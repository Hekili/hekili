-- DruidFeral.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 103 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.LunarPower )

spec:RegisterTalents( {
    -- Druid Talents
    astral_influence               = { 82210, 197524, 1 }, -- Increases the range of all of your spells by $s1 yards.
    cyclone                        = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to $d. Only one target can be affected by your Cyclone at a time.
    feline_swiftness               = { 82239, 131768, 1 }, -- Increases your movement speed by $s1%.
    fluid_form                     = { 92229, 449193, 1 }, -- Shred and Rake can be used in any form and shift you into Cat Form. ; Mangle can be used in any form and shifts you into Bear Form. ; Wrath and Starfire shift you into Moonkin Form, if known.
    forestwalk                     = { 100173, 400129, 1 }, -- Casting Regrowth increases your movement speed and healing received by $400126s1% for $400126d.
    frenzied_regeneration          = { 82220, 22842 , 1 }, -- Heals you for $o1% health over $d$?s301768[, and increases healing received by $301768s1%][].
    heart_of_the_wild              = { 82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for $d.$?!s137013[; Balance: Cast time of Balance spells reduced by $s13% and damage increased by $s1%.][]$?!s137011[; Feral: Gain $s14 Combo Point every $t14 sec while in Cat Form and Physical damage increased by $s4%.][]$?!s137010[; Guardian: Bear Form gives an additional $s7% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has ${$s9+1} charges.][]$?!s137012[; Restoration: Healing increased by $s10%, and mana costs reduced by $s12%.][]
    hibernate                      = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to $d. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin              = { 82219, 327993, 1 }, -- Barkskin's duration is increased by ${$s1/1000} sec.
    improved_rejuvenation          = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by ${$m1/1000} sec.
    improved_stampeding_roar       = { 82230, 288826, 1 }, -- Cooldown reduced by ${$m1/-1000} sec.
    improved_sunfire               = { 93714, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within $164815A2 yards.
    incapacitating_roar            = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within $A1 yards for $d. Damage will cancel the effect.
    innervate                      = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for $d.$?s326228[; If cast on somebody else, you gain the effect at $326228s1% effectiveness.][]
    instincts_of_the_claw          = { 100176, 449184, 2 }, -- Shred, $?s202028[Brutal Slash][Swipe], Rake, Mangle, and Thrash damage increased by $s1%.
    ironfur                        = { 82227, 192081, 1 }, -- Increases armor by ${$s1*$AGI/100} for $d.$?a231070[ Multiple uses of this ability may overlap.][]
    killer_instinct                = { 82225, 108299, 2 }, -- Physical damage and Armor increased by $s1%.
    lore_of_the_grove              = { 100175, 449185, 2 }, -- Moonfire and Sunfire damage increased by $s1%. Rejuvenation and Wild Growth healing increased by $s3%.
    lycaras_teachings              = { 82233, 378988, 2 }, -- You gain $s1% of a stat while in each form:; No Form: Haste; Cat Form: Critical Strike; Bear Form: Versatility; Moonkin Form: Mastery
    maim                           = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point:;    1 point  : ${$s2*1} damage, 1 sec;    2 points: ${$s2*2} damage, 2 sec;    3 points: ${$s2*3} damage, 3 sec;    4 points: ${$s2*4} damage, 4 sec;    5 points: ${$s2*5} damage, 5 sec
    mass_entanglement              = { 82242, 102359, 1 }, -- Roots the target and all enemies within $A1 yards in place for $d. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                     = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb $<shield> damage for $280165d.
    mighty_bash                    = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for $d. Usable in all shapeshift forms.
    natural_recovery               = { 82206, 377796, 1 }, -- Healing you receive is increased by $s1%.
    natures_vigil                  = { 82244, 124974, 1 }, -- For $d, $?s137012[all single-target healing also damages a nearby enemy target for $s3% of the healing done][all single-target damage also heals a nearby friendly target for $s3% of the damage done].
    nurturing_instinct             = { 82214, 33873 , 2 }, -- Magical damage and healing increased by $s1%.
    oakskin                        = { 100174, 449191, 1 }, -- Survival Instincts and Barkskin reduce damage taken by an additional $s1%.
    primal_fury                    = { 82238, 159286, 1 }, -- While in Cat Form, when you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect.; Mangle critical strike damage increased by $s2%.
    rake                           = { 82199, 1822  , 1 }, -- Rake the target for $s1 Bleed damage and an additional $155722o1 Bleed damage over $155722d.$?s48484[ Reduces the target's movement speed by $58180s1% for $58180d.][]$?a231052[ ; While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]$?a405834[ ; While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]; Awards $s2 combo $lpoint:points;.
    rejuvenation                   = { 82217, 774   , 1 }, -- Heals the target for $o1 over $d.$?s155675[; You can apply Rejuvenation twice to the same target.][]$?s33891[; Tree of Life: Healing increased by $5420s5% and Mana cost reduced by $5420s4%.][]
    renewal                        = { 82232, 108238, 1 }, -- Instantly heals you for $s1% of maximum health. Usable in all shapeshift forms.
    rip                            = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point.;    1 point  : ${$o1*2} over ${$d*2} sec;    2 points: ${$o1*3} over ${$d*3} sec;    3 points: ${$o1*4} over ${$d*4} sec;    4 points: ${$o1*5} over ${$d*5} sec;    5 points: ${$o1*6} over ${$d*6} sec
    rising_light_falling_night     = { 82207, 417712, 1 }, -- Increases your damage and healing by $417714s1% during the day.; Increases your Versatility by $417715s1% during the night.
    skull_bash                     = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for $93985d.
    soothe                         = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar                = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within $A1 yards by $s1% for $d.
    starlight_conduit              = { 100223, 451211, 1 }, -- Wrath, Starsurge, and Starfire damage increased by $s1%. $?!a137013[; Starsurge's cooldown is reduced by ${-$s2/1000} sec and its mana cost is reduced by $s3%.][]
    sunfire                        = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for $164815s1 Nature damage and then an additional $164815o2 Nature damage over $164815d$?s231050[ to the primary target and all enemies within $164815A2 yards][].$?s137013[; Generates ${$m3/10} Astral Power.][]
    thick_hide                     = { 82228, 16931 , 1 }, -- Reduces all damage taken by $s1%.
    thrash                         = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                     = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by $s1%, reducing gradually over $d.
    typhoon                        = { 82209, 132469, 1 }, -- Blasts targets within $61391a1 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by $61391s3% for $61391d. Usable in all shapeshift forms.
    ursine_vigor                   = { 82235, 377842, 1 }, -- For $340541d after shifting into Bear Form, your health and armor are increased by $s1%.
    ursocs_spirit                  = { 100177, 449182, 1 }, -- Stamina in Bear Form is increased by $s1%.
    ursols_vortex                  = { 82242, 102793, 1 }, -- Conjures a vortex of wind for $d at the destination, reducing the movement speed of all enemies within $A1 yards by $s1%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart                  = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by $s1%.
    wellhoned_instincts            = { 82246, 377847, 1 }, -- When you fall below $s2% health, you cast Frenzied Regeneration, up to once every $s1 sec.
    wild_charge                    = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                    = { 82241, 48438 , 1 }, -- Heals up to $s2 injured allies within $A1 yards of the target for $o1 over $d. Healing starts high and declines over the duration.$?s33891[; Tree of Life: Affects $33891s3 additional $ltarget:targets;.][]

    -- Feral Talents
    adaptive_swarm                 = { 82112, 391888, 1 }, -- Command a swarm that heals $391891o1 or deals $391889o1 Nature damage over $391889d to a target, and increases the effectiveness of your periodic effects on them by $391891s2%.; Upon expiration, finds a new target, preferring to alternate between friend and foe up to $s1 times.
    aggravate_wounds               = { 94616, 441829, 1 }, -- Every $?a137010[Maul, Raze, Mangle,  Thrash, or Swipe]$?a137011[attack with an Energy cost that] you cast extends the duration of your Dreadful Wounds by $?a137010[${$s1/1000}.1][${$s2/1000}.1] sec, up to $s3 additional sec.
    apex_predators_craving         = { 82092, 391881, 1 }, -- Rip damage has a ${$s1/10}.1% chance to make your next Ferocious Bite free and deal the maximum damage.
    ashamanes_guidance             = { 82113, 391548, 1 }, -- $@spellicon102543$@spellname102543; During Incarnation: Avatar of Ashamane and for $421440s1 sec after it ends, your Rip and Rake each cause affected enemies to take $421442s1% increased damage from your abilities.; $@spellicon391528 $@spellname391528; Convoke the Spirits' cooldown is reduced by ${($abs($391538s4)/120000)*100}% and its duration and number of spells cast is reduced by $391538s1%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    berserk                        = { 82101, 106951, 1 }, -- [106951] Go Berserk for $d. While Berserk:; Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap.; All attack and ability damage is increased by $s3%.
    berserk_frenzy                 = { 82090, 384668, 1 }, -- During $?s102543[Incarnation: Avatar of Ashamane][Berserk] your combo point-generating abilities bleed the target for an additional $s1% of their direct damage over $391140d.
    berserk_heart_of_the_lion      = { 82105, 391174, 1 }, -- Reduces the cooldown of $?s102543[Incarnation: Avatar of Ashamane][Berserk] by ${$s1/-1000} sec.
    bestial_strength               = { 94611, 441841, 1 }, -- $?a137011[Ferocious Bite damage increased by $s1% and Primal Wrath's direct damage increased by $s2%.][Maul and Raze damage increased by $s3%.]
    bloodtalons                    = { 82109, 319439, 1 }, -- When you use $s2 different combo point-generating abilities within $s1 sec, the damage of your next $145152n Rips or Ferocious Bites is increased by $145152s1% for their full duration.
    bond_with_nature               = { 94625, 439929, 1 }, -- Healing you receive is increased by $s1%.
    brutal_slash                   = { 82091, 202028, 1 }, -- Strikes all nearby enemies with a massive slash, inflicting $s2 Physical damage.$?a231063[ Deals $231063s1% increased damage against bleeding targets.][]$?a405300[ Applies the Bleed from Thrash.][] Deals reduced damage beyond $s3 targets.$?a5487[][; Awards $s1 combo $lpoint:points;.]
    bursting_growth                = { 94630, 440120, 1 }, -- When Bloodseeker Vines expire or you use Ferocious Bite on their target they explode in thorns, dealing $440122s1 physical damage to nearby enemies. Damage reduced above 5 targets.; When Symbiotic Blooms expire or you cast Rejuvenation on their target flowers grow around their target, healing them and up to $440121s2 nearby allies for $440121s1.
    carnivorous_instinct           = { 82110, 390902, 2 }, -- Tiger's Fury's damage bonus is increased by $s1%.
    circle_of_life_and_death       = { 82095, 400320, 1 }, -- Your damage over time effects deal their damage in $s1% less time, and your healing over time effects in $s2% less time.
    claw_rampage                   = { 94613, 441835, 1 }, -- During Berserk, $?a137010[Mangle][Shred], $?s202028[Brutal Slash][Swipe], and Thrash have a $h% chance to make your next $?a137010[Maul][Ferocious Bite] become Ravage.
    coiled_to_spring               = { 82085, 449537, 1 }, -- If you generate a combo point in excess of what you can store, your next Ferocious Bite or Primal Wrath deals $449538s1% increased direct damage.
    convoke_the_spirits            = { 82114, 391528, 1 }, -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of $s2 Druid spells and abilities over $d.$?s391538[ Chance to use an exceptional spell or ability is increased.][]; You will cast $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    doubleclawed_rake              = { 82086, 391700, 1 }, -- Rake also applies Rake to $s1 additional nearby $Ltarget:targets;.
    dreadful_bleeding              = { 82117, 391045, 1 }, -- Rip damage increased by $s1%.
    dreadful_wound                 = { 94620, 441809, 1 }, -- Ravage also inflicts a Bleed that causes $?a137011[$441812s1][$451177s1] damage over $441812d and saps its victims' strength, reducing damage they deal to you by $?a137011[$441812s2][$451177s2]%.; Dreadful Wound is not affected by Circle of Life and Death. $?a137011[If a Dreadful Wound benefiting from Tiger's Fury is re-applied, the new Dreadful Wound deals damage as if Tiger's Fury was active.][]
    empowered_shapeshifting        = { 94612, 441689, 1 }, -- Frenzied Regeneration can be cast in Cat Form for $s2 Energy.; Bear Form reduces magic damage you take by ${-$s4}%.; Shred and $?s202028[Brutal Slash][Swipe] damage increased by $s5%. Mangle damage increased by $s6%.
    entangling_vortex              = { 94622, 439895, 1 }, -- Enemies pulled into Ursol's Vortex are rooted in place for ${$s1/1000} sec. Damage may cancel the effect.
    feral_frenzy                   = { 82108, 274837, 1 }, -- Unleash a furious frenzy, clawing your target $m2 times for ${$274838s1*$m2} Physical damage and an additional ${$m2*$274838s3*$274838d/$274838t3} Bleed damage over $274838d.; Awards $s1 combo points.
    flower_walk                    = { 94622, 439901, 1 }, -- During Barkskin your movement speed is increased by $s1% and every second flowers grow beneath your feet that heal up to $439902s2 nearby injured allies for $439902s1.
    fount_of_strength              = { 94618, 441675, 1 }, -- Your maximum Energy and Rage are increased by $s1.; Frenzied Regeneration also increases your maximum health by $s3%.
    frantic_momentum               = { 82115, 391875, 2 }, -- Finishing moves have a $s1% chance per combo point spent to grant $391876s1% Haste for $391876d.
    harmonious_constitution        = { 94625, 440116, 1 }, -- Your Regrowth's healing to yourself is increased by $s1%.
    hunt_beneath_the_open_skies    = { 94629, 439868, 1 }, -- Damage and healing while in Cat Form increased by $s1%.; Moonfire and Sunfire damage increased by $s4%.
    implant                        = { 94628, 440118, 1 }, -- $?a137011[When you gain or lose Tiger's Fury, your next single-target melee ability causes a Bloodseeker Vine to grow on the target for ${$s1/1000} sec.][Your Swiftmend causes a Symbiotic Bloom to grow on the target for ${$s2/1000} sec.]
    incarnation_avatar_of_ashamane = { 82114, 102543, 1 }, -- An improved Cat Form that grants all of your known Berserk effects and lasts $d. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation:; Energy cost of all Cat Form abilities is reduced by $s3%, and Prowl can be used once while in combat.$?s343223[; Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $106951s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap.; All attack and ability damage is increased by $s4%.][]; 
    infected_wounds                = { 82118, 48484 , 1 }, -- Rake damage increased by $s2%, and Rake causes an Infected Wound in the target, reducing the target's movement speed by $58180s1% for $58180d.
    killing_strikes                = { 94619, 441824, 1 }, -- Ravage increases your Agility by $441825s1% and the armor granted by Ironfur by $441825s2% for $441825d.; Your first $?a137011[Tiger's Fury][Mangle] after entering combat makes your next $?a137011[Ferocious Bite][Maul] become Ravage.
    lethal_preservation            = { 94624, 455461, 1 }, -- When you remove an effect with Soothe or $?s88423[Nature's Cure][Remove Corruption], gain a combo point and heal for $s1% of your maximum health. If you are at full health an injured party or raid member will be healed instead.
    lions_strength                 = { 82109, 391972, 1 }, -- Ferocious Bite and Rip deal $s1% increased damage.
    lunar_inspiration              = { 92641, 155580, 1 }, -- Moonfire is usable in Cat Form, costs $155625c energy, and generates $155625s3 combo $lpoint:points;.
    merciless_claws                = { 82098, 231063, 1 }, -- Shred deals $s2% increased damage and $?s202028[Brutal Slash][Swipe] deals $s1% increased damage against bleeding targets.
    moment_of_clarity              = { 82100, 236068, 1 }, -- Omen of Clarity now triggers $s2% more often, can accumulate up to ${$s135700u+$s1} charges, and increases the damage of your next Shred, Thrash, or $?s202028[Brutal Slash][Swipe] by an additional $s4%.
    moonkin_form                   = { 91047, 197625, 1 }, -- Shapeshift into $?s114301[Astral Form][Moonkin Form], increasing the damage of your spells by $s7% and your armor by $m3%, and granting protection from Polymorph effects.; The act of shapeshifting frees you from movement impairing effects.
    omen_of_clarity                = { 82123, 16864 , 1 }, -- Your auto attacks have a $?s236068[high ][]chance to cause a Clearcasting state, making your next Shred, Thrash, or $?s202028[Brutal Slash][Swipe] cost no Energy$?s236068[ and deal $236068s4% more damage][].$?s236068[; Clearcasting can accumulate up to ${$s135700u+$236068s1} charges.][] 
    packs_endurance                = { 94615, 441844, 1 }, -- Stampeding Roar's duration is increased by $s1%.
    pouncing_strikes               = { 82119, 390772, 1 }, -- While stealthed, Rake will also stun the target for $163505d, and deal $1822s4% increased damage for its full duration.; While stealthed, Shred deals $5221s3% increased damage, has double the chance to critically strike, and generates $343232s1 additional combo $lpoint:points;.
    predator                       = { 82122, 202021, 1 }, -- Tiger's Fury lasts ${$s1/1000} additional seconds.; Your combo point-generating abilities' direct damage is increased by $449864s2% of your Haste.
    predatory_swiftness            = { 82106, 16974 , 1 }, -- Your finishing moves have a $s3% chance per combo point to make your next Regrowth or Entangling Roots instant, free, and castable in all forms.
    primal_wrath                   = { 82120, 285381, 1 }, -- Finishing move that deals instant damage and applies Rip to all enemies within $A1 yards. Lasts longer per combo point.;    1 point  : ${$s1*2} plus Rip for ${$s2*2} sec;    2 points: ${$s1*3} plus Rip for ${$s2*3} sec;    3 points: ${$s1*4} plus Rip for ${$s2*4} sec;    4 points: ${$s1*5} plus Rip for ${$s2*5} sec;    5 points: ${$s1*6} plus Rip for ${$s2*6} sec
    raging_fury                    = { 82107, 391078, 1 }, -- Tiger's Fury lasts ${$s1/1000} additional seconds.
    rampant_ferocity               = { 82103, 391709, 1 }, -- Ferocious Bite also deals $391710s1 damage per combo point spent to all nearby enemies affect by your Rip. Spending extra Energy on Ferocious Bite increases damage dealt by up to $s2%. Damage reduced beyond $s1 $Ltarget:targets;.
    ravage                         = { 94609, 441583, 1 }, -- [441605] Slash through your target in a wide arc, dealing $s1 Physical damage to your target and $s2 to all other enemies in front of you.
    remove_corruption              = { 82204, 2782  , 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    resilient_flourishing          = { 94631, 439880, 1 }, -- Bloodseeker Vines and Symbiotic Blooms last ${$s1/1000} additional sec.; When a target afflicted by Bloodseeker Vines dies, the vines jump to a valid nearby target for their remaining duration.
    rip_and_tear                   = { 82093, 391347, 1 }, -- Applying Rip to a target also applies a Tear that deals $s1% of the new Rip's damage over $391356d.
    root_network                   = { 94631, 439882, 1 }, -- Each active Bloodseeker Vine increases the damage your abilities deal by 2%.; Each active Symbiotic Bloom increases the healing of your spells by 2%.
    ruthless_aggression            = { 94619, 441814, 1 }, -- Ravage increases your auto-attack speed by $441817s1% for $441817d.
    saber_jaws                     = { 82094, 421432, 2 }, -- When you spend extra Energy on Ferocious Bite, the extra damage is increased by $s1%.; ; 
    sabertooth                     = { 82102, 202031, 1 }, -- Ferocious Bite deals $s1% increased damage.; For each Combo Point spent, Ferocious Bite's primary target takes $s2% increased damage from your Cat Form bleed and other periodic abilities for $391722d.
    savage_fury                    = { 82099, 449645, 1 }, -- Tiger's Fury increases your Haste by $449646s1% and Energy recovery rate by $449646s2% for $449646d.
    soul_of_the_forest             = { 82096, 158476, 1 }, -- Your finishing moves grant $s1 Energy per combo point spent and deal $s2% increased damage.
    starfire                       = { 91046, 197628, 1 }, -- Call down a burst of energy, causing $s1 Arcane damage to the target, and ${$m1*$m2/100} Arcane damage to all other enemies within $A1 yards. Deals reduced damage beyond $s3 targets.
    starsurge                      = { 82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing $s1 Astral damage.
    strategic_infusion             = { 94623, 439890, 1 }, -- $?a137011[Tiger's Fury and attacking][Attacking] from Prowl increases the chance for Shred, Rake, and $?s202028[Brutal Slash][Swipe] to critically strike by $439891s1% for $439891d.; Casting Regrowth increases the chance for your periodic heals to critically heal by $439893s1% for $439893d.
    strike_for_the_heart           = { 94614, 441845, 1 }, -- Shred, $?s202028[Brutal Slash][Swipe], and Mangle's critical strike chance and critical strike damage are increased by $s1%.; $?a137010[Mangle heals you for $458724s1% of maximum health.][]
    sudden_ambush                  = { 82104, 384667, 1 }, -- Finishing moves have a $s1% chance per combo point spent to make your next Rake or Shred deal damage as though you were stealthed. 
    survival_instincts             = { 82116, 61336 , 1 }, -- Reduces all damage you take by $50322s1% for $50322d.
    taste_for_blood                = { 82088, 384665, 1 }, -- Ferocious Bite deals $s1% increased damage and an additional $s2% during Tiger's Fury.; 
    tear_down_the_mighty           = { 94614, 441846, 1 }, -- The cooldown of $?a137011[Feral Frenzy][Pulverize] is reduced by ${$s1/-1000} sec.
    thrashing_claws                = { 82098, 405300, 1 }, -- Shred deals $s1% increased damage against bleeding targets and Shred and $?s202028[Brutal Slash][Swipe] apply the Bleed damage over time from Thrash, if known.
    thriving_growth                = { 94626, 439528, 1 }, -- Rip and Rake damage has a chance to cause Bloodseeker Vines to grow on the victim, dealing $439531o1 Bleed damage over $439531d.; $?a137011[Wild Growth and Regrowth][Wild Growth, Regrowth, and Efflorescence] healing has a chance to cause Symbiotic Blooms to grow on the target, healing for $439530o1 over $439530d.; Multiple instances of these can overlap.
    tigers_fury                    = { 82124, 5217  , 1 }, -- Instantly restores $s2 Energy, and increases the damage of all your attacks by $s1% for their full duration. Lasts $d.
    tigers_tenacity                = { 82107, 391872, 1 }, -- Tiger's Fury causes your next $391873n finishing $Lmove:moves; to restore $391874s1 combo $Lpoint:points;.; Tiger's Fury's also increases the periodic damage of your bleeds $?a155580[and Moonfire ][]by an additional $s3% for their full duration.
    tireless_energy                = { 82121, 383352, 2 }, -- Maximum Energy increased by $s1 and Energy regeneration increased by $s2%.
    twin_sprouts                   = { 94628, 440117, 1 }, -- When Bloodseeker Vines or Symbiotic Blooms grow, they have a $s1% chance to cause another growth of the same type to immediately grow on a valid nearby target.
    unbridled_swarm                = { 82111, 391951, 1 }, -- Adaptive Swarm has a $s1% chance to split into two Swarms each time it jumps.
    veinripper                     = { 82093, 391978, 1 }, -- Rip, Rake, and Thrash last $s1% longer.
    vigorous_creepers              = { 94627, 440119, 1 }, -- Bloodseeker Vines increase the damage your abilities deal to affected enemies by $s1%.; Symbiotic Blooms increase the healing your spells do to affected targets by $s2%.
    wild_slashes                   = { 82091, 390864, 1 }, -- Swipe and Thrash damage is increased by $s1%.
    wildpower_surge                = { 94612, 441691, 1 }, -- $?s202028[Shred and Brutal Slash]?a137011[Shred and Swipe][]$?a137011[ grant Ursine Potential. When you have $441695s1 stacks, the next time you transform into Bear Form, your next Mangle deals $441698s1% increased damage or your next Swipe deals $441698s2% increased damage. Either generates ${$442562s1/10} extra Rage.][Mangle grants Feline Potential. When you have $441701s1 stacks, the next time you transform into Cat Form, gain $441704s1 combo points and your next Ferocious Bite or Rip deals $441702s1% increased damage for its full duration.]
    wildshape_mastery              = { 94610, 441678, 1 }, -- Ironfur and Frenzied Regeneration persist in Cat Form.; When transforming from Bear to Cat Form, you retain $441685s1% of your Bear Form armor and health for $441685d.; For $441686d after entering Bear Form, you heal for $441686s1% of damage taken over $441688d. 
    wildstalkers_power             = { 94621, 439926, 1 }, -- Rip and Ferocious Bite damage increased by $s1%.; Rejuvenation$?a137012[, Efflorescence, and Lifebloom][] healing increased by $s3%.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    ferocious_wound      = 611 , -- (236020) Attacking with a $m2 combo point Ferocious Bite reduces the target's maximum health by up to $236021m1% for $236021d, stacking up to $236021u times. Ferocious Wound can only be active on one target at once.
    freedom_of_the_herd  = 203 , -- (213200) Your Stampeding Roar clears all roots and snares from yourself and allies.
    fresh_wound          = 612 , -- (203224) Rake has a $m1% increased critical strike chance if used on a target that doesnâ€™t already have Rake active.
    high_winds           = 5384, -- (200931) Increases the range of Cyclone, Typhoon, and Entangling Roots by $s1 yds.
    king_of_the_jungle   = 602 , -- (203052) For every enemy you have Rip active on, your movement speed and healing received is increased by $203059s1%. Stacks $203059u times.
    leader_of_the_pack   = 3751, -- (202626) While in Cat Form, you increase the movement speed of raid members within $m3 yards by $202636m1%.; Leader of the Pack also causes allies to heal themselves for $289241m1% of their maximum health when they critically hit with a direct attack. The healing effect cannot occur more than once every $m2 sec.
    malornes_swiftness   = 601 , -- (236012) Your Travel Form movement speed while within a Battleground or Arena is increased by $m2% and you always move at $m1% movement speed while in Travel Form.
    savage_momentum      = 820 , -- (205673) Interrupting a spell with Skull Bash reduces the remaining cooldown of Tiger's Fury, Survival Instincts, and $?s252216[Tiger Dash][Dash] by $s1 sec.
    strength_of_the_wild = 3053, -- (236019) [236716] Maul the target for $s2% of the target's maximum health in Physical damage.
    thorns               = 201 , -- (305497) Sprout thorns for $d on the friendly target. When victim to melee attacks, thorns deals $305496s1 Nature damage back to the attacker.; Attackers also have their movement speed reduced by $232559s1% for $232559d.
    tireless_pursuit     = 5647, -- (377801) For ${$s1/1000} sec after leaving Cat Form or Travel Form, you retain up to $s2% movement speed.
    wicked_claws         = 620 , -- (203242) Infected Wounds can now stack up to ${$s1+1} times, and reduces $s2% of all healing received by the target per stack.; Infected Wounds can now also be applied from Rip.
} )

-- Auras
spec:RegisterAuras( {
    -- Restoring $w1 health every $t1 sec and healing over time from $@auracaster increased by $w2%.
    adaptive_swarm = {
        id = 391891,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- circle_of_life_and_death[400320] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #15: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Your next Ferocious Bite costs no Energy or combo points and deals the maximum damage.
    apex_predators_craving = {
        id = 391882,
        duration = 15.0,
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
    -- Your Rip and Rake each cause affected enemies to take $s1% increased damage from your abilities.
    ashamanes_guidance = {
        id = 421442,
        duration = 3600,
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
        -- guardian_druid[137010] #14: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

        -- Affected by:
        -- berserk_heart_of_the_lion[391174] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Bleeding for $w1 damage every $t1 sec.
    bloodseeker_vines = {
        id = 439531,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- resilient_flourishing[439880] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vigorous_creepers[440119] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Your next Rip or Ferocious Bite deals $s1% increased damage.
    bloodtalons = {
        id = 145152,
        duration = 30.0,
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
    -- Heals $w1 damage every $t1 seconds.
    cenarion_ward = {
        id = 102352,
        duration = 8.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bear_form[5487] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- essence_of_ghanir[208253] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- adaptive_swarm[325748] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391891] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Charmed.
    charm_woodland_creature = {
        id = 127757,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Your next Shred, Thrash, or $?s202028[Brutal Slash][Swipe] costs no Energy$?s236068[ and deals $s3% increased damage][].
    clearcasting = {
        id = 135700,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- moment_of_clarity[236068] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- moment_of_clarity[236068] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Your next Ferocious Bite or Primal Wrath deals $s1% increased direct damage.
    coiled_to_spring = {
        id = 449538,
        duration = 15.0,
        max_stack = 1,
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
    -- Bleeding for $w1 damage every $t1 seconds. Weakened, dealing $w2% less damage to $@auracaster.
    dreadful_wound = {
        id = 451177,
        duration = 6.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Restores health to three injured allies within $81269A1 yards every $81262t1 sec for $81262d.
    efflorescence = {
        id = 81262,
        duration = 30.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Incapacitated.
    enraged_maim = {
        id = 236025,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- soul_of_the_forest[158476] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Rooted.$?<$w2>0>[ Suffering $w2 Nature damage every $t2 sec.][]
    entangling_roots = {
        id = 339,
        duration = 30.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- cat_form[3025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- incarnation_tree_of_life[81097] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- high_winds[200931] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
    },
    -- Heal over time spells are healing ${100*(1/(1+($m1/100))-1)}% faster.
    essence_of_ghanir = {
        id = 208253,
        duration = 8.0,
        max_stack = 1,
    },
    -- Bleeding for $w2 damage every $t2 sec.
    feral_frenzy = {
        id = 274838,
        duration = 6.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tear_down_the_mighty[441846] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- predator[449864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
    },
    -- Maximum health reduced by $w1%.
    ferocious_wound = {
        id = 236021,
        duration = 30.0,
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
        -- malornes_swiftness[236012] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Increases speed and all healing taken by $w1%.
    forestwalk = {
        id = 400126,
        duration = 6.0,
        max_stack = 1,
    },
    -- Haste increased by $s1%.
    frantic_momentum = {
        id = 391876,
        duration = 6.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 damage every $t sec.
    frenzied_assault = {
        id = 391140,
        duration = 8.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Healing $w1% health every $t1 sec.
    frenzied_regeneration = {
        id = 22842,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- heart_of_the_wild[319454] #8: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- verdant_heart[301768] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- empowered_shapeshifting[441689] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- empowered_shapeshifting[441689] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- adaptive_swarm[325748] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391891] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- guardian_druid[137010] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- guardian_druid[137010] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- restoration_druid[137012] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- restoration_druid[137012] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
        -- berserk_heart_of_the_lion[391174] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Movement speed slowed by $w1%.$?e1[ Healing taken reduced by $w2%.][]
    infected_wounds = {
        id = 58180,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- wicked_claws[203242] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- wicked_claws[203242] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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
    -- Armor increased by ${$w1*$AGI/100}.
    ironfur = {
        id = 192081,
        duration = 7.0,
        max_stack = 1,

        -- Affected by:
        -- heart_of_the_wild[319454] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- killing_strikes[441825] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ironfur[231070] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Agility increased by $w1% and armor granted by Ironfur increased by $w2%.
    killing_strikes = {
        id = 441825,
        duration = 8.0,
        max_stack = 1,
    },
    -- Increases movement speed by $w1%.; Healing received increased by $w2%.
    king_of_the_jungle = {
        id = 203059,
        duration = 24.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.; When you hit with a melee or ranged critical strike, you heal for $289241m1% of your maximum health. This effect cannot occur more than once every $m2 sec.
    leader_of_the_pack = {
        id = 202636,
        duration = 3600,
        max_stack = 1,
    },
    -- Incapacitated.
    maim = {
        id = 203126,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- soul_of_the_forest[158476] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

        -- Affected by:
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
    },
    -- Absorbs $w1 damage.
    matted_fur = {
        id = 385787,
        duration = 8.0,
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
    -- Suffering $w1 Arcane damage every $t1 sec.
    moonfire = {
        id = 155625,
        duration = 18.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- hunt_beneath_the_open_skies[439868] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hunt_beneath_the_open_skies[439868] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- predator[449864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
    },
    -- Spell damage increased by $s9%.; Immune to Polymorph effects.$?$w3>0[; Armor increased by $w3%.][]$?$w12<0[; Arcane damage taken reduced by $w13% and all other magic damage taken reduced by $w12%.][]
    moonkin_form = {
        id = 24858,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- feral_druid[137011] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- owlkin_frenzy[231042] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },
    -- Immune to Polymorph effects. Movement speed increased by $5419s1%.
    mount_form = {
        id = 210053,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- malornes_swiftness[236012] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- $?s137012[Single-target healing also damages a nearby enemy target for $w3% of the healing done][Single-target damage also heals a nearby friendly target for $w3% of the damage done].
    natures_vigil = {
        id = 124974,
        duration = 15.0,
        tick_time = 0.5,
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
    -- Heals $w2 every $t2 sec.
    regrowth = {
        id = 8936,
        duration = 12.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- feral_druid[137011] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[400320] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- harmonious_constitution[440116] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 35.0, 'target': TARGET_UNIT_CASTER, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 47.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Healing $w1 every $t1 sec.
    rejuvenation = {
        id = 774,
        duration = 12.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[400320] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- wildstalkers_power[439926] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- adaptive_swarm[325748] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391891] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 110.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Bleeding for $w1 damage every $t1 sec.
    rip = {
        id = 1079,
        duration = 4.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dreadful_bleeding[391045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dreadful_bleeding[391045] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lions_strength[391972] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- soul_of_the_forest[158476] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veinripper[391978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- wildstalkers_power[439926] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bloodtalons[145152] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bloodtalons[145152] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 84.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ashamanes_guidance[421442] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
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
    -- Auto-attack speed increased by $w1%.
    ruthless_aggression = {
        id = 441817,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage over time from $@auracaster increased by $w1%.
    sabertooth = {
        id = 391722,
        duration = 4.0,
        max_stack = 1,
    },
    -- Haste increased by $s1% and Energy recovery rate increased by $s2%.
    savage_fury = {
        id = 449646,
        duration = 6.0,
        max_stack = 1,
    },
    -- Movement speed increased by $s1%.
    stampeding_roar = {
        id = 106898,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- improved_stampeding_roar[288826] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- packs_endurance[441844] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Your next Rake or Shred will deal damage as though you were stealthed.
    sudden_ambush = {
        id = 391974,
        duration = 15.0,
        max_stack = 1,
    },
    -- Suffering $w2 Nature damage every $t2 sec.
    sunfire = {
        id = 93402,
        duration = 0.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%.
    survival_instincts = {
        id = 50322,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- oakskin[449191] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Bleeding for $w1 damage every $t1 seconds.
    tear = {
        id = 391356,
        duration = 8.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
    },
    -- Movement speed reduced by $232559s1%.
    thorns = {
        id = 232559,
        duration = 4.0,
        max_stack = 1,
    },
    -- $?a429523[Suffering $w1 Arcane][Bleeding for $w1] damage every $t1 sec.
    thrash = {
        id = 405233,
        duration = 15.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veinripper[391978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- wild_slashes[390864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wild_slashes[390864] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- clearcasting[135700] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- clearcasting[135700] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- clearcasting[135700] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- predator[449864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- lunar_calling[429523] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lunar_calling[429523] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #3: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 64, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Attacks deal $s1% additional damage for their full duration.
    tigers_fury = {
        id = 5217,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- carnivorous_instinct[390902] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- carnivorous_instinct[390902] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- carnivorous_instinct[390902] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- predator[202021] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- raging_fury[391078] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tigers_tenacity[391872] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Your next finishing move restores $391874s1 combo $Lpoint:points;.
    tigers_tenacity = {
        id = 391873,
        duration = 15.0,
        max_stack = 1,
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
    -- Heals $w2 damage every $t2 sec.
    tranquility = {
        id = 157982,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- incarnation_tree_of_life[5420] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_tree_of_life[5420] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- astral_influence[197524] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- heart_of_the_wild[319454] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- adaptive_swarm[325748] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391891] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Immune to Polymorph effects. Movement speed increased.
    travel_form = {
        id = 783,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- malornes_swiftness[236012] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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
    -- Adaptive Swarm has a $w1% chance to split into two Swarms each time it jumps.
    unbridled_swarm = {
        id = 391951,
        duration = 0.0,
        max_stack = 1,
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
        -- moonkin_form[197625] #5: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102383, 'target': TARGET_UNIT_CASTER, }
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
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[400320] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- adaptive_swarm[325748] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391891] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- You retain $w2% increased armor and $w3% increased Stamina from Bear Form.
    wildshape_mastery = {
        id = 441685,
        duration = 6.0,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Command a swarm that heals $391891o1 or deals $391889o1 Nature damage over $391889d to a target, and increases the effectiveness of your periodic effects on them by $391891s2%.; Upon expiration, finds a new target, preferring to alternate between friend and foe up to $s1 times.
    adaptive_swarm = {
        id = 391888,
        cast = 0.0,
        cooldown = 25.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "adaptive_swarm",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- cat_form[3025] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- astral_influence[197524] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

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
        -- guardian_druid[137010] #14: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

        talent = "berserk",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.5, 'trigger_spell': 343216, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- berserk_heart_of_the_lion[391174] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Strikes all nearby enemies with a massive slash, inflicting $s2 Physical damage.$?a231063[ Deals $231063s1% increased damage against bleeding targets.][]$?a405300[ Applies the Bleed from Thrash.][] Deals reduced damage beyond $s3 targets.$?a5487[][; Awards $s1 combo $lpoint:points;.]
    brutal_slash = {
        id = 202028,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        talent = "brutal_slash",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'ap_bonus': 1.476, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- cat_form[768] #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- bear_form[5487] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- empowered_shapeshifting[441689] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- strike_for_the_heart[441845] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- strike_for_the_heart[441845] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wild_slashes[390864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wild_slashes[390864] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- clearcasting[135700] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- clearcasting[135700] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- predator[449864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- You deal $s3 Physical damage and incapacitate the target for $236025d.
    enraged_maim = {
        id = 236026,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 35,
        spendType = 'energy',

        spend = 5,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.270504, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 236025, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- soul_of_the_forest[158476] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- high_winds[200931] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
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

    -- Unleash a furious frenzy, clawing your target $m2 times for ${$274838s1*$m2} Physical damage and an additional ${$m2*$274838s3*$274838d/$274838t3} Bleed damage over $274838d.; Awards $s1 combo points.
    feral_frenzy = {
        id = 274837,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        talent = "feral_frenzy",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.2, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- tear_down_the_mighty[441846] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- predator[449864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
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
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bestial_strength[441841] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lions_strength[391972] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sabertooth[202031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- soul_of_the_forest[158476] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- taste_for_blood[384665] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- apex_predators_craving[391882] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- apex_predators_craving[391882] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- apex_predators_craving[391882] #2: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': -4.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bloodtalons[145152] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- coiled_to_spring[449538] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 73.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Finishing move that causes damage per combo point$?s67598[, consumes up to 25 additional Energy to increase damage by up to 100%, and heals you for ${$67598m1/10}.1% of your total maximum health for each $67598m2 Energy used.][ and consumes up to 25 additional Energy to increase damage by up to 100%.]$?s1079[; When used on targets below 25% health, Ferocious Bite will also refresh the duration of your Rip on your target.][]; Critical strike chance doubled against bleeding targets.;    1 point  : ${$m1*1/5} damage;    2 points: ${$m1*2/5} damage;    3 points: ${$m1*3/5} damage;    4 points: ${$m1*4/5} damage;    5 points: ${$m1*5/5} damage
    ferocious_bite_213826 = {
        id = 213826,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_amp': 0.7, 'ap_bonus': 0.65519994, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'resource': energy, }

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- bestial_strength[441841] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lions_strength[391972] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sabertooth[202031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- soul_of_the_forest[158476] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- taste_for_blood[384665] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apex_predators_craving[391882] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- apex_predators_craving[391882] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- apex_predators_craving[391882] #2: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': -4.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- bloodtalons[145152] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- coiled_to_spring[449538] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 73.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
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
        -- malornes_swiftness[236012] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- heart_of_the_wild[319454] #8: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- verdant_heart[301768] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- empowered_shapeshifting[441689] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- empowered_shapeshifting[441689] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- adaptive_swarm[325748] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391891] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- guardian_druid[137010] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- guardian_druid[137010] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- restoration_druid[137012] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- restoration_druid[137012] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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

        talent = "incarnation_avatar_of_ashamane",
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
        -- berserk_heart_of_the_lion[391174] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Shapeshift into the Tree of Life, increasing healing done by $5420s1%, increasing armor by $5420s3%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, Entangling Roots, and Wrath is enhanced.; Lasts $117679d. You may shapeshift in and out of this form for its duration.
    incarnation_tree_of_life = {
        id = 33891,
        color = 'talent_shapeshift',
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'variance': 0.25, 'target': TARGET_UNIT_CASTER, 'form': tree_of_life_form, 'creature_type': humanoid, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 17, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 7.0, 'trigger_spell': 132213, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- berserk_heart_of_the_lion[391174] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
        -- killing_strikes[441825] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ironfur[231070] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
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
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- soul_of_the_forest[158476] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- empowered_shapeshifting[441689] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- strike_for_the_heart[441845] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- strike_for_the_heart[441845] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

        -- Affected by:
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
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
        -- guardian_druid[137010] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- A quick beam of lunar light burns the enemy for $s2 Arcane damage and then an additional $o1 Arcane damage over $d.; Awards $s3 combo $lpoint:points;.
    moonfire_155625 = {
        id = 155625,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 30,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'ap_bonus': 0.162, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.146, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lore_of_the_grove[449185] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- nurturing_instinct[33873] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- hunt_beneath_the_open_skies[439868] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hunt_beneath_the_open_skies[439868] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- predator[449864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
        from = "affected_by_mastery",
    },

    -- Shapeshift into $?s114301[Astral Form][Moonkin Form], increasing the damage of your spells by $s7% and your armor by $m3%, and granting protection from Polymorph effects.; The act of shapeshifting frees you from movement impairing effects.
    moonkin_form = {
        id = 197625,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "moonkin_form",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 17, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'variance': 0.25, 'target': TARGET_UNIT_CASTER, 'form': moonkin_form, 'creature_type': none, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_BASE_RESISTANCE_PCT, 'points': 125.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_HEALTH_PERCENT, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102383, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }

        -- Affected by:
        -- feral_druid[137011] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- owlkin_frenzy[231042] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },

    -- Shapeshift into $?s114301[Astral Form][Moonkin Form], increasing the damage of your spells by $s9% and your armor by $m3%, and granting protection from Polymorph effects.$?a231042[; While in this form, single-target attacks against you have a $h% chance to make your next Starfire instant.][]; The act of shapeshifting frees you from movement impairing effects.
    moonkin_form_24858 = {
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
        -- feral_druid[137011] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- owlkin_frenzy[231042] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        from = "from_description",
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
        -- malornes_swiftness[236012] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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

    -- Finishing move that deals instant damage and applies Rip to all enemies within $A1 yards. Lasts longer per combo point.;    1 point  : ${$s1*2} plus Rip for ${$s2*2} sec;    2 points: ${$s1*3} plus Rip for ${$s2*3} sec;    3 points: ${$s1*4} plus Rip for ${$s2*4} sec;    4 points: ${$s1*5} plus Rip for ${$s2*5} sec;    5 points: ${$s1*6} plus Rip for ${$s2*6} sec
    primal_wrath = {
        id = 285381,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        talent = "primal_wrath",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.143, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bestial_strength[441841] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- soul_of_the_forest[158476] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- soul_of_the_forest[158476] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veinripper[391978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- coiled_to_spring[449538] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- infected_wounds[48484] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- infected_wounds[48484] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veinripper[391978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- predator[449864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 31.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Finishing move that slashes through your target in a wide arc, dealing Physical damage per combo point to your target and consuming up to $?a102543[${$s2*(1+$102543s3/100)}][$s2] additional Energy to increase that damage by up to 100%. Hits all other enemies in front of you for reduced damage per combo point spent. ;   1 point: ${$m1*1/5} damage, ${$m3*1/5} in an arc;   2 points: ${$m1*2/5} damage, ${$m3*2/5} in an arc;   3 points: ${$m1*3/5} damage, ${$m3*3/5} in an arc;   4 points: ${$m1*4/5} damage, ${$m3*4/5} in an arc;   5 points: ${$m1*5/5} damage, ${$m3*5/5} in an arc
    ravage = {
        id = 441591,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_amp': 0.7, 'ap_bonus': 1.888, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': POWER_BURN, 'subtype': NONE, 'points': 25.0, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.787, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }

        -- Affected by:
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bestial_strength[441841] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lions_strength[391972] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sabertooth[202031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- soul_of_the_forest[158476] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- taste_for_blood[384665] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wildstalkers_power[439926] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- apex_predators_craving[391882] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- apex_predators_craving[391882] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- apex_predators_craving[391882] #2: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': -4.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- bloodtalons[145152] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- coiled_to_spring[449538] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 73.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- feral_druid[137011] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[400320] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- harmonious_constitution[440116] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 35.0, 'target': TARGET_UNIT_CASTER, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 47.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[400320] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- wildstalkers_power[439926] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- adaptive_swarm[325748] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391891] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 110.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    remove_corruption = {
        id = 2782,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.100,
        spendType = 'mana',

        talent = "remove_corruption",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- cat_form[768] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dreadful_bleeding[391045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dreadful_bleeding[391045] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lions_strength[391972] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- soul_of_the_forest[158476] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veinripper[391978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- wildstalkers_power[439926] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bloodtalons[145152] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bloodtalons[145152] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 84.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ashamanes_guidance[421442] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
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
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- empowered_shapeshifting[441689] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- strike_for_the_heart[441845] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- strike_for_the_heart[441845] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- clearcasting[135700] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- clearcasting[135700] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- predator[449864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 96.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- packs_endurance[441844] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
        -- moonfire[164812] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- moonfire[164812] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- heart_of_the_wild[319454] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- starlight_conduit[451211] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[197625] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[197625] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 90.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- moonkin_form[197625] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[197625] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- bestial_strength[441841] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- Reduces all damage you take by $50322s1% for $50322d.
    survival_instincts = {
        id = 61336,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "none",

        talent = "survival_instincts",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- oakskin[449191] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
        -- moonkin_form[197625] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[197625] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- bear_form[5487] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- instincts_of_the_claw[449184] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- wild_slashes[390864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wild_slashes[390864] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lunar_calling[429523] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #3: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 64, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 268.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_razor_claws[77493] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_razor_claws[77493] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- berserk[106951] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[106951] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigers_fury[5217] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigers_fury[5217] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veinripper[391978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- wild_slashes[390864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wild_slashes[390864] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- clearcasting[135700] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- clearcasting[135700] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- clearcasting[135700] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- predator[449864] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adaptive_swarm[325733] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391889] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- lunar_calling[429523] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lunar_calling[429523] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #3: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 64, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }
        -- sabertooth[391722] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ANY, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- malornes_swiftness[236012] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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
        -- moonkin_form[197625] #5: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 102383, 'target': TARGET_UNIT_CASTER, }
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
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[400320] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- adaptive_swarm[325748] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- adaptive_swarm[391891] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 25.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 44.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[400320] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[400320] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- moonkin_form[197625] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[197625] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_druid[137012] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 71.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_druid[137012] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 90.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

} )