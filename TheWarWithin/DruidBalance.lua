-- DruidBalance.lua
-- January 2025

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR

local GetSpellBookItemName = function(index, bookType)
    local spellBank = (bookType == BOOKTYPE_SPELL) and Enum.SpellBookSpellBank.Player or Enum.SpellBookSpellBank.Pet;
    return C_SpellBook.GetSpellBookItemName(index, spellBank);
end

local GetSpellCount = C_Spell.GetSpellCastCount

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
        value = 2.5
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
    aessinas_renewal            = {  82232, 474678, 1 }, -- When a hit deals more than 12% of your maximum health, instantly heal for 10% of your health. This effect cannot occur more than once every 30 seconds.
    aggravate_wounds            = {  94616, 441829, 1 }, -- Every attack with an Energy cost that you cast extends the duration of your Dreadful Wounds by 0.6 sec, up to 8 additional sec.
    astral_influence            = {  82210, 197524, 1 }, -- Increases the range of all of your spells by 5 yards.
    bestial_strength            = {  94611, 441841, 1 }, -- Maul and Raze damage increased by 20%.
    bond_with_nature            = {  94625, 439929, 1 }, -- Healing you receive is increased by 4%.
    bursting_growth             = {  94630, 440120, 1 }, -- When Bloodseeker Vines expire or you use Ferocious Bite on their target they explode in thorns, dealing 19,410 physical damage to nearby enemies. Damage reduced above 5 targets. When Symbiotic Blooms expire or you cast Rejuvenation on their target flowers grow around their target, healing them and up to 3 nearby allies for 3,956.
    circle_of_the_heavens       = { 104078, 474541, 1 }, -- Magical damage dealt by your spells increased by 5%.
    circle_of_the_wild          = { 104078, 474530, 1 }, -- Physical damage dealt by your abilities increased by 5%.
    claw_rampage                = {  94613, 441835, 1 }, -- During Berserk, Shred, Swipe, and Thrash have a 25% chance to make your next Ferocious Bite become Ravage.
    cyclone                     = {  82229,  33786, 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 5 sec. Only one target can be affected by your Cyclone at a time.
    dreadful_wound              = {  94620, 441809, 1 }, -- Ravage also inflicts a Bleed that causes 7,375 damage over 6 sec and saps its victims' strength, reducing damage they deal to you by 10%. Dreadful Wound is not affected by Circle of Life and Death. 
    empowered_shapeshifting     = {  94612, 441689, 1 }, -- Frenzied Regeneration can be cast in Cat Form for 40 Energy. Bear Form reduces magic damage you take by 4%. Shred and Swipe damage increased by 6%. Mangle damage increased by 15%.
    entangling_vortex           = {  94622, 439895, 1 }, -- Enemies pulled into Ursol's Vortex are rooted in place for 3 sec. Damage may cancel the effect.
    feline_swiftness            = {  82236, 131768, 1 }, -- Increases your movement speed by 15%.
    flower_walk                 = {  94622, 439901, 1 }, -- During Barkskin your movement speed is increased by 10% and every second flowers grow beneath your feet that heal up to 3 nearby injured allies for 3,732.
    fluid_form                  = {  82246, 449193, 1 }, -- Shred, Rake, and Skull Bash can be used in any form and shift you into Cat Form, if necessary. Mangle can be used in any form and shifts you into Bear Form. Wrath and Starfire shift you into Moonkin Form, if known.
    forestwalk                  = {  82243, 400129, 1 }, -- Casting Regrowth increases your movement speed and healing received by 8% for 6 sec.
    fount_of_strength           = {  94618, 441675, 1 }, -- Your maximum Energy and Rage are increased by 20. Frenzied Regeneration also increases your maximum health by 10%.
    frenzied_regeneration       = {  82220,  22842, 1 }, -- Heals you for 32% health over 3 sec, and increases healing received by 20%.
    gale_winds                  = { 104079, 400142, 1 }, -- Increases Typhoon's radius by 20% and its range by 5 yds.
    grievous_wounds             = {  82239, 474526, 1 }, -- Rake, Rip, and Thrash damage increased by 10%.
    harmonious_constitution     = {  94625, 440116, 1 }, -- Your Regrowth's healing to yourself is increased by 35%.
    heart_of_the_wild           = {  82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Feral: Gain 1 Combo Point every 2 sec while in Cat Form and Physical damage increased by 20%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges. Restoration: Healing increased by 30%, and mana costs reduced by 50%.
    hibernate                   = {  82211,   2637, 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    hunt_beneath_the_open_skies = {  94629, 439868, 1 }, -- Damage and healing while in Cat Form increased by 3%. Moonfire and Sunfire damage increased by 10%.
    implant                     = {  94628, 440118, 1 }, -- Your Swiftmend causes a Symbiotic Bloom to grow on the target for 6 sec.
    improved_barkskin           = { 104085, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_stampeding_roar    = {  82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    incapacitating_roar         = {  82237,     99, 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 10 yards for 3 sec. Damage may cancel the effect.
    incessant_tempest           = { 104079, 400140, 1 }, -- Reduces the cooldown of Typhoon by 5 sec.
    innervate                   = { 100175,  29166, 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 8 sec.
    instincts_of_the_claw       = { 104081, 449184, 1 }, -- Ferocious Bite and Maul damage increased by 8%.
    ironfur                     = {  82227, 192081, 1 }, -- Increases armor by 10,486 for 7 sec.
    killer_instinct             = {  82225, 108299, 2 }, -- Physical damage and Armor increased by 6%.
    killing_strikes             = {  94619, 441824, 1 }, -- Ravage increases your Agility by 8% and the armor granted by Ironfur by 20% for 8 sec. Your first Mangle after entering combat makes your next Maul become Ravage.
    lethal_preservation         = {  94624, 455461, 1 }, -- When you remove an effect with Soothe or Remove Corruption, gain a combo point and heal for 4% of your maximum health. If you are at full health an injured party or raid member will be healed instead.
    light_of_the_sun            = { 104083, 202918, 1 }, -- Reduces the remaining cooldown on Solar Beam by 15 sec when it interrupts the primary target.
    lingering_healing           = {  82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec. Regrowth's duration is increased by 3 sec when cast on yourself.
    lore_of_the_grove           = { 104080, 449185, 1 }, -- Moonfire and Sunfire damage increased by 10%.
    lycaras_meditation          = {  92229, 474728, 1 }, -- You retain Lycara's Teachings' bonus from your most recent shapeshift form for 5 sec after shifting out of it.
    lycaras_teachings           = {  82233, 378988, 2 }, -- You gain 3% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                        = {  82221,  22570, 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 3,105 damage, 1 sec 2 points: 6,211 damage, 2 sec 3 points: 9,316 damage, 3 sec 4 points: 12,422 damage, 4 sec 5 points: 15,528 damage, 5 sec
    mass_entanglement           = {  82207, 102359, 1 }, -- Roots the target and all enemies within 12 yards in place for 10 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                  = { 100177, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 60,657 damage for 8 sec.
    mighty_bash                 = {  82237,   5211, 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    moonkin_form                = {  82208,  24858, 1 }, -- Shapeshift into Moonkin Form, increasing the damage of your spells by 10% and your armor by 125%, and granting protection from Polymorph effects. While in this form, single-target attacks against you have a 15% chance to make your next Starfire instant. The act of shapeshifting frees you from movement impairing effects.
    natural_recovery            = {  82206, 377796, 1 }, -- Healing you receive is increased by 4%.
    natures_vigil               = {  82244, 124974, 1 }, -- For 15 sec, all single-target damage also heals a nearby friendly target for 20% of the damage done.
    nurturing_instinct          = {  82214,  33873, 2 }, -- Magical damage and healing increased by 6%.
    oakskin                     = { 100176, 449191, 1 }, -- Survival Instincts and Barkskin reduce damage taken by an additional 10%.
    packs_endurance             = {  94615, 441844, 1 }, -- Stampeding Roar's duration is increased by 25%.
    perfectlyhoned_instincts    = { 104082, 1213597, 1 }, -- Well-Honed Instincts can trigger up to once every 60 sec.
    primal_fury                 = {  82224, 159286, 1 }, -- While in Cat Form, when you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect. Mangle critical strike damage increased by 20%.
    rake                        = {  82199,   1822, 1 }, -- Rake the target for 6,277 Bleed damage and an additional 35,373 Bleed damage over 15 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    ravage                      = {  94609, 441583, 1 }, -- Your auto-attacks have a chance to make your next Ferocious Bite become Ravage. Ravage Finishing move that slashes through your target in a wide arc, dealing Physical damage per combo point to your target and consuming up to 25 additional Energy to increase that damage by up to 100%. Hits all other enemies in front of you for reduced damage per combo point spent. 1 point: 9,204 damage, 3,551 in an arc 2 points: 18,409 damage, 7,103 in an arc 3 points: 27,614 damage, 10,655 in an arc 4 points: 36,819 damage, 14,207 in an arc 5 points: 46,023 damage, 17,759 in an arc
    rejuvenation                = {  82217,    774, 1 }, -- Heals the target for 41,953 over 12 sec.
    remove_corruption           = {  82241,   2782, 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    renewal                     = {  82232, 108238, 1 }, -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    resilient_flourishing       = {  94631, 439880, 1 }, -- Bloodseeker Vines and Symbiotic Blooms last 2 additional sec. When a target afflicted by Bloodseeker Vines dies, the vines jump to a valid nearby target for their remaining duration.
    rip                         = {  82222,   1079, 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 27,904 over 8 sec 2 points: 41,856 over 12 sec 3 points: 55,808 over 16 sec 4 points: 69,760 over 20 sec 5 points: 83,712 over 24 sec
    root_network                = {  94631, 439882, 1 }, -- Each active Bloodseeker Vine increases the damage your abilities deal by 2%. Each active Symbiotic Bloom increases the healing of your spells by 2%.
    ruthless_aggression         = {  94619, 441814, 1 }, -- Ravage increases your auto-attack speed by 35% for 6 sec.
    soothe                      = {  82229,   2908, 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar             = {  82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 15 yards by 60% for 8 sec.
    starfire                    = {  82201, 194153, 1 }, -- Call down a burst of energy, causing 25,745 Arcane damage to the target, and 8,283 Arcane damage to all other enemies within 10 yards. Deals reduced damage beyond 8 targets. Generates 10 Astral Power.
    starlight_conduit           = { 100223, 451211, 1 }, -- Wrath, Starsurge, and Starfire damage increased by 5%. 
    starsurge                   = {  82202,  78674, 1 }, -- Launch a surge of stellar energies at the target, dealing 81,158 Astral damage.
    strategic_infusion          = {  94623, 439890, 1 }, -- Attacking from Prowl increases the chance for Shred, Rake, and Swipe to critically strike by 8% for 6 sec. Casting Regrowth increases the chance for your periodic heals to critically heal by 8% for 10 sec.
    strike_for_the_heart        = {  94614, 441845, 1 }, -- Shred, Swipe, and Mangle's critical strike chance and critical strike damage are increased by 15%. 
    sunfire                     = {  93714,  93402, 1 }, -- A quick beam of solar light burns the enemy for 5,628 Nature damage and then an additional 65,372 Nature damage over 18 sec to the primary target and all enemies within 8 yards. Generates 6 Astral Power.
    symbiotic_relationship      = { 100173, 474750, 1 }, -- Form a bond with an ally. Your self-healing also heals your bonded ally for 10% of the amount healed. Your healing to your bonded ally also heals you for 8% of the amount healed.
    tear_down_the_mighty        = {  94614, 441846, 1 }, -- The cooldown of Pulverize is reduced by 10 sec.
    thick_hide                  = {  82228,  16931, 1 }, -- Reduces all damage taken by 4%.
    thrash                      = {  82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    thriving_growth             = {  94626, 439528, 1 }, -- Rip and Rake damage has a chance to cause Bloodseeker Vines to grow on the victim, dealing 23,583 Bleed damage over 6 sec. Wild Growth, Regrowth, and Efflorescence healing has a chance to cause Symbiotic Blooms to grow on the target, healing for 23,740 over 6 sec. Multiple instances of these can overlap.
    tiger_dash                  = {  82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    twin_sprouts                = {  94628, 440117, 1 }, -- When Bloodseeker Vines or Symbiotic Blooms grow, they have a 20% chance to cause another growth of the same type to immediately grow on a valid nearby target.
    typhoon                     = {  82209, 132469, 1 }, -- Blasts targets within 20 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by 50% for 6 sec. Usable in all shapeshift forms.
    ursine_vigor                = { 100174, 377842, 1 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 15%.
    ursocs_spirit               = {  82219, 449182, 1 }, -- Stamina increased by 4%. Stamina in Bear Form is increased by an additional 5%.
    ursols_vortex               = {  82207, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart               = {  82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    vigorous_creepers           = {  94627, 440119, 1 }, -- Bloodseeker Vines increase the damage your abilities deal to affected enemies by 5%. Symbiotic Blooms increase the healing your spells do to affected targets by 20%.
    wellhoned_instincts         = {  82235, 377847, 1 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 90 sec.
    wild_charge                 = {  82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                 = {  82205,  48438, 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 35,657 over 7 sec. Healing starts high and declines over the duration.
    wildpower_surge             = {  94612, 441691, 1 }, -- Mangle grants Feline Potential. When you have 6 stacks, the next time you transform into Cat Form, gain 5 combo points and your next Ferocious Bite or Rip deals 225% increased damage for its full duration.
    wildshape_mastery           = {  94610, 441678, 1 }, -- Ironfur and Frenzied Regeneration persist in Cat Form. When transforming from Bear to Cat Form, you retain 80% of your Bear Form armor and health for 6 sec. For 6 sec after entering Bear Form, you heal for 10% of damage taken over 8 sec. 
    wildstalkers_power          = {  94621, 439926, 1 }, -- Rip and Ferocious Bite damage increased by 5%. Rejuvenation healing increased by 10%.
    
    -- Balance
    aetherial_kindling          = {  88209, 327541, 1 }, -- Casting Starfall extends the duration of active Moonfires and Sunfires by 3.0 sec, up to 28 sec.
    astral_communion            = {  88235, 450598, 1 }, -- Increases maximum Astral Power by 20. Entering Eclipse reduces the Astral Power cost of your next Starsurge or Starfall by 15. 
    astral_smolder              = {  88204, 394058, 1 }, -- Your Starfire and Wrath damage has a 35% chance to cause the target to languish for an additional 60% of your spell's damage over 6 sec.
    astronomical_impact         = {  88232, 468960, 1 }, -- The critical strike damage of your Astral spells is increased by 20%.
    balance_of_all_things       = {  88214, 394048, 2 }, -- Entering Eclipse increases your critical strike chance with Arcane or Nature spells by 20%, decreasing by 2% every 1 sec.
    celestial_alignment         = {  88215, 194223, 1 }, -- Celestial bodies align, maintaining both Eclipses and granting 10% haste for 12 sec.
    convoke_the_spirits         = {  88206, 391528, 1 }, -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of 16 Druid spells and abilities over 4 sec. You will cast Starsurge, Starfall, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    cosmic_rapidity             = {  88227, 400059, 2 }, -- Your Moonfire, Sunfire, and Stellar Flare deal damage 20% more frequently.
    crashing_star               = { 103847, 468978, 1 }, -- Shooting Stars has a 15% chance to instead call down a Crashing Star, dealing 31,134 Astral damage to the target and generating 4 Astral Power.
    denizen_of_the_dream        = {  88234, 394065, 1 }, -- Your Moonfire and Sunfire have a chance to summon a Faerie Dragon to assist you in battle for 30 sec.
    eclipse                     = {  88223,  79577, 1 }, -- Casting 2 Starfires empowers Wrath for 15 sec. Casting 2 Wraths empowers Starfire for 15 sec.  Eclipse (Solar) Nature spells deal 15% additional damage and Wrath damage is increased by 60%.  Eclipse (Lunar) Arcane spells deal 15% additional damage and the damage Starfire deals to nearby enemies is increased by 60%.
    elunes_guidance             = {  88228, 393991, 1 }, --  Incarnation: Chosen of Elune Reduces the Astral Power cost of Starsurge by 10, and the Astral Power cost of Starfall by 12.  Convoke the Spirits Cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    force_of_nature             = {  88210, 205636, 1 }, -- Summons a stand of 3 Treants for 10 sec which immediately taunt and attack enemies in the targeted area. Generates 20 Astral Power.
    fury_of_elune               = {  88224, 202770, 1 }, -- Calls down a beam of pure celestial energy that follows the enemy, dealing up to 83,967 Astral damage over 8 sec within its area. Damage reduced on secondary targets. Generates 40 Astral Power over its duration.
    hail_of_stars               = { 103846, 469004, 1 }, -- Casting a free Starsurge or Starfall grants Solstice for 3 sec.
    harmony_of_the_heavens      = {  88218, 450558, 1 }, -- Starsurge or Starfall increase your current Eclipse's Arcane or Nature damage bonus by an additional 2%, up to 6%.
    incarnation_chosen_of_elune = {  88206, 102560, 1 }, -- An improved Moonkin Form that grants both Eclipses, any learned Celestial Alignment bonuses, and 10% critical strike chance. Lasts 16 sec. You may shapeshift in and out of this improved Moonkin Form for its duration.
    natures_balance             = {  88226, 202430, 1 }, -- While in combat you generate 2 Astral Power every 3 sec. While out of combat your Astral Power rebalances to 50 instead of depleting to empty.
    natures_grace               = {  88208, 450347, 1 }, -- When Eclipse ends or when you enter combat, enter a Dreamstate, reducing the cast time of your next 2 Starfires or Wraths by 40%.
    new_moon                    = {  88224, 274281, 1 }, -- Deals 73,961 Astral damage to the target and empowers New Moon to become Half Moon. Generates 10 Astral Power.
    orbit_breaker               = {  88199, 383197, 1 }, -- Every 30th Shooting Star calls down a Full Moon at 60% effectiveness upon its target.
    orbital_strike              = {  88221, 390378, 1 }, -- Incarnation: Chosen of Elune blasts all enemies in a targeted area for 57,645 Astral damage and applies Stellar Flare to them. Reduces the cooldown of Incarnation: Chosen of Elune by 60 sec.
    power_of_goldrinn           = {  88200, 394046, 1 }, -- Starsurge has a chance to summon the Spirit of Goldrinn, which immediately deals 16,858 Astral damage to the target.
    radiant_moonlight           = {  88213, 394121, 1 }, -- New Moon, Half Moon, and Full Moon deal 25% increased damage. Full Moon becomes Full Moon once more before resetting to New Moon. Fury of Elune deals 50% increased damage and its cooldown is reduced by 15 sec.
    rattle_the_stars            = {  88236, 393954, 1 }, -- Starsurge and Starfall deal 8% increased damage and their cost is reduced by 10%.
    shooting_stars              = {  88225, 202342, 1 }, -- Moonfire and Sunfire damage over time has a chance to call down a falling star, dealing 10,376 Astral damage and generating 2 Astral Power.
    solar_beam                  = {  88231,  78675, 1 }, -- Summons a beam of solar light over an enemy target's location, interrupting the target and silencing all enemies within the beam. Lasts 8 sec.
    solstice                    = {  88203, 343647, 1 }, -- During the first 6 sec of every Eclipse, Shooting Stars fall 200% more often.
    soul_of_the_forest          = {  88212, 114107, 1 }, -- Solar Eclipse increases Wrath's Astral Power generation by 60% and Lunar Eclipse increases Starfire's damage and Astral Power generation by 20% for each target hit beyond the first, up to 60%.
    starlord                    = {  88207, 202345, 2 }, -- Starsurge and Starfall grant you 2% Haste for 15 sec. Stacks up to 3 times. Gaining a stack does not refresh the duration.
    starweaver                  = {  88236, 393940, 1 }, -- Starsurge has a 20% chance to make Starfall free. Starfall has a 40% chance to make Starsurge free.
    stellar_amplification       = {  88229, 450212, 1 }, -- Starsurge increases the damage the target takes from your periodic effects and Shooting Stars by 20% for 5 sec. Reapplying this effect extends its duration, up to 20 sec.
    stellar_flare               = {  91048, 202347, 1 }, -- Burns the target for 5,139 Astral damage, and then an additional 64,532 damage over 24 sec. If dispelled, causes 60,528 damage to the dispeller and blasts them upwards. Generates 12 Astral Power.
    sundered_firmament          = {  88199, 394094, 1 }, -- Every other Eclipse creates a Fury of Elune at 25% effectiveness that follows your current target for 8 sec.
    sunseeker_mushroom          = {  88202, 468936, 1 }, -- Sunfire damage has a chance to grow a magical mushroom at a target's location. After 1 sec, the mushroom detonates, dealing 63,714 Nature damage and then an additional 35,939 Nature damage over 10 sec. Affected targets are slowed by 50%. Generates up to 20 Astral Power based on targets hit. 
    touch_the_cosmos            = {  88222, 450356, 1 }, -- Casting Wrath in an Eclipse has a 15% chance to make your next Starsurge or Starfall free. Casting Starfire in an Eclipse has a 22% chance to make your next Starsurge or Starfall free.
    twin_moons                  = {  88201, 279620, 1 }, -- Moonfire deals 10% increased damage and also hits another nearby enemy within 15 yds of the target.
    umbral_embrace              = {  88216, 393760, 1 }, -- Wrath and Starfire have a 20% chance to cause your next Wrath or Starfire cast during an Eclipse to become Astral and deal 75% additional damage.
    umbral_inspiration          = {  88217, 450418, 1 }, -- Consuming Umbral Embrace increases the damage of your Moonfire, Sunfire, Stellar Flare, Shooting Stars, and Starfall by 30% for 6 sec.
    umbral_intensity            = {  88219, 383195, 1 }, -- Solar Eclipse increases the damage of Wrath by an additional 20%. Lunar Eclipse increases Starfire's damage by 15% and the damage it deals to nearby enemies by an additional 30%.
    waning_twilight             = {  88220, 393956, 1 }, -- When you have 3 periodic effects from your spells on a target, your damage and healing on them are increased by 6%.
    warrior_of_elune            = {  88210, 202425, 1 }, -- Your next 3 Starfires are instant cast and generate 30% increased Astral Power.
    whirling_stars              = {  88221, 468743, 1 }, -- Incarnation: Chosen of Elune's cooldown is reduced to 100 seconds and it has two charges, but its duration is reduced by 20%.
    wild_mushroom               = {  88202,  88747, 1 }, -- Grow a magical mushroom at the target enemy's location. After 1 sec, the mushroom detonates, dealing 63,714 Nature damage and then an additional 35,939 Nature damage over 10 sec. Affected targets are slowed by 50%. Generates up to 20 Astral Power based on targets hit.
    wild_surges                 = {  91048, 406890, 1 }, -- Your Wrath and Starfire chance to critically strike is increased by 10% and they generate 2 additional Astral Power.
    
    -- Elune's Chosen
    arcane_affinity             = {  94586, 429540, 1 }, -- All Arcane damage from your spells and abilities is increased by 3%.
    astral_insight              = {  94585, 429536, 1 }, -- Incarnation: Chosen of Elune increases Arcane damage from spells and abilities by 10% while active. Increases the duration and number of spells cast by Convoke the Spirits by 25%.
    atmospheric_exposure        = {  94607, 429532, 1 }, -- Enemies damaged by Full Moon or Fury of Elune take 6% increased damage from you for 6 sec.
    boundless_moonlight         = {  94608, 424058, 1, "elunes_chosen" }, --  Fury of Elune Fury of Elune now ends with a flash of energy, blasting nearby enemies for 44,877 Astral damage.  Full Moon
    elunes_grace                = {  94597, 443046, 1 }, -- Using Wild Charge while in Bear Form or Moonkin Form incurs a 3 sec shorter cooldown.
    glistening_fur              = {  94594, 429533, 1 }, -- Bear Form and Moonkin Form reduce Arcane damage taken by 6% and all other magic damage taken by 3%.
    lunar_amplification         = {  94596, 429529, 1 }, -- Each non-Arcane damaging ability you use increases the damage of your next Arcane damaging ability by 3%, stacking up to 3 times.
    lunar_calling               = {  94590, 429523, 1 }, -- Starfire deals 100% increased damage to its primary target, but no longer triggers Solar Eclipse.
    lunar_insight               = {  94588, 429530, 1 }, -- Moonfire deals 20% additional damage.
    lunation                    = {  94586, 429539, 1 }, -- Your Arcane abilities reduce the cooldown of Fury of Elune by 2.0 sec and the cooldown of New Moon, Half Moon, and Full Moon by 1.0 sec. 
    moon_guardian               = {  94598, 429520, 1 }, -- Moonfire and Starfire generate 2 additional Astral Power.
    moondust                    = {  94597, 429538, 1 }, -- Enemies affected by Moonfire are slowed by 20%.
    stellar_command             = {  94590, 429668, 1 }, -- Increases the damage of Fury of Elune by 15% and the damage of Full Moon by 25%.
    the_eternal_moon            = {  94587, 424113, 1 }, -- Further increases the power of Boundless Moonlight.  Fury of Elune The flash of energy now generates 6 Astral Power and its damage is increased by 50%.  Full Moon New Moon and Half Moon now also call down 1 Minor Moon.
    the_light_of_elune          = {  94585, 428655, 1 }, -- Moonfire damage has a chance to call down a Fury of Elune to follow your target for 3 sec.  Fury of Elune Calls down a beam of pure celestial energy, dealing 31,487 Astral damage over 3 sec within its area. Generates 15 Astral Power over its duration.
    
    -- Keeper of the Grove
    blooming_infusion           = {  94601, 429433, 1 }, -- Every 5 Regrowths you cast makes your next Wrath, Starfire, or Entangling Roots instant and increases damage it deals by 100%. Every 5 Starsurges or Starfalls you cast makes your next Regrowth or Entangling roots instant.
    bounteous_bloom             = {  94591, 429215, 1 }, -- Your Force of Nature treants generate 10 Astral Power every 2 sec.
    cenarius_might              = {  94604, 455797, 1 }, -- Entering Eclipse increases your Haste by 12% for 6 sec.
    control_of_the_dream        = {  94592, 434249, 1 }, -- Time elapsed while your major abilities are available to be used or at maximum charges is subtracted from that ability's cooldown after the next time you use it, up to 15 seconds. Affects Force of Nature, Incarnation: Chosen of Elune, and Convoke the Spirits.
    dream_surge                 = {  94600, 433831, 1, "keeper_of_the_grove" }, -- Force of Nature grants 3 charges of Dream Burst, causing your next Wrath or Starfire to explode on the target, dealing 61,684 Nature damage to nearby enemies. Damage reduced above 5 targets.
    durability_of_nature        = {  94605, 429227, 1 }, -- Your Force of Nature treants have 50% increased health.
    early_spring                = {  94591, 428937, 1 }, -- Force of Nature cooldown reduced by 15 sec.
    expansiveness               = {  94602, 429399, 1 }, -- Your maximum mana is increased by 5% and your maximum Astral Power is increased by 20.
    groves_inspiration          = {  94595, 429402, 1 }, -- Wrath and Starfire damage increased by 10%. Regrowth and Wild Growth healing increased by 9%.
    harmony_of_the_grove        = {  94606, 428731, 1 }, -- Each of your Force of Nature treants increases damage your spells deal by 8% while active.
    potent_enchantments         = {  94595, 429420, 1 }, -- Orbital Strike applies Stellar Flare for 8 additional sec and deals 30% increased damage. Whirling Stars reduces the cooldown of Incarnation: Chosen of Elune by an additional 10 sec.
    power_of_nature             = {  94605, 428859, 1 }, -- Your Force of Nature treants no longer taunt and deal 200% increased melee damage.
    power_of_the_dream          = {  94592, 434220, 1 }, -- Force of Nature grants an additional stack of Dream Burst.
    protective_growth           = {  94593, 433748, 1 }, -- Your Regrowth protects you, reducing damage you take by 8% while your Regrowth is on you.
    treants_of_the_moon         = {  94599, 428544, 1 }, -- Your Force of Nature treants cast Moonfire on nearby targets about once every 6 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( { 
    celestial_guardian     =  180, -- (233754) 
    crescent_burn          =  182, -- (200567) 
    deep_roots             =  834, -- (233755) Increases the amount of damage required to cancel your Entangling Roots or Mass Entanglement by 75%.
    dying_stars            =  822, -- (410544) Enemies that dispel your Moonfire or Sunfire suffer 15% additional damage from their effects for 12 sec. If already vulnerable, 50% of the remaining duration is applied to the dispeller.
    faerie_swarm           =  836, -- (209749) Swarms the target with Faeries, disarming the enemy, preventing the use of any weapons or shield and reducing movement speed by 30% for 5 sec.
    high_winds             = 5383, -- (200931) Increases the range of Cyclone, Typhoon, and Entangling Roots by 5 yds.
    malornes_swiftness     = 5515, -- (236147) Your Travel Form movement speed while within a Battleground or Arena is increased by 20% and you always move at 100% movement speed while in Travel Form.
    master_shapeshifter    = 5604, -- (411266) 
    moon_and_stars         =  184, -- (233750) Entering an Eclipse summons a beam of light at your location granting you 50% reduction in silence and interrupts for 6 sec.
    moonkin_aura           =  185, -- (209740) 
    owlkin_adept           = 5407, -- (354541) 
    protector_of_the_grove = 3728, -- (209730) 
    star_burst             = 3058, -- (356517) 
    thorns                 = 3731, -- (1217017) Casting Barkskin sprouts thorns on you for until canceled. When victim to melee attacks, thorns deals 27,681 Nature damage back to the attacker. Attackers also have their movement speed reduced by 50% for 4 sec.
    tireless_pursuit       = 5646, -- (377801) For 3 sec after leaving Cat Form or Travel Form, you retain up to 40% movement speed.
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
    astral_communion = {
        id = 450599,
        duration = 15,
        max_stack = 1
    },
    astral_smolder = {
        id = 394061,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Critical strike chance with Nature spells increased $w1%.
    -- https://wowhead.com/beta/spell=394049
    balance_of_all_things_nature = {
        id = 394049,
        duration = 10,
        max_stack = 10,
        copy = 339943
    },
    -- Talent: Critical strike chance with Arcane spells increased $w1%.
    -- https://wowhead.com/beta/spell=394050
    balance_of_all_things_arcane = {
        id = 394050,
        duration = 10,
        max_stack = 10,
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
    -- Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap. All attack and ability damage is increased by $s3%.
    berserk = {
        id = 106951,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next Wrath, Starfire, or Entangling Roots is instant and deals $w2% increased damage.
    blooming_infusion = {
        id = 429474,
        duration = 12.0,
        max_stack = 1,
    },
    blooming_infusion_regrowth = {
        id = 429438,
        duration = 12.0,
        max_stack = 1,
    },
    -- Autoattack damage increased by $w4%.  Immune to Polymorph effects.  Movement speed increased by $113636s1% and falling damage reduced.
    -- https://wowhead.com/beta/spell=768
    cat_form = {
        id = 768,
        duration = 3600,
        type = "Magic",
        max_stack = 1

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- starfall[191034] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- starfall[344869] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Talent: Both Eclipses active. Haste increased by $w2%.
    -- https://wowhead.com/beta/spell=194223
    celestial_alignment = {
        id = 194223,
        duration = function () return 15 * ( talent.whirling_stars.enabled and 0.8 or 1 ) + ( conduit.precise_alignment.mod * 0.001 ) end,
        type = "Magic",
        max_stack = 1,
        copy = 383410

        -- Affected by:
        -- orbital_strike[390378] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 383410, 'value': 194223, 'schools': ['physical', 'holy', 'fire', 'nature', 'shadow'], 'value1': 2, 'target': TARGET_UNIT_CASTER, }
        -- orbital_strike[390378] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    ca_inc = {}, -- stub for celestial vs. incarnation
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=102352
    cenarion_ward = {
        id = 102352,
        duration = 8,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Haste increased by $w1%.
    cenarius_might = {
        id = 455801,
        duration = 6.0,
        max_stack = 1,
    },
    -- Talent / Covenant (Night Fae): Every 0.25 sec, casting Wild Growth, Swiftmend, Moonfire, Wrath, Regrowth, Rejuvenation, Rake or Thrash on appropriate nearby targets.
    -- https://wowhead.com/beta/spell=391528
    convoke_the_spirits = {
        id = 391528,
        duration = function() return talent.astral_insight.enabled and 5 or 4 end,
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
        duration = 5,
        mechanic = "banish",
        type = "Magic",
        max_stack = 1

        -- Affected by:
        -- cat_form[3025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- heart_of_the_wild[319454] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- Increased movement speed by $s1% while in Cat Form.
    -- https://wowhead.com/beta/spell=1850
    dream_burst = {
        id = 433832,
        duration = 30,
        type = "Magic",
        max_stack = function() return talent.power_of_the_dream.enabled and 4 or 3 end,
    },
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
    faerie_swarm = {
        id = 209749,
        duration = 5,
        max_stack = 1
    },
    force_of_nature = { -- TODO: Is a totem?  Summon?
        id = 205644,
        duration = 15,
        max_stack = 1,
    },
    forestwalk = {
        id = 400129,
        duration = 6.0,
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
    -- Movement speed reduced by $s2%. Suffering $w1 Nature damage every $t1 sec.
    fungal_growth = {
        id = 81281,
        duration = 10,
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

        -- Affected by:
        -- mastery_astral_invocation[393014] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.6, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_astral_invocation[393014] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.6, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_astral_invocation[393014] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.6, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_astral_invocation[393014] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.6, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- moonfire[164812] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- moonfire[164812] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- sunfire[164815] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- sunfire[164815] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_moonlight[394121] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- radiant_moonlight[394121] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- balance_of_all_things[394049] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- eclipse_solar[48517] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eclipse_solar[48517] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eclipse_solar[48517] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=6795
    growl = {
        id = 6795,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    harmony_of_the_grove = {
        id = 428735,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Abilities not associated with your specialization are substantially empowered.
    -- https://wowhead.com/beta/spell=319454
    heart_of_the_wild = {
        id = 319454,
        duration = 45,
        tick_time = 2,
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

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- astral_influence[197524] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- starfall[191034] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- starfall[344869] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Talent: Both Eclipses active. Critical strike chance increased by $w2%$?s194223[ and haste increased by $w1%][].
    -- https://wowhead.com/beta/spell=102560
    incarnation = {
        id = 102560,
        duration = function () return 20 + ( conduit.precise_alignment.mod * 0.001 ) end,
        max_stack = 1,
        copy = "incarnation_chosen_of_elune",

        -- Affected by:
        -- druid[137009] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- elunes_guidance[393991] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -80.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- elunes_guidance[393991] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- orbital_strike[390378] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 390414, 'value': 102560, 'schools': ['shadow'], 'value1': 2, 'target': TARGET_UNIT_CASTER, }
        -- orbital_strike[390378] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
        -- Affected by:
        -- cat_form[768] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- bear_form[5487] #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
    },
    -- Talent: Armor increased by ${$w1*$AGI/100}.
    -- https://wowhead.com/beta/spell=192081
    ironfur = {
        id = 192081,
        duration = 7,
        type = "Magic",
        max_stack = 1
    },
    -- The damage of your next Arcane ability is increased by $w1%.
    lunar_amplification = {
        id = 431250,
        duration = 45.0,
        max_stack = 1,
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
        duration = 10,
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
    -- PvP Talent: Entering an Eclipse summons a beam of light at your location granting you 50% reduction in silence and interrupts for 6 sec.
    -- https://www.wowhead.com/spell=234084
    moon_and_stars = {
        id = 234084,
        duration = 6,
        max_stack = 1
    },
    -- Suffering $w2 Arcane damage every $t2 seconds.$?$w8<0[; Movement slowed by $w8%.][]
    moonfire = {
        id = 164812,
        duration = function () return mod_circle_dot( level > 13 and 22 or 18 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * ( 1 - 0.125 * talent.cosmic_rapidity.rank ) * haste end,
        type = "Magic",
        max_stack = 1,
        copy = { 155625, "moonfire_dmg" }
    },
    -- PvP Talent: Starsurge grants 4% spell critical strike chance to 8 allies within 40 yards for 18 sec, stacking up to 3 times.
    -- https://www.wowhead.com/spell=209746
    moonkin_aura = {
        id = 209746,
        duration = 18,
        max_stack = 3
    },
    -- Spell damage increased by $s9%.; Immune to Polymorph effects.$?$w3>0[; Armor increased by $w3%.][]$?$w12<0[; Arcane damage taken reduced by $w13% and all other magic damage taken reduced by $w12%.][]
    moonkin_form = {
        id = 24858,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        copy = 197625
    },
    -- Talent: $?s137012[Single-target healing also damages a nearby enemy target for $w3% of the healing done][Single-target damage also heals a nearby friendly target for $w3% of the damage done].
    -- https://wowhead.com/beta/spell=124974
    natures_vigil = {
        id = 124974,
        duration = 15,
        tick_time = 0.5,
        max_stack = 1
    },
    orbit_breaker = {
        id = 329970,
        duration = 3600,
        max_stack = 20
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
    -- All damage taken reduced by $w1%.
    protective_growth = {
        id = 433749,
        duration = 3600,
        max_stack = 1,
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
        max_stack = 1,
        dot = "buff",
        friendly = true
    },
     -- Healing $w1 every $t1 sec.
    rejuvenation = {
        id = 774,
        duration = 12.0,
        pandemic = true,
        max_stack = 1,
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
    -- Bleeding for $w1 damage every $t1 sec.
    rip = {
        id = 1079,
        duration = 4.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,
    },
    rising_light_falling_night_day = {
        id = 417714,
        duration = 3600,
        max_stack = 1
    },
    rising_light_falling_night_night = {
        id = 417715,
        duration = 3600,
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
        copy = "mount_form"
    },
     -- Movement speed increased by $s1%.
     stampeding_roar = {
        id = 106898,
        duration = 8.0,
        max_stack = 1,
    },
    -- Talent: Calling down falling stars on nearby enemies.
    -- https://wowhead.com/beta/spell=191034
    starfall = {
        id = 191034,
        duration = 8,
        tick_time = 1.0,
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
    -- Damage over time from $@auracaster increased by $w1%.
    stellar_amplification = {
        id = 450214,
        duration = 5.0,
        max_stack = 1,
    },
    -- Talent: Suffering $w2 Astral damage every $t2 sec.
    -- https://wowhead.com/beta/spell=202347
    stellar_flare = {
        id = 202347,
        duration = function () return mod_circle_dot( 24 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * ( 1 - 0.125 * talent.cosmic_rapidity.rank ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 Nature damage every $t2 seconds.
    -- https://wowhead.com/beta/spell=164815
    sunfire = {
        id = 164815,
        duration = function () return mod_circle_dot( 18 ) end,
        tick_time = function () return mod_circle_dot( 2 ) * ( 1 - 0.125 * talent.cosmic_rapidity.rank ) * haste end,
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
    touch_the_cosmos = {
        id = 450360,
        duration = 15,
        max_stack = 1,
        copy = { "touch_the_cosmos_starfall", "touch_the_cosmos_starsurge" }
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
    -- Moonfire, Sunfire, Stellar Flare, Shooting Stars, and Starfall damage increased by $w1%
    umbral_inspiration = {
        id = 450419,
        duration = 6.0,
        max_stack = 1,
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
        duration = 25,
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
        max_stack = 100,
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

spec:RegisterStateExpr( "energize_amount", function ()
    local ability = class.abilities[ this_action ]
    local amount = ability and ability.energize_amount

    if not amount then return 0 end
    return -amount
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
    if set_bonus.tier31_2pc > 0 then applyBuff( "dreamstate", nil, 2 ) end
    if set_bonus.tier31_4pc > 0 then
        removeBuff( "balance_t31_4pc_buff_lunar" )
        removeBuff( "balance_t31_4pc_buff_solar" )
    end
    if Hekili.ActiveDebug then Hekili:Debug( "Expire CA_Inc: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
end, state )

local ExpireEclipseLunar = setfenv( function()
    eclipse.state = "ANY_NEXT"
    eclipse.reset_stacks()
    removeBuff( "starsurge_empowerment_lunar" )
    if set_bonus.tier31_2pc > 0 then applyBuff( "dreamstate", nil, 2 ) end
    if set_bonus.tier31_4pc > 0 then
        removeBuff( "balance_t31_4pc_buff_lunar" )
    end
    if Hekili.ActiveDebug then Hekili:Debug( "Expire Lunar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
end, state )

local ExpireEclipseSolar = setfenv( function()
    eclipse.state = "ANY_NEXT"
    eclipse.reset_stacks()
    removeBuff( "starsurge_empowerment_solar" )
    if set_bonus.tier31_2pc > 0 then applyBuff( "dreamstate", nil, 2 ) end
    if set_bonus.tier31_4pc > 0 then
        removeBuff( "balance_t31_4pc_buff_solar" )
    end
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
            state:QueueAuraExpiration( "ca_inc", ExpireCelestialAlignment, buff.ca_inc.expires )
        elseif buff.eclipse_solar.up then
            eclipse.state = "IN_SOLAR"
            state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
        elseif buff.eclipse_lunar.up then
            eclipse.state = "IN_LUNAR"
            state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
        else
            eclipse.state = "ANY_NEXT"
            if eclipse.starfire_counter == 0 and eclipse.wrath_counter == 0 then
                if Hekili.ActiveDebug then Hekili:Debug( "Resetting from %d / %d to ANY_NEXT.", eclipse.starfire_counter, eclipse.wrath_counter ) end
                eclipse.reset_stacks()
            end
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

        if talent.astral_communion.enabled then applyBuff( "astral_communion" ) end

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
            local initial = eclipse.state

            if eclipse.starfire_counter == 0 and ( initial == "SOLAR_NEXT" or initial == "ANY_NEXT" ) then
                applyBuff( "eclipse_solar", class.auras.eclipse_solar.duration + buff.eclipse_solar.remains )
                if set_bonus.tier29_4pc > 0 then applyBuff( "touch_the_cosmos" ) end
                state:RemoveAuraExpiration( "eclipse_solar" )
                state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
                if talent.astral_communion.enabled then applyBuff( "astral_communion" ) end
                if talent.solstice.enabled then applyBuff( "solstice" ) end
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                eclipse.state = "IN_SOLAR"
                if buff.parting_skies.up then
                    removeBuff( "parting_skies" )
                    applyDebuff( "target", "fury_of_elune", 8 )
                    applyBuff( "fury_of_elune_ap", 8 )
                elseif talent.parting_skies.enabled then
                    applyBuff( "parting_skies" )
                end
            end

            if eclipse.wrath_counter == 0 and ( initial == "LUNAR_NEXT" or initial == "ANY_NEXT" ) then
                applyBuff( "eclipse_lunar", class.auras.eclipse_lunar.duration + buff.eclipse_lunar.remains )
                if set_bonus.tier29_4pc > 0 then applyBuff( "touch_the_cosmos" ) end
                state:RemoveAuraExpiration( "eclipse_lunar" )
                state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
                if talent.astral_communion.enabled then applyBuff( "astral_communion" ) end
                if talent.solstice.enabled then applyBuff( "solstice" ) end
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                eclipse.state = eclipse.state == "IN_SOLAR" and "IN_BOTH" or "IN_LUNAR"
                if buff.parting_skies.up then
                    removeBuff( "parting_skies" )
                    applyDebuff( "target", "fury_of_elune", 8 )
                    applyBuff( "fury_of_elune_ap", 8 )
                elseif talent.parting_skies.enabled then
                    applyBuff( "parting_skies" )
                end
            end

            if eclipse.state ~= initial then
                eclipse.starfire_counter = 0
                eclipse.wrath_counter = 0
            end
        end

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
        elseif k == "in_none" then
            return eclipse.state ~= "IN_SOLAR" and eclipse.state ~= "IN_LUNAR" and eclipse.state ~= "IN_BOTH"
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


spec:RegisterPet( "treants",
    103822,
    "force_of_nature",
    10,
    103822 )

spec:RegisterTotem( "treants", 103822 )

local TreantMoonfires = setfenv( function()
    for i = 1, 3 do -- # of treants
        spec.abilities.moonfire.handler()
    end
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


    --[[ Needs more work
    if pet.treants.up then
        local tick, expires = action.force_of_nature.lastCast, pet.treants.expires
		local tick2 = tick + 6
		tick = tick + 2
            if tick > query_time and tick < expires then
                state:QueueAuraEvent( "treant_moonfires", TreantMoonfires, tick, "AURA_TICK" )
            end
        end
    end
    --]]

    if talent.fungal_growth.enabled and query_time - action.wild_mushroom.lastCast < 1 then
        if debuff.fungal_growth.up then debuff.fungal_growth.expires = action.wild_mushroom.lastCast + 7
        else applyDebuff( "target", "wild_growth", 7 ) end
    end

    if buff.warrior_of_elune.up then
        setCooldown( "warrior_of_elune", 3600 )
    end

    eclipse.reset()

    --[[ if buff.lycaras_fleeting_glimpse.up then
        state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
    end ]]

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


--The War Within
spec:RegisterGear( "tww1", 212059, 212057, 212056, 212055, 212054 )
spec:RegisterGear( "tww2", 229310, 229308, 229306, 229307, 229305  )
spec:RegisterAuras( {
    -- 2-set
    -- https://www.wowhead.com/spell=1218033
    -- Jackpot! Auto shot damage increased by 200% and the time between auto shots is reduced by 0.5 sec.  
    --[[jackpot = {
        id = 1218033,
        duration = 10,
        max_stack = 1,
    },--]]

} )
-- Tier 29
spec:RegisterGear( "tier29", 200351, 200353, 200354, 200355, 200356, 217193, 217195, 217191, 217192, 217194 )
spec:RegisterSetBonuses( "tier29_2pc", 393632, "tier29_4pc", 393633 )
spec:RegisterAuras( {
    gathering_starstuff = {
        id = 394412,
        duration = 15,
        max_stack = 3,
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

spec:RegisterGear( "tier31", 207252, 207253, 207254, 207255, 207257 )
-- (2) When Eclipse ends or when you enter combat, enter a Dreamstate, reducing the cast time of your next $s3 Starfires or Wraths by $s1% and increasing their damage by $s2%.
spec:RegisterAuras( {
    dreamstate = {
        id = 424248,
        duration = 3600,
        max_stack = 2,
        copy = 450346
    },
    balance_t31_4pc_buff_lunar = {
        duration = 3600,
        max_stack = 5
    },
    balance_t31_4pc_buff_solar = {
        duration = 3600,
        max_stack = 5
    }
} )
spec:RegisterHook( "runHandler_startCombat", function()
    if set_bonus.tier31_2pc > 0 then applyBuff( "dreamstate", nil, 2 ) end
end )
-- (4) Starsurge or Starfall increase your current Eclipse's Arcane or Nature damage bonus by an additional $s1%, up to $s2%.


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

    -- Go Berserk for $d. While Berserk:; Generate $343216s1 combo $lpoint:points; every $t1 sec. Combo point generating abilities generate $s2 additional combo $lpoint:points;. Finishing moves restore up to $405189u combo points generated over the cap.; All attack and ability damage is increased by $s3%.
    berserk = {
        id = 106951,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "off",

        startsCombat = false,

        handler = function()
            applyBuff( "berserk" )
        end
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
    -- TODO: Revisit if Orbital Strike needs its own button.
    celestial_alignment = {
        id = function() return talent.orbital_strike.enabled and 383410 or 194223 end,
        cast = 0,
        charges = function () if talent.whirling_stars.enabled then return 2 end end,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * ( talent.whirling_stars.enabled and ( talent.potent_enchantmeents.enabled and 90 or 100 ) or 180 ) - 60 * talent.orbital_strike.rank end,
        recharge = function () if talent.whirling_stars.enabled then return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 100 - 60 * talent.orbital_strike.rank end end,
        gcd = "off",
        school = "astral",

        talent = "celestial_alignment",
        notalent = "incarnation",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "celestial_alignment" )
            if set_bonus.tww2 >= 2 then summonTotem( "wild_mushroom" ) end
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
                if target.maxR < 8 then
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
        cast = function() return 1.7 * ( buff.heart_of_the_wild.up and 0.7 or 1 ) * haste end,
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
        cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 136100,

        handler = function ()
            applyDebuff( "target", "entangling_roots" )
            removeBuff( "natures_swiftness" )
        end,
    },

    faerie_swarm = {
        id = 209749,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "spell",

        startsCombat = true,
        pvptalent = "faerie_swarm",

        handler = function()
            applyDebuff( "target", "faerie_swarm" )
        end,
    },

    -- Talent: Summons a stand of $s1 Treants for $248280d which immediately taunt and attack enemies in the targeted area.    |cFFFFFFFFGenerates ${$m5/10} Astral Power.|r
    force_of_nature = {
        id = 205636,
        cast = 0,
        cooldown = function() return talent.early_spring.enabled and 45 or 60 end,
        gcd = "spell",
        school = "nature",
        spend = -20,
        spendType = "astral_power",

        talent = "force_of_nature",
        startsCombat = true,

        toggle = "cooldowns",
        ap_check = function() return check_for_ap_overcap( "force_of_nature" ) end,

        handler = function ()
            summonPet( "treants", 10 )
            if talent.harmony_of_the_grove.enabled then applyBuff( "harmony_of_the_grove" ) end
            if talent.dream_surge.enabled then applyBuff( "dream_burst") end
            -- queue aura ticks +2, +8 3 moonfires, actually triggers the handler
            state:QueueAuraEvent( "treant_moonfires", TreantMoonfires, query_time + 2, "AURA_TICK" )
            state:QueueAuraEvent( "treant_moonfires", TreantMoonfires, query_time + 8, "AURA_TICK" )
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
        energize_amount = function() return action.full_moon.spend * -1 end,

        usable = function () return active_moon == "full_moon" end,
        handler = function ()
            spendCharges( "new_moon", 1 )
            spendCharges( "half_moon", 1 )

            -- Radiant Moonlight, NYI.
            active_moon = "new_moon"
        end,
    },

    -- [428655] Moonfire damage has a chance to call down a Fury of Elune to follow your target for ${$s2/1000} sec.; $@spellicon202770 $@spellname202770; Calls down a beam of pure celestial energy, dealing $<dmg> Astral damage over ${$s2/1000} sec within its area.; Generates $?a137010[${$202770m4/$202770t4*$s2/10000} Rage][${$202770m3/$202770t3*$s2/10000} Astral Power] over its duration.
    fury_of_elune = {
        id = 202770,
        cast = 0,
        cooldown = function() return talent.radiant_moonlight.enabled and 45 or 60 end,
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

        spend = -20,
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
        cast = function() return 1.5 * ( buff.heart_of_the_wild.up and 0.7 or 1 ) * haste end,
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

    -- An improved Moonkin Form that grants both Eclipses, any learned Celestial Alignment bonuses, $?a429536[$s6% increased Arcane damage, ][]and $s2% critical strike chance.; Lasts $d. You may shapeshift in and out of this improved Moonkin Form for its duration.
    incarnation = {
        id = function() return talent.orbital_strike.enabled and 390414 or 102560 end,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * ( talent.whirling_stars.enabled and ( talent.potent_enchantmeents.enabled and 90 or 100 ) or 180 ) - 60 * talent.orbital_strike.rank end,
        gcd = "off",

        spend = -40,
        spendType = "astral_power",

        toggle = "cooldowns",

        startsCombat = false,
        texture = 571586,

        talent = "incarnation",

        handler = function ()
            shift( "moonkin_form" )
            if set_bonus.tww2 >= 2 then summonTotem( "wild_mushroom" ) end

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

        form = function()
            if talent.fluid_form.enabled then return end
            return "bear_form"
        end,

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

        spend = 0.01,
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

        spend = function () return talent.moon_guardian.enabled and -8 or -6 end,
        spendType = "astral_power",

        readyTime = function () if state.spec.balance and talent.treants_of_the_moon.enabled then return pet.treants.remains end end,

        startsCombat = true,

        cycle = "moonfire",

        ap_check = function() return check_for_ap_overcap( "moonfire" ) end,
        energize_amount = function() return action.moonfire.spend * -1 end,

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
            local hp = health.percent or 100
            local vd = settings.vigil_damage or 50
            return hp <= vd, strformat( "health %d%% must be under %d%%", hp, vd )
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

        spend = -10,
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

        copy = 102547
    },

    rebirth ={
        id = 20484,
        cast = function() return buff.natures_swiftness.up and 0 or 2 * haste end,
        cooldown = 0,
        gcd = "spell",

        -- readyTime = there is a brez available .. API for this?

        handler = function ()
            removeBuff( "natures_swiftness" )
        end
    },

    -- Heals a friendly target for $s1 and another ${$o2*$<mult>} over $d.$?s231032[ Initial heal has a $231032s1% increased chance for a critical effect if the target is already affected by Regrowth.][]$?s24858|s197625[ Usable while in Moonkin Form.][]$?s33891[    |C0033AA11Tree of Life: Instant cast.|R][]
    regrowth = {
        id = 8936,
        cast = function() return buff.blooming_infusion_regrowth.up and 0 or 1.5 * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return 0.10 * ( 1 - 0.08 * buff.abundance.stack ) end,
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

        spend = 0.05,
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

        spend = 0.10,
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
            gain( health.max * 0.2, "health" )
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
            if buff.oneths_perception.up or buff.starweavers_warp.up or buff.touch_the_cosmos.up then return 0 end
            return ( 50 - ( buff.incarnation.up and talent.elunes_guidance.enabled and 10 or 0 ) - ( buff.touch_the_cosmos.up and 5 or 0 ) - ( buff.astral_communion.up and 15 or 0 ) ) * ( 1 - 0.05 * buff.rattled_stars.stack ) * ( 1 - 0.1 * buff.timeworn_dreambinder.stack )
        end,
        spendType = "astral_power",

        startsCombat = true,
        texture = 236168,

        ap_check = function() return check_for_ap_overcap( "starfall" ) end,

        handler = function ()
            if talent.hail_of_stars.enabled and ( buff.oneths_perception.up or buff.starweavers_warp.up or buff.touch_the_cosmos.up ) then
                applyBuff( "solstice", 3 )
            end

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

    -- Call down a burst of energy, causing $s1 Arcane damage to the target, and $?a429523[${($m1*$m3/100)/(1+$429523s1/100)}][${$m1*$m3/100}] Arcane damage to all other enemies within $A1 yards. Deals reduced damage beyond $s5 targets.; Generates ${$m2/10} Astral Power.
    starfire = {
        id = function () return state.spec.balance and 194153 or 197628 end,
        known = function () return state.spec.balance and IsPlayerSpell( 194153 ) or IsPlayerSpell( 197628 ) end,
        cast = function ()
            if buff.blooming_infusion.up or buff.warrior_of_elune.up or buff.owlkin_frenzy.up then return 0 end
            return haste * 2.25 * ( buff.dreamstate.up and 0.6 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return ( -8 + ( talent.wild_surges.enabled and -2 or 0 ) + ( talent.moon_guardian.enabled and -2 or 0 ) + ( set_bonus.tww1 >= 4 and -2 or 0 ) ) * ( talent.soul_of_the_forest.enabled and buff.eclipse_lunar.up and 1.2 or 1 ) * ( buff.warrior_of_elune.up and 1.3 or 1 ) end,
        spendType = "astral_power",

        startsCombat = true,
        texture = 135753,

        ap_check = function() return check_for_ap_overcap( "starfire" ) end,

        talent = "starfire",

        energize_amount = function() return action.starfire.spend * -1 end,

        handler = function ()
            if talent.fluid_form.enabled and not buff.moonkin_form.up then unshift() end

            removeBuff( "gathering_starstuff" )
            if talent.natures_grace.enabled and buff.dreamstate.up then removeStack( "dreamstate" ) end
            if talent.dream_surge.enabled and buff.dream_burst.up then removeStack( "dream_burst" ) end

            if not talent.lunar_calling.enabled and ( eclipse.state == "ANY_NEXT" or eclipse.state == "SOLAR_NEXT" ) then
                eclipse.starfire_counter = eclipse.starfire_counter - 1
                eclipse.advance()
            end          

            if buff.blooming_infusion.up then
                removeBuff( "blooming_infusion" )
            elseif buff.warrior_of_elune.up then
                removeStack( "warrior_of_elune" )
                if buff.warrior_of_elune.down then
                    setCooldown( "warrior_of_elune", 45 )
                end
            elseif buff.owlkin_frenzy.up then
                removeStack( "owlkin_frenzy" )
            end

            if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
        end,

        finish = function ()
            if talent.fluid_form.enabled and buff.moonkin_form.down then shift( "moonkin_form" ) end
        end,

        copy = { 194153, 197628 }
    },


    starsurge = {
        id = 78674,
        cast = 0,
        cooldown = function() return state.spec.balance and 0 or ( talent.starlight_conduit.enabled and 6 or 10 ) end,
        gcd = "spell",

        spend = function ()
            if not state.spec.balance then return ( talent.starlight_conduit.enabled and 0.003 or 0.006 ) end
            if buff.oneths_clear_vision.up or buff.starweavers_weft.up or buff.touch_the_cosmos.up then return 0 end
            return ( 40 - ( buff.incarnation.up and talent.elunes_guidance.enabled and 8 or 0 ) - ( buff.touch_the_cosmos.up and 5 or 0 ) - ( buff.astral_communion.up and 15 or 0 ) ) * ( 1 - 0.05 * buff.rattled_stars.stack ) * ( 1 - 0.1 * buff.timeworn_dreambinder.stack )
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

            if talent.hall_of_stars.enabled and ( buff.oneths_clear_vision.up or buff.starweavers_weft.up or buff.touch_the_cosmos.up ) then
                applyBuff( "solstice", 3 )
            end

            if buff.starweavers_weft.up then removeBuff( "starweavers_weft" )
            else removeBuff( "touch_the_cosmos" ) end

            if talent.rattle_the_stars.enabled then addStack( "rattled_stars" ) end
            if talent.starlord.enabled then
                if buff.starlord.stack < 3 then stat.haste = stat.haste + 0.04 end
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
            end
            if talent.stellar_amplification.enabled then
                if debuff.stellar_amplification.up and buff.stellar_amplification.duration < 20 then
                    buff.stellar_amplification.duration = buff.stellar_amplification.duration + 5
                    buff.stellar_amplification.expires = buff.stellar_amplification.expires + 5
                else
                    applyDebuff( "target", "stellar_amplification" )
                end
            end

            if set_bonus.tier31_4pc > 0 then
                if buff.eclipse_lunar.up then addStack( "balance_t31_4pc_buff_lunar" ) end
                if buff.eclipse_solar.up then addStack( "balance_t31_4pc_buff_solar" ) end
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "gathering_starstuff" )
            end

            removeBuff( "oneths_clear_vision" )
            removeBuff( "sunblaze" )

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

        spend = 0.10,
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
            if target.maxR < 15 then setDistance( target.distance + 5 ) end
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

        usable = function () return target.exists and target.maxR > 7, "target must be 8+ yards away" end,

        handler = function ()
            if buff.bear_form.up then target.maxR = 5; applyDebuff( "target", "immobilized" )
            elseif buff.cat_form.up then target.maxR = 5; applyDebuff( "target", "dazed" )
            elseif buff.moonkin_form.up then setDistance( target.maxR + 10 ) end
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
        notalent = "sunseeker_mushroom",

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
        cast = function ()
            if buff.blooming_infusion.up then return 0 end
            return haste * 1.5 * ( buff.dreamstate.up and 0.6 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if state.spec.balance then return -1 * (  6 + ( talent.wild_surges.enabled and 2 or 0 ) + ( set_bonus.tww1 >= 4 and 2 or 0 ) ) * ( talent.soul_of_the_forest.enabled and buff.eclipse_solar.up and 1.6 or 1 ) end
            return 0.002
        end,
        spendType = function()
            if state.spec.balance then return "astral_power" end
            return "mana"
        end,

        startsCombat = function() return action.wrath.in_flight end,
        texture = 535045,

        ap_check = function () return check_for_ap_overcap( "solar_wrath" ) end,

        velocity = 20,

        impact = function ()
            if state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                eclipse.wrath_counter = eclipse.wrath_counter - 1
                eclipse.advance()
            end
            if talent.dream_surge.enabled and buff.dream_burst.up then removeStack( "dream_burst" ) end
        end,

        energize_amount = function() return action.wrath.spend * -1 end,

        handler = function ()
            if talent.fluid_form.enabled and not buff.moonkin_form.up then unshift() end

            removeBuff( "blooming_infusion" )
            removeBuff( "gathering_starstuff" )
            if talent.natures_grace.enabled and buff.dreamstate.up then removeStack( "dreamstate" ) end

            if state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                eclipse.wrath_counter = eclipse.wrath_counter - 1
                eclipse.advance()
            end

            removeBuff( "dawning_sun" )
            if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
        end,

        finish = function ()
            if talent.fluid_form.enabled and buff.moonkin_form.down then shift( "moonkin_form" ) end
        end,

        copy = { "solar_wrath", 5176 }
    },
} )



spec:RegisterRanges( "moonfire", "entangling_roots", "growl", "shred" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageDots = true,
    damageExpiration = 6,

    potion = "tempered_potion",

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

spec:RegisterSetting( "starlord_cancel", false, {
    name = strformat( "%s |TInterface\\Addons\\Hekili\\Textures\\Cancel:0|t Cancel", Hekili:GetSpellLinkWithTexture( spec.auras.starlord.id ) ),
    desc = strformat( "If checked, canceling |TInterface\\Addons\\Hekili\\Textures\\Cancel:0|t your %s may be recommended.  Canceling it allows you to start building stacks via %s and %s at its full duration.\n\n"
        .. "You will likely want a |cFFFFD100/cancelaura %s|r macro to manage this during combat.", spec.auras.starlord.name, Hekili:GetSpellLinkWithTexture( spec.abilities.starsurge.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.starfall.id ), spec.auras.starlord.name ),
    icon = 462651,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "toggle",
    width = "full"
} )

-- Starlord Cancel Override
class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
    if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
    return args.buff_name ~= nil, "no buff name detected"
end, state )


--[[ spec:RegisterSetting( "delay_berserking", false, {
    name = strformat( "Delay %s", Hekili:GetSpellLinkWithTexture( class.specs[ 0 ].auras.berserking.id ) ),
    desc = strformat( "If checked, the default priority will attempt to adjust the timing of %s to be consistent with simmed %s usage.",
        Hekili:GetSpellLinkWithTexture( class.specs[ 0 ].auras.berserking.id ), Hekili:GetSpellLinkWithTexture( class.specs[ 0 ].auras.power_infusion.id ) ),
    type = "toggle",
    width = "full",
} ) ]]


spec:RegisterPack( "Balance", 20250125, [[Hekili:T3ZAVnosY9BX4WQH0AKSiLL94dsArUdxcUjxUaeFa5dbru0suwmwsuHKA84ab9Bp9tY(r1nBAl7D29oSp0mIfRU6QR3D1TMfm7Vn7(LXLjZ(RHdchniiCu)GrdVjC29LVSpz297Jx8u8JO)WU4TO))FiEt8UfKV)LnzXlXVEr2HC8xTUSCFXV)QREGctVI0Tl6)yA56dp0pn7k2R27(0T)XR2US)6YTB(5vPBsMWEH(LFVC29pCiDt5FE3ShaORW7gfm7(4dLRZYNDpgrOrnD5Yek4jflMDpc8R7niOx4OF)P5yqon)WEmMo91tFL8WGWEHH4hU)LTXfLj5fNMNUDFE23s2MSRSgUGEd0qYCV7pSBvAEIFnCd6fEhcU)50VFA()0)(F608)0InP7lsKG4gfm95tZJx()COOepMikyvw(P5Bs(wYM0Dpk9MdnorgqNibb9h0FK4xp4ge6rFgeq)mmWeogCxVWVGac)5DwaAqafObxZ(K9sbdyFoIHeZJ0xqKd6H)BX5pDAE2QtZlxJ4N)NPBwwdZT0P7FJ8K4C8JlxNUB29BslklicRjRIpSPe9h)ReH34fLPz7WsHBIZJEijE7S7t2f)WMKLZ(dZkrYpyOQ)MQx4584Y1uPM8090V7)6pTmTmz5)nIcYtF8Xeeb8xoSdth8L05Pic)z0NRIrIUlrtIStZ3NNSajjHOwmopn)7i1hesrIwPXifP0Ti4hFAE4P5DonpHIP(BWiokDxua5R9iO5B9d6)mfjDzFrO6xmK)f(uSINKdvMKz7rCKKY6z73Ir0c6P4)0MdOpU508RonVyFYMnrRXQbKbOmEdsCS)U4Yd5jfrCntgMfbjl)H0YOhYtIFkjVgGlpnFzwz)TzzeTK(LPlEclqJFaAk(WHvRuE1IsKjMtZNsEE4TNM3JWPUKbmADTaHKK(h2tMX(KhfEnzkfrTkTpUOi9BjrXf7XmJRBnZyrw2MLzpVR)Iy0kYI(5jBJt3H0kh)ZNMx9qKk6IKOSvru2dhkrkb9(jRwLGghe5SyjMAg1AQ5HSIcImXQ0hxxgvtmc0cJqxEajkGWczLHJO(QuHabUbTuhrFzmXDtRjo8IOz6d90GreIzezDIjSGgT48DeknAX6SIKDy2ycsfqq2YNlKeqKbyV6ZRtZXMeJqYj5fscAd6hsERJh1iLPyZEC9QlonFDsEwuzEss)Nss2NKJhEK5NOhXw9PyWJdlBGxhNVnB3lsqwp843GiFccgtwTJ4cw2UVL9ucbOI9PiRdf9f5C3isUC1WKNJWAsYdBfkRE8cer8isDDvoDzlEdIdmHOg5Z)xvCBIVIhHAOGOAjqBaBTHd84IL93g)DQ(TYu167ovxVy1bKznKvzcJjIAb2xFnHRThV8fYtUGTOYEWH9s62lJqKbYbbwXaP7CRIUdfQ4hsYZJ3vgrmTImzGdEIRnb9qeM(IbxufvrOe9CYdI(uQv1fik(Im1Uz97MNSplVuWqB4Dmb4xJHg)gF3WbCMHYeanvVZWuffawso2KfYi(IKDlrUDEjQij)WwXPn21sbn(lPL)R5tDjFpkqiiUISeGwfk4kTY6yum1KvFYmDO7gcmzCMGNah4PG25gBdXcsdgjoh0Yikhvkp2fUgJT6ChF53YIksuiyGbzb8QZcSf7dfiB2X7k2MwIglrbbVwTgrzeL5P7EkbT4h0pTOVSOjt6GdrieeUm)jwDVRsjXRrMRWkCd2MAXK1L1itIt)yiO5ZfHmjlGLFcADWlvtHDzicpIAn4x85BD0h2x4SeIhjy(Biy7TAF36O0KTSP1cqvaHI57qbAUtvUonhj(nq0V6Jj7qk1l4ai7KnWu6BmOdeTkCrtk5ux8YWy2ifm8gKi5sfgN2xmHyNVJKzMQLbrFvCoO94SXq1L(XLY23GqlwZEex7sA5Xi7NOfwSjRuGzJxruZ1uzfj00kcOrvfoCylxrcFRRiHYRibVpRiqO9SSIqs(p4AXcHGNIi2)2cL6GeOMiA9QKXPfIbnCqnQ3NvPwQM4iqOP62yTW(qux1WGcsgTAJlBazOuJZUzZ8eZOS6SerQZsLjzPhrQzKsu(SNrgz14YFvJSuTeagEGQiWbG)imTOg4CZ0clwxADMweVbNFMCYB0Q)uIZrc5qcN6goUzQepjhCVQiMpS9H84nixfLj7kslFPpsp7jX6bvKDyd3likcLKIY6XAkXYNV0ueHOCkhIuKo1ybBE6ryLScuHh4y8uznAowefNViExIGBtlWYcIIaRib(qwCze5Bj8)q1GneQVxJ8568PnaKOpvLfFAmL3Ai4qrtucL2moppnlVQglKjGQJ06jGKyaD1c9LilmlWcE1On)WUi6FocxowArzzSR4m6OyY5GT3f9xX)Z94YOMT9Hy9I7Uno)jUW1ZPBwcvI3kyrjZHSDGfcvlfC7RsQqLqs2GKPtr6aXBsFChUQ9sRFx0UIDHflwMFiDj1mPK6VOHZxx9mLIVs2TNPssgVCP9Q(j4mBDCr0(8Sfg9DwhnPuAvnN4ffce)f52JTEVhlk)cp0tTWXIZJFc9FrfXlEiplBP9zou9oBCMlhBf8KpSXjpy4paqyAYFjpyfT4FuzbkMA15cQEuRnf0qDsLKZrtJn49Czf6)LiPlqzMiZtOx75Y19X1FlQaPxq3hewLzJPPnGlzdhsEYbvwnyFpurYKcYuCRtMPSfpavDQ(DL3Zf68ZtDNxWRsYB9s13CD1MXamSAv4qoW4MyJ1lgeJhfmRjc1hK5XUoB46NiGuzRGLuJ1CtS2JHtWnnOxQgCDHt0eVHd0cWs5UFdQ0LampZ(RerYhpbkY0vDOutJiKIJxAF2Zj59xMSkDrAjnG6k0lSRvKGuUrzmqbjaz9x0phHoeg18KvOiVwJHLN9d1TovfSmlAzAcjYUkoaTIb3Wb)c3QrQw0JeKkOrZPUOLBFKpcsLeXyvSMYRI1fnvILkpc48kqSHxwSjHtpyPBapDvm4dNvEhnuzfgYv0nGbMWuDe9pwvLxvnVKA25LrJcEY61vMgKY6UbBdq23T6s6JIAeThzA3vuCh8MeT6vbYHDyBAtjzN0vtYHUoQ8LSTiwAhEnKAjvNkuCBKzgvl2IK2eB6aFr0zifld6HwCrxN8lXkoxsDjsdARKFAgujX5BEjQafYMsQDIDmbM8rrI9K8(EBFPhNa4W6ftfDSAN)GZcZT2GWoUQALG3)hpMhVirlx22k6oLxAAhMMeAXwEUb0ISfi1Fbi30L5zBmVe5b1HaS8r5JgVTfKRCVofOGiF7RmMdJrLtiGNd5ViL8UXAUIfZnMxnkavwpOeOgerd7KSWaON2lbHMlMydiui7ycImxirxQAI56PreWVLLHLf0mZAvt0k(OK5bxOqt1yJUBavnMbyDjDzkYY1IJ4(cojWtDE3MLUlAx2oZEo0Q1Pq1HjBkfc2NtI)gjZ1489YfuTm7WI1evVfziRZfr8ayjfxfkQwT6zAB8swvQHOIdSMNGw6qTXqPcrMnq6vhtcXUbcdLjCMp)jmFuj4pwu9utRT1sEUU6BUW4mdsEQDMsZ2PUEWjPg)XHEGQfBPPTi9cy7RHGze9naLSSiv5oE)mPU2nueO1XBwbcL0MGq6)hiOgjcfUuIrBpuSopltRTrTAyYkV0QdHqZwuAUqYg2ydlII0I5cPXh(fjwbTYjISGssLz)h1j4vsG2QtG10qRhsw7fbeKEZ1PZIIkPVdyXY1mIaNMgJN(TuTcLPERtD1jBtUMfA7QNGJXH5WUM2QWWCixyNIcZSZ)pQSyDOuT)cLtTLmenOAGOh4Y)n1s1)yXXPk6IBfGht))qWTn7WUsdXaDUZ)RX2(15UAtSPEh2M31XM6L4v0L2CY2y1LqB(WHubnQ0efBzAOqzC(oX47(QYtgIapx8xRak18zJeIATv5S7ezQOe0LePUVuAIw6LDxwL64kxzQfpw1CKEv7xMP53uxhq59yODfRyKCJbkz9AmS9U2updTGGX8(nz5l1Z2V6j82zvQ4yYMfnfnI9Y)d76xRKhTj0MF4cKrRUl1mWFbkvSbA8v05x)gmrAX9YNRFl3JSMdFZnddJ1o8nsX9RnMg02mh6Ml4Yujcmh(LS5aPvm5zGqVCvvMz8AGUqY1MkYK5aSAFOEkX0zIw4nDQ1QHpcO8jLw72RZa92rVKLk96icDjFpzXHsP40SujtTxW)CXwQlyujq)P93V8L6sKvv9m7AzkLJvG2bl)lr3XszBT0oYVhfC2s98m0RgnNSgjPv1u0ia4PxyEiWGhaFPtlT5s)7PLELVwwS18BZ1kOjxAwJzm0SZh322fPAsExZ1KKvnfG6swHXFip2KMptKoSfHWvXrUr5nBARb0u3w)MIxU8xBh2MjvNPsBGm8K2bAsIbPF4xmLdWpKN9fBtD1y8mpVdNXApBSPy8JX3ilxheIcXaVLP7WDr)S7j3yhiIhPXWUlt(e7M64t4ec(FpG0Wrz3uKH9HfFOmBBCj(lwSoE3Jjf9p91)skE7jX3(h)ruKGj5Kh)jLgsG1d)iCIV3nm8uUngeuEbF3VjClDDuOGzWB5IgWBgAfKO0JmjKI08)0n)KW1Srx70CxBd8LqxTgx6rmCbCPAm1l82EHxsTRvFnA47Fz41855nx9diTvXzVbEfZsh2RS(5qV4RUAAymLRkKYWaxYihXmuAIk432DrHJJcp7avvhLRychX27h3ainqf0BP6BoogNbQ)oymduAhf0BP4pQJrWa1bHz6hWDB1OyXLSZ4hWBLg(HHrg)bnyySY9J4jE54rPWQgx7Js(Wg3XZwrwoESHsFeV8f)Jh98Sf1xxtJ9pDJ)0W7oEehjyhzY1ueGgXLFhtpzA4GJhn4eFYa(kYVAzIx9JatSwyn8DwzZk(nh2h8yzf(wmUgcFeEqndSBJO(5shWQcaiVNy)9cVFuuTwmTNzt4wXFlKABg(wmUUk12aWUnI6NDFaTJgx)pVy)9cVFuuTHONKQuKsCtGvrsJGnGy9dNUc2nF61vhIWG3jA)DaXN(kqA5vNY6pDosmhOXKuOrlhCAvwGHX4DnDVrgfX5h0xarBHh5iYQug4HYytHraM3v07aIB2lIdX(yh9ah4zddcmKUpuQhuA4Hbak7jvw5AYOetOrjgZiR5LuyyExrVdiUzjghI7Wo6DrIXgKUpunkXyckPH4wdELeB1cflzGNkCv8QNa)BgXGUmIZsANZIRHPRZA1ru001kUGq)Q0XtVtv6XIkXF6n98K6hLFk0NtvVACCfchMLWEh4ggc8jw6etQG(yWJtPJy(newIDHx9dBPc2nFAmDDiepPMkih6qC6kALpGNkig(0FQHAdbbkDGmvWm4H10ved1rOk43wtJQnmgK1F7slVBi2GX53mIdp)ig04CrldK)JW2SfPTZxX9)OeP)7G5Yzydr(yytgYqK3eGFsnwh5MiwdDAzl8oOle(Lpg7a0(I5nAl48M3Nv03IIh2m8UpSUw7W2uXBtjDEMsgYk6BbBSz4DFyDLn6wjyp91)mrwgpoJ4To3P5KF0xqpg30ujlWhfRqC)FLH)vdI37nf9RkOv3jxPErbE6RGqjCfbcdbFdJ(mUNTMiUZAFM0P5tUGB8sV6wD4pZs1OoEu8Y)ZfAqENRyuXGxXBMTFs8YLme4vRBWRqrN6Vsl))JhTyHq9Ha5E7J4n5wkiZBE64vlKQnFaQNrnjdOgQ(qO5ZLH1ZiWsb4F6R)UF3P5)hvxWDy1dwlfsSB)Vs63sHFqK(xiB(A)(W8c(nI3NtxnXAtBwjfkLWFhwxPcC18noya5PkxjFMKXinNjMkUq6k0ZoSIG25cpXBzVJhfVH9y)n2TRNpmA5DokHkaNTgUb9mHoHxfBtIbe(rv)4sHwopn)S9ZeL4yuXKWljJd7WV5oOXcG)DIQJNi)RRi3RRiZZFSeILvFe60yMsJlTNgyRFDgB5lZ0RY25ZOzdn5(4FU6bMownghiHFzKydY5OXeSmXeA5sU5lGr0lyu3rx2Shf)l9c6bgX(Ld6h6R0qitrk7Exy1acUVo4Avq9hYXJ2ADe)on06i0z3nyYGlYXAfnHUoXYVWrtNe677x)2YZ5JhVWC2fid7qVJBumRJ7VmSXMJHYOvLy0poX(I8kHF1p6CHYbvJ4jPwCkLoOjFh5WcXqIWqZ0XjvilD3Qd4g2fBtbUX3fKn53A8uea87uK6OVKi5afwhkqPINWdQbLuKSN5rw2fSrsVJ1woQTTvKpi0HwitZrrJjzGFMIMEDhpOFCIMEDL0iqoLD8AYE24HnPhAYY04adZ6pWEhZVJTLXXtcVZ8sGbPpm)3Zb2whpNcLfiUq7enYU0D4EIZfJdiV8WA(oq(nX4uxf)yxx9n73Z4VUfmNG)QTFg)rOPqbvxWhNJjmqcOblBw0xjdnZg6ua0G6yhpd06ftcGYmJBweplHIgkCq3Wbx6z(nhhoY3xGdzuCZVrEvOeVcWsGsUFUWRSvpel8QqOSYBjVs)nFB8kPyPPNHmmddGsMmusWS(yRj5F3M(EWOw(6aurWiZgLyjBXd8x)e8InEaCCmXrL1ao5JVzCZjWF2Y5908OuFtiXgbOAiF8i8fe30WEEm4bVgE559P3FCtdSyJx4a3loTB(xRLUwGBNWVulsjoRCVDsYHgKhCb0xxBPvzbB6KBbCpZv5ePaLFCtyXqNL8z6pIktigDLwaMg047xukudI(iSjwJGAAUE5xBIyCMnU6wVQZf2ZmGnUsvA5xIXgTuHh7yGtQ94AMHqTn6EJkE4rE)zPRAe6AJ795rDcNaHRROL1lEb4nN(0BeceXqeEthYs)ZyC9xqogYQmRdNH5OE)W8BDEjLvkKGRQ(Mj7avcZDz1fOdO2H3fQQdcEDnQG4drsIQIUtvWkTVAYQnwLotdsZMGoBdKqzGFdc49OpA6TDLeK97i9xh7fuv2oqpW98c5v)tUFT87b5ntB6OOtqspM9I6nsvh2te7cQoIL(TQbM8nZBNozOdeHPk4YLyRllOy7nH8H7(I80BStLg9UhmOBqvnxH6VIoEYvtLJOUJetXugPsVH(YK4vKMSUeBlfuEb1BCuwL)YLk6mhw9nPS5IcYExHso787afrgCSxMJ4D8Tvfgt6vSzxWdEqGd9DsGpRAbQH0BJQOdE9T6sLDKJh5Byd7Qwh2cglqgAbgk1UIByjzy76TbcTKB5fy8YUSEmqlAsk6LfHYyjiw6(rN5tv7Mr3a7gVEABHqpFnKUKNCfWnRCD9a)M3pdhlnKPOicg5RTMY3Gc1VV6sNsxpNDRlPPZiExK7G9t7twBAjW5gbMZRH1sHSxedbqmFLIYgdm49iLHcT9f(dEOTf)nfJdpEukcc77IVfPY4LVGChA)1bPzFfI21O5RMbne4EJAsnfpUc95MRokOVkpDKxTDo6Cq((nhpQJcZNVXPYnc4KVdu23tRavm5BMxYgUmRvOG3sqIG7YRtBbdF)Ch6g8oSFUnSdaMXD3H(6E40XF3rneDAfnEg4pDBmw4Qr71pVTcu1ELmY3wy3oSRl8H7wFtDaGzULtnhWuJw(4tIEbd6OtPtDb5Iv0IQVOMYWOUqkJJHuBTP8Zl5BjT5P7uftz9TU84HTXVx99g8RZVZhR3M378)vgo(sgRPGyR)QBk6Vocp2MuLlI41nxJqGlQCevp(WzS487dN(K4nk80RRPgHn2y6KHQ7s11k4MNDag1U78uXlj0g5BSWfJuOGQ8qEtKGsEYs7A1uXRNwW9idcq1(rRDZQQKO(n1SYPe5TvGa(nUlueKNZ6oOtTG7lJTidbV5C76XEAv1vubacL(xcvfh(kGxv8D(QMNEdjvRfzU9kvvNSGykY0ey6(JrhWjVvdvKMdD5hi1z3BId0UTwur4PqTNfah2qldaNAx1Bv3tdU(g)y3Yntcm35qd9HRvGRtYp8ELX0ejeEEqUcBN9))d]] )