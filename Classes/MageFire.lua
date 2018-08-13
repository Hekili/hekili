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
    } )


    spec:RegisterStateTable( "firestarter", setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "active" then return talent.firestarter.enabled and target.health.pct > 90 end
        end, state )
    } ) )
    

    spec:RegisterHook( "reset_precast", function ()
        auto_advance = false
    end )


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
    
        package = nil,
    } )


    spec:RegisterPack( "Fire", 20180813.0045, [[duKk1aqiiQEeefSjHyuuPCkQKwfvI6vQunlHu3siP2fL(femmvsoMkLLPsQNPuvttPkxdIsBtirFtijJtiHZrLiADquiMNsr3df2hkQdcrHYcrrEiefQUiefLnsLiyKqueojefPvQsmtikKUjefr7ecnuQePwkvIqpvftvPYEv1FfzWcomPfRKhdAYOYLr2SO(mQQrluNwYQHOO61uPA2u1TH0Uv8BPgovSCGNd10jUokTDiY3vknEQeoVsH1tLiz(Ok7NI)B)U)WPc9iE9v3IIRIIB7BV6Q9IY937pYgo0FCuO7kF6pJIs)XLqbO)4OB4BL739hCZcG0FIfXbJmcciWVKy2Lf2OiGluwVkvpqGMfeWfkeHLVxiSYAuZriHGdOZLNWiSRiW13qy313sitQ8PKlHcqwCHc)ZIT8cY05x)Htf6r86RUffxff323E1v77sEDu8hLvIBWFofkY4)HJWW)SlUWMqHnb1eCuO7kFYe6SjOqP6Xe8fwWMqUbMaYeK7LVS)Xxyb)7(dhLvwV87EeV97(JcLQN)aB2ria2H8()qJU8e3Z0lpIx)7(dn6YtCpt)bckHaL(NfBoBHn6IflvpwUE78hfkvp)bTaGgKkuLp9YJ4()U)qJU8e3Z0FGGsiqP)jxaclkqiGvHsHezcrmbfkvpwa7qPoNC6TeWcJvaFcBcmmHRnbE8mby3EUE7yHn6IflvpwaHQ1GnbMnH9UYeIycl2C2cB0flwQESC92XeIyci3ee1tJyDVgoFn8T0OlpXzc84zcIc4tIvkukjDIRitytt42ntGhptqupnI19A481W3sJU8eNjeXeCZeGXkGpHtzGcLQh1BcmBc3SrHjWJNjifkzcBAc7DLj4QjeXeGD756TJf2OlwSu9ybeQwd2ey2e27Q)OqP65pa2HsDo50BjWlpI797(dn6YtCpt)bckHaL(NfBoBD2a0qVIrTasHIjeXeCZeGD756TJf2OlwSu9ybeQwd2ey2e27ktGhptqHs1JfWouQZjNElbSWyfWNWMaZMWntW1)OqP65pa2HsDo50BjWlpIi7V7p0OlpX9m9hiOecu6FGD756TJf2OlwSu9ybeQwd2e2KHjOqP6Xcyhk15KtVLawOILKuOKjC3eCZeqUjiQNgX6EnC(A4BPrxEIZeCztGpKZeC1eIycUzci3ee1tJyZfGWIcecyPrxEIZe4XZeqUjKlaHffieWQqPqImbE8mbfkfsuIgcTiSjWmdtyptGhptqHsHeLOHqlcBcmZWeU2eIycI6PrSzVIsjhvGXwA0LN4mbxnbE8mHfBoBHn6IflvpwwN)OqP65pq17tkuQEs(cl)Xxyjnkk9hyJUyXs1tYjwX0lpIr5V7p0OlpX9m9hiOecu6FwS5SfWouQZjNElbSSoMqetyXMZwyJUyXs1JLR3o)rHs1ZFGQ3NuOu9K8fw(JVWsAuu6pG2j5eRy6LhXO639hA0LN4EM(JcLQN)avVpPqP6j5lS8hFHL0OO0FWIoCkGlbArLQNxE5poac2Olv(DpI3(D)HgD5jUNPxEeV(39hA0LN4EME5rC)F3FOrxEI7z6LhX9(D)rHs1ZFuauhkvJqEpbL)qJU8e3Z0lpIi7V7p0OlpX9m9YJyu(7(JcLQN)GwaqdsfQYN(dn6YtCptV8igv)U)OqP65poTu98hA0LN4EME5rmk(D)rHs1ZFC2a0lVIL)qJU8e3Z0lV8hyJUyXs1tYjwX0V7r82V7p0OlpX9m9hiOecu6FwS5Sf2OlwSu9y56TZFuOu98hFXpwWjK5SC8rPrE5r86F3FOrxEI7z6pqqjeO0)SyZzlSrxSyP6XY1BN)OqP65pa2HsDo50BjWlpI7)7(dn6YtCpt)rHs1ZFGQ3NuOu9K8fw(JVWsAuu6pkukKOKOEAe8lpI797(JcLQN)aB0flwQE(dn6YtCptV8iIS)U)OqP65poTu98hA0LN4EME5rmk)D)rHs1ZFw(U5szwWg)HgD5jUNPxEeJQF3FuOu98NfbWeW9A4)hA0LN4EME5rmk(D)rHs1ZFYfGw(U5(dn6YtCptV8i6s(7(JcLQN)OdKWcq9jO69)HgD5jUNPxEeVD1V7pkuQE(dlMsLqO4)qJU8e3Z0lpI3U97(dn6YtCpt)bckHaL(h3mb3mbr90i2SxrPKJkWyln6YtCMqetqHsHeLOHqlcBcmBcxBcUAc84zckukKOeneArytGztiknbxnHiMWInNTXTKWcGu3TasHYFuOu98NSxrjSak3PxEeVD9V7p0OlpX9m9hiOecu6FwS5S1zdqd9kg1cifkMqetyXMZwyJUyXs1JfqOAnytGztGCbbzfkjfk9hfkvp)XzdqV8kwE5r82()U)qJU8e3Z0FGGsiqP)zXMZ24wsybqQ7waPq5pkuQE(JZgGE5vS8YJ4T9(D)HgD5jUNP)abLqGs)ZInNTXKk1WpX6ybKcL)OqP65p5cqPLxXYlpI3q2F3FuOu98hN4MMYfPSxrj8FOrxEI7z6LhXBr5V7p0OlpX9m9hiOecu6FwS5Sf2OlwSu9ybeQwd2ey2eGkwssHs)rHs1ZFWWgaJF5r8wu97(dn6YtCpt)bckHaL(hKBcl2C2g3sclasD3cifkMqetqHs1JnxakT8kwSWyfWNWMWMMWT)OqP65pCaLFp40cqQe)YJ4TO439hA0LN4EM(deucbk9pIc4tInMuVeBDGIjSjdty)RmHiMGOEAelMuqn8tsZcJT0OlpX9hfkvp)bdBam(Lx(JcLcjkjQNgb)7EeV97(dn6YtCpt)bckHaL(h3mHfBoBHn6IflvpwUE7ycUAc84zcUzcl2C2cB0flwQESSoMqetqHs1JnxakT8kwSWyfWNWMWMMWntW1)OqP65plVIL0wfj6LhXR)D)HgD5jUNP)abLqGs)dSBpxVDSWgDXILQhlGq1AWMaZMWExzc84zcUzcWU9C92XcB0flwQESacvRbBcmBcIc4tIvkukjDIRitWvtGhptyXMZwa7qPoNC6TeWY6yc84zc5cqyrbcbSkukKO)OqP65pOKqn4LhX9)D)HgD5jUNP)abLqGs)JOEAeR6jxGfGIDPuCkZc2WsJU8eNjeXeqUjSyZzBCljSai1DlGuO8hfkvp)HdO87bNwasL4xEe3739hA0LN4EM(deucbk9pkukKOeneArytGzt4MjeXewS5Sf2OlwSu9y56TZFuOu98hFHun8tRgD9Yl)bl6WPaUeOfvQE(DpI3(D)HgD5jUNP)abLqGs)JBMGBMGOEAeB2ROuYrfySLgD5jotiIjOqPqIs0qOfHnbMnHBMGRMapEMGcLcjkrdHwe2ey2e2ZeC1eIycl2C2g3sclasD3cifk)rHs1ZFYEfLWcOCNE5r86F3FOrxEI7z6pqqjeO0)SyZzBCljSai1DlGuOycrmHfBoBJBjHfaPUBbeQwd2e20euOu9yZfGwQ3BjxqqwHssHs)rHs1ZFC2a0lVILxEe3)39hA0LN4EM(deucbk9pl2C2g3sclasD3cifkMqetixaclkqiGvHsHezcrmbKBcI6PrSa2HsDo50BjGLgD5jU)OqP65poBa6LxXYlpI797(dn6YtCpt)bckHaL(hySc4t4ugOqP6r9MaZMW12OYeIyckukKOeneArytGzt46)OqP65poXnnLlszVIs4xEer2F3FOrxEI7z6pqqjeO0)SyZzBCljSai1DlGuOycrmb3mbKBcoacPeFiN9M1zdqV8kwmbE8mbfkvpwNna9YRyXwtk7l(XIj46FuOu98hNna9YRy5LhXO839hA0LN4EM(deucbk9pl2C2g3sclasD3cifkMqetquaFsSXK6LyRdumHnzyc7FLjeXee1tJyXKcQHFsAwySLgD5jU)OqP65poBa6LxXYlpIr1V7p0OlpX9m9hiOecu6FwS5S1zdqd9kg1cifkMqetGCbbzfkjfkzcBAcl2C26SbOHEfJAbeQwd(pkuQE(JZgGE5vS8YJyu87(dn6YtCpt)rHs1ZFGQ3NuOu9K8fw(JVWsAuu6pkukKOKOEAe8lpIUK)U)qJU8e3Z0FGGsiqP)b5MGOEAeR71W5RHVLgD5jotiIjSyZzBmPsn8tSowaPqXeIycUzci3ee1tJybSdL6CYP3saln6YtCMapEMamwb8jCkduOu9OEtGzt4MDptGhpta2TNR3owyJUyXs1JfqOAnytyttyVRmbxnHiMGBMW(MquBcWyfWNWPmqHs1J6nbxnbx2eCZeUDTj4YMa2H8(uSIfYeC1e20eGD756TJf2OlwSu9ybeQwd2eUBc7Bc84zcIc4tIvkukjDIRityttyV)OqP65p5cqPLxXYlpI3U639hA0LN4EM(deucbk9pI6PrSUxdNVg(wA0LN4mHiMWInNTXKk1WpX6ybKcftiIj4MjGCtqupnIfWouQZjNElbS0OlpXzc84zcWyfWNWPmqHs1J6nbMnHBwK1e4XZeGD756TJf2OlwSu9ybeQwd2e20e27ktWvtiIj4MjSVje1Mamwb8jCkduOu9OEtWvtWLnb3mHBrHj4YMa2H8(uSIfYeC1e20eGD756TJf2OlwSu9ybeQwd2eUBc7Bc84zcIc4tIvkukjDIRityttyV)OqP65p5cqPLxXYlpI3U97(dn6YtCpt)bckHaL(h3mHfBoBHn6IflvpwwhtGhptyXMZwa7qPoNC6TeWY6yc84zcl2C2wduhHa4u23BTyrHUBcmBc7Bc84zcI6PrSOfa0GuHQ8jln6YtCMGRMqetWntyptiQnbySc4t4ugOqP6r9MGRMGlBc323e20eGD756TJf2OlwSu9ybeQwd2eUBciRjWJNjikGpjwPqPK0jUImHnnHBx9hfkvp)XjUPPCrk7vuc)YJ4TR)D)HgD5jUNP)abLqGs)JBMWInNTWgDXILQhlRJjWJNjSyZzlGDOuNto9wcyzDmbxnHiMGBMWEMquBcWyfWNWPmqHs1J6nbxnbx2e2)ktytta2TNR3owyJUyXs1JfqOAnyt4UjGS)rHs1ZFCIBAkxKYEfLWV8iEB)F3FOrxEI7z6pqqjeO0)aJvaFcNYafkvpQ3ey2eU2ISMqeta2TNR3owyJUyXs1JfqOAnytGzt469)JcLQN)4e30uUiL9kkHF5r82E)U)qJU8e3Z0FGGsiqP)XntquaFsSXK6LyRdumHnzyc7FLjeXee1tJyXKcQHFsAwySLgD5jotWvtGhptWntqDPiqjK1bqXKkwA0LN4mHiMahTyZzRdGIjvSC92XeC9pkuQE(dg2ay8lpI3q2F3FuOu98NCbOL69)HgD5jUNPxEeVfL)U)OqP65pyydGX)HgD5jUNPxE5pG2j5eRy639iE739hfkvp)bWouQZjNElb(dn6YtCptV8iE9V7p0OlpX9m9hiOecu6FCZeCZee1tJyZEfLsoQaJT0OlpXzcrmbfkfsuIgcTiSjWSjCZeC1e4XZeuOuirjAi0IWMaZMWEMGRMqetyXMZ24wsybqQ7waPq5pkuQE(t2ROewaL70lpI7)7(dn6YtCpt)bckHaL(NfBoBJBjHfaPUBbKcL)OqP65poBa6LxXYlpI797(dn6YtCpt)rHs1ZFGQ3NuOu9K8fw(JVWsAuu6pkukKOKOEAe8lpIi7V7p0OlpX9m9hiOecu6FwS5S1zdqd9kg1cifkMqetGCbbzfkjfkzcBAcl2C26SbOHEfJAbeQwd2eIycl2C2cyhk15KtVLawaHQ1GnbMnbOILKuO0FuOu98hNna9YRy5LhXO839hA0LN4EM(deucbk9pi3eCaesPoNt8HC2CbO0YRyXeIycl2C2gtQud)eRJfqkumHiMqUaewuGqaRcLcjYeIycWyfWNWPmqHs1J6nbMnHB2O6pkuQE(tUauA5vS8YJyu97(dn6YtCpt)bckHaL(hKBcoacPeFiN9M1jUPPCrk7vucBcrmbySc4t4ugOqP6r9MaZMW12OYeIyc5cqyrbcbSkukKO)OqP65poXnnLlszVIs4xEeJIF3FOrxEI7z6pqqjeO0)GCtWbqiL6CoXhYzZfGslVIftiIjGCtixaclkqiGvHsHe9hfkvp)jxakT8kwE5r0L839hA0LN4EM(deucbk9pi3eCaesj(qo7nRtCtt5Iu2ROe(pkuQE(JtCtt5Iu2ROe(LhXBx97(dn6YtCpt)bckHaL(hrb8jXgtQxIToqXe2KHjS)vMqetqupnIftkOg(jPzHXwA0LN4(JcLQN)GHnag)YJ4TB)U)qJU8e3Z0FGGsiqP)rHsHeLOHqlcBcmBcx)hfkvp)HdO87bNwasL4xEeVD9V7p0OlpX9m9hiOecu6FCZee1tJyZEfLsoQaJT0OlpXzcrmbfkfsuIgcTiSjWSjCTj4QjWJNjOqPqIs0qOfHnbMnbK9pkuQE(t2ROewaL70lpI32)39hfkvp)jxaAPE)FOrxEI7z6LxE5pBvWudF8FqMI60aH4mHO0euOu9yc(clyR5YFWoe8rmk3)poGoxE6pidMaYmxqqwH4mHfLBazcWgDPIjSi(1GTMaYyqi5iyty6jQJvaAM1BckuQEWMqp(nSMlkuQEWwhabB0LkmYEf7U5IcLQhS1bqWgDPYDgiK7MZCrHs1d26aiyJUu5odeuw(O0iQu9yUOqP6bBDaeSrxQCNbckaQdLQriVNGI5IcLQhS1bqWgDPYDgiGh1bh3sclQGnxuOu9GToac2OlvUZab0caAqQqv(K5IcLQhS1bqWgDPYDgi40s1J5IcLQhS1bqWgDPYDgi4SbOxEflMlMlidMaYmxqqwH4mbcjcSHjifkzcsmzckuAGjuytqrslVU8K1CrHs1dMbSzhHayhY7nxqguOu9GVZabPqP0wf4eDLzifkX4Qil2C2U8DZ5zXILR3oMlkuQEW3zGaAbanivOkFk6kZyXMZwyJUyXs1JLR3oMlidMWr0HtbCMWo1tJycUeBxAtaz0MFbTMlkuQEW3zGaGDOuNto9wceDLzKlaHffieWQqPqIIOqP6Xcyhk15KtVLawySc4tygxZJhSBpxVDSWgDXILQhlGq1AWmV3vrwS5Sf2OlwSu9y56TteKlQNgX6EnC(A4BPrxEIJhprb8jXkfkLKoXv0M3UXJNOEAeR71W5RHVLgD5jUiUbJvaFcNYafkvpQN5B2OGhpPqPn37kxJa72Z1BhlSrxSyP6XciuTgmZ7DL5cYGj4sSDPnbwmzcBJlpzcS4A4BcU0BaAOxXOwZffkvp47mqaWouQZjNElbIUYmwS5S1zdqd9kg1cifkrCd2TNR3owyJUyXs1JfqOAnyM37kE8uOu9ybSdL6CYP3salmwb8jmZ3C1CrHs1d(odeGQ3NuOu9K8fwIEuuIbSrxSyP6j5eRyk6kZa2TNR3owyJUyXs1JfqOAn4nzOqP6Xcyhk15KtVLawOILKuO0D3qUOEAeR71W5RHVLgD5joxMpKZ1iUHCr90i2CbiSOaHawA0LN44Xd55cqyrbcbSkukKiE8uOuirjAi0IWmZypE8uOuirjAi0IWmZ46iI6PrSzVIsjhvGXwA0LN4CLhVfBoBHn6IflvpwwhZffkvp47mqaQEFsHs1tYxyj6rrjgG2j5eRyk6kZyXMZwa7qPoNC6TeWY6ezXMZwyJUyXs1JLR3oMlkuQEW3zGau9(KcLQNKVWs0JIsmWIoCkGlbArLQhZfZffkvpyRcLcjkjQNgbZy5vSK2QirrxzgUTyZzlSrxSyP6XY1Bhx5XZTfBoBHn6IflvpwwNikuQES5cqPLxXIfgRa(eEZBUAUOqP6bBvOuirjr90i47mqaLeQbrxzgWU9C92XcB0flwQESacvRbZ8ExXJNBWU9C92XcB0flwQESacvRbZSOa(KyLcLssN4kYvE8wS5SfWouQZjNElbSSo84LlaHffieWQqPqImxuOu9GTkukKOKOEAe8DgiWbu(9GtlaPsC0vMHOEAeR6jxGfGIDPuCkZc2WsJU8exeKVyZzBCljSai1DlGuOyUOqP6bBvOuirjr90i47mqWxivd)0QrxrxzgkukKOeneAryMVfzXMZwyJUyXs1JLR3oMlMlkuQEWwyJUyXs1tYjwXedFXpwWjK5SC8rPrIUYmwS5Sf2OlwSu9y56TJ5IcLQhSf2OlwSu9KCIvmDNbca2HsDo50Bjq0vMXInNTWgDXILQhlxVDmxuOu9GTWgDXILQNKtSIP7mqaQEFsHs1tYxyj6rrjgkukKOKOEAeS5IcLQhSf2OlwSu9KCIvmDNbcWgDXILQhZffkvpylSrxSyP6j5eRy6odeCAP6XCrHs1d2cB0flwQEsoXkMUZaHLVBUuMfSH5IcLQhSf2OlwSu9KCIvmDNbclcGjG71W3CrHs1d2cB0flwQEsoXkMUZaHCbOLVBoZffkvpylSrxSyP6j5eRy6ode0bsybO(eu9EZffkvpylSrxSyP6j5eRy6odeyXuQecfBUOqP6bBHn6IflvpjNyft3zGq2ROewaL7u0vMHBUjQNgXM9kkLCubgBPrxEIlIcLcjkrdHweM5RDLhpfkfsuIgcTimZrPRrwS5SnULewaK6UfqkumxuOu9GTWgDXILQNKtSIP7mqWzdqV8kwIUYmwS5S1zdqd9kg1cifkrwS5Sf2OlwSu9ybeQwdMzYfeKvOKuOK5IcLQhSf2OlwSu9KCIvmDNbcoBa6LxXs0vMXInNTXTKWcGu3TasHI5IcLQhSf2OlwSu9KCIvmDNbc5cqPLxXs0vMXInNTXKk1WpX6ybKcfZffkvpylSrxSyP6j5eRy6odeCIBAkxKYEfLWMlkuQEWwyJUyXs1tYjwX0DgiGHnaghDLzSyZzlSrxSyP6XciuTgmZqfljPqjZffkvpylSrxSyP6j5eRy6ode4ak)EWPfGujo6kZa5l2C2g3sclasD3cifkruOu9yZfGslVIflmwb8j8M3mxuOu9GTWgDXILQNKtSIP7mqadBamo6kZquaFsSXK6LyRdu2KX(xfrupnIftkOg(jPzHXwA0LN4mxmxuOu9GTG2j5eRyIbGDOuNto9wcyUOqP6bBbTtYjwX0DgiK9kkHfq5ofDLz4MBI6PrSzVIsjhvGXwA0LN4IOqPqIs0qOfHz(MR84PqPqIs0qOfHzEpxJSyZzBCljSai1DlGuOyUOqP6bBbTtYjwX0Dgi4SbOxEflrxzgl2C2g3sclasD3cifkMlkuQEWwq7KCIvmDNbcq17tkuQEs(clrpkkXqHsHeLe1tJGnxuOu9GTG2j5eRy6odeC2a0lVILORmJfBoBD2a0qVIrTasHseYfeKvOKuO0Ml2C26SbOHEfJAbeQwdoYInNTa2HsDo50BjGfqOAnyMHkwssHsMlkuQEWwq7KCIvmDNbc5cqPLxXs0vMbYDaesPoNt8HC2CbO0YRyjYInNTXKk1WpX6ybKcLi5cqyrbcbSkukKOiWyfWNWPmqHs1J6z(MnQmxuOu9GTG2j5eRy6odeCIBAkxKYEfLWrxzgi3bqiL4d5S3SoXnnLlszVIs4iWyfWNWPmqHs1J6z(ABufjxaclkqiGvHsHezUOqP6bBbTtYjwX0DgiKlaLwEflrxzgi3bqiL6CoXhYzZfGslVILiipxaclkqiGvHsHezUOqP6bBbTtYjwX0Dgi4e30uUiL9kkHJUYmqUdGqkXhYzVzDIBAkxKYEfLWMlkuQEWwq7KCIvmDNbcyydGXrxzgIc4tInMuVeBDGYMm2)QiI6PrSysb1Wpjnlm2sJU8eN5IcLQhSf0ojNyft3zGahq53doTaKkXrxzgkukKOeneAryMV2CrHs1d2cANKtSIP7mqi7vuclGYDk6kZWnr90i2SxrPKJkWyln6YtCruOuirjAi0IWmFTR84PqPqIs0qOfHzgznxuOu9GTG2j5eRy6odeYfGwQ3BUyUOqP6bBXIoCkGlbArLQhgzVIsybuUtrxzgU5MOEAeB2ROuYrfySLgD5jUikukKOeneAryMV5kpEkukKOeneAryM3Z1il2C2g3sclasD3cifkMlkuQEWwSOdNc4sGwuP65odeC2a0lVILORmJfBoBJBjHfaPUBbKcLil2C2g3sclasD3ciuTg8MkuQES5cql17TKliiRqjPqjZffkvpylw0HtbCjqlQu9CNbcoBa6LxXs0vMXInNTXTKWcGu3TasHsKCbiSOaHawfkfsueKlQNgXcyhk15KtVLawA0LN4mxuOu9GTyrhofWLaTOs1ZDgi4e30uUiL9kkHJUYmGXkGpHtzGcLQh1Z812OkIcLcjkrdHweM5RnxuOu9GTyrhofWLaTOs1ZDgi4SbOxEflrxzgl2C2g3sclasD3cifkrCd5oacPeFiN9M1zdqV8kw4XtHs1J1zdqV8kwS1KY(IFS4Q5IcLQhSfl6WPaUeOfvQEUZabNna9YRyj6kZyXMZ24wsybqQ7waPqjIOa(KyJj1lXwhOSjJ9VkIOEAelMuqn8tsZcJT0OlpXzUOqP6bBXIoCkGlbArLQN7mqWzdqV8kwIUYmwS5S1zdqd9kg1cifkrixqqwHssHsBUyZzRZgGg6vmQfqOAnyZffkvpylw0HtbCjqlQu9CNbcq17tkuQEs(clrpkkXqHsHeLe1tJGnxuOu9GTyrhofWLaTOs1ZDgiKlaLwEflrxzgixupnI19A481W3sJU8exKfBoBJjvQHFI1XcifkrCd5I6PrSa2HsDo50BjGLgD5joE8GXkGpHtzGcLQh1Z8n7E84b72Z1BhlSrxSyP6XciuTg8M7DLRrCB)OggRa(eoLbkuQEuVRUSB3U2LXoK3NIvSqUUjSBpxVDSWgDXILQhlGq1AW33Nhprb8jXkfkLKoXv0M7zUOqP6bBXIoCkGlbArLQN7mqixakT8kwIUYme1tJyDVgoFn8T0OlpXfzXMZ2ysLA4NyDSasHse3qUOEAelGDOuNto9wcyPrxEIJhpySc4t4ugOqP6r9mFZIS84b72Z1BhlSrxSyP6XciuTg8M7DLRrCB)OggRa(eoLbkuQEuVRUSB3Icxg7qEFkwXc56MWU9C92XcB0flwQESacvRbFFFE8efWNeRuOus6exrBUN5IcLQhSfl6WPaUeOfvQEUZabN4MMYfPSxrjC0vMHBl2C2cB0flwQESSo84TyZzlGDOuNto9wcyzD4XBXMZ2AG6ieaNY(ERflk0DM3Nhpr90iw0caAqQqv(KLgD5joxJ42Ernmwb8jCkduOu9OExD5B7VjSBpxVDSWgDXILQhlGq1AW3rwE8efWNeRuOus6exrBE7kZffkvpylw0HtbCjqlQu9CNbcoXnnLlszVIs4ORmd3wS5Sf2OlwSu9yzD4XBXMZwa7qPoNC6TeWY64Ae32lQHXkGpHtzGcLQh17QlV)vBc72Z1BhlSrxSyP6XciuTg8DK1CrHs1d2IfD4uaxc0Ikvp3zGGtCtt5Iu2ROeo6kZagRa(eoLbkuQEupZxBr2iWU9C92XcB0flwQESacvRbZ817BUOqP6bBXIoCkGlbArLQN7mqadBamo6kZWnrb8jXgtQxIToqztg7Fver90iwmPGA4NKMfgBPrxEIZvE8CtDPiqjK1bqXKkwA0LN4IWrl2C26aOysflxVDC1CrHs1d2IfD4uaxc0Ikvp3zGqUa0s9EZffkvpylw0HtbCjqlQu9CNbcyydGXV8Y)a]] )


end
