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
        max_stack = 1,
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
    setCooldown( "wildfire_bomb", 0 )
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

        talent = "aspect_of_the_eagle",
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
                TriggerBombardier()
                state:QueueAuraExpiration( "coordinated_assault", TriggerBombardier, buff.coordinated_assault.expires )
            end
            if talent.relentless_primal_ferocity.enabled then
                applyBuff( "relentless_primal_ferocity", buff.coordinated_assault.remains )
            end
        end,
    },

    -- Fires an explosive shot at your target. After $t1 sec, the shot will explode, dealing $212680s1 Fire damage to all enemies within $212680A1 yds. Deals reduced damage beyond $s2 targets.
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

        handler = function()
            removeStack( "tip_of_the_spear" )
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
            addStack( "tip_of_the_spear", nil, 2 )
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
            removeStack( "tip_of_the_spear" )

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
            removeStack( "tip_of_the_spear" )
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
            removeDebuff( "target", "latent_poison" )
            removeDebuff( "target", "latent_poison_injection" )
            removeStack( "tip_of_the_spear" )

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
            removeDebuff( "target", "latent_poison" )
            removeDebuff( "target", "latent_poison_injection" )
            removeStack( "tip_of_the_spear" )

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
            removeStack( "tip_of_the_spear" )
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


