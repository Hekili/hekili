-- DruidRestoration.lua
-- December 2022

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
    astral_influence           = { 82210, 197524, 2 }, -- Increases the range of all of your abilities by 3 yards.
    cyclone                    = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 6 sec. Only one target can be affected by your Cyclone at a time.
    feline_swiftness           = { 82239, 131768, 2 }, -- Increases your movement speed by 15%.
    forestwalk                 = { 92229, 400129, 2 }, -- Casting Regrowth increases your movement speed and healing received by 5% for 3 sec.
    gale_winds                 = { 92228, 400142, 1 }, -- Increases Typhoon's radius by 20% and its range by 5 yds.
    heart_of_the_wild          = { 82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Magical damage increased by 30%. Feral: Physical damage increased by 30%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges.
    hibernate                  = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin          = { 82219, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_rejuvenation      = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec.
    improved_stampeding_roar   = { 82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    improved_sunfire           = { 93714, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within 8 yards.
    improved_swipe             = { 82226, 400158, 1 }, -- Increases Swipe damage by 100%.
    incapacitating_roar        = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 15 yards for 3 sec. Damage will cancel the effect.
    incessant_tempest          = { 92228, 400140, 1 }, -- Reduces the cooldown of Typhoon by 5 sec.
    innervate                  = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 10 sec.
    ironfur                    = { 82227, 192081, 1 }, -- Increases armor by 2,509 for 7 sec.
    killer_instinct            = { 82225, 108299, 2 }, -- Physical damage and Armor increased by 2%.
    lycaras_teachings          = { 82233, 378988, 3 }, -- You gain 2% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                       = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 839 damage, 1 sec 2 points: 1,678 damage, 2 sec 3 points: 2,517 damage, 3 sec 4 points: 3,357 damage, 4 sec 5 points: 4,196 damage, 5 sec
    mass_entanglement          = { 82242, 102359, 1 }, -- Roots the target and all enemies within 15 yards in place for 30 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                 = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 21,605 damage for 8 sec.
    mighty_bash                = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    natural_recovery           = { 82206, 377796, 2 }, -- Healing done and healing taken increased by 3%.
    natures_vigil              = { 82244, 124974, 1 }, -- For 15 sec, all single-target healing also damages a nearby enemy target for 20% of the healing done.
    nurturing_instinct         = { 82214, 33873 , 2 }, -- Magical damage and healing increased by 2%.
    primal_fury                = { 82238, 159286, 1 }, -- When you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect.
    protector_of_the_pack      = { 82245, 378986, 1 }, -- Store 5% of your effective healing, up to 17,616. Your next Moonfire consumes all stored healing to increase its damage dealt.
    renewal                    = { 82232, 108238, 1 }, -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    rising_light_falling_night = { 82207, 417712, 1 }, -- Increases your damage and healing by 3% during the day. Increases your Versatility by 2% during the night.
    skull_bash                 = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    soothe                     = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar            = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 20 yards by 60% for 8 sec.
    sunfire                    = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for 1,566 Nature damage and then an additional 14,345 Nature damage over 18 sec.
    thick_hide                 = { 82228, 16931 , 2 }, -- Reduces all damage taken by 6%.
    tiger_dash                 = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    tireless_pursuit           = { 82197, 377801, 1 }, -- For 3 sec after leaving Cat Form or Travel Form, you retain up to 40% movement speed.
    typhoon                    = { 82209, 132469, 1 }, -- Blasts targets within 20 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by 50% for 6 sec. Usable in all shapeshift forms.
    ursine_vigor               = { 82235, 377842, 2 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 10%.
    ursols_vortex              = { 82242, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart              = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    wellhoned_instincts        = { 82246, 377847, 2 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 120 sec.
    wild_charge                = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                = { 82241, 48438 , 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 8,386 over 7 sec. Healing starts high and declines over the duration.

    -- Restoration
    abundance                  = { 82052, 207383, 1 }, -- For each Rejuvenation you have active, Regrowth's cost is reduced by 5% and critical effect chance is increased by 5%.
    adaptive_swarm             = { 82067, 391888, 1 }, -- Command a swarm that heals 14,040 or deals 12,362 Shadow damage over 12 sec to a target, and increases the effectiveness of your periodic effects on them by 20%. Upon expiration, finds a new target, preferring to alternate between friend and foe up to 3 times.
    budding_leaves             = { 82072, 392167, 2 }, -- Lifebloom's healing is increased by 5.0% each time it heals, up to 75%. Also increases Lifebloom's final bloom amount by 10%.
    cenarion_ward              = { 82052, 102351, 1 }, -- Protects a friendly target for 30 sec. Any damage taken will consume the ward and heal the target for 28,169 over 8 sec.
    cenarius_guidance          = { 82063, 393371, 1 }, --  Incarnation: Tree of Life During Incarnation: Tree of Life, you gain Clearcasting every 5 sec. The cooldown of Incarnation: Tree of Life is reduced by 2.0 sec when Lifebloom blooms and 1.0 sec when Regrowth's initial heal critically strikes.  Convoke the Spirits Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    circle_of_life_and_death   = { 82074, 391969, 1 }, -- Your damage over time effects deal their damage in 25% less time, and your healing over time effects in 15% less time.
    convoke_the_spirits        = { 82064, 391528, 1 }, -- Call upon the Night Fae for an eruption of energy, channeling a rapid flurry of 9 Druid spells and abilities over 3 sec. You will cast Wild Growth, Swiftmend, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    cultivation                = { 82056, 200390, 1 }, -- When Rejuvenation heals a target below 60% health, it applies Cultivation to the target, healing them for 1,668 over 6 sec.
    deep_focus                 = { 82074, 403949, 1 }, -- When Moonfire, Rake, Rip, or Rejuvenation are active on a single target, their effects are increased 40%.
    dreamstate                 = { 82053, 392162, 1 }, -- While channeling Tranquility, your other Druid spell cooldowns are reduced by up to 20 seconds.
    efflorescence              = { 82057, 145205, 1 }, -- Grows a healing blossom at the target location, restoring 1,776 health to three injured allies within 10 yards every 1.7 sec for 30 sec. Limit 1.
    embrace_of_the_dream       = { 82070, 392124, 2 }, -- Wild Growth has a 50% chance to momentarily shift your mind into the Emerald Dream, instantly healing all allies affected by your Rejuvenation or Regrowth for 6,430.
    flash_of_clarity           = { 82083, 392220, 1 }, -- Clearcast Regrowths heal for an additional 30%.
    flourish                   = { 82079, 197721, 1 }, -- Extends the duration of all of your heal over time effects on friendly targets within 60 yards by 8 sec, and increases the rate of your heal over time effects by 100% for 8 sec.
    forests_flow               = { 92609, 400531, 1 }, -- Nourish extends the duration of your Lifebloom, Rejuvenation, Regrowth, and Wild Growth effects on the target by 4 sec.
    frenzied_regeneration      = { 82220, 22842 , 1 }, -- Heals you for 30% health over 3 sec, and increases healing received by 20%.
    germination                = { 82071, 155675, 1 }, -- You can apply Rejuvenation twice to the same target. Rejuvenation's duration is increased by 2 sec.
    grove_tending              = { 82047, 383192, 1 }, -- Swiftmend heals the target for 9,360 over 9 sec.
    harmonious_blooming        = { 82065, 392256, 2 }, -- Lifebloom counts for 2 stacks of Mastery: Harmony.
    improved_ironbark          = { 82081, 382552, 1 }, -- Ironbark's cooldown is reduced by 20 sec.
    improved_natures_cure      = { 82203, 392378, 1 }, -- Nature's Cure additionally removes all Curse and Poison effects.
    improved_regrowth          = { 82055, 231032, 1 }, -- Regrowth's initial heal has a 40% increased chance for a critical effect if the target is already affected by Regrowth.
    improved_wild_growth       = { 82045, 328025, 1 }, -- Wild Growth heals 1 additional target.
    incarnation                = { 82064, 33891 , 1 }, -- Shapeshift into the Tree of Life, increasing healing done by 15%, increasing armor by 120%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, and Entangling Roots is enhanced. Lasts 30 sec. You may shapeshift in and out of this form for its duration.
    incarnation_tree_of_life   = { 82064, 33891 , 1 }, -- Shapeshift into the Tree of Life, increasing healing done by 15%, increasing armor by 120%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, and Entangling Roots is enhanced. Lasts 30 sec. You may shapeshift in and out of this form for its duration.
    inner_peace                = { 82053, 197073, 1 }, -- Reduces the cooldown of Tranquility by 60 sec. While channeling Tranquility, you take 20% reduced damage and are immune to knockbacks.
    invigorate                 = { 82078, 392160, 1 }, -- Refreshes the duration of your active Lifebloom and Rejuvenation effects on the target and causes them to complete 200% faster.
    ironbark                   = { 82082, 102342, 1 }, -- The target's skin becomes as tough as Ironwood, reducing damage taken by 20% for 12 sec.
    lifebloom                  = { 82049, 33763 , 1 }, -- Heals the target for 18,051 over 15 sec. When Lifebloom expires or is dispelled, the target is instantly healed for 10,129. May be active on one target at a time.
    luxuriant_soil             = { 82068, 392315, 2 }, -- Rejuvenation healing has a 1.0% chance to create a new Rejuvenation on a nearby target.
    moonkin_form               = { 91042, 197625, 1 }, -- Shapeshift into Moonkin Form, increasing the damage of your spells by 10% and your armor by 125%, and granting protection from Polymorph effects. The act of shapeshifting frees you from movement impairing effects.
    natures_splendor           = { 82051, 392288, 1 }, -- The healing bonus to Regrowth from Nature's Swiftness is increased by 35%.
    natures_swiftness          = { 82050, 132158, 1 }, -- Your next Regrowth, Rebirth, or Entangling Roots is instant, free, castable in all forms, and heals for an additional 100%.
    nourish                    = { 82043, 50464 , 1 }, -- Heals a friendly target for 16,996. Receives 300% bonus from Mastery: Harmony.
    nurturing_dormancy         = { 82076, 392099, 1 }, -- When your Rejuvenation heals a full health target, its duration is increased by 2 sec, up to a maximum total increase of 6 sec per cast.
    omen_of_clarity            = { 82084, 113043, 1 }, -- Your healing over time from Lifebloom has a 4% chance to cause a Clearcasting state, making your next Regrowth cost no mana.
    overgrowth                 = { 82061, 203651, 1 }, -- Apply Lifebloom, Rejuvenation, Wild Growth, and Regrowth's heal over time effect to an ally.
    passing_seasons            = { 82051, 382550, 1 }, -- Nature's Swiftness's cooldown is reduced by 12 sec.
    photosynthesis             = { 82073, 274902, 1 }, -- While your Lifebloom is on yourself, your periodic heals heal 20% faster. While your Lifebloom is on an ally, your periodic heals on them have a 4% chance to cause it to bloom.
    power_of_the_archdruid     = { 82077, 392302, 1 }, -- Wild Growth has a 40% chance to cause your next Rejuvenation or Regrowth to apply to 2 additional allies within 20 yards of the target.
    rake                       = { 82199, 1822  , 1 }, -- Rake the target for 1,929 Bleed damage and an additional 16,295 Bleed damage over 15 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    rampant_growth             = { 82058, 404521, 1 }, -- Regrowth's healing over time is increased by 50%, and it also applies to the target of your Lifebloom.
    reforestation              = { 82069, 392356, 1 }, -- Every 3 casts of Swiftmend grants you Incarnation: Tree of Life for 9 sec.
    regenerative_heartwood     = { 82075, 392116, 1 }, -- Allies protected by your Ironbark also receive 75% of the healing from each of your active Rejuvenations and Ironbark's duration is increased by 4 sec.
    regenesis                  = { 82062, 383191, 2 }, -- Rejuvenation healing is increased by up to 10%, and Tranquility healing is increased by up to 20%, healing for more on low-health targets.
    rejuvenation               = { 82217, 774   , 1 }, -- Heals the target for 11,836 over 15 sec.
    rip                        = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 10,525 over 8 sec 2 points: 15,788 over 12 sec 3 points: 21,050 over 16 sec 4 points: 26,313 over 20 sec 5 points: 31,576 over 24 sec
    soul_of_the_forest         = { 82059, 158478, 1 }, -- Swiftmend increases the healing of your next Regrowth or Rejuvenation by 150%, or your next Wild Growth by 50%.
    spring_blossoms            = { 82061, 207385, 1 }, -- Each target healed by Efflorescence is healed for an additional 1,646 over 6 sec.
    starfire                   = { 91040, 197628, 1 }, -- Call down a burst of energy, causing 10,543 Arcane damage to the target, and 3,597 Arcane damage to all other enemies within 5 yards. Deals reduced damage beyond 8 targets.
    starsurge                  = { 82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing 19,520 Astral damage.
    stonebark                  = { 82081, 197061, 1 }, -- Ironbark increases healing from your heal over time effects by 20%.
    swiftmend                  = { 82216, 18562 , 1 }, -- Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for 26,295. Swiftmend heals the target for 9,360 over 9 sec.
    thrash                     = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tranquil_mind              = { 92674, 403521, 1 }, -- Increases Omen of Clarity's chance to activate Clearcasting to 5% and Clearcasting can stack 1 additional time.
    tranquility                = { 82054, 740   , 1 }, -- Heals all allies within 45 yards for 22,484 over 6.8 sec. Each heal heals the target for another 524 over 8 sec, stacking. Healing increased by 100% when not in a raid.
    unbridled_swarm            = { 82066, 391951, 1 }, -- Adaptive Swarm has a 60% chance to split into two Swarms each time it jumps.
    undergrowth                = { 82077, 392301, 1 }, -- You may Lifebloom two targets at once, but Lifebloom's healing is reduced by 10%.
    unstoppable_growth         = { 82080, 382559, 2 }, -- Wild Growth's healing falls off 40% less over time.
    verdancy                   = { 82060, 392325, 1 }, -- When Lifebloom blooms, up to 3 targets within your Efflorescence are healed for 7,408.
    verdant_infusion           = { 82079, 392410, 1 }, -- Swiftmend no longer consumes a heal over time effect, and extends the duration of your heal over time effects on the target by 12 sec.
    waking_dream               = { 82046, 392221, 1 }, -- Ysera's Gift now heals every 4 sec and its healing is increased by 8% for each of your active Rejuvenations.
    wild_synthesis             = { 92609, 400533, 1 }, -- Regrowth decreases the cast time of your next Nourish by 33% and causes it to receive an additional 33% bonus from Mastery: Harmony. Stacks up to 3 times.
    yseras_gift                = { 82048, 145108, 1 }, -- Heals you for 3% of your maximum health every 5 sec. If you are at full health, an injured party or raid member will be healed instead.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    deep_roots          = 700 , -- (233755) Increases the amount of damage required to cancel your Entangling Roots by 250%.
    disentanglement     = 59  , -- (233673) Efflorescence removes all snare effects from friendly targets when it heals and its Mana cost is reduced by 25%.
    early_spring        = 1215, -- (203624) Wild Growth is now instant cast, and when you heal 6 allies with Wild Growth you gain Full Bloom. This effect has a 30 sec cooldown. Full Bloom Your next Wild Growth applies Lifebloom to all targets at 100% effectiveness. Lasts for 30 sec.
    entangling_bark     = 692 , -- (247543) Ironbark now also grants the target Nature's Grasp, rooting the first 3 melee attackers for 6 sec.
    focused_growth      = 835 , -- (203553) Reduces the mana cost of your Lifebloom by 8%, and your Lifebloom also applies Focused Growth to the target, increasing Lifebloom's healing by 8%. Stacks up to 3 times.
    high_winds          = 838 , -- (200931) Cyclone leaves the target reeling, reducing their damage and healing by 30% for 6 sec.
    keeper_of_the_grove = 5387, -- (353114) Tranquility protects you from all harm while it is channeled, and its healing is increased by 20%.
    malornes_swiftness  = 5514, -- (236147) Your Travel Form movement speed while within a Battleground or Arena is increased by 20% and you always move at 100% movement speed while in Travel Form.
    master_shapeshifter = 3048, -- (289237) Your abilities are amplified based on your current shapeshift form, granting an additional effect. Bear Form Ironfur grants 30% additional armor and generates 2,500 Mana.  Moonkin Form Wrath, Starfire, and Starsurge deal 30% additional damage and generate 3,500 Mana.  Cat Form Rip, Ferocious Bite, and Maim deal 60% additional damage and generate 10,000 Mana when cast with 5 combo points.
    reactive_resin      = 691 , -- (409785) Enemies have their movement speed reduced by 30% for 8 sec when removing your Restoration heal over time effects, stacking. Enemies are silenced and rooted for 3 sec at 3 stacks.
    thorns              = 697 , -- (305497) Sprout thorns for 12 sec on the friendly target. When victim to melee attacks, thorns deals 8,456 Nature damage back to the attacker. Attackers also have their movement speed reduced by 50% for 4 sec.
} )


-- Auras
spec:RegisterAuras( {
    cenarion_ward = {
        id = 102351,
        duration = 30,
        max_stack = 1
    },
    cenarion_ward_hot = {
        id = 102352,
        duration = 8,
        max_stack = 1
    },
    flourish = {
        id = 197721,
        duration = 8,
        max_stack = 1
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
        max_stack = 1,
        dot = "buff",
        copy = 290754
    },
    lifebloom_2 = {
        id = 188550,
        duration = 15,
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
    regrowth = {
        id = 8936,
        duration = 12,
        max_stack = 1
    },
    rejuvenation = {
        id = 774,
        duration = 12,
        max_stack = 1
    },
    rejuvenation_germination = {
        id = 155777,
        duration = 12,
        max_stack = 1
    },
    renewing_bloom = {
        id = 364686,
        duration = 8,
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
        max_stack = 1
    },
    wild_growth = {
        id = 48438,
        duration = 7,
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

    if legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent.restoration_affinity.enabled then
        applyBuff( "heart_of_the_wild" )
        applyDebuff( "player", "oath_of_the_elder_druid_icd" )
    end
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
        cooldown = 90,
        gcd = "spell",

        talent = "flourish",
        startsCombat = false,
        texture = 538743,

        toggle = "cooldowns",

        handler = function ()
            if buff.adaptive_swarm_heal.up then buff.adaptive_swarm_heal.expires = buff.adaptive_swarm_heal.expires + 8 end
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

    -- Shapeshift into the Tree of Life, increasing healing done by 15%, increasing armor by 120%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, and Entangling Roots is enhanced. Lasts 30 sec. You may shapeshift in and out of this form for its duration.
    incarnation_tree_of_life = {
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

        spend = function() return ( buff.incarnation.up and 0.7 or 1 ) * 0.05 end,
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
        charges = 1,
        cooldown = 15,
        recharge = 15,
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
            if buff.regrowth.up then removeBuff( "regrowth" )
            elseif buff.wild_growth.up then removeBuff( "wild_growth" )
            elseif buff.renewing_bloom.up then removeBuff( "renewing_bloom" )
            else removeBuff( "rejuvenation" ) end
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


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageDots = true,
    damageExpiration = 6,

    enhancedRecheck = true,

    package = "Restoration Druid",
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )


spec:RegisterPack( "Restoration Druid", 20230724, [[Hekili:TR16poQrs8)wSIeR98WhGTNz2iJ)q27IUS6YQtX5Zg3dU9y0ydo8yMDKS4V9R6gAOFc4D9gLCA)Y8a6UQQRN)QIELZQFF1YnOm8Qp5A7oX(E3PJDCNmDYSvlZE7iE1YJOGNrpb)re6a8ZFdNMfNGYcJJkw)ptYd3qwYB7JrBiKknopjaw2QLpMhUp7xIw9Ow6BFpS2J4GvFYXgy1UWnBWLRfNgSA5)gJ2JtkwFmjmojmleNwSgLGbo(FxE724G8u8MI1Xr7FBCXhl(iH03AF)TUt)XI1fR)zCsCqyCoSPFkmdtwyX6muYt4m4rVgMTRy9VfEe(ZD463uSo4TG9HrpvSoewfoc94E8goYp5w3juY)RHrXGSL9kg9mSYS4I1Fab7)NJtoulYVvSEBsm8)ldpKVNQV(qcAB24vl3hMMLsuwbOm4xFIAdQ43QFcEmSDCsiIOd3UDC6o0M4xpG3VzCoiZNovSM(8JjXVUx8rP5e1Op6WJ5P7GxTAjkGW5vltqpJxLbgbJ8AiOaIJ3dSkACqC0lXpJ9Z2H9tpgcRjDCc(akmcoVZlwpXUKPdikV94OmT7OInfRhvS2IUyQqUdJsY8J3sx7RH0JvJGQ8wIuprsQzlgTbDml8fGLVIsoWFA2eNnw8T(Bqha)4XPzGdDXAVI1UuXY8kRpXlG1cehCpGdyPBeXQbc20VjcMZxVGn7BIGn5RxWU7BIGn9RxWU)SfSbTXXSWGNHKj651dgJcjCfifocFGM0BbZnTko7qCCeqx)TqUMMamR(fhA17qCqL(uWMXhqFMURHTe6wMjOMUQlHx3FhK442Y8hx1iZGaMeMN6)eunbffGBKyXKmQ0UjfdxQUCidi9V9jzAlZ36xw9cYys0)VVTSGYMG5utGOKO3mmIPSyP6Ge8LlHOM(UrAKGDIPCigeh72Si)v)yXDMuny0JN5s8gnNbXhEm2)yCyuwPt4mMvUsI2GXh9PyHeCEQCFjzMif9ljCtffYZa1Y2emGRa2KyOtfkbhZWe6P869fjVemzsIB4rZsB4rQWkJoGxy52PfdPhKB(ayII93eIPEgLskahD)EwI6Xz7sqP78dia7GLmTHTnVHYDtqasZJ2gMGLCL7VevdA6yc(fFIM2PoFctZkNQQu1rCCR05HhauIVG34xjncoT6Qm5idCqOCN2KAa3tE6TsX2MjzdlnFn6QXYNCr1D6RHhXvAB4u8E(0LLerinc5i2PNLw)Nw94uQ(6XmfMYBzcodParFm)s2DhxMvVc)q9rLZlOYwsxjpQ8n5S(YG8B2JFqNAMT1YJ8O2DZm4IiJuQ5eYrdMcOtPunIHWJ(JqQXNxFT7hyhqvNxoJkaLmjnhoMuUBgFGGbdOUJToTm8hLN9fmpRH81sAIkjE9IvC6kSqsMzkmxZfq7vCRE3Bx56wSfTL1HT)JaBuAJKVsWcwBd6s1nN(YMaAdfrQfvV6Cmnb3nv4jgJrTNCzonvUo3Ax5AEAY3)nP0IH(rCn10lTiDV6pQohILqMhd8ZuHmszwrdSCImIXJZB692sb9E8MgZwzzDxnbUgustR9r4FSiLUI2i4CjkzjULPg34cPnoQ2ZKpFSLghCxknn60DfDfgQ46AUIRIEI)b84(zbdcfnAY3qELo0QYrXaf9lTJmzZu5nzFW(uAtBMsHiZwCskX)sow81sCmRvn1oVgyzNvOSMkm3xxZUDqxgKu5sDxM8ogyM5kBAM8GJgV96grATwgN(MzHPZXZCvkU8h3zBGVCuDxcMmzWSYw6BDiQS6Fc9SZpYr(xupJ026OJJpurydElkFV2z5sgNne(vsR)1NXb5zKGq8l4K3kJrGFUdt9RidvMm6z0lOW9ekmM7a)Coe28i4qOiHPX7rj(pIrhefSYPMYw1J4KuCs5iPewLCAFvfxZGM5asjmv6g2KNI9H9FG22B39sCoK(ym93AMHih8SQeEKMCfGvjJaQFJlQYT1mGxnbnFFCDN3it6X46m3mqxQzrZo5eBoSV1Hc(3h9PPrqjN6LT(VUbVFb(gkkdh7YizxGpIIYyWUms2f4ROOmZRlJKDb(mkgNh23IVJIY0QUuO8(IqYDwddQt4YM0V9Vyez4hCQeHjCyc05xUI7EJWJnCqmNVTTPPiEGeh)b7nVMGY2PGs7ycMaPK7BUZwV63CweIK5PHRbVbhGLKQ6xMhqDjaqiYZUPCLqXmsrfEps9CIFMnMXZPJzc1g7c5IXANu9laPnL8YYl6XeOV2LqGCee8ciM)DcgxiCkobA1BlbP77aw)os7C)royeHAyPXeXdLNfFarbjhSdf9eoDCXh)pHrWRCN9JfR)auEdNqF)7AAVfie5Ay8o1gEH3m05ZJO3JJFHYFYwNw6PsMcj92yaVMAV2gsgps5Rshx7XCT3)qXhP4J6wg1MFt4wpDir1UdMfGUjWc5zBP3nWQ3KKFRYKvWGB1g(jqH9dfRp7EwQfjqqA6Ar4P1nSW)0Mgua((dm7d5nrOSCidK)lHpfs1Tde6DWAGMRjJejsWpbRoBx)2TvkolJ43sGCT3humWUZpMEZEWp0pyJ398cEDlp9J48BTSLMZFFsyMVHGw2dSSgC8oDszaWDrSkVyX05lCBZHXQ7EAS6t)mZ9Q6LXAOru3No1nI7f3zF7e7R6cL9Ptd6cF9iE1LsWvlAenPy5OKgDaHG)L8ulco7gHc6EoeXUd8LEUwDIRCH7LLLo)5ZYj)5ZYPxEwoOt84c5ZlXmQJqCyhTuXnUyMvxFNAPaVEXhog4iCWRHaRMAB(dxMt09ws09EzbGsyGq6b5UWHF9uGSKcXSQ8b067KC7esOwKOktpRos1)kFTqLPNskaAAOELREIDtMKws8pQQIM2jOijnD7E2veX5LQ5IX2ZlDZfJTNxkNlgBpV0o9MTNrQhw0W3XV07k5vQm(EogkLWYTHG60sJSgoqgn5)hR5uvD)Db0MuTcEvSf)NwB(mRHvuv9EuXQMr)aZaLMxLKt(weQY2WJTYvVEZ1WJ1mv8UCPWZMpy6nLPu87UE9mlt3nJftLPFlOcg2fBGcGAUGvwsbFEoNo1bIOwJLvJml)SQlMzBnCirhQ)c5zz4RYVW79SyBXlH3OtNAX8PXyPXKkLB2BMAWwBq(gAgZN1GQsfGuQEV5SyoLSBI2v2JFqwduUupNr6nCMCna5sZDGtlhviHzWPe3c500pyPySvuF8Wn50qZDSLpU1OpHS7koG8Fy)tNm7Q8L6AkVnXRLIwBpFQKft0eXnFcXfvkJtfh9GOHgx0YeWo2JmfemxjraxIMZVdHwY4OaxIM8(SWMv54BXp0EnPM1Pt5dOoDQsx9E7ANxpIoswLYFYQw41Utbvp7F4x)vtNZTEgHVEQ0IwWTOrJif9QoucwD3RnyVUYvXruYJQ5EovE0fotY3XkRHmFL6KkdAgZS(6TNv6kLGXAhpff(8zNoXmhoQH7FXDTotPRvl10ag6m)IetOCuy6anG4DKHV0AclfktU5qeQw5GFNTe54B3g6I4A1j(nqD(88DXwUjT3BiuE2U4Kvl)v0ZODHphs)WjR(F]] )