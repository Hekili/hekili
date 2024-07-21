-- WarlockDemonology.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 266 )

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

    -- Demonology Talents
    abyssal_dominion               = { 94831, 429581, 1 }, -- $?s137044[Summon Demonic Tyrant is empowered, dealing $s1% increased damage and increasing the damage of your demons by $s2% while active.][Summon Infernal becomes empowered, dealing $s3% increased damage. When your Summon Infernal ends, it fragments into two smaller Infernals at $s4% effectiveness that lasts $456310d.]
    annihilan_training             = { 101884, 386174, 1 }, -- Your Felguard deals $386176s1% more damage and takes $386176s2% less damage.
    annihilans_bellow              = { 94836, 429072, 1 }, -- Howl of Terror cooldown is reduced by ${$s1/-1000} sec and range is increased by $s2 yds.
    antoran_armaments              = { 101913, 387494, 1 }, -- Your Felguard deals $s1% additional damage. Soul Strike now deals $s2% of its damage to nearby enemies.
    bilescourge_bombers            = { 101890, 267211, 1 }, -- Tear open a portal to the nether above the target location, from which several Bilescourge will pour out of and crash into the ground over $d, dealing $267213s1 Shadow damage to all enemies within $267213A1 yards.
    blood_invocation               = { 101904, 455576, 1 }, -- Power Siphon increases the damage of Demonbolt by an additional $s2%.
    call_dreadstalkers             = { 101894, 104316, 1 }, -- Summons $s1 ferocious Dreadstalkers to attack the target for $193332d.
    carnivorous_stalkers           = { 101887, 386194, 1 }, -- Your Dreadstalkers' attacks have a $s1% chance to trigger an additional Dreadbite.
    cloven_souls                   = { 94849, 428517, 1 }, -- Enemies damaged by your Overlord have their souls cloven, increasing damage taken by you and your pets by $434424s1% for $434424d.
    cruelty_of_kerxan              = { 94848, 429902, 1 }, -- $?s137044[Summon Demonic Tyrant][Summon Infernal] grants Diabolic Ritual and reduces its duration by ${$s1/1000} sec.
    demoniac                       = { 101891, 426115, 1 }, -- [264178] Send the fiery soul of a fallen demon at the enemy, causing $s1 Shadowflame damage.$?c2[; Generates 2 Soul Shards.][]
    demoniacs_fervor               = { 94832, 449629, 1 }, -- Your demonic soul deals $s1% increased damage to $?s137043[targets affected by your Unstable Affliction.][the main target of Hand of Gul'dan.]
    demonic_brutality              = { 101920, 453908, 1 }, -- Critical strikes from your spells and your demons deal $s1% increased damage.
    demonic_calling                = { 101903, 205145, 1 }, -- Shadow Bolt$?s264178[ and Demonbolt have][ has] a $s3% chance to make your next Call Dreadstalkers cost $s1 fewer Soul $LShard:Shards; and have no cast time.
    demonic_soul                   = { 94851, 449614, 1 }, -- A demonic entity now inhabits your soul, allowing you to detect if a Soul Shard has a Succulent Soul when it's generated. ; A Succulent Soul empowers your next $?s137043[Malefic Rapture, increasing its damage by $449793s2%, and unleashing your demonic soul to deal an additional $449801s1 Shadow damage.][Hand of Gul'dan, increasing its damage by $449793s3%, and unleashing your demonic soul to deal an additional $449801s1 Shadow damage.]
    demonic_strength               = { 101890, 267171, 1 }, -- Infuse your Felguard with demonic strength and command it to charge your target and unleash a Felstorm that will deal $s2% increased damage.
    diabolic_ritual                = { 94855, 428514, 1 }, -- Spending a Soul Shard on a damaging spell grants Diabolic Ritual for $431944d. While Diabolic Ritual is active, each Soul Shard spent on a damaging spell reduces its duration by $s1 sec.; When Diabolic Ritual expires you gain Demonic Art, causing your next $?s137044[Hand of Gul'dan][Chaos Bolt, Rain of Fire, or Shadowburn] to summon an Overlord, Mother of Chaos, or Pit Lord that unleashes a devastating attack against your enemies.
    doom                           = { 101919, 460551, 1 }, -- When Demonbolt consumes a Demonic Core it inflicts impending doom upon the target, dealing $460555s1 Shadow damage to enemies within $460555a1 yds of its target after $460553d or when removed. Damage is reduced beyond $s2 targets.; Consuming a Demonic Core reduces the duration of Doom by ${$s1/1000} sec.
    doom_eternal                   = { 101906, 455585, 1 }, -- Demonic Cores reduce the duration of Doom by an additional ${$s1/1000} sec.
    dread_calling                  = { 101889, 387391, 1 }, -- Each Soul Shard spent on Hand of Gul'dan increases the damage of your next Call Dreadstalkers by $s1%.
    dreadlash                      = { 101888, 264078, 1 }, -- When your Dreadstalkers charge into battle, their Dreadbite attack now hits all targets within $271971A1 yards and deals $s1% more damage.
    eternal_servitude              = { 94824, 449707, 1 }, -- Fel Domination cooldown is reduced by ${$s1/-1000} sec.
    feast_of_souls                 = { 94823, 449706, 1 }, -- When you kill a target, you have a chance to generate a Soul Shard that is guaranteed to be a Succulent Soul.
    fel_invocation                 = { 101897, 428351, 1 }, -- Soul Strike deals $s1% increased damage and generates a Soul Shard.
    fel_sunder                     = { 101911, 387399, 1 }, -- Each time Felstorm deals damage, it increases the damage the target takes from you and your pets by $s1% for $387402d, up to ${$s1*$387402u}%.
    fiendish_oblation              = { 101912, 455569, 1 }, -- Damage dealt by Grimoire: Felguard is increased by an additional $s1% and you gain a Demonic Core when Grimoire: Felguard ends.
    flames_of_xoroth               = { 94833, 429657, 1 }, -- Fire damage increased by $s1% and damage dealt by your demons is increased by $s3%.
    flametouched                   = { 101909, 453699, 1 }, -- Increases the attack speed of your Dreadstalkers by $s1% and their critical strike chance by $s2%.
    foul_mouth                     = { 101918, 455502, 1 }, -- Increases Vilefiend damage by $s1% and your Vilefiend's Bile Spit now applies Wicked Maw.
    friends_in_dark_places         = { 94850, 449703, 1 }, -- Dark Pact now shields you for an additional $s1% of the sacrificed health.
    gloom_of_nathreza              = { 94843, 429899, 1 }, -- $?s137044[Hand of Gul'dan deals $s1% increased damage for each Soul Shard spent.][Enemies marked by your Havoc take $s2% increased damage from your single target spells.]
    gorebound_fortitude            = { 94850, 449701, 1 }, -- You always gain the benefit of Soulburn when consuming a Healthstone, increasing its healing by 30% and increasing your maximum health by 20% for 12 sec.
    gorefiends_resolve             = { 94824, 389623, 1 }, -- Targets resurrected with Soulstone resurrect with $s1% additional health and $s2% additional mana.
    grimoire_felguard              = { 101907, 111898, 1 }, -- Summons a Felguard who attacks the target for $d that deals $216187s1% increased damage.; This Felguard will stun and interrupt their target when summoned.
    guillotine                     = { 101896, 386833, 1 }, -- Your Felguard hurls his axe towards the target location, erupting when it lands and dealing $386609s1 Shadowflame damage every $386542s2 sec for $386542d to nearby enemies.; While unarmed, your Felguard's basic attacks deal damage to all nearby enemies and attacks $386601s1% faster.
    immutable_hatred               = { 101896, 405670, 1 }, -- When you consume a Demonic Core, your primary Felguard carves your target, dealing $<damage> Physical damage.
    imp_gang_boss                  = { 101922, 387445, 1 }, -- Summoning a Wild Imp has a $s1% chance to summon a Imp Gang Boss instead. An Imp Gang Boss deals $387458s2% additional damage. ; Implosions from Imp Gang Boss deal $s2% increased damage.
    impending_doom                 = { 101885, 455587, 1 }, -- Increases the damage of Doom by $s1% and Doom summons $s2 Wild Imp when it expires.
    imperator                      = { 101923, 416230, 1 }, -- Increases the critical strike chance of your Wild Imp's Fel Firebolt by $s1%.
    implosion                      = { 101893, 196277, 1 }, -- Demonic forces suck all of your Wild Imps toward the target, and then cause them to violently explode, dealing $196278s2 Shadowflame damage to all enemies within $196278A3 yards.
    improved_demonic_tactics       = { 101892, 453800, 1 }, -- Increases your primary Felguard's critical strike chance equal to $s2% of your critical strike chance.
    infernal_bulwark               = { 94852, 429130, 1 }, -- Unending Resolve grants Soul Leech equal to $434561s1% of your maximum health and increases the maximum amount Soul Leech can absorb by $434561s1% for $434561d.
    infernal_machine               = { 94848, 429917, 1 }, -- Spending Soul Shards on damaging spells while your $?s137044[Demonic Tyrant][Infernal] is active decreases the duration of Diabolic Ritual by ${$s1/1000} additional sec.
    infernal_vitality              = { 94852, 429115, 1 }, -- Unending Resolve heals you for ${$434559s1*($434559d/$434559t1)}% of your maximum health over $434559d.
    inner_demons                   = { 101925, 267216, 1 }, -- You passively summon a Wild Imp to fight for you every $t1 sec.
    mark_of_fharg                  = { 101895, 455450, 1 }, -- [428453] Cloaked in the ever-burning flames of the abyss, dealing $428455s1 Fire damage to enemies within $428455a1 yards every $t1 sec.
    mark_of_shatug                 = { 101895, 455449, 1 }, -- [455489] Tooth and claw are drenched in malignant shadow magic, causing the Gloomhound's melee attacks to deal an additional $455491s1 Shadow damage.
    necrolyte_teachings            = { 94825, 449620, 1 }, -- $?s137043[Shadow Bolt and Drain Soul damage increased by $s2%. Nightfall increases the damage of Shadow Bolt and Drain Soul by an additional $s1%.][Shadow Bolt damage increased by $s2%. Power Siphon increases the damage of Demonbolt by an additional $s3%.]
    pact_of_the_eredruin           = { 101917, 453568, 1 }, -- When Doom expires, you have a chance to summon a Doomguard that casts $s1 Doom Bolts before departing. Each Doom Bolt deals $453616s1 Shadow damage.
    pact_of_the_imp_mother         = { 101924, 387541, 1 }, -- Hand of Gul'dan has a $s1% chance to cast a second time on your target for free.
    power_siphon                   = { 101916, 264130, 1 }, -- Instantly sacrifice up to $s1 Wild Imps, generating $s1 charges of Demonic Core that cause Demonbolt to deal $334581s1% additional damage.
    quietus                        = { 94846, 449634, 1 }, -- Soul Anathema damage increased by $s1% and is dealt $s2% faster.; Consuming $?s137043[Nightfall][Demonic Core] activates Shared Fate or Feast of Souls.
    reign_of_tyranny               = { 101908, 427684, 1 }, -- Summon Demonic Tyrant empowers $s1 additional Wild Imps and deals $s2% increased damage for each demon he empowers.
    ruination                      = { 94830, 428522, 1 }, -- [434635] Call down a demon-infested meteor from the depths of the Twisting Nether, dealing $434636s1 Chaos damage on impact to all enemies within $434636a1 yds of the target$?s137046[ and summoning $433885s3 Diabolic Imp.; Damage is further increased by your critical strike chance and is reduced beyond $s2 targets.][ and summoning $433885s2 Wild Imps.; Damage is reduced beyond $s2 targets.]
    rune_of_shadows                = { 101914, 453744, 1 }, -- Increases all damage done by your pet by $s1%.; Reduces the cast time of Shadow Bolt by $s2% and increases its damage by $s3%.
    sacrificed_souls               = { 101886, 267214, 1 }, -- Shadow Bolt and Demonbolt deal $s1% additional damage per demon you have summoned.
    sataiels_volition              = { 94838, 449637, 1 }, -- $?s137043[Corruption deals damage $s1% faster and Haunt grants Nightfall.][Wild Imp damage increased by $s2% and Wild Imps that are imploded have an additional $s3% chance to grant a Demonic Core.]
    secrets_of_the_coven           = { 94826, 428518, 1 }, -- [434506] Hurl a bolt enveloped in the infernal flames of the abyss, dealing $s1 Fire damage to your enemy target and generating ${$s2/10} Soul Shards.
    shadow_invocation              = { 101921, 422054, 1 }, -- Bilescourge Bombers deal $s1% increased damage, and your spells now have a chance to summon a Bilescourge Bomber.
    shadow_of_death                = { 94857, 449638, 1 }, -- Your $?s137043[Soul Rot][Summon Demonic Tyrant] spell is empowered by the demonic entity within you, causing it to grant ${$449858s1/10} Soul Shards that each contain a Succulent Soul.
    shadowtouched                  = { 101910, 453619, 1 }, -- Wicked Maw causes the target to take $s1% additional Shadow damage from your demons.
    shared_fate                    = { 94823, 449704, 1 }, -- When you kill a target, its tortured soul is flung into a nearby enemy for $450591d. This effect inflicts $450593s1 Shadow damage to enemies within $450593a1 yds every $450591t1 sec.; Deals reduced damage beyond $s1 targets.
    soul_anathema                  = { 94847, 449624, 1 }, -- Unleashing your demonic soul bestows a fiendish entity unto the soul of its targets, dealing $450538o1 Shadow damage over $450538d.; If this effect is reapplied, any remaining damage will be added to the new Soul Anathema.
    soul_strike                    = { 101899, 428344, 1 }, -- [267964] Strike into the soul of the enemy, dealing $<damage> Shadow damage.$?s428351[; Generates 1 Soul Shard.][]
    souletched_circles             = { 94836, 428911, 1 }, -- You always gain the benefit of Soulburn when casting Demonic Circle: Teleport, increasing your movement speed by 50% and making you immune to snares and roots for 6 sec.
    spiteful_reconstitution        = { 101901, 428394, 1 }, -- Implosion deals $s1% increased damage. Consuming a Demonic Core has a chance to summon a Wild Imp.
    summon_demonic_tyrant          = { 101905, 265187, 1 }, -- Summon a Demonic Tyrant to increase the duration of your Dreadstalkers, Vilefiend, Felguard, and up to $s3 of your Wild Imps by ${$265273m3/1000} sec. Your Demonic Tyrant increases the damage of affected demons by $265273s1%, while damaging your target.$?s334585[; Generates ${$s2/10} Soul Shards.][]
    summon_vilefiend               = { 101900, 264119, 1 }, -- Summon a Vilefiend to fight for you for the next $d.
    the_expendables                = { 101902, 387600, 1 }, -- When your Wild Imps expire or die, your other demons are inspired and gain 1% additional damage, stacking up to $387601u times.
    the_houndmasters_gambit        = { 101898, 455572, 1 }, -- Your Dreadstalkers deal $455611s1% increased damage while your Vilefiend is active.
    touch_of_rancora               = { 94856, 429893, 1 }, -- Demonic Art increases the damage of your next $?s137044[Hand of Gul'dan][Chaos Bolt, Rain of Fire, or Shadowburn] by $s1% and reduces its cast time by $s2%.
    umbral_blaze                   = { 101915, 405798, 1 }, -- Hand of Gul'dan has a $s1% chance to burn its target for ${$405802s1*(1+$s2/100)} additional Shadowflame damage every $405802t1 sec for $405802d.; If this effect is reapplied, any remaining damage will be added to the new Umbral Blaze.
    wicked_maw                     = { 101926, 267170, 1 }, -- Dreadbite causes the target to take $270569s1% additional Shadowflame damage from your spell and abilities for the next $270569d.
    wicked_reaping                 = { 94821, 449631, 1 }, -- Damage dealt by your demonic soul is increased by $s1%.; Consuming $?s137043[Nightfall][Demonic Core] feeds the demonic entity within you, causing it to appear and deal $?s137043[$449826s1][${$449826s1*($s2/100)}] Shadow damage to your target.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bonds_of_fel     = 5545, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the $a2 yd radius they explode, dealing $353813s1 Fire damage split amongst all nearby enemies.
    call_fel_lord    = 162 , -- (212459) Summon a fel lord to guard the location for $d. Any enemy that comes within $213688A1 yards will suffer $<FelCleave> Physical damage, and players struck will be stunned for $213688d.
    call_observer    = 165 , -- (201996) Summons a demonic Observer to keep a watchful eye over the area for $d.; Anytime an enemy within $m2 yards casts a harmful magical spell, the Observer will deal up to $212529s2% of the target's maximum health in Shadow damage.
    gateway_mastery  = 3506, -- (248855) Increases the range of your Demonic Gateway by $s1 yards, and reduces the cast time by $s2%.  Reduces the time between how often players can take your Demonic Gateway by $s3 sec.
    impish_instincts = 5577, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by ${$s1/-1000} sec.; Cannot occur more than once every $proccooldown sec.
    master_summoner  = 1213, -- (212628) Reduces the cast time of your Call Dreadstalkers, Summon Vilefiend, and Summon Demonic Tyrant by $s2% and reduces the cooldown of Call Dreadstalkers by ${$s3/-1000} sec.
    nether_ward      = 3624, -- (212295) Surrounds the caster with a shield that lasts $d, reflecting all harmful spells cast on you.
    shadow_rift      = 5394, -- (353294) Conjure a Shadow Rift at the target location lasting $d. Enemy players within the rift when it expires are teleported to your Demonic Circle.; Must be within $s2 yds of your Demonic Circle to cast.
    soul_rip         = 5606, -- (410598) Fracture the soul of up to $i target players within $r yds into the shadows, reducing their damage done by $s1% and healing received by $s3% for $d. Souls are fractured up to $410615a yds from the player's location.; Players can retrieve their souls to remove this effect.
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
    -- Your Felguard deals $w1% more damage and takes $w1% less damage.
    annihilan_training = {
        id = 386176,
        duration = 3600,
        max_stack = 1,
    },
    -- Time between attacks increased $w1% and casting speed increased by $w2%.
    aura_of_enfeeblement = {
        id = 449587,
        duration = 8.0,
        max_stack = 1,
    },
    -- Invulnerable, but unable to act.
    banish = {
        id = 710,
        duration = 30.0,
        max_stack = 1,
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
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonic_brutality[453908] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- sataiels_volition[449637] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither[445465] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 445468, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
    },
    -- Time between attacks increased by $w1%. $?e1[Chance to critically strike reduced by $w2%.][]
    curse_of_weakness = {
        id = 702,
        duration = 120.0,
        max_stack = 1,

        -- Affected by:
        -- amplify_curse[328774] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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
    -- Your next Call Dreadstalkers costs $205145s1 less Soul $LShard:Shards; and has no cast time.
    demonic_calling = {
        id = 205146,
        duration = 20.0,
        max_stack = 1,
    },
    -- Damage dealt by your demons increased by $s5%.
    demonic_power = {
        id = 265273,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next Felstorm will deal $s2% increased damage.
    demonic_strength = {
        id = 267171,
        duration = 20.0,
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
    -- Stunned.
    fel_cleave = {
        id = 213688,
        duration = 1.0,
        max_stack = 1,
    },
    -- Imp, Voidwalker, Succubus, Felhunter, or Felguard casting time reduced by $/1000;S1 sec.
    fel_domination = {
        id = 333889,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- fel_pact[386113] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- eternal_servitude[449707] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -90000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Damage taken reduced by $w1%.
    fel_resilience = {
        id = 386869,
        duration = 5.0,
        max_stack = 1,
    },
    -- Damage taken from $@auracaster and their pets is increased by $s1%.
    fel_sunder = {
        id = 387402,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- fel_sunder[387399] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- fel_sunder[387399] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    felsteed = {
        id = 5784,
        duration = 3600,
        pandemic = true,
        max_stack = 1,
    },
    -- Summoned by a Grimoire of Service.; Damage done increased by $s1%.
    grimoire_of_service = {
        id = 216187,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- fiendish_oblation[455569] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
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
    -- Damage done increased by $s2%.
    imp_gang_boss = {
        id = 387458,
        duration = 3600,
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
    -- Dealing $450593s1 Shadow damage to enemies within $450593a1 yds every $t1 sec.
    shared_fate = {
        id = 450591,
        duration = 3.0,
        max_stack = 1,
    },
    -- Dealing $o1 Shadow damage over $d.
    soul_anathema = {
        id = 450538,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_master_demonologist[77219] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 1.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- quietus[449634] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- quietus[449634] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- quietus[449634] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Absorbs $w1 damage.
    soul_leech = {
        id = 108366,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- demon_skin[219272] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15001.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- soulburn[213398] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Damage done reduced by $s1%.and healing received reduced by $s3%. Retrieve your soul to remove this effect.
    soul_rip = {
        id = 410598,
        duration = 8.0,
        max_stack = 1,
    },
    -- Increases the duration of your next Unstable Affliction by ${$m1/1000} sec.
    soulburn = {
        id = 213398,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_master_demonologist[77219] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_invocation[422054] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wicked_maw[270569] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Movement speed increased by $s1%. Immune to snares and roots.
    soulburn_demonic_circle = {
        id = 387633,
        duration = 6.0,
        max_stack = 1,
    },
    -- Maximum health is increased by $s1%.
    soulburn_healthstone = {
        id = 387636,
        duration = 12.0,
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
    -- $?s137043[Malefic Rapture deals $s2% increased damage.][Hand of Gul'dan deals $s3% increased damage.]; Unleashes your demonic entity upon consumption, dealing an additional $449801s~1 Shadow damage to enemies.
    succulent_soul = {
        id = 449793,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage done increased by $s1%.
    the_expendables = {
        id = 387601,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage dealt increased by $s1%.
    the_houndmasters_gambit = {
        id = 455611,
        duration = 30.0,
        max_stack = 1,
    },
    -- Dealing $w1 Shadowflame damage every $t1 sec for $d.
    umbral_blaze = {
        id = 405802,
        duration = 6.0,
        tick_time = 2.0,
        pandemic = true,
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
    -- Damage taken from the Warlock's Shadowflame damage spells increased by $s1%.
    wicked_maw = {
        id = 270569,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- shadowtouched[453619] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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

    -- Tear open a portal to the nether above the target location, from which several Bilescourge will pour out of and crash into the ground over $d, dealing $267213s1 Shadow damage to all enemies within $267213A1 yards.
    bilescourge_bombers = {
        id = 267211,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "bilescourge_bombers",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 1.0, 'value': 13045, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
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

    -- Summons $s1 ferocious Dreadstalkers to attack the target for $193332d.
    call_dreadstalkers = {
        id = 104316,
        cast = 2.0,
        cooldown = 20.0,
        gcd = "global",

        spend = 20,
        spendType = 'soul_shards',

        talent = "call_dreadstalkers",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- master_summoner[212628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- master_summoner[212628] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- demonic_calling[205146] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- demonic_calling[205146] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Summon a fel lord to guard the location for $d. Any enemy that comes within $213688A1 yards will suffer $<FelCleave> Physical damage, and players struck will be stunned for $213688d.
    call_fel_lord = {
        id = 212459,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 6.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 107024, 'schools': ['frost'], 'value1': 3831, 'target': TARGET_DEST_DEST, }
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
        -- sataiels_volition[449637] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
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

    -- Infuse your Felguard with demonic strength and command it to charge your target and unleash a Felstorm that will deal $s2% increased damage.
    demonic_strength = {
        id = 267171,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "demonic_strength",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'pvp_multiplier': 0.75, 'points': 300.0, 'target': TARGET_UNIT_PET, }
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

    -- [212459] Summon a fel lord to guard the location for $d. Any enemy that comes within $213688A1 yards will suffer $<FelCleave> Physical damage, and players struck will be stunned for $213688d.
    fel_cleave = {
        id = 213688,
        cast = 1.3,
        cooldown = 2.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 4.68, 'variance': 0.05, 'radius': 6.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'mechanic': stunned, 'points': 1.0, 'radius': 6.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
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
        -- eternal_servitude[449707] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -90000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Summons a Felguard who attacks the target for $d that deals $216187s1% increased damage.; This Felguard will stun and interrupt their target when summoned.
    grimoire_felguard = {
        id = 111898,
        color = 'summon',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        talent = "grimoire_felguard",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'value': 17252, 'schools': ['fire', 'shadow', 'arcane'], 'value1': 3313, 'radius': 15.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Your Felguard hurls his axe towards the target location, erupting when it lands and dealing $386609s1 Shadowflame damage every $386542s2 sec for $386542d to nearby enemies.; While unarmed, your Felguard's basic attacks deal damage to all nearby enemies and attacks $386601s1% faster.
    guillotine = {
        id = 386833,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "guillotine",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 6.0, 'target': TARGET_DEST_DEST, }
    },

    -- Calls down a demonic meteor full of Wild Imps which burst forth to attack the target.; Deals up to ${$m1*$86040m1} Shadowflame damage on impact to all enemies within $86040A1 yds of the target$?s196283[, applies Doom to each target,][] and summons up to ${$m1*$104317m2} Wild Imps, based on Soul Shards consumed.
    hand_of_guldan = {
        id = 105174,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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

    -- Demonic forces suck all of your Wild Imps toward the target, and then cause them to violently explode, dealing $196278s2 Shadowflame damage to all enemies within $196278A3 yards.
    implosion = {
        id = 196277,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "implosion",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, }

        -- Affected by:
        -- mastery_master_demonologist[77219] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spiteful_reconstitution[428394] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wicked_maw[270569] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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

    -- Instantly sacrifice up to $s1 Wild Imps, generating $s1 charges of Demonic Core that cause Demonbolt to deal $334581s1% additional damage.
    power_siphon = {
        id = 264130,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "power_siphon",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_UNIT_CASTER_AND_SUMMONS, }
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
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sargerei_technique[405955] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonic_brutality[453908] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- necrolyte_teachings[449620] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rune_of_shadows[453744] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- rune_of_shadows[453744] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- Consumes a Soul Shard, increasing the duration of your next Unstable Affliction by ${$m1/1000} sec. Lasts $d.
    soulburn_213398 = {
        id = 213398,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        spend = 1,
        spendType = 'soul_shards',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }

        -- Affected by:
        -- mastery_master_demonologist[77219] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_invocation[422054] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wicked_maw[270569] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
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

    -- Summon a Demonic Tyrant to increase the duration of your Dreadstalkers, Vilefiend, Felguard, and up to $s3 of your Wild Imps by ${$265273m3/1000} sec. Your Demonic Tyrant increases the damage of affected demons by $265273s1%, while damaging your target.$?s334585[; Generates ${$s2/10} Soul Shards.][]
    summon_demonic_tyrant = {
        id = 265187,
        cast = 2.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "summon_demonic_tyrant",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 135002, 'schools': ['holy', 'nature', 'frost', 'arcane'], 'value1': 4255, 'radius': 5.0, 'target': TARGET_DEST_CASTER_FRONT_LEFT, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': soul_shards, }
        -- #2: { 'type': UNKNOWN, 'subtype': NONE, 'points': 10.0, }

        -- Affected by:
        -- reign_of_tyranny[427684] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- master_summoner[212628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Summons a Felguard under your command as a powerful melee combatant.
    summon_felguard = {
        id = 30146,
        color = 'summon',
        cast = 6.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON_PET, 'subtype': NONE, 'points': 1.0, 'value': 17252, 'schools': ['fire', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER_SUMMON, }

        -- Affected by:
        -- fel_domination[333889] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -90.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- fel_domination[333889] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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

    -- Summon a Vilefiend to fight for you for the next $d.
    summon_vilefiend = {
        id = 264119,
        cast = 2.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        talent = "summon_vilefiend",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 135816, 'schools': ['nature'], 'value1': 4266, 'radius': 5.0, 'target': TARGET_DEST_CASTER_FRONT_RIGHT, }

        -- Affected by:
        -- mark_of_fharg[455450] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 455476, 'target': TARGET_UNIT_CASTER, }
        -- mark_of_shatug[455449] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 455465, 'target': TARGET_UNIT_CASTER, }
        -- master_summoner[212628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
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

} )