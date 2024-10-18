-- HunterSurvival.lua
-- July 2024

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local floor = math.floor
local strformat = string.format

local spec = Hekili:NewSpecialization( 255 )

local GetSpellBookItemName = function(index, bookType)
    local spellBank = (bookType == BOOKTYPE_SPELL) and Enum.SpellBookSpellBank.Player or Enum.SpellBookSpellBank.Pet;
    return C_SpellBook.GetSpellBookItemName(index, spellBank);
end

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
    binding_shackles           = { 102388, 321468, 1 }, -- Targets stunned by Binding Shot, knocked back by High Explosive Trap, knocked up by Implosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal 10% less damage to you for 8 sec after the effect ends.
    binding_shot               = { 102386, 109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within 5 yds for 10 sec, stunning them for 3 sec if they move more than 5 yds from the arrow.
    blackrock_munitions        = { 102392, 462036, 1 }, -- The damage of Explosive Shot is increased by 8%.
    born_to_be_wild            = { 102416, 266921, 1 }, -- Reduces the cooldowns of Aspect of the Eagle, Aspect of the Cheetah, and Aspect of the Turtle by 30 sec.
    bursting_shot              = { 102421, 186387, 1 }, -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by 50% for 6 sec, and dealing 575 Physical damage.
    camouflage                 = { 102414, 199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for 1 min. While camouflaged, you will heal for 2% of maximum health every 1 sec.
    concussive_shot            = { 102407, 5116  , 1 }, -- Dazes the target, slowing movement speed by 50% for 6 sec. Steady Shot will increase the duration of Concussive Shot on the target by 3.0 sec.
    devilsaur_tranquilizer     = { 102415, 459991, 1 }, -- If Tranquilizing Shot removes only an Enrage effect, its cooldown is reduced by 5 sec.
    disruptive_rounds          = { 102395, 343244, 1 }, -- When Tranquilizing Shot successfully dispels an effect or Muzzle interrupts a cast, gain 10 Focus.
    emergency_salve            = { 102389, 459517, 1 }, -- Feign Death and Aspect of the Turtle removes poison and disease effects from you.
    entrapment                 = { 102403, 393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for 4 sec. Damage taken may break this root.
    explosive_shot             = { 102420, 212431, 1 }, -- Fires an explosive shot at your target. After 3 sec, the shot will explode, dealing 34,916 Fire damage to all enemies within 8 yds. Deals reduced damage beyond 5 targets.
    ghillie_suit               = { 102385, 459466, 1 }, -- You take 20% reduced damage while Camouflage is active. This effect persists for 3 sec after you leave Camouflage.
    high_explosive_trap        = { 102739, 236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 5,110 Fire damage and knocking all enemies away. Limit 1. Trap will exist for 1 min.
    hunters_avoidance          = { 102423, 384799, 1 }, -- Damage taken from area of effect attacks reduced by 5%.
    implosive_trap             = { 102739, 462031, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 5,110 Fire damage and knocking all enemies up. Limit 1. Trap will exist for 1 min.
    improved_kill_shot         = { 102410, 343248, 1 }, -- Kill Shot's critical damage is increased by 25%.
    improved_traps             = { 102418, 343247, 1 }, -- The cooldown of Tar Trap, High Explosive Trap, Implosive Trap, and Freezing Trap is reduced by 5.0 sec.
    intimidation               = { 102397, 19577 , 1 }, -- Commands your pet to intimidate the target, stunning it for 5 sec.
    keen_eyesight              = { 102409, 378004, 2 }, -- Critical strike chance increased by 2%.
    kill_shot                  = { 102379, 320976, 1 }, -- You attempt to finish off a wounded target, dealing 43,631 Physical damage. Only usable on enemies with less than 20% health.
    kindling_flare             = { 102425, 459506, 1 }, -- Stealthed enemies revealed by Flare remain revealed for 3 sec after exiting the flare.
    kodo_tranquilizer          = { 102415, 459983, 1 }, -- Tranquilizing Shot removes up to 1 additional Magic effect from up to 2 nearby targets.
    lone_survivor              = { 102391, 388039, 1 }, -- Reduce the cooldown of Survival of the Fittest by 30 sec, and increase its duration by 2.0 sec. Reduce the cooldown of Counter Shot and Muzzle by 2 sec.
    misdirection               = { 102419, 34477 , 1 }, -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within 30 sec and lasting for 8 sec.
    moment_of_opportunity      = { 102426, 459488, 1 }, -- When a trap triggers, you gain Aspect of the Cheetah for 3 sec. Can only occur every 1 min.
    muzzle                     = { 79837, 187707, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for 3 sec.
    natural_mending            = { 102401, 270581, 1 }, -- Every 10 Focus you spend reduces the remaining cooldown on Exhilaration by 1.0 sec.
    no_hard_feelings           = { 102412, 459546, 1 }, -- When Misdirection targets your pet, it reduces the damage they take by 50% for 5 sec.
    padded_armor               = { 102406, 459450, 1 }, -- Survival of the Fittest gains an additional charge.
    pathfinding                = { 102404, 378002, 1 }, -- Movement speed increased by 4%.
    posthaste                  = { 102411, 109215, 1 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by 50% for 4 sec.
    quick_load                 = { 102413, 378771, 1 }, -- When you fall below 40% health, Bursting Shot and Scatter Shot have their cooldown immediately reset. This can only occur once every 25 sec.
    rejuvenating_wind          = { 102381, 385539, 1 }, -- Maximum health increased by 8%, and Exhilaration now also heals you for an additional 12.0% of your maximum health over 8 sec.
    roar_of_sacrifice          = { 102405, 53480 , 1 }, -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but 10% of all damage taken by that target is also taken by the pet. Lasts 12 sec.
    scare_beast                = { 102382, 1513  , 1 }, -- Scares a beast, causing it to run in fear for up to 20 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time.
    scatter_shot               = { 102421, 213691, 1 }, -- A short-range shot that deals 397 damage, removes all harmful damage over time effects, and incapacitates the target for 4 sec. Any damage caused will remove the effect. Turns off your attack when used.
    scouts_instincts           = { 102424, 459455, 1 }, -- You cannot be slowed below 80% of your normal movement speed while Aspect of the Cheetah is active.
    scrappy                    = { 102408, 459533, 1 }, -- Casting Wildfire Bomb reduces the cooldown of Intimidation and Binding Shot by 0.5 sec.
    serrated_tips              = { 102384, 459502, 1 }, -- You gain 5% more critical strike from critical strike sources.
    specialized_arsenal        = { 102390, 459542, 1 }, -- Wildfire Bomb deals 10% increased damage.
    survival_of_the_fittest    = { 102422, 264735, 1 }, -- Reduces all damage you and your pet take by 30% for 6 sec.
    tar_trap                   = { 102393, 187698, 1 }, -- Hurls a tar trap to the target location that creates a 8 yd radius pool of tar around itself for 30 sec when the first enemy approaches. All enemies have 50% reduced movement speed while in the area of effect. Limit 1. Trap will exist for 1 min.
    tarcoated_bindings         = { 102417, 459460, 1 }, -- Binding Shot's stun duration is increased by 1 sec.
    territorial_instincts      = { 102394, 459507, 1 }, -- Casting Intimidation without a pet now summons one from your stables to intimidate the target. Additionally, the cooldown of Intimidation is reduced by 5 sec.
    trailblazer                = { 102400, 199921, 1 }, -- Your movement speed is increased by 30% anytime you have not attacked for 3 sec.
    tranquilizing_shot         = { 102380, 19801 , 1 }, -- Removes 1 Enrage and 1 Magic effect from an enemy target.
    trigger_finger             = { 102396, 459534, 2 }, -- You and your pet have 5.0% increased attack speed. This effect is increased by 100% if you do not have an active pet.
    unnatural_causes           = { 102387, 459527, 1 }, -- Your damage over time effects deal 10% increased damage. This effect is increased by 50% on targets below 20% health.
    wilderness_medicine        = { 102383, 343242, 1 }, -- Mend Pet heals for an additional 25% of your pet's health over its duration, and has a 25% chance to dispel a magic effect each time it heals your pet.

    -- Beast Mastery
    alpha_predator             = { 102259, 269737, 1 }, -- Kill Command now has 2 charges, and deals 15% increased damage.
    bloodseeker                = { 102270, 260248, 1 }, -- Kill Command causes the target to bleed for 4,434 damage over 8 sec. You and your pet gain 10% attack speed for every bleeding enemy within 12 yds.
    bloody_claws               = { 102268, 385737, 1 }, -- Each stack of Mongoose Fury increases the chance for Kill Command to reset by 2%. Kill Command extends the duration of Mongoose Fury by 1.5 sec.
    bombardier                 = { 102273, 389880, 1 }, -- When you cast Coordinated Assault, you gain 2 charges of Wildfire Bomb. When Coordinated Assault ends, your next 2 Explosive Shots are free and have no cooldown.
    butchery                   = { 102290, 212436, 1 }, -- Attack all nearby enemies in a flurry of strikes, inflicting 20,070 Physical damage to each. Deals reduced damage beyond 5 targets.
    contagious_reagents        = { 102276, 459741, 1 }, -- Reapplying Serpent Sting to a target also spreads it to up to 2 nearby enemies.
    coordinated_assault        = { 102252, 360952, 1 }, -- You and your pet charge your enemy, striking them for a combined 34,905 Physical damage. You and your pet's bond is then strengthened for 20 sec, causing you and your pet to deal 20% increased damage. While Coordinated Assault is active, Kill Command's chance to reset its cooldown is increased by 15%.
    deadly_duo                 = { 102284, 378962, 1 }, -- The cooldown of Spearhead is reduced by 30 sec and Spearhead's bleed now increases your critical strike damage against the target by 30%.
    explosives_expert          = { 102281, 378937, 2 }, -- Wildfire Bomb cooldown reduced by 2.0 sec.
    exposed_flank              = { 102271, 459861, 1 }, -- Your Flanking Strike now strikes 2 additional nearby targets at 100% effectiveness, and exposes a weakness in your enemy's defenses, causing your Kill Command to hit 2 additional nearby enemies for 10 sec.
    flankers_advantage         = { 102283, 459964, 1 }, -- Kill Command has an additional 10% chance to immediately reset its cooldown. Tip of the Spear's damage bonus is increased up to 30%, based on your critical strike chance.
    flanking_strike            = { 102278, 269751, 1 }, -- You and your pet leap to the target and strike it as one, dealing a total of 39,625 Physical damage. Tip of the Spear grants an additional 15% damage bonus to Flanking Strike and Flanking Strike generates 2 stacks of Tip of the Spear.
    frenzy_strikes             = { 102286, 294029, 1 }, -- Butchery reduces the remaining cooldown on Wildfire Bomb by 1.0 sec for each target hit, up to 5.
    fury_of_the_eagle          = { 102275, 203415, 1 }, -- Furiously strikes all enemies in front of you, dealing 124,382 Physical damage over 3.2 sec. Critical strike chance increased by 50% against any target below 20% health. Deals reduced damage beyond 5 targets. Kill Command cooldown resets reduce the cooldown of Fury of the Eagle by 3.0 sec.
    grenade_juggler            = { 102287, 459843, 1 }, -- Wildfire Bomb deals 5% increased damage and has a 25% chance to also cast an Explosive Shot at your target at 100% effectiveness. Explosive Shot reduces the cooldown of Wildfire Bomb by 2 sec.
    guerrilla_tactics          = { 102285, 264332, 1 }, -- Wildfire Bomb now has 2 charges, and the initial explosion deals 50% increased damage.
    improved_wildfire_bomb     = { 102274, 321290, 1 }, -- Wildfire Bomb deals 8% additional damage.
    kill_command               = { 102255, 259489, 1 }, -- Give the command to kill, causing your pet to savagely deal 10,905 Physical damage to the enemy. Kill Command has a 10% chance to immediately reset its cooldown. Generates 15 Focus.
    killer_companion           = { 102282, 378955, 2 }, -- Kill Command damage increased by 10%.
    lunge                      = { 102272, 378934, 1 }, -- Auto-attacks with a two-handed weapon reduce the cooldown of Wildfire Bombs by 1.0 sec.
    merciless_blows            = { 102267, 459868, 1 }, -- Casting Butchery makes your next Raptor Strike or Mongoose Bite hit 3 targets.
    mongoose_bite              = { 102257, 259387, 1 }, -- A brutal attack that deals 22,034 Physical damage and grants you Mongoose Fury. Mongoose Fury Increases the damage of Mongoose Bite by 15% for 15 sec, stacking up to 5 times.
    outland_venom              = { 102269, 459939, 1 }, -- Each damage over time effect on a target increases the critical strike damage they receive from you by 2%.
    quick_shot                 = { 102279, 378940, 1 }, -- When you cast Kill Command, you have a 30% chance to fire an Arcane Shot at your target at 100% of normal value.
    ranger                     = { 102288, 385695, 1 }, -- Kill Shot, Serpent Sting, Arcane Shot, Steady Shot, and Explosive Shot deal 20% increased damage.
    raptor_strike              = { 102262, 186270, 1 }, -- A vicious slash dealing 27,051 Physical damage.
    relentless_primal_ferocity = { 102258, 459922, 1 }, -- Coordinated Assault sends you and your pet into a state of primal power. For the duration of Coordinated Assault, Kill Command generates 1 additional stack of Tip of the Spear, you gain 10% Haste, and Tip of the Spear's damage bonus is increased by 50%.
    ruthless_marauder          = { 102261, 385718, 2 }, -- Fury of the Eagle now gains bonus critical strike chance against targets below 35% health, and Fury of the Eagle critical strikes reduce the cooldown of Wildfire Bomb and Flanking Strike by 1.0 sec.
    sic_em                     = { 102280, 459920, 1 }, -- Casting Kill Command has a 15% chance to reset the cooldown of Kill Shot, make it usable on targets regardless of Health, and strike up to 2 additional targets. This chance is doubled during Coordinated Assault.
    spearhead                  = { 102291, 360966, 1 }, -- You give the signal, and your pet charges your target, bleeding them for 32,723 damage over 10 sec and increasing your chance to critically strike your target by 30% for 10 sec.
    sulfurlined_pockets        = { 102266, 459828, 1 }, -- Every 3 Quick Shots is replaced with an Explosive Shot at 100% effectiveness.
    sweeping_spear             = { 102289, 378950, 2 }, -- Raptor Strike, Mongoose Bite, and Butchery damage increased by 10%.
    symbiotic_adrenaline       = { 102258, 459875, 1 }, -- The cooldown of Coordinated Assault is reduced by 60 sec and Coordinated Assault now grants 3 stacks of Tip of the Spear.
    tactical_advantage         = { 102277, 378951, 1 }, -- Damage of Flanking Strike increased by 5% and all damage dealt by Wildfire Bomb increased by 5%.
    terms_of_engagement        = { 102256, 265895, 1 }, -- Harpoon has a 10 sec reduced cooldown, and deals 5,454 Physical damage and generates 20 Focus over 10 sec. Killing an enemy resets the cooldown of Harpoon.
    tip_of_the_spear           = { 102263, 260285, 1 }, -- Kill Command increases the direct damage of your other spells by 15%, stacking up to 3 times.
    vipers_venom               = { 102260, 268501, 1 }, -- Raptor Strike and Mongoose Bite apply Serpent Sting to your target. Serpent Sting Fire a poison-tipped arrow at an enemy, dealing 2,923 Nature damage instantly and an additional 23,397 damage over 12 sec.
    wildfire_bomb              = { 102264, 259495, 1 }, -- Hurl a bomb at the target, exploding for 8,508 Fire damage in a cone and coating enemies in wildfire, scorching them for 17,016 Fire damage over 6 sec. Deals reduced damage beyond 8 targets. Deals 40% increased damage to your primary target.
    wildfire_infusion          = { 102265, 460198, 1 }, -- Mongoose Bite and Raptor Strike have a 10% chance to reset Kill Command's cooldown. Kill Command reduces the cooldown of Wildfire Bomb by 0.5 sec.

    -- Pack Leader
    beast_of_opportunity       = { 94979, 445700, 1 }, -- Coordinated Assault calls on the pack, summoning a pet from your stable for 6 sec.
    cornered_prey              = { 94984, 445702, 1 }, -- Disengage increases the range of all your attacks by 5 yds for 5 sec.
    covering_fire              = { 94969, 445715, 1 }, -- Wildfire Bomb reduces the cooldown of Butchery by 2 sec.
    cull_the_herd              = { 94967, 445717, 1 }, -- Kill Shot deals an additional 30% damage over 6 sec and increases the bleed damage you and your pet deal to the target by 25%.
    den_recovery               = { 94972, 445710, 1 }, -- Aspect of the Turtle, Survival of the Fittest, and Mend Pet heal the target for 20% of maximum health over 4 sec. Duration increased by 1 sec when healing a target under 50% maximum health.
    frenzied_tear              = { 94988, 445696, 1 }, -- Your pet's Basic Attack has a 20% chance to reset the cooldown and cause Kill Command to strike a second time for 30% of normal damage.
    furious_assault            = { 94979, 445699, 1 }, -- Consuming Frenzied Tear has a 50% chance to reduce the cost of your next Raptor Strike by 100% and deal 30% more damage.
    howl_of_the_pack           = { 94992, 445707, 1 }, -- Your pet's Basic Attack critical strikes increase your critical strike damage by 5% for 8 sec stacking up to 3 times.
    pack_assault               = { 94966, 445721, 1 }, -- Vicious Hunt and Pack Coordination now stack and apply twice, and are always active during Coordinated Assault.
    pack_coordination          = { 94985, 445505, 1 }, -- Attacking with Vicious Hunt instructs your pet to strike with their Basic Attack along side your next Raptor Strike.
    scattered_prey             = { 94969, 445768, 1 }, -- Butchery increases the damage of your next Butchery by 25%.
    tireless_hunt              = { 94984, 445701, 1 }, -- Aspect of the Cheetah now increases movement speed by 15% for another 8 sec.
    vicious_hunt               = { 94991, 445404, 1, "pack_leader" }, -- Kill Command prepares you to viciously attack in coordination with your pet, dealing an additional 21,815 Physical damage with your next Kill Command.
    wild_attacks               = { 94962, 445708, 1 }, -- Every third pet Basic Attack is a guaranteed critical strike, with damage further increased by critical strike chance.

    -- Sentinel
    catch_out                  = { 94990, 451516, 1 }, -- When a target affected by Sentinel deals damage to you, they are rooted for 3 sec. May only occur every 1 min per target.
    crescent_steel             = { 94980, 451530, 1 }, -- Targets you damage below 20% health gain a stack of Sentinel every 3 sec.
    dont_look_back             = { 94989, 450373, 1 }, -- Each time Sentinel deals damage to an enemy you gain an absorb shield equal to 1% of your maximum health, up to 10%.
    extrapolated_shots         = { 94973, 450374, 1 }, -- When you apply Sentinel to a target not affected by Sentinel, you apply 1 additional stack.
    eyes_closed                = { 94970, 450381, 1 }, -- For 8 sec after activating Coordinated Assault, all abilities are guaranteed to apply Sentinel.
    invigorating_pulse         = { 94971, 450379, 1 }, -- Each time Sentinel deals damage to an enemy it has an up to 15% chance to generate 5 focus. Chances decrease with each additional Sentinel currently imploding applied to enemies.
    lunar_storm                = { 94978, 450385, 1 }, -- Every 15 sec your next Wildfire Bomb summons a celestial owl that conjures a 10 yd radius Lunar Storm at the target's location for 8 sec. A random enemy affected by Sentinel within your Lunar Storm gets struck for 8,180 Arcane damage every 0.4 sec. Any target struck by this effect takes 10% increased damage from you and your pet for 8 sec.
    overwatch                  = { 94980, 450384, 1 }, -- All Sentinel debuffs implode when a target affected by more than 3 stacks of your Sentinel falls below 20% health.
    release_and_reload         = { 94958, 450376, 1 }, -- When you apply Sentinel on a target, you have a 15% chance to apply a second stack.
    sentinel                   = { 94976, 450369, 1, "sentinel" }, -- Your attacks have a chance to apply Sentinel on the target, stacking up to 10 times. While Sentinel stacks are higher than 3, applying Sentinel has a chance to trigger an implosion, causing a stack to be consumed on the target every sec to deal 8,540 Arcane damage.
    sentinel_precision         = { 94981, 450375, 1 }, -- Raptor Strike, Mongoose Bite and Wildfire Bomb deal 10% increased damage.
    sentinel_watch             = { 94970, 451546, 1 }, -- Whenever a Sentinel deals damage, the cooldown of Coordinated Assault is reduced by 1 sec, up to 15 sec.
    sideline                   = { 94990, 450378, 1 }, -- When Sentinel starts dealing damage, the target is snared by 40% for 3 sec.
    symphonic_arsenal          = { 94965, 450383, 1 }, -- Multi-Shot and Butchery discharge arcane energy from all targets affected by your Sentinel, dealing 3,665 Arcane damage to up to 5 targets within 8 yds of your Sentinel targets.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting  = 3609, -- (356719) Stings the target, dealing 13,370 Nature damage and initiating a series of venoms. Each lasts 3 sec and applies the next effect after the previous one ends.  Scorpid Venom: 90% reduced movement speed.  Spider Venom: Silenced.  Viper Venom: 20% reduced damage and healing.
    diamond_ice      = 686 , -- (203340) Victims of Freezing Trap can no longer be damaged or healed. Freezing Trap is now undispellable, but has a 5 sec duration.
    hunting_pack     = 661 , -- (203235) Aspect of the Cheetah has 50% reduced cooldown and grants its effects to allies within 15 yds.
    interlope        = 5532, -- (248518) Misdirection now causes the next 3 hostile spells cast on your target within 10 sec to be redirected to your pet, but its cooldown is increased by 15 sec. Your pet must be within 20 yards of the target for spells to be redirected.
    mending_bandage  = 662 , -- (212640) Instantly clears all bleeds, poisons, and diseases from the target, and heals for 18% damage over 6 sec. Being attacked will stop you from using Mending Bandage.
    sticky_tar_bomb  = 664 , -- (407028) Throw a Sticky Tar Bomb that coats your target's weapons with tar, disarming them for 4 sec. After 4 sec, Sticky Tar Bomb explodes onto nearby enemies. Other enemies that are hit by the explosion are affected by Sticky Tar Bomb but this effect cannot spread further.
    survival_tactics = 3607, -- (202746) Feign Death reduces damage taken by 90% for 3 sec.
    trackers_net     = 665 , -- (212638) Hurl a net at your enemy, rooting them for 6 sec. While within the net, the target's chance to hit is reduced by 80%. Any damage will break the net.
    wild_kingdom     = 5443, -- (356707) Call in help from one of your dismissed Cunning pets for 10 sec. Your current pet is dismissed to rest and heal 30% of maximum health.
} )


-- Auras
spec:RegisterAuras( {
     -- Untrackable.
     aspect_of_the_chameleon = {
        id = 61648,
        duration = 60.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    aspect_of_the_cheetah = {
        id = 356781,
        duration = 3.0,
        max_stack = 1,
    },
    -- The range of $?s259387[Mongoose Bite][Raptor Strike] and and Mastery: Spirit Bond is increased to $265189r yds.
    aspect_of_the_eagle = {
        id = 186289,
        duration = 15,
        max_stack = 1
    },
    -- Deflecting all attacks.; Damage taken reduced by $w4%.
    aspect_of_the_turtle = {
        id = 186265,
        duration = 8.0,
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
        id = 260249,
        duration = 8,
        max_stack = 20
    },
    -- Explosive Shot cooldown reduced by $389880s1% and Focus cost reduced by $389880s2%.
    bombardier = {
        id = 459859,
        duration = 60.0,
        max_stack = 2,
    },
    -- Disoriented.
    bursting_shot = {
        id = 224729,
        duration = 4.0,
        max_stack = 1,
    },
    camouflage = {
        id = 199483,
        duration = 60,
        max_stack = 1,
    },
    -- Bleeding.
    careful_aim = {
        id = 63468,
        duration = 8.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Rooted.
    catch_out = {
        id = 451517,
        duration = 3.0,
        max_stack = 1,
    },
    -- You and your pet's bond is strengthened, increasing you and your pet's damage by $s2% and increasing your chance to reset Kill Command's cooldown.$?a459922[; Kill Command is generating $459962s4 additional stack of Tip of the Spear, your Haste is increased by $459962s1%, and Tip of the Spear's damage bonus is increased by $459962s2%.]
    coordinated_assault = {
        id = 360952,
        duration = function () return 20 + ( conduit.deadly_tandem.mod * 0.001 ) end,
        max_stack = 1,
        copy = 266779
    },
    coordinated_assault_empower = {
        id = 361738,
        duration = 5,
        max_stack = 1,
    },
    -- While Coordinated Assault is active, the cooldown of Wildfire Bomb is reduced by 25%, Wildfire Bomb generates 5 Focus when thrown, Kill Shot's cooldown is reduced by 25%, and Kill Shot can be used against any target, regardless of their current health.
    coordinated_kill = {
        id = 385739,
    },
    -- Bleeding for $w1 damage every $t1 sec.
    cull_the_herd = {
        id = 449233,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,
    },
    deadly_duo = {
        id = 397568,
        duration = 12,
        max_stack = 3
    },
    -- Rooted.
    entrapment = {
        id = 393456,
        duration = 4.0,
        max_stack = 1,
    },
    -- Exploding for $212680s1 Fire damage after $t1 sec.
    explosive_shot = {
        id = 212431,
        duration = 3.0,
        tick_time = 3.0,
        max_stack = 1,
    },
    -- Suffering $w2 Fire damage every $t2 sec.
    explosive_trap = {
        id = 13812,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_spirit_bond[263135] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.85, 'radius': 25.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, 'modifies': DAMAGE_HEALING, }
        -- mastery_spirit_bond[263135] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.85, 'radius': 25.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- coordinated_assault[360952] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- coordinated_assault[360952] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spearhead[378957] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- spearhead[378957] #2: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Your Kill Command hits $s1 targets.
    exposed_flank = {
        id = 459864,
        duration = 10.0,
        max_stack = 1,
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
    furious_assault = {
        id = 448814,
        duration = 12,
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
    -- Critical damage dealt increased by $s1%.
    howl_of_the_pack = {
        id = 462515,
        duration = 8.0,
        max_stack = 1,
    },
    -- The next hostile spell cast on the target will cause hostile spells for the next 3 sec. to be redirected to your pet. Your pet must be within 10 yards of the target for spells to be redirected.
    interlope = {
        id = 248518,
    },
    --[[ Suffering $w1 Bleed damage every $t1 sec.
    -- https://wowhead.com/beta/spell=270343
    internal_bleeding = {
        id = 270343,
        duration = 9,
        tick_time = 3,
        mechanic = "bleed",
        type = "Ranged",
        max_stack = 3
    }, ]]
    -- Talent: Bleeding for $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=259277
    kill_command = {
        id = 259277,
        duration = 8,
        max_stack = 1
    },
    -- Bleeding for $s1 damage every $t1 sec.
    lacerate = {
        id = 185855,
        duration = 12.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
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
    -- The bond between you and your pet is strong, granting you both $s3% increased effectiveness from Mastery: Spirit Bond.
    mastery_spirit_bond = {
        id = 459722,
        duration = 3600,
        max_stack = 1,
    },
    -- Your next Raptor Strike or Mongoose Bite hits $s1 targets.
    merciless_blows = {
        id = 459870,
        duration = 10.0,
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
        duration = 15,
        max_stack = 5
    },
    -- Damage taken reduced by $w1%
    no_hard_feelings = {
        id = 459547,
        duration = 5.0,
        max_stack = 1,
    },
    -- Damage taken from $@auracaster's critical strikes increased by $w1%.
    outland_venom = {
        id = 459941,
        duration = 3600,
        tick_time = 1.0,
        max_stack = 1,
    },
    pathfinding = {
        id = 264656,
        duration = 3600,
        max_stack = 1,
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
    -- Recently benefitted from Quick Load.
    quick_load = {
        id = 385646,
        duration = 25.0,
        max_stack = 1,
        copy = "quick_load_icd"
    },
    -- Kill Command is generating $s4 additional stack of Tip of the Spear, your Haste is increased by $s1%, and Tip of the Spear's damage bonus is increased by $s2%.
    relentless_primal_ferocity = {
        id = 459962,
        duration = 3600,
        max_stack = 1,
    },
    -- Sentinel from $@auracaster has a chance to start dealing $450412s1 Arcane damage every sec.
    sentinel = {
        id = 450387,
        duration = 1200.0,
        max_stack = 1,
    },
    -- Talent: Suffering $s2 Nature damage every $t2 sec.
    -- https://wowhead.com/beta/spell=271788
    serpent_sting = {
        id = 259491,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
    },
    -- Kill Shot usable on any target and it hits up to ${$s2-1} additional targets.
    sic_em = {
        id = 461409,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement slowed by $w1%.
    sideline = {
        id = 450845,
        duration = 3.0,
        max_stack = 1,
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
    -- Building up to an Explosive Shot...
    sulfurlined_pockets = {
        id = 459830,
        duration = 120.0,
        max_stack = 3,
    },
    sulfurlined_pockets_ready = {
        id = 459834,
        duration = 180,
        max_stack = 1
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
        max_stack = 1,
        copy = "wildfire_bomb"
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
    setCooldown( "explosive_shot", 0 )
    applyBuff( "bombardier", nil, 2 )
end, state )


spec:RegisterGear( "tier29", 200390, 200392, 200387, 200389, 200391, 217183, 217185, 217181, 217182, 217184 )
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

spec:RegisterGear( "tier31", 207216, 207217, 207218, 207219, 207221 )
spec:RegisterAuras( {
    fury_strikes = {
        id = 425830,
        duration = 12,
        max_stack = 1
    },
    contained_explosion = {
        id = 426344,
        duration = 12,
        max_stack = 1
    }
} )



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


spec:RegisterHook( "reset_precast", function()
    if buff.coordinated_assault.up and talent.bombardier.enabled then
        state:QueueAuraEvent( "coordinated_assault", TriggerBombardier, buff.coordinated_assault.expires, "AURA_EXPIRATION" )
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

    if lunar_storm_expires > query_time then setCooldown( "lunar_storm", lunar_storm_expires - query_time ) end

    if buff.coordinated_assault.up and talent.relentless_primal_ferocity.enabled then
        applyBuff( "relentless_primal_ferocity", buff.coordinated_assault.remains )
    end

    if talent.mongoose_bite.enabled then
        class.abilities.raptor_bite = class.abilities.mongoose_bite
        class.abilities.mongoose_strike = class.abilities.mongoose_bite
    else
        class.abilities.raptor_bite = class.abilities.raptor_strike
        class.abilities.mongoose_strike = class.abilities.raptor_strike
    end
end )

spec:RegisterHook( "spend", function( amt, resource )
    if set_bonus.tier30_4pc > 0 and amt >= 30 and resource == "focus" then
        local sec = floor( amt / 30 )
        gainChargeTime( "wildfire_bomb", sec )
    end
end )

spec:RegisterHook( "specializationChanged", function ()
    current_wildfire_bomb = nil
end )

spec:RegisterStateTable( "next_wi_bomb", setmetatable( {}, {
    __index = function( t, k )
        return k == "wildfire"
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
    -- A powerful aimed shot that deals $s1 Physical damage$?s260240[ and causes your next 1-$260242u ][]$?s342049&s260240[Chimaera Shots]?s260240[Arcane Shots][]$?s260240[ or Multi-Shots to deal $260242s1% more damage][].$?s260228[; Aimed Shot deals $393952s1% bonus damage to targets who are above $260228s1% health.][]$?s378888[; Aimed Shot also fires a Serpent Sting at the primary target.][]
    aimed_shot = {
        id = 19434,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "spell",

        spend = 40,
        spendType = 'focus',

        startsCombat = true,

        handler = function ()
            if talent.precise_shots.enabled then
                addStack( "precise_shots", nil, 2 )
            end
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

    -- Talent: Increases the range of your $?s259387[Mongoose Bite][Raptor Strike] to $265189r yds for $d.
    aspect_of_the_eagle = {
        id = 186289,
        cast = 0,
        cooldown = function () return 90 * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( 30 * talent.born_to_be_wild.rank ) end,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "aspect_of_the_eagle" )
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

        usable = function () return charges > 1 or active_enemies > 1 or target.time_to_die < ( 9 * haste ) end,
        handler = function ()
            removeBuff( "bestial_barrage" )
            removeBuff( "butchers_bone_fragments" )
            removeStack( "tip_of_the_spear" )

            if talent.frenzy_strikes.enabled then
                gainChargeTime( "wildfire_bomb", min( 5, true_active_enemies ) )
            end

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

        startsCombat = true,
        notalent = "butchery",

        handler = function ()
            removeBuff( "bestial_barrage" )
            removeBuff( "butchers_bone_fragments" )

            if talent.frenzy_strikes.enabled then
                gainChargeTime( "wildfire_bomb", min( 5, true_active_enemies ) )
            end

            if conduit.flame_infusion.enabled then
                addStack( "flame_infusion", nil, 1 )
            end
        end,
    },

    -- You and your pet charge your enemy, striking them for a combined $<combinedDmg> Physical damage. You and your pet's bond is then strengthened for $d, causing you and your pet to deal $s2% increased damage.; While Coordinated Assault is active, Kill Command's chance to reset its cooldown is increased by $s1%.
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
        cooldown = function() return 120 - ( 60 * talent.symbiotic_adrenaline.rank ) end,
        gcd = "spell",
        school = "nature",

        talent = "coordinated_assault",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "coordinated_assault" )
            if talent.bombardier.enabled then
                setCooldown( "wildfire_bomb", 0 )
            end
            if talent.relentless_primal_ferocity.enabled then
                applyBuff( "relentless_primal_ferocity", buff.coordinated_assault.remains )
            end
        end,
    },

    -- You and your pet leap to the target and strike it as one, dealing a total of $<damage> Physical damage.; Tip of the Spear grants an additional $260285s1% damage bonus to Flanking Strike and Flanking Strike generates $s2 stacks of Tip of the Spear.
    flanking_strike = {
        id = 269751,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        spend = 15,
        spendType = "focus",

        talent = "flanking_strike",
        startsCombat = true,

        usable = function () return pet.alive end,

        handler = function()
            addStack( "tip_of_the_spear" )
        end,
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

        start = function()
            if set_bonus.tier31_2pc > 0 then applyBuff( "fury_strikes" ) end
            if set_bonus.tier31_4pc > 0 then applyBuff( "contained_explosion" ) end
        end,
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

        startsCombat = true,

        usable = function () return settings.use_harpoon and action.harpoon.in_range, "harpoon disabled or target too close" end,
        handler = function ()
            applyDebuff( "target", "harpoon" )
            if talent.terms_of_engagement.enabled then applyBuff( "terms_of_engagement" ) end
            setDistance( 5 )
        end,
    },

    -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies away. Limit $s2. Trap will exist for $236775d.$?s321468[; Targets knocked back by High Explosive Trap deal $321469s1% less damage to you for $321469d after being knocked back.][]
    high_explosive_trap = {
        id = 236776,
        cast = 0,
        cooldown = function() return 40 - 5 * talent.improved_traps.rank end,
        gcd = "spell",
        school = "fire",

        talent = "high_explosive_trap",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Give the command to kill, causing your pet to savagely deal $<damage> Physical damage to the enemy.; Kill Command has a $s2% chance to immediately reset its cooldown.; Generates $s3 Focus.
    kill_command = {
        id = 259489,
        cast = 0,
        charges = function () return talent.alpha_predator.enabled and 2 or nil end,
        cooldown = 6,
        recharge = function () return talent.alpha_predator.enabled and 6 or nil end,
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

            if buff.sulfurlined_pockets_ready.up then
                buff.sulfurlined_pockets_ready.v1 = 259489
                class.abilities.explosive_shot.handler()
                buff.sulfurlined_pockets_ready.v1 = 0
                removeBuff( "sulfurlined_pockets_ready" )
            end

            if talent.bloodseeker.enabled then
                applyBuff( "predator", 8 )
                applyDebuff( "target", "kill_command", 8 )
            end

            if talent.tip_of_the_spear.enabled then
                addStack( "tip_of_the_spear", nil, talent.relentless_primal_ferocity.enabled and buff.coordinated_assault.up and 2 or 1 )
            end

            if talent.wildfire_infusion.enabled then
                gainChargeTime( "wildfire_bomb", 0.5 )
            end


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
        cooldown = function() return 10 end,
        gcd = "spell",
        school = "physical",

        spend = 10,
        spendType = "focus",

        talent = "kill_shot",
        startsCombat = true,

        usable = function () return buff.sic_em.up or target.health_pct < 20, "requires sic_em or target health below 20 percent" end,
        handler = function ()
            removeBuff( "sic_em" )
            removeStack ( "tip_of_the_spear" )
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

    -- A brutal attack that deals $s1 Physical damage and grants you Mongoose Fury.; Mongoose Fury; Increases the damage of Mongoose Bite by $259388s1% $?s385737[and the chance for Kill Command to reset by $259388s2% ][]for $259388d, stacking up to $259388u times.
    mongoose_bite = {
        id = 259387,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function()
            if buff.furious_assault.up then return 0 end
            return 30 - ( buff.bestial_barrage.up and 10 or 0 )
        end,
        spendType = "focus",

        talent = "mongoose_bite",
        startsCombat = true,

        handler = function ()
            if buff.furious_assault.up then removeBuff( "furious_assault" )
            else removeBuff( "bestial_barrage" ) end
            removeStack( "tip_of_the_spear" )
            removeDebuff( "target", "latent_poison" )
            removeDebuff( "target", "latent_poison_injection" )

            if buff.mongoose_fury.down then applyBuff( "mongoose_fury" )
            else
                local r = buff.mongoose_fury.expires
                applyBuff( "mongoose_fury", buff.mongoose_fury.remains, min( 5, buff.mongoose_fury.stack + 1 ) )
                buff.mongoose_fury.expires = r
            end

            if talent.vipers_venom.enabled then applyDebuff( "target", "serpent_sting" ) end


            if azerite.wilderness_survival.enabled then
                gainChargeTime( "wildfire_bomb", 1 )
            end

            if azerite.primeval_intuition.enabled then addStack( "primeval_intuition", nil, 1 ) end
            if azerite.blur_of_talons.enabled and buff.coordinated_assault.up then addStack( "blur_of_talons", nil, 1) end

            if legendary.butchers_bone_fragments.enabled then addStack( "butchers_bone_fragments", nil, 1 ) end
        end,

        copy = { 265888, "mongoose_bite_eagle", "mongoose_strike" }
    },

    -- Talent: A vicious slash dealing $s1 Physical damage.
    raptor_strike = {
        id = 186270,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function()
            if buff.furious_assault.up then return 0 end
            return 30 - ( buff.bestial_barrage.up and 10 or 0 )
        end,
        spendType = "focus",

        talent = "raptor_strike",
        startsCombat = true,
        indicator = function () return ( ( debuff.latent_poison_injection.down and active_dot.latent_poison_injection > 0 ) or ( debuff.latent_poison.down and active_dot.latent_poison > 0 ) ) and "cycle" or nil end,

        notalent = "mongoose_bite",

        handler = function ()
            if buff.furious_assault.up then removeBuff( "furious_assault" )
            else removeBuff( "bestial_barrage" ) end
            removeStack( "tip_of_the_spear" )
            removeDebuff( "target", "latent_poison" )
            removeDebuff( "target", "latent_poison_injection" )

            if buff.spearhead.up then
                applyDebuff( "target", "spearhead_damage" )
                if talent.deadly_duo.enabled then addStack( "deadly_duo" ) end
            end

            if talent.vipers_venom.enabled then applyDebuff( "target", "serpent_sting" ) end

            if azerite.wilderness_survival.enabled then
                gainChargeTime( "wildfire_bomb", 1 )
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

    -- You give the signal, and your pet charges your target, bleeding them for $378957o1 damage over $378957d and increasing your chance to critically strike your target by $378957s2% for $378957d.
    spearhead = {
        id = 360966,
        cast = 0,
        cooldown = function() return 90 - 30 * talent.deadly_duo.rank end,
        gcd = "spell",
        school = "physical",

        talent = "spearhead",
        startsCombat = true,
        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "spearhead" )
        end,
    },

    -- Talent: Hurl a bomb at the target, exploding for $265157s1 Fire damage in a cone and coating enemies in wildfire, scorching them for $269747o1 Fire damage over $269747d. Deals reduced damage beyond $s2 targets.; Deals $s3% increased damage to your primary target.
    wildfire_bomb = {
        id = 259495,
        cast = 0,
        charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
        cooldown = function() return ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste end,
        recharge = function() return talent.guerrilla_tactics.enabled and ( 18 - talent.explosives_expert.rank ) * ( 1 - 0.25 * talent.coordinated_kill.rank * ( buff.coordinated_assault.up and 1 or 0 ) ) * haste or nil end,
        gcd = "spell",
        school = "physical",

        spend = 10,
        spendType = 'focus',

        talent = "wildfire_bomb",
        startsCombat = true,
        velocity = 35,

        start = function ()
            removeBuff( "flame_infusion" )
            removeBuff( "coordinated_assault_empower" )
            if buff.contained_explosion.up then
                removeBuff( "contained_explosion" )
                gainCharges( 1, "wildfire_bomb" )
            end
            if talent.lunar_storm.enabled and cooldown.lunar_storm.ready then
                setCooldown( "lunar_storm", 13.7 )
                applyDebuff( "target", "lunar_storm" )
            end
        end,

        impact = function ()
            applyDebuff( "target", "wildfire_bomb_dot" )
            removeStack ( "tip_of_the_spear" )
        end,

        impactSpell = "wildfire_bomb",

        impactSpells = {
            wildfire_bomb = true,
        },
    },

    raptor_bite = {
        name = "|T1376044:0|t |cff00ccff[Raptor Strike / Mongoose Bite]|r",
        cast = 0,
        cooldown = 0,
        copy = { "raptor_bite_stub", "mongoose_strike" }
    }
} )


spec:RegisterRanges( "raptor_strike", "muzzle", "arcane_shot" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "spectral_agility",

    package = "Survival"
} )

spec:RegisterSetting( "pet_healing", 0, {
    name = "|T132179:0|t Mend Pet below %hp",
    desc = "If set above zero, the addon will recommend |T132179:0|t Mend Pet when your pet falls below this HP %. Leave at 0 to disable the feature.",
    icon = 132179,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "1.5"
} )

spec:RegisterSetting( "use_harpoon", true, {
    name = "|T1376040:0|t Use Harpoon",
    desc = "If checked, the addon will recommend |T1376040:0|t Harpoon when you are out of range and Harpoon is available.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "allow_focus_overcap", false, {
    name = "Allow Focus Overcap",
    desc = "The default priority tries to avoid overcapping Focus by default.  In simulations, this helps to avoid wasting Focus.  In actual gameplay, this can " ..
        "result in trying to use Focus spenders when other important buttons (Wildfire Bomb, Kill Command) are available to push.  On average, enabling this feature " ..
        "appears to be DPS neutral vs. the default setting, but has higher variance.  Your mileage may vary.\n\n" ..
        "The default setting is |cFFFFD100unchecked|r.",
    type = "toggle",
    width = "full"
} )

local beastMastery = class.specs[ 253 ]

spec:RegisterSetting( "mark_any", false, {
    name = strformat( "%s Any Target", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.hunters_mark.id ) ),
    desc = strformat( "If checked, %s may be recommended for any target rather than only bosses.", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.hunters_mark.id ) ),
    type = "toggle",
    width = "full"
} )

--[[ TODO: If this approach isn't sufficient, I'll need to check for pet Basic Attack abilities being set to manual.
spec:RegisterSetting( "manual_kill_shot", false, {
    name = strformat( "%s: %s Macro", Hekili:GetSpellLinkWithTexture( spec.auras.coordinated_assault.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.kill_shot.id ) ),
    desc = strformat( "During |W%s|w, some guides recommend using a macro to manually control your pet's attacks to empower |W%s|w.  These macros prevent the |W%s|w empowerment "
        .. "from occurring naturally, which will prevent |W%s|w from being recommended.\n\n"
        .. "Enabling this option will allow |W%s|w to be recommended during %s without the empowerment buff active.", spec.auras.coordinated_assault.name, spec.abilities.kill_shot.name,
        spec.auras.coordinated_assault_empower.name, spec.abilities.kill_shot.name, spec.abilities.kill_shot.name, spec.auras.coordinated_assault.name ),
    type = "toggle",
    width = 1.49
} ) ]]

spec:RegisterStateExpr( "coordinated_assault_kill_shot", function()
    return false -- ( settings.manual_kill_shot or false ) and buff.coordinated_assault.up
end )


spec:RegisterPack( "Survival", 20240922, [[Hekili:T3vFVTTnt8plbdW1En112jPjDpogORRDRDzPpyod7)SKImTTEIEXtVK2myOp7phPEJuIKIsX2jzlafTjMKhV74X7(DhjDNnC2vZMo3ien7YrdgD8G3oAu)bNE8GJNnn8U1OztxByEJXs4hCnCG)EAK)Tw3AyJB4oBpJ54Xh4f5Bcn(DX6Rcdxh8dV(1lTcxfDDFtpNxhy5ezBeA55A6BSie)7MVE20RJSSd)K7SR5o)h92ztnIcx55dZPLZ7NnDL185OKUJcmNnf39xn4TVA0OFiwh3Ly9O1ykf)54pN04zVA0XhgRdDAWz5DATVLNVv4D86(qmT(O13I1)vlB7y93754y4oh6AaOdI1TCJ1F3x(qS(xbXlw3X4BiOXp6zgfqtMbdbY87OG1iZWy9FjYne5)IGy9FZW)My9auyOL7YIbC6RgDkmGFZY1ZhA2YjJ1(p4jgvHc0d8iyGxTc6ZFAaJ9pb2YYD2uBRGWaYkdYn00gzClc(Tljl2ixJRTrZN9JGc2eVQa9AnYWFfcwmj6wFR1jF(0pC5vF6YpCrS(MnX6)0h(47(JlUkvd8U3F1N(YLx8PPajHra8NLb8tEE2Z9(QlSW75p3YfeI5Agbbgr2H99rogwUbZcH1AbCYnGAxZmrRtt3RJwSagVnio2OGanyr0XWwBbY3Zewl7hTowVtSoPBHwR18wOfUcPreS(bHGnCS(4y9HanVd0hAHg(lrGkcuja3CujUP08ETNZ1gG0G8ZfHCgg9T12Ebw3cZ1kVqmXowoXeXDta7uImKRc)QL98fw(in8833CfMLd0w4Nm1g2KXmS)PjRonDyVT0WKSGruDJI1)(y9LMZ7dw9fYpZSHf)tek(heRhAGxbPvOP9mHzK0CZumjl1z8ihrdZPVPDluNt0fy2TUUrXclSnCVb20Rfe6BDdcp9NkC67wdPtmvY5GQMNX69iASUK)O2smq0rdYgLAdb0YNnOjMrGojrHWTBz0Gs0KsTEK)G7RYCm2YFeRXuDsiwPumtQpmzUioRDwE41DktQi)7Y6gYyPnXO6TYPCGLPgYPGr7KSGaSgYf5yHs49Jl5poJThoOHETxqcmQ)sqVzeeQ5JwICjZaPHehj88hpSCGQwPGQ4AAy5OoLiRdY30IeE5ABVVgabvkiMVX6qpFTRHbqifjKrwJxhfAUc5FhnXXD6y6ovOkl1RtO7f98W0VqCS5feFxzrYZgJt0F)32L6Ese2SEe6B4(xaElR)M4dQktiocy3Cal4fm)B0mCVlZBnEnRVfOU8cY95KApn3lS)kcSLanhcSNZZcWLoUqlhyD3tBTzOg2ncXbubltpy5HvxdedaVyhUctlI9f8rA4pc4Ak1eYDUg0cVOu5HkmGfPKFrddIkbkLwc2xZ5bYJBWzV0rPImjW2TwMwErbAyzll0gG(ccjyIneuKnwBhekpasz(ycjK12Npsrwk1JMqDYbBz2bd1nrXi2jOqfZUGzk0ok64Kb79FGb(xkleRfaBcoAq4ubC9Wy9xgRJSXDn0dNAd48sMl1S51W30WfV7Z3hy0YoKyCDCTXsIVwq(VjOCpz8cABTCvyG2)lA(sNkuf(vG7mXqvQ6aliYXb0I49MCCIrP3suUwoRr(lGCRGiVMWMAdxZ70cq(rofKusFEs6UlrYnSbsb4D1wtC5dCcfuCEnMO4TBFkG)339(Fnw)Ip8UF6d)(Zz(9CMFsGx9CMF)BmZVNZtBNNN2mo5qOoQIMKog1skOn8caLgX(LjJX6C1o6XssDc8aoQ)zTXRs)tOafLLWxoiiXYvtYQKjHrrzvYKVOWSkl7JtGXbVfQtPNazjKItiscMcqrU2d)dmikE)x(Yf)0x(ZlNkcjro(ROaKwgn4GCOKEM3oDm4aSfDraiE9IBOMCarf2(SuQOd0JxPzIAn22Zd2JfLykvJL0tsjeaEJGqFaKnCctkat6jPuIDFqwlLde6PMaMcoln1faOrIRWJOmGHKwq(yao1aSIKZemVlWzjQXec(KAqs8iv5uOew7r(xoq7uiD0Py3CElwObiSjfyO(KCluRyu50OMsrPhR)kiQz)HYbXOgijg4uv0NfIiwmak7eihFtA6WZTGW7GRbGRb8YVHYFb5utldykmTSxsI2utGnoOS3czvcaolNW8fX6tVkw3cuDMrK6RyFxSUh0SJva2(Ab(uE)13hS2W5W8A6eRV224UGW7SHFewUdWNbmE3c5eMTctiOnKbbMAxdHir(jf9bMaW5d(t9rZHFNuPOqJBqP0fxkQeDeU(uq7aDmasyeGSTCr9J1zZXF6NU8NVasZ)Q397)8hUIoiDF5rHvXCIxbh4e4Jl4dM8jXfCb2nSgeoiZkW9dSmzEdPEyvR5cXXvrofDz3GdQNLKs(5dwB4IiY69dZlPv4HzcZkXtp(OOkhLRgrsfUPJmMzC1JYPdp1u(cbpMUMix)tVcgIdF9yRcgBJsiKfbmjxZCUTNG0npJoRGYv1Gn5dXE)7wtGxMTMb35CTfeA1uZyo4h1G4UQuVvuwRPCjYWlKwEe5HbZmZyQ1rxfLKArK0BhjTs33WtUvyJwpzfuPsjlQA3c5crC)rd(RUiXjsEVQwqoEUl98aGjy3TSk8KCZZAhNbgf1oMrokNLElrGiVyfkiG5sNVH1Cn0Tyj0y(CicX3W33Re5suBDQ2e(2SH9NEcJ0wTclspTKTo7C8ag2PA5ZMAHpQe)O1aOWHfLnHldwoK4ecMTo07nlxFgAhmClGtXDu5G6jspbfns0bqlgXt9ieeyZjQsqStv1rgMFMQsqDZATu96dgRhR)XiF8PwIV(K3Iauilb)hX6Ui4FHfNy9FXia)b)iip3S2dwDHfkpqfFrKl(snof4shaMQGBJOm8QSAWC3y2ycdHUW09EC0uB78iA2buPItzbWTBi20NcWTB4(jv4MDpC7hZNdLSnlKv3frWUcFucewn8ApPQd5vGOjGwAgc57zQdn(iIum7bXfA5Xw2dpJp)z85nfFUcIwNCDKFu4ks8qhdFJO5fMZYW1XdADJMFHj1kiJ2kOXRlGVcHXPx(k5YLzLi3DcxiBIQh295KDZ39QcML0DiQ0vfG3KUXtGWU1U2mnjs1dvUu3JkSv3Eh1VxQpAYcs0XLSdYcQC0z1ZccYd6wKFaU3PVrnWn10VA47IpL6ztjp)klN1E(HPf3)ffx)ZxGll)Ffb2aGAiWdB6zef65GDrdMURmCHi49J)8fqeNy9t(b8T9eYsYN08lQal4fj18VAdzsp0HUd)wVDcfJ)mhrn9sP3m58n85k67EBj(I31YTSSE6oHQNTtO6B3YuL7Ad(iZA2cZr8zloB3kXDs2qww0pEpmhcmWALz)UIIcmxtGUuIAS4zu0ykhPAzIvgbRQ0Jdk5YKwcq6hxZsB1ndhWNGmLAUer5wg6kewW(IsbvltA(HC3VexqqMT0oAUU2mNh0mpBJeXJvYyQcpk8gGuwriyoATT2(GNf6XF3phTwVSp4zHrP29ZrR1l7dEw4E9D)C0A9Y(GNfGpyFmhTwVSB5zbqs)xsErjhDwZeZ9bY4DBS6K5qqktTs5URO42gx4dlA29ZS0wDJimZvktCjclSmYvMGHc44MNl1qbof3oiL3PexqcLBPT2XF(tehCysFA2xKh4RKAqi2dg(996TWcF)msAkOF(d(9LN)6IN4B8N51E2Th(q8TF(CXx(z(JM(1ZEO1IZ7w5n8Uzd773TxhQZ2LE4NpOd3xS7KrduHZ58iCXQU0bcDp5lRb6pP6xod0TUNfnmhM(9KaE2y)Uvym13Rc0JO8tHprvaPOvFNWLO6WKxx)5dXZiBTQhFuNuBu6YFPcztGziH0tg1osNeyxopFqRPSkSnFQ)DX6T(7maAEJ(mMoKPG4NpKUFSFhcq3cZxza0nu6Bia8gdGR5(GWk2RbMr4TbjVdmS(G37dRC3lExv4ri5LLSzZb5obR0EhXhOCX4YBQJekbc63L5ZmJhTCV17gyD9BWguiESgMltTE9(kYxZYDre(uhESibSCp7766XjpM)QSECYEfVDQhh8heiP4gCnE4rL53KN5eHxHWmDyEjxJhDYMnp8Iqzwwvyfhs9iSs86s9YQMKEy9VAq)HIMGa8ymv4EySzJyHTYESGkVfk80u6jun583K6j9FYV9ikWxaKHAItrakv)LxOJKZCF8WEvMY8fmvxSRqbQtBMhpFGW7zzzKBWo0jdh1P7bIHWVztkYHke98bvLTA4mXtthrZYywGlDeE5iRWlmxBICFJ8xNMmOW7rDxpUjd7Fk1(pf6(BP6UK15XJ(EWhrf5GZiiRYPkZIIuGHWx6JuxQgpK)EdCMefBeeP9YN6K0IRAyu6wmvPD2BrgzcR4Xo3mLxvi6uhdk46Y1tsydiLgzoAhpQxVnB62vcxXjWtVTaNkXiILNLATjF7B(AE13sJmpEtg0RyHI5iltfmoVwMjhxLvukbIwUvV7b8VtwB2W)Z7u9EAnz4jCmYlFJQom)rMKgnzlmXhZXTB21HItIEd7KzFwQaqDeEHSkmAl1AJ93ljUstivgWezFlIrtVK0FVVHAZPsDyeUVqe4oPvDik6((YB0nCdHYrj2JX(YLLhI4F5tEP4w1OkpFuQtobnR6sDRJq0TRkkBigrhL644ZgijFSSzfheufQHHAQs)gpAaMMQ1v(RAvDexZwaXB8z2(v6R(424TGCzQFzXnSEC(TRovvZ97mlPEq4ReAMpaUKGoUcND3J6Fwt2G1)eUtsjqhCdlbzskJ)KV614LP6yZ04rp4VmXc(mPCY8w0pWu2fBVkbQZ8DBMqC(KEpItNtJ6GI8aKuSQ82(jT4CUzNfttSvyxzwHtQ(0kEfagOUeLu31tlqTOC8hwyl5AG9pOL8P(5uPBcNkhMKQwb8203CqizhLyLBSGi)0mytuS2mTWNVu)5fQsbVuTX83Hu3KkgNey9wFqiWAQ(ojhvvpERQndvvNg63B7xAI7H5ihIS)l0GQXqvQudQqmkWD1))AvSKEBu3bg6u3EK7Pf(qbtBlQ9aZ4B7EK6c31I44Q6aVAy8hW6pWm97u0ApvQbHkD88ebJBxYg)tNQzWAdCp9DRCfn6W6uF8XT0XK4G3BfxgcistRKaZGRwlb(AU6NBY3toMZUC0jNqE4VZ()p]] )
