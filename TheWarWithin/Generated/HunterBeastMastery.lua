-- HunterBeastMastery.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 253 )

-- Resources
spec:RegisterResource( Enum.PowerType.Focus )

spec:RegisterTalents( {
    -- Hunter Talents
    binding_shackles        = { 102388, 321468, 1 }, -- Targets stunned by Binding Shot, knocked back by High Explosive Trap, knocked up by Implosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal $s1% less damage to you for $321469d after the effect ends.
    binding_shot            = { 102386, 109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within $s2 yds for $d, stunning them for $117526d if they move more than $s2 yds from the arrow.$?s321468[; Targets stunned by Binding Shot deal $321469s1% less damage to you for $321469d after the effect ends.][]
    blackrock_munitions     = { 102392, 462036, 1 }, -- The damage of Explosive Shot is increased by $s1%.
    born_to_be_wild         = { 102416, 266921, 1 }, -- Reduces the cooldowns of $?c3[Aspect of the Eagle, ][]Aspect of the Cheetah, and Aspect of the Turtle by ${$s1/-1000} sec.
    bursting_shot           = { 102421, 186387, 1 }, -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by $s4% for $d, and dealing $s1 Physical damage.$?s378771[; When you fall below $378771s1% heath, Bursting Shot's cooldown is immediately reset. This can only occur once every $385646d.][]
    camouflage              = { 102414, 199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for $d. While camouflaged, you will heal for $s4% of maximum health every $T4 sec.
    concussive_shot         = { 102407, 5116  , 1 }, -- Dazes the target, slowing movement speed by $s1% for $d.; $?s193455[Cobra Shot][Steady Shot] will increase the duration of Concussive Shot on the target by ${$56641m3/10}.1 sec.
    devilsaur_tranquilizer  = { 102415, 459991, 1 }, -- If Tranquilizing Shot removes only an Enrage effect, its cooldown is reduced by $s1 sec.
    disruptive_rounds       = { 102395, 343244, 1 }, -- When Tranquilizing Shot successfully dispels an effect or $?c3[Muzzle][Counter Shot] interrupts a cast, gain $s1 Focus.
    emergency_salve         = { 102389, 459517, 1 }, -- Feign Death and Aspect of the Turtle removes poison and disease effects from you.
    entrapment              = { 102403, 393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for $393456d. Damage taken may break this root.
    explosive_shot          = { 102420, 212431, 1 }, -- Fires an explosive shot at your target. After $t1 sec, the shot will explode, dealing $212680s1 Fire damage to all enemies within $212680A1 yds. Deals reduced damage beyond $s2 targets.
    ghillie_suit            = { 102385, 459466, 1 }, -- You take $s1% reduced damage while Camouflage is active.; This effect persists for 3 sec after you leave Camouflage.
    high_explosive_trap     = { 102739, 236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies away. Limit $s2. Trap will exist for $236775d.$?s321468[; Targets knocked back by High Explosive Trap deal $321469s1% less damage to you for $321469d after being knocked back.][]
    hunters_avoidance       = { 102423, 384799, 1 }, -- Damage taken from area of effect attacks reduced by $s1%.
    implosive_trap          = { 102739, 462031, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies up. Limit $s2. Trap will exist for $236775d.$?s321468[; Targets knocked up by Implosive Trap deal $321469s1% less damage to you for $321469d after being knocked up.][]
    improved_kill_shot      = { 102410, 343248, 1 }, -- Kill Shot's critical damage is increased by $s1%.
    improved_traps          = { 102418, 343247, 1 }, -- The cooldown of Tar Trap, High Explosive Trap, Implosive Trap, and Freezing Trap is reduced by ${$m1/-1000}.1 sec.
    intimidation            = { 102397, 19577 , 1 }, -- $?a459507[Intimidate the target][Commands your pet to intimidate the target], stunning it for $24394d.$?s321468[; Targets stunned by Intimidation deal $321469s1% less damage to you for $321469d after the effect ends.][]
    keen_eyesight           = { 102409, 378004, 2 }, -- Critical strike chance increased by $s1%.
    kill_shot               = { 102379, 320976, 1 }, -- You attempt to finish off a wounded target, dealing $s1 Physical damage. Only usable on enemies with less than $s2% health.
    kindling_flare          = { 102425, 459506, 1 }, -- Stealthed enemies revealed by Flare remain revealed for ${$s1/1000} sec after exiting the flare.
    kodo_tranquilizer       = { 102415, 459983, 1 }, -- Tranquilizing Shot removes up to $s1 additional Magic effect from up to $s3 nearby targets.
    lone_survivor           = { 102391, 388039, 1 }, -- Reduce the cooldown of Survival of the Fittest by ${$m1/-1000} sec, and increase its duration by ${$s2/1000}.1 sec.; Reduce the cooldown of Counter Shot and Muzzle by ${$s3/-1000} sec.
    misdirection            = { 102419, 34477 , 1 }, -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within $d and lasting for $35079d.
    moment_of_opportunity   = { 102426, 459488, 1 }, -- When a trap triggers, you gain Aspect of the Cheetah for 3 sec.; Can only occur every 1 min.
    natural_mending         = { 102401, 270581, 1 }, -- Every $s1 Focus you spend reduces the remaining cooldown on Exhilaration by ${$m2/1000}.1 sec.
    no_hard_feelings        = { 102412, 459546, 1 }, -- When Misdirection targets your pet, it reduces the damage they take by $459547s1% for $459547d.
    padded_armor            = { 102406, 459450, 1 }, -- Survival of the Fittest gains an additional charge.
    pathfinding             = { 102404, 378002, 1 }, -- Movement speed increased by $s1%.
    posthaste               = { 102411, 109215, 1 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by $s2% for $118922d.
    quick_load              = { 102413, 378771, 1 }, -- When you fall below $s1% health, Bursting Shot and Scatter Shot have their cooldown immediately reset. This can only occur once every $385646d.
    rejuvenating_wind       = { 102381, 385539, 1 }, -- Maximum health increased by $s2%, and Exhilaration now also heals you for an additional ${$s1}.1% of your maximum health over $385540d.
    roar_of_sacrifice       = { 102405, 53480 , 1 }, -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but $s2% of all damage taken by that target is also taken by the pet.  Lasts $d.
    scare_beast             = { 102382, 1513  , 1 }, -- Scares a beast, causing it to run in fear for up to $d.  Damage caused may interrupt the effect.  Only one beast can be feared at a time.
    scatter_shot            = { 102421, 213691, 1 }, -- A short-range shot that deals $s1 damage, removes all harmful damage over time effects, and incapacitates the target for $d.  Any damage caused will remove the effect. Turns off your attack when used.$?s321468[; Targets incapacitated by Scatter Shot deal $321469s1% less damage to you for $321469d after the effect ends.][]
    scouts_instincts        = { 102424, 459455, 1 }, -- You cannot be slowed below $186257s2% of your normal movement speed while Aspect of the Cheetah is active.
    scrappy                 = { 102408, 459533, 1 }, -- Casting $?a137017[Wildfire Bomb]?a137016[Aimed Shot][Kill Command] reduces the cooldown of Intimidation and Binding Shot by ${$s1/1000}.1 sec.
    serrated_tips           = { 102384, 459502, 1 }, -- You gain $s1% more critical strike from critical strike sources.
    specialized_arsenal     = { 102390, 459542, 1 }, -- $?a137017[Wildfire Bomb]?a137016[Aimed Shot][Kill Command] deals $s1% increased damage.; 
    survival_of_the_fittest = { 102422, 264735, 1 }, -- Reduces all damage you and your pet take by $s1% for $d.
    tar_trap                = { 102393, 187698, 1 }, -- Hurls a tar trap to the target location that creates a $187699s1 yd radius pool of tar around itself for $13810d when the first enemy approaches. All enemies have $135299s1% reduced movement speed while in the area of effect. Limit $s2. Trap will exist for $13809d.
    tarcoated_bindings      = { 102417, 459460, 1 }, -- Binding Shot's stun duration is increased by ${$s1/1000} sec.
    territorial_instincts   = { 102394, 459507, 1 }, -- Casting Intimidation without a pet now summons one from your stables to intimidate the target.; Additionally, the cooldown of Intimidation is reduced by ${$abs($s2)/1000} sec.
    trailblazer             = { 102400, 199921, 1 }, -- Your movement speed is increased by $s2% anytime you have not attacked for ${$s1/1000} sec.
    tranquilizing_shot      = { 102380, 19801 , 1 }, -- Removes $s1 Enrage and $s2 Magic effect from an enemy target.$?s343244[; Successfully dispelling an effect generates $343244s1 Focus.][]
    trigger_finger          = { 102396, 459534, 2 }, -- You and your pet have ${$s2}.1% increased attack speed.; This effect is increased by $s3% if you do not have an active pet.
    unnatural_causes        = { 102387, 459527, 1 }, -- Your damage over time effects deal $s1% increased damage.; This effect is increased by $s2% on targets below $s3% health.
    wilderness_medicine     = { 102383, 343242, 1 }, -- Mend Pet heals for an additional ${$m1*$136d/$136t1}% of your pet's health over its duration, and has a $s2% chance to dispel a magic effect each time it heals your pet.

    -- Beast Mastery Talents
    a_murder_of_crows       = { 102352, 459760, 1 }, -- [131894] Summons a flock of crows to attack your target, dealing ${$131900s1*16} Physical damage over $d.
    alpha_predator          = { 102368, 269737, 1 }, -- Kill Command now has ${$s1+1} charges, and deals $s2% increased damage.
    animal_companion        = { 102361, 267116, 1 }, -- Your Call Pet additionally summons the pet from the bonus slot in your stable. This pet will obey your Kill Command, but cannot use pet family abilities and both of your pets deal $s2% reduced damage.
    aspect_of_the_beast     = { 102351, 191384, 1 }, -- Increases the damage and healing of your pet's abilities by $s1%.; Increases the effectiveness of your pet's Predator's Thirst, Endurance Training, and Pathfinding passives by $s3%.
    barbed_shot             = { 102377, 217200, 1 }, -- Fire a shot that tears through your enemy, causing them to bleed for ${$s1*$s2} damage over $d$?s257944[ and  increases your critical strike chance by $257946s1% for $257946d, stacking up to $257946u $Ltime:times;][].; Sends your pet into a frenzy, increasing attack speed by $272790s1% for $272790d, stacking up to $272790u times.; Generates ${$246152s1*$246152d/$246152t1} Focus over $246152d.
    barbed_wrath            = { 102373, 231548, 1 }, -- Barbed Shot reduces the cooldown of Bestial Wrath by ${$m1/1000}.1 sec.
    barrage                 = { 102335, 120360, 1 }, -- Rapidly fires a spray of shots for $120360d, dealing an average of $<damageSec> Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond $120361s1 targets.; $?c1[Grants Beast Cleave.][]
    basilisk_collar         = { 102367, 459571, 2 }, -- Each damage over time effect on a target increases the damage they receive from your pet's attacks by $s1%.
    beast_cleave            = { 102341, 115939, 1 }, -- After you Multi-Shot, your pet's melee attacks also strike all nearby enemies for $s1% of the damage$?s378207[and Kill Command strikes all nearby enemies for $378207s1% of the damage][] for the next ${$s2/1000}.1 sec. Deals reduced damage beyond $118459s2 targets.
    beast_of_opportunity    = { 94979, 445700, 1 }, -- $?a137015[Bestial Wrath]?s137017[Coordinated Assault][Bestial Wrath or Coordinated Assault] calls on the pack, summoning a pet from your stable for $s1 sec.
    bestial_wrath           = { 102340, 19574 , 1 }, -- Sends you and your pet into a rage, instantly dealing $<damage> Physical damage to its target, and increasing all damage you both deal by $s1% for $d. Removes all crowd control effects from your pet. $?s231548[; Bestial Wrath's remaining cooldown is reduced by $s3 sec each time you use Barbed Shot][]$?s193532[ and activating Bestial Wrath grants $s2 $Lcharge:charges; of Barbed Shot.][]$?s231548&!s193532[.][]
    black_arrow             = { 94987, 430703, 1 }, -- Fire a Black Arrow into your target, dealing $o1 Shadow damage over $d.; Each time Black Arrow deals damage, you have a $s2% chance to generate a charge of $?a137015[Barbed Shot]?a137016[Aimed Shot and reduce its cast time by $439659s2%][Barbed Shot or Aimed Shot].
    bloodshed               = { 102362, 321530, 1 }, -- Command your pet to tear into your target, causing your target to bleed for $<damage> over $321538d and take $321538s2% increased damage from your pet by for $321538d.
    bloody_frenzy           = { 102339, 407412, 1 }, -- While Call of the Wild is active, your pets have the effects of Beast Cleave, and each time Call of the Wild summons a pet, all of your pets Stomp.
    brutal_companion        = { 102350, 386870, 1 }, -- When Barbed Shot causes Frenzy to stack up to $s1, your pet will immediately use its special attack and deal $s2% bonus damage.
    call_of_the_wild        = { 102336, 359844, 1 }, -- You sound the call of the wild, summoning $s1 of your active pets for $d. During this time, a random pet from your stable will appear every $t2 sec to assault your target for $361582d. ; Each time Call of the Wild summons a pet, the cooldown of Barbed Shot and Kill Command are reduced by $s3%.
    cobra_senses            = { 102356, 378244, 1 }, -- Cobra Shot reduces the cooldown of Kill Command by an additional ${$m1/-1000}.1 sec.
    cobra_shot              = { 102354, 193455, 1 }, -- A quick shot causing ${$s2*$<mult>} Physical damage.; Reduces the cooldown of Kill Command by $?s378244[${$s3+($378244s1/-1000)}][$s3] sec.
    cornered_prey           = { 94984, 445702, 1 }, -- Disengage increases the range of all your attacks by $s1 yds for $s2 sec.
    counter_shot            = { 102292, 147362, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for $d.
    covering_fire           = { 94969, 445715, 1 }, -- $?a137015[Kill Command increases the duration of Beast Cleave by $s1 sec.][Wildfire Bomb reduces the cooldown of Butchery by $s2 sec.]
    cull_the_herd           = { 94967, 445717, 1 }, -- Kill Shot deals an additional $s1% damage over $449233d and increases the bleed damage you and your pet deal to the target by $s3%.
    dark_chains             = { 94960, 430712, 1 }, -- Disengage will chain the closest target to the ground, causing them to move 40% slower until they move 8 yards away.
    dark_empowerment        = { 94986, 430718, 1 }, -- When Black Arrow resets the cooldown of an ability, gain $442511s1 Focus.
    darkness_calls          = { 94974, 430722, 1 }, -- All Shadow damage you and your pets deal is increased by $s1%.
    death_shade             = { 94968, 430711, 1 }, -- When you apply Black Arrow to a target, you gain the $?a137015[Hunter's Prey]?a137016[Deathblow][Deathblow or Hunter's Prey] effect.
    den_recovery            = { 94972, 445710, 1 }, -- Aspect of the Turtle, Survival of the Fittest, and Mend Pet heal the target for $s1% of maximum health over $s2 sec. Duration increased by $s3 sec when healing a target under $s4% maximum health.
    dire_beast              = { 102376, 120679, 1 }, -- Summons a powerful wild beast that attacks the target and roars, increasing your Haste by $281036s1% for $d.; Generates $281036s2 Focus.
    dire_command            = { 102365, 378743, 1 }, -- Kill Command has a $s1% chance to also summon a Dire Beast to attack your target for $120679d.
    dire_frenzy             = { 102337, 385810, 1 }, -- Dire Beast lasts an additional ${$m1/1000} sec and deals $s2% increased damage.
    embrace_the_shadows     = { 94959, 430704, 1 }, -- You heal for $s1% of all Shadow damage dealt by you or your pets.
    explosive_venom         = { 102370, 459693, 1 }, -- Every $459689u casts of Explosive Shot or Multi-Shot will apply Serpent Sting to targets hit.
    frenzied_tear           = { 94988, 445696, 1 }, -- Your pet's Basic Attack has a $s1% chance to reset the cooldown and cause Kill Command to strike a second time for $s2% of normal damage.
    furious_assault         = { 94979, 445699, 1 }, -- Consuming Frenzied Tear has a $s1% chance to $?a137015[reset the cooldown of Barbed Shot]?s259387[reduce the cost of your next Mongoose Bite by $s2%]?a137017[reduce the cost of your next Raptor Strike by $s2%][reset the cooldown of Barbed Shot or reduce the cost of Raptor Strike by $s2%] and deal $s3% more damage.
    go_for_the_throat       = { 102357, 459550, 1 }, -- Kill Command deals increased critical strike damage equal to $s2% of your critical strike chance.
    grave_reaper            = { 94986, 430719, 1 }, -- When a target affected by Black Arrow dies, the cooldown of Black Arrow is reduced by $s1 sec.
    howl_of_the_pack        = { 94992, 445707, 1 }, -- Your pet's Basic Attack critical strikes increase your critical strike damage by $462515s1% for $462515d stacking up to $462515u times.
    hunters_prey            = { 102360, 378210, 1 }, -- Kill Command has a $s1% chance to reset the cooldown of Kill Shot, and causes your next Kill Shot to be usable on any target, regardless of the target's health.
    huntmasters_call        = { 102349, 459730, 1 }, -- Every $459731u casts of Dire Beast sounds the Horn of Valor, summoning either Hati or Fenryr to battle.; Hati; Increases the damage of all your pets by $459738s2%.; Fenryr; Pounces your primary target, inflicting a heavy bleed that deals $459753o1 damage over $459753d and grants you $459735s2% Haste.
    improved_kill_command   = { 102344, 378010, 1 }, -- Kill Command damage increased by $s1%.
    kill_cleave             = { 102355, 378207, 1 }, -- While Beast Cleave is active, Kill Command now also strikes nearby enemies for $s1% of damage dealt. Deals reduced damage beyond $389448s2 targets.
    kill_command            = { 102346, 34026 , 1 }, -- Give the command to kill, causing your pet to savagely deal $<damage> Physical damage to the enemy.
    killer_cobra            = { 102375, 199532, 1 }, -- While Bestial Wrath is active, Cobra Shot resets the cooldown on Kill Command.
    killer_instinct         = { 102364, 273887, 2 }, -- Kill Command deals $s1% increased damage against enemies below $s2% health.
    kindred_spirits         = { 102359, 56315 , 2 }, -- Increases your maximum Focus and your pet's maximum Focus by $s1.
    laceration              = { 102369, 459552, 1 }, -- When your pets critically strike, they cause their target to bleed for $459555s1% of the damage dealt over $459560d. 
    master_handler          = { 102372, 424558, 1 }, -- Each time Barbed Shot deals damage, the cooldown of Kill Command is reduced by ${$m1/1000}.2 sec.
    multishot               = { 102363, 2643  , 1 }, -- Fires several missiles, hitting all nearby enemies within $A2 yds of your current target for $s2 Physical damage$?s115939[ and triggering Beast Cleave][]. Deals reduced damage beyond $s1 targets.$?s19434[; Generates $213363s1 Focus per target hit.][]
    overshadow              = { 94961, 430716, 1 }, -- $?a137015[Barbed Shot and Kill Command deal $s2% increased damage.][Aimed Shot and Rapid Fire deal $s1% increased damage.]
    pack_assault            = { 94966, 445721, 1 }, -- Vicious Hunt and Pack Coordination now stack and apply twice, and are always active during $?a137015[Call of the Wild]?a137017[Coordinated Assault][Call of the Wild and Coordinated Assault].
    pack_coordination       = { 94985, 445505, 1 }, -- Attacking with Vicious Hunt instructs your pet to strike with their Basic Attack along side your next $?a137015[Barbed Shot]?s259387[Mongoose Bite]?a137017[Raptor Strike][Barbed Shot or Raptor Strike].
    pack_tactics            = { 102374, 321014, 1 }, -- Passive Focus generation increased by $s1%.
    piercing_fangs          = { 102371, 392053, 1 }, -- While Bestial Wrath is active, your pet's critical damage dealt is increased by $392054s1%.
    savagery                = { 102353, 424557, 1 }, -- Kill Command damage is increased by $s1%. Barbed Shot lasts ${$m2/1000}.1 sec longer.
    scattered_prey          = { 94969, 445768, 1 }, -- $?a137015[Multi-Shot][Butchery] increases the damage of your next $?a137015[Multi-Shot][Butchery] by $s1%.
    scent_of_blood          = { 102342, 193532, 2 }, -- Activating Bestial Wrath grants $s1 $Lcharge:charges; of Barbed Shot.
    shadow_erasure          = { 94974, 430720, 1 }, -- Kill Shot has a $s2% chance to generate a charge of $?a137015[Barbed Shot]?a137016[Aimed Shot][Barbed Shot or Aimed Shot] when used on a target affected by Black Arrow.
    shadow_hounds           = { 94983, 430707, 1 }, -- Each time Black Arrow deals damage, you have a $s1% chance to manifest a Dark Hound to charge to your target and deal Shadow damage.
    shadow_lash             = { 94957, 430717, 1 }, -- When $?a137015[Call of the Wild]?a137016[Trueshot][Call of the Wild or Trueshot] is active, Black Arrow deals damage 50% faster.
    shadow_surge            = { 94982, 430714, 1 }, -- When Multi-Shot hits a target affected by Black Arrow, a burst of Shadow energy erupts, dealing moderate Shadow damage to all enemies near the target.; This can only occur once every $s1 sec.
    shower_of_blood         = { 102366, 459729, 1 }, -- Bloodshed now hits ${$s1-1} additional nearby targets.
    smoke_screen            = { 94959, 430709, 1 }, -- Exhilaration grants you $s1 sec of Survival of the Fittest.; Survival of the Fittest activates Exhilaration at $s2% effectiveness.
    stomp                   = { 102347, 199530, 1 }, -- When you cast Barbed Shot, your pet stomps the ground, dealing $<damage> Physical damage to all nearby enemies.
    thrill_of_the_hunt      = { 102345, 257944, 1 }, -- Barbed Shot increases your critical strike chance by $257946s1% for $257946d, stacking up to $s2 $Ltime:times;.
    tireless_hunt           = { 94984, 445701, 1 }, -- Aspect of the Cheetah now increases movement speed by $s1% for another $s2 sec.
    training_expert         = { 102348, 378209, 2 }, -- All pet damage dealt increased by $s1%.
    venomous_bite           = { 102366, 459667, 1 }, -- Bloodshed increases all damage taken from your pet by an additional $321538s2%, and Kill Command deals $459668s1% increased damage to the target.
    venoms_bite             = { 102358, 459565, 1 }, -- [271788] Fire a shot that poisons your target, causing them to take $?s389882[${$m1*(1+($389882m1/100))}][$s1] Nature damage instantly and an additional $?s389882[${$o2*(1+($389882m1/100))}][$o2] Nature damage over $d.$?s378014[; Serpent Sting's damage applies Latent Poison to the target, stacking up to $378015u times. $@spelldesc393949 consumes all stacks of Latent Poison, dealing $378016s1 Nature damage to the target per stack consumed.][]
    vicious_hunt            = { 94991, 445404, 1 }, -- Kill Command prepares you to viciously attack in coordination with your pet, dealing an additional $445431s1 Physical damage with your next Kill Command.
    war_orders              = { 102343, 393933, 1 }, -- Barbed Shot deals $s2% increased damage, and applying Barbed Shot has a $s3% chance to reset the cooldown of Kill Command.
    wild_attacks            = { 94962, 445708, 1 }, -- Every third pet Basic Attack is a guaranteed critical strike, with damage further increased by critical strike chance.
    wild_call               = { 102338, 185789, 1 }, -- Your auto shot critical strikes have a $s1% chance to reset the cooldown of Barbed Shot.
    wild_instincts          = { 102339, 378442, 1 }, -- While Call of the Wild is active, each time you Kill Command, your Kill Command target takes $424567s1% increased damage from all of your pets, stacking up to $424567u times.
    withering_fire          = { 94993, 430715, 1 }, -- When Black Arrow resets the cooldown of $?a137015[Barbed Shot]?a137016[Aimed Shot][Barbed Shot or Aimed Shot], a barrage of dark arrows will strike your target for Shadow damage and increase the damage you and your pets deal by 10% for 6 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting     = 3604, -- (356719) Stings the target, dealing $s1 Nature damage and initiating a series of venoms. Each lasts $356723d and applies the next effect after the previous one ends.; $@spellicon356723 $@spellname356723:; $356723s1% reduced movement speed.; $@spellicon356727 $@spellname356727:; Silenced.; $@spellicon356730 $@spellname356730:; $356730s1% reduced damage and healing.
    diamond_ice         = 5534, -- (203340) Victims of Freezing Trap can no longer be damaged or healed.  Freezing Trap is now undispellable, but has a $203337d duration.
    dire_beast_basilisk = 825 , -- (205691) Summons a slow moving basilisk near the target for $d that attacks the target for heavy damage.
    dire_beast_hawk     = 824 , -- (208652) Summons a hawk to circle the target area, attacking all targets within 10 yards over the next $d.
    hunting_pack        = 3730, -- (203235) Aspect of the Cheetah has $m1% reduced cooldown and grants its effects to allies within $356781A yds.
    interlope           = 1214, -- (248518) Misdirection now causes the next $248519n hostile spells cast on your target within $248519d to be redirected to your pet, but its cooldown is increased by ${$s4/1000} sec.; Your pet must be within $248519a1 yards of the target for spells to be redirected.; 
    kindred_beasts      = 5444, -- (356962) Command Pet's unique ability cooldown reduced by $s1%, and gains additional effects.$?a264663[; Ferocity: $@spellname264667 increases Haste by $357650s1% for $357650d, but no longer applies Sated.]?a264662[; Tenacity: $@spellname388035 increases maximum health of allies within $204205A yards of your pet by $204205s1% for $204205d.]?a264656[; Cunning: $@spellname53271 frees nearby allies from movement impairing effects. ][]
    survival_tactics    = 3599, -- (202746) Feign Death reduces damage taken by $m1% for $202748d.
    the_beast_within    = 693 , -- (356976) Bestial Wrath now provides immunity to Fear and Horror effects for you and your pets for $357140d. Nearby allied pets are also inspired, increasing their attack speed by $s1%.
    wild_kingdom        = 5441, -- (356707) Call in help from one of your dismissed $?a264656[Tenacity][Cunning] pets for $d. Your current pet is dismissed to rest and heal $358250s1% of maximum health.
} )

-- Auras
spec:RegisterAuras( {
    -- Under attack by a flock of crows.
    a_murder_of_crows = {
        id = 213835,
        duration = 15.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_master_of_beasts[76657] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.9, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Under attack by a flock of crows.
    a_murder_of_crows_visuals = {
        id = 189681,
        duration = 15.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_master_of_beasts[76657] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.9, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
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

        -- Affected by:
        -- born_to_be_wild[266921] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- hunting_pack[203235] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Deflecting all attacks.; Damage taken reduced by $w4%.
    aspect_of_the_turtle = {
        id = 186265,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- born_to_be_wild[266921] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Suffering $w1 damage every $t1 sec.
    barbed_shot = {
        id = 217200,
        duration = 8.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overshadow[430716] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overshadow[430716] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- savagery[424557] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- war_orders[393933] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- war_orders[393933] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Lore revealed.
    beast_lore = {
        id = 1462,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage dealt increased by $w1%.
    bestial_wrath = {
        id = 19574,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- scent_of_blood[193532] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Dealing $s1% less damage to the Hunter.
    binding_shackles = {
        id = 321469,
        duration = 8.0,
        max_stack = 1,
    },
    -- Stunned.
    binding_shot = {
        id = 117526,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- tarcoated_bindings[459460] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Suffering $s1 Shadow damage every $t1 sec.
    black_arrow = {
        id = 430703,
        duration = 18.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Bleeding for $w1 Physical damage every $t1 sec.; Taking $w2% increased damage from the Hunter's pet.
    bloodshed = {
        id = 321538,
        duration = 18.0,
        tick_time = 3.0,
        max_stack = 1,

        -- Affected by:
        -- hunter[137014] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- shower_of_blood[459729] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- venomous_bite[459667] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Disoriented.
    bursting_shot = {
        id = 224729,
        duration = 4.0,
        max_stack = 1,
    },
    -- Being assisted by a pet from your stable.
    call_of_the_wild = {
        id = 361582,
        duration = 6.0,
        max_stack = 1,
    },
    -- Stealthed.
    camouflage = {
        id = 199483,
        duration = 60.0,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    concussive_shot = {
        id = 5116,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },
    -- Bleeding for $w1 damage every $t1 sec.
    cull_the_herd = {
        id = 449233,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,
    },
    -- Taking $w2% increased Physical damage from $@auracaster.
    death_chakram = {
        id = 325037,
        duration = 10.0,
        max_stack = 1,
    },
    -- Haste increased by $s1%.
    dire_beast = {
        id = 281036,
        duration = 8.0,
        max_stack = 1,
    },
    -- Vision is enhanced.
    eagle_eye = {
        id = 6197,
        duration = 60.0,
        max_stack = 1,
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
    -- Explosive Shot and Multi-Shot will apply Serpent Sting at $u stacks.
    explosive_venom = {
        id = 459689,
        duration = 15.0,
        max_stack = 1,
    },
    -- Directly controlling pet.
    eyes_of_the_beast = {
        id = 321297,
        duration = 60.0,
        max_stack = 1,
    },
    -- Feigning death.
    feign_death = {
        id = 5384,
        duration = 360.0,
        max_stack = 1,
    },
    -- Incapacitated.; Unable to be healed or damaged.
    freezing_trap = {
        id = 203337,
        duration = 5.0,
        max_stack = 1,
    },
    -- Critical damage dealt increased by $s1%.
    howl_of_the_pack = {
        id = 462515,
        duration = 8.0,
        max_stack = 1,
    },
    -- Can always be seen and tracked by the Hunter.; Damage taken increased by $428402s4% while above $s3% health.
    hunters_mark = {
        id = 257284,
        duration = 3600,
        tick_time = 0.5,
        max_stack = 1,
    },
    -- Your next Kill Shot is usable on any target, regardless of your target's current health.
    hunters_prey = {
        id = 378215,
        duration = 15.0,
        max_stack = 1,
    },
    -- Dire Beast will summon Hati or Fenryr at $u stacks.
    huntmasters_call = {
        id = 459731,
        duration = 3600,
        max_stack = 1,
    },
    -- Redirecting spells to the Hunter's pet.
    interlope = {
        id = 248519,
        duration = 10.0,
        max_stack = 1,
    },
    -- Stunned.
    intimidation = {
        id = 24394,
        duration = 5.0,
        max_stack = 1,
    },
    -- Heals $w1% of the pet's health every $t1 sec.$?s343242[; Each time Mend Pet heals your pet, you have a $343242s2% chance to dispel a harmful magic effect from your pet.][]
    mend_pet = {
        id = 136,
        duration = 10.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- wilderness_medicine[343242] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Threat redirected from Hunter to target.
    misdirection = {
        id = 35079,
        duration = 8.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%
    no_hard_feelings = {
        id = 459547,
        duration = 5.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w2%.
    pathfinding = {
        id = 264656,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- aspect_of_the_beast[191384] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- aspect_of_the_beast[191384] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Critical damage dealt increased by $s1%.
    piercing_fangs = {
        id = 392054,
        duration = 3600,
        max_stack = 1,
    },
    -- Playing Dead.
    play_dead = {
        id = 209997,
        duration = 360.0,
        max_stack = 1,
    },
    -- Increased movement speed by $s1%.
    posthaste = {
        id = 118922,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- posthaste[109215] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Leech increased by $w2%.
    predators_thirst = {
        id = 264663,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- aspect_of_the_beast[191384] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- aspect_of_the_beast[191384] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Recently benefitted from Quick Load.
    quick_load = {
        id = 385646,
        duration = 25.0,
        max_stack = 1,
    },
    -- Heals you for $w1 every $t sec.
    rejuvenating_wind = {
        id = 385540,
        duration = 8.0,
        max_stack = 1,
    },
    -- Immune to critical strikes, but damage transferred to the Hunter's pet.
    roar_of_sacrifice = {
        id = 53480,
        duration = 12.0,
        max_stack = 1,
    },
    -- Feared.
    scare_beast = {
        id = 1513,
        duration = 20.0,
        max_stack = 1,
    },
    -- Disoriented.
    scatter_shot = {
        id = 213691,
        duration = 4.0,
        max_stack = 1,
    },
    -- $w1% reduced movement speed.
    scorpid_venom = {
        id = 356723,
        duration = 3.0,
        max_stack = 1,
    },
    -- Slowed by $s2%.; $s3% increased chance suffer a critical strike from $@auracaster.
    stampede = {
        id = 201594,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_master_of_beasts[76657] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.9, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Immobilized.
    steel_trap = {
        id = 162480,
        duration = 20.0,
        max_stack = 1,
    },
    -- All damage taken reduced by $s1%.
    survival_of_the_fittest = {
        id = 264735,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- lone_survivor[388039] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- padded_armor[459450] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Reduces damage taken by $202746s1%, up to a maximum of $w1.
    survival_tactics = {
        id = 202748,
        duration = 3.0,
        max_stack = 1,
    },
    -- Taming a pet.
    tame_beast = {
        id = 1515,
        duration = 6.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Immune to Fear and Horror effects.; Attack speed increased by $s3%.
    the_beast_within = {
        id = 357140,
        duration = 8.0,
        max_stack = 1,
    },
    -- Critical strike chance increased by $s1%.
    thrill_of_the_hunt = {
        id = 257946,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- savagery[424557] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- thrill_of_the_hunt[257944] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Dealing bonus Nature damage to the target every $t sec for $d.
    titans_thunder = {
        id = 207094,
        duration = 8.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Tracking Beasts.
    track_beasts = {
        id = 1494,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Demons.
    track_demons = {
        id = 19878,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Dragonkin.
    track_dragonkin = {
        id = 19879,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Elementals.
    track_elementals = {
        id = 19880,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Giants.
    track_giants = {
        id = 19882,
        duration = 3600,
        max_stack = 1,
    },
    -- Greatly increases stealth detection.
    track_hidden = {
        id = 19885,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Humanoids.
    track_humanoids = {
        id = 19883,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Mechanicals.
    track_mechanicals = {
        id = 229533,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Undead.
    track_undead = {
        id = 19884,
        duration = 3600,
        max_stack = 1,
    },
    -- Damage taken from $@auracaster's Kill Command is increased by $w1%.
    venomous_bite = {
        id = 459668,
        duration = 3600,
        max_stack = 1,
    },
    -- Silenced.
    wailing_arrow = {
        id = 355596,
        duration = 5.0,
        max_stack = 1,
    },
    -- The cooldown of $?s217200[Barbed Shot][Dire Beast] is reset.
    wild_call = {
        id = 185791,
        duration = 4.0,
        max_stack = 1,
    },
    -- Damage taken from $@auracaster's Pets increased by $s1%.
    wild_instincts = {
        id = 424567,
        duration = 8.0,
        max_stack = 1,
    },
    -- Assistance summoned from your stable. Current pet dismissed and healing for $358250s1% of maximum health.
    wild_kingdom = {
        id = 356707,
        duration = 10.0,
        max_stack = 1,
    },
    -- Movement speed increased by $s3%.
    windburst = {
        id = 204475,
        duration = 5.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s1%.
    wing_clip = {
        id = 195645,
        duration = 15.0,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Summons a flock of crows to attack your target, dealing ${$131900s1*16} Physical damage over $d.
    a_murder_of_crows = {
        id = 131894,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 30,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'points': 60.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_master_of_beasts[76657] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.9, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Summons a flock of crows to attack your target over the next $d. If the target dies while under attack, A Murder of Crows' cooldown is reset.
    a_murder_of_crows_213835 = {
        id = 213835,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'points': 60.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_master_of_beasts[76657] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.9, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
    },

    -- Summons a flock of crows to attack your target over the next $d. If the target dies while under attack, A Murder of Crows' cooldown is reset.
    a_murder_of_crows_visuals = {
        id = 189681,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 30,
        spendType = 'focus',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'points': 60.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_master_of_beasts[76657] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.9, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- A quick shot that causes $sw2 Arcane damage.$?s260393[; Arcane Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    arcane_shot = {
        id = 185358,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.8624, 'pvp_multiplier': 1.35, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bestial_wrath[19574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bestial_wrath[19574] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- thrill_of_the_hunt[257946] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- The Hunter takes on the aspect of a chameleon, becoming untrackable.
    aspect_of_the_chameleon = {
        id = 61648,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': UNTRACKABLE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Increases your movement speed by $s1% for $d, and then by $186258s1% for another $186258d$?a445701[, and then by $445701s1% for another $445701s2 sec][].$?a459455[; You cannot be slowed below $s2% of your normal movement speed.][]
    aspect_of_the_cheetah = {
        id = 186257,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 90.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'amplitude': 1.0, 'points': 80.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- born_to_be_wild[266921] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- hunting_pack[203235] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Deflects all attacks and reduces all damage you take by $s4% for $d, but you cannot attack.$?s83495[  Additionally, you have a $83495s1% chance to reflect spells back at the attacker.][]
    aspect_of_the_turtle = {
        id = 186265,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_MELEE_HIT_CHANCE, 'sp_bonus': 0.25, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DEFLECT_SPELLS, 'sp_bonus': 0.25, 'points': 200.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': REFLECT_SPELLS, 'amplitude': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'sp_bonus': 0.25, 'points': -30.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 26, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 9, }
        -- #6: { 'type': APPLY_AURA, 'subtype': IGNORE_HIT_DIRECTION, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_RANGED_HIT_CHANCE, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- born_to_be_wild[266921] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Fire a shot that tears through your enemy, causing them to bleed for ${$s1*$s2} damage over $d$?s257944[ and  increases your critical strike chance by $257946s1% for $257946d, stacking up to $257946u $Ltime:times;][].; Sends your pet into a frenzy, increasing attack speed by $272790s1% for $272790d, stacking up to $272790u times.; Generates ${$246152s1*$246152d/$246152t1} Focus over $246152d.
    barbed_shot = {
        id = 217200,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "barbed_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'ap_bonus': 0.475, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overshadow[430716] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overshadow[430716] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- savagery[424557] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- war_orders[393933] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- war_orders[393933] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Rapidly fires a spray of shots for $120360d, dealing an average of $<damageSec> Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond $120361s1 targets.; $?c1[Grants Beast Cleave.][]
    barrage = {
        id = 120360,
        cast = 3.0,
        channeled = true,
        cooldown = 20.0,
        gcd = "global",

        spend = 60,
        spendType = 'focus',

        talent = "barrage",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.2, 'trigger_spell': 120361, 'target': TARGET_UNIT_CASTER, }
    },

    -- Gathers information about the target beast, displaying diet, abilities, specialization, whether or not the creature is tameable, and if it is exotic.
    beast_lore = {
        id = 1462,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': EMPATHY, 'sp_bonus': 0.25, 'target': TARGET_UNIT_TARGET_ANY, }
    },

    -- Sends you and your pet into a rage, instantly dealing $<damage> Physical damage to its target, and increasing all damage you both deal by $s1% for $d. Removes all crowd control effects from your pet. $?s231548[; Bestial Wrath's remaining cooldown is reduced by $s3 sec each time you use Barbed Shot][]$?s193532[ and activating Bestial Wrath grants $s2 $Lcharge:charges; of Barbed Shot.][]$?s231548&!s193532[.][]
    bestial_wrath = {
        id = 19574,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "bestial_wrath",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- scent_of_blood[193532] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Fires a magical projectile, tethering the enemy and any other enemies within $s2 yds for $d, stunning them for $117526d if they move more than $s2 yds from the arrow.$?s321468[; Targets stunned by Binding Shot deal $321469s1% less damage to you for $321469d after the effect ends.][]
    binding_shot = {
        id = 109248,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "binding_shot",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 1524, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_DEST_DEST_GROUND, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 5.0, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- Fire a Black Arrow into your target, dealing $o1 Shadow damage over $d.; Each time Black Arrow deals damage, you have a $s2% chance to generate a charge of $?a137015[Barbed Shot]?a137016[Aimed Shot and reduce its cast time by $439659s2%][Barbed Shot or Aimed Shot].
    black_arrow = {
        id = 430703,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 10,
        spendType = 'focus',

        talent = "black_arrow",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'ap_bonus': 0.2, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Command your pet to tear into your target, causing your target to bleed for $<damage> over $321538d and take $321538s2% increased damage from your pet by for $321538d.
    bloodshed = {
        id = 321530,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "bloodshed",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- While Call of the Wild is active, your pets have the effects of Beast Cleave, and each time Call of the Wild summons a pet, all of your pets Stomp.
    bloody_frenzy = {
        id = 407412,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "bloody_frenzy",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by $s4% for $d, and dealing $s1 Physical damage.$?s378771[; When you fall below $378771s1% heath, Bursting Shot's cooldown is immediately reset. This can only occur once every $385646d.][]
    bursting_shot = {
        id = 186387,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 10,
        spendType = 'focus',

        talent = "bursting_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.052728, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #2: { 'type': KNOCK_BACK, 'subtype': NONE, 'mechanic': knockbacked, 'trigger_spell': 224729, 'points': 50.0, 'value': 300, 'schools': ['fire', 'nature', 'shadow'], 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -50.0, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }

        -- Affected by:
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bestial_wrath[19574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bestial_wrath[19574] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- thrill_of_the_hunt[257946] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- You sound the call of the wild, summoning $s1 of your active pets for $d. During this time, a random pet from your stable will appear every $t2 sec to assault your target for $361582d. ; Each time Call of the Wild summons a pet, the cooldown of Barbed Shot and Kill Command are reduced by $s3%.
    call_of_the_wild = {
        id = 359844,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "call_of_the_wild",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': UNKNOWN, 'subtype': NONE, 'points': 2.0, 'target': TARGET_DEST_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 4.0, 'trigger_spell': 361582, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons your first pet to you.
    call_pet_1 = {
        id = 883,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons your second pet to you.
    call_pet_2 = {
        id = 83242,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'points': 1.0, 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons your third pet to you.
    call_pet_3 = {
        id = 83243,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'points': 2.0, 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons your fourth pet to you.
    call_pet_4 = {
        id = 83244,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'points': 3.0, 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons your fifth pet to you.
    call_pet_5 = {
        id = 83245,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'points': 4.0, 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- You and your pet blend into the surroundings and gain stealth for $d. While camouflaged, you will heal for $s4% of maximum health every $T4 sec.
    camouflage = {
        id = 199483,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        talent = "camouflage",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STEALTH, 'points_per_level': 5.0, 'points': 10.0, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': -30.0, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, }
        -- #3: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'tick_time': 1.0, 'points': 2.0, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 10.0, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, }
    },

    -- Stings the target, dealing $s1 Nature damage and initiating a series of venoms. Each lasts $356723d and applies the next effect after the previous one ends.; $@spellicon356723 $@spellname356723:; $356723s1% reduced movement speed.; $@spellicon356727 $@spellname356727:; Silenced.; $@spellicon356730 $@spellname356730:; $356730s1% reduced damage and healing.
    chimaeral_sting = {
        id = 356719,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.5, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 356723, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- A quick shot causing ${$s2*$<mult>} Physical damage.; Reduces the cooldown of Kill Command by $?s378244[${$s3+($378244s1/-1000)}][$s3] sec.
    cobra_shot = {
        id = 193455,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'focus',

        talent = "cobra_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.565, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Dazes the target, slowing movement speed by $s1% for $d.; $?s193455[Cobra Shot][Steady Shot] will increase the duration of Concussive Shot on the target by ${$56641m3/10}.1 sec.
    concussive_shot = {
        id = 5116,
        cast = 0.0,
        cooldown = 5.0,
        gcd = "global",

        talent = "concussive_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- Interrupts spellcasting, preventing any spell in that school from being cast for $d.
    counter_shot = {
        id = 147362,
        cast = 0.0,
        cooldown = 24.0,
        gcd = "none",

        talent = "counter_shot",
        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- lone_survivor[388039] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Throw a deadly chakram at your current target that will rapidly deal $325037s1 Shadow damage $x times, bouncing to other targets if they are nearby. Enemies struck by Death Chakram take $361756s1% more Physical damage from you and your pet for $361756d.; Each time the chakram deals damage, its damage is increased by $s3% and you generate $s4 Focus.
    death_chakram = {
        id = 325028,
        color = 'necrolord',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'chain_amp': 1.15, 'chain_targets': 7, 'ap_bonus': 0.316, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Summons a powerful wild beast that attacks the target and roars, increasing your Haste by $281036s1% for $d.; Generates $281036s2 Focus.
    dire_beast = {
        id = 120679,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        talent = "dire_beast",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 281036, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- dire_frenzy[385810] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Summons a slow moving basilisk near the target for $d that attacks the target for heavy damage.
    dire_beast_basilisk = {
        id = 205691,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 60,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'value': 105419, 'schools': ['physical', 'holy', 'nature', 'arcane'], 'value1': 3940, 'radius': 15.0, 'target': TARGET_DEST_TARGET_RANDOM, }
    },

    -- Summons a hawk to circle the target area, attacking all targets within 10 yards over the next $d.
    dire_beast_hawk = {
        id = 208652,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 30,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 10.0, 'value': 6486, 'schools': ['holy', 'fire', 'frost', 'arcane'], 'radius': 10.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
    },

    -- Leap backwards$?s109215[, clearing movement impairing effects, and increasing your movement speed by $118922s1% for $118922d][]$?s109298[, and activating a web trap which encases all targets within $115928A1 yards in sticky webs, preventing movement for $136634d][].
    disengage = {
        id = 781,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': KNOCK_BACK_DEST, 'subtype': NONE, 'trigger_spell': 199558, 'points': 75.0, 'value': 200, 'schools': ['nature', 'arcane'], 'radius': 1.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_CASTER_FRONT, }
    },

    -- Temporarily sends this pet away. You can call it back later.
    dismiss_pet = {
        id = 2641,
        cast = 3.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISMISS_PET, 'subtype': NONE, 'target': TARGET_UNIT_PET, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 47531, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- Changes your viewpoint to the targeted location for $d. Only usable outdoors.
    eagle_eye = {
        id = 6197,
        cast = 60.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': ADD_FARSIGHT, 'subtype': NONE, 'radius': 100.0, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Heals you for $s1% and your pet for $128594s1% of maximum health.$?s270581[; Every $270581s1 Focus spent reduces the cooldown of Exhilaration by ${$270581m2/1000}.1 sec.][]$?s385539[; Exhilaration heals you for an additional ${$385539s1}.1% of your maximum health over $385540d.][]
    exhilaration = {
        id = 109304,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL_PCT, 'subtype': NONE, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- [109304] Heals you for $s1% and your pet for $128594s1% of maximum health.$?s270581[; Every $270581s1 Focus spent reduces the cooldown of Exhilaration by ${$270581m2/1000}.1 sec.][]$?s385539[; Exhilaration heals you for an additional ${$385539s1}.1% of your maximum health over $385540d.][]
    exhilaration_128594 = {
        id = 128594,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL_PCT, 'subtype': NONE, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        from = "from_description",
    },

    -- Fires an explosive shot at your target. After $t1 sec, the shot will explode, dealing $212680s1 Fire damage to all enemies within $212680A1 yds. Deals reduced damage beyond $s2 targets.
    explosive_shot = {
        id = 212431,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 20,
        spendType = 'focus',

        talent = "explosive_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Take direct control of your pet and see through its eyes for $d.
    eyes_of_the_beast = {
        id = 321297,
        cast = 60.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 25.0, 'radius': 100.0, 'target': TARGET_UNIT_PET, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Feeds your pet the selected item, instantly restoring $1539s1% of its total health. Not usable in combat.; You may use the Beast Lore ability to identify what types of foods your pet will eat.
    feed_pet = {
        id = 6991,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': FEED_PET, 'subtype': NONE, 'trigger_spell': 1539, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 51284, 'target': TARGET_UNIT_PET, }
    },

    -- Feign death, tricking enemies into ignoring you. Lasts up to $d.
    feign_death = {
        id = 5384,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': FEIGN_DEATH, 'target': TARGET_UNIT_CASTER, }
    },

    -- Command your pet to retrieve the loot from a nearby corpse within $A1 yards.
    fetch = {
        id = 125050,
        cast = 0.1,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENTRY, }
    },

    -- Launch fireworks from your gun, bow or crossbow.
    fireworks = {
        id = 127933,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 15.0, 'target': TARGET_DEST_CASTER_RANDOM, }
    },

    -- Exposes all hidden and invisible enemies within the targeted area for $m1 sec.
    flare = {
        id = 1543,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 132950, 'points': 20.0, 'radius': 10.0, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
    },

    -- Hurls a frost trap to the target location that incapacitates the first enemy that approaches for $3355d. Damage will break the effect. Limit 1. Trap will exist for $3355d.
    freezing_trap = {
        id = 187650,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 187651, 'radius': 3.0, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- improved_traps[343247] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- [187650] Hurls a frost trap to the target location that incapacitates the first enemy that approaches for $3355d. Damage will break the effect. Limit 1. Trap will exist for $3355d.
    freezing_trap_187651 = {
        id = 187651,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 4424, 'schools': ['nature', 'arcane'], 'target': TARGET_DEST_DEST, }
        from = "triggered_spell",
    },

    -- Furiously strikes all enemies in front of you, dealing ${$203413s1*9} Physical damage over $d. Critical strike chance increased by $s3% against any target below $s4% health. Deals reduced damage beyond $s5 targets.; Kill Command cooldown resets reduce the cooldown of Fury of the Eagle by ${$m2/1000}.1 sec$?s385718[ and Fury of the Eagle critical strikes reduce the cooldown of Wildfire Bomb and Flanking Strike by ${$m1/1000}.1 sec][].
    fury_of_the_eagle = {
        id = 203415,
        cast = 4.0,
        channeled = true,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.5, 'trigger_spell': 203413, 'triggers': fury_of_the_eagle, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 203413, 'triggers': fury_of_the_eagle, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 203413, 'triggers': fury_of_the_eagle, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 203413, 'triggers': fury_of_the_eagle, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 203413, 'triggers': fury_of_the_eagle, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies away. Limit $s2. Trap will exist for $236775d.$?s321468[; Targets knocked back by High Explosive Trap deal $321469s1% less damage to you for $321469d after being knocked back.][]
    high_explosive_trap = {
        id = 236776,
        cast = 0.0,
        cooldown = 40.0,
        gcd = "global",

        talent = "high_explosive_trap",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'attributes': ['Position is facing relative'], 'trigger_spell': 236775, 'radius': 3.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- improved_traps[343247] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Apply Hunter's Mark to the target, causing the target to always be seen and tracked by the Hunter.; Hunter's Mark increases all damage dealt to targets above $s3% health by $428402s1%. Only one Hunter's Mark damage increase can be applied to a target at a time.; Hunter's Mark can only be applied to one target at a time. When applying Hunter's Mark in combat, the ability goes on cooldown for ${$s5/1000} sec.
    hunters_mark = {
        id = 257284,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.5, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_STALKED, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 80.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20000.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- [257284] Apply Hunter's Mark to the target, causing the target to always be seen and tracked by the Hunter.; Hunter's Mark increases all damage dealt to targets above $s3% health by $428402s1%. Only one Hunter's Mark damage increase can be applied to a target at a time.; Hunter's Mark can only be applied to one target at a time. When applying Hunter's Mark in combat, the ability goes on cooldown for ${$s5/1000} sec.
    hunters_mark_428402 = {
        id = 428402,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': 5.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "from_description",
    },

    -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies up. Limit $s2. Trap will exist for $236775d.$?s321468[; Targets knocked up by Implosive Trap deal $321469s1% less damage to you for $321469d after being knocked up.][]
    implosive_trap = {
        id = 462031,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "implosive_trap",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'attributes': ['Position is facing relative'], 'trigger_spell': 462032, 'radius': 3.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- improved_traps[343247] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- $?a459507[Intimidate the target][Commands your pet to intimidate the target], stunning it for $24394d.$?s321468[; Targets stunned by Intimidation deal $321469s1% less damage to you for $321469d after the effect ends.][]
    intimidation = {
        id = 19577,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "intimidation",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- territorial_instincts[459507] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Give the command to kill, causing your pet to savagely deal $<damage> Physical damage to the enemy.
    kill_command = {
        id = 34026,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "global",

        spend = 30,
        spendType = 'focus',

        talent = "kill_command",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hunter[137014] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- specialized_arsenal[459542] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- specialized_arsenal[459542] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- alpha_predator[269737] #2: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- alpha_predator[269737] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- bestial_wrath[19574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bestial_wrath[19574] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- go_for_the_throat[459550] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- improved_kill_command[378010] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overshadow[430716] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- savagery[424557] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- thrill_of_the_hunt[257946] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- venomous_bite[459668] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- You attempt to finish off a wounded target, dealing $s1 Physical damage. Only usable on enemies with less than $s2% health.$?s343248[; Kill Shot deals $343248s1% increased critical damage.][]
    kill_shot = {
        id = 53351,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'focus',

        talent = "kill_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 3.2, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- improved_kill_shot[343248] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- bestial_wrath[19574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bestial_wrath[19574] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hunters_prey[378215] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- thrill_of_the_hunt[257946] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- survival_hunter[137017] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- You attempt to finish off a wounded target, dealing $s1 Physical damage. Only usable on enemies with less than $s2% health.
    kill_shot_320976 = {
        id = 320976,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 10,
        spendType = 'focus',

        talent = "kill_shot_320976",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 4.0, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- beast_mastery_hunter[137015] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_kill_shot[343248] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- hunters_prey[378215] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- survival_hunter[137017] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "class_talent",
    },

    -- Heals your pet for $<total>% of its total health over $d.$?s343242[; Each time Mend Pet heals your pet, it has a $343242s2% chance to dispel a harmful magic effect from your pet.][]
    mend_pet = {
        id = 136,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'tick_time': 2.0, 'pvp_multiplier': 2.0, 'points': 10.0, 'target': TARGET_UNIT_PET, }

        -- Affected by:
        -- wilderness_medicine[343242] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within $d and lasting for $35079d.
    misdirection = {
        id = 34477,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        talent = "misdirection",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': REDIRECT_THREAT, 'subtype': NONE, 'points': 100.0, 'value': 38000, 'schools': ['frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': 15.0, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- interlope[248518] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Fires several missiles, hitting all nearby enemies within $A2 yds of your current target for $s2 Physical damage$?s115939[ and triggering Beast Cleave][]. Deals reduced damage beyond $s1 targets.$?s19434[; Generates $213363s1 Focus per target hit.][]
    multishot = {
        id = 2643,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'focus',

        talent = "multishot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.126, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- bestial_wrath[19574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bestial_wrath[19574] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- thrill_of_the_hunt[257946] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Playing Dead, tricking enemies into ignoring them. Lasts up to $d.
    play_dead = {
        id = 209997,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': FEIGN_DEATH, 'target': TARGET_UNIT_PET, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_PET, }
        -- #2: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 210000, 'value': 209997, 'schools': ['physical', 'fire', 'nature', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Revives your pet, returning it to life with $s1% of its base health.
    revive_pet = {
        id = 982,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'focus',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT_PET, 'subtype': NONE, 'points': 100.0, 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- hunter[137014] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- survival_hunter[137017] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but $s2% of all damage taken by that target is also taken by the pet.  Lasts $d.
    roar_of_sacrifice = {
        id = 53480,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        talent = "roar_of_sacrifice",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_SPELL_AND_WEAPON_CRIT_CHANCE, 'amplitude': 1.0, 'points': -10000.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'amplitude': 1.0, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Scares a beast, causing it to run in fear for up to $d.  Damage caused may interrupt the effect.  Only one beast can be feared at a time.
    scare_beast = {
        id = 1513,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 25,
        spendType = 'focus',

        talent = "scare_beast",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_FEAR, 'variance': 0.25, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- A short-range shot that deals $s1 damage, removes all harmful damage over time effects, and incapacitates the target for $d.  Any damage caused will remove the effect. Turns off your attack when used.$?s321468[; Targets incapacitated by Scatter Shot deal $321469s1% less damage to you for $321469d after the effect ends.][]
    scatter_shot = {
        id = 213691,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "scatter_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.044616, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'sp_bonus': 0.25, 'mechanic': disoriented, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 37506, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Summons all of your pets to fight your current target for $d. While in an Arena or Battleground, these pets deal only ${100+$130201m1}% of their normal damage.
    stampede = {
        id = 121818,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'trigger_spell': 130201, 'points': 4.0, 'radius': 5.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_DEST_CASTER_RIGHT, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_master_of_beasts[76657] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.9, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- A steady shot that causes $s1 Physical damage.; Usable while moving.$?s321018[; Generates $s2 Focus.][]
    steady_shot = {
        id = 56641,
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.6, 'pvp_multiplier': 1.4, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- bestial_wrath[19574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bestial_wrath[19574] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- thrill_of_the_hunt[257946] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Placeholder for level 75 talented active ability.
    stopping_power = {
        id = 175686,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Reduces all damage you and your pet take by $s1% for $d.
    survival_of_the_fittest = {
        id = 264735,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "hunter - command pet - survival of the fittest",

        talent = "survival_of_the_fittest",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -30.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'points': -30.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_PET, }

        -- Affected by:
        -- lone_survivor[388039] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- padded_armor[459450] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- $?a166615[You must dismiss your current pet before you can tame another one.; ][]Tames a beast to be your companion. If you lose the beast's attention for any reason, the taming process will fail.; You must dismiss any active beast companions and have an empty Call Pet slot before you can begin taming a new beast. Only Beast Mastery specialized Hunters can tame Exotic Beasts.
    tame_beast = {
        id = 1515,
        cast = 6.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 6.0, 'trigger_spell': 13481, 'target': TARGET_UNIT_CASTER, }
    },

    -- Hurls a tar trap to the target location that creates a $187699s1 yd radius pool of tar around itself for $13810d when the first enemy approaches. All enemies have $135299s1% reduced movement speed while in the area of effect. Limit $s2. Trap will exist for $13809d.
    tar_trap = {
        id = 187698,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "tar_trap",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 187699, 'radius': 3.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- improved_traps[343247] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- [187698] Hurls a tar trap to the target location that creates a $187699s1 yd radius pool of tar around itself for $13810d when the first enemy approaches. All enemies have $135299s1% reduced movement speed while in the area of effect. Limit $s2. Trap will exist for $13809d.
    tar_trap_187699 = {
        id = 187699,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 8.0, 'value': 4435, 'schools': ['physical', 'holy', 'frost', 'arcane'], 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        from = "triggered_spell",
    },

    -- Discharge a massive jolt of electricity from Titanstrike into all your pets$?s217200[][ and Dire Beasts], causing them to deal up to ${$RAP*1.15*0.5*$<bmMastery>} Nature damage to their target every $207094t sec. for $207094d.$?s217200[ Also causes the next pet frenzy caused by Barbed Shot to deal $218635s1 additional Nature damage on each of the 5 attacks.][]
    titans_thunder = {
        id = 207068,
        color = 'artifact',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 207081, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Removes $s1 Enrage and $s2 Magic effect from an enemy target.$?s343244[; Successfully dispelling an effect generates $343244s1 Focus.][]
    tranquilizing_shot = {
        id = 19801,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        talent = "tranquilizing_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'sp_bonus': 0.25, 'points': 1.0, 'value': 9, 'schools': ['physical', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'points': 1.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- kodo_tranquilizer[459983] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- kodo_tranquilizer[459983] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- kodo_tranquilizer[459983] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_DISTANCE, }
    },

    -- Fire an enchanted arrow, dealing $354831s1 Shadow damage to your target and an additional $354831s2 Shadow damage to all enemies within $354831A2 yds of your target. Targets struck by a Wailing Arrow are silenced for $355596d.
    wailing_arrow = {
        id = 355589,
        cast = 2.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 15,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 354831, 'triggers': wailing_arrow, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Tell your pet to wake up.
    wake_up = {
        id = 210000,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': UNKNOWN, 'subtype': NONE, 'trigger_spell': 209997, 'triggers': play_dead, 'target': TARGET_UNIT_PET, }
    },

    -- Call in help from one of your dismissed $?a264656[Tenacity][Cunning] pets for $d. Your current pet is dismissed to rest and heal $358250s1% of maximum health.
    wild_kingdom = {
        id = 356707,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Focuses the power of Wind through Thas'dorah, dealing $sw1 Physical damage to your target, and leaving behind a trail of wind for $204475d that increases the movement speed of allies by $204477s1%.
    windburst = {
        id = 204147,
        color = 'artifact',
        cast = 1.5,
        cooldown = 20.0,
        gcd = "global",

        spend = 20,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': WEAPON_PERCENT_DAMAGE, 'subtype': NONE, 'points': 272.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': NORMALIZED_WEAPON_DMG, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Maims the target, reducing movement speed by $s1% for $d.
    wing_clip = {
        id = 195645,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 20,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

} )