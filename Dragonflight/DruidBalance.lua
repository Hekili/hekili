-- DruidBalance.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 102 )

spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    aetherial_kindling          = { 88209, 327541, 2 }, -- Casting Starfall extends the duration of active Moonfires and Sunfires by 2 sec, up to 28 sec.
    astral_communion            = { 88235, 202359, 1 }, -- Generates 60 Astral Power.
    astral_influence            = { 82210, 197524, 2 }, -- Increases the range of all of your abilities by 3 yards.
    astral_smolder              = { 88204, 394058, 2 }, -- Your critical strikes from Starfire and Wrath cause the target to languish for an additional 20% of your spell's damage over 4 sec.
    balance_of_all_things       = { 88214, 394048, 2 }, -- Entering Eclipse increases your critical strike chance with Arcane or Nature spells by 16%, decreasing by 2% every 1 sec.
    celestial_alignment         = { 88215, 194223, 1 }, -- Celestial bodies align, maintaining both Eclipses and granting 10% haste for 20 sec.
    circle_of_life_and_death    = { 88227, 391969, 1 }, -- Your damage over time effects deal their damage in 25% less time, and your healing over time effects in 15% less time.
    convoke_the_spirits         = { 88206, 391528, 1 }, -- Call upon the Night Fae for an eruption of energy, channeling a rapid flurry of 16 Druid spells and abilities over 4 sec. You will cast Wild Growth, Swiftmend, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    cyclone                     = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 6 sec. Only one target can be affected by your Cyclone at a time.
    denizen_of_the_dream        = { 88218, 394065, 1 }, -- Your Moonfire and Sunfire have a chance to summon a Faerie Dragon to assist you in battle for 30 sec.
    eclipse                     = { 88223, 79577 , 1 }, -- Casting 2 Starfires empowers Wrath for 15 sec. Casting 2 Wraths empowers Starfire for 15 sec.  Eclipse (Solar) Nature spells deal 15% additional damage and Wrath damage is increased by 20%.  Eclipse (Lunar) Arcane spells deal 15% additional damage and Starfire critical strike chance is increased by 20%.
    elunes_guidance             = { 88228, 393991, 1 }, -- Incarnation: Chosen of Elune reduces the Astral Power cost of Starsurge by 5, and the Astral Power cost of Starfall by 8. Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    feline_swiftness            = { 82239, 131768, 2 }, -- Increases your movement speed by 15%.
    force_of_nature             = { 88210, 205636, 1 }, -- Summons a stand of 3 Treants for 10 sec which immediately taunt and attack enemies in the targeted area. Generates 20 Astral Power.
    frenzied_regeneration       = { 82220, 22842 , 1 }, -- Heals you for 32% health over 3 sec.
    friend_of_the_fae           = { 88234, 394081, 1 }, -- When a Faerie Dragon is summoned, your Arcane and Nature damage is increased by 6% for 30 sec.
    fungal_growth               = { 88205, 392999, 1 }, -- Enemies struck by Wild Mushrooms are damaged for an additional 70% over 8 sec and slowed by 50%.
    fury_of_elune               = { 88224, 202770, 1 }, -- Calls down a beam of pure celestial energy that follows the enemy, dealing up to 1,101 Astral damage over 8 sec within its area. Damage reduced on secondary targets. Generates 40 Astral Power over its duration.
    heart_of_the_wild           = { 82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Feral: Physical damage increased by 30%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges. Restoration: Healing increased by 30%, and mana costs reduced by 50%.
    hibernate                   = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin           = { 82219, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_rejuvenation       = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec.
    improved_stampeding_roar    = { 82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    improved_sunfire            = { 82207, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within 8 yards.
    incapacitating_roar         = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 10 yards for 3 sec. Damage will cancel the effect.
    incarnation_chosen_of_elune = { 88206, 394013, 1 }, -- An improved Moonkin Form that grants both Eclipses, any learned Celestial Alignment bonuses, and 10% critical strike chance. Lasts 30 sec. You may shapeshift in and out of this improved Moonkin Form for its duration.
    innervate                   = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 10 sec.
    ironfur                     = { 82227, 192081, 1 }, -- Increases armor by 448 for 7 sec.
    killer_instinct             = { 82225, 108299, 3 }, -- Physical damage and Armor increased by 2%.
    light_of_the_sun            = { 88211, 202918, 1 }, -- Reduces the remaining cooldown on Solar Beam by 15 sec when it interrupts the primary target.
    lunar_shrapnel              = { 88232, 393868, 1 }, -- Starfall's stars have a chance to deal an additional 25% damage to nearby enemies when they damage an enemy afflicted by Moonfire. Deals reduced damage beyond 8 targets.
    lycaras_teachings           = { 82233, 378988, 3 }, -- You gain 2% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                        = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 58 damage, 1 sec 2 points: 116 damage, 2 sec 3 points: 173 damage, 3 sec 4 points: 231 damage, 4 sec 5 points: 289 damage, 5 sec
    mass_entanglement           = { 82242, 102359, 1 }, -- Roots the target and all enemies within 15 yards in place for 30 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                  = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 1,189 damage for 8 sec.
    mighty_bash                 = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    moonkin_form                = { 82212, 24858 , 1 }, -- Shapeshift into Moonkin Form, increasing the damage of your spells by 10% and your armor by 125%, and granting protection from Polymorph effects. While in this form, single-target attacks against you have a 15% chance to make your next Starfire instant. The act of shapeshifting frees you from movement impairing effects.
    natural_recovery            = { 82206, 377796, 2 }, -- Healing done and healing taken increased by 3%.
    natures_balance             = { 88226, 202430, 1 }, -- While in combat you generate 1 Astral Power every 2 sec. While out of combat your Astral Power rebalances to 50 instead of depleting to empty.
    natures_grace               = { 88222, 393958, 1 }, -- After an Eclipse ends, you gain 15% Haste for 6 sec.
    natures_vigil               = { 82244, 124974, 1 }, -- For 30 sec, all single-target damage also heals a nearby friendly target for 20% of the damage done.
    new_moon                    = { 88224, 274281, 1 }, -- Deals 406.8 Astral damage to the target and empowers New Moon to become Half Moon. Generates 10 Astral Power.
    nurturing_instinct          = { 82214, 33873 , 3 }, -- Magical damage and healing increased by 2%.
    orbit_breaker               = { 88199, 383197, 1 }, -- Every 30th Shooting Star calls down a Full Moon at 80% power upon its target.
    orbital_strike              = { 88221, 390378, 1 }, -- Celestial Alignment blasts all enemies in a targeted area for 834 Astral damage and applies Stellar Flare to them.
    power_of_goldrinn           = { 88207, 394046, 1 }, -- Starsurge has a chance to summon the Spirit of Goldrinn, which immediately deals 433 Arcane damage to the target.
    primal_fury                 = { 82238, 159286, 1 }, -- When you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect.
    primordial_arcanic_pulsar   = { 88221, 393960, 1 }, -- Every 600 Astral Power spent grants Celestial Alignment for 12 sec.
    protector_of_the_pack       = { 82245, 378986, 1 }, -- Store 10% of your damage, up to 539. Your next Regrowth consumes all stored damage to increase its healing.
    radiant_moonlight           = { 88213, 394121, 1 }, -- Full Moon becomes Full Moon once more before resetting to New Moon. Fury of Elune's cooldown is reduced by 15 sec.
    rake                        = { 82199, 1822  , 1 }, -- Rake the target for 128 Bleed damage and an additional 549 Bleed damage over 15 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    rattle_the_stars            = { 88236, 393954, 1 }, -- Starsurge and Starfall reduce the cost of Starsurge and Starfall by 5% and increase their damage by 10% for 5 sec, stacking up to 2 times.
    rejuvenation                = { 82217, 774   , 1 }, -- Heals the target for 558 over 12 sec.
    remove_corruption           = { 82205, 2782  , 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    renewal                     = { 82232, 108238, 1 }, -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    rip                         = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 348 over 8 sec 2 points: 522 over 12 sec 3 points: 696 over 16 sec 4 points: 871 over 20 sec 5 points: 1,044 over 24 sec
    shooting_stars              = { 88225, 202342, 1 }, -- Moonfire, Sunfire, and Stellar Flare damage over time has a chance to call down a falling star, dealing 75 Astral damage and generating 2 Astral Power.
    skull_bash                  = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 4 sec.
    solar_beam                  = { 88231, 78675 , 1 }, -- Summons a beam of solar light over an enemy target's location, interrupting the target and silencing all enemies within the beam. Lasts 8 sec.
    solstice                    = { 88203, 343647, 2 }, -- During the first 6 sec of every Eclipse, Shooting Stars fall 100% more often.
    soothe                      = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    soul_of_the_forest          = { 88212, 114107, 1 }, -- Eclipse increases Wrath's Astral power generation 50%, and increases Starfire's area effect damage by 150%.
    stampeding_roar             = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 15 yards by 60% for 8 sec.
    starfall                    = { 88201, 191034, 1 }, -- Calls down waves of falling stars upon enemies within 40 yds, dealing 471 Astral damage over 8 sec. Multiple uses of this ability may overlap.
    starfire                    = { 82201, 194153, 1 }, -- Call down a burst of energy, causing 319 Arcane damage to the target, and 103 Arcane damage to all other enemies within 10 yards. Generates 8 Astral Power.
    starlord                    = { 88200, 202345, 2 }, -- Starsurge and Starfall grant you 2% Haste for 15 sec. Stacks up to 3 times. Gaining a stack does not refresh the duration.
    starsurge                   = { 82202, 78674 , 1 }, -- Launch a surge of stellar energies at the target, dealing 561 Astral damage, and empowering the damage bonus of any active Eclipse for its duration.
    starweaver                  = { 88236, 393940, 1 }, -- Starsurge has a 20% chance to make Starfall free. Starfall has a 40% chance to make Starsurge free.
    stellar_flare               = { 91048, 202347, 1 }, -- Burns the target for 52 Astral damage, and then an additional 438 damage over 24 sec. Generates 8 Astral Power.
    stellar_innervation         = { 88229, 394115, 1 }, -- During Solar Eclipse, Sunfire generates 100% additional Astral Power. During Lunar Eclipse, Moonfire generates 100% additional Astral Power.
    sundered_firmament          = { 88217, 394094, 1 }, -- Every other Eclipse creates a Fury of Elune at 20% effectiveness that follows your current target for 8 sec.
    sunfire                     = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for 83 Nature damage and then an additional 653 Nature damage over 18 sec. Generates 2 Astral Power.
    swiftmend                   = { 82216, 18562 , 1 }, -- Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for 1,562.
    swipe                       = { 82226, 213764, 1 }, -- Swipe nearby enemies, inflicting Physical damage. Damage varies by shapeshift form.
    thick_hide                  = { 82228, 16931 , 2 }, -- Reduces all damage taken by 6%.
    thrash                      = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                  = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    tireless_pursuit            = { 82197, 377801, 1 }, -- For 3 sec after leaving Cat Form or Travel Form, you retain up to 40% movement speed.
    twin_moons                  = { 88208, 279620, 1 }, -- Moonfire deals 10% increased damage and also hits another nearby enemy within 15 yds of the target.
    typhoon                     = { 82209, 132469, 1 }, -- Blasts targets within 15 yards in front of you with a violent Typhoon, knocking them back and dazing them for 6 sec. Usable in all shapeshift forms.
    umbral_embrace              = { 88216, 393760, 2 }, -- Dealing Astral damage has a chance to cause your next Wrath or Starfire to become Astral and deal 25% additional damage.
    umbral_intensity            = { 88219, 383195, 2 }, -- Solar Eclipse increases the damage of Wrath by an additional 10%. Lunar Eclipse increases the critical strike chance of Starfire by an additional 10%.
    ursine_vigor                = { 82235, 377842, 2 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 10%.
    ursols_vortex               = { 82242, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart               = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    waning_twilight             = { 88202, 393956, 2 }, -- When you have 3 periodic effects on a target, your damage and healing on them are increased by 4%.
    warrior_of_elune            = { 88233, 202425, 1 }, -- Your next 3 Starfires are instant cast and generate 40% increased Astral Power.
    wellhoned_instincts         = { 82246, 377847, 2 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 120 sec.
    wild_charge                 = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                 = { 82241, 48438 , 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 443 over 7 sec. Healing starts high and declines over the duration.
    wild_mushroom               = { 88220, 88747 , 1 }, -- Grow a magical mushroom at the target enemy's location. After 1 sec, the mushroom detonates, dealing 584 Nature damage and generating up to 20 Astral Power based on targets hit.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    celestial_guardian     = 180 , -- 233754
    crescent_burn          = 182 , -- 200567
    deep_roots             = 834 , -- 233755
    dying_stars            = 822 , -- 232546
    faerie_swarm           = 836 , -- 209749
    high_winds             = 5383, -- 200931
    malornes_swiftness     = 5515, -- 236147
    moon_and_stars         = 184 , -- 233750
    moonkin_aura           = 185 , -- 209740
    owlkin_adept           = 5407, -- 354541
    precognition           = 5503, -- 377360
    protector_of_the_grove = 3728, -- 209730
    reactive_resin         = 5526, -- 203399
    star_burst             = 3058, -- 356517
    thorns                 = 3731, -- 305497
} )


-- Auras
spec:RegisterAuras( {
    barkskin = {
        id = 22812,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    bear_form = {
        id = 5487,
        duration = 3600,
        max_stack = 1
    },
    blessing_of_anshe = {
        id = 202739,
        duration = 3600,
        tick_time = 3,
        max_stack = 1
    },
    blessing_of_elune = {
        id = 202737,
        duration = 3600,
        max_stack = 1
    },
    cat_form = {
        id = 768,
        duration = 3600,
        max_stack = 1
    },
    celestial_alignment = {
        id = 194223,
        duration = 20,
        max_stack = 1
    },
    convoke_the_spirits = {
        id = 323764,
        duration = 4,
        tick_time = 0.25,
        max_stack = 99
    },
    cyclone = {
        id = 33786,
        duration = 6,
        max_stack = 1
    },
    dash = {
        id = 1850,
        duration = 10,
        max_stack = 1
    },
    entangling_roots = {
        id = 339,
        duration = 30,
        tick_time = 2,
        max_stack = 1
    },
    faerie_swarm = {
        id = 209749,
        duration = 5,
        max_stack = 1
    },
    force_of_nature = { -- TODO: Is a totem?  Summon?
        id = 248280,
        duration = 10,
        max_stack = 1
    },
    frenzied_regeneration = {
        id = 22842,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    fury_of_elune = {
        id = 202770,
        duration = 8,
        tick_time = 0.5,
        max_stack = 1
    },
    growl = {
        id = 6795,
        duration = 3,
        max_stack = 1
    },
    heart_of_the_wild = {
        id = 319454,
        duration = 45,
        max_stack = 1
    },
    hibernate = {
        id = 2637,
        duration = 40,
        max_stack = 1
    },
    incapacitating_roar = {
        id = 99,
        duration = 3,
        max_stack = 1
    },
    incarnation_chosen_of_elune = {
        id = 102560,
        duration = 30,
        max_stack = 1,
        copy = "incarnation"
    },
    innervate = {
        id = 29166,
        duration = 10,
        max_stack = 1
    },
    ironfur = {
        id = 192081,
        duration = 7,
        max_stack = 1
    },
    mark_of_the_wild = {
        id = 1126,
        duration = 3600,
        max_stack = 1
    },
    mass_entanglement = {
        id = 102359,
        duration = 30,
        tick_time = 2,
        max_stack = 1
    },
    mighty_bash = {
        id = 5211,
        duration = 4,
        max_stack = 1
    },
    moonkin_form = {
        id = 24858,
        duration = 3600,
        max_stack = 1
    },
    natures_vigil = {
        id = 124974,
        duration = 30,
        tick_time = 0.5,
        max_stack = 1
    },
    prowl = {
        id = 5215,
        duration = 3600,
        max_stack = 1
    },
    rake = {
        id = 155722,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    regrowth = {
        id = 8936,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    rejuvenation = {
        id = 774,
        duration = 12,
        tick_time = 3,
        max_stack = 1
    },
    rip = {
        id = 1079,
        duration = 24,
        tick_time = 2,
        max_stack = 1
    },
    solar_beam = { -- Silence.
        id = 78675,
        duration = 8,
        max_stack = 1
    },
    solstice = {
        id = 343648,
        duration = 6,
        max_stack = 1
    },
    stampeding_roar = {
        id = 106898,
        duration = 8,
        max_stack = 1
    },
    starfall = {
        id = 393040,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    stellar_flare = {
        id = 202347,
        duration = 24,
        tick_time = 2,
        max_stack = 1
    },
    thorns = {
        id = 305497,
        duration = 12,
        max_stack = 1
    },
    tiger_dash = {
        id = 252216,
        duration = 5,
        tick_time = 0.5,
        max_stack = 1
    },
    timeworn_dreambinder = {
        id = 340049,
        duration = 5,
        max_stack = 2
    },
    travel_form = {
        id = 783,
        duration = 3600,
        max_stack = 1
    },
    typhoon = {
        id = 61391,
        duration = 6,
        max_stack = 1
    },
    ursine_vigor = {
        id = 340541,
        duration = 4,
        max_stack = 1
    },
    ursocs_endurance = {
        id = 385787,
        duration = 8,
        max_stack = 1
    },
    ursols_vortex = {
        id = 102793,
        duration = 10,
        max_stack = 1
    },
    warrior_of_elune = {
        id = 202425,
        duration = 3600,
        max_stack = 1
    },
    wild_charge = {
        id = 102401,
        duration = 0.5,
        max_stack = 1
    },
    wild_growth = {
        id = 48438,
        duration = 7,
        tick_time = 1,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    adaptive_swarm = {
        id = 325727,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        talent = "adaptive_swarm",
        startsCombat = false,
        texture = 3578197,

        handler = function ()
        end,
    },


    barkskin = {
        id = 22812,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = false,
        texture = 136097,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    bear_form = {
        id = 5487,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132276,

        handler = function ()
        end,
    },


    blessing_of_anshe = {
        id = 202739,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "blessing_of_anshe",
        startsCombat = false,
        texture = 608954,

        handler = function ()
        end,
    },


    blessing_of_elune = {
        id = 202737,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "blessing_of_elune",
        startsCombat = false,
        texture = 236704,

        handler = function ()
        end,
    },


    cat_form = {
        id = 768,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132115,

        handler = function ()
        end,
    },


    celestial_alignment = {
        id = 194223,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "celestial_alignment",
        startsCombat = false,
        texture = 136060,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    convoke_the_spirits = {
        id = 323764,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "convoke_the_spirits",
        startsCombat = false,
        texture = 3636839,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    cyclone = {
        id = 33786,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        talent = "cyclone",
        startsCombat = false,
        texture = 136022,

        handler = function ()
        end,
    },


    dash = {
        id = 1850,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 132120,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    entangling_roots = {
        id = 339,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 136100,

        handler = function ()
        end,
    },


    faerie_swarm = {
        id = 209749,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        pvptalent = "faerie_swarm",
        startsCombat = false,
        texture = 538516,

        handler = function ()
        end,
    },


    ferocious_bite = {
        id = 22568,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132127,

        handler = function ()
        end,
    },


    force_of_nature = {
        id = 205636,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "force_of_nature",
        startsCombat = false,
        texture = 132129,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    frenzied_regeneration = {
        id = 22842,
        cast = 0,
        charges = 1,
        cooldown = 36,
        recharge = 36,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        talent = "frenzied_regeneration",
        startsCombat = false,
        texture = 132091,

        handler = function ()
        end,
    },


    fury_of_elune = {
        id = 202770,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "fury_of_elune",
        startsCombat = false,
        texture = 132123,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    growl = {
        id = 6795,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 132270,

        handler = function ()
        end,
    },


    heart_of_the_wild = {
        id = 319454,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        talent = "heart_of_the_wild",
        startsCombat = false,
        texture = 135879,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    hibernate = {
        id = 2637,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "hibernate",
        startsCombat = false,
        texture = 136090,

        handler = function ()
        end,
    },


    incapacitating_roar = {
        id = 99,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "incapacitating_roar",
        startsCombat = false,
        texture = 132121,

        handler = function ()
        end,
    },


    incarnation_chosen_of_elune = {
        id = 102560,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "incarnation_chosen_of_elune",
        startsCombat = false,
        texture = 571586,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    innervate = {
        id = 29166,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "innervate",
        startsCombat = false,
        texture = 136048,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    ironfur = {
        id = 192081,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",

        spend = 40,
        spendType = "rage",

        talent = "ironfur",
        startsCombat = false,
        texture = 1378702,

        handler = function ()
        end,
    },


    maim = {
        id = 22570,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        spend = 30,
        spendType = "energy",

        talent = "maim",
        startsCombat = false,
        texture = 132134,

        handler = function ()
        end,
    },


    mangle = {
        id = 33917,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        startsCombat = true,
        texture = 132135,

        handler = function ()
        end,
    },


    mark_of_the_wild = {
        id = 1126,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        startsCombat = false,
        texture = 136078,

        handler = function ()
        end,
    },


    mass_entanglement = {
        id = 102359,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "mass_entanglement",
        startsCombat = false,
        texture = 538515,

        handler = function ()
        end,
    },


    mighty_bash = {
        id = 5211,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "mighty_bash",
        startsCombat = false,
        texture = 132114,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    moonfire = {
        id = 8921,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 136096,

        handler = function ()
        end,
    },


    moonkin_form = {
        id = 24858,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "moonkin_form",
        startsCombat = false,
        texture = 136036,

        handler = function ()
        end,
    },


    natures_vigil = {
        id = 124974,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "natures_vigil",
        startsCombat = false,
        texture = 236764,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    new_moon = {
        id = 274281,
        cast = 1,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "totem",

        talent = "new_moon",
        startsCombat = false,
        texture = 1392545,

        handler = function ()
        end,
    },


    prowl = {
        id = 5215,
        cast = 0,
        cooldown = 6,
        gcd = "off",

        startsCombat = false,
        texture = 514640,

        handler = function ()
        end,
    },


    rake = {
        id = 1822,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "rake",
        startsCombat = false,
        texture = 132122,

        handler = function ()
        end,
    },


    rebirth = {
        id = 20484,
        cast = 2,
        cooldown = 600,
        gcd = "spell",

        spend = 0,
        spendType = "rage",

        startsCombat = true,
        texture = 136080,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    regrowth = {
        id = 8936,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        startsCombat = false,
        texture = 136085,

        handler = function ()
        end,
    },


    rejuvenation = {
        id = 774,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        talent = "rejuvenation",
        startsCombat = false,
        texture = 136081,

        handler = function ()
        end,
    },


    remove_corruption = {
        id = 2782,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "remove_corruption",
        startsCombat = false,
        texture = 135952,

        handler = function ()
        end,
    },


    renewal = {
        id = 108238,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "renewal",
        startsCombat = false,
        texture = 136059,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    revive = {
        id = 50769,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 132132,

        handler = function ()
        end,
    },


    rip = {
        id = 1079,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 5,
        spendType = "combo_points",

        talent = "rip",
        startsCombat = false,
        texture = 132152,

        handler = function ()
        end,
    },


    shred = {
        id = 5221,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        startsCombat = true,
        texture = 136231,

        handler = function ()
        end,
    },


    skull_bash = {
        id = 106839,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        talent = "skull_bash",
        startsCombat = false,
        texture = 236946,

        handler = function ()
        end,
    },


    solar_beam = {
        id = 78675,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.17,
        spendType = "mana",

        talent = "solar_beam",
        startsCombat = false,
        texture = 252188,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    soothe = {
        id = 2908,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "soothe",
        startsCombat = false,
        texture = 132163,

        handler = function ()
        end,
    },


    stampeding_roar = {
        id = 106898,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "stampeding_roar",
        startsCombat = false,
        texture = 464343,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    starfall = {
        id = 191034,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 50,
        spendType = "lunar_power",

        talent = "starfall",
        startsCombat = false,
        texture = 236168,

        handler = function ()
        end,
    },


    starfire = {
        id = 194153,
        cast = 2.25,
        cooldown = 0,
        gcd = "spell",

        talent = "starfire",
        startsCombat = true,
        texture = 135753,

        handler = function ()
        end,
    },


    starsurge = {
        id = 78674,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "lunar_power",

        talent = "starsurge",
        startsCombat = true,
        texture = 135730,

        handler = function ()
        end,
    },


    stellar_flare = {
        id = 202347,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        talent = "stellar_flare",
        startsCombat = false,
        texture = 1052602,

        handler = function ()
        end,
    },


    sunfire = {
        id = 93402,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        talent = "sunfire",
        startsCombat = false,
        texture = 236216,

        handler = function ()
        end,
    },


    swiftmend = {
        id = 18562,
        cast = 0,
        charges = 1,
        cooldown = 15,
        recharge = 15,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "swiftmend",
        startsCombat = false,
        texture = 134914,

        handler = function ()
        end,
    },


    swipe = {
        id = 213764,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        talent = "swipe",
        startsCombat = false,
        texture = 134296,

        handler = function ()
        end,
    },


    teleport_moonglade = {
        id = 18960,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 10,
        spendType = "mana",

        startsCombat = false,
        texture = 135758,

        handler = function ()
        end,
    },


    thorns = {
        id = 305497,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 0.18,
        spendType = "mana",

        pvptalent = "thorns",
        startsCombat = false,
        texture = 136104,

        handler = function ()
        end,
    },


    thrash = {
        id = 106832,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "thrash",
        startsCombat = false,
        texture = 451161,

        handler = function ()
        end,
    },


    tiger_dash = {
        id = 252216,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "tiger_dash",
        startsCombat = false,
        texture = 1817485,

        handler = function ()
        end,
    },


    travel_form = {
        id = 783,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132144,

        handler = function ()
        end,
    },


    typhoon = {
        id = 132469,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "typhoon",
        startsCombat = false,
        texture = 236170,

        handler = function ()
        end,
    },


    ursols_vortex = {
        id = 102793,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "ursols_vortex",
        startsCombat = false,
        texture = 571588,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    warrior_of_elune = {
        id = 202425,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "warrior_of_elune",
        startsCombat = false,
        texture = 135900,

        handler = function ()
        end,
    },


    wild_charge = {
        id = 102401,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        talent = "wild_charge",
        startsCombat = false,
        texture = 538771,

        handler = function ()
        end,
    },


    wild_growth = {
        id = 48438,
        cast = 1.5,
        cooldown = 10,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        talent = "wild_growth",
        startsCombat = false,
        texture = 236153,

        handler = function ()
        end,
    },


    wrath = {
        id = 190984,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 535045,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Balance", 20220922,
-- Notes
[[

]],
-- Priority
[[

]] )