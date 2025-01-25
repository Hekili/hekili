
-- DruidFeral.lua
-- July 2024

-- TODO: Recalculate all ability damage / tick damage based on new formulas.

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID = ns.FindUnitBuffByID
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

local strformat = string.format

local spec = Hekili:NewSpecialization( 103 )

spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.ComboPoints, {
    predator_revealed = {
        aura = "predator_revealed",

        last = function ()
            local app = state.buff.predator_revealed.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 1.5 ) * 1.5
        end,

        interval = 1.5,
        value = 1
    },
    bs_inc = {
        talent = "berserk",
        aura = "bs_inc",

        last = function ()
            local app = state.buff.bs_inc.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 1.5 ) * 1.5
        end,

        interval = 1.5,
        value = 1
    }
} )

spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Druid
    astral_influence               = { 82210, 197524, 1 }, -- Increases the range of all of your spells by 5 yards.
    cyclone                        = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 6 sec. Only one target can be affected by your Cyclone at a time.
    feline_swiftness               = { 82239, 131768, 1 }, -- Increases your movement speed by 15%.
    fluid_form                     = { 92229, 449193, 1 }, -- Shred and Rake can be used in any form and shift you into Cat Form. Mangle can be used in any form and shifts you into Bear Form. Wrath and Starfire shift you into Moonkin Form, if known.
    forestwalk                     = { 100173, 400129, 1 }, -- Casting Regrowth increases your movement speed and healing received by 8% for 6 sec.
    frenzied_regeneration          = { 82220, 22842 , 1 }, -- Heals you for 20% health over 3 sec.
    heart_of_the_wild              = { 82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Cast time of Balance spells reduced by 30% and damage increased by 20%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges. Restoration: Healing increased by 30%, and mana costs reduced by 50%.
    hibernate                      = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin              = { 82219, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_rejuvenation          = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec.
    improved_stampeding_roar       = { 82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    improved_sunfire               = { 93714, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within 8 yards.
    incapacitating_roar            = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 10 yards for 3 sec. Damage will cancel the effect.
    innervate                      = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 8 sec.
    instincts_of_the_claw          = { 100176, 449184, 2 }, -- Shred, Brutal Slash, Rake, Mangle, and Thrash damage increased by 5%.
    ironfur                        = { 82227, 192081, 1 }, -- Increases armor by 14,735 for 7 sec.
    killer_instinct                = { 82225, 108299, 2 }, -- Physical damage and Armor increased by 6%.
    lore_of_the_grove              = { 100175, 449185, 2 }, -- Moonfire and Sunfire damage increased by 10%. Rejuvenation and Wild Growth healing increased by 5%.
    lycaras_teachings              = { 82233, 378988, 2 }, -- You gain 3% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                           = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 5,859 damage, 1 sec 2 points: 11,719 damage, 2 sec 3 points: 17,579 damage, 3 sec 4 points: 23,438 damage, 4 sec 5 points: 29,298 damage, 5 sec
    mass_entanglement              = { 82242, 102359, 1 }, -- Roots the target and all enemies within 12 yards in place for 10 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                     = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 67,588 damage for 8 sec.
    mighty_bash                    = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    natural_recovery               = { 82206, 377796, 1 }, -- Healing you receive is increased by 4%.
    natures_vigil                  = { 82244, 124974, 1 }, -- For 15 sec, all single-target damage also heals a nearby friendly target for 20% of the damage done.
    nurturing_instinct             = { 82214, 33873 , 2 }, -- Magical damage and healing increased by 6%.
    oakskin                        = { 100174, 449191, 1 }, -- Survival Instincts and Barkskin reduce damage taken by an additional 10%.
    primal_fury                    = { 82238, 159286, 1 }, -- While in Cat Form, when you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect. Mangle critical strike damage increased by 20%.
    rake                           = { 82199, 1822  , 1 }, -- Rake the target for 8,986 Bleed damage and an additional 73,281 Bleed damage over 15 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    rejuvenation                   = { 82217, 774   , 1 }, -- Heals the target for 40,886 over 12 sec.
    remove_corruption              = { 82204, 2782  , 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    renewal                        = { 82232, 108238, 1 }, -- Instantly heals you for 20% of maximum health. Usable in all shapeshift forms.
    rip                            = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 65,464 over 8 sec 2 points: 98,197 over 12 sec 3 points: 130,929 over 16 sec 4 points: 163,661 over 20 sec 5 points: 196,394 over 24 sec
    rising_light_falling_night     = { 82207, 417712, 1 }, -- Increases your damage and healing by 3% during the day. Increases your Versatility by 2% during the night.
    skull_bash                     = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    soothe                         = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar                = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 15 yards by 60% for 8 sec.
    starfire                       = { 91044, 197628, 1 }, -- Call down a burst of energy, causing 18,168 Arcane damage to the target, and 6,199 Arcane damage to all other enemies within 5 yards. Deals reduced damage beyond 8 targets.
    starlight_conduit              = { 100223, 451211, 1 }, -- Wrath, Starsurge, and Starfire damage increased by 5%. Starsurge's cooldown is reduced by 4 sec and its mana cost is reduced by 50%.
    starsurge                      = { 82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing 36,751 Astral damage.
    sunfire                        = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for 4,401 Nature damage and then an additional 46,339 Nature damage over 18 sec.
    thick_hide                     = { 82228, 16931 , 1 }, -- Reduces all damage taken by 4%.
    thrash                         = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                     = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    typhoon                        = { 82209, 132469, 1 }, -- Blasts targets within 15 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by 50% for 6 sec. Usable in all shapeshift forms.
    ursine_vigor                   = { 82235, 377842, 1 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 15%.
    ursocs_spirit                  = { 100177, 449182, 1 }, -- Stamina in Bear Form is increased by 10%.
    ursols_vortex                  = { 82242, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart                  = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    wellhoned_instincts            = { 82246, 377847, 1 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 120 sec.
    wild_charge                    = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                    = { 82241, 48438 , 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 32,907 over 7 sec. Healing starts high and declines over the duration.

    -- Feral
    adaptive_swarm                 = { 82112, 391888, 1 }, -- Command a swarm that heals 70,403 or deals 85,290 Nature damage over 12 sec to a target, and increases the effectiveness of your periodic effects on them by 25%. Upon expiration, finds a new target, preferring to alternate between friend and foe up to 3 times.
    apex_predators_craving         = { 82092, 391881, 1 }, -- Rip damage has a 6.0% chance to make your next Ferocious Bite free and deal the maximum damage.
    ashamanes_guidance             = { 82113, 391548, 1 }, -- Incarnation: Avatar of Ashamane During Incarnation: Avatar of Ashamane and for 30 sec after it ends, your Rip and Rake each cause affected enemies to take 3% increased damage from your abilities.  Convoke the Spirits Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    berserk                        = { 82101, 106951, 1 }, -- Go Berserk for 15 sec. While Berserk: Generate 1 combo point every 1.5 sec. Combo point generating abilities generate 1 additional combo point. Finishing moves restore up to 3 combo points generated over the cap. All attack and ability damage is increased by 10%.
    berserk_frenzy                 = { 82090, 384668, 1 }, -- During Berserk your combo point-generating abilities bleed the target for an additional 135% of their direct damage over 8 sec.
    berserk_heart_of_the_lion      = { 82105, 391174, 1 }, -- Reduces the cooldown of Berserk by 60 sec.
    bloodtalons                    = { 82109, 319439, 1 }, -- When you use 3 different combo point-generating abilities within 4 sec, the damage of your next 3 Rips or Ferocious Bites is increased by 25% for their full duration.
    brutal_slash                   = { 82091, 202028, 1 }, -- Strikes all nearby enemies with a massive slash, inflicting 38,547 Physical damage. Deals reduced damage beyond 5 targets. Awards 1 combo point.
    carnivorous_instinct           = { 82110, 390902, 2 }, -- Tiger's Fury's damage bonus is increased by 6%.
    circle_of_life_and_death       = { 82095, 400320, 1 }, -- Your damage over time effects deal their damage in 20% less time, and your healing over time effects in 15% less time.
    coiled_to_spring               = { 82085, 449537, 1 }, -- If you generate a combo point in excess of what you can store, your next Ferocious Bite or Primal Wrath deals 10% increased direct damage.
    convoke_the_spirits            = { 82114, 391528, 1 }, -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of 16 Druid spells and abilities over 4 sec. You will cast Ferocious Bite, Shred, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    doubleclawed_rake              = { 82086, 391700, 1 }, -- Rake also applies Rake to 1 additional nearby target.
    dreadful_bleeding              = { 82117, 391045, 1 }, -- Rip damage increased by 20%.
    feral_frenzy                   = { 82108, 274837, 1 }, -- Unleash a furious frenzy, clawing your target 5 times for 26,074 Physical damage and an additional 185,091 Bleed damage over 6 sec. Awards 5 combo points.
    frantic_momentum               = { 82115, 391875, 2 }, -- Finishing moves have a 3% chance per combo point spent to grant 10% Haste for 6 sec.
    incarnation                    = { 82114, 102543, 1 }, -- An improved Cat Form that grants all of your known Berserk effects and lasts 20 sec. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation: Energy cost of all Cat Form abilities is reduced by 20%, and Prowl can be used once while in combat. Generate 1 combo point every 1.5 sec. Combo point generating abilities generate 1 additional combo point. Finishing moves restore up to 3 combo points generated over the cap. All attack and ability damage is increased by 10%.
    incarnation_avatar_of_ashamane = { 82114, 102543, 1 }, -- An improved Cat Form that grants all of your known Berserk effects and lasts 20 sec. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation: Energy cost of all Cat Form abilities is reduced by 20%, and Prowl can be used once while in combat. Generate 1 combo point every 1.5 sec. Combo point generating abilities generate 1 additional combo point. Finishing moves restore up to 3 combo points generated over the cap. All attack and ability damage is increased by 10%.
    infected_wounds                = { 82118, 48484 , 1 }, -- Rake damage increased by 30%, and Rake causes an Infected Wound in the target, reducing the target's movement speed by 20% for 12 sec.
    lions_strength                 = { 82109, 391972, 1 }, -- Ferocious Bite and Rip deal 15% increased damage.
    lunar_inspiration              = { 92641, 155580, 1 }, -- Moonfire is usable in Cat Form, costs 30 energy, and generates 1 combo point.
    merciless_claws                = { 82098, 231063, 1 }, -- Shred deals 20% increased damage and Brutal Slash deals 15% increased damage against bleeding targets.
    moment_of_clarity              = { 82100, 236068, 1 }, -- Omen of Clarity now triggers 30% more often, can accumulate up to 2 charges, and increases the damage of your next Shred, Thrash, or Brutal Slash by an additional 15%.
    omen_of_clarity                = { 82123, 16864 , 1 }, -- Your auto attacks have a high chance to cause a Clearcasting state, making your next Shred, Thrash, or Brutal Slash cost no Energy and deal 15% more damage. Clearcasting can accumulate up to 1 charges.
    pouncing_strikes               = { 82119, 390772, 1 }, -- While stealthed, Rake will also stun the target for 4 sec, and deal 60% increased damage for its full duration. While stealthed, Shred deals 60% increased damage, has double the chance to critically strike, and generates 1 additional combo point.
    predator                       = { 82122, 202021, 1 }, -- Tiger's Fury lasts 5 additional seconds. Your combo point-generating abilities' direct damage is increased by 40% of your Haste.
    predatory_swiftness            = { 82106, 16974 , 1 }, -- Your finishing moves have a 20% chance per combo point to make your next Regrowth or Entangling Roots instant, free, and castable in all forms.
    primal_wrath                   = { 82120, 285381, 1 }, -- Finishing move that deals instant damage and applies Rip to all enemies within 10 yards. Lasts longer per combo point. 1 point : 10,474 plus Rip for 4 sec 2 points: 15,711 plus Rip for 6 sec 3 points: 20,948 plus Rip for 8 sec 4 points: 26,185 plus Rip for 10 sec 5 points: 31,422 plus Rip for 12 sec
    raging_fury                    = { 82107, 391078, 1 }, -- Tiger's Fury lasts 5 additional seconds.
    rampant_ferocity               = { 82103, 391709, 1 }, -- Ferocious Bite also deals 12,195 damage per combo point spent to all nearby enemies affect by your Rip. Spending extra Energy on Ferocious Bite increases damage dealt by up to 50%. Damage reduced beyond 5 targets.
    rip_and_tear                   = { 82093, 391347, 1 }, -- Applying Rip to a target also applies a Tear that deals 15% of the new Rip's damage over 8 sec.
    saber_jaws                     = { 82094, 421432, 2 }, -- When you spend extra Energy on Ferocious Bite, the extra damage is increased by 40%.
    sabertooth                     = { 82102, 202031, 1 }, -- Ferocious Bite deals 15% increased damage. For each Combo Point spent, Ferocious Bite's primary target takes 3% increased damage from your Cat Form bleed and other periodic abilities for 4 sec.
    savage_fury                    = { 82099, 449645, 1 }, -- Tiger's Fury increases your Haste by 10% and Energy recovery rate by 25% for 6 sec.
    soul_of_the_forest             = { 82096, 158476, 1 }, -- Your finishing moves grant 2 Energy per combo point spent and deal 5% increased damage.
    sudden_ambush                  = { 82104, 384667, 1 }, -- Finishing moves have a 6% chance per combo point spent to make your next Rake or Shred deal damage as though you were stealthed.
    survival_instincts             = { 82116, 61336 , 1 }, -- Reduces all damage you take by 50% for 6 sec.
    taste_for_blood                = { 82088, 384665, 1 }, -- Ferocious Bite deals 15% increased damage and an additional 15% during Tiger's Fury.
    thrashing_claws                = { 82098, 405300, 1 }, -- Shred deals 5% increased damage against bleeding targets and Shred and Brutal Slash apply the Bleed damage over time from Thrash, if known.
    tigers_fury                    = { 82124, 5217  , 1 }, -- Instantly restores 50 Energy, and increases the damage of all your attacks by 15% for their full duration. Lasts 20 sec.
    tigers_tenacity                = { 82107, 391872, 1 }, -- Tiger's Fury causes your next 3 finishing moves to restore 1 combo point. Tiger's Fury's also increases the periodic damage of your bleeds by an additional 10% for their full duration.
    tireless_energy                = { 82121, 383352, 2 }, -- Maximum Energy increased by 20 and Energy regeneration increased by 5%.
    unbridled_swarm                = { 82111, 391951, 1 }, -- Adaptive Swarm has a 60% chance to split into two Swarms each time it jumps.
    veinripper                     = { 82093, 391978, 1 }, -- Rip, Rake, and Thrash last 25% longer.
    wild_slashes                   = { 82091, 390864, 1 }, -- Swipe and Thrash damage is increased by 25%.

    -- Druid of the Claw
    aggravate_wounds               = { 94616, 441829, 1 }, -- Every attack with an Energy cost that you cast extends the duration of your Dreadful Wounds by 0.6 sec, up to 8 additional sec.
    bestial_strength               = { 94611, 441841, 1 }, -- Ferocious Bite damage increased by 5% and Primal Wrath's direct damage increased by 50%.
    claw_rampage                   = { 94613, 441835, 1 }, -- During Berserk, Shred, Brutal Slash, and Thrash have a 25% chance to make your next Ferocious Bite become Ravage.
    dreadful_wound                 = { 94620, 441809, 1 }, -- Ravage also inflicts a Bleed that causes 20,142 damage over 6 sec and saps its victims' strength, reducing damage they deal to you by 4%. Dreadful Wound is not affected by Circle of Life and Death. If a Dreadful Wound benefiting from Tiger's Fury is re-applied, the new Dreadful Wound deals damage as if Tiger's Fury was active.
    empowered_shapeshifting        = { 94612, 441689, 1 }, -- Frenzied Regeneration can be cast in Cat Form for 40 Energy. Bear Form reduces magic damage you take by 4%. Shred and Brutal Slash damage increased by 3%. Mangle damage increased by 10%.
    fount_of_strength              = { 94618, 441675, 1 }, -- Your maximum Energy and Rage are increased by 20. Frenzied Regeneration also increases your maximum health by 10%.
    killing_strikes                = { 94619, 441824, 1 }, -- Ravage increases your Agility by 5% and the armor granted by Ironfur by 20% for 8 sec. Your first Tiger's Fury after entering combat makes your next Ferocious Bite become Ravage.
    packs_endurance                = { 94615, 441844, 1 }, -- Stampeding Roar's duration is increased by 25%.
    ravage                         = { 94609, 441583, 1, "druid_of_the_claw" }, -- Your auto-attacks have a chance to make your next Ferocious Bite become Ravage. Ravage
    ruthless_aggression            = { 94619, 441814, 1 }, -- Ravage increases your auto-attack speed by 20% for 6 sec.
    strike_for_the_heart           = { 94614, 441845, 1 }, -- Shred, Brutal Slash, and Mangle's critical strike chance and critical strike damage are increased by 6%.
    tear_down_the_mighty           = { 94614, 441846, 1 }, -- The cooldown of Feral Frenzy is reduced by 5 sec.
    wildpower_surge                = { 94612, 441691, 1 }, -- Shred and Brutal Slash grant Ursine Potential. When you have 8 stacks, the next time you transform into Bear Form, your next Mangle deals 200% increased damage or your next Swipe deals 50% increased damage. Either generates 15 extra Rage.
    wildshape_mastery              = { 94610, 441678, 1 }, -- Ironfur and Frenzied Regeneration persist in Cat Form. When transforming from Bear to Cat Form, you retain 80% of your Bear Form armor and health for 6 sec. For 6 sec after entering Bear Form, you heal for 10% of damage taken over 8 sec.

    -- Wildstalker
    bond_with_nature               = { 94625, 439929, 1 }, -- Healing you receive is increased by 3%.
    bursting_growth                = { 94630, 440120, 1 }, -- When Bloodseeker Vines expire or you use Ferocious Bite on their target they explode in thorns, dealing 16,048 physical damage to nearby enemies. Damage reduced above 5 targets. When Symbiotic Blooms expire or you cast Rejuvenation on their target flowers grow around their target, healing them and up to 3 nearby allies for 4,152.
    entangling_vortex              = { 94622, 439895, 1 }, -- Enemies pulled into Ursol's Vortex are rooted in place for 3 sec. Damage may cancel the effect.
    flower_walk                    = { 94622, 439901, 1 }, -- During Barkskin your movement speed is increased by 10% and every second flowers grow beneath your feet that heal up to 3 nearby injured allies for 4,152.
    harmonious_constitution        = { 94625, 440116, 1 }, -- Your Regrowth's healing to yourself is increased by 25%.
    hunt_beneath_the_open_skies    = { 94629, 439868, 1 }, -- Damage and healing while in Cat Form increased by 3%. Moonfire and Sunfire damage increased by 10%.
    implant                        = { 94628, 440118, 1 }, -- When you gain or lose Tiger's Fury, your next single-target melee ability causes a Bloodseeker Vine to grow on the target for 4 sec.
    lethal_preservation            = { 94624, 455461, 1 }, -- When you remove an effect with Soothe or Remove Corruption, gain a combo point and heal for 4% of your maximum health. If you are at full health an injured party or raid member will be healed instead.
    resilient_flourishing          = { 94631, 439880, 1 }, -- Bloodseeker Vines and Symbiotic Blooms last 2 additional sec. When a target afflicted by Bloodseeker Vines dies, the vines jump to a valid nearby target for their remaining duration.
    root_network                   = { 94631, 439882, 1 }, -- Each active Bloodseeker Vine increases the damage your abilities deal by 2%. Each active Symbiotic Bloom increases the healing of your spells by 2%.
    strategic_infusion             = { 94623, 439890, 1 }, -- Tiger's Fury and attacking from Prowl increases the chance for Shred, Rake, and Brutal Slash to critically strike by 8% for 6 sec. Casting Regrowth increases the chance for your periodic heals to critically heal by 8% for 10 sec.
    thriving_growth                = { 94626, 439528, 1, "wildstalker" }, -- Rip and Rake damage has a chance to cause Bloodseeker Vines to grow on the victim, dealing 49,441 Bleed damage over 6 sec. Wild Growth and Regrowth healing has a chance to cause Symbiotic Blooms to grow on the target, healing for 24,915 over 6 sec. Multiple instances of these can overlap.
    twin_sprouts                   = { 94628, 440117, 1 }, -- When Bloodseeker Vines or Symbiotic Blooms grow, they have a 20% chance to cause another growth of the same type to immediately grow on a valid nearby target.
    vigorous_creepers              = { 94627, 440119, 1 }, -- Bloodseeker Vines increase the damage your abilities deal to affected enemies by 5%. Symbiotic Blooms increase the healing your spells do to affected targets by 20%.
    wildstalkers_power             = { 94621, 439926, 1 }, -- Rip and Ferocious Bite damage increased by 5%. Rejuvenation healing increased by 10%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    ferocious_wound      = 611 , -- (236020) Attacking with a 5 combo point Ferocious Bite reduces the target's maximum health by up to 5% for 30 sec, stacking up to 2 times. Ferocious Wound can only be active on one target at once.
    freedom_of_the_herd  = 203 , -- (213200) Your Stampeding Roar clears all roots and snares from yourself and allies.
    fresh_wound          = 612 , -- (203224) Rake has a 100% increased critical strike chance if used on a target that doesn’t already have Rake active.
    high_winds           = 5384, -- (200931) Increases the range of Cyclone, Typhoon, and Entangling Roots by 5 yds.
    king_of_the_jungle   = 602 , -- (203052) For every enemy you have Rip active on, your movement speed and healing received is increased by 5%. Stacks 4 times.
    leader_of_the_pack   = 3751, -- (202626) While in Cat Form, you increase the movement speed of raid members within 20 yards by 10%. Leader of the Pack also causes allies to heal themselves for 3% of their maximum health when they critically hit with a direct attack. The healing effect cannot occur more than once every 8 sec.
    malornes_swiftness   = 601 , -- (236012) Your Travel Form movement speed while within a Battleground or Arena is increased by 20% and you always move at 100% movement speed while in Travel Form.
    savage_momentum      = 820 , -- (205673) Interrupting a spell with Skull Bash reduces the remaining cooldown of Tiger's Fury, Survival Instincts, and Dash by 10 sec.
    strength_of_the_wild = 3053, -- (236019) You become further adept in Caster Form and Bear Form. Caster Form When using Regrowth on an ally the initial heal will have a 30% increased critical chance and the cast time of Regrowth will be reduced by 50% for 6 sec. Bear Form Maximum health while in Bear Form increased by 15% and you gain 5 Rage when attacked in Bear Form. You also learn:  Strength of the Wild
    thorns               = 201 , -- (305497) Sprout thorns for 12 sec on the friendly target. When victim to melee attacks, thorns deals 24,916 Nature damage back to the attacker. Attackers also have their movement speed reduced by 50% for 4 sec.
    tireless_pursuit     = 5647, -- (377801) For 3 sec after leaving Cat Form or Travel Form, you retain up to 40% movement speed.
    wicked_claws         = 620 , -- (203242) Infected Wounds can now stack up to 2 times, and reduces 10% of all healing received by the target per stack. Infected Wounds can now also be applied from Rip.
} )


local mod_circle_hot = setfenv( function( x )
    return x * ( talent.circle_of_life_and_death.enabled and 0.85 or 1 )
end, state )

local mod_circle_dot = setfenv( function( x )
    return x * ( talent.circle_of_life_and_death.enabled and 0.8 or 1 )
end, state )



-- Ticks gained on refresh.
local tick_calculator = setfenv( function( t, action, pmult )
    local remaining_ticks = 0
    local potential_ticks = 0
    local remains = t.remains
    local tick_time = t.tick_time
    local ttd = min( fight_remains, target.time_to_die )

    local aura = action
    if action == "primal_wrath" then aura = "rip" end

    local duration = class.auras[ aura ].duration * ( action == "primal_wrath" and 0.5 or 1 )
    local app_duration = min( ttd, class.abilities[ action ].apply_duration or duration )
    local app_ticks = app_duration / tick_time

    remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( remains, ttd ) / tick_time
    duration = max( 0, min( remains + duration, 1.3 * duration, ttd ) )
    potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( duration, ttd ) / tick_time

    if action == "primal_wrath" and active_enemies > 1 then
        -- Current target's ticks are based on actual values.
        local total = potential_ticks - remaining_ticks

        -- Other enemies could have a different remains for other reasons.
        -- Especially SbT.
        local pw_remains = max( state.action.primal_wrath.lastCast + class.abilities.primal_wrath.max_apply_duration - query_time, 0 )

        local fresh = max( 0, active_enemies - active_dot[ aura ] )
        local dotted = max( 0, active_enemies - fresh )

        if remains == 0 then
            fresh = max( 0, fresh - 1 )
        else
            dotted = max( 0, dotted - 1 )
            pw_remains = min( remains, pw_remains )
        end

        local pw_duration = min( pw_remains + class.abilities.primal_wrath.apply_duration, 1.3 * class.abilities.primal_wrath.apply_duration )

        local targets = ns.dumpNameplateInfo()
        for guid, counted in pairs( targets ) do
            if counted then
                -- Use TTD info for enemies that are counted as targets
                ttd = min( fight_remains, max( 1, Hekili:GetDeathClockByGUID( guid ) - ( offset + delay ) ) )

                if dotted > 0 then
                    -- Dotted enemies use remaining ticks from previous primal wrath cast or target remains, whichever is shorter
                    remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( pw_remains, ttd ) / tick_time
                    dotted = dotted - 1
                else
                    -- Fresh enemies have no remaining_ticks
                    remaining_ticks = 0
                    pw_duration = class.abilities.primal_wrath.apply_duration
                end

                potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( pw_duration, ttd ) / tick_time

                total = total + potential_ticks - remaining_ticks
            end
        end
        return max( 0, total )

    elseif action == "thrash_cat" then
        local fresh = max( 0, active_enemies - active_dot.thrash_cat )
        local dotted = max( 0, active_enemies - fresh )

        return max( 0, fresh * app_ticks + dotted * ( potential_ticks - remaining_ticks ) )
    end

    return max( 0, potential_ticks - remaining_ticks )
end, state )


Hekili:EmbedAdaptiveSwarm( spec )


-- Auras
spec:RegisterAuras( {
    aquatic_form = {
        id = 276012,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Your next Ferocious Bite costs no Energy or combo points and deals the maximum damage.
    -- https://wowhead.com/beta/spell=391882
    apex_predators_craving = {
        id = 391882,
        duration = 15,
        max_stack = 1,
        copy = 339140
    },
    -- Your Rip and Rake each cause affected enemies to take $s1% increased damage from your abilities.
    ashamanes_guidance = {
        id = 421442,
        duration = 3600,
        max_stack = 1,
    },
    -- Armor increased by $w4%.; Stamina increased by $1178s2%.; Immune to Polymorph effects.$?$w13<0[; Arcane damage taken reduced by $w14% and all other magic damage taken reduced by $w13%.][]
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
        copy = { 279526, "berserk_cat" },
        multiplier = 1.5,
    },
    -- Bleeding for $w1 damage every $t1 sec.
    bloodseeker_vines = {
        id = 439531,
        duration = function() return mod_circle_dot( talent.resilient_flourishing.enabled and 8 or 6 ) end,
        tick_time = mod_circle_dot( 2.0 ),
        max_stack = 1
    },
    overflowing_power = {
        id = 405189,
        duration = 10,
        max_stack = 3,
        --[[meta = {
            stack = function( t )
                if buff.bs_inc.down then return 0 end
                local deficit = combo_points.deficit
                if deficit > 0 then return t.count end
                return min( 3, t.count + max( 0, floor( ( query_time - t.applied ) / 1.5 ) ) )
            end,
            stacks = function( t )
                return t.stack
            end
        }--]]
    },

    -- Alias for Berserk vs. Incarnation
    bs_inc = {
        alias = { "berserk", "incarnation" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
        duration = function () return talent.incarnation.enabled and 20 or 15 end,
    },
    bloodtalons = {
        id = 145152,
        max_stack = 3,
        duration = 30,
        multiplier = 1.3,
    },
    -- Autoattack damage increased by $w4%.  Immune to Polymorph effects.  Movement speed increased by $113636s1% and falling damage reduced.
    -- https://wowhead.com/beta/spell=768
    cat_form = {
        id = 768,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Taking damage will grant $102352m1 healing every $102352t sec for $102352d.
    -- https://wowhead.com/beta/spell=102351
    cenarion_ward = {
        id = 102351,
        duration = 30,
        max_stack = 1
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=102352
    cenarion_ward_hot = {
        id = 102352,
        duration = 8,
        type = "Magic",
        max_stack = 1,
        dot = "buff"
    },
    -- Your next Shred, Thrash, or $?s202028[Brutal Slash][Swipe] costs no Energy$?s236068[ and deals $s3% increased damage][].
    -- https://wowhead.com/beta/spell=135700
    clearcasting = {
        id = 135700,
        duration = 15,
        type = "Magic",
        max_stack = function() return 1 + talent.moment_of_clarity.rank + talent.tranquil_mind.rank end,
        multiplier = function() return talent.moment_of_clarity.enabled and 1.15 or 1 end,
    },
    -- Your next Ferocious Bite or Primal Wrath deals $s1% increased direct damage.
    coiled_to_spring = {
        id = 449538,
        duration = 15.0,
        max_stack = 1,
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
    -- Bleeding for $w1 damage every $t1 seconds. Weakened, dealing $w2% less damage to $@auracaster.
    dreadful_wound = {
        id = 451177,
        duration = 6,
        tick_time = 2,
        pandemic = true,
        mechanic = "bleed",
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
    -- Rooted.$?<$w2>0>[ Suffering $w2 Nature damage every $t2 sec.][]
    -- https://wowhead.com/beta/spell=339
    entangling_roots = {
        id = 339,
        duration = 30,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Bleeding for $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=274838
    feral_frenzy = {
        id = 274838,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,

            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        }
    },
    -- Increases speed and all healing taken by $w1%.
    forestwalk = {
        id = 400126,
        duration = 6.0,
        max_stack = 1,
    },
    -- Talent: Haste increased by $s1%.
    -- https://wowhead.com/beta/spell=391876
    frantic_momentum = {
        id = 391876,
        duration = 6,
        max_stack = 1
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
    -- Taunted.
    -- https://wowhead.com/beta/spell=6795
    growl = {
        id = 6795,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    -- Talent: Abilities not associated with your specialization are substantially empowered.
    -- https://wowhead.com/beta/spell=108291
    heart_of_the_wild = {
        id = 108291,
        duration = 45,
        type = "Magic",
        max_stack = 1,
        copy = { 108292, 108293, 108294 }
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
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=99
    incapacitating_roar = {
        id = 99,
        duration = 3,
        mechanic = "incapacitate",
        max_stack = 1
    },
    -- Talent: Energy costs reduced by $w3%.$?s343223[    Finishing moves have a $w1% chance per combo point spent to refund $343216s1 combo $lpoint:points;.    Rake and Shred deal damage as though you were stealthed.][]    $?s384668[Combo point-generating abilities bleed the target for an additonal $384668s2% of their damage over $340056d.][]
    -- https://wowhead.com/beta/spell=102543
    incarnation_avatar_of_ashamane = {
        id = 102543,
        duration = 20,
        max_stack = 1,
        copy = { "incarnation", "incarnation_king_of_the_jungle" }
    },
    jungle_stalker = {
        id = 252071,
        duration = 30,
        max_stack = 1,
        copy = "incarnation_avatar_of_ashamane_prowl"
    },
    -- Talent: Movement speed slowed by $w1%.$?e1[ Healing taken reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=58180
    infected_wounds = {
        id = 58180,
        duration = 12,
        type = "Disease",
        max_stack = function () return pvptalent.wicked_claws.enabled and 2 or 1 end,
    },
    -- Talent: Mana costs reduced $w1%.
    -- https://wowhead.com/beta/spell=29166
    innervate = {
        id = 29166,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Armor increased by ${$w1*$AGI/100}.
    -- https://wowhead.com/beta/spell=192081
    ironfur = {
        id = 192081,
        duration = 7,
        type = "Magic",
        max_stack = 1
    },
    -- Agility increased by $w1% and armor granted by Ironfur increased by $w2%.
    killing_strikes = {
        id = 441825,
        duration = 8.0,
        max_stack = 1,
    },
    maim = {
        id = 22570,
        duration = function() return 1 + combo_points.current end,
        max_stack = 1,
    },
    -- Talent: Rooted.
    -- https://wowhead.com/beta/spell=102359
    mass_entanglement = {
        id = 102359,
        duration = 10,
        tick_time = 2.0,
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
    -- Suffering $w1 Arcane damage every $t1 sec.
    -- https://wowhead.com/beta/spell=155625
    moonfire_cat = {
        id = 155625,
        duration = function () return mod_circle_dot( 18 ) end,
        tick_time = function() return mod_circle_dot( 2 ) * haste end,
        max_stack = 1,
        copy = "lunar_inspiration",
        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,
            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        }
    },
    -- Suffering $w2 Arcane damage every $t2 seconds.
    -- https://wowhead.com/beta/spell=164812
    moonfire = {
        id = 164812,
        duration = function () return mod_circle_dot( 16 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Spell damage increased by $s9%.; Immune to Polymorph effects.$?$w3>0[; Armor increased by $w3%.][]$?$w12<0[; Arcane damage taken reduced by $w13% and all other magic damage taken reduced by $w12%.][]
    moonkin_form = {
        id = 24858,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $?s137012[Single-target healing also damages a nearby enemy target for $w3% of the healing done][Single-target damage also heals a nearby friendly target for $w3% of the damage done].
    -- https://wowhead.com/beta/spell=124974
    natures_vigil = {
        id = 124974,
        duration = 15,
        max_stack = 1
    },
    predatory_swiftness = {
        id = 69369,
        duration = 12,
        type = "Magic",
        max_stack = 1,
    },
    -- Stub for snapshot calcs. ???
    primal_wrath = {
        id = 285381,
        duration = function () return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 2 + 2 * combo_points.current ) end,
        tick_time = function () return mod_circle_dot( 2 ) * haste end,
        meta = {
            remains = function () return dot.rip.remains end,
            applied = function () return dot.rip.applied end
        }
    },
    -- Stealthed.
    -- https://wowhead.com/beta/spell=5215
    prowl_base = {
        id = 5215,
        duration = 3600,
        multiplier = function() return talent.pouncing_strikes.enabled and 1.6 or 1 end,
    },
    prowl_incarnation = {
        id = 102547,
        duration = 3600,
        multiplier = function() return talent.pouncing_strikes.enabled and 1.6 or 1 end,
    },
    prowl = {
        alias = { "prowl_base", "prowl_incarnation" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600
    },
    -- Talent: Bleeding for $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=155722
    rake = {
        id = 155722,
        duration = function () return mod_circle_dot( ( talent.veinripper.enabled and 1.25 or 1 ) * 15 ) end,
        tick_time = function() return mod_circle_dot( 3 ) * haste end,
        mechanic = "bleed",
        copy = "rake_bleed",

        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,

            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        }
    },
    ravage = {
        id = 441585,
        duration = 20,
        max_stack = 1,
        copy = "ravage_fb"
    },
    ravage_upon_combat = {
        duration = 3600,
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
        duration = function () return mod_circle_dot( ( talent.veinripper.enabled and 1.25 or 1 ) * ( 4 + ( combo_points.current * 4 ) ) ) end,
        tick_time = function() return mod_circle_dot( 2 ) * haste end,
        mechanic = "bleed",
        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,

            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        }
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
        duration = 4,
        max_stack = 1,
    },
    -- Haste increased by $s1% and Energy recovery rate increased by $s2%.
    savage_fury = {
        id = 449646,
        duration = 6.0,
        max_stack = 1,
    },
    shadowmeld = {
        id = 58984,
        duration = 3600,
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
     -- Movement speed increased by $s1%.
     stampeding_roar = {
        id = 106898,
        duration = function() return talent.packs_endurance.enabled and 10 or 8 end,
        max_stack = 1,
    },
    -- Suffering $w2 Astral damage every $t2 sec.
    -- https://wowhead.com/beta/spell=202347
    stellar_flare = {
        id = 202347,
        duration = 24,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Rake or Shred will deal damage as though you were stealthed.
    -- https://wowhead.com/beta/spell=391974
    sudden_ambush = {
        id = 391974,
        duration = 15,
        max_stack = 1,
        copy = 340698
    },
    -- Talent: Suffering $w2 Nature damage every $t2 seconds.
    -- https://wowhead.com/beta/spell=164815
    sunfire = {
        id = 164815,
        duration = 18,
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
    -- Melee attackers take Nature damage when hit and their movement speed is slowed by $232559s1% for $232559d.
    -- https://wowhead.com/beta/spell=305497
    thorns = {
        id = 305497,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Suffering $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=192090
    thrash_bear = {
        id = 192090,
        duration = function () return mod_circle_dot( 15 ) end,
        tick_time = function () return mod_circle_dot( 3 ) * haste end,
        max_stack = 3,
    },
    thrash_cat = {
        id = 405233,
        duration = function () return mod_circle_dot( ( talent.veinripper.enabled and 1.25 or 1 ) * 15 ) end,
        tick_time = function() return mod_circle_dot( 3 ) * haste end,
        meta = {
            ticks_gained_on_refresh = function( t )
                return tick_calculator( t, t.key, false )
            end,

            ticks_gained_on_refresh_pmultiplier = function( t )
                return tick_calculator( t, t.key, true )
            end,
        },
        copy = { "thrash", 106830 }
    },
    -- Talent: Increased movement speed by $s1% while in Cat Form, reducing gradually over time.
    -- https://wowhead.com/beta/spell=252216
    tiger_dash = {
        id = 252216,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Attacks deal $s1% additional damage for their full duration.
    -- https://wowhead.com/beta/spell=5217
    tigers_fury = {
        id = 5217,
        duration = function() return 10 + ( talent.predator.enabled and 5 or 0 ) + ( talent.raging_fury.enabled and 5 or 0 ) end,
        multiplier = function() return 1.15 + state.conduit.carnivorous_instinct.mod * 0.01 + state.talent.carnivorous_instinct.rank * 0.06 end,
    },
    -- Talent: Your next finishing move restores $391874s1 combo $Lpoint:points;.
    -- https://wowhead.com/beta/spell=391873
    tigers_tenacity = {
        id = 391873,
        duration = 15,
        max_stack = 3
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
    -- Talent: Movement speed slowed by $s1% and winds impeding movement.
    -- https://wowhead.com/beta/spell=102793
    ursols_vortex = {
        id = 102793,
        duration = 10,
        type = "Magic",
        max_stack = 1
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
        alias = { "bear_form", "cat_form", "moonkin_form" },
        duration = 3600,
        aliasMode = "first",
        aliasType = "buff",
    },

    -- PvP Talents
    ferocious_wound = {
        id = 236021,
        duration = 30,
        max_stack = 2,
    },
    high_winds = {
        id = 200931,
        duration = 4,
        max_stack = 1,
    },
    king_of_the_jungle = {
        id = 203059,
        duration = 24,
        max_stack = 3,
    },
    leader_of_the_pack = {
        id = 202636,
        duration = 3600,
        max_stack = 1,
    },

    -- Azerite Powers
    iron_jaws = {
        id = 276026,
        duration = 30,
        max_stack = 1,
    },
    jungle_fury = {
        id = 274426,
        duration = function () return talent.predator.enabled and 17 or 12 end,
        max_stack = 1,
    },

    -- Legendaries
    eye_of_fearful_symmetry = {
        id = 339142,
        duration = 15,
        max_stack = 2,
    }
} )


-- Snapshotting
local tf_spells = { rake = true, rip = true, thrash_cat = true, lunar_inspiration = true, primal_wrath = true }
local bt_spells = { rip = true, primal_wrath = true }
local mc_spells = { thrash_cat = true }
local pr_spells = { rake = true }
local bs_spells = { rake = true }

local stealth_dropped = 0


local function calculate_pmultiplier( spellID )
    local a = class.auras
    local tigers_fury = FindUnitBuffByID( "player", a.tigers_fury.id, "PLAYER" ) and a.tigers_fury.multiplier or 1
    local bloodtalons = FindUnitBuffByID( "player", a.bloodtalons.id, "PLAYER" ) and a.bloodtalons.multiplier or 1
    local clearcasting = state.talent.moment_of_clarity.enabled and FindUnitBuffByID( "player", a.clearcasting.id, "PLAYER" ) and a.clearcasting.multiplier or 1
    local prowling = ( FindUnitBuffByID( "player", a.prowl_base.id, "PLAYER" ) or FindUnitBuffByID( "player", a.prowl_incarnation.id, "PLAYER" ) or GetTime() - stealth_dropped < 0.2 ) and a.prowl_base.multiplier or 1
    local berserk = state.talent.berserk.enabled and FindUnitBuffByID( "player", state.talent.incarnation.enabled and a.incarnation.id or a.berserk.id, "PLAYER" ) and a.berserk.multiplier or 1

    if spellID == a.rake.id then
        return 1 * tigers_fury * prowling * berserk

    elseif spellID == a.rip.id or spellID == a.primal_wrath.id then
        return 1 * bloodtalons * tigers_fury

    elseif spellID == a.thrash_cat.id then
        return 1 * tigers_fury * clearcasting

    elseif spellID == a.lunar_inspiration.id then
        return 1 * tigers_fury

    end

    return 1
end

spec:RegisterStateExpr( "persistent_multiplier", function( act )
    local mult = 1

    act = act or this_action

    if not act then return mult end

    local a = class.auras
    if tf_spells[ act ] and buff.tigers_fury.up then mult = mult * a.tigers_fury.multiplier end
    if bt_spells[ act ] and buff.bloodtalons.up then mult = mult * a.bloodtalons.multiplier end
    if mc_spells[ act ] and talent.moment_of_clarity.enabled and buff.clearcasting.up then mult = mult * a.clearcasting.multiplier end
    if pr_spells[ act ] and ( effective_stealth or state.query_time - stealth_dropped < 0.2 ) then mult = mult * a.prowl_base.multiplier end
    if bs_spells[ act ] and talent.berserk.enabled and buff.bs_inc.up then mult = mult * a.berserk.multiplier end

    return mult
end )


local snapshots = {
    [155722] = true,
    [1079]   = true,
    [285381] = true,
    [106830] = true,
    [155625] = true
}


-- Tweaking for new Feral APL.
local rip_applied = false

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    rip_applied = false
end )

--[[spec:RegisterStateExpr( "opener_done", function ()
    return rip_applied
end )--]]


local last_bloodtalons_proc = 0
local last_bloodtalons_stack = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

    if sourceGUID == state.GUID then
        if subtype == "SPELL_AURA_REMOVED" then
            -- Track Prowl and Shadowmeld and Sudden Ambush dropping, give a 0.2s window for the Rake snapshot.
            if spellID == 58984 or spellID == 5215 or spellID == 102547 or spellID == 391974 or spellID == 340698 then
                stealth_dropped = GetTime()
            end
        elseif ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
            if snapshots[ spellID ] then
                local mult = calculate_pmultiplier( spellID )
                ns.saveDebuffModifier( spellID, mult )
                ns.trackDebuff( spellID, destGUID, GetTime(), true )

            end

        elseif subtype == "SPELL_CAST_SUCCESS" and ( spellID == class.abilities.rip.id or spellID == class.abilities.primal_wrath.id ) then
            rip_applied = true
        end

        if spellID == 145152 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REMOVED_DOSE" ) then
            local bloodtalons = GetPlayerAuraBySpellID( 145152 )
            if not bloodtalons or not bloodtalons.applications or bloodtalons.applications == 0 then
                last_bloodtalons_proc = 0
                last_bloodtalons_stack = 0
            else
                if bloodtalons.applications > last_bloodtalons_stack then last_bloodtalons_proc = GetTime() end
                last_bloodtalons_stack = bloodtalons.applications
            end
        end
    end
end )


spec:RegisterStateExpr( "last_bloodtalons", function ()
    return last_bloodtalons_proc
end )


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

    if legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent.restoration_affinity.enabled then
        applyBuff( "heart_of_the_wild" )
        applyDebuff( "player", "oath_of_the_elder_druid_icd" )
    end
end )


local affinities = {
    bear_form = "guardian_affinity",
    cat_form = "feral_affinity",
    moonkin_form = "balance_affinity",
}

-- Function to apply form that is passed into it via string.
spec:RegisterStateFunction( "shift", function( form )
    if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

    if buff.bear_form.up and form == "cat_form" and talent.wildshape_mastery.enabled then
        applyBuff( "wildshape_mastery" )
    end

    removeBuff( "cat_form" )
    removeBuff( "bear_form" )
    removeBuff( "travel_form" )
    removeBuff( "moonkin_form" )
    removeBuff( "travel_form" )
    removeBuff( "aquatic_form" )
    removeBuff( "stag_form" )
    applyBuff( form )

    if affinities[ form ] and legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down then
        applyBuff( "heart_of_the_wild" )
        applyDebuff( "player", "oath_of_the_elder_druid_icd" )
    end
end )

spec:RegisterHook( "runHandler_startCombat", function()
    if talent.killing_strikes.enabled then applyBuff( "ravage_upon_combat" ) end
end )

spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if not a or a.startsCombat then
        break_stealth()
    end

    if talent.aggravate_wounds.enabled and debuff.dreadful_wound.up and a.spendType == "energy" and a.spend > 0 then
        debuff.dreadful_wound.expires = debuff.dreadful_wound.expires + 0.6
    end

    if covenant.venthyr and buff.ravenous_frenzy.up and ability ~= "ravenous_frenzy" then
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


local bt_auras = {
    bt_brutal_slash = "brutal_slash",
    bt_moonfire = "lunar_inspiration",
    bt_rake = "rake",
    bt_shred = "shred",
    bt_swipe = "swipe_cat",
    bt_thrash = "thrash_cat"
}

local bt_generator = function( t )
    local ab = bt_auras[ t.key ]
    ab = ab and class.abilities[ ab ]
    ab = ab and ab.lastCast

    if ab and ab + 4 > query_time then
        t.count = 1
        t.expires = ab + 4
        t.applied = ab
        t.caster = "player"
        return
    end

    t.count = 0
    t.expires = 0
    t.applied = 0
    t.caster = "nobody"
end

spec:RegisterAuras( {
    bt_brutal_slash = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator
    },
    bt_moonfire = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator,
        copy = "bt_lunar_inspiration"
    },
    bt_rake = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator
    },
    bt_shred = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator
    },
    bt_swipe = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator,
        copy = { "bt_swipe_cat", "bt_brutal_slash" }
    },
    bt_thrash = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator,
        copy = "bt_thrash_cat"
    },
    bt_triggers = {
        alias = { "bt_brutal_slash", "bt_moonfire", "bt_rake", "bt_shred", "bt_swipe", "bt_thrash" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 4,
    },
} )


local LycarasHandler = setfenv( function ()
    if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
    elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
    elseif buff.bear_form.up then state:RunHandler( "barkskin" )
    elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
    else state:RunHandler( "wild_growth" ) end
end, state )

local SinfulHysteriaHandler = setfenv( function ()
    applyBuff( "ravenous_frenzy_sinful_hysteria" )
end, state )


local ComboPointPeriodic = setfenv( function()
    gain( 1, "combo_points" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    if buff.cat_form.down then
        energy.regen = 10 + ( stat.haste * 10 )
    end
    debuff.rip.pmultiplier = nil
    debuff.rake.pmultiplier = nil
    debuff.thrash_cat.pmultiplier = nil

    eclipse.reset()
    spec.SwarmOnReset()

    -- Bloodtalons
    if talent.bloodtalons.enabled then
        for bt_buff, bt_ability in pairs( bt_auras ) do
            local last = action[ bt_ability ].lastCast
            if last > last_bloodtalons_proc and now - last < 4 then
                applyBuff( bt_buff )
                buff[ bt_buff ].applied = last
                buff[ bt_buff ].expires = last + 4
            end
        end
    end

    if prev_gcd[1].feral_frenzy and now - action.feral_frenzy.lastCast < gcd.execute and combo_points.current < 5 then
        -- combo_points.current = 5
        gain( 5, "combo_points", false )
    end

    -- opener_done = nil
    last_bloodtalons = nil

    if buff.jungle_stalker.up then buff.jungle_stalker.expires = buff.bs_inc.expires end

    if buff.bs_inc.up then
        if talent.ashamanes_guidance.enabled then buff.ashamanes_frenzy.expires = buff.bs_inc.expires + 40 end

        -- Queue combo point gain events every 1.5 seconds while Incarnation/Berserk is active, starting 1.5 seconds after cast
        local tick, expires = buff.bs_inc.applied, buff.bs_inc.expires
        for i = 1.5, expires - query_time, 1.5 do
            tick = query_time + i
            if tick < expires then
                state:QueueAuraEvent( "incarnation_combo_point_perodic", ComboPointPeriodic, tick, "AURA_TICK" )
            end
        end
    end

    if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
        state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
    end
end )

spec:RegisterHook( "gain", function( amt, resource, overflow )
    if overflow == nil then overflow = true end -- nil is yes
    if amt > 0 and resource == "combo_points" then
        if combo_points.deficit < amt and overflow then -- excess points
        local combo_points_to_store = amt - combo_points.deficit
            if buff.overflowing_power.stack > ( 3 - combo_points_to_store ) or buff.bs_inc.down then -- unable to store them all
                applyBuff( "coiled_to_spring" )
            end
            if buff.bs_inc.up then addStack( "overflowing_power", nil, combo_points_to_store ) end -- store as many as possible
        end
    end
    if azerite.untamed_ferocity.enabled and amt > 0 and resource == "combo_points" then
        if talent.incarnation.enabled then gainChargeTime( "incarnation", 0.2 )
        else gainChargeTime( "berserk", 0.3 ) end
    end
end )

local function comboSpender( a, r )
    if r == "combo_points" and a > 0 then
        if talent.soul_of_the_forest.enabled then
            gain( a * 2, "energy" )
        end

        if buff.overflowing_power.up then
            gain( buff.overflowing_power.stack, "combo_points" )
            removeBuff( "overflowing_power" )
        end

        if buff.tigers_tenacity.up then
            removeStack( "tigers_tenacity" )
            gain( 1, "combo_points" )
        end

        if talent.predatory_swiftness.enabled and a >= 5 then
            applyBuff( "predatory_swiftness" )
        end

        -- Legacy
        if legendary.frenzyband.enabled then
            reduceCooldown( talent.incarnation.enabled and "incarnation" or "berserk", 0.3 )
        end

        if set_bonus.tier29_4pc > 0 then
            applyBuff( "sharpened_claws", nil, a )
        end
    end
end

spec:RegisterHook( "spend", comboSpender )



local combo_generators = {
    brutal_slash      = true,
    feral_frenzy      = true,
    lunar_inspiration = true,
    rake              = true,
    shred             = true,
    swipe_cat         = true,
    thrash_cat        = true
}

spec:RegisterStateExpr( "active_bt_triggers", function ()
    if not talent.bloodtalons.enabled then return 0 end
    return buff.bt_triggers.stack
end )


local bt_remainingTime = {}

spec:RegisterStateFunction( "time_to_bt_triggers", function( n )
    if not talent.bloodtalons.enabled or buff.bt_triggers.stack == n then return 0 end
    if buff.bt_triggers.stack < n then return 3600 end

    table.wipe( bt_remainingTime )

    for bt_aura in pairs( bt_auras ) do
        local rem = buff[ bt_aura ].remains
        if rem > 0 then bt_remainingTime[ bt_aura ] = rem end
    end

    table.sort( bt_remainingTime )
    return bt_remainingTime[ n ]
end )

--[[ spec:RegisterStateExpr( "will_proc_bloodtalons", function ()
    if not talent.bloodtalons.enabled then return false end

    local count = 0
    for bt_buff, bt_ability in pairs( bt_auras ) do
        if buff[ bt_buff ].up then
            count = count + 1
        end
    end

    if count > 2 then return true end
end )

spec:RegisterStateFunction( "proc_bloodtalons", function()
    for aura in pairs( bt_auras ) do
        removeBuff( aura )
    end

    applyBuff( "bloodtalons", nil, 2 )
    last_bloodtalons = query_time
end ) ]]

spec:RegisterStateFunction( "check_bloodtalons", function ()
    if buff.bt_triggers.stack > 2 then
        removeBuff( "bt_triggers" )
        applyBuff( "bloodtalons", nil, 3 )
    end
end )


spec:RegisterStateTable( "druid", setmetatable( {},{
    __index = function( t, k )
        if k == "catweave_bear" then return false
        elseif k == "owlweave_bear" then return false
        elseif k == "owlweave_cat" then
            return talent.balance_affinity.enabled and settings.owlweave_cat or false
        elseif k == "no_cds" then return not toggle.cooldowns
        elseif k == "primal_wrath" then return class.abilities.primal_wrath
        elseif k == "lunar_inspiration" then return debuff.lunar_inspiration
        elseif k == "delay_berserking" then return settings.delay_berserking
        elseif debuff[ k ] ~= nil then return debuff[ k ]
        end
    end
} ) )


spec:RegisterStateExpr( "bleeding", function ()
    return debuff.rake.up or debuff.rip.up or debuff.thrash_bear.up or debuff.thrash_cat.up or debuff.feral_frenzy.up or debuff.sickle_of_the_lion.up
end )

spec:RegisterStateExpr( "effective_stealth", function ()
    return buff.prowl.up or buff.incarnation.up or buff.shadowmeld.up or buff.sudden_ambush.up
end )


-- Legendaries.  Ugh.
spec:RegisterGear( "ailuro_pouncers", 137024 )
spec:RegisterGear( "behemoth_headdress", 151801 )
spec:RegisterGear( "chatoyant_signet", 137040 )
spec:RegisterGear( "ekowraith_creator_of_worlds", 137015 )
spec:RegisterGear( "fiery_red_maimers", 144354 )
spec:RegisterGear( "luffa_wrappings", 137056 )
spec:RegisterGear( "soul_of_the_archdruid", 151636 )
spec:RegisterGear( "the_wildshapers_clutch", 137094 )

-- Dragonflight
spec:RegisterGear( "tier29", 200354, 200356, 200351, 200353, 200355 )
spec:RegisterAura( "sharpened_claws", {
    id = 394465,
    duration = 4,
    max_stack = 1
} )

-- Tier 30
spec:RegisterGear( "tier30", 202518, 202516, 202515, 202514, 202513 )
-- 2 pieces (Feral) : Your auto-attacks have a 25% chance to grant Shadows of the Predator, increasing your Agility by 1%. Each application past 5 has an increasing chance to reset to 2 stacks.
spec:RegisterAura( "shadows_of_the_predator", {
    id = 408340,
    duration = 20,
    max_stack = 12
} )
-- 4 pieces (Feral) : When a Shadows of the Predator application resets stacks, you gain 5% increased Agility and you generate 1 combo point every 1.5 secs for 6 sec.
spec:RegisterAura( "predator_revealed", {
    id = 408468,
    duration = 6,
    tick_time = 1.5,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207252, 207253, 207254, 207255, 207257, 217193, 217195, 217191, 217192, 217194 )
-- (2) Feral Frenzy grants Smoldering Frenzy, increasing all damage you deal by $422751s1% for $422751d.
-- (4) Feral Frenzy's cooldown is reduced by ${$s1/-1000} sec. During Smoldering Frenzy, enemies burn for $422751s6% of damage you deal as Fire over $422779d.
spec:RegisterAuras( {
    smoldering_frenzy = {
        id = 422751,
        duration = 8,
        max_stack = 1
    },
    burning_frenzy = {
        id = 422779,
        duration = 10,
        max_stack = 1
    }
} )

-- Legion Sets (for now).
spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )
    spec:RegisterAura( "apex_predator", {
        id = 252752,
        duration = 25
     } ) -- T21 Feral 4pc Bonus.

spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 )
spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )


local function calculate_damage( coefficient, masteryFlag, armorFlag, critChanceMult )
    local feralAura = 1
    local armor = armorFlag and 0.7 or 1
    local crit = min( ( 1 + state.stat.crit * 0.01 * ( critChanceMult or 1 ) ), 2 )
    local vers = 1 + state.stat.versatility_atk_mod
    local mastery = masteryFlag and ( 1 + state.stat.mastery_value * 0.01 ) or 1
    local tf = state.buff.tigers_fury.up and class.auras.tigers_fury.multiplier or 1

    return coefficient * state.stat.attack_power * crit * vers * mastery * feralAura * armor * tf
end

-- Force reset when Combo Points change, even if recommendations are in progress.
spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( _, _, powerType )
    if powerType == "COMBO_POINTS" then
        Hekili:ForceUpdate( powerType, true )
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Your skin becomes as tough as bark, reducing all damage you take by $s1% and preventing damage from delaying your spellcasts. Lasts $d.    Usable while stunned, frozen, incapacitated, feared, or asleep, and in all shapeshift forms.
    barkskin = {
        id = 22812,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "nature",

        startsCombat = false,

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

        spend = -25,
        spendType = "rage",

        startsCombat = false,

        essential = true,
        noform = "bear_form",

        handler = function ()
            shift( "bear_form" )
            if talent.ursine_vigor.enabled or conduit.ursine_vigor.enabled then applyBuff( "ursine_vigor" ) end
        end,
    },

    -- Talent: Go Berserk for $d. While Berserk:    Finishing moves have a $343223s1% chance per combo point spent to refund $343216s1 combo $lpoint:points;.    Swipe generates $s3 additional combo $Lpoint:points;.    Rake and Shred deal damage as though you were stealthed.
    berserk = {
        id = 106951,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * ( talent.berserk_heart_of_the_lion.enabled and 180 or 120 ) end,
        gcd = "off",
        school = "physical",

        talent = "berserk",
        notalent = "incarnation",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if buff.cat_form.down then shift( "cat_form" ) end
            applyBuff( "berserk" )
            for i = 1.5, spec.auras.berserk.duration, 1.5 do
                state:QueueAuraEvent( "incarnation_combo_point_periodic", ComboPointPeriodic, query_time + i, "AURA_TICK" )
            end
        end,

        copy = { "berserk_cat", "bs_inc" }
    },

    -- Talent: Strikes all nearby enemies with a massive slash, inflicting $s2 Physical damage.$?a231063[ Deals $231063s1% increased damage against bleeding targets.][] Deals reduced damage beyond $s3 targets.    |cFFFFFFFFAwards $s1 combo $lpoint:points;.|r
    brutal_slash = {
        id = 202028,
        cast = 0,
        charges = 3,
        cooldown = 8,
        recharge = 8,
        hasteCD = true,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.clearcasting.up then return 0 end
            return 25 * ( buff.incarnation.up and 0.75 or 1 )
        end,
        spendType = "energy",

        talent = "brutal_slash",
        startsCombat = true,

        form = "cat_form",

        damage = function ()
            return calculate_damage( 1.476, false, true ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 )
        end,

        max_targets = 5,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.brutal_slash.spend ) end,

        handler = function ()
            gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1 + ( allow_crit_prediction and crit_pct_current * active_enemies >= 230 and 1 or 0 ), "combo_points" )
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end

            if talent.bloodtalons.enabled then
                applyBuff( "bt_brutal_slash" )
                check_bloodtalons()
            end

            if talent.thrashing_claws.enabled and talent.thrash.enabled then
                applyDebuff( "target", "thrash_cat" ) 
                active_dot.thrash_cat = min( true_active_enemies, active_dot.thrash_cat + active_enemies  )
            end
            
            removeStack( "clearcasting" )
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
        essential = true,
        noform = "cat_form",

        handler = function ()
            shift( "cat_form" )
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
        startsCombat = false,

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

        toggle = "cooldowns",
        notalent = "tiger_dash",

        handler = function ()
            shift( "cat_form" )
            applyBuff( "dash" )
        end,
    },


    strength_of_the_wild = {
        id = 236716,
        cast = 0,
        cooldown = 3,
        gcd = "spell",

        pvptalent = "strength_of_the_wild",
        form = "bear_form",

        spend = 40,
        spendType = "rage",

        startsCombat = true,
        texture = 132136,

        handler = function ()
        end,

        copy = "enraged_maul"
    },


    entangling_roots = {
        id = 339,
        cast = function ()
            if buff.predatory_swiftness.up then return 0 end
            return 1.7 * ( buff.heart_of_the_wild.up and 0.7 or 1 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 136100,

        handler = function ()
            applyDebuff( "target", "entangling_roots" )
            removeBuff( "predatory_swiftness" )
        end,
    },

    -- Talent: Unleash a furious frenzy, clawing your target $m2 times for ${$274838s1*$m2} Physical damage and an additional ${$m2*$274838s3*$274838d/$274838t3} Bleed damage over $274838d.    |cFFFFFFFFAwards $s1 combo points.|r
    feral_frenzy = {
        id = 274837,
        cast = 0,
        cooldown = function() return ( set_bonus.tier31_4pc > 0 and 30 or 45 ) - ( 5 * talent.tear_down_the_mighty.rank ) end,
        gcd = "totem",
        school = "physical",

        damage = function ()
            return calculate_damage( 0.099 * 5, true, true )
        end,
        tick_damage = function ()
            return calculate_damage( 0.198 * 5, true )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.198 * 5, true )
        end,

        spend = function ()
            return 25 * ( buff.incarnation.up and 0.75 or 1 ), "energy"
        end,
        spendType = "energy",

        talent = "feral_frenzy",
        startsCombat = true,

        form = "cat_form",
        indicator = function ()
            if active_enemies > 1 and settings.cycle and target.time_to_die < longest_ttd then return "cycle" end
        end,

        handler = function ()
            gain( 5, "combo_points", false )
            applyDebuff( "target", "feral_frenzy" )
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end
            if set_bonus.tier31_2pc > 0 then applyBuff( "smoldering_frenzy" ) end
        end,

        copy = "ashamanes_frenzy"
    },

    -- Finishing move that causes Physical damage per combo point and consumes up to $?a102543[${$s2*(1+$102543s2/100)}][$s2] additional Energy to increase damage by up to 100%.       1 point  : ${$m1*1/5} damage     2 points: ${$m1*2/5} damage     3 points: ${$m1*3/5} damage     4 points: ${$m1*4/5} damage     5 points: ${$m1*5/5} damage
    ferocious_bite = {
        id = function() return buff.ravage.up and 441591 or 22568 end,
        known = 22568,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.apex_predator.up or buff.apex_predators_craving.up then return 0 end
            -- Support true/false or 1/0 through this awkward transition.
            if args.max_energy and ( type( args.max_energy ) == 'boolean' or args.max_energy > 0 ) then return 50 * ( buff.incarnation.up and 0.75 or 1 ) * ( talent.relentless_predator.enabled and 0.9 or 1 ) end
            return max( 25, min( 50 * ( buff.incarnation.up and 0.75 or 1 ), energy.current ) ) * ( talent.relentless_predator.enabled and 0.9 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,
        texture = function() return buff.ravage.up and 5927623 or 132127 end,
        form = "cat_form",

        cycle = function() return hero_tree.wildstalker and "bloodseeker_vines" or "rip" end,
        cycle_to = true,

        -- Use maximum damage.
        damage = function () 
            return calculate_damage( 1.45 * 2 , true, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1 ) * ( talent.sabertooth.enabled and 1.15 or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 ) * ( talent.lions_strength.enabled and 1.15 or 1 ) *
                ( 1 + ( talent.taste_for_blood.enabled and ( buff.tigers_fury.up and 0.24 or 0.12 ) or 0 ) ) * ( talent.bestial_strength.enabled and 1.1 or 1 ) * ( buff.coiled_to_spring.up and 1.1 or 1 )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.ferocious_bite.spend ) end,

        usable = function () return buff.apex_predator.up or buff.apex_predators_craving.up or combo_points.current > 0 end,

        handler = function ()
            if talent.coiled_to_spring.enabled then removeBuff( "coiled_to_spring" ) end
            if talent.ravage.enabled then removeBuff( "ravage" ) end
            if talent.bloodtalons.enabled then removeStack( "bloodtalons" ) end
            if talent.sabertooth.enabled then applyDebuff( "target", "sabertooth" ) end
            if state.spec.restoration and talent.master_shapeshifter.enabled and combo_points.current == 5 then gain( 175000, "mana" ) end

            if buff.apex_predator.up or buff.apex_predators_craving.up then
                applyBuff( "predatory_swiftness" )
                removeBuff( "apex_predator" )
                removeBuff( "apex_predators_craving" )
            else
                spend( min( 5, combo_points.current ), "combo_points" )
            end

            --Legacy / PvP
            if legendary.eye_of_fearful_symmetry.enabled and buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end
            if pvptalent.ferocious_wound.enabled and combo_points.current >= 5 then
                applyDebuff( "target", "ferocious_wound", nil, min( 2, debuff.ferocious_wound.stack + 1 ) )
            end
            -- opener_done = true
        end,

        copy = { 22568, "ferocious_bite_max", 441591, "ravage" }
    },

    -- Talent: Heals you for $o1% health over $d$?s301768[, and increases healing received by $301768s1%][].
    frenzied_regeneration = {
        id = 22842,
        cast = 0,
        charges = function () if talent.innate_resolve.enabled then return 2 end end,
        cooldown = function () return 36 * ( buff.berserk.up and talent.berserk_persistence.enabled and 0 or 1 ) * ( 1 - 0.2 * talent.reinvigoration.rank ) end,
        recharge = function () if talent.innate_resolve.enabled then return ( 36 * ( buff.berserk.up and talent.berserk_persistence.enabled and 0 or 1 ) ) end end,
        gcd = "spell",
        school = "physical",

        spend = function() return ( buff.cat_form.up and talent.empowered_shapeshifting.enabled ) and 40 or 10 end,
        spendType = function() return ( buff.cat_form.up and talent.empowered_shapeshifting.enabled ) and "energy" or "rage" end,

        talent = "frenzied_regeneration",
        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        form = function() return ( buff.cat_form.up and talent.empowered_shapeshifting.enabled ) and "cat_form" or "bear_form" end,
        nobuff = "frenzied_regeneration",

        handler = function ()
            applyBuff( "frenzied_regeneration" )
            gain( health.max * 0.08, "health" )
        end,
    },

    -- Taunts the target to attack you.
    growl = {
        id = 6795,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        form = "bear_form",

        handler = function ()
            applyDebuff( "target", "growl" )
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
        startsCombat = false,

        handler = function ()
            shift( "bear_form" )
            applyDebuff( "target", "incapacitating_roar" )
        end,
    },

    -- An improved Cat Form that grants all of your known Berserk effects and lasts $d. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation:; Energy cost of all Cat Form abilities is reduced by $s3%, and Prowl can be used once while in combat.$?s343223[; Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $106951s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap.; All attack and ability damage is increased by $s4%.][];
    incarnation = {
        id = 102543,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * ( talent.berserk_heart_of_the_lion.enabled and 120 or 180 ) end,
        gcd = "off",
        school = "physical",

        talent = "incarnation",
        startsCombat = false,
        toggle = "cooldowns",
        nobuff = "incarnation", -- VoP

        handler = function ()
            if buff.cat_form.down then shift( "cat_form" ) end
            applyBuff( "incarnation" )
            applyBuff( "jungle_stalker" )
            if talent.ashamanes_guidance.enabled then applyBuff( "ashamanes_guidance", buff.incarnation.remains + 40 ) end
            setCooldown( "prowl", 0 )

            for i = 1.5, spec.auras.incarnation.duration, 1.5 do
                state:QueueAuraEvent( "incarnation_combo_point_periodic", ComboPointPeriodic, query_time + i, "AURA_TICK" )
            end

        end,

        copy = { "incarnation_avatar_of_ashamane", "Incarnation" }
    },

    -- Talent: Increases armor by ${$s1*$AGI/100} for $d.$?a231070[ Multiple uses of this ability may overlap.][]
    ironfur = {
        id = 192081,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",
        school = "nature",

        spend = 40,
        spendType = "rage",

        talent = "ironfur",
        startsCombat = false,
        form = "bear_form",

        handler = function ()
            applyBuff( "ironfur", 6 + buff.ironfur.remains )
        end,
    },

    -- Talent: Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point:       1 point  : ${$s2*1} damage, 1 sec     2 points: ${$s2*2} damage, 2 sec     3 points: ${$s2*3} damage, 3 sec     4 points: ${$s2*4} damage, 4 sec     5 points: ${$s2*5} damage, 5 sec
    maim = {
        id = 22570,
        cast = 0,
        cooldown = 20,
        gcd = "totem",
        school = "physical",

        spend = function () return 30 * ( buff.incarnation.up and 0.75 or 1 ) end,
        spendType = "energy",

        talent = "maim",
        startsCombat = false,
        form = "cat_form",

        usable = function () return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            applyDebuff( "target", "maim", combo_points.current )
            if state.spec.restoration and talent.master_shapeshifter.enabled and combo_points.current == 5 then gain( 175000, "mana" ) end
            spend( combo_points.current, "combo_points" )

            removeBuff( "iron_jaws" )

            if legendary.eye_of_fearful_symmetry.enabled and buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end

            -- opener_done = true
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
            removeBuff( "vicious_cycle_mangle" )
            addStack( "vicious_cycle_maul" )

            if talent.fluid_form.enabled and buff.bear_form.down then shift( "bear_form" ) end

            if talent.guardian_of_elune.enabled then applyBuff( "guardian_of_elune" ) end

            if buff.gore.up then
                gain( 4, "rage" )
                removeBuff( "gore" )
            end

            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end
            if conduit.savage_combatant.enabled then addStack( "savage_combatant", nil, 1 ) end
        end,
    },

    -- Talent: Roots the target and all enemies within $A1 yards in place for $d. Damage may interrupt the effect. Usable in all shapeshift forms.
    mass_entanglement = {
        id = 102359,
        cast = 0,
        cooldown = function () return 30  * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
        gcd = "spell",
        school = "nature",

        talent = "mass_entanglement",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mass_entanglement" )
            active_dot.mass_entanglement = max( active_dot.mass_entanglement, true_active_enemies )
        end,
    },

    -- Talent: Invokes the spirit of Ursoc to stun the target for $d. Usable in all shapeshift forms.
    mighty_bash = {
        id = 5211,
        cast = 0,
        cooldown = function () return 60 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
        gcd = "spell",
        school = "physical",

        talent = "mighty_bash",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mighty_bash" )
        end,
    },


    lunar_inspiration = {
        id = 155625,
        known = 8921,
        flash = { 8921, 155625 },
        suffix = "(Cat)",
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return 30 * ( buff.incarnation.up and 0.75 or 1 ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 136096,

        talent = "lunar_inspiration",
        form = "cat_form",

        damage = function ()
            return calculate_damage( 0.12 )
        end,
        tick_damage = function ()
            return calculate_damage( 0.12 )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.12 )
        end,

        cycle = "lunar_inspiration",
        aura = "lunar_inspiration",

        handler = function ()
            applyDebuff( "target", "lunar_inspiration" )
            debuff.lunar_inspiration.pmultiplier = persistent_multiplier
            gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1 + ( allow_crit_prediction and crit_pct_current >= 95 and 1 or 0 ), "combo_points" )
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end

            if talent.bloodtalons.enabled then
                applyBuff( "bt_moonfire" )
                check_bloodtalons()
            end
        end,

        bind = "moonfire",

        copy = { 155625, "moonfire_cat" }
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

        startsCombat = false,
        cycle = "moonfire",
        form = "moonkin_form",

        handler = function ()
            if not buff.moonkin_form.up then unshift() end
            applyDebuff( "target", "moonfire" )
        end,

        bind = { "lunar_inspiration", "moonfire_cat" }
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

        handler = function ()
            shift( "moonkin_form" )
        end,
    },

    -- Talent: Finishing move that deals instant damage and applies Rip to all enemies within $A1 yards. Lasts longer per combo point.       1 point  : ${$s1*2} plus Rip for ${$s2*2} sec     2 points: ${$s1*3} plus Rip for ${$s2*3} sec     3 points: ${$s1*4} plus Rip for ${$s2*4} sec     4 points: ${$s1*5} plus Rip for ${$s2*5} sec     5 points: ${$s1*6} plus Rip for ${$s2*6} sec
    primal_wrath = {
        id = 285381,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return 25 * ( buff.incarnation.up and 0.75 or 1 ) end,
        spendType = "energy",

        talent = "primal_wrath",
        startsCombat = true,

        aura = "rip",

        apply_duration = function ()
            return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 2 + 2 * combo_points.current )
        end,

        max_apply_duration = function ()
            return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 12 )
        end,

        ticks_gained_on_refresh = function()
            return tick_calculator( debuff.rip, "primal_wrath", false )
        end,

        ticks_gained_on_refresh_pmultiplier = function()
            return tick_calculator( debuff.rip, "primal_wrath", true )
        end,

        form = "cat_form",

        usable = function () return combo_points.current > 0, "no combo points" end,
        handler = function ()
            applyDebuff( "target", "rip", action.primal_wrath.apply_duration )
            active_dot.rip = active_enemies

            spend( combo_points.current, "combo_points" )
            if talent.bloodtalons.enabled then removeStack( "bloodtalons" ) end
            if talent.coiled_to_spring.enabled then removeBuff( "coiled_to_spring" ) end
            if talent.rip_and_tear.enabled then applyDebuff( "target", "tear" ) end

            if legendary.eye_of_fearful_symmetry.enabled and buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end

            -- opener_done = true
        end,
    },

    -- Shift into Cat Form and enter stealth.
    prowl = {
        id = function () return buff.incarnation.up and 102547 or 5215 end,
        known = function()
            return time == 0 or ( boss or encounter or settings.solo_prowl ) and buff.jungle_stalker.up
        end,
        cast = 0,
        cooldown = function ()
            if buff.prowl.up then return 0 end
            return 6
        end,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        nobuff = "prowl",

        usable = function ()
            Hekili:Debug( "Time(%d), Jungle Stalker(%s), Incarnation of Ashamane Prowl(%s)", time, tostring( buff.jungle_stalker.up ), tostring( buff.incarnation_avatar_of_ashamane_prowl.up ) )
            return time == 0 or ( boss or encounter or settings.solo_prowl ) and buff.jungle_stalker.up, "requires out of combat or incarnation_avatar_of_ashamane_prowl"
        end,

        handler = function ()
            shift( "cat_form" )
            applyBuff( buff.jungle_stalker.up and "prowl_incarnation" or "prowl_base" )
            removeBuff( "jungle_stalker" )
        end,

        copy = { 5215, 102547 }
    },

    -- Talent: Rake the target for $s1 Bleed damage and an additional $155722o1 Bleed damage over $155722d.$?s48484[ Reduces the target's movement speed by $58180s1% for $58180d.][]$?a231052[     While stealthed, Rake will also stun the target for $163505d and deal $s4% increased damage.][]    |cFFFFFFFFAwards $s2 combo $lpoint:points;.|r
    rake = {
        id = 1822,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            return 35 * ( buff.incarnation.up and talent.incarnation_avatar_of_ashamane.enabled and  0.75 or 1 ), "energy"
        end,
        spendType = "energy",

        talent = "rake",
        startsCombat = true,

        cycle = "rake",
        min_ttd = 6,

        damage = function ()
            return calculate_damage( 0.16, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.infected_wounds.enabled and 1.3 or 1 ) * ( 1 + 0.05 * talent.instincts_of_the_claw.rank )
        end,
        tick_damage = function ()
            return calculate_damage( 0.2311, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.infected_wounds.enabled and 1.3 or 1 ) * ( 1 + 0.05 * talent.instincts_of_the_claw.rank )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.2311, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.infected_wounds.enabled and 1.3 or 1 ) * ( 1 + 0.05 * talent.instincts_of_the_claw.rank )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.rake.spend ) end,

        form = function()
            if talent.fluid_form.enabled then return end
            return "cat_form"
        end,

        handler = function ()
            if talent.fluid_form.enabled and buff.cat_form.down then shift( "cat_form" ) end

            applyDebuff( "target", "rake" )
            debuff.rake.pmultiplier = persistent_multiplier
            if talent.sudden_ambush.enabled then removeBuff( "sudden_ambush" ) end
            if talent.doubleclawed_rake.enabled then active_dot.rake = min( true_active_enemies, active_dot.rake + 1 ) end
            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end
            if talent.bloodtalons.enabled then
                applyBuff( "bt_rake" )
                check_bloodtalons()
            end

            gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1 + ( allow_crit_prediction and crit_pct_current >= 95 and 1 or 0 ), "combo_points" )


        end,

        copy = "rake_bleed"
    },

    -- Heals a friendly target for $s1 and another ${$o2*$<mult>} over $d.$?s231032[ Initial heal has a $231032s1% increased chance for a critical effect if the target is already affected by Regrowth.][]$?s24858|s197625[ Usable while in Moonkin Form.][]$?s33891[    |C0033AA11Tree of Life: Instant cast.|R][]
    regrowth = {
        id = 8936,
        cast = function ()
            if buff.predatory_swiftness.up then return 0 end
            return 1.5 * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.10,
        spendType = "mana",

        startsCombat = false,

        usable = function ()
            if buff.prowl.up then return false, "prowling" end
            if buff.cat_form.up and time > 0 and buff.predatory_swiftness.down then return false, "predatory_swiftness is down" end
            return true
        end,

        handler = function ()
            if buff.predatory_swiftness.down then
                unshift()
            end

            removeBuff( "predatory_swiftness" )
            removeBuff( "protector_of_the_pack" )
            applyBuff( "regrowth" )
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

        handler = function ()
            unshift()
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
            return debuff.dispellable_curse.up or debuff.dispellable_poison.up, "requires dispellable curse or poison"
        end,

        handler = function ()
            removeDebuff( "player", "dispellable_curse" )
            removeDebuff( "player", "dispellable_poison" )
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

        toggle = "cooldowns",

        handler = function ()
            health.actual = min( health.max, health.actual + ( 0.2 * health.max ) )
        end,
    },

    -- Talent: Finishing move that causes Bleed damage over time. Lasts longer per combo point.       1 point  : ${$o1*2} over ${$d*2} sec     2 points: ${$o1*3} over ${$d*3} sec     3 points: ${$o1*4} over ${$d*4} sec     4 points: ${$o1*5} over ${$d*5} sec     5 points: ${$o1*6} over ${$d*6} sec
    rip = {
        id = 1079,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return 20 * ( buff.incarnation.up and 0.75 or 1 ) end,
        spendType = "energy",

        talent = "rip",
        startsCombat = true,

        aura = "rip",
        cycle = "rip",
        min_ttd = 9.6,

        tick_damage = function ()
            return ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * calculate_damage( 0.2512, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 ) * ( talent.lions_strength.enabled and 1.15 or 1 ) * ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * ( talent.wildstalkers_power.enabled and 1.05 or 1 )
        end,
        tick_dmg = function ()
            return ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * calculate_damage( 0.2512, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 ) * ( talent.lions_strength.enabled and 1.15 or 1 ) * ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * ( talent.wildstalkers_power.enabled and 1.05 or 1 )
        end,

        form = "cat_form",

        apply_duration = function ()
            return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 4 + 4 * combo_points.current )
        end,

        usable = function ()
            if combo_points.current == 0 then return false, "no combo points" end

            local rip_duration = settings.rip_duration or 0
            if rip_duration > 0 and target.time_to_die < rip_duration then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. rip_duration .. ")" end
            --[[ if settings.hold_bleed_pct > 0 then
                local limit = settings.hold_bleed_pct * debuff.rip.duration
                if target.time_to_die < limit then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. limit .. ")" end
            end ]]
            return true
        end,

        handler = function ()
            applyDebuff( "target", "rip" )
            debuff.rip.pmultiplier = persistent_multiplier
            if state.spec.restoration and talent.master_shapeshifter.enabled and combo_points.current == 5 then gain( 175000, "mana" ) end
            spend( combo_points.current, "combo_points" )

            if talent.bloodtalons.enabled then removeStack( "bloodtalons" ) end
            if talent.rip_and_tear.enabled then applyDebuff( "target", "tear" ) end

            if legendary.eye_of_fearful_symmetry.enabled and buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end

            

            -- opener_done = true
        end,
    },

    -- Shred the target, causing $s1 Physical damage to the target.$?a231063[ Deals $231063s2% increased damage against bleeding targets.][]$?a343232[    While stealthed, Shred deals $m3% increased damage, has double the chance to critically strike, and generates $343232s1 additional combo $lpoint:points;.][]    |cFFFFFFFFAwards $s2 combo $lpoint:points;.
    shred = {
        id = 5221,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.clearcasting.up then return 0 end
            return 40 * ( buff.incarnation.up and talent.incarnation_avatar_of_ashamane.enabled and 0.75 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,
        form = function()
            if talent.fluid_form.enabled then return end
            return "cat_form"
        end,

        damage = function ()
            return calculate_damage( 1.025, false, true, ( talent.pouncing_strikes.enabled and effective_stealth and class.auras.prowl.multiplier or 1 ) * ( 1 + ( talent.instincts_of_the_claw.rank * 0.05 )  ) * ( talent.empowered_shapeshifting and 1.06 or 1 ) * ( talent.merciless_claws.enabled and bleeding and 1.2 or 1 ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.berserk.enabled and buff.bs_inc.up and class.auras.berserk.multiplier or 1 ) )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.shred.spend ) end,

        handler = function ()
            if talent.fluid_form.enabled and buff.cat_form.down then shift( "cat_form" ) end
            if talent.thrashing_claws.enabled and talent.thrash.enabled then applyDebuff( "target", "thrash_cat" ) end
            if talent.bloodtalons.enabled then
                applyBuff( "bt_shred" )
                check_bloodtalons()
            end

            gain( 1 + ( talent.berserk.enabled and buff.bs_inc.up and 1 or 0 ) + ( talent.pouncing_strikes.enabled and buff.prowl.up and 1 or 0 ) + ( allow_crit_prediction and crit_pct_current >= 95 and 1 or 0 ), "combo_points" )

            removeStack( "clearcasting" )
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
        startsCombat = false,

        toggle = "interrupts",
        interrupt = true,

        form = function () return buff.bear_form.up and "bear_form" or "cat_form" end,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if pvptalent.savage_momentum.enabled then
                gainChargeTime( "tigers_fury", 10 )
                gainChargeTime( "survival_instincts", 10 )
                gainChargeTime( "stampeding_roar", 10 )
            end
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
        startsCombat = false,

        toggle = "interrupts",

        usable = function () return debuff.dispellable_enrage.up end,
        handler = function ()
            removeDebuff( "target", "dispellable_enrage" )
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

    -- Talent: Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within $A1 yards by $s1% for $d.
    stampeding_roar = {
        id = 106898,
        cast = 0,
        cooldown = function () return pvptalent.freedom_of_the_herd.enabled and 60 or 120 end,
        gcd = "spell",
        school = "physical",

        talent = "stampeding_roar",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if buff.bear_form.down and buff.cat_form.down then
                shift( "bear_form" )
            end
            applyBuff( "stampeding_roar" )
        end,
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
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "sunfire" )
            if talent.improved_sunfire.enabled then active_dot.sunfire = active_enemies end
        end,
    },

    -- Talent: Swipe nearby enemies, inflicting Physical damage. Damage varies by shapeshift form.$?s137011[    |cFFFFFFFFAwards $s1 combo $lpoint:points;.|r][]
    swipe_cat = {
        id = 106785,
        known = 213764,
        suffix = "(Cat)",
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.clearcasting.up then return 0 end
            return max( 0, ( 35 * ( buff.incarnation.up and 0.75 or 1 ) ) + buff.scent_of_blood.v1 )
        end,
        spendType = "energy",

        startsCombat = true,
        notalent = "brutal_slash",
        form = "cat_form",

        damage = function ()
            return calculate_damage( 0.3824, false, true ) * ( talent.merciless_claws.enabled and bleeding and 1.1 or 1 ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 ) * ( talent.merciless_claws.enabled and ( debuff.rip.up or debuff.rake.up or debuff.thrash_cat.up ) and 1.1 or 1 )
        end,

        max_targets = 5,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.swipe_cat.spend ) end,

        handler = function ()
            gain( talent.berserk.enabled and 2 or 1 + ( allow_crit_prediction and crit_pct_current * active_enemies >= 230 and 1 or 0 ), "combo_points" )

            if talent.bloodtalons.enabled then
                applyBuff( "bt_swipe" )
                check_bloodtalons()
            end

            if talent.cats_curiosity.enabled and buff.clearcasting.up then
                gain( 35 * 0.25, "energy" )
            end

            if talent.thrashing_claws.enabled then
                applyDebuff( "target", "thrash_cat" )
                active_dot.thrash_cat = max( active_enemies, active_dot.thrash_cat )
            end
            removeStack( "clearcasting" )
        end,

        copy = { 213764, "swipe" },
        bind = { "swipe_cat", "swipe_bear", "swipe", "brutal_slash" }
    },

    -- Sprout thorns for $d on the friendly target. When victim to melee attacks, thorns deals $305496s1 Nature damage back to the attacker.    Attackers also have their movement speed reduced by $232559s1% for $232559d.
    thorns = {
        id = 305497,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "nature",

        spend = 0.18,
        spendType = "mana",

        pvptalent = "thorns",
        startsCombat = false,

        handler = function ()
            applyBuff( "thorns" )
        end,
    },

    -- Talent: Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    thrash_cat = {
        id = 106830,
        known = 106832,
        suffix = "(Cat)",
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if buff.clearcasting.up then return 0 end
            return 40 * ( buff.incarnation.up and 0.75 or 1 )
        end,
        spendType = "energy",

        talent = "thrash",
        startsCombat = false,

        aura = "thrash_cat",
        cycle = "thrash_cat",

        damage = function ()
            return calculate_damage( 0.202, true ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 )
        end,
        tick_damage = function ()
            return calculate_damage( 0.4865, true ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.4865, true ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 )
        end,

        form = "cat_form",
        handler = function ()
            applyDebuff( "target", "thrash_cat" )

            active_dot.thrash_cat = max( active_dot.thrash, active_enemies )
            debuff.thrash_cat.pmultiplier = persistent_multiplier

            if talent.cats_curiosity.enabled and buff.clearcasting.up then
                gain( 40 * 0.25, "energy" )
            end
            removeStack( "clearcasting" )

            if talent.scent_of_blood.enabled then
                applyBuff( "scent_of_blood" )
                buff.scent_of_blood.v1 = -3 * active_enemies
            end

            -- if target.within8 then
                gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1 + ( allow_crit_prediction and crit_pct_current * active_enemies >= 230 and 1 or 0 ), "combo_points" )
            -- end

            if talent.bloodtalons.enabled then
                applyBuff( "bt_thrash" )
                check_bloodtalons()
            end
        end,

        copy = { "thrash", 106832 },
        bind = { "thrash_cat", "thrash_bear", "thrash" }
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
            shift( "cat_form" )
            applyBuff( "tiger_dash" )
        end,
    },

    -- Talent: Instantly restores $s2 Energy, and increases the damage of all your attacks by $s1% for their full duration. Lasts $d.
    tigers_fury = {
        id = 5217,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        school = "physical",

        spend = -50,
        spendType = "energy",

        talent = "tigers_fury",
        startsCombat = false,

        usable = function () return buff.tigers_fury.down or energy.deficit > 50 + energy.regen end,
        handler = function ()
            shift( "cat_form" )
            applyBuff( "tigers_fury" )
            if talent.savage_fury.enabled then applyBuff( "savage_fury" ) end
            if talent.tigers_tenacity.enabled then addStack( "tigers_tenacity", nil, 3 ) end
            if talent.killing_strikes.enabled and buff.ravage_upon_combat.up then
                applyBuff( "ravage" )
                removeBuff( "ravage_upon_combat" )
            end

            -- Legacy
            if legendary.eye_of_fearful_symmetry.enabled then
                applyBuff( "eye_of_fearful_symmetry", nil, 2 )
            end
            if azerite.jungle_fury.enabled then applyBuff( "jungle_fury" ) end
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
    damageDots = false,
    damageExpiration = 3,

    potion = "tempered_potion",

    package = "Feral"
} )

--[[ TODO: Revisit due to removal of Relentless Predator.
spec:RegisterSetting( "use_funnel", false, {
    name = strformat( "%s Funnel", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ) ),
    desc = function()
        return strformat( "If checked, when %s and %s are talented and %s is |cFFFFD100not|r talented, %s will be recommended over %s unless |W%s|w needs to be "
            .. "refreshed.\n\n"
            .. "Requires %s\n"
            .. "Requires %s\n"
            .. "Requires |W|c%sno %s|r|w",
            Hekili:GetSpellLinkWithTexture( spec.talents.taste_for_blood[2] ), Hekili:GetSpellLinkWithTexture( spec.talents.relentless_predator[2] ),
            Hekili:GetSpellLinkWithTexture( spec.talents.tear_open_wounds[2] ), Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ),
            Hekili:GetSpellLinkWithTexture( spec.abilities.primal_wrath.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ),
            Hekili:GetSpellLinkWithTexture( spec.talents.taste_for_blood[2], nil, state.talent.taste_for_blood.enabled ),
            Hekili:GetSpellLinkWithTexture( spec.talents.relentless_predator[2], nil, state.talent.relentless_predator.enabled ),
            ( not state.talent.tear_open_wounds.enabled and "FF00FF00" or "FFFF0000" ),
            Hekili:GetSpellLinkWithTexture( spec.talents.tear_open_wounds[2], nil, not state.talent.tear_open_wounds.enabled ) )
    end,
    type = "toggle",
    width = "full"
} )  ]]

--[[ Currently handled by the APL
spec:RegisterSetting( "zerk_biteweave", false, {
    name = strformat( "%s Biteweave", Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ) ),
    desc = function()
        return strformat( "If checked, the default priority will recommend %s more often when %s or %s is active.\n\n"
            .. "This option may not be optimal for all situations; the default setting is unchecked.", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ),
            Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.incarnation.id ) )
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterVariable( "zerk_biteweave", function()
    return settings.zerk_biteweave ~= false
end )--]]

--[[ spec:RegisterSetting( "owlweave_cat", false, {
    name = "|T136036:0|t Attempt Owlweaving (Experimental)",
    desc = "If checked, the addon will swap to Moonkin Form based on the default priority.",
    type = "toggle",
    width = "full"
} ) ]]

spec:RegisterSetting( "rip_duration", 9, {
    name = strformat( "%s Duration", Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ) ),
    desc = strformat( "If set above |cFFFFD1000|r, %s will not be recommended if the target will die within the specified timeframe.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ) ),
    type = "range",
    min = 0,
    max = 18,
    step = 0.1,
    width = 1.5
} )

spec:RegisterSetting( "frenzy_cp", 2, {
    name = strformat( "%s: Combo Point Cap", Hekili:GetSpellLinkWithTexture( spec.abilities.feral_frenzy.id ) ),
    desc = strformat( "In the default priority, %s will only be recommended if you have fewer than the specified number of Combo Points. "
        .. "When |W%s|w or |W%s|w is active, this cap is raised by one point.\n\nDefault: |cFFFFD1002|r",
        Hekili:GetSpellLinkWithTexture( spec.abilities.feral_frenzy.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.incarnation.id ) ),
    type = "range",
    min = 1,
    max = 5,
    step = 1,
    width = 1.5
} )

spec:RegisterSetting( "vigil_damage", 50, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( class.specs[ 102 ].abilities.natures_vigil.id ) ),
    desc = strformat( "If set below |cFFFFD100100%%|r, %s may only be recommended if your health has dropped below the specified percentage.\n\n"
        .. "By default, |W%s|w also requires the |cFFFFD100Defensives|r toggle to be active.",
        Hekili:GetSpellLinkWithTexture( class.specs[ 102 ].abilities.natures_vigil.id ),
        class.specs[ 102 ].abilities.natures_vigil.name ),
    type = "range",
    min = 1,
    max = 100,
    step = 1,
    width = 1.5
} )

