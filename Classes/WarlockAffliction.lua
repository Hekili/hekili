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

        potion = "battle_potion_of_intellect",

        package = "Affliction",
    } )


    spec:RegisterPack( "Affliction", 20190712.0010, [[du0M6bqikv9iLQkxsuQAtivJIIQtrrzvaQEfsXSOu6wiL0Uq1VuszyIsoMsyzakptukttPQ4AkPABiLQ(MsvvJtPQ05eLkTorPcZJI4EaSpkshePuPfQuLhIuIyIiLkUisjsojsjkwjLkZePePUjsjQANkrwQOurpLctvjQVIuIs7vK)s0Gr5WKwmL8yHMmHldTzb(SOA0kLtR41ukMTQUnq7wYVLA4c64iLOYYv55iMovxhjBxj57kvgpsjCEaz9iLY8ff7h0PfPLtgc1X0salRfz3S2)faJNvwlY2IfjdhOqmzeQrB0CmzukiMmODdc(j6txjJqfOVvrA5KbPPUiMm2CpKKDS2A5JVrzXJn4AKbK6vF6kEAGVgzaJRLmSOM3PLPswjdH6yAjGL1ISBw7)cGXZkRfaBDGLmiHymTeWO9RNm2gHaRKvYqGKyYy)GmA3GGFI(0fKrlREFhTbA3(bzBUhsYowBT8X3OS4XgCnYas9QpDfpnWxJmGX1G2TFqMDupqq2cGzlKbSSwKDHmAfYYkRSJfzbTdA3(bz0s20khjzhq72piJwHmAxHafqMri(pKrlDhTHdTB)GmAfYODfcuaz0o4QM6GmA518jYH2TFqgTczzNiyVcfqMRxo6YjGZ5q72piJwHSStKwoQ5qiJ2PxMazuHqwxqMRxo6qwqFqgTdQ(Mv)oKzozQiczhgCizdY(oFIq2qGmXeeGhwoKnbqgTeAhcKPhczIHOwpkmJdTB)GmAfYYoXWxJiKrWv4PpK56LJo3hqu6TumiKfvcsGSDJVbz(aIsVLIbHmZXsazDaKHvSPkhpZ4jJWRdMhtg7hKr7ge8t0NUGmAz177Onq72piBZ9qs2XARLp(gLfp2GRrgqQx9PR4Pb(AKbmUg0U9dYSJ6bcYwamBHmGL1ISlKrRqwwzLDSilODq72piJwYMw5ij7aA3(bz0kKr7keOaYmcX)HmAP7OnCOD7hKrRqgTRqGciJ2bx1uhKrlVMpro0U9dYOvil7eb7vOaYC9YrxobCohA3(bz0kKLDI0Yrnhcz0o9YeiJkeY6cYC9YrhYc6dYODq13S63HmZjtfri7WGdjBq235teYgcKjMGa8WYHSjaYOLq7qGm9qitme16rHzCOD7hKrRqw2jg(AeHmcUcp9HmxVC05(aIsVLIbHSOsqcKTB8niZhqu6TumiKzowciRdGmSInv54zghAh0U9dYOLIwGrkhfqMfg0hczXg0sDiZcZNIWHmA3yedDcKvDrRB6bgq9qMg9PlcK11dehANg9Plcp8WydAPoGGxj2aTtJ(0fHhEySbTuNgaRf0TaANg9Plcp8WydAPonawtPYbXYvF6cANg9Plcp8WydAPonawJqbc2LmeDODA0NUi8WdJnOL60ayT8Ba75qzhijA8MGjI2obaC9XY553a2ZHYoqs04nbte5yPwpkG2PrF6IWdpm2GwQtdG1iLgs2AxsC1jq70OpDr4HhgBql1PbWAHTpDbTtJ(0fHhEySbTuNgaRrqui7azSVJk0NUSDcaqcX)LUE5Ot4eefYoqg77Oc9PlP2OPaYg0on6txeE4HXg0sDAaS2Msvo0on6txeE4HXg0sDAaSgztf9oPv)UTtaa7D9XY5Bkv5CSuRhf0jH4)sxVC0jCcIczhiJ9DuH(0LuB0KSbTdA3(bz0srlWiLJcidxHhqqMpGiK5BiKPrVpiBiqMUsNxTEKdTtJ(0fbaje)x(D0gODA0NUi0aynbUQPojOMprODA0NUi0ayTv6nQ1J2wkicGIGscIcBxPpfcW1hlNt6DsFdLeefeowQ1Jc6Kq8FPRxo6eobrHSdKX(oQqF6sQnAkGSrZPJqIRWY5tTI6l8uRh5uHzY46JLZjt4wxYFcqowQ1Jc6Kq8FPRxo6eobrHSdKX(oQqF6YuaRtZPJqIRWY5tTI6l8uRh5uHzYqcX)LUE5Ot4eefYoqg77Oc9PltbSV0C6iK4kSC(uRO(cp16rovi0on6txeAaS2k9g16rBlfebeQcXu522HaiOB7k9PqaA0NU4Knv07Kw97CKwGrkhL(aIaxPn8gh5rLevXu5YO(k44aXXsTEuaTtJ(0fHgaRTsVrTE02sbraHQqmvUTDiGdjOB7k9Pqa5rHTtaaL2WBCKhvsuftLlJ6RGJdehl16rbDZD9XY5ItNssAQNJLA9OitgxFSCUavFZQFNJLA9OGES7x07kUavFZQFNFiOofXea5rHzq70OpDrObWAR0BuRhTTuqeaOoLRtjjOTR0NcbqcX)LUE5Ot4eefYoqg77Oc9PlP2OjawqJRpwoF3n(gkNsQ5Dbehl16rbnU(y5C1I0pLJYyFhvOpDXXsTEuaCGrJ5U(y58D34BOCkPM3fqCSuRhf0D9XY5KEN03qjbrbHJLA9OGoje)x66LJoHtqui7azSVJk0NUKAJMcmZOXCxFSCozc36s(taYXsTEuq3ExFSCE8qmCQCPavFJJLA9OGU9U(y5CXPtjjn1ZXsTEuygnNocjUclNp1kQVWtTEKtfcTtJ(0fHgaRTsVrTE02sbraI2jsQqBxPpfcWC7D9XY5KjCRl5pbihl16rrMmI25KjCRl5pbiNk0m6I25AExaXjUgTXualYIU9I25AExaXpm4qYMA9iDr78yFhvOpDXPcH2PrF6IqdG1I6)sn6txYFiUTLcIaID)IExrG2PrF6IqdG1eNoLK0uVTt54DuHUm)Bl9bSW24MofGf2gbk(O01lhDcGf2obaC9YrN7dik9wkg0ea5rbDst9sYMEctwhANg9PlcnawBtPk32jaaje)x66LJoHtqui7azSVJk0NUKAJMaay0C6iK4kSC(uRO(cp16rovi0on6txeAaSgHceSlPqpBYF9qBNaaI25AExaX9jAZu50fTZJ9DuH(0f3NOntLt3ClQGaUg9zfkPucN4A0gaRNjdPPEjztpbGSmJU5276JLZd30YBqjzQCQxVXbIJLA9Oitgr78WnT8gusMkN61BCG4hcQtrmJU5276JLZfO6Bw97CSuRhfzYe7(f9UIlq13S635hcQtrmbqEuKjJ9XUFrVR4cu9nR(D(HG6uKmziH4)sxVC0jCcIczhiJ9DuH(0LuB00f0C6iK4kSC(uRO(cp16rovOzq70OpDrObWAcu9nR(DBNaaXUFrVR4ekqWUKc9Sj)1d5hcQtrOVsVrTEKlANiPcPtcX)LUE5Ot4eefYoqg77Oc9PlP2iGf0C6iK4kSC(uRO(cp16roviDZThjeSIiF1qMUKDGmeVam6txCWP6JU9kTH34ixCOkcOEzu)FQC(PLnzYe7(f9UItOab7sk0ZM8xpKFiOofX0SLLzq70OpDrObWA(gkPkRMQeYG(IOTtaalQGa(HrBEKqKb9fr(HG6ueODA0NUi0aynnVlGSncu8rPRxo6ealSDcaCiOofXea5rbnA0NU4Knv07Kw97CKwGrkhL(aI09beLElfdA6(cTtJ(0fHgaRbIG9bKSdKpvCesXHkiX2jaGpGOjzllODA0NUi0aynkckhhbTTuqeGsBKn9uImOlx2bYWEhE2obaID)IExXjuGGDjf6zt(RhYpeuNIyYISG2PrF6IqdG1OkIRwpk1GGFI(0LTrGIpkD9YrNayHTtaa7JD5A(0fDFarP3sXGMayFH2PrF6IqdG1eNoLK0uVTrGIpkD9YrNayHTrTI4lNaa(eTHipeuNYK1TDca46JLZjBQO3jrqRtJihl16rb9v6nQ1JCqDkxNssq6c0IkiGt2urVtIGwNgr(HG6ue6c0IkiGt2urVtIGwNgr(HG6uetaKhfahyq70OpDrObWAKnv07Kw972gbk(O01lhDcGf2obaC9XY5Knv07KiO1PrKJLA9OG(k9g16roOoLRtjjiDbArfeWjBQO3jrqRtJi)qqDkcDbArfeWjBQO3jrqRtJi)qqDkIjaqAbgPCu6dicCGrJF6k8L(aI0TxJ(0fNSPIEN0QFNpLm4N8nhANg9PlcnawlCtlVbLKPYPE9ghiBJafFu66LJobWcBNaa(aIMMT1P76LJo3hqu6TumOPlO9aNeI)l3uIJ0n3EKqWkI8vdz6s2bYq8cWOpDXbNQp62R0gEJJCXHQiG6Lr9)PY5Nw2KjtS7x07koHceSlPqpBYF9q(HG6uet3N1ZKj29l6DfNqbc2LuONn5VEi)qqDkIjlwh4Kq8F5MsC0mODA0NUi0aynQI4Q1Jsni4NOpDzBeO4JsxVC0jawy7eaW(v6nQ1JCkckjikOtAQxs20tayDODA0NUi0ayncIczhiJ9DuH(0LTtaGv6nQ1JCkckjikOtAQxs20tayDODA0NUi0ayTO(VuJ(0L8hIBBPGiar7eODA0NUi0ayTvZJsxNYTncu8rPRxo6ealSDca4diA6I1P76LJo3hqu6TumOPawKfDZJD)IExXjuGGDjf6zt(RhYpeuNIyA2YktMy3VO3vCcfiyxsHE2K)6H8db1PiMSil6I25AExaXpeuNIykGfzrx0op23rf6tx8db1PiMcyrw0nx0oNmHBDj)ja5hcQtrmfWISYKXExFSCozc36s(taYXsTEuyMzq70OpDrObWAueuoocABPGiaL2iB6PezqxUSdKH9o8SDca4diAcGSbTtJ(0fHgaRfUPL3GsYu5uVEJdKTtaaFartaKT1H2PrF6IqdG1wnpkDDk32jaGpGOjlwhANg9PlcnawlNspXOLSdKkTHx7B2obaID)IExXjuGGDjf6zt(RhYpeuNIyYI1PBUODE4MwEdkjtLt96noq8db1PizYiANVAEu66uo)qqDksMm276JLZd30YBqjzQCQxVXbIJLA9OGU9U(y58vZJsxNY5yPwpkmltgFarP3sXGMKTSOjpkG2PrF6IqdG1e6zJK0uVTtaGy3VO3vCcfiyxsHE2K)6H8db1PiMSil6MlANhUPL3GsYu5uVEJde)qqDksMmI25RMhLUoLZpeuNIKjJ9U(y58WnT8gusMkN61BCG4yPwpkOBVRpwoF18O01PCowQ1JcZYKXhqu6TumOjallAYJImziH4)sxVC0jCcIczhiJ9DuH(0LuB00f0C6iK4kSC(uRO(cp16rovi0on6txeAaSMfEe8SzQCODA0NUi0ayTO(VuJ(0L8hIBBPGiasiwc8iq70OpDrObWAr9FPg9Pl5pe32sbrabZ)4rG2bTtJ(0fHh7(f9UIaGIGYXrqBlfebO0gztpLid6YLDGmS3HNTtaaZT31hlNhUPL3GsYu5uVEJdehl16rrMmXUFrVR4HBA5nOKmvo1R34aXpeuNIyY(aCsi(VCtjoMjJ9XUFrVR4HBA5nOKmvo1R34aXpeuNIyg9y3VO3vCcfiyxsHE2K)6H8db1PiMSyDGtcX)LBkXrODA0NUi8y3VO3veAaSwy7tx2obam31hlNl0ZgjPPEj4qWdiowQ1Jc6XUFrVR4ekqWUKc9Sj)1d5uH0JD)IExXf6zJK0upNk0SmzID)IExXjuGGDjf6zt(RhYPcZKXhqu6TumOjzllODA0NUi8y3VO3veAaSgfbLJJGeBNaaXUFrVR4ekqWUKc9Sj)1d5hcQtrmD)ZktgFarP3sXGMaSSYKXCZTOcc4A0NvOKsjCIRrBaSEMmKM6LKn9eaYYm6MBVRpwopCtlVbLKPYPE9ghiowQ1JImzID)IExXd30YBqjzQCQxVXbIFiOofXm6MBVRpwoxGQVz1VZXsTEuKjtS7x07kUavFZQFNFiOofXea5rrMm2h7(f9UIlq13S635hcQtrmJU9XUFrVR4ekqWUKc9Sj)1d5hcQtrmdANg9Plcp29l6DfHgaRrrq54iOTLcIac7OnOtgAdfYydgs5QpDjf4QjI2obaID)IExXjuGGDjf6zt(RhYpeuNIykaGToDZJD)IExXfO6Bw978db1PizYyVRpwoxGQVz1VZXsTEuyg0on6txeES7x07kcnawlyo067wy7eaW(y3VO3vCcfiyxsHE2K)6HCQqODA0NUi8y3VO3veAaSM13TqgqDaz7eaW(y3VO3vCcfiyxsHE2K)6HCQqODA0NUi8y3VO3veAaSgic2hqYoq(uXrifhQGeBNaa(aIMMTSG2PrF6IWJD)IExrObWAwF3czhi9nuIfccKTtaGq05c9Sj)1d5hcQtrYKXC7JD)IExXfO6Bw978db1PizYyVRpwoxGQVz1VZXsTEuyg9y3VO3vCcfiyxsHE2K)6H8db1PiMcyFZIosiyfrU13Tq2bsFdLyHGaXpTSX0fq70OpDr4XUFrVRi0ayTD99Iv4uYdjDPveTDcayrfeW)jaT(UfCIRrBmjBq70OpDr4XUFrVRi0ayTBcdFuoLKeQreAh0on6txeUWsEyWHKnaKjCRl5pbOT)uOmkaSyDBNaaMlANtMWTUK)eG8db1PizVODozc36s(taYfuN6txMzcaZfTZ18UaIFiOofj7fTZ18UaIlOo1NUmJU5I25KjCRl5pbi)qqDks2lANtMWTUK)eGCb1P(0LzMaWCr78yFhvOpDXpeuNIK9I25X(oQqF6IlOo1NUmJUODozc36s(taYpeuNIyIODozc36s(taYfuN6txaFbpBq70OpDr4cl5Hbhs2ObWAAExaz7pfkJcalw32jaG5I25AExaXpeuNIK9I25AExaXfuN6txMzcaZfTZJ9DuH(0f)qqDks2lANh77Oc9PlUG6uF6Ym6MlANR5Dbe)qqDks2lANR5DbexqDQpDzMjamx0oNmHBDj)ja5hcQtrYEr7CYeU1L8NaKlOo1NUmJUODUM3fq8db1PiMiANR5DbexqDQpDb8f8SbTtJ(0fHlSKhgCizJgaRf77Oc9PlB)PqzuayX62obamx0op23rf6tx8db1PizVODESVJk0NU4cQt9PlZmbG5I25AExaXpeuNIK9I25AExaXfuN6txMr3Cr78yFhvOpDXpeuNIK9I25X(oQqF6IlOo1NUmZeaMlANtMWTUK)eG8db1PizVODozc36s(taYfuN6txMrx0op23rf6tx8db1PiMiANh77Oc9PlUG6uF6c4l4zdAh0on6txeUODcacIczhiJ9DuH(0LTtaar78yFhvOpDXpeuNIycan6txCcIczhiJ9DuH(0fpQex6disJpGO0Bjztpbn7dhya38f0QRpwopEigovUuGQVXXsTEua8S4lw3m6Kq8FPRxo6eobrHSdKX(oQqF6sQnAkGSrZPJqIRWY5tTI6l8uRh5uH046JLZ3DJVHYPKAExaXXsTEuq3Er7CcIczhiJ9DuH(0f)qqDkcD71OpDXjikKDGm23rf6tx8PKb)KV5q70OpDr4I2j0aynnVlGSncu8rPRxo6ealSDca46JLZJhIHtLlfO6BCSuRhf01OpRqPODUM3fqMq7P76LJo3hqu6TumOPlYIU5hcQtrmbqEuKjtS7x07koHceSlPqpBYF9q(HG6uetxKfDZpeuNIyY6zYyVsB4noYd1sGGtuo1QoQ(0f)0Yg6hgCiztTE0mZG2PrF6IWfTtObWAAExazBeO4JsxVC0jawy7eaWExFSCE8qmCQCPavFJJLA9OGUg9zfkfTZ18UaYK9LURxo6CFarP3sXGMUil6MFiOofXea5rrMmXUFrVR4ekqWUKc9Sj)1d5hcQtrmDrw0n)qqDkIjRNjJ9kTH34ipulbcor5uR6O6tx8tlBOFyWHKn16rZmdANg9Plcx0oHgaRrMWTUK)eG2gbk(O01lhDcGf2obamxJ(ScLI25KjCRl5pbOj7lT66JLZJhIHtLlfO6BCSuRhf0kje)x66LJoHt6DsFdLeefeP2Oz0D9YrN7dik9wkg00fzr)WGdjBQ1J0n3(db1Pi0jH4)sxVC0jCcIczhiJ9DuH(0LuBeWImzID)IExXjuGGDjf6zt(RhYpeuNIykPPEjztpbW1OpDXPkIRwpk1GGFI(0fhPfyKYrPpGOzq70OpDr4I2j0ayTyFhvOpDzBeO4JsxVC0jawy7eaGeI)lD9YrNWjikKDGm23rf6txsTrtYgnNocjUclNp1kQVWtTEKtfsJRpwoF3n(gkNsQ5Dbehl16rbDZpeuNIycG8OitMy3VO3vCcfiyxsHE2K)6H8db1PiMUil6hgCiztTE0m6UE5OZ9beLElfdA6ISG2bTtJ(0fHhm)JhbavrC16rPge8t0NUS9NcLrbGfRB7eai29l6DfxGQVz1VZpeuNIycG8Oa4aJoje)x66LJoHtqui7azSVJk0NUKAJawqZPJqIRWY5tTI6l8uRh5uH0JD)IExXjuGGDjf6zt(RhYpeuNIykWYcANg9Plcpy(hpcnawlQ)l1OpDj)H42wkicqyjpm4qYMTtaaxFSCUavFZQFNJLA9OGoje)x66LJoHtqui7azSVJk0NUKAJawqZPJqIRWY5tTI6l8uRh5uH0nx0oxZ7ci(HG6ueteTZ18UaIlOo1NUaEw89F9mzeTZJ9DuH(0f)qqDkIjI25X(oQqF6IlOo1NUaEw89F9mzeTZjt4wxYFcq(HG6ueteTZjt4wxYFcqUG6uF6c4zX3)1nJES7x07kUavFZQFNFiOofXeaA0NU4AExaXZJcGVp0JD)IExXjuGGDjf6zt(RhYpeuNIykWYcANg9Plcpy(hpcnawlQ)l1OpDj)H42wkicqyjpm4qYMTtaaxFSCUavFZQFNJLA9OGoje)x66LJoHtqui7azSVJk0NUKAJawqZPJqIRWY5tTI6l8uRh5uH0JD)IExXjuGGDjf6zt(RhYpeuNIycast9sYMEcGRrF6IR5DbeppkOrJ(0fxZ7ciEEua8Sr3Cr7CnVlG4hcQtrmr0oxZ7ciUG6uF6c4lYKr0op23rf6tx8db1PiMiANh77Oc9PlUG6uF6c4lYKr0oNmHBDj)ja5hcQtrmr0oNmHBDj)ja5cQt9PlGVWmODA0NUi8G5F8i0aynbQ(Mv)UTtaGy3VO3vCcfiyxsHE2K)6H8db1PiMciBzrtEuKjtS7x07koHceSlPqpBYF9q(HG6uetxSpzbTtJ(0fHhm)JhHgaRr2urVtA1VB7eaWIkiGd2RqqSCoviDlQGaEn5BEG(p)qqDkc0on6txeEW8pEeAaSMM3fq2obaSOcc4G9keelNtfs3EZD9XY5KjCRl5pbihl16rbDZdpCLmpk4l4AExarp8WvY8OGdmUM3fq0dpCLmpk4zJR5DbKzzYeE4kzEuWxW18UaYmODA0NUi8G5F8i0aynYeU1L8Na02jaGfvqahSxHGy5CQq62BE4HRK5rbFbNmHBDj)jaPhE4kzEuWbgNmHBDj)jaPhE4kzEuWZgNmHBDj)jandANg9Plcpy(hpcnawl23rf6tx2obaSOcc4G9keelNtfs3(WdxjZJc(cESVJk0NUOBVRpwoxTi9t5Om23rf6txCSuRhfq70OpDr4bZ)4rObWAItNs(taA7eaWIkiGpfUAC16rPabhcYjUgTX0fzr31lhDUpGO0BPyqtaSilODA0NUi8G5F8i0aynXPtj)jaTDca46JLZjt4wxYFcqowQ1Jc6wubb8PWvJRwpkfi4qqoX1OnMcy9SOvGLfWnNeI)lD9YrNWjikKDGm23rf6txsTrA90riXvy58Pwr9fEQ1JCQqtbamZOlANR5Dbe)qqDkIPRdCsi(VCtjosx0op23rf6tx8db1PiMMhf0nx0oNmHBDj)ja5hcQtrmnpkYKXExFSCozc36s(taYXsTEuygDZfOfvqaFtPkNFiOofX01boje)xUPehZKXExFSC(Msvohl16rHz0JD5A(0LPRdCsi(VCtjocTtJ(0fHhm)JhHgaRjoDk5pbOTtaaxFSC(UB8nuoLuZ7ciowQ1Jc6wubb8PWvJRwpkfi4qqoX1OnMcy9SOvGLfWnNeI)lD9YrNWjikKDGm23rf6txsTrA90riXvy58Pwr9fEQ1JCQqtbKnZO11bU5Kq8FPRxo6eobrHSdKX(oQqF6sQnsRNocjUclNp1kQVWtTEKtfcayMrx0oxZ7ci(HG6uetxh4Kq8F5MsCKUODESVJk0NU4hcQtrmnpkOBUaTOcc4Bkv58db1PiMUoWjH4)YnL4yMm276JLZ3uQY5yPwpkmJESlxZNUmDDGtcX)LBkXrODA0NUi8G5F8i0aynXPtj)jaTDca46JLZvls)uokJ9DuH(0fhl16rbDlQGa(u4QXvRhLceCiiN4A0gtbSEw0kWYc4MtcX)LUE5Ot4eefYoqg77Oc9PlP2iTE6iK4kSC(uRO(cp16rovOPa2hZOlANR5Dbe)qqDkIPRdCsi(VCtjos3CbArfeW3uQY5hcQtrmDDGtcX)LBkXXmzS31hlNVPuLZXsTEuyg9yxUMpDz66aNeI)l3uIJq70OpDr4bZ)4rObWABkv5q70OpDr4bZ)4rObWAbDKIGcPsB4nokTqfeANg9Plcpy(hpcnawlK6MaGMkxA9kXH2PrF6IWdM)XJqdG1IDfXYp1rHm4vq02jaG9I25XUIy5N6Oqg8kikTOUIFiOofHU9A0NU4XUIy5N6Oqg8kiYNsg8t(MdTtJ(0fHhm)JhHgaRjoDkjPPEBNYX7OcDz(3w6dyHTXnDkalSDkhVJk0bSW2iqXhLUE5OtaSW2jaGRxo6CFarP3sXGMaipkG2PrF6IWdM)XJqdG1eNoLK0uVTrGIpkD9YrNayHTXnDkalSDkhVJk0LtaaFI2qKhcQtzY62oLJ3rf6Y8VT0hWcBNaaU(y5CYMk6Dse060iYXsTEuqFLEJA9ihuNY1PKeKU9c0IkiGt2urVtIGwNgr(HG6ueODA0NUi8G5F8i0aynXPtjjn1BBeO4JsxVC0jawyBCtNcWcBNYX7OcD5eaWNOne5HG6uMSUTt54DuHUm)Bl9bSW2jaGRpwoNSPIENebTonICSuRhf0xP3OwpYb1PCDkjbH2PrF6IWdM)XJqdG1eNoLK0uVTt54DuHUm)Bl9bSW24MofGf2oLJ3rf6awaTtJ(0fHhm)JhHgaRr2urVtA1VBBeO4JsxVC0jawy7eaW1hlNt2urVtIGwNgrowQ1Jc6R0BuRh5G6uUoLKG0TxGwubbCYMk6Dse060iYpeuNIq3En6txCYMk6DsR(D(uYGFY3CODA0NUi8G5F8i0aynYMk6DsR(DBJafFu66LJobWcBNaaU(y5CYMk6Dse060iYXsTEuqFLEJA9ihuNY1PKeeANg9Plcpy(hpcnawJSPIEN0QFhAh0on6txeojelbEeaufXvRhLAqWprF6Y2jaqS7x07koHceSlPqpBYF9q(HG6uetaqAQxs20taCZrAbgPCu6disJsB4noYfhQIaQxg1)NkNFAzJz0n3ExFSCUavFZQFNJLA9OitMy3VO3vCbQ(Mv)o)qqDkIjain1ljB6jaoslWiLJsFarZG2PrF6IWjHyjWJqdG1I6)sn6txYFiUTLcIacM)XJy7eaW8y3VO3vCcfiyxsHE2K)6H8db1PiM4dik9ws20taCZP90kPPEjztpHzzYe7(f9UItOab7sk0ZM8xpKtfAgDFarP3sXGMg7(f9UItOab7sk0ZM8xpKFiOofbANg9PlcNeILapcnawJGOq2bYyFhvOpDz7eayLEJA9iNIGscIcODA0NUiCsiwc8i0aynQI4Q1Jsni4NOpDz7eaW(v6nQ1JCkckjikOBF4HRK5rbFbNqbc2LuONn5VEiDZD9XY5cu9nR(DowQ1Jc6XUFrVR4cu9nR(D(HG6uetaG0cms5O0hqKU9kTH34ipQKOkMkxg1xbhhiowQ1JImzmN0uVKSPNWuaRtNeI)lD9YrNWjikKDGm23rf6txsTrtawMmKM6LKn9eMcay0jH4)sxVC0jCcIczhiJ9DuH(0LuB0uaaZm6UE5OZ9beLElfdA6(qdslWiLJsFar6Kq8FPRxo6eobrHSdKX(oQqF6sQncyrMmUE5OZ9beLElfdAcG9LgKwGrkhL(aIaN0uVKSPNWmODA0NUiCsiwc8i0aynQI4Q1Jsni4NOpDz7eaW(v6nQ1JCkckjikOh7Y18PltaevIl9bePzLEJA9ipufIPYH2PrF6IWjHyjWJqdG1OkIRwpk1GGFI(0LTrGIpkD9YrNayHTtaa7xP3OwpYPiOKGOGU5276JLZfO6Bw97CSuRhfzYe7(f9UIlq13S635hcQtrm1hqu6TKSPNitgst9sYMEctxygDZT31hlNVAEu66uohl16rrMmKM6LKn9eMUWm6XUCnF6YearL4sFarAwP3OwpYdvHyQC6MBVsB4noYJkjQIPYLr9vWXbIJLA9OitglQGaEujrvmvUmQVcooq8db1PiM6dik9ws20tywYyfEKPR0salRfz3S2)SYU8f7FYyNE1u5KKbTmGH95OaY2FitJ(0fK9dXjCODjdLY36lzymG0ssg)qCsA5KHWsEyWHKT0YPLwKwozGLA9OiTxYqJ(0vYGmHBDj)jatgXBC8gnzyoKjANtMWTUK)eG8db1Piqw2dzI25KjCRl5pbixqDQpDbzMbzMaaYmhYeTZ18UaIFiOofbYYEit0oxZ7ciUG6uF6cYmdYOdzMdzI25KjCRl5pbi)qqDkcKL9qMODozc36s(taYfuN6txqMzqMjaGmZHmr78yFhvOpDXpeuNIazzpKjANh77Oc9PlUG6uF6cYmdYOdzI25KjCRl5pbi)qqDkcKzcKjANtMWTUK)eGCb1P(0fKbCiBbpBjJFkugfjJfRN80salTCYal16rrAVKHg9PRKHM3fqjJ4noEJMmmhYeTZ18UaIFiOofbYYEit0oxZ7ciUG6uF6cYmdYmbaKzoKjANh77Oc9Pl(HG6ueil7Hmr78yFhvOpDXfuN6txqMzqgDiZCit0oxZ7ci(HG6ueil7Hmr7CnVlG4cQt9PliZmiZeaqM5qMODozc36s(taYpeuNIazzpKjANtMWTUK)eGCb1P(0fKzgKrhYeTZ18UaIFiOofbYmbYeTZ18UaIlOo1NUGmGdzl4zlz8tHYOizSy9KNwkBPLtgyPwpks7Lm0OpDLmI9DuH(0vYiEJJ3OjdZHmr78yFhvOpDXpeuNIazzpKjANh77Oc9PlUG6uF6cYmdYmbaKzoKjANR5Dbe)qqDkcKL9qMODUM3fqCb1P(0fKzgKrhYmhYeTZJ9DuH(0f)qqDkcKL9qMODESVJk0NU4cQt9PliZmiZeaqM5qMODozc36s(taYpeuNIazzpKjANtMWTUK)eGCb1P(0fKzgKrhYeTZJ9DuH(0f)qqDkcKzcKjANh77Oc9PlUG6uF6cYaoKTGNTKXpfkJIKXI1tEYtgcmqPEpTCAPfPLtgA0NUsgKq8F53rBsgyPwpks7L80salTCYqJ(0vYqGRAQtcQ5tmzGLA9OiTxYtlLT0YjdSuRhfP9sgDyYGGEYqJ(0vYyLEJA9yYyL(uyYW1hlNt6DsFdLeefeowQ1JciJoKrcX)LUE5Ot4eefYoqg77Oc9PlP2iKzkailBqgnq2PJqIRWY5tTI6l8uRh5uHqwMmqMRpwoNmHBDj)ja5yPwpkGm6qgje)x66LJoHtqui7azSVJk0NUGmtbazRdz0azNocjUclNp1kQVWtTEKtfczzYazKq8FPRxo6eobrHSdKX(oQqF6cYmfaKTVqgnq2PJqIRWY5tTI6l8uRh5uHjJv6jlfetgueusquK80s7tA5KbwQ1JI0EjJomzqqpzOrF6kzSsVrTEmzSsFkmzOrF6It2urVtA1VZrAbgPCu6diczahYuAdVXrEujrvmvUmQVcooqCSuRhfjJv6jlfetgHQqmvEYtlTEA5KbwQ1JI0EjJomzCib9KHg9PRKXk9g16XKXk9PWKrEuKmI344nAYqPn8gh5rLevXu5YO(k44aXXsTEuaz0HmZHmxFSCU40PKKM65yPwpkGSmzGmxFSCUavFZQFNJLA9OaYOdzXUFrVR4cu9nR(D(HG6ueiZeaqwEuazMLmwPNSuqmzeQcXu5jpTeTpTCYal16rrAVKrhMmiONm0OpDLmwP3OwpMmwPpfMmiH4)sxVC0jCcIczhiJ9DuH(0LuBeYmbaKTaYObYC9XY57UX3q5usnVlG4yPwpkGmAGmxFSCUAr6NYrzSVJk0NU4yPwpkGmGdzadYObYmhYC9XY57UX3q5usnVlG4yPwpkGm6qMRpwoN07K(gkjikiCSuRhfqgDiJeI)lD9YrNWjikKDGm23rf6txsTriZuidyqMzqgnqM5qMRpwoNmHBDj)ja5yPwpkGm6qM9qMRpwopEigovUuGQVXXsTEuaz0Hm7HmxFSCU40PKKM65yPwpkGmZGmAGSthHexHLZNAf1x4PwpYPctgR0twkiMma1PCDkjbtEAP9pTCYal16rrAVKrhMmiONm0OpDLmwP3OwpMmwPpfMmmhYShYC9XY5KjCRl5pbihl16rbKLjdKjANtMWTUK)eGCQqiZmiJoKjANR5DbeN4A0giZuaq2ISGm6qM9qMODUM3fq8ddoKSPwpcz0Hmr78yFhvOpDXPctgR0twkiMmeTtKuHjpT0(MwozGLA9OiTxYqJ(0vYiQ)l1OpDj)H4jJFiUSuqmze7(f9UIK80sz30YjdSuRhfP9sgA0NUsgItNssAQpzebk(O01lhDsAPfjJ4noEJMmC9YrN7dik9wkgeYmbaKLhfqgDiJ0uVKSPNaYmbYwpze30Psglsgt54DuHUm)Bl9tglsEAPfzLwozGLA9OiTxYiEJJ3Ojdsi(V01lhDcNGOq2bYyFhvOpDj1gHmtaazadYObYoDesCfwoFQvuFHNA9iNkmzOrF6kzSPuLN80slwKwozGLA9OiTxYiEJJ3Ojdr7CnVlG4(eTzQCiJoKjANh77Oc9PlUprBMkhYOdzMdzwubbCn6ZkusPeoX1OnqgaiBDiltgiJ0uVKSPNaYaazzbzMbz0HmZHm7HmxFSCE4MwEdkjtLt96noqCSuRhfqwMmqMODE4MwEdkjtLt96noq8db1PiqMzqgDiZCiZEiZ1hlNlq13S635yPwpkGSmzGSy3VO3vCbQ(Mv)o)qqDkcKzcailpkGSmzGm7HSy3VO3vCbQ(Mv)o)qqDkcKLjdKrcX)LUE5Ot4eefYoqg77Oc9PlP2iKzkKTaYObYoDesCfwoFQvuFHNA9iNkeYmlzOrF6kzqOab7sk0ZM8xpm5PLwaS0YjdSuRhfP9sgXBC8gnze7(f9UItOab7sk0ZM8xpKFiOofbYOdzR0BuRh5I2jsQqiJoKrcX)LUE5Ot4eefYoqg77Oc9PlP2iKbaYwaz0azNocjUclNp1kQVWtTEKtfcz0HmZHm7HmKqWkI8vdz6s2bYq8cWOpDXbNQpiJoKzpKP0gEJJCXHQiG6Lr9)PY5Nw2azzYazXUFrVR4ekqWUKc9Sj)1d5hcQtrGmtHSSLfKzwYqJ(0vYqGQVz1VN80slYwA5KbwQ1JI0EjJ4noEJMmSOcc4hgT5rcrg0xe5hcQtrsgA0NUsg(gkPkRMQeYG(IyYtlTyFslNmWsTEuK2lzOrF6kzO5DbuYiEJJ3OjJdb1PiqMjaGS8OaYObY0OpDXjBQO3jT635iTaJuok9beHm6qMpGO0BPyqiZuiBFtgrGIpkD9YrNKwArYtlTy90YjdSuRhfP9sgXBC8gnz4diczMazzlRKHg9PRKbic2hqYoq(uXrifhQGKKNwAbTpTCYal16rrAVKHg9PRKHsBKn9uImOlx2bYWEhEjJ4noEJMmID)IExXjuGGDjf6zt(RhYpeuNIazMazlYkzukiMmuAJSPNsKbD5Yoqg27Wl5PLwS)PLtgyPwpks7Lm0OpDLmOkIRwpk1GGFI(0vYiEJJ3Ojd7HSyxUMpDbz0HmFarP3sXGqMjaGS9nzebk(O01lhDsAPfjpT0I9nTCYal16rrAVKHg9PRKH40PKKM6tgrGIpkD9YrNKwArYiQveF5eKm8jAdrEiOoLjRNmI344nAYW1hlNt2urVtIGwNgrowQ1JciJoKTsVrTEKdQt56usccz0HmbArfeWjBQO3jrqRtJi)qqDkcKrhYeOfvqaNSPIENebTonI8db1PiqMjaGS8OaYaoKbSKNwAr2nTCYal16rrAVKHg9PRKbztf9oPv)EYiEJJ3OjdxFSCoztf9ojcADAe5yPwpkGm6q2k9g16roOoLRtjjiKrhYeOfvqaNSPIENebTonI8db1PiqgDitGwubbCYMk6Dse060iYpeuNIazMaaYqAbgPCu6diczahYagKrdK5NUcFPpGiKrhYShY0OpDXjBQO3jT635tjd(jFZtgrGIpkD9YrNKwArYtlbSSslNmWsTEuK2lzOrF6kzeUPL3GsYu5uVEJduYiEJJ3OjdFariZuilBRdz0HmxVC05(aIsVLIbHmtHSf0Eid4qgje)xUPehHm6qM5qM9qgsiyfr(QHmDj7aziEby0NU4Gt1hKrhYShYuAdVXrU4qveq9YO()u58tlBGSmzGSy3VO3vCcfiyxsHE2K)6H8db1PiqMPq2(SoKLjdKf7(f9UItOab7sk0ZM8xpKFiOofbYmbYwSoKbCiJeI)l3uIJqMzjJiqXhLUE5OtslTi5PLa2I0YjdSuRhfP9sgA0NUsgufXvRhLAqWprF6kzeVXXB0KH9q2k9g16rofbLeefqgDiJ0uVKSPNaYaazRNmIafFu66LJojT0IKNwcyalTCYal16rrAVKr8ghVrtgR0BuRh5ueusquaz0Hmst9sYMEcidaKTEYqJ(0vYGGOq2bYyFhvOpDL80salBPLtgyPwpks7Lm0OpDLmI6)sn6txYFiEY4hIllfetgI2jjpTeW2N0YjdSuRhfP9sgA0NUsgRMhLUoLNmI344nAYWhqeYmfYwSoKrhYC9YrN7dik9wkgeYmfaKTiliJoKzoKf7(f9UItOab7sk0ZM8xpKFiOofbYmfYYwwqwMmqwS7x07koHceSlPqpBYF9q(HG6ueiZeiBrwqgDit0oxZ7ci(HG6ueiZuaq2ISGm6qMODESVJk0NU4hcQtrGmtbazlYcYOdzMdzI25KjCRl5pbi)qqDkcKzkaiBrwqwMmqM9qMRpwoNmHBDj)ja5yPwpkGmZGmZsgrGIpkD9YrNKwArYtlbS1tlNmWsTEuK2lzOrF6kzO0gztpLid6YLDGmS3HxYiEJJ3OjdFariZeaqw2sgLcIjdL2iB6PezqxUSdKH9o8sEAjGr7tlNmWsTEuK2lzeVXXB0KHpGiKzcailBRNm0OpDLmc30YBqjzQCQxVXbk5PLa2(NwozGLA9OiTxYiEJJ3OjdFariZeiBX6jdn6txjJvZJsxNYtEAjGTVPLtgyPwpks7LmI344nAYi29l6DfNqbc2LuONn5VEi)qqDkcKzcKTyDiJoKzoKjANhUPL3GsYu5uVEJde)qqDkcKLjdKjANVAEu66uo)qqDkcKLjdKzpK56JLZd30YBqjzQCQxVXbIJLA9OaYOdz2dzU(y58vZJsxNY5yPwpkGmZGSmzGmFarP3sXGqMjqw2YcYObYYJIKHg9PRKroLEIrlzhivAdV23sEAjGLDtlNmWsTEuK2lzeVXXB0KrS7x07koHceSlPqpBYF9q(HG6ueiZeiBrwqgDiZCit0opCtlVbLKPYPE9ghi(HG6ueiltgit0oF18O01PC(HG6ueiltgiZEiZ1hlNhUPL3GsYu5uVEJdehl16rbKrhYShYC9XY5RMhLUoLZXsTEuazMbzzYaz(aIsVLIbHmtGmGLfKrdKLhfqwMmqgje)x66LJoHtqui7azSVJk0NUKAJqMPq2ciJgi70riXvy58Pwr9fEQ1JCQWKHg9PRKHqpBKKM6tEAPSLvA5KHg9PRKHfEe8SzQ8KbwQ1JI0EjpTu2wKwozGLA9OiTxYqJ(0vYiQ)l1OpDj)H4jJFiUSuqmzqcXsGhj5PLYgWslNmWsTEuK2lzOrF6kze1)LA0NUK)q8KXpexwkiMmcM)XJK8KNmcpm2GwQNwoT0I0YjdSuRhfP9sEAjGLwozGLA9OiTxYtlLT0YjdSuRhfP9sEAP9jTCYqJ(0vYGqbc2Lma)nQYXlzGLA9OiTxYtlTEA5KbwQ1JI0EjJ4noEJMmC9XY553a2ZHYoqs04nbte5yPwpksgA0NUsg53a2ZHYoqs04nbtetEAjAFA5KbwQ1JI0EjpT0(NwozOrF6kze2(0vYal16rrAVKNwAFtlNmWsTEuK2lzeVXXB0Kbje)x66LJoHtqui7azSVJk0NUKAJqMPaGSSLm0OpDLmiikKDGm23rf6txjpTu2nTCYqJ(0vYytPkpzGLA9OiTxYtlTiR0YjdSuRhfP9sgXBC8gnzypK56JLZ3uQY5yPwpkGm6qgje)x66LJoHtqui7azSVJk0NUKAJqMjqw2sgA0NUsgKnv07Kw97jp5jJy3VO3vK0YPLwKwozGLA9OiTxYqJ(0vYqPnYMEkrg0Ll7azyVdVKr8ghVrtgMdz2dzU(y58WnT8gusMkN61BCG4yPwpkGSmzGSy3VO3v8WnT8gusMkN61BCG4hcQtrGmtGS9bYaoKrcX)LBkXriltgiZEil29l6DfpCtlVbLKPYPE9ghi(HG6ueiZmiJoKf7(f9UItOab7sk0ZM8xpKFiOofbYmbYwSoKbCiJeI)l3uIJjJsbXKHsBKn9uImOlx2bYWEhEjpTeWslNmWsTEuK2lzeVXXB0KH5qMRpwoxONnsst9sWHGhqCSuRhfqgDil29l6DfNqbc2LuONn5VEiNkeYOdzXUFrVR4c9SrsAQNtfczMbzzYazXUFrVR4ekqWUKc9Sj)1d5uHqwMmqMpGO0BPyqiZeilBzLm0OpDLmcBF6k5PLYwA5KbwQ1JI0EjJ4noEJMmID)IExXjuGGDjf6zt(RhYpeuNIazMcz7FwqwMmqMpGO0BPyqiZeidyzbzzYazMdzMdzwubbCn6ZkusPeoX1OnqgaiBDiltgiJ0uVKSPNaYaazzbzMbz0HmZHm7HmxFSCE4MwEdkjtLt96noqCSuRhfqwMmqwS7x07kE4MwEdkjtLt96noq8db1PiqMzqgDiZCiZEiZ1hlNlq13S635yPwpkGSmzGSy3VO3vCbQ(Mv)o)qqDkcKzcailpkGSmzGm7HSy3VO3vCbQ(Mv)o)qqDkcKzgKrhYShYID)IExXjuGGDjf6zt(RhYpeuNIazMLm0OpDLmOiOCCeKK80s7tA5KbwQ1JI0Ejdn6txjJWoAd6KH2qHm2GHuU6txsbUAIyYiEJJ3OjJy3VO3vCcfiyxsHE2K)6H8db1PiqMPaGmGToKrhYmhYID)IExXfO6Bw978db1PiqwMmqM9qMRpwoxGQVz1VZXsTEuazMLmkfetgHD0g0jdTHczSbdPC1NUKcC1eXKNwA90YjdSuRhfP9sgXBC8gnzypKf7(f9UItOab7sk0ZM8xpKtfMm0OpDLmcMdT(UfjpTeTpTCYal16rrAVKr8ghVrtg2dzXUFrVR4ekqWUKc9Sj)1d5uHjdn6txjdRVBHmG6ak5PL2)0YjdSuRhfP9sgXBC8gnz4diczMczzlRKHg9PRKbic2hqYoq(uXrifhQGKKNwAFtlNmWsTEuK2lzeVXXB0Kri6CHE2K)6H8db1PiqwMmqM5qM9qwS7x07kUavFZQFNFiOofbYYKbYShYC9XY5cu9nR(DowQ1JciZmiJoKf7(f9UItOab7sk0ZM8xpKFiOofbYmfaKTVzbz0HmKqWkICRVBHSdK(gkXcbbIFAzdKzkKTizOrF6kzy9DlKDG03qjwiiqjpTu2nTCYal16rrAVKr8ghVrtgwubb8FcqRVBbN4A0giZeilBjdn6txjJD99Iv4uYdjDPvetEAPfzLwozOrF6kzCty4JYPKKqnIjdSuRhfP9sEYtgI2jPLtlTiTCYal16rrAVKr8ghVrtgI25X(oQqF6IFiOofbYmbaKPrF6Itqui7azSVJk0NU4rL4sFariJgiZhqu6TKSPNaYObY2hoWGmGdzMdzlGmAfYC9XY5XdXWPYLcu9nowQ1Jcid4qww8fRdzMbz0Hmsi(V01lhDcNGOq2bYyFhvOpDj1gHmtbazzdYObYoDesCfwoFQvuFHNA9iNkeYObYC9XY57UX3q5usnVlG4yPwpkGm6qM9qMODobrHSdKX(oQqF6IFiOofbYOdz2dzA0NU4eefYoqg77Oc9Pl(uYGFY38KHg9PRKbbrHSdKX(oQqF6k5PLawA5KbwQ1JI0Ejdn6txjdnVlGsgXBC8gnz46JLZJhIHtLlfO6BCSuRhfqgDitJ(ScLI25AExabzMaz0EiJoK56LJo3hqu6TumiKzkKTiliJoKzoKDiOofbYmbaKLhfqwMmqwS7x07koHceSlPqpBYF9q(HG6ueiZuiBrwqgDiZCi7qqDkcKzcKToKLjdKzpKP0gEJJ8qTei4eLtTQJQpDXpTSbYOdzhgCiztTEeYmdYmlzebk(O01lhDsAPfjpTu2slNmWsTEuK2lzOrF6kzO5DbuYiEJJ3Ojd7HmxFSCE8qmCQCPavFJJLA9OaYOdzA0NvOu0oxZ7ciiZeiBFHm6qMRxo6CFarP3sXGqMPq2ISGm6qM5q2HG6ueiZeaqwEuazzYazXUFrVR4ekqWUKc9Sj)1d5hcQtrGmtHSfzbz0HmZHSdb1PiqMjq26qwMmqM9qMsB4noYd1sGGtuo1QoQ(0f)0YgiJoKDyWHKn16riZmiZSKreO4JsxVC0jPLwK80s7tA5KbwQ1JI0Ejdn6txjdYeU1L8NamzeVXXB0KH5qMg9zfkfTZjt4wxYFcqiZeiBFHmAfYC9XY5XdXWPYLcu9nowQ1JciJwHmsi(V01lhDcN07K(gkjikisTriZmiJoK56LJo3hqu6TumiKzkKTiliJoKDyWHKn16riJoKzoKzpKDiOofbYOdzKq8FPRxo6eobrHSdKX(oQqF6sQnczaGSfqwMmqwS7x07koHceSlPqpBYF9q(HG6ueiZuiJ0uVKSPNaYaoKPrF6ItvexTEuQbb)e9PloslWiLJsFariZSKreO4JsxVC0jPLwK80sRNwozGLA9OiTxYqJ(0vYi23rf6txjJ4noEJMmiH4)sxVC0jCcIczhiJ9DuH(0LuBeYmbYYgKrdKD6iK4kSC(uRO(cp16roviKrdK56JLZ3DJVHYPKAExaXXsTEuaz0HmZHSdb1PiqMjaGS8OaYYKbYID)IExXjuGGDjf6zt(RhYpeuNIazMczlYcYOdzhgCiztTEeYmdYOdzUE5OZ9beLElfdczMczlYkzebk(O01lhDsAPfjp5jJG5F8iPLtlTiTCYal16rrAVKHg9PRKbvrC16rPge8t0NUsgXBC8gnze7(f9UIlq13S635hcQtrGmtaaz5rbKbCidyqgDiJeI)lD9YrNWjikKDGm23rf6txsTridaKTaYObYoDesCfwoFQvuFHNA9iNkeYOdzXUFrVR4ekqWUKc9Sj)1d5hcQtrGmtHmGLvY4NcLrrYyX6jpTeWslNmWsTEuK2lzeVXXB0KHRpwoxGQVz1VZXsTEuaz0Hmsi(V01lhDcNGOq2bYyFhvOpDj1gHmaq2ciJgi70riXvy58Pwr9fEQ1JCQqiJoKzoKjANR5Dbe)qqDkcKzcKjANR5DbexqDQpDbzahYYIV)RdzzYazI25X(oQqF6IFiOofbYmbYeTZJ9DuH(0fxqDQpDbzahYYIV)RdzzYazI25KjCRl5pbi)qqDkcKzcKjANtMWTUK)eGCb1P(0fKbCill((VoKzgKrhYID)IExXfO6Bw978db1PiqMjaGmn6txCnVlG45rbKbCiBFGm6qwS7x07koHceSlPqpBYF9q(HG6ueiZuidyzLm0OpDLmI6)sn6txYFiEY4hIllfetgcl5Hbhs2sEAPSLwozGLA9OiTxYiEJJ3OjdxFSCUavFZQFNJLA9OaYOdzKq8FPRxo6eobrHSdKX(oQqF6sQnczaGSfqgnq2PJqIRWY5tTI6l8uRh5uHqgDil29l6DfNqbc2LuONn5VEi)qqDkcKzcaiJ0uVKSPNaYaoKPrF6IR5DbeppkGmAGmn6txCnVlG45rbKbCilBqgDiZCit0oxZ7ci(HG6ueiZeit0oxZ7ciUG6uF6cYaoKTaYYKbYeTZJ9DuH(0f)qqDkcKzcKjANh77Oc9PlUG6uF6cYaoKTaYYKbYeTZjt4wxYFcq(HG6ueiZeit0oNmHBDj)ja5cQt9Plid4q2ciZSKHg9PRKru)xQrF6s(dXtg)qCzPGyYqyjpm4qYwYtlTpPLtgyPwpks7LmI344nAYi29l6DfNqbc2LuONn5VEi)qqDkcKzkailBzbz0az5rbKLjdKf7(f9UItOab7sk0ZM8xpKFiOofbYmfYwSpzLm0OpDLmeO6Bw97jpT06PLtgyPwpks7LmI344nAYWIkiGd2RqqSCoviKrhYSOcc41KV5b6)8db1Pijdn6txjdYMk6DsR(9KNwI2NwozGLA9OiTxYiEJJ3OjdlQGaoyVcbXY5uHqgDiZEiZCiZ1hlNtMWTUK)eGCSuRhfqgDiZCil8WvY8OGVGR5DbeKrhYcpCLmpk4aJR5DbeKrhYcpCLmpk4zJR5DbeKzgKLjdKfE4kzEuWxW18UacYmlzOrF6kzO5DbuYtlT)PLtgyPwpks7LmI344nAYWIkiGd2RqqSCoviKrhYShYmhYcpCLmpk4l4KjCRl5pbiKrhYcpCLmpk4aJtMWTUK)eGqgDil8WvY8OGNnozc36s(taczMLm0OpDLmit4wxYFcWKNwAFtlNmWsTEuK2lzeVXXB0KHfvqahSxHGy5CQqiJoKzpKfE4kzEuWxWJ9DuH(0fKrhYShYC9XY5QfPFkhLX(oQqF6IJLA9OizOrF6kze77Oc9PRKNwk7MwozGLA9OiTxYiEJJ3OjdlQGa(u4QXvRhLceCiiN4A0giZuiBrwqgDiZ1lhDUpGO0BPyqiZeaq2ISsgA0NUsgItNs(taM80slYkTCYal16rrAVKr8ghVrtgU(y5CYeU1L8NaKJLA9OaYOdzwubb8PWvJRwpkfi4qqoX1OnqMPaGS1ZcYOvidyzbzahYmhYiH4)sxVC0jCcIczhiJ9DuH(0LuBeYOvi70riXvy58Pwr9fEQ1JCQqiZuaqgWGmZGm6qMODUM3fq8db1PiqMPq26qgWHmsi(VCtjocz0Hmr78yFhvOpDXpeuNIazMcz5rbKrhYmhYeTZjt4wxYFcq(HG6ueiZuilpkGSmzGm7HmxFSCozc36s(taYXsTEuazMbz0HmZHmbArfeW3uQY5hcQtrGmtHS1HmGdzKq8F5MsCeYYKbYShYC9XY5Bkv5CSuRhfqMzqgDil2LR5txqMPq26qgWHmsi(VCtjoMm0OpDLmeNoL8Nam5PLwSiTCYal16rrAVKr8ghVrtgU(y58D34BOCkPM3fqCSuRhfqgDiZIkiGpfUAC16rPabhcYjUgTbYmfaKTEwqgTczallid4qM5qgje)x66LJoHtqui7azSVJk0NUKAJqgTczNocjUclNp1kQVWtTEKtfczMcaYYgKzgKrRq26qgWHmZHmsi(V01lhDcNGOq2bYyFhvOpDj1gHmAfYoDesCfwoFQvuFHNA9iNkeYaazadYmdYOdzI25AExaXpeuNIazMczRdzahYiH4)YnL4iKrhYeTZJ9DuH(0f)qqDkcKzkKLhfqgDiZCitGwubb8nLQC(HG6ueiZuiBDid4qgje)xUPehHSmzGm7HmxFSC(Msvohl16rbKzgKrhYID5A(0fKzkKToKbCiJeI)l3uIJjdn6txjdXPtj)jatEAPfalTCYal16rrAVKr8ghVrtgU(y5C1I0pLJYyFhvOpDXXsTEuaz0HmlQGa(u4QXvRhLceCiiN4A0giZuaq26zbz0kKbSSGmGdzMdzKq8FPRxo6eobrHSdKX(oQqF6sQncz0kKD6iK4kSC(uRO(cp16roviKzkaiBFGmZGm6qMODUM3fq8db1PiqMPq26qgWHmsi(VCtjocz0HmZHmbArfeW3uQY5hcQtrGmtHS1HmGdzKq8F5MsCeYYKbYShYC9XY5Bkv5CSuRhfqMzqgDil2LR5txqMPq26qgWHmsi(VCtjoMm0OpDLmeNoL8Nam5PLwKT0Yjdn6txjJnLQ8KbwQ1JI0EjpT0I9jTCYqJ(0vYiOJueuivAdVXrPfQGjdSuRhfP9sEAPfRNwozOrF6kzesDtaqtLlTEL4jdSuRhfP9sEAPf0(0YjdSuRhfP9sgXBC8gnzypKjANh7kILFQJczWRGO0I6k(HG6ueiJoKzpKPrF6Ih7kILFQJczWRGiFkzWp5BEYqJ(0vYi2vel)uhfYGxbXKNwAX(NwozGLA9OiTxYqJ(0vYqC6usst9jJiqXhLUE5OtslTizmLJ3rf6jJfjJ4noEJMmC9YrN7dik9wkgeYmbaKLhfjJ4MovYyrYykhVJk0L5FBPFYyrYtlTyFtlNmWsTEuK2lzOrF6kzioDkjPP(KreO4JsxVC0jPLwKmMYX7OcD5eKm8jAdrEiOoLjRNmI344nAYW1hlNt2urVtIGwNgrowQ1JciJoKTsVrTEKdQt56usccz0Hm7HmbArfeWjBQO3jrqRtJi)qqDksYiUPtLmwKmMYX7OcDz(3w6NmwK80slYUPLtgyPwpks7Lm0OpDLmeNoLK0uFYicu8rPRxo6K0slsgt54DuHUCcsg(eTHipeuNYK1tgXBC8gnz46JLZjBQO3jrqRtJihl16rbKrhYwP3OwpYb1PCDkjbtgXnDQKXIKXuoEhvOlZ)2s)KXIKNwcyzLwozGLA9OiTxYqJ(0vYqC6usst9jJPC8oQqpzSize30Psglsgt54DuHUm)Bl9tglsEAjGTiTCYal16rrAVKHg9PRKbztf9oPv)EYiEJJ3OjdxFSCoztf9ojcADAe5yPwpkGm6q2k9g16roOoLRtjjiKrhYShYeOfvqaNSPIENebTonI8db1PiqgDiZEitJ(0fNSPIEN0QFNpLm4N8npzebk(O01lhDsAPfjpTeWawA5KbwQ1JI0Ejdn6txjdYMk6DsR(9Kr8ghVrtgU(y5CYMk6Dse060iYXsTEuaz0HSv6nQ1JCqDkxNssWKreO4JsxVC0jPLwK80salBPLtgA0NUsgKnv07Kw97jdSuRhfP9sEYtgKqSe4rslNwArA5KbwQ1JI0EjJ4noEJMmID)IExXjuGGDjf6zt(RhYpeuNIazMaaYin1ljB6jGmGdzMdziTaJuok9beHmAGmL2WBCKloufbuVmQ)pvo)0YgiZmiJoKzoKzpK56JLZfO6Bw97CSuRhfqwMmqwS7x07kUavFZQFNFiOofbYmbaKrAQxs20tazahYqAbgPCu6diczMLm0OpDLmOkIRwpk1GGFI(0vYtlbS0YjdSuRhfP9sgXBC8gnzyoKf7(f9UItOab7sk0ZM8xpKFiOofbYmbY8beLEljB6jGmGdzMdz0EiJwHmst9sYMEciZmiltgil29l6DfNqbc2LuONn5VEiNkeYmdYOdz(aIsVLIbHmtHSy3VO3vCcfiyxsHE2K)6H8db1Pijdn6txjJO(VuJ(0L8hINm(H4YsbXKrW8pEKKNwkBPLtgyPwpks7LmI344nAYyLEJA9iNIGscIIKHg9PRKbbrHSdKX(oQqF6k5PL2N0YjdSuRhfP9sgXBC8gnzypKTsVrTEKtrqjbrbKrhYShYcpCLmpk4l4ekqWUKc9Sj)1dHm6qM5qMRpwoxGQVz1VZXsTEuaz0HSy3VO3vCbQ(Mv)o)qqDkcKzcaidPfyKYrPpGiKrhYShYuAdVXrEujrvmvUmQVcooqCSuRhfqwMmqM5qgPPEjztpbKzkaiBDiJoKrcX)LUE5Ot4eefYoqg77Oc9PlP2iKzcKbmiltgiJ0uVKSPNaYmfaKbmiJoKrcX)LUE5Ot4eefYoqg77Oc9PlP2iKzkaidyqMzqgDiZ1lhDUpGO0BPyqiZuiBFGmAGmKwGrkhL(aIqgDiJeI)lD9YrNWjikKDGm23rf6txsTridaKTaYYKbYC9YrN7dik9wkgeYmbaKTVqgnqgslWiLJsFarid4qgPPEjztpbKzwYqJ(0vYGQiUA9Oudc(j6txjpT06PLtgyPwpks7LmI344nAYWEiBLEJA9iNIGscIciJoKf7Y18PliZeaqwujU0hqeYObYwP3OwpYdvHyQ8KHg9PRKbvrC16rPge8t0NUsEAjAFA5KbwQ1JI0Ejdn6txjdQI4Q1Jsni4NOpDLmI344nAYWEiBLEJA9iNIGscIciJoKzoKzpK56JLZfO6Bw97CSuRhfqwMmqwS7x07kUavFZQFNFiOofbYmfY8beLEljB6jGSmzGmst9sYMEciZuiBbKzgKrhYmhYShYC9XY5RMhLUoLZXsTEuazzYazKM6LKn9eqMPq2ciZmiJoKf7Y18PliZeaqwujU0hqeYObYwP3OwpYdvHyQCiJoKzoKzpKP0gEJJ8OsIQyQCzuFfCCG4yPwpkGSmzGmlQGaEujrvmvUmQVcooq8db1PiqMPqMpGO0BjztpbKzwYicu8rPRxo6K0slsEYtEYtEkb]] )


end