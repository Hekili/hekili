-- HunterMarksmanship.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 254, true )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)

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
        value = 2,
    }
} )

-- Talents
spec:RegisterTalents( {

    -- Hunter
    binding_shackles               = { 102388,  321468, 1 }, -- Targets stunned by Binding Shot, knocked back by High Explosive Trap, knocked up by Implosive Trap, incapacitated by Scatter Shot, or stunned by Intimidation deal $s1% less damage to you for $s2 sec after the effect ends
    binding_shot                   = { 102386,  109248, 1 }, -- Fires a magical projectile, tethering the enemy and any other enemies within $s1 yds for $s2 sec, stunning them for $s3 sec if they move more than $s4 yds from the arrow
    blackrock_munitions            = { 102392,  462036, 1 }, -- The damage of Explosive Shot is increased by $s2%$s$s3 Pet damage bonus of Harmonize increased by $s4%
    born_to_be_wild                = { 102416,  266921, 1 }, -- The cooldown of Aspect of the Cheetah, and Aspect of the Turtle are reduced by $s1 sec
    bursting_shot                  = { 102421,  186387, 1 }, -- Fires an explosion of bolts at all enemies in front of you, knocking them back, snaring them by $s2% for $s3 sec, and dealing $s$s4 Physical damage
    camouflage                     = { 102414,  199483, 1 }, -- You and your pet blend into the surroundings and gain stealth for $s1 min. While camouflaged, you will heal for $s2% of maximum health every $s3 sec
    concussive_shot                = { 102407,    5116, 1 }, -- Dazes the target, slowing movement speed by $s1% for $s2 sec. Steady Shot will increase the duration of Concussive Shot on the target by $s3 sec
    counter_shot                   = { 102402,  147362, 1 }, -- Interrupts spellcasting, preventing any spell in that school from being cast for $s1 sec
    deathblow                      = { 102410,  343248, 1 }, -- Aimed Shot has a $s1% chance to grant Deathblow.  Deathblow The cooldown of Black Arrow is reset. Your next Black Arrow can be used on any target, regardless of their current health
    devilsaur_tranquilizer         = { 102415,  459991, 1 }, -- If Tranquilizing Shot removes only an Enrage effect, its cooldown is reduced by $s1 sec
    disruptive_rounds              = { 102395,  343244, 1 }, -- When Tranquilizing Shot successfully dispels an effect or Counter Shot interrupts a cast, gain $s1 Focus
    emergency_salve                = { 102389,  459517, 1 }, -- Feign Death and Aspect of the Turtle removes poison and disease effects from you
    entrapment                     = { 102403,  393344, 1 }, -- When Tar Trap is activated, all enemies in its area are rooted for $s1 sec. Damage taken may break this root
    explosive_shot                 = { 102420,  212431, 1 }, -- Fires an explosive shot at your target. After $s2 sec, the shot will explode, dealing $s$s3 Fire damage to all enemies within $s4 yds. Deals reduced damage beyond $s5 targets
    ghillie_suit                   = { 102385,  459466, 1 }, -- You take $s1% reduced damage while Camouflage is active. This effect persists for $s2 sec after you leave Camouflage
    harmonize                      = { 102420, 1245926, 1 }, -- All pet damage dealt increased by $s1%
    high_explosive_trap            = { 102739,  236776, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $s$s2 Fire damage and knocking all enemies away. Limit $s3. Trap will exist for $s4 min
    hunters_avoidance              = { 102423,  384799, 1 }, -- Damage taken from area of effect attacks reduced by $s1%
    implosive_trap                 = { 102739,  462031, 1 }, -- Hurls a fire trap to the target location that explodes when an enemy approaches, causing $s$s2 Fire damage and knocking all enemies up. Limit $s3. Trap will exist for $s4 min
    improved_traps                 = { 102418,  343247, 1 }, -- The cooldown of Tar Trap, High Explosive Trap, Implosive Trap, and Freezing Trap is reduced by $s1 sec
    intimidation                   = { 103990,  474421, 1 }, -- Your Spotting Eagle descends from the skies, stunning your target for $s1 sec. This ability does not require line of sight when used against players
    keen_eyesight                  = { 102409,  378004, 2 }, -- Critical strike chance increased by $s1%
    kill_shot                      = { 102399,   53351, 1 }, -- You attempt to finish off a wounded target, dealing $s$s2 Physical damage. Only usable on enemies with less than $s3% health
    kindling_flare                 = { 102425,  459506, 1 }, -- Flare's radius is increased by $s1%
    kodo_tranquilizer              = { 102415,  459983, 1 }, -- Tranquilizing Shot removes up to $s1 additional Magic effect from up to $s2 nearby targets
    lone_survivor                  = { 102391,  388039, 1 }, -- The cooldown of Survival of the Fittest is reduced by $s1 sec, and its duration is increased by $s2 sec. The cooldown of Counter Shot is reduced by $s3 sec
    misdirection                   = { 102419,   34477, 1 }, -- Misdirects all threat you cause to the targeted party or raid member, beginning with your next attack within $s1 sec and lasting for $s2 sec
    moment_of_opportunity          = { 102426,  459488, 1 }, -- When a trap triggers, you gain $s1% movement speed for $s2 sec
    natural_mending                = { 102401,  270581, 1 }, -- Every $s1 Focus you spend reduces the remaining cooldown on Exhilaration by $s2 sec
    no_hard_feelings               = { 102412,  459546, 1 }, -- When Misdirection targets your pet, it reduces the damage they take by $s1% for $s2 sec. The cooldown of Misdirection is reduced by $s3 sec
    padded_armor                   = { 102406,  459450, 1 }, -- Survival of the Fittest gains an additional charge
    pathfinding                    = { 102404,  378002, 1 }, -- Movement speed increased by $s1%
    posthaste                      = { 102411,  109215, 1 }, -- Disengage also frees you from all movement impairing effects and increases your movement speed by $s1% for $s2 sec
    quick_load                     = { 102413,  378771, 1 }, -- When you fall below $s1% health, Bursting Shot and Scatter Shot have their cooldown immediately reset. This can only occur once every $s2 sec
    rejuvenating_wind              = { 102381,  385539, 1 }, -- Maximum health increased by $s1%, and Exhilaration now also heals you for an additional $s2% of your maximum health over $s3 sec
    roar_of_sacrifice              = { 102405,   53480, 1 }, -- Instructs your pet to protect a friendly target from critical strikes, making attacks against that target unable to be critical strikes. Lasts $s1 sec. While Roar of Sacrifice is active, your Spotting Eagle cannot apply Spotter's Mark
    scare_beast                    = { 102382,    1513, 1 }, -- Scares a beast, causing it to run in fear for up to $s1 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time
    scatter_shot                   = { 102421,  213691, 1 }, -- A short-range shot that deals $s2 damage, removes all harmful damage over time effects, and incapacitates the target for $s3 sec$s$s4 Any damage caused will remove the effect. Turns off your attack when used
    scouts_instincts               = { 102424,  459455, 1 }, -- You cannot be slowed below $s1% of your normal movement speed while Aspect of the Cheetah is active
    scrappy                        = { 102408,  459533, 1 }, -- Casting Aimed Shot reduces the cooldown of Intimidation and Binding Shot by $s1 sec
    serrated_tips                  = { 102384,  459502, 1 }, -- You gain $s1% more critical strike from critical strike sources
    specialized_arsenal            = { 102390,  459542, 1 }, -- Aimed Shot deals $s1% increased damage
    survival_of_the_fittest        = { 102422,  264735, 1 }, -- Reduces all damage you and your pet take by $s1% for $s2 sec
    tar_trap                       = { 102393,  187698, 1 }, -- Hurls a tar trap to the target location that creates a $s1 yd radius pool of tar around itself for $s2 sec when the first enemy approaches. All enemies have $s3% reduced movement speed while in the area of effect. Limit $s4. Trap will exist for $s5 min
    tarcoated_bindings             = { 102417,  459460, 1 }, -- Binding Shot's stun duration is increased by $s1 sec
    territorial_instincts          = { 102394,  459507, 1 }, -- The cooldown of Intimidation is reduced by $s1 sec
    trailblazer                    = { 102400,  199921, 1 }, -- Your movement speed is increased by $s1% anytime you have not attacked for $s2 sec
    tranquilizing_shot             = { 102380,   19801, 1 }, -- Removes $s1 Enrage and $s2 Magic effect from an enemy target. Successfully dispelling an effect generates $s3 Focus
    trigger_finger                 = { 102396,  459534, 2 }, -- You and your pet have $s1% increased attack speed. This effect is increased by $s2% if you do not have an active pet
    unnatural_causes               = { 102387,  459527, 1 }, -- Your damage over time effects deal $s1% increased damage. This effect is increased by $s2% on targets below $s3% health
    wilderness_medicine            = { 102383,  343242, 1 }, -- Natural Mending now reduces the cooldown of Exhilaration by an additional $s1 sec Mend Pet heals for an additional $s2% of your pet's health over its duration, and has a $s3% chance to dispel a magic effect each time it heals your pet

    -- Marksmanship
    aimed_shot                     = { 103982,   19434, 1 }, -- A powerful aimed shot that deals $s$s2 Physical damage
    ammo_conservation              = { 103975,  459794, 1 }, -- Rapid Fire shoots $s1 additional shots. Aimed Shot cooldown reduced by $s2 sec
    aspect_of_the_hydra            = { 103957,  470945, 1 }, -- Aimed Shot, Rapid Fire, and Arcane Shot now hit $s1 additional target for $s2% of their damage
    avian_specialization           = { 104127,  466867, 1 }, -- The damage bonus of Spotter's Mark is increased by $s1%. Additionally, your Eagle learns how to Fetch.  Spotter's Mark Damaging an enemy with abilities empowered by Precise Shots has a $s4% chance to apply Spotter's Mark to the primary target, causing your next Aimed Shot to deal $s5% increased damage to the target
    bullet_hell                    = { 104095,  473378, 1 }, -- Damage from Multi-Shot and Volley reduces the cooldown of Rapid Fire by $s1 sec. Damage from Aimed Shot reduces the cooldown of Volley by $s2 sec
    bulletstorm                    = { 103962,  389019, 1 }, -- Damage from Rapid Fire increases the damage of Aimed Shot by $s1% for $s2 sec, stacking up to $s3 times. New stacks do not refresh duration and are removed upon casting Rapid Fire
    bullseye                       = { 103985,  204089, 1 }, -- When your abilities damage a target below $s1% health, you gain $s2% increased critical strike chance for $s3 sec, stacking up to $s4 times
    calling_the_shots              = { 103958,  260404, 1 }, -- Trueshot's cooldown is reduced by $s1 sec
    cunning                        = { 103986,  474440, 1 }, -- Your Spotting Eagle gains the Cunning specialization, granting you Master's Call and Pathfinding.  Master's Call Your pet removes all root and movement impairing effects from itself and a friendly target, and grants immunity to all such effects for $s3 sec.  Pathfinding Your movement speed is increased by $s6%
    deadeye                        = { 103972,  321460, 1 }, -- Black Arrow now has $s1 charges and has its cooldown reduced by $s2 sec
    double_tap                     = { 103953,  473370, 1 }, -- Casting Trueshot or Volley grants Double Tap, causing your next Aimed Shot to fire again at $s1% power, or your next Rapid Fire to fire $s2% additional shots during its channel
    eagles_accuracy                = { 103973,  473369, 2 }, -- Aimed Shot and Rapid Fire's damage is increased by $s1%
    feathered_frenzy               = { 103984,  470943, 1 }, -- Trueshot sends your Spotting Eagle into a frenzy, instantly applying Spotter's Mark to your target. During Trueshot, your chance to apply Spotter's Mark is increased by $s1%
    focused_aim                    = { 103987,  378767, 1 }, -- Consuming Precise Shots reduces the cooldown of Aimed Shot by $s1 sec
    headshot                       = { 103972,  471363, 1 }, -- Black Arrow can now benefit from Precise Shots at $s1% effectiveness. Black Arrow consumes Precise Shots
    improved_deathblow             = { 103969,  378769, 1 }, -- Aimed Shot now has a $s1% chance and Rapid Fire now has a $s2% chance to grant Deathblow. Black Arrow critical strike damage is increased by $s3%.  Deathblow The cooldown of Black Arrow is reset. Your next Black Arrow can be used on any target, regardless of their current health
    improved_streamline            = { 103987,  471427, 1 }, -- Streamline's cast time reduction effect is increased to $s1%
    in_the_rhythm                  = { 103948,  407404, 1 }, -- When Rapid Fire finishes channeling, the time between your Auto Shots is reduced by $s1 sec for $s2 sec
    incendiary_ammunition          = { 107290,  471428, 1 }, -- Bulletstorm now increases your critical strike damage by $s1%. Additionally, Bulletstorm now stacks $s2 more times
    kill_zone                      = { 103960,  459921, 1 }, -- Your spells and attacks deal $s1% increased damage and ignore line of sight against any target in your Volley
    light_ammo                     = { 107288,  378913, 1 }, -- Trick Shots now causes Aimed Shot and Rapid Fire to ricochet to $s1 additional targets. Aspect of the Hydra's damage bonus is increased by $s2%
    lock_and_load                  = { 107289,  194595, 1 }, -- Your ranged auto attacks have a $s1% chance to trigger Lock and Load, causing your next Aimed Shot to cost no Focus and be instant
    magnetic_gunpowder             = { 103981,  473522, 1 }, -- Consuming Precise Shots reduces the cooldown of Explosive Shot by $s1 sec. Consuming Lock and Load reduces the cooldown of Explosive Shot by $s2 sec
    master_marksman                = { 103974,  260309, 1 }, -- Your ranged ability critical strikes cause the target to bleed for an additional $s1% of the damage dealt over $s2 sec
    moving_target                  = { 103980,  474296, 1 }, -- Consuming Precise Shots increases the damage of your next Aimed Shot by $s1% and grants Streamline.  Streamline Your next Aimed Shot has its Focus cost and cast time reduced by $s4%. Stacks up to $s5 times
    no_scope                       = { 103955,  473385, 1 }, -- Rapid Fire grants Precise Shots
    obsidian_arrowhead             = { 103959,  471350, 1 }, -- The damage of Auto Shot is increased by $s1% and its critical strike chance is increased by $s2%
    ohnahran_winds                 = { 103979, 1215021, 1 }, -- When your Eagle applies Spotter's Mark, it has a $s1% chance to apply a Spotter's Mark to up to $s2 additional nearby enemy at $s3% effectiveness
    on_target                      = { 103959,  471348, 1 }, -- Consuming Spotter's Mark grants $s1% increased Haste for $s2 sec, stacking up to $s3 times. Multiple instances of this effect can overlap
    penetrating_shots              = { 104130,  459783, 1 }, -- Gain critical strike damage equal to $s1% of your critical strike chance
    precise_shots                  = { 103977,  260240, 1 }, -- Aimed Shot causes your next Arcane Shot or Multi-Shot to deal $s1% more damage, cost $s2% less Focus, and have its global cooldown reduced by $s3%. Your Auto Shot damage is increased by $s4% but the time between your Auto Shots is increased by $s5 sec
    precision_detonation           = { 103949,  471369, 1 }, -- When Aimed Shot damages a target affected by your Explosive Shot, Explosive Shot instantly explodes, dealing $s1% increased damage
    rapid_fire                     = { 103961,  257044, 1 }, -- Shoot a stream of $s1 shots at your target over $s2 sec, dealing a total of $s3 million Physical damage. Usable while moving. Rapid Fire causes your next Aimed Shot to cast $s4% faster. Each shot generates $s5 Focus
    razor_fragments                = { 103965,  384790, 1 }, -- After gaining Deathblow, your next Black Arrow will deal $s1% increased damage, and shred up to $s2 targets near your Black Arrow target for $s3% of the damage dealt by Black Arrow over $s4 sec
    salvo                          = { 103960,  400456, 1 }, -- Volley now also applies Explosive Shot to up to $s1 targets hit
    shrapnel_shot                  = { 104126,  473520, 1 }, -- Casting Explosive Shot has a $s1% chance to grant Lock and Load
    small_game_hunter              = { 103978,  459802, 1 }, -- Multi-Shot deals $s1% increased damage and Explosive Shot deals $s2% increased damage
    streamline                     = { 103983,  260367, 1 }, -- Rapid Fire's damage is increased by $s1%. Casting Rapid Fire grants Streamline.  Streamline Your next Aimed Shot has its Focus cost and cast time reduced by $s4%. Stacks up to $s5 times
    surging_shots                  = { 103964,  391559, 1 }, -- Rapid Fire deals $s1% additional damage, and Aimed Shot has a $s2% chance to reset the cooldown of Rapid Fire
    target_acquisition             = { 103968,  473379, 1 }, -- Consuming Spotter's Mark reduces the cooldown of Aimed Shot by $s1 sec
    tenacious                      = { 103986,  474456, 1 }, -- Your Spotting Eagle gains the Tenacity specialization, granting you Endurance Training and Air Superiority.  Endurance Training You gain $s3% increased maximum health.  Air Superiority Your Spotting Eagle alerts you to oncoming danger, reducing all damage you take by $s6%
    tensile_bowstring              = { 103966,  471366, 1 }, -- While Trueshot is active, consuming Precise Shots extends Trueshot's duration by $s1 sec, up to $s2 sec. Additionally, Trueshot now increases the effectiveness of Streamline by $s3%
    trick_shots                    = { 103957,  257621, 1 }, -- When Multi-Shot hits $s1 or more targets, your next Aimed Shot or Rapid Fire will ricochet and hit up to $s2 additional targets for $s3% of normal damage
    trueshot                       = { 103947,  288613, 1 }, -- Increases your critical strike chance by $s1% and critical strike damage by $s2% for $s3 sec. Reduces the cooldown of your Aimed Shot and Rapid Fire by $s4%
    unbreakable_bond               = { 104127, 1223323, 1 }, -- Regain access to Call Pet. While outdoors, your pet deals $s1% increased damage and takes $s2% reduced damage
    unerring_vision                = { 103958,  474738, 1 }, -- Trueshot now increases your critical strike chance by an additional $s1% and increases your critical strike damage by an additional $s2%
    unmatched_precision            = { 103950, 1232955, 2 }, -- The damage bonus of Precise Shots is increased by an additional $s1%
    volley                         = { 103956,  260243, 1 }, -- Rain a volley of arrows down over $s1 sec, dealing up to $s2 million Physical damage to any enemy in the area, and gain the effects of Trick Shots for as long as Volley is active
    windrunner_quiver              = { 103952,  473523, 1 }, -- Precise Shots can now stack up to $s1 times, but its damage bonus is reduced to $s2%. Casting Aimed Shot has a $s3% chance to grant an additional stack of Precise Shots

    -- Dark Ranger
    banshees_mark                  = {  94957,  467902, 1 }, -- Black Arrow's initial damage has a $s2% chance to summon a flock of crows to attack your target, dealing $s$s3 Shadow damage over $s4 sec
    black_arrow                    = {  94987,  466932, 1 }, -- Your Kill Shot is replaced with Black Arrow.  Black Arrow You attempt to finish off a wounded target, dealing $s$s5 Shadow damage and $s$s6 Shadow damage over $s7 sec. Only usable on enemies above $s8% health or below $s9% health
    bleak_arrows                   = {  94961,  467749, 1 }, -- Your auto shot now deals Shadow damage, allowing it to bypass armor. Your auto shot has a $s1% chance to grant Deathblow.  Deathblow The cooldown of Black Arrow is reset. Your next Black Arrow can be used on any target, regardless of their current health
    bleak_powder                   = {  94974,  467911, 1 }, -- Black Arrow now explodes in a cloud of shadow and sulfur on impact, dealing $s$s2 Shadow damage to all enemies within an $s3 yd cone behind the target. Damage reduced beyond $s4 targets
    dark_chains                    = {  94960,  430712, 1 }, -- While in combat, Disengage will chain the closest target to the ground, causing them to move $s1% slower until they move $s2 yards away
    ebon_bowstring                 = {  94986,  467897, 1 }, -- Casting Black Arrow has a $s1% chance to grant Deathblow.  Deathblow The cooldown of Black Arrow is reset. Your next Black Arrow can be used on any target, regardless of their current health
    phantom_pain                   = {  94986,  467941, 1 }, -- When Aimed Shot deals damage, $s1% of the damage dealt is replicated to up to $s2 other units affected by Black Arrow's periodic damage
    shadow_dagger                  = {  94960,  467741, 1 }, -- While in combat, Disengage releases a fan of shadow daggers, dealing $s$s2 Shadow damage per second and reducing affected target's movement speed by $s3% for $s4 sec
    shadow_hounds                  = {  94983,  430707, 1 }, -- Each time Black Arrow deals damage, you have a small chance to manifest a Dark Hound that charges to your target and attacks nearby enemies for $s1 sec
    smoke_screen                   = {  94959,  430709, 1 }, -- Exhilaration grants you $s1 sec of Survival of the Fittest. Survival of the Fittest activates Exhilaration at $s2% effectiveness
    soul_drinker                   = {  94983,  469638, 1 }, -- Black Arrow damage increased by $s1%. Bleak Powder damage increased by $s2%
    the_bell_tolls                 = {  94968,  467644, 1 }, -- Firing a Black Arrow increases all damage dealt by $s1% for $s2 sec. Multiple instances of this effect may overlap
    umbral_reach                   = {  94982, 1235397, 1 }, -- Black Arrow periodic damage increased by $s1% and Bleak Powder now applies Black Arrow's periodic effect to all enemies it damages. If Bleak Powder damages $s2 or more enemies, gain Trick Shots if talented
    withering_fire                 = {  94993,  466990, 1 }, -- While Trueshot is active, you surrender to darkness, granting you Withering Fire and Deathblow.  Withering Fire Casting Black Arrow fires a barrage of $s3 additional Black Arrows at nearby targets at $s4% effectiveness, prioritizing enemies that aren't affected by Black Arrow's damage over time effect

    -- Sentinel
    catch_out                      = {  94990,  451516, 1 }, -- When a target affected by Sentinel deals damage to you, they are rooted for $s1 sec. May only occur every $s2 min per target
    crescent_steel                 = {  94980,  451530, 1 }, -- Targets you damage below $s1% health gain a stack of Sentinel every $s2 sec
    dont_look_back                 = {  94989,  450373, 1 }, -- Each time Sentinel deals damage to an enemy you gain an absorb shield equal to $s1% of your maximum health, up to $s2%
    extrapolated_shots             = {  94973,  450374, 1 }, -- When you apply Sentinel to a target not affected by Sentinel, you apply $s1 additional stack
    eyes_closed                    = {  94970,  450381, 1 }, -- For $s1 sec after activating Trueshot, all abilities are guaranteed to apply Sentinel
    invigorating_pulse             = {  94971,  450379, 1 }, -- Each time Sentinel deals damage to an enemy it has an up to $s1% chance to generate $s2 Focus. Chances decrease with each additional Sentinel currently imploding applied to enemies
    lunar_storm                    = {  94978,  450385, 1 }, -- Every $s3 sec, the cooldown of Rapid Fire is reset and your next cast of Rapid Fire also fires a celestial arrow that conjures a $s4 yd radius Lunar Storm at the target's location, dealing $s$s5 Arcane damage. For the next $s6 sec, a random enemy affected by Sentinel within your Lunar Storm gets struck for $s$s7 Arcane damage every $s8 sec. Any target struck by this effect takes $s9% increased damage from you for $s10 sec
    overwatch                      = {  94980,  450384, 1 }, -- All Sentinel debuffs implode when a target affected by more than $s1 stacks of your Sentinel falls below $s2% health. This effect can only occur once every $s3 sec per target
    release_and_reload             = {  94958,  450376, 1 }, -- When you apply Sentinel on a target, you have a $s1% chance to apply a second stack
    sentinel                       = {  94976,  450369, 1 }, -- Your attacks have a chance to apply Sentinel on the target, stacking up to $s2 times. While Sentinel stacks are higher than $s3, applying Sentinel has a chance to trigger an implosion, causing a stack to be consumed on the target every sec to deal $s$s4 Arcane damage
    sentinel_precision             = {  94981,  450375, 1 }, -- Aimed Shot and Rapid Fire deal $s1% increased damage
    sentinel_watch                 = {  94970,  451546, 1 }, -- Whenever a Sentinel deals damage, the cooldown of Trueshot is reduced by $s1 sec, up to $s2 sec
    sideline                       = {  94990,  450378, 1 }, -- When Sentinel starts dealing damage, the target is snared by $s1% for $s2 sec
    symphonic_arsenal              = {  94965,  450383, 1 }, -- Multi-Shot discharges arcane energy from all targets affected by your Sentinel, dealing $s$s2 Arcane damage to up to $s3 targets within $s4 yds of your Sentinel targets
} )

-- Auras
spec:RegisterAuras( {
    a_murder_of_crows = {
        id = 131894,
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
        duration = 14,
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
        max_stack = function() return 15 + 5 * talent.incendiary_ammunition.rank end
    },
    -- Talent: Critical strike chance increased by $s1%.
    -- https://wowhead.com/beta/spell=204090
    bullseye = {
        id = 204090,
        duration = 6,
        max_stack = 30
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
    lunar_storm_cooldown = {
        id = 451803,
        duration = 30,
        max_stack = 1,
        onRemove = function()
            applyBuff( "lunar_storm_ready" )
        end,
        -- This is a player debuff, use generate to create the buff version in order to align with SimulationCraft
        generate = function( t )
            local src = auras.player.debuff.lunar_storm_cooldown
            if src and src.expires > now then
                t.applied = src.applied
                t.duration = src.duration
                t.expires = src.expires
            return
            end
        end
    },
    lunar_storm_ready = {
        id = 451805,
        duration = 3600,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=269576
    master_marksman = {
        id = 269576,
        duration = 6,
        max_stack = 1,
    },
    -- Talent: Threat redirected from Hunter.
    -- https://wowhead.com/beta/spell=34477
    misdirection = {
        id = 34477,
        duration = 30,
        max_stack = 1
    },
    --
    moving_target = {
        id = 474293,
        duration = 15,
        max_stack = 1
    },
    -- Damage taken reduced by $w1%
    no_hard_feelings = {
        id = 459547,
        duration = 5.0,
        max_stack = 1,
    },
    on_target = {
        id = 474257,
        duration = 10,
        max_stack = 4
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
    precise_shots = {
        id = 260242,
        duration = 15,
        max_stack = function() return 1 + talent.windrunner_quiver.rank end,
        copy = { "precise_shot" } -- just incase simc uses it
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
            return ( 2 * haste ) / ( action.rapid_fire.shots )
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
    -- https://www.wowhead.com/spell=466872
    spotters_mark = {
        id = 466872,
        duration = 12,
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
        max_stack = 1,
        -- Focus cost
        streamlineCostMultiplier = function() return 1 - ( buff.streamline.stack * 0.2 * ( talent.tensile_bowstring.enabled and buff.trueshot.up and 1.5 or 1 ) ) end,
        -- Cast speed reduction
        streamlineCastMultiplier = function() return 1 - ( buff.streamline.stack * ( 0.2 + 0.1 * talent.improved_streamline.rank ) * ( talent.tensile_bowstring.enabled and buff.trueshot.up and 1.5 or 1 ) ) end
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
    -- Talent: Raining arrows down in the target area.
    -- https://wowhead.com/beta/spell=260243
    volley = {
        id = 260243,
        duration = 6,
        tick_time = 0.5,
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

spec:RegisterStateExpr( "trick_shots", function ()
    -- Internal Expression to return target count for spells that interact with Trick Shots
    if buff.trick_shots.up or buff.volley.up then
        return min( 6 + ( 2 * talent.light_ammo.rank ), active_enemies )
    elseif talent.aspect_of_the_hydra.enabled then
        min ( 2, active_enemies )
    else return 1 end

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

spec:RegisterGear( {
    -- The War Within
    tww3 = {
        items = { 237644, 237645, 237646, 237647, 237649 },
        auras = {
            -- Dark Ranger
            blighted_quiver = {
                id = 1236975,
                duration = 3600,
                max_stack = 10
            },
            -- Sentinel
            boon_of_elune_consumable = {
                id = 1236644,
                duration = 20,
                max_stack = 2
            },
            boon_of_elune_storm = {
                id = 1249464,
                duration = 12,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229271, 229269, 229274, 229272, 229270 },
        auras = {
            -- 2-set
            -- https://www.wowhead.com/spell=1218033
            -- Jackpot! Auto shot damage increased by 200% and the time between auto shots is reduced by 0.5 sec.
            jackpot = {
                id = 1218033,
                duration = 10,
                max_stack = 1
            }
        }
    },
    tww1 = {
        items = { 212018, 212019, 212020, 212021, 212023 }
    },
    -- Dragonflight
    tier31 = {
        items = { 207216, 207217, 207218, 207219, 207221, 217183, 217185, 217181, 217182, 217184 }
    },
    tier30 = {
        items = { 202482, 202480, 202479, 202478, 202477 }
    },
    tier29 = {
        items = { 200390, 200392, 200387, 200389, 200391 },
        auras = {
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
        }
    }
} )

local SpottersMarkConsumer = setfenv( function ( max_targets )

    local markConsumptions = 0
    local trueshotCDR = talent.unerring_vision.enabled and 3 or 2

    if max_targets >= active_enemies then
        -- Case where all consumptions are guaranteed
        markConsumptions = min( active_enemies, active_dot.spotters_mark )
    else
        -- Case where not all targets can be hit, ONLY apply CDR based on what we can guarantee
        local guaranteedHits = min( max_targets, active_dot.spotters_mark )
        local overflowTargets = active_enemies - max_targets
        markConsumptions = max( 0, guaranteedHits - overflowTargets )
    end

    removeDebuff( "target", "spotters_mark" )
    active_dot.spotters_mark = max( 0, active_dot.spotters_mark - ( markConsumptions - 1 ) )
    if talent.calling_the_shots.enabled then reduceCooldown( "trueshot", trueshotCDR * markConsumptions ) end
    if talent.target_acquisition.enabled then reduceCooldown( "aimed_shot", 2 * markConsumptions ) end
    if talent.on_target.enabled then addStack( "on_target", nil, markConsumptions ) end
    setCooldown( "global_cooldown", ( cooldown.global_cooldown.remains / 2 ) )

end, state )

local tensileTrueshotExtension = 0

local PreciseShotsConsumer = setfenv( function ()

    local count = buff.precise_shots.stack

    if set_bonus.tww1 >= 4 or talent.moving_target.enabled then
        applyBuff( "moving_target" )
        addStack( "streamline", nil, count )
    end

    if talent.magnetic_gunpowder.enabled then reduceCooldown( "explosive_shot", 2 * count ) end

    if talent.focused_aim.enabled then reduceCooldown( "aimed_shot", 0.75 * count ) end

    if talent.tensile_bowstring.enabled and tensileTrueshotExtension < 5 then

        if tensileTrueshotExtension == 4 then
            -- If consuming 2 stacks @ 4, it still caps at 5. Don't roll over to 6
            buff.trueshot.expires = buff.trueshot.expires + 1
        else
            buff.trueshot.expires = buff.trueshot.expires + count
        end

        tensileTrueshotExtension = tensileTrueshotExtension + count
    end

    removeBuff( "precise_shots" )
end, state )

local LunarStormCycle = setfenv( function()
    applyBuff( "lunar_storm_ready" )
    setCooldown( "rapid_fire", 0 )
end, state )

spec:RegisterHook( "reset_precast", function ()

    if buff.lunar_storm_cooldown.up then
        state:QueueAuraEvent( "lunar_storm_cooldown", LunarStormCycle, buff.lunar_storm_cooldown.expires, "AURA_EXPIRATION" )
    end

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

    -- FIXME
    -- This is still happening, but works better at further distances. It might be good practice to slow the projectile in general.
    -- Ensure that multishot recommendation doesn't flicker while black arrow is in flight, which was happening when only using the impact() function of the spell
    if ( action.black_arrow.in_flight or prev_gcd[1].black_arrow and action.black_arrow.time_since <= 2 ) and talent.umbral_reach.enabled and active_enemies > 1 and talent.trick_shots.enabled then
        applyBuff( "trick_shots" )
    end

end )

-- Abilities
spec:RegisterAbilities( {
    -- Trait: A powerful aimed shot that deals $s1 Physical damage$?s260240[ and causes your next 1-$260242u ][]$?s342049&s260240[Chimaera Shots]?s260240[Arcane Shots][]$?s260240[ or Multi-Shots to deal $260242s1% more damage][].$?s260228[    Aimed Shot deals $393952s1% bonus damage to targets who are above $260228s1% health.][]$?s378888[    Aimed Shot also fires a Serpent Sting at the primary target.][]
    aimed_shot = {
        id = 19434,
        cast = function ()
            if buff.lock_and_load.up then return 0 end
            return 3 * haste * ( spec.auras.streamline.streamlineCastMultiplier )
        end,
        charges = 2,
        cooldown = function () return haste * 12 * ( buff.trueshot.up and 0.4 or 1 ) - ( 1 * talent.ammo_conservation.rank ) end,
        recharge = function () return haste * 12 * ( buff.trueshot.up and 0.4 or 1 ) - ( 1 * talent.ammo_conservation.rank ) end,
        gcd = "spell",
        school = function() if set_bonus.tww3>=2 and buff.boon_of_elune_consumable.up or set_bonus.tww3>=4 and buff.boon_of_elune_storm.up then return "arcane"
        else return "physical" end end,

        cycle_to = true,
        cycle = "spotters_mark",

        max_targets = trick_shots,

        spend = function ()
            if buff.lock_and_load.up or buff.secrets_of_the_unblinking_vigil.up then return 0 end
            return 35 * ( spec.auras.streamline.streamlineCostMultiplier * ( legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) )
        end,
        spendType = "focus",

        talent = "aimed_shot",
        texture = 135130,
        startsCombat = true,
        indicator = function() if settings.trueshot_rapid_fire and buff.trueshot.up and talent.surging_shots.enabled then return spec.abilities.rapid_fire.texture end end,

        usable = function ()
            if action.aimed_shot.cast > 0 and moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
            return true
        end,
        -- Yes it really is 100, it's very fast
        velocity = 100,

        handler = function ()
            -- Simple buffs
            removeBuff ( "moving_target" )
            if set_bonus.tww2 >= 2 then removeStack( "boon_of_elune_consumable" ) end
            if talent.precise_shots.enabled then addStack( "precise_shots", nil, 1 + talent.windrunner_quiver.rank ) end

            if buff.lock_and_load.up then
                if talent.magnetic_gunpowder.enabled then reduceCooldown( "explosive_shot", 8 ) end
                if set_bonus.tww2 >= 4 then spec.abilities.explosive_shot.handler() end
                removeBuff( "lock_and_load" ) -- prevent infinite buffs by removing this after
            else
                removeBuff( "streamline" )
            end

            if buff.double_tap.up then
                removeBuff( "double_tap" )
                spec.abilities.aimed_shot.handler()
            end

            -- Trick Shots
            if buff.trick_shots.up and buff.volley.down then
                removeBuff( "trick_shots" )
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

        impact = function()
            if debuff.spotters_mark.up then SpottersMarkConsumer( action.aimed_shot.max_targets ) end
            if debuff.explosive_shot.up and talent.precision_detonation.enabled then removeDebuff( "target", "explosive_shot" ) end
            if talent.bullet_hell.enabled then reduceCooldown( "volley", 0.5 * action.aimed_shot.max_targets ) end
        end,
    },

    -- A quick shot that causes $sw2 Arcane damage.$?s260393[    Arcane Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    arcane_shot = {
        id = 185358,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",
        max_targets = function() if talent.aspect_of_the_hydra.enabled then return min ( 2, active_enemies )
        else return 1 end end,

        spend = function () return  40  * ( buff.precise_shots.up and 0.6 or 1 ) * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) end,
        spendType = "focus",

        startsCombat = true,
        cycle = "spotters_mark",

        -- notalent = "chimaera_shot",

        handler = function ()

            if buff.precise_shots.up then PreciseShotsConsumer() end

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
    --[[chimaera_shot = {
        id = 342049,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 40 * ( buff.precise_shots.up and 0.3 or 1 ) * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) end,
        spendType = "focus",

        talent = "chimaera_shot",
        startsCombat = true,

        handler = function ()
            if buff.precise_shots.up then PreciseShotsConsumer() end

            -- Legacy / PvP stuff
            if set_bonus.tier29_4pc > 0 then
                removeBuff( "focusing_aim" )
            end

        end,
    },--]]

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

    -- Changes your viewpoint to the targeted location for $d. Only usable outdoors.
    eagle_eye = {
        id = 6197,
        cast = 60,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        startsCombat = false,

        start = function ()
            applyBuff( "eagle_eye" )
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
            -- It does technically trigger the explosion, but we just need to model the debuff presence
            applyDebuff( "target", "explosive_shot", debuff.explosive_shot.remains + spec.auras.explosive_shot.duration )
            if talent.precision_detonation.enabled then addStack( "streamline" ) end
            if talent.shrapnel_shot.enabled then applyBuff( "lock_and_load" ) end
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

    -- Your Spotting Eagle descends from the skies, stunning your target for 5 sec. Targets stunned by Intimidation deal 10% less damage to you for 8 sec after the effect ends. This ability does not require line of sight.
    intimidation = {
        id = 474421,
        cast = 0,
        cooldown = function() return 60 - ( 10* talent.territorial_instincts.rank ) end,
        gcd = "spell",

        talent = "intimidation",
        startsCombat = true,
        texture = 1392564,


        handler = function ()
            applyDebuff( "target", "intimidation" )
        end,
    },

    -- Fire a Black Arrow into your target, dealing $o1 Shadow damage over $d.; Each time Black Arrow deals damage, you have a $s2% chance to generate a charge of $?a137015[Barbed Shot]?a137016[Aimed Shot and reduce its cast time by $439659s2%][Barbed Shot or Aimed Shot].
    black_arrow = {
        id = 466930,
        cast = 0.0,
        cooldown = function() return 10 - ( 2 * talent.deadeye.rank ) end,
        charges = function() if talent.deadeye.enabled then return 2 end end,
        recharge = function() if talent.deadeye.enabled then return 8 end end,
        gcd = "spell",
        school = "shadow",

        spend = 10,
        spendType = 'focus',

        talent = "black_arrow",
        startsCombat = true,
        -- Purposefully slowing this projectile to try and smooth recommendations. value is 80 in simc.
        velocity = 80,

        cycle = "black_arrow",

        usable = function () return buff.deathblow.up or target.health_pct < 20 or target.health_pct > 80, "Requires deathblow, or target health either below 20% or above 80%" end,
        handler = function ()
            spec.abilities.kill_shot.handler()
        end,

        impact = function()
            applyDebuff( "target", "black_arrow" )
            if talent.umbral_reach.enabled and active_enemies > 1 then
                active_dot.black_arrow = min( active_dot.black_arrow + 1, true_active_enemies )
                if talent.trick_shots.enabled then applyBuff( "trick_shots" ) end
            end
        end,

        bind = "kill_shot"
    },


        -- Talent: You attempt to finish off a wounded target, dealing $s1 Physical damage. Only usable on enemies with less than $s2% health.$?s343248[    Kill Shot deals $343248s1% increased critical damage.][]
    kill_shot = {
        id = 53351,
        cast = 0,
        cooldown = function() return 10 - ( 2 * talent.deadeye.rank ) end,
        charges = function() if talent.deadeye.enabled then return 2 end end,
        recharge = function() if talent.deadeye.enabled then return 10 end end,
        gcd = "spell",
        school = "physical",

        spend = function () return buff.flayers_mark.up and 0 or 10 end,
        spendType = "focus",

        cycle = "spotters_mark",
        talent = "kill_shot",
        notalent = "black_arrow",
        startsCombat = true,

        usable = function () return buff.deathblow.up or target.health_pct < 20, "Requires deathblow, or target health below 20 percent" end,

        handler = function ()

            removeBuff( "deathblow" )
            if buff.razor_fragments.up then
                removeBuff( "razor_fragments" )
                applyDebuff( "target", "razor_fragments_bleed" )
            end

            if talent.headshot.enabled and buff.precise_shots.up then PreciseShotsConsumer() end

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

    -- Your pet removes all root and movement impairing effects from itself and a friendly target, and grants immunity to all such effects for 4 sec.
    masters_call = {
        id = 272682,
        cast = 0,
        cooldown = function() return pvptalent.kindred_beasts.enabled and 22.5 or 45 end,
        gcd = "spell",

        startsCombat = false,
        texture = off,
        talent = "cunning",

        handler = function ()
            applyBuff( "masters_call" )
        end,

        copy = 53271, -- Pet's version.

        auras = {
            masters_call = {
                id = 62305,
                duration = 4,
                max_stack = 1
            }
        }
    },

    -- Talent: Fires several missiles, hitting your current target and all enemies within $A1 yards for $s1 Physical damage. Deals reduced damage beyond $2643s1 targets.$?s260393[    Multi-Shot has a $260393h% chance to reduce the cooldown of Rapid Fire by ${$260393m1/10}.1 sec.][]
    multishot = {
        id = 257620,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function () return 30 * ( buff.precise_shots.up and 0.6 or 1 ) * ( buff.trueshot.up and legendary.eagletalons_true_focus.enabled and 0.75 or 1 ) end,
        spendType = "focus",

        cycle = "spotters_mark",
        startsCombat = true,

        handler = function ()

            if buff.precise_shots.up then PreciseShotsConsumer() end
            if talent.trick_shots.enabled and active_enemies > 2 then applyBuff( "trick_shots" ) end
            if talent.bullet_hell.enabled then reduceCooldown( "rapid_fire", 0.3 * active_enemies ) end

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
        cooldown = function() return 20 * ( buff.trueshot.up and 0.4 or 1 ) end,
        gcd = "spell",
        school = "physical",

        max_targets = trick_shots,
        shots = function() return ( 7 + 3 * talent.ammo_conservation.rank ) * ( buff.double_tap.up and 1.8 or 1 ) end,

        talent = "rapid_fire",
        startsCombat = true,
        texture = 461115,

        toggle = function ()
            if buff.lunar_storm_ready.up then
                local dyn = state.settings.lunar_toggle
                if dyn == "none" then return "none" end
                if dyn == "default" then return nil end  -- let the base toggle apply
                return dyn
            end
            return "none"
        end,

        start = function ()
            if talent.bulletstorm.enabled then
                addStack( "bulletstorm", nil, action.rapid_fire.max_targets * action.rapid_fire.shots )
            end
            if talent.lunar_storm.enabled and buff.lunar_storm_ready.up then
                removeBuff( "lunar_storm_ready" )
                applyDebuff( "player", "lunar_storm_cooldown" )
                applyDebuff( "target", "lunar_storm" )
            end
            if talent.streamline.enabled then addStack( "streamline" ) end
            if talent.no_scope.enabled then addStack( "precise_shots" ) end
            -- Legacy / PvP stuff
            if conduit.brutal_projectiles.enabled then removeBuff( "brutal_projectiles" ) end
            if set_bonus.tier31_2pc > 0 then applyBuff( "volley", 2 * haste ) end
            removeBuff( "double_tap" )
        end,

        finish = function ()
            if buff.volley.down then
                if buff.trick_shots.up then
                    removeBuff( "trick_shots" )
                end
            end
            if talent.in_the_rhythm.up then applyBuff( "in_the_rhythm" ) end
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

        spend = -20,
        spendType = "focus",

        startsCombat = true,
        texture = 132213,

        handler = function ()
            if debuff.concussive_shot.up then debuff.concussive_shot.expires = debuff.concussive_shot.expires + 3 end
            reduceCooldown( "aimed_shot", 2 )
        end,
    },

    -- Talent: Reduces the cooldown of your Aimed Shot and Rapid Fire by ${100*(1-(100/(100+$m1)))}%, and causes Aimed Shot to cast $s4% faster for $d.    While Trueshot is active, you generate $s5% additional Focus$?s386878[ and you gain $386877s1% critical strike chance and $386877s2% increased critical damage dealt every $386876t1 sec, stacking up to $386877u times.][].$?s260404[    Every $260404s2 Focus spent reduces the cooldown of Trueshot by ${$260404m1/1000}.1 sec.][]
    trueshot = {
        id = 288613,
        cast = 0,
        cooldown = function() return 120 - ( talent.calling_the_shots.enabled and 30 or 0 ) - ( set_bonus.tww3_dark_ranger >=2 and 30 or 0 ) end,
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
            tensileTrueshotExtension = 0
            focus.regen = focus.regen * 1.5
            reduceCooldown( "aimed_shot", cooldown.aimed_shot.remains * 0.6 )
            reduceCooldown( "rapid_fire", cooldown.rapid_fire.remains * 0.6 )
            applyBuff( "trueshot" )

            if talent.withering_fire.enabled then
                applyBuff ( "withering_fire" )
                applyBuff( "deathblow" )
                gainCharges( "black_arrow", 1 )
                if set_bonus.tww2 >= 4 then
                    removeBuff( "blighted_quiver" )
                end
            end
            if talent.feathered_frenzy.enabled then applyDebuff( "target", "spotters_mark" ) end

        end,

        --[[meta = {
            duration_guess = function( t )
                return ( t.duration - ( 15 * talent.sentinel_watch.rank) - ( 15 * talent.calling_the_shots.rank ) )
            end,
        }--]]
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
            if talent.double_tap.enabled then applyBuff( "double_tap" ) end

            -- There are weird situations where it doesn't do the below .. but this is usually what happens
            if talent.salvo.enabled then
                if active_enemies < 3 then
                    spec.abilities.explosive_shot.handler()
                    if active_enemies > 1 then active_dot.explosive_shot = min( true_active_enemies, active_dot.explosive_shot + 1 ) end
                else
                   active_dot.explosive_shot = min( true_active_enemies, active_dot.explosive_shot + 2 )
                end
                if talent.shrapnel_shot.enabled then
                    applyBuff( "lock_and_load" )
                end
            end

            if pvptalent.rangers_finesse.enabled then
                if buff.rangers_finesse.stack == 3 then
                    removeBuff( "rangers_finesse" )
                    reduceCooldown( "aspect_of_the_turtle", 20 )
                end
            end
        end,

        tick = function()
            if talent.bullet_hell.enabled then reduceCooldown( "rapid_fire", 0.3 * active_enemies ) end
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

    potion = "tempered_potion",

    package = "Marksmanship",
} )

local beastMastery = class.specs[ 253 ]

spec:RegisterSetting( "pet_healing", 0, {
    name = strformat( "%s Below Health %%", Hekili:GetSpellLinkWithTexture( beastMastery.abilities.mend_pet.id ) ),
    desc = strformat( "If set above zero, %s may be recommended when your pet falls below this health percentage.\n\n"
        .. "Setting to |cFFFFD1000|r disables this feature.",
        Hekili:GetSpellLinkWithTexture( beastMastery.abilities.mend_pet.id )
    ),
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
    name = strformat( "|T135130:0|t %s Icon in %s", Hekili:GetSpellLinkWithTexture( spec.abilities.rapid_fire.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.trueshot.id ) ),
    desc = strformat( "If checked, when %s is recommended during %s, a %s indicator will also be shown.\n\n"
        .. "This icon means that you should attempt to queue %s during the cast, in case %s's cooldown is reset by %s.\n\n"
        .. "Otherwise, follow the next recommendation.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.aimed_shot.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.trueshot.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.rapid_fire.id ),
        spec.abilities.rapid_fire.name,
        spec.abilities.rapid_fire.name,
        -- Hekili:GetSpellLinkWithTexture( spec.talents.improved_deathblow[ 2 ] ), -- no longer resets Rapid Fire?
        Hekili:GetSpellLinkWithTexture( spec.talents.surging_shots[ 2 ] ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "lunar_toggle", "none", {
    name = strformat( "|T461115:0|t %s: Special Toggle", Hekili:GetSpellLinkWithTexture( spec.talents.lunar_storm[2] ) ),
    desc = strformat(
        "When %s is talented and is not on cooldown, %s will only be recommended if the selected toggle is active.\n\n" ..
        "This setting will be ignored if you have set %s's toggle in |cFFFFD100Abilities and Items|r.\n\n" ..
        "Select |cFFFFD100Do Not Override|r to disable this feature.",
        Hekili:GetSpellLinkWithTexture( spec.talents.lunar_storm[2] ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.rapid_fire.id ),
        spec.abilities.rapid_fire.name
    ),
    type = "select",
    width = 2,
    values = function ()
        local toggles = {
            none       = "Do Not Override",
            default    = "Default |cffffd100(" .. ( spec.abilities.rapid_fire.toggle or "none" ) .. ")|r",
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

spec:RegisterSetting( "prevent_hardcasts", false, {
    name = "Prevent Hardcasts While Moving",
    desc = strformat( "If checked, the addon will not recommend %s when moving and hardcasting.", Hekili:GetSpellLinkWithTexture( spec.abilities.aimed_shot.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Marksmanship", 20250909, [[Hekili:T31EVnoos(plblg12xs7y7KmDsVX5WSZCl2TXC9D7M5W(hhUitBrhRRLL8OhjThy4p7xvKusKsKusokz7BXcm9K0wuSEWI)QhSO7hM8WV8W9EKu6dFE64Pxn(MX3mA8nxCZLF4H7t3TL(W9Bjl)c5r4xcjBG)))oj(ljBiHjR93IpCxqeXdNKKOS4LWawNMUn5JNF(J(PRZwmAz0MZt83Kfqs9JcxgtwLI)9LNViiAX5PRPptIFggQF45)WsCi)NX(rX(P7(z)K0KZ9ORizbPNVolmLg7UrI6JWP5H7xK5hK(NdFyHw54cqoizPRJIF4(7938Ja)575r5dNMaVpo83p(g4)(4H53VlC5H5i)a)om8dFQ4XFWYJV(9tVwZJF4(auiyQ44LbuYtu43)mtNtdjlcOEp8ha(Jj3Wh91Tbrj(prDtwhLY5Vy)T8ho9W8us8J00KdZhm9uozIYspm)xI9x(fGGW7Km8W8dZ)BCgyDmzBinG)KdZ9IcFh8JFnJMrpm)FlNw5pgwxOXanwdFY2y6ssc8Hj(HlPIp8hs2sxcFw0kXh8N25ftGXqxgf6rI3bdXFd1lFcF2paOn8SKSn5ZXphHCkj0d)vI3OhUheqGU(eCDC1QrPXzuu4h5f9C4H5oOqhqdthHSKFcOjC9OPrHmJPrcDiBCdom)KIrNiKDMISCy73FyoJmbaF4cSHlA8wsRLrrb4Fzebfe(lVCnQ1tCxfZxMiGqD7SdZNmAYH5dFifS3QSCwrK4CoFnnzu2woBuYRRPepz2S0EyrabzZ44ONr6CHr6iMPfzbbG9rAu8gfvdJnKFyHapOGliSvx3OvUWcL7ACPvvVvYWpfbZ0o1NwO5epmMUH4hMGAOcXbws89Cx5htrP5s7AnVOm4jUPKTkCBjxinG6RVQ6C(emStMjsdIe8uulTHKKwUIaL0RmkPprGFaFCHzVBmymSRCrRrTWXUwKtqK)((M5pKza0xpkjDnGB)CjhQSHTC(tsrbXnNeFW(IDXKG7oCSSgAq5l)ABIEYp8rxowj8KsEQCtnYsx3j7ptwX3019(8fqpk7XjBJsHHNWCRvvevfKA2xK4LKqAH4mzCx4KssPLtog95KQE1kzGwTHZWEkJEhrsYqE1zYjXh4iVpbiEk6MKj(68bxdm1aRQ1UV8J7hhl2e6g820iIXBdMNzFvcThSwiSflGNU7WC6xPlZsb23hdzqXbvhDUvYYzHKyx2JClwgQX5T13KbF2Y2fLsM82OyYVffJR1pUbMGeliDYBX(cedvXkFv)i5dcITo1NB2BrnxrTyczYi0JrWIcD5YDlzwESGuXDyTZ3sl99P33vJow0BNHr3QyK9Q7gsf7UlEIAZELJ09u3up9Mlel6cUBmtjejJQBZHZQOLzGKCQqsIPpsbE92dZzpy0gYxngPIQpfPTwv8O4fB3FsRYP7ItLtQJN3Os2CAGEAmridUNARtaBUXg0zpz85uqvM2hEj4vlP5W2Lf1))ZVw5geZ56zbq2yAGnK4uBGlyAVJXVQjCM(lfNVDtr5T0vAD8NJ3pX3u(6oshswIlmmYnzz0wQ6wQJX42saHnLDv309VjosFPj486Njt3sFljTpsBRFKQgXw6X02IjGDi9jwn688sgr)kwszUbt1N5hYS64Crr2oD2vMqvkL5KgfPP0Q6EovD1frDF)A3MxaCj)0k7zK9Xy2hwJj917L5P54gYjD98knK9OzxOV6(dmHrz2L7jnaVBG7mz71GNZEF5tsGvRs3nYiEs8yLmB(gUwETklKcTtRHhBVVaXbcw4mi)DwgXpHW6V0NvM70ys4VM5h4)BOQqZORIlgTfDaLkbHkWRWFliJkBTIqnj0DvSwx5)4AeuRmUa5ePk1rzXm9ilX1jJlGbkaXyZmjfwx)kG8cjfiCdSikjHTixHqqcVtVQskN)efusB8dHis8xb)jf(dmuYH5pgfb8lpyL0OdZHu1WSrfm3H5)vWzdejg6T5W8iy624)Bc(nL8fAcESH8tU9W8e27tEKYN9eYtOUyvu8H5SqA3gqLY8La)jik8r(VHS0Z8ZQ0JgqGzl6j8KjxtcymmmKCnfWv)hPRPXp7J8kjGf2pJkjBi4PpYMGeU8eWeAC7aQqbjbYxappti2TWVa8XzIdM851yXcYs8rg6piu7NvWmSZXmGD6OcjS4arzQ)CXK8vGlylsJyMmU8Jpx1hNohJnBVbsCKBAmLoYd2H7cg0pIkiNCp)YrX4h6UkGZxompkIHiLu5ioRiXKOcsoxk7Uh3szoOcsx7UfvOGzh8rU4hb6qPKzOGZc4j68gvSlgw2CfXVGNDo)e0fS1sVeDUnA17MVkB3DWa84Sttb2gRsum6FBxEcfmmt)ex(UTHf6BafZdu08guGd6EyoeN4yrw2S3d3w5MgHki3RhZWaMoUK1LFz7PjjOinKUXNYbtMkiedbsote5Gf0AZGiTW4r83wQgvk7LDxvhlNEsVXSvo1h7o20WUt6xnNObqk821n2OFvls8I58a6j65fNW9XBofG(v4yKd(ymiLOnliTlZXSWfaq4xWba7Xd9YnkLcljBZgGMcimZRHFRGIyELTQvgazFHAHtKCpiV50q(iMcK8YwhvxS(87ZFxRLrFsUcQZbQ(2uwaRglFRK(V2vjf18FH35y3NYZoxPTXu68lmWsiGYFQSuSRjjSa6ibIu7xqzbzTnpWpAyu2JR5bQTaicmSLP4mMgnsBTcQgIIbDV6YyXJeHiRl8RxyDjorIC1IX6Fw5cZD3M56tOTK1iv4ZKo18WVnQHHjgSCYABDk6QTOEdLo1TsVg1vOtf2OxSgDut2wDPOmHCXkLe43i1ZCqY7npxNr556CTIlA5hYCpBTPTAmOKoxoBJUmt7srwWmTSgZK(nKwkebeMz5oFynKg)fm5WMDnwJigrZzk8lg3mR89YGqrrW(VS42D6UVMScjCjfI2Le4Ib4A310Re7Ctj3GqsmLJDhm2QYhRSdjU)VzESAtBhKVUe5uEGzmgjilPuu1VvCQurZmlLxiLlbGOG)Kz0xuIalXHkgZKk(NoPOmsJsNmcI2XndGX41zQEXqLxvMCrBw7U8QCWmvk5dOKH78PbEi2xiflg22y)KnW27amN3sgwZoTkc1ulc103mHAA7fQP2IJ10uuXKlGKc2MyMqXpUBeRGDmM7kfdqRsP55btl46gThNEfZhbp)vdSDXXGA(wK09uFeo9mwTWAsFPl3Ya8E2p0loleKB3Fnd82el1Ap2Cgzn9zXCRRh)ng8TkBz9(mmur8SgHO1JCVdhMAh7eHQ5jy92oi9WC8XwQikZzQn9DXlsTPYvvV3chrR4Ax5C8mApEhog0oB1AkdLxw7jTxxJAYcPTKPJAPwVCkN)Hz3)VOwo4LkhgVWmowDH1AvGQfTPJVO806)Mob(ssRR1d01d4vZQnxGn336VccLtlXe1lcvtCwx(CV6cHEwRwo1As9wtXu6TC9Z1URaFya0hV8Ochg3weJr5wGk5vFQMMK7OlpgBcAkUedQX2C9LAp7icaKvy4X5PS0STNEeJAhxK9L4(D91G66c5sjyUtwA8M007nsYvTSghWhagfiLlUX4F4H7FMehINBZd3)l4j67VzBuC(r6)U8eeFhwFAWOkgzXKi0WLKLgTHWQynSdi8rAYOdF6NzDCWKpEy(pgfceJ948zzKAEIVJx773zins4XdM81HTysnM9KgkyBSkKBQbYn1Umu7XTCsBVmyFScYD4t)z26isfC3i36a7iKKuCDcStG9KGzWvxIhAy0kFSzl(D)UdZ)V2MKcHZTb4032Vwdo8jK83xqGFejaQU2Sb7pg8lAaGNwUAY1J)(f8b)tG53hXAGK)1zak4CrnzuXrHE6SZlpgZZ8xnZWPFQ)vLpHr8Lhu7Co3Vx9moh6GZJMt3C2yhTNQ5DthRN2LGDiLfZQ4emV9cKUvp5sNkHWyqDuIriPXGhi3rzYFE9oidwaWJ7k9F2zvzVTDwL8YsEIyNHfszMA2yNX6CQzNi5hhP9(9kvJ5UbMBkVtNmE4(9f(5R3kEWdbZDhLj82PxX3B(FF)Uy)v)phM)(dZ)Ce)Z(JOW8tzGVIOW)AeereOjwdKV00auBPcfaf1FO6yls8r8zOLYE02zW2u)vNHFpD4JVYmoxMKUdYB1JZcXmwGPNCPG8nZqITcvP0zpJSuEwr3DX497R(m)W7((XMxQqLQ8r5kOG2gcXXsnRCor8W6hiOeTZ7cneerTZ1UvQR1uWbQ0VjCUEPxsZdkFhG8iFRWqRA39Na9jUNKsXyuOSUhDtKN)kF(5SFGDW7jzlEFaS2f8(pmb2Wf7dQRGDnlPYng2z8M2z2K6a13nnhuwQKto6BOXgPPA)D1zQEYrs28o5YgbN8sKP2m9hpZd)M8mFKZdVpRuMjtSKcy1iyFdmP(Hpf9fqE(kylhscyXhYN4TrpdGb(HRYWyZX5vnbGCGMjtRGEF7KlkDWZPs5bnwFEY2QfXwZKuCeH6NeJviIHfQJeFFvsOE0FVAKP4m96jkCtvcu5e)QtgwEOvEj(rWPJLCgW93kD6FfqJLN83TtzEMRZExmHz7XA70IiI(hMV6SmhyrU6nhNA2ZeFyNkD5SXJgFLum)AkfHJU(oWb9Ua(AeUx1EErFQkvHvw1SZ1Bn4yPoaodorh7icdREVp40U(172ztgnzOwowkYHc2TAD82V)eJ5vinvL1ersJlvIiNA1mIjcdmV2usyETML2XQw4A9YgFmfIvLZKOuxx(aHIUEPKgACLP4JXlAVXfk9myUDbYIgc(0XoRFu6fP8)uOC1WsDSbLjnFQ5PwdtZGkvRUkF41Q5AZgC6uu6z3YsyB0K3zGXIwl476fSwVYwJYrNUWqvk7G2Oo2t3WsAYur4APO1JLhFsQwgWgsxpGO1G9jJPAedqF7gRKsNOvJVlN1gYue)9Q5GRjIVGTZoMpSVQu5OXQoXC3bxIJj5vqQMdLh1XWA8tfhxvCqPd05i3vB37xs9c1nOkc4(9I4iQPag27GJm(rfyS5Ie8sxJBqH0)GECI8AHJ7mWw3ZENqDAQZz1fW(1fLTO8dVdIIV9yOQHN2ci8Qqdc47g)cysEokl1WXbVRI101yBh0bxbffdx6BCPHMLLg9k0BX6PqwDbBNw5RzN6WnAdkvD)Gcv0ewKMUD6ozBwN2gTUrI2hqhkt4lWRMX5SO)lSO9naJyaRWagMDZaTXlxFbQOlbCQ5rPxCByMbpglO804Y)6RO84PAYMQ3vuVyxnhbiyRWN7sWTTzJH85Dwwg1oJvlCOP9egguF7vjcvToozOb(PeVDqTCU1clusdnLfyOL15MwpvyRJTIfglCGsFPAvgCA1UQolPvRysZli1LLUsZH1lmh3(3uBCIhJ7cAQOeIKqnJN5WqaMlxHpfHOn(Cgy36sOLedtphuoA51B9ZqRvATDH6vvgLwv(7QqQDFOeJ6yMZ5Bi7kBzOCzMthUTssrlTEMspKnBYz73JNCo2wdUEKnKhPV1zTYNCnFRmRxskJvQvss)X5owqnnWRYzc(gZTM4OYixQYqfvi4LhMIt9wq9wHZCdTF6PsXk16AV4yYDFR2o3oYWAPeiWNXfXn2HLFRk7(rx3OO2hrIj0lgsMrzETefypuiHUeOQ1eWk4NgZ4(4QdBn68cDLOzgBJhydYuRS8RfEkJQLos(M0nHPQ8135O24kCo7xM2PbYQJ)FTkGOvUUDkYEgWQ7hqtZyr6QWO8Zp6eNvlByparzHVAexshBEevcSgHFj1yPXuuZ5itWC2ySMrEK5ZCZV6ag6rPSqyZrCQtbjjM9C16QXyhRhalt5rwzR(gETNnq7Fb(fddAtcvXKSmWk1IMDgdNw(p0g3w8pYgTX6oV9aLRxYFJw0YvjzB53aN01S2DFxyk2(3d2rt)xhQwmKurV2cZoEJt8tPBsoJ9fgqEB4o5JIFzk3xjmLUIpr5IQufSVOLdVWwtYD5vLYBl4fwMpNKQ9YaDSmaMTyZxeOUWMtvzZP9nBA5(7yLn59kQ(xSylLMVtgU7QQyhYmTP3A2KR3RV9(hMB)(d5x(bbZYQLxk)UrKWBMbmBLWGD5)deAEx()7fxie1pDKEJ7zLRtSE42LLyaOaMn2QToED12UL6zqx7yCVG6tkDBkUweF33z(ktmBSJbv9LM0zBj8lvhxxqQPn3qsbXor0sKKfrytyIQy9krE3MWgBekRsZhIMeIJq0Zj4LXOyge9gAJtsEFAUrC9xy3pf2idPFnTXftLTDVrlNmr4OxpnT35stZBrbdnJhmDCdV8TZm(Y8Ep6ZsGgZxd7qXfj2vMkkDNnldSXy9XomY0cx(s8ZG3nA(ToIBSWVJxVlP4gkX(MGS8fvV7sJaR9GK87(f(f1O0TD6WE8lUiEZaNu)wpjm)IP5wTfgIv29izkl9oe8)XVOxxlDXP6vdsf7nJi6wmFgyeWEWKBEVzBYVJDTSurLTDlUMoEyTXpDQfYda)NOAEQ6b0UP7WH29ouGcjzc)7Ba1sAON1iMvmn3eoI56bBFUi826TjcFK04dRyUkD9)0U)HzL1b74(2K7KwAZzgkCG6AN5Pq1CXiy0PwS7Mm28PPaiGgJK6YQpbISVTSZKRQzPprypQGygG34MY7yQnatXD3eViPHyRBYnTGvl8hIBjkBFtXWwW(Eqq15yJyLap2B2jT0mXiYKrKHlmJAC6QGOO4bdu0(VhWES4DD4)IfCleMB4Dt(qbAc)WBkqgkwZy3W2sf7A8A)YcdLY2HQS)KZxSvk8QgZU)VfSqpVBv7UqUqyDJb7lQHh()(d]] )