-- WarlockDemonology.lua
-- October 2023

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local PTR = ns.PTR

local FindPlayerAuraByID, FindUnitBuffByID, FindUnitDebuffByID = ns.FindPlayerAuraByID, ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local abs, ceil, strformat = math.abs, math.ceil, string.format

local RC = LibStub( "LibRangeCheck-3.0" )


local spec = Hekili:NewSpecialization( 266 )

spec:RegisterResource( Enum.PowerType.SoulShards )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Warlock
    abyss_walker                   = { 71954, 389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by 4% for 10 sec.
    accrued_vitality               = { 71953, 386613, 2 }, -- Drain Life heals for 15% of the amount drained over 7.7 sec.
    amplify_curse                  = { 71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    banish                         = { 71944, 710   , 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = { 71949, 111400, 1 }, -- Increases your movement speed by 60%, but also damages you for 2% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    curses_of_enfeeblement         = { 71951, 386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    dark_accord                    = { 71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by 45 sec.
    dark_pact                      = { 71936, 108416, 1 }, -- Sacrifices 20% of your current health to shield you for 200% of the sacrificed health plus an additional 24,582 for 20 sec. Usable while suffering from control impairing effects.
    darkfury                       = { 71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by 15 sec and increases its radius by 2 yards.
    demon_skin                     = { 71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of ${$s1/10}.1% of maximum health every $t1 sec, and may now absorb up to $s2% of maximum health.; Increases your armor by $m4%.    demonic_circle                 = { 71933, 268358, 1 }, -- Summons a Demonic Circle for 15 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects.
    demonic_embrace                = { 71930, 288843, 1 }, -- Stamina increased by 10%.
    demonic_fortitude              = { 71922, 386617, 1 }, -- Increases you and your pets' maximum health by 5%.
    demonic_gateway                = { 71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 90 sec.
    demonic_inspiration            = { 71928, 386858, 1 }, -- Increases the attack speed of your primary pet by 5%.
    demonic_resilience             = { 71917, 389590, 2 }, -- Reduces the chance you will be critically struck by 2%. All damage your primary demon takes is reduced by 8%.
    fel_armor                      = { 71950, 386124, 2 }, -- When Soul Leech absorbs damage, 5% of damage taken is absorbed and spread out over 5 sec. Reduces damage taken by 1.5%.
    fel_domination                 = { 71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 90%.
    fel_pact                       = { 71932, 386113, 2 }, -- Reduces the cooldown of Fel Domination by 30 sec.
    fel_synergy                    = { 71918, 389367, 1 }, -- Soul Leech also heals you for 15% and your pet for 50% of the absorption it grants.
    fiendish_stride                = { 71948, 386110, 2 }, -- Reduces the damage dealt by Burning Rush by 25%. Burning Rush increases your movement speed by an additional 5%.
    frequent_donor                 = { 71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by 15 sec.
    grim_feast                     = { 71926, 386689, 1 }, -- Drain Life now channels 30% faster and restores health 30% faster.
    grimoire_of_synergy            = { 71924, 171975, 2 }, -- Damage done by you or your demon has a chance to grant the other one 5% increased damage for 15 sec.
    horrify                        = { 71916, 56244 , 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear.
    howl_of_terror                 = { 71947, 5484  , 1 }, -- Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    ichor_of_devils                = { 71937, 386664, 1 }, -- Dark Pact sacrifices only 5% of your current health for the same shield value.
    inquisitors_gaze               = { 71939, 386344, 1 }, -- Your spells and abilities have a chance to summon an Inquisitor's Eye that deals 6,953 Shadowflame damage every 0.8 sec for 11.5 sec.
    lifeblood                      = { 71940, 386646, 2 }, -- When you use a Healthstone, gain 7% Leech for 20 sec.
    mortal_coil                    = { 71947, 6789  , 1 }, -- Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    nightmare                      = { 71916, 386648, 1 }, -- Increases the amount of damage required to break your fear effects by 60%.
    profane_bargain                = { 71919, 389576, 2 }, -- When your health drops below 35%, the percentage of damage shared via your Soul Link is increased by an additional 5%.
    resolute_barrier               = { 71915, 389359, 2 }, -- Attacks received that deal at least 5% of your health decrease Unending Resolve's cooldown by 10 sec. Cannot occur more than once every 30 sec.
    sargerei_technique             = { 93179, 405955, 2 }, -- Shadow Bolt damage increased by 8%.
    shadowflame                    = { 71941, 384069, 1 }, -- Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowfury                     = { 71942, 30283 , 1 }, -- Stuns all enemies within 8 yds for 3 sec.
    socrethars_guile               = { 93178, 405936, 2 }, -- Wild Imp damage increased by 10%.
    soul_conduit                   = { 71923, 215941, 2 }, -- Every Soul Shard you spend has a 5% chance to be refunded.
    soul_link                      = { 71925, 108415, 1 }, -- 10% of all damage you take is taken by your demon pet instead.
    soulburn                       = { 71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by 50% and makes you immune to snares and roots for 6 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for 30 sec. This shield cannot exceed 30% of your maximum health. Health Funnel: Restores 140% more health and reduces the damage taken by your pet by 30% for 10 sec. Healthstone: Increases the healing of your Healthstone by 30% and increases your maximum health by 20% for 12 sec.
    strength_of_will               = { 71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional 15%.
    summon_soulkeeper              = { 71939, 386256, 1 }, -- Summons a Soulkeeper that consumes all Tormented Souls you've collected, blasting nearby enemies for 651 Chaos damage per soul consumed over 8 sec. Deals reduced damage beyond 8 targets and only one Soulkeeper can be active at a time. You collect Tormented Souls from each target you kill and occasionally escaped souls you previously collected.
    sweet_souls                    = { 71927, 386620, 1 }, -- Your Healthstone heals you for an additional 10% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    teachings_of_the_black_harvest = { 71938, 385881, 1 }, -- Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target 4% damage reduction for 5 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by 30 sec. Felhunter: Reduces the cooldown of Devour Magic by 5 sec. Sayaad: Reduces the cooldown of Seduction by 10 sec and causes the target to walk faster towards the demon. Felguard: Reduces the cooldown of Pursuit by 5 sec and increases its maximum range by 5 yards.
    teachings_of_the_satyr         = { 71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by 15 sec.
    wrathful_minion                = { 71946, 386864, 1 }, -- Increases the damage done by your primary pet by 5%.

    -- Demonology
    annihilan_training             = { 72022, 386174, 1 }, -- Your Felguard deals 20% more damage and takes 10% less damage.
    antoran_armaments              = { 72008, 387494, 1 }, -- Your Felguard deals 20% additional damage. Soul Strike now deals 25% of its damage to nearby enemies.
    bilescourge_bombers            = { 72021, 267211, 1 }, -- Tear open a portal to the nether above the target location, from which several Bilescourge will pour out of and crash into the ground over 6 sec, dealing 4,446 Shadow damage to all enemies within 8 yards.
    call_dreadstalkers             = { 72023, 104316, 1 }, -- Summons 2 ferocious Dreadstalkers to attack the target for 12 sec.
    carnivorous_stalkers           = { 72018, 386194, 1 }, -- Your Dreadstalkers' attacks have a 10% chance to trigger an additional Dreadbite.
    cavitation                     = { 72009, 416154, 2 }, -- Your primary Felguard's damaging critical strikes deal 10% increased damage.
    demoniac                       = { 72024, 426115, 1 }, -- [264178] Send the fiery soul of a fallen demon at the enemy, causing $s1 Shadowflame damage.$?c2[; Generates 2 Soul Shards.][]
    demonic_calling                = { 72017, 205145, 1 }, -- Shadow Bolt and Demonbolt have a 10% chance to make your next Call Dreadstalkers cost 2 fewer Soul Shards and have no cast time.
    demonic_knowledge              = { 72026, 386185, 1 }, -- Hand of Gul'dan has a 15% chance to generate a charge of Demonic Core.
    demonic_strength               = { 72021, 267171, 1 }, -- Infuse your Felguard with demonic strength and command it to charge your target and unleash a Felstorm that will deal 300% increased damage.
    doom                           = { 72028, 603   , 1 }, -- Inflicts impending doom upon the target, causing 20,514 Shadow damage after 15.4 sec. Doom damage generates 1 Soul Shard.
    dread_calling                  = { 71999, 387391, 2 }, -- Each Soul Shard spent on Hand of Gul'dan increases the damage of your next Call Dreadstalkers by 2%.
    dreadlash                      = { 72020, 264078, 1 }, -- When your Dreadstalkers charge into battle, their Dreadbite attack now hits all targets within 8 yards and deals 10% more damage.
    fel_and_steel                  = { 72016, 386200, 1 }, -- Your primary Felguard's Legion Strike damage is increased by 10%. Your primary Felguard's Felstorm damage is increased by 5%.
    fel_invocation                 = { 95146, 428351, 1 }, -- Soul Strike deals $s1% increased damage and generates a Soul Shard.; Reduces the cast time of Summon Vilefiend by ${$abs($s2)/1000}.1 sec and your Vilefiend now deals $428455s1 Nature damage to nearby enemies every $428453t sec while active.
    fel_sunder                     = { 72010, 387399, 1 }, -- Each time Felstorm deals damage, it increases the damage the target takes from you and your pets by 1% for 8 sec, up to 5%.
    grand_warlocks_design          = { 71991, 387084, 1 }, -- $?a137043[Summon Darkglare]?a137044[Summon Demonic Tyrant][Summon Infernal] cooldown is reduced by $?a137043[${$m1/-1000}]?a137044[${$m2/-1000}][${$m3/-1000}] sec.
    grimoire_felguard              = { 72013, 111898, 1 }, -- Summons a Felguard who attacks the target for 17 sec that deals 45% increased damage. This Felguard will stun and interrupt their target when summoned.
    guillotine                     = { 72005, 386833, 1 }, -- Your Felguard hurls his axe towards the target location, erupting when it lands and dealing 4,268 Shadowflame damage every 1 sec for 6 sec to nearby enemies. While unarmed, your Felguard's basic attacks deal damage to all nearby enemies and attacks 50% faster.
    guldans_ambition               = { 71995, 387578, 1 }, -- When Nether Portal ends, you summon a Pit Lord that blasts your target for $<damage> Fire damage every $427688t1 sec for $427688d.
    heavy_handed                   = { 72014, 416183, 1 }, -- Increases your primary Felguard's critical strike chance by 10%.
    immutable_hatred               = { 72005, 405670, 1 }, -- When you consume a Demonic Core, your primary Felguard carves your target, dealing $<damage> Physical damage.
    imp_gang_boss                  = { 71998, 387445, 2 }, -- Summoning a Wild Imp has a $s1% chance to summon a Imp Gang Boss instead. An Imp Gang Boss deals $387458s2% additional damage. ; Implosions from Imp Gang Boss deal $s2% increased damage.
    imperator                      = { 72025, 416230, 1 }, -- Increases the critical strike chance of your Wild Imp's Fel Firebolt by $s1%.
    implosion                      = { 72002, 196277, 1 }, -- Demonic forces suck all of your Wild Imps toward the target, and then cause them to violently explode, dealing 6,113 Shadowflame damage to all enemies within 8 yards.
    infernal_command               = { 72006, 387549, 2 }, -- While your Felguard is active, your Wild Imps and Dreadstalkers deal 5% additional damage.
    inner_demons                   = { 72027, 267216, 1 }, -- You passively summon a Wild Imp to fight for you every $t1 sec.
    kazaaks_final_curse            = { 72029, 387483, 2 }, -- Doom deals 3% increased damage for each demon pet you have active.
    malefic_impact                 = { 72012, 416341, 1 }, -- Increases Hand of Gul'dan damage by $s1% and the critical strike chance of Hand of Gul'dan by $s2%.
    nerzhuls_volition              = { 71996, 387526, 2 }, -- Demons summoned from your Nether Portal deal $s1% increased damage.
    nether_portal                  = { 71997, 267217, 1 }, -- Tear open a portal to the Twisting Nether for 15 sec. Every time you spend Soul Shards, you will also command demons from the Nether to come out and fight for you.
    pact_of_the_imp_mother         = { 72004, 387541, 2 }, -- Hand of Gul'dan has a 8% chance to cast a second time on your target for free.
    power_siphon                   = { 72003, 264130, 1 }, -- Instantly sacrifice up to 2 Wild Imps, generating 2 charges of Demonic Core that cause Demonbolt to deal 30% additional damage.
    reign_of_tyranny               = { 71991, 427684, 1 }, -- Summon Demonic Tyrant empowers $s1 additional Wild Imps and deals $s2% increased damage for each demon he empowers.
    sacrificed_souls               = { 71993, 267214, 2 }, -- Shadow Bolt and Demonbolt deal 2% additional damage per demon you have summoned.
    shadow_invocation              = { 95145, 422054, 1 }, -- Bilescourge Bombers deal $s1% increased damage, and your spells now have a chance to summon a Bilescourge Bomber.
    shadows_bite                   = { 72000, 387322, 1 }, -- When your summoned Dreadstalkers fade away, they increase the damage of your Demonbolt by 10% for 8 sec.
    soul_strike                    = { 72019, 428344, 1 }, -- [267964] Strike into the soul of the enemy, dealing $<damage> Shadow damage.$?s428351[; Generates 1 Soul Shard.][]
    soulbound_tyrant               = { 71992, 334585, 2 }, -- Summoning your Demonic Tyrant instantly generates 3 Soul Shards.
    spiteful_reconstitution        = { 72001, 428394, 1 }, -- Implosion deals $s1% increased damage. Consuming a Demonic Core has a chance to summon a Wild Imp.
    stolen_power                   = { 72007, 387602, 1 }, -- When your Wild Imps cast Fel Firebolt, you gain an application of Stolen Power. After you reach 75 applications, your next Demonbolt deals 60% increased damage or your next Shadow Bolt deals 60% increased damage.
    summon_demonic_tyrant          = { 72030, 265187, 1 }, -- Summon a Demonic Tyrant to increase the duration of your Dreadstalkers, Vilefiend, Felguard, and up to $s3 of your Wild Imps by ${$265273m3/1000} sec. Your Demonic Tyrant increases the damage of affected demons by $265273s1%, while damaging your target.$?s334585[; Generates ${$s2/10} Soul Shards.][]
    summon_vilefiend               = { 72019, 264119, 1 }, -- Summon a Vilefiend to fight for you for the next 15 sec.
    the_expendables                = { 71994, 387600, 1 }, -- When your Wild Imps expire or die, your other demons are inspired and gain 1% additional damage, stacking up to 10 times.
    the_houndmasters_stratagem     = { 72015, 267170, 1 }, -- Dreadbite causes the target to take 20% additional Shadowflame damage from your spell and abilities for the next 12 sec.
    umbral_blaze                   = { 72011, 405798, 2 }, -- Hand of Gul'dan has a 8% chance to burn its target for 5,628 additional Shadowflame damage every 2 sec for 6 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bonds_of_fel     = 5545, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the 8 yd radius they explode, dealing 60,958 Fire damage split amongst all nearby enemies.
    call_fel_lord    = 162 , -- (212459) Summon a fel lord to guard the location for 15 sec. Any enemy that comes within 6 yards will suffer 36,911 Physical damage, and players struck will be stunned for 1 sec.
    call_observer    = 165 , -- (201996) Summons a demonic Observer to keep a watchful eye over the area for 20 sec. Anytime an enemy within 30 yards casts a harmful magical spell, the Observer will deal up to 10% of the target's maximum health in Shadow damage.
    fel_obelisk      = 5400, -- (353601) Summon a Fel Obelisk with 5% of your maximum health. Empowers you and your minions within 40 yds, increasing attack speed by 20% and reducing the cast time of spells by 20% for 15 sec.
    gateway_mastery  = 3506, -- (248855) Increases the range of your Demonic Gateway by 20 yards, and reduces the cast time by 30%. Reduces the time between how often players can take your Demonic Gateway by 30 sec.
    impish_instincts = 5577, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by 2 sec. Cannot occur more than once every 5 sec.
    master_summoner  = 1213, -- (212628) Reduces the cast time of your Call Dreadstalkers, Summon Vilefiend, and Summon Demonic Tyrant by 20% and reduces the cooldown of Call Dreadstalkers by 5 sec.
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
            -- elseif spellID == 111898 then table.insert( grim_felguard, now + 17 )

            -- Demonic Tyrant: 265187, 15 seconds uptime.
            elseif spellID == 265187 then table.insert( demonic_tyrant, now + 15 )
                -- for i = 1, #dreadstalkers do dreadstalkers[ i ] = dreadstalkers[ i ] + 15 end
                -- for i = 1, #vilefiend do vilefiend[ i ] = vilefiend[ i ] + 15 end
                -- for i = 1, #grim_felguard do grim_felguard[ i ] = grim_felguard[ i ] + 15 end
                for i = 1, #wild_imps do wild_imps[ i ] = wild_imps[ i ] + 15 end

                for _, imp in pairs( imps ) do
                    imp.expires = imp.expires + 15
                    imp.max = imp.max + 15
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
                -- TODO:  Come up with a good estimate of the time it takes.
                dreadstalkers_travel_time = ( select( 6, GetSpellInfo( 104316 ) ) or 25 ) / 25

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

spec:RegisterGear( "tier31", 207270, 207271, 207272, 207273, 207275 )
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
            if texture == 136216 then
                extraTime = action.grimoire_felguard.lastCast % 1
                demon = grim_felguard_v
            elseif texture == 1616211 then
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

        if #grim_felguard_v > 1 then table.sort( grim_felguard_v ) end
        if #vilefiend_v > 1 then table.sort( vilefiend_v ) end
        if #dreadstalkers_v > 1 then table.sort( dreadstalkers_v ) end
        if #demonic_tyrant_v > 1 then table.sort( demonic_tyrant_v ) end
    end

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

    if buff.nether_portal.up and talent.guldans_ambition.enabled then
        state:QueueAuraExpiration( "nether_portal", ExpireNetherPortal, buff.nether_portal.expires )
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

    -- print( grim_felguard_v[1], buff.grimoire_felguard.up, buff.grimoire_felguard.remains )

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
            if buff.nether_portal.up then
                summon_demon( "other", 15 )
            end

            if legendary.wilfreds_sigil_of_superior_summoning.enabled then
                reduceCooldown( "summon_demonic_tyrant", amt * 0.6 )
            end

            if talent.grand_warlocks_design.enabled then
                reduceCooldown( "summon_demonic_tyrant", amt * 0.6 )
            end
        elseif amt < 0 and floor( soul_shard ) < floor( soul_shard + amt ) then
            if talent.demonic_inspiration.enabled then applyBuff( "demonic_inspiration" ) end
        end
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


--[[ APL Reverted 1/2/24.

actions.precombat+=/variable,name=tyrant_timings,value=0

-- actions.variables+=/variable,name=tyrant_timings,op=set,value=120+time,
-- if=((buff.nether_portal.up&buff.nether_portal.remains<3&talent.nether_portal)|fight_remains<20|pet.demonic_tyrant.active&fight_remains<100|fight_remains<25|(pet.demonic_tyrant.active|!talent.summon_demonic_tyrant&buff.dreadstalkers.up))&variable.tyrant_sync<=0

-- actions+=/call_action_list,name=tyrant,if=cooldown.summon_demonic_tyrant.remains<15&cooldown.summon_vilefiend.remains<gcd.max*5&cooldown.call_dreadstalkers.remains<gcd.max*5&(cooldown.grimoire_felguard.remains<10|!set_bonus.tier30_2pc)&(cooldown.summon_demonic_tyrant.remains<15|fight_remains<40|buff.power_infusion.up)|talent.summon_vilefiend.enabled&cooldown.summon_demonic_tyrant.remains<15&cooldown.summon_vilefiend.remains<gcd.max*5&cooldown.call_dreadstalkers.remains<gcd.max*5&(cooldown.grimoire_felguard.remains<10|!set_bonus.tier30_2pc)&(cooldown.summon_demonic_tyrant.remains<15|fight_remains<40|buff.power_infusion.up)|cooldown.summon_demonic_tyrant.remains<15&(buff.vilefiend.up|!talent.summon_vilefiend&(buff.grimoire_felguard.up|cooldown.grimoire_felguard.up|!set_bonus.tier30_2pc))&(cooldown.summon_demonic_tyrant.remains<15|buff.grimoire_felguard.up|fight_remains<40|buff.power_infusion.up)

-- actions.tyrant+=/variable,name=tyrant_timings,op=set,value=120+time,
-- if=variable.pet_expire>0&variable.pet_expire<action.summon_demonic_tyrant.execute_time+(buff.demonic_core.down*action.shadow_bolt.execute_time+buff.demonic_core.up*gcd.max)+gcd.max&variable.tyrant_timings<=0


spec:RegisterPhasedVariable( "tyrant_timings",
    -- Default value.
    function ()
        return 0
    end,
    -- Value update function; include all conditions here.
    function( current, default )
        if not talent.summon_demonic_tyrant.enabled then return default end

        local value = current or default

        -- ((buff.nether_portal.up&buff.nether_portal.remains<3&talent.nether_portal)|fight_remains<20|pet.demonic_tyrant.active&fight_remains<100|fight_remains<25|(pet.demonic_tyrant.active|!talent.summon_demonic_tyrant&buff.dreadstalkers.up))&variable.tyrant_sync<=0
        if ( ( buff.nether_portal.up and buff.nether_portal.remains < 3 and talent.nether_portal.enabled ) or boss and fight_remains < 20 or pet.demonic_tyrant.active and fight_remains < 100 or ( pet.demonic_tyrant.active or not talent.summon_demonic_tyrant.enabled and buff.dreadstalkers.up ) ) and ( current - time ) <= 0 then
            Hekili:Debug( "Setting tyrant_timings to 120 + %d.", time )
            value = 120 + time
        end

        if ( cooldown.summon_demonic_tyrant.remains < 15 and cooldown.summon_vilefiend.remains < gcd.max * 5 and cooldown.call_dreadstalkers.remains < gcd.max * 5 and ( cooldown.grimoire_felguard.remains < 10 or set_bonus.tier30_2pc == 0 ) and ( cooldown.summon_demonic_tyrant.remains < 15 or boss and fight_remains < 40 or buff.power_infusion.up ) or
           talent.summon_vilefiend.enabled and cooldown.summon_demonic_tyrant.remains < 15 and cooldown.summon_vilefiend.remains < gcd.max * 5 and cooldown.call_dreadstalkers.remains < gcd.max * 5 and ( cooldown.grimoire_felguard.remains < 10 or set_bonus.tier30_2pc == 0 ) and ( cooldown.summon_demonic_tyrant.remains < 15 or boss and fight_remains < 40 or buff.power_infusion.up ) or
           cooldown.summon_demonic_tyrant.remains < 15 and ( buff.vilefiend.up or not talent.summon_vilefiend.enabled and ( buff.grimoire_felguard.up or cooldown.grimoire_felguard.up or set_bonus.tier30_2pc == 0 ) ) and  ( cooldown.summon_demonic_tyrant.remains < 15 or buff.grimoire_felguard.up or boss and fight_remains<40 or buff.power_infusion.up ) ) and
           ( variable.pet_expire > 0 and variable.pet_expire < action.summon_demonic_tyrant.execute_time + ( ( buff.demonic_core.down and action.shadow_bolt.execute_time or 0 ) + ( buff.demonic_core.up and gcd.max or 0 ) ) + gcd.max and current <= 0 ) then -- Conditions for Tyrant action list were met.
            Hekili:Debug( "[2] Setting tyrant_timings to 120 + %d.", time )
            value = 120 + time
        end

        return value
    end,
"reset_precast", "advance_end", "runHandler" ) ]]


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
    balespiders_burning_core = {
        id = 337161,
        duration = 15,
        max_stack = 4
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
    -- Damage done increased by $w2%.
    -- https://wowhead.com/beta/spell=171982
    demonic_synergy = {
        id = 171982,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Doomed to take $w1 Shadow damage.
    -- https://wowhead.com/beta/spell=603
    doom = {
        id = 603,
        duration = function() return 15 * haste end,
        tick_time = function() return 15 * haste end,
        type = "Magic",
        max_stack = 1
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
    -- Suffering Fire damage every $t1 sec.
    felseeker = {
        id = 427688,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1,
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
    -- Talent: Damage taken from the Warlock's Shadowflame damage spells increased by $s1%.
    -- https://wowhead.com/beta/spell=270569
    the_houndmasters_stratagem = {
        id = 270569,
        duration = 12,
        max_stack = 1,
        copy = "from_the_shadows" -- name from pre-10.1
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
    -- Talent: Damage done increased by $w1%.
    -- https://wowhead.com/beta/spell=387552
    infernal_command = {
        id = 387552,
        duration = 3600,
        max_stack = 1
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
    nether_portal = {
        id = 267218,
        duration = 15,
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
    -- Talent: $s1% of all damage taken is split with the Warlock's summoned demon.    The Warlock is healed for $s2% and your demon is healed for $s3% of all absorption granted by Soul Leech.
    -- https://wowhead.com/beta/spell=108446
    soul_link = {
        id = 108446,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: After reaching $u stacks, your next Demonbolt deals $387604s2% increased damage or your next Shadow Bolt deals $387604s1% increased damage.
    -- https://wowhead.com/beta/spell=387603
    stolen_power = {
        id = 387603,
        duration = 15,
        tick_time = 3,
        max_stack = 75
    },
    -- Talent: Increases the damage of Demonbolt by $s2% and Shadow Bolt by $s1%.
    -- https://wowhead.com/beta/spell=387604
    stolen_power_final = {
        id = 387604,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Damage done increased by $s1%.
    -- https://wowhead.com/beta/spell=387601
    the_expendables = {
        id = 387601,
        duration = 30,
        max_stack = 10
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

    dreadstalkers = {
        duration = 12,

        meta = {
            up = function ()
                local exp = dreadstalkers_v[ #dreadstalkers_v ]
                return exp and exp >= query_time or false
            end,
            down = function ( t ) return not t.up end,
            applied = function () local exp = dreadstalkers_v[ #dreadstalkers_v ]; return exp and ( exp - 12 ) or 0 end,
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
            applied = function () local exp = grim_felguard_v[ #grim_felguard_v ]; return exp and ( exp - 17 ) or 0 end,
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
            applied = function () local exp = vilefiend_v[ #vilefiend_v ]; return exp and ( exp - 15 ) or 0 end,
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
            applied = function () local exp = wild_imps_v[ #wild_imps_v ]; return exp and ( exp - 40 ) or 0 end,
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
            applied = function () local exp = imp_gang_boss_v[ #imp_gang_boss_v ]; return exp and ( exp - 40 ) or 0 end,
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
            applied = function () local exp = other_demon_v[ #other_demon_v ]; return exp and ( exp - 15 ) or 0 end,
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
    function() return Glyphed( 112870 ) and 58965 or 17252 end,
    "summon_felguard",
    3600, 58965, 17252 )

spec:RegisterPet( "doomguard",
    11859,
    "ritual_of_doom",
    300 )


--[[ Demonic Tyrant
spec:RegisterPet( "demonic_tyrant",
    135002,
    "summon_demonic_tyrant",
    15 ) ]]

spec:RegisterTotem( "demonic_tyrant", 135002 )
spec:RegisterTotem( "vilefiend", 1616211 )
spec:RegisterTotem( "grimoire_felguard", 136216 )
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
            removeBuff( "stolen_power" )
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

    -- Talent: Inflicts impending doom upon the target, causing 5,248 Shadow damage after 15.2 sec. Doom damage generates 1 Soul Shard.
    doom = {
        id = 603,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "doom",
        startsCombat = true,
        cycle = "doom",
        min_ttd = function () return 3 + debuff.doom.duration end,

        -- readyTime = function () return IsCycling() and 0 or debuff.doom.remains end,
        -- usable = function () return IsCycling() or ( target.time_to_die < 3600 and target.time_to_die > debuff.doom.duration ) end,
        handler = function ()
            applyDebuff( "target", "doom" )
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

    -- Talent: Tear open a portal to the Twisting Nether for 15 sec. Every time you spend Soul Shards, you will also command demons from the Nether to come out and fight for you.
    nether_portal = {
        id = 267217,
        cast = 1.5,
        cooldown = 180,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "nether_portal",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "nether_portal" )
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
        cast = function() return 2 * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.015,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            removeBuff( "stolen_power" )
            gain( 1, "soul_shards" )

            if legendary.balespiders_burning_core.enabled then
                addStack( "balespiders_burning_core" )
            end
        end,
    },

    -- Talent: Command your Felguard to strike into the soul of its enemy, dealing 2,814 Shadow damage. Generates 1 Soul Shard.
    soul_strike = {
        id = 267964,
        cast = 0,
        cooldown = 10,
        gcd = "off",
        school = "physical",

        talent = "soul_strike",
        startsCombat = true,

        usable = function() return pet.alive and pet.real_pet == "felguard", "requires a living felguard" end,
        handler = function ()
            if talent.fel_invocation.enabled then gain( 1, "soul_shards" ) end
        end,
    },

    -- Talent: Summon a Demonic Tyrant to increase the duration of your Dreadstalkers, Vilefiend, Felguard, and up to $s3 of your Wild Imps by ${$265273m3/1000} sec. Your Demonic Tyrant increases the damage of affected demons by $265273s1%, while damaging your target.$?s334585[; Generates ${$s2/10} Soul Shards.][]
    summon_demonic_tyrant = {
        id = 265187,
        cast = 2,
        cooldown = function () return 90 - ( talent.grand_warlocks_design.enabled and 30 or 0 ) end,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "summon_demonic_tyrant",
        startsCombat = false,

        toggle = "cooldowns",

        --[[ readyTime = function ()
            local dcon_imps = settings.dcon_imps or 0
            if ( dcon_imps or 0 ) == 0 or buff.wild_imps.stack > dcon_imps then return 0 end

            local missing = settings.dcon_imps - buff.wild_imps.stack
            if missing <= 0 then return 0 end
            if missing > 3 or missing > #guldan_v then return 3600 end

            -- Still a little risky, because imps can despawn, too.
            for i, time in ipairs( guldan_v ) do
                if time > query_time then
                    missing = missing - 1
                    if missing <= 0 then return time - query_time - action.summon_demonic_tyrant.cast end
                end
            end

            return 3600
        end, ]]

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
        id = 264119,
        cast = function() return ( talent.fel_invocation.enabled and 1.5 or 2 ) * haste end,
        cooldown = 45,
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


spec:RegisterPack( "Demonology", 20240121, [[Hekili:D3ZAZnUXr(BrvQLlHEqbaskVBIitLyFjNDLlNRO15(MOGibLWTGa8aaLwvfl(B)6Eg8yE0dEWhR96pKyTeZ0VNE6UNEaU35(pD)Dl8Y8V)F6A7oY2X1zGJR9hTV5(7YEBT)93T2B(N9Ec(JiVvW))p4Vkokom(P3Wh9wyS3ceePXBsMdp(5SS1P)XRV(PGSN384G5XRUony1MqVSG4O5jElZW)98RFmm(XRxK49uC0YWGNEo7A)ONcI8VEEOxA6SvXl2e6NET36WRF1ljmE(NhmF967V7XnbHz)y09pst1JakzT)C4NVbyGNdwSWNpw)053Fho2RSDUY15pU7H)RGO4KDpKLee9z)SDpSzncWb7(PD)uX4ShxnU)Z4)U6ygELJ7voFagZVW(90DpSmjE1UhUly13lpOrWG(llwapATFy4Uh(hidjnIHiys939WkVGON9IGX(QV364iaQV(SFK)l(jcZayIpcZ4tWy(mc1GOfH(Yp)7qIp(faKXrfu2Nc8bEzOT8iDHr(V8tFlAoGlqXPXboahS7HE7EWrqISPwMgKEibS7H)2MKSNrS6ypWTCwYJCmBK)Sx28N5JR6X2FGZj5YpVsnMWq(oUwOqpS7HeV5bEHIu2FcMko)p9wIxugIRflcIEA3dP(zzWFidTByq7hbdw)v(rziO2KdAkMfNYyjcyzmNHDgmwDkpCfYk)VBsbQilgamQ0VBZQvOw6Fhe6VmWNP9bL(UhcGr9AC07H)Zc)qV3k4aJqIT(8X4WSci4b)vsqkyLeVe(FGz0CV1Rz8oNW(HeFVfPat(z)KuzMYLl4ddJFvcYimz)wiywgMEnA0eVjtK4QaIddi)ly2V4d81FZhKMFp83rWir1Y8SnOaUqAviOJIb49gUY07fVGqVhfTVTV5k3BYHlWrWGwdQkVSnj(v645EPm68PG5YZCCU9ex09ZXVIMN3fS(zufSjf82bc(OkaT(zVu))eA59gxsdidO)6Wkx2ljAbgbh3sVWqM0pE5sbYA8vdT5wDGw6F(ZabKIYcyyBYsdw4Rqn7EO)F26YCDoZ3uampyHwjbeG(zwgefKcRPE0hSi95a2)lRdsexbc4UqyYTteTrU7zVKfPC227L4a0Yeqa7zmlIG5O6eboWOZ)mjC)fd24RG5jnEB(64pj7uwgM2U0l1arYJOn4N995K(Q3QeAVcoizgSO1GLa8gvS097d99I4I8myoPb4owODaY5LY(e)1EjE8hXuesGY(JClR1RdbCdB0Dfq8zOv)6KG4KGS3OyPrfoa)pIqR8Dp83Hn5cJbzSFP5y5kSsz(DzjWwMOZAW(cmg9xidYrmq(xb3BO1Df(bt3G0a2(kmrxbRXqKaigwyq(lAE(UeflZd3W9Gcsi)KiCj8lEjbS1Pr(FjBww5cIW55bam4(7cdsZszbD4V0Btyg8N)twqiGFayeW)9l(ZYIttV)oFM4yX9)17ZGn0fhtkUl6mmQaLrnuCul8FbIkz2kpqLRmUr44Q(L7IHqlGDcQMBbRG)v4g4)0hweTbwXUqYBjU8pafLt)Z5p)LcR7QNzX8u)08fdw59LDpC(UhShm((7Md6dFalyqnstenb7rIUnRzu2mEOyR9ZMXxmJS04tgl9usWQyalZw6h(0gWDqhyTZkmphKYw(pRInZPvgVMpgDmjoideZ(jUU5ylUKef7Hi4SUifApF(DDMpTviEARZgzPTBz8uhj3p0zYTVOOlYhJ1C264e4hKPL5XXHWwarkJPYChJlMpugnlpmKRTej7O1i5(XotUmyZDnoajhrHnoPx8Nbb7VkWNtsWUAxaBSvjV9GHVmyU)IzqkxHPv8Oe1fSADisFo2hebwkCUD3d30aL62EkLzaPccafJBpiizwNJgZ(Hgy2rhiL62zkT08nFf3cECaZiiExBMaUDZax75pNfJs1ulD1LpL5yCASW7GrnHPRLwElom2kfscGyRXBL38yS88GihcNzWDR6mLCPaaGrmPZGqCYzyMCNfFaeZ8mi47zW8XypkL5pciWp5Zqqnkrl4mQ2PfghVy2YnjVPoTX1nTLGhp2uvN1n1nlVO5qeLjEa)bch1PQ6SVyw5PmdWjfIRu8FRINkR(YG5Yh8mNzOYoTyZkINVYlILkh3ccgd4BFGIzhFXeFlK8e5ZCgG5SmllyLpB1LDP5vDdXQar1GLYXOrTUGHpgcRVoUChab2pRWkK)CHhwAEwAlIdqdbvrCpH5g3GuZTuQzzaqC5(SfBkY7y6emXUNEoBwofW09Q7CQO7Dv09UDs372GU3DV19UnR7jgYHP7DmR7DQt37Sx6E3wSIXKU3TD6E1WqoK190eA3w6lk0x4bjGbP0zyzrJlUkvJ15lOxtMCTZFcoketSFTA7qZlhSuITSTB1oLdBlwMTQXODiRCPxC2TfVTv752ILh6ApIvZDw7r7rOTApNJQ2tnOtt7CJazgwy)c1z1pGGrnIWIPf92QnqCmBIs8EXhlC4SuEX(f16cQGG0bgNIGcUppa8ytmnkeNLgarBukkrrvJUBptqCwmW08kvnaJK7TAmdLvl07AxnglnNhF7Y7QMK07APX7pgNYxwlTLaNQDloXoZwqOD3qtoFaHq2Zb(ltN9K3QhdYeT3mkkkWP(SrCPw1n9TPA)2qT1jvR2IrB)rKAvlOMUB5272TTuBRCPQTFasTQ1ZsO6IMnsgAxXwSKT4)JzyrA5LQnpJk(u9Z9vPMMHGJOcFV2dgxW4kO9D7E4JJ5jrNVWIEa3IN2O4gi8mTt8dEkcCWYT7IEtUip01LWQIlr)T4SFAt4cVig3Og4Cf305ngYP5EFLZ9vEM1uUwK(kZWFF5UgC8msSiARXZwBwq0Yn4roiuBaEocjEblMXokTbElwKoap0TCSCL6thufeCHN)MkbjHEOMYM8TJMt0Bt6ZEWCXqHap7P7zanhnnB7XUOiVpzrMlc6RfA5(1E4asef9qSeSlBh9Bq6vpvCic3w6PUQyxUQzfw7bo1cQVn2PGd3pkSPcPiKDqDQj90vVU8DqgRHQsUIHf1GZlg8IIEzqeX8vwl8510moE1ShbmwX)5bnkVfc4ZAgVdMykw9zxPKH93hwyNrx3uXqufm9J3eIbsg8zFdhPH4ieLpI(AClqnFW4X6Zn8kx4Q8G(SNDvz8Ye7RwfiQg7iTmNvTCJvu(CbcTmsASflWCOg4mOuzXjFiMPhJJ2KcXP7Nm0zM765Gw8T5HqmvEjp5NLI5DHAF1CQ0pwldAGAnd4p)qnge45lkHwjNcbrIbRNNHBvsbFnX6ffMRw1i3lwqX9yLY6HgMSxnVcfNpgoeorcu3njy1DZqLfXc5yXW7iXoa4rWzq684nGvbq7RWc8R2WaQr5Vx0z)6Z8lFsYBOPnoXJmQGbEQStqyeR5G87Gtt3XDzFALYEiUpN6jKQSdLuiqmY30XtGhlwCAUonfyQ18FhBfQI2tbBhkwlHTz9L82I7hXzTa9gfHTGfGY3gS7H)Bi(WHxnklV158cYsXscHnd1T3KIDS2YmEhrw0RASPmo7cQz8bIziLVZRXZyLIcyHuHYzvgEgYAeU0Q4yuUyodeMColozfRbFyNTyHxZjLres4C2rBFrCQyNr5NWqP5yd0ZyJTSRGjiFC7mLyUuU5JDoqr1tMhjv07xYgqm75v5z2XqqJkawAp0QbxtBxyvVtNrMQGRs2MYw3)skQSy9UNhAMfJntf(xVfVPO)9E2dlVeSvBAEB4LxgjwNB9dXya)4FXASqSL9qIfTul6AV(oFcEk2QD)pbHy7Fgf(MLI2UV8o)tloXIwLqJsqgJ6usxOH63rg(XewUre)khb1fyuVMIl6wdXfreMt5j3vAIGk08gspf4R0GNIentqJb1yoRe2KI5ZooyUMkCmYuTLfJcwn(jnBeJXezrx6LYqljJ2n3j20c2u3o82cL9PjqyIaEhke(zPdC6EjqELSqNrJDH7R(flCxX6l2SNXglng7MteqmvIPYU(vtLqfoxHMOMiiNwURJX4NjZV4WLQm6dJci1BjxgQwo5kXJE61Tk5d6mzK6VWdofhkvnYmMQ28xndI6YhQC9Lyy(s8)ibVOhldG)YtpbppLDcl8omVO38bZHF(oU1W84vfDtpmQFGjlnhMSH8(mNhZiZ16U7WQM48mxyO2Uz6fSMGQUQHmYuBcGglIutI)sqW)moo6mRhBlMLvEji5gPIzxLjEWbf95DlxW6kufjTiZyL3ApbMHCt2tOrkN7aSepbgP8PyI5oaicIs2sbbO5fg6a0XU(GEnVWWOxq(ESKw5IKV66gZlBiGdTVwX8TYklskHjzZnIzLlSYgxMHz(emLYXx8NVbYAPSYk9PCEGlZz0FbSQwyPdbA)1k1s7cbzXlL9h5cGgFd(N1VmIKrNswbjAMwOhnetjwrUjL(qDHXAkKP1X5lSBKYTRLq(nVcuPZsQ1tZVtfbn6HZSltKvNhVbRLuzUxLCGuYTCwONXZdr(5vhJc)3nMm5uM3pQWWkPNwMSxr0uKfuI0NxnE(faIgRYjQIUSAOqG)Y1(twIOzpqhQWEVhYOcj8zhHZn8msta1Ze0ipBTpBBrA30kjlTDQsa38tp3Ge0OUWCfbvlmtnrSODFtKYqHUcpeCT57qGPOFXawgk7BlAD9HPPDDrKO1JHHvwJxkjd8UunnQ)(kvNjAlpxxD1I1(i(Dml(PJ5w7wWyCfY3(sFD3lgL8MeIKzb5yoXfYQnEWw2MDw2ZqPKlLbn3jn87qg8)Fnai2D89zigsPta1S)6EKYZ6IO0Xudjkw0fs5P4Uqg3QIxCtRtRCNobDNgowZAZoZuSJDl6qr9AECpKag0t1K7h)2qrTLLALgG4yMhV6rpY06QyF6(o3lS4IPCMQ7sWIP829jvEhyz4Sfy1NyDLw95sDaOjxCdtNkjimF1eFJzSwKXNCxIvD57VZMknIMtcwObvX7ldMzcYoIOuPPDPcoVd4XTr84wHNUF3ULBG(Knp(2SxF2pCnSEN9(6bTELhZRphaEOsW2PoiAUxcyf4plyES(DgkiDarZutjOYVvsurg3bwWTfSGBxyb3wZcUISq3Vk3zT7Amql843HfQiz7aIR)oeqZYviEpUT1cSmA(kCtVYVFXsIKvbjjXjOVILjai3K4Vyww8Qy4xFnLVdQDroZAtUMRgX5fTjTPLVL0fzGZDGnDBGnDpe2SPBasnSPlbBA4sAhSSEFTvso8nQfzrzu8nweHqgrB)xjPExJHJxn2jLxKYwpL31e(5W0kxNoZpmfyw2R7JCLSdzaPDuQ52SuZ1GuZ9xzPgj(BPuZWwWnj1mCxsuc9Ow7oQNlkHfxDf(sil2jrhlWVjZCoLSMlzOOTK1oeEYmdjfgQbdQgTPU2imMjDjfoNbl2B1Sl2PE)YlILryKeaL)s5RcwSs7WUCnN3rVM8C6NwWHn6UHIj1Uk6MzsNwZKoTKjBZoGwYG5ccwLBeFfHHTfJPDSTlGJv9g21CLRWq7FniCbRVaPA2LgYcJUtemL28WARdP2BfcJP0wDBmyhhnZry1z4u6jtpl5mI3)aMXIPsqYsJ7fiZw8z5VypTHr)keAkpTLpHVF7arAm(g)J1dCVN7r(9yNX9)TbsKAbwfaKC92a2fESgxDoK6)tSx5A)d27un8TT23hhHV4aXh)(6k7oaz8faxTJPirDyS9D(IvjE(oA8OMNVckmvgavOZEXk(1h8sf5sb2K1AtdWUNw62a4pC6E4PLUvaFmKAgZlBk)Lr57Rwgn1TxFTQjTD7znGXEK1qYQxFriVDlDT6Un3HZ5Ux4(oHAZzTDB)ZibCVkWozSvHu53oCX17dxuPUgDISg29teE5YRxZrXn3btHn4evPk1Aoqn0L1QW)Mtk1Ba6hnQ)066)dNkxCAKDEmscVUukHRq0Jcp7xh4j)kBsdKApUTqTmU4C)heqMyiNsOxbxnJGk4Au26wJS9Rf8CQxxP942c1gLMKd5uc9k4(XJQnGkvFCHEZWDFx9EKHNR9rvBDAHEZWDpxND0HNw8ZL8DDvxLqg0WWBhwRVMUemwNWQwqCh0kNtl0RGRwOxhKLPkvFCHEfCnesK6l0L3lh3IP33lAKTc41sFcT1V1EW4E9L6A439UpoE6i7TB1(1BDgdzv0azSDRNuZ8n1TmthtiKeFha6Qebgcl8if05qt1BO6oxPcz97RLgqnKgHAhNRaz1hBe8AB5iXZYL1NwUO2NdDdrhTekgP5M)ii9nb0JELWgzW254JitfxA)etKjJx2PjVVtPJBA3a5kLt4tv5Xs8RjN1U1duThlbuTKJfJaqTZciiy6r1EuySXeOXvDdV9ivRbhOrg1WKqI509AJWZ0OApkAVWRXH3EK2SWZ4WKqI58V6uuGnoCjKAo9PoH0ghUCYqMtVyDs88bErVnBX60YdKJGhnnUJnEKoZVoa)MoUoA1wttPdyV96UghUmw12nR0IPDYuZJ7yJN61DMHFlueew)nnLoG92R7AC4Yy1C6TAhcoHzc1yoTW)0b5F1OCTCZm1mhq(q1GG39UYFQ(20zcKUvlh67ExDyCIDz2D7jj3sYOluCteCLAq7amlxW1ScMEmYgqhB4F6G8VAuEZM(UA2rei4eB6tGX6m9Bhj3sYOluCteCLAWCP4WE)HApf(plBMyofosO4qdfZ5STFgBNA43giJPtYo)C8RbyyO)CQmaihuBP9wJbtz1wdSBrOlhC0oTOSQDA31tn8BdKBHoXWGAlT3Am0zTERs24GZpPgSFu8y0fVxJByROZmgtJjp(B3AEVG63mOP(N168(odgFHHL2Wtn0RS48UYEW4Z7WsvlRP97xFyBn1jSQKRtJKRJbYTzBmlCsxirWO6(kf1V17CSTTSk31(RO296VT0U6K73aA3RZ1UdWIu)JS6tJlQhvCnn39a7lTl847VZBt2ZXj3Fh(T7fVOKXldWETNpW0bL1Z(IjxlFPgVmy5eSMDtT7Dw59xShVr5mDZf39tuWnpqoaiimpqGviUVeVPatKVBJxM3QCtSVmE9e2vJC3p9h(dfILoaiy6WKVK1Y3a0aYU0Yji6L4p7pt(10(m7slQZM44A3gAxzPyoYk01k9qFhGNlj8C3B4vE3e1OqIYvVDR0JnwHzLXPvC4UqGUgiqY6PxH46lbUY4oicS4cksjanFL16acCPrqd3jUoGafNIAmczjjVOVeNwRRVZDTTugVrc)CxRUq7U1s7gkNAfT08UmY0E9c9os789sYDhfSmN2DUS6QPmb2J5sWEDb7Bw)KMln1x9IPrxAQUifCpyPGwvk(Qxxf6Qu0gPGH75NQ4WvuC4iimmh8N(tkKtcgZqahtfwxI3wQwq0NaQ9Gcv9iKhcvzi6q4Qn7hroA1JqQiuPq3HiwB2RTAaRkXRkNmcTzJ4nwdJZIrTkxFUPo53we9ln3TdZVUhuxwUYB8XqdiV8wSHyU6YEC7yaFXPGLvzNsACTQW1ytfiy055tbgO3xG1W4DRt4343cfS3we)1f(VeVjb2s)PG584x)35AmPjlVGR61QICWR5coQ3G7t)ZSNPDrzSUcKBNJEul0hI3sh67GZPGWm(PgsIanDNH6zQlR6za4FvyngPxlzFw909HtDS0zotxVAGG2UL(YrzgXrRvehfSK09qrypuY3ZwthANV0w9vRLLzuJV3dLrodcf7kdidzEp5(Oe8GvW7g(u(V3ySWr0neO1Tz02tEk3oU5PCOu6hiO0rhcAjFBFlthnemvbP5A3RDJS87wdofJ7CmXT00w8H49jufnMVlHJRgR5pvgvJM7o)F5npWluYzo(5jYp5ZqMcxk8QEDIJ0ycJJxmB5MK3mpMLWYD24mpeVO5(PzjEGwbOy1XH03pM5VsI6WXea)O8GVe)uKwePNdA30HinlYjUx)Zm(fLTNqSqfBep1gVMOu)UvV(gHe8mI40YlBGaaLVSyI1aOunNRtjI6Siw3joKrwZ5xlIjQef30jYVBR7MIWLur4wti)Dqr4Aqr4EikchcfHJbfH(TmOofHBngEukc3JPIGTIOljFvTKOsgzi5Vjo1zBAjLTFLIPNznSXfvB32NDzgapPMmQSAmDyv)YtDTT6O00LwA2g76MLMU1zGzjv1GUknDBT005RH0eNj7dpp5e4HVzQ2vSteOumvxvUazEFo4nWcOqG)zwhefB3wJ7IZQYcw9EFW(EyzUigOW24ZSuQV7VrzfNAyfNkwbtwTNKVQBDDnRH1kMnQzn)jUNcoDWrxZl)Q3zwJ4VbxdnJ)6x(lDesanKFaq(FjZpjcIIcXsrOUINjesv9jtGPhXVwO3g2JkzjlL7mw9MAkMco2Qx5SBDhdwu16(QM7bLH3chI6j1ptXC5t5hegwHf0TzhAlcd53zVfhh5X7A8rCF6AMfYtFr8abBNtAGuoDPvunAJ1mbSc61V70mPVLrfzMR9TQgK2NP)HDhGZvg(GUJ(HR)Qi2YC((nH8TYjK85j35T03djFBXbkO6Y7EN8btvVmbus9ylR90IZm(6MirQuRu4NSaN1sanBim9J2e4TebT31X0rJLRk8Q8Avl9s)EcB33(Nr9TFJ7HRMVz09m(1(72jdT6rvCemEOstLQRpPO1xS23HXPLV6LSeENkD7iWOv4F2F0v91CjBvx99DUWqXDophHqqxuFmX7r(fquqyREQeK1jQNjPE)Z2F5EoHFroekj5bcFFUXWbpTy4IHWI3MesQrXwUAIoYMC8kV8D6ndLkXvG2hTBXhx9jXUL4QFDHCZgALJp1rOhnG0UeDyHmgTv7gQqoDJnu9BiC0Dp8BZVo2IcSYVarSa3e)uzpvi3xCuslrlNgHpu0vb)ZyDP2N6ZJ9eyNyf3ionz22x1OS3zk)u70FxCZhB9gXvhWb(2Yexel8rTE7wNgIcV6XABfzXSr(v7BmD9bX3x6L1xBIdRC3JrTmwWPoFN0oltgl9Vg1tF)RE1T91TcBFPSd1eNQZzK4vvqdYcjjXzDg0GsUBF(HBF8e0BTzPMZeSforucLhAFFXn77DiHnifOaeAsvK2KNVeLSr6Ji8jrsqTHzV(g3jEk4OImUcPqKAMvP4eGYLdtUHaLOIYQ8aX3RqVyQG95Z47jr1qh)wPXh132yCA93BvrRIG8GMavMfe5h1oxMxiNRbipPK4cFCGLOKQEGrONxguwUhmYn19O0Tqf7AAXPsh6v7MlLmQDZukSl9PnSEeklKBpwPInrTyE0ZKSpQ0xDE7q16eBaEsXVPmLQL4YTxpNBVOBLiTAjvz)QigHy1VElhngSJf)guDbXz(JlboVacg(UKs4sBZ6YujVOKR143cQnVHn3W)e7M3DdFBXk6bPqPGuYHKMpkp4lsTzzqDgSHOR)kw8)0VjnBOA0IwY0j8(f53fSTglZ)eo)7tEZ4UbFZXQemN0oeifZ(clx(MDx)7vRPgVS6zvLHf)nTKTMou)mBQphPgQTGGMsUnER7dJCp2z5p0M6u8Qyfn9aPPF72ZEuV(69RzDvSNUJnX6XBGMTAwKqOGAqcOBai2D0xzGBjOeTyXetT38YoPO(6lxoackNQX)Odw(wNHvRvJwtqb0XS2TJDXqxZss5TOzAPv(nCChIcnR2lECAq8qMnWVHfoQRKuemnWTnu3NozvqVWU7Fam2NpJheSgZaWu(5sf)XuB4o1X6yiboaVRdP23DA733TqQouOHcRa0e76DTY(YhD))p]] )