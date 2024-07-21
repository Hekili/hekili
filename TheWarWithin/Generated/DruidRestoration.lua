-- DruidRestoration.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 105 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.LunarPower )

spec:RegisterTalents( {
    -- Druid Talents
    astral_influence            = { 82210, 197524, 1 }, -- Increases the range of all of your spells by $s1 yards.
    cyclone                     = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to $d. Only one target can be affected by your Cyclone at a time.
    feline_swiftness            = { 82239, 131768, 1 }, -- Increases your movement speed by $s1%.
    fluid_form                  = { 92229, 449193, 1 }, -- Shred and Rake can be used in any form and shift you into Cat Form. ; Mangle can be used in any form and shifts you into Bear Form. ; Wrath and Starfire shift you into Moonkin Form, if known.
    forestwalk                  = { 100173, 400129, 1 }, -- Casting Regrowth increases your movement speed and healing received by $400126s1% for $400126d.
    frenzied_regeneration       = { 82220, 22842 , 1 }, -- Heals you for $o1% health over $d$?s301768[, and increases healing received by $301768s1%][].
    heart_of_the_wild           = { 82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for $d.$?!s137013[; Balance: Cast time of Balance spells reduced by $s13% and damage increased by $s1%.][]$?!s137011[; Feral: Gain $s14 Combo Point every $t14 sec while in Cat Form and Physical damage increased by $s4%.][]$?!s137010[; Guardian: Bear Form gives an additional $s7% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has ${$s9+1} charges.][]$?!s137012[; Restoration: Healing increased by $s10%, and mana costs reduced by $s12%.][]
    hibernate                   = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to $d. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin           = { 82219, 327993, 1 }, -- Barkskin's duration is increased by ${$s1/1000} sec.
    improved_rejuvenation       = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by ${$m1/1000} sec.
    improved_stampeding_roar    = { 82230, 288826, 1 }, -- Cooldown reduced by ${$m1/-1000} sec.
    improved_sunfire            = { 93714, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within $164815A2 yards.
    incapacitating_roar         = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within $A1 yards for $d. Damage will cancel the effect.
    innervate                   = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for $d.$?s326228[; If cast on somebody else, you gain the effect at $326228s1% effectiveness.][]
    instincts_of_the_claw       = { 100176, 449184, 2 }, -- Shred, $?s202028[Brutal Slash][Swipe], Rake, Mangle, and Thrash damage increased by $s1%.
    ironfur                     = { 82227, 192081, 1 }, -- Increases armor by ${$s1*$AGI/100} for $d.$?a231070[ Multiple uses of this ability may overlap.][]
    killer_instinct             = { 82225, 108299, 2 }, -- Physical damage and Armor increased by $s1%.
    lore_of_the_grove           = { 100175, 449185, 2 }, -- Moonfire and Sunfire damage increased by $s1%. Rejuvenation and Wild Growth healing increased by $s3%.
    lycaras_teachings           = { 82233, 378988, 2 }, -- You gain $s1% of a stat while in each form:; No Form: Haste; Cat Form: Critical Strike; Bear Form: Versatility; Moonkin Form: Mastery
    maim                        = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point:;    1 point  : ${$s2*1} damage, 1 sec;    2 points: ${$s2*2} damage, 2 sec;    3 points: ${$s2*3} damage, 3 sec;    4 points: ${$s2*4} damage, 4 sec;    5 points: ${$s2*5} damage, 5 sec
    mass_entanglement           = { 82242, 102359, 1 }, -- Roots the target and all enemies within $A1 yards in place for $d. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                  = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb $<shield> damage for $280165d.
    mighty_bash                 = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for $d. Usable in all shapeshift forms.
    natural_recovery            = { 82206, 377796, 1 }, -- Healing you receive is increased by $s1%.
    natures_vigil               = { 82244, 124974, 1 }, -- For $d, $?s137012[all single-target healing also damages a nearby enemy target for $s3% of the healing done][all single-target damage also heals a nearby friendly target for $s3% of the damage done].
    nurturing_instinct          = { 82214, 33873 , 2 }, -- Magical damage and healing increased by $s1%.
    oakskin                     = { 100174, 449191, 1 }, -- Survival Instincts and Barkskin reduce damage taken by an additional $s1%.
    primal_fury                 = { 82238, 159286, 1 }, -- While in Cat Form, when you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect.; Mangle critical strike damage increased by $s2%.
    rake                        = { 82199, 1822  , 1 }, -- Rake the target for $s1 Bleed damage and an additional $155722o1 Bleed damage over $155722d.$?s48484[ Reduces the target's movement speed by $58180s1% for $58180d.][]$?a231052[ ; While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]$?a405834[ ; While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]; Awards $s2 combo $lpoint:points;.
    rejuvenation                = { 82217, 774   , 1 }, -- Heals the target for $o1 over $d.$?s155675[; You can apply Rejuvenation twice to the same target.][]$?s33891[; Tree of Life: Healing increased by $5420s5% and Mana cost reduced by $5420s4%.][]
    renewal                     = { 82232, 108238, 1 }, -- Instantly heals you for $s1% of maximum health. Usable in all shapeshift forms.
    rip                         = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point.;    1 point  : ${$o1*2} over ${$d*2} sec;    2 points: ${$o1*3} over ${$d*3} sec;    3 points: ${$o1*4} over ${$d*4} sec;    4 points: ${$o1*5} over ${$d*5} sec;    5 points: ${$o1*6} over ${$d*6} sec
    rising_light_falling_night  = { 82207, 417712, 1 }, -- Increases your damage and healing by $417714s1% during the day.; Increases your Versatility by $417715s1% during the night.
    skull_bash                  = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for $93985d.
    soothe                      = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar             = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within $A1 yards by $s1% for $d.
    starlight_conduit           = { 100223, 451211, 1 }, -- Wrath, Starsurge, and Starfire damage increased by $s1%. $?!a137013[; Starsurge's cooldown is reduced by ${-$s2/1000} sec and its mana cost is reduced by $s3%.][]
    sunfire                     = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for $164815s1 Nature damage and then an additional $164815o2 Nature damage over $164815d$?s231050[ to the primary target and all enemies within $164815A2 yards][].$?s137013[; Generates ${$m3/10} Astral Power.][]
    thick_hide                  = { 82228, 16931 , 1 }, -- Reduces all damage taken by $s1%.
    thrash                      = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                  = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by $s1%, reducing gradually over $d.
    typhoon                     = { 82209, 132469, 1 }, -- Blasts targets within $61391a1 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by $61391s3% for $61391d. Usable in all shapeshift forms.
    ursine_vigor                = { 82235, 377842, 1 }, -- For $340541d after shifting into Bear Form, your health and armor are increased by $s1%.
    ursocs_spirit               = { 100177, 449182, 1 }, -- Stamina in Bear Form is increased by $s1%.
    ursols_vortex               = { 82242, 102793, 1 }, -- Conjures a vortex of wind for $d at the destination, reducing the movement speed of all enemies within $A1 yards by $s1%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart               = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by $s1%.
    wellhoned_instincts         = { 82246, 377847, 1 }, -- When you fall below $s2% health, you cast Frenzied Regeneration, up to once every $s1 sec.
    wild_charge                 = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                 = { 82241, 48438 , 1 }, -- Heals up to $s2 injured allies within $A1 yards of the target for $o1 over $d. Healing starts high and declines over the duration.$?s33891[; Tree of Life: Affects $33891s3 additional $ltarget:targets;.][]

    -- Restoration Talents
    abundance                   = { 82052, 207383, 1 }, -- For each Rejuvenation you have active, Regrowth's cost is reduced by $207640s1% and critical effect chance is increased by $207640s2%, up to a maximum of ${$207640s2*$207640u}%.
    blooming_infusion           = { 94601, 429433, 1 }, -- Every $s1 Regrowths you cast makes your next Wrath, Starfire, or Entangling Roots instant and increases damage it deals by $429474s2%.; Every $s1 Starsurges $?a137013[or Starfalls ][]you cast makes your next Regrowth or Entangling roots instant.
    bond_with_nature            = { 94625, 439929, 1 }, -- Healing you receive is increased by $s1%.
    bounteous_bloom             = { 94591, 429215, 1 }, -- $?a137013[Your Force of Nature treants generate ${$429217m1/10} Astral Power every $429217t1 sec.][Your Grove Guardians' healing is increased by $s1%.]
    budding_leaves              = { 82072, 392167, 2 }, -- Lifebloom's healing is increased by ${$s1}.1% each time it heals, up to $s2%. Also increases Lifebloom's final bloom amount by $s3%.
    bursting_growth             = { 94630, 440120, 1 }, -- When Bloodseeker Vines expire or you use Ferocious Bite on their target they explode in thorns, dealing $440122s1 physical damage to nearby enemies. Damage reduced above 5 targets.; When Symbiotic Blooms expire or you cast Rejuvenation on their target flowers grow around their target, healing them and up to $440121s2 nearby allies for $440121s1.
    call_of_the_elder_druid     = { 82067, 426784, 1 }, -- [319454] Abilities not associated with your specialization are substantially empowered for $d.$?!s137013[; Balance: Cast time of Balance spells reduced by $s13% and damage increased by $s1%.][]$?!s137011[; Feral: Gain $s14 Combo Point every $t14 sec while in Cat Form and Physical damage increased by $s4%.][]$?!s137010[; Guardian: Bear Form gives an additional $s7% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has ${$s9+1} charges.][]$?!s137012[; Restoration: Healing increased by $s10%, and mana costs reduced by $s12%.][]
    cenarion_ward               = { 82052, 102351, 1 }, -- Protects a friendly target for $d. Any damage taken will consume the ward and heal the target for $102352o1 over $102352d.
    cenarius_guidance           = { 82063, 393371, 1 }, -- $@spellicon33891 $@spellname5420; During Incarnation: Tree of Life, you summon a Grove Guardian every $393418t sec. The cooldown of Incarnation: Tree of Life is reduced by ${$393381s1/-1000}.1 sec when Grove Guardians fade.; $@spellicon391528 $@spellname391528; Convoke the Spirits' cooldown is reduced by ${($abs($393374s4)/120000)*100}% and its duration and number of spells cast is reduced by $393374s1%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    cenarius_might              = { 94604, 455797, 1 }, -- $?a137013[Entering Eclipse][Casting Swiftmend] increases your Haste by $455801s1% for $455801d.
    control_of_the_dream        = { 94592, 434249, 1 }, -- Time elapsed while your major abilities are available to be used is subtracted from that ability's cooldown after the next time you use it, up to $s1 seconds.; Affects $?a137012[Nature's Swiftness, Incarnation: Tree of Life,][Force of Nature,] $?a137012[]?a394013[Incarnation: Chosen of Elune, ][Celestial Alignment, ]and Convoke the Spirits.
    convoke_the_spirits         = { 82064, 391528, 1 }, -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of $s2 Druid spells and abilities over $d.$?s391538[ Chance to use an exceptional spell or ability is increased.][]; You will cast $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    cultivation                 = { 82056, 200390, 1 }, -- When Rejuvenation heals a target below $s1% health, it applies Cultivation to the target, healing them for $200389o1 over $200389d.
    dream_of_cenarius           = { 82066, 158504, 1 }, -- While Heart of the Wild is active, Wrath and Shred transfer $s1% of their damage and Starfire and Swipe transfer $s2% of their damage into healing onto a nearby ally.
    dream_surge                 = { 94600, 433831, 1 }, -- $?a137013[Force of Nature grants $s1 charges of Dream Burst, causing your next Wrath or Starfire to explode on the target, dealing ${$433850s1*(1+$393014s3/100)} Nature damage to nearby enemies. Damage reduced above $433850s2 targets.][Grove Guardians causes your next targeted heal to create $s2 Dream Petals near the target, healing up to 3 nearby allies for $434141s1. Stacks up to 3 charges.]
    dreamstate                  = { 82053, 392162, 1 }, -- While channeling Tranquility, your other Druid spell cooldowns are reduced by up to ${($s1/-1000)*5} seconds.
    durability_of_nature        = { 94605, 429227, 1 }, -- $?a137013[Your Force of Nature treants have 50% increased health.][Your Grove Guardians' Nourish and Swiftmend spells also apply a Minor Cenarion Ward that heals the target for $429222o1 over $429222d the next time they take damage.]
    early_spring                = { 94591, 428937, 1 }, -- $?a137013[Force of Nature cooldown reduced by ${$s1/-1000} sec.][Grove Guardians cooldown reduced by ${$s2/-1000} sec.]
    efflorescence               = { 82057, 145205, 1 }, -- Grows a healing blossom at the target location, restoring $81269s1 health to $?p138284[four][three] injured allies within $81269A1 yards every $81262t1 sec for $81262d. Limit 1.
    embrace_of_the_dream        = { 82070, 392124, 1 }, -- Wild Growth momentarily shifts your mind into the Emerald Dream, instantly healing all allies affected by your Rejuvenation or Regrowth for $392147s1.
    entangling_vortex           = { 94622, 439895, 1 }, -- Enemies pulled into Ursol's Vortex are rooted in place for ${$s1/1000} sec. Damage may cancel the effect.
    expansiveness               = { 94602, 429399, 1 }, -- Your maximum mana is increased by $s2%$?a137013[ and your maximum Astral Power is increased by ${$s1/10}][].
    flash_of_clarity            = { 82083, 392220, 1 }, -- Clearcast Regrowths heal for an additional $s1%.
    flourish                    = { 82073, 197721, 1 }, -- Extends the duration of all of your heal over time effects on friendly targets within $A1 yards by $s1 sec, and increases the rate of your heal over time effects by ${100*(1/(1+($m2/100))-1)}% for $d.
    flower_walk                 = { 94622, 439901, 1 }, -- During Barkskin your movement speed is increased by $s1% and every second flowers grow beneath your feet that heal up to $439902s2 nearby injured allies for $439902s1.
    germination                 = { 82071, 155675, 1 }, -- You can apply Rejuvenation twice to the same target. Rejuvenation's duration is increased by ${$s1/1000} sec.
    grove_guardians             = { 82043, 102693, 1 }, -- Summons a Treant which will immediately cast Swiftmend on your current target, healing for ${$422094m1}.  The Treant will cast Nourish on that target or a nearby ally periodically, healing for ${$422090m1}. Lasts $d.
    grove_tending               = { 82047, 383192, 1 }, -- Swiftmend heals the target for $383193o1 over $383193d.
    groves_inspiration          = { 94595, 429402, 1 }, -- Wrath and Starfire damage increased by $s1%. ; Regrowth$?a137013[ and Wild Growth][, Wild Growth, and Swiftmend] healing increased by $s2%.
    harmonious_blooming         = { 82065, 392256, 2 }, -- Lifebloom counts for ${$s1+1} stacks of Mastery: Harmony.
    harmonious_constitution     = { 94625, 440116, 1 }, -- Your Regrowth's healing to yourself is increased by $s1%.
    harmony_of_the_grove        = { 94606, 428731, 1 }, -- $?a137013[Each of your Force of Nature treants increases damage your spells deal by $428735s1% while active.][Each of your Grove Guardians increases your healing done by $428737s1% while active.]
    hunt_beneath_the_open_skies = { 94629, 439868, 1 }, -- Damage and healing while in Cat Form increased by $s1%.; Moonfire and Sunfire damage increased by $s4%.
    implant                     = { 94628, 440118, 1 }, -- $?a137011[When you gain or lose Tiger's Fury, your next single-target melee ability causes a Bloodseeker Vine to grow on the target for ${$s1/1000} sec.][Your Swiftmend causes a Symbiotic Bloom to grow on the target for ${$s2/1000} sec.]
    improved_ironbark           = { 82081, 382552, 1 }, -- Ironbark's cooldown is reduced by ${$s1/-1000} sec.
    improved_natures_cure       = { 82203, 392378, 1 }, -- Nature's Cure additionally removes all Curse and Poison effects.
    improved_regrowth           = { 82055, 231032, 1 }, -- Regrowth's initial heal has a $s1% increased chance for a critical effect if the target is already affected by Regrowth.
    improved_wild_growth        = { 82045, 328025, 1 }, -- Wild Growth heals $s1 additional $ltarget:targets;.
    incarnation_tree_of_life    = { 82064, 33891 , 1 }, -- Shapeshift into the Tree of Life, increasing healing done by $5420s1%, increasing armor by $5420s3%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, Entangling Roots, and Wrath is enhanced.; Lasts $117679d. You may shapeshift in and out of this form for its duration.
    inner_peace                 = { 82053, 197073, 1 }, -- Reduces the cooldown of Tranquility by ${$m1/-1000} sec.; While channeling Tranquility, you take $740s5% reduced damage and are immune to knockbacks.
    invigorate                  = { 82070, 392160, 1 }, -- Refreshes the duration of your active Lifebloom and Rejuvenation effects on the target and causes them to complete $s1% faster.
    ironbark                    = { 82082, 102342, 1 }, -- The target's skin becomes as tough as Ironwood, reducing damage taken by $s1%$?a197061[ and increasing healing from your heal over time effects by $s2%][] for $d.$?a392116[; Allies protected by your Ironbark also receive $392116s1% of the healing from each of your active Rejuvenations.][]
    lethal_preservation         = { 94624, 455461, 1 }, -- When you remove an effect with Soothe or $?s88423[Nature's Cure][Remove Corruption], gain a combo point and heal for $s1% of your maximum health. If you are at full health an injured party or raid member will be healed instead.
    lifebloom                   = { 82049, 33763 , 1 }, -- Heals the target for $o1 over $d. When Lifebloom expires or is dispelled, the target is instantly healed for $33778s1.; May be active on $?s338831[two targets][one target] at a time.
    liveliness                  = { 82074, 426702, 1 }, -- Your damage over time effects deal their damage $s1% faster, and your healing over time effects heal $s2% faster.
    master_shapeshifter         = { 82074, 289237, 1 }, -- Your abilities are amplified based on your current shapeshift form, granting an additional effect.; Wrath, Starfire, and Starsurge deal $s2% additional damage and generate $411146s1 Mana.; $@spellicon197491Bear Form; Ironfur grants $s1% additional armor and generates $411144s1 Mana.; $@spellicon202155 Cat Form; Rip, Ferocious Bite, and Maim deal $s3% additional damage and generate $411143s1 Mana when cast with $s4 combo points.
    natures_splendor            = { 82051, 392288, 1 }, -- The healing bonus to Regrowth from Nature's Swiftness is increased by $s1%.
    natures_swiftness           = { 82050, 132158, 1 }, -- Your next Regrowth, Rebirth, or Entangling Roots is instant, free, castable in all forms, and heals for an additional $s2%.
    nourish                     = { 82043, 50464 , 1 }, -- Heals a friendly target for $s1.  Receives $s2% bonus from $@spellname77495.
    nurturing_dormancy          = { 82076, 392099, 1 }, -- When your Rejuvenation heals a full health target, its duration is increased by $s1 sec, up to a maximum total increase of $s2 sec per cast.
    omen_of_clarity             = { 82084, 113043, 1 }, -- Your healing over time from Lifebloom has a $s1% chance to cause a Clearcasting state, making your next $?a155577[${$155577m1+1} Regrowths][Regrowth] cost no mana.
    overgrowth                  = { 82061, 203651, 1 }, -- Apply Lifebloom, Rejuvenation, Wild Growth, and Regrowth's heal over time effect to an ally.
    passing_seasons             = { 82051, 382550, 1 }, -- Nature's Swiftness's cooldown is reduced by ${$s1/-1000} sec.
    photosynthesis              = { 82073, 274902, 1 }, -- While your Lifebloom is on yourself, your periodic heals heal $s1% faster.; While your Lifebloom is on an ally, your periodic heals on them have a $s2% chance to cause it to bloom.
    potent_enchantments         = { 94595, 429420, 1 }, -- $?a137013[Orbital Strike applies Stellar Flare for ${$s1/1000} additional sec and deals $s2% increased damage.; Greater Alignment increases the duration of ][]$?s394013[Incarnation: Chosen of Elune]?s194223[Celestial Alignment][]$?a137013[ by an additional $s3% and increases Eclipse damage during ][]$?s394013[Incarnation: Chosen of Elune]?s194223[Celestial Alignment][]$?a137013[ by an additional $s4%.][Reforestation grants Tree of Life for $s5 additional sec.]
    power_of_nature             = { 94605, 428859, 1 }, -- $?a137013[Your Force of Nature treants no longer taunt and deal $449001s1% increased melee damage.][Your Grove Guardians increase the healing of your Rejuvenation, Efflorescence, and Lifebloom by $428866s1% while active.]
    power_of_the_archdruid      = { 82077, 392302, 1 }, -- Wild Growth has a $h% chance to cause your next Rejuvenation or Regrowth to apply to $s1 additional $Lally:allies; within $189877s1 yards of the target.
    power_of_the_dream          = { 94592, 434220, 1 }, -- $?a137013[Force of Nature grants an additional stack of Dream Burst.][Healing spells cast with Dream Surge generate an additional Dream Petal.]
    prosperity                  = { 82079, 200383, 1 }, -- Swiftmend now has ${$m1+1} charges.
    protective_growth           = { 94593, 433748, 1 }, -- Your Regrowth protects you, reducing damage you take by $433749s1% while your Regrowth is on you.
    rampant_growth              = { 82058, 404521, 1 }, -- Regrowth's healing over time is increased by $s1%, and it also applies to the target of your Lifebloom.
    reforestation               = { 82069, 392356, 1 }, -- Every $s1 casts of Swiftmend grants you Incarnation: Tree of Life for $s2 sec.
    regenerative_heartwood      = { 82075, 392116, 1 }, -- Allies protected by your Ironbark also receive $s1% of the healing from each of your active Rejuvenations and Ironbark's duration is increased by ${$s2/1000} sec.
    regenesis                   = { 82062, 383191, 2 }, -- Rejuvenation healing is increased by up to $s1%, and Tranquility healing is increased by up to $s2%, healing for more on low-health targets.
    resilient_flourishing       = { 94631, 439880, 1 }, -- Bloodseeker Vines and Symbiotic Blooms last ${$s1/1000} additional sec.; When a target afflicted by Bloodseeker Vines dies, the vines jump to a valid nearby target for their remaining duration.
    root_network                = { 94631, 439882, 1 }, -- Each active Bloodseeker Vine increases the damage your abilities deal by 2%.; Each active Symbiotic Bloom increases the healing of your spells by 2%.
    soul_of_the_forest          = { 82059, 158478, 1 }, -- Swiftmend increases the healing of your next Regrowth or Rejuvenation by $114108s1%, or your next Wild Growth by $114108s2%.
    spring_blossoms             = { 82061, 207385, 1 }, -- Each target healed by Efflorescence is healed for an additional $207386o1 over $207386d.
    starfire                    = { 91040, 197628, 1 }, -- Call down a burst of energy, causing $s1 Arcane damage to the target, and ${$m1*$m2/100} Arcane damage to all other enemies within $A1 yards. Deals reduced damage beyond $s3 targets.
    starsurge                   = { 82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing $s1 Astral damage.
    stonebark                   = { 82081, 197061, 1 }, -- Ironbark increases healing from your heal over time effects by $s1%.
    strategic_infusion          = { 94623, 439890, 1 }, -- $?a137011[Tiger's Fury and attacking][Attacking] from Prowl increases the chance for Shred, Rake, and $?s202028[Brutal Slash][Swipe] to critically strike by $439891s1% for $439891d.; Casting Regrowth increases the chance for your periodic heals to critically heal by $439893s1% for $439893d.
    thriving_growth             = { 94626, 439528, 1 }, -- Rip and Rake damage has a chance to cause Bloodseeker Vines to grow on the victim, dealing $439531o1 Bleed damage over $439531d.; $?a137011[Wild Growth and Regrowth][Wild Growth, Regrowth, and Efflorescence] healing has a chance to cause Symbiotic Blooms to grow on the target, healing for $439530o1 over $439530d.; Multiple instances of these can overlap.
    thriving_vegetation         = { 82068, 447131, 2 }, -- Rejuvenation instantly heals your target for $s1% of its total periodic effect and Regrowth's duration is increased by ${$s2/1000} sec.
    tranquil_mind               = { 92674, 403521, 1 }, -- Increases Omen of Clarity's chance to activate Clearcasting to $s3% and Clearcasting can stack $s1 additional time.
    tranquility                 = { 82054, 740   , 1 }, -- Heals all allies within $a2 yards for $<healing> over $d. Each heal heals the target for another $157982o2 over $157982d, stacking.; Healing decreased beyond $s3 targets.
    treants_of_the_moon         = { 94599, 428544, 1 }, -- Your $?a137013[Force of Nature treants][Grove Guardians] cast Moonfire on nearby targets about once every $s1 sec.
    twin_sprouts                = { 94628, 440117, 1 }, -- When Bloodseeker Vines or Symbiotic Blooms grow, they have a $s1% chance to cause another growth of the same type to immediately grow on a valid nearby target.
    undergrowth                 = { 82077, 392301, 1 }, -- You may Lifebloom two targets at once, but Lifebloom's healing is reduced by $s1%.
    unstoppable_growth          = { 82080, 382559, 2 }, -- Wild Growth's healing falls off $s1% less over time.
    verdancy                    = { 82060, 392325, 1 }, -- When Lifebloom blooms, up to $s1 targets within your Efflorescence are healed for $392329s1.
    verdant_infusion            = { 82079, 392410, 1 }, -- Swiftmend no longer consumes a heal over time effect, and extends the duration of your heal over time effects on the target by $s1 sec.
    vigorous_creepers           = { 94627, 440119, 1 }, -- Bloodseeker Vines increase the damage your abilities deal to affected enemies by $s1%.; Symbiotic Blooms increase the healing your spells do to affected targets by $s2%.
    waking_dream                = { 82046, 392221, 1 }, -- Ysera's Gift now heals every ${$s2/1000} sec and its healing is increased by $s1% for each of your active Rejuvenations.
    wild_synthesis              = { 94535, 400533, 1 }, -- $@spellicon50464 $@spellname50464; Regrowth decreases the cast time of your next Nourish by $400534s1% and causes it to receive an additional $400534s2% bonus from $@spellname77495. Stacks up to $s1 times.; $@spellicon102693$@spellname102693; Treants from Grove Guardians also cast Wild Growth immediately when summoned, healing $422382s2 allies within $422382A1 yds for $422382o1 over $422382d.
    wildstalkers_power          = { 94621, 439926, 1 }, -- Rip and Ferocious Bite damage increased by $s1%.; Rejuvenation$?a137012[, Efflorescence, and Lifebloom][] healing increased by $s3%.
    yseras_gift                 = { 82048, 145108, 1 }, -- Heals you for $s1% of your maximum health every $t1 sec. If you are at full health, an injured party or raid member will be healed instead.$?a392221[; Healing is increased by $392221s1% for each of your active Rejuvenations.][]
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    deep_roots         = 700 , -- (233755) Increases the amount of damage required to cancel your Entangling Roots$?s102359[ or Mass Entanglement][] by $s1%.
    disentanglement    = 59  , -- (233673) Efflorescence removes all snare effects from friendly targets when it heals and its Mana cost is reduced by $s2%.
    early_spring       = 1215, -- (203624) Wild Growth is now instant cast, and when you heal 6 allies with Wild Growth you gain Full Bloom. This effect has a 30 sec cooldown.; Full Bloom; Your next Wild Growth applies Lifebloom to all targets at $s2% effectiveness. Lasts for 30 sec.
    entangling_bark    = 692 , -- (247543) Ironbark now also grants the target Nature's Grasp, rooting the first $s1 melee attackers for $170855d.
    focused_growth     = 835 , -- (203553) Reduces the mana cost of your Lifebloom by $m1%, and your Lifebloom also applies Focused Growth to the target, increasing Lifebloom's healing by $?a338831[$347621s1%][$203554s1%]. Stacks up to $203554u times.
    high_winds         = 838 , -- (200931) Increases the range of Cyclone, Typhoon, and Entangling Roots by $s1 yds.
    malornes_swiftness = 5514, -- (236147) Your Travel Form movement speed while within a Battleground or Arena is increased by $m2% and you always move at $m1% movement speed while in Travel Form.
    preserve_nature    = 5387, -- (353114) Tranquility protects you from all harm while it is channeled, and its healing is increased by $s1%.
    reactive_resin     = 691 , -- (409785) Enemies have their movement speed reduced by $410063s1% for $410063d when removing your Restoration heal over time effects, stacking.  Enemies are silenced and rooted for $410065d at $s1 stacks.
    thorns             = 697 , -- (305497) Sprout thorns for $d on the friendly target. When victim to melee attacks, thorns deals $305496s1 Nature damage back to the attacker.; Attackers also have their movement speed reduced by $232559s1% for $232559d.
    tireless_pursuit   = 5649, -- (377801) For ${$s1/1000} sec after leaving Cat Form or Travel Form, you retain up to $s2% movement speed.
} )

-- Auras
spec:RegisterAuras( {
    -- Regrowth cost reduced by $s1% and critical effect chance increased by $s2%.
    abundance = {
        id = 207640,
        duration = 30.0,
        max_stack = 1,
    },
    -- Bleeding for $w2 damage every $t2 sec.
    ashamanes_frenzy = {
        id = 210723,
        duration = 6.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,
    },
    -- All damage taken reduced by $w1%.
    barkskin = {
        id = 22812,
        duration = 8.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- improved_barkskin[327993] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- oakskin[449191] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- verdant_heart[301768] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- flower_walk[439901] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },
    -- Armor increased by $w4%.; Stamina increased by $1178s2%.; Immune to Polymorph effects.$?$w13<0[; Arcane damage taken reduced by $w14% and all other magic damage taken reduced by $w13%.][]
    bear_form = {
        id = 5487,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap. All attack and ability damage is increased by $s3%.
    berserk = {
        id = 106951,
        duration = 15.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 damage every $t1 sec.
    bloodseeker_vines = {
        id = 439531,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- resilient_flourishing[439880] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- vigorous_creepers[440119] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Your next Wrath, Starfire, or Entangling Roots is instant and deals $w2% increased damage.
    blooming_infusion = {
        id = 429474,
        duration = 12.0,
        max_stack = 1,
    },
    -- Autoattack damage increased by $w4%.; Immune to Polymorph effects.; Movement speed increased by $113636s1% and falling damage reduced.
    cat_form = {
        id = 768,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Taking damage will grant $102352m1 healing every $102352t sec for $102352d.
    cenarion_ward = {
        id = 102351,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- bear_form[5487] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- [393381] During Incarnation: Tree of Life, you summon a Grove Guardian every $393418t sec. The cooldown of Incarnation: Tree of Life is reduced by ${$s1/-1000}.1 sec when Grove Guardians fade.
    cenarius_guidance = {
        id = 393418,
        duration = 30.0,
        tick_time = 10.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    cenarius_might = {
        id = 455801,
        duration = 6.0,
        max_stack = 1,
    },
    -- Charmed.
    charm_woodland_creature = {
        id = 127757,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Your next Regrowth is free$?s155577[ and heals for an additonal $w2%][].
    clearcasting = {
        id = 16870,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- flash_of_clarity[392220] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- tranquil_mind[403521] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Every ${$t1}.2 sec, casting $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake or Thrash on appropriate nearby targets.
    convoke_the_spirits = {
        id = 391528,
        duration = 4.0,
        tick_time = 0.25,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- restoration_druid[137012] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },
    -- Heals $w1 damage every $t1 seconds.
    cultivation = {
        id = 200389,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },
    -- Disoriented and invulnerable.
    cyclone = {
        id = 33786,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- cat_form[3025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- high_winds[200931] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Increased movement speed by $s1% while in Cat Form.
    dash = {
        id = 1850,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- cat_form[768] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },
    -- Restores health to three injured allies within $81269A1 yards every $81262t1 sec for $81262d.
    efflorescence = {
        id = 81262,
        duration = 30.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- disentanglement[233673] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Rooted.
    entangling_roots = {
        id = 170855,
        duration = 6.0,
        max_stack = 1,
    },
    -- Heal over time spells are healing ${100*(1/(1+($m1/100))-1)}% faster.
    essence_of_ghanir = {
        id = 208253,
        duration = 8.0,
        max_stack = 1,
    },
    -- Hovering.
    flap = {
        id = 164862,
        duration = 15.0,
        max_stack = 1,
    },
    -- Immune to Polymorph effects. Movement speed increased and allows you to fly.
    flight_form = {
        id = 165962,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- malornes_swiftness[236147] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Heal over time spells are healing ${100*(1/(1+($m2/100))-1)}% faster.
    flourish = {
        id = 197721,
        duration = 6.0,
        max_stack = 1,
    },
    -- Increases speed and all healing taken by $w1%.
    forestwalk = {
        id = 400126,
        duration = 6.0,
        max_stack = 1,
    },
    -- Healing $w1% health every $t1 sec.
    frenzied_regeneration = {
        id = 22842,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- restoration_druid[137012] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- heart_of_the_wild[319454] #8: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- verdant_heart[301768] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Heals $w1 every $t1 sec.
    grove_tending = {
        id = 383193,
        duration = 9.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },
    -- Taunted.
    growl = {
        id = 6795,
        duration = 3.0,
        max_stack = 1,
    },
    -- Abilities not associated with your specialization are substantially empowered.
    heart_of_the_wild = {
        id = 319454,
        duration = 45.0,
        tick_time = 2.0,
        max_stack = 1,
    },
    -- Asleep.
    hibernate = {
        id = 2637,
        duration = 40.0,
        max_stack = 1,

        -- Affected by:
        -- cat_form[768] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- Incapacitated.
    incapacitating_roar = {
        id = 99,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Allows the use of Prowl even while in combat.
    incarnation_avatar_of_ashamane = {
        id = 252071,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Healing increased by $5420s1%.; Armor increased by $5420s3%.; Some spells are enhanced.
    incarnation_tree_of_life = {
        id = 33891,
        duration = 3600,
        tick_time = 7.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Mana costs reduced $w1%.
    innervate = {
        id = 29166,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- cat_form[768] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- All damage taken is reduced by $w1%$?<$w2>0>[ and healing over time from $@auracaster increased by $w2%][].
    ironbark = {
        id = 102342,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- improved_ironbark[382552] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- regenerative_heartwood[392116] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- stonebark[197061] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Armor increased by ${$w1*$AGI/100}.
    ironfur = {
        id = 192081,
        duration = 7.0,
        max_stack = 1,

        -- Affected by:
        -- heart_of_the_wild[319454] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- master_shapeshifter[289237] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ironfur[231070] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Healing $w1 every $t1 sec.; Blooms for additional healing when effect expires or is dispelled.
    lifebloom = {
        id = 33763,
        duration = 15.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- budding_leaves[392167] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.7, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- undergrowth[392301] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- undergrowth[392301] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- focused_growth[203553] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -8.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_dark_titans_lesson[338831] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_dark_titans_lesson[338831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Stunned.
    maim = {
        id = 22570,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- master_shapeshifter[289237] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Versatility increased by $w1%.
    mark_of_the_wild = {
        id = 1126,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Rooted.
    mass_entanglement = {
        id = 102359,
        duration = 10.0,
        tick_time = 2.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    matted_fur = {
        id = 385787,
        duration = 8.0,
        max_stack = 1,
    },
    -- Your next Rejuvenation or Regrowth will apply to $339064s1 additional allies within $w1 yards of the target.
    memory_of_the_mother_tree = {
        id = 189877,
        duration = 15.0,
        max_stack = 1,
    },
    -- Stunned.
    mighty_bash = {
        id = 5211,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Suffering $w2 Arcane damage every $t2 seconds.$?$w8<0[; Movement slowed by $w8%.][]
    moonfire = {
        id = 164812,
        duration = 18.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonfire[164812] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- moonfire[164812] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- lore_of_the_grove[449185] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hunt_beneath_the_open_skies[439868] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hunt_beneath_the_open_skies[439868] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Spell damage increased by $s9%.; Immune to Polymorph effects.$?$w3>0[; Armor increased by $w3%.][]$?$w12<0[; Arcane damage taken reduced by $w13% and all other magic damage taken reduced by $w12%.][]
    moonkin_form = {
        id = 24858,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- feral_druid[137011] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- owlkin_frenzy[231042] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },
    -- Immune to Polymorph effects. Movement speed increased by $5419s1%.
    mount_form = {
        id = 210053,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- malornes_swiftness[236147] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Your next Regrowth, Rebirth, or Entangling Roots is instant, free, castable in all forms, and heals for an additional $w2%.
    natures_swiftness = {
        id = 132158,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- natures_splendor[392288] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- passing_seasons[382550] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -12000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- $?s137012[Single-target healing also damages a nearby enemy target for $w3% of the healing done][Single-target damage also heals a nearby friendly target for $w3% of the damage done].
    natures_vigil = {
        id = 124974,
        duration = 15.0,
        tick_time = 0.5,
        max_stack = 1,
    },
    -- Your next Rejuvenation or Regrowth will apply to $392302s1 additional $Lally:allies; within $w1 yards of the target.
    power_of_the_archdruid = {
        id = 392303,
        duration = 15.0,
        max_stack = 1,
    },
    -- All damage taken reduced by $w1%.
    protective_growth = {
        id = 433749,
        duration = 3600,
        max_stack = 1,
    },
    -- Stealthed.
    prowl = {
        id = 102547,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- incarnation_avatar_of_ashamane[252071] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102547, 'target': TARGET_UNIT_CASTER, }
    },
    -- Stunned.
    rake = {
        id = 163505,
        duration = 4.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%. Rooted and Silenced at $409785s1 stacks.
    reactive_resin = {
        id = 410063,
        duration = 8.0,
        max_stack = 1,
    },
    -- Heals $w2 every $t2 sec.
    regrowth = {
        id = 8936,
        duration = 12.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[3025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- clearcasting[16870] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- clearcasting[16870] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[81097] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- groves_inspiration[429402] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- groves_inspiration[429402] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- harmonious_constitution[440116] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 35.0, 'target': TARGET_UNIT_CASTER, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- natures_swiftness[132158] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[132158] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- natures_swiftness[132158] #2: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'points': -100.0, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- natures_swiftness[132158] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rampant_growth[404521] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- thriving_vegetation[447131] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- abundance[207640] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -8.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- abundance[207640] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- balance_druid[137013] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 47.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- feral_druid[137011] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Healing $w1 every $t1 sec.
    rejuvenation = {
        id = 774,
        duration = 12.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 110.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_tree_of_life[5420] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bear_form[5487] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_rejuvenation[231040] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- lore_of_the_grove[449185] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- germination[155675] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- regenesis[383191] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }
        -- wildstalkers_power[439926] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Bleeding for $w1 damage every $t1 sec.
    rip = {
        id = 1079,
        duration = 4.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 84.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- master_shapeshifter[289237] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- master_shapeshifter[289237] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Damage and healing increased by $s1%.
    rising_light_falling_night_day = {
        id = 417714,
        duration = 3600,
        max_stack = 1,
    },
    -- Versatility increased by $s1%.
    rising_light_falling_night_night = {
        id = 417715,
        duration = 3600,
        max_stack = 1,
    },
    -- Healing of your next Regrowth or Rejuvenation increased by $s1%, or your next Wild Growth by $s2%.
    soul_of_the_forest = {
        id = 114108,
        duration = 15.0,
        max_stack = 1,
    },
    -- Heals $w1 damage every $t1 seconds.
    spring_blossoms = {
        id = 207386,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },
    -- Movement speed increased by $s1%.
    stampeding_roar = {
        id = 106898,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- improved_stampeding_roar[288826] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Suffering $w2 Nature damage every $t2 sec.
    sunfire = {
        id = 93402,
        duration = 0.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $232559s1%.
    thorns = {
        id = 232559,
        duration = 4.0,
        max_stack = 1,
    },
    -- Increased movement speed by $s1% while in Cat Form, reducing gradually over time.
    tiger_dash = {
        id = 252216,
        duration = 5.0,
        tick_time = 0.5,
        max_stack = 1,

        -- Affected by:
        -- cat_form[768] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },
    -- Tracking beasts.
    track_beasts = {
        id = 210065,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking humanoids.
    track_humanoids = {
        id = 5225,
        duration = 3600,
        max_stack = 1,
    },
    -- Healing all allies within $a1 yards for $157982s1 every $t1 sec.
    tranquility = {
        id = 740,
        duration = 8.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- astral_influence[197524] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- inner_peace[197073] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- preserve_nature[353114] #1: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_MELEE_CRIT_DAMAGE, 'target': TARGET_UNIT_CASTER, }
    },
    -- Immune to Polymorph effects. Movement speed increased.
    travel_form = {
        id = 783,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- malornes_swiftness[236147] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Shapeshifted into Treant Form.  All spells may be cast while in this form.
    treant_form = {
        id = 114282,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement speed reduced by $s3%.
    typhoon = {
        id = 61391,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- astral_influence[197524] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- high_winds[200931] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- high_winds[200931] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Health and armor increased by ${$w1}.1%.
    ursine_vigor = {
        id = 340541,
        duration = 4.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    ursocs_endurance = {
        id = 280165,
        duration = 8.0,
        max_stack = 1,
    },
    -- Movement speed slowed by $s1% and winds impeding movement.
    ursols_vortex = {
        id = 102793,
        duration = 10.0,
        max_stack = 1,
    },
    -- Flying to an ally's position.
    wild_charge = {
        id = 102401,
        duration = 0.5,
        max_stack = 1,

        -- Affected by:
        -- cat_form[3025] #2: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 49376, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- aquatic_form_passive[5421] #2: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102416, 'target': TARGET_UNIT_CASTER, }
        -- bear_form_passive_2[21178] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 16979, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- travel_form_passive[5419] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102417, 'target': TARGET_UNIT_CASTER, }
        -- moonkin_form[24858] #6: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102383, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
    },
    -- Heals $w1 damage every $t1 sec.
    wild_growth = {
        id = 48438,
        duration = 7.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- groves_inspiration[429402] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- groves_inspiration[429402] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_wild_growth[328025] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- early_spring[203624] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- The cast time of Nourish is reduced by $w1% and it receives $w2% additional bonus from $@spellname77495.
    wild_synthesis = {
        id = 400534,
        duration = 3600,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Unleash Ashamane's Frenzy, clawing your target $m2 times over $d for ${$210723s1*$m2} Physical damage and an additional ${$210723s3*3*$m2} Bleed damage over $210723d.; Awards $s3 combo $Lpoint:points;.
    ashamanes_frenzy = {
        id = 210722,
        color = 'artifact',
        cast = 0.0,
        cooldown = 75.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.2, 'points': 15.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Your skin becomes as tough as bark, reducing all damage you take by $s1%$?a301768[, increasing healing received by $301768s2%,][] and preventing damage from delaying your spellcasts. Lasts $d.; Usable while stunned, frozen, incapacitated, feared, or asleep, and in all shapeshift forms.
    barkskin = {
        id = 22812,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': REDUCE_PUSHBACK, 'points': 100.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 15, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'attributes': ['Compute Points Only At Cast Time'], 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'amplitude': 1.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- improved_barkskin[327993] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- oakskin[449191] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- verdant_heart[301768] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- flower_walk[439901] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },

    -- Shapeshift into Bear Form, increasing armor by $m4% and Stamina by $1178s2%, granting protection from Polymorph effects, and increasing threat generation.; The act of shapeshifting frees you from movement impairing effects.
    bear_form = {
        id = 5487,
        color = 'shapeshift',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'variance': 0.25, 'target': TARGET_UNIT_CASTER, 'form': bear_form, 'creature_type': beast, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_MELEE_CRIT_CHANCE, 'points': -6.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_BASE_RESISTANCE_PCT, 'points': 220.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 17, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_EXPERTISE, 'points': 3.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #9: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- #12: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -3.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #13: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -6.0, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Go Berserk for $d. While Berserk:; Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap.; All attack and ability damage is increased by $s3%.
    berserk = {
        id = 106951,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.5, 'trigger_spell': 343216, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Shapeshift into Cat Form, increasing auto-attack damage by $s4%, movement speed by $113636s1%, granting protection from Polymorph effects, and reducing falling damage.; The act of shapeshifting frees you from movement impairing effects.
    cat_form = {
        id = 768,
        color = 'shapeshift',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, 'form': cat_form, 'creature_type': beast, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 17, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'sp_bonus': 0.25, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -33.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- #6: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #8: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Protects a friendly target for $d. Any damage taken will consume the ward and heal the target for $102352o1 over $102352d.
    cenarion_ward = {
        id = 102351,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.018,
        spendType = 'mana',

        talent = "cenarion_ward",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'sp_bonus': 0.25, 'trigger_spell': 102352, 'triggers': cenarion_ward, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- bear_form[5487] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of $s2 Druid spells and abilities over $d.$?s391538[ Chance to use an exceptional spell or ability is increased.][]; You will cast $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    convoke_the_spirits = {
        id = 391528,
        cast = 4.0,
        channeled = true,
        cooldown = 120.0,
        gcd = "global",

        talent = "convoke_the_spirits",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.25, 'points': 4.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 16.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- restoration_druid[137012] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- restoration_druid[137012] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },

    -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to $d. Only one target can be affected by your Cyclone at a time.
    cyclone = {
        id = 33786,
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        talent = "cyclone",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'mechanic': banished, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'mechanic': banished, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'mechanic': banished, 'points': -100.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- cat_form[3025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- high_winds[200931] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Shift into Cat Form and increase your movement speed by $s1% while in Cat Form for $d.
    dash = {
        id = 1850,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 60.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- cat_form[768] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },

    -- Teleports the caster to the Emerald Dreamway.; Casting Dreamwalk again while in the Emerald Dreamway will return you back to near your departure point.
    dreamwalk = {
        id = 193753,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.001,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TELEPORT_UNITS, 'subtype': NONE, 'amplitude': 1.0, 'value': 1378, 'schools': ['holy', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': QUEST_COMPLETE, 'subtype': NONE, 'value': 39174, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': KILL_CREDIT, 'subtype': NONE, 'value': 98305, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': KILL_CREDIT, 'subtype': NONE, 'value': 104608, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_CRIT_CHANCE_SCHOOL, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 293887, 'value': 193753, 'schools': ['physical', 'nature', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Grows a healing blossom at the target location, restoring $81269s1 health to $?p138284[four][three] injured allies within $81269A1 yards every $81262t1 sec for $81262d. Limit 1.
    efflorescence = {
        id = 145205,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.034,
        spendType = 'mana',

        talent = "efflorescence",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 47649, 'schools': ['physical', 'shadow'], 'value1': 3456, 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 6.0, 'value': 9049, 'schools': ['physical', 'nature', 'frost', 'arcane'], 'target': TARGET_DEST_DEST, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- disentanglement[233673] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Roots the target in place for $d. Damage may cancel the effect.$?s33891[; Tree of Life: Instant cast.][]
    entangling_roots = {
        id = 339,
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ROOT_2, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 1.5, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- cat_form[3025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- incarnation_tree_of_life[81097] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- natures_swiftness[132158] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[132158] #2: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'points': -100.0, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- natures_swiftness[132158] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- high_winds[200931] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- blooming_infusion[429474] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Release the natural power within G'Hanir to increase the frequency that all of your heal over time effects heal allies by ${100*(1/(1+($m1/100))-1)}% for $d.
    essence_of_ghanir = {
        id = 208253,
        color = 'artifact',
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.25, 'trigger_spell': 218889, 'points': -50.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Finishing move that causes Physical damage per combo point and consumes up to $?a102543[${$s2*(1+$102543s3/100)}][$s2] additional Energy to increase damage by up to 100%.;    1 point  : ${$m1*1/5} damage;    2 points: ${$m1*2/5} damage;    3 points: ${$m1*3/5} damage;    4 points: ${$m1*4/5} damage;    5 points: ${$m1*5/5} damage
    ferocious_bite = {
        id = 22568,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_amp': 0.7, 'ap_bonus': 1.45, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': POWER_BURN, 'subtype': NONE, 'points': 25.0, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 73.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- master_shapeshifter[289237] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- $?a114301[You descend on starry dust, slowing your falling speed.][You flap your wings, slowing your falling speed.]
    flap = {
        id = 164862,
        cast = 15.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': FEATHER_FALL, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': HOVER, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': WATER_WALK, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': SUPPRESS_TRANSFORMS, 'value1': 8, 'target': TARGET_UNIT_CASTER, }
    },

    -- Shapeshift into flight form, increasing movement speed and allowing you to fly. Cannot use in combat. ; The act of shapeshifting frees the caster of movement impairing effects.
    flight_form = {
        id = 165962,
        color = 'shapeshift',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.074,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'variance': 0.25, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- malornes_swiftness[236147] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Extends the duration of all of your heal over time effects on friendly targets within $A1 yards by $s1 sec, and increases the rate of your heal over time effects by ${100*(1/(1+($m2/100))-1)}% for $d.
    flourish = {
        id = 197721,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "flourish",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 6.0, 'radius': 60.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.25, 'trigger_spell': 218889, 'points': -50.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },

    -- Heals you for $o1% health over $d$?s301768[, and increases healing received by $301768s1%][].
    frenzied_regeneration = {
        id = 22842,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "global",

        spend = 100,
        spendType = 'rage',

        spendType = 'energy',

        talent = "frenzied_regeneration",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'attributes': ['Compute Points Only At Cast Time'], 'tick_time': 1.0, 'pvp_multiplier': 0.626, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'attributes': ['Compute Points Only At Cast Time'], 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': MOD_PET_TALENT_POINTS, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- restoration_druid[137012] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- restoration_druid[137012] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- heart_of_the_wild[319454] #8: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- verdant_heart[301768] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Summons a Treant which will immediately cast Swiftmend on your current target, healing for ${$422094m1}.  The Treant will cast Nourish on that target or a nearby ally periodically, healing for ${$422090m1}. Lasts $d.
    grove_guardians = {
        id = 102693,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "none",

        spend = 0.012,
        spendType = 'mana',

        talent = "grove_guardians",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 54983, 'schools': ['physical', 'holy', 'fire', 'arcane'], 'value1': 5734, 'target': TARGET_DEST_CASTER, }
    },

    -- Taunts the target to attack you.
    growl = {
        id = 6795,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ATTACK_ME, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_TAUNT, 'points': 400.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Abilities not associated with your specialization are substantially empowered for $d.$?!s137013[; Balance: Cast time of Balance spells reduced by $s13% and damage increased by $s1%.][]$?!s137011[; Feral: Gain $s14 Combo Point every $t14 sec while in Cat Form and Physical damage increased by $s4%.][]$?!s137010[; Guardian: Bear Form gives an additional $s7% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has ${$s9+1} charges.][]$?!s137012[; Restoration: Healing increased by $s10%, and mana costs reduced by $s12%.][]
    heart_of_the_wild = {
        id = 319454,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        talent = "heart_of_the_wild",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #11: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': -50.0, 'target': TARGET_UNIT_CASTER, }
        -- #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #13: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 2.0, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },

    -- Forces the enemy target to sleep for up to $d. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    hibernate = {
        id = 2637,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        talent = "hibernate",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- cat_form[768] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within $A1 yards for $d. Damage will cancel the effect.
    incapacitating_roar = {
        id = 99,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "incapacitating_roar",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'value': 1, 'schools': ['physical'], 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -50.0, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- An improved Cat Form that grants all of your known Berserk effects and lasts $d. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation:; Energy cost of all Cat Form abilities is reduced by $s3%, and Prowl can be used once while in combat.$?s343223[; Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $106951s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap.; All attack and ability damage is increased by $s4%.][]; 
    incarnation_avatar_of_ashamane = {
        id = 102543,
        color = 'shapeshift',
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.5, 'trigger_spell': 343216, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 252071, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Shapeshift into the Tree of Life, increasing healing done by $5420s1%, increasing armor by $5420s3%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, Entangling Roots, and Wrath is enhanced.; Lasts $117679d. You may shapeshift in and out of this form for its duration.
    incarnation_tree_of_life = {
        id = 33891,
        color = 'talent_shapeshift',
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "incarnation_tree_of_life",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'variance': 0.25, 'target': TARGET_UNIT_CASTER, 'form': tree_of_life_form, 'creature_type': humanoid, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 17, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 7.0, 'trigger_spell': 132213, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for $d.$?s326228[; If cast on somebody else, you gain the effect at $326228s1% effectiveness.][]
    innervate = {
        id = 29166,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        talent = "innervate",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': -100.0, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- cat_form[768] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Refreshes the duration of your active Lifebloom and Rejuvenation effects on the target and causes them to complete $s1% faster.
    invigorate = {
        id = 392160,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        spend = 0.004,
        spendType = 'mana',

        talent = "invigorate",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },

    -- The target's skin becomes as tough as Ironwood, reducing damage taken by $s1%$?a197061[ and increasing healing from your heal over time effects by $s2%][] for $d.$?a392116[; Allies protected by your Ironbark also receive $392116s1% of the healing from each of your active Rejuvenations.][]
    ironbark = {
        id = 102342,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "ironbark",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- improved_ironbark[382552] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- regenerative_heartwood[392116] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- stonebark[197061] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Increases armor by ${$s1*$AGI/100} for $d.$?a231070[ Multiple uses of this ability may overlap.][]
    ironfur = {
        id = 192081,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "none",

        spend = 400,
        spendType = 'rage',

        talent = "ironfur",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 112.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- heart_of_the_wild[319454] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- master_shapeshifter[289237] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ironfur[231070] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },

    -- Heals the target for $o1 over $d. When Lifebloom expires or is dispelled, the target is instantly healed for $33778s1.; May be active on $?s338831[two targets][one target] at a time.
    lifebloom = {
        id = 33763,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.016,
        spendType = 'mana',

        talent = "lifebloom",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 1.0, 'sp_bonus': 0.18, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- budding_leaves[392167] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.7, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- undergrowth[392301] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- undergrowth[392301] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- focused_growth[203553] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -8.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_dark_titans_lesson[338831] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_dark_titans_lesson[338831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point:;    1 point  : ${$s2*1} damage, 1 sec;    2 points: ${$s2*2} damage, 2 sec;    3 points: ${$s2*3} damage, 3 sec;    4 points: ${$s2*4} damage, 4 sec;    5 points: ${$s2*5} damage, 5 sec
    maim = {
        id = 22570,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        spend = 30,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        talent = "maim",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.16, 'variance': 0.05, 'radius': 5.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- master_shapeshifter[289237] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Mangle the target for $s2 Physical damage.$?a231064[ Deals $s3% additional damage against bleeding targets.][]; Generates ${$m4/10} Rage.
    mangle = {
        id = 33917,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.639, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'points': 120.0, 'target': TARGET_UNIT_CASTER, 'resource': rage, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- fluid_form[449193] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- instincts_of_the_claw[449184] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- primal_fury[159286] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Infuse a friendly target with the power of the wild, increasing their Versatility by $s1% for 60 minutes.; If target is in your party or raid, all party and raid members will be affected.; 
    mark_of_the_wild = {
        id = 1126,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_VERSATILITY, 'amplitude': 1.0, 'points': 3.0, 'radius': 100.0, 'target': TARGET_UNIT_TARGET_ALLY_OR_RAID, }
    },

    -- Roots the target and all enemies within $A1 yards in place for $d. Damage may interrupt the effect. Usable in all shapeshift forms.
    mass_entanglement = {
        id = 102359,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "mass_entanglement",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ROOT_2, 'radius': 12.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 0.5, 'radius': 12.0, 'target': TARGET_UNIT_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
    },

    -- Invokes the spirit of Ursoc to stun the target for $d. Usable in all shapeshift forms.
    mighty_bash = {
        id = 5211,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "mighty_bash",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'variance': 0.25, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- A quick beam of lunar light burns the enemy for $164812s1 Arcane damage and then an additional $164812o2 Arcane damage over $164812d$?s238049[, and causes enemies to deal $238049s1% less damage to you.][.]$?a372567[; Hits a second target within $279620s1 yds of the first.][]$?s197911[; Generates ${$m3/10} Astral Power.][] 
    moonfire = {
        id = 8921,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.04,
        spendType = 'mana',

        -- 0. [137012] restoration_druid
        -- spend = 0.012,
        -- spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': rage, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': astral_power, }

        -- Affected by:
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #10: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Shapeshift into $?s114301[Astral Form][Moonkin Form], increasing the damage of your spells by $s9% and your armor by $m3%, and granting protection from Polymorph effects.$?a231042[; While in this form, single-target attacks against you have a $h% chance to make your next Starfire instant.][]; The act of shapeshifting frees you from movement impairing effects.
    moonkin_form = {
        id = 24858,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 17, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'variance': 0.25, 'target': TARGET_UNIT_CASTER, 'form': moonkin_form, 'creature_type': none, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_BASE_RESISTANCE_PCT, 'points': 125.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_HEALTH_PERCENT, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 150.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102383, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_MELEE_CRIT_CHANCE, 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #10: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #11: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -3.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #12: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -6.0, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- feral_druid[137011] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- owlkin_frenzy[231042] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },

    -- Shapeshift into a mountable travel form, increasing movement speed by $5419s1%. Also protects the caster from Polymorph effects. Only usable outdoors.; The act of shapeshifting frees the caster of movement impairing effects.
    mount_form = {
        id = 210053,
        color = 'shapeshift',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'variance': 0.25, 'target': TARGET_UNIT_CASTER, 'form': travel_form, 'creature_type': beast, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 17, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'points': 120.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- malornes_swiftness[236147] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Cures harmful effects on the friendly target, removing all Magic$?s392378[, Curse, and Poison][] effects.
    natures_cure = {
        id = 88423,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.013,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': DISPEL, 'subtype': NONE, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- cat_form[768] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
    },

    -- Your next Regrowth, Rebirth, or Entangling Roots is instant, free, castable in all forms, and heals for an additional $s2%.
    natures_swiftness = {
        id = 132158,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        talent = "natures_swiftness",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'points': -100.0, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }

        -- Affected by:
        -- natures_splendor[392288] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- passing_seasons[382550] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -12000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- For $d, $?s137012[all single-target healing also damages a nearby enemy target for $s3% of the healing done][all single-target damage also heals a nearby friendly target for $s3% of the damage done].
    natures_vigil = {
        id = 124974,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "natures_vigil",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.5, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Heals a friendly target for $s1.  Receives $s2% bonus from $@spellname77495.
    nourish = {
        id = 50464,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.036,
        spendType = 'mana',

        talent = "nourish",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 2.23, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wild_synthesis[400534] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -33.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Apply Lifebloom, Rejuvenation, Wild Growth, and Regrowth's heal over time effect to an ally.
    overgrowth = {
        id = 203651,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.024,
        spendType = 'mana',

        talent = "overgrowth",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- astral_influence[197524] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Shift into Cat Form and enter stealth.
    prowl = {
        id = 5215,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STEALTH, 'points_per_level': 5.0, 'points': 85.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': -30.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 639, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], }

        -- Affected by:
        -- incarnation_avatar_of_ashamane[252071] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102547, 'target': TARGET_UNIT_CASTER, }
    },

    -- Allows the Druid to vanish from sight, entering an improved stealth mode.  Lasts until cancelled.
    prowl_102547 = {
        id = 102547,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STEALTH, 'points_per_level': 5.0, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': -30.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': SANCTUARY_2, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 35.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #5: { 'type': UNKNOWN, 'subtype': NONE, 'points': 252071.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- incarnation_avatar_of_ashamane[252071] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102547, 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- Rake the target for $s1 Bleed damage and an additional $155722o1 Bleed damage over $155722d.$?s48484[ Reduces the target's movement speed by $58180s1% for $58180d.][]$?a231052[ ; While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]$?a405834[ ; While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]; Awards $s2 combo $lpoint:points;.
    rake = {
        id = 1822,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'energy',

        talent = "rake",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.2154, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 155722, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 31.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- prowl[102547] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fluid_form[449193] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Returns the spirit to the body, restoring a dead target to life with $s2% health and at least $s1% mana. Castable in combat.
    rebirth = {
        id = 20484,
        cast = 2.0,
        cooldown = 600.0,
        gcd = "global",

        spend = 300,
        spendType = 'rage',

        spend = 0.020,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 20.0, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- cat_form[3025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- bear_form[5487] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- natures_swiftness[132158] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[132158] #2: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'points': -100.0, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- natures_swiftness[132158] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Heals a friendly target for $s1 and another ${$o2*$<mult>} over $d.$?s231032[ Initial heal has a $231032s1% increased chance for a critical effect if the target is already affected by Regrowth.][]$?s24858|s197625[ Usable while in Moonkin Form.][]$?s33891[; Tree of Life: Instant cast.][]
    regrowth = {
        id = 8936,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.1,
        spendType = 'mana',

        -- 0. [137012] restoration_druid
        -- spend = 0.028,
        -- spendType = 'mana',

        -- 1. [137013] balance_druid
        -- spend = 0.100,
        -- spendType = 'mana',

        -- 2. [137011] feral_druid
        -- spend = 0.100,
        -- spendType = 'mana',

        -- 3. [137010] guardian_druid
        -- spend = 0.100,
        -- spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 2.6988, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 2.0, 'sp_bonus': 0.0864, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[3025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- clearcasting[16870] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- clearcasting[16870] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[81097] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- groves_inspiration[429402] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- groves_inspiration[429402] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- harmonious_constitution[440116] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 35.0, 'target': TARGET_UNIT_CASTER, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- natures_swiftness[132158] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[132158] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- natures_swiftness[132158] #2: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'points': -100.0, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- natures_swiftness[132158] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rampant_growth[404521] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- thriving_vegetation[447131] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- abundance[207640] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -8.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- abundance[207640] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- balance_druid[137013] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 47.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- feral_druid[137011] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Heals the target for $o1 over $d.$?s155675[; You can apply Rejuvenation twice to the same target.][]$?s33891[; Tree of Life: Healing increased by $5420s5% and Mana cost reduced by $5420s4%.][]
    rejuvenation = {
        id = 774,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.05,
        spendType = 'mana',

        -- 0. [137012] restoration_druid
        -- spend = 0.022,
        -- spendType = 'mana',

        -- 1. [137013] balance_druid
        -- spend = 0.050,
        -- spendType = 'mana',

        -- 2. [137011] feral_druid
        -- spend = 0.050,
        -- spendType = 'mana',

        -- 3. [137010] guardian_druid
        -- spend = 0.050,
        -- spendType = 'mana',

        talent = "rejuvenation",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 3.0, 'sp_bonus': 0.2465, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 110.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_tree_of_life[5420] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bear_form[5487] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_rejuvenation[231040] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- lore_of_the_grove[449185] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- germination[155675] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- regenesis[383191] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }
        -- wildstalkers_power[439926] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- [2782] Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    remove_corruption = {
        id = 440015,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- cat_form[768] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
    },

    -- Instantly heals you for $s1% of maximum health. Usable in all shapeshift forms.
    renewal = {
        id = 108238,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "renewal",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL_PCT, 'subtype': NONE, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- bear_form[5487] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
    },

    -- Returns all dead party members to life with $s1% of maximum health and mana. Not castable in combat.
    revitalize = {
        id = 212040,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT_WITH_AURA, 'subtype': NONE, 'points': 35.0, 'radius': 100.0, 'target': TARGET_CORPSE_SRC_AREA_RAID, }
    },

    -- Returns the spirit to the body, restoring a dead target to life with $s1% of maximum health and mana. Not castable in combat.
    revive = {
        id = 50769,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 35.0, }

        -- Affected by:
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Finishing move that causes Bleed damage over time. Lasts longer per combo point.;    1 point  : ${$o1*2} over ${$d*2} sec;    2 points: ${$o1*3} over ${$d*3} sec;    3 points: ${$o1*4} over ${$d*4} sec;    4 points: ${$o1*5} over ${$d*5} sec;    5 points: ${$o1*6} over ${$d*6} sec
    rip = {
        id = 1079,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 20,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        talent = "rip",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'mechanic': bleeding, 'ap_bonus': 0.2512, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 84.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- master_shapeshifter[289237] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- master_shapeshifter[289237] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Shred the target, causing $s1 Physical damage to the target.$?a231063[ Deals $231063s2% increased damage against bleeding targets.][]$?a405300[ Deals $405300s1% increased damage against bleeding targets. Applies the Bleed from Thrash.][]$?a343232[; While stealthed, Shred deals $m3% increased damage, has double the chance to critically strike, and generates $343232s1 additional combo $lpoint:points;.][]$?a405834[; While stealthed, Shred deals $m3% increased damage, has double the chance to critically strike, and generates $343232s1 additional combo $lpoint:points;.][]; Awards $s2 combo $lpoint:points;.
    shred = {
        id = 5221,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.025, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 96.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fluid_form[449193] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for $93985d.
    skull_bash = {
        id = 106839,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        talent = "skull_bash",
        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- cat_form[3025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Soothes the target, dispelling all enrage effects.
    soothe = {
        id = 2908,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 0.011,
        spendType = 'mana',

        talent = "soothe",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 9, 'schools': ['physical', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- cat_form[768] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within $A1 yards by $s1% for $d.
    stampeding_roar = {
        id = 106898,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "stampeding_roar",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 60.0, 'radius': 15.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ALLY, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 1.0, 'radius': 15.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ALLY, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- improved_stampeding_roar[288826] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Call down a burst of energy, causing $s1 Arcane damage to the target, and ${$m1*$m2/100} Arcane damage to all other enemies within $A1 yards. Deals reduced damage beyond $s3 targets.
    starfire = {
        id = 197628,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        talent = "starfire",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.875, 'variance': 0.05, 'radius': 5.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 90.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonfire[164812] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- moonfire[164812] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- starlight_conduit[451211] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- groves_inspiration[429402] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lunar_calling[429523] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blooming_infusion[429474] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- blooming_infusion[429474] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Launch a surge of stellar energies at the target, dealing $s1 Astral damage.
    starsurge = {
        id = 197626,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        talent = "starsurge",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.77, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonfire[164812] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- moonfire[164812] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- sunfire[164815] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- sunfire[164815] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- heart_of_the_wild[319454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- starlight_conduit[451211] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- starlight_conduit[451211] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- starlight_conduit[451211] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Maul the target for $s2% of the target's maximum health in Physical damage.
    strength_of_the_wild = {
        id = 236716,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 3.0,
        gcd = "global",

        spend = 400,
        spendType = 'rage',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DAMAGE_FROM_MAX_HEALTH_PCT, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- A quick beam of solar light burns the enemy for $164815s1 Nature damage and then an additional $164815o2 Nature damage over $164815d$?s231050[ to the primary target and all enemies within $164815A2 yards][].$?s137013[; Generates ${$m3/10} Astral Power.][]
    sunfire = {
        id = 93402,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.018,
        spendType = 'mana',

        talent = "sunfire",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': astral_power, }
    },

    -- Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for $s1.$?a383192[; Swiftmend heals the target for $383193o1 over $383193d.][]
    swiftmend = {
        id = 18562,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.014,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 6.1824, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #4: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- groves_inspiration[429402] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- groves_inspiration[429402] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- prosperity[200383] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Instantly heal an ally for $s1.
    swiftmend_422094 = {
        id = 422094,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 1.36, 'variance': 0.05, 'radius': 40.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #4: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- groves_inspiration[429402] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- groves_inspiration[429402] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- balance_druid[137013] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "from_description",
    },

    -- Swipe nearby enemies, inflicting Physical damage. Damage varies by shapeshift form.$?s137011[; Awards $s1 combo $lpoint:points;.][]
    swipe = {
        id = 213764,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
    },

    -- Teleport to the Moonglade.; Casting Teleport: Moonglade while in Moonglade will return you back to near your departure point.
    teleport_moonglade = {
        id = 18960,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.000,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_CRIT_CHANCE_SCHOOL, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TELEPORT_UNITS, 'subtype': NONE, 'amplitude': 1.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #2: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 293840, 'value': 18960, 'schools': ['frost'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Sprout thorns for $d on the friendly target. When victim to melee attacks, thorns deals $305496s1 Nature damage back to the attacker.; Attackers also have their movement speed reduced by $232559s1% for $232559d.
    thorns = {
        id = 305497,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.036,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- $@spelldesc203727
    thorns_232559 = {
        id = 232559,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ANY, }
        from = "from_description",
    },

    -- [305497] Sprout thorns for $d on the friendly target. When victim to melee attacks, thorns deals $305496s1 Nature damage back to the attacker.; Attackers also have their movement speed reduced by $232559s1% for $232559d.
    thorns_305496 = {
        id = 305496,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.2, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- heart_of_the_wild[319454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "from_description",
    },

    -- Strikes all nearby enemies, dealing $s1 $?a429523[Arcane][Bleed] damage and an additional $192090o1 $?a429523[Arcane][Bleed] damage over $192090d. When applied from Bear Form, this effect can stack up to $192090u times.; Generates ${$m2/10} Rage.
    thrash = {
        id = 77758,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'mechanic': bleeding, 'ap_bonus': 0.092, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'resource': rage, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bear_form[5487] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- instincts_of_the_claw[449184] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lunar_calling[429523] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lunar_calling[429523] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #3: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 64, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Strikes all nearby enemies, dealing $m1 $?a429523[Arcane][Bleed] damage and an additional $405233o1 $?a429523[Arcane][Bleed] damage over $405233d.; Awards $s2 combo $lpoint:points;.
    thrash_106830 = {
        id = 106830,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'mechanic': bleeding, 'ap_bonus': 0.202, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- cat_form[768] #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lunar_calling[429523] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #3: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 64, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "class",
    },

    -- Shift into Cat Form and increase your movement speed by $s1%, reducing gradually over $d.
    tiger_dash = {
        id = 252216,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "tiger_dash",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 200.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.5, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- cat_form[768] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },

    -- Shows the location of all nearby beasts on the minimap.
    track_beasts = {
        id = 210065,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRACK_CREATURES, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Shows the location of all nearby humanoids on the minimap.
    track_humanoids = {
        id = 5225,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRACK_CREATURES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Heals all allies within $a2 yards for $<healing> over $d. Each heal heals the target for another $157982o2 over $157982d, stacking.; Healing decreased beyond $s3 targets.
    tranquility = {
        id = 740,
        cast = 8.0,
        channeled = true,
        cooldown = 180.0,
        gcd = "global",

        spend = 0.037,
        spendType = 'mana',

        talent = "tranquility",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 2.0, 'trigger_spell': 157982, 'triggers': tranquility, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': DUMMY, 'points': 1.0, 'radius': 40.0, 'target': TARGET_DEST_DYNOBJ_ALLY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'value': 2347, 'schools': ['physical', 'holy', 'nature', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- astral_influence[197524] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- inner_peace[197073] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- preserve_nature[353114] #1: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_MELEE_CRIT_DAMAGE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Shapeshift into a travel form appropriate to your current location, increasing movement speed on land, in water, or in the air, and granting protection from Polymorph effects.; The act of shapeshifting frees you from movement impairing effects.$?a159456[; Land speed increased when used out of combat. This effect is disabled in battlegrounds and arenas.][]
    travel_form = {
        id = 783,
        color = 'shapeshift',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- malornes_swiftness[236147] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Shapeshift into Treant Form.
    treant_form = {
        id = 114282,
        color = 'shapeshift',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'variance': 0.25, 'target': TARGET_UNIT_CASTER, 'form': treant_form, 'creature_type': humanoid, }
    },

    -- Blasts targets within $61391a1 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by $61391s3% for $61391d. Usable in all shapeshift forms.
    typhoon = {
        id = 132469,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "typhoon",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 61391, 'triggers': typhoon, 'points': 400.0, }

        -- Affected by:
        -- astral_influence[197524] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- high_winds[200931] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- high_winds[200931] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Conjures a vortex of wind for $d at the destination, reducing the movement speed of all enemies within $A1 yards by $s1%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    ursols_vortex = {
        id = 102793,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "ursols_vortex",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'mechanic': snared, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 314, 'schools': ['holy', 'nature', 'frost', 'shadow'], 'target': TARGET_DEST_DEST, }
    },

    -- Fly to a nearby ally's position.
    wild_charge = {
        id = 102401,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        talent = "wild_charge",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': JUMP_DEST, 'subtype': NONE, 'amplitude': 3.0, 'value1': 150, 'target': TARGET_DEST_TARGET_ANY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- cat_form[3025] #2: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 49376, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- aquatic_form_passive[5421] #2: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102416, 'target': TARGET_UNIT_CASTER, }
        -- bear_form_passive_2[21178] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 16979, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- travel_form_passive[5419] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102417, 'target': TARGET_UNIT_CASTER, }
        -- moonkin_form[24858] #6: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102383, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
    },

    -- Heals up to $s2 injured allies within $A1 yards of the target for $o1 over $d. Healing starts high and declines over the duration.$?s33891[; Tree of Life: Affects $33891s3 additional $ltarget:targets;.][]
    wild_growth = {
        id = 48438,
        cast = 1.5,
        cooldown = 10.0,
        gcd = "global",

        spend = 0.038,
        spendType = 'mana',

        spend = 0.150,
        spendType = 'mana',

        spend = 0.150,
        spendType = 'mana',

        spend = 0.150,
        spendType = 'mana',

        talent = "wild_growth",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 1.0, 'sp_bonus': 0.1344, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ANY, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- flourish[197721] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- groves_inspiration[429402] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- groves_inspiration[429402] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_wild_growth[328025] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- ironbark[102342] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- liveliness[426702] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- early_spring[203624] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Hurl a ball of energy at the target, dealing $s1 Nature damage.$?s33891[; Tree of Life: Damage increased by $5420s7% and instant cast.][]
    wrath = {
        id = 5176,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.04,
        spendType = 'mana',

        -- 0. [137010] guardian_druid
        -- spend = 0.002,
        -- spendType = 'mana',

        -- 2. [137013] balance_druid
        -- spend = 0.002,
        -- spendType = 'mana',

        -- 3. [137011] feral_druid
        -- spend = 0.002,
        -- spendType = 'mana',

        -- 4. [137012] restoration_druid
        -- spend = 0.002,
        -- spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.5775, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 90.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- sunfire[164815] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- sunfire[164815] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- starlight_conduit[451211] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- groves_inspiration[429402] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- liveliness[426702] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blooming_infusion[429474] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- blooming_infusion[429474] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

} )