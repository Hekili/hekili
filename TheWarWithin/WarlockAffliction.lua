-- WarlockAffliction.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 265 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local Glyphed = IsSpellKnownOrOverridesKnown

spec:RegisterResource( Enum.PowerType.SoulShards, {
    rampaging_demonic_soul = {
        resource = "soul_shards",
        aura = "rampaging_demonic_soul",
        set_bonus = "tww3_4pc",

        last = function()
            local app = state.buff.rampaging_demonic_soul.applied
            local t = state.query_time
            return app + floor((t - app) / 3) * 3
        end,

        interval = 3,
        value = 1,
    }
},
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
    abyss_walker                   = {  71954,  389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by $s1% for $s2 sec
    accrued_vitality               = {  71953,  386613, 2 }, -- Drain Life heals for $s1% of the amount drained over $s2 sec
    amplify_curse                  = {  71934,  328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within $s1 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional $s2%. Curse of Tongues Increases casting time by an additional $s3%. Curse of Weakness Enemy is unable to critically strike
    banish                         = {  71944,     710, 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for $s1 sec. Limit $s2. Casting Banish again on the target will cancel the effect
    burning_rush                   = {  71949,  111400, 1 }, -- Increases your movement speed by $s1%, but also damages you for $s2% of your maximum health every $s3 sec. Movement impairing effects may not reduce you below $s4% of normal movement speed. Lasts until canceled
    curses_of_enfeeblement         = {  71951,  386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by $s3% for $s4 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by $s7% for $s8 sec. Curses: A warlock can only have one Curse active per target
    dark_accord                    = {  71956,  386659, 1 }, -- Reduces the cooldown of Unending Resolve by $s1 sec
    dark_pact                      = {  71936,  108416, 1 }, -- Sacrifices $s1% of your current health to shield you for $s2% of the sacrificed health plus an additional $s3 for $s4 sec. Usable while suffering from control impairing effects
    darkfury                       = {  71941,  264874, 1 }, -- Reduces the cooldown of Shadowfury by $s1 sec and increases its radius by $s2 yards
    demon_skin                     = {  71952,  219272, 2 }, -- Your Soul Leech absorption now ly recharges at a rate of $s1% of maximum health every $s2 sec, and may now absorb up to $s3% of maximum health. Increases your armor by $s4%
    demonic_circle                 = { 100941,  268358, 1 }, -- Summons a Demonic Circle for $s1 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects
    demonic_embrace                = {  71930,  288843, 1 }, -- Stamina increased by $s1%
    demonic_fortitude              = {  71922,  386617, 1 }, -- Increases you and your pets' maximum health by $s1%
    demonic_gateway                = {  71955,  111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per $s1 sec
    demonic_inspiration            = {  71928,  386858, 1 }, -- Increases the attack speed of your primary pet by $s1%. Increases Grimoire of Sacrifice damage by $s2%
    demonic_resilience             = {  71917,  389590, 2 }, -- Reduces the chance you will be critically struck by $s2%$s$s3 All damage your primary demon takes is reduced by $s4%
    demonic_tactics                = {  71925,  452894, 1 }, -- Your spells have a $s1% increased chance to deal a critical strike. You gain $s2% more of the Critical Strike stat from all sources
    fel_armor                      = {  71950,  386124, 2 }, -- When Soul Leech absorbs damage, $s2% of damage taken is absorbed and spread out over $s3 sec$s$s4 Reduces damage taken by $s5%
    fel_domination                 = {  71931,  333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by $s1%
    fel_pact                       = {  71932,  386113, 1 }, -- Reduces the cooldown of Fel Domination by $s1 sec
    fel_synergy                    = {  71924,  389367, 2 }, -- Soul Leech also heals you for $s1% and your pet for $s2% of the absorption it grants
    fiendish_stride                = {  71948,  386110, 1 }, -- Reduces the damage dealt by Burning Rush by $s1%. Burning Rush increases your movement speed by an additional $s2%
    frequent_donor                 = {  71937,  386686, 1 }, -- Reduces the cooldown of Dark Pact by $s1 sec
    horrify                        = {  71916,   56244, 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear
    howl_of_terror                 = {  71947,    5484, 1 }, -- Let loose a terrifying howl, causing $s1 enemies within $s2 yds to flee in fear, disorienting them for $s3 sec. Damage may cancel the effect
    ichor_of_devils                = {  71937,  386664, 1 }, -- Dark Pact sacrifices only $s1% of your current health for the same shield value
    lifeblood                      = {  71940,  386646, 2 }, -- When you use a Healthstone, gain $s1% Leech for $s2 sec
    mortal_coil                    = {  71947,    6789, 1 }, -- Horrifies an enemy target into fleeing, incapacitating for $s1 sec and healing you for $s2% of maximum health
    nightmare                      = {  71916,  386648, 1 }, -- Increases the amount of damage required to break your fear effects by $s1%
    pact_of_gluttony               = {  71926,  386689, 1 }, -- Healthstones you conjure for yourself are now Demonic Healthstones and can be used multiple times in combat. Demonic Healthstones cannot be traded.  Demonic Healthstone Instantly restores $s3% health. $s4 sec cooldown
    resolute_barrier               = {  71915,  389359, 2 }, -- Attacks received that deal at least $s1% of your health decrease Unending Resolve's cooldown by $s2 sec. Cannot occur more than once every $s3 sec
    sargerei_technique             = {  93179,  405955, 2 }, -- Shadow Bolt and Drain Soul damage increased by $s1%
    shadowflame                    = {  71941,  384069, 1 }, -- Slows enemies in a $s1 yard cone in front of you by $s2% for $s3 sec
    shadowfury                     = {  71942,   30283, 1 }, -- Stuns all enemies within $s1 yds for $s2 sec
    socrethars_guile               = {  93178,  405936, 2 }, -- Agony damage increased by $s1%
    soul_conduit                   = {  71939,  215941, 1 }, -- Every Soul Shard you spend has a $s1% chance to be refunded
    soul_leech                     = {  71933,  108370, 1 }, -- All single-target damage done by you and your minions grants you and your pet shadowy shields that absorb $s1% of the damage dealt, up to $s2% of maximum health
    soul_link                      = {  71923,  108415, 2 }, -- $s1% of all damage you take is taken by your demon pet instead. While Grimoire of Sacrifice is active, your Stamina is increased by $s2%
    soulburn                       = {  71957,  385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by $s1% and makes you immune to snares and roots for $s2 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for $s3 sec. This shield cannot exceed $s4% of your maximum health. Health Funnel: Restores $s5% more health and reduces the damage taken by your pet by $s6% for $s7 sec. Healthstone: Increases the healing of your Healthstone by $s8% and increases your maximum health by $s9% for $s10 sec
    strength_of_will               = {  71956,  317138, 1 }, -- Unending Resolve reduces damage taken by an additional $s1%
    sweet_souls                    = {  71927,  386620, 1 }, -- Your Healthstone heals you for an additional $s1% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount
    swift_artifice                 = {  71918,  452902, 1 }, -- Reduces the cast time of Soulstone and Create Healthstone by $s1%
    teachings_of_the_black_harvest = {  71938,  385881, 1 }, -- Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target $s1% damage reduction for $s2 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by $s3 sec. Felhunter: Reduces the cooldown of Devour Magic by $s4 sec. Sayaad: Reduces the cooldown of Seduction by $s5 sec and causes the target to walk faster towards the demon
    teachings_of_the_satyr         = {  71935,  387972, 1 }, -- Reduces the cooldown of Amplify Curse by $s1 sec
    wrathful_minion                = {  71946,  386864, 1 }, -- Increases the damage done by your primary pet by $s1%. Increases Grimoire of Sacrifice damage by $s2%

    -- Affliction
    absolute_corruption            = {  72051,  196103, 1 }, -- Corruption is now permanent and deals $s1% increased damage. Duration reduced to $s2 sec against players
    contagion                      = {  72041,  453096, 2 }, -- Increases critical strike damage dealt by Agony, Corruption, and Unstable Affliction by $s1%
    creeping_death                 = {  72058,  264000, 1 }, -- Your Agony, Corruption, and Unstable Affliction deal damage $s1% faster
    cull_the_weak                  = {  72038,  453056, 2 }, -- Malefic Rapture damage is increased by $s1% for each enemy it hits, up to $s2 enemies
    cunning_cruelty                = {  72054,  453172, 1 }, -- Shadow Bolt and Drain Soul have a chance to trigger a Shadow Bolt Volley, dealing $s$s2 Shadow damage to $s3 enemies within $s4 yards of your current target
    dark_harvest                   = { 102029,  387016, 1 }, -- Each target affected by Soul Rot increases your haste and critical strike chance by $s1% for $s2 sec
    dark_virtuosity                = {  72043,  405327, 2 }, -- Shadow Bolt and Drain Soul deal an additional $s1% damage
    deaths_embrace                 = {  72033,  453189, 1 }, -- Increases Drain Life healing by $s1% while your health is at or below $s2% health. Damage done by your Agony, Corruption, Unstable Affliction, and Malefic Rapture is increased by $s3% when your target is at or below $s4% health
    drain_soul                     = {  72045,  388667, 1 }, -- Replaces Shadow Bolt. Drains the target's soul, causing $s$s2 Shadow damage over $s3 sec. Damage is increased by $s4% against enemies below $s5% health. Generates $s6 Soul Shard if the target dies during this effect
    focused_malignancy             = {  72042,  399668, 1 }, -- Malefic Rapture deals $s1% increased damage to targets suffering from Unstable Affliction
    grimoire_of_sacrifice          = {  72037,  108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal $s1 additional Shadow damage. Lasts until canceled or until you summon a demon pet
    haunt                          = {  72032,   48181, 1 }, -- A ghostly soul haunts the target, dealing $s$s2 Shadow damage and increasing your damage dealt to the target by $s3% for $s4 sec. If the target dies, Haunt's cooldown is reset
    improved_haunt                 = { 102031,  458034, 1 }, -- Increases the damage of Haunt by $s1% and reduces its cast time by $s2%. Haunt now applies Shadow Embrace
    improved_malefic_rapture       = {  72035,  454378, 1 }, -- Increases Malefic Rapture damage by $s1% and reduces its cast time by $s2%
    improved_shadow_bolt           = {  72045,  453080, 1 }, -- Reduces the cast time of Shadow Bolt by $s1% and increases its damage by $s2%
    infirmity                      = { 102032,  458036, 1 }, -- The stack count of Agony is increased by $s2 when applied by Vile Taint$s$s3 Enemies damaged by Phantom Singularity take $s4% increased damage from you for its duration
    kindled_malice                 = {  72040,  405330, 2 }, -- Malefic Rapture damage increased by $s2%$s$s3 Corruption damage increased by $s4%
    malediction                    = {  72046,  453087, 2 }, -- Increases the critical strike chance of Agony, Corruption, and Unstable Affliction by $s1%
    malefic_touch                  = { 102030,  458029, 1 }, -- Malefic Rapture deals an additional $s$s2 Shadowflame damage to each target it affects
    malevolent_visionary           = {  71987,  387273, 1 }, -- Increases the damage of your Darkglare by $s2%. When Darkglare extends damage over time effects it also sears affected targets for $s$s3 Shadow damage
    malign_omen                    = {  72057,  458041, 1 }, -- Casting Soul Rot grants $s1 applications of Malign Omen.  Malign Omen Your next Malefic Rapture deals $s4% increased damage and extends the duration of your damage over time effects and Haunt by $s5 sec
    nightfall                      = {  72047,  108558, 1 }, -- Corruption damage has a chance to cause your next Shadow Bolt or Drain Soul to deal $s1% increased damage. Shadow Bolt is instant cast and Drain Soul channels $s2% faster when affected
    oblivion                       = {  71986,  417537, 1 }, -- Unleash wicked magic upon your target's soul, dealing $s$s2 Shadow damage over $s3 sec. Deals $s4% increased damage, up to $s5%, per damage over time effect you have active on the target
    perpetual_unstability          = { 102246,  459376, 1 }, -- The cast time of Unstable Affliction is reduced by $s2%. Refreshing Unstable Affliction with $s3 or less seconds remaining deals $s$s4 Shadow damage to its target
    phantom_singularity            = { 102033,  205179, 1 }, -- Places a phantom singularity above the target, which consumes the life of all enemies within $s1 yards, dealing $s2 damage over $s3 sec, healing you for $s4% of the damage done
    ravenous_afflictions           = { 102247,  459440, 1 }, -- Critical strikes from your Agony, Corruption, and Unstable Affliction have a chance to grant Nightfall
    relinquished                   = {  72052,  453083, 1 }, -- Agony has $s1 times the normal chance to generate a Soul Shard
    sacrolashs_dark_strike         = {  72053,  386986, 1 }, -- Corruption damage is increased by $s1%, and each time it deals damage any of your Curses active on the target are extended by $s2 sec
    seed_of_corruption             = {  72050,   27243, 1 }, -- Embeds a demon seed in the enemy target that will explode after $s2 sec, dealing $s$s3 Shadow damage to all enemies within $s4 yards and applying Corruption to them. The seed will detonate early if the target is hit by other detonations, or takes $s5 damage from your spells
    shadow_embrace                 = { 100940,   32388, 1 }, -- Shadow Bolt applies Shadow Embrace, increasing your damage dealt to the target by $s1% for $s2 sec. Stacks up to $s3 times
    siphon_life                    = {  72051,  452999, 1 }, -- Corruption deals $s1% increased damage and its periodic damage heals you for $s2% of the damage dealt
    soul_rot                       = {  72056,  386997, 1 }, -- Wither away all life force of your current target and up to $s3 additional targets nearby, causing your primary target to suffer $s$s4 Shadow damage and secondary targets to suffer $s$s5 Shadow damage over $s6 sec. Damage dealt by Soul Rot heals you for $s7% of damage done
    summon_darkglare               = {  72034,  205180, 1 }, -- Summons a Darkglare from the Twisting Nether that extends the duration of your damage over time effects on all enemies by $s2 sec. The Darkglare will serve you for $s3 sec, blasting its target for $s$s4 Shadow damage, increased by $s5% for every damage over time effect you have active on their current target
    summoners_embrace              = {  72037,  453105, 1 }, -- Increases the damage dealt by your spells and your demon by $s1%
    tormented_crescendo            = {  72031,  387075, 1 }, -- While Agony, Corruption, and Unstable Affliction are active, your Shadow Bolt has a $s1% chance and your Drain Soul has a $s2% chance to make your next Malefic Rapture cost no Soul Shards and cast instantly
    unstable_affliction            = {  72049,  316099, 1 }, -- Afflicts one target with $s$s3 Shadow damage over $s4 sec. If dispelled, deals $s$s5 million damage to the dispeller and silences them for $s6 sec. Generates $s7 Soul Shard if the target dies while afflicted
    vile_taint                     = { 102033,  278350, 1 }, -- Unleashes a vile explosion at the target location, dealing $s$s2 Shadow damage over $s3 sec to $s4 enemies within $s5 yds and applies Agony and Curse of Exhaustion to them
    volatile_agony                 = {  72039,  453034, 1 }, -- Refreshing Agony with $s2 or less seconds remaining deals $s$s3 Shadow damage to its target and enemies within $s4 yards. Deals reduced damage beyond $s5 targets
    withering_bolt                 = {  72055,  386976, 1 }, -- Shadow Bolt and Drain Soul deal $s1% increased damage, up to $s2%, per damage over time effect you have active on the target
    writhe_in_agony                = {  72048,  196102, 1 }, -- Agony's damage starts at $s1 stacks and may now ramp up to $s2 stacks
    xavius_gambit                  = {  71921,  416615, 1 }, -- Unstable Affliction deals $s1% increased damage

    -- Hellcaller
    aura_of_enfeeblement           = {  94822,  440059, 1 }, -- While Unending Resolve is active, enemies within $s1 yds are affected by Curse of Tongues and Curse of Weakness at $s2% effectiveness
    blackened_soul                 = {  94837,  440043, 1 }, -- Spending Soul Shards on damaging spells will further corrupt enemies affected by your Wither, increasing its stack count by $s2. Each time Wither gains a stack it has a chance to collapse, consuming a stack every $s3 sec to deal $s$s4 Shadowflame damage to its host until $s5 stack remains
    bleakheart_tactics             = {  94854,  440051, 1 }, -- Wither damage increased $s1%. When Wither gains a stack from Blackened Soul, it has a chance to gain an additional stack
    curse_of_the_satyr             = {  94822,  440057, 1 }, -- Curse of Weakness is empowered and transforms into Curse of the Satyr.  Curse of the Satyr Increases the time between an enemy's attacks by $s3% and the casting time of all spells by $s4% for $s5 min. Curses: A warlock can only have one Curse active per target
    hatefury_rituals               = {  94854,  440048, 1 }, -- Wither deals $s1% increased periodic damage but its duration is $s2% shorter
    illhoofs_design                = {  94835,  440070, 1 }, -- Sacrifice $s1% of your maximum health. Soul Leech now absorbs an additional $s2% of your maximum health
    malevolence                    = {  94842,  442726, 1 }, -- Dark magic erupts from you and corrupts your soul for $s2 sec, causing enemies suffering from your Wither to take $s$s3 Shadowflame damage and increase its stack count by $s4. While corrupted your Haste is increased by $s5% and spending Soul Shards on damaging spells grants $s6 additional stack of Wither
    mark_of_perotharn              = {  94844,  440045, 1 }, -- Critical strike damage dealt by Wither is increased by $s1%. Wither has a chance to gain a stack when it critically strikes. Stacks gained this way do not activate Blackened Soul
    mark_of_xavius                 = {  94834,  440046, 1 }, -- Agony damage increased by $s1%. Blackened Soul deals $s2% increased damage per stack of Wither
    seeds_of_their_demise          = {  94829,  440055, 1 }, -- After Wither reaches $s2 stacks or when its host reaches $s3% health, Wither deals $s$s4 Shadowflame damage to its host every $s5 sec until $s6 stack remains. When Blackened Soul deals damage, you have a chance to gain Tormented Crescendo
    wither                         = {  94840,  445468, 1 }, -- Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing $s$s3 Shadowflame damage immediately and an additional $s$s4 Shadowflame damage over $s5 sec. Replaces Corruption
    xalans_cruelty                 = {  94845,  440040, 1 }, -- Shadow damage dealt by your spells and abilities is increased by $s1% and your Shadow spells gain $s2% more critical strike chance from all sources
    xalans_ferocity                = {  94853,  440044, 1 }, -- Fire damage dealt by your spells and abilities is increased by $s1% and your Fire spells gain $s2% more critical strike chance from all sources
    zevrims_resilience             = {  94835,  440065, 1 }, -- Dark Pact heals you for $s1 every $s2 sec while active

    -- Soul Harvester
    demoniacs_fervor               = {  94832,  449629, 1 }, -- Your demonic soul deals $s1% increased damage to targets affected by your Unstable Affliction
    demonic_soul                   = {  94851,  449614, 1 }, -- A demonic entity now inhabits your soul, allowing you to detect if a Soul Shard has a Succulent Soul when it's generated. A Succulent Soul empowers your next Malefic Rapture, increasing its damage by $s2%, and unleashing your demonic soul to deal an additional $s$s3 Shadow damage
    eternal_servitude              = {  94824,  449707, 1 }, -- Fel Domination cooldown is reduced by $s1 sec
    feast_of_souls                 = {  94823,  449706, 1 }, -- When you kill a target, you have a chance to generate a Soul Shard that is guaranteed to be a Succulent Soul
    friends_in_dark_places         = {  94850,  449703, 1 }, -- Dark Pact now shields you for an additional $s1% of the sacrificed health
    gorebound_fortitude            = {  94850,  449701, 1 }, -- You always gain the benefit of Soulburn when consuming a Healthstone, increasing its healing by $s1% and increasing your maximum health by $s2% for $s3 sec
    gorefiends_resolve             = {  94824,  389623, 1 }, -- Targets resurrected with Soulstone resurrect with $s1% additional health and $s2% additional mana
    necrolyte_teachings            = {  94825,  449620, 1 }, -- Shadow Bolt and Drain Soul damage increased by $s1%. Nightfall increases the damage of Shadow Bolt and Drain Soul by an additional $s2%
    quietus                        = {  94846,  449634, 1 }, -- Soul Anathema damage increased by $s1% and is dealt $s2% faster. Consuming Nightfall activates Shared Fate or Feast of Souls
    sataiels_volition              = {  94838,  449637, 1 }, -- Corruption deals damage $s1% faster and Haunt grants Nightfall
    shadow_of_death                = {  94857,  449638, 1 }, -- Your Soul Rot spell is empowered by the demonic entity within you, causing it to grant $s1 Soul Shards that each contain a Succulent Soul
    shared_fate                    = {  94823,  449704, 1 }, -- When you kill a target, its tortured soul is flung into a nearby enemy for $s2 sec. This effect inflicts $s$s3 Shadow damage to enemies within $s4 yds every $s5 sec. Deals reduced damage beyond $s6 targets
    soul_anathema                  = {  94847,  449624, 1 }, -- Unleashing your demonic soul bestows a fiendish entity unto the soul of its targets, dealing $s$s2 Shadow damage over $s3 sec. If this effect is reapplied, any remaining damage will be added to the new Soul Anathema
    wicked_reaping                 = {  94821,  449631, 1 }, -- Damage dealt by your demonic soul is increased by $s2%. Consuming Nightfall feeds the demonic entity within you, causing it to appear and deal $s$s3 Shadow damage to your target
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bloodstones                    = 5695, -- (1218692) Your Healthstones are replaced with Bloodstones which increase their user's haste by $s1% for $s2 sec instead of healing
    bonds_of_fel                   = 5546, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the $s2 yd radius they explode, dealing $s$s3 Fire damage split amongst all nearby enemies
    essence_drain                  =   19, -- (221711) Whenever you heal yourself with Drain Life, the enemy target deals $s1% reduced damage to you for $s2 sec. Stacks up to $s3 times
    gateway_mastery                =   15, -- (248855) Increases the range of your Demonic Gateway by $s1 yards, and reduces the cast time by $s2%. Reduces the time between how often players can take your Demonic Gateway by $s3 sec
    impish_instincts               = 5579, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by $s1 sec. Cannot occur more than once every $s2 sec
    jinx                           = 5386, -- (426352) Casting a curse now applies Corruption and Agony to your target, but curses now costs $s1 Soul Shard
    nether_ward                    =   18, -- (212295) Surrounds the caster with a shield that lasts $s1 sec, reflecting all harmful spells cast on you
    rampant_afflictions            = 5379, -- (335052) Unstable Affliction can now be applied to up to $s1 targets, but its damage is reduced by $s2%
    rot_and_decay                  =   16, -- (212371) Shadow Bolt damage increases the duration of your Unstable Affliction, Corruption, Agony, and Siphon Life on the target by $s1 sec. Drain Life, Drain Soul, and Oblivion damage increases the duration of your Unstable Affliction, Corruption, Agony, and Siphon Life on the target by $s2 sec
    shadow_rift                    = 5392, -- (353294) Conjure a Shadow Rift at the target location lasting $s1 sec. Enemy players within the rift when it expires are teleported to your Demonic Circle. Must be within $s2 yds of your Demonic Circle to cast
    soul_rip                       = 5608, -- (410598) Fracture the soul of up to $s1 target players within $s2 yds into the shadows, reducing their damage done by $s3% and healing received by $s4% for $s5 sec. Souls are fractured up to $s6 yds from the player's location. Players can retrieve their souls to remove this effect
    soul_swap                      = 5662, -- (386951) Copies your damage over time effects and Haunt from the target, preserving their duration. Your next use of Soul Swap within $s1 sec will exhale a copy damage of the effects onto a new target
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
        duration = 18,
        tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
        type = "Magic",
        max_stack = function () return 14 + 4 * talent.writhe_in_agony.rank end,
        meta = {
            stack = function( t )
                if t.down then return 0 end
                if t.count >= 10 then return t.count end

                local app = t.applied
                local tick = t.tick_time

                local last_real_tick = now + ( floor( ( now - app ) / tick ) * tick )
                local ticks_since = floor( ( query_time - last_real_tick ) / tick )

                return min( talent.writhe_in_agony.enabled and 18 or 14, t.count + ticks_since )
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
        duration = function () return talent.absolute_corruption.enabled and ( target.is_player and 24 or 3600 ) or 14 end,
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
        max_stack = 5
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
        max_stack = 2
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
        duration = function() return 12 * haste end,
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
    soul_swap = {
        id = 399680,
        duration = 10,
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
        max_stack = 3
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
        max_stack = 3
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
        duration = 21,
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
    -- https://wowhead.com/beta/spell=386931
    vile_taint = {
        id = 386931,
        duration = 10,
        tick_time = 2,
        type = "Magic",
        max_stack = 1,
        copy = "vile_taint_dot"
    },
    -- Suffering $w1 Shadowflame damage every $t1 sec.$?a339892[ ; Damage taken by Chaos Bolt and Incinerate increased by $w2%.][]
    wither = {
        id = 445474,
        duration = function() return talent.absolute_corruption.enabled and ( target.is_player and 24 or 3600 ) or ( 18.0 * ( 1 - 0.15 * talent.hatefury_rituals.rank ) ) end,
        tick_time = function() return 2.0 * ( 1 - 0.15 * talent.creeping_death.rank ) * ( 1 - 0.25 * talent.sataiels_volition.rank) end,
        pandemic = true,
        max_stack = 8 -- ??
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

spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if talent.blackened_soul.enabled and debuff.wither.up and ability and ability.spend and ability.spendType == "soul_shards" then
        -- We need to do this here, because it works even if you spend 0 due to a discount proc
        applyDebuff( "target", "wither", debuff.wither.remains, debuff.wither.stack + ( buff.malevolence.up and 2 or 1 ) )
    end

end )

spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )

spec:RegisterStateExpr( "time_to_shard", function ()
    local num_agony = active_dot.agony
    if num_agony == 0 then return 3600 end

    return 1 / ( 0.16 / sqrt( num_agony ) * ( num_agony == 1 and 1.15 or 1 ) * num_agony / debuff.agony.tick_time )
end )

local corruption = spec.auras.corruption.id

local applyEvent = {
    SPELL_AURA_APPLIED = 1,
    SPELL_AURA_APPLIED_DOSE = 1,
    SPELL_AURA_REFRESH = 1
}

local corruptionTargets = {}

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
    if sourceGUID ~= GUID then return end
    if spellID == corruption and applyEvent[ subtype ] then
        corruptionTargets[ destGUID ] = GetTime()
    end
end, false )

spec:RegisterHook( "combatExit", function()
    wipe( corruptionTargets )
end )

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237700, 237698, 237703, 237701, 237699 },
        auras = {
            -- Soul Harvester
            rampaging_demonic_soul = {
                id = 1239689,
                duration = 9,
                max_stack = 1
            },
            -- Hellcaller
            maintained_withering = {
                id = 1239577,
                duration = 8,
                max_stack = 1
            }
        }
    },
    tww2 = {
        items = { 229325, 229323, 229328, 229326, 229324 },
        auras = {
            jackpot = {
                id = 1219034,
                duration = 12,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207270, 207271, 207272, 207273, 207275, 217212, 217214, 217215, 217211, 217213 },
        auras = {
            umbrafire_kindling = {
                id = 423765,
                duration = 20,
                max_stack = 3
            }
        }
    },
    tier30 = {
        items = { 202534, 202533, 202532, 202536, 202531 },
        auras = {
            infirmity = {
                id = 409765,
                duration = 16,
                max_stack = 1
            }
        }
    },
    tier29 = {
        items = { 200336, 200338, 200333, 200335, 200337 },
        auras = {
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
        }
    },
    tier28 = {
        items = { 188884, 188887, 188888, 188889, 188890 },
        bonuses = {
            tier28_2pc = 364437,
            tier28_4pc = 363953
        },
        auras = {
            calamitous_crescendo = {
                id = 364322,
                duration = 10,
                max_stack = 1
            }
        }
    },
    -- Legacy
    tier21 = { items = { 152174, 152177, 152172, 152176, 152173, 152175 } },
    tier20 = { items = { 147183, 147186, 147181, 147185, 147182, 147184 } },
    tier19 = { items = { 138314, 138323, 138373, 138320, 138311, 138317 } },
    class =  { items = { 139765, 139768, 139767, 139770, 139764, 139769, 139766, 139763 } },
    amanthuls_vision = { items = { 154172 } },
    hood_of_eternal_disdain = { items = { 132394 } },
    norgannons_foresight = { items = { 132455 } },
    pillars_of_the_dark_portal = { items = { 132357 } },
    power_cord_of_lethtendris = { items = { 132457 } },
    reap_and_sow = { items = { 144364 } },
    sacrolashs_dark_strike = { items = { 132378 } },
    soul_of_the_netherlord = { items = { 151649 } },
    stretens_sleepless_shackles = { items = { 132381 } },
    the_master_harvester = { items = { 151821 } }
} )

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


    if debuff.corruption.down and corruptionTargets[ target.guid ] then
        local corruptionExpires = corruptionTargets[ target.guid ] + spec.auras.corruption.duration

        if expires > state.now then
            debuff.corruption.expires = corruptionExpires
            debuff.corruption.duration = spec.auras.corruption.duration
            debuff.corruption.applied = corruptionTargets[ target.guid ]
            debuff.corruption.count = 1
            debuff.corruption.caster = "player"

            Hekili:Error( "WARNING: Corruption applied virtually due to aura missing from target." )
            if Hekili.ActiveDebug then Hekili:Debug( "WARNING: Corruption applied virtrually due to aura missing from target." ) end
        end
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
        local summon_demon = GetSpellInfo( 180284 )
        SUMMON_DEMON_TEXT = summon_demon and summon_demon.name or "Summon Demon"
        class.abilityList.summon_pet = "|T136082:0|t |cff00ccff[" .. SUMMON_DEMON_TEXT .. "]|r"
    end

    class.abilities.summon_pet = class.abilities[ settings.default_pet or "summon_sayaad" ]
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

            if debuff.agony.up then applyDebuff( "target", "agony", nil, min( debuff.agony.max_stack, debuff.agony.stack + 1 ) )
            else applyDebuff( "target", "agony", nil, max( 4 * talent.writhe_in_agony.rank, 1 ) )
            end
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
        notalent = function() return state.spec.affliction and talent.wither.enabled and "wither" or nil end,

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "corruption" )
        end,

        bind  = "wither"
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

        spend = 0.03,
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
            removeStack( "nightfall" )

            if talent.shadow_embrace.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
        end,

        tick = function ()
            if not settings.manage_ds_ticks or not talent.shadow_embrace.enabled then return end
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
            if talent.improved_haunt.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
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

    -- Talent: Your damaging periodic effects from your spells erupt on all targets, causing $324540s1 Shadow damage per effect.
    malefic_rapture = {
        id = 324536,
        cast = function ()
            if buff.tormented_crescendo.up or buff.calamitous_crescendo.up then return 0 end
            return 1.5 * ( 1 - 0.1 * talent.improved_malefic_rapture.rank ) * haste
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
            if buff.tormented_crescendo.up then removeStack( "tormented_crescendo" ) end

            if buff.malign_omen.up or buff.umbrafire_kindling.up then
                removeStack( "umbrafire_kindling" )
                removeStack( "malign_omen" )
                if dot.agony.up               then dot.agony.expires               = dot.agony.expires               + 2 end
                if dot.corruption.up          then dot.corruption.expires          = dot.corruption.expires          + 2 end
                if dot.unstable_affliction.up then dot.unstable_affliction.expires = dot.unstable_affliction.expires + 2 end
                if dot.vile_taint.up          then dot.vile_taint.expires          = dot.vile_taint.expires          + 2 end
                if dot.phantom_singularity.up then dot.phantom_singularity.expires = dot.phantom_singularity.expires + 2 end
                if dot.siphon_life.up         then dot.siphon_life.expires         = dot.siphon_life.expires         + 2 end
            end

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
            if debuff.wither.up then applyDebuff( "target", "wither", debuff.wither.remains, debuff.wither.stack + 6 + ( set_bonus.tww3 >= 2 and 2 or 0 ) ) end
            applyBuff( "malevolence" )
            if set_bonus.tww3 >= 4 then
                addStack( "tormented_crescendo", 2 )
                applyBuff( "maintained_withering" )
            end
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
        toggle = "essences",

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
        nodebuff = function() if active_enemies == 1 then return "seed_of_corruption" end end,
        velocity = 30,

        handler = function()
            removeStack( "cruel_epiphany" )
            removeStack( "umbrafire_kindling" )
        end,

        impact = function ()

            if debuff.seed_of_corruption.up then
                active_dot.seed_of_corruption = min( active_enemies, active_dot.seed_of_corruption + 1 )
            else
                applyDebuff( "target", "seed_of_corruption" )
            end
        end
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
            removeStack( "nightfall" )
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
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = 0.005,
        spendType = "mana",

        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "soul_rot" )
            active_dot.soul_rot = min( 5, active_enemies )
            if talent.dark_harvest.enabled then applyBuff( "dark_harvest", nil, active_dot.soul_rot ) end
            if talent.malign_omen.enabled then addStack( "malign_omen", nil, 3 ) end
            if legendary.decaying_soul_satchel.enabled then applyBuff( "decaying_soul_satchel", nil, active_dot.soul_rot ) end
            if talent.shadow_of_death.enabled then
                addStack( "succulent_soul", nil, 3 )
                gain( 3, "soul_shards" )
                if set_bonus.tww3 >= 2 then
                    applyBuff( "rampaging_demonic_soul" )
                end
            end
        end,

        copy = { 386997, 325640 }
    },

    soul_swap = {

        id = 386951,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        texture = 460857,

        spend = 1,
        spendType = "soul_shards",
        pvptalent = "soul_swap",

        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "soul_swap" )
        end,
        copy = { 386951, 399685 }
    },

    soul_swap_exhale = {

        id = 399685,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        texture = 132291,

        spend = 1,
        spendType = "soul_shards",
        buff = "soul_swap",
        pvptalent = "soul_swap",

        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "soul_swap" )
        end,
        copy = { 386951, 399685 }
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
            if set_bonus.tww2 >= 2 then applyBuff( "jackpot" ) end
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
        cast = function() return 1.5 * ( 1 - 0.2 * talent.perpetual_unstability.rank ) * haste end,
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

            if buff.jackpot.up then active_dot.unstable_affliction = min( active_enemies, active_dot.unstable_affliction +3 ) end
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
            active_dot.vile_taint = min( active_enemies, active_dot.vile_taint + 7 )
            applyDebuff( "target", "agony", nil, 4 * ( talent.writhe_in_agony.rank + talent.infirmity.rank ) )
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

        bind = function() return state.spec.affliction and "corruption" or "immolate" end,
    }
} )

spec:RegisterSetting( "default_pet", "summon_sayaad", {
    name = "|T136082:0|t Preferred Demon",
    desc = "Specify which demon should be summoned if you have no active pet.",
    type = "select",
    values = function()
        return {
            summon_sayaad = class.abilityList.summon_sayaad,
            summon_imp = class.abilityList.summon_imp,
            summon_felhunter = class.abilityList.summon_felhunter,
            summon_voidwalker = class.abilityList.summon_voidwalker,
        }
    end,
    width = "full"
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

    potion = "tempered_potion",

    package = "Affliction",
} )

spec:RegisterPack( "Affliction", 20250813, [[Hekili:T3ZAVnUrs(BX4q0izpJgrARjo7z5GSZHfibzZUaklUpC4efTeLnXqrQJKYogWq)2V(bF0pQQ7M6HhNblqYyBXMvxV66vxDRzEZ(9ztxgwgn738h5pE01ExoC03F11EFA20YN3enB6MWfFj8EYVKgUM8V)0QvjXlkJZsPp65KSWLuquKTnFb5XpuwUP4V8XpEFC5dBVB4IS1FSiE92Kq6BSipCvj9Vx8XztVBBCs5pNo7oO5)YlVIaZnrliF8NgtaB8YLr8XgvSy20p8HDZ)9hI2n))omN8pKjloD38PrHfzKFE5UFHcSpm66p45)x2n)NtJlJdt2n)N(N)6U59Jg)d)W4R8hS7x29lMbKFnGi)3NiaA6ZPl2n)jYOi)E86px)4lj)hWJjCO8SvXje(Y)X)XU5UYBUlj7Upw(q0tH5pXqOp(tmg()mpolpU85FnUOS4JlJwfUnP8JKrLKT4lbHncMHuOS7xOt50g4)zk83n)ZzRxhxYrvcgxXk4d()IigiFwlRJYGczGSy4M8iccFxy5KvrjblZwhNYG77JxnPmED0TJ6D2MOYHHjXpgb8Axm5JfBxVolnGmk4N)yyEC4DjrVNQPnzrsu4JrbHBsE)JHjBJMuMD)9jrdxTnnnkHGX7M)VkIwUBEz2U5feyo)3ZJt)c9xOIWIKmYV5TBEyXU5)1TRw18CYFVkJiSlPI9WTLzRjecrULKDp5hoGzLC4e4fChbUf1Oh)th6n8HWIGTfrSN(YlTFECbf5FiJ(SKO0cd0qHir4FkjcFqIWhHi8HjIFQfb(vgcWrovmMssncPPvcOoGREbfe123NTzcHxfVQcN94)mikPiAYOHJF)IS0LXuyoPgmdvez963kvwKLLSm7P0Hl3MZ0O)UVR5Jiw1scYZkBE2KrV8c(t)UVZayNmAWbYR87cVY)G5v(Q8k)tdVcaS18QPmwrizHaXvq8kkZsMdvReXwaTkljj7jY4tRS0NeNsxDKswGLsh3bVyXlyDy62WeTL8KvffBEEDyrzuErWtr3PSUp8UO88W0YacHKKqe43h1fc0)1Ia9HjqFteOVjc8Vr1T)hPm7CI0wMOjAUht6hTLoQOvRIwqh0ZzB3nFzwkzupfs)xktGnekRHtkDH68cI(JfjBxgbj)Y3E3Zbp9quYMGcY)Myf9Ben2q)3DSWFFe83hf)56xm1I61wemDLGPfpoYCWAoClRb1ZIghMej0IHHPphSCtrZ68l6J7D8CVXduEEr89PKPkBvabDd2qdh65Z9LSvyIu9psKQVrs13gPQ7dvMu9TsQ6Uqy6tHunlkf7lOZQ4xPdK5MQWnv9H4l6dXtWdYzOUBX8T8Yl4EDm62b51AKjdoVV3fe)BN3ceAan0XmmoTKS8GSeLmia4qDBoyWT9ngIacLIp)Eoo)EvZpSG6(841zX5ru9IIWf5upgrSiWdj6rLdbF(WOu6uSejO8OOL0HVilpF7gM(mbE0rsc(oknADCuXT(V8IYN41RAkxgrIPpEra1bp8m8q4wITV2ujOtk1jranTfXpDri5d5)zqcjhhU6ynlQW(qZUFXs7JkUmATdalkLXxwfF)dLVVGiFwus02j8M7Yk4r9(7petS4qyc5ptwbs(vUVZeYFvs8fwqs8IgBpZ98tXelYZxgt8nq8OSkpBnXI1p)3)873n)UTL0xLOwq()AtyfeuGmUTPm0IKuv5ZdTJZ8CM0fGt0fG(TlkBZ0Y(meMba(B9fFXW7ZsFMoO(NvPJ8ijf4ak1vkery7hompIs(f9Q(5nggZf85r8je7ELb0uqhqcvLpHH3vKLSTmsqRUb4x(YlN5WWgdf8AZdBg21d6X0qcQ(GBxsggJd0GXJfzoSfdcRyfx(0JzEiLcUveM)WIYWfF5g)pqwm9yar1MyezzobK8b3vU7ar0yBkb4ezVqvdysSk5kLiagcnIEIxNVeNE)xjEDdrlY3E5fyg3lViW5ymEeomKmeG8TirnXqwgXMz2yh6i3b8DSWQaFhr(MRklQCea4kZgObbhLlYh4FsVZ6xTKv3tdXvyaH5sMOgZtuwV(aVD0GEhxfjDbohDHjozNJhBkQIr1)utHcOjiv2ACH5MtEPY2n96dT6rDCRd)Ja2d0wvwJBr)r0ck1rnzFo2B3AFPwnInYYS81KpKWnxKhvSG4JoJGzeRsywtHEb(QEVb9q5K9yFqXdH5ljm1oV4rkuNhcjdl4USKY3cCvlmf0h3acCM2ThiNcoGdsks0HwscInDrK44BbNuWg1OLHfk36dwAQAw5erE5fu3heQ)LxKwqDd6RpONwia96dV87Lx0n8WFDdEFezbBEimLKkyqbXJ82Kqw2ADKxCGu7fx)AsV1ZoLiBcF9rsQQfbB3inq(wnSmm)l3t4lrsVWILuJY0xPvHTAzA067YdxerquUdp5pEyyzqZcbzL31eW8ygbulISIC0XssmlipCt5woU1V1GZTxvTghDv6e7RsnyB7wd28DiOuct7WTHugMFpjP4hIctkFy4MfL34pYchcc1e5A(g4AeCgNDG(wvd48QLeibrjGcE9myQ7wVrcqi7UK4hjeRWcZ6ps4fKGUFp0HEJ3ijLX6Nt5BN2fNGbCkRHbPTdSu8Lx6dgAF1hcyPBqpTvzndVkObTb07mw4y4U7V9YxnPKJk5NbeYqhDZQIKgvuDanHscd3QqtmogwKDZeCpmEJUq0f1GoeYQHaXKvuobg5aljsE0kYiFGQt2T6gCesy38C7C(UcS8fpq(1jEVpkmp55a2FfajgEpn(nM9Maw3cS4lb8wgy4yejKyNheMfDHAnQxtMjotnBd9pEFv3qmzuvrQ1yN2H3JLQaZteA6RuSdYnfAG8tcGeWOwxGTxvL5RGyRvvo1CUMrIb38JYdAtX5gSVQIdnv6aUAgQdhuP3KvQQF(b)EvA1nfBEemSx88cgqObtuWloRYBEDpHfiSx6M(Yd5dxF7pc555CVlGmZD(4bA8fyKHAiq(ZgJA7utsPJ2FYeRRoV)Bh1R1k(Hwo1oyG6yZia0gH4i9B09oGQICKOPlX8F7GS9QVHKT24dojAV6vr0Quabhtr2uDfM4pwZ6aMNBbceIDPjG1IlsePWZV5MXQCgu(bw1eosmg96eOIa1VMAg00iiB(7Qa9LFUlahCJo7JKn0n)iq2q3CTzLX(6VdhoaW3J4i5yvBCns1TQFuLX8MSNIYdItxTTGoV0KKukFKk8DUyhcJxjfcXmUmKC(1s5TCLtv1aFs)wOgcoqMVTtV2bcauo9QLZloE9gjVxRmoHynG1f0eCogtllyEoIx3PlNtsIdi2mv4vT9Gaa08UE1M5WjYwPG7G3EihsSdaYGlD1jVyfteZkhE1r4YNfg29jz3fMW5m1lfaAib3QLoVokxH94MWJ09UjxiN(gaFDiWcVsR4iOmRsytecBPzhddjH9EZcQkw1cEt1yALeOfnTW(6wC9FLAlJoe6DdFb3IG6o)EIrv0n(VfxDZiXPzF8psMw6A)a0s8FfBzPMvCOLAQblTLM149nnRRpWCRAvICy)TfyZCTja4iN2Q(w9kxIpU)yVHgv4a3d4bMtOBeaQDm2p6RCEVNhOf3XeFaKQ(1KdnUjYhhbIBPuTxobNyXVZaa8X9uWSO)LTjkLK(xvpGwGf)TZWRbqiQ1wa6BM9gVfLEdUf5g5xFBLLRrnJ)KKOBxLwFv3YxJy7BLmGvIUowAtMCm0k8yspwGdn9TJaSDDNVfCHzPteDLFyo(yRJ9eT)XG0PEczkoMuWh9y7b9M3di5xjdggAivr6IyO0uUXhA6OQbN6nwMrAyUVvleBDgNO(K99fYhNBEga78Ttw9E1XdFU)fL5eorsvM2N5gAOjeevkfpKrofQrvWQvBEnDJYKdwESUwMJhdIj(g7X6bOiTy3Mj5XrgZecb5ctZtDuesM(rNCaFuYt7vyNzehwHwu1O4Ism2PhJABNSEG(7vhlk9J)87PJiB1kkJNBlHsy1Qb16uJgETnylFURrt8GRd3o28Onz5LvlNNC51QPvn56rTmH2vEqXDsYeKEO3ueOIXJQH50Z2D9jj1towTICwAx6N9X6dC6epWZfA1zFMw7kPd1zThuAKF6hz0kSfaIntNqp7PMMxJ8YV66nP9j8vI9WNYBSc1bd0pzS1hzwOdtl)8fkMHpYXp9cVBLxgmWrrLFxfv(amwparLhMOYRtIkVJHOsFk3prLpQOY3GOY)aev8ZNnXEyq5dXrRkcUpC9DXLk2ekc4em4QwVXeKY0zB2oVGiE3eTGy4(IXduCinXJyRqPdRiEcEi8XSfvyLj6t2KPMne8dyo(QfI5F03YO9ciPk71g0y2uLbzx5SH1XockNHaN9Jf5dZISRLcXI0U8xGwNIYzFZXIOqoGK6)s(sOZI()2gVzt0YHPre1(e6HUpCtbvL9bA0T5he0rGjZ0QqOy1j8bUmDIhzTvx03ReyVfqCJ1n(kcDHVSd1i7FQOl91kO(5fdTKE9fqiSnz1js7Qn9lLpQZ1iNgKjbPweLt7g8UaDVRCe6jzzldwTn)5ob9Vhb60BKoLzio9XSVqKF)bja3uIaLYb5sy5EysA(zXWietrl(OrbRIZJyurNiGrUXEOQCfLu9qAHZ70mGXIeMdLQ4pbmtsRvXql3XtDbk6RMCm98kSoIMZHZ1QW22NiYNmv9NM5RJv(5eYHAQ8Wbukh7ShuMJsfdFBw9gK5QzXZbw(gDoVO(u9sy25rU63RSirZkx(aACg(EqWp8DqNheX6YIpBSMGfE2e3WGQaZPZv7ht)ZBh54SaqwaBnrpdK6aJOXHYiyw7HzeTU3L27g3GBBLwKbEJnC(2c18N8Uww2jKSpn85ILP8Yc5jYKUdGKwJMrIJ2nAV29ecTdU)3kteXfMuo5njrynHawEaGV8axW(2J2vEef3fD8YFMRqHFAUGHYMIztFKeEfbmn3KX(ZM(uyEkrsrEi7sgoEnTMCv34NVJfj772npNMnso9QIQiBD7Dth9dwqe33hvmC3V8RSR6r6Tm8NZsjZe7XVRnsAXYR8o(nnyZtl1ECFV)yGdavnmwaadmKtiWprG91bNVcbSEMfEApwcxXbQvCfCiNqGFIa7Rdop2oyRRGMj4kmgjS(ydEja)Vsl2UHA5Hc668MR9eTB()dbGA1u8)9)S5QTBzCb1o3Ygy(PJ66dfoXXf4nG97TZG7GAHcoFCbEdy9gDu5fki9rg6TW17OYnuX6Jl0hsJMhW3CZfyz38pB2eF99PoIjEHh7Ofn1lswaadmeNm84BgJ1ESJa1kgdoeNmqSVMkpXG)Kb4Vs4D2Mi(iQUHYFhwPnB37ai4FmU54HG7KrdQjV9eX2B8YgAz1DbWnDSjlVyAchBWFYa8xj82UgS2UFbb)JIgm8x(bOAWUHy7nEzdTA4OxBYLKCdRa7tsBmsAcgbpqV2aphWduAI(btoQSqhWJXDW7cDyyGUflh4xTbWSlGr5wKxGF9datkwNdFu6a8w1hGsWg3XEEOled2d4Bnci7XSzg6qF1bGSieEKYZfEXqCJtHpUJ98ywIGdFRse7XKAg6ojrmns55clFG91p5Pg(Uaz9VDeaan4GCf3DEgWsQbf27Be2NA47cKDGRGmixXDNNbx57AHVDI(Ehbm0kK3d)l(dfLkh)ohbmXeeY0WC7zDUR)(gPwM8kYl)4xrEP(CFm5LdPfv6NxxxXvpV2ATspOK0YfnBk73OF1zYBAdYV9BSVmoR(2Az2FD2u(lr(j9qorgyEmjqZ4Wzt7VB(zebM62(18n9Y8xEHw2kwjU2n)g631uvma9d)1U5xuJEGxPa7Mpy38EK1KntiW5AVDM7jpXxYXLZ2RxEm)L1tyrzqkV211OS0o3VB(T0VnUuVLOOu)ycVv8WQqLeLZ(nFeXb)m(OipKo)psu0BjAx(UoWeXFjcX3I6ImGZmXa6)1IhCgBUR7ZddxFc85rOTe0hmJfoYm3v)cvWeh(kfoCl3e4OPiXJyUtvoMkmk3F38pSBo4LVGUKaZUHrBfd4Jb6AzGVEVvtH9qkHogLq7dkVTr(Gg201nUGPj0Zb9hmzQIqSMWaowNuY8t2KNYlnewsPCq65(gcO9DWSPYnLfDE(E05Pv22qPsswc7wQPfywczmbVHoSwBYU5sNjlkBPQ5QAumm8(3oH(DlClz3QErPQRnPKyJWmlHVIpif5RzLhUkHGfHkEfLgAjbGUXHsl)GjArSfH4xvdooz1ijDg8gHofaDLJ(AFLMLtIzAO39yOKT(jC(abCwPNEy4UAyoa4EnVPfscx4fmGO6C2jRNoUMtTBAztOQdXJ5ecEeBzZkUtI(0TJCB1jQKzUQspNjDqV7jyIq0HikfTz78wjJIkhetgYJB43MjEfpCvQW2OSBCJY6rxgOCkh5UpfSo165KrkwnUJsk6YjFlYPkQ1mRh9TBg05YwND19VcY6jJlqXeqh1iPL9qkd4UTenkkA0QYLLrgSq8cqnnAZ44maaBVcaai0vGxGhxj01)b7zkSVlTYxWD8ztZ6mS1jojNDrKUF6d34K(aUtYZShcOT1o9DzbcnGgZXpsjJluJ6XmD5J7zw8EXWHWwasSrTKa05d3B6XC(QY5LoH4EEpMtisq2(4UH1wlGzm3h3PQbyiCobyab35MaBaKbI7lb8nfY4M(2Q2rbOXPINneIDeXlmfY7kDBRasZShoBkVkimduqCbbSGYsqIIXqDTerzTmKvicJxwjawnXIWTxRXLMzx1FnI)axYnfWGCJVxJbwFJdbwJhDUuk44j0sIiZqDTKKT6YdT70Lzt97gJ)mh4924tTfR0PdqeJxC84TEYj9EolyoYNiCYIek(KBiQjzvPwbaawo1frGv()RKsQcl0GcR72bSDs3SyRS2E3bWDFRRGJo3NEDCtsyyxSebc7eYyYdcqRXqcDO9aHZmCXZXgCOTcxHlNhgEjs)JgETzndd1CHZTHVwE41e7YRHRpf5rxps2RdSsfwYSnfLJ9nwpa7VkL3Qcnk1jtccf5p3WwduTpyEy52XpeCT(d12aT6R5fwnk844oWo8vD7YWFoDjN82dwh0zBcKaBczdpaCoKqeF5mEWoMA8u7hvVUa6gOHlTmHn340enqlFwLnRTgjaEo)k)qVEWi7dkpniUIQI2djpi6LTGGChytnu0n8po6g(iYnpCDdpl6g6Nnax0n8or6gqyZHQB4Br3W3QUH)ERB4ptDFGUdX(zZLZGnlxEJBque5ylE6cRR5ENHVDpkvLV6UmQwOpOzUvFEtjseVZJymeUzw9tA1mG9os3KQYsnnNCsLp5aSl0RU8rgHHlwvH1XQGXajhBAYer3BDrYvTmREXVnOpygW(PPBYsrvUJ8E3x3HZ79r49ywTmk)EdX7vl(zBH1QUaFQz(cFaC4DwVsNMbSXC1th2R46KJ((so7GUdxmBLBc3m3adRBTPBXE(mOTm8pjeVL6isD(CvdpYOrjdofNbTVKFtZGGSCyiIsE(yABm6jTAea1sRN98NDnxy7jcFPq8OqjUwzgLLpCDcxUup2dPegmXq1xMWnC)2u1iz2gKKrl1rReXqf)mUP01QcfMY5Z8(OtxhyiPaJVmp3F1WgLRwpzLbHQjQQlkzR3CcWI3GWqXETmQGmfvT42V)qCrZbHN(RCF1jpZQhsArc)Catw9VB(tXjj0tl)Qvr5enM8S17Mp9N)7F(9uv5s6Rs0d46pL0tCCrivZz12ugIgMq3Wst0qlHdeuAvkraHJ6lVWUAXB4MeGwqakEi8P9wP(tXitpmlcYFVKfWdCpl79VB51o1YR1YTMTseFhz74UE8Q2qITestdhAO7O6l1NvaBYiBXuDz34F15)Ny1bj(lEhuys(rFU6fiVvHUjLraMoMQjYMaBOdYCxgH3cRDvGHcPoi9qHbSOC)wQGjuaNBzjr7Al8QG3Y7H7c((NMEX2Db1EkB6GHw4(RVMj22dag6MWxdg1BPM0VRTsFt4gsTfHHgLenncydyt0EGsIdkpvKOKBuOZnbjvxkWlzyVpwFojueNU3OuTMR9QrgdIWEY9bwJe9iyucmJPsJDp6BzjQdmC0Hi3JQMYP)KW)L3(v9EE1Pa9b6HzJD(PqPcZ6yR9luWrtwFmESfOV8ECWaacQMlnWSDXQ4aGdIwWziSOwwV8zMWqVJEyC2Jmp7cbZ9FT4CihvddTHQwV)kSsPIez1w5v)Oyewg0yPqzfmWXTWqdIAGcvoUfgA6Z(V5phcg6zuNCF(g6CiyO1vTrk6YPVvphc6Zr9xrzigaBESkOaWdLUbr)vVXLUF3q3d)6AGKpgWeaLxxvtOmShVdM7)n(z54pd6w4XBzZgXzg20f7RyDzX5(TY2n6gpAiB1aZKn9V(NOe8qu0ewy(nUepif8fmNqNFOjDCPJhNLEhwPUV0y8m7DfIDdfp8cGEj22XDQoeixYI7asMjGfS9MS5IZDM59gMP4ZRof3WdTP4cjg8eo5lRIsicH1XPH1eUVeAWJ2L8IYyH2MvMTHMxAPqAuvUcO)wYwAxzLD)9epdR2MMgLWEU8jZLUBzL6BKPdawU)dRV(yQ0EAFO6fmMY2q(VkORjP3qpf0MP(35Vi)(pI2fcmROHe1N)kd4vpVO62mMTBJv3AXXl2npj7(4fIuP(M9RTRRDGu9nrQ63LAorQfI0Q)XGwf68d1WzQOv66cGKLS1pCGDG43b5yO9XTwumnQVZ2SWbZafo6p1Yn(vk3OItPY(O83gfRPCLQgHRhQGpikPG87mRkqAu07ejktwnQe3yYyn(gW9j1jGjdolhBMS)bZK9ByYQHa1HvTaxlRqwPapgfsCIPmcnKSyDt0I4vuwHm9pT2GfDr(QSKKSNODqXU5)0)8xP3qw0l9nwdvKshNZlOR7HvkFqnKPoWhaUwxHmHD04d(hB(GVaFqBNW7aJa8sHvHg)BuD8)bbLjwTfjVmr)s0ql5F0w6OIwTkAbDqpNTLgqeD7KFkK(Vu(aBiuUtvueGc6QU8NrHQXy0bke8kPTduyJa0gf(UUsI(sKOAWQDGevUNAzXx23yKhSc2u11Pqdg6kkLFkXaSkYxdWuDBrHSvc2a94ScN1UvoFkm(ZEeVxRkGz(JE4kg4pOxHRha)XVJ8hFa(dsyRYUET1EX4UMPghT542QV7p6Y5nzaJr2V(mkoIERvD(o1dawBKNnJha0uxMSrmGLhsFhcIdch1oVu2Wr1ebWXrpbC0A0gm7jHullu1hFbBwYHG0SeW3wWgEqQx1N(jMEL173N7ZJxNfNtBk6GIqYJjEbB2IJ25hCySzaVqJv5OR0OJuvrGN4vvSD0sajKuPwtuWqKVxmXtEZWOM57Jn9llqMV2nj1wJkJf)SUAVWFfjkkY47OtPE3)2fCbRwFcLir(RWrEs9I4b7RcX9lTCRLDSN4aSv0yhW7UWFB20S9QWa22DwPIslpXSZk5(LJEJnM2cG38rm5K8hXNjHPUTK(gYB2L534oIIEMHOmgWVjivtRZ25W0aGgitV1NhrSuyzFDqctX1aH)TmjyAUvpcjZnhHn97EseyVP6GBi1Z7UCOnqRtUQ11By73lxeQ3uaJXkKmta4ExL2CmST1tuOTteEbFb3ocDsrz)tVWgIiVXNk18Vflf3xn89PwhDUsFDJ1DvZ1T5wU3WAXv9nNGQDMbEmGO6VRP1pg1wGw16BpylthPQJ3EFxTxZJ(MkjmzEAZgFjjK)k7tfKJdG58taRI3lhjIrow99zllEtCNMevZB(r5qo5iG4lA2zQoY7b5qsyxT7YfgStxqw231WBf640puBabk6qH2TOrpd7ubRDxSdaWRfNPg18ARiQVWhyVWT)O9ni)86KkSTM)86dWorqbD1tJDSBRjoxU7Ng3Xny1CuCGmRpzxg3tqg3SBsQ7BCVJ4jdQtB8iqLiFfz1gxcBMN3h8mSyQJb3JE8gHJHEqL7cld6kHZg)QlQMx9nGQj6bE(uZO3lfZR(6RyASPb6u70AbPzxv6JLI9sPZFXdveMdztYaQec2blYesphy(ySAzgCdLIDOVmEvyFs4(m8gim1AmfRNIXddcizBXWWe6Jn1rAfzQPdl1nRVXEjKgxisVeYx246QT(WWPg(GZDtz1506j5GqnZPc9zw2P2xJSiB3K9uuEqC6QTfuKRT7crQYJaIaDh5J3lBIkgwUJ8XBCmLCEV02c5BBe(kV5vo8Mw6oBRTM2)ULMT0GGgpoSOQT2Y2qWTHTkR27Rv74AMVy9Q80KMLDXPlsU9tS7w)UA8mKAJcTTePVlRdon97Q1Z4asG6Mu2b026yh6JwaarPw72aEE1w)Hfo7NGZmxR16RNw9V0XAfY2pUUYvn5e5zfKEWQJITVhXEltt4oNnOlC5rjkyTMbVE84D(lSLMWLpdzqe9Al(qoWAT1t(ktdtjTLbIeY9jz3fMu3nYgVFp(QD7k7avje1N6DDm7YsY4wZiyCZ5BjZl1VbpAsuOnpMSg1RJ6K7DLdt(Dr5fr50UOhQM7hic89UGajzzldwTn)zOcWFGiWihqGvX5rmKWCj03R53fga9GAxusVI6ONS7zv6JHBlFiJ4WzA86pZ(Kz))p]] )