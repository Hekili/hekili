-- WarlockAffliction.lua
-- July 2024

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitDebuffByID = ns.FindUnitDebuffByID
local UnitTokenFromGUID = _G.UnitTokenFromGUID

local spec = Hekili:NewSpecialization( 265 )

spec:RegisterResource( Enum.PowerType.SoulShards, {},
    setmetatable( {
        actual = nil,
        max = 5,
        active_regen = 0,
        inactive_regen = 0,
        forecast = {},
        times = {},
        values = {},
        fcount = 0,
        regen = 0,
        regenerates = false,
    }, {
        __index = function( t, k )
            if k == "count" or k == "current" then return t.actual

            elseif k == "actual" then
                t.actual = UnitPower( "player", Enum.PowerType.SoulShards )
                return t.actual

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Warlock
    abyss_walker                   = { 71954, 389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by 4% for 10 sec.
    accrued_vitality               = { 71953, 386613, 2 }, -- Drain Life heals for 15% of the amount drained over 7.7 sec.
    amplify_curse                  = { 71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    banish                         = { 71944, 710   , 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = { 71949, 111400, 1 }, -- Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    curses_of_enfeeblement         = { 71951, 386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    dark_accord                    = { 71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by 45 sec.
    dark_pact                      = { 71936, 108416, 1 }, -- Sacrifices 20% of your current health to shield you for 200% of the sacrificed health plus an additional 24,582 for 20 sec. Usable while suffering from control impairing effects.
    darkfury                       = { 71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by 15 sec and increases its radius by 2 yards.
    demon_skin                     = { 71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of ${$s1/10}.1% of maximum health every $t1 sec, and may now absorb up to $s2% of maximum health.; Increases your armor by $m4%.
    demonic_circle                 = { 100941, 268358, 1 }, -- [48018] Summons a Demonic Circle for $d. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects.$?s58081[; If you cast Demonic Circle: Summon while controlling an Eye of Kilrogg, the circle will appear where the eye is located.][]
    demonic_embrace                = { 71930, 288843, 1 }, -- Stamina increased by 10%.
    demonic_fortitude              = { 71922, 386617, 1 }, -- Increases you and your pets' maximum health by 5%.
    demonic_gateway                = { 71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 90 sec.
    demonic_inspiration            = { 71928, 386858, 1 }, -- Increases the attack speed of your primary pet by 5%. Increases Grimoire of Sacrifice damage by 10%.
    demonic_resilience             = { 71917, 389590, 2 }, -- Reduces the chance you will be critically struck by 2%. All damage your primary demon takes is reduced by 8%.
    demonic_tactics                = { 71925, 452894, 1 }, -- Your spells have a $s1% increased chance to deal a critical strike.; You gain $s2% more of the Critical Strike stat from all sources.
    fel_armor                      = { 71950, 386124, 2 }, -- When Soul Leech absorbs damage, 5% of damage taken is absorbed and spread out over 5 sec. Reduces damage taken by 1.5%.
    fel_domination                 = { 71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 90%.
    fel_pact                       = { 71932, 386113, 1 }, -- Reduces the cooldown of Fel Domination by ${$s1/-1000} sec.
    fel_synergy                    = { 71924, 389367, 2 }, -- Soul Leech also heals you for $s1% and your pet for $s2% of the absorption it grants.
    fiendish_stride                = { 71948, 386110, 1 }, -- Reduces the damage dealt by Burning Rush by ${$abs($s1)}%. Burning Rush increases your movement speed by an additional $s2%.
    frequent_donor                 = { 71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by 15 sec.
    horrify                        = { 71916, 56244 , 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear.
    howl_of_terror                 = { 71947, 5484  , 1 }, -- Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    ichor_of_devils                = { 71937, 386664, 1 }, -- Dark Pact sacrifices only 5% of your current health for the same shield value.
    lifeblood                      = { 71940, 386646, 2 }, -- When you use a Healthstone, gain 7% Leech for 20 sec.
    mortal_coil                    = { 71947, 6789  , 1 }, -- Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    nightmare                      = { 71916, 386648, 1 }, -- Increases the amount of damage required to break your fear effects by 60%.
    pact_of_gluttony               = { 71926, 386689, 1 }, -- [452930] Instantly restores $s1% health$?s262031[, plus an additional ${$262080d/$262080t1*$262080s1}% over $262080d.][.]
    resolute_barrier               = { 71915, 389359, 2 }, -- Attacks received that deal at least 5% of your health decrease Unending Resolve's cooldown by 10 sec. Cannot occur more than once every 30 sec.
    sargerei_technique             = { 93179, 405955, 2 }, -- Shadow Bolt and Drain Soul damage increased by 8%.
    shadowflame                    = { 71941, 384069, 1 }, -- Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowfury                     = { 71942, 30283 , 1 }, -- Stuns all enemies within 8 yds for 3 sec.
    socrethars_guile               = { 93178, 405936, 2 }, -- Agony damage increased by 8%.
    soul_conduit                   = { 71939, 215941, 1 }, -- Every Soul Shard you spend has a $?s137043[$s1%]?s137046[$s3%][$s2%] chance to be refunded.
    soul_link                      = { 71923, 108415, 2 }, -- $s2% of all damage you take is taken by your demon pet instead. $?a137044[][; While Grimoire of Sacrifice is active, your Stamina is increased by $s3%.]
    soulburn                       = { 71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by 50% and makes you immune to snares and roots for 6 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for 30 sec. This shield cannot exceed 30% of your maximum health. Health Funnel: Restores 140% more health and reduces the damage taken by your pet by 30% for 10 sec. Healthstone: Increases the healing of your Healthstone by 30% and increases your maximum health by 20% for 12 sec.
    strength_of_will               = { 71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional 15%.
    sweet_souls                    = { 71927, 386620, 1 }, -- Your Healthstone heals you for an additional 10% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    swift_artifice                 = { 71918, 452902, 1 }, -- Reduces the cast time of Soulstone and Create Healthstone by $s1%.
    teachings_of_the_black_harvest = { 71938, 385881, 1 }, -- Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target 4% damage reduction for 5 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by 30 sec. Felhunter: Reduces the cooldown of Devour Magic by 5 sec. Sayaad: Reduces the cooldown of Seduction by 10 sec and causes the target to walk faster towards the demon.
    teachings_of_the_satyr         = { 71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by 15 sec.
    wrathful_minion                = { 71946, 386864, 1 }, -- Increases the damage done by your primary pet by 5%. Increases Grimoire of Sacrifice damage by 10%.

    -- Affliction
    absolute_corruption            = { 72051, 196103, 1 }, -- $?a445465[Wither][Corruption] is now permanent and deals $s2% increased damage.; Duration reduced to $s1 sec against players.
    contagion                      = { 72041, 453096, 2 }, -- Increases critical strike damage dealt by Agony, $?a445465[Wither][Corruption], and Unstable Affliction by $s1%.
    creeping_death                 = { 72058, 264000, 1 }, -- Your Agony, $?a445465[Wither][Corruption], and Unstable Affliction deal damage $s1% faster.
    cull_the_weak                  = { 72038, 453056, 2 }, -- Malefic Rapture damage is increased by $s1% for each enemy it hits, up to $s2 enemies.
    cunning_cruelty                = { 72054, 453172, 1 }, -- Shadow Bolt and Drain Soul have a chance to trigger a Shadow Bolt Volley, dealing $<damage> Shadow damage to $s1 enemies within $453176a1 yards of your current target.
    dark_harvest                   = { 102029, 387016, 1 }, -- Each target affected by Soul Rot increases your haste and critical strike chance by ${$s1/10}.1% for $387018d.
    dark_virtuosity                = { 72043, 405327, 2 }, -- Shadow Bolt and Drain Soul deal an additional 5% damage.
    deaths_embrace                 = { 72033, 453189, 1 }, -- Increases Drain Life healing by $s1% while your health is at or below $s2% health. ; Damage done by your Agony, $?a445465[Wither][Corruption], Unstable Affliction, and Malefic Rapture is increased by $s3% when your target is at or below $s4% health.
    drain_soul                     = { 72045, 388667, 1 }, -- [198590] $?s388667[][Replaces Shadow Bolt.; ]Drains the target's soul, causing $o1 Shadow damage over $d.; Damage is increased by $s2% against enemies below $s3% health.; Generates 1 Soul Shard if the target dies during this effect.
    focused_malignancy             = { 72042, 399668, 1 }, -- Malefic Rapture deals $s1% increased damage to targets suffering from Unstable Affliction.
    grimoire_of_sacrifice          = { 72037, 108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal $196100s1 additional Shadow damage.; Lasts $196099d or until you summon a demon pet.
    haunt                          = { 72032, 48181 , 1 }, -- A ghostly soul haunts the target, dealing 10,798 Shadow damage and increasing your damage dealt to the target by 10% for 18 sec. If the target dies, Haunt's cooldown is reset.
    improved_haunt                 = { 102031, 458034, 1 }, -- Increases the damage of Haunt by $s1% and reduces its cast time by $s2%. Haunt now applies Shadow Embrace.
    improved_malefic_rapture       = { 72035, 454378, 1 }, -- Increases Malefic Rapture damage by $s1% and reduces its cast time by $s2%.
    improved_shadow_bolt           = { 72045, 453080, 1 }, -- Reduces the cast time of Shadow Bolt by $s1% and increases its damage by $s2%.
    infirmity                      = { 102032, 458036, 1 }, -- The stack count of Agony is increased by $s1 when applied by Vile Taint.; Enemies damaged by Phantom Singularity take $458219s1% increased damage from you for its duration.
    kindled_malice                 = { 72040, 405330, 2 }, -- Malefic Rapture damage increased by $s1%. $?a445465[Wither][Corruption] damage increased by $s2%.
    malediction                    = { 72046, 453087, 2 }, -- Increases the critical strike chance of Agony, $?a445465[Wither][Corruption], and Unstable Affliction by $s1%.
    malefic_touch                  = { 102030, 458029, 1 }, -- Malefic Rapture deals an additional $458131s1 Shadowflame damage to each target it affects.
    malevolent_visionary           = { 71987, 387273, 1 }, -- Increases the damage of your Darkglare by $s1%. When Darkglare extends damage over time effects it also sears affected targets for $453233s1 Shadow damage.
    malign_omen                    = { 72057, 458041, 1 }, -- [458043] Your next Malefic Rapture deals $s1% increased damage and extends the duration of your damage over time effects and Haunt by $s2 sec.
    nightfall                      = { 72047, 108558, 1 }, -- $?a445465[Wither][Corruption] damage has a chance to cause your next Shadow Bolt or Drain Soul to deal $264571s2% increased damage. ; Shadow Bolt is instant cast and Drain Soul channels $264571s3% faster when affected.
    oblivion                       = { 71986, 417537, 1 }, -- Unleash wicked magic upon your target's soul, dealing $o Shadow damage over $d.; Deals $s2% increased damage, up to ${$s2*$s3}%, per damage over time effect you have active on the target.
    perpetual_unstability          = { 102246, 459376, 1 }, -- The cast time of Unstable Affliction is reduced by $s2%.; Refreshing Unstable Affliction with $s1 or less seconds remaining deals $459461s1 Shadow damage to its target.
    phantom_singularity            = { 102033, 205179, 1 }, -- Places a phantom singularity above the target, which consumes the life of all enemies within $205246A2 yards, dealing ${8*$205246s2} damage over $d, healing you for ${$205246e2*100}% of the damage done.
    ravenous_afflictions           = { 102247, 459440, 1 }, -- Critical strikes from your Agony, $?a445465[Wither][Corruption], and Unstable Affliction have a chance to grant Nightfall.
    relinquished                   = { 72052, 453083, 1 }, -- Agony has 1.$m1 times the normal chance to generate a Soul Shard.
    sacrolashs_dark_strike         = { 72053, 386986, 1 }, -- $?a445465[Wither][Corruption] damage is increased by $s1%, and each time it deals damage any of your Curses active on the target are extended by ${$s2/1000}.1 sec.
    seed_of_corruption             = { 72050, 27243 , 1 }, -- Embeds a demon seed in the enemy target that will explode after $d, dealing $27285s1 Shadow damage to all enemies within $27285A1 yards and applying $?a445465[Wither][Corruption] to them.; The seed will detonate early if the target is hit by other detonations, or takes ${$SPS*$s1/100} damage from your spells.
    shadow_embrace                 = { 100940, 32388 , 1 }, -- $?s388667[Drain Soul][Shadow Bolt] applies Shadow Embrace, increasing your damage dealt to the target by $?s388667[$32390s1%][$453206s2%] for $32390d. Stacks up to $?s388667[$32390u][$453206u] times.
    siphon_life                    = { 72051, 452999, 1 }, -- $?a445465[Wither][Corruption] deals $s1% increased damage and its periodic damage heals you for $s2% of the damage dealt.
    soul_rot                       = { 72056, 386997, 1 }, -- Wither away all life force of your current target and up to 3 additional targets nearby, causing your primary target to suffer 66,731 Nature damage and secondary targets to suffer 33,365 Nature damage over 8 sec. For the next 8 sec, casting Drain Life will cause you to also Drain Life from any enemy affected by your Soul Rot, and Drain Life will not consume any mana.
    summon_darkglare               = { 72034, 205180, 1 }, -- Summons a Darkglare from the Twisting Nether that extends the duration of your damage over time effects on all enemies by 8 sec. The Darkglare will serve you for 20 sec, blasting its target for 4,987 Shadow damage, increased by 25% for every damage over time effect you have active on their current target.
    summoners_embrace              = { 72037, 453105, 1 }, -- Increases the damage dealt by your spells and your demon by $s1%.
    tormented_crescendo            = { 72031, 387075, 1 }, -- While Agony, $?a445465[Wither][Corruption], and Unstable Affliction are active, your Shadow Bolt has a $s1% chance and your Drain Soul has a $s2% chance to make your next Malefic Rapture cost no Soul Shards and cast instantly.
    unstable_affliction            = { 72049, 316099, 1 }, -- Afflicts one target with $o2 Shadow damage over $d. ; If dispelled, deals ${$m2*$s1/100} damage to the dispeller and silences them for $196364d.$?s231791[; Generates $231791m1 Soul $LShard:Shards; if the target dies while afflicted.][]
    vile_taint                     = { 102033, 278350, 1 }, -- Unleashes a vile explosion at the target location, dealing $386931o1 Shadow damage over $386931d to $s2 enemies within $a1 yds and applies Agony and Curse of Exhaustion to them.
    volatile_agony                 = { 72039, 453034, 1 }, -- Refreshing Agony with $s1 or less seconds remaining deals $453035s1 Shadow damage to its target and enemies within $453035a1 yards.; Deals reduced damage beyond $s2 targets.
    withering_bolt                 = { 72055, 386976, 1 }, -- Shadow Bolt and Drain Soul deal $s1% increased damage, up to ${$s1*$s2}%, per damage over time effect you have active on the target.
    writhe_in_agony                = { 72048, 196102, 1 }, -- Agony's damage starts at $s3 stacks and may now ramp up to $s2 stacks.
    xavius_gambit                  = { 71921, 416615, 1 }, -- Unstable Affliction deals $s1% increased damage.

    -- Hellcaller
    aura_of_enfeeblement           = { 94822, 440059, 1 }, -- While Unending Resolve is active, enemies within $449587a1 yds are affected by Curse of Tongues and Curse of Weakness at $s1% effectiveness.
    blackened_soul                 = { 94837, 440043, 1 }, -- Spending Soul Shards on damaging spells will further corrupt enemies affected by your Wither, increasing its stack count by $s1.; Each time Wither gains a stack it has a chance to collapse, consuming a stack every $445731t1 sec to deal $445736s1 Shadowflame damage to its host until 1 stack remains.
    bleakheart_tactics             = { 94854, 440051, 1 }, -- Wither damage increased $s1%. When Wither gains a stack from Blackened Soul, it has a chance to gain an additional stack.
    curse_of_the_satyr             = { 94822, 440057, 1 }, -- [442804] Increases the time between an enemy's attacks by $s1% and the casting time of all spells by $s3% for $d.$?s103112[; Soulburn: Your Curse of Weakness will affect all enemies in a $104222A yard radius around your target.][]; Curses: A warlock can only have one Curse active per target.
    hatefury_rituals               = { 94854, 440048, 1 }, -- Wither deals $s1% increased periodic damage but its duration is $s2% shorter.
    illhoofs_design                = { 94835, 440070, 1 }, -- Sacrifice $s1% of your maximum health. Soul Leech now absorbs an additional $s2% of your maximum health.
    malevolence                    = { 94842, 442726, 1 }, -- Dark magic erupts from you and corrupts your soul for $442726d, causing enemies suffering from your Wither to take $446285s1 Shadowflame damage and increase its stack count by $s1.; While corrupted your Haste is increased by $442726s1% and spending Soul Shards on damaging spells grants $s2 additional stack of Wither.
    mark_of_perotharn              = { 94844, 440045, 1 }, -- Critical strike damage dealt by Wither is increased by $s1%. ; Wither has a chance to gain a stack when it critically strikes. Stacks gained this way do not activate Blackened Soul.
    mark_of_xavius                 = { 94834, 440046, 1 }, -- $?s980[Agony damage increased by $s1%.][Wither damage increased by $s2%.]; Blackened Soul deals $s3% increased damage per stack of Wither.
    seeds_of_their_demise          = { 94829, 440055, 1 }, -- After Wither reaches $s1 stacks or when its host reaches $s2% health, Wither deals $445736s1 Shadowflame damage to its host every $445731t1 sec until 1 stack remains.; When Blackened Soul deals damage, you have a chance to gain $?s137046[$s4 stacks of Flashpoint][Tormented Crescendo].
    xalans_cruelty                 = { 94845, 440040, 1 }, -- Shadow damage dealt by your spells and abilities is increased by $s3% and your Shadow spells gain $s1% more critical strike chance from all sources.
    xalans_ferocity                = { 94853, 440044, 1 }, -- Fire damage dealt by your spells and abilities is increased by $s1% and your Fire spells gain $s4% more critical strike chance from all sources.
    wither                         = { 94840, 445468, 1 }, -- [445468] Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing $s1 Shadowflame damage immediately and an additional $445474o1 Shadowflame damage over $445474d.$?s137046[; Periodic damage generates 1 Soul Shard Fragment and has a $s2% chance to generate an additional 1 on critical strikes.; Replaces Immolate.][; Replaces Corruption.]
    zevrims_resilience             = { 94835, 440065, 1 }, -- Dark Pact heals you for $108416s5 every $108416t5 sec while active.

    -- Soul Harvester
    demoniacs_fervor               = { 94832, 449629, 1 }, -- Your demonic soul deals $s1% increased damage to $?s137043[targets affected by your Unstable Affliction.][the main target of Hand of Gul'dan.]
    demonic_soul                   = { 94851, 449614, 1 }, -- A demonic entity now inhabits your soul, allowing you to detect if a Soul Shard has a Succulent Soul when it's generated. ; A Succulent Soul empowers your next $?s137043[Malefic Rapture, increasing its damage by $449793s2%, and unleashing your demonic soul to deal an additional $449801s1 Shadow damage.][Hand of Gul'dan, increasing its damage by $449793s3%, and unleashing your demonic soul to deal an additional $449801s1 Shadow damage.]
    eternal_servitude              = { 94824, 449707, 1 }, -- Fel Domination cooldown is reduced by ${$s1/-1000} sec.
    feast_of_souls                 = { 94823, 449706, 1 }, -- When you kill a target, you have a chance to generate a Soul Shard that is guaranteed to be a Succulent Soul.
    friends_in_dark_places         = { 94850, 449703, 1 }, -- Dark Pact now shields you for an additional $s1% of the sacrificed health.
    gorebound_fortitude            = { 94850, 449701, 1 }, -- You always gain the benefit of Soulburn when consuming a Healthstone, increasing its healing by 30% and increasing your maximum health by 20% for 12 sec.
    gorefiends_resolve             = { 94824, 389623, 1 }, -- Targets resurrected with Soulstone resurrect with $s1% additional health and $s2% additional mana.
    necrolyte_teachings            = { 94825, 449620, 1 }, -- $?s137043[Shadow Bolt and Drain Soul damage increased by $s2%. Nightfall increases the damage of Shadow Bolt and Drain Soul by an additional $s1%.][Shadow Bolt damage increased by $s2%. Power Siphon increases the damage of Demonbolt by an additional $s3%.]
    quietus                        = { 94846, 449634, 1 }, -- Soul Anathema damage increased by $s1% and is dealt $s2% faster.; Consuming $?s137043[Nightfall][Demonic Core] activates Shared Fate or Feast of Souls.
    sataiels_volition              = { 94838, 449637, 1 }, -- $?s137043[Corruption deals damage $s1% faster and Haunt grants Nightfall.][Wild Imp damage increased by $s2% and Wild Imps that are imploded have an additional $s3% chance to grant a Demonic Core.]
    shadow_of_death                = { 94857, 449638, 1 }, -- Your $?s137043[Soul Rot][Summon Demonic Tyrant] spell is empowered by the demonic entity within you, causing it to grant ${$449858s1/10} Soul Shards that each contain a Succulent Soul.
    shared_fate                    = { 94823, 449704, 1 }, -- When you kill a target, its tortured soul is flung into a nearby enemy for $450591d. This effect inflicts $450593s1 Shadow damage to enemies within $450593a1 yds every $450591t1 sec.; Deals reduced damage beyond $s1 targets.
    soul_anathema                  = { 94847, 449624, 1 }, -- Unleashing your demonic soul bestows a fiendish entity unto the soul of its targets, dealing $450538o1 Shadow damage over $450538d.; If this effect is reapplied, any remaining damage will be added to the new Soul Anathema.
    wicked_reaping                 = { 94821, 449631, 1 }, -- Damage dealt by your demonic soul is increased by $s1%.; Consuming $?s137043[Nightfall][Demonic Core] feeds the demonic entity within you, causing it to appear and deal $?s137043[$449826s1][${$449826s1*($s2/100)}] Shadow damage to your target.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bonds_of_fel        = 5546, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the 8 yd radius they explode, dealing 68,061 Fire damage split amongst all nearby enemies.
    call_observer       = 5543, -- (201996) Summons a demonic Observer to keep a watchful eye over the area for 20 sec. Anytime an enemy within 30 yards casts a harmful magical spell, the Observer will deal up to 10% of the target's maximum health in Shadow damage.
    essence_drain       = 19  , -- (221711) Whenever you heal yourself with Drain Life, the enemy target deals 9% reduced damage to you for 10 sec. Stacks up to 4 times.
    gateway_mastery     = 15  , -- (248855) Increases the range of your Demonic Gateway by 20 yards, and reduces the cast time by 30%. Reduces the time between how often players can take your Demonic Gateway by 30 sec.
    impish_instincts    = 5579, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by 2 sec. Cannot occur more than once every 5 sec.
    jinx                = 5386, -- (426352) Casting a curse now applies Corruption and Agony to your target, but curses now costs ${$s1/10} Soul $LShard:Shards;.
    nether_ward         = 18  , -- (212295) Surrounds the caster with a shield that lasts 3 sec, reflecting all harmful spells cast on you.
    rampant_afflictions = 5379, -- (335052) Unstable Affliction can now be applied to up to 3 targets, but its damage is reduced by 25%.
    rot_and_decay       = 16  , -- (212371) Shadow Bolt damage increases the duration of your Unstable Affliction, Corruption, Agony, and Siphon Life on the target by 3.0 sec. Drain Life, Drain Soul, and Oblivion damage increases the duration of your Unstable Affliction, Corruption, Agony, and Siphon Life on the target by 1.0 sec.
    shadow_rift         = 5392, -- (353294) Conjure a Shadow Rift at the target location lasting 2 sec. Enemy players within the rift when it expires are teleported to your Demonic Circle. Must be within 40 yds of your Demonic Circle to cast.
    soul_rip            = 5608, -- (410598) Fracture the soul of up to 3 target players within 20 yds into the shadows, reducing their damage done by 25% and healing received by 25% for 8 sec. Souls are fractured up to 20 yds from the player's location. Players can retrieve their souls to remove this effect.
} )


-- Auras
spec:RegisterAuras( {
    -- Talent: Damage taken is reduced by $s1%.
    -- https://wowhead.com/beta/spell=389614
    abyss_walker = {
        id = 389614,
        duration = 10,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec. Damage increases over time.
    -- https://wowhead.com/beta/spell=980
    agony = {
        id = 980,
        duration = function () return ( 18 + conduit.rolling_agony.mod * 0.001 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
        tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
        type = "Magic",
        max_stack = function () return 10 + 4 * talent.writhe_in_agony.rank end,
        meta = {
            stack = function( t )
                if t.down then return 0 end
                if t.count >= 10 then return t.count end

                local app = t.applied
                local tick = t.tick_time

                local last_real_tick = now + ( floor( ( now - app ) / tick ) * tick )
                local ticks_since = floor( ( query_time - last_real_tick ) / tick )

                return min( talent.writhe_in_agony.enabled and 18 or 10, t.count + ticks_since )
            end,
        }
    },
    -- Talent: Next Curse of Tongues, Curse of Exhaustion or Curse of Weakness is amplified.
    -- https://wowhead.com/beta/spell=328774
    amplify_curse = {
        id = 328774,
        duration = 15,
        max_stack = 1
    },
    -- Time between attacks increased $w1% and casting speed increased by $w2%.
    aura_of_enfeeblement = {
        id = 449587,
        duration = 8.0,
        max_stack = 1,
    },
    -- Talent: Invulnerable, but unable to act.
    -- https://wowhead.com/beta/spell=710
    banish = {
        id = 710,
        duration = 30,
        mechanic = "banish",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=111400
    burning_rush = {
        id = 111400,
        duration = 3600,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=146739
    corruption = {
        id = 146739,
        duration = function () return ( talent.absolute_corruption.enabled and ( target.is_player and 24 or 3600 ) or 14 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
        tick_time = function () return 2 * ( 1 - 0.15 * talent.creeping_death.rank ) * ( 1 - 0.15 * talent.sataiels_volition.rank ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed slowed by $w1%.
    -- https://wowhead.com/beta/spell=334275
    curse_of_exhaustion = {
        id = 334275,
        duration = 12,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    curse_of_the_satyr = {
        id = 440057,
        duration = 120,
        max_stack = 1
    },
    -- Speaking Demonic increasing casting time by $w1%.
    -- https://wowhead.com/beta/spell=1714
    curse_of_tongues = {
        id = 1714,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Time between attacks increased by $w1%. $?e1[Chance to critically strike reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=702
    curse_of_weakness = {
        id = 702,
        duration = 120,
        type = "Magic",
        max_stack = 1
    },
    dark_harvest = {
        id = 387018,
        duration = 8,
        max_stack = 4,
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=108416
    dark_pact = {
        id = 108416,
        duration = 20,
        max_stack = 1
    },
    decaying_soul_satchel = {
        id = 356369,
        duration = 8,
        max_stack = 4,
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=268358
    demonic_circle = {
        id = 268358,
        duration = 3600,
        type = "Magic",
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
    -- Doomed to take $w1 Shadow damage.
    -- https://wowhead.com/beta/spell=603
    doom = {
        id = 603,
        duration = 20,
        tick_time = 20,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $s1 Shadow damage every $t1 seconds.  Restoring health to the Warlock.
    -- https://wowhead.com/beta/spell=234153
    drain_life = {
        id = 234153,
        duration = function () return 5 * haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
        tick_time = function () return haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Healing for $m1% of maximum health every $t1 sec.; Spell casts are not delayed by taking damage.
    empowered_healthstone = {
        id = 262080,
        duration = 6.0,
        max_stack = 1,
    },
    -- Controlling Eye of Kilrogg.  Detecting Invisibility.
    -- https://wowhead.com/beta/spell=126
    eye_of_kilrogg = {
        id = 126,
        duration = 45,
        type = "Magic",
        max_stack = 1
    },
    fear = {
        id = 118699,
        duration = 20,
        type = "Magic",
        max_stack = 1,
    },
    -- Damage is being delayed every $t1 sec.
    fel_armor = {
        id = 387846,
        duration = 3600,
        tick_time = 0.5,
        pandemic = true,
        max_stack = 1,
    },
    -- Talent: Imp, Voidwalker, Succubus, Felhunter, or Felguard casting time reduced by $/1000;S1 sec.
    -- https://wowhead.com/beta/spell=333889
    fel_domination = {
        id = 333889,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Sacrificed your demon pet to gain its command demon ability.    Your spells sometimes deal additional Shadow damage.
    -- https://wowhead.com/beta/spell=196099
    grimoire_of_sacrifice = {
        id = 196099,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Taking $s2% increased damage from the Warlock. Haunt's cooldown will be reset on death.
    -- https://wowhead.com/beta/spell=48181
    haunt = {
        id = 48181,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    -- Spells cast by the Warlock also hit this target for $s1% of normal initial damage.
    -- https://wowhead.com/beta/spell=80240
    havoc = {
        id = 80240,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Transferring health.
    -- https://wowhead.com/beta/spell=755
    health_funnel = {
        id = 755,
        duration = 5,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=5484
    howl_of_terror = {
        id = 5484,
        duration = 20,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Fire damage every $t1 sec.$?a339892[   Damage taken by Chaos Bolt and Incinerate increased by $w2%.][]
    -- https://wowhead.com/beta/spell=157736
    immolate = {
        id = 157736,
        duration = 18,
        tick_time = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=322170
    impending_catastrophe = {
        id = 322170,
        duration = 12,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Taking $w1% increased Fire damage from Infernal.
    -- https://wowhead.com/beta/spell=340045
    infernal_brand = {
        id = 340045,
        duration = 8,
        max_stack = 15
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
    -- Talent: Leech increased by $w1%.
    -- https://wowhead.com/beta/spell=386647
    lifeblood = {
        id = 386647,
        duration = 20,
        max_stack = 1
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
    -- https://wowhead.com/beta/spell=77215
    mastery_potent_afflictions = {
        id = 77215,
        duration = 3600,
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
    -- https://wowhead.com/beta/spell=212295
    nether_ward = {
        id = 212295,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    nightfall = {
        id = 264571,
        duration = 12,
        max_stack = 1
    },
    oblivion = {
        id = 417537,
        duration = 3,
        max_stack = 1
    },
    -- Talent: Dealing damage to all nearby targets every $t1 sec and healing the casting Warlock.
    -- https://wowhead.com/beta/spell=205179
    phantom_singularity = {
        id = 205179,
        duration = 16,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: The percentage of damage shared via your Soul Link is increased by an additional $s2%.
    -- https://wowhead.com/beta/spell=394747
    profane_bargain = {
        id = 394747,
        duration = 3600,
        max_stack = 1
    },
    -- Movement speed increased by $s3%.
    -- https://wowhead.com/beta/spell=30151
    pursuit = {
        id = 30151,
        duration = 8,
        max_stack = 1
    },
    --
    -- https://wowhead.com/beta/spell=698
    ritual_of_summoning = {
        id = 698,
        duration = 120,
        type = "Magic",
        max_stack = 1
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
    -- Talent: Embeded with a demon seed that will soon explode, dealing Shadow damage to the caster's enemies within $27285A1 yards, and applying Corruption to them.    The seed will detonate early if the target is hit by other detonations, or takes $w3 damage from your spells.
    -- https://wowhead.com/beta/spell=27243
    seed_of_corruption = {
        id = 27243,
        duration = 12,
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
    shadow_embrace = {
        id = 32390,
        duration = 16,
        type = "Magic",
        max_stack = function() return talent.drain_soul.enabled and 4 or 2 end,
        copy = { 453206 }
    },
    -- If the target dies and yields experience or honor, Shadowburn restores ${$245731s1/10} Soul Shard and refunds a charge.
    -- https://wowhead.com/beta/spell=17877
    shadowburn = {
        id = 17877,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Slowed by $w1% for $d.
    -- https://wowhead.com/beta/spell=384069
    shadowflame = {
        id = 384069,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=30283
    shadowfury = {
        id = 30283,
        duration = 3,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Dealing $450593s1 Shadow damage to enemies within $450593a1 yds every $t1 sec.
    shared_fate = {
        id = 450591,
        duration = 3.0,
        max_stack = 1,
    },
    -- Talent: Suffering $w1 Shadow damage every $t1 sec and siphoning life to the casting Warlock.
    -- https://wowhead.com/beta/spell=63106
    siphon_life = {
        id = 63106,
        duration = function () return 15 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
        tick_time = function () return 3 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Dealing $o1 Shadow damage over $d.
    soul_anathema = {
        id = 450538,
        duration = function() return 10.0 - ( 1 - 0.2 * talent.quietus.rank ) end,
        tick_time = function() return ( 1 - 0.2 * talent.quietus.rank ) end,
        max_stack = 1,

        -- Affected by:
        -- mastery_potent_afflictions[77215] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 2.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- quietus[449634] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- quietus[449634] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- quietus[449634] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=108366
    soul_leech = {
        id = 108366,
        duration = 15,
        max_stack = 1
    },
    -- Mana cost of Drain Life reduced by $s1%.
    soul_rot = {
        id = 386997,
        duration = function() return 8 + ( set_bonus.tier31_2pc > 0 and 4 or 0 ) end,
        type = "Magic",
        max_stack = 1,
        copy = 325640
    },
    --
    -- https://wowhead.com/beta/spell=246985
    soul_shards = {
        id = 246985,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Consumes a Soul Shard, unlocking the hidden power of your spells.    |cFFFFFFFFDemonic Circle: Teleport|r: Increases your movement speed by $387633s1% and makes you immune to snares and roots for $387633d.    |cFFFFFFFFDemonic Gateway|r: Can be cast instantly.    |cFFFFFFFFDrain Life|r: Gain an absorb shield equal to the amount of healing done for $387630d. This shield cannot exceed $387630s1% of your maximum health.    |cFFFFFFFFHealth Funnel|r: Restores $387626s1% more health and reduces the damage taken by your pet by ${$abs($387641s1)}% for $387641d.    |cFFFFFFFFHealthstone|r: Increases the healing of your Healthstone by $387626s2% and increases your maximum health by $387636s1% for $387636d.
    -- https://wowhead.com/beta/spell=387626
    soulburn = {
        id = 387626,
        duration = 3600,
        max_stack = 1,
        onRemove = function()
            setCooldown( "soulburn", action.soulburn.cooldown )
        end,
    },
    -- Maximum health is increased by $s1%.
    soulburn_healthstone = {
        id = 387636,
        duration = 12.0,
        max_stack = 1,
    },
    -- Soul stored by $@auracaster.
    -- https://wowhead.com/beta/spell=20707
    soulstone = {
        id = 20707,
        duration = 900,
        max_stack = 1
    },
    -- $@auracaster's subject.
    -- https://wowhead.com/beta/spell=1098
    subjugate_demon = {
        id = 1098,
        duration = 300,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    -- $?s137043[Malefic Rapture deals $s2% increased damage.][Hand of Gul'dan deals $s3% increased damage.]; Unleashes your demonic entity upon consumption, dealing an additional $449801s~1 Shadow damage to enemies.
    succulent_soul = {
        id = 449793,
        duration = 30.0,
        max_stack = 1,
    },
    -- Talent: Summons a Darkglare from the Twisting Nether that blasts its target for Shadow damage, dealing increased damage for every damage over time effect you have active on any target.
    -- https://wowhead.com/beta/spell=205180
    summon_darkglare = {
        id = 205180,
        duration = function() return 20 + 5 * talent.malevolent_visionary.rank end,
        type = "Magic",
        max_stack = 1
    },
    --
    -- https://wowhead.com/beta/spell=101508
    the_codex_of_xerrath = {
        id = 101508,
        duration = 3600,
        max_stack = 1
    },
    tormented_crescendo = {
        id = 387079,
        duration = 10,
        max_stack = 1,
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
    -- Damage taken reduced by $w3%  Immune to interrupt and silence effects.
    -- https://wowhead.com/beta/spell=104773
    unending_resolve = {
        id = 104773,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=316099
    unstable_affliction = {
        id = function () return pvptalent.rampant_afflictions.enabled and 342938 or 316099 end,
        duration = function () return 21 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
        tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
        type = "Magic",
        max_stack = 1,
        copy = { 342938, 316099 }
    },
    unstable_affliction_silence = {
        id = 196364,
        duration = 4,
        max_stack = 1
    },
    -- Talent: Suffering $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=286931
    vile_taint = {
        id = 286931,
        duration = 10,
        tick_time = 2,
        type = "Magic",
        max_stack = 1,
        copy = "vile_taint_dot"
    },
    -- Suffering $w1 Shadowflame damage every $t1 sec.$?a339892[ ; Damage taken by Chaos Bolt and Incinerate increased by $w2%.][]
    wither = {
        id = 445474,
        duration = function() return 18.0 * ( 1 - 0.15 * talent.hatefury_rituals.rank ) end,
        tick_time = function() return 2.0 * ( 1 - 0.15 * talent.creeping_death.rank ) * ( 1 - 0.25 * talent.sataiels_volition.rank) end,
        pandemic = true,
        max_stack = 8, -- ??
    },


    -- PvP Talents
    casting_circle = {
        id = 221705,
        duration = 3600,
        max_stack = 1,
    },
    curse_of_fragility = {
        id = 199954,
        duration = 10,
        max_stack = 1,
    },
    curse_of_shadows = {
        id = 234877,
        duration = 10,
        type = "Curse",
        max_stack = 1,
    },
    demon_armor = {
        id = 285933,
        duration = 3600,
        max_stack = 1,
    },
    essence_drain = {
        id = 221715,
        duration = 10,
        type = "Magic",
        max_stack = 5,
    },
    soulshatter = {
        id = 236471,
        duration = 8,
        max_stack = 5,
    },


    -- Conduit
    diabolic_bloodstone = {
        id = 340563,
        duration = 8,
        max_stack = 1
    },


    -- Legendaries
    malefic_wrath = {
        id = 337125,
        duration = 8,
        max_stack = 1
    },

    relic_of_demonic_synergy = {
        id = 337060,
        duration = 15,
        max_stack = 1
    },

    -- Azerite
    cascading_calamity = {
        id = 275378,
        duration = 15,
        max_stack = 1
    },
} )


spec:RegisterHook( "TimeToReady", function( wait, action )
    local ability = action and class.abilities[ action ]

    if ability and ability.spend and ability.spendType == "soul_shards" and ability.spend > soul_shard then
        wait = 3600
    end

    return wait
end )

spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )


state.sqrt = math.sqrt

spec:RegisterStateExpr( "time_to_shard", function ()
    local num_agony = active_dot.agony
    if num_agony == 0 then return 3600 end

    return 1 / ( 0.16 / sqrt( num_agony ) * ( num_agony == 1 and 1.15 or 1 ) * num_agony / debuff.agony.tick_time )
end )

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
    if sourceGUID == GUID then
        if spellName == class.abilities.seed_of_corruption.name then
            if subtype == "SPELL_CAST_SUCCESS" then
                action.seed_of_corruption.flying = GetTime()
            elseif subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" then
                action.seed_of_corruption.flying = 0
            end
        end
    end
end, false )


spec:RegisterGear( "tier31", 207270, 207271, 207272, 207273, 207275, 217212, 217214, 217215, 217211, 217213 )
-- (4) Soul Rot grants 3 Umbrafire Kindling which increase the damage of your next Malefic Rapture to deal 50% or your next Seed of Corruption by 60%. Additionally, Umbrafire Kindling causes Malefic Rapture to extend the duration of your damage over time effects and Haunt by 2 sec.
spec:RegisterAura( "umbrafire_kindling", {
    id = 423765,
    duration = 20,
    max_stack = 3
} )


spec:RegisterGear( "tier30", 202534, 202533, 202532, 202536, 202531 )
spec:RegisterAura( "infirmity", {
    id = 409765,
    duration = 16, -- spelldata says 2 sec, but applies for 16 seconds from PS and 10 seconds from VT.
    max_stack = 1
} )

-- Tier 29
spec:RegisterGear( "tier29", 200336, 200338, 200333, 200335, 200337 )
spec:RegisterAuras( {
    cruel_inspiration = {
        id = 394215,
        duration = 6,
        max_stack = 1
    },
    cruel_epiphany = {
        id = 394253,
        duration = 40,
        max_stack = 5
    }
} )

-- Tier 28
spec:RegisterGear( "tier28", 188884, 188887, 188888, 188889, 188890 )
spec:RegisterSetBonuses( "tier28_2pc", 364437, "tier28_4pc", 363953 )
-- 2-Set - Deliberate Malice - Malefic Rapture's damage is increased by 15% and each cast extends the duration of Corruption, Agony, and Unstable Affliction by 2 sec.
-- 4-Set - Calamitous Crescendo - While Agony, Corruption, and Unstable Affliction are active, your Drain Soul has a 10% chance / Shadow Bolt has a 20% chance to make your next Malefic Rapture cost no Soul Shards and cast instantly.
spec:RegisterAura( "calamitous_crescendo", {
    id = 364322,
    duration = 10,
    max_stack = 1,
} )

spec:RegisterGear( "tier21", 152174, 152177, 152172, 152176, 152173, 152175 )
spec:RegisterGear( "tier20", 147183, 147186, 147181, 147185, 147182, 147184 )
spec:RegisterGear( "tier19", 138314, 138323, 138373, 138320, 138311, 138317 )
spec:RegisterGear( "class", 139765, 139768, 139767, 139770, 139764, 139769, 139766, 139763 )

spec:RegisterGear( "amanthuls_vision", 154172 )
spec:RegisterGear( "hood_of_eternal_disdain", 132394 )
spec:RegisterGear( "norgannons_foresight", 132455 )
spec:RegisterGear( "pillars_of_the_dark_portal", 132357 )
spec:RegisterGear( "power_cord_of_lethtendris", 132457 )
spec:RegisterGear( "reap_and_sow", 144364 )
spec:RegisterGear( "sacrolashs_dark_strike", 132378 )
spec:RegisterGear( "soul_of_the_netherlord", 151649 )
spec:RegisterGear( "stretens_sleepless_shackles", 132381 )
spec:RegisterGear( "the_master_harvester", 151821 )


--[[ spec:RegisterStateFunction( "applyUnstableAffliction", function( duration )
    for i = 1, 5 do
        local aura = "unstable_affliction_" .. i

        if debuff[ aura ].down then
            applyDebuff( "target", aura, duration or 8 )
            break
        end
    end
end ) ]]


spec:RegisterHook( "reset_preauras", function ()
    if class.abilities.summon_darkglare.realCast and state.now - class.abilities.summon_darkglare.realCast < 20 then
        target.updated = true
    end
end )


local SUMMON_DEMON_TEXT

spec:RegisterHook( "reset_precast", function ()
    soul_shards.actual = nil

    local icd = 25

    if debuff.drain_soul.up then
        local ticks = debuff.drain_soul.ticks_remain
        if pvptalent.rot_and_decay.enabled then
            if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 1 end
            if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 1 end
            if debuff.unstable_affliction.up then debuff.unstable_affliction.expires = debuff.unstable_affliction.expires + 1 end
        end
        if pvptalent.essence_drain.enabled and health.pct < 100 then
            addStack( "essence_drain", debuff.drain_soul.remains, debuff.essence_drain.stack + ticks )
        end
    end

    -- Can't trust Agony stacks/duration to refresh.
    local name, _, count, _, duration, expires, caster = FindUnitDebuffByID( "target", 980 )
    if name then
        debuff.agony.expires = expires
        debuff.agony.duration = duration
        debuff.agony.applied = max( 0, expires - duration )
        debuff.agony.count = expires > 0 and max( 1, count ) or 0
        debuff.agony.caster = caster
    else
        debuff.agony.expires = 0
        debuff.agony.duration = 0
        debuff.agony.applied = 0
        debuff.agony.count = 0
        debuff.agony.caster = "nobody"
    end

    if buff.casting.up and buff.casting.v1 == 234153 then
        removeBuff( "inevitable_demise" )
        removeBuff( "inevitable_demise_az" )
    end

    if buff.casting_circle.up then
        applyBuff( "casting_circle", action.casting_circle.lastCast + 8 - query_time )
    end

    class.abilities.summon_pet = class.abilities.summon_felhunter

    if not SUMMON_DEMON_TEXT then
        SUMMON_DEMON_TEXT = GetSpellInfo( 180284 )
        class.abilityList.summon_pet = "|T136082:0|t |cff00ccff[" .. ( SUMMON_DEMON_TEXT or "Summon Demon" ) .. "]|r"
    end
end )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "soul_shards" and amt > 0 and talent.summon_darkglare.enabled then
        if talent.grand_warlocks_design.enabled then reduceCooldown( "summon_darkglare", amt * 2 ) end
        if legendary.wilfreds_sigil_of_superior_summoning.enabled then reduceCooldown( "summon_darkglare", amt * 2 ) end
    end
end )


spec:RegisterStateExpr( "target_uas", function ()
    return active_dot.unstable_affliction
end )

spec:RegisterStateExpr( "contagion", function ()
    return active_dot.unstable_affliction > 0
end )

spec:RegisterStateExpr( "can_seed", function ()
    local seed_targets = min( active_enemies, Hekili:GetNumTTDsAfter( action.seed_of_corruption.cast + ( 6 * haste ) ) )
    if active_dot.seed_of_corruption < seed_targets - ( state:IsInFlight( "seed_of_corruption" ) and 1 or 0 ) then return true end
    return false
end )


local Glyphed = IsSpellKnownOrOverridesKnown

-- Fel Imp          58959
spec:RegisterPet( "imp",
    function() return Glyphed( 112866 ) and 58959 or 416 end,
    "summon_imp",
    3600 )

-- Voidlord         58960
spec:RegisterPet( "voidwalker",
    function() return Glyphed( 112867 ) and 58960 or 1860 end,
    "summon_voidwalker",
    3600 )

-- Observer         58964
spec:RegisterPet( "felhunter",
    function() return Glyphed( 112869 ) and 58964 or 417 end,
    "summon_felhunter",
    3600 )

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
    "incubus", "succubus" )

-- Wrathguard       58965
spec:RegisterPet( "felguard",
    function() return Glyphed( 112870 ) and 58965 or 17252 end,
    "summon_felguard",
    3600 )


-- Abilities
spec:RegisterAbilities( {
    -- Inflicts increasing agony on the target, causing up to 9,300 Shadow damage over 18 sec. Damage starts low and increases over the duration. Refreshing Agony maintains its current damage level. Agony damage sometimes generates 1 Soul Shard.
    agony = {
        id = 980,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",
        cycle = "agony",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "agony", nil, max( 2 * talent.writhe_in_agony.rank + ( azerite.sudden_onset.enabled and 4 or 0 ), debuff.agony.stack ) )
        end,
    },

    -- Talent: Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    amplify_curse = {
        id = 328774,
        cast = 0,
        cooldown = 60, function() return talent.teachings_of_the_satyr.enabled and 45 or 60 end,
        gcd = "off",
        school = "shadow",
        icd = 1.5,

        talent = "amplify_curse",
        startsCombat = false,

        handler = function ()
            applyBuff( "amplify_curse" )
        end,
    },

    -- Talent: Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    banish = {
        id = 710,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.015,
        spendType = "mana",

        talent = "banish",
        startsCombat = true,

        handler = function ()
            if debuff.banish.up then removeDebuff( "target", "banish" )
            else applyDebuff( "target", "banish" ) end
        end,
    },

    -- Talent: Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    burning_rush = {
        id = 111400,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        talent = "burning_rush",
        startsCombat = false,

        handler = function ()
            if buff.burning_rush.up then removeBuff( "burning_rush" )
            else applyBuff( "burning_rush" ) end
        end,
    },

    -- Corrupts the target, causing $s3 Shadow damage and $?a196103[$146739s1 Shadow damage every $146739t1 sec.][an additional $146739o1 Shadow damage over $146739d.]
    corruption = {
        id = 172,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",
        notalent = "wither",

        startsCombat = true,

        handler = function ()
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
    },

    -- Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    curse_of_exhaustion = {
        id = 334275,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function()
            if pvptalent.jinx.enabled then return 1, "soul_shards" end
            return 0.01, "mana"
        end,

        talent = "curses_of_enfeeblement",
        startsCombat = true,

        handler = function ()
            removeBuff( "amplify_curse" )
            applyDebuff( "target", "curse_of_exhaustion" )
            removeDebuff( "target", "curse_of_tongues" )
            removeDebuff( "target", "curse_of_weakness" )

            if pvptalent.jinx.enabled then
                applyDebuff( "target", "corruption" )
                applyDebuff( "target", "agony" )
            end
        end,
    },


    curse_of_fragility = {
        id = 199954,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = function()
            if pvptalent.jinx.enabled then return 1, "soul_shards" end
            return 0.01, "mana"
        end,

        pvptalent = "curse_of_fragility",

        startsCombat = true,
        texture = 132097,

        usable = function () return target.is_player end,
        handler = function ()
            applyDebuff( "target", "curse_of_fragility" )
            setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )
            setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )

            if pvptalent.jinx.enabled then
                applyDebuff( "target", "corruption" )
                applyDebuff( "target", "agony" )
            end
        end,
    },

    -- Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target.
    curse_of_tongues = {
        id = 1714,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function()
            if pvptalent.jinx.enabled then return 1, "soul_shards" end
            return 0.01, "mana"
        end,

        talent = "curses_of_enfeeblement",
        startsCombat = true,

        handler = function ()
            removeBuff( "amplify_curse" )
            removeDebuff( "target", "curse_of_exhaustion" )
            applyDebuff( "target", "curse_of_tongues" )
            removeDebuff( "target", "curse_of_weakness" )
            setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
            setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )

            if pvptalent.jinx.enabled then
                applyDebuff( "target", "corruption" )
                applyDebuff( "target", "agony" )
            end
        end,
    },

    -- Increases the time between an enemy's attacks by 20% for 2 min. Curses: A warlock can only have one Curse active per target.
    curse_of_weakness = {
        id = function() return talent.curse_of_the_satyr.enabled and 442804 or 702 end,
        known = 702,
        flash = { 702, 442804 },
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function()
            if pvptalent.jinx.enabled then return 1, "soul_shards" end
            return 0.01, "mana"
        end,

        startsCombat = true,

        handler = function ()
            removeBuff( "amplify_curse" )
            removeDebuff( "target", "curse_of_exhaustion" )
            removeDebuff( "target", "curse_of_tongues" )
            applyDebuff( "target", talent.curse_of_the_satyr.enabled and "curse_of_the_satyr" or "curse_of_weakness" )
            setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
            setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )

            if pvptalent.jinx.enabled then
                applyDebuff( "target", "corruption" )
                applyDebuff( "target", "agony" )
            end
        end,

        copy = { 702, "curse_of_the_satyr", 442804 },
    },


    -- Talent: Sacrifices 20% of your current health to shield you for 250% of the sacrificed health plus an additional 12,365 for 20 sec. Usable while suffering from control impairing effects.
    dark_pact = {
        id = 108416,
        cast = 0,
        cooldown = function() return talent.frequent_donor.enabled and 45 or 60 end,
        gcd = "off",
        school = "physical",

        talent = "dark_pact",
        startsCombat = false,

        toggle = "defensives",

        usable = function () return health.pct > ( talent.ichor_of_devils.enabled and 10 or 25 ), "insufficient health" end,
        handler = function ()
            applyBuff( "dark_pact" )
            spend( ( talent.ichor_of_devils.enabled and 0.05 or 0.2 ) * health.max, "health" )
        end,
    },


    deathbolt = {
        id = 264106,
        cast = 1,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        pvptalent = "deathbolt",

        handler = function ()
        end,
    },

    -- Talent: Summons a Demonic Circle for 15 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects.
    demonic_circle = {
        id = 268358,
        cast = 0,
        cooldown = 0,
        gcd = "off",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "demonic_circle",
        startsCombat = false,
        nobuff = "demonic_circle",

        handler = function ()
            applyBuff( "demonic_circle" )
        end,
    },


    demonic_circle_teleport = {
        id = 48020,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,

        talent = "demonic_circle",
        buff = "demonic_circle",

        handler = function ()
            if talent.abyss_walker.enabled then applyBuff( "abyss_walker" ) end
            if conduit.demonic_momentum.enabled then applyBuff( "demonic_momentum" ) end
        end,
    },

    -- Talent: Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 1.5 min.
    demonic_gateway = {
        id = 111771,
        cast = function ()
            if legendary.pillars_of_the_dark_portal.enabled or buff.soulburn.up then return 0 end
            return 2 * haste
        end,
        cooldown = 10,
        gcd = "spell",
        school = "shadow",

        spend = 0.1,
        spendType = "mana",

        talent = "demonic_gateway",
        startsCombat = false,

        handler = function ()
            removeBuff( "soulburn" )
        end,
    },


    devour_magic = {
        id = 19505,
        cast = 0,
        cooldown = function() return talent.teachings_of_the_black_harvest.enabled and 10 or 15 end,
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

    -- Drains life from the target, causing 2,174 Shadow damage over 4.0 sec, and healing you for 500% of the damage done. Drain Life heals for 15% more while below 50% health.
    drain_life = {
        id = 234153,
        cast = function () return 5
            * haste
            * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
        channeled = true,
        breakable = true,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function () return buff.soul_rot.up and 0 or 0.03 end,
        spendType = "mana",

        startsCombat = true,

        start = function ()
            applyDebuff( "target", "drain_life" )
            removeBuff( "inevitable_demise" )
        end,

        finish = function ()
            if talent.accrued_vitality.enabled or conduit.accrued_vitality.enabled then applyBuff( "accrued_vitality" ) end
        end,
    },

    -- Talent: Drains the target's soul, causing 5,810 Shadow damage over 3.8 sec. Damage is increased by 100% against enemies below 20% health. Generates 1 Soul Shard if the target dies during this effect.
    drain_soul = {
        id = 198590,
        flash = { 686, 198590 },
        cast = function() return 5 * ( buff.nightfall.up and 0.5 or 1 ) * haste end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        prechannel = true,
        breakable = true,
        breakchannel = function () removeDebuff( "target", "drain_soul" ) end,

        talent = "drain_soul",
        startsCombat = true,

        break_any = function ()
            if not settings.manage_ds_ticks then return true end
            return nil
        end,

        tick_time = function ()
            if not talent.shadow_embrace.enabled or not settings.manage_ds_ticks or debuff.shadow_embrace.stack > 2 then return nil end
            return class.auras.drain_soul.tick_time
        end,

        start = function ()
            applyDebuff( "target", "drain_soul" )
            applyBuff( "casting", 5 * haste )

            channelSpell( "drain_soul" )

            removeStack( "decimating_bolt" )
            removeBuff( "malefic_wrath" )
            removeBuff( "nightfall" )

            if talent.shadow_embrace.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
        end,

        tick = function ()
            if not settings.manage_ds_ticks or not talent.shadow_embrace.enabled or debuff.shadow_embrace.stack > 2 then return end
            applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 )
        end,

        bind = "shadow_bolt"
    },

    --[[ Summons an Eye of Kilrogg and binds your vision to it. The eye is stealthed and moves quickly but is very fragile.
    eye_of_kilrogg = {
        id = 126,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "eye_of_kilrogg" )
        end,
    }, ]]

    -- Strikes fear in the enemy, disorienting for 20 sec. Damage may cancel the effect. Limit 1.
    fear = {
        id = 5782,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "fear" )
        end,
    },

    -- Talent: Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 5.5 sec.
    fel_domination = {
        id = 333889,
        cast = 0,
        cooldown = function () return 180 - 90 * talent.eternal_servitude.rank - 60 * talent.fel_pact.rank + conduit.fel_celerity.mod * 0.001 end,
        gcd = "off",
        school = "shadowstrike",

        talent = "fel_domination",
        startsCombat = false,
        essential = true,
        nomounted = true,
        nobuff = "grimoire_of_sacrifice",

        handler = function ()
            applyBuff( "fel_domination" )
        end,
    },

    -- Talent: Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal 1,678 additional Shadow damage. Lasts 1 |4hour:hrs; or until you summon a demon pet.
    grimoire_of_sacrifice = {
        id = 108503,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        talent = "grimoire_of_sacrifice",
        startsCombat = false,
        essential = true,

        nobuff = "grimoire_of_sacrifice",

        usable = function () return pet.active, "requires a pet to sacrifice" end,
        handler = function ()
            if pet.felhunter.alive then dismissPet( "felhunter" )
            elseif pet.imp.alive then dismissPet( "imp" )
            elseif pet.succubus.alive then dismissPet( "succubus" )
            elseif pet.voidawalker.alive then dismissPet( "voidwalker" ) end
            applyBuff( "grimoire_of_sacrifice" )
        end,
    },

    -- Talent: A ghostly soul haunts the target, dealing 2,273 Shadow damage and increasing your damage dealt to the target by 10% for 18 sec. If the target dies, Haunt's cooldown is reset.
    haunt = {
        id = 48181,
        cast = function() return 1.5 * ( 1 - 0.25 * talent.improved_haunt.rank ) end,
        cooldown = 15,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "haunt",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "haunt" )
            if level > 51 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
        end,
    },

    -- Sacrifices 25% of your maximum health to heal your summoned Demon for twice as much over 4.0 sec.
    health_funnel = {
        id = 755,
        cast = 5,
        channeled = true,
        breakable = true,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        startsCombat = false,

        usable = function () return pet.active and pet.alive and pet.health_pct < 100, "requires pet" end,
        start = function ()
            applyBuff( "health_funnel" )
        end,
    },

    -- Talent: Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    howl_of_terror = {
        id = 5484,
        cast = 0,
        cooldown = function() return 40 - 15 * talent.annihilans_bellow.rank end,
        gcd = "spell",
        school = "shadow",

        talent = "howl_of_terror",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "howl_of_terror" )
        end,
    },

    --[[ Passive in 10.0.5 -- Talent: Summon an Inquisitor's Eye that periodically blasts enemies for 254 Shadowflame damage and occasionally dealing 290 Shadowflame damage instead. Lasts 1 |4hour:hrs;.
    inquisitors_gaze = {
        id = 386344,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "shadow",

        talent = "inquisitors_gaze",
        startsCombat = false,
        nobuff = "inquisitors_gaze",

        handler = function ()
            applyBuff( "inquisitors_gaze" )
        end,
    }, ]]

    -- Talent: Your damaging periodic effects from your spells erupt on all targets, causing $324540s1 Shadow damage per effect.
    malefic_rapture = {
        id = 324536,
        cast = function ()
            if buff.tormented_crescendo.up or buff.calamitous_crescendo.up then return 0 end
            return 1.5 * ( 1 - 0.15 * talent.improved_malefic_rapture.rank )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function () return ( buff.tormented_crescendo.up or buff.calamitous_crescendo.up ) and 0 or 1 end,
        spendType = "soul_shards",

        startsCombat = true,
        texture = 236296,

        usable = function () return active_dot.agony + active_dot.corruption + active_dot.seed_of_corruption + active_dot.unstable_affliction + active_dot.vile_taint + active_dot.phantom_singularity + active_dot.siphon_life > 0, "requires affliction dots" end,

        handler = function ()
            removeStack( "cruel_epiphany" )

            if buff.calamitous_crescendo.up then removeBuff( "calamitous_crescendo" ) end
            if buff.tormented_crescendo.up then removeBuff( "tormented_crescendo" ) end

            if buff.umbrafire_kindling.up then
                removeStack( "umbrafire_kindling" )
                if dot.agony.up               then dot.agony.expires               = dot.agony.expires               + 2 end
                if dot.corruption.up          then dot.corruption.expires          = dot.corruption.expires          + 2 end
                if dot.unstable_affliction.up then dot.unstable_affliction.expires = dot.unstable_affliction.expires + 2 end
                if dot.vile_taint.up          then dot.vile_taint.expires          = dot.vile_taint.expires          + 2 end
                if dot.phantom_singularity.up then dot.phantom_singularity.expires = dot.phantom_singularity.expires + 2 end
                if dot.siphon_life.up         then dot.siphon_life.expires         = dot.siphon_life.expires         + 2 end
            end

            if talent.dread_touch.enabled then
                if debuff.unstable_affliction.up then applyDebuff( "target", "dread_touch" ) end
                active_dot.dread_touch = active_dot.unsable_affliction
            end

            if debuff.wither.up then applyDebuff( "target", "wither", nil, debuff.wither.stack + ( buff.malevolence.up and 2 or 1 ) ) end

            --[[ if talent.malefic_affliction.enabled and active_dot.unstable_affliction > 0 then
                if buff.malefic_affliction.stack == 3 then
                    if debuff.unstable_affliction.up then applyDebuff( "target", "dread_touch" )
                    else active_dot.dread_touch = 1 end
                else addStack( "malefic_affliction" ) end
            end ]]
            if legendary.malefic_wrath.enabled then addStack( "malefic_wrath" ) end
        end,
    },

    -- [430014] Dark magic erupts from you and corrupts your soul for $442726d, causing enemies suffering from your Wither to take $446285s1 Shadowflame damage and increase its stack count by $s1.; While corrupted your Haste is increased by $442726s1% and spending Soul Shards on damaging spells grants $s2 additional stack of Wither.
    malevolence = {
        id = 442726,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "spell",

        spend = 0.010,
        spendType = 'mana',

        talent = "malevolence",
        startsCombat = true,

        handler = function()
            if debuff.wither.up then applyDebuff( "target", "wither", nil, debuff.wither.stack + 6 ) end
            applyBuff( "malevolence" )
        end,
    },

    -- Talent: Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    mortal_coil = {
        id = 6789,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "mortal_coil",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mortal_coil" )
            active_dot.mortal_coil = max( active_dot.mortal_coil, active_dot.bane_of_havoc )
            gain( 0.2 * health.max, "health" )
        end,
    },

    -- Surrounds the caster with a shield that lasts 3 sec, reflecting all harmful spells cast on you.
    nether_ward = {
        id = 212295,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "nether_ward",
        startsCombat = false,
        toggle = "defensives",

        handler = function ()
            applyBuff( "nether_ward" )
        end,
    },

     -- Unleash wicked magic upon your target's soul, dealing $o Shadow damage over $d.; Deals $s2% increased damage, up to ${$s2*$s3}%, per damage over time effect you have active on the target.
     oblivion = {
        id = 417537,
        cast = 3,
        channeled = true,
        cooldown = 45.0,
        gcd = "spell",

        spend = 2,
        spendType = "soul_shards",

        startsCombat = true,
        pvptalent = "oblivion",

        usable = function() return debuff.agony.up or debuff.doom.up or debuff.corruption.up or debuff.unstable_affliction.up or debuff.vile_taint.up or debuff.phantom_singularity.up or debuff.siphon_life.up, "requires an active dot effect" end,

        start = function ()
            applyDebuff( "target", "oblivion" )
        end,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'sp_bonus': 2.66, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 10.0, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 3.0, }
    },

    -- Talent: Places a phantom singularity above the target, which consumes the life of all enemies within 15 yards, dealing 10,570 damage over 12.2 sec, healing you for 25% of the damage done.
    phantom_singularity = {
        id = 205179,
        cast = 0,
        cooldown = 33,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "phantom_singularity",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "phantom_singularity" )
            if set_bonus.tier30_4pc > 0 then applyDebuff( "target", "infirmity" ) end
        end,
    },

    -- Embeds a demon seed in the enemy target that will explode after $d, dealing $27285s1 Shadow damage to all enemies within $27285A1 yards and applying $?a445465[Wither][Corruption] to them.; The seed will detonate early if the target is hit by other detonations, or takes ${$SPS*$s1/100} damage from your spells.
    seed_of_corruption = {
        id = 27243,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "seed_of_corruption",
        startsCombat = true,
        nodebuff = "seed_of_corruption",

        velocity = 30,

        handler = function()
            removeStack( "cruel_epiphany" )
            removeStack( "umbrafire_kindling" )
        end,

        impact = function ()
            applyDebuff( "target", "seed_of_corruption" )
            if active_enemies > 1 and talent.sow_the_seeds.enabled then
                active_dot.seed_of_corruption = min( active_enemies, active_dot.seed_of_corruption + 2 )
            end
        end,
    },

    -- Sends a shadowy bolt at the enemy, causing 2,321 Shadow damage.
    shadow_bolt = {
        id = 686,
        cast = function()
            if buff.nightfall.up then return 0 end
            return 2 * ( 1 - 0.15 * talent.improved_shadow_bolt.rank ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.015,
        spendType = "mana",

        notalent = "drain_soul",
        startsCombat = true,
        velocity = 20,

        cycle = function () return talent.shadow_embrace.enabled and "shadow_embrace" or nil end,

        handler = function ()
            removeBuff( "nightfall" )
            removeBuff( "malefic_wrath" )
        end,

        impact = function ()
            if talent.shadow_embrace.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
        end,
    },

     -- Conjure a Shadow Rift at the target location lasting $d. Enemy players within the rift when it expires are teleported to your Demonic Circle.; Must be within $s2 yds of your Demonic Circle to cast.
     shadow_rift = {
        id = 353294,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "shadow_rift",
        startsCombat = false,
        buff = "demonic_circle",
     },

    -- Talent: Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowflame = {
        id = 384069,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "shadowflame",

        talent = "shadowflame",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shadowflame" )
        end,
    },

    -- Talent: Stuns all enemies within 8 yds for 3 sec.
    shadowfury = {
        id = 30283,
        cast = 1.5,
        cooldown = function () return talent.darkfury.enabled and 45 or 60 end,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "shadowfury",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shadowfury" )
        end,
    },

    -- Siphons the target's life essence, dealing 5,782 Shadow damage over 15 sec and healing you for 30% of the damage done.
    siphon_life = {
        id = 63106,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "siphon_life" )
        end,
    },

    soul_rip = {
        id = 410598,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        startsCombat = true,
        pvptalent = "soul_rip",

        handler = function ()
            applyDebBuff( "target", "soul_rip" )
        end,
    },

    -- Talent: Wither away all life force of your current target and up to 3 additional targets nearby, causing your primary target to suffer 10,339 Nature damage and secondary targets to suffer 5,169 Nature damage over 8 sec. For the next 8 sec, casting Drain Life will cause you to also Drain Life from any enemy affected by your Soul Rot, and Drain Life will not consume any mana.
    soul_rot = {
        id = function() return talent.soul_rot.enabled and 386997 or 325640 end,
        cast = 1.5,
        cooldown = function() return 60 - 8 * talent.souleaters_gluttony.rank end,
        gcd = "spell",
        school = "nature",

        spend = 0.005,
        spendType = "mana",

        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "soul_rot" )
            active_dot.soul_rot = min( 4, active_enemies )
            if legendary.decaying_soul_satchel.enabled then applyBuff( "decaying_soul_satchel", nil, active_dot.soul_rot ) end
            if talent.dark_harvest.enabled then applyBuff( "dark_harvest", nil, active_dot.soul_rot ) end
        end,

        copy = { 386997, 325640 }
    },

    soulburn = {
        id = 385899,
        cast = 0,
        cooldown = 6,
        gcd = "off",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "soulburn",
        startsCombat = false,
        nobuff = "soulburn",

        handler = function ()
            applyBuff( "soulburn" )
        end,
    },

    -- Stores the soul of the target party or raid member, allowing resurrection upon death. Also castable to resurrect a dead target. Targets resurrect with 60% health and at least 20% mana.
    soulstone = {
        id = 20707,
        cast = function() return 3 * ( 1 - 0.5 * talent.swift_artifice.rank ) end,
        cooldown = 600,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "soulstone" )
        end,
    },


    spell_lock = {
        id = 19647,
        known = function () return IsSpellKnownOrOverridesKnown( 119910 ) or IsSpellKnownOrOverridesKnown( 132409 ) end,
        cast = 0,
        cooldown = 24,
        gcd = "off",

        startsCombat = true,
        -- texture = ?

        toggle = "interrupts",
        interrupt = true,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,

        copy = { 19647, 119910, 132409, 119898 }
    },

    -- Subjugates the target demon up to level 61, forcing it to do your bidding for 5 min.
    subjugate_demon = {
        id = 1098,
        cast = 3,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        usable = function () return target.is_demon and target.level < level + 2, "requires demon target" end,
        handler = function ()
            summonPet( "controlled_demon" )
        end,
    },

    -- Talent: Summons a Darkglare from the Twisting Nether that extends the duration of your damage over time effects on all enemies by 8 sec. The Darkglare will serve you for 20 sec, blasting its target for 928 Shadow damage, increased by 10% for every damage over time effect you have active on any target.
    summon_darkglare = {
        id = 205180,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "summon_darkglare",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "darkglare", 20 )
            if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 8 end
            if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 8 end
            -- if debuff.impending_catastrophe.up then debuff.impending_catastrophe.expires = debuff.impending_catastrophe.expires + 8 end
            if debuff.scouring_tithe.up then debuff.scouring_tithe.expires = debuff.scouring_tithe.expires + 8 end
            if debuff.siphon_life.up then debuff.siphon_life.expires = debuff.siphon_life.expires + 8 end
            if debuff.unstable_affliction.up then debuff.unstable_affliction.expires = debuff.unstable_affliction.expires + 8 end
        end,
    },


    summon_felhunter = {
        id = 691,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        startsCombat = false,
        essential = true,
        nomounted = true,

        usable = function ()
            if pet.alive then return false, "pet is alive"
            elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
            return true
        end,
        handler = function ()
            removeBuff( "fel_domination" )
            removeBuff( "grimoire_of_sacrifice" )
            summonPet( "felhunter" )
        end,

        copy = 112869,

        bind = function ()
            if settings.default_pet == "summon_felhunter" then return "summon_pet" end
        end,
    },


    summon_imp = {
        id = 688,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        startsCombat = false,
        essential = true,
        nomounted = true,

        usable = function ()
            if pet.alive then return false, "pet is alive"
            elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
            return true
        end,
        handler = function ()
            removeBuff( "fel_domination" )
            removeBuff( "grimoire_of_sacrifice" )
            summonPet( "imp" )
        end,

        bind = function ()
            if settings.default_pet == "summon_imp" then return "summon_pet" end
        end,
    },


    summon_pet = {
        name = "|T136082:0|t |cff00ccff[Summon Demon]|r",
        bind = function () return settings.default_pet end
    },


    summon_sayaad = {
        id = 366222,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        startsCombat = false,
        essential = true,
        nomounted = true,

        usable = function ()
            if pet.alive then return false, "pet is alive"
            elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
            return true
        end,
        handler = function ()
            removeBuff( "fel_domination" )
            removeBuff( "grimoire_of_sacrifice" )
            summonPet( "sayaad" )
        end,

        copy = { 365349, "summon_incubus", "summon_succubus" },

        bind = function()
            if settings.default_pet == "summon_sayaad" then return { "summon_incubus", "summon_succubus", "summon_pet" } end
            return { "summon_incubus", "summon_succubus" }
        end,
    },


    summon_voidwalker = {
        id = 697,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        startsCombat = false,
        essential = true,
        nomounted = true,

        usable = function ()
            if pet.alive then return false, "pet is alive"
            elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
            return true
        end,
        handler = function ()
            removeBuff( "fel_domination" )
            removeBuff( "grimoire_of_sacrifice" )
            summonPet( "voidwalker" )
        end,

        bind = function ()
            if settings.default_pet == "summon_voidwalker" then return "summon_pet" end
        end,
    },

    unending_breath = {
        id = 5697,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "unending_breath" )
        end,
    },

    -- Hardens your skin, reducing all damage you take by 25% and granting immunity to interrupt, silence, and pushback effects for 8 sec.
    unending_resolve = {
        id = 104773,
        cast = 0,
        cooldown = function() return 180 - 45 * talent.dark_accord.rank end,
        gcd = "off",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "unending_resolve" )
            if talent.aura_of_enfeeblement.enabled then
                applyDebuff( "target", "curse_of_tongues" )
                applyDebBuff( "target", "curse_of_weakness" )
            end
        end,
    },

    -- Talent: Afflicts one target with 18,624 Shadow damage over 21 sec. If dispelled, deals 32,416 damage to the dispeller and silences them for 4 sec. Generates 1 Soul Shard if the target dies while afflicted.
    unstable_affliction = {
        id = function () return pvptalent.rampant_afflictions.enabled and 342938 or 316099 end,
        cast = function() return 1.5 * ( 1 - 0.2 * talent.perpetual_unstability.rank ) end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "unstable_affliction",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "unstable_affliction" )
            -- removeBuff( "malefic_affliction" )

            if azerite.cascading_calamity.enabled and debuff.unstable_affliction.up then
                applyBuff( "cascading_calamity" )
            end

            if azerite.dreadful_calling.enabled then
                gainChargeTime( "summon_darkglare", 1 )
            end
        end,

        copy = { 342938, 316099 },
    },

    -- Talent: Unleashes a vile explosion at the target location, dealing 8,331 Shadow damage over 10 sec to 8 enemies within 10 yds and applies Agony and Curse of Exhaustion to them.
    vile_taint = {
        id = 278350,
        cast = 1.5,
        cooldown = 25,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "vile_taint",
        startsCombat = true,
        toggle = "cooldowns", -- Treat as CD since CDs are very dependent on its use.

        handler = function()
            applyDebuff( "target", "vile_taint" )
            applyDebuff( "target", "agony" )
            active_dot.agony = min( active_enemies, active_dot.agony + 7 )
            applyDebuff( "target", "curse_of_exhaustion" )
            active_dot.curse_of_exhaustion = min( active_enemies, active_dot.curse_of_exhaustion + 7 )
            if set_bonus.tier30_4pc > 0 then applyDebuff( "target", "infirmity", 10 ) end
        end,

        -- Azerite
        auras = {
            cascading_calamity = {
                id = 275378,
                duration = 15,
                max_stack = 1
            }
        }
    },

    -- Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing $s1 Shadowflame damage immediately and an additional $445474o1 Shadowflame damage over $445474d.$?s137046[; Periodic damage generates 1 Soul Shard Fragment and has a $s2% chance to generate an additional 1 on critical strikes.; Replaces Immolate.][; Replaces Corruption.]
    wither = {
        id = 445468,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 0.015,
        spendType = 'mana',

        talent = "wither",
        startsCombat = true,

        handler = function()
            applyDebuff( "target", "wither" )
        end,
    }
} )

spec:RegisterSetting( "manage_ds_ticks", false, {
    name = "Model |T136163:0|t Drain Soul Ticks",
    desc = "If checked, the addon will expend |cFFFF0000more CPU|r determining when to break |T136163:0|t Drain Soul channels in favor of " ..
        "other spells.  This is generally not worth it, but is technically more accurate.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "agony_macro", nil, {
    name = "|T136139:0|t Agony Macro",
    desc = "Using a macro makes it easier to apply your DOT effects to other targets without switching targets.",
    type = "input",
    width = "full",
    multiline = true,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.agony.name end,
    set = function () end,
} )

-- TODO: Confirm if this will work with Wither.
spec:RegisterSetting( "corruption_macro", nil, {
    name = "|T136118:0|t Corruption Macro",
    desc = "Using a macro makes it easier to apply your DOT effects to other targets without switching targets.",
    type = "input",
    width = "full",
    multiline = true,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.corruption.name end,
    set = function () end,
} )

spec:RegisterSetting( "sl_macro", nil, {
    name = "|T136188:0|t Siphon Life Macro",
    desc = "Using a macro makes it easier to apply your DOT effects to other targets without switching targets.",
    type = "input",
    width = "full",
    multiline = true,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.siphon_life.name end,
    set = function () end,
} )


spec:RegisterRanges( "corruption", "agony", "subjugate_demon", "mortal_coil" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageDots = true,
    damageExpiration = 6,

    potion = "spectral_intellect",

    package = "Affliction",
} )


spec:RegisterPack( "Affliction", 20240801, [[Hekili:L3ZAVTnUw(BP4IX1UnJRLstB6SXzWU39lZGfZEXnZDVFyXAzfB5eHiB5vsoTbiW)23dPEXhNdjLTC6JffinrI88IhEEqEi1mVz)5SBwgwen7p8N4)(jxoXBS3hNC57VC2nfpTnA2nBdx8q4DWVSjCn8Z)1vRsIxueNUH9QNssdxYarE6USfWRVVOyB(V8U3DxCX97UD8I01VlpE9UKqwpwKfUQG93lE3SBUDxCsXVTz2T44)caMBJwap(dWVEF8YLrLTnkFXSByT9NN8XF2)8Fz)8)8(O9Z)NHzWpaSgVz)8H5Pzf7NNUAeqKzPRItaslKt15J3MfbK1THftxfLeSmDD8go1Dw8QPfXRJUEYGxTnQyCys8Jr7)DTU92PVlF361PBcGwH)(hdZIdVnj6mMmB6IKOWhJcc3MC2YOvH7skMo5S0TtZIYDdafzXBEiQiWl42DRwLF2JHj7AE6yVX3hMhSlpI)2UapFu45FWWZli)PnlySgWyXRQGRx5)heLKhnDY4loBr6MLXmyoTgmJv4WbdBzUfPPjlt)8MXl3LXhN(PFQ5rGwxsqwArZ7Mo55NPF7p9tga70jJ6cV6F08QVkV6FA4veW2rE1lyD4MDHjAkEX5JVnkjnld(rEqX9rb572Simjjk75NLAgBIfm3mAvEWDHRVnUt69(4433n87F043li6lls2TmctaKT72Nc(89rjBdYHFMOW4F((yWog8K7cIbsldS1efedQfDHa8jiaFZeGFVraLZldQ1F0KdGr2fJd38uWYT5nAzVDOKKyDCwwAwq6QGvzaM3LfTmOiDnm6L(5834pzKs73806DrGHOnzG1Zeg9NVnEZYKO343jTxFJ0UVnA3VJ0UFFs7BZItZIlEs1oJVODgpbRmVI0KkL9NNFM2YKrtteDRrqp6nd9Elyd8nTaH5yH1MXXBkan1OffqJqGdZ0kR7)mR7DyKqr1peMpKZAkZYq06BJYyMjhnA01dn6GHqgsZzEoYzEeCM95hkwvi5mCLR7YIxNgNfX6rE4IS4vXlI4X7eMeTPym67hhTHr8ljcbkcipO5la6B3w(elaEGLMKKGIWS7IkYhR3MGW0OR9bMPeV5PFU0Qn0W8bo1zpCY5(WDBiSPVBtEbJrccBcDLrQVQHgapN5FoClbFEFiOCeCBAca(MMWEbNAtsx8G4tLNgVfmbSTAUB1m3LGp6T3hUbgzdYbddqOXSj4GdQfpa)5ZpxtxinIgrpwGIOhHaFbbkOtgW(tnC0(EJGMGnOGUvwCOo(hyGThrtC5zOuwt0qACC9BOb5ILmUrNJBMmZLgTMt5I(2)Ktr0qNzNyXYCzqtZ6nZuALuctEkzL2huMvYYWShUd6EKjEmpG9UhJKjKwVhv0jmw18OwbZGHTXDQGZXzrRbQm)A)jccDLgnYWikKnwWJfnPh1KXK3e2K2gIPSzMbZ2CeW8bnWSn3mycVlDZt66y8hxZUVD4N(0BEv7JR07CIpv4sS5x6Or4D14IXyLdQbrBIwhhbdcUiGuepMntPrigMOFquKNSKEOYi(B0MpC1VQmA(gdwsSrrSChck)ZGK48Iskl9UflT3Q4IO152Bw5QbCwo4pFbiW1POP(cHK1U2b2Hm4E0ayLz01GmcCYhKfULfPbR53MMNpyv8D3xeunkF17LgTAe5AUp5wHKhQ4ZdUYB8fyjPwd)PrFjAXoiFew6zVfKYJxh(Lrsw4IG0vYGK2s2vuWNWfU5HR8gqcZRN6jXOiAbmYFOJeLl0YqDzHZq3aF4FXOrd0mPifcsvF4mKIdPHY(RSYhVAQNn0vAiKHRAMPH6rmvv2pX3SimVOIT1day0GAGEHSs41xisdebZr13Zf7lpgrwRxgXdvN)3ndmsOroQ2SOvGxK7z41eTLhV9E(eYvrDPxkoh5c4gnQYOpHi8Huca5wfLl)4XGizXdtXFhmHkG)(rd6semcAMXBEm9HOGTPFokliEZQD5mZotAsx66jdS2wa(MIaBzgixcyV5mw(tCzFPnmu5WGHgKdxDoLyQEK(Cj3Ycb4FGi0VBieX0Bzoi3hMT863dgsROHI0S1W)dPbTauKweTzz6aoAqErLoG3abqzfThcEKdUTNaAjXBZbfsKOcEkRZtruc4D40A1R2WM4UcC3AsIu(UMMQiJkvURTkuTibrpgxAhBj4CoVst663F5ZpBSb(tgyZnT4CPk0rrzkQ(oWfQtrjGMqMYJHOsSA79C1MlhRXql(UM6p4yd(yee1XqR4XqChiGZg0MmW9Oqm4P9AwGcQcWFyd7PI)SfhGA7lJDzXtl4sp(kmjfKCdcV6YbNMWBgwfEBDpB48M(1ea8vdTN2ZOR(1HDiXhHWRufnIHTywaj0YR(Wa61aaSiY4NRaRvFT5ARksIXq3dHq7acrx4uw3AFsBqPdE1WAjNw)aVebGYpyVUCn3qAr9SQjAgieqpYGUa(RzAnGRXyibY(nAiNvuSGNzezGrhXNpP0PFJ(CDua6w(Q0VhunrQoDCnFEyPKZG4ow0KRyRo)dSTqcuPyiB4WHYa8QpakOSzDNpz0aw9l0oFSSHJATlTmfMOCBcejr6AnndCf0grPWk27ahm0HLk0dCtlf2QWaNa2gvfBKLOsDASDO6GN(kepAGffaCmYJqIsBsm4QbhqMgDj1g3SU3orNWo)fdu1ZU0r9itYJ6iibdOP3gMunOCAKic69YTrtuHhaB5sWPfu63flawlX)DEaHQHPnfJhf9L3pRhMtOLm2YttGKTtzPwvPwsZwyYKlxMGqf1DqnHfEBEAcByS91diJLbZQ(GfHB4)gcQDoPXME4Cun9uuvomey1aS9vjuay91IfE(3SlhylZ2TfSPtRmgc2(QTgKOKGtrqCICys5VeJKfxcPVxOzQaTTfyPja42At6gSCsr9Lz9enIvTCFCjwzfVMLAlbYgcnBy31UywY65OjGMiunR8lgWiFJGzoFZJcy)(zSFjD1Qai(oyAbFVAPkB1YCM4LHU)edlXsTtc)j8vAuS2WOanAHgxbhy6tJYQw9bkbDgPfivjTJePaJ1KlAzDBGc8uPaFkkyee8jm4Tmi6rEujlxMpo6lX5fqNvFoBMPCPMrrVxp9cwsN6tq8bf6)Y(5)ZO9Z)mew9(5fP7NdJYWVusP5WlIlUF)8)9MrSQZPqvdQF)9aCJYH)e(r8Aio0L7NZR8HZyTijz)8BJ4GgE(Q4S8IXg0ZYtslQlDup5GGBR4Nrd0RlX6YmDQhA1Gwv8XmBSsLYz9yO04V(aln68DsdV84yOUCgdOr5vwH6Or61dBDHYIPhww)5IP4ruAOV176Ps6kJCC8Y)GgV8rKUEiJxEuJxytenOE0hJx6O8WgV8jhV8nmE5FeJxLLMTM5hf))1dCOwoyR1LXIp2USagE3gTaSu82lgPSOIqoRa4LF21EdUp8X0f1QtClx)2Q9Zt3K8e7NrSFiB(A)8TzPpgZm6ecwGab2z1nGzdlf(zwzVQPw49)NWJIb4UjkU89wb2TPmtGIGXK1nzVOA26OR8D6j0GxdYEDyElhrwnM2N60mWAU4jpirKpUiY(CimrK2jxQtUZ)MteXGCW9HBwkgehRM)ylBwkpMt8z4ATMvh(rzSD9X5EKKMUmy1USNi7XF5Vaty)h5rqmf)nwI0WS3QmPzXDabWWNSvgoXFTsaY(Bi9Lpd9jj(byQ2nCrKq8iWCWBGaD3p)VNwa)(FRC5bHhkuU5Ztba)Ffdrxp)pd5fjoJuu4GQC8J(ceW8MWe(yCv1VlL2pb)nWXd9Jb3hkXhAheOZOJ(F3fVDB0s6(psB0JTRm8rqxhUd3Sac0ldetSimj61SBEe0JGUvDMy)O)5ZU5ZHzBaAjF2n8WiJxVLFexxXgIEnxl)17NNXyImML2801qRc3bJPLbvUagGVlkhmW(FeZm579lmTLnaM4V(1sJcube)6YiDBACHTwp07lJSIs9Hdn8G2KtiWTcwICHWfqOTZrQVlJg2ATtOuF(fctDOJghgWTcwI8cXfq2hn8jrJyu0iqx51ocuRIe7A)9lWprG9LHMpNu1Z4GN2RLOvAGALwTpzPFb(jcSVm087Td26eLmbxH2ir19n4La8)yt(UTmVYmqxhVzD4s7N)FdauZYZ)Z)Y(5qeSzqSwlJZzXbSSbMx0RZpuKe9lWPblEa6nWe)11N8uReDVc9pyx5OdQ0NuGtd2tRePNG((Fhjg2QJG2R7uuSA(qkjbKIDqHiXo2AesbntDQBjVcOf2jFciQzg6ubXEvoqn7RAxGu1cQ3CicO9XxakMahhHCMaI9Rm4ONFvc9lpPq3R)vIPazVQt4pPxhc91sj54ax)BSXNspqAFYvPt59zVRG(az(pDYO0ZPg17bqtObGunbkWhREdOqcHJU(fjekF9lsiCJ8IGKMkrrb0TvOIBXQ0CbH86ofTcD6hI34AVwpaqLx7yK8gbQ2R7A4QDkrPtm4pza(ReDNUnQSf5GMhK74RTVlvyWVpU94WG70jJQzVdKWoy6YgzrhBLEcUKdv4TXCOBhj4pza(ReDBxdwBteXGFVObJFbisQb7gHDW0LnYIo(9gJnDzpbS1AZPmiIsTRqrCCH1mjKOfLxJkyx4lBT2DuANViBMC6lAXykk9uVLgXfEiTQd4G8QEehzMAUmwnUVlw5mQw1bC4oNzT5YyLAtiiUslreKuTRVXJuzl1b4B7Mfex3Wwx6a2j3pDCmBQ5YyLApiiUspruvCBS74XJ5XoA47WabI2VTU0bS7(yN1MlJvQuHo04qo1W3fiRFhGIaA0g5kT7mgOYRZaSDqX5O11mID870uC0s2w3W3HMV2Pg(Uazh0biAKR0UZyOZAzo5A5O9gze7oQLzUTgXNwQpNO7Kz00sSvVZAxDXkgm6Y9XSdwaAlnptZBLVrMrxWaB1DVoF5zLVOUnMDqNtGVmFFmxRy9cQd8UFq1b05RVx0bAnvqTJ6INi6gBriVJCRZmTtmSl3AnGw9ChxW7WuwiCDyPUj2kHdCNHiwo)JyxXEXGyVU5LeQphbvtaXELQP2wpTdwVQwH(jVNs9VF3ux98zl7N41DIcifFfjyjNuCSZ(j248JhW9BnFqA(743fwpIAP4yhYoDBE(jb0OgVlpVYVUt2V75YAOxHw)x5je6LixUjkGgPfDehh)C0txPn03MvFjQuckB39H4GY(932GMY5W3OGE)V)BRRRI6p0w(0SR5EM5Pz3awTUpnB2n3eV(Vo7g(ZzFbc5Nbk4x(d(N0WkWo7FR(7wi1wfn7gHteiRZvFNan1Jfq0orqIeZUziq275119(5xZkUS9ZhiCAwPogJnnE0(5p)CjmKYLGc3CWl2A9IXUeIVIDncGN(yzdKXNELPZPneYZ4(UPrE61Umn55HsEehzNAYBunkbiIFbqucp9lbIYN72fbbmEnfIWVrGWoy3CelD4U3p)k2O6SIz)HVIoyTovfBbAzStEQ4FlPtHDucBzvnjx95ZF)CGk9kjrKr)QRfGMraL0)RhPWgZXhfnti(DCUWaorHD1bWFNrQ5kNquJ(cTU3akDZYtdDJSX2ArSF(B5dfm9gfLKrLFetZI3wQt8v5weHPKEUzLu)EuP0NqHXJwP0ZIsjLPfRZoojkLyuZXQu6BrP03QsPFxukLSi5ZuqEVOcYTIQdO6cwSm6DrdHsmo2sNUi6AUla4S1f1IXqPB)I6b9wpzQV)6ALcXBjdUaPmWbDFpmrZfD2aVAygTctJodTAqQX9Nry4I5CJXmujaRdIJ4uc42SlHrUQPz1t(TbDvBNFZEpMW0r(Gv7Rkt56OoI72hO1r8j0roOa3(wrhbK9Fur2tfKpdx87(J6bJ2hWMNFt1PsRjVI6(1(1Fuenir(LUfACurBpRfFSFd8qdOi14xrnvg3WcVYbEqPzl(9niMxE3iO21mr8B7OkTOVYkIKa)IevZpsVqcojZgAMuRN3yxUYT7iXxnsxv)aUXAnRucHCvDLueXo)(yfZ8IDu3mZT8YOukOd(GL8JkXKaQBVBlXMIzh)UiPfmGGnKjAFrri5KXhr2P6BCjJxUSZ8IOHWkaPhhwRaR2aRv7ED3CNI2PW9idWyFcHX4FrmXzTAGu(93O183nEtqd)RQDaIGgCWyABUiM(ajM2YhR8uxGh7dwAFVo5HmcdhF6t7N)gUCw)72HSyT5kDNtcDYkVJcvKat9jmiAMneANaVWi7o5lWXriRKTHpJO40Vrd7Lms39OioTS6JhldLgm1C1VQ0LT5IDXM)c7sizbShNXOYRq9l(z5cFwba2LlfV3urCAS3LlCkR7Qw0PzbKu6l3Lj2xQuyOOG9vivkqlJKqzF50GQLyBIXUIQW0s8OAySfpgsH99IbokD7cZd9t1eOu47g9APQDYT0uM184Q0MB9CudHwkdgoe)CkWNwv9XKqlQ8u8V3bLitj2CnmXw5aW4x70SM5nCbGQLzP1pQtmq3O4HMcE6aeFw6atk4FHWs3O58OvcHyMGlQu9GGVuBTrLj(0QW3Csg9QM1)WkPwZOC6t1vHe9HUexeUNkHo633c7Ptut1Ii8cSjNGXGlA5Kgh1(QokAzdxa55TGe5lPbhbQgSBra2hTIsS1cv(l5Wr10TiH2ElNBLZB3hAouPTO3jOk8nSGdwAJ0YZer3QVQm4OVV)5UxS81SvBrt7qknkZVT9bTGlmu2yp6pSfkzvQNjxJmvjIEUGL2RKfrAPfcJcvqZ7CtYErv0Z5HWutQT3l(q0c1xm(qCG8LxG2PxVqY(hgjx1q2vZpNkP9mvwkKSVja8b6334qUI8nu7bCEGtxKF3re20bfejtViHtCoTlIJL0yP1BcZ0g)pwm3ku8ntc0gUrZUwku0Mp3giIDpZOL2CUJCEvZ0UrjSnG0(EXpxkMjwAFgCafJ)54Oun)YszM1gwTjyUfuC7hjeo9r79XaJkySHbdAxngGH6SFUzvjlxO22Ard0P3ZnSHbrP2b)zZTbYmKQprqbQUkrK2wXWe(n(BnEwfLak1qkaHn(WLiJsNgBJuOc0v51HvFrmPTM875vWq3ZWwzNBRR6Er0PSJbm809fqvyFSSHh)w8qSAPXRmlGAPy25ea1mKTTBdDdo)jSemAF9uUwcEAisaXmwkbZOkrxqusoWstgFrJSK7cNyHCDv04Bx0qTltiNELtGObflUjA6(6clmGySqP4jVj1wTlyaC9WY90JrCyRTRJeNLQ4sI4WV9dW1eAjo01d2rQd9QqatKrEo)XfDv1AcN86(IillqSqEMVgcWfEIKxNwGzvPNErFmuvYz8KnXxMZQYteRZKhZ7YoQSY5Y2hBOloB2PfKwDuWmBA)GPzGnnFA2nYM(iSjHZuxTWwxbtZ6qrJqBdwkuzcl0wns)oxQ2OrCb1qEcqGaEcBPmFZE16oS2bUq7ranZhJme)5wi21XD9PQ4hEV9Tvz61Uv4syYfTsd0MCXZz5IN7YfxM2RBH1ICr29PxZSuE5JPTzgAjtDxw86u2x2Cab5HWRHmCI0xQe0MXXaDgqYf2R(rjlimTQMTvwivKJCrzEKUcqHKl0BfNQ)Oyi9LlbOC08g2feLLws8mC2ctIfRSCtpCjLg2UKymzgYf38CvoRqVMyKwUqRRGDtPe33BsYO9cLfOJuI1DiXcACbhtQ52oHgj2hBT4VUDtleC7iTbogx0)otnw51VJ3)gh3xbRtjP2V3YDWqF3pBOuo8VSw69IVHmdf2GXwy2iQfGOYwrEv9SnPPY23n(rLBiVAh7YEYVhBZKazS4NTyMnpKvlOXMPWgHGp4i0coc(GIbd164PAL)kLvx1SEBFplFrMnHjJPxDWhfwi3EB7pnpnxCVpPD(I)LTxyleFfNsRhTm8TLVAxnykmKFF5RxSWr2cOqDHaQBTqRmUXNc2EjpY94JHAz5Jmi(dXoZPTEb1nwyjV7Y6VF(K2f8VHse3faC3CnZ0hGEqgoNyuIoamoU2X2on23YUGhy53ctmg3oTByJkTiYkTSXNcwB568j1ZZWpUmJu9UGDa83BztX0wXa9TBelcEBZG0YqxkYNHUw3M1hXfKT6tt7dnpJrc7kZbSXDKLpgUw6qmfq5Xi9GXg1QJAwbNqxKY1Q4gXyytEk9wg2d7SCh3mCuMr1hML4e0n9AiYHlQzeK5Ex68CjuYw1dh6yGAhXtB7LBiaXcco2f2QVQVE)vRMV75)wvqIgtb2wgl9D6QFLQPV)FAkH65BjxZce5fAmd6tsCTUrUIX3Q6RJmNZVgjwQBIeTY0WmRrVCJUau716h9In2YygUqyAsbXygewxhYfHB4p1win0Px1P1UJYvrhYT4eKru3umOYpI0lTdLgzhZgAOD3wM8f2w2unXs(dE(vAX1BRWRiJz2wD4zoIARfH3lyeq4bQPwrMAPiDiry)vkcpxcVJoSwkhBsr69djNt767GtLK2BxJnfRfGPzmq7HQBtrTuIGFTldsth1iYL)XwQ14OYWjqsWPMAeFfgp5oODu5ygqBKuzK0C13QDOtmAUto3UYt6Hl52XpTCgZStqbV5S02g4FAdBFyaGTh6rz8LF2ycdMbssA6YGv7YSSBugbcBj)4aYC0ZgHr4Mfr5fzHjbSIhJlHl)3S)V)]] )