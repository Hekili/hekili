-- MageFire.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 63, true )

    -- spec:RegisterResource( Enum.PowerType.ArcaneCharges )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        firestarter = 22456, -- 205026
        pyromaniac = 22459, -- 205020
        searing_touch = 22462, -- 269644

        blazing_soul = 23071, -- 235365
        shimmer = 22443, -- 212653
        blast_wave = 23074, -- 157981

        incanters_flow = 22444, -- 1463
        mirror_image = 22445, -- 55342
        rune_of_power = 22447, -- 116011

        flame_on = 22450, -- 205029
        alexstraszas_fury = 22465, -- 235870
        phoenix_flames = 22468, -- 257541

        frenetic_speed = 22904, -- 236058
        ice_ward = 22448, -- 205036
        ring_of_frost = 22471, -- 113724

        flame_patch = 22451, -- 205037
        conflagration = 23362, -- 205023
        living_bomb = 22472, -- 44457

        kindling = 21631, -- 155148
        pyroclasm = 22220, -- 269650
        meteor = 21633, -- 153561
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3583, -- 208683
        relentless = 3582, -- 196029
        adaptation = 3581, -- 214027

        prismatic_cloak = 828, -- 198064
        dampened_magic = 3524, -- 236788
        greater_pyroblast = 648, -- 203286
        flamecannon = 647, -- 203284
        kleptomania = 3530, -- 198100
        temporal_shield = 56, -- 198111
        netherwind_armor = 53, -- 198062
        tinder = 643, -- 203275
        world_in_flames = 644, -- 203280
        firestarter = 646, -- 203283
        controlled_burn = 645, -- 280450
    } )

    -- Auras
    spec:RegisterAuras( {
        arcane_intellect = {
            id = 1459,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        blast_wave = {
            id = 157981,
            duration = 4,
            max_stack = 1,
        },
        blazing_barrier = {
            id = 235313,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        blink = {
            id = 1953,
        },
        cauterize = {
            id = 86949,
        },
        combustion = {
            id = 190319,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        conflagration = {
            id = 226757,
            duration = 8.413,
            type = "Magic",
            max_stack = 1,
        },
        critical_mass = {
            id = 117216,
        },
        dragons_breath = {
            id = 31661,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        enhanced_pyrotechnics = {
            id = 157642,
            duration = 15,
            type = "Magic",
            max_stack = 10,
        },
        fire_blasting = {
            duration = 0.5,
            max_stack = 1,
            generate = function ()
                local last = action.fire_blast.lastCast
                local fb = buff.fire_blasting

                if query_time - last < 0.5 then
                    fb.count = 1
                    fb.applied = last
                    fb.expires = last + 0.5
                    fb.caster = "player"
                    return
                end

                fb.count = 0
                fb.applied = 0
                fb.expires = 0
                fb.caster = "nobody"
            end,
        },
        flamestrike = {
            id = 2120,
            duration = 8,
            max_stack = 1,
        },
        frenetic_speed = {
            id = 236060,
            duration = 3,
            max_stack = 1,
        },
        frost_nova = {
            id = 122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        heating_up = {
            id = 48107,
            duration = 10,
            max_stack = 1,
        },
        hot_streak = {
            id = 48108,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        hypothermia = {
            id = 41425,
            duration = 30,
            max_stack = 1,
        },
        ice_block = {
            id = 45438,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        ignite = {
            id = 12654,
            duration = 9,
            type = "Magic",
            max_stack = 1,
        },
        preinvisibility = {
            id = 66,
            duration = 3,
            max_stack = 1,
        },
        invisibility = {
            id = 32612,
            duration = 20,
            max_stack = 1
        },
        living_bomb = {
            id = 217694,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        living_bomb_spread = {
            id = 244813,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        meteor_burn = {
            id = 155158,
            duration = 3600,
            max_stack = 1,
        },
        mirror_image = {
            id = 55342,
            duration = 40,
            max_stack = 3,
            generate = function ()
                local mi = buff.mirror_image

                if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                    mi.count = 1
                    mi.applied = action.mirror_image.lastCast
                    mi.expires = mi.applied + 40
                    mi.caster = "player"
                    return
                end

                mi.count = 0
                mi.applied = 0
                mi.expires = 0
                mi.caster = "nobody"
            end,
        },
        pyroclasm = {
            id = 269651,
            duration = 15,
            max_stack = 2,
        },
        shimmer = {
            id = 212653,
        },
        slow_fall = {
            id = 130,
            duration = 30,
            max_stack = 1,
        },
        temporal_displacement = {
            id = 80354,
            duration = 600,
            max_stack = 1,
        },
        time_warp = {
            id = 80353,
            duration = 40,
            type = "Magic",
            max_stack = 1,
        },

        -- Azerite Powers
        blaster_master = {
            id = 274598,
            duration = 3,
            max_stack = 3,
        },

        wildfire = {
            id = 288800,
            duration = 10,
            max_stack = 1,
        },
    } )


    spec:RegisterStateTable( "firestarter", setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "active" then return talent.firestarter.enabled and target.health.pct > 90
            elseif k == "remains" then
                if not talent.firestarter.enabled or target.health.pct <= 90 then return 0 end
                return max( 0, floor( target.time_to_die * 90 / target.health.pct ) )
            end
        end, state )
    } ) )


    spec:RegisterTotem( "rune_of_power", 609815 )


    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        incanters_flow.reset()
    end )


    spec:RegisterStateExpr( "auto_advance", function () return false end )


    -- Abilities
    spec:RegisterAbilities( {
        arcane_intellect = {
            id = 1459,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            nobuff = "arcane_intellect",
            essential = true,

            startsCombat = false,
            texture = 135932,

            handler = function ()
                applyBuff( "arcane_intellect" )
            end,
        },


        blast_wave = {
            id = 157981,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 135903,

            talent = "blast_wave",

            usable = function () return target.distance < 8 end,
            handler = function ()
                applyDebuff( "target", "blast_wave" )
            end,
        },


        blazing_barrier = {
            id = 235313,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            defensive = true,

            spend = 0.03,
            spendType = "mana",

            startsCombat = false,
            texture = 132221,

            handler = function ()
                applyBuff( "blazing_barrier" )
            end,
        },


        blink = {
            id = function () return talent.shimmer.enabled and 212653 or 1953 end,
            cast = 0,
            charges = function () return talent.shimmer.enabled and 2 or 1 end,
            cooldown = function () return talent.shimmer.enabled and 20 or 15 end,
            recharge = function () return talent.shimmer.enabled and 20 or 15 end,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

            handler = function ()
                if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
                if talent.blazing_soul.enabled then applyBuff( "blazing_barrier" ) end
            end,

            copy = { 212653, 1953, "shimmer" }
        },


        combustion = {
            id = 190319,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "off",
            castableWhileCasting = true,

            spend = 0.1,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135824,

            handler = function ()
                applyBuff( "combustion" )
                stat.crit = stat.crit + 100

                if azerite.wildfire.enabled then applyBuff( 'wildfire' ) end
            end,
        },


        --[[ conjure_refreshment = {
            id = 190336,
            cast = 3,
            cooldown = 15,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 134029,

            handler = function ()
            end,
        }, ]]


        counterspell = {
            id = 2139,
            cast = 0,
            cooldown = 24,
            gcd = "off",

            interrupt = true,
            toggle = "interrupts",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135856,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        dragons_breath = {
            id = 31661,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 134153,

            usable = function () return target.within12 end,
            handler = function ()
                if talent.alexstraszas_fury.enabled then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end
                end

                applyDebuff( "target", "dragons_breath" )
            end,
        },


        fire_blast = {
            id = 108853,
            cast = 0,
            charges = function () return talent.flame_on.enabled and 3 or 2 end,
            cooldown = function () return talent.flame_on.enabled and 10 or 12 end,
            recharge = function () return talent.flame_on.enabled and 10 or 12 end,
            gcd = "off",
            castableWhileCasting = true,

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135807,

            nobuff = "fire_blasting", -- horrible.

            handler = function ()
                if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                else applyBuff( "heating_up" ) end

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                if azerite.blaster_master.enabled then addStack( "blaster_master", nil, 1 ) end

                applyBuff( "fire_blasting" )
            end,
        },


        fireball = {
            id = 133,
            cast = 2.25,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135812,

            velocity = 45,

            -- Used by the real event handler, must use *real* data.
            -- Only purpose is to add any needed flags to the data table for onImpact.
            onRealCastFinish = function( data )
                if PlayerBuffUp( "combustion" ) then
                    data.willCrit = true
                end
            end,

            onCastFinish = function( data )
                if buff.combustion.up then
                    data.willCrit = true
                end
            end,

            onImpact = function( data )
                if data.willCrit or ( talent.firestarter.enabled and target.health.pct > 90 ) or ( stat.crit + ( buff.enhanced_pyrotechnics.stack * 10 ) >= 100 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    removeBuff( "enhanced_pyrotechnics" )

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    removeBuff( "heating_up" )
                    addStack( "enhanced_pyrotechnics", nil, buff.enhanced_pyrotechnics.stack + 1 )
                end

                applyDebuff( "target", "ignite" )
                if talent.conflagration.enabled then applyDebuff( "target", "conflagration" ) end
            end,

            --[[ Old handler.
            handler = function ()
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) or ( stat.crit + ( buff.enhanced_pyrotechnics.stack * 10 ) >= 100 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    addStack( "enhanced_pyrotechnics", nil, 1 )
                    removeBuff( "heating_up" )
                end

                applyDebuff( "target", "ignite" )
                if talent.conflagration.enabled then applyDebuff( "target", "conflagration" ) end
            end, ]]
        },


        flamestrike = {
            id = 2120,
            cast = function () return buff.hot_streak.up and 0 or 4 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135826,

            handler = function ()
                removeBuff( "hot_streak" )
                if buff.combustion.up then applyBuff( "heating_up" ) end

                applyDebuff( "target", "ignite" )
                applyDebuff( "target", "flamestrike" )
            end,
        },


        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            defensive = true,

            spend = 0.02,
            spendType = "mana",

            startsCombat = false,
            texture = 135848,

            handler = function ()
                applyDebuff( "target", "frost_nova" )
            end,
        },


        ice_block = {
            id = 45438,
            cast = 0,
            cooldown = 240,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 135841,

            handler = function ()
                applyBuff( "ice_block" )
                applyDebuff( "player", "hypothermia" )
            end,
        },


        invisibility = {
            id = 66,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132220,

            handler = function ()
                applyBuff( "preinvisibility" )
                applyBuff( "invisibility", 23 )
            end,
        },


        living_bomb = {
            id = 44457,
            cast = 0,
            cooldown = 12,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 236220,

            handler = function ()
                applyDebuff( "target", "living_bomb" )
            end,
        },


        meteor = {
            id = 153561,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 1033911,

            velocity = function ()
                return target.maxR / 1.5
            end,

            onImpact = function ()
                applyDebuff( "target", "meteor_burn" )
            end,
        },


        mirror_image = {
            id = 55342,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135994,

            talent = "mirror_image",

            handler = function ()
                applyBuff( "mirror_image" )
            end,
        },


        phoenix_flames = {
            id = 257541,
            cast = 0,
            charges = 3,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1392549,

            talent = "phoenix_flames",

            velocity = 50,

            onImpact = function ()
                if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                else applyBuff( "heating_up" ) end

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
            end,
        },


        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = false,
            texture = 136071,

            handler = function ()
                applyDebuff( "target", "polymorph" )
            end,
        },


        pyroblast = {
            id = 11366,
            cast = function () return buff.hot_streak.up and 0 or 4.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135808,

            velocity = 35,

            -- Used by the real event handler, must use *real* data.
            -- Only purpose is to add any needed flags to the data table for onImpact.
            onRealCastFinish = function( data )
                if PlayerBuffUp( "combustion" ) or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    data.willCrit = true
                end
            end,

            onCastFinish = function( data )
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    data.willCrit = true
                end

                removeBuff( "hot_streak" )
                removeStack( "pyroclasm" )
            end,

            onImpact = function( data )
                if Hekili.ActiveDebug then Hekili:Debug( "willCrit: %d, heating_up: %d, hot_streak: %d, ignite: %d", willCrit and 1 or 0, buff.heating_up.up and 1 or 0, buff.hot_streak.up and 1 or 0, debuff.ignite.up and 1 or 0 ) end

                if data.willCrit then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    removeBuff( "heating_up" )
                end

                applyDebuff( "target", "ignite" )
                if Hekili.ActiveDebug then Hekili:Debug( "willCrit: %d, heating_up: %d, hot_streak: %d, ignite: %d", willCrit and 1 or 0, buff.heating_up.up and 1 or 0, buff.hot_streak.up and 1 or 0, debuff.ignite.up and 1 or 0 ) end
            end,

            usable = function () 
                if action.pyroblast.cast > 0 and not boss then return false, "hardcasts only allowed on bosses" end
                return true
            end,

            --[[ handler = function ()
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                end

                if buff.hot_streak.up then
                    removeBuff( "hot_streak" )
                    removeStack( "pyroclasm" )
                end

                applyDebuff( "target", "ignite" )
            end, ]]
        },


        remove_curse = {
            id = 475,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136082,

            handler = function ()
            end,
        },


        ring_of_frost = {
            id = 113724,
            cast = 2,
            cooldown = 45,
            gcd = "spell",

            spend = 0.08,
            spendType = "mana",

            startsCombat = true,
            texture = 464484,

            handler = function ()
            end,
        },


        rune_of_power = {
            id = 116011,
            cast = 1.5,
            charges = 2,
            cooldown = 40,
            recharge = 40,
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",

            handler = function ()
                applyBuff( "rune_of_power" )
            end,
        },


        scorch = {
            id = 2948,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135827,

            handler = function ()
                if talent.frenetic_speed.enabled then applyBuff( "frenetic_speed" ) end

                if buff.combustion.up or stat.crit >= 100 then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end
                end

                applyDebuff( "target", "ignite" )
            end,
        },


        slow_fall = {
            id = 130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135992,

            handler = function ()
                applyBuff( "slow_fall" )
            end,
        },


        spellsteal = {
            id = 30449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.21,
            spendType = "mana",

            startsCombat = true,
            texture = 135729,

            handler = function ()
            end,
        },


        time_warp = {
            id = 80353,
            cast = 0,
            cooldown = 300,
            gcd = "off",

            spend = 0.04,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 458224,

            handler = function ()
                applyBuff( "time_warp" )
                applyDebuff( "player", "temporal_displacement" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
        gcdSync = false,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "potion_of_unbridled_fury",

        package = "Fire",
    } )


    spec:RegisterPack( "Fire", 20190803, [[dOeqBcqiLipIGuDjbQcBIaJIkYPOIAveKKxPs0Sei3sLQu7cXVujzyQu5yeuldqQNbizAeK4AQuyBcuX3iifJJGK6CQufwNkvrMhG4EuH9PsPdkqvXcvj8qcsPjkqvPUOavQAJQuLmsbQsNuGkfRuj0nfOQANQK6NcuPYqfOkAPcuvYtj0uvI6QQuf1xfOsP9k0Fr1Gj6WuwSs9yKMmqxgAZs5ZkPrlOtlA1cujVMGy2u1TvXUv8BjdNkDCvQQLRQNdA6KUUuTDa13fW4fOCELG1RsrZhG9JYrHJlhfbnfJxd03j894oH67akIWbhGsOw4OOUGlgfDnQqSvmko2bJI3R8XOORTGVmW4Yrry1Fkgfdv1fEpD1vRPg23eADUcMNU30Sg6Bn9kyEOxff390Rb3mXDue0umEnqFNW3J7eQVdOicFdGk4C39ikADnS(OOyE6EtZAeAFRPrXWeeeN4okcIqAuuOZK3R8rMm43wr2IcDMmuvx490vxTMAyFtO15kyE6EtZAOV10RG5HEfBrHotg8PV2HktcubXKa9DcFpyY7ntk8D3t3jmBr2IcDMuOn0MveEpXwuOZK3BM8EgImPMhKRfhmrM8nneFMudTHjv7xrLO5b5AXbtKjB1ZKEdQ3BisRbKjTD6tDbMSdTvesII(eQW4YrXuXdK7RaC3pRp1fIlhVw44YrrCSThbJxefPFQ4NwuKwLhScmeAD2DOM1qE8y5azYBzsGTpTThj1W7qKt7A1AmjaamPAECuslFeQ2R4tWX2EeKjfWKT8rOAVIp5XJLdKjVLjb2(02EKudVdroTRvRffh7GrrnbrOw)HtlqmyrrJQznrrnbrOw)HtlqmyrnEnqhxokIJT9iy8IOi9tf)0II0Q8GvGHqRZUd1SgYJhlhitEltcS9PT9iPgEhICAxRwJjbaGjvZJJsA5Jq1EfFco22JGmPaMSLpcv7v8jpESCGm5TmjW2N22JKA4DiYPDTATOOr1SMOiDbQV0VMKY3EdQrrS1qQYh7Grr6cuFPFnjLV9guJAuJI06S7qnRH7gAqmUC8AHJlhfXX2EemEruK(PIFArXDV1i06S7qnRHawbMOOr1SMOOpxdvip4QdUEWrJA8AGoUCuehB7rW4frr6Nk(Pff39wJqRZUd1SgcyfyysbmPr1eyKJdEseYK3YKchfnQM1ef9jW5SY31zh141avC5OOr1SMO42xfiVACne54GNfII4yBpcgViQXRfkXLJIgvZAIIRD7btB4vJB3e)sdJI4yBpcgViQXRVrC5OOr1SMO4bp1VaVACFNMGCWhTdmkIJT9iy8IOgVo4exokIJT9iy8IOyhI8aHPh5udQ5Sgffoks)uXpTOin0(veYK36GjfMjfWKoXKoXKgvZAiT8r(2BqLqdTFfH82BunRX8m5LmPtm5U3AeAD2DOM1qE8y5azY7ntU7Tgz7nOIp)yqfFcy)nnRHjDMjdEWK0Q8GvGH0Yh5BVbvcy)nnRHjV3mPtm5U3AeAD2DOM1qE8y5azsNzYGhmPtm5U3AKT3Gk(8Jbv8jG930SgM8EZK3rUbt6mt6mtERdM8oMeaaMCjM0Uj(PIKT3Gk(8Jbv8j4yBpcYKaaWKlXKQ5XrjnVDqEneCSThbzsaayYDV1i06S7qnRH84XYbYKaXbtU7Tgz7nOIp)yqfFcy)nnRHjbaGj39wJS9guXNFmOIp5XJLdKjbctEh5gmjaamjE)E66IGKWfCXxdF0a5b(eQbEZfYKcysAvEWkWqcxWfFn8rdKh4tOg4nxihOU7oHfkan5XJLdKjbctEdM0zMuatU7TgHwNDhQznKUltkGjDIjxIjnQM1qG06PHemyiTR5SYKcyYLysJQzne3f(A7nOsYH385AOYKcyYDV1iHOP5SY7UKUltcaatAunRHaP1tdjyWqAxZzLjfWK7ERrclLd1hnHqaRadtkGjDIj39wJeIMMZkV7saRadtcaatA3e)urY2BqfF(XGk(eCSThbzsNzsaays7M4Nks2EdQ4ZpguXNGJT9iitkGjvZJJsAE7G8Ai4yBpcYKcysJQzne3f(A7nOsYH385AOYKcyYDV1iHOP5SY7UeWkWWKcyYDV1iHLYH6JMqiGvGHjDok2HiVAn(kfmkkCu0OAwtuSLpY3EdQrnETqtC5Oio22JGXlII0pv8tlkU7TgHwNDhQzneWkWefnQM1ef)(G8QXDRa4h141c1XLJI4yBpcgVik2Hipqy6ro1GAoRrrHJIgvZAIIT8r(2Bqnks)uXpTOODt8tfjBVbv85hdQ4tWX2EeKjfWKQ5XrjnVDqEneCSThbzsbm5U3AKT3Gk(8Jbv8jGvGHjfWKoXKQ5XrjFFqE14Uva8j4yBpcYKcysJQznKVpiVAC3ka(emyiTR5SYKcysJQznKVpiVAC3ka(emyiTRi)XJLdKjbctEhj4WKaaWKoXK0Q8GvGHqRZUd1SgYJg4cmjaam5U3AeAD2DOM1q6UmPZmPaMCjMunpok57dYRg3TcGpbhB7rqMuatUetAunRH4UWxBVbvso8MpxdvMuatUetAunRH0Yh3M3tYH385AOYKoh1413J4YrrCSThbJxefnQM1efPM3ZnQM1W9juJI(eQ8Xoyu0OAcmYvZJJcJA8AHVlUCuehB7rW4frXoe5bctpYPguZznkkCuK(PIFArrNysNysJQznKdQy9KC4nFUgQmPaM0OAwd5GkwpjhEZNRHk)XJLdKjbIdM8oYnysNzsaayYLys184OKdQy9eCSThbzsNzsbmPtm5U3AKVpiVAC3ka(KUltcaatUetQMhhL89b5vJ7wbWNGJT9iit6CuSdrE1A8vkyuu4OOr1SMOiTo7ouZAIA8AHfoUCu0OAwtu0T0SMOio22JGXlIA8AHb64YrrJQznrXTVkqER)lefXX2EemEruJxlmqfxokAunRjkUXhIVqYznkIJT9iy8IOgVwyHsC5OOr1SMOylFC7RcmkIJT9iy8IOgVw4BexokAunRjkAdfH6BEo18(Oio22JGXlIA8AHdoXLJI4yBpcgVikAunRjksnVNBunRH7tOgf9ju5JDWOO(5ieuHrnETWcnXLJI4yBpcgViks)uXpTOOtmPtmPAECusZBhK7AknKGJT9iitkGjnQMaJCCWtIqM8wMeOzsNzsaaysJQjWihh8KiKjVLjdomPZmPaMC3BnsyPCO(OjeYJgvzsbm5smPDt8tfjBVbv85hdQ4tWX2EemkAunRjk282bH6NcbJA8AHfQJlhfXX2EemEruK(PIFArXDV1iUl8f1BWd5rJQmPaMC3BncTo7ouZAipESCGm5Tmj1GkxZdgfnQM1efDx4RT3GAuJxl89iUCuehB7rW4frr6Nk(Pff39wJewkhQpAcH8Or1OOr1SMOO7cFT9guJA8AG(U4YrrCSThbJxef7qKhim9iNAqnN1OOWrr6Nk(Pffriehkso4P(f4vJ770eKd(ODGKJfCvptkGjDIjPH2VIqE7nQM1yEM8wMuycqXKaaWK7ERr2EdQ4ZpguXN84XYbYKaHjVJCdMeaaMC3BncTo7ouZAipESCGmjqyYDV1iBVbv85hdQ4ta7VPznmjaam5smPDt8tfjBVbv85hdQ4tWX2EeKjDMjfWKoXKoXK7ERrO1z3HAwdP7YKcysNyYDV1iHOP5SY7UKhnQYKcyYLysJQzne3f(A7nOsYH385AOYKcyYLysJQzneiTEAibdgs7AoRmPZmjaamPtmPr1SgcKwpnKGbdPDf5pESCGmPaMC3BnsiAAoR8UlbScmmPaMC3BnsyPCO(Ojecyfyysbm5smPr1SgI7cFT9guj5WB(CnuzsNzsNzsNJIDiYRwJVsbJIchfnQM1efB5J8T3GAuJxd0chxokIJT9iy8IOyhI8aHPh5udQ5Sgffoks)uXpTO4smjcH4qrYbp1VaVACFNMGCWhTdKCSGR6zsbmPtm5smPDt8tfjBVbv85hdQ4tWX2EeKjbaGjxIjvZJJsAE7G8Ai4yBpcYKoZKcysNysNyYDV1i06S7qnRH0DzsbmPtm5U3AKq00Cw5DxYJgvzsbm5smPr1SgI7cFT9guj5WB(Cnuzsbm5smPr1SgcKwpnKGbdPDnNvM0zMeaaM0jM0OAwdbsRNgsWGH0UI8hpwoqMuatU7TgjennNvE3LawbgMuatU7TgjSuouF0ecbScmmPaMCjM0OAwdXDHV2EdQKC4nFUgQmPZmPZmPZrXoe5vRXxPGrrHJIgvZAIIT8r(2BqnQXRbAGoUCuehB7rW4frr6Nk(PffDFey(kfKimbsRNgYKcyYDV1iHOP5SY7UKUBu0OAwtu0DHV2EdQrnEnqduXLJIgvZAIIUHfozW4nVDqyuehB7rW4frnEnqluIlhfXX2EemEruK(PIFArXDV1i06S7qnRH84XYbYK3YKudQCnpitkGj39wJqRZUd1Sgs3LjbaGj39wJqRZUd1SgcyfyIIgvZAIIqA90WOgVgOVrC5Oio22JGXlII0pv8tlkU7TgHwNDhQznKhpwoqMeim5kfKCSGXKcysJQjWihh8KiKjVLjfokAunRjk6tGZzLVRZoQXRb6GtC5Oio22JGXlII0pv8tlkU7TgHwNDhQznKhpwoqMeim5kfKCSGXKcyYDV1i06S7qnRH0DJIgvZAIIGVTwdKVF00WOgVgOfAIlhfXX2EemEruK(PIFArr1(vujHO51qIlvzsG4GjbQ7ysbmPAECuceTpNvUwDAibhB7rWOOr1SMOiKwpnmQrnkAunbg5Q5XrHXLJxlCC5Oio22JGXlII0pv8tlkAunbg54GNeHm5TmPWmPaMC3BncTo7ouZAiGvGHjfWKoXK0Q8GvGHqRZUd1SgYJhlhitEltsRYdwbgIpboNv(UoBcy)nnRHjbaGjPv5bRadHwNDhQznKhnWfysNJIgvZAII(e4Cw576SJA8AGoUCuehB7rW4frr6Nk(Pff39wJ89b5vJ7wbWN0DzsbmPtmzlFeQ2R4tE8y5azYBzsAvEWkWqoOI1ta7VPznmjaam5smzlFeQ2R4tmQMaJmPZmjaamjTkpyfyiFFqE14Uva8jpESCGm5TmPMhKRfhmrMuatAunRH89b5vJ7wbWNqdTFfHmjqysHzsaaysNysAvEWkWqoOI1ta7VPznmjqysAvEWkWqO1z3HAwd5XJLdKjbaGjPv5bRadHwNDhQznKhnWfysNzsbm5smPAECuY3hKxnUBfaFco22JGmPaM0jMKwLhScmKdQy9eW(BAwdtceMSLpcv7v8jpESCGmjaam5smPAECuslFeQ2R4tWX2EeKjbaGjxIjB5Jq1EfFIr1eyKjDokAunRjkEqfRpQrnkMkEG8WCnK7(z9PUqC541chxokIJT9iy8IOOr1SMOi18EUr1SgUpHAuK(PIFArrNys184OKVpiVAC3ka(eCSThbzsbmjTkpyfyi06S7qnRH84XYbYKaXbtAunRH89b5vJ7wbWNqnOY18GmjaamjTkpyfyi06S7qnRH8ObUat6mtkGjxIjB5Jq1EfFIr1eyKjbaGj39wJqRZUd1Sgs3nk6tOYh7GrXuXdKtRZUd1SMOgVgOJlhfnQM1ef7qKNkEGrrCSThbJxe141avC5Oio22JGXlII0pv8tlksRYdwbgcTo7ouZAipESCGmjqCWK3GjVKjf(gmPqftcS9PT9iPvJYbR(2J8A4Digfh7Grr7MWq7niVvJYRg3TcGFu0OAwtu0Ujm0EdYB1O8QXDRa4h141cL4YrrCSThbJxefPFQ4NwuKwLhScmeAD2DOM1qE8y5azYBzsGTpTThj1W7qKt7A1ArXXoyu8lL(DOIGCGRcSkoy59rrJQznrXVu63HkcYbUkWQ4GL3h1413iUCuehB7rW4frr6Nk(PffPv5bRadHwNDhQznKhpwoqM8wMey7tB7rsn8oe50UwTwuCSdgfT73t3sXr5J1103HrrJQznrr7(90TuCu(yDn9DyuJxhCIlhfXX2EemEruK(PIFArrAvEWkWqO1z3HAwd5XJLdKjVLjb2(02EKudVdroTRvRffh7Grryycm(CGXPo8h9jnkAunRjkcdtGXNdmo1H)OpPrnETqtC5Oio22JGXlIIgvZAIIH2FQjPCq8yk(P5ZBIFueBnKQ8Xoyum0(tnjLdIhtXpnFEt8JA8AH64YrrCSThbJxefPFQ4NwuKwLhScmeAD2DOM1qE8y5azYBDWK34gmPaMC3BncTo7ouZAiGvGHjfWK0Q8GvGHqRZUd1SgYJhlhitEltcS9PT9iPgEhICAxRwlko2bJIhZ3Q)GG8q8npiK7X1aV5cJIgvZAIIhZ3Q)GG8q8npiK7X1aV5cJA867rC5Oio22JGXlII0pv8tlksRYdwbgcTo7ouZAipESCGm5ToyYBCdMuatU7TgHwNDhQzneWkWWKcysAvEWkWqO1z3HAwd5XJLdKjVLjb2(02EKudVdroTRvRffh7GrrBOjokxitP8QXdKqW6efnQM1efTHM4OCHmLYRgpqcbRtuJxl8DXLJI4yBpcgViks)uXpTOiTkpyfyi06S7qnRH84XYbYK36Gjfk3GjfWK7ERrO1z3HAwdbScmmPaMKwLhScmeAD2DOM1qE8y5azYBzsGTpTThj1W7qKt7A1ArXXoyuCW(BEoCHXCHihNqBO4hfnQM1ef7qKNkEIAuJIGyZ6EnUC8AHJlhfnQM1efPvFu8HUO3hfXX2EemEruJxd0XLJI4yBpcgVikAunRjksnVNBunRH7tOgf9ju5JDWOyQ4bYdZ1qU7N1N6crnEnqfxokIJT9iy8IOi9tf)0II7ERrO1z3HAwdbScmrrJQznrXt(F988yRyuJxluIlhfnQM1efP1qXrFtrqEZBhmkIJT9iy8IOgV(gXLJIgvZAIITI2Hii3Uj(PI8nANOio22JGXlIA86GtC5OOr1SMOOB)Z2c5SY3EdQrrCSThbJxe141cnXLJIgvZAIIF666rEoCORrXOio22JGXlIA8AH64YrrJQznrrne59zx9bK3QNIrrCSThbJxe1413J4YrrJQznrXa17bbgZH)iSgBOyuehB7rW4frnETW3fxokIJT9iy8IOi9tf)0IIQ5XrjT8rOAVIpbhB7rqMuat2YhHQ9k(KhpwoqM8wMS19E(J0q7xrUMhKjbaGjPv5bRadHwNDhQznKhpwoqM8wMey7tB7rcTo7ouZA4F5YPDTAnMuatU7TgHwNDhQzneWkWWKaaWKAEqUwCWezsGWK0Q8GvGHqRZUd1SgYJhlhitkGj39wJqRZUd1SgcyfyIIgvZAIIFFqE14Uva8JA8AHfoUCuehB7rW4frrJQznrrQ59CJQznCFc1Oi9tf)0IIoXKQ5XrjFFqE14Uva8j4yBpcYKcysAvEWkWqO1z3HAwd5XJLdKjbIdM0OAwd57dYRg3TcGpHAqLR5bzsaaysAvEWkWqO1z3HAwd5rdCbM0zMuatUet2YhHQ9k(eJQjWitcaatU7TgHwNDhQznKUBu0NqLp2bJI06S7qnRH7gAqmQXRfgOJlhfXX2EemEruSdrEGW0JCQb1CwJIchfPFQ4Nwu0jMeHqCOi5GN6xGxnUVttqo4J2bsowWv9mjaamjcH4qrYbp1VaVACFNMGCWhTdKCYPEMuatA3e)urY2BqfF(XGk(eCSThbzsNzsbmjn0(veYKoyYJfmon0(veYKcyYLyYDV1iHLYH6JMqipAuLjfWKlXKoXK7ERrcrtZzL3DjpAuLjfWKoXK7ERrO1z3HAwdP7YKcysNysJQznKw(428Eso8MpxdvMeaaM0OAwdXDHV2EdQKC4nFUgQmjaamPr1SgcKwpnKGbdPDnNvM0zMeaaMuTFfvsiAEnK4svMeioysG6oMuatAunRHaP1tdjyWqAxZzLjDMjDMjfWKlXKoXKlXK7ERrcrtZzL3DjpAuLjfWKlXK7ERrclLd1hnHqE0OktkGj39wJqRZUd1SgcyfyysbmPtmPr1SgslFCBEpjhEZNRHktcaatAunRH4UWxBVbvso8MpxdvM0zM05OyhI8Q14RuWOOWrrJQznrXw(iF7nOg141cduXLJI4yBpcgVik2Hipqy6ro1GAoRrrHJI0pv8tlk6etIqiouKCWt9lWRg33Pjih8r7ajhl4QEMeaaMeHqCOi5GN6xGxnUVttqo4J2bso5uptkGjTBIFQiz7nOIp)yqfFco22JGmPZmPaMKgA)kczshm5XcgNgA)kczsbm5sm5U3AKWs5q9rtiKhnQYKcyYLysNyYDV1iHOP5SY7UKhnQYKcysNyYDV1i06S7qnRH0DzsbmPtmPr1SgslFCBEpjhEZNRHktcaatAunRH4UWxBVbvso8MpxdvMeaaM0OAwdbsRNgsWGH0UMZkt6mtcaatQ2VIkjenVgsCPktcehmjqDhtkGjnQM1qG06PHemyiTR5SYKoZKoZKcyYLysNyYLyYDV1iHOP5SY7UKhnQYKcyYLyYDV1iHLYH6JMqipAuLjfWK7ERrO1z3HAwdbScmmPaM0jM0OAwdPLpUnVNKdV5Z1qLjbaGjnQM1qCx4RT3GkjhEZNRHkt6mt6CuSdrE1A8vkyuu4OOr1SMOylFKV9guJA8AHfkXLJI4yBpcgVikAunRjksnVNBunRH7tOgfPFQ4NwuC3BnY3hKxnUBfaFs3LjfWK7ERrO1z3HAwdbScmrrFcv(yhmk(Ll3n0GyuJxl8nIlhfXX2EemEruSCJIquJIgvZAIIaBFABpgfb28DmkQMhhL89b5vJ7wbWNGJT9iitkGjPv5bRad57dYRg3TcGp5XJLdKjbctsRYdwbgslFKV9gujTU3ZFKgA)kY18GmPaM0jMKwLhScmeAD2DOM1qE8y5azYBzsGTpTThj06S7qnRH)LlN21Q1ysaayYw(iuTxXNyunbgzsNzsbmPtmjTkpyfyiFFqE14Uva8jpESCGmjqysnpixloyImjaamPr1SgY3hKxnUBfaFcn0(veYK3YK3XKoZKaaWK0Q8GvGHqRZUd1SgYJhlhitceM0OAwdPLpY3EdQKw375psdTFf5AEqM8sMKwLhScmKw(iF7nOsa7VPznmPqftA3e)urY2BqfF(XGk(eCSThbzsbm5smzlFeQ2R4tmQMaJmPaMKwLhScmeAD2DOM1qE8y5azsGWKAEqUwCWezsaays184OKw(iuTxXNGJT9iitkGjB5Jq1EfFIr1eyKjfWKT8rOAVIp5XJLdKjbctsRYdwbgslFKV9gujTU3ZFKgA)kY18Gm5LmjTkpyfyiT8r(2BqLa2FtZAysHkM0Uj(PIKT3Gk(8Jbv8j4yBpcgfb2E(yhmk2Yh5BVbvUBv(CwJA8AHdoXLJI4yBpcgVikwUrriQrrJQznrrGTpTThJIaB(ogfvZJJs((G8QXDRa4tWX2EeKjfWK0Q8GvGH89b5vJ7wbWN84XYbYKaHjPv5bRadXnSWjdgV5TdcjTU3ZFKgA)kY18GmPaMKwLhScmeAD2DOM1qE8y5azYBzsGTpTThj06S7qnRH)LlN21Q1ysbmPtmjTkpyfyiFFqE14Uva8jpESCGmjqysnpixloyImjaamPr1SgY3hKxnUBfaFcn0(veYK3YK3XKoZKaaWK0Q8GvGHqRZUd1SgYJhlhitceM0OAwdXnSWjdgV5TdcjTU3ZFKgA)kY18GmPaMKwLhScmeAD2DOM1qE8y5azsGWKAEqUwCWeJIaBpFSdgfDdlCYGXDRYNZAuJxlSqtC5Oio22JGXlIIgvZAIIuZ75gvZA4(eQrrFcv(yhmkcvBaThK)LAAwtuJAumv8a506S7qnRjUC8AHJlhfXX2EemEruCSdgfZ1j1Sg(XwriV1Hyu0OAwtumxNuZA4hBfH8whIrnEnqhxokIJT9iy8IOi9tf)0II7ERrO1z3HAwdP7YKcysJQznKw(iF7nOsOH2VIqM0btEhtkGjnQM1qA5J8T3Gk5rAO9RixZdYK3YKRuqYJhlhyuCSdgfdxWfFn8rdKh4tOg4nxyu0OAwtuSdrEQ4jQXRbQ4YrrCSThbJxefh7Grr7M9h1WcYH5SIGCxF)yRyuSdrE1A8vkyuu4Oi9tf)0II7ERrO1z3HAwdP7YKaaWKgvZAihuX6j5WB(CnuzsbmPr1SgYbvSEso8Mpxdv(Jhlhitcehm5DKBefnQM1efTB2FudlihMZkcYD99JTIrnETqjUCuehB7rW4frrJQznrXvVbMMwpKVnWvmk2HiVAn(kfmkkCuK(PIFArXDV1i06S7qnRH0DzsaaysJQznKdQy9KC4nFUgQmPaM0OAwd5GkwpjhEZNRHk)XJLdKjbIdM8oYnIIyRHuLp2bJIREdmnTEiFBGRyuJxFJ4YrrCSThbJxefnQM1efx9gyAA9q(bbnVpRjk2HiVAn(kfmkkCuK(PIFArXDV1i06S7qnRH0DzsaaysJQznKdQy9KC4nFUgQmPaM0OAwd5GkwpjhEZNRHk)XJLdKjbIdM8oYnIIyRHuLp2bJIREdmnTEi)GGM3N1e141bN4YrrCSThbJxefh7GrXT5Xw(iF)2qdJIDiYRwJVsbJIchfPFQ4NwuC3BncTo7ouZAiDxMeaaM0OAwd5GkwpjhEZNRHktkGjnQM1qoOI1tYH385AOYF8y5azsG4GjVJCJOOr1SMO428ylFKVFBOHrnETqtC5Oio22JGXlIIJDWOimSOczNk(qEZM1OyhI8Q14RuWOOWrr6Nk(Pff39wJqRZUd1Sgs3LjbaGjnQM1qoOI1tYH385AOYKcysJQznKdQy9KC4nFUgQ8hpwoqMeioyY7i3ikAunRjkcdlQq2PIpK3SznQXRfQJlhfXX2EemEruCSdgf1BAdc5B7fc0nhegf7qKxTgFLcgffoks)uXpTO4U3AeAD2DOM1q6UmjaamPr1SgYbvSEso8MpxdvMuatAunRHCqfRNKdV5Z1qL)4XYbYKaXbtEh5grrJQznrr9M2Gq(2EHaDZbHrnE99iUCuehB7rW4frXXoyu0gAIJYfYukVA8ajeSorXoe5vRXxPGrrHJI0pv8tlkU7TgHwNDhQznKUltcaatAunRHCqfRNKdV5Z1qLjfWKgvZAihuX6j5WB(Cnu5pESCGmjqCWK3rUru0OAwtu0gAIJYfYukVA8ajeSornETW3fxokIJT9iy8IO4yhmkoy)nphUWyUqKJtOnu8JIDiYRwJVsbJIchfPFQ4NwuC3BncTo7ouZAiDxMeaaM0OAwd5GkwpjhEZNRHktkGjnQM1qoOI1tYH385AOYF8y5azsG4GjVJCJOOr1SMOyhI8uXtuJxlSWXLJI4yBpcgViko2bJIhZ3Q)GG8q8npiK7X1aV5cJIDiYRwJVsbJIchfPFQ4NwuC3BncTo7ouZAiDxMeaaM0OAwd5GkwpjhEZNRHktkGjnQM1qoOI1tYH385AOYF8y5azsG4GjVJCJOOr1SMO4X8T6piipeFZdc5ECnWBUWOg1O4xUC3qdIXLJxlCC5OOr1SMO43hKxnUBfa)Oio22JGXlIA8AGoUCuehB7rW4frr6Nk(PffDIjDIjvZJJsAE7GCxtPHeCSThbzsbmPr1eyKJdEseYK3YKcZKoZKaaWKgvtGroo4jritEltkuysNzsbm5U3AKWs5q9rtiKhnQgfnQM1efBE7Gq9tHGrnEnqfxokIJT9iy8IOi9tf)0II7ERrclLd1hnHqE0OAu0OAwtu0DHV2EdQrnETqjUCuehB7rW4frXoe5bctpYPguZznkkCuK(PIFArrNysAvEWkWqO1z3HAwd5XJLdKjVLjVJjbaGjB5Jq1EfFIr1eyKjfWK7ERr((G8QXDRa4t6UmPZmPaM0jMCjMC3BnsiAAoR8Ul5rJQmPaMCjMC3BnsyPCO(OjeYJgvzsbm5smP7JaZRwJVsbjT8r(2BqLjfWKoXKgvZAiT8r(2BqLqdTFfHm5ToysGMjbaGjDIjnQM1qCdlCYGXBE7Gqcn0(veYK36GjfMjfWKQ5XrjUHfozW4nVDqibhB7rqM0zMeaaM0jMunpokX8yWG6BWBAqER)lqWX2EeKjfWK0Q8GvGHa(2Anq((rtdjpAGlWKoZKaaWKoXKQ5Xrjq0(Cw5A1PHeCSThbzsbmPA)kQKq08AiXLQmjqCWKa1DmPZmjaamPtmPAECuslFeQ2R4tWX2EeKjfWKT8rOAVIpXOAcmYKoZKoZKohf7qKxTgFLcgffokAunRjk2Yh5BVb1OgV(gXLJI4yBpcgVikAunRjksnVNBunRH7tOgf9ju5JDWOOr1eyKRMhhfg141bN4YrrCSThbJxefPFQ4NwuC3BnI7cFr9g8qE0OktkGjPgu5AEqMeim5U3Ae3f(I6n4H84XYbYKcyYDV1iFFqE14Uva8jpESCGm5Tmj1GkxZdgfnQM1efDx4RT3GAuJxl0exokIJT9iy8IOyhI8aHPh5udQ5Sgffoks)uXpTOOtmjTkpyfyi06S7qnRH84XYbYK3YK3XKaaWKT8rOAVIpXOAcmYKcyYDV1iFFqE14Uva8jDxM0zMuat6etU7TgjennNvE3L8OrvMuat6etQ2VIkjenVgsCPktERdMeOUJjbaGjxIjvZJJsGO95SY1Qtdj4yBpcYKoZKohf7qKxTgFLcgffokAunRjk2Yh5BVb1OgVwOoUCuehB7rW4frXoe5bctpYPguZznkkCuK(PIFArrNysAvEWkWqO1z3HAwd5XJLdKjVLjVJjbaGjB5Jq1EfFIr1eyKjfWK7ERr((G8QXDRa4t6UmPZmPaMunpokbI2NZkxRonKGJT9iitkGjv7xrLeIMxdjUuLjbIdMeOUJjfWKoXK7ERrcrtZzL3DjpAuLjfWKlXKgvZAiqA90qcgmK21CwzsaayYLyYDV1iHOP5SY7UKhnQYKcyYLyYDV1iHLYH6JMqipAuLjDok2HiVAn(kfmkkCu0OAwtuSLpY3EdQrnE99iUCuehB7rW4frr6Nk(PffDFey(kfKimbsRNgYKcyYDV1iHOP5SY7UKUltkGjvZJJsGO95SY1Qtdj4yBpcYKcys1(vujHO51qIlvzsG4GjbQ7ysbmPtm5smPAECusZBhK7AknKGJT9iitcaatAunbg54GNeHmPdMuyM05OOr1SMOO7cFT9guJA8AHVlUCuehB7rW4frr6Nk(PffxIjDFey(kfKimXnSWjdgV5Tdczsbm5U3AKq00Cw5DxYJgvJIgvZAIIUHfozW4nVDqyuJxlSWXLJI4yBpcgViks)uXpTOOA)kQKq08AiXLQmjqCWKa1DmPaMunpokbI2NZkxRonKGJT9iyu0OAwtuesRNgg141cd0XLJI4yBpcgViks)uXpTOOr1eyKJdEseYK3YKaDu0OAwtue8T1AG89JMgg141cduXLJI4yBpcgViks)uXpTOOtmPAECusZBhK7AknKGJT9iitkGjnQMaJCCWtIqM8wMeOzsNzsaaysJQjWihh8KiKjVLjVru0OAwtuS5Tdc1pfcg141cluIlhfnQM1efB5JBZ7JI4yBpcgViQrnkQFocbvyC541chxokAunRjk2Hipv8aJI4yBpcgViQXRb64YrrCSThbJxefPFQ4NwuCjMKwLhScme6cuFPFnjLV9gujG930SMO4yhmk6wuHGkmVjcYP1XTRMM1WbrGtkgfnQM1efDlQqqfM3eb50642vtZA4GiWjfJAuJIq1gq7b5FPMM1exoETWXLJI4yBpcgViks)uXpTOOtmPtmPAECusZBhK7AknKGJT9iitkGjnQMaJCCWtIqM8wMuyMuatUet2YhHQ9k(eJQjWit6mtcaatAunbg54GNeHm5TmPqHjDMjfWK7ERrclLd1hnHqE0OAu0OAwtuS5Tdc1pfcg141aDC5Oio22JGXlII0pv8tlkU7TgjSuouF0ec5rJQmPaMC3BnsyPCO(OjeYJhlhitceM0OAwdPLpUnVNGbdPDf5AEWOOr1SMOO7cFT9guJA8AGkUCuehB7rW4frr6Nk(Pff39wJewkhQpAcH8OrvMuat6et6(iW8vkiryslFCBEptcaat2YhHQ9k(eJQjWitcaatAunRH4UWxBVbvso8MpxdvM05OOr1SMOO7cFT9guJA8AHsC5Oio22JGXlII0pv8tlksdTFfHm5ToysGIjfWKgvtGroo4jritEltc0mPaMCjMey7tB7rIByHtgmUBv(CwJIgvZAIIUHfozW4nVDqyuJxFJ4YrrCSThbJxefPFQ4NwuC3BnsyPCO(OjeYJgvzsbmPA)kQKq08AiXLQmjqCWKa1DmPaMunpokbI2NZkxRonKGJT9iyu0OAwtu0DHV2EdQrnEDWjUCuehB7rW4frr6Nk(Pff39wJ4UWxuVbpKhnQYKcysQbvUMhKjbctU7TgXDHVOEdEipESCGrrJQznrr3f(A7nOg141cnXLJI4yBpcgVik2Hipqy6ro1GAoRrrHJI0pv8tlk6etsRYdwbgcTo7ouZAipESCGm5Tm5DmPaMC3BnY3hKxnUBfaFcyfyysaayYw(iuTxXNyunbgzsNzsbm5smPAECuIqYb0NZkbhB7rqMuatUetcS9PT9iPLpY3EdQC3Q85SYKcysNysNysNysJQznKw(428EcgmK21CwzsaaysJQzne3f(A7nOsWGH0UMZkt6mtkGjDIj39wJeIMMZkV7sE0Oktcaat2YhHQ9k(eJQjWitkGjxIj39wJewkhQpAcH8OrvMuatUetU7TgjennNvE3L8OrvM0zM0zMeaaM0jMunpokbI2NZkxRonKGJT9iitkGjv7xrLeIMxdjUuLjbIdMeOUJjfWKoXK7ERrcrtZzL3DjpAuLjfWKlXKgvZAiqA90qcgmK21CwzsaayYLyYDV1iHLYH6JMqipAuLjfWKlXK7ERrcrtZzL3DjpAuLjfWKgvZAiqA90qcgmK21Cwzsbm5smPr1SgI7cFT9guj5WB(Cnuzsbm5smPr1SgslFCBEpjhEZNRHkt6mt6mtcaat6et2YhHQ9k(eJQjWitkGjDIjnQM1qCx4RT3GkjhEZNRHktcaatAunRH0Yh3M3tYH385AOYKoZKcyYLyYDV1iHOP5SY7UKhnQYKcyYLyYDV1iHLYH6JMqipAuLjDMjDok2HiVAn(kfmkkCu0OAwtuSLpY3EdQrnETqDC5Oio22JGXlII0pv8tlkQMhhLiKCa95SsWX2EeKjfWK7ERrcrtZzL3DjpAuLjfWKoXK0Q8GvGHqRZUd1SgYJhlhitElt26Ep)rAO9RixZdYKxYKantEjtQMhhLiKCa95SsWX2EeKjbaGjB5Jq1EfFYJhlhitElt26Ep)rAO9RixZdYKaaWKoXKlXKQ5XrjFFqE14Uva8j4yBpcYKaaWK0Q8GvGH89b5vJ7wbWN84XYbYK3YKAEqUwCWezsbmPr1SgY3hKxnUBfaFcn0(veYKaHjfMjDMjfWK0Q8GvGHqRZUd1SgYJhlhitEltQ5b5AXbtKjDokAunRjk2Yh5BVb1OgV(EexokIJT9iy8IOi9tf)0IIUpcmFLcseMaP1tdzsbm5U3AKq00Cw5Dxs3LjfWKQ5Xrjq0(Cw5A1PHeCSThbzsbmPA)kQKq08AiXLQmjqCWKa1DmPaM0jM0jMunpokP5TdYDnLgsWX2EeKjfWKgvtGroo4jrit6GjfMjfWKlXKT8rOAVIpXOAcmYKoZKaaWKoXKgvtGroo4jritceMuOWKcyYLys184OKM3oi31uAibhB7rqM0zM05OOr1SMOO7cFT9guJA8AHVlUCuehB7rW4frr6Nk(PffDIj39wJeIMMZkV7sE0Oktcaat6etUetU7TgjSuouF0ec5rJQmPaM0jM0OAwdPLpY3EdQeAO9RiKjVLjVJjbaGjvZJJsGO95SY1Qtdj4yBpcYKcys1(vujHO51qIlvzsG4GjbQ7ysNzsNzsNzsbm5smjW2N22Je3WcNmyC3Q85SgfnQM1efDdlCYGXBE7GWOgVwyHJlhfXX2EemEru0OAwtuKAEp3OAwd3Nqnk6tOYh7GrrJQjWixnpokmQXRfgOJlhfXX2EemEruK(PIFArrJQjWihh8KiKjVLjfokAunRjkc(2Anq((rtdJA8AHbQ4YrrCSThbJxefnQM1efPM3ZnQM1W9juJI(eQ8Xoyumv8a5(ka39Z6tDHOgVwyHsC5Oio22JGXlII0pv8tlkQ2VIkjenVgsCPktcehmjqDhtkGjvZJJsGO95SY1Qtdj4yBpcgfnQM1efH06PHrnETW3iUCu0OAwtuSLpUnVpkIJT9iy8IOgVw4GtC5OOr1SMOiKwpnmkIJT9iy8IOg1OO7J06SnnUC8AHJlhfnQM1efTNAdYZrrVhPAuehB7rW4frnEnqhxokIJT9iy8IOy5gfHOgfnQM1efb2(02EmkcS57yum4Cxuey75JDWOiTo7ouZA4F5YPDTATOgVgOIlhfXX2EemEruSCJIquJIgvZAIIaBFABpgfb28DmkI3VNUUiizkT(S6qUbDZ3gfY3g4kYKaaWK497PRlcsMsRpRoKV6nW006H8TbUImjaamjE)E66IGeyojuXNV6nW006H8TbUImjaamjE)E66IGeyojuXNBq38TrH8TbUImjaamjE)E66IGeWhnq(Q3attRhY3g4kYKaaWK497PRlcsaF0a5g0nFBuiFBGRitcaatI3VNUUiib8rdKtRZ2uBuiphyUoPXKaaWK497PRlcsMsRpRoKBq38TrH8dcAEFwdtcaatI3VNUUiizkT(S6q(Q3attRhYpiO59znmjaamjE)E66IGeyojuXNV6nW006H8dcAEFwdtcaatI3VNUUiibMtcv85g0nFBui)GGM3N1WKaaWK497PRlcsaF0a5REdmnTEi)GGM3N1WKaaWK497PRlcsaF0a5g0nFBui)GGM3N1WKaaWK497PRlcsaF0a506Sn1gfYpiO59znmjaamjE)E66IGKCDsnRHFSveYBDiYKaaWK497PRlcs0BAdc5B7fc0nheYKaaWK497PRlcsSB2FudlihMZkcYD99JTImjaamjE)E66IGeBOjokxitP8QXdKqW6WKaaWK497PRlcsGHfvi7uXhYB2SYKaaWK497PRlcsgS)MNdxymxiYXj0gk(mjaamjE)E66IGKT5Xw(iF)2qdJIaBpFSdgfP1z3HAwdVgEhIrnETqjUCuehB7rW4frXYnkcrnkAunRjkcS9PT9yueyZ3XOiE)E66IGe7MWq7niVvJYRg3TcGptkGjb2(02EKqRZUd1SgEn8oeJIaBpFSdgfB1OCWQV9iVgEhIrnE9nIlhfXX2EemEruSCJIquJIgvZAIIaBFABpgfb28Dmkc03XKcvmjW2N22JeAD2DOM1WRH3HitkGjxIjb2(02EK0Qr5GvF7rEn8oezYlzsHYDmPqftcS9PT9iPvJYbR(2J8A4DiYKxYKa9nysHkMeVFpDDrqIDtyO9gK3Qr5vJ7wbWNjfWKlXKaBFABpsA1OCWQV9iVgEhIrrGTNp2bJI1W7qKt7A1ArnEDWjUCuehB7rW4frnETqtC5Oio22JGXlIIJDWOODtyO9gK3Qr5vJ7wbWpkAunRjkA3egAVb5TAuE14Uva8JA8AH64YrrJQznrXt(F988yRyuehB7rW4frnE99iUCu0OAwtu0T0SMOio22JGXlIA8AHVlUCu0OAwtu0DHV2EdQrrCSThbJxe1Og1OiW4dZAIxd03j894oHgGgOJIbSFYzfgfdU54wVIGmPW3XKgvZAysFcviHTyu09Rw6XOOqNjVx5JmzWVTISff6mzOQUW7PRUAn1W(MqRZvW809MM1qFRPxbZd9k2IcDMm4tFTdvMeOcIjb67e(EWK3BMu47UNUty2ISff6mPqBOnRi8EITOqNjV3m59mezsnpixloyIm5BAi(mPgAdtQ2VIkrZdY1IdMit2QNj9guV3qKwditA70N6cmzhARiKWwKTOqNjdUpyiTRiitUXw9itsRZ2uMCJR5ajmzWhkfDvito1CVdT)06EM0OAwdKjRXVaHTOqNjnQM1ajUpsRZ2uhnVbfcBrHotAunRbsCFKwNTPx64QwvGSff6mPr1SgiX9rAD2MEPJRS(6bh10Sg2IgvZAGe3hP1zB6LoUYEQniphf9EKQSff6m5YHjKjb2(02EKjHOczsnezsnpitAktgimPHmzWx9bzYQXKbpRa4ZKWWQ7bzsOAVYKBmNvMeAaJGmzREMudrMCWGPmPqBD2DOM1WKUHgezlAunRbsCFKwNTPx64kGTpTThdASd6GwNDhQzn8VC50UwTwqLRdiQbbS57OJGZDSfnQM1ajUpsRZ20lDCfW2N22Jbn2bDqRZUd1SgEn8oedQCDarniGnFhDG3VNUUiizkT(S6qUbDZ3gfY3g4kcaaE)E66IGKP06ZQd5REdmnTEiFBGRiaa497PRlcsG5KqfF(Q3attRhY3g4kcaaE)E66IGeyojuXNBq38TrH8TbUIaaG3VNUUiib8rdKV6nW006H8TbUIaaG3VNUUiib8rdKBq38TrH8TbUIaaG3VNUUiib8rdKtRZ2uBuiphyUoPbaaE)E66IGKP06ZQd5g0nFBui)GGM3N1aaaE)E66IGKP06ZQd5REdmnTEi)GGM3N1aaaE)E66IGeyojuXNV6nW006H8dcAEFwdaa497PRlcsG5KqfFUbDZ3gfYpiO59znaaG3VNUUiib8rdKV6nW006H8dcAEFwdaa497PRlcsaF0a5g0nFBui)GGM3N1aaaE)E66IGeWhnqoToBtTrH8dcAEFwdaa497PRlcsY1j1Sg(XwriV1Hiaa497PRlcs0BAdc5B7fc0nhecaaE)E66IGe7M9h1WcYH5SIGCxF)yRiaa497PRlcsSHM4OCHmLYRgpqcbRdaa497PRlcsGHfvi7uXhYB2ScaaE)E66IGKb7V55WfgZfICCcTHIpaa497PRlcs2MhB5J89BdnKTOr1SgiX9rAD2MEPJRa2(02EmOXoOJwnkhS6BpYRH3HyqLRdiQbbS57Od8(901fbj2nHH2BqERgLxnUBfaFbaBFABpsO1z3HAwdVgEhISff6mzWnkEGmPgAktApYKDicYKvxHjiYKvJjfARZUd1SgM0EKjNszYoebzsRP4ZKAyczsnpitMnMudXfyYav3dYKUDLjnMu)CecQmzhIGmzGudzsH26S7qnRHjRHjnMegApicYK0Q8GvGHWw0OAwdK4(iToBtV0XvaBFABpg0yh0rn8oe50UwTwqLRdiQbbS57OdG(oHkGTpTThj06S7qnRHxdVdrblbS9PT9iPvJYbR(2J8A4DiEPq5oHkGTpTThjTAuoy13EKxdVdXlb6BiuH3VNUUiiXUjm0EdYB1O8QXDRa4lyjGTpTThjTAuoy13EKxdVdr2IgvZAGe3hP1zB6LoUcoMlmSuounfYw0OAwdK4(iToBtV0XvDiYtfpbn2bDy3egAVb5TAuE14Uva8zlAunRbsCFKwNTPx64Qt(F988yRiBrJQznqI7J06Sn9shx5wAwdBrJQznqI7J06Sn9shx5UWxBVbv2ISff6mzW9bdPDfbzsey8xGj18GmPgImPr16zYeYKgWw6TThjSfnQM1aDqR(O4dDrVNTOr1Sg4LoUIAEp3OAwd3NqnOXoOJuXdKhMRHC3pRp1fylAunRbEPJRo5)1ZZJTIbLnh7ERrO1z3HAwdbScmSfnQM1aV0Xv0AO4OVPiiV5TdYw0OAwd8shx1kAhIGC7M4NkY3ODylAunRbEPJRC7F2wiNv(2BqLTOr1Sg4LoU6txxpYZHdDnkYw0OAwd8shxPHiVp7QpG8w9uKTOr1Sg4LoUkq9EqGXC4pcRXgkYw0OAwd8shx99b5vJ7wbWpOS5qnpokPLpcv7v8j4yBpckOLpcv7v8jpESCG326Ep)rAO9RixZdcaaTkpyfyi06S7qnRH84XYbElW2N22JeAD2DOM1W)YLt7A1Ac29wJqRZUd1SgcyfyaaqZdY1IdMiqOv5bRadHwNDhQznKhpwoqb7ERrO1z3HAwdbScmSfnQM1aV0XvuZ75gvZA4(eQbn2bDqRZUd1SgUBObXGYMdNuZJJs((G8QXDRa4tWX2EeuaTkpyfyi06S7qnRH84XYbcehgvZAiFFqE14Uva8judQCnpiaa0Q8GvGHqRZUd1SgYJg4colyPw(iuTxXNyunbgbay3BncTo7ouZAiDx2IgvZAGx64Qw(iF7nOguhI8aHPh5udQ5S6q4G6qKxTgFLc6q4GYMdNqiehkso4P(f4vJ770eKd(ODGKJfCvpaaieIdfjh8u)c8QX9DAcYbF0oqYjN6fy3e)urY2BqfF(XGk(eCSThbDwan0(ve64ybJtdTFfHcwA3BnsyPCO(OjeYJgvfSKt7ERrcrtZzL3DjpAuvGt7ERrO1z3HAwdP7kWjJQznKw(428Eso8MpxdvaamQM1qCx4RT3GkjhEZNRHkaagvZAiqA90qcgmK21CwDgaa1(vujHO51qIlvbIdG6obgvZAiqA90qcgmK21CwD2zbl50s7ERrcrtZzL3DjpAuvWs7ERrclLd1hnHqE0OQGDV1i06S7qnRHawbgbozunRH0Yh3M3tYH385AOcaGr1SgI7cFT9guj5WB(CnuD2z2IgvZAGx64Qw(iF7nOguhI8aHPh5udQ5S6q4G6qKxTgFLc6q4GYMdNqiehkso4P(f4vJ770eKd(ODGKJfCvpaaieIdfjh8u)c8QX9DAcYbF0oqYjN6fy3e)urY2BqfF(XGk(eCSThbDwan0(ve64ybJtdTFfHcwA3BnsyPCO(OjeYJgvfSKt7ERrcrtZzL3DjpAuvGt7ERrO1z3HAwdP7kWjJQznKw(428Eso8MpxdvaamQM1qCx4RT3GkjhEZNRHkaagvZAiqA90qcgmK21CwDgaa1(vujHO51qIlvbIdG6obgvZAiqA90qcgmK21CwD2zbl50s7ERrcrtZzL3DjpAuvWs7ERrclLd1hnHqE0OQGDV1i06S7qnRHawbgbozunRH0Yh3M3tYH385AOcaGr1SgI7cFT9guj5WB(CnuD2z2IgvZAGx64kQ59CJQznCFc1Gg7Go(YL7gAqmOS5y3BnY3hKxnUBfaFs3vWU3AeAD2DOM1qaRadBrJQznWlDCfW2N22Jbn2bD0Yh5BVbvUBv(CwdcyZ3rhQ5XrjFFqE14Uva8j4yBpckGwLhScmKVpiVAC3ka(KhpwoqGqRYdwbgslFKV9gujTU3ZFKgA)kY18GcCIwLhScmeAD2DOM1qE8y5aVfy7tB7rcTo7ouZA4F5YPDTAnaaA5Jq1EfFIr1ey0zborRYdwbgY3hKxnUBfaFYJhlhiq08GCT4GjcaGr1SgY3hKxnUBfaFcn0(veE7DodaaTkpyfyi06S7qnRH84XYbceJQznKw(iF7nOsADVN)in0(vKR5bVKwLhScmKw(iF7nOsa7VPzncv2nXpvKS9guXNFmOIpbhB7rqbl1YhHQ9k(eJQjWOaAvEWkWqO1z3HAwd5XJLdeiAEqUwCWebaqnpokPLpcv7v8j4yBpckOLpcv7v8jgvtGrbT8rOAVIp5XJLdei0Q8GvGH0Yh5BVbvsR798hPH2VICnp4L0Q8GvGH0Yh5BVbvcy)nnRrOYUj(PIKT3Gk(8Jbv8j4yBpcYw0OAwd8shxbS9PT9yqJDqhUHfozW4Uv5ZzniGnFhDOMhhL89b5vJ7wbWNGJT9iOaAvEWkWq((G8QXDRa4tE8y5abcTkpyfyiUHfozW4nVDqiP19E(J0q7xrUMhuaTkpyfyi06S7qnRH84XYbElW2N22JeAD2DOM1W)YLt7A1AcCIwLhScmKVpiVAC3ka(KhpwoqGO5b5AXbteaaJQznKVpiVAC3ka(eAO9Ri827CgaaAvEWkWqO1z3HAwd5XJLdeigvZAiUHfozW4nVDqiP19E(J0q7xrUMhuaTkpyfyi06S7qnRH84XYbcenpixloyISfnQM1aV0XvuZ75gvZA4(eQbn2bDavBaThK)LAAwdBr2IgvZAGeJQjWixnpok0HpboNv(Uo7GYMdJQjWihh8Ki8wHfS7TgHwNDhQzneWkWiWjAvEWkWqO1z3HAwd5XJLd8wAvEWkWq8jW5SY31zta7VPznaaqRYdwbgcTo7ouZAipAGl4mBrJQznqIr1eyKRMhhfEPJRoOI1hu2CS7Tg57dYRg3TcGpP7kWPw(iuTxXN84XYbElTkpyfyihuX6jG930SgaawQLpcv7v8jgvtGrNbaGwLhScmKVpiVAC3ka(KhpwoWB18GCT4GjkWOAwd57dYRg3TcGpHgA)kcbIWaa4eTkpyfyihuX6jG930SgGqRYdwbgcTo7ouZAipESCGaaqRYdwbgcTo7ouZAipAGl4SGLuZJJs((G8QXDRa4tWX2EeuGt0Q8GvGHCqfRNa2FtZAaslFeQ2R4tE8y5abayj184OKw(iuTxXNGJT9iiaal1YhHQ9k(eJQjWOZSfzlk0zsH26S7qnRHjDdniYKUp6ApczsBN(uteYKbsnKjnMee92cbXKAiomP36dneHmzoAXKAiYKcT1z3HAwdtcX73XHISfnQM1aj06S7qnRH7gAq0Hpxdvip4QdUEWrdkBo29wJqRZUd1SgcyfyylAunRbsO1z3HAwd3n0G4LoUYNaNZkFxNDqzZXU3AeAD2DOM1qaRaJaJQjWihh8Ki8wHzlAunRbsO1z3HAwd3n0G4LoUA7RcKxnUgICCWZcSfnQM1aj06S7qnRH7gAq8shxT2ThmTHxnUDt8lnKTOr1SgiHwNDhQznC3qdIx64QdEQFbE14(onb5GpAhiBrHotg8D)ZzLjfARZUd1SMGyY7v(itEH3GkKjThzYoebzsTyYvCW3uKjdElLjf1hnHazsBazYto5jVjYKAiYK2P6JYKvJj18Gmj0fhLjXGH0UMZktwAi(mj0f9EiHjVx1ZKq1gq7bzY7v(yqm59kFKjVWBqfYK2Jmzn(fyYoebzYaH4WKbVOP5SYK3ZUmzczsJQjWitwptgiehM0ysrA90qMKAqLjtitMdt6(16JqitAditg8IMMZktEp7YK2aYKbVLYKI6JMqys7rMCkLjnQMaJeMm42udzYl8guXNjd(nOIptAditEV82bzYG7MGyY7v(itEH3GkKjP2WKgiyQznM3VatUrMSdrqMmqy6rMm4TuMuuF0ectAditg8IMMZktEp7YK2Jm5uktAunbgzsBazsJjdEUWxBVbvMmHmzomPgImPLptAditAEyXKbctpYKudQ5SYKI06PHmjcmomz2yYGx00CwzY7zxMmHmP5F0axGjnQMaJeMC5qKj9MQ4ZKM3xbGmPgOyYG3szsr9rtimzWZf(A7nOczsTyYnYKudQmzomjStPieM1WKwtXNj1qKjfP1tdjmzWhqWuZAmVFbMmqQHm5fEdQ4ZKb)guXNjTbKjVxE7GmzWDtqm59kFKjVWBqfYKWWQ7bzYPuMCJmzhIGmzF8ieYKx4nOIptg8BqfFMmHmPTRUYKAXKyWCZhzY6zsneFKjThzYt9itQH2WK4u91qM8ELpYKx4nOczsTysmykoGm5fEdQ4ZKb)guXNj1Ij1qKjXbKjRgtk0wNDhQzne2IgvZAGeAD2DOM1WDdniEPJRA5J8T3GAqDiYdeMEKtnOMZQdHdQdrE1A8vkOdHdkBoOH2VIWBDiSaNCYOAwdPLpY3EdQeAO9RiK3EJQznM)sN29wJqRZUd1SgYJhlh49E3BnY2BqfF(XGk(eW(BAwJZbpOv5bRadPLpY3EdQeW(BAwZ92PDV1i06S7qnRH84XYb6CWdN29wJS9guXNFmOIpbS)MM1CVVJCdND(wh3baWs2nXpvKS9guXNFmOIpbhB7rqaawsnpokP5TdYRHGJT9iiaa7ERrO1z3HAwd5XJLdeio29wJS9guXNFmOIpbS)MM1aaWU3AKT3Gk(8Jbv8jpESCGa5oYnaaaVFpDDrqs4cU4RHpAG8aFc1aV5cfqRYdwbgs4cU4RHpAG8aFc1aV5c5a1D3jSqbOjpESCGa5goly3BncTo7ouZAiDxboTKr1SgcKwpnKGbdPDnNvblzunRH4UWxBVbvso8Mpxdvb7ERrcrtZzL3DjDxaamQM1qG06PHemyiTR5Sky3BnsyPCO(Ojecyfye40U3AKq00Cw5DxcyfyaaWUj(PIKT3Gk(8Jbv8j4yBpc6maa2nXpvKS9guXNFmOIpbhB7rqbQ5XrjnVDqEneCSThbfyunRH4UWxBVbvso8Mpxdvb7ERrcrtZzL3DjGvGrWU3AKWs5q9rtieWkW4mBrJQznqcTo7ouZA4UHgeV0XvFFqE14Uva8dkBo29wJqRZUd1Sgcyfyylk0zYGBtnKjVWBqfFMm43Gk(bXKgtEVYhzYl8guzsyy19Gm5gzYoebzYaHPhzsQb1CwzYGV6dYKvJjdEwbWNWw0OAwdKqRZUd1SgUBObXlDCvlFKV9gudQdrEGW0JCQb1CwDiCqzZHDt8tfjBVbv85hdQ4tWX2EeuGAECusZBhKxdbhB7rqb7ERr2EdQ4ZpguXNawbgboPMhhL89b5vJ7wbWNGJT9iOaJQznKVpiVAC3ka(emyiTR5SkWOAwd57dYRg3TcGpbdgs7kYF8y5abYDKGdaaorRYdwbgcTo7ouZAipAGlaaWU3AeAD2DOM1q6Uolyj184OKVpiVAC3ka(eCSThbfSKr1SgI7cFT9guj5WB(CnufSKr1SgslFCBEpjhEZNRHQZSfnQM1aj06S7qnRH7gAq8shxrnVNBunRH7tOg0yh0Hr1eyKRMhhfYw0OAwdKqRZUd1SgUBObXlDCfTo7ouZAcQdrE1A8vkOdHdQdrEGW0JCQb1CwDiCqzZHtozunRHCqfRNKdV5Z1qvGr1SgYbvSEso8Mpxdv(JhlhiqCCh5godaWsQ5XrjhuX6j4yBpc6SaN29wJ89b5vJ7wbWN0Dbayj184OKVpiVAC3ka(eCSThbDMTOr1SgiHwNDhQznC3qdIx64k3sZAylAunRbsO1z3HAwd3n0G4LoUA7RcK36)cSfnQM1aj06S7qnRH7gAq8shxTXhIVqYzLTOr1SgiHwNDhQznC3qdIx64Qw(42xfiBrJQznqcTo7ouZA4UHgeV0Xv2qrO(MNtnVNTOr1SgiHwNDhQznC3qdIx64kQ59CJQznCFc1Gg7Go0phHGkKTOr1SgiHwNDhQznC3qdIx64QM3oiu)uiyqzZHtoPMhhL082b5UMsdj4yBpckWOAcmYXbpjcVfODgaaJQjWihh8Ki82GJZc29wJewkhQpAcH8Orvblz3e)urY2BqfF(XGk(eCSThbzlAunRbsO1z3HAwd3n0G4LoUYDHV2EdQbLnh7ERrCx4lQ3GhYJgvfS7TgHwNDhQznKhpwoWBPgu5AEq2IgvZAGeAD2DOM1WDdniEPJRCx4RT3GAqzZXU3AKWs5q9rtiKhnQYw0OAwdKqRZUd1SgUBObXlDCvlFKV9gudQdrE1A8vkOdHdQdrEGW0JCQb1CwDiCqzZbcH4qrYbp1VaVACFNMGCWhTdKCSGR6f4en0(veYBVr1SgZFRWeGcaGDV1iBVbv85hdQ4tE8y5abYDKBaaWU3AeAD2DOM1qE8y5abYU3AKT3Gk(8Jbv8jG930SgaawYUj(PIKT3Gk(8Jbv8j4yBpc6SaNCA3BncTo7ouZAiDxboT7TgjennNvE3L8OrvblzunRH4UWxBVbvso8MpxdvblzunRHaP1tdjyWqAxZz1zaaCYOAwdbsRNgsWGH0UI8hpwoqb7ERrcrtZzL3DjGvGrWU3AKWs5q9rtieWkWiyjJQzne3f(A7nOsYH385AO6SZoZw0OAwdKqRZUd1SgUBObXlDCvlFKV9gudQdrE1A8vkOdHdQdrEGW0JCQb1CwDiCqzZXsieIdfjh8u)c8QX9DAcYbF0oqYXcUQxGtlz3e)urY2BqfF(XGk(eCSThbbayj184OKM3oiVgco22JGolWjN29wJqRZUd1Sgs3vGt7ERrcrtZzL3DjpAuvWsgvZAiUl812BqLKdV5Z1qvWsgvZAiqA90qcgmK21CwDgaaNmQM1qG06PHemyiTRi)XJLduWU3AKq00Cw5DxcyfyeS7TgjSuouF0ecbScmcwYOAwdXDHV2EdQKC4nFUgQo7SZSfnQM1aj06S7qnRH7gAq8shx5UWxBVb1GYMd3hbMVsbjctG06PHc29wJeIMMZkV7s6USfnQM1aj06S7qnRH7gAq8shx5gw4KbJ382bHSfnQM1aj06S7qnRH7gAq8shxbP1tddkBo29wJqRZUd1SgYJhlh4TudQCnpOGDV1i06S7qnRH0Dbay3BncTo7ouZAiGvGHTOr1SgiHwNDhQznC3qdIx64kFcCoR8DD2bLnh7ERrO1z3HAwd5XJLdeiRuqYXcMaJQjWihh8Ki8wHzlAunRbsO1z3HAwd3n0G4LoUc8T1AG89JMggu2CS7TgHwNDhQznKhpwoqGSsbjhlyc29wJqRZUd1Sgs3LTOr1SgiHwNDhQznC3qdIx64kiTEAyqzZHA)kQKq08AiXLQaXbqDNa184OeiAFoRCT60qco22JGSfzlAunRbssfpqoTo7ouZAC0Hipv8e0yh0rUoPM1Wp2kc5ToezlAunRbssfpqoTo7ouZAU0XvDiYtfpbn2bDeUGl(A4JgipWNqnWBUWGYMJDV1i06S7qnRH0DfyunRH0Yh5BVbvcn0(ve64obgvZAiT8r(2BqL8in0(vKR5bVDLcsE8y5azlAunRbssfpqoTo7ouZAU0XvDiYtfpb1HiVAn(kf0HWbn2bDy3S)OgwqomNveK767hBfdkBo29wJqRZUd1Sgs3faaJQznKdQy9KC4nFUgQcmQM1qoOI1tYH385AOYF8y5abIJ7i3GTOr1Sgijv8a506S7qnR5shx1Hipv8euhI8Q14Ruqhche2Aiv5JDqhREdmnTEiFBGRyqzZXU3AeAD2DOM1q6UaayunRHCqfRNKdV5Z1qvGr1SgYbvSEso8Mpxdv(JhlhiqCCh5gSfnQM1ajPIhiNwNDhQznx64Qoe5PING6qKxTgFLc6q4GWwdPkFSd6y1BGPP1d5he08(SMGYMJDV1i06S7qnRH0DbaWOAwd5GkwpjhEZNRHQaJQznKdQy9KC4nFUgQ8hpwoqG44oYnylAunRbssfpqoTo7ouZAU0XvDiYtfpb1HiVAn(kf0HWbn2bDSnp2Yh573gAyqzZXU3AeAD2DOM1q6UaayunRHCqfRNKdV5Z1qvGr1SgYbvSEso8Mpxdv(JhlhiqCCh5gSfnQM1ajPIhiNwNDhQznx64Qoe5PING6qKxTgFLc6q4Gg7GoGHfvi7uXhYB2Sgu2CS7TgHwNDhQznKUlaagvZAihuX6j5WB(CnufyunRHCqfRNKdV5Z1qL)4XYbceh3rUbBrJQznqsQ4bYP1z3HAwZLoUQdrEQ4jOoe5vRXxPGoeoOXoOd9M2Gq(2EHaDZbHbLnh7ERrO1z3HAwdP7caGr1SgYbvSEso8MpxdvbgvZAihuX6j5WB(Cnu5pESCGaXXDKBWw0OAwdKKkEGCAD2DOM1CPJR6qKNkEcQdrE1A8vkOdHdASd6WgAIJYfYukVA8ajeSobLnh7ERrO1z3HAwdP7caGr1SgYbvSEso8MpxdvbgvZAihuX6j5WB(Cnu5pESCGaXXDKBWw0OAwdKKkEGCAD2DOM1CPJR6qKNkEcQdrE1A8vkOdHdASd6yW(BEoCHXCHihNqBO4hu2CS7TgHwNDhQznKUlaagvZAihuX6j5WB(CnufyunRHCqfRNKdV5Z1qL)4XYbceh3rUbBrJQznqsQ4bYP1z3HAwZLoUQdrEQ4jOoe5vRXxPGoeoOXoOJJ5B1FqqEi(MheY94AG3CHbLnh7ERrO1z3HAwdP7caGr1SgYbvSEso8MpxdvbgvZAihuX6j5WB(Cnu5pESCGaXXDKBWwKTOr1Sgijv8a5H5Ai39Z6tDbhuZ75gvZA4(eQbn2bDKkEGCAD2DOM1eu2C4KAECuY3hKxnUBfaFco22JGcOv5bRadHwNDhQznKhpwoqG4WOAwd57dYRg3TcGpHAqLR5bbaGwLhScmeAD2DOM1qE0axWzbl1YhHQ9k(eJQjWiaa7ERrO1z3HAwdP7Yw0OAwdKKkEG8WCnK7(z9PUWLoUQdrEQ4bYw0OAwdKKkEG8WCnK7(z9PUWLoUQdrEQ4jOXoOd7MWq7niVvJYRg3TcGFqzZbTkpyfyi06S7qnRH84XYbceh34sHVHqfW2N22JKwnkhS6BpYRH3HiBrJQznqsQ4bYdZ1qU7N1N6cx64Qoe5PINGg7Go(sPFhQiih4QaRIdwEFqzZbTkpyfyi06S7qnRH84XYbElW2N22JKA4DiYPDTAn2IgvZAGKuXdKhMRHC3pRp1fU0XvDiYtfpbn2bDy3VNULIJYhRRPVddkBoOv5bRadHwNDhQznKhpwoWBb2(02EKudVdroTRvRXw0OAwdKKkEG8WCnK7(z9PUWLoUQdrEQ4jOXoOdyycm(CGXPo8h9jnOS5GwLhScmeAD2DOM1qE8y5aVfy7tB7rsn8oe50UwTgBrJQznqsQ4bYdZ1qU7N1N6cx64Qoe5PINGWwdPkFSd6i0(tnjLdIhtXpnFEt8zlAunRbssfpqEyUgYD)S(ux4shx1Hipv8e0yh0XX8T6piipeFZdc5ECnWBUWGYMdAvEWkWqO1z3HAwd5XJLd8wh34gc29wJqRZUd1SgcyfyeqRYdwbgcTo7ouZAipESCG3cS9PT9iPgEhICAxRwJTOr1Sgijv8a5H5Ai39Z6tDHlDCvhI8uXtqJDqh2qtCuUqMs5vJhiHG1jOS5GwLhScmeAD2DOM1qE8y5aV1XnUHGDV1i06S7qnRHawbgb0Q8GvGHqRZUd1SgYJhlh4TaBFABpsQH3HiN21Q1ylAunRbssfpqEyUgYD)S(ux4shx1Hipv8e0yh0XG938C4cJ5crooH2qXpOS5GwLhScmeAD2DOM1qE8y5aV1Hq5gc29wJqRZUd1SgcyfyeqRYdwbgcTo7ouZAipESCG3cS9PT9iPgEhICAxRwJTiBrJQznqsQ4bY9vaU7N1N6co6qKNkEcASd6qtqeQ1F40cedwqzZbTkpyfyi06S7qnRH84XYbElW2N22JKA4DiYPDTAnaauZJJsA5Jq1EfFco22JGcA5Jq1EfFYJhlh4TaBFABpsQH3HiN21Q1ylAunRbssfpqUVcWD)S(ux4shx1Hipv8ee2Aiv5JDqh0fO(s)AskF7nOgu2CqRYdwbgcTo7ouZAipESCG3cS9PT9iPgEhICAxRwdaa184OKw(iuTxXNGJT9iOGw(iuTxXN84XYbElW2N22JKA4DiYPDTAn2ISfnQM1ajF5YDdni647dYRg3TcGpBrJQznqYxUC3qdIx64QM3oiu)uiyqzZHtoPMhhL082b5UMsdj4yBpckWOAcmYXbpjcVvyNbaWOAcmYXbpjcVvO4SGDV1iHLYH6JMqipAuLTOr1Sgi5lxUBObXlDCL7cFT9gudkBo29wJewkhQpAcH8Orv2IgvZAGKVC5UHgeV0XvT8r(2BqnOoe5vRXxPGoeoOoe5bctpYPguZz1HWbLnhorRYdwbgcTo7ouZAipESCG3EhaaT8rOAVIpXOAcmky3BnY3hKxnUBfaFs31zboT0U3AKq00Cw5DxYJgvfS0U3AKWs5q9rtiKhnQkyj3hbMxTgFLcsA5J8T3GQaNmQM1qA5J8T3GkHgA)kcV1bqdaGtgvZAiUHfozW4nVDqiHgA)kcV1HWcuZJJsCdlCYGXBE7Gqco22JGodaGtQ5XrjMhdguFdEtdYB9Fbco22JGcOv5bRadb8T1AG89JMgsE0axWzaaCsnpokbI2NZkxRonKGJT9iOa1(vujHO51qIlvbIdG6oNbaWj184OKw(iuTxXNGJT9iOGw(iuTxXNyunbgD2zNzlAunRbs(YL7gAq8shxrnVNBunRH7tOg0yh0Hr1eyKRMhhfYw0OAwdK8Ll3n0G4LoUYDHV2EdQbLnh7ERrCx4lQ3GhYJgvfqnOY18Gaz3BnI7cFr9g8qE8y5afS7Tg57dYRg3TcGp5XJLd8wQbvUMhKTOr1Sgi5lxUBObXlDCvlFKV9gudQdrE1A8vkOdHdQdrEGW0JCQb1CwDiCqzZHt0Q8GvGHqRZUd1SgYJhlh4T3baqlFeQ2R4tmQMaJc29wJ89b5vJ7wbWN0DDwGt7ERrcrtZzL3DjpAuvGtQ9ROscrZRHexQERdG6oaawsnpokbI2NZkxRonKGJT9iOZoZw0OAwdK8Ll3n0G4LoUQLpY3EdQb1HiVAn(kf0HWb1Hipqy6ro1GAoRoeoOS5WjAvEWkWqO1z3HAwd5XJLd827aaOLpcv7v8jgvtGrb7ERr((G8QXDRa4t6UolqnpokbI2NZkxRonKGJT9iOa1(vujHO51qIlvbIdG6oboT7TgjennNvE3L8OrvblzunRHaP1tdjyWqAxZzfaGL29wJeIMMZkV7sE0OQGL29wJewkhQpAcH8OrvNzlAunRbs(YL7gAq8shx5UWxBVb1GYMd3hbMVsbjctG06PHc29wJeIMMZkV7s6UcuZJJsGO95SY1Qtdj4yBpckqTFfvsiAEnK4svG4aOUtGtlPMhhL082b5UMsdj4yBpccaGr1eyKJdEse6qyNzlAunRbs(YL7gAq8shx5gw4KbJ382bHbLnhl5(iW8vkiryIByHtgmEZBheky3BnsiAAoR8Ul5rJQSfnQM1ajF5YDdniEPJRG06PHbLnhQ9ROscrZRHexQceha1DcuZJJsGO95SY1Qtdj4yBpcYw0OAwdK8Ll3n0G4LoUc8T1AG89JMggu2Cyunbg54GNeH3c0SfnQM1ajF5YDdniEPJRAE7Gq9tHGbLnhoPMhhL082b5UMsdj4yBpckWOAcmYXbpjcVfODgaaJQjWihh8Ki82BWw0OAwdK8Ll3n0G4LoUQLpUnVNTiBrJQznqcuTb0Eq(xQPznoAE7Gq9tHGbLnho5KAECusZBhK7AknKGJT9iOaJQjWihh8Ki8wHfSulFeQ2R4tmQMaJodaGr1eyKJdEseERqXzb7ERrclLd1hnHqE0OkBrJQznqcuTb0Eq(xQPznx64k3f(A7nOgu2CS7TgjSuouF0ec5rJQc29wJewkhQpAcH84XYbceJQznKw(428EcgmK2vKR5bzlAunRbsGQnG2dY)snnR5shx5UWxBVb1GYMJDV1iHLYH6JMqipAuvGtUpcmFLcseM0Yh3M3daqlFeQ2R4tmQMaJaayunRH4UWxBVbvso8MpxdvNzlAunRbsGQnG2dY)snnR5shx5gw4KbJ382bHbLnh0q7xr4ToakbgvtGroo4jr4TaTGLa2(02EK4gw4KbJ7wLpNv2IgvZAGeOAdO9G8VutZAU0XvUl812BqnOS5y3BnsyPCO(OjeYJgvfO2VIkjenVgsCPkqCau3jqnpokbI2NZkxRonKGJT9iiBrJQznqcuTb0Eq(xQPznx64k3f(A7nOgu2CS7TgXDHVOEdEipAuva1GkxZdcKDV1iUl8f1BWd5XJLdKTOr1SgibQ2aApi)l10SMlDCvlFKV9gudQdrE1A8vkOdHdQdrEGW0JCQb1CwDiCqzZHt0Q8GvGHqRZUd1SgYJhlh4T3jy3BnY3hKxnUBfaFcyfyaaOLpcv7v8jgvtGrNfSKAECuIqYb0NZkbhB7rqblbS9PT9iPLpY3EdQC3Q85SkWjNCYOAwdPLpUnVNGbdPDnNvaamQM1qCx4RT3Gkbdgs7AoRolWPDV1iHOP5SY7UKhnQcaqlFeQ2R4tmQMaJcwA3BnsyPCO(OjeYJgvfS0U3AKq00Cw5DxYJgvD2zaaCsnpokbI2NZkxRonKGJT9iOa1(vujHO51qIlvbIdG6oboT7TgjennNvE3L8OrvblzunRHaP1tdjyWqAxZzfaGL29wJewkhQpAcH8OrvblT7TgjennNvE3L8OrvbgvZAiqA90qcgmK21CwfSKr1SgI7cFT9guj5WB(CnufSKr1SgslFCBEpjhEZNRHQZodaGtT8rOAVIpXOAcmkWjJQzne3f(A7nOsYH385AOcaGr1SgslFCBEpjhEZNRHQZcwA3BnsiAAoR8Ul5rJQcwA3BnsyPCO(OjeYJgvD2z2IgvZAGeOAdO9G8VutZAU0XvT8r(2BqnOS5qnpokri5a6ZzLGJT9iOGDV1iHOP5SY7UKhnQkWjAvEWkWqO1z3HAwd5XJLd82w375psdTFf5AEWlb6lvZJJsesoG(Cwj4yBpccaqlFeQ2R4tE8y5aVT19E(J0q7xrUMheaaNwsnpok57dYRg3TcGpbhB7rqaaOv5bRad57dYRg3TcGp5XJLd8wnpixloyIcmQM1q((G8QXDRa4tOH2VIqGiSZcOv5bRadHwNDhQznKhpwoWB18GCT4Gj6mBrJQznqcuTb0Eq(xQPznx64k3f(A7nOgu2C4(iW8vkirycKwpnuWU3AKq00Cw5Dxs3vGAECuceTpNvUwDAibhB7rqbQ9ROscrZRHexQceha1DcCYj184OKM3oi31uAibhB7rqbgvtGroo4jrOdHfSulFeQ2R4tmQMaJodaGtgvtGroo4jriqekcwsnpokP5TdYDnLgsWX2Ee0zNzlAunRbsGQnG2dY)snnR5shx5gw4KbJ382bHbLnhoT7TgjennNvE3L8OrvaaCAPDV1iHLYH6JMqipAuvGtgvZAiT8r(2BqLqdTFfH3EhaaQ5Xrjq0(Cw5A1PHeCSThbfO2VIkjenVgsCPkqCau35SZolyjGTpTThjUHfozW4Uv5ZzLTOr1SgibQ2aApi)l10SMlDCf18EUr1SgUpHAqJDqhgvtGrUAECuiBrJQznqcuTb0Eq(xQPznx64kW3wRbY3pAAyqzZHr1eyKJdEseERWSfnQM1ajq1gq7b5FPMM1CPJROM3ZnQM1W9judASd6iv8a5(ka39Z6tDb2IgvZAGeOAdO9G8VutZAU0XvqA90WGYMd1(vujHO51qIlvbIdG6obQ5Xrjq0(Cw5A1PHeCSThbzlAunRbsGQnG2dY)snnR5shx1Yh3M3Zw0OAwdKavBaThK)LAAwZLoUcsRNgYwKTOr1Sgir)CecQqhDiYtfpq2IgvZAGe9ZriOcV0XvDiYtfpbn2bD4wuHGkmVjcYP1XTRMM1WbrGtkgu2CSeTkpyfyi0fO(s)AskF7nOsa7VPznrrOlsJxhCaQOg1ye]] )


end
