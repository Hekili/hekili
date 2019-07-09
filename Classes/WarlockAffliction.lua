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


    spec:RegisterPack( "Affliction", 20190709.1700, [[dueL3bqirjpsPs5scu1MqQgffLtrrAvakVcPywuuDlKsSlu9lLugMsKJPewgGQNHuQPPujUMsQ2MaL8nLkPXHusoNafwNaLY8OiUha7taoOaf1cvQ4HiLumrbkYfrkPKtIusfRuantKsk1nrkPQ2POulvGs1tPWuvI6RiLuP9kYFjAWOCyslMsESqtMWLH2mL6ZIQrRuoTIxlqMTQUnq7wYVLA4c64iLuLLRYZrmDQUos2UsY3bKXRuP68kvTEbQmFrX(bDArA5KHqDmLnWxArWyPDDPGbFXUUG20ErYW3hIjJqngKMJjJsbXKrWST9prF6kzeQ7)wfPLtgKM6IyYyZ9qsW2ARLp(gLfp2GRrgqQx9PR4P2(AKbmUwYWIAENwNkzLmeQJPSb(slcglTRlfm4l21f0g4lsgKqmMYg4bR1tgBJqGvYkziqsmzSBqwWST9prF6cYO1vVVJbbdC3GSn3djbBRTw(4Buw8ydUgzaPE1NUINA7RrgW4AWa3nilqQFpKfmmhYa(slcgqgTazl21GTLwcgimWDdYO1SPvosc2GbUBqgTazbZcbkGmJq8FiJw7ogehg4Ubz0cKfmleOaYcMWvn1bz06R5tKddC3GmAbYc2rWEfkGmxVC0LJnNZHbUBqgTazb7iTEuZHqwWuVmbYOcHSUGmxVC0Hm7(GSGju9nR(DiZmYureYo0(qYgK9D(eHSHazIX2gpSCiBSHmAnbteitpeYedrTEuykhg4Ubz0cKfSJHVgriJGRWtFiZ1lhDUpGO0BPyqilQeKazan(gK5dik9wkgeYmdlbK12qgwXMQC8mLNmcV2EEmzSBqwWST9prF6cYO1vVVJbbdC3GSn3djbBRTw(4Buw8ydUgzaPE1NUINA7RrgW4AWa3nilqQFpKfmmhYa(slcgqgTazl21GTLwcgimWDdYO1SPvosc2GbUBqgTazbZcbkGmJq8FiJw7ogehg4Ubz0cKfmleOaYcMWvn1bz06R5tKddC3GmAbYc2rWEfkGmxVC0LJnNZHbUBqgTazb7iTEuZHqwWuVmbYOcHSUGmxVC0Hm7(GSGju9nR(DiZmYureYo0(qYgK9D(eHSHazIX2gpSCiBSHmAnbteitpeYedrTEuykhg4Ubz0cKfSJHVgriJGRWtFiZ1lhDUpGO0BPyqilQeKazan(gK5dik9wkgeYmdlbK12qgwXMQC8mLddeg4Ubz0AT7yKYrbKzH29HqwSbTuhYSW8PiCilyogXqNazvx0YMEG2upKPrF6IazD975Wa1OpDr4HhgBql1by)kjiyGA0NUi8WdJnOL60ayn7UfWa1OpDr4HhgBql1PbWAkvoiwU6txWa1OpDr4HhgBql1PbWAekqWUKHOdduJ(0fHhEySbTuNgaRLFdyphkBBjrJ3ypr08XgGRpwop)gWEou22sIgVXEIihl16rbmqn6txeE4HXg0sDAaSgP0qYw7sIRobgOg9Plcp8WydAPonawlS9PlyGA0NUi8WdJnOL60ayncIczBlJ9DuH(0L5Jnasi(V01lhDcNGOq22YyFhvOpDj1gdaaTHbQrF6IWdpm2GwQtdG12uQYHbQrF6IWdpm2GwQtdG1iBQObsA1VB(ydilxFSC(Msvohl16rbDsi(V01lhDcNGOq22YyFhvOpDj1gnH2WaHbUBqgTw7ogPCuaz4k82dz(aIqMVHqMg9(GSHaz6kDE16romqn6txeaKq8F53XGGbQrF6IqdG1e4QM6KGA(eHbQrF6IqdG1wP3OwpAEPGiakckjikmFL(uiaxFSCoPbs6BOKGOGWXsTEuqNeI)lD9YrNWjikKTTm23rf6txsTXaaqBAoDesCfwoFQvuFHNA9iNkmtgxFSCozc36s(JnYXsTEuqNeI)lD9YrNWjikKTTm23rf6txbayDAoDesCfwoFQvuFHNA9iNkmtgsi(V01lhDcNGOq22YyFhvOpDfaaAfnNocjUclNp1kQVWtTEKtfcduJ(0fHgaRTsVrTE08sbraHQqmvU5Diac6MVsFkeGg9PloztfnqsR(DoU7yKYrPpGiW0GdVXrEujrvmvUmQVco(EowQ1JcyGA0NUi0ayTv6nQ1JMxkiciufIPYnVdbCibDZxPpfcipkmFSbObhEJJ8OsIQyQCzuFfC89CSuRhf0nZ1hlNloDkjPPEowQ1JImzC9XY5cu9nR(DowQ1Jc6XUFrduXfO6Bw978db1PiMaipkmfgOg9PlcnawBLEJA9O5LcIaa1PCDkjbnFL(uiasi(V01lhDcNGOq22YyFhvOpDj1gnbWcAC9XY5aDJVHYPKAEx75yPwpkOX1hlNRwK(PCug77Oc9PlowQ1JcGbCAmZ1hlNd0n(gkNsQ5DTNJLA9OGURpwoN0aj9nusquq4yPwpkOtcX)LUE5Ot4eefY2wg77Oc9PlP2yaa3uAmZ1hlNtMWTUK)yJCSuRhf0ZY1hlNhpedNkxkq134yPwpkONLRpwoxC6usst9CSuRhfMsZPJqIRWY5tTI6l8uRh5uHWa1OpDrObWAR0BuRhnVuqeGODIKk08v6tHamllxFSCozc36s(JnYXsTEuKjJODozc36s(JnYPcnLUODUM31EoX1yqbayXs0Zs0oxZ7Ap)q7djBQ1J0fTZJ9DuH(0fNkegOg9PlcnawlQ)l1OpDj)H4Mxkici29lAGkcmqn6txeAaSM40PKKM6nFkhVJk0L5FBPpGfMh30PaSW84(4JsxVC0jawy(ydW1lhDUpGO0BPyqtaKhf0jn1ljB6jmzDyGA0NUi0ayTnLQCZhBaKq8FPRxo6eobrHSTLX(oQqF6sQnAcaGtZPJqIRWY5tTI6l8uRh5uHWa1OpDrObWAekqWUKc9ck)1dnFSbiANR5DTN7tmOPYPlANh77Oc9PlUpXGMkNUzwu22Cn6ZkusPeoX1yqawptgst9sYMEcalzkDZYY1hlNhUPL3GsYu5uVEJVNJLA9Oitgr78WnT8gusMkN61B898db1PiMs3SSC9XY5cu9nR(DowQ1JImzID)IgOIlq13S635hcQtrmbqEuKjtwXUFrduXfO6Bw978db1PizYqcX)LUE5Ot4eefY2wg77Oc9PlP2yalO50riXvy58Pwr9fEQ1JCQqtHbQrF6IqdG1eO6Bw97Mp2aID)IgOItOab7sk0lO8xpKFiOofH(k9g16rUODIKkKoje)x66LJoHtquiBBzSVJk0NUKAJawqZPJqIRWY5tTI6l8uRh5uH0nllKqWkI8vdz6s22Yq8SXOpDXbNQp6zPbhEJJCXHQWM6Lr9)PY5NwbLjtS7x0avCcfiyxsHEbL)6H8db1Pibq7LmfgOg9PlcnawZ3qjvz1uLqA3xenFSbyrzBZpmg0JeI0UViYpeuNIaduJ(0fHgaRP5DT384(4JsxVC0jawy(yd4qqDkIjaYJcA0OpDXjBQObsA1VZXDhJuok9beP7dik9wkgmaAfmqn6txeAaSgic23EzBlFQ4iKIdvqI5JnaFartO9sWa1OpDrObWAueuoocAEPGian4iB6PePDxUSTLHnq4z(ydi29lAGkoHceSlPqVGYF9q(HG6uetwSemqn6txeAaSgvrC16rPAB)t0NUmpUp(O01lhDcGfMp2aYk2LR5tx09beLElfdAcaAfmqn6txeAaSM40PKKM6npUp(O01lhDcGfMh1kIVCSb4tmiI8qqDktw38XgGRpwoNSPIgijcADAe5yPwpkOVsVrTEKdQt56uscsxGwu22CYMkAGKiO1PrKFiOofHUaTOST5Knv0ajrqRtJi)qqDkIjaYJcGbCyGA0NUi0aynYMkAGKw97Mh3hFu66LJobWcZhBaU(y5CYMkAGKiO1PrKJLA9OG(k9g16roOoLRtjjiDbArzBZjBQObsIGwNgr(HG6ue6c0IY2Mt2urdKebTonI8db1PiMaa3Dms5O0hqeyaNg)0v4l9bePNLg9PloztfnqsR(D(us7FY3CyGA0NUi0ayTWnT8gusMkN61B89Mh3hFu66LJobWcZhBa(aIbq71P76LJo3hqu6TumyalcwaJeI)l3uIJ0nllKqWkI8vdz6s22Yq8SXOpDXbNQp6zPbhEJJCXHQWM6Lr9)PY5NwbLjtS7x0avCcfiyxsHEbL)6H8db1PibSlRNjtS7x0avCcfiyxsHEbL)6H8db1PiMSyDGrcX)LBkXrtHbQrF6IqdG1OkIRwpkvB7FI(0L5X9XhLUE5OtaSW8XgqwR0BuRh5ueusquqN0uVKSPNaW6Wa1OpDrObWAeefY2wg77Oc9PlZhBaR0BuRh5ueusquqN0uVKSPNaW6Wa1OpDrObWAr9FPg9Pl5pe38sbraI2jWa1OpDrObWARMhLUoLBECF8rPRxo6ealmFSb4digWI1P76LJo3hqu6TumyaawSeDZID)IgOItOab7sk0lO8xpKFiOofjaAVuMmXUFrduXjuGGDjf6fu(RhYpeuNIyYILOlANR5DTNFiOofjaalwIUODESVJk0NU4hcQtrcaWILOBMODozc36s(JnYpeuNIeaGflLjtwU(y5CYeU1L8hBKJLA9OWutHbQrF6IqdG1OiOCCe08sbraAWr20tjs7UCzBldBGWZ8XgGpGOjaOnmqn6txeAaSw4MwEdkjtLt96n(EZhBa(aIMaG2RdduJ(0fHgaRTAEu66uU5JnaFartwSomqn6txeAaSwoLEIrlzBl1GdV23mFSbe7(fnqfNqbc2LuOxq5VEi)qqDkIjlwNUzI25HBA5nOKmvo1R3475hcQtrYKr0oF18O01PC(HG6uKmzYY1hlNhUPL3GsYu5uVEJVNJLA9OGEwU(y58vZJsxNY5yPwpkmntgFarP3sXGMq7LOjpkGbQrF6IqdG1e6fKK0uV5JnGy3VObQ4ekqWUKc9ck)1d5hcQtrmzXs0nt0opCtlVbLKPYPE9gFp)qqDksMmI25RMhLUoLZpeuNIKjtwU(y58WnT8gusMkN61B89CSuRhf0ZY1hlNVAEu66uohl16rHPzY4dik9wkg0eGVen5rrMmKq8FPRxo6eobrHSTLX(oQqF6sQngWcAoDesCfwoFQvuFHNA9iNkegOg9PlcnawZcpcEbnvomqn6txeAaSwu)xQrF6s(dXnVuqeajelbEeyGA0NUi0ayTO(VuJ(0L8hIBEPGia75F8iWaHbQrF6IWJD)IgOIaGIGYXrqZlfebObhztpLiT7YLTTmSbcpZhBaMLLRpwopCtlVbLKPYPE9gFphl16rrMmXUFrduXd30YBqjzQCQxVX3ZpeuNIyYUamsi(VCtjoMjtwXUFrduXd30YBqjzQCQxVX3ZpeuNIyk9y3VObQ4ekqWUKc9ck)1d5hcQtrmzX6aJeI)l3uIJWa1OpDr4XUFrdurObWAHTpDz(ydWmxFSCUqVGKKM6LGdbV9CSuRhf0JD)IgOItOab7sk0lO8xpKtfsp29lAGkUqVGKKM65uHMMjtS7x0avCcfiyxsHEbL)6HCQWmz8beLElfdAcTxcgOg9Plcp29lAGkcnawJIGYXrqI5JnGy3VObQ4ekqWUKc9ck)1d5hcQtrcyxxktgFarP3sXGMa8LYKXmZSOST5A0NvOKsjCIRXGaSEMmKM6LKn9eawYu6MLLRpwopCtlVbLKPYPE9gFphl16rrMmXUFrduXd30YBqjzQCQxVX3ZpeuNIykDZYY1hlNlq13S635yPwpkYKj29lAGkUavFZQFNFiOofXea5rrMmzf7(fnqfxGQVz1VZpeuNIyk9SID)IgOItOab7sk0lO8xpKFiOofXuyGA0NUi8y3VObQi0ayn75qRVBH5JnGSID)IgOItOab7sk0lO8xpKtfcduJ(0fHh7(fnqfHgaRz9DlK2u3EZhBazf7(fnqfNqbc2LuOxq5VEiNkegOg9Plcp29lAGkcnawdeb7BVSTLpvCesXHkiX8XgGpGya0EjyGA0NUi8y3VObQi0aynRVBHSTL(gkXcb3dduJ(0fHh7(fnqfHgaRbuFVyfoL8qsxAfrZhBawu228FSrRVBbN4AmitOnmqn6txeES7x0aveAaS2nHHpkNssc1icdegOg9Plcxyjp0(qYgaYeU1L8hB08FkugfawSU5JnaZeTZjt4wxYFSr(HG6uKGx0oNmHBDj)Xg5cQt9PltnbGzI25AEx75hcQtrcEr7CnVR9Cb1P(0LP0nt0oNmHBDj)Xg5hcQtrcEr7CYeU1L8hBKlOo1NUm1eaMjANh77Oc9Pl(HG6uKGx0op23rf6txCb1P(0LP0fTZjt4wxYFSr(HG6ueteTZjt4wxYFSrUG6uF6cyl40ggOg9Plcxyjp0(qYgnawtZ7AV5)uOmkaSyDZhBaMjANR5DTNFiOofj4fTZ18U2ZfuN6txMAcaZeTZJ9DuH(0f)qqDksWlANh77Oc9PlUG6uF6Yu6MjANR5DTNFiOofj4fTZ18U2ZfuN6txMAcaZeTZjt4wxYFSr(HG6uKGx0oNmHBDj)Xg5cQt9PltPlANR5DTNFiOofXer7CnVR9Cb1P(0fWwWPnmqn6txeUWsEO9HKnAaSwSVJk0NUm)NcLrbGfRB(ydWmr78yFhvOpDXpeuNIe8I25X(oQqF6IlOo1NUm1eaMjANR5DTNFiOofj4fTZ18U2ZfuN6txMs3mr78yFhvOpDXpeuNIe8I25X(oQqF6IlOo1NUm1eaMjANtMWTUK)yJ8db1PibVODozc36s(JnYfuN6txMsx0op23rf6tx8db1PiMiANh77Oc9PlUG6uF6cyl40ggimqn6txeUODcacIczBlJ9DuH(0L5Jnar78yFhvOpDXpeuNIycan6txCcIczBlJ9DuH(0fpQex6disJpGO0Bjztpbn7ch4aZSf0IRpwopEigovUuGQVXXsTEuaSL4lw3u6Kq8FPRxo6eobrHSTLX(oQqF6sQngaaAtZPJqIRWY5tTI6l8uRh5uH046JLZb6gFdLtj18U2ZXsTEuqplr7CcIczBlJ9DuH(0f)qqDkc9S0OpDXjikKTTm23rf6tx8PK2)KV5Wa1OpDr4I2j0aynnVR9Mh3hFu66LJobWcZhBaU(y584Hy4u5sbQ(ghl16rbDn6ZkukANR5DT3KGfDxVC05(aIsVLIbdyXs0n7qqDkIjaYJImzID)IgOItOab7sk0lO8xpKFiOofjGflr3Sdb1PiMSEMmzPbhEJJ8qTei4eLtTQJQpDXpTcI(H2hs2uRhn1uyGA0NUiCr7eAaSMM31EZJ7JpkD9YrNayH5JnGSC9XY5XdXWPYLcu9nowQ1Jc6A0NvOu0oxZ7AVj0k6UE5OZ9beLElfdgWILOB2HG6uetaKhfzYe7(fnqfNqbc2LuOxq5VEi)qqDksalwIUzhcQtrmz9mzYsdo8gh5HAjqWjkNAvhvF6IFAfe9dTpKSPwpAQPWa1OpDr4I2j0aynYeU1L8hB084(4JsxVC0jawy(ydWmn6ZkukANtMWTUK)yJMqROfxFSCE8qmCQCPavFJJLA9OGwiH4)sxVC0jCsdK03qjbrbrQnAkDxVC05(aIsVLIbdyXs0p0(qYMA9iDZY6qqDkcDsi(V01lhDcNGOq22YyFhvOpDj1gbSitMy3VObQ4ekqWUKc9ck)1d5hcQtrcG0uVKSPNayA0NU4ufXvRhLQT9prF6IJ7ogPCu6diAkmqn6txeUODcnawl23rf6txMh3hFu66LJobWcZhBaKq8FPRxo6eobrHSTLX(oQqF6sQnAcTP50riXvy58Pwr9fEQ1JCQqAC9XY5aDJVHYPKAEx75yPwpkOB2HG6uetaKhfzYe7(fnqfNqbc2LuOxq5VEi)qqDksalwI(H2hs2uRhnLURxo6CFarP3sXGbSyjyGWa1OpDr42Z)4raqvexTEuQ22)e9PlZ)PqzuayX6Mp2aID)IgOIlq13S635hcQtrmbqEuamGtNeI)lD9YrNWjikKTTm23rf6txsTralO50riXvy58Pwr9fEQ1JCQq6XUFrduXjuGGDjf6fu(RhYpeuNIeaWxcgOg9Plc3E(hpcnawlQ)l1OpDj)H4Mxkicqyjp0(qYM5JnaxFSCUavFZQFNJLA9OGoje)x66LJoHtquiBBzSVJk0NUKAJawqZPJqIRWY5tTI6l8uRh5uH0nt0oxZ7Ap)qqDkIjI25AEx75cQt9PlGTeFxxptgr78yFhvOpDXpeuNIyIODESVJk0NU4cQt9PlGTeFxxptgr7CYeU1L8hBKFiOofXer7CYeU1L8hBKlOo1NUa2s8DDDtPh7(fnqfxGQVz1VZpeuNIycan6txCnVR988Oay7c9y3VObQ4ekqWUKc9ck)1d5hcQtrca4lbduJ(0fHBp)JhHgaRf1)LA0NUK)qCZlfebiSKhAFizZ8XgGRpwoxGQVz1VZXsTEuqNeI)lD9YrNWjikKTTm23rf6txsTralO50riXvy58Pwr9fEQ1JCQq6XUFrduXjuGGDjf6fu(RhYpeuNIycast9sYMEcGPrF6IR5DTNNhf0OrF6IR5DTNNhfaJ20nt0oxZ7Ap)qqDkIjI25AEx75cQt9PlGTitgr78yFhvOpDXpeuNIyIODESVJk0NU4cQt9PlGTitgr7CYeU1L8hBKFiOofXer7CYeU1L8hBKlOo1NUa2ctHbQrF6IWTN)XJqdG1eO6Bw97Mp2aID)IgOItOab7sk0lO8xpKFiOofjaa0EjAYJImzID)IgOItOab7sk0lO8xpKFiOofjGf7YsWa1OpDr42Z)4rObWAKnv0ajT63nFSbyrzBZb7viiwoNkKUfLTnVM8n3w)NFiOofbgOg9Plc3E(hpcnawtZ7AV5JnalkBBoyVcbXY5uH0ZYmxFSCozc36s(JnYXsTEuq3SWdxjZJc(cUM31E6HhUsMhfCGZ18U2tp8WvY8OGtBUM31EtZKj8WvY8OGVGR5DT3uyGA0NUiC75F8i0aynYeU1L8hB08XgGfLTnhSxHGy5CQq6zzw4HRK5rbFbNmHBDj)XgPhE4kzEuWboNmHBDj)XgPhE4kzEuWPnNmHBDj)XgnfgOg9Plc3E(hpcnawl23rf6txMp2aSOST5G9keelNtfspRWdxjZJc(cESVJk0NUONLRpwoxTi9t5Om23rf6txCSuRhfWa1OpDr42Z)4rObWAItNs(JnA(ydWIY2MpfUAC16rPabhcYjUgdkGflr31lhDUpGO0BPyqtaSyjyGA0NUiC75F8i0aynXPtj)XgnFSb46JLZjt4wxYFSrowQ1Jc6wu228PWvJRwpkfi4qqoX1yqbay9LOfGVeWmJeI)lD9YrNWjikKTTm23rf6txsTrA50riXvy58Pwr9fEQ1JCQWaaaCtPlANR5DTNFiOofjG1bgje)xUPehPlANh77Oc9Pl(HG6uKaYJc6MjANtMWTUK)yJ8db1PibKhfzYKLRpwoNmHBDj)Xg5yPwpkmLUzc0IY2MVPuLZpeuNIeW6aJeI)l3uIJzYKLRpwoFtPkNJLA9OWu6XUCnF6kG1bgje)xUPehHbQrF6IWTN)XJqdG1eNoL8hB08XgGRpwohOB8nuoLuZ7Aphl16rbDlkBB(u4QXvRhLceCiiN4AmOaaS(s0cWxcyMrcX)LUE5Ot4eefY2wg77Oc9PlP2iTC6iK4kSC(uRO(cp16rovyaaOTP0Y6aZmsi(V01lhDcNGOq22YyFhvOpDj1gPLthHexHLZNAf1x4PwpYPcbaCtPlANR5DTNFiOofjG1bgje)xUPehPlANh77Oc9Pl(HG6uKaYJc6MjqlkBB(Msvo)qqDksaRdmsi(VCtjoMjtwU(y58nLQCowQ1JctPh7Y18PRawhyKq8F5MsCegOg9Plc3E(hpcnawtC6uYFSrZhBaU(y5C1I0pLJYyFhvOpDXXsTEuq3IY2MpfUAC16rPabhcYjUgdkaaRVeTa8LaMzKq8FPRxo6eobrHSTLX(oQqF6sQnslNocjUclNp1kQVWtTEKtfgaGDXu6I25AEx75hcQtrcyDGrcX)LBkXr6MjqlkBB(Msvo)qqDksaRdmsi(VCtjoMjtwU(y58nLQCowQ1JctPh7Y18PRawhyKq8F5MsCegOg9Plc3E(hpcnawBtPkhgOg9Plc3E(hpcnawZUJueui1GdVXrPfQGWa1OpDr42Z)4rObWAHu3yVFQCP1RehgOg9Plc3E(hpcnawl2vel)uhfs7xbrZhBazjANh7kILFQJcP9RGO0I6k(HG6ue6zPrF6Ih7kILFQJcP9RGiFkP9p5Bomqn6txeU98pEeAaSM40PKKM6nFkhVJk0L5FBPpGfMh30PaSW8PC8oQqhWcZJ7JpkD9YrNayH5JnaxVC05(aIsVLIbnbqEuaduJ(0fHBp)JhHgaRjoDkjPPEZJ7JpkD9YrNayH5XnDkalmFkhVJk0LJnaFIbrKhcQtzY6MpLJ3rf6Y8VT0hWcZhBaU(y5CYMkAGKiO1PrKJLA9OG(k9g16roOoLRtjji9SeOfLTnNSPIgijcADAe5hcQtrGbQrF6IWTN)XJqdG1eNoLK0uV5X9XhLUE5OtaSW84MofGfMpLJ3rf6YXgGpXGiYdb1PmzDZNYX7OcDz(3w6dyH5JnaxFSCoztfnqse060iYXsTEuqFLEJA9ihuNY1PKeegOg9Plc3E(hpcnawtC6usst9MpLJ3rf6Y8VT0hWcZJB6uawy(uoEhvOdybmqn6txeU98pEeAaSgztfnqsR(DZJ7JpkD9YrNayH5JnaxFSCoztfnqse060iYXsTEuqFLEJA9ihuNY1PKeKEwc0IY2Mt2urdKebTonI8db1Pi0ZsJ(0fNSPIgiPv)oFkP9p5Bomqn6txeU98pEeAaSgztfnqsR(DZJ7JpkD9YrNayH5JnaxFSCoztfnqse060iYXsTEuqFLEJA9ihuNY1PKeegOg9Plc3E(hpcnawJSPIgiPv)omqyGA0NUiCsiwc8iaOkIRwpkvB7FI(0L5JnGy3VObQ4ekqWUKc9ck)1d5hcQtrmbaPPEjztpbWmd3Dms5O0hqKgn4WBCKlouf2uVmQ)pvo)0kitPBwwU(y5CbQ(Mv)ohl16rrMmXUFrduXfO6Bw978db1PiMaG0uVKSPNay4UJrkhL(aIMcduJ(0fHtcXsGhHgaRf1)LA0NUK)qCZlfebyp)JhX8XgGzXUFrduXjuGGDjf6fu(RhYpeuNIyIpGO0BjztpbWmlyrlKM6LKn9eMMjtS7x0avCcfiyxsHEbL)6HCQqtP7dik9wkgmGy3VObQ4ekqWUKc9ck)1d5hcQtrGbQrF6IWjHyjWJqdG1iikKTTm23rf6txMp2awP3OwpYPiOKGOagOg9PlcNeILapcnawJQiUA9OuTT)j6txMp2aYALEJA9iNIGscIc6zfE4kzEuWxWjuGGDjf6fu(Rhs3mxFSCUavFZQFNJLA9OGES7x0avCbQ(Mv)o)qqDkIjaWDhJuok9bePNLgC4noYJkjQIPYLr9vWX3ZXsTEuKjJzKM6LKn9ebayD6Kq8FPRxo6eobrHSTLX(oQqF6sQnAcWZKH0uVKSPNiaaaNoje)x66LJoHtquiBBzSVJk0NUKAJbaa4Ms31lhDUpGO0BPyWa2fAWDhJuok9bePtcX)LUE5Ot4eefY2wg77Oc9PlP2iGfzY46LJo3hqu6TumOjaOv0G7ogPCu6dicmst9sYMEctHbQrF6IWjHyjWJqdG1OkIRwpkvB7FI(0L5JnGSwP3OwpYPiOKGOGESlxZNUmbqujU0hqKMv6nQ1J8qviMkhgOg9PlcNeILapcnawJQiUA9OuTT)j6txMh3hFu66LJobWcZhBazTsVrTEKtrqjbrbDZYY1hlNlq13S635yPwpkYKj29lAGkUavFZQFNFiOofjaFarP3sYMEImzin1ljB6jcyHP0nllxFSC(Q5rPRt5CSuRhfzYqAQxs20teWctPh7Y18PltaevIl9bePzLEJA9ipufIPYPBwwAWH34ipQKOkMkxg1xbhFphl16rrMmwu228OsIQyQCzuFfC898db1Pib4dik9ws20tyAYyfEKPRu2aFPfbJLO9sbdoWxq71tgaPxnvojzqRdyyFokGSDfY0OpDbz)qCchgyYqP8T(sggdiTMKXpeNKwoziSKhAFizlTCk7fPLtgyPwpks7Km0OpDLmit4wxYFSXKr8ghVrtgMbzI25KjCRl5p2i)qqDkcKf8qMODozc36s(JnYfuN6txqMPqMjaGmZGmr7CnVR98db1PiqwWdzI25AEx75cQt9PliZuiJoKzgKjANtMWTUK)yJ8db1PiqwWdzI25KjCRl5p2ixqDQpDbzMczMaaYmdYeTZJ9DuH(0f)qqDkcKf8qMODESVJk0NU4cQt9PliZuiJoKjANtMWTUK)yJ8db1PiqMjqMODozc36s(JnYfuN6txqgWGSfCANm(PqzuKmwSEYtzd80YjdSuRhfPDsgA0NUsgAEx7tgXBC8gnzygKjANR5DTNFiOofbYcEit0oxZ7ApxqDQpDbzMczMaaYmdYeTZJ9DuH(0f)qqDkcKf8qMODESVJk0NU4cQt9PliZuiJoKzgKjANR5DTNFiOofbYcEit0oxZ7ApxqDQpDbzMczMaaYmdYeTZjt4wxYFSr(HG6ueil4Hmr7CYeU1L8hBKlOo1NUGmtHm6qMODUM31E(HG6ueiZeit0oxZ7ApxqDQpDbzadYwWPDY4NcLrrYyX6jpLnTtlNmWsTEuK2jzOrF6kze77Oc9PRKr8ghVrtgMbzI25X(oQqF6IFiOofbYcEit0op23rf6txCb1P(0fKzkKzcaiZmit0oxZ7Ap)qqDkcKf8qMODUM31EUG6uF6cYmfYOdzMbzI25X(oQqF6IFiOofbYcEit0op23rf6txCb1P(0fKzkKzcaiZmit0oNmHBDj)Xg5hcQtrGSGhYeTZjt4wxYFSrUG6uF6cYmfYOdzI25X(oQqF6IFiOofbYmbYeTZJ9DuH(0fxqDQpDbzadYwWPDY4NcLrrYyX6jp5jdbARuVNwoL9I0Yjdn6txjdsi(V87yqjdSuRhfPDsEkBGNwozOrF6kziWvn1jb18jMmWsTEuK2j5PSPDA5KbwQ1JI0ojJomzqqpzOrF6kzSsVrTEmzSsFkmz46JLZjnqsFdLeefeowQ1JciJoKrcX)LUE5Ot4eefY2wg77Oc9PlP2iKfaaiJ2qgnq2PJqIRWY5tTI6l8uRh5uHqwMmqMRpwoNmHBDj)Xg5yPwpkGm6qgje)x66LJoHtquiBBzSVJk0NUGSaaazRdz0azNocjUclNp1kQVWtTEKtfczzYazKq8FPRxo6eobrHSTLX(oQqF6cYcaaKrRGmAGSthHexHLZNAf1x4PwpYPctgR0twkiMmOiOKGOi5PS3L0YjdSuRhfPDsgDyYGGEYqJ(0vYyLEJA9yYyL(uyYqJ(0fNSPIgiPv)oh3Dms5O0hqeYagKPbhEJJ8OsIQyQCzuFfC89CSuRhfjJv6jlfetgHQqmvEYtzVEA5KbwQ1JI0ojJomzCib9KHg9PRKXk9g16XKXk9PWKrEuKmI344nAYqdo8gh5rLevXu5YO(k4475yPwpkGm6qMzqMRpwoxC6usst9CSuRhfqwMmqMRpwoxGQVz1VZXsTEuaz0HSy3VObQ4cu9nR(D(HG6ueiZeaqwEuazMMmwPNSuqmzeQcXu5jpLDWkTCYal16rrANKrhMmiONm0OpDLmwP3OwpMmwPpfMmiH4)sxVC0jCcIczBlJ9DuH(0LuBeYmbaKTaYObYC9XY5aDJVHYPKAEx75yPwpkGmAGmxFSCUAr6NYrzSVJk0NU4yPwpkGmGbzahYObYmdYC9XY5aDJVHYPKAEx75yPwpkGm6qMRpwoN0aj9nusquq4yPwpkGm6qgje)x66LJoHtquiBBzSVJk0NUKAJqwaqgWHmtHmAGmZGmxFSCozc36s(JnYXsTEuaz0HSSGmxFSCE8qmCQCPavFJJLA9OaYOdzzbzU(y5CXPtjjn1ZXsTEuazMcz0azNocjUclNp1kQVWtTEKtfMmwPNSuqmzaQt56uscM8u27AA5KbwQ1JI0ojJomzqqpzOrF6kzSsVrTEmzSsFkmzygKLfK56JLZjt4wxYFSrowQ1Jciltgit0oNmHBDj)Xg5uHqMPqgDit0oxZ7ApN4Amiilaaq2ILGm6qwwqMODUM31E(H2hs2uRhHm6qMODESVJk0NU4uHjJv6jlfetgI2jsQWKNYMwLwozGLA9OiTtYqJ(0vYiQ)l1OpDj)H4jJFiUSuqmze7(fnqfj5PSdgPLtgyPwpks7Km0OpDLmeNoLK0uFYiUp(O01lhDsk7fjJ4noEJMmC9YrN7dik9wkgeYmbaKLhfqgDiJ0uVKSPNaYmbYwpze30Psglsgt54DuHUm)Bl9tglsEk7flLwozGLA9OiTtYiEJJ3Ojdsi(V01lhDcNGOq22YyFhvOpDj1gHmtaazahYObYoDesCfwoFQvuFHNA9iNkmzOrF6kzSPuLN8u2lwKwozGLA9OiTtYiEJJ3Ojdr7CnVR9CFIbnvoKrhYeTZJ9DuH(0f3NyqtLdz0HmZGmlkBBUg9zfkPucN4AmiidaKToKLjdKrAQxs20tazaGSLGmtHm6qMzqwwqMRpwopCtlVbLKPYPE9gFphl16rbKLjdKjANhUPL3GsYu5uVEJVNFiOofbYmfYOdzMbzzbzU(y5CbQ(Mv)ohl16rbKLjdKf7(fnqfxGQVz1VZpeuNIazMaaYYJciltgillil29lAGkUavFZQFNFiOofbYYKbYiH4)sxVC0jCcIczBlJ9DuH(0LuBeYcaYwaz0azNocjUclNp1kQVWtTEKtfczMMm0OpDLmiuGGDjf6fu(RhM8u2laEA5KbwQ1JI0ojJ4noEJMmID)IgOItOab7sk0lO8xpKFiOofbYOdzR0BuRh5I2jsQqiJoKrcX)LUE5Ot4eefY2wg77Oc9PlP2iKbaYwaz0azNocjUclNp1kQVWtTEKtfcz0HmZGSSGmKqWkI8vdz6s22Yq8SXOpDXbNQpiJoKLfKPbhEJJCXHQWM6Lr9)PY5NwbbzzYazXUFrduXjuGGDjf6fu(RhYpeuNIazbaz0EjiZ0KHg9PRKHavFZQFp5PSxq70YjdSuRhfPDsgXBC8gnzyrzBZpmg0JeI0UViYpeuNIKm0OpDLm8nusvwnvjK29fXKNYEXUKwozGLA9OiTtYqJ(0vYqZ7AFYiEJJ3OjJdb1PiqMjaGS8OaYObY0OpDXjBQObsA1VZXDhJuok9beHm6qMpGO0BPyqilaiJwLmI7JpkD9YrNKYErYtzVy90YjdSuRhfPDsgXBC8gnz4diczMaz0EPKHg9PRKbic23EzBlFQ4iKIdvqsYtzViyLwozGLA9OiTtYqJ(0vYGIGYXrWKr8ghVrtgXUFrduXjuGGDjf6fu(RhYpeuNIazMazlwkzukiMm0GJSPNsK2D5Y2wg2aHxYtzVyxtlNmWsTEuK2jzOrF6kzqvexTEuQ22)e9PRKr8ghVrtgzbzXUCnF6cYOdz(aIsVLIbHmtaaz0QKrCF8rPRxo6Ku2lsEk7f0Q0YjdSuRhfPDsgA0NUsgItNssAQpze3hFu66LJojL9IKruRi(YXoz4tmiI8qqDktwpzeVXXB0KHRpwoNSPIgijcADAe5yPwpkGm6q2k9g16roOoLRtjjiKrhYeOfLTnNSPIgijcADAe5hcQtrGm6qMaTOST5Knv0ajrqRtJi)qqDkcKzcailpkGmGbzap5PSxemslNmWsTEuK2jzOrF6kzq2urdK0QFpzeVXXB0KHRpwoNSPIgijcADAe5yPwpkGm6q2k9g16roOoLRtjjiKrhYeOfLTnNSPIgijcADAe5hcQtrGm6qMaTOST5Knv0ajrqRtJi)qqDkcKzcaid3Dms5O0hqeYagKbCiJgiZpDf(sFariJoKLfKPrF6It2urdK0QFNpL0(N8npze3hFu66LJojL9IKNYg4lLwozGLA9OiTtYqJ(0vYiCtlVbLKPYPE9gFFYiEJJ3OjdFarilaiJ2Rdz0HmxVC05(aIsVLIbHSaGSfblidyqgje)xUPehHm6qMzqwwqgsiyfr(QHmDjBBziE2y0NU4Gt1hKrhYYcY0GdVXrU4qvyt9YO()u58tRGGSmzGSy3VObQ4ekqWUKc9ck)1d5hcQtrGSaGSDzDiltgil29lAGkoHceSlPqVGYF9q(HG6ueiZeiBX6qgWGmsi(VCtjoczMMmI7JpkD9YrNKYErYtzd8fPLtgyPwpks7Km0OpDLmOkIRwpkvB7FI(0vYiEJJ3OjJSGSv6nQ1JCkckjikGm6qgPPEjztpbKbaYwpze3hFu66LJojL9IKNYg4apTCYal16rrANKr8ghVrtgR0BuRh5ueusquaz0Hmst9sYMEcidaKTEYqJ(0vYGGOq22YyFhvOpDL8u2aN2PLtgyPwpks7Km0OpDLmI6)sn6txYFiEY4hIllfetgI2jjpLnW3L0YjdSuRhfPDsgA0NUsgRMhLUoLNmI344nAYWhqeYcaYwSoKrhYC9YrN7dik9wkgeYcaaKTyjiJoKzgKf7(fnqfNqbc2LuOxq5VEi)qqDkcKfaKr7LGSmzGSy3VObQ4ekqWUKc9ck)1d5hcQtrGmtGSflbz0Hmr7CnVR98db1PiqwaaGSflbz0Hmr78yFhvOpDXpeuNIazbaaYwSeKrhYmdYeTZjt4wxYFSr(HG6ueilaaq2ILGSmzGSSGmxFSCozc36s(JnYXsTEuazMczMMmI7JpkD9YrNKYErYtzd81tlNmWsTEuK2jzOrF6kzqrq54iyYiEJJ3OjdFariZeaqgTtgLcIjdn4iB6PePDxUSTLHnq4L8u2apyLwozGLA9OiTtYiEJJ3OjdFariZeaqgTxpzOrF6kzeUPL3GsYu5uVEJVp5PSb(UMwozGLA9OiTtYiEJJ3OjdFariZeiBX6jdn6txjJvZJsxNYtEkBGtRslNmWsTEuK2jzeVXXB0KrS7x0avCcfiyxsHEbL)6H8db1PiqMjq2I1Hm6qMzqMODE4MwEdkjtLt96n(E(HG6ueiltgit0oF18O01PC(HG6ueiltgilliZ1hlNhUPL3GsYu5uVEJVNJLA9OaYOdzzbzU(y58vZJsxNY5yPwpkGmtHSmzGmFarP3sXGqMjqgTxcYObYYJIKHg9PRKroLEIrlzBl1GdV23sEkBGhmslNmWsTEuK2jzeVXXB0KrS7x0avCcfiyxsHEbL)6H8db1PiqMjq2ILGm6qMzqMODE4MwEdkjtLt96n(E(HG6ueiltgit0oF18O01PC(HG6ueiltgilliZ1hlNhUPL3GsYu5uVEJVNJLA9OaYOdzzbzU(y58vZJsxNY5yPwpkGmtHSmzGmFarP3sXGqMjqgWxcYObYYJciltgiJeI)lD9YrNWjikKTTm23rf6txsTrilaiBbKrdKD6iK4kSC(uRO(cp16rovyYqJ(0vYqOxqsst9jpLnTxkTCYqJ(0vYWcpcEbnvEYal16rrANKNYM2lslNmWsTEuK2jzOrF6kze1)LA0NUK)q8KXpexwkiMmiHyjWJK8u20g4PLtgyPwpks7Km0OpDLmI6)sn6txYFiEY4hIllfetg2Z)4rsEYtgHhgBql1tlNYErA5KbwQ1JI0ojpLnWtlNmWsTEuK2j5PSPDA5KbwQ1JI0ojpL9UKwozOrF6kzqOab7sAJ)gv54LmWsTEuK2j5PSxpTCYal16rrANKr8ghVrtgU(y588Ba75qzBljA8g7jICSuRhfjdn6txjJ8Ba75qzBljA8g7jIjpLDWkTCYal16rrANKNYExtlNm0OpDLmcBF6kzGLA9OiTtYtztRslNmWsTEuK2jzeVXXB0Kbje)x66LJoHtquiBBzSVJk0NUKAJqwaaGmANm0OpDLmiikKTTm23rf6txjpLDWiTCYqJ(0vYytPkpzGLA9OiTtYtzVyP0YjdSuRhfPDsgXBC8gnzKfK56JLZ3uQY5yPwpkGm6qgje)x66LJoHtquiBBzSVJk0NUKAJqMjqgTtgA0NUsgKnv0ajT63tEYtgXUFrdurslNYErA5KbwQ1JI0ojdn6txjdkckhhbtgXBC8gnzygKLfK56JLZd30YBqjzQCQxVX3ZXsTEuazzYazXUFrduXd30YBqjzQCQxVX3ZpeuNIazMaz7cKbmiJeI)l3uIJqwMmqwwqwS7x0av8WnT8gusMkN61B898db1PiqMPqgDil29lAGkoHceSlPqVGYF9q(HG6ueiZeiBX6qgWGmsi(VCtjoMmkfetgAWr20tjs7UCzBldBGWl5PSbEA5KbwQ1JI0ojJ4noEJMmmdYC9XY5c9cssAQxcoe82ZXsTEuaz0HSy3VObQ4ekqWUKc9ck)1d5uHqgDil29lAGkUqVGKKM65uHqMPqwMmqwS7x0avCcfiyxsHEbL)6HCQqiltgiZhqu6TumiKzcKr7LsgA0NUsgHTpDL8u20oTCYal16rrANKr8ghVrtgXUFrduXjuGGDjf6fu(RhYpeuNIazbaz76sqwMmqMpGO0BPyqiZeid4lbzzYazMbzMbzwu22Cn6ZkusPeoX1yqqgaiBDiltgiJ0uVKSPNaYaazlbzMcz0HmZGSSGmxFSCE4MwEdkjtLt96n(EowQ1Jciltgil29lAGkE4MwEdkjtLt96n(E(HG6ueiZuiJoKzgKLfK56JLZfO6Bw97CSuRhfqwMmqwS7x0avCbQ(Mv)o)qqDkcKzcailpkGSmzGSSGSy3VObQ4cu9nR(D(HG6ueiZuiJoKLfKf7(fnqfNqbc2LuOxq5VEi)qqDkcKzAYqJ(0vYGIGYXrqsYtzVlPLtgyPwpks7KmI344nAYilil29lAGkoHceSlPqVGYF9qovyYqJ(0vYWEo067wK8u2RNwozGLA9OiTtYiEJJ3OjJSGSy3VObQ4ekqWUKc9ck)1d5uHjdn6txjdRVBH0M62N8u2bR0YjdSuRhfPDsgXBC8gnz4diczbaz0EPKHg9PRKbic23EzBlFQ4iKIdvqsYtzVRPLtgA0NUsgwF3czBl9nuIfcUpzGLA9OiTtYtztRslNmWsTEuK2jzeVXXB0KHfLTn)hB067wWjUgdcYmbYODYqJ(0vYaO(EXkCk5HKU0kIjpLDWiTCYqJ(0vY4MWWhLtjjHAetgyPwpks7K8KNmeTtslNYErA5KbwQ1JI0ojJ4noEJMmeTZJ9DuH(0f)qqDkcKzcaitJ(0fNGOq22YyFhvOpDXJkXL(aIqgnqMpGO0BjztpbKrdKTlCGdzadYmdYwaz0cK56JLZJhIHtLlfO6BCSuRhfqgWGSL4lwhYmfYOdzKq8FPRxo6eobrHSTLX(oQqF6sQnczbaaYOnKrdKD6iK4kSC(uRO(cp16roviKrdK56JLZb6gFdLtj18U2ZXsTEuaz0HSSGmr7CcIczBlJ9DuH(0f)qqDkcKrhYYcY0OpDXjikKTTm23rf6tx8PK2)KV5jdn6txjdcIczBlJ9DuH(0vYtzd80YjdSuRhfPDsgA0NUsgAEx7tgXBC8gnz46JLZJhIHtLlfO6BCSuRhfqgDitJ(ScLI25AEx7HmtGSGfKrhYC9YrN7dik9wkgeYcaYwSeKrhYmdYoeuNIazMaaYYJciltgil29lAGkoHceSlPqVGYF9q(HG6ueilaiBXsqgDiZmi7qqDkcKzcKToKLjdKLfKPbhEJJ8qTei4eLtTQJQpDXpTccYOdzhAFiztTEeYmfYmnze3hFu66LJojL9IKNYM2PLtgyPwpks7Km0OpDLm08U2NmI344nAYiliZ1hlNhpedNkxkq134yPwpkGm6qMg9zfkfTZ18U2dzMaz0kiJoK56LJo3hqu6TumiKfaKTyjiJoKzgKDiOofbYmbaKLhfqwMmqwS7x0avCcfiyxsHEbL)6H8db1Piqwaq2ILGm6qMzq2HG6ueiZeiBDiltgillitdo8gh5HAjqWjkNAvhvF6IFAfeKrhYo0(qYMA9iKzkKzAYiUp(O01lhDsk7fjpL9UKwozGLA9OiTtYqJ(0vYGmHBDj)XgtgXBC8gnzygKPrFwHsr7CYeU1L8hBeYmbYOvqgTazU(y584Hy4u5sbQ(ghl16rbKrlqgje)x66LJoHtAGK(gkjikisTriZuiJoK56LJo3hqu6TumiKfaKTyjiJoKDO9HKn16riJoKzgKLfKDiOofbYOdzKq8FPRxo6eobrHSTLX(oQqF6sQnczaGSfqwMmqwS7x0avCcfiyxsHEbL)6H8db1PiqwaqgPPEjztpbKbmitJ(0fNQiUA9OuTT)j6txCC3XiLJsFariZ0KrCF8rPRxo6Ku2lsEk71tlNmWsTEuK2jzOrF6kze77Oc9PRKr8ghVrtgKq8FPRxo6eobrHSTLX(oQqF6sQnczMaz0gYObYoDesCfwoFQvuFHNA9iNkeYObYC9XY5aDJVHYPKAEx75yPwpkGm6qMzq2HG6ueiZeaqwEuazzYazXUFrduXjuGGDjf6fu(RhYpeuNIazbazlwcYOdzhAFiztTEeYmfYOdzUE5OZ9beLElfdczbazlwkze3hFu66LJojL9IKN8KH98pEK0YPSxKwozGLA9OiTtYqJ(0vYGQiUA9OuTT)j6txjJ4noEJMmID)IgOIlq13S635hcQtrGmtaaz5rbKbmid4qgDiJeI)lD9YrNWjikKTTm23rf6txsTridaKTaYObYoDesCfwoFQvuFHNA9iNkeYOdzXUFrduXjuGGDjf6fu(RhYpeuNIazbazaFPKXpfkJIKXI1tEkBGNwozGLA9OiTtYiEJJ3OjdxFSCUavFZQFNJLA9OaYOdzKq8FPRxo6eobrHSTLX(oQqF6sQnczaGSfqgnq2PJqIRWY5tTI6l8uRh5uHqgDiZmit0oxZ7Ap)qqDkcKzcKjANR5DTNlOo1NUGmGbzlX311HSmzGmr78yFhvOpDXpeuNIazMazI25X(oQqF6IlOo1NUGmGbzlX311HSmzGmr7CYeU1L8hBKFiOofbYmbYeTZjt4wxYFSrUG6uF6cYagKTeFxxhYmfYOdzXUFrduXfO6Bw978db1PiqMjaGmn6txCnVR988OaYagKTlqgDil29lAGkoHceSlPqVGYF9q(HG6ueilaid4lLm0OpDLmI6)sn6txYFiEY4hIllfetgcl5H2hs2sEkBANwozGLA9OiTtYiEJJ3OjdxFSCUavFZQFNJLA9OaYOdzKq8FPRxo6eobrHSTLX(oQqF6sQnczaGSfqgnq2PJqIRWY5tTI6l8uRh5uHqgDil29lAGkoHceSlPqVGYF9q(HG6ueiZeaqgPPEjztpbKbmitJ(0fxZ7ApppkGmAGmn6txCnVR988OaYagKrBiJoKzgKjANR5DTNFiOofbYmbYeTZ18U2ZfuN6txqgWGSfqwMmqMODESVJk0NU4hcQtrGmtGmr78yFhvOpDXfuN6txqgWGSfqwMmqMODozc36s(JnYpeuNIazMazI25KjCRl5p2ixqDQpDbzadYwazMMm0OpDLmI6)sn6txYFiEY4hIllfetgcl5H2hs2sEk7DjTCYal16rrANKr8ghVrtgXUFrduXjuGGDjf6fu(RhYpeuNIazbaaYO9sqgnqwEuazzYazXUFrduXjuGGDjf6fu(RhYpeuNIazbazl2LLsgA0NUsgcu9nR(9KNYE90YjdSuRhfPDsgXBC8gnzyrzBZb7viiwoNkeYOdzwu228AY3CB9F(HG6uKKHg9PRKbztfnqsR(9KNYoyLwozGLA9OiTtYiEJJ3OjdlkBBoyVcbXY5uHqgDilliZmiZ1hlNtMWTUK)yJCSuRhfqgDiZmil8WvY8OGVGR5DThYOdzHhUsMhfCGZ18U2dz0HSWdxjZJcoT5AEx7HmtHSmzGSWdxjZJc(cUM31EiZ0KHg9PRKHM31(KNYExtlNmWsTEuK2jzeVXXB0KHfLTnhSxHGy5CQqiJoKLfKzgKfE4kzEuWxWjt4wxYFSriJoKfE4kzEuWboNmHBDj)XgHm6qw4HRK5rbN2CYeU1L8hBeYmnzOrF6kzqMWTUK)yJjpLnTkTCYal16rrANKr8ghVrtgwu22CWEfcILZPcHm6qwwqw4HRK5rbFbp23rf6txqgDilliZ1hlNRwK(PCug77Oc9PlowQ1JIKHg9PRKrSVJk0NUsEk7GrA5KbwQ1JI0ojJ4noEJMmSOST5tHRgxTEukqWHGCIRXGGSaGSflbz0HmxVC05(aIsVLIbHmtaazlwkzOrF6kzioDk5p2yYtzVyP0YjdSuRhfPDsgXBC8gnz46JLZjt4wxYFSrowQ1JciJoKzrzBZNcxnUA9OuGGdb5exJbbzbaaYwFjiJwGmGVeKbmiZmiJeI)lD9YrNWjikKTTm23rf6txsTriJwGSthHexHLZNAf1x4PwpYPcHSaaazahYmfYOdzI25AEx75hcQtrGSaGS1HmGbzKq8F5MsCeYOdzI25X(oQqF6IFiOofbYcaYYJciJoKzgKjANtMWTUK)yJ8db1PiqwaqwEuazzYazzbzU(y5CYeU1L8hBKJLA9OaYmfYOdzMbzc0IY2MVPuLZpeuNIazbazRdzadYiH4)YnL4iKLjdKLfK56JLZ3uQY5yPwpkGmtHm6qwSlxZNUGSaGS1HmGbzKq8F5MsCmzOrF6kzioDk5p2yYtzVyrA5KbwQ1JI0ojJ4noEJMmC9XY5aDJVHYPKAEx75yPwpkGm6qMfLTnFkC14Q1JsbcoeKtCngeKfaaiB9LGmAbYa(sqgWGmZGmsi(V01lhDcNGOq22YyFhvOpDj1gHmAbYoDesCfwoFQvuFHNA9iNkeYcaaKrBiZuiJwGS1HmGbzMbzKq8FPRxo6eobrHSTLX(oQqF6sQncz0cKD6iK4kSC(uRO(cp16roviKbaYaoKzkKrhYeTZ18U2ZpeuNIazbazRdzadYiH4)YnL4iKrhYeTZJ9DuH(0f)qqDkcKfaKLhfqgDiZmitGwu228nLQC(HG6ueilaiBDidyqgje)xUPehHSmzGSSGmxFSC(Msvohl16rbKzkKrhYID5A(0fKfaKToKbmiJeI)l3uIJjdn6txjdXPtj)XgtEk7fapTCYal16rrANKr8ghVrtgU(y5C1I0pLJYyFhvOpDXXsTEuaz0HmlkBB(u4QXvRhLceCiiN4Amiilaaq26lbz0cKb8LGmGbzMbzKq8FPRxo6eobrHSTLX(oQqF6sQncz0cKD6iK4kSC(uRO(cp16roviKfaaiBxGmtHm6qMODUM31E(HG6ueilaiBDidyqgje)xUPehHm6qMzqMaTOST5Bkv58db1Piqwaq26qgWGmsi(VCtjoczzYazzbzU(y58nLQCowQ1JciZuiJoKf7Y18PlilaiBDidyqgje)xUPehtgA0NUsgItNs(JnM8u2lODA5KHg9PRKXMsvEYal16rrANKNYEXUKwozOrF6kzy3rkckKAWH34O0cvWKbwQ1JI0ojpL9I1tlNm0OpDLmcPUXE)u5sRxjEYal16rrANKNYErWkTCYal16rrANKr8ghVrtgzbzI25XUIy5N6OqA)kikTOUIFiOofbYOdzzbzA0NU4XUIy5N6OqA)kiYNsA)t(MNm0OpDLmIDfXYp1rH0(vqm5PSxSRPLtgyPwpks7Km0OpDLmeNoLK0uFYiUp(O01lhDsk7fjJPC8oQqpzSizeVXXB0KHRxo6CFarP3sXGqMjaGS8Oize30Psglsgt54DuHUm)Bl9tglsEk7f0Q0YjdSuRhfPDsgA0NUsgItNssAQpze3hFu66LJojL9IKXuoEhvOlh7KHpXGiYdb1Pmz9Kr8ghVrtgU(y5CYMkAGKiO1PrKJLA9OaYOdzR0BuRh5G6uUoLKGqgDillitGwu22CYMkAGKiO1PrKFiOofjze30Psglsgt54DuHUm)Bl9tglsEk7fbJ0YjdSuRhfPDsgA0NUsgItNssAQpze3hFu66LJojL9IKXuoEhvOlh7KHpXGiYdb1Pmz9Kr8ghVrtgU(y5CYMkAGKiO1PrKJLA9OaYOdzR0BuRh5G6uUoLKGjJ4MovYyrYykhVJk0L5FBPFYyrYtzd8LslNmWsTEuK2jzOrF6kzioDkjPP(KXuoEhvONmwKmIB6ujJfjJPC8oQqxM)TL(jJfjpLnWxKwozGLA9OiTtYqJ(0vYGSPIgiPv)EYiEJJ3OjdxFSCoztfnqse060iYXsTEuaz0HSv6nQ1JCqDkxNssqiJoKLfKjqlkBBoztfnqse060iYpeuNIaz0HSSGmn6txCYMkAGKw978PK2)KV5jJ4(4JsxVC0jPSxK8u2ah4PLtgyPwpks7Km0OpDLmiBQObsA1VNmI344nAYW1hlNt2urdKebTonICSuRhfqgDiBLEJA9ihuNY1PKemze3hFu66LJojL9IKNYg40oTCYqJ(0vYGSPIgiPv)EYal16rrANKN8KbjelbEK0YPSxKwozGLA9OiTtYiEJJ3OjJy3VObQ4ekqWUKc9ck)1d5hcQtrGmtaazKM6LKn9eqgWGmZGmC3XiLJsFariJgitdo8gh5IdvHn1lJ6)tLZpTccYmfYOdzMbzzbzU(y5CbQ(Mv)ohl16rbKLjdKf7(fnqfxGQVz1VZpeuNIazMaaYin1ljB6jGmGbz4UJrkhL(aIqMPjdn6txjdQI4Q1Js12(NOpDL8u2apTCYal16rrANKr8ghVrtgMbzXUFrduXjuGGDjf6fu(RhYpeuNIazMaz(aIsVLKn9eqgWGmZGSGfKrlqgPPEjztpbKzkKLjdKf7(fnqfNqbc2LuOxq5VEiNkeYmfYOdz(aIsVLIbHSaGSy3VObQ4ekqWUKc9ck)1d5hcQtrsgA0NUsgr9FPg9Pl5pepz8dXLLcIjd75F8ijpLnTtlNmWsTEuK2jzeVXXB0KXk9g16rofbLeefjdn6txjdcIczBlJ9DuH(0vYtzVlPLtgyPwpks7KmI344nAYiliBLEJA9iNIGscIciJoKLfKfE4kzEuWxWjuGGDjf6fu(Rhcz0HmZGmxFSCUavFZQFNJLA9OaYOdzXUFrduXfO6Bw978db1PiqMjaGmC3XiLJsFariJoKLfKPbhEJJ8OsIQyQCzuFfC89CSuRhfqwMmqMzqgPPEjztpbKfaaiBDiJoKrcX)LUE5Ot4eefY2wg77Oc9PlP2iKzcKbCiltgiJ0uVKSPNaYcaaKbCiJoKrcX)LUE5Ot4eefY2wg77Oc9PlP2iKfaaid4qMPqgDiZ1lhDUpGO0BPyqilaiBxGmAGmC3XiLJsFariJoKrcX)LUE5Ot4eefY2wg77Oc9PlP2iKbaYwazzYazUE5OZ9beLElfdczMaaYOvqgnqgU7yKYrPpGiKbmiJ0uVKSPNaYmnzOrF6kzqvexTEuQ22)e9PRKNYE90YjdSuRhfPDsgXBC8gnzKfKTsVrTEKtrqjbrbKrhYID5A(0fKzcailQex6dicz0azR0BuRh5HQqmvEYqJ(0vYGQiUA9OuTT)j6txjpLDWkTCYal16rrANKHg9PRKbvrC16rPAB)t0NUsgXBC8gnzKfKTsVrTEKtrqjbrbKrhYmdYYcYC9XY5cu9nR(DowQ1Jciltgil29lAGkUavFZQFNFiOofbYcaY8beLEljB6jGSmzGmst9sYMEcilaiBbKzkKrhYmdYYcYC9XY5RMhLUoLZXsTEuazzYazKM6LKn9eqwaq2ciZuiJoKf7Y18PliZeaqwujU0hqeYObYwP3OwpYdvHyQCiJoKzgKLfKPbhEJJ8OsIQyQCzuFfC89CSuRhfqwMmqMfLTnpQKOkMkxg1xbhFp)qqDkcKfaK5dik9ws20tazMMmI7JpkD9YrNKYErYtEYtEYtja]] )


end