spec:RegisterPack( "Survival", 20240824, [[Hekili:TZ1)VTTTs8)wcgGB8wQRLtstAFobiVUS9Axw6WCh2Vzjzz6y9I(INOuAZGH(B)DhLS(cfjLSITR7BbOyZ2K84X7oE3NJ8ygRn(tJhn1mKm(2b9hCs)ZhCspTxF8aTthpk8XfKXJwyADV5DWh8mDH)7OOGhSFW0bB4rhFZPibO(rbwqJFxSX8WWf03(QxDND48Oj9S8DFf12nYXm023ZkWCwi(DRxnE0KiBNW37nEIyg44XJmJcN7haZPT77gpAU90PKKUtOwJhHD)L9p)Ldo5TXgyxInwey7hyh(ySr0cKMXFi(dR6M2aOB)K9xIn(fBhNyJ3576A6nf6kfwEXg2EXgx9XRJn(mW5XgUMFHan(t(wr0IKPVgqMFNqxqScJn(prEHKGxqJn(vZG7JnOKWqBV7YhWzVCWzWa(vBp)aOzB3vS2)cNysfkuCGhdd8tZH(8NMWy)tGTS9gpYXMgszcDIxine(0TmLiXZCIdz64)ni3SqH94r3dluDRK154rwpA5q0dndUJaeag0ilqwrcSnhp6WyJjrZM1lG4au1HqP6GS010rFgjW3ceP9IweB0jTBH2l09NPhoNOdccZGE0qWkj2yySHwSr3enuG9Ie2y013(PyJaYd2u7qug5nfLrgavWzcOPV7eZGP2eyzE9OydWib)yXFEgQ4M5Z(vu9mcOit7DL)19GVctX7V96BInwUm24hV(NU6pUb6XO3F7pFdOs)0v)(pFn89RE3NE)hV9M3p6t9ghcgCCYTC5HLVVZu)p7b2V(ah4bkSP6MuQzKtiiKCnT9O5YzMmyob2lae9yjkJaZfH(b6tGPO4mDqSXu)WEusWcqYRtrZhq(ADptebc8efg8tUGYZxhehXgxcY5bSwbf3byFq1gWSEHM3z7hr1diGrnyF0lLtsemiV8arVYegBCrSrFMMRIvcSKoz9wsnHB6OIzgM1iXJ4AtOS(xvmLPieX0Nkv5Q0egeedsew11nTCbXmhtpuHb8vG99eC6FD7M(lz6by1Mzb(zBNPZSdi642HEwZXfjvFwqYCB6Kyn07SeMEDh2B4gMc7DMEbKnFFSXDwt7boitg7bfgUtKNzaif8dCRUnPelHYOZKkJYTPZDcu2uwrZRN0ByjnPG1pYPNlLtpmJvY8cuItkTbL(O7eBFy3TU50aOxo2Ee(E3aZJmRZcR(mLu3YcGCUkRharg0NtVlOBjA7US)H99q2)A0kj1SqUGP7wA1Q08v06Ub27DZToiFzHJpfDmrN7ZmmEZtzBEb7ykijjUReqCHWxnzA9BwG(mEygd9IXpalytAi4gg8cZwwSgs2cNzJ2eaaP2bnPRnaRqQ5Ly)3A8OAwlrBh1oLyDBwei1cijof0XaSXgVmZ5Mc)wAYboKikdmTNQtEavSMtNcH9(ccAlr8jRTovBcHKc85j9lzeolk4XvRCiUQde71gXqgeTiC8OezhpiKCgKpW6LmiBDkU32LeyzZ0RtC8)C5G2mrpFhqPm)MEPePWkzsuO1CsWJmwEnbz0iupsSS4HgiEQQoYqey7mwmHvOUxnu3O)(VrnrovxHVCvpcdm9(liLh7)Mbua3sxU3Y1zhMLybUNn4EDtVhx59Gbo0gKY(0m3HfqwnNLEbv3LLEYfR2BWbQCHvO(59t9qMZYfhSkCGwMWgPKVOJPNKKKIEscJwtPQHJXBrcogooLjz63hSTykxKBYvSislRqwAmnInw4qdvJltWoJbBd(amRmFGOg)JuzYbBy2jnjsLqCKky2gmtU0Hp0Q4GDLY08pWmQ5sV3EgWLGxgcMJTNpMenKIbXb7AOpEMbGtkjok6xCdSzGLPhUDjaa8WV5vRK3GjM3X8qdl)7P89SKxbh77Mhs1)VrtVZTcvHVcCNfc7PQhhAKRliexq4zfLbN2l8JW7Plr7B6aKcIfRVG5lf4KcXGf1yIaA1(jfNdsE(5Lnx(TRE3VeBCZ1x9Jx)7Ph(t(jemEDpoabIEXMSCazE64O0eB(kpGIe40Jva0L33FRrJvFgzF1YNvbKp5HV23svTLh8WM6CpKhtBJLTxsIOntfNMZxN1yiGu(8ImIYoxk94Mr)8dVRz9FyYsiFMA(WuTHwE8(A1sJvKls95eNMQBfFoB)uDZuPG0WNccnM9BUiRbUAhibPWtizvfEDuKOPepGd6DEB8Q070cGxkMvwnXq4ZYlAXyHztLLGxLjHdC0Pf7uUfbxV49XjX4qKI6SItqPe(4qEH5TOatbiix4JFOeII39XpEZp(X)82rYqsKH)kIs0xrdLG2K6dA15Xumt4Q9syOgbN2xThzxNgotf0Xo((WESOetPASK(MCfA6zrGqFaKnmVMgat6BYvj6(GPlvde6BTfyk4SI3Rg6k84cgWqslKaeGtnaRy5m1bVLsiBo9sHGpTgKe7PcNCHWcF2)xa0ov5MPkNo01N)Sz6aQ7uVY8yrsgm4fhGkCxGnzg4L2AE(mwPfbOosOXeIPfKLmOGXyVtip67v0dLOwfH(y9sfSU7wjNbqrbqzxAnGisZZEQnGBa85aH6bG4VUGkGI1JapsSW0J9A)Veb(TB2EfiWhzfia8vBGswrStVX5XydFyUDTP4Uc24(L3rxy6Eu2jgfBSWX8rA4JoWhbwIILUbBIWHGmksqhiVhKAtGa7iFGhPembGlt8xdit9t5JqZ7jP0fpNRefaE4xq7aDmbsysjS7rl2O8jt8Czmu2NnYlpxgd1MyX6MiW(45UipO7(25USjo4dHxgCPRmRusYTmf(n1r9ipp)NlkI)rxuekGpTA1bzfYCPwegCDqhsw5DRAb567DNVpaLcDHxwGNCkfRAhZfTa1oP06G)8kAjKj1hBtdwGzRUnBveODAPvB1ZAs59pVXzNwuudYZTMpm7Etrn0SknqqmT1VOgKDMynOOgkCVRT4w0Ku7TpFDAQCr(81P9ncSUNVoTNVoTVHUoTIPKwS6HorskeBH7zts8PD(nKjmQUQlOI5GVsy8cepK)wSKEbvLUglf3YemWhibuSBPp)jybn6ZMbE4LenEe75)y7UWpim9uQErEW6xGNV0FfbIdW1h1hlFvZOqFx0agupZn9apE9I)WnqAiXgN(wSOO8GPJ18lQ4g9fjhEv1gw5Ff6WHAFP7wHIXFqWsnTyl3iRZIvOghFjQ414xRVERq1Z2ku98nmvfQBWdwE9umhlMTeG0LJ7uGfMFPFYoyoKyk0kZ(TffLyyLeRGJALpTjEk9gjuAvYa8eJ)ynAk9eC0j8KwXPRSFnlTv2O1xmblD(gCev4zFuHWs2xWfDKN0IZ2D3sCjUZ3q7Of6AZAkD98SnqgpwbpzfEu6fWYliKmhT2wBxWZs94V9NJwlx2f8S0OuB)5O1YLDbplDV(2FoATCzxWZsWhSlMJwlx2U8SeiP)djVOKhTZ6Tm))f03sq22kH72IIssaR17LKrVnlA2VUZsBLnYWGV(z6OjzlYMbh7wL4B3nEXF49m3piPpl50f99WkFIgI(xy3mK14BhC6P47vZFMnE7Dj9I2l7bS9dx8Q8NSw8he1EX3j2r2ZU4WkVwTLll)s162j9So5FJAx0VJW3M2Ld6lEUxvjEhH1n4fcQBruoKoqO7jV33I)s133BXw3Xlnyg5FPLjlmi3M67eE2ohL84nVqd52YhO8WJ7KA(u8CJAcztIpRG0xoODKojIOAE(Gwt5MW2IP(3fB063KArER4PXFuPJx)cTI9R8BuTylLEsQfBG7fOIM5axl8HmKVZbmJqJ6K3Vakpe9Ug47E(7bahHIkIE5YdY8pvP9owslpN8XL1uhfucwOF3k3zR4rBVh8Vh0RFb2UbbY0rUm161)ZKaDBVzr4X1VVSckZ9LFpc7N8y2Rjy)K9YR5)9d(dclKxYSd1oMNFtkpFgVcbn6u6fimCWPlx(1FjWZY1gQ9OcVqGc(3eoC(NcG6ElQG)LnckkuTAWLdVCPCrvLDO0kfQponC13)Lx86u)Wpxy8TSW4lGYdqZutiugIS6REOokUP6HADRmLzwdn1sQcfkC1XI45dKwZ98qebBHl1g05WdKd8F5Yuqnvi6f9RU2QHZKpnDKnldlJPQJ0cLVcVuQQaYCBlwpDz)ChB1vIqxQ17ScBUBq3FtHURqppCW3dU2QSoemcMwovyMVRgZvG7NA(QAOM49gykl5BeKj9YM6KKPRAyWvet1OoUyqAekjnxLxlx6nmgUsWOmZCrNmrN6wGsQxQUkIic5EPkkWWbD7UC5HhQGReetT7gGtvyewMNvATQE7FMnt1I6wLhZl73nxrv6AmtxyckB7lpPkR0OCJAPRIdpqCLnVCP4FVt1QD(sTtfSjHVqVokRANtJgTbM4te42EvznjihwToRSp5o2PocRKk0Qj3OLR11oEHI4sRdPwHAs1FyFksVKm7FQHQZOsDymEQqmeoPvDikRGpfn61CdrJJYSdJDMTw(Ae)mBY3IX9uOQBDeIdpSjcBigrNg1XHN3xrQMRMvmiytOgcvTj9B4G(inBwxfR1Q6iUMTaY34xA7hxz52gVfSkQ9hYlZ2HzLyBQOw4FgBu6brSqy98biKefJRiy39GENVoBW6DQWjHd0HWWsqMOQ4p1AV1wnvhBMgpAV8Va(58EYPN3alYnzoYzt6ti0BgnQdDXxH8KBkVTBYuoJB2AHPYMH1ZBsZDlSLruayzZ6SO)IrxDHU7HBKn1pNe86WPQb40uJer7TRg3VHNBslC(khoaOQR3Xmi6RVtQbp0vKiOTB3fSh7YQ)fz)LLW6N7fBNN)C2uV7ZGUPrsAuo0nHyfqTu)d7TmP3ejuxIo1TR4jAtRjzABrs1LgFB3vux0GTCqqjRMVor62(PwxJkV1rE(NCY1L1CpH0RR6gqrc2Dk7kE4jT0DI8GSBKn6siY6MyBPbxn1wXsU6NB2dsD8)7]] )