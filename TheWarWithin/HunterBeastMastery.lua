-- HunterBeastMastery.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR
local spec = Hekili:NewSpecialization( 253, true )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)

spec:RegisterResource( Enum.PowerType.Focus, {
    barbed_shot = {
        resource = "focus",
        aura = "barbed_shot",

        last = function ()
            local app = state.buff.barbed_shot.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 2 ) * 2
        end,

        interval = 2,
        value = 5,
    },

    barbed_shot_2 = {
        resource = "focus",
        aura = "barbed_shot_2",

        last = function ()
            local app = state.buff.barbed_shot_2.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 2 ) * 2
        end,

        interval = 2,
        value = 5,
    },

    barbed_shot_3 = {
        resource = "focus",
        aura = "barbed_shot_3",

        last = function ()
            local app = state.buff.barbed_shot_3.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 2 ) * 2
        end,

        interval = 2,
        value = 5,
    },

    barbed_shot_4 = {
        resource = "focus",
        aura = "barbed_shot_4",

        last = function ()
            local app = state.buff.barbed_shot_4.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 2 ) * 2
        end,

        interval = 2,
        value = 5,
    },

    barbed_shot_5 = {
        resource = "focus",
        aura = "barbed_shot_5",

        last = function ()
            local app = state.buff.barbed_shot_5.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 2 ) * 2
        end,

        interval = 2,
        value = 5,
    },

    barbed_shot_6 = {
        resource = "focus",
        aura = "barbed_shot_6",

        last = function ()
            local app = state.buff.barbed_shot_6.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 2 ) * 2
        end,

        interval = 2,
        value = 5,
    },

    barbed_shot_7 = {
        resource = "focus",
        aura = "barbed_shot_7",

        last = function ()
            local app = state.buff.barbed_shot_7.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 2 ) * 2
        end,

        interval = 2,
        value = 5,
    },

    barbed_shot_8 = {
        resource = "focus",
        aura = "barbed_shot_8",

        last = function ()
            local app = state.buff.barbed_shot_8.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 2 ) * 2
        end,

        interval = 2,
        value = 5,
    },

    death_chakram = {
        resource = "focus",
        aura = "death_chakram",

        last = function ()
            return state.buff.death_chakram.applied + floor( ( state.query_time - state.buff.death_chakram.applied ) / class.auras.death_chakram.tick_time ) * class.auras.death_chakram.tick_time
        end,

        interval = function () return class.auras.death_chakram.tick_time end,
        value = function () return state.conduit.necrotic_barrage.enabled and 5 or 3 end,
    }
} )

