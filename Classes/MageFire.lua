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


    spec:RegisterPack( "Fire", 20190810, [[dSukycqiLipcvI6scuPAtOIrjGoLazvGkPELssZsaULkQu7cXVuszyQiDmuPwgOs9mujmnqL4AkPY2eOkFtGkmoqLKZPIkzDQOImpqf3JkSpvuoOavflujXdrLiMOavkDrujs1gvrf(OkQO0ifOIoPkQOALkHUPavYovr8tbQumubQkTuujs5POQPQe1vrLi5RQOII9k0FjmyIomLfRupgLjdYLH2Su(SkmAbDArRwGQQxJkPztv3wL2TIFlz4uPJRIQwUQEoW0jDDPA7GQ(ov04fOCELG1RKQMpOSFKoYDC5ipKPy8e4(uUpxNcxX9Pe4MlGB4YPRlYRl4IrExJXv7aJ8JDXi)5iFmY7Al4ldkUCKhu9NHr(qvDbNtRT2rQH9nHv31a5T7nnRH9wtxdKx2Ar(Dp9658jUJ8qMIXtG7t5(CDkCf3NsGBUaU5I1bxI8wxdRpYZN3U30SgUK3AAKpmHGWjUJ8qiGf55Yu55iFKkdUSdKUixMkdv1fCoT2AhPg23ewDxdK3U30Sg2BnDnqEzRrxKltLbF6hDGsLCFAaujCFk3NlQ8CtLCF650PCtxKUixMk5scT5abNt0f5Yu55Mk5sbqQuZlk0saLiv(MgIpvQH2qLQ9hOs08IcTeqjsLT6PsVb0Znaz1arL2o9PUav2b2bcirEFcuqC5iFQ4fi8LtH7N1N6cXLJNWDC5ipo22JqXvI8gtZAI8AcHaT(RGvqyWI8Spv8tlYZQYdvohcRU7oqZAipETCau5zuj82N22JKAeDakyDTAnQegmQunpokPLpcu7v8j4yBpcrLCOYw(iqTxXN841YbqLNrLWBFABpsQr0bOG11Q1I8JDXiVMqiqR)kyfegSOgpbUJlh5XX2EekUsK3yAwtKNTaZx6xtYeBVb0ip7tf)0I8SQ8qLZHWQ7Ud0SgYJxlhavEgvcV9PT9iPgrhGcwxRwJkHbJkvZJJsA5Ja1EfFco22JqujhQSLpcu7v8jpETCau5zuj82N22JKAeDakyDTATip2AitfJDXipBbMV0VMKj2EdOrnQrEwD3DGM1iCdnagxoEc3XLJ84yBpcfxjYZ(uXpTi)U3AewD3DGM1qGkNtK3yAwtK3NhHkqe83HoU4OrnEcChxoYBmnRjYV9vbjQMqdrbo4DHipo22JqXvIA8eUiUCK3yAwtK)I36xqunHVZsib0J2fe5XX2EekUsuJNaxIlh5XX2EekUsKVdqHZW0JcMb0CoI8Ch5zFQ4NwKNfA)bcOYZCqLCtLCOYaPYaPsJPznKw(Oy7nGsyH2FGar7nMM1yEQCvQmqQC3BncRU7oqZAipETCau55Mk39wJS9gqXxCnGIpbQ)MM1qLbrLb3PswvEOY5qA5JIT3akbQ)MM1qLNBQmqQC3BncRU7oqZAipETCauzquzWDQmqQC3BnY2BafFX1ak(eO(BAwdvEUPYtjRJkdIkdIkpZbvEkvcdgvUevARh)urY2BafFX1ak(eCSThHOsyWOYLOs184OKM3UOOgco22Jqujmyu5U3AewD3DGM1qE8A5aOs44Gk39wJS9gqXxCnGIpbQ)MM1qLWGrL7ERr2EdO4lUgqXN841YbqLWHkpLSoQegmQepFpDDris4cU4RHpAqcNFcuNV5cOsoujRkpu5CiHl4IVg(ObjC(jqD(MlqWfNEk3Wf4M841YbqLWHkxhvgevYHk39wJWQ7Ud0Sgs3Lk5qLbsLlrLgtZAiaw9SqcgmK11CoOsou5suPX0SgI7cFT9gqj5iA(8iuPsou5U3AKq00CoeDxs3LkHbJknMM1qaS6zHemyiRR5CqLCOYDV1iHLka6JgxjqLZHk5qLbsL7ERrcrtZ5q0DjqLZHkHbJkT1JFQiz7nGIV4AafFco22JquzqujmyuPTE8tfjBVbu8fxdO4tWX2EeIk5qLQ5XrjnVDrrneCSThHOsouPX0SgI7cFT9gqj5iA(8iuPsou5U3AKq00CoeDxcu5COsou5U3AKWsfa9rJReOY5qLbf57auuTM4Gbf55oYBmnRjY3YhfBVb0OgpzDXLJ84yBpcfxjYZ(uXpTi)U3AewD3DGM1qGkNtK3yAwtK)7dkQMWTCIFuJNe8Ilh5XX2EekUsKVdqHZW0JcMb0CoI8Ch5nMM1e5B5JIT3aAKN9PIFArEB94Nks2EdO4lUgqXNGJT9ievYHkvZJJsAE7IIAi4yBpcrLCOYDV1iBVbu8fxdO4tGkNdvYHkdKkvZJJs((GIQjClN4tWX2EeIk5qLgtZAiFFqr1eULt8jyWqwxZ5Gk5qLgtZAiFFqr1eULt8jyWqwxrXJxlhavchQ8usWJkHbJkdKkzv5HkNdHv3DhOznKhnOfOsyWOYDV1iS6U7anRH0DPYGOsou5suPAECuY3huunHB5eFco22JqujhQCjQ0yAwdXDHV2EdOKCenFEeQujhQCjQ0yAwdPLpUnVNKJO5ZJqLkdkQXtcoIlh5XX2EekUsK3yAwtKNzEVWyAwJWNanY7tGkg7IrEJPj8OqnpokiQXtGRIlh5XX2EekUsKVdqHZW0JcMb0CoI8Ch5zFQ4NwKpqQmqQ0yAwd5IkwpjhrZNhHkvYHknMM1qUOI1tYr085rOkE8A5aOs44GkpLSoQmiQegmQCjQunpok5IkwpbhB7riQmiQKdvgivU7Tg57dkQMWTCIpP7sLWGrLlrLQ5XrjFFqr1eULt8j4yBpcrLbf57auuTM4Gbf55oYBmnRjYZQ7Ud0SMOgp5CfxoYBmnRjY7wAwtKhhB7rO4krnEc3NgxoYBmnRjYV9vbjA9FHipo22JqXvIA8eU5oUCK3yAwtKFJpaFUMZrKhhB7rO4krnEc3WDC5iVX0SMiFlFC7RckYJJT9iuCLOgpHBUiUCK3yAwtK3ggc038cM59rECSThHIRe14jCdxIlh5XX2EekUsK3yAwtKNzEVWyAwJWNanY7tGkg7IrE9ZHROcIA8eUxxC5ipo22JqXvI8Spv8tlYhivgivQMhhL082ffUMYcj4yBpcrLCOsJPj8Oah8MiGkpJkHBQmiQegmQ0yAcpkWbVjcOYZOYGhvgevYHk39wJewQaOpACL8OXuQKdvUevARh)urY2BafFX1ak(eCSThHI8gtZAI8nVDrG(jxXOgpH7GxC5ipo22JqXvI8Spv8tlYV7TgXDHVyEdCjpAmLk5qL7ERry1D3bAwd5XRLdGkpJkzgqfAEXiVX0SMiV7cFT9gqJA8eUdoIlh5XX2EekUsKN9PIFAr(DV1iHLka6JgxjpAmnYBmnRjY7UWxBVb0OgpHB4Q4YrECSThHIRe57au4mm9OGzanNJip3rE2Nk(Pf5raahgsU4T(fevt47Sesa9ODbKRf8xpvYHkdKkzH2FGar7nMM1yEQ8mQKBcxqLWGrL7ERr2EdO4lUgqXN841YbqLWHkpLSoQegmQC3BncRU7oqZAipETCaujCOYDV1iBVbu8fxdO4tG6VPznujmyu5suPTE8tfjBVbu8fxdO4tWX2EeIkdIk5qLbsLbsL7ERry1D3bAwdP7sLCOYaPYDV1iHOP5Ci6UKhnMsLCOYLOsJPzne3f(A7nGsYr085rOsLCOYLOsJPzneaREwibdgY6AohuzqujmyuzGuPX0SgcGvplKGbdzDffpETCaujhQC3BnsiAAohIUlbQCoujhQC3BnsyPcG(OXvcu5COsou5suPX0SgI7cFT9gqj5iA(8iuPYGOYGOYGI8DakQwtCWGI8Ch5nMM1e5B5JIT3aAuJNW95kUCKhhB7rO4kr(oafodtpkygqZ5iYZDKN9PIFAr(LOseaWHHKlERFbr1e(olHeqpAxa5Ab)1tLCOYaPYLOsB94Nks2EdO4lUgqXNGJT9ievcdgvUevQMhhL082ff1qWX2EeIkdIk5qLbsLbsL7ERry1D3bAwdP7sLCOYaPYDV1iHOP5Ci6UKhnMsLCOYLOsJPzne3f(A7nGsYr085rOsLCOYLOsJPzneaREwibdgY6AohuzqujmyuzGuPX0SgcGvplKGbdzDffpETCaujhQC3BnsiAAohIUlbQCoujhQC3BnsyPcG(OXvcu5COsou5suPX0SgI7cFT9gqj5iA(8iuPYGOYGOYGI8DakQwtCWGI8Ch5nMM1e5B5JIT3aAuJNa3NgxoYJJT9iuCLip7tf)0I8UpcV4Gbr4May1ZcPsou5U3AKq00CoeDxs3nYBmnRjY7UWxBVb0OgpbU5oUCK3yAwtK3nSWjdMO5TlcI84yBpcfxjQXtGB4oUCKhhB7rO4krE2Nk(Pf539wJWQ7Ud0SgYJxlhavEgvYmGk08IujhQC3BncRU7oqZAiDxQegmQC3BncRU7oqZAiqLZjYBmnRjYdy1ZcJA8e4MlIlh5XX2EekUsKN9PIFAr(DV1iS6U7anRH841YbqLWHkpyqKRfmQKdvAmnHhf4G3ebu5zuj3rEJPznrEFcFohIDD3rnEcCdxIlh5XX2EekUsKN9PIFAr(DV1iS6U7anRH841YbqLWHkpyqKRfmQKdvU7TgHv3DhOznKUBK3yAwtKh6TJAaI9JMgg14jW96Ilh5XX2EekUsKN9PIFArE1(dujHO51qIltPs44Gk5ItPsouPAECucaTpNdHwDwibhB7rOiVX0SMipGvplmQrnYBmnHhfQ5XrbXLJNWDC5ipo22JqXvI8Spv8tlYBmnHhf4G3ebu5zuj3ujhQC3BncRU7oqZAiqLZHk5qLbsLSQ8qLZHWQ7Ud0SgYJxlhavEgvYQYdvohIpHpNdXUUBcu)nnRHkHbJkzv5HkNdHv3DhOznKhnOfOYGI8gtZAI8(e(Coe76UJA8e4oUCKhhB7rO4krE2Nk(Pf539wJ89bfvt4woXN0DPsouzGuzlFeO2R4tE8A5aOYZOswvEOY5qUOI1tG6VPznujmyu5suzlFeO2R4tmMMWJuzqujmyujRkpu5CiFFqr1eULt8jpETCau5zuPMxuOLakrQKdvAmnRH89bfvt4woXNWcT)abujCOsUPsyWOYaPswvEOY5qUOI1tG6VPznujCOswvEOY5qy1D3bAwd5XRLdGkHbJkzv5HkNdHv3DhOznKhnOfOYGOsou5suPAECuY3huunHB5eFco22JqujhQmqQKvLhQCoKlQy9eO(BAwdvchQSLpcu7v8jpETCaujmyu5suPAECuslFeO2R4tWX2EeIkHbJkxIkB5Ja1EfFIX0eEKkdkYBmnRjYFrfRpQrnYNkEbIW8iu4(z9PUqC54jChxoYJJT9iuCLip7tf)0I8bsLQ5XrjFFqr1eULt8j4yBpcrLCOswvEOY5qy1D3bAwd5XRLdGkHJdQ0yAwd57dkQMWTCIpHzavO5fPsyWOswvEOY5qy1D3bAwd5rdAbQmiQKdvUev2YhbQ9k(eJPj8ivcdgvU7TgHv3DhOznKUBK3yAwtKNzEVWyAwJWNanY7tGkg7Ir(uXlqWQ7Ud0SMOgpbUJlh5nMM1e57auKkEbrECSThHIRe14jCrC5ipo22JqXvI8gtZAI826bH2BarRgvunHB5e)ip7tf)0I8SQ8qLZHWQ7Ud0SgYJxlhavchhu56OYvPsUxhvcxtLWBFABpsA1OcOQV9OOgrhGr(XUyK3wpi0EdiA1OIQjClN4h14jWL4YrECSThHIRe5nMM1e5)szFhOiKa(QGQsavEFKN9PIFArEwvEOY5qy1D3bAwd5XRLdGkpJkH3(02EKuJOdqbRRvRf5h7Ir(Vu23bkcjGVkOQeqL3h14jRlUCKhhB7rO4krEJPznrE7890TuCuXyDn9DqKN9PIFArEwvEOY5qy1D3bAwd5XRLdGkpJkH3(02EKuJOdqbRRvRf5h7IrE7890TuCuXyDn9DquJNe8Ilh5XX2EekUsK3yAwtKheMWJVaECQR4rFYI8Spv8tlYZQYdvohcRU7oqZAipETCau5zuj82N22JKAeDakyDTATi)yxmYdct4Xxapo1v8OpzrnEsWrC5ipo22JqXvI8gtZAI8H2FRjzci8Ak(P5Z1JFKhBnKPIXUyKp0(BnjtaHxtXpnFUE8JA8e4Q4YrECSThHIRe5nMM1e5VMVv)fHeH4BEiGWJhoFZfe5zFQ4NwKNvLhQCoewD3DGM1qE8A5aOYZCqLRBDujhQC3BncRU7oqZAiqLZHk5qLSQ8qLZHWQ7Ud0SgYJxlhavEgvcV9PT9iPgrhGcwxRwlYp2fJ8xZ3Q)IqIq8npeq4XdNV5cIA8KZvC5ipo22JqXvI8gtZAI82WsCubxNsfvt4mbq1nYZ(uXpTipRkpu5CiS6U7anRH841YbqLN5Gkx36Osou5U3AewD3DGM1qGkNdvYHkzv5HkNdHv3DhOznKhVwoaQ8mQeE7tB7rsnIoafSUwTwKFSlg5THL4OcUoLkQMWzcGQBuJNW9PXLJ84yBpcfxjYBmnRjY3bOiv8g5zFQ4NwKNvLhQCoewD3DGM1qE8A5aOYZCqLWL1rLCOYDV1iS6U7anRHavohQKdvYQYdvohcRU7oqZAipETCau5zuj82N22JKAeDakyDTATi)yxmYpy)nVaSWyUauGtOnm8JAuJ8qyZ6EnUC8eUJlh5nMM1e5zvFu8bUO3h5XX2EekUsuJNa3XLJ84yBpcfxjYBmnRjYZmVxymnRr4tGg59jqfJDXiFQ4ficZJqH7N1N6crnEcxexoYJJT9iuCLip7tf)0I87ERry1D3bAwdbQCorEJPznr(B(F9I8AhyuJNaxIlh5XX2EekUsKN9PIFArEwvEOY5qy1D3bAwd5XRLdGkHdvY9PujmyuPMxuOLakrQeoujRkpu5CiS6U7anRH841Ybe5nMM1e5p62dL2iQMWwp(Lgg14jRlUCK3yAwtKNvddh9nfHenVDXipo22JqXvIA8KGxC5iVX0SMiFRyDacjS1JFQOyJ2nYJJT9iuCLOgpj4iUCK3yAwtK3T)zBHCoeBVb0ipo22JqXvIA8e4Q4YrEJPznr(pDD9OihbW1yyKhhB7rO4krnEY5kUCK3yAwtKxdrrF2vFGeT6zyKhhB7rO4krnEc3NgxoYBmnRjY7SEpe8yoIhb1yddJ84yBpcfxjQXt4M74YrECSThHIRe5zFQ4NwKxnpokPLpcu7v8j4yBpcrLCOYw(iqTxXN841YbqLNrLTU3lEKfA)bk08IujmyujRkpu5CiS6U7anRH841YbqLNrLWBFABpsy1D3bAwJ4lxbRRvRrLCOYDV1iS6U7anRHavohQegmQuZlk0saLivchQKvLhQCoewD3DGM1qE8A5aOsou5U3AewD3DGM1qGkNtK3yAwtK)7dkQMWTCIFuJNWnChxoYJJT9iuCLip7tf)0I8bsLQ5XrjFFqr1eULt8j4yBpcrLCOswvEOY5qy1D3bAwd5XRLdGkHJdQ0yAwd57dkQMWTCIpHzavO5fPsyWOswvEOY5qy1D3bAwd5rdAbQmiQKdvUev2YhbQ9k(eJPj8ivcdgvU7TgHv3DhOznKUBK3yAwtKNzEVWyAwJWNanY7tGkg7IrEwD3DGM1iCdnag14jCZfXLJ84yBpcfxjY3bOWzy6rbZaAohrEUJ8Spv8tlYhivIaaomKCXB9liQMW3zjKa6r7cixl4VEQegmQebaCyi5I36xqunHVZsib0J2fqU5upvYHkT1JFQiz7nGIV4AafFco22JquzqujhQKfA)bcOshu51cMGfA)bcOsou5su5U3AKWsfa9rJRKhnMsLCOYLOYaPYDV1iHOP5Ci6UKhnMsLCOYaPYDV1iS6U7anRH0DPsouzGuPX0SgslFCBEpjhrZNhHkvcdgvAmnRH4UWxBVbusoIMppcvQegmQ0yAwdbWQNfsWGHSUMZbvgevcdgvQ2FGkjenVgsCzkvchhujxCkvYHknMM1qaS6zHemyiRR5CqLbrLbrLCOYLOYaPYLOYDV1iHOP5Ci6UKhnMsLCOYLOYDV1iHLka6JgxjpAmLk5qL7ERry1D3bAwdbQCoujhQmqQ0yAwdPLpUnVNKJO5ZJqLkHbJknMM1qCx4RT3akjhrZNhHkvgevguKVdqr1AIdguKN7iVX0SMiFlFuS9gqJA8eUHlXLJ84yBpcfxjY3bOWzy6rbZaAohrEUJ8Spv8tlY3YhbQ9k(eJPj8ivYHkzH2FGaQ8mhuj3ujhQmqQCjQeE7tB7rslFuS9gqfUv5Z5GkHbJk39wJ89bfvt4woXN0DPYGOsouzGu5suPTE8tfjBVbu8fxdO4tWX2EeIkHbJk39wJS9gqXxCnGIp5XRLdGkHdvEkzDuzqujhQmqQCjQ0yAwdPLpUnVNGbdzDnNdQKdvUevAmnRH4UWxBVbusoIMppcvQKdvU7TgjennNdr3L0DPsyWOsJPznKw(428EcgmK11CoOsou5U3AKWsfa9rJReOY5qLWGrLgtZAiUl812BaLKJO5ZJqLk5qL7ERrcrtZ5q0DjqLZHk5qL7ERrclva0hnUsGkNdvguKVdqr1AIdguKN7iVX0SMiFlFuS9gqJA8eUxxC5ipo22JqXvI8Spv8tlYV7Tg57dkQMWTCIpP7sLCOYDV1iS6U7anRHavoNiVX0SMipZ8EHX0SgHpbAK3Navm2fJ8F5kCdnag14jCh8Ilh5XX2EekUsKVCJ8auJ8gtZAI8WBFABpg5H38DmYRMhhL89bfvt4woXNGJT9ievYHkzv5HkNd57dkQMWTCIp5XRLdGkHdvYQYdvohslFuS9gqjTU3lEKfA)bk08IujhQmqQKvLhQCoewD3DGM1qE8A5aOYZOs4TpTThjS6U7anRr8LRG11Q1OsyWOYw(iqTxXNymnHhPYGOsouzGujRkpu5CiFFqr1eULt8jpETCaujCOsnVOqlbuIujmyuPX0SgY3huunHB5eFcl0(deqLNrLNsLbrLWGrLSQ8qLZHWQ7Ud0SgYJxlhavchQ0yAwdPLpk2EdOKw37fpYcT)afAErQCvQKvLhQCoKw(Oy7nGsG6VPznujCnvARh)urY2BafFX1ak(eCSThHOsou5suzlFeO2R4tmMMWJujhQKvLhQCoewD3DGM1qE8A5aOs4qLAErHwcOePsyWOs184OKw(iqTxXNGJT9ievYHkB5Ja1EfFIX0eEKk5qLT8rGAVIp5XRLdGkHdvYQYdvohslFuS9gqjTU3lEKfA)bk08Iu5QujRkpu5CiT8rX2BaLa1FtZAOs4AQ0wp(PIKT3ak(IRbu8j4yBpcf5H3EXyxmY3YhfBVbuHBv(CoIA8eUdoIlh5XX2EekUsKVCJ8auJ8gtZAI8WBFABpg5H38DmYRMhhL89bfvt4woXNGJT9ievYHkzv5HkNd57dkQMWTCIp5XRLdGkHdvYQYdvohIByHtgmrZBxeqADVx8il0(duO5fPsoujRkpu5CiS6U7anRH841YbqLNrLWBFABpsy1D3bAwJ4lxbRRvRrLCOYaPswvEOY5q((GIQjClN4tE8A5aOs4qLAErHwcOePsyWOsJPznKVpOOAc3Yj(ewO9hiGkpJkpLkdIkHbJkzv5HkNdHv3DhOznKhVwoaQeouPX0SgIByHtgmrZBxeqADVx8il0(duO5fPsoujRkpu5CiS6U7anRH841YbqLWHk18IcTeqjg5H3EXyxmY7gw4Kbt4wLpNJOgpHB4Q4YrECSThHIRe5nMM1e5zM3lmMM1i8jqJ8(eOIXUyKhO2azpK4l10SMOg1iFQ4fiy1D3bAwtC54jChxoYJJT9iuCLi)yxmYNhtQznIRDGarRdWiVX0SMiFEmPM1iU2bceToaJA8e4oUCKhhB7rO4krEJPznr(WfCXxdF0Geo)eOoFZfe5zFQ4NwKF3BncRU7oqZAiDxQKdvAmnRH0YhfBVbucl0(deqLoOYtPsouPX0SgslFuS9gqjpYcT)afAErQ8mQ8GbrE8A5aI8JDXiF4cU4RHpAqcNFcuNV5cIA8eUiUCKhhB7rO4kr(XUyK3wF)rnSacqohiKW13V2bg57auuTM4Gbf55oYBmnRjYBRV)OgwabiNdes467x7aJ8Spv8tlYV7TgHv3DhOznKUlvcdgvAmnRHCrfRNKJO5ZJqLk5qLgtZAixuX6j5iA(8iufpETCaujCCqLNswxuJNaxIlh5XX2EekUsK3yAwtK)WBqPP1deBd6aJ8DakQwtCWGI8Ch5zFQ4NwKF3BncRU7oqZAiDxQegmQ0yAwd5IkwpjhrZNhHkvYHknMM1qUOI1tYr085rOkE8A5aOs44GkpLSUip2AitfJDXi)H3GstRhi2g0bg14jRlUCKhhB7rO4krEJPznr(dVbLMwpqCriZ7ZAI8DakQwtCWGI8Ch5zFQ4NwKF3BncRU7oqZAiDxQegmQ0yAwd5IkwpjhrZNhHkvYHknMM1qUOI1tYr085rOkE8A5aOs44GkpLSUip2AitfJDXi)H3GstRhiUiK59znrnEsWlUCKhhB7rO4kr(XUyKFBESLpk2VnSWiFhGIQ1ehmOip3rEJPznr(T5Xw(Oy)2WcJ8Spv8tlYV7TgHv3DhOznKUlvcdgvAmnRHCrfRNKJO5ZJqLk5qLgtZAixuX6j5iA(8iufpETCaujCCqLNswxuJNeCexoYJJT9iuCLi)yxmYdclgx3PIpq0S5iY3bOOAnXbdkYZDK3yAwtKhewmUUtfFGOzZrKN9PIFAr(DV1iS6U7anRH0DPsyWOsJPznKlQy9KCenFEeQujhQ0yAwd5IkwpjhrZNhHQ4XRLdGkHJdQ8uY6IA8e4Q4YrECSThHIRe5h7IrED92GaX2EUcCZbbr(oafvRjoyqrEUJ8gtZAI866TbbIT9Cf4MdcI8Spv8tlYV7TgHv3DhOznKUlvcdgvAmnRHCrfRNKJO5ZJqLk5qLgtZAixuX6j5iA(8iufpETCaujCCqLNswxuJNCUIlh5XX2EekUsKFSlg5THL4OcUoLkQMWzcGQBKVdqr1AIdguKN7iVX0SMiVnSehvW1Pur1eotauDJ8Spv8tlYV7TgHv3DhOznKUlvcdgvAmnRHCrfRNKJO5ZJqLk5qLgtZAixuX6j5iA(8iufpETCaujCCqLNswxuJNW9PXLJ84yBpcfxjYp2fJ8d2FZlalmMlaf4eAdd)iFhGIQ1ehmOip3rEJPznr(oafPI3ip7tf)0I87ERry1D3bAwdP7sLWGrLgtZAixuX6j5iA(8iuPsouPX0SgYfvSEsoIMppcvXJxlhavchhu5PK1f14jCZDC5ipo22JqXvI8JDXi)18T6ViKieFZdbeE8W5BUGiFhGIQ1ehmOip3rEJPznr(R5B1Friri(Mhci84HZ3CbrE2Nk(Pf539wJWQ7Ud0Sgs3LkHbJknMM1qUOI1tYr085rOsLCOsJPznKlQy9KCenFEeQIhVwoaQeooOYtjRlQrnY)LRWn0ayC54jChxoYBmnRjY)9bfvt4woXpYJJT9iuCLOgpbUJlh5XX2EekUsKN9PIFAr(aPYaPs184OKM3UOW1uwibhB7riQKdvAmnHhf4G3ebu5zuj3uzqujmyuPX0eEuGdEteqLNrLWfQmiQKdvU7TgjSubqF04k5rJPrEJPznr(M3Uiq)KRyuJNWfXLJ84yBpcfxjYZ(uXpTi)U3AKWsfa9rJRKhnMg5nMM1e5Dx4RT3aAuJNaxIlh5XX2EekUsKVdqHZW0JcMb0CoI8Ch5zFQ4NwKpqQCjQSLpcu7v8jgtt4rQKdvYQYdvohcRU7oqZAipETCau5zu5PuzqujhQmqQCjQC3BnsiAAohIUl5rJPujhQCjQC3BnsyPcG(OXvYJgtPsou5suP7JWlQwtCWGiT8rX2BaLk5qLbsLgtZAiT8rX2BaLWcT)abu5zoOs4MkHbJkdKknMM1qCdlCYGjAE7Iacl0(deqLN5Gk5Mk5qLQ5XrjUHfozWenVDrabhB7riQmiQegmQmqQunpokX8yWa6BG1BarR)lqWX2EeIk5qLSQ8qLZHa92rnaX(rtdjpAqlqLbrLWGrLbsLQ5Xrja0(CoeA1zHeCSThHOsouPA)bQKq08AiXLPujCCqLCXPuzquzquzqr(oafvRjoyqrEUJ8gtZAI8T8rX2BanQXtwxC5ipo22JqXvI8gtZAI8mZ7fgtZAe(eOrEFcuXyxmYBmnHhfQ5XrbrnEsWlUCKhhB7rO4krE2Nk(Pf539wJ4UWxmVbUKhnMsLCOsMbuHMxKkHdvU7TgXDHVyEdCjpETCaujhQC3BnY3huunHB5eFYJxlhavEgvYmGk08IrEJPznrE3f(A7nGg14jbhXLJ84yBpcfxjY3bOWzy6rbZaAohrEUJ8Spv8tlYhivUev2YhbQ9k(eJPj8ivYHkzv5HkNdHv3DhOznKhVwoaQ8mQ8uQmiQKdvgivU7TgjennNdr3L8OXuQKdvgivQ2FGkjenVgsCzkvEMdQKloLkHbJkxIkvZJJsaO95Ci0QZcj4yBpcrLbrLbf57auuTM4Gbf55oYBmnRjY3YhfBVb0OgpbUkUCKhhB7rO4kr(oafodtpkygqZ5iYZDKN9PIFAr(aPYLOYw(iqTxXNymnHhPsoujRkpu5CiS6U7anRH841YbqLNrLNsLbrLCOs184OeaAFohcT6Sqco22JqujhQuT)avsiAEnK4YuQeooOsU4uQKdvgivU7TgjennNdr3L8OXuQKdvUevAmnRHay1ZcjyWqwxZ5GkHbJkxIk39wJeIMMZHO7sE0ykvYHkxIk39wJewQaOpACL8OXuQmOiFhGIQ1ehmOip3rEJPznr(w(Oy7nGg14jNR4YrECSThHIRe5zFQ4NwK39r4fhmic3eaREwivYHk39wJeIMMZHO7s6UujhQunpokbG2NZHqRolKGJT9ievYHkv7pqLeIMxdjUmLkHJdQKloLk5qLbsLlrLQ5XrjnVDrHRPSqco22JqujmyuPX0eEuGdEteqLoOsUPYGI8gtZAI8Ul812BanQXt4(04YrECSThHIRe5zFQ4NwKFjQ09r4fhmic3e3WcNmyIM3UiGk5qL7ERrcrtZ5q0DjpAmnYBmnRjY7gw4Kbt082fbrnEc3ChxoYJJT9iuCLip7tf)0I8Q9hOscrZRHexMsLWXbvYfNsLCOs184OeaAFohcT6Sqco22JqrEJPznrEaREwyuJNWnChxoYJJT9iuCLip7tf)0I8gtt4rbo4nravEgvc3rEJPznrEO3oQbi2pAAyuJNWnxexoYJJT9iuCLip7tf)0I8bsLQ5XrjnVDrHRPSqco22JqujhQ0yAcpkWbVjcOYZOs4MkdIkHbJknMMWJcCWBIaQ8mQCDrEJPznr(M3Uiq)KRyuJNWnCjUCK3yAwtKVLpUnVpYJJT9iuCLOg1iV(5WvubXLJNWDC5iVX0SMiFhGIuXliYJJT9iuCLOgpbUJlh5XX2EekUsKFSlg5dT)wtYeq41u8tZNRh)iVX0SMiFO93AsMacVMIFA(C94h1Og5bQnq2dj(snnRjUC8eUJlh5XX2EekUsKN9PIFAr(aPYaPs184OKM3UOW1uwibhB7riQKdvAmnHhf4G3ebu5zuj3ujhQCjQSLpcu7v8jgtt4rQmiQegmQ0yAcpkWbVjcOYZOs4cvgevYHk39wJewQaOpACL8OX0iVX0SMiFZBxeOFYvmQXtG74YrECSThHIRe5zFQ4NwKF3BnsyPcG(OXvYJgtPsou5U3AKWsfa9rJRKhVwoaQeouPX0SgslFCBEpbdgY6kk08IrEJPznrE3f(A7nGg14jCrC5ipo22JqXvI8Spv8tlYV7TgjSubqF04k5rJPujhQmqQ09r4fhmic3Kw(428EQegmQSLpcu7v8jgtt4rQegmQ0yAwdXDHV2EdOKCenFEeQuzqrEJPznrE3f(A7nGg14jWL4YrECSThHIRe5zFQ4NwKNfA)bcOYZCqLCbvYHknMMWJcCWBIaQ8mQeUPsou5suj82N22Je3WcNmyc3Q85Ce5nMM1e5DdlCYGjAE7IGOgpzDXLJ84yBpcfxjYZ(uXpTi)U3AKWsfa9rJRKhnMsLCOs1(dujHO51qIltPs44Gk5ItPsouPAECucaTpNdHwDwibhB7rOiVX0SMiV7cFT9gqJA8KGxC5ipo22JqXvI8Spv8tlYV7TgXDHVyEdCjpAmLk5qLmdOcnVivchQC3BnI7cFX8g4sE8A5aI8gtZAI8Ul812BanQXtcoIlh5XX2EekUsKVdqHZW0JcMb0CoI8Ch5zFQ4NwKpqQKvLhQCoewD3DGM1qE8A5aOYZOYtPsou5U3AKVpOOAc3Yj(eOY5qLCOYLOYw(iqTxXNymnHhPYGOsou5suPAECucxZbYNZbbhB7riQKdvUevcV9PT9iPLpk2EdOc3Q85CqLCOYaPYaPYaPsJPznKw(428EcgmK11CoOsyWOsJPzne3f(A7nGsWGHSUMZbvgevYHkdKk39wJeIMMZHO7sE0ykvgevgevcdgvgivQMhhLaq7Z5qOvNfsWX2EeIk5qLQ9hOscrZRHexMsLWXbvYfNsLCOYaPYDV1iHOP5Ci6UKhnMsLCOYLOsJPzneaREwibdgY6Aohujmyu5su5U3AKWsfa9rJRKhnMsLCOYLOYDV1iHOP5Ci6UKhnMsLCOsJPzneaREwibdgY6AohujhQCjQ0yAwdXDHV2EdOKCenFEeQujhQCjQ0yAwdPLpUnVNKJO5ZJqLkdIkdIkdkY3bOOAnXbdkYZDK3yAwtKVLpk2EdOrnEcCvC5ipo22JqXvI8Spv8tlYRMhhLW1CG85CqWX2EeIk5qL7ERrcrtZ5q0DjpAmLk5qLlrLT8rGAVIpXyAcpsLCOYaPswvEOY5qy1D3bAwd5XRLdGkpJkBDVx8il0(duO5fPYvPs4MkxLkvZJJs4Aoq(Coi4yBpcrLWGrLbsLlrLQ5XrjFFqr1eULt8j4yBpcrLWGrLSQ8qLZH89bfvt4woXN841YbqLNrLAErHwcOePsouPX0SgY3huunHB5eFcl0(deqLWHk5MkdIk5qLSQ8qLZHWQ7Ud0SgYJxlhavEgvQ5ffAjGsKkdkYBmnRjY3YhfBVb0Ogp5CfxoYJJT9iuCLip7tf)0I8UpcV4Gbr4May1ZcPsou5U3AKq00CoeDxs3Lk5qLQ5Xrja0(CoeA1zHeCSThHOsouPA)bQKq08AiXLPujCCqLCXPujhQmqQmqQunpokP5TlkCnLfsWX2EeIk5qLgtt4rbo4nrav6Gk5Mk5qLlrLT8rGAVIpXyAcpsLbrLWGrLbsLgtt4rbo4nravchQeUqLCOYLOs184OKM3UOW1uwibhB7riQmiQmOiVX0SMiV7cFT9gqJA8eUpnUCKhhB7rO4krE2Nk(Pf5dKk39wJeIMMZHO7sE0ykvcdgvgivUevU7TgjSubqF04k5rJPujhQmqQ0yAwdPLpk2EdOewO9hiGkpJkpLkHbJkvZJJsaO95Ci0QZcj4yBpcrLCOs1(dujHO51qIltPs44Gk5ItPYGOYGOYGOsou5suj82N22Je3WcNmyc3Q85Ce5nMM1e5DdlCYGjAE7IGOgpHBUJlh5XX2EekUsK3yAwtKNzEVWyAwJWNanY7tGkg7IrEJPj8OqnpokiQXt4gUJlh5XX2EekUsKN9PIFArEJPj8Oah8MiGkpJk5oYBmnRjYd92rnaX(rtdJA8eU5I4YrECSThHIRe5nMM1e5zM3lmMM1i8jqJ8(eOIXUyKpv8ce(YPW9Z6tDHOgpHB4sC5ipo22JqXvI8Spv8tlYR2FGkjenVgsCzkvchhujxCkvYHkvZJJsaO95Ci0QZcj4yBpcf5nMM1e5bS6zHrnEc3RlUCK3yAwtKVLpUnVpYJJT9iuCLOgpH7GxC5iVX0SMipGvplmYJJT9iuCLOg1iV7JS6UnnUC8eUJlh5nMM1e5TNzdkYrrVhzAKhhB7rO4krnEcChxoYJJT9iuCLiF5g5bOg5nMM1e5H3(02EmYdV57yKp4DAKhE7fJDXipRU7oqZAeF5kyDTATOgpHlIlh5XX2EekUsKVCJ8auJ8gtZAI8WBFABpg5H38DmYJNVNUUiezkT(S6aHbCZ3gfi2g0bsLWGrL457PRlcrMsRpRoqC4nO006bITbDGujmyujE(E66IqeqojqXxC4nO006bITbDGujmyujE(E66IqeqojqXxya38TrbITbDGujmyujE(E66IqeOhniXH3GstRhi2g0bsLWGrL457PRlcrGE0GegWnFBuGyBqhivcdgvINVNUUieb6rdsWQ72uBuGihqEmPrLWGrL457PRlcrMsRpRoqya38TrbIlczEFwdvcdgvINVNUUiezkT(S6aXH3GstRhiUiK59znujmyujE(E66IqeqojqXxC4nO006bIlczEFwdvcdgvINVNUUiebKtcu8fgWnFBuG4IqM3N1qLWGrL457PRlcrGE0GehEdknTEG4IqM3N1qLWGrL457PRlcrGE0GegWnFBuG4IqM3N1qLWGrL457PRlcrGE0GeS6Un1gfiUiK59znujmyujE(E66IqK8ysnRrCTdeiADasLWGrL457PRlcr01BdceB75kWnheqLWGrL457PRlcrS13FudlGaKZbcjC99RDGujmyujE(E66IqeByjoQGRtPIQjCMaO6sLWGrL457PRlcraHfJR7uXhiA2CqLWGrL457PRlcrgS)MxawymxakWj0gg(ujmyujE(E66IqKT5Xw(Oy)2WcJ8WBVySlg5z1D3bAwJOgrhGrnEcCjUCKhhB7rO4kr(YnYdqnYBmnRjYdV9PT9yKhEZ3XipE(E66IqeB9Gq7nGOvJkQMWTCIpvYHkH3(02EKWQ7Ud0SgrnIoaJ8WBVySlg5B1OcOQV9OOgrhGrnEY6Ilh5XX2EekUsKVCJ8auJ8gtZAI8WBFABpg5H38DmYd3NsLW1uj82N22JewD3DGM1iQr0bivYHkxIkH3(02EK0QrfqvF7rrnIoaPYvPs4YPujCnvcV9PT9iPvJkGQ(2JIAeDasLRsLW96Os4AQepFpDDriITEqO9gq0Qrfvt4woXNk5qLlrLWBFABpsA1OcOQV9OOgrhGrE4Txm2fJ81i6auW6A1ArnEsWlUCKhhB7rO4krnEsWrC5ipo22JqXvI8JDXiVTEqO9gq0Qrfvt4woXpYBmnRjYBRheAVbeTAur1eULt8JA8e4Q4YrEJPznr(B(F9I8AhyKhhB7rO4krnEY5kUCK3yAwtK3T0SMipo22JqXvIA8eUpnUCK3yAwtK3DHV2EdOrECSThHIRe1Og1ip84dYAINa3NY956u4Qt5IiVt7NCoar(Z5x36veIk5(uQ0yAwdv6tGci0fJ8UF1spg55Yu55iFKkdUSdKUixMkdv1fCoT2AhPg23ewDxdK3U30Sg2BnDnqEzRrxKltLbF6hDGsLCFAaujCFk3NlQ8CtLCF650PCtxKUixMk5scT5abNt0f5Yu55Mk5sbqQuZlk0saLiv(MgIpvQH2qLQ9hOs08IcTeqjsLT6PsVb0Znaz1arL2o9PUav2b2bci0fPlYLPsU0dgY6kcrLBSvpsLS6UnLk34roacvg8HXqxfqLtnN7q7VTUNknMM1aOYA8lqOlYLPsJPznaI7JS6Un1rZBaUsxKltLgtZAae3hz1DB6QowRvfeDrUmvAmnRbqCFKv3TPR6ynRFCXrnnRHUOX0SgaX9rwD3MUQJ1SNzdkYrrVhzkDrUmvUCycOs4TpTThPsaQaQudrQuZlsLMsLodtwivYLwFqQSAuzW3Yj(ujiS6EiQeO2Ru5gZ5Gkbg8iev2QNk1qKkhmykvYLu3DhOznuPBObq6IgtZAae3hz1DB6QowdE7tB7Xag7Ioy1D3bAwJ4lxbRRvRfq56aGAaWB(o6i4DkDrJPznaI7JS6UnDvhRbV9PT9yaJDrhS6U7anRruJOdWakxhaudaEZ3rh457PRlcrMsRpRoqya38TrbITbDGWGHNVNUUiezkT(S6aXH3GstRhi2g0bcdgE(E66IqeqojqXxC4nO006bITbDGWGHNVNUUiebKtcu8fgWnFBuGyBqhimy457PRlcrGE0GehEdknTEGyBqhimy457PRlcrGE0GegWnFBuGyBqhimy457PRlcrGE0GeS6Un1gfiYbKhtAWGHNVNUUiezkT(S6aHbCZ3gfiUiK59znWGHNVNUUiezkT(S6aXH3GstRhiUiK59znWGHNVNUUiebKtcu8fhEdknTEG4IqM3N1adgE(E66IqeqojqXxya38TrbIlczEFwdmy457PRlcrGE0GehEdknTEG4IqM3N1adgE(E66IqeOhniHbCZ3gfiUiK59znWGHNVNUUieb6rdsWQ72uBuG4IqM3N1adgE(E66IqK8ysnRrCTdeiADacdgE(E66IqeD92GaX2EUcCZbbWGHNVNUUieXwF)rnSacqohiKW13V2bcdgE(E66IqeByjoQGRtPIQjCMaO6cdgE(E66IqeqyX46ov8bIMnhWGHNVNUUiezW(BEbyHXCbOaNqBy4ddgE(E66IqKT5Xw(Oy)2WcPlAmnRbqCFKv3TPR6yn4TpTThdySl6OvJkGQ(2JIAeDagq56aGAaWB(o6apFpDDriITEqO9gq0Qrfvt4woXNd82N22JewD3DGM1iQr0biDrUmvEoxXlGk1qtPs7rQSdqiQS6kiHqQSAujxsD3DGM1qL2Ju5ukv2bievAnfFQudtavQ5fPYSrLAiUav6S6EiQ0TRuPrL6NdxrLk7aeIkDMAivYLu3DhOznuznuPrLGq7HqiQKvLhQCoe6IgtZAae3hz1DB6QowdE7tB7Xag7IoQr0bOG11Q1cOCDaqna4nFhDa3NcxdV9PT9iHv3DhOznIAeDaYzj4TpTThjTAubu13EuuJOdWvHlNcxdV9PT9iPvJkGQ(2JIAeDaUkCVo4A88901fHi26bH2BarRgvunHB5eFolbV9PT9iPvJkGQ(2JIAeDasx0yAwdG4(iRUBtx1XAGXCbHLkaQPa6IgtZAae3hz1DB6QowRdqrQ4nGXUOdB9Gq7nGOvJkQMWTCIpDrJPznaI7JS6UnDvhRDZ)RxKx7aPlAmnRbqCFKv3TPR6yn3sZAOlAmnRbqCFKv3TPR6yn3f(A7nGsxKUixMk5spyiRRievIWJ)cuPMxKk1qKknMwpvMaQ0G3sVT9iHUOX0SgGdw1hfFGl690fnMM1aw1XAmZ7fgtZAe(eObm2fDKkEbIW8iu4(z9PUaDrJPznGvDS2n)VErETdmGS5y3BncRU7oqZAiqLZHUOX0SgWQow7OBpuAJOAcB94xAyazZbRkpu5CiS6U7anRH841YbahUpfgmnVOqlbuIWHvLhQCoewD3DGM1qE8A5aOlAmnRbSQJ1y1WWrFtrirZBxKUOX0SgWQowRvSoaHe26XpvuSr7sx0yAwdyvhR52)STqohIT3akDrJPznGvDS2NUUEuKJa4AmKUOX0SgWQowtdrrF2vFGeT6ziDrJPznGvDSMZ69qWJ5iEeuJnmKUOX0SgWQow77dkQMWTCIFazZHAECuslFeO2R4tWX2EeItlFeO2R4tE8A5aoR19EXJSq7pqHMxegmwvEOY5qy1D3bAwd5XRLd4m4TpTThjS6U7anRr8LRG11Q14S7TgHv3DhOzneOY5adMMxuOLakr4WQYdvohcRU7oqZAipETCaC29wJWQ7Ud0Sgcu5COlAmnRbSQJ1yM3lmMM1i8jqdySl6Gv3DhOznc3qdGbKnhbQMhhL89bfvt4woXNGJT9iehwvEOY5qy1D3bAwd5XRLdaoomMM1q((GIQjClN4tygqfAEryWyv5HkNdHv3DhOznKhnOfcIZsT8rGAVIpXyAcpcd2U3AewD3DGM1q6U0fnMM1aw1XAT8rX2BanGoafodtpkygqZ5Wb3b0bOOAnXbdYb3bKnhbIaaomKCXB9liQMW3zjKa6r7cixl4VEyWqaahgsU4T(fevt47Sesa9ODbKBo1ZXwp(PIKT3ak(IRbu8j4yBpcfehwO9hiWX1cMGfA)bc4S0U3AKWsfa9rJRKhnMYzPa39wJeIMMZHO7sE0ykNa39wJWQ7Ud0Sgs3LtGgtZAiT8XT59KCenFEeQWGzmnRH4UWxBVbusoIMppcvyWmMM1qaS6zHemyiRR5CeemyQ9hOscrZRHexMchhCXPCmMM1qaS6zHemyiRR5CeuqCwkWL29wJeIMMZHO7sE0ykNL29wJewQaOpACL8OXuo7ERry1D3bAwdbQCoCc0yAwdPLpUnVNKJO5ZJqfgmJPzne3f(A7nGsYr085rOguq0f5YuzWT9pNdQ8CKpcu7v8dGkph5Ju5kEdOaQ0EKk7aeIkb5n927xGk1IkH6FohujxsD3DGM1qOYZzXbFZ7xiaQudXfOs7rQSdqiQulQ8ah8nfPYGZsPsE9rJRaQ0ziouj7tfqLotVNkNsPYnsLonGIquPnquPZudPYv8gqXNkdUmGIFauPgIlqLGWQ7HOYnsLa3hniQS6kvQfvETCulhQudrQCfVbu8PYGldO4tL7ERrOlAmnRbSQJ1A5JIT3aAaDakCgMEuWmGMZHdUdOdqr1AIdgKdUdiBoA5Ja1EfFIX0eEKdl0(deCMdU5e4sWBFABpsA5JIT3aQWTkFohWGT7Tg57dkQMWTCIpP7geNaxYwp(PIKT3ak(IRbu8j4yBpcbd2U3AKT3ak(IRbu8jpETCaW5uY6cItGlzmnRH0Yh3M3tWGHSUMZbNLmMM1qCx4RT3akjhrZNhHkNDV1iHOP5Ci6UKUlmygtZAiT8XT59emyiRR5CWz3BnsyPcG(OXvcu5CGbZyAwdXDHV2EdOKCenFEeQC29wJeIMMZHO7sGkNdNDV1iHLka6JgxjqLZji6IgtZAaR6ynM59cJPzncFc0ag7Io(Yv4gAamGS5y3BnY3huunHB5eFs3LZU3AewD3DGM1qGkNdDrJPznGvDSg82N22Jbm2fD0YhfBVbuHBv(CocaEZ3rhQ5XrjFFqr1eULt8j4yBpcXHvLhQCoKVpOOAc3Yj(KhVwoa4WQYdvohslFuS9gqjTU3lEKfA)bk08ICcKvLhQCoewD3DGM1qE8A5aodE7tB7rcRU7oqZAeF5kyDTAnyWA5Ja1EfFIX0eEmiobYQYdvohY3huunHB5eFYJxlhaC08IcTeqjcdMX0SgY3huunHB5eFcl0(deC2PbbdgRkpu5CiS6U7anRH841YbahJPznKw(Oy7nGsADVx8il0(duO5fxLvLhQCoKw(Oy7nGsG6VPznW126XpvKS9gqXxCnGIpbhB7riol1YhbQ9k(eJPj8ihwvEOY5qy1D3bAwd5XRLdaoAErHwcOeHbtnpokPLpcu7v8j4yBpcXPLpcu7v8jgtt4roT8rGAVIp5XRLdaoSQ8qLZH0YhfBVbusR79IhzH2FGcnV4QSQ8qLZH0YhfBVbucu)nnRbU2wp(PIKT3ak(IRbu8j4yBpcrx0yAwdyvhRbV9PT9yaJDrhUHfozWeUv5Z5ia4nFhDOMhhL89bfvt4woXNGJT9iehwvEOY5q((GIQjClN4tE8A5aGdRkpu5CiUHfozWenVDraP19EXJSq7pqHMxKdRkpu5CiS6U7anRH841YbCg82N22JewD3DGM1i(YvW6A1ACcKvLhQCoKVpOOAc3Yj(KhVwoa4O5ffAjGsegmJPznKVpOOAc3Yj(ewO9hi4StdcgmwvEOY5qy1D3bAwd5XRLdaogtZAiUHfozWenVDraP19EXJSq7pqHMxKdRkpu5CiS6U7anRH841YbahnVOqlbuI0fnMM1aw1XAmZ7fgtZAe(eObm2fDauBGShs8LAAwdDr6IgtZAaeJPj8OqnpokWHpHpNdXUU7aYMdJPj8Oah8Mi4mU5S7TgHv3DhOzneOY5WjqwvEOY5qy1D3bAwd5XRLd4mwvEOY5q8j85Ci21DtG6VPznWGXQYdvohcRU7oqZAipAqleeDrJPznaIX0eEuOMhhfSQJ1UOI1hq2CS7Tg57dkQMWTCIpP7YjWw(iqTxXN841YbCgRkpu5CixuX6jq930SgyWwQLpcu7v8jgtt4XGGbJvLhQCoKVpOOAc3Yj(KhVwoGZ08IcTeqjYXyAwd57dkQMWTCIpHfA)bcGd3WGfiRkpu5CixuX6jq930Sg4WQYdvohcRU7oqZAipETCaWGXQYdvohcRU7oqZAipAqleeNLuZJJs((GIQjClN4tWX2EeItGSQ8qLZHCrfRNa1FtZAGtlFeO2R4tE8A5aGbBj184OKw(iqTxXNGJT9iemyl1YhbQ9k(eJPj8yq0fPlYLPsUK6U7anRHkDdnasLUp6ApcOsBN(uteqLotnKknQec92cbqLAiouP36dlebuzoArLAisLCj1D3bAwdvcWZ3XHH0fnMM1aiS6U7anRr4gAa0HppcvGi4VdDCXrdiBo29wJWQ7Ud0Sgcu5COlAmnRbqy1D3bAwJWn0a4QowB7RcsunHgIcCW7c0fnMM1aiS6U7anRr4gAaCvhRDXB9liQMW3zjKa6r7cOlYLPYGB7FohujxsD3DGM1eavEoYhPYv8gqbuP9iv2bievQfvEGd(MIuzWzPujV(OXvavAdevEZjV56rQudrQ0UvFuQSAuPMxKkbU4OujgmK11CoOYsdXNkbUO3diu55OEQeO2azpevEoYhdGkph5Ju5kEdOaQ0EKkRXVav2biev6mehQm4ennNdQKlLlvMaQ0yAcpsL1tLodXHknQKNvplKkzgqPYeqL5qLUFD8iaqL2arLbNOP5CqLCPCPsBGOYGZsPsE9rJRuP9ivoLsLgtt4rcvEotQHu5kEdO4tLbxgqXNkTbIkphE7IuzWntau55iFKkxXBafqLmBOsdck1SgZ7xGk3iv2biev6mm9ivgCwkvYRpACLkTbIkdortZ5Gk5s5sL2Ju5ukvAmnHhPsBGOsJkd(UWxBVbuQmbuzouPgIuPLpvAdevAEqrLodtpsLmdO5CqL8S6zHujcpouz2OYGt00CoOsUuUuzcOsZ)ObTavAmnHhju5YHiv6nvXNknVVCcOs1zrLbNLsL86JgxPYGVl812BafqLArLBKkzgqPYCOsqNXqaiRHkTMIpvQHivYZQNfsOYGpqqPM1yE)cuPZudPYv8gqXNkdUmGIpvAdevEo82fPYGBMaOYZr(ivUI3akGkbHv3drLtPu5gPYoaHOY(4raGkxXBafFQm4Yak(uzcOsBxDLk1IkXG5MpsL1tLAi(ivApsL36rQudTHkXP6hHu55iFKkxXBafqLArLyWuCGOYv8gqXNkdUmGIpvQfvQHivIdevwnQKlPU7oqZAi0fnMM1aiS6U7anRr4gAaCvhR1YhfBVb0a6au4mm9OGzanNdhChqhGIQ1ehmihChq2CWcT)abN5GBobgOX0SgslFuS9gqjSq7pqGO9gtZAm)QbU7TgHv3DhOznKhVwoGZ9U3AKT3ak(IRbu8jq930SMGcUZQYdvohslFuS9gqjq930SMZDG7ERry1D3bAwd5XRLdiOG7bU7Tgz7nGIV4AafFcu)nnR5CFkzDbf0zoofgSLS1JFQiz7nGIV4AafFco22JqWGTKAECusZBxuudbhB7riyW29wJWQ7Ud0SgYJxlhaCCS7Tgz7nGIV4AafFcu)nnRbgSDV1iBVbu8fxdO4tE8A5aGZPK1bdgE(E66IqKWfCXxdF0Geo)eOoFZfWHvLhQCoKWfCXxdF0Geo)eOoFZfi4ItpLB4cCtE8A5aGZ6cIZU3AewD3DGM1q6UCcCjJPzneaREwibdgY6AohCwYyAwdXDHV2EdOKCenFEeQC29wJeIMMZHO7s6UWGzmnRHay1ZcjyWqwxZ5GZU3AKWsfa9rJReOY5WjWDV1iHOP5Ci6UeOY5adMTE8tfjBVbu8fxdO4tWX2EekiyWS1JFQiz7nGIV4AafFco22JqCuZJJsAE7IIAi4yBpcXXyAwdXDHV2EdOKCenFEeQC29wJeIMMZHO7sGkNdNDV1iHLka6JgxjqLZji6IgtZAaewD3DGM1iCdnaUQJ1((GIQjClN4hq2CS7TgHv3DhOzneOY5qxKltLNZKAivUI3ak(uzWLbu8dGknQ8CKpsLR4nGsLGWQ7HOYnsLDacrLodtpsLmdO5CqLCP1hKkRgvg8TCIpHUOX0SgaHv3DhOznc3qdGR6yTw(Oy7nGgqhGcNHPhfmdO5C4G7aYMdB94Nks2EdO4lUgqXNGJT9ieh184OKM3UOOgco22JqC29wJS9gqXxCnGIpbQCoCcunpok57dkQMWTCIpbhB7riogtZAiFFqr1eULt8jyWqwxZ5GJX0SgY3huunHB5eFcgmK1vu841YbaNtjbpyWcKvLhQCoewD3DGM1qE0GwagSDV1iS6U7anRH0DdIZsQ5XrjFFqr1eULt8j4yBpcXzjJPzne3f(A7nGsYr085rOYzjJPznKw(428EsoIMppc1GOlAmnRbqy1D3bAwJWn0a4QowJzEVWyAwJWNanGXUOdJPj8OqnpokGUOX0SgaHv3DhOznc3qdGR6ynwD3DGM1eqhGIQ1ehmihChqhGcNHPhfmdO5C4G7aYMJad0yAwd5IkwpjhrZNhHkhJPznKlQy9KCenFEeQIhVwoa444uY6ccgSLuZJJsUOI1tWX2EekiobU7Tg57dkQMWTCIpP7cd2sQ5XrjFFqr1eULt8j4yBpcfeDrJPznacRU7oqZAeUHgax1XAULM1qx0yAwdGWQ7Ud0SgHBObWvDS22xfKO1)fOlAmnRbqy1D3bAwJWn0a4QowBJpaFUMZbDrJPznacRU7oqZAeUHgax1XAT8XTVki6IgtZAaewD3DGM1iCdnaUQJ1SHHa9nVGzEpDrJPznacRU7oqZAeUHgax1XAmZ7fgtZAe(eObm2fDOFoCfvaDrJPznacRU7oqZAeUHgax1XAnVDrG(jxXaYMJadunpokP5TlkCnLfsWX2EeIJX0eEuGdEteCgChemygtt4rbo4nrWzbVG4S7TgjSubqF04k5rJPCwYwp(PIKT3ak(IRbu8j4yBpcrx0yAwdGWQ7Ud0SgHBObWvDSM7cFT9gqdiBo29wJ4UWxmVbUKhnMYz3BncRU7oqZAipETCaNXmGk08I0fnMM1aiS6U7anRr4gAaCvhR5UWxBVb0aYMJDV1iHLka6JgxjpAmLUOX0SgaHv3DhOznc3qdGR6yTw(Oy7nGgqhGIQ1ehmihChqhGcNHPhfmdO5C4G7aYMdeaWHHKlERFbr1e(olHeqpAxa5Ab)1ZjqwO9hiq0EJPznM)mUjCbmy7ERr2EdO4lUgqXN841YbaNtjRdgSDV1iS6U7anRH841YbaNDV1iBVbu8fxdO4tG6VPznWGTKTE8tfjBVbu8fxdO4tWX2Eekiobg4U3AewD3DGM1q6UCcC3BnsiAAohIUl5rJPCwYyAwdXDHV2EdOKCenFEeQCwYyAwdbWQNfsWGHSUMZrqWGfOX0SgcGvplKGbdzDffpETCaC29wJeIMMZHO7sGkNdNDV1iHLka6JgxjqLZHZsgtZAiUl812BaLKJO5ZJqnOGcIUOX0SgaHv3DhOznc3qdGR6yTw(Oy7nGgqhGIQ1ehmihChqhGcNHPhfmdO5C4G7aYMJLqaahgsU4T(fevt47Sesa9ODbKRf8xpNaxYwp(PIKT3ak(IRbu8j4yBpcbd2sQ5XrjnVDrrneCSThHcItGbU7TgHv3DhOznKUlNa39wJeIMMZHO7sE0ykNLmMM1qCx4RT3akjhrZNhHkNLmMM1qaS6zHemyiRR5CeemybAmnRHay1ZcjyWqwxrXJxlhaNDV1iHOP5Ci6UeOY5Wz3BnsyPcG(OXvcu5C4SKX0SgI7cFT9gqj5iA(8iudkOGOlAmnRbqy1D3bAwJWn0a4QowZDHV2EdObKnhUpcV4Gbr4May1Zc5S7TgjennNdr3L0DPlAmnRbqy1D3bAwJWn0a4QowZnSWjdMO5TlcOlAmnRbqy1D3bAwJWn0a4QowdWQNfgq2CS7TgHv3DhOznKhVwoGZygqfAEro7ERry1D3bAwdP7cd2U3AewD3DGM1qGkNdDrJPznacRU7oqZAeUHgax1XA(e(Coe76UdiBo29wJWQ7Ud0SgYJxlhaCoyqKRfmogtt4rbo4nrWzCtx0yAwdGWQ7Ud0SgHBObWvDSg0Bh1ae7hnnmGS5y3BncRU7oqZAipETCaW5GbrUwW4S7TgHv3DhOznKUlDrJPznacRU7oqZAeUHgax1XAaw9SWaYMd1(dujHO51qIltHJdU4uoQ5Xrja0(CoeA1zHeCSThHOlsx0yAwdGKkEbcwD3DGM14OdqrQ4nGXUOJ8ysnRrCTdeiADasx0yAwdGKkEbcwD3DGM1SQJ16auKkEdySl6iCbx81WhniHZpbQZ3CbbKnh7ERry1D3bAwdP7YXyAwdPLpk2EdOewO9hiWXPCmMM1qA5JIT3ak5rwO9hOqZlE2bdI841Ybqx0yAwdGKkEbcwD3DGM1SQJ16auKkEdOdqr1AIdgKdUdySl6WwF)rnSacqohiKW13V2bgq2CS7TgHv3DhOznKUlmygtZAixuX6j5iA(8iu5ymnRHCrfRNKJO5ZJqv841YbahhNswhDrJPznasQ4fiy1D3bAwZQowRdqrQ4nGoafvRjoyqo4oaS1qMkg7Ioo8guAA9aX2GoWaYMJDV1iS6U7anRH0DHbZyAwd5IkwpjhrZNhHkhJPznKlQy9KCenFEeQIhVwoa444uY6OlAmnRbqsfVabRU7oqZAw1XADaksfVb0bOOAnXbdYb3bGTgYuXyx0XH3GstRhiUiK59znbKnh7ERry1D3bAwdP7cdMX0SgYfvSEsoIMppcvogtZAixuX6j5iA(8iufpETCaWXXPK1rx0yAwdGKkEbcwD3DGM1SQJ16auKkEdOdqr1AIdgKdUdySl6yBESLpk2VnSWaYMJDV1iS6U7anRH0DHbZyAwd5IkwpjhrZNhHkhJPznKlQy9KCenFEeQIhVwoa444uY6OlAmnRbqsfVabRU7oqZAw1XADaksfVb0bOOAnXbdYb3bm2fDaclgx3PIpq0S5iGS5y3BncRU7oqZAiDxyWmMM1qUOI1tYr085rOYXyAwd5IkwpjhrZNhHQ4XRLdaoooLSo6IgtZAaKuXlqWQ7Ud0SMvDSwhGIuXBaDakQwtCWGCWDaJDrh66TbbIT9Cf4MdcciBo29wJWQ7Ud0Sgs3fgmJPznKlQy9KCenFEeQCmMM1qUOI1tYr085rOkE8A5aGJJtjRJUOX0Sgajv8ceS6U7anRzvhR1bOiv8gqhGIQ1ehmihChWyx0HnSehvW1Pur1eotauDdiBo29wJWQ7Ud0Sgs3fgmJPznKlQy9KCenFEeQCmMM1qUOI1tYr085rOkE8A5aGJJtjRJUOX0Sgajv8ceS6U7anRzvhR1bOiv8gqhGIQ1ehmihChWyx0XG938cWcJ5cqboH2WWpGS5y3BncRU7oqZAiDxyWmMM1qUOI1tYr085rOYXyAwd5IkwpjhrZNhHQ4XRLdaoooLSo6IgtZAaKuXlqWQ7Ud0SMvDSwhGIuXBaDakQwtCWGCWDaJDrhxZ3Q)IqIq8npeq4XdNV5cciBo29wJWQ7Ud0Sgs3fgmJPznKlQy9KCenFEeQCmMM1qUOI1tYr085rOkE8A5aGJJtjRJUiDrJPznasQ4ficZJqH7N1N6coyM3lmMM1i8jqdySl6iv8ceS6U7anRjGS5iq184OKVpOOAc3Yj(eCSThH4WQYdvohcRU7oqZAipETCaWXHX0SgY3huunHB5eFcZaQqZlcdgRkpu5CiS6U7anRH8ObTqqCwQLpcu7v8jgtt4ryW29wJWQ7Ud0Sgs3LUOX0Sgajv8ceH5rOW9Z6tDHvDSwhGIuXlGUOX0Sgajv8ceH5rOW9Z6tDHvDSwhGIuXBaJDrh26bH2BarRgvunHB5e)aYMdwvEOY5qy1D3bAwd5XRLdaoow3QCVo4A4TpTThjTAubu13EuuJOdq6IgtZAaKuXlqeMhHc3pRp1fw1XADaksfVbm2fD8LY(oqrib8vbvLaQ8(aYMdwvEOY5qy1D3bAwd5XRLd4m4TpTThj1i6auW6A1A0fnMM1aiPIxGimpcfUFwFQlSQJ16auKkEdySl6WoFpDlfhvmwxtFheq2CWQYdvohcRU7oqZAipETCaNbV9PT9iPgrhGcwxRwJUOX0Sgajv8ceH5rOW9Z6tDHvDSwhGIuXBaJDrhGWeE8fWJtDfp6twazZbRkpu5CiS6U7anRH841YbCg82N22JKAeDakyDTAn6IgtZAaKuXlqeMhHc3pRp1fw1XADaksfVbGTgYuXyx0rO93AsMacVMIFA(C94tx0yAwdGKkEbIW8iu4(z9PUWQowRdqrQ4nGXUOJR5B1Friri(Mhci84HZ3CbbKnhSQ8qLZHWQ7Ud0SgYJxlhWzow364S7TgHv3DhOzneOY5WHvLhQCoewD3DGM1qE8A5aodE7tB7rsnIoafSUwTgDrJPznasQ4ficZJqH7N1N6cR6yToafPI3ag7IoSHL4OcUoLkQMWzcGQBazZbRkpu5CiS6U7anRH841YbCMJ1Too7ERry1D3bAwdbQCoCyv5HkNdHv3DhOznKhVwoGZG3(02EKuJOdqbRRvRrx0yAwdGKkEbIW8iu4(z9PUWQowRdqrQ4nGXUOJb7V5fGfgZfGcCcTHHFazZbRkpu5CiS6U7anRH841YbCMd4Y64S7TgHv3DhOzneOY5WHvLhQCoewD3DGM1qE8A5aodE7tB7rsnIoafSUwTgDr6IgtZAaKuXlq4lNc3pRp1fC0bOiv8gWyx0HMqiqR)kyfegSaYMdwvEOY5qy1D3bAwd5XRLd4m4TpTThj1i6auW6A1AWGPMhhL0YhbQ9k(eCSThH40YhbQ9k(KhVwoGZG3(02EKuJOdqbRRvRrx0yAwdGKkEbcF5u4(z9PUWQowRdqrQ4naS1qMkg7IoylW8L(1KmX2BanGS5GvLhQCoewD3DGM1qE8A5aodE7tB7rsnIoafSUwTgmyQ5XrjT8rGAVIpbhB7rioT8rGAVIp5XRLd4m4TpTThj1i6auW6A1A0fPlAmnRbq(Yv4gAa0X3huunHB5eF6IgtZAaKVCfUHgax1XAnVDrG(jxXaYMJadunpokP5TlkCnLfsWX2EeIJX0eEuGdEteCg3bbdMX0eEuGdEteCgCjio7ERrclva0hnUsE0ykDrJPznaYxUc3qdGR6yn3f(A7nGgq2CS7TgjSubqF04k5rJP0fnMM1aiF5kCdnaUQJ1A5JIT3aAaDakQwtCWGCWDaDakCgMEuWmGMZHdUdiBocCPw(iqTxXNymnHh5WQYdvohcRU7oqZAipETCaNDAqCcCPDV1iHOP5Ci6UKhnMYzPDV1iHLka6JgxjpAmLZsUpcVOAnXbdI0YhfBVbuobAmnRH0YhfBVbucl0(deCMd4ggSanMM1qCdlCYGjAE7Iacl0(deCMdU5OMhhL4gw4Kbt082fbeCSThHccgSavZJJsmpgmG(gy9gq06)ceCSThH4WQYdvohc0Bh1ae7hnnK8ObTqqWGfOAECucaTpNdHwDwibhB7rioQ9hOscrZRHexMchhCXPbfuq0fnMM1aiF5kCdnaUQJ1yM3lmMM1i8jqdySl6WyAcpkuZJJcOlAmnRbq(Yv4gAaCvhR5UWxBVb0aYMJDV1iUl8fZBGl5rJPCygqfAEr4S7TgXDHVyEdCjpETCaC29wJ89bfvt4woXN841YbCgZaQqZlsx0yAwdG8LRWn0a4QowRLpk2EdOb0bOOAnXbdYb3b0bOWzy6rbZaAoho4oGS5iWLA5Ja1EfFIX0eEKdRkpu5CiS6U7anRH841YbC2PbXjWDV1iHOP5Ci6UKhnMYjq1(dujHO51qIltpZbxCkmylPMhhLaq7Z5qOvNfsWX2EekOGOlAmnRbq(Yv4gAaCvhR1YhfBVb0a6auuTM4Gb5G7a6au4mm9OGzanNdhChq2Ce4sT8rGAVIpXyAcpYHvLhQCoewD3DGM1qE8A5ao70G4OMhhLaq7Z5qOvNfsWX2EeIJA)bQKq08AiXLPWXbxCkNa39wJeIMMZHO7sE0ykNLmMM1qaS6zHemyiRR5Cad2s7ERrcrtZ5q0DjpAmLZs7ERrclva0hnUsE0yAq0fnMM1aiF5kCdnaUQJ1Cx4RT3aAazZH7JWloyqeUjaw9Sqo7ERrcrtZ5q0DjDxoQ5Xrja0(CoeA1zHeCSThH4O2FGkjenVgsCzkCCWfNYjWLuZJJsAE7IcxtzHeCSThHGbZyAcpkWbVjcCWDq0fnMM1aiF5kCdnaUQJ1CdlCYGjAE7IGaYMJLCFeEXbdIWnXnSWjdMO5Tlc4S7TgjennNdr3L8OXu6IgtZAaKVCfUHgax1XAaw9SWaYMd1(dujHO51qIltHJdU4uoQ5Xrja0(CoeA1zHeCSThHOlAmnRbq(Yv4gAaCvhRb92rnaX(rtddiBomMMWJcCWBIGZGB6IgtZAaKVCfUHgax1XAnVDrG(jxXaYMJavZJJsAE7IcxtzHeCSThH4ymnHhf4G3ebNb3bbdMX0eEuGdEteC26OlAmnRbq(Yv4gAaCvhR1Yh3M3txKUOX0SgabO2azpK4l10SghnVDrG(jxXaYMJadunpokP5TlkCnLfsWX2EeIJX0eEuGdEteCg3CwQLpcu7v8jgtt4XGGbZyAcpkWbVjcodUeeNDV1iHLka6JgxjpAmLUOX0SgabO2azpK4l10SMvDSM7cFT9gqdiBo29wJewQaOpACL8OXuo7ERrclva0hnUsE8A5aGJX0SgslFCBEpbdgY6kk08I0fnMM1aia1gi7HeFPMM1SQJ1Cx4RT3aAazZXU3AKWsfa9rJRKhnMYjq3hHxCWGiCtA5JBZ7HbRLpcu7v8jgtt4ryWmMM1qCx4RT3akjhrZNhHAq0fnMM1aia1gi7HeFPMM1SQJ1CdlCYGjAE7IGaYMdwO9hi4mhCbhJPj8Oah8Mi4m4MZsWBFABpsCdlCYGjCRYNZbDrJPznacqTbYEiXxQPznR6yn3f(A7nGgq2CS7TgjSubqF04k5rJPCu7pqLeIMxdjUmfoo4It5OMhhLaq7Z5qOvNfsWX2EeIUOX0SgabO2azpK4l10SMvDSM7cFT9gqdiBo29wJ4UWxmVbUKhnMYHzavO5fHZU3Ae3f(I5nWL841Ybqx0yAwdGauBGShs8LAAwZQowRLpk2EdOb0bOOAnXbdYb3b0bOWzy6rbZaAoho4oGS5iqwvEOY5qy1D3bAwd5XRLd4St5S7Tg57dkQMWTCIpbQCoCwQLpcu7v8jgtt4XG4SKAECucxZbYNZbbhB7riolbV9PT9iPLpk2EdOc3Q85CWjWad0yAwdPLpUnVNGbdzDnNdyWmMM1qCx4RT3akbdgY6AohbXjWDV1iHOP5Ci6UKhnMguqWGfOAECucaTpNdHwDwibhB7rioQ9hOscrZRHexMchhCXPCcC3BnsiAAohIUl5rJPCwYyAwdbWQNfsWGHSUMZbmylT7TgjSubqF04k5rJPCwA3BnsiAAohIUl5rJPCmMM1qaS6zHemyiRR5CWzjJPzne3f(A7nGsYr085rOYzjJPznKw(428EsoIMppc1Gcki6IgtZAaeGAdK9qIVutZAw1XAT8rX2BanGS5qnpokHR5a5Z5GGJT9ieNDV1iHOP5Ci6UKhnMYzPw(iqTxXNymnHh5eiRkpu5CiS6U7anRH841YbCwR79IhzH2FGcnV4QW9QQ5XrjCnhiFoheCSThHGblWLuZJJs((GIQjClN4tWX2EecgmwvEOY5q((GIQjClN4tE8A5aotZlk0saLihJPznKVpOOAc3Yj(ewO9hiaoChehwvEOY5qy1D3bAwd5XRLd4mnVOqlbuIbrx0yAwdGauBGShs8LAAwZQowZDHV2EdObKnhUpcV4Gbr4May1Zc5S7TgjennNdr3L0D5OMhhLaq7Z5qOvNfsWX2EeIJA)bQKq08AiXLPWXbxCkNadunpokP5TlkCnLfsWX2EeIJX0eEuGdEte4GBol1YhbQ9k(eJPj8yqWGfOX0eEuGdEteah4cNLuZJJsAE7IcxtzHeCSThHcki6IgtZAaeGAdK9qIVutZAw1XAUHfozWenVDrqazZrG7ERrcrtZ5q0DjpAmfgSaxA3BnsyPcG(OXvYJgt5eOX0SgslFuS9gqjSq7pqWzNcdMAECucaTpNdHwDwibhB7rioQ9hOscrZRHexMchhCXPbfuqCwcE7tB7rIByHtgmHBv(CoOlAmnRbqaQnq2dj(snnRzvhRXmVxymnRr4tGgWyx0HX0eEuOMhhfqx0yAwdGauBGShs8LAAwZQowd6TJAaI9JMggq2CymnHhf4G3ebNXnDrJPznacqTbYEiXxQPznR6ynM59cJPzncFc0ag7IosfVaHVCkC)S(uxGUOX0SgabO2azpK4l10SMvDSgGvplmGS5qT)avsiAEnK4Yu44GloLJAECucaTpNdHwDwibhB7ri6IgtZAaeGAdK9qIVutZAw1XAT8XT590fnMM1aia1gi7HeFPMM1SQJ1aS6zH0fPlAmnRbq0phUIkWrhGIuXlGUOX0Sgar)C4kQGvDSwhGIuXBaJDrhH2FRjzci8Ak(P5Z1JFKh4IS4jbpUiQrngba]] )


end
