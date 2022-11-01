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
    -- Heals $w1% of the pet's health every $t1 sec.$?s343242[  Each time Mend Pet heals your pet, you have a $343242s2% chance to dispel a harmful magic effect from your pet.][]
    -- https://wowhead.com/beta/spell=136
    mend_pet = {
        id = 136,
        duration = 10,
        type = "Magic",
        max_stack = 1
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
local bombardment_arcane_shots = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

    if sourceGUID == state.GUID then
        if ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
            if spellID == 193534 then -- Steady Aim.
                steady_focus_applied = GetTime()
            elseif spellID == 378880 then
                bombardment_arcane_shots = 0
            end
        elseif subtype == "SPELL_CAST_SUCCESS" and spellID == 185358 and state.talent.bombardment.enabled then
            bombardment_arcane_shots = ( bombardment_arcane_shots + 1 ) % 4
        end
    end
end )

spec:RegisterStateExpr( "last_steady_focus", function ()
    return steady_focus_applied
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


-- Tier 28
spec:RegisterSetBonuses( "tier28_2pc", 364491, "tier28_4pc", 363666 )
-- 2-Set - Focused Trickery - Trick Shots now also increases the damage of the affected shot by 30%.
-- 4-Set - Focused Trickery - Spending 40 Focus grants you 1 charge of Trick Shots.

local focusSpent = 0

local FOCUS = Enum.PowerType.Focus
local lastFocus = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "FOCUS" and state.set_bonus.tier28_4pc > 0 then
        local current = UnitPower( "player", FOCUS )

        if current < lastFocus then
            focusSpent = ( focusSpent + lastFocus - current ) % 40
        end

        lastFocus = current
    end
end )

spec:RegisterStateExpr( "focused_trickery_count", function ()
    return 0
end )


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
        startsCombat = false,

        cycle = function () return runeforge.serpentstalkers_trickery.enabled and "serpent_sting" or nil end,

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
                addStack( "bulletstorm", min( 8 - 2 * talent.heavy_ammo.rank + 2 * talent.light_ammo.rank, true_active_enemies ) )
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
            removeStack( "precise_shots" )
            if talent.trick_shots.enabled and active_enemies > 2 then applyBuff( "trick_shots" ) end
            if talent.calling_the_shots.enabled then cooldown.rapid_fire.expires = max( 0, cooldown.rapid_fire.expires - 2.5 ) end
            if buff.bombardment.up then
                applyBuff( "trick_shots" )
                removeBuff( "bombardment" )
            end
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
                addStack( "bulletstorm", min( 8 - 2 * talent.heavy_ammo.rank + 2 * talent.light_ammo.rank, true_active_enemies ) )
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
            if talent.steady_focus.enabled and prev[1].steady_shot and action.steady_shot.lastCast > last_steady_focus then
                applyBuff( "steady_focus" )
                last_steady_focus = query_time
            end
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


