-- WarlockAffliction.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARLOCK' then
    local spec = Hekili:NewSpecialization( 265, true )

    spec:RegisterResource( Enum.PowerType.SoulShards, {
        -- regen effects.
    }, setmetatable( {
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
            if k == 'count' or k == 'current' then return t.actual

            elseif k == 'actual' then
                t.actual = UnitPower( "player", Enum.PowerType.SoulShards )
                return t.actual

            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        nightfall = 22039, -- 108558
        drain_soul = 23140, -- 198590
        deathbolt = 23141, -- 264106

        writhe_in_agony = 22044, -- 196102
        absolute_corruption = 21180, -- 196103
        siphon_life = 22089, -- 63106

        demon_skin = 19280, -- 219272
        burning_rush = 19285, -- 111400
        dark_pact = 19286, -- 108416

        sow_the_seeds = 19279, -- 196226
        phantom_singularity = 19292, -- 205179
        vile_taint = 22046, -- 278350

        darkfury = 22047, -- 264874
        mortal_coil = 19291, -- 6789
        demonic_circle = 19288, -- 268358

        shadow_embrace = 23139, -- 32388
        haunt = 23159, -- 48181
        grimoire_of_sacrifice = 19295, -- 108503

        soul_conduit = 19284, -- 215941
        creeping_death = 19281, -- 264000
        dark_soul_misery = 19293, -- 113860
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3498, -- 196029
        adaptation = 3497, -- 214027
        gladiators_medallion = 3496, -- 208683

        soulshatter = 13, -- 212356
        gateway_mastery = 15, -- 248855
        rot_and_decay = 16, -- 212371
        curse_of_shadows = 17, -- 234877
        nether_ward = 18, -- 212295
        essence_drain = 19, -- 221711
        endless_affliction = 12, -- 213400
        curse_of_fragility = 11, -- 199954
        curse_of_weakness = 10, -- 199892
        curse_of_tongues = 9, -- 199890
        casting_circle = 20, -- 221703
    } )

    -- Auras
    spec:RegisterAuras( {
        agony = {
            id = 980,
            duration = function () return 18 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
            type = "Curse",
            max_stack = function () return ( talent.writhe_in_agony.enabled and 15 or 10 ) end,
            meta = {
                stack = function( t )
                    if t.down then return 0 end
                    if t.count >= 10 then return t.count end

                    local app = t.applied
                    local tick = t.tick_time

                    local last_real_tick = now + ( floor( ( now - app ) / tick ) * tick )
                    local ticks_since = floor( ( query_time - last_real_tick ) / tick )
                    
                    return min( 10, t.count + ticks_since )
                end,
            }
        },
        burning_rush = {
            id = 111400,
            duration = 3600,
            max_stack = 1,
        },
        corruption = {
            id = 146739,
            duration = function () return ( talent.absolute_corruption.enabled and ( target.is_player and 24 or 3600 ) or 14 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        dark_pact = {
            id = 108416,
            duration = 20,
            max_stack = 1,
        },
        dark_soul_misery = {
            id = 113860,
            duration = 20,
            max_stack = 1,
        },
        demonic_circle = {
            id = 48018,
            duration = 900,
            max_stack = 1,
        },
        demonic_circle_teleport = {
            id = 48020,
        },
        drain_life = {
            id = 234153,
            duration = function () return 5 * haste end,
            max_stack = 1,
            tick_time = function () return haste end,
        },
        drain_soul = {
            id = 198590,
            duration = function () return 5 * haste end,
            max_stack = 1,
            tick_time = function () return haste end,
        },
        eye_of_kilrogg = {
            id = 126,
        },
        fear = {
            id = 118699,
            duration = 20,
            type = "Magic",
            max_stack = 1,
        },
        grimoire_of_sacrifice = {
            id = 196099,
            duration = 3600,
            max_stack = 1,
        },
        haunt = {
            id = 48181,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        mortal_coil = {
            id = 6789,
            duration = 3.001,
            type = "Magic",
            max_stack = 1,
        },
        nightfall = {
            id = 264571,
            duration = 12,
            max_stack = 1,
        },
        phantom_singularity = {
            id = 205179,
            duration = 16,
            max_stack = 1,
        },
        ritual_of_summoning = {
            id = 698,
        },
        seed_of_corruption = {
            id = 27243,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        shadow_embrace = {
            id = 32390,
            duration = 10,
            type = "Magic",
            max_stack = 3,
        },
        shadowfury = {
            id = 30283,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        siphon_life = {
            id = 63106,
            duration = function () return 15 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 3 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        soul_leech = {
            id = 108366,
            duration = 15,
            max_stack = 1,
        },
        soul_shards = {
            id = 246985,
        },
        summon_darkglare = {
            id = 205180,
        },
        unending_breath = {
            id = 5697,
            duration = 600,
            max_stack = 1,
        },
        unending_resolve = {
            id = 104773,
            duration = 8,
            max_stack = 1,
        },
        unstable_affliction = {
            id = 233490,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
            copy = "unstable_affliction_1"
        },
        unstable_affliction_2 = {
            id = 233496,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_3 = {
            id = 233497,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_4 = {
            id = 233498,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        unstable_affliction_5 = {
            id = 233499,
            duration = function () return ( pvptalent.endless_affliction.enabled and 14 or 8 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
            type = "Magic",
            max_stack = 1,
        },
        active_uas = {
            alias = { "unstable_affliction_1", "unstable_affliction_2", "unstable_affliction_3", "unstable_affliction_4", "unstable_affliction_5" },
            aliasMode = 'longest',
            aliasType = 'debuff',
            duration = 8
        },
        vile_taint = {
            id = 278350,
            duration = 10,
            type = "Magic",
            max_stack = 1,
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
        curse_of_tongues = {
            id = 199890,
            duration = 10,
            type = "Curse",
            max_stack = 1,
        },
        curse_of_weakness = {
            id = 199892,
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
            duration = 6,
            type = "Magic",
            max_stack = 5,
        },
        nether_ward = {
            id = 212295,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        soulshatter = {
            id = 236471,
            duration = 8,
            max_stack = 5,
        },


        -- Azerite Powers
        inevitable_demise = {
            id = 273525,
            duration = 20,
            max_stack = 50,
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


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        if sourceGUID == GUID and spellName == "Seed of Corruption" then
            if subtype == "SPELL_CAST_SUCCESS" then
                action.seed_of_corruption.flying = GetTime()
            elseif subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" then
                action.seed_of_corruption.flying = 0
            end
        end
    end )


    spec:RegisterGear( 'tier21', 152174, 152177, 152172, 152176, 152173, 152175 )
    spec:RegisterGear( 'tier20', 147183, 147186, 147181, 147185, 147182, 147184 )
    spec:RegisterGear( 'tier19', 138314, 138323, 138373, 138320, 138311, 138317 )
    spec:RegisterGear( 'class', 139765, 139768, 139767, 139770, 139764, 139769, 139766, 139763 )
    
    spec:RegisterGear( 'amanthuls_vision', 154172 )
    spec:RegisterGear( 'hood_of_eternal_disdain', 132394 )
    spec:RegisterGear( 'norgannons_foresight', 132455 )
    spec:RegisterGear( 'pillars_of_the_dark_portal', 132357 )
    spec:RegisterGear( 'power_cord_of_lethtendris', 132457 )
    spec:RegisterGear( 'reap_and_sow', 144364 )
    spec:RegisterGear( 'sacrolashs_dark_strike', 132378 )
    spec:RegisterGear( 'sindorei_spite', 132379 )
    spec:RegisterGear( 'soul_of_the_netherlord', 151649 )
    spec:RegisterGear( 'stretens_sleepless_shackles', 132381 )
    spec:RegisterGear( 'the_master_harvester', 151821 )


    spec:RegisterStateFunction( "applyUnstableAffliction", function( duration )
        for i = 1, 5 do
            local aura = "unstable_affliction_" .. i

            if debuff[ aura ].down then
                applyDebuff( 'target', aura, duration or 8 )
                break
            end
        end
    end )


    local summons = {
        [18540] = true,
        [157757] = true,
        [1122] = true,
        [157898] = true
    }

    local last_sindorei_spite = 0

    spec:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )
        if not UnitIsUnit( unit, "player" ) then return end

        local now = GetTime()

        if summons[ spellID ] then
            if now - last_sindorei_spite > 25 then
                last_sindorei_spite = now
            end
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        soul_shards.actual = nil
    
        local icd = 25

        if now - last_sindorei_spite < icd then
            cooldown.sindorei_spite_icd.applied = last_sindorei_spite
            cooldown.sindorei_spite_icd.expires = last_sindorei_spite + icd
            cooldown.sindorei_spite_icd.duration = icd
        end

        if debuff.drain_soul.up then            
            local ticks = debuff.drain_soul.ticks_remain
            if pvptalent.rot_and_decay.enabled then
                for i = 1, 5 do
                    if debuff[ "unstable_affliction_" .. i ].up then debuff[ "unstable_affliction_" .. i ].expires = debuff[ "unstable_affliction_" .. i ].expires + ticks end
                end
                if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 1 end
                if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 1 end
            end
            if pvptalent.essence_drain.enabled and health.pct < 100 then
                addStack( "essence_drain", debuff.drain_soul.remains, debuff.essence_drain.stack + ticks )
            end
        end
        
        if buff.casting_circle.up then
            applyBuff( "casting_circle", action.casting_circle.lastCast + 8 - query_time )
        end
    end )


    spec:RegisterStateExpr( "target_uas", function ()
        return buff.active_uas.stack
    end )

    spec:RegisterStateExpr( "contagion", function ()
        return max( debuff.unstable_affliction.remains, debuff.unstable_affliction_2.remains, debuff.unstable_affliction_3.remains, debuff.unstable_affliction_4.remains, debuff.unstable_affliction_5.remains )
    end )

    
    

    -- Abilities
    spec:RegisterAbilities( {
        sindorei_spite_icd = {
            name = "Sindorei Spite ICD",
            cast = 0,
            cooldown = 25,
            gcd = "off",

            hidden = true,
            usable = function () return false end,
        },

        agony = {
            id = 980,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "agony", nil, max( azerite.sudden_onset.enabled and 4 or 1, debuff.agony.stack ) )
            end,
        },
        

        --[[ banish = {
            id = 710,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        burning_rush = {
            id = 111400,
            cast = 0,
            cooldown = 0,
            gcd = function () return buff.burning_rush.up and "off" or "spell" end,
            
            startsCombat = true,

            talent = "burning_rush",
            
            handler = function ()
                if buff.burning_rush.down then applyBuff( "burning_rush" )
                else removeBuff( "burning_rush" ) end
            end,
        },
        

        casting_circle = {
            id = 221703,
            cast = 0.5,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            pvptalent = "casting_circle",

            startsCombat = false,
            texture = 1392953,
            
            handler = function ()
                applyBuff( "casting_circle", 8 )
            end,
        },
        

        --[[ command_demon = {
            id = 119898,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        corruption = {
            id = 172,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "corruption" )
            end,
        },
        

        --[[ create_healthstone = {
            id = 6201,
            cast = 3,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        },
        

        create_soulwell = {
            id = 29893,
            cast = 3,
            cooldown = 120,
            gcd = "spell",
            
            spend = 0.05,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        curse_of_fragility = {
            id = 199954,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",

            pvptalent = "curse_of_fragility",            
            
            startsCombat = true,
            texture = 132097,
            
            usable = function () return target.is_player end,
            handler = function ()
                applyDebuff( "target", "curse_of_fragility" )
                setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )
                setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )
            end,
        },
        

        curse_of_tongues = {
            id = 199890,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",

            pvptalent = "curse_of_tongues",
            
            startsCombat = true,
            texture = 136140,
            
            handler = function ()
                applyDebuff( "target", "curse_of_tongues" )
                setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
                setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )
            end,
        },
        

        curse_of_weakness = {
            id = 199892,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",

            pvptalent = "curse_of_weakness",
            
            startsCombat = true,
            texture = 615101,
            
            handler = function ()
                applyDebuff( "target", "curse_of_weakness" )
                setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
                setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )
            end,
        },
        

        dark_pact = {
            id = 108416,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,

            talent = "dark_pact",
            
            handler = function ()
                spend( 0.2 * health.current, "health" )
                applyBuff( "dark_pact" )
            end,
        },
        

        dark_soul = {
            id = 113860,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,

            talent = "dark_soul_misery",
            
            handler = function ()
                applyBuff( "dark_soul_misery" )
                stat.haste = stat.haste + 0.3
            end,

            copy = "dark_soul_misery"
        },
        

        deathbolt = {
            id = 264106,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,

            talent = "deathbolt",
            
            handler = function ()
                -- applies shadow_embrace (32390)
            end,
        },
        

        demon_armor = {
            id = 285933,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "demon_armor",
            
            startsCombat = false,
            texture = 136185,
            
            handler = function ()
                applyBuff( "demon_armor" )
            end,
        },
        

        --[[ demonic_circle = {
            id = 48018,
            cast = 0.5,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        },
        

        demonic_circle_teleport = {
            id = 48020,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        },
        

        demonic_gateway = {
            id = 111771,
            cast = 2,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.2,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]


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
                if debuff.dispellable_magic.down then return false, "no dispellable magic aura" end
                return true
            end,

            handler = function()
                removeDebuff( "dispellable_magic" )
            end,
        },
        

        drain_life = {
            id = 234153,
            cast = 5,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                removeBuff( "inevitable_demise" )
            end,
        },
        

        drain_soul = {
            id = 198590,
            cast = 5,
            cooldown = 0,
            gcd = "spell",

            channeled = true,
            prechannel = true,
            breakable = true,
            breakchannel = function () removeDebuff( "target", "drain_soul" ) end,

            spend = 0,
            spendType = "mana",
            
            startsCombat = true,

            talent = "drain_soul",
           
            handler = function ()
                applyDebuff( "target", "drain_soul" )
                applyBuff( "casting", 5 * haste )
                channelSpell( "drain_soul" )
            end,
        },
        

        --[[ enslave_demon = {
            id = 1098,
            cast = 3,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        },
        

        eye_of_kilrogg = {
            id = 126,
            cast = 2,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        fear = {
            id = 5782,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "fear" )
            end,
        },
        

        grimoire_of_sacrifice = {
            id = 108503,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            
            usable = function () return pet.exists and buff.grimoire_of_sacrifice.down end,
            handler = function ()
                applyBuff( "grimoire_of_sacrifice" )
            end,
        },
        

        haunt = {
            id = 48181,
            cast = 1.5,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,

            talent = "haunt",
            
            handler = function ()
                applyDebuff( "target", "haunt" )
            end,
        },
        

        health_funnel = {
            id = 755,
            cast = 5,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            
            handler = function ()
            end,
        },
        

        mortal_coil = {
            id = 6789,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,

            talent = "mortal_coil",
            
            handler = function ()
                applyDebuff( "target", "mortal_coil" )
                gain( 0.2 * health.max, "health" )
            end,
        },
        

        nether_ward = {
            id = 212295,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "nether_ward",
            
            startsCombat = false,
            texture = 135796,
            
            handler = function ()
                applyBuff( "nether_ward" )
            end,
        },
        

        phantom_singularity = {
            id = 205179,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,

            talent = "phantom_singularity",
            
            handler = function ()
                applyDebuff( "target", "phantom_singularity" )
            end,
        },
        

        --[[ ritual_of_summoning = {
            id = 698,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = 0,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            
            handler = function ()
            end,
        }, ]]
        

        seed_of_corruption = {
            id = 27243,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "soul_shards",
            
            startsCombat = true,
            velocity = 30,
            
            usable = function () return dot.seed_of_corruption.down end,
            handler = function ()
                applyDebuff( "target", "seed_of_corruption" )
            end,
        },
        

        shadow_bolt = {
            id = 232670,
            cast = 2,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            velocity = 20,

            notalent = "drain_soul",
            cycle = function () return talent.shadow_embrace.enabled and "shadow_embrace" or nil end,
            
            handler = function ()
                if talent.shadow_embrace.enabled then
                    addStack( "shadow_embrace", 10, 1 )
                end
            end,
        },
        

        shadowfury = {
            id = 30283,
            cast = 1.5,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "shadowfury" )
            end,
        },
        

        siphon_life = {
            id = 63106,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,

            talent = "siphon_life",
            
            handler = function ()
                applyDebuff( "target", "siphon_life" )
            end,
        },
        

        soulshatter = {
            id = 212356,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",
            pvptalent = "soulshatter",

            startsCombat = true,
            texture = 135728,
            
            usable = function () return buff.active_uas.stack > 0 or active_dot.agony > 0 or active_dot.corruption > 0 or active_dot.siphon_life > 0 end,
            handler = function ()
                local targets = min( 5, max( buff.active_uas.stack, active_dot.agony, active_dot.corruption, active_dot.siphon_life ) )

                applyBuff( "soulshatter", nil, targets )
                stat.haste = stat.haste + ( 0.1 * targets )

                gain( targets, "soul_shards" )

                active_dot.agony = max( 0, active_dot.agony - targets )
                if active_dot.agony == 0 then removeDebuff( "target", "agony" ) end

                active_dot.corruption = max( 0, active_dot.corruption - targets )
                if active_dot.corruption == 0 then removeDebuff( "target", "corruption" ) end

                active_dot.siphon_life = max( 0, active_dot.siphon_life - targets )
                if active_dot.siphon_life == 0 then removeDebuff( "target", "siphon_life" ) end
            end,
        },
        

        soulstone = {
            id = 20707,
            cast = 3,
            cooldown = 600,
            gcd = "spell",
            
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
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,

            toggle = "interrupts",
            
            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },
        

        summon_darkglare = {
            id = 205180,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            
            handler = function ()
                summonPet( "darkglare", 20 )
            end,
        },


        summon_imp = {
            id = 688,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "imp" ) end,
        },
        

        summon_voidwalker = {
            id = 697,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "voidwalker" ) end,
        },

        
        summon_felhunter = {
            id = 691,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            essential = true,

            bind = "summon_pet",

            usable = function ()
                if pet.alive then return false, "pet is alive"
                elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
                return true
            end,
            handler = function () summonPet( "felhunter" ) end,

            copy = { "summon_pet", 112869 }
        },
        

        summon_succubus = {
            id = 712,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "succubus" ) end,
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
        

        unending_resolve = {
            id = 104773,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            toggle = "defensives",

            startsCombat = true,
            
            handler = function ()
                applyBuff( "unending_resolve" )
            end,
        },
        

        unstable_affliction = {
            id = 30108,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "soul_shards",
            
            startsCombat = true,
            
            handler = function ()
                applyUnstableAffliction()
                if azerite.dreadful_calling.enabled then
                    gainChargeTime( "summon_darkglare", 1 )
                end
            end,
        },
        

        vile_taint = {
            id = 278350,
            cast = 1.5,
            cooldown = 20,
            gcd = "spell",
            
            spend = 1,
            spendType = "soul_shards",
            
            startsCombat = true,
            
            handler = function ()
                applyDebuff( "target", "vile_taint" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "battle_potion_of_intellect",
        
        package = "Affliction",
    } )


    spec:RegisterPack( "Affliction", 20190102.1050, [[dC02JbqiLepIsP6sukLnHOgfrLtruAvef9ka1SiQ6wukXUq6xuQAykP6yIsldq6zkPyAkPuxdr02ikOVruiJtjLCokLuRJOanpeP7Pu2NsWbPuswiG4HicOjIiOUiIGOtIiqzLukMjIaPBIiqStLqdfrqAPefWtPKPQK0xreG9kYFPyWO6WKwmrESGjJYLH2SO6Zc1Ob40sTAebQEnLkZwv3gHDR43sgUqooIGWYv55eMovxhOTRe9DLkJhrOZRu16jkuZxuSFqNYMwnzXuhtlc01ZARxp76aLMD912wtszuYY3hHjRinyNgJjRrjWKLTkp)7G31KSI09FPS0QjlrbEbmzbW9iHmO92h3oaqjAOiSx0eGV6DnHtZD7fnrWEPVKSxkxTfgU0(ORY7hf2VAJhqZA)QanRHeGEFfSZyRYZ)o4DnurteswsG97KGnjPKftDmTiqxpRTE9SRduA21xBBnjLHjlregslcuzijtwaAgdNKuYIHIqYY2HCBvE(3bVRbYjbO3xb7G2y7qoa3JeYG2BFC7aaLOHIWErta(Q31eon3Tx0eb7L(sYEPC1wy4s7JUkVFuypj0dLb0MjSNeQmGHeGEFfSZyRYZ)o4DnurteG2y7qUn6aQ3EihOYd5aD9S2Ai3wG8SRldUM1H2aTX2HCsGa0jgfYGqBSDi3wGCBfJHmi3kc)hYjbTc2rH2y7qUTa52kgdzqojmUSapiNeenUduOn2oKBlqUmasulrgK76fJUPZPuk0gBhYTfi3wXibhu4qEKYy9ed5l1RvPhH8VI7afAJTd52cKldGKqa2hc5KW1QcihmcYRbYD9IrhYZRdYjHr1bivVd5Yj6jGq(H5hkaa5Ff3biVfqoRZZXdhhY7CiNeijSaY1dHCwluPhzYstwrxL3pMSSDi3wLN)DW7AGCsa69vWoOn2oKdW9iHmO92h3oaqjAOiSx0eGV6DnHtZD7fnrWEPVKSxkxTfgU0(ORY7hf2tc9qzaTzc7jHkdyibO3xb7m2Q88VdExdv0ebOn2oKBJoG6ThYbQ8qoqxpRTgYTfip76YGRzDOnqBSDiNeiaDIrHmi0gBhYTfi3wXyidYTIW)HCsqRGDuOn2oKBlqUTIXqgKtcJllWdYjbrJ7afAJTd52cKldGe1sKb5UEXOB6CkLcTX2HCBbYTvmsWbfoKhPmwpXq(s9Av6ri)R4oqH2y7qUTa5YaijeG9HqojCTQaYbJG8AGCxVy0H886GCsyuDas17qUCIEciKFy(Hcaq(xXDaYBbKZ68C8WXH8ohYjbsclGC9qiN1cv6rMSuOnqBSDiNessedGoYGCjmVoeYdfHK6qUeg3JGc52QqaJCbKp1yla0Jih8HCn4DnciVMFpfAJg8Ugbn6WqriP(w(Rc7G2ObVRrqJomuesQd8M95vXG2ObVRrqJomuesQd8M9kymboU6DnqB0G31iOrhgkcj1bEZEbibrnMi0H2ObVRrqJomuesQd8M9Xxtu9HMk3i0W15DaLVZ3C9XXPXxtu9HMk3i0W15DaP4OspYG2ObVRrqJomuesQd8M9IrJeak3iC1fqB0G31iOrhgkcj1bEZ(OY7AG2ObVRrqJomuesQd8M9cezMk3eQ7aJ8Ug578nre(VX1lgDbvGiZu5MqDhyK31y0cxyBnqB0G31iOrhgkcj1bEZEak44qB0G31iOrhgkcj1bEZEbaLv7ms17Y35BR46JJtbOGJtXrLEKrweH)BC9IrxqfiYmvUju3bg5DngTqsxd0gOn2oKtcjjIbqhzqoUeV9qU3eiK7aqixdEDqElGCDP2Vk9ifAJg8UgXMic)38vWoOnAW7AeaVzpdxwGNHqJ7a0gn4DncG3SFPETk9O8JsGBGc0iqKj)s9bXnxFCCQO2zCaOrGitqXrLEKrweH)BC9IrxqfiYmvUju3bg5DngTWf2wdWN2mdUehN2ZsWFWtLEKcgLjJRpoov0raQX8DosXrLEKrweH)BC9IrxqfiYmvUju3bg5DnlSrsGpTzgCjooTNLG)GNk9ifmktgre(VX1lgDbvGiZu5MqDhyK31SW2Ab8PnZGlXXP9Se8h8uPhPGrqBSDixdExJa4n7xQxRspk)Oe4wKYy9elFfTjqx(L6dIBAW7AOcakR2zKQ3PijIbqhnEtGYuLX41osdQiOSEInb9vI23tXrLEKbTX2HCn4DncG3SFPETk9O8JsGBrkJ1tS8v02Hc0LFP(G4wCGjFNVPYy8AhPbveuwpXMG(kr77P4OspYilNRpooLDApgrb(uCuPhzzY46JJtzO6aKQ3P4OspYihQ6z1UHYq1bivVtpKq7rq6wCGjl0gn4DncG3SFPETk9O8JsGBrkJ1tS8v0MaD5xQpiUjNCQmgV2rAqfbL1tSjOVs0(EkoQ0JmYY56JJtzN2JruGpfhv6rwMmU(44ugQoaP6DkoQ0JmYHQEwTBOmuDas170dj0EeKUfhyYkl54altg50G31qfauwTZivVtrsedGoA8MaLPkJXRDKgurqz9eBc6ReTVNIJk9itwzH2ObVRra8M9l1RvPhLFucCJq7X1Emcu(L6dIBIi8FJRxm6cQarMPYnH6oWiVRXOfs6wwGD9XXP7U2bGMEmACn7P4OspYa21hhNQsI6bD0eQ7aJ8UgkoQ0JmzcuGLZ1hhNU7AhaA6XOX1SNIJk9iJSRpoovu7moa0iqKjO4OspYilIW)nUEXOlOcezMk3eQ7aJ8UgJw4cavwGLZ1hhNk6ia1y(ohP4OspYiVIRpoonCig1tSHHQdGIJk9iJ8kU(44u2P9yef4tXrLEKjlWN2mdUehN2ZsWFWtLEKcgbTrdExJa4n7xQxRspkp0gn4DncG3SpO)B0G31y(w4YpkbUfQ6z1UraTrdExJa4n7zN2JruGV8944DGrUj(lj93YkFaG2Zww5d7dpAC9IrxSLv(oFZ1lgDQ3eOXldRrs3IdmYIc8nca6XiLKqB0G31iaEZEak44Y35BIi8FJRxm6cQarMPYnH6oWiVRXOfs6gqb(0MzWL440Ewc(dEQ0JuWiOnAW7AeaVzVaKGOgdtp7IF9q578nw5unUM9uVd21tmzw50qDhyK31q9oyxpXKLtcmpNQbVxIgqvqfUgSBJKzYikW3iaOhBBDzjl3kU(440ia64fHr0tm4Rx77P4OspYYKHvoncGoErye9ed(61(E6HeApczjl3kU(44ugQoaP6DkoQ0JSmzcv9SA3qzO6aKQ3PhsO9iiDloWYKzLqvpR2nugQoaP6D6HeApImzer4)gxVy0fubImtLBc1DGrExJrlCHSaFAZm4sCCAplb)bpv6rkyKSqB0G31iaEZEgQoaP6D578TqvpR2nubibrngME2f)6H0dj0EeKLBfxFCCQOJauJ57CKIJk9iltgw5urhbOgZ35ifmswYSYPACn7Pcxd2TWw21jZkNQX1SNYap17AwyTiZkNgQ7aJ8Ugkyezre(VX1lgDbvGiZu5MqDhyK31y0c3Yc8PnZGlXXP9Se8h8uPhPGrqB0G31iaEZEnUM9Yh2hE046fJUylR8D(2HeApcs3IdmG1G31qfauwTZivVtrsedGoA8Maj76fJo1Bc04LH14cRf0gn4DncG3ShCeUk9OrZZ)o4DnY35BReQX14UgYUEXOt9ManEzyns62AbTrdExJa4n7zN2JruGV8H9HhnUEXOl2YkFqNa(MoFZ7GDcZHeApKss578nxFCCQaGYQDgKq60asXrLEKrEPETk9iLq7X1EmcKmdLaZZPcakR2zqcPtdi9qcThbzgkbMNtfauwTZGesNgq6HeApcs3IdmzcuOnAW7AeaVzVaGYQDgP6D5d7dpAC9IrxSLv(oFZ1hhNkaOSANbjKonGuCuPhzKxQxRspsj0ECThJajZqjW8CQaGYQDgKq60aspKq7rqMHsG55ubaLv7miH0PbKEiH2JG0nKeXaOJgVjqzcuG9txIVXBcK8kAW7AOcakR2zKQ3P9yY)ogGdTrdExJa4n7JaOJxegrpXGVETVx(oFZBcCH1qsYUEXOt9ManEzynUqwzOmfr4)gaQWrOnAW7AeaVz)Y(rJR94Y35BEtGlKLKKD9IrN6nbA8YWACHTSRdTrdExJa4n7bhHRspA088VdExJ8D(2kl1RvPhPGc0iqKrwuGVraqp2gjH2ObVRra8M9cezMk3eQ7aJ8Ug578TL61Q0JuqbAeiYilkW3iaOhBJKqB0G31iaEZ(G(VrdExJ5BHl)Oe4gRCb0gn4DncG3SpcGoErye9ed(61(E578nVjqs3wdjH2ObVRra8M9l7hnU2JlFNV5nbsAwscTrdExJa4n7z6zNruGV8D(wOQNv7gQaKGOgdtp7IF9q6HeApcsZUozw50ia64fHr0tm4Rx77PhsO9iYKX1lgDQ3eOXldRrsb66ahhyzYiIW)nUEXOlOcezMk3eQ7aJ8UgJw4czb(0MzWL440Ewc(dEQ0JuWiOnAW7AeaVzVeEc8SRNyOnAW7AeaVzFq)3ObVRX8TWLFucCteHddpb0gn4DncG3SpO)B0G31y(w4YpkbUL3)JNaAd0gn4DncAOQNv7gXwu5DnY35BY56JJtz6zNruGVHOf4TNIJk9iJCOQNv7gQaKGOgdtp7IF9qkye5qvpR2nuME2zef4tbJKntMqvpR2nubibrngME2f)6HuWOmzC9IrN6nbA8YWAK01So0gn4DncAOQNv7gbWB2dkqt7iHq(oFBLqvpR2nubibrngME2f)6HuWi578TqvpR2nubibrngME2f)6H0dj0EeliJwptgVjqJxgwJKc01ZKro5KaZZPAW7LObufuHRb72izMmIc8nca6X2wxwYYTIRpooncGoErye9ed(61(EkoQ0JSmzcv9SA3qJaOJxegrpXGVETVNEiH2JqwYYTIRpooLHQdqQENIJk9iltMqvpR2nugQoaP6D6HeApcs3IdSmzwju1ZQDdLHQdqQENEiH2JqwYReQ6z1UHkajiQXW0ZU4xpKEiH2JqwOnAW7Ae0qvpR2ncG3SpVpu6RIjFNVTsOQNv7gQaKGOgdtp7IF9qkye0gn4DncAOQNv7gbWB2l9vXm5G3E578Tvcv9SA3qfGee1yy6zx8RhsbJG2aTrdExJGYKmhMFOaWMOJauJ57Cu(Vh0eyBzjP8D(MCSYPIocqnMVZr6HeApcBJvov0raQX8DoszGN6DnYs6MCSYPACn7PhsO9iSnw5unUM9ug4PExJSKLJvov0raQX8DospKq7ryBSYPIocqnMVZrkd8uVRrws3KJvonu3bg5Dn0dj0Ee2gRCAOUdmY7AOmWt9UgzjZkNk6ia1y(ohPhsO9iiLvov0raQX8DoszGN6DnYmlDnqB0G31iOmjZH5hkaa8M9ACn7L)7bnb2wwskFNVjhRCQgxZE6HeApcBJvovJRzpLbEQ31ilPBYXkNgQ7aJ8Ug6HeApcBJvonu3bg5Dnug4PExJSKLJvovJRzp9qcThHTXkNQX1SNYap17AKL0n5yLtfDeGAmFNJ0dj0Ee2gRCQOJauJ57CKYap17AKLmRCQgxZE6HeApcszLt14A2tzGN6DnYmlDnqB0G31iOmjZH5hkaa8M9H6oWiVRr(Vh0eyBzjP8D(MCSYPH6oWiVRHEiH2JW2yLtd1DGrExdLbEQ31ilPBYXkNQX1SNEiH2JW2yLt14A2tzGN6DnYswow50qDhyK31qpKq7ryBSYPH6oWiVRHYap17AKL0n5yLtfDeGAmFNJ0dj0Ee2gRCQOJauJ57CKYap17AKLmRCAOUdmY7AOhsO9iiLvonu3bg5Dnug4PExJmZsxd0gOnAW7Aeuw5InbImtLBc1DGrExJ8D(gRCAOUdmY7AOhsO9iiDtdExdvGiZu5MqDhyK31qdQWnEtGa7nbA8YiaOhd41McuzkxwBX1hhNgoeJ6j2Wq1bqXrLEKjZ1PzjPSKfr4)gxVy0fubImtLBc1DGrExJrlCHT1a8PnZGlXXP9Se8h8uPhPGra76JJt3DTdan9y04A2tXrLEKrEfw5ubImtLBc1DGrExd9qcThb5v0G31qfiYmvUju3bg5Dn0Em5FhdWH2ObVRrqzLlaEZEnUM9Yh2hE046fJUylR8D(MRpoonCig1tSHHQdGIJk9iJSg8EjAyLt14A2tQmKSRxm6uVjqJxgwJlKDDYYDiH2JG0T4altMqvpR2nubibrngME2f)6H0dj0EelKDDYYDiH2JGusMjZkQmgV2rAKomKOdMEwwb17AONo2r(W8dfauPhLvwOnAW7Aeuw5cG3SxJRzV8H9HhnUEXOl2YkFNVTIRpoonCig1tSHHQdGIJk9iJSg8EjAyLt14A2t6Ar21lgDQ3eOXldRXfYUoz5oKq7rq6wCGLjtOQNv7gQaKGOgdtp7IF9q6HeApIfYUoz5oKq7rqkjZKzfvgJx7inshgs0btplRG6Dn0th7iFy(HcaQ0JYkl0gn4DnckRCbWB2l6ia1y(ohLpSp8OX1lgDXww578n50G3lrdRCQOJauJ57CK01YwC9XXPHdXOEInmuDauCuPhz2Iic)346fJUGkQDghaAeiYegTqzj76fJo1Bc04LH14czxN8H5hkaOspswUvoKq7rqweH)BC9IrxqfiYmvUju3bg5DngTWTSzYeQ6z1UHkajiQXW0ZU4xpKEiH2Jybrb(gba9yYudExdfCeUk9OrZZ)o4DnuKeXaOJgVjqzH2ObVRrqzLlaEZ(qDhyK31iFyF4rJRxm6ITSY35BIi8FJRxm6cQarMPYnH6oWiVRXOfs6Aa(0MzWL440Ewc(dEQ0JuWiGD9XXP7U2bGMEmACn7P4OspYil3HeApcs3IdSmzcv9SA3qfGee1yy6zx8RhspKq7rSq21jFy(HcaQ0JYs21lgDQ3eOXldRXfYUo0gOnAW7Ae08(F8eBGJWvPhnAE(3bVRr(Vh0eyBzjP8D(wOQNv7gkdvhGu9o9qcThbPBXbMmbkzre(VX1lgDbvGiZu5MqDhyK31y0c3Yc8PnZGlXXP9Se8h8uPhPGrKdv9SA3qfGee1yy6zx8RhspKq7rSaqxhAJg8UgbnV)hpbWB2h0)nAW7AmFlC5hLa3ysMdZpuaq(oFZ1hhNYq1bivVtXrLEKrweH)BC9IrxqfiYmvUju3bg5DngTWTSaFAZm4sCCAplb)bpv6rkyez5yLt14A2tpKq7rqkRCQgxZEkd8uVRrMRtLrKmtgw50qDhyK31qpKq7rqkRCAOUdmY7AOmWt9UgzUovgrYmzyLtfDeGAmFNJ0dj0EeKYkNk6ia1y(ohPmWt9UgzUovgrszjhQ6z1UHYq1bivVtpKq7rq6Mg8UgQgxZEACGjZ1MCOQNv7gQaKGOgdtp7IF9q6HeApIfa66qB0G31iO59)4jaEZ(G(VrdExJ5BHl)Oe4gtYCy(HcaY35BU(44ugQoaP6DkoQ0JmYIi8FJRxm6cQarMPYnH6oWiVRXOfULf4tBMbxIJt7zj4p4PspsbJihQ6z1UHkajiQXW0ZU4xpKEiH2JG0nrb(gba9yYudExdvJRzpnoWawdExdvJRzpnoWK5AilhRCQgxZE6HeApcszLt14A2tzGN6DnYmBMmSYPH6oWiVRHEiH2JGuw50qDhyK31qzGN6DnYmBMmSYPIocqnMVZr6HeApcszLtfDeGAmFNJug4PExJmZkl0gn4DncAE)pEcG3SNHQdqQEx(oFlu1ZQDdvasquJHPNDXVEi9qcThXcBRzDGJdSmzcv9SA3qfGee1yy6zx8RhspKq7rSq21EDOnAW7Ae08(F8eaVzVaGYQDgP6D578njW8CkrTejWXPGrKLaZZPthdWZ1)PhsO9iG2ObVRrqZ7)Xta8M9ACn7LVZ3KaZZPe1sKahNcgrEf5C9XXPIocqnMVZrkoQ0JmYYfD4stCGrZs14A2to6WLM4aJcuQgxZEYrhU0ehy01q14A2lBMmrhU0ehy0SunUM9YcTrdExJGM3)JNa4n7fDeGAmFNJY35BsG55uIAjsGJtbJiVICrhU0ehy0SurhbOgZ35i5OdxAIdmkqPIocqnMVZrYrhU0ehy01qfDeGAmFNJYcTrdExJGM3)JNa4n7d1DGrExJ8D(MeyEoLOwIe44uWiYReD4stCGrZsd1DGrExd5vC9XXPQKOEqhnH6oWiVRHIJk9idAJg8UgbnV)hpbWB2ZoThZ35O8D(MCsG550EWLTRspAyirlqQW1GDlSTwK0wKteH)BC9IrxqfiYmvUju3bg5DngTqB50MzWL440Ewc(dEQ0JuWOfaQSYeORtwUqvpR2nugQoaP6D6HeApIfqsedGoA8MaZKzfxFCCkdvhGu9ofhv6rMSKLlu1ZQDdncGoErye9ed(61(E6HeApIfqsedGoA8MaZKzfxFCCAeaD8IWi6jg81R99uCuPhzYswUqvpR2nuME2zef4tpKq7rSasIya0rJ3eyMmR46JJtz6zNruGVHOf4TNIJk9itwYYfQ6z1UHUSF04Apo9qcThXcijIbqhnEtGzYSIRpooDz)OX1ECkoQ0JmzjhQ6z1UHkajiQXW0ZU4xpKEiH2JybKeXaOJgVjqGZUEMmsG550EWLTRspAyirlqQW1GDlSM1j76fJo1Bc04LH1iPBzxxwOnAW7Ae08(F8eaVzpafCCOnAW7Ae08(F8eaVzp70EmIc8LVhhVdmYnXFjP)ww5da0E2YkFpoEhyKVLv(W(WJgxVy0fBzLVZ3C9IrN6nbA8YWAK0T4adAJg8UgbnV)hpbWB2ZoThJOaF5d7dpAC9IrxSLv(aaTNTSY3JJ3bg5MoFZ7GDcZHeApKss57XX7aJCt8xs6VLv(oFZ1hhNkaOSANbjKonGuCuPhzKxQxRspsj0ECThJajVcdLaZZPcakR2zqcPtdi9qcThb0gn4DncAE)pEcG3SNDApgrb(Yh2hE046fJUylR8baApBzLVhhVdmYnD(M3b7eMdj0EiLKY3JJ3bg5M4VK0FlR8D(MRpoovaqz1odsiDAaP4OspYiVuVwLEKsO94ApgbcTrdExJGM3)JNa4n7zN2JruGV8944DGrUj(lj93YkFaG2Zww57XX7aJ8TSqB0G31iO59)4jaEZEbaLv7ms17Yh2hE046fJUylR8D(MRpoovaqz1odsiDAaP4OspYiVuVwLEKsO94ApgbsEfgkbMNtfauwTZGesNgq6HeApcYRObVRHkaOSANrQEN2Jj)7yao0gn4DncAE)pEcG3Sxaqz1oJu9U8H9HhnUEXOl2YkFNV56JJtfauwTZGesNgqkoQ0JmYl1RvPhPeApU2JrGqB0G31iO59)4jaEZEbaLv7ms17qBG2ObVRrqfr4WWtSbocxLE0O55Fh8Ug578TqvpR2nubibrngME2f)6H0dj0EeKUjkW3iaOhtMijIbqhnEtGKLBfxFCCkdvhGu9ofhv6rwMmHQEwTBOmuDas170dj0EeKUjkW3iaOhtMijIbqhnEtGYcTrdExJGkIWHHNa4n7d6)gn4DnMVfU8JsGB59)4jKVZ3Klu1ZQDdvasquJHPNDXVEi9qcThbPEtGgVmca6XKPCYqBruGVraqpMSzYeQ6z1UHkajiQXW0ZU4xpKcgjlzVjqJxgwJleQ6z1UHkajiQXW0ZU4xpKEiH2JaAJg8UgbveHddpbWB2lqKzQCtOUdmY7AKVZ3wQxRspsbfOrGidAJg8UgbveHddpbWB2docxLE0O55Fh8Ug578TvwQxRspsbfOrGiJ8krhU0ehy0SubibrngME2f)6HKLZ1hhNYq1bivVtXrLEKrou1ZQDdLHQdqQENEiH2JG0nKeXaOJgVjqYROYy8AhPbveuwpXMG(kr77P4OspYYKrorb(gba9ylSrsYIi8FJRxm6cQarMPYnH6oWiVRXOfskqZKruGVraqp2cBaLSic)346fJUGkqKzQCtOUdmY7AmAHlSbuzj76fJo1Bc04LH14cRnWijIbqhnEtGKfr4)gxVy0fubImtLBc1DGrExJrlClBMmUEXOt9ManEzyns62AbmsIya0rJ3eOmff4Bea0Jjl0gn4DncQichgEcG3ShCeUk9OrZZ)o4DnY35BRSuVwLEKckqJarg5qnUg31q6wqfUXBce4L61Q0J0iLX6jgAJg8UgbveHddpbWB2docxLE0O55Fh8Ug5d7dpAC9IrxSLv(oFBLL61Q0JuqbAeiYil3kU(44ugQoaP6DkoQ0JSmzcv9SA3qzO6aKQ3PhsO9iwWBc04LraqpwMmIc8nca6XwiRSKLBfxFCC6Y(rJR94uCuPhzzYikW3iaOhBHSYsouJRXDnKUfuHB8MabEPETk9inszSEIjl3kQmgV2rAqfbL1tSjOVs0(EkoQ0JSmzKaZZPbveuwpXMG(kr77PhsO9iwWBc04LraqpMSjRL4j6Aslc01ZARxp76aLMD91KS2P30tSizrcgruDoYGCzeKRbVRbY)w4ck0MKLc6aQlzz1eKatwFlCrA1KftYCy(HcaPvtlMnTAYchv6rwcijln4DnjlrhbOgZ35yYkCTJxRjl5GCw5urhbOgZ35i9qcThbKBBqoRCQOJauJ57CKYap17AGCzHCs3GC5GCw5unUM90dj0EeqUTb5SYPACn7PmWt9UgixwiNmKlhKZkNk6ia1y(ohPhsO9iGCBdYzLtfDeGAmFNJug4PExdKllKt6gKlhKZkNgQ7aJ8Ug6HeApci32GCw50qDhyK31qzGN6DnqUSqoziNvov0raQX8DospKq7ra5Kc5SYPIocqnMVZrkd8uVRbYLjKNLUMK13dAcSKvwsM80IanTAYchv6rwcijln4DnjlnUM9jRW1oETMSKdYzLt14A2tpKq7ra52gKZkNQX1SNYap17AGCzHCs3GC5GCw50qDhyK31qpKq7ra52gKZkNgQ7aJ8Ugkd8uVRbYLfYjd5Yb5SYPACn7PhsO9iGCBdYzLt14A2tzGN6DnqUSqoPBqUCqoRCQOJauJ57CKEiH2JaYTniNvov0raQX8DoszGN6DnqUSqoziNvovJRzp9qcThbKtkKZkNQX1SNYap17AGCzc5zPRjz99GMalzLLKjpT4AsRMSWrLEKLasYsdExtYku3bg5DnjRW1oETMSKdYzLtd1DGrExd9qcThbKBBqoRCAOUdmY7AOmWt9UgixwiN0nixoiNvovJRzp9qcThbKBBqoRCQgxZEkd8uVRbYLfYjd5Yb5SYPH6oWiVRHEiH2JaYTniNvonu3bg5Dnug4PExdKllKt6gKlhKZkNk6ia1y(ohPhsO9iGCBdYzLtfDeGAmFNJug4PExdKllKtgYzLtd1DGrExd9qcThbKtkKZkNgQ7aJ8Ugkd8uVRbYLjKNLUMK13dAcSKvwsM8KNSyyUc(EA10IztRMS0G31KSer4)MVc2LSWrLEKLasYtlc00Qjln4DnjlgUSapdHg3HKfoQ0JSeqsEAX1KwnzHJk9ilbKK1s9bXKLRpoovu7moa0iqKjO4OspYGCYqUic)346fJUGkqKzQCtOUdmY7AmAHq(cBq(AGCGH8tBMbxIJt7zj4p4PspsbJG8mzGCxFCCQOJauJ57CKIJk9idYjd5Ii8FJRxm6cQarMPYnH6oWiVRbYxydYjjKdmKFAZm4sCCAplb)bpv6rkyeKNjdKlIW)nUEXOlOcezMk3eQ7aJ8UgiFHniFTGCGH8tBMbxIJt7zj4p4PspsbJswAW7Aswl1RvPhtwl1ZmkbMSafOrGil5Pfx70QjlCuPhzjGKSQOKLa9KLg8UMK1s9Av6XK1s9bXKLCqUCqUkJXRDKgurqz9eBc6ReTVNIJk9idYjd5Yb5U(44u2P9yef4tXrLEKb5zYa5U(44ugQoaP6DkoQ0JmiNmKhQ6z1UHYq1bivVtpKq7ra5KUb5XbgKllKllKtgYJdmiptgixoixdExdvaqz1oJu9ofjrma6OXBceYLjKRYy8AhPbveuwpXMG(kr77P4OspYGCzHCztwl1ZmkbMSIugRN4KNwKKPvtw4OspYsajzTuFqmzjIW)nUEXOlOcezMk3eQ7aJ8UgJwiKt6gKNfYbgYD9XXP7U2bGMEmACn7P4OspYGCGHCxFCCQkjQh0rtOUdmY7AO4OspYGCzc5afYbgYLdYD9XXP7U2bGMEmACn7P4OspYGCYqURpoovu7moa0iqKjO4OspYGCYqUic)346fJUGkqKzQCtOUdmY7AmAHq(cqoqHCzHCGHC5GCxFCCQOJauJ57CKIJk9idYjd5Ra5U(440WHyupXggQoakoQ0JmiNmKVcK76JJtzN2JruGpfhv6rgKllKdmKFAZm4sCCAplb)bpv6rkyuYsdExtYAPETk9yYAPEMrjWKfH2JR9yeyYtlkdtRMS0G31KSwQxRspMSWrLEKLasYtlkJsRMSWrLEKLasYsdExtYkO)B0G31y(w4jRVfUzucmzfQ6z1UrK80IRvA1KfoQ0JSeqswAW7AswSt7XikWpzf2hE046fJUiTy2Kv4AhVwtwUEXOt9ManEzync5KUb5XbgKtgYff4Bea0Jb5Kc5KmzfaO9KSYMS6XX7aJCt8xs6NSYM80I260QjlCuPhzjGKScx741AYseH)BC9IrxqfiYmvUju3bg5DngTqiN0nihOqoWq(PnZGlXXP9Se8h8uPhPGrjln4Dnjlak44jpTy21tRMSWrLEKLasYkCTJxRjlw5unUM9uVd21tmKtgYzLtd1DGrExd17GD9ed5KHC5GCjW8CQg8EjAavbv4AWoiFdYjjKNjdKlkW3iaOhdY3G81HCzHCYqUCq(kqURpooncGoErye9ed(61(EkoQ0JmiptgiNvoncGoErye9ed(61(E6HeApcixwiNmKlhKVcK76JJtzO6aKQ3P4OspYG8mzG8qvpR2nugQoaP6D6HeApciN0nipoWG8mzG8vG8qvpR2nugQoaP6D6HeApciptgixeH)BC9IrxqfiYmvUju3bg5DngTqiFbiplKdmKFAZm4sCCAplb)bpv6rkyeKlBYsdExtYsasquJHPNDXVEyYtlMnBA1KfoQ0JSeqswHRD8AnzfQ6z1UHkajiQXW0ZU4xpKEiH2JaYjd5Yb5Ra5U(44urhbOgZ35ifhv6rgKNjdKZkNk6ia1y(ohPGrqUSqoziNvovJRzpv4AWoiFHnip76qoziNvovJRzpLbEQ31a5la5RfKtgYzLtd1DGrExdfmcYjd5Ii8FJRxm6cQarMPYnH6oWiVRXOfc5BqEwihyi)0MzWL440Ewc(dEQ0JuWOKLg8UMKfdvhGu9EYtlMfOPvtw4OspYsajzPbVRjzPX1SpzfU2XR1K1HeApciN0nipoWGCGHCn4DnubaLv7ms17uKeXaOJgVjqiNmK76fJo1Bc04LH1iKVaKVwjRW(WJgxVy0fPfZM80IzxtA1KfoQ0JSeqswHRD8AnzTcKhQX14UgiNmK76fJo1Bc04LH1iKt6gKVwjln4DnjlWr4Q0Jgnp)7G31K80Izx70QjlCuPhzjGKS0G31KSyN2JruGFYkSp8OX1lgDrAXSjRGob8nDEYY7GDcZHeApKsYKv4AhVwtwU(44ubaLv7miH0PbKIJk9idYjd5l1RvPhPeApU2JrGqoziNHsG55ubaLv7miH0PbKEiH2JaYjd5mucmpNkaOSANbjKonG0dj0EeqoPBqECGb5YeYbAYtlMLKPvtw4OspYsajzPbVRjzjaOSANrQEpzfU2XR1KLRpoovaqz1odsiDAaP4OspYGCYq(s9Av6rkH2JR9yeiKtgYzOeyEovaqz1odsiDAaPhsO9iGCYqodLaZZPcakR2zqcPtdi9qcThbKt6gKJKigaD04nbc5YeYbkKdmK7NUeFJ3eiKtgYxbY1G31qfauwTZivVt7XK)Dmapzf2hE046fJUiTy2KNwmRmmTAYchv6rwcijRW1oETMS8MaH8fG81qsiNmK76fJo1Bc04LH1iKVaKNvgc5YeYfr4)gaQWXKLg8UMKveaD8IWi6jg81R99jpTywzuA1KfoQ0JSeqswHRD8Anz5nbc5la5zjjKtgYD9IrN6nbA8YWAeYxydYZUEYsdExtYAz)OX1E8KNwm7ALwnzHJk9ilbKKv4AhVwtwRa5l1RvPhPGc0iqKb5KHCrb(gba9yq(gKtYKLg8UMKf4iCv6rJMN)DW7AsEAXS260QjlCuPhzjGKScx741AYAPETk9ifuGgbImiNmKlkW3iaOhdY3GCsMS0G31KSeiYmvUju3bg5DnjpTiqxpTAYchv6rwcijln4DnjRG(VrdExJ5BHNS(w4MrjWKfRCrYtlc0SPvtw4OspYsajzfU2XR1KL3eiKt6gKVgsMS0G31KSIaOJxegrpXGVETVp5PfbkqtRMSWrLEKLasYkCTJxRjlVjqiNuipljtwAW7Aswl7hnU2JN80IaDnPvtw4OspYsajzfU2XR1KvOQNv7gQaKGOgdtp7IF9q6HeApciNuip76qoziNvoncGoErye9ed(61(E6HeApciptgi31lgDQ3eOXldRriNuihORd5ad5XbgKNjdKlIW)nUEXOlOcezMk3eQ7aJ8UgJwiKVaKNfYbgYpTzgCjooTNLG)GNk9ifmkzPbVRjzX0ZoJOa)KNweORDA1KLg8UMKLeEc8SRN4KfoQ0JSeqsEArGsY0QjlCuPhzjGKS0G31KSc6)gn4DnMVfEY6BHBgLatwIiCy4jsEArGkdtRMSWrLEKLasYsdExtYkO)B0G31y(w4jRVfUzucmzL3)JNi5jpzfDyOiKupTAAXSPvtw4OspYsaj5PfbAA1KfoQ0JSeqsEAX1KwnzHJk9ilbKKNwCTtRMS0G31KSeGee1yYXha444LSWrLEKLasYtlsY0QjlCuPhzjGKScx741AYY1hhNgFnr1hAQCJqdxN3bKIJk9ilzPbVRjzfFnr1hAQCJqdxN3bm5PfLHPvtw4OspYsaj5PfLrPvtwAW7AswrL31KSWrLEKLasYtlUwPvtw4OspYsajzfU2XR1KLic)346fJUGkqKzQCtOUdmY7AmAHq(cBq(AswAW7AswcezMk3eQ7aJ8UMKNw0wNwnzPbVRjzbqbhpzHJk9ilbKKNwm76Pvtw4OspYsajzfU2XR1K1kqURpoofGcoofhv6rgKtgYfr4)gxVy0fubImtLBc1DGrExJrleYjfYxtYsdExtYsaqz1oJu9EYtEYku1ZQDJiTAAXSPvtw4OspYsajzfU2XR1KLCqURpooLPNDgrb(gIwG3EkoQ0JmiNmKhQ6z1UHkajiQXW0ZU4xpKcgb5KH8qvpR2nuME2zef4tbJGCzH8mzG8qvpR2nubibrngME2f)6HuWiiptgi31lgDQ3eOXldRriNuiFnRNS0G31KSIkVRj5PfbAA1KfoQ0JSeqswHRD8AnzfQ6z1UHkajiQXW0ZU4xpKEiH2JaYxaYLrRd5zYa5EtGgVmSgHCsHCGUoKNjdKlhKlhKlbMNt1G3lrdOkOcxd2b5BqojH8mzGCrb(gba9yq(gKVoKllKtgYLdYxbYD9XXPra0XlcJONyWxV23tXrLEKb5zYa5HQEwTBOra0XlcJONyWxV23tpKq7ra5Yc5KHC5G8vGCxFCCkdvhGu9ofhv6rgKNjdKhQ6z1UHYq1bivVtpKq7ra5KUb5XbgKNjdKVcKhQ6z1UHYq1bivVtpKq7ra5Yc5KH8vG8qvpR2nubibrngME2f)6H0dj0EeqUSjln4DnjlqbAAhjejpT4AsRMSWrLEKLasYkCTJxRjRvG8qvpR2nubibrngME2f)6HuWOKLg8UMKvEFO0xfl5Pfx70QjlCuPhzjGKScx741AYAfipu1ZQDdvasquJHPNDXVEifmkzPbVRjzj9vXm5G3(KN8KfRCrA10IztRMSWrLEKLasYkCTJxRjlw50qDhyK31qpKq7ra5KUb5AW7AOcezMk3eQ7aJ8UgAqfUXBceYbgY9ManEzea0Jb5ad5RnfOqUmHC5G8SqUTa5U(440WHyupXggQoakoQ0JmixMq(60SKeYLfYjd5Ii8FJRxm6cQarMPYnH6oWiVRXOfc5lSb5RbYbgYpTzgCjooTNLG)GNk9ifmcYbgYD9XXP7U2bGMEmACn7P4OspYGCYq(kqoRCQarMPYnH6oWiVRHEiH2JaYjd5Ra5AW7AOcezMk3eQ7aJ8UgApM8VJb4jln4DnjlbImtLBc1DGrExtYtlc00QjlCuPhzjGKS0G31KS04A2NScx741AYY1hhNgoeJ6j2Wq1bqXrLEKb5KHCn49s0WkNQX1ShYjfYLHqozi31lgDQ3eOXldRriFbip76qozixoi)qcThbKt6gKhhyqEMmqEOQNv7gQaKGOgdtp7IF9q6HeApciFbip76qozixoi)qcThbKtkKtsiptgiFfixLX41osJ0HHeDW0ZYkOExd90XoiNmKFy(HcaQ0JqUSqUSjRW(WJgxVy0fPfZM80IRjTAYchv6rwcijln4DnjlnUM9jRW1oETMSwbYD9XXPHdXOEInmuDauCuPhzqozixdEVenSYPACn7HCsH81cYjd5UEXOt9ManEzync5la5zxhYjd5Yb5hsO9iGCs3G84adYZKbYdv9SA3qfGee1yy6zx8RhspKq7ra5la5zxhYjd5Yb5hsO9iGCsHCsc5zYa5Ra5QmgV2rAKomKOdMEwwb17AONo2b5KH8dZpuaqLEeYLfYLnzf2hE046fJUiTy2KNwCTtRMSWrLEKLasYsdExtYs0raQX8DoMScx741AYsoixdEVenSYPIocqnMVZriNuiFTGCBbYD9XXPHdXOEInmuDauCuPhzqUTa5Ii8FJRxm6cQO2zCaOrGity0cHCzHCYqURxm6uVjqJxgwJq(cqE21HCYq(H5hkaOspc5KHC5G8vG8dj0EeqozixeH)BC9IrxqfiYmvUju3bg5DngTqiFdYZc5zYa5HQEwTBOcqcIAmm9Sl(1dPhsO9iG8fGCrb(gba9yqUmHCn4DnuWr4Q0Jgnp)7G31qrsedGoA8MaHCztwH9HhnUEXOlslMn5PfjzA1KfoQ0JSeqswAW7AswH6oWiVRjzfU2XR1KLic)346fJUGkqKzQCtOUdmY7AmAHqoPq(AGCGH8tBMbxIJt7zj4p4PspsbJGCGHCxFCC6URDaOPhJgxZEkoQ0JmiNmKlhKFiH2JaYjDdYJdmiptgipu1ZQDdvasquJHPNDXVEi9qcThbKVaKNDDiNmKFy(HcaQ0JqUSqozi31lgDQ3eOXldRriFbip76jRW(WJgxVy0fPfZM8KNSY7)XtKwnTy20QjlCuPhzjGKS0G31KSahHRspA088VdExtYkCTJxRjRqvpR2nugQoaP6D6HeApciN0nipoWGCzc5afYjd5Ii8FJRxm6cQarMPYnH6oWiVRXOfc5BqEwihyi)0MzWL440Ewc(dEQ0JuWiiNmKhQ6z1UHkajiQXW0ZU4xpKEiH2JaYxaYb66jRVh0eyjRSKm5PfbAA1KfoQ0JSeqswHRD8Anz56JJtzO6aKQ3P4OspYGCYqUic)346fJUGkqKzQCtOUdmY7AmAHq(gKNfYbgYpTzgCjooTNLG)GNk9ifmcYjd5Yb5SYPACn7PhsO9iGCsHCw5unUM9ug4PExdKltiFDQmIKqEMmqoRCAOUdmY7AOhsO9iGCsHCw50qDhyK31qzGN6DnqUmH81PYisc5zYa5SYPIocqnMVZr6HeApciNuiNvov0raQX8DoszGN6DnqUmH81PYisc5Yc5KH8qvpR2nugQoaP6D6HeApciN0nixdExdvJRzpnoWGCzc5RnKtgYdv9SA3qfGee1yy6zx8RhspKq7ra5la5aD9KLg8UMKvq)3ObVRX8TWtwFlCZOeyYIjzom)qbGKNwCnPvtw4OspYsajzfU2XR1KLRpooLHQdqQENIJk9idYjd5Ii8FJRxm6cQarMPYnH6oWiVRXOfc5BqEwihyi)0MzWL440Ewc(dEQ0JuWiiNmKhQ6z1UHkajiQXW0ZU4xpKEiH2JaYjDdYff4Bea0Jb5YeY1G31q14A2tJdmihyixdExdvJRzpnoWGCzc5RbYjd5Yb5SYPACn7PhsO9iGCsHCw5unUM9ug4PExdKltiplKNjdKZkNgQ7aJ8Ug6HeApciNuiNvonu3bg5Dnug4PExdKltiplKNjdKZkNk6ia1y(ohPhsO9iGCsHCw5urhbOgZ35iLbEQ31a5YeYZc5YMS0G31KSc6)gn4DnMVfEY6BHBgLatwmjZH5hkaK80IRDA1KfoQ0JSeqswHRD8AnzfQ6z1UHkajiQXW0ZU4xpKEiH2JaYxydYxZ6qoWqECGb5zYa5HQEwTBOcqcIAmm9Sl(1dPhsO9iG8fG8SR96jln4DnjlgQoaP69KNwKKPvtw4OspYsajzfU2XR1KLeyEoLOwIe44uWiiNmKlbMNtNogGNR)tpKq7rKS0G31KSeauwTZivVN80IYW0QjlCuPhzjGKScx741AYscmpNsulrcCCkyeKtgYxbYLdYD9XXPIocqnMVZrkoQ0JmiNmKlhKhD4stCGrZs14A2d5KH8OdxAIdmkqPACn7HCYqE0HlnXbgDnunUM9qUSqEMmqE0HlnXbgnlvJRzpKlBYsdExtYsJRzFYtlkJsRMSWrLEKLasYkCTJxRjljW8CkrTejWXPGrqoziFfixoip6WLM4aJMLk6ia1y(ohHCYqE0HlnXbgfOurhbOgZ35iKtgYJoCPjoWORHk6ia1y(ohHCztwAW7AswIocqnMVZXKNwCTsRMSWrLEKLasYkCTJxRjljW8CkrTejWXPGrqoziFfip6WLM4aJMLgQ7aJ8UgiNmKVcK76JJtvjr9GoAc1DGrExdfhv6rwYsdExtYku3bg5DnjpTOToTAYchv6rwcijRW1oETMSKdYLaZZP9GlBxLE0WqIwGuHRb7G8f2G81IKqUTa5Yb5Ii8FJRxm6cQarMPYnH6oWiVRXOfc52cKFAZm4sCCAplb)bpv6rkyeKVaKduixwixMqoqxhYjd5Yb5HQEwTBOmuDas170dj0Eeq(cqosIya0rJ3eiKNjdKVcK76JJtzO6aKQ3P4OspYGCzHCYqUCqEOQNv7gAeaD8IWi6jg81R990dj0Eeq(cqosIya0rJ3eiKNjdKVcK76JJtJaOJxegrpXGVETVNIJk9idYLfYjd5Yb5HQEwTBOm9SZikWNEiH2JaYxaYrsedGoA8MaH8mzG8vGCxFCCktp7mIc8neTaV9uCuPhzqUSqozixoipu1ZQDdDz)OX1EC6HeApciFbihjrma6OXBceYZKbYxbYD9XXPl7hnU2JtXrLEKb5Yc5KH8qvpR2nubibrngME2f)6H0dj0Eeq(cqosIya0rJ3eiKdmKNDDiptgixcmpN2dUSDv6rddjAbsfUgSdYxaYxZ6qozi31lgDQ3eOXldRriN0nip76qUSjln4Dnjl2P9y(ohtEAXSRNwnzPbVRjzbqbhpzHJk9ilbKKNwmB20QjlCuPhzjGKS0G31KSyN2JruGFYkSp8OX1lgDrAXSjREC8oWipzLnzfU2XR1KLRxm6uVjqJxgwJqoPBqECGLSca0Eswztw944DGrUj(lj9twztEAXSanTAYchv6rwcijln4Dnjl2P9yef4NSc7dpAC9IrxKwmBYQhhVdmYnDEYY7GDcZHeApKsYKv4AhVwtwU(44ubaLv7miH0PbKIJk9idYjd5l1RvPhPeApU2JrGqoziFfiNHsG55ubaLv7miH0PbKEiH2JizfaO9KSYMS6XX7aJCt8xs6NSYM80IzxtA1KfoQ0JSeqswAW7AswSt7XikWpzf2hE046fJUiTy2KvpoEhyKB68KL3b7eMdj0EiLKjRW1oETMSC9XXPcakR2zqcPtdifhv6rgKtgYxQxRspsj0ECThJatwbaApjRSjREC8oWi3e)LK(jRSjpTy21oTAYchv6rwcijln4Dnjl2P9yef4NS6XX7aJ8Kv2KvaG2tYkBYQhhVdmYnXFjPFYkBYtlMLKPvtw4OspYsajzPbVRjzjaOSANrQEpzfU2XR1KLRpoovaqz1odsiDAaP4OspYGCYq(s9Av6rkH2JR9yeiKtgYxbYzOeyEovaqz1odsiDAaPhsO9iGCYq(kqUg8UgQaGYQDgP6DApM8VJb4jRW(WJgxVy0fPfZM80IzLHPvtw4OspYsajzPbVRjzjaOSANrQEpzfU2XR1KLRpoovaqz1odsiDAaP4OspYGCYq(s9Av6rkH2JR9yeyYkSp8OX1lgDrAXSjpTywzuA1KLg8UMKLaGYQDgP69KfoQ0JSeqsEYtwIiCy4jsRMwmBA1KfoQ0JSeqswHRD8AnzfQ6z1UHkajiQXW0ZU4xpKEiH2JaYjDdYff4Bea0Jb5YeYrsedGoA8MaHCYqUCq(kqURpooLHQdqQENIJk9idYZKbYdv9SA3qzO6aKQ3PhsO9iGCs3GCrb(gba9yqUmHCKeXaOJgVjqix2KLg8UMKf4iCv6rJMN)DW7AsEArGMwnzHJk9ilbKKv4AhVwtwYb5HQEwTBOcqcIAmm9Sl(1dPhsO9iGCsHCVjqJxgba9yqUmHC5GCziKBlqUOaFJaGEmixwiptgipu1ZQDdvasquJHPNDXVEifmcYLfYjd5EtGgVmSgH8fG8qvpR2nubibrngME2f)6H0dj0Eejln4DnjRG(VrdExJ5BHNS(w4MrjWKvE)pEIKNwCnPvtw4OspYsajzfU2XR1K1s9Av6rkOancezjln4DnjlbImtLBc1DGrExtYtlU2Pvtw4OspYsajzfU2XR1K1kq(s9Av6rkOancezqoziFfip6WLM4aJMLkajiQXW0ZU4xpeYjd5Yb5U(44ugQoaP6DkoQ0JmiNmKhQ6z1UHYq1bivVtpKq7ra5KUb5ijIbqhnEtGqoziFfixLX41osdQiOSEInb9vI23tXrLEKb5zYa5Yb5Ic8nca6XG8f2GCsc5KHCre(VX1lgDbvGiZu5MqDhyK31y0cHCsHCGc5zYa5Ic8nca6XG8f2GCGc5KHCre(VX1lgDbvGiZu5MqDhyK31y0cH8f2GCGc5Yc5KHCxVy0PEtGgVmSgH8fG81gYbgYrsedGoA8MaHCYqUic)346fJUGkqKzQCtOUdmY7AmAHq(gKNfYZKbYD9IrN6nbA8YWAeYjDdYxlihyihjrma6OXBceYLjKlkW3iaOhdYLnzPbVRjzbocxLE0O55Fh8UMKNwKKPvtw4OspYsajzfU2XR1K1kq(s9Av6rkOancezqozipuJRXDnqoPBqEqfUXBceYbgYxQxRspsJugRN4KLg8UMKf4iCv6rJMN)DW7AsEArzyA1KfoQ0JSeqswAW7AswGJWvPhnAE(3bVRjzfU2XR1K1kq(s9Av6rkOancezqozixoiFfi31hhNYq1bivVtXrLEKb5zYa5HQEwTBOmuDas170dj0Eeq(cqU3eOXlJaGEmiptgixuGVraqpgKVaKNfYLfYjd5Yb5Ra5U(440L9Jgx7XP4OspYG8mzGCrb(gba9yq(cqEwixwiNmKhQX14UgiN0nipOc34nbc5ad5l1RvPhPrkJ1tmKtgYLdYxbYvzmETJ0GkckRNytqFLO99uCuPhzqEMmqUeyEonOIGY6j2e0xjAFp9qcThbKVaK7nbA8YiaOhdYLnzf2hE046fJUiTy2KN8KN8KNsa]] )


end