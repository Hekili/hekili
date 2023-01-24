-- HunterBeastMastery.lua
-- October 2022

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local PTR = ns.PTR

local spec = Hekili:NewSpecialization( 253, true )


spec:RegisterResource( Enum.PowerType.Focus, {
    aspect_of_the_wild = {
        resource = "focus",
        aura = "aspect_of_the_wild",

        last = function ()
            local app = state.buff.aspect_of_the_wild.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 5,
    },

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
spec:RegisterTalents( {
    -- Hunter
    alpha_predator              = { 79904, 269737, 1 }, -- Kill Command now has 2 charges, and deals 15% increased damage.
    arctic_bola                 = { 79815, 390231, 2 }, -- Cobra Shot has a chance to fling an Arctic Bola at your target, dealing 0 Frost damage and snaring the target by 20% for 3 sec. The Arctic Bola strikes up to 2 targets.
    barrage                     = { 79914, 120360, 1 }, -- Rapidly fires a spray of shots for 2.6 sec, dealing an average of 3,396 Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond 8 targets.
    beast_master                = { 79926, 378007, 2 }, -- Pet damage increased by 3%.
    binding_shackles            = { 79920, 321468, 1 }, -- Targets rooted by Binding Shot, knocked back by High Explosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal 10% less damage to you for 8 sec after the effect ends.
    binding_shot                = { 79937, 109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within 5 yards for 10 sec, stunning them for 3 sec if they move more than 5 yards from the arrow.
    born_to_be_wild             = { 79933, 266921, 2 }, -- Reduces the cooldowns of Aspect of the Cheetah, Survival of the Fittest, and Aspect of the Turtle by 7%.
    camouflage                  = { 79934, 199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for 1 min. While camouflaged, you will heal for 2% of maximum health every 1 secs.
    concussive_shot             = { 79906, 5116  , 1 }, -- Dazes the target, slowing movement speed by 50% for 6 sec. Cobra Shot will increase the duration of Concussive Shot on the target by 3.0 sec.
    death_chakram               = { 79916, 375891, 1 }, -- Throw a deadly chakram at your current target that will rapidly deal 595 Physical damage 7 times, bouncing to other targets if they are nearby. Enemies struck by Death Chakram take 10% more damage from you and your pet for 10 sec. Each time the chakram deals damage, its damage is increased by 15% and you generate 3 Focus.
    entrapment                  = { 79977, 393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for 4 sec. Damage taken may break this root.
    explosive_shot              = { 79914, 212431, 1 }, -- Fires an explosive shot at your target. After 3 sec, the shot will explode, dealing 4,085 Fire damage to all enemies within 8 yards. Deals reduced damage beyond 5 targets.
    high_explosive_trap         = { 79910, 236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 1,079 Fire damage and knocking all enemies away. Trap will exist for 1 min.
    hunters_avoidance           = { 79832, 384799, 1 }, -- Damage taken from area of effect attacks reduced by 6%.
    hydras_bite                 = { 79911, 260241, 1 }, -- Serpent Sting fires arrows at 2 additional enemies near your target, and its damage over time is increased by 20%.
    improved_kill_command       = { 79932, 378010, 2 }, -- Kill Command damage increased by 5%.
    improved_kill_shot          = { 79930, 343248, 1 }, -- Kill Shot's critical damage is increased by 25%.
    improved_tranquilizing_shot = { 79919, 343244, 1 }, -- When Tranquilizing Shot successfully dispels an effect, gain 10 Focus.
    improved_traps              = { 79923, 343247, 2 }, -- The cooldown of Tar Trap, Steel Trap, High Explosive Trap, and Freezing Trap is reduced by 2.5 sec.
    intimidation                = { 79910, 19577 , 1 }, -- Commands your pet to intimidate the target, stunning it for 5 sec.
    keen_eyesight               = { 79922, 378004, 2 }, -- Critical strike chance increased by 2%.
    killer_instinct             = { 79904, 273887, 1 }, -- Kill Command deals 50% increased damage against enemies below 35% health.
    lone_survivor               = { 79820, 388039, 1 }, -- Reduce the cooldown of Survival of the Fittest by 30 sec, and increase its duration by 2.0 sec.
    master_marksman             = { 79913, 260309, 2 }, -- Your melee and ranged special attack critical strikes cause the target to bleed for an additional 7% of the damage dealt over 6 sec.
    misdirection                = { 79924, 34477 , 1 }, -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within 30 sec and lasting for 8 sec.
    natural_mending             = { 79925, 270581, 2 }, -- Every 30 Focus you spend reduces the remaining cooldown on Exhilaration by 1.0 sec.
    natures_endurance           = { 79820, 388042, 1 }, -- Survival of the Fittest reduces damage taken by an additional 20%.
    pathfinding                 = { 79918, 378002, 2 }, -- Movement speed increased by 2%.
    poison_injection            = { 79911, 378014, 1 }, -- Serpent Sting's damage applies Latent Poison to the target, stacking up to 10 times. Barbed Shot consumes all stacks of Latent Poison, dealing 389 Nature damage to the target per stack consumed.
    posthaste                   = { 79921, 109215, 2 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by 25% for 4 sec.
    rejuvenating_wind           = { 79909, 385539, 2 }, -- Exhilaration heals you for an additional 10.0% of your maximum health over 8 sec.
    scare_beast                 = { 79927, 1513  , 1 }, -- Scares a beast, causing it to run in fear for up to 20 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time.
    scatter_shot                = { 79937, 213691, 1 }, -- A short-range shot that deals 84 damage, removes all harmful damage over time effects, and incapacitates the target for 4 sec. Any damage caused will remove the effect. Turns off your attack when used.
    sentinel_owl                = { 79819, 388045, 1 }, -- Call forth a Sentinel Owl to the target location within 40 yds, granting you unhindered vision. Your attacks ignore line of sight against any target in this area. While the Sentinel Owl is active, your party gains 5% Leech. Every 150 Focus spent grants you 1 sec of the Sentinel Owl when cast, up to a maximum of 12 sec. The Sentinel Owl can only be summoned when it will last at least 5 sec.
    sentinels_perception        = { 79818, 388056, 1 }, -- Sentinel Owl now also grants unhindered vision to party members while active.
    sentinels_protection        = { 79818, 388057, 1 }, -- While the Sentinel Owl is active, your party gains 5% Leech.
    serpent_sting               = { 79905, 271788, 1 }, -- Fire a shot that poisons your target, causing them to take 310 Nature damage instantly and an additional 2,150 Nature damage over 18 sec. Serpent Sting's damage applies Latent Poison to the target, stacking up to 10 times. Barbed Shot consumes all stacks of Latent Poison, dealing 389 Nature damage to the target per stack consumed.
    serrated_shots              = { 79814, 389882, 2 }, -- Serpent Sting and Bleed damage increased by 10%. This value is increased to 20% against targets below 30% health.
    stampede                    = { 79916, 201430, 1 }, -- Summon a herd of stampeding animals from the wilds around you that deal 3,478 Physical damage to your enemies over 12 sec. Enemies struck by the stampede are snared by 30%, and you have 10% increased critical strike chance against them for 5 sec.
    steel_trap                  = { 79908, 162488, 1 }, -- Hurls a Steel Trap to the target location that snaps shut on the first enemy that approaches, immobilizing them for 20 sec and causing them to bleed for 3,476 damage over 20 sec. Damage other than Steel Trap may break the immobilization effect. Trap will exist for 1 min. Limit 1.
    survival_of_the_fittest     = { 79821, 264735, 1 }, -- Reduces all damage you and your pet take by 20% for 8 sec.
    tar_trap                    = { 79928, 187698, 1 }, -- Hurls a tar trap to the target location that creates a 8 yd radius pool of tar around itself for 30 sec when the first enemy approaches. All enemies have 50% reduced movement speed while in the area of effect. Trap will exist for 1 min.
    trailblazer                 = { 79931, 199921, 2 }, -- Your movement speed is increased by 15% anytime you have not attacked for 3 seconds.
    tranquilizing_shot          = { 79907, 19801 , 1 }, -- Removes 1 Enrage and 1 Magic effect from an enemy target. Successfully dispelling an effect generates 10 Focus.
    wilderness_medicine         = { 79936, 343242, 2 }, -- Mend Pet heals for an additional 25% of your pet's health over its duration, and has a 25% chance to dispel a magic effect each time it heals your pet.

    -- BeastMastery
    a_murder_of_crows           = { 79943, 131894, 1 }, -- Summons a flock of crows to attack your target, dealing 9,648 Physical damage over 15 sec. If the target dies while under attack, A Murder of Crows' cooldown is reset.
    animal_companion            = { 79947, 267116, 1 }, -- Your Call Pet additionally summons the first pet from your stable. This pet will obey your Kill Command, but cannot use pet family abilities and both of your pets deal 35% reduced damage.
    aspect_of_the_beast         = { 79944, 191384, 1 }, -- Increases the damage and healing of your pet's abilities by 30%. Increases the effectiveness of your pet's Predator's Thirst, Endurance Training, and Pathfinding passives by 50%.
    aspect_of_the_wild          = { 79950, 193530, 1 }, -- Fire off a Cobra Shot at your current target and 1 other enemy near your current target. For the next 20 sec, your Cobra Shot will fire at 1 extra target and Cobra Shot Focus cost reduced by 10.
    barbed_shot                 = { 79968, 217200, 1 }, -- Fire a shot that tears through your enemy, causing them to bleed for 4,612 damage over 8 sec and increases your critical strike chance by 3% for 8 sec, stacking up to 3 times. Sends your pet into a frenzy, increasing attack speed by 30% for 8 sec, stacking up to 3 times. Generates 20 Focus over 8 sec.
    barbed_wrath                = { 79822, 231548, 1 }, -- Barbed Shot reduces the cooldown of Bestial Wrath by 12.0 sec.
    beast_cleave                = { 79956, 115939, 2 }, -- After you Multi-Shot, your pet's melee attacks also strike all nearby enemies for 35% of the damage for the next 3.0 sec. Deals reduced damage beyond 8 targets.
    bestial_wrath               = { 79955, 19574 , 1 }, -- Sends you and your pet into a rage, instantly dealing 1,312 Physical damage to its target, and increasing all damage you both deal by 25% for 15 sec. Removes all crowd control effects from your pet. Bestial Wrath's remaining cooldown is reduced by 12 sec each time you use Barbed Shot and activating Bestial Wrath grants 2 charges of Barbed Shot.
    bloodshed                   = { 79943, 321530, 1 }, -- Command your pet to tear into your target, causing your target to bleed for 3,028 over 18 sec and increase all damage taken from your pet by 15% for 18 sec.
    bloody_frenzy               = { 79946, 378739, 1 }, -- While Call of the Wild is active, Barbed Shot affects all of your summoned pets.
    brutal_companion            = { 79816, 386870, 1 }, -- When Barbed Shot causes Frenzy to stack up to 3, your pet will immediately use its special attack and deal 50% bonus damage.
    call_of_the_wild            = { 79967, 359844, 1 }, -- You sound the call of the wild, summoning 2 of your active pets for 20 sec. During this time, a random pet from your stable will appear every 4 sec to assault your target for 6 sec.
    cobra_senses                = { 79963, 378244, 1 }, -- Cobra Shot reduces the cooldown of Kill Command by an additional 1.0 sec.
    cobra_shot                  = { 79949, 193455, 1 }, -- A quick shot causing 1,596 Physical damage. Reduces the cooldown of Kill Command by 2 sec.
    cobra_sting                 = { 79941, 378750, 2 }, -- Cobra Shot has a 25% chance to make your next Kill Command consume no Focus.
    counter_shot                = { 79912, 147362, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for 3 sec.
    dire_beast                  = { 79959, 120679, 1 }, -- Summons a powerful wild beast that attacks the target and roars, increasing your Haste by 5% for 8 sec.
    dire_command                = { 79953, 378743, 3 }, -- Kill Command has a 30% chance to also summon a Dire Beast to attack your target for 8 sec.
    dire_frenzy                 = { 79823, 385810, 2 }, -- Dire Beast lasts an additional 1 sec and deals 20% increased damage.
    dire_pack                   = { 79940, 378745, 1 }, -- Every 5 Dire Beasts summoned resets the cooldown of Kill Command, and reduces the Focus cost and cooldown of Kill Command by 50% for 8 sec.
    hunters_prey                = { 79951, 378210, 1 }, -- Kill Command has a 10% chance to reset the cooldown of Kill Shot, and causes your next Kill Shot to be usable on any target, regardless of the target's health.
    kill_cleave                 = { 79954, 378207, 1 }, -- While Beast Cleave is active, Kill Command now also strikes nearby enemies for 50% of damage dealt.
    kill_command                = { 79935, 34026 , 1 }, -- Give the command to kill, causing your pet to savagely deal 2,734 Physical damage to the enemy.
    kill_shot                   = { 79835, 53351 , 1 }, -- You attempt to finish off a wounded target, dealing 4,763 Physical damage. Only usable on enemies with less than 20% health. Kill Shot deals 25% increased critical damage.
    killer_cobra                = { 79961, 199532, 1 }, -- While Bestial Wrath is active, Cobra Shot resets the cooldown on Kill Command.
    killer_command              = { 79939, 378740, 2 }, -- Kill Command damage increased by 5%.
    kindred_spirits             = { 79957, 56315 , 2 }, -- Increases your maximum Focus and your pet's maximum Focus by 20.
    master_handler              = { 79962, 389654, 1 }, -- Each temporary beast summoned reduces the cooldown of Aspect of the Wild by 2.0 sec.
    multishot                   = { 79917, 2643  , 1 }, -- Fires several missiles, hitting all nearby enemies within 8 yards of your current target for 237 Physical damage and triggering Beast Cleave. Deals reduced damage beyond 5 targets.
    one_with_the_pack           = { 79960, 199528, 2 }, -- Wild Call has a 20% increased chance to reset the cooldown of Barbed Shot.
    pack_tactics                = { 79958, 321014, 1 }, -- Passive Focus generation increased by 100%.
    piercing_fangs              = { 79961, 392053, 1 }, -- While Bestial Wrath is active, your pet's critical damage dealt is increased by 35%.
    scent_of_blood              = { 79965, 193532, 2 }, -- Activating Bestial Wrath grants 1 charge of Barbed Shot.
    sharp_barbs                 = { 79945, 378205, 2 }, -- Barbed shot damage increased by 1%.
    snake_bite                  = { 79962, 389660, 1 }, -- While Aspect of the Wild is active, Cobra Shot deals 30% increased damage.
    stomp                       = { 79942, 199530, 2 }, -- When you cast Barbed Shot, your pet stomps the ground, dealing 376 Physical damage to all nearby enemies.
    thrill_of_the_hunt          = { 79964, 257944, 3 }, -- Barbed Shot increases your critical strike chance by 3% for 8 sec, stacking up to 1 time.
    training_expert             = { 79948, 378209, 2 }, -- All pet damage dealt increased by 5%.
    wailing_arrow               = { 79938, 392060, 1 }, -- Fire an enchanted arrow, dealing 5,225 Shadow damage to your target and an additional 2,118 Shadow damage to all enemies within 8 yds of your target. Non-Player targets struck by a Wailing Arrow have their spellcasting interrupted and are silenced for 3 sec.
    war_orders                  = { 79952, 393933, 2 }, -- Barbed Shot deals 10% increased damage, and applying Barbed Shot has a 25% chance to reset the cooldown of Kill Command.
    wild_call                   = { 79966, 185789, 1 }, -- Your auto shot critical strikes have a 20% chance to reset the cooldown of Barbed Shot.
    wild_instincts              = { 79946, 378442, 1 }, -- While Call of the Wild is active, Barbed Shot has a 25% chance to gain a charge any time Focus is spent.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting     = 3604, -- (356719) Stings the target, dealing 1,906 Nature damage and initiating a series of venoms. Each lasts 3 sec and applies the next effect after the previous one ends.  Scorpid Venom: 90% reduced movement speed.  Spider Venom: Silenced.  Viper Venom: 20% reduced damage and healing.
    diamond_ice         = 5534, -- (203340) Victims of Freezing Trap can no longer be damaged or healed. Freezing Trap is now undispellable, but has a 5 sec duration.
    dire_beast_basilisk = 825 , -- (205691) Summons a slow moving basilisk near the target for 30 sec that attacks the target for heavy damage.
    dire_beast_hawk     = 824 , -- (208652) Summons a hawk to circle the target area, attacking all targets within 10 yards over the next 10 sec.
    dragonscale_armor   = 3600, -- (202589) Magical damage over time effects deal 20% less damage to you.
    hunting_pack        = 3730, -- (203235) Aspect of the Cheetah has 50% reduced cooldown and grants its effects to allies within 15 yds.
    interlope           = 1214, -- (248518) The next hostile spell cast on the target will cause hostile spells for the next 3 sec. to be redirected to your pet. Your pet must be within 10 yards of the target for spells to be redirected.
    kindred_beasts      = 5444, -- (356962) Command Pet's unique ability cooldown reduced by 50%, and gains additional effects. Ferocity: Primal Rage increases Haste by 12% for 20 sec, but no longer applies Sated.
    roar_of_sacrifice   = 3612, -- (53480) Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but 20% of all damage taken by that target is also taken by the pet. Lasts 12 sec.
    survival_tactics    = 3599, -- (202746) Feign Death dispels all harmful magical effects, and reduces damage taken by 90% for 1.5 sec.
    the_beast_within    = 693 , -- (356976) Bestial Wrath inspires you and all nearby allied pets for 8 sec, increasing attack speed by 10% and providing immunity to Fear and Horror effects.
    tranquilizing_darts = 5418, -- (356015) Interrupting or removing effects with Tranquilizing Shot and Counter Shot releases 8 darts at nearby enemies, each reducing the duration of a beneficial Magic effect by 4 sec.
    wild_kingdom        = 5441, -- (356707) Call in help from one of your dismissed Cunning pets for 10 sec. Your current pet is dismissed to rest and heal 30% of maximum health.
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
    -- Talent: Slowed by $s2%.
    -- https://wowhead.com/beta/spell=390232
    arctic_bola = {
        id = 390232,
        duration = 3,
        type = "Ranged",
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=186257
    aspect_of_the_cheetah_sprint = {
        id = 186257,
        duration = 3,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=186258

    aspect_of_the_cheetah = {
        id = 186258,
        duration = function () return conduit.cheetahs_vigor.enabled and 12 or 9 end,
        max_stack = 1,
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
    -- Talent: Cobra Shot Focus cost reduced by $s2.  Cobra Shot will fire at $s1 additional $Ltarget:targets;.$?$w3!=0[  Cobra Shot damage increased by $w3%.][]
    -- https://wowhead.com/beta/spell=193530
    aspect_of_the_wild = {
        id = 193530,
        duration = 20,
        type = "Ranged",
        max_stack = 1
    },
    -- Talent: Suffering $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=217200
    barbed_shot = {
        id = 246152,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
    },
    barbed_shot_2 = {
        id = 246851,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
    },
    barbed_shot_3 = {
        id = 246852,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
    },
    barbed_shot_4 = {
        id = 246853,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
    },
    barbed_shot_5 = {
        id = 246854,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
    },
    barbed_shot_6 = {
        id = 284255,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
    },
    barbed_shot_7 = {
        id = 284257,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
    },
    barbed_shot_8 = {
        id = 284258,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
    },
    barbed_shot_dot = {
        id = 217200,
        duration = 8,
        tick_time = 2,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 1,
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=120360
    barrage = {
        id = 120360,
        duration = 3,
        tick_time = 0.2,
        max_stack = 1
    },
    beast_cleave = {
        id = 118455,
        duration = 4,
        max_stack = 1,
        generate = function ()
            local bc = buff.beast_cleave
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 118455 )

            if name then
                bc.name = name
                bc.count = 1
                bc.expires = expires
                bc.applied = expires - duration
                bc.caster = caster
                return
            end

            bc.count = 0
            bc.expires = 0
            bc.applied = 0
            bc.caster = "nobody"
        end,
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
        max_stack = 1,
    },
    -- Talent: Bleeding for $w1 Physical damage every $t1 sec.  Taking $s2% increased damage from the Hunter's pet.
    -- https://wowhead.com/beta/spell=321538
    bloodshed = {
        id = 321538,
        duration = 18,
        tick_time = 3,
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
    -- Movement speed reduced by $s4%.
    -- https://wowhead.com/beta/spell=186387
    bursting_shot = {
        id = 186387,
        duration = 6,
        type = "Ranged",
        max_stack = 1
    },
    -- Talent: Being assisted by a pet from your stable.
    -- https://wowhead.com/beta/spell=361582
    call_of_the_wild = {
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
    -- Talent: Your next Kill Command will consume $s1% less Focus.
    -- https://wowhead.com/beta/spell=392296
    cobra_sting = {
        id = 392296,
        duration = 15,
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
        duration = function() return talent.dire_frenzy.enabled and 9 or 8 end,
        max_stack = 1
    },
    dire_beast_basilisk = {
        id = 209967,
        duration = 30,
        max_stack = 1,
    },
    dire_beast_hawk = {
        id = 208684,
        duration = 3600,
        max_stack = 1,
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
    -- Vision is enhanced.
    -- https://wowhead.com/beta/spell=6197
    eagle_eye = {
        id = 6197,
        duration = 60,
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
        max_stack = 1,
    },
    -- Attack speed increased by $s1%.
    -- https://wowhead.com/beta/spell=272790
    frenzy = {
        id = 272790,
        duration = function () return azerite.feeding_frenzy.enabled and 9 or 8 end,
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
        max_stack = 1,
    },
    -- Can always be seen and tracked by the Hunter.
    -- https://wowhead.com/beta/spell=257284
    hunters_mark = {
        id = 257284,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Kill Shot is usable on any target, regardless of your target's current health.
    -- https://wowhead.com/beta/spell=378215
    hunters_prey = {
        id = 378215,
        duration = 15,
        max_stack = 1
    },
    intimidation = {
        id = 24394,
        duration = 5,
        max_stack = 1,
    },
    -- Talent: Bleeding for $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=259277
    kill_command = {
        id = 259277,
        duration = 8,
        max_stack = 1
    },
    -- Injected with Latent Poison. $?s137015[Barbed Shot]?s137016[Aimed Shot]?s137017&!s259387[Raptor Strike][Mongoose Bite]  consumes all stacks of Latent Poison, dealing ${$378016s1/$s1} Nature damage per stack consumed.
    -- https://wowhead.com/beta/spell=378015
    latent_poison = {
        id = 378015,
        duration = 15,
        max_stack = 10
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=263423
    lock_jaw = {
        id = 263423,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
    },
    master_marksman = {
        id = 269576,
        duration = 6,
        mechanic = "bleed",
        max_stack = 1
    },
    masters_call = {
        id = 54216,
        duration = 4,
        type = "Magic",
        max_stack = 1,
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
        end,
    },
    -- Talent: Threat redirected from Hunter.
    -- https://wowhead.com/beta/spell=35079
    misdirection = {
        id = 35079,
        duration = 8,
        max_stack = 1,
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
        max_stack = 4,
    },

    -- Suffering $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=270332
    pheromone_bomb = {
        id = 270332,
        duration = 6,
        tick_time = 1,
        type = "Ranged",
        max_stack = 1
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
        max_stack = 1,
    },
    -- Stealthed.  Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=24450
    prowl = {
        id = 24450,
        duration = 3600,
        max_stack = 1
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
    -- Talent: Ignoring line of sight to enemies in the targeted area.
    -- https://wowhead.com/beta/spell=388045
    sentinel_owl = {
        id = 388045,
        duration = function() return buff.sentinel_owl_ready.stack end,
        max_stack = 1
    },
    sentinel_owl_ready = {
        duration = 3600,
        max_stack = 12,
        generate = function( t, auraType )
            local n = GetSpellCount( 388045 )

            if n > 4 then
                t.name = class.abilities.sentinel_owl.name
                t.count = n
                t.applied = now
                t.expires = now + 3600
                t.caster = "player"
                return
            end
            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end
    },
    -- Talent: Suffering $s2 Nature damage every $t2 sec.
    -- https://wowhead.com/beta/spell=271788
    serpent_sting = {
        id = 271788,
        duration = 18,
        type = "Ranged",
        max_stack = 1
    },
    -- Dodge chance increased by $s1%.
    -- https://wowhead.com/beta/spell=263904
    serpents_swiftness = {
        id = 263904,
        duration = 20,
        max_stack = 1
    },
    -- Suffering $w1 Fire damage every $t1 sec.  $?s259387[Mongoose Bite][Raptor Strike] and Butchery apply a stack of Internal Bleeding.
    -- https://wowhead.com/beta/spell=270339
    shrapnel_bomb = {
        id = 270339,
        duration = 6,
        tick_time = 1,
        type = "Ranged",
        max_stack = 1
    },
    -- Damage taken reduced by $s1%.
    -- https://wowhead.com/beta/spell=263938
    silverback = {
        id = 263938,
        duration = 15,
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
        max_stack = 1,
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=160065
    tendon_rip = {
        id = 160065,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
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
        duration = 8,
        max_stack = function() return talent.thrill_of_the_hunt.rank end,
        copy = 312365
    },
    trailblazer = {
        id = 231390,
        duration = 3600,
        max_stack = 1,
    },
    -- Suffering $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=271049
    volatile_bomb = {
        id = 271049,
        duration = 6,
        tick_time = 1,
        type = "Magic",
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
    -- Suffering $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=269747
    wildfire_bomb = {
        id = 269747,
        duration = 6,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
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

    -- PvP Talents
    high_explosive_trap = {
        id = 236777,
        duration = 0.1,
        max_stack = 1,
    },
    interlope = {
        id = 248518,
        duration = 45,
        max_stack = 1,
    },
    roar_of_sacrifice = {
        id = 53480,
        duration = 12,
        max_stack = 1,
    },
    the_beast_within = {
        id = 212704,
        duration = 15,
        max_stack = 1,
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
        max_stack = 1,
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


spec:RegisterStateExpr( "barbed_shot_grace_period", function ()
    return ( settings.barbed_shot_grace_period or 0 ) * gcd.max
end )

spec:RegisterHook( "spend", function( amt, resource )
    if amt < 0 and resource == "focus" and buff.nessingwarys_trapping_apparatus.up then
        amt = amt * 2
    end

    return amt, resource
end )


local ExpireNesingwarysTrappingApparatus = setfenv( function()
    focus.regen = focus.regen * 0.5
    forecastResources( "focus" )
end, state )


spec:RegisterGear( "tier29", 200390, 200392, 200387, 200389, 200391 )
spec:RegisterAura( "lethal_command", {
    id = 394298,
    duration = 15,
    max_stack = 1
} )


spec:RegisterHook( "reset_precast", function()
    if debuff.tar_trap.up then
        debuff.tar_trap.expires = debuff.tar_trap.applied + 30
    end

    if buff.nesingwarys_apparatus.up then
        state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireNesingwarysTrappingApparatus, buff.nesingwarys_apparatus.expires )
    end

    if now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end
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
    if subtype == "SPELL_CAST_SUCCESS" and sourceGUID == GUID and spellID == 187698 and legendary.soulforge_embers.enabled then
        -- Capture all boss/elite targets present at this time as valid trapped targets.
        table.wipe( tar_trap_targets )

        for _, unit in ipairs( trapUnits ) do
            if UnitExists( unit ) and UnitCanAttack( "player", unit ) and not trappableClassifications[ UnitClassification( unit ) ] then
                tar_trap_targets[ UnitGUID( unit ) ] = true
            end
        end
    end
end, false )


spec:RegisterStateTable( "tar_trap", setmetatable( {}, {
    __index = function( t, k )
        return state.debuff.tar_trap[ k ]
    end
} ) )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Summons a flock of crows to attack your target, dealing ${$131900s1*16} Physical damage over $d. If the target dies while under attack, A Murder of Crows' cooldown is reset.
    a_murder_of_crows = {
        id = 131894,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "physical",

        spend = 30,
        spendType = "focus",

        talent = "a_murder_of_crows",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "a_murder_of_crows" )
            if talent.master_handler.enabled then reduceCooldown( "aspect_of_the_wild", 2 ) end -- ???
        end,
    },

    -- A quick shot that causes $sw2 Arcane damage.$?s260393[    Arcane Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    arcane_shot = {
        id = 185358,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 40,
        spendType = "focus",

        startsCombat = true,

        handler = function ()
        end,
    },

    -- Increases your movement speed by $s1% for $d, and then by $186258s1% for another $186258d.
    aspect_of_the_cheetah = {
        id = 186257,
        cast = 0,
        cooldown = function () return 180 * ( pvptalent.hunting_pack.enabled and 0.5 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( 1 - 0.075 * talent.born_to_be_wild.rank ) + ( conduit.cheetahs_vigor.mod * 0.001 ) end,
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
        cooldown = function () return 180 * ( pvptalent.hunting_pack.enabled and 0.5 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( 1 - 0.075 * talent.born_to_be_wild.rank ) + ( conduit.cheetahs_vigor.mod * 0.001 ) end,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        toggle = "cooldowns",

        start = function ()
            applyBuff( "aspect_of_the_turtle" )
        end,
    },

    -- Talent: Fire off a Cobra Shot at your current target and $s1 other $Lenemy:enemies; near your current target. For the next $d, your Cobra Shot will fire at $s1 extra $Ltarget:targets; and Cobra Shot Focus cost reduced by $s2.$?s389654[    Each temporary beast summoned reduces the cooldown of Aspect of the Wild by ${$389654m1/1000}.1 sec.][]$?s389660[    While Aspect of the Wild is active, Cobra Shot deals $389660s1% increased damage.][]
    aspect_of_the_wild = {
        id = 193530,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * 120 end,
        gcd = "spell",
        school = "physical",

        talent = "aspect_of_the_wild",
        startsCombat = false,

        toggle = "cooldowns",

        nobuff = function ()
            if settings.aspect_vop_overlap then return end
            return "aspect_of_the_wild"
        end,

        handler = function ()
            applyBuff( "aspect_of_the_wild" )


            if azerite.primal_instincts.enabled then gainCharges( "barbed_shot", 1 ) end
        end,
    },

    -- Talent: Fire a shot that tears through your enemy, causing them to bleed for ${$s1*$s2} damage over $d$?s257944[ and  increases your critical strike chance by $257946s1% for $257946d, stacking up to $257946u $Ltime:times;][].    Sends your pet into a frenzy, increasing attack speed by $272790s1% for $272790d, stacking up to $272790u times.    |cFFFFFFFFGenerates ${$246152s1*$246152d/$246152t1} Focus over $246152d.|r
    barbed_shot = {
        id = 217200,
        cast = 0,
        charges = 2,
        cooldown = function () return ( conduit.bloodletting.enabled and 11 or 12 ) * haste end,
        recharge = function () return ( conduit.bloodletting.enabled and 11 or 12 ) * haste end,
        gcd = "spell",
        school = "physical",

        talent = "barbed_shot",
        startsCombat = true,

        velocity = 50,
        cycle = "barbed_shot",

        handler = function ()
            if buff.barbed_shot.down then applyBuff( "barbed_shot" )
            else
                for i = 2, 8 do
                    if buff[ "barbed_shot_" .. i ].down then applyBuff( "barbed_shot_" .. i ); break end
                end
            end

            applyDebuff( "target", "barbed_shot_dot" )
            addStack( "frenzy", 8, 1 )

            if talent.barbed_wrath.enabled then reduceCooldown( "bestial_wrath", 12 ) end
            if talent.thrill_of_the_hunt.enabled then addStack( "thrill_of_the_hunt", nil, 1 ) end
            -- No longer predictable (11/1 nerfs).
            -- if talent.war_orders.rank > 1 then setCooldown( "kill_command", 0 ) end
            removeDebuff( "target", "latent_poison" )

            if set_bonus.tier29_4pc > 0 then applyBuff( "lethal_command" ) end

            if legendary.qapla_eredun_war_order.enabled then
                setCooldown( "kill_command", 0 )
            end
        end,
    },

    -- Talent: Rapidly fires a spray of shots for $120360d, dealing an average of $<damageSec> Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond $120361s1 targets.
    barrage = {
        id = 120360,
        cast = function () return 3 * haste end,
        channeled = true,
        cooldown = 20,
        gcd = "spell",
        school = "physical",

        spend = 60,
        spendType = "focus",

        talent = "barrage",
        startsCombat = true,

        start = function ()
            applyBuff( "barrage" )
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
            applyBuff( "bestial_wrath" )
            if pvptalent.the_beast_within.enabled then applyBuff( "the_beast_within" ) end
            if talent.scent_of_blood.enabled then gainCharges( "barbed_shot", 2 ) end
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

    -- Talent: Command your pet to tear into your target, causing your target to bleed for $<damage> over $321538d and increase all damage taken from your pet by $321538s2% for $321538d.
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

    -- Talent: You sound the call of the wild, summoning $s1 of your active pets for $d. During this time, a random pet from your stable will appear every $t2 sec to assault your target for $361582d.$?s378442[    While Call of the Wild is active, Barbed Shot has a $378442h% chance to gain a charge any time Focus is spent.][]$?s378739[    While Call of the Wild is active, Barbed Shot affects all of your summoned pets.][]
    call_of_the_wild = {
        id = 359844,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        school = "nature",

        talent = "call_of_the_wild",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "call_of_the_wild" )
            if talent.master_handler.enabled then reduceCooldown( "aspect_of_the_wild", 2 ) end
        end,
    },

    -- Talent: You and your pet blend into the surroundings and gain stealth for $d. While camouflaged, you will heal for $s4% of maximum health every $T4 secs.
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

        spend = function() return buff.aspect_of_the_wild.up and 25 or 35 end,
        spendType = "focus",

        talent = "cobra_shot",
        startsCombat = true,

        handler = function ()
            if talent.killer_cobra.enabled and buff.bestial_wrath.up then setCooldown( "kill_command", 0 )
            else
                gainChargeTime( "kill_command", talent.cobra_senses.enabled and 2 or 1 )
            end
            if debuff.concussive_shot.up then debuff.concussive_shot.expires = debuff.concussive_shot.expires + 3 end
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
        cooldown = 24,
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

    -- Covenant (Necrolord) / Talent: Throw a deadly chakram at your current target that will rapidly deal $375893s1 Physical damage $x times, bouncing to other targets if they are nearby. Enemies struck by Death Chakram take $375893s2% more damage from you and your pet for $375893d.    Each time the chakram deals damage, its damage is increased by $s3% and you generate $s4 Focus.
    death_chakram = {
        id = function() return talent.death_chakram.enabled and 375891 or 325028 end,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyBuff( "death_chakram" )
            applyDebuff( "target", "death_chakram_vulnerability" )
            if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
        end,

        copy = { 325028, 375891 }
    },

    -- Talent: Summons a powerful wild beast that attacks the target and roars, increasing your Haste by $281036s1% for $d.
    dire_beast = {
        id = 120679,
        cast = 0,
        cooldown = 20,
        gcd = "spell",
        school = "nature",

        talent = "dire_beast",
        startsCombat = true,

        handler = function ()
            applyBuff( "dire_beast" )
            summonPet( "dire_beast", 8 )
            if talent.master_handler.enabled then reduceCooldown( "aspect_of_the_wild", 2 ) end
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
            if talent.master_handler.enabled then reduceCooldown( "aspect_of_the_wild", 2 ) end
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
            if talent.master_handler.enabled then reduceCooldown( "aspect_of_the_wild", 2 ) end
        end,
    },

    -- Leap backwards$?s109215[, clearing movement impairing effects, and increasing your movement speed by $118922s1% for $118922d][]$?s109298[, and activating a web trap which encases all targets within $115928A1 yards in sticky webs, preventing movement for $136634d][].
    disengage = {
        id = 781,
        cast = 0,
        charges = 1,
        cooldown = 1,
        recharge = 20,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        handler = function ()
            if talent.posthaste.enabled then applyBuff( "posthaste" ) end
            if conduit.tactical_retreat.enabled and target.within8 then applyDebuff( "target", "tactical_retreat" ) end
        end,
    },

    -- Changes your viewpoint to the targeted location for $d. Only usable outdoors.
    eagle_eye = {
        id = 6197,
        cast = 60,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        startsCombat = false,

        start = function ()
            applyBuff( "eagle_eye" )
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
            applyDebuff( "target", "explosive_shot" )
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

    -- Hurls a frost trap to the target location that incapacitates the first enemy that approaches for $3355d. Damage will break the effect. Limit 1. Trap will exist for $3355d.
    freezing_trap = {
        id = 187650,
        cast = 0,
        cooldown = function() return 30 - 2.5 * talent.improved_traps.rank end,
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
        cooldown = function() return 40 - 2.5 * talent.improved_traps.rank end,
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

    -- Apply Hunter's Mark to the target, causing the target to always be seen and tracked by the Hunter.    Only one Hunter's Mark can be applied at a time.
    hunters_mark = {
        id = 257284,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hunters_mark" )
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
        cooldown = 60,
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
        charges = function() return talent.alpha_predator.enabled and 2 or nil end,
        cooldown = function () return 7.5 * haste end,
        recharge = function() return talent.alpha_predator.enabled and ( 7.5 * haste ) or nil end,
        icd = 0.5,
        gcd = "spell",
        school = "physical",

        spend = function () return ( buff.cobra_sting.up or buff.flamewakers_cobra_sting.up ) and 0 or 30 end,
        spendType = "focus",

        talent = "kill_command",
        startsCombat = true,

        disabled = function()
            if settings.check_pet_range and settings.petbased and Hekili:PetBasedTargetDetectionIsReady( true ) and not Hekili:TargetIsNearPet( "target" ) then return true, "not in-range of pet" end
        end,

        handler = function ()
            removeBuff( "cobra_sting" )
            removeBuff( "flamewakers_cobra_sting" )
            removeBuff( "lethal_command" )

            if conduit.ferocious_appetite.enabled and stat.crit >= 100 then
                reduceCooldown( "aspect_of_the_wild", conduit.ferocious_appetite.mod / 10 )
            end
        end,
    },

    -- Talent: You attempt to finish off a wounded target, dealing $s1 Physical damage. Only usable on enemies with less than $s2% health.$?s343248[    Kill Shot deals $343248s1% increased critical damage.][]
    kill_shot = {
        id = function() return state.spec.survival and 320976 or 53351 end,
        cast = 0,
        charges = function() return talent.deadeye.enabled and 2 or nil end,
        cooldown = function() return talent.deadeye.enabled and 7 or 10 end,
        recharge = function() return talent.deadeye.enabled and 7 or nil end,
        gcd = "spell",
        school = "physical",

        spend = function () return ( buff.hunters_prey.up or buff.flayers_mark.up ) and 0 or 10 end,
        spendType = "focus",

        talent = "kill_shot",
        startsCombat = true,

        usable = function () return buff.hunters_prey.up or buff.flayers_mark.up or target.health_pct < 20, "requires flayers_mark/hunters_prey or target health below 20 percent" end,
        handler = function ()
            if buff.flayers_mark.up and legendary.pouch_of_razor_fragments.enabled then
                applyDebuff( "target", "pouch_of_razor_fragments" )
                removeBuff( "flayers_mark" )
            else
                removeBuff( "hunters_prey" )
            end
        end,

        copy = { 53351, 320976 }
    },


    masters_call = {
        id = 272682,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        startsCombat = true,
        texture = 236189,

        handler = function ()
        end,
    },

    -- Talent: Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within $d and lasting for $35079d.
    misdirection = {
        id = 34477,
        cast = 0,
        cooldown = 30,
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

        pvptalent = "roar_of_sacrifice",

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

    sentinel_owl = {
        id = 388045,
        cast = 0,
        cooldown = 0,
        gcd = 0,

        talent = "sentinel_owl",
        startsCombat = true,

        usable = function() return buff.sentinel_owl_ready.stack > 4, "requires 5+ stacks of sentinel_owl_ready" end,

        handler = function ()
            removeBuff( "sentinel_owl_ready" )
            applyDebuff( "target", "sentinel_owl" )
        end,
    },

    -- Talent: Fire a shot that poisons your target, causing them to take $s1 Nature damage instantly and an additional $o2 Nature damage over $d.$?s260241[    Serpent Sting fires arrows at $260241s1 additional $Lenemy:enemies; near your target.][]$?s378014[    Serpent Sting's damage applies Latent Poison to the target, stacking up to $378015u times. $@spelldesc393949 consumes all stacks of Latent Poison, dealing $378016s1 Nature damage to the target per stack consumed.][]
    serpent_sting = {
        id = 271788,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 10 * ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) end,
        spendType = "focus",

        talent = "serpent_sting",
        startsCombat = false,

        velocity = 60,

        impact = function ()
            applyDebuff( "target", "serpent_sting" )
            if talent.hydras_bite.enabled then active_dot.serpent_sting = min( true_active_enemies, active_dot.serpent_sting + 2 ) end
            if talent.poison_injection.enabled then applyDebuff( "target", "latent_poison", nil, debuff.latent_poison.stack + 1 ) end
        end,
    },

    -- Talent: Summon a herd of stampeding animals from the wilds around you that deal ${$201594s1*6} Physical damage to your enemies over $d.    Enemies struck by the stampede are snared by $201594s2%, and you have $201594s3% increased critical strike chance against them for $201594d.
    stampede = {
        id = 201430,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "physical",

        talent = "stampede",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "stampede" )
            if talent.master_handler.enabled then reduceCooldown( "aspect_of_the_wild", 2 ) end
        end,
    },

    -- Talent: Hurls a Steel Trap to the target location that snaps shut on the first enemy that approaches, immobilizing them for $162480d and causing them to bleed for $162487o1 damage over $162487d.     Damage other than Steel Trap may break the immobilization effect. Trap will exist for $162496d. Limit 1.
    steel_trap = {
        id = 162488,
        cast = 0,
        cooldown = function() return 30 - 2.5 * talent.improved_traps.rank end,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if legendary.nessingwarys_trapping_apparatus.enabled then
                return -45, "focus"
            end
        end,

        talent = "steel_trap",
        startsCombat = false,

        handler = function ()
        end,
    },


    survival_of_the_fittest = {
        id = 264735,
        cast = 0,
        cooldown = function () return ( talent.lone_survivor.enabled and 150 or 180 ) * ( pvptalent.hunting_pack.enabled and 0.5 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( 1 - 0.075 * talent.born_to_be_wild.rank ) + ( conduit.cheetahs_vigor.mod * 0.001 ) end,
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

    -- Talent: Hurls a tar trap to the target location that creates a $187699s1 yd radius pool of tar around itself for $13810d when the first enemy approaches. All enemies have $135299s1% reduced movement speed while in the area of effect. Trap will exist for $13809d.
    tar_trap = {
        id = 187698,
        cast = 0,
        cooldown = function() return 30 - 2.5 * talent.improved_traps.rank end,
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
            removeBuff( "dispellable_enrage" )
            removeBuff( "dispellable_magic" )
            if state.spec.survival or talent.improved_tranquilizing_shot.enabled then gain( 10, "focus" ) end
        end,
    },

    -- Sylvanas Legendary / Talent: Fire an enchanted arrow, dealing $354831s1 Shadow damage to your target and an additional $354831s2 Shadow damage to all enemies within $354831A2 yds of your target. Targets struck by a Wailing Arrow are silenced for $355596d.
    wailing_arrow = {
        id = function() return talent.wailing_arrow.enabled and 392060 or 355589 end,
        cast = 2,
        cooldown = 60,
        gcd = "spell",

        spend = 15,
        spendType = "focus",

        toggle = "cooldowns",

        startsCombat = true,

        handler = function ()
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


spec:RegisterOptions( {
    enabled = true,

    potion = "spectral_agility",

    buffPadding = 0,

    nameplates = false,
    nameplateRange = 8,

    aoe = 3,

    damage = true,
    damageExpiration = 3,

    package = "Beast Mastery",
} )


spec:RegisterSetting( "barbed_shot_grace_period", 0.5, {
    name = "|T2058007:0|t Barbed Shot Grace Period",
    desc = "If set above zero, the addon (using the default priority or |cFFFFD100barbed_shot_grace_period|r expression) will recommend |T2058007:0|t Barbed Shot up to 1 global cooldown earlier.",
    icon = 2058007,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "range",
    min = 0,
    max = 1,
    step = 0.01,
    width = "full"
} )

spec:RegisterSetting( "avoid_bw_overlap", false, {
    name = "Avoid |T132127:0|t Bestial Wrath Overlap",
    desc = "If checked, the addon will not recommend |T132127:0|t Bestial Wrath if the buff is already applied.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "check_pet_range", false, {
    name = "Check Pet Range for |T132176:0|t Kill Command",
    desc = function ()
        return "If checked, the addon will not recommend |T132176:0|t Kill Command if your pet is not in range of your target.\n\n" ..
            "Requires |c" .. ( state.settings.petbased and "FF00FF00" or "FFFF0000" ) .. "Pet-Based Target Detection|r"
    end,
    type = "toggle",
    width = "full"
} )


spec:RegisterPack( "Beast Mastery", 20230123, [[Hekili:T3vwVnoos4FlngSESNK2XsjoB3dS9d9G9HUXUngGma7BwwrworOTL8ijNJbb(3(wK6IKQ4HKL7otw)somj)yvfR6JNMCU18)y(nlDt9N)v7r2xoYY(YHwJSVES98BsFER)8B2669n37G)i0Dd8Zp57MKUFX)b(PF8ZKKFEDK7scmjr7I9GS8t7xCFA62KF9IlUli9(D3o0lAZfjbB2T2nnik0l2Dvk5)9Uy(n3UlyD6NdNFlUyyn)g3DP3hfp)MBc28BZV5(GLl9ZYUFI38BMFZ6GK0eQA4VYD36u4p)kvT8dDVDT)Y5FklVXbBj1(8B(xp57Tl1F5(f(pa6W(fPbB8HFEp8dxV0O49lcsG)8b3G1eegcYGxwr9I2fc6TtY9rPZtbHLupfjMg7g(NG6e8xbH3LLfgzaY9LcsvjQURx7K9poeTjtNCYm4EltiL9Q2u204GWV5NsbySaaG9a0Ka3mOEW3Xp0FtGpO4t2VWE)IxEz)I3bwf31(HPdVL0S74T239b)H5OSFrpQbtSWxcUcqn7LsAhmtqtOwZRnweNvkInv(GsA1C5ld45eP8MTX(G)8TUvoAfqKSBZgO0B9fB45CtUnknfsXz1A3N9x(iXxjn6PGqnolKQLOJeN153ynCmt9M67V2bC)2YAZQA8EeCKjvJBCC0JCwN8mubqrQzQAUAJeqvQmUX3c6sMZEvDV0)2DRwneI3b4D2gfKefc1cqLqBb(iTY7VFbnxRI9d)RNhUBl9tz)Oy)nUbHeVQP7xCN3YHBCFA)IZ2Vy0q7XCT)jEKkkALZTRJIwYPJErrRxg9yi4JKKg4U25Xy307zWg8iSPOwwdeGxTd8haB(9UX357KrrmHjpgG8aWK8mydDsjyaHHGzSWBWCB5HzJG)GbxN7ID98bp04GOLV2nG4wpX4cbdfhraRiwAoYfGk7o0VuAqbJUipBf8gOp52s31BV31bcyHE0IIXc4(waGfpBvL8KLy0MnUHllzU5OPGMjO3kNhdwVuG14A286)021rje6pKoJ(N6SJSTie)osB6Trjju9yvWD3N6W5cWri5UzR)scH5x)ah3hX5k5EFrX(JSzAPpuLoGD(BXUBeYO1io4yfsXCYtnZqrYNnoUzxNn7IxcDWdwypGSmrm3Y6c)a5bliQHguhWGMge6LMW54qXrSX3K2LpYfMtRbcm8r4uF6eNvXz6J76SokhAlLeZs2asKyjE1QHsupUGoUisbpcUiULbX(oukiXSjgUv6y6hVL4BqSi3XAWI9bc(K7jfiN5GiFdj8oW4fCwg4t1GL7IDZzgWuJpOokxSpeaq)SrhNpodMw1yYSaiy(XAMge6fBUav3KT(EPk4TSfhGbdVBK3UKs9Ms1Ys7(lLdfKQr1RPIon1JZvm0Sr3g7wnmFXUSBMzuRhmd1j3y1O1T2o8yjQj9M2KQ7w37O2ky4WFJonbB5Da2p3gs7fnZAg7FNFi9)VCeqvqrplfUEyDJ9CdjM9yWqLMn2YY5MGm6YOTKaJ0kaEWfKaivYFTENFUQlLSOCCf1YbRzO2KCQLBwgeq7HE0FWH4WyXB1fQu0bZ4C3o)KY6DavLkM8ZZHEo72In0WCdrWkCtbhcvJAczkaYuTCdQJ)6eY0C0z3kT)MOSyJwtFllrMZCngMAp8E3eNI6kNMVirlAI7sacxWzOOnQEXRYbxXThwQdfCO0whg8rYGiefZiRwrRsqErMkRi90jNt1jNdQ8TBV9kFSj)FJfJlQmp3owqxZXrH35hJn9GM5pBPYFg36RQfuiCqtRdQzrec8whBPTowYADSL16GkNt1jNi(Zn3Ej4p)M3IH6pBZ5plUQGfUX55MSuzRJsz)FI5mA1ks)G01pJB8bAm9fbhdZ7YR2NxpOtoRD1YSu6B0k8Xen2rYPUD4IQvIuHJPs5FM0A)9KPvRhaiBJPUFsGPN0uGbUD1iQeimkXCBAndNDndNsjZGS0EHFgedypYahKSQGKD51r36ciJArWkRSEpthEOTAdkB7WnjUlFwPnnZKkpdA5hZSgCsIEozJgisNWsyADGAw0wj55JVDazI7KzbmUZ0RbuKKntuSEEMJSBlcu)2cu)2Ms9BIHvb1STmL3QBO(RZGzqCVcpDDZjrP83iQFmaAp7zJP(R3NPsjZGS0EHhL6xEv0fu)M6ciBwsTL6hfptP(Towu)k6iuk1poXGrJzVtyjmTo0t9ljuUdO(BQEzi1Vnh1FkDd3B(U6(dFNizRT8DrbmNxstR08iUIuGBVz7dB3TvFY3lVlBWE5DLPBk2yt2ITR53oS8nOdzpbnDVW(Gr7Vg3MfOCdjB7w7PAZzA4wTFOBsv72cQRYkSboDs9XZd8mlkQVEGMy(w6ZMhOyFWibLqcEfTS9Pf59mGmiB)fqQQCwvvBfOKTb7sZ2Koz7P5rEt6QVxJyHhx3OnuZIlwMz7SeY2HTbHABquTZwzBKO86UR3zRrhZQlFlU2UJSrkQ3qZ(Q2hnYG(h0K9rJC(ar6khBtG41WskbQsw3cyWoVd(Kme2XqyY3ibik7BvndQ(DSQGctIeZMiH5B9UKug(zA459(URHSV1lnJjAe7y2mvDjG7SAx8ZyBZ1Bo11n0dQ7yOUjck2oH82qLhvPYRGUjOva26K)MqBVK54VUnI(7CsLhGGzY)MFASjEcp6ghcb3WOa)dYbLoyZ2O4uclfmtLFo)Ox)Z7xe7)N7adhOwjrK(hC3LgTXLEARH(YHj2KmC)x(3bHqsJ)19l(TOqOUOj)ZihLxaW0i8KkSFqw6B90GsuVUJrD)xq03YZaCZ04lXLnUEgfeo0ZUROolb3QbLlaA9Z7Rg9nFIKjntDTWflXibbHtwGIOsBFurVMjnFQ08hjHsW5xJdMKncu(fKOgO1s2iqTvdATKne0AR7dcYy55OcVwGrwVkeZCRL72cVwGzw4gmdbtAMkNsHZQ5W9Qx602OCYx1y4na4tSyhe8AbUTnDgk3TfETa)QNN41T0PTr5KVQXWxc8vkzXkkOewmMK5KwzGEqSyQL0wY3kh02zxpYWRf426hBOC3w41cClzluiNTHl7VTsN2gLt(QgdVbaFIf7GGxlWTTPZq5UTWRf4x98eVULoTnkN8vng(sGRT8YDbHJmqzKK8vyxLWwLLJi4AHTTEggk1TfETaFqDd1T24Jk4hjypjZNK5xNYCBzmmuQBl8hnGpj3TtU58TCx(SANVSmyKe3CGBcKnAymnxIBe8Ab(inkPt9CFYqC4W(JrM3cfGKLH0tJd)jJSay8KmsAB5SufGlARFwiEY(fbHag9LeZ2RV4xzkMpjVmmFNFE5ff2SbV8Y7AeAIvEooZyvyroR)HnNmWPlkKTzO107TgRQqVF8e0I1d9tp7QrZ4oDvG9qX3SJE9vuZktSzI1SP2Ju2S9(XZMIJ3H28GK(eolKKA4mviiyJhmqMYbDmlXIypcpHjyavPz066DsdK6)oz(LhseLEmfunLacPNzXQDc1Nyp(aKZb9qO8MjH4IsQ9MHq6ItesntS((siDXBwcPlori1jesLJHQ2zgop3h0W0LbQL(rLIMLJi4AHfXj0OPzAOu3w41c8bnl2U1gFub)ib7jz(Km)6uMBlJHHsDBH)Ob8j5UDYnNVf2k6IKbJK4MdCtGSrRxEZL4gbVwGpsJs6up3NmehoS)yK5oAPIvqx2MtGKaCkwQy1ZWdDTuSXMFwDBMHRmJT5Rmds)ccRfj(kZux2myLzQxOMTeigTYmwyRmt9AwzIntSewzgm4A7kZOR5bj9gUYmiiOALze7yU1RmdsNL1wQyXaP(Yx0MdiIspMYxzgKWGgUYmMkNAwzgesT3mesxCIqQzI13xcPlEZsivBPIpri1kcPHsUye8wsg02HFNiWDXFuoMofxBpIJT778THqNIETJaENIETZBrhHoQ)qsdVrqeDhqN4WUTyZzG(PCAQrGL7M3GzHiXLL)gMtW8HF9ZPdzubMErpIjUfjysCa)90OGWIFjowtyLan)TfOa04xLGncAINigQSxWGMcyx0M9btA0AIxgoXAXn1ZPGjdByeBYpiT3iWAU2F8Clf7HIxGXEvi5eBjzWKUP6aQfjiZ8krkalY7hznhnj9z3f0vQGUv0vsmaDHSQc6wjRDo)xEOrNhYT)lFMsPsq76SxczYT0n99YgsM8KchTkyD5R8xYWYR1SZMEr1Jz8(VGLUSNXy8CxDJJDo7dz8uRHJppy103vy9zVTZ6vqauwwIo9t7x04hW7szAk7d4D5NcYx93UB2uPdgm7FPVn0NtEsDMcJ9xFMYNnHb5e(nmTLaV0Pwetcj9QhU6j2KjXLzpy5Q6jKTl1xpzfurDnJmByTv1mlARb0C8Bq1K3T9Vh9i5Ml)ZHR2LqD2E8EY9A6NYMbZ(f)3y6ZLhP1jExi5(e889lkAV8whL4N5yd(nqAqsKRN9I5Tbo2)(Nb)xqKsYULdtahSWLKM6WL1RL8mAn(CYyh2tFIcllrMG56rDiO1fvb(e9IHE)IBiEaWypwUlpQjAfUA4UFXDrKBWC3Tq40tbKHMqURftjrGeRtr0a4TanjbHpe9nWg(e4egcZPJeaN1SSLy6a(SmlhPvjVJj(BeYxEPCASO3TYtaT8l81z1nZkBOgxPF5fjvg52JSh3AxmX66Avq5DHAPyJCHyw5alMyV(O1EXhZCTxwUgavx5LtiloGHck)Ty6RCHT8(h91LCwZ9k7Md9vLqEjLBQumP0xe)0QB99Z5UiUZybL)ynp7J96lz409u1n9KP35T8mYZFqjJk)Oz7Pjy2Y(maHxEP(TH(e4Z1u6bn3eCyk5zYEFh(rO9ikF5d9EDvfB8)tO6eutiqX(OdqqtIiIolGE1hepsnigQGKf(NtbKmu8mpOO3eSq8XyoofpReiPX92uGvw2AfvmRgGxTeR9mu0CVA1b2OtNONCUmel2hlDWlN(qV6p3dZSgA3IyYVRYNgxDSg)YxtbSww2hobmLJ5buOx9L3FwX2yGB1iVi5szTkwoFUNRajANKWN6pYcyXPLpTcuEaXhzCcnWVyNp(k0hN8E4L5kK6IB6rnsZrDlqJZzF2eKWBqiDngq(3SacI9Pk8zmV8bND5ObtkFVdy77ojvFaY35oTKVi1tUuEFsKhFlET6q6crak59vqtwc)CMTToVEsktxhcFSc24Kuju50eK1xvMqG3brnZuZ8lAkXPzuKx1YXJiZDQFRhee5ZN8bDdIY(QZ6)H3dzDWz1HaF4ZFu0)bHIpR1UZP3RAYrCtuXhNfhuYflKWXJ4m3rSBinZ0sMxsMocl1KVwJLq(wS2vaqf7XE(svLDmzoN(eNRyAFLUM1sT07u1Cdb2Uhip2OdTexTc1(8o3TZpbWEGPQsE5opA70e)0Gv5kMj1swwD8HgRPAv3Zjl(uarIMktRnqKRFQCYL3YJYb)Rqq1HGq80yiuGIeQka2zHPcSAPXvWI14LTafFgAgNIKXEkKKPkKe2Z8IHAD1Px6VVATjE8P1oLmIUpwsCFeTxsSWS(BYnKiQgxbRziTXmKwigsBedjIKmvHKW6(yOwx5(83xTg39HOHbP(BoN8h5V)Zq37Kxh6c0OD23xMHXGJxj23Ux72Ewnn)R1p6r4vQdVCbt)b1SEzA2bI0OZPj2xP)6vSQ0AMqXFknXqRLhstnTlyryn6iAIaGItOPDhDanrpk88Npt5Ft(B1xKF0qiTik9SzI443WJMPHc5aLtEFgcpyBzUS5yU6OJz(3HtzoQVK0r6jxW0ZCDOhLBJyUWoH5QoG5hQqXZC1HhVCnTlh8HlVzNT8U6OLJYhZZCj)GL3QZvUYJvEZpv5hNdvo6zk3iMlMrRn)gYYAm)R2JVK(4lo))9d]] )