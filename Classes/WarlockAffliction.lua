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


    spec:RegisterPack( "Affliction", 20190803, [[dCekmcqibYJuksxsvsAtePprukWOqP6uOuwLQuEfkPzja3IOe7IWVukzycOJPewMQu9mLsnnIs11uIABeLuFJOuACQskNJOKSoLIiZJi6EQI9ruCqvjvTqvjEOQKkMirPOlsukOtQuevRuGAMeLc1nvkIIDQezPQsQ0tjLPQu4QkfrPVsukK9kv)LKbJ4WuwmP6XcnzuDzOnlOplLgTs1Pv8AIWSbUTQA3s(TOHlfhxPiSCvEostNQRJITRK67kjJxvsCEuI1RuuZNOA)GUVOVrxJBo2x69axiRc81cCBXIaxoWax01CwAWUwJfLWAXUwzFSR96ddbt0NS6AnglG049n6A0K5IyxB39g6M0wB1o(oJUiM)TOZNby(Kv8SqFl68JB110zgGVjV66DnU5yFP3dCHSkWxlWTflcu2LvYUSQRrBWyFP3L1l312hohRUExJJ0yxBtHKxFyiyI(KfKiBKDGmkbm4nfs2DVHUjT1wTJVZOlI5Fl68zaMpzfpl03Io)4wWG3ui51Z0YqDiz7aGK3dCHScsKfizrGBsBl7WGHbVPqYRZUvTiDtcg8McjYcK865CKdjAniaajYgNrjeWG3uirwGKxpNJCir2exNmhKSjJ1orbm4nfsKfi51f)5AKdjUDTORMqHqadEtHezbsEDXnbZCiKiBMBqHeMgijliXTRfDijmpir2enFxpboKWoDQicjhgEiDhsaz7eHKHcj8jmepSCizcHKxhztkKyhcj8HA6aKZMag8McjYcK86InalIqcfxJNbGe3Uw0f(8rLNk(Gqs0Oifswn(oK4ZhvEQ4dcjSJfhsYqibRyYuoESj6AnxgoaSRTPqYRpmemrFYcsKnYoqgLag8Mcj7U3q3K2AR2X3z0fX8VfD(maZNSINf6BrNFClyWBkK86zAzOoKSDaqY7bUqwbjYcKSiWnPTLDyWWG3ui51z3QwKUjbdEtHezbsE9CoYHeTgeaGezJZOecyWBkKilqYRNZroKiBIRtMds2KXANOag8McjYcK86I)CnYHe3Uw0vtOqiGbVPqISajVU4MGzoesKnZnOqctdKKfK421IoKeMhKiBIMVRNahsyNoveHKddpKUdjGSDIqYqHe(egIhwoKmHqYRJSjfsSdHe(qnDaYztadEtHezbsEDXgGfriHIRXZaqIBxl6cF(OYtfFqijAuKcjRgFhs85Jkpv8bHe2XIdjziKGvmzkhp2eWGHbVPqISHVcgzCKdj6yyEiKeZVU5qIo2ofvajV(yeBCkKuzjl729dzaqIf9jlkKKfGfbm4nfsSOpzrfnhgZVU5pHaJkbm4nfsSOpzrfnhgZVU5S(SvyMCyWBkKyrFYIkAomMFDZz9zlJP9JLB(Kfmyl6twurZHX8RBoRpBrz()SunOdd2I(Kfv0Cym)6MZ6ZwT38Z5qvgQOw8MWjIbmHpUbWYfT38Z5qvgQOw8MWjIcSmDaYHbVPqIf9jlQO5Wy(1nN1NTOL1q3txrDZPWGTOpzrfnhgZVU5S(Svt6twWGTOpzrfnhgZVU5S(SfdfvJJ)ak7Jp2MP72zuvywUkdvn5k8GbBrFYIkAomMFDZz9zlkICvgQI5Dmn(Kvat4dTbbaLBxl6ubfrUkdvX8oMgFYszjkZZ2sdc3emttdYflK1YQTxi7WGTOpzrfnhgZVU5S(S1UXuomyl6twurZHX8RBoRpBr3nEUsPNapGj8ji3ay5IDJPCbwMoa5sPniaOC7ArNkOiYvzOkM3X04twklrj3wAq4MGzAAqUyHSwwT9czhgmm4nfsKn8vWiJJCibxJhlqIpFes8DesSONhKmuiXwBdW0bOagSf9jl6dTbbafiJsad2I(KfL1NT446K5uFRDIWGTOpzrz9zR12nMoadOSp(WqrffrEaRnad(4galxqZvkFhvue5ubwMoa5sPniaOC7ArNkOiYvzOkM3X04twklrzE2M1ZgUcxJLlMAndOWZ0bOGPrUC3ay5c60SNLcmHOalthGCP0geauUDTOtfue5QmufZ7yA8jlzEwM1ZgUcxJLlMAndOWZ0bOGPrUCAdcak3Uw0PckICvgQI5Dmn(KLmpVgRNnCfUglxm1AgqHNPdqbtdmyl6twuwF2ATDJPdWak7JpngNpvBazZdf9awBag8XI(KLGUB8CLspbUaFfmY4OYNp(MTz8ghfrJgn(uTQObS)4SiWY0bihgSf9jlkRpBT2UX0byaL9XNgJZNQnGS55qk6bS2am4tBKhWe(yBgVXrr0OrJpvRkAa7polcSmDaYLYUBaSCb)SPu0KbiWY0bixUC3ay5coA(UEcCbwMoa5sJzc45QsWrZ31tGlo8BtrL8PnYzdgSf9jlkRpBT2UX0byaL9XNVnLBtPOyaRnad(qBqaq521IovqrKRYqvmVJPXNSuwIs(SGv3ay5Iv347OAkL1MflcSmDaYz1nawUW0PjGXrvmVJPXNSeyz6aK)27SYUBaSCXQB8DunLYAZIfbwMoa5sDdGLlO5kLVJkkICQalthGCP0geauUDTOtfue5QmufZ7yA8jlLLOmVZgRS7galxqNM9SuGjefyz6aKlni3ay5I4HyZuTkoA(UalthGCPb5galxWpBkfnzacSmDaYzJ1ZgUcxJLlMAndOWZ0bOGPbgSf9jlkRpBT2UX0byaL9XhE6ufttaRnad(WEqUbWYf0PzplfycrbwMoa5YLZtxqNM9SuGjefmnSjLNUWAZIfb1TOeY8SiqPbXtxyTzXI4WWdP7MoaLYtxeZ7yA8jlbtdmyl6twuwF2kAaGYI(KLcmupGY(4tmtapxvuyWw0NSOS(Sf)SPu0KbeWuoEhtJRAbPUbEweqC3M6zrarwIau521Io9zrat4JpFu5PIpOKpTrUuAYau0D74sUmmyl6twuwF2A3ykpGj8H2GaGYTRfDQGIixLHQyEhtJpzPSeL85DwpB4kCnwUyQ1mGcpthGcMgyWw0NSOS(SfL5)ZsXTtIwGDyat4dpDH1MflcFIsmvRuE6IyEhtJpzj8jkXuTszxNjmuyrFwJkgJkOUfL4zz5YPjdqr3TJ)eiBszpi3ay5IMDR88ROt1YaSBCweyz6aKlxopDrZUvE(v0PAza2nolId)2uu2KYEqUbWYfC08D9e4cSmDaYLlpMjGNRkbhnFxpbU4WVnfvYN2ixU8GIzc45QsWrZ31tGlo8BtrLlN2GaGYTRfDQGIixLHQyEhtJpzPSeLzbRNnCfUglxm1AgqHNPdqbtdBWGTOpzrz9zloA(UEc8aMWNyMaEUQeuM)plf3ojAb2HId)2uuPRTBmDak4PtvmnsPniaOC7ArNkOiYvzOkM3X04twklXNfSE2Wv4ASCXuRzafEMoafmnszpiKsXkII1dDYsLHQg8cXOpzj(tLN0GSnJ34OGFOXdzaQObat1koRKqU8yMaEUQeuM)plf3ojAb2HId)2uuz2oq2GbBrFYIY6Zw(oQyk9KP4QW8Iyat4JotyO4WOeaKsvH5frXHFBkkmyl6twuwF2YAZILaISebOYTRfD6ZIaMWNd)2uujFAJCwTOpzjO7gpxP0tGlWxbJmoQ85Js95Jkpv8bL51GbBrFYIY6ZwF8NhlQmubyIdxXp0(0aMWhF(OKBhim4nfs2a)n5zhlqs48kqINqY3KaHekZHqITz6UDMSbuijmlhs4jslzdCir)qtciHBNeTa7qiHHATOagSf9jlkRpBzTzXsaGPqvK)SDGbmHp(8rz2oqPXmb8CvjOm)FwkUDs0cSdfh(TPOs(SyzP4MGzAAqUyHSwwT9czhgSf9jlkRpBfZ7yA8jRaatHQi)z7adycF85JYSDGsJzc45Qsqz()SuC7KOfyhko8BtrL8zXYsXnbZ00GCXczTSA7fYU0GCdGLlmDAcyCufZ7yA8jlbwMoa5sz3nawUGon7zPatikWY0bixUCAdcak3Uw0PckICvgQI5Dmn(KLYsuMfsPniaOC7ArNkOiYvzOkM3X04twklrjF2MnyWw0NSOS(SfDA2ZsbMqmaWuOkYF2oWaMWhF(OmBhO0yMaEUQeuM)plf3ojAb2HId)2uujFwSSuCtWmnnixSqwlR2EHSdd2I(KfL1NTykQB6auzHHGj6twbezjcqLBxl60NfbmHpbfZYT2jlP(8rLNk(Gs(8AWGTOpzrz9zl(ztPOjdiGilraQC7ArN(SiGOvreOMWhFIsqvh(TPKC5aMWh3ay5c6UXZvk8RFwefyz6aKlDTDJPdqX3MYTPuuukh1zcdf0DJNRu4x)Siko8BtrLYrDMWqbD345kf(1plIId)2uujFAJ83EhgSf9jlkRpBr3nEUsPNapGilraQC7ArN(SiGj8XnawUGUB8CLc)6NfrbwMoa5sxB3y6au8TPCBkffLYrDMWqbD345kf(1plIId)2uuPCuNjmuq3nEUsHF9ZIO4WVnfvYh8vWiJJkF(4BVZQF2AeO85JsdYI(KLGUB8CLspbUykviyA3DyWw0NSOS(SvZUvE(v0PAza2nolbezjcqLBxl60NfbmHp(8rz2EzPUDTOl85Jkpv8bLzHS(nAdcaQDJ6Ou2dcPuSIOy9qNSuzOQbVqm6twI)u5jniBZ4nok4hA8qgGkAaWuTIZkjKlpMjGNRkbL5)ZsXTtIwGDO4WVnfvgzFzwPjdqr3TJ)MTz8ghf8dnEidqfnayQwXzLeYLhZeWZvLGY8)zP42jrlWouC43MIk5ILFJ2GaGA3OoYknzak6UD83SnJ34OGFOXdzaQObat1koRKGnyWw0NSOS(SftrDthGklmemrFYkGilraQC7ArN(SiGj8jO12nMoafmuurrKlLMmafD3o(ZYWGTOpzrz9zlkICvgQI5Dmn(Kvat4ZA7gthGcgkQOiYLstgGIUBh)zzyWw0NSOS(Sv0aaLf9jlfyOEaL9XhE6uyWw0NSOS(S16bGk3MYdiYseGk3Uw0PplcycF85JYSyzPUDTOl85Jkpv8bL5zrGszpMjGNRkbL5)ZsXTtIwGDO4WVnfvMTduU8yMaEUQeuM)plf3ojAb2HId)2uujxeOuE6cRnlweh(TPOY8SiqP80fX8oMgFYsC43MIkZZIaLYopDbDA2ZsbMquC43MIkZZIaLlpi3ay5c60SNLcmHOalthGC2ydgSf9jlkRpBXqr144pGY(4JTz6UDgvfMLRYqvtUcVaMWhF(OKpBdd2I(KfL1NTA2TYZVIovldWUXzjGj8XNpk5Z2ldd2I(KfL1NTwpau52uEat4JpFuYfldd2I(KfL1NTAzSJpwPYqLTz8sFpGj8H9yMaEUQeuM)plf3ojAb2HId)2uujxSmR0KbOO72XFZ2mEJJc(HgpKbOIgamvRalthGC5Yz32mEJJc(HgpKbOIgamvR4Ssc5YrkfRikwp0jlvgQAWleJ(KL4Ssc2K6ZhLz7aL621IUWNpQ8uXhuMN3xeiBszNNUOz3kp)k6uTma7gNfXHFBkQC580fRhaQCBkxC43MIkxEqUbWYfn7w55xrNQLby34SiWY0bixAqUbWYfRhaQCBkxGLPdqoBYL7ZhvEQ4dk52bYABKdd2I(KfL1NT42jHIMmGaMWNyMaEUQeuM)plf3ojAb2HId)2uujxSmR0KbOO72XFZ2mEJJc(HgpKbOIgamvRalthGCPSZtx0SBLNFfDQwgGDJZI4WVnfvUCE6I1davUnLlo8BtrzdgSf9jlkRpBPJhfpjMQfgSf9jlkRpBfnaqzrFYsbgQhqzF8H2Gfhpkmyl6twuwF2kAaGYI(KLcmupGY(4t4aa4rHbdd2I(KfveZeWZvf9HHIQXXFaL9XhBZ0D7mQkmlxLHQMCfEbmHpShKBaSCrZUvE(v0PAza2nolcSmDaYLlpMjGNRkrZUvE(v0PAza2nolId)2uujL93OniaO2nQJYLhumtapxvIMDR88ROt1YaSBCweh(TPOSjnMjGNRkbL5)ZsXTtIwGDO4WVnfvYfYQ3OniaO2nQJSstgGIUBh)nBZ4nok4hA8qgGkAaWuTIZkjKYtxyTzXI4WVnfvkpDrmVJPXNSeh(TPOszNNUGon7zPatiko8BtrLlpi3ay5c60SNLcmHOalthGC2GbBrFYIkIzc45QIY6ZwnPpzfWe(WUBaSCb3oju0KbO(dfpweyz6aKlnMjGNRkbL5)ZsXTtIwGDOGPrAmtapxvcUDsOOjdqW0WMC5Xmb8CvjOm)FwkUDs0cSdfmnYL7ZhvEQ4dk52bcd2I(KfveZeWZvfL1NTyOOAC8tdycFIzc45Qsqz()SuC7KOfyhko8BtrLr2gOC5(8rLNk(Gs(EGYLZo76mHHcl6ZAuXyub1TOepllxonzak6UD8Naztk7b5galx0SBLNFfDQwgGDJZIalthGC5YJzc45Qs0SBLNFfDQwgGDJZI4WVnfLnPShKBaSCbhnFxpbUalthGC5YJzc45QsWrZ31tGlo8BtrL8PnYLlpOyMaEUQeC08D9e4Id)2uu2KgumtapxvckZ)NLIBNeTa7qXHFBkkBWGTOpzrfXmb8Cvrz9zRW5qDqM8aMWNGIzc45Qsqz()SuC7KOfyhkyAGbBrFYIkIzc45QIY6Zw6Gm5QqMJLaMWNGIzc45Qsqz()SuC7KOfyhkyAGbBrFYIkIzc45QIY6ZwF8NhlQmubyIdxXp0(0aMWhF(OmBhimyl6twurmtapxvuwF2IBNekAYacycF85Jkpv8bL89azTnYLlN2GaGYTRfDQGIixLHQyEhtJpzPSeLzbRNnCfUglxm1AgqHNPdqbtJC5UbWYf0CLY3rffrovGLPdqU0yMaEUQeuM)plf3ojAb2HId)2uuzEIzc45Qsqz()SuC7KOfyhk4mN5twYYIaHbBrFYIkIzc45QIY6Zw6Gm5Qmu57Ocl8Zsat4td6cUDs0cSdfh(TPOYLZEqXmb8Cvj4O576jWfh(TPOYLhKBaSCbhnFxpbUalthGC2KgZeWZvLGY8)zP42jrlWouC43MIkZZRfOuKsXkIcDqMCvgQ8DuHf(zrCwjHmlGbVPqYMSues423ANQfsYswyOiK43usGofs(5HqsEqcaPuijlijMjGNRQaGeAcjGSAHeJcj(ocjBYFDKnHeFhzbsMkYCqYQSKnWHemmeJoKyflqs674bj(nLeOtHegQ1IqcN5MQfsIzc45QIkGbBrFYIkIzc45QIY6Zwmuuno(dOSp(0KrjqNoBg5Qy(ByCZNSuCC9eXaMWh2Jzc45Qsqz()SuC7KOfyhko8BtrL559LLl3NpQ8uXhuYNTdKnPShZeWZvLGJMVRNaxC43MIkxEqUbWYfC08D9e4cSmDaYzdgSf9jlQiMjGNRkkRpBXqr144pGY(4ZLE8yOoYvRZKNPINaqat4d7Xmb8CvjOm)FwkUDs0cSdfh(TPOY88(YYL7ZhvEQ4dk5Z2bYMu2Jzc45QsWrZ31tGlo8BtrLlpi3ay5coA(UEcCbwMoa5Sbd2I(KfveZeWZvfL1NTyOOAC8hqzF8HUpRXtTgR8RoemXaMWh2Jzc45Qsqz()SuC7KOfyhko8BtrL559LLl3NpQ8uXhuYNTdKnPShZeWZvLGJMVRNaxC43MIkxEqUbWYfC08D9e4cSmDaYzdgSf9jlQiMjGNRkkRpBXqr144pGY(4JTjyMM0XYvLX4dGHgWe(WEmtapxvckZ)NLIBNeTa7qXHFBkQmpVVSC5(8rLNk(Gs(SDGSjL9yMaEUQeC08D9e4Id)2uu5YdYnawUGJMVRNaxGLPdqoBWGTOpzrfXmb8Cvrz9zlgkQgh)bu2hF8HJupVVkMC8vcycFypMjGNRkbL5)ZsXTtIwGDO4WVnfvMN3xwUCF(OYtfFqjF2oq2KYEmtapxvcoA(UEcCXHFBkQC5b5galxWrZ31tGlWY0biNnyWw0NSOIyMaEUQOS(SfdfvJJ)ak7JpRhdOYqf1Z7tdycFypMjGNRkbL5)ZsXTtIwGDO4WVnfvMN3xwUCF(OYtfFqjF2oq2KYEmtapxvcoA(UEcCXHFBkQC5b5galxWrZ31tGlWY0biNnyWw0NSOIyMaEUQOS(S1Q8a814uQdPzzvedycF0zcdfGje1bzYfu3Isi52WGTOpzrfXmb8Cvrz9zRBAAaOAkfTXIimyyWw0NSOcUU6WWdP7p0PzplfycXaatHQi)zXYbmHpSZtxqNM9SuGjefh(TPOVkpDbDA2ZsbMquWzoZNSytYh25PlS2SyrC43MI(Q80fwBwSi4mN5twSjLDE6c60SNLcmHO4WVnf9v5PlOtZEwkWeIcoZz(KfBs(WopDrmVJPXNSeh(TPOVkpDrmVJPXNSeCMZ8jl2KYtxqNM9SuGjefh(TPOsYtxqNM9SuGjefCMZ8jR3wi2ggSf9jlQGRRom8q6oRpBzTzXsaGPqvK)Sy5aMWh25PlS2SyrC43MI(Q80fwBwSi4mN5twSj5d780fX8oMgFYsC43MI(Q80fX8oMgFYsWzoZNSytk780fwBwSio8BtrFvE6cRnlweCMZ8jl2K8HDE6c60SNLcmHO4WVnf9v5PlOtZEwkWeIcoZz(KfBs5PlS2SyrC43MIkjpDH1MflcoZz(K1BleBdd2I(KfvW1vhgEiDN1NTI5Dmn(KvaGPqvK)Sy5aMWh25PlI5Dmn(KL4WVnf9v5PlI5Dmn(KLGZCMpzXMKpSZtxyTzXI4WVnf9v5PlS2SyrWzoZNSytk780fX8oMgFYsC43MI(Q80fX8oMgFYsWzoZNSytYh25PlOtZEwkWeIId)2u0xLNUGon7zPatik4mN5twSjLNUiM3X04twId)2uuj5PlI5Dmn(KLGZCMpz92cX2WGHbBrFYIk4PtFOiYvzOkM3X04twbmHp80fX8oMgFYsC43MIk5Jf9jlbfrUkdvX8oMgFYsenQR85JS6ZhvEQO72Xzv2fV)g7lKf3ay5I4HyZuTkoA(UalthG83cuSyz2KsBqaq521IovqrKRYqvmVJPXNSuwIY8SnRNnCfUglxm1AgqHNPdqbtdRUbWYfRUX3r1ukRnlweyz6aKlniE6ckICvgQI5Dmn(KL4WVnfvAqw0NSeue5QmufZ7yA8jlXuQqW0U7WGTOpzrf80PS(SL1MflbezjcqLBxl60NfbmHpUbWYfXdXMPAvC08DbwMoa5sTOpRrfpDH1MflskRL6ZhvEQ4dkZIaLY(HFBkQKpTrUC5Xmb8CvjOm)FwkUDs0cSdfh(TPOYSiqPSF43MIk5YYLhKTz8ghfnwXX)evtToJMpzjoRKq6HHhs3nDaYgBWGTOpzrf80PS(SL1MflbezjcqLBxl60NfbmHpb5galxepeBMQvXrZ3fyz6aKl1I(Sgv80fwBwSi5Rj1NpQ8uXhuMfbkL9d)2uujFAJC5YJzc45Qsqz()SuC7KOfyhko8BtrLzrGsz)WVnfvYLLlpiBZ4nokASIJ)jQMADgnFYsCwjH0ddpKUB6aKn2GbBrFYIk4Ptz9zl60SNLcmHyarwIau521Io9zrat4d7w0N1OINUGon7zPatik5RjlUbWYfXdXMPAvC08DbwMoa5YcTbbaLBxl6ubnxP8DurrKtvwISj1NpQ8uXhuMfbk9WWdP7MoaLYEqh(TPOsPniaOC7ArNkOiYvzOkM3X04twklXNfYLhZeWZvLGY8)zP42jrlWouC43MIkdnzak6UD83SOpzjykQB6auzHHGj6twc8vWiJJkF(iBWGTOpzrf80PS(SvmVJPXNSciYseGk3Uw0PplcycFOniaOC7ArNkOiYvzOkM3X04twklrj3M1ZgUcxJLlMAndOWZ0bOGPHv3ay5Iv347OAkL1MflcSmDaYLY(HFBkQKpTrUC5Xmb8CvjOm)FwkUDs0cSdfh(TPOYSiqPhgEiD30biBsD7Arx4ZhvEQ4dkZIaHbdd2I(KfveoaaE0hMI6MoavwyiyI(KvaGPqvK)Sy5aMWNyMaEUQeC08D9e4Id)2uujFAJ83ExkTbbaLBxl6ubfrUkdvX8oMgFYszj(SG1ZgUcxJLlMAndOWZ0bOGPrAmtapxvckZ)NLIBNeTa7qXHFBkQmVhimyl6twur4aa4rz9zRObakl6twkWq9ak7JpCD1HHhs3dycFCdGLl4O576jWfyz6aKlL2GaGYTRfDQGIixLHQyEhtJpzPSeFwW6zdxHRXYftTMbu4z6auW0iLDE6cRnlweh(TPOsYtxyTzXIGZCMpz9wGcz7YYLZtxeZ7yA8jlXHFBkQK80fX8oMgFYsWzoZNSElqHSDz5Y5PlOtZEwkWeIId)2uuj5PlOtZEwkWeIcoZz(K1BbkKTlZM0yMaEUQeC08D9e4Id)2uujFSOpzjS2Syr0g5Vj7sJzc45Qsqz()SuC7KOfyhko8BtrL59aHbBrFYIkchaapkRpBfnaqzrFYsbgQhqzF8HRRom8q6Eat4JBaSCbhnFxpbUalthGCP0geauUDTOtfue5QmufZ7yA8jlLL4ZcwpB4kCnwUyQ1mGcpthGcMgPXmb8CvjOm)FwkUDs0cSdfh(TPOs(qtgGIUBh)nl6twcRnlweTroRw0NSewBwSiAJ832wk780fwBwSio8BtrLKNUWAZIfbN5mFY6TfYLZtxeZ7yA8jlXHFBkQK80fX8oMgFYsWzoZNSEBHC580f0PzplfycrXHFBkQK80f0PzplfycrbN5mFY6TfSbd2I(KfveoaaEuwF2IJMVRNapGj8jMjGNRkbL5)ZsXTtIwGDO4WVnfvMNTdK12ixU8yMaEUQeuM)plf3ojAb2HId)2uuzwi7bcd2I(KfveoaaEuwF2IUB8CLspbEat4JotyO4NRXpwUGPrQotyOOM2Dp0aaXHFBkkmyl6twur4aa4rz9zlRnlwcycF0zcdf)Cn(XYfmnsdID3ay5c60SNLcmHOalthGCPS3C4AvBKlwiS2SyrAZHRvTrU4DH1MflsBoCTQnYfBlS2SyHn5YBoCTQnYflewBwSWgmyl6twur4aa4rz9zl60SNLcmHyat4JotyO4NRXpwUGPrAqS3C4AvBKlwiOtZEwkWeIsBoCTQnYfVlOtZEwkWeIsBoCTQnYfBlOtZEwkWeISbd2I(KfveoaaEuwF2kM3X04twbmHp6mHHIFUg)y5cMgPb1C4AvBKlwiI5Dmn(KL0GCdGLlmDAcyCufZ7yA8jlbwMoa5WGTOpzrfHdaGhL1NT4NnLcmHyat4JotyOykC94MoavC8puuqDlkHmlcuQpFu5PIpOKplcegSf9jlQiCaa8OS(Sf)SPuGjedycFCdGLlOtZEwkWeIcSmDaYLQZegkMcxpUPdqfh)dffu3IsiZZYbklVh4BStBqaq521IovqrKRYqvmVJPXNSuwIYYzdxHRXYftTMbu4z6auW0iZZ7SjLNUWAZIfXHFBkQml)gTbba1UrDukpDrmVJPXNSeh(TPOY0g5szNNUGon7zPatiko8BtrLPnYLlpi3ay5c60SNLcmHOalthGC2KYoh1zcdf7gt5Id)2uuzw(nAdcaQDJ6OC5b5galxSBmLlWY0biNnPXSCRDYsMLFJ2GaGA3Oocd2I(KfveoaaEuwF2IF2ukWeIbmHpUbWYfRUX3r1ukRnlweyz6aKlvNjmumfUECthGko(hkkOUfLqMNLduwEpW3yN2GaGYTRfDQGIixLHQyEhtJpzPSeLLZgUcxJLlMAndOWZ0bOGPrMNTztww(n2PniaOC7ArNkOiYvzOkM3X04twklrz5SHRW1y5IPwZak8mDakyAEENnP80fwBwSio8BtrLz53OniaO2nQJs5PlI5Dmn(KL4WVnfvM2ixk7CuNjmuSBmLlo8BtrLz53OniaO2nQJYLhKBaSCXUXuUalthGC2KgZYT2jlzw(nAdcaQDJ6imyl6twur4aa4rz9zl(ztPatigWe(4galxy60eW4OkM3X04twcSmDaYLQZegkMcxpUPdqfh)dffu3IsiZZYbklVh4BStBqaq521IovqrKRYqvmVJPXNSuwIYYzdxHRXYftTMbu4z6auW0iZJSZMuE6cRnlweh(TPOYS8B0geau7g1rPSZrDMWqXUXuU4WVnfvMLFJ2GaGA3OokxEqUbWYf7gt5cSmDaYztAml3ANSKz53OniaO2nQJWGTOpzrfHdaGhL1NT2nMYHbBrFYIkchaapkRpBfMrgkYv2MXBCuPJ2hgSf9jlQiCaa8OS(SvdZnHSmvRshyuhgSf9jlQiCaa8OS(SvmRiw(zoYvHa7JbmHpbXtxeZkILFMJCviW(OsN5kXHFBkQ0GSOpzjIzfXYpZrUkeyFumLkemT7omyl6twur4aa4rz9zl(ztPOjdiGPC8oMgx1csDd8SiG4Un1ZIaMYX7yA8NfbezjcqLBxl60NfbmHp(8rLNk(Gs(0g5WGTOpzrfHdaGhL1NT4NnLIMmGaISebOYTRfD6ZIaI72uplcykhVJPXvt4JprjOQd)2usUCat54DmnUQfK6g4zrat4JBaSCbD345kf(1plIcSmDaYLU2UX0bO4Bt52ukkknioQZegkO7gpxPWV(zruC43MIcd2I(KfveoaaEuwF2IF2ukAYaciYseGk3Uw0PplciUBt9SiGPC8oMgxnHp(eLGQo8Btj5YbmLJ3X04QwqQBGNfbmHpUbWYf0DJNRu4x)SikWY0bix6A7gthGIVnLBtPOimyl6twur4aa4rz9zl(ztPOjdiGPC8oMgx1csDd8SiG4Un1ZIaMYX7yA8NfWGTOpzrfHdaGhL1NTO7gpxP0tGhqKLiavUDTOtFweWe(4galxq3nEUsHF9ZIOalthGCPRTBmDak(2uUnLIIsdIJ6mHHc6UXZvk8RFwefh(TPOsdYI(KLGUB8CLspbUykviyA3DyWw0NSOIWbaWJY6Zw0DJNRu6jWdiYseGk3Uw0PplcycFCdGLlO7gpxPWV(zruGLPdqU012nMoafFBk3MsrryWw0NSOIWbaWJY6Zw0DJNRu6jWHbdd2I(KfvqBWIJh9HPOUPdqLfgcMOpzfWe(eZeWZvLGY8)zP42jrlWouC43MIk5dnzak6UD83yhFfmY4OYNpYQTz8ghf8dnEidqfnayQwXzLeSjL9GCdGLl4O576jWfyz6aKlxEmtapxvcoA(UEcCXHFBkQKp0KbOO72XFdFfmY4OYNpYMu2DdGLlO5kLVJkkICQalthGC5Y5PlA2TYZVIovldWUXzrC43MIkxopDX6bGk3MYfh(TPOSbd2I(KfvqBWIJhL1NTIgaOSOpzPad1dOSp(eoaaE0aMWh2Jzc45Qsqz()SuC7KOfyhko8BtrL0NpQ8ur3TJ)g7lll0KbOO72XztU8yMaEUQeuM)plf3ojAb2HcMg2K6ZhvEQ4dktmtapxvckZ)NLIBNeTa7qXHFBkkmyl6twubTbloEuwF2IIixLHQyEhtJpzfWe(S2UX0bOGHIkkICyWw0NSOcAdwC8OS(SftrDthGklmemrFYkGj8jO12nMoafmuurrKlnOMdxRAJCXcbL5)ZsXTtIwGDOu2DdGLl4O576jWfyz6aKlnMjGNRkbhnFxpbU4WVnfvYh8vWiJJkF(O0GSnJ34OiA0OXNQvfnG9hNfbwMoa5YLZonzak6UDCzEwwkTbbaLBxl6ubfrUkdvX8oMgFYszjk57YLttgGIUBhxMN3LsBqaq521IovqrKRYqvmVJPXNSuwIY88oBsD7Arx4ZhvEQ4dkJSZk(kyKXrLpFukTbbaLBxl6ubfrUkdvX8oMgFYszj(SqUCF(OYtfFqjFEnwXxbJmoQ85JVrtgGIUBhNnyWw0NSOcAdwC8OS(SftrDthGklmemrFYkGj8jO12nMoafmuurrKlnMLBTtws(enQR85JSU2UX0bOOX48PAHbBrFYIkOnyXXJY6Zwmf1nDaQSWqWe9jRaISebOYTRfD6ZIaMWNGwB3y6auWqrffrUu2dYnawUGJMVRNaxGLPdqUC5Xmb8Cvj4O576jWfh(TPOY4ZhvEQO72XLlNMmafD3oUmlytk7b5galxSEaOYTPCbwMoa5YLttgGIUBhxMfSjnMLBTtws(enQR85JSU2UX0bOOX48PALYEq2MXBCuenA04t1QIgW(JZIalthGC5Y1zcdfrJgn(uTQObS)4Sio8BtrLXNpQ8ur3TJZwxBnE0jR(sVh4czvGY23FTU2k7QPAPDTn5)M8CKdjYwiXI(KfKagQtfWG7AgJVNxxtB(VoDnWqDAFJUgxxDy4H09(g9Lw03ORHLPdqE)LUMf9jRUgDA2ZsbMqSRfVXXBSUg7qcpDbDA2ZsbMquC43MIcjVkKWtxqNM9SuGjefCMZ8jliHnirYhiHDiHNUWAZIfXHFBkkK8QqcpDH1MflcoZz(KfKWgKifsyhs4PlOtZEwkWeIId)2uui5vHeE6c60SNLcmHOGZCMpzbjSbjs(ajSdj80fX8oMgFYsC43MIcjVkKWtxeZ7yA8jlbN5mFYcsydsKcj80f0PzplfycrXHFBkkKijKWtxqNM9SuGjefCMZ8jli5nizHy7Ugykuf5DTfl39(sV33ORHLPdqE)LUMf9jRUM1MflDT4noEJ11yhs4PlS2SyrC43MIcjVkKWtxyTzXIGZCMpzbjSbjs(ajSdj80fX8oMgFYsC43MIcjVkKWtxeZ7yA8jlbN5mFYcsydsKcjSdj80fwBwSio8BtrHKxfs4PlS2SyrWzoZNSGe2GejFGe2HeE6c60SNLcmHO4WVnffsEviHNUGon7zPatik4mN5twqcBqIuiHNUWAZIfXHFBkkKijKWtxyTzXIGZCMpzbjVbjleB31atHQiVRTy5U3xA7(gDnSmDaY7V01SOpz11I5Dmn(KvxlEJJ3yDn2HeE6IyEhtJpzjo8BtrHKxfs4PlI5Dmn(KLGZCMpzbjSbjs(ajSdj80fwBwSio8BtrHKxfs4PlS2SyrWzoZNSGe2GePqc7qcpDrmVJPXNSeh(TPOqYRcj80fX8oMgFYsWzoZNSGe2GejFGe2HeE6c60SNLcmHO4WVnffsEviHNUGon7zPatik4mN5twqcBqIuiHNUiM3X04twId)2uuirsiHNUiM3X04twcoZz(KfK8gKSqSDxdmfQI8U2IL7E37ACm0yaEFJ(sl6B01SOpz11OniaOazuIUgwMoa59x6EFP37B01SOpz11446K5uFRDIDnSmDaY7V09(sB33ORHLPdqE)LUw201OO31SOpz11wB3y6aSRT2amyxZnawUGMRu(oQOiYPcSmDaYHePqcTbbaLBxl6ubfrUkdvX8oMgFYszjcjY8ajBdjScjNnCfUglxm1AgqHNPdqbtdKixoK4galxqNM9SuGjefyz6aKdjsHeAdcak3Uw0PckICvgQI5Dmn(KfKiZdKSmKWkKC2Wv4ASCXuRzafEMoafmnqIC5qcTbbaLBxl6ubfrUkdvX8oMgFYcsK5bsEniHvi5SHRW1y5IPwZak8mDakyA6ARTtv2h7AmuurrK39(sYEFJUgwMoa59x6AztxJIExZI(KvxBTDJPdWU2AdWGDnl6twc6UXZvk9e4c8vWiJJkF(iK8gKyBgVXrr0OrJpvRkAa7polcSmDaY7ARTtv2h7AngNpvB37lTCFJUgwMoa59x6Aztx7qk6Dnl6twDT12nMoa7ARnad21AJ8Uw8ghVX6A2MXBCuenA04t1QIgW(JZIalthGCirkKWoK4galxWpBkfnzacSmDaYHe5YHe3ay5coA(UEcCbwMoa5qIuijMjGNRkbhnFxpbU4WVnffsK8bsAJCiHTU2A7uL9XUwJX5t129(sY6(gDnSmDaY7V01YMUgf9UMf9jRU2A7gthGDT1gGb7A0geauUDTOtfue5QmufZ7yA8jlLLiKi5dKSasyfsCdGLlwDJVJQPuwBwSiWY0bihsyfsCdGLlmDAcyCufZ7yA8jlbwMoa5qYBqY7qcRqc7qIBaSCXQB8DunLYAZIfbwMoa5qIuiXnawUGMRu(oQOiYPcSmDaYHePqcTbbaLBxl6ubfrUkdvX8oMgFYszjcjYajVdjSbjScjSdjUbWYf0PzplfycrbwMoa5qIuijiiXnawUiEi2mvRIJMVlWY0bihsKcjbbjUbWYf8ZMsrtgGalthGCiHniHvi5SHRW1y5IPwZak8mDakyA6ARTtv2h7AFBk3MsrXU3xs223ORHLPdqE)LUw201OO31SOpz11wB3y6aSRT2amyxJDijiiXnawUGon7zPatikWY0bihsKlhs4PlOtZEwkWeIcMgiHnirkKWtxyTzXIG6wucirMhizrGqIuijiiHNUWAZIfXHHhs3nDacjsHeE6IyEhtJpzjyA6ARTtv2h7A80PkMMU3x616B01WY0biV)sxZI(KvxlAaGYI(KLcmuVRbgQRk7JDTyMaEUQODVVKSQVrxdlthG8(lDnl6twDn(ztPOjdORfzjcqLBxl60(sl6AXBC8gRR5ZhvEQ4dcjs(ajTroKifsOjdqr3TJdjscjl31I72uDTfDTPC8oMgx1csDd01w09(slcSVrxdlthG8(lDT4noEJ11OniaOC7ArNkOiYvzOkM3X04twklrirYhi5DiHvi5SHRW1y5IPwZak8mDakyA6Aw0NS6A7gt5DVV0If9n6Ayz6aK3FPRfVXXBSUgpDH1MflcFIsmvlKifs4PlI5Dmn(KLWNOet1cjsHe2HeDMWqHf9znQymQG6wuci5bswgsKlhsOjdqr3TJdjpqsGqcBqIuiHDijiiXnawUOz3kp)k6uTma7gNfbwMoa5qIC5qcpDrZUvE(v0PAza2nolId)2uuiHnirkKWoKeeK4galxWrZ31tGlWY0bihsKlhsIzc45QsWrZ31tGlo8BtrHejFGK2ihsKlhsccsIzc45QsWrZ31tGlo8BtrHe5YHeAdcak3Uw0PckICvgQI5Dmn(KLYsesKbswajScjNnCfUglxm1AgqHNPdqbtdKWwxZI(KvxJY8)zP42jrlWoS79Lw8EFJUgwMoa59x6AXBC8gRRfZeWZvLGY8)zP42jrlWouC43MIcjsHK12nMoaf80PkMgirkKqBqaq521IovqrKRYqvmVJPXNSuwIqYdKSasyfsoB4kCnwUyQ1mGcpthGcMgirkKWoKeeKGukwruSEOtwQmu1Gxig9jlXFQ8GePqsqqITz8ghf8dnEidqfnayQwXzLeqIC5qsmtapxvckZ)NLIBNeTa7qXHFBkkKidKSDGqcBDnl6twDnoA(UEc8U3xAX29n6Ayz6aK3FPRfVXXBSUMotyO4WOeaKsvH5frXHFBkAxZI(KvxZ3rftPNmfxfMxe7EFPfYEFJUgwMoa59x6Aw0NS6AwBwS01I344nwx7WVnffsK8bsAJCiHviXI(KLGUB8CLspbUaFfmY4OYNpcjsHeF(OYtfFqirgi516ArwIau521IoTV0IU3xAXY9n6Ayz6aK3FPRfVXXBSUMpFesKes2oWUMf9jRU2h)5XIkdvaM4Wv8dTpT79LwiR7B01WY0biV)sxZI(KvxZAZILUw8ghVX6A(8rirgiz7aHePqsmtapxvckZ)NLIBNeTa7qXHFBkkKi5dKSyzirkKGBcMPPb5cBZ0D7mQkmlxLHQMCfEDnWuOkY7ABhy37lTq223ORHLPdqE)LUMf9jRUwmVJPXNS6AXBC8gRR5ZhHezGKTdesKcjXmb8CvjOm)FwkUDs0cSdfh(TPOqIKpqYILHePqcUjyMMgKlSnt3TZOQWSCvgQAYv4bjsHKGGe3ay5ctNMaghvX8oMgFYsGLPdqoKifsyhsCdGLlOtZEwkWeIcSmDaYHe5YHeAdcak3Uw0PckICvgQI5Dmn(KLYsesKbswajsHeAdcak3Uw0PckICvgQI5Dmn(KLYsesK8bs2gsyRRbMcvrExB7a7EFPfVwFJUgwMoa59x6Aw0NS6A0PzplfycXUw8ghVX6A(8rirgiz7aHePqsmtapxvckZ)NLIBNeTa7qXHFBkkKi5dKSyzirkKGBcMPPb5cBZ0D7mQkmlxLHQMCfEDnWuOkY7ABhy37lTqw13ORHLPdqE)LUMf9jRUgtrDthGklmemrFYQRfVXXBSUwqqsml3ANSGePqIpFu5PIpiKi5dK8ADTilraQC7ArN2xAr37l9EG9n6Ayz6aK3FPRzrFYQRXpBkfnzaDTilraQC7ArN2xArxlAvebQjSR5tucQ6WVnLKl31I344nwxZnawUGUB8CLc)6NfrbwMoa5qIuizTDJPdqX3MYTPuuesKcjCuNjmuq3nEUsHF9ZIO4WVnffsKcjCuNjmuq3nEUsHF9ZIO4WVnffsK8bsAJCi5ni59U3x69f9n6Ayz6aK3FPRzrFYQRr3nEUsPNaVRfVXXBSUMBaSCbD345kf(1plIcSmDaYHePqYA7gthGIVnLBtPOiKifs4OotyOGUB8CLc)6NfrXHFBkkKifs4OotyOGUB8CLc)6NfrXHFBkkKi5dKGVcgzCu5ZhHK3GK3HewHe)S1iq5ZhHePqsqqIf9jlbD345kLEcCXuQqW0U7DTilraQC7ArN2xAr37l9(79n6Ayz6aK3FPRzrFYQR1SBLNFfDQwgGDJZsxlEJJ3yDnF(iKidKS9YqIuiXTRfDHpFu5PIpiKidKSqwdjVbj0geau7g1rirkKWoKeeKGukwruSEOtwQmu1Gxig9jlXFQ8GePqsqqITz8ghf8dnEidqfnayQwXzLeqIC5qsmtapxvckZ)NLIBNeTa7qXHFBkkKidKi7ldjScj0KbOO72XHK3GeBZ4nok4hA8qgGkAaWuTIZkjGe5YHKyMaEUQeuM)plf3ojAb2HId)2uuirsizXYqYBqcTbba1UrDesyfsOjdqr3TJdjVbj2MXBCuWp04Hmav0aGPAfNvsajS11ISebOYTRfDAFPfDVV07B33ORHLPdqE)LUMf9jRUgtrDthGklmemrFYQRfVXXBSUwqqYA7gthGcgkQOiYHePqcnzak6UDCi5bswURfzjcqLBxl60(sl6EFP3L9(gDnSmDaY7V01I344nwxBTDJPdqbdfvue5qIuiHMmafD3ooK8ajl31SOpz11OiYvzOkM3X04twDVV07l33ORHLPdqE)LUMf9jRUw0aaLf9jlfyOExdmuxv2h7A80PDVV07Y6(gDnSmDaY7V01SOpz11wpau52uExlEJJ3yDnF(iKidKSyzirkK421IUWNpQ8uXhesK5bsweiKifsyhsIzc45Qsqz()SuC7KOfyhko8BtrHezGKTdesKlhsIzc45Qsqz()SuC7KOfyhko8BtrHejHKfbcjsHeE6cRnlweh(TPOqImpqYIaHePqcpDrmVJPXNSeh(TPOqImpqYIaHePqc7qcpDbDA2ZsbMquC43MIcjY8ajlcesKlhsccsCdGLlOtZEwkWeIcSmDaYHe2Ge26ArwIau521IoTV0IU3x6DzBFJUgwMoa59x6Aw0NS6A2MP72zuvywUkdvn5k86AXBC8gRR5ZhHejFGKT7AL9XUMTz6UDgvfMLRYqvtUcVU3x69xRVrxdlthG8(lDT4noEJ1185JqIKpqY2l31SOpz11A2TYZVIovldWUXzP79LExw13ORHLPdqE)LUw8ghVX6A(8rirsizXYDnl6twDT1davUnL39(sBhyFJUgwMoa59x6AXBC8gRRXoKeZeWZvLGY8)zP42jrlWouC43MIcjscjlwgsyfsOjdqr3TJdjVbj2MXBCuWp04Hmav0aGPAfyz6aKdjYLdjSdj2MXBCuWp04Hmav0aGPAfNvsajYLdjiLIvefRh6KLkdvn4fIrFYsCwjbKWgKifs85JqImqY2bcjsHe3Uw0f(8rLNk(GqImpqY7lcesydsKcjSdj80fn7w55xrNQLby34Sio8BtrHe5YHeE6I1davUnLlo8BtrHe5YHKGGe3ay5IMDR88ROt1YaSBCweyz6aKdjsHKGGe3ay5I1davUnLlWY0bihsydsKlhs85Jkpv8bHejHKTdesyfsAJ8UMf9jRUwlJD8XkvgQSnJx67DVV02l6B01WY0biV)sxlEJJ3yDTyMaEUQeuM)plf3ojAb2HId)2uuirsizXYqcRqcnzak6UDCi5niX2mEJJc(HgpKbOIgamvRalthGCirkKWoKWtx0SBLNFfDQwgGDJZI4WVnffsKlhs4Plwpau52uU4WVnffsyRRzrFYQRXTtcfnzaDVV02V33ORzrFYQRPJhfpjMQTRHLPdqE)LU3xA7T7B01WY0biV)sxZI(KvxlAaGYI(KLcmuVRbgQRk7JDnAdwC8ODVV02YEFJUgwMoa59x6Aw0NS6Ardauw0NSuGH6DnWqDvzFSRfoaaE0U39UwZHX8RBEFJ(sl6B01SOpz11Om)FwQqeSZuoEDnSmDaY7V09(sV33ORHLPdqE)LUw8ghVX6AUbWYfT38Z5qvgQOw8MWjIcSmDaY7Aw0NS6AT38Z5qvgQOw8MWjIDVV029n6Aw0NS6AnPpz11WY0biV)s37lj79n6Ayz6aK3FPRv2h7A2MP72zuvywUkdvn5k86Aw0NS6A2MP72zuvywUkdvn5k86EFPL7B01WY0biV)sxlEJJ3yDnAdcak3Uw0PckICvgQI5Dmn(KLYsesK5bs2gsKcjbbj4MGzAAqUW2mD3oJQcZYvzOQjxHxxZI(KvxJIixLHQyEhtJpz19(sY6(gDnl6twDTDJP8UgwMoa59x6EFjzBFJUgwMoa59x6AXBC8gRRfeK4galxSBmLlWY0bihsKcj0geauUDTOtfue5QmufZ7yA8jlLLiKijKSnKifsccsWnbZ00GCHTz6UDgvfMLRYqvtUcVUMf9jRUgD345kLEc8U39Uwmtapxv0(g9Lw03ORHLPdqE)LUMf9jRUMTz6UDgvfMLRYqvtUcVUw8ghVX6ASdjbbjUbWYfn7w55xrNQLby34SiWY0bihsKlhsIzc45Qs0SBLNFfDQwgGDJZI4WVnffsKesKDi5niH2GaGA3OocjYLdjbbjXmb8CvjA2TYZVIovldWUXzrC43MIcjSbjsHKyMaEUQeuM)plf3ojAb2HId)2uuirsizHScsEdsOniaO2nQJqcRqcnzak6UDCi5niX2mEJJc(HgpKbOIgamvR4SscirkKWtxyTzXI4WVnffsKcj80fX8oMgFYsC43MIcjsHe2HeE6c60SNLcmHO4WVnffsKlhsccsCdGLlOtZEwkWeIcSmDaYHe26AL9XUMTz6UDgvfMLRYqvtUcVU3x69(gDnSmDaY7V01I344nwxJDiXnawUGBNekAYau)HIhlcSmDaYHePqsmtapxvckZ)NLIBNeTa7qbtdKifsIzc45QsWTtcfnzacMgiHnirUCijMjGNRkbL5)ZsXTtIwGDOGPbsKlhs85Jkpv8bHejHKTdSRzrFYQR1K(Kv37lTDFJUgwMoa59x6AXBC8gRRfZeWZvLGY8)zP42jrlWouC43MIcjYajY2aHe5YHeF(OYtfFqirsi59aHe5YHe2He2HeDMWqHf9znQymQG6wuci5bswgsKlhsOjdqr3TJdjpqsGqcBqIuiHDijiiXnawUOz3kp)k6uTma7gNfbwMoa5qIC5qsmtapxvIMDR88ROt1YaSBCweh(TPOqcBqIuiHDijiiXnawUGJMVRNaxGLPdqoKixoKeZeWZvLGJMVRNaxC43MIcjs(ajTroKixoKeeKeZeWZvLGJMVRNaxC43MIcjSbjsHKGGKyMaEUQeuM)plf3ojAb2HId)2uuiHTUMf9jRUgdfvJJFA37lj79n6Ayz6aK3FPRfVXXBSUwqqsmtapxvckZ)NLIBNeTa7qbttxZI(KvxlCouhKjV79LwUVrxdlthG8(lDT4noEJ11ccsIzc45Qsqz()SuC7KOfyhkyA6Aw0NS6A6Gm5QqMJLU3xsw33ORHLPdqE)LUw8ghVX6A(8rirgiz7a7Aw0NS6AF8NhlQmubyIdxXp0(0U3xs223ORHLPdqE)LUw8ghVX6A(8rLNk(GqIKqY7bcjScjTroKixoKqBqaq521IovqrKRYqvmVJPXNSuwIqImqYciHvi5SHRW1y5IPwZak8mDakyAGe5YHe3ay5cAUs57OIIiNkWY0bihsKcjXmb8CvjOm)FwkUDs0cSdfh(TPOqImpqsmtapxvckZ)NLIBNeTa7qbN5mFYcsKfizrGDnl6twDnUDsOOjdO79LET(gDnSmDaY7V01I344nwxRbDb3ojAb2HId)2uuirUCiHDijiijMjGNRkbhnFxpbU4WVnffsKlhsccsCdGLl4O576jWfyz6aKdjSbjsHKyMaEUQeuM)plf3ojAb2HId)2uuirMhi51cesKcjiLIvef6Gm5Qmu57Ocl8ZI4SscirgizrxZI(KvxthKjxLHkFhvyHFw6EFjzvFJUgwMoa59x6Aw0NS6Anzuc0PZMrUkM)gg38jlfhxprSRfVXXBSUg7qsmtapxvckZ)NLIBNeTa7qXHFBkkKiZdK8(YqIC5qIpFu5PIpiKi5dKSDGqcBqIuiHDijMjGNRkbhnFxpbU4WVnffsKlhsccsCdGLl4O576jWfyz6aKdjS11k7JDTMmkb60zZixfZFdJB(KLIJRNi29(slcSVrxdlthG8(lDnl6twDTl94XqDKRwNjptfpbGUw8ghVX6ASdjXmb8CvjOm)FwkUDs0cSdfh(TPOqImpqY7ldjYLdj(8rLNk(GqIKpqY2bcjSbjsHe2HKyMaEUQeC08D9e4Id)2uuirUCijiiXnawUGJMVRNaxGLPdqoKWwxRSp21U0Jhd1rUADM8mv8ea6EFPfl6B01WY0biV)sxZI(KvxJUpRXtTgR8RoemXUw8ghVX6ASdjXmb8CvjOm)FwkUDs0cSdfh(TPOqImpqY7ldjYLdj(8rLNk(GqIKpqY2bcjSbjsHe2HKyMaEUQeC08D9e4Id)2uuirUCijiiXnawUGJMVRNaxGLPdqoKWwxRSp21O7ZA8uRXk)QdbtS79Lw8EFJUgwMoa59x6Aw0NS6A2MGzAshlxvgJpagAxlEJJ3yDn2HKyMaEUQeuM)plf3ojAb2HId)2uuirMhi59LHe5YHeF(OYtfFqirYhiz7aHe2GePqc7qsmtapxvcoA(UEcCXHFBkkKixoKeeK4galxWrZ31tGlWY0bihsyRRv2h7A2MGzAshlxvgJpagA37lTy7(gDnSmDaY7V01SOpz118HJupVVkMC8v6AXBC8gRRXoKeZeWZvLGY8)zP42jrlWouC43MIcjY8ajVVmKixoK4ZhvEQ4dcjs(ajBhiKWgKifsyhsIzc45QsWrZ31tGlo8BtrHe5YHKGGe3ay5coA(UEcCbwMoa5qcBDTY(yxZhos98(QyYXxP79Lwi79n6Ayz6aK3FPRzrFYQRTEmGkdvupVpTRfVXXBSUg7qsmtapxvckZ)NLIBNeTa7qXHFBkkKiZdK8(YqIC5qIpFu5PIpiKi5dKSDGqcBqIuiHDijMjGNRkbhnFxpbU4WVnffsKlhsccsCdGLl4O576jWfyz6aKdjS11k7JDT1JbuzOI659PDVV0IL7B01WY0biV)sxlEJJ3yDnDMWqbycrDqMCb1TOeqIKqY2Dnl6twDTv5b4RXPuhsZYQi29(slK19n6Aw0NS6A300aq1ukAJfXUgwMoa59x6E37A80P9n6lTOVrxdlthG8(lDT4noEJ114PlI5Dmn(KL4WVnffsK8bsSOpzjOiYvzOkM3X04twIOrDLpFesyfs85Jkpv0D74qcRqISlEhsEdsyhswajYcK4galxepeBMQvXrZ3fyz6aKdjVbjbkwSmKWgKifsOniaOC7ArNkOiYvzOkM3X04twklrirMhizBiHvi5SHRW1y5IPwZak8mDakyAGewHe3ay5Iv347OAkL1MflcSmDaYHePqsqqcpDbfrUkdvX8oMgFYsC43MIcjsHKGGel6twckICvgQI5Dmn(KLykviyA39UMf9jRUgfrUkdvX8oMgFYQ79LEVVrxdlthG8(lDnl6twDnRnlw6AXBC8gRR5galxepeBMQvXrZ3fyz6aKdjsHel6ZAuXtxyTzXcKijKiRHePqIpFu5PIpiKidKSiqirkKWoKC43MIcjs(ajTroKixoKeZeWZvLGY8)zP42jrlWouC43MIcjYajlcesKcjSdjh(TPOqIKqYYqIC5qsqqITz8ghfnwXX)evtToJMpzjoRKasKcjhgEiD30biKWgKWwxlYseGk3Uw0P9Lw09(sB33ORHLPdqE)LUMf9jRUM1MflDT4noEJ11ccsCdGLlIhInt1Q4O57cSmDaYHePqIf9znQ4PlS2SybsKesEnirkK4ZhvEQ4dcjYajlcesKcjSdjh(TPOqIKpqsBKdjYLdjXmb8CvjOm)FwkUDs0cSdfh(TPOqImqYIaHePqc7qYHFBkkKijKSmKixoKeeKyBgVXrrJvC8pr1uRZO5twIZkjGePqYHHhs3nDacjSbjS11ISebOYTRfDAFPfDVVKS33ORHLPdqE)LUMf9jRUgDA2ZsbMqSRfVXXBSUg7qIf9znQ4PlOtZEwkWeIqIKqYRbjYcK4galxepeBMQvXrZ3fyz6aKdjYcKqBqaq521IovqZvkFhvue5uLLiKWgKifs85Jkpv8bHezGKfbcjsHKddpKUB6aesKcjSdjbbjh(TPOqIuiH2GaGYTRfDQGIixLHQyEhtJpzPSeHKhizbKixoKeZeWZvLGY8)zP42jrlWouC43MIcjYaj0KbOO72XHK3Gel6twcMI6MoavwyiyI(KLaFfmY4OYNpcjS11ISebOYTRfDAFPfDVV0Y9n6Ayz6aK3FPRzrFYQRfZ7yA8jRUw8ghVX6A0geauUDTOtfue5QmufZ7yA8jlLLiKijKSnKWkKC2Wv4ASCXuRzafEMoafmnqcRqIBaSCXQB8DunLYAZIfbwMoa5qIuiHDi5WVnffsK8bsAJCirUCijMjGNRkbL5)ZsXTtIwGDO4WVnffsKbsweiKifsom8q6UPdqiHnirkK421IUWNpQ8uXhesKbsweyxlYseGk3Uw0P9Lw09U31chaapAFJ(sl6B01WY0biV)sxZI(KvxJPOUPdqLfgcMOpz11I344nwxlMjGNRkbhnFxpbU4WVnffsK8bsAJCi5ni5DirkKqBqaq521IovqrKRYqvmVJPXNSuwIqYdKSasyfsoB4kCnwUyQ1mGcpthGcMgirkKeZeWZvLGY8)zP42jrlWouC43MIcjYajVhyxdmfQI8U2IL7EFP37B01WY0biV)sxlEJJ3yDn3ay5coA(UEcCbwMoa5qIuiH2GaGYTRfDQGIixLHQyEhtJpzPSeHKhizbKWkKC2Wv4ASCXuRzafEMoafmnqIuiHDiHNUWAZIfXHFBkkKijKWtxyTzXIGZCMpzbjVbjbkKTldjYLdj80fX8oMgFYsC43MIcjscj80fX8oMgFYsWzoZNSGK3GKafY2LHe5YHeE6c60SNLcmHO4WVnffsKes4PlOtZEwkWeIcoZz(KfK8gKeOq2UmKWgKifsIzc45QsWrZ31tGlo8BtrHejFGel6twcRnlweTroK8gKi7qIuijMjGNRkbL5)ZsXTtIwGDO4WVnffsKbsEpWUMf9jRUw0aaLf9jlfyOExdmuxv2h7ACD1HHhs37EFPT7B01WY0biV)sxlEJJ3yDn3ay5coA(UEcCbwMoa5qIuiH2GaGYTRfDQGIixLHQyEhtJpzPSeHKhizbKWkKC2Wv4ASCXuRzafEMoafmnqIuijMjGNRkbL5)ZsXTtIwGDO4WVnffsK8bsOjdqr3TJdjVbjw0NSewBwSiAJCiHviXI(KLWAZIfrBKdjVbjBdjsHe2HeE6cRnlweh(TPOqIKqcpDH1MflcoZz(KfK8gKSasKlhs4PlI5Dmn(KL4WVnffsKes4PlI5Dmn(KLGZCMpzbjVbjlGe5YHeE6c60SNLcmHO4WVnffsKes4PlOtZEwkWeIcoZz(KfK8gKSasyRRzrFYQRfnaqzrFYsbgQ31ad1vL9XUgxxDy4H09U3xs27B01WY0biV)sxlEJJ3yDTyMaEUQeuM)plf3ojAb2HId)2uuirMhiz7aHewHK2ihsKlhsIzc45Qsqz()SuC7KOfyhko8BtrHezGKfYEGDnl6twDnoA(UEc8U3xA5(gDnSmDaY7V01I344nwxtNjmu8Z14hlxW0ajsHeDMWqrnT7EObaId)2u0UMf9jRUgD345kLEc8U3xsw33ORHLPdqE)LUw8ghVX6A6mHHIFUg)y5cMgirkKeeKWoK4galxqNM9SuGjefyz6aKdjsHe2HKMdxRAJCXcH1MflqIuiP5W1Q2ix8UWAZIfirkK0C4AvBKl2wyTzXcKWgKixoK0C4AvBKlwiS2SybsyRRzrFYQRzTzXs37ljB7B01WY0biV)sxlEJJ3yDnDMWqXpxJFSCbtdKifsccsyhsAoCTQnYfle0PzplfycrirkK0C4AvBKlExqNM9SuGjeHePqsZHRvTrUyBbDA2ZsbMqesyRRzrFYQRrNM9SuGje7EFPxRVrxdlthG8(lDT4noEJ110zcdf)Cn(XYfmnqIuijiiP5W1Q2ixSqeZ7yA8jlirkKeeK4galxy60eW4OkM3X04twcSmDaY7Aw0NS6AX8oMgFYQ79LKv9n6Ayz6aK3FPRfVXXBSUMotyOykC94MoavC8puuqDlkbKidKSiqirkK4ZhvEQ4dcjs(ajlcSRzrFYQRXpBkfycXU3xArG9n6Ayz6aK3FPRfVXXBSUMBaSCbDA2ZsbMquGLPdqoKifs0zcdftHRh30bOIJ)HIcQBrjGezEGKLdesKfi59aHK3Ge2HeAdcak3Uw0PckICvgQI5Dmn(KLYsesKfi5SHRW1y5IPwZak8mDakyAGezEGK3He2GePqcpDH1MflId)2uuirgizzi5niH2GaGA3OocjsHeE6IyEhtJpzjo8BtrHezGK2ihsKcjSdj80f0PzplfycrXHFBkkKidK0g5qIC5qsqqIBaSCbDA2ZsbMquGLPdqoKWgKifsyhs4OotyOy3ykxC43MIcjYajldjVbj0geau7g1rirUCijiiXnawUy3ykxGLPdqoKWgKifsIz5w7KfKidKSmK8gKqBqaqTBuh7Aw0NS6A8ZMsbMqS79LwSOVrxdlthG8(lDT4noEJ11CdGLlwDJVJQPuwBwSiWY0bihsKcj6mHHIPW1JB6auXX)qrb1TOeqImpqYYbcjYcK8EGqYBqc7qcTbbaLBxl6ubfrUkdvX8oMgFYszjcjYcKC2Wv4ASCXuRzafEMoafmnqImpqY2qcBqISajldjVbjSdj0geauUDTOtfue5QmufZ7yA8jlLLiKilqYzdxHRXYftTMbu4z6auW0ajpqY7qcBqIuiHNUWAZIfXHFBkkKidKSmK8gKqBqaqTBuhHePqcpDrmVJPXNSeh(TPOqImqsBKdjsHe2HeoQZegk2nMYfh(TPOqImqYYqYBqcTbba1UrDesKlhsccsCdGLl2nMYfyz6aKdjSbjsHKywU1ozbjYajldjVbj0geau7g1XUMf9jRUg)SPuGje7EFPfV33ORHLPdqE)LUw8ghVX6AUbWYfMonbmoQI5Dmn(KLalthGCirkKOZegkMcxpUPdqfh)dffu3IsajY8ajlhiKilqY7bcjVbjSdj0geauUDTOtfue5QmufZ7yA8jlLLiKilqYzdxHRXYftTMbu4z6auW0ajY8ajYoKWgKifs4PlS2SyrC43MIcjYajldjVbj0geau7g1rirkKWoKWrDMWqXUXuU4WVnffsKbswgsEdsOniaO2nQJqIC5qsqqIBaSCXUXuUalthGCiHnirkKeZYT2jlirgizzi5niH2GaGA3Oo21SOpz114NnLcmHy37lTy7(gDnl6twDTDJP8UgwMoa59x6EFPfYEFJUMf9jRUwygzOixzBgVXrLoA)UgwMoa59x6EFPfl33ORzrFYQR1WCtilt1Q0bg17Ayz6aK3FP79LwiR7B01WY0biV)sxlEJJ3yDTGGeE6IywrS8ZCKRcb2hv6mxjo8BtrHePqsqqIf9jlrmRiw(zoYvHa7JIPuHGPD37Aw0NS6AXSIy5N5ixfcSp29(slKT9n6Ayz6aK3FPRzrFYQRXpBkfnzaDTilraQC7ArN2xArxBkhVJPX7Al6AXBC8gRR5ZhvEQ4dcjs(ajTrExlUBt11w01MYX7yACvli1nqxBr37lT416B01WY0biV)sxZI(KvxJF2ukAYa6ArwIau521IoTV0IU2uoEhtJRMWUMprjOQd)2usUCxlEJJ3yDn3ay5c6UXZvk8RFwefyz6aKdjsHK12nMoafFBk3MsrrirkKeeKWrDMWqbD345kf(1plIId)2u0UwC3MQRTORnLJ3X04QwqQBGU2IU3xAHSQVrxdlthG8(lDnl6twDn(ztPOjdORfzjcqLBxl60(sl6At54DmnUAc7A(eLGQo8Btj5YDT4noEJ11CdGLlO7gpxPWV(zruGLPdqoKifswB3y6au8TPCBkff7AXDBQU2IU2uoEhtJRAbPUb6Al6EFP3dSVrxdlthG8(lDnl6twDn(ztPOjdORnLJ3X04DTfDT4UnvxBrxBkhVJPXvTGu3aDTfDVV07l6B01WY0biV)sxZI(KvxJUB8CLspbExlEJJ3yDn3ay5c6UXZvk8RFwefyz6aKdjsHK12nMoafFBk3MsrrirkKeeKWrDMWqbD345kf(1plIId)2uuirkKeeKyrFYsq3nEUsPNaxmLkemT7ExlYseGk3Uw0P9Lw09(sV)EFJUgwMoa59x6Aw0NS6A0DJNRu6jW7AXBC8gRR5galxq3nEUsHF9ZIOalthGCirkKS2UX0bO4Bt52ukk21ISebOYTRfDAFPfDVV07B33ORzrFYQRr3nEUsPNaVRHLPdqE)LU39UgTbloE0(g9Lw03ORHLPdqE)LUw8ghVX6AXmb8CvjOm)FwkUDs0cSdfh(TPOqIKpqcnzak6UDCi5niHDibFfmY4OYNpcjScj2MXBCuWp04Hmav0aGPAfNvsajSbjsHe2HKGGe3ay5coA(UEcCbwMoa5qIC5qsmtapxvcoA(UEcCXHFBkkKi5dKqtgGIUBhhsEdsWxbJmoQ85JqcBqIuiHDiXnawUGMRu(oQOiYPcSmDaYHe5YHeE6IMDR88ROt1YaSBCweh(TPOqIC5qcpDX6bGk3MYfh(TPOqcBDnl6twDnMI6MoavwyiyI(Kv37l9EFJUgwMoa59x6AXBC8gRRXoKeZeWZvLGY8)zP42jrlWouC43MIcjscj(8rLNk6UDCi5niHDizzirwGeAYau0D74qcBqIC5qsmtapxvckZ)NLIBNeTa7qbtdKWgKifs85Jkpv8bHezGKyMaEUQeuM)plf3ojAb2HId)2u0UMf9jRUw0aaLf9jlfyOExdmuxv2h7AHdaGhT79L2UVrxdlthG8(lDT4noEJ11wB3y6auWqrffrExZI(KvxJIixLHQyEhtJpz19(sYEFJUgwMoa59x6AXBC8gRRfeKS2UX0bOGHIkkICirkKeeK0C4AvBKlwiOm)FwkUDs0cSdHePqc7qIBaSCbhnFxpbUalthGCirkKeZeWZvLGJMVRNaxC43MIcjs(aj4RGrghv(8rirkKeeKyBgVXrr0OrJpvRkAa7polcSmDaYHe5YHe2HeAYau0D74qImpqYYqIuiH2GaGYTRfDQGIixLHQyEhtJpzPSeHejHK3He5YHeAYau0D74qImpqY7qIuiH2GaGYTRfDQGIixLHQyEhtJpzPSeHezEGK3He2GePqIBxl6cF(OYtfFqirgir2HewHe8vWiJJkF(iKifsOniaOC7ArNkOiYvzOkM3X04twklri5bswajYLdj(8rLNk(GqIKpqYRbjScj4RGrghv(8ri5niHMmafD3ooKWwxZI(KvxJPOUPdqLfgcMOpz19(sl33ORHLPdqE)LUw8ghVX6AbbjRTBmDakyOOIIihsKcjXSCRDYcsK8bsIg1v(8riHvizTDJPdqrJX5t121SOpz11ykQB6auzHHGj6twDVVKSUVrxdlthG8(lDnl6twDnMI6MoavwyiyI(KvxlEJJ3yDTGGK12nMoafmuurrKdjsHe2HKGGe3ay5coA(UEcCbwMoa5qIC5qsmtapxvcoA(UEcCXHFBkkKidK4ZhvEQO72XHe5YHeAYau0D74qImqYciHnirkKWoKeeK4galxSEaOYTPCbwMoa5qIC5qcnzak6UDCirgizbKWgKifsIz5w7KfKi5dKenQR85JqcRqYA7gthGIgJZNQfsKcjSdjbbj2MXBCuenA04t1QIgW(JZIalthGCirUCirNjmuenA04t1QIgW(JZI4WVnffsKbs85Jkpv0D74qcBDTilraQC7ArN2xAr37E37E37Da]] )


end