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


    spec:RegisterPack( "Affliction", 20190722, [[dCe6kcqibvpsPkCjLQuBIi9javvmkIWPqQSkaLxHuAwevDlbb7IWVuQ0WeuoMsyzkv1ZaettquxtjQTjiIVjiKXbOkNtqKwNsveZJi6EaSpIkhuqOAHaspuPkQMOGq5IaQQ0jvQIuRuqAMaQQYnbuvv7ujYsvQIYtjLPQuXvvQIK(QsvKyVs1FjzWiomLftQESqtgvxgAZc8zP0OvkNwXRrQA2Q62aTBj)w0WLIJdOQSCvEoktNQRJKTRK67kjJxPk58ifRhqL5tu2pO7l67014MJ9L2pSfH0Wcr7VViSWczGSpWRR500GDTglsV1IDTYaXUwiEqWprFYQR1y08PX7701yj1fXU2M7nS9KD3TD8nkDrmb3LnGuV5twXZc8DzdyC3UMo18(E6QR314MJ9L2pSfH0Wcr7VViSWczGewiQRXAWyFP9djl312gohRUExJJSyxBpGKq8GGFI(KfKSNIDFgPhg6EajBU3W2t2D32X3O0fXeCx2as9MpzfplW3LnGXDHHUhqsOupnqY(lKhs2pSfHuijeGK9xSNaKWGHcdDpGK98nRAr2Ecm09ascbijeNZroKO1G)dja)Lr6fWq3dijeGKqCoh5qsigUoPoib4FRDIcyO7bKecqYEgcMRroK421IUAcecbm09ascbizpdb(OMdHKqSChgKq1ajzbjUDTOdjb5bjHyO5B657qIeSPIiKCyWHSni5Z2jcjdds4tqaEy5qYeaj75HymiXoes4dZ0FKtNag6EajHaKSNHnVfriHHRXZEiXTRfDHpGOYtfFqijAmKbjRgFds8bevEQ4dcjsGfhsYaibRysvoE0j6Anxgmp212dijepi4NOpzbj7Py3Nr6HHUhqYM7nS9KD3TD8nkDrmb3LnGuV5twXZc8DzdyCxyO7bKek1tdKS)c5HK9dBrifscbiz)f7jajmyOWq3dizpFZQwKTNadDpGKqascX5CKdjAn4)qcWFzKEbm09ascbijeNZroKeIHRtQdsa(3ANOag6EajHaKSNHG5AKdjUDTORMaHqadDpGKqas2ZqGpQ5qijel3HbjunqswqIBxl6qsqEqsigA(ME(oKibBQicjhgCiBds(SDIqYWGe(eeGhwoKmbqYEEigdsSdHe(Wm9h50jGHUhqsiaj7zyZBresy4A8ShsC7Arx4diQ8uXhesIgdzqYQX3GeFarLNk(GqIeyXHKmasWkMuLJhDcyOWq3dib439cJuoYHeDmipesIjOU5qIo2oftajH4Xi24miPYke2SdmG6Hel6twmijRNgbm09asSOpzXenhgtqDZbe8gJEyO7bKyrFYIjAomMG6MtlGDdYKddDpGel6twmrZHXeu3CAbSRr1cILB(Kfmul6twmrZHXeu3CAbSlJcemlvd6WqTOpzXenhgtqDZPfWUT3aMZHQmqXS4nbteLFca42JLlAVbmNdvzGIzXBcMikWY0FKddDpGel6twmrZHXeu3CAbSlRSg2w6kMBodgQf9jlMO5WycQBoTa2Tj9jlyOw0NSyIMdJjOU50cyxgICvgOI5Dun(KL8taawd(VYTRfDMGHixLbQyEhvJpzPSeLdaqGHArFYIjAomMG6MtlGD3mQYHHArFYIjAomMG6MtlGDzBgpxP0Z3LFcaeUBpwUyZOkxGLP)ixkRb)x521IotWqKRYavmVJQXNSuwIsceyOWq3dib439cJuoYHeCnE0aj(aIqIVHqIf98GKHbj2ABEt)rbmul6twmaSg8F1Nr6HHArFYIrlGD546K6uGw7eHHArFYIrlGDxB3y6pkFzGiakgQyiYLFT9uia3ESCblxP8nuXqKZeyz6pYLYAW)vUDTOZeme5QmqfZ7OA8jlLLOCaacTNnCfUglxm1AQVWZ0Fuq1itMBpwUGnnBzP(jafyz6pYLYAW)vUDTOZeme5QmqfZ7OA8jl5aSmTNnCfUglxm1AQVWZ0Fuq1itgRb)x521IotWqKRYavmVJQXNSKdaWJ2ZgUcxJLlMAn1x4z6pkOAGHArFYIrlGDxB3y6pkFzGiGgJZNQv(SbadD5xBpfcWI(KLGTz8CLspFxG7fgPCu5dicmd4WBCuenw04t1QI2BGJtJalt)romul6twmAbS7A7gt)r5ldeb0yC(uTYNnaoKHU8RTNcb0g5YpbamGdVXrr0yrJpvRkAVbooncSm9h5sLWThlxWpBkflPEbwM(JCzYC7XYfC08n98DbwM(JCPXmFEUQeC08n98DXHG2umjb0g50bd1I(KfJwa7U2UX0Fu(YaraG2uUnLIHYV2EkeaRb)x521IotWqKRYavmVJQXNSuwIscybTU9y5Iv34BOAkL1MfncSm9h5062JLlmDw(uoQI5Dun(KLalt)roW2NwjC7XYfRUX3q1ukRnlAeyz6pYL62JLly5kLVHkgICMalt)rUuwd(VYTRfDMGHixLbQyEhvJpzPSeLBF6Ovc3ESCbBA2Ys9takWY0FKlnC3ESCr8qSzQwfhnFtGLP)ixA4U9y5c(ztPyj1lWY0FKthTNnCfUglxm1AQVWZ0Fuq1ad1I(KfJwa7U2UX0Fu(Yara80zkQg5xBpfcqIWD7XYfSPzll1pbOalt)rUmz80fSPzll1pbOGQHoP80fwBw0iyUfPxoalctA480fwBw0iom4q2MP)OuE6IyEhvJpzjOAGHArFYIrlGDJ2)kl6twQFyU8LbIaIz(8CvXGHArFYIrlGD5NnLILuV8t54DunUQ9tD7bSq(4MnfGfYhPj(OYTRfDgGfYpba8bevEQ4dkjG2ixklPEfBZoUKldd1I(KfJwa7UzuLl)eaG1G)RC7ArNjyiYvzGkM3r14twklrjbSpTNnCfUglxm1AQVWZ0Fuq1ad1I(KfJwa7YOabZsXTJ(23ou(jaapDH1MfncFI0pvRuE6IyEhvJpzj8js)uTsLqNkiqyrFwJkkJjyUfPhWYYKXsQxX2SJdim6Kkr4U9y5IMnR8euXMQL6TBCAeyz6pYLjJNUOzZkpbvSPAPE7gNgXHG2um6Kkr4U9y5coA(ME(Ualt)rUmzXmFEUQeC08n98DXHG2umjb0g5YKfEmZNNRkbhnFtpFxCiOnftMmwd(VYTRfDMGHixLbQyEhvJpzPSeLBbTNnCfUglxm1AQVWZ0Fuq1qhmul6twmAbSlhnFtpFx(jaqmZNNRkbJcemlf3o6BF7qXHG2umPRTBm9hf80zkQgPSg8FLBxl6mbdrUkduX8oQgFYszjcybTNnCfUglxm1AQVWZ0Fuq1ivIWrgdRikwpSjlvgOAWlaJ(KLaCQ8KgUbC4nok4hA8aQxfT)NQvCwrVmzXmFEUQemkqWSuC7OV9TdfhcAtXKdiHrhmul6twmAbSRVHkQspPkUkiVik)eaqNkiqCyK(hzmvqEruCiOnfdgQf9jlgTa21AZIg5J0eFu521IodWc5NaahcAtXKeqBKtRf9jlbBZ45kLE(Ua3lms5OYhquQpGOYtfFq5aEWqTOpzXOfWUGiyE0OYa1tfhUIFObYKFca4dikjqcdg6Eaj7GGn5zhnqsWSxqINqcOrpcjmQdHed4yB2za)WGKGSCiHNiRa(XHe9dn6HeUD03(2HqcfZArbmul6twmAbSR1MfnY)tHQihaqct(jaqmZNNRkbJcemlf3o6BF7qXHG2umjbSyzPiWh100GCXIqsifilczyOw0NSy0cy3yEhvJpzj)pfQICaajm5NaaXmFEUQemkqWSuC7OV9TdfhcAtXKeWILLIaFuttdYflcjHuGSiKLgUBpwUW0z5t5OkM3r14twcSm9h5sLWThlxWMMTSu)eGcSm9h5YKXAW)vUDTOZeme5QmqfZ7OA8jlLLOClKYAW)vUDTOZeme5QmqfZ7OA8jlLLOKaacDWqTOpzXOfWUSPzll1pbO8)uOkYbaKWKFcaeZ855QsWOabZsXTJ(23ouCiOnftsalwwkc8rnnnixSiKesbYIqggQf9jlgTa2LQyUP)OYcc(j6twYhPj(OYTRfDgGfYpbacpMLBTtws9bevEQ4dkjaGhmul6twmAbSl)SPuSK6Lpst8rLBxl6malKpAveF1eaWNi9m1HG2usUS8taa3ESCbBZ45kfcQFwefyz6pYLU2UX0FuaAt52ukgkLJ6ubbc2MXZvkeu)Sikoe0MIjLJ6ubbc2MXZvkeu)Sikoe0MIjjG2ihy7dd1I(KfJwa7Y2mEUsPNVlFKM4Jk3Uw0zawi)eaWThlxW2mEUsHG6NfrbwM(JCPRTBm9hfG2uUnLIHs5OovqGGTz8CLcb1plIIdbTPys5OovqGGTz8CLcb1plIIdbTPysca3lms5OYhqey7tRF2A8v(aIsd3I(KLGTz8CLspFxmLk4N2nhgQf9jlgTa2TzZkpbvSPAPE7gNg5J0eFu521IodWc5Naa(aIYbKLL621IUWhqu5PIpOClcjaJ1G)R2mMJsLiCKXWkII1dBYsLbQg8cWOpzjaNkpPHBahEJJc(HgpG6vr7)PAfNv0ltwmZNNRkbJcemlf3o6BF7qXHG2um5c5LPLLuVITzhhygWH34OGFOXdOEv0(FQwXzf9YKfZ855QsWOabZsXTJ(23ouCiOnftYfldmwd(VAZyosllPEfBZooWmGdVXrb)qJhq9QO9)uTIZk6PdgQf9jlgTa2LQyUP)OYcc(j6twYhPj(OYTRfDgGfYpbacFTDJP)OGIHkgICPSK6vSn74awggQf9jlgTa2LHixLbQyEhvJpzj)eayTDJP)OGIHkgICPSK6vSn74awggQf9jlgTa2nA)RSOpzP(H5YxgicGNodgQf9jlgTa2D98OYTPC5J0eFu521IodWc5Naa(aIYTyzPUDTOl8bevEQ4dkhGfHjvIyMppxvcgfiywkUD03(2HIdbTPyYbKWKjlM5ZZvLGrbcMLIBh9TVDO4qqBkMKlctkpDH1MfnIdbTPyYbyrys5PlI5Dun(KL4qqBkMCaweMuj4PlytZwwQFcqXHG2um5aSimzYc3ThlxWMMTSu)eGcSm9h50rhmul6twmAbSlfdvJJGYxgicWao2MDgtfKLRYavtUcp5Naa(aIscaiWqTOpzXOfWUnBw5jOInvl1B340i)eaWhqusaazzyOw0NSy0cy31ZJk3MYLFca4dik5ILHHArFYIrlGDBPSJpwPYaLbC4L(M8taajIz(8CvjyuGGzP42rF7Bhkoe0MIj5ILPLLuVITzhhygWH34OGFOXdOEv0(FQwbwM(JCzYKWao8ghf8dnEa1RI2)t1koROxMmKXWkII1dBYsLbQg8cWOpzjoRONoP(aIYbKWK621IUWhqu5PIpOCa2Fry0jvcE6IMnR8euXMQL6TBCAehcAtXKjJNUy98OYTPCXHG2umzYc3Thlx0SzLNGk2uTuVDJtJalt)rU0WD7XYfRNhvUnLlWY0FKtNmz(aIkpv8bLeiHrBBKdd1I(KfJwa7YTJEflPE5NaaXmFEUQemkqWSuC7OV9TdfhcAtXKCXY0YsQxX2SJdmd4WBCuWp04buVkA)pvRalt)rUuj4PlA2SYtqfBQwQ3UXPrCiOnftMmE6I1ZJk3MYfhcAtXOdgQf9jlgTa2vhpgE0pvlmul6twmAbSB0(xzrFYs9dZLVmqeaRbloEmyOw0NSy0cy3O9VYI(KL6hMlFzGiGG5F8yWqHHArFYIjIz(8CvXaqXq14iO8LbIamGJTzNXubz5Qmq1KRWt(jaGeH72JLlA2SYtqfBQwQ3UXPrGLP)ixMSyMppxvIMnR8euXMQL6TBCAehcAtXKmKbgRb)xTzmhLjl8yMppxvIMnR8euXMQL6TBCAehcAtXOtAmZNNRkbJcemlf3o6BF7qXHG2umjxesbgRb)xTzmhPLLuVITzhhygWH34OGFOXdOEv0(FQwXzf9s5PlS2SOrCiOnftkpDrmVJQXNSehcAtXKkbpDbBA2Ys9takoe0MIjtw4U9y5c20SLL6NauGLP)iNoyOw0NSyIyMppxvmAbSBt6twYpbaKWThlxWTJEflPEf4WWJgbwM(JCPXmFEUQemkqWSuC7OV9TdfunsJz(8Cvj42rVILuVGQHozYIz(8CvjyuGGzP42rF7BhkOAKjZhqu5PIpOKajmyOw0NSyIyMppxvmAbSlfdvJJGm5NaaXmFEUQemkqWSuC7OV9TdfhcAtXKlefMmz(aIkpv8bLC)WKjtcj0Pccew0N1OIYycMBr6bSSmzSK6vSn74acJoPseUBpwUOzZkpbvSPAPE7gNgbwM(JCzYIz(8CvjA2SYtqfBQwQ3UXPrCiOnfJoPseUBpwUGJMVPNVlWY0FKltwmZNNRkbhnFtpFxCiOnftsaTrUmzHhZ855QsWrZ30Z3fhcAtXOtA4XmFEUQemkqWSuC7OV9TdfhcAtXOdgQf9jlMiM5ZZvfJwa7gmhQ)zYLFcaeEmZNNRkbJcemlf3o6BF7qbvdmul6twmrmZNNRkgTa2v)ZKRcOoAKFcaeEmZNNRkbJcemlf3o6BF7qbvdmul6twmrmZNNRkgTa2febZJgvgOEQ4Wv8dnqM8taaFar5asyWqTOpzXeXmFEUQy0cyxUD0Ryj1l)eaWhqu5PIpOK7hgTTrUmzSg8FLBxl6mbdrUkduX8oQgFYszjk3cApB4kCnwUyQ1uFHNP)OGQrMm3ESCblxP8nuXqKZeyz6pYLgZ855QsWOabZsXTJ(23ouCiOnftoaXmFEUQemkqWSuC7OV9TdfCQZ8jRqyryWqTOpzXeXmFEUQy0cyx9ptUkdu(gQWcbPr(jaqd6cUD03(2HIdbTPyYKjr4XmFEUQeC08n98DXHG2umzYc3ThlxWrZ30Z3fyz6pYPtAmZNNRkbJcemlf3o6BF7qXHG2um5aa8ctkYyyfrH(NjxLbkFdvyHG0ioROxUfWq3dizpvgcjCd0ANQfsYkeOyiK43u0JodsaZdHK8GKhzmijlijM5ZZvL8qclHKpRwiXyqIVHqYE698qmiX3qAGKPIuhKSklGFCibdcWOdjwrdKK(gEqIFtrp6miHIzTiKWPUPAHKyMppxvmbmul6twmrmZNNRkgTa2LIHQXrq5ldeb0Kr6rNnahYvXeSHYnFYsXX1teLFcairmZNNRkbJcemlf3o6BF7qXHG2um5aS)YYK5diQ8uXhusaajm6KkrmZNNRkbhnFtpFxCiOnftMSWD7XYfC08n98DbwM(JC6GHArFYIjIz(8CvXOfWUumunockFzGiGl94rXCKRwNjptfp)x(jaGeXmFEUQemkqWSuC7OV9TdfhcAtXKdW(lltMpGOYtfFqjbaKWOtQeXmFEUQeC08n98DXHG2umzYc3ThlxWrZ30Z3fyz6pYPdgQf9jlMiM5ZZvfJwa7sXq14iO8LbIayBZA8uRXkbvh(tu(jaGeXmFEUQemkqWSuC7OV9TdfhcAtXKdW(lltMpGOYtfFqjbaKWOtQeXmFEUQeC08n98DXHG2umzYc3ThlxWrZ30Z3fyz6pYPdgQf9jlMiM5ZZvfJwa7sXq14iO8LbIamGpQPjDSCvzu(8um5NaaseZ855QsWOabZsXTJ(23ouCiOnftoa7VSmz(aIkpv8bLeaqcJoPseZ855QsWrZ30Z3fhcAtXKjlC3ESCbhnFtpFxGLP)iNoyOw0NSyIyMppxvmAbSlfdvJJGYxgicWhoY88avXKJ7L8taajIz(8CvjyuGGzP42rF7Bhkoe0MIjhG9xwMmFarLNk(GscaiHrNujIz(8Cvj4O5B657IdbTPyYKfUBpwUGJMVPNVlWY0FKthmul6twmrmZNNRkgTa2LIHQXrq5ldebSESxLbkMNhit(jaGeXmFEUQemkqWSuC7OV9TdfhcAtXKdW(lltMpGOYtfFqjbaKWOtQeXmFEUQeC08n98DXHG2umzYc3ThlxWrZ30Z3fyz6pYPdgQf9jlMiM5ZZvfJwa7UkVNVgNsDillRIO8taaDQGaXpbO(NjxWClsVKabgQf9jlMiM5ZZvfJwa7EttZJQPuSglIWqHHArFYIj46QddoKTbGnnBzP(jaL)NcvroGfll)eaqcE6c20SLL6NauCiOnfBV5PlytZwwQFcqbN6mFYIojbibpDH1MfnIdbTPy7npDH1Mfnco1z(KfDsLGNUGnnBzP(jafhcAtX2BE6c20SLL6NauWPoZNSOtsasWtxeZ7OA8jlXHG2uS9MNUiM3r14twco1z(KfDs5PlytZwwQFcqXHG2umj5PlytZwwQFcqbN6mFYcyleabgQf9jlMGRRom4q2gTa21AZIg5)PqvKdyXYYpbaKGNUWAZIgXHG2uS9MNUWAZIgbN6mFYIojbibpDrmVJQXNSehcAtX2BE6IyEhvJpzj4uN5tw0jvcE6cRnlAehcAtX2BE6cRnlAeCQZ8jl6KeGe80fSPzll1pbO4qqBk2EZtxWMMTSu)eGco1z(KfDs5PlS2SOrCiOnftsE6cRnlAeCQZ8jlGTqaeyOw0NSycUU6WGdzB0cy3yEhvJpzj)pfQICalww(jaGe80fX8oQgFYsCiOnfBV5PlI5Dun(KLGtDMpzrNKaKGNUWAZIgXHG2uS9MNUWAZIgbN6mFYIoPsWtxeZ7OA8jlXHG2uS9MNUiM3r14twco1z(KfDscqcE6c20SLL6NauCiOnfBV5PlytZwwQFcqbN6mFYIoP80fX8oQgFYsCiOnftsE6IyEhvJpzj4uN5twaBHaiWqHHArFYIj4PZaWqKRYavmVJQXNSKFcaWtxeZ7OA8jlXHG2umjbyrFYsWqKRYavmVJQXNSerJ5kFarA9bevEQyB2XPnKf7dmjwecU9y5I4HyZuTkoA(Malt)roWctSyz6KYAW)vUDTOZeme5QmqfZ7OA8jlLLOCaacTNnCfUglxm1AQVWZ0Fuq1qRBpwUy1n(gQMszTzrJalt)rU0W5PlyiYvzGkM3r14twIdbTPysd3I(KLGHixLbQyEhvJpzjMsf8t7Mdd1I(KftWtNrlGDT2SOr(inXhvUDTOZaSq(jaGBpwUiEi2mvRIJMVjWY0FKl1I(Sgv80fwBw0izirQpGOYtfFq5weMujoe0MIjjG2ixMSyMppxvcgfiywkUD03(2HIdbTPyYTimPsCiOnftYLLjlCd4WBCu0yfhbNOAQ1z08jlXzf9spm4q2MP)iD0bd1I(KftWtNrlGDT2SOr(inXhvUDTOZaSq(jaq4U9y5I4HyZuTkoA(Malt)rUul6ZAuXtxyTzrJKapP(aIkpv8bLBrysL4qqBkMKaAJCzYIz(8CvjyuGGzP42rF7Bhkoe0MIj3IWKkXHG2umjxwMSWnGdVXrrJvCeCIQPwNrZNSeNv0l9WGdzBM(J0rhmul6twmbpDgTa2LnnBzP(jaLpst8rLBxl6malKFcaiHf9znQ4PlytZwwQFcqjbEHGBpwUiEi2mvRIJMVjWY0FKhcSg8FLBxl6mblxP8nuXqKZuwI0j1hqu5PIpOClct6HbhY2m9hLkr4hcAtXKYAW)vUDTOZeme5QmqfZ7OA8jlLLiGfYKfZ855QsWOabZsXTJ(23ouCiOnftows9k2MDCGzrFYsqvm30Fuzbb)e9jlbUxyKYrLpGiDWqTOpzXe80z0cy3yEhvJpzjFKM4Jk3Uw0zawi)eaG1G)RC7ArNjyiYvzGkM3r14twklrjbcTNnCfUglxm1AQVWZ0Fuq1qRBpwUy1n(gQMszTzrJalt)rUujoe0MIjjG2ixMSyMppxvcgfiywkUD03(2HIdbTPyYTimPhgCiBZ0FKoPUDTOl8bevEQ4dk3IWGHcd1I(Kftem)JhdavXCt)rLfe8t0NSK)NcvroGfll)eaiM5ZZvLGJMVPNVloe0MIjjG2ihy7lL1G)RC7ArNjyiYvzGkM3r14twklralO9SHRW1y5IPwt9fEM(JcQgPXmFEUQemkqWSuC7OV9TdfhcAtXKB)WGHArFYIjcM)XJrlGDJ2)kl6twQFyU8LbIa46QddoKTj)eaWThlxWrZ30Z3fyz6pYLYAW)vUDTOZeme5QmqfZ7OA8jlLLiGf0E2Wv4ASCXuRP(cpt)rbvJuj4PlS2SOrCiOnftsE6cRnlAeCQZ8jlGfMieTSmz80fX8oQgFYsCiOnftsE6IyEhvJpzj4uN5twalmriAzzY4PlytZwwQFcqXHG2umj5PlytZwwQFcqbN6mFYcyHjcrltN0yMppxvcoA(ME(U4qqBkMKaSOpzjS2SOr0g5alKLgZ855QsWOabZsXTJ(23ouCiOnftU9ddgQf9jlMiy(hpgTa2nA)RSOpzP(H5YxgicGRRom4q2M8taa3ESCbhnFtpFxGLP)ixkRb)x521IotWqKRYavmVJQXNSuwIawq7zdxHRXYftTM6l8m9hfunsJz(8CvjyuGGzP42rF7Bhkoe0MIjjaws9k2MDCGzrFYsyTzrJOnYP1I(KLWAZIgrBKdmGivcE6cRnlAehcAtXKKNUWAZIgbN6mFYcylKjJNUiM3r14twIdbTPysYtxeZ7OA8jlbN6mFYcylKjJNUGnnBzP(jafhcAtXKKNUGnnBzP(jafCQZ8jlGTGoyOw0NSyIG5F8y0cyxoA(ME(U8taGyMppxvcgfiywkUD03(2HIdbTPyYbaiHrBBKltwmZNNRkbJcemlf3o6BF7qXHG2um5weYHbd1I(Kftem)JhJwa7Y2mEUsPNVl)eaqNkiqaMRrqSCbvJuDQGarnTBEG9V4qqBkgmul6twmrW8pEmAbSR1MfnYpba0PcceG5Aeelxq1inCjC7XYfSPzll1pbOalt)rUujAoCTQnYflewBw0iT5W1Q2ixSVWAZIgPnhUw1g5cGiS2SOHozYAoCTQnYflewBw0qhmul6twmrW8pEmAbSlBA2Ys9tak)eaqNkiqaMRrqSCbvJ0WLO5W1Q2ixSqWMMTSu)eGsBoCTQnYf7lytZwwQFcqPnhUw1g5cGiytZwwQFcq6GHArFYIjcM)XJrlGDJ5Dun(KL8taaDQGabyUgbXYfunsdV5W1Q2ixSqeZ7OA8jlPH72JLlmDw(uoQI5Dun(KLalt)romul6twmrW8pEmAbSl)SPu)eGYpba0PccetHRh30FuXrWHHcMBr6LBrys9bevEQ4dkjGfHbd1I(Kftem)JhJwa7YpBk1pbO8taa3ESCbBA2Ys9takWY0FKlvNkiqmfUECt)rfhbhgkyUfPxoalhwiSFyatcwd(VYTRfDMGHixLbQyEhvJpzPSedHZgUcxJLlMAn1x4z6pkOAKdW(0jLNUWAZIgXHG2um5wgySg8F1MXCukpDrmVJQXNSehcAtXKRnYLkbpDbBA2Ys9takoe0MIjxBKltw4U9y5c20SLL6NauGLP)iNoPsWrDQGaXMrvU4qqBkMCldmwd(VAZyoktw4U9y5InJQCbwM(JC6KgZYT2jl5wgySg8F1MXCegQf9jlMiy(hpgTa2LF2uQFcq5NaaU9y5Iv34BOAkL1MfncSm9h5s1PccetHRh30FuXrWHHcMBr6LdWYHfc7hgWKG1G)RC7ArNjyiYvzGkM3r14twklXq4SHRW1y5IPwt9fEM(JcQg5aae6cHLbMeSg8FLBxl6mbdrUkduX8oQgFYszjgcNnCfUglxm1AQVWZ0Fuq1ayF6KYtxyTzrJ4qqBkMCldmwd(VAZyokLNUiM3r14twIdbTPyY1g5sLGJ6ubbInJQCXHG2um5wgySg8F1MXCuMSWD7XYfBgv5cSm9h50jnMLBTtwYTmWyn4)QnJ5imul6twmrW8pEmAbSl)SPu)eGYpbaC7XYfMolFkhvX8oQgFYsGLP)ixQovqGykC94M(JkocomuWClsVCawoSqy)WaMeSg8FLBxl6mbdrUkduX8oQgFYszjgcNnCfUglxm1AQVWZ0Fuq1ihGqMoP80fwBw0ioe0MIj3YaJ1G)R2mMJsLGJ6ubbInJQCXHG2um5wgySg8F1MXCuMSWD7XYfBgv5cSm9h50jnMLBTtwYTmWyn4)QnJ5imul6twmrW8pEmAbS7Mrvomul6twmrW8pEmAbSBqgPyixzahEJJkD0aHHArFYIjcM)XJrlGDBOUjGMPAv6VXCyOw0NSyIG5F8y0cy3ywrS8ZCKRcEdeLFcaeopDrmRiw(zoYvbVbIkDQRehcAtXKgUf9jlrmRiw(zoYvbVbIIPub)0U5WqTOpzXebZ)4XOfWU8ZMsXsQx(PC8oQgx1(PU9awiFCZMcWc5NYX7OACalKpst8rLBxl6malKFca4diQ8uXhusaTromul6twmrW8pEmAbSl)SPuSK6Lpst8rLBxl6malKpUztbyH8t54DunUAca4tKEM6qqBkjxw(PC8oQgx1(PU9awi)eaWThlxW2mEUsHG6NfrbwM(JCPRTBm9hfG2uUnLIHsdNJ6ubbc2MXZvkeu)Sikoe0MIbd1I(Kftem)JhJwa7YpBkflPE5J0eFu521IodWc5JB2uawi)uoEhvJRMaa(ePNPoe0MsYLLFkhVJQXvTFQBpGfYpbaC7XYfSnJNRuiO(zruGLP)ix6A7gt)rbOnLBtPyimul6twmrW8pEmAbSl)SPuSK6LFkhVJQXvTFQBpGfYh3SPaSq(PC8oQghWcyOw0NSyIG5F8y0cyx2MXZvk98D5J0eFu521IodWc5NaaU9y5c2MXZvkeu)SikWY0FKlDTDJP)Oa0MYTPumuA4CuNkiqW2mEUsHG6NfrXHG2umPHBrFYsW2mEUsPNVlMsf8t7Mdd1I(Kftem)JhJwa7Y2mEUsPNVlFKM4Jk3Uw0zawi)eaWThlxW2mEUsHG6NfrbwM(JCPRTBm9hfG2uUnLIHWqTOpzXebZ)4XOfWUSnJNRu657WqHHArFYIjynyXXJbGQyUP)OYcc(j6twYpbaIz(8CvjyuGGzP42rF7Bhkoe0MIjjaws9k2MDCGjbUxyKYrLpGiTgWH34OGFOXdOEv0(FQwXzf90jvIWD7XYfC08n98DbwM(JCzYIz(8Cvj4O5B657IdbTPyscGLuVITzhhy4EHrkhv(aI0jvc3ESCblxP8nuXqKZeyz6pYLjJNUOzZkpbvSPAPE7gNgXHG2umzY4PlwppQCBkxCiOnfJoyOw0NSycwdwC8y0cy3O9VYI(KL6hMlFzGiGG5F8yYpbaKiM5ZZvLGrbcMLIBh9TVDO4qqBkMK(aIkpvSn74atILdbws9k2MDC6KjlM5ZZvLGrbcMLIBh9TVDOGQHoP(aIkpv8bLlM5ZZvLGrbcMLIBh9TVDO4qqBkgmul6twmbRbloEmAbSldrUkduX8oQgFYs(jaWA7gt)rbfdvme5WqTOpzXeSgS44XOfWUufZn9hvwqWprFYs(jaq4RTBm9hfumuXqKln8MdxRAJCXcbJcemlf3o6BF7qPs42JLl4O5B657cSm9h5sJz(8Cvj4O5B657IdbTPysca3lms5OYhquA4gWH34OiASOXNQvfT3ahNgbwM(JCzYKGLuVITzhxoallL1G)RC7ArNjyiYvzGkM3r14twklrj3xMmws9k2MDC5aSVuwd(VYTRfDMGHixLbQyEhvJpzPSeLdW(0j1TRfDHpGOYtfFq5czAX9cJuoQ8beLYAW)vUDTOZeme5QmqfZ7OA8jlLLiGfYK5diQ8uXhusaapAX9cJuoQ8bebglPEfBZooDWqTOpzXeSgS44XOfWUufZn9hvwqWprFYs(jaq4RTBm9hfumuXqKlnMLBTtwsciAmx5dis7A7gt)rrJX5t1cd1I(KftWAWIJhJwa7svm30Fuzbb)e9jl5J0eFu521IodWc5NaaHV2UX0FuqXqfdrUujc3ThlxWrZ30Z3fyz6pYLjlM5ZZvLGJMVPNVloe0MIjNpGOYtfBZoUmzSK6vSn74YTGoPseUBpwUy98OYTPCbwM(JCzYyj1RyB2XLBbDsJz5w7KLKaIgZv(aI0U2UX0Fu0yC(uTsLiCd4WBCuenw04t1QI2BGJtJalt)rUmz6ubbIOXIgFQwv0EdCCAehcAtXKZhqu5PITzhNUU2A8ytw9L2pSfH0Wcrl2xewyl6ARSRMQL112td2KNJCijebjw0NSGKFyotadTRzu(wEDnTbCpVR9dZz9D6ACD1HbhY2670xArFNUgwM(J8oq7Aw0NS6ASPzll1pbyxlEJJ3yDnjGeE6c20SLL6NauCiOnfds2BiHNUGnnBzP(jafCQZ8jliHoirsaqIeqcpDH1MfnIdbTPyqYEdj80fwBw0i4uN5twqcDqIuirciHNUGnnBzP(jafhcAtXGK9gs4PlytZwwQFcqbN6mFYcsOdsKeaKibKWtxeZ7OA8jlXHG2umizVHeE6IyEhvJpzj4uN5twqcDqIuiHNUGnnBzP(jafhcAtXGejHeE6c20SLL6NauWPoZNSGeGbjleaPR9tHQiVRTy5U3xA)(oDnSm9h5DG21SOpz11S2SOPRfVXXBSUMeqcpDH1MfnIdbTPyqYEdj80fwBw0i4uN5twqcDqIKaGejGeE6IyEhvJpzjoe0MIbj7nKWtxeZ7OA8jlbN6mFYcsOdsKcjsaj80fwBw0ioe0MIbj7nKWtxyTzrJGtDMpzbj0bjscasKas4PlytZwwQFcqXHG2umizVHeE6c20SLL6NauWPoZNSGe6GePqcpDH1MfnIdbTPyqIKqcpDH1Mfnco1z(KfKamizHaiDTFkuf5DTfl39(saPVtxdlt)rEhODnl6twDTyEhvJpz11I344nwxtciHNUiM3r14twIdbTPyqYEdj80fX8oQgFYsWPoZNSGe6Gejbajsaj80fwBw0ioe0MIbj7nKWtxyTzrJGtDMpzbj0bjsHejGeE6IyEhvJpzjoe0MIbj7nKWtxeZ7OA8jlbN6mFYcsOdsKeaKibKWtxWMMTSu)eGIdbTPyqYEdj80fSPzll1pbOGtDMpzbj0bjsHeE6IyEhvJpzjoe0MIbjscj80fX8oQgFYsWPoZNSGeGbjleaPR9tHQiVRTy5U39UghdmQ3770xArFNUMf9jRUgRb)x9zK(UgwM(J8oq7EFP97701SOpz11446K6uGw7e7Ayz6pY7aT79LasFNUgwM(J8oq7AztxJHExZI(KvxBTDJP)yxBT9uyxZThlxWYvkFdvme5mbwM(JCirkKWAW)vUDTOZeme5QmqfZ7OA8jlLLiKihaibiqcTqYzdxHRXYftTM6l8m9hfunqImzqIBpwUGnnBzP(jafyz6pYHePqcRb)x521IotWqKRYavmVJQXNSGe5aajldj0cjNnCfUglxm1AQVWZ0Fuq1ajYKbjSg8FLBxl6mbdrUkduX8oQgFYcsKdaKa8GeAHKZgUcxJLlMAn1x4z6pkOA6ARTtvgi21OyOIHiV79Lc5(oDnSm9h5DG21YMUgd9UMf9jRU2A7gt)XU2A7PWUMf9jlbBZ45kLE(Ua3lms5OYhqesagKyahEJJIOXIgFQwv0EdCCAeyz6pY7ARTtvgi21AmoFQ2U3xA5(oDnSm9h5DG21YMU2Hm07Aw0NS6ARTBm9h7ARTNc7ATrExlEJJ3yDnd4WBCuenw04t1QI2BGJtJalt)roKifsKasC7XYf8ZMsXsQxGLP)ihsKjdsC7XYfC08n98DbwM(JCirkKeZ855QsWrZ30Z3fhcAtXGejbajTroKqxxBTDQYaXUwJX5t129(sHK(oDnSm9h5DG21YMUgd9UMf9jRU2A7gt)XU2A7PWUgRb)x521IotWqKRYavmVJQXNSuwIqIKaGKfqcTqIBpwUy1n(gQMszTzrJalt)roKqlK42JLlmDw(uoQI5Dun(KLalt)roKamizFiHwirciXThlxS6gFdvtPS2SOrGLP)ihsKcjU9y5cwUs5BOIHiNjWY0FKdjsHewd(VYTRfDMGHixLbQyEhvJpzPSeHe5GK9He6GeAHejGe3ESCbBA2Ys9takWY0FKdjsHKWHe3ESCr8qSzQwfhnFtGLP)ihsKcjHdjU9y5c(ztPyj1lWY0FKdj0bj0cjNnCfUglxm1AQVWZ0Fuq101wBNQmqSRbAt52ukg29(sHO(oDnSm9h5DG21YMUgd9UMf9jRU2A7gt)XU2A7PWUMeqs4qIBpwUGnnBzP(jafyz6pYHezYGeE6c20SLL6Nauq1aj0bjsHeE6cRnlAem3I0djYbaswegKifschs4PlS2SOrCyWHSnt)rirkKWtxeZ7OA8jlbvtxBTDQYaXUgpDMIQP79LaE9D6Ayz6pY7aTRzrFYQRfT)vw0NSu)W8U2pmxvgi21Iz(8CvX6EFPqAFNUgwM(J8oq7Aw0NS6A8ZMsXsQVRfPj(OYTRfDwFPfDT4noEJ118bevEQ4dcjscasAJCirkKWsQxX2SJdjscjl31IB2uDTfDTPC8oQgx1(PU9DTfDVV0IW6701WY0FK3bAxlEJJ3yDnwd(VYTRfDMGHixLbQyEhvJpzPSeHejbaj7dj0cjNnCfUglxm1AQVWZ0Fuq101SOpz112mQY7EFPfl6701WY0FK3bAxlEJJ3yDnE6cRnlAe(ePFQwirkKWtxeZ7OA8jlHpr6NQfsKcjsaj6ubbcl6ZAurzmbZTi9qcaizzirMmiHLuVITzhhsaajHbj0bjsHejGKWHe3ESCrZMvEcQyt1s92noncSm9h5qImzqcpDrZMvEcQyt1s92nonIdbTPyqcDqIuircijCiXThlxWrZ30Z3fyz6pYHezYGKyMppxvcoA(ME(U4qqBkgKijaiPnYHezYGKWHKyMppxvcoA(ME(U4qqBkgKitgKWAW)vUDTOZeme5QmqfZ7OA8jlLLiKihKSasOfsoB4kCnwUyQ1uFHNP)OGQbsORRzrFYQRXOabZsXTJ(23oS79LwSFFNUgwM(J8oq7AXBC8gRRfZ855QsWOabZsXTJ(23ouCiOnfdsKcjRTBm9hf80zkQgirkKWAW)vUDTOZeme5QmqfZ7OA8jlLLiKaaswaj0cjNnCfUglxm1AQVWZ0Fuq1ajsHejGKWHeKXWkII1dBYsLbQg8cWOpzjaNkpirkKeoKyahEJJc(HgpG6vr7)PAfNv0djYKbjXmFEUQemkqWSuC7OV9TdfhcAtXGe5GeGegKqxxZI(KvxJJMVPNV39(slasFNUgwM(J8oq7AXBC8gRRPtfeioms)JmMkiVikoe0MI11SOpz118nurv6jvXvb5fXU3xAri33PRHLP)iVd0UMf9jRUM1MfnDT4noEJ11oe0MIbjscasAJCiHwiXI(KLGTz8CLspFxG7fgPCu5dicjsHeFarLNk(GqICqcWRRfPj(OYTRfDwFPfDVV0IL7701WY0FK3bAxlEJJ3yDnFarirsibiH11SOpz11arW8OrLbQNkoCf)qdK19(slcj9D6Ayz6pY7aTRzrFYQRzTzrtxlEJJ3yDTyMppxvcgfiywkUD03(2HIdbTPyqIKaGKfldjsHee4JAAAqUWao2MDgtfKLRYavtUcVU2pfQI8UgqcR79LweI6701WY0FK3bAxZI(KvxlM3r14twDT4noEJ11Iz(8CvjyuGGzP42rF7Bhkoe0MIbjscaswSmKifsqGpQPPb5cd4yB2zmvqwUkdun5k8GePqs4qIBpwUW0z5t5OkM3r14twcSm9h5qIuirciXThlxWMMTSu)eGcSm9h5qImzqcRb)x521IotWqKRYavmVJQXNSuwIqICqYcirkKWAW)vUDTOZeme5QmqfZ7OA8jlLLiKijaibiqcDDTFkuf5DnGew37lTa413PRHLP)iVd0UMf9jRUgBA2Ys9ta21I344nwxlM5ZZvLGrbcMLIBh9TVDO4qqBkgKijaizXYqIuibb(OMMgKlmGJTzNXubz5Qmq1KRWRR9tHQiVRbKW6EFPfH0(oDnSm9h5DG21SOpz11OkMB6pQSGGFI(KvxlEJJ3yDTWHKywU1ozbjsHeFarLNk(GqIKaGeGxxlst8rLBxl6S(sl6EFP9dRVtxdlt)rEhODnl6twDn(ztPyj131I0eFu521IoRV0IUw0Qi(QjOR5tKEM6qqBkjxURfVXXBSUMBpwUGTz8CLcb1plIcSm9h5qIuizTDJP)Oa0MYTPumesKcjCuNkiqW2mEUsHG6NfrXHG2umirkKWrDQGabBZ45kfcQFwefhcAtXGejbajTroKamiz)U3xA)f9D6Ayz6pY7aTRzrFYQRX2mEUsPNV31I344nwxZThlxW2mEUsHG6NfrbwM(JCirkKS2UX0FuaAt52ukgcjsHeoQtfeiyBgpxPqq9ZIO4qqBkgKifs4OovqGGTz8CLcb1plIIdbTPyqIKaGeCVWiLJkFaribyqY(qcTqIF2A8v(aIqIuijCiXI(KLGTz8CLspFxmLk4N2nVRfPj(OYTRfDwFPfDVV0(733PRHLP)iVd0UMf9jRUwZMvEcQyt1s92nonDT4noEJ118beHe5GeGSmKifsC7Arx4diQ8uXhesKdswesGeGbjSg8F1MXCesKcjsajHdjiJHvefRh2KLkdun4fGrFYsaovEqIuijCiXao8ghf8dnEa1RI2)t1koROhsKjdsIz(8CvjyuGGzP42rF7Bhkoe0MIbjYbjH8YqcTqclPEfBZooKamiXao8ghf8dnEa1RI2)t1koROhsKjdsIz(8CvjyuGGzP42rF7Bhkoe0MIbjscjlwgsagKWAW)vBgZriHwiHLuVITzhhsagKyahEJJc(HgpG6vr7)PAfNv0dj011I0eFu521IoRV0IU3xAFG03PRHLP)iVd0UMf9jRUgvXCt)rLfe8t0NS6AXBC8gRRfoKS2UX0FuqXqfdroKifsyj1RyB2XHeaqYYDTinXhvUDTOZ6lTO79L2pK7701WY0FK3bAxlEJJ3yDT12nM(JckgQyiYHePqclPEfBZooKaaswURzrFYQRXqKRYavmVJQXNS6EFP9xUVtxdlt)rEhODnl6twDTO9VYI(KL6hM31(H5QYaXUgpDw37lTFiPVtxdlt)rEhODnl6twDT1ZJk3MY7AXBC8gRR5dicjYbjlwgsKcjUDTOl8bevEQ4dcjYbaswegKifsKasIz(8CvjyuGGzP42rF7Bhkoe0MIbjYbjajmirMmijM5ZZvLGrbcMLIBh9TVDO4qqBkgKijKSimirkKWtxyTzrJ4qqBkgKihaizryqIuiHNUiM3r14twIdbTPyqICaGKfHbjsHejGeE6c20SLL6NauCiOnfdsKdaKSimirMmijCiXThlxWMMTSu)eGcSm9h5qcDqcDDTinXhvUDTOZ6lTO79L2pe13PRHLP)iVd0UMf9jRUMbCSn7mMkilxLbQMCfEDT4noEJ118beHejbajaPRvgi21mGJTzNXubz5Qmq1KRWR79L2h413PRHLP)iVd0Uw8ghVX6A(aIqIKaGeGSCxZI(KvxRzZkpbvSPAPE7gNMU3xA)qAFNUgwM(J8oq7AXBC8gRR5dicjscjlwURzrFYQRTEEu52uE37lbKW6701WY0FK3bAxlEJJ3yDnjGKyMppxvcgfiywkUD03(2HIdbTPyqIKqYILHeAHews9k2MDCibyqIbC4nok4hA8aQxfT)NQvGLP)ihsKjdsKasmGdVXrb)qJhq9QO9)uTIZk6HezYGeKXWkII1dBYsLbQg8cWOpzjoROhsOdsKcj(aIqICqcqcdsKcjUDTOl8bevEQ4dcjYbas2FryqcDqIuirciHNUOzZkpbvSPAPE7gNgXHG2umirMmiHNUy98OYTPCXHG2umirMmijCiXThlx0SzLNGk2uTuVDJtJalt)roKifschsC7XYfRNhvUnLlWY0FKdj0bjYKbj(aIkpv8bHejHeGegKqlK0g5Dnl6twDTwk74JvQmqzahEPV19(sazrFNUgwM(J8oq7AXBC8gRRfZ855QsWOabZsXTJ(23ouCiOnfdsKeswSmKqlKWsQxX2SJdjadsmGdVXrb)qJhq9QO9)uTcSm9h5qIuirciHNUOzZkpbvSPAPE7gNgXHG2umirMmiHNUy98OYTPCXHG2umiHUUMf9jRUg3o6vSK67EFjGSFFNUMf9jRUMoEm8OFQ2UgwM(J8oq7EFjGaK(oDnSm9h5DG21SOpz11I2)kl6twQFyEx7hMRkde7ASgS44X6EFjGeY9D6Ayz6pY7aTRzrFYQRfT)vw0NSu)W8U2pmxvgi21cM)XJ19U31AomMG6M33PV0I(oDnl6twDngfiywQa83OkhVUgwM(J8oq7EFP97701WY0FK3bAxlEJJ3yDn3ESCr7nG5COkdumlEtWerbwM(J8UMf9jRUw7nG5COkdumlEtWeXU3xci9D6Aw0NS6AnPpz11WY0FK3bA37lfY9D6Ayz6pY7aTRfVXXBSUgRb)x521IotWqKRYavmVJQXNSuwIqICaGeG01SOpz11yiYvzGkM3r14twDVV0Y9D6Aw0NS6ABgv5DnSm9h5DG29(sHK(oDnSm9h5DG21I344nwxlCiXThlxSzuLlWY0FKdjsHewd(VYTRfDMGHixLbQyEhvJpzPSeHejHeG01SOpz11yBgpxP0Z37E37AXmFEUQy9D6lTOVtxdlt)rEhODnl6twDnd4yB2zmvqwUkdun5k86AXBC8gRRjbKeoK42JLlA2SYtqfBQwQ3UXPrGLP)ihsKjdsIz(8CvjA2SYtqfBQwQ3UXPrCiOnfdsKesczibyqcRb)xTzmhHezYGKWHKyMppxvIMnR8euXMQL6TBCAehcAtXGe6GePqsmZNNRkbJcemlf3o6BF7qXHG2umirsizrifsagKWAW)vBgZriHwiHLuVITzhhsagKyahEJJc(HgpG6vr7)PAfNv0djsHeE6cRnlAehcAtXGePqcpDrmVJQXNSehcAtXGePqIeqcpDbBA2Ys9takoe0MIbjYKbjHdjU9y5c20SLL6NauGLP)ihsORRvgi21mGJTzNXubz5Qmq1KRWR79L2VVtxdlt)rEhODT4noEJ11KasC7XYfC7OxXsQxbom8OrGLP)ihsKcjXmFEUQemkqWSuC7OV9TdfunqIuijM5ZZvLGBh9kws9cQgiHoirMmijM5ZZvLGrbcMLIBh9TVDOGQbsKjds8bevEQ4dcjscjajSUMf9jRUwt6twDVVeq6701WY0FK3bAxlEJJ3yDTyMppxvcgfiywkUD03(2HIdbTPyqICqsikmirMmiXhqu5PIpiKijKSFyqImzqIeqIeqIovqGWI(SgvugtWClspKaaswgsKjdsyj1RyB2XHeaqsyqcDqIuircijCiXThlx0SzLNGk2uTuVDJtJalt)roKitgKeZ855Qs0SzLNGk2uTuVDJtJ4qqBkgKqhKifsKaschsC7XYfC08n98DbwM(JCirMmijM5ZZvLGJMVPNVloe0MIbjscasAJCirMmijCijM5ZZvLGJMVPNVloe0MIbj0bjsHKWHKyMppxvcgfiywkUD03(2HIdbTPyqcDDnl6twDnkgQghbzDVVui33PRHLP)iVd0Uw8ghVX6AHdjXmFEUQemkqWSuC7OV9TdfunDnl6twDTG5q9ptE37lTCFNUgwM(J8oq7AXBC8gRRfoKeZ855QsWOabZsXTJ(23ouq101SOpz110)m5QaQJMU3xkK03PRHLP)iVd0Uw8ghVX6A(aIqICqcqcRRzrFYQRbIG5rJkdupvC4k(HgiR79Lcr9D6Ayz6pY7aTRfVXXBSUMpGOYtfFqirsiz)WGeAHK2ihsKjdsyn4)k3Uw0zcgICvgOI5Dun(KLYsesKdswaj0cjNnCfUglxm1AQVWZ0Fuq1ajYKbjU9y5cwUs5BOIHiNjWY0FKdjsHKyMppxvcgfiywkUD03(2HIdbTPyqICaGKyMppxvcgfiywkUD03(2Hco1z(KfKecqYIW6Aw0NS6AC7OxXsQV79LaE9D6Ayz6pY7aTRfVXXBSUwd6cUD03(2HIdbTPyqImzqIeqs4qsmZNNRkbhnFtpFxCiOnfdsKjdschsC7XYfC08n98DbwM(JCiHoirkKeZ855QsWOabZsXTJ(23ouCiOnfdsKdaKa8cdsKcjiJHvef6FMCvgO8nuHfcsJ4SIEiroizrxZI(Kvxt)ZKRYaLVHkSqqA6EFPqAFNUgwM(J8oq7Aw0NS6AnzKE0zdWHCvmbBOCZNSuCC9eXUw8ghVX6AsajXmFEUQemkqWSuC7OV9TdfhcAtXGe5aaj7VmKitgK4diQ8uXhesKeaKaKWGe6GePqIeqsmZNNRkbhnFtpFxCiOnfdsKjdschsC7XYfC08n98DbwM(JCiHUUwzGyxRjJ0JoBaoKRIjydLB(KLIJRNi29(slcRVtxdlt)rEhODnl6twDTl94rXCKRwNjptfp)VRfVXXBSUMeqsmZNNRkbJcemlf3o6BF7qXHG2umiroaqY(ldjYKbj(aIkpv8bHejbajajmiHoirkKibKeZ855QsWrZ30Z3fhcAtXGezYGKWHe3ESCbhnFtpFxGLP)ihsORRvgi21U0JhfZrUADM8mv88)U3xAXI(oDnSm9h5DG21SOpz11yBZA8uRXkbvh(tSRfVXXBSUMeqsmZNNRkbJcemlf3o6BF7qXHG2umiroaqY(ldjYKbj(aIkpv8bHejbajajmiHoirkKibKeZ855QsWrZ30Z3fhcAtXGezYGKWHe3ESCbhnFtpFxGLP)ihsORRvgi21yBZA8uRXkbvh(tS79LwSFFNUgwM(J8oq7Aw0NS6AgWh10KowUQmkFEkwxlEJJ3yDnjGKyMppxvcgfiywkUD03(2HIdbTPyqICaGK9xgsKjds8bevEQ4dcjscasasyqcDqIuircijM5ZZvLGJMVPNVloe0MIbjYKbjHdjU9y5coA(ME(Ualt)roKqxxRmqSRzaFutt6y5QYO85PyDVV0cG03PRHLP)iVd0UMf9jRUMpCK55bQIjh3RUw8ghVX6AsajXmFEUQemkqWSuC7OV9TdfhcAtXGe5aaj7VmKitgK4diQ8uXhesKeaKaKWGe6GePqIeqsmZNNRkbhnFtpFxCiOnfdsKjdschsC7XYfC08n98DbwM(JCiHUUwzGyxZhoY88avXKJ7v37lTiK7701WY0FK3bAxZI(KvxB9yVkdumppqwxlEJJ3yDnjGKyMppxvcgfiywkUD03(2HIdbTPyqICaGK9xgsKjds8bevEQ4dcjscasasyqcDqIuircijM5ZZvLGJMVPNVloe0MIbjYKbjHdjU9y5coA(ME(Ualt)roKqxxRmqSRTESxLbkMNhiR79LwSCFNUgwM(J8oq7AXBC8gRRPtfei(ja1)m5cMBr6HejHeG01SOpz11wL3ZxJtPoKLLvrS79Lwes6701SOpz11UPP5r1ukwJfXUgwM(J8oq7E37A80z9D6lTOVtxdlt)rEhODT4noEJ114PlI5Dun(KL4qqBkgKijaiXI(KLGHixLbQyEhvJpzjIgZv(aIqcTqIpGOYtfBZooKqlKeYI9HeGbjsajlGKqasC7XYfXdXMPAvC08nbwM(JCibyqsyIfldj0bjsHewd(VYTRfDMGHixLbQyEhvJpzPSeHe5aajabsOfsoB4kCnwUyQ1uFHNP)OGQbsOfsC7XYfRUX3q1ukRnlAeyz6pYHePqs4qcpDbdrUkduX8oQgFYsCiOnfdsKcjHdjw0NSeme5QmqfZ7OA8jlXuQGFA38UMf9jRUgdrUkduX8oQgFYQ79L2VVtxdlt)rEhODnl6twDnRnlA6AXBC8gRR52JLlIhInt1Q4O5BcSm9h5qIuiXI(Sgv80fwBw0ajscjHeirkK4diQ8uXhesKdswegKifsKasoe0MIbjscasAJCirMmijM5ZZvLGrbcMLIBh9TVDO4qqBkgKihKSimirkKibKCiOnfdsKeswgsKjdschsmGdVXrrJvCeCIQPwNrZNSeNv0djsHKddoKTz6pcj0bj011I0eFu521IoRV0IU3xci9D6Ayz6pY7aTRzrFYQRzTzrtxlEJJ3yDTWHe3ESCr8qSzQwfhnFtGLP)ihsKcjw0N1OINUWAZIgirsib4bjsHeFarLNk(GqICqYIWGePqIeqYHG2umirsaqsBKdjYKbjXmFEUQemkqWSuC7OV9TdfhcAtXGe5GKfHbjsHejGKdbTPyqIKqYYqImzqs4qIbC4nokASIJGtun16mA(KL4SIEirkKCyWHSnt)riHoiHUUwKM4Jk3Uw0z9Lw09(sHCFNUgwM(J8oq7Aw0NS6ASPzll1pbyxlEJJ3yDnjGel6ZAuXtxWMMTSu)eGqIKqcWdscbiXThlxepeBMQvXrZ3eyz6pYHKqasyn4)k3Uw0zcwUs5BOIHiNPSeHe6GePqIpGOYtfFqiroizryqIui5WGdzBM(JqIuircijCi5qqBkgKifsyn4)k3Uw0zcgICvgOI5Dun(KLYsesaajlGezYGKyMppxvcgfiywkUD03(2HIdbTPyqICqclPEfBZooKamiXI(KLGQyUP)OYcc(j6twcCVWiLJkFariHUUwKM4Jk3Uw0z9Lw09(sl33PRHLP)iVd0UMf9jRUwmVJQXNS6AXBC8gRRXAW)vUDTOZeme5QmqfZ7OA8jlLLiKijKaeiHwi5SHRW1y5IPwt9fEM(JcQgiHwiXThlxS6gFdvtPS2SOrGLP)ihsKcjsajhcAtXGejbajTroKitgKeZ855QsWOabZsXTJ(23ouCiOnfdsKdswegKifsom4q2MP)iKqhKifsC7Arx4diQ8uXhesKdswewxlst8rLBxl6S(sl6E37AbZ)4X670xArFNUgwM(J8oq7Aw0NS6AufZn9hvwqWprFYQRfVXXBSUwmZNNRkbhnFtpFxCiOnfdsKeaK0g5qcWGK9HePqcRb)x521IotWqKRYavmVJQXNSuwIqcaizbKqlKC2Wv4ASCXuRP(cpt)rbvdKifsIz(8CvjyuGGzP42rF7Bhkoe0MIbjYbj7hwx7NcvrExBXYDVV0(9D6Ayz6pY7aTRfVXXBSUMBpwUGJMVPNVlWY0FKdjsHewd(VYTRfDMGHixLbQyEhvJpzPSeHeaqYciHwi5SHRW1y5IPwt9fEM(JcQgirkKibKWtxyTzrJ4qqBkgKijKWtxyTzrJGtDMpzbjadscteIwgsKjds4PlI5Dun(KL4qqBkgKijKWtxeZ7OA8jlbN6mFYcsagKeMieTmKitgKWtxWMMTSu)eGIdbTPyqIKqcpDbBA2Ys9tak4uN5twqcWGKWeHOLHe6GePqsmZNNRkbhnFtpFxCiOnfdsKeaKyrFYsyTzrJOnYHeGbjHmKifsIz(8CvjyuGGzP42rF7Bhkoe0MIbjYbj7hwxZI(KvxlA)RSOpzP(H5DTFyUQmqSRX1vhgCiBR79LasFNUgwM(J8oq7AXBC8gRR52JLl4O5B657cSm9h5qIuiH1G)RC7ArNjyiYvzGkM3r14twklribaKSasOfsoB4kCnwUyQ1uFHNP)OGQbsKcjXmFEUQemkqWSuC7OV9TdfhcAtXGejbajSK6vSn74qcWGel6twcRnlAeTroKqlKyrFYsyTzrJOnYHeGbjabsKcjsaj80fwBw0ioe0MIbjscj80fwBw0i4uN5twqcWGKfqImzqcpDrmVJQXNSehcAtXGejHeE6IyEhvJpzj4uN5twqcWGKfqImzqcpDbBA2Ys9takoe0MIbjscj80fSPzll1pbOGtDMpzbjadswaj011SOpz11I2)kl6twQFyEx7hMRkde7ACD1HbhY26EFPqUVtxdlt)rEhODT4noEJ11Iz(8CvjyuGGzP42rF7Bhkoe0MIbjYbasasyqcTqsBKdjYKbjXmFEUQemkqWSuC7OV9TdfhcAtXGe5GKfHCyDnl6twDnoA(ME(E37lTCFNUgwM(J8oq7AXBC8gRRPtfeiaZ1iiwUGQbsKcj6ubbIAA38a7FXHG2uSUMf9jRUgBZ45kLE(E37lfs6701WY0FK3bAxlEJJ3yDnDQGabyUgbXYfunqIuijCirciXThlxWMMTSu)eGcSm9h5qIuirciP5W1Q2ixSqyTzrdKifsAoCTQnYf7lS2SObsKcjnhUw1g5cGiS2SObsOdsKjdsAoCTQnYflewBw0aj011SOpz11S2SOP79Lcr9D6Ayz6pY7aTRfVXXBSUMovqGamxJGy5cQgirkKeoKibK0C4AvBKlwiytZwwQFcqirkK0C4AvBKl2xWMMTSu)eGqIuiP5W1Q2ixaebBA2Ys9tacj011SOpz11ytZwwQFcWU3xc413PRHLP)iVd0Uw8ghVX6A6ubbcWCncILlOAGePqs4qsZHRvTrUyHiM3r14twqIuijCiXThlxy6S8PCufZ7OA8jlbwM(J8UMf9jRUwmVJQXNS6EFPqAFNUgwM(J8oq7AXBC8gRRPtfeiMcxpUP)OIJGddfm3I0djYbjlcdsKcj(aIkpv8bHejbajlcRRzrFYQRXpBk1pby37lTiS(oDnSm9h5DG21I344nwxZThlxWMMTSu)eGcSm9h5qIuirNkiqmfUECt)rfhbhgkyUfPhsKdaKSCyqsiaj7hgKamirciH1G)RC7ArNjyiYvzGkM3r14twklrijeGKZgUcxJLlMAn1x4z6pkOAGe5aaj7dj0bjsHeE6cRnlAehcAtXGe5GKLHeGbjSg8F1MXCesKcj80fX8oQgFYsCiOnfdsKdsAJCirkKibKWtxWMMTSu)eGIdbTPyqICqsBKdjYKbjHdjU9y5c20SLL6NauGLP)ihsOdsKcjsajCuNkiqSzuLloe0MIbjYbjldjadsyn4)QnJ5iKitgKeoK42JLl2mQYfyz6pYHe6GePqsml3ANSGe5GKLHeGbjSg8F1MXCSRzrFYQRXpBk1pby37lTyrFNUgwM(J8oq7AXBC8gRR52JLlwDJVHQPuwBw0iWY0FKdjsHeDQGaXu46Xn9hvCeCyOG5wKEiroaqYYHbjHaKSFyqcWGejGewd(VYTRfDMGHixLbQyEhvJpzPSeHKqasoB4kCnwUyQ1uFHNP)OGQbsKdaKaeiHoijeGKLHeGbjsajSg8FLBxl6mbdrUkduX8oQgFYszjcjHaKC2Wv4ASCXuRP(cpt)rbvdKaas2hsOdsKcj80fwBw0ioe0MIbjYbjldjadsyn4)QnJ5iKifs4PlI5Dun(KL4qqBkgKihK0g5qIuirciHJ6ubbInJQCXHG2umiroizzibyqcRb)xTzmhHezYGKWHe3ESCXMrvUalt)roKqhKifsIz5w7KfKihKSmKamiH1G)R2mMJDnl6twDn(ztP(ja7EFPf733PRHLP)iVd0Uw8ghVX6AU9y5ctNLpLJQyEhvJpzjWY0FKdjsHeDQGaXu46Xn9hvCeCyOG5wKEiroaqYYHbjHaKSFyqcWGejGewd(VYTRfDMGHixLbQyEhvJpzPSeHKqasoB4kCnwUyQ1uFHNP)OGQbsKdaKeYqcDqIuiHNUWAZIgXHG2umiroizzibyqcRb)xTzmhHePqIeqch1PcceBgv5IdbTPyqICqYYqcWGewd(VAZyocjYKbjHdjU9y5InJQCbwM(JCiHoirkKeZYT2jliroizzibyqcRb)xTzmh7Aw0NS6A8ZMs9ta29(slasFNUMf9jRU2MrvExdlt)rEhODVV0IqUVtxZI(KvxliJumKRmGdVXrLoAGDnSm9h5DG29(slwUVtxZI(KvxRH6MaAMQvP)gZ7Ayz6pY7aT79Lwes6701WY0FK3bAxlEJJ3yDTWHeE6IywrS8ZCKRcEdev6uxjoe0MIbjsHKWHel6twIywrS8ZCKRcEdeftPc(PDZ7Aw0NS6AXSIy5N5ixf8gi29(slcr9D6Ayz6pY7aTRzrFYQRXpBkflP(UwKM4Jk3Uw0z9Lw01MYX7OA8U2IUw8ghVX6A(aIkpv8bHejbajTrExlUzt11w01MYX7OACv7N6231w09(slaE9D6Ayz6pY7aTRzrFYQRXpBkflP(UwKM4Jk3Uw0z9Lw01MYX7OAC1e018jsptDiOnLKl31I344nwxZThlxW2mEUsHG6NfrbwM(JCirkKS2UX0FuaAt52ukgcjsHKWHeoQtfeiyBgpxPqq9ZIO4qqBkwxlUzt11w01MYX7OACv7N6231w09(slcP9D6Ayz6pY7aTRzrFYQRXpBkflP(UwKM4Jk3Uw0z9Lw01MYX7OAC1e018jsptDiOnLKl31I344nwxZThlxW2mEUsHG6NfrbwM(JCirkKS2UX0FuaAt52ukg21IB2uDTfDTPC8oQgx1(PU9DTfDVV0(H13PRHLP)iVd0UMf9jRUg)SPuSK67At54DunExBrxlUzt11w01MYX7OACv7N6231w09(s7VOVtxdlt)rEhODnl6twDn2MXZvk989Uw8ghVX6AU9y5c2MXZvkeu)SikWY0FKdjsHK12nM(JcqBk3MsXqirkKeoKWrDQGabBZ45kfcQFwefhcAtXGePqs4qIf9jlbBZ45kLE(UykvWpTBExlst8rLBxl6S(sl6EFP93VVtxdlt)rEhODnl6twDn2MXZvk989Uw8ghVX6AU9y5c2MXZvkeu)SikWY0FKdjsHK12nM(JcqBk3MsXWUwKM4Jk3Uw0z9Lw09(s7dK(oDnl6twDn2MXZvk989UgwM(J8oq7E37ASgS44X670xArFNUgwM(J8oq7AXBC8gRRfZ855QsWOabZsXTJ(23ouCiOnfdsKeaKWsQxX2SJdjadsKasW9cJuoQ8beHeAHed4WBCuWp04buVkA)pvR4SIEiHoirkKibKeoK42JLl4O5B657cSm9h5qImzqsmZNNRkbhnFtpFxCiOnfdsKeaKWsQxX2SJdjadsW9cJuoQ8beHe6GePqIeqIBpwUGLRu(gQyiYzcSm9h5qImzqcpDrZMvEcQyt1s92nonIdbTPyqImzqcpDX65rLBt5IdbTPyqcDDnl6twDnQI5M(Jkli4NOpz19(s733PRHLP)iVd0Uw8ghVX6AsajXmFEUQemkqWSuC7OV9TdfhcAtXGejHeFarLNk2MDCibyqIeqYYqsiajSK6vSn74qcDqImzqsmZNNRkbJcemlf3o6BF7qbvdKqhKifs8bevEQ4dcjYbjXmFEUQemkqWSuC7OV9TdfhcAtX6Aw0NS6Ar7FLf9jl1pmVR9dZvLbIDTG5F8yDVVeq6701WY0FK3bAxlEJJ3yDT12nM(JckgQyiY7Aw0NS6Ame5QmqfZ7OA8jRU3xkK7701WY0FK3bAxlEJJ3yDTWHK12nM(JckgQyiYHePqs4qsZHRvTrUyHGrbcMLIBh9TVDiKifsKasC7XYfC08n98DbwM(JCirkKeZ855QsWrZ30Z3fhcAtXGejbaj4EHrkhv(aIqIuijCiXao8ghfrJfn(uTQO9g440iWY0FKdjYKbjsajSK6vSn74qICaGKLHePqcRb)x521IotWqKRYavmVJQXNSuwIqIKqY(qImzqclPEfBZooKihaizFirkKWAW)vUDTOZeme5QmqfZ7OA8jlLLiKihaizFiHoirkK421IUWhqu5PIpiKihKeYqcTqcUxyKYrLpGiKifsyn4)k3Uw0zcgICvgOI5Dun(KLYsesaajlGezYGeFarLNk(GqIKaGeGhKqlKG7fgPCu5dicjadsyj1RyB2XHe66Aw0NS6AufZn9hvwqWprFYQ79LwUVtxdlt)rEhODT4noEJ11chswB3y6pkOyOIHihsKcjXSCRDYcsKeaKenMR8beHeAHK12nM(JIgJZNQTRzrFYQRrvm30Fuzbb)e9jRU3xkK03PRHLP)iVd0UMf9jRUgvXCt)rLfe8t0NS6AXBC8gRRfoKS2UX0FuqXqfdroKifsKaschsC7XYfC08n98DbwM(JCirMmijM5ZZvLGJMVPNVloe0MIbjYbj(aIkpvSn74qImzqclPEfBZooKihKSasOdsKcjsajHdjU9y5I1ZJk3MYfyz6pYHezYGews9k2MDCiroizbKqhKifsIz5w7KfKijaijAmx5dicj0cjRTBm9hfngNpvlKifsKaschsmGdVXrr0yrJpvRkAVbooncSm9h5qImzqIovqGiASOXNQvfT3ahNgXHG2umiroiXhqu5PITzhhsORRfPj(OYTRfDwFPfDV7DV7DV3ba]] )


end