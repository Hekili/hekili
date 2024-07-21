-- WarlockDestruction.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 267 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.SoulShards )

spec:RegisterTalents( {
    -- Warlock Talents
    abyss_walker                   = { 71954, 389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by $389614s1% for $389614d.
    accrued_vitality               = { 71953, 386613, 2 }, -- Drain Life heals for $s1% of the amount drained over $386614d.
    amplify_curse                  = { 71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within $d is amplified.; $@spellname334275; Reduces the target's movement speed by an additional $s3%.; $@spellname1714; Increases casting time by an additional $<cast>%.; $@spellname702; Enemy is unable to critically strike.
    banish                         = { 71944, 710   , 1 }, -- Banishes an enemy Demon, Aberration$?s386651[, Undead][], or Elemental, preventing any action for $d. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = { 71949, 111400, 1 }, -- Increases your movement speed by $s1%, but also damages you for $s2% of your maximum health every $t2 sec. Movement impairing effects may not reduce you below $s3% of normal movement speed. Lasts $d.
    curses_of_enfeeblement         = { 71951, 386105, 1 }, -- [1714] Forces the target to speak in Demonic, increasing the casting time of all spells by $s1% for $d.$?s103112[; Soulburn: Your Curse of Tongues will affect all enemies in a $104224A yard radius around your target.][]; Curses: A warlock can only have one Curse active per target.
    dark_accord                    = { 71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by ${$s1/-1000} sec.
    dark_pact                      = { 71936, 108416, 1 }, -- Sacrifices $s2% of your current health to shield you for $s3% of the sacrificed health plus an additional $<points> for $d. Usable while suffering from control impairing effects.
    darkfury                       = { 71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by ${$s1/-1000} sec and increases its radius by $s2 yards.
    demon_skin                     = { 71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of ${$s1/10}.1% of maximum health every $t1 sec, and may now absorb up to $s2% of maximum health.; Increases your armor by $m4%.
    demonic_circle                 = { 100941, 268358, 1 }, -- [48018] Summons a Demonic Circle for $d. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects.$?s58081[; If you cast Demonic Circle: Summon while controlling an Eye of Kilrogg, the circle will appear where the eye is located.][]
    demonic_embrace                = { 71930, 288843, 1 }, -- Stamina increased by $s1%.
    demonic_fortitude              = { 71922, 386617, 1 }, -- Increases you and your pets' maximum health by $s1%.
    demonic_gateway                = { 71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per $<GatewayCooldown> sec.
    demonic_inspiration            = { 71928, 386858, 1 }, -- Increases the attack speed of your primary pet by $s1%. $?a137044[][; Increases Grimoire of Sacrifice damage by $s2%.]
    demonic_resilience             = { 71917, 389590, 2 }, -- Reduces the chance you will be critically struck by $s1%. All damage your primary demon takes is reduced by $s3%.
    demonic_tactics                = { 71925, 452894, 1 }, -- Your spells have a $s1% increased chance to deal a critical strike.; You gain $s2% more of the Critical Strike stat from all sources.
    fel_armor                      = { 71950, 386124, 2 }, -- When Soul Leech absorbs damage, $s1% of damage taken is absorbed and spread out over $387847d.; Reduces damage taken by ${$s4/10}.1%.
    fel_domination                 = { 71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by $s1%.; 
    fel_pact                       = { 71932, 386113, 1 }, -- Reduces the cooldown of Fel Domination by ${$s1/-1000} sec.
    fel_synergy                    = { 71924, 389367, 2 }, -- Soul Leech also heals you for $s1% and your pet for $s2% of the absorption it grants.
    fiendish_stride                = { 71948, 386110, 1 }, -- Reduces the damage dealt by Burning Rush by ${$abs($s1)}%. Burning Rush increases your movement speed by an additional $s2%.
    frequent_donor                 = { 71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by ${$s1/-1000} sec.
    horrify                        = { 71916, 56244 , 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear.
    howl_of_terror                 = { 71947, 5484  , 1 }, -- Let loose a terrifying howl, causing $i enemies within $A1 yds to flee in fear, disorienting them for $d. Damage may cancel the effect.
    ichor_of_devils                = { 71937, 386664, 1 }, -- Dark Pact sacrifices only $s3% of your current health for the same shield value.
    lifeblood                      = { 71940, 386646, 2 }, -- When you use a Healthstone, gain $s2% Leech for $386647d.
    mortal_coil                    = { 71947, 6789  , 1 }, -- Horrifies an enemy target into fleeing, incapacitating for $6789d and healing you for $108396m1% of maximum health.
    nightmare                      = { 71916, 386648, 1 }, -- Increases the amount of damage required to break your fear effects by $s1%.
    pact_of_gluttony               = { 71926, 386689, 1 }, -- [452930] Instantly restores $s1% health$?s262031[, plus an additional ${$262080d/$262080t1*$262080s1}% over $262080d.][.]
    resolute_barrier               = { 71915, 389359, 2 }, -- Attacks received that deal at least $s2% of your health decrease Unending Resolve's cooldown by $s3 sec. Cannot occur more than once every ${$proccooldown-$s1/-1000} sec.; 
    sargerei_technique             = { 93179, 405955, 2 }, -- $?c1[Shadow Bolt and Drain Soul damage increased by $s1%.]?c2[Shadow Bolt damage increased by $s1%.][Incinerate damage increased by $s2%.]
    shadowflame                    = { 71941, 384069, 1 }, -- Slows enemies in a $A1 yard cone in front of you by $s1% for $d.
    shadowfury                     = { 71942, 30283 , 1 }, -- Stuns all enemies within $a1 yds for $d.
    socrethars_guile               = { 93178, 405936, 2 }, -- $?c1[Agony damage increased by $s1%.]?c2[Wild Imp damage increased by $s2%.][Immolate damage increased by $s3%.]
    soul_conduit                   = { 71939, 215941, 1 }, -- Every Soul Shard you spend has a $?s137043[$s1%]?s137046[$s3%][$s2%] chance to be refunded.
    soul_link                      = { 71923, 108415, 2 }, -- $s2% of all damage you take is taken by your demon pet instead. $?a137044[][; While Grimoire of Sacrifice is active, your Stamina is increased by $s3%.]
    soulburn                       = { 71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells.; Demonic Circle: Teleport: Increases your movement speed by $387633s1% and makes you immune to snares and roots for $387633d.; Demonic Gateway: Can be cast instantly.; Drain Life: Gain an absorb shield equal to the amount of healing done for $387630d. This shield cannot exceed $387630s1% of your maximum health.; Health Funnel: Restores $387626s1% more health and reduces the damage taken by your pet by ${$abs($387641s1)}% for $387641d.; Healthstone: Increases the healing of your Healthstone by $387626s2% and increases your maximum health by $387636s1% for $387636d.
    strength_of_will               = { 71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional $s1%.
    sweet_souls                    = { 71927, 386620, 1 }, -- Your Healthstone heals you for an additional $s1% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    swift_artifice                 = { 71918, 452902, 1 }, -- Reduces the cast time of Soulstone and Create Healthstone by $s1%.
    teachings_of_the_black_harvest = { 71938, 385881, 1 }, -- Your primary pets gain a bonus effect.; Imp: Successful Singe Magic casts grant the target $386869s1% damage reduction for $386869d.; Voidwalker: Reduces the cooldown of Shadow Bulwark by ${$abs($s2/1000)} sec.; Felhunter: Reduces the cooldown of Devour Magic by ${$abs($s3/1000)} sec.; Sayaad: Reduces the cooldown of Seduction by ${$abs($s4/1000)} sec and causes the target to walk faster towards the demon.$?s137044[; Felguard: Reduces the cooldown of Pursuit by ${$abs($s6/1000)} sec and increases its maximum range by $s7 yards.][]
    teachings_of_the_satyr         = { 71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by ${$s1/-1000} sec.
    wrathful_minion                = { 71946, 386864, 1 }, -- Increases the damage done by your primary pet by $s1%. $?a137044[][; Increases Grimoire of Sacrifice damage by $s2%.]

    -- Destruction Talents
    abyssal_dominion               = { 94831, 429581, 1 }, -- $?s137044[Summon Demonic Tyrant is empowered, dealing $s1% increased damage and increasing the damage of your demons by $s2% while active.][Summon Infernal becomes empowered, dealing $s3% increased damage. When your Summon Infernal ends, it fragments into two smaller Infernals at $s4% effectiveness that lasts $456310d.]
    annihilans_bellow              = { 94836, 429072, 1 }, -- Howl of Terror cooldown is reduced by ${$s1/-1000} sec and range is increased by $s2 yds.
    ashen_remains                  = { 71969, 387252, 1 }, -- Chaos Bolt, Shadowburn, and Incinerate deal $s1% increased damage to targets afflicted by $?a445465[Wither][Immolate].
    aura_of_enfeeblement           = { 94822, 440059, 1 }, -- While Unending Resolve is active, enemies within $449587a1 yds are affected by Curse of Tongues and Curse of Weakness at $s1% effectiveness.
    avatar_of_destruction          = { 101998, 456975, 1 }, -- [434587] Generates $457578s1 Soul Shard Fragment every $457578t1 sec and casts Chaos Bolt at $456975s1% effectiveness at its summoner's target.
    backdraft                      = { 72067, 196406, 1 }, -- Conflagrate reduces the cast time of your next Incinerate, Chaos Bolt, or Soul Fire by $117828s1%. Maximum $?s267115[$s2][$s1] charges.
    backlash                       = { 71983, 387384, 1 }, -- Increases your critical strike chance by $s1%.; Physical attacks against you have a $s2% chance to make your next Incinerate instant cast. This effect can only occur once every $proccooldown sec.
    blackened_soul                 = { 94837, 440043, 1 }, -- Spending Soul Shards on damaging spells will further corrupt enemies affected by your Wither, increasing its stack count by $s1.; Each time Wither gains a stack it has a chance to collapse, consuming a stack every $445731t1 sec to deal $445736s1 Shadowflame damage to its host until 1 stack remains.
    bleakheart_tactics             = { 94854, 440051, 1 }, -- Wither damage increased $s1%. When Wither gains a stack from Blackened Soul, it has a chance to gain an additional stack.
    blistering_atrophy             = { 101996, 456939, 1 }, -- Increases the damage of Shadowburn by $s1%. The critical strike chance of Shadowburn is increased by an additional $s3% when damaging a target that is at or below $s4% health.
    burn_to_ashes                  = { 71964, 387153, 1 }, -- Chaos Bolt and Rain of Fire increase the damage of your next $s3 Incinerates by $s1%. Shadowburn increases the damage of your next Incinerate by $s1%.; Stacks up to $387154U times.
    cataclysm                      = { 71974, 152108, 1 }, -- Calls forth a cataclysm at the target location, dealing $s1 Shadowflame damage to all enemies within $A1 yards and afflicting them with $?a445465[Wither][Immolate].
    channel_demonfire              = { 72064, 196447, 1 }, -- Launches $s1 bolts of felfire over $d at random targets afflicted by your $?a445465[Wither][Immolate] within $196449A1 yds. Each bolt deals $196448s1 Fire damage to the target and $196448s2 Fire damage to nearby enemies.
    chaos_incarnate                = { 71966, 387275, 1 }, -- Chaos Bolt, Rain of Fire, and Shadowburn always gain at least $s1% of the maximum benefit from your Mastery: Chaotic Energies.
    cloven_souls                   = { 94849, 428517, 1 }, -- Enemies damaged by your Overlord have their souls cloven, increasing damage taken by you and your pets by $434424s1% for $434424d.
    conflagrate                    = { 72068, 17962 , 1 }, -- Triggers an explosion on the target, dealing $s1 Fire damage.$?s196406[; Reduces the cast time of your next Incinerate or Chaos Bolt by $117828s1% for $117828d.][]; Generates $245330s1 Soul Shard Fragments.
    conflagration_of_chaos         = { 72061, 387108, 1 }, -- Conflagrate and Shadowburn have a $s1% chance to guarantee your next cast of the ability to critically strike, and increase its damage by your critical strike chance.
    crashing_chaos                 = { 71960, 417234, 1 }, -- Summon Infernal increases the damage of your next $s3 casts of Chaos Bolt by $s1% or your next $s3 casts of Rain of Fire by $s2%.
    cruelty_of_kerxan              = { 94848, 429902, 1 }, -- $?s137044[Summon Demonic Tyrant][Summon Infernal] grants Diabolic Ritual and reduces its duration by ${$s1/1000} sec.
    curse_of_the_satyr             = { 94822, 440057, 1 }, -- [442804] Increases the time between an enemy's attacks by $s1% and the casting time of all spells by $s3% for $d.$?s103112[; Soulburn: Your Curse of Weakness will affect all enemies in a $104222A yard radius around your target.][]; Curses: A warlock can only have one Curse active per target.
    decimation                     = { 101997, 456985, 1 }, -- Your critical strikes have a chance to reset the cooldown of Soul Fire and reduce the cast time of your next Soul Fire by $457555s1%.
    demonfire_mastery              = { 101993, 456946, 1 }, -- Increases the damage of Channel Demonfire by $s1% and it deals damage $s2% faster.
    devastation                    = { 72066, 454735, 1 }, -- Increases the critical strike chance of your Destruction spells by $s1%.
    diabolic_embers                = { 71968, 387173, 1 }, -- Incinerate now generates $s1% additional Soul Shard Fragments.
    diabolic_ritual                = { 94855, 428514, 1 }, -- Spending a Soul Shard on a damaging spell grants Diabolic Ritual for $431944d. While Diabolic Ritual is active, each Soul Shard spent on a damaging spell reduces its duration by $s1 sec.; When Diabolic Ritual expires you gain Demonic Art, causing your next $?s137044[Hand of Gul'dan][Chaos Bolt, Rain of Fire, or Shadowburn] to summon an Overlord, Mother of Chaos, or Pit Lord that unleashes a devastating attack against your enemies.
    dimension_ripper               = { 102002, 457025, 1 }, -- Incinerate has a chance to tear open a Dimensional Rift or recharge Dimensional Rift if learned.
    dimensional_rift               = { 102003, 387976, 1 }, -- [394235] Deals ${$394238s1*($394237d/$394237t1)} Shadow damage over $394237d.
    emberstorm                     = { 72062, 454744, 1 }, -- Increases the damage done by your Fire spells by $s1% and reduces the cast time of your Incinerate spell by $s2%.
    eradication                    = { 71984, 196412, 1 }, -- Chaos Bolt and Shadowburn increases the damage you deal to the target by $s2% for $196414d.
    explosive_potential            = { 72059, 388827, 1 }, -- Reduces the cooldown of Conflagrate by ${$s1/-1000} sec.
    fiendish_cruelty               = { 101994, 456943, 1 }, -- When Shadowburn fails to kill a target that is at or below $s2% health, its cooldown is reduced by $s1 sec.
    fire_and_brimstone             = { 71982, 196408, 1 }, -- Incinerate now also hits all enemies near your target for $s1% damage.
    flames_of_xoroth               = { 94833, 429657, 1 }, -- Fire damage increased by $s1% and damage dealt by your demons is increased by $s3%.
    flashpoint                     = { 71972, 387259, 1 }, -- When your $?a445465[Wither][Immolate] deals periodic damage to a target above $s2% health, gain $387263s1% Haste for $387263d.; Stacks up to $387263U times.
    gloom_of_nathreza              = { 94843, 429899, 1 }, -- $?s137044[Hand of Gul'dan deals $s1% increased damage for each Soul Shard spent.][Enemies marked by your Havoc take $s2% increased damage from your single target spells.]
    grimoire_of_sacrifice          = { 71971, 108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal $196100s1 additional Shadow damage.; Lasts $196099d or until you summon a demon pet.
    hatefury_rituals               = { 94854, 440048, 1 }, -- Wither deals $s1% increased periodic damage but its duration is $s2% shorter.
    havoc                          = { 71979, 80240 , 1 }, -- Marks a target with Havoc for $d, causing your single target spells to also strike the Havoc victim for $s1% of the damage dealt.
    illhoofs_design                = { 94835, 440070, 1 }, -- Sacrifice $s1% of your maximum health. Soul Leech now absorbs an additional $s2% of your maximum health.
    improved_chaos_bolt            = { 101992, 456951, 1 }, -- Increases the damage of Chaos Bolt by $s1% and reduces its cast time by ${$s2/-1000}.1 sec.
    improved_conflagrate           = { 72065, 231793, 1 }, -- Conflagrate gains an additional charge.
    indiscriminate_flames          = { 101995, 457114, 1 }, -- Backdraft increases the damage of your next Chaos Bolt by $s1% and increases the critical strike chance of your next Incinerate or Soul Fire by $s2%.
    infernal_bulwark               = { 94852, 429130, 1 }, -- Unending Resolve grants Soul Leech equal to $434561s1% of your maximum health and increases the maximum amount Soul Leech can absorb by $434561s1% for $434561d.
    infernal_machine               = { 94848, 429917, 1 }, -- Spending Soul Shards on damaging spells while your $?s137044[Demonic Tyrant][Infernal] is active decreases the duration of Diabolic Ritual by ${$s1/1000} additional sec.
    infernal_vitality              = { 94852, 429115, 1 }, -- Unending Resolve heals you for ${$434559s1*($434559d/$434559t1)}% of your maximum health over $434559d.
    inferno                        = { 71974, 270545, 1 }, -- Rain of Fire damage is increased by $s2% and its Soul Shard cost is reduced by ${$s1/-10}.
    internal_combustion            = { 71980, 266134, 1 }, -- Chaos Bolt consumes up to $s1 sec of $?a445465[Wither's][Immolate's] damage over time effect on your target, instantly dealing that much damage.
    malevolence                    = { 94842, 442726, 1 }, -- Dark magic erupts from you and corrupts your soul for $442726d, causing enemies suffering from your Wither to take $446285s1 Shadowflame damage and increase its stack count by $s1.; While corrupted your Haste is increased by $442726s1% and spending Soul Shards on damaging spells grants $s2 additional stack of Wither.
    mark_of_perotharn              = { 94844, 440045, 1 }, -- Critical strike damage dealt by Wither is increased by $s1%. ; Wither has a chance to gain a stack when it critically strikes. Stacks gained this way do not activate Blackened Soul.
    mark_of_xavius                 = { 94834, 440046, 1 }, -- $?s980[Agony damage increased by $s1%.][Wither damage increased by $s2%.]; Blackened Soul deals $s3% increased damage per stack of Wither.
    master_ritualist               = { 71962, 387165, 1 }, -- Ritual of Ruin requires $s1 less Soul Shards spent.
    mayhem                         = { 71979, 387506, 1 }, -- Your single target spells have a $s1% chance to apply $?a200546[Bane of Havoc below][Havoc to] a nearby enemy for ${$s3/1000}.1 sec.; $?a200546[$@spellicon200546 $@spellname200546; Curses the ground with a demonic bane, causing all of your single target spells to also strike targets marked with the bane for $80240s1% of the damage dealt. Lasts ${$s3/1000}.1 sec.][$@spellicon80240 $@spellname80240; Marks a target with Havoc for ${$s3/1000}.1 sec, causing your single target spells to also strike the Havoc victim for $80240s1% of the damage dealt.]
    power_overwhelming             = { 71965, 387279, 1 }, -- Consuming Soul Shards increases your Mastery by ${$s2/10}.1% for $387283d for each shard spent. Gaining a stack does not refresh the duration.
    pyrogenics                     = { 71975, 387095, 1 }, -- Enemies affected by your Rain of Fire take $s1% increased damage from your Fire spells.
    raging_demonfire               = { 72063, 387166, 1 }, -- Channel Demonfire fires an additional $s1 bolts. Each bolt increases the remaining duration of $?a445465[Wither][Immolate] on all targets hit by ${$s2/1000}.1 sec.
    rain_of_chaos                  = { 71960, 266086, 1 }, -- While your initial Infernal is active, every Soul Shard you spend has a $s1% chance to summon an additional Infernal that lasts $335236d.
    rain_of_fire                   = { 72069, 5740  , 1 }, -- Calls down a rain of hellfire, dealing ${$42223m1*8} Fire damage over $d to enemies in the area.
    reverse_entropy                = { 71980, 205148, 1 }, -- Your spells have a chance to grant you $266030s1% Haste for $266030d.
    ritual_of_ruin                 = { 71970, 387156, 1 }, -- Every $s1 Soul Shards spent grants Ritual of Ruin, making your next Chaos Bolt or Rain of Fire consume no Soul Shards and have its cast time reduced by $387157s3%.
    roaring_blaze                  = { 72065, 205184, 1 }, -- Conflagrate increases your $?s6353[Soul Fire, ][]$?s196447[Channel Demonfire, ][]$?a445465[Wither][Immolate], Incinerate, and Conflagrate damage to the target by $265931s1% for $265931d.
    rolling_havoc                  = { 71961, 387569, 1 }, -- Each time your spells duplicate from Havoc, gain $s1% increased damage for $387570d. Stacks up to $387570U times.
    ruin                           = { 71967, 387103, 1 }, -- Increases the critical strike damage of your Destruction spells by $s1%.
    ruination                      = { 94830, 428522, 1 }, -- [434635] Call down a demon-infested meteor from the depths of the Twisting Nether, dealing $434636s1 Chaos damage on impact to all enemies within $434636a1 yds of the target$?s137046[ and summoning $433885s3 Diabolic Imp.; Damage is further increased by your critical strike chance and is reduced beyond $s2 targets.][ and summoning $433885s2 Wild Imps.; Damage is reduced beyond $s2 targets.]
    scalding_flames                = { 71973, 388832, 1 }, -- Increases the damage of $?a445465[Wither][Immolate] by $s1% and its duration by ${$s3/1000} sec.
    secrets_of_the_coven           = { 94826, 428518, 1 }, -- [434506] Hurl a bolt enveloped in the infernal flames of the abyss, dealing $s1 Fire damage to your enemy target and generating ${$s2/10} Soul Shards.
    seeds_of_their_demise          = { 94829, 440055, 1 }, -- After Wither reaches $s1 stacks or when its host reaches $s2% health, Wither deals $445736s1 Shadowflame damage to its host every $445731t1 sec until 1 stack remains.; When Blackened Soul deals damage, you have a chance to gain $?s137046[$s4 stacks of Flashpoint][Tormented Crescendo].
    shadowburn                     = { 72060, 17877 , 1 }, -- Blasts a target for $s1 Shadowflame damage, gaining $s3% critical strike chance on targets that have $s4% or less health.; Restores ${$245731s1/10} Soul Shard and refunds a charge if the target dies within $d.
    soul_fire                      = { 71978, 6353  , 1 }, -- Burns the enemy's soul, dealing $s1 Fire damage and applying $?a445465[Wither][Immolate].; Generates ${$281490s1/10} Soul Shard.
    souletched_circles             = { 94836, 428911, 1 }, -- You always gain the benefit of Soulburn when casting Demonic Circle: Teleport, increasing your movement speed by 50% and making you immune to snares and roots for 6 sec.
    summon_infernal                = { 71985, 1122  , 1 }, -- Summons an Infernal from the Twisting Nether, impacting for $22703s1 Fire damage and stunning all enemies in the area for $22703d.; The Infernal will serve you for $111685d, dealing ${$20153s1*(100+$137046s3)/100} damage to all nearby enemies every $19483t1 sec and generating $264365s1 Soul Shard Fragment every $264364t1 sec.
    summoners_embrace              = { 71971, 453105, 1 }, -- Increases the damage dealt by your spells and your demon by $s1%.
    touch_of_rancora               = { 94856, 429893, 1 }, -- Demonic Art increases the damage of your next $?s137044[Hand of Gul'dan][Chaos Bolt, Rain of Fire, or Shadowburn] by $s1% and reduces its cast time by $s2%.
    unstable_rifts                 = { 102427, 457064, 1 }, -- Bolts from Dimensional Rift now deal $s1% of damage dealt to nearby enemies as Fire damage.
    wither                         = { 94840, 445468, 1 }, -- [445468] Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing $s1 Shadowflame damage immediately and an additional $445474o1 Shadowflame damage over $445474d.$?s137046[; Periodic damage generates 1 Soul Shard Fragment and has a $s2% chance to generate an additional 1 on critical strikes.; Replaces Immolate.][; Replaces Corruption.]
    xalans_cruelty                 = { 94845, 440040, 1 }, -- Shadow damage dealt by your spells and abilities is increased by $s3% and your Shadow spells gain $s1% more critical strike chance from all sources.
    xalans_ferocity                = { 94853, 440044, 1 }, -- Fire damage dealt by your spells and abilities is increased by $s1% and your Fire spells gain $s4% more critical strike chance from all sources.
    zevrims_resilience             = { 94835, 440065, 1 }, -- Dark Pact heals you for $108416s5 every $108416t5 sec while active.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bane_of_havoc    = 164 , -- (461917) [200546] $?a387506[Your single target spells have a $387506s1% chance to curse][Curses] the ground with a demonic bane, causing all of your single target spells to also strike targets marked with the bane for  $80240s1% of the damage dealt. Lasts $?a387506[${$387506s3/1000} sec][$d].
    bonds_of_fel     = 5401, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the $a2 yd radius they explode, dealing $353813s1 Fire damage split amongst all nearby enemies.
    call_observer    = 5544, -- (201996) Summons a demonic Observer to keep a watchful eye over the area for $d.; Anytime an enemy within $m2 yards casts a harmful magical spell, the Observer will deal up to $212529s2% of the target's maximum health in Shadow damage.
    fel_fissure      = 157 , -- (200586) Chaos Bolt creates a $m1 yd wide eruption of Felfire under the target, reducing movement speed by $200587m1% and reducing all healing received by $200587m2% on all enemies within the fissure. Lasts $212269d.
    gateway_mastery  = 5382, -- (248855) Increases the range of your Demonic Gateway by $s1 yards, and reduces the cast time by $s2%.  Reduces the time between how often players can take your Demonic Gateway by $s3 sec.
    impish_instincts = 5580, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by ${$s1/-1000} sec.; Cannot occur more than once every $proccooldown sec.
    nether_ward      = 3508, -- (212295) Surrounds the caster with a shield that lasts $d, reflecting all harmful spells cast on you.
    shadow_rift      = 5393, -- (353294) Conjure a Shadow Rift at the target location lasting $d. Enemy players within the rift when it expires are teleported to your Demonic Circle.; Must be within $s2 yds of your Demonic Circle to cast.
    soul_rip         = 5607, -- (410598) Fracture the soul of up to $i target players within $r yds into the shadows, reducing their damage done by $s1% and healing received by $s3% for $d. Souls are fractured up to $410615a yds from the player's location.; Players can retrieve their souls to remove this effect.
} )

-- Auras
spec:RegisterAuras( {
    -- Damage taken is reduced by $s1%.
    abyss_walker = {
        id = 389614,
        duration = 10.0,
        max_stack = 1,
    },
    -- Healing $w1 every $t sec.
    accrued_vitality = {
        id = 386614,
        duration = 10.0,
        max_stack = 1,
    },
    -- Next Curse of Tongues, Curse of Exhaustion or Curse of Weakness is amplified.
    amplify_curse = {
        id = 328774,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- teachings_of_the_satyr[387972] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Time between attacks increased $w1% and casting speed increased by $w2%.
    aura_of_enfeeblement = {
        id = 449587,
        duration = 8.0,
        max_stack = 1,
    },
    -- Incinerate, Soul Fire, and Chaos Bolt cast times reduced by $s1%.
    backdraft = {
        id = 117828,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- indiscriminate_flames[457114] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- indiscriminate_flames[457114] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- Your next Incinerate is instant cast.
    backlash = {
        id = 387385,
        duration = 15.0,
        max_stack = 1,
    },
    -- Invulnerable, but unable to act.
    banish = {
        id = 710,
        duration = 30.0,
        max_stack = 1,
    },
    -- Incinerate damage increased by $w1%.
    burn_to_ashes = {
        id = 387154,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- burn_to_ashes[387153] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Movement speed increased by $s1%.
    burning_rush = {
        id = 111400,
        duration = 3600,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- fiendish_stride[386110] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- fiendish_stride[386110] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Damage taken from you and your pets is increased by $s1%.
    cloven_soul = {
        id = 434424,
        duration = 15.0,
        max_stack = 1,
    },
    -- Suffering $w1 Shadow damage every $t1 sec.
    corruption = {
        id = 146739,
        duration = 14.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- destruction_warlock[137046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destruction_warlock[137046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- destruction_warlock[137046] #12: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 348, 'target': TARGET_UNIT_CASTER, }
        -- devastation[454735] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- ruin[387103] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither[445465] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 445468, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
    },
    -- Time between attacks increased by $w1%. $?e1[Chance to critically strike reduced by $w2%.][]
    curse_of_weakness = {
        id = 702,
        duration = 120.0,
        max_stack = 1,

        -- Affected by:
        -- amplify_curse[328774] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- curse_of_the_satyr[440057] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 442804, 'target': TARGET_UNIT_CASTER, }
    },
    -- Absorbs $w1 damage.
    dark_pact = {
        id = 108416,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- frequent_donor[386686] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- ichor_of_devils[386664] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- ichor_of_devils[386664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 300.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Increases your damage by $s1%, and doubles the effectiveness of the other traits of the Deadwind Harvester.
    deadwind_harvester = {
        id = 216708,
        duration = 5.0,
        max_stack = 1,
    },
    -- The cast time of your next Soul Fire is reduced by $s1%.
    decimation = {
        id = 457555,
        duration = 10.0,
        max_stack = 1,
    },
    -- [428524] Your next Soul Shard spent summons an Overlord that unleashes a devastating attack.
    diabolic_ritual_overlord = {
        id = 431944,
        duration = 20.0,
        max_stack = 1,
    },
    -- Suffering $s1 Shadow damage every $t1 seconds.; Restoring health to the Warlock.
    drain_life = {
        id = 234153,
        duration = 5.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    dreadsteed = {
        id = 23161,
        duration = 3600,
        tick_time = 0.5,
        pandemic = true,
        max_stack = 1,
    },
    -- Healing for $m1% of maximum health every $t1 sec.; Spell casts are not delayed by taking damage.
    empowered_healthstone = {
        id = 262080,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage taken from the Warlock increased by $w1%.
    eradication = {
        id = 196414,
        duration = 7.0,
        max_stack = 1,

        -- Affected by:
        -- eradication[196412] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- eradication[196412] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- eradication[196412] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Controlling Eye of Kilrogg.; Detecting Invisibility.
    eye_of_kilrogg = {
        id = 126,
        duration = 45.0,
        max_stack = 1,
    },
    -- Disoriented.
    fear = {
        id = 5782,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- fear[342914] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
    },
    -- Damage is being delayed every $t1 sec.
    fel_armor = {
        id = 387846,
        duration = 3600,
        tick_time = 0.5,
        pandemic = true,
        max_stack = 1,
    },
    -- Imp, Voidwalker, Succubus, Felhunter, or Felguard casting time reduced by $/1000;S1 sec.
    fel_domination = {
        id = 333889,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- fel_pact[386113] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Movement speed reduced by $w1%.; Healing received reduced by $w2%.
    fel_fissure = {
        id = 200587,
        duration = 3600,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%.
    fel_resilience = {
        id = 386869,
        duration = 5.0,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    felsteed = {
        id = 5784,
        duration = 3600,
        pandemic = true,
        max_stack = 1,
    },
    -- Sacrificed your demon pet to gain its command demon ability.; Your spells sometimes deal additional Shadow damage.
    grimoire_of_sacrifice = {
        id = 196099,
        duration = 3600,
        pandemic = true,
        max_stack = 1,
    },
    -- Spells cast by the Warlock also hit this target for $s1% of the damage dealt.
    havoc = {
        id = 80240,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- gloom_of_nathreza[429899] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- bane_of_havoc[461917] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 200546, 'target': TARGET_UNIT_CASTER, }
    },
    -- Transferring health.
    health_funnel = {
        id = 755,
        duration = 5.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Disoriented.
    howl_of_terror = {
        id = 5484,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- annihilans_bellow[429072] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- annihilans_bellow[429072] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Suffering $w1 Fire damage every $t1 sec.$?a339892[ ; Damage taken by Chaos Bolt and Incinerate increased by $w2%.][]
    immolate = {
        id = 157736,
        duration = 18.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- destruction_warlock[137046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destruction_warlock[137046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- socrethars_guile[405936] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ashen_remains[387252] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- devastation[454735] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- emberstorm[454744] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mark_of_xavius[440046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ruin[387103] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- scalding_flames[388832] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- scalding_flames[388832] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ashen_remains[339892] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Stunned.
    infernal_awakening = {
        id = 22703,
        duration = 2.0,
        max_stack = 1,
    },
    -- Soul Leech can absorb an additional $s1% of your maximum health.
    infernal_bulwark = {
        id = 434561,
        duration = 8.0,
        max_stack = 1,
    },
    -- Healing for ${$s1*($d/$t1)}% of your maximum health over $d.
    infernal_vitality = {
        id = 434559,
        duration = 10.0,
        max_stack = 1,
    },
    -- Inflicts Shadow damage.
    laserbeam = {
        id = 212529,
        duration = 0.0,
        max_stack = 1,
    },
    -- Leech increased by $w1%.
    lifeblood = {
        id = 386647,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- lifeblood[386646] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Haste increased by $w1% and $?s324536[Malefic Rapture grants $w2 additional stack of Wither to targets affected by Unstable Affliction.][Chaos Bolt grants $w3 additional stack of Wither.]; All of your active Withers are acute.
    malevolence = {
        id = 442726,
        duration = 20.0,
        max_stack = 1,
    },
    -- Incapacitated.
    mortal_coil = {
        id = 108396,
        duration = 0.0,
        max_stack = 1,
    },
    -- Reflecting all spells.
    nether_ward = {
        id = 212295,
        duration = 3.0,
        max_stack = 1,
    },
    -- Mastery increased by ${$W1}.1%.
    power_overwhelming = {
        id = 387283,
        duration = 10.0,
        max_stack = 1,
    },
    -- $42223s1 Fire damage every $5740t2 sec.
    rain_of_fire = {
        id = 5740,
        duration = 8.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- inferno[270545] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ritual_of_ruin[387157] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Haste increased by $s1%.
    reverse_entropy = {
        id = 266030,
        duration = 8.0,
        max_stack = 1,
    },
    -- Your next Chaos Bolt or Rain of Fire cost no Soul Shards and has its cast time reduced by $s3%.
    ritual_of_ruin = {
        id = 387157,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage increased by $W1%.
    rolling_havoc = {
        id = 387570,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- demonic_fortitude[386617] #4: { 'type': APPLY_AURA, 'subtype': MOD_PET_STAT_PCT, 'points': 5.0, 'value': 1, 'schools': ['physical'], 'value1': 1860, 'target': TARGET_UNIT_CASTER, }
        -- rolling_havoc[387569] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- rolling_havoc[387569] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- If the target dies and yields experience or honor, Shadowburn restores ${$245731s1/10} Soul Shard and refunds a charge.
    shadowburn = {
        id = 17877,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- destruction_warlock[137046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destruction_warlock[137046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blistering_atrophy[456939] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blistering_atrophy[456939] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- blistering_atrophy[456939] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- devastation[454735] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ruin[387103] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- wither[445474] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- immolate[157736] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Slowed by $w1% for $d.
    shadowflame = {
        id = 384069,
        duration = 6.0,
        max_stack = 1,
    },
    -- Stunned.
    shadowfury = {
        id = 30283,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- darkfury[264874] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- darkfury[264874] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Absorbs $w1 damage.
    soul_leech = {
        id = 108366,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- demon_skin[219272] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15001.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Damage done reduced by $s1%.and healing received reduced by $s3%. Retrieve your soul to remove this effect.
    soul_rip = {
        id = 410598,
        duration = 8.0,
        max_stack = 1,
    },
    -- [385899] Consumes a Soul Shard, unlocking the hidden power of your spells.; Demonic Circle: Teleport: Increases your movement speed by $387633s1% and makes you immune to snares and roots for $387633d.; Demonic Gateway: Can be cast instantly.; Drain Life: Gain an absorb shield equal to the amount of healing done for $387630d. This shield cannot exceed $387630s1% of your maximum health.; Health Funnel: Restores $387626s1% more health and reduces the damage taken by your pet by ${$abs($387641s1)}% for $387641d.; Healthstone: Increases the healing of your Healthstone by $387626s2% and increases your maximum health by $387636s1% for $387636d.
    soulburn = {
        id = 387626,
        duration = 20.0,
        max_stack = 1,
    },
    -- Movement speed increased by $s1%. Immune to snares and roots.
    soulburn_demonic_circle = {
        id = 387633,
        duration = 6.0,
        max_stack = 1,
    },
    -- Soul stored by $@auracaster.
    soulstone = {
        id = 20707,
        duration = 900.0,
        max_stack = 1,

        -- Affected by:
        -- swift_artifice[452902] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- $@auracaster's subject.
    subjugate_demon = {
        id = 1098,
        duration = 600.0,
        max_stack = 1,
    },
    -- Underwater Breathing. Swim speed increased by $s2%.
    unending_breath = {
        id = 5697,
        duration = 600.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w3%; Immune to interrupt and silence effects.
    unending_resolve = {
        id = 104773,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- dark_accord[386659] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -45000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- strength_of_will[317138] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Suffering $w1 Shadowflame damage every $t1 sec.$?a339892[ ; Damage taken by Chaos Bolt and Incinerate increased by $w2%.][]
    wither = {
        id = 445474,
        duration = 18.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- destruction_warlock[137046] #12: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 348, 'target': TARGET_UNIT_CASTER, }
        -- socrethars_guile[405936] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ashen_remains[387252] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- bleakheart_tactics[440051] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- emberstorm[454744] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hatefury_rituals[440048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hatefury_rituals[440048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mark_of_xavius[440046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- scalding_flames[388832] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- scalding_flames[388832] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither[445465] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 445468, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- ashen_remains[339892] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- [386613] Drain Life heals for $s1% of the amount drained over $386614d.
    accrued_vitality = {
        id = 386614,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'amplitude': 5.0, 'tick_time': 2.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within $d is amplified.; $@spellname334275; Reduces the target's movement speed by an additional $s3%.; $@spellname1714; Increases casting time by an additional $<cast>%.; $@spellname702; Enemy is unable to critically strike.
    amplify_curse = {
        id = 328774,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        talent = "amplify_curse",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'pvp_multiplier': 0.25, 'points': -40.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.75, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }

        -- Affected by:
        -- teachings_of_the_satyr[387972] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- $?a387506[Your single target spells have a $387506s1% chance to curse][Curses] the ground with a demonic bane, causing all of your single target spells to also strike targets marked with the bane for  $80240s1% of the damage dealt. Lasts $?a387506[${$387506s3/1000} sec][$d].
    bane_of_havoc = {
        id = 200546,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 5650, 'schools': ['holy', 'frost'], 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 12900.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_COOLDOWN, }

        -- Affected by:
        -- gloom_of_nathreza[429899] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- bane_of_havoc[461917] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 200546, 'target': TARGET_UNIT_CASTER, }
    },

    -- Banishes an enemy Demon, Aberration$?s386651[, Undead][], or Elemental, preventing any action for $d. Limit 1. Casting Banish again on the target will cancel the effect.
    banish = {
        id = 710,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.015,
        spendType = 'mana',

        talent = "banish",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'points': -100.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Encircle enemy players with Bonds of Fel. If any affected player leaves the $a2 yd radius they explode, dealing $353813s1 Fire damage split amongst all nearby enemies.
    bonds_of_fel = {
        id = 353753,
        color = 'pvp_talent',
        cast = 1.5,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.015,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 1.0, 'value': 23075, 'schools': ['physical', 'holy', 'shadow'], 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
    },

    -- Increases your movement speed by $s1%, but also damages you for $s2% of your maximum health every $t2 sec. Movement impairing effects may not reduce you below $s3% of normal movement speed. Lasts $d.
    burning_rush = {
        id = 111400,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "burning_rush",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'sp_bonus': 0.25, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE_PERCENT, 'tick_time': 1.0, 'points': 4.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- fiendish_stride[386110] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- fiendish_stride[386110] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Summons a demonic Observer to keep a watchful eye over the area for $d.; Anytime an enemy within $m2 yards casts a harmful magical spell, the Observer will deal up to $212529s2% of the target's maximum health in Shadow damage.
    call_observer = {
        id = 201996,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 107100, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 3832, 'target': TARGET_DEST_CASTER, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 30.0, }
        -- #2: { 'type': UNKNOWN, 'subtype': NONE, 'points': 5.0, }
    },

    -- Calls forth a cataclysm at the target location, dealing $s1 Shadowflame damage to all enemies within $A1 yards and afflicting them with $?a445465[Wither][Immolate].
    cataclysm = {
        id = 152108,
        cast = 2.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "cataclysm",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.7, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- destruction_warlock[137046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destruction_warlock[137046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- devastation[454735] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- emberstorm[454744] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ruin[387103] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Launches $s1 bolts of felfire over $d at random targets afflicted by your $?a445465[Wither][Immolate] within $196449A1 yds. Each bolt deals $196448s1 Fire damage to the target and $196448s2 Fire damage to nearby enemies.
    channel_demonfire = {
        id = 196447,
        cast = 3.0,
        channeled = true,
        cooldown = 25.0,
        gcd = "global",

        spend = 0.015,
        spendType = 'mana',

        talent = "channel_demonfire",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.2, 'points': 15.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- warlock[137042] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- demonfire_mastery[456946] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -35.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- demonfire_mastery[456946] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -35.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- raging_demonfire[387166] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- raging_demonfire[387166] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -12.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },

    -- Unleashes a devastating blast of chaos, dealing a critical strike for ${2*$s1} Chaos damage. Damage is further increased by your critical strike chance.
    chaos_bolt = {
        id = 116858,
        cast = 3.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 20,
        spendType = 'soul_shards',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.90141, 'chain_targets': 1, 'pvp_multiplier': 1.7, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE_PCT, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- destruction_warlock[137046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destruction_warlock[137046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- devastation[454735] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- emberstorm[454744] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_chaos_bolt[456951] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_chaos_bolt[456951] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ruin[387103] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- wither[445474] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- immolate[157736] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- backdraft[117828] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- backdraft[117828] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- backdraft[117828] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ritual_of_ruin[387157] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ritual_of_ruin[387157] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Triggers an explosion on the target, dealing $s1 Fire damage.$?s196406[; Reduces the cast time of your next Incinerate or Chaos Bolt by $117828s1% for $117828d.][]; Generates $245330s1 Soul Shard Fragments.
    conflagrate = {
        id = 17962,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "conflagrate",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.3499, 'chain_targets': 1, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- destruction_warlock[137046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destruction_warlock[137046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- devastation[454735] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- emberstorm[454744] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_conflagrate[231793] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- ruin[387103] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Corrupts the target, causing $s3 Shadow damage and $?a196103[$146739s1 Shadow damage every $146739t1 sec.][an additional $146739o1 Shadow damage over $146739d.]
    corruption = {
        id = 172,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 146739, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.138, 'pvp_multiplier': 1.25, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- destruction_warlock[137046] #12: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 348, 'target': TARGET_UNIT_CASTER, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither[445465] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 445468, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
    },

    -- [386646] When you use a Healthstone, gain $s2% Leech for $386647d.
    create_healthstone = {
        id = 6201,
        cast = 3.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- swift_artifice[452902] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Creates a Soulwell for $d. Party and raid members can use the Soulwell to acquire a Healthstone.
    create_soulwell = {
        id = 29893,
        cast = 3.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 0.050,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'points': 1.0, 'value': 303148, 'schools': ['fire', 'nature', 'shadow'], 'radius': 5.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Increases the time between an enemy's attacks by $s1% for $d.$?s103112[; Soulburn: Your Curse of Weakness will affect all enemies in a $104222A yard radius around your target.][]; Curses: A warlock can only have one Curse active per target.
    curse_of_weakness = {
        id = 702,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        spendType = 'soul_shards',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_MELEE_RANGED_HASTE_2, 'points': -20.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_PCT, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- amplify_curse[328774] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- curse_of_the_satyr[440057] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 442804, 'target': TARGET_UNIT_CASTER, }
    },

    -- Sacrifices $s2% of your current health to shield you for $s3% of the sacrificed health plus an additional $<points> for $d. Usable while suffering from control impairing effects.
    dark_pact = {
        id = 108416,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        talent = "dark_pact",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'sp_bonus': 5.0, }
        -- #4: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 1.0, 'sp_bonus': 0.182332, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- frequent_donor[386686] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- ichor_of_devils[386664] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- ichor_of_devils[386664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 300.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per $<GatewayCooldown> sec.
    demonic_gateway = {
        id = 111771,
        cast = 2.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 0.100,
        spendType = 'mana',

        talent = "demonic_gateway",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'value': 47319, 'schools': ['physical', 'holy', 'fire', 'frost', 'arcane'], 'value1': 4991, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- gateway_mastery[248855] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- gateway_mastery[248855] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'modifies': CAST_TIME, }
        -- soulburn[387626] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Rips a hole in time and space, opening a portal that damages your target.; Generates $s2 Soul Shard Fragments.
    dimensional_rift = {
        id = 196586,
        color = 'artifact',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 24710.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'resource': soul_shards, }
    },

    -- [394235] Deals ${$394238s1*($394237d/$394237t1)} Shadow damage over $394237d.
    dimensional_rift_387976 = {
        id = 387976,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "dimensional_rift_387976",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 24710.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'resource': soul_shards, }
        from = "spec_talent",
    },

    -- [386619] Drain Life heals for $s1% more while below $s2% health.
    drain_life = {
        id = 234153,
        cast = 5.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_LEECH, 'amplitude': 5.0, 'tick_time': 1.0, 'sp_bonus': 0.15, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Summons an Eye of Kilrogg and binds your vision to it. The eye is stealthed and moves quickly but is very fragile.
    eye_of_kilrogg = {
        id = 126,
        cast = 45.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'amplitude': 1.0, 'points': 1.0, 'value': 4277, 'schools': ['physical', 'fire', 'frost', 'shadow'], 'value1': 5027, 'target': TARGET_DEST_CASTER_SUMMON, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INVISIBILITY_DETECT, 'points_per_level': 5.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- [386648] Increases the amount of damage required to break your fear effects by $s1%.
    fear = {
        id = 5782,
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'mechanic': fleeing, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- fear[342914] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
    },

    -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by $s1%.; 
    fel_domination = {
        id = 333889,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        talent = "fel_domination",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -90.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }

        -- Affected by:
        -- fel_pact[386113] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal $196100s1 additional Shadow damage.; Lasts $196099d or until you summon a demon pet.
    grimoire_of_sacrifice = {
        id = 108503,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "grimoire_of_sacrifice",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': INSTAKILL, 'subtype': NONE, 'target': TARGET_UNIT_PET, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 196099, 'target': TARGET_UNIT_CASTER, }
    },

    -- Marks a target with Havoc for $d, causing your single target spells to also strike the Havoc victim for $s1% of the damage dealt.
    havoc = {
        id = 80240,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "havoc",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 60.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- gloom_of_nathreza[429899] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- bane_of_havoc[461917] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 200546, 'target': TARGET_UNIT_CASTER, }
    },

    -- Sacrifices ${$m3*$d/$t1}% of your maximum health to heal your summoned Demon for twice as much over $d.
    health_funnel = {
        id = 755,
        cast = 5.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'amplitude': 2.2, 'tick_time': 1.0, 'points': 5.0, 'target': TARGET_UNIT_PET, }
    },

    -- Let loose a terrifying howl, causing $i enemies within $A1 yds to flee in fear, disorienting them for $d. Damage may cancel the effect.
    howl_of_terror = {
        id = 5484,
        cast = 0.0,
        cooldown = 40.0,
        gcd = "global",

        spend = 0.018,
        spendType = 'mana',

        talent = "howl_of_terror",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_FEAR, 'points': 1.0, 'value': 1, 'schools': ['physical'], 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 4.0, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }

        -- Affected by:
        -- annihilans_bellow[429072] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- annihilans_bellow[429072] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- [430014] Dark magic erupts from you and corrupts your soul for $442726d, causing enemies suffering from your Wither to take $446285s1 Shadowflame damage and increase its stack count by $s1.; While corrupted your Haste is increased by $442726s1% and spending Soul Shards on damaging spells grants $s2 additional stack of Wither.
    malevolence = {
        id = 442726,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "malevolence",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'attributes': ['Suppress Points Stacking'], 'points': 8.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AREA_AURA_ENEMY, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 445731, 'radius': 100.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
    },

    -- Horrifies an enemy target into fleeing, incapacitating for $6789d and healing you for $108396m1% of maximum health.
    mortal_coil = {
        id = 6789,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "mortal_coil",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_FEAR, 'sp_bonus': 0.25, 'mechanic': horrified, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 108396, 'points': 15.0, }
        -- #3: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'mechanic': horrified, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Surrounds the caster with a shield that lasts $d, reflecting all harmful spells cast on you.
    nether_ward = {
        id = 212295,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "none",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': REFLECT_SPELLS, 'amplitude': 1.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Calls down a rain of hellfire, dealing ${$42223m1*8} Fire damage over $d to enemies in the area.
    rain_of_fire = {
        id = 5740,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 30,
        spendType = 'soul_shards',

        talent = "rain_of_fire",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': PERSISTENT_AREA_AURA, 'subtype': DUMMY, 'points': 50.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_DEST_DYNOBJ_ENEMY, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 5420, 'schools': ['fire', 'nature', 'shadow'], 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- inferno[270545] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ritual_of_ruin[387157] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Consume all Tormented Souls collected by Ulthalesh, increasing your damage by $216708s1% and doubling the effect of all of Ulthalesh's other traits for $216708d per soul consumed.; Ulthalesh collects Tormented Souls from each target you kill and occasionally escaped souls it previously collected.
    reap_souls = {
        id = 216698,
        color = 'artifact',
        cast = 0.0,
        cooldown = 5.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Begins a ritual that sacrifices a random participant to summon a doomguard. Requires the caster and 4 additional party members to complete the ritual.
    ritual_of_doom = {
        id = 342601,
        cast = 180.0,
        channeled = true,
        cooldown = 3600.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRANS_DOOR, 'subtype': NONE, 'points': 1.0, 'value': 177193, 'schools': ['physical', 'nature', 'shadow'], 'radius': 5.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Begins a ritual to create a summoning portal, requiring the caster and 2 allies to complete. This portal can be used to summon party and raid members.
    ritual_of_summoning = {
        id = 698,
        cast = 120.0,
        channeled = true,
        cooldown = 120.0,
        gcd = "global",

        spend = 0.050,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 194108, 'schools': ['fire', 'nature', 'frost', 'shadow'], 'radius': 0.0, 'target': TARGET_DEST_CASTER_FRONT, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Sends a shadowy bolt at the enemy, causing $s1 Shadow damage.$?c2[; Generates 1 Soul Shard.][]
    shadow_bolt = {
        id = 686,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.015,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.702, 'pvp_multiplier': 1.9, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- destruction_warlock[137046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destruction_warlock[137046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- destruction_warlock[137046] #13: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 29722, 'target': TARGET_UNIT_CASTER, }
        -- sargerei_technique[405955] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation[454735] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- ruin[387103] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Conjure a Shadow Rift at the target location lasting $d. Enemy players within the rift when it expires are teleported to your Demonic Circle.; Must be within $s2 yds of your Demonic Circle to cast.
    shadow_rift = {
        id = 353294,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 23024, 'schools': ['frost', 'shadow', 'arcane'], 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_DEST_DEST, }
    },

    -- Blasts a target for $s1 Shadowflame damage, gaining $s3% critical strike chance on targets that have $s4% or less health.; Restores ${$245731s1/10} Soul Shard and refunds a charge if the target dies within $d.
    shadowburn = {
        id = 17877,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        talent = "shadowburn",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.9872, 'chain_targets': 1, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- destruction_warlock[137046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destruction_warlock[137046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blistering_atrophy[456939] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blistering_atrophy[456939] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- blistering_atrophy[456939] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- devastation[454735] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ruin[387103] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- wither[445474] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- immolate[157736] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Slows enemies in a $A1 yard cone in front of you by $s1% for $d.
    shadowflame = {
        id = 384069,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "shadowflame",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -70.0, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
    },

    -- Stuns all enemies within $a1 yds for $d.
    shadowfury = {
        id = 30283,
        cast = 1.5,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "shadowfury",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- darkfury[264874] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- darkfury[264874] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Burns the enemy's soul, dealing $s1 Fire damage and applying $?a445465[Wither][Immolate].; Generates ${$281490s1/10} Soul Shard.
    soul_fire = {
        id = 6353,
        cast = 4.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "soul_fire",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 4.7628, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- destruction_warlock[137046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destruction_warlock[137046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- devastation[454735] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- emberstorm[454744] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ruin[387103] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- backdraft[117828] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- backdraft[117828] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- backdraft[117828] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- decimation[457555] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -80.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Fracture the soul of up to $i target players within $r yds into the shadows, reducing their damage done by $s1% and healing received by $s3% for $d. Souls are fractured up to $410615a yds from the player's location.; Players can retrieve their souls to remove this effect.
    soul_rip = {
        id = 410598,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'trigger_spell': 410615, 'points': -25.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 20.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': -30.0, 'radius': 20.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'points': -25.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 20.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
    },

    -- Consumes a Soul Shard, unlocking the hidden power of your spells.; Demonic Circle: Teleport: Increases your movement speed by $387633s1% and makes you immune to snares and roots for $387633d.; Demonic Gateway: Can be cast instantly.; Drain Life: Gain an absorb shield equal to the amount of healing done for $387630d. This shield cannot exceed $387630s1% of your maximum health.; Health Funnel: Restores $387626s1% more health and reduces the damage taken by your pet by ${$abs($387641s1)}% for $387641d.; Healthstone: Increases the healing of your Healthstone by $387626s2% and increases your maximum health by $387636s1% for $387636d.
    soulburn = {
        id = 385899,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "none",

        spend = 10,
        spendType = 'soul_shards',

        talent = "soulburn",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 387626, 'target': TARGET_UNIT_CASTER, }
    },

    -- Stores the soul of the target party or raid member, allowing resurrection upon death.$?a231811[ Also castable to resurrect a dead target.][] Targets resurrect with $3026s2% health and at least $3026s1% mana.
    soulstone = {
        id = 20707,
        cast = 3.0,
        cooldown = 600.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'sp_bonus': 1.0, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'trigger_spell': 6203, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_CORPSE_TARGET_ALLY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- swift_artifice[452902] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Subjugates the target demon up to level $s1, forcing it to do your bidding for $d.
    subjugate_demon = {
        id = 1098,
        cast = 3.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CHARM, 'points_per_level': 1.0, 'points': 22.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Summons a Felhunter under your command, able to disrupt the spell casts of your enemies.
    summon_felhunter = {
        id = 691,
        color = 'summon',
        cast = 6.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'points': 1.0, 'value': 417, 'schools': ['physical', 'shadow'], 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- fel_domination[333889] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -90.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- fel_domination[333889] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Summons an Imp under your command that casts ranged Firebolts.
    summon_imp = {
        id = 688,
        color = 'summon',
        cast = 6.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'value': 416, 'schools': ['shadow'], 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- fel_domination[333889] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -90.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- fel_domination[333889] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Summons an Infernal from the Twisting Nether, impacting for $22703s1 Fire damage and stunning all enemies in the area for $22703d.; The Infernal will serve you for $111685d, dealing ${$20153s1*(100+$137046s3)/100} damage to all nearby enemies every $19483t1 sec and generating $264365s1 Soul Shard Fragment every $264364t1 sec.
    summon_infernal = {
        id = 1122,
        color = 'guardian',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "summon_infernal",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 47319, 'schools': ['physical', 'holy', 'fire', 'frost', 'arcane'], 'value1': 1881, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 22703, 'radius': 10.0, 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': TRIGGER_MISSILE_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 111685, 'points': 1.0, 'target': TARGET_DEST_DEST, }
    },

    -- Summons a Succubus or Incubus under your command to seduce enemy Humanoids, preventing them from attacking.; 
    summon_sayaad = {
        id = 366222,
        cast = 6.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'points': 1.0, 'value': 1863, 'schools': ['physical', 'holy', 'fire', 'arcane'], 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- fel_domination[333889] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -90.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- fel_domination[333889] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Summons a Voidwalker under your command, able to withstand heavy punishment.
    summon_voidwalker = {
        id = 697,
        color = 'summon',
        cast = 6.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'points': 1.0, 'value': 1860, 'schools': ['fire', 'arcane'], 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- fel_domination[333889] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -90.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- fel_domination[333889] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Thal'kiel drains $s2% of the life from your demon servants and unleashes a blast of Shadow damage at your current target equal to the life he stole. 
    thalkiels_consumption = {
        id = 211714,
        color = 'artifact',
        cast = 2.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DAMAGE_FROM_MAX_HEALTH_PCT, 'subtype': NONE, 'points': 8.0, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, }
    },

    -- Allows an ally to breathe underwater and increases swim speed by $s2% for $d.
    unending_breath = {
        id = 5697,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': WATER_BREATHING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SWIM_SPEED, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Hardens your skin, reducing all damage you take by $s3% and granting immunity to interrupt, silence, and pushback effects for $d.
    unending_resolve = {
        id = 104773,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 26, }
        -- #1: { 'type': APPLY_AURA, 'subtype': REDUCE_PUSHBACK, 'points': 100.0, 'value': 3, 'schools': ['physical', 'holy'], 'value1': 15, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -25.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 9, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 449587, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- dark_accord[386659] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -45000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- strength_of_will[317138] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing $s1 Shadowflame damage immediately and an additional $445474o1 Shadowflame damage over $445474d.$?s137046[; Periodic damage generates 1 Soul Shard Fragment and has a $s2% chance to generate an additional 1 on critical strikes.; Replaces Immolate.][; Replaces Corruption.]
    wither = {
        id = 445468,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.015,
        spendType = 'mana',

        talent = "wither",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.138, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 445474, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- destruction_warlock[137046] #12: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 348, 'target': TARGET_UNIT_CASTER, }
        -- socrethars_guile[405936] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bleakheart_tactics[440051] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- emberstorm[454744] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mark_of_xavius[440046] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- scalding_flames[388832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither[445465] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 445468, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- wither[445465] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

} )