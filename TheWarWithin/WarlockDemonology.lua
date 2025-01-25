-- WarlockDemonology.lua
-- July 2024

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local PTR = ns.PTR

local FindPlayerAuraByID, FindUnitBuffByID, FindUnitDebuffByID = ns.FindPlayerAuraByID, ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local abs, ceil, strformat = math.abs, math.ceil, string.format

local GetSpellInfo = ns.GetUnpackedSpellInfo

local RC = LibStub( "LibRangeCheck-3.0" )


local spec = Hekili:NewSpecialization( 266 )
local GetSpellCount = C_Spell.GetSpellCastCount

spec:RegisterResource( Enum.PowerType.SoulShards )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Warlock
    abyss_walker                   = {  71954, 389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by 4% for 10 sec.
    accrued_vitality               = {  71953, 386613, 2 }, -- Drain Life heals for 15% of the amount drained over 7.6 sec.
    amplify_curse                  = {  71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    banish                         = {  71944,    710, 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = {  71949, 111400, 1 }, -- Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    curses_of_enfeeblement         = {  71951, 386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    dark_accord                    = {  71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by 45 sec.
    dark_pact                      = {  71936, 108416, 1 }, -- Sacrifices 5% of your current health to shield you for 800% of the sacrificed health plus an additional 39,952 for 20 sec. Usable while suffering from control impairing effects.
    darkfury                       = {  71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by 15 sec and increases its radius by 2 yards.
    demon_skin                     = {  71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of 0.2% of maximum health every 1 sec, and may now absorb up to 10% of maximum health. Increases your armor by 45%.
    demonic_circle                 = { 100941, 268358, 1 }, -- Summons a Demonic Circle for 15 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects.
    demonic_embrace                = {  71930, 288843, 1 }, -- Stamina increased by 10%.
    demonic_fortitude              = {  71922, 386617, 1 }, -- Increases you and your pets' maximum health by 5%.
    demonic_gateway                = {  71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 90 sec.
    demonic_inspiration            = {  71928, 386858, 1 }, -- Increases the attack speed of your primary pet by 5%.
    demonic_resilience             = {  71917, 389590, 2 }, -- Reduces the chance you will be critically struck by 2%. All damage your primary demon takes is reduced by 8%.
    demonic_tactics                = {  71925, 452894, 1 }, -- Your spells have a 5% increased chance to deal a critical strike. You gain 10% more of the Critical Strike stat from all sources.
    fel_armor                      = {  71950, 386124, 2 }, -- When Soul Leech absorbs damage, 5% of damage taken is absorbed and spread out over 5 sec. Reduces damage taken by 1.5%.
    fel_domination                 = {  71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 90%.
    fel_pact                       = {  71932, 386113, 1 }, -- Reduces the cooldown of Fel Domination by 60 sec.
    fel_synergy                    = {  71924, 389367, 2 }, -- Soul Leech also heals you for 8% and your pet for 25% of the absorption it grants.
    fiendish_stride                = {  71948, 386110, 1 }, -- Reduces the damage dealt by Burning Rush by 10%. Burning Rush increases your movement speed by an additional 20%.
    frequent_donor                 = {  71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by 15 sec.
    horrify                        = {  71916,  56244, 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear.
    howl_of_terror                 = {  71947,   5484, 1 }, -- Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    ichor_of_devils                = {  71937, 386664, 1 }, -- Dark Pact sacrifices only 5% of your current health for the same shield value.
    lifeblood                      = {  71940, 386646, 2 }, -- When you use a Healthstone, gain 4% Leech for 20 sec.
    mortal_coil                    = {  71947,   6789, 1 }, -- Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    nightmare                      = {  71916, 386648, 1 }, -- Increases the amount of damage required to break your fear effects by 60%.
    pact_of_gluttony               = {  71926, 386689, 1 }, -- Healthstones you conjure for yourself are now Demonic Healthstones and can be used multiple times in combat. Demonic Healthstones cannot be traded.  Demonic Healthstone Instantly restores 35% health. 60 sec cooldown.
    resolute_barrier               = {  71915, 389359, 2 }, -- Attacks received that deal at least 5% of your health decrease Unending Resolve's cooldown by 10 sec. Cannot occur more than once every 30 sec.
    sargerei_technique             = {  93179, 405955, 2 }, -- Shadow Bolt damage increased by 8%.
    shadowflame                    = {  71941, 384069, 1 }, -- Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowfury                     = {  71942,  30283, 1 }, -- Stuns all enemies within 8 yds for 3 sec.
    socrethars_guile               = {  93178, 405936, 2 }, -- Wild Imp damage increased by 10%.
    soul_conduit                   = {  71939, 215941, 1 }, -- Every Soul Shard you spend has a 5% chance to be refunded.
    soul_leech                     = {  71933, 108370, 1 }, -- All single-target damage done by you and your minions grants you and your pet shadowy shields that absorb 3% of the damage dealt, up to 10% of maximum health.
    soul_link                      = {  71923, 108415, 2 }, -- 5% of all damage you take is taken by your demon pet instead.
    soulburn                       = {  71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by 50% and makes you immune to snares and roots for 6 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for 30 sec. This shield cannot exceed 30% of your maximum health. Health Funnel: Restores 140% more health and reduces the damage taken by your pet by 30% for 10 sec. Healthstone: Increases the healing of your Healthstone by 30% and increases your maximum health by 20% for 12 sec.
    strength_of_will               = {  71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional 15%.
    sweet_souls                    = {  71927, 386620, 1 }, -- Your Healthstone heals you for an additional 10% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    swift_artifice                 = {  71918, 452902, 1 }, -- Reduces the cast time of Soulstone and Create Healthstone by 50%.
    teachings_of_the_black_harvest = {  71938, 385881, 1 }, -- Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target 4% damage reduction for 5 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by 30 sec. Felhunter: Reduces the cooldown of Devour Magic by 5 sec. Sayaad: Reduces the cooldown of Seduction by 10 sec and causes the target to walk faster towards the demon. Felguard: Reduces the cooldown of Pursuit by 5 sec and increases its maximum range by 5 yards.
    teachings_of_the_satyr         = {  71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by 15 sec.
    wrathful_minion                = {  71946, 386864, 1 }, -- Increases the damage done by your primary pet by 5%.

    -- Soul Harvester
    annihilan_training             = { 101884, 386174, 1 }, -- Your Felguard deals 20% more damage and takes 10% less damage.
    antoran_armaments              = { 101913, 387494, 1 }, -- Your Felguard deals 20% additional damage. Soul Strike now deals 25% of its damage to nearby enemies.
    bilescourge_bombers            = { 101890, 267211, 1 }, -- Tear open a portal to the nether above the target location, from which several Bilescourge will pour out of and crash into the ground over 6 sec, dealing 6,208 Shadow damage to all enemies within 8 yards.
    blood_invocation               = { 101904, 455576, 1 }, -- Power Siphon increases the damage of Demonbolt by an additional 25%.
    call_dreadstalkers             = { 101894, 104316, 1 }, -- Summons 2 ferocious Dreadstalkers to attack the target for 12 sec.
    carnivorous_stalkers           = { 101887, 386194, 1 }, -- Your Dreadstalkers' attacks have a 10% chance to trigger an additional Dreadbite.
    demoniac                       = { 101891, 426115, 1 }, -- Grants access to the following abilities:  Demonbolt Send the fiery soul of a fallen demon at the enemy, causing 41,590 Shadowflame damage. Generates 2 Soul Shards.  Demonic Core When your Wild Imps expend all of their energy or are imploded, you have a 10% chance to absorb their life essence, granting you a stack of Demonic Core. When your summoned Dreadstalkers fade away, you have a 50% chance to absorb their life essence, granting you a stack of Demonic Core. Demonic Core reduces the cast time of Demonbolt by 100%. Maximum 4 stacks.
    demonic_brutality              = { 101920, 453908, 1 }, -- Critical strikes from your spells and your demons deal 4% increased damage.
    demonic_calling                = { 101903, 205145, 1 }, -- Shadow Bolt and Demonbolt have a 10% chance to make your next Call Dreadstalkers cost 2 fewer Soul Shards and have no cast time.
    demonic_strength               = { 101890, 267171, 1 }, -- Infuse your Felguard with demonic strength and command it to charge your target and unleash a Felstorm that will deal 300% increased damage.
    doom                           = { 101919, 460551, 1 }, -- When Demonbolt consumes a Demonic Core it inflicts impending doom upon the target, dealing 59,325 Shadow damage to enemies within 10 yds of its target after 20 sec or when removed. Damage is reduced beyond 8 targets. Consuming a Demonic Core reduces the duration of Doom by 2 sec.
    doom_eternal                   = { 101906, 455585, 1 }, -- Demonic Cores reduce the duration of Doom by an additional 2 sec.
    dread_calling                  = { 101889, 387391, 1 }, -- Each Soul Shard spent on Hand of Gul'dan increases the damage of your next Call Dreadstalkers by 2%.
    dreadlash                      = { 101888, 264078, 1 }, -- When your Dreadstalkers charge into battle, their Dreadbite attack now hits all targets within 8 yards and deals 10% more damage.
    fel_invocation                 = { 101897, 428351, 1 }, -- Soul Strike deals 20% increased damage and generates a Soul Shard.
    fel_sunder                     = { 101911, 387399, 1 }, -- Each time Felstorm deals damage, it increases the damage the target takes from you and your pets by 1% for 8 sec, up to 5%.
    fiendish_oblation              = { 101912, 455569, 1 }, -- Damage dealt by Grimoire: Felguard is increased by an additional 10% and you gain a Demonic Core when Grimoire: Felguard ends.
    flametouched                   = { 101909, 453699, 1 }, -- Increases the attack speed of your Dreadstalkers by 10% and their critical strike chance by 15%.
    foul_mouth                     = { 101918, 455502, 1 }, -- Increases Vilefiend damage by 20% and your Vilefiend's Bile Spit now applies Wicked Maw.
    grimoire_felguard              = { 101907, 111898, 1 }, -- Summons a Felguard who attacks the target for 17 sec that deals 45% increased damage. This Felguard will stun and interrupt their target when summoned.
    guillotine                     = { 101896, 386833, 1 }, -- Your Felguard hurls his axe towards the target location, erupting when it lands and dealing 6,367 Shadowflame damage every 1 sec for 6 sec to nearby enemies. While unarmed, your Felguard's basic attacks deal damage to all nearby enemies and attacks 50% faster.
    immutable_hatred               = { 101896, 405670, 1 }, -- When you consume a Demonic Core, your primary Felguard carves your target, dealing 8,361 Physical damage.
    imp_gang_boss                  = { 101922, 387445, 1 }, -- Summoning a Wild Imp has a 15% chance to summon a Imp Gang Boss instead. An Imp Gang Boss deals 50% additional damage. Implosions from Imp Gang Boss deal 50% increased damage.
    impending_doom                 = { 101885, 455587, 1 }, -- Increases the damage of Doom by 30% and Doom summons 1 Wild Imp when it expires.
    imperator                      = { 101923, 416230, 1 }, -- Increases the critical strike chance of your Wild Imp's Fel Firebolt by 15%.
    implosion                      = { 101893, 196277, 1 }, -- Demonic forces suck all of your Wild Imps toward the target, and then cause them to violently explode, dealing 11,738 Shadowflame damage to all enemies within 8 yards.
    improved_demonic_tactics       = { 101892, 453800, 1 }, -- Increases your primary Felguard's critical strike chance equal to 30% of your critical strike chance.
    inner_demons                   = { 101925, 267216, 1 }, -- You passively summon a Wild Imp to fight for you every 12 sec.
    mark_of_fharg                  = { 101895, 455450, 1 }, -- Your Summon Vilefiend becomes Summon Charhound and learns the following ability:  Infernal Presence Cloaked in the ever-burning flames of the abyss, dealing 2,714 Fire damage to enemies within 10 yards every 0.8 sec.
    mark_of_shatug                 = { 101895, 455449, 1 }, -- Your Summon Vilefiend becomes Summon Gloomhound and learns the following ability:  Gloom Slash Tooth and claw are drenched in malignant shadow magic, causing the Gloomhound's melee attacks to deal an additional 3,458 Shadow damage.
    pact_of_the_eredruin           = { 101917, 453568, 1 }, -- When Doom expires, you have a chance to summon a Doomguard that casts 5 Doom Bolts before departing. Each Doom Bolt deals 36,709 Shadow damage.
    pact_of_the_imp_mother         = { 101924, 387541, 1 }, -- Hand of Gul'dan has a 15% chance to cast a second time on your target for free.
    power_siphon                   = { 101916, 264130, 1 }, -- Instantly sacrifice up to 2 Wild Imps, generating 2 charges of Demonic Core that cause Demonbolt to deal 30% additional damage.
    reign_of_tyranny               = { 101908, 427684, 1 }, -- Summon Demonic Tyrant empowers 5 additional Wild Imps and deals 10% increased damage for each demon he empowers.
    rune_of_shadows                = { 101914, 453744, 1 }, -- Increases all damage done by your pet by 4%. Reduces the cast time of Shadow Bolt by 25% and increases its damage by 40%.
    sacrificed_souls               = { 101886, 267214, 1 }, -- Shadow Bolt and Demonbolt deal 2% additional damage per demon you have summoned.
    shadow_invocation              = { 101921, 422054, 1 }, -- Bilescourge Bombers deal 20% increased damage, and your spells now have a chance to summon a Bilescourge Bomber.
    shadowtouched                  = { 101910, 453619, 1 }, -- Wicked Maw causes the target to take 20% additional Shadow damage from your demons.
    soul_strike                    = { 101899, 428344, 1 }, -- Teaches your primary Felguard the following ability:  Soul Strike Strike into the soul of the enemy, dealing 12,934 Shadow damage. Generates 1 Soul Shard.
    spiteful_reconstitution        = { 101901, 428394, 1 }, -- Implosion deals 10% increased damage. Consuming a Demonic Core has a chance to summon a Wild Imp.
    summon_demonic_tyrant          = { 101905, 265187, 1 }, -- Summon a Demonic Tyrant to increase the duration of your Dreadstalkers, Vilefiend, Felguard, and up to 15 of your Wild Imps by 15 sec. Your Demonic Tyrant increases the damage of affected demons by 15%, while damaging your target.
    summon_vilefiend               = { 101900, 264119, 1 }, -- Summon a Vilefiend to fight for you for the next 15 sec.
    the_expendables                = { 101902, 387600, 1 }, -- When your Wild Imps expire or die, your other demons are inspired and gain 1% additional damage, stacking up to 10 times.
    the_houndmasters_gambit        = { 101898, 455572, 1 }, -- Your Dreadstalkers deal 50% increased damage while your Vilefiend is active.
    umbral_blaze                   = { 101915, 405798, 1 }, -- Hand of Gul'dan has a 15% chance to burn its target for 16,307 additional Shadowflame damage every 2 sec for 6 sec. If this effect is reapplied, any remaining damage will be added to the new Umbral Blaze.
    wicked_maw                     = { 101926, 267170, 1 }, -- Dreadbite causes the target to take 20% additional Shadowflame damage from your spell and abilities for the next 12 sec.

    -- Diabolist
    abyssal_dominion               = {  94831, 429581, 1 }, -- Summon Demonic Tyrant is empowered, dealing 70% increased damage and increasing the damage of your demons by 20% while active.
    annihilans_bellow              = {  94836, 429072, 1 }, -- Howl of Terror cooldown is reduced by 15 sec and range is increased by 5 yds.
    cloven_souls                   = {  94849, 428517, 1 }, -- Enemies damaged by your Overlord have their souls cloven, increasing damage taken by you and your pets by 5% for 15 sec.
    cruelty_of_kerxan              = {  94848, 429902, 1 }, -- Summon Demonic Tyrant grants Diabolic Ritual and reduces its duration by 3 sec.
    diabolic_ritual                = {  94855, 428514, 1, "diabolist" }, -- Spending a Soul Shard on a damaging spell grants Diabolic Ritual for 20 sec. While Diabolic Ritual is active, each Soul Shard spent on a damaging spell reduces its duration by 1 sec. When Diabolic Ritual expires you gain Demonic Art, causing your next Hand of Gul'dan to summon an Overlord, Mother of Chaos, or Pit Lord that unleashes a devastating attack against your enemies.
    flames_of_xoroth               = {  94833, 429657, 1 }, -- Fire damage increased by 2% and damage dealt by your demons is increased by 2%.
    gloom_of_nathreza              = {  94843, 429899, 1 }, -- Hand of Gul'dan deals 15% increased damage for each Soul Shard spent.
    infernal_bulwark               = {  94852, 429130, 1 }, -- Unending Resolve grants Soul Leech equal to 10% of your maximum health and increases the maximum amount Soul Leech can absorb by 10% for 8 sec.
    infernal_machine               = {  94848, 429917, 1 }, -- Spending Soul Shards on damaging spells while your Demonic Tyrant is active decreases the duration of Diabolic Ritual by 1 additional sec.
    infernal_vitality              = {  94852, 429115, 1 }, -- Unending Resolve heals you for 30% of your maximum health over 10 sec.
    ruination                      = {  94830, 428522, 1 }, -- Summoning a Pit Lord causes your next Hand of Gul'dan to become Ruination.  Ruination Call down a demon-infested meteor from the depths of the Twisting Nether, dealing 191,536 Chaos damage on impact to all enemies within 8 yds of the target and summoning 3 Wild Imps. Damage is reduced beyond 8 targets. Consuming a Demonic Core reduces the duration of Doom by 2 sec.
    secrets_of_the_coven           = {  94826, 428518, 1 }, -- Mother of Chaos empowers your next Shadow Bolt to become Infernal Bolt.  Infernal Bolt Hurl a bolt enveloped in the infernal flames of the abyss, dealing 167,303 Fire damage to your enemy target and generating 3 Soul Shards.
    souletched_circles             = {  94836, 428911, 1 }, -- You always gain the benefit of Soulburn when casting Demonic Circle: Teleport, increasing your movement speed by 50% and making you immune to snares and roots for 6 sec.
    touch_of_rancora               = {  94856, 429893, 1 }, -- Demonic Art increases the damage of your next Hand of Gul'dan by 100% and reduces its cast time by 50%.

    -- Soul Harvester
    demoniacs_fervor               = {  94832, 449629, 1 }, -- Your demonic soul deals 100% increased damage to the main target of Hand of Gul'dan.
    demonic_soul                   = {  94851, 449614, 1, "soul_harvester" }, -- A demonic entity now inhabits your soul, allowing you to detect if a Soul Shard has a Succulent Soul when it's generated. A Succulent Soul empowers your next Hand of Gul'dan, increasing its damage by 60%, and unleashing your demonic soul to deal an additional 39,730 Shadow damage.
    eternal_servitude              = {  94824, 449707, 1 }, -- Fel Domination cooldown is reduced by 90 sec.
    feast_of_souls                 = {  94823, 449706, 1 }, -- When you kill a target, you have a chance to generate a Soul Shard that is guaranteed to be a Succulent Soul.
    friends_in_dark_places         = {  94850, 449703, 1 }, -- Dark Pact now shields you for an additional 50% of the sacrificed health.
    gorebound_fortitude            = {  94850, 449701, 1 }, -- You always gain the benefit of Soulburn when consuming a Healthstone, increasing its healing by 30% and increasing your maximum health by 20% for 12 sec.
    gorefiends_resolve             = {  94824, 389623, 1 }, -- Targets resurrected with Soulstone resurrect with 40% additional health and 80% additional mana.
    necrolyte_teachings            = {  94825, 449620, 1 }, -- Shadow Bolt damage increased by 20%. Power Siphon increases the damage of Demonbolt by an additional 20%.
    quietus                        = {  94846, 449634, 1 }, -- Soul Anathema damage increased by 25% and is dealt 20% faster. Consuming Demonic Core activates Shared Fate or Feast of Souls.
    sataiels_volition              = {  94838, 449637, 1 }, -- Wild Imp damage increased by 5% and Wild Imps that are imploded have an additional 5% chance to grant a Demonic Core.
    shadow_of_death                = {  94857, 449638, 1 }, -- Your Summon Demonic Tyrant spell is empowered by the demonic entity within you, causing it to grant 3 Soul Shards that each contain a Succulent Soul.
    shared_fate                    = {  94823, 449704, 1 }, -- When you kill a target, its tortured soul is flung into a nearby enemy for 3 sec. This effect inflicts 8,601 Shadow damage to enemies within 10 yds every 0.8 sec. Deals reduced damage beyond 8 targets.
    soul_anathema                  = {  94847, 449624, 1 }, -- Unleashing your demonic soul bestows a fiendish entity unto the soul of its targets, dealing 37,775 Shadow damage over 10 sec. If this effect is reapplied, any remaining damage will be added to the new Soul Anathema.
    wicked_reaping                 = {  94821, 449631, 1 }, -- Damage dealt by your demonic soul is increased by 10%. Consuming Demonic Core feeds the demonic entity within you, causing it to appear and deal 21,631 Shadow damage to your target.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bonds_of_fel     = 5545, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the 8 yd radius they explode, dealing 88,300 Fire damage split amongst all nearby enemies.
    call_fel_lord    =  162, -- (212459) Summon a fel lord to guard the location for 15 sec. Any enemy that comes within 6 yards will suffer 44,991 Physical damage, and players struck will be stunned for 1 sec.
    call_observer    =  165, -- (201996) Summons a demonic Observer to keep a watchful eye over the area for 20 sec. Anytime an enemy within 30 yards casts a harmful magical spell, the Observer will deal up to 4% of the target's maximum health in Shadow damage.
    gateway_mastery  = 3506, -- (248855) Increases the range of your Demonic Gateway by 20 yards, and reduces the cast time by 30%. Reduces the time between how often players can take your Demonic Gateway by 30 sec.
    impish_instincts = 5577, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by 3 sec. Cannot occur more than once every 5 sec.
    master_summoner  = 1213, -- (212628) Reduces the cast time of your Call Dreadstalkers, Summon Vilefiend, and Summon Demonic Tyrant by 15% and reduces the cooldown of Call Dreadstalkers by 5 sec.
    nether_ward      = 3624, -- (212295) Surrounds the caster with a shield that lasts 3 sec, reflecting all harmful spells cast on you.
    shadow_rift      = 5394, -- (353294) Conjure a Shadow Rift at the target location lasting 2 sec. Enemy players within the rift when it expires are teleported to your Demonic Circle. Must be within 40 yds of your Demonic Circle to cast.
    soul_rip         = 5606, -- (410598) Fracture the soul of up to 3 target players within 20 yds into the shadows, reducing their damage done by 25% and healing received by 25% for 8 sec. Souls are fractured up to 20 yds from the player's location. Players can retrieve their souls to remove this effect.
} )


-- Demon Handling
local dreadstalkers = {}
local dreadstalkers_v = {}

local vilefiend = {}
local vilefiend_v = {}

local wild_imps = {}
local wild_imps_v = {}

local imp_gang_boss = {}
local imp_gang_boss_v = {}

local demonic_tyrant = {}
local demonic_tyrant_v = {}

local grim_felguard = {}
local grim_felguard_v = {}

local pit_lord = {}
local pit_lord_v = {}

local other_demon = {}
local other_demon_v = {}

local imps = {}
local guldan = {}
local guldan_v = {}

local last_summon = {}

local FindUnitBuffByID = ns.FindUnitBuffByID


local shards_for_guldan = 0

local function UpdateShardsForGuldan()
    shards_for_guldan = UnitPower( "player", Enum.PowerType.SoulShards )
end




local dreadstalkers_travel_time = 1

spec:RegisterCombatLogEvent( function( _, subtype, _, source, _, _, _, destGUID, _, _, _, spellID, spellName )
    if source == state.GUID then
        local now = GetTime()

        if subtype == "SPELL_SUMMON" then
            -- Wild Imp: 104317 (40) and 279910 (20).
            if spellID == 104317 or spellID == 279910 then
                local dur = ( spellID == 279910 and 20 or 40 )
                table.insert( wild_imps, now + dur )

                imps[ destGUID ] = {
                    t = now,
                    casts = 0,
                    expires = math.ceil( now + dur ),
                    max = math.ceil( now + dur )
                }

                if guldan[ 1 ] then
                    -- If this imp is impacting within 0.15s of the expected queued imp, remove that imp from the queue.
                    if abs( now - guldan[ 1 ] ) < 0.15 then
                        table.remove( guldan, 1 )
                    end
                end

                -- Expire missed/lost Gul'dan predictions.
                while( guldan[ 1 ] ) do
                    if guldan[ 1 ] < now then
                        table.remove( guldan, 1 )
                    else
                        break
                    end
                end

            -- Grimoire Felguard
            elseif spellID == 111898 then table.insert( grim_felguard, now + 17 )

            -- Demonic Tyrant: 265187, 15 seconds uptime.
            elseif spellID == 265187 then table.insert( demonic_tyrant, now + 15 )
                for i = 1, #dreadstalkers do dreadstalkers[ i ] = dreadstalkers[ i ] + 15 end
                for i = 1, #vilefiend do vilefiend[ i ] = vilefiend[ i ] + 15 end
                for i = 1, #grim_felguard do grim_felguard[ i ] = grim_felguard[ i ] + 15 end
                for i = 1, 15 do
                    if not wild_imps[ i ] then break end
                    wild_imps[ i ] = wild_imps[ i ] + 15
                end

                local i = 0
                for _, imp in pairs( imps ) do
                    imp.expires = imp.expires + 15
                    imp.max = imp.max + 15
                    i = i + 1
                    if i == 15 then break end
                end

            -- Other Demons, 15 seconds uptime.
            -- 267986 - Prince Malchezaar
            -- 267987 - Illidari Satyr
            -- 267988 - Vicious Hellhound
            -- 267989 - Eyes of Gul'dan
            -- 267991 - Void Terror
            -- 267992 - Bilescourge
            -- 267994 - Shivarra
            -- 267995 - Wrathguard
            -- 267996 - Darkhound
            -- 268001 - Ur'zul
            elseif spellID >= 267986 and spellID <= 268001 then table.insert( other_demon, now + 15 )
            elseif spellID == 387590 then table.insert( pit_lord, now + 10 ) end -- Pit Lord from Gul'dan's Ambition

        elseif spellID == 387458 and imps[ destGUID ] then
            imps[ destGUID ].boss = true

        elseif subtype == "SPELL_CAST_START" and spellID == 105174 then
            C_Timer.After( 0.25, UpdateShardsForGuldan )

        elseif subtype == "SPELL_CAST_SUCCESS" then
            -- Implosion.
            if spellID == 196277 then
                table.wipe( wild_imps )
                table.wipe( imps )

            -- Power Siphon.
            elseif spellID == 264130 then
                if wild_imps[1] then table.remove( wild_imps, 1 ) end
                if wild_imps[1] then table.remove( wild_imps, 1 ) end

                for i = 1, 2 do
                    local lowest

                    for id, imp in pairs( imps ) do
                        if not lowest then lowest = id
                        elseif imp.expires < imps[ lowest ].expires then
                            lowest = id
                        end
                    end

                    if lowest then
                        imps[ lowest ] = nil
                    end
                end

            -- Hand of Guldan (queue imps).
            elseif spellID == 105174 then
                hog_time = now

                if shards_for_guldan >= 1 then table.insert( guldan, now + 0.6 ) end
                if shards_for_guldan >= 2 then table.insert( guldan, now + 0.8 ) end
                if shards_for_guldan >= 3 then table.insert( guldan, now + 1 ) end

            -- Call Dreadstalkers (use travel time to determine buffer delay for Demonic Cores).
            elseif spellID == 104316 then
                local info = GetSpellInfo( 104316 )
                -- TODO:  Come up with a good estimate of the time it takes.
                dreadstalkers_travel_time = ( info and info.maxRange or 25 ) / 25

            end
        end

    elseif imps[ source ] and subtype == "SPELL_CAST_SUCCESS" then
        local demonic_power = FindPlayerAuraByID( 265273 )
        local now = GetTime()

        if not demonic_power then
            local imp = imps[ source ]

            imp.start = now
            imp.casts = imp.casts + 1

            imp.expires = min( imp.max, now + ( ( ( state.level > 55 and 7 or 6 ) - imp.casts ) * 2 * state.haste ) )
        end
    end
end )


local ExpireDreadstalkers = setfenv( function()
    addStack( "demonic_core", nil, 2 )
    if talent.shadows_bite.enabled then applyBuff( "shadows_bite" ) end
end, state )

local ExpireDoom = setfenv( function()
    gain( 1, "soul_shards" )
end, state )

spec:RegisterStateFunction( "SoulStrikeIfNotCapped", function()
    if soul_shard < 5 then
        class.abilities.soul_strike.handler()
        setCooldown( "soul_strike", 10 )
        if Hekili.ActiveDebug then Hekili:Debug( "*** Soul Strike cast by pet at %.2f; gained 1 Soul Shard (to %d).", query_time, soul_shard ) end
    else
        state:QueueAuraExpiration( "soul_strike", SoulStrikeIfNotCapped, gcd.remains > 0 and gcd.expires or ( query_time + gcd.max ) )
        if Hekili.ActiveDebug then Hekili:Debug( "*** Soul Strike not cast at %.2f due to capped shards; requeuing in cast by pet at %.2f.", query_time, gcd.remains > 0 and gcd.expires or ( query_time + gcd.max ) ) end
    end
end )


-- Tier 29
spec:RegisterGear( "tier29", 200336, 200338, 200333, 200335, 200337 )
spec:RegisterAura( "blazing_meteor", {
    id = 394215,
    duration = 6,
    max_stack = 1
} )

spec:RegisterGear( "tier30", 202534, 202533, 202532, 202536, 202531 )
spec:RegisterAura( "rite_of_ruvaraad", {
    id = 409725,
    duration = 17,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207270, 207271, 207272, 207273, 207275, 217212, 217214, 217215, 217211, 217213 )
spec:RegisterAuras( {
    doom_brand = {
        id = 423583,
        duration = 20,
        max_stack = 1
    }
} )

local wipe = table.wipe

spec:RegisterHook( "reset_precast", function()
    local i = 1
    for id, imp in pairs( imps ) do
        if imp.expires < now then
            imps[ id ] = nil
        end
    end

    while( wild_imps[ i ] ) do
        if wild_imps[ i ] < now then
            table.remove( wild_imps, i )
        else
            i = i + 1
        end
    end

    wipe( wild_imps_v )
    wipe( imp_gang_boss_v )

    for n, t in pairs( imps ) do
        table.insert( wild_imps_v, t.expires )
        if t.boss then table.insert( imp_gang_boss_v, t.expires ) end
    end

    table.sort( wild_imps_v )
    table.sort( imp_gang_boss_v )

    local difference = #wild_imps_v - GetSpellCount( 196277 )

    while difference > 0 do
        table.remove( wild_imps_v, 1 )
        difference = difference - 1
    end

    wipe( guldan_v )
    for n, t in ipairs( guldan ) do guldan_v[ n ] = t end

    i = 1
    while( other_demon[ i ] ) do
        if other_demon[ i ] < now then
            table.remove( other_demon, i )
        else
            i = i + 1
        end
    end

    wipe( other_demon_v )
    for n, t in ipairs( other_demon ) do other_demon_v[ n ] = t end

    i = 1
    local pl_expires = 0
    while( pit_lord[ i ] ) do
        if pit_lord[ i ] < now then
            table.remove( pit_lord, i )
        elseif pit_lord[ i ] > pl_expires then
            pl_expires = pit_lord[ i ]
            i = i + 1
        else
            i = i + 1
        end
    end

    if pl_expires > 0 then summonPet( "pit_lord", pl_expires - now ) end

    if #dreadstalkers_v > 0  then wipe( dreadstalkers_v ) end
    if #vilefiend_v > 0      then wipe( vilefiend_v )     end
    if #grim_felguard_v > 0  then wipe( grim_felguard_v ) end
    if #demonic_tyrant_v > 0 then wipe( demonic_tyrant_v ) end

    -- Pull major demons from Totem API.
    for i = 1, 5 do
        local summoned, duration, texture = select( 3, GetTotemInfo( i ) )

        if summoned ~= nil then
            local demon, extraTime = nil, 0

            -- Grimoire Felguard
            if texture == 237562 then
                extraTime = action.grimoire_felguard.lastCast % 1
                demon = grim_felguard_v
            elseif texture == 1616211 or texture == 1709931 or texture == 1709932 then
                extraTime = action.summon_vilefiend.lastCast % 1
                demon = vilefiend_v
            elseif texture == 1378282 then
                extraTime = action.call_dreadstalkers.lastCast % 1
                demon = dreadstalkers_v
            elseif texture == 135002 then
                extraTime = action.summon_demonic_tyrant.lastCast % 1
                demon = demonic_tyrant_v
            end

            if demon then
                insert( demon, summoned + duration + extraTime )
            end
        end

    end

    if #grim_felguard_v > 1 then table.sort( grim_felguard_v ) end
    if #vilefiend_v > 1 then table.sort( vilefiend_v ) end
    if #dreadstalkers_v > 1 then table.sort( dreadstalkers_v ) end
    if #demonic_tyrant_v > 1 then table.sort( demonic_tyrant_v ) end

    if demonic_tyrant_v[ 1 ] and demonic_tyrant_v[ 1 ] > now then
        summonPet( "demonic_tyrant", demonic_tyrant_v[ 1 ] - now )
    end

    if buff.demonic_power.up and buff.demonic_power.remains > pet.demonic_tyrant.remains then
        summonPet( "demonic_tyrant", buff.demonic_power.remains )
    end

    if buff.tyrant.down and pet.demonic_tyrant.remains > 0 then
        applyBuff( "tyrant", pet.demonic_tyrant.remains )
    end

    local subjugated, _, _, _, _, expirationTime = FindUnitDebuffByID( "pet", 1098 )
    if subjugated then
        summonPet( "subjugated_demon", expirationTime - now )
    else
        dismissPet( "subjugated_demon" )
    end

    if buff.dreadstalkers.up then
        state:QueueAuraExpiration( "dreadstalkers", ExpireDreadstalkers, 1 + buff.dreadstalkers.expires + dreadstalkers_travel_time )
    end

    class.abilities.summon_pet = class.abilities.summon_felguard

    if debuff.doom.up then
        state:QueueAuraExpiration( "doom", ExpireDoom, debuff.doom.expires )
    end

    if prev_gcd[1].guillotine and now - action.guillotine.lastCast < 1 and buff.fiendish_wrath.down then
        applyBuff( "fiendish_wrath" )
    end

    if prev_gcd[1].demonic_strength and now - action.demonic_strength.lastCast < 1 and buff.felstorm.down then
        applyBuff( "felstorm" )
        buff.demonic_strength.expires = buff.felstorm.expires
    end

    if IsActiveSpell( 434506 ) then
        applyBuff( "infernal_bolt" )
    end

    if talent.soul_strike.enabled and cooldown.soul_strike.remains > 0 then
        state:QueueAuraExpiration( "soul_strike", SoulStrikeIfNotCapped, query_time + cooldown.soul_strike.remains )
        if Hekili.ActiveDebug then Hekili:Debug( "*** Soul Strike queued for %.2f.", cooldown.soul_strike.remains ) end
    end

    if Hekili.ActiveDebug then
        Hekili:Debug(   " - Dreadstalkers: %d, %.2f\n" ..
                        " - Vilefiend    : %d, %.2f\n" ..
                        " - Grim Felguard: %d, %.2f\n" ..
                        " - Wild Imps    : %d, %.2f\n" ..
                        " - Imp Gang Boss: %d, %.2f\n" ..
                        " - Other Demons : %d, %.2f\n" ..
                        "Next Demon Exp. : %.2f",
                        buff.dreadstalkers.stack, buff.dreadstalkers.remains,
                        buff.vilefiend.stack, buff.vilefiend.remains,
                        buff.grimoire_felguard.stack, buff.grimoire_felguard.remains,
                        buff.wild_imps.stack, buff.wild_imps.remains,
                        buff.imp_gang_boss.stack, buff.imp_gang_boss.remains,
                        buff.other_demon.stack, buff.other_demon.remains,
                        major_demon_remains )
    end
end )


spec:RegisterHook( "advance_end", function ()
    -- For virtual imps, assume they'll take 0.5s to start casting and then chain cast.
    local longevity = 0.5 + ( state.level > 55 and 7 or 6 ) * 2 * state.haste
    for i = #guldan_v, 1, -1 do
        local imp = guldan_v[i]

        if imp <= query_time then
            if ( imp + longevity ) > query_time then
                insert( wild_imps_v, imp + longevity )
            end
            remove( guldan_v, i )
        end
    end
end )


-- Provide a way to confirm if all Hand of Gul'dan imps have landed.
spec:RegisterStateExpr( "spawn_remains", function ()
    if #guldan_v > 0 then
        return max( 0, guldan_v[ #guldan_v ] - query_time )
    end
    return 0
end )

spec:RegisterStateExpr( "pet_count", function ()
    return buff.dreadstalkers.stack + buff.vilefiend.stack + buff.grimoire_felguard.stack + buff.wild_imps.stack + buff.other_demon.stack
end )

-- 20230109
spec:RegisterStateExpr( "igb_ratio", function ()
    return buff.imp_gang_boss.stack / buff.wild_imps.stack
end )

spec:RegisterVariable( "imp_despawn", function ()
    if buff.tyrant.up then return 0 end

    local val = 0

    -- # Sets an expected duration of valid Wild Imps on a tyrant Setup for the sake of casting Tyrant before expiration of Imps
    -- actions.variables+=/variable,name=imp_despawn,op=set,value=2*spell_haste*6+0.58+time,if=prev_gcd.1.hand_of_guldan&buff.dreadstalkers.up&cooldown.summon_demonic_tyrant.remains<13&variable.imp_despawn=0
    if action.hand_of_guldan.time_since < 2 * state.haste * 6 + 0.58 + query_time and buff.dreadstalkers.up and cooldown.summon_demonic_tyrant.remains < 13 then
        val = max( 0, time - action.hand_of_guldan.time_since + 2 * state.haste * 6 + 0.58 )
    end

    -- # Checks the Wild Imps in a Tyrant Setup alongside Dreadstalkers for the sake of casting Tyrant before Expiration Dreadstalkers or Imps
    -- actions.variables+=/variable,name=imp_despawn,op=max,value=buff.dreadstalkers.remains+time,if=variable.imp_despawn
    if val > 0 then
        val = max( val, buff.dreadstalkers.remains + time )
    end

    -- # Checks The Wild Imps in a Tyrant Setup alongside Grimoire Felguard for the sake of casting Tyrant before Expiration of Grimoire Felguard or Imps
    -- actions.variables+=/variable,name=imp_despawn,op=max,value=buff.grimoire_felguard.remains+time,if=variable.imp_despawn&buff.grimoire_felguard.up
    if val > 0 and buff.grimoire_felguard.up then
        val = max( val, buff.grimoire_felguard.remains + time )
    end

    return val
end )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "soul_shards" then
        if amt > 0 then
            if legendary.wilfreds_sigil_of_superior_summoning.enabled then
                reduceCooldown( "summon_demonic_tyrant", amt * 0.6 )
            end

            if buff.art_overlord.up then
                summon_demon( "overlord", 2 )
                removeBuff( "art_overlord" )
            end

            if buff.art_mother.up then
                summon_demon( "mother_of_chaos", 6 )
                removeBuff( "art_mother" )
                if talent.secrets_of_the_coven.enabled then
                    applyBuff( "infernal_bolt" )
                    buff.infernal_bolt.applied = buff.infernal_bolt.applied + 0.25
                    buff.infernal_bolt.expires = buff.infernal_bolt.expires + 0.25
                end
            end

            if buff.art_pit_lord.up then
                summon_demon( "pit_lord", 5 )
                removeBuff( "art_pit_lord" )
                if talent.ruination.enabled then
                    applyBuff( "ruination" )
                    buff.ruination.applied = buff.ruination.applied + 0.25
                    buff.ruination.expires = buff.ruination.expires + 0.25
                end
            end

            if talent.diabolic_ritual.enabled then
                if buff.diabolic_ritual.down then applyBuff( "diabolic_ritual" )
                else
                    if buff.ritual_overlord.up then
                        buff.ritual_overlord.expires = buff.ritual_overlord.expires - amt
                        if buff.ritual_overlord.down then applyBuff( "art_overlord" ) end
                    end
                    if buff.ritual_mother.up then
                        buff.ritual_mother.expires = buff.ritual_mother.expires - amt
                        if buff.ritual_mother.down then applyBuff( "art_mother" ) end
                    end
                    if buff.ritual_pit_lord.up then
                        buff.ritual_pit_lord.expires = buff.ritual_pit_lord.expires - amt
                        if buff.ritual_pit_lord.down then applyBuff( "art_pit_lord" ) end
                    end
                end
            end

            if talent.grand_warlocks_design.enabled then
                reduceCooldown( "summon_demonic_tyrant", amt * 0.6 )
            end

        elseif amt < 0 and floor( soul_shard ) < floor( soul_shard + amt ) then
            if talent.demonic_inspiration.enabled then applyBuff( "demonic_inspiration" ) end
        end
    end
end )


spec:RegisterHook( "advance_end", function( time )
    if buff.ritual_overlord.expires > query_time - time and buff.ritual_overlord.down then
        applyBuff( "art_overlord" )
    end

    if buff.ritual_mother.expires > query_time - time and buff.ritual_mother.down then
        applyBuff( "art_mother" )
    end

    if buff.ritual_pit_lord.expires > query_time - time and buff.ritual_pit_lord.down then
        applyBuff( "art_pit_lord" )
    end
end )


spec:RegisterStateFunction( "summon_demon", function( name, duration, count )
    local db = other_demon_v

    if name == "dreadstalkers" then db = dreadstalkers_v
    elseif name == "vilefiend" then db = vilefiend_v
    elseif name == "wild_imps" then db = wild_imps_v
    elseif name == "imp_gang_boss" then db = imp_gang_boss_v
    elseif name == "grimoire_felguard" then db = grim_felguard_v
    elseif name == "demonic_tyrant" then db = demonic_tyrant_v end

    count = count or 1
    local expires = query_time + duration

    last_summon.name = name
    last_summon.at = query_time
    last_summon.count = count

    for i = 1, count do
        table.insert( db, expires )
    end
end )


spec:RegisterStateFunction( "extend_demons", function( duration )
    duration = duration or 15

    for k, v in pairs( dreadstalkers_v ) do dreadstalkers_v [ k ] = v + duration end
    for k, v in pairs( vilefiend_v     ) do vilefiend_v     [ k ] = v + duration end

    for k, v in pairs( grim_felguard_v ) do grim_felguard_v [ k ] = v + duration end
    for k, v in pairs( other_demon_v   ) do other_demon_v   [ k ] = v + duration end

    local n = talent.reign_of_tyranny.enabled and 15 or 10
    for k, v in pairs( wild_imps_v     ) do
        wild_imps_v[ k ] = v + duration
        if imp_gang_boss_v[ k ] then imp_gang_boss_v[ k ] = v + duration end
        n = n - 1
        if n == 0 then break end
    end
end )


spec:RegisterStateFunction( "consume_demons", function( name, count )
    local db = other_demon_v

    if     name == "dreadstalkers"     then db = dreadstalkers_v
    elseif name == "vilefiend"         then db = vilefiend_v
    elseif name == "wild_imps"         then db = wild_imps_v
    elseif name == "imp_gang_boss"     then db = imp_gang_boss_v
    elseif name == "grimoire_felguard" then db = grim_felguard_v
    elseif name == "demonic_tyrant"    then db = demonic_tyrant_v end

    if type( count ) == "string" and count == "all" then
        table.wipe( db )

        -- Wipe queued Guldan imps that should have landed by now.
        if name == "wild_imps" then
            while( guldan_v[ 1 ] ) do
                if guldan_v[ 1 ] < now then table.remove( guldan_v, 1 )
                else break end
            end
        end
        return
    end

    count = count or 0

    if count >= #db then
        count = count - #db
        table.wipe( db )
    end

    while( count > 0 ) do
        if not db[1] then break end

        local d = table.remove( db, 1 )
        if name == "wild_imps" and #imp_gang_boss_v > 0 then
            for i, v in ipairs( imp_gang_boss_v ) do
                if d == v then
                    table.remove( imp_gang_boss_v, i )
                    break
                end
            end
        end

        count = count - 1
    end

    if name == "wild_imps" and count > 0 then
        while( count > 0 ) do
            if not guldan_v[1] or guldan_v[1] > now then break end
            table.remove( guldan_v, 1 )
            count = count - 1
        end
    end
end )


spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )
spec:RegisterStateExpr( "soul_shard_deficit", function () return soul_shards.max - soul_shards.current end )

-- How long before you can complete a 3 Soul Shard HoG cast.
spec:RegisterStateExpr( "time_to_hog", function ()
    local shards_needed = max( 0, 3 - soul_shards.current )
    local cast_time = action.hand_of_guldan.cast_time

    if shards_needed > 0 then
        local cores = min( shards_needed, buff.demonic_core.stack )

        if cores > 0 then
            cast_time = cast_time + cores * gcd.execute
            shards_needed = shards_needed - cores
        end

        cast_time = cast_time + shards_needed * action.shadow_bolt.cast_time
    end

    return cast_time
end )


spec:RegisterStateExpr( "major_demons_active", function ()
    return ( buff.grimoire_felguard.up and 1 or 0 ) + ( buff.vilefiend.up and 1 or 0 ) + ( buff.dreadstalkers.up and 1 or 0 )
end )


-- When the next major demon (anything but Wild Imps) expires.
spec:RegisterStateExpr( "major_demon_remains", function ()
    local expire = 3600

    if buff.grimoire_felguard.up then expire = min( expire, buff.grimoire_felguard.remains ) end
    if buff.vilefiend.up then expire = min( expire, buff.vilefiend.remains ) end
    if buff.dreadstalkers.up then expire = min( expire, buff.dreadstalkers.remains ) end

    if expire == 3600 then return 0 end
    return expire
end )


-- New imp forecasting expressions for Demo.
spec:RegisterStateExpr( "incoming_imps", function ()
    local n = 0

    for i, time in ipairs( guldan_v ) do
        if time > query_time then
            n = n + 1
        end
    end

    return n
end )


local time_to_n = 0

spec:RegisterStateTable( "query_imp_spawn", setmetatable( {}, {
    __index = function( t, k )
        if k ~= "remains" then return 0 end

        local queued = #guldan_v

        if queued == 0 then return 0 end

        if time_to_n == 0 or time_to_n >= queued then
            return max( 0, guldan_v[ queued ] - query_time )
        end

        local count = 0
        local remains = 0

        for i, time in ipairs( guldan_v ) do
            if time > query_time then
                count = count + 1
                remains = time - query_time

                if count >= time_to_n then break end
            end
        end

        return remains
    end,
} ) )

spec:RegisterStateTable( "time_to_imps", setmetatable( {}, {
    __index = function( t, k )
        if type( k ) == "number" then
            time_to_n = min( #guldan_v, k )
        elseif k == "all" then
            time_to_n = #guldan_v
        else
            return 0
        end

        return query_imp_spawn.remains
    end
} ) )


spec:RegisterStateTable( "imps_spawned_during", setmetatable( {}, {
    __index = function( t, k, v )
        local cap = query_time

        if type(k) == "number" then cap = cap + ( k / 1000 )
        else
            if not class.abilities[ k ] then k = "summon_demonic_tyrant" end
            cap = cap + action[ k ].cast
        end

        -- In SimC, k would be a numeric value to be interpreted but I don't see the point.
        -- We're only using it for SDT now, and I don't know what else we'd really use it for.

        -- So imps_spawned_during.summon_demonic_tyrant would be the syntax I'll use here.

        local n = 0

        for i, spawn in ipairs( guldan_v ) do
            if spawn > cap then break end
            if spawn > query_time then n = n + 1 end
        end

        return n
    end,
} ) )


-- Auras
spec:RegisterAuras( {
    -- Talent: Damage taken is reduced by $s1%.
    -- https://wowhead.com/beta/spell=389614
    abyss_walker = {
        id = 389614,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Healing $w1 every $t sec.
    -- https://wowhead.com/beta/spell=386614
    accrued_vitality = {
        id = 386614,
        duration = 10,
        type = "Magic",
        max_stack = 1,
        copy = 339298
    },
    -- Talent: Damage done increased by $w1%. Soul Strike deals $w2% of its damage to nearby enemies.
    -- https://wowhead.com/beta/spell=387496
    antoran_armaments = {
        id = 387496,
        duration = 3600,
        max_stack = 1
    },
    -- Stunned for $d.
    -- https://wowhead.com/beta/spell=89766
    axe_toss = {
        id = 89766,
        duration = 4,
        type = "Ranged",
        max_stack = 1
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
    balespiders_burning_core = {
        id = 337161,
        duration = 15,
        max_stack = 4
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
        tick_time = function() return 2.0 * ( state.spec.affliction and talent.sataiels_volition.enabled and 0.75 or 1 ) end,
        pandemic = true,
        max_stack = 1,
    },
    -- Time between attacks increased by $w1%. $?e1[Chance to critically strike reduced by $w2%.][]
    curse_of_weakness = {
        id = 702,
        duration = 120.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    dark_pact = {
        id = 108416,
        duration = 20.0,
        max_stack = 1,
    },
    demonic_art_mother_of_chaos = {
        id = 432794,
        duration = 60,
        max_stack = 1,
        copy = { "demonic_art_mother", "art_mother" }
    },
    demonic_art_overlord = {
        id = 428524,
        duration = 60,
        max_stack = 1,
        copy = "art_overlord"
    },
    demonic_art_pit_lord = {
        id = 432795,
        duration = 60,
        max_stack = 1,
        copy = "art_pit_lord"
    },
    demonic_art = {
        alias = { "demonic_art_mother_of_chaos", "demonic_art_overlord", "demonic_art_pit_lord" },
        aliasMode = "first",
        aliasType = "buff"
    },
    demonic_calling = {
        id = 205146,
        duration = 20,
        type = "Magic",
        max_stack = 1,
    },
    -- The cast time of Demonbolt is reduced by $s1%. $?a334581[Demonbolt damage is increased by $334581s1%.][]
    -- https://wowhead.com/beta/spell=264173
    demonic_core = {
        id = 264173,
        duration = 20,
        max_stack = 4
    },
    -- Talent: Faded into the nether and unable to use another Demonic Gateway.
    -- https://wowhead.com/beta/spell=113942
    demonic_gateway = {
        id = 113942,
        duration = 90,
        max_stack = 1
    },
    -- Talent: Attack speed increased by $w1%.
    -- https://wowhead.com/beta/spell=386861
    demonic_inspiration = {
        id = 386861,
        duration = 8,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=339412
    demonic_momentum = {
        id = 339412,
        duration = 5,
        max_stack = 1
    },
    -- Damage dealt by your demons increased by $s2%.
    -- https://wowhead.com/beta/spell=265273
    demonic_power = {
        id = 265273,
        duration = 15,
        max_stack = 1,
        copy = "tyrant"
    },
    demonic_servitude = {
        duration = 3600,
        max_stack = 1,
        -- TODO: Make metafunction based on summons/expirations and GetSpellCount on Summon Demonic Tyrant button.
    },
    -- Talent: Your next Felstorm will deal $s2% increased damage.
    -- https://wowhead.com/beta/spell=267171
    demonic_strength = {
        id = 267171,
        duration = 20,
        max_stack = 1
    },
    -- [428524] Your next Soul Shard spent summons an Overlord that unleashes a devastating attack.
    diabolic_ritual_overlord = {
        id = 431944,
        duration = 20.0,
        max_stack = 1,
        copy = "ritual_overlord"
    },
    diabolic_ritual_mother_of_chaos = {
        id = 432815,
        duration = 20.0,
        max_stack = 1,
        copy = { "ritual_mother_of_chaos", "ritual_mother" }
    },
    diabolic_ritual_pit_lord = {
        id = 432816,
        duration = 20.0,
        max_stack = 1,
        copy = "ritual_pit_lord"
    },
    diabolic_ritual = {
        alias = { "diabolic_ritual_overlord", "diabolic_ritual_mother_of_chaos", "diabolic_ritual_pit_lord" },
        aliasMode = "first",
        aliasType = "buff"
    },
    dread_calling = {
        id = 387393,
        duration = 3600,
        max_stack = 20,
    },
    -- Healing for $m1% of maximum health every $t1 sec.  Spell casts are not delayed by taking damage.
    -- https://wowhead.com/beta/spell=262080
    empowered_healthstone = {
        id = 262080,
        duration = 6,
        max_stack = 1
    },
    -- Talent: $w1 damage is being delayed every $387846t1 sec.    Damage Remaining: $w2
    -- https://wowhead.com/beta/spell=387847
    fel_armor = {
        id = 387847,
        duration = 5,
        max_stack = 1
    },
    fel_cleave = {
        id = 213688,
        duration = 1,
        max_stack = 1
    },
    -- Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=386869
    fel_resilience = {
        id = 386869,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Damage taken from $@auracaster and their pets is increased by $s1%.
    -- https://wowhead.com/beta/spell=387402
    fel_sunder = {
        id = 387402,
        duration = 8,
        type = "Magic",
        max_stack = 5
    },
    -- Striking for $<damage> Physical damage every $t1 sec. Unable to use other abilities.
    -- https://wowhead.com/beta/spell=89751
    felstorm = {
        id = 89751,
        duration = function () return 5 * haste end,
        tick_time = function () return 1 * haste end,
        max_stack = 1,
        generate = function( t )
            local name, _, _, _, duration, expires = FindUnitBuffByID( "pet", 89751 )

            if name then
                t.count = 1
                t.applied = expires - duration
                t.expires = expires
                t.caster = "pet"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Unarmed. Basic attacks deal damage to all nearby enemies and attacks $s1% faster.
    -- https://wowhead.com/beta/spell=386601
    fiendish_wrath = {
        id = 386601,
        duration = 6,
        max_stack = 1,
        generate = function( t )
            local name, _, _, _, duration, expires = FindUnitBuffByID( "pet", 386601 )

            if name then
                t.count = 1
                t.applied = expires - duration
                t.expires = expires
                t.caster = "pet"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Summoned by a Grimoire of Service.  Damage done increased by $s1%.
    -- https://wowhead.com/beta/spell=216187
    grimoire_of_service = {
        id = 216187,
        duration = 3600,
        max_stack = 1,
        generate = function( t )
            local name, _, _, _, duration, expires = FindUnitBuffByID( "pet", 216187 )

            if name then
                t.count = 1
                t.applied = expires - duration
                t.expires = expires
                t.caster = "pet"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Disoriented.
    howl_of_terror = {
        id = 5484,
        duration = 20.0,
        max_stack = 1,
    },
    --[[ Talent: Damage done increased by $s2%.
    -- https://wowhead.com/beta/spell=387458
    -- TODO: May use this aura to identify Wild Imps who became Imp Gang Bosses.
    imp_gang_boss = {
        id = 387458,
        duration = 3600,
        max_stack = 1
    }, ]]
    implosive_potential = {
        id = 337139,
        duration = 8,
        max_stack = 1
    },
    -- Drain Life deals $w1% additional damage and costs $w3% less mana.
    -- https://wowhead.com/beta/spell=334320
    inevitable_demise = {
        id = 334320,
        duration = 20,
        type = "Magic",
        max_stack = 50
    },
    -- Soul Leech can absorb an additional $s1% of your maximum health.
    infernal_bulwark = {
        id = 434561,
        duration = 8.0,
        max_stack = 1,
    },
    -- Talent: Damage done increased by $w1%.
    -- https://wowhead.com/beta/spell=387552
    infernal_command = {
        id = 387552,
        duration = 3600,
        max_stack = 1
    },
    -- Healing for ${$s1*($d/$t1)}% of your maximum health over $d.
    infernal_vitality = {
        id = 434559,
        duration = 10.0,
        max_stack = 1,
    },
    legion_strike = {
        id = 30213,
        duration = 6,
        max_stack = 1,
    },
    -- Talent: Leech increased by $w1%.
    -- https://wowhead.com/beta/spell=386647
    lifeblood = {
        id = 386647,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=6789
    mortal_coil = {
        id = 6789,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Reflecting all spells.
    nether_ward = {
       id = 212295,
       duration = 3.0,
       max_stack = 1,
   },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=386649
    nightmare = {
        id = 386649,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Dealing damage to all nearby targets every $t1 sec and healing the casting Warlock.
    -- https://wowhead.com/beta/spell=205179
    phantom_singularity = {
        id = 205179,
        duration = 16,
        type = "Magic",
        max_stack = 1
    },
    -- TODO: Will need to track based on CLEU events since hidden auras are... hidden.
    power_siphon = {
        id = 334581,
        duration = 20,
        max_stack = 2
    },
    -- Covenant: Suffering $w2 Arcane damage every $t2 sec.
    -- https://wowhead.com/beta/spell=312321
    scouring_tithe = {
        id = 312321,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    -- Disoriented.
    -- https://wowhead.com/beta/spell=6358
    seduction = {
        id = 6358,
        duration = 30,
        mechanic = "sleep",
        type = "Magic",
        max_stack = 1
    },
    -- Maximum health increased by $s1%.
    -- https://wowhead.com/beta/spell=17767
    shadow_bulwark = {
        id = 17767,
        duration = 20,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Demonbolt damage increased by $w1.
    -- https://wowhead.com/beta/spell=272945
    shadows_bite = {
        id = 272945,
        duration = 8,
        type = "Magic",
        max_stack = 1
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
        duration = function() return 10.0 * ( 1 - 0.2 * talent.quietus.rank ) end,
        tick_time = function() return ( 1 - 0.2 * talent.quietus.rank ) end,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    soul_leech = {
        id = 108366,
        duration = function() return 15.0 + ( buff.soulburn.up and 10 or 0 ) end,
        max_stack = 1,
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
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    -- $@auracaster's subject.
    subjugate_demon = {
       id = 1098,
       duration = 600.0,
       max_stack = 1,
       dot = "buff",
       friendly = true,
       no_ticks = true
    },
    -- $?s137043[Malefic Rapture deals $s2% increased damage.][Hand of Gul'dan deals $s3% increased damage.]; Unleashes your demonic entity upon consumption, dealing an additional $449801s~1 Shadow damage to enemies.
    succulent_soul = {
        id = 449793,
        duration = 30.0,
        max_stack = 1,
    },
    -- Talent: Damage done increased by $s1%.
    -- https://wowhead.com/beta/spell=387601
    the_expendables = {
        id = 387601,
        duration = 30,
        max_stack = 10
    },
    -- Damage dealt increased by $s1%.
    the_houndmasters_gambit = {
        id = 455611,
        duration = 30.0,
        max_stack = 1,
        copy = { "the_houndmasters_stratagem", "from_the_shadows" } -- Old names.
    },
    -- Damage dealt by your demons increased by $w1%.
    -- https://wowhead.com/beta/spell=339784
    tyrants_soul = {
        id = 339784,
        duration = 15,
        max_stack = 1
    },
    -- Dealing $w1 Shadowflame damage every $t1 sec for $d.
    -- https://wowhead.com/beta/spell=273526
    umbral_blaze = {
        id = 273526,
        duration = 6,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=386931
    vile_taint = {
        id = 386931,
        duration = 10,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Damage taken from the Warlock's Shadowflame damage spells increased by $s1%.
    wicked_maw = {
        id = 270569,
        duration = 12.0,
        max_stack = 1
    },

    dreadstalkers = {
        duration = 12,

        meta = {
            up = function ()
                local exp = dreadstalkers_v[ #dreadstalkers_v ]
                return exp and exp >= query_time or false
            end,
            down = function ( t ) return not t.up end,
            applied = function () local exp = dreadstalkers_v[ 1 ]; return exp and min( query_time, exp - 12 ) or 0 end,
            expires = function () return dreadstalkers_v[ #dreadstalkers_v ] or 0 end,
            count = function ()
                local c = 0
                for i, exp in ipairs( dreadstalkers_v ) do
                    if exp >= query_time then c = c + 2 end
                end
                return c
            end,
        }
    },

    grimoire_felguard = {
        duration = 17,

        meta = {
            up = function ()
                local exp = grim_felguard_v[ #grim_felguard_v ]
                return exp and exp >= query_time or false
            end,
            down = function ( t ) return not t.up end,
            applied = function () local exp = grim_felguard_v[ 1 ]; return exp and min( query_time, exp - 17 ) or 0 end,
            expires = function () return grim_felguard_v[ #grim_felguard_v ] or 0 end,
            count = function ()
                local c = 0
                for i, exp in ipairs( grim_felguard_v ) do
                    if exp > query_time then c = c + 1 end
                end
                return c
            end,
        }
    },

    vilefiend = {
        duration = 15,

        meta = {
            up = function () local exp = vilefiend_v[ #vilefiend_v ]; return exp and exp >= query_time or false end,
            down = function ( t ) return not t.up end,
            applied = function () local exp = vilefiend_v[ 1 ]; return exp and min( query_time, exp - 15 ) or 0 end,
            expires = function () return vilefiend_v[ #vilefiend_v ] or 0 end,
            count = function ()
                local c = 0
                for i, exp in ipairs( vilefiend_v ) do
                    if exp > query_time then c = c + 1 end
                end
                return c
            end,
        }
    },

    wild_imps = {
        duration = 40,

        meta = {
            up = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and exp >= query_time or false end,
            down = function ( t ) return not t.up end,
            applied = function () local exp = wild_imps_v[ 1 ]; return exp and min( query_time, exp - 40 ) or 0 end,
            expires = function () return wild_imps_v[ #wild_imps_v ] or 0 end,
            count = function ()
                local c = 0
                for i, exp in ipairs( wild_imps_v ) do
                    if exp > query_time then c = c + 1 end
                end
                return c
            end,
        }
    },


    imp_gang_boss = {
        duration = 40,

        meta = {
            up = function () local exp = imp_gang_boss_v[ #imp_gang_boss_v ]; return exp and exp >= query_time or false end,
            down = function ( t ) return not t.up end,
            applied = function () local exp = imp_gang_boss_v[ 1 ]; return exp and min( query_time,  exp - 40 ) or 0 end,
            expires = function () return imp_gang_boss_v[ #imp_gang_boss_v ] or 0 end,
            count = function ()
                local c = 0
                for i, exp in ipairs( imp_gang_boss_v ) do
                    if exp > query_time then c = c + 1 end
                end
                return c
            end,
        }
    },

    other_demon = {
        duration = 20,

        meta = {
            up = function () local exp = other_demon_v[ #other_demon_v ]; return exp and exp >= query_time or false end,
            down = function ( t ) return not t.up end,
            applied = function () local exp = other_demon_v[ 1 ]; return exp and min( query_time, exp - 15 ) or 0 end,
            expires = function () return other_demon_v[ #other_demon_v ] or 0 end,
            count = function ()
                local c = 0
                for i, exp in ipairs( other_demon_v ) do
                    if exp > query_time then c = c + 1 end
                end
                return c
            end,
        }
    },

    doom = {
        id = 460551,
        duration = 20,
        max_stack = 1,
        copy = "impending_doom"
    },
} )


local Glyphed = IsSpellKnownOrOverridesKnown

-- Fel Imp          58959
spec:RegisterPet( "imp",
    function() return Glyphed( 112866 ) and 58959 or 416 end,
    "summon_imp",
    3600,
    58959, 416 )

-- Voidlord         58960
spec:RegisterPet( "voidwalker",
    function() return Glyphed( 112867 ) and 58960 or 1860 end,
    "summon_voidwalker",
    3600,
    58960, 1860 )

-- Observer         58964
spec:RegisterPet( "felhunter",
    function() return Glyphed( 112869 ) and 58964 or 417 end,
    "summon_felhunter",
    3600,
    58964, 417 )

-- Fel Succubus     120526
-- Shadow Succubus  120527
-- Shivarra         58963
spec:RegisterPet( "sayaad",
    function()
        if Glyphed( 240263 ) then return 120526
        elseif Glyphed( 240266 ) then return 120527
        elseif Glyphed( 112868 ) then return 58963
        elseif Glyphed( 365349 ) then return 184600
        end
        return 1863
    end,
    "summon_sayaad",
    3600,
    "incubus", "succubus", 120526, 120527, 58963, 184600 )

-- Wrathguard       58965
spec:RegisterPet( "felguard",
    function() return Glyphed( 112870 ) and 58965 or 237562 end,
    "summon_felguard",
    3600, 58965, 17252 )

spec:RegisterPet( "doomguard",
    11859,
    "ritual_of_doom",
    300 )


-- Demonic Tyrant
spec:RegisterPet( "demonic_tyrant",
    135002,
    "summon_demonic_tyrant",
    15 )

spec:RegisterTotem( "demonic_tyrant", 135002 )
spec:RegisterTotem( "vilefiend", 1709931 ) -- Charhound.
spec:RegisterTotem( "vilefiend", 1709932 ) -- Gloomhound.
spec:RegisterTotem( "vilefiend", 1616211 )
spec:RegisterTotem( "grimoire_felguard", 237562 )
spec:RegisterTotem( "dreadstalker", 1378282 )


spec:RegisterStateExpr( "extra_shards", function () return 0 end )

spec:RegisterStateExpr( "last_cast_imps", function ()
    local count = 0

    for i, imp in ipairs( wild_imps_v ) do
        if imp - query_time <= 4 * haste then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "two_cast_imps", function ()
    local count = 0

    for i, imp in ipairs( wild_imps_v ) do
        if imp - query_time <= 6 * haste and imp - query_time > 4 * haste then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "last_cast_igb_imps", function ()
    local count = 0

    for i, imp in ipairs( imp_gang_boss_v ) do
        if imp - query_time <= 4 * haste then count = count + 1 end
    end
end )

spec:RegisterStateExpr( "two_cast_igb_imps", function ()
    local count = 0

    for i, imp in ipairs( imp_gang_boss_v ) do
        if imp - query_time <= 6 * haste and imp - query_time > 4 * haste then count = count + 1 end
    end
end )



-- Abilities
spec:RegisterAbilities( {
    axe_toss = {
        id = 119914,
        known = function () return IsSpellKnownOrOverridesKnown( 119914 ) end,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = true,

        toggle = "interrupts",
        interrupt = true,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        usable = function () return pet.exists, "requires felguard" end,
        handler = function ()
            interrupt()
            applyDebuff( "target", "axe_toss", 4 )
        end,
    },

    -- Talent: Tear open a portal to the nether above the target location, from which several Bilescourge will pour out of and crash into the ground over 6 sec, dealing 1,179 Shadow damage to all enemies within 8 yards.
    bilescourge_bombers = {
        id = 267211,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "bilescourge_bombers",
        startsCombat = true,
    },

    -- Talent: Summons 2 ferocious Dreadstalkers to attack the target for 12 sec.
    call_dreadstalkers = {
        id = 104316,
        cast = function () if pvptalent.master_summoner.enabled or buff.demonic_calling.up then return 0 end
            return 1.5 * haste
        end,
        cooldown = 20,
        gcd = "spell",
        school = "shadow",

        spend = function () return buff.demonic_calling.up and 0 or 2 end,
        spendType = "soul_shards",

        talent = "call_dreadstalkers",
        startsCombat = true,

        handler = function ()
            summon_demon( "dreadstalkers", 12, 2 )
            applyBuff( "dreadstalkers", 12, 2 )
            summonPet( "dreadstalker", 12 )
            removeStack( "demonic_calling" )

            if talent.the_houndmasters_stratagem.enabled then applyDebuff( "target", "the_houndmasters_stratagem" ) end
        end,
    },


    call_felhunter = {
        id = 212619,
        cast = 0,
        cooldown = 24,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        pvptalent = "call_felhunter",
        toggle = "interrupts",
        interrupt = true,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },


    call_fel_lord = {
        id = 212459,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = true,
        pvptalent = "call_fel_lord",
        toggle = "cooldowns",

        handler = function()
            interrupt()
            applyDebuff( "target", "fel_cleave" )
        end,
    },

    -- Corrupts the target, causing $s3 Shadow damage and $?a196103[$146739s1 Shadow damage every $146739t1 sec.][an additional $146739o1 Shadow damage over $146739d.]
    corruption = {
        id = 172,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        handler = function()
            applyDebuff( "target", "corruption" )
        end,
    },

    -- [386646] When you use a Healthstone, gain $s2% Leech for $386647d.
    create_healthstone = {
        id = 6201,
        cast = function() return 3.0 * ( 1 - 0.5 * talent.swift_artifice.rank ) end,
        cooldown = 0.0,
        gcd = "spell",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- swift_artifice[452902] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Talent: Send the fiery soul of a fallen demon at the enemy, causing 2,201 Shadowflame damage. Generates 2 Soul Shards.
    demonbolt = {
        id = 264178,
        cast = function () return ( buff.demonic_core.up and 0 or 4.5 ) * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "shadowflame",

        spend = 0.02,
        spendType = "mana",
        startsCombat = true,

        cycle = function()
            if set_bonus.tier31_2pc > 0 then return "doom_brand" end
        end,

        handler = function ()
            removeBuff( "fel_covenant" )
            if buff.demonic_core.up then
                removeStack( "demonic_core" )
                if set_bonus.tier30_2pc > 0 then reduceCooldown( "grimoire_felguard", 0.5 ) end
                if set_bonus.tier31_2pc > 0 then applyDebuff( "target", "doom_brand" ) end -- TODO: Determine behavior on reapplication.
            end
            removeStack( "power_siphon" )
            removeStack( "decimating_bolt" )
            gain( 2, "soul_shards" )
        end,
    },

    -- Talent: Infuse your Felguard with demonic strength and command it to charge your target and unleash a Felstorm that will deal 400% increased damage.
    demonic_strength = {
        id = 267171,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        talent = "demonic_strength",
        startsCombat = true,
        readyTime = function() return max( buff.fiendish_wrath.remains, buff.felstorm.remains ) end,

        usable = function() return pet.alive and pet.real_pet == "felguard", "requires a living felguard" end,
        handler = function ()
            applyBuff( "felstorm" )
            applyBuff( "demonic_strength" )
            buff.demonic_strength.expires = buff.felstorm.expires
            if cooldown.guillotine.remains < 5 then setCooldown( "guillotine", 8 ) end
        end,
    },


    devour_magic = {
        id = 19505,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        toggle = "interrupts",

        usable = function ()
            if buff.dispellable_magic.down then return false, "no dispellable magic aura" end
            return true
        end,

        handler = function()
            removeBuff( "dispellable_magic" )
        end,
    },

    -- Talent: Summons a Felguard who attacks the target for 17 sec that deals 45% increased damage. This Felguard will stun their target when summoned.
    grimoire_felguard = {
        id = 111898,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "grimoire_felguard",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            summon_demon( "grimoire_felguard", 17 )
            applyBuff( "grimoire_felguard" )
            summonPet( "grimoire_felguard" )

            if set_bonus.tier30_4pc > 0 then applyBuff( "rite_of_ruvaraad" ) end
        end,
    },

    -- Talent: Your Felguard hurls his axe towards the target location, erupting when it lands and dealing 363 Shadowflame damage every 1 sec for 8 sec to nearby enemies. While unarmed, your Felguard's basic attacks deal damage to all nearby enemies and attacks 50% faster.
    guillotine = {
        id = 386833,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "physical",

        talent = "guillotine",
        startsCombat = true,
        nobuff = "felstorm",

        usable = function() return pet.alive and pet.real_pet == "felguard", "requires a living felguard" end,
        handler = function()
            removeBuff( "felstorm" )
            applyBuff( "fiendish_wrath" )
            if cooldown.demonic_strength.remains < 8 then setCooldown( "demonic_strength", 8 ) end
        end
    },

    -- Calls down a demonic meteor full of Wild Imps which burst forth to attack the target. Deals up to 2,188 Shadowflame damage on impact to all enemies within 8 yds of the target and summons up to 3 Wild Imps, based on Soul Shards consumed.
    hand_of_guldan = {
        id = 105174,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "shadowflame",

        spend = 1,
        spendType = "soul_shards",

        texture = 535592,
        startsCombat = true,
        nobuff = "ruination",

        handler = function ()
            removeBuff( "blazing_meteor" )

            extra_shards = min( 2, soul_shards.current )
            if Hekili.ActiveDebug then Hekili:Debug( "Extra Shards: %d", extra_shards ) end
            spend( extra_shards, "soul_shards" )
            insert( guldan_v, query_time + 0.6 )
            if extra_shards > 0 then insert( guldan_v, query_time + 0.8 ) end
            if extra_shards > 1 then insert( guldan_v, query_time + 1 ) end

            if debuff.doom_brand.up then
                debuff.doom_brand.expires = debuff.doom_brand.expires - ( 1 + extra_shards )
                -- TODO: Decide if tracking Doomfiends is worth it.
            end

            if talent.dread_calling.enabled then
                addStack( "dread_calling", nil, 1 + extra_shards )
            end
        end,

        bind = "ruination"
    },

    -- Calls down a demonic meteor full of Wild Imps which burst forth to attack the target. Deals up to 2,188 Shadowflame damage on impact to all enemies within 8 yds of the target and summons up to 3 Wild Imps, based on Soul Shards consumed.
    ruination = {
        id = 434635,
        known = 105174,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "shadowflame",

        texture = 135800,
        startsCombat = true,
        buff = "ruination",

        handler = function ()
            removeBuff( "ruination" )
            removeBuff( "blazing_meteor" )

            insert( guldan_v, query_time + 0.6 )
            insert( guldan_v, query_time + 0.8 )
            insert( guldan_v, query_time + 1 )

            if debuff.doom_brand.up then
                debuff.doom_brand.expires = debuff.doom_brand.expires - ( 1 + extra_shards )
            end

            if talent.dread_calling.enabled then
                addStack( "dread_calling", nil, 3 ) -- ?
            end
        end,

        bind = "hand_of_guldan"
    },

    -- Talent: Demonic forces suck all of your Wild Imps toward the target, and then cause them to violently explode, dealing 1,410 Shadowflame damage to all enemies within 8 yards.
    implosion = {
        id = 196277,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadowflame",

        spend = 0.02,
        spendType = "mana",

        talent = "implosion",
        startsCombat = true,

        usable = function ()
            if buff.wild_imps.stack < 3 and azerite.explosive_potential.enabled then return false, "too few imps for explosive_potential"
            elseif buff.wild_imps.stack < 1 then return false, "no imps available" end
            return true
        end,
        handler = function ()
            if azerite.explosive_potential.enabled and buff.wild_imps.stack >= 3 then applyBuff( "explosive_potential" ) end
            if legendary.implosive_potential.enabled then
                if buff.implosive_potential.up then
                    stat.haste = stat.haste - 0.01 * buff.implosive_potential.v1
                    removeBuff( "implosive_potential" )
                end
                if buff.implosive_potential.down then stat.haste = stat.haste + 0.05 * buff.wild_imps.stack end
                applyBuff( "implosive_potential", 12 )
                stat.haste = stat.haste + ( active_enemies > 2 and 0.05 or 0.01 ) * buff.wild_imps.stack
                buff.implosive_potential.v1 = ( active_enemies > 2 and 5 or 1 ) * buff.wild_imps.stack
            end
            consume_demons( "wild_imps", "all" )
            if buff.imp_gang_boss.up then
                for i = 1, buff.imp_gang_boss.stack do
                    insert( guldan_v, query_time + 0.1 )
                end
                consume_demons( "imp_gang_boss", "all" )
            end
        end,
    },

    -- Talent: Instantly sacrifice up to 2 Wild Imps, generating 2 charges of Demonic Core that cause Demonbolt to deal 30% additional damage.
    power_siphon = {
        id = 264130,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        talent = "power_siphon",
        startsCombat = false,

        readyTime = function ()
            if buff.wild_imps.stack >= 2 then return 0 end

            local imp_deficit = 2 - buff.wild_imps.stack

            for i, imp in ipairs( guldan_v ) do
                if imp > query_time then
                    imp_deficit = imp_deficit - 1
                    if imp_deficit == 0 then return imp - query_time end
                end
            end

            return 3600
        end,

        handler = function ()
            local num = min( 2, buff.wild_imps.count )
            consume_demons( "wild_imps", num )

            addStack( "demonic_core", nil, num )
            addStack( "power_siphon", nil, num )
        end,
    },

    -- Sends a shadowy bolt at the enemy, causing 2,105 Shadow damage. Generates 1 Soul Shard.
    shadow_bolt = {
        id = 686,
        cast = function() return 2 * ( 1 - 0.25 * talent.rune_of_shadows.rank ) * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.015,
        spendType = "mana",

        startsCombat = true,
        texture = 136197,
        nobuff = "infernal_bolt",

        handler = function ()
            gain( 1, "soul_shards" )

            if legendary.balespiders_burning_core.enabled then
                addStack( "balespiders_burning_core" )
            end
        end,

        bind = "infernal_bolt"
    },

    infernal_bolt = {
        id = 434506,
        known = 686,
        cast = function() return 2 * ( 1 - 0.25 * talent.rune_of_shadows.rank ) * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.015,
        spendType = "mana",

        startsCombat = true,
        texture = 841220,
        buff = "infernal_bolt",

        handler = function ()
            removeBuff( "infernal_bolt" )
            gain( 3, "soul_shards" )

            if legendary.balespiders_burning_core.enabled then
                addStack( "balespiders_burning_core" )
            end
        end,

        bind = "shadow_bolt"
    },

    -- Fracture the soul of up to $i target players within $r yds into the shadows, reducing their damage done by $s1% and healing received by $s3% for $d. Souls are fractured up to $410615a yds from the player's location.; Players can retrieve their souls to remove this effect.
    soul_rip = {
        id = 410598,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "spell",

        spend = 1,
        spendType = 'soul_shards',

        startsCombat = true,
        pvptalent = "soul_rip",

        handler = function ()
            applyDebuff( "target", "soul_rip" )
        end,
    },

    -- Talent: Summon a Demonic Tyrant to increase the duration of your Dreadstalkers, Vilefiend, Felguard, and up to $s3 of your Wild Imps by ${$265273m3/1000} sec. Your Demonic Tyrant increases the damage of affected demons by $265273s1%, while damaging your target.$?s334585[; Generates ${$s2/10} Soul Shards.][]
    summon_demonic_tyrant = {
        id = 265187,
        cast = function() return 2 * ( 1 - 0.15 * talent.master_summoner.rank ) end,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "summon_demonic_tyrant",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "demonic_tyrant", 15 )
            summon_demon( "demonic_tyrant", 15 )
            applyBuff( "demonic_power", 15 )

            extend_demons()

            if talent.soulbound_tyrant.enabled then
                gain( ceil( 2.5 * talent.soulbound_tyrant.rank ), "soul_shards" )
            end
        end,

        copy = "tyrant"
    },


    summon_felguard = {
        id = 30146,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        startsCombat = false,
        essential = true,

        bind = "summon_pet",
        nomounted = true,

        usable = function () return not pet.exists, "cannot have an existing pet" end,
        handler = function ()
            removeBuff( "fel_domination" )
            summonPet( "felguard", 3600 )
        end,

        copy = { "summon_pet", 112870 }
    },

    -- Talent: Summon a Vilefiend to fight for you for the next 15 sec.
    summon_vilefiend = {
        id = function()
            if talent.mark_of_fharg.enabled then return 455476
            elseif talent.mark_of_shatug.enabled then return 455465 end
            return 264119
        end,
        cast = function() return ( talent.fel_invocation.enabled and 1.5 or 2 ) * haste end,
        cooldown = 30,
        gcd = "spell",
        school = "fire",

        spend = 1,
        spendType = "soul_shards",

        talent = "summon_vilefiend",
        startsCombat = true,

        handler = function ()
            summon_demon( "vilefiend", 15 )
            summonPet( "vilefiend", 15 )
        end,

        copy = { 264119, "summon_charhound", 455476, "summon_gloomhound", 455465 }
    },


    -- Pet: Felguard
    soul_strike = {
        id = 264057,
        cast = 0,
        cooldown = 10,
        gcd = "off", -- Pet's gonna pet.

        talent = "soul_strike",
        startsCombat = true,

        hidden = true,

        handler = function()
            gain( 1, "soul_shards" )
        end
    },

    felstorm = {
        id = 89751,
        cast = 0,
        cooldown = function() return 30 * ( talent.reign_of_tyranny.enabled and 0.9 or 1 ) end,
        gcd = "off", -- Pet ability, no GCD

        startsCombat = true,
        texture = 236298,

        readyTime = function() return buff.fiendish_wrath.remains end,

        usable = function() return pet.alive and pet.real_pet == "felguard", "requires a living felguard" end,
        handler = function()
            applyBuff( "felstorm" )
            if cooldown.guillotine.remains < 5 then setCooldown( "guillotine", 8 ) end
        end,
    },
} )


spec:RegisterRanges( "corruption", "subjugate_demon", "mortal_coil" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    cycle = true,

    damage = true,
    damageExpiration = 6,

    potion = "tempered_potion",

    package = "Demonology",
} )


--[[ spec:RegisterSetting( "tyrant_padding", 1, {
    type = "range",
    name = strformat( "%s Padding", Hekili:GetSpellLinkWithTexture( spec.abilities.summon_demonic_tyrant.id ) ),
    desc = strformat( "This value determines how many global cooldowns (GCDs) early %s will be recommended, to avoid the risk of having your demons expire before finishing the cast.\n\n"
        .. "The default SimulationCraft value is |cFFFFD1001|r GCD; this option allows this to be extended up to 2.5 GCDs in total.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.summon_demonic_tyrant.id ) ),
    min = 1,
    max = 2.5,
    step = 0.05,
    width = "full",
} ) ]]

spec:RegisterStateExpr( "tyrant_padding", function ()
    return gcd.max * ( settings.tyrant_padding or 1 )
end )

--[[ Retired 20230718
spec:RegisterSetting( "dcon_imps", 0, {
    type = "range",
    name = "Wild Imps Required",
    desc = "If set above zero, Summon Demonic Tyrant will not be recommended unless the specified number of imps are summoned.\n\n" ..
        "This can backfire horribly, letting your Felguard or Vilefiend expire when you could've extended them with Summon Demonic Tyrant.",
    min = 0,
    max = 10,
    step = 1,
    width = "full"
} ) ]]


spec:RegisterPack( "Demonology", 20241109, [[Hekili:L3ZAVTnss(BjyruKSNOiszNhlSeWSzU92jyU9wSEMD(WHZs0su2CdLOwrQ4yad9B)QUj73v)GYuzM7omdITj7U66vxDvvxDZBIU5NV56LjvP38xJhfFru8Opmm6I43Dr8nxx9420BUEBYIpNCh8lBswd)7pKUUytrEXDpsE1J5fjljGOSy)UfWRVVQAB5F8nV5USQ73F7WffRFtz2695jvzfBwSlzvf5Vx8MBZlU9nl3LCxXMv5z3DF1Bs3Cx2M03SipPSC26IL7ZtlFtY2838qYU8IfFE4ITBV56B3NLx9JBU5wCSgqKTPlGN(23c4s2YLP1nnTCXnxtA6RJIE9Op8hpm)NFCxYMQdZbkjBXH573sax5HpD4t1nB0RJhdn7)O4lPhMNTE7magBtEyZH5vfhMtgLdZRXsL(eb95VdSisVk2xra6YdZt3uTltf6JEl0YFIq5VQ8W8pTF5DRHwXBXOp864lGwCD26pEy(2Dzf7YQEKHNIM9EOzF3H5WphpkOMpkgA23V8FUVei(vf7omFt6dhM)XF4W8L73rftc8C07Q5c)89a58RjqJ)vqUMbmH(Lf7aauSAWnxNNvwvsucYQsxt(L)kvRkDtYT5PlV5pDZ1jliWf0O2LT5ZPvrGykVOs(V3xMoRy1Qz3TyjP7xVaW)0Dzj3C9xsGFaaAytJNfn729RwbmTEhM)IdZrE)6Kn7tYPnOpTnBtRgUKO4MTywfvWpKGseHe0MMooSkA4IKYQzvzRHxmf4QhM)0tua4QjdydKJrHbMKCqipSC)AOvZ0ABd)QUXguLqMo5W8y6qUOOiFzXdBSaVDPRtYaHjbnJhXyxbYkIhYHohoxf(qE(H5xkXzmOM4zPFDr((LPMC44H3NuoJnq1V3jA5NDfzvxjMRRmWcGQ12MXMBaCtaGRiZBN1Gb3ub2BCRWhRPWh3kf(ypk8XhTcFSFfEKM8BGcF0jxHp60QWhzxHpYLcpgA5NDfhGXrBk8XbPWpUdTWJJNTZiVmpFzYAWHLz2uK8AqHlfDz13RYvyRCqAfzKOp9kUERDBan9jm9sqPdCuH6csZCIbeH3fDO1kCdsTZGvOcV4aMCyk8qSG1AHhUvWqfErDPW7snHxTB5LBFCnGHP7kN9q6TMcmMiwVDcbPB7KkgaaIfKgVVMAjK2qjWUlDl4A4WYkiUHAJhJhjTYKZz6s87SYHQ4kxO4uDts3abcn8FeIjEe2KEdTRGWrNgx8IJ2OsoFYlBGQM8wu1eiqM0DRaTQzjLls3SmzZIhNvMUB)A7QmU6tOQpamvwEEKvbX4reS)DAyVnCJ0Xz3NSzjZKL4bauEVf7CRZ2TRyhaWzR2bpB)U0LZQkwxap9HszIsvs5SB4Z8DA(kUlaAet06MOaUXh8UKD4ljhQf7GwU1WxbazJg5DnQWxdkuSnO1xmwCSc(VRR1KHzhyH)kWuDfEIHhbTD3US1fz7sNTkn)U9j7wYdTG1ID7Z2Ku)Rc4J4oMZr8W8ZQNrUo5R81c3L(fYSRHGM(6T5fL0XqYeqZJq8EW1yXhLZyJlD5cMHIff7szRuaEq)bXckkTy)wMySSyF(SY7bwdf8xGBgXXOit5deeiTP3wKxHTcBOIVfj55ZwUlnzjmy5FgSOJziouO14BWxYYtxLLwBqt3SylHLQ9zmlKUay0in(faPYQDPBUR6Em7lcyzvAaqDmQ7fQO)2Ihs3nRmB791AGggh()CQGr2nHip(tzH69SjBbEqw8KSkYD7ZHL6PiJIjOSnRs3TjjFgfxvmdvrOIvj7HNZScY6vYxbBUfLLA2TSL3e6uP6)ygj9I1jzCw9kDmB5ObIQP1HKAGifnRklw1k2cS60krtzJk53Y3N60JhIgXTa1At3oMcUgYzX9Pl(8myn7SK8sm7p2zkbKejvOlZgLgrDBu2C3YPyPo7VoTs5GNmw3qQTHrSsRt7x8GY4CIvz7iHWrLu0i5abmSi(IQWjXITPBs352yxyb3zmhn6IaXbHXBhMbdfjigqUulrqBs)kNnTOXiZL(wLZHbRwGlJ9S(xKn7fcJNsdCDaNltRn8vuSMAfVj8P6EoK3XHqCd17efvbvUxQbkYsXGR1i6ZI2LL)tQnBqz7ZPQz9uWBKAHmhrZmEpoibxeNLT5lflOUdkGAnYzUivtOVAVOp9DVM(l1gVGzwPRj7vvZIldy)VHFICwNmArzyCKPxO56O2WmOLT4Xf5Wkfj7UlTQKmXKi19yJhBnnAEhmzf8NkhYWwafPDUC2kicQMjywwy2U3V(9YPf8cYSYA0ubSupHafnh(gz37vebCKBx6IS78QBGDlmRTCrXEqmc(jS(wMvc7lnGbp20joFthhvZjUy(Mr7etpKI2AFwoejx2MukQ9(qIZkYJtUkohPiqLYFiZ4HLgBgIgYe32RqnYMlCe3WSVss1dfZO4oedyPu(t5ZEiXg6kksMqerapUM00FJywAozGngDjzOsGPX2xdse(p8JICGfbVApWbqT1ktEw7G863NR2zRlnyylYIvMy915o1uIaXaDOvzlYQOAGskTAKOM6OK)bWdbvsHQLDJ39nINIhpJ8KEthoSUcztWyQ8FO7zBUt0Nxl1NPboodA70TO3HUK7e62eI80lcFTDK5s1zABGRG4ITVWfQe4fh9azl8fB(OH7M2al2gyoZGonJT4V0AhOrS373oNZWTLpiuNsW8pk2(Q0wTejhCmMXjkw9Aob9V2NLwTVKrj2mB5iYpVYktPuRhEB57VZ18S5SBFlboqZ6qlwAWn5)CvxS7dZrLfllsJX2YGFNlnCfjgFoSSFYk(ADHKD1VDcHX29vr3NFzkQfRajhZUEqcJT7FHJu0e6GFUQ)aiXXpESSZ2oYO4FDS9LTA2bFZnBKJNnjXqngtAtCh9cnnaLZ(NnfLjfpUugJL9XrdFBxetgQPDqeo6levUFZsiOrdBNW7kRk2T(gAIBbx3xabQLisDlE4aOvrrsoJ3ZuE5BLf4Bqzc0FWPYuLaxjO2YI1S4SQmtgSHO(ygMg1pO7uXJ2q4plVrX1Lp8UST1T4AysmWFjveROanyvtm8sYmvsupB3NdXfrkw4QKpdnoH8hvKIEjc8vOe42BwwsQ)4n3jNnyZSuwHNC6KLlXrB7qswowRFySJJc1efI(7xabZVHq40sgUH6txSVIgHxTwrXQdZ)3Ba4H5)5giEyoPEHP9OSH7SsWWi9(VbCko)UMIWqm6WLY5j6Uz2z8eDdwpxwY)GbijorBzhM4Kg3q3StNXnSQH0Sx5NgE2Tfv3JRmLq4JOSuZPGkCsM3kvMBqb1kW(BDyfqvmOTWNSSGU6hR1IvjuLxozkCvbsTG(Xesz6)ZuatP8e4HGCnJ0vITKRPJrDwyxqBC9i4XGIUNYeoayk2LDWrO2bP4ZTLf5aXDyoaIS173uldJgPiN)Ze8qZsPx8u3v1aSxldZSnZeBzJX2L4hysvccPgDjBlgzzhnoXpa6IBiRONTsE69px3z6Q8zL0faiDw6fcDx2tONgfzkqR4BO0H(QZTGoIFo0rChqhXs0H(69TGoO1J1U93(4ShUpnFl4ZEkzQUc58NjQE)NaQ9lLcQOS2YaPeEOcMhYigAipApPvPRif6g0Ohl2dXIuq0uFGQVswiN2ecX24PeQCQPoVPuy7D3qT4WE2uyC3tHXkuy732C)v)OAlCv(HygKQpCwehbLzjeA6AMqNqPRkYZlEO2a23)3(jqLf09BmYUH0oQcDY(QI1GdQlCo1SUAMP8dmVscKFes9KEc4hXDn)iwMFG5xsG8JOHetfsheHZ1Rpx)Lp5zScN2ILokr9d8rOGz4R2ahz6fHFi8ZVEjE6IAu0vQln4LDJ3CkHYyq9bjmgtShgti1v6VpymXimgmxtagt2k0DbrB9rw80yLWPGF9sV5Yq02j8Ivo4U8sFJ)e22yPW75lN(9Ijz)u9PtT2Xq27JW1XkFCZcRQpZGG9HFF0WlL8uQczdndJDhBHDh)Bm7gD8FMS7yCn3JIDBSrROSBFvFTV6Dw2sq(xYP5Rr2Sj8m9yqm4buNaskBMidls8NK95RuMNyPKQ9XCI4SMykRXIBTewJRGynh2WzK25IkveLfTEVk(VXkmKmEpGAmgGv0WlPMYLGPSZ6sTebOeTrwL6mvQgKCBicdbnoWR2rWOGrWifeSbCSfU6BODwN3DDT4bueoA0igCg4wHsPSvvsbUAoBJvYgTEYF1ARZ8rtZjPYonWQ4mXoluoKVd7ifGdFVSclFZvIY4KL2wB1UjPgCs395ms6gvjj5r628IILZwTF3J6j2wUvqS6P0wQ1OlKBe4yAAz1UKC6wWBG3mDe0lma)Edf2MrWpdDYwmulWrSmp7F4hjl5TwjWYJQsUiAvGHCiSEBU)nuOXzWM8YXYj(YzenWsLcHYHNFFbg8SC65IHy()hffZden6grwCi5dGif48f6ma2s0Kxyj71DbXghoXIUPpxrlgJqbHt(1)Wb)klpvLH9lBrzxYB12BTLH7UGVDXVtj63Blr2DHLG66QtR210l1zrt67yRVVsCuXSUxT4fmKi)42kd83R2px1KKEp1Kv)906QBhA5puJDhM)XcsY03xcURjNA2s6gurKH3N8fybck5rE7AA7v6EzDUKSMgx89a3ws3DkyR5SzQvT26caLPX1U4(Kco7WSwt80pvS2sTXzlv5hbEx8L0D5f7wgmcZ7qWyA7two6aVnRAwRWuEhcgtpIuXxxsSLBtHje3tYqg9VFl1ugeM17R9mvBpSKQhv1cvtQUruMC1YYSaMcgnw1KIYvffjYtnJZSxIMjFFRT)7LIfOzwTZkfqo2lLdHeJmWzzw5LxXsY05gfEN0wUHkVuR96(k1PSUEbHZj9AEHGlvLqDbI3cugPIbJzH)WepopXqsh0RaQR4Nbr9)JLgYbAs)jIt(cMDBSVCjpjB(prBbL5m5YHQF4e(5ghlHbA0TAnM57GY4VGUBHuPNr57jQ0AC9ajmxCypqC6wG29DFSn6GZ4HhVjXjKPD1mr96)vWGmoVi2lYnPjRM(UInmxiTumMV2qlWZdcIlLiOrSn0qcrLGQazOP3iFFPTYJ2(jEW(zsvEm1ciapOJMJUWYIh0TfgBwyok60A4K9s(vcNqGOhrZyKwOFCl0Qt(XwXrhhN1tSMVRkUv5fj7QK92TTlZCglHdHHBcofYzYpGZ6KFMvWOYrqPTwkCAwwq7WTe5KP6ScuTQI0cg(XWxAhB)I2cE0dwyOYIwsp2N73n(k9o6ghyEb3ewEyiUA5U7EshdPWE1bGGKrVDFCCEIBdHBdZ7RxN08Q4KTXe8rXSj61nVAqLokm0bQRMzeHTY46JNIsAQOcciKtHjxNtt4t5)293Rn8FebVcpqOWzq)UvjrbSk1BaamA3YT2GDh547GyxeFfXmrZMhkz8P5O9W4rpKLVKEoFLoAyFqZevPC4V2Sujo9pw49bX7mWp0bXLHYRWmuAe0coA2Z4PYZgndeRfKL6WIBzON132g0WtTJhOPN4r6HAIoHKQpBpIaRAYemXLuCGPBet4hDD9ioD6DH9adSohRfXK54QjWk4T6sJzqAAzIPtcUBILtSTrtSIrw73u(TGS)taOKuJcQB9FRiyxvYmheH5)H9WKusprSYTQL9ZHwClUZUA2wANzZvx))s5Jgj(XD2JNp2912(KkSvWT75OEe7E9Lt5CJP6GAyNEEvSfFnxLc7WY9msDbsaDG8M6pXfrJ(Wnx)qYUnqW1L3Cn9lYaO8r)kmq3jVxLrU)TE1H57s)x7bM9sIUizzMMA2L8GfGvP7slhE4t)eT6EjFTk(yXgyKOV(vSsUr6UQgaiP8GFLCHej9U(rFDW3mW54YKNdxhTHPy6DCAWnZlRudShTjNqGhayLVm5raP2RpH46jf4CWgBhSw15ITRZDQb3jsf2gABEd2Inb0JKRBbEaG1PkSXRpH46jf4CWoUtNzOHZDlW9c2J0uFhdUl6ub1jf4Eb7rA5PJb3LwbNXHwcbSyTjiWJCgXqyQpdWFmIStkW9c2tmh)4SlCsbUxW2rAjV3f4DEEQWhnFDjOb3)H5cx67Rlkd(h6u51jf4c)jh1PZ709wTBH(qYNupKy2AUUSFv7IAZMxLIRPSxP5lzHXvCMbbBbOQX2Rbx8a)df0K74jnakFJAzaM3zbmnEiZQUnDqQ9ARUqB4dsNXaInmC1bcmBaTlW33Id6MRalnyQDXyzamlITJdygMjpkvjBG5OWPXgMkEoaJW6)LnL73smtqaxDQIaaWkbZxP24t3mcBGxuNOiAxQfqQaKOM)4x6uT0aODJZYhinedZAVw1(I7CQyfQgV2JXpzVk0VGhqqz8wPog2dYlKXWwRuhd7H90joF5g(2V0dWhlNTxDCpX(z7g(TGU83E1X1yYlNFUDxXIHjBEC2YTL8ddkcF0w766XHmTz2ra)a8Y956vUPphCPxyuN9211JJBUOD4hal55gErK9iR4Ek7q)aRnNw4F6G8VzyEby4G2KY6Z2)R4BHzd8yhm(E9DnaV8L8hHNGAwdNm6PNcSPV8LUgXjJgWO8JeLdenAdg7dHfIHaI(1XKA)kqDn8pDq(3mm3VQFSHEeYaCIv9rgrxQ(HHYbIgTbJ9HWIGSS5LE995a26k1pwnun7(6JcLiCOeWUp2kLTtn8dbYKWoOfat2MkWJDWRqeqJ2OqX9GhbBr)yf2h76BNA4hcKdGRyPrHI7bpchbFVBM10MzWrEmh)cRRRBZQ3tpz3EOBdIw6h3X5bN1pA4LNBr9gElcaixTndgmTFF3UHyHkTo0rEh6OMHg645kdorm8AnXYGxgnA0Gb8vu(gY1FZVDCDZH(Bmx)nnC9Hwsbgd8KGMAtkWitQcnpHMz2QtZtOnW3D5jKxGmTHdzKqP6b3Oye1qoRfTSbzBzaml7pTrW(XvWyiSTXbA1bP2ayR8V9WLRRd0wYLTl6p6nH4WN(X1mT63luSjNODYatoZIfRYY5NMOYH88iF(K3Ss57kW3LTAcPEgMoQ3l4Fcb69c6IR2(4bC4tyWTHPcaHaZwaS)a9wsbwSRt)MbGJKmRjFh5K)pX48H)DfBNucea9o1ycatcYf8LY(XE3(F0OAYYLnOAZXlZ9xfaQS2ZK42rXhZv3F3rTMtJXjwRN2JwrRD3vUFhWbAkf(qKOp90rWg6Ilz)JMml3FlQGwVupLK2NZAPLpPaswzEE3i)hnrbdeZSYOqac)6WtZMeLs8Dt032Bu)qqinVGBWhrCtkx1LHGKXNqKmgfjJnrs)xr8pZlb)2G18lhFdMlYgqgi6h)Td9JTG(O7FQ8msFxb7pRRK(2qbSRQEm(V62ycwvLFP99DSn0z83k6mgNor2UwbD6z)vvNY39xp6TH80cH1qAIULHN3xrI6Cd8olE0GFprWXojyl7rQGG9VJLCco4Bf8O2G)1PmOzLUSvS16(oXTx8KrdV87iU3tD6yI1CZije)gVbf470v7yAXTHPf)SzAg7rY38D1bFpsQ9iTTx56HW7SCvSRZeJLzIrsSq7jf08nmUR0SS8VKpvYkd5w7oaK(eGTpRuy2b5ngBRtcnnMDqUJX2bHWtLPwMmvtFmUav(SvJ3cTRvD8gXp(10uSqXFTBt9NEc5MuFQfJXYxSxFI3e4fjFfMJq(qNk9m9RqXADtE6zLBA9v8hbhPOO6fcYuP4Fmu1vUimvJ8X6Li(tpr(MS2t57X6vXX(XD2Wa4jxYRIas3v8tI8dq6jmwVt)H)alfDKosYR3NHPQFTQ5aNdmO6oxliZ2SAFzdZtJIa7Rw5bAupOk(0tAD)YNEQVdE4luZsGAR6rLJ6hg8b(5i14a4OivzWumnEKFy0egC9T1myFRjJLxXLzMxZJEHzDJjGYZswmeTjHlNfDHbWvylHdYPejcNguVPTH3jpm6zUPfdIkdwy)q5BUCntT)lu)2sd6e19CiVBG1YzROwQ6H8D8(QjXdA0uAqMMRmdyTJ(C9lrL7l7VGu98ZqDglpUhAEXh0tyP7QlgiB47Q(x86(1k2SBi4PXGT5EVq6g6GtumWtiLEbYwJUeNTYm5PWaOx5gtNmwgHH)sS6m6DcUQbvHrEhJXvJdf)JVSjT8S3thb5C7ZilP93ImYACvfJI3c6NLlk2d6uWAkRVTz6GRUC3(miw3kigkSw2RVyLE99ARHsegU0BHI1jXfJ7NKTflDRFWzRO3iPt5h8ZE2B0vXN1OZQOmgUqrzUAg7Zfa1G3dfZOOa5(FA6iH)BKwPOwZ7wp9zaJF6j1NqucZjavcYdSQxZhsl3B5S5R981qMT0ZzDa1KHYCffJHcNw6w0smIm)MoJl154QeAPycq96mIAoTVOTtJLuLTFHUXn5Db4tJctr9sd91nTBAaWCqOAFrVtXg6Klv(RlSzewtlBs0a3SffMYlC3B3lxPVE1ad97lWwoQ2AmyBPV86h96(1NuncmOn279SGcm9q2XA1zlJFDLYjPQfWLXAKzmbbTJw8iV0BFexkGGf8AEqhfpEoTQVPw4pmB8DmNa3VjUci2LZfPB97kgHUlgVafHc0wIF3xrIfimyF(Lwxcx(fAHttPis0pQrnXhYgpVfU31ZLxlkXnlEmRWI6ExzKTWuxyqsXRpKhKfXHk9Tbglqs8UA6JKYRv8hrdIS5e4EIGdphZ84wwpZYCWZ)GL5lYZg0Ja2Z85b4OjEiEHXrXu8BvpvNceE3X8Cxpdb49m8inAbM87FPSh)uAnIBzkKQ1krJOjocAaj1rKFxnhsFhzNCzzbosXPx)zHMTLM96)c7zpsk1QmpENoIypc75WIohBEKqsVmlP2tIdEXLMsvZnPyE1ye8cmabIKi6M92wIROEzXjVtP6dTl6ocDRdQfAdq6OwMTNQoR6O0PIr1PIDSZgTqNk2Iov83aDQOUvNY8Il5zPtfHOtfzrNYCODpxYUHamDQ4UxNIANQnBxMWqLGtzz76Me5AY2aLnbwOJ5qcB1u3tp1NMR54rw3YSbE32Zg8I)TwDASuAwAdpngNNgYev)80yxkBdu2J42YtJdMNg9nHNs3ca16CHWzdD3vM8(MGsLaXUusfzZt17iW0OvDFbBbPCB8VpYivJ0aDVGMamxSnmT59Urb7tTCHdyOEeBxLTsvTuOzV(JClajUSXS1BS1ytK2KeFybD6iPBZiUm6OBu01zn1qZRRm)0zRnNRGnZ1FL84aoroiNwyA3VPg3MVdel8ym0pw42GNS7517aPTORLIuyYLVgnxGiGcl2q5SVI1f1mFlNk6EUYeSCvlZbgECTEWaPueiEBZMLdVw8ju3YoNl3w(hsDS3Y)aQJ9s1pC6YOs9K(Zdyd)fkok74VKAJ0nxFpShEL8(cCwmVc0rxUsS9r93A7R54tpTf5l54GJfLceHuYsDSC9RWzMIY544WK)pdZbL3OMVKWCB5QOl713trmeQlqt7hgTCoplDOczopvK1hxBrvGmq5C1mrUEhKemyyJXwZ2NIsDZEZIMA7bOkntpo9y5TJbH60mKV11NneLD6W22zD1fTyuIXgLTOFUhRhp5p1J4BaQ)b18l6yV(QeJ03YrPj7iFhhX0xSpSgD3kpCCpuestX)mmbQz6d7qLj8DIr5HAF3f9B)7SldC07gInWbla8oyUw3zctY)Ui)QE4slVCOWjm)8OlcfukfPIFgwW4icxc1Z5WwG7QO39AXomP3hJpvqWARyn3EfsCvuSOdycyep1dfZLrLA7DyFpXKwQ36N6RPrxkseQPnrM1unh)LGSlgGeAkgeZoGz595ucKkC(gkq(Z8MPlqis7ymCxV5ORzGHAuFn6FKEvEw8WlpNplGKOlkjP9H7B6hKM4vs85gV8Arzi2iq2H5DaFunaN9j4ID06Cjp3mh(EApHPAk8SmaeKbySjc9S8gxdKJd(CaZQIhH6nms5CHj9zLPfEHxjNyGXQ1wviU8IQd6XZsQYStaGU8K6gQ(89hDIrbSj9kTrZs7MkVHGOv)cgtujkgCjMSyW)QjoD7dRoqSiqLZsbdVi5YG971jOqTkWvp)dHzsLNq8qgolNX8roZLA9jA4Vatqi3DaZjNFgcvM)4H5)x)L0pNLN9Fx3eXXTxCShxQCcjHHldE4Vc2hpm)hbdK1Ns5eJBobXzYVKEVFq6mXsf4FU485FBk0Su6OLjpkualFmmCXreAkQ8K4Zk3McZfUNKW7ZE75JgE57pNyNulCdvdhwmShMO8QOXOl5mzun18rsIRyh9uzEywnpu7(tjHCROuMTKCovv)Uu2kU7)Me3vdoeW8my2WSSgMTDJQCwogJrLT8ZTMTGD3EC08gBximDltY6cBozu2wMLEB8CmyLMTdk4BuMBUHFupO0FbafyOO6r(m0MkfB(d3NUrWyj3peKjkbzmdaIkUiJgeOqqTAByI6Y78(m)vy3jrlNrwHGFLtHDoV)hoqFybev8)x2(8XEMfH3IqcX(jbTIz8Ql93LFpr1VhHQViqs4VNwFUXkjud1kl5(4ImLCFzYDP4tWVp5l053X1txxtBVs3BwPYYvdJDcgTmCpM15v29Cv3giVQVTKCr21ll5)0RVq8WeEFqHvZBDimglhkdLfe0AY6cqSr3MZf3NuWhxr(R90(WKyhbIv8L0D0mX5dJ4n8KHk8Kc6dvKYEyiOY)BXpjmk5BzzAFZ1j7RUVa(51zR)i97w8n)p]] )