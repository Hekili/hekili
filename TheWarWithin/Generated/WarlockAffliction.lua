-- WarlockAffliction.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 265 )

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

    -- Affliction Talents
    absolute_corruption            = { 72051, 196103, 1 }, -- $?a445465[Wither][Corruption] is now permanent and deals $s2% increased damage.; Duration reduced to $s1 sec against players.
    aura_of_enfeeblement           = { 94822, 440059, 1 }, -- While Unending Resolve is active, enemies within $449587a1 yds are affected by Curse of Tongues and Curse of Weakness at $s1% effectiveness.
    blackened_soul                 = { 94837, 440043, 1 }, -- Spending Soul Shards on damaging spells will further corrupt enemies affected by your Wither, increasing its stack count by $s1.; Each time Wither gains a stack it has a chance to collapse, consuming a stack every $445731t1 sec to deal $445736s1 Shadowflame damage to its host until 1 stack remains.
    bleakheart_tactics             = { 94854, 440051, 1 }, -- Wither damage increased $s1%. When Wither gains a stack from Blackened Soul, it has a chance to gain an additional stack.
    contagion                      = { 72041, 453096, 2 }, -- Increases critical strike damage dealt by Agony, $?a445465[Wither][Corruption], and Unstable Affliction by $s1%.
    creeping_death                 = { 72058, 264000, 1 }, -- Your Agony, $?a445465[Wither][Corruption], and Unstable Affliction deal damage $s1% faster.
    cull_the_weak                  = { 72038, 453056, 2 }, -- Malefic Rapture damage is increased by $s1% for each enemy it hits, up to $s2 enemies.
    cunning_cruelty                = { 72054, 453172, 1 }, -- Shadow Bolt and Drain Soul have a chance to trigger a Shadow Bolt Volley, dealing $<damage> Shadow damage to $s1 enemies within $453176a1 yards of your current target.
    curse_of_the_satyr             = { 94822, 440057, 1 }, -- [442804] Increases the time between an enemy's attacks by $s1% and the casting time of all spells by $s3% for $d.$?s103112[; Soulburn: Your Curse of Weakness will affect all enemies in a $104222A yard radius around your target.][]; Curses: A warlock can only have one Curse active per target.
    dark_harvest                   = { 102029, 387016, 1 }, -- Each target affected by Soul Rot increases your haste and critical strike chance by ${$s1/10}.1% for $387018d.
    dark_virtuosity                = { 72043, 405327, 2 }, -- Shadow Bolt and Drain Soul deal an additional $s1% damage.
    deaths_embrace                 = { 72033, 453189, 1 }, -- Increases Drain Life healing by $s1% while your health is at or below $s2% health. ; Damage done by your Agony, $?a445465[Wither][Corruption], Unstable Affliction, and Malefic Rapture is increased by $s3% when your target is at or below $s4% health.
    demoniacs_fervor               = { 94832, 449629, 1 }, -- Your demonic soul deals $s1% increased damage to $?s137043[targets affected by your Unstable Affliction.][the main target of Hand of Gul'dan.]
    demonic_soul                   = { 94851, 449614, 1 }, -- A demonic entity now inhabits your soul, allowing you to detect if a Soul Shard has a Succulent Soul when it's generated. ; A Succulent Soul empowers your next $?s137043[Malefic Rapture, increasing its damage by $449793s2%, and unleashing your demonic soul to deal an additional $449801s1 Shadow damage.][Hand of Gul'dan, increasing its damage by $449793s3%, and unleashing your demonic soul to deal an additional $449801s1 Shadow damage.]
    drain_soul                     = { 72045, 388667, 1 }, -- [198590] $?s388667[][Replaces Shadow Bolt.; ]Drains the target's soul, causing $o1 Shadow damage over $d.; Damage is increased by $s2% against enemies below $s3% health.; Generates 1 Soul Shard if the target dies during this effect.
    eternal_servitude              = { 94824, 449707, 1 }, -- Fel Domination cooldown is reduced by ${$s1/-1000} sec.
    feast_of_souls                 = { 94823, 449706, 1 }, -- When you kill a target, you have a chance to generate a Soul Shard that is guaranteed to be a Succulent Soul.
    focused_malignancy             = { 72042, 399668, 1 }, -- Malefic Rapture deals $s1% increased damage to targets suffering from Unstable Affliction.
    friends_in_dark_places         = { 94850, 449703, 1 }, -- Dark Pact now shields you for an additional $s1% of the sacrificed health.
    gorebound_fortitude            = { 94850, 449701, 1 }, -- You always gain the benefit of Soulburn when consuming a Healthstone, increasing its healing by 30% and increasing your maximum health by 20% for 12 sec.
    gorefiends_resolve             = { 94824, 389623, 1 }, -- Targets resurrected with Soulstone resurrect with $s1% additional health and $s2% additional mana.
    grimoire_of_sacrifice          = { 72037, 108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal $196100s1 additional Shadow damage.; Lasts $196099d or until you summon a demon pet.
    hatefury_rituals               = { 94854, 440048, 1 }, -- Wither deals $s1% increased periodic damage but its duration is $s2% shorter.
    haunt                          = { 72032, 48181 , 1 }, -- A ghostly soul haunts the target, dealing $s1 Shadow damage and increasing your damage dealt to the target by $s2% for $d.; If the target dies, Haunt's cooldown is reset.
    illhoofs_design                = { 94835, 440070, 1 }, -- Sacrifice $s1% of your maximum health. Soul Leech now absorbs an additional $s2% of your maximum health.
    improved_haunt                 = { 102031, 458034, 1 }, -- Increases the damage of Haunt by $s1% and reduces its cast time by $s2%. Haunt now applies Shadow Embrace.
    improved_malefic_rapture       = { 72035, 454378, 1 }, -- Increases Malefic Rapture damage by $s1% and reduces its cast time by $s2%.
    improved_shadow_bolt           = { 72045, 453080, 1 }, -- Reduces the cast time of Shadow Bolt by $s1% and increases its damage by $s2%.
    infirmity                      = { 102032, 458036, 1 }, -- The stack count of Agony is increased by $s1 when applied by Vile Taint.; Enemies damaged by Phantom Singularity take $458219s1% increased damage from you for its duration.
    kindled_malice                 = { 72040, 405330, 2 }, -- Malefic Rapture damage increased by $s1%. $?a445465[Wither][Corruption] damage increased by $s2%.
    malediction                    = { 72046, 453087, 2 }, -- Increases the critical strike chance of Agony, $?a445465[Wither][Corruption], and Unstable Affliction by $s1%.
    malefic_touch                  = { 102030, 458029, 1 }, -- Malefic Rapture deals an additional $458131s1 Shadowflame damage to each target it affects.
    malevolence                    = { 94842, 442726, 1 }, -- Dark magic erupts from you and corrupts your soul for $442726d, causing enemies suffering from your Wither to take $446285s1 Shadowflame damage and increase its stack count by $s1.; While corrupted your Haste is increased by $442726s1% and spending Soul Shards on damaging spells grants $s2 additional stack of Wither.
    malevolent_visionary           = { 71987, 387273, 1 }, -- Increases the damage of your Darkglare by $s1%. When Darkglare extends damage over time effects it also sears affected targets for $453233s1 Shadow damage.
    malign_omen                    = { 72057, 458041, 1 }, -- [458043] Your next Malefic Rapture deals $s1% increased damage and extends the duration of your damage over time effects and Haunt by $s2 sec.
    mark_of_perotharn              = { 94844, 440045, 1 }, -- Critical strike damage dealt by Wither is increased by $s1%. ; Wither has a chance to gain a stack when it critically strikes. Stacks gained this way do not activate Blackened Soul.
    mark_of_xavius                 = { 94834, 440046, 1 }, -- $?s980[Agony damage increased by $s1%.][Wither damage increased by $s2%.]; Blackened Soul deals $s3% increased damage per stack of Wither.
    necrolyte_teachings            = { 94825, 449620, 1 }, -- $?s137043[Shadow Bolt and Drain Soul damage increased by $s2%. Nightfall increases the damage of Shadow Bolt and Drain Soul by an additional $s1%.][Shadow Bolt damage increased by $s2%. Power Siphon increases the damage of Demonbolt by an additional $s3%.]
    nightfall                      = { 72047, 108558, 1 }, -- $?a445465[Wither][Corruption] damage has a chance to cause your next Shadow Bolt or Drain Soul to deal $264571s2% increased damage. ; Shadow Bolt is instant cast and Drain Soul channels $264571s3% faster when affected.
    oblivion                       = { 71986, 417537, 1 }, -- Unleash wicked magic upon your target's soul, dealing $o Shadow damage over $d.; Deals $s2% increased damage, up to ${$s2*$s3}%, per damage over time effect you have active on the target.
    perpetual_unstability          = { 102246, 459376, 1 }, -- The cast time of Unstable Affliction is reduced by $s2%.; Refreshing Unstable Affliction with $s1 or less seconds remaining deals $459461s1 Shadow damage to its target.
    phantom_singularity            = { 102033, 205179, 1 }, -- Places a phantom singularity above the target, which consumes the life of all enemies within $205246A2 yards, dealing ${8*$205246s2} damage over $d, healing you for ${$205246e2*100}% of the damage done.
    quietus                        = { 94846, 449634, 1 }, -- Soul Anathema damage increased by $s1% and is dealt $s2% faster.; Consuming $?s137043[Nightfall][Demonic Core] activates Shared Fate or Feast of Souls.
    ravenous_afflictions           = { 102247, 459440, 1 }, -- Critical strikes from your Agony, $?a445465[Wither][Corruption], and Unstable Affliction have a chance to grant Nightfall.
    relinquished                   = { 72052, 453083, 1 }, -- Agony has 1.$m1 times the normal chance to generate a Soul Shard.
    sacrolashs_dark_strike         = { 72053, 386986, 1 }, -- $?a445465[Wither][Corruption] damage is increased by $s1%, and each time it deals damage any of your Curses active on the target are extended by ${$s2/1000}.1 sec.
    sataiels_volition              = { 94838, 449637, 1 }, -- $?s137043[Corruption deals damage $s1% faster and Haunt grants Nightfall.][Wild Imp damage increased by $s2% and Wild Imps that are imploded have an additional $s3% chance to grant a Demonic Core.]
    seed_of_corruption             = { 72050, 27243 , 1 }, -- Embeds a demon seed in the enemy target that will explode after $d, dealing $27285s1 Shadow damage to all enemies within $27285A1 yards and applying $?a445465[Wither][Corruption] to them.; The seed will detonate early if the target is hit by other detonations, or takes ${$SPS*$s1/100} damage from your spells.
    seeds_of_their_demise          = { 94829, 440055, 1 }, -- After Wither reaches $s1 stacks or when its host reaches $s2% health, Wither deals $445736s1 Shadowflame damage to its host every $445731t1 sec until 1 stack remains.; When Blackened Soul deals damage, you have a chance to gain $?s137046[$s4 stacks of Flashpoint][Tormented Crescendo].
    shadow_embrace                 = { 100940, 32388 , 1 }, -- $?s388667[Drain Soul][Shadow Bolt] applies Shadow Embrace, increasing your damage dealt to the target by $?s388667[$32390s1%][$453206s2%] for $32390d. Stacks up to $?s388667[$32390u][$453206u] times.
    shadow_of_death                = { 94857, 449638, 1 }, -- Your $?s137043[Soul Rot][Summon Demonic Tyrant] spell is empowered by the demonic entity within you, causing it to grant ${$449858s1/10} Soul Shards that each contain a Succulent Soul.
    shared_fate                    = { 94823, 449704, 1 }, -- When you kill a target, its tortured soul is flung into a nearby enemy for $450591d. This effect inflicts $450593s1 Shadow damage to enemies within $450593a1 yds every $450591t1 sec.; Deals reduced damage beyond $s1 targets.
    siphon_life                    = { 72051, 452999, 1 }, -- $?a445465[Wither][Corruption] deals $s1% increased damage and its periodic damage heals you for $s2% of the damage dealt.
    soul_anathema                  = { 94847, 449624, 1 }, -- Unleashing your demonic soul bestows a fiendish entity unto the soul of its targets, dealing $450538o1 Shadow damage over $450538d.; If this effect is reapplied, any remaining damage will be added to the new Soul Anathema.
    soul_rot                       = { 72056, 386997, 1 }, -- Wither away all life force of your current target and up to $s3 additional targets nearby, causing your primary target to suffer ${$o2*(1+$m4/10)} Shadow damage and secondary targets to suffer $o2 Shadow damage over $d.; For the next $d, casting Drain Life will cause you to also Drain Life from any enemy affected by your Soul Rot, and Drain Life will not consume any mana.
    summon_darkglare               = { 72034, 205180, 1 }, -- Summons a Darkglare from the Twisting Nether that extends the duration of your damage over time effects on all enemies by $s2 sec.; The Darkglare will serve you for $d, blasting its target for $205231s1 Shadow damage, increased by $s3% for every damage over time effect you have active on their current target.
    summoners_embrace              = { 72037, 453105, 1 }, -- Increases the damage dealt by your spells and your demon by $s1%.
    tormented_crescendo            = { 72031, 387075, 1 }, -- While Agony, $?a445465[Wither][Corruption], and Unstable Affliction are active, your Shadow Bolt has a $s1% chance and your Drain Soul has a $s2% chance to make your next Malefic Rapture cost no Soul Shards and cast instantly.
    unstable_affliction            = { 72049, 316099, 1 }, -- Afflicts one target with $o2 Shadow damage over $d. ; If dispelled, deals ${$m2*$s1/100} damage to the dispeller and silences them for $196364d.$?s231791[; Generates $231791m1 Soul $LShard:Shards; if the target dies while afflicted.][]
    vile_taint                     = { 102033, 278350, 1 }, -- Unleashes a vile explosion at the target location, dealing $386931o1 Shadow damage over $386931d to $s2 enemies within $a1 yds and applies Agony and Curse of Exhaustion to them.
    volatile_agony                 = { 72039, 453034, 1 }, -- Refreshing Agony with $s1 or less seconds remaining deals $453035s1 Shadow damage to its target and enemies within $453035a1 yards.; Deals reduced damage beyond $s2 targets.
    wicked_reaping                 = { 94821, 449631, 1 }, -- Damage dealt by your demonic soul is increased by $s1%.; Consuming $?s137043[Nightfall][Demonic Core] feeds the demonic entity within you, causing it to appear and deal $?s137043[$449826s1][${$449826s1*($s2/100)}] Shadow damage to your target.
    wither                         = { 94840, 445468, 1 }, -- [445468] Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing $s1 Shadowflame damage immediately and an additional $445474o1 Shadowflame damage over $445474d.$?s137046[; Periodic damage generates 1 Soul Shard Fragment and has a $s2% chance to generate an additional 1 on critical strikes.; Replaces Immolate.][; Replaces Corruption.]
    withering_bolt                 = { 72055, 386976, 1 }, -- Shadow Bolt and Drain Soul deal $s1% increased damage, up to ${$s1*$s2}%, per damage over time effect you have active on the target.
    writhe_in_agony                = { 72048, 196102, 1 }, -- Agony's damage starts at $s3 stacks and may now ramp up to $s2 stacks.
    xalans_cruelty                 = { 94845, 440040, 1 }, -- Shadow damage dealt by your spells and abilities is increased by $s3% and your Shadow spells gain $s1% more critical strike chance from all sources.
    xalans_ferocity                = { 94853, 440044, 1 }, -- Fire damage dealt by your spells and abilities is increased by $s1% and your Fire spells gain $s4% more critical strike chance from all sources.
    xavius_gambit                  = { 71921, 416615, 1 }, -- Unstable Affliction deals $s1% increased damage.
    zevrims_resilience             = { 94835, 440065, 1 }, -- Dark Pact heals you for $108416s5 every $108416t5 sec while active.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bonds_of_fel        = 5546, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the $a2 yd radius they explode, dealing $353813s1 Fire damage split amongst all nearby enemies.
    call_observer       = 5543, -- (201996) Summons a demonic Observer to keep a watchful eye over the area for $d.; Anytime an enemy within $m2 yards casts a harmful magical spell, the Observer will deal up to $212529s2% of the target's maximum health in Shadow damage.
    essence_drain       = 19  , -- (221711) Whenever you heal yourself with Drain Life, the enemy target deals $221715m1% reduced damage to you for $221715d. Stacks up to $221715u times.
    gateway_mastery     = 15  , -- (248855) Increases the range of your Demonic Gateway by $s1 yards, and reduces the cast time by $s2%.  Reduces the time between how often players can take your Demonic Gateway by $s3 sec.
    impish_instincts    = 5579, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by ${$s1/-1000} sec.; Cannot occur more than once every $proccooldown sec.
    jinx                = 5386, -- (426352) Casting a curse now applies Corruption and Agony to your target, but curses now costs ${$s1/10} Soul $LShard:Shards;.
    nether_ward         = 18  , -- (212295) Surrounds the caster with a shield that lasts $d, reflecting all harmful spells cast on you.
    rampant_afflictions = 5379, -- (335052) Unstable Affliction can now be applied to up to $s3 targets, but its damage is reduced by $s2%.
    rot_and_decay       = 16  , -- (212371) Shadow Bolt damage increases the duration of your Unstable Affliction, Corruption, Agony, and Siphon Life on the target by ${$s2/1000}.1 sec.; Drain Life, Drain Soul, and Oblivion damage increases the duration of your Unstable Affliction, Corruption, Agony, and Siphon Life on the target by ${$s1/1000}.1 sec.; 
    shadow_rift         = 5392, -- (353294) Conjure a Shadow Rift at the target location lasting $d. Enemy players within the rift when it expires are teleported to your Demonic Circle.; Must be within $s2 yds of your Demonic Circle to cast.
    soul_rip            = 5608, -- (410598) Fracture the soul of up to $i target players within $r yds into the shadows, reducing their damage done by $s1% and healing received by $s3% for $d. Souls are fractured up to $410615a yds from the player's location.; Players can retrieve their souls to remove this effect.
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
    -- Suffering $w1 Shadow damage every $t1 sec. Damage increases over time.
    agony = {
        id = 980,
        duration = 18.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- agony[231792] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- socrethars_guile[405936] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- socrethars_guile[405936] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- mark_of_xavius[440046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- writhe_in_agony[196102] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
    -- Suffering $w1 Shadow damage every $t1 sec.
    corruption = {
        id = 146739,
        duration = 14.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 26.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavian_teachings[317031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- kindled_malice[405330] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- kindled_malice[405330] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- sacrolashs_dark_strike[386986] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sataiels_volition[449637] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- siphon_life[452999] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- siphon_life[452999] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither[445465] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 445468, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Time between attacks increased by $w1%. $?e1[Chance to critically strike reduced by $w2%.][]
    curse_of_weakness = {
        id = 702,
        duration = 120.0,
        max_stack = 1,

        -- Affected by:
        -- amplify_curse[328774] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- curse_of_the_satyr[440057] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 442804, 'target': TARGET_UNIT_CASTER, }
        -- jinx[426352] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
    },
    -- Haste increased by ${$W1}.1%.; Critical strike chance increased by ${$W2}.1%.
    dark_harvest = {
        id = 387018,
        duration = 8.0,
        max_stack = 1,
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
    -- Suffering $s1 Shadow damage every $t1 seconds.; Restoring health to the Warlock.
    drain_life = {
        id = 234153,
        duration = 5.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- soul_rot[386998] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
    -- Damage dealt to the Warlock reduced by $w1%.
    essence_drain = {
        id = 221715,
        duration = 10.0,
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
    -- Taking $s2% increased damage from the Warlock. Haunt's cooldown will be reset on death.
    haunt = {
        id = 48181,
        duration = 18.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_haunt[458034] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_haunt[458034] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
    },
    -- Damage taken increased by $s1%.
    infirmity = {
        id = 458219,
        duration = 3600,
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
    -- Your next Malefic Rapture deals $s1% increased damage and extends the duration of your damage over time effects and Haunt by $s2 sec.
    malign_omen = {
        id = 458043,
        duration = 30.0,
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
    -- Your next $?s198590[Drain Soul drains $s3% faster and][Shadow Bolt is instant and] deals $s2% increased damage.
    nightfall = {
        id = 264571,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- necrolyte_teachings[449620] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Dealing $s1 Shadow damage to the target every $t1 sec.
    oblivion = {
        id = 417537,
        duration = 3.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Dealing damage to all nearby targets every $t1 sec and healing the casting Warlock.
    phantom_singularity = {
        id = 205179,
        duration = 16.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Embeded with a demon seed that will soon explode, dealing Shadow damage to the caster's enemies within $27285A1 yards, and applying Corruption to them.; The seed will detonate early if the target is hit by other detonations, or takes $w3 damage from your spells.
    seed_of_corruption = {
        id = 27243,
        duration = 12.0,
        tick_time = 12.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Damage taken from $@auracaster increased by ${$W1}.1%.
    shadow_embrace = {
        id = 32390,
        duration = 16.0,
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
    -- Suffering $w1 Shadow damage every $t1 sec and siphoning life to the casting Warlock.
    siphon_life = {
        id = 63106,
        duration = 15.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Dealing $o1 Shadow damage over $d.
    soul_anathema = {
        id = 450538,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    },
    -- Damage done reduced by $s1%.and healing received reduced by $s3%. Retrieve your soul to remove this effect.
    soul_rip = {
        id = 410598,
        duration = 8.0,
        max_stack = 1,
    },
    -- Mana cost of Drain Life reduced by $s1%.
    soul_rot = {
        id = 386998,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deadwind_harvester[216708] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
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
    -- Summons a Darkglare from the Twisting Nether that blasts its target for Shadow damage, dealing increased damage for every damage over time effect you have active on their current target.
    summon_darkglare = {
        id = 205180,
        duration = 20.0,
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
    -- Silenced.
    unstable_affliction = {
        id = 196364,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Suffering $w1 Shadow damage every $t1 sec.
    vile_taint = {
        id = 386931,
        duration = 10.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Suffering $w1 Shadowflame damage every $t1 sec.$?a339892[ ; Damage taken by Chaos Bolt and Incinerate increased by $w2%.][]
    wither = {
        id = 445474,
        duration = 18.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 26.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavian_teachings[317031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- socrethars_guile[405936] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bleakheart_tactics[440051] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- hatefury_rituals[440048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hatefury_rituals[440048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- kindled_malice[405330] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- kindled_malice[405330] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mark_of_xavius[440046] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sacrolashs_dark_strike[386986] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sataiels_volition[449637] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- siphon_life[452999] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- siphon_life[452999] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
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

    -- Inflicts increasing agony on the target, causing up to ${$s1*$d/$t1*$u} Shadow damage over $d. Damage starts low and increases over the duration. Refreshing Agony maintains its current damage level.; Agony damage sometimes generates 1 Soul Shard.
    agony = {
        id = 980,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 0.0170247, 'pvp_multiplier': 1.25, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- agony[231792] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- socrethars_guile[405936] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- socrethars_guile[405936] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- mark_of_xavius[440046] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- writhe_in_agony[196102] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 26.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavian_teachings[317031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- kindled_malice[405330] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- kindled_malice[405330] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- sacrolashs_dark_strike[386986] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sataiels_volition[449637] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- siphon_life[452999] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- siphon_life[452999] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- jinx[426352] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
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
        -- soul_rot[386998] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
        -- eternal_servitude[449707] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -90000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

    -- A ghostly soul haunts the target, dealing $s1 Shadow damage and increasing your damage dealt to the target by $s2% for $d.; If the target dies, Haunt's cooldown is reset.
    haunt = {
        id = 48181,
        cast = 1.5,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "haunt",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.74519, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_MASK_DAMAGE_FROM_CASTER, 'points': 10.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_TAKEN_FROM_CASTER_PET, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_haunt[458034] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_haunt[458034] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
    },

    -- Your damaging periodic effects from your spells erupt on all targets, causing $324540s1 Shadowflame damage per effect.
    malefic_rapture = {
        id = 324536,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ['Is Harmful'], 'sp_bonus': 0.31625, 'radius': 100.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- improved_malefic_rapture[454378] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
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

    -- Unleash wicked magic upon your target's soul, dealing $o Shadow damage over $d.; Deals $s2% increased damage, up to ${$s2*$s3}%, per damage over time effect you have active on the target.
    oblivion = {
        id = 417537,
        cast = 3.0,
        channeled = true,
        cooldown = 45.0,
        gcd = "global",

        spend = 20,
        spendType = 'soul_shards',

        talent = "oblivion",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'sp_bonus': 4.02325, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 10.0, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 3.0, }
    },

    -- Places a phantom singularity above the target, which consumes the life of all enemies within $205246A2 yards, dealing ${8*$205246s2} damage over $d, healing you for ${$205246e2*100}% of the damage done.
    phantom_singularity = {
        id = 205179,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "phantom_singularity",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_LEECH, 'amplitude': 0.25, 'tick_time': 2.0, 'sp_bonus': 0.27225, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Embeds a demon seed in the enemy target that will explode after $d, dealing $27285s1 Shadow damage to all enemies within $27285A1 yards and applying $?a445465[Wither][Corruption] to them.; The seed will detonate early if the target is hit by other detonations, or takes ${$SPS*$s1/100} damage from your spells.
    seed_of_corruption = {
        id = 27243,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        talent = "seed_of_corruption",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 12.0, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'attributes': ['Compute Points Only At Cast Time'], 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sargerei_technique[405955] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_virtuosity[405327] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- drain_soul[388667] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 198590, 'value': 686, 'schools': ['holy', 'fire', 'nature', 'shadow'], 'value1': 2, 'target': TARGET_UNIT_CASTER, }
        -- improved_shadow_bolt[453080] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- improved_shadow_bolt[453080] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- necrolyte_teachings[449620] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nightfall[264571] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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

    -- Siphons the target's life essence, dealing $o1 Shadow damage over $d and healing you for ${$e1*100}% of the damage done.
    siphon_life = {
        id = 63106,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_LEECH, 'amplitude': 0.3, 'tick_time': 3.0, 'sp_bonus': 0.165, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- summoners_embrace[453105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summoners_embrace[453105] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demonology_warlock[137044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demonology_warlock[137044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- infirmity[458219] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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

    -- Wither away all life force of your current target and up to $s3 additional targets nearby, causing your primary target to suffer ${$o2*(1+$m4/10)} Shadow damage and secondary targets to suffer $o2 Shadow damage over $d.; For the next $d, casting Drain Life will cause you to also Drain Life from any enemy affected by your Soul Rot, and Drain Life will not consume any mana.
    soul_rot = {
        id = 386997,
        cast = 1.5,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        talent = "soul_rot",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Always AOE Line of Sight'], 'tick_time': 2.0, 'sp_bonus': 0.3025, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deadwind_harvester[216708] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },

    -- Wither away all life force of your current target and up to $s3 additional targets nearby, causing your primary target to suffer ${$o2*(1+$m4/10)} Nature damage and secondary targets to suffer $o2 Nature damage over $d.; For the next $d, casting Drain Life will cause you to also Drain Life from any enemy affected by your Soul Rot, and Drain Life will not consume any mana.
    soul_rot_325640 = {
        id = 325640,
        color = 'night_fae',
        cast = 1.5,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Always AOE Line of Sight'], 'tick_time': 2.0, 'sp_bonus': 0.25, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deadwind_harvester[216708] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        from = "affected_by_mastery",
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

    -- Summons a Darkglare from the Twisting Nether that extends the duration of your damage over time effects on all enemies by $s2 sec.; The Darkglare will serve you for $d, blasting its target for $205231s1 Shadow damage, increased by $s3% for every damage over time effect you have active on their current target.
    summon_darkglare = {
        id = 205180,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "summon_darkglare",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 103673, 'schools': ['physical', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 3766, 'radius': 3.0, 'target': TARGET_DEST_CASTER_RIGHT, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 8.0, 'radius': 3.0, 'target': TARGET_DEST_CASTER_RIGHT, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
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

    -- Afflicts one target with $o2 Shadow damage over $d. ; If dispelled, deals ${$m2*$s1/100} damage to the dispeller and silences them for $196364d.$?s231791[; Generates $231791m1 Soul $LShard:Shards; if the target dies while afflicted.][]
    unstable_affliction = {
        id = 316099,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "unstable_affliction",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 0.30613, 'pvp_multiplier': 1.4, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[334315] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- perpetual_unstability[459376] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavius_gambit[416615] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavius_gambit[416615] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rampant_afflictions[335052] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 342938, 'value': 316099, 'schools': ['physical', 'holy', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- rampant_afflictions[335052] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Afflicts the target with $233490o1 Shadow damage over $233490d. You may afflict a target with up to $s2 Unstable Afflictions at once.; You deal $s3% increased damage to targets affected by your Unstable Affliction.; If dispelled, deals ${$233490s1*$s1/100} damage to the dispeller and silences them for $196364d.$?a231791[; Refunds $231791m1 Soul $LShard:Shards; if the target dies while afflicted.][]
    unstable_affliction_30108 = {
        id = 30108,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[334315] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- perpetual_unstability[459376] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavius_gambit[416615] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavius_gambit[416615] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rampant_afflictions[335052] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 342938, 'value': 316099, 'schools': ['physical', 'holy', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- rampant_afflictions[335052] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "affected_by_mastery",
    },

    -- Afflicts up to $335052s3 targets with $o2 Shadow damage over $d. ; If dispelled, deals ${$s1*$SP/100} damage to the dispeller and silences them for $196364d.; Generates $231791m1 Soul $LShard:Shards; if the target dies while afflicted.
    unstable_affliction_342938 = {
        id = 342938,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 0.30613, 'pvp_multiplier': 1.15702, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[334315] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- perpetual_unstability[459376] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavius_gambit[416615] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavius_gambit[416615] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rampant_afflictions[335052] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 342938, 'value': 316099, 'schools': ['physical', 'holy', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- rampant_afflictions[335052] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "affected_by_mastery",
    },

    -- Unleashes a vile explosion at the target location, dealing $386931o1 Shadow damage over $386931d to $s2 enemies within $a1 yds and applies Agony and Curse of Exhaustion to them.
    vile_taint = {
        id = 278350,
        cast = 1.5,
        cooldown = 30.0,
        gcd = "global",

        spend = 10,
        spendType = 'soul_shards',

        talent = "vile_taint",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_potent_afflictions[77215] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_potent_afflictions[77215] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- affliction_warlock[137043] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- affliction_warlock[137043] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 26.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xavian_teachings[317031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- socrethars_guile[405936] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bleakheart_tactics[440051] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- contagion[453096] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- creeping_death[264000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- kindled_malice[405330] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- kindled_malice[405330] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- malediction[453087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mark_of_xavius[440046] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sacrolashs_dark_strike[386986] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sataiels_volition[449637] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- siphon_life[452999] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- siphon_life[452999] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unstable_affliction[316099] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- wither[445465] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 445468, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- wither[445465] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

} )