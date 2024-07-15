-- HunterMarksmanship.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 254 )

-- Resources
spec:RegisterResource( Enum.PowerType.Focus )

spec:RegisterTalents( {
    -- Hunter Talents
    binding_shackles          = { 102388, 321468, 1 }, -- Targets stunned by Binding Shot, knocked back by High Explosive Trap, knocked up by Implosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal $s1% less damage to you for $321469d after the effect ends.
    binding_shot              = { 102386, 109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within $s2 yds for $d, stunning them for $117526d if they move more than $s2 yds from the arrow.$?s321468[; Targets stunned by Binding Shot deal $321469s1% less damage to you for $321469d after the effect ends.][]
    blackrock_munitions       = { 102392, 462036, 1 }, -- The damage of Explosive Shot is increased by $s1%.
    born_to_be_wild           = { 102416, 266921, 1 }, -- Reduces the cooldowns of $?c3[Aspect of the Eagle, ][]Aspect of the Cheetah, and Aspect of the Turtle by ${$s1/-1000} sec.
    bursting_shot             = { 102421, 186387, 1 }, -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by $s4% for $d, and dealing $s1 Physical damage.$?s378771[; When you fall below $378771s1% heath, Bursting Shot's cooldown is immediately reset. This can only occur once every $385646d.][]
    camouflage                = { 102414, 199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for $d. While camouflaged, you will heal for $s4% of maximum health every $T4 sec.
    concussive_shot           = { 102407, 5116  , 1 }, -- Dazes the target, slowing movement speed by $s1% for $d.; $?s193455[Cobra Shot][Steady Shot] will increase the duration of Concussive Shot on the target by ${$56641m3/10}.1 sec.
    devilsaur_tranquilizer    = { 102415, 459991, 1 }, -- If Tranquilizing Shot removes only an Enrage effect, its cooldown is reduced by $s1 sec.
    disruptive_rounds         = { 102395, 343244, 1 }, -- When Tranquilizing Shot successfully dispels an effect or $?c3[Muzzle][Counter Shot] interrupts a cast, gain $s1 Focus.
    emergency_salve           = { 102389, 459517, 1 }, -- Feign Death and Aspect of the Turtle removes poison and disease effects from you.
    entrapment                = { 102403, 393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for $393456d. Damage taken may break this root.
    explosive_shot            = { 102420, 212431, 1 }, -- Fires an explosive shot at your target. After $t1 sec, the shot will explode, dealing $212680s1 Fire damage to all enemies within $212680A1 yds. Deals reduced damage beyond $s2 targets.
    ghillie_suit              = { 102385, 459466, 1 }, -- You take $s1% reduced damage while Camouflage is active.; This effect persists for 3 sec after you leave Camouflage.
    high_explosive_trap       = { 102739, 236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies away. Limit $s2. Trap will exist for $236775d.$?s321468[; Targets knocked back by High Explosive Trap deal $321469s1% less damage to you for $321469d after being knocked back.][]
    hunters_avoidance         = { 102423, 384799, 1 }, -- Damage taken from area of effect attacks reduced by $s1%.
    implosive_trap            = { 102739, 462031, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $236777s2 Fire damage and knocking all enemies up. Limit $s2. Trap will exist for $236775d.$?s321468[; Targets knocked up by Implosive Trap deal $321469s1% less damage to you for $321469d after being knocked up.][]
    improved_kill_shot        = { 102410, 343248, 1 }, -- Kill Shot's critical damage is increased by $s1%.
    improved_traps            = { 102418, 343247, 1 }, -- The cooldown of Tar Trap, High Explosive Trap, Implosive Trap, and Freezing Trap is reduced by ${$m1/-1000}.1 sec.
    intimidation              = { 102397, 19577 , 1 }, -- $?a459507[Intimidate the target][Commands your pet to intimidate the target], stunning it for $24394d.$?s321468[; Targets stunned by Intimidation deal $321469s1% less damage to you for $321469d after the effect ends.][]
    keen_eyesight             = { 102409, 378004, 2 }, -- Critical strike chance increased by $s1%.
    kill_shot                 = { 102379, 320976, 1 }, -- You attempt to finish off a wounded target, dealing $s1 Physical damage. Only usable on enemies with less than $s2% health.
    kindling_flare            = { 102425, 459506, 1 }, -- Stealthed enemies revealed by Flare remain revealed for ${$s1/1000} sec after exiting the flare.
    kodo_tranquilizer         = { 102415, 459983, 1 }, -- Tranquilizing Shot removes up to $s1 additional Magic effect from up to $s3 nearby targets.
    lone_survivor             = { 102391, 388039, 1 }, -- Reduce the cooldown of Survival of the Fittest by ${$m1/-1000} sec, and increase its duration by ${$s2/1000}.1 sec.; Reduce the cooldown of Counter Shot and Muzzle by ${$s3/-1000} sec.
    misdirection              = { 102419, 34477 , 1 }, -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within $d and lasting for $35079d.
    moment_of_opportunity     = { 102426, 459488, 1 }, -- When a trap triggers, you gain Aspect of the Cheetah for 3 sec.; Can only occur every 1 min.
    natural_mending           = { 102401, 270581, 1 }, -- Every $s1 Focus you spend reduces the remaining cooldown on Exhilaration by ${$m2/1000}.1 sec.
    no_hard_feelings          = { 102412, 459546, 1 }, -- When Misdirection targets your pet, it reduces the damage they take by $459547s1% for $459547d.
    padded_armor              = { 102406, 459450, 1 }, -- Survival of the Fittest gains an additional charge.
    pathfinding               = { 102404, 378002, 1 }, -- Movement speed increased by $s1%.
    posthaste                 = { 102411, 109215, 1 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by $s2% for $118922d.
    quick_load                = { 102413, 378771, 1 }, -- When you fall below $s1% health, Bursting Shot and Scatter Shot have their cooldown immediately reset. This can only occur once every $385646d.
    rejuvenating_wind         = { 102381, 385539, 1 }, -- Maximum health increased by $s2%, and Exhilaration now also heals you for an additional ${$s1}.1% of your maximum health over $385540d.
    roar_of_sacrifice         = { 102405, 53480 , 1 }, -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes, but $s2% of all damage taken by that target is also taken by the pet.  Lasts $d.
    scare_beast               = { 102382, 1513  , 1 }, -- Scares a beast, causing it to run in fear for up to $d.  Damage caused may interrupt the effect.  Only one beast can be feared at a time.
    scatter_shot              = { 102421, 213691, 1 }, -- A short-range shot that deals $s1 damage, removes all harmful damage over time effects, and incapacitates the target for $d.  Any damage caused will remove the effect. Turns off your attack when used.$?s321468[; Targets incapacitated by Scatter Shot deal $321469s1% less damage to you for $321469d after the effect ends.][]
    scouts_instincts          = { 102424, 459455, 1 }, -- You cannot be slowed below $186257s2% of your normal movement speed while Aspect of the Cheetah is active.
    scrappy                   = { 102408, 459533, 1 }, -- Casting $?a137017[Wildfire Bomb]?a137016[Aimed Shot][Kill Command] reduces the cooldown of Intimidation and Binding Shot by ${$s1/1000}.1 sec.
    serrated_tips             = { 102384, 459502, 1 }, -- You gain $s1% more critical strike from critical strike sources.
    specialized_arsenal       = { 102390, 459542, 1 }, -- $?a137017[Wildfire Bomb]?a137016[Aimed Shot][Kill Command] deals $s1% increased damage.; 
    survival_of_the_fittest   = { 102422, 264735, 1 }, -- Reduces all damage you and your pet take by $s1% for $d.
    tar_trap                  = { 102393, 187698, 1 }, -- Hurls a tar trap to the target location that creates a $187699s1 yd radius pool of tar around itself for $13810d when the first enemy approaches. All enemies have $135299s1% reduced movement speed while in the area of effect. Limit $s2. Trap will exist for $13809d.
    tarcoated_bindings        = { 102417, 459460, 1 }, -- Binding Shot's stun duration is increased by ${$s1/1000} sec.
    territorial_instincts     = { 102394, 459507, 1 }, -- Casting Intimidation without a pet now summons one from your stables to intimidate the target.; Additionally, the cooldown of Intimidation is reduced by ${$abs($s2)/1000} sec.
    trailblazer               = { 102400, 199921, 1 }, -- Your movement speed is increased by $s2% anytime you have not attacked for ${$s1/1000} sec.
    tranquilizing_shot        = { 102380, 19801 , 1 }, -- Removes $s1 Enrage and $s2 Magic effect from an enemy target.$?s343244[; Successfully dispelling an effect generates $343244s1 Focus.][]
    trigger_finger            = { 102396, 459534, 2 }, -- You and your pet have ${$s2}.1% increased attack speed.; This effect is increased by $s3% if you do not have an active pet.
    unnatural_causes          = { 102387, 459527, 1 }, -- Your damage over time effects deal $s1% increased damage.; This effect is increased by $s2% on targets below $s3% health.
    wilderness_medicine       = { 102383, 343242, 1 }, -- Mend Pet heals for an additional ${$m1*$136d/$136t1}% of your pet's health over its duration, and has a $s2% chance to dispel a magic effect each time it heals your pet.

    -- Marksmanship Talents
    aimed_shot                = { 102297, 19434 , 1 }, -- A powerful aimed shot that deals $s1 Physical damage$?s260240[ and causes your next 1-$260242u ][]$?s342049&s260240[Chimaera Shots]?s260240[Arcane Shots][]$?s260240[ or Multi-Shots to deal $260242s1% more damage][].$?s260228[; Aimed Shot deals $393952s1% bonus damage to targets who are above $260228s1% health.][]$?s378888[; Aimed Shot also fires a Serpent Sting at the primary target.][]
    barrage                   = { 102332, 120360, 1 }, -- Rapidly fires a spray of shots for $120360d, dealing an average of $<damageSec> Physical damage to all nearby enemies in front of you. Usable while moving. Deals reduced damage beyond $120361s1 targets.; $?c1[Grants Beast Cleave.][]
    black_arrow               = { 94987, 430703, 1 }, -- Fire a Black Arrow into your target, dealing $o1 Shadow damage over $d.; Each time Black Arrow deals damage, you have a $s2% chance to generate a charge of $?a137015[Barbed Shot]?a137016[Aimed Shot and reduce its cast time by $439659s2%][Barbed Shot or Aimed Shot].
    bulletstorm               = { 102303, 389019, 1 }, -- Each additional target your Rapid Fire or Aimed Shot ricochets to from Trick Shots increases the damage of Multi-Shot by $389020s1% for $389020d, stacking up to $389020u times. The duration of this effect is not refreshed when gaining a stack.
    bullseye                  = { 102298, 204089, 1 }, -- When your abilities damage a target below $s1% health, you gain $204090s1% increased critical strike chance for $204090d, stacking up to $s2 times.
    calling_the_shots         = { 102326, 260404, 1 }, -- Every $s2 Focus spent reduces the cooldown of Trueshot by ${$m1/1000}.1 sec.
    careful_aim               = { 102313, 260228, 1 }, -- Aimed Shot deals $s3% bonus damage to targets who are above $s1% health.
    catch_out                 = { 94990, 451516, 1 }, -- When a target affected by Sentinel deals damage to you, they are rooted for $451517d.; May only occur every $451519d per target.
    chimaera_shot             = { 102323, 342049, 1 }, -- A two-headed shot that hits your primary target for $344120sw1 Nature damage and another nearby target for ${$344121sw1*($s1/100)} Frost damage.$?s260393[; Chimaera Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    counter_shot              = { 102402, 147362, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for $d.
    crack_shot                = { 102329, 321293, 1 }, -- Arcane Shot and Chimaera Shot Focus cost reduced by $s1.
    crescent_steel            = { 94980, 451530, 1 }, -- Targets you damage below $s1% health gain a stack of Sentinel every 3 sec.
    dark_chains               = { 94960, 430712, 1 }, -- Disengage will chain the closest target to the ground, causing them to move 40% slower until they move 8 yards away.
    dark_empowerment          = { 94986, 430718, 1 }, -- When Black Arrow resets the cooldown of an ability, gain $442511s1 Focus.
    darkness_calls            = { 94974, 430722, 1 }, -- All Shadow damage you and your pets deal is increased by $s1%.
    death_shade               = { 94968, 430711, 1 }, -- When you apply Black Arrow to a target, you gain the $?a137015[Hunter's Prey]?a137016[Deathblow][Deathblow or Hunter's Prey] effect.
    deathblow                 = { 102305, 378769, 1 }, -- Aimed Shot has a $h% and Rapid Fire has a $s1% chance to grant a charge of Kill Shot, and cause your next Kill Shot to be usable on any target regardless of their current health.
    dont_look_back            = { 94989, 450373, 1 }, -- Each time Sentinel deals damage to an enemy you gain an absorb shield equal to $s1% of your maximum health, up to $s2%.
    eagletalons_true_focus    = { 102306, 389449, 1 }, -- Trueshot lasts an additional ${$m2/1000}.1 sec, reduces the Focus Cost of Aimed Shot by $s1%, and causes your Arcane Shot, Chimaera Shot, and Multi-Shot to be cast again at $s3% effectiveness.
    embrace_the_shadows       = { 94959, 430704, 1 }, -- You heal for $s1% of all Shadow damage dealt by you or your pets.
    extrapolated_shots        = { 94973, 450374, 1 }, -- When you apply Sentinel to a target not affected by Sentinel, you apply $s1 additional stack.
    eyes_closed               = { 94970, 450381, 1 }, -- For $451180d after activating $?s137016[Trueshot][Coordinated Assault], all abilities are guaranteed to apply Sentinel.
    fan_the_hammer            = { 102314, 459794, 1 }, -- Rapid Fire shoots $s2 additional shots.
    focused_aim               = { 102333, 378767, 2 }, -- Aimed Shot and Rapid Fire damage increased by ${$s1}.1%.
    grave_reaper              = { 94986, 430719, 1 }, -- When a target affected by Black Arrow dies, the cooldown of Black Arrow is reduced by $s1 sec.
    heavy_ammo                = { 102334, 378910, 1 }, -- Trick Shots now ricochets to $s1 fewer targets, but each ricochet deals an additional $s3% damage.
    hydras_bite               = { 102301, 260241, 1 }, -- When Aimed Shot strikes an enemy affected with your Serpent Sting, it spreads Serpent Sting to $s3 enemies nearby.; Serpent Sting's damage over time is increased by $s2%.
    improved_steady_shot      = { 102328, 321018, 1 }, -- Steady Shot now generates $s1 Focus.
    in_the_rhythm             = { 102319, 407404, 1 }, -- When Rapid Fire fully finishes channeling, gain $407405s1% haste for $407405d.
    invigorating_pulse        = { 94971, 450379, 1 }, -- Each time Sentinel deals damage to an enemy it has an up to $s2% chance to generate $s1 focus.; Chances decrease with each additional Sentinel currently imploding applied to enemies.
    kill_zone                 = { 102310, 459921, 1 }, -- Your spells and attacks deal $393480s2% increased damage and ignore line of sight against any target in your Volley.
    killer_accuracy           = { 102330, 378765, 1 }, -- Kill Shot critical strike chance and critical strike damage increased by $s1%.
    legacy_of_the_windrunners = { 102327, 406425, 2 }, -- Aimed Shot coalesces $s1 Wind $LArrow:Arrows; that shoot your target for $191043s1 Physical damage.; Each time Rapid Fire deals damage, there is a 5% chance to coalesce a Wind Arrow at your target.
    light_ammo                = { 102334, 378913, 1 }, -- Trick Shots now causes Aimed Shot and Rapid Fire to ricochet to $s1 additional $Ltarget:targets;.
    lock_and_load             = { 102324, 194595, 1 }, -- Your ranged auto attacks have a $194595h% chance to trigger Lock and Load, causing your next Aimed Shot to cost no Focus and be instant.
    lone_wolf                 = { 102300, 155228, 1 }, -- Increases your damage by $s3% when you do not have an active pet.
    lunar_storm               = { 94978, 450385, 1 }, -- Every 15 sec your next $?s137016[Rapid Fire][Wildfire Bomb] summons a celestial owl that conjures a $450978s1 yd radius Lunar Storm at the target's location for $450978d.;  ; A random enemy affected by Sentinel within your Lunar Storm gets struck for $450883s1 Arcane damage every $450978t2 sec. Any target struck by this effect takes $450884s2% increased damage from you and your pet for $450884d. 
    master_marksman           = { 102296, 260309, 1 }, -- Your melee and ranged special attack critical strikes cause the target to bleed for an additional $s1% of the damage dealt over $269576d.
    multishot                 = { 102295, 257620, 1 }, -- Fires several missiles, hitting your current target and all enemies within $A1 yards for $s1 Physical damage. Deals reduced damage beyond $2643s1 targets.$?s260393[; Multi-Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    night_hunter              = { 102321, 378766, 1 }, -- Aimed Shot and Rapid Fire critical strike chance increased by $s1%.
    overshadow                = { 94961, 430716, 1 }, -- $?a137015[Barbed Shot and Kill Command deal $s2% increased damage.][Aimed Shot and Rapid Fire deal $s1% increased damage.]
    overwatch                 = { 94980, 450384, 1 }, -- All Sentinel debuffs implode when a target affected by more than 3 stacks of your Sentinel falls below $s1% health.
    penetrating_shots         = { 102331, 459783, 1 }, -- Gain critical strike damage equal to $s2% of your critical strike chance.
    precise_shots             = { 102294, 260240, 1 }, -- Aimed Shot causes your next $260242u $?s342049[Chimaera Shots][Arcane Shots] or Multi-Shots to deal $s1% more damage and cost $260242s6% less Focus.
    rapid_fire                = { 102318, 257044, 1 }, -- Shoot a stream of $s1 shots at your target over $d, dealing a total of ${$m1*$257045sw1} Physical damage. Usable while moving.$?s260367[; Rapid Fire causes your next Aimed Shot to cast $342076s1% faster.][]; Each shot generates $263585s1 Focus.
    rapid_fire_barrage        = { 102302, 459800, 1 }, -- Barrage now instead shoots Rapid Fires at your target and up to $459796s3 nearby enemies at $s4% effectiveness, but its cooldown is increased by ${$s3/1000} sec.
    razor_fragments           = { 102322, 384790, 1 }, -- When the Trick Shots effect fades or is consumed, or after gaining Deathblow, your next Kill Shot will deal $388998s1% increased damage, and shred up to $388998s2 targets near your Kill Shot target for $388998s3% of the damage dealt by Kill Shot over $385638d.
    readiness                 = { 102307, 389865, 1 }, -- Trueshot grants Wailing Arrow and you generate $s3 additional Wind Arrows while in Trueshot.; Wailing Arrow resets the cooldown of Rapid Fire and generates $s2 $Lcharge:charges; of Aimed Shot.
    release_and_reload        = { 94958, 450376, 1 }, -- When you apply Sentinel on a target, you have a $s1% chance to apply a second stack.
    salvo                     = { 102316, 400456, 1 }, -- Your next Multi-Shot or Volley now also applies Explosive Shot to up to $s1 $Ltarget:targets; hit. 
    sentinel                  = { 94976, 450369, 1 }, -- Your attacks have a chance to apply Sentinel on the target, stacking up to $450387u times.; While Sentinel stacks are higher than $s1, applying Sentinel has a chance to trigger an implosion, causing a stack to be consumed on the target every sec to deal $450412s1 Arcane damage.; 
    sentinel_precision        = { 94981, 450375, 1 }, -- $?s137016[Aimed Shot and Rapid Fire][Raptor Strike, Mongoose Bite and Wildfire Bomb] deal $?s137016[$s1][$s3]% increased damage. 
    sentinel_watch            = { 94970, 451546, 1 }, -- Whenever a Sentinel deals damage, the cooldown of $?s137016[Trueshot][Coordinated Assault] is reduced by $s1 sec, up to $s2 sec.
    serpentstalkers_trickery  = { 102315, 378888, 1 }, -- [271788] Fire a shot that poisons your target, causing them to take $?s389882[${$m1*(1+($389882m1/100))}][$s1] Nature damage instantly and an additional $?s389882[${$o2*(1+($389882m1/100))}][$o2] Nature damage over $d.$?s378014[; Serpent Sting's damage applies Latent Poison to the target, stacking up to $378015u times. $@spelldesc393949 consumes all stacks of Latent Poison, dealing $378016s1 Nature damage to the target per stack consumed.][]
    shadow_erasure            = { 94974, 430720, 1 }, -- Kill Shot has a $s2% chance to generate a charge of $?a137015[Barbed Shot]?a137016[Aimed Shot][Barbed Shot or Aimed Shot] when used on a target affected by Black Arrow.
    shadow_hounds             = { 94983, 430707, 1 }, -- Each time Black Arrow deals damage, you have a $s1% chance to manifest a Dark Hound to charge to your target and deal Shadow damage.
    shadow_lash               = { 94957, 430717, 1 }, -- When $?a137015[Call of the Wild]?a137016[Trueshot][Call of the Wild or Trueshot] is active, Black Arrow deals damage 50% faster.
    shadow_surge              = { 94982, 430714, 1 }, -- When Multi-Shot hits a target affected by Black Arrow, a burst of Shadow energy erupts, dealing moderate Shadow damage to all enemies near the target.; This can only occur once every $s1 sec.
    sideline                  = { 94990, 450378, 1 }, -- When Sentinel starts dealing damage, the target is snared by $450845s1% for $450845d.
    small_game_hunter         = { 102325, 459802, 1 }, -- Multi-Shot deals $s1% increased damage and Explosive Shot deals $s2% increased damage.
    smoke_screen              = { 94959, 430709, 1 }, -- Exhilaration grants you $s1 sec of Survival of the Fittest.; Survival of the Fittest activates Exhilaration at $s2% effectiveness.
    steady_focus              = { 102293, 193533, 1 }, -- Using Steady Shot twice in a row increases your haste by $s1% for $193534d.
    streamline                = { 102308, 260367, 1 }, -- Rapid Fire's damage is increased by $s1%, and Rapid Fire also causes your next Aimed Shot to cast $s3% faster.
    surging_shots             = { 102320, 391559, 1 }, -- Rapid Fire deals $s1% additional damage, and Aimed Shot has a $h% chance to reset the cooldown of Rapid Fire.
    symphonic_arsenal         = { 94965, 450383, 1 }, -- Multi-Shot $?s137016[discharges][and Butchery discharge] arcane energy from all targets affected by your Sentinel, dealing $?c2[${$451194s1*$s2}][$451194s1] Arcane damage to up to $s1 targets within $451194A1 yds of your Sentinel targets.
    tactical_reload           = { 102311, 400472, 1 }, -- Aimed Shot and Rapid Fire cooldown reduced by $s1%.
    trick_shots               = { 102309, 257621, 1 }, -- When Multi-Shot hits $s2 or more targets, your next Aimed Shot or Rapid Fire will ricochet and hit up to $s1 additional targets for $s4% of normal damage.
    trueshot                  = { 102304, 288613, 1 }, -- Reduces the cooldown of your Aimed Shot and Rapid Fire by ${100*(1-(100/(100+$m1)))}%, and causes Aimed Shot to cast $s4% faster for $d.; While Trueshot is active, you generate $s5% additional Focus$?s386878[ and you gain $386877s1% critical strike chance and $386877s2% increased critical damage dealt every $386876t1 sec, stacking up to $386877u times][].$?s260404[; Every $260404s2 Focus spent reduces the cooldown of Trueshot by ${$260404m1/1000}.1 sec.][]
    unerring_vision           = { 102312, 386878, 1 }, -- [386876] While Trueshot is active you gain $386877s1% critical strike chance and $386877s2% increased critical damage dealt every $t1 sec, stacking up to $386877u times.
    volley                    = { 102317, 260243, 1 }, -- Rain a volley of arrows down over $d, dealing up to ${$260247s1*12} Physical damage to any enemy in the area, and gain the effects of Trick Shots for as long as Volley is active.
    wailing_arrow             = { 102299, 459806, 1 }, -- [392060] Fire an enchanted arrow, dealing $392058s1 Shadow damage to your target and an additional $392058s2 Shadow damage to all enemies within $392058A2 yds of your target. Non-Player targets struck by a Wailing Arrow have their spellcasting interrupted and are silenced for $392061d.$?s389865[; Wailing Arrow resets the cooldown of Rapid Fire and generates $389865s2 $Lcharge:charges; of Aimed Shot.][]$?s389866[; Wailing Arrow fires off $389866s1 Wind Arrows at your primary target, and $389866s2 Wind Arrows split among any secondary targets hit, each dealing $191043s1 Physical damage.][]
    withering_fire            = { 94993, 430715, 1 }, -- When Black Arrow resets the cooldown of $?a137015[Barbed Shot]?a137016[Aimed Shot][Barbed Shot or Aimed Shot], a barrage of dark arrows will strike your target for Shadow damage and increase the damage you and your pets deal by 10% for 6 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting        = 653 , -- (356719) Stings the target, dealing $s1 Nature damage and initiating a series of venoms. Each lasts $356723d and applies the next effect after the previous one ends.; $@spellicon356723 $@spellname356723:; $356723s1% reduced movement speed.; $@spellicon356727 $@spellname356727:; Silenced.; $@spellicon356730 $@spellname356730:; $356730s1% reduced damage and healing.
    consecutive_concussion = 5440, -- (357018) Concussive Shot slows movement by an additional $s1%. Using Steady Shot $s2 times on a concussed enemy stuns them for $357021d.
    diamond_ice            = 5533, -- (203340) Victims of Freezing Trap can no longer be damaged or healed.  Freezing Trap is now undispellable, but has a $203337d duration.
    hunting_pack           = 3729, -- (203235) Aspect of the Cheetah has $m1% reduced cooldown and grants its effects to allies within $356781A yds.
    interlope              = 5531, -- (248518) Misdirection now causes the next $248519n hostile spells cast on your target within $248519d to be redirected to your pet, but its cooldown is increased by ${$s4/1000} sec.; Your pet must be within $248519a1 yards of the target for spells to be redirected.; 
    rangers_finesse        = 659 , -- (248443) Casting Aimed Shot provides you with Ranger's Finesse. After gaining $408518u stacks of Ranger's Finesse, increase your next Volley's radius and duration by $408518s1% or your next Bursting Shot's slow by an additional $408518s2% and its knockback distance.; Consuming Ranger's Finesse reduces the remaining cooldown of Aspect of the Turtle by $s1 sec.
    sniper_shot            = 660 , -- (203155) Take a sniper's stance, firing a well-aimed shot dealing $s2% of the target's maximum health in Physical damage and increases the range of all shots by $s3% for $d.
    survival_tactics       = 651 , -- (202746) Feign Death reduces damage taken by $m1% for $202748d.
    trueshot_mastery       = 658 , -- (203129) Reduces the cooldown of Trueshot by ${($m4/1000)*-1} sec, and Trueshot also restores $203132s1% Focus.
    wild_kingdom           = 5442, -- (356707) Call in help from one of your dismissed $?a264656[Tenacity][Cunning] pets for $d. Your current pet is dismissed to rest and heal $358250s1% of maximum health.
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
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Firing at the target.
    auto_shot = {
        id = 75,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- lone_wolf[155228] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lone_wolf[155228] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- bullseye[204090] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- survival_hunter[137017] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Being targeted by Rapid Fire.
    barrage = {
        id = 459796,
        duration = 2.0,
        tick_time = 0.33,
        max_stack = 1,

        -- Affected by:
        -- marksmanship_hunter[137016] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- fan_the_hammer[459794] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -34.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- rapid_fire_barrage[459800] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sniper_shot[203155] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
    -- Stunned.
    binding_shot = {
        id = 117526,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- tarcoated_bindings[459460] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Taking $w1 Shadow damage every $t1 seconds.
    black_arrow = {
        id = 194599,
        duration = 8.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Multi-Shot damage increased by $s1%.
    bulletstorm = {
        id = 389020,
        duration = 15.0,
        max_stack = 1,
    },
    -- Critical strike chance increased by $s1%.
    bullseye = {
        id = 204090,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- bullseye[204089] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Disoriented.
    bursting_shot = {
        id = 238559,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rangers_finesse[408518] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- rangers_finesse[408518] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Stealthed.
    camouflage = {
        id = 199483,
        duration = 60.0,
        max_stack = 1,
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

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Movement slowed by $s1%.
    concussive_shot = {
        id = 5116,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- consecutive_concussion[357018] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Stunned.
    consecutive_concussion = {
        id = 357021,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- consecutive_concussion[357018] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Your next ability is empowered.; $@spellname259495: Initial damage increased by $w2%.; $@spellname320976: Applies Bleeding Gash to your target.
    coordinated_assault = {
        id = 361738,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Taking $w1% increased Physical damage from $@auracaster.
    death_chakram = {
        id = 361756,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Your next Kill Shot can be used on any target, regardless of their current health.
    deathblow = {
        id = 378770,
        duration = 12.0,
        max_stack = 1,
    },
    -- Distracted.
    distracting_shot = {
        id = 20736,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
    -- All abilities are guaranteed to apply Sentinel.
    eyes_closed = {
        id = 451180,
        duration = 8.0,
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
    -- Bleeding for $s1 Shadow damage every $t1 sec.
    flayed_shot = {
        id = 324149,
        duration = 18.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Your next Kill Shot can be used on any target, regardless of their current health, deals $s3% increased damage, and will not consume any Focus.
    flayers_mark = {
        id = 324156,
        duration = 12.0,
        max_stack = 1,
    },
    -- Incapacitated.; Unable to be healed or damaged.
    freezing_trap = {
        id = 203337,
        duration = 5.0,
        max_stack = 1,
    },
    -- Movement speed slowed by $s2%.
    glaive_toss = {
        id = 120761,
        duration = 3.0,
        max_stack = 1,
    },
    -- Can always be seen and tracked by the Hunter.; Damage taken increased by $428402s4% while above $s3% health.
    hunters_mark = {
        id = 257284,
        duration = 3600,
        tick_time = 0.5,
        max_stack = 1,
    },
    -- Haste increased by $s1%.
    in_the_rhythm = {
        id = 407405,
        duration = 6.0,
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
    -- $@auracaster can attack this target regardless of line of sight.; $@auracaster deals $w2% increased damage to this target.
    kill_zone = {
        id = 393480,
        duration = 3600,
        max_stack = 1,
    },
    -- Aimed Shot costs no Focus and is instant.
    lock_and_load = {
        id = 194594,
        duration = 15.0,
        max_stack = 1,
    },
    -- Damage taken from $@auracaster and their pets increased by $w1%.
    lunar_storm = {
        id = 450884,
        duration = 8.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 damage every $t1 sec.
    master_marksman = {
        id = 269576,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,
    },
    -- Range increased by $w1%.; Focus spending abilites deal $s2% increased damage.
    mastery_sniper_training = {
        id = 193468,
        duration = 0.0,
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
    -- Damage of $?s342049[Chimaera Shot][Arcane Shot] or Multi-Shot increased by $s1 and their Focus cost is reduced by $s6%.
    precise_shots = {
        id = 260242,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- precise_shots[260240] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 70.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- precise_shots[260240] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 70.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Recently benefitted from Quick Load.
    quick_load = {
        id = 385646,
        duration = 25.0,
        max_stack = 1,
    },
    -- After gaining $u stacks, increase your next Volley's radius and duration by $s1% or your next Bursting Shot's slow by an additional $s2% and its knockback distance.
    rangers_finesse = {
        id = 408518,
        duration = 18.0,
        max_stack = 1,
    },
    -- Being targeted by Rapid Fire.
    rapid_fire = {
        id = 257044,
        duration = 2.0,
        tick_time = 0.33,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fan_the_hammer[459794] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -34.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- streamline[260367] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- streamline[260367] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tactical_reload[400472] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- trueshot[288613] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'points': 235.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Bleeding for $w1 damage every $t1 sec.
    razor_fragments = {
        id = 385638,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- unnatural_causes[459527] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Your next Multi-Shot or Volley now also applies Explosive Shot to up to $s1 $Ltarget:targets; hit.
    salvo = {
        id = 400456,
        duration = 15.0,
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

        -- Affected by:
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
    -- Haste increased by $s1%.
    steady_focus = {
        id = 193534,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- steady_focus[193533] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
    -- The cooldown of Aimed Shot and Rapid Fire is reduced by ${100*(1-(100/(100+$m1)))}%, and Aimed Shot casts $s4% faster.; All Focus generation is increased by $s5%.
    trueshot = {
        id = 288613,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- eagletalons_true_focus[389449] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- trueshot_mastery[203129] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Critical strike chance increased by $s1%. Critical damage dealt increased by $s2%.
    unerring_vision = {
        id = 386877,
        duration = 60.0,
        max_stack = 1,
    },
    -- Auto attacks also spend $s1 Focus to launch a volley of shots that hit the target and all other nearby enemies.
    volley = {
        id = 194386,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- beast_mastery_hunter[137015] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rangers_finesse[408518] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- rangers_finesse[408518] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Silenced.
    wailing_arrow = {
        id = 392061,
        duration = 3.0,
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
    -- Incapacitated.
    wyvern_sting = {
        id = 19386,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- A powerful aimed shot that deals $s1 Physical damage$?s260240[ and causes your next 1-$260242u ][]$?s342049&s260240[Chimaera Shots]?s260240[Arcane Shots][]$?s260240[ or Multi-Shots to deal $260242s1% more damage][].$?s260228[; Aimed Shot deals $393952s1% bonus damage to targets who are above $260228s1% health.][]$?s378888[; Aimed Shot also fires a Serpent Sting at the primary target.][]
    aimed_shot = {
        id = 19434,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'focus',

        talent = "aimed_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 3.63, 'pvp_multiplier': 1.55, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- specialized_arsenal[459542] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- specialized_arsenal[459542] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- focused_aim[378767] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lone_wolf[155228] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lone_wolf[155228] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- night_hunter[378766] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- overshadow[430716] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel_precision[450375] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel_precision[450375] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- trueshot[288613] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- bullseye[204090] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- eagletalons_true_focus[389450] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lock_and_load[194594] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- lock_and_load[194594] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lock_and_load[194594] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- A powerful aimed shot that deals $s1 Physical damage. 
    aimed_shot_257276 = {
        id = 257276,
        cast = 3.5,
        cooldown = 12.0,
        gcd = "global",

        spend = 50,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.241136, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- specialized_arsenal[459542] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- specialized_arsenal[459542] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- focused_aim[378767] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- night_hunter[378766] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- overshadow[430716] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel_precision[450375] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel_precision[450375] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- trueshot[288613] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- eagletalons_true_focus[389450] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lock_and_load[194594] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- lock_and_load[194594] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lock_and_load[194594] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
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
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crack_shot[321293] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lone_wolf[155228] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lone_wolf[155228] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- bullseye[204090] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- eagletalons_true_focus[389450] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- precise_shots[260242] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- precise_shots[260242] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- marksmanship_hunter[137016] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rapid_fire_barrage[459800] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- sniper_shot[203155] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Shoots Rapid Fires at your target and up to $s3 nearby enemies at $459800s4% effectiveness.
    barrage_459796 = {
        id = 459796,
        cast = 2.0,
        channeled = true,
        cooldown = 20.0,
        gcd = "global",

        spend = 60,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.33, 'points': 40.0, 'radius': 10.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- marksmanship_hunter[137016] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- fan_the_hammer[459794] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -34.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- rapid_fire_barrage[459800] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sniper_shot[203155] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        from = "from_description",
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
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Fires a Black Arrow at the target, dealing $o1 Shadow damage over $d and summoning a Dark Minion to taunt it for the duration.; When you kill an enemy, the remaining cooldown on Black Arrow will reset.
    black_arrow_194599 = {
        id = 194599,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 10,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'ap_bonus': 0.21293999, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 186070, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        from = "affected_by_mastery",
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
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lone_wolf[155228] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lone_wolf[155228] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bullseye[204090] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rangers_finesse[408518] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- rangers_finesse[408518] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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

    -- Throw a deadly chakram at your current target that will rapidly deal $375893s1 Physical damage $x times, bouncing to other targets if they are nearby. Enemies struck by Death Chakram take $375893s2% more damage from you and your pet for $375893d.; Each time the chakram deals damage, its damage is increased by $s3% and you generate $s4 Focus.
    chakram = {
        id = 375891,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'chain_amp': 1.15, 'chain_targets': 7, 'ap_bonus': 0.316, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- A two-headed shot that hits your primary target for $344120sw1 Nature damage and another nearby target for ${$344121sw1*($s1/100)} Frost damage.$?s260393[; Chimaera Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    chimaera_shot = {
        id = 342049,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'focus',

        talent = "chimaera_shot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'chain_targets': 2, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- marksmanship_hunter[137016] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hunter[137014] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- crack_shot[321293] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- eagletalons_true_focus[389450] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- precise_shots[260242] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- precise_shots[260242] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- A two-headed shot that hits your primary target and another nearby target, dealing $171457sw2 Nature damage to one and $171454sw2 Frost damage to the other.$?s137015[; Generates $204304s1 Focus for each target hit.][]
    chimaera_shot_53209 = {
        id = 53209,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'chain_targets': 2, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- hunter[137014] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        from = "affected_by_mastery",
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
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- consecutive_concussion[357018] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- lone_survivor[388039] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Distracts the target to attack $?s123632[your pet][you] for $d.
    distracting_shot = {
        id = 20736,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': THREAT, 'subtype': NONE, 'points': 110.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_TAUNT, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Fire a shot at your enemy, dealing $s3 Shadow damage and then causing them to bleed for $o1 Shadow damage over $d. Each time Flayed Shot deals damage, you have a $s2% chance to gain Flayer's Mark, causing your next Kill Shot to be free, usable on any target regardless of their current health, and deal $324156s3% increased damage.
    flayed_shot = {
        id = 324149,
        color = 'venthyr',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'ap_bonus': 0.125, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.5, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- You hurl two glaives toward a target, each dealing $120761s1 damage to each enemy struck and reducing movement speed by $120761s2% for $120761d.  The primary target will take $s1 times as much damage from each strike.; The Glaives will return back to you, damaging and snaring targets again as they return.
    glaive_toss = {
        id = 213831,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.2, 'points': 4.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 120755, 'points': 50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 120756, 'points': 50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- sniper_shot[203155] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 7.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- improved_kill_shot[343248] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- killer_accuracy[378765] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- killer_accuracy[378765] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- lone_wolf[155228] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lone_wolf[155228] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- bullseye[204090] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deathblow[378770] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'points': 7.0, 'target': TARGET_UNIT_CASTER, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- survival_hunter[137017] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- razor_fragments[388998] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flayers_mark[324156] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- flayers_mark[324156] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- flayers_mark[324156] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- marksmanship_hunter[137016] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 7.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_kill_shot[343248] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- killer_accuracy[378765] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- killer_accuracy[378765] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- deathblow[378770] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'points': 7.0, 'target': TARGET_UNIT_CASTER, }
        -- survival_hunter[137017] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- razor_fragments[388998] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flayers_mark[324156] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- flayers_mark[324156] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- flayers_mark[324156] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- Fires several missiles, hitting your current target and all enemies within $A1 yards for $s1 Physical damage. Deals reduced damage beyond $2643s1 targets.$?s260393[; Multi-Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    multishot = {
        id = 257620,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 30,
        spendType = 'focus',

        talent = "multishot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.5076, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- small_game_hunter[459802] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eagletalons_true_focus[389450] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- precise_shots[260242] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- precise_shots[260242] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- bulletstorm[389020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 7.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Fires several missiles, hitting all nearby enemies within $A2 yds of your current target for $s2 Physical damage$?s115939[ and triggering Beast Cleave][]. Deals reduced damage beyond $s1 targets.$?s19434[; Generates $213363s1 Focus per target hit.][]
    multishot_2643 = {
        id = 2643,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.126, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- lone_wolf[155228] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lone_wolf[155228] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- small_game_hunter[459802] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- bullseye[204090] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- eagletalons_true_focus[389450] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- precise_shots[260242] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- precise_shots[260242] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bulletstorm[389020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 7.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
    },

    -- A powerful shot which deals $sw3 Physical damage to the target and up to ${$sw3/($s1/10)} Physical damage to all enemies between you and the target. ; Piercing Shot ignores the target's armor.
    piercing_shot = {
        id = 198670,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 20,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'ap_bonus': 0.45, 'variance': 0.05, 'radius': 100.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_LINE_CASTER_TO_DEST_ENEMY, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.125, 'variance': 0.05, 'radius': 5.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- [198670] A powerful shot which deals $sw3 Physical damage to the target and up to ${$sw3/($s1/10)} Physical damage to all enemies between you and the target. ; Piercing Shot ignores the target's armor.
    piercing_shot_213678 = {
        id = 213678,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 20,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'ap_bonus': 1.125, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "affected_by_mastery",
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

    -- Shoot a stream of $s1 shots at your target over $d, dealing a total of ${$m1*$257045sw1} Physical damage. Usable while moving.$?s260367[; Rapid Fire causes your next Aimed Shot to cast $342076s1% faster.][]; Each shot generates $263585s1 Focus.
    rapid_fire = {
        id = 257044,
        cast = 2.0,
        channeled = true,
        cooldown = 20.0,
        gcd = "global",

        talent = "rapid_fire",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.33, 'points': 40.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fan_the_hammer[459794] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -34.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- streamline[260367] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- streamline[260367] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tactical_reload[400472] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- trueshot[288613] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'points': 235.0, 'target': TARGET_UNIT_CASTER, }
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

        -- Affected by:
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Launches Sidewinders that travel toward the target, weaving back and forth and dealing $214581s1 Nature damage to each target they hit. Cannot hit the same target twice. Applies Vulnerable to all targets hit.; Generates $s2 Focus.$?s214579[][; Also replaces Multi-Shot.]
    sidewinders = {
        id = 214579,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'resource': focus, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 60.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- sniper_shot[203155] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- [214579] Launches Sidewinders that travel toward the target, weaving back and forth and dealing $214581s1 Nature damage to each target they hit. Cannot hit the same target twice. Applies Vulnerable to all targets hit.; Generates $s2 Focus.$?s214579[][; Also replaces Multi-Shot.]
    sidewinders_240711 = {
        id = 240711,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- sniper_shot[203155] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        from = "affected_by_mastery",
    },

    -- Take a sniper's stance, firing a well-aimed shot dealing $s2% of the target's maximum health in Physical damage and increases the range of all shots by $s3% for $d.
    sniper_shot = {
        id = 203155,
        color = 'pvp_talent',
        cast = 3.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 40,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DAMAGE_FROM_MAX_HEALTH_PCT, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- mastery_sniper_training[193468] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marksmanship_hunter[137016] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- improved_steady_shot[321018] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- lone_wolf[155228] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lone_wolf[155228] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- bullseye[204090] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- freezing_trap[3355] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- survival_hunter[137017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- survival_hunter[137017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beast_mastery_hunter[137015] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- kodo_tranquilizer[459983] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- kodo_tranquilizer[459983] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- kodo_tranquilizer[459983] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_DISTANCE, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Reduces the cooldown of your Aimed Shot and Rapid Fire by ${100*(1-(100/(100+$m1)))}%, and causes Aimed Shot to cast $s4% faster for $d.; While Trueshot is active, you generate $s5% additional Focus$?s386878[ and you gain $386877s1% critical strike chance and $386877s2% increased critical damage dealt every $386876t1 sec, stacking up to $386877u times][].$?s260404[; Every $260404s2 Focus spent reduces the cooldown of Trueshot by ${$260404m1/1000}.1 sec.][]
    trueshot = {
        id = 288613,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "trueshot",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'points': 235.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 235.0, 'value': 1715, 'schools': ['physical', 'holy', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_RUNE_REGEN_SPEED, 'points': 50.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_POWER_REGEN_PERCENT, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'resource': focus, }

        -- Affected by:
        -- eagletalons_true_focus[389449] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- trueshot_mastery[203129] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Rain a volley of arrows down over $d, dealing up to ${$260247s1*12} Physical damage to any enemy in the area, and gain the effects of Trick Shots for as long as Volley is active.
    volley = {
        id = 260243,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "volley",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.5, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnatural_causes[459527] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnatural_causes[459529] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- beast_mastery_hunter[137015] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rangers_finesse[408518] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- rangers_finesse[408518] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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

    -- Fire an enchanted arrow, dealing $392058s1 Shadow damage to your target and an additional $392058s2 Shadow damage to all enemies within $392058A2 yds of your target. Non-Player targets struck by a Wailing Arrow have their spellcasting interrupted and are silenced for $392061d.$?s389865[; Wailing Arrow resets the cooldown of Rapid Fire and generates $389865s2 $Lcharge:charges; of Aimed Shot.][]$?s389866[; Wailing Arrow fires off $389866s1 Wind Arrows at your primary target, and $389866s2 Wind Arrows split among any secondary targets hit, each dealing $191043s1 Physical damage.][]
    wailing_arrow_392060 = {
        id = 392060,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 15,
        spendType = 'focus',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 392058, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 392061, 'ap_bonus': 1.85, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.4, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- specialized_arsenal[459542] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- specialized_arsenal[459542] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- focused_aim[378767] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- night_hunter[378766] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- overshadow[430716] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel_precision[450375] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel_precision[450375] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- trueshot[288613] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- eagletalons_true_focus[389450] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lock_and_load[194594] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.25, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- lock_and_load[194594] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lock_and_load[194594] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
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

    -- A stinging shot that puts the target to sleep, incapacitating them for $d. Damage will cancel the effect. Usable while moving.
    wyvern_sting = {
        id = 19386,
        cast = 1.5,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'mechanic': asleep, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_sniper_training[193468] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.625, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- hunter[137014] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- sniper_shot[203155] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

} )