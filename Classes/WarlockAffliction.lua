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


    spec:RegisterPack( "Affliction", 20190810, [[dCKrmcqibYJuQKUKQezteXNuQevJcLYPqjTkvP6vOunlb4wevXUi8lLQmmb0XucltvkptPQMgrv11uISnIQuFJOQ04uLqNJOkzDkvImpIu3tvSpIkhuvIQfQkPhQkrXejQk6Ievf0jjQkWkfOMjrvH6MkvIIDQe1svLO0tPKPQuXvvQeL(krvHSxP6VumyehM0IPupwOjJQldTzb9zP0OvkNwXRjsMnWTvv7wYVfnCP44kvclxLNJ00P66Oy7kP(UsY4vLGZJsSELk18jk7h09f9D6wC1X(YVf4c5vGV4IafVTyPfljV6wolny3QrJsPTy3Q0p2TE5HHGj6twDRgLfqQ8(oDlAYCrSBT5EdDxAV9AhFJXweZ)E05ZauFYkEAOVhD(X96w2mdWLpO62DlU6yF53cCH8kWxCrGI3wS0c5)f7w0gm2x(n59sDRTHZXQB3T4in2T2vi5LhgcMOpzbjYhPhiJsbdExHKn3BO7s7Tx74Bm2Iy(3JoFgG6twXtd99OZpUhm4DfsE5mTmuhsweyaqYBbUqEbjYdK8wG7sY)sWGHbVRqYlZMwTiDxcg8UcjYdK8Y5CKdjwniaajYhNrPeWG3virEGKxoNJCir(exNmhKSlJ2orbm4DfsKhi5Lf)5AKdjUETOBMqHqadExHe5bsEzXDbZCiKiFM7qHeMgijliX1RfDijmpir(evFZoboKWgDQicjhgEiDdsaz7eHKHcj8jmepSCizcHKxg5tkKOhcj8HQ2aKZQag8UcjYdK8YInanIqcfxJNcGexVw0f(8rJNg(GqsuPifswn(gK4ZhnEA4dcjSHfhsYqibRyYuoESk6wnxgoaSBTRqYlpmemrFYcsKpspqgLcg8UcjBU3q3L2BV2X3ySfX8VhD(ma1NSINg67rNFCpyW7kK8YzAzOoKSiWaGK3cCH8csKhi5Ta3LK)LGbddExHKxMnTAr6Uem4DfsKhi5LZ5ihsSAqaasKpoJsjGbVRqI8ajVCoh5qI8jUozoizxgTDIcyW7kKipqYll(Z1ihsC9Ar3mHcHag8UcjYdK8YI7cM5qir(m3HcjmnqswqIRxl6qsyEqI8jQ(MDcCiHn6uresom8q6gKaY2jcjdfs4tyiEy5qYecjVmYNuirpes4dvTbiNvbm4DfsKhi5LfBaAeHekUgpfajUETOl85Jgpn8bHKOsrkKSA8niXNpA80WhesydloKKHqcwXKPC8yvadgg8UcjYh(cyKXroKyJH5Hqsm)2Qdj2y7uubK8YJrSXPqsLL8SP3pKbajA0NSOqswaweWG3virJ(Kfv0Cym)2Q)ecuQuWG3virJ(Kfv0Cym)2QZ(ZEHzYHbVRqIg9jlQO5Wy(TvN9N9uM2pwU6twWG1OpzrfnhgZVT6S)ShL5)ZY0Gomyn6twurZHX8BRo7p71EZpNdnzOHQXBcNigWe(4kalx0EZpNdnzOHQXBcNikWsTbihg8UcjA0NSOIMdJ53wD2F2JwAdDlDd1vNcdwJ(Kfv0Cym)2QZ(ZEnPpzbdwJ(Kfv0Cym)2QZ(ZEmu0mo(dO0p(O7MUPNsnHz5Mm00KRWdgSg9jlQO5Wy(TvN9N9OiYnzOjM3X04twbmHp0geamUETOtfue5Mm0eZ7yA8jlJMOCp7ljiCxWmnnixSqElV2FH8ddwJ(Kfv0Cym)2QZ(ZEBkt5WG1OpzrfnhgZVT6S)ShDt55kJDc8aMWNGCfGLl2uMYfyP2aKlH2GaGX1RfDQGIi3KHMyEhtJpzz0eLEFjbH7cMPPb5IfYB51(lKFyWWG3vir(WxaJmoYHeCnESaj(8riX3qirJEEqYqHeDToa1gGcyWA0NSOp0geamGmkfmyn6twu2F2JJRtMZ812jcdwJ(KfL9N9wR3O2amGs)4ddfnue5bSwbm4JRaSCbnxz8n0qrKtfyP2aKlH2GaGX1RfDQGIi3KHMyEhtJpzz0eL7zF2pD4gCnwUyQ1mGcp1gGcMgzYCfGLlOtZwwgWeIcSuBaYLqBqaW461IovqrKBYqtmVJPXNSK7zj2pD4gCnwUyQ1mGcp1gGcMgzYOniayC9ArNkOiYnzOjM3X04twY98ISF6Wn4ASCXuRzafEQnafmnWG1Opzrz)zV16nQnadO0p(0OC(uTbKnpu0dyTcyWhn6twc6MYZvg7e4c8fWiJJgF(476UXBCuevAu5t1AIkq)JZIal1gGCyWA0NSOS)S3A9g1gGbu6hFAuoFQ2aYMNdPOhWAfWGpTrEat4JUB8ghfrLgv(uTMOc0)4SiWsTbixcBUcWYf8tNYqtgGal1gGCzYCfGLl4O6B2jWfyP2aKljMjGNRkbhvFZobU4WVofv6N2iNvyWA0NSOS)S3A9g1gGbu6hF(6uUoLHIbSwbm4dTbbaJRxl6ubfrUjdnX8oMgFYYOjk9Zc2DfGLlwDJVHMPmABwSiWsTbiNDxby5c1MMaghnX8oMgFYsGLAdq(7VXoBUcWYfRUX3qZugTnlweyP2aKlXvawUGMRm(gAOiYPcSuBaYLqBqaW461IovqrKBYqtmVJPXNSmAIY9gRSZMRaSCbDA2YYaMquGLAdqUKGCfGLlIhInt1A4O6BcSuBaYLeKRaSCb)0Pm0KbiWsTbiNv2pD4gCnwUyQ1mGcp1gGcMgyWA0NSOS)S3A9g1gGbu6hF4PtnmnbSwbm4dBb5kalxqNMTSmGjefyP2aKltgpDbDA2YYaMquW0WQeE6cTnlweuxJsj3ZIaLeepDH2MflIddpKUP2aucpDrmVJPXNSemnWG1Opzrz)zVOcagn6twgWq9ak9JpXmb8CvrHbRrFYIY(ZE8tNYqtgqat54DmnUPfK2k4zraXnDQNfbezjcqJRxl60NfbmHp(8rJNg(Gs)0g5sOjdWq30Jl9sWG1Opzrz)zVnLP8aMWhAdcagxVw0PckICtgAI5Dmn(KLrtu6N3y)0HBW1y5IPwZak8uBakyAGbRrFYIY(ZEuM)pldxpPAb6HbmHp80fABwSi8jk1uTs4PlI5Dmn(KLWNOut1kHnBMWqHg9znAyuQG6AuQNLKjJMmadDtp(tGYKXtx0SPLNFdDQwgGEJZI4WVofvcpDrZMwE(n0PAza6nolId)6uuPFAJCwLWwqUcWYfnBA553qNQLbO34SiWsTbixMmE6IMnT88BOt1Ya0BCweh(1POSkHTGCfGLl4O6B2jWfyP2aKltwmtapxvcoQ(MDcCXHFDkQ0pTrUmzbfZeWZvLGJQVzNaxC4xNIktgTbbaJRxl6ubfrUjdnX8oMgFYYOjk3c2pD4gCnwUyQ1mGcp1gGcMgwHbRrFYIY(ZECu9n7e4bmHpXmb8CvjOm)FwgUEs1c0dfh(1POswR3O2auWtNAyAKqBqaW461IovqrKBYqtmVJPXNSmAIply)0HBW1y5IPwZak8uBakyAKWwqiLIvefRh6KLjdnn4fIrFYs8NkpjbP7gVXrb)qLhYamrfaMQvCAjLmzXmb8CvjOm)FwgUEs1c0dfh(1POYTFGScdwJ(KfL9N98n0Wu2jtXnH5fXaMWhBMWqXHrPaiLAcZlIId)6uuyWA0NSOS)SN2MflbezjcqJRxl60NfbmHph(1POs)0g5SRrFYsq3uEUYyNaxGVagzC04ZhL4ZhnEA4dk3lcdwJ(KfL9N9(4ppwmzObWehUHFO(PbmHp(8rP3pqyW7kKSd(BYtpwGKW5fGepHKVkfcjuMdHeD30n90D5uijmlhs4jsRD5oKyFOkfKW1tQwGEiKWq1wuadwJ(KfL9N902SyjaWuOjYF2pWaMWhF(OC7hOKyMaEUQeuM)pldxpPAb6HId)6uuPFwSKeCxWmnnixSqElV2FH8ddwJ(KfL9N9I5Dmn(KvaGPqtK)SFGbmHp(8r52pqjXmb8CvjOm)FwgUEs1c0dfh(1POs)Syjj4UGzAAqUyH8wET)c5xsqUcWYfQnnbmoAI5Dmn(KLal1gGCjS5kalxqNMTSmGjefyP2aKltgTbbaJRxl6ubfrUjdnX8oMgFYYOjk3cj0geamUETOtfue5Mm0eZ7yA8jlJMO0p7Zkmyn6twu2F2JonBzzatigayk0e5p7hyat4JpFuU9dusmtapxvckZ)NLHRNuTa9qXHFDkQ0plwscUlyMMgKlwiVLx7Vq(HbRrFYIY(ZEmf1vBaA0WqWe9jRaISebOX1RfD6ZIaMWNGIz5A7KLeF(OXtdFqPFEryWA0NSOS)Sh)0Pm0KbeqKLianUETOtFwequRicmt4JprPOMd)6usVuat4JRaSCbDt55kd(TpnIcSuBaYLSwVrTbO4Rt56ugkkHJ2mHHc6MYZvg8BFAefh(1POs4OntyOGUP8CLb)2NgrXHFDkQ0pTr(7VbdwJ(KfL9N9OBkpxzStGhqKLianUETOtFweWe(4kalxq3uEUYGF7tJOal1gGCjR1BuBak(6uUoLHIs4OntyOGUP8CLb)2NgrXHFDkQeoAZegkOBkpxzWV9PruC4xNIk9d(cyKXrJpF893y3pDncm(8rjbPrFYsq3uEUYyNaxmLjemTBomyn6twu2F2Rztlp)g6uTma9gNLaISebOX1RfD6ZIaMWhF(OC7VKexVw0f(8rJNg(GYTqE)oTbbaZMsDucBbHukwruSEOtwMm00Gxig9jlXFQ8KeKUB8ghf8dvEidWevayQwXPLuYKfZeWZvLGY8)zz46jvlqpuC4xNIkN8Ve70KbyOB6XFx3nEJJc(HkpKbyIkamvR40skzYIzc45Qsqz()SmC9KQfOhko8RtrLEXsVtBqaWSPuhzNMmadDtp(76UXBCuWpu5HmatubGPAfNwsXkmyn6twu2F2JPOUAdqJggcMOpzfqKLianUETOtFweWe(e0A9g1gGcgkAOiYLqtgGHUPh)zjyWA0NSOS)ShfrUjdnX8oMgFYkGj8zTEJAdqbdfnue5sOjdWq30J)Semyn6twu2F2lQaGrJ(KLbmupGs)4dpDkmyn6twu2F2B9aqJRt5bezjcqJRxl60NfbmHp(8r5wSKeF(OXtdFq5EweOe2Izc45Qsqz()SmC9KQfOhko8RtrLB)aLjlMjGNRkbL5)ZYW1tQwGEO4WVofv6fbkHNUqBZIfXHFDkQCplcucpDrmVJPXNSeh(1POY9SiqjSXtxqNMTSmGjefh(1POY9SiqzYcYvawUGonBzzatikWsTbiNvwHbRrFYIY(ZEmu0mo(dO0p(O7MUPNsnHz5Mm00KRWlGj8XNpk9Z(WG1Opzrz)zVMnT88BOt1Ya0BCwcycF85Js)S)sWG1Opzrz)zV1danUoLhWe(4ZhLEXsWG1Opzrz)zVwg94JwMm0O7gV03cycFylMjGNRkbL5)ZYW1tQwGEO4WVofv6flXonzag6ME831DJ34OGFOYdzaMOcat1kWsTbixMm20DJ34OGFOYdzaMOcat1koTKsMmKsXkII1dDYYKHMg8cXOpzjoTKIvj(8r52pqj(8rJNg(GY982IazvcB80fnBA553qNQLbO34Sio8RtrLjJNUy9aqJRt5Id)6uuzYcYvawUOztlp)g6uTma9gNfbwQna5scYvawUy9aqJRt5cSuBaYzvMmF(OXtdFqP3pq2BJCyWA0NSOS)ShxpPm0KbeWe(eZeWZvLGY8)zz46jvlqpuC4xNIk9ILyNMmadDtp(76UXBCuWpu5HmatubGPAfyP2aKlHnE6IMnT88BOt1Ya0BCweh(1POYKXtxSEaOX1PCXHFDkkRWG1Opzrz)zpB8O4j1uTWG1Opzrz)zVOcagn6twgWq9ak9Jp0gS44rHbRrFYIY(ZErfamA0NSmGH6bu6hFchaapkmyyWA0NSOIyMaEUQOpmu0mo(dO0p(O7MUPNsnHz5Mm00KRWlGj8HTGCfGLlA20YZVHovldqVXzrGLAdqUmzXmb8CvjA20YZVHovldqVXzrC4xNIkT8)oTbbaZMsDuMSGIzc45Qs0SPLNFdDQwgGEJZI4WVofLvjXmb8CvjOm)FwgUEs1c0dfh(1POsVqE9oTbbaZMsDKDAYam0n94VR7gVXrb)qLhYamrfaMQvCAjLeE6cTnlweh(1POs4PlI5Dmn(KL4WVofvcB80f0PzlldycrXHFDkQmzb5kalxqNMTSmGjefyP2aKZkmyn6twurmtapxvu2F2Rj9jRaMWh2CfGLl46jLHMmaZFO4XIal1gGCjXmb8CvjOm)FwgUEs1c0dfmnsIzc45QsW1tkdnzacMgwLjlMjGNRkbL5)ZYW1tQwGEOGPrMmF(OXtdFqP3pqyWA0NSOIyMaEUQOS)ShdfnJJFAat4tmtapxvckZ)NLHRNuTa9qXHFDkQCY3aLjZNpA80Whu63cuMm2yZMjmuOrFwJggLkOUgL6zjzYOjdWq30J)eiRsylixby5IMnT88BOt1Ya0BCweyP2aKltwmtapxvIMnT88BOt1Ya0BCweh(1POSkHTGCfGLl4O6B2jWfyP2aKltwmtapxvcoQ(MDcCXHFDkQ0pTrUmzbfZeWZvLGJQVzNaxC4xNIYQKGIzc45Qsqz()SmC9KQfOhko8RtrzfgSg9jlQiMjGNRkk7p7fohAdYKhWe(eumtapxvckZ)NLHRNuTa9qbtdmyn6twurmtapxvu2F2ZgKj3eYCSeWe(eumtapxvckZ)NLHRNuTa9qbtdmyn6twurmtapxvu2F27J)8yXKHgatC4g(H6NgWe(4ZhLB)aHbRrFYIkIzc45QIY(ZEC9KYqtgqat4JpF04PHpO0Vfi7TrUmzUcWYf0CLX3qdfrovGLAdqUKyMaEUQeuM)pldxpPAb6HId)6uu5EIzc45Qsqz()SmC9KQfOhk4mN6twYZIaHbRrFYIkIzc45QIY(ZE2Gm5Mm04BObl8Zsat4td6cUEs1c0dfh(1POYKXwqXmb8Cvj4O6B2jWfh(1POYKfKRaSCbhvFZobUal1gGCwLeZeWZvLGY8)zz46jvlqpuC4xNIk3ZlgOeKsXkIcBqMCtgA8n0Gf(zrCAjLClGbVRqYUSues46xBNQfsYsEyOiK43usHofs(5HqsEqcaPuijlijMjGNRQaGeAcjGSAHeLcj(gcjYh8YiFcj(gYcKmvK5GKvzTl3HemmeJoKOflqs6B4bj(nLuOtHegQ2IqcN5MQfsIzc45QIkGbRrFYIkIzc45QIY(ZEmu0mo(dO0p(0KrPqNo7g5My(ByC1NSmCC9eXaMWh2Izc45Qsqz()SmC9KQfOhko8RtrL75TLKjZNpA80Whu6N9dKvjSfZeWZvLGJQVzNaxC4xNIktwqUcWYfCu9n7e4cSuBaYzfgSg9jlQiMjGNRkk7p7XqrZ44pGs)4ZLE8yOoYnRZKNPHNaqat4dBXmb8CvjOm)FwgUEs1c0dfh(1POY982sYK5ZhnEA4dk9Z(bYQe2Izc45QsWr13StGlo8RtrLjlixby5coQ(MDcCbwQna5ScdwJ(KfveZeWZvfL9N9yOOzC8hqPF8HUnRXZSgR8BoemXaMWh2Izc45Qsqz()SmC9KQfOhko8RtrL75TLKjZNpA80Whu6N9dKvjSfZeWZvLGJQVzNaxC4xNIktwqUcWYfCu9n7e4cSuBaYzfgSg9jlQiMjGNRkk7p7XqrZ44pGs)4JUlyMM0XYnLY4dGHgWe(WwmtapxvckZ)NLHRNuTa9qXHFDkQCpVTKmz(8rJNg(Gs)SFGSkHTyMaEUQeCu9n7e4Id)6uuzYcYvawUGJQVzNaxGLAdqoRWG1OpzrfXmb8Cvrz)zpgkAgh)bu6hF8HJupVVjMC8fcycFylMjGNRkbL5)ZYW1tQwGEO4WVofvUN3wsMmF(OXtdFqPF2pqwLWwmtapxvcoQ(MDcCXHFDkQmzb5kalxWr13StGlWsTbiNvyWA0NSOIyMaEUQOS)ShdfnJJ)ak9JpRhfyYqd1Z7tdycFylMjGNRkbL5)ZYW1tQwGEO4WVofvUN3wsMmF(OXtdFqPF2pqwLWwmtapxvcoQ(MDcCXHFDkQmzb5kalxWr13StGlWsTbiNvyWA0NSOIyMaEUQOS)S3Q8a814uMdPzPvedycFSzcdfGjeTbzYfuxJsj9(WG1OpzrfXmb8Cvrz)zVBAAaOzkdTrJimyyWA0NSOcUT5WWdPBp0PzlldycXaatHMi)zXsbmHpSXtxqNMTSmGjefh(1POVepDbDA2YYaMquWzo1NSyv6h24Pl02SyrC4xNI(s80fABwSi4mN6twSkHnE6c60SLLbmHO4WVof9L4PlOtZwwgWeIcoZP(KfRs)WgpDrmVJPXNSeh(1POVepDrmVJPXNSeCMt9jlwLWtxqNMTSmGjefh(1POsZtxqNMTSmGjefCMt9jR3xi2hgSg9jlQGBBom8q6g7p7PTzXsaGPqtK)SyPaMWh24Pl02SyrC4xNI(s80fABwSi4mN6twSk9dB80fX8oMgFYsC4xNI(s80fX8oMgFYsWzo1NSyvcB80fABwSio8RtrFjE6cTnlweCMt9jlwL(HnE6c60SLLbmHO4WVof9L4PlOtZwwgWeIcoZP(KfRs4Pl02SyrC4xNIknpDH2MflcoZP(K17le7ddwJ(KfvWTnhgEiDJ9N9I5Dmn(KvaGPqtK)SyPaMWh24PlI5Dmn(KL4WVof9L4PlI5Dmn(KLGZCQpzXQ0pSXtxOTzXI4WVof9L4Pl02SyrWzo1NSyvcB80fX8oMgFYsC4xNI(s80fX8oMgFYsWzo1NSyv6h24PlOtZwwgWeIId)6u0xINUGonBzzatik4mN6twSkHNUiM3X04twId)6uuP5PlI5Dmn(KLGZCQpz9(cX(WGHbRrFYIk4PtFOiYnzOjM3X04twbmHp80fX8oMgFYsC4xNIk9Jg9jlbfrUjdnX8oMgFYsevQB85JS7ZhnEAOB6Xzx(fV9oBlKhxby5I4HyZuTgoQ(Mal1gG83duSyjwLqBqaW461IovqrKBYqtmVJPXNSmAIY9Sp7NoCdUglxm1AgqHNAdqbtd7UcWYfRUX3qZugTnlweyP2aKljiE6ckICtgAI5Dmn(KL4WVofvsqA0NSeue5Mm0eZ7yA8jlXuMqW0U5WG1Opzrf80PS)SN2MflbezjcqJRxl60NfbmHpUcWYfXdXMPAnCu9nbwQna5s0OpRrdpDH2MflslVL4ZhnEA4dk3IaLW2HFDkQ0pTrUmzXmb8CvjOm)FwgUEs1c0dfh(1POYTiqjSD4xNIk9sYKfKUB8ghfnAXX)entToJQpzjoTKsYHHhs3uBaYkRWG1Opzrf80PS)SN2MflbezjcqJRxl60NfbmHpb5kalxepeBMQ1Wr13eyP2aKlrJ(Sgn80fABwSi9lkXNpA80WhuUfbkHTd)6uuPFAJCzYIzc45Qsqz()SmC9KQfOhko8RtrLBrGsy7WVofv6LKjliD34nokA0IJ)jAMADgvFYsCAjLKddpKUP2aKvwHbRrFYIk4Ptz)zp60SLLbmHyarwIa0461Io9zrat4dBA0N1OHNUGonBzzatik9lkpUcWYfXdXMPAnCu9nbwQna5YdTbbaJRxl6ubnxz8n0qrKtnAISkXNpA80WhuUfbk5WWdPBQnaLWwqh(1POsOniayC9ArNkOiYnzOjM3X04twgnXNfYKfZeWZvLGY8)zz46jvlqpuC4xNIkhnzag6ME831OpzjykQR2a0OHHGj6twc8fWiJJgF(iRWG1Opzrf80PS)SxmVJPXNSciYseGgxVw0PplcycFOniayC9ArNkOiYnzOjM3X04twgnrP3N9thUbxJLlMAndOWtTbOGPHDxby5Iv34BOzkJ2MflcSuBaYLW2HFDkQ0pTrUmzXmb8CvjOm)FwgUEs1c0dfh(1POYTiqjhgEiDtTbiRsC9Arx4ZhnEA4dk3IaHbddwJ(KfveoaaE0hMI6QnanAyiyI(KvaGPqtK)SyPaMWNyMaEUQeCu9n7e4Id)6uuPFAJ83FtcTbbaJRxl6ubfrUjdnX8oMgFYYOj(SG9thUbxJLlMAndOWtTbOGPrsmtapxvckZ)NLHRNuTa9qXHFDkQCVfimyn6twur4aa4rz)zVOcagn6twgWq9ak9JpCBZHHhs3cycFCfGLl4O6B2jWfyP2aKlH2GaGX1RfDQGIi3KHMyEhtJpzz0eFwW(Pd3GRXYftTMbu4P2auW0iHnE6cTnlweh(1POsZtxOTzXIGZCQpz9EGc57sYKXtxeZ7yA8jlXHFDkQ080fX8oMgFYsWzo1NSEpqH8DjzY4PlOtZwwgWeIId)6uuP5PlOtZwwgWeIcoZP(K17bkKVlXQKyMaEUQeCu9n7e4Id)6uuPF0Opzj02Syr0g5Vl)sIzc45Qsqz()SmC9KQfOhko8RtrL7TaHbRrFYIkchaapk7p7fvaWOrFYYagQhqPF8HBBom8q6wat4JRaSCbhvFZobUal1gGCj0geamUETOtfue5Mm0eZ7yA8jlJM4Zc2pD4gCnwUyQ1mGcp1gGcMgjXmb8CvjOm)FwgUEs1c0dfh(1POs)qtgGHUPh)Dn6twcTnlweTro7A0NSeABwSiAJ833xcB80fABwSio8RtrLMNUqBZIfbN5uFY69fYKXtxeZ7yA8jlXHFDkQ080fX8oMgFYsWzo1NSEFHmz80f0PzlldycrXHFDkQ080f0PzlldycrbN5uFY69fScdwJ(KfveoaaEu2F2JJQVzNapGj8zTEJAdqbpDQHPrcBXmb8CvjOm)FwgUEs1c0dfh(1POY9SFGS3g5YKfZeWZvLGY8)zz46jvlqpuC4xNIk3c5pqwHbRrFYIkchaapk7p7r3uEUYyNapGj8XMjmu8Z14hlxW0iXMjmuut7MhQaG4WVoffgSg9jlQiCaa8OS)SN2MflbmHp2mHHIFUg)y5cMgjbXMRaSCbDA2YYaMquGLAdqUe2AoCTPnYfleABwSiP5W1M2ix8MqBZIfjnhU20g5I9fABwSWQmznhU20g5IfcTnlwyfgSg9jlQiCaa8OS)ShDA2YYaMqmGj8XMjmu8Z14hlxW0iji2AoCTPnYfle0PzlldycrjnhU20g5I3e0PzlldycrjnhU20g5I9f0PzlldycrwHbRrFYIkchaapk7p7fZ7yA8jRaMWhBMWqXpxJFSCbtJKGAoCTPnYfleX8oMgFYssqUcWYfQnnbmoAI5Dmn(KLal1gGCyWA0NSOIWbaWJY(ZE8tNYaMqmGj8XMjmumfUEC1gGgo(hkkOUgLsUfbkXNpA80Whu6NfbcdwJ(KfveoaaEu2F2JF6ugWeIbmHpUcWYf0PzlldycrbwQna5sSzcdftHRhxTbOHJ)HIcQRrPK7zPaLN3c8D2OniayC9ArNkOiYnzOjM3X04twgnr550HBW1y5IPwZak8uBakyAK75nwLWtxOTzXI4WVofvULEN2GaGztPokHNUiM3X04twId)6uu5AJCjSXtxqNMTSmGjefh(1POY1g5YKfKRaSCbDA2YYaMquGLAdqoRsyJJ2mHHInLPCXHFDkQCl9oTbbaZMsDuMSGCfGLl2uMYfyP2aKZQKywU2ozj3sVtBqaWSPuhHbRrFYIkchaapk7p7XpDkdycXaMWhxby5Iv34BOzkJ2MflcSuBaYLyZegkMcxpUAdqdh)dffuxJsj3ZsbkpVf47SrBqaW461IovqrKBYqtmVJPXNSmAIYZPd3GRXYftTMbu4P2auW0i3Z(Skpl9oB0geamUETOtfue5Mm0eZ7yA8jlJMO8C6Wn4ASCXuRzafEQnafmnpVXQeE6cTnlweh(1POYT070geamBk1rj80fX8oMgFYsC4xNIkxBKlHnoAZegk2uMYfh(1POYT070geamBk1rzYcYvawUytzkxGLAdqoRsIz5A7KLCl9oTbbaZMsDegSg9jlQiCaa8OS)Sh)0PmGjedycFCfGLluBAcyC0eZ7yA8jlbwQna5sSzcdftHRhxTbOHJ)HIcQRrPK7zPaLN3c8D2OniayC9ArNkOiYnzOjM3X04twgnr550HBW1y5IPwZak8uBakyAK7r(zvcpDH2MflId)6uu5w6DAdcaMnL6Oe24OntyOytzkxC4xNIk3sVtBqaWSPuhLjlixby5InLPCbwQna5SkjMLRTtwYT070geamBk1ryWA0NSOIWbaWJY(ZEBkt5WG1OpzrfHdaGhL9N9cZidf5gD34noASr9ddwJ(KfveoaaEu2F2RH5MqwMQ1yduQddwJ(KfveoaaEu2F2lMvel)uh5MqG(XaMWNG4PlIzfXYp1rUjeOF0yZCL4WVofvsqA0NSeXSIy5N6i3ec0pkMYecM2nhgSg9jlQiCaa8OS)Sh)0Pm0KbeWuoEhtJBAbPTcEweqCtN6zrat54Dmn(ZIaISebOX1RfD6ZIaMWhF(OXtdFqPFAJCyWA0NSOIWbaWJY(ZE8tNYqtgqarwIa0461Io9zraXnDQNfbmLJ3X04Mj8XNOuuZHFDkPxkGPC8oMg30csBf8SiGj8XvawUGUP8CLb)2NgrbwQna5swR3O2au81PCDkdfLeehTzcdf0nLNRm43(0iko8RtrHbRrFYIkchaapk7p7XpDkdnzabezjcqJRxl60Nfbe30PEweWuoEhtJBMWhFIsrnh(1PKEPaMYX7yACtliTvWZIaMWhxby5c6MYZvg8BFAefyP2aKlzTEJAdqXxNY1PmuegSg9jlQiCaa8OS)Sh)0Pm0KbeWuoEhtJBAbPTcEweqCtN6zrat54Dmn(ZcyWA0NSOIWbaWJY(ZE0nLNRm2jWdiYseGgxVw0PplcycFCfGLlOBkpxzWV9PruGLAdqUK16nQnafFDkxNYqrjbXrBMWqbDt55kd(TpnIId)6uujbPrFYsq3uEUYyNaxmLjemTBomyn6twur4aa4rz)zp6MYZvg7e4bezjcqJRxl60NfbmHpUcWYf0nLNRm43(0ikWsTbixYA9g1gGIVoLRtzOimyn6twur4aa4rz)zp6MYZvg7e4WGHbRrFYIkOnyXXJ(WuuxTbOrddbt0NScycFIzc45Qsqz()SmC9KQfOhko8RtrL(HMmadDtp(7SHVagzC04Zhzx3nEJJc(HkpKbyIkamvR40skwLWwqUcWYfCu9n7e4cSuBaYLjlMjGNRkbhvFZobU4WVofv6hAYam0n94VJVagzC04ZhzvcBUcWYf0CLX3qdfrovGLAdqUmz80fnBA553qNQLbO34Sio8RtrLjJNUy9aqJRt5Id)6uuwHbRrFYIkOnyXXJY(ZErfamA0NSmGH6bu6hFchaapAat4dBXmb8CvjOm)FwgUEs1c0dfh(1POs7ZhnEAOB6XFNTLKhAYam0n94SktwmtapxvckZ)NLHRNuTa9qbtdRs85Jgpn8bLlMjGNRkbL5)ZYW1tQwGEO4WVoffgSg9jlQG2Gfhpk7p7rrKBYqtmVJPXNScycFwR3O2auWqrdfromyn6twubTbloEu2F2JPOUAdqJggcMOpzfWe(e0A9g1gGcgkAOiYLeuZHRnTrUyHGY8)zz46jvlqpucBUcWYfCu9n7e4cSuBaYLeZeWZvLGJQVzNaxC4xNIk9d(cyKXrJpFusq6UXBCuevAu5t1AIkq)JZIal1gGCzYyJMmadDtpUCpljH2GaGX1RfDQGIi3KHMyEhtJpzz0eL(nzYOjdWq30Jl3ZBsOniayC9ArNkOiYnzOjM3X04twgnr5EEJvjUETOl85Jgpn8bLt(zhFbmY4OXNpkH2GaGX1RfDQGIi3KHMyEhtJpzz0eFwitMpF04PHpO0pVi74lGrghn(8X3PjdWq30JZkmyn6twubTbloEu2F2JPOUAdqJggcMOpzfWe(e0A9g1gGcgkAOiYLeZY12jlPFIk1n(8r2xR3O2au0OC(uTWG1Opzrf0gS44rz)zpMI6QnanAyiyI(KvarwIa0461Io9zrat4tqR1BuBakyOOHIixcBb5kalxWr13StGlWsTbixMSyMaEUQeCu9n7e4Id)6uu585Jgpn0n94YKrtgGHUPhxUfSkHTGCfGLlwpa046uUal1gGCzYOjdWq30Jl3cwLeZY12jlPFIk1n(8r2xR3O2au0OC(uTsyliD34nokIknQ8PAnrfO)XzrGLAdqUmz2mHHIOsJkFQwtub6FCweh(1POY5ZhnEAOB6XzTBTgp6KvF53cCH8kWxmq5xSyPfDRv6vt1s7wYh8BYZroKiFHen6twqcyOovadUBbgQt770T42MddpKU13PV8I(oDlSuBaY7V2T0Opz1TOtZwwgWeIDR4noEJ2Tyds4PlOtZwwgWeIId)6uui5LGeE6c60SLLbmHOGZCQpzbjScjs)ajSbj80fABwSio8RtrHKxcs4Pl02SyrWzo1NSGewHejqcBqcpDbDA2YYaMquC4xNIcjVeKWtxqNMTSmGjefCMt9jliHvir6hiHniHNUiM3X04twId)6uui5LGeE6IyEhtJpzj4mN6twqcRqIeiHNUGonBzzatiko8RtrHePHeE6c60SLLbmHOGZCQpzbjVdjle73TatHMiVBTyPU3x(T(oDlSuBaY7V2T0Opz1T02SyPBfVXXB0UfBqcpDH2MflId)6uui5LGeE6cTnlweCMt9jliHvir6hiHniHNUiM3X04twId)6uui5LGeE6IyEhtJpzj4mN6twqcRqIeiHniHNUqBZIfXHFDkkK8sqcpDH2MflcoZP(KfKWkKi9dKWgKWtxqNMTSmGjefh(1POqYlbj80f0PzlldycrbN5uFYcsyfsKaj80fABwSio8RtrHePHeE6cTnlweCMt9jli5DizHy)Ufyk0e5DRfl19(Y733PBHLAdqE)1ULg9jRUvmVJPXNS6wXBC8gTBXgKWtxeZ7yA8jlXHFDkkK8sqcpDrmVJPXNSeCMt9jliHvir6hiHniHNUqBZIfXHFDkkK8sqcpDH2MflcoZP(KfKWkKibsyds4PlI5Dmn(KL4WVoffsEjiHNUiM3X04twcoZP(KfKWkKi9dKWgKWtxqNMTSmGjefh(1POqYlbj80f0PzlldycrbN5uFYcsyfsKaj80fX8oMgFYsC4xNIcjsdj80fX8oMgFYsWzo1NSGK3HKfI97wGPqtK3TwSu37E3IJHkdW770xErFNULg9jRUfTbbadiJs1TWsTbiV)A37l)wFNULg9jRUfhxNmN5RTtSBHLAdqE)1U3xE)(oDlSuBaY7V2TYMUff9ULg9jRU1A9g1gGDR1kGb7wUcWYf0CLX3qdfrovGLAdqoKibsOniayC9ArNkOiYnzOjM3X04twgnrirUhizFiHDi50HBW1y5IPwZak8uBakyAGezYGexby5c60SLLbmHOal1gGCircKqBqaW461IovqrKBYqtmVJPXNSGe5EGKLGe2HKthUbxJLlMAndOWtTbOGPbsKjdsOniayC9ArNkOiYnzOjM3X04twqICpqYlcjSdjNoCdUglxm1AgqHNAdqbtt3ATEMs)y3IHIgkI8U3xw(770TWsTbiV)A3kB6wu07wA0NS6wR1BuBa2TwRagSBPrFYsq3uEUYyNaxGVagzC04ZhHK3HeD34nokIknQ8PAnrfO)XzrGLAdqE3ATEMs)y3Qr58PA7EF5L670TWsTbiV)A3kB6whsrVBPrFYQBTwVrTby3ATcyWUvBK3TI344nA3s3nEJJIOsJkFQwtub6FCweyP2aKdjsGe2Gexby5c(PtzOjdqGLAdqoKitgK4kalxWr13StGlWsTbihsKajXmb8Cvj4O6B2jWfh(1POqI0pqsBKdjS2TwRNP0p2TAuoFQ2U3xwE33PBHLAdqE)1Uv20TOO3T0Opz1TwR3O2aSBTwbmy3I2GaGX1RfDQGIi3KHMyEhtJpzz0eHePFGKfqc7qIRaSCXQB8n0mLrBZIfbwQna5qc7qIRaSCHAttaJJMyEhtJpzjWsTbihsEhsEdsyhsydsCfGLlwDJVHMPmABwSiWsTbihsKajUcWYf0CLX3qdfrovGLAdqoKibsOniayC9ArNkOiYnzOjM3X04twgnriroi5niHviHDiHniXvawUGonBzzatikWsTbihsKajbbjUcWYfXdXMPAnCu9nbwQna5qIeijiiXvawUGF6ugAYaeyP2aKdjScjSdjNoCdUglxm1AgqHNAdqbtt3ATEMs)y36Rt56ugk29(YY3(oDlSuBaY7V2TYMUff9ULg9jRU1A9g1gGDR1kGb7wSbjbbjUcWYf0PzlldycrbwQna5qImzqcpDbDA2YYaMquW0ajScjsGeE6cTnlweuxJsbjY9ajlcesKajbbj80fABwSiom8q6MAdqircKWtxeZ7yA8jlbtt3ATEMs)y3INo1W009(YVyFNUfwQna59x7wA0NS6wrfamA0NSmGH6DlWqDtPFSBfZeWZvfT79LLx9D6wyP2aK3FTBPrFYQBXpDkdnzaDRilraAC9ArN2xEr3kEJJ3ODlF(OXtdFqir6hiPnYHejqcnzag6MECirAizPUvCtNQBTOBnLJ3X04MwqARGU1IU3xErG9D6wyP2aK3FTBfVXXB0UfTbbaJRxl6ubfrUjdnX8oMgFYYOjcjs)ajVbjSdjNoCdUglxm1AgqHNAdqbtt3sJ(Kv3AtzkV79LxSOVt3cl1gG8(RDR4noEJ2T4Pl02Syr4tuQPAHejqcpDrmVJPXNSe(eLAQwircKWgKyZegk0OpRrdJsfuxJsbjpqYsqImzqcnzag6MECi5bscesKjds4PlA20YZVHovldqVXzrC4xNIcjsGeE6IMnT88BOt1Ya0BCweh(1POqI0pqsBKdjScjsGe2GKGGexby5IMnT88BOt1Ya0BCweyP2aKdjYKbj80fnBA553qNQLbO34Sio8RtrHewHejqcBqsqqIRaSCbhvFZobUal1gGCirMmijMjGNRkbhvFZobU4WVoffsK(bsAJCirMmijiijMjGNRkbhvFZobU4WVoffsKjdsOniayC9ArNkOiYnzOjM3X04twgnriroizbKWoKC6Wn4ASCXuRzafEQnafmnqcRDln6twDlkZ)NLHRNuTa9WU3xEXB9D6wyP2aK3FTBfVXXB0UvmtapxvckZ)NLHRNuTa9qXHFDkkKibswR3O2auWtNAyAGejqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjpqYciHDi50HBW1y5IPwZak8uBakyAGejqcBqsqqcsPyfrX6HozzYqtdEHy0NSe)PYdsKajbbj6UXBCuWpu5HmatubGPAfNwsbjYKbjXmb8CvjOm)FwgUEs1c0dfh(1POqICqY(bcjS2T0Opz1T4O6B2jW7EF5f733PBHLAdqE)1Uv8ghVr7w2mHHIdJsbqk1eMxefh(1PODln6twDlFdnmLDYuCtyErS79Lxi)9D6wyP2aK3FTBPrFYQBPTzXs3kEJJ3ODRd)6uuir6hiPnYHe2Hen6twc6MYZvg7e4c8fWiJJgF(iKibs85Jgpn8bHe5GKxSBfzjcqJRxl60(Yl6EF5fl13PBHLAdqE)1Uv8ghVr7w(8rirAiz)a7wA0NS6wF8NhlMm0ayId3Wpu)0U3xEH8UVt3cl1gG8(RDln6twDlTnlw6wXBC8gTB5ZhHe5GK9desKajXmb8CvjOm)FwgUEs1c0dfh(1POqI0pqYILGejqcUlyMMgKl0Dt30tPMWSCtgAAYv41TatHMiVBTFGDVV8c5BFNUfwQna59x7wA0NS6wX8oMgFYQBfVXXB0ULpFesKds2pqircKeZeWZvLGY8)zz46jvlqpuC4xNIcjs)ajlwcsKaj4UGzAAqUq3nDtpLAcZYnzOPjxHhKibsccsCfGLluBAcyC0eZ7yA8jlbwQna5qIeiHniXvawUGonBzzatikWsTbihsKjdsOniayC9ArNkOiYnzOjM3X04twgnriroizbKibsOniayC9ArNkOiYnzOjM3X04twgnrir6hizFiH1Ufyk0e5DR9dS79Lx8I9D6wyP2aK3FTBPrFYQBrNMTSmGje7wXBC8gTB5ZhHe5GK9desKajXmb8CvjOm)FwgUEs1c0dfh(1POqI0pqYILGejqcUlyMMgKl0Dt30tPMWSCtgAAYv41TatHMiVBTFGDVV8c5vFNUfwQna59x7wA0NS6wmf1vBaA0WqWe9jRUv8ghVr7wbbjXSCTDYcsKaj(8rJNg(GqI0pqYl2TISebOX1RfDAF5fDVV8Bb23PBHLAdqE)1ULg9jRUf)0Pm0Kb0TISebOX1RfDAF5fDROwreyMWULprPOMd)6usVu3kEJJ3ODlxby5c6MYZvg8BFAefyP2aKdjsGK16nQnafFDkxNYqrircKWrBMWqbDt55kd(TpnIId)6uuircKWrBMWqbDt55kd(TpnIId)6uuir6hiPnYHK3HK36EF53w03PBHLAdqE)1ULg9jRUfDt55kJDc8Uv8ghVr7wUcWYf0nLNRm43(0ikWsTbihsKajR1BuBak(6uUoLHIqIeiHJ2mHHc6MYZvg8BFAefh(1POqIeiHJ2mHHc6MYZvg8BFAefh(1POqI0pqc(cyKXrJpFesEhsEdsyhs8txJaJpFesKajbbjA0NSe0nLNRm2jWftzcbt7M3TISebOX1RfDAF5fDVV8BV13PBHLAdqE)1ULg9jRUvZMwE(n0PAza6nolDR4noEJ2T85JqICqY(lbjsGexVw0f(8rJNg(GqICqYc5nK8oKqBqaWSPuhHejqcBqsqqcsPyfrX6HozzYqtdEHy0NSe)PYdsKajbbj6UXBCuWpu5HmatubGPAfNwsbjYKbjXmb8CvjOm)FwgUEs1c0dfh(1POqICqI8VeKWoKqtgGHUPhhsEhs0DJ34OGFOYdzaMOcat1koTKcsKjdsIzc45Qsqz()SmC9KQfOhko8RtrHePHKflbjVdj0geamBk1riHDiHMmadDtpoK8oKO7gVXrb)qLhYamrfaMQvCAjfKWA3kYseGgxVw0P9Lx09(YVTFFNUfwQna59x7wA0NS6wmf1vBaA0WqWe9jRUv8ghVr7wbbjR1BuBakyOOHIihsKaj0KbyOB6XHKhizPUvKLianUETOt7lVO79LFt(770TWsTbiV)A3kEJJ3ODR16nQnafmu0qrKdjsGeAYam0n94qYdKSu3sJ(Kv3IIi3KHMyEhtJpz19(YVTuFNUfwQna59x7wA0NS6wrfamA0NSmGH6DlWqDtPFSBXtN29(YVjV770TWsTbiV)A3sJ(Kv3A9aqJRt5DR4noEJ2T85JqICqYILGejqIpF04PHpiKi3dKSiqircKWgKeZeWZvLGY8)zz46jvlqpuC4xNIcjYbj7hiKitgKeZeWZvLGY8)zz46jvlqpuC4xNIcjsdjlcesKaj80fABwSio8RtrHe5EGKfbcjsGeE6IyEhtJpzjo8RtrHe5EGKfbcjsGe2GeE6c60SLLbmHO4WVoffsK7bsweiKitgKeeK4kalxqNMTSmGjefyP2aKdjScjS2TISebOX1RfDAF5fDVV8BY3(oDlSuBaY7V2T0Opz1T0Dt30tPMWSCtgAAYv41TI344nA3YNpcjs)aj73Tk9JDlD30n9uQjml3KHMMCfEDVV8BVyFNUfwQna59x7wXBC8gTB5ZhHePFGK9xQBPrFYQB1SPLNFdDQwgGEJZs37l)M8QVt3cl1gG8(RDR4noEJ2T85JqI0qYIL6wA0NS6wRhaACDkV79L3pW(oDlSuBaY7V2TI344nA3InijMjGNRkbL5)ZYW1tQwGEO4WVoffsKgswSeKWoKqtgGHUPhhsEhs0DJ34OGFOYdzaMOcat1kWsTbihsKjdsyds0DJ34OGFOYdzaMOcat1koTKcsKjdsqkfRikwp0jltgAAWleJ(KL40skiHvircK4ZhHe5GK9desKaj(8rJNg(GqICpqYBlcesyfsKajSbj80fnBA553qNQLbO34Sio8RtrHezYGeE6I1danUoLlo8RtrHezYGKGGexby5IMnT88BOt1Ya0BCweyP2aKdjsGKGGexby5I1danUoLlWsTbihsyfsKjds85Jgpn8bHePHK9desyhsAJ8ULg9jRUvlJE8rltgA0DJx6BDVV8(l670TWsTbiV)A3kEJJ3ODRyMaEUQeuM)pldxpPAb6HId)6uuirAizXsqc7qcnzag6MECi5Dir3nEJJc(HkpKbyIkamvRal1gGCircKWgKWtx0SPLNFdDQwgGEJZI4WVoffsKjds4Plwpa046uU4WVoffsyTBPrFYQBX1tkdnzaDVV8(V13PBPrFYQBzJhfpPMQTBHLAdqE)1U3xE)9770TWsTbiV)A3sJ(Kv3kQaGrJ(KLbmuVBbgQBk9JDlAdwC8ODVV8(YFFNUfwQna59x7wA0NS6wrfamA0NSmGH6DlWqDtPFSBfoaaE0U39UvZHX8BREFN(Yl670T0Opz1TOm)FwMqeSXuoEDlSuBaY7V29(YV13PBHLAdqE)1Uv8ghVr7wUcWYfT38Z5qtgAOA8MWjIcSuBaY7wA0NS6wT38Z5qtgAOA8MWjIDVV8(9D6wA0NS6wnPpz1TWsTbiV)A37ll)9D6wyP2aK3FTBv6h7w6UPB6PutywUjdnn5k86wA0NS6w6UPB6PutywUjdnn5k86EF5L670TWsTbiV)A3kEJJ3ODlAdcagxVw0PckICtgAI5Dmn(KLrtesK7bs2hsKajbbj4UGzAAqUq3nDtpLAcZYnzOPjxHx3sJ(Kv3IIi3KHMyEhtJpz19(YY7(oDln6twDRnLP8UfwQna59x7EFz5BFNUfwQna59x7wXBC8gTBfeK4kalxSPmLlWsTbihsKaj0geamUETOtfue5Mm0eZ7yA8jlJMiKinKSpKibsccsWDbZ00GCHUB6MEk1eMLBYqttUcVULg9jRUfDt55kJDc8U39Uvmtapxv0(o9Lx03PBHLAdqE)1ULg9jRULUB6MEk1eMLBYqttUcVUv8ghVr7wSbjbbjUcWYfnBA553qNQLbO34SiWsTbihsKjdsIzc45Qs0SPLNFdDQwgGEJZI4WVoffsKgsKFi5DiH2GaGztPocjYKbjbbjXmb8CvjA20YZVHovldqVXzrC4xNIcjScjsGKyMaEUQeuM)pldxpPAb6HId)6uuirAizH8csEhsOniay2uQJqc7qcnzag6MECi5Dir3nEJJc(HkpKbyIkamvR40skircKWtxOTzXI4WVoffsKaj80fX8oMgFYsC4xNIcjsGe2GeE6c60SLLbmHO4WVoffsKjdsccsCfGLlOtZwwgWeIcSuBaYHew7wL(XULUB6MEk1eMLBYqttUcVU3x(T(oDlSuBaY7V2TI344nA3IniXvawUGRNugAYam)HIhlcSuBaYHejqsmtapxvckZ)NLHRNuTa9qbtdKibsIzc45QsW1tkdnzacMgiHvirMmijMjGNRkbL5)ZYW1tQwGEOGPbsKjds85Jgpn8bHePHK9dSBPrFYQB1K(Kv37lVFFNUfwQna59x7wXBC8gTBfZeWZvLGY8)zz46jvlqpuC4xNIcjYbjY3aHezYGeF(OXtdFqirAi5TaHezYGe2Ge2GeBMWqHg9znAyuQG6Auki5bswcsKjdsOjdWq30JdjpqsGqcRqIeiHnijiiXvawUOztlp)g6uTma9gNfbwQna5qImzqsmtapxvIMnT88BOt1Ya0BCweh(1POqcRqIeiHnijiiXvawUGJQVzNaxGLAdqoKitgKeZeWZvLGJQVzNaxC4xNIcjs)ajTroKitgKeeKeZeWZvLGJQVzNaxC4xNIcjScjsGKGGKyMaEUQeuM)pldxpPAb6HId)6uuiH1ULg9jRUfdfnJJFA37ll)9D6wyP2aK3FTBfVXXB0UvqqsmtapxvckZ)NLHRNuTa9qbtt3sJ(Kv3kCo0gKjV79LxQVt3cl1gG8(RDR4noEJ2TccsIzc45Qsqz()SmC9KQfOhkyA6wA0NS6w2Gm5MqMJLU3xwE33PBHLAdqE)1Uv8ghVr7w(8riroiz)a7wA0NS6wF8NhlMm0ayId3Wpu)0U3xw(23PBHLAdqE)1Uv8ghVr7w(8rJNg(GqI0qYBbcjSdjTroKitgK4kalxqZvgFdnue5ubwQna5qIeijMjGNRkbL5)ZYW1tQwGEO4WVoffsK7bsIzc45Qsqz()SmC9KQfOhk4mN6twqI8ajlcSBPrFYQBX1tkdnzaDVV8l23PBHLAdqE)1Uv8ghVr7wnOl46jvlqpuC4xNIcjYKbjSbjbbjXmb8Cvj4O6B2jWfh(1POqImzqsqqIRaSCbhvFZobUal1gGCiHvircKeZeWZvLGY8)zz46jvlqpuC4xNIcjY9ajVyGqIeibPuSIOWgKj3KHgFdnyHFweNwsbjYbjl6wA0NS6w2Gm5Mm04BObl8Zs37llV670TWsTbiV)A3sJ(Kv3QjJsHoD2nYnX83W4Qpzz446jIDR4noEJ2TydsIzc45Qsqz()SmC9KQfOhko8RtrHe5EGK3wcsKjds85Jgpn8bHePFGK9desyfsKajSbjXmb8Cvj4O6B2jWfh(1POqImzqsqqIRaSCbhvFZobUal1gGCiH1UvPFSB1KrPqNo7g5My(ByC1NSmCC9eXU3xErG9D6wyP2aK3FTBPrFYQBDPhpgQJCZ6m5zA4ja0TI344nA3InijMjGNRkbL5)ZYW1tQwGEO4WVoffsK7bsEBjirMmiXNpA80WhesK(bs2pqiHvircKWgKeZeWZvLGJQVzNaxC4xNIcjYKbjbbjUcWYfCu9n7e4cSuBaYHew7wL(XU1LE8yOoYnRZKNPHNaq37lVyrFNUfwQna59x7wA0NS6w0TznEM1yLFZHGj2TI344nA3InijMjGNRkbL5)ZYW1tQwGEO4WVoffsK7bsEBjirMmiXNpA80WhesK(bs2pqiHvircKWgKeZeWZvLGJQVzNaxC4xNIcjYKbjbbjUcWYfCu9n7e4cSuBaYHew7wL(XUfDBwJNznw53CiyIDVV8I3670TWsTbiV)A3sJ(Kv3s3fmtt6y5Msz8bWq7wXBC8gTBXgKeZeWZvLGY8)zz46jvlqpuC4xNIcjY9ajVTeKitgK4ZhnEA4dcjs)aj7hiKWkKibsydsIzc45QsWr13StGlo8RtrHezYGKGGexby5coQ(MDcCbwQna5qcRDRs)y3s3fmtt6y5Msz8bWq7EF5f733PBHLAdqE)1ULg9jRULpCK659nXKJVq3kEJJ3ODl2GKyMaEUQeuM)pldxpPAb6HId)6uuirUhi5TLGezYGeF(OXtdFqir6hiz)aHewHejqcBqsmtapxvcoQ(MDcCXHFDkkKitgKeeK4kalxWr13StGlWsTbihsyTBv6h7w(WrQN33eto(cDVV8c5VVt3cl1gG8(RDln6twDR1JcmzOH659PDR4noEJ2TydsIzc45Qsqz()SmC9KQfOhko8RtrHe5EGK3wcsKjds85Jgpn8bHePFGK9desyfsKajSbjXmb8Cvj4O6B2jWfh(1POqImzqsqqIRaSCbhvFZobUal1gGCiH1UvPFSBTEuGjdnupVpT79LxSuFNUfwQna59x7wXBC8gTBzZegkatiAdYKlOUgLcsKgs2VBPrFYQBTkpaFnoL5qAwAfXU3xEH8UVt3sJ(Kv36MMgaAMYqB0i2TWsTbiV)A37E3I2GfhpAFN(Yl670TWsTbiV)A3kEJJ3ODRyMaEUQeuM)pldxpPAb6HId)6uuir6hiHMmadDtpoK8oKWgKGVagzC04ZhHe2HeD34nok4hQ8qgGjQaWuTItlPGewHejqcBqsqqIRaSCbhvFZobUal1gGCirMmijMjGNRkbhvFZobU4WVoffsK(bsOjdWq30JdjVdj4lGrghn(8riHvircKWgK4kalxqZvgFdnue5ubwQna5qImzqcpDrZMwE(n0PAza6nolId)6uuirMmiHNUy9aqJRt5Id)6uuiH1ULg9jRUftrD1gGgnmemrFYQ79LFRVt3cl1gG8(RDR4noEJ2TydsIzc45Qsqz()SmC9KQfOhko8RtrHePHeF(OXtdDtpoK8oKWgKSeKipqcnzag6MECiHvirMmijMjGNRkbL5)ZYW1tQwGEOGPbsyfsKaj(8rJNg(GqICqsmtapxvckZ)NLHRNuTa9qXHFDkA3sJ(Kv3kQaGrJ(KLbmuVBbgQBk9JDRWbaWJ29(Y733PBHLAdqE)1Uv8ghVr7wR1BuBakyOOHIiVBPrFYQBrrKBYqtmVJPXNS6EFz5VVt3cl1gG8(RDR4noEJ2TccswR3O2auWqrdfroKibsccsAoCTPnYfleuM)pldxpPAb6HqIeiHniXvawUGJQVzNaxGLAdqoKibsIzc45QsWr13StGlo8RtrHePFGe8fWiJJgF(iKibsccs0DJ34OiQ0OYNQ1evG(hNfbwQna5qImzqcBqcnzag6MECirUhizjircKqBqaW461IovqrKBYqtmVJPXNSmAIqI0qYBqImzqcnzag6MECirUhi5nircKqBqaW461IovqrKBYqtmVJPXNSmAIqICpqYBqcRqIeiX1RfDHpF04PHpiKihKi)qc7qc(cyKXrJpFesKaj0geamUETOtfue5Mm0eZ7yA8jlJMiK8ajlGezYGeF(OXtdFqir6hi5fHe2He8fWiJJgF(iK8oKqtgGHUPhhsyTBPrFYQBXuuxTbOrddbt0NS6EF5L670TWsTbiV)A3kEJJ3ODRGGK16nQnafmu0qrKdjsGKywU2ozbjs)ajrL6gF(iKWoKSwVrTbOOr58PA7wA0NS6wmf1vBaA0WqWe9jRU3xwE33PBHLAdqE)1ULg9jRUftrD1gGgnmemrFYQBfVXXB0UvqqYA9g1gGcgkAOiYHejqcBqsqqIRaSCbhvFZobUal1gGCirMmijMjGNRkbhvFZobU4WVoffsKds85Jgpn0n94qImzqcnzag6MECiroizbKWkKibsydsccsCfGLlwpa046uUal1gGCirMmiHMmadDtpoKihKSasyfsKajXSCTDYcsK(bsIk1n(8riHDizTEJAdqrJY5t1cjsGe2GKGGeD34nokIknQ8PAnrfO)XzrGLAdqoKitgKyZegkIknQ8PAnrfO)XzrC4xNIcjYbj(8rJNg6MECiH1UvKLianUETOt7lVO7DVBfoaaE0(o9Lx03PBHLAdqE)1ULg9jRUftrD1gGgnmemrFYQBfVXXB0UvmtapxvcoQ(MDcCXHFDkkKi9dK0g5qY7qYBqIeiH2GaGX1RfDQGIi3KHMyEhtJpzz0eHKhizbKWoKC6Wn4ASCXuRzafEQnafmnqIeijMjGNRkbL5)ZYW1tQwGEO4WVoffsKdsElWUfyk0e5DRfl19(YV13PBHLAdqE)1Uv8ghVr7wUcWYfCu9n7e4cSuBaYHejqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjpqYciHDi50HBW1y5IPwZak8uBakyAGejqcBqcpDH2MflId)6uuirAiHNUqBZIfbN5uFYcsEhscuiFxcsKjds4PlI5Dmn(KL4WVoffsKgs4PlI5Dmn(KLGZCQpzbjVdjbkKVlbjYKbj80f0PzlldycrXHFDkkKinKWtxqNMTSmGjefCMt9jli5DijqH8DjiHvircKeZeWZvLGJQVzNaxC4xNIcjs)ajA0NSeABwSiAJCi5Dir(HejqsmtapxvckZ)NLHRNuTa9qXHFDkkKihK8wGDln6twDROcagn6twgWq9UfyOUP0p2T42MddpKU19(Y733PBHLAdqE)1Uv8ghVr7wUcWYfCu9n7e4cSuBaYHejqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjpqYciHDi50HBW1y5IPwZak8uBakyAGejqsmtapxvckZ)NLHRNuTa9qXHFDkkKi9dKqtgGHUPhhsEhs0Opzj02Syr0g5qc7qIg9jlH2MflI2ihsEhs2hsKajSbj80fABwSio8RtrHePHeE6cTnlweCMt9jli5DizbKitgKWtxeZ7yA8jlXHFDkkKinKWtxeZ7yA8jlbN5uFYcsEhswajYKbj80f0PzlldycrXHFDkkKinKWtxqNMTSmGjefCMt9jli5DizbKWA3sJ(Kv3kQaGrJ(KLbmuVBbgQBk9JDlUT5WWdPBDVVS833PBHLAdqE)1Uv8ghVr7wR1BuBak4PtnmnqIeiHnijMjGNRkbL5)ZYW1tQwGEO4WVoffsK7bs2pqiHDiPnYHezYGKyMaEUQeuM)pldxpPAb6HId)6uuiroizH8hiKWA3sJ(Kv3IJQVzNaV79LxQVt3cl1gG8(RDR4noEJ2TSzcdf)Cn(XYfmnqIeiXMjmuut7MhQaG4WVofTBPrFYQBr3uEUYyNaV79LL39D6wyP2aK3FTBfVXXB0ULntyO4NRXpwUGPbsKajbbjSbjUcWYf0PzlldycrbwQna5qIeiHniP5W1M2ixSqOTzXcKibsAoCTPnYfVj02SybsKajnhU20g5I9fABwSajScjYKbjnhU20g5IfcTnlwGew7wA0NS6wABwS09(YY3(oDlSuBaY7V2TI344nA3YMjmu8Z14hlxW0ajsGKGGe2GKMdxBAJCXcbDA2YYaMqesKajnhU20g5I3e0PzlldycrircK0C4AtBKl2xqNMTSmGjeHew7wA0NS6w0PzlldycXU3x(f770TWsTbiV)A3kEJJ3ODlBMWqXpxJFSCbtdKibsccsAoCTPnYfleX8oMgFYcsKajbbjUcWYfQnnbmoAI5Dmn(KLal1gG8ULg9jRUvmVJPXNS6EFz5vFNUfwQna59x7wXBC8gTBzZegkMcxpUAdqdh)dffuxJsbjYbjlcesKaj(8rJNg(GqI0pqYIa7wA0NS6w8tNYaMqS79LxeyFNUfwQna59x7wXBC8gTB5kalxqNMTSmGjefyP2aKdjsGeBMWqXu46XvBaA44FOOG6AukirUhizPaHe5bsElqi5DiHniH2GaGX1RfDQGIi3KHMyEhtJpzz0eHe5bsoD4gCnwUyQ1mGcp1gGcMgirUhi5niHvircKWtxOTzXI4WVoffsKdswcsEhsOniay2uQJqIeiHNUiM3X04twId)6uuiroiPnYHejqcBqcpDbDA2YYaMquC4xNIcjYbjTroKitgKeeK4kalxqNMTSmGjefyP2aKdjScjsGe2GeoAZegk2uMYfh(1POqICqYsqY7qcTbbaZMsDesKjdsccsCfGLl2uMYfyP2aKdjScjsGKywU2ozbjYbjlbjVdj0geamBk1XULg9jRUf)0PmGje7EF5fl670TWsTbiV)A3kEJJ3ODlxby5Iv34BOzkJ2MflcSuBaYHejqIntyOykC94QnanC8puuqDnkfKi3dKSuGqI8ajVfiK8oKWgKqBqaW461IovqrKBYqtmVJPXNSmAIqI8ajNoCdUglxm1AgqHNAdqbtdKi3dKSpKWkKipqYsqY7qcBqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjYdKC6Wn4ASCXuRzafEQnafmnqYdK8gKWkKibs4Pl02SyrC4xNIcjYbjlbjVdj0geamBk1rircKWtxeZ7yA8jlXHFDkkKihK0g5qIeiHniHJ2mHHInLPCXHFDkkKihKSeK8oKqBqaWSPuhHezYGKGGexby5InLPCbwQna5qcRqIeijMLRTtwqICqYsqY7qcTbbaZMsDSBPrFYQBXpDkdycXU3xEXB9D6wyP2aK3FTBfVXXB0ULRaSCHAttaJJMyEhtJpzjWsTbihsKaj2mHHIPW1JR2a0WX)qrb11OuqICpqYsbcjYdK8wGqY7qcBqcTbbaJRxl6ubfrUjdnX8oMgFYYOjcjYdKC6Wn4ASCXuRzafEQnafmnqICpqI8djScjsGeE6cTnlweh(1POqICqYsqY7qcTbbaZMsDesKajSbjC0MjmuSPmLlo8RtrHe5GKLGK3HeAdcaMnL6iKitgKeeK4kalxSPmLlWsTbihsyfsKajXSCTDYcsKdswcsEhsOniay2uQJDln6twDl(Ptzati29(Yl2VVt3sJ(Kv3AtzkVBHLAdqE)1U3xEH833PBPrFYQBfMrgkYn6UXBC0yJ6VBHLAdqE)1U3xEXs9D6wA0NS6wnm3eYYuTgBGs9UfwQna59x7EF5fY7(oDlSuBaY7V2TI344nA3kiiHNUiMvel)uh5MqG(rJnZvId)6uuircKeeKOrFYseZkILFQJCtiq)OyktiyA38ULg9jRUvmRiw(PoYnHa9JDVV8c5BFNUfwQna59x7wA0NS6w8tNYqtgq3kYseGgxVw0P9Lx0TMYX7yA8U1IUv8ghVr7w(8rJNg(GqI0pqsBK3TIB6uDRfDRPC8oMg30csBf0Tw09(YlEX(oDlSuBaY7V2T0Opz1T4NoLHMmGUvKLianUETOt7lVOBnLJ3X04MjSB5tukQ5WVoL0l1TI344nA3YvawUGUP8CLb)2NgrbwQna5qIeizTEJAdqXxNY1PmuesKajbbjC0Mjmuq3uEUYGF7tJO4WVofTBf30P6wl6wt54DmnUPfK2kOBTO79LxiV670TWsTbiV)A3sJ(Kv3IF6ugAYa6wrwIa0461IoTV8IU1uoEhtJBMWULprPOMd)6usVu3kEJJ3ODlxby5c6MYZvg8BFAefyP2aKdjsGK16nQnafFDkxNYqXUvCtNQBTOBnLJ3X04MwqARGU1IU3x(Ta770TWsTbiV)A3sJ(Kv3IF6ugAYa6wt54DmnE3Ar3kUPt1Tw0TMYX7yACtliTvq3Ar37l)2I(oDlSuBaY7V2T0Opz1TOBkpxzStG3TI344nA3YvawUGUP8CLb)2NgrbwQna5qIeizTEJAdqXxNY1PmuesKajbbjC0Mjmuq3uEUYGF7tJO4WVoffsKajbbjA0NSe0nLNRm2jWftzcbt7M3TISebOX1RfDAF5fDVV8BV13PBHLAdqE)1ULg9jRUfDt55kJDc8Uv8ghVr7wUcWYf0nLNRm43(0ikWsTbihsKajR1BuBak(6uUoLHIDRilraAC9ArN2xEr37l)2(9D6wA0NS6w0nLNRm2jW7wyP2aK3FT7DVBXtN23PV8I(oDlSuBaY7V2TI344nA3INUiM3X04twId)6uuir6hirJ(KLGIi3KHMyEhtJpzjIk1n(8riHDiXNpA80q30JdjSdjYV4ni5DiHnizbKipqIRaSCr8qSzQwdhvFtGLAdqoK8oKeOyXsqcRqIeiH2GaGX1RfDQGIi3KHMyEhtJpzz0eHe5EGK9He2HKthUbxJLlMAndOWtTbOGPbsyhsCfGLlwDJVHMPmABwSiWsTbihsKajbbj80fue5Mm0eZ7yA8jlXHFDkkKibsccs0OpzjOiYnzOjM3X04twIPmHGPDZ7wA0NS6wue5Mm0eZ7yA8jRU3x(T(oDlSuBaY7V2T0Opz1T02SyPBfVXXB0ULRaSCr8qSzQwdhvFtGLAdqoKibs0OpRrdpDH2MflqI0qI8gsKaj(8rJNg(GqICqYIaHejqcBqYHFDkkKi9dK0g5qImzqsmtapxvckZ)NLHRNuTa9qXHFDkkKihKSiqircKWgKC4xNIcjsdjlbjYKbjbbj6UXBCu0Ofh)t0m16mQ(KL40skircKCy4H0n1gGqcRqcRDRilraAC9ArN2xEr37lVFFNUfwQna59x7wA0NS6wABwS0TI344nA3kiiXvawUiEi2mvRHJQVjWsTbihsKajA0N1OHNUqBZIfirAi5fHejqIpF04PHpiKihKSiqircKWgKC4xNIcjs)ajTroKitgKeZeWZvLGY8)zz46jvlqpuC4xNIcjYbjlcesKajSbjh(1POqI0qYsqImzqsqqIUB8ghfnAXX)entToJQpzjoTKcsKajhgEiDtTbiKWkKWA3kYseGgxVw0P9Lx09(YYFFNUfwQna59x7wA0NS6w0PzlldycXUv8ghVr7wSbjA0N1OHNUGonBzzaticjsdjViKipqIRaSCr8qSzQwdhvFtGLAdqoKipqcTbbaJRxl6ubnxz8n0qrKtnAIqcRqIeiXNpA80WhesKdsweiKibsom8q6MAdqircKWgKeeKC4xNIcjsGeAdcagxVw0PckICtgAI5Dmn(KLrtesEGKfqImzqsmtapxvckZ)NLHRNuTa9qXHFDkkKihKqtgGHUPhhsEhs0OpzjykQR2a0OHHGj6twc8fWiJJgF(iKWA3kYseGgxVw0P9Lx09(Yl13PBHLAdqE)1ULg9jRUvmVJPXNS6wXBC8gTBrBqaW461IovqrKBYqtmVJPXNSmAIqI0qY(qc7qYPd3GRXYftTMbu4P2auW0ajSdjUcWYfRUX3qZugTnlweyP2aKdjsGe2GKd)6uuir6hiPnYHezYGKyMaEUQeuM)pldxpPAb6HId)6uuiroizrGqIei5WWdPBQnaHewHejqIRxl6cF(OXtdFqiroizrGDRilraAC9ArN2xEr37E37wkJVLx3YA(VmDV79o]] )


end