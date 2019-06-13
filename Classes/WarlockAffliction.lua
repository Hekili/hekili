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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.9 or 1 ) * 180 end,
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


    spec:RegisterPack( "Affliction", 20190309.2135, [[dy0RIbqiLqpsjLCjkL0MquJIO0PikwfrLELQuZIOQBrur7cPFPK0Wus1XOuTmvr9mkLAAkPORHiABic8neHACic6CukH1HiKMhI09uQ2NsWbvsbluvKhQKc1ereIlQKcPtQKsPwjLIzQKsr3ujLQ2POOLQKsLNsjtvjXxvsHyVI8xkgmkhM0IjYJfmzcxgAZIQpluJwPCAfRwjLcVwuy2a3gHDl1VLmCHCCLukz5Q8CunDQUUQA7krFxvy8ev48QswpLs08fL2pOt2tRKSeQJPmFED72I1T962c6Z2TnjynFoz5VIWKvKgYqJXKvReyYAnKNdMGpvNSI0xGsfPvsw86FbmzT5EeNeD1vJhF7lrdfXQ8H4duFQoCAUVkFicRkbkPvLYv5uGlxn6Q8bG8vxzW7z7RUYZ2nRr0duHmmRH8CWe8PAkFicjlP)a812Dskzjuhtz(862TfRB71Tf0NTBBsW6K4KfpcdPmFMeqYK12ieyNKswcKhswRfKTgYZbtWNQHS1i6bQqgqBwliBZ9ioj6QRgp(2xIgkIv5dXhO(uD40CFv(qewfAZAbzR96f2GmBH8q2ZRB3wazYjK9SDsuBtsOnqBwliBnEt7yKtIcTzTGm5eYwdcbkGmRieaGS1Mvidk0M1cYKtiBnieOaYirWL1)GS1EnEcuOnRfKjNq2AhsulrbK56fJUzYPuk0M1cYKtiBniwB85oKfPcX0Xq2s9gvcGqgOINafAZAbzYjKT2HRT(ZHqgjsTchY(rqw1qMRxm6qwEDqgjcQ(MubCitw(0beYom)q(gKbQ4jazdhYetEoEy7q2KdzRXKiCitpeYedxLaOqgAYk6Q8bGjR1cYwd55Gj4t1q2Ae9avidOnRfKT5EeNeD1vJhF7lrdfXQ8H4duFQoCAUVkFicRcTzTGS1E9cBqMTqEi751TBlGm5eYE2ojQTjj0gOnRfKTgVPDmYjrH2SwqMCczRbHafqMvecaq2AZkKbfAZAbzYjKTgecuazKi4Y6Fq2AVgpbk0M1cYKtiBTdjQLOaYC9Ir3m5ukfAZAbzYjKTgeRn(ChYIuHy6yiBPEJkbqiduXtGcTzTGm5eYw7W1w)5qiJePwHdz)iiRAiZ1lgDilVoiJebvFtQaoKjlF6aczhMFiFdYav8eGSHdzIjphpSDiBYHS1yseoKPhczIHRsauidfAd0M1cYwJkhy47OaYKW86qiluesQdzsy80CkKTgcbmY5qwxTCUPhr(hazAWNQ5qw1GxuOnAWNQ50OddfHK675aLNb0gn4t1CA0HHIqs937RMxLaAJg8PAon6WqriP(79v1Fmb2U6t1qB0GpvZPrhgkcj1FVVk)tquTjcDOnAWNQ50OddfHK6V3xn(gIAo0u5gUgUjFcO8t(URaSDA8ne1COPYnCnCt(eqk2QeafqB0GpvZPrhgkcj1FVVkV1i(w5gURohAJg8PAon6WqriP(79vJkFQgAJg8PAon6WqriP(79v5ikmvUju39J8PA5N8DEecagxVy05uoIctLBc1D)iFQ2OfUWUTH2ObFQMtJomuesQ)EF1n93o0gn4t1CA0HHIqs937RY3ur9Wivax(jFFrxby70n93ofBvcGcY8ieamUEXOZPCefMk3eQ7(r(uTrlKuBdTbAZAbzRrLdm8Duaz4s8Ebz(qGqMVHqMg86GSHdz6sDaQeaPqB0GpvZ35riayavidOnAWNQ5V3xvGlR)zi04jaTrd(unFFPEJkbq5BLa3)C0Wrui)sf8XDxby7uE9W4BOHJOGtXwLaOGmpcbaJRxm6CkhrHPYnH6UFKpvB0cxy32VpDegCj2oD6LFqJNkbq6pkBwxby7u(eTvTbm5ifBvcGcY8ieamUEXOZPCefMk3eQ7(r(u9c7K89PJWGlX2PtV8dA8ujas)rzZYJqaW46fJoNYruyQCtOU7h5t1lStcFF6im4sSD60l)GgpvcG0Fe0gn4t1837RUuVrLaO8TsG7rQqmDS8v0ohD5xQGpUlRSQTeVXrAq5bvmDSjOaLy8xuSvjakilRRaSDQ40Pn86dOyRsauKnRRaSDQavFtQaofBvcGcYHQaI6rtfO6BsfWPhsOtZjDpoiKrgYXbr2SYQbFQMY3ur9WivaNIYbg(oA8HaLRAlXBCKguEqfthBckqjg)ffBvcGczKbAJg8PA(79vxQ3Osau(wjWDcDAxN2Wr5xQGpUZJqaW46fJoNYruyQCtOU7h5t1gTqs3T)2va2o9Xn(gAM2OXv)IITkbqXBxby7uvIxGVJMqD3pYNQPyRsaui3NFlRRaSD6JB8n0mTrJR(ffBvcGcYUcW2P86HX3qdhrbNITkbqbzEecagxVy05uoIctLBc1D)iFQ2OfUWZY8wwxby7u(eTvTbm5ifBvcGcYl6kaBNgoeJMo2iq13OyRsauqErxby7uXPtB41hqXwLaOqM3NocdUeBNo9YpOXtLai9hbTrd(un)9(Ql1BujakFRe4UOCU5hj)sf8XDzx0va2oLprBvBatosXwLaOiBwr5u(eTvTbm5i9hjdzr5unU6xuURHmwy3(6KxuuovJR(f9W8d5BQeajlkNgQ7(r(un9hbTrd(un)9(QbfamAWNQnGH7Y3kbUhQciQhnhAJg8PA(79vfNoTHxFG8t74D)i3edkjfSBx(WMo9UD5dVca046fJoF3U8t(URxm6uFiqJxgXGKUhheK51hy4B6jiLKqB0GpvZFVV6M(Bx(jFNhHaGX1lgDoLJOWu5MqD3pYNQnAHKU)87thHbxITtNE5h04PsaK(JG2ObFQM)EFv(NGOAJqVmIb6HYp57IYPAC1VO(eYy6yYIYPH6UFKpvt9jKX0XKLv6NNt1GplrZx5uURHm2jz2S86dm8n9e7Rldzzx0va2onAtBVim8PJ)a9g)ffBvcGISzfLtJ202lcdF64pqVXFrpKqNMldzzx0va2ovGQVjvaNITkbqr2SHQaI6rtfO6BsfWPhsOtZjDpoiYMDXqvar9OPcu9nPc40dj0P5zZYJqaW46fJoNYruyQCtOU7h5t1gTWfS)(0ryWLy70Px(bnEQeaP)izG2ObFQM)EFvbQ(MubC5N89qvar9OP8pbr1gHEzed0dPhsOtZjVuVrLaivuo38JiZJqaW46fJoNYruyQCtOU7h5t1gTWD7VpDegCj2oD6LFqJNkbq6pcAJg8PA(79v14QFjF4vaGgxVy0572LFY3pKqNMt6ECq8wd(unLVPI6HrQaofLdm8D04dbs21lgDQpeOXlJyWfiHqB0GpvZFVV6V5UkbqJMNdMGpvl)KVVyOAxJNQj76fJo1hc04LrmiP7KqOnAWNQ5V3xvC60gE9bYhEfaOX1lgD(UD5dAhqGzY39jKb3CiHonPKu(jF3va2oLVPI6HbjKonGuSvjakiVuVrLaiLqN21PnCKSaL(55u(MkQhgKq60aspKqNMtwGs)8CkFtf1ddsiDAaPhsOtZjDpoiK7ZqB0GpvZFVVkFtf1dJubC5dVca046fJoF3U8t(URaSDkFtf1ddsiDAaPyRsauqEPEJkbqkHoTRtB4izbk9ZZP8nvupmiH0PbKEiHonNSaL(55u(MkQhgKq60aspKqNMt6okhy47OXhcuUp)2pDjcm(qGKxud(unLVPI6HrQaoDAtoyI3COnAWNQ5V3xnAtBVim8PJ)a9g)L8t(Upe4c2MKKD9IrN6dbA8YigCb7Ka5YJqaWSPChH2ObFQM)EF1LdanUoTl)KV7dbUGDss21lgDQpeOXlJyWf2TVo0gn4t1837R(BURsa0O55Gj4t1YhEfaOX1lgD(UD5N89fxQ3OsaK(5OHJOGmV(adFtpXojH2ObFQM)EFvoIctLBc1D)iFQw(jFFPEJkbq6NJgoIcY86dm8n9e7KeAJg8PA(79vdkay0GpvBad3LVvcCxuohAJg8PA(79vJ202lcdF64pqVXFj)KV7dbs6UTjj0gn4t1837RUCaOX1PD5N8DFiqsTtsOnAWNQ5V3xvOxggE9bYp57HQaI6rt5FcIQnc9YigOhspKqNMtQ91jlkNgTPTxeg(0XFGEJ)IEiHonpBwxVy0P(qGgVmIbj951FhhezZYJqaW46fJoNYruyQCtOU7h5t1gTWfS)(0ryWLy70Px(bnEQeaP)iOnAWNQ5V3xvcpoEzmDm0gn4t1837RguaWObFQ2agUlFRe4opcBbECOnAWNQ5V3xnOaGrd(uTbmCx(wjW98baWJdTbAJg8PAonufqupA(Eu5t1Yp57Y6kaBNk0lddV(adXWX7ffBvcGcYHQaI6rt5FcIQnc9YigOhs)rKdvbe1JMk0lddV(a6psMSzdvbe1JMY)eevBe6LrmqpK(JYM11lgDQpeOXlJyqsT96qB0GpvZPHQaI6rZFVV6NJMXrcU8t((IHQaI6rt5FcIQnc9YigOhs)rYp57HQaI6rt5FcIQnc9YigOhspKqNMVajE9Sz9HanEzeds6ZRNnRSYk9ZZPAWNLO5RCk31qg7KmBwE9bg(MEI91LHSSl6kaBNgTPTxeg(0XFGEJ)IITkbqr2SHQaI6rtJ202lcdF64pqVXFrpKqNMldzzx0va2ovGQVjvaNITkbqr2SHQaI6rtfO6BsfWPhsOtZjDpoiYMDXqvar9OPcu9nPc40dj0P5YqEXqvar9OP8pbr1gHEzed0dPhsOtZLbAJg8PAonufqupA(79vZNdLavjKFY3xmufqupAk)tquTrOxgXa9q6pcAJg8PAonufqupA(79vLavjm5)7L8t((IHQaI6rt5FcIQnc9YigOhs)rqBG2ObFQMtfsMdZpKVTZNOTQnGjhLhmnAcID7Ku(jFxwr5u(eTvTbm5i9qcDAUTkkNYNOTQnGjhPI)P(uTmKUlROCQgx9l6He60CBvuovJR(fv8p1NQLHSSIYP8jARAdyYr6He60CBvuoLprBvBatosf)t9PAziDxwr50qD3pYNQPhsOtZTvr50qD3pYNQPI)P(uTmKfLt5t0w1gWKJ0dj0P5KkkNYNOTQnGjhPI)P(uTCTtTn0gn4t1CQqYCy(H8T37RQXv)sEW0Oji2Tts5N8DzfLt14QFrpKqNMBRIYPAC1VOI)P(uTmKUlROCAOU7h5t10dj0P52QOCAOU7h5t1uX)uFQwgYYkkNQXv)IEiHon3wfLt14QFrf)t9PAziDxwr5u(eTvTbm5i9qcDAUTkkNYNOTQnGjhPI)P(uTmKfLt14QFrpKqNMtQOCQgx9lQ4FQpvlx7uBdTrd(unNkKmhMFiF79(QH6UFKpvlpyA0ee72jP8t(USIYPH6UFKpvtpKqNMBRIYPH6UFKpvtf)t9PAziDxwr5unU6x0dj0P52QOCQgx9lQ4FQpvldzzfLtd1D)iFQMEiHon3wfLtd1D)iFQMk(N6t1Yq6USIYP8jARAdyYr6He60CBvuoLprBvBatosf)t9PAzilkNgQ7(r(un9qcDAoPIYPH6UFKpvtf)t9PA5ANABOnqB0GpvZPIY57CefMk3eQ7(r(uT8t(UOCAOU7h5t10dj0P5KURbFQMYruyQCtOU7h5t10GYDJpe4BFiqJxg(MEI3Rj9z5kRD50va2onCignDSrGQVrXwLaOqURtTtsziZJqaW46fJoNYruyQCtOU7h5t1gTWf2T97thHbxITtNE5h04PsaK(JE7kaBN(4gFdntB04QFrXwLaOG8IIYPCefMk3eQ7(r(un9qcDAo5f1Gpvt5ikmvUju39J8PA60MCWeV5qB0GpvZPIY5V3xvJR(L8HxbaAC9IrNVBx(jF3va2onCignDSrGQVrXwLaOGSg8zjAeLt14QFrkjGSRxm6uFiqJxgXGlyFDYYEiHonN094GiB2qvar9OP8pbr1gHEzed0dPhsOtZxW(6KL9qcDAoPKmB2fvBjEJJ0iTfiXemtVScQpvtpTZG8H5hY3ujakJmqB0GpvZPIY5V3xvJR(L8HxbaAC9IrNVBx(jFFrxby70WHy00XgbQ(gfBvcGcYAWNLOruovJR(fPKqYUEXOt9HanEzedUG91jl7He60Cs3JdISzdvbe1JMY)eevBe6LrmqpKEiHonFb7Rtw2dj0P5KsYSzxuTL4nosJ0wGetWm9YkO(un90odYhMFiFtLaOmYaTrd(unNkkN)EFv(eTvTbm5O8HxbaAC9IrNVBx(jFxwn4Zs0ikNYNOTQnGjhjLekNUcW2PHdXOPJncu9nk2QeafYjpcbaJRxm6CkVEy8n0WruWnAHYq21lgDQpeOXlJyWfSVo5dZpKVPsaKSSlEiHonNmpcbaJRxm6CkhrHPYnH6UFKpvB0c3TNnBOkGOE0u(NGOAJqVmIb6H0dj0P5lWRpWW30tixn4t10FZDvcGgnphmbFQMIYbg(oA8HaLbAJg8PAovuo)9(QH6UFKpvlF4vaGgxVy0572LFY35riayC9IrNt5ikmvUju39J8PAJwiP2(9PJWGlX2PtV8dA8ujas)rVDfGTtFCJVHMPnAC1VOyRsauqw2dj0P5KUhhezZgQciQhnL)jiQ2i0lJyGEi9qcDA(c2xN8H5hY3ujakdzxVy0P(qGgVmIbxW(6qBG2ObFQMtZhaap((V5UkbqJMNdMGpvlpyA0ee72jP8t(EOkGOE0ubQ(MubC6He60Cs3Jdc5(mzEecagxVy05uoIctLBc1D)iFQ2OfUB)9PJWGlX2PtV8dA8ujas)rKdvbe1JMY)eevBe6LrmqpKEiHonFHNxhAJg8PAonFaa84V3xnOaGrd(uTbmCx(wjWDHK5W8d5BYp57UcW2Pcu9nPc4uSvjakiZJqaW46fJoNYruyQCtOU7h5t1gTWD7VpDegCj2oD6LFqJNkbq6pISSIYPAC1VOhsOtZjvuovJR(fv8p1NQL76usmjZMvuonu39J8PA6He60CsfLtd1D)iFQMk(N6t1YDDkjMKzZkkNYNOTQnGjhPhsOtZjvuoLprBvBatosf)t9PA5UoLetszihQciQhnvGQVjvaNEiHonN0Dn4t1unU6x04GqURj5qvar9OP8pbr1gHEzed0dPhsOtZx451H2ObFQMtZhaap(79vdkay0GpvBad3LVvcCxizom)q(M8t(URaSDQavFtQaofBvcGcY8ieamUEXOZPCefMk3eQ7(r(uTrlC3(7thHbxITtNE5h04PsaK(JihQciQhnL)jiQ2i0lJyGEi9qcDAoP786dm8n9eYvd(unvJR(fnoiERbFQMQXv)IgheY12KLvuovJR(f9qcDAoPIYPAC1VOI)P(uTCTNnROCAOU7h5t10dj0P5KkkNgQ7(r(unv8p1NQLR9SzfLt5t0w1gWKJ0dj0P5KkkNYNOTQnGjhPI)P(uTCTld0gn4t1CA(aa4XFVVQavFtQaU8t(EOkGOE0u(NGOAJqVmIb6H0dj0P5lSB71FhhezZgQciQhnL)jiQ2i0lJyGEi9qcDA(c2xZ1H2ObFQMtZhaap(79v5BQOEyKkGl)KVl9ZZPe1sKaBN(Jil9ZZP9eV55kaqpKqNMdTrd(unNMpaaE837RQXv)s(jFx6NNtjQLib2o9hrErzDfGTt5t0w1gWKJuSvjakilB0HlnXbb1ovJR(f5OdxAIdc6ZunU6xKJoCPjoiO2MQXv)sMSzJoCPjoiO2PAC1VKbAJg8PAonFaa84V3xLprBvBatok)KVl9ZZPe1sKaBN(JiVOSrhU0eheu7u(eTvTbm5i5OdxAIdc6Zu(eTvTbm5i5OdxAIdcQTP8jARAdyYrzG2ObFQMtZhaap(79vd1D)iFQw(jFx6NNtjQLib2o9hrEXOdxAIdcQDAOU7h5t1Kx0va2ovL4f47Oju39J8PAk2QeafqB0GpvZP5daGh)9(QItN2aMCu(jFxwPFEoDAC54QeancKy4iL7AiJf2xZ1Ltz5riayC9IrNt5ikmvUju39J8PAJwOCE6im4sSD60l)GgpvcG0F0cplJCFEDYYgQciQhnvGQVjvaNEiHonFbuoWW3rJpey2Sl6kaBNkq13KkGtXwLaOqgYYgQciQhnnAtBVim8PJ)a9g)f9qcDA(cOCGHVJgFiWSzx0va2onAtBVim8PJ)a9g)ffBvcGczilBOkGOE0uHEzy41hqpKqNMVakhy47OXhcmB2fDfGTtf6LHHxFGHy449IITkbqHmKLnufqupA6YbGgxN2PhsOtZxaLdm8D04dbMn7IUcW2PlhaACDANITkbqHmKdvbe1JMY)eevBe6LrmqpKEiHonFbuoWW3rJpe4B7RNnR0ppNonUCCvcGgbsmCKYDnKXc2xNSRxm6uFiqJxgXGKUBFDzG2ObFQMtZhaap(79v30F7qB0GpvZP5daGh)9(QItN2WRpq(PD8UFKBIbLKc2TlFytNE3U8t74D)iF3U8HxbaAC9IrNVBx(jF31lgDQpeOXlJyqs3JdcOnAWNQ508baWJ)EFvXPtB41hiF4vaGgxVy0572LpSPtVBx(PD8UFKBM8DFczWnhsOttkjLFAhV7h5MyqjPGD7Yp57UcW2P8nvupmiH0PbKITkbqb5L6nQeaPe60UoTHJKxuGs)8CkFtf1ddsiDAaPhsOtZH2ObFQMtZhaap(79vfNoTHxFG8HxbaAC9IrNVBx(WMo9UD5N2X7(rUzY39jKb3CiHonPKu(PD8UFKBIbLKc2Tl)KV7kaBNY3ur9WGesNgqk2QeafKxQ3OsaKsOt760gocTrd(unNMpaaE837RkoDAdV(a5N2X7(rUjgusky3U8HnD6D7YpTJ39J8D7qB0GpvZP5daGh)9(Q8nvupmsfWLp8kaqJRxm68D7Yp57UcW2P8nvupmiH0PbKITkbqb5L6nQeaPe60UoTHJKxuGs)8CkFtf1ddsiDAaPhsOtZjVOg8PAkFtf1dJubC60MCWeV5qB0GpvZP5daGh)9(Q8nvupmsfWLp8kaqJRxm68D7Yp57UcW2P8nvupmiH0PbKITkbqb5L6nQeaPe60UoTHJqB0GpvZP5daGh)9(Q8nvupmsfWH2aTrd(unNYJWwGhF)3CxLaOrZZbtWNQLFY3dvbe1JMY)eevBe6LrmqpKEiHonN0DE9bg(MEc5IYbg(oA8Hajl7IUcW2Pcu9nPc4uSvjakYMnufqupAQavFtQao9qcDAoP786dm8n9eYfLdm8D04dbkd0gn4t1CkpcBbE837RguaWObFQ2agUlFRe4E(aa4XLFY3LnufqupAk)tquTrOxgXa9q6He60Cs9HanEz4B6jKRSKa5KxFGHVPNqMSzdvbe1JMY)eevBe6LrmqpK(JKHSpeOXlJyWfcvbe1JMY)eevBe6LrmqpKEiHonhAJg8PAoLhHTap(79v5ikmvUju39J8PA5N89L6nQeaPFoA4ikG2ObFQMt5rylWJ)EF1FZDvcGgnphmbFQw(jFFXL6nQeaPFoA4ikiVy0HlnXbb1oL)jiQ2i0lJyGEizzDfGTtfO6BsfWPyRsauqoufqupAQavFtQao9qcDAoP7OCGHVJgFiqYlQ2s8ghPbLhuX0XMGcuIXFrXwLaOiBwz51hy4B6jwyNKK5riayC9IrNt5ikmvUju39J8PAJwiPpNnlV(adFtpXc7ptMhHaGX1lgDoLJOWu5MqD3pYNQnAHlS)SmKD9IrN6dbA8YigCH18nkhy47OXhcKmpcbaJRxm6CkhrHPYnH6UFKpvB0c3TNnRRxm6uFiqJxgXGKUtcFJYbg(oA8HaLlV(adFtpHmqB0GpvZP8iSf4XFVV6V5UkbqJMNdMGpvl)KVV4s9gvcG0phnCefKdv7A8unP7bL7gFiW3l1BujasJuHy6yOnAWNQ5uEe2c84V3x93CxLaOrZZbtWNQLp8kaqJRxm68D7Yp57lUuVrLai9Zrdhrbzzx0va2ovGQVjvaNITkbqr2SHQaI6rtfO6BsfWPhsOtZxWhc04LHVPNiBwE9bg(MEIfSldzzx0va2oD5aqJRt7uSvjakYMLxFGHVPNyb7YqouTRXt1KUhuUB8HaFVuVrLainsfIPJjl7IQTeVXrAq5bvmDSjOaLy8xuSvjakYMv6NNtdkpOIPJnbfOeJ)IEiHonFbFiqJxg(MEczswlXJpvNY851TBlw3(6ptTVojtwp0RNoMNSwBtevNJciJedzAWNQHmWWDofAtYs)(wDjlRHynozbgUZtRKSesMdZpKVLwjLP90kjlSvjakspLS0GpvNS4t0w1gWKJjRWnoEJMSKfYeLt5t0w1gWKJ0dj0P5qMTczIYP8jARAdyYrQ4FQpvdzYazKUdzYczIYPAC1VOhsOtZHmBfYeLt14QFrf)t9PAitgiJmKjlKjkNYNOTQnGjhPhsOtZHmBfYeLt5t0w1gWKJuX)uFQgYKbYiDhYKfYeLtd1D)iFQMEiHonhYSvituonu39J8PAQ4FQpvdzYazKHmr5u(eTvTbm5i9qcDAoKrkKjkNYNOTQnGjhPI)P(unKjxiZo12jlW0Ojisw2jzYtz(CALKf2QeafPNswAWNQtwAC1VswHBC8gnzjlKjkNQXv)IEiHonhYSvituovJR(fv8p1NQHmzGms3HmzHmr50qD3pYNQPhsOtZHmBfYeLtd1D)iFQMk(N6t1qMmqgzitwituovJR(f9qcDAoKzRqMOCQgx9lQ4FQpvdzYazKUdzYczIYP8jARAdyYr6He60CiZwHmr5u(eTvTbm5iv8p1NQHmzGmYqMOCQgx9l6He60CiJuituovJR(fv8p1NQHm5cz2P2ozbMgnbrYYojtEktBNwjzHTkbqr6PKLg8P6KvOU7h5t1jRWnoEJMSKfYeLtd1D)iFQMEiHonhYSvituonu39J8PAQ4FQpvdzYazKUdzYczIYPAC1VOhsOtZHmBfYeLt14QFrf)t9PAitgiJmKjlKjkNgQ7(r(un9qcDAoKzRqMOCAOU7h5t1uX)uFQgYKbYiDhYKfYeLt5t0w1gWKJ0dj0P5qMTczIYP8jARAdyYrQ4FQpvdzYazKHmr50qD3pYNQPhsOtZHmsHmr50qD3pYNQPI)P(unKjxiZo12jlW0Ojisw2jzYtEYsG56h4PvszApTsYsd(uDYIhHaGbuHmswyRsauKEk5PmFoTsYsd(uDYsGlR)zi04jKSWwLaOi9uYtzA70kjlSvjakspLSwQGpMSCfGTt51dJVHgoIcofBvcGciJmKXJqaW46fJoNYruyQCtOU7h5t1gTqiBHDiZ2q2Bi70ryWLy70Px(bnEQeaP)iilBwiZva2oLprBvBatosXwLaOaYidz8ieamUEXOZPCefMk3eQ7(r(unKTWoKrsi7nKD6im4sSD60l)GgpvcG0FeKLnlKXJqaW46fJoNYruyQCtOU7h5t1q2c7qgjeYEdzNocdUeBNo9YpOXtLai9hLS0GpvNSwQ3OsamzTuptReyY6ZrdhrrYtzUMPvswyRsauKEkzvrjlo6jln4t1jRL6nQeatwlvWhtwYczYczQTeVXrAq5bvmDSjOaLy8xuSvjakGmYqMSqMRaSDQ40Pn86dOyRsauazzZczUcW2Pcu9nPc4uSvjakGmYqwOkGOE0ubQ(MubC6He60CiJ0DiloiGmzGmzGmYqwCqazzZczYczAWNQP8nvupmsfWPOCGHVJgFiqitUqMAlXBCKguEqfthBckqjg)ffBvcGcitgitMK1s9mTsGjRiviMoo5PmjzALKf2QeafPNswlvWhtw8ieamUEXOZPCefMk3eQ7(r(uTrleYiDhYSdzVHmxby70h34BOzAJgx9lk2Qeafq2BiZva2ovL4f47Oju39J8PAk2QeafqMCHSNHS3qMSqMRaSD6JB8n0mTrJR(ffBvcGciJmK5kaBNYRhgFdnCefCk2QeafqgziJhHaGX1lgDoLJOWu5MqD3pYNQnAHq2cq2ZqMmq2BitwiZva2oLprBvBatosXwLaOaYidzlczUcW2PHdXOPJncu9nk2QeafqgziBriZva2ovC60gE9buSvjakGmzGS3q2PJWGlX2PtV8dA8ujas)rjln4t1jRL6nQeatwl1Z0kbMSi0PDDAdhtEktsqALKf2QeafPNswlvWhtwYczlczUcW2P8jARAdyYrk2Qeafqw2SqMOCkFI2Q2aMCK(JGmzGmYqMOCQgx9lk31qgq2c7qM91HmYq2IqMOCQgx9l6H5hY3ujaczKHmr50qD3pYNQP)OKLg8P6K1s9gvcGjRL6zALatwIY5MFuYtzsItRKSWwLaOi9uYsd(uDYkOaGrd(uTbmCpzbgUBALatwHQaI6rZtEktsyALKf2QeafPNswAWNQtwItN2WRpizfEfaOX1lgDEkt7jRWnoEJMSC9IrN6dbA8YigeYiDhYIdciJmKXRpWW30tazKczKmzf20Ptw2twt74D)i3edkjfKSSN8uM2I0kjlSvjakspLSc344nAYIhHaGX1lgDoLJOWu5MqD3pYNQnAHqgP7q2Zq2Bi70ryWLy70Px(bnEQeaP)OKLg8P6K1M(Bp5PmTVEALKf2QeafPNswHBC8gnzjkNQXv)I6tiJPJHmYqMOCAOU7h5t1uFczmDmKrgYKfYK(55un4Zs08voL7AidiBhYijKLnlKXRpWW30taz7q26qMmqgzitwiBriZva2onAtBVim8PJ)a9g)ffBvcGcilBwituonAtBVim8PJ)a9g)f9qcDAoKjdKrgYKfYweYCfGTtfO6BsfWPyRsauazzZczHQaI6rtfO6BsfWPhsOtZHms3HS4GaYYMfYweYcvbe1JMkq13KkGtpKqNMdzzZcz8ieamUEXOZPCefMk3eQ7(r(uTrleYwaYSdzVHSthHbxITtNE5h04PsaK(JGmzswAWNQtw8pbr1gHEzed0dtEkt72tRKSWwLaOi9uYkCJJ3OjRqvar9OP8pbr1gHEzed0dPhsOtZHmYq2s9gvcGur5CZpcYidz8ieamUEXOZPCefMk3eQ7(r(uTrleY2Hm7q2Bi70ryWLy70Px(bnEQeaP)OKLg8P6KLavFtQaEYtzA)50kjlSvjakspLS0GpvNS04QFLSc344nAY6qcDAoKr6oKfheq2Bitd(unLVPI6HrQaofLdm8D04dbczKHmxVy0P(qGgVmIbHSfGmsyYk8kaqJRxm68uM2tEkt72oTsYcBvcGI0tjRWnoEJMSweYcv7A8unKrgYC9IrN6dbA8YigeYiDhYiHjln4t1jRFZDvcGgnphmbFQo5PmTVMPvswyRsauKEkzPbFQozjoDAdV(GKv4vaGgxVy05PmTNScAhqGzYtw(eYGBoKqNMusMSc344nAYYva2oLVPI6HbjKonGuSvjakGmYq2s9gvcGucDAxN2WriJmKjqPFEoLVPI6HbjKonG0dj0P5qgzitGs)8CkFtf1ddsiDAaPhsOtZHms3HS4GaYKlK9CYtzANKPvswyRsauKEkzPbFQozX3ur9WivapzfUXXB0KLRaSDkFtf1ddsiDAaPyRsauazKHSL6nQeaPe60UoTHJqgzitGs)8CkFtf1ddsiDAaPhsOtZHmYqMaL(55u(MkQhgKq60aspKqNMdzKUdzOCGHVJgFiqitUq2Zq2BiZpDjcm(qGqgziBritd(unLVPI6HrQaoDAtoyI38Kv4vaGgxVy05PmTN8uM2jbPvswyRsauKEkzfUXXB0KLpeiKTaKzBsczKHmxVy0P(qGgVmIbHSfGm7KaitUqgpcbaZMYDmzPbFQozfTPTxeg(0XFGEJ)k5PmTtItRKSWwLaOi9uYkCJJ3OjlFiqiBbiZojHmYqMRxm6uFiqJxgXGq2c7qM91twAWNQtwlhaACDAp5PmTtctRKSWwLaOi9uYsd(uDY63CxLaOrZZbtWNQtwHBC8gnzTiKTuVrLai9ZrdhrbKrgY41hy4B6jGSDiJKjRWRaanUEXOZtzAp5PmTBlsRKSWwLaOi9uYkCJJ3OjRL6nQeaPFoA4ikGmYqgV(adFtpbKTdzKmzPbFQozXruyQCtOU7h5t1jpL5ZRNwjzHTkbqr6PKLg8P6KvqbaJg8PAdy4EYcmC30kbMSeLZtEkZNTNwjzHTkbqr6PKv4ghVrtw(qGqgP7qMTjzYsd(uDYkAtBVim8PJ)a9g)vYtz(8ZPvswyRsauKEkzfUXXB0KLpeiKrkKzNKjln4t1jRLdanUoTN8uMpB70kjlSvjakspLSc344nAYkufqupAk)tquTrOxgXa9q6He60CiJuiZ(6qgzituonAtBVim8PJ)a9g)f9qcDAoKLnlK56fJo1hc04LrmiKrkK986q2BiloiGSSzHmEecagxVy05uoIctLBc1D)iFQ2Ofczlaz2HS3q2PJWGlX2PtV8dA8ujas)rjln4t1jlHEzy41hK8uMpVMPvswAWNQtws4XXlJPJtwyRsauKEk5PmFMKPvswyRsauKEkzPbFQozfuaWObFQ2agUNSad3nTsGjlEe2c84jpL5ZKG0kjlSvjakspLS0GpvNSckay0GpvBad3twGH7MwjWKv(aa4XtEYtwrhgkcj1tRKY0EALKf2QeafPNsEkZNtRKSWwLaOi9uYtzA70kjlSvjakspL8uMRzALKLg8P6Kf)tquTjhbB)2XlzHTkbqr6PKNYKKPvswyRsauKEkzfUXXB0KLRaSDA8ne1COPYnCnCt(eqk2Qeafjln4t1jR4BiQ5qtLB4A4M8jGjpLjjiTsYcBvcGI0tjpLjjoTsYsd(uDYkQ8P6Kf2QeafPNsEktsyALKf2QeafPNswHBC8gnzXJqaW46fJoNYruyQCtOU7h5t1gTqiBHDiZ2jln4t1jloIctLBc1D)iFQo5PmTfPvswAWNQtwB6V9Kf2QeafPNsEkt7RNwjzHTkbqr6PKv4ghVrtwlczUcW2PB6VDk2QeafqgziJhHaGX1lgDoLJOWu5MqD3pYNQnAHqgPqMTtwAWNQtw8nvupmsfWtEYtwHQaI6rZtRKY0EALKf2QeafPNswHBC8gnzjlK5kaBNk0lddV(adXWX7ffBvcGciJmKfQciQhnL)jiQ2i0lJyGEi9hbzKHSqvar9OPc9YWWRpG(JGmzGSSzHSqvar9OP8pbr1gHEzed0dP)iilBwiZ1lgDQpeOXlJyqiJuiZ2RNS0GpvNSIkFQo5PmFoTsYcBvcGI0tjRWnoEJMScvbe1JMY)eevBe6LrmqpKEiHonhYwaYiXRdzzZcz(qGgVmIbHmsHSNxhYYMfYKfYKfYK(55un4Zs08voL7AidiBhYijKLnlKXRpWW30taz7q26qMmqgzitwiBriZva2onAtBVim8PJ)a9g)ffBvcGcilBwilufqupAA0M2Ery4th)b6n(l6He60CitgiJmKjlKTiK5kaBNkq13KkGtXwLaOaYYMfYcvbe1JMkq13KkGtpKqNMdzKUdzXbbKLnlKTiKfQciQhnvGQVjvaNEiHonhYKbYidzlczHQaI6rt5FcIQnc9YigOhspKqNMdzYKS0GpvNS(C0mosWtEktBNwjzHTkbqr6PKv4ghVrtwlczHQaI6rt5FcIQnc9YigOhs)rjln4t1jR85qjqvIKNYCntRKSWwLaOi9uYkCJJ3OjRfHSqvar9OP8pbr1gHEzed0dP)OKLg8P6KLeOkHj)FVsEYtwIY5PvszApTsYcBvcGI0tjRWnoEJMSeLtd1D)iFQMEiHonhYiDhY0Gpvt5ikmvUju39J8PAAq5UXhceYEdz(qGgVm8n9eq2BiBnPpdzYfYKfYSdzYjK5kaBNgoeJMo2iq13OyRsauazYfYwNANKqMmqgziJhHaGX1lgDoLJOWu5MqD3pYNQnAHq2c7qMTHS3q2PJWGlX2PtV8dA8ujas)rq2BiZva2o9Xn(gAM2OXv)IITkbqbKrgYweYeLt5ikmvUju39J8PA6He60CiJmKTiKPbFQMYruyQCtOU7h5t10Pn5GjEZtwAWNQtwCefMk3eQ7(r(uDYtz(CALKf2QeafPNswAWNQtwAC1VswHBC8gnz5kaBNgoeJMo2iq13OyRsauazKHmn4Zs0ikNQXv)cYifYibqgziZ1lgDQpeOXlJyqiBbiZ(6qgzitwi7qcDAoKr6oKfheqw2SqwOkGOE0u(NGOAJqVmIb6H0dj0P5q2cqM91HmYqMSq2He60CiJuiJKqw2Sq2IqMAlXBCKgPTajMGz6Lvq9PA6PDgqgzi7W8d5BQeaHmzGmzswHxbaAC9IrNNY0EYtzA70kjlSvjakspLS0GpvNS04QFLSc344nAYAriZva2onCignDSrGQVrXwLaOaYidzAWNLOruovJR(fKrkKrcHmYqMRxm6uFiqJxgXGq2cqM91HmYqMSq2He60CiJ0DiloiGSSzHSqvar9OP8pbr1gHEzed0dPhsOtZHSfGm7RdzKHmzHSdj0P5qgPqgjHSSzHSfHm1wI34insBbsmbZ0lRG6t10t7mGmYq2H5hY3ujaczYazYKScVca046fJopLP9KNYCntRKSWwLaOi9uYsd(uDYIprBvBatoMSc344nAYswitd(SenIYP8jARAdyYriJuiJeczYjK5kaBNgoeJMo2iq13OyRsauazYjKXJqaW46fJoNYRhgFdnCefCJwiKjdKrgYC9IrN6dbA8YigeYwaYSVoKrgYom)q(MkbqiJmKjlKTiKDiHonhYidz8ieamUEXOZPCefMk3eQ7(r(uTrleY2Hm7qw2SqwOkGOE0u(NGOAJqVmIb6H0dj0P5q2cqgV(adFtpbKjxitd(un93CxLaOrZZbtWNQPOCGHVJgFiqitMKv4vaGgxVy05PmTN8uMKmTsYcBvcGI0tjln4t1jRqD3pYNQtwHBC8gnzXJqaW46fJoNYruyQCtOU7h5t1gTqiJuiZ2q2Bi70ryWLy70Px(bnEQeaP)ii7nK5kaBN(4gFdntB04QFrXwLaOaYidzYczhsOtZHms3HS4GaYYMfYcvbe1JMY)eevBe6LrmqpKEiHonhYwaYSVoKrgYom)q(MkbqitgiJmK56fJo1hc04LrmiKTaKzF9Kv4vaGgxVy05PmTN8KNSYhaapEALuM2tRKSWwLaOi9uYsd(uDY63CxLaOrZZbtWNQtwHBC8gnzfQciQhnvGQVjvaNEiHonhYiDhYIdcitUq2ZqgziJhHaGX1lgDoLJOWu5MqD3pYNQnAHq2oKzhYEdzNocdUeBNo9YpOXtLai9hbzKHSqvar9OP8pbr1gHEzed0dPhsOtZHSfGSNxpzbMgnbrYYojtEkZNtRKSWwLaOi9uYkCJJ3Ojlxby7ubQ(MubCk2QeafqgziJhHaGX1lgDoLJOWu5MqD3pYNQnAHq2oKzhYEdzNocdUeBNo9YpOXtLai9hbzKHmzHmr5unU6x0dj0P5qgPqMOCQgx9lQ4FQpvdzYfYwNsIjjKLnlKjkNgQ7(r(un9qcDAoKrkKjkNgQ7(r(unv8p1NQHm5czRtjXKeYYMfYeLt5t0w1gWKJ0dj0P5qgPqMOCkFI2Q2aMCKk(N6t1qMCHS1PKysczYazKHSqvar9OPcu9nPc40dj0P5qgP7qMg8PAQgx9lACqazYfYwtiJmKfQciQhnL)jiQ2i0lJyGEi9qcDAoKTaK986jln4t1jRGcagn4t1gWW9Kfy4UPvcmzjKmhMFiFl5PmTDALKf2QeafPNswHBC8gnz5kaBNkq13KkGtXwLaOaYidz8ieamUEXOZPCefMk3eQ7(r(uTrleY2Hm7q2Bi70ryWLy70Px(bnEQeaP)iiJmKfQciQhnL)jiQ2i0lJyGEi9qcDAoKr6oKXRpWW30tazYfY0Gpvt14QFrJdci7nKPbFQMQXv)IgheqMCHmBdzKHmzHmr5unU6x0dj0P5qgPqMOCQgx9lQ4FQpvdzYfYSdzzZczIYPH6UFKpvtpKqNMdzKczIYPH6UFKpvtf)t9PAitUqMDilBwituoLprBvBatospKqNMdzKczIYP8jARAdyYrQ4FQpvdzYfYSdzYKS0GpvNSckay0GpvBad3twGH7MwjWKLqYCy(H8TKNYCntRKSWwLaOi9uYkCJJ3OjRqvar9OP8pbr1gHEzed0dPhsOtZHSf2HmBVoK9gYIdcilBwilufqupAk)tquTrOxgXa9q6He60CiBbiZ(AUEYsd(uDYsGQVjvap5PmjzALKf2QeafPNswHBC8gnzj9ZZPe1sKaBN(JGmYqM0ppN2t8MNRaa9qcDAEYsd(uDYIVPI6HrQaEYtzscsRKSWwLaOi9uYkCJJ3OjlPFEoLOwIey70FeKrgYweYKfYCfGTt5t0w1gWKJuSvjakGmYqMSqw0HlnXbb1ovJR(fKrgYIoCPjoiOpt14QFbzKHSOdxAIdcQTPAC1VGmzGSSzHSOdxAIdcQDQgx9litMKLg8P6KLgx9RKNYKeNwjzHTkbqr6PKv4ghVrtws)8CkrTejW2P)iiJmKTiKjlKfD4stCqqTt5t0w1gWKJqgzil6WLM4GG(mLprBvBatoczKHSOdxAIdcQTP8jARAdyYritMKLg8P6KfFI2Q2aMCm5PmjHPvswyRsauKEkzfUXXB0KL0ppNsulrcSD6pcYidzlczrhU0eheu70qD3pYNQHmYq2IqMRaSDQkXlW3rtOU7h5t1uSvjakswAWNQtwH6UFKpvN8uM2I0kjlSvjakspLSc344nAYswit6NNtNgxoUkbqJajgos5UgYaYwyhYwZ1Hm5eYKfY4riayC9IrNt5ikmvUju39J8PAJwiKjNq2PJWGlX2PtV8dA8ujas)rq2cq2ZqMmqMCHSNxhYidzYczHQaI6rtfO6BsfWPhsOtZHSfGmuoWW3rJpeiKLnlKTiK5kaBNkq13KkGtXwLaOaYKbYidzYczHQaI6rtJ202lcdF64pqVXFrpKqNMdzlazOCGHVJgFiqilBwiBriZva2onAtBVim8PJ)a9g)ffBvcGcitgiJmKjlKfQciQhnvOxggE9b0dj0P5q2cqgkhy47OXhceYYMfYweYCfGTtf6LHHxFGHy449IITkbqbKjdKrgYKfYcvbe1JMUCaOX1PD6He60CiBbidLdm8D04dbczzZczlczUcW2PlhaACDANITkbqbKjdKrgYcvbe1JMY)eevBe6LrmqpKEiHonhYwaYq5adFhn(qGq2BiZ(6qw2SqM0ppNonUCCvcGgbsmCKYDnKbKTaKzFDiJmK56fJo1hc04LrmiKr6oKzFDitMKLg8P6KL40PnGjhtEkt7RNwjzPbFQozTP)2twyRsauKEk5PmTBpTsYcBvcGI0tjln4t1jlXPtB41hKScVca046fJopLP9K10oE3pYtw2twHBC8gnz56fJo1hc04LrmiKr6oKfhejRWMoDYYEYAAhV7h5MyqjPGKL9KNY0(ZPvswyRsauKEkzPbFQozjoDAdV(GKv4vaGgxVy05PmTNSM2X7(rUzYtw(eYGBoKqNMusMSc344nAYYva2oLVPI6HbjKonGuSvjakGmYq2s9gvcGucDAxN2WriJmKTiKjqPFEoLVPI6HbjKonG0dj0P5jRWMoDYYEYAAhV7h5MyqjPGKL9KNY0UTtRKSWwLaOi9uYsd(uDYsC60gE9bjRWRaanUEXOZtzApznTJ39JCZKNS8jKb3CiHonPKmzfUXXB0KLRaSDkFtf1ddsiDAaPyRsauazKHSL6nQeaPe60UoTHJjRWMoDYYEYAAhV7h5MyqjPGKL9KNY0(AMwjzHTkbqr6PKLg8P6KL40Pn86dswt74D)ipzzpzf20Ptw2twt74D)i3edkjfKSSN8uM2jzALKf2QeafPNswAWNQtw8nvupmsfWtwHBC8gnz5kaBNY3ur9WGesNgqk2QeafqgziBPEJkbqkHoTRtB4iKrgYweYeO0ppNY3ur9WGesNgq6He60CiJmKTiKPbFQMY3ur9WivaNoTjhmXBEYk8kaqJRxm68uM2tEkt7KG0kjlSvjakspLS0GpvNS4BQOEyKkGNSc344nAYYva2oLVPI6HbjKonGuSvjakGmYq2s9gvcGucDAxN2WXKv4vaGgxVy05PmTN8uM2jXPvswAWNQtw8nvupmsfWtwyRsauKEk5jpzXJWwGhpTskt7PvswyRsauKEkzfUXXB0KvOkGOE0u(NGOAJqVmIb6H0dj0P5qgP7qgV(adFtpbKjxidLdm8D04dbczKHmzHSfHmxby7ubQ(MubCk2Qeafqw2SqwOkGOE0ubQ(MubC6He60CiJ0DiJxFGHVPNaYKlKHYbg(oA8HaHmzswAWNQtw)M7QeanAEoyc(uDYtz(CALKf2QeafPNswHBC8gnzjlKfQciQhnL)jiQ2i0lJyGEi9qcDAoKrkK5dbA8YW30tazYfYKfYibqMCcz86dm8n9eqMmqw2SqwOkGOE0u(NGOAJqVmIb6H0FeKjdKrgY8HanEzedczlazHQaI6rt5FcIQnc9YigOhspKqNMNS0GpvNSckay0GpvBad3twGH7MwjWKv(aa4XtEktBNwjzHTkbqr6PKv4ghVrtwl1Bujas)C0WruKS0GpvNS4ikmvUju39J8P6KNYCntRKSWwLaOi9uYkCJJ3OjRfHSL6nQeaPFoA4ikGmYq2Iqw0HlnXbb1oL)jiQ2i0lJyGEiKrgYKfYCfGTtfO6BsfWPyRsauazKHSqvar9OPcu9nPc40dj0P5qgP7qgkhy47OXhceYidzlczQTeVXrAq5bvmDSjOaLy8xuSvjakGSSzHmzHmE9bg(MEciBHDiJKqgziJhHaGX1lgDoLJOWu5MqD3pYNQnAHqgPq2Zqw2SqgV(adFtpbKTWoK9mKrgY4riayC9IrNt5ikmvUju39J8PAJwiKTWoK9mKjdKrgYC9IrN6dbA8YigeYwaYwti7nKHYbg(oA8HaHmYqgpcbaJRxm6CkhrHPYnH6UFKpvB0cHSDiZoKLnlK56fJo1hc04LrmiKr6oKrcHS3qgkhy47OXhceYKlKXRpWW30tazYKS0GpvNS(n3vjaA08CWe8P6KNYKKPvswyRsauKEkzfUXXB0K1Iq2s9gvcG0phnCefqgziluTRXt1qgP7qwq5UXhceYEdzl1BujasJuHy64KLg8P6K1V5UkbqJMNdMGpvN8uMKG0kjlSvjakspLS0GpvNS(n3vjaA08CWe8P6Kv4ghVrtwlczl1Bujas)C0WruazKHmzHSfHmxby7ubQ(MubCk2Qeafqw2SqwOkGOE0ubQ(MubC6He60CiBbiZhc04LHVPNaYYMfY41hy4B6jGSfGm7qMmqgzitwiBriZva2oD5aqJRt7uSvjakGSSzHmE9bg(MEciBbiZoKjdKrgYcv7A8unKr6oKfuUB8HaHS3q2s9gvcG0iviMogYidzYczlczQTeVXrAq5bvmDSjOaLy8xuSvjakGSSzHmPFEonO8GkMo2euGsm(l6He60CiBbiZhc04LHVPNaYKjzfEfaOX1lgDEkt7jp5jp5jpLa]] )


end