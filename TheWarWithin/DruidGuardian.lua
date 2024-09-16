-- DruidGuardian.lua
-- July 2024

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 104 )

spec:RegisterResource( Enum.PowerType.Rage, {
    oakhearts_puny_quods = {
        aura = "oakhearts_puny_quods",

        last = function ()
            local app = state.buff.oakhearts_puny_quods.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 10
    },

    raging_frenzy = {
        aura = "frenzied_regeneration",
        pvptalent = "raging_frenzy",

        last = function ()
            local app = state.buff.frenzied_regeneration.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 10 -- tooltip says 60, meaning this would be 20, but NOPE.
    },

    thrash_bear = {
        aura = "thrash_bear",
        talent = "blood_frenzy",
        debuff = true,

        last = function ()
            return state.debuff.thrash_bear.applied + floor( ( state.query_time - state.debuff.thrash_bear.applied ) / class.auras.thrash_bear.tick_time ) * class.auras.thrash_bear.tick_time
        end,

        interval = function () return class.auras.thrash_bear.tick_time end,
        value = function () return 2 * state.active_dot.thrash_bear end,
    }
} )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    -- Druid
    astral_influence              = { 82210, 197524, 1 }, -- Increases the range of all of your spells by 5 yards.
    cyclone                       = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 6 sec. Only one target can be affected by your Cyclone at a time.
    feline_swiftness              = { 82239, 131768, 1 }, -- Increases your movement speed by 15%.
    fluid_form                    = { 92229, 449193, 1 }, -- Shred and Rake can be used in any form and shift you into Cat Form. Mangle can be used in any form and shifts you into Bear Form. Wrath and Starfire shift you into Moonkin Form, if known.
    forestwalk                    = { 100173, 400129, 1 }, -- Casting Regrowth increases your movement speed and healing received by 8% for 6 sec.
    frenzied_regeneration         = { 82220, 22842 , 1 }, -- Heals you for 20% health over 3 sec, and increases healing received by 20%.
    heart_of_the_wild             = { 82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Cast time of Balance spells reduced by 30% and damage increased by 20%. Feral: Gain 1 Combo Point every 2 sec while in Cat Form and Physical damage increased by 20%. Restoration: Healing increased by 30%, and mana costs reduced by 50%.
    hibernate                     = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin             = { 82219, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_rejuvenation         = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec.
    improved_stampeding_roar      = { 82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    improved_sunfire              = { 93714, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within 8 yards.
    incapacitating_roar           = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 10 yards for 3 sec. Damage will cancel the effect.
    innervate                     = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 8 sec.
    instincts_of_the_claw         = { 100176, 449184, 2 }, -- Shred, Swipe, Rake, Mangle, and Thrash damage increased by 5%.
    ironfur                       = { 82227, 192081, 1 }, -- Increases armor by 14,034 for 7 sec.
    killer_instinct               = { 82225, 108299, 2 }, -- Physical damage and Armor increased by 6%.
    lore_of_the_grove             = { 100175, 449185, 2 }, -- Moonfire and Sunfire damage increased by 10%. Rejuvenation and Wild Growth healing increased by 5%.
    lycaras_teachings             = { 82233, 378988, 2 }, -- You gain 3% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                          = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 4,607 damage, 1 sec 2 points: 9,215 damage, 2 sec 3 points: 13,823 damage, 3 sec 4 points: 18,431 damage, 4 sec 5 points: 23,039 damage, 5 sec
    mass_entanglement             = { 82242, 102359, 1 }, -- Roots the target and all enemies within 12 yards in place for 10 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                    = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 84,904 damage for 8 sec.
    mighty_bash                   = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    natural_recovery              = { 82206, 377796, 1 }, -- Healing you receive is increased by 4%.
    natures_vigil                 = { 82244, 124974, 1 }, -- For 15 sec, all single-target damage also heals a nearby friendly target for 20% of the damage done.
    nurturing_instinct            = { 82214, 33873 , 2 }, -- Magical damage and healing increased by 6%.
    oakskin                       = { 100174, 449191, 1 }, -- Survival Instincts and Barkskin reduce damage taken by an additional 10%.
    primal_fury                   = { 82238, 159286, 1 }, -- While in Cat Form, when you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect. Mangle critical strike damage increased by 20%.
    rake                          = { 82199, 1822  , 1 }, -- Rake the target for 6,203 Bleed damage and an additional 54,898 Bleed damage over 11.3 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    rejuvenation                  = { 82217, 774   , 1 }, -- Heals the target for 54,446 over 10.2 sec.
    remove_corruption             = { 82215, 2782  , 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    renewal                       = { 82232, 108238, 1 }, -- Instantly heals you for 20% of maximum health. Usable in all shapeshift forms.
    rip                           = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 38,999 over 6 sec 2 points: 58,499 over 9 sec 3 points: 77,999 over 12 sec 4 points: 97,499 over 15 sec 5 points: 116,999 over 18 sec
    rising_light_falling_night    = { 82207, 417712, 1 }, -- Increases your damage and healing by 3% during the day. Increases your Versatility by 2% during the night.
    skull_bash                    = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    soothe                        = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar               = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 15 yards by 60% for 8 sec.
    starfire                      = { 91041, 197628, 1 }, -- Call down a burst of energy, causing 24,191 Arcane damage to the target, and 8,255 Arcane damage to all other enemies within 5 yards. Deals reduced damage beyond 8 targets.
    starlight_conduit             = { 100223, 451211, 1 }, -- Wrath, Starsurge, and Starfire damage increased by 5%. Starsurge's cooldown is reduced by 4 sec and its mana cost is reduced by 50%.
    starsurge                     = { 82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing 48,936 Astral damage.
    sunfire                       = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for 5,861 Nature damage and then an additional 61,703 Nature damage over 13.5 sec.
    thick_hide                    = { 82228, 16931 , 1 }, -- Reduces all damage taken by 4%.
    thrash                        = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                    = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    typhoon                       = { 82209, 132469, 1 }, -- Blasts targets within 15 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by 50% for 6 sec. Usable in all shapeshift forms.
    ursine_vigor                  = { 82235, 377842, 1 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 15%.
    ursocs_spirit                 = { 100177, 449182, 1 }, -- Stamina in Bear Form is increased by 10%.
    ursols_vortex                 = { 82242, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart                 = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    wellhoned_instincts           = { 82246, 377847, 1 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 120 sec.
    wild_charge                   = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                   = { 82241, 48438 , 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 43,798 over 6.0 sec. Healing starts high and declines over the duration.

    -- Guardian
    after_the_wildfire            = { 82140, 371905, 1 }, -- Every 200 Rage you spend causes a burst of restorative energy, healing allies within 12 yds for 143,802.
    berserk_persistence           = { 82144, 50334 , 1 }, -- Go berserk for 15 sec, increasing your haste by 15%, reducing the cooldown of Frenzied Regeneration by 100%, Mangle, Thrash, and Growl by 50%, and reducing the cost of Maul and Ironfur by 50%.
    berserk_ravage                = { 82149, 50334 , 1 }, -- Go berserk for 15 sec, increasing your haste by 15%, reducing the cooldown of Frenzied Regeneration by 100%, Mangle, Thrash, and Growl by 50%, and reducing the cost of Maul and Ironfur by 50%.
    berserk_unchecked_aggression  = { 82155, 50334 , 1 }, -- Go berserk for 15 sec, increasing your haste by 15%, reducing the cooldown of Frenzied Regeneration by 100%, Mangle, Thrash, and Growl by 50%, and reducing the cost of Maul and Ironfur by 50%.
    blood_frenzy                  = { 82142, 203962, 1 }, -- Thrash also generates 3 Rage each time it deals damage, on up to 5 targets.
    brambles                      = { 82161, 203953, 1 }, -- Sharp brambles protect you, absorbing and reflecting up to 1,797 damage from each attack. While Barkskin is active, the brambles also deal 1,192 Nature damage to all nearby enemies every 1 sec.
    bristling_fur                 = { 82161, 155835, 1 }, -- Bristle your fur, causing you to generate Rage based on damage taken for 8 sec.
    circle_of_life_and_death      = { 82137, 391969, 1 }, -- Your damage over time effects deal their damage in 25% less time, and your healing over time effects in 15% less time.
    convoke_the_spirits           = { 82136, 391528, 1 }, -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of 16 Druid spells and abilities over 4 sec. You will cast Mangle, Ironfur, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    dream_of_cenarius             = { 92227, 372119, 1 }, -- When you take non-periodic damage, you have a chance equal to your critical strike to cause your next Regrowth to heal for an additional 200%, and to be instant, free, and castable in all forms for 30 sec. This effect cannot occur more than once every 20 sec.
    earthwarden                   = { 82156, 203974, 1 }, -- When you deal direct damage with Thrash, you gain a charge of Earthwarden, reducing the damage of the next auto attack you take by 25%. Earthwarden may have up to 3 charges.
    elunes_favored                = { 82134, 370586, 1 }, -- While in Bear Form, you deal 10% increased Arcane damage, and are healed for 25% of all Arcane damage done.
    flashing_claws                = { 82154, 393427, 2 }, -- Thrash has a 10% chance to trigger an additional Thrash. Thrash stacks 1 additional time.
    fury_of_nature                = { 82138, 370695, 2 }, -- While in Bear Form, you deal 10% increased Arcane damage.
    galactic_guardian             = { 82145, 203964, 1 }, -- Your damage has a 5% chance to trigger a free automatic Moonfire on that target. When this occurs, the next Moonfire you cast generates 8 Rage, and deals 300% increased direct damage.
    gore                          = { 82126, 210706, 1 }, -- Thrash, Swipe, Moonfire, and Maul have a 15% chance to reset the cooldown on Mangle, and to cause it to generate an additional 4 Rage.
    gory_fur                      = { 82132, 200854, 1 }, -- Mangle has a 15% chance to reduce the Rage cost of your next Ironfur by 25%.
    guardian_of_elune             = { 82140, 155578, 1 }, -- Mangle increases the duration of your next Ironfur by 3 sec, or the healing of your next Frenzied Regeneration by 20%.
    improved_survival_instincts   = { 82128, 328767, 1 }, -- Survival Instincts now has 2 charges.
    incarnation                   = { 82136, 102558, 1 }, -- An improved Bear Form that grants the benefits of Berserk, causes Mangle to hit up to 3 targets, and increases maximum health by 30%. Lasts 30 sec. You may freely shapeshift in and out of this improved Bear Form for its duration.
    incarnation_guardian_of_ursoc = { 82136, 102558, 1 }, -- An improved Bear Form that grants the benefits of Berserk, causes Mangle to hit up to 3 targets, and increases maximum health by 30%. Lasts 30 sec. You may freely shapeshift in and out of this improved Bear Form for its duration.
    infected_wounds               = { 82162, 345208, 1 }, -- Mangle and Maul cause an Infected Wound in the target, reducing their movement speed by 50% for 12 sec.
    innate_resolve                = { 82160, 377811, 1 }, -- Frenzied Regeneration's healing is increased by up to 120% based on your missing health. Frenzied Regeneration has 1 additional charge.
    layered_mane                  = { 82148, 384721, 2 }, -- Ironfur has a 10% chance to apply two stacks and Frenzied Regeneration has a 10% chance to not consume a charge.
    lunar_beam                    = { 92587, 204066, 1 }, -- Summons a beam of lunar light at your location, increasing your mastery by 15%, dealing 38,758 Arcane damage, and healing you for 321,119 over 8 sec.
    mangle                        = { 82131, 231064, 1 }, -- Mangle deals 20% additional damage against bleeding targets.
    maul                          = { 82127, 6807  , 1 }, -- Maul the target for 65,376 Physical damage.
    moonless_night                = { 92586, 400278, 1 }, -- Your direct damage melee abilities against enemies afflicted by Moonfire cause them to burn for an additional 20% Arcane damage.
    pulverize                     = { 82153, 80313 , 1 }, -- A devastating blow that consumes 2 stacks of your Thrash on the target to deal 61,749 Physical damage and reduce the damage they deal to you by 35% for 8 sec.
    rage_of_the_sleeper           = { 82141, 200851, 1 }, -- Unleashes the rage of Ursoc for 8 sec, preventing 20% of all damage you take, increasing your damage done by 15%, granting you 20% leech, and reflecting 12,837 Nature damage back at your attackers.
    raze                          = { 92588, 400254, 1 }, -- Strike with the might of Ursoc, dealing 35,165 Physical damage to all enemies in front of you. Deals reduced damage beyond 5 targets.
    reinforced_fur                = { 82139, 393618, 1 }, -- Ironfur increases armor by an additional 15% and Barkskin reduces damage taken by an additional 10%.
    reinvigoration                = { 82157, 372945, 2 }, -- Frenzied Regeneration's cooldown is reduced by 10%.
    rend_and_tear                 = { 82152, 204053, 1 }, -- Each stack of Thrash reduces the target's damage to you by 2% and increases your damage to them by 2%.
    scintillating_moonlight       = { 82146, 238049, 2 }, -- Moonfire reduces damage dealt to you by -1%.
    soul_of_the_forest            = { 92226, 158477, 1 }, -- Mangle generates 5 more Rage and deals 25% more damage.
    survival_instincts            = { 82129, 61336 , 1 }, -- Reduces all damage you take by 50% for 6 sec.
    survival_of_the_fittest       = { 82143, 203965, 2 }, -- Reduces the cooldowns of Barkskin and Survival Instincts by 12%.
    thorns_of_iron                = { 92585, 400222, 1 }, -- When you cast Ironfur, also deal Physical damage equal to 20% of your armor, split among enemies within 12 yards. Damage reduced above 4 applications.
    tooth_and_claw                = { 82133, 135288, 1 }, -- Autoattacks have a 20% chance to empower your next cast of Maul or Raze, stacking up to 2 times. An empowered cast of Maul or Raze deals 40% increased damage, costs 100% less rage, and reduces the target's damage to you by 12% for 6 sec.
    twin_moonfire                 = { 82147, 372567, 1 }, -- Moonfire deals 10% increased damage and also hits another nearby enemy within 15 yds of the target.
    untamed_savagery              = { 82152, 372943, 1 }, -- Increases the damage and radius of Thrash by 25%.
    ursocs_endurance              = { 82130, 393611, 1 }, -- Increases the duration of Barkskin and Ironfur by 2.0 sec.
    ursocs_fury                   = { 82151, 377210, 1 }, -- Thrash and Maul grant you an absorb shield for 25% of the damage dealt for 15 sec.
    ursocs_guidance               = { 82135, 393414, 1 }, -- Incarnation: Guardian of Ursoc: Every 25 Rage you spend reduces the cooldown of Incarnation: Guardian of Ursoc by 1 sec.  Convoke the Spirits: Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    vicious_cycle                 = { 82158, 371999, 1 }, -- Mangle increases the damage of your next cast of Maul or Raze, and casting Maul or Raze increases the damage of your next Mangle by 15%. Stacks up to 3.
    vulnerable_flesh              = { 82159, 372618, 2 }, -- Maul and Raze have an additional 30% chance to critically strike.

    -- Druid of the Claw
    aggravate_wounds              = { 94616, 441829, 1 }, -- Every Maul, Raze, Mangle, Thrash, or Swipe you cast extends the duration of your Dreadful Wounds by 0.6 sec, up to 8 additional sec.
    bestial_strength              = { 94611, 441841, 1 }, -- Maul and Raze damage increased by 10%.
    claw_rampage                  = { 94613, 441835, 1 }, -- During Berserk, Mangle, Swipe, and Thrash have a 25% chance to make your next Maul become Ravage.
    dreadful_wound                = { 94620, 441809, 1 }, -- Ravage also inflicts a Bleed that causes 13,787 damage over 6.0 sec and saps its victims' strength, reducing damage they deal to you by 10%. Dreadful Wound is not affected by Circle of Life and Death.
    empowered_shapeshifting       = { 94612, 441689, 1 }, -- Frenzied Regeneration can be cast in Cat Form for 40 Energy. Bear Form reduces magic damage you take by 4%. Shred and Swipe damage increased by 3%. Mangle damage increased by 10%.
    fount_of_strength             = { 94618, 441675, 1 }, -- Your maximum Energy and Rage are increased by 20. Frenzied Regeneration also increases your maximum health by 10%.
    killing_strikes               = { 94619, 441824, 1 }, -- Ravage increases your Agility by 5% and the armor granted by Ironfur by 20% for 8 sec. Your first Mangle after entering combat makes your next Maul become Ravage.
    packs_endurance               = { 94615, 441844, 1 }, -- Stampeding Roar's duration is increased by 25%.
    ravage                        = { 94609, 441583, 1, "druid_of_the_claw" }, -- Your auto-attacks have a chance to make your next Maul become Ravage. Ravage Slash through your target in a wide arc, dealing 86,493 Physical damage to your target and 43,683 to all other enemies in front of you.
    ruthless_aggression           = { 94619, 441814, 1 }, -- Ravage increases your auto-attack speed by 20% for 6 sec.
    strike_for_the_heart          = { 94614, 441845, 1 }, -- Shred, Swipe, and Mangle's critical strike chance and critical strike damage are increased by 6%. Mangle heals you for 1% of maximum health.
    tear_down_the_mighty          = { 94614, 441846, 1 }, -- The cooldown of Pulverize is reduced by 5 sec.
    wildpower_surge               = { 94612, 441691, 1 }, -- Mangle grants Feline Potential. When you have 6 stacks, the next time you transform into Cat Form, gain 5 combo points and your next Ferocious Bite or Rip deals 100% increased damage for its full duration.
    wildshape_mastery             = { 94610, 441678, 1 }, -- Ironfur and Frenzied Regeneration persist in Cat Form. When transforming from Bear to Cat Form, you retain 80% of your Bear Form armor and health for 6 sec. For 6 sec after entering Bear Form, you heal for 10% of damage taken over 8 sec.

    -- Elune's Chosen
    arcane_affinity               = { 94586, 429540, 1 }, -- All Arcane damage from your spells and abilities is increased by 3%.
    astral_insight                = { 94585, 429536, 1 }, -- Incarnation: Guardian of Ursoc increase Arcane damage from spells and abilities by 10% while active. Increases the duration and number of spells cast by Convoke the Spirits by 25%.
    atmospheric_exposure          = { 94607, 429532, 1 }, -- Enemies damaged by Lunar Beam or Fury of Elune take 6% increased damage from you for 6 sec.
    boundless_moonlight           = { 94608, 424058, 1, "elunes_chosen" }, --  Lunar Beam Lunar Beam now causes you to leech life equal to 10% of all damage dealt to enemies within the beam.  Fury of Elune Fury of Elune now ends with a flash of energy, blasting nearby enemies for 73,265 Astral damage.
    elunes_grace                  = { 94597, 443046, 1 }, -- Using Wild Charge while in Bear Form or Moonkin Form incurs a 3 sec shorter cooldown.
    glistening_fur                = { 94594, 429533, 1 }, -- Bear Form and Moonkin Form reduce Arcane damage taken by 6% and all other magic damage taken by 3%.
    lunar_amplification           = { 94596, 429529, 1 }, -- Each non-Arcane damaging ability you use increases the damage of your next Arcane damaging ability by 3%, stacking up to 3 times.
    lunar_calling                 = { 94590, 429523, 1 }, -- Thrash now deals Arcane damage and its damage is increased by 12%.
    lunar_insight                 = { 94588, 429530, 1 }, -- Moonfire deals 20 additional damage.
    lunation                      = { 94586, 429539, 1 }, -- Your Arcane abilities reduce the cooldown of Lunar Beam by 3.0 sec.
    moon_guardian                 = { 94598, 429520, 1 }, -- Free automatic Moonfires from Galactic Guardian generate 5 Rage.
    moondust                      = { 94597, 429538, 1 }, -- Enemies affected by Moonfire are slowed by 20%.
    stellar_command               = { 94590, 429668, 1 }, -- Increases the damage of Lunar Beam by 30% and Fury of Elune by 15%.
    the_eternal_moon              = { 94587, 424113, 1 }, -- Further increases the power of Boundless Moonlight.  Lunar Beam Lunar Beam increases Mastery by an additional 10%, deals 30% increased damage, and lasts 3 sec longer.  Fury of Elune The flash of energy now generates 6 Rage and its damage is increased by 50%.
    the_light_of_elune            = { 94585, 428655, 1 }, -- Moonfire damage has a chance to call down a Fury of Elune to follow your target for 3 sec.  Fury of Elune Calls down a beam of pure celestial energy, dealing 30,190 Astral damage over 3 sec within its area. Generates 18 Rage over its duration.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_challenge     = 842 , -- (207017)
    charging_bash       = 194 , -- (228431) Increases the range of your Skull Bash by 10 yards.
    demoralizing_roar   = 52  , -- (201664) Demoralizes all enemies within 10 yards, reducing the damage they do by 20% for 8 sec.
    den_mother          = 51  , -- (236180) You bolster nearby allies within 15 yards, increasing their maximum health by 15%. The duration of all stun effects on you is reduced by 15%.
    emerald_slumber     = 197 , -- (329042) Embrace the Emerald Dream, causing you to enter a deep slumber for 8 sec. While sleeping, all other cooldowns recover 400% faster, and allies within 40 yds are healed for 14,380 every 1 sec. Direct damage taken may awaken you.
    entangling_claws    = 195 , -- (202226) Entangling Roots is now an instant cast spell with a 6 second cooldown but with a 10 yard range. It can also be cast while in shapeshift forms.
    freedom_of_the_herd = 3750, -- (213200) Your Stampeding Roar clears all roots and snares from yourself and allies.
    grove_protection    = 5410, -- (354654) Summon a grove to protect allies in the area for 10 sec, reducing damage taken by 50% from enemies outside the grove.
    malornes_swiftness  = 1237, -- (236147) Your Travel Form movement speed while within a Battleground or Arena is increased by 20% and you always move at 100% movement speed while in Travel Form.
    master_shapeshifter = 49  , -- (236144) Your abilities are amplified based on your current shapeshift form, granting an additional effect.  Caster Form Rejuvenation and Swiftmend heal for 30% more and cause you to instantly generate 25 Rage after entering Bear Form.  Moonkin Form Wrath, Starfire, and Starsurge deal 30% additional damage and cause you to instantly generate 25 Rage after entering Bear Form.  Cat Form Rip, Ferocious Bite, and Maim deal 60% additional damage and cause you to instantly generate 50 Rage after entering Bear Form when cast with 5 combo points.
    overrun             = 196 , -- (202246) Charge to an enemy, stunning them for 3 sec and knocking back their allies within 15 yards.
    tireless_pursuit    = 5648, -- (377801) For 3 sec after leaving Cat Form or Travel Form, you retain up to 40% movement speed.
} )


local mod_circle_hot = setfenv( function( x )
    return x * ( legendary.circle_of_life_and_death.enabled and 0.85 or 1 ) * ( talent.circle_of_life_and_death.enabled and 0.85 or 1 )
end, state )

local mod_circle_dot = setfenv( function( x )
    return x * ( legendary.circle_of_life_and_death.enabled and 0.75 or 1 ) * ( talent.circle_of_life_and_death.enabled and 0.75 or 1 )
end, state )


-- Auras
spec:RegisterAuras( {
    after_the_wildfire = {
        id = 400734,
        duration = 3600,
        max_stack = 1
    },
    aquatic_form = {
        id = 276012,
        duration = 3600,
        max_stack = 1,
    },
    -- Armor increased by $w4%.; Stamina increased by $1178s2%.; Immune to Polymorph effects.$?$w13<0[; Arcane damage taken reduced by $w14% and all other magic damage taken reduced by $w13%.][]
    barkskin = {
        id = 22812,
        duration = function() return ( talent.improved_barkskin.enabled and 12 or 8 ) + ( talent.ursocs_endurance.enabled and 2 or 0 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Armor increased by $w4%.  Stamina increased by $1178s2%.  Immune to Polymorph effects.
    -- https://wowhead.com/beta/spell=5487
    bear_form = {
        id = 5487,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap. All attack and ability damage is increased by $s3%.
    berserk = {
        id = 106951,
        duration = 15,
        max_stack = 1,
        copy = 50334
    },
    -- Alias for Berserk vs. Incarnation
    berserk_bear = {
        alias = { "berserk", "incarnation" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
        duration = function () return talent.incarnation.enabled and 30 or 15 end,
    },
    -- Talent: Generating Rage from taking damage.
    -- https://wowhead.com/beta/spell=155835
    bristling_fur = {
        id = 155835,
        duration = 8,
        max_stack = 1
    },
    -- Autoattack damage increased by $w4%.  Immune to Polymorph effects.  Movement speed increased by $113636s1% and falling damage reduced.
    -- https://wowhead.com/beta/spell=768
    cat_form = {
        id = 768,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent / Covenant (Night Fae): Every ${$t1}.2 sec, casting $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred, Tiger's Fury,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake or Thrash on appropriate nearby targets.
    -- https://wowhead.com/beta/spell=323764
    convoke_the_spirits = {
        id = 391528,
        duration = function() return 4 * ( talent.astral_insight.enabled and 1.25 or 1 ) * ( talent.ursocs_guidance.enabled and 0.75 or 1 ) end,
        max_stack = 1,
        copy = 323764
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=200389
    cultivation = {
        id = 200389,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Disoriented and invulnerable.
    -- https://wowhead.com/beta/spell=33786
    cyclone = {
        id = 33786,
        duration = 6,
        mechanic = "banish",
        type = "Magic",
        max_stack = 1
    },
    -- Increased movement speed by $s1% while in Cat Form.
    -- https://wowhead.com/beta/spell=1850
    dash = {
        id = 1850,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    dream_of_cenarius = {
        id = 372152,
        duration = 30,
        max_stack = 1
    },
    earthwarden = {
        id = 203975,
        duration = 3600,
        max_stack = 3
    },
    -- Rooted.$?<$w2>0>[ Suffering $w2 Nature damage every $t2 sec.][]
    -- https://wowhead.com/beta/spell=339
    entangling_roots = {
        id = 339,
        duration = 30,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    feline_potential = {
        id = 441702,
        duration = 15,
        max_stack = 1
    },
    feline_potential_counter = {
        id = 441701,
        duration = 3600,
        max_stack = 6
    },
    -- Bleeding for $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=274838
    feral_frenzy = {
        id = 274838,
        duration = 6,
        max_stack = 1
    },
    flight_form = {
        id = 276029,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases speed and all healing taken by $w1%.
    forestwalk = {
        id = 400126,
        duration = 6.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 damage every $t sec.
    -- https://wowhead.com/beta/spell=391140
    frenzied_assault = {
        id = 391140,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Talent: Healing $w1% health every $t1 sec.
    -- https://wowhead.com/beta/spell=22842
    frenzied_regeneration = {
        id = 22842,
        duration = 3,
        max_stack = 1
    },
    -- Movement speed reduced by $s2%. Suffering $w1 Nature damage every $t1 sec.
    -- https://wowhead.com/beta/spell=81281
    fungal_growth = {
        id = 81281,
        duration = 8,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Generating ${$m3/10/$t3*$d} Astral Power over $d.
    -- https://wowhead.com/beta/spell=202770
    fury_of_elune = {
        id = 202770,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    galactic_guardian = {
        id = 213708,
        duration = 15,
        max_stack = 1,
    },
    gore = {
        id = 93622,
        duration = 10,
        max_stack = 1,
    },
    -- Talent: Reduces the Rage cost of your next Ironfur by $s1%.
    -- https://wowhead.com/beta/spell=201671
    gory_fur = {
        id = 201671,
        duration = 3600,
        max_stack = 1
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=6795
    growl = {
        id = 6795,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    -- Talent: Increases the duration of your next Ironfur by ${$m1/1000} sec, or the healing of your next Frenzied Regeneration by $s2%.
    -- https://wowhead.com/beta/spell=213680
    guardian_of_elune = {
        id = 213680,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Abilities not associated with your specialization are substantially empowered.
    -- https://wowhead.com/beta/spell=319454
    heart_of_the_wild = {
        id = 319454,
        duration = 45,
        tick_time = 2,
        type = "Magic",
        max_stack = 1,
        copy = { 319451, 319452, 319453 }
    },
    -- Talent: Asleep.
    -- https://wowhead.com/beta/spell=2637
    hibernate = {
        id = 2637,
        duration = 40,
        mechanic = "sleep",
        type = "Magic",
        max_stack = 1
    },
    immobilized = {
        id = 45334,
        duration = 4,
        max_stack = 1,
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=99
    incapacitating_roar = {
        id = 99,
        duration = 3,
        mechanic = "incapacitate",
        max_stack = 1
    },
    -- Cooldowns of Mangle, Thrash, Growl, and Frenzied Regeneration are reduced by $w1%.; Ironfur cost reduced by $w3%.; Mangle hits up to $w12 targets.; Health increased by $w13%.$?a429536[; Arcane damage increased by $w14%.][]$?$w7>0[; Immune to effects that cause loss of control of your character.][]
    incarnation = {
        id = 102558,
        duration = 30,
        max_stack = 1,
        copy = "incarnation_guardian_of_ursoc"
    },
    -- Talent: Movement speed slowed by $w1%.
    -- https://wowhead.com/beta/spell=345209
    infected_wounds = {
        id = 345209,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Mana costs reduced $w1%.
    -- https://wowhead.com/beta/spell=29166
    innervate = {
        id = 29166,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    intimidating_roar = {
        id = 236748,
        duration = 3,
        max_stack = 1,
    },
    -- Talent: Armor increased by ${$w1*$AGI/100}.
    -- https://wowhead.com/beta/spell=192081
    ironfur = {
        id = 192081,
        duration = function() return 7 + ( buff.guardian_of_elune.up and 3 or 0 ) + ( talent.ursocs_endurance.enabled and 2 or 0 ) end,
        max_stack = 5,
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
    -- Healing $w1 every $t1 sec.  Blooms for additional healing when effect expires or is dispelled.
    -- https://wowhead.com/beta/spell=33763
    lifebloom = {
        id = 33763,
        duration = 15,
        type = "Magic",
        max_stack = 1,
        copy = 188550
    },
    -- Mastery increased by ${$w2*$mas}%.
    lunar_beam = {
        id = 204066,
        duration = function() return talent.the_eternal_moon.enabled and 11.5 or 8.5 end,
        max_stack = 1,
    },
    -- Talent: Rooted.
    -- https://wowhead.com/beta/spell=102359
    mass_entanglement = {
        id = 102359,
        duration = 10,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=385787
    matted_fur = {
        id = 385787,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=5211
    mighty_bash = {
        id = 5211,
        duration = 4,
        mechanic = "stun",
        max_stack = 1
    },
    -- Suffering $w2 Arcane damage every $t2 seconds.$?$w8<0[; Movement slowed by $w8%.][]
    moonfire = {
        id = 164812,
        duration = function () return mod_circle_dot( 18 ) * haste end,
        tick_time = function () return mod_circle_dot( 2 ) * haste end,
        type = "Magic",
        max_stack = 1,
        copy = 155625
    },
    -- Spell damage increased by $s9%.; Immune to Polymorph effects.$?$w3>0[; Armor increased by $w3%.][]$?$w12<0[; Arcane damage taken reduced by $w13% and all other magic damage taken reduced by $w12%.][]
    moonkin_form = {
        id = 197625,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Dealing $w2% reduced damage to $@auracaster.
    -- https://wowhead.com/beta/spell=80313
    pulverize = {
        id = 80313,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Prevents $s4% of all damage you take and reflects $219432s1 Nature damage back at your attackers.
    -- https://wowhead.com/beta/spell=200851
    rage_of_the_sleeper = {
        id = 200851,
        duration = 8,
        max_stack = 1
    },
    ravage = {
        id = 441602,
        duration = 15,
        max_stack = 1
    },
    -- Heals $w2 every $t2 sec.
    -- https://wowhead.com/beta/spell=8936
    regrowth = {
        id = 8936,
        duration = function () return mod_circle_hot( 12 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Healing $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=774
    rejuvenation = {
        id = 774,
        duration = function () return mod_circle_hot( talent.improved_rejuvenation.enabled and 18 or 15 ) end,
        tick_time = function () return mod_circle_hot( 3 ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Healing $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=155777
    rejuvenation_germination = {
        id = 155777,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Healing $s1 every $t sec.
    -- https://wowhead.com/beta/spell=364686
    renewing_bloom = {
        id = 364686,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Bleeding for $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=1079
    rip = {
        id = 1079,
        duration = 4,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Auto-attack speed increased by $w1%.
    ruthless_aggression = {
        id = 441817,
        duration = 6.0,
        max_stack = 1,
    },
    -- Swipe and Thrash damage increased by $m1%.
    -- https://wowhead.com/beta/spell=279943
    sharpened_claws = {
        id = 279943,
        duration = 6,
        max_stack = 1
    },
    -- Dealing $s1 every $t1 sec.
    -- https://wowhead.com/beta/spell=363830
    sickle_of_the_lion = {
        id = 363830,
        duration = 10,
        tick_time = 1,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Interrupted.
    -- https://wowhead.com/beta/spell=97547
    solar_beam = {
        id = 97547,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=207386
    spring_blossoms = {
        id = 207386,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=77764
    stampeding_roar = {
        id = 77761,
        duration = function() return 8 * ( 1.25 * talent.packs_endurance.rank ) end,
        type = "Magic",
        max_stack = 1,
        copy = { 77764, 106898 }
    },
    -- Suffering $w2 Astral damage every $t2 sec.
    -- https://wowhead.com/beta/spell=202347
    stellar_flare = {
        id = 202347,
        duration = function () return mod_circle_dot( 24 ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 Nature damage every $t2 seconds.
    -- https://wowhead.com/beta/spell=164815
    sunfire = {
        id = 164815,
        duration = function () return mod_circle_dot( 12 ) * haste end,
        tick_time = function () return mod_circle_dot( 2 ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $50322s1%.
    -- https://wowhead.com/beta/spell=61336
    survival_instincts = {
        id = 61336,
        duration = 6,
        max_stack = 1
    },
    -- Bleeding for $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=391356
    tear = {
        id = 391356,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Talent: Bleeding for $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=192090
    thrash_bear = {
        id = 192090,
        duration = function () return mod_circle_dot( 15 ) * haste end,
        tick_time = function () return mod_circle_dot( 3 ) * haste end,
        max_stack = function () return 3 + talent.untamed_savagery.rank end,
        copy = "thrash"
    },
    -- Talent: Increased movement speed by $s1% while in Cat Form, reducing gradually over time.
    -- https://wowhead.com/beta/spell=252216
    tiger_dash = {
        id = 252216,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    tireless_pursuit = {
        id = 393897,
        duration = 3,
        max_stack = 1,
        copy = 340546
    },
    -- Talent: Your next Maul deals $s1% more damage and reduces the target's damage to you by $135601s1%~ for $135601d.
    -- https://wowhead.com/beta/spell=135286
    tooth_and_claw = {
        id = 135286,
        duration = 15,
        max_stack = 2
    },
    -- Talent: Dealing $w1% reduced damage to $@auracaster.
    -- https://wowhead.com/beta/spell=135601
    tooth_and_claw_debuff = {
        id = 135601,
        duration = 6,
        max_stack = 1
    },
    -- Immune to Polymorph effects.  Movement speed increased.
    -- https://wowhead.com/beta/spell=783
    travel_form = {
        id = 783,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Dazed.
    -- https://wowhead.com/beta/spell=61391
    typhoon = {
        id = 61391,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    ursocs_fury = {
        id = 372505,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Movement speed slowed by $s1% and winds impeding movement.
    -- https://wowhead.com/beta/spell=102793
    ursols_vortex = {
        id = 102793,
        duration = 10,
        type = "Magic",
        max_stack = 1,
        copy = 127797
    },
    vicious_cycle_mangle = {
        id = 372019,
        duration = 15,
        max_stack = 1,
    },
    vicious_cycle_maul = {
        id = 372015,
        duration = 15,
        max_stack = 1,
    },
    -- Talent: Flying to an ally's position.
    -- https://wowhead.com/beta/spell=102401
    wild_charge = {
        id = 102401,
        duration = 0.5,
        max_stack = 1
    },
    -- Talent: Heals $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=48438
    wild_growth = {
        id = 48438,
        duration = 7,
        type = "Magic",
        max_stack = 1
    },
    -- You retain $w2% increased armor and $w3% increased Stamina from Bear Form.
    wildshape_mastery = {
        id = 441685,
        duration = 6.0,
        max_stack = 1,
    },

    any_form = {
        alias = { "bear_form", "cat_form", "moonkin_form", "travel_form", "aquatic_form", "stag_form" },
        duration = 3600,
        aliasMode = "first",
        aliasType = "buff",
    },

    -- PvP Talents
    demoralizing_roar = {
        id = 201664,
        duration = 8,
        max_stack = 1,
    },
    den_mother = {
        id = 236181,
        duration = 3600,
        max_stack = 1,
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 1,
    },
    grove_protection_defense = {
        id = 354704,
        duration = 12,
        max_stack = 1,
    },
    grove_protection_offense = {
        id = 354789,
        duration = 12,
        max_stack = 1,
    },
    master_shapeshifter_feral = {
        id = 236188,
        duration = 3600,
        max_stack = 1,
    },
    overrun = {
        id = 202244,
        duration = 3,
        max_stack = 1,
    },
    protector_of_the_pack = {
        id = 201940,
        duration = 3600,
        max_stack = 1,
    },

    -- Azerite
    masterful_instincts = {
        id = 273349,
        duration = 30,
        max_stack = 1,
    },

    -- Conduit
    savage_combatant = {
        id = 340613,
        duration = 15,
        max_stack = 3
    },
    wellhoned_instincts = {
        id = 340556,
        duration = function ()
            if conduit.wellhoned_instincts.enabled then return conduit.wellhoned_instincts.mod end
            return 90
        end,
        max_stack = 1
    },

    -- Legendary
    lycaras_fleeting_glimpse = {
        id = 340060,
        duration = 5,
        max_stack = 1
    },
    ursocs_fury_remembered = {
        id = 345048,
        duration = 15,
        max_stack = 1,
    }
} )

Hekili:EmbedAdaptiveSwarm( spec )

-- Function to remove any form currently active.
spec:RegisterStateFunction( "unshift", function()
    if ( talent.tireless_pursuit.enabled or conduit.tireless_pursuit.enabled ) and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

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

    if form == "cat_form" and buff.feline_potential_counter.stack_pct == 100 then
        applyBuff( "feline_potential" )
        removeBuff( "feline_potential_counter" )
        gain( 5, "combo_points" )
    end
end )

spec:RegisterStateExpr( "ironfur_damage_threshold", function ()
    return ( settings.ironfur_damage_threshold or 0 ) / 100 * ( health.max )
end )


-- Tier 29
spec:RegisterGear( "tier29", 200351, 200353, 200354, 200355, 200356 )
spec:RegisterAura( "bloody_healing", {
    id = 394504,
    duration = 6,
    max_stack = 1,
} )

-- Tier 30
spec:RegisterGear( "tier30", 202518, 202516, 202515, 202514, 202513, 217193, 217195, 217191, 217192, 217194 )
-- 2 pieces (Guardian) : When you take damage, Mangle and Thrash damage and Rage generation are increased by 15% for 8 sec and you heal for 6% of damage taken over 8 sec.
spec:RegisterAura( "furious_regeneration", {
    id = 408504,
    duration = 8,
    max_stack = 1
} )
-- 4 pieces (Guardian) : Raze Raze Maul damage increased by 20% and casting Ironfur or Raze Raze Maul increases your maximum health by 3% for 12 sec, stacking 5 times.
spec:RegisterAura( "indomitable_guardian", {
    id = 408522,
    duration = 12,
    max_stack = 5
} )

spec:RegisterGear( "tier31", 207252, 207253, 207254, 207255, 207257 )
-- (2) Rage you spend during Rage of the Sleeper fuel the growth of Dream Thorns, which wreath you in their protection after Rage of the Sleeper expires, absorbing $425407s2% of damage dealt to you while the thorns remain, up to ${$s2/100*$AP} per $s1 Rage spent.
-- (4) Each $s1 Rage you spend while Rage of the Sleeper is active extends its duration by ${$s4/1000}.1 sec, up to ${$s3/1000}.1. Your Dream Thorns become Blazing Thorns, causing $s2% of damage absorbed to be reflected at the attacker.
spec:RegisterAuras( {
    dream_thorns = {
        id = 425407,
        duration = 45,
        max_stack = 1,
        copy = "blazing_thorns" -- ???
    },

})

-- Gear.
spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )
spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 ) -- Bonuses NYI
spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )

spec:RegisterGear( "ailuro_pouncers", 137024 )
spec:RegisterGear( "behemoth_headdress", 151801 )
spec:RegisterGear( "chatoyant_signet", 137040 )
spec:RegisterGear( "dual_determination", 137041 )
spec:RegisterGear( "ekowraith_creator_of_worlds", 137015 )
spec:RegisterGear( "elizes_everlasting_encasement", 137067 )
spec:RegisterGear( "fiery_red_maimers", 144354 )
spec:RegisterGear( "lady_and_the_child", 144295 )
spec:RegisterGear( "luffa_wrappings", 137056 )
spec:RegisterGear( "oakhearts_puny_quods", 144432 )
    spec:RegisterAura( "oakhearts_puny_quods", {
        id = 236479,
        duration = 3,
        max_stack = 1,
    } )
spec:RegisterGear( "skysecs_hold", 137025 )
    spec:RegisterAura( "skysecs_hold", {
        id = 208218,
        duration = 3,
        max_stack = 1,
    } )

spec:RegisterGear( "the_wildshapers_clutch", 137094 )

spec:RegisterGear( "soul_of_the_archdruid", 151636 )


spec:RegisterStateExpr( "lunar_eclipse", function ()
    return eclipse.wrath_counter
end )

spec:RegisterStateExpr( "solar_eclipse", function ()
    return eclipse.starfire_counter
end )

local LycarasHandler = setfenv( function ()
    if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
    elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
    elseif buff.bear_form.up then state:RunHandler( "barkskin" )
    elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
    else state:RunHandle( "wild_growth" ) end
end, state )

local SinfulHysteriaHandler = setfenv( function ()
    applyBuff( "ravenous_frenzy_sinful_hysteria" )
end, state )

local DreamThornsHandler = setfenv( function ()
    applyBuff( "dream_thorns" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
        applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
    end

    if buff.lycaras_fleeting_glimpse.up then
        state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
    end

    if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
        state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
    end

    if set_bonus.tier31_2pc > 0 and buff.rage_of_the_sleeper.up then
        state:QueueAuraExpiration( "rage_of_the_sleeper", DreamThornsHandler, buff.rage_of_the_sleeper.expires )
    end

    eclipse.reset() -- from Balance.
end )


spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if not a or a.startsCombat then
        break_stealth()
    end

    if buff.ravenous_frenzy.up and ability ~= "ravenous_frenzy" then
        addStack( "ravenous_frenzy", nil, 1 )
    end
end )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" and amt > 0 then
        if talent.after_the_wildfire.enabled and buff.after_the_wildfire.up then
            buff.after_the_wildfire.v1 = buff.after_the_wildfire.v1 - amt
            if buff.after_the_wildfire.v1 < 0 then
                -- Heal ticked.
                buff.after_the_wildfire.v1 = buff.after_the_wildfire.v1 + 200
            end
        end
    end
end )


spec:RegisterStateTable( "druid", setmetatable( {
}, {
    __index = function( t, k )
        if k == "catweave_bear" then return settings.catweave_bear
        elseif k == "owlweave_bear" then return false
        elseif k == "no_cds" then return not toggle.cooldowns
        elseif k == "primal_wrath" then return debuff.rip
        elseif k == "lunar_inspiration" then return debuff.moonfire_cat end

        local fallthru = rawget( debuff, k )
        if fallthru then return fallthru end
    end
} ) )


-- Force reset when Combo Points change, even if recommendations are in progress.
spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( _, _, powerType )
    if powerType == "COMBO_POINTS" then
        Hekili:ForceUpdate( powerType, true )
    end
end )


-- Abilities
spec:RegisterAbilities( {
    alpha_challenge = {
        id = 207017,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "alpha_challenge",

        startsCombat = true,
        texture = 132270,

        handler = function ()
            applyDebuff( "target", "focused_assault" )
        end,
    },

    -- Your skin becomes as tough as bark, reducing all damage you take by $s1% and preventing damage from delaying your spellcasts. Lasts $d.    Usable while stunned, frozen, incapacitated, feared, or asleep, and in all shapeshift forms.
    barkskin = {
        id = 22812,
        cast = 0,
        cooldown = function () return 60 * ( 1 - 0.12 * talent.survival_of_the_fittest.rank ) * ( 1 + ( conduit.tough_as_bark.mod * 0.01 ) ) end,
        gcd = "off",
        school = "nature",

        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        usable = function ()
            if role.tank then
                if not tanking then return false, "player is not tanking right now"
                elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
            end
            return true
        end,

        handler = function ()
            applyBuff( "barkskin" )

            if legendary.the_natural_orders_will.enabled and buff.bear_form.up then
                applyBuff( "ironfur" )
                applyBuff( "frenzied_regeneration" )
            end

            if talent.matted_fur.enabled then applyBuff( "matted_fur" ) end
        end
    },

    -- Shapeshift into Bear Form, increasing armor by $m4% and Stamina by $1178s2%, granting protection from Polymorph effects, and increasing threat generation.    The act of shapeshifting frees you from movement impairing effects.
    bear_form = {
        id = 5487,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function() return -25 * ( buff.furious_regeneration.up and 1.15 or 1 ) end,
        spendType = "rage",

        startsCombat = false,

        essential = true,
        noform = "bear_form",

        handler = function ()
            shift( "bear_form" )
            if talent.ursine_vigor.enabled or conduit.ursine_vigor.enabled then applyBuff( "ursine_vigor" ) end
        end,
    },

    berserk = {
        id = 50334,
        cast = 0,
        cooldown = function () return legendary.legacy_of_the_sleeper.enabled and 150 or 180 end,
        gcd = "off",

        toggle = "cooldowns",
        startsCombat = true,

        notalent = "incarnation",
        usable = function() return talent.berserk_ravage.rank + talent.berserk_unchecked_aggression.rank + talent.berserk_persistence.rank > 0, "requires a berserk talent" end,

        handler = function ()
            applyBuff( "berserk" )
        end,

        copy = "berserk_bear"
    },

    -- Talent: Bristle your fur, causing you to generate Rage based on damage taken for $d.
    bristling_fur = {
        id = 155835,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        school = "nature",

        talent = "bristling_fur",
        startsCombat = false,

        usable = function ()
            if incoming_damage_3s < health.max * 0.1 then return false, "player has not taken 10% health in dmg in 3s" end
            return true
        end,
        handler = function ()
            applyBuff( "bristling_fur" )
        end,
    },

    -- Shapeshift into Cat Form, increasing auto-attack damage by $s4%, movement speed by $113636s1%, granting protection from Polymorph effects, and reducing falling damage.    The act of shapeshifting frees you from movement impairing effects.
    cat_form = {
        id = 768,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        noform = "cat_form",

        handler = function ()
            shift( "cat_form" )

            if pvptalent.master_shapeshifter.enabled and talent.feral_affinity.enabled then
                applyBuff( "master_shapeshifter_feral" )
            end
        end,
    },

    -- Talent: Tosses the enemy target into the air, disorienting them but making them invulnerable for up to $d. Only one target can be affected by your Cyclone at a time.
    cyclone = {
        id = 33786,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.1,
        spendType = "mana",

        talent = "cyclone",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "cyclone" )
        end,
    },

    -- Shift into Cat Form and increase your movement speed by $s1% while in Cat Form for $d.
    dash = {
        id = 1850,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            if buff.cat_form.down then shift( "cat_form" ) end
            applyBuff( "dash" )
        end,
    },


    demoralizing_roar = {
        id = 201664,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        pvptalent = "demoralizing_roar",

        startsCombat = true,
        texture = 132117,

        handler = function ()
            applyDebuff( "demoralizing_roar" )
            active_dot.demoralizing_roar = active_enemies
        end,
    },


    emerald_slumber = {
        id = 329042,
        cast = 8,
        cooldown = 120,
        channeled = true,
        gcd = "spell",

        toggle = "cooldowns",
        pvptalent = "emerald_slumber",

        startsCombat = false,
        texture = 1394953,

        handler = function ()
        end,
    },

    -- Roots the target in place for $d. Damage may cancel the effect.$?s33891[    |C0033AA11Tree of Life: Instant cast.|R][]
    entangling_roots = {
        id = 339,
        cast = function () return pvptalent.entangling_claws.enabled and 0 or 1.7 end,
        cooldown = function () return pvptalent.entangling_claws.enabled and 6 or 0 end,
        gcd = "spell",
        school = "nature",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "entangling_roots" )
        end,
    },

    -- Talent: Heals you for $o1% health over $d$?s301768[, and increases healing received by $301768s1%][].
    frenzied_regeneration = {
        id = 22842,
        cast = 0,
        charges = function () return talent.innate_resolve.enabled and 2 or nil end,
        cooldown = function () return 36 * ( buff.berserk.up and talent.berserk_persistence.enabled and 0 or 1 ) * ( 1 - 0.1 * talent.reinvigoration.rank ) end,
        recharge = function () return talent.innate_resolve.enabled and ( 36 * ( buff.berserk.up and talent.berserk_persistence.enabled and 0 or 1 ) ) or nil end,
        gcd = "spell",
        school = "physical",

        spend = function()
            if talent.empowered_shapeshifting.enabled and buff.cat_form.up then return 40, "energy" end
            return 10, "rage"
        end,

        talent = "frenzied_regeneration",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        form = function()
            if talent.empowered_shapeshifting.enabled and buff.cat_form.up then return "cat_form" end
            return "bear_form"
        end,
        nobuff = "frenzied_regeneration",

        handler = function ()
            applyBuff( "frenzied_regeneration" )
            gain( health.max * 0.08, "health" )
        end,
    },


    grove_protection = {
        id = 354654,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        toggle = "defensives",

        pvptalent = "grove_protection",
        startsCombat = false,
        texture = 4067364,

        handler = function ()
            -- Don't apply auras; position dependent.
        end,
    },

    -- Taunts the target to attack you.
    growl = {
        id = 6795,
        cast = 0,
        cooldown = function () return ( buff.berserk_bear.up and talent.berserk_ravage.enabled and 0 or 8 ) * haste end,
        gcd = "off",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyDebuff( "growl" )
        end,
    },

    -- Talent: Abilities not associated with your specialization are substantially empowered for $d.$?!s137013[    |cFFFFFFFFBalance:|r Magical damage increased by $s1%.][]$?!s137011[    |cFFFFFFFFFeral:|r Physical damage increased by $s4%.][]$?!s137010[    |cFFFFFFFFGuardian:|r Bear Form gives an additional $s7% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has ${$s9+1} charges.][]$?!s137012[    |cFFFFFFFFRestoration:|r Healing increased by $s10%, and mana costs reduced by $s12%.][]
    heart_of_the_wild = {
        id = 319454,
        cast = 0,
        cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
        gcd = "spell",
        school = "nature",

        talent = "heart_of_the_wild",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "heart_of_the_wild" )
        end,
    },

    -- Talent: Forces the enemy target to sleep for up to $d.  Any damage will awaken the target.  Only one target can be forced to hibernate at a time.  Only works on Beasts and Dragonkin.
    hibernate = {
        id = 2637,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.06,
        spendType = "mana",

        talent = "hibernate",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hibernate" )
        end,
    },

    -- Talent: Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within $A1 yards for $d. Damage will cancel the effect.
    incapacitating_roar = {
        id = 99,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "incapacitating_roar",
        startsCombat = true,

        handler = function ()
            if buff.bear_form.down then shift( "bear_form" ) end
            applyDebuff( "target", "incapacitating_roar" )
        end,
    },

    -- An improved Bear Form that grants the benefits of Berserk, causes Mangle to hit up to $s12 targets, $?a429536[increases Arcane damage by $s14%, ][]and increases maximum health by $s13%.$?a339062[; Grants immunity to effects that cause loss of control of your character.][]; Lasts $d. You may freely shapeshift in and out of this improved Bear Form for its duration.
    incarnation = {
        id = 102558,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        toggle = "cooldowns",

        startsCombat = false,
        talent = "incarnation",

        handler = function ()
            applyBuff( "incarnation" )
        end,

        copy = { "incarnation_guardian_of_ursoc", "Incarnation" }
    },

    -- Talent: Infuse a friendly healer with energy, allowing them to cast spells without spending mana for $d.$?s326228[    If cast on somebody else, you gain the effect at $326228s1% effectiveness.][]
    innervate = {
        id = 29166,
        cast = 0,
        cooldown = 180,
        gcd = "off",
        school = "nature",

        talent = "innervate",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "innervate" )
        end,
    },

    -- Talent: Increases armor by ${$s1*$AGI/100} for $d.$?a231070[ Multiple uses of this ability may overlap.][]
    ironfur = {
        id = 192081,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",
        icd = function() return 7 / ( max_ironfur or 1 ) end,
        school = "nature",

        spend = function () return ( buff.berserk_bear.up and talent.berserk_persistence.enabled and 20 or 40 ) * ( buff.gory_fur.up and 0.85 or 1 ) end,
        spendType = "rage",

        talent = "ironfur",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        form = "bear_form",
        cycle = function()
            if talent.tooth_and_claw.enabled then return "tooth_and_claw" end
        end,

        usable = function ()
            -- allow offensive ironfur with specific talents
            if talent.thorns_of_iron.enabled and talent.reinforced_fur.enabled then return true end
            if settings.ironfur_damage_threshold > 0 and incoming_damage_5s < health.max * settings.ironfur_damage_threshold * 0.01 * ( solo and 0.5 or 1 ) then return false, "player has not taken preferred damage in 5s" end
            return true
        end,

        handler = function ()
            applyBuff( "ironfur" )
            removeBuff( "gory_fur" )
            removeBuff( "guardian_of_elune" )
            if set_bonus.tier30_4pc > 0 then addStack( "indomitable_guardian" ) end
        end,
    },

    -- Summons a beam of lunar light at your location, increasing your mastery by ${$s2*$mas}%, dealing ${$414613s1*$s1} Arcane damage, and healing you for ${$204069s1*$s1} over $m1 sec.
    lunar_beam = {
        id = 204066,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "lunar_beam",
        startsCombat = false,
        texture = 136057,

        handler = function()
            applyBuff( "lunar_beam" )
        end,
    },

    -- Talent: Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point:       1 point  : ${$s2*1} damage, 1 sec     2 points: ${$s2*2} damage, 2 sec     3 points: ${$s2*3} damage, 3 sec     4 points: ${$s2*4} damage, 4 sec     5 points: ${$s2*5} damage, 5 sec
    maim = {
        id = 22570,
        cast = 0,
        cooldown = 20,
        gcd = "totem",
        school = "physical",

        spend = 30,
        spendType = "energy",

        talent = "maim",
        startsCombat = true,

        form = "cat_form",

        usable = function () return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyDebuff( "target", "maim", combo_points.current )
            spend( combo_points.current, "combo_points" )
        end,
    },

    -- Talent: Mangle the target for $s2 Physical damage.$?a231064[ Deals $s3% additional damage against bleeding targets.][]    |cFFFFFFFFGenerates ${$m4/10} Rage.|r
    mangle = {
        id = 33917,
        cast = 0,
        cooldown = function () return ( buff.berserk_bear.up and talent.berserk_ravage.enabled and 0 or 6 ) * haste end,
        gcd = "spell",
        school = "physical",

        spend = function() return ( -10 - ( buff.gore.up and 4 or 0 ) - ( 5 * talent.soul_of_the_forest.rank ) ) * ( buff.furious_regeneration.up and 1.15 or 1 ) end,
        spendType = "rage",

        startsCombat = true,
        form = function()
            if talent.fluid_form.enabled then return end
            return "bear_form"
        end,

        handler = function ()
            if talent.fluid_form.enabled and buff.bear_form.down then shift( "bear_form" ) end
            if talent.wildpower_surge.enabled then addStack( "feline_potential_counter" ) end

            removeBuff( "vicious_cycle_mangle" )
            addStack( "vicious_cycle_maul" )
            if talent.guardian_of_elune.enabled then applyBuff( "guardian_of_elune" ) end

            if buff.gore.up then
                gain( 4, "rage" )
                removeBuff( "gore" )

                if set_bonus.tier29_4pc > 0 then applyBuff( "bloody_healing" ) end
            end

            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end
            if conduit.savage_combatant.enabled then addStack( "savage_combatant", nil, 1 ) end
        end,
    },

    -- Talent: Roots the target and all enemies within $A1 yards in place for $d. Damage may interrupt the effect. Usable in all shapeshift forms.
    mass_entanglement = {
        id = 102359,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "mass_entanglement",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mass_entanglement" )
        end,
    },

    -- Talent: Maul the target for $s2 Physical damage.
    maul = {
        id = function() return buff.ravage.up and 441605 or 6807 end,
        known = 6807,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function()
            if buff.tooth_and_claw.up then return 0 end
            return buff.berserk_bear.up and talent.berserk_unchecked_aggression.enabled and 20 or 40
        end,
        spendType = "rage",

        talent = "maul",
        startsCombat = true,
        texture = function() return buff.ravage.up and 5927623 or 132136 end,
        form = "bear_form",

        usable = function ()
            if action.maul.spend > 0 and ( settings.maul_rage or 0 ) > 0 and rage.current - action.maul.spend < ( settings.maul_rage or 0 ) then return false, "not enough additional rage" end
            return true
        end,

        handler = function ()
            addStack( "vicious_cycle_mangle" )
            removeBuff( "savage_combatant" )
            removeBuff( "vicious_cycle_maul" )
            removeBuff( "ravage" )

            if buff.tooth_and_claw.up then
                removeStack( "tooth_and_claw" )
                applyDebuff( "target", "tooth_and_claw_debuff" )
            end
            if set_bonus.tier30_4pc > 0 then addStack( "indomitable_guardian" ) end
            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end
            if talent.ursocs_fury.enabled then applyBuff( "ursocs_fury" ) end
            if pvptalent.sharpened_claws.enabled or essence.conflict_and_strife.major then applyBuff( "sharpened_claws" ) end
        end,

        copy = { 6807, "ravage", 441605}
    },

    -- Talent: Invokes the spirit of Ursoc to stun the target for $d. Usable in all shapeshift forms.
    mighty_bash = {
        id = 5211,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "physical",

        talent = "mighty_bash",
        startsCombat = true,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "mighty_bash" )
        end,
    },

    -- A quick beam of lunar light burns the enemy for $164812s1 Arcane damage and then an additional $164812o2 Arcane damage over $164812d$?s238049[, and causes enemies to deal $238049s1% less damage to you.][.]$?a372567[    Hits a second target within $279620s1 yds of the first.][]$?s197911[    |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r][]
    moonfire = {
        id = 8921,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "moonfire" )

            if buff.galactic_guardian.up then
                gain( 8, "rage" )
                removeBuff( "galactic_guardian" )
            end

            if talent.twin_moonfire.enabled then
                active_dot.moonfire = min( true_active_enemies, active_dot.moonfire + 1 )
            end
        end,

        copy = 155625
    },

    -- Talent: Shapeshift into $?s114301[Astral Form][Moonkin Form], increasing your armor by $m3%, and granting protection from Polymorph effects.    The act of shapeshifting frees you from movement impairing effects.
    moonkin_form = {
        id = 197625,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        talent = "moonkin_form",
        startsCombat = false,
        noform = "moonkin_form",

        handler = function ()
            shift( "moonkin_form" )
        end,
    },


    overrun = {
        id = 202246,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        startsCombat = true,
        texture = 1408833,

        pvptalent = "overrun",

        handler = function ()
            applyDebuff( "target", "overrun" )
            setDistance( 5 )
        end,
    },

    -- Talent: A devastating blow that consumes $s3 stacks of your Thrash on the target to deal $s1 Physical damage and reduce the damage they deal to you by $s2% for $d.
    pulverize = {
        id = 80313,
        cast = 0,
        cooldown = function() return 45 - 5 * talent.tear_down_the_mighty.rank end,
        gcd = "spell",
        school = "physical",

        talent = "pulverize",
        startsCombat = true,

        form = "bear_form",

        usable = function ()
            if debuff.thrash_bear.stack < 2 then return false, "target has fewer than 2 thrash stacks" end
            return true
        end,

        cycle = "thrash_bear",
        cycle_to = true,

        handler = function ()
            if debuff.thrash_bear.count > 2 then debuff.thrash_bear.count = debuff.thrash_bear.count - 2
            else removeDebuff( "target", "thrash_bear" ) end
            applyBuff( "pulverize" )
        end,
    },

    -- Talent: Unleashes the rage of Ursoc for $d, preventing $s4% of all damage you take and reflecting $219432s1 Nature damage back at your attackers.
    rage_of_the_sleeper = {
        id = 200851,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "physical",

        talent = "rage_of_the_sleeper",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "rage_of_the_sleeper" )
            if set_bonus.tier31_2pc > 0 then
                state:QueueAuraExpiration( "rage_of_the_sleeper", DreamThornsHandler, buff.rage_of_the_sleeper.expires )
            end
        end,
    },

    -- Talent: Maul the target for $s2 Physical damage.
    raze = {
        id = 400254,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function()
            if buff.tooth_and_claw.up then return 0 end
            return buff.berserk_bear.up and talent.berserk_unchecked_aggression.enabled and 20 or 40
        end,
        spendType = "rage",

        talent = "raze",
        startsCombat = true,
        form = "bear_form",

        usable = function ()
            if action.raze.spend > 0 and ( settings.maul_rage or 0 ) > 0 and rage.current - action.raze.spend < ( settings.maul_rage or 0 ) then return false, "not enough additional rage" end
            return true
        end,

        handler = function ()
            addStack( "vicious_cycle_mangle" )
            removeBuff( "savage_combatant" )
            removeBuff( "vicious_cycle_maul" )
            if buff.tooth_and_claw.up then
                removeStack( "tooth_and_claw" )
                applyDebuff( "target", "tooth_and_claw_debuff" )
            end
            if set_bonus.tier30_4pc > 0 then addStack( "indomitable_guardian" ) end
            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end
            if talent.ursocs_fury.enabled then applyBuff( "ursocs_fury" ) end
            if pvptalent.sharpened_claws.enabled or essence.conflict_and_strife.major then applyBuff( "sharpened_claws" ) end
        end,
    },

    -- Heals a friendly target for $s1 and another ${$o2*$<mult>} over $d.$?s231032[ Initial heal has a $231032s1% increased chance for a critical effect if the target is already affected by Regrowth.][]$?s24858|s197625[ Usable while in Moonkin Form.][]$?s33891[    |C0033AA11Tree of Life: Instant cast.|R][]
    regrowth = {
        id = 8936,
        cast = function() return buff.dream_of_cenarius.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return buff.dream_of_cenarius.up and 0 or 0.10 end,
        spendType = "mana",

        startsCombat = false,
        usable = function() return buff.dream_of_cenarius.up or buff.any_form.down, "not used in form without dream_of_cenarius" end,

        handler = function ()
            applyBuff( "regrowth" )
            removeBuff( "dream_of_cenarius" )
            removeBuff( "protector_of_the_pack" )
            if talent.forestwalk.enabled then applyBuff( "forestwalk" ) end
        end,
    },

    -- Talent: Heals the target for $o1 over $d.$?s155675[    You can apply Rejuvenation twice to the same target.][]$?s33891[    |C0033AA11Tree of Life: Healing increased by $5420s5% and Mana cost reduced by $5420s4%.|R][]
    rejuvenation = {
        id = 774,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.05,
        spendType = "mana",

        talent = "rejuvenation",
        startsCombat = false,

        usable = function ()
            if not ( buff.bear_form.down and buff.cat_form.down and buff.travel_form.down and buff.moonkin_form.down ) then return false, "player is in a form" end
            return true
        end,

        handler = function ()
            applyBuff( "rejuvenation" )
        end,
    },

    -- Talent: Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    remove_corruption = {
        id = 2782,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "arcane",

        spend = 0.10,
        spendType = "mana",

        talent = "remove_corruption",
        startsCombat = false,

        usable = function ()
            if buff.dispellable_poison.down and buff.dispellable_curse.down then return false, "player has no dispellable auras" end
            return true
        end,
        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_curse" )
        end,
    },

    -- Talent: Instantly heals you for $s1% of maximum health. Usable in all shapeshift forms.
    renewal = {
        id = 108238,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "nature",

        talent = "renewal",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        handler = function ()
            gain( 0.2 * health.max, "health" )
        end,
    },

    -- Talent: You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for $93985d.
    skull_bash = {
        id = 106839,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "skull_bash",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },

    -- Talent: Soothes the target, dispelling all enrage effects.
    soothe = {
        id = 2908,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "nature",

        spend = 0.056,
        spendType = "mana",

        talent = "soothe",
        startsCombat = true,

        debuff = "dispellable_enrage",

        handler = function ()
            removeDebuff( "target", "dispellable_enrage" )
        end,
    },

    -- Talent: Let loose a wild roar, increasing the movement speed of all friendly players within $A1 yards by $s1% for $d.
    stampeding_roar = {
        id = 106898,
        cast = 0,
        cooldown = function () return 120 - ( talent.improved_stampeding_roar.enabled and 60 or 0 ) end,
        gcd = "spell",
        school = "physical",

        talent = "stampeding_roar",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "stampeding_roar" )
            if buff.bear_form.down and buff.cat_form.down then
                shift( "bear_form" )
            end
        end,

        copy = { 77761, 77764 }
    },

    -- Talent: A quick beam of solar light burns the enemy for $164815s1 Nature damage and then an additional $164815o2 Nature damage over $164815d$?s231050[ to the primary target and all enemies within $164815A2 yards][].$?s137013[    |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r][]
    sunfire = {
        id = 93402,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.12,
        spendType = "mana",

        talent = "sunfire",
        startsCombat = true,

        usable = function() return buff.moonkin_form.up or buff.any_form.down, "requires moonkin_form or no form" end,

        handler = function ()
            applyDebuff( "target", "sunfire" )
            active_dot.sunfire = active_enemies
        end,
    },

    -- Talent: Reduces all damage you take by $50322s1% for $50322d.
    survival_instincts = {
        id = 61336,
        cast = 0,
        charges = function() return talent.improved_survival_instincts.enabled and 2 or nil end,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( 1 - 0.12 * talent.survival_of_the_fittest.rank ) * 180 end,
        recharge = function () return talent.improved_survival_instincts.enabled and ( ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( 1 - 0.12 * talent.survival_of_the_fittest.rank ) * 180 ) or nil end,
        gcd = "off",
        school = "physical",

        talent = "survival_instincts",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        usable = function ()
            if not tanking then return false, "player is not tanking right now"
            elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
            return true
        end,

        handler = function ()
            applyBuff( "survival_instincts" )
            if talent.matted_fur.enabled then applyBuff( "matted_fur" ) end
            if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
                applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
            end
        end,
    },

    -- Talent: Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for $s1.$?a383192[    Swiftmend heals the target for $383193o1 over $383193d.][]
    swiftmend = {
        id = 18562,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "nature",

        spend = 0.10,
        spendType = "mana",

        talent = "swiftmend",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        usable = function ()
            return IsSpellUsable( 18562 ) or buff.regrowth.up or buff.wild_growth.up or buff.rejuvenation.up, "requires a hot"
        end,

        handler = function ()
            unshift()
            if buff.regrowth.up then removeBuff( "regrowth" )
            elseif buff.wild_growth.up then removeBuff( "wild_growth" )
            elseif buff.rejuvenation.up then removeBuff( "rejuvenation" ) end
        end,
    },

    -- Talent: Swipe nearby enemies, inflicting Physical damage. Damage varies by shapeshift form.$?s137011[    |cFFFFFFFFAwards $s1 combo $lpoint:points;.|r][]
    swipe_bear = {
        id = 213771,
        known = 213764,
        suffix = "(Bear)",
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        startsCombat = true,

        handler = function ()
        end,

        form = "bear_form",

        copy = { "swipe", 213764 },
        bind = { "swipe_bear", "swipe_cat", "swipe" }
    },

    -- Strikes all nearby enemies, dealing $s1 $?a429523[Arcane][Bleed] damage and an additional $192090o1 $?a429523[Arcane][Bleed] damage over $192090d. When applied from Bear Form, this effect can stack up to $192090u times.; Generates ${$m2/10} Rage.
    thrash_bear = {
        id = 77758,
        known = 106832,
        suffix = "(Bear)",
        cast = 0,
        cooldown = function () return ( buff.berserk_bear.up and talent.berserk_ravage.enabled and 0 or 6 ) * haste end,
        gcd = "spell",
        school = "physical",

        spend = function() return -5 * ( buff.furious_regeneration.up and 1.15 or 1 ) end,
        spendType = "rage",

        talent = "thrash",
        startsCombat = true,

        form = "bear_form",
        bind = "thrash",

        handler = function ()
            applyDebuff( "target", "thrash_bear", 15, debuff.thrash_bear.count + 1 )
            active_dot.thrash_bear = active_enemies

            if talent.ursocs_fury.enabled then applyBuff( "ursocs_fury" ) end
            if legendary.ursocs_fury_remembered.enabled then
                applyBuff( "ursocs_fury_remembered" )
            end

            if talent.earthwarden.enabled then addStack( "earthwarden", nil, 1 ) end
        end,
    },

    -- Talent: Shift into Cat Form and increase your movement speed by $s1%, reducing gradually over $d.
    tiger_dash = {
        id = 252216,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "physical",

        talent = "tiger_dash",
        startsCombat = false,

        handler = function ()
            if not buff.cat_form.up then shift( "cat_form" ) end
            applyBuff( "tiger_dash" )
        end,
    },

    -- Shapeshift into a travel form appropriate to your current location, increasing movement speed on land, in water, or in the air, and granting protection from Polymorph effects.    The act of shapeshifting frees you from movement impairing effects.$?a159456[    Land speed increased when used out of combat. This effect is disabled in battlegrounds and arenas.][]
    travel_form = {
        id = 783,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        handler = function ()
            applyBuff( "travel_form" )
        end,
    },

    -- Talent: Conjures a vortex of wind for $d at the destination, reducing the movement speed of all enemies within $A1 yards by $s1%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center.  Usable in all shapeshift forms.
    ursols_vortex = {
        id = 102793,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "nature",

        talent = "ursols_vortex",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "ursols_vortex" )
        end,
    },

    -- Talent: Bound backward away from your enemies.
    wild_charge = {
        id = function ()
            if buff.bear_form.up then return 16979
            elseif buff.cat_form.up then return 49376
            elseif buff.moonkin_form.up then return 102383 end
            return 102401
        end,
        known = 102401,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "wild_charge",
        startsCombat = true,

        usable = function () return target.exists and target.minR > 7, "target must be 8+ yards away" end,

        handler = function ()
            if buff.bear_form.up then target.distance = 5; applyDebuff( "target", "immobilized" )
            elseif buff.cat_form.up then target.distance = 5; applyDebuff( "target", "dazed" ) end
        end,

        copy = { 49376, 16979, 102401, 102383 }
    },

    -- Talent: Heals up to $s2 injured allies within $A1 yards of the target for $o1 over $d. Healing starts high and declines over the duration.$?s33891[    |C0033AA11Tree of Life: Affects $33891s3 additional $ltarget:targets;.|R][]
    wild_growth = {
        id = 48438,
        cast = 1.5,
        cooldown = 10,
        gcd = "spell",
        school = "nature",

        spend = 0.15,
        spendType = "mana",

        talent = "wild_growth",
        startsCombat = false,

        handler = function ()
            applyBuff( "wild_growth" )
        end,
    },
} )


spec:RegisterRanges( "shred", "rake", "skull_bash", "wild_charge", "growl", "entangling_roots", "moonfire" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageExpiration = 6,

    potion = "spectral_agility",

    package = "Guardian",
} )

spec:RegisterSetting( "maul_rage", 20, {
    name = strformat( "%s (or %s) Rage Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.maul.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.raze.id ) ),
    desc = strformat( "If set above zero, %s and %s can be recommended only if you'll still have this much Rage after use.\n\n"
        .. "This option helps to ensure that %s or %s are available if needed.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.maul.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.raze.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.ironfur.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.frenzied_regeneration.id ) ),
    type = "range",
    min = 0,
    max = 60,
    step = 0.1,
    width = "full"
} )

spec:RegisterSetting( "maul_anyway", true, {
    name = strformat( "Use %s and %s in %s Build", Hekili:GetSpellLinkWithTexture( spec.abilities.maul.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.raze.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.ironfur.id ) ),
    desc = strformat( "If checked, %s and %s are recommended more frequently even if you have talented %s or %s.\n\n"
        .. "This differs from the default SimulationCraft priority as of February 2023.", Hekili:GetSpellLinkWithTexture( spec.abilities.maul.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.raze.id ), Hekili:GetSpellLinkWithTexture( spec.talents.layered_mane[2] ), Hekili:GetSpellLinkWithTexture( spec.talents.reinforced_fur[2] ) ),
    type = "toggle",
    width = "full",
} )

--[[ spec:RegisterSetting( "mangle_more", false, {
    name = "Use |T132135:0|t Mangle More in Multi-Target",
    desc = "If checked, the default priority will recommend |T132135:0|t Mangle more often in |cFFFFD100multi-target|r scenarios.\n\nThis will generate roughly 15% more Rage and allow for more mitigation (or |T132136:0|t Maul) than otherwise, " ..
        "funnel slightly more damage into your primary target, but will |T134296:0|t Swipe less often, dealing less damage/threat to your secondary targets.",
    type = "toggle",
    width = "full",
} ) ]]

spec:RegisterSetting( "vigil_damage", 50, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( class.specs[ 102 ].abilities.natures_vigil.id ) ),
    desc = strformat( "If set below 100%%, %s may only be recommended if your health has dropped below the specified percentage.\n\n"
        .. "By default, |W%s|w also requires the |cFFFFD100Defensives|r toggle to be active.", class.specs[ 102 ].abilities.natures_vigil.name, class.specs[ 102 ].abilities.natures_vigil.name ),
    type = "range",
    min = 1,
    max = 100,
    step = 1,
    width = "full"
} )

spec:RegisterSetting( "ironfur_damage_threshold", 5, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.ironfur.id ) ),
    desc = strformat( "If set above zero, %s will not be recommended for mitigation purposes unless you've taken this much damage in the past 5 seconds (as a percentage "
        .. "of your total health).\n\n"
        .. "This value is halved when playing solo.\n\n"
        .. "Taking %s and %s will result in |W%s|w recommendations for offensive purposes.", Hekili:GetSpellLinkWithTexture( spec.abilities.ironfur.id ),
        Hekili:GetSpellLinkWithTexture( spec.talents.thorns_of_iron[2] ), Hekili:GetSpellLinkWithTexture( spec.talents.reinforced_fur[2] ), spec.abilities.ironfur.name ),
    type = "range",
    min = 0,
    max = 200,
    step = 0.1,
    width = "full"
} )

spec:RegisterSetting( "max_ironfur", 1, {
    name = strformat( "%s Maximum Stacks", Hekili:GetSpellLinkWithTexture( spec.abilities.ironfur.id ) ),
    desc = strformat( "When set above zero, %s will not be recommended for mitigation purposes if you already have this many stacks.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.ironfur.id ) ),
    type = "range",
    min = 1,
    max = 14,
    step = 1,
    width = "full"
} )

    spec:RegisterStateExpr( "max_ironfur", function()
        return settings.max_ironfur or 1
    end )

--[[ spec:RegisterSetting( "shift_for_convoke", false, {
    name = "|T3636839:0|t Powershift for Convoke the Spirits",
    desc = "If checked, the addon will recommend swapping to Cat Form before using |T3636839:0|t Convoke the Spirits.\n\n" ..
        "This is a DPS gain unless you die horribly.",
    type = "toggle",
    width = "full"
} ) ]]

spec:RegisterSetting( "catweave_bear", false, {
    name = strformat( "Weave %s and %s", Hekili:GetSpellLinkWithTexture( spec.abilities.cat_form.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.bear_form.id ) ),
    desc = strformat( "If checked, shifting between %s and %s may be recommended based on whether you're actively tanking and other conditions.  These swaps may occur "
        .. "very frequently.\n\n"
        .. "If unchecked, |W%s|w and |W%s|w abilities will be recommended based on your selected form, but swapping between forms will not be recommended.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.cat_form.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.bear_form.id ),
        spec.abilities.cat_form.name, spec.abilities.bear_form.name ),
    type = "toggle",
    width = "full",
} )

--[[ Retired 2023-02-21
spec:RegisterSetting( "owlweave_bear", false, {
    name = "|T136036:0|t Attempt Owlweaving (Experimental)",
    desc = "If checked, the addon will use the experimental |cFFFFD100owlweave|r priority included in the default priority pack.",
    type = "toggle",
    width = "full"
} ) ]]


spec:RegisterPack( "Guardian", 20240915, [[Hekili:vZ1wpkoow4Fl8cc6PA6KauxgvWdZkTRM(HEFGrAEdWemqufsqjovTvju(TVhBNlo(sIHQ6lJ0OPBsSp(C97CS9PZs3L)1YfBre8YV554nX5b3PJCN68WKBxUG86j8YfNq(pH2d)Li0r4))FYqjBdqr0x8AymAlLaPXzj(WlpqiNs)9V8L9bKdzBg5hF8lPbhZcrKG4i)e0oc93(Fz5InzbHK)mA5gDR(0XUlxGYihItwUyrWX)fq5GTBX8HJt9xUGo8p78WNDN(75R)dmkjF9)oo5y(64OWxZxhSlFDuC(6DSNfKMVg5tcEgN)18VYN69F2BYn5RP)jLe0vjFD2jkZupO7(S3y4L)1bC(6)MUg)niybGShgKssPs(XasWEM4b)6BmTjocTjeVD5FSCHFsabNeGaDjk6PGO95R7NVUx(6NrWtHrnky3kQQyl7fbrGgdg1QTOJGkF1uGVNdpojoAxws5tjhsWPhIlMZMSD7gvmIrj4JOGiywpMVEC(6pLV(akfeiLbMsaRkBytbnTpJ)xu8YLeWAyuqoGrHKdJo5tyt)wH5NG3Ne)c5aLaJVoceHFbfsN)eR0KTqRDaXElaVDfWvazt42iGYtVgkF302mqoJC5kB(KoI(F18XguYtPazPl9TgxAMXjnl55GNrHRatibwks6OTXVevB9kPv9JLvaoTZMEtnYNQloWXeGZGyR2DTzSwc6zyLgLDIXa8GTvGE)yaMV4U1l1ruwy7ozdYxtqH4iYiGvtiRI3bE94vVabkJkMqzKuX4scov)MH5RpF2ssW4(D4WGi8QtXeycbGsWpolc4LY4KzGQvRGrJZQfmLvsxKqLwigI2csWkQsQgFff4QuBoO8)OIBGFLpkbLShtgrcocGcXR2gG5AAVknamNe8okCbD5TysdnjL3vmzMgfajELkMriswcwrV)Ra)orY)WildQ)x9dbAZwNuQJERWpn4VcEEBmWGhsqPhwrnEIORnuBHWiOHL(HOxsHqMiURLhNqMPYeBOIBxuzSSkPjHevjL(OceYEOt)yi3eaqbSgG9uenKgIXNWczOaB49cOKjqc1qkZuKaQdOsXye9yT3rjq5lcZIGXdt6OirHrDVfqq0a5tXVGtwbyK7XQOh(isJ4vTqkSxw4M3RlAxZ5(Xrph)eMRdpfaShfx(BpikDBWjP4KNKenxhXXai6OKiEsqPXzgzVkqMx7qnjwTVOkqQ5nljn2VoLuL5V9Xl6iqtBvOAkSUmbI7aZjmpqN6rXMXeNsKXADPgvLoOjlKfQPspZuye)GyflhT8QjeGQjeJztBn1QEXQsG7w3muX3dICzRR5Y(SOkbaJYtTkbxZyXLYcjoMCyfkAldkReYBEfMOUbjwQmmSFlF9E)T0sIkv5AkrNJY2z9njO3Wmo3mEPcbMjLRGJy5JcPGIQWcsaZUYWLYL0lS0Gx6wSonsHvPN0wfkECLh4uNYHvfPFcLLIxXxZAfRrDOtJ1rxwIs)XQf9bN2PxbQ6)aem91B4ENrxLAYjg7WXLLbHAZN160YJf9d1n4kSjdiQxg(P3pnw3oVl3sJAzzt0TgqPBkb2I5EyFu6jQRB3u1os(Jqf3AOOL60HnYmiCAcUMlZ6JY7UNDS4pk15)mzhZgWh6mhS9fb3x)2Oln8xLYOhFJp0tbOXg0eeND4Ky)G4S0vBaEND(do)4KQETiy9Ar2KQB9dJFUkTSjvlO2z6tZ7KOtONNd42gEYrATFcN9YyTIZCDE3mueLYLkRiZZCDXmUyFCsBvN66ErLjBY(iF6spwE6s2UPWJOO9HCbYCb3TvIYatAtrFnnvrP)4wKk0(QnLd1yWmx8VDff8iTWAp7TfvN0xpdrCLinONWJKpRkJbCvN4swWwo1uSPPhsWSZl0Z8Ug(jjYVhXIQNysvhhOJ8AAbPfIcmx9CBapnpEJVlBIur1vTpprqR3mDgQ)4ym5ss)LGPSsBnuZflyUEZoqfBb77A5VoGuVgBHorU1k0UCgVFl7XTwOUmo3cAETjq6sGuvyJnx8Ns2PznUMuPZEzCRNFQ26Smiatu8x0mXcHlnolSmdaapItjn0Zg0pnIJ5BGaIfV)EJbG8AEmmTXDmn742H6q0hBUqnD1oy24y623oLf(mqV3W6ppMXtep8CrI28WZhBoznVGsuiLi(vvi2OWqLB6RqDTbsqVneNMUIEjHHb7pq04ixE)Hu2WC21lUMHk7BXUUnM9VN0HvcesKtBpno7Tant2)kZeEhFXKROQcVa2IXly0ZS7yAM0PTYRWyS5Ia(NLoORdg1o1sv9KJnNmS1cCHTslE5TgvbwWlf7pCS5Cu6wr)4JBIHYwdIi8W8jVBgr9maMyonqj2fGmOEXFvEiEoc68YHYOCR5f60RrdmxD(HoD7Od6IxIM3)s6lbNWvaPtSPznSFPk2WNEOqTyCeANFTdsEtww2nkvC6tzHHR2aq0sOZEngfT2lSm(TH0dKKGONWeW1jnmMi8BIAVbinhpP54rNJ50edmDKlxWbniKcf2Lh9pjQ3GE5iO3PuXvASI2gB8MzBfV7(eANnsXDORHejzrgPqHdd8WtjyAims1GDebcQyBYOXSjSSXGhrkMup)YiD2FRyDllOutemTpcJsPli9in1HnNGdIaNpF8wA)huNR9zuyg41gMclGtXpxUWvNNJvmznYKg28usWry350ov5cYF01zg1Ii0wp2Xi6v08v1YV2MHQJYLqrVYLqA26AsvboWCSaDmu6wk9nfDnQZKLlEbIra9A6Yf)5XtXjektoHd8ehLVM1WMJY)k1TmExa1SWFv6Ok)0FB2xK9mZ)QUrvAAVHAvNv65Ddt3oZ9MAv(mNBc2nRv3W(T6cAZ6x7u1fhOXdRVrVR(T7zPNZum6cRUrVP(9u9J0t(khbkzv9yOnUBX0GbxNwOXtzPbeFc9kEbVWJ3qHTNvI035i8ehbh2LYvd0HMF(Svi5dfjPmon3yxdqlowjaz(qPRTGgHLIL5INfwP(QU2T(nZqp3vzEAnTdUgB7WZN7CAwCYLZUvIPFCSQWwuaXnn2KheHuQaeR7O)Gbd6vubAF1(oCURhW5de2IIHbnuMVURkktBxisP63PvEsL(3WsROXe2RlvjjSMahOT5cFCAniIsRjoZ78z9ZAsBZY10SgxlqABFrvbQrRfYHJy9QyFB2v487vPxrtgQ1fsz01DEOYR002xIHugWD7lVPn9Hku0KZN7zlgEPSjaBP8sb0lL3PrfYKLbdSa4JAe6FzTn48BDgwaQQ0SGd7t5M5tC6pOu(BPd7ObwwWJvy4si7x(IzXOkPPgN5Q2T7JlxZfLy4rpn2(3W1CJUlgyUBbtP)cbE09327dsTYHdpZT70ss4vsJFwf2K2gQt1hN3Zd6sx0ZuZL1VhxHx1wzCZ3uN(9ATrY0iVof0s)r)C(mJWp4OBMqW(pDg0O6KQ(KCRgmOmWrNz3kS5Xv1oBUPw0eD3vSS33DwYSz0To9MPEcRy6UU6NF3t)JsH0IJGfAHHQaqxT3sVUxUpoX(xTftJIS5XCwJnBtvdk1u3)sKLEA6clv(dgW7MP6PLR6PLTQYXFLR1fOaAxUlYuAmAY0nFoBSsIqbxdXEEstwD6DQvLxVOdNKfsxxllBWMnM94TwF2bDQyG6QKL8sJPsEo5D)uv2XfOwvnASlsHYC2Ka4Xzt9Srfb7DTNIhzpDnwKQ7OXtSrJA9j8peo)DWJs(NIu9sicV0vDbwL7b5DuyQK4bfvwh89wZTX)XUu15Z)oVqgLjZBtqBSQHitBxnJH22PxmZSdSJb0vXlLPSz1nm3ldaYeJDXB7PL4mDPZuyJj62xSqqP5o6qvIy(RuONhV)EfhpxxHxpwZR7Ef78qSKb5vgFv3GiVXV2OS5dBSkzRMU)OFrDdch7yHa2sxF8(r2z6xO8zfK6En2FS0D32YTdGz9TW87Cel5PVM7GxJs8YtP(DK9BBdTwkpf1ZAiHEDBnOY(2rF165LjSyVsmFY1Uov9Va)ys5HDYT)a3w45Oo7Qggq8ym1ByKIiNiCwLANq1ngyd50CgvIHMxeN5ounGv8svQVpMzcBFT8iM7PKtOFGY3MJ5M((UWxzPVTlpo(tSVPlnFzXbXRJVO(NfFywOSw9xmKhV184zFhwSD4A)uRiQgSHiIhRUM5D3uDAoNrUFQ(JzIbkR(LnPky1WxCLctU4xBLgYGJEEXB6Ne)YQSbLI3(FJe)KjLEc7t)xM)e21yV8))]] )