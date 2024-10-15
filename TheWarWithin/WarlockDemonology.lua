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
    abyss_walker                   = { 71954, 389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by 4% for 10 sec.
    accrued_vitality               = { 71953, 386613, 2 }, -- Drain Life heals for 15% of the amount drained over 7.5 sec.
    amplify_curse                  = { 71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    banish                         = { 71944, 710   , 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = { 71949, 111400, 1 }, -- Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    curses_of_enfeeblement         = { 71951, 386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    dark_accord                    = { 71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by 45 sec.
    dark_pact                      = { 71936, 108416, 1 }, -- Sacrifices 5% of your current health to shield you for 800% of the sacrificed health plus an additional 28,722 for 20 sec. Usable while suffering from control impairing effects.
    darkfury                       = { 71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by 15 sec and increases its radius by 2 yards.
    demon_skin                     = { 71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of 0.2% of maximum health every 1 sec, and may now absorb up to 10% of maximum health. Increases your armor by 45%.
    demonic_circle                 = { 100941, 268358, 1 }, -- Summons a Demonic Circle for 15 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects.
    demonic_embrace                = { 71930, 288843, 1 }, -- Stamina increased by 10%.
    demonic_fortitude              = { 71922, 386617, 1 }, -- Increases you and your pets' maximum health by 5%.
    demonic_gateway                = { 71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 90 sec.
    demonic_inspiration            = { 71928, 386858, 1 }, -- Increases the attack speed of your primary pet by 5%.
    demonic_resilience             = { 71917, 389590, 2 }, -- Reduces the chance you will be critically struck by 2%. All damage your primary demon takes is reduced by 8%.
    demonic_tactics                = { 71925, 452894, 1 }, -- Your spells have a 5% increased chance to deal a critical strike. You gain 10% more of the Critical Strike stat from all sources.
    fel_armor                      = { 71950, 386124, 2 }, -- When Soul Leech absorbs damage, 5% of damage taken is absorbed and spread out over 5 sec. Reduces damage taken by 1.5%.
    fel_domination                 = { 71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 90%.
    fel_pact                       = { 71932, 386113, 1 }, -- Reduces the cooldown of Fel Domination by 60 sec.
    fel_synergy                    = { 71924, 389367, 2 }, -- Soul Leech also heals you for 8% and your pet for 25% of the absorption it grants.
    fiendish_stride                = { 71948, 386110, 1 }, -- Reduces the damage dealt by Burning Rush by 10%. Burning Rush increases your movement speed by an additional 20%.
    frequent_donor                 = { 71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by 15 sec.
    horrify                        = { 71916, 56244 , 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear.
    howl_of_terror                 = { 71947, 5484  , 1 }, -- Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    ichor_of_devils                = { 71937, 386664, 1 }, -- Dark Pact sacrifices only 5% of your current health for the same shield value.
    lifeblood                      = { 71940, 386646, 2 }, -- When you use a Healthstone, gain 4% Leech for 20 sec.
    mortal_coil                    = { 71947, 6789  , 1 }, -- Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    nightmare                      = { 71916, 386648, 1 }, -- Increases the amount of damage required to break your fear effects by 60%.
    pact_of_gluttony               = { 71926, 386689, 1 }, -- Healthstones you conjure for yourself are now Demonic Healthstones and can be used multiple times in combat. Demonic Healthstones cannot be traded.  Demonic Healthstone Instantly restores 25% health. 60 sec cooldown.
    resolute_barrier               = { 71915, 389359, 2 }, -- Attacks received that deal at least 5% of your health decrease Unending Resolve's cooldown by 10 sec. Cannot occur more than once every 30 sec.
    sargerei_technique             = { 93179, 405955, 2 }, -- Shadow Bolt damage increased by 8%.
    shadowflame                    = { 71941, 384069, 1 }, -- Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowfury                     = { 71942, 30283 , 1 }, -- Stuns all enemies within 10 yds for 3 sec.
    socrethars_guile               = { 93178, 405936, 2 }, -- Wild Imp damage increased by 10%.
    soul_conduit                   = { 71939, 215941, 1 }, -- Every Soul Shard you spend has a 5% chance to be refunded.
    soul_leech                     = { 71933, 108370, 1 }, -- All single-target damage done by you and your minions grants you and your pet shadowy shields that absorb 3% of the damage dealt, up to 10% of maximum health.
    soul_link                      = { 71923, 108415, 2 }, -- 5% of all damage you take is taken by your demon pet instead.
    soulburn                       = { 71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by 50% and makes you immune to snares and roots for 6 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for 30 sec. This shield cannot exceed 30% of your maximum health. Health Funnel: Restores 140% more health and reduces the damage taken by your pet by 30% for 10 sec. Healthstone: Increases the healing of your Healthstone by 30% and increases your maximum health by 20% for 12 sec.
    strength_of_will               = { 71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional 15%.
    sweet_souls                    = { 71927, 386620, 1 }, -- Your Healthstone heals you for an additional 10% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    swift_artifice                 = { 71918, 452902, 1 }, -- Reduces the cast time of Soulstone and Create Healthstone by 50%.
    teachings_of_the_black_harvest = { 71938, 385881, 1 }, -- Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target 4% damage reduction for 5 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by 30 sec. Felhunter: Reduces the cooldown of Devour Magic by 5 sec. Sayaad: Reduces the cooldown of Seduction by 10 sec and causes the target to walk faster towards the demon. Felguard: Reduces the cooldown of Pursuit by 5 sec and increases its maximum range by 5 yards.
    teachings_of_the_satyr         = { 71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by 15 sec.
    wrathful_minion                = { 71946, 386864, 1 }, -- Increases the damage done by your primary pet by 5%.

    -- Soul Harvester
    annihilan_training             = { 101884, 386174, 1 }, -- Your Felguard deals 20% more damage and takes 10% less damage.
    antoran_armaments              = { 101913, 387494, 1 }, -- Your Felguard deals 20% additional damage. Soul Strike now deals 25% of its damage to nearby enemies.
    bilescourge_bombers            = { 101890, 267211, 1 }, -- Tear open a portal to the nether above the target location, from which several Bilescourge will pour out of and crash into the ground over 6 sec, dealing 5,385 Shadow damage to all enemies within 8 yards.
    blood_invocation               = { 101904, 455576, 1 }, -- Power Siphon increases the damage of Demonbolt by an additional 25%.
    call_dreadstalkers             = { 101894, 104316, 1 }, -- Summons 2 ferocious Dreadstalkers to attack the target for 12 sec.
    carnivorous_stalkers           = { 101887, 386194, 1 }, -- Your Dreadstalkers' attacks have a 10% chance to trigger an additional Dreadbite.
    demoniac                       = { 101891, 426115, 1 }, -- Grants access to the following abilities:  Demonbolt Send the fiery soul of a fallen demon at the enemy, causing 16,578 Shadowflame damage. Generates 2 Soul Shards.  Demonic Core When your Wild Imps expend all of their energy or are imploded, you have a 10% chance to absorb their life essence, granting you a stack of Demonic Core. When your summoned Dreadstalkers fade away, you have a 35% chance to absorb their life essence, granting you a stack of Demonic Core. Demonic Core reduces the cast time of Demonbolt by 100%. Maximum 4 stacks.
    demonic_brutality              = { 101920, 453908, 1 }, -- Critical strikes from your spells and your demons deal 4% increased damage.
    demonic_calling                = { 101903, 205145, 1 }, -- Shadow Bolt and Demonbolt have a 10% chance to make your next Call Dreadstalkers cost 2 fewer Soul Shards and have no cast time.
    demonic_strength               = { 101890, 267171, 1 }, -- Infuse your Felguard with demonic strength and command it to charge your target and unleash a Felstorm that will deal 300% increased damage.
    doom                           = { 101919, 460551, 1 }, -- When Demonbolt consumes a Demonic Core it inflicts impending doom upon the target, dealing 43,984 Shadow damage to enemies within 10 yds of its target after 20 sec or when removed. Damage is reduced beyond 8 targets. Consuming a Demonic Core reduces the duration of Doom by 4 sec.
    doom_eternal                   = { 101906, 455585, 1 }, -- Demonic Cores reduce the duration of Doom by an additional 2 sec.
    dread_calling                  = { 101889, 387391, 1 }, -- Each Soul Shard spent on Hand of Gul'dan increases the damage of your next Call Dreadstalkers by 2%.
    dreadlash                      = { 101888, 264078, 1 }, -- When your Dreadstalkers charge into battle, their Dreadbite attack now hits all targets within 8 yards and deals 10% more damage.
    fel_invocation                 = { 101897, 428351, 1 }, -- Soul Strike deals 20% increased damage and generates a Soul Shard.
    fel_sunder                     = { 101911, 387399, 1 }, -- Each time Felstorm deals damage, it increases the damage the target takes from you and your pets by 1% for 8 sec, up to 5%.
    fiendish_oblation              = { 101912, 455569, 1 }, -- Damage dealt by Grimoire: Felguard is increased by an additional 10% and you gain a Demonic Core when Grimoire: Felguard ends.
    flametouched                   = { 101909, 453699, 1 }, -- Increases the attack speed of your Dreadstalkers by 10% and their critical strike chance by 15%.
    foul_mouth                     = { 101918, 455502, 1 }, -- Increases Vilefiend damage by 20% and your Vilefiend's Bile Spit now applies Wicked Maw.
    grimoire_felguard              = { 101907, 111898, 1 }, -- Summons a Felguard who attacks the target for 17 sec that deals 45% increased damage. This Felguard will stun and interrupt their target when summoned.
    guillotine                     = { 101896, 386833, 1 }, -- Your Felguard hurls his axe towards the target location, erupting when it lands and dealing 4,721 Shadowflame damage every 1 sec for 6 sec to nearby enemies. While unarmed, your Felguard's basic attacks deal damage to all nearby enemies and attacks 50% faster.
    immutable_hatred               = { 101896, 405670, 1 }, -- When you consume a Demonic Core, your primary Felguard carves your target, dealing 7,253 Physical damage.
    imp_gang_boss                  = { 101922, 387445, 1 }, -- Summoning a Wild Imp has a 15% chance to summon a Imp Gang Boss instead. An Imp Gang Boss deals 50% additional damage. Implosions from Imp Gang Boss deal 50% increased damage.
    impending_doom                 = { 101885, 455587, 1 }, -- Increases the damage of Doom by 30% and Doom summons 1 Wild Imp when it expires.
    imperator                      = { 101923, 416230, 1 }, -- Increases the critical strike chance of your Wild Imp's Fel Firebolt by 15%.
    implosion                      = { 101893, 196277, 1 }, -- Demonic forces suck all of your Wild Imps toward the target, and then cause them to violently explode, dealing 10,182 Shadowflame damage to all enemies within 8 yards.
    improved_demonic_tactics       = { 101892, 453800, 1 }, -- Increases your primary Felguard's critical strike chance equal to 30% of your critical strike chance.
    inner_demons                   = { 101925, 267216, 1 }, -- You passively summon a Wild Imp to fight for you every 12 sec.
    mark_of_fharg                  = { 101895, 455450, 1 }, -- Your Summon Vilefiend becomes Summon Charhound and learns the following ability:  Infernal Presence Cloaked in the ever-burning flames of the abyss, dealing 2,012 Fire damage to enemies within 10 yards every 0.8 sec.
    mark_of_shatug                 = { 101895, 455449, 1 }, -- Your Summon Vilefiend becomes Summon Gloomhound and learns the following ability:  Gloom Slash Tooth and claw are drenched in malignant shadow magic, causing the Gloomhound's melee attacks to deal an additional 2,564 Shadow damage.
    pact_of_the_eredruin           = { 101917, 453568, 1 }, -- When Doom expires, you have a chance to summon a Doomguard that casts 5 Doom Bolts before departing. Each Doom Bolt deals 18,769 Shadow damage.
    pact_of_the_imp_mother         = { 101924, 387541, 1 }, -- Hand of Gul'dan has a 15% chance to cast a second time on your target for free.
    power_siphon                   = { 101916, 264130, 1 }, -- Instantly sacrifice up to 2 Wild Imps, generating 2 charges of Demonic Core that cause Demonbolt to deal 30% additional damage.
    reign_of_tyranny               = { 101908, 427684, 1 }, -- Summon Demonic Tyrant empowers 5 additional Wild Imps and deals 10% increased damage for each demon he empowers.
    rune_of_shadows                = { 101914, 453744, 1 }, -- Increases all damage done by your pet by 4%. Reduces the cast time of Shadow Bolt by 25% and increases its damage by 40%.
    sacrificed_souls               = { 101886, 267214, 1 }, -- Shadow Bolt and Demonbolt deal 2% additional damage per demon you have summoned.
    shadow_invocation              = { 101921, 422054, 1 }, -- Bilescourge Bombers deal 20% increased damage, and your spells now have a chance to summon a Bilescourge Bomber.
    shadowtouched                  = { 101910, 453619, 1 }, -- Wicked Maw causes the target to take 20% additional Shadow damage from your demons.
    soul_strike                    = { 101899, 428344, 1 }, -- Teaches your primary Felguard the following ability:  Soul Strike Strike into the soul of the enemy, dealing 11,219 Shadow damage. Generates 1 Soul Shard.
    spiteful_reconstitution        = { 101901, 428394, 1 }, -- Implosion deals 10% increased damage. Consuming a Demonic Core has a chance to summon a Wild Imp.
    summon_demonic_tyrant          = { 101905, 265187, 1 }, -- Summon a Demonic Tyrant to increase the duration of your Dreadstalkers, Vilefiend, Felguard, and up to 15 of your Wild Imps by 15 sec. Your Demonic Tyrant increases the damage of affected demons by 15%, while damaging your target.
    summon_vilefiend               = { 101900, 264119, 1 }, -- Summon a Vilefiend to fight for you for the next 15 sec.
    the_expendables                = { 101902, 387600, 1 }, -- When your Wild Imps expire or die, your other demons are inspired and gain 1% additional damage, stacking up to 10 times.
    the_houndmasters_gambit        = { 101898, 455572, 1 }, -- Your Dreadstalkers deal 50% increased damage while your Vilefiend is active.
    umbral_blaze                   = { 101915, 405798, 1 }, -- Hand of Gul'dan has a 15% chance to burn its target for 12,090 additional Shadowflame damage every 2 sec for 6 sec. If this effect is reapplied, any remaining damage will be added to the new Umbral Blaze.
    wicked_maw                     = { 101926, 267170, 1 }, -- Dreadbite causes the target to take 20% additional Shadowflame damage from your spell and abilities for the next 12 sec.

    -- Diabolist
    abyssal_dominion               = { 94831, 429581, 1 }, -- Summon Demonic Tyrant is empowered, dealing 70% increased damage and increasing the damage of your demons by 20% while active.
    annihilans_bellow              = { 94836, 429072, 1 }, -- Howl of Terror cooldown is reduced by 15 sec and range is increased by 5 yds.
    cloven_souls                   = { 94849, 428517, 1 }, -- Enemies damaged by your Overlord have their souls cloven, increasing damage taken by you and your pets by 5% for 15 sec.
    cruelty_of_kerxan              = { 94848, 429902, 1 }, -- Summon Demonic Tyrant grants Diabolic Ritual and reduces its duration by 3 sec.
    diabolic_ritual                = { 94855, 428514, 1, "diabolist" }, -- Spending a Soul Shard on a damaging spell grants Diabolic Ritual for 20 sec. While Diabolic Ritual is active, each Soul Shard spent on a damaging spell reduces its duration by 1 sec. When Diabolic Ritual expires you gain Demonic Art, causing your next Hand of Gul'dan to summon an Overlord, Mother of Chaos, or Pit Lord that unleashes a devastating attack against your enemies.
    flames_of_xoroth               = { 94833, 429657, 1 }, -- Fire damage increased by 2% and damage dealt by your demons is increased by 2%.
    gloom_of_nathreza              = { 94843, 429899, 1 }, -- Hand of Gul'dan deals 15% increased damage for each Soul Shard spent.
    infernal_bulwark               = { 94852, 429130, 1 }, -- Unending Resolve grants Soul Leech equal to 10% of your maximum health and increases the maximum amount Soul Leech can absorb by 10% for 8 sec.
    infernal_machine               = { 94848, 429917, 1 }, -- Spending Soul Shards on damaging spells while your Demonic Tyrant is active decreases the duration of Diabolic Ritual by 1 additional sec.
    infernal_vitality              = { 94852, 429115, 1 }, -- Unending Resolve heals you for 30% of your maximum health over 10 sec.
    ruination                      = { 94830, 428522, 1 }, -- Summoning a Pit Lord causes your next Hand of Gul'dan to become Ruination.  Ruination Call down a demon-infested meteor from the depths of the Twisting Nether, dealing 139,221 Chaos damage on impact to all enemies within 8 yds of the target and summoning 3 Wild Imps. Damage is reduced beyond 8 targets.
    secrets_of_the_coven           = { 94826, 428518, 1 }, -- Mother of Chaos empowers your next Shadow Bolt to become Infernal Bolt.  Infernal Bolt Hurl a bolt enveloped in the infernal flames of the abyss, dealing 72,964 Fire damage to your enemy target and generating 3 Soul Shards.
    souletched_circles             = { 94836, 428911, 1 }, -- You always gain the benefit of Soulburn when casting Demonic Circle: Teleport, increasing your movement speed by 50% and making you immune to snares and roots for 6 sec.
    touch_of_rancora               = { 94856, 429893, 1 }, -- Demonic Art increases the damage of your next Hand of Gul'dan by 100% and reduces its cast time by 50%.

    -- Soul Harvester
    demoniacs_fervor               = { 94832, 449629, 1 }, -- Your demonic soul deals 100% increased damage to the main target of Hand of Gul'dan.
    demonic_soul                   = { 94851, 449614, 1, "soul_harvester" }, -- A demonic entity now inhabits your soul, allowing you to detect if a Soul Shard has a Succulent Soul when it's generated. A Succulent Soul empowers your next Hand of Gul'dan, increasing its damage by 60%, and unleashing your demonic soul to deal an additional 25,528 Shadow damage.
    eternal_servitude              = { 94824, 449707, 1 }, -- Fel Domination cooldown is reduced by 90 sec.
    feast_of_souls                 = { 94823, 449706, 1 }, -- When you kill a target, you have a chance to generate a Soul Shard that is guaranteed to be a Succulent Soul.
    friends_in_dark_places         = { 94850, 449703, 1 }, -- Dark Pact now shields you for an additional 50% of the sacrificed health.
    gorebound_fortitude            = { 94850, 449701, 1 }, -- You always gain the benefit of Soulburn when consuming a Healthstone, increasing its healing by 30% and increasing your maximum health by 20% for 12 sec.
    gorefiends_resolve             = { 94824, 389623, 1 }, -- Targets resurrected with Soulstone resurrect with 40% additional health and 80% additional mana.
    necrolyte_teachings            = { 94825, 449620, 1 }, -- Shadow Bolt damage increased by 20%. Power Siphon increases the damage of Demonbolt by an additional 20%.
    quietus                        = { 94846, 449634, 1 }, -- Soul Anathema damage increased by 25% and is dealt 20% faster. Consuming Demonic Core activates Shared Fate or Feast of Souls.
    sataiels_volition              = { 94838, 449637, 1 }, -- Wild Imp damage increased by 5% and Wild Imps that are imploded have an additional 5% chance to grant a Demonic Core.
    shadow_of_death                = { 94857, 449638, 1 }, -- Your Summon Demonic Tyrant spell is empowered by the demonic entity within you, causing it to grant 3 Soul Shards that each contain a Succulent Soul.
    shared_fate                    = { 94823, 449704, 1 }, -- When you kill a target, its tortured soul is flung into a nearby enemy for 3 sec. This effect inflicts 6,377 Shadow damage to enemies within 10 yds every 0.8 sec. Deals reduced damage beyond 8 targets.
    soul_anathema                  = { 94847, 449624, 1 }, -- Unleashing your demonic soul bestows a fiendish entity unto the soul of its targets, dealing 24,432 Shadow damage over 10 sec. If this effect is reapplied, any remaining damage will be added to the new Soul Anathema.
    wicked_reaping                 = { 94821, 449631, 1 }, -- Damage dealt by your demonic soul is increased by 10%. Consuming Demonic Core feeds the demonic entity within you, causing it to appear and deal 12,509 Shadow damage to your target.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bonds_of_fel     = 5545, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the 8 yd radius they explode, dealing 65,466 Fire damage split amongst all nearby enemies.
    call_fel_lord    = 162 , -- (212459) Summon a fel lord to guard the location for 15 sec. Any enemy that comes within 6 yards will suffer 39,025 Physical damage, and players struck will be stunned for 1 sec.
    call_observer    = 165 , -- (201996) Summons a demonic Observer to keep a watchful eye over the area for 20 sec. Anytime an enemy within 30 yards casts a harmful magical spell, the Observer will deal up to 8% of the target's maximum health in Shadow damage.
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

local ExpireNetherPortal = setfenv( function()
    summon_demon( "pit_lord", 10 )
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
                if talent.secrets_of_the_coven.enabled then applyBuff( "infernal_bolt" ) end
            end

            if buff.art_pit_lord.up then
                summon_demon( "pit_lord", 5 )
                removeBuff( "art_pit_lord" )
                if talent.ruination.enabled then applyBuff( "ruination" ) end
            end

            if talent.diabolic_ritual.enabled then
                if buff.diabolic_ritual.down then applyBuff( "diabolic_ritual" )
                else
                    if buff.ritual_overlord.up then buff.ritual_overlord.expires = buff.ritual_overlord.expires - amt; if buff.ritual_overlord.down then applyBuff( "art_overlord" ) end end
                    if buff.ritual_mother  .up then buff.ritual_mother  .expires = buff.ritual_mother  .expires - amt; if buff.ritual_mother  .down then applyBuff( "art_mother"   ) end end
                    if buff.ritual_pit_lord.up then buff.ritual_pit_lord.expires = buff.ritual_pit_lord.expires - amt; if buff.ritual_pit_lord.down then applyBuff( "art_pit_lord" ) end end
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
    if buff.art_mother.expires > query_time - time and buff.art_mother.down then
        summon_demon( "mother_of_chaos", 6 )
        removeBuff( "art_mother" )
        if talent.secrets_of_the_coven.enabled then applyBuff( "infernal_bolt" ) end
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
    },
    diabolic_ritual_mother_of_chaos = {
        id = 432815,
        duration = 20.0,
        max_stack = 1,
    },
    diabolic_ritual_pit_lord = {
        id = 432816,
        duration = 20.0,
        max_stack = 1,
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
        if imp - query_time <= 2 * haste then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "two_cast_imps", function ()
    local count = 0

    for i, imp in ipairs( wild_imps_v ) do
        if imp - query_time <= 4 * haste then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "last_cast_igb_imps", function ()
    local count = 0

    for i, imp in ipairs( imp_gang_boss_v ) do
        if imp - query_time <= 2 * haste then count = count + 1 end
    end
end )

spec:RegisterStateExpr( "two_cast_igb_imps", function ()
    local count = 0

    for i, imp in ipairs( imp_gang_boss_v ) do
        if imp - query_time <= 4 * haste then count = count + 1 end
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
    }
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

    potion = "spectral_intellect",

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


spec:RegisterPack( "Demonology", 20241006, [[Hekili:T3t)VTTU1(3sWf11oPXXsoPn3HypC39(2dR4I9gEPB73IJITCIwLT8KKBAac8F7pskrk(X5qszl3wm8WgUT1I8WZx88fpI6UG7(0D3UiQm(U)A4OWldgn69ddgD54WpC3TLVSj(UB3en)Zrps(lRJwr(V)w8QS1zPzp(c9rVKMfTGcIIST5Zjp(PYYnf)HlU4XKYN2(WW5zRUOiz120OYKS1ZZJwws)3ZV4H0ShUyrE0JzRxMM84tLxeV(XK1XxmpnQOy2QSfBtJlUiAt6fphLNMn)ZdNVzZD3(W2K0Y)Y67EaeRhrW6InXZj)87FpbzswSiUASXfZV7w6yppy05JE)Fy39)oDvFBXU7)42fpUkED5UpU7JSrm6Npp8sYiUnz1VU7(n5jz5jLVS7(TBOlzZWUMmS3T7EYFoEKxdFuizy)YI)12IYD3VmlF39RJFE39)6VT7(fBZzSOIMX)HZdhtg)NEkE39)ZiYG)NeEAY6D33VilNaGSLdU720KIYcQaiPmEf9V8xzs041rpKgV4U)0D3gnNcxI0mpz9NJldiCO0Ss5)92I4zzlxo7X5lOt)25e8popj6UB)se5piaAy9GNfm7HTlxsyA92D)j7Uh45RIwVnkLnG(SXSjUC4cQstY8zLVKhTUCifL(smBm1tCyzWW5rfLZktwrEWucxD39V(kda2gYa(czzv4GjkLiKhwSDfzuZ0gBn)QAWguvJmDYU7dzl58SS0fzpVgbE5XRIsictkAgoIZU8KveouaDbCUX)L8SD3FLeNXGAcNf)15PBxeBYHdh(uuXm(cv9CROLB2vaQUsOqxzacGQ02MX3Bq4MeaUKUVDwngCxjzRUDf(qnf(WwPWh6qHpCVv4dDRWdmKVdk8bhDf(GJRcFaUcFGnfEi0Yn7k0dJJyk8HEPWpUdTWdJNTZiVmpFr0ksWcZWuKCAqrifTz13PYLFEoOJIUsSF9gHElUnG654NEjrPJejsjDpw9EIbuH3LDO1kydsTZGLVcVqp2Cyk8aSG1AHhSvqFfEbDPW7knHxviXfBEzfbdJZlM9C8dMcmUiwFCncs72jvmaqiwI046kQLsAdLaBE8gsOHdlkjXSxz8y8ijptw3PlXVtkgQIRcHIv1njDdaiuZ)biMWrqB6n0U8chTACXjoIrLc(Kt2atn59GQjjR2eNVKOvnlQyE86frRN)YSI48TRWvzSnhFvFiWuX98iubX4ruS)dAypgUrN4SNIwVGBYQ5hiq5Ae7CRsYZZYjaC2YCYVTnpEXSYSvzKF95czIsvszDAW78TA(kSlaAax0ANOiCJF2PlB)Dj7RfBVC3AeRabzdg50hL)(G8fB9Y)IHZXsY)72knzYUdO0FBWuDfEQHNgA7X8Kvzj5XZwgN(42O8fIul4JiFBY6OQ)Ad8bchZ6kU7(tR2rUk6RcFH5XFHU7AirtF1M0Sc2AizcO(NaIEW2AjwLt5RlZDb3qX8S8yUNcse0)CJdfLrSDdxmwKTnDwXtewdd8xcBgXYQit5dAiq2qFilTeYdRVIV5rPPZwKhhTGSyPFMyrhYqSVqRo2GVKKgVmjUYGMUzXwclv7ZqwiTbWGrA8lcKkkZJx)y5tq2xAGfQ0Ga1XGHxOI(BYEooFwrYMNQ0anmo8FCQGb4MqKx)P8u9oyYUbpOopPErECBkXvpdzumbLSEzC(6O0zmCvXmujLkwgTL87CRG8zf9vIn3SIcn7wy1nHTvQ6FmJwEXQImoRYth3woyIOAADaLgiqrZQeXQgoMGNlKJekEGq)yA7HkuiXbEsuAbKXiSiHSYXQkmRvJrwqUX624WwMgNGwTvjYxs4uEzson7kglJLKfrnN4FDEP)Ky2M41X52TP5xExgBFcU0tCOXUkUTqFXb6w7R0krZ64Vk4sZR3(FLl)pwmw2cCzSdptggSmnRjTWvPcUiUYKuw2kM916eBQM5qXehsIOV68zy6NYZsnfoEY)2SE3NNhkVYKmRPeDTphRwpYgEJ0iK5iAgy7jajj4TzjR)s2CwGAnqTc5mDFuNuQ2d6ZE25S)sLreYgR4vjXfCZ(d4)FJi4eSoz0IXWeitpFRcrLjtIw28xMNsSHhL)yCzbDFPWZq785ZQiGjRq8RYbZVHGISjxmBjj3M69xiUmD4jWA8hTGxiVJZiWe8yJpHjjZJswml(lu5r0IffdPhLgvl4kMOw9PdBkbREycArEfCLSR2hi7llMNTLiOi(Ox9a1oGQx3aC3a9L4f6lLAfOB2dzmonv(QnC6KE8xPhByfSWEwpZhjlkEVcN5XTjPKmZswhZOrC)paBNcCWGX9PyhyqYck8W9pabpox8)mKmHJ8jJ2q)IaEV2bpclAw66IBsR85SzSYatshUqQuYcZv00KTLqn)z2y4DZIyrSb7pzC1QR)KgZYPuCYaXKeYk1iie3yCtLyi)rwkrerE0wIea05QmLJob541otDYOXcy48bXTsiUjD3i2(qjnigrhEzY8KswigsN)GgjQTDqY9e5hjBjAuTXlSrFJuBfPwkB3Xmct0qIQZlwL)tMEY6hBMZ5sZzQNRZG2UDp4dGXynHDITa)6L(hmhWEPQIEoWw(0H4UFbLaNS3lKUpqxbLdhx(aeBd8Oxb3MXJ2tY9fyXt699lACGOUhlfqTROqHcioepqbulrY1PaY4edRoxqq)7TjXLBl4ucMzR9OACczLPuQTl)ySY335AEyz30hjtrwbGAHRb7K)bQUmUnNuGhfuetAGvMToxAyl1BXEy5SMuk6YLs2v)gkeWJv5eluul8azlLXX4XxyPKC(U4NPgpaqHBgRK7OLI7(xhJ72QUzkmp3xbEwx1k1IkWgI9eOy19Py2)QU)yz4XhKXy5yCuWxY)KeE8CssxrnLJgoUEWodjkLteCTaXXZrCYwerMpj6mQ6qdYqD2SiBfpJMsZcCBWZ2NLPwosMoJFOTezKrwelvMe(Mc6FlDl5pccR6g58KnvJ42yAYbL0U8TPPt(etKT7EYdPQ80ml2SnLK7rzgDN4NjdoI(pkPnYtaXPBbHBVEbbqPzRFKTSI6cRxE3sZcUtrBsUkWOnoKKLJvwhmof1gFvke9VmNKy(AkHZAd6AQpE(2swwuvAfzl3D))Dna3D)FUgI7UNw4g2mkQ5olByy0z)3iCkb)UIIGqm2Yfl4j6bO3z8e9D(hkl5FWbKeNOTSdtCsJBOBVPZ4gOAi1PGFC4zpKv(eSYueLpcYsn3cQWj5U9lnpUfMvGTpyXkGQyqZdISSG5gHp6gZTQYlRmfHQaT)w)1i6REWNyaMr5rKFKixtOtLAl5w2Auv)65SbxTcomOOh6nLdqmfBZo4iq7Gm85HISucXT7EciswTDDLmmyKIC(ptXdnlLoXt9iZ9WETmmtwpR5SUmoCh3atQ7wO9Dm98ePUD04e)grxCn1DCYs5T3FQAYSefskyoaOtw6bn6U8Fjn7XK5YuGwdfXOdDVZTGocpe6iSdOJqj6q3FFlOdwpMLV9HxM98tXPBib)gt3QRqo)zQQ3)db1(7fnurrLLbABjXempNqn0q)PT0rfVK28EKb9s2wsq9zun1Nz6Ruh5SHqj26iLaLt19UoJcBF4gQn82btHHDpfgQqHqrM4jfI2rNQJWwlvczqIq6KOYObckZsO00TCHoLsxMLMM9CLbSF5V97evwIUFTr210XXuOJ2wMTIeG6CRBnR6qBg)akQep5h(0JShb(ryxZpcL5hqXL4j)iyi1uH0lxXz69CS7wc9uEZGJyPJru)MyfY4g(QmWr3Er5hnX5x5IN5uJHUstPgVWnElOegJbmge)ymHoym(0RS)yWycbymqHMqymjlbpobn)J8kIa1wQn8R34SOanJDIObS9EkVX16pHFEqk8EH70FPzt2Vt3KXdmK)8ayDSIxwphv9zwCAb5VpA4vsrkvcC6Q(XUdry3HFNz3GR)bYUdH1C3l2DismOQSBxDuURE4w2sq6xsz1Rr2Sj530ZbXGhWcciQOEJmXjXFsoMVczEcsBI7I5eiynHmwdsyTuwJTKynxw)zK4CrLEjdrR3PI)fOWqY49aMXycScgEfZuUemLdwxAKaaLQnY7XPPsDVLDdrqiOXlXlocg4ncgOGG1GJ74QVH2zvbS11IhWq4GrJ4WzGDfkLwXvPwYQfRT6a4XQIQ2yT21sSAsQuYEEV61uI(IHIJQgOzAup)zFkClV)x5LTfRPxP9ttC(NtOLBuLKKxPhsZYwmB528x0ROT8Oi5QhZgP2GUuEqKatJlkZJszNLTbExNyU1QnRCeVvhcDZjBaFALnRp(BiIZ1AI7JcWl4CddL7z)06vQwTAxiGRSHJTWD2QI6esFevk6kxRcfXMBsMieVYfBIOvQQNAB308GB4bhEMXjplvQmqF8s9XrLfxPE4r9e8R2Kj9ybjkDmzDbI3cug4iZdvAcbR9hTuBTJRZ2fu0)VOyT872a(gBFphXBQ6byqhpw3txD8PU7yOwq4MNpCtR8aZQhazMa44wm97bDWVWRX0UspuV3pAWDJEve)azLuvnTDI0KdGhFFtJsFjQfD8oTvGgHyOHeIkb1gKH5roDBbwRXG3TB4DIJ8AQ5gKRDPYiQBBTfzpRBji08SKuu30Wj8MYrcNaGOdrZyGrO3QDA9i1yuC0Y7lYrwZ32MoLheLtsnkPCwAw(c77kX8oCvlWTgofWRgxBdPaKz5nQShuARLchhl2An2yGvMQ1MM47LD52X2VSTGhSP29vw0s6bFVF3ePWyv2rpZcF1CO6GnXTJSlaNd1O2WXJXJp4C1UqdStsLbOs)fI1gPWDv8ahzSz59eQVExaj6rbEA3ckWCi6D5O6BdIL2EODnvDTmEpLsHwLsOnKTHxzjFGtKFr6SW(gypbyJt6srSi1MYiDgI0638S6oNSLS3rMwnNW4bcfzuMr9ly3abdreBXyt2IRCST8QI1f57imCPLydGHpLab8trtfYgYEv()DqNGLIcamDHGUAVVc6sYXWMoS6wepIwurrlsMWY7Kgk4r9fBMDHwc0DswjtqEntmgckgzDtK2TSjABlFfw9oBBK0Wot8Z9jE89kP8gQCRmGwdwTcnB)oFGtmGx9RUpdy)mlkUn0KpNe1xiEO6k5E5hPKgg2n4G8QQ0bwTQDyeqOrQJKeOE9NGT81YwrVXVnS(h9qfr7iUMZfFHYrOtyJjlOxmWPK)7FH9UbsFeT1GLBlo52MRG18W0jtnotstTPf6EiMmSy2QLiVkua3Cuimv8InXeBipr7Se2)(9mZ9JgE11vNOtD721QU5XHacITPXW(1NIN)zEZgiZusQykADvDeTxPlsO3lO)MQ1WwXU(VKyxAWHcgfUhQNSP)r7EYoJ7bh8EiSR5Rn68qXYHW1)uR56q9J7EZ6X6wCdzGdbGLi7L0SBFFinYO0S1MiuBBvzPeq998vsNkVAvMr1FV2pR6KsRdRM)YoSyg1lO873J1w65lKfpjLDjUvBQG)Mq)8tXRBKy0g9KAMuWoK5aShau2WUIyd9NyzA(6G4gErR8cew5x)dl8lsGfQmS)(gq2LSpL3dvAZUIVD5pOe91G1k19wWw4Rw)6Kv)6)Pzi2sh8MMl2q0QNbNFQJI0qC5E9ExeGR1ew)VXvx4tKr(Bvy3U7)vM91TfrpgdBt(POVWmjhwzHDfB8ktVoye0g0h(1eeQWUULSvS2e13S)vzeCM1YIZFkktWpmpImhZtfTrU)aalE6EI4zFjoNvFDFXyXe8hvBvSZ4OQ4Oa8fvLo7a)q1Q0Ci6ZuSI95(y0phE5D3(Cu(AIgizfzbEqmNX(QyW0vFBc9sx7T7Upp(FVL4lFbn3o278svFPr)bISD9JXfd39XFN1zYb)bQA7AYkXE8B5TlK0DhobG0wB(TYnbL0Z6h81bFZaNLl3FbC94daGZ1Pg3mV8ynWEWHCebUhGv(Y9haKAp(iIRhvGlaBioyr15cX15o2G7iPcJH2M3OWqBaDi56wG7byTQcB84JiUEubUaSJ70DgA4C3cCNGDpn13XG7YovqDubUtWUNwE6yWDfk4mEHRaal0y8c8aVFBam1da87Ji7OcCNG9iZX3p7chvG7eSDKwY12aV13fm4vZ1u8AXD)IObl9DnfLf)N7u51rf4nXtoQt33PhTA3c9H0pXHa5SvF9L)22L1gwIrnDyYB1ILuQ3tWsccbOQnIIgCH7sfFbn9IEsdGYxRwgG59iGPocz(LoQoi1Emk4n0t7uWhAy8QZ4VHF4iOpGb0UaFnS1vn76RzlnyQD5BzameX2EbSXg763lnvmWSF4esoKTeyGMFexyvT0aeUXr5xMnadJAp2HzcHJcRq14XQqfpPnGlhcaugEuQRbEsw(SgyJsDnWt7Otc(Xo8tqVWeGxlRJxDDpYX5Ah(TGUCpEhERe8Zn5zZhgT(Lzl2uiErsb4JyJRRxh62Mz7b89ikZdnQ4adVqcPNFuh(4661Xoxeh(EWso0W7dWZSrePQf9dOXCCH)XdYF3W8mIHd2qQBsK3koM1A4XFP67132c8M3i(j4ceZh4KrV(QNd9nVX2koz0aoLVNOSNOrBWyxiSLO6fB8ClGHhJJSgoq4F8G83nm3TQFOHEeWcCKv9bwrBQ((HYEIgTbJDHWnzgHfLE1DbbKFLQFwn)k8y9bHsamu840)ALY2Xg((azAAhSZ7pzDjjIDsuHaGgCq(I7EVcyz)Gc791)2Xg((azp4kidYxC37vyp47DZUM2SdoWH54tq9RJz171xXThA3GiY8ebop40(bdV6me1BYtbaa9AXzWGP97BpmeeQeDPdCU0b1lnzINPS4uXW5AILbVjy0ObdeEu(gY1V47hx3CP)gZ1VOMRpePeyIEVOn1)sVEp0xJdrRt34i38n(Kl8DmghvxQZQeRzrFQMTr)GRbD03StJfaPQ36D8Pg8XEHhFR9Yzw9wY0sz5rG5U7J)fgErb418xsA6TbArjDHV7wc(8uw(D3EBYQFL(A4KTmH20HvdSyOOSSNn5c1R4)3LSCc945NoQ3jIBZ)ENW8vHDp(V7JqWTMftacfMTay)eRTw5T5CxD99dJK89(VJ2WKtmUDRFx2MjfecG1SMtiWKICEF)OVVxZ(7nQgTyrnQwbahxq)mzTJ9BTJI3NBr)UJAn3udtSOVTZTIw7UB)(oGdu3j6(irF919Gn0f3397nzwS9bqbTENlkjTpJpsKB3FjRmh2LJ)EtuKfIBwzKpar8oAQztIrjUUu4B7LBVpiKwqL14dp6iTBDsFqY2EZ13gKmeejdnrs33w7h49rFBWAX9uVbZf4888e9pWlB(2G(HiOp4XrkVJC3X82HVnua)wJhI)REQGeRQYpe)y8AdDEq367THodHPtGt)SHoDCCLQB57(BQ82qEAzeAinbpbUZ6RirTEEyNgoAWpseCOvcg5ihBiy3haOGG9(c6oOn4Fvg41E6swY91v9NSls4jJgE17OH3Zc6ycAPoKeIFJR3p8bh1oMwyByAHhmtZ4ih(MFijWh5qvePT92p3hEhYTIUotmuMjgiXcXRXM5t4CxPDzPFjDQKvg6fOThi9raBpOkc2bLHf6Ki8TQGDqPyHkiV)vguRWGQvJfwGkF17apcTB4C4bjUDEyLyHH)AxS5V(AZ9VJ4snFkIXy5lS0pkgc5brFLShH(X7u630VyKR0n5SmLHwDX9sXrgkQ(MHpvk)huWwFrltbb6nAZRVs)(I2t5Bl6nHHVt6UwFsG7LI9wUQpPF6N4vzJorAP5(mz)1xlRVeHiuv1KR4(jRxUTOMI1qhIrrucqd1j6pV(Q20V61x7BHbCIAQ9QJQhJ5RFF7mWnhPchir3XKGM84XEiaRZDT6DINyuQUmJ3i2IzKKSBywnykOC4NHJO1vj50GlnaUcBXFqoLkre0G69za5zYlJE5wAXIOYGB20R8X)TIP2)e1pYXeDIQzoumnIjUzlzMx6b8bL(MjHdQ1uQrM6lvbIb)(Ny2E3Yo5npQHPCwEypWsBpOxJ5PBUCGS1QB6F559RuS53Fgtdjgu7DI0TkLGO6j11098KTgCfmBLBNsHbWU8jMozSmct(xnUubV5fuTc2yz2YACZyFX)qt8x69eG5sOFEuYIzXFHYAIwq8aKS(MlV6C1Fv42uXwWdef1I5zBjkxepcROFzkKF8JBtizLwsY2HP214cw)1vOgBBmoPpIb96FIoAg)v6rz86RW)Ep9FMZrE)aRCekMQPrf4GKDnfv2G(i79djFP5U()JY(0KUr8O0IKEU)AKkgQs4xjnmR9pNnJ9YFs(1IPJAI4KokL90IP1dL83hGHWY0nXm(1xv)f6U8u6AjTGMQzCUMatqU7n4ge75AGCNvNXNaOnzfJrkEBAcLRBrRMvKhn5PI3PxbUkHwk2OuVeazgo63m2PHs7xWV6De(uUKeXNctr9kI)86Xn1dyoWxn8GpO4KAYvk)RlX8YPPLnjyGD2Ict5e7Z2E8a6bemWq)(si)9vU7igW6l7GUx3haGIl)XdAJdvhESjBpKt3qD3Y4ZvFFMAbC5SgzgJxqBVfpYX20hiMnskuonpOJI7pNwn4Fe(ZP87gRULtahyQqbe6gTLoT(DfJqpgUtaripTL4o)aGKT8d2NDfQVD5hOvKbgfrtVunTuXswNAtt8Z9SfAeC1egkYMKg9K(HudLXm8undIr5XkXEObrUUjCGcWWZYoaHfUtr2lC2pJO3kRvQNQVJ9vdGrt4Cz9JJcPa2QzQQk6)0HYCrVuiWZ0)uQAbM8JVu2r8cTgXr2cPA1OzqSkKrgaTgz0)UAXYEh9CM51Ooqj4t31iNFGRKuFWltMuHF5rEoDenpkOFNy8FFlygqXV5LCFsO3g5RBKo7KI59qH3g6jeiqzYRp5DjUI6nZM854QV02O7aWd2OsOnayIA1DFQ6UQ9sNkeuNk0Y5U0cDQqeDQWVb6ubDRoL5TeYbPtfaOtfGOtzU023lHBiasNkS71Py2PAZH51yOQHtHCyItcSTzBGYru3OJzrcJAQ71x7ZkQE4i0d0BGZdLTgVeFEcMgkvUJ2WtdH5P(Sr1npn0MY2aLtWUT80qV5PbFt4PSZ6qTlCOCwFpgPjxxNCOeiYJPDpUOM2JiMgr19BylandK7t5gOxPgOhf0ecZf64CRFUDuaFRLnCac1d4N5nkv1sHgE3rzxasdzJBR34maNiDAqUWc22r60Mrdz0Y0yOR1o(Hvdxz(P1rBUxbANR7(mYcCcSqoTW0UBtn2nF7jw4WyOBSWUbp5WZRoQvSSRLYuyYvNdwtoaqbLBOCvqHMIAfOLljCpBvKvUNQfadoVwhyGujcAEADNeqECZ3ADKweqESIV46qpv8Lwh6HQFH1LrLQn9N5rppi0oK(qw0d6hVrUm8NgkAdEqVsc3CKWzX(q986RBa(irlhFyRqjpriLIchoaGL10sj7hI8F28g1QI4xWj3iDC4nWsqwnLxX2zY4jnixuKjYDqHeVbIYmoKs46VcbUP7N0x(idaqinJCBS99GtPA8yh5Ynx2IvjeAv2a(bOUA9K)4tdFiDUxuZVX096RsmsFDPL2Ia8LLgseJVSgthLhoUhicPPREkKa1S0ADOYeS2QYpQ9LG2TvJtVYZvVBiwpxmpWBV5ADNvhPyFcCR6D0TT4MhDPVGsPznCZW8ghb4sGrv6RlMXIweqFggFBEUXyK4hFVOi30pyYQoxoVV3V78COma(OQvp3FqBxarjxzBe6l(Muvdq)8OnnyutbfnTF6zbdj89wXfdn4IAD5qFelVtOTWhkbdXYGdSVVwnufC0AOl)Xi2FMWizdat6tunqiJPtgpyGKRlGpZW4sF1v)GIqvkMpG90cxh2LLN1opaGbVcU(IITjZvhRUlXNy4azpoI7IXKTcaqJ3Qhf3HhT2eJwqs6rARgQUM0rjb2)codlhwIjlgCBT1AqrfYNKVDbQC(TC8IMfm)VxLARAJsR(gn73UzrPu9z5qE3PhzTkCAVI4F))AX6fL2ObOsRHNk91L903Fg9Rk7zuJcAbzRAqa(vgWBdUJbTYnzeJ1(d73v2dIpdA(C6Fe38jtimaBBScN6h8VfSheFZcBdn4iH(lUdaOWqoi8CKOoi1k713ynh2hWvprPuvCrgnOqHIAv2UAAiRZ6ZJKc5Zmk07TCl)0IE4yp3IX7biHq3KGwBODZvUNYpsu91au9LEscFd)mJ6dbd2aL7J)DLZBvnCb6JWIC)g65KaM4UzAcOzCE61TkBPR9HXG0o9YAfU(IPYNIOqSogVFsS9aX0)sQIIrsFbvpsOI(xkvuur(lKk9JF6D)F]] )