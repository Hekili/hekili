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


    spec:RegisterPack( "Affliction", 20190728, [[dCeancqiPqpsvsCjvjLnrK(KsbvnkIWPqPAvQs1RqjnlPGBruL2fHFPuYWKI6ykHLPkXZuk10ukW1uIABevHVrufnoIQQZruvSoLckZJi6EQI9ru5GevLAHQs5HQsQyIevLCrvjvvNuvsvSsPiZuvsv5MkfuXovISuvjv6PKYuvk6QkfuPVQkPkTxP6VKmyehMYIjvpwOjJQldTzb(SuA0kvNwXRrPmBGBRQ2TKFlA4c64kfKLRYZrA6uDDuSDLuFxjz8QssNhLy9kfA(eL9d6(I(MDnU5yFPxAEH8Pz55lYVyH8V4LTL)UMZsi21cTiBwl21k7JDn57GaWe9jRUwOXcinEFZUgnzUi212DpKUHT1wTJVZOlI5Fl68zaMpzfplW3Io)4wDnDMb4VEQUExJBo2x6LMxiFAwE(I8lwi)lEz7L7A0qm2x6f5XYDT9HZXQR314in21Efir(oiamrFYcsE9AhiJSbB6vGKD3dPByBTv747m6Iy(3IoFgG5twXZc8TOZpUfSPxbsAIbWcK8I83aK8sZlKpqI8cjlK)nSMLhWMGn9kqYRZUvTiDdd20RajYlKiFZ5ihs0craasE9Lr2eWMEfirEHe5Boh5qI8fUozoizdhRDIcytVcKiVqYRl(Z1ihsC7ArxnbcHa20RajYlK86IBiM5qir(k3KcjmHqswqIBxl6qsqEqI8fA(UEcCirc6uresom4q6oKaY2jcjdfs4tqaEy5qYeajVoYxuiXoes4d10biNDbSPxbsKxi51fdbweHekUgpdajUDTOl85Jkpv8bHKOrrkKSA8DiXNpQ8uXhesKaloKKbqcwXKPC8yx01cVmyayx7vGe57GaWe9jli51RDGmYgSPxbs2DpKUHT1wTJVZOlI5Fl68zaMpzfplW3Io)4wWMEfiPjgalqYlYFdqYlnVq(ajYlKSq(3WAwEaBc20RajVo7w1I0nmytVcKiVqI8nNJCirlebai51xgztaB6vGe5fsKV5CKdjYx46K5GKnCS2jkGn9kqI8cjVU4pxJCiXTRfD1eiecytVcKiVqYRlUHyMdHe5RCtkKWecjzbjUDTOdjb5bjYxO576jWHejOtfri5WGdP7qciBNiKmuiHpbb4HLdjtaK86iFrHe7qiHputhGC2fWMEfirEHKxxmeyresO4A8maK421IUWNpQ8uXhesIgfPqYQX3HeF(OYtfFqircS4qsgajyftMYXJDbSjytVcK86)vXiJJCirhdYdHKy(1nhs0X2POcir(ogXqNcjvwY7UD)agaKyrFYIcjzbyraB6vGel6twur4HX8RB(taWOSbB6vGel6twur4HX8RBoRpBfKjh20Rajw0NSOIWdJ5x3CwF2YyA)y5MpzbBYI(KfveEym)6MZ6ZwuM)plvi6WMSOpzrfHhgZVU5S(Sv7n)CouLbkQfVjyIydtWJBaSCr7n)CouLbkQfVjyIOalthGCytVcKyrFYIkcpmMFDZz9zlAzH090vu3CkSjl6twur4HX8RBoRpBfM(KfSjl6twur4HX8RBoRpBXqr144VHY(4JTr6UDgvfKLRYavyUcpytw0NSOIWdJ5x3CwF2IIixLbQyEhtOpz1We8qdraq521IovqrKRYavmVJj0NSuwIY9ST0gXneZegICXc5H8z7fBaSjl6twur4HX8RBoRpBTBmLdBYI(KfveEym)6MZ6Zw0DJNRu6jWBycEA0nawUy3ykxGLPdqUuAicak3Uw0PckICvgOI5DmH(KLYsuYTHnzrFYIkcpmMFDZz9zl6UXZvk9e4nmbpn6galxSBmLlWY0bixknebaLBxl6ubfrUkduX8oMqFYszjk52sBe3qmtyiYflKhYNTxSbWMGn9kqYR)xfJmoYHeCnESaj(8riX3riXIEEqYqHeBTnathGcytw0NSOp0qeauGmYgSjl6twuwF2IJRtMt9T2jcBYI(KfL1NTwB3y6aSHY(4ddfvue5nS2am4JBaSCbnxP8DurrKtfyz6aKlLgIaGYTRfDQGIixLbQyEhtOpzPSeL7zBwpB4kCnwUyQ1mGcpthGcMqzYCdGLlOt4EwkWeGcSmDaYLsdraq521IovqrKRYavmVJj0NSK7zzwpB4kCnwUyQ1mGcpthGcMqzYOHiaOC7ArNkOiYvzGkM3Xe6twY9i)SE2Wv4ASCXuRzafEMoafmHWMSOpzrz9zR12nMoaBOSp(eAC(uTnKHpu0ByTbyWhl6twc6UXZvk9e4c8vXiJJkF(472gXBCuenA04t1QIgW(JZIalthGCytw0NSOS(S1A7gthGnu2hFcnoFQ2gYWNdPO3WAdWGpTrEdtWJTr8ghfrJgn(uTQObS)4SiWY0bixQeUbWYf8ZMsrtgGalthGCzYCdGLl4O576jWfyz6aKlnMjGNRkbhnFxpbU4WVnfvYN2iNDytw0NSOS(S1A7gthGnu2hF(2uUnLIInS2am4dnebaLBxl6ubfrUkduX8oMqFYszjk5ZcwDdGLlwDJVJQPuwBwSiWY0biNv3ay5ctNMaghvX8oMqFYsGLPdq(7VWQeUbWYfRUX3r1ukRnlweyz6aKl1nawUGMRu(oQOiYPcSmDaYLsdraq521IovqrKRYavmVJj0NSuwIY9c7SkHBaSCbDc3ZsbMauGLPdqU0gDdGLlIhIHt1Q4O57cSmDaYL2OBaSCb)SPu0KbiWY0biNDwpB4kCnwUyQ1mGcpthGcMqytw0NSOS(S1A7gthGnu2hF4PtvmHnS2am4Jen6galxqNW9SuGjafyz6aKltgpDbDc3ZsbMauWeYUuE6cRnlweu3ISj3ZIML2ipDH1MflIddoKUB6aukpDrmVJj0NSemHWMSOpzrz9zRObakl6twkWq9gk7JpXmb8CvrHnzrFYIY6Zw8ZMsrtgqdt54DmHUQfK6g4zrdXDBQNfnezjcqLBxl60Nfnmbp(8rLNk(Gs(0g5sPjdqr3TJl5YWMSOpzrz9zRDJP8gMGhAicak3Uw0PckICvgOI5DmH(KLYsuYNxy9SHRW1y5IPwZak8mDakycHnzrFYIY6ZwuM)plf3o2Ab2Hnmbp80fwBwSi8jY2uTs5PlI5DmH(KLWNiBt1kvcDMGaHf9znQymQG6wKTNLLjJMmafD3o(tZSlvIgDdGLlc3TYZVIovldWUXzrGLPdqUmz80fH7w55xrNQLby34Sio8BtrzxQen6galxWrZ31tGlWY0bixMSyMaEUQeC08D9e4Id)2uujFAJCzYAmMjGNRkbhnFxpbU4WVnfvMmAicak3Uw0PckICvgOI5DmH(KLYsuUfSE2Wv4ASCXuRzafEMoafmHSdBYI(KfL1NT4O576jWBycEIzc45Qsqz()SuC7yRfyhko8BtrLU2UX0bOGNovXekLgIaGYTRfDQGIixLbQyEhtOpzPSeFwW6zdxHRXYftTMbu4z6auWekvIgrkfRikwp0jlvgOcXlaJ(KL4pvEsB02iEJJc(HgpGbOIgamvR4SInzYIzc45Qsqz()SuC7yRfyhko8BtrLB7Mzh2Kf9jlkRpB57OIP0tMIRcYlInmbp6mbbIdJSbqkvfKxefh(TPOWMSOpzrz9zlRnlwAiYseGk3Uw0PplAycEo8BtrL8PnYz1I(KLGUB8CLspbUaFvmY4OYNpk1NpQ8uXhuo5h2Kf9jlkRpB9XFESOYafGjoCf)q7tBycE85JsUDZWMEfizt8hMNDSajbZRcjEcjFJnesOmhcj2gP72zB4PqsqwoKWtKwB4Dir)qJniHBhBTa7qiHHATOa2Kf9jlkRpBzTzXsdGPqvK)SDZnmbp(8r52UzPXmb8CvjOm)FwkUDS1cSdfh(TPOs(SyzP4gIzcdrUyH8q(S9Ina2Kf9jlkRpBfZ7yc9jRgatHQi)z7MBycE85JYTDZsJzc45Qsqz()SuC7yRfyhko8BtrL8zXYsXneZegICXc5H8z7fBG0gDdGLlmDAcyCufZ7yc9jlbwMoa5sLWnawUGoH7zPatakWY0bixMmAicak3Uw0PckICvgOI5DmH(KLYsuUfsPHiaOC7ArNkOiYvzGkM3Xe6twklrjF2MDytw0NSOS(SfDc3ZsbMaSbWuOkYF2U5gMGhF(OCB3S0yMaEUQeuM)plf3o2Ab2HId)2uujFwSSuCdXmHHixSqEiF2EXgaBYI(KfL1NTykQB6auzbbGj6twnezjcqLBxl60NfnmbpngZYT2jlP(8rLNk(Gs(i)WMSOpzrz9zl(ztPOjdOHilraQC7ArN(SOHOvreOMGhFISrvh(TPKC5gMGh3ay5c6UXZvk8RFwefyz6aKlDTDJPdqX3MYTPuuukh1zcce0DJNRu4x)Siko8BtrLYrDMGabD345kf(1plIId)2uujFAJ83Fb2Kf9jlkRpBr3nEUsPNaVHilraQC7ArN(SOHj4XnawUGUB8CLc)6NfrbwMoa5sxB3y6au8TPCBkffLYrDMGabD345kf(1plIId)2uuPCuNjiqq3nEUsHF9ZIO4WVnfvYh8vXiJJkF(47VWQF2AeO85JsB0I(KLGUB8CLspbUykvayA3Dytw0NSOS(Sv4UvE(v0PAza2nolnezjcqLBxl60Nfnmbp(8r52EzPUDTOl85Jkpv8bLBH84DAicaQDJ6OujAePuSIOy9qNSuzGkeVam6twI)u5jTrBJ4nok4hA8agGkAaWuTIZk2KjlMjGNRkbL5)ZsXTJTwGDO4WVnfvUnyzwPjdqr3TJ)UTr8ghf8dnEadqfnayQwXzfBYKfZeWZvLGY8)zP42XwlWouC43MIk5ILFNgIaGA3OoYknzak6UD83TnI34OGFOXdyaQObat1koRyJDytw0NSOS(SftrDthGkliamrFYQHilraQC7ArN(SOHj4PX12nMoafmuurrKlLMmafD3o(ZYWMSOpzrz9zlkICvgOI5DmH(KvdtWZA7gthGcgkQOiYLstgGIUBh)zzytw0NSOS(Sv0aaLf9jlfyOEdL9XhE6uytw0NSOS(S16bGk3MYBiYseGk3Uw0PplAycE85JYTyzPUDTOl85Jkpv8bL7zrZsLiMjGNRkbL5)ZsXTJTwGDO4WVnfvUTBwMSyMaEUQeuM)plf3o2Ab2HId)2uujx0SuE6cRnlweh(TPOY9SOzP80fX8oMqFYsC43MIk3ZIMLkbpDbDc3ZsbMauC43MIk3ZIMLjRr3ay5c6eUNLcmbOalthGC2zh2Kf9jlkRpBXqr144VHY(4JTr6UDgvfKLRYavyUcVgMGhF(OKpBdBYI(KfL1NTc3TYZVIovldWUXzPHj4XNpk5Z2ldBYI(KfL1NTwpau52uEdtWJpFuYfldBYI(KfL1NTAzSJpwPYaLTr8sFVHj4rIyMaEUQeuM)plf3o2Ab2HId)2uujxSmR0KbOO72XF32iEJJc(HgpGbOIgamvRalthGCzYKW2iEJJc(HgpGbOIgamvR4SInzYqkfRikwp0jlvgOcXlaJ(KL4SIn2L6ZhLB7ML621IUWNpQ8uXhuUNxw0m7sLGNUiC3kp)k6uTma7gNfXHFBkQmz80fRhaQCBkxC43MIktwJUbWYfH7w55xrNQLby34SiWY0bixAJUbWYfRhaQCBkxGLPdqo7YK5ZhvEQ4dk52nZABKdBYI(KfL1NT42XMIMmGgMGNyMaEUQeuM)plf3o2Ab2HId)2uujxSmR0KbOO72XF32iEJJc(HgpGbOIgamvRalthGCPsWtxeUBLNFfDQwgGDJZI4WVnfvMmE6I1davUnLlo8Btrzh2Kf9jlkRpBPJhfp2MQf2Kf9jlkRpBfnaqzrFYsbgQ3qzF8HgIfhpkSjl6twuwF2kAaGYI(KLcmuVHY(4tWaa4rHnbBYI(KfveZeWZvf9HHIQXXFdL9XhBJ0D7mQkilxLbQWCfEnmbps0OBaSCr4UvE(v0PAza2nolcSmDaYLjlMjGNRkr4UvE(v0PAza2nolId)2uuj3G3PHiaO2nQJYK1ymtapxvIWDR88ROt1YaSBCweh(TPOSlnMjGNRkbL5)ZsXTJTwGDO4WVnfvYfYN3PHiaO2nQJSstgGIUBh)DBJ4nok4hA8agGkAaWuTIZk2KYtxyTzXI4WVnfvkpDrmVJj0NSeh(TPOsLGNUGoH7zPatako8BtrLjRr3ay5c6eUNLcmbOalthGC2HnzrFYIkIzc45QIY6ZwHPpz1We8iHBaSCb3o2u0KbO(dfpweyz6aKlnMjGNRkbL5)ZsXTJTwGDOGjuAmtapxvcUDSPOjdqWeYUmzXmb8CvjOm)FwkUDS1cSdfmHYK5ZhvEQ4dk52ndBYI(KfveZeWZvfL1NTyOOAC8tBycEIzc45Qsqz()SuC7yRfyhko8BtrLtE2Smz(8rLNk(Gs(sZYKjHe6mbbcl6ZAuXyub1TiBplltgnzak6UD8NMzxQen6galxeUBLNFfDQwgGDJZIalthGCzYIzc45QseUBLNFfDQwgGDJZI4WVnfLDPs0OBaSCbhnFxpbUalthGCzYIzc45QsWrZ31tGlo8BtrL8PnYLjRXyMaEUQeC08D9e4Id)2uu2L2ymtapxvckZ)NLIBhBTa7qXHFBkk7WMSOpzrfXmb8Cvrz9zRG5qDqM8gMGNgJzc45Qsqz()SuC7yRfyhkycHnzrFYIkIzc45QIY6Zw6Gm5QaMJLgMGNgJzc45Qsqz()SuC7yRfyhkycHnzrFYIkIzc45QIY6ZwF8NhlQmqbyIdxXp0(0gMGhF(OCB3mSjl6twurmtapxvuwF2IBhBkAYaAycE85Jkpv8bL8LMzTnYLjJgIaGYTRfDQGIixLbQyEhtOpzPSeLBbRNnCfUglxm1AgqHNPdqbtOmzUbWYf0CLY3rffrovGLPdqU0yMaEUQeuM)plf3o2Ab2HId)2uu5EIzc45Qsqz()SuC7yRfyhk4mN5twY7IMHnzrFYIkIzc45QIY6Zw6Gm5Qmq57Ocl8ZsdtWti6cUDS1cSdfh(TPOYKjrJXmb8Cvj4O576jWfh(TPOYK1OBaSCbhnFxpbUalthGC2LgZeWZvLGY8)zP42XwlWouC43MIk3J83SuKsXkIcDqMCvgO8DuHf(zrCwXMClGn9kqYgUues423ANQfsYsEzOiK43uSHofs(5HqsEqcaPuijlijMjGNRQgGeAcjGSAHeJcj(ocjVEEDKVGeFhzbsMkYCqYQS2W7qcgeGrhsSIfij9D8Ge)MIn0Pqcd1AriHZCt1cjXmb8CvrfWMSOpzrfXmb8Cvrz9zlgkQgh)nu2hFcZiBOtNnICvm)HmU5twkoUEIydtWJeXmb8CvjOm)FwkUDS1cSdfh(TPOY98YYYK5ZhvEQ4dk5Z2nZUujIzc45QsWrZ31tGlo8BtrLjRr3ay5coA(UEcCbwMoa5SdBYI(KfveZeWZvfL1NTyOOAC83qzF85spEmuh5Q1zYZuXtaOHj4rIyMaEUQeuM)plf3o2Ab2HId)2uu5EEzzzY85Jkpv8bL8z7MzxQeXmb8Cvj4O576jWfh(TPOYK1OBaSCbhnFxpbUalthGC2HnzrFYIkIzc45QIY6Zwmuuno(BOSp(q3N14PwJv(vhcMydtWJeXmb8CvjOm)FwkUDS1cSdfh(TPOY98YYYK5ZhvEQ4dk5Z2nZUujIzc45QsWrZ31tGlo8BtrLjRr3ay5coA(UEcCbwMoa5SdBYI(KfveZeWZvfL1NTyOOAC83qzF8X2qmty6y5QYy8bWqBycEKiMjGNRkbL5)ZsXTJTwGDO4WVnfvUNxwwMmF(OYtfFqjF2Uz2LkrmtapxvcoA(UEcCXHFBkQmzn6galxWrZ31tGlWY0biNDytw0NSOIyMaEUQOS(SfdfvJJ)gk7Jp(WrQN3xfto(QnmbpseZeWZvLGY8)zP42XwlWouC43MIk3ZllltMpFu5PIpOKpB3m7sLiMjGNRkbhnFxpbU4WVnfvMSgDdGLl4O576jWfyz6aKZoSjl6twurmtapxvuwF2IHIQXXFdL9XN1JbuzGI659PnmbpseZeWZvLGY8)zP42XwlWouC43MIk3ZllltMpFu5PIpOKpB3m7sLiMjGNRkbhnFxpbU4WVnfvMSgDdGLl4O576jWfyz6aKZoSjl6twurmtapxvuwF2AvEa(ACk1H0SSkInmbp6mbbcWeG6Gm5cQBr2KCBytw0NSOIyMaEUQOS(S1nHHaunLIgAre2eSjl6twubxxDyWH09h6eUNLcmbydGPqvK)Sy5gMGhj4PlOt4EwkWeGId)2u0xJNUGoH7zPatak4mN5twSl5Je80fwBwSio8BtrFnE6cRnlweCMZ8jl2LkbpDbDc3ZsbMauC43MI(A80f0jCplfycqbN5mFYIDjFKGNUiM3Xe6twId)2u0xJNUiM3Xe6twcoZz(Kf7s5PlOt4EwkWeGId)2uuj5PlOt4EwkWeGcoZz(K17leBdBYI(KfvW1vhgCiDN1NTS2SyPbWuOkYFwSCdtWJe80fwBwSio8BtrFnE6cRnlweCMZ8jl2L8rcE6IyEhtOpzjo8BtrFnE6IyEhtOpzj4mN5twSlvcE6cRnlweh(TPOVgpDH1MflcoZz(Kf7s(ibpDbDc3ZsbMauC43MI(A80f0jCplfycqbN5mFYIDP80fwBwSio8BtrLKNUWAZIfbN5mFY69fITHnzrFYIk46QddoKUZ6ZwX8oMqFYQbWuOkYFwSCdtWJe80fX8oMqFYsC43MI(A80fX8oMqFYsWzoZNSyxYhj4PlS2SyrC43MI(A80fwBwSi4mN5twSlvcE6IyEhtOpzjo8BtrFnE6IyEhtOpzj4mN5twSl5Je80f0jCplfycqXHFBk6RXtxqNW9SuGjafCMZ8jl2LYtxeZ7yc9jlXHFBkQK80fX8oMqFYsWzoZNSEFHyBytWMSOpzrf80Ppue5QmqfZ7yc9jRgMGhE6IyEhtOpzjo8BtrL8XI(KLGIixLbQyEhtOpzjIg1v(8rw95Jkpv0D74SUbIxExIfYRBaSCr8qmCQwfhnFxGLPdq(7nlwSm7sPHiaOC7ArNkOiYvzGkM3Xe6twklr5E2M1ZgUcxJLlMAndOWZ0bOGjKv3ay5Iv347OAkL1MflcSmDaYL2ipDbfrUkduX8oMqFYsC43MIkTrl6twckICvgOI5DmH(KLykvayA3Dytw0NSOcE6uwF2YAZILgISebOYTRfD6ZIgMGh3ay5I4Hy4uTkoA(UalthGCPw0N1OINUWAZIfjLhs95Jkpv8bLBrZsL4WVnfvYN2ixMSyMaEUQeuM)plf3o2Ab2HId)2uu5w0Sujo8BtrLCzzYA02iEJJIqR44FIQPwNrZNSeNvSj9WGdP7MoazNDytw0NSOcE6uwF2YAZILgISebOYTRfD6ZIgMGNgDdGLlIhIHt1Q4O57cSmDaYLArFwJkE6cRnlwKu(L6ZhvEQ4dk3IMLkXHFBkQKpTrUmzXmb8CvjOm)FwkUDS1cSdfh(TPOYTOzPsC43MIk5YYK1OTr8ghfHwXX)evtToJMpzjoRyt6Hbhs3nDaYo7WMSOpzrf80PS(SfDc3ZsbMaSHilraQC7ArN(SOHj4rcl6ZAuXtxqNW9SuGjaLu(Lx3ay5I4Hy4uTkoA(UalthGC5LgIaGYTRfDQGMRu(oQOiYPklr2L6ZhvEQ4dk3IMLEyWH0DthGsLOXd)2uuP0qeauUDTOtfue5QmqfZ7yc9jlLL4ZczYIzc45Qsqz()SuC7yRfyhko8BtrLJMmafD3o(7w0NSemf1nDaQSGaWe9jlb(QyKXrLpFKDytw0NSOcE6uwF2kM3Xe6twnezjcqLBxl60Nfnmbp0qeauUDTOtfue5QmqfZ7yc9jlLLOKBZ6zdxHRXYftTMbu4z6auWeYQBaSCXQB8DunLYAZIfbwMoa5sL4WVnfvYN2ixMSyMaEUQeuM)plf3o2Ab2HId)2uu5w0S0ddoKUB6aKDPUDTOl85Jkpv8bLBrZWMGnzrFYIkcgaap6dtrDthGkliamrFYQbWuOkYFwSCdtWtmtapxvcoA(UEcCXHFBkQKpTr(7ViLgIaGYTRfDQGIixLbQyEhtOpzPSeFwW6zdxHRXYftTMbu4z6auWeknMjGNRkbL5)ZsXTJTwGDO4WVnfvUxAg2Kf9jlQiyaa8OS(Sv0aaLf9jlfyOEdL9XhUU6WGdP7nmbpUbWYfC08D9e4cSmDaYLsdraq521IovqrKRYavmVJj0NSuwIply9SHRW1y5IPwZak8mDakycLkbpDH1MflId)2uuj5PlS2SyrWzoZNSEVzH8CzzY4PlI5DmH(KL4WVnfvsE6IyEhtOpzj4mN5twV3SqEUSmz80f0jCplfycqXHFBkQK80f0jCplfycqbN5mFY69MfYZLzxAmtapxvcoA(UEcCXHFBkQKpw0NSewBwSiAJ833aPXmb8CvjOm)FwkUDS1cSdfh(TPOY9sZWMSOpzrfbdaGhL1NTIgaOSOpzPad1BOSp(W1vhgCiDVHj4XnawUGJMVRNaxGLPdqUuAicak3Uw0PckICvgOI5DmH(KLYs8zbRNnCfUglxm1AgqHNPdqbtO0yMaEUQeuM)plf3o2Ab2HId)2uujFOjdqr3TJ)Uf9jlH1MflI2iNvl6twcRnlweTr(7BlvcE6cRnlweh(TPOsYtxyTzXIGZCMpz9(czY4PlI5DmH(KL4WVnfvsE6IyEhtOpzj4mN5twVVqMmE6c6eUNLcmbO4WVnfvsE6c6eUNLcmbOGZCMpz9(c2HnzrFYIkcgaapkRpBXrZ31tG3We8eZeWZvLGY8)zP42XwlWouC43MIk3Z2nZABKltwmtapxvckZ)NLIBhBTa7qXHFBkQCl2GMHnzrFYIkcgaapkRpBr3nEUsPNaVHj4rNjiq8Z14hlxWekvNjiqut7UhyaG4WVnff2Kf9jlQiyaa8OS(SL1Mflnmbp6mbbIFUg)y5cMqPnkHBaSCbDc3ZsbMauGLPdqUujcpCTQnYflewBwSin8W1Q2ix8IWAZIfPHhUw1g5ITfwBwSWUmzHhUw1g5IfcRnlwyh2Kf9jlQiyaa8OS(SfDc3ZsbMaSHj4rNjiq8Z14hlxWekTrjcpCTQnYfle0jCplfycqPHhUw1g5Ixe0jCplfycqPHhUw1g5ITf0jCplfycq2HnzrFYIkcgaapkRpBfZ7yc9jRgMGhDMGaXpxJFSCbtO0gdpCTQnYfleX8oMqFYsAJUbWYfMonbmoQI5DmH(KLalthGCytw0NSOIGbaWJY6Zw8ZMsbMaSHj4rNjiqmfUECthGko(hkkOUfztUfnl1NpQ8uXhuYNfndBYI(KfvemaaEuwF2IF2ukWeGnmbpUbWYf0jCplfycqbwMoa5s1zccetHRh30bOIJ)HIcQBr2K7z5ML3xA(DjOHiaOC7ArNkOiYvzGkM3Xe6twklr59SHRW1y5IPwZak8mDakycL75f2LYtxyTzXI4WVnfvULFNgIaGA3OokLNUiM3Xe6twId)2uu5AJCPsWtxqNW9SuGjafh(TPOY1g5YK1OBaSCbDc3ZsbMauGLPdqo7sLGJ6mbbIDJPCXHFBkQCl)oneba1UrDuMSgDdGLl2nMYfyz6aKZU0ywU1ozj3YVtdraqTBuhHnzrFYIkcgaapkRpBXpBkfycWgMGh3ay5Iv347OAkL1MflcSmDaYLQZeeiMcxpUPdqfh)dffu3ISj3ZYnlVV087sqdraq521IovqrKRYavmVJj0NSuwIY7zdxHRXYftTMbu4z6auWek3Z2SlVl)Ue0qeauUDTOtfue5QmqfZ7yc9jlLLO8E2Wv4ASCXuRzafEMoafmHpVWUuE6cRnlweh(TPOYT870qeau7g1rP80fX8oMqFYsC43MIkxBKlvcoQZeei2nMYfh(TPOYT870qeau7g1rzYA0nawUy3ykxGLPdqo7sJz5w7KLCl)oneba1UrDe2Kf9jlQiyaa8OS(Sf)SPuGjaBycECdGLlmDAcyCufZ7yc9jlbwMoa5s1zccetHRh30bOIJ)HIcQBr2K7z5ML3xA(DjOHiaOC7ArNkOiYvzGkM3Xe6twklr59SHRW1y5IPwZak8mDakycL7zdyxkpDH1MflId)2uu5w(DAicaQDJ6Ouj4OotqGy3ykxC43MIk3YVtdraqTBuhLjRr3ay5IDJPCbwMoa5SlnMLBTtwYT870qeau7g1rytw0NSOIGbaWJY6Zw7gt5WMSOpzrfbdaGhL1NTcYidf5kBJ4noQ0r7dBYI(KfvemaaEuwF2kK5MawMQvPdmQdBYI(KfvemaaEuwF2kMvel)mh5QaG9XgMGNg5PlIzfXYpZrUkayFuPZCL4WVnfvAJw0NSeXSIy5N5ixfaSpkMsfaM2Dh2Kf9jlQiyaa8OS(Sf)SPu0Kb0WuoEhtORAbPUbEw0qC3M6zrdt54DmH(ZIgISebOYTRfD6ZIgMGhF(OYtfFqjFAJCytw0NSOIGbaWJY6Zw8ZMsrtgqdrwIau521Io9zrdXDBQNfnmLJ3Xe6Qj4XNiBu1HFBkjxUHPC8oMqx1csDd8SOHj4XnawUGUB8CLc)6NfrbwMoa5sxB3y6au8TPCBkffL2ih1zcce0DJNRu4x)Siko8BtrHnzrFYIkcgaapkRpBXpBkfnzanezjcqLBxl60Nfne3TPEw0WuoEhtORMGhFISrvh(TPKC5gMYX7ycDvli1nWZIgMGh3ay5c6UXZvk8RFwefyz6aKlDTDJPdqX3MYTPuue2Kf9jlQiyaa8OS(Sf)SPu0Kb0WuoEhtORAbPUbEw0qC3M6zrdt54DmH(Zcytw0NSOIGbaWJY6Zw0DJNRu6jWBiYseGk3Uw0PplAycECdGLlO7gpxPWV(zruGLPdqU012nMoafFBk3MsrrPnYrDMGabD345kf(1plIId)2uuPnArFYsq3nEUsPNaxmLkamT7oSjl6twurWaa4rz9zl6UXZvk9e4nezjcqLBxl60NfnmbpUbWYf0DJNRu4x)SikWY0bix6A7gthGIVnLBtPOiSjl6twurWaa4rz9zl6UXZvk9e4WMGnzrFYIkOHyXXJ(Wuu30bOYccat0NSAycEIzc45Qsqz()SuC7yRfyhko8BtrL8HMmafD3o(7sGVkgzCu5Zhz12iEJJc(HgpGbOIgamvR4SIn2LkrJUbWYfC08D9e4cSmDaYLjlMjGNRkbhnFxpbU4WVnfvYhAYau0D74VJVkgzCu5ZhzxQeUbWYf0CLY3rffrovGLPdqUmz80fH7w55xrNQLby34Sio8BtrLjJNUy9aqLBt5Id)2uu2HnzrFYIkOHyXXJY6Zwrdauw0NSuGH6nu2hFcgaapAdtWJeXmb8CvjOm)FwkUDS1cSdfh(TPOs6ZhvEQO72XFxILLxAYau0D74SltwmtapxvckZ)NLIBhBTa7qbti7s95Jkpv8bLlMjGNRkbL5)ZsXTJTwGDO4WVnff2Kf9jlQGgIfhpkRpBrrKRYavmVJj0NSAycEwB3y6auWqrffroSjl6twubneloEuwF2IPOUPdqLfeaMOpz1We804A7gthGcgkQOiYL2y4HRvTrUyHGY8)zP42XwlWouQeUbWYfC08D9e4cSmDaYLgZeWZvLGJMVRNaxC43MIk5d(QyKXrLpFuAJ2gXBCuenA04t1QIgW(JZIalthGCzYKGMmafD3oUCpllLgIaGYTRfDQGIixLbQyEhtOpzPSeL8fzYOjdqr3TJl3ZlsPHiaOC7ArNkOiYvzGkM3Xe6twklr5EEHDPUDTOl85Jkpv8bLBdyfFvmY4OYNpkLgIaGYTRfDQGIixLbQyEhtOpzPSeFwitMpFu5PIpOKpYpR4RIrghv(8X3Pjdqr3TJZoSjl6twubneloEuwF2IPOUPdqLfeaMOpz1We804A7gthGcgkQOiYLgZYT2jljFIg1v(8rwxB3y6aueAC(uTWMSOpzrf0qS44rz9zlMI6MoavwqayI(KvdrwIau521Io9zrdtWtJRTBmDakyOOIIixQen6galxWrZ31tGlWY0bixMSyMaEUQeC08D9e4Id)2uu585Jkpv0D74YKrtgGIUBhxUfSlvIgDdGLlwpau52uUalthGCzYOjdqr3TJl3c2LgZYT2jljFIg1v(8rwxB3y6aueAC(uTsLOrBJ4nokIgnA8PAvrdy)XzrGLPdqUmz6mbbIOrJgFQwv0a2FCweh(TPOY5ZhvEQO72XzVRTgp6KvFPxAEH8Pz55lV01wzxnvlTR965hMNJCirEcjw0NSGeWqDQa2uxdmuN23SRX1vhgCiDVVzFPf9n7Ayz6aK3FRRzrFYQRrNW9SuGja7AXBC8gRRjbKWtxqNW9SuGjafh(TPOqYRbj80f0jCplfycqbN5mFYcsyhsK8bsKas4PlS2SyrC43MIcjVgKWtxyTzXIGZCMpzbjSdjsHejGeE6c6eUNLcmbO4WVnffsEniHNUGoH7zPatak4mN5twqc7qIKpqIeqcpDrmVJj0NSeh(TPOqYRbj80fX8oMqFYsWzoZNSGe2HePqcpDbDc3ZsbMauC43MIcjscj80f0jCplfycqbN5mFYcsEhswi2URbMcvrExBXYDVV0l9n7Ayz6aK3FRRzrFYQRzTzXsxlEJJ3yDnjGeE6cRnlweh(TPOqYRbj80fwBwSi4mN5twqc7qIKpqIeqcpDrmVJj0NSeh(TPOqYRbj80fX8oMqFYsWzoZNSGe2HePqIeqcpDH1MflId)2uui51GeE6cRnlweCMZ8jliHDirYhirciHNUGoH7zPatako8BtrHKxds4PlOt4EwkWeGcoZz(KfKWoKifs4PlS2SyrC43MIcjscj80fwBwSi4mN5twqY7qYcX2DnWuOkY7AlwU79L2UVzxdlthG8(BDnl6twDTyEhtOpz11I344nwxtciHNUiM3Xe6twId)2uui51GeE6IyEhtOpzj4mN5twqc7qIKpqIeqcpDH1MflId)2uui51GeE6cRnlweCMZ8jliHDirkKibKWtxeZ7yc9jlXHFBkkK8AqcpDrmVJj0NSeCMZ8jliHDirYhirciHNUGoH7zPatako8BtrHKxds4PlOt4EwkWeGcoZz(KfKWoKifs4PlI5DmH(KL4WVnffsKes4PlI5DmH(KLGZCMpzbjVdjleB31atHQiVRTy5U39UghdmgG33SV0I(MDnl6twDnAicakqgzRRHLPdqE)TU3x6L(MDnl6twDnoUozo13ANyxdlthG8(BDVV029n7Ayz6aK3FRRLHDnk6Dnl6twDT12nMoa7ARnad21CdGLlO5kLVJkkICQalthGCirkKqdraq521IovqrKRYavmVJj0NSuwIqICpqY2qcRqYzdxHRXYftTMbu4z6auWecjYKbjUbWYf0jCplfycqbwMoa5qIuiHgIaGYTRfDQGIixLbQyEhtOpzbjY9ajldjScjNnCfUglxm1AgqHNPdqbtiKitgKqdraq521IovqrKRYavmVJj0NSGe5EGe5hsyfsoB4kCnwUyQ1mGcpthGcMWU2A7uL9XUgdfvue5DVV0g03SRHLPdqE)TUwg21OO31SOpz11wB3y6aSRT2amyxZI(KLGUB8CLspbUaFvmY4OYNpcjVdj2gXBCuenA04t1QIgW(JZIalthG8U2A7uL9XUwOX5t129(sl33SRHLPdqE)TUwg21oKIExZI(KvxBTDJPdWU2AdWGDT2iVRfVXXBSUMTr8ghfrJgn(uTQObS)4SiWY0bihsKcjsajUbWYf8ZMsrtgGalthGCirMmiXnawUGJMVRNaxGLPdqoKifsIzc45QsWrZ31tGlo8BtrHejFGK2ihsyVRT2ovzFSRfAC(uTDVVK8OVzxdlthG8(BDTmSRrrVRzrFYQRT2UX0byxBTbyWUgnebaLBxl6ubfrUkduX8oMqFYszjcjs(ajlGewHe3ay5Iv347OAkL1MflcSmDaYHewHe3ay5ctNMaghvX8oMqFYsGLPdqoK8oK8cKWkKibK4galxS6gFhvtPS2SyrGLPdqoKifsCdGLlO5kLVJkkICQalthGCirkKqdraq521IovqrKRYavmVJj0NSuwIqICqYlqc7qcRqIeqIBaSCbDc3ZsbMauGLPdqoKifsAesCdGLlIhIHt1Q4O57cSmDaYHePqsJqIBaSCb)SPu0KbiWY0bihsyhsyfsoB4kCnwUyQ1mGcpthGcMWU2A7uL9XU23MYTPuuS79LKN9n7Ayz6aK3FRRLHDnk6Dnl6twDT12nMoa7ARnad21KasAesCdGLlOt4EwkWeGcSmDaYHezYGeE6c6eUNLcmbOGjesyhsKcj80fwBwSiOUfzdsK7bsw0mKifsAes4PlS2SyrCyWH0DthGqIuiHNUiM3Xe6twcMWU2A7uL9XUgpDQIjS79LK)(MDnSmDaY7V11SOpz11IgaOSOpzPad17AGH6QY(yxlMjGNRkA37ljF6B21WY0biV)wxZI(KvxJF2ukAYa6ArwIau521IoTV0IUw8ghVX6A(8rLNk(GqIKpqsBKdjsHeAYau0D74qIKqYYDT4UnvxBrxBkhVJj0vTGu3aDTfDVV0IM7B21WY0biV)wxlEJJ3yDnAicak3Uw0PckICvgOI5DmH(KLYsesK8bsEbsyfsoB4kCnwUyQ1mGcpthGcMWUMf9jRU2UXuE37lTyrFZUgwMoa5936AXBC8gRRXtxyTzXIWNiBt1cjsHeE6IyEhtOpzj8jY2uTqIuircirNjiqyrFwJkgJkOUfzdsEGKLHezYGeAYau0D74qYdK0mKWoKifsKasAesCdGLlc3TYZVIovldWUXzrGLPdqoKitgKWtxeUBLNFfDQwgGDJZI4WVnffsyhsKcjsajncjUbWYfC08D9e4cSmDaYHezYGKyMaEUQeC08D9e4Id)2uuirYhiPnYHezYGKgHKyMaEUQeC08D9e4Id)2uuirMmiHgIaGYTRfDQGIixLbQyEhtOpzPSeHe5GKfqcRqYzdxHRXYftTMbu4z6auWecjS31SOpz11Om)FwkUDS1cSd7EFPfV03SRHLPdqE)TUw8ghVX6AXmb8CvjOm)FwkUDS1cSdfh(TPOqIuizTDJPdqbpDQIjesKcj0qeauUDTOtfue5QmqfZ7yc9jlLLiK8ajlGewHKZgUcxJLlMAndOWZ0bOGjesKcjsajncjiLIvefRh6KLkduH4fGrFYs8NkpirkK0iKyBeVXrb)qJhWaurdaMQvCwXgKitgKeZeWZvLGY8)zP42XwlWouC43MIcjYbjB3mKWExZI(KvxJJMVRNaV79LwSDFZUgwMoa5936AXBC8gRRPZeeiomYgaPuvqEruC43MI21SOpz118DuXu6jtXvb5fXU3xAXg03SRHLPdqE)TUMf9jRUM1MflDT4noEJ11o8BtrHejFGK2ihsyfsSOpzjO7gpxP0tGlWxfJmoQ85JqIuiXNpQ8uXhesKdsK)UwKLiavUDTOt7lTO79LwSCFZUgwMoa5936AXBC8gRR5ZhHejHKTBURzrFYQR9XFESOYafGjoCf)q7t7EFPfYJ(MDnSmDaY7V11SOpz11S2SyPRfVXXBSUMpFesKds2UzirkKeZeWZvLGY8)zP42XwlWouC43MIcjs(ajlwgsKcj4gIzcdrUW2iD3oJQcYYvzGkmxHxxdmfQI8U22n39(slKN9n7Ayz6aK3FRRzrFYQRfZ7yc9jRUw8ghVX6A(8riroiz7MHePqsmtapxvckZ)NLIBhBTa7qXHFBkkKi5dKSyzirkKGBiMjme5cBJ0D7mQkilxLbQWCfEqIuiPriXnawUW0PjGXrvmVJj0NSeyz6aKdjsHejGe3ay5c6eUNLcmbOalthGCirMmiHgIaGYTRfDQGIixLbQyEhtOpzPSeHe5GKfqIuiHgIaGYTRfDQGIixLbQyEhtOpzPSeHejFGKTHe27AGPqvK312U5U3xAH833SRHLPdqE)TUMf9jRUgDc3ZsbMaSRfVXXBSUMpFesKds2UzirkKeZeWZvLGY8)zP42XwlWouC43MIcjs(ajlwgsKcj4gIzcdrUW2iD3oJQcYYvzGkmxHxxdmfQI8U22n39(slKp9n7Ayz6aK3FRRzrFYQRXuu30bOYccat0NS6AXBC8gRR1iKeZYT2jlirkK4ZhvEQ4dcjs(ajYFxlYseGk3Uw0P9Lw09(sV0CFZUgwMoa5936Aw0NS6A8ZMsrtgqxlYseGk3Uw0P9Lw01IwfrGAc6A(ezJQo8Btj5YDT4noEJ11CdGLlO7gpxPWV(zruGLPdqoKifswB3y6au8TPCBkffHePqch1zcce0DJNRu4x)Siko8BtrHePqch1zcce0DJNRu4x)Siko8BtrHejFGK2ihsEhsEP79LEzrFZUgwMoa5936Aw0NS6A0DJNRu6jW7AXBC8gRR5galxq3nEUsHF9ZIOalthGCirkKS2UX0bO4Bt52ukkcjsHeoQZeeiO7gpxPWV(zruC43MIcjsHeoQZeeiO7gpxPWV(zruC43MIcjs(aj4RIrghv(8ri5Di5fiHviXpBncu(8rirkK0iKyrFYsq3nEUsPNaxmLkamT7ExlYseGk3Uw0P9Lw09(sV8sFZUgwMoa5936Aw0NS6AH7w55xrNQLby34S01I344nwxZNpcjYbjBVmKifsC7Arx4ZhvEQ4dcjYbjlKhqY7qcneba1UrDesKcjsajncjiLIvefRh6KLkduH4fGrFYs8NkpirkK0iKyBeVXrb)qJhWaurdaMQvCwXgKitgKeZeWZvLGY8)zP42XwlWouC43MIcjYbjBWYqcRqcnzak6UDCi5DiX2iEJJc(HgpGbOIgamvR4SInirMmijMjGNRkbL5)ZsXTJTwGDO4WVnffsKeswSmK8oKqdraqTBuhHewHeAYau0D74qY7qITr8ghf8dnEadqfnayQwXzfBqc7DTilraQC7ArN2xAr37l9Y29n7Ayz6aK3FRRzrFYQRXuu30bOYccat0NS6AXBC8gRR1iKS2UX0bOGHIkkICirkKqtgGIUBhhsEGKL7ArwIau521IoTV0IU3x6LnOVzxdlthG8(BDT4noEJ11wB3y6auWqrffroKifsOjdqr3TJdjpqYYDnl6twDnkICvgOI5DmH(Kv37l9YY9n7Ayz6aK3FRRzrFYQRfnaqzrFYsbgQ31ad1vL9XUgpDA37l9I8OVzxdlthG8(BDnl6twDT1davUnL31I344nwxZNpcjYbjlwgsKcjUDTOl85Jkpv8bHe5EGKfndjsHejGKyMaEUQeuM)plf3o2Ab2HId)2uuiroiz7MHezYGKyMaEUQeuM)plf3o2Ab2HId)2uuirsizrZqIuiHNUWAZIfXHFBkkKi3dKSOzirkKWtxeZ7yc9jlXHFBkkKi3dKSOzirkKibKWtxqNW9SuGjafh(TPOqICpqYIMHezYGKgHe3ay5c6eUNLcmbOalthGCiHDiH9UwKLiavUDTOt7lTO79LErE23SRHLPdqE)TUMf9jRUMTr6UDgvfKLRYavyUcVUw8ghVX6A(8rirYhiz7UwzFSRzBKUBNrvbz5QmqfMRWR79LEr(7B21WY0biV)wxlEJJ3yDnF(iKi5dKS9YDnl6twDTWDR88ROt1YaSBCw6EFPxKp9n7Ayz6aK3FRRfVXXBSUMpFesKeswSCxZI(KvxB9aqLBt5DVV02n33SRHLPdqE)TUw8ghVX6AsajXmb8CvjOm)FwkUDS1cSdfh(TPOqIKqYILHewHeAYau0D74qY7qITr8ghf8dnEadqfnayQwbwMoa5qImzqIeqITr8ghf8dnEadqfnayQwXzfBqImzqcsPyfrX6HozPYaviEby0NSeNvSbjSdjsHeF(iKihKSDZqIuiXTRfDHpFu5PIpiKi3dK8YIMHe2HePqIeqcpDr4UvE(v0PAza2nolId)2uuirMmiHNUy9aqLBt5Id)2uuirMmiPriXnawUiC3kp)k6uTma7gNfbwMoa5qIuiPriXnawUy9aqLBt5cSmDaYHe2HezYGeF(OYtfFqirsiz7MHewHK2iVRzrFYQR1YyhFSsLbkBJ4L(E37lT9I(MDnSmDaY7V11I344nwxlMjGNRkbL5)ZsXTJTwGDO4WVnffsKeswSmKWkKqtgGIUBhhsEhsSnI34OGFOXdyaQObat1kWY0bihsKcjsaj80fH7w55xrNQLby34Sio8BtrHezYGeE6I1davUnLlo8BtrHe27Aw0NS6AC7ytrtgq37lT9l9n7Aw0NS6A64rXJTPA7Ayz6aK3FR79L2E7(MDnSmDaY7V11SOpz11IgaOSOpzPad17AGH6QY(yxJgIfhpA37lT9g03SRHLPdqE)TUMf9jRUw0aaLf9jlfyOExdmuxv2h7AbdaGhT7DVRfEym)6M33SV0I(MDnl6twDnkZ)NLkab7mLJxxdlthG8(BDVV0l9n7Ayz6aK3FRRfVXXBSUMBaSCr7n)CouLbkQfVjyIOalthG8UMf9jRUw7n)CouLbkQfVjyIy37lTDFZUMf9jRUwy6twDnSmDaY7V19(sBqFZUgwMoa5936AL9XUMTr6UDgvfKLRYavyUcVUMf9jRUMTr6UDgvfKLRYavyUcVU3xA5(MDnSmDaY7V11I344nwxJgIaGYTRfDQGIixLbQyEhtOpzPSeHe5EGKTHePqsJqcUHyMWqKlSns3TZOQGSCvgOcZv411SOpz11OiYvzGkM3Xe6twDVVK8OVzxZI(KvxB3ykVRHLPdqE)TU3xsE23SRHLPdqE)TUw8ghVX6AncjUbWYf7gt5cSmDaYHePqcnebaLBxl6ubfrUkduX8oMqFYszjcjscjB31SOpz11O7gpxP0tG39(sYFFZUgwMoa5936AXBC8gRR1iK4galxSBmLlWY0bihsKcj0qeauUDTOtfue5QmqfZ7yc9jlLLiKijKSnKifsAesWneZegICHTr6UDgvfKLRYavyUcVUMf9jRUgD345kLEc8U39Uwmtapxv0(M9Lw03SRHLPdqE)TUMf9jRUMTr6UDgvfKLRYavyUcVUw8ghVX6AsajncjUbWYfH7w55xrNQLby34SiWY0bihsKjdsIzc45QseUBLNFfDQwgGDJZI4WVnffsKes2ai5DiHgIaGA3OocjYKbjncjXmb8Cvjc3TYZVIovldWUXzrC43MIcjSdjsHKyMaEUQeuM)plf3o2Ab2HId)2uuirsizH8bsEhsOHiaO2nQJqcRqcnzak6UDCi5DiX2iEJJc(HgpGbOIgamvR4SInirkKWtxyTzXI4WVnffsKcj80fX8oMqFYsC43MIcjsHejGeE6c6eUNLcmbO4WVnffsKjdsAesCdGLlOt4EwkWeGcSmDaYHe27AL9XUMTr6UDgvfKLRYavyUcVU3x6L(MDnSmDaY7V11I344nwxtciXnawUGBhBkAYau)HIhlcSmDaYHePqsmtapxvckZ)NLIBhBTa7qbtiKifsIzc45QsWTJnfnzacMqiHDirMmijMjGNRkbL5)ZsXTJTwGDOGjesKjds85Jkpv8bHejHKTBURzrFYQRfM(Kv37lTDFZUgwMoa5936AXBC8gRRfZeWZvLGY8)zP42XwlWouC43MIcjYbjYZMHezYGeF(OYtfFqirsi5LMHezYGejGejGeDMGaHf9znQymQG6wKni5bswgsKjdsOjdqr3TJdjpqsZqc7qIuirciPriXnawUiC3kp)k6uTma7gNfbwMoa5qImzqsmtapxvIWDR88ROt1YaSBCweh(TPOqc7qIuirciPriXnawUGJMVRNaxGLPdqoKitgKeZeWZvLGJMVRNaxC43MIcjs(ajTroKitgK0iKeZeWZvLGJMVRNaxC43MIcjSdjsHKgHKyMaEUQeuM)plf3o2Ab2HId)2uuiH9UMf9jRUgdfvJJFA37lTb9n7Ayz6aK3FRRfVXXBSUwJqsmtapxvckZ)NLIBhBTa7qbtyxZI(KvxlyouhKjV79LwUVzxdlthG8(BDT4noEJ11AesIzc45Qsqz()SuC7yRfyhkyc7Aw0NS6A6Gm5QaMJLU3xsE03SRHLPdqE)TUw8ghVX6A(8riroiz7M7Aw0NS6AF8NhlQmqbyIdxXp0(0U3xsE23SRHLPdqE)TUw8ghVX6A(8rLNk(GqIKqYlndjScjTroKitgKqdraq521IovqrKRYavmVJj0NSuwIqICqYciHvi5SHRW1y5IPwZak8mDakycHezYGe3ay5cAUs57OIIiNkWY0bihsKcjXmb8CvjOm)FwkUDS1cSdfh(TPOqICpqsmtapxvckZ)NLIBhBTa7qbN5mFYcsKxizrZDnl6twDnUDSPOjdO79LK)(MDnSmDaY7V11I344nwxleDb3o2Ab2HId)2uuirMmirciPrijMjGNRkbhnFxpbU4WVnffsKjdsAesCdGLl4O576jWfyz6aKdjSdjsHKyMaEUQeuM)plf3o2Ab2HId)2uuirUhir(BgsKcjiLIvef6Gm5Qmq57Ocl8ZI4SIniroizrxZI(KvxthKjxLbkFhvyHFw6EFj5tFZUgwMoa5936Aw0NS6AHzKn0PZgrUkM)qg38jlfhxprSRfVXXBSUMeqsmtapxvckZ)NLIBhBTa7qXHFBkkKi3dK8YYqImzqIpFu5PIpiKi5dKSDZqc7qIuircijMjGNRkbhnFxpbU4WVnffsKjdsAesCdGLl4O576jWfyz6aKdjS31k7JDTWmYg60zJixfZFiJB(KLIJRNi29(slAUVzxdlthG8(BDnl6twDTl94XqDKRwNjptfpbGUw8ghVX6AsajXmb8CvjOm)FwkUDS1cSdfh(TPOqICpqYlldjYKbj(8rLNk(GqIKpqY2ndjSdjsHejGKyMaEUQeC08D9e4Id)2uuirMmiPriXnawUGJMVRNaxGLPdqoKWExRSp21U0Jhd1rUADM8mv8ea6EFPfl6B21WY0biV)wxZI(KvxJUpRXtTgR8RoemXUw8ghVX6AsajXmb8CvjOm)FwkUDS1cSdfh(TPOqICpqYlldjYKbj(8rLNk(GqIKpqY2ndjSdjsHejGKyMaEUQeC08D9e4Id)2uuirMmiPriXnawUGJMVRNaxGLPdqoKWExRSp21O7ZA8uRXk)QdbtS79Lw8sFZUgwMoa5936Aw0NS6A2gIzcthlxvgJpagAxlEJJ3yDnjGKyMaEUQeuM)plf3o2Ab2HId)2uuirUhi5LLHezYGeF(OYtfFqirYhiz7MHe2HePqIeqsmtapxvcoA(UEcCXHFBkkKitgK0iK4galxWrZ31tGlWY0bihsyVRv2h7A2gIzcthlxvgJpagA37lTy7(MDnSmDaY7V11SOpz118HJupVVkMC8v7AXBC8gRRjbKeZeWZvLGY8)zP42XwlWouC43MIcjY9ajVSmKitgK4ZhvEQ4dcjs(ajB3mKWoKifsKasIzc45QsWrZ31tGlo8BtrHezYGKgHe3ay5coA(UEcCbwMoa5qc7DTY(yxZhos98(QyYXxT79LwSb9n7Ayz6aK3FRRzrFYQRTEmGkduupVpTRfVXXBSUMeqsmtapxvckZ)NLIBhBTa7qXHFBkkKi3dK8YYqImzqIpFu5PIpiKi5dKSDZqc7qIuircijMjGNRkbhnFxpbU4WVnffsKjdsAesCdGLl4O576jWfyz6aKdjS31k7JDT1JbuzGI659PDVV0IL7B21WY0biV)wxlEJJ3yDnDMGabycqDqMCb1TiBqIKqY2Dnl6twDTv5b4RXPuhsZYQi29(slKh9n7Aw0NS6A3egcq1ukAOfXUgwMoa5936E37A0qS44r7B2xArFZUgwMoa5936AXBC8gRRfZeWZvLGY8)zP42XwlWouC43MIcjs(aj0KbOO72XHK3HejGe8vXiJJkF(iKWkKyBeVXrb)qJhWaurdaMQvCwXgKWoKifsKasAesCdGLl4O576jWfyz6aKdjYKbjXmb8Cvj4O576jWfh(TPOqIKpqcnzak6UDCi5DibFvmY4OYNpcjSdjsHejGe3ay5cAUs57OIIiNkWY0bihsKjds4Plc3TYZVIovldWUXzrC43MIcjYKbj80fRhaQCBkxC43MIcjS31SOpz11ykQB6auzbbGj6twDVV0l9n7Ayz6aK3FRRfVXXBSUMeqsmtapxvckZ)NLIBhBTa7qXHFBkkKijK4ZhvEQO72XHK3HejGKLHe5fsOjdqr3TJdjSdjYKbjXmb8CvjOm)FwkUDS1cSdfmHqc7qIuiXNpQ8uXhesKdsIzc45Qsqz()SuC7yRfyhko8Btr7Aw0NS6Ardauw0NSuGH6DnWqDvzFSRfmaaE0U3xA7(MDnSmDaY7V11I344nwxBTDJPdqbdfvue5Dnl6twDnkICvgOI5DmH(Kv37lTb9n7Ayz6aK3FRRfVXXBSUwJqYA7gthGcgkQOiYHePqsJqs4HRvTrUyHGY8)zP42XwlWoesKcjsajUbWYfC08D9e4cSmDaYHePqsmtapxvcoA(UEcCXHFBkkKi5dKGVkgzCu5ZhHePqsJqITr8ghfrJgn(uTQObS)4SiWY0bihsKjdsKasOjdqr3TJdjY9ajldjsHeAicak3Uw0PckICvgOI5DmH(KLYsesKesEbsKjdsOjdqr3TJdjY9ajVajsHeAicak3Uw0PckICvgOI5DmH(KLYsesK7bsEbsyhsKcjUDTOl85Jkpv8bHe5GKnasyfsWxfJmoQ85JqIuiHgIaGYTRfDQGIixLbQyEhtOpzPSeHKhizbKitgK4ZhvEQ4dcjs(ajYpKWkKGVkgzCu5ZhHK3HeAYau0D74qc7Dnl6twDnMI6MoavwqayI(Kv37lTCFZUgwMoa5936AXBC8gRR1iKS2UX0bOGHIkkICirkKeZYT2jlirYhijAux5ZhHewHK12nMoafHgNpvBxZI(KvxJPOUPdqLfeaMOpz19(sYJ(MDnSmDaY7V11SOpz11ykQB6auzbbGj6twDT4noEJ11AeswB3y6auWqrffroKifsKasAesCdGLl4O576jWfyz6aKdjYKbjXmb8Cvj4O576jWfh(TPOqICqIpFu5PIUBhhsKjdsOjdqr3TJdjYbjlGe2HePqIeqsJqIBaSCX6bGk3MYfyz6aKdjYKbj0KbOO72XHe5GKfqc7qIuijMLBTtwqIKpqs0OUYNpcjScjRTBmDakcnoFQwirkKibK0iKyBeVXrr0OrJpvRkAa7polcSmDaYHezYGeDMGar0OrJpvRkAa7polId)2uuiroiXNpQ8ur3TJdjS31ISebOYTRfDAFPfDV7DTGbaWJ23SV0I(MDnSmDaY7V11SOpz11ykQB6auzbbGj6twDT4noEJ11Izc45QsWrZ31tGlo8BtrHejFGK2ihsEhsEbsKcj0qeauUDTOtfue5QmqfZ7yc9jlLLiK8ajlGewHKZgUcxJLlMAndOWZ0bOGjesKcjXmb8CvjOm)FwkUDS1cSdfh(TPOqICqYln31atHQiVRTy5U3x6L(MDnSmDaY7V11I344nwxZnawUGJMVRNaxGLPdqoKifsOHiaOC7ArNkOiYvzGkM3Xe6twklri5bswajScjNnCfUglxm1AgqHNPdqbtiKifsKas4PlS2SyrC43MIcjscj80fwBwSi4mN5twqY7qsZc55YqImzqcpDrmVJj0NSeh(TPOqIKqcpDrmVJj0NSeCMZ8jli5DiPzH8CzirMmiHNUGoH7zPatako8BtrHejHeE6c6eUNLcmbOGZCMpzbjVdjnlKNldjSdjsHKyMaEUQeC08D9e4Id)2uuirYhiXI(KLWAZIfrBKdjVdjBaKifsIzc45Qsqz()SuC7yRfyhko8BtrHe5GKxAURzrFYQRfnaqzrFYsbgQ31ad1vL9XUgxxDyWH09U3xA7(MDnSmDaY7V11I344nwxZnawUGJMVRNaxGLPdqoKifsOHiaOC7ArNkOiYvzGkM3Xe6twklri5bswajScjNnCfUglxm1AgqHNPdqbtiKifsIzc45Qsqz()SuC7yRfyhko8BtrHejFGeAYau0D74qY7qIf9jlH1MflI2ihsyfsSOpzjS2Syr0g5qY7qY2qIuirciHNUWAZIfXHFBkkKijKWtxyTzXIGZCMpzbjVdjlGezYGeE6IyEhtOpzjo8BtrHejHeE6IyEhtOpzj4mN5twqY7qYcirMmiHNUGoH7zPatako8BtrHejHeE6c6eUNLcmbOGZCMpzbjVdjlGe27Aw0NS6Ardauw0NSuGH6DnWqDvzFSRX1vhgCiDV79L2G(MDnSmDaY7V11I344nwxlMjGNRkbL5)ZsXTJTwGDO4WVnffsK7bs2UziHviPnYHezYGKyMaEUQeuM)plf3o2Ab2HId)2uuiroizXg0CxZI(KvxJJMVRNaV79LwUVzxdlthG8(BDT4noEJ110zcce)Cn(XYfmHqIuirNjiqut7UhyaG4WVnfTRzrFYQRr3nEUsPNaV79LKh9n7Ayz6aK3FRRfVXXBSUMotqG4NRXpwUGjesKcjncjsajUbWYf0jCplfycqbwMoa5qIuircij8W1Q2ixSqyTzXcKifscpCTQnYfViS2SybsKcjHhUw1g5ITfwBwSajSdjYKbjHhUw1g5IfcRnlwGe27Aw0NS6AwBwS09(sYZ(MDnSmDaY7V11I344nwxtNjiq8Z14hlxWecjsHKgHejGKWdxRAJCXcbDc3ZsbMaesKcjHhUw1g5Ixe0jCplfycqirkKeE4AvBKl2wqNW9SuGjaHe27Aw0NS6A0jCplfycWU3xs(7B21WY0biV)wxlEJJ3yDnDMGaXpxJFSCbtiKifsAescpCTQnYfleX8oMqFYcsKcjncjUbWYfMonbmoQI5DmH(KLalthG8UMf9jRUwmVJj0NS6EFj5tFZUgwMoa5936AXBC8gRRPZeeiMcxpUPdqfh)dffu3ISbjYbjlAgsKcj(8rLNk(GqIKpqYIM7Aw0NS6A8ZMsbMaS79Lw0CFZUgwMoa5936AXBC8gRR5galxqNW9SuGjafyz6aKdjsHeDMGaXu46XnDaQ44FOOG6wKnirUhiz5MHe5fsEPzi5DirciHgIaGYTRfDQGIixLbQyEhtOpzPSeHe5fsoB4kCnwUyQ1mGcpthGcMqirUhi5fiHDirkKWtxyTzXI4WVnffsKdswgsEhsOHiaO2nQJqIuiHNUiM3Xe6twId)2uuiroiPnYHePqIeqcpDbDc3ZsbMauC43MIcjYbjTroKitgK0iK4galxqNW9SuGjafyz6aKdjSdjsHejGeoQZeei2nMYfh(TPOqICqYYqY7qcneba1UrDesKjdsAesCdGLl2nMYfyz6aKdjSdjsHKywU1ozbjYbjldjVdj0qeau7g1XUMf9jRUg)SPuGja7EFPfl6B21WY0biV)wxlEJJ3yDn3ay5Iv347OAkL1MflcSmDaYHePqIotqGykC94MoavC8puuqDlYgKi3dKSCZqI8cjV0mK8oKibKqdraq521IovqrKRYavmVJj0NSuwIqI8cjNnCfUglxm1AgqHNPdqbtiKi3dKSnKWoKiVqYYqY7qIeqcnebaLBxl6ubfrUkduX8oMqFYszjcjYlKC2Wv4ASCXuRzafEMoafmHqYdK8cKWoKifs4PlS2SyrC43MIcjYbjldjVdj0qeau7g1rirkKWtxeZ7yc9jlXHFBkkKihK0g5qIuirciHJ6mbbIDJPCXHFBkkKihKSmK8oKqdraqTBuhHezYGKgHe3ay5IDJPCbwMoa5qc7qIuijMLBTtwqICqYYqY7qcneba1UrDSRzrFYQRXpBkfycWU3xAXl9n7Ayz6aK3FRRfVXXBSUMBaSCHPttaJJQyEhtOpzjWY0bihsKcj6mbbIPW1JB6auXX)qrb1TiBqICpqYYndjYlK8sZqY7qIeqcnebaLBxl6ubfrUkduX8oMqFYszjcjYlKC2Wv4ASCXuRzafEMoafmHqICpqYgajSdjsHeE6cRnlweh(TPOqICqYYqY7qcneba1UrDesKcjsajCuNjiqSBmLlo8BtrHe5GKLHK3HeAicaQDJ6iKitgK0iK4galxSBmLlWY0bihsyhsKcjXSCRDYcsKdswgsEhsOHiaO2nQJDnl6twDn(ztPata29(sl2UVzxZI(KvxB3ykVRHLPdqE)TU3xAXg03SRzrFYQRfKrgkYv2gXBCuPJ2VRHLPdqE)TU3xAXY9n7Aw0NS6AHm3eWYuTkDGr9UgwMoa5936EFPfYJ(MDnSmDaY7V11I344nwxRriHNUiMvel)mh5QaG9rLoZvId)2uuirkK0iKyrFYseZkILFMJCvaW(OykvayA39UMf9jRUwmRiw(zoYvba7JDVV0c5zFZUgwMoa5936Aw0NS6A8ZMsrtgqxlYseGk3Uw0P9Lw01MYX7yc9U2IUw8ghVX6A(8rLNk(GqIKpqsBK31I72uDTfDTPC8oMqx1csDd01w09(slK)(MDnSmDaY7V11SOpz114NnLIMmGUwKLiavUDTOt7lTORnLJ3Xe6QjOR5tKnQ6WVnLKl31I344nwxZnawUGUB8CLc)6NfrbwMoa5qIuizTDJPdqX3MYTPuuesKcjncjCuNjiqq3nEUsHF9ZIO4WVnfTRf3TP6Al6At54DmHUQfK6gORTO79LwiF6B21WY0biV)wxZI(KvxJF2ukAYa6ArwIau521IoTV0IU2uoEhtORMGUMpr2OQd)2usUCxlEJJ3yDn3ay5c6UXZvk8RFwefyz6aKdjsHK12nMoafFBk3MsrXUwC3MQRTORnLJ3Xe6QwqQBGU2IU3x6LM7B21WY0biV)wxZI(KvxJF2ukAYa6At54DmHExBrxlUBt11w01MYX7ycDvli1nqxBr37l9YI(MDnSmDaY7V11SOpz11O7gpxP0tG31I344nwxZnawUGUB8CLc)6NfrbwMoa5qIuizTDJPdqX3MYTPuuesKcjncjCuNjiqq3nEUsHF9ZIO4WVnffsKcjncjw0NSe0DJNRu6jWftPcat7U31ISebOYTRfDAFPfDVV0lV03SRHLPdqE)TUMf9jRUgD345kLEc8Uw8ghVX6AUbWYf0DJNRu4x)SikWY0bihsKcjRTBmDak(2uUnLIIDTilraQC7ArN2xAr37l9Y29n7Aw0NS6A0DJNRu6jW7Ayz6aK3FR7DVRXtN23SV0I(MDnSmDaY7V11I344nwxJNUiM3Xe6twId)2uuirYhiXI(KLGIixLbQyEhtOpzjIg1v(8riHviXNpQ8ur3TJdjScjBG4fi5DircizbKiVqIBaSCr8qmCQwfhnFxGLPdqoK8oK0SyXYqc7qIuiHgIaGYTRfDQGIixLbQyEhtOpzPSeHe5EGKTHewHKZgUcxJLlMAndOWZ0bOGjesyfsCdGLlwDJVJQPuwBwSiWY0bihsKcjncj80fue5QmqfZ7yc9jlXHFBkkKifsAesSOpzjOiYvzGkM3Xe6twIPubGPD37Aw0NS6Aue5QmqfZ7yc9jRU3x6L(MDnSmDaY7V11SOpz11S2SyPRfVXXBSUMBaSCr8qmCQwfhnFxGLPdqoKifsSOpRrfpDH1MflqIKqI8asKcj(8rLNk(GqICqYIMHePqIeqYHFBkkKi5dK0g5qImzqsmtapxvckZ)NLIBhBTa7qXHFBkkKihKSOzirkKibKC43MIcjscjldjYKbjncj2gXBCueAfh)tun16mA(KL4SInirkKCyWH0DthGqc7qc7DTilraQC7ArN2xAr37lTDFZUgwMoa5936Aw0NS6AwBwS01I344nwxRriXnawUiEigovRIJMVlWY0bihsKcjw0N1OINUWAZIfirsir(HePqIpFu5PIpiKihKSOzirkKibKC43MIcjs(ajTroKitgKeZeWZvLGY8)zP42XwlWouC43MIcjYbjlAgsKcjsajh(TPOqIKqYYqImzqsJqITr8ghfHwXX)evtToJMpzjoRydsKcjhgCiD30biKWoKWExlYseGk3Uw0P9Lw09(sBqFZUgwMoa5936Aw0NS6A0jCplfycWUw8ghVX6Asajw0N1OINUGoH7zPatacjscjYpKiVqIBaSCr8qmCQwfhnFxGLPdqoKiVqcnebaLBxl6ubnxP8DurrKtvwIqc7qIuiXNpQ8uXhesKdsw0mKifsom4q6UPdqirkKibK0iKC43MIcjsHeAicak3Uw0PckICvgOI5DmH(KLYsesEGKfqImzqsmtapxvckZ)NLIBhBTa7qXHFBkkKihKqtgGIUBhhsEhsSOpzjykQB6auzbbGj6twc8vXiJJkF(iKWExlYseGk3Uw0P9Lw09(sl33SRHLPdqE)TUMf9jRUwmVJj0NS6AXBC8gRRrdraq521IovqrKRYavmVJj0NSuwIqIKqY2qcRqYzdxHRXYftTMbu4z6auWecjScjUbWYfRUX3r1ukRnlweyz6aKdjsHejGKd)2uuirYhiPnYHezYGKyMaEUQeuM)plf3o2Ab2HId)2uuiroizrZqIui5WGdP7MoaHe2HePqIBxl6cF(OYtfFqiroizrZDTilraQC7ArN2xAr37E37AgJVNxxtB(VoDV79oa]] )


end