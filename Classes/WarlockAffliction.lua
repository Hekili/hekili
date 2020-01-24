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


    spec:RegisterPack( "Affliction", 20200124, [[dCe8lcqibYJuQIUekrSjI4tkvH0OqPCkusRcLWRqPAwevDlbGDr4xkvAycOJPewMsv9mvjMMaKRPe12ea5BcqzCOeLZPufSouIQmpIu3tvSpIkhuauTqvj9qLQqnrbq5IOevQtIsujRuGAMOevv3uPke2PsKLIsuXtPKPQuXvvQcrFfLOQSxP6VumyehM0IPupwOjJQldTzP4ZsPrRuoTIxtKmBGBRQ2TKFlA4c64cq1Yv55inDQUok2UsQVRKmEuI05vLA9kvP5tu2pO7l670T4QJ9L2pW9dmWf7hqIfbgyGb0EOB5VdXUvOgLsBXUvPFSBfG30aMOpz1Tc13Gu59D6w0K5Iy3AZ9qklVD3TD8ngBrm)7sNpdq9jR4Pn(U05h3TBzZmaNLRQB3T4QJ9L2pW9dmWf7hqIfbgyGbuaRBrdXyFP9dql3T2gohRUD3IJ0y3ApHKa8MgWe9jliHLp9azukyW7jKS5EiLL3U72o(gJTiM)DPZNbO(Kv80gFx68J7cdEpHKG1IrV3qY(lKhs2pW9degmm49es2J30QfPS8GbVNqsaajb4CoYHeRqeaGew(ZOucyW7jKeaqsaoNJCijadxNmhKShH2orbm49escaiHLd(Z1ihsC9Ar3mncHag8EcjbaKWYbd4mZHqsawUdfsycHKSGexVw0HKM8GKamu9n7e4qcB0PIiKCyZH0nibKTtesgkKWNMg8WYHKPbs2JdWOqIEiKWhQAdqoRcyW7jKeaqclhmeOresO4A8uaK461IUWNpA80WhesIkfPqYQX3GeF(OXtdFqiHnS4qs2ajyftMYXJvr3k8YMbGDR9escWBAat0NSGew(0dKrPGbVNqYM7HuwE7UB74Bm2Iy(3LoFgG6twXtB8DPZpUlm49escwlg9Edj7VqEiz)a3pqyWWG3tizpEtRwKYYdg8EcjbaKeGZ5ihsScraasy5pJsjGbVNqsaajb4CoYHKamCDYCqYEeA7efWG3tijaGewo4pxJCiX1RfDZ0iecyW7jKeaqclhmGZmhcjby5ouiHjesYcsC9ArhsAYdscWq13StGdjSrNkIqYHnhs3Geq2orizOqcFAAWdlhsMgizpoaJcj6HqcFOQna5SkGbVNqsaajSCWqGgriHIRXtbqIRxl6cF(OXtdFqijQuKcjRgFds85Jgpn8bHe2WIdjzdKGvmzkhpwfWGHbVNqcl3SumY4ihsSXM8qijMFB1HeBSDkQascWJrm0PqsLvaSP3VHbajA0NSOqswG3cyW7jKOrFYIkcpmMFB1FAakvkyW7jKOrFYIkcpmMFB1z)z3Mm5WG3tirJ(KfveEym)2QZ(ZUkt7hlx9jlyWA0NSOIWdJ53wD2F2LY8)zzcrhgSg9jlQi8Wy(TvN9NDBV5NZHMSXq14nnteLFAECfGLlAV5NZHMSXq14nntefyP2aKddEpHen6twur4HX8BRo7p7slnKULUH6QtHbRrFYIkcpmMFB1z)z3W0NSGbRrFYIkcpmMFB1z)zxgkAgh)Yx6hF09s30tPMMSCt2ycZv4bdwJ(KfveEym)2QZ(ZUue5MSXeZ7yc9jl5NMhAicagxVw0PckICt2yI5DmH(KLrtuUNxKeegWzMWqKlweG2dVSiGGbRrFYIkcpmMFB1z)z3nLPCyWA0NSOIWdJ53wD2F2LUP8CLXobU8tZtqUcWYfBkt5cSuBaYLqdraW461IovqrKBYgtmVJj0NSmAIs)IKGWaoZegICXIa0E4LfbemyyW7jKWYnlfJmoYHeCnEVHeF(iK4BiKOrppizOqIUwhGAdqbmyn6tw0hAicagqgLcgSg9jlk7p7YX1jZz(A7eHbRrFYIY(ZUR1BuBakFPF8HHIgkIC5xRag8XvawUGMRm(gAOiYPcSuBaYLqdraW461IovqrKBYgtmVJj0NSmAIY98c7NoCdUglxm1AgqHNAdqbtOmzUcWYf0jClldyAqbwQna5sOHiayC9ArNkOiYnzJjM3Xe6twY9Sm7NoCdUglxm1AgqHNAdqbtOmz0qeamUETOtfue5MSXeZ7yc9jl5EyzSF6Wn4ASCXuRzafEQnafmHWG1Opzrz)z316nQnaLV0p(eQC(uTYNHpu0LFTcyWhn6twc6MYZvg7e4cKLIrghn(8rwO7fVXrruPrLpvRjQa9p(BbwQna5WG1Opzrz)z316nQnaLV0p(eQC(uTYNHphsrx(1kGbFAJC5NMhDV4nokIknQ8PAnrfO)XFlWsTbixcBUcWYf8tNYqtgGal1gGCzYCfGLl4O6B2jWfyP2aKljMjGNRkbhvFZobU4WVofv6N2iNvyWA0NSOS)S7A9g1gGYx6hF(6uUoLHIYVwbm4dnebaJRxl6ubfrUjBmX8oMqFYYOjk9Zc2DfGLlwDJVHMPmABwVfyP2aKZURaSCHAttaJJMyEhtOpzjWsTbiNf7ZoBUcWYfRUX3qZugTnR3cSuBaYL4kalxqZvgFdnue5ubwQna5sOHiayC9ArNkOiYnzJjM3Xe6twgnr52Nv2zZvawUGoHBzzatdkWsTbixsqUcWYfXdXWPAnCu9nbwQna5scYvawUGF6ugAYaeyP2aKZk7NoCdUglxm1AgqHNAdqbtimyn6twu2F2DTEJAdq5l9Jp80PgMq5xRag8HTGCfGLlOt4wwgW0GcSuBaYLjJNUGoHBzzatdkyczvcpDH2M1Bb11OuY9SiqjbXtxOTz9wCyZH0n1gGs4PlI5DmH(KLGjegSg9jlk7p7gvaWOrFYYagQlFPF8jMjGNRkkmyn6twu2F2LF6ugAYaKFkhVJj0nTG0wbplKpUPt9Sq(47ianUETOtFwi)084ZhnEA4dk9tBKlHMmadDtpU0lddwJ(KfL9ND3uMYLFAEOHiayC9ArNkOiYnzJjM3Xe6twgnrPF2N9thUbxJLlMAndOWtTbOGjegSg9jlk7p7sz()SmC9KQfOhk)08WtxOTz9w4tuQPALWtxeZ7yc9jlHprPMQvcB2mnncn6ZA0WOub11Ouplltgnzag6ME8NaLjJNUiCtlp)g6uTma9g)T4WVofvcpDr4MwE(n0PAza6n(BXHFDkQ0pTroRsylixby5IWnT88BOt1Ya0B83cSuBaYLjJNUiCtlp)g6uTma9g)T4WVofLvjSfKRaSCbhvFZobUal1gGCzYIzc45QsWr13StGlo8RtrL(PnYLjlOyMaEUQeCu9n7e4Id)6uuzYOHiayC9ArNkOiYnzJjM3Xe6twgnr5wW(Pd3GRXYftTMbu4P2auWeYkmyn6twu2F2LJQVzNax(P5jMjGNRkbL5)ZYW1tQwGEO4WVofvYA9g1gGcE6udtOeAicagxVw0PckICt2yI5DmH(KLrt8zb7NoCdUglxm1AgqHNAdqbtOe2ccPuSIOy9qNSmzJjeVgm6twI)u5jjiDV4nok4hQ8ggGjQaWuTItlPKjlMjGNRkbL5)ZYW1tQwGEO4WVofvUxcKvyWA0NSOS)SRVHgMYozkUPjVik)08yZ00iomkfaPuttEruC4xNIcdwJ(KfL9ND12SElF8DeGgxVw0PplKFAEo8RtrL(PnYzxJ(KLGUP8CLXobUazPyKXrJpFuIpF04PHpOCSmyWA0NSOS)S7h)592KngatC4g(H6Nk)084ZhL(LaHbVNqYo4pmp9Edjndlfs8es(QuiKqzoes09s30t3JsHKMSCiHNiT2J6qI9HQuqcxpPAb6HqcdvBrbmyn6twu2F2vBZ6T8GPqtK)8sGYpnp(8r5EjqjXmb8CvjOm)FwgUEs1c0dfh(1POs)SyzjyaNzcdrUyraAp8YIacgSg9jlk7p7gZ7yc9jl5btHMi)5LaLFAE85JY9sGsIzc45Qsqz()SmC9KQfOhko8RtrL(zXYsWaoZegICXIa0E4LfbKKGCfGLluBAcyC0eZ7yc9jlbwQna5syZvawUGoHBzzatdkWsTbixMmAicagxVw0PckICt2yI5DmH(KLrtuUfsOHiayC9ArNkOiYnzJjM3Xe6twgnrPFEHvyWA0NSOS)SlDc3YYaMguEWuOjYFEjq5NMhF(OCVeOKyMaEUQeuM)pldxpPAb6HId)6uuPFwSSemGZmHHixSiaThEzrabdwJ(KfL9NDzkQR2a0OnnGj6twYhFhbOX1RfD6Zc5NMNGIz5A7KLeF(OXtdFqPFyzWG1Opzrz)zx(PtzOjdq(47ianUETOtFwiFuRicmtZJprPOMd)6usVS8tZJRaSCbDt55kd(TpnIcSuBaYLSwVrTbO4Rt56ugkkHJ2mnnc6MYZvg8BFAefh(1POs4OnttJGUP8CLb)2NgrXHFDkQ0pTrol2hgSg9jlk7p7s3uEUYyNax(47ianUETOtFwi)084kalxq3uEUYGF7tJOal1gGCjR1BuBak(6uUoLHIs4OnttJGUP8CLb)2NgrXHFDkQeoAZ00iOBkpxzWV9PruC4xNIk9dYsXiJJgF(il2ND)01iW4ZhLeKg9jlbDt55kJDcCXuMgW0U5WG1Opzrz)z3WnT88BOt1Ya0B83YhFhbOX1RfD6Zc5NMhF(OCVSSexVw0f(8rJNg(GYTiaXcAicaMnL6Oe2ccPuSIOy9qNSmzJjeVgm6twI)u5jjiDV4nok4hQ8ggGjQaWuTItlPKjlMjGNRkbL5)ZYW1tQwGEO4WVofvUaAz2PjdWq30JZcDV4nok4hQ8ggGjQaWuTItlPKjlMjGNRkbL5)ZYW1tQwGEO4WVofv6flZcAicaMnL6i70KbyOB6XzHUx8ghf8dvEddWevayQwXPLuScdwJ(KfL9NDzkQR2a0OnnGj6twYhFhbOX1RfD6Zc5NMNGwR3O2auWqrdfrUeAYam0n94plddwJ(KfL9NDPiYnzJjM3Xe6twYpnpR1BuBakyOOHIixcnzag6ME8NLHbRrFYIY(ZUrfamA0NSmGH6Yx6hF4PtHbRrFYIY(ZURhaACDkx(47ianUETOtFwi)084ZhLBXYs85Jgpn8bL7zrGsylMjGNRkbL5)ZYW1tQwGEO4WVofvUxcuMSyMaEUQeuM)pldxpPAb6HId)6uuPxeOeE6cTnR3Id)6uu5EweOeE6IyEhtOpzjo8RtrL7zrGsyJNUGoHBzzatdko8RtrL7zrGYKfKRaSCbDc3YYaMguGLAdqoRScdwJ(KfL9NDzOOzC8lFPF8r3lDtpLAAYYnzJjmxHN8tZJpFu6NxGbRrFYIY(ZUHBA553qNQLbO34VLFAE85Js)8YYWG1Opzrz)z31danUoLl)084ZhLEXYWG1Opzrz)z3wg94JwMSXO7fV03KFAEylMjGNRkbL5)ZYW1tQwGEO4WVofv6flZonzag6MECwO7fVXrb)qL3WamrfaMQvGLAdqUmzSP7fVXrb)qL3WamrfaMQvCAjLmziLIvefRh6KLjBmH41GrFYsCAjfRs85JY9sGs85Jgpn8bL7z)fbYQe24Plc30YZVHovldqVXFlo8RtrLjJNUy9aqJRt5Id)6uuzYcYvawUiCtlp)g6uTma9g)Tal1gGCjb5kalxSEaOX1PCbwQna5SktMpF04PHpO0Vei7Tromyn6twu2F2LRNugAYaKFAEIzc45Qsqz()SmC9KQfOhko8RtrLEXYSttgGHUPhNf6EXBCuWpu5nmatubGPAfyP2aKlHnE6IWnT88BOt1Ya0B83Id)6uuzY4Plwpa046uU4WVofLvyWA0NSOS)SRnEu8KAQwyWA0NSOS)SBubaJg9jldyOU8L(XhAiwC8OWG1Opzrz)z3Ocagn6twgWqD5l9JpndaGhfgmmyn6twurmtapxv0Nv5b4RXPmhsZsRicdwJ(KfveZeWZvfL9NDzOOzC8lFPF8r3lDtpLAAYYnzJjmxHN8tZdBb5kalxeUPLNFdDQwgGEJ)wGLAdqUmzXmb8Cvjc30YZVHovldqVXFlo8RtrLoGybnebaZMsDuMSGIzc45QseUPLNFdDQwgGEJ)wC4xNIYQKyMaEUQeuM)pldxpPAb6HId)6uuPxShybnebaZMsDKDAYam0n94Sq3lEJJc(HkVHbyIkamvR40skj80fABwVfh(1POs4PlI5DmH(KL4WVofvcB80f0jClldyAqXHFDkQmzb5kalxqNWTSmGPbfyP2aKZkmyn6twurmtapxvu2F2nm9jl5NMh2CfGLl46jLHMmaZFO49wGLAdqUKyMaEUQeuM)pldxpPAb6HcMqjXmb8Cvj46jLHMmabtiRYKfZeWZvLGY8)zz46jvlqpuWektMpF04PHpO0Veimyn6twurmtapxvu2F2LHIMXXpv(P5jMjGNRkbL5)ZYW1tQwGEO4WVofvUawGYK5ZhnEA4dk9(bktgBSzZ00i0OpRrdJsfuxJs9SSmz0KbyOB6XFcKvjSfKRaSCr4MwE(n0PAza6n(BbwQna5YKfZeWZvLiCtlp)g6uTma9g)T4WVofLvjSfKRaSCbhvFZobUal1gGCzYIzc45QsWr13StGlo8RtrL(PnYLjlOyMaEUQeCu9n7e4Id)6uuwLeumtapxvckZ)NLHRNuTa9qXHFDkkRWG1OpzrfXmb8Cvrz)z3M5qBqMC5NMNGIzc45Qsqz()SmC9KQfOhkycHbRrFYIkIzc45QIY(ZU2Gm5MgM7T8tZtqXmb8CvjOm)FwgUEs1c0dfmHWG1OpzrfXmb8Cvrz)z3p(Z7TjBmaM4Wn8d1pv(P5XNpk3lbcdwJ(KfveZeWZvfL9ND56jLHMma5NMhF(OXtdFqP3pq2BJCzYCfGLlO5kJVHgkICQal1gGCjXmb8CvjOm)FwgUEs1c0dfh(1POY9eZeWZvLGY8)zz46jvlqpuWzo1NScGfbcdwJ(KfveZeWZvfL9NDTbzYnzJX3qdw4)T8tZti6cUEs1c0dfh(1POYKXwqXmb8Cvj4O6B2jWfh(1POYKfKRaSCbhvFZobUal1gGCwLeZeWZvLGY8)zz46jvlqpuC4xNIk3dllqjiLIvef2Gm5MSX4BObl8)wCAjLClGbVNqYEKues46xBNQfsYkayOiK43usHofs(5HqsEqcaPuijlijMjGNRk5HeAcjGSAHeLcj(gcjSCThhGbj(g(gsMkYCqYQS2J6qc20Grhs06nKK(gEqIFtjf6uiHHQTiKWzUPAHKyMaEUQOcyWA0NSOIyMaEUQOS)SldfnJJF5l9JpHzuk0PZErUjM)qgx9jldhxpru(P5HTyMaEUQeuM)pldxpPAb6HId)6uu5E2FzzY85Jgpn8bL(5LazvcBXmb8Cvj4O6B2jWfh(1POYKfKRaSCbhvFZobUal1gGCwHbRrFYIkIzc45QIY(ZUmu0mo(LV0p(CPhpgQJCZ6m5zA4jai)08WwmtapxvckZ)NLHRNuTa9qXHFDkQCp7VSmz(8rJNg(Gs)8sGSkHTyMaEUQeCu9n7e4Id)6uuzYcYvawUGJQVzNaxGLAdqoRWG1OpzrfXmb8Cvrz)zxgkAgh)Yx6hFOBZA8mRXk)Mdbtu(P5HTyMaEUQeuM)pldxpPAb6HId)6uu5E2FzzY85Jgpn8bL(5LazvcBXmb8Cvj4O6B2jWfh(1POYKfKRaSCbhvFZobUal1gGCwHbRrFYIkIzc45QIY(ZUmu0mo(LV0p(ObCMjmDSCtPm(ayOYpnpSfZeWZvLGY8)zz46jvlqpuC4xNIk3Z(lltMpF04PHpO0pVeiRsylMjGNRkbhvFZobU4WVofvMSGCfGLl4O6B2jWfyP2aKZkmyn6twurmtapxvu2F2LHIMXXV8L(XhF4i1Z7BIjhzPYpnpSfZeWZvLGY8)zz46jvlqpuC4xNIk3Z(lltMpF04PHpO0pVeiRsylMjGNRkbhvFZobU4WVofvMSGCfGLl4O6B2jWfyP2aKZkmyn6twurmtapxvu2F2LHIMXXV8L(XN1JcmzJH659PYpnpSfZeWZvLGY8)zz46jvlqpuC4xNIk3Z(lltMpF04PHpO0pVeiRsylMjGNRkbhvFZobU4WVofvMSGCfGLl4O6B2jWfyP2aKZkmyn6twurmtapxvu2F29MWqaAMYqd1icdggSg9jlQGBBoS5q62dDc3YYaMguEWuOjYFwSS8tZdB80f0jClldyAqXHFDkklHNUGoHBzzatdk4mN6twSk9dB80fABwVfh(1POSeE6cTnR3coZP(KfRsyJNUGoHBzzatdko8Rtrzj80f0jClldyAqbN5uFYIvPFyJNUiM3Xe6twId)6uuwcpDrmVJj0NSeCMt9jlwLWtxqNWTSmGPbfh(1POsZtxqNWTSmGPbfCMt9jlwSq8cmyn6twub32CyZH0n2F2vBZ6T8GPqtK)Syz5NMh24Pl02SElo8Rtrzj80fABwVfCMt9jlwL(HnE6IyEhtOpzjo8Rtrzj80fX8oMqFYsWzo1NSyvcB80fABwVfh(1POSeE6cTnR3coZP(KfRs)WgpDbDc3YYaMguC4xNIYs4PlOt4wwgW0GcoZP(KfRs4Pl02SElo8RtrLMNUqBZ6TGZCQpzXIfIxGbRrFYIk42MdBoKUX(ZUX8oMqFYsEWuOjYFwSS8tZdB80fX8oMqFYsC4xNIYs4PlI5DmH(KLGZCQpzXQ0pSXtxOTz9wC4xNIYs4Pl02SEl4mN6twSkHnE6IyEhtOpzjo8Rtrzj80fX8oMqFYsWzo1NSyv6h24PlOt4wwgW0GId)6uuwcpDbDc3YYaMguWzo1NSyvcpDrmVJj0NSeh(1POsZtxeZ7yc9jlbN5uFYIfleVadggSg9jlQGNo9HIi3KnMyEhtOpzj)08WtxeZ7yc9jlXHFDkQ0pA0NSeue5MSXeZ7yc9jlruPUXNpYUpF04PHUPhN9asSplyBra4kalxepedNQ1Wr13eyP2aKZIaflwMvj0qeamUETOtfue5MSXeZ7yc9jlJMOCpVW(Pd3GRXYftTMbu4P2auWeYURaSCXQB8n0mLrBZ6Tal1gGCjbXtxqrKBYgtmVJj0NSeh(1POscsJ(KLGIi3KnMyEhtOpzjMY0aM2nhgSg9jlQGNoL9ND12SElF8DeGgxVw0PplKFAECfGLlIhIHt1A4O6BcSuBaYLOrFwJgE6cTnR3shGK4ZhnEA4dk3IaLW2HFDkQ0pTrUmzXmb8CvjOm)FwgUEs1c0dfh(1POYTiqjSD4xNIk9YYKfKUx8ghfHAXX)entToJQpzjoTKsYHnhs3uBaYkRWG1Opzrf80PS)SR2M1B5JVJa0461Io9zH8tZtqUcWYfXdXWPAnCu9nbwQna5s0OpRrdpDH2M1BPzzs85Jgpn8bLBrGsy7WVofv6N2ixMSyMaEUQeuM)pldxpPAb6HId)6uu5weOe2o8RtrLEzzYcs3lEJJIqT44FIMPwNr1NSeNwsj5WMdPBQnazLvyWA0NSOcE6u2F2LoHBzzatdkF8DeGgxVw0PplKFAEytJ(Sgn80f0jClldyAqPzzbGRaSCr8qmCQwdhvFtGLAdqEaqdraW461IovqZvgFdnue5uJMiRs85Jgpn8bLBrGsoS5q6MAdqjSf0HFDkQeAicagxVw0PckICt2yI5DmH(KLrt8zHmzXmb8CvjOm)FwgUEs1c0dfh(1POYrtgGHUPhNfA0NSemf1vBaA0MgWe9jlbYsXiJJgF(iRWG1Opzrf80PS)SBmVJj0NSKp(ocqJRxl60NfYpnp0qeamUETOtfue5MSXeZ7yc9jlJMO0VW(Pd3GRXYftTMbu4P2auWeYURaSCXQB8n0mLrBZ6Tal1gGCjSD4xNIk9tBKltwmtapxvckZ)NLHRNuTa9qXHFDkQClcuYHnhs3uBaYQexVw0f(8rJNg(GYTiqyWWG1OpzrfndaGh9HPOUAdqJ20aMOpzjpyk0e5plww(P5jMjGNRkbhvFZobU4WVofv6N2iNf7lHgIaGX1RfDQGIi3KnMyEhtOpzz0eFwW(Pd3GRXYftTMbu4P2auWekjMjGNRkbL5)ZYW1tQwGEO4WVofvU9degSg9jlQOzaa8OS)SBubaJg9jldyOU8L(XhUT5WMdPBYpnpUcWYfCu9n7e4cSuBaYLqdraW461IovqrKBYgtmVJj0NSmAIply)0HBW1y5IPwZak8uBakycLWgpDH2M1BXHFDkQ080fABwVfCMt9jlweOiGTSmz80fX8oMqFYsC4xNIknpDrmVJj0NSeCMt9jlweOiGTSmz80f0jClldyAqXHFDkQ080f0jClldyAqbN5uFYIfbkcylZQKyMaEUQeCu9n7e4Id)6uuPF0Opzj02SElAJCweqsIzc45Qsqz()SmC9KQfOhko8RtrLB)aHbRrFYIkAgaapk7p7gvaWOrFYYagQlFPF8HBBoS5q6M8tZJRaSCbhvFZobUal1gGCj0qeamUETOtfue5MSXeZ7yc9jlJM4Zc2pD4gCnwUyQ1mGcp1gGcMqjXmb8CvjOm)FwgUEs1c0dfh(1POs)qtgGHUPhNfA0NSeABwVfTro7A0NSeABwVfTrolErcB80fABwVfh(1POsZtxOTz9wWzo1NSyXczY4PlI5DmH(KL4WVofvAE6IyEhtOpzj4mN6twSyHmz80f0jClldyAqXHFDkQ080f0jClldyAqbN5uFYIflyfgSg9jlQOzaa8OS)SlhvFZobU8tZZA9g1gGcE6udtOe2Izc45Qsqz()SmC9KQfOhko8RtrL75LazVnYLjlMjGNRkbL5)ZYW1tQwGEO4WVofvUfbuGScdwJ(Kfv0maaEu2F2LUP8CLXobU8tZJnttJ4NRXpwUGjuInttJOM2nVrbaXHFDkkmyn6twurZaa4rz)zxTnR3Ypnp2mnnIFUg)y5cMqjbXMRaSCbDc3YYaMguGLAdqUe2cpCTPnYfleABwVLeE4AtBKl2xOTz9ws4HRnTrU4fH2M1BwLjl8W1M2ixSqOTz9MvyWA0NSOIMbaWJY(ZU0jClldyAq5NMhBMMgXpxJFSCbtOKGyl8W1M2ixSqqNWTSmGPbLeE4AtBKl2xqNWTSmGPbLeE4AtBKlErqNWTSmGPbzfgSg9jlQOzaa8OS)SBmVJj0NSKFAESzAAe)Cn(XYfmHsck8W1M2ixSqeZ7yc9jljb5kalxO20eW4OjM3Xe6twcSuBaYHbRrFYIkAgaapk7p7YpDkdyAq5NMhBMMgXu46XvBaA44FOOG6Auk5weOeF(OXtdFqPFweimyn6twurZaa4rz)zx(Ptzatdk)084kalxqNWTSmGPbfyP2aKlXMPPrmfUEC1gGgo(hkkOUgLsUNLdma2pqwWgnebaJRxl6ubfrUjBmX8oMqFYYOjgaNoCdUglxm1AgqHNAdqbtOCp7ZQeE6cTnR3Id)6uu5wMf0qeamBk1rj80fX8oMqFYsC4xNIkxBKlHnE6c6eULLbmnO4WVofvU2ixMSGCfGLlOt4wwgW0GcSuBaYzvcBC0MPPrSPmLlo8RtrLBzwqdraWSPuhLjlixby5InLPCbwQna5SkjMLRTtwYTmlOHiay2uQJWG1OpzrfndaGhL9ND5NoLbmnO8tZJRaSCXQB8n0mLrBZ6Tal1gGCj2mnnIPW1JR2a0WX)qrb11OuY9SCGbW(bYc2OHiayC9ArNkOiYnzJjM3Xe6twgnXa40HBW1y5IPwZak8uBakycL75fwdGLzbB0qeamUETOtfue5MSXeZ7yc9jlJMyaC6Wn4ASCXuRzafEQnafmHp7ZQeE6cTnR3Id)6uu5wMf0qeamBk1rj80fX8oMqFYsC4xNIkxBKlHnoAZ00i2uMYfh(1POYTmlOHiay2uQJYKfKRaSCXMYuUal1gGCwLeZY12jl5wMf0qeamBk1ryWA0NSOIMbaWJY(ZU8tNYaMgu(P5XvawUqTPjGXrtmVJj0NSeyP2aKlXMPPrmfUEC1gGgo(hkkOUgLsUNLdma2pqwWgnebaJRxl6ubfrUjBmX8oMqFYYOjgaNoCdUglxm1AgqHNAdqbtOCpbeRs4Pl02SElo8RtrLBzwqdraWSPuhLWghTzAAeBkt5Id)6uu5wMf0qeamBk1rzYcYvawUytzkxGLAdqoRsIz5A7KLClZcAicaMnL6imyn6twurZaa4rz)z3nLPCyWA0NSOIMbaWJY(ZUnzKHICJUx8ghn2O(HbRrFYIkAgaapk7p7gYCtZ7PAn2aL6WG1OpzrfndaGhL9NDJzfXYp1rUPbOFu(P5jiE6IywrS8tDKBAa6hn2mxjo8RtrLeKg9jlrmRiw(PoYnna9JIPmnGPDZHbRrFYIkAgaapk7p7YpDkdnzaYpLJ3Xe6MwqARGNfYh30PEwi)uoEhtO)Sq(47ianUETOtFwi)084ZhnEA4dk9tBKddwJ(Kfv0maaEu2F2LF6ugAYaKp(ocqJRxl60NfYh30PEwi)uoEhtOBMMhFIsrnh(1PKEz5NYX7ycDtliTvWZc5NMhxby5c6MYZvg8BFAefyP2aKlzTEJAdqXxNY1PmuusqC0MPPrq3uEUYGF7tJO4WVoffgSg9jlQOzaa8OS)Sl)0Pm0KbiF8DeGgxVw0PplKpUPt9Sq(PC8oMq3mnp(eLIAo8Rtj9YYpLJ3Xe6MwqARGNfYpnpUcWYf0nLNRm43(0ikWsTbixYA9g1gGIVoLRtzOimyn6twurZaa4rz)zx(PtzOjdq(PC8oMq30csBf8Sq(4Mo1Zc5NYX7yc9NfWG1OpzrfndaGhL9NDPBkpxzStGlF8DeGgxVw0PplKFAECfGLlOBkpxzWV9PruGLAdqUK16nQnafFDkxNYqrjbXrBMMgbDt55kd(TpnIId)6uujbPrFYsq3uEUYyNaxmLPbmTBomyn6twurZaa4rz)zx6MYZvg7e4YhFhbOX1RfD6Zc5NMhxby5c6MYZvg8BFAefyP2aKlzTEJAdqXxNY1PmuegSg9jlQOzaa8OS)SlDt55kJDcCyWWG1Opzrf0qS44rFykQR2a0OnnGj6twYpnpXmb8CvjOm)FwgUEs1c0dfh(1POs)qtgGHUPhNfSHSumY4OXNpYUUx8ghf8dvEddWevayQwXPLuSkHTGCfGLl4O6B2jWfyP2aKltwmtapxvcoQ(MDcCXHFDkQ0p0KbyOB6XzbYsXiJJgF(iRsyZvawUGMRm(gAOiYPcSuBaYLjJNUiCtlp)g6uTma9g)T4WVofvMmE6I1danUoLlo8RtrzfgSg9jlQGgIfhpk7p7gvaWOrFYYagQlFPF8Pzaa8OYpnpSfZeWZvLGY8)zz46jvlqpuC4xNIkTpF04PHUPhNfSTCaqtgGHUPhNvzYIzc45Qsqz()SmC9KQfOhkyczvIpF04PHpOCXmb8CvjOm)FwgUEs1c0dfh(1POWG1Opzrf0qS44rz)zxkICt2yI5DmH(KL8tZZA9g1gGcgkAOiYHbRrFYIkOHyXXJY(ZUmf1vBaA0MgWe9jl5NMNGwR3O2auWqrdfrUKGcpCTPnYfleuM)pldxpPAb6HsyZvawUGJQVzNaxGLAdqUKyMaEUQeCu9n7e4Id)6uuPFqwkgzC04ZhLeKUx8ghfrLgv(uTMOc0)4VfyP2aKltgB0KbyOB6XL7zzj0qeamUETOtfue5MSXeZ7yc9jlJMO07ltgnzag6MEC5E2xcnebaJRxl6ubfrUjBmX8oMqFYYOjk3Z(SkX1RfDHpF04PHpOCbe7ilfJmoA85JsOHiayC9ArNkOiYnzJjM3Xe6twgnXNfYK5ZhnEA4dk9dlJDKLIrghn(8rwqtgGHUPhNvyWA0NSOcAiwC8OS)SltrD1gGgTPbmrFYs(P5jO16nQnafmu0qrKljMLRTtws)evQB85JSVwVrTbOiu58PAHbRrFYIkOHyXXJY(ZUmf1vBaA0MgWe9jl5JVJa0461Io9zH8tZtqR1BuBakyOOHIixcBb5kalxWr13StGlWsTbixMSyMaEUQeCu9n7e4Id)6uu585Jgpn0n94YKrtgGHUPhxUfSkHTGCfGLlwpa046uUal1gGCzYOjdWq30Jl3cwLeZY12jlPFIk1n(8r2xR3O2aueQC(uTsyliDV4nokIknQ8PAnrfO)XFlWsTbixMmBMMgruPrLpvRjQa9p(BXHFDkQC(8rJNg6MECw7wRXJoz1xA)axShcKLTiWU1k9QPAPDlwU(H55ihscyqIg9jlibmuNkGb3TugFlVUL183J7wGH60(oDlUT5WMdPB9D6lTOVt3cl1gG8(RDln6twDl6eULLbmny3kEJJ3ODl2GeE6c6eULLbmnO4WVoffsyjqcpDbDc3YYaMguWzo1NSGewHePFGe2GeE6cTnR3Id)6uuiHLaj80fABwVfCMt9jliHvircKWgKWtxqNWTSmGPbfh(1POqclbs4PlOt4wwgW0GcoZP(KfKWkKi9dKWgKWtxeZ7yc9jlXHFDkkKWsGeE6IyEhtOpzj4mN6twqcRqIeiHNUGoHBzzatdko8RtrHePHeE6c6eULLbmnOGZCQpzbjSaswiEPBbMcnrE3AXYDVV0(9D6wyP2aK3FTBPrFYQBPTz9UBfVXXB0UfBqcpDH2M1BXHFDkkKWsGeE6cTnR3coZP(KfKWkKi9dKWgKWtxeZ7yc9jlXHFDkkKWsGeE6IyEhtOpzj4mN6twqcRqIeiHniHNUqBZ6T4WVoffsyjqcpDH2M1BbN5uFYcsyfsK(bsyds4PlOt4wwgW0GId)6uuiHLaj80f0jClldyAqbN5uFYcsyfsKaj80fABwVfh(1POqI0qcpDH2M1BbN5uFYcsybKSq8s3cmfAI8U1IL7EFPx670TWsTbiV)A3sJ(Kv3kM3Xe6twDR4noEJ2Tyds4PlI5DmH(KL4WVoffsyjqcpDrmVJj0NSeCMt9jliHvir6hiHniHNUqBZ6T4WVoffsyjqcpDH2M1BbN5uFYcsyfsKajSbj80fX8oMqFYsC4xNIcjSeiHNUiM3Xe6twcoZP(KfKWkKi9dKWgKWtxqNWTSmGPbfh(1POqclbs4PlOt4wwgW0GcoZP(KfKWkKibs4PlI5DmH(KL4WVoffsKgs4PlI5DmH(KLGZCQpzbjSaswiEPBbMcnrE3AXYDV7Dlo2OmaVVtFPf9D6wA0NS6w0qeamGmkv3cl1gG8(RDVV0(9D6wA0NS6wCCDYCMV2oXUfwQna59x7EFPx670TWsTbiV)A3kd7wu07wA0NS6wR1BuBa2TwRagSB5kalxqZvgFdnue5ubwQna5qIeiHgIaGX1RfDQGIi3KnMyEhtOpzz0eHe5EGKxGe2HKthUbxJLlMAndOWtTbOGjesKjdsCfGLlOt4wwgW0GcSuBaYHejqcnebaJRxl6ubfrUjBmX8oMqFYcsK7bswgsyhsoD4gCnwUyQ1mGcp1gGcMqirMmiHgIaGX1RfDQGIi3KnMyEhtOpzbjY9ajSmiHDi50HBW1y5IPwZak8uBakyc7wR1Zu6h7wmu0qrK39(sbuFNUfwQna59x7wzy3IIE3sJ(Kv3ATEJAdWU1AfWGDln6twc6MYZvg7e4cKLIrghn(8riHfqIUx8ghfrLgv(uTMOc0)4VfyP2aK3TwRNP0p2TcvoFQ2U3xA5(oDlSuBaY7V2TYWU1Hu07wA0NS6wR1BuBa2TwRagSB1g5DR4noEJ2T09I34OiQ0OYNQ1evG(h)Tal1gGCircKWgK4kalxWpDkdnzacSuBaYHezYGexby5coQ(MDcCbwQna5qIeijMjGNRkbhvFZobU4WVoffsK(bsAJCiH1U1A9mL(XUvOY5t129(sbO(oDlSuBaY7V2TYWUff9ULg9jRU1A9g1gGDR1kGb7w0qeamUETOtfue5MSXeZ7yc9jlJMiKi9dKSasyhsCfGLlwDJVHMPmABwVfyP2aKdjSdjUcWYfQnnbmoAI5DmH(KLal1gGCiHfqY(qc7qcBqIRaSCXQB8n0mLrBZ6Tal1gGCircK4kalxqZvgFdnue5ubwQna5qIeiHgIaGX1RfDQGIi3KnMyEhtOpzz0eHe5GK9HewHe2He2Gexby5c6eULLbmnOal1gGCircKeeK4kalxepedNQ1Wr13eyP2aKdjsGKGGexby5c(PtzOjdqGLAdqoKWkKWoKC6Wn4ASCXuRzafEQnafmHDR16zk9JDRVoLRtzOy37lfW670TWsTbiV)A3kd7wu07wA0NS6wR1BuBa2TwRagSBXgKeeK4kalxqNWTSmGPbfyP2aKdjYKbj80f0jClldyAqbtiKWkKibs4Pl02SElOUgLcsK7bsweiKibsccs4Pl02SEloS5q6MAdqircKWtxeZ7yc9jlbty3ATEMs)y3INo1We29(sSS(oDlSuBaY7V2T0Opz1TIkay0Opzzad17wGH6Ms)y3kMjGNRkA37lTh670TWsTbiV)A3sJ(Kv3IF6ugAYa6wX3raAC9ArN2xAr3kEJJ3ODlF(OXtdFqir6hiPnYHejqcnzag6MECirAiz5UvCtNQBTOBnLJ3Xe6MwqARGU1IU3xArG9D6wyP2aK3FTBfVXXB0UfnebaJRxl6ubfrUjBmX8oMqFYYOjcjs)aj7djSdjNoCdUglxm1AgqHNAdqbty3sJ(Kv3AtzkV79LwSOVt3cl1gG8(RDR4noEJ2T4Pl02SEl8jk1uTqIeiHNUiM3Xe6twcFIsnvlKibsydsSzAAeA0N1OHrPcQRrPGKhizzirMmiHMmadDtpoK8ajbcjYKbj80fHBA553qNQLbO34Vfh(1POqIeiHNUiCtlp)g6uTma9g)T4WVoffsK(bsAJCiHvircKWgKeeK4kalxeUPLNFdDQwgGEJ)wGLAdqoKitgKWtxeUPLNFdDQwgGEJ)wC4xNIcjScjsGe2GKGGexby5coQ(MDcCbwQna5qImzqsmtapxvcoQ(MDcCXHFDkkKi9dK0g5qImzqsqqsmtapxvcoQ(MDcCXHFDkkKitgKqdraW461IovqrKBYgtmVJj0NSmAIqICqYciHDi50HBW1y5IPwZak8uBakycHew7wA0NS6wuM)pldxpPAb6HDVV0I9770TWsTbiV)A3kEJJ3ODRyMaEUQeuM)pldxpPAb6HId)6uuircKSwVrTbOGNo1WecjsGeAicagxVw0PckICt2yI5DmH(KLrtesEGKfqc7qYPd3GRXYftTMbu4P2auWecjsGe2GKGGeKsXkII1dDYYKnMq8AWOpzj(tLhKibsccs09I34OGFOYByaMOcat1koTKcsKjdsIzc45Qsqz()SmC9KQfOhko8RtrHe5GKxcesyTBPrFYQBXr13StG39(slEPVt3cl1gG8(RDR4noEJ2TSzAAehgLcGuQPjViko8Rtr7wA0NS6w(gAyk7KP4MM8Iy37lTiG670TWsTbiV)A3sJ(Kv3sBZ6D3kEJJ3ODRd)6uuir6hiPnYHe2Hen6twc6MYZvg7e4cKLIrghn(8rircK4ZhnEA4dcjYbjSSUv8DeGgxVw0P9Lw09(slwUVt3cl1gG8(RDR4noEJ2T85JqI0qYlb2T0Opz1T(4pV3MSXayId3Wpu)0U3xAraQVt3cl1gG8(RDln6twDlTnR3DR4noEJ2T85JqICqYlbcjsGKyMaEUQeuM)pldxpPAb6HId)6uuir6hizXYqIeibd4mtyiYf6EPB6PuttwUjBmH5k86wGPqtK3TEjWU3xAraRVt3cl1gG8(RDln6twDRyEhtOpz1TI344nA3YNpcjYbjVeiKibsIzc45Qsqz()SmC9KQfOhko8RtrHePFGKfldjsGemGZmHHixO7LUPNsnnz5MSXeMRWdsKajbbjUcWYfQnnbmoAI5DmH(KLal1gGCircKWgK4kalxqNWTSmGPbfyP2aKdjYKbj0qeamUETOtfue5MSXeZ7yc9jlJMiKihKSasKaj0qeamUETOtfue5MSXeZ7yc9jlJMiKi9dK8cKWA3cmfAI8U1lb29(slyz9D6wyP2aK3FTBPrFYQBrNWTSmGPb7wXBC8gTB5ZhHe5GKxcesKajXmb8CvjOm)FwgUEs1c0dfh(1POqI0pqYILHejqcgWzMWqKl09s30tPMMSCt2ycZv41TatHMiVB9sGDVV0I9qFNUfwQna59x7wA0NS6wmf1vBaA0MgWe9jRUv8ghVr7wbbjXSCTDYcsKaj(8rJNg(GqI0pqclRBfFhbOX1RfDAFPfDVV0(b23PBHLAdqE)1ULg9jRUf)0Pm0Kb0TIVJa0461IoTV0IUvuRicmtt3YNOuuZHFDkPxUBfVXXB0ULRaSCbDt55kd(TpnIcSuBaYHejqYA9g1gGIVoLRtzOiKibs4OnttJGUP8CLb)2NgrXHFDkkKibs4OnttJGUP8CLb)2NgrXHFDkkKi9dK0g5qclGK97EFP9x03PBHLAdqE)1ULg9jRUfDt55kJDc8Uv8ghVr7wUcWYf0nLNRm43(0ikWsTbihsKajR1BuBak(6uUoLHIqIeiHJ2mnnc6MYZvg8BFAefh(1POqIeiHJ2mnnc6MYZvg8BFAefh(1POqI0pqcYsXiJJgF(iKWcizFiHDiXpDncm(8rircKeeKOrFYsq3uEUYyNaxmLPbmTBE3k(ocqJRxl60(sl6EFP93VVt3cl1gG8(RDln6twDRWnT88BOt1Ya0B83DR4noEJ2T85JqICqYlldjsGexVw0f(8rJNg(GqICqYIaeKWciHgIaGztPocjsGe2GKGGeKsXkII1dDYYKnMq8AWOpzj(tLhKibsccs09I34OGFOYByaMOcat1koTKcsKjdsIzc45Qsqz()SmC9KQfOhko8RtrHe5GKaAziHDiHMmadDtpoKWcir3lEJJc(HkVHbyIkamvR40skirMmijMjGNRkbL5)ZYW1tQwGEO4WVoffsKgswSmKWciHgIaGztPocjSdj0KbyOB6XHewaj6EXBCuWpu5nmatubGPAfNwsbjS2TIVJa0461IoTV0IU3xA)x670TWsTbiV)A3sJ(Kv3IPOUAdqJ20aMOpz1TI344nA3kiizTEJAdqbdfnue5qIeiHMmadDtpoK8ajl3TIVJa0461IoTV0IU3xA)aQVt3cl1gG8(RDR4noEJ2TwR3O2auWqrdfroKibsOjdWq30JdjpqYYDln6twDlkICt2yI5DmH(Kv37lT)Y9D6wyP2aK3FTBPrFYQBfvaWOrFYYagQ3Tad1nL(XUfpDA37lTFaQVt3cl1gG8(RDln6twDR1danUoL3TI344nA3YNpcjYbjlwgsKaj(8rJNg(GqICpqYIaHejqcBqsmtapxvckZ)NLHRNuTa9qXHFDkkKihK8sGqImzqsmtapxvckZ)NLHRNuTa9qXHFDkkKinKSiqircKWtxOTz9wC4xNIcjY9ajlcesKaj80fX8oMqFYsC4xNIcjY9ajlcesKajSbj80f0jClldyAqXHFDkkKi3dKSiqirMmijiiXvawUGoHBzzatdkWsTbihsyfsyTBfFhbOX1RfDAFPfDVV0(bS(oDlSuBaY7V2T0Opz1T09s30tPMMSCt2ycZv41TI344nA3YNpcjs)ajV0Tk9JDlDV0n9uQPjl3KnMWCfEDVV0(SS(oDlSuBaY7V2TI344nA3YNpcjs)ajVSC3sJ(Kv3kCtlp)g6uTma9g)D37lT)EOVt3cl1gG8(RDR4noEJ2T85JqI0qYIL7wA0NS6wRhaACDkV79LEjW(oDlSuBaY7V2TI344nA3InijMjGNRkbL5)ZYW1tQwGEO4WVoffsKgswSmKWoKqtgGHUPhhsybKO7fVXrb)qL3WamrfaMQvGLAdqoKitgKWgKO7fVXrb)qL3WamrfaMQvCAjfKitgKGukwruSEOtwMSXeIxdg9jlXPLuqcRqIeiXNpcjYbjVeiKibs85Jgpn8bHe5EGK9xeiKWkKibsyds4Plc30YZVHovldqVXFlo8RtrHezYGeE6I1danUoLlo8RtrHezYGKGGexby5IWnT88BOt1Ya0B83cSuBaYHejqsqqIRaSCX6bGgxNYfyP2aKdjScjYKbj(8rJNg(GqI0qYlbcjSdjTrE3sJ(Kv3QLrp(OLjBm6EXl9TU3x6Lf9D6wyP2aK3FTBfVXXB0UvmtapxvckZ)NLHRNuTa9qXHFDkkKinKSyziHDiHMmadDtpoKWcir3lEJJc(HkVHbyIkamvRal1gGCircKWgKWtxeUPLNFdDQwgGEJ)wC4xNIcjYKbj80fRhaACDkxC4xNIcjS2T0Opz1T46jLHMmGU3x6L9770T0Opz1TSXJINut12TWsTbiV)A37l9Yl9D6wyP2aK3FTBPrFYQBfvaWOrFYYagQ3Tad1nL(XUfneloE0U3x6LaQVt3cl1gG8(RDln6twDROcagn6twgWq9UfyOUP0p2TAgaapA37E3k8Wy(TvVVtFPf9D6wA0NS6wuM)pltdc2ykhVUfwQna59x7EFP9770TWsTbiV)A3kEJJ3ODlxby5I2B(5COjBmunEtZerbwQna5Dln6twDR2B(5COjBmunEtZeXU3x6L(oDln6twDRW0NS6wyP2aK3FT79LcO(oDlSuBaY7V2Tk9JDlDV0n9uQPjl3KnMWCfEDln6twDlDV0n9uQPjl3KnMWCfEDVV0Y9D6wyP2aK3FTBfVXXB0UfnebaJRxl6ubfrUjBmX8oMqFYYOjcjY9ajVajsGKGGemGZmHHixO7LUPNsnnz5MSXeMRWRBPrFYQBrrKBYgtmVJj0NS6EFPauFNULg9jRU1MYuE3cl1gG8(RDVVuaRVt3cl1gG8(RDR4noEJ2TccsCfGLl2uMYfyP2aKdjsGeAicagxVw0PckICt2yI5DmH(KLrtesKgsEbsKajbbjyaNzcdrUq3lDtpLAAYYnzJjmxHx3sJ(Kv3IUP8CLXobE37E3kMjGNRkAFN(sl670T0Opz1TwLhGVgNYCinlTIy3cl1gG8(RDVV0(9D6wyP2aK3FTBPrFYQBP7LUPNsnnz5MSXeMRWRBfVXXB0UfBqsqqIRaSCr4MwE(n0PAza6n(BbwQna5qImzqsmtapxvIWnT88BOt1Ya0B83Id)6uuirAijGGewaj0qeamBk1rirMmijiijMjGNRkr4MwE(n0PAza6n(BXHFDkkKWkKibsIzc45Qsqz()SmC9KQfOhko8RtrHePHKf7biHfqcnebaZMsDesyhsOjdWq30JdjSas09I34OGFOYByaMOcat1koTKcsKaj80fABwVfh(1POqIeiHNUiM3Xe6twId)6uuircKWgKWtxqNWTSmGPbfh(1POqImzqsqqIRaSCbDc3YYaMguGLAdqoKWA3Q0p2T09s30tPMMSCt2ycZv419(sV03PBHLAdqE)1Uv8ghVr7wSbjUcWYfC9KYqtgG5pu8ElWsTbihsKajXmb8CvjOm)FwgUEs1c0dfmHqIeijMjGNRkbxpPm0KbiycHewHezYGKyMaEUQeuM)pldxpPAb6HcMqirMmiXNpA80WhesKgsEjWULg9jRUvy6twDVVua13PBHLAdqE)1Uv8ghVr7wXmb8CvjOm)FwgUEs1c0dfh(1POqICqsalqirMmiXNpA80WhesKgs2pqirMmiHniHniXMPPrOrFwJggLkOUgLcsEGKLHezYGeAYam0n94qYdKeiKWkKibsydsccsCfGLlc30YZVHovldqVXFlWsTbihsKjdsIzc45QseUPLNFdDQwgGEJ)wC4xNIcjScjsGe2GKGGexby5coQ(MDcCbwQna5qImzqsmtapxvcoQ(MDcCXHFDkkKi9dK0g5qImzqsqqsmtapxvcoQ(MDcCXHFDkkKWkKibsccsIzc45Qsqz()SmC9KQfOhko8RtrHew7wA0NS6wmu0mo(PDVV0Y9D6wyP2aK3FTBfVXXB0UvqqsmtapxvckZ)NLHRNuTa9qbty3sJ(Kv3Qzo0gKjV79Lcq9D6wyP2aK3FTBfVXXB0UvqqsmtapxvckZ)NLHRNuTa9qbty3sJ(Kv3YgKj30WCV7EFPawFNUfwQna59x7wXBC8gTB5ZhHe5GKxcSBPrFYQB9XFEVnzJbWehUHFO(PDVVelRVt3cl1gG8(RDR4noEJ2T85Jgpn8bHePHK9desyhsAJCirMmiXvawUGMRm(gAOiYPcSuBaYHejqsmtapxvckZ)NLHRNuTa9qXHFDkkKi3dKeZeWZvLGY8)zz46jvlqpuWzo1NSGKaaswey3sJ(Kv3IRNugAYa6EFP9qFNUfwQna59x7wXBC8gTBfIUGRNuTa9qXHFDkkKitgKWgKeeKeZeWZvLGJQVzNaxC4xNIcjYKbjbbjUcWYfCu9n7e4cSuBaYHewHejqsmtapxvckZ)NLHRNuTa9qXHFDkkKi3dKWYcesKajiLIvef2Gm5MSX4BObl8)wCAjfKihKSOBPrFYQBzdYKBYgJVHgSW)7U3xArG9D6wyP2aK3FTBPrFYQBfMrPqNo7f5My(dzC1NSmCC9eXUv8ghVr7wSbjXmb8CvjOm)FwgUEs1c0dfh(1POqICpqY(ldjYKbj(8rJNg(GqI0pqYlbcjScjsGe2GKyMaEUQeCu9n7e4Id)6uuirMmijiiXvawUGJQVzNaxGLAdqoKWA3Q0p2TcZOuOtN9ICtm)HmU6twgoUEIy37lTyrFNUfwQna59x7wA0NS6wx6XJH6i3SotEMgEcaDR4noEJ2TydsIzc45Qsqz()SmC9KQfOhko8RtrHe5EGK9xgsKjds85Jgpn8bHePFGKxcesyfsKajSbjXmb8Cvj4O6B2jWfh(1POqImzqsqqIRaSCbhvFZobUal1gGCiH1UvPFSBDPhpgQJCZ6m5zA4ja09(sl2VVt3cl1gG8(RDln6twDl62SgpZASYV5qWe7wXBC8gTBXgKeZeWZvLGY8)zz46jvlqpuC4xNIcjY9aj7VmKitgK4ZhnEA4dcjs)ajVeiKWkKibsydsIzc45QsWr13StGlo8RtrHezYGKGGexby5coQ(MDcCbwQna5qcRDRs)y3IUnRXZSgR8BoemXU3xAXl9D6wyP2aK3FTBPrFYQBPbCMjmDSCtPm(ayODR4noEJ2TydsIzc45Qsqz()SmC9KQfOhko8RtrHe5EGK9xgsKjds85Jgpn8bHePFGKxcesyfsKajSbjXmb8Cvj4O6B2jWfh(1POqImzqsqqIRaSCbhvFZobUal1gGCiH1UvPFSBPbCMjmDSCtPm(ayODVV0IaQVt3cl1gG8(RDln6twDlF4i1Z7BIjhzPDR4noEJ2TydsIzc45Qsqz()SmC9KQfOhko8RtrHe5EGK9xgsKjds85Jgpn8bHePFGKxcesyfsKajSbjXmb8Cvj4O6B2jWfh(1POqImzqsqqIRaSCbhvFZobUal1gGCiH1UvPFSB5dhPEEFtm5ilT79LwSCFNUfwQna59x7wA0NS6wRhfyYgd1Z7t7wXBC8gTBXgKeZeWZvLGY8)zz46jvlqpuC4xNIcjY9aj7VmKitgK4ZhnEA4dcjs)ajVeiKWkKibsydsIzc45QsWr13StGlo8RtrHezYGKGGexby5coQ(MDcCbwQna5qcRDRs)y3A9Oat2yOEEFA37lTia13PBPrFYQBDtyiantzOHAe7wyP2aK3FT7DVBXtN23PV0I(oDlSuBaY7V2TI344nA3INUiM3Xe6twId)6uuir6hirJ(KLGIi3KnMyEhtOpzjIk1n(8riHDiXNpA80q30JdjSdjbKyFiHfqcBqYcijaGexby5I4Hy4uTgoQ(Mal1gGCiHfqsGIfldjScjsGeAicagxVw0PckICt2yI5DmH(KLrtesK7bsEbsyhsoD4gCnwUyQ1mGcp1gGcMqiHDiXvawUy1n(gAMYOTz9wGLAdqoKibsccs4PlOiYnzJjM3Xe6twId)6uuircKeeKOrFYsqrKBYgtmVJj0NSetzAat7M3T0Opz1TOiYnzJjM3Xe6twDVV0(9D6wyP2aK3FTBPrFYQBPTz9UBfVXXB0ULRaSCr8qmCQwdhvFtGLAdqoKibs0OpRrdpDH2M1BirAijabjsGeF(OXtdFqiroizrGqIeiHni5WVoffsK(bsAJCirMmijMjGNRkbL5)ZYW1tQwGEO4WVoffsKdsweiKibsydso8RtrHePHKLHezYGKGGeDV4nokc1IJ)jAMADgvFYsCAjfKibsoS5q6MAdqiHviH1Uv8DeGgxVw0P9Lw09(sV03PBHLAdqE)1ULg9jRUL2M17Uv8ghVr7wbbjUcWYfXdXWPAnCu9nbwQna5qIeirJ(Sgn80fABwVHePHewgKibs85Jgpn8bHe5GKfbcjsGe2GKd)6uuir6hiPnYHezYGKyMaEUQeuM)pldxpPAb6HId)6uuiroizrGqIeiHni5WVoffsKgswgsKjdsccs09I34Oiulo(NOzQ1zu9jlXPLuqIei5WMdPBQnaHewHew7wX3raAC9ArN2xAr37lfq9D6wyP2aK3FTBPrFYQBrNWTSmGPb7wXBC8gTBXgKOrFwJgE6c6eULLbmniKinKWYGKaasCfGLlIhIHt1A4O6BcSuBaYHKaasOHiayC9ArNkO5kJVHgkICQrtesyfsKaj(8rJNg(GqICqYIaHejqYHnhs3uBacjsGe2GKGGKd)6uuircKqdraW461IovqrKBYgtmVJj0NSmAIqYdKSasKjdsIzc45Qsqz()SmC9KQfOhko8RtrHe5GeAYam0n94qclGen6twcMI6QnanAtdyI(KLazPyKXrJpFesyTBfFhbOX1RfDAFPfDVV0Y9D6wyP2aK3FTBPrFYQBfZ7yc9jRUv8ghVr7w0qeamUETOtfue5MSXeZ7yc9jlJMiKinK8cKWoKC6Wn4ASCXuRzafEQnafmHqc7qIRaSCXQB8n0mLrBZ6Tal1gGCircKWgKC4xNIcjs)ajTroKitgKeZeWZvLGY8)zz46jvlqpuC4xNIcjYbjlcesKajh2CiDtTbiKWkKibsC9Arx4ZhnEA4dcjYbjlcSBfFhbOX1RfDAFPfDV7DRMbaWJ23PV0I(oDlSuBaY7V2T0Opz1TykQR2a0OnnGj6twDR4noEJ2TIzc45QsWr13StGlo8RtrHePFGK2ihsybKSpKibsOHiayC9ArNkOiYnzJjM3Xe6twgnri5bswajSdjNoCdUglxm1AgqHNAdqbtiKibsIzc45Qsqz()SmC9KQfOhko8RtrHe5GK9dSBbMcnrE3AXYDVV0(9D6wyP2aK3FTBfVXXB0ULRaSCbhvFZobUal1gGCircKqdraW461IovqrKBYgtmVJj0NSmAIqYdKSasyhsoD4gCnwUyQ1mGcp1gGcMqircKWgKWtxOTz9wC4xNIcjsdj80fABwVfCMt9jliHfqsGIa2YqImzqcpDrmVJj0NSeh(1POqI0qcpDrmVJj0NSeCMt9jliHfqsGIa2YqImzqcpDbDc3YYaMguC4xNIcjsdj80f0jClldyAqbN5uFYcsybKeOiGTmKWkKibsIzc45QsWr13StGlo8RtrHePFGen6twcTnR3I2ihsybKeqqIeijMjGNRkbL5)ZYW1tQwGEO4WVoffsKds2pWULg9jRUvubaJg9jldyOE3cmu3u6h7wCBZHnhs36EFPx670TWsTbiV)A3kEJJ3ODlxby5coQ(MDcCbwQna5qIeiHgIaGX1RfDQGIi3KnMyEhtOpzz0eHKhizbKWoKC6Wn4ASCXuRzafEQnafmHqIeijMjGNRkbL5)ZYW1tQwGEO4WVoffsK(bsOjdWq30JdjSas0Opzj02SElAJCiHDirJ(KLqBZ6TOnYHewajVajsGe2GeE6cTnR3Id)6uuirAiHNUqBZ6TGZCQpzbjSaswajYKbj80fX8oMqFYsC4xNIcjsdj80fX8oMqFYsWzo1NSGewajlGezYGeE6c6eULLbmnO4WVoffsKgs4PlOt4wwgW0GcoZP(KfKWcizbKWA3sJ(Kv3kQaGrJ(KLbmuVBbgQBk9JDlUT5WMdPBDVVua13PBHLAdqE)1Uv8ghVr7wR1BuBak4PtnmHqIeiHnijMjGNRkbL5)ZYW1tQwGEO4WVoffsK7bsEjqiHDiPnYHezYGKyMaEUQeuM)pldxpPAb6HId)6uuiroizrafiKWA3sJ(Kv3IJQVzNaV79LwUVt3cl1gG8(RDR4noEJ2TSzAAe)Cn(XYfmHqIeiXMPPrut7M3OaG4WVofTBPrFYQBr3uEUYyNaV79Lcq9D6wyP2aK3FTBfVXXB0ULnttJ4NRXpwUGjesKajbbjSbjUcWYf0jClldyAqbwQna5qIeiHnij8W1M2ixSqOTz9gsKajHhU20g5I9fABwVHejqs4HRnTrU4fH2M1BiHvirMmij8W1M2ixSqOTz9gsyTBPrFYQBPTz9U79Lcy9D6wyP2aK3FTBfVXXB0ULnttJ4NRXpwUGjesKajbbjSbjHhU20g5Ifc6eULLbmniKibscpCTPnYf7lOt4wwgW0GqIeij8W1M2ix8IGoHBzzatdcjS2T0Opz1TOt4wwgW0GDVVelRVt3cl1gG8(RDR4noEJ2TSzAAe)Cn(XYfmHqIeijiij8W1M2ixSqeZ7yc9jlircKeeK4kalxO20eW4OjM3Xe6twcSuBaY7wA0NS6wX8oMqFYQ79L2d9D6wyP2aK3FTBfVXXB0ULnttJykC94QnanC8puuqDnkfKihKSiqircK4ZhnEA4dcjs)ajlcSBPrFYQBXpDkdyAWU3xArG9D6wyP2aK3FTBfVXXB0ULRaSCbDc3YYaMguGLAdqoKibsSzAAetHRhxTbOHJ)HIcQRrPGe5EGKLdescaiz)aHewajSbj0qeamUETOtfue5MSXeZ7yc9jlJMiKeaqYPd3GRXYftTMbu4P2auWecjY9aj7djScjsGeE6cTnR3Id)6uuiroizziHfqcnebaZMsDesKaj80fX8oMqFYsC4xNIcjYbjTroKibsyds4PlOt4wwgW0GId)6uuiroiPnYHezYGKGGexby5c6eULLbmnOal1gGCiHvircKWgKWrBMMgXMYuU4WVoffsKdswgsybKqdraWSPuhHezYGKGGexby5InLPCbwQna5qcRqIeijMLRTtwqICqYYqclGeAicaMnL6y3sJ(Kv3IF6ugW0GDVV0If9D6wyP2aK3FTBfVXXB0ULRaSCXQB8n0mLrBZ6Tal1gGCircKyZ00iMcxpUAdqdh)dffuxJsbjY9ajlhiKeaqY(bcjSasydsOHiayC9ArNkOiYnzJjM3Xe6twgnrijaGKthUbxJLlMAndOWtTbOGjesK7bsEbsyfscaizziHfqcBqcnebaJRxl6ubfrUjBmX8oMqFYYOjcjbaKC6Wn4ASCXuRzafEQnafmHqYdKSpKWkKibs4Pl02SElo8RtrHe5GKLHewaj0qeamBk1rircKWtxeZ7yc9jlXHFDkkKihK0g5qIeiHniHJ2mnnInLPCXHFDkkKihKSmKWciHgIaGztPocjYKbjbbjUcWYfBkt5cSuBaYHewHejqsmlxBNSGe5GKLHewaj0qeamBk1XULg9jRUf)0PmGPb7EFPf733PBHLAdqE)1Uv8ghVr7wUcWYfQnnbmoAI5DmH(KLal1gGCircKyZ00iMcxpUAdqdh)dffuxJsbjY9ajlhiKeaqY(bcjSasydsOHiayC9ArNkOiYnzJjM3Xe6twgnrijaGKthUbxJLlMAndOWtTbOGjesK7bsciiHvircKWtxOTz9wC4xNIcjYbjldjSasOHiay2uQJqIeiHniHJ2mnnInLPCXHFDkkKihKSmKWciHgIaGztPocjYKbjbbjUcWYfBkt5cSuBaYHewHejqsmlxBNSGe5GKLHewaj0qeamBk1XULg9jRUf)0PmGPb7EFPfV03PBPrFYQBTPmL3TWsTbiV)A37lTiG670T0Opz1TAYidf5gDV4noASr93TWsTbiV)A37lTy5(oDln6twDRqMBAEpvRXgOuVBHLAdqE)1U3xAraQVt3cl1gG8(RDR4noEJ2Tccs4PlIzfXYp1rUPbOF0yZCL4WVoffsKajbbjA0NSeXSIy5N6i30a0pkMY0aM2nVBPrFYQBfZkILFQJCtdq)y37lTiG13PBHLAdqE)1ULg9jRUf)0Pm0Kb0TIVJa0461IoTV0IU1uoEhtO3Tw0TI344nA3YNpA80WhesK(bsAJ8UvCtNQBTOBnLJ3Xe6MwqARGU1IU3xAblRVt3cl1gG8(RDln6twDl(PtzOjdOBfFhbOX1RfDAFPfDRPC8oMq3mnDlFIsrnh(1PKE5Uv8ghVr7wUcWYf0nLNRm43(0ikWsTbihsKajR1BuBak(6uUoLHIqIeijiiHJ2mnnc6MYZvg8BFAefh(1PODR4Mov3Ar3AkhVJj0nTG0wbDRfDVV0I9qFNUfwQna59x7wA0NS6w8tNYqtgq3k(ocqJRxl60(sl6wt54DmHUzA6w(eLIAo8Rtj9YDR4noEJ2TCfGLlOBkpxzWV9PruGLAdqoKibswR3O2au81PCDkdf7wXnDQU1IU1uoEhtOBAbPTc6wl6EFP9dSVt3cl1gG8(RDln6twDl(PtzOjdOBnLJ3Xe6DRfDR4Mov3Ar3AkhVJj0nTG0wbDRfDVV0(l670TWsTbiV)A3sJ(Kv3IUP8CLXobE3kEJJ3ODlxby5c6MYZvg8BFAefyP2aKdjsGK16nQnafFDkxNYqrircKeeKWrBMMgbDt55kd(TpnIId)6uuircKeeKOrFYsq3uEUYyNaxmLPbmTBE3k(ocqJRxl60(sl6EFP93VVt3cl1gG8(RDln6twDl6MYZvg7e4DR4noEJ2TCfGLlOBkpxzWV9PruGLAdqoKibswR3O2au81PCDkdf7wX3raAC9ArN2xAr37lT)l9D6wA0NS6w0nLNRm2jW7wyP2aK3FT7DVBrdXIJhTVtFPf9D6wyP2aK3FTBfVXXB0UvmtapxvckZ)NLHRNuTa9qXHFDkkKi9dKqtgGHUPhhsybKWgKGSumY4OXNpcjSdj6EXBCuWpu5nmatubGPAfNwsbjScjsGe2GKGGexby5coQ(MDcCbwQna5qImzqsmtapxvcoQ(MDcCXHFDkkKi9dKqtgGHUPhhsybKGSumY4OXNpcjScjsGe2Gexby5cAUY4BOHIiNkWsTbihsKjds4Plc30YZVHovldqVXFlo8RtrHezYGeE6I1danUoLlo8RtrHew7wA0NS6wmf1vBaA0MgWe9jRU3xA)(oDlSuBaY7V2TI344nA3InijMjGNRkbL5)ZYW1tQwGEO4WVoffsKgs85Jgpn0n94qclGe2GKLHKaasOjdWq30JdjScjYKbjXmb8CvjOm)FwgUEs1c0dfmHqcRqIeiXNpA80WhesKdsIzc45Qsqz()SmC9KQfOhko8Rtr7wA0NS6wrfamA0NSmGH6DlWqDtPFSB1maaE0U3x6L(oDlSuBaY7V2TI344nA3ATEJAdqbdfnue5Dln6twDlkICt2yI5DmH(Kv37lfq9D6wyP2aK3FTBfVXXB0UvqqYA9g1gGcgkAOiYHejqsqqs4HRnTrUyHGY8)zz46jvlqpesKajSbjUcWYfCu9n7e4cSuBaYHejqsmtapxvcoQ(MDcCXHFDkkKi9dKGSumY4OXNpcjsGKGGeDV4nokIknQ8PAnrfO)XFlWsTbihsKjdsydsOjdWq30JdjY9ajldjsGeAicagxVw0PckICt2yI5DmH(KLrtesKgs2hsKjdsOjdWq30JdjY9aj7djsGeAicagxVw0PckICt2yI5DmH(KLrtesK7bs2hsyfsKajUETOl85Jgpn8bHe5GKacsyhsqwkgzC04ZhHejqcnebaJRxl6ubfrUjBmX8oMqFYYOjcjpqYcirMmiXNpA80WhesK(bsyzqc7qcYsXiJJgF(iKWciHMmadDtpoKWA3sJ(Kv3IPOUAdqJ20aMOpz19(sl33PBHLAdqE)1Uv8ghVr7wbbjR1BuBakyOOHIihsKajXSCTDYcsK(bsIk1n(8riHDizTEJAdqrOY5t12T0Opz1TykQR2a0OnnGj6twDVVuaQVt3cl1gG8(RDln6twDlMI6QnanAtdyI(Kv3kEJJ3ODRGGK16nQnafmu0qrKdjsGe2GKGGexby5coQ(MDcCbwQna5qImzqsmtapxvcoQ(MDcCXHFDkkKihK4ZhnEAOB6XHezYGeAYam0n94qICqYciHvircKWgKeeK4kalxSEaOX1PCbwQna5qImzqcnzag6MECiroizbKWkKibsIz5A7KfKi9dKevQB85Jqc7qYA9g1gGIqLZNQfsKajSbjbbj6EXBCuevAu5t1AIkq)J)wGLAdqoKitgKyZ00iIknQ8PAnrfO)XFlo8RtrHe5GeF(OXtdDtpoKWA3k(ocqJRxl60(sl6E37E37EVd]] )


end