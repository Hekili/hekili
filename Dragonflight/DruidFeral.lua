-- DruidFeral.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID = ns.FindUnitBuffByID

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
    astral_influence               = { 82210, 197524, 2 }, -- Increases the range of all of your abilities by 97 yards.
    cyclone                        = { 82213, 33786 , 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 6 sec. Only one target can be affected by your Cyclone at a time.
    feline_swiftness               = { 82239, 131768, 2 }, -- Increases your movement speed by 15%.
    forestwalk                     = { 92229, 400129, 2 }, -- Casting Regrowth increases your movement speed and healing received by 5% for 3 sec.
    gale_winds                     = { 92228, 400142, 1 }, -- Increases Typhoon's radius by 20% and its range by 5 yds.
    heart_of_the_wild              = { 82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Magical damage increased by 30%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges. Restoration: Healing increased by 30%, and mana costs reduced by 50%.
    hibernate                      = { 82211, 2637  , 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin              = { 82219, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_rejuvenation          = { 82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec.
    improved_stampeding_roar       = { 82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    improved_sunfire               = { 93714, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within 8 yards.
    improved_swipe                 = { 82226, 400158, 1 }, -- Increases Swipe damage by 100%.
    incapacitating_roar            = { 82237, 99    , 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 13 yards for 3 sec. Damage will cancel the effect.
    incessant_tempest              = { 92228, 400140, 1 }, -- Reduces the cooldown of Typhoon by 5 sec.
    innervate                      = { 82243, 29166 , 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 10 sec.
    ironfur                        = { 82227, 192081, 1 }, -- Increases armor by 8,250 for 7 sec.
    killer_instinct                = { 82225, 108299, 2 }, -- Physical damage and Armor increased by 2%.
    lycaras_teachings              = { 82233, 378988, 3 }, -- You gain 2% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                           = { 82221, 22570 , 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 2,235 damage, 1 sec 2 points: 4,471 damage, 2 sec 3 points: 6,707 damage, 3 sec 4 points: 8,943 damage, 4 sec 5 points: 11,179 damage, 5 sec
    mass_entanglement              = { 82242, 102359, 1 }, -- Roots the target and all enemies within 15 yards in place for 30 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                     = { 82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 30,987 damage for 8 sec.
    mighty_bash                    = { 82237, 5211  , 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    natural_recovery               = { 82206, 377796, 2 }, -- Healing done and healing taken increased by 3%.
    natures_vigil                  = { 82244, 124974, 1 }, -- For 15 sec, all single-target damage also heals a nearby friendly target for 20% of the damage done.
    nurturing_instinct             = { 82214, 33873 , 2 }, -- Magical damage and healing increased by 2%.
    primal_fury                    = { 82238, 159286, 1 }, -- When you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect.
    protector_of_the_pack          = { 82245, 378986, 1 }, -- Store 5% of your damage, up to 42,045. Your next Regrowth consumes all stored damage to increase its healing.
    renewal                        = { 82232, 108238, 1 }, -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    rising_light_falling_night     = { 82207, 417712, 1 }, -- Increases your damage and healing by 3% during the day. Increases your Versatility by 2% during the night.
    skull_bash                     = { 82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    soothe                         = { 82229, 2908  , 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar                = { 82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 18 yards by 60% for 8 sec.
    sunfire                        = { 82208, 93402 , 1 }, -- A quick beam of solar light burns the enemy for 2,018 Nature damage and then an additional 17,432 Nature damage over 18 sec.
    thick_hide                     = { 82228, 16931 , 2 }, -- Reduces all damage taken by 6%.
    tiger_dash                     = { 82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    tireless_pursuit               = { 82197, 377801, 1 }, -- For 3 sec after leaving Cat Form or Travel Form, you retain up to 40% movement speed.
    typhoon                        = { 82209, 132469, 1 }, -- Blasts targets within 18 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by 50% for 6 sec. Usable in all shapeshift forms.
    ursine_vigor                   = { 82235, 377842, 2 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 10%.
    ursols_vortex                  = { 82242, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart                  = { 82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    wellhoned_instincts            = { 82246, 377847, 2 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 120 sec.
    wild_charge                    = { 82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                    = { 82241, 48438 , 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 13,097 over 7 sec. Healing starts high and declines over the duration.

    -- Feral
    adaptive_swarm                 = { 82112, 391888, 1 }, -- Command a swarm that heals 17,531 or deals 16,697 Shadow damage over 12 sec to a target, and increases the effectiveness of your periodic effects on them by 25%. Upon expiration, finds a new target, preferring to alternate between friend and foe up to 3 times.
    apex_predators_craving         = { 82092, 391881, 1 }, -- Rip damage has a 4% chance to make your next Ferocious Bite free and deal the maximum damage.
    ashamanes_guidance             = { 82113, 391548, 1 }, -- Your melee attacks have a chance to activate Incarnation: Avatar of Ashamane for 6 sec, without the ability to enter stealth in combat. Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    berserk                        = { 82101, 106951, 1 }, -- Go Berserk for 20 sec. While Berserk: Generate 1 combo point every 1.5 sec. Combo point generating abilities generate 1 additional combo point. Finishing moves restore up to 3 combo points generated over the cap. Shred and Rake damage increased by 50%.
    berserk_frenzy                 = { 82090, 384668, 1 }, -- During Incarnation: Avatar of Ashamane your combo point-generating abilities bleed the target for an additional 100% of their damage over 8 sec.
    berserk_heart_of_the_lion      = { 82105, 391174, 1 }, -- Each combo point spent reduces the cooldown of Incarnation: Avatar of Ashamane by 0.5 sec.
    bloodtalons                    = { 82109, 319439, 1 }, -- When you use 3 different combo point-generating abilities within 4 sec, the damage of your next 3 Rips or Ferocious Bites is increased by 25% for their full duration.
    brutal_slash                   = { 82091, 202028, 1 }, -- Strikes all nearby enemies with a massive slash, inflicting 14,490 Physical damage. Deals 15% increased damage against bleeding targets. Deals reduced damage beyond 5 targets. Awards 1 combo point.
    carnivorous_instinct           = { 82110, 390902, 2 }, -- Tiger's Fury's damage bonus is increased by 6%.
    cats_curiosity                 = { 82094, 386318, 2 }, -- Clearcast abilities generate 25% of their Energy cost.
    circle_of_life_and_death       = { 82095, 400320, 1 }, -- Your damage over time effects deal their damage in 20% less time, and your healing over time effects in 15% less time.
    convoke_the_spirits            = { 82114, 391528, 1 }, -- Call upon the Night Fae for an eruption of energy, channeling a rapid flurry of 12 Druid spells and abilities over 3 sec. Chance to use an exceptional spell or ability is increased. You will cast Ferocious Bite, Shred, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    dire_fixation                  = { 82085, 417710, 1 }, -- Attacking an enemy with Shred fixates your attention on it for 10 sec. You can fixate on a single target at once. Your attacks deal 8% increased damage to your fixated target.
    doubleclawed_rake              = { 82086, 391700, 1 }, -- Rake also applies Rake to 1 additional nearby target.
    dreadful_bleeding              = { 82117, 391045, 1 }, -- Rip damage increased by 18%.
    feral_frenzy                   = { 82108, 274837, 1 }, -- Unleash a furious frenzy, clawing your target 5 times for 8,682 Physical damage and an additional 57,470 Bleed damage over 6 sec. Awards 5 combo points.
    frantic_momentum               = { 82115, 391875, 2 }, -- Finishing moves have a 3% chance per combo point spent to grant 10% Haste for 6 sec.
    frenzied_regeneration          = { 82220, 22842 , 1 }, -- Heals you for 32% health over 3 sec.
    incarnation                    = { 82114, 102543, 1 }, -- An improved Cat Form that grants all of your known Berserk effects and lasts 30 sec. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation: Energy cost of all Cat Form abilities is reduced by 20%, and Prowl can be used once while in combat. Generate 1 combo point every 1.5 sec. Combo point generating abilities generate 1 additional combo point. Finishing moves restore up to 3 combo points generated over the cap. Shred and Rake damage increased by 50%.
    incarnation_avatar_of_ashamane = { 82114, 102543, 1 }, -- An improved Cat Form that grants all of your known Berserk effects and lasts 30 sec. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation: Energy cost of all Cat Form abilities is reduced by 20%, and Prowl can be used once while in combat. Generate 1 combo point every 1.5 sec. Combo point generating abilities generate 1 additional combo point. Finishing moves restore up to 3 combo points generated over the cap. Shred and Rake damage increased by 50%.
    infected_wounds                = { 82103, 48484 , 1 }, -- Rake damage increased by 30%, and Rake causes an Infected Wound in the target, reducing the target's movement speed by 20% for 12 sec.
    lions_strength                 = { 82109, 391972, 1 }, -- Ferocious Bite and Rip deal 15% increased damage.
    lunar_inspiration              = { 92641, 155580, 1 }, -- Moonfire is usable in Cat Form, costs 30 energy, and generates 1 combo point.
    merciless_claws                = { 82098, 231063, 1 }, -- Shred deals 20% increased damage and Swipe deals 15% increased damage against bleeding targets.
    moment_of_clarity              = { 82100, 236068, 1 }, -- Omen of Clarity now triggers 50% more often, can accumulate up to 2 charges, and increases the damage of your next Shred, Thrash, or Swipe by 15%.
    moonkin_form                   = { 91045, 197625, 1 }, -- Shapeshift into Moonkin Form, increasing the damage of your spells by 10% and your armor by 125%, and granting protection from Polymorph effects. The act of shapeshifting frees you from movement impairing effects.
    omen_of_clarity                = { 82123, 16864 , 1 }, -- Your auto attacks have a high chance to cause a Clearcasting state, making your next Shred, Thrash, or Swipe cost no Energy and deal 15% more damage. Clearcasting can accumulate up to 1 charges.
    pouncing_strikes               = { 82119, 390772, 1 }, -- While stealthed, Rake will also stun the target for 4 sec, and deal 60% increased damage for its full duration. While stealthed, Shred deals 60% increased damage, has double the chance to critically strike, and generates 1 additional combo point.
    predator                       = { 82122, 202021, 1 }, -- The cooldown on Tiger's Fury resets when a target dies with one of your Bleed effects active, and Tiger's Fury lasts 5 additional seconds.
    predatory_swiftness            = { 82106, 16974 , 1 }, -- Your finishing moves have a 20% chance per combo point to make your next Regrowth or Entangling Roots instant, free, and castable in all forms.
    primal_wrath                   = { 82120, 285381, 1 }, -- Finishing move that deals instant damage and applies Rip to all enemies within 14 yards. Lasts longer per combo point. 1 point : 2,409 plus Rip for 4 sec 2 points: 3,613 plus Rip for 6 sec 3 points: 4,818 plus Rip for 8 sec 4 points: 6,022 plus Rip for 10 sec 5 points: 7,227 plus Rip for 12 sec
    protective_growth              = { 82097, 391947, 1 }, -- Your Regrowth protects you, reducing all damage you take by 5% while your Regrowth is on you.
    raging_fury                    = { 82107, 391078, 1 }, -- Finishing moves extend the duration of Tiger's Fury by 0.4 sec per combo point spent.
    rake                           = { 82199, 1822  , 1 }, -- Rake the target for 3,721 Bleed damage and an additional 29,651 Bleed damage over 15 sec. Reduces the target's movement speed by 20% for 12 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    rampant_ferocity               = { 82099, 391709, 1 }, -- Ferocious Bite also deals 2,946 damage per combo point spent to all nearby enemies affect by your Rip. Damage reduced beyond 5 targets.
    rejuvenation                   = { 82217, 774   , 1 }, -- Heals the target for 16,830 over 12 sec.
    relentless_predator            = { 82088, 393771, 1 }, -- Energy cost of Ferocious Bite reduced by 20%.
    remove_corruption              = { 82204, 2782  , 1 }, -- Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects.
    rip                            = { 82222, 1079  , 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 16,393 over 8 sec 2 points: 24,590 over 12 sec 3 points: 32,787 over 16 sec 4 points: 40,984 over 20 sec 5 points: 49,181 over 24 sec
    rip_and_tear                   = { 82093, 391347, 1 }, -- Applying Rip to a target also applies a Tear that deals 15% of the new Rip's damage over 8 sec.
    sabertooth                     = { 82102, 202031, 1 }, -- Ferocious Bite deals 15% increased damage and increases all damage dealt by Rip by 5% per Combo Point spent for 4 sec.
    soul_of_the_forest             = { 82096, 158476, 1 }, -- Your finishing moves grant 3 Energy per combo point spent and deal 5% increased damage.
    starfire                       = { 91044, 197628, 1 }, -- Call down a burst of energy, causing 8,829 Arcane damage to the target, and 3,013 Arcane damage to all other enemies within 5 yards. Deals reduced damage beyond 8 targets.
    starsurge                      = { 82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing 16,347 Astral damage.
    sudden_ambush                  = { 82104, 384667, 1 }, -- Finishing moves have a 6% chance per combo point spent to make your next Rake or Shred deal damage as though you were stealthed.
    survival_instincts             = { 82116, 61336 , 1 }, -- Reduces all damage you take by 50% for 6 sec.
    swiftmend                      = { 82216, 18562 , 1 }, -- Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for 52,216.
    taste_for_blood                = { 82118, 384665, 1 }, -- Ferocious Bite deals 5% increased damage for each of your Bleeds on the target.
    tear_open_wounds               = { 82089, 391785, 1 }, -- Primal Wrath consumes up to 4 sec of Rip damage on targets it hits and deals 50% of it instantly.
    thrash                         = { 82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    thrashing_claws                = { 82098, 405300, 1 }, -- Shred deals 5% increased damage against bleeding targets and Shred and Swipe apply the Bleed damage over time from Thrash.
    tigers_fury                    = { 82124, 5217  , 1 }, -- Instantly restores 50 Energy, and increases the damage of all your attacks by 21% for their full duration. Lasts 15 sec.
    tigers_tenacity                = { 82107, 391872, 1 }, -- Tiger's Fury causes your next 3 finishing moves to restore 1 combo point.
    tireless_energy                = { 82121, 383352, 2 }, -- Maximum Energy increased by 30 and Energy regeneration increased by 10%.
    unbridled_swarm                = { 82111, 391951, 1 }, -- Adaptive Swarm has a 60% chance to split into two Swarms each time it jumps.
    veinripper                     = { 82093, 391978, 1 }, -- Rip, Rake, and Thrash last 25% longer.
    wild_slashes                   = { 82091, 390864, 1 }, -- Swipe and Thrash damage is increased by 25%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    ferocious_wound      = 611 , -- (236020) Attacking with a 5 combo point Ferocious Bite reduces the target's maximum health by up to 5% for 30 sec, stacking up to 2 times. Ferocious Wound can only be active on one target at once.
    freedom_of_the_herd  = 203 , -- (213200) Your Stampeding Roar clears all roots and snares from yourself and allies.
    fresh_wound          = 612 , -- (203224) Rake has a 100% increased critical strike chance if used on a target that doesn’t already have Rake active.
    high_winds           = 5384, -- (200931) Cyclone leaves the target reeling, reducing their damage and healing by 30% for 6 sec.
    king_of_the_jungle   = 602 , -- (203052) For every enemy you have Rip active on, your movement speed and healing received is increased by 5%. Stacks 4 times.
    leader_of_the_pack   = 3751, -- (202626) While in Cat Form, you increase the movement speed of raid members within 20 yards by 10%. Leader of the Pack also causes allies to heal themselves for 3% of their maximum health when they critically hit with a direct attack. The healing effect cannot occur more than once every 8 sec.
    malornes_swiftness   = 601 , -- (236012) Your Travel Form movement speed while within a Battleground or Arena is increased by 20% and you always move at 100% movement speed while in Travel Form.
    savage_momentum      = 820 , -- (205673) Interrupting a spell with Skull Bash reduces the remaining cooldown of Tiger's Fury, Survival Instincts, and Dash by 10 sec.
    strength_of_the_wild = 3053, -- (236019) You become further adept in Caster Form and Bear Form. Caster Form When using Regrowth on an ally the initial heal will have a 30% increased critical chance and the cast time of Regrowth will be reduced by 50% for 6 sec. Bear Form Maximum health while in Bear Form increased by 15% and you gain 5 Rage when attacked in Bear Form. You also learn:  Strength of the Wild Maul the target for 8% of the target's maximum health in Physical damage.
    thorns               = 201 , -- (305497) Sprout thorns for 12 sec on the friendly target. When victim to melee attacks, thorns deals 12,109 Nature damage back to the attacker. Attackers also have their movement speed reduced by 50% for 4 sec.
    wicked_claws         = 620 , -- (203242) Infected Wounds can now stack up to 2 times, and reduces 10% of all healing received by the target per stack. Infected Wounds can now also be applied from Rip.
    wild_attunement      = 5593, -- (410354) After successful Cyclone casts, you are automatically shifted into Cat Form and your next Ferocious Bite, Rip, or Maim within 5 sec also casts Feral Frenzy.
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
    -- Armor increased by $w4%.  Stamina increased by $1178s2%.  Immune to Polymorph effects.
    -- https://wowhead.com/beta/spell=5487
    bear_form = {
        id = 5487,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Finishing moves have a $w1% chance per combo point spent to refund $343216s1 combo $lpoint:points;.    Rake and Shred deal damage as though you were stealthed.    $?s384668[Combo point-generating abilities bleed the target for an additonal $384668s2% of their damage over $340056d.][]
    -- https://wowhead.com/beta/spell=106951
    berserk = {
        id = 106951,
        duration = 20,
        max_stack = 1,
        copy = { 279526, "berserk_cat" },
        multiplier = 1.5,
    },
    overflowing_power = {
        id = 405189,
        duration = function () return talent.incarnation.enabled and 30 or 20 end,
        max_stack = 3,
        copy = "berserk_overflow",
        meta = {
            stack = function( t )
                if buff.bs_inc.down then return 0 end
                local deficit = combo_points.deficit
                if deficit > 0 then return t.count end
                return min( 3, t.count + max( 0, floor( ( query_time - t.applied ) / 1.5 ) ) )
            end,
            stacks = function( t )
                return t.stack
            end
        }
    },

    -- Alias for Berserk vs. Incarnation
    bs_inc = {
        alias = { "berserk", "incarnation" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
        duration = function () return talent.incarnation.enabled and 30 or 20 end,
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
    -- Damage taken from $@auracaster's attacks increased by $s1%.
    dire_fixation = {
        id = 417713,
        duration = 10.0,
        max_stack = 1,
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
        duration = 1,
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
        duration = 30,
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
    maim = {
        id = 22570,
        duration = function() return 1 + combo_points.current end,
        max_stack = 1,
    },
    -- Talent: Rooted.
    -- https://wowhead.com/beta/spell=102359
    mass_entanglement = {
        id = 102359,
        duration = 30,
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
        duration = function () return mod_circle_dot( 16 ) * haste end,
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
        duration = function () return mod_circle_dot( 16 ) * haste end,
        tick_time = function () return mod_circle_dot( 2 ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Immune to Polymorph effects.$?$w3>0[  Armor increased by $w3%.][]
    -- https://wowhead.com/beta/spell=197625
    moonkin_form = {
        id = 197625,
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
        duration = function () return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 2 + 2 * combo_points.current ) * haste end,
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
        duration = function () return mod_circle_dot( ( talent.veinripper.enabled and 1.25 or 1 ) * 15 ) * haste end,
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
    -- Heals $w2 every $t2 sec.
    -- https://wowhead.com/beta/spell=8936
    regrowth = {
        id = 8936,
        duration = function () return mod_circle_hot( 12 ) * haste end,
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
    sabertooth = {
        id = 391722,
        duration = 4,
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
        duration = function () return mod_circle_dot( 15 ) * haste end,
        tick_time = function () return mod_circle_dot( 3 ) * haste end,
        max_stack = 3,
    },
    thrash_cat = {
        id = 405233,
        duration = function () return mod_circle_dot( ( talent.veinripper.enabled and 1.25 or 1 ) * 15 ) * haste end,
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
        duration = function() return talent.predator.enabled and 15 or 10 end,
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

spec:RegisterStateExpr( "opener_done", function ()
    return rip_applied
end )


local last_bloodtalons_proc = 0

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
            elseif spellID == 145152 then -- Bloodtalons
                last_bloodtalons_proc = GetTime()
            end
        elseif subtype == "SPELL_CAST_SUCCESS" and ( spellID == class.abilities.rip.id or spellID == class.abilities.primal_wrath.id ) then
            rip_applied = true
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
        generate = bt_generator
    },
    bt_thrash = {
        duration = 4,
        max_stack = 1,
        generate = bt_generator
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
        gain( 5, "combo_points" )
    end

    opener_done = nil
    last_bloodtalons = nil

    if buff.jungle_stalker.up then buff.jungle_stalker.expires = buff.bs_inc.expires end

    if buff.lycaras_fleeting_glimpse.up then
        state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
    end

    if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
        state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
    end
end )

spec:RegisterHook( "gain", function( amt, resource )
    if amt > 0 and resource == "combo_points" and buff.bs_inc.up and buff.overflowing_power.applied == 0 and combo_points.deficit - amt <= 0 then
        local partial = max( 0, ( query_time - buff.bs_inc.applied ) % 1.5 )
        applyBuff( "overflowing_power", buff.bs_inc.remains + partial, 0, nil, nil, nil, query_time - partial )
    end
    if azerite.untamed_ferocity.enabled and amt > 0 and resource == "combo_points" then
        if talent.incarnation.enabled then gainChargeTime( "incarnation", 0.2 )
        else gainChargeTime( "berserk", 0.3 ) end
    end
end )


local function comboSpender( a, r )
    if r == "combo_points" and a > 0 then
        if talent.soul_of_the_forest.enabled then
            gain( a * 3, "energy" )
        end

        if buff.overflowing_power.up then
            gain( buff.overflowing_power.stack, "combo_points" )
            removeBuff( "overflowing_power" )
        end

        if legendary.frenzyband.enabled then
            reduceCooldown( talent.incarnation.enabled and "incarnation" or "berserk", 0.3 )
        end

        if talent.berserk_heart_of_the_lion.enabled and buff.bs_inc.up then
            reduceCooldown( talent.incarnation.enabled and "incarnation" or "berserk", 0.5 )
        end

        if talent.raging_fury.enabled and buff.tigers_fury.up then
            buff.tigers_fury.expires = buff.tigers_fury.expires + 0.4 * a
        end

        if buff.tigers_tenacity.up then
            removeStack( "tigers_tenacity" )
            gain( 1, "combo_points" )
        end

        if a >= 5 then
            applyBuff( "predatory_swiftness" )
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
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
        gcd = "off",
        school = "physical",

        talent = "berserk",
        notalent = "incarnation",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if buff.cat_form.down then shift( "cat_form" ) end
            applyBuff( "berserk" )
            applyBuff( "overflowing_power", nil, 0 )
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
            return max( 0, 25 * ( buff.incarnation.up and 0.8 or 1 ) + buff.scent_of_blood.v1 )
        end,
        spendType = "energy",

        talent = "brutal_slash",
        startsCombat = true,

        form = "cat_form",

        damage = function ()
            return calculate_damage( 0.9837, false, true ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 )
        end,

        max_targets = 5,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.brutal_slash.spend ) end,

        handler = function ()
            gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1, "combo_points" )
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end

            if talent.bloodtalons.enabled then
                applyBuff( "bt_brutal_slash" )
                check_bloodtalons()
            end

            if talent.cats_curiosity.enabled and buff.clearcasting.up then
                gain( 25 * 0.25, "energy" )
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


    enraged_maul = {
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
    },


    entangling_roots = {
        id = 339,
        cast = function ()
            if buff.predatory_swiftness.up then return 0 end
            return 1.7 * haste
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
        cooldown = 45,
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
            return 25 * ( buff.incarnation.up and 0.8 or 1 ), "energy"
        end,
        spendType = "energy",

        talent = "feral_frenzy",
        startsCombat = true,

        form = "cat_form",
        indicator = function ()
            if active_enemies > 1 and settings.cycle and target.time_to_die < longest_ttd then return "cycle" end
        end,

        handler = function ()
            gain( 5, "combo_points" )
            applyDebuff( "target", "feral_frenzy" )
            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end
        end,

        copy = "ashamanes_frenzy"
    },

    -- Finishing move that causes Physical damage per combo point and consumes up to $?a102543[${$s2*(1+$102543s2/100)}][$s2] additional Energy to increase damage by up to 100%.       1 point  : ${$m1*1/5} damage     2 points: ${$m1*2/5} damage     3 points: ${$m1*3/5} damage     4 points: ${$m1*4/5} damage     5 points: ${$m1*5/5} damage
    ferocious_bite = {
        id = 22568,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.apex_predator.up or buff.apex_predators_craving.up then return 0 end
            -- Support true/false or 1/0 through this awkward transition.
            if args.max_energy and ( type( args.max_energy ) == 'boolean' or args.max_energy > 0 ) then return 50 * ( buff.incarnation.up and 0.8 or 1 ) * ( talent.relentless_predator.enabled and 0.8 or 1 ) end
            return max( 25, min( 50 * ( buff.incarnation.up and 0.8 or 1 ), energy.current ) ) * ( talent.relentless_predator.enabled and 0.6 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,
        form = "cat_form",

        cycle = "rip",
        cycle_to = true,

        -- Use maximum damage.
        damage = function () -- TODO: Taste For Blood soulbind conduit
            return calculate_damage( 1.05 * 2 , true, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1 ) * ( talent.sabertooth.enabled and 1.15 or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 ) * ( talent.lions_strength.enabled and 1.15 or 1 ) *
                ( 1 + 0.05 * talent.taste_for_blood.rank * ( ( debuff.rip.up and 1 or 0 ) + ( debuff.tear.up and 1 or 0 ) + ( debuff.thrash_cat.up and 1 or 0 ) + ( debuff.sickle_of_the_lion.up and 1 or 0 ) ) )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.ferocious_bite.spend ) end,

        usable = function () return buff.apex_predator.up or buff.apex_predators_craving.up or combo_points.current > 0 end,

        handler = function ()
            if talent.sabertooth.enabled and debuff.rip.up then
                debuff.rip.expires = debuff.rip.expires + ( 4 * combo_points.current )
            end

            if pvptalent.ferocious_wound.enabled and combo_points.current >= 5 then
                applyDebuff( "target", "ferocious_wound", nil, min( 2, debuff.ferocious_wound.stack + 1 ) )
            end

            if buff.apex_predator.up or buff.apex_predators_craving.up then
                applyBuff( "predatory_swiftness" )
                removeBuff( "apex_predator" )
                removeBuff( "apex_predators_craving" )
            else
                spend( min( 5, combo_points.current ), "combo_points" )
            end

            removeStack( "bloodtalons" )

            if buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end

            if talent.sabertooth.enabled then applyDebuff( "target", "sabertooth" ) end

            opener_done = true
        end,

        copy = "ferocious_bite_max"
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

    -- Talent: An improved Cat Form that grants all of your known Berserk effects and lasts $d. You may shapeshift in and out of this improved Cat Form for its duration. During Incarnation:    Energy cost of all Cat Form abilities is reduced by $s3%, and Prowl can be used once while in combat.$?s343223[    Finishing moves have a $s1% chance per combo point spent to refund $343216s1 combo $lpoint:points;.    Rake and Shred deal damage as though you were stealthed.][]
    incarnation = {
        id = 102543,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
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
            setCooldown( "prowl", 0 )
            applyBuff( "overflowing_power", nil, 0 )
            energy.max = energy.max + 50
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

        spend = function () return 30 * ( buff.incarnation.up and 0.8 or 1 ) end,
        spendType = "energy",

        talent = "maim",
        startsCombat = false,
        form = "cat_form",

        usable = function () return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            applyDebuff( "target", "maim", combo_points.current )
            spend( combo_points.current, "combo_points" )

            removeBuff( "iron_jaws" )

            if buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end

            opener_done = true
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

        spend = function () return 30 * ( buff.incarnation.up and 0.8 or 1 ) end,
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
            gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1, "combo_points" )
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

        spend = function () return 20 * ( buff.incarnation.up and 0.8 or 1 ) end,
        spendType = "energy",

        talent = "primal_wrath",
        startsCombat = true,

        aura = "rip",

        apply_duration = function ()
            return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 2 + 2 * combo_points.current ) * haste
        end,

        max_apply_duration = function ()
            return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 12 ) * haste
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
            if talent.tear_open_wounds.enabled and debuff.rip.up then
                debuff.rip.expires = debuff.rip.expires - 4
            end
            applyDebuff( "target", "rip", action.primal_wrath.apply_duration )
            active_dot.rip = active_enemies

            spend( combo_points.current, "combo_points" )
            removeStack( "bloodtalons" )

            if buff.eye_of_fearful_symmetry.up then
                gain( 2, "combo_points" )
                removeStack( "eye_of_fearful_symmetry" )
            end

            if talent.rip_and_tear.enabled then applyDebuff( "target", "tear" ) end

            opener_done = true
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
            return 35 * ( buff.incarnation.up and 0.8 or 1 ), "energy"
        end,
        spendType = "energy",

        talent = "rake",
        startsCombat = true,

        cycle = "rake",
        min_ttd = 6,

        damage = function ()
            return calculate_damage( 0.16, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.infected_wounds.enabled and 1.3 or 1 )
        end,
        tick_damage = function ()
            return calculate_damage( 0.2311, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.infected_wounds.enabled and 1.3 or 1 )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.2311, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.infected_wounds.enabled and 1.3 or 1 )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.rake.spend ) end,

        form = "cat_form",

        handler = function ()
            applyDebuff( "target", "rake" )
            debuff.rake.pmultiplier = persistent_multiplier
            removeBuff( "sudden_ambush" )

            if talent.doubleclawed_rake.enabled and active_dot.rake < true_active_enemies then active_dot.rake = active_dot.rake + 1 end
            if talent.infected_wounds.enabled then applyDebuff( "target", "infected_wounds" ) end

            gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1, "combo_points" )

            if talent.bloodtalons.enabled then
                applyBuff( "bt_rake" )
                check_bloodtalons()
            end

            if buff.bs_inc.up and talent.berserk_frenzy.enabled then applyDebuff( "target", "frenzied_assault" ) end
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
            health.actual = min( health.max, health.actual + ( 0.3 * health.max ) )
        end,
    },

    -- Talent: Finishing move that causes Bleed damage over time. Lasts longer per combo point.       1 point  : ${$o1*2} over ${$d*2} sec     2 points: ${$o1*3} over ${$d*3} sec     3 points: ${$o1*4} over ${$d*4} sec     4 points: ${$o1*5} over ${$d*5} sec     5 points: ${$o1*6} over ${$d*6} sec
    rip = {
        id = 1079,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return 30 * ( buff.incarnation.up and 0.8 or 1 ) end,
        spendType = "energy",

        talent = "rip",
        startsCombat = true,

        aura = "rip",
        cycle = "rip",
        min_ttd = 9.6,

        tick_damage = function ()
            return ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * calculate_damage( 0.0915, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 ) * ( talent.lions_strength.enabled and 1.15 or 1 )
        end,
        tick_dmg = function ()
            return ( talent.dreadful_bleeding.enabled and 1.2 or 1 ) * calculate_damage( 0.0915, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 ) * ( talent.lions_strength.enabled and 1.15 or 1 )
        end,

        form = "cat_form",

        apply_duration = function ()
            return ( talent.veinripper.enabled and 1.25 or 1 ) * mod_circle_dot( 4 + 4 * combo_points.current ) * haste
        end,

        usable = function ()
            if combo_points.current == 0 then return false, "no combo points" end
            --[[ if settings.hold_bleed_pct > 0 then
                local limit = settings.hold_bleed_pct * debuff.rip.duration
                if target.time_to_die < limit then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. limit .. ")" end
            end ]]
            return true
        end,

        handler = function ()
            applyDebuff( "target", "rip" )
            debuff.rip.pmultiplier = persistent_multiplier
            spend( combo_points.current, "combo_points" )

            removeStack( "bloodtalons" )

            if buff.eye_of_fearful_symmetry.up then gain( 2, "combo_points" ) end
            if talent.rip_and_tear.enabled then applyDebuff( "target", "tear" ) end

            opener_done = true
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
            return 40 * ( buff.incarnation.up and 0.8 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,
        form = "cat_form",

        damage = function ()
            return calculate_damage( 0.6837, false, true, ( talent.pouncing_strikes.enabled and effective_stealth and class.auras.prowl.multiplier or 1 ) * ( talent.merciless_claws.enabled and bleeding and 1.2 or 1 ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.berserk.enabled and buff.bs_inc.up and class.auras.berserk.multiplier or 1 ) )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 1, class.abilities.shred.spend ) end,

        handler = function ()
            removeBuff( "sudden_ambush" )
            gain( 1 + ( talent.berserk.enabled and buff.bs_inc.up and 1 or 0 ) + ( talent.pouncing_strikes.enabled and buff.prowl.up and 1 or 0 ), "combo_points" )

            if talent.bloodtalons.enabled then
                applyBuff( "bt_shred" )
                check_bloodtalons()
            end

            if talent.cats_curiosity.enabled and buff.clearcasting.up then
                gain( 40 * 0.25, "energy" )
            end
            if talent.dire_fixation.enabled then
                active_dot.dire_fixation = 0
                applyDebuff( "target", "dire_fixation" )
            end
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
        form = "moonkin_form",

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
            return max( 0, ( 35 * ( buff.incarnation.up and 0.8 or 1 ) ) + buff.scent_of_blood.v1 )
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
            gain( talent.berserk.enabled and 2 or 1, "combo_points" )

            if talent.bloodtalons.enabled then
                applyBuff( "bt_swipe_cat" )
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
            return 40 * ( buff.incarnation.up and 0.8 or 1 )
        end,
        spendType = "energy",

        talent = "thrash",
        startsCombat = false,

        aura = "thrash_cat",
        cycle = "thrash_cat",

        damage = function ()
            return calculate_damage( 0.098, true ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 )
        end,
        tick_damage = function ()
            return calculate_damage( 0.0624, true ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 )
        end,
        tick_dmg = function ()
            return calculate_damage( 0.0624, true ) * ( talent.moment_of_clarity.enabled and buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 ) * ( talent.wild_slashes.enabled and 1.2 or 1 )
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

            if target.within8 then
                gain( talent.berserk.enabled and buff.bs_inc.up and 2 or 1, "combo_points" )
            end

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
            if azerite.jungle_fury.enabled then applyBuff( "jungle_fury" ) end
            if talent.tigers_tenacity.enabled then addStack( "tigers_tenacity", nil, 3 ) end

            if legendary.eye_of_fearful_symmetry.enabled then
                applyBuff( "eye_of_fearful_symmetry", nil, 2 )
            end
        end,
    },
} )


--[[ spec:RegisterSetting( "owlweave_cat", false, {
    name = "|T136036:0|t Attempt Owlweaving (Experimental)",
    desc = "If checked, the addon will swap to Moonkin Form based on the default priority.",
    type = "toggle",
    width = "full"
} ) ]]

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
} )

spec:RegisterStateExpr( "funneling", function()
    return settings.use_funnel and talent.taste_for_blood.enabled and talent.relentless_predator.enabled and not talent.tear_open_wounds.enabled
end )

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
end )

spec:RegisterSetting( "lazy_swipe", false, {
    name = strformat( "%s: Don't %s in AOE", Hekili:GetSpellLinkWithTexture( spec.talents.wild_slashes[2] ), Hekili:GetSpellLinkWithTexture( spec.abilities.shred.id ) ),
    desc = function()
        return strformat( "If checked, when %s is talented, the use of %s will be minimized in multi-target situations even if "
            .. "%s is talented.\n\nThis option is a DPS loss but can be easier to execute correctly.",
            Hekili:GetSpellLinkWithTexture( spec.talents.wild_slashes[2] ), Hekili:GetSpellLinkWithTexture( spec.abilities.shred.id ),
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
        .. "This recommendation generally occurs at very low energy, regardless of your current health.", Hekili:GetSpellLinkWithTexture( spec.abilities.regrowth.id ) ),
    type = "toggle",
    width = "full",
} )

spec:RegisterVariable( "regrowth", function()
    return settings.regrowth ~= false
end )

spec:RegisterStateExpr( "filler_regrowth", function()
    return settings.regrowth ~= false
end )

spec:RegisterSetting( "rip_duration", 9, {
    name = strformat( "%s Duration", Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ) ),
    desc = strformat( "If set above 0, %s will not be recommended if the target will die within the timeframe specified.",
    Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ) ),
    type = "range",
    min = 0,
    max = 18,
    step = 0.1,
    width = "full",
} )

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

spec:RegisterSetting( "solo_prowl", false, {
    name = strformat( "Solo %s in Combat", Hekili:GetSpellLinkWithTexture( spec.abilities.prowl.id ) ),
    desc = strformat( "If checked, %s can be recommended in combat when %s is active when you are solo.\n\n"
        .. "This option is off by default because %s may cause you to drop combat outside of a group/encounter sitation.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.prowl.id ), Hekili:GetSpellLinkWithTexture( spec.auras.jungle_stalker.id ), spec.abilities.prowl.name ),
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "allow_shadowmeld", nil, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( spec.auras.shadowmeld.id ) ),
    desc = strformat( "If checked, %s can be recommended for |W%s|w players if its conditions for use are met.\n\n"
            .. "Your stealth-based abilities can be used in |W%s|w, even if your action bar does not change. |W%s|w can only be recommended in boss fights or when you "
            .. "are in a group (to avoid resetting combat).", Hekili:GetSpellLinkWithTexture( spec.auras.shadowmeld.id ), C_CreatureInfo.GetRaceInfo(4).raceName,
            spec.auras.shadowmeld.name, spec.auras.shadowmeld.name ),
    type = "toggle",
    width = "full",
    get = function () return not Hekili.DB.profile.specs[ 103 ].abilities.shadowmeld.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 103 ].abilities.shadowmeld.disabled = not val
    end,
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageDots = false,
    damageExpiration = 3,

    potion = "spectral_agility",

    package = "Feral"
} )


spec:RegisterPack( "Feral", 20230826, [[Hekili:T31EZnUrY9plSCziYSsu8HOwT(ezsSVCv8w23TLLVY)rQiiiGHuiliacEiUYLk(zpDppaMzWmaGuA39YDxzx2IeaZ0VMU)190d4TtV9xV9MaVcYT)5ztMnFYvZUC805x82lU82BkEkLC7nPE(F0Bd8hXEBH)7FIK5fHF7trjEb4tNNuM5dx52BUVmmQ4hJV9EZd5IBVXRS4HKSBV5MWT)WT38qyqaHD7KC)BVbV9ZMC1zZU872F3phgNKT)U0SWKSWIN2FxzkoO5J3)(9VNDNV9SPVdUZ939djXpsYk2FhoU7V7rVSqV7Ji57VlmUiz)D5Pe)93LKweMedF5WFY73Hb8MDHPKt3F3Vq2KLSR4b4pjf(JhPodlOZWVUJ49X939JX(EzXE44S)Upapveqx5G4r6zwC2m2Z8xPeSmlG0szo8v)sy6(7(JLz8rYloy)DGKnXpmPeiWVpeFU1LXXeycYjffHXBYvNJjY01j78clobO)4ImyEwtLCE55HpsqPZ27Hj(djGWy)DBiXe28QmEC(u(EbcX3lgLH(zepKStaPmWfHBH)oOmdikGwjz5KSpQoyxqhSF27JWn(Fs8qvtYA4jFa(8VfgfGSCCcqP4ibkkvEB6u2JZSa46DM0BDyCy(divqLz(jjrbj7InPfMCfDu(rK63ccgViPXADwYwM5I6ZCPHzw9oMtVJFHKxKKbe)2qqkJYbVeIlUaiGsC(mfBuyEHPhxyA4TXlm2c1m)SzVLPJH5QlsFM4M)3d(FkXBNz8qPSkRUp8BGYKPgqs3Js)LrfHPrWFvgFgywMsaXAHx2gsrU64VOIyy8BTbkBHfSUcwNHALF4dW3fBWIomoVG4fWmg(qw4wuN8BG14dmcJUSyxs8jid4fHd961JujJPsSjsRC7pqwNSj0NXTPzKhjOX(6mc53bY9CswwsMkdXT4)q1QZDHrrCjLWmdOCpyyU4nnwzS7bcWH)eW3NaF6MIms8gkBGgQErWStcofnqJZbBakXSleVHiulYCvvgrxh(dzERRvWJV9g0QjhDTkztbF8ptDwtIrxBb3(9WLPwzGF3SsykDZJ8YF42B8FYpI4YvH4dDJpWFeWLi8x81lJLFKXRlJICZi(pGpJlB591axV)UNFwymmg)A3Ie3Gq2vxW8ANfMYicVhtcXvKEPPu7J7rHhBiZpLVCfT1P(a4Qh0mWliaVoOOXakvpctCHpa67bMGciCIg)xZxzeqtN)aEL935awIW8xUE9yqs4L57rnzhddKFbJNgsJjaCTWsV4Hmqs46JA7v7VB6K(DFlOZ2aHkFCqsjqcU(rE7ibUzG)VXC6D)DJO)RYTZgnG2OprU09wRCRNruem3QiGD)JPZjWPbpjMlQGiVed166T9(sqHxMkKsbjfIhrscISE1vs5UicrhBGIF64lK4e6ONIrcfJQ4l9sjFYfwjcw1Wspx)mVhrTqzAnVbZhynULefG82fwmVLUlvtoW(ih9XgtqZgI)hZL8VHlDX4cPBY8cim(c5NxOmRDXYXlta(FHf(Nt1TSS2o5Mc(Wy(FCLP3vMzen5BCsb1ppmiRj4sN8KOs8sNISd85WIAbFuYoQFTa8H4aqIdiBd9phD6hH((YJ9sZFGEdHz5ud6l)QZ0mZDj7FDhBupxR14q0YdIsG4hLLcuVBaEdiSo1liCV5CNFCUGkr3MCpZbxckgniFgsL9XeFaBeGMncSmNHdcJggHsU32hVH28JCfn8IX4h1djCFVZI6jQm2lZfINNgYat2UUs3)SQt1CeioZNQHali8zjPhlkA(oVmafuabTc42BBtsIb7kcs3tNiZGvtGg3n1wevtSxfZGgrI5ASISUHiaNd9Ow1U1a)aTl2Ae(rvsvfGMf7bih31HFIHTxoStx(0gqdfiYAACeKDKlDMOxLp8a6OaMjcrnqLIYcxNSdEUh8WmpOyaOg)G58dmybqYm0KisqSc5fNwT0dx8GMOa6aVm0GxG8Qs1xgJPkaA9WmkgTpXtFsgZfvKpxw5lz4RO9HpkG5zcCLIwyGcG66qNPumSU7qiSJ1nYRJZ7hMHk5K1UrHRjUGeXfcjbpISwse0vBmrxj5u19LvyseWhabLBcG52DxszCGKAXi2fjJNvuJhfAmZBl4WUWDnf0EXt6axgzyHRmPYWnjBXOWicjBLAr(QMa3vfiimTdKEdADgzcdRsILuIEeNUBI0DLu(3aP4guA1FNb4zvmlG7gqylkvsn7mqKRimRBGWwURlZEsclsBOgqG8GnCsMBm5tfCkWgiQ1ICXCVhM7EezTLjvsWtV17ZbxL(uVjCdp9VwXsdKcr4AbiwPlq9q8mvBTBVzR3NCXYuS5joxzdAudUsErRbIOFuaYeDbH1G2hCOiNVr7ovS7SWssb2IKBpPO2w9p1uWXwZVqD0KHmqhWzwGtimj1I6P5iULKC1mlBMrhmMfzH(0fa1EnkHGC0)2fZMMLtTlReMkkPwLGhw6Y2La)JuwBwmXLDm8QaAFKwUcT4LOv0CDcGZwgkY4kErRRnnPVTN4ZVQNRx1w9RJKWm4oUXgfJTg8sHV(b9a(5il(AExp8lWkUNj)cDhcWhRyNBkVGDlfvRHAofMwdTceixrVsfc4FhMt6WTJqXX2wglmNPM0H6(v0YQjXhwouWsTCY5tX0a98)i7Zlo)sS2H0koYyGAg23diefFBDYYdQx7HLWFnKfjAhMcjtMnMpTxVuaFdh7hjU3x4c(v3SHwfu4IZQbKCFussaO3tIZ1E8rkEARWxBWhOAAd0nBOmldSKOq)3FhRY4yAcScA7Nexewc6z860D5GvP3kXymTg8TjNKIt0Z1jkCJex3gslQBvn(Bts1wrjY1h)al51m62KiY9)SZGCnWnzJw96yCJQyv4kKVfiqsiBdJzBFaWZKGneAQu06R)ys0J0CuWb(Ec9pXqDKaPQVhusyd1dHBO7LcMITgQ0k8tfSYyY9sB32yKWFXxZqA1HMedDviCQm1LjsvsR6Il6xaq042qqMxdP2xtr2Rdka9GKVgsLHkvL7ZbecJOi0RRMwekv)wWcqC7)qYJ5c50939usPWPvT7j2(fHlytsttYkkJP75eeXjNKRL4IDbJAuBlHCz6rRHTRYLxOtOmglBYwru0J4cfUkiLzzOAdvSETfpWzQQeCQZstWEvLd84Nlg2T6KF7evNkEIycjWfTcSyvZhlfzxnckBz(1O6Lwa12UKXwDxubDQy1hW2HwekHVx6E9T6JU1aFKqszLg37rVWigVslt79fDNIv1Masdc3OKEMblc(Xq8Aws9U6zlzfj(gmQQRpmmx8VSXpGnebK1EGdIQNV6H(iMZ39nXFpt5UsskEGODhwljKbyc)hFI4xsJvtazlcXHMCjDtfGNdLEikGkj64BTxXdMTk16IoiGn9eB((BppoXDdMDy1s2Qegq8LMcnMa3xoPO(MfliW)kQe(FcdFj8KYlGAfSjD44qZ4lWmfjQBIO1AdkplErHBIDNdOVaLuUPyfDpzRbixqyqPCpQwbaiCFm5JeAvPW1OaO4AGkVz)DZf(pQJaagKEB9Ij5UBkdd8I9jkYpTj7A6J2757YjIGf8Wod(YmVtNvnXJKf)GNHc(ZAkq1Xi7bYA(e6KktG8vqv345iWPlLICQOd45O6(a2NtIQkgPhr2Oi5Dh6CBsx8cM)PxXiaRZUfTaMFC7rW50MjvDfvPw)GwVvhL6nlxQCrHiyLlEm4ap0pKL92LlKfywAJLPSmKR2abgKxZrFRNwJykuaskjlouyPo1WCRbNxvtATuCgzU2dTGnGfoaM9j1KmKozjayW9XWnHrgHfu)8RdJIizGPeRRjP07d0KAhN6Z2yYlLgAiHlYoVO6G4TzVugFFwyaCvx6g8QyayFNqRQCbkp9c8sPi6OJaUQiQkSHyxVSDFYUgKkNR6TIX84XR)3sJ8EIvEJP2khqJhwoGnZO2a5eaUx3qaRv)psZHxKvN5BtEzTC6t2FIAjYCjqb88qn)iHXURJqViTE3Y3wR7QMCLPmcuUhPhw79WQHtF28pllHSvo5gA0w2kTEQbC6MrABfq1oVECItdj1MblhGeupv0VfvK1(QDAhBDpgJv1og5pKuIn379vPdZAv0iWXgmD0MDb75pSmLEfIUcmzDbjMvap1CPXIuLmE)D)kTpVcZPzDKxsZFgN)7FcFIT(SwfG5xdh(DG4N15Ra9Sb7R78er7DYAmbAL4iff4CXyqw(6yhLr192k6FZIkkVXs8WO0rWwzeKRdvtVbDMzFBP13RcY36cIvs7g(qEfORkN81vLGOX3pxcUU6MbxT9yylvABLMouojzLLA73vP6y0Fhl8vLx2BEGQcX5byTkWK8es8xWsoJcc7aQKLTYHPGuxfF24gH2QbRy7vWez1rZKt8Vvz)eQ8GV17t1JpEWdUTTDG4IAtdHQYfBpBqOhiAjxhJ43Uys7E9Qc7BJkP2DOacPyKh1bf1Cpi889jPf4nSxB)f4fWd(Rl8tZn7UIwFdp473sBED2wymCY4PNnz8SVv4QPat54I0rTPKAFlDAUgCPud9mSJeN7W2SBrU9n5zMDyJgxHmOPtdhdUxw0x7z1DOzwF7MbtHsBXRWHVqtUr(rcR7IT8AjrKMu77CbBXhZd)IMRxPDd46Iy8C6OTrbkTJb)AAjiiNka)BO1AdgDgoatvRtZXhlpi1c9U1ds6LNUlU)1vLJtAye1Tb0YpazWMw(7)o409(ejhyMUOHY2Ph6j(jrTWQLxvfitLqvsmxqPknfdVwG1tNOyA16yEv20R5Pi5FUEo3KSSs8RLxAND(WxQwlQvFrhXgl0JgoQcQwlYlJMns2bjyVO6yQ0kZxixNMkpFQ1pK6h1UbQb5FpjmRZNt7LA6APsmoqPFGzv8PcmKYv41TPIHnFrN(w)peP4CPcp1QaQLfPuLdssnl63mjNNH1hOZklhdsCbqjtigKBvHhsW0FEkPmdpOxygf3loEA(0pI3eF78lWdNIatqLGAiD3tOD))JH(Wx8imaEJUvPam6C00R4fisys2QgSP96S5SRy4bC6qJ)kOUPjgu0XoRB1OUQWyvrmBO2495NsoD3F8JF3M6ML99wOW3QgHX)2q8WlIbqwNbCwj4pda4Unb(2D5p)m8Wbeifj4IBWZ5kYQ2pBiMyL28KnZONmfM61YeOoCyIy9OTednmGgcHzi7AJ1awJTDARMvN1R9azKyFDnmmlBmHv5B3IIOoIIP(xtc0MEXXDAnt(H9bU5srvcR(xZUyuCmWWTr1KYRzy1d4nnyX3WTcWJK73I7kZekJXUDXxunZhFzsE1QrIwSGQdag4GFlRHUkXtPcTzqOhJECPlavhpE(0tmMqyX6lm6E8MwgfnMvfkSV)YWH(SvdrHWBuKxVz6KrF73cYKRXRr)RrS9gM3SCi1qlbg2nHanCcnFumhvp8O4qB6lQUHFGNVNSoHDOAOvULGNMeCbOEbj4EK8Id9D3KfswdPh4B8qhxdtVX9QL3Hws)0cHOC8Tak0fEKT5nH)kLWxxNHNdRzUTVaMTySEnRn8PQ3GQh3MjdpsXdOoIw7iXzpXxNwhRz32jeg0rqUBz02nlPVShTAgl9OotH4RLyqHTmlbE96cr5eB6ZHNwpPVHgA)i7YOdDRlhzwgyo9YooVZQqwEviV(tB27NrXau31C1JRPx3aoDuon9mvnGEtCd97ehiiq9Ew7OPqHHzXrCogS3nHhrE92RoUnzGspc2nNwp19RlcFDumhPOTLT43InA3AzL9u18HcPoBaRySC6cFLAWUk7(wA6Gkocj6AoQfk1svOA0dc214ga1Ghmr1V9M5MiZdWUJwm3cdnqqBmVnM7OobugjAl2C22x0J4WSlsCHHZQdZfPLpAg1TgJFGEE6h)jB)hvoz7FF2n77(KTloq7OEEXHEs2P4VBSnYnvBsUtm6rQOLnyLhQTRZcCd8mTT3QRAE2YBjnRw1bow0D66gwdcWFXxfc5UWZN6E67RdimxkaaWxiJxZZkd7XbmDmedoKGzg2rbIxGxIovM9p3GfHdNj2B0U3o9D4gFMHVIpYXzhZIBlMVg)bprkVKtWj6)TeKabyFiG5x4vwKS1J2cdqEhXBOVIX(jAvbNIVaY4Vo7WRFIb5ZjmBmtxsi6GBz40pnQEyVY8WQOy0gxJkT(oWhn9U)9MeNS64DGIYjMjnTGSAuNLqWDqG8(g)Wiqnrxsk)9YxoBZLprjJ)vdNp5ndTu7(VD64lhnYz4qot0zlH6Om2xp8DDn2JE(5Hdo2rF6vtEJLrhgzHcO)S75Fgz3Z)SZU1gOZnBGQ1cyAgOwAqSomqL2a6dZiD2NLfrCbGLb)115HqvCy8n6h(Vgl1SzIIqTV6L74)f(2F8Gkn))9FO6v0zqyoL47T3a0AxVyuxRy5508gwT4SIUQwnyRB4bxQm0WInS20Aw6lGvjAvJE1chkIb1Qq7muUIYxpdEo1QI5OC9LZH1jWuoWu1LF(zwrxevwggRwQp6Q66J6mSTaBowYM55Nh02J98ZwWbTAALJT)PM7q1CvkUVo6nQNKFCRyL)0P7vEHUIojOfLCDy9XRdFziX7NL3S8C9Et50W1lLQvifh97n9GcVmNIfAFPHT928J1OftQMqPgvHPFvAsfZJgLinFjXtJsi(1HVT(4XP8T0Jd3(3)n7V7GpyBYJdLCqgsX0djFW(hgNLGnYajPlK7N0tlOyCagOkbWB8BaQ7ApiTUmY6LN8qrrA(3D(572TB8UKDGynymW7NtnwwoDYKlNCo9TMWzHXRlXucoz1hWpJVNHzFX1N7rR)iU3X0TXNTD)ycPmwFhb3lg22(3)z(Y3Ty65cCWR4V0BzZf9DvC)hPzlUy(5s99WzGuhwgCwY6ZeUAozL0l6A2KqZ1TVtY8zZF7LxCoFD)zGA(m(U0(VsVHFojiCDijB5BV8Qtw9dSBRwWr7Z77jXe6gLTT0)H9836XpGVkdgZ0A1Q4q2Mbt(eKZAShyicAz2ciQUYvORKnleoOy3hFByoLEqXwka(18ujYwc1OXkVE5u7JTAdfWNclEFABCK8KYheveZ9z32FZ8AuZ2JROdOTxJ8Ltuqn)kp6tNbd)O2foydjyuY83TPoXwiayEXTWL(68gqXYoLgiMX)e71isU6B)(q2RbKgRIufOQVcConjDzgmlfT)q11OPNpGOJqLU96Bvcjc68MlcB5CcwhZVLBcaNyaNZZpRUx0RUCbQ3maCB6ch(KOFybvmpX6LDQsH1wof5cJBz1ktBxLZqLyAC0tk75QYmQCg(OcmGQxnrHOyNfp8IAnPRt9j476lvEg1tV0P8Z(2s(rFtsXOLyQJfxCGVsNwpNExFH1RlwqFrBeytz(WHd68i298ZDE86UEg4NOJd011ZbSimARRJrNL7R(ggzmTaNbd17EahCGuBG2LiToO9sgyfd8YPJOO2(h8dc2HzK1PHHt7AdBRxwnT3ACvyVQNkaM)wrOe57uULemV65yY)A0libSMjDQ855oQPGYYc4AiXrn2s6SJzIXy5hzRrlCgAD1rnRz60HaxL5Pw(0In6vujYbrCk7qOiXlQ4dwjD0WKhu8eBDAoXFPTJnfoEYxB5fo8irgp(woAroVyIntzWZVT58A(X0I535l9jXQBzU4qo1q2Sq14eKvdgAnjbJAC7sREqxsZcsAnmXg0w1Aw094lv3yf7n7oRAzLr3tNyQQYvVpuEfis4Py2IxpBHQjR6jyIlv0o7so6VydEp1y8Z8VRj1LzrsudmLCVVyY5vF7MXRVWurcLeGAZB9ghJZIulSWHJ2SbIayYQwd1dXQPtA7QawgricR)UPa5MnW8UkmYgludrgzboiR6odKR917xag0o9UbKbluhA(1thFHEnN4F0(zsgnMoQFXsEL5tBm0XWpFU)fcXgRBl7kZCC)Z5ITI)Vb)b)4lTG45NL7ETd1xrFCQrf1h8VTh2gzX1PeJb5HSJmBjMA1NyDZTCKZokHn9lgcdTZx7FYmS7Fbw2BmJaBsqASg7y(hzZLKe246sijqsiVLVwxhi97Yv9otik3wVYgqfvNJ(UJDLtfjQwAm75TXTWpS3ZZMi(dfsQacQL31ZwbIAf36OAy5VkVKM7ptkJVTx4pPu6)p41TSjrq1gDjsHOq8(Y1wfE6Dq)JeCJs1gDA9umC9fx0fKHrMyAvum9LZ)CZ49hfutoIgt(a4LHku2WxAO7r1fV7v4vtSzvggyadeyIHOLnVLcgnWwfJg5iKxsT4RHPxj1ioYxl(YmDSSmmIkXV7Aev7TBdJMkSOwhlPE31wAoonYPx1ErSZsgE3bBC9MoVQdh5L(Y9TpASwFP)UAQvBodX2REZx0cyyJitn88vHr6ictldXRSTPc11qcuhB0Wmp8LwHGrodTsOoADb0ZpRBLoAKncTkk3NBF4QbVu8fZwWDSE6vyNJml8JKNQO2MSZln6Sng02Qkv3qV4Own5OdLGEPKq)PGQaGndyXBYQgvjZEvETnjsHr6iHwtrtoyYWw8NgfVTd)o9X5MYa0sajZXC)slkpsbtBgj21cvBARPoDg7KelONCAdZLDNXkH8Qi0QZzMPCW7IVBTyinoaDlNlpZ9splxOMdIBokk2g1rbl9L)qH1U1wNfRz1IUkrJbR1xXQ2yDDPKyw(8X((VrSR)FgoDxhvagLyU2Qe2QlCmU73vcFzXJJbX4ifGE1L7v9N1q(M6l5LV5Mc3mgGPbUFi0nbEK3dA)L)4F57WQJekAEcQjp9DlcUHZvLd5pG1Kjjfl3vc7xtxr9pPVKuOpGh8bjQMNRQCJKjr5k)0Qst7UjgmlGTEXPA7inUSYeI9sOHDx0QC)Re6X(dfuDNguJw(kib5TWygjL4X014oHX85j2meS5JOVZA2fIwhvBfaVrEs8bPm2EVS173tAwcolMoF2wn1vafZjKAAFv6aUs)HMyzpymyr2RKGRlYJjObG95rDQmuWPOUpeY(dLvcnIICuIhTrSFYaRpUUZu1rq(QRMzNgAW1CxYVPhNseQ9AZJ9ZC8C)mWYR6Urh)uzzeDS1y0xpx)icH7PcyCy(ydn00x70N(g)6PZLBBCzgt6eqiKwp)SAFJpBHu7i9f518Orkv0VxHR16R9Pxb5DJAzJctvv)S5s1OrCtowe4Va59Kw5b0NkgI2IbdVmc1VSS62I8apbMhYSBZWRPWUxYMLwenSZdxn(Y6P30k4zkRGRiGxOg7BKAOH)(5fyNrXTbzHTUETrnr)NhAZ)g(422hNfAVlcnP4B0nRToU5YrOf7ipUOwQ9hPMtdwxghtWmEyG3v6pstyw8dZqAdCSffUM46fh4gqKAMYrm4(AJdZs5YA4za(xW7ykapFxsjUOOUusDN7AM32upaepR7jkEQgN2iTIZitg9SjqLfxGjDxqDh2EpxBVjAnTofB5FqvKJRLCdkzN0EZksL0lbFmUXKpXZiqKPP8QpwABTLELALOKMkTEublvgZyeMTdS91zfNyqJ4zAUbeIuG7IeNgn0nAEHje52jvt(p1MQUNjUNMwskTMuQ)P(erkZ(f98u(pONlz)EEIVJ69X3zBZPVcFU9)7p]] )