spec:RegisterSetting( "allow_crit_prediction", true, {
    name = strformat( "%s Combo Point Prediction", Hekili:GetSpellLinkWithTexture( 159286 ) ), -- Primal Fury
    desc = strformat( "This setting enables prediction of an additional combo point on critical strikes when talented into %s.\n\n" ..
                      "This prediction activates only when it is |cFFFFD10095%%|r certain a critical strike will occur based on your critical strike chance and the number of targets the spell will hit.",
                      Hekili:GetSpellLinkWithTexture( 159286 )
    ),
    type = "toggle",
    width = "full",
} )

spec:RegisterVariable( "allow_crit_prediction", function()
    return settings.allow_crit_prediction ~= false
end )

spec:RegisterSetting( "lazy_swipe", false, {
    name = strformat( "%s: Don't %s in AOE", Hekili:GetSpellLinkWithTexture( spec.talents.wild_slashes[2] ), Hekili:GetSpellLinkWithTexture( spec.abilities.shred.id ) ),
    desc = function()
        return strformat( "If checked, when %s is talented, the use of %s will be minimized in multi-target situations even if "
            .. "%s is talented.\n\nThis option is a DPS loss but can be easier to execute correctly.",
            Hekili:GetSpellLinkWithTexture( spec.talents.wild_slashes[2] ),
            Hekili:GetSpellLinkWithTexture( spec.abilities.shred.id ),
            Hekili:GetSpellLinkWithTexture( spec.talents.bloodtalons[2] ) )
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterVariable( "lazy_swipe", function()
    return settings.lazy_swipe ~= false
end )

spec:RegisterSetting( "regrowth", true, {
    name = strformat( "Filler %s", Hekili:GetSpellLinkWithTexture( spec.abilities.regrowth.id ) ),
    desc = strformat( "If checked, %s may be recommended when higher priority abilities are not available or recommended.\n\n"
        .. "This recommendation generally occurs at very low energy, regardless of your current health.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.regrowth.id ) ),
    type = "toggle",
    width = "full",
} )

spec:RegisterVariable( "regrowth", function()
    return settings.regrowth ~= false
end )

spec:RegisterStateExpr( "filler_regrowth", function()
    return settings.regrowth ~= false
end )

spec:RegisterSetting( "solo_prowl", false, {
    name = strformat( "Allow %s in Combat When Solo", Hekili:GetSpellLinkWithTexture( spec.abilities.prowl.id ) ),
    desc = strformat( "If checked, %s can be recommended in combat when %s is active and you are solo.\n\n"
        .. "This option is off by default because |cFFFF0000it may drop combat|r outside of a group/encounter situation.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.prowl.id ),
        Hekili:GetSpellLinkWithTexture( spec.auras.jungle_stalker.id ),
        spec.abilities.prowl.name ),
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "allow_shadowmeld", nil, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( spec.auras.shadowmeld.id ) ),
    desc = strformat( "If checked, %s can be recommended for |W%s|w players if its conditions for use are met.\n\n"
            .. "Your stealth-based abilities can be used in |W%s|w, even if your action bar does not change. |W%s|w can only be recommended in boss fights or when you "
            .. "are in a group (to avoid resetting combat).",
        Hekili:GetSpellLinkWithTexture( spec.auras.shadowmeld.id ),
        C_CreatureInfo.GetRaceInfo(4).raceName,
        spec.auras.shadowmeld.name,
        spec.auras.shadowmeld.name ),
    type = "toggle",
    width = "full",
    get = function () return not Hekili.DB.profile.specs[ 103 ].abilities.shadowmeld.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 103 ].abilities.shadowmeld.disabled = not val
    end,
} )


spec:RegisterPack( "Feral", 20241022, [[Hekili:T3ZFVnUnY(zzrr9A3K4yPeVBBXMa0R9vCT4U(o0uG7poCXwXMorVil5tsoEtrG)S)MH)sKuKu0o2B337o0I2yjQHdho)MdjVn62F72BMNutU9xIhfFz0O44Hrxo(9xm(2BQFEf52BwLm7XK7H)ipzj8F)rszsg(0NZksMJFDvX6YzWBU9M7wNMv)t53ENDqEb02vKz3(lrJG)8H05ZjS2sQMD7nyBplA0zXXF72PrrdhnC82FE7ptF8OV5S4i4X3KU873oD9ke6QVmAe8YFm9JW)HuwmlTyD12P)PuOrtxM8XjKCs59pR(bJU80TtX))x7bQJUaE5VTHK842P1jL3tQtZVVPbF9zXxk)6vLPfLP1p3goF9zrJHM9DZ)FwxvBbbxuuUD6FpnBEvDs2JKsTVeh0)1KsabkwaiXdewtp1Fhshv)uEnPSC9kOptYNd4zrb(9YM9Eg6)BuyMqXH6hsZHP2YIfPzWeAYS60I8QHRkjZkwExs9jxD(sazMuSycaQjBamz7pBRvai2KDA6IREZDRxSyi9NdxVYEJNLupbiclBAV4j0p5l2oD2dKzajifjbLP5psGXuvwb8FNvKxNKMdeZe4r1jWJkYbssfmO6)uszAYDzWFMcnGr(FKGeKuOnZsWgXiRW8k0IS0hrgM0YsCkjhH)MIYhXj9PBaIZ2PpKunbG9eelhyF0i60trXLR4O7Ki6NuD6tjzRLpDy0qva27nnppTAy6YvKYfKz1tsQMrYNNKp75jvKY1lnAyXtP5jFSAYss5S1qNNnHC)9gTbOtZkOy7KhtRQWzW5KeyiTdJHyRJHyhJH4qhdXbmgI9pg(cgVXgy2lPe(pRYsEMoRfJtN5RrXm4RFQ4rYPSMbJ2fGOMAdkYpJY2u8e(IlA)cYtKCgJqXAG14osjmsEeeHEGKuwRiHMbO4UqyJMu9C(StlwDvfOIzbNahX()tizvKRaLHNcJG5PimVcuuqYRhYhsuzXQvPG2GkGKXExs1djltYjvtUFDks3j9eD(qdMYE9ByvMvuKnVyt(W5RltW(6l)YO4rxn6LxG)3x(LEA4vJ2jbI4)GgZXh8XSoZx(BR7I)dq9Cw7NLa)bsh043MnVsOVHZJbnkb1X9qrD2UqK3zgR30FViZd2xEl5JURAsA(mfc7lV46DDmJ8YlH1JwgH27EFnSBUJWNS2zjId3KvlHI4d)KLfqQoz5VhpWtwwXfMOm3TQ0FNi91OcfzrplYsZjNbUKWfob50ZUEj49XzAoEapmRi)E0iYS5na5SRREOOSgFSOpv6HDGpr44NjNsSkNsKkFItHtxmcV8IBweV8inVdC5B2WK8NNmFvZmWGVQF0WXN00k01bQhFj3NMbJjAdIT1GLjvaTdBGfudfCgm46(Ev208UqWTOUWTOGWTioUHUDZNIvDpM(5crgaB75WF5U8swkUVidKYPpv9BRECDw2K7aDbApLhqWxaS9)fG1gJKy70paos)a4D0vV9H66vvF75NVzZMHBk2aE5mhiRlphIHll7QOrJE3OZxvSHuEwA(I1vauF71)n83yShSh8HZtUwiU8Ny2YgY6Wg0iLjXs(iqdZbh)WXgJJNc8jcGBsVwV6LxedBUDYjupXeHNO5ggLcceb2pH3vvZ6ezqcgOvvDXQjlr)sVh757NnFyjbL2RUAupY)AD6QvK529BvTtRtbnbvtwSU8zem9zHIoCozr6S06RVymQ8A5DftwvKMxxDLXVV(Ql6nVOEyz6kO7xusa15aY2JriYkkMduauVX6vd61)UIQQElsV)H6jCC9dxfbqSVP6z(BVoEKEZVE8aRToz(Zgnmk(LxWUBWa1rBzc4HZSNNLbAGPbmxbAIeZBaQdqDjjBoDUZjNEEs9AyGo5PuqWd)APuvj5EO91p0dMNZQFyieCbevr9hE)iySBWAq)Tc1hPqAOkmtSjju4R(LjZtwvN(eyGztcipAz4IZy6TAYCWk89KHGLIzp(Hl61)nUBtD6mmMZxEXDteZUXd69ggIz0WHP5twKHZy96tLxBqWgPM153vMopJmN9nadKGvtIcpqklMuxsidNxIAw4IwZYs2my3OjTuz1nrYoAoKKJtwZ7PnUgwTjDfGyj1xh1ZyyOIOlePFzYDP1ejILSI8rWYkzEsDbWWmRmbf8PAwBuQNtaC4U6Ei0aC(UAGYKEpYHDv8GU10ieRoTc(Sz1nSkAO6xi0xUrjLqSm4qZiXDf4llbJsyagiN92PNSD6tK08suNujeHrwXgW5dqzo8KkEgMQYtwbEGaqaeNRkWWjWSISb8jrZQa8jiEzW00RHrqbV6jDbLHpubnX0wdgnqiDQPVsr7DZZv4bf84J71suwQeAupdLLG2R(UAoWrPRQDGfTen6nh0UFb2btLZI2l1zAbybWBSinpTcOXiPxhj7(BXSUoN9PoejG5pvGcKufpvsxcsQ4RkY(a6l9Bm53v8ge9CAgorFxDadQKcmPqDHCxFv8rg7eQ1Ls7cb9NbnkPlQHOJqgYETTdurYiSrfIixJobSm5JkoZnuzm2YJDf8H7So3vDZXavQhzvWCzIrBuIUQn9bq)nbtAj6YVRUK1yKqIdpvFeeIxSwG4bQ2UYMgnM4jOpJ2uMPs0BONksNJPPy1kQ2M7kRWKXIZGvd3o97YQkafleu30DLRHUdtllaas15BGwsNIzjBfW5tfzqtKTeSZHbBbo(kMbGOrnWP0GKy9P0Tr7JFwhpH2V2S7O4nJslhUa9igI1IoyOZUF4siAuo728u6pltatEisJwQMxjvoaVYWFdDJrGIHZ8z5CGV5akvdbzFZOdE5fTE5dD0jUOysjpK8W5rqL6t4ZD96hoz41qf(ere0mOkzqzSGCoum69XNiwKNkroGbVzbwWZxwuKViTKeg9uN013g91LIWldHI4EEvgvj1ck4jUAedmVjPpD1Y1z1PRYsjLFiAO3oL2Em0cUtMCOIHdOhqelI0Q14s6njz5DRPAr61OTE2SjOAeYCNurz0bFYgcUqATitSpgaMQ5ZySia)deJBxmjUImsvHnNxzEXA4xi7lmsWVlOHNl0e5TVO2QmWPnQORqfT10Stv)aMvA(4b5)rlq0Xzq8)7a)ECq870rrwQcj2c6MxKFMYec3KJlmwajks3XKIhuuag30)9Nx41mLVinldSAgKftmBsbnjeWC)Rcqpa(K1KBlpAsGOxEMbpVSpi881H6(n969vAb4c8Dj4YuFxTmps7khGtna2jk(zrqRL7Req388(GU)0aD4gfsMMoydyPw1ch0UoaCya6DVIXGoFyade1OpSy83irL00ncEIn2L1U(7MP2bFviAMOpWiYzE)RMeqBdeD)a(mF00K(YVaZE(9LjZjSqAQQPPqKzqcT0I5AVCtkwibCuJzMAvs(CYY0zq8u)ajl5zHjSeSGukWiGW)Avrvv6D0szbIEkLwzkRrt5ihbRBTqlPSXymq9vnTScghqm6GIMjnuJRTYBRq5KjrzOmVjTO(2HSna715FbH32qY04v4r3fOZgT7snDL6MPT18DoGC7sbCnBume0dLuolPQ2DojTy3dxntG6aHDZk)nlbEl5eNxWRkkAbSKt(i8ZOHJboV)XFM8yAw6)C70F7)(h(Vz17gljaawtDaJMdacwDcBaZGLK)1AyqM9mTUQWSpcKoAa9eO5lPRZeIit3KKwpD7uAgrai8aJF(oK1NwQCWWWQIoyibtTSIo8ueixnAySMUtyWmHpYMubtE9mw0L3pQxR0iXfOBcL1xc9U(Iqyn3x(TgxHcAA2cauDkRdCGzrbRXUS0vcDp0egJUX0OSjVwvxd8WkLuk7r1t3gg3f9rHiEURUUSZMI5o(zAlwWWCcUKMZskZPlRmcjJvo79SvoJs1X4wmkBXMQo4ESohHNnN9w56hau(cvJdnZqPynFUGGXiXI3tPQiptf6wrBSi(sRjlpfRTsr9gW8lvBrVX2XwQgRvmsZIlQMUwJcjyq4yqSkge7edIcfdIKyWxOuHvm6ftyNVUk2WqE7LQMnClOVJvj1hS4RWSU(hkYvxmVatmmktcAvWQELWl0qArILjx1(K7PzoohvbZkwfur)J0FVQG1ZCKIf(mvpF1Z51y6STGBSpQnEXgpglY8fWWSFdHgr1Fhgy90EcV0C65TwDeqmIxoo5kvjdkqKuEgJtgRgUKNiO9dwFa6UwNHpg)Inpqq3TGFikKx4NptH093ZYAarTwIbRzOu23)dGxy)yH49yfcxj(uCMydvUkltycfRM9uWMY2PF3F7VG2zbisZm(pY63nIQoMvyPkYWd9Y(Z0nyvWT6urXRwPma4vNmUEbLnLgU)oPTuUljL2lUULfzRltMXJh0RFqZ9VdGVl1gbX9CMhLsJg0SUJ2QBohvkHFqoagAVrxdLOvwRWn(xAPmRetDxfnqTqgTwXsxRByPhZOsOZ4XwNXJ)8zgpAFMXTye41oJBfKAZ4roMXB)L(MXJhOYRSdZ4k1TK6S(C6IIKmdxEK1vWFNKxTmftA6K6KkxwWE5fDv7XXwzPwG7cOjGl25)(ZSWWuwaxSgtA5nT67JzzMoBtYZAwX4tpTQ(z0n0NlwZkyABOJL5v64RTPkFvd1LJnX7aQWmrXny6iG(iU9sLP)(laWWY00qLvq66XN5SmEfLbttzyPTkYNlZgXQnOndrSFmJMVB44tqkpzb3ZZvBov18gqnQjjy4y0TOK(hxMSCvc6TjRwAWTGedlXi2O7Ii6(JG3mn4Yah4u6tWC(CXcUjMVFhZE9ccTgcfRxW2P)Kw3)Rjpb(9Xbl10OWmCsgg1j79Sf(492HOKfsu2f0eOLUeyP3asA0O30x0c13EDuV(08mP(WgDzdhBgljllkgTwMwaSI7EJSmAO0SjckRSwN67fDOftgD5ZHaXFeeWrYBLOMI4OtjLUqrhpa7DNirfS5d4RGAjgCiYgubaeD2smZHK3vBqFkroI1RGPRFnvwI0klPpF7B1WOGZQAUBl4r4kdUJaHHs4DnMDD03UflKBGI58SLXtHHT5uSwM6yDwKKEvQGbfcRfODPcMSQw1SSM8z6eGHOzAAVE5fXJVSN(C6a780fQ5kbiNtWm7CvK1gBuzCn7BsSyYBteFJz8kDdsxRiGcqy6WkqFMjFCfjVkff5Xurq)ywSl38a1B9tWnViRszobf7PBUMlhDc8VxmMNeJOOXI8FHjyLxtjS4ZzboJa8I4tG)n(R5F03el2WOIXKWQ9jML4dzbU72WQbK9j615d7zN0)YrFfDGQLhpAvoo4K(x8vC8RKCpjhEW4rFvFFCh0uWYeljaOwMutvLcMnabN860mvTLK8I13)qtoaTwUnddyKQwjw6JY(9bQ8znRUIbj5S(XxWg(kPfbzzh8LAdCweV0ugwsQxxMtdWzDlZpj8SvMd0s6SPid6OjN87jbmwmtqOyG4AvaPA7BYoK0frJhlCt7Rgn8cWjNbdAQ)JS15jyPSJoNqBddMQ5UsdQAVWgC77APOCKB(bAlnsthXsdNzhWMlk15xQnNjIyQ)hHBpTzpwXsmHQk)UNj45wtSNsBPnTxl1USIdg1H9fSkttMEmfHlAWZik1ngix6Coo4qq9Q(rclJllwI5Qe8be4oqx3zKl6MuwyMd0)HPoG8rO)rNsIuCULr(5kIqlQldanvYGIGBnKaJoXBJK79LR1JRieiRBzkikG0F(z0CzzHomTR)5Bz(1btpieW1NOAfDl)UGNXLtLRtbFtJ)fHWeiYyvlsREecNy(Cbb8KXhisiWjww8rQoDpeswY5SqhzEDPS)YkeeOWOb8S(zsfmYG4jTEHKoe5MqycKOXwg)fRWgHfsAtE9y5ZelZuQPbwP5YljE(U4GrkWyf(nWWbvJWcuxeM3oYIeqbzaeazzcdw3asU0(g8xOEaeZ59TFmfyfVVaNYOlsZCjd(3v8F96qWM6wqIIb8v7wvixxsRHLMATQ9I84SNKgTeFtTUwvDxIfid4f4QsYtTnrE7npHRme8h0ZrKrFtC0T3Sb8GaNmU9g6bxr6YvfL1CX)3QuzfVf5n(xRtPEkwvG(gLSUUG7S0Shqpfq)EyB8n8ih57bbvsj91V1UFaVLjq54TIy1Gw1p6JdKW(s7WwTc5maS6RCb1XhfO(12HAR6rYa0TEVl4)nhfSoYbX4Gm9f9UJgnz7pBHhMRo4GW)2SBqnqUMx4CypYoin2mwgW1Xw1QfWDitOSlImaSYB2vG2SpKmGzZl2vqQ4pQbmv9unS5B5g(E3MXBHzTwHwuLRe74VTU1R9RQscuVNLlw6LUAF4DR1DyR9E0vtdVZCDeZyV)80A)6Q1wPiNZvTEDGaTlAVzV0v7dVBdBUYBtdVZcEUQRwR1Lo02BXlEdjFB(57qTIJ(ODo(n6c3lcqN9q7vKs4YUfwBBT5Oc(JgG)dcVlaPjAlQyE(hapINdSfztCUeP99HL2pnJS1YRgniCM6JicRGVDHUYzG3)jqU1rFCaLBB1dVsg0Jm4pAa(pi8(tLCBRZBPp3LBddH3h5whrCEqLBD0hhq52w9WRKb9id(JgG)p49)wG3T0t67OOBhu8eY5iODvLYhTxNnD21s1uowD0N(wAL940PRdv8)rtR3ls9RIshe9lCcDx0zjxVJSvEqTn5OpoG2MA1d8HVLZVVwkfS3MJk4pAa()G3)BbE)j02uBVIpcNBQ2GPMgZpPNCQ2XMpb2McJwVxK6xfLoi6x4e6UOZsU(2RpZRuEYCPpo0WpeiBTO3TaDxTl0rqO9dYYnzpGV5rhRfqBPjhyO7AHdcbY8t0wF4DttoWqFNX79n6MJn8dbYHXj6UDHoccTF2po(2hwYwa9EZXhm03doNo5jT2Kdm0dfVB7AJZq4Cz)mOt2BRg6CPw04CZ2qi24qZU9BTGoTonVTguOlMwt8jYl(06TwOOm8r6IZNoA(5FMrZp)tonFOJIMyVkYlhl76RSkHSIFIr0UHGXDiUFGk0EXiCVb356GtI)xCuiWEHDRIg0a6TEVl4FyR0hgmDuwATQFCdi369bY0jKxFvmDgwVAoOf8y7s2aTrVla3EFq3c0wBYre4U5YKGTdIHLg4N9vsL7eFT2KJiWLG11QjSF04axQI9d4Ub7riLThwu)Oc8aalY3QO5WgBTYRpI46rf4Dc2WdrkOqXE9DJ3iXCLm19tI)OcC3G9iiAEyr9JkWdaSEfnB96JiUEubENGn881fKO5RVB8NKKihEs66aKWGB3z7c0lqX2V(T7KxGoqA2(l3ad5B6ChIGo2kcQBVEd4PDWiSBqDpDpF7p)tuAgcQ3lo8uWdIe6Ei7NV9g6FH3TXk7Oi4N)c92sMdUB)t3EtXQBVPIulUQCV9gr0u4FLTM08aXMSI(KjSRszLDM1T13(lXgaxaZMDym7QsUmDf7fO8JNBmIBVbAAnb6)BVr9mRCAVTtFZ2P(J)s0Q(n7Vn5(edFfnWq1tb5TthGdIlCmiupCebet9KaajRkOAFLtjRooup3o9dqKBBN(YlBNQCSPO(yh3DbQnPVy0ipgcWbO2jaX2PxFf9o68m82E151naqdO)ByKoXHaj9Hgibo6zyNbE8HGrddMLpNUlpqgLlnyuAya4mM225xcs1(pzFiNP)mzAwiIjp2prY7yhYHnnsN94WCfzOnnAFoQVuZJZjyh3xa07zHl3DY(aUQP35KJZ2HgndBTEiKIJMOHbJj8JZybldBMq5EOG(uLd66TtVIEOkWGofkMNMdIxk7x5PyqZmn9SPgh3V)Z5XDxJq6lLhZ2bmSBo)WXX(x7qmaXc)MHmTyYzADUTo3tQIJrJMSP9BAeC49n7Ou(H7Yazxuy7tEoou6MI8moYJg5yOBzBKVltZbGjkx7h7YS4(DfMqhRMUDAWf)AgmHXo2IcIyLl)v1D1tJgWVzsuX5aWrZPEtFm3BGz30zKBxt6sBvZIP0Cfte4eH4e9whVWhsXjt75A40rWvEBrFG4HPr0WvOgKcu3u3U5IrNPm53SDPSqhhMgf9P(qoectTadpSkY0H5izh96jdw7EtZfboYuU7rCZNBHPn2LoAZHRhVnE3REuhBQ9CNh1oegOgxPhwd2snGXKPMd)9A7AJf)2m1V2wn0SMRtxbq5szTpGhA6aXxjdxxoXjVMWv7xrSAYwrV2WnAHRWnmVyqzPwHN)dzYs86CEF5b4h)(BG63aEc)HoQQEmQsDC26Z5X01J7yR(LPTYSU2X7OWMigZgEq7I)T(jw00pCfE6JidSPjVfAhBumhDgzdaxtr4bEGGWr52FyumpKwkYPhlOYrTJTqa8R3r7k6PjQ5gwvBIzMQ2SiL1C2n1ddSv9k2MkT)(rs6Tru6sCq)iesBiRDTHBZ549cJuOvSJAkVoFQFFwBQIZZTDTiIF2W)nm(uVxp4nXP59kcNc4yf374HH566cxGcg5J4k65og2Jn6yCCyVOi2ie20qz)z0WHLlxEa7MGBvbz4ZcDng75pSMinLn8XFG(rBmgCE1K3LFDins)AkNopgRj1OFeT2H71TgpSBYCQJEbPXxOEZQB2sbT0voto1NOleD1bTvjHEQ8XAiMCorUAjTo5IuzWAFiePA2XMrjDHqlRZHfbqvLbJBS3z5WLLX9YueB1gk3qvFFGqkfzZ68ahQZ1nQkgew167c36jomez4G0yQ1UzqhXv1g3dKjxScCwJxYbFLQ6djhMogiN6uL3vpvEzuUrsoK2kfWxiFQYQpPPrW7ytSwy2cHkGH21xjY4ZNHJn116ZwWAg6LTFjYthf29Vq)YKNkOXVq5vDYG9bSWlKNnyYameTBzs5JclNO6hd3X7o0bpXD4n9kMMvThwHPQ9UxNuJ6AquDWc9PkV27XvL92B9WMYEtDDorzyrIF4YspGwzFpMiv0ycaGAMcgL7El(fvGSsNzMAy3nqpswvZs3hEFdXoeLRXS4uHRinMkWLPLLYlYiW(0JkN1RALsT6IlZrlr1PBliTDywj2)SshhIy2BFyZkEp9USnGJBgWMkF5d40f32oVuEQYijoXAP79TOUWVXmGq)MTAHrumjBN(LyCDJelbeQuJ(ZVSRVJ1EZf9vS8S0Ji5vzjpt5CIrwQ814vXbFuZVnnyxSuAnqC9tXwUVlA)c26aVrCRFWxI3VLgofwvkm2zcYlZzXAXGIf7VtMWjKSk4VhnCSKRmYwiTkZT2GuBUewV(jKpi(tkFGxINPPnRcgAUXEyildomsiMzjXC4ZsaKR2einKwujbJj(2vVwrl)FqG4Oh5983w3LiFn9EubBpEVkH3gGZ0eXP3XGgxftvjOPniSPSdOSSzMAE1YYF6yDDjuBz7CDGzDT2dwyD7etoISUEWXUur1khBU0r5vBI75lT4fCmB25e65Ana)2jnVe4y(kkmIgoMMscNEtP0Y4aBPfuNj)YQaTRBH)w1ICUwdcg)n9r3n(7SLwM1AWFdTA8RiV0FNiHC1w(HTpE5XDgg2ftpfOY6SRXa81VvDHhIxxUOlmZM3aKZUU6bSmql1UZe4V0MMgXL1xxA4IK8YXSi58udPnmZ2RbiXn3dnhhJfASyzQ32ke2xP6D2X66Hn7eWsfBu1aUssJepvxrHDALU()TKK2XFRx4sUQJw2k2OjEiVP)WYVeV3(Yyje9rAr9Glwx5Mu0vD5T9ogSP4wtcVwS43KA06obVqPBUAPxvuvLsjvnxf407PDurcTBVvFP66l7ggfggYwVFVztE2P9AZkAjvCOr(dToB7Q)C1DYLgj8PyB54qnZH7w5lhwVBTWv0Q1glH43GukZknFE7QDW7sXUZvrUYcsQvgjUtDil)sQx)sDVqhskK3sOXmMhDtm0Cmk0R0UQMLIo0REmwj3tBWhRP2hb(Z)XFM8yAw6)uEbeDdEHgHt3aQqlZlAbwtqVN3SD6cC3zaKo8k9HDRNHfpcTAPjqZxs32diImDtsA9uCONHxgAGflQaiEnjMmhtHemMv0PwOCL)DRT1808YptrJQ2kS)EzjOALO)M2RsBVUs5oUU94v4sAn6WxS)fPnKj8qejA5i5U1f(llR9T2sOi(CTAlrVg0CvCDw0)pldVHmzAVPRSf2znQRXLYwQTgFyvZAFfmclRXM9rJEhRQO3o2OQQ8Q4YtH75Tp4f(MEpywQpsh92RTbKqZYjuoUlhr9QOTUo(Qqpq0WlOTt94wq5LJhjCM2VuNIHttpR)C5M2u1xBZZHcBoi2nbN5kcfPotTE1mao9TqdJVOzgr)4Uqer15TMhmOLhQ7ItT4ouwcmBEfgeDOtR0Q(i3(wUKsICCtxsjAJgEbB55If0k(AeZ7vNNbhQ9RTBctzpB92W0FF33RJ9VZRpKdSe0GocXuh6drmyooa3RPQ8fM2W3Z1CZtjeivpAE1BYxFEZX3R9UcvD0X1rVFlzLtLQxX0iWYpbBK78KwP9eyx30OQ4FtHZ7EnO8lY6nvBsMXtcoNCSmczucH9cTF(GXNABTqR2Upx8PQunLB4upRVtG0nZcW8eFzv9erDP8hhn6pORgvt6pEhO6z9HcK4BCtFQt9nVYqPVnke6VnWIFyhK(J1vQQjTJbbxlNb9260d9R1LmQXO4ODXOQomuQ(e75F3ZOq6(MYociWrW(DHPAn(RUzunJeqf3n2q(TccZl0faX2TGQAOiUUStnSN64Ayv3oNEcgzbQiKx8NRzlLt(7BkN8MrOIZW2CexgTelb5GBbyvWO(7MU0YIcWk(wH7w2wRfvmm2s9F1ALBmnCJBRoJYWPzneUhRBh4zcd78Ef3lKfQPbTjs608ASixWPeMMbLQ85mvO7ljU8MeBL6yEuI1I60(muPtQtKc1rBck2MNJYmPWmkzqqLMQyJFgliRWBBLipljaVFaBLb)zYupTtTqxSWKT43vtcYSjUvmhMVxstHsg1caE3kt9rLUi4z0SXHJGK7tqvt5yk8yAVqFCFK(7wgOqF(P5jS658ASm)Cniuh99AVltW4MLr2Oo)kSzt)kTNkD6Ax8GjAeN4B68LPe12MQE7EWx4Zy8(vcN9BuWxUodFm(fBEGGgEzXbqlLn4NptH093Z2gSef4w9qcn3dF)pa2a(XcX7XAKRs8P4K2gQKywMiBTvRiZsxGrn9D)T)cgRnar6jCXpYDdsu3DSYAsrQxjlQO0hmtTSYMZq7Iop3sImrbBSb9BEJ1cFUJmSgpwjc2GN6FNSVDRAnywPZ6wx(izW6nPNORc1WP39b3Fduin6fzO6HPL7cOqcrRvpGy1HfLW9GwfresivwHDmHPTD4LzawtKZQfgCTcyvSxLICdVSqXdcOs25aenWwB(L6ZCKxUG)pcJB0RIX1Hz2JgJR3(ZfJBKpgxBqSBg342mUTkTfFmUT9VWZkWySnaUsUnZSU2sMTnUHhgKcsYMSac753F2AKbIgAzUYmGXSnjpRz0xAm1Oy4WGjFUynAvkxZ4UBd5HTzrVCSDQGoBxNhvCkmnEChRnD19zLu72EHsNW2Xhd1o5Fy7W1Z2gsn2P4ciZrKALDtJLWzK(0PCcYzUchjSZiTZLvjXQnOIt9St(UHJpbNXjl4XjSAZPQUwaZl1KeCvxtXcJu)JltwUkbJnGTx6qXi2yLmhC74VlQmAEZ0GldCqiepLsJXLraf8zVJ5R0cYgQ7r8TtZ2P)Kw3)R0JJpoyP2heUaLKHj3G9EwYHEVviQY6QV1DujSk7RXM8RRD29PPwEOED5yWeB5BvkTGbQo7k3hDuY3ebr2CreccXFdRNP5DUIqEKuobP8vn7qvfuMFohkq5o6G3PMyz9JirPgCFrqt31J7YjvJg1X2zOOf0wXZevZ4VIDyOv9kIzyZTEOFxaKWu9tm0GIqw91SQNXC6YmhaL4cKJcTvWCmnVtC5muyy1gmqnu(D9kq46xX2Y1Z3mY5joSrSgLbvd9vkrZnzChzrbMKaAxJhdjv0myjR6658AUInPAlzbW3pbRVeTDxRE5D4j2DJ91RxoRwYOOAZpkw(v2Uu21b8qR(Xzy6w27Zuf8jRbfKL3EZFn5XKhsFmL(0B)F)]] )
