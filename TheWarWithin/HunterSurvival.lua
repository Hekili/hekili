
-- HunterSurvival.lua
-- January 2025

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
    binding_shot               = { 102386, 109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within 5 yds for 10 sec, stunning them for 4 sec if they move more than 5 yds from the arrow.
    blackrock_munitions        = { 102392, 462036, 1 }, -- The damage of Explosive Shot is increased by 8%.
    born_to_be_wild            = { 102416, 266921, 1 }, -- Reduces the cooldowns of Aspect of the Eagle, Aspect of the Cheetah, and Aspect of the Turtle by 30 sec.
    bursting_shot              = { 102421, 186387, 1 }, -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by 50% for 6 sec, and dealing 4,977 Physical damage.
    camouflage                 = { 102414, 199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for 1 min. While camouflaged, you will heal for 2% of maximum health every 1 sec.
    concussive_shot            = { 102407,   5116, 1 }, -- Dazes the target, slowing movement speed by 50% for 6 sec. Steady Shot will increase the duration of Concussive Shot on the target by 3.0 sec.
    deathblow                  = { 102410, 343248, 1 }, -- Kill Command has a 15% chance to grant Deathblow.  Deathblow The cooldown of Kill Shot is reset. Your next Kill Shot can be used on any target, regardless of their current health.
    devilsaur_tranquilizer     = { 102415, 459991, 1 }, -- If Tranquilizing Shot removes only an Enrage effect, its cooldown is reduced by 5 sec.
    disruptive_rounds          = { 102395, 343244, 1 }, -- When Tranquilizing Shot successfully dispels an effect or Muzzle interrupts a cast, gain 10 Focus.
    emergency_salve            = { 102389, 459517, 1 }, -- Feign Death and Aspect of the Turtle removes poison and disease effects from you.
    entrapment                 = { 102403, 393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for 4 sec. Damage taken may break this root.
    explosive_shot             = { 102420, 212431, 1 }, -- Fires an explosive shot at your target. After 3 sec, the shot will explode, dealing 385,013 Fire damage to all enemies within 8 yds. Deals reduced damage beyond 5 targets.
    ghillie_suit               = { 102385, 459466, 1 }, -- You take 20% reduced damage while Camouflage is active. This effect persists for 3 sec after you leave Camouflage.
    high_explosive_trap        = { 102739, 236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 44,960 Fire damage and knocking all enemies away. Limit 1. Trap will exist for 1 min.
    hunters_avoidance          = { 102423, 384799, 1 }, -- Damage taken from area of effect attacks reduced by 5%.
    implosive_trap             = { 102739, 462031, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing 44,960 Fire damage and knocking all enemies up. Limit 1. Trap will exist for 1 min.
    improved_traps             = { 102418, 343247, 1 }, -- The cooldown of Tar Trap, High Explosive Trap, Implosive Trap, and Freezing Trap is reduced by 5.0 sec.
    intimidation               = { 103989,  19577, 1 }, -- Commands your pet to intimidate the target, stunning it for 5 sec.
    keen_eyesight              = { 102409, 378004, 2 }, -- Critical strike chance increased by 2%.
    kill_shot                  = { 102379, 320976, 1 }, -- You attempt to finish off a wounded target, dealing 453,099 Physical damage. Only usable on enemies with less than 20% health.
    kindling_flare             = { 102425, 459506, 1 }, -- Flare's radius is increased by 50%.
    kodo_tranquilizer          = { 102415, 459983, 1 }, -- Tranquilizing Shot removes up to 1 additional Magic effect from up to 2 nearby targets.
    lone_survivor              = { 102391, 388039, 1 }, -- Reduce the cooldown of Survival of the Fittest by 30 sec, and increase its duration by 2.0 sec. Reduce the cooldown of Counter Shot and Muzzle by 2 sec.
    misdirection               = { 102419,  34477, 1 }, -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within 30 sec and lasting for 8 sec.
    moment_of_opportunity      = { 102426, 459488, 1 }, -- When a trap triggers, you gain 30% movement speed for 3 sec. Can only occur every 1 min.
    muzzle                     = {  79837, 187707, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for 3 sec.
    natural_mending            = { 102401, 270581, 1 }, -- Every 10 Focus you spend reduces the remaining cooldown on Exhilaration by 1.0 sec.
    no_hard_feelings           = { 102412, 459546, 1 }, -- When Misdirection targets your pet, it reduces the damage they take by 50% for 5 sec. The cooldown of Misdirection is reduced by 5 sec.
    padded_armor               = { 102406, 459450, 1 }, -- Survival of the Fittest gains an additional charge.
    pathfinding                = { 102404, 378002, 1 }, -- Movement speed increased by 4%.
    posthaste                  = { 102411, 109215, 1 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by 50% for 4 sec.
    quick_load                 = { 102413, 378771, 1 }, -- When you fall below 40% health, Bursting Shot and Scatter Shot have their cooldown immediately reset. This can only occur once every 25 sec.
    rejuvenating_wind          = { 102381, 385539, 1 }, -- Maximum health increased by 8%, and Exhilaration now also heals you for an additional 12.0% of your maximum health over 8 sec.
    roar_of_sacrifice          = { 102405,  53480, 1 }, -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but 10% of all damage taken by that target is also taken by the pet. Lasts 12 sec.
    scare_beast                = { 102382,   1513, 1 }, -- Scares a beast, causing it to run in fear for up to 20 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time.
    scatter_shot               = { 102421, 213691, 1 }, -- A short-range shot that deals 3,499 damage, removes all harmful damage over time effects, and incapacitates the target for 4 sec. Any damage caused will remove the effect. Turns off your attack when used.
    scouts_instincts           = { 102424, 459455, 1 }, -- You cannot be slowed below 80% of your normal movement speed while Aspect of the Cheetah is active.
    scrappy                    = { 102408, 459533, 1 }, -- Casting Wildfire Bomb reduces the cooldown of Intimidation and Binding Shot by 0.5 sec.
    serrated_tips              = { 102384, 459502, 1 }, -- You gain 5% more critical strike from critical strike sources.
    specialized_arsenal        = { 102390, 459542, 1 }, -- Wildfire Bomb deals 10% increased damage.
    survival_of_the_fittest    = { 102422, 264735, 1 }, -- Reduces all damage you and your pet take by 30% for 8 sec.
    tar_trap                   = { 102393, 187698, 1 }, -- Hurls a tar trap to the target location that creates a 8 yd radius pool of tar around itself for 30 sec when the first enemy approaches. All enemies have 50% reduced movement speed while in the area of effect. Limit 1. Trap will exist for 1 min.
    tarcoated_bindings         = { 102417, 459460, 1 }, -- Binding Shot's stun duration is increased by 1 sec.
    territorial_instincts      = { 102394, 459507, 1 }, -- The cooldown of Intimidation is reduced by 10 sec.
    trailblazer                = { 102400, 199921, 1 }, -- Your movement speed is increased by 30% anytime you have not attacked for 3 sec.
    tranquilizing_shot         = { 102380,  19801, 1 }, -- Removes 1 Enrage and 1 Magic effect from an enemy target. Successfully dispelling an effect generates 10 Focus.
    trigger_finger             = { 102396, 459534, 2 }, -- You and your pet have 5.0% increased attack speed. This effect is increased by 100% if you do not have an active pet.
    unnatural_causes           = { 102387, 459527, 1 }, -- Your damage over time effects deal 10% increased damage. This effect is increased by 50% on targets below 20% health.
    wilderness_medicine        = { 102383, 343242, 1 }, -- Natural Mending now reduces the cooldown of Exhilaration by an additional 0.5 sec Mend Pet heals for an additional 25% of your pet's health over its duration, and has a 25% chance to dispel a magic effect each time it heals your pet.

    -- Survival
    alpha_predator             = { 102259, 269737, 1 }, -- Kill Command now has 2 charges, and deals 15% increased damage.
    bloodseeker                = { 102270, 260248, 1 }, -- Kill Command causes the target to bleed for 35,969 damage over 8 sec. You and your pet gain 10% attack speed for every bleeding enemy within 12 yds.
    bloody_claws               = { 102268, 385737, 1 }, -- Each stack of Mongoose Fury increases the chance for Kill Command to reset by 2%. Kill Command extends the duration of Mongoose Fury by 1.5 sec.
    bombardier                 = { 102273, 389880, 1 }, -- When you cast Coordinated Assault, you gain 1 charge of Wildfire Bomb. When Coordinated Assault ends, Explosive Shot's cooldown is reset and your next Explosive Shot fires at 2 additional targets at 100% effectiveness.
    born_to_kill               = { 102271, 1217434, 1 }, -- Your chance to gain Deathblow is increased by 5% and the duration of Cull the Herd is increased by 2.0 sec. Cull the Herd now additionally increases the damage taken from your Kill Shot by 25%.
    butchery                   = { 102290, 212436, 1 }, -- Attack all nearby enemies in a flurry of strikes, inflicting 300,914 Physical damage to nearby enemies and 289,435 damage over 8 sec. Deals reduced damage beyond 5 targets. Reduces the remaining cooldown on Wildfire Bomb by 3 sec for each target hit, up to 15.0 sec.
    contagious_reagents        = { 102276, 459741, 1 }, -- Reapplying Serpent Sting to a target also spreads it to up to 4 enemies within 8 yds.
    coordinated_assault        = { 102252, 360952, 1 }, -- You and your pet charge your enemy, striking them for a combined 302,065 Physical damage. You and your pet's bond is then strengthened for 20 sec, causing you and your pet to deal 20% increased damage. While Coordinated Assault is active, Kill Command's chance to reset its cooldown is increased by 15%.
    cull_the_herd              = { 102278, 1217429, 1 }, -- Kill Shot increases the damage enemies receive from you and your pet's Bleed effects by 25% for 8 sec.
    deadly_duo                 = { 102284, 378962, 1 }, -- The cooldown of Spearhead is reduced by 30 sec and Spearhead's bleed now increases you and your pet's critical strike damage against the target by 30%.
    explosives_expert          = { 102281, 378937, 2 }, -- Wildfire Bomb and Explosive Shot damage increased by 2.5%.
    flankers_advantage         = { 102283, 459964, 1 }, -- Kill Command has an additional 10% chance to immediately reset its cooldown. Tip of the Spear's damage bonus is increased up to 30%, based on your critical strike chance.
    flanking_strike            = { 102290, 269751, 1 }, -- You and your pet leap to the target and strike it as one, dealing a total of 532,541 Physical damage. Tip of the Spear grants an additional 15% damage bonus to Flanking Strike and Flanking Strike generates 2 stacks of Tip of the Spear.
    frenzy_strikes             = { 102286, 294029, 1 }, -- Flanking Strike damage increased by 40% and Flanking Strike now increases your attack speed by 25% for 12 sec. Butchery reduces the remaining cooldown on Wildfire Bomb by 3.0 sec for each target hit, up to 5 targets.
    fury_of_the_eagle          = { 102275, 203415, 1 }, -- Furiously strikes all enemies in front of you, dealing 1.3 million Physical damage over 2.6 sec. Critical strike chance increased by 50% against any target below 20% health. Deals reduced damage beyond 5 targets.
    grenade_juggler            = { 102287, 459843, 1 }, -- Wildfire Bomb deals 5% increased damage and has a 25% chance to reset the cooldown of Explosive Shot. Explosive Shot reduces the cooldown of Wildfire Bomb by 2 sec.
    guerrilla_tactics          = { 102285, 264332, 1 }, -- Wildfire Bomb now has 2 charges, and the initial explosion deals 50% increased damage.
    kill_command               = { 102255, 259489, 1 }, -- Give the command to kill, causing your pet to savagely deal 111,829 Physical damage to the enemy. Kill Command has a 20% chance to immediately reset its cooldown. Generates 15 Focus.
    killer_companion           = { 102282, 378955, 2 }, -- Kill Command damage increased by 20%.
    lunge                      = { 102272, 378934, 1 }, -- Auto-attacks with a two-handed weapon reduce the cooldown of Wildfire Bombs by 1.0 sec.
    merciless_blow             = { 102267, 459868, 1 }, -- Enemies damaged by Flanking Strike bleed for an additional 578,871 damage over 8 sec. Up to 5 enemies damaged by Butchery bleed for an additional 289,435 damage over 8 sec.
    mongoose_bite              = { 102257, 259387, 1 }, -- A brutal attack that deals 278,596 Physical damage and grants you Mongoose Fury. Mongoose Fury Increases the damage of Mongoose Bite by 15% for 16 sec, stacking up to 5 times.
    outland_venom              = { 102269, 459939, 1 }, -- Each damage over time effect on a target increases the critical strike damage they receive from you by 2%.
    quick_shot                 = { 102279, 378940, 1 }, -- When you cast Kill Command, you have a 30% chance to fire an Arcane Shot at your target at 100% of normal value.
    ranger                     = { 102256, 385695, 1 }, -- Kill Shot, Serpent Sting, Arcane Shot, Steady Shot, and Explosive Shot deal 20% increased damage.
    raptor_strike              = { 102262, 186270, 1 }, -- A vicious slash dealing 341,513 Physical damage.
    relentless_primal_ferocity = { 102258, 459922, 1 }, -- Coordinated Assault sends you and your pet into a state of primal power. For the duration of Coordinated Assault, Kill Command generates 2 additional stack of Tip of the Spear, you gain 10% Haste, and Tip of the Spear's damage bonus is increased by 50%.
    ruthless_marauder          = { 102261, 470068, 1 }, -- Fury of the Eagle's damage is increased by 10% and has a 20% chance to generate a stack of Tip of the Spear. When Fury of the Eagle ends, your Haste is increased by 8%.
    sic_em                     = { 102280, 459920, 1 }, -- Kill Command's chance to grant Deathblow is increased by 5% and Deathblow now makes Kill Shot strike up to 2 additional targets. Your chance to gain Deathblow is doubled during Coordinated Assault.  Deathblow The cooldown of Kill Shot is reset. Your next Kill Shot can be used on any target, regardless of their current health.
    spearhead                  = { 102291, 360966, 1 }, -- You give the signal, and your pet charges your target, bleeding them for 361,794 damage over 10 sec and increasing you and your pet's chance to critically strike your target by 30% for 10 sec.
    sulfurlined_pockets        = { 102266, 459828, 1 }, -- Every 3 Quick Shots is replaced with an Explosive Shot at 100% effectiveness.
    sweeping_spear             = { 102289, 378950, 2 }, -- Raptor Strike, Mongoose Bite, and Butchery damage increased by 10%.
    symbiotic_adrenaline       = { 102258, 459875, 1 }, -- The cooldown of Coordinated Assault is reduced by 60 sec and Coordinated Assault now grants 3 stacks of Tip of the Spear.
    tactical_advantage         = { 102277, 378951, 1 }, -- Damage of Flanking Strike and Butchery increased by 5% and all damage dealt by Wildfire Bomb increased by 5%.
    terms_of_engagement        = { 102288, 265895, 1 }, -- Harpoon has a 10 sec reduced cooldown, and deals 47,197 Physical damage and generates 20 Focus over 10 sec. Killing an enemy resets the cooldown of Harpoon.
    tip_of_the_spear           = { 102263, 260285, 1 }, -- Kill Command increases the direct damage of your other spells by 15%, stacking up to 3 times.
    vipers_venom               = { 102260, 268501, 1 }, -- Raptor Strike and Mongoose Bite damage increased by 15%. Raptor Strike and Mongoose Bite apply Serpent Sting to your target. Serpent Sting Fire a poison-tipped arrow at an enemy, dealing 33,393 Nature damage instantly and an additional 224,641 damage over 12 sec.
    wildfire_arsenal           = { 102274, 321290, 1 }, -- Quick Shot and and auto-attacks with a two-handed weapon increase the direct damage of your next Wildfire Bomb by 4%, stacking up to 3 times. Casting Coordinated Assault grants 3 stacks of Wildfire Arsenal.
    wildfire_bomb              = { 102264, 259495, 1 }, -- Hurl a bomb at the target, exploding for 164,758 Fire damage in a cone and coating enemies in wildfire, scorching them for 148,484 Fire damage over 6 sec. Deals reduced damage beyond 8 targets. Deals 80% increased damage to your primary target.
    wildfire_infusion          = { 102265, 460198, 1 }, -- Mongoose Bite and Raptor Strike have a 10% chance to reset Kill Command's cooldown. Kill Command reduces the cooldown of Wildfire Bomb by 0.5 sec.

    -- Pack Leader
    better_together            = {  94962, 472357, 1 }, -- Howl of the Pack Leader's cooldown is reduced to 25 sec. Your pets gain an extra 5% of your attack power.
    dire_summons               = {  94992, 472352, 1 }, -- Kill Command reduces the cooldown of Howl of the Pack Leader by 1.0 sec. Mongoose Bite reduces the cooldown of Howl of the Pack Leader by 1.0 sec.
    envenomed_fangs            = {  94972, 472524, 1 }, -- Initial damage from your Bear will consume Serpent Sting from up to 8 nearby targets, dealing 100% of its remaining damage instantly.
    fury_of_the_wyvern         = {  94984, 472550, 1 }, -- Your pet's attacks increase your Wyvern's damage bonus by 1%, up to 10%. Casting Wildfire Bomb extends the duration of your Wyvern by 2.0 sec, up to 10 additional sec.
    hogstrider                 = {  94988, 472639, 1 }, -- Summoning your Boar refreshes the duration of Mongoose Fury. Each time your Boar deals damage, you have a 25% chance to gain a stack of Mongoose Fury and Mongoose Bite strikes 1 additional target. Stacks up to 4 times. Mongoose Fury Increases the damage of Mongoose Bite or Raptor Strike by 15% for 16 sec, stacking up to 5 times.
    horsehair_tether           = {  94979, 472729, 1 }, -- When an enemy is stunned by Binding Shot, it is dragged to Binding Shot's center.
    howl_of_the_pack_leader    = {  94991, 471876, 1, "pack_leader" }, -- Every 25 sec, your next Kill Command summons the aid of a Beast.  Bear A Bear leaps into the fray, rending the flesh of your enemies, dealing 508,191 damage over 10 sec to up to 8 nearby enemies.  Wyvern A Wyvern descends from the skies, letting out a battle cry that increases the damage of you and your pets by 10% for 15 sec.  Boar A Boar charges through your target 3 times, dealing 493,017 physical damage to the primary target and 197,207 damage to up to 8 nearby enemies.
    lead_from_the_front        = {  94966, 472741, 1 }, -- Casting Coordinated Assault grants Howl of the Pack Leader and increases the damage dealt by your Beasts by 25% and your pet by 0% for 12 sec.
    no_mercy                   = {  94969, 472660, 1 }, -- Damage from your Kill Shot sends your pets into a rage, causing all active pets within 20 yds and your Bear to pounce to the target and Smack, Claw, or Bite it. Your pets will not leap if their target is already in melee range.
    pack_mentality             = {  94985, 472358, 1 }, -- Howl of the Pack Leader causes your Kill Command to generate an additional stack of Tip of the Spear. Summoning a Beast reduces the cooldown of Wildfire Bomb by 10.0 sec.
    shell_cover                = {  94967, 472707, 1 }, -- When dropping below 60% health, summon the aid of a Turtle, reducing the damage you take by 10% for 6 sec. This effect can only occur once every 1.5 min.
    slicked_shoes              = {  94979, 472719, 1 }, -- When Disengage removes a movement impairing effect, its cooldown is reduced by 4 sec.
    ursine_fury                = {  94972, 472476, 1 }, -- Your Bear's periodic damage has a 10% chance to reduce the cooldown of Butchery or Flanking Strike by 2.0 sec.

    -- Sentinel
    catch_out                  = {  94990, 451516, 1 }, -- When a target affected by Sentinel deals damage to you, they are rooted for 3 sec. May only occur every 1 min per target.
    crescent_steel             = {  94980, 451530, 1 }, -- Targets you damage below 20% health gain a stack of Sentinel every 3 sec.
    dont_look_back             = {  94989, 450373, 1 }, -- Each time Sentinel deals damage to an enemy you gain an absorb shield equal to 1.0% of your maximum health, up to 10%.
    extrapolated_shots         = {  94973, 450374, 1 }, -- When you apply Sentinel to a target not affected by Sentinel, you apply 1 additional stack.
    eyes_closed                = {  94970, 450381, 1 }, -- For 8 sec after activating Coordinated Assault, all abilities are guaranteed to apply Sentinel.
    invigorating_pulse         = {  94971, 450379, 1 }, -- Each time Sentinel deals damage to an enemy it has an up to 15% chance to generate 5 Focus. Chances decrease with each additional Sentinel currently imploding applied to enemies.
    lunar_storm                = {  94978, 450385, 1 }, -- Every 30 sec your next Wildfire Bomb launches a celestial arrow that conjures a 12 yd radius Lunar Storm at the target's location dealing 94,395 Arcane damage. For the next 12 sec, a random enemy affected by Sentinel within your Lunar Storm gets struck for 88,495 Arcane damage every 0.4 sec. Any target struck by this effect takes 10% increased damage from you and your pet for 8 sec.
    overwatch                  = {  94980, 450384, 1 }, -- All Sentinel debuffs implode when a target affected by more than 3 stacks of your Sentinel falls below 20% health. This effect can only occur once every 15 sec per target.
    release_and_reload         = {  94958, 450376, 1 }, -- When you apply Sentinel on a target, you have a 15% chance to apply a second stack.
    sentinel                   = {  94976, 450369, 1, "sentinel" }, -- Your attacks have a chance to apply Sentinel on the target, stacking up to 10 times. While Sentinel stacks are higher than 3, applying Sentinel has a chance to trigger an implosion, causing a stack to be consumed on the target every sec to deal 84,588 Arcane damage.
    sentinel_precision         = {  94981, 450375, 1 }, -- Raptor Strike, Mongoose Bite and Wildfire Bomb deal 10% increased damage.
    sentinel_watch             = {  94970, 451546, 1 }, -- Whenever a Sentinel deals damage, the cooldown of Coordinated Assault is reduced by 1 sec, up to 15 sec.
    sideline                   = {  94990, 450378, 1 }, -- When Sentinel starts dealing damage, the target is snared by 40% for 3 sec.
    symphonic_arsenal          = {  94965, 450383, 1 }, -- Multi-Shot and Butchery discharge arcane energy from all targets affected by your Sentinel, dealing 84,956 Arcane damage to up to 5 targets within 8 yds of your Sentinel targets.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting  = 3609, -- (356719) Stings the target, dealing 117,636 Nature damage and initiating a series of venoms. Each lasts 3 sec and applies the next effect after the previous one ends.  Scorpid Venom: 90% reduced movement speed.  Spider Venom: Silenced.  Viper Venom: 20% reduced damage and healing.
    diamond_ice      =  686, -- (203340) Victims of Freezing Trap can no longer be damaged or healed. Freezing Trap is now undispellable, but has a 4 sec duration.
    explosive_powder = 5690, -- (1218150) Bursting Shot now also knocks you back and snares enemies by an additional 20%.
    hunting_pack     =  661, -- (203235) Aspect of the Cheetah has 50% reduced cooldown and grants its effects to allies within 15 yds.
    interlope        = 5532, -- (248518) Misdirection now causes the next 3 hostile spells cast on your target within 10 sec to be redirected to your pet, but its cooldown is increased by 15 sec. Your pet must be within 20 yards of the target for spells to be redirected.
    mending_bandage  =  662, -- (212640) Instantly clears all bleeds, poisons, and diseases from the target, and heals for 18% damage over 6 sec. Being attacked will stop you from using Mending Bandage.
    sticky_tar_bomb  =  664, -- (407028) Throw a Sticky Tar Bomb that coats your target's weapons with tar, disarming them for 4 sec. After 4 sec, Sticky Tar Bomb explodes onto nearby enemies. Other enemies that are hit by the explosion are affected by Sticky Tar Bomb but this effect cannot spread further.
    survival_tactics = 3607, -- (202746) Feign Death reduces damage taken by 90% for 2 sec.
    trackers_net     =  665, -- (212638) Hurl a net at your enemy, rooting them for 6 sec. While within the net, the target's chance to hit is reduced by 80%. Any damage will break the net.
    wild_kingdom     = 5443, -- (356707) Call in help from one of your dismissed Cunning pets for 10 sec. Your current pet is dismissed to rest and heal 30% of maximum health.
} )

-- Auras
spec:RegisterAuras( {
     -- Untrackable.
     aspect_of_the_chameleon = {
        id = 61648,
        duration = 60.0,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    aspect_of_the_cheetah = {
        id = 356781,
        duration = 3.0,
        max_stack = 1
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
    bleeding_gash = {
        id = 361049,
        duration = 6,
        max_stack = 1
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
        max_stack = 1
    },
    -- Disoriented.
    bursting_shot = {
        id = 224729,
        duration = 4.0,
        max_stack = 1
    },
    camouflage = {
        id = 199483,
        duration = 60,
        max_stack = 1
    },
    -- Bleeding.
    careful_aim = {
        id = 63468,
        duration = 8.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1
    },
    -- Rooted.
    catch_out = {
        id = 451517,
        duration = 3.0,
        max_stack = 1
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
        max_stack = 1
    },
    -- While Coordinated Assault is active, the cooldown of Wildfire Bomb is reduced by 25%, Wildfire Bomb generates 5 Focus when thrown, Kill Shot's cooldown is reduced by 25%, and Kill Shot can be used against any target, regardless of their current health.
    coordinated_kill = {
        id = 385739
    },
    -- Bleeding for $w1 damage every $t1 sec.
    cull_the_herd = {
        id = 1217430,
        duration = function() return 6 + ( 2 * talent.born_to_kill.rank ) end,
        tick_time = 2.0,
        max_stack = 1
    },
    deadly_duo = {
        id = 397568,
        duration = 12,
        max_stack = 3
    },

    deathblow = {
        id = 378770,
        duration = 12,
        max_stack = 1
    },
    -- Rooted.
    entrapment = {
        id = 393456,
        duration = 4.0,
        max_stack = 1
    },
    -- Exploding for $212680s1 Fire damage after $t1 sec.
    explosive_shot = {
        id = 212431,
        duration = 3.0,
        tick_time = 3.0,
        max_stack = 1
    },
    -- Suffering $w2 Fire damage every $t2 sec.
    explosive_trap = {
        id = 13812,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1
    },
    -- All abilities are guaranteed to apply Sentinel.
    eyes_closed = {
        id = 451180,
        duration = 8.0,
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
    -- https://www.wowhead.com/spell=1217377
    -- Frenzy Strikes Attack speed increased by 25%.
    frenzy_strikes = {
        id = 1217377,
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
    howl_of_the_pack_leader_cooldown = {
        id = 471877,
        duration = function() return 25 - ( 5 * talent.better_together.rank ) end,
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
    -- The next hostile spell cast on the target will cause hostile spells for the next 3 sec. to be redirected to your pet. Your pet must be within 10 yards of the target for spells to be redirected.
    interlope = {
        id = 248518,
    },
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
    -- Damage taken from $@auracaster and their pets increased by $w1%.
    lunar_storm = {
        id = 450884,
        duration = 8.0,
        max_stack = 1
    },
    lunar_storm_cooldown = {
        id = 451803,
        duration = 30,
        max_stack = 1,
        onRemove = function()
            applyBuff( "lunar_storm_ready" )
        end,
    },
    lunar_storm_ready = {
        id = 451805,
        duration = 3600,
        max_stack = 1
    },
    masters_call = {
        id = 54216,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- The bond between you and your pet is strong, granting you both $s3% increased effectiveness from Mastery: Spirit Bond.
    mastery_spirit_bond = {
        id = 459722,
        duration = 3600,
        max_stack = 1
    },
    -- Butchery Version
    merciless_blows = {
        id = 459870,
        duration = 8,
        tick_time = 1,
        mechanic = "bleed",
        type = "melee",
        max_stack = 1
    },
    -- Flanking Strike Version
    merciless_blow = {
        id = 1217375,
        duration = 8,
        tick_time = 1,
        mechanic = "bleed",
        type = "melee",
        max_stack = 1
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
        max_stack = 1
    },
    -- Mongoose Bite damage increased by $s1%.$?$w2>0[  Kill Command reset chance increased by $w2%.][]
    -- https://wowhead.com/beta/spell=259388
    mongoose_fury = {
        id = 259388,
        duration = 14,
        max_stack = 5
    },
    -- Damage taken reduced by $w1%
    no_hard_feelings = {
        id = 459547,
        duration = 5.0,
        max_stack = 1
    },
    -- Damage taken from $@auracaster's critical strikes increased by $w1%.
    outland_venom = {
        id = 459941,
        duration = 3600,
        tick_time = 1.0,
        max_stack = 1
    },
    pathfinding = {
        id = 264656,
        duration = 3600,
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
        max_stack = 10
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
        max_stack = 1
    },
    ruthless_marauder = {
        id = 470070,
        duration = 10,
        max_stack = 1
    },
    -- Sentinel from $@auracaster has a chance to start dealing $450412s1 Arcane damage every sec.
    sentinel = {
        id = 450387,
        duration = 1200.0,
        max_stack = 1
    },
    -- Talent: Suffering $s2 Nature damage every $t2 sec.
    -- https://wowhead.com/beta/spell=271788
    serpent_sting = {
        id = 259491,
        duration = 12,
        tick_time = 3,
        max_stack = 1
    },
    -- Movement slowed by $w1%.
    sideline = {
        id = 450845,
        duration = 3.0,
        max_stack = 1
    },
    -- Talent: Pet damage dealt increased by $s1%.  $?s259387[Mongoose Bite][Raptor Strike] deals an additional $s2% of damage dealt as a bleed over $389881d.  Kill Command has a $s3% increased chance to reset its cooldown.$?$w4!=0&?s259387[  Mongoose Bite Focus cost reduced by $w4.]?$w4!=0&!s259387[  Raptor Strike Focus cost reduced by $w4.][]
    -- https://wowhead.com/beta/spell=360966
    spearhead = {
        id = 378957,
        duration = 10,
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
        max_stack = 1
    },
    -- Building up to an Explosive Shot...
    sulfurlined_pockets = {
        id = 459830,
        duration = 3600,
        max_stack = 2
    },
    sulfurlined_pockets_ready = {
        id = 459834,
        duration = 3600,
        max_stack = 1
    },
    terms_of_engagement = {
        id = 265898,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Your next $?s259387[Mongoose Bite][Raptor Strike] deals $s1% increased damage.
    -- https://wowhead.com/beta/spell=260286
    tip_of_the_spear = {
        id = 260286,
        duration = 10,
        max_stack = 3,
        meta = {
            stack = function() return max( 0, ( state.buff.tip_of_the_spear.stack - ( action.wildfire_bomb.in_flight and 1 or 0 ) ) ) end,
            stacks = function() return max( 0, ( state.buff.tip_of_the_spear.stack - ( action.wildfire_bomb.in_flight and 1 or 0 ) ) ) end,
            react = function() return max( 0, ( state.buff.tip_of_the_spear.stack - ( action.wildfire_bomb.in_flight and 1 or 0 ) ) ) end,
        }
    },
    trailblazer = {
        id = 231390,
        duration = 3600,
        max_stack = 1
    },
    -- Call in help from one of your dismissed Cunning pets for 10 sec. Your current pet is dismissed to rest and heal 30% of maximum health.
    wild_kingdom = {
        id = 356707
    },
    wildfire_arsenal = {
        id = 1223701,
        duration = 12,
        max_stack = 3
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
        max_stack = 5
    },
    primeval_intuition = {
        id = 288573,
        duration = 12,
        max_stack = 5
    },
    -- Legendaries
    butchers_bone_fragments = {
        id = 336908,
        duration = 12,
        max_stack = 6
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

-- The War Within
spec:RegisterGear( "tww2", 229271, 229269, 229274, 229272, 229270 )
spec:RegisterAuras( {
    -- 2-set
    -- https://www.wowhead.com/spell=1216874
    -- Winning Streak! Wildfire Bomb damage increased by 6%.
    winning_streak = {
        id = 1216874,
        duration = 30,
        max_stack = 6,
    },
    -- 4-set
    -- https://www.wowhead.com/spell=1216879
    strike_it_rich = {
        id = 1216879,
        duration = 10,
        max_stack = 1,
    },

} )

-- Dragonflight
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
    setCooldown( "explosive_shot", 1 ) -- There is a slight delay before you actually get it
    applyBuff( "bombardier", nil, 1 )
end, state )

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
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
end )

-- To support SimC Expressions
spec:RegisterStateTable( "howl_summon", setmetatable( {

    refresh_cycle = setfenv( function()
        -- reset_precast function
        pack_leader_buff_next_index = nil
    end, state ),

    raid_boss_reset = setfenv( function()
        pack_leader_buff_next_index = 1
    end, state ),

    trigger_summon = setfenv( function( isCoordinatedAssault )

        local summonCount = 0
        if isCoordinatedAssault then
            -- Scenario 1: Coordinated Assault prepares the next summon without summoning anything that is currently ready or modifying the CD buff
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
                    if buffName == "boar" and talent.hogstrider.enabled and buff.mongoose_fury.up then
                        applyBuff( "mongoose_fury", spec.auras.mongoose_fury.duration, buff.mongoose_fury.stack )
                    end
                end
            end

            if summonCount > 0 then
                addStack( "tip_of_the_spear" )
                if talent.pack_mentality.enabled then reduceCooldown( "wildfire_bomb", 10 * summonCount ) end
            end

            if buff.howl_of_the_pack_leader_cooldown.down then applyBuff( "howl_of_the_pack_leader_cooldown" )
            elseif talent.dire_summons.enabled then buff.howl_of_the_pack_leader_cooldown.expires = buff.howl_of_the_pack_leader_cooldown.expires - 2
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
        local remains = boar_charge.boar_duration - elapsed

        if k == "remains" then
            return max( 0, remains )
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

spec:RegisterHook( "runHandler_startCombat", function()
    if talent.howl_of_the_pack_leader.enabled then
        if buff.howl_of_the_pack_leader_cooldown.down then applyBuff( "howl_of_the_pack_leader_cooldown" ) end
        if raid and boss then howl_summon.raid_boss_reset() end
    end
end )

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
        cooldown = 15,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        spend = function() return 30 - ( buff.bestial_barrage.up and 10 or 0 ) end,
        spendType = "focus",

        talent = "butchery",
        startsCombat = true,

        handler = function ()
            if talent.scattered_prey.enabled then applyBuff( "scattered_prey" ) end
            removeStack( "tip_of_the_spear" )

            if talent.frenzy_strikes.enabled then
                gainChargeTime( "wildfire_bomb", min( 5, true_active_enemies ) * 3 )
            end

            if talent.merciless_blow.enabled then applyDebuff( "target", "merciless_blows" ) end

            -- Legacy / PvP Stuff
            if set_bonus.tier31_2pc > 0 then removeBuff( "bestial_barrage" ) end
            if legendary.butchers_bone_fragments.enabled then removeBuff( "butchers_bone_fragments" ) end
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
            -- Standard effects / talents
            applyBuff( "coordinated_assault" )
            if talent.bombardier.enabled then
                gainCharges( "wildfire_bomb", 1 )
            end
            if talent.relentless_primal_ferocity.enabled then
                applyBuff( "relentless_primal_ferocity", buff.coordinated_assault.remains )
            end
            if talent.wildfire_arsenal.enabled then addStack( "wildfire_arsenal", nil, 3 ) end

            -- Hero Talents
            if talent.lead_from_the_front.enabled then howl_summon.trigger_summon( true ) end
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
            removeStack ( "tip_of_the_spear" )
            if buff.bombardier.up then
                removeBuff( "bombardier" )
                active_dot.explosive_shot = min( true_active_enemies, active_dot.explosive_shot + 2 )
            end
            if talent.grenade_juggler.enabled then reduceCooldown( "wildfire_bomb", 2 ) end
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
            if talent.merciless_blow.enabled then applyDebuff( "target", "merciless_blow" ) end
        end,
    },

    -- Talent: Furiously strikes all enemies in front of you, dealing ${$203413s1*9} Physical damage over $d. Critical strike chance increased by $s3% against any target below $s4% health. Deals reduced damage beyond $s5 targets.    Kill Command cooldown resets reduce the cooldown of Fury of the Eagle by ${$m2/1000}.1 sec$?s385718[ and the cooldown of Wildfire Bomb and Flanking Strike by ${$m1/1000}.1 sec][].
    fury_of_the_eagle = {
        id = 203415,
        cast = 3,
        channeled = true,
        cooldown = 45,
        gcd = "spell",
        school = "physical",

        talent = "fury_of_the_eagle",
        startsCombat = true,

        start = function()
            if set_bonus.tier31_2pc > 0 then applyBuff( "fury_strikes" ) end
            if set_bonus.tier31_4pc > 0 then applyBuff( "contained_explosion" ) end
            removeStack( "tip_of_the_spear" )
        end,

        finish = function ()
            if talent.ruthless_marauder.enabled then
                applyBuff( "ruthless_marauder" )
                -- Can generate up to 3, but since its RNG we need to lowball it
                addStack( "tip_of_the_spear" )
            end
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
        recharge = function () return talent.alpha_predator.enabled and 6 * haste or nil end,
        hasteCD = true,
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

            if talent.howl_of_the_pack_leader.enabled then howl_summon.trigger_summon( false ) end

            if talent.bloodseeker.enabled then
                applyBuff( "predator", 8 )
                applyDebuff( "target", "kill_command", 8 )
            end

            if talent.tip_of_the_spear.enabled then
                addStack( "tip_of_the_spear", nil, talent.relentless_primal_ferocity.enabled and buff.coordinated_assault.up and 3 or 1 )
            end

            if talent.wildfire_infusion.enabled then
                gainChargeTime( "wildfire_bomb", 0.5 )
            end

            if set_bonus.tier30_4pc > 0 then
                applyDebuff( "target", "shredded_armor" )
                active_dot.shredded_armor = 1 -- Only applies to last target.
            end

            if buff.mongoose_fury.up and talent.bloody_claws.enabled then
                buff.mongoose_fury.expires = buff.mongoose_fury.expires + 1.5
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

        usable = function () return buff.deathblow.up or target.health_pct < 20, "requires Deathblow buff or target health below 20 percent" end,
        handler = function ()
            removeStack ( "tip_of_the_spear" )
            removeBuff( "deathblow" )
            if talent.cull_the_herd.enabled then applyDebuff( "target", "cull_the_herd" ) end
        end,
    },
    howl_of_the_pack_leader = {
        cast = 0,
        cooldown = function() return 25 - ( 5 * talent.better_together.rank ) end,
        gcd = "off",
        hidden = true,
    },
    lunar_storm = {
        cast = 0,
        cooldown = 30,
        gcd = "off",
        hidden = true,
        readyTime = function() return buff.lunar_storm_cooldown.remains end,
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
        cooldown = function() return 30 - ( 5 * talent.no_hard_feelings.rank ) end,
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
            return 30 - ( buff.bestial_barrage.up and 10 or 0 )
        end,
        spendType = "focus",

        talent = "mongoose_bite",
        startsCombat = true,

        handler = function ()
            spec.abilities.raptor_strike.handler()
            if buff.mongoose_fury.down then applyBuff( "mongoose_fury" )
            else
                local r = buff.mongoose_fury.expires
                applyBuff( "mongoose_fury", buff.mongoose_fury.remains, min( 5, buff.mongoose_fury.stack + 1 ) )
                buff.mongoose_fury.expires = r
            end
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
            return 30 - ( buff.bestial_barrage.up and 10 or 0 )
        end,
        spendType = "focus",

        cycle = function() return talent.vipers_venom.enabled and "serpent_sting" or nil end,

        talent = "raptor_strike",
        startsCombat = true,
        indicator = function () return ( ( debuff.latent_poison_injection.down and active_dot.latent_poison_injection > 0 ) or ( debuff.latent_poison.down and active_dot.latent_poison > 0 ) ) and "cycle" or nil end,

        notalent = "mongoose_bite",

        handler = function ()
            if buff.strike_it_rich.up then
                removeBuff( "strike_it_rich" )
                reduceCooldown( "wildfire_bomb", 10 )
            end

            if talent.dire_summons.enabled and buff.howl_of_the_pack_leader_cooldown.up then buff.howl_of_the_pack_leader_cooldown.expires = buff.howl_of_the_pack_leader_cooldown.expires - 1 end

            removeStack( "tip_of_the_spear" )

            if talent.vipers_venom.enabled then
                if talent.contagious_reagents.enabled and debuff.serpent_sting.up then
                    active_dot.serpent_sting = min( true_active_enemies, active_dot.serpent_sting + 4 )
                end
                applyDebuff( "target", "serpent_sting" )
            end

            -- Legacy / PvP Stuff
            if azerite.wilderness_survival.enabled then
                gainChargeTime( "wildfire_bomb", 1 )
            end
            if azerite.primeval_intuition.enabled then addStack( "primeval_intuition", nil, 1 ) end
            if azerite.blur_of_talons.enabled and buff.coordinated_assault.up then addStack( "blur_of_talons", nil, 1) end
            if legendary.butchers_bone_fragments.enabled then addStack( "butchers_bone_fragments", nil, 1 ) end
            if set_bonus.tier31_2pc > 0 then removeBuff( "bestial_barrage" ) end
            if legendary.latent_poison_injection.enabled then
                removeDebuff( "target", "latent_poison" )
                removeDebuff( "target", "latent_poison_injection" )
            end
            if azerite.wilderness_survival.enabled then
                gainChargeTime( "wildfire_bomb", 1 )
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
        charges = function () if talent.guerrilla_tactics.enabled then return 2 end end,
        cooldown = 18,
        recharge = function() if talent.guerrilla_tactics.enabled then return 18 * haste end end,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        spend = 10,
        spendType = 'focus',

        talent = "wildfire_bomb",
        startsCombat = true,
        texture = 2065634,
        velocity = 35,

        toggle = function ()
            if buff.lunar_storm_ready.up then
                local dyn = state.settings.lunar_toggle
                if dyn == "none" then return "none" end
                if dyn == "default" then return nil end
                return dyn
            end
            return "none"
        end,

        start = function ()
            removeBuff( "flame_infusion" )
            removeBuff( "coordinated_assault_empower" )
            if buff.contained_explosion.up then
                removeBuff( "contained_explosion" )
                gainCharges( 1, "wildfire_bomb" )
            end
            if talent.lunar_storm.enabled and buff.lunar_storm_cooldown.down then
                applyDebuff( "target", "lunar_storm" )
                applyBuff( "lunar_storm_cooldown" )
            end
        end,

        impact = function ()
            applyDebuff( "target", "wildfire_bomb_dot" )
            removeStack ( "tip_of_the_spear" )
            removeBuff( "wildfire_arsenal" )
        end,

        impactSpell = "wildfire_bomb",

        impactSpells = {
            wildfire_bomb = true,
        },

        copy = 265157
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

    potion = "tempered_potion",

    package = "Survival"
} )

local beastMastery = class.specs[ 253 ]

spec:RegisterSetting( "pet_healing", 0, {
    name = strformat( "%s Below Health %%", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.mend_pet.id ) ),
    desc = strformat( "If set above zero, %s will be recommended when your pet falls below this health percentage. Set to 0 to disable the feature.", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.mend_pet.id ) ),
    icon = 132179,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "1.5"
} )

spec:RegisterSetting( "use_harpoon", true, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( spec.abilities.harpoon.id ) ),
    desc = strformat( "If checked, %s will be recommended when you are out of range and it is available.", Hekili:GetSpellLinkWithTexture( spec.abilities.harpoon.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "mark_any", false, {
    name = strformat( "%s Any Target", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.hunters_mark.id ) ),
    desc = strformat( "If checked, %s may be recommended for any target rather than only bosses.", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.hunters_mark.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "lunar_toggle", "none", {
    name = strformat( "|T2065634:0|t %s: Special Toggle", Hekili:GetSpellLinkWithTexture( spec.talents.lunar_storm[2] ) ),
    desc = strformat(
        "When %s is talented and is not on cooldown, %s will only be recommended if the selected toggle is active.\n\n" ..
        "This setting will be ignored if you have set %s's toggle in |cFFFFD100Abilities and Items|r.\n\n" ..
        "Select |cFFFFD100Do Not Override|r to disable this feature.",
        Hekili:GetSpellLinkWithTexture( spec.talents.lunar_storm[2] ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.wildfire_bomb.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.wildfire_bomb.id )
    ),
    type = "select",
    width = 2,
    values = function ()
        local toggles = {
            none       = "Do Not Override",
            default    = "Default |cffffd100(" .. ( spec.abilities.wildfire_bomb.toggle or "none" ) .. ")|r",
            cooldowns  = "Cooldowns",
            essences   = "Minor CDs",
            defensives = "Defensives",
            interrupts = "Interrupts",
            potions    = "Potions",
            custom1    = spec.custom1Name or "Custom 1",
            custom2    = spec.custom2Name or "Custom 2",
        }
        return toggles
    end
} )

spec:RegisterPack( "Survival", 20250505, [[Hekili:TZ1EZnQrs8plUUQ4Stwjlq(1MtYv5BJtUDJJ3TI8w7)jadJK4mp0bi71PuXN9R7bemaZads2B8MYvsLS2ttp90t)4x30StvNEZ0j2MXKPxRnq74bW)0x9KJvp6TtNe)4sY0jlnTUZCo8h8n9G)7KvH37CVPlUWJUbM2idIcwfAblUioEz0pD4HZDIxS62(wbEhg54TY1m2jW3k0Cwm(ZwhERBWThgVG8Gz4daPo(hEHfsYNcDccDIF8kNO4OdxSYpMeQhLTJ9XhD6KBx54g)E)P3YvUhE60jMRIxeecIQJ37azYX2MKsojcEEK8EdW)9Nsmqssm(8sKtjFiDPJ6PoexA1YLbHXjgljW)jKaYa5njgwMlrjnI(hDDD8NNyeTKy5mZXIsBu)cgn4KQ7HXpMyCBGzOU1cZW5575WEAQPKAvq6(lcEWfo(EEb(6Het7htm6178edMFFF6V)Gc(OoO2wwNp50R1t7mG(B(YxGhIygf4NyOLySQKcrRN6ParFkK46454BgcYHQAF1eJl(0vuIGt6B7PPb6e1b5NK3vIpajN1t7iGeG0bNLtYYSR86eRQbe9loFnX43CCDtmExGNNPVnqyeypMy4aY6fF8Yed0ekXWZ8ReyXFjWAvubtgGcZFqWBi4w8)qTO(Nrjg)Uz4DWfhjogVbZi)0EA4b93D8dcHfD82iu)lCtj1E(IhdnyUzbqXxmHN8luB6PtCrZyQ)bXp2YLyEpb(PRP(CeFZBDj2t)3G9k12F6KhCCTN5es0VnWlZCn0zz6AtU86BE)1xEvIX61jg)8L)YfF(QBYo)x8UBE)hV(Q3pbyl8eGe6yoDYEGH2QzZ67UcUX0JIdc90TccCTdEaTA8mD8JMgdUpcKM7aLo8auDolFPmfmfGJKljkshUa9mD1NrcdSG7X(RwMyOKT3Xol1dMPdE66WnGzy)OyiAsIXiWqb45JGorpg9da1eOwaPzyfPPY(kIHGtXa62MFclPm7N6TfPplm94z6sFg1(NMQq76J920hB)eJytut0hj3m02He2pt6lloWFaw1hSLS1nJImx5gV5sGQoaNUFiXyULDFWooX4Gu(VH5RITwqcFKpRZxLLFzCsKXfOPpsW9EieGliu)wqVxt9hfh6Chr3jwp0XArPR6klXvw4DHFmkgB27nhfwbdO5eHgf714faRkSL7N2V3tTz3iPCUprj90T38TG3Zwf(4gYiMZDjiNptiN3VfNTXuRlux0gzqe9dyedxt)7GOJ6PxTOq82ogRygnymMZZYmcSmiZj(unjDbXgfQdyTkiFDPBqeK(vpArqCfBd1Qrt3kvEnVd1QHfRWwBIz8cagZdfw6k5gBrow6eVngAvut0ZaUdvd11IdyHPUvGFS5CNGvry2CqLcyoY3lUQt581R)KXywOzuJ7n5T28OER(Z)eSmlFzOXsrCOP))daR58NuJO6xDIJ1VFEQz0ij8oDt)h34oJIxFNi4MkkIgOe074wcMh2bX9tbngP7rtWpEtEHSNl2XdoIb6lTI1pBa1kqJXmG9H5fJSqcbGE9xqmDJxG8IAtd)kD8xbsnJAI4BRdRKhQJZTaIJup9h0ridPah0tXBBzh1CiWSZoXN45qsd4oK1yKc(lZdaXYRd4qSlcdcGta3Bl0krsjAPBulX6QksNtJa9SkszORAmqPqn1EpFsgI8lvDvn2PeQRNz5QqNLgVT1a7LqK(zeqCfK5oZajgsGtqiY(bikyO8iIlsACac2hqmkigvPOlMHwM(ONAyiiOvd5xkmZTMZPAg48FxuvkhYsPRZ8fXr6)3v2Z9QXv4hbPZcHjupyxwTtOFmNaEm6TuLRJ3ss4mOIdaAGfeaW036r9is4kVcw2anFxgAm9KB6cScapPVKMEaKegiO8wmvX7kU4OItUmyPzUYWK9q4yBExtTKQD3X6YG3ArWCKE0BLfQattak(9PLX04JYUhk1PdfZw3AXNb5kkJF0HVvLiEeRNzLAMl5CkkFRiXE)C1g3GT6p849Kq)cvjJEM)dG3XDHCcl5hW)0lgiqBO7LTiGcffNkaoTuOx(LRDgln8kuQm5Itm2ba8CRzAxkJOnJL2lTjRZcIAHWXcYd(sPWdUvdGOrBOdwWzDza(hkHu4DF8Jx9ZF8lxpruRQYtOTkIONXd6XcYiFF)s3aCcMxrbXl7WMOIS1qvNQmEwUXa55rk7ixWPccyFEP2jgpj3GaBD0iU5S)F)Ecb8neimcKgaXLYdbXFhoLyQi6DjV8pF)EaZayMHq02HKMFEiJbmGnKeIjlAjjffAkSVZqW46LAb6XmjO(os5uOewgq))CQnwcu)tWGFbZMPdW7O1X1ETefQvesilkYCiI9GSK9vN2yDXYaSUsBYRPploI4Xa4SxuZ52ZQ6WgkjfdnasnG94eM4f0xzt1u6XzTFOHCqvsyxnngh8EpbivZ7y)lomKLYe)PlE3VLyC1Lx8Zx(hPmBY7V(xV6YeJBU4p(1lVHnbD)MZ1kNrtxEfi1ELfvaS1yIrz2fbfh2sEijXFwhQSOYpe3FxSiDW1Ejync8b4gS5w3r7Hs960PrHrKKP9kA)YrRe2H40RDMUcuAd30wajl(OLJKmsJstcZO8fZBoMcp1uJvVkDjlITbevWVmHgeezQ9cF22nTSHj7vtmNo91bRDg7SqthBDY94TRPTnCD(v8vDNABjAnL6lHVcFGZhnO8lEIBTCQDRQYYnjSP2eiSEODP0VCnLmzyytC8KKmczyMuIn5Ean9KaF6AVCiXnMgBIqtHNv7EiV2driqQLlueVNSu8GIkJRyuCMSToioVj)n29sPghdb2RCse3Mn6tQ5KalNVRZg)efST5i8T0SU22u(fbvSDEb(Zdca82BIUl(vYTVeMFuT4SvWriKK22kDeSbTic2jtrPiAvRPlSKFal2X5XPaaUKJ8rB4rRoson4DEMeqmeNT)L2qSSlyeKklEhIJ1QZxznqfhF(1xivBxBtW(lgeqBoGJY73FDCaIHc0sJhZJ3G3T80TfHUktkxdKArVAajsR2Df78wfH7zcyR6Xnh3OgGjzu4nPbprwulDcguRWSEsq0jA4YAfrNMOPxylgO2M6hsxrZHIwxJ3jFeG2C)fJBtB36QJaGBA7WO72iYnTwcl0gkQTd6M2ocySZy30edw8vWBpNG30KPbrAI7q0ln4BApFVq9HYnNysUHpHW3g214S)De(2WwEZ4pZW3gUdja((e(2WwYm1v4BdpwA4Bdprg4Bdf9EiF6HVnuoKI8MQeqQVNegHuN(X8D0GtaTTzOpouitN8Ep8dXdJwEA67daNoe63wv)KpGJTzWmhCu0)h)JeJN)VaXKpG7ZNxMorRPFHDPFbA4h02pbqgbFEiwT2j4auIVuBid8PdF7q1tSt(qYhspar9ZN20FC8HfZxk)138ovFd(oHhl(vcZ)PzhDZ34mB8(1gG01Rlp8OhOG8HZyJoEGc3Xf9CTbYi5CMaugvcqE6xva7VP(xra7QFJpAOeMnq)4Uv(JayeZhaa7tuDoStvfw2rTte(UUFt6ODpwf3XmzpRJ8JgQ088HlZoKo6TnSlNRTZ7sAdYB(KS3tXMiZHP1ncDV32HBNvmzXE8Msr(gRYsx5HDNDLsZ2o7cvgLD0jcKAUdAxHFjyYHUmPZxhQA4n3Dk1M5UQmOyw1qE0qXoRxVN4PNrXs4SKu8C5lP0aNsdixwgD8VpaQoJ8vW9gqoRJszMbFWdqeDh)zRWeoVuobLL(YZk3ltzmFs3EzkEfZJ2ld5dsdvm3gJuhwvEthDmQScjPuknDCJ0oE96)6pcvfzzbL8gMbBlnKmZ0QDEwPh9g0xv0geHpJmv(VET4dBnFSOAZxgUnvglTZhFcn2A9bNQ23Epd(NSCQiWUnIHShbUCHbcD18i5w31(CvuAOnvJaTEMjv9VrefoFAkNpqi5iVuQUgAukK9n0(mEN(MsJMF8BSKBLgQ)CKk3nTuTEBLyTF25xM5amxz1(ma2gPKcspGRCxPhl5Aq(QNXAzBOGL5R920enUl2yOfwbTAhOArupFax2uUm6T6QK2dMFSOrrJYBseeXPwB6oxT)XI3guiYpi1(yo2G0o9d5ORbdYGb2PP8KDpIILqzS)U6VDW61VW8nON7Y2jYgVwrgIWqK12VDk1aLdDZtUS7bLbTKxzpHZJA1kLbmnNRQPS)EI7E0614MZBmphpO(LrlsM4Trr0UmkBHS6aveoeP1KfEbZQ7PiipCPKEYKbQ2XF7zmNB8UhtfUu53401R5)7vQ3m1ZpIZvClPbO0imlSurQeh2gouThfBtyQDiu3610TC0WbhitaNYMOJ16QBrdUFDHv8v0vZEY5mKL)rU)UQQGxfnUP6vo9qr1Wn(Ab4ZP2mp21lxzpan7Ezj7B)dGvCktbosq(Bbl4AV6r5syP9dqkRdWENM(4zHalE4Q)Lov5uCLuiplvViyVQhRU0YCoYS(nfAPItohfxBQEHMgDp6RigvpZ)(7ci(d2sxiXryfWqrGX3bpOMe9TdSDxSELkKRSmKg)S7dMu5nkkE8ohdvQ0R7C2Xd4SP7aQ4CES94I5F23EeyvJeq5DPx7RumNFB)4W6Ax8736f)51FF69Wy)knfq5zoV1b7AIloQg(zgeHe9BqwHTepEBgRIYWkYaT4aiy4BQNTvQn9Bc47MSrhPXI(MNjbFhrUdTrrto5mzmCVu6wsmLTXp9jP0m1J3rvdNNUPS8IkOiFTNQeUTXSMlwPdPBFkkArkxkz8iEnHRSgZVMW91eUVMW91eUDWp91eU7scx63lIf(LvCmDOpN()p]] )
