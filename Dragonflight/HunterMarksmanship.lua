-- HunterMarksmanship.lua
-- October 2022

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

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
spec:RegisterGear( "tier31", 207216, 207217, 207218, 207219, 207221, 217183, 217185, 217181, 217182, 217184 )




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

spec:RegisterRanges( "aimed_shot", "scatter_shot", "wing_clip", "arcane_shot" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageExpiration = 6,

    potion = "spectral_agility",

    package = "Marksmanship",
} )


local beastMastery = class.specs[ 253 ]

spec:RegisterSetting( "mark_any", false, {
    name = strformat( "%s Any Target", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.hunters_mark.id ) ),
    desc = strformat( "If checked, %s may be recommended for any target rather than only bosses.", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.hunters_mark.id ) ),
    type = "toggle",
    width = "full"
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


spec:RegisterPack( "Marksmanship", 20231224, [[Hekili:T31EZnUns(pltLkASwpJgjA7jZKZwvTBsL9sQ9rQ1zV7)SmSeLeJPi1sszpEkx6Z(1Ddas8KVSDMhNRlx2yrGgnA0O7FDJxxm5IF7IZxWkcV4Femo4OjbbhpAYBpzCWfNxC32WloFlB(1SvW)rcBd8V)7SSRZ3WsYxhTf)4DXPSfinYt3LnhkW3S)Y1ffBZ)(38MvrfR3D1O5PBEtE0MDXSIO0K5zSLf4Fp)nxC(v7IIl(5KlUYjpm59xCoBxX60Slo)8On)WfNVoAXIqEXdZNFX5yXF9KGxp(TF)(l)V3LueM9Y89xIm5(lzl(9D5fBctkgT)x2)l8Yo51tSlR23h)o47)5fl2F5MO88OKv7V8gwwe7Q4qGMjWVhhLxKRxNtG68RSI5R3F5KXJcQ(44V71tE)3JnZ1q1)TSDH5Rtl2F580KfrO8ayHnPzW3wMMTk6gQ9Is2FjuSmOClJwTwTXq6DsROxrgmkTLLP1)HQpoaQ()ITnc6j)uevYOn8Uj0ox(NJ2ecF5CGQ)xOme)VlcdJXgJTvHsV91bOK8httEzHkNSyxgrnw1pQuRtGHlOwWW524OL3PwX40vrZfI4SWnP3esebAD2I74C0(lHEt2Dk074xF04VhPs0QvHzqPyX3KU)YBbvpqiTlUi618kE76qqQ()KghhcelkN46cwmqWWfAeK6w)7TOcji)Zs3qSRq99hq13rxCoPdG69fzrZVg7a4F9pOPtHjOYYIl(lxC(8SiqplIbLJAQr5uVz2Y057Yhjk4(lhaJ3kFy28uq)K(5R2TCPELardlchMpD)LVdMGmhzly(hVmiNCrbmrYlJqumJ9X0SzlZyRW5h5J2TTIsxhfhxsNJq6i)s4h2gNMhDti)Zk0hk5XQLCriRy9S5RzxNX2yuWtulyEbBZ2WfHgL5TQL5wwumOsnJLLLERrb)oJ(zjDdZ2c9Sz5fqnv7(zHlZafo(05bsvGrRVBrglF2vqX0gwErzjeuey44RdZYNrd8HGYOS1pF(DZJdNvWYwfcAdGUaWFVZ74aYPGKmmjCtuimCoD)LFxf)Ff0zrZUajEVQS4gsb2qimzC9J2eRsJzkQptpdMn9HW57kaEgM0RknY3b2IajoVkLDqjtKHwpMTemEqTUFLEPHtGd4ZYNLHAPvus(7eD8RZ2YHaQlCGyst770YASnlCEuEOOolsVfmyC)9LKtylB3w(VUChmnbQXAC8wqmyk5CwEH4VoC)LRMVy0g2h2F5q4F4ETYI2Y77)ukAVsRlHoK(nrN6v4ObQkb)VRdrZJ3gMxqMgH(czIvuz0gj83GX7)kOnLXIJblCPj4)g5gWA3s4)hTbMUlgesGwkdnUYnssTh38kA)xyphS(MDlk)b)ACXIOi7VCxsCyEUQL7i8xbXc2Hu8Fu1Gm8JqVi7wGqJQg(zyHlT1m5iptMvkM9Kmf1KVSg6ts7YW)Aaian()3a)s4y(VMgLNIafkaeAJqpFydVIRbaQj7IrRkSCr9HE4nrP7Yr4ljWyakVp(rWSHxRcN0EIJY1bohjeFH88rMiNNIYaq8YB1rvQgJ4FAa)tQwwHHMJRyZ5RJ2WazuLA3BBpNwPz4wZrQHqF6kqnbuslsZ2mIgL2F5zi(qsLOl9QkMFdIOPKXBRZVAMY4XD4ws5AwuYVhY5O(6tutT)Fs2K2H2sUILhIkIMgX4ASme4li8Y4yHLgS42XEPuLMBIJh4b8xWhzB3gFhrf9zjC1D)(I1NMJdYAaRcJHEgBlrK37Li9y4udQvGFV49G0AAkb(Drxxx)k2QzPl5JQ5eDc0XUvb5udqsboUVKbCqjM4YzFPuKxUaqQrBm6L)deDy0hL4qmkTPVI0TOEVIaqI9a)VI3fInDAm2)Q6Tz8il4(baT6mgyal8guZgc8ba(8beLVsbeQ94e78W7uqksEfWq1MvzOehSmBri4ikmIzR2r(qp00fJSa7V8n7VmWWyc1Mvws0)DWxZmX3gQYYq0yxhwmQyYO1aaxyY3mSECkR8XsEvTdC046khj8C2wb11wbTSTcC1wyjACyYSacVihy)LkX9H2Fen9a(ocoXDZIFg473o2lJjAxZFwTxpPQ2xLMZ7egkscwWedXpgcZJ2qMqL47I4MoxLMUGIQhJTpvyWTkwCi4Fm2FIHaZMBXW))OqkuWUg9yUnlkfSqqwxX6drIWPEoyhEbLRI9xswy2I(neUw42UJtLwX5qoj4KlcJz3XrvcqzyXedNtjlGAzGR(Ns8HqLJbWUIwjFd8xccKZ7pC)gOWLRDfUCj4LQuZj)vIKiWd5Fhpho)fX8KxvYmCu1eazrpeDHq)knci7MigoAIv(iYQYmEMWmcPrgbStJSGMhyBc9VLdZtZUEgl5oH2oj6gfbHEsd)dvrWSagUwt2lZNTHYPfmRFSWpnvV1HSyiq7Ty3h0ME3yPI(QSujwerrr9HzfPyzNHLBQce1)eOInMuXKwpvB2YG2Da1yom6mJ)hZWCIWZmIqenFrEzW8DTUYbtxb57piAyUYr8EDL1Av8BL4sYXFTGad1k2jVOZrZh09wrjzsKxuoWN6tSe5faSuMTikba9SyglphD9olCZwiKXmPviPVROSf5OxDa46D2H2RJiXBJwAzwlrpkMtbf1Jp5cp5dYmVs3gfVaJBaMdS5Q6sRKNSf5puJduCcVCx2DeCM1W4eBvCyLHyDfg7cw6NFOksglrUvMRQnHz(1QlzznbZixHDc6z5BdHFV0g8BinVk1TSBcDP6Yv4w87SSD7sMTfg2blBYoD8caI2YyMA4DnxuzUQQVpD1UI5RXye80DuII2HVtPVE9rSsAAPpBnw2q(YC3EkqIfTudj(6aVjjO0Ml2dqd85RHqlsGqmOX4cWaa5VIBghlqeAjoHbfiomCbMOhbmVtlriAthv0dAnPxWiNwcgzOmkVojm8BSOfuY9WKjg)ks6vW5qZVM0CWHlMe(HIz3gXPJKQMQyLtfJswcqkudjEOhjIpFMBaesPPi4yGp06vHKX8yk21z8yWLd2tPS97kfZw5Vq2oqhPifc1c8QC9Jr74lDdKpJ5PB2aOUUWoQ1dfZPZcxfYruZxidsLCqttu8Wl(9e3CRQO2fZsUMcWKlJkdWxxjYiov)wpEHiOmh(g8Vel1eCEx6l65PWis9THSmaR4cZUIVmU6vfLVEusYjTE4EqkWCIxj70(fNrd66IiUlIjb2XKFt0weVkyIjDJEC51Tcpd9W5TDQRR622PJ21Tqb2RdmFnNIdVR3IwKJyOG8Gg5ror5tJbrqWWvdgkAugFead2k)UK5uuLcotg0fFXdOAqTHwSryLQIlY0ZqZ9dZ0UxFh4HY)CS72Da(VxIwTt9axjBIMQWZ8JzhIm6bHCfflIa9bpYa(RaADvDdp8PUf2bUk7vccdrVKhNwO(3yQDsxUCgyK2iHYEZ3eFcBPgALkI1NeKy2eCUcmHdZzqJzqAyPd7(2eUzWQu14kjyAPR7ixzVPXkEip2BJoOLSRP0N5HVFnyT8KMjauStihlEiZaVF5qmqpIdm64IbelrEGLiVwoRffP)mpUywoe((AcS4(BJhSYJVmTwvUtTKY12Uh2e9CoQnSCSRMuXwJmLls9xGtDtytPHgNuxISn0qGoAveK88L50Wa36EltGDlmF0OoKTqTngi1LQn2iIYnSTzv(rPJz4n7FNJzaZDUzLUNKujxKR2OCUllk2x07MijTImZI5Wc)vEQJjpKLE9KKsDFoqjDooLsMCvcSt2RKE3r42FlooN)7ib4Qmc3NHSRXoVAViN3cajURSnyXygYr3SQPghJSktRtEWA2waZBUft6iZ4(6EKGIHjJwo0uwibXUsiQOEk0BgY3tglyBibG)UbeuByg8pL9Fkb16dHKueKA)Cce24cSVwi76a6GxZwLKca6NZxZabSfKkqOqiVwMC9CAJkuY6Bzrz02DK2Qia8FiyjLXkEP5TTRC9zGvjWaRsqRWQ0UPI1bKiW3egxRSw)WQy74SfUBQXaB9yvCwrxyvCyoU2oFNWQ4Ia93DFNXQydpSwoRffP)mVtSk(BIhdSk1O84ZPWJcwfN0RTyvSxI6hjSk1GCZlwf3gwu7OpCSkneO1dXcvBBJMXQ4XsWJbwLU1X4PzbxzY6xvn)SYKJuY3BywEygL45AxVmZeAW50s2Zmjb7v3qe1XkVvHvIttxmdtKURmw8hkRWsMhcJjS4z4QD6kddp5SZ7vsYBuwijCCbFWhJGnEfjIPtHXSFF3cA)YFrH9IAxxpIR4Y3UoiJeVlVQRQTs(JOvY)0YjgnnRqrOVnL(FRDHf52r0xLAdboFdMBSSqkPUfpFf85q5f1pfQNN4bPKY)HEqiwSkehL8aY6O9GWqTuL3HZkrHRTb7PTBxW6FAyxsTV2Yf0WujAaQu5sXyPAcHBZKSJpPr1Vjkl0S4Gjudc9wN1)2V)sPI7AIRReZ3XvMVszX5Eo4DQLPUJ7I)Le3XSrLnkI(PEPO2vT(G91EYn4dKCcRUJr9Sc82fuFNTR8xLasAwDwBgyRpbjU0rLG6Sh4LCJPKf321QqNQBBCwUaKtetaavfi(xqumpDZvSIzqDxHHipTUn4jVQpVLq9Ie2xae12wE3sOUMk1O5lXUQSkdcCboPrA6tqwOQTvT5ssPFaeXmSyCydVkKsUficePoPqwNi8ef61oUMfrH7zjNv4yxsuIcRLNAMUyRv6C235L5axEEPzcnSBy8ywPQJRDSnSnSzSjaLOAyQHovoXXPh9PooEqUvRmZ35)lLXm)hLN9D)GCHKmDh8d)GOBlprvlA9XZkmc3qTMhtlP4O2JQ1vHlPJqmTfDXDhdFWb3KUyA5UnDF1w(LNUW(ZM8KDkKprccIz)7hyaUGDXeBIBGOezkCzl4N0z(Ki7UPyEM3Ek0f3sLOMUzfFdqtcXJzImTTZzjYdKI7drvxN(9)3Np5yYeP5)OF04AZjIRFHhAdvRTrhQthTnsvHChxPe1ICd(OJWSPd2K7JOwpotr2hDo)GBFCBzwgmVlSnhvQ6KV2NNPjgcyVNNjSNqW)QpM3Q5xXPa)EBA8s79KA(UnBa8EBdDg9zZ7TeByvvRrKb0mxzTRjuz6ieJaW7rGEnTJFxMbm1UmymQiDtkQTN7iNMnxfFG60YEC9jE1Kevg7mQA1h8xLZ8vLbnXNN1eF2L1WUBzo(RCHM)J7eFDbTxe0QnfLXAmtlAjT)PMhMSG89lpHtFV1s8o1A9sFf)qnHT1uXfZI2Q76770rlcfjidCoeezeEWSHFoKZRZttYJO1g9Vttx4Rr6pjNWao8QMXixp6I1i(JuoMhdoppkzUeodD0peNzRTXreSOIBddLlR6InRQwzxAHLPFwLIgN2jEY2RwrmxP3Qv2UQzv2C1IbATOjAl0USuZ7IZDLPsR8rXjplgaqaONMTD3h)ymEclus4MRp6iNVUG6PP0(RCUZaakQHNMiGMQJMwIk(2qu9q72AG2ZaKETmUYudW4JQl5sNkxZ3d8hozDW)g23mlRKnphzcUgquMOAC6M2T4w)odYuoXbZJIyABvMZ436sAJr08tT7jdUu)vkxKfckVgIqGpwkU4LAXOrL4XZaHdWY46)sGrGUneFcEgeKxywJFlk)YWGjZV48FdNjhTzl)cKczSxwuEWYEjg45)zxezGjpfTxZ2bUMX9Qo0LxJXzH33u)nYu7eW(4pKManh95x6yK8LCHLRpj7oqroyYhgws1VZnvv2H2ge1XE3UL00xwnm56gs(HzRnzSNMtn9RMTHRuZAr4G)y7hEeBM3)dgnJVRhI2s(h9EZ(FXHsV4oiOBA8h5MJL5u1GdntHSPaWIAcyp64)kjQB4HTNOMzr1bHDuKNqI3nYcgoQNO8c0D(TveUrsgu)GM1NBfFAN6BheUVdA9J4DJSUKTokq353wryFKmDBipyICEsdFP9cVqeyWbVW9zte(GN543FV2sjm1MY6lPZHUxoNVn4(7DSmoN5zjCgImKB7d3FFntbNE0yFFh6(AunWhvT1r0PQ5OYW7V3Rq1(oYyWb(Uvoo0(k340GtSjEuY03o2rJc02ZXDD6eS84AdnqBWei)qPs3NDAmV5znMpt1yAcfArvcYnaquyF5u0aQMYmr2nCnEqYxMMsd(Yk9LMMWTWPQ5Kuo66XjPYNBfrFqWLQNt7P7C)CAtz)0b33IQ0QgV5uV6Ox2IQ0YgVCkTC2yDUVvkZtk5BKWosazDyf7kF3xY3iHvYfRlbHY3AlF6LCt6o5(SN7ACq5zD1wt(wq4VuSF33HUNyY3iH77qxl57(s(gj8N92j(8M7ACq5zD1wt(sc)w3qL5PO)L64K1ZBVjl6l9NpS0N)Uhb(ZzOfcXthxJGJFkm67JO2bwwNoPN0L94s8gjBFviBjx3xY)Kr4p189dcyWJRUXtkXFIi7Z88Z88NN8CFTy0sUUVK)jJWpZ39JV10TA1Yi1soU7eUlKStOS7oh3jY3iHFsq31ZaKEgiqJK9zbXdGSFs4zRvW2ZCRbh44sKr5hfvtzxww760n8(7FrxjOnlqKAQ6CxtlmF7r6RJwTf(Wa9fpuR)xtNzQt(61toPUk96to1z1g48xp84tMQ1rabynxrfdoOMwU2p2n2A6zbExVvb5MEMB61Rbt3RyS87NQjH80chwhfmKXdhwZIj7rIem29ho1fHQ6zuB5BH0vgXu8pD2yRjr8nZznlE(dAgBZ00qsu)s1hmEOV16(bWMnGr4lu7yV5z7yF9yh7nF1Ah7npBh7rZowjITtEkGB7JOtS4K6cwUQipHeVrY6qrSvrF2sUUVK)jJWFQ57huq5pU6gpPe)jISpZZpZZFEYZ91Irl56(s(Nmc)mF3p(wt3QvN6LwYXDNWDHKEfcUltx54or(gj8tc6UG(TtJEgiqJK9zbXdGSFs4z)z(UPWcDNGNaxb2zZpTpJrbTpJroSI7pZ3okSEgJM4jJr2DMwKXi7k1TuZ0QmgnXvgJSB5A)y3ylJmg5IC9nJrohmDNSGEMXihuOUmgz60T3zmYHJqRmFBo5tLP7wgJ8M43UpJTzA6pJroM10Tmg1w2SbmcFHAhZFMVF2o2JaB9hRDS38vRDmRmF)SDS(YMiInNBC88hNdJ6dCFXBHo9j6Ygr0hEYUcy8iD65vqIn5eJWpOqJQHQMQnTjuGNwQ3r62Q0B0loUvuUzA(GYarnuTrzRZI8us9os3wTLm7fh3kk7LMT(2ibhW0V9shCG(9a2ztQ7EMa9DD6KtU)E3xA91CZt8iDhv819TAI(qX0j99ke5l(H5VUVksA9WC1eEpxBBD6m5jiLNBGSNkymEAoT76zJ2W5DhUfHT2MSpyc7e7j)wA8Lpg4pVkkBroEnySnZAqt7BDebk(OCrx80RbLk2QytiCwFVLNNu)UvUnkEb(6Qm7kWUGJ35LP5BdHFtCvv(TbwgS6gbEtq1uH37d9AX812QRYFURArL8xuYYD5QRTJNV79ESXtdCt0wC6ZnHjPBmN)Q8PUs2EEhxU)x(zsPhj13jVU0XlU(8cuR(IZHHJ5x8pco5y8kXnDzuC5tsv(OYBmOdp7nv394VkA5zspmL32p7)LVz)LpFvl)h(vT8(FX1GLmq9xHxzXNje(kPI6v0LQ8zVqpUaPWQYhNzofEH7ajusssZ3jrv5nP5RqOkoXvMLkSJuQcTIsfL5MrTcYFZzbpZrbhudNCwnCIwkKAP8uve9fB3UlAMbwAM1Khv3eMU1UFL6T69ztg7UOOygmwUHZdoUYUjJz)bFfC7MvRUGWrRU6Wlp9OkK(CKHMaqpnWZOG2vMTnLNgG6S25ptxU8zXDLThLHQB6B39onX2aJiOcq3McYEg9(sgMr0Q8xHMOiJLaWgJJ(OmVCMUaLp8p0RN0(lxLMUyV4rId747W(M8XhcC(8VyrW3P7pqeGguWOpY4ERla)k5v(d5pu6Y3M(C9xqE6DgBBCOYab(W1Go)4)x1)eYtoMKtIXh0OQXbwCC6TIwjFd8xccKZ7pXuNgFQwuDqv66h9at(WUDn6GdGwHm0FreX3Rkzg(lDfPGj6HLV)7uyuYUj(wfrHiQOd4W(cx8YxilHTfFXw3(RNZhPyHFaP8WxOWnejCDbc7lo4gcd2ruWFbFHCQQkTMM4NpBdl7A0kYb5Hf4RSg(OuMD9mwYDODe6n4ncGFd0BO0sYcyuwT6NnEG2R17STZlM(UXdoyvw6UTLKbnoaGFWVo7DJNkEtU(tbJ14l8PrEg)pNH445Q6ZxK3CHKZfBUKW)l4VnAEXztC55PY)qr19qAZuTO81eOgQpfS)(nFdyl9hiBm009FLdv(NfXKjTIO)e1TB7iSMYOCYhbYeGvIsUj9AG6FagosyXK6nNDia4Lb6HCI(e1sfMGk3mCAw98Dt1YwxAYrwvP8z22UHqDaxMLQMU5QjERztO)8z)K1mLVl2psTW7nBaJxnB7MbjVzL4pJ1UyPbhWTOQ8cAxoLR61Z(0aFMfSeaCSMobwu251FoSpfXIQqgc0dqPYhO5s(giqge(lM(PzS8C8Diyw4gstf7kUsQKd6Q9UcJ0UcGU6xQGYF8joOIwUCC8D5lCSJp5OBq2ql5d7uxjevvMwSkYqhnK(7XSloHLDtOMiOBPO6BdCqu9qiw87SSD7sMTfgnzzLSC8cW6YYy8ne0McwDonwSm7wo4UQyZC7OTsakPIJMx(jSvDtMgQ0b2C2PGdR7Vh99LVoJTnjmMlHlaJ(GLYbhGFkkrAgoomeZZdh0ZPbUQPC2drypUZHPwdhoWd2T2k4BF1lvN82pBsW9c8fdD2Tr8kjjr1OMvgiDP2VbWZNMIG1a1WxP9mHY9PUiKmNetVSLZ4V7kCr9035GEatuKMHXyhD9Jb9uFrkDrokEYdjvz6j)(0YN77bUvSCnsgZsUMI(IZ11swFdLnzu(f(SkJVkLUmjkFRn7m7awDyzG)ixD1ghUjUSKcY5gUAf1htFxus5r1FGbU0frHawiLSoOKp7YyQvshD3vC7SMPQx1ChH(7ilgdu)Jzu89cecA7viP5L3jcst7JOr6bVWeOXqdEP6XQxbwI1lE7PAV2T6uqtvSnAtuT4ypQuleVi4A7or1aJRdZ2XN4gvyGPCVl6vVOH1C0X6CB0C(C7l0bmXLq)Sg0hJV1ugXMu7q7bY(J620INno9hNwhUZTluPd(dl)VGa19p6BQ2jLBAikEu2ibFgSbc(AnPjM6B(ZqX3qpO1RO1Y6CCQnpvJYmlhLt52t8yMdS2cE(5kK1jsDvJifgkNHArHinzmqpbZuJ)8Rw)dGn)s(vR3qRrzTjCyUVjl8CpU2pF93F)b2PuWnKqnZJsfvTDcI9cIaU6Kpf9dfgsC4sEQQl5bMtnhwon4tY7nFNgg(Yvk3Kd6gHiOfcsBQqf2DJpO1B9ivjbi6rEk(a0FOdV64twVXqx1Jt)Jiv1ES6BBhxIzwfpDv2A7nU6AGv7PDSZiwg7Ja()LzmkzG5AXDPvvFyc1kKhqGg9vt8JAFwtv0hj6cCy7iNAeHSNM9kGNyRcDaG978udPJDNFSDbWm9mTjYUWc7H(Qiv9eBczR9NqVAT3oBBGC8xbbtgloMwlE8FZxuBPFVB1xaFUBFQ9eU0bs8JT2RV56u0aGKYf)EKh5MFB(steA6FJIsMTKsQogfpVS)P3)(27MU5bD)UZBLFMQqEapodhwnONK2Lb(w6GDfFSVdEABP0NIf8tKe7rBcShs52jOk1GWfC6cBqJEWmC(F6XE4b7avuBFvGn2UrldqegPksZ2iIBCY4HnZFK(4)KmtqBBJRy5H897GUDfUQed3Qcq7KXbWlTHWnT8sPUg3QtE6US5In5aaup(oIk6QV(0d7JpgZhG7(6OrppN1HWWV39wi2BwlOVePtOK8Hecrl9nCZ78X3Y95zXAwHyRpTimpkdhd2RS7xz7R2tSyllDXq1GC8PpQtlB)HM7VLQdPTyVTuNtudU8HYK8PSTMl5fxWMMw448hA7bCzweflMI8GLM3gH7GGR6HiLSlwZggI(oprveZ)VZrhj822CNpzTxNf7ekE4)XX0uESZi2cuI99ecta)v(gZIN4azNuskvaleyeaaCijpKBpm5MjMsKe4b8NGgmN)7ib47hnH0sS)Lv7f58waiXDLTblg3)zOuvDJNHRmuMwN8G1GfTWKClM0X(oZx3JeumNBLCbXUsiQOEkgLkhCLX(d3r3ikzzyg8pL9FwYDMdHKuK2A6Gb5fYuPrD940IxZwLawyIMZ3rEcTuKkPz0EgVCRRLt4okz9TSOmAxOty(aB0GfnLXkEPfTTlv2YLFg)psxUCgGbam5J8KCp(WtcJZmF22Rncx3RP2j2S93AeT)(s2Xgk27LFJJYQDNr45Ys2rgAB8gJWUoD7MzOvxyeUUQKTB46(w3yk9RlcxuRN3weoheDMw9(Dxr4Ga1CvryMY9(Etr4yFWBEH347gsEshVMi619JSZjOnsrV3reoMM0TRiIwYJ91mxGQzUM6EUnl56sSWXDyrRnZ1(lhhN6sEmZ5OSAM58CZ44yTTA0mNDD6MfLwzMZ19IJDdx336gtPBMZf16PzoNdI1FWL6KzoheOgZCMlwzFnZ504TUzUAoZsDYmxVUmCCobTrk61mNJPjDZmxl5XlkG)Vl()(d]] )