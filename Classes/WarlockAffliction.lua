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

        if buff.casting.up and buff.casting.v1 == 234153 then
            removeBuff( "inevitable_demise" )
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
                if buff.dispellable_magic.down then return false, "no dispellable magic aura" end
                return true
            end,

            handler = function()
                removeBuff( "dispellable_magic" )
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
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

        potion = "unbridled_fury",

        package = "Affliction",
    } )


    spec:RegisterPack( "Affliction", 20190804.1510, [[dC0pmcqibYJuQKUKQK0MiIpruQGrHs5uOKwLQuEfkvZsaUfrjTlc)sPkdtaDmLWYuLQNPuvtJOuUMsKTruI(grPQXPkPCoIsyDkvImpIu3tvSpIIdQkPQfQkXdvLuXejkv6IeLk0jvQevRuGAMeLkQBQujk2PsulvvsLEkLmvLkUQsLO0xjkvK9kv)LIbJ4WKwmL6XcnzuDzOnlOplLgTs50kEnrYSbUTQA3s(TOHlfhxPsy5Q8CKMovxhfBxj13vsgVQK48OeRxPsnFIQ9d6(I(oDlU6yF53dCHSiWxlqztSyPaLfYw3YzPb7wnAukTf7wL(XU1RpmemrFYQB1OSasL33PBrtMlIDRn3BO7s7Tx74Bm2Iy(3JoFgG6twXtd99OZpUx3YMza(U8QB3T4QJ9LFpWfYIaFTaLnXILcuwSVSSBrBWyF53LLl1T2gohRUD3IJ0y3AxHKxFyiyI(KfKi7KEGmkfm4Dfs2CVHUlT3ETJVXylI5Fp68zaQpzfpn03Jo)4EWG3vi51Z0YqDir2casEpWfYcirwHKflTlfyGWGHbVRqYRZMwTiDxcg8UcjYkK865CKdjwniaajYoNrPeWG3virwHKxpNJCir2fxNmhKSlJ2orbm4DfsKvi51f)5AKdjUETOBMqHqadExHezfsEDXDbZCiKi7M7qHeMgijliX1RfDijmpir2fvFZoboKWgDQicjhgEiDdsaz7eHKHcj8jmepSCizcHKxhzxkKOhcj8HQ2aKZQag8UcjYkK86InanIqcfxJNcGexVw0f(8rJNg(GqsuPifswn(gK4ZhnEA4dcjSHfhsYqibRyYuoESk6wnxgoaSBTRqYRpmemrFYcsKDspqgLcg8UcjBU3q3L2BV2X3ySfX8VhD(ma1NSINg67rNFCpyW7kK86zAzOoKiBbajVh4czbKiRqYIL2LcmqyWWG3vi51ztRwKUlbdExHezfsE9CoYHeRgeaGezNZOucyW7kKiRqYRNZroKi7IRtMds2LrBNOag8UcjYkK86I)CnYHexVw0ntOqiGbVRqIScjVU4UGzoesKDZDOqctdKKfK461IoKeMhKi7IQVzNahsyJoveHKddpKUbjGSDIqYqHe(egIhwoKmHqYRJSlfs0dHe(qvBaYzvadExHezfsEDXgGgriHIRXtbqIRxl6cF(OXtdFqijQuKcjRgFds85Jgpn8bHe2WIdjziKGvmzkhpwfWGHbVRqISJVcgzCKdj2yyEiKeZVT6qIn2ofvajV(yeBCkKuzjRB69dzaqIg9jlkKKfGfbm4Dfs0OpzrfnhgZVT6pHaLkfm4Dfs0OpzrfnhgZVT6S)SxyMCyW7kKOrFYIkAomMFB1z)zpLP9JLR(Kfmyn6twurZHX8BRo7p7rz()SmnOddwJ(Kfv0Cym)2QZ(ZET38Z5qtgAOA8MWjIbmHpUcWYfT38Z5qtgAOA8MWjIcSuBaYHbVRqIg9jlQO5Wy(TvN9N9OL2q3s3qD1PWG1OpzrfnhgZVT6S)Sxt6twWG1OpzrfnhgZVT6S)ShdfnJJ)ak9Jp6UPB6PutywUjdnn5k8GbRrFYIkAomMFB1z)zpkICtgAI5Dmn(Kvat4dTbbaJRxl6ubfrUjdnX8oMgFYYOjkZZ(scc3fmttdYflKLYI9xiBWG1OpzrfnhgZVT6S)S3MYuomyn6twurZHX8BRo7p7r3uEUYyNapGj8jixby5InLPCbwQna5sOniayC9ArNkOiYnzOjM3X04twgnrP3xsq4UGzAAqUyHSuwS)czdgmm4DfsKD8vWiJJCibxJhlqIpFes8nes0ONhKmuirxRdqTbOagSg9jl6dTbbadiJsbdwJ(KfL9N9446K5mFTDIWG1Opzrz)zV16nQnadO0p(WqrdfrEaRvad(4kalxqZvgFdnue5ubwQna5sOniayC9ArNkOiYnzOjM3X04twgnrzE2N9thUbxJLlMAndOWtTbOGPrUCxby5c60SLLbmHOal1gGCj0geamUETOtfue5Mm0eZ7yA8jlzEwI9thUbxJLlMAndOWtTbOGPrUCAdcagxVw0PckICtgAI5Dmn(KLmpVg7NoCdUglxm1AgqHNAdqbtdmyn6twu2F2BTEJAdWak9JpnkNpvBazZdf9awRag8rJ(KLGUP8CLXobUaFfmY4OXNp(MUB8ghfrLgv(uTMOc0)4SiWsTbihgSg9jlk7p7TwVrTbyaL(XNgLZNQnGS55qk6bSwbm4tBKhWe(O7gVXrruPrLpvRjQa9polcSuBaYLWMRaSCb)0Pm0KbiWsTbixUCxby5coQ(MDcCbwQna5sIzc45QsWr13StGlo8RtrL(PnYzfgSg9jlk7p7TwVrTbyaL(XNVoLRtzOyaRvad(qBqaW461IovqrKBYqtmVJPXNSmAIs)SGDxby5Iv34BOzkJ2MflcSuBaYz3vawUqTPjGXrtmVJPXNSeyP2aK)27SZMRaSCXQB8n0mLrBZIfbwQna5sCfGLlO5kJVHgkICQal1gGCj0geamUETOtfue5Mm0eZ7yA8jlJMOmVZk7S5kalxqNMTSmGjefyP2aKljixby5I4HyZuTgoQ(Mal1gGCjb5kalxWpDkdnzacSuBaYzL9thUbxJLlMAndOWtTbOGPbgSg9jlk7p7TwVrTbyaL(XhE6udttaRvad(WwqUcWYf0PzlldycrbwQna5YLZtxqNMTSmGjefmnSkHNUqBZIfb11OuY8SiqjbXtxOTzXI4WWdPBQnaLWtxeZ7yA8jlbtdmyn6twu2F2lQaGrJ(KLbmupGs)4tmtapxvuyWA0NSOS)Sh)0Pm0KbeWuoEhtJBAbPTcEweqCtN6zrarwIa0461Io9zrat4JpF04PHpO0pTrUeAYam0n94sVemyn6twu2F2BtzkpGj8H2GaGX1RfDQGIi3KHMyEhtJpzz0eL(5D2pD4gCnwUyQ1mGcp1gGcMgyWA0NSOS)ShL5)ZYW1tQwGEyat4dpDH2MflcFIsnvReE6IyEhtJpzj8jk1uTsyZMjmuOrFwJggLkOUgL6zj5YPjdWq30J)eOC580fnBA553qNQLbO34Sio8RtrLWtx0SPLNFdDQwgGEJZI4WVofv6N2iNvjSfKRaSCrZMwE(n0PAza6nolcSuBaYLlNNUOztlp)g6uTma9gNfXHFDkkRsylixby5coQ(MDcCbwQna5YLhZeWZvLGJQVzNaxC4xNIk9tBKlxEqXmb8Cvj4O6B2jWfh(1POYLtBqaW461IovqrKBYqtmVJPXNSmAIYSG9thUbxJLlMAndOWtTbOGPHvyWA0NSOS)ShhvFZobEat4tmtapxvckZ)NLHRNuTa9qXHFDkQK16nQnaf80PgMgj0geamUETOtfue5Mm0eZ7yA8jlJM4Zc2pD4gCnwUyQ1mGcp1gGcMgjSfesPyfrX6HozzYqtdEHy0NSe)PYtsq6UXBCuWpu5HmatubGPAfNwsjxEmtapxvckZ)NLHRNuTa9qXHFDkQm7hiRWG1Opzrz)zpFdnmLDYuCtyErmGj8XMjmuCyukasPMW8IO4WVoffgSg9jlk7p7PTzXsarwIa0461Io9zrat4ZHFDkQ0pTro7A0NSe0nLNRm2jWf4RGrghn(8rj(8rJNg(GY8AWG1Opzrz)zVp(ZJftgAamXHB4hQFAat4JpFu69deg8Ucj7G)M80JfijCEfiXti5RsHqcL5qir3nDtpv2bkKeMLdj8ePLSdoKyFOkfKW1tQwGEiKWq1wuadwJ(KfL9N902SyjaWuOjYF2pWaMWhF(Om7hOKyMaEUQeuM)pldxpPAb6HId)6uuPFwSKeCxWmnnixSqwkl2FHSbdwJ(KfL9N9I5Dmn(KvaGPqtK)SFGbmHp(8rz2pqjXmb8CvjOm)FwgUEs1c0dfh(1POs)Syjj4UGzAAqUyHSuwS)cztsqUcWYfQnnbmoAI5Dmn(KLal1gGCjS5kalxqNMTSmGjefyP2aKlxoTbbaJRxl6ubfrUjdnX8oMgFYYOjkZcj0geamUETOtfue5Mm0eZ7yA8jlJMO0p7Zkmyn6twu2F2JonBzzatigayk0e5p7hyat4JpFuM9dusmtapxvckZ)NLHRNuTa9qXHFDkQ0plwscUlyMMgKlwilLf7Vq2GbRrFYIY(ZEmf1vBaA0WqWe9jRaISebOX1RfD6ZIaMWNGIz5A7KLeF(OXtdFqPFEnyWA0NSOS)Sh)0Pm0KbeqKLianUETOtFwequRicmt4JprPOMd)6usVuat4JRaSCbDt55kd(TpnIcSuBaYLSwVrTbO4Rt56ugkkHJ2mHHc6MYZvg8BFAefh(1POs4OntyOGUP8CLb)2NgrXHFDkQ0pTr(BVddwJ(KfL9N9OBkpxzStGhqKLianUETOtFweWe(4kalxq3uEUYGF7tJOal1gGCjR1BuBak(6uUoLHIs4OntyOGUP8CLb)2NgrXHFDkQeoAZegkOBkpxzWV9PruC4xNIk9d(kyKXrJpF8T3z3pDncm(8rjbPrFYsq3uEUYyNaxmLjemTBomyn6twu2F2Rztlp)g6uTma9gNLaISebOX1RfD6ZIaMWhF(Om7VKexVw0f(8rJNg(GYSqw(gTbbaZMsDucBbHukwruSEOtwMm00Gxig9jlXFQ8KeKUB8ghf8dvEidWevayQwXPLuYLhZeWZvLGY8)zz46jvlqpuC4xNIkJSTe70KbyOB6XFt3nEJJc(HkpKbyIkamvR40sk5YJzc45Qsqz()SmC9KQfOhko8RtrLEXsVrBqaWSPuhzNMmadDtp(B6UXBCuWpu5HmatubGPAfNwsXkmyn6twu2F2JPOUAdqJggcMOpzfqKLianUETOtFweWe(e0A9g1gGcgkAOiYLqtgGHUPh)zjyWA0NSOS)ShfrUjdnX8oMgFYkGj8zTEJAdqbdfnue5sOjdWq30J)Semyn6twu2F2lQaGrJ(KLbmupGs)4dpDkmyn6twu2F2B9aqJRt5bezjcqJRxl60NfbmHp(8rzwSKeF(OXtdFqzEweOe2Izc45Qsqz()SmC9KQfOhko8RtrLz)aLlpMjGNRkbL5)ZYW1tQwGEO4WVofv6fbkHNUqBZIfXHFDkQmplcucpDrmVJPXNSeh(1POY8SiqjSXtxqNMTSmGjefh(1POY8Siq5YdYvawUGonBzzatikWsTbiNvwHbRrFYIY(ZEmu0mo(dO0p(O7MUPNsnHz5Mm00KRWlGj8XNpk9Z(WG1Opzrz)zVMnT88BOt1Ya0BCwcycF85Js)S)sWG1Opzrz)zV1danUoLhWe(4ZhLEXsWG1Opzrz)zVwg94JwMm0O7gV03cycFylMjGNRkbL5)ZYW1tQwGEO4WVofv6flXonzag6ME830DJ34OGFOYdzaMOcat1kWsTbixUC20DJ34OGFOYdzaMOcat1koTKsUCKsXkII1dDYYKHMg8cXOpzjoTKIvj(8rz2pqj(8rJNg(GY88(IazvcB80fnBA553qNQLbO34Sio8RtrLlNNUy9aqJRt5Id)6uu5YdYvawUOztlp)g6uTma9gNfbwQna5scYvawUy9aqJRt5cSuBaYzvUCF(OXtdFqP3pq2BJCyWA0NSOS)ShxpPm0KbeWe(eZeWZvLGY8)zz46jvlqpuC4xNIk9ILyNMmadDtp(B6UXBCuWpu5HmatubGPAfyP2aKlHnE6IMnT88BOt1Ya0BCweh(1POYLZtxSEaOX1PCXHFDkkRWG1Opzrz)zpB8O4j1uTWG1Opzrz)zVOcagn6twgWq9ak9Jp0gS44rHbRrFYIY(ZErfamA0NSmGH6bu6hFchaapkmyyWA0NSOIyMaEUQOpmu0mo(dO0p(O7MUPNsnHz5Mm00KRWlGj8HTGCfGLlA20YZVHovldqVXzrGLAdqUC5Xmb8CvjA20YZVHovldqVXzrC4xNIkTS9gTbbaZMsDuU8GIzc45Qs0SPLNFdDQwgGEJZI4WVofLvjXmb8CvjOm)FwgUEs1c0dfh(1POsVqw8gTbbaZMsDKDAYam0n94VP7gVXrb)qLhYamrfaMQvCAjLeE6cTnlweh(1POs4PlI5Dmn(KL4WVofvcB80f0PzlldycrXHFDkQC5b5kalxqNMTSmGjefyP2aKZkmyn6twurmtapxvu2F2Rj9jRaMWh2CfGLl46jLHMmaZFO4XIal1gGCjXmb8CvjOm)FwgUEs1c0dfmnsIzc45QsW1tkdnzacMgwLlpMjGNRkbL5)ZYW1tQwGEOGPrUCF(OXtdFqP3pqyWA0NSOIyMaEUQOS)ShdfnJJFAat4tmtapxvckZ)NLHRNuTa9qXHFDkQmY(aLl3NpA80Whu63duUC2yZMjmuOrFwJggLkOUgL6zj5YPjdWq30J)eiRsylixby5IMnT88BOt1Ya0BCweyP2aKlxEmtapxvIMnT88BOt1Ya0BCweh(1POSkHTGCfGLl4O6B2jWfyP2aKlxEmtapxvcoQ(MDcCXHFDkQ0pTrUC5bfZeWZvLGJQVzNaxC4xNIYQKGIzc45Qsqz()SmC9KQfOhko8RtrzfgSg9jlQiMjGNRkk7p7fohAdYKhWe(eumtapxvckZ)NLHRNuTa9qbtdmyn6twurmtapxvu2F2ZgKj3eYCSeWe(eumtapxvckZ)NLHRNuTa9qbtdmyn6twurmtapxvu2F27J)8yXKHgatC4g(H6NgWe(4ZhLz)aHbRrFYIkIzc45QIY(ZEC9KYqtgqat4JpF04PHpO0Vhi7TrUC5UcWYf0CLX3qdfrovGLAdqUKyMaEUQeuM)pldxpPAb6HId)6uuzEIzc45Qsqz()SmC9KQfOhk4mN6twY6IaHbRrFYIkIzc45QIY(ZE2Gm5Mm04BObl8Zsat4td6cUEs1c0dfh(1POYLZwqXmb8Cvj4O6B2jWfh(1POYLhKRaSCbhvFZobUal1gGCwLeZeWZvLGY8)zz46jvlqpuC4xNIkZZRfOeKsXkIcBqMCtgA8n0Gf(zrCAjLmlGbVRqYUSues46xBNQfsYswzOiK43usHofs(5HqsEqcaPuijlijMjGNRQaGeAcjGSAHeLcj(gcj7YFDKDHeFdzbsMkYCqYQSKDWHemmeJoKOflqs6B4bj(nLuOtHegQ2IqcN5MQfsIzc45QIkGbRrFYIkIzc45QIY(ZEmu0mo(dO0p(0KrPqNo7g5My(ByC1NSmCC9eXaMWh2Izc45Qsqz()SmC9KQfOhko8RtrL559LKl3NpA80Whu6N9dKvjSfZeWZvLGJQVzNaxC4xNIkxEqUcWYfCu9n7e4cSuBaYzfgSg9jlQiMjGNRkk7p7XqrZ44pGs)4ZLE8yOoYnRZKNPHNaqat4dBXmb8CvjOm)FwgUEs1c0dfh(1POY88(sYL7ZhnEA4dk9Z(bYQe2Izc45QsWr13StGlo8RtrLlpixby5coQ(MDcCbwQna5ScdwJ(KfveZeWZvfL9N9yOOzC8hqPF8HUnRXZSgR8BoemXaMWh2Izc45Qsqz()SmC9KQfOhko8RtrL559LKl3NpA80Whu6N9dKvjSfZeWZvLGJQVzNaxC4xNIkxEqUcWYfCu9n7e4cSuBaYzfgSg9jlQiMjGNRkk7p7XqrZ44pGs)4JUlyMM0XYnLY4dGHgWe(WwmtapxvckZ)NLHRNuTa9qXHFDkQmpVVKC5(8rJNg(Gs)SFGSkHTyMaEUQeCu9n7e4Id)6uu5YdYvawUGJQVzNaxGLAdqoRWG1OpzrfXmb8Cvrz)zpgkAgh)bu6hF8HJupVVjMC8vcycFylMjGNRkbL5)ZYW1tQwGEO4WVofvMN3xsUCF(OXtdFqPF2pqwLWwmtapxvcoQ(MDcCXHFDkQC5b5kalxWr13StGlWsTbiNvyWA0NSOIyMaEUQOS)ShdfnJJ)ak9JpRhfyYqd1Z7tdycFylMjGNRkbL5)ZYW1tQwGEO4WVofvMN3xsUCF(OXtdFqPF2pqwLWwmtapxvcoQ(MDcCXHFDkQC5b5kalxWr13StGlWsTbiNvyWA0NSOIyMaEUQOS)S3Q8a814uMdPzPvedycFSzcdfGjeTbzYfuxJsj9(WG1OpzrfXmb8Cvrz)zVBAAaOzkdTrJimyyWA0NSOcUT5WWdPBp0PzlldycXaatHMi)zXsbmHpSXtxqNMTSmGjefh(1POVkpDbDA2YYaMquWzo1NSyv6h24Pl02SyrC4xNI(Q80fABwSi4mN6twSkHnE6c60SLLbmHO4WVof9v5PlOtZwwgWeIcoZP(KfRs)WgpDrmVJPXNSeh(1POVkpDrmVJPXNSeCMt9jlwLWtxqNMTSmGjefh(1POsZtxqNMTSmGjefCMt9jR3wi2hgSg9jlQGBBom8q6g7p7PTzXsaGPqtK)SyPaMWh24Pl02SyrC4xNI(Q80fABwSi4mN6twSk9dB80fX8oMgFYsC4xNI(Q80fX8oMgFYsWzo1NSyvcB80fABwSio8RtrFvE6cTnlweCMt9jlwL(HnE6c60SLLbmHO4WVof9v5PlOtZwwgWeIcoZP(KfRs4Pl02SyrC4xNIknpDH2MflcoZP(K1Ble7ddwJ(KfvWTnhgEiDJ9N9I5Dmn(KvaGPqtK)SyPaMWh24PlI5Dmn(KL4WVof9v5PlI5Dmn(KLGZCQpzXQ0pSXtxOTzXI4WVof9v5Pl02SyrWzo1NSyvcB80fX8oMgFYsC4xNI(Q80fX8oMgFYsWzo1NSyv6h24PlOtZwwgWeIId)6u0xLNUGonBzzatik4mN6twSkHNUiM3X04twId)6uuP5PlI5Dmn(KLGZCQpz92cX(WGHbRrFYIk4PtFOiYnzOjM3X04twbmHp80fX8oMgFYsC4xNIk9Jg9jlbfrUjdnX8oMgFYsevQB85JS7ZhnEAOB6Xzx2eV)gBlKvxby5I4HyZuTgoQ(Mal1gG83cuSyjwLqBqaW461IovqrKBYqtmVJPXNSmAIY8Sp7NoCdUglxm1AgqHNAdqbtd7UcWYfRUX3qZugTnlweyP2aKljiE6ckICtgAI5Dmn(KL4WVofvsqA0NSeue5Mm0eZ7yA8jlXuMqW0U5WG1Opzrf80PS)SN2MflbezjcqJRxl60NfbmHpUcWYfXdXMPAnCu9nbwQna5s0OpRrdpDH2MflsllL4ZhnEA4dkZIaLW2HFDkQ0pTrUC5Xmb8CvjOm)FwgUEs1c0dfh(1POYSiqjSD4xNIk9sYLhKUB8ghfnAXX)entToJQpzjoTKsYHHhs3uBaYkRWG1Opzrf80PS)SN2MflbezjcqJRxl60NfbmHpb5kalxepeBMQ1Wr13eyP2aKlrJ(Sgn80fABwSi9RjXNpA80WhuMfbkHTd)6uuPFAJC5YJzc45Qsqz()SmC9KQfOhko8RtrLzrGsy7WVofv6LKlpiD34nokA0IJ)jAMADgvFYsCAjLKddpKUP2aKvwHbRrFYIk4Ptz)zp60SLLbmHyarwIa0461Io9zrat4dBA0N1OHNUGonBzzatik9RjRUcWYfXdXMPAnCu9nbwQna5YkTbbaJRxl6ubnxz8n0qrKtnAISkXNpA80WhuMfbk5WWdPBQnaLWwqh(1POsOniayC9ArNkOiYnzOjM3X04twgnXNfYLhZeWZvLGY8)zz46jvlqpuC4xNIkdnzag6ME830OpzjykQR2a0OHHGj6twc8vWiJJgF(iRWG1Opzrf80PS)SxmVJPXNSciYseGgxVw0PplcycFOniayC9ArNkOiYnzOjM3X04twgnrP3N9thUbxJLlMAndOWtTbOGPHDxby5Iv34BOzkJ2MflcSuBaYLW2HFDkQ0pTrUC5Xmb8CvjOm)FwgUEs1c0dfh(1POYSiqjhgEiDtTbiRsC9Arx4ZhnEA4dkZIaHbddwJ(KfveoaaE0hMI6QnanAyiyI(KvaGPqtK)SyPaMWNyMaEUQeCu9n7e4Id)6uuPFAJ83ExcTbbaJRxl6ubfrUjdnX8oMgFYYOj(SG9thUbxJLlMAndOWtTbOGPrsmtapxvckZ)NLHRNuTa9qXHFDkQmVhimyn6twur4aa4rz)zVOcagn6twgWq9ak9JpCBZHHhs3cycFCfGLl4O6B2jWfyP2aKlH2GaGX1RfDQGIi3KHMyEhtJpzz0eFwW(Pd3GRXYftTMbu4P2auW0iHnE6cTnlweh(1POsZtxOTzXIGZCQpz9wGcz)sYLZtxeZ7yA8jlXHFDkQ080fX8oMgFYsWzo1NSElqHSFj5Y5PlOtZwwgWeIId)6uuP5PlOtZwwgWeIcoZP(K1BbkK9lXQKyMaEUQeCu9n7e4Id)6uuPF0Opzj02Syr0g5VjBsIzc45Qsqz()SmC9KQfOhko8RtrL59aHbRrFYIkchaapk7p7fvaWOrFYYagQhqPF8HBBom8q6wat4JRaSCbhvFZobUal1gGCj0geamUETOtfue5Mm0eZ7yA8jlJM4Zc2pD4gCnwUyQ1mGcp1gGcMgjXmb8CvjOm)FwgUEs1c0dfh(1POs)qtgGHUPh)nn6twcTnlweTro7A0NSeABwSiAJ832xcB80fABwSio8RtrLMNUqBZIfbN5uFY6TfYLZtxeZ7yA8jlXHFDkQ080fX8oMgFYsWzo1NSEBHC580f0PzlldycrXHFDkQ080f0PzlldycrbN5uFY6TfScdwJ(KfveoaaEu2F2JJQVzNapGj8zTEJAdqbpDQHPrcBXmb8CvjOm)FwgUEs1c0dfh(1POY8SFGS3g5YLhZeWZvLGY8)zz46jvlqpuC4xNIkZczlqwHbRrFYIkchaapk7p7r3uEUYyNapGj8XMjmu8Z14hlxW0iXMjmuut7MhQaG4WVoffgSg9jlQiCaa8OS)SN2MflbmHp2mHHIFUg)y5cMgjbXMRaSCbDA2YYaMquGLAdqUe2AoCTPnYfleABwSiP5W1M2ix8UqBZIfjnhU20g5I9fABwSWQC5nhU20g5IfcTnlwyfgSg9jlQiCaa8OS)ShDA2YYaMqmGj8XMjmu8Z14hlxW0iji2AoCTPnYfle0PzlldycrjnhU20g5I3f0PzlldycrjnhU20g5I9f0PzlldycrwHbRrFYIkchaapk7p7fZ7yA8jRaMWhBMWqXpxJFSCbtJKGAoCTPnYfleX8oMgFYssqUcWYfQnnbmoAI5Dmn(KLal1gGCyWA0NSOIWbaWJY(ZE8tNYaMqmGj8XMjmumfUEC1gGgo(hkkOUgLsMfbkXNpA80Whu6NfbcdwJ(KfveoaaEu2F2JF6ugWeIbmHpUcWYf0PzlldycrbwQna5sSzcdftHRhxTbOHJ)HIcQRrPK5zPaL13d8n2OniayC9ArNkOiYnzOjM3X04twgnrz90HBW1y5IPwZak8uBakyAK55DwLWtxOTzXI4WVofvMLEJ2GaGztPokHNUiM3X04twId)6uuzAJCjSXtxqNMTSmGjefh(1POY0g5YLhKRaSCbDA2YYaMquGLAdqoRsyJJ2mHHInLPCXHFDkQml9gTbbaZMsDuU8GCfGLl2uMYfyP2aKZQKywU2ozjZsVrBqaWSPuhHbRrFYIkchaapk7p7XpDkdycXaMWhxby5Iv34BOzkJ2MflcSuBaYLyZegkMcxpUAdqdh)dffuxJsjZZsbkRVh4BSrBqaW461IovqrKBYqtmVJPXNSmAIY6Pd3GRXYftTMbu4P2auW0iZZ(SkRl9gB0geamUETOtfue5Mm0eZ7yA8jlJMOSE6Wn4ASCXuRzafEQnafmnpVZQeE6cTnlweh(1POYS0B0geamBk1rj80fX8oMgFYsC4xNIktBKlHnoAZegk2uMYfh(1POYS0B0geamBk1r5YdYvawUytzkxGLAdqoRsIz5A7KLml9gTbbaZMsDegSg9jlQiCaa8OS)Sh)0PmGjedycFCfGLluBAcyC0eZ7yA8jlbwQna5sSzcdftHRhxTbOHJ)HIcQRrPK5zPaL13d8n2OniayC9ArNkOiYnzOjM3X04twgnrz90HBW1y5IPwZak8uBakyAK5r2yvcpDH2MflId)6uuzw6nAdcaMnL6Oe24OntyOytzkxC4xNIkZsVrBqaWSPuhLlpixby5InLPCbwQna5SkjMLRTtwYS0B0geamBk1ryWA0NSOIWbaWJY(ZEBkt5WG1OpzrfHdaGhL9N9cZidf5gD34noASr9ddwJ(KfveoaaEu2F2RH5MqwMQ1yduQddwJ(KfveoaaEu2F2lMvel)uh5MqG(XaMWNG4PlIzfXYp1rUjeOF0yZCL4WVofvsqA0NSeXSIy5N6i3ec0pkMYecM2nhgSg9jlQiCaa8OS)Sh)0Pm0KbeWuoEhtJBAbPTcEweqCtN6zrat54Dmn(ZIaISebOX1RfD6ZIaMWhF(OXtdFqPFAJCyWA0NSOIWbaWJY(ZE8tNYqtgqarwIa0461Io9zraXnDQNfbmLJ3X04Mj8XNOuuZHFDkPxkGPC8oMg30csBf8SiGj8XvawUGUP8CLb)2NgrbwQna5swR3O2au81PCDkdfLeehTzcdf0nLNRm43(0iko8RtrHbRrFYIkchaapk7p7XpDkdnzabezjcqJRxl60Nfbe30PEweWuoEhtJBMWhFIsrnh(1PKEPaMYX7yACtliTvWZIaMWhxby5c6MYZvg8BFAefyP2aKlzTEJAdqXxNY1PmuegSg9jlQiCaa8OS)Sh)0Pm0KbeWuoEhtJBAbPTcEweqCtN6zrat54Dmn(ZcyWA0NSOIWbaWJY(ZE0nLNRm2jWdiYseGgxVw0PplcycFCfGLlOBkpxzWV9PruGLAdqUK16nQnafFDkxNYqrjbXrBMWqbDt55kd(TpnIId)6uujbPrFYsq3uEUYyNaxmLjemTBomyn6twur4aa4rz)zp6MYZvg7e4bezjcqJRxl60NfbmHpUcWYf0nLNRm43(0ikWsTbixYA9g1gGIVoLRtzOimyn6twur4aa4rz)zp6MYZvg7e4WGHbRrFYIkOnyXXJ(WuuxTbOrddbt0NScycFIzc45Qsqz()SmC9KQfOhko8RtrL(HMmadDtp(BSHVcgzC04Zhzx3nEJJc(HkpKbyIkamvR40skwLWwqUcWYfCu9n7e4cSuBaYLlpMjGNRkbhvFZobU4WVofv6hAYam0n94VHVcgzC04ZhzvcBUcWYf0CLX3qdfrovGLAdqUC580fnBA553qNQLbO34Sio8RtrLlNNUy9aqJRt5Id)6uuwHbRrFYIkOnyXXJY(ZErfamA0NSmGH6bu6hFchaapAat4dBXmb8CvjOm)FwgUEs1c0dfh(1POs7ZhnEAOB6XFJTLKvAYam0n94SkxEmtapxvckZ)NLHRNuTa9qbtdRs85Jgpn8bLjMjGNRkbL5)ZYW1tQwGEO4WVoffgSg9jlQG2Gfhpk7p7rrKBYqtmVJPXNScycFwR3O2auWqrdfromyn6twubTbloEu2F2JPOUAdqJggcMOpzfWe(e0A9g1gGcgkAOiYLeuZHRnTrUyHGY8)zz46jvlqpucBUcWYfCu9n7e4cSuBaYLeZeWZvLGJQVzNaxC4xNIk9d(kyKXrJpFusq6UXBCuevAu5t1AIkq)JZIal1gGC5YzJMmadDtpUmpljH2GaGX1RfDQGIi3KHMyEhtJpzz0eL(D5YPjdWq30JlZZ7sOniayC9ArNkOiYnzOjM3X04twgnrzEENvjUETOl85Jgpn8bLr2yhFfmY4OXNpkH2GaGX1RfDQGIi3KHMyEhtJpzz0eFwixUpF04PHpO0pVg74RGrghn(8X3OjdWq30JZkmyn6twubTbloEu2F2JPOUAdqJggcMOpzfWe(e0A9g1gGcgkAOiYLeZY12jlPFIk1n(8r2xR3O2au0OC(uTWG1Opzrf0gS44rz)zpMI6QnanAyiyI(KvarwIa0461Io9zrat4tqR1BuBakyOOHIixcBb5kalxWr13StGlWsTbixU8yMaEUQeCu9n7e4Id)6uuz85Jgpn0n94YLttgGHUPhxMfSkHTGCfGLlwpa046uUal1gGC5YPjdWq30JlZcwLeZY12jlPFIk1n(8r2xR3O2au0OC(uTsyliD34nokIknQ8PAnrfO)XzrGLAdqUC52mHHIOsJkFQwtub6FCweh(1POY4ZhnEAOB6XzTBTgp6KvF53dCHSiWxlW97wR0RMQL2T2L)BYZroKi7Hen6twqcyOovadUBbgQt770T42MddpKU13PV8I(oDlSuBaY7V0T0Opz1TOtZwwgWeIDR4noEJ2Tyds4PlOtZwwgWeIId)6uui5vHeE6c60SLLbmHOGZCQpzbjScjs)ajSbj80fABwSio8RtrHKxfs4Pl02SyrWzo1NSGewHejqcBqcpDbDA2YYaMquC4xNIcjVkKWtxqNMTSmGjefCMt9jliHvir6hiHniHNUiM3X04twId)6uui5vHeE6IyEhtJpzj4mN6twqcRqIeiHNUGonBzzatiko8RtrHePHeE6c60SLLbmHOGZCQpzbjVbjle73TatHMiVBTyPU3x(9(oDlSuBaY7V0T0Opz1T02SyPBfVXXB0UfBqcpDH2MflId)6uui5vHeE6cTnlweCMt9jliHvir6hiHniHNUiM3X04twId)6uui5vHeE6IyEhtJpzj4mN6twqcRqIeiHniHNUqBZIfXHFDkkK8QqcpDH2MflcoZP(KfKWkKi9dKWgKWtxqNMTSmGjefh(1POqYRcj80f0PzlldycrbN5uFYcsyfsKaj80fABwSio8RtrHePHeE6cTnlweCMt9jli5nizHy)Ufyk0e5DRfl19(Y733PBHLAdqE)LULg9jRUvmVJPXNS6wXBC8gTBXgKWtxeZ7yA8jlXHFDkkK8QqcpDrmVJPXNSeCMt9jliHvir6hiHniHNUqBZIfXHFDkkK8QqcpDH2MflcoZP(KfKWkKibsyds4PlI5Dmn(KL4WVoffsEviHNUiM3X04twcoZP(KfKWkKi9dKWgKWtxqNMTSmGjefh(1POqYRcj80f0PzlldycrbN5uFYcsyfsKaj80fX8oMgFYsC4xNIcjsdj80fX8oMgFYsWzo1NSGK3GKfI97wGPqtK3TwSu37E3IJHkdW770xErFNULg9jRUfTbbadiJs1TWsTbiV)s37l)EFNULg9jRUfhxNmN5RTtSBHLAdqE)LU3xE)(oDlSuBaY7V0TYMUff9ULg9jRU1A9g1gGDR1kGb7wUcWYf0CLX3qdfrovGLAdqoKibsOniayC9ArNkOiYnzOjM3X04twgnrirMhizFiHDi50HBW1y5IPwZak8uBakyAGe5YHexby5c60SLLbmHOal1gGCircKqBqaW461IovqrKBYqtmVJPXNSGezEGKLGe2HKthUbxJLlMAndOWtTbOGPbsKlhsOniayC9ArNkOiYnzOjM3X04twqImpqYRbjSdjNoCdUglxm1AgqHNAdqbtt3ATEMs)y3IHIgkI8U3xw2670TWsTbiV)s3kB6wu07wA0NS6wR1BuBa2TwRagSBPrFYsq3uEUYyNaxGVcgzC04ZhHK3GeD34nokIknQ8PAnrfO)XzrGLAdqE3ATEMs)y3Qr58PA7EF5L670TWsTbiV)s3kB6whsrVBPrFYQBTwVrTby3ATcyWUvBK3TI344nA3s3nEJJIOsJkFQwtub6FCweyP2aKdjsGe2Gexby5c(PtzOjdqGLAdqoKixoK4kalxWr13StGlWsTbihsKajXmb8Cvj4O6B2jWfh(1POqI0pqsBKdjS2TwRNP0p2TAuoFQ2U3xww23PBHLAdqE)LUv20TOO3T0Opz1TwR3O2aSBTwbmy3I2GaGX1RfDQGIi3KHMyEhtJpzz0eHePFGKfqc7qIRaSCXQB8n0mLrBZIfbwQna5qc7qIRaSCHAttaJJMyEhtJpzjWsTbihsEdsEhsyhsydsCfGLlwDJVHMPmABwSiWsTbihsKajUcWYf0CLX3qdfrovGLAdqoKibsOniayC9ArNkOiYnzOjM3X04twgnrirgi5DiHviHDiHniXvawUGonBzzatikWsTbihsKajbbjUcWYfXdXMPAnCu9nbwQna5qIeijiiXvawUGF6ugAYaeyP2aKdjScjSdjNoCdUglxm1AgqHNAdqbtt3ATEMs)y36Rt56ugk29(YY((oDlSuBaY7V0TYMUff9ULg9jRU1A9g1gGDR1kGb7wSbjbbjUcWYf0PzlldycrbwQna5qIC5qcpDbDA2YYaMquW0ajScjsGeE6cTnlweuxJsbjY8ajlcesKajbbj80fABwSiom8q6MAdqircKWtxeZ7yA8jlbtt3ATEMs)y3INo1W009(YVwFNUfwQna59x6wA0NS6wrfamA0NSmGH6DlWqDtPFSBfZeWZvfT79LLf9D6wyP2aK3FPBPrFYQBXpDkdnzaDRilraAC9ArN2xEr3kEJJ3ODlF(OXtdFqir6hiPnYHejqcnzag6MECirAizPUvCtNQBTOBnLJ3X04MwqARGU1IU3xErG9D6wyP2aK3FPBfVXXB0UfTbbaJRxl6ubfrUjdnX8oMgFYYOjcjs)ajVdjSdjNoCdUglxm1AgqHNAdqbtt3sJ(Kv3AtzkV79LxSOVt3cl1gG8(lDR4noEJ2T4Pl02Syr4tuQPAHejqcpDrmVJPXNSe(eLAQwircKWgKyZegk0OpRrdJsfuxJsbjpqYsqIC5qcnzag6MECi5bscesKlhs4PlA20YZVHovldqVXzrC4xNIcjsGeE6IMnT88BOt1Ya0BCweh(1POqI0pqsBKdjScjsGe2GKGGexby5IMnT88BOt1Ya0BCweyP2aKdjYLdj80fnBA553qNQLbO34Sio8RtrHewHejqcBqsqqIRaSCbhvFZobUal1gGCirUCijMjGNRkbhvFZobU4WVoffsK(bsAJCirUCijiijMjGNRkbhvFZobU4WVoffsKlhsOniayC9ArNkOiYnzOjM3X04twgnrirgizbKWoKC6Wn4ASCXuRzafEQnafmnqcRDln6twDlkZ)NLHRNuTa9WU3xEX79D6wyP2aK3FPBfVXXB0UvmtapxvckZ)NLHRNuTa9qXHFDkkKibswR3O2auWtNAyAGejqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjpqYciHDi50HBW1y5IPwZak8uBakyAGejqcBqsqqcsPyfrX6HozzYqtdEHy0NSe)PYdsKajbbj6UXBCuWpu5HmatubGPAfNwsbjYLdjXmb8CvjOm)FwgUEs1c0dfh(1POqImqY(bcjS2T0Opz1T4O6B2jW7EF5f733PBHLAdqE)LUv8ghVr7w2mHHIdJsbqk1eMxefh(1PODln6twDlFdnmLDYuCtyErS79LxiB9D6wyP2aK3FPBPrFYQBPTzXs3kEJJ3ODRd)6uuir6hiPnYHe2Hen6twc6MYZvg7e4c8vWiJJgF(iKibs85Jgpn8bHezGKxRBfzjcqJRxl60(Yl6EF5fl13PBHLAdqE)LUv8ghVr7w(8rirAiz)a7wA0NS6wF8NhlMm0ayId3Wpu)0U3xEHSSVt3cl1gG8(lDln6twDlTnlw6wXBC8gTB5ZhHezGK9desKajXmb8CvjOm)FwgUEs1c0dfh(1POqI0pqYILGejqcUlyMMgKl0Dt30tPMWSCtgAAYv41TatHMiVBTFGDVV8czFFNUfwQna59x6wA0NS6wX8oMgFYQBfVXXB0ULpFesKbs2pqircKeZeWZvLGY8)zz46jvlqpuC4xNIcjs)ajlwcsKaj4UGzAAqUq3nDtpLAcZYnzOPjxHhKibsccsCfGLluBAcyC0eZ7yA8jlbwQna5qIeiHniXvawUGonBzzatikWsTbihsKlhsOniayC9ArNkOiYnzOjM3X04twgnrirgizbKibsOniayC9ArNkOiYnzOjM3X04twgnrir6hizFiH1Ufyk0e5DR9dS79Lx8A9D6wyP2aK3FPBPrFYQBrNMTSmGje7wXBC8gTB5ZhHezGK9desKajXmb8CvjOm)FwgUEs1c0dfh(1POqI0pqYILGejqcUlyMMgKl0Dt30tPMWSCtgAAYv41TatHMiVBTFGDVV8czrFNUfwQna59x6wA0NS6wmf1vBaA0WqWe9jRUv8ghVr7wbbjXSCTDYcsKaj(8rJNg(GqI0pqYR1TISebOX1RfDAF5fDVV87b23PBHLAdqE)LULg9jRUf)0Pm0Kb0TISebOX1RfDAF5fDROwreyMWULprPOMd)6usVu3kEJJ3ODlxby5c6MYZvg8BFAefyP2aKdjsGK16nQnafFDkxNYqrircKWrBMWqbDt55kd(TpnIId)6uuircKWrBMWqbDt55kd(TpnIId)6uuir6hiPnYHK3GK37EF53x03PBHLAdqE)LULg9jRUfDt55kJDc8Uv8ghVr7wUcWYf0nLNRm43(0ikWsTbihsKajR1BuBak(6uUoLHIqIeiHJ2mHHc6MYZvg8BFAefh(1POqIeiHJ2mHHc6MYZvg8BFAefh(1POqI0pqc(kyKXrJpFesEdsEhsyhs8txJaJpFesKajbbjA0NSe0nLNRm2jWftzcbt7M3TISebOX1RfDAF5fDVV87V33PBHLAdqE)LULg9jRUvZMwE(n0PAza6nolDR4noEJ2T85JqImqY(lbjsGexVw0f(8rJNg(GqImqYczjK8gKqBqaWSPuhHejqcBqsqqcsPyfrX6HozzYqtdEHy0NSe)PYdsKajbbj6UXBCuWpu5HmatubGPAfNwsbjYLdjXmb8CvjOm)FwgUEs1c0dfh(1POqImqISTeKWoKqtgGHUPhhsEds0DJ34OGFOYdzaMOcat1koTKcsKlhsIzc45Qsqz()SmC9KQfOhko8RtrHePHKflbjVbj0geamBk1riHDiHMmadDtpoK8gKO7gVXrb)qLhYamrfaMQvCAjfKWA3kYseGgxVw0P9Lx09(YVVFFNUfwQna59x6wA0NS6wmf1vBaA0WqWe9jRUv8ghVr7wbbjR1BuBakyOOHIihsKaj0KbyOB6XHKhizPUvKLianUETOt7lVO79LFx2670TWsTbiV)s3kEJJ3ODR16nQnafmu0qrKdjsGeAYam0n94qYdKSu3sJ(Kv3IIi3KHMyEhtJpz19(YVVuFNUfwQna59x6wA0NS6wrfamA0NSmGH6DlWqDtPFSBXtN29(YVll770TWsTbiV)s3sJ(Kv3A9aqJRt5DR4noEJ2T85JqImqYILGejqIpF04PHpiKiZdKSiqircKWgKeZeWZvLGY8)zz46jvlqpuC4xNIcjYaj7hiKixoKeZeWZvLGY8)zz46jvlqpuC4xNIcjsdjlcesKaj80fABwSio8RtrHezEGKfbcjsGeE6IyEhtJpzjo8RtrHezEGKfbcjsGe2GeE6c60SLLbmHO4WVoffsK5bsweiKixoKeeK4kalxqNMTSmGjefyP2aKdjScjS2TISebOX1RfDAF5fDVV87Y((oDlSuBaY7V0T0Opz1T0Dt30tPMWSCtgAAYv41TI344nA3YNpcjs)aj73Tk9JDlD30n9uQjml3KHMMCfEDVV87VwFNUfwQna59x6wXBC8gTB5ZhHePFGK9xQBPrFYQB1SPLNFdDQwgGEJZs37l)USOVt3cl1gG8(lDR4noEJ2T85JqI0qYIL6wA0NS6wRhaACDkV79L3pW(oDlSuBaY7V0TI344nA3InijMjGNRkbL5)ZYW1tQwGEO4WVoffsKgswSeKWoKqtgGHUPhhsEds0DJ34OGFOYdzaMOcat1kWsTbihsKlhsyds0DJ34OGFOYdzaMOcat1koTKcsKlhsqkfRikwp0jltgAAWleJ(KL40skiHvircK4ZhHezGK9desKaj(8rJNg(GqImpqY7lcesyfsKajSbj80fnBA553qNQLbO34Sio8RtrHe5YHeE6I1danUoLlo8RtrHe5YHKGGexby5IMnT88BOt1Ya0BCweyP2aKdjsGKGGexby5I1danUoLlWsTbihsyfsKlhs85Jgpn8bHePHK9desyhsAJ8ULg9jRUvlJE8rltgA0DJx6BDVV8(l670TWsTbiV)s3kEJJ3ODRyMaEUQeuM)pldxpPAb6HId)6uuirAizXsqc7qcnzag6MECi5nir3nEJJc(HkpKbyIkamvRal1gGCircKWgKWtx0SPLNFdDQwgGEJZI4WVoffsKlhs4Plwpa046uU4WVoffsyTBPrFYQBX1tkdnzaDVV8(V33PBPrFYQBzJhfpPMQTBHLAdqE)LU3xE)9770TWsTbiV)s3sJ(Kv3kQaGrJ(KLbmuVBbgQBk9JDlAdwC8ODVV8(YwFNUfwQna59x6wA0NS6wrfamA0NSmGH6DlWqDtPFSBfoaaE0U39UvZHX8BREFN(Yl670T0Opz1TOm)FwMqeSXuoEDlSuBaY7V09(YV33PBHLAdqE)LUv8ghVr7wUcWYfT38Z5qtgAOA8MWjIcSuBaY7wA0NS6wT38Z5qtgAOA8MWjIDVV8(9D6wA0NS6wnPpz1TWsTbiV)s37llB9D6wyP2aK3FPBv6h7w6UPB6PutywUjdnn5k86wA0NS6w6UPB6PutywUjdnn5k86EF5L670TWsTbiV)s3kEJJ3ODlAdcagxVw0PckICtgAI5Dmn(KLrtesK5bs2hsKajbbj4UGzAAqUq3nDtpLAcZYnzOPjxHx3sJ(Kv3IIi3KHMyEhtJpz19(YYY(oDln6twDRnLP8UfwQna59x6EFzzFFNUfwQna59x6wXBC8gTBfeK4kalxSPmLlWsTbihsKaj0geamUETOtfue5Mm0eZ7yA8jlJMiKinKSpKibsccsWDbZ00GCHUB6MEk1eMLBYqttUcVULg9jRUfDt55kJDc8U39Uvmtapxv0(o9Lx03PBHLAdqE)LULg9jRULUB6MEk1eMLBYqttUcVUv8ghVr7wSbjbbjUcWYfnBA553qNQLbO34SiWsTbihsKlhsIzc45Qs0SPLNFdDQwgGEJZI4WVoffsKgsKni5niH2GaGztPocjYLdjbbjXmb8CvjA20YZVHovldqVXzrC4xNIcjScjsGKyMaEUQeuM)pldxpPAb6HId)6uuirAizHSasEdsOniay2uQJqc7qcnzag6MECi5nir3nEJJc(HkpKbyIkamvR40skircKWtxOTzXI4WVoffsKaj80fX8oMgFYsC4xNIcjsGe2GeE6c60SLLbmHO4WVoffsKlhsccsCfGLlOtZwwgWeIcSuBaYHew7wL(XULUB6MEk1eMLBYqttUcVU3x(9(oDlSuBaY7V0TI344nA3IniXvawUGRNugAYam)HIhlcSuBaYHejqsmtapxvckZ)NLHRNuTa9qbtdKibsIzc45QsW1tkdnzacMgiHvirUCijMjGNRkbL5)ZYW1tQwGEOGPbsKlhs85Jgpn8bHePHK9dSBPrFYQB1K(Kv37lVFFNUfwQna59x6wXBC8gTBfZeWZvLGY8)zz46jvlqpuC4xNIcjYajY(aHe5YHeF(OXtdFqirAi59aHe5YHe2Ge2GeBMWqHg9znAyuQG6Auki5bswcsKlhsOjdWq30JdjpqsGqcRqIeiHnijiiXvawUOztlp)g6uTma9gNfbwQna5qIC5qsmtapxvIMnT88BOt1Ya0BCweh(1POqcRqIeiHnijiiXvawUGJQVzNaxGLAdqoKixoKeZeWZvLGJQVzNaxC4xNIcjs)ajTroKixoKeeKeZeWZvLGJQVzNaxC4xNIcjScjsGKGGKyMaEUQeuM)pldxpPAb6HId)6uuiH1ULg9jRUfdfnJJFA37llB9D6wyP2aK3FPBfVXXB0UvqqsmtapxvckZ)NLHRNuTa9qbtt3sJ(Kv3kCo0gKjV79LxQVt3cl1gG8(lDR4noEJ2TccsIzc45Qsqz()SmC9KQfOhkyA6wA0NS6w2Gm5MqMJLU3xww23PBHLAdqE)LUv8ghVr7w(8rirgiz)a7wA0NS6wF8NhlMm0ayId3Wpu)0U3xw233PBHLAdqE)LUv8ghVr7w(8rJNg(GqI0qY7bcjSdjTroKixoK4kalxqZvgFdnue5ubwQna5qIeijMjGNRkbL5)ZYW1tQwGEO4WVoffsK5bsIzc45Qsqz()SmC9KQfOhk4mN6twqIScjlcSBPrFYQBX1tkdnzaDVV8R13PBHLAdqE)LUv8ghVr7wnOl46jvlqpuC4xNIcjYLdjSbjbbjXmb8Cvj4O6B2jWfh(1POqIC5qsqqIRaSCbhvFZobUal1gGCiHvircKeZeWZvLGY8)zz46jvlqpuC4xNIcjY8ajVwGqIeibPuSIOWgKj3KHgFdnyHFweNwsbjYajl6wA0NS6w2Gm5Mm04BObl8Zs37lll670TWsTbiV)s3sJ(Kv3QjJsHoD2nYnX83W4Qpzz446jIDR4noEJ2TydsIzc45Qsqz()SmC9KQfOhko8RtrHezEGK3xcsKlhs85Jgpn8bHePFGK9desyfsKajSbjXmb8Cvj4O6B2jWfh(1POqIC5qsqqIRaSCbhvFZobUal1gGCiH1UvPFSB1KrPqNo7g5My(ByC1NSmCC9eXU3xErG9D6wyP2aK3FPBPrFYQBDPhpgQJCZ6m5zA4ja0TI344nA3InijMjGNRkbL5)ZYW1tQwGEO4WVoffsK5bsEFjirUCiXNpA80WhesK(bs2pqiHvircKWgKeZeWZvLGJQVzNaxC4xNIcjYLdjbbjUcWYfCu9n7e4cSuBaYHew7wL(XU1LE8yOoYnRZKNPHNaq37lVyrFNUfwQna59x6wA0NS6w0TznEM1yLFZHGj2TI344nA3InijMjGNRkbL5)ZYW1tQwGEO4WVoffsK5bsEFjirUCiXNpA80WhesK(bs2pqiHvircKWgKeZeWZvLGJQVzNaxC4xNIcjYLdjbbjUcWYfCu9n7e4cSuBaYHew7wL(XUfDBwJNznw53CiyIDVV8I3770TWsTbiV)s3sJ(Kv3s3fmtt6y5Msz8bWq7wXBC8gTBXgKeZeWZvLGY8)zz46jvlqpuC4xNIcjY8ajVVeKixoK4ZhnEA4dcjs)aj7hiKWkKibsydsIzc45QsWr13StGlo8RtrHe5YHKGGexby5coQ(MDcCbwQna5qcRDRs)y3s3fmtt6y5Msz8bWq7EF5f733PBHLAdqE)LULg9jRULpCK659nXKJVs3kEJJ3ODl2GKyMaEUQeuM)pldxpPAb6HId)6uuirMhi59LGe5YHeF(OXtdFqir6hiz)aHewHejqcBqsmtapxvcoQ(MDcCXHFDkkKixoKeeK4kalxWr13StGlWsTbihsyTBv6h7w(WrQN33eto(kDVV8czRVt3cl1gG8(lDln6twDR1JcmzOH659PDR4noEJ2TydsIzc45Qsqz()SmC9KQfOhko8RtrHezEGK3xcsKlhs85Jgpn8bHePFGK9desyfsKajSbjXmb8Cvj4O6B2jWfh(1POqIC5qsqqIRaSCbhvFZobUal1gGCiH1UvPFSBTEuGjdnupVpT79LxSuFNUfwQna59x6wXBC8gTBzZegkatiAdYKlOUgLcsKgs2VBPrFYQBTkpaFnoL5qAwAfXU3xEHSSVt3sJ(Kv36MMgaAMYqB0i2TWsTbiV)s37E3I2GfhpAFN(Yl670TWsTbiV)s3kEJJ3ODRyMaEUQeuM)pldxpPAb6HId)6uuir6hiHMmadDtpoK8gKWgKGVcgzC04ZhHe2HeD34nok4hQ8qgGjQaWuTItlPGewHejqcBqsqqIRaSCbhvFZobUal1gGCirUCijMjGNRkbhvFZobU4WVoffsK(bsOjdWq30JdjVbj4RGrghn(8riHvircKWgK4kalxqZvgFdnue5ubwQna5qIC5qcpDrZMwE(n0PAza6nolId)6uuirUCiHNUy9aqJRt5Id)6uuiH1ULg9jRUftrD1gGgnmemrFYQ79LFVVt3cl1gG8(lDR4noEJ2TydsIzc45Qsqz()SmC9KQfOhko8RtrHePHeF(OXtdDtpoK8gKWgKSeKiRqcnzag6MECiHvirUCijMjGNRkbL5)ZYW1tQwGEOGPbsyfsKaj(8rJNg(GqImqsmtapxvckZ)NLHRNuTa9qXHFDkA3sJ(Kv3kQaGrJ(KLbmuVBbgQBk9JDRWbaWJ29(Y733PBHLAdqE)LUv8ghVr7wR1BuBakyOOHIiVBPrFYQBrrKBYqtmVJPXNS6EFzzRVt3cl1gG8(lDR4noEJ2TccswR3O2auWqrdfroKibsccsAoCTPnYfleuM)pldxpPAb6HqIeiHniXvawUGJQVzNaxGLAdqoKibsIzc45QsWr13StGlo8RtrHePFGe8vWiJJgF(iKibsccs0DJ34OiQ0OYNQ1evG(hNfbwQna5qIC5qcBqcnzag6MECirMhizjircKqBqaW461IovqrKBYqtmVJPXNSmAIqI0qY7qIC5qcnzag6MECirMhi5DircKqBqaW461IovqrKBYqtmVJPXNSmAIqImpqY7qcRqIeiX1RfDHpF04PHpiKidKiBqc7qc(kyKXrJpFesKaj0geamUETOtfue5Mm0eZ7yA8jlJMiK8ajlGe5YHeF(OXtdFqir6hi51Ge2He8vWiJJgF(iK8gKqtgGHUPhhsyTBPrFYQBXuuxTbOrddbt0NS6EF5L670TWsTbiV)s3kEJJ3ODRGGK16nQnafmu0qrKdjsGKywU2ozbjs)ajrL6gF(iKWoKSwVrTbOOr58PA7wA0NS6wmf1vBaA0WqWe9jRU3xww23PBHLAdqE)LULg9jRUftrD1gGgnmemrFYQBfVXXB0UvqqYA9g1gGcgkAOiYHejqcBqsqqIRaSCbhvFZobUal1gGCirUCijMjGNRkbhvFZobU4WVoffsKbs85Jgpn0n94qIC5qcnzag6MECirgizbKWkKibsydsccsCfGLlwpa046uUal1gGCirUCiHMmadDtpoKidKSasyfsKajXSCTDYcsK(bsIk1n(8riHDizTEJAdqrJY5t1cjsGe2GKGGeD34nokIknQ8PAnrfO)XzrGLAdqoKixoKyZegkIknQ8PAnrfO)XzrC4xNIcjYaj(8rJNg6MECiH1UvKLianUETOt7lVO7DVBfoaaE0(o9Lx03PBHLAdqE)LULg9jRUftrD1gGgnmemrFYQBfVXXB0UvmtapxvcoQ(MDcCXHFDkkKi9dK0g5qYBqY7qIeiH2GaGX1RfDQGIi3KHMyEhtJpzz0eHKhizbKWoKC6Wn4ASCXuRzafEQnafmnqIeijMjGNRkbL5)ZYW1tQwGEO4WVoffsKbsEpWUfyk0e5DRfl19(YV33PBHLAdqE)LUv8ghVr7wUcWYfCu9n7e4cSuBaYHejqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjpqYciHDi50HBW1y5IPwZak8uBakyAGejqcBqcpDH2MflId)6uuirAiHNUqBZIfbN5uFYcsEdscui7xcsKlhs4PlI5Dmn(KL4WVoffsKgs4PlI5Dmn(KLGZCQpzbjVbjbkK9lbjYLdj80f0PzlldycrXHFDkkKinKWtxqNMTSmGjefCMt9jli5nijqHSFjiHvircKeZeWZvLGJQVzNaxC4xNIcjs)ajA0NSeABwSiAJCi5nir2GejqsmtapxvckZ)NLHRNuTa9qXHFDkkKidK8EGDln6twDROcagn6twgWq9UfyOUP0p2T42MddpKU19(Y733PBHLAdqE)LUv8ghVr7wUcWYfCu9n7e4cSuBaYHejqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjpqYciHDi50HBW1y5IPwZak8uBakyAGejqsmtapxvckZ)NLHRNuTa9qXHFDkkKi9dKqtgGHUPhhsEds0Opzj02Syr0g5qc7qIg9jlH2MflI2ihsEds2hsKajSbj80fABwSio8RtrHePHeE6cTnlweCMt9jli5nizbKixoKWtxeZ7yA8jlXHFDkkKinKWtxeZ7yA8jlbN5uFYcsEdswajYLdj80f0PzlldycrXHFDkkKinKWtxqNMTSmGjefCMt9jli5nizbKWA3sJ(Kv3kQaGrJ(KLbmuVBbgQBk9JDlUT5WWdPBDVVSS13PBHLAdqE)LUv8ghVr7wR1BuBak4PtnmnqIeiHnijMjGNRkbL5)ZYW1tQwGEO4WVoffsK5bs2pqiHDiPnYHe5YHKyMaEUQeuM)pldxpPAb6HId)6uuirgizHSfiKWA3sJ(Kv3IJQVzNaV79LxQVt3cl1gG8(lDR4noEJ2TSzcdf)Cn(XYfmnqIeiXMjmuut7MhQaG4WVofTBPrFYQBr3uEUYyNaV79LLL9D6wyP2aK3FPBfVXXB0ULntyO4NRXpwUGPbsKajbbjSbjUcWYf0PzlldycrbwQna5qIeiHniP5W1M2ixSqOTzXcKibsAoCTPnYfVl02SybsKajnhU20g5I9fABwSajScjYLdjnhU20g5IfcTnlwGew7wA0NS6wABwS09(YY((oDlSuBaY7V0TI344nA3YMjmu8Z14hlxW0ajsGKGGe2GKMdxBAJCXcbDA2YYaMqesKajnhU20g5I3f0PzlldycrircK0C4AtBKl2xqNMTSmGjeHew7wA0NS6w0PzlldycXU3x(1670TWsTbiV)s3kEJJ3ODlBMWqXpxJFSCbtdKibsccsAoCTPnYfleX8oMgFYcsKajbbjUcWYfQnnbmoAI5Dmn(KLal1gG8ULg9jRUvmVJPXNS6EFzzrFNUfwQna59x6wXBC8gTBzZegkMcxpUAdqdh)dffuxJsbjYajlcesKaj(8rJNg(GqI0pqYIa7wA0NS6w8tNYaMqS79LxeyFNUfwQna59x6wXBC8gTB5kalxqNMTSmGjefyP2aKdjsGeBMWqXu46XvBaA44FOOG6AukirMhizPaHezfsEpqi5niHniH2GaGX1RfDQGIi3KHMyEhtJpzz0eHezfsoD4gCnwUyQ1mGcp1gGcMgirMhi5DiHvircKWtxOTzXI4WVoffsKbswcsEdsOniay2uQJqIeiHNUiM3X04twId)6uuirgiPnYHejqcBqcpDbDA2YYaMquC4xNIcjYajTroKixoKeeK4kalxqNMTSmGjefyP2aKdjScjsGe2GeoAZegk2uMYfh(1POqImqYsqYBqcTbbaZMsDesKlhsccsCfGLl2uMYfyP2aKdjScjsGKywU2ozbjYajlbjVbj0geamBk1XULg9jRUf)0PmGje7EF5fl670TWsTbiV)s3kEJJ3ODlxby5Iv34BOzkJ2MflcSuBaYHejqIntyOykC94QnanC8puuqDnkfKiZdKSuGqIScjVhiK8gKWgKqBqaW461IovqrKBYqtmVJPXNSmAIqIScjNoCdUglxm1AgqHNAdqbtdKiZdKSpKWkKiRqYsqYBqcBqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjYkKC6Wn4ASCXuRzafEQnafmnqYdK8oKWkKibs4Pl02SyrC4xNIcjYajlbjVbj0geamBk1rircKWtxeZ7yA8jlXHFDkkKidK0g5qIeiHniHJ2mHHInLPCXHFDkkKidKSeK8gKqBqaWSPuhHe5YHKGGexby5InLPCbwQna5qcRqIeijMLRTtwqImqYsqYBqcTbbaZMsDSBPrFYQBXpDkdycXU3xEX79D6wyP2aK3FPBfVXXB0ULRaSCHAttaJJMyEhtJpzjWsTbihsKaj2mHHIPW1JR2a0WX)qrb11OuqImpqYsbcjYkK8EGqYBqcBqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjYkKC6Wn4ASCXuRzafEQnafmnqImpqISbjScjsGeE6cTnlweh(1POqImqYsqYBqcTbbaZMsDesKajSbjC0MjmuSPmLlo8RtrHezGKLGK3GeAdcaMnL6iKixoKeeK4kalxSPmLlWsTbihsyfsKajXSCTDYcsKbswcsEdsOniay2uQJDln6twDl(Ptzati29(Yl2VVt3sJ(Kv3AtzkVBHLAdqE)LU3xEHS13PBPrFYQBfMrgkYn6UXBC0yJ6VBHLAdqE)LU3xEXs9D6wA0NS6wnm3eYYuTgBGs9UfwQna59x6EF5fYY(oDlSuBaY7V0TI344nA3kiiHNUiMvel)uh5MqG(rJnZvId)6uuircKeeKOrFYseZkILFQJCtiq)OyktiyA38ULg9jRUvmRiw(PoYnHa9JDVV8czFFNUfwQna59x6wA0NS6w8tNYqtgq3kYseGgxVw0P9Lx0TMYX7yA8U1IUv8ghVr7w(8rJNg(GqI0pqsBK3TIB6uDRfDRPC8oMg30csBf0Tw09(YlET(oDlSuBaY7V0T0Opz1T4NoLHMmGUvKLianUETOt7lVOBnLJ3X04MjSB5tukQ5WVoL0l1TI344nA3YvawUGUP8CLb)2NgrbwQna5qIeizTEJAdqXxNY1PmuesKajbbjC0Mjmuq3uEUYGF7tJO4WVofTBf30P6wl6wt54DmnUPfK2kOBTO79Lxil670TWsTbiV)s3sJ(Kv3IF6ugAYa6wrwIa0461IoTV8IU1uoEhtJBMWULprPOMd)6usVu3kEJJ3ODlxby5c6MYZvg8BFAefyP2aKdjsGK16nQnafFDkxNYqXUvCtNQBTOBnLJ3X04MwqARGU1IU3x(9a770TWsTbiV)s3sJ(Kv3IF6ugAYa6wt54DmnE3Ar3kUPt1Tw0TMYX7yACtliTvq3Ar37l)(I(oDlSuBaY7V0T0Opz1TOBkpxzStG3TI344nA3YvawUGUP8CLb)2NgrbwQna5qIeizTEJAdqXxNY1PmuesKajbbjC0Mjmuq3uEUYGF7tJO4WVoffsKajbbjA0NSe0nLNRm2jWftzcbt7M3TISebOX1RfDAF5fDVV87V33PBHLAdqE)LULg9jRUfDt55kJDc8Uv8ghVr7wUcWYf0nLNRm43(0ikWsTbihsKajR1BuBak(6uUoLHIDRilraAC9ArN2xEr37l)((9D6wA0NS6w0nLNRm2jW7wyP2aK3FP7DVBXtN23PV8I(oDlSuBaY7V0TI344nA3INUiM3X04twId)6uuir6hirJ(KLGIi3KHMyEhtJpzjIk1n(8riHDiXNpA80q30JdjSdjYM4Di5niHnizbKiRqIRaSCr8qSzQwdhvFtGLAdqoK8gKeOyXsqcRqIeiH2GaGX1RfDQGIi3KHMyEhtJpzz0eHezEGK9He2HKthUbxJLlMAndOWtTbOGPbsyhsCfGLlwDJVHMPmABwSiWsTbihsKajbbj80fue5Mm0eZ7yA8jlXHFDkkKibsccs0OpzjOiYnzOjM3X04twIPmHGPDZ7wA0NS6wue5Mm0eZ7yA8jRU3x(9(oDlSuBaY7V0T0Opz1T02SyPBfVXXB0ULRaSCr8qSzQwdhvFtGLAdqoKibs0OpRrdpDH2MflqI0qISesKaj(8rJNg(GqImqYIaHejqcBqYHFDkkKi9dK0g5qIC5qsmtapxvckZ)NLHRNuTa9qXHFDkkKidKSiqircKWgKC4xNIcjsdjlbjYLdjbbj6UXBCu0Ofh)t0m16mQ(KL40skircKCy4H0n1gGqcRqcRDRilraAC9ArN2xEr37lVFFNUfwQna59x6wA0NS6wABwS0TI344nA3kiiXvawUiEi2mvRHJQVjWsTbihsKajA0N1OHNUqBZIfirAi51GejqIpF04PHpiKidKSiqircKWgKC4xNIcjs)ajTroKixoKeZeWZvLGY8)zz46jvlqpuC4xNIcjYajlcesKajSbjh(1POqI0qYsqIC5qsqqIUB8ghfnAXX)entToJQpzjoTKcsKajhgEiDtTbiKWkKWA3kYseGgxVw0P9Lx09(YYwFNUfwQna59x6wA0NS6w0PzlldycXUv8ghVr7wSbjA0N1OHNUGonBzzaticjsdjVgKiRqIRaSCr8qSzQwdhvFtGLAdqoKiRqcTbbaJRxl6ubnxz8n0qrKtnAIqcRqIeiXNpA80WhesKbsweiKibsom8q6MAdqircKWgKeeKC4xNIcjsGeAdcagxVw0PckICtgAI5Dmn(KLrtesEGKfqIC5qsmtapxvckZ)NLHRNuTa9qXHFDkkKidKqtgGHUPhhsEds0OpzjykQR2a0OHHGj6twc8vWiJJgF(iKWA3kYseGgxVw0P9Lx09(Yl13PBHLAdqE)LULg9jRUvmVJPXNS6wXBC8gTBrBqaW461IovqrKBYqtmVJPXNSmAIqI0qY(qc7qYPd3GRXYftTMbu4P2auW0ajSdjUcWYfRUX3qZugTnlweyP2aKdjsGe2GKd)6uuir6hiPnYHe5YHKyMaEUQeuM)pldxpPAb6HId)6uuirgizrGqIei5WWdPBQnaHewHejqIRxl6cF(OXtdFqirgizrGDRilraAC9ArN2xEr37E37wkJVLx3YA(VoDV79o]] )


end