-- HunterMarksmanship.lua
-- October 2024

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 254, true )

spec:RegisterResource( Enum.PowerType.Focus, {
    chakram = {
        aura = "chakram",

        last = function ()
            return state.buff.chakram.applied + floor( ( state.query_time - state.buff.chakram.applied ) / class.auras.chakram.tick_time ) * class.auras.chakram.tick_time
        end,

        interval = function () return class.auras.chakram.tick_time end,
        value = function () return state.conduit.necrotic_barrage.enabled and 5 or 3 end,
    },
    rapid_fire = {
        channel = "rapid_fire",

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.rapid_fire.tick_time ) * class.auras.rapid_fire.tick_time
        end,

        interval = function () return class.auras.rapid_fire.tick_time end,
        value = 1,
    }
} )

-- Talents
spec:RegisterTalents( {
    -- Hunter
    binding_shackles          = { 102388, 321468, 1 }, -- Targets stunned by Binding Shot, knocked back by High Explosive Trap, knocked up by Implosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal 10% less damage to you for 8 sec after the effect ends.
    binding_shot              = { 102386, 109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within 5 yds for 10 sec, stunning them for 3 sec if they move more than 5 yds from the arrow.
    blackrock_munitions       = { 102392, 462036, 1 }, -- The damage of Explosive Shot is increased by 8%.
    born_to_be_wild           = { 102416, 266921, 1 }, -- Reduces the cooldowns of Aspect of the Cheetah, and Aspect of the Turtle by 30 sec.
    bursting_shot             = { 102421, 186387, 1 }, -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by 50% for 6 sec, and dealing 643 Physical damage.
    camouflage                = { 102414, 199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for 1 min. While camouflaged, you will heal for 2% of maximum health every 1 sec.
    concussive_shot           = { 102407, 5116  , 1 }, -- Dazes the target, slowing movement speed by 50% for 6 sec. Steady Shot will increase the duration of Concussive Shot on the target by 3.0 sec.
    counter_shot              = { 102402, 147362, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for 3 sec.
    deathblow                 = { 102410, 343248, 1 }, -- [378770] Your next Kill Shot can be used on any target, regardless of their current health.
    devilsaur_tranquilizer    = { 102415, 459991, 1 }, -- If Tranquilizing Shot removes only an Enrage effect, its cooldown is reduced by 5 sec.
    disruptive_rounds         = { 102395, 343244, 1 }, -- When Tranquilizing Shot successfully dispels an effect or Counter Shot interrupts a cast, gain 10 Focus.
    emergency_salve           = { 102389, 459517, 1 }, -- Feign Death and Aspect of the Turtle removes poison and disease effects from you.
    entrapment                = { 102403, 393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for 4 sec. Damage taken may break this root.
    explosive_shot            = { 102420, 212431, 1 }, -- Fires an explosive shot at your target. After 3 sec, the shot will explode, dealing 35,498 Fire damage to all enemies within 8 yds. Deals reduced damage beyond 5 targets.
    ghillie_suit              = { 102385, 459466, 1 }, -- You take 20% reduced damage while Camouflage is active. This effect persists for 3 sec after you leave Camouflage.
    high_explosive_trap       = { 102739, 236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 5,110 Fire damage and knocking all enemies away. Limit 1. Trap will exist for 1 min.
    hunters_avoidance         = { 102423, 384799, 1 }, -- Damage taken from area of effect attacks reduced by 5%.
    implosive_trap            = { 102739, 462031, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 5,110 Fire damage and knocking all enemies up. Limit 1. Trap will exist for 1 min.
    improved_traps            = { 102418, 343247, 1 }, -- The cooldown of Tar Trap, High Explosive Trap, Implosive Trap, and Freezing Trap is reduced by 5.0 sec.
    intimidation              = { 102397, 19577 , 1 }, -- Commands your pet to intimidate the target, stunning it for 5 sec.
    keen_eyesight             = { 102409, 378004, 2 }, -- Critical strike chance increased by 2%.
    kill_shot                 = { 102399, 53351 , 1 }, -- You attempt to finish off a wounded target, dealing 41,767 Physical damage. Only usable on enemies with less than 20% health.
    kindling_flare            = { 102425, 459506, 1 }, -- Stealthed enemies revealed by Flare remain revealed for 3 sec after exiting the flare.
    kodo_tranquilizer         = { 102415, 459983, 1 }, -- Tranquilizing Shot removes up to 1 additional Magic effect from up to 2 nearby targets.
    lone_survivor             = { 102391, 388039, 1 }, -- Reduce the cooldown of Survival of the Fittest by 30 sec, and increase its duration by 2.0 sec. Reduce the cooldown of Counter Shot and Muzzle by 2 sec.
    misdirection              = { 102419, 34477 , 1 }, -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within 30 sec and lasting for 8 sec.
    moment_of_opportunity     = { 102426, 459488, 1 }, -- When a trap triggers, you gain 30% movement speed for 3 sec.; Can only occur every 1 min.
    natural_mending           = { 102401, 270581, 1 }, -- Every 10 Focus you spend reduces the remaining cooldown on Exhilaration by 1.0 sec.
    no_hard_feelings          = { 102412, 459546, 1 }, -- When Misdirection targets your pet, it reduces the damage they take by 50% for 5 sec.
    padded_armor              = { 102406, 459450, 1 }, -- Survival of the Fittest gains an additional charge.
    pathfinding               = { 102404, 378002, 1 }, -- Movement speed increased by 4%.
    posthaste                 = { 102411, 109215, 1 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by 50% for 4 sec.
    quick_load                = { 102413, 378771, 1 }, -- When you fall below 40% health, Bursting Shot and Scatter Shot have their cooldown immediately reset. This can only occur once every 25 sec.
    rejuvenating_wind         = { 102381, 385539, 1 }, -- Maximum health increased by 8%, and Exhilaration now also heals you for an additional 12.0% of your maximum health over 8 sec.
    roar_of_sacrifice         = { 102405, 53480 , 1 }, -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but 10% of all damage taken by that target is also taken by the pet. Lasts 12 sec.
    scare_beast               = { 102382, 1513  , 1 }, -- Scares a beast, causing it to run in fear for up to 20 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time.
    scatter_shot              = { 102421, 213691, 1 }, -- A short-range shot that deals 544 damage, removes all harmful damage over time effects, and incapacitates the target for 4 sec. Any damage caused will remove the effect. Turns off your attack when used.
    scouts_instincts          = { 102424, 459455, 1 }, -- You cannot be slowed below 80% of your normal movement speed while Aspect of the Cheetah is active.
    scrappy                   = { 102408, 459533, 1 }, -- Casting Aimed Shot reduces the cooldown of Intimidation and Binding Shot by 0.5 sec.
    serrated_tips             = { 102384, 459502, 1 }, -- You gain 5% more critical strike from critical strike sources.
    specialized_arsenal       = { 102390, 459542, 1 }, -- Aimed Shot deals 10% increased damage.
    survival_of_the_fittest   = { 102422, 264735, 1 }, -- Reduces all damage you and your pet take by 30% for 6 sec.
    tar_trap                  = { 102393, 187698, 1 }, -- Hurls a tar trap to the target location that creates a 8 yd radius pool of tar around itself for 30 sec when the first enemy approaches. All enemies have 50% reduced movement speed while in the area of effect. Limit 1. Trap will exist for 1 min.
    tarcoated_bindings        = { 102417, 459460, 1 }, -- Binding Shot's stun duration is increased by 1 sec.
    territorial_instincts     = { 102394, 459507, 1 }, -- Casting Intimidation without a pet now summons one from your stables to intimidate the target. Additionally, the cooldown of Intimidation is reduced by 5 sec.
    trailblazer               = { 102400, 199921, 1 }, -- Your movement speed is increased by 30% anytime you have not attacked for 3 sec.
    tranquilizing_shot        = { 102380, 19801 , 1 }, -- Removes 1 Enrage and 1 Magic effect from an enemy target.
    trigger_finger            = { 102396, 459534, 2 }, -- You and your pet have 5.0% increased attack speed. This effect is increased by 100% if you do not have an active pet.
    unnatural_causes          = { 102387, 459527, 1 }, -- Your damage over time effects deal 10% increased damage. This effect is increased by 50% on targets below 20% health.
    wilderness_medicine       = { 102383, 343242, 1 }, -- Mend Pet heals for an additional 25% of your pet's health over its duration, and has a 25% chance to dispel a magic effect each time it heals your pet.

    -- Marksmanship
    aimed_shot                = { 102297, 19434 , 1 }, -- A powerful aimed shot that deals 44,280 Physical damage.
    barrage                   = { 102332, 120360, 1 }, -- Rapidly fires a spray of shots for 2.4 sec, dealing an average of 18,785 Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond 8 targets.
    bulletstorm               = { 102303, 389019, 1 }, -- Each additional target your Rapid Fire or Aimed Shot ricochets to from Trick Shots increases the damage of Multi-Shot by 7% for 15 sec, stacking up to 10 times. The duration of this effect is not refreshed when gaining a stack.
    bullseye                  = { 102298, 204089, 1 }, -- When your abilities damage a target below 20% health, you gain 1% increased critical strike chance for 6 sec, stacking up to 30 times.
    calling_the_shots         = { 102312, 260404, 1 }, -- Every $s2 Focus spent reduces the cooldown of Trueshot by ${$m1/1000}.1 sec.
    careful_aim               = { 102313, 260228, 1 }, -- Aimed Shot deals 50% bonus damage to targets who are above 70% health.
    chimaera_shot             = { 102323, 342049, 1 }, -- A two-headed shot that hits your primary target for 9,917 Nature damage and another nearby target for 4,958 Frost damage.
    crack_shot                = { 102329, 321293, 1 }, -- Arcane Shot and Chimaera Shot Focus cost reduced by 20.
    improved_deathblow        = { 102305, 378769, 1 }, -- [378770] Your next Kill Shot can be used on any target, regardless of their current health.
    fan_the_hammer            = { 102314, 459794, 1 }, -- Rapid Fire shoots 3 additional shots.
    focused_aim               = { 102333, 378767, 2 }, -- Aimed Shot and Rapid Fire damage increased by 5.0%.
    heavy_ammo                = { 102334, 378910, 1 }, -- Trick Shots now ricochets to 2 fewer targets, but each ricochet deals an additional 25% damage.
    hydras_bite               = { 102301, 260241, 1 }, -- When Aimed Shot strikes an enemy affected with your Serpent Sting, it spreads Serpent Sting to 2 enemies nearby. Serpent Sting's damage over time is increased by 20%.
    improved_steady_shot      = { 102328, 321018, 1 }, -- Steady Shot now generates an additional $s1 Focus.
    in_the_rhythm             = { 102319, 407404, 1 }, -- When Rapid Fire fully finishes channeling, gain 8% haste for 6 sec.
    kill_zone                 = { 102310, 459921, 1 }, -- Your spells and attacks deal 8% increased damage and ignore line of sight against any target in your Volley.
    killer_accuracy           = { 102330, 378765, 1 }, -- Kill Shot critical strike chance and critical strike damage increased by 20%.
    legacy_of_the_windrunners = { 102327, 406425, 2 }, -- Aimed Shot coalesces 1 Wind Arrow that shoot your target for 1,782 Physical damage. Each time Rapid Fire deals damage, there is a 5% chance to coalesce a Wind Arrow at your target.
    light_ammo                = { 102334, 378913, 1 }, -- Trick Shots now causes Aimed Shot and Rapid Fire to ricochet to 2 additional targets.
    lock_and_load             = { 102324, 194595, 1 }, -- Your ranged auto attacks have a 8% chance to trigger Lock and Load, causing your next Aimed Shot to cost no Focus and be instant.
    lone_wolf                 = { 102300, 155228, 1 }, -- Increases your damage by 5% when you do not have an active pet.
    master_marksman           = { 102296, 260309, 1 }, -- Your melee and ranged special attack critical strikes cause the target to bleed for an additional 15% of the damage dealt over 6 sec.
    multishot                 = { 102295, 257620, 1 }, -- Fires several missiles, hitting your current target and all enemies within 10 yards for 6,192 Physical damage. Deals reduced damage beyond 5 targets.
    night_hunter              = { 102321, 378766, 1 }, -- Aimed Shot and Rapid Fire critical strike chance increased by 5%.
    penetrating_shots         = { 102331, 459783, 1 }, -- Gain critical strike damage equal to 40% of your critical strike chance.
    pin_cushion               = { 102328, 468392, 1 }, -- Steady Shot reduces the cooldown of Aimed Shot by ${$s1/1000} seconds.
    precise_shot              = { 102294, 260240, 1 }, -- Aimed Shot causes your next $?s342049[Chimaera Shot][Arcane Shot] or Multi-Shot to deal $s1% more damage and cost $260242s6% less Focus.
    rapid_fire                = { 102318, 257044, 1 }, -- Shoot a stream of 7 shots at your target over 1.6 sec, dealing a total of 51,660 Physical damage. Usable while moving. Each shot generates 1 Focus.
    rapid_fire_barrage        = { 102302, 459800, 1 }, -- Barrage now instead shoots Rapid Fires at your target and up to 4 nearby enemies at 30% effectiveness, but its cooldown is increased by 40 sec.
    razor_fragments           = { 102322, 384790, 1 }, -- When the Trick Shots effect fades or is consumed, or after gaining Deathblow, your next Kill Shot will deal 75% increased damage, and shred up to 5 targets near your Kill Shot target for 25% of the damage dealt by Kill Shot over 6 sec.
    readiness                 = { 102307, 389865, 1 }, -- Trueshot grants Wailing Arrow and Aimed Shot generates $s3 additional Wind Arrows while in Trueshot.; Wailing Arrow resets the cooldown of Rapid Fire and generates $s2 $Lcharge:charges; of Aimed Shot.
    salvo                     = { 102316, 400456, 1 }, -- Your next Multi-Shot or Volley now also applies Explosive Shot to up to 2 targets hit.
    serpentstalkers_trickery  = { 102315, 378888, 1 }, -- Aimed Shot also fires a Serpent Sting at the primary target.  Serpent Sting Fire a shot that poisons your target, causing them to take 1,836 Nature damage instantly and an additional 13,834 Nature damage over 18 sec.
    small_game_hunter         = { 102325, 459802, 1 }, -- Multi-Shot deals 75% increased damage and Explosive Shot deals 25% increased damage.
    steady_focus              = { 102293, 193533, 1 }, -- Casting Steady Shot increases your haste by $s1% for $193534d.
    streamline                = { 102308, 260367, 1 }, -- Rapid Fire's damage is increased by 15%, and Rapid Fire also causes your next Aimed Shot to cast 30% faster.
    surging_shots             = { 102320, 391559, 1 }, -- Rapid Fire deals 35% additional damage, and Aimed Shot has a 15% chance to reset the cooldown of Rapid Fire.
    tactical_reload           = { 102311, 400472, 1 }, -- Aimed Shot and Rapid Fire cooldown reduced by 10%.
    trick_shots               = { 102309, 257621, 1 }, -- When Multi-Shot hits 3 or more targets, your next Aimed Shot or Rapid Fire will ricochet and hit up to 5 additional targets for 65% of normal damage.
    trueshot                  = { 102304, 288613, 1 }, -- Reduces the cooldown of your Aimed Shot and Rapid Fire by ${100*(1-(100/(100+$m1)))}%, and causes Aimed Shot to cast $s4% faster and cost $s7% less Focus for $d.; While Trueshot is active, you generate $s5% additional Focus$?s386878[ and you gain $386877s1% critical strike chance and $386877s2% increased critical damage dealt every $386876t1 sec, stacking up to $386877u times][].$?s260404[; Every $260404s2 Focus spent reduces the cooldown of Trueshot by ${$260404m1/1000}.1 sec.][]
    unerring_vision           = { 102326, 386878, 1 }, -- [386876] While Trueshot is active you gain $386877s1% critical strike chance and $386877s2% increased critical damage dealt every $t1 sec, stacking up to $386877u times.
    volley                    = { 102317, 260243, 1 }, -- Rain a volley of arrows down over 6 sec, dealing up to 43,036 Physical damage to any enemy in the area, and gain the effects of Trick Shots for as long as Volley is active.
    wailing_arrow             = { 102299, 459806, 1 }, -- After summoning 20 Wind Arrows, your next Aimed Shot becomes a Wailing Arrow. Wailing Arrow

    -- Dark Ranger
    banshees_mark             = { 94957, 467902, 1 }, -- [131894] Summons a flock of crows to attack your target, dealing ${$131900s1*$d} Physical damage over $d.
    black_arrow               = { 94987, 466932, 1, "dark_ranger" }, -- [466930] You attempt to finish off a wounded target, dealing $s1 Shadow damage and $468572o1 Shadow damage over $468572d. Only usable on enemies above $s3% health or below $s2% health.
    bleak_arrows              = { 94961, 467749, 1 }, -- [378770] Your next Kill Shot can be used on any target, regardless of their current health.
    bleak_powder              = { 94974, 467911, 1 }, -- Casting Black Arrow while $?c1[Beast Cleave][Trick Shots] is active causes Black Arrow to explode upon hitting a target, dealing $467914s1 Shadow damage to nearby enemies.
    dark_chains               = { 94960, 430712, 1 }, -- While in combat, Disengage will chain the closest target to the ground, causing them to move $442396s1% slower until they move $s1 yards away.
    embrace_the_shadows       = { 94959, 430704, 1 }, -- You heal for 15% of all Shadow damage dealt by you or your pets.
    ebon_bowstring            = { 94986, 467897, 1 }, -- [378770] Your next Kill Shot can be used on any target, regardless of their current health.
    phantom_pain              = { 94986, 467941, 1 }, -- When $?c1[Kill Command][Aimed Shot] damages a target affected by Black Arrow, $s1% of the damage dealt is replicated to each other unit affected by Black Arrow.
    shadow_dagger             = { 94960, 467741, 1 }, -- While in combat, Disengage releases a fan of shadow daggers, dealing $467745s1 shadow damage per second and reducing affected target's movement speed by $467745s2% for $467745d.
    shadow_hounds             = { 94983, 430707, 1 }, -- Each time Black Arrow deals damage, you have a small chance to manifest a Dark Hound to charge to your target and deal Shadow damage for $442419d.$?c1[; Whenever you summon a Dire Beast, you have a $s1% chance to also summon a Shadow Hound.][]
    shadow_surge              = { 94982, 467936, 1 }, -- Periodic damage from Black Arrow has a small chance to erupt in a burst of darkness, dealing $444269s1 Shadow damage to all enemies near the target. Damage reduced beyond $s1 targets.
    soul_drinker              = { 94983, 469638, 1 }, -- [378770] Your next Kill Shot can be used on any target, regardless of their current health.
    smoke_screen              = { 94959, 430709, 1 }, -- Exhilaration grants you 3 sec of Survival of the Fittest. Survival of the Fittest activates Exhilaration at 50% effectiveness.
    the_bell_tolls            = { 94968, 467644, 1 }, -- Black Arrow is now usable on enemies with greater than 80% health or less than 20% health.
    withering_fire            = { 94993, 466990, 1 }, -- $?c1[Every $s1 casts of Bestial Wrath][While Trueshot is active], you surrender to darkness$?c2[.][ for $466991d]; If you would gain Deathblow while under the effects of Withering Fire, you instead instantly fire a Black Arrow at your target and $s3 additional Black Arrows at nearby targets at $s4% effectiveness.

    -- Sentinel
    catch_out                 = { 94990, 451516, 1 }, -- When a target affected by Sentinel deals damage to you, they are rooted for 3 sec. May only occur every 1 min per target.
    crescent_steel            = { 94980, 451530, 1 }, -- Targets you damage below 20% health gain a stack of Sentinel every 3 sec.
    dont_look_back            = { 94989, 450373, 1 }, -- Each time Sentinel deals damage to an enemy you gain an absorb shield equal to ${$s1}.1% of your maximum health, up to $s2%.
    extrapolated_shots        = { 94973, 450374, 1 }, -- When you apply Sentinel to a target not affected by Sentinel, you apply 1 additional stack.
    eyes_closed               = { 94970, 450381, 1 }, -- For 8 sec after activating Trueshot, all abilities are guaranteed to apply Sentinel.
    invigorating_pulse        = { 94971, 450379, 1 }, -- Each time Sentinel deals damage to an enemy it has an up to 15% chance to generate 5 focus. Chances decrease with each additional Sentinel currently imploding applied to enemies.
    lunar_storm               = { 94978, 450385, 1 }, -- Every 15 sec your next Rapid Fire summons a celestial owl that conjures a 10 yd radius Lunar Storm at the target's location for 8 sec. A random enemy affected by Sentinel within your Lunar Storm gets struck for 9,148 Arcane damage every 0.4 sec. Any target struck by this effect takes 10% increased damage from you and your pet for 8 sec.
    overwatch                 = { 94980, 450384, 1 }, -- All Sentinel debuffs implode when a target affected by more than 3 stacks of your Sentinel falls below $s1% health.; This effect can only occur once every $s2 sec per target.
    release_and_reload        = { 94958, 450376, 1 }, -- When you apply Sentinel on a target, you have a 15% chance to apply a second stack.
    sentinel                  = { 94976, 450369, 1, "sentinel" }, -- Your attacks have a chance to apply Sentinel on the target, stacking up to 10 times. While Sentinel stacks are higher than 3, applying Sentinel has a chance to trigger an implosion, causing a stack to be consumed on the target every sec to deal 9,551 Arcane damage.
    sentinel_precision        = { 94981, 450375, 1 }, -- Aimed Shot and Rapid Fire deal 5% increased damage.
    sentinel_watch            = { 94970, 451546, 1 }, -- Whenever a Sentinel deals damage, the cooldown of Trueshot is reduced by 1 sec, up to 15 sec.
    sideline                  = { 94990, 450378, 1 }, -- When Sentinel starts dealing damage, the target is snared by 40% for 3 sec.
    symphonic_arsenal         = { 94965, 450383, 1 }, -- Multi-Shot $?s137016[discharges][and Butchery discharge] arcane energy from all targets affected by your Sentinel, dealing $?c2[${$451194s1*$s2}][$451194s3] Arcane damage to up to $s1 targets within $451194A1 yds of your Sentinel targets.
} )


-- Auras
spec:RegisterAuras( {
    a_murder_of_crows = {
        id = 213835,
        duration = 15.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    aspect_of_the_chameleon = {
        id = 61648,
        duration = 60,
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
        duration = function() return ( talent.rapid_fire_barrage.enabled and 2 or 3 ) * haste end,
        tick_time = function() return talent.rapid_fire_barrage.enabled and spec.auras.rapid_fire.tick_time or ( 3 * haste / 16) end,
        max_stack = 1
    },
     -- Lore revealed.
     beast_lore = {
        id = 1462,
        duration = 30.0,
        max_stack = 1,
    },
    -- Dealing $s1% less damage to the Hunter.
    binding_shackles = {
        id = 321469,
        duration = 8.0,
        max_stack = 1,
    },
    -- Taking $w1 Shadow damage every $t1 seconds.
    black_arrow = {
        id = 468572,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
    },
    -- Firing at the target, probably not needed?
    bleak_arrows = {
        id = 467718,
        duration = 60.0,
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
    -- Rooted.
    catch_out = {
        id = 451517,
        duration = 3.0,
        max_stack = 1,
    },
    -- Taking $w2% increased damage from $@auracaster.
    chakram = {
        id = 375893,
        duration = 10.0,
        max_stack = 1,
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
    -- Stunned.
    consecutive_concussion = {
        id = 357021,
        duration = 4.0,
        max_stack = 1,
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
    -- Rooted.
    entrapment = {
        id = 393456,
        duration = 4.0,
        max_stack = 1,
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
    -- All abilities are guaranteed to apply Sentinel.
    eyes_closed = {
        id = 451180,
        duration = 8.0,
        max_stack = 1,
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
    -- $@auracaster can attack this target regardless of line of sight.; $@auracaster deals $w2% increased damage to this target.
    kill_zone = {
        id = 393480,
        duration = 3600,
        max_stack = 1,
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
    -- Damage taken from $@auracaster and their pets increased by $w1%.
    lunar_storm = {
        id = 450884,
        duration = 8.0,
        max_stack = 1,
    },
    -- Talent: Threat redirected from Hunter.
    -- https://wowhead.com/beta/spell=34477
    misdirection = {
        id = 34477,
        duration = 30,
        max_stack = 1
    },
    -- tww1_4pc
    moving_target = {
        id = 457116,
        duration = 15,
        max_stack = 1
    },
    -- Damage taken reduced by $w1%
    no_hard_feelings = {
        id = 459547,
        duration = 5.0,
        max_stack = 1,
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
    -- Damage of $?s342049[Chimaera Shot][Arcane Shot] or Multi-Shot increased by $s1 and their Focus cost is reduced by $s6%.
    precise_shot = {
        id = 260242,
        duration = 15,
        max_stack = 1,
        copy = { "precise_shots" } -- simc not updated to "precise_shot" yet
    },
    -- Recently benefitted from Quick Load.
    quick_load = {
        id = 385646,
        duration = 25.0,
        max_stack = 1,
        copy = "quick_load_icd"
    },
    rangers_finesse = {
        id = 408518,
        duration = 18,
        max_stack = 3
    },
    -- Talent: Being targeted by Rapid Fire.
    -- https://wowhead.com/beta/spell=257044
    rapid_fire = {
        id = 257044,
        duration = function () return 2 * haste end,
        tick_time = function ()
            return ( 2 * haste ) / ( talent.fan_the_hammer.enabled and 10 or 7 )
        end,
        type = "Ranged",
        max_stack = 1
    },
    -- Your next Kill Shot will deal 75% increased damage, and shred up to 5 targets near your Kill shot target for 25% of the damage dealt by Kill Shot over 6 sec.
    razor_fragments = {
        id = 388998,
        duration = 15,
        max_stack = 1,
    },
    -- Bleeding for $w1 damage every $t1 sec.
    razor_fragments_bleed = {
        id = 385638,
        duration = 6,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Heals you for $w1 every $t sec.
    rejuvenating_wind = {
        id = 385540,
        duration = 8.0,
        max_stack = 1,
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
    -- $w1% reduced movement speed.
    scorpid_venom = {
        id = 356723,
        duration = 3.0,
        max_stack = 1,
    },
    -- Sentinel from $@auracaster has a chance to start dealing $450412s1 Arcane damage every sec.
    sentinel = {
        id = 450387,
        duration = 1200.0,
        max_stack = 1,
    },
    -- Leech increased by $s1%.
    sentinels_protection = {
        id = 393777,
        duration = 12.0,
        max_stack = 1,
    },
    -- Suffering $s2 Nature damage every $t2 sec.
    serpent_sting = {
        id = 271788,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
    },
    -- Movement slowed by $w1%.
    sideline = {
        id = 450845,
        duration = 3.0,
        max_stack = 1,
    },
    -- Range of all shots increased by $w3%.
    sniper_shot = {
        id = 203155,
        duration = 6.0,
        max_stack = 1,
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
        duration = function() return 6 + 2 * talent.lone_survivor.rank end,
        max_stack = 1,
    },
    -- Taming a pet.
    tame_beast = {
        id = 1515,
        duration = 6.0,
        pandemic = true,
        max_stack = 1,
    },
    tar_trap = {
        id = 135299,
        duration = 30,
        max_stack = 1
    },
    -- Dealing bonus Nature damage to the target every $t sec for $d.
    titans_thunder = {
        id = 207094,
        duration = 8.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    trailblazer = {
        id = 231390,
        duration = 3600,
        max_stack = 1,
    },
    trick_shots = {
        id = 257622,
        duration = 20,
        max_stack = 1
    },
    trueshot = {
        id = 288613,
        duration = function () return ( 15 + ( legendary.eagletalons_true_focus.enabled and 3 or 0 ) ) * ( 1 + ( conduit.sharpshooters_focus.mod * 0.01 ) ) end,
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
    wailing_arrow_counter = {
        id = 459805,
        duration = 3600,
        max_stack = 20
    },
    wailing_arrow_override = {
        id = 459808,
        duration = 15,
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=195645
    wing_clip = {
        id = 195645,
        duration = 15,
        max_stack = 1
    },
    withering_fire = {
        id = 466991,
        duration = function () return spec.auras.trueshot.duration end,
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


local lunar_storm_expires = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

    if sourceGUID == state.GUID then
        if ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
                if spellID == 450978 then
                lunar_storm_expires = GetTime() + 13.7
            end
        end
    end
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
spec:RegisterGear( "tww1", 212018, 212019, 212020, 212021, 212023 )



spec:RegisterHook( "reset_precast", function ()
    if debuff.tar_trap.up then
        debuff.tar_trap.expires = debuff.tar_trap.applied + 30
    end

    if legendary.nessingwarys_trapping_apparatus.enabled then
        if buff.nesingwarys_apparatus.up then
            state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireNesingwarysTrappingApparatus, buff.nesingwarys_apparatus.expires )
        end
    end

    if legendary.eagletalons_true_focus.enabled then
        rawset( buff, "eagletalons_true_focus", buff.trueshot_aura )
    else
        rawset( buff, "eagletalons_true_focus", buff.eagletalons_true_focus_stub )
    end

    if covenant.kyrian then if now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end end

    if lunar_storm_expires > query_time then setCooldown( "lunar_storm", lunar_storm_expires - query_time ) end
    if IsSpellKnownOrOverridesKnown( 392060 ) then applyBuff( "wailing_arrow_override" ) end
end )

-- Abilities
spec:RegisterAbilities( {
    -- Trait: A powerful aimed shot that deals $s1 Physical damage$?s260240[ and causes your next 1-$260242u ][]$?s342049&s260240[Chimaera Shots]?s260240[Arcane Shots][]$?s260240[ or Multi-Shots to deal $260242s1% more damage][].$?s260228[    Aimed Shot deals $393952s1% bonus damage to targets who are above $260228s1% health.][]$?s378888[    Aimed Shot also fires a Serpent Sting at the primary target.][]
    aimed_shot = {
        id = 19434,
        cast = function ()
            if buff.lock_and_load.up then return 0 end
            return 2.5 * haste * ( buff.trueshot.up and 0.5 or 1 ) * ( buff.streamline.up and 0.7 or 1 )
        end,
        charges = 2,
        cooldown = function () return haste * 12 *( buff.trueshot.up and 0.3 or 1 ) * ( talent.tactical_reload.enabled and 0.9 or 1 ) end,
        recharge = function () return haste * 12 *( buff.trueshot.up and 0.3 or 1 ) * ( talent.tactical_reload.enabled and 0.9 or 1 ) end,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if buff.lock_and_load.up or buff.secrets_of_the_unblinking_vigil.up then return 0 end
            return 35 * ( ( buff.trueshot.up and 0.5 or 1 ) * ( legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) )
        end,
        spendType = "focus",

        talent = "aimed_shot",
        texture = 135130,
        startsCombat = true,
        nobuff = "wailing_arrow_override",
        indicator = function() if settings.trueshot_rapid_fire and buff.trueshot.up then return spec.abilities.rapid_fire.texture end end,

        usable = function ()
            if action.aimed_shot.cast > 0 and moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
            return true
        end,

        handler = function ()
            -- Simple buffs
            if buff.lock_and_load.up then removeBuff( "lock_and_load" ) end
            if set_bonus.tww1 >= 4 then removeBuff ( "moving_target" ) end
            if talent.precise_shot.enabled then applyBuff( "precise_shot" ) end

            -- Trick Shots
            if buff.trick_shots.up then
                if talent.bulletstorm.enabled then addStack( "bulletstorm", nil, min( 5 - 2 * talent.heavy_ammo.rank + 2 * talent.light_ammo.rank, true_active_enemies -1 ) ) end
                if buff.volley.down then 
                    removeBuff( "trick_shots" )
                    if talent.razor_fragments.enabled then applyBuff( "razor_fragments" ) end
                    end
            end
            --- Legacy / PvP stuff
            if set_bonus.tier29_2pc > 0 then
                if buff.find_the_mark.up then
                 removeBuff( "find_the_mark" )
                    applyDebuff( "target", "hit_the_mark" )
                end
            end
            if legendary.secrets_of_the_unblinking_vigil.enabled then 
                if buff.secrets_of_the_unblinking_vigil.up then removeBuff( "secrets_of_the_unblinking_vigil" ) end
            end
            if pvptalent.rangers_finesse.enabled then addStack( "rangers_finesse" ) end
        end,
        bind = "wailing_arrow"
    },

    wailing_arrow = {
        id = 392060,
        known = 19434,
        cast = function ()
            if buff.lock_and_load.up then return 0 end
            return 2 * haste * ( buff.trueshot.up and 0.5 or 1 ) * ( buff.streamline.up and 0.7 or 1 )
        end,
        cooldown = function () return haste * 12 *( buff.trueshot.up and 0.3 or 1 ) * ( talent.tactical_reload.enabled and 0.9 or 1 ) end,
        gcd = "spell",
        school = "shadow",

        spend = function ()
            if buff.lock_and_load.up or buff.secrets_of_the_unblinking_vigil.up then return 0 end
            return 15 * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) * ( buff.trueshot.up and 0.5 or 1 )
        end,
        spendType = "focus",

        talent = "wailing_arrow",
        texture = 132323,
        startsCombat = true,
        buff = "wailing_arrow_override",

        usable = function ()
            if action.wailing_arrow.cast > 0 and moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
            return true
        end,

        handler = function ()
            removeBuff( "wailing_arrow_override" )
            if buff.lock_and_load.up then removeBuff( "lock_and_load" ) end

            if talent.readiness.enabled then
                -- Trueshot grants Wailing Arrow and you generate 2 additional Wind Arrows while in Trueshot. Wailing Arrow resets the cooldown of Rapid Fire and generates 2 charges of Aimed Shot.
                gainCharges( "aimed_shot", 2 )
                setCooldown( "rapid_fire", 0 )
            end

            if talent.precise_shot.enabled then applyBuff( "precise_shot" ) end

            --- Legacy / PvP stuff
            if set_bonus.tier29_2pc > 0 then
                if buff.find_the_mark.up then
                 removeBuff( "find_the_mark" )
                    applyDebuff( "target", "hit_the_mark" )
                end
            end
            if legendary.secrets_of_the_unblinking_vigil.enabled then 
                if buff.secrets_of_the_unblinking_vigil.up then removeBuff( "secrets_of_the_unblinking_vigil" ) end
            end
            if pvptalent.rangers_finesse.enabled then addStack( "rangers_finesse" ) end
        end,

        bind = "aimed_shot"
    },

    -- A quick shot that causes $sw2 Arcane damage.$?s260393[    Arcane Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    arcane_shot = {
        id = 185358,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return ( 40 - ( talent.crack_shot.enabled and 20 or 0 ) ) * ( buff.precise_shot.up and 0.5 or 1 ) * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) end,
        spendType = "focus",

        startsCombat = true,

        notalent = "chimaera_shot",

        handler = function ()

            if buff.precise_shot.up then
                removeBuff( "precise_shot" )
                if set_bonus.tww1 >= 4 then
                    applyBuff ( "moving_target" )
                end
            end

            -- Legacy / PvP stuff
            if set_bonus.tier29_4pc > 0 then
                removeBuff( "focusing_aim" )
            end

        end,
    },


    -- The Hunter takes on the aspect of a chameleon, becoming untrackable.
    aspect_of_the_chameleon = {
        id = 61648,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "spell",

        startsCombat = false,

        handler = function ()
            applyBuff( "aspect_of_the_chameleon" )
        end,
    },

    -- Increases your movement speed by $s1% for $d, and then by $186258s1% for another $186258d$?a445701[, and then by $445701s1% for another $445701s2 sec][].$?a459455[; You cannot be slowed below $s2% of your normal movement speed.][]
    aspect_of_the_cheetah = {
        id = 186257,
        cast = 0.0,
        cooldown = function() return ( 180.0 - 30 * talent.born_to_be_wild.rank ) * ( talent.hunting_pack.enabled and 0.5 or 1 ) end,
        gcd = "off",

        startsCombat = false,

        handler = function ()
            applyBuff( "aspect_of_the_cheetah" )
        end,
    },

    -- Deflects all attacks and reduces all damage you take by $s4% for $d, but you cannot attack.$?s83495[  Additionally, you have a $83495s1% chance to reflect spells back at the attacker.][]
    aspect_of_the_turtle = {
        id = 186265,
        cast = 0.0,
        cooldown = function() return 180.0 - 30 * talent.born_to_be_wild.rank end,
        gcd = "off",

        startsCombat = false,

        handler = function ()
            applyBuff( "aspect_of_the_turtle" )
        end,
    },

    -- Talent: Rapidly fires a spray of shots for $120360d, dealing an average of $<damageSec> Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond $120361s1 targets.
    barrage = {
        id = function() return talent.rapid_fire_barrage.enabled and 459796 or 120360 end,
        cast = function() return ( talent.rapid_fire_barrage.enabled and 2 or 3 ) * haste end,
        channeled = true,
        cooldown = function() return 20 + 40 * talent.rapid_fire_barrage.rank end,
        gcd = "spell",
        school = "physical",

        spend = function () return ( state.spec.marksmanship and 30 or 60 ) * ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) end,
        spendType = "focus",

        talent = "barrage",
        startsCombat = true,

        start = function ()
            if talent.rapid_fire_barrage.enabled then 
                if talent.bulletstorm.enabled and buff.trick_shots.up then
                    addStack( "bulletstorm", nil, min( 4, true_active_enemies - 1 ) )
                end
                if talent.streamline.enabled then applyBuff( "streamline" ) end
            end
            applyBuff( "barrage" )
        end,

        finish = function ()
            if talent.rapid_fire_barrage.enabled then spec.abilities.rapid_fire.finish() end
        end,

        copy = { 120360, 459796, "rapid_fire_barrage" }
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

    -- Fire a Black Arrow into your target, dealing $o1 Shadow damage over $d.; Each time Black Arrow deals damage, you have a $s2% chance to generate a charge of $?a137015[Barbed Shot]?a137016[Aimed Shot and reduce its cast time by $439659s2%][Barbed Shot or Aimed Shot].
    black_arrow = {
        id = 466930,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "spell",

        spend = 10,
        spendType = 'focus',

        talent = "black_arrow",
        startsCombat = true,

        usable = function () return buff.deathblow.up or buff.flayers_mark.up or ( talent.the_bell_tolls.enabled and target.health_pct > 80 ) or target.health_pct < 20, "requires flayers_mark or target health below 20 percent or above 80 percent" end,
        handler = function ()
            applyDebuff( "target", "black_arrow" )
            spec.abilities.kill_shot.handler()
        end,
        bind = "kill_shot"
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
            if buff.rangers_finesse.stack == 3 then
                removeBuff( "rangers_finesse" )
                reduceCooldown( "aspect_of_the_turtle", 20 )
            end
            applyBuff( "bursting_shot" )
        end,
    },

    -- Throw a deadly chakram at your current target that will rapidly deal $375893s1 Physical damage $x times, bouncing to other targets if they are nearby. Enemies struck by Death Chakram take $375893s2% more damage from you and your pet for $375893d.; Each time the chakram deals damage, its damage is increased by $s3% and you generate $s4 Focus.
    chakram = {
        id = 375891,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "spell",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "chakram" )
        end,
    },

    -- Talent: A two-headed shot that hits your primary target for $344120sw1 Nature damage and another nearby target for ${$344121sw1*($s1/100)} Frost damage.$?s260393[    Chimaera Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    chimaera_shot = {
        id = 342049,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( 40 - ( talent.crack_shot.enabled and 20 or 0 ) ) * ( buff.precise_shot.up and 0.5 or 1 ) * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) end,
        spendType = "focus",

        talent = "chimaera_shot",
        startsCombat = true,

        handler = function ()
            removeStack( "precise_shot" )

            -- Legacy / PvP stuff
            if set_bonus.tier29_4pc > 0 then
                removeBuff( "focusing_aim" )
            end

        end,
    },

    -- Stings the target, dealing $s1 Nature damage and initiating a series of venoms. Each lasts $356723d and applies the next effect after the previous one ends.; $@spellicon356723 $@spellname356723:; $356723s1% reduced movement speed.; $@spellicon356727 $@spellname356727:; Silenced.; $@spellicon356730 $@spellname356730:; $356730s1% reduced damage and healing.
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
            applyDebuff( "target", "scorpid_venom" )
        end,

        auras = {
            scorpid_venom = {
                id = 356723,
                duration = 3,
                max_stack = 1
            },
            spider_venom = {
                id = 356727,
                duration = 3,
                max_stack = 1
            },
            viper_venom = {
                id = 356730,
                duration = 3,
                max_stack = 1
            }
        }
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
        cooldown = 10,
        gcd = "spell",
        school = "physical",

        spend = function () return buff.flayers_mark.up and 0 or 10 end,
        spendType = "focus",

        talent = "kill_shot",
        notalent = "black_arrow",
        startsCombat = true,

        usable = function () return buff.deathblow.up or target.health_pct < 20 or buff.flayers_mark.up, "requires flayers_mark or target health below 20 percent" end,
        handler = function ()

            removeBuff( "deathblow" )
            if buff.razor_fragments.up then
                removeBuff( "razor_fragments" )
                applyDebuff( "target", "razor_fragments_bleed" )
            end

            --- Legacy / PvP Stuff
            if covenant.venthyr then
                if buff.flayers_mark.up and legendary.pouch_of_razor_fragments.enabled then
                    applyDebuff( "target", "pouch_of_razor_fragments" )
                    removeBuff( "flayers_mark" )
                end
            end
            if set_bonus.tier30_4pc > 0 then
                reduceCooldown( "aimed_shot", 1.5 )
                reduceCooldown( "rapid_fire", 1.5 )
            end
        end,

        bind = "black_arrow"
    },

    lunar_storm = {
        cast = 0,
        cooldown = 13.7,
        gcd = "off",
        hidden = true,
    },

    -- Talent: Fires several missiles, hitting your current target and all enemies within $A1 yards for $s1 Physical damage. Deals reduced damage beyond $2643s1 targets.$?s260393[    Multi-Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    multishot = {
        id = 257620,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function () return 30 * ( buff.precise_shot.up and 0.5 or 1 ) * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) end,
        spendType = "focus",

        talent = "multishot",
        startsCombat = true,

        handler = function ()

            if buff.precise_shot.up then
                removeBuff( "precise_shot" )
                if set_bonus.tww1 >= 4 then
                    applyBuff ( "moving_target" )
                end
            end

            if buff.salvo.up then
                applyDebuff( "target", "explosive_shot" )
                if active_enemies > 1 and active_dot.explosive_shot < active_enemies then active_dot.explosive_shot = active_dot.explosive_shot + 1 end
                removeBuff( "salvo" )
            end

            if talent.trick_shots.enabled and active_enemies > 2 then applyBuff( "trick_shots" ) end

            -- Legacy / PvP stuff
            if set_bonus.tier29_4pc > 0 then
                removeBuff( "focusing_aim" )
            end

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
            if talent.bulletstorm.enabled and buff.trick_shots.up then
                addStack( "bulletstorm", nil, min( 5 - 2 * talent.heavy_ammo.rank + 2 * talent.light_ammo.rank, true_active_enemies - 1 ) )
            end
            if talent.lunar_storm.enabled and cooldown.lunar_storm.ready then
                setCooldown( "lunar_storm", 13.7 )
                applyDebuff( "target", "lunar_storm" )
            end
            if talent.streamline.enabled then applyBuff( "streamline" ) end

            -- Legacy / PvP stuff
            if conduit.brutal_projectiles.enabled then removeBuff( "brutal_projectiles" ) end
            if set_bonus.tier31_2pc > 0 then applyBuff( "volley", 2 * haste ) end
        end,

        finish = function ()
            if buff.volley.down then
                if buff.trick_shots.up then
                    removeBuff( "trick_shots" )
                    if talent.razor_fragments.enabled then applyBuff( "razor_fragments" ) end
                end
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

    -- A steady shot that causes $s1 Physical damage.    Usable while moving.$?s321018[    |cFFFFFFFFGenerates $s2 Focus.|r][]
    steady_shot = {
        id = 56641,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = function () return talent.improved_steady_shot.enabled and -20  or -10 end,
        spendType = "focus",

        startsCombat = true,
        texture = 132213,

        handler = function ()
            if debuff.concussive_shot.up then debuff.concussive_shot.expires = debuff.concussive_shot.expires + 3 end
            if talent.pin_cushion.enabled then reduceCooldown( "aimed_shot", 2 ) end
            applyBuff ( "steady_focus" )
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
            reduceCooldown( "aimed_shot", cooldown.aimed_shot.remains * 0.7 )
            reduceCooldown( "rapid_fire", cooldown.rapid_fire.remains * 0.7 )
            applyBuff( "trueshot" )

            if talent.readiness.enabled then
                -- Trueshot grants Wailing Arrow and you generate 2 additional Wind Arrows while in Trueshot. Wailing Arrow resets the cooldown of Rapid Fire and generates 2 charges of Aimed Shot.
                applyBuff( "wailing_arrow_override" )
            end

            if talent.withering_fire.enabled then applyBuff ( "withering_fire" ) end

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

            if pvptalent.rangers_finesse.enabled then
                if buff.rangers_finesse.stack == 3 then
                    removeBuff( "rangers_finesse" )
                    reduceCooldown( "aspect_of_the_turtle", 20 )
                end
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

spec:RegisterSetting( "pet_healing", 0, {
    name = strformat( "%s Below Health %%", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.mend_pet.id ) ),
    desc = strformat( "If set above zero, %s may be recommended when your pet falls below this health percentage.  Setting to |cFFFFD1000|r disables this feature.", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.mend_pet.id ) ),
    icon = 132179,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "1.5"
} )

spec:RegisterSetting( "mark_any", false, {
    name = strformat( "%s Any Target", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.hunters_mark.id ) ),
    desc = strformat( "If checked, %s may be recommended for any target rather than only bosses.", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.hunters_mark.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "trueshot_rapid_fire", true, {
    name = strformat( "%s Indicator during %s", Hekili:GetSpellLinkWithTexture( spec.abilities.rapid_fire.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.trueshot.id ) ),
    desc = strformat( "If checked, when %s is recommended during %s, a %s indicator will also be shown.  This icon means that you should attempt to queue %s during the cast, in case %s's cooldown is reset by %s / %s.  Otherwise, use the next recommended ability in the queue.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.aimed_shot.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.trueshot.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.rapid_fire.id ),
        spec.abilities.rapid_fire.name,
        spec.abilities.aimed_shot.name,
        Hekili:GetSpellLinkWithTexture( spec.talents.improved_deathblow[ 2 ] ),
        Hekili:GetSpellLinkWithTexture( spec.talents.surging_shots[ 2 ] ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "prevent_hardcasts", false, {
    name = "Prevent Hardcasts While Moving",
    desc = strformat( "If checked, the addon will not recommend %s or %s when moving and hardcasting.", Hekili:GetSpellLinkWithTexture( spec.abilities.aimed_shot.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.wailing_arrow.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Marksmanship", 20241021, [[Hekili:T3vFZTTns)plz6Ckwp2rwIooTPpwAM76nDUM5AVoNBV(FsIwIYIpHIuhjvCChp6Z(ZUaGK4LfGViR0KoAM2yBcGflwSy3FyXsIPJM(ltVDPFEW0FYBO3Rhn0B0aVRUA4WRMEB(JBdME7w)fV3)E4xI93a)7p6N((Sn(XzRd3If(yuI)sKizj7sxav4R2pFDE(2SV9YlVpmF9U7gSizZLzHB2f5NhMeVi1Fvo(3lUC6T3Tlmk)hINEhbtm81tV1Fx(6K0P3EB4MVB6TRdxUmGx5GSftVfR8Rg(2xnA4f7NJ)86VD)CSQ7NVBlsV9VB)74v6BGcHk555QgJWcZd8x(4(5FFYIDz7NNehb)r4Q9ZZ9JcIZdwk3IHVfAXVYieu3vPjBeuxUoiv)1SG9Z)h7G2N(sOMOqC)8SG88W47RQ8x)kVVgQ8pggNKcfhUPGl)FHFHGcYn8kOH)YAOo)Mp02FdK8HXtVnkmlpdNDYtdx8(S1jS)6NyZ6bX(3ffSC6FB6Tlsdb6g6d1JnkhKXKcZwHcHbIkUFEV9ZVB3QvQLMgSXpmgyPB2pFemJTaNKb1bEDWUCAomVI9yrzbFCBusw4hc4flXjqnVsUMFijkk4rTA8664(u)THlNTkmny2D(PPG2R5yGjqy9V0qyY49Zd(yWID5bZYdr19cgrqhS7V2A33fcxXRiTFJBAN6)7jPZwbCYgyCMny32kc9(WOOsX9xlleVlcwcpdgajpOjj)g3D320GfHz8zPbltEiUIMp4hgb6UcQcK6TTKu7N)0tLtf7cypxE4y0bJgATh(Gp8d4XLuAwkQ8vrSINZOJUYFrL8H5LLcnYfpUicMP8tVpawXaRx60SCL2gHKenHLgUL33FpUG)2G0T40kOf)E(Q8Fb7LG0hVan)G8c8tCnEuYdbzWFW7z0gsrJrdyWFpy)8)fZY1cFSEO9Rq4NpKSlcwdaJn)paK5bWkHOtG2Xgl7N)3tIFju1KpeK(aoM3p)N5mFrvycrVMViqB2wruSBlVKvCRTtaElbz4Z3pNpTmOAwzawu10f4pjpSCs9Q64hHkMQw8D(3plz1mUXrgDET8chzByklCYXPVv(ahuAnTOnlsy2OPSSPydmp1p()cE)c)Dul3MDqPrucS4a8yizBuO1J)w0UaSRtIWXx1OnL7ld0cpB)8xa6l(GTMGpG2i9xUeSS)r0)GufegqVBxuuwWJsMnztsH3VgxAvOTJtw694YDPmV8ZUhEqgBIuBcquH9ZVeChlPxu2NG(pQpow)5B8)4mrz9Lz50W43hKpiF0G1(zZa)KZW2XPSuHL8Q8a4QHUQht4r2xEU6lVg2xEu9fwJANM0RaUmIxOEjvI7ZnlmmM5127A6Uflg473m0kJj6x9hlpQhv167sY4dcnfjbl0xZM4FpawhTjmoOY(viuB)9ZVpjbuj5wyZteyJ(LcnS9Z)3a)awI)aZEycqUnH)UqkK7)EeQ220WeWcbiYZyThCTZPEgyyCjApcShZSWSnkOW4l25zOXx0El(BCtQmZLldI8FKB1eW)6hXyyOkfYF0Gmy6o9bMHu)iWcUOxaW0rrccKXhprSbnkC5AxbRwfSiVuZjdCh4hdC5dRdIrUN5a4VjwNCrjZWDvWCaigHjRepLndumm9)iWf4clW2oAvzghPVMZuNaV2c6ZRd8JYxpBlYPWuk8Oz4JaMtYODq8Yzqju4OkTGcYJz8)ygIFLJIvWulwMrHtQrTTq8vcqICOCwjW8mWKtkaCk(rXcxMwWGWSzCnzULbS3aKSlbnV1mt)zZ2WG3dgWgYQHODO(6S8euan7BgYwC4nSI1LBSBSzIEmioytyaF9ZvCoSYcUSd4cIa(ZGNMZGZ0ibwwUBKD6mcoIAFViT1eMNveGqYM78ZDVtLQXkSGmy2djrRQgPLEW3Tzd0NcnoDql17s10MFHjBd)gQoeAMldv3xHGcxia3nfXKaG8xKVlfW(KNSjbbbx6aqIK13eBECQCmCdT7VQkOtcWIIaERwtRkWEtgBRj9QJphxhF2V0tJlyb1pZyiL)ZUqZUJxMZcybn4YdDSji1EMxQShJxuShIccJBG4hIrpqzlat9mhtf(A)wv3zC7fl93W8mjE2fC3RyFbfcgfsZXFVK82kN5KdfjidaEJwe6hXESaHWIK4SWLyv)r2YfURWVVybdGEOAfZdbagbCWU2hgjjOxBdohC5Uiq4IFlSzSub6HTriMG7cYFiaDnZeFl3CFLlCMFB2JLPOMFxMqE2Ozfc(UTDaqfxAJXg0KOh9u6r7E7)CXfPocc0ZrXAJP3osQLz(rFiXfWb5n)RSy4N50C)8)kwd(EGXWcI)pIOcvuEizFfeXDXrSD(8qaQ2PSFBgEr26L)dlUwC6i38b17NxFVA8qKPUtnIw6HRZja(qUxxAjqrOrRebQJCeLooQ9tdyaPzR(veBSLIkbFGliUqSoJJoMr51PbcXlSWmOzcOjL7O0ISPNPOzmIzHH7OeEibSJ6xTzngukYsCtkCbvPPeWmtUqMbvnmfjISbwFjZUCBgCjhRfS(qX6b2Oke7ThXJze5Cnaou(NpByoa4pVB29OcdcBNM8ysOpGy(rbdlHrcdZh8mZdH4g6UZ10dJFOmY6xgEigHbm0zrj5Y)nItjz1Qz3VyPwGjRbYtPgALkIrrM(jAqSnQaD11UGMbRcIGBimxwyx0mavUB45O7fJbOHSZ5GFIv((v7Np666jauTRzwOTqMEwlby)xFnJd0g4IjedrUNHi3jN1GQ0DMhJvoHW3wxGv3EFCWkp2IbOcGFnPSZ(986Oh5Sw1oyOfjfRNSpy9g6Qc3qtyDPr)2Txk6TMWX2rAyGBDVHHwTbMpQvhYuO2edKQs1A7er96304D(SmW08M9RziMg6OgASxnXUrcZ4USyW1qVBIWhkIziggs8P8GAY8qw61RkyivNWelCOrjSWCwfA1IndXefWE0(EOdZ4phjaxLr4(uS)lTTCfY79hl7d)im2T3fOg02iF1Dmcc51(B3geNzWKeXS12WJjO8j3kSGy3jevSrkmA6ZbVQT)wIHry8QGu4)kh)SntPofYKISTwNd7QghR5fdDaDWR8VpojlpCbpA2cylivssz75TmSVz(BKhFB9dtz7IMTlL0GSDr5sZv8AZ7BxbSvqppnSkEncRsZwk6ciHNTfmuN5t3WQy64SbUBCyG1nwfYgsHvHWCSZbFRWQqrGU7UV1yvmHh6KZAqv6oZtIvXEx8CGvXHYtJIOBxXQqsVMIvX8WtFMWQ4a5MvSk1hv3dhRsnB06qSq10(OESkwSe8CGvPDdmEywYQ5CDoWmqJvNx4kZIOYmn7zosJt5kL8wZEkxzpQQerZs6i00YzUc3XLrbHkr5SfStPCotf(4)ibbc8VXIriAiMegOQcmGxNX)520eaSX)CxmMRH3MNKUbbNaOqWwi)yoENFJNlx7N)xrbchX5UTdiM1JW2ckvifLN05R7k1PKRw5SpQa6UgtyMNlcqAs8aLKmtljmKoFrtMY9rilToP(8rt)CElQtv(nPhbUW7zl4UfJPnxaxeo5WmbwuM0gSziqkMx0MW8bgA4SyJxKkh2IRm1bbREOr1K2yvbgVirnePZHW(AskhB(c8qx4XiEqLWO(SbKkq(1MfFwYkXZmnFWly1oybp0M1ijRoopaE7awwuCo)OOeLu6YGoC8QkzlwhUXpi1NZlL6(915iQ0oKiRdPmMyUDXFJTHd75D4(2N2HnxpiiKF0A21huo7GICx0htlMGvmtnSZFlo4J5C5oz3RKKmFNqkB7qmW00PQPRsdcks)BdDZCIuj9q8IXv)6zKVCjYjSOMVRrkPuyL7iv3a1LCKAzKPuABiRtYOKDVxuuYHMOanMqk94MTRtIdb0wPza1JupnRIAHjk1S7HnLoJFqGsRsOmBI8Bn5QT1rUFkmxx5QDK98YU2uoxcuqvoKpsjbTDMp8JSNiqDiRznNsTNEpnM8)Hpp7zp3WB8GW6KVN9v5UwQAKBXEklwDLBXysU5eJmT3jhy4btavmwai8tFpMxE1d)1OtkryPF6AmzCroU6IvEJmm5KeyvZU0hPoQVpPSIF8cW3wQF0mmz1CJu)iXoVTIBqdjmHdvC3AM(xes)Sz)F7wY25c1(bCnI6vb6GXir7YQgQI01GNXNdkY4tVMLQVsc9TjSF6emnHDfpnbUaQQYulrYFWwBbE3ZWNYEtZg(wWdbaUmfbZKbyRruoHB2MKMl25ZlZlZoXxIaF(V7cz5luwcc0YFxEYgF8LcBoGje2hmaG4D)twMtHV1xFxsm0DSIFjbGGxYbNtvuHjpOkNn6J9lP6RPPQP3hnAB39uvpS)DedFXR5q7g7xrZLfzYVgVP)YgOpMnOMiidQbgPKO0XnP5evpWfeeMOkhrI3oYcQqUjkVcTNFBeHRLKEUN0mkUr8P5jJrq4UoP1nI3oYsjBjQq753gryBKmzBapwRz8df6LuE4ac07Sxq)gRafyzn(tpP4yyIjLvFrIoxZtNOW)I3tpXDrP8Ydnw9zLV4q9rgI2(Wtp5yj4KRgARCy4RqvpBu1uhrLQ6Zk9F6jRcvZxdNENz7f)5CZ3QNB8U2K4HXtEZqIofOTLxVNjJW6JE67PmzcKVFHs3NDAmxEsJ5ZunMsRqFdn6H8QqFPbGi38DDPgunLVIjTdxJfmDLV)jA8LX7LIUjCpNojlMDT4KuQ4gr0dcUKBoTJUZTZP19ATqW9nOjnQZR)DQHyu2GM0WoVCjDXQrxUVLQZrL81syIZN1fwX2Y3DL81syPdbMsqivwt5tRKBu7j3N9CxTtkN0vBm5BaH)sX(DxN6oYKVwc31PUgY3DL81s4p7Tt85n3v7KYjD1gt(sc)gAOY8i1(svCYQzAGol(1pduICtazppO)pWi6ArqjLZjAeLiBu(uqtl7kRvtdc54qAsPC0KAuKm7imi8XzgAKLGUBCAM6022PD24oq)Gq17aBhuQrhyrH4z5ydeDXBp2cjBDWHlKiToimZ1Yt9XyM85a8MnIAgGidctwLJiXRLSD1Xsd56Us(JgH)JMVpia(pV6ghvIFKi7jE(ep)5jp3vlgnKR7k5pAe(eF3n(wr3QrhhCd542t42qYwTB52ZXTI81s4Jc6UogOJtabQLSNeehaz)dHNnYeflRT6DgXB1R0dfnt6Ll155T3)PNErBjOjlWi1e51U6wy(lxPEE4oR85EQjbGY43XGzcjF9Qrx7QrV66BiBwpYNE(RVEIYabeGoENb7DMJE2zHTJTMm2ZAEtii3KX00RttM0z(rr53OiHS0dN7IcAY4(9DKuiwKiEdPl4gkcvnYy9LTeIrAgtY)04HglI4z0RJKG5GwXwpn1KeUt5gVH9TLZkhaBwdgHVqTJD5j7y)5Xo2L)P1o2LNSJ9SzhReX21hd422i6idoX1MLRQYrK41swcfXgT7ZgY1DL8hnc)hnFFqBk)5v34Os8JezpXZN45pp55UAXOHCDxj)rJWN47UX3k6wn6TxRHCC7jCBiPvHaDDAlh3kYxlHpkO786wgdEciqTK9KG4ai7Fi8S9iFx32cPdWJh1g7m5NMhXiVMhXicR42J8nrLvJy0ilrmYCW0Gigz2O2fAMgfXOrurmYSNDwy7ylTigrrUUgXiYjt6Gf0Xigrqbxrms3PBNJyeHJqJiFRV4tMPBxeJSg432VITEAApIreRAAxeJAkBwdgHVqTJzpY3NSJ9mWwFATJD5FATJze57t2X6kBIi22)UFGLZ4iqT3u8DfdV(oZWVKGVB6TzBdwm9N8U(14DtvYQWOYl(7SbLVd6Np(YQRPWlcxn(f6V)47F3xTF(PBLTp53kB7Fh1KvHkZf4n6ZytJIxWUhIgxU0q911VsRsx7wRbffiTCT(3Y9QvW1)sPxXju24Q6tJYuAyHvc5gu8mYkoMOI9CWjJDWjkgZAO8uwe9f7WUnAMEgAMo8Otty5lEp0c1zgx)FWyw5Q)RFpX3Tn9l9VXd7rEz)bMPP7B2xVTlKVA)gpAiZI4N4RMpA2R6Rijkyu)y1DZvvFpB4VtCp9Kwn86Rou(S4o2ZYer1xSsZH6epudqAK2tT8XEO7sbzbIjFn5l)CZRfFDNFNUlW)eDxGlpTOBzr(ZAUWQsPvQo)PE6z6t80b8rbZ2x4jcuLYFkM0HS33HZCct(uK0tNKFr)XDswvQ4kGhTHOETXFJ0vgVITcTBpCUs4ILz1xPIvjY18tSZmR8g8tWRB4I8XJOCDGiB4RpYR((wvpvZl)EL6G6tywJ)kWW63Xm4Ww7)ZCeZ)q8QDzm7JCtkQFE23TDaVHfEiGPbGxcJ)qY7bY)rq0e7hX0158ddh(SqbrrwrDvBP2JxLxhonR(ofB2QDBjv1gDLbrk)cdttekRwvRgP6I3O3fQF5GpADt5Ne4NPE4T6DG2hmyZUbjVEJ4FbFPyPENXn4k9XdUCDv1ho4B8Sz1WqaWbcsI8OCWR(La(geOyfzYiqXq8DaOhJVPUHzUzuVxOpm1iF53G)srI5fiJwtKURy0kr97cpXqFKwd4dFgIPpTxLlA8r13najzS0hzcWPv5ugXn1I0ekrPtUMJIM((BPFLDtP2QXFfZFi3jTzizunmH4HExRO1TLFZ6lvokU7v6PUnboM3KMEtA08Bufngsr(X60t3iiD(gbrt2kTXqL7HgU)yejrgxsbAOOGQiUXcvB1cdJNTIzFgXyWj0)ZBFBPAKX9yZtpDMPlcZBVMBUFXYZl3xnaBvdeIx1IjLVal9ROVX9rZe57IME6gS6)CyoghH9C5Bs1uS2Zvgj0IqdB0MRC1QVXaT3z2(cNuUrzJpnj6chPlIIgYNIVslsIsZpHloDYuNSInbmbVVmkuu1VlqCi4QTXFkKI1YegIuP7XJ6afPRtld)OczEx17lGH8nwiQTPsLkv4HHSWMO)0Z6k)Xkxdv09Gk0GdIuTdRL64KcZLsnuCnA3q7H1ArGkiHtQqVMcy57rNK29EFrhCF)VIrhE8OtwDbkRe8uEygzDIWNEdC7pWYq1TFZMPW0RvtwMg3L7aP5jnBVGh1MBlrBzwlSPyZUbBl8CWs8zMYZbtCdqJ4HwgKfMIAl7LoDq)9vNzi2ZL380ylyktQtoSqOCUEuaRsNcreaDJKwHlpuMK7NOXCjV6c20CjhYFSaid(pcJeRnoyPjENQZVKUBRiLPr7iSQSY5XaLX8NU13pDRVFuU13jvzXyzd2Z3Cb(lIB3DW4mYtfXBLzQoNmO6nnbVOEdenJzEZZVRM)MntM)FwsVlI6QKDxwETMjc(FT52LzBAxou1Ou7I6LA2SJDvw7yk1e7IIADmVUiNejpXMULvxeeWrsDPFAoDnNUit62(oZccjgUvj0vNEtMjxGwlfTMnxeltAxYC1qESRM58KnZv3WRU0o11Pn2CZCnpnwj1LSyMRUKy1soS2Luy9qtv0gzMJkdwDLaRhktPAM7zm9vjNeDNyxTYmx7YD1NRuxL04TQzoh50vRmZ1P0w1zwRwhChtZChLCwLGhzxaMt))d]] )
