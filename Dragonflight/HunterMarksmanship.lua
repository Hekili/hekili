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
    aimed_shot                  = { 79873, 19434 , 1 }, -- A powerful aimed shot that deals 4,769 Physical damage and causes your next 1-2 Arcane Shots or Multi-Shots to deal 75% more damage. Aimed Shot deals 50% bonus damage to targets who are above 70% health. Aimed Shot also fires a Serpent Sting at the primary target.
    alpha_predator              = { 79904, 269737, 1 }, -- Kill Command now has 2 charges, and deals 15% increased damage.
    arctic_bola                 = { 79815, 390231, 2 }, -- Aimed Shot has a chance to fling an Arctic Bola at your target, dealing 0 Frost damage and snaring the target by 20% for 3 sec. The Arctic Bola strikes up to 2 targets.
    barrage                     = { 79914, 120360, 1 }, -- Rapidly fires a spray of shots for 2.6 sec, dealing an average of 2,108 Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond 8 targets.
    beast_master                = { 79926, 378007, 2 }, -- Pet damage increased by 5%.
    binding_shackles            = { 79920, 321468, 1 }, -- Targets rooted by Binding Shot, knocked back by High Explosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal 10% less damage to you for 8 sec after the effect ends.
    binding_shot                = { 79937, 109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within 5 yards for 10 sec, stunning them for 3 sec if they move more than 5 yards from the arrow.
    bombardment                 = { 79889, 378880, 1 }, -- Every 4 Arcane Shots grants you the Bombardment effect, causing your next Multi-Shot to grant Trick Shots, regardless of how many targets were hit.
    born_to_be_wild             = { 79933, 266921, 2 }, -- Reduces the cooldowns of Aspect of the Cheetah, Survival of the Fittest, and Aspect of the Turtle by 7%.
    bulletstorm                 = { 79817, 389019, 1 }, -- Each additional target your Rapid Fire or Aimed Shot ricochets to from Trick Shots increases the damage of Multi-Shot by 7% for 15 sec, stacking up to 10 times. The duration of this effect is not refreshed when gaining a stack.
    bullseye                    = { 79876, 204089, 2 }, -- When your abilities damage a target below 20% health, you gain 1% increased critical strike chance for 6 sec, stacking up to 15 times.
    bursting_shot               = { 79872, 186387, 1 }, -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by 50% for 6 sec, and dealing 83 Physical damage.
    calling_the_shots           = { 79902, 260404, 1 }, -- TODO: Every 50 Focus spent reduces the cooldown of Trueshot by 1.5 sec.
    camouflage                  = { 79934, 199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for 1 min. While camouflaged, you will heal for 2% of maximum health every 1 secs.
    careful_aim                 = { 79879, 260228, 2 }, -- Aimed Shot deals 25% bonus damage to targets who are above 70% health.
    chimaera_shot               = { 79915, 342049, 1 }, -- A two-headed shot that hits your primary target for 1,290 Nature damage and another nearby target for 645 Frost damage.
    concussive_shot             = { 79906, 5116  , 1 }, -- Dazes the target, slowing movement speed by 50% for 6 sec. Steady Shot will increase the duration of Concussive Shot on the target by 3.0 sec.
    counter_shot                = { 79836, 147362, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for 3 sec.
    crack_shot                  = { 79895, 321293, 1 }, -- Arcane Shot and Chimaera Shot Focus cost reduced by 20.
    deadeye                     = { 79892, 321460, 1 }, -- Kill Shot now has 2 charges and has its cooldown reduced by 3.0 sec.
    death_chakram               = { 79916, 375891, 1 }, -- Throw a deadly chakram at your current target that will rapidly deal 502 Physical damage 7 times, bouncing to other targets if they are nearby. Enemies struck by Death Chakram take 10% more damage from you and your pet for 10 sec. Each time the chakram deals damage, its damage is increased by 15% and you generate 3 Focus.
    deathblow                   = { 79883, 378769, 1 }, -- Aimed Shot has a 15% and Rapid Fire has a 25% chance to grant a charge of Kill Shot, and cause your next Kill Shot to be usable on any target regardless of their current health.
    double_tap                  = { 79874, 260402, 1 }, -- Your next Aimed Shot will fire a second time instantly at 100% power without consuming Focus, or your next Rapid Fire will shoot 100% additional shots during its channel.
    eagletalons_true_focus      = { 79901, 389449, 2 }, -- Trueshot lasts an additional 1.5 sec, reduces the Focus cost of Arcane Shot, Chimaera Shot, and Multi-Shot by 12%, and reduces the Focus Cost of Aimed Shot by 12%.
    entrapment                  = { 79977, 393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for 4 sec. Damage taken may break this root.
    explosive_shot              = { 79914, 212431, 1 }, -- Fires an explosive shot at your target. After 3 sec, the shot will explode, dealing 2,993 Fire damage to all enemies within 8 yards. Deals reduced damage beyond 5 targets.
    focused_aim                 = { 79896, 378767, 2 }, -- Aimed Shot and Rapid Fire damage increased by 5%.
    heavy_ammo                  = { 79903, 378910, 1 }, -- Trick Shots now ricochets to 2 fewer targets, but each ricochet deals an additional 10% damage.
    high_explosive_trap         = { 79910, 236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 728 Fire damage and knocking all enemies away. Trap will exist for 1 min.
    hunters_avoidance           = { 79832, 384799, 1 }, -- Damage taken from area of effect attacks reduced by 6%.
    hunters_knowledge           = { 79888, 378766, 2 }, -- Aimed Shot and Rapid Fire critical strike chance increased by 5%.
    hydras_bite                 = { 79911, 260241, 1 }, -- Serpent Sting fires arrows at 2 additional enemies near your target, and its damage over time is increased by 20%.
    improved_kill_command       = { 79932, 378010, 2 }, -- Kill Command damage increased by 5%.
    improved_kill_shot          = { 79930, 343248, 1 }, -- Kill Shot's critical damage is increased by 25%.
    improved_steady_shot        = { 79898, 321018, 1 }, -- Steady Shot now generates 10 Focus.
    improved_tranquilizing_shot = { 79919, 343244, 1 }, -- When Tranquilizing Shot successfully dispels an effect, gain 10 Focus.
    improved_traps              = { 79923, 343247, 2 }, -- The cooldown of Tar Trap, Steel Trap, High Explosive Trap, and Freezing Trap is reduced by 2.5 sec.
    intimidation                = { 79910, 19577 , 1 }, -- Commands your pet to intimidate the target, stunning it for 5 sec.
    keen_eyesight               = { 79922, 378004, 2 }, -- Critical strike chance increased by 2%.
    kill_command                = { 79838, 34026 , 1 }, -- Give the command to kill, causing your pet to savagely deal 1,332 Physical damage to the enemy.
    kill_shot                   = { 79834, 53351 , 1 }, -- You attempt to finish off a wounded target, dealing 3,653 Physical damage. Only usable on enemies with less than 20% health. Kill Shot deals 25% increased critical damage.
    killer_accuracy             = { 79900, 378765, 2 }, -- Kill Shot critical strike chance increased by 10%.
    killer_instinct             = { 79904, 273887, 1 }, -- Kill Command deals 50% increased damage against enemies below 35% health.
    legacy_of_the_windrunners   = { 79899, 190852, 2 }, -- Aimed Shot has a 25% chance to coalesce 3 extra Wind Arrows that also shoot your target for 327 Physical damage. Modifiers to Aimed Shot damage also increase the damage of Wind Arrows.
    lethal_shots                = { 79897, 260393, 1 }, -- Arcane Shot and Multi-Shot have a 30% chance to reduce the cooldown of Rapid Fire by 5.0 sec.
    light_ammo                  = { 79903, 378913, 1 }, -- Trick Shots now causes Aimed Shot and Rapid Fire to ricochet to 2 additional targets.
    lock_and_load               = { 79884, 194595, 1 }, -- Your ranged auto attacks have a 8% chance to trigger Lock and Load, causing your next Aimed Shot to cost no Focus and be instant.
    lone_survivor               = { 79820, 388039, 1 }, -- Reduce the cooldown of Survival of the Fittest by 30 sec, and increase its duration by 2.0 sec.
    lone_wolf                   = { 79871, 155228, 1 }, -- Increases your damage by 10% when you do not have an active pet.
    master_marksman             = { 79913, 260309, 2 }, -- Your melee and ranged special attack critical strikes cause the target to bleed for an additional 7% of the damage dealt over 6 sec.
    misdirection                = { 79924, 34477 , 1 }, -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within 30 sec and lasting for 8 sec.
    multishot                   = { 79840, 257620, 1 }, -- Fires several missiles, hitting your current target and all enemies within 10 yards for 818 Physical damage. Deals reduced damage beyond 5 targets.
    natural_mending             = { 79925, 270581, 2 }, -- TODO: Every 30 Focus you spend reduces the remaining cooldown on Exhilaration by 1.0 sec.
    natures_endurance           = { 79820, 388042, 1 }, -- Survival of the Fittest reduces damage taken by an additional 20%.
    pathfinding                 = { 79918, 378002, 2 }, -- Movement speed increased by 2%.
    poison_injection            = { 79911, 378014, 1 }, -- Serpent Sting's damage applies Latent Poison to the target, stacking up to 10 times. Aimed Shot consumes all stacks of Latent Poison, dealing 263 Nature damage to the target per stack consumed.
    posthaste                   = { 79921, 109215, 2 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by 25% for 4 sec.
    precise_shots               = { 79877, 260240, 2 }, -- Aimed Shot causes your next 1-2 Arcane Shots or Multi-Shots to deal 35% more damage.
    quick_load                  = { 79878, 378771, 1 }, -- When you fall below 40% health, Bursting Shot's cooldown is immediately reset. This can only occur once every 25 sec.
    rapid_fire                  = { 79880, 257044, 1 }, -- Shoot a stream of 7 shots at your target over 1.7 sec, dealing a total of 5,344 Physical damage. Usable while moving. Rapid Fire causes your next Aimed Shot to cast 30% faster. Each shot generates 1 Focus.
    razor_fragments             = { 79831, 384790, 1 }, -- When the Trick Shots effect fades or is consumed, or after gaining Deathblow, your next Kill Shot will deal 50% increased damage, and shred up to 5 targets near your Kill Shot target for 25% of the damage dealt by Kill Shot over 6 sec.
    readiness                   = { 79813, 389865, 1 }, -- Wailing Arrow resets the cooldown of Rapid Fire and generates 2 charges of Aimed Shot.
    rejuvenating_wind           = { 79909, 385539, 2 }, -- Exhilaration heals you for an additional 10.0% of your maximum health over 8 sec.
    salvo                       = { 79830, 384791, 1 }, -- Multi-Shot and Volley now also apply Explosive Shot to up to 2 targets hit. This can only occur once every 45 sec.
    scare_beast                 = { 79927, 1513  , 1 }, -- Scares a beast, causing it to run in fear for up to 20 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time.
    scatter_shot                = { 79937, 213691, 1 }, -- A short-range shot that deals 71 damage, removes all harmful damage over time effects, and incapacitates the target for 4 sec. Any damage caused will remove the effect. Turns off your attack when used.
    sentinel_owl                = { 79819, 388045, 1 }, -- Call forth a Sentinel Owl to the target location, granting you unhindered vision. Your attacks ignore line of sight against any target in this area. Every 90 Focus spent grants you 1 sec of the Sentinel Owl when cast, up to a maximum of 12 sec. The Sentinel Owl can only be summoned when it will last at least 5 sec.
    sentinels_perception        = { 79818, 388056, 1 }, -- Sentinel Owl now also grants unhindered vision to party members while active.
    sentinels_protection        = { 79818, 388057, 1 }, -- While the Sentinel Owl is active, your party gains 5% Leech.
    serpent_sting               = { 79905, 271788, 1 }, -- Fire a shot that poisons your target, causing them to take 209 Nature damage instantly and an additional 1,456 Nature damage over 18 sec. Serpent Sting's damage applies Latent Poison to the target, stacking up to 10 times. Aimed Shot consumes all stacks of Latent Poison, dealing 263 Nature damage to the target per stack consumed.
    serpentstalkers_trickery    = { 79881, 378888, 1 }, -- Aimed Shot also fires a Serpent Sting at the primary target.
    serrated_shots              = { 79814, 389882, 2 }, -- Serpent Sting and Bleed damage increased by 10%. This value is increased to 20% against targets below 30% health.
    sharpshooter                = { 79887, 378907, 2 }, -- Critical strike damage increased by 2%.
    stampede                    = { 79916, 201430, 1 }, -- Summon a herd of stampeding animals from the wilds around you that deal 1,686 Physical damage to your enemies over 12 sec. Enemies struck by the stampede are snared by 30%, and you have 10% increased critical strike chance against them for 5 sec.
    steady_focus                = { 79891, 193533, 2 }, -- Using Steady Shot twice in a row increases your Haste by 7% for 15 sec.
    steel_trap                  = { 79908, 162488, 1 }, -- Hurls a Steel Trap to the target location that snaps shut on the first enemy that approaches, immobilizing them for 20 sec and causing them to bleed for 2,942 damage over 20 sec. Damage other than Steel Trap may break the immobilization effect. Trap will exist for 1 min. Limit 1.
    streamline                  = { 79893, 260367, 2 }, -- Rapid Fire's damage is increased by 7%, and Rapid Fire also causes your next Aimed Shot to cast 15% faster.
    surging_shots               = { 79897, 391559, 1 }, -- Rapid Fire deals 35% additional damage, and Aimed Shot has a 15% chance to reset the cooldown of Rapid Fire.
    survival_of_the_fittest     = { 79821, 264735, 1 }, -- Reduces all damage you and your pet take by 20% for 8 sec.
    tar_trap                    = { 79928, 187698, 1 }, -- Hurls a tar trap to the target location that creates a 8 yd radius pool of tar around itself for 30 sec when the first enemy approaches. All enemies have 50% reduced movement speed while in the area of effect. Trap will exist for 1 min.
    target_practice             = { 79886, 321287, 1 }, -- Arcane Shot and Multi-Shot damage increased by 25%.
    trailblazer                 = { 79931, 199921, 2 }, -- Your movement speed is increased by 15% anytime you have not attacked for 3 seconds.
    tranquilizing_shot          = { 79907, 19801 , 1 }, -- Removes 1 Enrage and 1 Magic effect from an enemy target. Successfully dispelling an effect generates 10 Focus.
    trick_shots                 = { 79875, 257621, 1 }, -- When Multi-Shot hits 3 or more targets, your next Aimed Shot or Rapid Fire will ricochet and hit up to 5 additional targets for 55% of normal damage.
    trueshot                    = { 79882, 288613, 1 }, -- Reduces the cooldown of your Aimed Shot and Rapid Fire by 70%, and causes Aimed Shot to cast 50% faster for 18 sec. While Trueshot is active, you generate 50% additional Focus. Every 50 Focus spent reduces the cooldown of Trueshot by 1.5 sec.
    unerring_vision             = { 79902, 386878, 1 }, -- While Trueshot is active you gain 1% critical strike chance and 2% increased critical damage dealt every 1 sec, stacking up to 10 times.
    volley                      = { 79890, 260243, 1 }, -- Rain a volley of arrows down over 6 sec, dealing up to 4,669 Physical damage to any enemy in the area, and gain the effects of Trick Shots for as long as Volley is active.
    wailing_arrow               = { 79885, 392060, 1 }, -- Fire an enchanted arrow, dealing 4,407 Shadow damage to your target and an additional 1,786 Shadow damage to all enemies within 8 yds of your target. Non-Player targets struck by a Wailing Arrow are silenced for 3 sec.
    wilderness_medicine         = { 79936, 343242, 2 }, -- Mend Pet heals for an additional 25% of your pet's health over its duration, and has a 25% chance to dispel a magic effect each time it heals your pet.
    windrunners_barrage         = { 79813, 389866, 1 }, -- Wailing Arrow fires off 5 Wind Arrows at your primary target, and 10 Wind Arrows split among any secondary targets hit.
    windrunners_guidance        = { 79894, 378905, 1 }, -- Each Wind Arrow fired has a 3% chance to grant you 10.0 sec of Trueshot.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting        = 653 , -- (356719) Stings the target, dealing 1,906 Nature damage and initiating a series of venoms. Each lasts 3 sec and applies the next effect after the previous one ends.  Scorpid Venom: 90% reduced movement speed.  Spider Venom: Silenced.  Viper Venom: 20% reduced damage and healing.
    consecutive_concussion = 5440, -- (357018) Concussive Shot slows movement by an additional 20%. Using Steady Shot 3 times on a concussed enemy stuns them for 4 sec.
    diamond_ice            = 5533, -- (203340) Victims of Freezing Trap can no longer be damaged or healed. Freezing Trap is now undispellable, but has a 5 sec duration.
    dragonscale_armor      = 649 , -- (202589) Magical damage over time effects deal 20% less damage to you.
    hunting_pack           = 3729, -- (203235) Aspect of the Cheetah has 50% reduced cooldown and grants its effects to allies within 15 yds.
    interlope              = 5531, -- (248518) The next hostile spell cast on the target will cause hostile spells for the next 3 sec. to be redirected to your pet. Your pet must be within 10 yards of the target for spells to be redirected.
    rangers_finesse        = 659 , -- (248443) Casting Aimed Shot reduces the remaining cooldown of Aspect of the Turtle, and Exhilaration by 5 sec.
    roar_of_sacrifice      = 3614, -- (53480) Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but 20% of all damage taken by that target is also taken by the pet. Lasts 12 sec.
    sniper_shot            = 660 , -- (203155) Take a sniper's stance, firing a well-aimed shot dealing 20% of the target's maximum health in Physical damage and increases the range of all shots by 40% for 6 sec.
    survival_tactics       = 651 , -- (202746) Feign Death dispels all harmful magical effects, and reduces damage taken by 90% for 1.5 sec.
    tranquilizing_darts    = 5419, -- (356015) Interrupting or removing effects with Tranquilizing Shot and Counter Shot releases 8 darts at nearby enemies, each reducing the duration of a beneficial Magic effect by 4 sec.
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
        duration = 3,
        max_stack = 1
    },
    -- Talent: Your next Kill Shot can be used on any target, regardless of their current health.
    -- https://wowhead.com/beta/spell=378770
    deathblow = {
        id = 378770,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Your next Aimed Shot will fire a second time instantly at $s4% power and consume no Focus, or your next Rapid Fire will shoot $s3% additional shots during its channel.
    -- https://wowhead.com/beta/spell=260402
    double_tap = {
        id = 260402,
        duration = 15,
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
    -- Can always be seen and tracked by the Hunter.
    -- https://wowhead.com/beta/spell=257284
    hunters_mark = {
        id = 257284,
        duration = 3600,
        type = "Magic",
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
    lethal_shots = {
        id = 260393,
        duration = 3600,
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
            return ( 2 * haste ) / ( buff.double_tap.up and 14 or 7 )
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
    salvo = { -- ICD.
        id = 384791,
        duration = 45,
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
        duration = function () return ( 15 + ( legendary.eagletalons_true_focus.enabled and 3 or 0 ) + ( 1.5 * talent.eagletalons_true_focus.rank ) ) * ( 1 + ( conduit.sharpshooters_focus.mod * 0.01 ) ) end,
        max_stack = 1,
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
            elseif spellID == 378880 then
                bombardment_arcane_shots = 0
            end
        elseif subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 185358 and state.talent.bombardment.enabled then
                bombardment_arcane_shots = ( bombardment_arcane_shots + 1 ) % 4
            elseif spellID == 56641 and state.talent.steady_focus.enabled then
                steady_focus_casts = ( steady_focus_casts + 1 ) % 2
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
end )

spec:RegisterHook( "runHandler", function( token )
    if talent.steady_focus.enabled then
        if token == "steady_shot" then
            steady_focus_count = steady_focus_count + 1

            if steady_focus_count == 2 then
                applyBuff( "steady_focus" )
                steady_focus_count = 0
            end
        else
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
        cooldown = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) end,
        recharge = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) end,
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
            removeBuff( "double_tap" )
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

    -- Talent: Your next Aimed Shot will fire a second time instantly at $s4% power without consuming Focus, or your next Rapid Fire will shoot $s3% additional shots during its channel.
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
    },


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

            if talent.trick_shots.enabled and active_enemies > 2 then applyBuff( "trick_shots" ) end
            if talent.calling_the_shots.enabled then cooldown.rapid_fire.expires = max( 0, cooldown.rapid_fire.expires - 2.5 ) end
            if talent.salvo.enabled and debuff.salvo.down then
                applyDebuff( "target", "explosive_shot" )
                applyDebuff( "player", "salvo" )
            end
        end,
    },

    -- Talent: Shoot a stream of $s1 shots at your target over $d, dealing a total of ${$m1*$257045sw1} Physical damage.  Usable while moving.$?s260367[    Rapid Fire causes your next Aimed Shot to cast $342076s1% faster.][]    |cFFFFFFFFEach shot generates $263585s1 Focus.|r
    rapid_fire = {
        id = 257044,
        cast = function () return ( 2 * haste ) end,
        channeled = true,
        cooldown = function() return 20 * ( buff.trueshot.up and 0.3 or 1 ) end,
        gcd = "spell",
        school = "physical",

        talent = "rapid_fire",
        startsCombat = true,

        start = function ()
            removeBuff( "brutal_projectiles" )
            applyBuff( "rapid_fire" )
            if talent.bulletstorm.enabled and buff.trick_shots.up then
                addStack( "bulletstorm", nil, min( 8 - 2 * talent.heavy_ammo.rank + 2 * talent.light_ammo.rank, true_active_enemies ) )
            end
            if talent.streamline.enabled then applyBuff( "streamline" ) end
        end,

        finish = function ()
            removeBuff( "double_tap" )
            if buff.volley.down then
                removeBuff( "trick_shots" )
                if talent.razor_fragments.enabled then applyBuff( "razor_fragments" ) end
            end
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
            if talent.salvo.enabled and debuff.salvo.down then
                applyDebuff( "target", "explosive_shot" )
                applyDebuff( "player", "salvo" )
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
    name = "Prevent Hardcasts of |T135130:0|t Aimed Shot During Movement",
    desc = "If checked, the addon will not recommend |T135130:0|t Aimed Shot if it has a cast time and you are moving.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "eagletalon_swap", false, {
    name = "Use |T132329:0|t Trueshot with Eagletalon's True Focus Runeforge",
    desc = "If checked, the default priority includes usage of |T132329:0|t Trueshot pre-pull, assuming you will successfully swap " ..
        "your legendary on your own.  The addon will not tell you to swap your gear.",
    type = "toggle",
    width = "full",
} )


spec:RegisterPack( "Marksmanship", 20230105, [[Hekili:T3ZFZTTnY(zPZnpfRZUYskXjTDS8mVEDUBAN712PU379Fscwc2IxOivjPIJZ4rF2F7cascaUGeKsQ1PNMRxseb4IDxSy)fwcmD00FD6Tlzz8P)44HJF9WrdVAWO3C1Rh91tVn7Pn8P3UHT49ShG)reBn8N)pSK3NUMfLUkyd24tHXSLiqsJ3MSa6WFz38vzzBs)MlV8HGSvBVBWI41xMgSEBillioArc7(m83lUC6T3Tnim77JMEhjsm8RMElBB2Q4KP3EBW6)20BxfSCjx2DE6IP3o92WG0SuC8Zscw8(0vXIF9Jc6IhXUlKVC63o92fjbz8Kag0pwipkBqAgNT8Pz3hVyB6avh3nV3U56nmBr82OmXJVB793B(sj81SGO0DZVE3CerxGuhWhK9bXKPzab5ereqmH9P4Kz3NWEynGvPd2UPesVpimSaoV2jCwehhUm(XiawBcwo7(GeUbU9WILdwZ(4U5p)8U5FXU5fmGeoBDyqepN8lh5LXBHhmlJTbh63Cyg6fSzi8)aV7yYviMK3e)JBcJtb4j5rAyi0Z3Q3ZLCw2QzlwXEFcBTvhFNEhtZyR3WxYT6ZxP3NhzbaQ(Wmwss8JwD8RT4ufWLNSbO0zPzWBQZat43NWtxHVGqktXrw90Yew6S7GUziBQXZKqeq4W3ZtsNjK(5jpvYbx80cbJl5boSKawqa43OHoNkLtnZ4r81bCy27MDZFxjbChqTOsaegJ05gFiomK)KfBy0y9UKLSLtmdnYTeTyLHGIetTAl1UzYU58pYxSndiTG1sM2zLCLTjpGZnY3QGZHIBcywknbl00z4vfb3nVFjjukElWC7fe5DJby0sL0yf2pHkOgMdZjU2ZoeVXMe(IGuU6DWLPACI8jfbFaF69BbLnWBScXyfWUgx0MMP(15ARN7lypOo4KGnsI)VhNSB(TgK0Rau8xve1fiVgzgWFVcGwy8J8u4hsAbM0kEz4FGltgSB()aKgtyHHpTBECe(Ni2SBEW9W)h(7hJ3gcmjGpZqLkpcwBuJhacbrVB(3fh9kORXFGN8iY)3n)NLSfvx2nFBuipvGOsocaB8PaBbjO)BCkv23YbKHncurYJaGgiejUApfj(8AAokUnt1RcEyLyU(FcM4X53Fooinocn1c(wats3YWb(b5SnisSne1aXsvVpqHFiiEl8tXcub)(ThaLhoxF)o)bUsncXmHQfHVcc1PlIrEaWELJ6GsrJbYM6jBsxlmm18Ms0CXQG1mGhv4uWOVYFmTuYGwYjxcr00DGyciKMfNSEGywA3CG5nAOqKOnuvjYd()LfuG4(APSMLmoSDUriCnli6FZLyuxnGAi2)tc9pBr9g3Xs5OGOTclPeldyoGFBCyvsquPYjPoRxLlslvNjDzg(f0iBZMWNeqXCvIqCFSB72MlZXjzdxr5HaLjDEASBFI7W0PHZPJD7LBhaTHKY4gDtGK0VJ9WS47LZQPc48gth9kDs3WTKmCE)EgGbfrruS6dJfGNq5TPL)oSOFdIRj4t5UIy1BBkkEdk3RXa(adOpOv8FfULR5NDb1MG4FUDaqQoHbkW4FaLSzlxc((8rmUiToOe7Xf2P8N4MohDpOHoBwPIsCYYEexUnre)2Sh2kSxEUTjM8oSB(L7Mp2szIyml1Ky(CWwZmvB91r5KGO3ZZgKnAWkWByyX3m89KqwRXYOq0iGxpSU(jyEKJ146gRXEowJPglShnonz3bLvKZQ2sj7(8QnIQEaBhJVIEyXMb8(TdDIyQX1(X6u9OY3Mi4HrkbG4uj5zjIPqoBVl(ooScBTq5AUxEbsLQpehdcRsxuYIvQIZ9zd8H4xamfmV)bHQZyaCRd(KI)KXEpIuBscIbDhc9U47dXZiHEkOHEjAtd0zl09SbTOOm6i1QhgNRFx64PWPYL8q2tsFlbNCyHceg6s(mdGv)uUxIWlhcU8QgL01WVuaivspslkiBxk3XV)EW(vHmvk4uflcWYhxXJqSxyQ4BvRGUOazK(wlCtwrHOXfXtfZa5Kj6DNyjx6aH(MzYS7KVyEMqSLk4)cTHafmt(JzyoyKzIrbMfltlcxVTVBobxefVxHRcYtV2oVc6E)uyv3lCinRi1aEn6G8(ypbTwAQewBqNWIxFhR0Ed5iwsvGOiF2JXH3xLMs3UEnmMB4KzEchPC38NE7OHtDKKfBZts8MfcRgGOgMTz7N(e057I)OwuoenwJSJEqrgl))zjkAf2fUgogxDGsUzpgRT2mp4Th5OjlJWbflufHe()kYrHeo6V(GMfOSnFkt3HPXtI3CmQzJybq9sqvZlw1uuwYenZdfXIfsFDOz33MjTsvYVnzZOUyKfZs4c1LcLpgZrOkmZaXLC9l0Iuwb5vjC1C564eUFZgLShhteeXonbxukwJvOsHyjwZoFL)Gbwkhn5L3g8qelu4FplR0)PufttICsYw5saYYepMHPLq(AO5iaSbjYOAWUK(u0cHfqt7cit2q1n2Vs122l(BMmTZxq90NWIIgrkFQGuRh)LchA8KQeH85hopLfUCyro)kI)S1Y07lmrk8Sa(zqyvQ7Xa0C9D8Y5oFj3MMUK4gHUYMj1QETMJXv8810L2U70BPpNxVJ0Z6YoydIYemz9QLn4(vM46v61eEoPj8SFPw3UZVujH()y4y142UyPtAwc4Wm6wScu6RnKAakwDbEj)9rILrl4rlfwwY9u)BmxfjTdSKTw4xR6zxiDohhlOryfFsg(VlaVR2f29qwITdWc8D2Oz50aLD82T4CuDloPfL6s0V0IAKZX2GGwuBStrTrUe1g7suJepN0eEsS4S98lRfN)PNJ1NsEESH8STRIglM)xPO3t0rHwz1RkQ0aLrsXYxCPUkCuvmOyyT4tLbjluruOyOCDr5(6icVomwe2CzO6r70cKfuB83Hbmv(CeaswOe)EKdX8Nur9rGC0FQymapAILg21tcqiZuhciaTITzdpkTcssKdaxKNGrXivoQa2DkwLGsbQPV0FrlnEeKrq098e4)kOFw0t2tHcUOqzBgONfP1SCspmo7lzpefNMfSqMDeL)niuItwI4ArAesfBwtbQVHfKi0Rkc(kHNUnmtBUs2B5yBSfO1VATWN7sVAR0uvv1EKTUsnkDDiOrWY0Iv)c4YuJwNgTAjHBCo6F5U5JUQzaaD7kHElhGPNZwoF383muGbwPZtXwRW4gxHXvlM5rx6oYJB)34AZuRXqGD39yCyfbCztYIlx74EEtWJCwRFXChnljFvHBIfzPU7qJgwLCddmPDgZnmRo0XY78WVls5Vxo0Fqu147yqYyBCqu9ZG)1qo3pi0g4)BiMdZCf5J03)l1tisHQvFgtAsWpgvD6Rh7IwO2SOUzsOQMnp0huZkGMIyVwsOvMeOaq31Q2AtcvTLwlM5rx6oYtAsW9qCimj4RiGRCi0vtcKWZxtcv370dKjHAmq60KqZjF5GysObht3hvn(ognBsWHYGdKjH2rB2MeujFpTHD2QP6X(Sows2QT(UANKrJ1tmBBN07D6v9jvLCN3wz5VuFTD4x1QywOoU22mVRIy)RYPs(OfMrv9WTS6RjOaTnA0A3feBC03jAE38FflWsrK4)cwyEyK(yOTyyVyyPHC1MwLxZUY8pGBZF0aRIQSuo1JkuVUssxtrrnLBdcf)lHdvvAmsQU0zTwuU32oQJd1EnxMQbSVeBH2iD9P(JMQvCtkkQdFrdrYOY6qn2xxb7Bx5G1UPHJQz)sLfdFrgCjlKDB1w59wRGrnfK))KPFHsk9clbCnz7bukepC1YUGuCxIEA69n3GZsV1vvWFgrz7N3PYQ2ZAN2scEqybrVYSHL3jXR3n)BXsFiz5Arv7uwXpQCZP81y7Mlu79FoOULf(Hy5lKV5(Qx6oUifKGjvvcUkENGSbvuhFx5WBujVzvQB2EUwqjSlQy8iwvvZQ8X6wDi3dBbZ1NkM4a(LfCwd1q(zTSmYl0MEUrjLRR5uHHgLYSx1trPVm2Zq6E(uPm5DOg84)Xl8trQQwj)nxE0)ueYRrSQfWrZJnUw6P4TysSrtX)n18JS9lqUoIopejlzJvICZBxX(5LjYcwKED4Cy)cj(pmz1pp(8lOCz2eX)fPpQL1A0Fxwy4wFmpjBXLnOS2JRcqtLkFBfRXSuH3uKd1hFGj3)Vklwi13(bLzEthdA8dVG0p)Q(G42BM6GJi6JfXRxdl3fHM0W3ha9x6rhkn)kFbk18rfCyhzwcOvH7ZxCqDmUQFwaV203u3FwaynTwBGS1eJn40ujkagK5jVhdHJOoTCrg5CUI4zSRVjb3mVq0RdvERgQeghdI3BtEQnHUEuqfw0cqhfO)zgw9SurbF0rNVUeBWv8cMdvXF4NKwic)0z)7TlfFz3urfxhf1R0GMarc3MwsQs17dwXzHzRgSb3D3Rls6ttP7rJPVjw83zsbCW3Gu8N5Fd(Jq9vjO3nPQ6Lly9M4KmvO5VkROsMFfQM(32cmTL42hJ6tzBZIxd2BqFuwXIEGNoy3p8pfXQp6Ba3lIJGHt08RiuJ)kPV7unLRHh6YzJ(y)cO(AxqnpyOkW0okjBi(Mdoe)AAiQ91EBbsIVdCpHPRiaSX5gcuWE0g5InRhSQ9yqfiR3aU7C7rUMapsSghZe2FpIwdJRpxrFb)bNA29deR1vFtCTBHUJP08p7llm0(ltRXf4QKrBMd9cGsNID)bQDcUjamrxoIaVDGf0xwpqLDO94RxaUrqoU(jTkn7fEwDJQjaCxN06gWBhyP4TeDO94Rxa2fiJ3WL7mxQSUUEfLNwaa6D2xqNwCObhRXF(zdhuUPkKn)Qtp3YJlvJ)xJF(zPRsgFPPtmFwXxzAFeHO1p88Z1Se8Mxp0v7a5Ba1XUGAvzetOApR0)5NDYuRMb)EN56Re98Q5S)6Xxvf4br382HedkaBh7pXnJW(BM6IBgbtiGpO9mMEHbSFUy4lozOlpjd9zJmuHMQ3s7Hrwzc3SCYiR6NeAdE(u89z2oFFCeKtXhVPfEv5J60wnVdFzLBHGfWm3xbBiD1rj8lhZeTc)i5)Phgg)EsE)(gkHdM5(elKl2YEh3Mt(D3XvxHcI7JMn003YnFbuRek)JjwshdNr6xTgdYDPOcGDS6F)bStz2oUUJuzGYexlt4ufMPrqi52kFfDqiAnxVgHIGL2JWrRht7y4sUbAHBc5w4jGmvFoQGVratuZGeS5oJ3Df8ncyTctKIrO1MV4PtWnQ9G7fp214KYjzvVbVha(KwS9c8nc4Uo15jE3vW3iGFXRN4Ln214KYjzvVbFbGR4uRHwS8x0HwmTMnWwxaDV0IvpM2r9TUbA34RhzW3iG7QCSN4DxbFJaUJAlQbp7IUSpBXUgNuojR6n49aWN0ITxGVra31PopX7Uc(gb8lE9eVSXUgNuojR6n4laCLKlEiu44cOAysl2P)JkWBeSDvYWtSURGVraVxMHoS84JkWpsG9eoFcNFzIZDvJHNyDxb)rdWNW7UH3gYwEvMAEIXThWTbKTYnM2JXTc8nc4JIxsD0r8toc0iypXi2dW(hcoxPczDS2Q3zeNWuApu9AAhrs1w1F9F(5VOTaSkkia1n6RDT1WGLxRdbWE1GE3qosF5ORQ7L(YRUM816r(0ZFZWBmkpqGLuZPytVZQzKRTX2Hw3mzSZ6XubUBMqdV9D6HO9Rn4qogHZRdcw84(9RPytDWrgpKUHRPaujLjglxfAR2mMMfNjdRSSqwyP97DMZQRDVwe2mmTyf1xlVJhkOAYAFDpWZgS7)zQUPlpPBQDO1VV6MU8pT6MU8KUPdOUPcpRE3XWTyxaDuZEbs2LJiWBeSeIIEfLONyDxbFJaEVcc9WYJpQa)ib2t48jC(Ljo3vngEI1Df8hnaFcV7gEBiB51xrUNyC7bCBazRs3D7X4wb(gb8rXlPXDRgjo5iqJG9eJypa7Fi4S7m92u8v0j)ymvasvXh)ZMYy)ZMcHwCRujsNnLQONhztP6l1U0w4v2ugrLnLQJCTn2o0YkBkuGRRztPPPhI2Bz2uiGqDztX2mANZMcHPTkz61E5Kos3YSP4mpNTFryZW0D2uiw20YSP4lE2GD)pt1nD5jDtTdT(9v30L)Pv3uLm9Es3u3Xt0ZQD)W3l(Q(rhQEB(j)kE6cNMHF0(4nvF89b4LPQSP0bfhclNp5YYl5(lcUFs(PcuXbOYUFG6LkpS8Vq)AWFYOH09h5Ebz81xG3IMtiUE739d)f5zOn73VRREAuT8eZf5hMNHox)6YZnj5bCH9PSZ1J7tdwJJQ4Qq(MX4kIQhKdM8Lxe3R800N2r9ln1zW26z2(KXOuScSte3pg8ebSkEkmezjSOFBlWg)u(XOIG7ODzjxEJhiUzqFiogiCuWus4BrAl)WGFaEJrGxyeIJpjmueOJbFIjx8Gx(jPL3CYYBXZ8lo1uZR3uXn1WMqU2ebEyFJxtYY)v93VPbIduELYr8GUVCEGfgg)OAusxZWlnDbasL0J8UAbpfBrntvVDzZp)6FCfpcXEH4W3Qo7TUOazKhb)cbmffwC5Kk0uLtM4H7U4W6stgaMwY1DjxBBENxCH46BEsHARoF6KDGovY2Jt2oxhkze661p9WSTKQdsxNizeBuOoihBdY)KDEKPlCHNE1ZK)CgAqtkKTyzAZDkFvqZ9mLuvFPc5SYt5SMbwwXX4mLEqn9CdaQaGs55xo2FcoYOxx5vkoNXfVYwZd76NFMA5wPye1q8w7HW88d)Onmfhm4hOr4RThaRJn8QddcE7xsEoEtHs9otQPq7iehTSzD8HF94HoC17T6Z)Pe2njCbO3zvVV26jqdQ7IHRVsPHRYD0wVVWMA6BHlfxcBvXr11Pwt8pz31Vx1UW4oizYiecA3VA9(IgosV614WzEZPjCj4WD9NznwA(9c0XzL6HRCBOD9dlwQ7sxoW770OhPc1kkRbDYJg6splQ0IqBDoAwvfmghMpJQqOBYOAHEFBXP8BMmBEO(LrMvBn5L8iR(l9MumN3XBkmlaworQVAu)K7tT8Y46cRxLPzlWMl)IavlwpDxLeeXlOl3llkO46iRqfG5L9v(6uZl6REvT5RFsdQuJvCHE1Zm4kbl50vj1X8QKYAwwl4xc92nPQ(mP1XQ3Oup)8zvnUx9EKc1zEErYe6xgfGXrMiri39vlkZQEZqDJ(9sufXX(LIy)HEjq1QPHp74YcM8b6cRQ9Up52vjDK(Vo2PLGMSr1Ohk6xVuE9cgZefVH9D)em5IKZn4f705Y33((EYwUQ8sF6acvJlbkVOpTznDhIldDYVz2w5x8x5yCkC6TaZtyFkoz29jmridIBzl6x10BWo4m4HbUlyQCH3IHW2PzA8G2tnRPjBN8mA2yXIlq0M4fueO2n5tJHq4yybNxGPyoHxMVZXBK7vczJ5Y7oA20XsN6rNyOi9SU7aA)JLZt)dPjTqrg1X)uMAAl14M5yw3B2bOZ4n5YZ(6U1ahZc7P)n(oT50aTx2NlSnFoS8U)lpxuAbh9pko2bBjOdqrBGwhA5rezBETxJwxTCF6634ahQgrMD0x5oew1eVmaoGrcZuzXjRhitd(OH9Bg)eYJ)KyPVydvUJLYLPnXuxHuuIHBIamojYc8Qi0dH6IxLlRj1KKgVnzbxU9dSnBcFsaftXxxYHDXiI9DfwxTK4F(XC75HhS9MLc6kqALhC2KUUNCyU3GirzHIjwmzm5EVKQ2vsPWTupUkLfyMhepMLXZFnuD)sEAqctK2gSl42TlKNqKRCZUqlmMcfIS(FU9gtvwknQnLQU8Wyreczunkr(ub9upskn)Pr4EJPYURqvBLGYCfHifBn62RAh7eB0j8ZGWQO8Jb4UhEhVKR7ln0rgTqzAn7)NOD7nWvG15v(WU8nYuhTKC0ccdmJ99rckybpAPqFr(E2(nMeqQ4ElDjBTyhovp7c520IJf0iGzjz4)Ua8UAx4YdYVt9HJKvPMLu8fRDcSmpTzKB6y726WIkfkR6wrM3MXlMBev)fYFgzhNq0XE1GjtQbt0RiipP6Ykf6ZxQUFleFg7u8zKdXhB(vB2m7kmscsZ4fRWihtXihrWihtWijWKj1Gj6IpEs1LIpF(s1YGd(xPOJ7MARZLMQOXuLi6aLnbHktu9QQyquvacgQf(uzjQiulRGyjO0d6teqxOi1ZSYcLjANwzKma3XLq0Ok(Ceasdws87ro79OQvlv2bYr)PIXaSkhlTJPxcoHmt927MF2kWdsEuAfKKOcCCrEcgfJ0GKcy3PyvckfOM(shBSSYqqgbr3ZtG)RG(zrpzpfk4IcdCGdWlZ3JgbPhgN9LShIap6cwiRnjL5CekXjlrCTOiEsfX5vG6BybjcBzY8TYtbpi1MRK9wn2ukNYRLV0lq0inx(ugbTJvA(vqZuFE7vRfg)lqA)pkmiw3P)Xb44GWGOoDAS6OR(oTRkK9Q4OPogmQoW11w7qkZsJMcADSYOByEHsXDRQlAcautzrBx4vDTQOj0KB)bBuJPQ2vs0D6SVGCrxJq0z9qtSoPLLdTNizB0xnwxFvt0eT(fQI0MSwY9uFL)FqhKsqodBWnU1S(Q99RMWl9vuFmhvh46ARDiLP(kkO1r9vnmVqfNsR0xraGA0xzx7PDvFfPwyt9v1ezw70x1PVGdYfDncrN6RiwN0s9vEIKtVnDdFX0FC8vVzAg8)M())d]] )
