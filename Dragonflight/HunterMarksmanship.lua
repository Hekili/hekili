-- HunterMarksmanship.lua
-- October 2022

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 254, true )

spec:RegisterResource( Enum.PowerType.Focus, {
    death_chakram = {
        aura = "death_chakram",

        last = function ()
            return state.buff.death_chakram.applied + floor( ( state.query_time - state.buff.death_chakram.applied ) / class.auras.death_chakram.tick_time ) * class.auras.death_chakram.tick_time
        end,

        interval = function () return class.auras.death_chakram.tick_time end,
        value = function () return state.conduit.necrotic_barrage.enabled and 5 or 3 end,
    },
    rapid_fire = {
        channel = "rapid_fire",

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.rapid_fire.tick_time ) * class.auras.rapid_fire.tick_time
        end,

        interval = function () return class.auras.rapid_fire.tick_time * ( state.buff.trueshot.up and 0.667 or 1 ) end,
        value = 1,
    }
} )

-- Talents
spec:RegisterTalents( {
    -- Hunter
    alpha_predator              = { 79904, 269737, 1 }, -- Kill Command now has 2 charges, and deals 15% increased damage.
    arctic_bola                 = { 79815, 390231, 2 }, -- Aimed Shot has a chance to fling an Arctic Bola at your target, dealing 0 Frost damage and snaring the target by 20% for 3 sec. The Arctic Bola strikes up to 2 targets.
    barrage                     = { 79914, 120360, 1 }, -- Rapidly fires a spray of shots for 2.8 sec, dealing an average of 3,323 Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond 8 targets.
    beast_master                = { 79926, 378007, 2 }, -- Pet damage increased by 3%.
    binding_shackles            = { 79920, 321468, 1 }, -- Targets rooted by Binding Shot, knocked back by High Explosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal 10% less damage to you for 8 sec after the effect ends.
    binding_shot                = { 79937, 109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within 5 yds for 10 sec, stunning them for 3 sec if they move more than 5 yds from the arrow.
    born_to_be_wild             = { 79933, 266921, 2 }, -- Reduces the cooldowns of Aspect of the Cheetah, Survival of the Fittest, and Aspect of the Turtle by 7%.
    camouflage                  = { 79934, 199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for $d. While camouflaged, you will heal for $s4% of maximum health every $T4 sec.
    concussive_shot             = { 79906, 5116  , 1 }, -- Dazes the target, slowing movement speed by 50% for 6 sec. Steady Shot will increase the duration of Concussive Shot on the target by 3.0 sec.
    death_chakram               = { 79916, 375891, 1 }, -- Throw a deadly chakram at your current target that will rapidly deal 1,370 Physical damage 7 times, bouncing to other targets if they are nearby. Enemies struck by Death Chakram take 10% more damage from you and your pet for 10 sec. Each time the chakram deals damage, its damage is increased by 15% and you generate 3 Focus.
    entrapment                  = { 79977, 393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for 4 sec. Damage taken may break this root.
    explosive_shot              = { 79914, 212431, 1 }, -- Fires an explosive shot at your target. After 3 sec, the shot will explode, dealing 4,704 Fire damage to all enemies within 8 yds. Deals reduced damage beyond 5 targets.
    high_explosive_trap         = { 79910, 236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 840 Fire damage and knocking all enemies away. Trap will exist for 1 min.
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
    poison_injection            = { 79911, 378014, 1 }, -- Serpent Sting's damage applies Latent Poison to the target, stacking up to 10 times. Aimed Shot consumes all stacks of Latent Poison, dealing 303 Nature damage to the target per stack consumed.
    posthaste                   = { 79921, 109215, 2 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by 25% for 4 sec.
    rejuvenating_wind           = { 79909, 385539, 2 }, -- Maximum health increased by 4%, and Exhilaration now also heals you for an additional 10.0% of your maximum health over 8 sec.
    roar_of_sacrifice           = { 79832, 53480 , 1 }, -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but 10% of all damage taken by that target is also taken by the pet. Lasts 12 sec.
    scare_beast                 = { 79927, 1513  , 1 }, -- Scares a beast, causing it to run in fear for up to 20 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time.
    scatter_shot                = { 79937, 213691, 1 }, -- A short-range shot that deals 82 damage, removes all harmful damage over time effects, and incapacitates the target for 4 sec. Any damage caused will remove the effect. Turns off your attack when used.
    sentinel_owl                = { 79819, 388045, 1 }, -- Call forth a Sentinel Owl to the target location within 40 yds, granting you unhindered vision. Your attacks ignore line of sight against any target in this area. Every 90 Focus spent grants you 1 sec of the Sentinel Owl when cast, up to a maximum of 12 sec. The Sentinel Owl can only be summoned when it will last at least 5 sec.
    sentinels_perception        = { 79818, 388056, 1 }, -- Sentinel Owl now also grants unhindered vision to party members while active.
    sentinels_protection        = { 79818, 388057, 1 }, -- While the Sentinel Owl is active, your party gains 5% leech.
    serpent_sting               = { 79905, 271788, 1 }, -- Fire a shot that poisons your target, causing them to take 356 Nature damage instantly and an additional 2,279 Nature damage over 18 sec. Serpent Sting's damage applies Latent Poison to the target, stacking up to 10 times. Aimed Shot consumes all stacks of Latent Poison, dealing 303 Nature damage to the target per stack consumed.
    serrated_shots              = { 79814, 389882, 2 }, -- Serpent Sting and Bleed damage increased by 10%. This value is increased to 20% against targets below 30% health.
    stampede                    = { 79916, 201430, 1 }, -- Summon a herd of stampeding animals from the wilds around you that deal 2,294 Physical damage to your enemies over 12 sec. Enemies struck by the stampede are snared by 30%, and you have 10% increased critical strike chance against them for 5 sec.
    steel_trap                  = { 79908, 162488, 1 }, -- Hurls a Steel Trap to the target location that snaps shut on the first enemy that approaches, immobilizing them for 20 sec and causing them to bleed for 2,951 damage over 20 sec. Damage other than Steel Trap may break the immobilization effect. Trap will exist for 1 min. Limit 1.
    survival_of_the_fittest     = { 79821, 264735, 1 }, -- Reduces all damage you and your pet take by 20% for 8 sec.
    tar_trap                    = { 79928, 187698, 1 }, -- Hurls a tar trap to the target location that creates a 8 yd radius pool of tar around itself for 30 sec when the first enemy approaches. All enemies have 50% reduced movement speed while in the area of effect. Trap will exist for 1 min.
    trailblazer                 = { 79931, 199921, 2 }, -- Your movement speed is increased by 15% anytime you have not attacked for 3 sec.
    tranquilizing_shot          = { 79907, 19801 , 1 }, -- Removes 1 Enrage and 1 Magic effect from an enemy target.
    wilderness_medicine         = { 79936, 343242, 2 }, -- Mend Pet heals for an additional 25% of your pet's health over its duration, and has a 25% chance to dispel a magic effect each time it heals your pet.

    -- Marksmanship
    aimed_shot                  = { 79873, 19434 , 1 }, -- A powerful aimed shot that deals 6,688 Physical damage and causes your next 1-2 Arcane Shots or Multi-Shots to deal 75% more damage. Aimed Shot deals 50% bonus damage to targets who are above 70% health. Aimed Shot also fires a Serpent Sting at the primary target.
    bombardment                 = { 79889, 405804, 1 }, -- Kill Shot now grants the Trick Shots effect.
    bulletstorm                 = { 79817, 389019, 1 }, -- Each additional target your Rapid Fire or Aimed Shot ricochets to from Trick Shots increases the damage of Multi-Shot by 7% for 15 sec, stacking up to 10 times. The duration of this effect is not refreshed when gaining a stack.
    bullseye                    = { 79876, 204089, 1 }, -- When your abilities damage a target below 20% health, you gain 1% increased critical strike chance for 6 sec, stacking up to 30 times.
    bursting_shot               = { 79872, 186387, 1 }, -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by 50% for 6 sec, and dealing 114 Physical damage.
    calling_the_shots           = { 79902, 260404, 1 }, -- Every 50 Focus spent reduces the cooldown of Trueshot by 2.5 sec.
    careful_aim                 = { 79879, 260228, 2 }, -- Aimed Shot deals 25% bonus damage to targets who are above 70% health.
    chimaera_shot               = { 79915, 342049, 1 }, -- A two-headed shot that hits your primary target for 2,202 Nature damage and another nearby target for 1,101 Frost damage.
    counter_shot                = { 79836, 147362, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for 3 sec.
    crack_shot                  = { 79895, 321293, 1 }, -- Arcane Shot and Chimaera Shot Focus cost reduced by 20.
    deadeye                     = { 79892, 321460, 1 }, -- Kill Shot now has 2 charges and has its cooldown reduced by 3.0 sec.
    deathblow                   = { 79883, 378769, 1 }, -- Aimed Shot has a 15% and Rapid Fire has a 25% chance to grant a charge of Kill Shot, and cause your next Kill Shot to be usable on any target regardless of their current health.
    eagletalons_true_focus      = { 79901, 389449, 2 }, -- Trueshot lasts an additional 1.5 sec, reduces the Focus cost of Arcane Shot, Chimaera Shot, and Multi-Shot by 12%, and reduces the Focus Cost of Aimed Shot by 12%.
    focused_aim                 = { 79896, 378767, 2 }, -- Aimed Shot and Rapid Fire damage increased by 5%.
    heavy_ammo                  = { 79903, 378910, 1 }, -- Trick Shots now ricochets to 2 fewer targets, but each ricochet deals an additional 25% damage.
    hunters_knowledge           = { 79888, 378766, 2 }, -- Aimed Shot and Rapid Fire critical strike chance increased by 5%.
    improved_steady_shot        = { 79898, 321018, 1 }, -- Steady Shot now generates 10 Focus.
    in_the_rhythm               = { 79897, 407404, 1 }, -- When Rapid Fire fully finishes channeling, gain 12% haste for 6 sec.
    kill_command                = { 79838, 34026 , 1 }, -- Give the command to kill, causing your pet to savagely deal 1,632 Physical damage to the enemy.
    kill_shot                   = { 79834, 53351 , 1 }, -- You attempt to finish off a wounded target, dealing 6,032 Physical damage. Only usable on enemies with less than 20% health. Kill Shot deals 25% increased critical damage.
    killer_accuracy             = { 79900, 378765, 2 }, -- Kill Shot critical strike chance increased by 10%.
    legacy_of_the_windrunners   = { 79899, 406425, 2 }, -- Aimed Shot coalesces 2 extra Wind Arrows that also shoot your target for 119 Physical damage. Every 24 Wind Arrows fired generates 30 Focus and grants 1 charge of Aimed Shot. Modifiers to Aimed Shot damage also increase the damage of Wind Arrows.
    light_ammo                  = { 79903, 378913, 1 }, -- Trick Shots now causes Aimed Shot and Rapid Fire to ricochet to 2 additional targets.
    lock_and_load               = { 79884, 194595, 1 }, -- Your ranged auto attacks have a 8% chance to trigger Lock and Load, causing your next Aimed Shot to cost no Focus and be instant.
    lone_wolf                   = { 79871, 155228, 1 }, -- Increases your damage by 10% when you do not have an active pet.
    multishot                   = { 79840, 257620, 1 }, -- Fires several missiles, hitting your current target and all enemies within 10 yards for 1,273 Physical damage. Deals reduced damage beyond 5 targets.
    precise_shots               = { 79877, 260240, 2 }, -- Aimed Shot causes your next 1-2 Arcane Shots or Multi-Shots to deal 35% more damage.
    quick_load                  = { 79878, 378771, 1 }, -- When you fall below 40% heath, Bursting Shot's cooldown is immediately reset. This can only occur once every 25 sec.
    rapid_fire                  = { 79880, 257044, 1 }, -- Shoot a stream of 7 shots at your target over 1.9 sec, dealing a total of 13,215 Physical damage. Usable while moving. Rapid Fire causes your next Aimed Shot to cast 30% faster. Each shot generates 1 Focus.
    razor_fragments             = { 79831, 384790, 1 }, -- When the Trick Shots effect fades or is consumed, or after gaining Deathblow, your next Kill Shot will deal 50% increased damage, and shred up to 5 targets near your Kill Shot target for 25% of the damage dealt by Kill Shot over 6 sec.
    readiness                   = { 79813, 389865, 1 }, -- Wailing Arrow resets the cooldown of Rapid Fire and generates 2 charges of Aimed Shot.
    salvo                       = { 79830, 400456, 1 }, -- Your next Multi-Shot or Volley now also applies Explosive Shot to up to 2 targets hit.
    serpentstalkers_trickery    = { 79881, 378888, 1 }, -- Aimed Shot also fires a Serpent Sting at the primary target.
    sharpshooter                = { 79887, 378907, 2 }, -- Critical strike damage increased by 2%.
    steady_focus                = { 79891, 193533, 2 }, -- Using Steady Shot twice in a row increases your haste by 7% for 15 sec.
    streamline                  = { 79893, 260367, 2 }, -- Rapid Fire's damage is increased by 7%, and Rapid Fire also causes your next Aimed Shot to cast 15% faster.
    surging_shots               = { 79897, 391559, 1 }, -- Rapid Fire deals 35% additional damage, and Aimed Shot has a 15% chance to reset the cooldown of Rapid Fire.
    tactical_reload             = { 79874, 400472, 1 }, -- Aimed Shot and Rapid Fire cooldown reduced by 10%.
    target_practice             = { 79886, 321287, 1 }, -- Arcane Shot and Multi-Shot damage increased by 25%.
    trick_shots                 = { 79875, 257621, 1 }, -- When Multi-Shot hits 3 or more targets, your next Aimed Shot or Rapid Fire will ricochet and hit up to 5 additional targets for 55% of normal damage.
    trueshot                    = { 79882, 288613, 1 }, -- Reduces the cooldown of your Aimed Shot and Rapid Fire by 70%, and causes Aimed Shot to cast 50% faster for 15 sec. While Trueshot is active, you generate 50% additional Focus.
    unerring_vision             = { 79902, 386878, 1 }, --
    volley                      = { 79890, 260243, 1 }, -- Rain a volley of arrows down over 6 sec, dealing up to 6,372 Physical damage to any enemy in the area, and gain the effects of Trick Shots for as long as Volley is active.
    wailing_arrow               = { 79885, 392060, 1 }, -- Fire an enchanted arrow, dealing 6,015 Shadow damage to your target and an additional 2,438 Shadow damage to all enemies within 8 yds of your target. Non-Player targets struck by a Wailing Arrow have their spellcasting interrupted and are silenced for 3 sec.
    windrunners_barrage         = { 79813, 389866, 1 }, -- Wailing Arrow fires off 5 Wind Arrows at your primary target, and 10 Wind Arrows split among any secondary targets hit.
    windrunners_guidance        = { 79894, 378905, 1 }, -- Each Wind Arrow fired reduces the cooldown of Rapid Fire by ${$m1/1000}.1 sec, and every $s2 Wind Arrows fired increases the duration of your next Trueshot by ${$424571m1/1000}.1 sec, up to a maximum of ${$424571m1/1000*$424571u}.1 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting        = 653 , -- (356719) Stings the target, dealing 2,198 Nature damage and initiating a series of venoms. Each lasts 3 sec and applies the next effect after the previous one ends.  Scorpid Venom: 90% reduced movement speed.  Spider Venom: Silenced.  Viper Venom: 20% reduced damage and healing.
    consecutive_concussion = 5440, -- (357018) Concussive Shot slows movement by an additional 20%. Using Steady Shot 3 times on a concussed enemy stuns them for 4 sec.
    diamond_ice            = 5533, -- (203340) Victims of Freezing Trap can no longer be damaged or healed. Freezing Trap is now undispellable, but has a 5 sec duration.
    hunting_pack           = 3729, -- (203235) Aspect of the Cheetah has 50% reduced cooldown and grants its effects to allies within 15 yds.
    interlope              = 5531, -- (248518) Misdirection now causes the next 3 hostile spells cast on your target within 10 sec to be redirected to your pet, but its cooldown is increased by 15 sec. Your pet must be within 20 yards of the target for spells to be redirected.
    rangers_finesse        = 659 , -- (248443) Casting Aimed Shot provides you with Ranger's Finesse. After gaining 3 stacks of Ranger's Finesse, increase your next Volley's radius and duration by 50% or your next Bursting Shot's slow by an additional 25% and its knockback distance. Consuming Ranger's Finesse reduces the remaining cooldown of Aspect of the Turtle by 20 sec.
    sniper_shot            = 660 , -- (203155) Take a sniper's stance, firing a well-aimed shot dealing 20% of the target's maximum health in Physical damage and increases the range of all shots by 40% for 6 sec.
    survival_tactics       = 651 , -- (202746) Feign Death reduces damage taken by $m1% for $202748d.    tranquilizing_darts    = 5419, -- (356015) Interrupting or removing effects with Tranquilizing Shot and Counter Shot releases 8 darts at nearby enemies, each reducing the duration of a beneficial Magic effect by 4 sec.
    trueshot_mastery       = 658 , -- (203129) Reduces the cooldown of Trueshot by 20 sec, and Trueshot also restores 100% Focus.
    wild_kingdom           = 5442, -- (356707) Call in help from one of your dismissed Cunning pets for 10 sec. Your current pet is dismissed to rest and heal 30% of maximum health.
} )


-- Auras
spec:RegisterAuras( {
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
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=186258
    aspect_of_the_cheetah = {
        id = 186258,
        duration = 9,
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
    -- Talent:
    -- https://wowhead.com/beta/spell=120360
    barrage = {
        id = 120360,
        duration = 3,
        tick_time = 0.2,
        max_stack = 1
    },
    binding_shot = {
        id = 117526,
        duration = 8,
        max_stack = 1,
    },
    -- Bleeding for $w1 Physical damage every $t1 sec.  Taking $s2% increased damage from the Hunter's pet.
    -- https://wowhead.com/beta/spell=321538
    bloodshed = {
        id = 321538,
        duration = 18,
        tick_time = 3,
        max_stack = 1
    },
    bombardment = {
        id = 386875,
        duration = 120,
        max_stack = 1,
    },
    bulletstorm = {
        id = 389020,
        duration = 15,
        max_stack = 10
    },
    -- Talent: Critical strike chance increased by $s1%.
    -- https://wowhead.com/beta/spell=204090
    bullseye = {
        id = 204090,
        duration = 6,
        max_stack = 15
    },
    -- Talent: Movement speed reduced by $s4%.
    -- https://wowhead.com/beta/spell=186387
    bursting_shot = {
        id = 186387,
        duration = 6,
        type = "Ranged",
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=224729
    bursting_shot_disorient = {
        id = 224729,
        duration = 4,
        mechanic = "snare",
        max_stack = 1
    },
    -- Talent: Stealthed.
    -- https://wowhead.com/beta/spell=199483
    camouflage = {
        id = 199483,
        duration = 60,
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
    -- Your abilities are empowered.    $@spellname187708: Reduces the cooldown of Wildfire Bomb by an additional 1 sec.  $@spellname320976: Applies Bleeding Gash to your target.
    -- https://wowhead.com/beta/spell=361738
    coordinated_assault = {
        id = 361738,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Your next Kill Shot can be used on any target, regardless of their current health.
    -- https://wowhead.com/beta/spell=378770
    deathblow = {
        id = 378770,
        duration = 12,
        max_stack = 1
    },
    --[[ Talent: Your next Aimed Shot will fire a second time instantly at $s4% power and consume no Focus, or your next Rapid Fire will shoot $s3% additional shots during its channel.
    -- https://wowhead.com/beta/spell=260402
    double_tap = {
        id = 260402,
        duration = 15,
        max_stack = 1
    }, ]]
    -- Vision is enhanced.
    -- https://wowhead.com/beta/spell=6197
    eagle_eye = {
        id = 6197,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Focus cost of all Aimed Shot reduced by $s1%.  Focus cost of Arcane Shot, Chimaera Shot, and Multi-Shot reduced by $s2%.
    -- https://wowhead.com/beta/spell=389450
    eagletalons_true_focus = {
        id = 389450,
        duration = -1,
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
    freezing_trap = {
        id = 3355,
        duration = 60,
        max_stack = 1,
    },
    -- Can always be seen and tracked by the Hunter.; Damage taken increased by $428402s4% while above $s3% health.
    -- https://wowhead.com/beta/spell=257284
    hunters_mark = {
        id = 257284,
        duration = 3600,
        tick_time = 0.5,
        type = "Magic",
        max_stack = 1
    },
    in_the_rhythm = {
        id = 407405,
        duration = 6,
        max_stack = 1
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
   -- Talent: Aimed Shot costs no Focus and is instant.
    -- https://wowhead.com/beta/spell=194594
    lock_and_load = {
        id = 194594,
        duration = 15,
        max_stack = 1
    },
    lone_wolf = {
        id = 164273,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Threat redirected from Hunter.
    -- https://wowhead.com/beta/spell=34477
    misdirection = {
        id = 34477,
        duration = 30,
        max_stack = 1
    },
    pathfinding = {
        id = 264656,
        duration = 3600,
        max_stack = 1,
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
    -- Talent: Increased movement speed by $s1%.
    -- https://wowhead.com/beta/spell=118922
    posthaste = {
        id = 118922,
        duration = 4,
        max_stack = 1
    },
    -- Talent: Damage of $?s342049[Chimaera Shot][Arcane Shot] or Multi-Shot increased by $s1%.
    -- https://wowhead.com/beta/spell=260242
    precise_shots = {
        id = 260242,
        duration = 15,
        max_stack = 2
    },
    -- Talent: Being targeted by Rapid Fire.
    -- https://wowhead.com/beta/spell=257044
    rapid_fire = {
        id = 257044,
        duration = function () return 2 * haste end,
        tick_time = function ()
            return ( 2 * haste ) / 7
        end,
        type = "Ranged",
        max_stack = 1
    },
    razor_fragments = {
        id = 388998,
        duration = 15,
        max_stack = 1,
    },
    razor_fragments_bleed = {
        id = 385638,
        duration = 6,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    salvo = {
        id = 400456,
        duration = 15,
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
    -- Talent: Suffering $s2 Nature damage every $t2 sec.
    -- https://wowhead.com/beta/spell=271788
    serpent_sting = {
        id = 271788,
        duration = 18,
        type = "Ranged",
        max_stack = 1
    },
    -- Talent: Haste increased by $s1%.
    -- https://wowhead.com/beta/spell=193534
    steady_focus = {
        id = 193534,
        duration = 15,
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
    -- Talent: Aimed Shot cast time reduced by $s1%.
    -- https://wowhead.com/beta/spell=342076
    streamline = {
        id = 342076,
        duration = 15,
        max_stack = 1
    },
    survival_of_the_fittest = {
        id = 281195,
        duration = 6,
        max_stack = 1,
    },
    tar_trap = {
        id = 135299,
        duration = 30,
        max_stack = 1
    },
    trailblazer = {
        id = 231390,
        duration = 3600,
        max_stack = 1,
    },
    trick_shots = {
        id = 257622,
        duration = 20,
        max_stack = 2,
    },
    trueshot = {
        id = 288613,
        duration = function () return ( 15 + ( legendary.eagletalons_true_focus.enabled and 3 or 0 ) + ( 1.5 * talent.eagletalons_true_focus.rank ) + ( buff.windrunners_guidance.stack ) ) * ( 1 + ( conduit.sharpshooters_focus.mod * 0.01 ) ) end,
        max_stack = 1,

        -- windrunners_guidance[424571] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Talent: Critical strike chance increased by $s1%. Critical damage dealt increased by $s2%.
    -- https://wowhead.com/beta/spell=386877
    unerring_vision = {
        id = 386877,
        duration = 60,
        max_stack = 10,
        copy = 274447 -- Azerite.
    },
    -- Talent: Raining arrows down in the target area.
    -- https://wowhead.com/beta/spell=260243
    volley = {
        id = 260243,
        duration = 6,
        max_stack = 1
    },
     -- Duration of your next Trueshot increased by ${$m1/1000}.1 sec.
    windrunners_guidance = {
        id = 424571,
        duration = 60,
        max_stack = 10,
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=195645
    wing_clip = {
        id = 195645,
        duration = 15,
        max_stack = 1
    },

    -- Conduit
    brutal_projectiles = {
        id = 339929,
        duration = 3600,
        max_stack = 1,
    },

    -- Legendaries
    nessingwarys_trapping_apparatus = {
        id = 336744,
        duration = 5,
        max_stack = 1,
        copy = { "nesingwarys_trapping_apparatus", "nesingwarys_apparatus", "nessingwarys_apparatus" }
    },
    secrets_of_the_unblinking_vigil = {
        id = 336892,
        duration = 20,
        max_stack = 1,
    },

    -- stub.
    eagletalons_true_focus_stub = {
        duration = 10,
        max_stack = 1,
        copy = "eagletalons_true_focus"
    }
} )


spec:RegisterStateExpr( "ca_execute", function ()
    return talent.careful_aim.enabled and ( target.health.pct > 70 )
end )

spec:RegisterStateExpr( "ca_active", function ()
    return talent.careful_aim.enabled and ( target.health.pct > 70 )
end )


local steady_focus_applied = 0
local steady_focus_casts = 0
local bombardment_arcane_shots = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

    if sourceGUID == state.GUID then
        if ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
            if spellID == 193534 then -- Steady Aim.
                steady_focus_applied = GetTime()
                steady_focus_casts = 0
            elseif spellID == 378880 then
                bombardment_arcane_shots = 0
            end
        elseif subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 185358 and state.talent.bombardment.enabled then
                bombardment_arcane_shots = ( bombardment_arcane_shots + 1 ) % 4
            end
        
            if state.talent.steady_focus.enabled then
                if spellID == 56641 and GetTime() - steady_focus_applied > 0.5 then
                    steady_focus_casts = ( steady_focus_casts + 1 ) % 2
                elseif class.abilities[ spellName ] and class.abilities[ spellName ].gcd ~= "off" then
                    steady_focus_casts = 0
                end
            end
        end
    end
end )

spec:RegisterStateExpr( "last_steady_focus", function ()
    return steady_focus_applied
end )

spec:RegisterStateExpr( "steady_focus_count", function ()
    return steady_focus_casts
end )

spec:RegisterStateExpr( "bombardment_count", function ()
    return bombardment_arcane_shots
end )


local ExpireNesingwarysTrappingApparatus = setfenv( function()
    focus.regen = focus.regen * 0.5
    forecastResources( "focus" )
end, state )


spec:RegisterStateTable( "tar_trap", setmetatable( {}, {
    __index = function( t, k )
        return state.debuff.tar_trap[ k ]
    end
} ) )


spec:RegisterGear( "tier29", 200390, 200392, 200387, 200389, 200391 )
spec:RegisterAuras( {
    -- 2pc
    find_the_mark = {
        id = 394366,
        duration = 15,
        max_stack = 1
    },
    hit_the_mark = {
        id = 394371,
        duration = 6,
        max_stack = 1
    },
    -- 4pc
    focusing_aim = {
        id = 394384,
        duration = 15,
        max_stack = 1
    }
} )

spec:RegisterGear( "tier30", 202482, 202480, 202479, 202478, 202477 )
spec:RegisterGear( "tier31", 207216, 207217, 207218, 207219, 207221 )




spec:RegisterHook( "reset_precast", function ()
    if now - action.serpent_sting.lastCast < gcd.execute * 2 and target.unit == action.serpent_sting.lastUnit then
        applyDebuff( "target", "serpent_sting" )
    end

    if debuff.tar_trap.up then
        debuff.tar_trap.expires = debuff.tar_trap.applied + 30
    end

    if buff.nesingwarys_apparatus.up then
        state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireNesingwarysTrappingApparatus, buff.nesingwarys_apparatus.expires )
    end

    if legendary.eagletalons_true_focus.enabled then
        rawset( buff, "eagletalons_true_focus", buff.trueshot_aura )
    else
        rawset( buff, "eagletalons_true_focus", buff.eagletalons_true_focus_stub )
    end

    if now - action.volley.lastCast < 6 then applyBuff( "volley", 6 - ( now - action.volley.lastCast ) ) end

    if now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end

    last_steady_focus = nil
    steady_focus_count = nil

    -- If the last GCD ability wasn't Stready Shot, reset the counter.
    if talent.steady_focus.enabled and steady_focus_count > 0 and prev_gcd.last ~= "steady_shot" then
        if Hekili.ActiveDebug then Hekili:Debug( "Resetting Steady Focus counter as last GCD spell was '%s'.", ( prev_gcd.last or "Unknown" ) ) end
        steady_focus_count = 0
    end
end )

spec:RegisterHook( "runHandler", function( token )
    if talent.steady_focus.enabled then
        if token == "steady_shot" then
            steady_focus_count = steady_focus_count + 1

            if steady_focus_count == 2 then
                applyBuff( "steady_focus" )
                steady_focus_count = 0
            end
        elseif class.abilities[ token ] and class.abilities[ token ].gcd ~= "off" then
            steady_focus_count = 0
        end
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Trait: A powerful aimed shot that deals $s1 Physical damage$?s260240[ and causes your next 1-$260242u ][]$?s342049&s260240[Chimaera Shots]?s260240[Arcane Shots][]$?s260240[ or Multi-Shots to deal $260242s1% more damage][].$?s260228[    Aimed Shot deals $393952s1% bonus damage to targets who are above $260228s1% health.][]$?s378888[    Aimed Shot also fires a Serpent Sting at the primary target.][]
    aimed_shot = {
        id = 19434,
        cast = function ()
            if buff.lock_and_load.up then return 0 end
            return 2.5 * haste * ( buff.rapid_fire.up and 0.7 or 1 ) * ( buff.trueshot.up and 0.5 or 1 ) * ( buff.streamline.up and ( 1 - 0.15 * talent.streamline.rank ) or 1 )
        end,
        charges = 2,
        cooldown = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) * ( 1 - 0.1 * talent.tactical_reload.rank ) end,
        recharge = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) * ( 1 - 0.1 * talent.tactical_reload.rank ) end,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if buff.lock_and_load.up or buff.secrets_of_the_unblinking_vigil.up then return 0 end
            return 35 * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) * ( buff.trueshot.up and ( 1 - 0.125 * talent.eagletalons_true_focus.rank ) or 1 )
        end,
        spendType = "focus",

        talent = "aimed_shot",
        startsCombat = true,

        cycle = function () return ( talent.serpentstalkers_trickery.enabled or runeforge.serpentstalkers_trickery.enabled ) and "serpent_sting" or nil end,

        usable = function ()
            if action.aimed_shot.cast > 0 and moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
            return true
        end,

        handler = function ()
            if buff.lock_and_load.up then removeBuff( "lock_and_load" )
            elseif buff.secrets_of_the_unblinking_vigil.up then removeBuff( "secrets_of_the_unblinking_vigil" ) end
            if talent.precise_shots.enabled then applyBuff( "precise_shots" ) end
            if talent.bulletstorm.enabled and buff.trick_shots.up then
                addStack( "bulletstorm", nil, min( 8 - 2 * talent.heavy_ammo.rank + 2 * talent.light_ammo.rank, true_active_enemies ) )
            end
            if buff.find_the_mark.up then
                removeBuff( "find_the_mark" )
                applyDebuff( "target", "hit_the_mark" )
            end
            if buff.volley.down and buff.trick_shots.up then
                removeBuff( "trick_shots" )
                if talent.razor_fragments.enabled then applyBuff( "razor_fragments" ) end
            end
            -- TODO: Check if this needs to move to an impact handler.
            if talent.serpentstalkers_trickery.enabled then applyDebuff( "target", "serpent_sting" ) end
        end,
    },

    -- A quick shot that causes $sw2 Arcane damage.$?s260393[    Arcane Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    arcane_shot = {
        id = 185358,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return ( talent.crack_shot.enabled and 20 or 40 ) * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) * ( buff.trueshot.up and ( 1 - 0.125 * talent.eagletalons_true_focus.rank ) or 1 ) end,
        spendType = "focus",

        startsCombat = true,

        notalent = "chimaera_shot",

        handler = function ()
            removeBuff( "focusing_aim" )
            removeStack( "precise_shots" )

            if talent.bombardment.enabled then
                if bombardment_count == 3 then
                    applyBuff( "bombardment" )
                    bombardment_count = 0
                else
                    bombardment_count = bombardment_count + 1
                end
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

        spend = function () return 60 * ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) end,
        spendType = "focus",

        talent = "barrage",
        startsCombat = true,

        start = function ()
            applyBuff( "barrage" )
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
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "binding_shot" )
        end,
    },

    -- Talent: Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by $s4% for $d, and dealing $s1 Physical damage.$?s378771[    When you fall below $378771s1% heath, Bursting Shot's cooldown is immediately reset. This can only occur once every $385646d.][]
    bursting_shot = {
        id = 186387,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        spend = function () return 10 * ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) end,
        spendType = "focus",

        talent = "bursting_shot",
        startsCombat = true,

        handler = function ()
            applyBuff( "bursting_shot" )
        end,
    },

    -- Talent: A two-headed shot that hits your primary target for $344120sw1 Nature damage and another nearby target for ${$344121sw1*($s1/100)} Frost damage.$?s260393[    Chimaera Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    chimaera_shot = {
        id = 342049,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( talent.crack_shot.enabled and 20 or 40 ) * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) * ( buff.trueshot.up and ( 1 - 0.125 * talent.eagletalons_true_focus.rank ) or 1 ) end,
        spendType = "focus",

        talent = "chimaera_shot",
        startsCombat = true,

        handler = function ()
            removeBuff( "focusing_aim" )
            removeStack( "precise_shots" )
        end,
    },


    chimaeral_sting = {
        id = 356719,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "chimaeral_sting",
        startsCombat = false,
        texture = 132211,

        toggle = "cooldowns",

        handler = function ()
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
            applyBuff( "concussive_shot" )
        end,
    },

    --[[ Removed in 10.0.5 -- Talent: Your next Aimed Shot will fire a second time instantly at $s4% power without consuming Focus, or your next Rapid Fire will shoot $s3% additional shots during its channel.
    double_tap = {
        id = 260402,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "physical",

        talent = "double_tap",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "double_tap" )
        end,
    }, ]]


    explosive_shot = {
        id = 212431,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 20,
        spendType = "focus",

        talent = "explosive_shot",
        startsCombat = false,
        texture = 236178,

        handler = function ()
        end,
    },


    interlope = {
        id = 248518,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        pvptalent = "interlope",
        startsCombat = false,
        texture = 132180,

        handler = function ()
        end,
    },


    -- Talent: You attempt to finish off a wounded target, dealing $s1 Physical damage. Only usable on enemies with less than $s2% health.$?s343248[    Kill Shot deals $343248s1% increased critical damage.][]
    kill_shot = {
        id = 53351,
        cast = 0,
        charges = function() return talent.deadeye.enabled and 2 or nil end,
        cooldown = function () return talent.deadeye.enabled and 7 or 10 end,
        recharge = function() return talent.deadeye.enabled and 7 or nil end,
        gcd = "spell",
        school = "physical",

        spend = function () return buff.flayers_mark.up and 0 or 10 end,
        spendType = "focus",

        talent = "kill_shot",
        startsCombat = true,

        usable = function () return buff.deathblow.up or buff.hunters_prey.up or buff.flayers_mark.up or target.health_pct < 20, "requires flayers_mark/hunters_prey or target health below 20 percent" end,
        handler = function ()
            if buff.razor_fragments.up then
                removeBuff( "razor_fragments" )
                applyDebuff( "target", "razor_fragments_bleed" )
            end
            if buff.flayers_mark.up and legendary.pouch_of_razor_fragments.enabled then
                applyDebuff( "target", "pouch_of_razor_fragments" )
                removeBuff( "flayers_mark" )
            else
                removeBuff( "hunters_prey" )
                if buff.deathblow.up then
                    removeBuff( "deathblow" )
                    if talent.razor_fragments.enabled then applyBuff( "razor_fragments" ) end
                end
            end

            if set_bonus.tier30_4pc > 0 then
                reduceCooldown( "aimed_shot", 1.5 )
                reduceCooldown( "rapid_fire", 1.5 )
            end
        end,
    },

    -- Talent: Fires several missiles, hitting your current target and all enemies within $A1 yards for $s1 Physical damage. Deals reduced damage beyond $2643s1 targets.$?s260393[    Multi-Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    multishot = {
        id = 257620,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function () return 20 * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) * ( buff.trueshot.up and ( 1 - 0.125 * talent.eagletalons_true_focus.rank ) or 1 ) end,
        spendType = "focus",

        talent = "multishot",
        startsCombat = true,

        handler = function ()
            removeBuff( "bulletstorm" )
            removeBuff( "focusing_aim" )
            removeStack( "precise_shots" )

            if buff.bombardment.up then
                applyBuff( "trick_shots" )
                removeBuff( "bombardment" )
            end

            if buff.salvo.up then
                applyDebuff( "target", "explosive_shot" )
                if active_enemies > 1 and active_dot.explosive_shot < active_enemies then active_dot.explosive_shot = active_dot.explosive_shot + 1 end
                removeBuff( "salvo" )
            end

            if talent.trick_shots.enabled and active_enemies > 2 then applyBuff( "trick_shots" ) end
        end,
    },

    -- Talent: Shoot a stream of $s1 shots at your target over $d, dealing a total of ${$m1*$257045sw1} Physical damage.  Usable while moving.$?s260367[    Rapid Fire causes your next Aimed Shot to cast $342076s1% faster.][]    |cFFFFFFFFEach shot generates $263585s1 Focus.|r
    rapid_fire = {
        id = 257044,
        cast = function () return ( 2 * haste ) end,
        channeled = true,
        cooldown = function() return 20 * ( buff.trueshot.up and 0.3 or 1 ) * ( 1 - 0.1 * talent.tactical_reload.rank ) end,
        gcd = "spell",
        school = "physical",

        talent = "rapid_fire",
        startsCombat = true,

        start = function ()
            removeBuff( "brutal_projectiles" )
            applyBuff( "rapid_fire" )
            if set_bonus.tier31_2pc > 0 then applyBuff( "volley", 2 * haste ) end
            if talent.bulletstorm.enabled and buff.trick_shots.up then
                addStack( "bulletstorm", nil, min( 8 - 2 * talent.heavy_ammo.rank + 2 * talent.light_ammo.rank, true_active_enemies ) )
            end
            if talent.streamline.enabled then applyBuff( "streamline" ) end
        end,

        finish = function ()
            if buff.volley.down then
                removeBuff( "trick_shots" )
                if talent.razor_fragments.enabled then applyBuff( "razor_fragments" ) end
            end

            if talent.in_the_rhythm.up then applyBuff( "in_the_rhythm" ) end
        end,
    },

    -- Your next Multi-Shot or Volley now also applies Explosive Shot to up to 2 targets hit.
    salvo = {
        id = 400456,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "salvo",
        startsCombat = false,
        texture = 1033904,

        handler = function ()
            applyBuff( "salvo" )
        end,
    },

    sniper_shot = {
        id = 203155,
        cast = 3,
        cooldown = 10,
        gcd = "spell",

        spend = 40,
        spendType = "focus",

        pvptalent = "sniper_shot",
        startsCombat = false,
        texture = 1412205,

        handler = function ()
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
            applyBuff( "stampede" )
        end,
    },

    -- A steady shot that causes $s1 Physical damage.    Usable while moving.$?s321018[    |cFFFFFFFFGenerates $s2 Focus.|r][]
    steady_shot = {
        id = 56641,
        cast = 1.8,
        cooldown = 0,
        gcd = "spell",

        spend = function () return talent.improved_steady_shot.enabled and ( buff.trueshot.up and -15 or -10 ) or 0 end,
        spendType = "focus",

        startsCombat = true,
        texture = 132213,

        handler = function ()
            if debuff.concussive_shot.up then debuff.concussive_shot.expires = debuff.concussive_shot.expires + 3 end
        end,
    },

    -- Talent: Reduces the cooldown of your Aimed Shot and Rapid Fire by ${100*(1-(100/(100+$m1)))}%, and causes Aimed Shot to cast $s4% faster for $d.    While Trueshot is active, you generate $s5% additional Focus$?s386878[ and you gain $386877s1% critical strike chance and $386877s2% increased critical damage dealt every $386876t1 sec, stacking up to $386877u times.][].$?s260404[    Every $260404s2 Focus spent reduces the cooldown of Trueshot by ${$260404m1/1000}.1 sec.][]
    trueshot = {
        id = 288613,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "physical",

        talent = "trueshot",
        startsCombat = false,

        toggle = "cooldowns",

        nobuff = function ()
            if settings.trueshot_vop_overlap then return end
            return "trueshot"
        end,

        handler = function ()
            focus.regen = focus.regen * 1.5
            reduceCooldown( "aimed_shot", ( 1 - 0.3077 ) * 12 * haste )
            reduceCooldown( "rapid_fire", ( 1 - 0.3077 ) * 20 * haste )
            applyBuff( "trueshot" )
            if buff.windrunners_guidance.up then removeBuff( "windrunners_guidance" ) end

            if azerite.unerring_vision.enabled or talent.unerring_vision.enabled then
                applyBuff( "unerring_vision" )
            end
        end,

        meta = {
            duration_guess = function( t )
                return talent.calling_the_shots.enabled and 90 or t.duration
            end,
        }
    },

    -- Talent: Rain a volley of arrows down over $d, dealing up to ${$260247s1*12} Physical damage to any enemy in the area, and gain the effects of Trick Shots for as long as Volley is active.
    volley = {
        id = 260243,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "physical",

        talent = "volley",
        startsCombat = true,

        handler = function ()
            applyBuff( "volley" )
            applyBuff( "trick_shots", 6 )

            if buff.salvo.up then
                applyDebuff( "target", "explosive_shot" )
                if active_enemies > 1 and active_dot.explosive_shot < active_enemies then active_dot.explosive_shot = active_dot.explosive_shot + 1 end
                removeBuff( "salvo" )
            end
        end,
    },


    wild_kingdom = {
        id = 356707,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "wild_kingdom",
        startsCombat = false,
        texture = 236159,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "spectral_agility",

    package = "Marksmanship",
} )


spec:RegisterSetting( "prevent_hardcasts", false, {
    name = "Prevent Hardcasts While Moving",
    desc = "If checked, the addon will not recommend |T135130:0|t Aimed Shot or |T132323:0|t Wailing Arrow when moving and hardcasting.",
    type = "toggle",
    width = "full"
} )

--[[ spec:RegisterSetting( "eagletalon_swap", false, {
    name = "Use |T132329:0|t Trueshot with Eagletalon's True Focus Runeforge",
    desc = "If checked, the default priority includes usage of |T132329:0|t Trueshot pre-pull, assuming you will successfully swap " ..
        "your legendary on your own.  The addon will not tell you to swap your gear.",
    type = "toggle",
    width = "full",
} ) ]]


spec:RegisterPack( "Marksmanship", 20230720, [[Hekili:T3vFZTTns)plD6CkwJTLLyItAYJTN55ANEtZCxBNZT3Z)jjyjijEMIuLVyfLXJ(S)SlaijaiajiTCZlvtttSjb(HflwS4hawcmE04FB8TZjP0X)S3qVxo8nEdhmc)Pxn(20DBOJVDdz29KLWpeswd)9)IeFFYAsyYk)n4l3ferMJGKeLfpdsW3UF6Q00njV7Ilw6NUk7UbZIwFrI)6SasQFu4SyYIu83NDX4BVlZpi9NchFNjHy4LJVLKLUkkE8T36V(7hF7k)5ZP8uttMn(wm1Np8nNp6TVB)0)f5E6(P)wCgnzvu6(PZIcN7JLyY(PRJIH3TikEP)d(Hl3p1pC)uizXq6w4VCvAYG9VF)7lW7sNWlng0dBiX0WuLSp0dY()MSXF((P)OplL(Rzf7dq5m9)1FnfEZTaQ)p7NsMJ)CkLgGfgzJesV(CVxdi9drHVivwsMNfZqJu(qPCD55JWYh0yBc8xStoJbrl9Nb5lekYy66OhOmqGsNmFhxI2pfQnX7KW7vN)YHVdrXF5sAmKksWdr7NUfACbLuwqQ)58mUDff0Q)NOGakaMFctQtjbaG05kaYQw)(gSjh0)XrRzIRWa57rdKbJVnWpjnbTSsJ9NDpwbWF7NzwS0qYDb05J)7JVDwSFkn2NaPJvudsy1MjlIMLLmqKW9t7bT3sVyYSOSWu2JVlBXc1mbQgIp2mF1(PFhydodflWcNNgusgNcMQwfegIXKpgfpzrmz5AqQsgKTPeP79dckW5Lio5VH(Hnbrj(pq5VwcFiLVsoLZPK0vtMTICFmzTwcVuoHjPK1BOZPAP51YPzlXpamPMqIJJ2QLW3OvplWLgVbQztssHCkx9JPlIbdomdmfSODz1U5XKKj3bjtPz5BksHarqGdUNgNmH1WtbJX8s)2z7MfqNKsIxsbRbWwaKVVZA7akPGMKgsx7tHMZB2p9nLY)DqLfDSbq8wzDXdmdynLWOH13ANM3pCE02WsSYFmdc7wUciGAlRzxYc8MRHoKFGollfQ2GFdzfAsg4odA04zPqhLx2XOdOjla)pSsx3Cnpze0BKWARI61qVRgAJyc4jIEvUxLYZXMy6m)eQipOYC)0hFSaoHsoBd)PlYG(rqowHsSamOp7mssQ43oD)0LZMpyn5d7N2h(dFKJy)n8k)pgHo0uQsViH5RJvPod11OYa(3vu0)5wAskZ3juxy(GfzgDIc)o4D)FaMBXKGaWfyui(3O0aUdxa)p6KmklausGEMGEF5ErzLh3)loaHWHp4EoElQ)3p9x5Qfrs2pnlmGMKi7A3hFkOwWkK0amLfibFjulI3canGzs8YNOjXxwnZHrTPPEfWkG1w)pHbPW23FnYpjcznKceIgGddIf8sERnysKfGUyijI8d1Wh8JYGFfCSk03V6a4aWA)7lDhCuV2ZylH4nSHbz(lNfH6aq9Yl1bLMgd4VQh)vYUzHMMxvkMZw5VMa6OIX7g9A3L0sldZwo5wiSxDhyMagPPrXRhWAL2pfuEJgYmjAtTQu4xJ0BkeCxhjSMUmwgBCdZ4AIF4)LYLOUoaPIz)VW8)KH(nUJKqrdrDhwClwcYcguEXCIX5oN4(SErUjn3DgNNp8BWljB2eSJHIAVeU5U9bMRBiZeKkmuZiByG8wRG0HMtfExE2hsVdqRyP414q9gR63rwojAbVvnHHJNkrUs(NkStsX29feqckiix07dP5sJnXMubBCQm)bmzm)pMZOql12gRygmu3e(VmbzSZ5TpHpzXzZtk4T228cAHW7Xoq58zDIIh475LCxcL9AKDOu0rjbFAkR3PtItsAbPzNeeW2XR9LI0uDynRO3UO13rsRFMpL11GOq6KTrblQYhmjB9AOm3qno7fSKYhpD8TaD3Y8HZ3ZKjaxKjbGBoyK5jBY(4hb)E3f9bjMegEzngeYepu8K9RCPtJAdoCCe6tdhEpDBu(q4seK2sX(WkuUySWy0UYNQkIJC2h0SfgNltPENpPHs32OfOHC6HCtALb9nSmPAqBAgUJTmxodgTg9NywDRUYa66j(ieOkMGlYrcHV2kkTrPr6KD5A9ZKyJkqEvmv0wkwEfhAnkvpwAimWp5ASRjR7vHpgd9UI2GdSl5H)bcibWBXFkid9UfffGoWlDNhZ1w90jYYPXWTzminJQApHCzsO7OQwufuFhDj)b0pSbima9z4EjMa5DjQJzJCPlDZZIzlWIGunUSxtk5zwxoMSmJ1B60kvSciVOOHOGlgt(ljIP(CGQ(eX76lx95TidshnyfjzcWDzcMpr1V8LfYQCf4LdRlDSMgJLLxDLLNJLLNPYYKBGByn4gAcq)dxwDYl36VmKeWiHrslBLse964WZ73ikySph7XS1xJNnC(HaS(XCQNyss2foJX9JxRPlwa2s8EPdyM75d9bPBcdAtdC0C)e9j1vF9Jr1uQsYFkRQwV8Z9UiPtQwj4p30yznxlm1BN1WPvD(nu(jR5lVissM3Pf(v)GQ1UTaJuOcqlB7CT62uZfx2mmyBZv1Q9nYL4k9Vu7409UwLosUYC)xvNxYquUkaAzT8f2ZY12YsVMKZRBso7xoSD31x8u8xhnMUZVFGcd8VMnXvwxhGqDuiBBieqj33G7bOO31G9t)Pqw3Oz0W5mQjBI9JaUe7ENAViUx55K1KL0INDgUEF8Y6gXMfH)Cb82EpJ4eQssu6wkK3jJMKxhmreSDDohvxNtZMsDzmwZMAgBJ1HWSPMNvtTr2m18SzQzuoVUj50qNZ2RV06C(vVgRVj7zpf7zBZ1qKAyEWjbrPY)oQoJwSyYYzZ13XH61759mguYpPYRQ2PZb2DL2gDTimlGLKhRVPOKkDD2M1wfUXAPFoFYdnbaKSlzwGwGPN13aZr4vdzsGg9wHATIIZRIIRwjZHK0DHhxTDVAz2RueyYTxghetG7IssCO77vvu31kaN2eEgB(6x0iAw3K39WETg1T2tqJ(k5QffjPD(Nv8uo0s)88zuvmxrN4ODq854AzyuX2yHisNAljBrwgGkLjPrtM7tlMi6bPEPXN73tWPaRodgbajviWjIufFX8Kym4q2EZPbe2gBWORH7be(0vKaC2wilrbILqjV)RS9wnicx2jsbi(HISYS6hGXTtaoNu85iaCJgU8TLsUhR8Ami95L(UIYaMuBeFUDjKhWLWzboh9aIknsqjVISzdnmPIqkQN4(a3u1JPOig5hla7oHQIvtHAtF(sgOr61q1WpCbng(tr9NeUtVjKPfz8TtbQ2yDnnVQdd3Fozzyuskg6rOgrmfxeLO45OSgLxZsyBQAHOVH4hZOwZwa3yAswqQuBfp18YgjFyB)5e45Pr(WZjYhU1tSoMbE26WyAzS6g5JQJH6Wip14ITPz5xBvOvKpmbq3h)U1KpQYARwjZHK0DH3i5d7fXHG8rdMavjFyBbi6k5dJ45k5JQlV7bI8rnCYSs(O5vU5Gq(OH5c9u854Az0m5dlEfoaKpAx9IVlpjnS7Pnf3ON0XqhvShnvteFi7ESgw9fhNrzY0o0zyP3Tfvb5rXJ5WMQiqPovjeQWE5I9qMUKmBhlsewrNS1pCECwyinwvRisS0RNSmZFojCgT6EskTXUgw8D3IocLG3OHqPITN1kHCRiQoRDVxRR0vdlfRBPQRXeR7X0tPHMMKzkwyFJCmDuBSe)DQrwIXqewjSyRlEJRj6ynT7x1Sx11eKS1f1R8EACuLJrhtDbUXyW8OelHsrcrUKAkAARAzQPwSBOx4S64EhFCVJnSkk9lTOB5EhxoPhPqp3wa3ug1AABIP2h7boPqTpSJ7OS5Jd1CXS9sZZJF6aRoK1C(PgTgmrv39SHHqo4XPUTWr(KwgrYwgATF1(OkrfRlHne(Mzez6Hf9xsng3WgI(AZwt6lrZ)hBs(2Ju69TpM4riJYGh89IQDE0bn35iDN6JrlKEeVNRoQnQ3VJUGfpr(iEH0pKYBCa56xWvsqjGM4RWr3ft(6Zi0p(caXfS47jafGSaMycklsy(QorMZ)QY4DIQwnf9ZSwtHQ4gwkQPAwk3alekgfV5R00msyE8zXdAxBmBCT73F17pzOZeZY)G)Lh4YhCGcDqZFxtk8aLi5OLm7HHDDKMRqVRMyUUrQ)anL1Kq2GeEJuzVwqnxvQ9AyctM)wc6qWFx5BCWRHP4CWkzsm0dMwwUn(jM4yGNR9feApWZXq8U2zxxSgsvzSa8JlfbyqAA8940MA5mDz9KnqNUkFR6eLxljkbrrqVGS4DTzYQplIcoB6eWYgS(jbbomX3dV482sPbDmWuoDFA0bSp26j)3S5SplwtZLUHv1iFmeMGeKLuwvfRM0kkjiD1Gn4(sCvXIo1qT0tsPVjI9Vg2qHANwRNMcxWTvPP1qy1Z6fbdqNGpv89VdKGbFNXiBQeref6VEd)Rvhja8I0IVtGxGmV(JmOLzoU7k4idKS0O1Wyhi)Nvird8JB)FYIHQrVdyIefcfh71VWWsF9coretVkFCvijNm6d9lq9nMrv6d(vdudFkWoIPnA96sDdS)1lTr2umYl2GEzyAHiQaS3FU1dlQn9VVmTIX2NFMRWFWRn7FVbJEX34u7S4V0SelXXttitR(1c1GCv8r60ojZIjxXxWJMCv5l7rVX5vMXJ7gsdm15DRJKfD2t0lXRpaYNr9FYHrX)eREw6OBDX01BEBAr3DS8mTE8AfvDlzVJnAh8o8p3UHFPzGZxsrnm1xb1MHtSsEQR8ybQMxyYwGQ(YiAazdj55e9wIl09PEu5jOdsSti3mME13Yv51UjPvxaydi35wUUHElX1K(1qc6Ge7eYwXmAdLV)bj81r7fw2sLEvNosVtuPVF9OEN8nw66)4J4Y9C1OlF8rZByYn236JhFuzIg1Ks(MKCQ5ni5V594Jg2yKRTSPi9XkJzpoqLXEx6BE5qBVhuJkO6zd1QMBQOQ382)XhvBkUzKMs7kVl7NBL8vBl8f)LVfUSB(HJg7iB8yFMiVyP4uwCqTYW4YwxbylKWEcaBKhTOn8WSKcDLz1ZcXkx4r4mZNNvWBhSoX9PlYRta3iKpnovUqHWzsppRG3oyDI2txKxNa2gKhPt9xNbBpsN6R9w4IE5vytP4AohBlUMLED9R0yXqipHbPRxs74Gi2bTqTMB0uNRtP08ScFJaBiW0RBC62k3Df(gbwk63nPiKENRYPv4g1E4(Sx6ASr5OTQZW7aWh9I9KGVrG7AtNJYDxHVrG)S3pXN3sxJnkhTvDg(cGRSOtkEXYZOfVysVwrATb6tYlw9sAh93Ah0UPxFMHVrG7QDSJYDxHVrG7O3IAKZU4l7lwPRXgLJ2QodVdaF0l2tc(gbURnDok3Df(gb(ZE)eFElDn2OC0w1z4laUYM)DiC4ydujjPf7)XZk4ncBxTmCuQ7k8nc8tAyOdRo(zf8NjypkZhL5ppL5U6XWrPURW)Sb8r5UBYTITLtBEVJsC7bUnq2kAmTxIBf8nc8ZclPose)irGgH9OI4ja7NezUsCdzPVvVtmCEgk9qr2Koq(Qnkj6)4JFtBbSQiWG6g5(U6EyWGfYIbyVAeVBmwsNp6Y6Y05xELXS1Z4tp9vdVrjWpavsnhxA9oPMsU2x2oX6MR9Sg)kc4U5AZ41XMh8R6TxDj6kf1KLI506qqtr3VFnrOJf1I3qZV4ktavw9yLLTOtsQztAyNRhwPVbpKH637eRHK0tQNyZyQPkQpaO8gY1WvoCaVY7YNGC2WG)FH6G6IJoOANy9NRdQl(62b1fhDqDaDqvWXQYNzVixpjcY2aDuZ8bnMKNrWBewdMIonFrhL6UcFJa)KMo6Hvh)Sc(ZeShL5JY8NNYCx9y4Ou3v4F2a(OC3n5wX2YPVYohL42dCBGSvl8D7L4wbFJa)SWsYRBrlXrIanc7rfXta2pjYS918TP5xzEfq8mnbPQYJ7lPIN7lPIbV4kR57illPsvXZHLuPAMA3Ax40sQmY0sQuTKR9LTtS0wsftW11LuXsZJ6sQyirTCjvmGqDlPI(yPDEjvmm(wL18vVpLSq3YLuX6kE2(EInJP9LuXqFNwUKkUkNnm4)xOoOU4OdQ2jw)56GQ6A((vLdQkR57rhuDxorow7F)pXohEqQvVo)i)gpg3tsXJzNX3UjoAHFqXLrtYGItC0tV(IKS1RJcNSHMEM)IRZpvgkoTq3)EJzcp8HpdFsrd0OHMtkQ48tPRpdV2NVMeav)vK4jBY(4hdavA0h2)(VLFFiqWZSCL7MaSAeHeiXZxi1lAH8lmHTu8itMFznWUgce3aMS7HH8RCKiT7PHbMf1YtjDuvOEojC1llpYk4hBu6NKcx513mSkNI9vr(gpSZq1dkuv9YTS3iRyu1h4fYaQli4v4qc5b2v6GIYehilxfjREodGdV0i2YUpkyiVkMku6Rzxje1R2KoE3nx7uuB90okq8qdybSxZUA0OXmSkEkuePXKW)iduJFm)O6e0oG6r669p)gPGDTESF6YOiOMJwM8AEgw5YVvmgSF6)M4dVN(afVHeI2aj0)JeEhNuY94rYD(D9p)shn)EEnr92yLDb4SjGk1sG3Oc4f7p)NQ)6yLDxBK7yeVPnkBiibbrBfLsYA43eaKWRpbSknE0LJELQEz4EM4oDD7kAik9m7H)U4Sl5ScHHFfSWSWe1WI7sv2Wd5vt8s0GDyNGgbOM)33mNFEEHctcflkPRwfaJDrzVaTDcXhSmQ4Y3LDrvG30SGbKwUcf3UTmzF3wYoqJGNlAN7n8VbT1)6TyAMbdiH6hm1q(yh)ySdfEyQSVEi7YT8TdZHpPVqClnLYD1Y9hLF2VWzAD2dKGm61fEzpihSnp(P)aT5jCKfz78SXWqCYh8m6eiKH02HzJHDkvgspDiD6OSr2lcEhimH)RtWrh5MaZMN0CIY7w1CkH)fg62Fw61JmnksPV(0Ydk8MrnT4a7Vg0Vr2x6aOEbWvEVyGPNrRuvhn6LvYsX9xbllzQxIcp(OPUhLnxMkIxRxeQ3lfpBftXfoXbQeEREbODDuuTyq41Ze)(HWKi17eEpsPRMIckJLxlfxbCjnkEEvuaCEAghuUOYREptCfYJReMeddWBGRsVtQEdNYDxA62n9QlfUJQCRM27B0vj91KfvoAvuGvViOUA5S5NwqtTxAdhx65jW0HCUMOuCTn2uZol1C1CrslUq7QOQf3frobQY9f6zk3RwChes3BO9(Mgoysnm(MwXPEJGwr05xcOApw5E)u7DnXmEKw6lVFPKTdLpa35Jj00L45nvtuHfsPTITMBTNNRWqr6iZHVMyo8TSlzTN0fzPMTsX9Lzf)a9uNCjRWpEtk(eeZVKVjfTpMNbx8n5vNZPO6vQ4JpEsvkrnn(z)sVukhr0vxmeGHr(1JyFHpK0QxmI3iFPi2tVxz)IUbFsUdeBvZWxUAzJevSoYBtdH3ijc5lJrNYqjNiTxOOBS0gWu3i)YBWl(WtnmWpEvjQ1qxEPiEarv5ss01kEoVBzo5LZf0nU5TIA(3zPCQs2nM8XO4jlIjSP(KOWLvjR2ynQKil0e1QR6mmvETIPOniAdHzHYu62MRro0wk27azISKAGI7BSKd9EHkVuMYzDwrkzsL8SvxfxR4RWehBMt5Feh(ZDhYUWn5Fa6KysqaBb7X)MVY35dqUvDv(58dyLNySFaIFWz6bQSxW1rTwMlfRq(alA3dXy0n3CyFSCNgKPCsoWWn97x2qgg1MgthhDDjV9SfdZ2cn6Nkn2bRRLfOmpMMmAWCfmoIuVghqsBK)RELfzO6SuKlFzwnvhvSyIHqlvAu8AX8fhnSFZYhZE8xyD9zBxZDKekFFou9vWnLi4c)dLtmN9EXU)XCx8ICBnUNKKOS4zIn3ayPhSJHIQ5Rn7WUmKH(fIzxh3W9LdY(G1oO2B2kORG0ksp2i2GKFalJB9xgscynSK0Ylk3eXMEYnU5(XJ5Bwkopo2Jj4qb8SHU7Ntt8JX2lX2xTlCgZEcfUYTsdhHr1OGTfaNQVhsLrQZX9p6RZvbsZYJ5yrY8J)uMry9wwColswRoBEXtUW(sFKl(kvHcfznsVxSjU4GmaFNu)GQI8wFCdLVJw2vX16qh7DWuO10)G9EwfrAp9zsDEGWSpFVTLflUgTOIbCp(PqwnygnCoZjF(24)o1kqc7o3EoznBtVfp7m(o3JL1nIDxg)5c4T9EgpvuFN4Igr8cP4ytOx0SWZlw5EfQHIuB6sue4yg6Iv6UqkJ5mFKZq(ZmMWRnKWE1ijxxJKihGyowRldCSVCR19BH5JNvZNrwmF01xTXjDffPHQMsgROi9mPihzqr6zqrAqsUUgjr28XXADP5ZxU1A(Ov)EcoBlvV15wtv8ykctiFXycfHPJi(Gebfeo)y8P8OwIV06CelHsEM6SzHheXIJPYyNkCVuKfbUQ)rOat4phbGpGfx(2sj3JUw1Cz7Zl9DfLbmQCeFCm5OYIffrkvYtwb0(PHjvesdbLLTQhtrrmoGKaS7eQkwnfQn95Sr1gLXq1WpCbng(tr9NeUtVjKPfzdWbZAzE(MnXQ6brPNtwgc0W9NXdxnXW5ikrXZrzTiUUsytoVq03q8JzJLXwSdyImaTFP2kEQfLTjNtfX3j(drlwmbMOmmViuMYTv5lbILEDUfW7ModeQY3Z9aO39dnfd9bL)aFSCKPyGlAJrpF180UOu3PGN30bMs1cUU31oHsn05nHwhJCElTlkboVjp5TkU5naqnHnV(mm6AuZBW1U(x1tnJD1UqMVtNskg751iIwJxEdDwAz4Y7Oq2vhyEYoWAQ(10xStDZb2DhyU)faz0AY6CkSlBn7aRAEANVcNCGz6R)PAbx37ANqP6aZeAD0bML2ffhyMMjtRCGzaGACGPVQlD1bMrFZQoWQzUBTZbwN(KFm2ZRreT6aZqNLw6aZrHC8TjBOZg)ZEx(QXPW)n())]] )