-- Talents
spec:RegisterTalents({

    -- Hunter
    binding_shackles               = { 102388,  321468, 1 }, -- Targets stunned by Binding Shot, knocked back by High Explosive Trap, knocked up by Implosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal $s1% less damage to you for $s2 sec after the effect ends
    binding_shot                   = { 102386,  109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within $s1 yds for $s2 sec, stunning them for $s3 sec if they move more than $s4 yds from the arrow. Targets stunned by Binding Shot deal $s5% less damage to you for $s6 sec after the effect ends
    blackrock_munitions            = { 102392,  462036, 1 }, -- The damage of Explosive Shot is increased by $s2%$s$s3 Pet damage bonus of Harmonize increased by $s4%
    born_to_be_wild                = { 102416,  266921, 1 }, -- The cooldown of Aspect of the Cheetah, and Aspect of the Turtle are reduced by $s1 sec
    bursting_shot                  = { 102421,  186387, 1 }, -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by $s2% for $s3 sec, and dealing $s$s4 Physical damage
    camouflage                     = { 102414,  199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for $s1 min. While camouflaged, you will heal for $s2% of maximum health every $s3 sec
    concussive_shot                = { 102407,    5116, 1 }, -- Dazes the target, slowing movement speed by $s1% for $s2 sec. Cobra Shot will increase the duration of Concussive Shot on the target by $s3 sec
    counter_shot                   = { 102292,  147362, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for $s1 sec
    deathblow                      = { 102410,  343248, 1 }, -- Kill Command has a $s1% chance to grant Deathblow.  Deathblow The cooldown of Black Arrow is reset. Your next Black Arrow can be used on any target, regardless of their current health
    devilsaur_tranquilizer         = { 102415,  459991, 1 }, -- If Tranquilizing Shot removes only an Enrage effect, its cooldown is reduced by $s1 sec
    disruptive_rounds              = { 102395,  343244, 1 }, -- When Tranquilizing Shot successfully dispels an effect or Counter Shot interrupts a cast, gain $s1 Focus
    emergency_salve                = { 102389,  459517, 1 }, -- Feign Death and Aspect of the Turtle removes poison and disease effects from you
    entrapment                     = { 102403,  393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for $s1 sec. Damage taken may break this root
    explosive_shot                 = { 102420,  212431, 1 }, -- Fires an explosive shot at your target. After $s2 sec, the shot will explode, dealing $s$s3 Fire damage to all enemies within $s4 yds. Deals reduced damage beyond $s5 targets
    ghillie_suit                   = { 102385,  459466, 1 }, -- You take $s1% reduced damage while Camouflage is active. This effect persists for $s2 sec after you leave Camouflage
    harmonize                      = { 102420, 1245926, 1 }, -- All pet damage dealt increased by $s1%
    high_explosive_trap            = { 102739,  236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $s$s2 Fire damage and knocking all enemies away. Limit $s3. Trap will exist for $s4 min. Targets knocked back by High Explosive Trap deal $s5% less damage to you for $s6 sec after being knocked back
    hunters_avoidance              = { 102423,  384799, 1 }, -- Damage taken from area of effect attacks reduced by $s1%
    implosive_trap                 = { 102739,  462031, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $s$s2 Fire damage and knocking all enemies up. Limit $s3. Trap will exist for $s4 min. Targets knocked up by Implosive Trap deal $s5% less damage to you for $s6 sec after being knocked up
    improved_traps                 = { 102418,  343247, 1 }, -- The cooldown of Tar Trap, High Explosive Trap, Implosive Trap, and Freezing Trap is reduced by $s1 sec
    intimidation                   = { 102397,   19577, 1 }, -- Commands your pet to intimidate the target, stunning it for $s1 sec. Targets stunned by Intimidation deal $s2% less damage to you for $s3 sec after the effect ends
    keen_eyesight                  = { 102409,  378004, 2 }, -- Critical strike chance increased by $s1%
    kill_shot                      = { 102378,   53351, 1 }, -- You attempt to finish off a wounded target, dealing $s$s2 Physical damage. Only usable on enemies with less than $s3% health
    kindling_flare                 = { 102425,  459506, 1 }, -- Flare's radius is increased by $s1%
    kodo_tranquilizer              = { 102415,  459983, 1 }, -- Tranquilizing Shot removes up to $s1 additional Magic effect from up to $s2 nearby targets
    lone_survivor                  = { 102391,  388039, 1 }, -- The cooldown of Survival of the Fittest is reduced by $s1 sec, and its duration is increased by $s2 sec. The cooldown of Counter Shot is reduced by $s3 sec
    misdirection                   = { 102419,   34477, 1 }, -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within $s1 sec and lasting for $s2 sec
    moment_of_opportunity          = { 102426,  459488, 1 }, -- When a trap triggers, you gain $s1% movement speed for $s2 sec
    natural_mending                = { 102401,  270581, 1 }, -- Every $s1 Focus you spend reduces the remaining cooldown on Exhilaration by $s2 sec
    no_hard_feelings               = { 102412,  459546, 1 }, -- When Misdirection targets your pet, it reduces the damage they take by $s1% for $s2 sec. The cooldown of Misdirection is reduced by $s3 sec
    padded_armor                   = { 102406,  459450, 1 }, -- Survival of the Fittest gains an additional charge
    pathfinding                    = { 102404,  378002, 1 }, -- Movement speed increased by $s1%
    posthaste                      = { 102411,  109215, 1 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by $s1% for $s2 sec
    quick_load                     = { 102413,  378771, 1 }, -- When you fall below $s1% health, Bursting Shot and Scatter Shot have their cooldown immediately reset. This can only occur once every $s2 sec
    rejuvenating_wind              = { 102381,  385539, 1 }, -- Maximum health increased by $s1%, and Exhilaration now also heals you for an additional $s2% of your maximum health over $s3 sec
    roar_of_sacrifice              = { 102405,   53480, 1 }, -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but $s1% of all damage taken by that target is also taken by the pet. Lasts $s2 sec
    scare_beast                    = { 102382,    1513, 1 }, -- Scares a beast, causing it to run in fear for up to $s1 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time
    scatter_shot                   = { 102421,  213691, 1 }, -- A short-range shot that deals $s2 damage, removes all harmful damage over time effects, and incapacitates the target for $s3 sec$s$s4 Any damage caused will remove the effect. Turns off your attack when used. Targets incapacitated by Scatter Shot deal $s5% less damage to you for $s6 sec after the effect ends
    scouts_instincts               = { 102424,  459455, 1 }, -- You cannot be slowed below $s1% of your normal movement speed while Aspect of the Cheetah is active
    scrappy                        = { 102408,  459533, 1 }, -- Casting Kill Command reduces the cooldown of Intimidation and Binding Shot by $s1 sec
    serrated_tips                  = { 102384,  459502, 1 }, -- You gain $s1% more critical strike from critical strike sources
    specialized_arsenal            = { 102390,  459542, 1 }, -- Kill Command deals $s1% increased damage
    survival_of_the_fittest        = { 102422,  264735, 1 }, -- Reduces all damage you and your pet take by $s1% for $s2 sec
    tar_trap                       = { 102393,  187698, 1 }, -- Hurls a tar trap to the target location that creates a $s1 yd radius pool of tar around itself for $s2 sec when the first enemy approaches. All enemies have $s3% reduced movement speed while in the area of effect. Limit $s4. Trap will exist for $s5 min
    tarcoated_bindings             = { 102417,  459460, 1 }, -- Binding Shot's stun duration is increased by $s1 sec
    territorial_instincts          = { 102394,  459507, 1 }, -- The cooldown of Intimidation is reduced by $s1 sec
    trailblazer                    = { 102400,  199921, 1 }, -- Your movement speed is increased by $s1% anytime you have not attacked for $s2 sec
    tranquilizing_shot             = { 102380,   19801, 1 }, -- Removes $s1 Enrage and $s2 Magic effect from an enemy target. Successfully dispelling an effect generates $s3 Focus
    trigger_finger                 = { 102396,  459534, 2 }, -- You and your pet have $s1% increased attack speed. This effect is increased by $s2% if you do not have an active pet
    unnatural_causes               = { 102387,  459527, 1 }, -- Your damage over time effects deal $s1% increased damage. This effect is increased by $s2% on targets below $s3% health
    wilderness_medicine            = { 102383,  343242, 1 }, -- Natural Mending now reduces the cooldown of Exhilaration by an additional $s1 sec Mend Pet heals for an additional $s2% of your pet's health over its duration, and has a $s3% chance to dispel a magic effect each time it heals your pet

    -- Beast Mastery
    alpha_predator                 = { 102368,  269737, 1 }, -- Kill Command now has $s1 charges, and deals $s2% increased damage
    animal_companion               = { 102361,  267116, 1 }, -- Your Call Pet additionally summons the pet from the bonus slot in your stable. This pet will obey your Kill Command, but cannot use pet family abilities
    aspect_of_the_beast            = { 102351,  191384, 1 }, -- Increases the damage and healing of your pet's abilities by $s1%. Increases the effectiveness of your pet's Predator's Thirst, Endurance Training, and Pathfinding s by $s2%
    barbed_scales                  = { 102353,  469880, 1 }, -- Casting Cobra Shot reduces the cooldown of Barbed Shot by $s1 sec
    barbed_shot                    = { 102377,  217200, 1 }, -- Fire a shot that tears through your enemy, causing them to bleed for $s1 damage over $s2 sec and increases your critical strike chance by $s3% for $s4 sec, stacking up to $s5 times. Sends your pet into a frenzy, increasing attack speed by $s6% for $s7 sec, stacking up to $s8 times. Generates $s9 Focus over $s10 sec
    barbed_wrath                   = { 102373,  231548, 1 }, -- Barbed Shot reduces the cooldown of Bestial Wrath by $s1 sec
    beast_cleave                   = { 102341,  115939, 1 }, -- After you Multi-Shot, your pet's melee attacks also strike all nearby enemies for $s1% of the damage and Kill Command strikes all nearby enemies for $s2% of the damage for the next $s3 sec. Deals reduced damage beyond $s4 targets
    bestial_wrath                  = { 102340,   19574, 1 }, -- Sends you and your pet into a rage, instantly dealing $s$s2 Physical damage to its target, and increasing all damage you both deal by $s3% for $s4 sec. Removes all crowd control effects from your pet. Bestial Wrath's remaining cooldown is reduced by $s5 sec each time you use Barbed Shot
    bloodshed                      = { 102362,  321530, 1 }, -- Command your pets to tear into your target, causing your target to bleed for $s1 million over $s2 sec. Damage from Bloodshed has an increased chance to summon Dire Beasts
    bloody_frenzy                  = { 102339,  407412, 1 }, -- While Call of the Wild is active, your pets have the effects of Beast Cleave, and each time Call of the Wild summons a pet, all of your pets Stomp
    brutal_companion               = { 102350,  386870, 1 }, -- When Barbed Shot causes Frenzy to stack up to $s1, your pet will immediately use its special attack and deal $s2% bonus damage
    call_of_the_wild               = { 102336,  359844, 1 }, -- You sound the call of the wild, summoning $s1 of your active pets for $s2 sec. During this time, a random pet from your stable will appear every $s3 sec to assault your target for $s4 sec. Each time Call of the Wild summons a pet, the cooldown of Barbed Shot and Kill Command are reduced by $s5%
    cobra_senses                   = { 102344,  378244, 1 }, -- Cobra Shot Focus cost reduced by $s1. Cobra Shot damage increased by $s2%
    cobra_shot                     = { 102354,  193455, 1 }, -- A quick shot causing $s$s2 Physical damage. Reduces the cooldown of Kill Command by $s3 sec
    dire_beast                     = { 102376,  120679, 1 }, -- Damage from your bleed effects has a $s1% chance of attracting a powerful wild beast that attacks your target for $s2 sec
    dire_cleave                    = { 102337, 1217524, 1 }, -- When summoned, Dire Beasts gain Beast Cleave at $s1% effectiveness for $s2 sec
    dire_command                   = { 102365,  378743, 1 }, -- Kill Command has a $s1% chance to also summon a Dire Beast to attack your target for $s2 sec
    dire_frenzy                    = { 102367,  385810, 2 }, -- Dire Beast lasts an additional $s1 sec and deals $s2% increased damage
    go_for_the_throat              = { 102357,  459550, 1 }, -- Kill Command deals increased critical strike damage equal to $s1% of your critical strike chance
    hunters_prey                   = { 102360,  378210, 1 }, -- Black Arrow deals $s1% increased damage for each of your active pets. Stacks up to $s2 times
    huntmasters_call               = { 107286,  459730, 1 }, -- Summoning a Dire Beast $s2 times sounds the Horn of Valor, summoning either Hati or Fenryr to battle. Hati Increases the damage of all your pets by $s3%. Fenryr Pounces your primary target, inflicting a heavy bleed that deals $s$s4 million damage over $s5 sec and grants you $s6% Haste
    kill_cleave                    = { 102355,  378207, 1 }, -- While Beast Cleave is active, Kill Command now also strikes nearby enemies for $s1% of damage dealt. Deals reduced damage beyond $s2 targets
    kill_command                   = { 102346,   34026, 1 }, -- Give the command to kill, causing your pet to savagely deal $s$s2 Physical damage to the enemy
    killer_cobra                   = { 102375,  199532, 1 }, -- While Bestial Wrath is active, Cobra Shot resets the cooldown on Kill Command
    killer_instinct                = { 102364,  273887, 2 }, -- Kill Command deals $s1% increased damage
    laceration                     = { 102369,  459552, 1 }, -- When your pet attacks critically strike, they cause their target to bleed for $s1% of the damage dealt over $s2 sec
    master_handler                 = { 102359,  424558, 1 }, -- Each time Barbed Shot deals damage, the cooldown of Kill Command is reduced by $s1 sec
    multishot                      = { 102363,    2643, 1 }, -- Fires several missiles, hitting all nearby enemies within $s2 yds of your current target for $s$s3 Physical damage and triggering Beast Cleave. Deals reduced damage beyond $s4 targets
    pack_tactics                   = { 102374,  321014, 1 }, -- Focus generation increased by $s1%
    piercing_fangs                 = { 102371,  392053, 1 }, -- While Bestial Wrath is active, your pet's critical damage dealt is increased by $s1%
    poisoned_barbs                 = { 102358, 1217535, 1 }, -- Direct damage from Barbed Shot has a $s4% chance to explode on impact, applying Serpent Sting and dealing $s$s5 Nature damage to nearby enemies. Damage reduced beyond $s6 targets.  Serpent Sting Fire a shot that poisons your target, causing them to take $s$s9 Nature damage instantly and an additional $s$s10 Nature damage over $s11 sec
    savagery                       = { 102356,  424557, 1 }, -- Kill Command damage is increased by $s1%. Barbed Shot lasts $s2 sec longer
    scent_of_blood                 = { 102342,  193532, 2 }, -- Activating Bestial Wrath grants $s1 charge of Barbed Shot
    serpentine_rhythm              = { 102372,  468701, 1 }, -- Casting Cobra Shot increases its damage by $s1%. Stacks up to $s2 times. Upon reaching $s3 stacks, the bonus is removed and you gain $s4% increased pet damage for $s5 sec
    snakeskin_quiver               = { 102344,  468695, 1 }, -- Your auto shot has a $s1% chance to also fire a Cobra Shot at your target
    solitary_companion             = { 102361,  474746, 1 }, -- Your pet damage is increased by $s1% and your pet is $s2% larger
    stomp                          = { 102347,  199530, 1 }, -- When you cast Barbed Shot, your pet stomps the ground, dealing $s$s3 Physical damage to its primary target and $s$s4 Physical damage to all other nearby enemies
    thrill_of_the_hunt             = { 102345,  257944, 1 }, -- Barbed Shot increases your critical strike chance by $s1% for $s2 sec, stacking up to $s3 times
    thundering_hooves              = { 102370,  459693, 1 }, -- Casting Explosive Shot causes all active pets to Stomp at $s1% effectiveness
    training_expert                = { 102338,  378209, 1 }, -- All pet damage dealt increased by $s1%
    war_orders                     = { 102343,  393933, 1 }, -- Barbed Shot deals $s1% increased damage, and applying Barbed Shot has a $s2% chance to reset the cooldown of Kill Command
    wild_call                      = { 102348,  185789, 1 }, -- Your auto shot critical strikes have a $s1% chance to reset the cooldown of Barbed Shot
    wild_instincts                 = { 102339,  378442, 1 }, -- While Call of the Wild is active, each time you Kill Command, your Kill Command target takes $s1% increased damage from all of your pets, stacking up to $s2 times
    wildspeaker                    = { 107285, 1232739, 1 }, -- Dire Beasts will now obey your Kill Command, dealing its damage at $s1% effectiveness. Bestial Wrath now sends your Dire Beasts into a rage, increasing their damage dealt by $s2% for $s3 sec. Dire Beasts summoned during a Bestial Wrath will benefit at a reduced duration

    -- Dark Ranger
    banshees_mark                  = {  94957,  467902, 1 }, -- Black Arrow's initial damage has a $s2% chance to summon a flock of crows to attack your target, dealing $s$s3 Shadow damage over $s4 sec
    black_arrow                    = {  94987,  466932, 1 }, -- Your Kill Shot is replaced with Black Arrow.  Black Arrow You attempt to finish off a wounded target, dealing $s$s5 Shadow damage and $s$s6 Shadow damage over $s7 sec. Only usable on enemies above $s8% health or below $s9% health
    bleak_arrows                   = {  94961,  467749, 1 }, -- Your auto shot now deals Shadow damage, allowing it to bypass armor. Your auto shot has a $s1% chance to grant Deathblow.  Deathblow The cooldown of Black Arrow is reset. Your next Black Arrow can be used on any target, regardless of their current health
    bleak_powder                   = {  94974,  467911, 1 }, -- Black Arrow now explodes in a cloud of shadow and sulfur on impact, dealing $s$s2 Shadow damage to all enemies within an $s3 yd cone behind the target. Damage reduced beyond $s4 targets
    dark_chains                    = {  94960,  430712, 1 }, -- While in combat, Disengage will chain the closest target to the ground, causing them to move $s1% slower until they move $s2 yards away
    ebon_bowstring                 = {  94986,  467897, 1 }, -- Casting Black Arrow has a $s1% chance to grant Deathblow.  Deathblow The cooldown of Black Arrow is reset. Your next Black Arrow can be used on any target, regardless of their current health
    phantom_pain                   = {  94986,  467941, 1 }, -- When Kill Command deals damage, $s1% of the damage dealt is replicated to up to $s2 other units affected by Black Arrow's periodic damage
    shadow_dagger                  = {  94960,  467741, 1 }, -- While in combat, Disengage releases a fan of shadow daggers, dealing $s$s2 Shadow damage per second and reducing affected target's movement speed by $s3% for $s4 sec
    shadow_hounds                  = {  94983,  430707, 1 }, -- Each time Black Arrow deals damage, you have a small chance to manifest a Dark Hound that charges to your target and attacks nearby enemies for $s1 sec
    smoke_screen                   = {  94959,  430709, 1 }, -- Exhilaration grants you $s1 sec of Survival of the Fittest. Survival of the Fittest activates Exhilaration at $s2% effectiveness
    soul_drinker                   = {  94983,  469638, 1 }, -- Black Arrow damage increased by $s1%. Bleak Powder damage increased by $s2%
    the_bell_tolls                 = {  94968,  467644, 1 }, -- Firing a Black Arrow increases all damage dealt by you and your pets by $s1% for $s2 sec. Multiple instances of this effect may overlap
    umbral_reach                   = {  94982, 1235397, 1 }, -- Black Arrow periodic damage increased by $s1% and Bleak Powder now applies Black Arrow's periodic effect to all enemies it damages. If Bleak Powder damages $s2 or more enemies, gain Beast Cleave if talented
    withering_fire                 = {  94993,  466990, 1 }, -- While Call of the Wild is active, you surrender to darkness, granting you Withering Fire and Deathblow every $s1 sec.  Withering Fire Casting Black Arrow fires a barrage of $s4 additional Black Arrows at nearby targets at $s5% effectiveness, prioritizing enemies that aren't affected by Black Arrow's damage over time effect

    -- Pack Leader
    better_together                = {  94962,  472357, 1 }, -- Damage dealt by your pets is increased by $s1%. Frenzy's attack speed bonus is increased by $s2%
    dire_summons                   = {  94992,  472352, 1 }, -- Kill Command reduces the cooldown of Howl of the Pack Leader by $s1 sec. Cobra Shot reduces the cooldown of Howl of the Pack Leader by $s2 sec
    envenomed_fangs                = {  94972,  472524, 1 }, -- Initial damage from your Bear will consume Serpent Sting from up to $s1 nearby targets, dealing $s2% of its remaining damage instantly
    fury_of_the_wyvern             = {  94984,  472550, 1 }, -- Your pet's attacks increase your Wyvern's damage bonus by $s1%, up to $s2%. Casting Kill Command extends the duration of your Wyvern by $s3 sec, up to $s4 additional sec
    hogstrider                     = {  94988,  472639, 1 }, -- Each time your Boar deals damage, the damage of your next Cobra Shot is increased by $s1% and Cobra Shot strikes $s2 additional target. Stacks up to $s3 times
    horsehair_tether               = {  94979,  472729, 1 }, -- When an enemy is stunned by Binding Shot, it is dragged to Binding Shot's center
    howl_of_the_pack_leader        = {  94991,  471876, 1 }, -- While in combat, every $s2 sec your next Kill Command summons the aid of a Beast.  Wyvern A Wyvern descends from the skies, letting out a battle cry that increases the damage of you and your pets by $s5% for $s6 sec.  Boar A Boar charges through your target $s9 times, dealing $s$s10 physical damage to the primary target and $s11 damage to up to $s12 nearby enemies.  Bear A Bear leaps into the fray, rending the flesh of your enemies, dealing $s15 damage over $s16 sec to up to $s17 nearby enemies
    lead_from_the_front            = {  94966,  472741, 1 }, -- Casting Bestial Wrath grants Howl of the Pack Leader and increases the damage dealt by your Beasts by $s1% and your pets by $s2% for $s3 sec
    no_mercy                       = {  94969,  472660, 1 }, -- Damage from your Kill Shot sends your pets into a rage, causing all active pets within $s1 yds and your Bear to pounce to the target and Smack, Claw, or Bite it. Your pets will not leap if their target is already in melee range
    pack_mentality                 = {  94985,  472358, 1 }, -- Howl of the Pack Leader increases the damage of your Kill Command by $s1%. Summoning a Beast reduces the cooldown of Barbed Shot by $s2 sec
    shell_cover                    = {  94967,  472707, 1 }, -- When dropping below $s1% health, summon the aid of a Turtle, reducing the damage you take by $s2% for $s3 sec. Damage reduction increased as health is reduced, increasing to up to $s4% damage reduction at $s5% health. This effect can only occur once every $s6 min
    slicked_shoes                  = {  94979,  472719, 1 }, -- When Disengage removes a movement impairing effect, its cooldown is reduced by $s1 sec
    ursine_fury                    = {  94972,  472476, 1 }, -- Your Bear's periodic damage has a $s1% chance to reduce the cooldown of Kill Command by $s2 sec
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting                = 3604, -- (356719) Stings the target, dealing $s$s2 Nature damage and initiating a series of venoms. Each lasts $s3 sec and applies the next effect after the previous one ends.  Scorpid Venom: $s6% reduced movement speed.  Spider Venom: Silenced.  Viper Venom: $s11% reduced damage and healing
    diamond_ice                    = 5534, -- (203340)
    dire_beast_basilisk            =  825, -- (1218223) Call of the Wild additionally summons a slow moving basilisk near your target for $s1 sec that attacks the target for heavy damage
    dire_beast_hawk                =  824, -- (208652) Summons a hawk to circle the target area, attacking all targets within $s1 yards over the next $s2 sec
    explosive_powder               = 5689, -- (1218150)
    hunting_pack                   = 3730, -- (203235)
    interlope                      = 1214, -- (248518) Misdirection now causes the next $s1 hostile spells cast on your target within $s2 sec to be redirected to your pet, but its cooldown is increased by $s3 sec. Your pet must be within $s4 yards of the target for spells to be redirected
    kindred_beasts                 = 5444, -- (356962)
    survival_tactics               = 3599, -- (202746)
    the_beast_within               =  693, -- (356976)
    wild_kingdom                   = 5441, -- (356707) Call in help from one of your dismissed Cunning pets for $s1 sec. Your current pet is dismissed to rest and heal $s2% of maximum health
} )

-- Auras
spec:RegisterAuras( {
    -- Talent: Under attack by a flock of crows.
    -- https://wowhead.com/beta/spell=131894
    a_murder_of_crows = {
        id = 131894,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=263446
    acid_spit = {
        id = 263446,
        duration = 6,
        mechanic = "snare",
        type = "Ranged",
        max_stack = 1
    },
    -- Dodge chance increased by $s1%.
    -- https://wowhead.com/beta/spell=160011
    agile_reflexes = {
        id = 160011,
        duration = 20,
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=50433
    ankle_crack = {
        id = 50433,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=186257
    aspect_of_the_cheetah_sprint = {
        id = 186257,
        duration = 3,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=186258
    aspect_of_the_cheetah = {
        id = 186258,
        duration = function () return conduit.cheetahs_vigor.enabled and 12 or 9 end,
        max_stack = 1
    },
    -- The range of $?s259387[Mongoose Bite][Raptor Strike] is increased to $265189r yds.
    -- https://wowhead.com/beta/spell=186289
    aspect_of_the_eagle = {
        id = 186289,
        duration = 15,
        max_stack = 1
    },
    -- Deflecting all attacks.  Damage taken reduced by $w4%.
    -- https://wowhead.com/beta/spell=186265
    aspect_of_the_turtle = {
        id = 186265,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Suffering $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=217200
    barbed_shot = {
        id = 246152,
        duration = function() return 12 + ( talent.savagery.enabled and 2 or 0 ) end,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    barbed_shot_2 = {
        id = 246851,
        duration = function () return spec.auras.barbed_shot.duration end,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    barbed_shot_3 = {
        id = 246852,
        duration = function () return spec.auras.barbed_shot.duration end,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    barbed_shot_4 = {
        id = 246853,
        duration = function () return spec.auras.barbed_shot.duration end,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    barbed_shot_5 = {
        id = 246854,
        duration = function () return spec.auras.barbed_shot.duration end,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    barbed_shot_6 = {
        id = 284255,
        duration = function () return spec.auras.barbed_shot.duration end,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    barbed_shot_7 = {
        id = 284257,
        duration = function () return spec.auras.barbed_shot.duration end,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    barbed_shot_8 = {
        id = 284258,
        duration = function () return spec.auras.barbed_shot.duration end,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    barbed_shot_dot = {
        id = 217200,
        duration = function () return spec.auras.barbed_shot.duration end,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    beast_cleave = {
        id = 268877,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Damage dealt increased by $w1%.
    -- https://wowhead.com/beta/spell=19574
    bestial_wrath = {
        id = 19574,
        duration = 15,
        type = "Ranged",
        max_stack = 1
    },
    binding_shackles = {
        id = 321469,
        duration = 8,
        max_stack = 1
    },
    binding_shot = {
        id = 117405,
        duration = 10,
        max_stack = 1
    },
    -- Stunned.
    binding_shot_stun = {
        id = 117526,
        duration = function() return 3.0 + ( 1 * talent.tarcoated_bindings.rank ) end,
        max_stack = 1,
    },
    black_arrow = {
        id = 468572,
        duration = 14,
        tick_time = 2,
        max_stack = 1
    },
    -- Talent: Bleeding for $w1 Physical damage every $t1 sec.  Taking $s2% increased damage from the Hunter's pet.
    -- https://wowhead.com/beta/spell=321538
    bloodshed = {
        id = 321538,
        duration = 12,
        tick_time = 1,
        max_stack = 1,
        generate = function ( t )
            local name, count, duration, expires, caster, _

            for i = 1, 40 do
                name, _, count, _, duration, expires, caster = UnitDebuff( "target", 321538 )

                if not name then break end
                if name and UnitIsUnit( caster, "pet" ) then break end
            end

            if name then
                t.name = name
                t.count = count
                t.expires = expires
                t.applied = expires - duration
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    -- Damage reduced by $s1%.
    -- https://wowhead.com/beta/spell=263869
    bristle = {
        id = 263869,
        duration = 12,
        max_stack = 1
    },
    -- Burrowed into the ground, dealing damage to enemies above.
    -- https://wowhead.com/beta/spell=93433
    burrow_attack = {
        id = 93433,
        duration = 8,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Disoriented.
    bursting_shot = {
        id = 224729,
        duration = 4.0,
        max_stack = 1
    },
    -- Summoning 1 of your active pets every 4 sec. Each pet summoned lasts for 6 sec.
    -- https://wowhead.com/beta/spell=359844
    call_of_the_wild = {
        id = 359844,
        duration = 20,
        max_stack = 1
    },
    call_of_the_wild_summon = {
        id = 361582,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Stealthed.
    -- https://wowhead.com/beta/spell=199483
    camouflage = {
        id = 199483,
        duration = 60,
        max_stack = 1
    },
    -- Dodge chance increased by $s1%.
    -- https://wowhead.com/beta/spell=263892
    catlike_reflexes = {
        id = 263892,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=5116
    concussive_shot = {
        id = 5116,
        duration = 6,
        mechanic = "snare",
        type = "Ranged",
        max_stack = 1
    },
    deathblow = {
        id = 378770,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Taking $w2% increased Physical damage from $@auracaster.
    -- https://wowhead.com/beta/spell=325037
    death_chakram_vulnerability = {
        id = 375893,
        duration = 10,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
        copy = { 325037, 361756, "death_chakram_debuff" }
    },
    death_chakram = {
        duration = 3.5,
        tick_time = 0.5,
        max_stack = 1,
        generate = function( t, auraType )
            local cast = action.death_chakram.lastCast or 0

            if cast + class.auras.death_chakram.duration >= query_time then
                t.name = class.abilities.death_chakram.name
                t.count = 1
                t.applied = cast
                t.expires = cast + 3.5
                t.caster = "player"
                return
            end
            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Talent: Haste increased by $s1%.
    -- https://wowhead.com/beta/spell=281036
    dire_beast = {
        id = 281036,
        duration = function() return 8 + 2 * talent.dire_frenzy.rank end,
        max_stack = 1
    },
    dire_beast_basilisk = {
        id = 209967,
        duration = 30,
        max_stack = 1
    },
    dire_beast_hawk = {
        id = 208684,
        duration = 3600,
        max_stack = 1
    },
    -- Dodge chance increased by $s1%.
    -- https://wowhead.com/beta/spell=263887
    dragons_guile = {
        id = 263887,
        duration = 20,
        max_stack = 1
    },
    -- Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=50285
    dust_cloud = {
        id = 50285,
        duration = 6,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Exploding for $212680s1 Fire damage after $t1 sec.
    -- https://wowhead.com/beta/spell=212431
    explosive_shot = {
        id = 212431,
        duration = 3,
        tick_time = 3,
        type = "Ranged",
        max_stack = 1
    },
    -- Directly controlling pet.
    -- https://wowhead.com/beta/spell=321297
    eyes_of_the_beast = {
        id = 321297,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Feigning death.
    -- https://wowhead.com/beta/spell=5384
    feign_death = {
        id = 5384,
        duration = 360,
        max_stack = 1
    },
    -- Covenant: Bleeding for $s1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=324149
    flayed_shot = {
        id = 324149,
        duration = 18,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    -- Maximum health increased by $s1%.
    -- https://wowhead.com/beta/spell=388035
    fortitude_of_the_bear = {
        id = 388035,
        duration = 10,
        max_stack = 1,
        copy = 392956
    },
    freezing_trap = {
        id = 3355,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Attack speed increased by $s1%.
    -- https://wowhead.com/beta/spell=272790
    frenzy = {
        id = 272790,
        duration = function () return azerite.feeding_frenzy.enabled and 9 or spec.auras.barbed_shot.duration end,
        max_stack = 3,
        generate = function ()
            local fr = buff.frenzy
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 272790 )

            if name then
                fr.name = name
                fr.count = count
                fr.expires = expires
                fr.applied = expires - duration
                fr.caster = caster
                return
            end

            fr.count = 0
            fr.expires = 0
            fr.applied = 0
            fr.caster = "nobody"
        end,
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=54644
    frost_breath = {
        id = 54644,
        duration = 6,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Causing Froststorm damage to all targets within $95725A1 yards.
    -- https://wowhead.com/beta/spell=92380
    froststorm_breath = {
        id = 92380,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=263840
    furious_bite = {
        id = 263840,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
    },
    growl = {
        id = 2649,
        duration = 3,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=472640
    -- Hogstrider Your next Cobra Shot strikes X additional targets and its damage is increased by 100%.
    hogstrider = {
        id = 472640,
        duration = 20,
        max_stack = 4
    },
    howl_of_the_pack_leader_cooldown = {
        id = 471877,
        duration = 30,
        max_stack = 1
    },
    howl_of_the_pack_leader_bear = {
        id = 472325,
        duration = 30,
        max_stack = 1
    },
    howl_of_the_pack_leader_boar = {
        id = 472324,
        duration = 30,
        max_stack = 1
    },
    howl_of_the_pack_leader_wyvern = {
        id = 471878,
        duration = 30,
        max_stack = 1
    },
    -- Huntmaster's Call Dire Beast will summon Hati or Fenryr at $s1 stacks
    -- https://www.wowhead.com/spell=459731
    huntmasters_call = {
        id = 459731,
        duration = 3600,
        max_stack = 5
    },
    intimidation = {
        id = 24394,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Bleeding for $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=259277
    kill_command = {
        id = 259277,
        duration = 8,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=472743
    -- Lead From the Front The damage of your Pack Leader Beasts is increased by 25%.
    lead_from_the_front = {
        id = 472743,
        duration = 12,
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=263423
    lock_jaw = {
        id = 263423,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
    },
    masters_call = {
        id = 54216,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Heals $w1% of the pet's health every $t1 sec.$?s343242[  Each time Mend Pet heals your pet, you have a $343242s2% chance to dispel a harmful magic effect from your pet.][]
    -- https://wowhead.com/beta/spell=136
    mend_pet = {
        id = 136,
        duration = 10,
        type = "Magic",
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 136 )

            if name then
                t.name = name
                t.count = count
                t.expires = expires
                t.applied = expires - duration
                t.caster = caster
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end
    },
    -- Talent: Threat redirected from Hunter.
    -- https://wowhead.com/beta/spell=35079
    misdirection = {
        id = 35079,
        duration = 8,
        max_stack = 1
    },
    -- Damage taken reduced by $w1%
    no_hard_feelings = {
        id = 459547,
        duration = 5.0,
        max_stack = 1
    },
    -- Damage reduced by $s1%.
    -- https://wowhead.com/beta/spell=263867
    obsidian_skin = {
        id = 263867,
        duration = 12,
        max_stack = 1
    },
    parsels_tongue = {
        id = 248085,
        duration = 8,
        max_stack = 4
    },
    -- Pinned in place.
    -- https://wowhead.com/beta/spell=50245
    pin = {
        id = 50245,
        duration = 6,
        mechanic = "root",
        max_stack = 1
    },
    -- "When you're the best of friends..."
    -- https://wowhead.com/beta/spell=90347
    play = {
        id = 90347,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Increased movement speed by $s1%.
    -- https://wowhead.com/beta/spell=118922
    posthaste = {
        id = 118922,
        duration = 4,
        max_stack = 1
    },
    predators_thirst = {
        id = 264663,
        duration = 3600,
        max_stack = 1
    },
    -- Stealthed.  Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=24450
    prowl = {
        id = 24450,
        duration = 3600,
        max_stack = 1
    },
    -- Recently benefitted from Quick Load.
    quick_load = {
        id = 385646,
        duration = 25.0,
        max_stack = 1,
        copy = "quick_load_icd"
    },
    rejuvenating_wind = {
        id = 339400,
        duration = 8,
        max_stack = 1
    },
    -- Zzzzzz...
    -- https://wowhead.com/beta/spell=94019
    rest = {
        id = 94019,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Feared.
    -- https://wowhead.com/beta/spell=1513
    scare_beast = {
        id = 1513,
        duration = 20,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=213691
    scatter_shot = {
        id = 213691,
        duration = 4,
        type = "Ranged",
        max_stack = 1
    },
    serpentine_rhythm = {
        id = 468703,
        duration = 30,
        max_stack = 3
    },
    serpentine_blessing = {
        id = 468704,
        duration = 8,
        max_stack = 1
    },
    -- Dodge chance increased by $s1%.
    -- https://wowhead.com/beta/spell=263904
    serpents_swiftness = {
        id = 263904,
        duration = 20,
        max_stack = 1
    },
    -- Damage taken reduced by $s1%.
    -- https://wowhead.com/beta/spell=263938
    silverback = {
        id = 263938,
        duration = 15,
        max_stack = 1
    },
    solitary_companion = {
        id = 474751,
        duration = 3600,
        max_stack = 1
    },
    -- Heals $w2 every $t2 sec for $d.
    -- https://wowhead.com/beta/spell=90361
    spirit_mend = {
        id = 90361,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Stealthed.  Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=90328
    spirit_walk = {
        id = 90328,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Slowed by $s2%.  $s3% increased chance suffer a critical strike from $@auracaster.
    -- https://wowhead.com/beta/spell=201594
    stampede = {
        id = 201594,
        duration = 5,
        type = "Ranged",
        max_stack = 1
    },
    -- Talent: Bleeding for $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=162487
    steel_trap = {
        id = 162487,
        duration = 20,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1
    },
    -- Summon Fenryr Haste increased by $s1%. $s2 seconds remaining
    -- https://www.wowhead.com/spell=459735
    summon_fenryr = {
        id = 459735,
        duration = 16,
        max_stack = 1,
    },
    -- All damage taken reduced by $s1%.
    survival_of_the_fittest = {
        id = 264735,
        duration = function() return 6.0 + 2 * talent.lone_survivor.rank end,
        max_stack = 1
    },
    -- Reduces damage taken by $202746s1%, up to a maximum of $w1.
    survival_tactics = {
        id = 202748,
        duration = 2.0,
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=263852
    talon_rend = {
        id = 263852,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
    },
    tar_trap = {
        id = 135299,
        duration = 30,
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=160065
    tendon_rip = {
        id = 160065,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
    },
    -- The Bell Tolls All damage dealt by you and your pets is increased by $s1%. $s2 seconds remaining
    -- https://www.wowhead.com/spell=1232992
    the_bell_tolls = {
        id = 1232992,
        duration = 12,
        max_stack = 10
    },
    -- Damage taken reduced by $s1%.
    -- https://wowhead.com/beta/spell=263926
    thick_fur = {
        id = 263926,
        duration = 15,
        max_stack = 1
    },
    -- Damage taken reduced by $s1%.
    -- https://wowhead.com/beta/spell=160058
    thick_hide = {
        id = 160058,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Critical strike chance increased by $s1%.
    -- https://wowhead.com/beta/spell=257946
    thrill_of_the_hunt = {
        id = 257946,
        duration = function () return spec.auras.barbed_shot.duration end,
        max_stack = 3,
        copy = 312365
    },
    trailblazer = {
        id = 231390,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=355596
    wailing_arrow = {
        id = 355596,
        duration = 5,
        mechanic = "silence",
        type = "Magic",
        max_stack = 1,
        copy = 392061
    },
    -- Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=35346
    warp_time = {
        id = 35346,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=160067
    web_spray = {
        id = 160067,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
    },
    -- Talent: The cooldown of $?s217200[Barbed Shot][Dire Beast] is reset.
    -- https://wowhead.com/beta/spell=185791
    wild_call = {
        id = 185791,
        duration = 4,
        max_stack = 1
    },
    -- Damage taken from $@auracaster's Pets increased by $s1%.
    wild_instincts = {
        id = 424567,
        duration = 8,
        max_stack = 10
    },
    -- Suffering $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=269747
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=195645
    wing_clip = {
        id = 195645,
        duration = 15,
        max_stack = 1
    },
    -- Dodge chance increased by $s1%.
    -- https://wowhead.com/beta/spell=264360
    winged_agility = {
        id = 264360,
        duration = 20,
        max_stack = 1
    },
    -- Withering Fire Casting Black Arrow fires a barrage of $s1 additional Black Arrows at nearby targets. $s2 second remaining
    withering_fire = {
        id = 466991,
        duration = function() return spec.auras.call_of_the_wild.duration end,
        max_stack = 1
    },
    -- Wyvern's Cry You and your pet's damage is increased by $s1%. $s2 seconds remaining
    -- https://www.wowhead.com/spell=471881
    wyverns_cry = {
        id = 471881,
        duration = 15,
        max_stack = 20
    },
    -- PvP Talents
    high_explosive_trap = {
        id = 236777,
        duration = 0.1,
        max_stack = 1
    },
    interlope = {
        id = 248518,
        duration = 45,
        max_stack = 1
    },
    roar_of_sacrifice = {
        id = 53480,
        duration = 12,
        max_stack = 1
    },
    the_beast_within = {
        id = 212704,
        duration = 15,
        max_stack = 1
    },
    -- Azerite Powers
    dance_of_death = {
        id = 274443,
        duration = 8,
        max_stack = 1
    },
    primal_instincts = {
        id = 279810,
        duration = 20,
        max_stack = 1
    },
    -- Conduits
    resilience_of_the_hunter = {
        id = 339461,
        duration = 8,
        max_stack = 1
    },
    tactical_retreat = {
        id = 339654,
        duration = 3,
        max_stack = 1
    },
    -- Legendaries
    flamewakers_cobra_sting = {
        id = 336826,
        duration = 15,
        max_stack = 1
    },
    nessingwarys_trapping_apparatus = {
        id = 336744,
        duration = 5,
        max_stack = 1,
        copy = { "nesingwarys_trapping_apparatus", "nesingwarys_apparatus", "nessingwarys_apparatus" }
    },
    soulforge_embers = {
        id = 336746,
        duration = 12,
        max_stack = 1
    }
} )

-- Pets
spec:RegisterPets({
    -- Howl of the Pack Leader
    wyvern = {
        id = 234170,
        spell = "kill_command",
        duration = 15
    },
    -- boar isn't a real pet
    bear = {
        id = 234018,
        spell = "kill_command",
        duration = 15
    }
} )

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237644, 237645, 237646, 237647, 237649 },
        auras = {
            -- Pack Leader
            -- Mastery
            grizzled_fur = {
                id = 1236564,
                duration = 8,
                max_stack = 1
            },
            -- Haste
            hasted_hooves = {
                id = 1236565,
                duration = 8,
                max_stack = 1
            },
            -- Crit
            sharpened_fangs = {
                id = 1236566,
                duration = 8,
                max_stack = 1
            },
            -- Dark Ranger
            blighted_quiver = {
                id = 1236975,
                duration = 3600,
                max_stack = 15
            },
        }
    },
    tww2 = {
        items = { 229271, 229269, 229274, 229272, 229270 },
        auras = {
            -- Possible TODO: pet attacks reduce bestial wrath cd?
            potent_mutagen = {
                id = 1218003,
                duration = 8,
                max_stack = 1
            }
        }
    },
    tww1 = {
        items = { 212018, 212019, 212020, 212021, 212023 }
    },
    -- Dragonflight
    tier31 = {
        items = { 207216, 207217, 207218, 207219, 207221, 217183, 217185, 217181, 217182, 217184 },
    },
    tier29 = {
        items = { 200390, 200392, 200387, 200389, 200391 },
        auras = {
            lethal_command = {
                id = 394298,
                duration = 15,
                max_stack = 1
            }
        }
    },

} )

-- Legacy
--- Shadowlands
local ExpireNesingwarysTrappingApparatus = setfenv( function()
    focus.regen = focus.regen * 0.5
    forecastResources( "focus" )
end, state )

spec:RegisterStateExpr( "barbed_shot_grace_period", function ()
    return ( settings.barbed_shot_grace_period or 0 ) * gcd.max
end )

spec:RegisterHook( "spend", function( amt, resource )
    if amt < 0 and resource == "focus" and buff.nessingwarys_trapping_apparatus.up then
        amt = amt * 2
    end

    return amt, resource
end )

local CallOfTheWildCDR = setfenv( function()
    gainChargeTime( "kill_command", spec.abilities.kill_command.recharge/4)
    gainChargeTime( "barbed_shot", spec.abilities.barbed_shot.recharge/4)
    if talent.withering_fire.enabled then applyBuff( "deathblow" ) end
end, state )

local pack_leader_buff_cycle = {
    "wyvern",
    "boar",
    "bear",
}

-- This variable represents the true index in the above table of the next buff that will be applied to you, whether by the natural cycle or by bestial wrath
-- The index should always initially start at "1" (Wyvern), and is also reset to 1 upon:
  -- Aura Interrupt: Leave World (19), Enter World (22), Change Specialization (38), Raid Encounter Start or M+ Start (40), Raid Encounter End or M+ Start (41), Disconnect (42), Enter Instance (43), Leave Arena or Battleground (45), Change Talent (46), Encounter End (56)
local PackLeaderBuffNextIndex = 1

spec:RegisterStateExpr( "pack_leader_buff_next_index", function()
    return PackLeaderBuffNextIndex
end )

local lastBoarSummoned = 0

spec:RegisterStateExpr( "last_boar_summoned", function()
    return lastBoarSummoned
end )

local trapUnits = { "target", "focus" }
local trappableClassifications = {
    rare = true,
    elite = true,
    normal = true,
    trivial = true,
    minus = true
}

for i = 1, 5 do
    trapUnits[ #trapUnits + 1 ] = "boss" .. i
end

for i = 1, 40 do
    trapUnits[ #trapUnits + 1 ] = "nameplate" .. i
end

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" then
            -- Detect REAL cycle events and update the index accordingly
            for index, animal in ipairs( pack_leader_buff_cycle ) do
                local buffName = "howl_of_the_pack_leader_" .. animal
                local aura = spec.auras[ buffName ]
                if aura and spellID == aura.id then
                    PackLeaderBuffNextIndex = ( index % #pack_leader_buff_cycle ) + 1
                    break
                end
            end
        elseif subtype == "SPELL_AURA_REMOVED" and spellID == 472324 then
            local now = GetTime()
            -- use lastcast to make sure it wasn't a natural buff disappearing
            if now - action.kill_command.lastCast <= 1 then lastBoarSummoned = now end
        end
    end

    --[[
    if subtype == "SPELL_CAST_SUCCESS" and sourceGUID == GUID and spellID == 187698 and legendary.soulforge_embers.enabled then
        -- Capture all boss/elite targets present at this time as valid trapped targets.
        table.wipe(tar_trap_targets)

        for _, unit in ipairs(trapUnits) do
            if UnitExists(unit) and UnitCanAttack("player", unit) and not trappableClassifications[UnitClassification(unit)] then
                tar_trap_targets[UnitGUID(unit)] = true
            end
        end
    end--]]
end, false )

spec:RegisterStateTable( "tar_trap", setmetatable( {}, {
    __index = function( t, k )
        return state.debuff.tar_trap[ k ]
    end
} ) )

-- To support TWW Season 3 tier set
local tww3_tier_pack_leader_buffs = {
    bear   = "grizzled_fur",
    boar   = "hasted_hooves",
    wyvern = "sharpened_fangs",
}

-- To support SimC Expressions
spec:RegisterStateTable( "howl_summon", setmetatable( {

    refresh_cycle = setfenv( function()
        -- reset_precast function
        pack_leader_buff_next_index = nil
    end, state ),

    raid_boss_reset = setfenv( function()
        pack_leader_buff_next_index = 1
    end, state ),

    trigger_summon = setfenv( function( isBestialWrath )

        local summonCount = 0
        if isBestialWrath then
            -- Scenario 1: Bestial Wrath prepares the next summon without summoning anything that is currently ready or modifying the CD buff
            applyBuff( "howl_of_the_pack_leader_" .. pack_leader_buff_cycle[ pack_leader_buff_next_index ] )
            pack_leader_buff_next_index = ( pack_leader_buff_next_index % #pack_leader_buff_cycle) + 1  -- Advance to the next buff index virtually, will be reset / synced in reset_precast
            applyBuff( "lead_from_the_front" )
        else
            -- Scenario 2: Kill Command summons + other effects
            for _, animal in ipairs( pack_leader_buff_cycle ) do
                local buffName = "howl_of_the_pack_leader_" .. animal
                if buff[ buffName ].up then
                    removeBuff( buffName )
                    summonCount = summonCount + 1
                    if set_bonus.tww3 >= 2 then
                        applyBuff( tww3_tier_pack_leader_buffs[ animal ] )
                    end
                end
            end
            if talent.pack_mentality.enabled then reduceCooldown( "barbed_shot", 10 * summonCount ) end

            if buff.howl_of_the_pack_leader_cooldown.down then applyBuff( "howl_of_the_pack_leader_cooldown" )
            elseif talent.dire_summons.enabled then buff.howl_of_the_pack_leader_cooldown.expires = buff.howl_of_the_pack_leader_cooldown.expires - 1
            end
        end
    end, state ),

}, {
    __index = function( t, k )

        if k == "ready" then
            return buff.howl_of_the_pack_leader_bear.up or buff.howl_of_the_pack_leader_boar.up or buff.howl_of_the_pack_leader_wyvern.up or false
        elseif k == "ready_bear"  then
            return buff.howl_of_the_pack_leader_bear.up
        elseif k == "ready_boar" then
            return buff.howl_of_the_pack_leader_boar.up
        elseif k == "ready_wyvern" then
            return buff.howl_of_the_pack_leader_wyvern.up
        elseif k == "next" then
            return pack_leader_buff_cycle[ pack_leader_buff_next_index ]
        elseif k == "next_bear" then
            return pack_leader_buff_next_index == 3
        elseif k == "next_boar" then
            return pack_leader_buff_next_index == 2
        elseif k == "next_wyvern" then
            return pack_leader_buff_next_index == 1
        end
    end
} ) )

-- To support SimC Expressions
spec:RegisterStateTable( "boar_charge", setmetatable( {

    boar_duration = 6,
    boar_interval = 3,

    refresh_tracker = setfenv( function()
        -- reset_precast function
        last_boar_summoned = nil
    end, state ),

}, {
    __index = function( t, k )
        local elapsed = query_time - last_boar_summoned

        if k == "remains" then
            return max( 0, boar_charge.boar_duration - elapsed )
        elseif k == "next_charge"  then
            if elapsed < 0 or elapsed > boar_charge.boar_duration then
                return 3600
            else
                return ( boar_charge.boar_interval * ( floor( elapsed / boar_charge.boar_interval ) + 1 ) ) - elapsed
            end
        elseif k == "charges_remaining" then
            if elapsed < 0 or elapsed >= boar_charge.boar_duration then
                return 0
            else
                return max( 0, 2 - ( floor( elapsed / boar_charge.boar_interval ) ) )
            end
        end
    end
} ) )

spec:RegisterHook( "reset_precast", function()

    if talent.howl_of_the_pack_leader.enabled then
        howl_summon.refresh_cycle()
        boar_charge.refresh_tracker()
    end


    if debuff.tar_trap.up then
        debuff.tar_trap.expires = debuff.tar_trap.applied + 30
    end

    if legendary.nessingwarys_trapping_apparatus.enabled then
        if buff.nesingwarys_apparatus.up then
            state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireNesingwarysTrappingApparatus, buff.nesingwarys_apparatus.expires )
        end
    end

    if buff.call_of_the_wild.up then
        local tick, expires = buff.call_of_the_wild.applied, buff.call_of_the_wild.expires
        for i = 1, 5 do
            tick = tick + 4
            if tick > query_time and tick < expires then
                state:QueueAuraEvent( "call_of_the_wild_cdr", CallOfTheWildCDR, tick, "AURA_TICK" )
            end
        end
    end
    if covenant.kyrian and now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end
    if barbed_shot_grace_period > 0 and cooldown.barbed_shot.remains > 0 then reduceCooldown( "barbed_shot", barbed_shot_grace_period ) end

    -- FIXME
    -- This is still happening, but works better at further distances. It might be good practice to slow the projectile in general.
    -- Ensure that multishot recommendation doesn't flicker while black arrow is in flight, which was happening when only using the impact() function of the spell
    if action.kill_shot.in_flight and talent.umbral_reach.enabled and active_enemies > 1 and talent.beast_cleave.enabled then
        applyBuff( "beast_cleave" )
    end

end )

spec:RegisterHook( "runHandler_startCombat", function()
    if talent.howl_of_the_pack_leader.enabled then
        if buff.howl_of_the_pack_leader_cooldown.down then applyBuff( "howl_of_the_pack_leader_cooldown" ) end
        if raid and boss then howl_summon.raid_boss_reset() end
    end
end )

-- Abilities
spec:RegisterAbilities( {
    -- Increases your movement speed by $s1% for $d, and then by $186258s1% for another $186258d$?a445701[, and then by $445701s1% for another $445701s2 sec][].$?a459455[; You cannot be slowed below $s2% of your normal movement speed.][]
    aspect_of_the_cheetah = {
        id = 186257,
        cast = 0,
        cooldown = function () return 180 * ( pvptalent.hunting_pack.enabled and 0.5 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) - ( 30 * talent.born_to_be_wild.rank ) + ( conduit.cheetahs_vigor.mod * 0.001 ) end,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "aspect_of_the_cheetah" )
            applyBuff( "aspect_of_the_cheetah_sprint" )
        end,
    },

    -- Deflects all attacks and reduces all damage you take by $s4% for $d, but you cannot attack.$?s83495[  Additionally, you have a $83495s1% chance to reflect spells back at the attacker.][]
    aspect_of_the_turtle = {
        id = 186265,
        cast = 8,
        channeled = true,
        cooldown = function () return 180 * ( pvptalent.hunting_pack.enabled and 0.5 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) - ( 30 * talent.born_to_be_wild.rank ) + ( conduit.cheetahs_vigor.mod * 0.001 ) end,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        toggle = "cooldowns",

        start = function ()
            applyBuff( "aspect_of_the_turtle" )
        end,
    },

    -- Talent: Fire a shot that tears through your enemy, causing them to bleed for ${$s1*$s2} damage over $d$?s257944[ and  increases your critical strike chance by $257946s1% for $257946d, stacking up to $257946u $Ltime:times;][].    Sends your pet into a frenzy, increasing attack speed by $272790s1% for $272790d, stacking up to $272790u times.    |cFFFFFFFFGenerates ${$246152s1*$246152d/$246152t1} Focus over $246152d.|r
    barbed_shot = {
        id = 217200,
        cast = 0,
        charges = 2,
        cooldown = 18,
        recharge = 18,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        talent = "barbed_shot",
        startsCombat = true,

        velocity = 50,
        cycle = "barbed_shot_dot",

        handler = function ()
            if buff.barbed_shot.down then applyBuff( "barbed_shot" )
            else
                for i = 2, 8 do
                    if buff[ "barbed_shot_" .. i ].down then applyBuff( "barbed_shot_" .. i ); break end
                end
            end

            applyDebuff( "target", "barbed_shot_dot" )
            addStack( "frenzy", nil, 1 )

            if talent.barbed_wrath.enabled then reduceCooldown( "bestial_wrath", 12 ) end
            if talent.thrill_of_the_hunt.enabled then addStack( "thrill_of_the_hunt", nil, 1 ) end

            --- Legacy / PvP Stuff
            if set_bonus.tier29_4pc > 0 then applyBuff( "lethal_command" ) end
            if legendary.qapla_eredun_war_order.enabled then
                setCooldown( "kill_command", 0 )
            end
            if legendary.latent_poison_injectors.enabled then
                removeDebuff( "target", "latent_poison" )
            end
        end,
    },

    -- Talent: Sends you and your pet into a rage, instantly dealing $<damage> Physical damage to its target, and increasing all damage you both deal by $s1% for $d. Removes all crowd control effects from your pet. $?s231548[    Bestial Wrath's remaining cooldown is reduced by $s3 sec each time you use Barbed Shot][]$?s193532[ and activating Bestial Wrath grants $s2 $Lcharge:charges; of Barbed Shot.][]$?s231548&!s193532[.][]
    bestial_wrath = {
        id = 19574,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "physical",

        talent = "bestial_wrath",
        startsCombat = false,

        toggle = "cooldowns",
        nobuff = function () return settings.avoid_bw_overlap and "bestial_wrath" or nil, "avoid_bw_overlap is checked and bestial_wrath is up" end,

        handler = function ()
            -- Base Functionality / Talents
            applyBuff( "bestial_wrath" )
            if talent.scent_of_blood.enabled then gainCharges( "barbed_shot", talent.scent_of_blood.rank ) end

            -- Hero Talents
            if talent.lead_from_the_front.enabled then howl_summon.trigger_summon( true ) end

            if set_bonus.tww2 >= 2 then
            spec.abilities.barbed_shot.handler()
                if set_bonus.tww2 >= 4 then
                    applyBuff( "potent_mutagen" )
                end
            end

            -- Legacy / PvP Stuff
            if set_bonus.tier31_2pc > 0 then
                applyBuff( "dire_beast", 15 )
                summonPet( "dire_beast", 15 )
            end
            if pvptalent.the_beast_within.enabled then applyBuff( "the_beast_within" ) end
        end,
    },

    -- Talent: Fires a magical projectile, tethering the enemy and any other enemies within $s2 yards for $d, stunning them for $117526d if they move more than $s2 yards from the arrow.$?s321468[    Targets stunned by Binding Shot deal $321469s1% less damage to you for $321469d after the effect ends.][]
    binding_shot = {
        id = 109248,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "nature",

        talent = "binding_shot",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "binding_shot" )
        end,
    },

    -- Command your pet to tear into your target, causing your target to bleed for $<damage> over $321538d and take $321538s2% increased damage from your pet by for $321538d.
    bloodshed = {
        id = 321530,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "physical",

        talent = "bloodshed",
        startsCombat = true,

        usable = function() return pet.alive, "requires a living pet" end,

        handler = function ()
            applyDebuff( "target", "bloodshed" )
        end,
    },

    -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by $s4% for $d, and dealing $s1 Physical damage.$?s378771[; When you fall below $378771s1% heath, Bursting Shot's cooldown is immediately reset. This can only occur once every $385646d.][]
    bursting_shot = {
        id = 186387,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "spell",

        spend = 10,
        spendType = 'focus',

        talent = "bursting_shot",
        startsCombat = true,
    },

    -- Talent: You sound the call of the wild, summoning $s1 of your active pets for $d. During this time, a random pet from your stable will appear every $t2 sec to assault your target for $361582d.$?s378442[    While Call of the Wild is active, Barbed Shot has a $378442h% chance to gain a charge any time Focus is spent.][]$?s378739[    While Call of the Wild is active, Barbed Shot affects all of your summoned pets.][]
    call_of_the_wild = {
        id = 359844,
        cast = 0,
        cooldown = function() if set_bonus.tww3_dark_ranger >=2 then return 60 else return 120 end end,
        gcd = "spell",
        school = "nature",

        talent = "call_of_the_wild",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "call_of_the_wild" )
            gainCharges( "kill_command", 1 )
            gainCharges( "barbed_shot", 1 )
            -- Queue the pet summons for CDR calculation
            for i = 4, 20, 4 do
                state:QueueAuraEvent( "call_of_the_wild_cdr", CallOfTheWildCDR, query_time + i, "AURA_TICK" )
            end
            if talent.bloody_frenzy.enabled then applyBuff( "beast_cleave", 20 ) end
            if talent.withering_fire.enabled then
                applyBuff( "withering_fire" )
                applyBuff( "deathblow" )
                if set_bonus.tww2 >= 4 then
                    removeBuff( "blighted_quiver" )
                end
            end
        end,
    },

    -- Talent: You and your pet blend into the surroundings and gain stealth for $d. While camouflaged, you will heal for $s4% of maximum health every $T4 sec.
    camouflage = {
        id = 199483,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "physical",

        talent = "camouflage",
        startsCombat = false,

        handler = function ()
            applyBuff( "camouflage" )
        end,
    },

    -- Talent: A quick shot causing ${$s2*$<mult>} Physical damage.    Reduces the cooldown of Kill Command by $?s378244[${$s3+($378244s1/-1000)}][$s3] sec.
    cobra_shot = {
        id = 193455,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function () return talent.cobra_senses.enabled and 30 or 35 end,
        spendType = "focus",

        talent = "cobra_shot",
        startsCombat = true,

        handler = function ()

            if talent.serpentine_rhythm.enabled then
                if buff.serpentine_rhythm.stacks == 3 then
                    removeBuff( "serpentine_rhythm" )
                    applyBuff( "serpentine_blessing" )
                else addStack( "serpentine_rhythm" )
                end
            end

            -- CDR
            if talent.dire_summons.enabled and buff.howl_of_the_pack_leader_cooldown.up then buff.howl_of_the_pack_leader_cooldown.expires = buff.howl_of_the_pack_leader_cooldown.expires - 1 end
            if talent.barbed_scales.enabled then
                reduceCooldown( "barbed_shot", 2 )
            end
            reduceCooldown( "kill_command", 1 )
            if talent.killer_cobra.enabled and buff.bestial_wrath.up then gainCharges( "kill_command", 1 ) end

            -- Legacy / PvP Stuff
            if debuff.concussive_shot.up then debuff.concussive_shot.expires = debuff.concussive_shot.expires + 3 end
            if set_bonus.tier30_4pc > 0 then reduceCooldown( "bestial_wrath", 1 ) end
        end,
    },

    -- Talent: Dazes the target, slowing movement speed by $s1% for $d.    $?s193455[Cobra Shot][Steady Shot] will increase the duration of Concussive Shot on the target by ${$56641m3/10}.1 sec.
    concussive_shot = {
        id = 5116,
        cast = 0,
        cooldown = 5,
        gcd = "spell",
        school = "physical",

        talent = "concussive_shot",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "concussive_shot" )
        end,
    },

    -- Talent: Interrupts spellcasting, preventing any spell in that school from being cast for $d.
    counter_shot = {
        id = 147362,
        cast = 0,
        cooldown = function() return 24 - 2 * talent.lone_survivor.rank end,
        gcd = "off",
        school = "physical",

        talent = "counter_shot",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            if conduit.reversal_of_fortune.enabled then
                gain( conduit.reversal_of_fortune.mod, "focus" )
            end

            interrupt()
        end,
    },

    -- Summons a powerful wild beast that attacks the target and roars, increasing your Haste by $281036s1% for $d.; Generates $281036s2 Focus.
    dire_beast = {
        id = 120679,
        cast = 0,
        cooldown = 20,
        gcd = "spell",
        school = "nature",

        spend = -20,
        spendType = "focus",

        talent = "dire_beast",
        startsCombat = true,

        handler = function ()
            applyBuff( "dire_beast" )
            summonPet( "dire_beast", 8 )
        end,
    },

    dire_beast_basilisk = {
        id = 205691,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 60,
        spendType = "focus",

        toggle = "cooldowns",
        pvptalent = "dire_beast_basilisk",

        startsCombat = true,
        texture = 1412204,

        handler = function ()
            applyDebuff( "target", "dire_beast_basilisk" )
        end,
    },

    dire_beast_hawk = {
        id = 208652,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 30,
        spendType = "focus",

        pvptalent = "dire_beast_hawk",

        startsCombat = true,
        texture = 612363,

        handler = function ()
            applyDebuff( "target", "dire_beast_hawk" )
        end,
    },

    -- Leap backwards$?s109215[, clearing movement impairing effects, and increasing your movement speed by $118922s1% for $118922d][]$?s109298[, and activating a web trap which encases all targets within $115928A1 yards in sticky webs, preventing movement for $136634d][].
    disengage = {
        id = 781,
        cast = 0,
        cooldown = 20,
        gcd = "off",
        school = "physical",
        icd = 0.5,

        startsCombat = false,

        handler = function ()
            if talent.posthaste.enabled then applyBuff( "posthaste" ) end
            if conduit.tactical_retreat.enabled then applyDebuff( "target", "tactical_retreat" ) end
        end,
    },

    exhilaration = {
        id = 109304,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 461117,

        toggle = "defensives",

        handler = function ()
            if talent.rejuvenating_wind.enabled or conduit.rejuvenating_wind.enabled then applyBuff( "rejuvenating_wind" ) end
        end,
    },

    -- Talent: Fires an explosive shot at your target. After $t1 sec, the shot will explode, dealing $212680s1 Fire damage to all enemies within $212680A1 yards. Deals reduced damage beyond $s2 targets.
    explosive_shot = {
        id = 212431,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "fire",

        spend = 20,
        spendType = "focus",

        talent = "explosive_shot",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "explosive_shot", debuff.explosive_shot.remains + spec.auras.explosive_shot.duration )
        end,
    },

    -- Take direct control of your pet and see through its eyes for $d.
    eyes_of_the_beast = {
        id = 321297,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "eyes_of_the_beast" )
        end,
    },

    -- Feign death, tricking enemies into ignoring you. Lasts up to $d.
    feign_death = {
        id = 5384,
        cast = 0,
        cooldown = function () return legendary.craven_stategem.enabled and 15 or 30 end,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        handler = function ()
            applyBuff( "feign_death" )

            if pvptalent.survival_tactics.enabled then
                applyBuff( "survival_tactics" )
            end

            if talent.emergency_salve.enabled then
                removeDebuff( "player", "dispellable_disease" )
                removeDebuff( "player", "dispellable_poison" )
            end

            if legendary.craven_strategem.enabled then
                removeDebuff( "player", "dispellable_curse" )
                removeDebuff( "player", "dispellable_disease" )
                removeDebuff( "player", "dispellable_magic" )
                removeDebuff( "player", "dispellable_poison" )
            end
        end,
    },

    -- Exposes all hidden and invisible enemies within the targeted area for $m1 sec.
    flare = {
        id = 1543,
        cast = 0,
        cooldown = 20,
        gcd = "spell",
        school = "arcane",

        startsCombat = false,

        handler = function ()
            if legendary.soulforge_embers.enabled and debuff.tar_trap.up then
                applyDebuff( "target", "soulforge_embers" )
                active_dot.soulforge_embers = max( 1, min( 5, active_dot.tar_trap ) )
            end
        end,
    },

    -- Increase the maximum health of you and your pet by 20% for 10 sec, and instantly heals you for that amount.
    fortitude_of_the_bear = {
        id = 272679,
        cast = 0,
        cooldown = function() return pvptalent.kindred_beasts.enabled and 60 or 120 end,
        gcd = "off",

        startsCombat = false,
        texture = off,

        handler = function ()
            local hp = health.max * 0.2
            health.max = health.max + hp
            gain( hp, "health" )

            applyBuff( "fortitude_of_the_bear" )
        end,

        copy = { 388035, 392956 }, -- Pet's version?

        auras = {
            fortitude_of_the_bear = {
                id = 388035,
                duration = 10,
                max_stack = 1,
                copy = 392956
            }
        }
    },

    -- Hurls a frost trap to the target location that incapacitates the first enemy that approaches for $3355d. Damage will break the effect. Limit 1. Trap will exist for $3355d.
    freezing_trap = {
        id = 187650,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.improved_traps.rank end,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if legendary.nessingwarys_trapping_apparatus.enabled then
                return -45, "focus"
            end
        end,

        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies away.  Trap will exist for $236775d.$?s321468[    Targets knocked back by High Explosive Trap deal $321469s1% less damage to you for $321469d after being knocked back.][]
    high_explosive_trap = {
        id = 236776,
        cast = 0,
        cooldown = function() return 40 - 5 * talent.improved_traps.rank end,
        gcd = "spell",
        school = "fire",

        spend = function ()
            if legendary.nessingwarys_trapping_apparatus.enabled then
                return -45, "focus"
            end
        end,

        talent = "high_explosive_trap",
        startsCombat = false,

        handler = function ()
        end,
    },

    howl_of_the_pack_leader = {
        cast = 0,
        cooldown = 30,
        gcd = "off",
        hidden = true,
    },

    -- Apply Hunter's Mark to the target, causing the target to always be seen and tracked by the Hunter.; Hunter's Mark increases all damage dealt to targets above $s3% health by $428402s1%. Only one Hunter's Mark damage increase can be applied to a target at a time.; Hunter's Mark can only be applied to one target at a time. When applying Hunter's Mark in combat, the ability goes on cooldown for ${$s5/1000} sec.
    hunters_mark = {
        id = 257284,
        cast = 0,
        cooldown = function () return time > 0 and 20 or 0 end,
        gcd = "totem",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hunters_mark" )
        end,
    },

    -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies up. Limit $s2. Trap will exist for $236775d.$?s321468[; Targets knocked up by Implosive Trap deal $321469s1% less damage to you for $321469d after being knocked up.][]
    implosive_trap = {
        id = 462031,
        cast = 0.0,
        cooldown = function() return 60.0 - 5 * talent.improved_traps.rank end,
        gcd = "spell",

        talent = "implosive_trap",
        startsCombat = false,

        handler = function()
        end,
    },

    interlope = {
        id = 248518,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "interlope",

        startsCombat = false,
        texture = 132180,

        handler = function ()
        end,
    },

    -- Talent: Commands your pet to intimidate the target, stunning it for $24394d.$?s321468[    Targets stunned by Intimidation deal $321469s1% less damage to you for $321469d after the effect ends.][]
    intimidation = {
        id = 19577,
        cast = 0,
        cooldown = function() return 60 - 10 * talent.territorial_instincts.rank end,
        gcd = "spell",
        school = "nature",

        talent = "intimidation",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "intimidation" )
        end,
    },

    -- Talent: Give the command to kill, causing your pet to savagely deal $<damage> Physical damage to the enemy.
    kill_command = {
        id = 34026,
        cast = 0,
        charges = function() if talent.alpha_predator.enabled then return 2 end end,
        cooldown = 7.5,
        recharge = function() if talent.alpha_predator.enabled then return 7.5 * haste end end,
        hasteCD = true,
        icd = 0.5,
        gcd = "spell",
        school = "physical",

        spend = 30,
        spendType = "focus",

        talent = "kill_command",
        startsCombat = true,

        disabled = function()
            if settings.check_pet_range and settings.petbased and Hekili:PetBasedTargetDetectionIsReady( true ) and not Hekili:TargetIsNearPet( "target" ) then return true, "not in-range of pet" end
        end,

        handler = function ()

            if talent.howl_of_the_pack_leader.enabled then howl_summon.trigger_summon( false ) end

            if talent.wild_instincts.enabled and buff.call_of_the_wild.up then
                applyDebuff( "target", "wild_instincts", nil, min( spec.auras.wild_instincts.max_stack, debuff.wild_instincts.stack + 1 ) )
            end

            --- Legacy / PvP Stuff
            if legendary.flamewakers_cobra_sting.enabled then removeBuff( "flamewakers_cobra_sting" ) end
            if set_bonus.tier29_4pc > 0 then removeBuff( "lethal_command" ) end
            if set_bonus.tier30_4pc > 0 then reduceCooldown( "bestial_wrath", 1 ) end
        end,
    },

    -- Talent: You attempt to finish off a wounded target, dealing $s1 Physical damage. Only usable on enemies with less than $s2% health.$?s343248[    Kill Shot deals $343248s1% increased critical damage.][]
    kill_shot = {
        id = function() return talent.black_arrow.enabled and 466930 or 53351 end,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = function() return talent.black_arrow.enabled and "shadow" or "physical" end,

        spend = function () return ( buff.flayers_mark.up ) and 0 or 10 end,
        spendType = "focus",

        talent = "kill_shot",
        startsCombat = true,
        velocity = 80,

        cycle = function() if talent.banshees_mark.enabled then return "a_murder_of_crows" end end,

        usable = function () return buff.deathblow.up or target.health_pct < 20 or talent.black_arrow.enabled and target.health_pct > 80, "Requires deathblow, target health below 20 percent (or above 80% with Black Arrow)" end,

        handler = function ()
            removeBuff( "deathblow" )
            if talent.black_arrow.enabled then applyDebuff( "target", "black_arrow" ) end

            --- Legacy / PvP Stuff
            if covenant.venthyr then
                if buff.flayers_mark.up and legendary.pouch_of_razor_fragments.enabled then
                    applyDebuff( "target", "pouch_of_razor_fragments" )
                    removeBuff( "flayers_mark" )
                end
            end

        end,

        impact = function()
            if talent.umbral_reach.enabled and active_enemies > 1 then
                active_dot.black_arrow = min( active_dot.black_arrow, true_active_enemies )
                if talent.beast_cleave.enabled then applyBuff( "beast_cleave" ) end
            end
        end,

        bind = "black_arrow",
        copy = { 53351, 320976, 466930, "black_arrow" }
    },

    -- Your pet removes all root and movement impairing effects from itself and a friendly target, and grants immunity to all such effects for 4 sec.
    masters_call = {
        id = 272682,
        cast = 0,
        cooldown = function() return pvptalent.kindred_beasts.enabled and 22.5 or 45 end,
        gcd = "spell",

        startsCombat = false,
        texture = off,

        handler = function ()
            applyBuff( "masters_call" )
        end,

        copy = 53271, -- Pet's version.

        auras = {
            masters_call = {
                id = 62305,
                duration = 4,
                max_stack = 1
            }
        }
    },

    -- Talent: Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within $d and lasting for $35079d.
    misdirection = {
        id = 34477,
        cast = 0,
        cooldown = function() return 30 - ( 5 * talent.no_hard_feelings.rank ) end,
        gcd = "off",
        school = "physical",

        talent = "misdirection",
        nopvptalent = "interlope",
        startsCombat = false,

        handler = function ()
            applyBuff( "misdirection" )
        end,
    },

    -- Talent: Fires several missiles, hitting all nearby enemies within $A2 yards of your current target for $s2 Physical damage$?s115939[ and triggering Beast Cleave][]. Deals reduced damage beyond $s1 targets.$?s19434[    |cFFFFFFFFGenerates $213363s1 Focus per target hit.|r][]
    multishot = {
        id = 2643,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 40,
        spendType = "focus",

        talent = "multishot",
        startsCombat = true,

        handler = function ()
            applyBuff( "beast_cleave" )

            -- Legacy / PvP Stuff
            if set_bonus.tier30_4pc > 0 then reduceCooldown( "bestial_wrath", 1 ) end
    end,
    },

    -- Talent: Interrupts spellcasting, preventing any spell in that school from being cast for $d.
    muzzle = {
        id = 187707,
        cast = 0,
        cooldown = function() return 15 - 2 * talent.lone_survivor.rank end,
        gcd = "off",
        school = "physical",

        startsCombat = true,
        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            if conduit.reversal_of_fortune.enabled then gain( conduit.reversal_of_fortune.mod, "focus" ) end
            interrupt()
        end,
    },

    primal_rage = {
        id = 272678,
        cast = 0,
        cooldown = 360,
        gcd = "spell",

        toggle = "cooldowns",

        startsCombat = true,
        texture = 136224,

        usable = function () return pet.alive and pet.ferocity, "requires a living ferocity pet" end,
        handler = function ()
            applyBuff( "primal_rage" )
            stat.haste = stat.haste + 0.4
            applyDebuff( "player", "exhaustion" )
        end,
    },

    roar_of_sacrifice = {
        id = 53480,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "roar_of_sacrifice",

        startsCombat = false,
        texture = 464604,

        handler = function ()
            applyBuff( "roar_of_sacrifice" )
        end,
    },

    --[[ Talent: Scares a beast, causing it to run in fear for up to $d.  Damage caused may interrupt the effect.  Only one beast can be feared at a time.
    scare_beast = {
        id = 1513,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 25,
        spendType = "focus",

        talent = "scare_beast",
        startsCombat = false,

        usable = function() return target.is_beast, "requires a beast target" end,

        handler = function ()
            applyDebuff( "tagret", "scare_beast" )
        end,
    }, ]]

    -- Talent: A short-range shot that deals $s1 damage, removes all harmful damage over time effects, and incapacitates the target for $d.  Any damage caused will remove the effect. Turns off your attack when used.$?s321468[    Targets incapacitated by Scatter Shot deal $321469s1% less damage to you for $321469d after the effect ends.][]
    scatter_shot = {
        id = 213691,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "scatter_shot",
        startsCombat = false,

        handler = function ()
            -- trigger scatter_shot [37506]
            applyDebuff( "target", "scatter_shot" )
        end,
    },

    spirit_mend = {
        id = 90361,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 237586,

        handler = function ()
            applyBuff( "spirit_mend" )
        end,
    },

    -- A steady shot that causes $s1 Physical damage.; Usable while moving.$?s321018[; Generates $s2 Focus.][]
    steady_shot = {
        id = 56641,
        cast = 1.7,
        spend = -10,
        spendType = "focus",
        cooldown = 0.0,
        gcd = "spell",

        notalent = "barbed_shot",

        startsCombat = true,
    },

    -- Reduces all damage you and your pet take by $s1% for $d.
    survival_of_the_fittest = {
        id = 264735,
        cast = 0,
        cooldown = function () return ( talent.lone_survivor.enabled and 150 or 180 ) * ( pvptalent.hunting_pack.enabled and 0.5 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( 1 - 0.075 * talent.born_to_be_wild.rank ) + ( conduit.cheetahs_vigor.mod * 0.001 ) end,
        charges = function() return talent.padded_armor.enabled and ( ( talent.lone_survivor.enabled and 150 or 180 ) * ( pvptalent.hunting_pack.enabled and 0.5 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( 1 - 0.075 * talent.born_to_be_wild.rank ) + ( conduit.cheetahs_vigor.mod * 0.001 ) ) or nil end,
        recharge = function() return talent.padded_armor.enabled and 2 or nil end,
        gcd = "off",

        startsCombat = false,

        handler = function()
            applyBuff( "survival_of_the_fittest" )
        end,
    },

    summon_pet = {
        id = 883,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "focus",

        startsCombat = false,
        texture = 'Interface\\ICONS\\Ability_Hunter_BeastCall',

        essential = true,
        nomounted = true,

        usable = function () return not pet.exists, "requires no active pet" end,

        handler = function ()
            summonPet( "made_up_pet", 3600, "ferocity" )
        end,
    },

    -- Hurls a tar trap to the target location that creates a $187699s1 yd radius pool of tar around itself for $13810d when the first enemy approaches. All enemies have $135299s1% reduced movement speed while in the area of effect. Limit $s2. Trap will exist for $13809d.
    tar_trap = {
        id = 187698,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.improved_traps.rank end,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if legendary.nessingwarys_trapping_apparatus.enabled then
                return -45, "focus"
            end
        end,

        talent = "tar_trap",
        startsCombat = false,

        -- Let's not recommend Tar Trap if Flare is on CD.
        timeToReady = function () return max( 0, cooldown.flare.remains - gcd.max ) end,

        handler = function ()
            applyDebuff( "target", "tar_trap" )
        end,
    },

    -- Talent: Removes $s1 Enrage and $s2 Magic effect from an enemy target.$?s343244[    Successfully dispelling an effect generates $343244s1 Focus.][]
    tranquilizing_shot = {
        id = 19801,
        cast = 0,
        cooldown = 10,
        gcd = "totem",
        school = "nature",

        talent = "tranquilizing_shot",
        startsCombat = true,

        toggle = "interrupts",

        usable = function () return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic effect" end,

        handler = function ()
            if talent.devilsaur_tranquilizer.enabled and buff.dispellable_enrage.up and buff.dispellable_magic.up then reduceCooldown( "tranquilizing_shot", 5 ) end
            removeBuff( "dispellable_enrage" )
            removeBuff( "dispellable_magic" )
            if state.spec.survival or talent.improved_tranquilizing_shot.enabled then gain( 10, "focus" ) end
        end,
    },

    -- Sylvanas Legendary / Talent: Fire an enchanted arrow, dealing $354831s1 Shadow damage to your target and an additional $354831s2 Shadow damage to all enemies within $354831A2 yds of your target. Targets struck by a Wailing Arrow are silenced for $355596d.
    wailing_arrow = {
        id = 355589,
        cast = function()
            if buff.lock_and_load.up then return 0 end
            return ( buff.trueshot.up and 1 or 2 ) * haste
        end,
        cooldown = 60,
        gcd = "spell",

        spend = function()
            if buff.lock_and_load.up then return 0 end
            return 15 * ( buff.trueshot.up and 0.5 or 1 )
        end, -- TODO: Does game match spell data?
        spendType = "focus",

        toggle = "cooldowns",
        startsCombat = true,

        usable = function ()
            if moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
            return true
        end,

        handler = function ()
            removeStack( "lock_and_load" )
            interrupt()
            applyDebuff( "target", "wailing_arrow" )
            if talent.readiness.enabled then
                setCooldown( "rapid_fire", 0 )
                gainCharges( "aimed_shot", 2 )
            end
        end,

        copy = { 392060, 355589 }
    },

    -- Maims the target, reducing movement speed by $s1% for $d.
    wing_clip = {
        id = 195645,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 20,
        spendType = "focus",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "wing_clip" )
        end,
    },

    -- Utility
    mend_pet = {
        id = 136,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        startsCombat = false,

        usable = function ()
            if not pet.alive then return false, "requires a living pet" end
            return true
        end,
    },
} )

spec:RegisterRanges( "arcane_shot", "kill_command", "wing_clip" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageExpiration = 3,

    potion = "tempered_potion",
    package = "Beast Mastery",
} )

spec:RegisterSetting( "barbed_shot_grace_period", 0, {
    name = strformat( "%s Grace Period", Hekili:GetSpellLinkWithTexture( spec.abilities.barbed_shot.id ) ),
    desc = strformat( "If set above zero, %s's cooldown will be reduced by this number of global cooldowns. This feature helps to ensure that you maintain %s stacks by recommending %s with time remaining on %s.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.barbed_shot.id ), Hekili:GetSpellLinkWithTexture( spec.auras.frenzy.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.barbed_shot.id ), Hekili:GetSpellLinkWithTexture( spec.auras.frenzy.id ) ),
    icon = 2058007,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "range",
    min = 0,
    max = 2,
    step = 0.01,
    width = 1.5
} )

spec:RegisterSetting( "pet_healing", 0, {
    name = strformat( "%s Below Health %%", Hekili:GetSpellLinkWithTexture( spec.abilities.mend_pet.id ) ),
    desc = strformat( "If set above zero, %s may be recommended when your pet falls below this health percentage. Setting to |cFFFFd1000|r disables this feature.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.mend_pet.id ) ),
    icon = 132179,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = 1.5
} )

spec:RegisterSetting( "avoid_bw_overlap", false, {
    name = strformat( "Avoid %s Overlap", Hekili:GetSpellLinkWithTexture( spec.abilities.bestial_wrath.id ) ),
    desc = strformat( "If checked, %s will not be recommended if the buff is already active.", Hekili:GetSpellLinkWithTexture( spec.abilities.bestial_wrath.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "mark_any", false, {
    name = strformat( "%s Any Target", Hekili:GetSpellLinkWithTexture( spec.abilities.hunters_mark.id ) ),
    desc = strformat( "If checked, %s may be recommended for any target rather than only bosses.", Hekili:GetSpellLinkWithTexture( spec.abilities.hunters_mark.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "check_pet_range", false, {
    name = strformat( "Check Pet Range for %s", Hekili:GetSpellLinkWithTexture( spec.abilities.kill_command.id ) ),
    desc = function ()
        return strformat( "If checked, %s will only be recommended if your pet is in range of your target.\n\n" ..
                          "Requires |c" .. ( state.settings.petbased and "FF00FF00" or "FFFF0000" ) .. "Pet-Based Target Detection|r",
                          Hekili:GetSpellLinkWithTexture( spec.abilities.kill_command.id ) )
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "barbed_shot_opener", true, {
    name = strformat( "Use %s Opener", Hekili:GetSpellLinkWithTexture( spec.abilities.barbed_shot.id ) ),
    desc = strformat( "If checked, %s will be recommended as the first ability in combat. This differs from SimulationCraft behavior which uses %s first but aligns with written guides. The %s opener ensures your pets immediately move to the target at the start of the fight.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.barbed_shot.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.bestial_wrath.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.barbed_shot.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Beast Mastery", 20250826, [[Hekili:T31EpUTTw(pltV46yNmJTL84mtYoEa6nfl2u0wuSU72)4I1YYwYJfgBjFLKhN5Ib(Z(EoK6bL4drjBNjT1OfjoIKh(78KKhsrnXyYVnzSJDS7KFXSV5W(3A((Ugxp42H3mzC8ZBCNmEJ98hTFa(HV9A4p)hU2rX7N(ZWF6g(mw8ZRcSDqYefSnCouLLXXBI(yVEp4fVC7SUZdw3lYB92v2XEb(ZdTxeJ)759MTkywV4LU7Sd3bv1ZV33phRYVg6fe6f)8p5ffh1ZXDH92vX9wU1h6rRzy)BTM29Dr6mz8STERI)S)KzIzL3pzS924LbHtgp2B9Naa6544sRUBe0(RUA)0FBP7(P)UDi8heSSF6yONcG)EW(FeP3v9V9kZ3)X9t)86nHbpb1ogBY35eSD2k4hrX2R3464(D7NUyRpHrSxbCbtRhaT(7)1Fci9Z(Z3pf61HlM1FH5151XWKRo3CTJZS5g51P)1qD(1q3vER98TdFE)udJUM0M9J4)PMFmtP0GRm(aqjuMSF6)Zgu0TF68BNpB4I5m1b7TV3Xz)01ErrE(pa1zPT)dqDxegSE)0nHUp5fSnkLsBPukNa9)yXIUC)uBKEZSdNbYTLbG9uWgxF3q8VrbxAJnVY8wOX)2V)7SWVupyELXnceigjceOsxFLHbGKsWikTS(u9QSYW2b0RF3HjpS)hUY08Jcy3RjAz5f13ak6)2nAJ7CGL)Vig0VjcDMcFeeeUXXO4nP63CL5nPs(pzVAfiBwKyZ97ERGhgBVY1pg1gUZFm6)a6UiOSpfqilabqUM(WsDvEpG8wzlLjJxHoEKadHZx5A)Kl87FHePWMyxpz8JERwzHAUjJD9Tb7FNj)JjXGJhwP8NmEo4h7g6zd)kiyLtWo)UZbEXkyHfWjw7agPBO7ABpFaB3dk3(7N(Yl7NErk7Xx9uQNHLzUrXE2RS2fAhVebXGsGiRIG9MRtcSZr2ITqpe6cg1Hp4Af7Tgeh3TF6dZD6U2(lqnFgecwXyPGubKdqxCnRWaIJf4eTeXubHXqPcJzBxSOlnsgva3ffn7N2A)02SmpHYpBTi01)F)CkNtLqAip7Kdri6BShHXbC9EwWxU5L4HBKYdjqecX77apX)bRLbqyXiEfK7x2SkiY7jxRueCB90quvteihStIRcglJyKbeZryCM12(oD5RTyD4h4mOtOqjrGrFPYGfbZ3g1fnzSIdGbL(cRLZ(PVfmOzK0bZcTZebgf8NkjIkaa4FgdY3hDj(Ku)qg0eSbg51noNwpzdydkf)1QTUzAkzEsPMDyCCle7gCvfSLOwDS2LOfVcAKvNSg3wh)AcLUqvp1jTZs8Iy8(7UDtjVJIfN4Ay9Ww3OiIUAiXnbezw0P3G00kcg6fIiy78SOyAjcCVfIf5IOePxznCoC5qI21YDvKRwrxlkwYixg4smw0rYjki7XXmKOs5QrQwvP1NytVJUDNqJoX6DusaJDMoCrTewgSK0XEnmd8YeT8Wlvt0(YiAQrq6GdccnNeccWv0QGy2)nmddqGUaL9y0j2HiO1PBSr3L2rwyfrPtQ)Bk(6wYPJR8e6yzyffhgat9mmXEiL(MDZmBZh9lBMehu)OaQ5tBHHrZaIZ2qYcE2pThUgcITtag1b(XcVhwgxdk8U8zgXWZCYuLYJ7vZfWsgmgwnvUIeY8o10QL6IbU56HeavsoKjIs0DCkgtofJsWQrvog8dovebQhzDgw9k6TJJfxb8iSE3jxfunkExvuNxb3j9)LlQs9lRG)r5Df16oXDrzPubmDrbEsuqlwwgN)oD9cGkTVQ4n0O2mZD5c1EYvfvQstnEzSO(qny1tlujusQxUqwwyqqHzo8iX(Iw7sPHYmlnuMPwdLvHYs3HymLXngh3HY4JyQBGffUmAouMqkiAOmbEAkLh1FOmru5ye6V5dLXphdLGvJQCm4hHdLjVZoUdLPWItMd)jyOmHux3HYmo9dLPyaFPdLjoOfllFKgkRIj6Fir)QOpo6dLjjWZXyOS6X(0uaLSniCzIDonFVstgB(GE2()RTER8(3yQ6eu7YlOpFSVna0w6AVkEP1gmX1aZbpYcFeqlMKm667ybLiAfV5uRDwMUJ6U2o8rlB)NtxEpMEUUErwzHobbivfA5eaGGWQrwRj5lNAO2kRDPPHdWO1T9tuw5OJTXIw(CHeIs)hwyIWPPdpzrZZDuUizLTnrlhPvAvNTYEoiAcdd2vohBjcexF31EUj2A5U8jnNn3YSTxqJhSNntXkzbNWiH5V9qG)9zWVUyhAPrDWEYEzKM6xH4NndqAZcFf1au5VIus3ig4RLoitdeN9Bbz0U0(KSmyxwg7WnJ2cAOdeXJpuj7CFOBlRv6UYMPEGypq4fFmT972nW66nZlW4zBuIg7Zu5edNvXMSptuuCO70rbErzQoZOOGmgtM4csiIOpA761bSZNrcJCR4TzzGoBvM8HliMaVABv2WASvzLhu44Svz3O5UujpKSgBsvYKzOEBpatoXdWzxW3z(Jex8bLJUPWnPW2CfNmMX59pUP7FCDm(0WmrworkYBcq8TfN0zMoUa5JPZqQ6y6s3INQvC0f2Tv6w)Pyk5gdy16HrUHpItGvPD3RjCFFjBeRfBdFw9C1)gbU2(ZHMhcnh7inIW)6a5pKJ4fEHUeHSO1g8nbyhyKJ2nbK)M4XXeE91BsuFTMMKgZXOIiL6h6v84qvndng2s4e0ArKGTtScq1GfEo6iWf(by7WoGw2W0T0Pb8JRt7n9NhhBx2rYikkwaCLdJCJMdJSbWvW6z28tDGYgK8mOEUdvVF48PilvlQBkNKMHT0Ob5uWlQ7ApyXyHOTjXGyBiiQIdwhGlrlkLQmKS6MuaLYYlQ6uhwMe5zcSutZlqEtgjRjTQcNJQcN1zt6QxUp)tUqJEkNd92q9c(bxis2Ap)0dWCEQitif8Ja4XpJh)y8CzNhBlQ7(PFgOkspxFhYzbEtYH1(J04t7N6UyH78yA0l6zmj7zxUF6QK(6EYb)nmg)Dg5Lvo5eNJIeeaJ34o3ddKcp2LI15b(r4kw2p9NjUl0Jk7)zQdZ(P)wUhZox7hjm7sBGtcarqihYJ8GPVSFQh(7nb7WA4HpEZkpaiZCJ3566Ni(Cw)qAl3pfIoM8ywk2L9y3KMd489)r0e60k2LI9usupAwOhR)rss6Wp5MBVL4Bzq2qf6p6r(HjPO8bweAy(50J3SVnO2qnmnu)(PF6hOkGuJdQUlEPhAXSdAXUa)3aI)hqJxZ8JIp0KE7ypi)Gre2EcFMlGknlh1J)NL7AMH6SONEDXddMSm4NG1BGLL8Ujyyoz8o7qFKutgtoc2ER3ag8WWYOb8BsZw8B2pn09FT1JyhhfGHfS3cJayhJpGEs8b3IF8NiE045y)tb(qNrkoLkDlgM8nu3M3ijkkuCBJV0PsIYVX7CewyvoHeVsYkikPaPHO6OfQBk5pze(1g3MQn84kwl02mBJtkXprK9mMpJ5VnXCtJyOjQBk5pze(mUBgUlyBz78SAJpAf0cX1NW1HKsfcIRtDrCTiFLe(Km7oMvIkYsGPmTi35jcCwqCmi7RcMH13r9fHvuIVk1Y8TA1w2b0LPKK2YSA9xErbO68Ylx0iQkbmeIEpRRC5ao)9bTWTHOvHTGqzlENz)c8qbzIcE7E5i8kJHQA5vdVtEBBjVO3D9W7lWxewfKXkoKETARaiklSPO8(rLeO8e((rkOCZ18m9QGYVJx0PQVENkAvun0PthzmmANRGFm7RO07erYCUL0Rxi1zMf(PJ3nQVy)rm1pp52Pv7lK5hCiraKst5qrTmtzhcLJcg(Ga3zo8ayJkMyYFocE27CWZ)Ig8S3FPcE27CWZVUbpZMB6nNIfwiJOgCirvAbYRYjK4vswbwRAToBnrDtj)jJWV24(Gs)WX124Ks8tezpJ5Zy(Btm30igAI6Ms(tgHpJ7MH7c2wIsfVGkOfIRpHRdjLkeexN6I4Ar(kj8jz2DMkYXVP8C8FEIavs2ZcIdGSVkywEo(LUu0QtOKPOv3XdQAMMkZAMMkbb1Rih)cArX0uzijnv88MUPPIVLnnbq6NMkdrPPIhiklSPOSuAQer4dpnvc18It0WbNMkb0svAQkp09rinvcgyLlh)LDMzHFdstL0uyx)iasP5rinvcClRxAQ0LnQyIj)5i4zf54)CWZ)0g8S3FPcEYLJ)ZbppTbp7I3E)cEzaYEB4EtTEBamvUwY0UxsiBMIlmBCze9GwZJAK2Wv9khPv9I1ja9A0eT68QFR(eWLA0en7CoFCrR7xqDoPKVscli2KQL6vxC3uYxjHBy(vuGZMCKm)dl6QuPC2wvBYRbH)Js87MQ6oXKVsc3uvNM4UPKVsc)nFCIVTrxLkLZ2QAtEztqo9Y97n1A(XdlHo8IUeNjozbb8x6yPiuAPjSUqe2e8D9PcFFManKM3sVs)WxpAYx9jO4jJXpqvt(fZHdW7HJGfE4lb(F7VTF6x5pSB7)rSthN1dFc7buISEn(E4JFG0(iZNqnSY)aiiHNL)9Ad5wkdg1nBvuVBuV8BreOHq7oFPi81(srqSEjDTZxIVA(Jse(mPA6sYLrWOlkobJuHv(YR5sdG4zKWKCJQxIxE(oQEfz5iruwIuegSqdthT5obJojSIJeuXwkqYifiPqQF0uEYkI(dlBxhlttoltf5jLgJ6Fo(5qVf)FK7q9V3XjW)kmER3cV55xPhux41Gxj4mv6dmjU9KqiGemc1ki0fhwX2H0T7N()sVQjapVOR2bHHIr)s63Qr63LqhphY9LHlcz6x9rWQfCkx9Cxs4WV7R6DXX3PJaV0L0rI0MmuNQ7KK3224DTn6128Tpm3PdQBlRc(jxmIgyahgHJaheGbq3T0LgeevdlcwTkaW(dB9qP)m3L24h8smIkYaERzFMqwH5(a5sVfJuChIK1EOvSxT3SpN)Q8MT00BHBSJkEZDFhZT2nBlyVzSXw1M7(5gC6kC3C3PfnfQC3k3J63s4TX99M9lWzLUKGPQ45orvxPeVknQjEXJISd)1HCR2jWp5Am(otmsh)nFCRsvBqhD6vAB1RNV3efTv1X3BOrhtz2lQUppMCBoVQrhxdML6MM6kbggac88Fk4rOAFbS28TxrgVHIcY0rS88xSfJ7HOHexqW10yoasV4)A1w0hoUo5IOYuPv7K5xx86B8LxYgjr4xoV7g0hiAXnlW495HlO8y(TsQAUqk4KGnb7uHXaUop7og9035CCEXBm0xbaKDbGEY77puURP3MNN8(DGrQJf74F)CGdm3dCbb4yDPlAfMpp4MDzYS3N5YpnJIEOep5rfGrg)O7Dp6vvoA(DvwJ)o4i)2(Dhccm(lP0mV)SRVAgnbHdiUGhcpKVD2LMWYbaiMjpu4k1CKbcp(BXZ7azaeoI7Uh9(rzOTIRr(mCXzTLrboJuY(q)YlCx1OTeaWBfXMzF0o5llt8KoPgfzbbxBIGReEM4ZcGoD)xf0ZLRRGQu8oBNzCFU77DbnMvriQ7ZUHujQ6Y3K7OM(TWOQjMOfV52VFqEudg7R8EjDQkPWOO9htPCUevkkjBGUSqwI7JMyLlMs8gsmL(v3uIPV1sq0eZj9LJhsub5woCgWSmToMWAijkA5gflZQLuYj0InQ8c6AK1kLkISujLujaKj2RcD89uM65Kn5GO4V1NyqUurS1tTqB9Mcq5U(WmSQW4rMvhNjvLHkuFlN36I2sviP(BaUBvvLObhADHotQajyh9LMLLzfCdslknzdVRC2OqGZCmttYgL0vmQ4tRFNASK02sxeWfLPrNgUmv6h497g2PMcbsJVmyZiYxg)e5HoD1L5Fg7Roinl6l)fS)Y5b(oEiKhPVyQwCjw1NCRqxxJmpislxtLSqDSgmf)xu(e2YOMnov4tBDFHTg3CaVy31xI)i5ZRleod)47MMopsWnz71qnoC3IUnfyY)F(5fToNy8AERWiypfu)22iObfoV4sUsy45lnpT48nSPhdB9pS4IUqy4XHQYAkglEuXfr3d(KIluJZUxK8BfwdpN4ciLIJjEbM9OCkXfSxALFdBKDpWWS1C6FeXB0TaJqhEzu8WpF4c8dR3XdxtEOPXwnzJTEKFDCmo0yR18TXrO9NQyRcAqHyRsEvC45lnJTY3WMg3s)yRIErC4XHQYAkglgBveDp4yRc14QpDfnm2QasPi2QXrp2QWrrkgBvXHTO(XwB0BFJqhEzu8WJTkWpSEXw1KhiFJoM8))d]] )