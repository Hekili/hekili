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

local debugstack = debugstack

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


-- If SDT is talented and time - variable.next_tyrant is less than 2 seconds from the Tyrant prep start window and SDT is off-cooldown.
-- actions+=/call_action_list,name=tyrant,if=talent.summon_demonic_tyrant&(time-variable.next_tyrant)<=(variable.tyrant_prep_start+2)&cooldown.summon_demonic_tyrant.up
-- If SDT is talented and SDT's remains_expected is less than the length of a Tyrant prep start window (12)
-- actions+=/call_action_list,name=tyrant,if=talent.summon_demonic_tyrant&cooldown.summon_demonic_tyrant.remains_expected<=variable.tyrant_prep_start
-- actions.tyrant+=/variable,name=next_tyrant,op=set,value=time+13+cooldown.grimoire_felguard.ready+cooldown.summon_vilefiend.ready,if=variable.next_tyrant<=time

spec:RegisterPhasedVariable( "next_tyrant",
    -- Default value.
    function()
        return 14 + talent.grimoire_felguard.rank + talent.summon_vilefiend.rank
    end,
    -- Value update function; include all conditions here.
    function( current, default )
        if not talent.summon_demonic_tyrant.enabled then return default end

        if current == nil then return default end

        local update = time + 13
            + ( talent.grimoire_felguard.enabled and cooldown.grimoire_felguard.remains < cooldown.summon_demonic_tyrant.remains_expected and 1 or 0 )
            + ( talent.summon_vilefiend.enabled  and cooldown.summon_vilefiend.remains  < cooldown.summon_demonic_tyrant.remains_expected and 1 or 0 )

        if abs( current - update ) > 16 then
            return update
        end

        -- #1: list-if: talent.summon_demonic_tyrant.enabled and time - current <= 12 + 2 and cooldown.summon_demonic_tyrant.remains <= gcd.max
        if ( current - time <= 12 + 2 and cooldown.summon_demonic_tyrant.remains <= gcd.max or
            -- #2: list-if: talent.summon_demonic_tyrant.enabled and cooldown.summon_demonic_tyrant.remains_expected <= 12
            cooldown.summon_demonic_tyrant.remains_expected <= 12 ) then
            -- value: time + 14 + cooldown.grimoire_felguard.ready + cooldown.summon_vilefiend.ready

            if current <= time then
                return update
            end

            -- I'm going to manipulate this to keep the window from collapsing prematurely due to downtime.
            local demon = buff.dreadstalkers.remains

            if demon > 4 then
                if buff.grimoire_felguard.up then demon = demon and min( demon, buff.grimoire_felguard.remains ) or buff.grimoire_felguard.remains end
                if buff.vilefiend.up         then demon = demon and min( demon, buff.vilefiend.remains         ) or buff.vilefiend.remains         end

                if demon > 4 then
                    return time + demon
                end
            end
        end

        return current
    end,
"reset_precast", "advance_end", "runHandler" )


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


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 8,

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


