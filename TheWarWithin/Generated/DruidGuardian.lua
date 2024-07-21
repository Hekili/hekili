-- DruidGuardian.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 104 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.LunarPower )

spec:RegisterTalents( {
    -- Druid Talents
    astral_influence              = { 82210, 197524, 1 }, -- Increases the range of all of your spells by $s1 yards.
    cyclone                       = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to $d. Only one target can be affected by your Cyclone at a time.
    feline_swiftness              = { 82239, 131768, 1 }, -- Increases your movement speed by $s1%.
    fluid_form                    = { 92229, 449193, 1 }, -- Shred and Rake can be used in any form and shift you into Cat Form. ; Mangle can be used in any form and shifts you into Bear Form. ; Wrath and Starfire shift you into Moonkin Form, if known.
    forestwalk                    = { 100173, 400129, 1 }, -- Casting Regrowth increases your movement speed and healing received by $400126s1% for $400126d.
    frenzied_regeneration         = { 82220, 22842 , 1 }, -- Heals you for $o1% health over $d$?s301768[, and increases healing received by $301768s1%][].
    heart_of_the_wild             = { 82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for $d.$?!s137013[; Balance: Cast time of Balance spells reduced by $s13% and damage increased by $s1%.][]$?!s137011[; Feral: Gain $s14 Combo Point every $t14 sec while in Cat Form and Physical damage increased by $s4%.][]$?!s137010[; Guardian: Bear Form gives an additional $s7% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has ${$s9+1} charges.][]$?!s137012[; Restoration: Healing increased by $s10%, and mana costs reduced by $s12%.][]
    hibernate                     = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to $d. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin             = { 82219, 327993, 1 }, -- Barkskin's duration is increased by ${$s1/1000} sec.
    improved_rejuvenation         = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by ${$m1/1000} sec.
    improved_stampeding_roar      = { 82230, 288826, 1 }, -- Cooldown reduced by ${$m1/-1000} sec.
    improved_sunfire              = { 93714, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within $164815A2 yards.
    incapacitating_roar           = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within $A1 yards for $d. Damage will cancel the effect.
    innervate                     = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for $d.$?s326228[; If cast on somebody else, you gain the effect at $326228s1% effectiveness.][]
    instincts_of_the_claw         = { 100176, 449184, 2 }, -- Shred, $?s202028[Brutal Slash][Swipe], Rake, Mangle, and Thrash damage increased by $s1%.
    ironfur                       = { 82227, 192081, 1 }, -- Increases armor by ${$s1*$AGI/100} for $d.$?a231070[ Multiple uses of this ability may overlap.][]
    killer_instinct               = { 82225, 108299, 2 }, -- Physical damage and Armor increased by $s1%.
    lore_of_the_grove             = { 100175, 449185, 2 }, -- Moonfire and Sunfire damage increased by $s1%. Rejuvenation and Wild Growth healing increased by $s3%.
    lycaras_teachings             = { 82233, 378988, 2 }, -- You gain $s1% of a stat while in each form:; No Form: Haste; Cat Form: Critical Strike; Bear Form: Versatility; Moonkin Form: Mastery
    maim                          = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point:;    1 point  : ${$s2*1} damage, 1 sec;    2 points: ${$s2*2} damage, 2 sec;    3 points: ${$s2*3} damage, 3 sec;    4 points: ${$s2*4} damage, 4 sec;    5 points: ${$s2*5} damage, 5 sec
    mass_entanglement             = { 82242, 102359, 1 }, -- Roots the target and all enemies within $A1 yards in place for $d. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                    = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb $<shield> damage for $280165d.
    mighty_bash                   = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for $d. Usable in all shapeshift forms.
    natural_recovery              = { 82206, 377796, 1 }, -- Healing you receive is increased by $s1%.
    natures_vigil                 = { 82244, 124974, 1 }, -- For $d, $?s137012[all single-target healing also damages a nearby enemy target for $s3% of the healing done][all single-target damage also heals a nearby friendly target for $s3% of the damage done].
    nurturing_instinct            = { 82214, 33873 , 2 }, -- Magical damage and healing increased by $s1%.
    oakskin                       = { 100174, 449191, 1 }, -- Survival Instincts and Barkskin reduce damage taken by an additional $s1%.
    primal_fury                   = { 82238, 159286, 1 }, -- While in Cat Form, when you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect.; Mangle critical strike damage increased by $s2%.
    rake                          = { 82199, 1822  , 1 }, -- Rake the target for $s1 Bleed damage and an additional $155722o1 Bleed damage over $155722d.$?s48484[ Reduces the target's movement speed by $58180s1% for $58180d.][]$?a231052[ ; While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]$?a405834[ ; While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]; Awards $s2 combo $lpoint:points;.
    rejuvenation                  = { 82217, 774   , 1 }, -- Heals the target for $o1 over $d.$?s155675[; You can apply Rejuvenation twice to the same target.][]$?s33891[; Tree of Life: Healing increased by $5420s5% and Mana cost reduced by $5420s4%.][]
    renewal                       = { 82232, 108238, 1 }, -- Instantly heals you for $s1% of maximum health. Usable in all shapeshift forms.
    rip                           = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point.;    1 point  : ${$o1*2} over ${$d*2} sec;    2 points: ${$o1*3} over ${$d*3} sec;    3 points: ${$o1*4} over ${$d*4} sec;    4 points: ${$o1*5} over ${$d*5} sec;    5 points: ${$o1*6} over ${$d*6} sec
    rising_light_falling_night    = { 82207, 417712, 1 }, -- Increases your damage and healing by $417714s1% during the day.; Increases your Versatility by $417715s1% during the night.
    skull_bash                    = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for $93985d.
    soothe                        = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar               = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within $A1 yards by $s1% for $d.
    starlight_conduit             = { 100223, 451211, 1 }, -- Wrath, Starsurge, and Starfire damage increased by $s1%. $?!a137013[; Starsurge's cooldown is reduced by ${-$s2/1000} sec and its mana cost is reduced by $s3%.][]
    sunfire                       = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for $164815s1 Nature damage and then an additional $164815o2 Nature damage over $164815d$?s231050[ to the primary target and all enemies within $164815A2 yards][].$?s137013[; Generates ${$m3/10} Astral Power.][]
    thick_hide                    = { 82228, 16931 , 1 }, -- Reduces all damage taken by $s1%.
    thrash                        = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                    = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by $s1%, reducing gradually over $d.
    typhoon                       = { 82209, 132469, 1 }, -- Blasts targets within $61391a1 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by $61391s3% for $61391d. Usable in all shapeshift forms.
    ursine_vigor                  = { 82235, 377842, 1 }, -- For $340541d after shifting into Bear Form, your health and armor are increased by $s1%.
    ursocs_spirit                 = { 100177, 449182, 1 }, -- Stamina in Bear Form is increased by $s1%.
    ursols_vortex                 = { 82242, 102793, 1 }, -- Conjures a vortex of wind for $d at the destination, reducing the movement speed of all enemies within $A1 yards by $s1%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart                 = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by $s1%.
    wellhoned_instincts           = { 82246, 377847, 1 }, -- When you fall below $s2% health, you cast Frenzied Regeneration, up to once every $s1 sec.
    wild_charge                   = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                   = { 82241, 48438 , 1 }, -- Heals up to $s2 injured allies within $A1 yards of the target for $o1 over $d. Healing starts high and declines over the duration.$?s33891[; Tree of Life: Affects $33891s3 additional $ltarget:targets;.][]

    -- Guardian Talents
    after_the_wildfire            = { 82140, 371905, 1 }, -- Every $s2 Rage you spend causes a burst of restorative energy, healing allies within $371982A1 yds for $371982s1.
    aggravate_wounds              = { 94616, 441829, 1 }, -- Every $?a137010[Maul, Raze, Mangle,  Thrash, or Swipe]$?a137011[attack with an Energy cost that] you cast extends the duration of your Dreadful Wounds by $?a137010[${$s1/1000}.1][${$s2/1000}.1] sec, up to $s3 additional sec.
    arcane_affinity               = { 94586, 429540, 1 }, -- All Arcane damage from your spells and abilities is increased by $s1%.
    astral_insight                = { 94585, 429536, 1 }, -- $?a137013[Incarnation: Chosen of Elune][Incarnation: Guardian of Ursoc] increase Arcane damage from spells and abilities by $102560s6% while active.; Increases the duration and number of spells cast by Convoke the Spirits by $s1%.
    atmospheric_exposure          = { 94607, 429532, 1 }, -- Enemies damaged by $?a137013[Full Moon or Fury of Elune][Lunar Beam or Fury of Elune] take $430589s1% increased damage from you for $430589d.
    berserk_persistence           = { 82144, 50334 , 1 }, -- Go berserk for $50334d, reducing the cooldown of Frenzied Regeneration by $50334s2% and cost of Ironfur by $50334s3%.; Combines with other Berserk abilities.
    berserk_ravage                = { 82149, 50334 , 1 }, -- Go berserk for $50334d, reducing the cooldowns of Mangle, Thrash, and Growl by $s1%.; Combines with other Berserk abilities.
    berserk_unchecked_aggression  = { 82155, 50334 , 1 }, -- Go berserk for $50334d, increasing haste by $s1%, and reducing the rage cost of Maul by $s2%.; Combines with other Berserk abilities.
    bestial_strength              = { 94611, 441841, 1 }, -- $?a137011[Ferocious Bite damage increased by $s1% and Primal Wrath's direct damage increased by $s2%.][Maul and Raze damage increased by $s3%.]
    blood_frenzy                  = { 82142, 203962, 1 }, -- Thrash also generates ${$203961s1/10} Rage each time it deals damage, on up to $s1 targets.
    boundless_moonlight           = { 94608, 424058, 1 }, -- [424588] $?a424113[New Moon and Half Moon call down $s3 Minor $LMoon:Moons; and ][]Full Moon calls down $424058s1 Minor $LMoon:Moons; that $Ldeals:deal; $s1 Astral damage and generate ${$m2/10} Astral Power.
    brambles                      = { 82161, 203953, 1 }, -- Sharp brambles protect you, absorbing and reflecting up to $<shield> damage from each attack.; While Barkskin is active, the brambles also deal $213709s1 Nature damage to all nearby enemies every $22812t3 sec.
    bristling_fur                 = { 82161, 155835, 1 }, -- Bristle your fur, causing you to generate Rage based on damage taken for $d.
    circle_of_life_and_death      = { 82137, 391969, 1 }, -- Your damage over time effects deal their damage in $s1% less time, and your healing over time effects in $s2% less time.
    claw_rampage                  = { 94613, 441835, 1 }, -- During Berserk, $?a137010[Mangle][Shred], $?s202028[Brutal Slash][Swipe], and Thrash have a $h% chance to make your next $?a137010[Maul][Ferocious Bite] become Ravage.
    convoke_the_spirits           = { 82136, 391528, 1 }, -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of $s2 Druid spells and abilities over $d.$?s391538[ Chance to use an exceptional spell or ability is increased.][]; You will cast $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    dreadful_wound                = { 94620, 441809, 1 }, -- Ravage also inflicts a Bleed that causes $?a137011[$441812s1][$451177s1] damage over $441812d and saps its victims' strength, reducing damage they deal to you by $?a137011[$441812s2][$451177s2]%.; Dreadful Wound is not affected by Circle of Life and Death. $?a137011[If a Dreadful Wound benefiting from Tiger's Fury is re-applied, the new Dreadful Wound deals damage as if Tiger's Fury was active.][]
    dream_of_cenarius             = { 92227, 372119, 1 }, -- When you take non-periodic damage, you have a chance equal to your critical strike to cause your next Regrowth to heal for an additional $372152s4%, and to be instant, free, and castable in all forms for $372152d. ; This effect cannot occur more than once every $372523d.
    earthwarden                   = { 82156, 203974, 1 }, -- When you deal direct damage with Thrash, you gain a charge of Earthwarden, reducing the damage of the next auto attack you take by $s1%. Earthwarden may have up to $203975u charges.
    elunes_favored                = { 82134, 370586, 1 }, -- While in Bear Form, you deal $370588s1% increased Arcane damage, and are healed for $s1% of all Arcane damage done.
    elunes_grace                  = { 94597, 443046, 1 }, -- Using Wild Charge while in Bear Form or Moonkin Form incurs a $s1 sec shorter cooldown.
    empowered_shapeshifting       = { 94612, 441689, 1 }, -- Frenzied Regeneration can be cast in Cat Form for $s2 Energy.; Bear Form reduces magic damage you take by ${-$s4}%.; Shred and $?s202028[Brutal Slash][Swipe] damage increased by $s5%. Mangle damage increased by $s6%.
    flashing_claws                = { 82154, 393427, 2 }, -- Thrash has a $s1% chance to trigger an additional Thrash.; Thrash stacks $s2 additional $ltime:times;.
    fount_of_strength             = { 94618, 441675, 1 }, -- Your maximum Energy and Rage are increased by $s1.; Frenzied Regeneration also increases your maximum health by $s3%.
    fury_of_nature                = { 82138, 370695, 2 }, -- While in Bear Form, you deal $s1% increased Arcane damage.
    galactic_guardian             = { 82145, 203964, 1 }, -- Your damage has a $h% chance to trigger a free automatic Moonfire on that target. ; When this occurs, the next Moonfire you cast generates ${$213708m1/10} Rage, and deals $213708s3% increased direct damage.
    glistening_fur                = { 94594, 429533, 1 }, -- Bear Form and Moonkin Form reduce Arcane damage taken by $s2% and all other magic damage taken by $s1%.
    gore                          = { 82126, 210706, 1 }, -- Thrash, Swipe, Moonfire, and Maul have a $s1% chance to reset the cooldown on Mangle, and to cause it to generate an additional ${$93622m1/10} Rage.
    gory_fur                      = { 82132, 200854, 1 }, -- Mangle has a $h% chance to reduce the Rage cost of your next Ironfur by $s1%.
    guardian_of_elune             = { 82140, 155578, 1 }, -- Mangle increases the duration of your next Ironfur by ${$213680m1/1000} sec, or the healing of your next Frenzied Regeneration by $213680s2%.
    improved_survival_instincts   = { 82128, 328767, 1 }, -- Survival Instincts now has ${$s1+1} charges.; 
    incarnation_guardian_of_ursoc = { 82136, 102558, 1 }, -- [102558] An improved Bear Form that grants the benefits of Berserk, causes Mangle to hit up to $s12 targets, $?a429536[increases Arcane damage by $s14%, ][]and increases maximum health by $s13%.$?a339062[; Grants immunity to effects that cause loss of control of your character.][]; Lasts $d. You may freely shapeshift in and out of this improved Bear Form for its duration.
    infected_wounds               = { 82162, 345208, 1 }, -- Mangle and Maul cause an Infected Wound in the target, reducing their movement speed by $345209s1% for $345209d.
    innate_resolve                = { 82160, 377811, 1 }, -- Frenzied Regeneration's healing is increased by up to $s1% based on your missing health.; Frenzied Regeneration has ${$s2} additional charge.
    killing_strikes               = { 94619, 441824, 1 }, -- Ravage increases your Agility by $441825s1% and the armor granted by Ironfur by $441825s2% for $441825d.; Your first $?a137011[Tiger's Fury][Mangle] after entering combat makes your next $?a137011[Ferocious Bite][Maul] become Ravage.
    layered_mane                  = { 82148, 384721, 2 }, -- Ironfur has a $s1% chance to apply two stacks and Frenzied Regeneration has a $s2% chance to not consume a charge.
    lunar_amplification           = { 94596, 429529, 1 }, -- Each non-Arcane damaging ability you use increases the damage of your next Arcane damaging ability by $431250s1%, stacking up to $431250U times.
    lunar_beam                    = { 92587, 204066, 1 }, -- Summons a beam of lunar light at your location, increasing your mastery by ${$s2*$mas}%, dealing ${$414613s1*$s1} Arcane damage, and healing you for ${$204069s1*$s1} over $m1 sec.
    lunar_calling                 = { 94590, 429523, 1 }, -- $?a137013[Starfire deals $s1% increased damage to its primary target, but no longer triggers Solar Eclipse.][Thrash now deals Arcane damage and its damage is increased by $s2%.]
    lunar_insight                 = { 94588, 429530, 1 }, -- Moonfire deals $s1 additional damage.
    lunation                      = { 94586, 429539, 1 }, -- $?a137013[Your Arcane abilities reduce the cooldown of Fury of Elune by ${$s1/-1000}.1 sec and the cooldown of New Moon, Half Moon, and Full Moon by ${$s2/-1000}.1 sec.][Your Arcane abilities reduce the cooldown of Lunar Beam by ${$s3/-1000}.1 sec.]; 
    mangle                        = { 82131, 231064, 1 }, -- Mangle deals $33917s3% additional damage against bleeding targets.
    maul                          = { 82127, 6807  , 1 }, -- Maul the target for $s2 Physical damage.
    moon_guardian                 = { 94598, 429520, 1 }, -- $?a137013[Moonfire and Starfire generate ${$s1/10} additional Astral Power.][Free automatic Moonfires from Galactic Guardian generate ${$430581s1/10} Rage.]
    moondust                      = { 94597, 429538, 1 }, -- Enemies affected by Moonfire are slowed by $164812s8%.
    moonkin_form                  = { 91047, 197625, 1 }, -- Shapeshift into $?s114301[Astral Form][Moonkin Form], increasing the damage of your spells by $s7% and your armor by $m3%, and granting protection from Polymorph effects.; The act of shapeshifting frees you from movement impairing effects.
    moonless_night                = { 92586, 400278, 1 }, -- Your direct damage melee abilities against enemies afflicted by Moonfire cause them to burn for an additional $s1% Arcane damage.
    packs_endurance               = { 94615, 441844, 1 }, -- Stampeding Roar's duration is increased by $s1%.
    pulverize                     = { 82153, 80313 , 1 }, -- A devastating blow that consumes $s3 stacks of your Thrash on the target to deal $s1 Physical damage and reduce the damage they deal to you by $s2% for $d.
    rage_of_the_sleeper           = { 82141, 200851, 1 }, -- Unleashes the rage of Ursoc for $d, preventing $s3% of all damage you take, increasing your damage done by $s5%, granting you $s3% leech, and reflecting $219432s1 Nature damage back at your attackers.
    ravage                        = { 94609, 441583, 1 }, -- [441605] Slash through your target in a wide arc, dealing $s1 Physical damage to your target and $s2 to all other enemies in front of you.
    raze                          = { 92588, 400254, 1 }, -- Strike with the might of Ursoc, dealing $s1 Physical damage to all enemies in front of you. Deals reduced damage beyond 5 targets.
    reinforced_fur                = { 82139, 393618, 1 }, -- Ironfur increases armor by an additional $s1% and Barkskin reduces damage taken by an additional $s2%.
    reinvigoration                = { 82157, 372945, 2 }, -- Frenzied Regeneration's cooldown is reduced by $s1%.
    remove_corruption             = { 82215, 2782  , 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    rend_and_tear                 = { 82152, 204053, 1 }, -- Each stack of Thrash reduces the target's damage to you by $s3% and increases your damage to them by $s1%.
    ruthless_aggression           = { 94619, 441814, 1 }, -- Ravage increases your auto-attack speed by $441817s1% for $441817d.
    scintillating_moonlight       = { 82146, 238049, 2 }, -- Moonfire reduces damage dealt to you by ${$s1/1}%.
    soul_of_the_forest            = { 92226, 158477, 1 }, -- Mangle generates ${$m1/10} more Rage and deals $s2% more damage.
    starfire                      = { 91046, 197628, 1 }, -- Call down a burst of energy, causing $s1 Arcane damage to the target, and ${$m1*$m2/100} Arcane damage to all other enemies within $A1 yards. Deals reduced damage beyond $s3 targets.
    starsurge                     = { 82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing $s1 Astral damage.
    stellar_command               = { 94590, 429668, 1 }, -- $?a137013[Increases the damage of Fury of Elune by $s1% and the damage of Full Moon by $s2%.][Increases the damage of Lunar Beam by $s3% and Fury of Elune by $s1%.]
    strike_for_the_heart          = { 94614, 441845, 1 }, -- Shred, $?s202028[Brutal Slash][Swipe], and Mangle's critical strike chance and critical strike damage are increased by $s1%.; $?a137010[Mangle heals you for $458724s1% of maximum health.][]
    survival_instincts            = { 82129, 61336 , 1 }, -- Reduces all damage you take by $50322s1% for $50322d.
    survival_of_the_fittest       = { 82143, 203965, 2 }, -- Reduces the cooldowns of Barkskin and Survival Instincts by $s1%.
    tear_down_the_mighty          = { 94614, 441846, 1 }, -- The cooldown of $?a137011[Feral Frenzy][Pulverize] is reduced by ${$s1/-1000} sec.
    the_eternal_moon              = { 94587, 424113, 1 }, -- Further increases the power of Boundless Moonlight.; $?a137010[$@spellicon204066 $@spellname204066; Lunar Beam increases Mastery by an additional ${$s5*$mas}%, deals $s6% increased damage, and lasts ${$s3/1000} sec longer.; $@spellicon202770 $@spellname202770; The flash of energy now generates  ${$428682s3/10} Rage and its damage is increased by $s1%.][$@spellicon202770 $@spellname202770; The flash of energy now generates ${$428682s2/10} Astral Power and its damage is increased by $s1%.; $@spellicon274283 $@spellname274283; New Moon and Half Moon now also call down $s2 Minor $LMoon:Moons;.]
    the_light_of_elune            = { 94585, 428655, 1 }, -- Moonfire damage has a chance to call down a Fury of Elune to follow your target for ${$s2/1000} sec.; $@spellicon202770 $@spellname202770; Calls down a beam of pure celestial energy, dealing $<dmg> Astral damage over ${$s2/1000} sec within its area.; Generates $?a137010[${$202770m4/$202770t4*$s2/10000} Rage][${$202770m3/$202770t3*$s2/10000} Astral Power] over its duration.
    thorns_of_iron                = { 92585, 400222, 1 }, -- When you cast Ironfur, also deal Physical damage equal to $s1% of your armor, split among enemies within $r yards. Damage reduced above $s2 applications.
    tooth_and_claw                = { 82133, 135288, 1 }, -- Autoattacks have a $s1% chance to empower your next cast of Maul or Raze, stacking up to $135286u times.; An empowered cast of Maul or Raze deals $135286s1% increased damage, costs $135286s3% less rage, and reduces the target's damage to you by $135601s2% for $135601d.
    twin_moonfire                 = { 82147, 372567, 1 }, -- Moonfire deals $s2% increased damage and also hits another nearby enemy within $279620s1 yds of the target.
    untamed_savagery              = { 82152, 372943, 1 }, -- Increases the damage and radius of Thrash by $s1%.
    ursocs_endurance              = { 82130, 393611, 1 }, -- Increases the duration of Barkskin and Ironfur by ${$m1/1000}.1 sec.
    ursocs_fury                   = { 82151, 377210, 1 }, -- Thrash and Maul grant you an absorb shield for $s1% of the damage dealt for $372505d.
    ursocs_guidance               = { 82135, 393414, 1 }, -- $@spellicon102558 $@spellname102558: ; Every $s5 Rage you spend reduces the cooldown of Incarnation: Guardian of Ursoc by 1 sec.; $@spellicon391528 $@spellname391528: ; Convoke the Spirits' cooldown is reduced by ${($abs($s4)/120000)*100}% and its duration and number of spells cast is reduced by $s1%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    vicious_cycle                 = { 82158, 371999, 1 }, -- Mangle increases the damage of your next cast of Maul or Raze, and casting Maul or Raze increases the damage of your next Mangle by $s1%. Stacks up to $372015u.
    vulnerable_flesh              = { 82159, 372618, 2 }, -- Maul and Raze have an additional $s1% chance to critically strike.
    wildpower_surge               = { 94612, 441691, 1 }, -- $?s202028[Shred and Brutal Slash]?a137011[Shred and Swipe][]$?a137011[ grant Ursine Potential. When you have $441695s1 stacks, the next time you transform into Bear Form, your next Mangle deals $441698s1% increased damage or your next Swipe deals $441698s2% increased damage. Either generates ${$442562s1/10} extra Rage.][Mangle grants Feline Potential. When you have $441701s1 stacks, the next time you transform into Cat Form, gain $441704s1 combo points and your next Ferocious Bite or Rip deals $441702s1% increased damage for its full duration.]
    wildshape_mastery             = { 94610, 441678, 1 }, -- Ironfur and Frenzied Regeneration persist in Cat Form.; When transforming from Bear to Cat Form, you retain $441685s1% of your Bear Form armor and health for $441685d.; For $441686d after entering Bear Form, you heal for $441686s1% of damage taken over $441688d. 
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_challenge     = 842 , -- (207017) [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    charging_bash       = 194 , -- (228431) Increases the range of your Skull Bash by $m1 yards.
    demoralizing_roar   = 52  , -- (201664) Demoralizes all enemies within $A1 yards, reducing the damage they do by $s1% for $d.
    den_mother          = 51  , -- (236180) You bolster nearby allies within $m1 yards, increasing their maximum health by $236181m1%.; The duration of all stun effects on you is reduced by $s2%.
    emerald_slumber     = 197 , -- (329042) Embrace the Emerald Dream, causing you to enter a deep slumber for $d. While sleeping, all other cooldowns recover $s1% faster, and allies within $a5 yds are healed for $s5 every ${$t5+.1} sec.; Direct damage taken may awaken you.
    entangling_claws    = 195 , -- (202226) Entangling Roots is now an instant cast spell with a ${$s2/1000} second cooldown but with a $m5 yard range. It can also be cast while in shapeshift forms.
    freedom_of_the_herd = 3750, -- (213200) Your Stampeding Roar clears all roots and snares from yourself and allies.
    grove_protection    = 5410, -- (354654) Summon a grove to protect allies in the area for $d, reducing damage taken by $s2% from enemies outside the grove.
    malornes_swiftness  = 1237, -- (236147) Your Travel Form movement speed while within a Battleground or Arena is increased by $m2% and you always move at $m1% movement speed while in Travel Form.
    master_shapeshifter = 49  , -- (236144) Your abilities are amplified based on your current shapeshift form, granting an additional effect.; $@spellicon197492 Caster Form; Rejuvenation and Swiftmend heal for $s1% more and cause you to instantly generate $411231s1 Rage after entering Bear Form.; $@spellicon197488 Moonkin Form; Wrath, Starfire, and Starsurge deal $s2% additional damage and cause you to instantly generate $411231s1 Rage after entering Bear Form.; $@spellicon202155 Cat Form; Rip, Ferocious Bite, and Maim deal $s3% additional damage and cause you to instantly generate ${$411231s1*2} Rage after entering Bear Form when cast with $s4 combo points.
    overrun             = 196 , -- (202246) Charge to an enemy, stunning them for $202244d and knocking back their allies within $202244A3 yards.
    tireless_pursuit    = 5648, -- (377801) For ${$s1/1000} sec after leaving Cat Form or Travel Form, you retain up to $s2% movement speed.
} )

-- Auras
spec:RegisterAuras( {
    -- You will trigger a burst of restorative energy after spending $w1 more Rage.
    after_the_wildfire = {
        id = 400734,
        duration = 3600,
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
        -- guardian_druid[137010] #14: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- improved_barkskin[327993] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- oakskin[449191] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- verdant_heart[301768] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- reinforced_fur[393618] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- survival_of_the_fittest[203965] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -12.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- ursocs_endurance[393611] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
    -- Generating Rage from taking damage.
    bristling_fur = {
        id = 155835,
        duration = 8.0,
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
        -- circle_of_life_and_death[391969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
    },
    -- Every ${$t1}.2 sec, casting $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake or Thrash on appropriate nearby targets.
    convoke_the_spirits = {
        id = 391528,
        duration = 4.0,
        tick_time = 0.25,
        max_stack = 1,

        -- Affected by:
        -- astral_insight[429536] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- astral_insight[429536] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- ursocs_guidance[393414] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- ursocs_guidance[393414] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- ursocs_guidance[393414] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
    },
    -- Increased movement speed by $s1% while in Cat Form.
    dash = {
        id = 1850,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- cat_form[768] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },
    -- Demoralized, dealing $s1% less damage.
    demoralizing_roar = {
        id = 201664,
        duration = 8.0,
        max_stack = 1,
    },
    -- Increases maximum health by $w1%.
    den_mother = {
        id = 236181,
        duration = 3600,
        max_stack = 1,
    },
    -- Your next Regrowth heals for an additional $s4% and is free, instant, and castable in all forms.
    dream_of_cenarius = {
        id = 372152,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage of the next autoattack you take will be reduced by $203974s1~%.
    earthwarden = {
        id = 203975,
        duration = 3600,
        max_stack = 1,
    },
    -- Restores health to three injured allies within $81269A1 yards every $81262t1 sec for $81262d.
    efflorescence = {
        id = 81262,
        duration = 30.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,
    },
    -- $@auracaster is in a deep slumber. Healing for $s5 every $t5 sec.
    emerald_slumber = {
        id = 329042,
        duration = 8.0,
        max_stack = 1,
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
        -- entangling_claws[202226] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1700.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- entangling_claws[202226] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- entangling_claws[202226] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- entangling_claws[202226] #3: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- overpowering_aura[395944] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Damage taken increased by $m1%.
    focused_assault = {
        id = 206891,
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
        -- guardian_druid[137010] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- guardian_druid[137010] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- heart_of_the_wild[319454] #8: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- verdant_heart[301768] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- berserk[50334] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- empowered_shapeshifting[441689] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- empowered_shapeshifting[441689] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- incarnation_guardian_of_ursoc[102558] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- innate_resolve[377811] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- reinvigoration[372945] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Your next Moonfire generates ${$m1/10} Rage, and deals $s3% increased direct damage.
    galactic_guardian = {
        id = 213708,
        duration = 15.0,
        max_stack = 1,
    },
    -- Mangle's cooldown has been reset, and generates an additional ${$m1/10} Rage.$?a393637[ Mangle deals $393637s2% additional damage][]
    gore = {
        id = 93622,
        duration = 10.0,
        max_stack = 1,
    },
    -- Reduces the Rage cost of your next Ironfur by $s1%.
    gory_fur = {
        id = 201671,
        duration = 3600,
        max_stack = 1,
    },
    -- Taunted.
    growl = {
        id = 6795,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- berserk[50334] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- incarnation_guardian_of_ursoc[102558] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Increases the duration of your next Ironfur by ${$m1/1000} sec, or the healing of your next Frenzied Regeneration by $s2%.
    guardian_of_elune = {
        id = 213680,
        duration = 15.0,
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
    -- Cooldowns of Mangle, Thrash, Growl, and Frenzied Regeneration are reduced by $w1%.; Ironfur cost reduced by $w3%.; Mangle hits up to $w12 targets.; Health increased by $w13%.$?a429536[; Arcane damage increased by $w14%.][]$?$w7>0[; Immune to effects that cause loss of control of your character.][]
    incarnation_guardian_of_ursoc = {
        id = 102558,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- berserk_unchecked_aggression[377623] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- berserk_unchecked_aggression[377623] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
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
    -- Movement speed slowed by $w1%.
    infected_wounds = {
        id = 345209,
        duration = 12.0,
        max_stack = 1,
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
        -- ursine_adept[300346] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- heart_of_the_wild[319454] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- berserk[50334] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_guardian_of_ursoc[102558] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- reinforced_fur[393618] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ursocs_endurance[393611] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- gory_fur[201671] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- guardian_of_elune[213680] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- killing_strikes[441825] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ironfur[231070] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Agility increased by $w1% and armor granted by Ironfur increased by $w2%.
    killing_strikes = {
        id = 441825,
        duration = 8.0,
        max_stack = 1,
    },
    -- The damage of your next Arcane ability is increased by $w1%.
    lunar_amplification = {
        id = 431250,
        duration = 45.0,
        max_stack = 1,
    },
    -- Mastery increased by ${$w2*$mas}%.
    lunar_beam = {
        id = 204066,
        duration = 8.5,
        max_stack = 1,

        -- Affected by:
        -- boundless_moonlight[424058] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 7.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- the_eternal_moon[424113] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- the_eternal_moon[424113] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- the_eternal_moon[424113] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 14.5, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- master_shapeshifter[236144] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
    -- $w1 Rage is instantly generated upon entering Bear Form.
    master_shapeshifter = {
        id = 411231,
        duration = 3600,
        max_stack = 1,
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
    -- Suffering $w2 Arcane damage every $t2 seconds.$?$w8<0[; Movement slowed by $w8%.][]
    moonfire = {
        id = 164812,
        duration = 18.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- guardian_druid[137010] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- arcane_affinity[429540] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_affinity[429540] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_insight[429530] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lunar_insight[429530] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[197625] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[197625] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rage_of_the_sleeper[200851] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twin_moonfire[372567] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twin_moonfire[372567] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elunes_favored[370588] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twin_moons[279620] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twin_moons[279620] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Your direct damage melee abilities against enemies afflicted by Moonfire cause them to burn for an additional $w1% Arcane damage.
    moonless_night = {
        id = 400278,
        duration = 0.0,
        max_stack = 1,
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
    -- $?s137012[Single-target healing also damages a nearby enemy target for $w3% of the healing done][Single-target damage also heals a nearby friendly target for $w3% of the damage done].
    natures_vigil = {
        id = 124974,
        duration = 15.0,
        tick_time = 0.5,
        max_stack = 1,
    },
    -- Damage dealt increased by $s1% and damage taken reduced by $s1%.
    overpowering_aura = {
        id = 395944,
        duration = 6.0,
        max_stack = 1,
    },
    -- Knocked down.
    overrun = {
        id = 202244,
        duration = 3.0,
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
    -- Dealing $w2% reduced damage to $@auracaster.
    pulverize = {
        id = 80313,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #4: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rage_of_the_sleeper[200851] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tear_down_the_mighty[441846] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overpowering_aura[395944] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Prevents $s3% of all damage you take, increases damage done by $s5%, grants $s3% leech, and reflects $219432s1 Nature damage back at your attackers.
    rage_of_the_sleeper = {
        id = 200851,
        duration = 8.0,
        max_stack = 1,
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
        -- guardian_druid[137010] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[391969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dream_of_cenarius[372152] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 8936, 'triggers': regrowth, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- dream_of_cenarius[372152] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'trigger_spell': 8936, 'triggers': regrowth, 'target': TARGET_UNIT_CASTER, }
        -- dream_of_cenarius[372152] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 8936, 'triggers': regrowth, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dream_of_cenarius[372152] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dream_of_cenarius[372152] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- guardian_druid[137010] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[391969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- master_shapeshifter[236144] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- master_shapeshifter[236144] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- master_shapeshifter[236144] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- master_shapeshifter[236144] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Auto-attack speed increased by $w1%.
    ruthless_aggression = {
        id = 441817,
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
    -- Increased movement speed by $s1% while in Cat Form, reducing gradually over time.
    tiger_dash = {
        id = 252216,
        duration = 5.0,
        tick_time = 0.5,
        max_stack = 1,

        -- Affected by:
        -- cat_form[768] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },
    -- Dealing $w1% reduced damage to $@auracaster.
    tooth_and_claw = {
        id = 135601,
        duration = 6.0,
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
        -- circle_of_life_and_death[391969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
    -- Absorbing $w1 damage.
    ursocs_fury = {
        id = 372505,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed slowed by $s1% and winds impeding movement.
    ursols_vortex = {
        id = 102793,
        duration = 10.0,
        max_stack = 1,
    },
    -- Your next cast of Maul or Raze deals $w1% increased damage.
    vicious_cycle = {
        id = 372015,
        duration = 15.0,
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
        -- guardian_druid[137010] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[391969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    alpha_challenge = {
        id = 207017,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 206891, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
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
        -- guardian_druid[137010] #14: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- improved_barkskin[327993] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- oakskin[449191] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- verdant_heart[301768] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- reinforced_fur[393618] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- survival_of_the_fittest[203965] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -12.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- ursocs_endurance[393611] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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

    -- Go berserk for $d$?a377623[, increasing your haste by $s4%][]$?a343240|a377779[, reducing the cooldown of ][]$?a377779[Frenzied Regeneration by $s2%][]$?a343240&a377779[, ][]$?a343240[Mangle, Thrash, and Growl by $s3%][]$?a377779|a377623[, and reducing the cost of ][]$?a377623[Maul][]$?a377623&a377779[ and ][]$?a377779[Ironfur][]$?a377779|a377623[ by $s3%][].$?a339062[; Grants immunity to effects that cause loss of control of your character.][]
    berserk = {
        id = 50334,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        talent = "berserk",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- #1: { 'type': APPLY_AURA, 'subtype': CHARGE_RECOVERY_MULTIPLIER, 'points': -100.0, 'value': 1568, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 6807, 'triggers': maul, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MOD_LEECH, 'points': 15.0, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'value': 2071, 'schools': ['physical', 'holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }

        -- Affected by:
        -- berserk_unchecked_aggression[377623] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- berserk_unchecked_aggression[377623] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },

    -- Go Berserk for $d. While Berserk:; Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap.; All attack and ability damage is increased by $s3%.
    berserk_106951 = {
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
        from = "from_description",
    },

    -- Bristle your fur, causing you to generate Rage based on damage taken for $d.
    bristling_fur = {
        id = 155835,
        cast = 0.0,
        cooldown = 40.0,
        gcd = "global",

        talent = "bristling_fur",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
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
        -- astral_insight[429536] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- astral_insight[429536] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- ursocs_guidance[393414] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- ursocs_guidance[393414] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- ursocs_guidance[393414] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

    -- Demoralizes all enemies within $A1 yards, reducing the damage they do by $s1% for $d.
    demoralizing_roar = {
        id = 201664,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'points': -20.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
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

    -- Embrace the Emerald Dream, causing you to enter a deep slumber for $d. While sleeping, all other cooldowns recover $s1% faster, and allies within $a5 yds are healed for $s5 every ${$t5+.1} sec.; Direct damage taken may awaken you.
    emerald_slumber = {
        id = 329042,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE_EXCLUSIVE, 'points': 400.0, 'value': 21, 'schools': ['physical', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 400.0, 'value': 1568, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'mechanic': asleep, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 5, }
        -- #4: { 'type': APPLY_AREA_AURA_FRIEND, 'subtype': PERIODIC_HEAL, 'tick_time': 0.9, 'ap_bonus': 0.6, 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 400.0, 'value': 1469, 'schools': ['physical', 'fire', 'nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 400.0, 'value': 1901, 'schools': ['physical', 'fire', 'nature', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 400.0, 'value': 1909, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 400.0, 'value': 1884, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE_EXCLUSIVE, 'points': 400.0, 'value': 1089, 'schools': ['physical', 'arcane'], 'target': TARGET_UNIT_CASTER, }
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
        -- entangling_claws[202226] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1700.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- entangling_claws[202226] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- entangling_claws[202226] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- entangling_claws[202226] #3: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- overpowering_aura[395944] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bestial_strength[441841] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- master_shapeshifter[236144] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- guardian_druid[137010] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- guardian_druid[137010] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- heart_of_the_wild[319454] #8: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- verdant_heart[301768] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- berserk[50334] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- empowered_shapeshifting[441689] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- empowered_shapeshifting[441689] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- incarnation_guardian_of_ursoc[102558] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- innate_resolve[377811] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- reinvigoration[372945] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Summon a grove to protect allies in the area for $d, reducing damage taken by $s2% from enemies outside the grove.
    grove_protection = {
        id = 354654,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 23195, 'schools': ['physical', 'holy', 'nature', 'frost'], 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_DEST_DEST, }
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

        -- Affected by:
        -- berserk[50334] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- incarnation_guardian_of_ursoc[102558] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

    -- An improved Bear Form that grants the benefits of Berserk, causes Mangle to hit up to $s12 targets, $?a429536[increases Arcane damage by $s14%, ][]and increases maximum health by $s13%.$?a339062[; Grants immunity to effects that cause loss of control of your character.][]; Lasts $d. You may freely shapeshift in and out of this improved Bear Form for its duration.
    incarnation_guardian_of_ursoc = {
        id = 102558,
        color = 'shapeshift',
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        talent = "incarnation_guardian_of_ursoc",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- #1: { 'type': APPLY_AURA, 'subtype': CHARGE_RECOVERY_MULTIPLIER, 'points': -100.0, 'value': 1568, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MOD_LEECH, 'points': 15.0, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'value': 2071, 'schools': ['physical', 'holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 6807, 'triggers': maul, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- #12: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_HEALTH_PERCENT, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- berserk_unchecked_aggression[377623] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- berserk_unchecked_aggression[377623] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
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
        -- ursine_adept[300346] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- heart_of_the_wild[319454] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- berserk[50334] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_guardian_of_ursoc[102558] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- reinforced_fur[393618] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ursocs_endurance[393611] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- gory_fur[201671] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- guardian_of_elune[213680] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- killing_strikes[441825] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ironfur[231070] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },

    -- Summons a beam of lunar light at your location, increasing your mastery by ${$s2*$mas}%, dealing ${$414613s1*$s1} Arcane damage, and healing you for ${$204069s1*$s1} over $m1 sec.
    lunar_beam = {
        id = 204066,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "lunar_beam",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 8.0, 'value': 5994, 'schools': ['holy', 'nature', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MASTERY, 'points': 21.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- boundless_moonlight[424058] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 7.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- the_eternal_moon[424113] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- the_eternal_moon[424113] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- the_eternal_moon[424113] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 14.5, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- master_shapeshifter[236144] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- fluid_form[449193] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- instincts_of_the_claw[449184] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- primal_fury[159286] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- berserk[50334] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- empowered_shapeshifting[441689] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- rage_of_the_sleeper[200851] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- soul_of_the_forest[158477] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- soul_of_the_forest[158477] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- strike_for_the_heart[441845] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- strike_for_the_heart[441845] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- gore[93622] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- overpowering_aura[395944] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Maul the target for $s2 Physical damage.
    maul = {
        id = 6807,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 400,
        spendType = 'rage',

        talent = "maul",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_amp': 0.5, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.19728, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[50334] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 6807, 'triggers': maul, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bestial_strength[441841] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rage_of_the_sleeper[200851] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vulnerable_flesh[372618] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 6807, 'triggers': maul, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- tooth_and_claw[135286] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.5, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tooth_and_claw[135286] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vicious_cycle[372015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- guardian_druid[137010] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #10: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- astral_influence[197524] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- moon_guardian[429520] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- elunes_favored[370588] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- galactic_guardian[213708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- feral_druid[137011] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- feral_druid[137011] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
        -- malornes_swiftness[236147] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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

    -- Charge to an enemy, stunning them for $202244d and knocking back their allies within $202244A3 yards.
    overrun = {
        id = 202246,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 25.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': CHARGE, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 202249, 'target': TARGET_UNIT_TARGET_ANY, }
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

    -- A devastating blow that consumes $s3 stacks of your Thrash on the target to deal $s1 Physical damage and reduce the damage they deal to you by $s2% for $d.
    pulverize = {
        id = 80313,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "pulverize",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.35702, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_TARGET_RESIST, 'points': -35.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #4: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rage_of_the_sleeper[200851] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tear_down_the_mighty[441846] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overpowering_aura[395944] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Strike with the might of Ursoc, dealing $s1 Physical damage to all enemies in front of you. Deals reduced damage beyond 5 targets.
    raze = {
        id = 400254,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 400,
        spendType = 'rage',

        talent = "raze",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.644, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }

        -- Affected by:
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[50334] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 6807, 'triggers': maul, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- bestial_strength[441841] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rage_of_the_sleeper[200851] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vulnerable_flesh[372618] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 6807, 'triggers': maul, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- tooth_and_claw[135286] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.5, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tooth_and_claw[135286] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- vicious_cycle[372015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- guardian_druid[137010] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[391969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dream_of_cenarius[372152] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 8936, 'triggers': regrowth, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- dream_of_cenarius[372152] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'trigger_spell': 8936, 'triggers': regrowth, 'target': TARGET_UNIT_CASTER, }
        -- dream_of_cenarius[372152] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 8936, 'triggers': regrowth, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dream_of_cenarius[372152] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dream_of_cenarius[372152] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- guardian_druid[137010] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[391969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- master_shapeshifter[236144] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- master_shapeshifter[236144] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- cat_form[768] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heart_of_the_wild[319454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_wild[319454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rip[1079] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- master_shapeshifter[236144] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- master_shapeshifter[236144] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- empowered_shapeshifting[441689] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- strike_for_the_heart[441845] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- strike_for_the_heart[441845] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- charging_bash[228431] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- arcane_affinity[429540] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_affinity[429540] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moon_guardian[429520] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- moon_guardian[429520] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- moonkin_form[197625] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[197625] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- arcane_affinity[429540] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_affinity[429540] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[197625] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[197625] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- berserk[50334] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 6807, 'triggers': maul, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- bestial_strength[441841] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- vulnerable_flesh[372618] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 6807, 'triggers': maul, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- tooth_and_claw[135286] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.5, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tooth_and_claw[135286] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- vicious_cycle[372015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- improved_survival_instincts[328767] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
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
        -- guardian_druid[137010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- guardian_druid[137010] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 58.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- guardian_druid[137010] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 268.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bear_form[5487] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- druid[137009] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- ashamanes_frenzy[210723] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- instincts_of_the_claw[449184] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instincts_of_the_claw[449184] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- killer_instinct[108299] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killer_instinct[108299] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_affinity[429540] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_affinity[429540] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[50334] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lunar_calling[429523] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #3: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 64, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }
        -- rage_of_the_sleeper[200851] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- untamed_savagery[372943] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- untamed_savagery[372943] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- untamed_savagery[372943] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- untamed_savagery[372943] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elunes_favored[370588] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elunes_favored[370588] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overpowering_aura[395944] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overpowering_aura[395944] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- arcane_affinity[429540] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_affinity[429540] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lunar_calling[429523] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lunar_calling[429523] #3: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 64, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }
        -- untamed_savagery[372943] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- untamed_savagery[372943] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- untamed_savagery[372943] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- untamed_savagery[372943] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rake[155722] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- incarnation_avatar_of_ashamane[102543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incarnation_avatar_of_ashamane[102543] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_avatar_of_ashamane[102543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- feral_druid[137011] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- feral_druid[137011] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elunes_favored[370588] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elunes_favored[370588] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- guardian_druid[137010] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- circle_of_life_and_death[391969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
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
        -- arcane_affinity[429540] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_affinity[429540] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- berserk[50334] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- berserk[50334] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- circle_of_life_and_death[391969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- circle_of_life_and_death[391969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- convoke_the_spirits[391528] #2: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, }
        -- convoke_the_spirits[391528] #3: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_PCT_MODIFIER, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- incarnation_guardian_of_ursoc[102558] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incarnation_guardian_of_ursoc[102558] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[197625] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[197625] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_light_falling_night_day[417714] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- balance_druid[137013] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_druid[137013] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonkin_form[24858] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moonkin_form[24858] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

} )