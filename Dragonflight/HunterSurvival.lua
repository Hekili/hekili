-- HunterSurvival.lua
-- October 2022

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local floor = math.floor
local strformat = string.format

local spec = Hekili:NewSpecialization( 255 )

spec:RegisterResource( Enum.PowerType.Focus, {
    terms_of_engagement = {
        aura = "terms_of_engagement",

        last = function ()
            local app = state.buff.terms_of_engagement.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 2,
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
    arctic_bola                 = { 79815, 390231, 2 }, -- Mongoose Bite has a chance to fling an Arctic Bola at your target, dealing 0 Frost damage and snaring the target by 20% for 3 sec. The Arctic Bola strikes up to 2 targets.
    barrage                     = { 79914, 120360, 1 }, -- Rapidly fires a spray of shots for 3.0 sec, dealing an average of 3,153 Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond 8 targets.
    beast_master                = { 79926, 378007, 2 }, -- Pet damage increased by 3%.
    binding_shackles            = { 79920, 321468, 1 }, -- Targets rooted by Binding Shot, knocked back by High Explosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal 10% less damage to you for 8 sec after the effect ends.
    binding_shot                = { 79937, 109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within 5 yds for 10 sec, stunning them for 3 sec if they move more than 5 yds from the arrow.
    born_to_be_wild             = { 79933, 266921, 2 }, -- Reduces the cooldowns of Aspect of the Eagle, Aspect of the Cheetah, Survival of the Fittest, and Aspect of the Turtle by 7%.
    camouflage                  = { 79934, 199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for 1 min. While camouflaged, you will heal for 2% of maximum health every 1 secs.
    concussive_shot             = { 79906, 5116  , 1 }, -- Dazes the target, slowing movement speed by 50% for 6 sec. Steady Shot will increase the duration of Concussive Shot on the target by 3.0 sec.
    death_chakram               = { 79916, 375891, 1 }, -- Throw a deadly chakram at your current target that will rapidly deal 865 Physical damage 7 times, bouncing to other targets if they are nearby. Enemies struck by Death Chakram take 10% more damage from you and your pet for 10 sec. Each time the chakram deals damage, its damage is increased by 15% and you generate 3 Focus.
    entrapment                  = { 79977, 393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for 4 sec. Damage taken may break this root.
    explosive_shot              = { 79914, 212431, 1 }, -- Fires an explosive shot at your target. After 3 sec, the shot will explode, dealing 3,793 Fire damage to all enemies within 8 yds. Deals reduced damage beyond 5 targets.
    high_explosive_trap         = { 79910, 236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 618 Fire damage and knocking all enemies away. Trap will exist for 1 min.
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
    poison_injection            = { 79911, 378014, 1 }, -- Serpent Sting's damage applies Latent Poison to the target, stacking up to 10 times. Mongoose Bite consumes all stacks of Latent Poison, dealing 223 Nature damage to the target per stack consumed.
    posthaste                   = { 79921, 109215, 2 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by 25% for 4 sec.
    rejuvenating_wind           = { 79909, 385539, 2 }, -- Maximum health increased by 4%, and Exhilaration now also heals you for an additional 10.0% of your maximum health over 8 sec.
    roar_of_sacrifice           = { 79832, 53480 , 1 }, -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but 10% of all damage taken by that target is also taken by the pet. Lasts 12 sec.
    scare_beast                 = { 79927, 1513  , 1 }, -- Scares a beast, causing it to run in fear for up to 20 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time.
    scatter_shot                = { 79937, 213691, 1 }, -- A short-range shot that deals 48 damage, removes all harmful damage over time effects, and incapacitates the target for 4 sec. Any damage caused will remove the effect. Turns off your attack when used.
    sentinel_owl                = { 79819, 388045, 1 }, -- Call forth a Sentinel Owl to the target location within 40 yds, granting you unhindered vision. Your attacks ignore line of sight against any target in this area. Every 150 Focus spent grants you 1 sec of the Sentinel Owl when cast, up to a maximum of 12 sec. The Sentinel Owl can only be summoned when it will last at least 5 sec.
    sentinels_perception        = { 79818, 388056, 1 }, -- Sentinel Owl now also grants unhindered vision to party members while active.
    sentinels_protection        = { 79818, 388057, 1 }, -- While the Sentinel Owl is active, your party gains 5% leech.
    serpent_sting               = { 79905, 271788, 1 }, -- Fire a shot that poisons your target, causing them to take 360 Nature damage instantly and an additional 2,170 Nature damage over 18 sec. Serpent Sting's damage applies Latent Poison to the target, stacking up to 10 times. Mongoose Bite consumes all stacks of Latent Poison, dealing 223 Nature damage to the target per stack consumed.
    serrated_shots              = { 79814, 389882, 2 }, -- Serpent Sting and Bleed damage increased by 10%. This value is increased to 20% against targets below 30% health.
    stampede                    = { 79916, 201430, 1 }, -- Summon a herd of stampeding animals from the wilds around you that deal 1,815 Physical damage to your enemies over 12 sec. Enemies struck by the stampede are snared by 30%, and you have 10% increased critical strike chance against them for 5 sec.
    steel_trap                  = { 79908, 162488, 1 }, -- Hurls a Steel Trap to the target location that snaps shut on the first enemy that approaches, immobilizing them for 20 sec and causing them to bleed for 2,200 damage over 20 sec. Damage other than Steel Trap may break the immobilization effect. Trap will exist for 1 min. Limit 1.
    survival_of_the_fittest     = { 79821, 264735, 1 }, -- Reduces all damage you and your pet take by 40% for 6 sec.
    tar_trap                    = { 79928, 187698, 1 }, -- Hurls a tar trap to the target location that creates a 8 yd radius pool of tar around itself for 30 sec when the first enemy approaches. All enemies have 50% reduced movement speed while in the area of effect. Trap will exist for 1 min.
    trailblazer                 = { 79931, 199921, 2 }, -- Your movement speed is increased by 15% anytime you have not attacked for 3 sec.
    tranquilizing_shot          = { 79907, 19801 , 1 }, -- Removes 1 Enrage and 1 Magic effect from an enemy target.
    wilderness_medicine         = { 79936, 343242, 2 }, -- Mend Pet heals for an additional 25% of your pet's health over its duration, and has a 25% chance to dispel a magic effect each time it heals your pet.

    -- Survival
    aspect_of_the_eagle         = { 79857, 186289, 1 }, -- Increases the range of your Mongoose Bite to 43 yds for 15 sec.
    birds_of_prey               = { 79864, 260331, 1 }, -- Kill Shot strikes up to 3 additional targets while Coordinated Assault is active.
    bloodseeker                 = { 79859, 260248, 1 }, -- Kill Command causes the target to bleed for 417 damage over 8 sec. You and your pet gain 10% attack speed for every bleeding enemy within 12 yds.
    bloody_claws                = { 79828, 385737, 2 }, -- Each stack of Mongoose Fury increases the chance for Kill Command to reset by 2%.
    bombardier                  = { 79864, 389880, 1 }, -- Wildfire Bomb's cooldown is reset at the start and end of Coordinated Assault.
    butchery                    = { 79848, 212436, 1 }, -- Attack all nearby enemies in a flurry of strikes, inflicting 1,865 Physical damage to each. Deals reduced damage beyond 5 targets.
    carve                       = { 79848, 187708, 1 }, -- A sweeping attack that strikes all enemies in front of you for 596 Physical damage. Deals reduced damage beyond 5 targets.
    coordinated_assault         = { 79865, 360952, 1 }, -- You and your pet charge your enemy, striking them for a combined 2,737 Physical damage. You and your pet's bond is then strengthened for 20 sec, causing your pet's Basic Attack to empower your next spell cast: Wildfire Bomb: Increase the initial damage by 20% Kill Shot: Bleed the target for 50% of Kill Shot's damage over 6 sec.
    coordinated_kill            = { 79824, 385739, 2 }, -- While Coordinated Assault is active, the cooldown of Wildfire Bomb is reduced by 25%, Wildifre Bomb generates 5 Focus when thrown, Kill Shot's cooldown is reduced by 25%, and Kill Shot can be used against any target, regardless of their current health.
    deadly_duo                  = { 79869, 378962, 2 }, -- While Spearhead is active, Mongoose Bite increases the damage of your next Kill Command by 40% and the reset chance of your next Kill Command by 20%, stacking up to 3 times. Kill Command cooldown resets extend the duration of Spearhead by 1.0 sec.
    energetic_ally              = { 79855, 378961, 1 }, -- You and your pets maximum Focus is increased by 10.
    explosives_expert           = { 79858, 378937, 2 }, -- Wildfire Bomb cooldown reduced by 1.0 sec.
    ferocity                    = { 79845, 378916, 1 }, -- All damage done by your pet is increased by 10%.
    flankers_advantage          = { 79860, 263186, 1 }, -- Kill Command has an additional 15% chance to immediately reset its cooldown.
    flanking_strike             = { 79841, 269751, 1 }, -- You and your pet leap to the target and strike it as one, dealing a total of 5,476 Physical damage. Generates 30 Focus for you and your pet.
    frenzy_strikes              = { 79844, 294029, 1 }, -- Butchery and Carve reduce the remaining cooldown on Wildfire Bomb by 1 sec and the the remaining cooldown of Flanking Strike by 1 sec for each target hit, up to 5.
    fury_of_the_eagle           = { 79852, 203415, 1 }, -- Furiously strikes all enemies in front of you, dealing 11,479 Physical damage over 4.0 sec. Critical strike chance increased by 50% against any target below 20% health. Deals reduced damage beyond 5 targets. Kill Command cooldown resets reduce the cooldown of Fury of the Eagle by 3.0 sec.
    guerrilla_tactics           = { 79867, 264332, 1 }, -- Wildfire Bomb now has 2 charges, and the initial explosion deals 50% increased damage.
    harpoon                     = { 79842, 190925, 1 }, -- Hurls a harpoon at an enemy, rooting them in place for 3 sec and pulling you to them.
    improved_wildfire_bomb      = { 79850, 321290, 2 }, -- Wildfire Bomb deals 8% additional damage.
    intense_focus               = { 79827, 385709, 1 }, -- Kill Command generates 6 additional Focus.
    kill_command                = { 79839, 259489, 1 }, -- Give the command to kill, causing your pet to savagely deal 1,691 Physical damage to the enemy. Kill Command has a 25% chance to immediately reset its cooldown. Kill Command also increases the damage of your next Mongoose Bite by 25%, stacking up to 3 times. Generates 15 Focus.
    kill_shot                   = { 79833, 320976, 1 }, -- You attempt to finish off a wounded target, dealing 5,191 Physical damage. Only usable on enemies with less than 20% health.
    killer_companion            = { 79854, 378955, 2 }, -- Kill Command damage increased by 5%.
    lunge                       = { 79846, 378934, 1 }, -- Increases the range of your melee attacks and abilities by 3 yds. Auto-attacks with a two-handed weapon reduce the cooldown of Wildfire Bombs by 1.0 sec.
    mongoose_bite               = { 79861, 259387, 1 }, -- A brutal attack that deals 2,720 Physical damage and grants you Mongoose Fury. Mongoose Fury Increases the damage of Mongoose Bite by 15% for 14 sec, stacking up to 5 times. Successive attacks do not increase duration.
    muzzle                      = { 79837, 187707, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for 3 sec.
    quick_shot                  = { 79868, 378940, 1 }, -- When Kill Command's cooldown is reset, you have a 30% chance to fire an Arcane Shot at your target at 100% of normal value.
    ranger                      = { 79825, 385695, 2 }, -- Kill Shot, Serpent Sting, Arcane Shot, Steady Shot, and Explosive Shot deal 20% increased damage.
    raptor_strike               = { 79847, 186270, 1 }, -- A vicious slash dealing 3,345 Physical damage.
    ruthless_marauder           = { 79829, 385718, 2 }, -- Fury of the Eagle now gains bonus critical strike chance against targets below 35% health, and Fury of the Eagle critical strikes reduce the cooldown of Wildfire Bomb and Flanking Strike by 0.5 sec.
    sharp_edges                 = { 79843, 378948, 2 }, -- Critical damage dealt increased by 2%.
    spear_focus                 = { 79853, 378953, 2 }, -- Mongoose Bite damage increased by 5%.
    spearhead                   = { 79866, 360966, 1 }, -- You and your pet charge your enemy, striking them for 478 Physical damage. You then become one with your pet for 12 sec. While active, your pet damage is increased by 25%, Raptor Strike and Mongoose Bite deal an additional 35% damage over 4 sec, and Kill Command has a 20% increased chance to reset.
    sweeping_spear              = { 79856, 378950, 2 }, -- Raptor Strike, Mongoose Bite, Butchery, and Carve damage increased by 5%.
    tactical_advantage          = { 79851, 378951, 2 }, -- Damage of Flanking Strike increased by 5% and all damage dealt by Wildfire Bomb increased by 5%.
    terms_of_engagement         = { 79862, 265895, 1 }, -- Harpoon has a 10 sec reduced cooldown, and deals 684 Physical damage and generates 20 Focus over 10 sec. Killing an enemy resets the cooldown of Harpoon.
    tip_of_the_spear            = { 79849, 260285, 2 }, -- Kill Command increases the damage of your next Mongoose Bite by 8%, stacking up to 3 times.
    vipers_venom                = { 79826, 268501, 2 }, -- Raptor Strike and Mongoose Bite have a 15% chance to apply Serpent Sting to your target.
    wildfire_bomb               = { 79863, 259495, 1 }, -- Hurl a bomb at the target, exploding for 1,580 Fire damage in a cone and coating enemies in wildfire, scorching them for 2,106 Fire damage over 6 sec.
    wildfire_infusion           = { 79870, 271014, 1 }, -- Lace your Wildfire Bomb with extra reagents, randomly giving it one of the following enhancements each time you throw it: Shrapnel Bomb: Shrapnel pierces the targets, causing Mongoose Bite and Butchery to apply a bleed for 9 sec that stacks up to 3 times. Pheromone Bomb: Kill Command has a 100% chance to reset against targets coated with Pheromones. Volatile Bomb: Reacts violently with poison, causing an extra 454 Fire damage against enemies suffering from your Serpent Sting, and applies Serpent Sting to up to 3 targets.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting     = 3609, -- (356719) Stings the target, dealing 1,906 Nature damage and initiating a series of venoms. Each lasts 3 sec and applies the next effect after the previous one ends.  Scorpid Venom: 90% reduced movement speed.  Spider Venom: Silenced.  Viper Venom: 20% reduced damage and healing.
    diamond_ice         = 686 , -- (203340) Victims of Freezing Trap can no longer be damaged or healed. Freezing Trap is now undispellable, but has a 5 sec duration.
    dragonscale_armor   = 3610, -- (202589) Magical damage over time effects deal 20% less damage to you.
    hunting_pack        = 661 , -- (203235) Aspect of the Cheetah has 50% reduced cooldown and grants its effects to allies within 15 yds.
    interlope           = 5532, -- (248518) The next hostile spell cast on the target will cause hostile spells for the next 3 sec. to be redirected to your pet. Your pet must be within 10 yards of the target for spells to be redirected.
    mending_bandage     = 662 , -- (212640) Instantly clears all bleeds, poisons, and diseases from the target, and heals for 30% damage over 6 sec. Being attacked will stop you from using Mending Bandage.
    sticky_tar          = 664 , -- (203264) Enemies who stand in your Tar Trap for 3 sec have their gear coated with tar, slowing melee attack speed by 80% for 5 sec.
    survival_tactics    = 3607, -- (202746) Feign Death dispels all harmful magical effects, and reduces damage taken by 90% for 1.5 sec.
    trackers_net        = 665 , -- (212638) Hurl a net at your enemy, rooting them for 6 sec. While within the net, the target's chance to hit is reduced by 80%. Any damage will break the net.
    tranquilizing_darts = 5420, -- (356015) Interrupting or removing effects with Tranquilizing Shot and Counter Shot releases 8 darts at nearby enemies, each reducing the duration of a beneficial Magic effect by 4 sec.
    wild_kingdom        = 5443, -- (356707) Call in help from one of your dismissed Cunning pets for 10 sec. Your current pet is dismissed to rest and heal 30% of maximum health.
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
    -- Talent: The range of $?s259387[Mongoose Bite][Raptor Strike] is increased to $265189r yds.
    -- https://wowhead.com/beta/spell=186289
    aspect_of_the_eagle = {
        id = 186289,
        duration = 15,
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
        id = 117405,
        duration = 3600,
        max_stack = 1,
    },
    bleeding_gash = {
        id = 361049,
        duration = 6,
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
    -- Kill Command causes the target to bleed for 839 damage over 8 sec. You and your pet gain 10% attack speed for every bleeding enemy within 12 yds.
    bloodseeker = {
        id = 260248,
    },
    camouflage = {
        id = 199483,
        duration = 60,
        max_stack = 1,
    },
    -- Talent: You and your pet's bond is strengthened, empowering your Wildfire Bomb or Kill Shot when your pet uses their basic attack.$?$w2!=0[  Wildfire Bomb cooldown reduced by $w2% and Wildfire Bomb generates $w3 Focus when thrown.  Kill Shot cooldown reduced by $w4%.][]$?260331[    Kill Shot strikes up to $260331s1 additional target while Coordinated Assault is active.][]
    -- https://wowhead.com/beta/spell=360952
    coordinated_assault = {
        id = 360952,
        duration = function () return 20 + ( conduit.deadly_tandem.mod * 0.001 ) end,
        max_stack = 1,
        copy = 266779
    },
    coordinated_assault_empower = {
        id = 361738,
        duration = 3,
        max_stack = 1,
    },
    -- While Coordinated Assault is active, the cooldown of Wildfire Bomb is reduced by 25%, Wildfire Bomb generates 5 Focus when thrown, Kill Shot's cooldown is reduced by 25%, and Kill Shot can be used against any target, regardless of their current health.
    coordinated_kill = {
        id = 385739,
    },
    deadly_duo = {
        id = 397568,
        duration = 12,
        max_stack = 3
    },
    -- When Tar Trap is activated, all enemies in its area are rooted for 4 sec. Damage taken may break this root.
    entrapment = {
        id = 393344,
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
    -- Talent: Rooted.
    -- https://wowhead.com/beta/spell=190925
    harpoon = {
        id = 190925,
        duration = 3,
        type = "Ranged",
        max_stack = 1,
        copy = 190927
    },
    -- The next hostile spell cast on the target will cause hostile spells for the next 3 sec. to be redirected to your pet. Your pet must be within 10 yards of the target for spells to be redirected.
    interlope = {
        id = 248518,
    },
    -- Suffering $w1 Bleed damage every $t1 sec.
    -- https://wowhead.com/beta/spell=270343
    internal_bleeding = {
        id = 270343,
        duration = 9,
        tick_time = 3,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 3
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
        max_stack = 10,
        copy = 273286
    },
    masters_call = {
        id = 54216,
        duration = 4,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: Threat redirected from Hunter.
    -- https://wowhead.com/beta/spell=34477
    misdirection_buff = {
        id = 34477,
        duration = 30,
        max_stack = 1
    },
    misdirection = {
        id = 35079,
        duration = 8,
        max_stack = 1,
    },
    -- Mongoose Bite damage increased by $s1%.$?$w2>0[  Kill Command reset chance increased by $w2%.][]
    -- https://wowhead.com/beta/spell=259388
    mongoose_fury = {
        id = 259388,
        duration = 14,
        max_stack = 5
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
    predator = {
        id = 260249,
        duratinon = 3600,
        max_stack = 10,
    },
    -- Talent: Suffering $s2 Nature damage every $t2 sec.
    -- https://wowhead.com/beta/spell=271788
    serpent_sting = {
        id = 271788,
        duration = function () return 12 * haste end,
        tick_time = function () return 3 * haste end,
        type = "Ranged",
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
    -- Talent: Pet damage dealt increased by $s1%.  $?s259387[Mongoose Bite][Raptor Strike] deals an additional $s2% of damage dealt as a bleed over $389881d.  Kill Command has a $s3% increased chance to reset its cooldown.$?$w4!=0&?s259387[  Mongoose Bite Focus cost reduced by $w4.]?$w4!=0&!s259387[  Raptor Strike Focus cost reduced by $w4.][]
    -- https://wowhead.com/beta/spell=360966
    spearhead = {
        id = 360966,
        duration = 12,
        max_stack = 1
    },
    spearhead_damage = {
        id = 389881,
        duration = 4,
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
    steel_trap_immobilize = {
        id = 162480,
        duration = 20,
        max_stack = 1,
    },
    terms_of_engagement = {
        id = 265898,
        duration = 10,
        max_stack = 1,
    },
    -- Talent: Your next $?s259387[Mongoose Bite][Raptor Strike] deals $s1% increased damage.
    -- https://wowhead.com/beta/spell=260286
    tip_of_the_spear = {
        id = 260286,
        duration = 10,
        max_stack = 3
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
    -- Call in help from one of your dismissed Cunning pets for 10 sec. Your current pet is dismissed to rest and heal 30% of maximum health.
    wild_kingdom = {
        id = 356707,
    },
    -- Talent: Suffering $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=269747
    wildfire_bomb_dot = {
        id = 269747,
        duration = 6,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    wildfire_bomb = {
        alias = { "wildfire_bomb_dot", "shrapnel_bomb", "pheromone_bomb", "volatile_bomb" },
        aliasType = "debuff",
        aliasMode = "longest"
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=195645
    wing_clip = {
        id = 195645,
        duration = 15,
        max_stack = 1
    },


    -- AZERITE POWERS
    blur_of_talons = {
        id = 277969,
        duration = 6,
        max_stack = 5,
    },
    primeval_intuition = {
        id = 288573,
        duration = 12,
        max_stack = 5,
    },

    -- Legendaries
    butchers_bone_fragments = {
        id = 336908,
        duration = 12,
        max_stack = 6,
    },
    latent_poison_injection = {
        id = 336903,
        duration = 15,
        max_stack = 10
    },
    nessingwarys_trapping_apparatus = {
        id = 336744,
        duration = 5,
        max_stack = 1,
        copy = { "nesingwarys_trapping_apparatus", "nesingwarys_apparatus", "nessingwarys_apparatus" }
    },

    -- Conduits
    flame_infusion = {
        id = 341401,
        duration = 8,
        max_stack = 2,
    },
    strength_of_the_pack = {
        id = 341223,
        duration = 4,
        max_stack = 1
    }
} )


spec:RegisterHook( "runHandler", function( action, pool )
    if buff.camouflage.up and action ~= "camouflage" then removeBuff( "camouflage" ) end
    if buff.feign_death.up and action ~= "feign_death" then removeBuff( "feign_death" ) end
end )


spec:RegisterStateExpr( "current_wildfire_bomb", function () return "wildfire_bomb" end )

spec:RegisterStateExpr( "check_focus_overcap", function ()
    if settings.allow_focus_overcap then return true end
    if not this_action then return focus.current + focus.regen * gcd.max <= focus.max end
    return focus.current + cast_regen <= focus.max
end )


local function IsActiveSpell( id )
    local slot = FindSpellBookSlotBySpellID( id )
    if not slot then return false end

    local _, _, spellID = GetSpellBookItemName( slot, "spell" )
    return id == spellID
end

state.IsActiveSpell = IsActiveSpell


local ExpireNesingwarysTrappingApparatus = setfenv( function()
    focus.regen = focus.regen * 0.5
    forecastResources( "focus" )
end, state )


local TriggerBombardier = setfenv( function()
    setCooldown( "wildfire_bomb", 0 )
    if talent.wildfire_infusion.enabled then
        setCooldown( "pheromone_bomb", 0 )
        setCooldown( "shrapnel_bomb", 0 )
        setCooldown( "volatile_bomb", 0 )
    end
end, state )


spec:RegisterGear( "tier29", 200390, 200392, 200387, 200389, 200391 )
spec:RegisterAura( "bestial_barrage", {
    id = 394388,
    duration = 15,
    max_stack = 1
} )

spec:RegisterGear( "tier30", 202482, 202480, 202479, 202478, 202477 )
spec:RegisterAura( "shredded_armor", {
    id = 410167,
    duration = 8,
    max_stack = 1
} )


spec:RegisterHook( "reset_precast", function()
    if talent.wildfire_infusion.enabled then
        if IsActiveSpell( 270335 ) then current_wildfire_bomb = "shrapnel_bomb"
        elseif IsActiveSpell( 270323 ) then current_wildfire_bomb = "pheromone_bomb"
        elseif IsActiveSpell( 271045 ) then current_wildfire_bomb = "volatile_bomb"
        else current_wildfire_bomb = "wildfire_bomb" end
    else
        current_wildfire_bomb = "wildfire_bomb"
    end

    if talent.bombardier.enabled and buff.coordinated_assault.up then
        state:QueueAuraExpiration( "coordinated_assault", TriggerBombardier, buff.coordinated_assault.expires )
    end

    if now - action.harpoon.lastCast < 1.5 then
        setDistance( 5 )
    end

    if debuff.tar_trap.up then
        debuff.tar_trap.expires = debuff.tar_trap.applied + 30
    end

    if buff.nesingwarys_apparatus.up then
        state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireNesingwarysTrappingApparatus, buff.nesingwarys_apparatus.expires )
    end

    if now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end
end )

spec:RegisterHook( "spend", function( amt, resource )
    if set_bonus.tier30_4pc > 0 and amt >= 30 then
        local sec = floor( amt / 30 )
        gainChargeTime( "wildfire_bomb", sec )
        gainChargeTime( "shrapnel_bomb", sec )
        gainChargeTime( "volatile_bomb", sec )
        gainChargeTime( "pheromone_bomb", sec )
    end
end )

spec:RegisterHook( "specializationChanged", function ()
    current_wildfire_bomb = nil
end )

spec:RegisterHook( "spend", function( amt, resource )
    if set_bonus.tier30_4pc > 0 and amt > 25 and resource == "focus" then
        local cdr = floor( amt / 25 )
        reduceCooldown( "wildfire_bomb", cdr )
        reduceCooldown( "shrapnel_bomb", cdr )
        reduceCooldown( "pheromone_bomb", cdr )
        reduceCooldown( "volatile_bomb", cdr )
    end
end )

spec:RegisterStateTable( "next_wi_bomb", setmetatable( {}, {
    __index = function( t, k )
        if k == "shrapnel" then return current_wildfire_bomb == "shrapnel_bomb"
        elseif k == "pheromone" then return current_wildfire_bomb == "pheromone_bomb"
        elseif k == "volatile" then return current_wildfire_bomb == "volatile_bomb" end
        return false
    end
} ) )

spec:RegisterStateTable( "bloodseeker", setmetatable( {}, {
    __index = function( t, k )
        if k == "count" then
            return active_dot.kill_command
        end

        return debuff.kill_command[ k ]
    end,
} ) )


spec:RegisterStateExpr( "bloodseeker", function () return debuff.bloodseeker end )


-- Abilities
spec:RegisterAbilities( {
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

    -- Talent: Increases the range of your $?s259387[Mongoose Bite][Raptor Strike] to $265189r yds for $d.
    aspect_of_the_eagle = {
        id = 186289,
        cast = 0,
        cooldown = function () return 90 * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( 1 - 0.075 * talent.born_to_be_wild.rank ) end,
        gcd = "off",
        school = "physical",

        talent = "aspect_of_the_eagle",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "aspect_of_the_eagle" )
        end,
    },

    -- Talent: Rapidly fires a spray of shots for $120360d, dealing an average of $<damageSec> Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond $120361s1 targets.
    barrage = {
        id = 120360,
        cast = 3,
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

    -- Talent: Attack all nearby enemies in a flurry of strikes, inflicting $s1 Physical damage to each. Deals reduced damage beyond $s3 targets.$?s294029[    Reduces the remaining cooldown on Wildfire Bomb by $<cdr> sec for each target hit, up to $s3 sec.][]
    butchery = {
        id = 212436,
        cast = 0,
        charges = 3,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",
        school = "physical",

        spend = function() return 30 - ( buff.bestial_barrage.up and 10 or 0 ) end,
        spendType = "focus",

        talent = "butchery",
        startsCombat = true,
        aura = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
        cycle = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,

        usable = function () return charges > 1 or active_enemies > 1 or target.time_to_die < ( 9 * haste ) end,
        handler = function ()
            removeBuff( "bestial_barrage" )
            removeBuff( "butchers_bone_fragments" )

            if talent.frenzy_strikes.enabled then
                gainChargeTime( "wildfire_bomb", min( 5, true_active_enemies ) )
                gainChargeTime( "shrapnel_bomb", min( 5, true_active_enemies ) )
                gainChargeTime( "volatile_bomb", min( 5, true_active_enemies ) )
                gainChargeTime( "pheromone_bomb", min( 5, true_active_enemies ) )
                reduceCooldown( "flanking_strike", min( 5, true_active_enemies ) )
            end

            if debuff.shrapnel_bomb.up then applyDebuff( "target", "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end

            if conduit.flame_infusion.enabled then
                addStack( "flame_infusion", nil, 1 )
            end
        end,
    },

    -- Talent: A sweeping attack that strikes all enemies in front of you for $s1 Physical damage. Deals reduced damage beyond $s3 targets.$?s294029[    Reduces the remaining cooldown on Wildfire Bomb by $<cdr> sec for each target hit, up to $s3 sec.][]
    carve = {
        id = 187708,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        spend = function() return 35 - ( buff.bestial_barrage.up and 10 or 0 ) end,
        spendType = "focus",

        talent = "carve",
        startsCombat = true,
        notalent = "butchery",

        handler = function ()
            removeBuff( "bestial_barrage" )
            removeBuff( "butchers_bone_fragments" )

            if debuff.shrapnel_bomb.up then applyDebuff( "target", "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end

            if talent.frenzy_strikes.enabled then
                gainChargeTime( "wildfire_bomb", min( 5, true_active_enemies ) )
                gainChargeTime( "shrapnel_bomb", min( 5, true_active_enemies ) )
                gainChargeTime( "volatile_bomb", min( 5, true_active_enemies ) )
                gainChargeTime( "pheromone_bomb", min( 5, true_active_enemies ) )
                reduceCooldown( "flanking_strike", min( 5, true_active_enemies ) )
            end

            if conduit.flame_infusion.enabled then
                addStack( "flame_infusion", nil, 1 )
            end
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

    -- Talent: You and your pet charge your enemy, striking them for a combined $<combinedDmg> Physical damage. You and your pet's bond is then strengthened for $d, causing your pet's Basic Attack to empower your next spell cast:    $@spellname259495: Increaase the initial damage by $361738s2%  $@spellname320976: Bleed the target for $361738s1% of Kill Shot's damage over $361049d.$?s389880[    Wildfire Bomb's cooldown is reset when Coordinated Assault is applied and when it is removed.][]$?s260331[    Kill Shot strikes up to $260331s1 additional target while Coordinated Assault is active.][]
    coordinated_assault = {
        id = 360952,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "nature",

        talent = "coordinated_assault",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "coordinated_assault" )
            if talent.bombardier.enabled then
                setCooldown( "wildfire_bomb", 0 )
                TriggerBombardier()
                state:QueueAuraExpiration( "coordinated_assault", TriggerBombardier, buff.coordinated_assault.expires )
            end
        end,
    },

    -- Talent: You and your pet leap to the target and strike it as one, dealing a total of $<damage> Physical damage.    |cFFFFFFFFGenerates $269752s2 Focus for you and your pet.|r
    flanking_strike = {
        id = 269751,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        spend = -30,
        spendType = "focus",

        talent = "flanking_strike",
        startsCombat = true,

        usable = function () return pet.alive end,
    },

    -- Talent: Furiously strikes all enemies in front of you, dealing ${$203413s1*9} Physical damage over $d. Critical strike chance increased by $s3% against any target below $s4% health. Deals reduced damage beyond $s5 targets.    Kill Command cooldown resets reduce the cooldown of Fury of the Eagle by ${$m2/1000}.1 sec$?s385718[ and the cooldown of Wildfire Bomb and Flanking Strike by ${$m1/1000}.1 sec][].
    fury_of_the_eagle = {
        id = 203415,
        cast = 4,
        channeled = true,
        cooldown = 45,
        gcd = "spell",
        school = "physical",

        talent = "fury_of_the_eagle",
        startsCombat = true,
    },

    -- Talent: Hurls a harpoon at an enemy, rooting them in place for $190927d and pulling you to them.
    harpoon = {
        id = 190925,
        cast = 0,
        charges = 1,
        cooldown = function() return talent.terms_of_engagement.enabled and 20 or 30 end,
        -- recharge = function() return talent.terms_of_engagement.enabled and 20 or 30 end,
        gcd = "off",
        school = "physical",

        talent = "harpoon",
        startsCombat = true,

        usable = function () return settings.use_harpoon and target.distance > 8, "harpoon disabled or target too close" end,
        handler = function ()
            applyDebuff( "target", "harpoon" )
            if talent.terms_of_engagement.enabled then applyBuff( "terms_of_engagement" ) end
            setDistance( 5 )
        end,
    },

    -- Talent: Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies away.  Trap will exist for $236775d.$?s321468[    Targets knocked back by High Explosive Trap deal $321469s1% less damage to you for $321469d after being knocked back.][]
    high_explosive_trap = {
        id = 236776,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        school = "fire",

        talent = "high_explosive_trap",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Give the command to kill, causing your pet to savagely deal $<damage> Physical damage to the enemy.    Kill Command has a $s2% chance to immediately reset its cooldown. $?s260285[ Kill Command also increases the damage of your next ][]$?s260285&s259387[Mongoose Bite]?s260285&!s259387[Raptor Strike][]$?s260285 [ by $260286s1%, stacking up to $260286u times][].    |cFFFFFFFFGenerates $s3 Focus.|r
    kill_command = {
        id = 259489,
        cast = 0,
        charges = function () return talent.alpha_predator.enabled and 2 or nil end,
        cooldown = 7.5,
        recharge = function () return talent.alpha_predator.enabled and 7.5 or nil end,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.intense_focus.enabled and -21 or -15 end,
        spendType = "focus",

        talent = "kill_command",
        startsCombat = true,
        cycle = function () return talent.bloodseeker.enabled and "kill_command" or nil end,

        usable = function () return pet.alive, "requires a living pet" end,
        handler = function ()
            removeBuff( "deadly_duo" )
            if debuff.pheromone_bomb.up then gainCharges( "kill_command", 1 ) end
            if debuff.shrapnel_bomb.up then applyDebuff( "target", "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end

            if talent.bloodseeker.enabled then
                applyBuff( "predator", 8 )
                applyDebuff( "target", "kill_command", 8 )
            end
            if talent.tip_of_the_spear.enabled then addStack( "tip_of_the_spear", nil, 1 ) end

            if set_bonus.tier30_4pc > 0 then
                applyDebuff( "target", "shredded_armor" )
                active_dot.shredded_armor = 1 -- Only applies to last target.
            end
        end,
    },

    -- Talent: You attempt to finish off a wounded target, dealing $s1 Physical damage. Only usable on enemies with less than $s2% health.
    kill_shot = {
        id = 320976,
        cast = 0,
        cooldown = function() return 10 - ( 1 - 0.25 * ( buff.coordinated_assault.up and talent.coordinated_kill.rank or 0 ) ) end,
        gcd = "spell",
        school = "physical",

        spend = 10,
        spendType = "focus",

        talent = "kill_shot",
        startsCombat = true,

        usable = function () return buff.flayers_mark.up or talent.coordinated_kill.enabled and buff.coordinated_assault.up or target.health_pct < 20, "requires target health below 20 percent" end,
        handler = function ()
            if buff.flayers_mark.up and legendary.pouch_of_razor_fragments.enabled then
                applyDebuff( "target", "pouch_of_razor_fragments" )
                removeBuff( "flayers_mark" )
            end
            if buff.coordinated_assault_empower.up then
                applyDebuff( "target", "bleeding_gash" )
                removeBuff( "coordinated_assault_empower" )
            end
        end,
    },


    masters_call = {
        id = 272682,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        startsCombat = false,
        texture = 236189,

        usable = function () return pet.alive, "requires a living pet" end,
        handler = function ()
            applyBuff( "masters_call" )
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
        startsCombat = false,

        usable = function () return pet.alive or group, "requires a living pet or ally" end,
        handler = function ()
            applyBuff( "misdirection" )
        end,
    },

    -- Talent: A brutal attack that deals $s1 Physical damage and grants you Mongoose Fury.    |cFFFFFFFFMongoose Fury|r  Increases the damage of Mongoose Bite by $259388s1% $?s385737[and the chance for Kill Command to reset by $259388s2% ][]for $259388d, stacking up to $259388u times. Successive attacks do not increase duration.
    mongoose_bite = {
        id = 259387,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function() return 30 - ( buff.bestial_barrage.up and 10 or 0 ) end,
        spendType = "focus",

        talent = "mongoose_bite",
        startsCombat = true,
        aura = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
        cycle = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,

        handler = function ()
            removeBuff( "bestial_barrage" )
            removeBuff( "tip_of_the_spear" )
            removeDebuff( "target", "latent_poison" )
            removeDebuff( "target", "latent_poison_injection" )

            if buff.spearhead.up then
                applyDebuff( "target", "spearhead_damage" )
                if talent.deadly_duo.enabled then addStack( "deadly_duo" ) end
            end

            if buff.mongoose_fury.down then applyBuff( "mongoose_fury" )
            else applyBuff( "mongoose_fury", buff.mongoose_fury.remains, min( 5, buff.mongoose_fury.stack + 1 ) ) end

            if debuff.shrapnel_bomb.up then
                if debuff.internal_bleeding.up then applyDebuff( "target", "internal_bleeding", 9, debuff.internal_bleeding.stack + 1 ) end
            end

            if azerite.wilderness_survival.enabled then
                gainChargeTime( "wildfire_bomb", 1 )
                if talent.wildfire_infusion.enabled then
                    gainChargeTime( "shrapnel_bomb", 1 )
                    gainChargeTime( "pheromone_bomb", 1 )
                    gainChargeTime( "volatile_bomb", 1 )
                end
            end

            if azerite.primeval_intuition.enabled then addStack( "primeval_intuition", nil, 1 ) end
            if azerite.blur_of_talons.enabled and buff.coordinated_assault.up then addStack( "blur_of_talons", nil, 1) end

            if legendary.butchers_bone_fragments.enabled then addStack( "butchers_bone_fragments", nil, 1 ) end
        end,

        copy = { 265888, "mongoose_bite_eagle" }
    },

    -- Talent: Interrupts spellcasting, preventing any spell in that school from being cast for $d.
    muzzle = {
        id = 187707,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "muzzle",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            if conduit.reversal_of_fortune.enabled then gain( conduit.reversal_of_fortune.mod, "focus" ) end
            interrupt()
        end,
    },


    pheromone_bomb = {
        id = 270323,
        known = 259495,
        cast = 0,
        charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
        cooldown = function() return ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste end,
        recharge = function() return talent.guerrilla_tactics.enabled and ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste or nil end,
        gcd = "spell",

        spend = function() return talent.coordinated_kill.enabled and buff.coordinated_assault.up and ( -5 * talent.coordinated_kill.rank ) or nil end,
        spendType = "focus",

        startsCombat = true,

        bind = "wildfire_bomb",
        talent = "wildfire_infusion",
        velocity = 35,

        usable = function () return current_wildfire_bomb == "pheromone_bomb" end,
        start = function ()
            removeBuff( "flame_infusion" )
        end,
        impact = function ()
            applyDebuff( "target", "pheromone_bomb" )
        end,

        copy = 270329,

        unlisted = true,
    },

    -- Talent: A vicious slash dealing $s1 Physical damage.
    raptor_strike = {
        id = 186270,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function() return 30 - ( buff.bestial_barrage.up and 10 or 0 ) end,
        spendType = "focus",

        talent = "raptor_strike",
        startsCombat = true,
        aura = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
        cycle = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
        indicator = function () return ( ( debuff.latent_poison_injection.down and active_dot.latent_poison_injection > 0 ) or ( debuff.latent_poison.down and active_dot.latent_poison > 0 ) ) and "cycle" or nil end,

        notalent = "mongoose_bite",

        handler = function ()
            removeBuff( "bestial_barrage" )
            removeBuff( "tip_of_the_spear" )
            removeDebuff( "target", "latent_poison" )
            removeDebuff( "target", "latent_poison_injection" )

            if debuff.shrapnel_bomb.up then
                applyDebuff( "target", "internal_bleeding", 9, debuff.internal_bleeding.stack + 1 )
            end

            if buff.spearhead.up then
                applyDebuff( "target", "spearhead_damage" )
                if talent.deadly_duo.enabled then addStack( "deadly_duo" ) end
            end

            if azerite.wilderness_survival.enabled then
                gainChargeTime( "wildfire_bomb", 1 )
                if talent.wildfire_infusion.enabled then
                    gainChargeTime( "shrapnel_bomb", 1 )
                    gainChargeTime( "pheromone_bomb", 1 )
                    gainChargeTime( "volatile_bomb", 1 )
                end
            end

            if azerite.primeval_intuition.enabled then
                addStack( "primeval_intuition", nil, 1 )
            end

            if azerite.blur_of_talons.enabled and buff.coordinated_assault.up then
                addStack( "blur_of_talons", nil, 1)
            end

            if legendary.butchers_bone_fragments.enabled then
                addStack( "butchers_bone_fragments", nil, 1 )
            end
        end,

        copy = { "raptor_strike_eagle", 265189 },
    },

    -- Talent: Fire a shot that poisons your target, causing them to take $s1 Nature damage instantly and an additional $o2 Nature damage over $d.$?s260241[    Serpent Sting fires arrows at $260241s1 additional $Lenemy:enemies; near your target.][]$?s378014[    Serpent Sting's damage applies Latent Poison to the target, stacking up to $378015u times. $@spelldesc393949 consumes all stacks of Latent Poison, dealing $378016s1 Nature damage to the target per stack consumed.][]
    serpent_sting = {
        id = 271788,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 10,
        spendType = "focus",

        talent = "serpent_sting",
        startsCombat = true,
        cycle = "serpent_sting",

        velocity = 60,

        impact = function ()
            applyDebuff( "target", "serpent_sting" )
            if talent.hydras_bite.enabled then
                active_dot.serpent_sting = min( true_active_enemies, active_dot.serpent_sting + 2 )
            end
            if talent.poison_injection.enabled or azerite.latent_poison.enabled then applyDebuff( "target", "latent_poison", nil, debuff.latent_poison.stack + 1 ) end
            if legendary.latent_poison_injectors.enabled then applyDebuff( "target", "latent_poison_injection", nil, debuff.latent_poison_injection.stack + 1 ) end
        end,
    },

    -- Hurl a bomb at the target, exploding for $270338s1 Fire damage in a cone and impaling enemies with burning shrapnel, scorching them for $270339o1 Fire damage over $270339d.    $?s259387[Mongoose Bite][Raptor Strike] and $?s212436[Butchery][Carve] apply Internal Bleeding, causing $270343o1 damage over $270343d. Internal Bleeding stacks up to $270343u times.
    shrapnel_bomb = {
        id = 270335,
        known = 259495,
        cast = 0,
        charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
        cooldown = function() return ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste end,
        recharge = function() return talent.guerrilla_tactics.enabled and ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste or nil end,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.coordinated_kill.enabled and buff.coordinated_assault.up and ( -5 * talent.coordinated_kill.rank ) or nil end,
        spendType = "focus",

        startsCombat = true,
        bind = "wildfire_bomb",
        talent = "wildfire_infusion",
        velocity = 35,

        usable = function () return current_wildfire_bomb == "shrapnel_bomb" end,
        start = function ()
            removeBuff( "flame_infusion" )
        end,
        impact = function ()
            applyDebuff( "target", "shrapnel_bomb" )
        end,

        copy = 270338,
        unlisted = true,
    },

    -- Talent: You and your pet charge your enemy, striking them for $378957s1 Physical damage. You then become one with your pet for $d. While active, your pet damage is increased by $s1%, Raptor Strike and Mongoose Bite deal an additional $s2% damage over 4 sec, and Kill Command has a $s3% increased chance to reset.$?s378962[    While Spearhead is active, the Focus cost of Raptor Strike and Mongoose Bite is reduced by $s4, and Kill Command cooldown resets extend the duration of Spearhead by ${$m5/1000}.1 sec.][]
    spearhead = {
        id = 360966,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "physical",

        talent = "spearhead",
        startsCombat = true,
        toggle = "cooldowns",

        handler = function ()
            setDistance( 5 )
            applyBuff( "spearhead" )
        end,
    },


    volatile_bomb = {
        id = 271045,
        known = 259495,
        cast = 0,
        charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
        cooldown = function() return ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste end,
        recharge = function() return talent.guerrilla_tactics.enabled and ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste or nil end,
        gcd = "spell",

        spend = function() return talent.coordinated_kill.enabled and buff.coordinated_assault.up and ( -5 * talent.coordinated_kill.rank ) or nil end,
        spendType = "focus",

        startsCombat = true,
        bind = "wildfire_bomb",
        talent = "wildfire_infusion",
        velocity = 35,

        usable = function () return current_wildfire_bomb == "volatile_bomb" end,

        start = function ()
            removeBuff( "flame_infusion" )
        end,
        impact = function ()
            applyDebuff( "target", "volatile_bomb" )
            if debuff.serpent_sting.up then
                applyDebuff( "target", "serpent_sting" )
                active_dot.serpent_sting = min( true_active_enemies, active_dot.serpent_sting + 2 )
            end
        end,

        copy = 271048,

        unlisted = true,
    },

    -- Talent: Hurl a bomb at the target, exploding for $265157s1 Fire damage in a cone and coating enemies in wildfire, scorching them for $269747o1 Fire damage over $269747d.
    wildfire_bomb = {
        id = function ()
            if current_wildfire_bomb == "wildfire_bomb" then return 259495
            elseif current_wildfire_bomb == "pheromone_bomb" then return 270323
            elseif current_wildfire_bomb == "shrapnel_bomb" then return 270335
            elseif current_wildfire_bomb == "volatile_bomb" then return 271045 end
            return 259495
        end,
        flash = { 270335, 270323, 271045, 259495 },
        known = 259495,
        cast = 0,
        charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
        cooldown = function() return ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste end,
        recharge = function() return talent.guerrilla_tactics.enabled and ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste or nil end,
        gcd = "spell",
        school = "physical",

        talent = "wildfire_bomb",
        startsCombat = true,
        bind = function () return current_wildfire_bomb end,
        velocity = 35,

        start = function ()
            removeBuff( "flame_infusion" )
            removeBuff( "coordinated_assault_empower" )
        end,

        impact = function ()
            if current_wildfire_bomb == "wildfire_bomb" then
                applyDebuff( "target", "wildfire_bomb_dot" )
            else class.abilities[ current_wildfire_bomb ].impact() end
            current_wildfire_bomb = "wildfire_bomb"
        end,

        impactSpell = function ()
            if not talent.wildfire_infusion.enabled then return "wildfire_bomb" end
            if IsActiveSpell( 270335 ) then return "shrapnel_bomb" end
            if IsActiveSpell( 270323 ) then return "pheromone_bomb" end
            if IsActiveSpell( 271045 ) then return "volatile_bomb" end
            return "wildfire_bomb"
        end,

        impactSpells = {
            wildfire_bomb = true,
            shrapnel_bomb = true,
            pheromone_bomb = true,
            volatile_bomb = true
        },

        copy = { 259495, 265157 }
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "spectral_agility",

    package = "Survival"
} )


spec:RegisterSetting( "use_harpoon", true, {
    name = "|T1376040:0|t Use Harpoon",
    desc = "If checked, the addon will recommend |T1376040:0|t Harpoon when you are out of range and Harpoon is available.",
    type = "toggle",
    width = 1.49
} )

spec:RegisterSetting( "allow_focus_overcap", false, {
    name = "Allow Focus Overcap",
    desc = "The default priority tries to avoid overcapping Focus by default.  In simulations, this helps to avoid wasting Focus.  In actual gameplay, this can " ..
        "result in trying to use Focus spenders when other important buttons (Wildfire Bomb, Kill Command) are available to push.  On average, enabling this feature " ..
        "appears to be DPS neutral vs. the default setting, but has higher variance.  Your mileage may vary.\n\n" ..
        "The default setting is |cFFFFD100unchecked|r.",
    type = "toggle",
    width = 1.49
} )

-- TODO: If this approach isn't sufficient, I'll need to check for pet Basic Attack abilities being set to manual.
spec:RegisterSetting( "manual_kill_shot", false, {
    name = strformat( "%s: %s Macro", Hekili:GetSpellLinkWithTexture( spec.auras.coordinated_assault.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.kill_shot.id ) ),
    desc = strformat( "During |W%s|w, some guides recommend using a macro to manually control your pet's attacks to empower |W%s|w.  These macros prevent the |W%s|w empowerment "
        .. "from occurring naturally, which will prevent |W%s|w from being recommended.\n\n"
        .. "Enabling this option will allow |W%s|w to be recommended during %s without the empowerment buff active.", spec.auras.coordinated_assault.name, spec.abilities.kill_shot.name,
        spec.auras.coordinated_assault_empower.name, spec.abilities.kill_shot.name, spec.abilities.kill_shot.name, spec.auras.coordinated_assault.name ),
    type = "toggle",
    width = 1.49
} )

spec:RegisterStateExpr( "coordinated_assault_kill_shot", function()
    return ( settings.manual_kill_shot or false ) and buff.coordinated_assault.up
end )


spec:RegisterPack( "Survival", 20230702, [[Hekili:TZX2UnUn2VLGIXJDBIJTY1PiXaTtb2TDx0x8UyFZYms02QrwsvIkzsHH)23dj1fskskjhpjZcSVmJJi1HhEUFHulMU4FTyUpIGx87otCUyYntCg74a)4tlMtEjbVyEcY7r0A4hrOTW)opp9PGNqH0bEjmg5tbqwCEQhm43TF5gcjj7hp)81bKn5pm2lE75zbBZdrKG4iVu0kc9V9oFX8hYdcj)A0Ih0Ja3UyokNSjofwZGTFEX8nb((y(0XzElMtN(ztU5Sjo)4(L)NGq)vbP49l)54TpSFzq0(LEHy0tWtcY2VewZKWGvby)9l9trBb0Xdfg(Y49)2(FJdPRpZ5kas)62K4uY(LagJZG)ppHIDaigge5fM7t)zEga24v7x(l)bknppAKayU6mNPay(hbHH7xoFtmaITXprx3nbR3Gt54wsAqCAa5fPxCkDN8tWUeMCgMqcIwVFjjUy9eHOFEkBWphhN6hebii8k)uwgkpegDvCk9FcFKHQSjkHoiV04mPvEYTWk)3b8RgZkFNphVDlkYxMKMTjopeE2dygY5xSMeu6AmbwvYgeSqpZaqya9ncJPObokoNUi0nfWdi4ub04YZCUgqJ)nJGdqmnElGYvcpFMk8mEX8WGmsgtSfVIUFHF(7mXyKhDAlMVn)V(RqqAehHEie7V4NxqaHlXzqsrr)ji(f8xaXXf2meLzFbD21pP6fPYmU8)WLIhCSXLRA45NrF3lvExpGAItdqCO8e2fhH3gqfJUB)YlaLhsAGhHUh62Ya)jm7R68QmB)sN(VkConDLUwKYHs9qryxsCAkosHQrQERsoIw87H8vRa7cvcUUiUCRlg08EgKiYt2VCavykewIXpeK6N5gVYnjf)Y4ciUF5UDG0OgG8iiZvWrlX56hPkh8CHvd3haJg6ebkNOpgr246Tb9iy7qzIxkoXmcABc2xv6Zm3c2dH(XphnEvE6l0TjzdW7qRdXJtXBrbrz896jveKMtSeW1C2MeMgCs8xscJZOskAK)VPD8vI2bifqJtXafcSa4sc2IzcEzjy45vMfoNjkwl)LYLWU14QPdSGwZAp)XBrFHtz8JjJZ2KIsIWHCKbST)iZQhifnKpHGiaIriycHymqAwpg4uEpYGMJj4uXaexYr1BGhYjEGf9xO7HpPSh4Ar(C)dUjGiikTIRf6JtDxfYMsLiwRtLQ9orKf2qsqHlo1SsOrIMg2ZuhZ8NyVCG(8dGUicmDKIxJJyKl2aucMa2gIIEKzVfmf9ihYQ2zRH8qMiFe(le3Nd4yyj(QQqujjgeTcC3fhvBLWaZAQQn6kxhGxQ44mqOgWdj6fMz2IguqeXnjoidwMcriqohcwX7fW4xPOo1(hDDu17lxhyJaMqlPeV(15AdRdZ0Nh3dE)4BmLh7QFgWLBefr5crkILM13bMQj3dGBbdM0NQQ71N9POPBmOlaHgKW8tiPPb2XqPBWq0UkrvOQH1QGeB7vbUstm6jLoQkEvOdonHkFKryAS1qpfVkfNTH(cf(qPWBmLZb(SD9d4MLN6uABSwl6PGeCAM7tqiABLDZwmHnVaboNX2qskyAXCZk29HLOXKHtxvD1HvDvDu37k58ufXAehKF2Hfeel4hkrxroP8X18R6XQygdehxhWBeOWdHXX(Uu)ivXgPfDlGj8xBzXIHJwd5eUL(mXvVG3kBhHlcXKdJZjzb(yWlwfgaMwsIHFOjO7V5OwOipiLWuikcAOZlSgR)3iOm1ViJjxffA5iHq2EKm3)i3F92gHY)7Qou0eaOOVftX)v5POsGdTMfXcKmYJz2J08DLcwScXzzCbBkXYvmEqi0L6nfy4eNYIEQmA2kRs6Yf1S)Qc9elRRZvcB(3lQt9(ljM9)vHMQX4kke2sGCHBcJwaXYbYd5GH64vRCbbewoP8WL1o1AQdvAQIwmtiM8Z2VCY4P8nyrHtYgdJo)LipTbcxXEqrbEURtdWRahaEBmHynNxpWkovTb)qBO1LigfnGfyBgVAxPbj8Nppy7(LpZl(srvOwTF5F7Z)Y(L)roTCvOveAnMypHw4RGONIFe7FkfbGHdi8hJE(XNrP(8kXazwNbCC6KpBnSFhRlKSgOUzZ1fsX(bqGRGjtGQC)(LxliraWYJiN5cZTzgrNxZ2cM1Q8Cra1qUdyAH1CrPBJtfs(JZFQmQ1iYSYme)(wc7TvFN6rV(SWTVFaPpbxRYv3WQd22dktkuqJMomVDQrl5APOXjA1eBnJyzX02QpI9Tq3tzNyREo1us(2q2nPi1DMe1fmwmDszu5vKrjALPccjpPQn7iDPVy11ENQm3Hw4nZo6HnCkkW3f)eD3G89ZghWPp9OytNjt4A)foF)Ylgdoth1n1QswJHuIvuufe0OiayPnaiFMuw05PvIxBhuwdfW24wS0mQsitL1G)cT(78SlftReGXnLutWhmq4JazBcGSxmX9Yepl2LuRhqBg8BRQG1zI0wbogwqDavi)WxC9ZJf45oAdKQIOnGxYWKn40yi5tSsndnKzSASFTTx7HenTDc9ZFrL)pDmmdbUyTIfnccS9cFOp)DDbTvdl67i2IJ7l3hwcCUqI4Cgt)jeahaUJ3(GBAgq3PHoDMSWYOMQ0S9qfIsD0iPJjpIMQhBB3AoaIdROyMD2)2t9wyOslelLI91wJRBusNrx9TmieB27oxigdjPql(tkAnwsaqEer6xtfZHwTUsL2u5tZy8PclZwmlBWz6LtmHOhWwqOcdnAcbXsbPBp6QMro3AA6Th4NyK2wA0gSlVQxXbo1CunfifkmzdI27sFei430V9Hyn51Pmk6vtpZEqtzpQncBwVS0cVw9elilPPfrFsSCkgAVQJz3odnvsdQ1sj2rHDeW7uizZ4epcpUOjcARwcfWwICTw3LrsYXwXYV6iYOoADYGvMpnrkZdn6UmgwFZX)OgYxTPaz5nJDCxzAIPy91PVnhIBll9C5Dp9QUK1KLeeA00N6TwhAKDdRvn6d03qukJrIZ1iPBxzqkEyh6wwSDrrXs8h24tMC7BVDOQ(aniF3QV2uu0ALCJpy7yo3kTvvoTmu0XSlp(II)Z8GeWz14wJKOQOkCrgHrCVCYT36mvQ(Y044gzXJ11xvmiNMKt2eIZYC3Isr5(VAYt3IZCulXh6yknyJckVY6Qv0zanvLqNO2fM6LrhAu8ftLdyP6qfihYYfMZ37D3gKn7m2kVSPtn5HFkumqIn7oORX6PEGiUCsBXSqwmhII3JwcUMh50S8TGKRBcwTpQMIeqBNUK70tekjJDEDPYd8q(yhmycIQ)9aEvm94oZri6FVMzGGDuDbe9SK4IdqmTDp(Xr0U6yUlBKMDhGUBPSfkTAXChTY0KMvVpoHgNdjyv9luMIc7xfNV06Sv0yixYkqDuppHcZPgoZQo2CJLuihZbhBAvZqgwSzuWoFccSIIF8dE(1G)L5pJsJOnpCX8)1gG4guCwWzhU5pwX()iWtOw3tz8JyQcekNeVLFmSbflWne98v)pdIGHU8hPhI6iy1yd)rD7XpYBeN2Xk3)WCgo9l8JAUgSZZpRF41u94vvwbk4uJSfQXhRWtJ2KcKTKFV6ACXrgNnaVJkoBG)FW4Sb4DuX5BoY4Sb4DuX5pDKXzdW7iHZA1HZ6PPLJTkSZrgEhB1vdI(ncXubUglmyhH)bJVxPhEsnSvbMABMBhvNQ7pOcqB24W3CigNGtzxJNm(nj6JdBgM7SohX6zd78u)aey7ObwYmE2KbdB(A3589f1Ly3oJ75bN41HE4AdawASJ5XkGBnkoA3Ut0NO2aHiDV7Mrd0LdujR9TIJC()NJ0ghP2c)0wuJKlsZ9thqBI3aPg4DhlDQpmutNcoRoXRr1uxTfLzG5MsCxXBwki1zC683aCQMuEXBoP8RhbryBzWPLyHJvmERRMYQMVNE9x1WFSVihnh6tn4xtURCkqxFl7Ad0neNScnDsU2LN7NKxHcJ2g8nqvCSt7)deJ7SeD)W46qwN0UCkT8pwesfRouJiIna(doKW)NdFnKJHspXuvq13XSga3qchVsBxoTzP)nkqhEON2IKPCZ9gHqN3ocvteV6BjIOUOKgm8eJLPULWlzMM(HARq3vvX5D7KT1mB6O3fM076gUwiWG)tEN2uunLB)wdLYBnak1guPcvtnWsDbUW5BjbwZCQ3fXjlOtnbSdvw8GCnPVE1SpveF8yuVlPprekyN2pFeQIogQtZrlm02cvSZmZzzIFqf(GtjcDGa4ChZPhvUjRGy5TRxHi0y83AN9gaRW1vwbQAUiZIYQ8paquqDvzZMPFeBGu3HHPTflEvqyv)LYgx1wOF4(ZR7d4(F772V843dV9)MULT82IDkT3A3RP)E6FT6g5DQyZ(U3r)0ldKNVk1rZFACY9So(DkRZB3BSXBNw3aV7n2)Ut9IJ8dOdEFb)scquoubYbOe)6vk(KMFAFehv9tEdFR45N1(KG)N)n05(PNgS6EzNM3Dr7aGBWZcqM5ice5V0ocB7Xa6cJxF1TPqYsvRktSQksF6Jorn()bNOXCEbqux6n87SnDDlEjI5lgop0dX4nuVm4QGx(Aw)MV7OgZye338vw5kz3GJlE3PPixLv)wUk2ZGG7BaSQ7S8x9TjaHML7A6fQyKIUCXt5xWyUOwA5DJwbwoxvGKFT2bQivR2Bpv4AeZv1fULWZkY16SjJNUBN69v2(APErK78cn4KgebUlQ3KluSPnftmwhMPyriRXfgwqIO8Egp7(RLmtYS3cVD19IXMKUWDCCGUqh3Tt3lvbAnlRuOyAgxQtFAgV8SURzinOIK9aJxXHA5(gtrZYiFOh1Hh0VUpsRC)I)8doAaA5hQjkC1uQcqME3oJN63bdT81(6ohDVPqddgPbDK1)A)SC2ecDHuxrjn)1mtdGLRYgJGzmp)wO0dpr73ARAbMgX5RJyjfQ2PsNDpU1jZFFRMDRg4jfE4raEIok1boZKpDvnt2TQeRSnZqNyXFLwBbvrQ3xMCLD1dHDPyzU8yiRzveVzd6GKWnCyqZBS3SPodgEIMS(Q6uRqsB6e8ETQcwPe9vWSD8t0pvgPdcMnIwXs5(UB6apJxciEPEvwDjR2AxU2aO9YpQSCsE(SZQQ4)cXPzgxuwNEA6MPxAY9yterzXQEE9gIpUPtQ(SQn5ztNmOUGEA)MpuBhwA4r6eJ6rOoDoQg9IjVvNyKx1z4rZH94GpLihHthYR7KH0tZg6DAzPBadgY2fQFpeM50ijQYwZA(BGGwHtliBNfhU7I2m5aMa12af1un0B3q2zqhCdQ)TOJ2Pt9rN6Q)HDeySzFOBXGWEpz3Dh99MQP0xzWe3mqxOeklsdl81mALlh)anpTCpYLehAqJwtV12TZGYVgtPxor3s3be617h0w1Cm5ICq75FE3vTP0uaC5ZGYbE2t6KSxVo3jQYqhwuNCH8gP3ZESHu7hQR6uuT5bnUeG35aodnyOZsCCAkj2OkEDJv9iTaJSO6OrH4tt6RpLdWbyTuS(BhUqnuKNGkU1lZyDWIvJWVEtJ(Yu4vTPq3HcA8nWU7984wyLcAkPCvJHkarU0Dcgw5hsJ(P25CRkoQ155Wt6(vEML4bNbz(6odoahPX(21xvwH2gNnKESVS52T3SKENVhRU)TfDFhlYqMCVC)MsVYSguFnK3v)QgCGA2)PyvOOxdyAVgOFJiUIDlrx8F)d]] )