spec:RegisterPack( "Demonology", 20231115, [[Hekili:T3t7YnooY9S46kRrA8yzrkjVZCNLU6UDZDz3kzZwr7E5FwIwIYMzOiviPShxLl9SNUbjibaBacAjnFS1MC5IhrGUB0FHUB0G8wNB)1BNTYlZ)2F2DG7qhhNX9h8Exx33F7SSN36F7STEl)O39WFe5Tb(V)b)nXrXHX3)m(ONdJ9wHGinExYs4XpKLTn9pF1v3hK9WU76VmEZvPbB2f6LfehTmXBDg(VxE1DHX3D1QeV7JJwhgC)dzx5hDFqK)vld9stNVjE1Uq)0R82gE1tEjHXl)y)LB3E7S72feM9Jr3EhnvpeOKT(lHF(6RbIjy1k)8X6NU82z4yV0X5sNr7x0z)cNX)59l(pdIIt2Vy3weCP7xSojEZ(fZc28993)t7)j(ug8DWy3V4FSlj7bFy8od67wol5roMnYFXlB5d5JR6XdE)LU5a6VTA1(fE7xKLee9r)mHH8Dx68E2q(ngW3ViXBzGxOiL9xGPIZ)xFoXlkdX1Qvbr3VFrQFwg8hYq7Ag0(rG77VXpkdb1UcqtTyXPmwIawhNVGD6pwDklUexk)V7sbQilgaCkm(z72a6i7x8Vcc9xh4hbu6tp4d)qamQNIJEd8)BLFO3Z8vGwiXu2UlomJdbp4Vscs)4(fXRH)Vh9tw6TDlBTNty)qIV3Quyr(r)Ku5fLBoJpmm(jjiJWK9BH(p6hME1tGQB8UmrIRciomG8FdZ(rFyD9p8bU53d)DemsuSSmBhYG5CloJokgG3Z(i2E0li07UqFb4E9LUxxaxyfbdAliQ8Y2L4xjJx6LYOZ7dwkpZXf6t5SUFj(ju9CwW2hqrWUuW0fy8rvaA7dEP()fuZ75ConGmG(nH1CEVeRfwi44w7fgY4(XRxlqwJVC4GCToqk9Z)cqaPiVag2US0Gv(kuZ(fD)R9ExHm)Fp(FcJhMhyOvsabHObqquqkytDNpOr6Ndy)pTnir0ceWnNzMRNiQJm7bVKvP5lBVhJdqntabSNX0icwIIte4WcD5hjH7VPrhFdmpPXpi3o(xZnXj8wGJXL2udyj3H6GF03pN038Cft7PGOvmfwuBONa8gXnD)(qFVOCwEgmN0a09lQhGR8sEFI)wVeV8hXeesGAWhY1S2UneWn41(sG4ZqT(TjbXjbzptTKgXDa(VfHA57x8pbp2HXap2VuDS0cRKNpllb8)Nbcxq)cug9xjdYrmq(3b3BO2Df(bv3GuG(tlyD8LgdrcGyixH83Q557DiBzz4UCpOahYpjcnHF0ljGzNg5)PS5zLgeHll2nR)TZcdsZsXT)YFm8x)mBdvF2AF1T)9BNTeiuFas3oReGB9ZMNR3UFX09lUF5Q(B8(0(fxW8FGqoLPDnFvo7Pa59rBH5zbB8z7ErcUBea3B3Vy0TZYHiSxOx0Q5XRNF)UWvEr3MbBrQqP8rclXW55)J54c82zGDjmvyUlxHlqlwtdmsIgxL(FYF5Um)IfkWt6cw87a3l8XTeTZa9)i2sKdRh8GFAo6rVoeQpD0W4Tc8QESXv8pZLRZZJ3bwPBsr21W)GDzb7kpyfgdBKgg224cg3V3zlk6balzCRDo8nolGlZjPqKJCTwocUuxgVdD6c8bxgFOCfifLx(sOtXZUpjytmWGMV2p8(DW(9kp)r(o2f)EpoKrA9r)5(r(BcWmbaSoC)IxEH8j50t(MvakrNRf5PKcRY0G7J6xSQ4y4S8iTqTbi2WGnBdJtz8gopQ6Na(Y3PNVubKAl1CIIjTqQFq1QoYhZBz(24eGMv4i10heKBvAdiv9ETuvDaXcGIPLoIZHpRMiavFqo8zL8YcnLQHuYgLHHSkacNEcYsTR5EI(HGqLNNYIugxCFW8ItvVXkolTEkKSC480hycmG)mML8JgoOwzHZaT0Ri8NaWVcgseldk6JxPRmHoHrOOWIyzxW)H12Y44qCHQXPeMIragUgSUDgk7ClABnhgLmDgTQgXIeTEm0SkgP8ARCygw74Jkx5YpUCfxyrAshLdknoY4pUUyP3RH97ON9ZcQrs7LjauJbsRjY3(C)6(x0Y51XeRjaz8q1WIOnBRTL3RM3Q3Bzo0RJ1sEqfaf1BetWWLTDp8FFfaOT(GsdKgjMFvptzE4OgheFOR4vLrhBrC3eTB5aRICv7uieI7IJ2L2plWpzOZC3TlffXQbYKVln9S6DALgWc(5LHqOwEj37d5uMhVOJ(WJmTHRIFvLqkBxqJIs7IWHibmynmq)ERoS4zO2jty1HBRnBnwm45OhFJjtNpmr1s3bny5PF3dZaJ2xOExHMHg1gB6Djuhwdhyy3C95xyfr1MWZRdqNbkgYaKslQRJ5qABwx2m5RQTPpmvc4iM)cDW4z46zT3UWQc8WhM3NatL40uz14CvTkEXJX7sMVX7(GLkJtvjkg29aC)eSUA2CJn2FvKKDU8zoKwPCiqL)hLL5f8Kc6HLa7Cqu5cBfEdyY((XC3AwnLPWuCZ30dDeuKPb(JodQTvyHvomOGO7tRfGsq0JXF0FEUSliA9oKBpFq)v74LKSm93ZSltlKffUdYtlmfys2fjuXCegUo6Ipbc71cXgTqJbD6exRco5VQFh3ESSdeDdpO)4gc9s3gnIkrvoVP8CC8ws1dJ1(LMLBQwQCOIPg35vpdr1Z3bZqowl2UY2dAxYfbLOenZaXOzAjlr1bEZSKbkRpAv1gx1flLwsUQ7c0m5ABAiwMRHPCLfjBiNbIYp0m5YGDH7S8Y2uXSjkzLdViGC(Thm81bl9xnhdXovOGvIuhUtiz9gAhbkUN71nqPU2tPmfivqKxtfBbb5IvnYZx)I99nSyhDGuQAyTntP2TZyruwY7Pxg5H4tnLlggKHRIfSAAx0vUO5KphlpV6XPRFMsEnaaWiM05RJtec(1q5oapn9vyB5I2cREiKqDXT6wjzUdOr)KpcHhrDybgQuWrc9HXXRMVExYZKjLFSr3AWVmdLnKz7XbBErl9HSp8arlOxuLdQak5dTOhCCa7MW4mX)TfNKxXGN7mhvUt5XRs88nErSEdPCpCdl0ovDguMJ4b)MhtmVGdggsz9kmGLYXuJADH9rXZe3VoUC7)Gx6CUvxrIavpS0CSuWivYaocQoc)jSDM6PaiN(i7CUqYatuK4mrQ6E8kIuxfrQBRePUnisDF1Iu3MfPed5WePo6fPoMePoVkrQBDrQRDIu14GoeRuAdXwBOAegDTq9Nw7Pagf8PUMTN70K(LD(eKcF14()yK0(lz97Z08T67XkTHAyGhIjNr(I9wDgHrxl0LnkJjKpegNTw(qBGF4YhJhONXfAJM99SIN34gccNnaQAeW6WgIaGC11HsrpVzheT2UOeVh9X(pCE62GOvyiUwfgrUSQKWulwzFmgYNZxi0bzuK3MwYajED9luLFl79tD4(yQ51ejrDDOtLPR9MQhUzwnhhijQpOudXbouT695)JI2ZsOBLQoSbex6djn3i9gwjB4Rwf0E((fFyCEcDdivDkgawO8XcMsfz9L4hCFeEkzmv1ONLl4aDoYgpJnx9LB3o)lLK6N7CZ4CMYjBOcISJDOu5YuTUu8APwCA5iAKYY1zSoxbJelYJCbJLpJ1ZWU4py1CwJw33B1Q0(ylzxa8lvFQqnW5br1ujYies)Hy9ujwT07svLeC1FIuTxQ19qpd6Un2GjgKrc4sRC5BkrJ1T9LLnNJn63G)7pyZXVouFpEruyzstpYnRa8F9qECqKp2w1Ylai9Hwg5QubYnQFWwK4sg3BlzhmwppdQ7Q9YGY5hCONzI4r6UP2XBpu6GHVduBsxgVl5EFauBWk9PE2V67hH2jBnfhRCWxfmGAJtScZ8fW9LxBdgXQVuOTqM7owVzVWJjpZefd769JHUGzf60w8waMeSn)3XRMe)6IGxpj2v0A323LFn1(rCwRWyTIWRefGYN7VFX)fSJ8WlhLvCv28cYGbKXUCs3CDkEdYwd)ECu1DhJnLXzxqnJ3tmdPOoFkEolhryjKkKNzj7dxALzEs1BXiFXqe0StSiozd7c3WoTbEz7NKVbChYqpDQ55cNkEtL8tyOuFG0Fv7kYS3gJoQ(kZvKUkDRKMGSbXVLIYx21VZd1mJX7df(xphVJFf8EWdZFgY9iT4M0vKQm7Yx9dXi7a)l2DdeV1D4kbvU5x8UUo)k8u82Y9)eeI3GZOWN7DBTUyHStiTkQZPkxaQwfzmQB)DLAq0n)SYVMJaUSN9mi)1p6RjYCHbOlqzxH4Nun(MW7SXmlAhMIccnuFSNKS5Zooy2qQPdvd5ssnu4M5I3c0N85ADBy3lZShWl2ymEBcXZStXqqT3r1EUKt5RN6kC3WLQNzwWk7LHsYoLsYQQeDdRh36XXyPBg6JLCwEdIohBrS8aSx5NViJJ3m)ouQu6XkNZ0xwaajEop)g3ZWy9zxPxoHtzCGPCg7JqH5i1qunjmzoVWnBt9w3KOJUnCZLygO6PL7Cvx2x0Vj1f2F7Y9BthYQ1yGQbiRKjiAuJvvsi)3U)EGpLYkTA(LNMFTZbr(VmlxIVmEd)IIdJ6hATDBHStmExX2(uYD6ibxO)EsyRpi8ZOv3R4YQTi7O20ZX2U)5fs31iYoDwF0Oj(RbbWd4teuoaMfBExlMCLP(hhIdgu1UZRHlJn9r34fkC(aY55ds1YoZrIZcHUnFfQCZQyhRKcMetVw0uWnHPZ2cvbfn30poUI98srIx4BaayxlVKCR8wd01ESwTTcUYXgJaT9nwQWXiGhlnEUqipk324l8dds7VjijbCsacQ1jWAyxcK6uwmeCss8tPutiDBCqykoHi)qi8LKDPsIc5dcb5zTV3tfoDid0)xMh2sEMBl4zUv8S23CQYsPKD3988NEWpemiG)7qkj5tpeKc54IN0xq0sVeWK3FEWYcOxtEw0Vfi11(ErvMF0a152AQZvK6AFRNkZxmCESu8L8ZVhr8RONsLxZTcZUIywtdE24vVOCvK(C0YBTTJW0C6OvNZZ5nUlB1yNu2WqwpLZBc)5WSxbBU4kuWAqD((hmUMMMn1wUMBZCnDNPS7xyUgj(TKR9AVMpfSeEJv10XXlQWPNVkvllnC9gz8xT3qFD1JLrbad2RaRlmStr5ijiiutHFAstRrvKkXxjnaRPk1981tvocuLSq3PuKZ6Bbd9UllEVNccxXkRBT6rOnjnSob6JN3q37w)TnqUqoVbkygevnIuPgnzEGg6AxvSqhTE()7Sh9ty1NM)27B0TZEc2WIfZ4SFfFVFb8My8nHgRWIVj3Y8ny5g))2bHjVcZRdjxVDqyeESMGAjK819Sxfv)hS31u4lRRVpocFHQHp(nMkCfaz8fJLXXWl8ZBWQy(PEL45904rn7hfuO7aAvHo7Tw3NFWlD6lkWM8IXudWdpT0TgWF409OtlDRa(yiGnM)P08xsFVPYmAQBNUmNbINa9lVCwdyStUdeLBjvVoDfH8lVOa5Iu4VPOmqV19c3ZfUp)94l3VEiVRKiVkg84tK8B)pr4xQ4Ab3ohtAuDp6oMg2GQwx4)rQwpxGBb078ZDChCZK3pUJ2NoDI74EV8c(dWF6mOxNhPpCSEDk3LUPR770bDoZYvjJJOJ6ns8FPP9szZPsl1i0RDAJ10U0CAKQWxZwRhjQx7g3hjQ)7oPuVMWbo8nMQr2fHVk0N)LWvikzHN9LbEY3xOAGS2JTfQLwNfM4eqMyiNsO3mCD6VnjEzFVONNVcI9N7)GGpRBC2r)2JhPKKQb)AkZv8hT6iUg0r(CbphZ6C1ESTqTrTcYHCkHEZW11sDb9JZo63E8ywN7dhvBYtl0BgUVwVPhz45o4OQ1DAHEZW9v6V4OdpNJ66(0c9MH7RZgWwQ(1b9k4wlTPdcUQu9Xf6vWTw5eoizOkvFCHEfC1ecU6Lu6nYXXQ7omvJSvaFTmtrBTBg0xnjUZp)dJNoAWlVu7xVXzCVoDBGmE5f5gRyQBzzn0Hqs8DaORIfCARA4WAo6KMV8bEqJd6gy1weD0swBOMcuQ22RkWxxlUxd8MtL9iYOo1z1ouxATvnMOk9xVPgTfOh)AvPXE44JOAbwDqSjYQcw2csVPv1fSwvBkDMJzRWQik(1Pim0FzgH7CYbjT2pciGFizVcqVbRuBYZMO8QHCCb(bq1WZsH9McdYms5Yd74JKdyfWQqUjANpGJjGpa6fpsrtKBXZpIGT9eBtT0ebISyk2JCI2JIgL0ducr12yQmYxl8kOzqhBeOtczbO15zGCihxGFauTjpcAh2XhjhWkG27aXaoMa(aOxs)d1F(reSTNyTWhIkISyk2JCBC7yyGsisFPRjA3rANBeJYEuOTBjPXLPHlHu9Lh1M1LUrzpkSFD14WLqQ(csAQnmPzMMgUesD0xWUwH1ghUmwTOWBgosfQXCAH)PdYFXO8A1esx3o2PRjeC(5L)K5M9CYGxEXYHE(5MW4KbLvv6vsYwsgTHIBIGRed1k3sPbxZcy6XiRaDSH)PdYFXO8Mv9DRPhrGGtSQpbgnP6BhjBjz0gkUjcUsmyXra0kbSQc0Xg(2azBpsw7o63dhpOsG(J(vp8TotrZPIEmWGUW21c7x7EJNA4BdKTtUAB7QC4451P)0IcC(k1FAbgSv)P22aNPnEcDEBF5f9(Hn7iwNjBV321P)4l0ysapvZf5OxVPDnh1JoHSkgDAeJofyKZ))mY3U6ZoF7QtaFRFXPASog)w5ZU1(EautXxgh53UFu)e1jzFI2ZVNh7xGVE1W7VsgFCS3OsRJ3fjn6vRWbVYlZ7oVu))CXN(FSoj4XP8JStsbH)iziJNtcE7UJxhuDbXt7xEwlxm5k5BI97cwpH1LVd6Cw5LUUZzmBuDx369)efClIWaaccZdeyC2(7W741KA3d73fVDskGi2LjAIJRnarUVLLHa7gABdquSnkMUj)BV8cXtlQik5ZESQEJKpNvzpYNGAhIpOPQAPmwIYr1gwIljlHkKHk8wViXKpJKLOwStYNiZsAUqFkJ9azjLxU5A6je1VsrAOTKtTHaC1qaKfqtzTFuia(1yMIbOTstTbbU0iWCPSAdcY93x4Uiyn3LZ7QUwJtg0F87a(YQaeMtAUEgF2RadD9mAdxW9G5c1sT9ZEY40P22gUa)kgRYhCf5docCHtuqvMIfvtwMkb6q5w2Y4RmfwQMuuuqo12KMc1IwejE3EXioyWt5gdp1P4M0v7McFZqAOwErErqwDB7UzCNU4nbgu74T5QwDhHBYRkqWy3kMcmq(NftXFt8ZGP4Vtgq0YvQAILIMg((mkQW2GHeFgvA1FBDL40ZfR(q4jhny(n2K8vN40)AEajQ35YExE)YvVfDbY1efVWN0xNZtbHP9TPSebQ76N2rx709zybyhb29mDK4lVCg1Bb0EhlsFaJUQlA1qPa50sehTvHxXxQsx8nH99iF1hpD4GI7fS6Rg4E6rn(QWvg5miW3jfqgU49KBuxNl492RUVfFVAmwSwU5Ac062mA7ipLBg38uouk99eu6OdbTKVS9KPd78BFJ7aHGn47BG)AxDBnoXTu7v(fLNGx5A9ynhD8lF(4QXQ)nrB1Of5evFW)ENWN7giWkGhR97vdO1dBL2rANNBCDLGB5xYVdfsLFK(ouaj)937qHg)7eKcBd)GXWJHLXe1gvkv8Q55xbEE1szDecnKhD00b4B5aQFVxNUAHe8mIqqlYHvaG5HVYvWetCTuPRGdrepnpk(jo9eZ5MmY1PtKFpp2oMTljZ2vlZ2TnmBxnmB3dHz7qWSD0WSRF3ymXSD7jkMobmBMMT(eUmQA3Co7uAwucq20GLAxsD)o6LRAnxAmt3c6P8lD2u3b9AjVZLM3zLMQ(8vnPOOLLlY7CBpVZ90W7sRVtKETgtMi9mWXm5hJwIMh4OUYCzC7KoNvLgFXZL)YUPCHU0TvtlmbFLgtnI2g0EFL6H7)P)0FIF4kiQlYd1)tz(jrWg24O4XQjMAkt3Gmc8oe)kN7oSdv0(9Qjeap96fPYJ1zG6LY7g3XG1LrZidxAlnVuIefpQFnHY5pLF)4yjhxpiMHdeHH8BhA(5tD8UOJe34WMxcfXFdeJDouak40fRCNULdxB((G0xBgXcEGKR6I4(3Lzk4mwvlAepfZAFAPqyx)t4gaIl18PBddkGob6Yxfw)bd3ed)0O62M3zzfdM6t9LW2V0pMMF9zJHrYhiRGxb4A9ISGGM(HbYf5vEd3susV3qHEOI7VPxpSZzk)KDs4lU(dwhzeREsAfgmIM4Bbud7Ku9yRlJNuE8b1(QHj(4QVjx2YxnfjepoHm6RmDDdqjFj2B2nf3BUUYn7NjJMaIpz)IVo)8CjYtk)mBX2jx8B11uHctHJccWN4RZfH9A13rRsbm13NRjoduQe4uNMSc)IzIP3ssRX3X3eduO(I95TYCiGDLEZxAZU3t57EpYYiiM68DGiRcntgl9VgvwP)QB6UaKR)HnQ61WjSFMSE4eNQtAH4eRAGxiXjoR1GgeYT7JhvnBg2jBw(zFbseM6l(sEy2g(AV0r7x6LBMmSNAu63mQ0wNl(QQy9uNoIki3mQ8ebfKlIMJ1LwtRKwII9Bg2tO6hKfLNIJk9fC6Ri(NIDp7RfvNUAb0uWdADwoKiRiV2cge16hOg5y20iBFl)BdgYMFnFdL(kI9tYlRI(G6l1eYF7(Qz3Q9ib5P6qSdBzOV1ft25m9cPd0b5rcCCHVHrs4UQVje6tI(LvpadTtDVS60N7a6PshBMDZTzUIUzkf0w9Pn0mcRNyIDyLkYg1AdrptYMQPUr5ndvphknWtk6pLPuzzlvQTIyFBzf3QSj85NFVy8Lv)6nf210QV(FYF5oiimSKtxqCaPOM)B5qOsFvEEugz8fBVlkx11wV13QNAvvm)lmUoklcojlOm0icIGUic51a)Br(SCH7TEbN4TmWl83Pl5TXzFRA204AtRRZV5wQeloj3PifVmExuw5hza5eHqkPJMYwv9SQQCH)wTuvMoSE9YnNHrdPXliPK7tsHzvV)ZyNN3WbuNGs1sPMCGu13Un4g1PB9M9YurqPB3lSwMAO5EnZsieqnWbQRai2(PxQz1sqj1cCrmXy9MDsHi1vozAckNQLIOdO8gNHv2QrB15hVwaETRs2AA5osk3IoXJw43q1KfzA9SN940a7Hm05VIzoQwskmMgwTnu1KwPvqBy3(VflsFQyiO5QKtx(8YqyNcwctP5DBGu1n015EtD6qLHpNJQK4PAvaDkoSQdN3Ca(DhsTJ8u73rMZVhku40kanzGzNU3oZBx2dXj3oBwWMVN9v462)))]] )