spec:RegisterPack( "Marksmanship", 20221028, [[Hekili:v3ZApkoY1(BPv06fVDVmG7hZmrarjrRUAxTzUs3os38ja3GPXzamXp6z6vi(TFRQSD9YNtvLnqpZnAv2TTlFQZ7x(uMPdN(pN(4YW8OPFkyqqWWbbFO)GbdgE79tFm)19rtFCF4Iph(m5)yx4wY)))im9ZzBd3LToEp9MVUjjCjfizjfPlil4pDC(6889z)539UNJZxx8u)fjBFxw82InH5Xj7wKgUkN(3lE30hFQiEt(VUB6tGiXGGPpgwKVojD6JpgV9Vp9X1XlxgvU8OSftFC6JBIZYZO7FEA8IpNToH9xFIrxr7cFAt0YP)TPpUinopknoKSUWnr7Y7NLhfU81zRswuK1VAHhN7DCE8UzR2e)86C2F9uXQvQRnnABy8USJZhDCoHjfUGsueYVCnueyAoHoq3)0IDrRssFoQ)(KIfRNLSAwA4FKKoBvA4ZBjOMk6WqGvBcFnknB2wcZVFXEXU(54nB475T09ucFI2mlpnCVmEqw1DNbmtSnmmBjhfUhf49ooV8zimWSKDevHDpplmnn5l9)8UKVSJrSlss2SK8hnxJmx)5fewZHdhNFLlWuSOVeVHGP7Jj4uw9cOGXWTjpFpj0szjGOKLLo548BhCCUF5IZdjm78(5XBJMLNmBzCedydhOblCUXKYv7vseVenlAx024OQDITrLKaHlKggVCw0luL)WLljYYVsnDk3k97jVbF0vMTVqTyzsbrfywor7JOv8GdQCe3hBy)xZI2(erxxXiGWOyQYn55YkneDX0i9LiWPAGqXO3BW9q1wvSNbD7yOIXqAef8Fq2sm6R73KKrfomRevRXpQAZgUDF0YiT1mCak2EcI1ATSgkoJB(Clsk2r8h(thNhad44Dmy(WabXiBaWOcCxYoOOljVl1MRCJRYCfknuKK568Pnjjl3uKLZeO(UQl3o7pdgZsHi(sy8gomySe8OeYEDEjzZMOxrDbwXjQwLchaZbtWz1ZqR1GKCuOZAzSLBrzlmrAdXbvY6IyvSTLml2MDNSf4tKvZs2r1aepSM94p9QuerXA3vZ8DjEfBZuUx9gv9CsHSbIcUmkmF9SfRd)CA4w57JOlfiPGNNwevNjWqNC6xK(mLCzPTP4XVxB4lUi71nxerOe7RVGbYYMScVeBhrXo6RrlkYjpymnByUAC4EI((Q4s3)dXdV4oWvuE2NgTiolQ6zwYPNvfK8)i3Bnv4u9yeHYIWS8Q)6AjNfvBEPqQ0FOGecjlVkrUhx86cgVHkXZOjttjkLGAkQj6MlF0j3AwfRQrFHvvALO3vO9gOIeGhtVbWfIBaDHQ0uy1MW4ClsYYzI9kEIqU2V8w6HqxSoEByuAiqeuKKkfefPOU8yEnp4r4pxiUocr01VtGnkucdJcK1zfflPQVgOu4KCfnARZqPtrRi6ERP3rkDUO09eg8SmQcjSrvaEKL2XyC2W6ExTzqLYU4yFxuwgbIFjm91mw607zWF)(W0W8cGuNLtopa395jSdebu0FqxdFB(GntWkhLlvsD4PWNPvgx2UbgCWD3rlz4P4Dl7VNKaAbr6hLwSNX1LJ1zA3wTHCvwltyv4pqReFElhu0uZP(NxfsKAqTcH25K049LW4xk9vrqesYAPVsCkWIAKVoIPGKKECEmrXj8fsURui0xYAJMsxuQAlpePceU7)uqY39pQDZQzmHNJNKx6O9Rl(JSz7ttwSjCBOkNJQgZzW7IFnKOhqmbilpjotFHm7JDllIZjk8eknlCdvks2NCY2Piouduyef8r4gpsYZpAgT4tIedONl8hkK4rQ8pMrBKv7YSKBWZ1D4g6U1lf3CeyANk7)2SYwdsmj295OYQ909RHtXsayXYmO2f4k3slWWT6XZLJPYDpiT9z5qTgOl7oXpBGoRPU5KmZtAOWKTpfkmq5UxsYZj78SYWqFH5Wk5RX70JfPgYI7KOdgzwBRHSVzDnzkHuNS50hhkv)VulGmZPg2cfrSYDHu5SPCWZdQ7BlCwsJ0lYvk1Aa1BZQrC3xwWYYs0aXrFWuNgZ0rHILW0q5gZarqs2ttUjx80VesW)NO5(8s4MIiB1PRxhcda1gHVUBXSI9CD8wTT2LK4iwJaXU2vbWhvHKYttObbfuMUDzfLfVcM2Gae3bCfP7G7(r)fdEYN9m5VRb3SOnzYWeBXgZycWBXBbDEMiHsbLUpfxjGoH5ed(lOeYOomKFPSn0Wv1ocgkNBx9vukSN8pv3PF(W(RjPJvqk2JYvvAWKbJiThVM4KAwznZUVQnvRDMxVrbDcpBcbbQY8dlUPKqxkPlu(KO2CtyO0JZH)YIuwYPLTGacdeRWhele0GfMK3zddUYfjQj8ONnu5Nzv8osEFKSnlXcKBnXgSFxzC(gYCly5zNz(DfFqtMb5iWm1OqVG7NFdswXoJKhJkBfCBkzitqPAp07mYgOFhpTTRSHJOer1Ebi2AgBudzHwantYbNpnL2IZ6iRvrdT9VxBscyMCpDT5Mqq61h6a5pXgk2rrbg1AgqeqSIoslTqJ5ABWCsdyQRXdhC7cjx0(NYYHaFJviiGVteGtzy0ZA4GEAX(QjeRAxLDWfiFiiZDRqZMtqFq2cmjD(skQ7Hf8vFV2sRpoR)IWfRJOn9lCX)PioLurEoXrCwrAKq3Lvda)(FjC3YQxtgqJHuZpoOr(XbgYpUB5DIYFVy5h3T84BcbevHH2vfSPQDHsWaale0GfMK1aCoJbTl)yy)TMrfBbRDmsQH8GGl2WawE2zMFxXhEBkVdp7cG8JnK7XPMFSLi5xzdhrjI3K8J7SMsBXz08JXenVn5hBP6g75hJt(Tn)yxffwZpgeqNy(XW(LSMFmCWTlKC5sKFmab4uggw6hIR5hdPD198JDux1H8JT3uVtlPOUhwal)4GZq(X5SxG6jD0liy1(0OxM98IL9h2x6vsXUlBVXpkgL4yZfvYH5KnBbn0nfIb7kW(yV1Sp500gDQNsJEwrWscvsjc9fcvnBG(Us6kg4F3DCk0C3sh057vv4BZGolYXgAy3hjgrrSbKwmccitlFjJsZnaW7aEOSeYD0SAKRhZFd7UIg(hXpkh4VK9ZYbNWLzl7BWjfP(ggpkhFq1Wg8OC42KX2CEEgzEkEDufVvQpIahxJAcuhef94GW1Cr2xJhqfSJxGSfrtB(atNbLbQJnd2KEouzKCmoRZ4hHJw4awer(7It1IHKdnECwWh3O6aVsJuT04vyyERr8R3IdWYzxPFOzL(7qUTI74UBvy2OqiD0LUmbeEwfWPf1QrGPNLZQGqq3IjoFK(SujDYDoXtLt7Yr6NuNzm(GNgTAvbZsnChHOi5oViAdH0YtsB5XkGxug6IKJGjDFTeoWtp9epso8S3jvfSLoGRF7pWo0v0kjHSbIRhzNsvLkCf4Wt5GQFTEF4gMhZ81r68xFH6pzxqpewoPy7MC4w3pLXJAXXpZE(9s7nJP14SQjmgy3VACgR8nIMnW3MGbb3FjZac7i6AjdiSJKNLd8Wt0jsoDj9K(RnrK6Nfju5GKYEw4MxsAEohkV8sPYjHhOxofOC4tmC0YmAa2dB4oroaDmx(xRCq68BMMw7JJjPwNdE8XaodGqCAWzlg(egz5GMzQHkYo9rAzdE7uW7scEdIC25132Gik(8LajxRMDJOWN3er23KD0dOurKs)OKnuacOIgNkaVEdadaUwURNLmX228S0z5uzF225W0fH7Ie7RtN6U6I)BuZczNR9JlPrEsNmpZgK1hH8CJhvUwPP7D05JU63DwdDwr36zO2XtNhEqVZ9PZlq7J5b(PZJEqNm2PCW4vOUBLsnYuFRnek0dlxmpJ57jajE6X2sR1hGlZ9E0SY)B13sd5cBKB1e2VxT6jAVfJs)m1drUPpOtWOUHM5jLamab(Gegq7YZSvfPVYFXbVXyq4UfreZ2WnZO1Uy(ftCEXIpkzLrCjWyfMBaTjdv2h0RSz)7ILSpKvMB1mO5rpWoVv6DJf1zDu4M8193ViN3Au8m0F4cQfR2VK9jS)D1P6IEYxP)z93zT3tBJx6ocyZM(4)7F9)5t)6N(V(ZhNFC()KEaGJ3UpjnNgep948FmNFgg)rs8OOY3binybnp1WI8KTHSdsmX(E3Zrz9p(B)oXvprFIaW)EYoYwZU9pwfn4FrGsEI0Fx71LC9Ed)Qp)5d0EErOqoiKUeguURRqjKWa(L)7FxdCp0vWPaL33vOaJudpvw9qDEDRbGoF5KbGZSevW8Xtfp0bG74rGSU7Gtepc6m)awfj4mRYfOZN4jvXbN4knjYJ)MfNovFhdANhNB7knQqAxgOu)viGdd(fCfcTJdd7UYb1qD5Tvrf)mT)gjSGvi19Z3bkTeq33EaDQSCx50zTKfFQHf0zfNOiQZU0oZXQ018Ana6GUMka6IowGja0fFdDkMDWfiMToy6eXOhFZfIrbaF4BaaqsN7utI50Z(OlEocmbGUitBKduRXIZJcAdW0jIrx9ODaXASHQz6SL1OPrz0p22KN61D5HF948FOeV(9IWJZxg)smTcYJZt2x2jqcQ9osHU9U3uSVQbnDOKmtmnR)lM86ohE(aGNpO65Fq65F)5LCA4tXbYXa64e5CxL4(xzsx6J9qDZcooN9rpNC7PpMTpAbTz13r)u8KSkw89NlRppHSRh)oSpRqh)nOvl6Rj89RhqUBIxnwQZ0AdMh8Zk6q8nYF8GgpCafAQ9wFYWdhUYyhs8UQY4V81hcVLIx1qZTy0TE9A1wC4Ggac8H3vPgadqzbho0Z42E4GY267PcGXbuTJ)ejUrB)cUXX2XYFZY4xLkEB8XBt(UYp1nvFOZgF7anDbGVBAhoy4Z1gHDy4d0M3vMbTVccQ9L66g6hLLX1ogRLf4YB0ww6z9v2yvDfVDOwjGflDyrzGQ4e0Qszs6ToBhyIo(bPat1)Q17j42yr)YPRUNExu9W6JPNroMprXaguAVRIAW089u4lm1A8(jkTMHF3e(E6B8Hdk9BD0WBTzfJt1Qq6936RWnPUS5D)NYpBIkOQstUDqde9bDOR2z)lXoWBB)Pd8pQdBT(53ChyV8rThQSv4qyJxVg92N6(nvTV(Jcg4RJzbpC20aOXreOCw(yTaivwWYJIHxp4Zlt5EcnAhJU)WHM3CjtBVhmMUKzMy2VMVmIty18d)I21fN3fTBiLva15HzoApR(Hhryj(2qAVRqDzWDl08ws7o08Tr3zjLBOLquWBOhn8Ec))k4rx7WHMZoMxVMtC2OHd8qgNmAiGMpWKA0upNMjdPmpx2vwYaJhAe6(6AhSJFrPkn)mJ45sEKzUN8PN(jbHky8Gpbi0BPTjQtGFdT4Yd3H2LLL1mTyuxCLkj6EHmPb4KWOEqxUgq3iyaOm6bQQiaSr0JMm8JG6kAofh0uGxh2v3UxoSRo)u(agqzOoz2tyIvEkvLHv8BzF8w9qiziJNXxZPoA09AuI(dlsqs5aristtC5gokcUOQjdHvtUd4YvM(Tt)bs9rJzvwVdpmnqKtBITQiznhgubdwz82mwsxgsTCg2D3Ip9t0kpDyuRG0k895LhkUONHthWOB1jjX4wP5ivE(Y84jDup6woe8DcvjYMHfKMUdmdDQO29jZIcnlFdke16d6JMVVPkd43RZjOWsY16QiMJ(Dpve2EavQev7HDD(O171WO8s6Kj4(ZtSObUels3xmFEY5EyuN796I(uN59gmiUMdBG2Rs4MpB7OTLktRFukJE64HCCcsvTrDWeATX4Rt9SCnVRA(IOH284XZhPXyPprEK0BWim7P0qHiEqf0GxcIr3xoyWDjDk51iyotjGDrdJbUqhI7Ev3)MIudr7GPiqb6e6GuFDfnQ)ReIMkOyiRpJqvzUQH0TLMyBVM5nnHFIBubB1ivd1F4txRWdj03BT2Idkdkd3STEEKP2iF6Yrh4zpRas(JXHuxkeDi0LUvW)Pv1u)jGaUChfuZwb7xQ0YDq73nveqd1ucLfiLpHB7ocCAvtoSQ7wwe53ZT4aOYOHUK2d1QuZq)220EePInCUTvkcQlDlg01U6w3quGcwdl0001BCHYT1BGrRz4azKngSSXFkajdqmm7)p0kag5BUBakefyxb47I6V6Nvg7AVjsidmJ9hW9YYXKByMmNEv7iaUk4pMLQu9FM9eI0DBLxfHbjRX6WGkYIV(w9oNaLPbOAqovdVtPbzt6a2fIM1kvdWXkhJvyS3HYGScAdv2duBeVUORHBalwCB4MuAqu4el)eY8e)jp3cPMLlRxACfFuV6bpRfp4yTPtUftU4wXroGiQB4O7SLdQ98eXca3IcKCrGyN0Cqt8EBkCTlnjl)YmIX7K)5z8CaWwvSKMy80lAsVadKINytKY46VUKvJWr5h7YBy)o)yiAQU3RMaMgwwf0kFdPR2bZHnX2FGzJWsPiNi(wPTEtY(XSFbMUHoUqXuayMcQOsRMbJ(lOVUUYFmLUr8dV0yBl1U623Ec(KOh3eFVfKXKZOCdKMOFixJZJ2MDd7l(F9GKXCx3RxoFwqL)OVA7feO(u1yfjZDKp37omJI8zkTn4H2JvJiKSq5xxsaW4uI7PsY0O5i4G4beVHQQo9nzmWovFtF99QEfyKR3jStxHZ6r2SEg2TF((rGFZGpCa8YtmaQFiWxwEGHcNf(WBknjyS6gpgWqb6dawFb(R)ZTKNby(Z3pbKc8aV6idq6hcOPGJHcWihdOk82Mbb8mDZjbd6OCZr8rgrmXgho4AyoMjSVtAp6peRboMOMjg5UoZ9GqFdp7iL3fPrH41MmzvaJKgMUh4ZdNK9)aBebi89XriBJPbMxTExPJuMKUtU3hJ0Pt9KJQfYuKVIvSXOCTlKzRDO577j7M08NPDcwZYst)d0UFBYRjqnVM2LpbmV5CKxt7YVs7XAkKA(r2hpg75pmL(EvVcmY1KxxB7Kd51O7gXWU11CaaJv2i)oiu4SWhEtPPlqIWGrOuZRbm0vNYRbjoXvOOamYDEZRPvYnhXhO8AGyJxK8AqYE0qEnquJJ51yJ7zkVgGNTl51azYILxJUh4ZdN8eYRjOB51O7vZuEnnLUoMxJf1cS8AqREVlHmBTdnL8AS9ZpdAEnSpQvt))(]] )
