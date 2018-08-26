-- MageFire.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 63 )

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
        preheat = {
            id = 273333,
            duration = 30,
            max_stack = 1,
        }
    } )


    spec:RegisterStateTable( "firestarter", setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "active" then return talent.firestarter.enabled and target.health.pct > 90 end
        end, state )
    } ) )
    

    --[[ spec:RegisterHook( "reset_precast", function ()
        auto_advance = false
    end ) ]]


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
            id = 1953,
            cast = 0,
            charges = 1,
            cooldown = 15,
            recharge = 15,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135736,

            notalent = "shimmer",
            
            handler = function ()
                if talent.blazing_soul.enabled then applyBuff( "blazing_barrier" ) end
            end,
        },
        

        combustion = {
            id = 190319,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135824,
            
            handler = function ()
                applyBuff( "combustion" )
                stat.crit = stat.crit + 100
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

            usable = function () return target.casting end,
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
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135807,

            nobuff = "fire_blasting", -- horrible.
            
            handler = function ()
                if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                else applyBuff( "heating_up" ) end

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
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
            end,
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
            charges = function () return talent.ice_ward.enabled and 2 or 1 end,
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

            velocity = 25,
            
            handler = function ()
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
            
            handler = function ()
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                end

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
            
            handler = function ()
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                end

                applyDebuff( "target", "ignite" )
                removeBuff( "hot_streak" )
                removeBuff( "pyroclasm" )
            end,
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
            
            toggle = "cooldowns",

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
                applyDebuff( "target", "ignite" )

                if azerite.preheat.enabled then applyDebuff( "target", "preheat" ) end
            end,
        },
        

        shimmer = {
            id = 212653,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135739,

            talent = "shimmer",
            
            handler = function ()
                -- applies shimmer (212653)
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
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = "Fire",
    } )


    spec:RegisterPack( "Fire", 20180813.0045, [[du0K1aqiispIkH0MeIrrL0POszvcj8kiywcPULkrzxu6xqOHPu0XujTmvcpdIyAkv6AQezBcj6BcjzCuj4CcjL1jKuX8uQ4EOW(qrDqHKQSquKhkKuvxuLOkBKkHWivjQWjvjQ0kvPmtHKkDtvIkANQunuQeQwkvcrpvftvPQ9QQ)kYGfCyslwjpg0KrLlJSzr9zuvJwOoTKvRsuvVMkvZMQUnK2TIFl1WPILd8COMoX1rPTdr9DLsJNkrNxPW6PsOmFuL9tX)1F)F4uH(7xS5vxytx4ksSBg1UikVuu7pYgo0FCuO7kF6pJIs)XfrbO)4OB4BL73)hCZcG0FIfXbh1bre5xsm7YcBueXfkRxLQhiqZcI4cfI4Y3lexz9Y4iKr0b05Ytye3xe4IRiU)IRPlNkFk5IOaKfxOW)SylVC5o)6pCQq)9l28QlSPlCfj2nJAxS5f)rzL4g8NtHg1)pCeg(N9Xf2ekSjOMGJcDx5tMqNnbfkvpMGVWc2eYnWeUCqUx(Y(hFHf8V)pCuwz9YV)VF93)hfkvp)b2SJqaSd59)HgD5jUNPx(7x87)dn6YtCpt)bckHaL(hPqjtGHjSPjeXewS5SD57MZZIflxVD(JcLQN)ifkL2QaNx(7i53)hA0LN4EM(deucbk9pl2C2cB0flwQESC925pkuQE(dAbanivOkF6L)(U)()qJU8e3Z0FGGsiqP)jxaclkqiGvHsHmzcrmbfkvpwa7qPoNC6TeWcJvaFcBcmmHlmbE8mby3EUE7yHn6IflvpwaHQ1GnbMnHD30eIycl2C2cB0flwQESC92XeIyci1ee1tJyDVgoFn8T0OlpXzc84zcIc4tIvkukjDIRityht46vtGhptqupnI19A481W3sJU8eNjeXeC1eGXkGpHtzGcLQh1BcmBcxTUGjWJNjifkzc7yc7UPj4MjeXeGD756TJf2OlwSu9ybeQwd2ey2e2DZ)OqP65pa2HsDo50BjWl)9l97)dn6YtCpt)bckHaL(NfBoBD2a0qVIrTasHIjeXeC1eGD756TJf2OlwSu9ybeQwd2ey2e2DttGhptqHs1JfWouQZjNElbSWyfWNWMaZMWvtWT)OqP65pa2HsDo50BjWl)9O83)hA0LN4EM(JcLQN)avVpPqP6j5lS8hiOecu6FGD756TJf2OlwSu9ybeQwd2e2HHjOqP6Xcyhk15KtVLawOILKuOKjGGj4QjGutqupnI19A481W3sJU8eNjefMaFiNj4MjeXeC1eqQjiQNgXMlaHffieWsJU8eNjWJNjGutixaclkqiGvHsHmzc84zckukKPeneArytGzgMWUMapEMGcLczkrdHwe2eyMHjCHjeXee1tJyZEfLsoQaJT0OlpXzcUzc84zcl2C2cB0flwQESSo)Xxyjnkk9hyJUyXs1tYjwX0l)9O63)hA0LN4EM(JcLQN)avVpPqP6j5lS8hiOecu6FwS5SfWouQZjNElbSSoMqetyXMZwyJUyXs1JLR3o)Xxyjnkk9hq7KCIvm9YF3f(9)HgD5jUNP)OqP65pq17tkuQEs(cl)Xxyjnkk9hSOdNc4sGwuP65Lx(JdGGn6sLF)F)6V)p0OlpX9m9YF)IF)FOrxEI7z6L)os(9)HgD5jUNPx(77(7)JcLQN)OaOouQgH8Eck)HgD5jUNPx(7x63)hA0LN4EME5VhL)()OqP65pOfa0GuHQ8P)qJU8e3Z0l)9O63)hfkvp)XPLQN)qJU8e3Z0l)Dx43)hfkvp)XzdqV8kw(dn6YtCptV8YFGn6IflvpjNyft)()(1F)FOrxEI7z6pqqjeO0)SyZzlSrxSyP6XY1BN)OqP65p(IFSGtx(SC8rPrE5VFXV)p0OlpX9m9hiOecu6FwS5Sf2OlwSu9y56TZFuOu98ha7qPoNC6Te4L)os(9)HgD5jUNP)OqP65pq17tkuQEs(cl)Xxyjnkk9hfkfYusupnc(L)(U)()OqP65pWgDXILQN)qJU8e3Z0l)9l97)JcLQN)40s1ZFOrxEI7z6L)Eu(7)JcLQN)S8DZLYSGn(dn6YtCptV83JQF)FuOu98NfbWeW9A4)hA0LN4EME5V7c)()OqP65p5cqlF3C)HgD5jUNPx(7rTF)FuOu98hDGewaQpbvV)p0OlpX9m9YF)6M)()OqP65pSykvcHI)dn6YtCptV83VE93)hA0LN4EM(deucbk9pUAcUAcI6PrSzVIsjhvGXwA0LN4mHiMGcLczkrdHwe2ey2eUWeCZe4XZeuOuitjAi0IWMaZMquAcUzcrmHfBoBJBjHfaPUBbKcL)OqP65pzVIsybuUtV83VEXV)p0OlpX9m9hiOecu6FwS5S1zdqd9kg1cifkMqetyXMZwyJUyXs1JfqOAnytGztGCjbzfkjfk9hfkvp)XzdqV8kwE5VFfj)()qJU8e3Z0FGGsiqP)zXMZ24wsybqQ7waPq5pkuQE(JZgGE5vS8YF)6U)()qJU8e3Z0FGGsiqP)zXMZ2ysLA4NyDSasHYFuOu98NCbO0YRy5L)(1l97)JcLQN)4e30uUmL9kkH)dn6YtCptV83VgL)()qJU8e3Z0FGGsiqP)zXMZwyJUyXs1JfqOAnytGztaQyjjfk9hfkvp)bdBam(L)(1O63)hA0LN4EM(deucbk9pi1ewS5SnULewaK6UfqkumHiMGcLQhBUauA5vSyHXkGpHnHDmHR)rHs1ZF4ak)EWPfGuj(L)(vx43)hA0LN4EM(deucbk9pIc4tInMuVeBDGIjSddtajBAcrmbr90iwmPGA4NKMfgBPrxEI7pkuQE(dg2ay8lV8hfkfYusupnc(3)3V(7)dn6YtCpt)bckHaL(hxnHfBoBHn6IflvpwUE7ycUzc84zcUAcl2C2cB0flwQESSoMqetqHs1JnxakT8kwSWyfWNWMWoMWvtWT)OqP65plVIL0wfz6L)(f)()qJU8e3Z0FGGsiqP)b2TNR3owyJUyXs1JfqOAnytGzty3nnbE8mbxnby3EUE7yHn6IflvpwaHQ1GnbMnbrb8jXkfkLKoXvKj4MjWJNjSyZzlGDOuNto9wcyzDmbE8mHCbiSOaHawfkfY0FuOu98husOg8YFhj)()qJU8e3Z0FGGsiqP)rupnIv9KlXcqXUykoLzbByPrxEIZeIyci1ewS5SnULewaK6Ufqku(JcLQN)Wbu(9GtlaPs8l)9D)9)HgD5jUNP)abLqGs)JcLczkrdHwe2ey2eUAcrmHfBoBHn6IflvpwUE78hfkvp)Xxixd)0QrxV8YFWIoCkGlbArLQNF)F)6V)p0OlpX9m9hiOecu6FC1eC1ee1tJyZEfLsoQaJT0OlpXzcrmbfkfYuIgcTiSjWSjC1eCZe4XZeuOuitjAi0IWMaZMWUMGBMqetyXMZ24wsybqQ7waPq5pkuQE(t2ROewaL70l)9l(9)HgD5jUNP)abLqGs)ZInNTXTKWcGu3TasHIjeXewS5SnULewaK6UfqOAnytyhtqHs1JnxaAPEVLCjbzfkjfk9hfkvp)XzdqV8kwE5VJKF)FOrxEI7z6pqqjeO0)SyZzBCljSai1DlGuOycrmHCbiSOaHawfkfYKjeXeqQjiQNgXcyhk15KtVLawA0LN4(JcLQN)4SbOxEflV83393)hA0LN4EM(deucbk9pWyfWNWPmqHs1J6nbMnHlSrLjeXeuOuitjAi0IWMaZMWf)rHs1ZFCIBAkxMYEfLWV83V0V)p0OlpX9m9hiOecu6FwS5SnULewaK6UfqkumHiMGRMasnbhaHCIpKZE16SbOxEflMapEMGcLQhRZgGE5vSyRjL9f)yXeC7pkuQE(JZgGE5vS8YFpk)9)HgD5jUNP)abLqGs)ZInNTXTKWcGu3TasHIjeXeefWNeBmPEj26aftyhgMas20eIycI6PrSysb1Wpjnlm2sJU8e3FuOu98hNna9YRy5L)Eu97)dn6YtCpt)bckHaL(NfBoBD2a0qVIrTasHIjeXeixsqwHssHsMWoMWInNToBaAOxXOwaHQ1G)JcLQN)4SbOxEflV83DHF)FOrxEI7z6pkuQE(du9(KcLQNKVWYF8fwsJIs)rHsHmLe1tJGF5Vh1(9)HgD5jUNP)abLqGs)dsnbr90iw3RHZxdFln6YtCMqetyXMZ2ysLA4NyDSasHIjeXeC1eqQjiQNgXcyhk15KtVLawA0LN4mbE8mbySc4t4ugOqP6r9MaZMWv7UMapEMaSBpxVDSWgDXILQhlGq1AWMWoMWUBAcUzcrmbxnbKycxMjaJvaFcNYafkvpQ3eCZeIctWvt46fMquycyhY7tXkwitWntyhta2TNR3owyJUyXs1JfqOAnytabtajMapEMGOa(KyLcLssN4kYe2Xe29pkuQE(tUauA5vS8YF)6M)()qJU8e3Z0FGGsiqP)rupnI19A481W3sJU8eNjeXewS5SnMuPg(jwhlGuOycrmbxnbKAcI6PrSa2HsDo50BjGLgD5jotGhptagRa(eoLbkuQEuVjWSjC1EjtGhpta2TNR3owyJUyXs1JfqOAnytyhty3nnb3mHiMGRMasmHlZeGXkGpHtzGcLQh1BcUzcrHj4QjC1fmHOWeWoK3NIvSqMGBMWoMaSBpxVDSWgDXILQhlGq1AWMacMasmbE8mbrb8jXkfkLKoXvKjSJjS7FuOu98NCbO0YRy5L)(1R)()qJU8e3Z0FGGsiqP)XvtyXMZwyJUyXs1JL1Xe4XZewS5SfWouQZjNElbSSoMapEMWInNT1a1riaoL99wlwuO7MaZMasmbE8mbr90iw0caAqQqv(KLgD5jotWntiIj4QjSRjCzMamwb8jCkduOu9OEtWntikmHRiXe2XeGD756TJf2OlwSu9ybeQwd2eqWeUKjWJNjikGpjwPqPK0jUImHDmHRB(hfkvp)XjUPPCzk7vuc)YF)6f)()qJU8e3Z0FGGsiqP)XvtyXMZwyJUyXs1JL1Xe4XZewS5SfWouQZjNElbSSoMGBMqetWvtyxt4YmbySc4t4ugOqP6r9MGBMquycizttyhta2TNR3owyJUyXs1JfqOAnytabt4s)rHs1ZFCIBAkxMYEfLWV83VIKF)FOrxEI7z6pqqjeO0)aJvaFcNYafkvpQ3ey2eUWEjtiIja72Z1BhlSrxSyP6XciuTgSjWSjCbs(JcLQN)4e30uUmL9kkHF5VFD3F)FOrxEI7z6pqqjeO0)4QjikGpj2ys9sS1bkMWommbKSPjeXee1tJyXKcQHFsAwySLgD5jotWntGhptWvtqDXiqjK1bqXKkwA0LN4mHiMahTyZzRdGIjvSC92XeC7pkuQE(dg2ay8l)9Rx63)hfkvp)jxaAPE)FOrxEI7z6L)(1O83)hfkvp)bdBam(p0OlpX9m9Yl)b0ojNyft)()(1F)FuOu98ha7qPoNC6Te4p0OlpX9m9YF)IF)FOrxEI7z6pqqjeO0)4Qj4QjiQNgXM9kkLCubgBPrxEIZeIyckukKPeneArytGzt4Qj4MjWJNjOqPqMs0qOfHnbMnHDnb3mHiMWInNTXTKWcGu3TasHYFuOu98NSxrjSak3Px(7i53)hA0LN4EM(deucbk9pl2C2g3sclasD3cifk)rHs1ZFC2a0lVILx(77(7)dn6YtCpt)rHs1ZFGQ3NuOu9K8fw(JVWsAuu6pkukKPKOEAe8l)9l97)dn6YtCpt)bckHaL(NfBoBD2a0qVIrTasHIjeXeixsqwHssHsMWoMWInNToBaAOxXOwaHQ1GnHiMWInNTa2HsDo50BjGfqOAnytGztaQyjjfk9hfkvp)XzdqV8kwE5VhL)()qJU8e3Z0FGGsiqP)bPMGdGqo15CIpKZMlaLwEflMqetyXMZ2ysLA4NyDSasHIjeXeYfGWIcecyvOuitMqetagRa(eoLbkuQEuVjWSjC1gv)rHs1ZFYfGslVILx(7r1V)p0OlpX9m9hiOecu6FqQj4aiKt8HC2RwN4MMYLPSxrjSjeXeGXkGpHtzGcLQh1BcmBcxyJktiIjKlaHffieWQqPqM(JcLQN)4e30uUmL9kkHF5V7c)()qJU8e3Z0FGGsiqP)bPMGdGqo15CIpKZMlaLwEflMqetaPMqUaewuGqaRcLcz6pkuQE(tUauA5vS8YFpQ97)dn6YtCpt)bckHaL(hKAcoac5eFiN9Q1jUPPCzk7vuc)hfkvp)XjUPPCzk7vuc)YF)6M)()qJU8e3Z0FGGsiqP)ruaFsSXK6LyRdumHDyycizttiIjiQNgXIjfud)K0SWyln6YtC)rHs1ZFWWgaJF5VF96V)p0OlpX9m9hiOecu6FuOuitjAi0IWMaZMWf)rHs1ZF4ak)EWPfGuj(L)(1l(9)HgD5jUNP)abLqGs)JRMGOEAeB2ROuYrfySLgD5jotiIjOqPqMs0qOfHnbMnHlmb3mbE8mbfkfYuIgcTiSjWSjCP)OqP65pzVIsybuUtV83VIKF)FuOu98NCbOL69)HgD5jUNPxE5L)GmbWvp)9l28QlSPlCfj2n3C3l9NTkyQHp(pxUOonqiotiknbfkvpMGVWc2AU9hhqNlp9hxut4YZLeKviotyr5gqMaSrxQyclIFnyRje1dcjhbBctpxwScqZSEtqHs1d2e6XVH1CtHs1d26aiyJUuHr2Ry3n3uOu9GToac2OlvqGbI5U5m3uOu9GToac2OlvqGbIklFuAevQEm3uOu9GToac2OlvqGbIkaQdLQriVNGI5McLQhS1bqWgDPccmqepQdoULewubBUPqP6bBDaeSrxQGaderlaObPcv5tMBkuQEWwhabB0LkiWarNwQEm3uOu9GToac2OlvqGbIoBa6LxXI5M5MlQjC55scYkeNjqitGnmbPqjtqIjtqHsdmHcBckYA51LNSMBkuQEWmGn7iea7qEV5McLQhmcmqukukTvborxzgsHsm2mYInNTlF3CEwSy56TJ5McLQhmcmqeTaGgKkuLpfDLzSyZzlSrxSyP6XY1BhZnxut4i6WPaotyV6PrmbxKTlUje1T5xqR5McLQhmcmqeWouQZjNElbIUYmYfGWIcecyvOuitruOu9ybSdL6CYP3salmwb8jmJl4Xd2TNR3owyJUyXs1JfqOAnyM3DZil2C2cB0flwQESC92jcsf1tJyDVgoFn8T0OlpXXJNOa(KyLcLssN4kANRx5XtupnI19A481W3sJU8exexHXkGpHtzGcLQh1Z8vRlWJNuO0o7UPBrGD756TJf2OlwSu9ybeQwdM5D30CZf1eCr2U4MalMmHTXLNmbwCn8nbx8nan0RyuR5McLQhmcmqeWouQZjNElbIUYmwS5S1zdqd9kg1cifkrCf2TNR3owyJUyXs1JfqOAnyM3DtE8uOu9ybSdL6CYP3salmwb8jmZxDZCtHs1dgbgicvVpPqP6j5lSe9OOedyJUyXs1tYjwXu0vMbSBpxVDSWgDXILQhlGq1AW7WqHs1JfWouQZjNElbSqfljPqjeCfPI6PrSUxdNVg(wA0LN4Ic(qo3I4ksf1tJyZfGWIcecyPrxEIJhpKMlaHffieWQqPqM4XtHsHmLOHqlcZmJD5XtHsHmLOHqlcZmJlIiQNgXM9kkLCubgBPrxEIZnE8wS5Sf2OlwSu9yzDm3uOu9GrGbIq17tkuQEs(clrpkkXa0ojNyftrxzgl2C2cyhk15KtVLawwNil2C2cB0flwQESC92XCtHs1dgbgicvVpPqP6j5lSe9OOedSOdNc4sGwuP6XCZCtHs1d2QqPqMsI6PrWmwEflPTkYu0vMHRl2C2cB0flwQESC92XnE8CDXMZwyJUyXs1JL1jIcLQhBUauA5vSyHXkGpH35QBMBkuQEWwfkfYusupncgbgiIsc1GORmdy3EUE7yHn6IflvpwaHQ1GzE3n5XZvy3EUE7yHn6IflvpwaHQ1GzwuaFsSsHsjPtCf5gpEl2C2cyhk15KtVLawwhE8YfGWIcecyvOuitMBkuQEWwfkfYusupncgbgiYbu(9GtlaPsC0vMHOEAeR6jxIfGIDXuCkZc2WsJU8exeKUyZzBCljSai1DlGuOyUPqP6bBvOuitjr90iyeyGOVqUg(PvJUIUYmuOuitjAi0IWmFnYInNTWgDXILQhlxVDm3m3uOu9GTWgDXILQNKtSIjg(IFSGtx(SC8rPrIUYmwS5Sf2OlwSu9y56TJ5McLQhSf2OlwSu9KCIvmHadebSdL6CYP3sGORmJfBoBHn6IflvpwUE7yUPqP6bBHn6IflvpjNyftiWarO69jfkvpjFHLOhfLyOqPqMsI6PrWMBkuQEWwyJUyXs1tYjwXecmqe2OlwSu9yUPqP6bBHn6IflvpjNyftiWarNwQEm3uOu9GTWgDXILQNKtSIjeyG4Y3nxkZc2WCtHs1d2cB0flwQEsoXkMqGbIlcGjG71W3CtHs1d2cB0flwQEsoXkMqGbI5cqlF3CMBkuQEWwyJUyXs1tYjwXecmquhiHfG6tq17n3uOu9GTWgDXILQNKtSIjeyGilMsLqOyZnfkvpylSrxSyP6j5eRycbgiM9kkHfq5ofDLz4QRI6PrSzVIsjhvGXwA0LN4IOqPqMs0qOfHz(c34XtHsHmLOHqlcZCu6wKfBoBJBjHfaPUBbKcfZnfkvpylSrxSyP6j5eRycbgi6SbOxEflrxzgl2C26SbOHEfJAbKcLil2C2cB0flwQESacvRbZm5scYkuskuYCtHs1d2cB0flwQEsoXkMqGbIoBa6LxXs0vMXInNTXTKWcGu3TasHI5McLQhSf2OlwSu9KCIvmHadeZfGslVILORmJfBoBJjvQHFI1XcifkMBkuQEWwyJUyXs1tYjwXecmq0jUPPCzk7vucBUPqP6bBHn6IflvpjNyftiWarmSbW4ORmJfBoBHn6IflvpwaHQ1GzgQyjjfkzUPqP6bBHn6IflvpjNyftiWaroGYVhCAbivIJUYmq6InNTXTKWcGu3TasHsefkvp2CbO0YRyXcJvaFcVZvZnfkvpylSrxSyP6j5eRycbgiIHnaghDLzikGpj2ys9sS1bk7WajBgrupnIftkOg(jPzHXwA0LN4m3m3uOu9GTG2j5eRyIbGDOuNto9wcyUPqP6bBbTtYjwXecmqm7vuclGYDk6kZWvxf1tJyZEfLsoQaJT0OlpXfrHsHmLOHqlcZ8v34XtHsHmLOHqlcZ8UUfzXMZ24wsybqQ7waPqXCtHs1d2cANKtSIjeyGOZgGE5vSeDLzSyZzBCljSai1DlGuOyUPqP6bBbTtYjwXecmqeQEFsHs1tYxyj6rrjgkukKPKOEAeS5McLQhSf0ojNyftiWarNna9YRyj6kZyXMZwNnan0RyulGuOeHCjbzfkjfkTZInNToBaAOxXOwaHQ1GJSyZzlGDOuNto9wcybeQwdMzOILKuOK5McLQhSf0ojNyftiWaXCbO0YRyj6kZaPoac5uNZj(qoBUauA5vSezXMZ2ysLA4NyDSasHsKCbiSOaHawfkfYueySc4t4ugOqP6r9mF1gvMBkuQEWwq7KCIvmHadeDIBAkxMYEfLWrxzgi1bqiN4d5SxToXnnLltzVIs4iWyfWNWPmqHs1J6z(cBufjxaclkqiGvHsHmzUPqP6bBbTtYjwXecmqmxakT8kwIUYmqQdGqo15CIpKZMlaLwEflrqAUaewuGqaRcLczYCtHs1d2cANKtSIjeyGOtCtt5Yu2ROeo6kZaPoac5eFiN9Q1jUPPCzk7vucBUPqP6bBbTtYjwXecmqedBamo6kZquaFsSXK6LyRdu2Hbs2mIOEAelMuqn8tsZcJT0OlpXzUPqP6bBbTtYjwXecmqKdO87bNwasL4ORmdfkfYuIgcTimZxyUPqP6bBbTtYjwXecmqm7vuclGYDk6kZWvr90i2SxrPKJkWyln6YtCruOuitjAi0IWmFHB84PqPqMs0qOfHz(sMBkuQEWwq7KCIvmHadeZfGwQ3BUzUPqP6bBXIoCkGlbArLQhgzVIsybuUtrxzgU6QOEAeB2ROuYrfySLgD5jUikukKPeneAryMV6gpEkukKPeneAryM31Til2C2g3sclasD3cifkMBkuQEWwSOdNc4sGwuP6bbgi6SbOxEflrxzgl2C2g3sclasD3cifkrwS5SnULewaK6UfqOAn4DuOu9yZfGwQ3BjxsqwHssHsMBkuQEWwSOdNc4sGwuP6bbgi6SbOxEflrxzgl2C2g3sclasD3cifkrYfGWIcecyvOuitrqQOEAelGDOuNto9wcyPrxEIZCtHs1d2IfD4uaxc0IkvpiWarN4MMYLPSxrjC0vMbmwb8jCkduOu9OEMVWgvruOuitjAi0IWmFH5McLQhSfl6WPaUeOfvQEqGbIoBa6LxXs0vMXInNTXTKWcGu3TasHsexrQdGqoXhYzVAD2a0lVIfE8uOu9yD2a0lVIfBnPSV4hlUzUPqP6bBXIoCkGlbArLQheyGOZgGE5vSeDLzSyZzBCljSai1DlGuOeruaFsSXK6LyRdu2Hbs2mIOEAelMuqn8tsZcJT0OlpXzUPqP6bBXIoCkGlbArLQheyGOZgGE5vSeDLzSyZzRZgGg6vmQfqkuIqUKGScLKcL2zXMZwNnan0RyulGq1AWMBkuQEWwSOdNc4sGwuP6bbgicvVpPqP6j5lSe9OOedfkfYusupnc2CtHs1d2IfD4uaxc0IkvpiWaXCbO0YRyj6kZaPI6PrSUxdNVg(wA0LN4ISyZzBmPsn8tSowaPqjIRivupnIfWouQZjNElbS0OlpXXJhmwb8jCkduOu9OEMVA3Lhpy3EUE7yHn6IflvpwaHQ1G3z3nDlIRi5YGXkGpHtzGcLQh17wu461lIcSd59PyflKB7a72Z1BhlSrxSyP6XciuTgmciHhprb8jXkfkLKoXv0o7AUPqP6bBXIoCkGlbArLQheyGyUauA5vSeDLziQNgX6EnC(A4BPrxEIlYInNTXKk1WpX6ybKcLiUIur90iwa7qPoNC6TeWsJU8ehpEWyfWNWPmqHs1J6z(Q9s84b72Z1BhlSrxSyP6XciuTg8o7UPBrCfjxgmwb8jCkduOu9OE3IcxV6crb2H8(uSIfYTDGD756TJf2OlwSu9ybeQwdgbKWJNOa(KyLcLssN4kANDn3uOu9GTyrhofWLaTOs1dcmq0jUPPCzk7vuchDLz46InNTWgDXILQhlRdpEl2C2cyhk15KtVLawwhE8wS5STgOocbWPSV3AXIcDNzKWJNOEAelAbanivOkFYsJU8eNBrCD3ldgRa(eoLbkuQEuVBrXvKSdSBpxVDSWgDXILQhlGq1AWiCjE8efWNeRuOus6exr7CDtZnfkvpylw0HtbCjqlQu9GadeDIBAkxMYEfLWrxzgUUyZzlSrxSyP6XY6WJ3InNTa2HsDo50BjGL1XTiUU7LbJvaFcNYafkvpQ3TOajBUdSBpxVDSWgDXILQhlGq1AWiCjZnfkvpylw0HtbCjqlQu9GadeDIBAkxMYEfLWrxzgWyfWNWPmqHs1J6z(c7LIa72Z1BhlSrxSyP6XciuTgmZxGeZnfkvpylw0HtbCjqlQu9GadeXWgaJJUYmCvuaFsSXK6LyRdu2Hbs2mIOEAelMuqn8tsZcJT0OlpX5gpEUQUyeOeY6aOysfln6YtCr4OfBoBDaumPILR3oUzUPqP6bBXIoCkGlbArLQheyGyUa0s9EZnfkvpylw0HtbCjqlQu9GadeXWgaJ)d2HG)9OejV8Y)]] )


end
