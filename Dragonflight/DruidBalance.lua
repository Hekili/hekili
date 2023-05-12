-- DruidBalance.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR

local strformat = string.format

local spec = Hekili:NewSpecialization( 102 )

spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.LunarPower, {
    fury_of_elune = {
        aura = "fury_of_elune_ap",
        debuff = true,

        last = function ()
            local app = state.debuff.fury_of_elune_ap.applied
            local t = state.query_time

            return app + floor( ( t - app ) * 2 ) * 0.5
        end,

        interval = 0.5,
        value = 3
    },

    celestial_infusion = {
        aura = "celestial_infusion",

        last = function ()
            local app = state.buff.celestial_infusion.applied
            local t = state.query_time

            return app + floor( ( t - app ) * 2 ) * 0.5
        end,

        interval = 0.5,
        value = 2.5
    },

    natures_balance = {
        talent = "natures_balance",

        last = function ()
            local app = state.combat
            local t = state.query_time

            return app + floor( ( t - app ) / 2 ) * 2
        end,

        interval = 3,
        value = 2,
    }
} )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    -- Druid
    astral_influence            = { 82210, 197524, 2 }, -- Increases the range of all of your abilities by 3 yards.
    cyclone                     = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 6 sec. Only one target can be affected by your Cyclone at a time.
    feline_swiftness            = { 82239, 131768, 2 }, -- Increases your movement speed by 15%.
    forestwalk                  = { 92229, 400129, 2 }, -- Casting Regrowth increases your movement speed and healing received by 5% for 3 sec.
    gale_winds                  = { 92228, 400142, 1 }, -- Increases Typhoon's radius by 20% and its range by 5 yds.
    heart_of_the_wild           = { 82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Feral: Physical damage increased by 30%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges. Restoration: Healing increased by 30%, and mana costs reduced by 50%.
    hibernate                   = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin           = { 82219, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_rejuvenation       = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec.
    improved_stampeding_roar    = { 82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    improved_sunfire            = { 82207, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within 8 yards.
    improved_swipe              = { 82226, 400158, 1 }, -- Increases Swipe damage by 100%.
    incapacitating_roar         = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 15 yards for 3 sec. Damage will cancel the effect.
    incessant_tempest           = { 92228, 400140, 1 }, -- Reduces the cooldown of Typhoon by 5 sec.
    innervate                   = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 10 sec.
    ironfur                     = { 82227, 192081, 1 }, -- Increases armor by 2,509 for 7 sec.
    killer_instinct             = { 82225, 108299, 2 }, -- Physical damage and Armor increased by 2%.
    lycaras_teachings           = { 82233, 378988, 3 }, -- You gain 2% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                        = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 717 damage, 1 sec 2 points: 1,434 damage, 2 sec 3 points: 2,152 damage, 3 sec 4 points: 2,869 damage, 4 sec 5 points: 3,587 damage, 5 sec
    mass_entanglement           = { 82242, 102359, 1 }, -- Roots the target and all enemies within 15 yards in place for 30 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                  = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 18,468 damage for 8 sec.
    mighty_bash                 = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    natural_recovery            = { 82206, 377796, 2 }, -- Healing done and healing taken increased by 3%.
    natures_vigil               = { 82244, 124974, 1 }, -- For 30 sec, all single-target damage also heals a nearby friendly target for 20% of the damage done.
    nurturing_instinct          = { 82214, 33873 , 2 }, -- Magical damage and healing increased by 2%.
    primal_fury                 = { 82238, 159286, 1 }, -- When you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect.
    protector_of_the_pack       = { 82245, 378986, 1 }, -- Store 5% of your damage, up to 24,795. Your next Regrowth consumes all stored damage to increase its healing.
    renewal                     = { 82232, 108238, 1 }, -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    skull_bash                  = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    soothe                      = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar             = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 20 yards by 60% for 8 sec.
    sunfire                     = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for 1,219 Nature damage and then an additional 13,957 Nature damage over 18 sec to the primary target and all enemies within 8 yards. Generates 6 Astral Power.
    thick_hide                  = { 82228, 16931 , 2 }, -- Reduces all damage taken by 6%.
    tiger_dash                  = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    tireless_pursuit            = { 82197, 377801, 1 }, -- For 3 sec after leaving Cat Form or Travel Form, you retain up to 40% movement speed.
    typhoon                     = { 82209, 132469, 1 }, -- Blasts targets within 20 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by 50% for 6 sec. Usable in all shapeshift forms.
    ursine_vigor                = { 82235, 377842, 2 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 10%.
    ursols_vortex               = { 82242, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart               = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    wellhoned_instincts         = { 82246, 377847, 2 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 120 sec.
    wild_charge                 = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                 = { 82241, 48438 , 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 8,078 over 7 sec. Healing starts high and declines over the duration.

    -- Balance
    aetherial_kindling          = { 88209, 327541, 1 }, -- Casting Starfall extends the duration of active Moonfires and Sunfires by 4 sec, up to 28 sec.
    astral_communion            = { 88235, 400636, 1 }, -- Increases maximum Astral Power by 20 and teaches Astral Communion: Astral Communion: Generates 60 Astral Power. 60 sec cooldown.
    astral_smolder              = { 88204, 394058, 2 }, -- Your critical strikes from Starfire and Wrath cause the target to languish for an additional 40% of your spell's damage over 8 sec.
    balance_of_all_things       = { 88214, 394048, 2 }, -- Entering Eclipse increases your critical strike chance with Arcane or Nature spells by 16%, decreasing by 2% every 1 sec.
    celestial_alignment         = { 88215, 194223, 1 }, -- Celestial bodies align, maintaining both Eclipses and granting 10% haste for 20 sec.
    convoke_the_spirits         = { 88206, 391528, 1 }, -- Call upon the Night Fae for an eruption of energy, channeling a rapid flurry of 12 Druid spells and abilities over 3 sec. You will cast Starsurge, Starfall, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    cosmic_rapidity             = { 88227, 400059, 2 }, -- Your Moonfire, Sunfire, and Stellar Flare deal damage 20% faster.
    denizen_of_the_dream        = { 88218, 394065, 1 }, -- Your Moonfire and Sunfire have a chance to summon a Faerie Dragon to assist you in battle for 30 sec.
    eclipse                     = { 88223, 79577 , 1 }, -- Casting 2 Starfires empowers Wrath for 15 sec. Casting 2 Wraths empowers Starfire for 15 sec.  Eclipse (Solar) Nature spells deal 15% additional damage and Wrath damage is increased by 20%.  Eclipse (Lunar) Arcane spells deal 15% additional damage and the damage Starfire deals to nearby enemies is increased by 30%.
    elunes_guidance             = { 88228, 393991, 1 }, -- Incarnation: Chosen of Elune reduces the Astral Power cost of Starsurge by 8, and the Astral Power cost of Starfall by 10. Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    force_of_nature             = { 88210, 205636, 1 }, -- Summons a stand of 3 Treants for 10 sec which immediately taunt and attack enemies in the targeted area. Generates 20 Astral Power.
    frenzied_regeneration       = { 82220, 22842 , 1 }, -- Heals you for 32% health over 3 sec, and increases healing received by 20%.
    friend_of_the_fae           = { 88234, 394081, 1 }, -- When a Faerie Dragon is summoned, your Arcane and Nature damage is increased by 8% for 20 sec.
    fungal_growth               = { 88205, 392999, 1 }, -- Enemies struck by Wild Mushrooms are damaged for an additional 70% over 8 sec and slowed by 50%.
    fury_of_elune               = { 88224, 202770, 1 }, -- Calls down a beam of pure celestial energy that follows the enemy, dealing up to 18,044 Astral damage over 8 sec within its area. Damage reduced on secondary targets. Generates 40 Astral Power over its duration.
    incarnation                 = { 88206, 102560, 1 }, -- An improved Moonkin Form that grants both Eclipses, any learned Celestial Alignment bonuses, and 10% critical strike chance. Lasts 30 sec. You may shapeshift in and out of this improved Moonkin Form for its duration.
    incarnation_chosen_of_elune = { 88206, 102560, 1 }, -- An improved Moonkin Form that grants both Eclipses, any learned Celestial Alignment bonuses, and 10% critical strike chance. Lasts 30 sec. You may shapeshift in and out of this improved Moonkin Form for its duration.
    light_of_the_sun            = { 88211, 202918, 1 }, -- Reduces the remaining cooldown on Solar Beam by 15 sec when it interrupts the primary target.
    lunar_shrapnel              = { 88232, 393868, 2 }, -- Starfall's stars have a chance to deal an additional 13% damage to nearby enemies when they damage an enemy afflicted by Moonfire. Deals reduced damage beyond 8 targets.
    moonkin_form                = { 82212, 24858 , 1 }, -- Shapeshift into Astral Form, increasing the damage of your spells by 10% and your armor by 125%, and granting protection from Polymorph effects. While in this form, single-target attacks against you have a 15% chance to make your next Starfire instant. The act of shapeshifting frees you from movement impairing effects.
    natures_balance             = { 88226, 202430, 1 }, -- While in combat you generate 2 Astral Power every 3 sec. While out of combat your Astral Power rebalances to 50 instead of depleting to empty.
    natures_grace               = { 88222, 393958, 1 }, -- After an Eclipse ends, you gain 15% Haste for 6 sec.
    new_moon                    = { 88224, 274281, 1 }, -- Deals 5943.9 Astral damage to the target and empowers New Moon to become Half Moon. Generates 12 Astral Power.
    orbit_breaker               = { 88199, 383197, 1 }, -- Every 30th Shooting Star calls down a Full Moon at 80% power upon its target.
    orbital_strike              = { 88221, 390378, 1 }, -- Celestial Alignment blasts all enemies in a targeted area for 12,192 Astral damage and applies Stellar Flare to them. Reduces the cooldown of Incarnation: Chosen of Elune by 60 sec.
    power_of_goldrinn           = { 88207, 394046, 2 }, -- Starsurge has a chance to summon the Spirit of Goldrinn, which immediately deals 8,656 Astral damage to the target.
    primordial_arcanic_pulsar   = { 88221, 393960, 1 }, -- Every 600 Astral Power spent grants Celestial Alignment for 12 sec.
    radiant_moonlight           = { 88213, 394121, 1 }, -- New Moon, Half Moon, and Full Moon deal 25% increased damage. Full Moon becomes Full Moon once more before resetting to New Moon. Fury of Elune deals 50% increased damage and its cooldown is reduced by 20 sec.
    rake                        = { 82199, 1822  , 1 }, -- Rake the target for 964 Bleed damage and an additional 7,636 Bleed damage over 15 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    rattle_the_stars            = { 88236, 393954, 1 }, -- Starsurge and Starfall reduce the cost of Starsurge and Starfall by 5% and increase their damage by 8% for 6 sec, stacking up to 2 times.
    rejuvenation                = { 82217, 774   , 1 }, -- Heals the target for 12,513 over 15 sec.
    remove_corruption           = { 82205, 2782  , 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    rip                         = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 4,932 over 8 sec 2 points: 7,399 over 12 sec 3 points: 9,865 over 16 sec 4 points: 12,331 over 20 sec 5 points: 14,798 over 24 sec
    shooting_stars              = { 88225, 202342, 1 }, -- Moonfire and Sunfire damage over time has a chance to call down a falling star, dealing 1,097 Astral damage and generating 2 Astral Power.
    solar_beam                  = { 88231, 78675 , 1 }, -- Summons a beam of solar light over an enemy target's location, interrupting the target and silencing all enemies within the beam. Lasts 8 sec.
    solstice                    = { 88203, 343647, 1 }, -- During the first 6 sec of every Eclipse, Shooting Stars fall 200% more often.
    soul_of_the_forest          = { 88212, 114107, 1 }, -- Solar Eclipse increases Wrath's Astral power generation by 30% and Lunar Eclipse increases Starfire's damage and Astral Power generation by 20% for each target hit beyond the first, up to 60%.
    starfall                    = { 88201, 191034, 1 }, -- Calls down waves of falling stars upon enemies within 45 yds, dealing 6,254 Astral damage over 8 sec. Multiple uses of this ability may overlap.
    starfire                    = { 82201, 194153, 1 }, -- Call down a burst of energy, causing 3,964 Arcane damage to the target, and 1,275 Arcane damage to all other enemies within 10 yards. Generates 10 Astral Power.
    starlord                    = { 88200, 202345, 2 }, -- Starsurge and Starfall grant you 2% Haste for 15 sec. Stacks up to 3 times. Gaining a stack does not refresh the duration.
    starsurge                   = { 82202, 78674 , 1 }, -- Launch a surge of stellar energies at the target, dealing 8,366 Astral damage.
    starweaver                  = { 88236, 393940, 1 }, -- Starsurge has a 20% chance to make Starfall free. Starfall has a 40% chance to make Starsurge free.
    stellar_flare               = { 91048, 202347, 1 }, -- Burns the target for 853 Astral damage, and then an additional 10,481 damage over 24 sec. If dispelled, causes 17,069 damage to the dispeller and blast them upwards. Generates 12 Astral Power.
    stellar_innervation         = { 88229, 394115, 1 }, -- During Solar Eclipse, Sunfire generates 100% additional Astral Power. During Lunar Eclipse, Moonfire generates 100% additional Astral Power.
    sundered_firmament          = { 88217, 394094, 1 }, -- Every other Eclipse creates a Fury of Elune at 20% effectiveness that follows your current target for 8 sec.
    swiftmend                   = { 82216, 18562 , 1 }, -- Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for 32,421.
    thrash                      = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    twin_moons                  = { 88208, 279620, 1 }, -- Moonfire deals 10% increased damage and also hits another nearby enemy within 15 yds of the target.
    umbral_embrace              = { 88216, 393760, 2 }, -- Dealing Astral damage has a chance to cause your next Wrath or Starfire cast during an Eclipse to become Astral and deal 25% additional damage.
    umbral_intensity            = { 88219, 383195, 2 }, -- Solar Eclipse increases the damage of Wrath by an additional 10%. Lunar Eclipse increases the damage Starfire deals to nearby enemies by an additional 10%.
    waning_twilight             = { 88202, 393956, 2 }, -- When you have 3 periodic effects on a target, your damage and healing on them are increased by 4%.
    warrior_of_elune            = { 88210, 202425, 1 }, -- Your next 3 Starfires are instant cast and generate 40% increased Astral Power.
    wild_mushroom               = { 88220, 88747 , 1 }, -- Grow a magical mushroom at the target enemy's location. After 1 sec, the mushroom detonates, dealing 8,534 Nature damage and generating up to 20 Astral Power based on targets hit.
    wild_surges                 = { 91048, 406890, 1 }, -- Your Wrath and Starfire chance to critically strike is increased by 15% and they generate 2 additional Astral Power.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    celestial_guardian     = 180 , -- (233754) Bear Form reduces magic damage taken from spells by 10% and you may now cast Moonfire while in Bear Form.
    crescent_burn          = 182 , -- (200567) Using Moonfire on a target already afflicted by Moonfire's damage over time effect deals 35% additional direct damage.
    deep_roots             = 834 , -- (233755) Increases the amount of damage required to cancel your Entangling Roots by 250%.
    dying_stars            = 822 , -- (232546) Sunfire and Moonfire generate 3 Astral Power when they are dispelled.
    faerie_swarm           = 836 , -- (209749) Swarms the target with Faeries, disarming the enemy, preventing the use of any weapons or shield and reducing movement speed by 30% for 5 sec.
    high_winds             = 5383, -- (200931) Cyclone leaves the target reeling, reducing their damage and healing by 30% for 4 sec.
    malornes_swiftness     = 5515, -- (236147) Your Travel Form movement speed while within a Battleground or Arena is increased by 20% and you always move at 100% movement speed while in Travel Form.
    moon_and_stars         = 184 , -- (233750) Entering an Eclipse summons a beam of light at your location granting you 70% reduction in silence and interrupts for 10 sec.
    moonkin_aura           = 185 , -- (209740) Starsurge grants 4% spell critical strike chance to 8 allies within 40 yards for 18 sec, stacking up to 3 times.
    owlkin_adept           = 5407, -- (354541) Owlkin Frenzy can stack up to 2 times and reduces the cast time of your next Cyclone or Entangling Roots by 30%.
    precognition           = 5503, -- (377360) If an interrupt is used on you while you are not casting, gain 15% haste and become immune to control and interrupt effects for 4 sec.
    protector_of_the_grove = 3728, -- (209730) When using Regrowth on an ally the initial heal will always have a critical effect and the cast time of Regrowth will be reduced by 50% for 6 sec.
    reactive_resin         = 5526, -- (203399) Casting Rejuvenation grants the target 2 charges of Reactive Resin. Reactive Resin will heal the target for 245 after taking a melee critical strike, and increase the duration of Rejuvenation by 3 sec.
    star_burst             = 3058, -- (356517) Starfall calls down collapsing stars that last 15 sec. Enemies that come into contact with a star cause it to burst, knocking nearby enemies upwards and dealing 1,168 Astral damage. Generates 15 Astral Power. The Druid and their allies may pick up stars, causing them to orbit around you.
    thorns                 = 3731, -- (305497) Sprout thorns for 12 sec on the friendly target. When victim to melee attacks, thorns deals 501 Nature damage back to the attacker. Attackers also have their movement speed reduced by 50% for 4 sec.
} )


spec:RegisterPower( "lively_spirit", 279642, {
    id = 279648,
    duration = 20,
    max_stack = 1,
} )


local mod_circle_hot = setfenv( function( x )
    return x
end, state )

local mod_circle_dot = setfenv( function( x )
    return x
end, state )


-- Auras
spec:RegisterAuras( {
    astral_smolder = {
        id = 394061,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Critical strike chance with Nature spells increased $w1%.
    -- https://wowhead.com/beta/spell=394049
    balance_of_all_things_nature = {
        id = 394049,
        duration = 8,
        max_stack = 8,
        copy = 339943
    },
    -- Talent: Critical strike chance with Arcane spells increased $w1%.
    -- https://wowhead.com/beta/spell=394050
    balance_of_all_things_arcane = {
        id = 394050,
        duration = 8,
        max_stack = 8,
        copy = 339946
    },
    -- All damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=22812
    barkskin = {
        id = 22812,
        duration = 8,
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
    -- Autoattack damage increased by $w4%.  Immune to Polymorph effects.  Movement speed increased by $113636s1% and falling damage reduced.
    -- https://wowhead.com/beta/spell=768
    cat_form = {
        id = 768,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Both Eclipses active. Haste increased by $w2%.
    -- https://wowhead.com/beta/spell=194223
    celestial_alignment = {
        id = 194223,
        duration = function () return 20 + ( conduit.precise_alignment.mod * 0.001 ) end,
        type = "Magic",
        max_stack = 1,
        copy = 383410
    },
    ca_inc = {}, -- stub for celestial vs. incarnation
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=102352
    cenarion_ward = {
        id = 102352,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent / Covenant (Night Fae): Every 0.25 sec, casting Wild Growth, Swiftmend, Moonfire, Wrath, Regrowth, Rejuvenation, Rake or Thrash on appropriate nearby targets.
    -- https://wowhead.com/beta/spell=391528
    convoke_the_spirits = {
        id = 391528,
        duration = 4,
        tick_time = 0.25,
        max_stack = 99,
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
    -- Arcane spells deal $w1% additional damage$?<$w5>0>[, area effect damage increased $w5%,][] and Starfire's critical strike chance is increased by $w2%.
    -- https://wowhead.com/beta/spell=48518
    eclipse_lunar = {
        id = 48518,
        duration = 15,
        max_stack = 1,
        meta = {
            empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
        }
    },
    -- Nature spells deal $w1% additional damage$?<$w5>0>[, Astral Power generation increased $w5%,][] and Wrath's damage is increased by $w2%.
    -- https://wowhead.com/beta/spell=48517
    eclipse_solar = {
        id = 48517,
        duration = 15,
        max_stack = 1,
        meta = {
            empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
        }
    },
    -- Rooted.$?<$w2>0>[ Suffering $w2 Nature damage every $t2 sec.][]
    -- https://wowhead.com/beta/spell=339
    entangling_roots = {
        id = 339,
        duration = 30,
        tick_time = 2,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    force_of_nature = { -- TODO: Is a totem?  Summon?
        id = 205644,
        duration = 15,
        max_stack = 1,
    },
    forestwalk = {
        id = 400129,
        duration = function() return 3 * talent.forestwalk.rank end,
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
    -- Talent: Healing $w1% health every $t1 sec.
    -- https://wowhead.com/beta/spell=22842
    frenzied_regeneration = {
        id = 22842,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    friend_of_the_fae = {
        id = 394081,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%. Suffering $w1 Nature damage every $t1 sec.
    -- https://wowhead.com/beta/spell=81281
    fungal_growth = {
        id = 81281,
        duration = 8,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Generating ${$m3/10/$t3*$d} Astral Power over $d.
    -- https://wowhead.com/beta/spell=202770
    fury_of_elune_ap = {
        id = 202770,
        duration = 8,
        tick_time = 0.5,
        max_stack = 1,

        generate = function ( t )
            local applied = action.fury_of_elune.lastCast

            if applied and now - applied < 8 then
                t.count = 1
                t.expires = applied + 8
                t.applied = applied
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,

        copy = "fury_of_elune"
    },
    -- Heals $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=383193
    grove_tending = {
        id = 383193,
        duration = 9,
        max_stack = 1,
        copy = 279793
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
    -- https://wowhead.com/beta/spell=319454
    heart_of_the_wild = {
        id = 319454,
        duration = 45,
        max_stack = 1,
        copy = { 108291, 108292, 108293, 108294 }
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
    -- Talent: Both Eclipses active. Critical strike chance increased by $w2%$?s194223[ and haste increased by $w1%][].
    -- https://wowhead.com/beta/spell=102560
    incarnation = {
        id = 102560,
        duration = function () return 30 + ( conduit.precise_alignment.mod * 0.001 ) end,
        max_stack = 1,
        copy = "incarnation_chosen_of_elune",
    },
    -- Movement speed slowed by $w1%.$?e1[ Healing taken reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=58180
    infected_wounds = {
        id = 58180,
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
    -- Talent: Armor increased by ${$w1*$AGI/100}.
    -- https://wowhead.com/beta/spell=192081
    ironfur = {
        id = 192081,
        duration = 7,
        type = "Magic",
        max_stack = 1
    },
    -- Versatility increased by $w1%.
    -- https://wowhead.com/beta/spell=1126
    mark_of_the_wild = {
        id = 1126,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        shared = "player"
    },
    -- Talent: Rooted.
    -- https://wowhead.com/beta/spell=102359
    mass_entanglement = {
        id = 102359,
        duration = 30,
        tick_time = 2,
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
    -- https://wowhead.com/beta/spell=164812
    moonfire = {
        id = 164812,
        duration = function () return mod_circle_dot( 22 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * ( 1 - 0.1 * talent.cosmic_rapidity.rank ) * haste end,
        type = "Magic",
        max_stack = 1,
        copy = 155625
    },
    -- Talent: Spell damage increased by $s9%.  Immune to Polymorph effects.$?$w3>0[  Armor increased by $w3%.][]
    -- https://wowhead.com/beta/spell=24858
    moonkin_form = {
        id = 24858,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        copy = 197625
    },
    natures_grace = {
        id = 393959,
        duration = 6,
        max_stack = 1
    },
    -- Talent: $?s137012[Single-target healing also damages a nearby enemy target for $w3% of the healing done][Single-target damage also heals a nearby friendly target for $w3% of the damage done].
    -- https://wowhead.com/beta/spell=124974
    natures_vigil = {
        id = 124974,
        duration = 30,
        tick_time = 0.5,
        max_stack = 1
    },
    -- Your next Starfire is instant cast$?s354541[ or your next Cyclone or Entangling Roots cast time is reduced by $s2%.][.]
    -- https://wowhead.com/beta/spell=157228
    owlkin_frenzy = {
        id = 157228,
        duration = 10,
        type = "Magic",
        max_stack = function () return pvptalent.owlkin_adept.enabled and 2 or 1 end
    },
    parting_skies = {
        id = 395110,
        duration = 60,
        max_stack = 1,
    },
    -- Cost of Starsurge and Starfall reduced by $w1%, and their damage increased by $w2%.
    -- https://wowhead.com/beta/spell=393955
    rattled_stars = {
        id = 393955,
        duration = 6,
        max_stack = 2,
        copy = "rattle_the_stars"
    },
    -- Heals $w2 every $t2 sec.
    -- https://wowhead.com/beta/spell=8936
    regrowth = {
        id = 8936,
        duration = function () return mod_circle_hot( 12 ) end,
        tick_time =  function () return mod_circle_hot( 2 ) end,
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
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=81261
    solar_beam = {
        id = 81261,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Interrupted.
    -- https://wowhead.com/beta/spell=78675
    solar_beam_silence = { -- Silence.
        id = 78675,
        duration = 8,
        max_stack = 1
    },
    solstice = {
        id = 343648,
        duration = 6,
        max_stack = 1,
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=207386
    spring_blossoms = {
        id = 207386,
        duration = 6,
        max_stack = 1
    },
    stag_form = {
        id = 210053,
        duration = 3600,
        max_stack = 1,
        generate = function ()
            local form = GetShapeshiftForm()
            local stag = form and form > 0 and select( 4, GetShapeshiftFormInfo( form ) )

            local sf = buff.stag_form

            if stag == 210053 then
                sf.count = 1
                sf.applied = now
                sf.expires = now + 3600
                sf.caster = "player"
                return
            end

            sf.count = 0
            sf.applied = 0
            sf.expires = 0
            sf.caster = "nobody"
        end,
    },
    -- Talent: Calling down falling stars on nearby enemies.
    -- https://wowhead.com/beta/spell=191034
    starfall = {
        id = 191034,
        duration = 8,
        type = "Magic",
        max_stack = 20,
        copy = 393040
    },
    starlord = {
        id = 279709,
        duration = 20,
        max_stack = 3,
    },
    starweavers_warp = { -- free Starfall.
        id = 393942,
        duration = 30,
        max_stack = 1,
    },
    starweavers_weft = { -- free Starsurge.
        id = 393944,
        duration = 30,
        max_stack = 1,
    },
    -- Talent: Suffering $w2 Astral damage every $t2 sec.
    -- https://wowhead.com/beta/spell=202347
    stellar_flare = {
        id = 202347,
        duration = function () return mod_circle_dot( 24 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * ( 1 - 0.1 * talent.cosmic_rapidity.rank ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 Nature damage every $t2 seconds.
    -- https://wowhead.com/beta/spell=164815
    sunfire = {
        id = 164815,
        duration = function () return mod_circle_dot( 18 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * ( 1 - 0.1 * talent.cosmic_rapidity.rank ) * haste end,
        type = "Magic",
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
    -- Talent: Increased movement speed by $s1% while in Cat Form, reducing gradually over time.
    -- https://wowhead.com/beta/spell=252216
    tiger_dash = {
        id = 252216,
        duration = 5,
        type = "Magic",
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
    treant_form = {
        id = 114282,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Dazed.
    -- https://wowhead.com/beta/spell=61391
    typhoon = {
        id = 61391,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Wrath of Starfire deals Astral damage and deals $w1% additional damage.
    -- https://wowhead.com/beta/spell=393763
    umbral_embrace = {
        id = 393763,
        duration = 15,
        max_stack = 1
    },
    ursine_vigor = {
        id = 340541,
        duration = 4,
        max_stack = 1
    },
    -- Movement speed slowed by $s1% and winds impeding movement.
    -- https://wowhead.com/beta/spell=102793
    ursols_vortex = {
        id = 102793,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Starfire is instant cast and generates $s2% increased Astral Power.
    -- https://wowhead.com/beta/spell=202425
    warrior_of_elune = {
        id = 202425,
        duration = 3600,
        type = "Magic",
        max_stack = 3
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

    -- Legendaries
    celestial_infusion = {
        id = 367907,
        duration = 8,
        max_stack = 1
    },
    oath_of_the_elder_druid = {
        id = 338643,
        duration = 60,
        max_stack = 1
    },
    oneths_perception = {
        id = 339800,
        duration = 30,
        max_stack = 1,
    },
    oneths_clear_vision = {
        id = 339797,
        duration = 30,
        max_stack = 1,
    },
    primordial_arcanic_pulsar = {
        id = 393961,
        duration = 3600,
        max_stack = 10,
        copy = 338825
    },
    timeworn_dreambinder = {
        id = 340049,
        duration = 6,
        max_stack = 2,
    },
} )


-- Adaptive Swarm Stuff
do
    local applications = {
        SPELL_AURA_APPLIED = true,
        SPELL_AURA_REFRESH = true,
        SPELL_AURA_APPLIED_DOSE = true
    }

    local casts = { SPELL_CAST_SUCCESS = true }

    local removals = {
        SPELL_AURA_REMOVED = true,
        SPELL_AURA_BROKEN = true,
        SPELL_AURA_BROKEN_SPELL = true,
        SPELL_AURA_REMOVED_DOSE = true,
        SPELL_DISPEL = true
    }

    local deaths = {
        UNIT_DIED       = true,
        UNIT_DESTROYED  = true,
        UNIT_DISSIPATES = true,
        PARTY_KILL      = true,
        SPELL_INSTAKILL = true,
    }

    local spellIDs = {
        [325733] = true,
        [325889] = true,
        [325748] = true,
        [325891] = true,
        [325727] = true
    }

    local flights = {}
    local pending = {}
    local swarms = {}

    -- Flow:  Cast -> In Flight -> Application -> Ticks -> Removal -> In Flight -> Application -> Ticks -> Removal -> ...
    -- If the swarm target dies, it will jump again.
    local insert, remove = table.insert, table.remove

    function Hekili:EmbedAdaptiveSwarm( s )
        s:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
            if not state.covenant.necrolord and not state.talent.adaptive_swarm.enabled then return end

            if sourceGUID == state.GUID and spellIDs[ spellID ] then
                -- On cast, we need to show we have a cast-in-flight.
                if casts[ subtype ] then
                    local dot

                    if bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 then
                        dot = "adaptive_swarm_damage"
                    else
                        dot = "adaptive_swarm_heal"
                    end

                    insert( flights, { destGUID, 3, GetTime() + 5, dot } )

                -- On application, we need to store the GUID of the unit so we can get the stacks and expiration time.
                elseif applications[ subtype ] and #flights > 0 then
                    local n, flight

                    for i, v in ipairs( flights ) do
                        if v[1] == destGUID then
                            n = i
                            flight = v
                            break
                        end
                        if not flight and v[1] == "unknown" then
                            n = i
                            flight = v
                        end
                    end

                    if flight then
                        local swarm = swarms[ destGUID ]
                        local now = GetTime()

                        if swarm and swarm.expiration > now then
                            swarm.stacks = swarm.stacks + flight[2]
                            swarm.dot = bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 and "adaptive_swarm_damage" or "adaptive_swarm_heal"
                            swarm.expiration = now + class.auras[ swarm.dot ].duration
                        else
                            swarms[ destGUID ] = {}
                            swarms[ destGUID ].stacks = flight[2]
                            swarms[ destGUID ].dot = bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 and "adaptive_swarm_damage" or "adaptive_swarm_heal"
                            swarms[ destGUID ].expiration = now + class.auras[ swarms[ destGUID ].dot ].duration
                        end
                        remove( flights, n )
                    else
                        swarms[ destGUID ] = {}
                        swarms[ destGUID ].stacks = 3 -- We'll assume it's fresh.
                        swarms[ destGUID ].dot = bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 and "adaptive_swarm_damage" or "adaptive_swarm_heal"
                        swarms[ destGUID ].expiration = GetTime() + class.auras[ swarms[ destGUID ].dot ].duration
                    end

                elseif removals[ subtype ] then
                    -- If we have a swarm for this, remove it.
                    local swarm = swarms[ destGUID ]

                    if swarm then
                        swarms[ destGUID ] = nil

                        if swarm.stacks > 1 then
                            local dot

                            if bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 then
                                dot = "adaptive_swarm_heal"
                            else
                                dot = "adaptive_swarm_damage"
                            end

                            insert( flights, { "unknown", swarm.stacks - 1, GetTime() + 5, dot } )

                        end
                    end
                end

            elseif swarms[ destGUID ] and deaths[ subtype ] then
                -- If we have a swarm for this, remove it.
                local swarm = swarms[ destGUID ]

                if swarm then
                    swarms[ destGUID ] = nil

                    if swarm.stacks > 1 then
                        if bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 then
                            dot = "adaptive_swarm_heal"
                        else
                            dot = "adaptive_swarm_damage"
                        end

                        insert( flights, { "unknown", swarm.stacks - 1, GetTime() + 5, dot } )

                    end
                end
            end
        end )

        function s.GetActiveSwarms()
            return swarms
        end

        function s.GetPendingSwarms()
            return pending
        end

        function s.GetInFlightSwarms()
            return flights
        end

        local flySwarm, landSwarm

        landSwarm = setfenv( function( aura )
            if aura.key == "adaptive_swarm_heal_in_flight" then
                applyBuff( "adaptive_swarm_heal", 12, min( 5, buff.adaptive_swarm_heal.stack + aura.count ) )
                buff.adaptive_swarm_heal.expires = query_time + 12
                state:QueueAuraEvent( "adaptive_swarm", flySwarm, buff.adaptive_swarm_heal.expires, "AURA_EXPIRATION", buff.adaptive_swarm_heal )
            else
                applyDebuff( "target", "adaptive_swarm_damage", 12, min( 5, debuff.adaptive_swarm_damage.stack + aura.count ) )
                debuff.adaptive_swarm_damage.expires = query_time + 12
                state:QueueAuraEvent( "adaptive_swarm", flySwarm, debuff.adaptive_swarm_damage.expires, "AURA_EXPIRATION", debuff.adaptive_swarm_damage )
            end
        end, state )

        flySwarm = setfenv( function( aura )
            if aura.key == "adaptive_swarm_heal" then
                applyBuff( "adaptive_swarm_heal_in_flight", 5, aura.count - 1 )
                state:QueueAuraEvent( "adaptive_swarm", landSwarm, query_time + 5, "AURA_EXPIRATION", buff.adaptive_swarm_heal_in_flight )
            else
                applyBuff( "adaptive_swarm_damage_in_flight", 5, aura.count - 1 )
                state:QueueAuraEvent( "adaptive_swarm", landSwarm, query_time + 5, "AURA_EXPIRATION", buff.adaptive_swarm_damage_in_flight )
            end
        end, state )

        s.SwarmOnReset = setfenv( function()
            for k, v in pairs( swarms ) do
                if v.expiration + 0.1 <= now then swarms[ k ] = nil end
            end

            for i = #flights, 1, -1 do
                if flights[i][3] + 0.1 <= now then remove( flights, i ) end
            end

            local target = UnitGUID( "target" )
            local tSwarm = swarms[ target ]

            if not UnitIsFriend( "target", "player" ) and tSwarm and tSwarm.expiration > now then
                applyDebuff( "target", "adaptive_swarm_damage", tSwarm.expiration - now, tSwarm.stacks )
                debuff.adaptive_swarm_damage.expires = tSwarm.expiration

                if tSwarm.stacks > 1 then
                    state:QueueAuraEvent( "adaptive_swarm", flySwarm, tSwarm.expiration, "AURA_EXPIRATION", debuff.adaptive_swarm_damage )
                end
            end

            if buff.adaptive_swarm_heal.up and buff.adaptive_swarm_heal.stack > 1 then
                state:QueueAuraEvent( "adaptive_swarm", flySwarm, buff.adaptive_swarm_heal.expires, "AURA_EXPIRATION", buff.adaptive_swarm_heal )
            else
                for k, v in pairs( swarms ) do
                    if k ~= target and v.dot == "adaptive_swarm_heal" then
                        applyBuff( "adaptive_swarm_heal", v.expiration - now, v.stacks )
                        buff.adaptive_swarm_heal.expires = v.expiration

                        if v.stacks > 1 then
                            state:QueueAuraEvent( "adaptive_swarm", flySwarm, buff.adaptive_swarm_heal.expires, "AURA_EXPIRATION", buff.adaptive_swarm_heal )
                        end
                    end
                end
            end

            local flight

            for i, v in ipairs( flights ) do
                if not flight or v[3] > now and v[3] > flight then flight = v end
            end

            if flight then
                local dot = flight[4] .. "_in_flight"
                applyBuff( dot, flight[3] - now, flight[2] )
                state:QueueAuraEvent( dot, landSwarm, flight[3], "AURA_EXPIRATION", buff[ dot ] )
            end

            Hekili:Debug( "Swarm Info:\n   Damage - %.2f remains, %d stacks.\n   Dmg In Flight - %.2f remains, %d stacks.\n   Heal - %.2f remains, %d stacks.\n   Heal In Flight - %.2f remains, %d stacks.\n   Count Dmg: %d, Count Heal: %d.", dot.adaptive_swarm_damage.remains, dot.adaptive_swarm_damage.stack, buff.adaptive_swarm_damage_in_flight.remains, buff.adaptive_swarm_damage_in_flight.stack, buff.adaptive_swarm_heal.remains, buff.adaptive_swarm_heal.stack, buff.adaptive_swarm_heal_in_flight.remains, buff.adaptive_swarm_heal_in_flight.stack, active_dot.adaptive_swarm_damage, active_dot.adaptive_swarm_heal )
        end, state )

        function Hekili:DumpSwarmInfo()
            local line = "Flights:"
            for k, v in pairs( flights ) do
                line = line .. " " .. k .. ":" .. table.concat( v, ":" )
            end
            print( line )

            line = "Pending:"
            for k, v in pairs( pending ) do
                line = line .. " " .. k .. ":" .. v
            end
            print( line )

            line = "Swarms:"
            for k, v in pairs( swarms ) do
                line = line .. " " .. k .. ":" .. v.stacks .. ":" .. v.expiration
            end
            print( line )
        end

        -- Druid - Necrolord - 325727 - adaptive_swarm       (Adaptive Swarm)
        spec:RegisterAbility( "adaptive_swarm", {
            id = function() return talent.adaptive_swarm.enabled and 391888 or 325727 end,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,
            texture = 3578197,

            -- For Feral, we want to put Adaptive Swarm on the highest health enemy.
            indicator = function ()
                if state.spec.feral and active_enemies > 1 and target.time_to_die < longest_ttd then return "cycle" end
            end,

            handler = function ()
                applyDebuff( "target", "adaptive_swarm_dot", nil, 3 )
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            copy = { "adaptive_swarm_damage", "adaptive_swarm_heal", 325727, 325733, 325748, 391888 },

            auras = {
                -- Suffering $w1 Shadow damage every $t1 sec and damage over time from $@auracaster increased by $w2%.
                -- https://wowhead.com/beta/spell=325733
                adaptive_swarm_dot = {
                    id = 325733,
                    duration = 12,
                    tick_time = 2,
                    type = "Magic",
                    max_stack = 5,
                    copy = { 391889, "adaptive_swarm_damage" }
                },
                -- Restoring $w1 health every $t1 sec and healing over time from $@auracaster increased by $w2%.
                -- https://wowhead.com/beta/spell=325748
                adaptive_swarm_hot = {
                    id = 325748,
                    duration = 12,
                    max_stack = 5,
                    dot = "buff",
                    copy = { 391891, "adaptive_swarm_heal" }
                },
                adaptive_swarm_damage_in_flight = {
                    duration = 5,
                    max_stack = 5
                },
                adaptive_swarm_heal_in_flight = {
                    duration = 5,
                    max_stack = 5,
                },
                adaptive_swarm = {
                    alias = { "adaptive_swarm_damage", "adaptive_swarm_heal" },
                    aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
                    aliasType = "any",
                },
                adaptive_swarm_in_flight = {
                    alias = { "adaptive_swarm_damage", "adaptive_swarm_heal" },
                    aliasMode = "shortest", -- use duration info from the first buff that's up, as they should all be equal.
                    aliasType = "any",
                },
            }
        } )
    end
end

Hekili:EmbedAdaptiveSwarm( spec )

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
    removeBuff( "celestial_guardian" )

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

    if form == "bear_form" and pvptalent.celestial_guardian.enabled then
        applyBuff( "celestial_guardian" )
    end
end )


spec:RegisterStateExpr( "lunar_eclipse", function ()
    return 0
end )

spec:RegisterStateExpr( "solar_eclipse", function ()
    return 0
end )


spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if not a or a.startsCombat then
        break_stealth()
    end
end )

--[[ This is intended to cause an AP reset on entering an encounter, but it's not working.
    spec:RegisterHook( "start_combat", function( action )
    if boss and astral_power.current > 50 then
        spend( astral_power.current - 50, "astral_power" )
    end
end ) ]]

spec:RegisterHook( "pregain", function( amt, resource, overcap, clean )
    if buff.memory_of_lucid_dreams.up then
        if amt > 0 and resource == "astral_power" then
            return amt * 2, resource, overcap, true
        end
    end
end )

spec:RegisterHook( "prespend", function( amt, resource, overcap, clean )
    if buff.memory_of_lucid_dreams.up then
        if amt < 0 and resource == "astral_power" then
            return amt * 2, resource, overcap, true
        end
    end
end )


local check_for_ap_overcap = setfenv( function( ability )
    local a = ability or this_action
    if not a then return true end

    a = action[ a ]
    if not a then return true end

    local cost = 0
    if a.spendType == "astral_power" then cost = a.cost end

    return astral_power.current - cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 2 ) or 0 ) < astral_power.max
end, state )

spec:RegisterStateExpr( "ap_check", function() return check_for_ap_overcap() end )

-- Simplify lookups for AP abilities consistent with SimC.
local ap_checks = {
    "force_of_nature", "full_moon", "half_moon", "incarnation", "moonfire", "new_moon", "starfall", "starfire", "starsurge", "sunfire", "wrath"
}

for i, lookup in ipairs( ap_checks ) do
    spec:RegisterStateExpr( lookup, function ()
        return action[ lookup ]
    end )
end


spec:RegisterStateExpr( "active_moon", function ()
    return "new_moon"
end )

local function IsActiveSpell( id )
    local slot = FindSpellBookSlotBySpellID( id )
    if not slot then return false end

    local _, _, spellID = GetSpellBookItemName( slot, "spell" )
    return id == spellID
end

state.IsActiveSpell = IsActiveSpell

local ExpireCelestialAlignment = setfenv( function()
    eclipse.state = "ANY_NEXT"
    eclipse.reset_stacks()
    if buff.eclipse_lunar.down then removeBuff( "starsurge_empowerment_lunar" ) end
    if buff.eclipse_solar.down then removeBuff( "starsurge_empowerment_solar" ) end
    if Hekili.ActiveDebug then Hekili:Debug( "Expire CA_Inc: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
end, state )

local ExpireEclipseLunar = setfenv( function()
    eclipse.state = "SOLAR_NEXT"
    eclipse.reset_stacks()
    eclipse.wrath_counter = 0
    removeBuff( "starsurge_empowerment_lunar" )
    if Hekili.ActiveDebug then Hekili:Debug( "Expire Lunar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
end, state )

local ExpireEclipseSolar = setfenv( function()
    eclipse.state = "LUNAR_NEXT"
    eclipse.reset_stacks()
    eclipse.starfire_counter = 0
    removeBuff( "starsurge_empowerment_solar" )
    if Hekili.ActiveDebug then Hekili:Debug( "Expire Solar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
end, state )

spec:RegisterStateTable( "eclipse", setmetatable( {
    -- ANY_NEXT, IN_SOLAR, IN_LUNAR, IN_BOTH, SOLAR_NEXT, LUNAR_NEXT
    state = "ANY_NEXT",
    wrath_counter = 2,
    starfire_counter = 2,

    reset = setfenv( function()
        eclipse.starfire_counter = GetSpellCount( 197628 ) or 0
        eclipse.wrath_counter    = GetSpellCount(   5176 ) or 0

        if buff.eclipse_solar.up and buff.eclipse_lunar.up then
            eclipse.state = "IN_BOTH"
            -- eclipse.reset_stacks()
        elseif buff.eclipse_solar.up then
            eclipse.state = "IN_SOLAR"
            -- eclipse.reset_stacks()
        elseif buff.eclipse_lunar.up then
            eclipse.state = "IN_LUNAR"
            -- eclipse.reset_stacks()
        elseif eclipse.starfire_counter > 0 and eclipse.wrath_counter > 0 then
            eclipse.state = "ANY_NEXT"
        elseif eclipse.starfire_counter == 0 and eclipse.wrath_counter > 0 then
            eclipse.state = "LUNAR_NEXT"
        elseif eclipse.starfire_counter > 0 and eclipse.wrath_counter == 0 then
            eclipse.state = "SOLAR_NEXT"
        elseif eclipse.starfire_count == 0 and eclipse.wrath_counter == 0 and buff.eclipse_lunar.down and buff.eclipse_solar.down then
            eclipse.state = "ANY_NEXT"
            eclipse.reset_stacks()
        end

        if buff.ca_inc.up then
            state:QueueAuraExpiration( "ca_inc", ExpireCelestialAlignment, buff.ca_inc.expires )
        elseif buff.eclipse_solar.up then
            state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
        elseif buff.eclipse_lunar.up then
            state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
        end

        buff.eclipse_solar.empowerTime = 0
        buff.eclipse_lunar.empowerTime = 0

        if buff.eclipse_solar.up and action.starsurge.lastCast > buff.eclipse_solar.applied then buff.eclipse_solar.empowerTime = action.starsurge.lastCast end
        if buff.eclipse_lunar.up and action.starsurge.lastCast > buff.eclipse_lunar.applied then buff.eclipse_lunar.empowerTime = action.starsurge.lastCast end
    end, state ),

    reset_stacks = setfenv( function()
        eclipse.wrath_counter = 2
        eclipse.starfire_counter = 2
    end, state ),

    trigger_both = setfenv( function( duration )
        eclipse.state = "IN_BOTH"
        eclipse.reset_stacks()

        if set_bonus.tier29_4pc > 0 then applyBuff( "touch_the_cosmos" ) end

        if legendary.balance_of_all_things.enabled then
            applyBuff( "balance_of_all_things_arcane", nil, 8, 8 )
            applyBuff( "balance_of_all_things_nature", nil, 8, 8 )
        end

        if talent.solstice.enabled then applyBuff( "solstice" ) end

        removeBuff( "starsurge_empowerment_lunar" )
        removeBuff( "starsurge_empowerment_solar" )

        applyBuff( "eclipse_lunar", ( duration or class.auras.eclipse_lunar.duration ) + buff.eclipse_lunar.remains )
        if set_bonus.tier29_2pc > 0 then applyBuff( "celestial_infusion" ) end
        applyBuff( "eclipse_solar", ( duration or class.auras.eclipse_solar.duration ) + buff.eclipse_solar.remains )

        if buff.parting_skies.up then
            removeBuff( "parting_skies" )
            applyDebuff( "target", "fury_of_elune", 8 )
            applyBuff( "fury_of_elune_ap", 8 )
        elseif talent.parting_skies.enabled then
            applyBuff( "parting_skies" )
        end

        state:QueueAuraExpiration( "ca_inc", ExpireCelestialAlignment, buff.ca_inc.expires )
        state:RemoveAuraExpiration( "eclipse_solar" )
        state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
        state:RemoveAuraExpiration( "eclipse_lunar" )
        state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
    end, state ),

    advance = setfenv( function()
        if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Pre): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end

        if not ( eclipse.state == "IN_SOLAR" or eclipse.state == "IN_LUNAR" or eclipse.state == "IN_BOTH" ) then
            if eclipse.starfire_counter == 0 and ( eclipse.state == "SOLAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                applyBuff( "eclipse_solar", class.auras.eclipse_solar.duration + buff.eclipse_solar.remains )
                if set_bonus.tier29_4pc > 0 then applyBuff( "touch_the_cosmos" ) end
                state:RemoveAuraExpiration( "eclipse_solar" )
                state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
                if talent.solstice.enabled then applyBuff( "solstice" ) end
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                eclipse.state = "IN_SOLAR"
                eclipse.starfire_counter = 0
                eclipse.wrath_counter = 2
                if buff.parting_skies.up then
                    removeBuff( "parting_skies" )
                    applyDebuff( "target", "fury_of_elune", 8 )
                    applyBuff( "fury_of_elune_ap", 8 )
                elseif talent.parting_skies.enabled then
                    applyBuff( "parting_skies" )
                end
                if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                return
            end

            if eclipse.wrath_counter == 0 and ( eclipse.state == "LUNAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                applyBuff( "eclipse_lunar", class.auras.eclipse_lunar.duration + buff.eclipse_lunar.remains )
                if set_bonus.tier29_4pc > 0 then applyBuff( "touch_the_cosmos" ) end
                state:RemoveAuraExpiration( "eclipse_lunar" )
                state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
                if talent.solstice.enabled then applyBuff( "solstice" ) end
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                eclipse.state = "IN_LUNAR"
                eclipse.wrath_counter = 0
                eclipse.starfire_counter = 2
                if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                if buff.parting_skies.up then
                    removeBuff( "parting_skies" )
                    applyDebuff( "target", "fury_of_elune", 8 )
                    applyBuff( "fury_of_elune_ap", 8 )
                elseif talent.parting_skies.enabled then
                    applyBuff( "parting_skies" )
                end
                return
            end
        end

        if eclipse.state == "IN_SOLAR" then eclipse.state = "LUNAR_NEXT" end
        if eclipse.state == "IN_LUNAR" then eclipse.state = "SOLAR_NEXT" end
        if eclipse.state == "IN_BOTH" then eclipse.state = "ANY_NEXT" end

        if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end

    end, state )
}, {
    __index = function( t, k )
        -- any_next
        if k == "any_next" then
            return eclipse.state == "ANY_NEXT"
        -- in_any
        elseif k == "in_any" then
            return eclipse.state == "IN_SOLAR" or eclipse.state == "IN_LUNAR" or eclipse.state == "IN_BOTH"
        -- in_solar
        elseif k == "in_solar" then
            return eclipse.state == "IN_SOLAR"
        -- in_lunar
        elseif k == "in_lunar" then
            return eclipse.state == "IN_LUNAR"
        -- in_both
        elseif k == "in_both" then
            return eclipse.state == "IN_BOTH"
        -- solar_next
        elseif k == "solar_next" then
            return eclipse.state == "SOLAR_NEXT"
        -- solar_in
        elseif k == "solar_in" then
            return eclipse.starfire_counter
        -- solar_in_2
        elseif k == "solar_in_2" then
            return eclipse.starfire_counter == 2
        -- solar_in_1
        elseif k == "solar_in_1" then
            return eclipse.starfire_counter == 1
        -- lunar_next
        elseif k == "lunar_next" then
            return eclipse.state == "LUNAR_NEXT"
        -- lunar_in
        elseif k == "lunar_in" then
            return eclipse.wrath_counter
        -- lunar_in_2
        elseif k == "lunar_in_2" then
            return eclipse.wrath_counter == 2
        -- lunar_in_1
        elseif k == "lunar_in_1" then
            return eclipse.wrath_counter == 1
        end
    end
} ) )

spec:RegisterStateTable( "druid", setmetatable( {},{
    __index = function( t, k )
        if k == "catweave_bear" then return false
        elseif k == "owlweave_bear" then return false
        elseif k == "primal_wrath" then return debuff.rip
        elseif k == "lunar_inspiration" then return debuff.moonfire_cat
        elseif k == "no_cds" then return not toggle.cooldowns
        elseif k == "delay_berserking" then return settings.delay_berserking
        elseif rawget( debuff, k ) ~= nil then return debuff[ k ] end
        return false
    end
} ) )

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

spec:RegisterHook( "reset_precast", function ()
    if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
    elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
    elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
    else active_moon = nil end

    -- UGLY
    if talent.incarnation.enabled then
        rawset( cooldown, "ca_inc", cooldown.incarnation )
        rawset( buff, "ca_inc", buff.incarnation )
    else
        rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
        rawset( buff, "ca_inc", buff.celestial_alignment )
    end

    if talent.fungal_growth.enabled and query_time - action.wild_mushroom.lastCast < 1 then
        if debuff.fungal_growth.up then debuff.fungal_growth.expires = action.wild_mushroom.lastCast + 7
        else applyDebuff( "target", "wild_growth", 7 ) end
    end

    if buff.warrior_of_elune.up then
        setCooldown( "warrior_of_elune", 3600 )
    end

    eclipse.reset()

    if buff.lycaras_fleeting_glimpse.up then
        state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
    end

    if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
        state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
    end
end )


spec:RegisterHook( "step", function()
    if Hekili.ActiveDebug then Hekili:Debug( "Eclipse State: %s, Wrath: %d, Starfire: %d; Lunar: %.2f, Solar: %.2f\n", eclipse.state or "NOT SET", eclipse.wrath_counter, eclipse.starfire_counter, buff.eclipse_lunar.remains, buff.eclipse_solar.remains ) end
end )


spec:RegisterHook( "spend", function( amt, resource )
    if legendary.primordial_arcanic_pulsar.enabled and resource == "astral_power" and amt > 0 then
        local v1 = ( buff.primordial_arcanic_pulsar.v1 or 0 ) + amt

        if v1 >= 300 then
            applyBuff( talent.incarnation.enabled and "incarnation" or "celestial_alignment", 9 )
            v1 = v1 - 300
        end

        if v1 > 0 then
            applyBuff( "primordial_arcanic_pulsar", nil, max( 1, floor( amt / 30 ) ) )
            buff.primordial_arcanic_pulsar.v1 = v1
        else
            removeBuff( "primordial_arcanic_pulsar" )
        end
    end
end )


-- Tier 29
spec:RegisterGear( "tier29", 200351, 200353, 200354, 200355, 200356 )
spec:RegisterSetBonuses( "tier29_2pc", 393632, "tier29_4pc", 393633 )
spec:RegisterAuras( {
    gathering_starstuff = {
        id = 394412,
        duration = 15,
        max_stack = 1,
    },
    touch_the_cosmos = {
        id = 394414,
        duration = 15,
        max_stack = 1,
    }
} )

-- Tier 30
spec:RegisterGear( "tier30", 202518, 202516, 202515, 202514, 202513 )
-- 2 pieces (Balance) : Sunfire radius increased by 3 yds. Sunfire, Moonfire and Shooting Stars damage increased by 20%.
-- 4 pieces (Balance) : Shooting Stars has a 20% chance to instead call down a Crashing Star, dealing (76.5% of Spell power) Astral damage to the target and generating 5 Astral Power.


-- Legion Sets (for now).
spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )
    spec:RegisterAura( "solar_solstice", {
        id = 252767,
        duration = 6,
        max_stack = 1,
     } )

spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 )
spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

spec:RegisterGear( "impeccable_fel_essence", 137039 )
spec:RegisterGear( "oneths_intuition", 137092 )
    spec:RegisterAuras( {
        oneths_intuition = {
            id = 209406,
            duration = 3600,
            max_stacks = 1,
        },
        oneths_overconfidence = {
            id = 209407,
            duration = 3600,
            max_stacks = 1,
        },
    } )

spec:RegisterGear( "radiant_moonlight", 151800 )
spec:RegisterGear( "the_emerald_dreamcatcher", 137062 )
    spec:RegisterAura( "the_emerald_dreamcatcher", {
        id = 224706,
        duration = 5,
        max_stack = 2,
    } )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Generates ${$m1/10} Astral Power.
    astral_communion = {
        id = 202359,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "astral",

        spend = -60,
        spendType = "astral_power",

        talent = "astral_communion",
        startsCombat = false,

        handler = function ()
        end,
    },

    barkskin = {
        id = 22812,
        cast = 0,
        cooldown = function () return 60 * ( 1 - 0.15 * talent.survival_of_the_fittest.rank ) * ( 1 + ( conduit.tough_as_bark.mod * 0.01 ) ) end,
        gcd = "off",
        school = "nature",

        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        usable = function ()
            if not tanking then return false, "player is not tanking right now"
            elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
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

    -- Talent: Celestial bodies align, maintaining both Eclipses and granting $s1% haste for $d.
    celestial_alignment = {
        id = function() return talent.orbital_strike.enabled and 383410 or 194223 end,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 - 60 * talent.orbital_strike.rank end,
        gcd = "off",
        school = "astral",

        talent = "celestial_alignment",
        notalent = "incarnation",
        startsCombat = false,

        toggle = "cooldowns",


        handler = function ()
            applyBuff( "celestial_alignment" )
            stat.haste = stat.haste + 0.1

            eclipse.trigger_both( 20 )

            if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
        end,

        copy = { 194223, 383410, "ca_inc" }
    },

    -- Talent / Covenant (Night_Fae): Call upon the Night Fae for an eruption of energy, channeling a rapid flurry of $s2 Druid spells and abilities over $d.    You will cast $?a24858|a197625[Starsurge, Starfall,]?a768[Ferocious Bite, Shred, Tiger's Fury,]?a5487[Mangle, Ironfur,][Wild Growth, Swiftmend,] Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    convoke_the_spirits = {
        id = function() return talent.convoke_the_spirits.enabled and 391528 or 323764 end,
        cast = function() return 4 * ( legendary.celestial_spirits.enabled and 0.75 or 1 ) * ( talent.ashamanes_guidance.enabled and 0.75 or 1 ) end,
        channeled = true,
        cooldown = function() return 120 * ( legendary.celestial_spirits.enabled and 0.5 or 1 ) * ( talent.ashamanes_guidance.enabled and 0.5 or 1 ) end,
        gcd = "spell",
        school = "nature",

        talent = function()
            if covenant.night_fae then return end
            return "convoke_the_spirits"
        end,
        startsCombat = true,

        toggle = "cooldowns",

        disabled = function ()
            return not talent.convoke_the_spirits.enabled and covenant.night_fae and not IsSpellKnownOrOverridesKnown( 323764 ), "you have not finished your night_fae covenant intro"
        end,

        finish = function ()
            -- Can we safely assume anything is going to happen?
            if state.spec.feral then
                applyBuff( "tigers_fury" )
                if target.distance < 8 then
                    gain( 5, "combo_points" )
                end
            elseif state.spec.guardian then
            elseif state.spec.balance then
            end
        end,

        copy = { 391528, 323764 }
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

    -- Roots the target in place for $d. Damage may cancel the effect.$?s33891[    |C0033AA11Tree of Life: Instant cast.|R][]
    entangling_roots = {
        id = 339,
        cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 136100,

        handler = function ()
            applyDebuff( "target", "entangling_roots" )
        end,
    },

    -- Talent: Summons a stand of $s1 Treants for $248280d which immediately taunt and attack enemies in the targeted area.    |cFFFFFFFFGenerates ${$m5/10} Astral Power.|r
    force_of_nature = {
        id = 205636,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "nature",

        talent = "force_of_nature",
        startsCombat = true,

        toggle = "cooldowns",
        ap_check = function() return check_for_ap_overcap( "force_of_nature" ) end,

        handler = function ()
            summonPet( "treants", 10 )
        end,
    },


    full_moon = {
        id = 274283,
        known = 274281,
        flash = 274281,
        cast = 3,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",

        spend = -48,
        spendType = "astral_power",

        texture = 1392542,
        startsCombat = true,

        talent = "new_moon",
        bind = "half_moon",

        ap_check = function() return check_for_ap_overcap( "full_moon" ) end,

        usable = function () return active_moon == "full_moon" end,
        handler = function ()
            spendCharges( "new_moon", 1 )
            spendCharges( "half_moon", 1 )

            -- Radiant Moonlight, NYI.
            active_moon = "new_moon"
        end,
    },


    fury_of_elune = {
        id = 202770,
        cast = 0,
        cooldown = function() return talent.radiant_moonlight.enabled and 40 or 60 end,
        gcd = "spell",

        -- toggle = "cooldowns",

        startsCombat = true,
        texture = 132123,

        handler = function ()
            if not buff.moonkin_form.up then unshift() end
            applyDebuff( "target", "fury_of_elune_ap" )
        end,
    },

    -- Taunts the target to attack you.
    growl = {
        id = 6795,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyBuff( "growl" )
        end,
    },


    half_moon = {
        id = 274282,
        known = 274281,
        flash = 274281,
        cast = 2,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",

        spend = -24,
        spendType = "astral_power",

        texture = 1392543,
        startsCombat = true,

        talent = "new_moon",
        bind = { "new_moon", "full_moon" },

        ap_check = function() return check_for_ap_overcap( "half_moon" ) end,

        usable = function () return active_moon == "half_moon" end,
        handler = function ()
            spendCharges( "new_moon", 1 )
            spendCharges( "full_moon", 1 )

            active_moon = "full_moon"
        end,
    },

    -- Talent: Abilities not associated with your specialization are substantially empowered for $d.$?!s137013[    |cFFFFFFFFBalance:|r Magical damage increased by $s1%.][]$?!s137011[    |cFFFFFFFFFeral:|r Physical damage increased by $s4%.][]$?!s137010[    |cFFFFFFFFGuardian:|r Bear Form gives an additional $s7% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has ${$s9+1} charges.][]$?!s137012[    |cFFFFFFFFRestoration:|r Healing increased by $s10%, and mana costs reduced by $s12%.][]
    heart_of_the_wild = {
        id = 319454,
        cast = 0,
        cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
        gcd = "spell",

        toggle = "cooldowns",
        talent = "heart_of_the_wild",

        startsCombat = false,
        texture = 135879,

        handler = function ()
            applyBuff( "heart_of_the_wild" )

            if talent.feral_affinity.enabled then
                shift( "cat_form" )
            elseif talent.guardian_affinity.enabled then
                shift( "bear_form" )
            elseif talent.restoration_affinity.enabled then
                unshift()
            end
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
            applyDebuff( "target", "incapacitating_roar" )
        end,
    },


    incarnation = {
        id = function() return talent.orbital_strike.enabled and 390414 or 102560 end,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 - 60 * talent.orbital_strike.rank end,
        gcd = "off",

        spend = -40,
        spendType = "astral_power",

        toggle = "cooldowns",

        startsCombat = false,
        texture = 571586,

        talent = "incarnation",

        handler = function ()
            shift( "moonkin_form" )

            applyBuff( "incarnation" )
            stat.crit = stat.crit + 0.10
            stat.haste = stat.haste + 0.10

            eclipse.trigger_both( 20 )

            if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
        end,

        copy = { "incarnation_chosen_of_elune", "Incarnation", 102560, 390414 },
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
        texture = 136048,

        toggle = "cooldowns",

        usable = function () return group end,
        handler = function ()
            active_dot.innervate = 1
        end,
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

        handler = function ()
            applyBuff( "ironfur" )
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

        usable = function () return combo_points.current > 0, "requires combo points" end,
        handler = function ()
            applyDebuff( "target", "maim" )
            spend( combo_points.current, "combo_points" )
        end,
    },

    -- Mangle the target for $s2 Physical damage.$?a231064[ Deals $s3% additional damage against bleeding targets.][]    |cFFFFFFFFGenerates ${$m4/10} Rage.|r
    mangle = {
        id = 33917,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        school = "physical",

        spend = -10,
        spendType = "rage",

        startsCombat = true,
        texture = 132135,

        form = "bear_form",

        handler = function ()
        end,
    },

    -- Infuse a friendly target with the power of the wild, increasing their Versatility by $s1% for 60 minutes.    If target is in your party or raid, all party and raid members will be affected.
    mark_of_the_wild = {
        id = 1126,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",
        essential = true,

        spend = 0.2,
        spendType = "mana",

        startsCombat = false,
        nobuff = "mark_of_the_wild",

        handler = function ()
            applyBuff( "mark_of_the_wild" )
        end,
    },

    -- Talent: Roots the target and all enemies within $A1 yards in place for $d. Damage may interrupt the effect. Usable in all shapeshift forms.
    mass_entanglement = {
        id = 102359,
        cast = 0,
        cooldown = function () return 30 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
        gcd = "spell",
        school = "nature",

        talent = "mass_entanglement",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mass_entanglement" )
            active_dot.mass_entanglement = max( active_dot.mass_entanglement, active_enemies )
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

    -- A quick beam of lunar light burns the enemy for $164812s1 Arcane damage and then an additional $164812o2 Arcane damage over $164812d$?s238049[, and causes enemies to deal $238049s1% less damage to you.][.]$?a372567[    Hits a second target within $279620s1 yds of the first.][]$?s197911[    |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r][]
    moonfire = {
        id = 8921,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = -6,
        spendType = "astral_power",

        startsCombat = true,

        cycle = "moonfire",

        ap_check = function() return check_for_ap_overcap( "moonfire" ) end,

        handler = function ()
            if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
            applyDebuff( "target", "moonfire" )

            if talent.twin_moons.enabled and active_enemies > 1 then
                active_dot.moonfire = min( active_enemies, active_dot.moonfire + 1 )
            end
        end,
    },

    -- Talent: Shapeshift into $?s114301[Astral Form][Moonkin Form], increasing the damage of your spells by $s9% and your armor by $m3%, and granting protection from Polymorph effects.$?a231042[    While in this form, single-target attacks against you have a $h% chance to make your next Starfire instant.][]    The act of shapeshifting frees you from movement impairing effects.
    moonkin_form = {
        id = function() return state.spec.restoration and 197625 or 24858 end,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        talent = "moonkin_form",
        startsCombat = false,

        noform = "moonkin_form",
        essential = true,

        handler = function ()
            shift( "moonkin_form" )
        end,

        copy = { 24858, 197625 }
    },

    -- Talent: For $d, $?s137012[all single-target healing also damages a nearby enemy target for $s3% of the healing done][all single-target damage also heals a nearby friendly target for $s3% of the damage done].
    natures_vigil = {
        id = 124974,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "nature",

        talent = "natures_vigil",
        startsCombat = false,

        toggle = "defensives",
        usable = function()
            return health.pct <= ( settings.vigil_damage or 50 ), strformat( "health %d%% must be under %d%%", health.pct, settings.vigil_damage or 50 )
        end,

        handler = function ()
            applyBuff( "natures_vigil" )
        end,
    },

    -- Talent: Deals $m1 Astral damage to the target and empowers New Moon to become Half Moon.     |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r
    new_moon = {
        id = 274281,
        cast = 1,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "totem",
        school = "astral",

        spend = -12,
        spendType = "astral_power",

        talent = "new_moon",
        startsCombat = true,
        bind = { "half_moon", "full_moon" },

        ap_check = function() return check_for_ap_overcap( "new_moon" ) end,

        usable = function () return active_moon == "new_moon" end,
        handler = function ()
            spendCharges( "half_moon", 1 )
            spendCharges( "full_moon", 1 )

            active_moon = "half_moon"
        end,
    },

    -- Shift into Cat Form and enter stealth.
    prowl = {
        id = 5215,
        cast = 0,
        cooldown = 6,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        usable = function ()
            if time > 0 and ( not boss or not buff.shadowmeld.up ) then return false, "cannot stealth in combat"
            elseif buff.prowl.up then return false, "player is already prowling" end
            return true
        end,

        handler = function ()
            shift( "cat_form" )
            applyBuff( "prowl" )
        end,
    },

    -- Heals a friendly target for $s1 and another ${$o2*$<mult>} over $d.$?s231032[ Initial heal has a $231032s1% increased chance for a critical effect if the target is already affected by Regrowth.][]$?s24858|s197625[ Usable while in Moonkin Form.][]$?s33891[    |C0033AA11Tree of Life: Instant cast.|R][]
    regrowth = {
        id = 8936,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.17,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            if buff.moonkin_form.down then unshift() end
            applyBuff( "regrowth" )
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

        spend = 0.12,
        spendType = "mana",

        talent = "rejuvenation",
        startsCombat = false,

        handler = function ()
            if buff.moonkin_form.down then unshift() end
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

        spend = 0.065,
        spendType = "mana",

        talent = "remove_corruption",
        startsCombat = false,

        usable = function() return debuff.dispellable_curse.up or debuff.dispellable_poison.up, "requires curse/poison" end,

        handler = function ()
            removeDebuff( "target", "dispellable_curse" )
            removeDebuff( "target", "dispellable_poison" )
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

        handler = function ()
            gain( health.max * 0.3, "health" )
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

    -- Talent: Summons a beam of solar light over an enemy target's location, interrupting the target and silencing all enemies within the beam.  Lasts $d.
    solar_beam = {
        id = 78675,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "nature",

        spend = 0.168,
        spendType = "mana",

        talent = "solar_beam",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            -- trigger 97547, 97547, 97547
            applyBuff( "solar_beam" )
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

        usable = function () return buff.dispellable_enrage.up end,
        handler = function ()
            if buff.moonkin_form.down then unshift() end
            removeBuff( "dispellable_enrage" )
        end,
    },


    stag_form = {
        id = 210053,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 1394966,

        noform = "travel_form",
        handler = function ()
            shift( "stag_form" )
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

    -- Talent: Calls down waves of falling stars upon enemies within $50286A1 yds, dealing $<damage> Astral damage over $191034d. Multiple uses of this ability may overlap.$?s327541[    Extends the duration of active Moonfires and Sunfires by $327541s1 sec.][]
    starfall = {
        id = 191034,
        cast = 0,
        cooldown = function () return talent.stellar_drift.enabled and 12 or 0 end,
        gcd = "spell",
        school = "astral",

        spend = function ()
            if buff.oneths_perception.up or buff.starweavers_warp.up then return 0 end
            return ( 50 - ( buff.incarnation.up and talent.elunes_guidance.enabled and 10 or 0 ) - ( buff.touch_the_cosmos.up and 5 or 0 ) ) * ( 1 - 0.05 * buff.rattled_stars.stack ) * ( 1 - 0.1 * buff.timeworn_dreambinder.stack )
        end,
        spendType = "astral_power",

        startsCombat = true,
        texture = 236168,

        ap_check = function() return check_for_ap_overcap( "starfall" ) end,

        handler = function ()
            if buff.starweavers_warp.up then removeBuff( "starweavers_warp" )
            else removeBuff( "touch_the_cosmos" ) end

            if talent.rattle_the_stars.enabled then addStack( "rattled_stars" ) end
            if talent.starlord.enabled then
                if buff.starlord.stack < 3 then stat.haste = stat.haste + 0.04 end
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "gathering_starstuff" )
            end

            applyBuff( "starfall" )
            if level > 53 then
                if debuff.moonfire.up then debuff.moonfire.expires = debuff.moonfire.expires + 4 end
                if debuff.sunfire.up then debuff.sunfire.expires = debuff.sunfire.expires + 4 end
            end

            removeBuff( "oneths_perception" )

            if legendary.timeworn_dreambinder.enabled then
                addStack( "timeworn_dreambinder", nil, 1 )
            end
        end,
    },

    -- Talent: Call down a burst of energy, causing $s1 Arcane damage to the target, and ${$m1*$m3/100} Arcane damage to all other enemies within $A1 yards.    |cFFFFFFFFGenerates ${$m2/10} Astral Power.|r
    starfire = {
        id = function () return state.spec.balance and 194153 or 197628 end,
        known = function () return state.spec.balance and IsPlayerSpell( 194153 ) or IsPlayerSpell( 197628 ) end,
        cast = function ()
            if buff.warrior_of_elune.up or buff.owlkin_frenzy.up then return 0 end
            return haste * ( buff.eclipse_lunar and ( level > 46 and 0.8 or 0.92 ) or 1 ) * 2.25
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return ( talent.soul_of_the_forest.enabled and buff.eclipse_lunar.up and 1.3 or 1 ) * ( buff.warrior_of_elune.up and 1.4 or 1 ) * ( talent.wild_surges.enabled and -12 or -10 ) end,
        spendType = "astral_power",

        startsCombat = true,
        texture = 135753,

        ap_check = function() return check_for_ap_overcap( "starfire" ) end,

        talent = "starfire",

        handler = function ()
            if not buff.moonkin_form.up then unshift() end

            removeBuff( "gathering_starstuff" )

            if eclipse.state == "ANY_NEXT" or eclipse.state == "SOLAR_NEXT" then
                eclipse.starfire_counter = eclipse.starfire_counter - 1
                eclipse.advance()
            end

            if level > 53 then
                if debuff.moonfire.up then debuff.moonfire.expires = debuff.moonfire.expires + 4 end
                if debuff.sunfire.up then debuff.sunfire.expires = debuff.sunfire.expires + 4 end
            end

            if buff.warrior_of_elune.up then
                removeStack( "warrior_of_elune" )
                if buff.warrior_of_elune.down then
                    setCooldown( "warrior_of_elune", 45 )
                end
            elseif buff.owlkin_frenzy.up then
                removeStack( "owlkin_frenzy" )
            end

            if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
        end,

        copy = { 194153, 197628 }
    },


    starsurge = {
        id = function() return state.spec.balance and 78674 or 197626 end,
        cast = 0,
        cooldown = function() return state.spec.balance and 0 or 10 end,
        gcd = "spell",

        spend = function ()
            if not state.spec.balance then return 0.006 end
            if buff.oneths_clear_vision.up or buff.starweavers_weft.up then return 0 end
            return ( 40 - ( buff.incarnation.up and talent.elunes_guidance.enabled and 8 or 0 ) - ( buff.touch_the_cosmos.up and 5 or 0 ) ) * ( 1 - 0.05 * buff.rattled_stars.stack ) * ( 1 - 0.1 * buff.timeworn_dreambinder.stack )
        end,
        spendType = function ()
            if not state.spec.balance then return "mana" end
            return "astral_power"
        end,

        startsCombat = true,
        texture = 135730,
        talent = "starsurge",

        ap_check = function() return check_for_ap_overcap( "starsurge" ) end,

        handler = function ()
            if buff.bear_form.up or buff.cat_form.up then unshift() end

            if not state.spec.balance then return end

            if buff.starweavers_weft.up then removeBuff( "starweavers_weft" )
            else removeBuff( "touch_the_cosmos" ) end

            if talent.rattle_the_stars.enabled then addStack( "rattled_stars" ) end
            if talent.starlord.enabled then
                if buff.starlord.stack < 3 then stat.haste = stat.haste + 0.04 end
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "gathering_starstuff" )
            end

            removeBuff( "oneths_clear_vision" )
            removeBuff( "sunblaze" )

            if buff.eclipse_solar.up then buff.eclipse_solar.empowerTime = query_time; applyBuff( "starsurge_empowerment_solar" ) end
            if buff.eclipse_lunar.up then buff.eclipse_lunar.empowerTime = query_time; applyBuff( "starsurge_empowerment_lunar" ) end

            if pvptalent.moonkin_aura.enabled then
                addStack( "moonkin_aura", nil, 1 )
            end

            if azerite.arcanic_pulsar.enabled then
                addStack( "arcanic_pulsar" )
                if buff.arcanic_pulsar.stack == 9 then
                    removeBuff( "arcanic_pulsar" )
                    applyBuff( "ca_inc", 6 )
                    eclipse.trigger_both( 6 )
                end
            end

            if legendary.timeworn_dreambinder.enabled then
                addStack( "timeworn_dreambinder", nil, 1 )
            end
        end,

        copy = { 78674, 197626 },

        auras = {
            starsurge_empowerment_lunar = {
                duration = 3600,
                max_stack = 30,
                generate = function( t )
                    local last = action.starsurge.lastCast

                    t.name = "Starsurge Empowerment (Lunar)"

                    if eclipse.in_any then
                        t.applied = last
                        t.duration = buff.eclipse_lunar.expires - last
                        t.expires = t.applied + t.duration
                        t.count = 1
                        t.caster = "player"
                        return
                    end

                    t.applied = 0
                    t.duration = 0
                    t.expires = 0
                    t.count = 0
                    t.caster = "nobody"
                end,
                copy = "starsurge_lunar"
            },

            starsurge_empowerment_solar = {
                duration = 3600,
                max_stack = 30,
                generate = function( t )
                    local last = action.starsurge.lastCast

                    t.name = "Starsurge Empowerment (Solar)"

                    if eclipse.in_any then
                        t.applied = last
                        t.duration = buff.eclipse_solar.expires - last
                        t.expires = t.applied + t.duration
                        t.count = 1
                        t.caster = "player"
                        return
                    end

                    t.applied = 0
                    t.duration = 0
                    t.expires = 0
                    t.count = 0
                    t.caster = "nobody"
                end,
                copy = "starsurge_solar"
            }
        }
    },

    -- Talent: Burns the target for $s1 Astral damage, and then an additional $o2 damage over $d.    |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r
    stellar_flare = {
        id = 202347,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "astral",

        spend = -12,
        spendType = "astral_power",

        talent = "stellar_flare",
        startsCombat = true,

        ap_check = function() return check_for_ap_overcap( "stellar_flare" ) end,

        handler = function ()
            applyDebuff( "target", "stellar_flare" )
        end,
    },

    -- Talent: A quick beam of solar light burns the enemy for $164815s1 Nature damage and then an additional $164815o2 Nature damage over $164815d$?s231050[ to the primary target and all enemies within $164815A2 yards][].$?s137013[    |cFFFFFFFFGenerates ${$m3/10} Astral Power.|r][]
    sunfire = {
        id = 93402,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = -6,
        spendType = "astral_power",

        startsCombat = true,
        texture = 236216,

        cycle = "sunfire",

        ap_check = function()
            return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
        end,

        readyTime = function()
            return mana[ "time_to_" .. ( 0.12 * mana.max ) ]
        end,

        handler = function ()
            if buff.bear_form.up or buff.cat_form.up then unshift() end
            spend( 0.12 * mana.max, "mana" ) -- I want to see AP in mouseovers.
            applyDebuff( "target", "sunfire" )
            if talent.improved_sunfire.enabled then active_dot.sunfire = active_enemies end
        end,
    },

    -- Talent: Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for $s1.$?a383192[    Swiftmend heals the target for $383193o1 over $383193d.][]
    swiftmend = {
        id = 18562,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "nature",

        spend = 0.08,
        spendType = "mana",

        talent = "swiftmend",
        startsCombat = false,


        handler = function ()
            if buff.moonkin_form.down then unshift() end
            gain( health.max * 0.1, "health" )
        end,
    },

    -- Sprout thorns for $d on the friendly target. When victim to melee attacks, thorns deals $305496s1 Nature damage back to the attacker.    Attackers also have their movement speed reduced by $232559s1% for $232559d.
    thorns = {
        id = 305497,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "nature",

        spend = 0.12,
        spendType = "mana",

        pvptalent = function ()
            if essence.conflict_and_strife.enabled then return end
            return "thorns"
        end,
        startsCombat = false,
        texture = 136104,

        handler = function ()
            applyBuff( "thorns" )
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
            shift( "cat_form" )
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

        noform = "travel_form",
        handler = function ()
            shift( "travel_form" )
        end,
    },


    treant_form = {
        id = 114282,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132145,

        handler = function ()
            shift( "treant_form" )
        end,
    },

    -- Talent: Blasts targets within $61391a1 yards in front of you with a violent Typhoon, knocking them back and dazing them for $61391d. Usable in all shapeshift forms.
    typhoon = {
        id = 132469,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.incessant_tempest.rank end,
        gcd = "spell",
        school = "nature",

        talent = "typhoon",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "typhoon" )
            if target.distance < 15 then setDistance( target.distance + 5 ) end
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
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "ursols_vortex" )
        end,
    },

    -- Talent: Your next $n Starfires are instant cast and generate $s2% increased Astral Power.
    warrior_of_elune = {
        id = 202425,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "arcane",

        talent = "warrior_of_elune",
        startsCombat = false,

        handler = function ()
            applyBuff( "warrior_of_elune", nil, 3 )
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
        startsCombat = false,

        usable = function () return target.exists and target.distance > 7, "target must be 8+ yards away" end,

        handler = function ()
            if buff.bear_form.up then target.distance = 5; applyDebuff( "target", "immobilized" )
            elseif buff.cat_form.up then target.distance = 5; applyDebuff( "target", "dazed" )
            elseif buff.moonkin_form.up then setDistance( target.distance + 10 ) end
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

        spend = 0.22,
        spendType = "mana",

        talent = "wild_growth",
        startsCombat = false,

        handler = function ()
            unshift()
            applyBuff( "wild_growth" )
        end,
    },

    -- Talent: Grow a magical mushroom at the target enemy's location. After $d, the mushroom detonates, dealing $88751s1 Nature damage and generating up to $88751s2 Astral Power based on targets hit.
    wild_mushroom = {
        id = 88747,
        cast = 0,
        charges = 3,
        cooldown = 30,
        recharge = 30,
        gcd = "spell",
        school = "nature",

        talent = "wild_mushroom",
        startsCombat = false,

        handler = function ()
            summonTotem( "wild_mushroom" )
            if talent.fungal_growth.enabled then
                if debuff.fungal_growth.up then debuff.fungal_growth.expires = query_time + 7
                else applyDebuff( "target", "fungal_growth", 7 ) end
            end
        end,
    },

    -- Hurl a ball of energy at the target, dealing $s1 Nature damage.$?a197911[    |cFFFFFFFFGenerates ${$m2/10} Astral Power.|r][]
    wrath = {
        id = 190984,
        known = function () return state.spec.balance and IsPlayerSpell( 190984 ) or IsPlayerSpell( 5176 ) end,
        cast = function () return haste * ( buff.eclipse_solar.up and ( level > 46 and 0.8 or 0.92 ) or 1 ) * 1.5 end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return ( talent.soul_of_the_forest.enabled and buff.eclipse_solar.up and 1.3 or 1 ) * ( talent.wild_surges.enabled and -12 or 10 ) end,
        spendType = "astral_power",

        startsCombat = false,
        texture = 535045,

        ap_check = function () return check_for_ap_overcap( "solar_wrath" ) end,

        velocity = 20,

        impact = function ()
            if not state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                eclipse.wrath_counter = eclipse.wrath_counter - 1
                eclipse.advance()
            end
        end,

        handler = function ()
            if not buff.moonkin_form.up then unshift() end

            removeBuff( "gathering_starstuff" )

            if state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                eclipse.wrath_counter = eclipse.wrath_counter - 1
                eclipse.advance()
            end

            removeBuff( "dawning_sun" )
            if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
        end,

        copy = { "solar_wrath", 5176 }
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

    potion = "spectral_intellect",

    package = "Balance",
} )


spec:RegisterSetting( "vigil_damage", 50, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.natures_vigil.id ) ),
    desc = strformat( "If set below 100%%, |W%s|w may only be recommended if your health has dropped below the specified percentage.\n\n"
        .. "By default, |W%s|w also requires the |cFFFFD100Defensives|r toggle to be active.", spec.abilities.natures_vigil.name, spec.abilities.natures_vigil.name ),
    type = "range",
    min = 1,
    max = 100,
    step = 1,
    width = "full"
} )

--[[ spec:RegisterSetting( "starlord_cancel", false, {
    name = "Cancel |T462651:0|t Starlord",
    desc = "If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\n" ..
        "You will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat.",
    icon = 462651,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "toggle",
    width = "full"
} ) ]]

--[[ Starlord Cancel Override
class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
    if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
    return args.buff_name ~= nil, "no buff name detected"
end, state ) ]]


--[[ spec:RegisterSetting( "delay_berserking", false, {
    name = strformat( "Delay %s", Hekili:GetSpellLinkWithTexture( class.specs[ 0 ].auras.berserking.id ) ),
    desc = strformat( "If checked, the default priority will attempt to adjust the timing of %s to be consistent with simmed %s usage.",
        Hekili:GetSpellLinkWithTexture( class.specs[ 0 ].auras.berserking.id ), Hekili:GetSpellLinkWithTexture( class.specs[ 0 ].auras.power_infusion.id ) ),
    type = "toggle",
    width = "full",
} ) ]]


spec:RegisterPack( "Balance", 20230508, [[Hekili:TZvBVnoUr4FlbhoVwoRDKKTtYDW2f9o0p0fT3xY1VAzfz5e1il5Qxs2ay4F7D4lsIKAOEXjz3fOf3HnjMKZmC4WzEMHKET16)C9DBDZ8x)h2M2tnNBE7elRPwtxFx2Rh8xF3bxVNCFa(Li39W)(BUHUrE0p)1Wy3TKHNgNNq(OhZYoK(RxD19S(monyV3KhcYEm)(jbXxXh647c2)7xTF7KhZ2h(x2fe6VKpGjzFnB9D3NheM93JwFpQCzpF9DU5zpgNS(ocHaUgSDRpR7(PERVJ09XMZhBE7VEAZPn)RdeQKEAZUK49N2qgZPnb7HPvwq0dWhK5MKMN8G)Pn5PWeDYPVC6lL04Akn(NbrXjq7msj3dBfUq6OL5elrgkmIzJTUHoI)62)DEA2PnXro5P(ozjbrp5d)9ZUjbU3hkkh2JTNZhZw)TN2KccEO)yqWFGmcy4az2XMk7CddpT5fqPFAZFgN7b)i7rO9FpoDFC6K13fgKMLsx0935MhMb)6Fqnc8JiSD76FJPitcoKfehT(U)2x99YZi81)z)Kxb6fS3NtvqjsMVbWe39z3GqQGdlqESHMgh6M4CVV7(1zW6iHlvnfduqKRqpMQihGqK5dQdWwKYZfN28G32j7D)6PndoTziisEHbhs9N4g9QtK)xbTXXJvFAyEeWF2NBuX7xsCZEKOjI8D82U(U5eEptlVt83L4N(iPfkBlLf7tBgjlr3NVB3eo3DOCFs(bHjDMFirJSd(hFvbyUwb4cGNUH(rztKiWeENFZcfy1euxEUwrEIHXK6NvnWclvYVfMd)i9aiDomZY0jPLwJRGDe0U7W8HeK64g7t4Xn9MhxFAZvWoakNE0f0hN2CzP6jYnlhwQCk8NuQGQ6sCY9bzo3N47(KFsvhav224Sj7JJJi6IjzbEprDpmIAMrvHYdfMEEprNBq723CAZ4cDpTZGPFkqeFqvd2E0)hAAMPOE4GBAAWZ(oUPhikJB1AaqPONRtqK3Ke)9UbrWgUvlbgAYm4lDAefdlGoS5kRP7JttPMb7cE4XmNYHdMkwZRu037NK6NqMZer5xAYwCBsEWwgNsl2h(bjHtnL24EiM(tqaTmvKWIUW9JAjkZL8w1x7fGaArznzlg7tNKzdZa3TV64fhhUn(LiMuouyoOshgzKMMiDzk1kyGSYIyEC(6NAAxe2cMCPHXGp)kDdrbQ6ZxrbA3zfODnfOfQcSjz0(hb9InvVifLImgqjSpvjqL1uXEv4255Ghccv7P(4kLch3Fyj9sYJCy)UdjAnlMn3Nb3XPLA0IUmw4pj)3Dhs89I3FVBvS)Irt8)b(aCaum7vMis6L9Ujp5eVZbcH78sq42wIJ3UB9QqCE(H(GNt3qh3WGhI2t(mXaDv9emtCtaDpzU69yCQFerK8HiCcE(jwbIoSe9)kAsHbbODX(wAOfMBFUuruhouaLPfsHipPypGauPLU9vxjBNRwM9MTfb5L4C)JWlf(sEpLUW5UB320urcKxLdei0oL4excm8nvTv4wzY28e6QpnkClIMAW12fnBurZUbrZ(8en9bBFBaCP71j(lqq4lUHNb(tkeFPRvvSVdjgCe8DtiaoDYID2g4tX(u6(1GoNVM2DaGwcSt(q8laIjiHJaVGmAZL((eWarnQH8o9E1l0Vagjr0l8(Gi)P51e)3IipM2DjCSu8M2fHUF3MqQUiBAb5hUvJ(7OudSXY9lQqhHy4ZlC3Rclq)eNKOHz7GdMtNBKEoQFbtmO7YQ2ldrp8IJ2gqhfpYSUaZk5(9MSxhRyJoPW9EX6nlUKU(CwMc3shNosUGk3wwuzJRsZ3FpHhbrz(rPbzVojXn6jXoWfI09GraigSMz7ZkfJAQyuds1iziGSujuLUUkVqIWaoMFso1ACD1IM1vJQ5gHAvsmLZiLLHcDYJvugEkIKoOLxdBMDe7zBPSvLt4x0(FMGSu0lALAu7LHuqLI85Xc03b9DfHqq41C6VDGMcBFldPwgn0njjioPC)SkcD1ujB3Bwd7cMk6FaMz(jmDlAoxitrHHuyHIdbOLLpMSxkBt8zvXZHvNi1LvsaNYKFqfWleS)opzSUHixgPOv0lGfGz4jDHkD93DgjdrMOxLqXU8OhaQ8qs8lebsmfIQo9IBuq0dozaGBsKfLmnIvPIuGhgCr8ax3ueUdYo7zhs97SyG63NN(ysmPuYIkfXwAjpZ(RCUTjb1Usk2LN8A12kS0sFlsXSYLOMSJakiB602MJAdWqCcb7RjqWOtg9rv0OAMjjWKDwV47(SFsQd4d6qznnklMRBsyCYwPGnLJK2cViJlyfpc3xSLENX1fd)DzfyOA2jMiNOPvszLQp6)p4MEcUbh(IL(ua7)CzUz16cF0EX73NhXJnARgVdNzmm4M6um0c7ZSlRkUo1pqQZdaqF56V3PTXDaxcRxcBea4aph)Kpfnv6HayMKsNJ6J02FfQLGcnY)Ls)d26Jw2FMy)T3z3JUH7QMmVVbxfCPgN45tcsWQskLx6JvDUESaNG4USS1hrsbF(kQX8anNxMCDxcIynGdJY(Aj4NStBucZPTQp7Io3u5Bj75YEmjNvyNY)cP6oDOgZIrqKpy2sTNSiRRGfivGr6K0enfl)DipfBBALvGqk6lXq9IIiksz0kA3qXT6qXHQdpRdrO41ubxW1vPkSc78XlnAx16Aa7(V5)236uPjlIELM2zu0jRZSQtZ)Ev1j6z60WDhGonoKeShGtst5oXdsGXZ5qEyk4yJQPorpP258G94ZDDiAX9OOh5CpKNRn1Wzwibno87BPjsfSGENQmHij)2wyIUPDja744n0UxamQNlDas0RYtjkdQEPw9mAxaXRtqPAuLl1JhZW3uTHSNLbXd8NvGeQmZ(EW(k4aTdwtTchI8UEvI4ezDZLHrPgm8brLgTZcCqknunfCMOIObROdTBai6Abb8FtUNxXUpinCRam6YYspZ0qWVlpxJYn6RBPIhSfFKuuM8ue9AriTbePB0RrH8IBDHqtQ6DPK46PLM8QAOwd9hOWCHRFewIQ1Q2WBHzTKsY7Ag4ND5ZAi18(f)TH8FpZIpju3ky3Fwi30GyYvNeSESL3Sicc5weDvYVXIAmNRLRDpW43)fqDhcDFo02poPq1P73cm9AeL3ZY9QTml69K1FM8DVmlVNoq)ExGC7wUXQO1XPXt5u7uv84pLVcvfh6PfTFMtUwm)Q048WI7Pg41ha3lDLF1GSKDDDv4Ab2jnmMskva9uQnIivZkij(m0a9OBRdNDOWn7EuXnk1qY7SAKujVZLOnQ1lrUWD3xph2568oRp6zZhTg36LM1mBoGgZe6d1WlX37rsp42LJPNAMHoP1YS5JmBAlrBrsagDbwBJ8aOlPx)Dmm4tLU8LyfkCQU4EDUqHqtKnGKbv8sAUMM6j5ymtxF3FsEhhb7peNKXF9kFI)Yq(ePYm)NCqwjV5KyIg3nplEVl9XGaRerpqFmm)JGiOjYlu53buJ(j0M)e2lwaOywSM2kmkG(m06RgL09gC6QCv)vOSMhcqhPT0f9xHYOVFGwOB8bF2TbeSlday)F66Fw4bmCzZY8LnX4rypAHrdPMJipxHvdTVzS9iMZ5QhOGHXOzMfZZRV6hqzRuZAzQUKXV8LQxA)YLnD3QF11mllnuw92SxJYiDGt5tFbz3v5TVUF7VMIBRIuYkfl2gUq1Q6an8OHQuQWRouptvEodNNc3NzfEGCtNvPPgFrVjAwZxrP5H4fcgX4qP5os0A3KyekJ1NpuYxs4B1UlSrLrTMLKw9eTDPfVpFOKx3(B3y)(TZ2ULOfcPVnyyDesJ5yEmwD94HsNP5pBBmadQ9kmqOxoTywF287QEYV28b8H6356gI97wCpqXc(7QEjrRfjrJBujmWkugfFCxjSYvst13g(fwRgX1Oqkkh0NuXUjx)ivYzxlqnBCkxrefQQ5cK8PMJOwG3TFB7M2Y2oStXEf)NJST)zRBle(w65vqp1j6P9efW3JDk21qg92Sm0qo1YkQqwDvDSg5R5NNlw1kfGQCRTwbDLfQjvRWaDzMxJ8)Y7U)JtF5Vtn7iKBEXXsDAd97caOzYtcmM8nXqr(LPtkrPE5YReFvGN(cApuEpG49QimWNjPPUu8OB(m90HwErMwiRdUODd4JhLoU)oidYLsIlf3EP9O64c7c5QvJiofTmpBsk)CX40Z8mgz8HLUB3wiqFoy3sCeSdAaK4Q3mJTfzSnoJraBPJX01pcjhQEWYhpw8jvVrodYgHF60ME)nArjZbww9DAH8Ns(6Sq8tkfncXxWRA3GUjNFM)nXWY5s8qSCjeklcuJYf7rf8b9qR1rwMrlHIxu6dxGvVbAlByWUdAClb87u6kl9dxa8iNgDPokO1O4DS2eIYB1xIceLjYrDVAPT5XJONE9XJKYGoqQmMlSK0MSV(dORtIo6gm8DGttnnezv5dF)Z03iFXwwQFJsIkVr)ILwGtAnLJ54XHAg2slbXuPPPgdKReBFMrsZFfcB2H5QDJZv7Q5QA9F0Zw7VPthXpu6ROaWj4pvacG0ya7S(bpp(qK1qQ3y(wosACGWUlNuazrcQu)zw3j7UfvASn8ToS0mIJ5c)7Wi4yoOELKo3rwGRlOQNUNMAFskvvo4NVmMy0Db4TLxEFunFd1mYoNvFAEfi6KDuP5U9Sy(GlK3zGj3RSmX3zm)slZrTdp0WO2IRue1ZFjEm(nt3y1TxI3sp073oaNelgAznMpPrFmkJLt7q8HOymOKv1EwS1urSaZs7Rvher3ufKTSajOZYf4ZYrsZsyDMyoG8sznoEeLQdXj7Lw28W6ONo(IzCoHEKRlMv3Kbj1KgvnQJxW(SxJt9WfBE3OF1l0upClIruD)DcOblfobYHHGTbniJ4v3)sXlwqnDBjK5lololVYY5C9hxAD2kEWWe239nN2MdgEbwk4hpw8XkLFdYrv3BeDH9aeNE3m4cDVi0AZePluw)Mj3IXB76mGF9p6hXNzoOHnHRexDAYAAvJlJIEQqMlZ4IG0LsHDh6oEuP0vdk7z1fHBXuuosZKVeTpYnErN7BKDE)pAWivfHADY6NT2CZAUSRFxwvj5I5MyZmWAAX0IeivQnDJw0ngwz1SAt5I77w)MQw1MQL31S(ri7Vf7pvU1T9vcFx38zDttX9Kg0QP4f8OQWnfpgq0WzQFiAcqfhGHyAqfF2sueykzwv2BrfdER6ZNP9d8aLIfdru4tZ6EQtvr)AoxffQ3uwqVdKVxEJ7UD8TDvEUvrEAiBR0S(LSLvhZ2A(7w2wCnALDmL9T8oLwTCo4vwvs1fdhHzYEhANBxBIqD(1wvM69kjas1nKgDNsbO2O0NaaI9H6taIBG0ffXI5q0anMoRM3ix9fFUqCwwhZE58vvihGezHyB2J0lkFIvqAIx0rgv4qVPqGYztuXfmtC8KN4KDGwHsD5UixiC60S3HyL31J4YVYkkGurNJIvt1vbzJ3jWp13QY1ZAFZudA)9sjuBdv9G62yCGHDE8VrGQQBME3aiXO2hxUG4UZ7Pt5oLYvzMzQN(pR7QVZiSpTyhCX9M)SWO0DD30ZeMY5ZHpkKkkS5TNIcLm)yMHcFhZpIf3qdCgeqkAQmkQqxvUu5RaXOHwxAo56rAVtmJqdsByiqXIOGseLomKNpXiZjZmUetgng1uK)H89ZJMAyu6Lq1H8GwFVlexmY4Bv9kxR6GyL7dSaaKYe5OMFZH1F5kJVXqLRwMnHLaddmIUutduFPlTWayO8znMCk9lmhpYxlb20NvY6)7d]] )