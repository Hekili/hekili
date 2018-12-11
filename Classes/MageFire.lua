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
        preheat = not PTR and {
            id = 273333,
            duration = 30,
            max_stack = 1,
        } or nil,

        blaster_master = {
            id = 274598,
            duration = 3,
            max_stack = 3,
        },

        wildfire = PTR and {
            id = 288800,
            duration = 10,
            max_stack = 1,
        } or nil,
    } )


    spec:RegisterStateTable( "firestarter", setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "active" then return talent.firestarter.enabled and target.health.pct > 90 end
        end, state )
    } ) )
    

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
        gcdSync = false,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "battle_potion_of_intellect",
        
        package = "Fire",
    } )


    spec:RegisterPack( "Fire", 20181211.0847, [[dyKTMbqirrpIKKAtq0OGKofjyvqcsVsuXSeL6wqcyxa)IKyyqGJPkAzIQQNbj00evLUMOQyBKKW3ijvnoss05GeuRJKuY8ev5EKO9Pk0bjjLkluuPhssQyIqccxesGYgjjv6KqcIwjj0nHei7uuYqjjjTussINIktvu4QqcuTxs9xQmybhMYIf5XGMmQ6YiBwHpRknAH60sTAssP8AiOztv3wvTBL(TKHlKJtskvTCvEoutN46kA7qOVtsnEirNxvW6jjfZhsTFuw)uNHMJ3esNv(rWtv5Z8)8jabQY8v1R5KhIinxKbrO9sAU1(KMt1TpsZfzp4lJxNHMdxZdsAUyrIWQwQOYBlXZeawFvW9F6nPRfE2qub3FOkjFLujnmuaEcrvIUA0EcRIQ6rQkwZJvrvvvXHcYEjNQBFea3FOMlnBVGc5QtAoEtiDw5hbpvLpZ)ZNaeGG8R6FMFnNnL460CC9F6nPRv15SHO5IBEEA1jnhpHHAovnlO62hXcOGSxIPOQMfIfjcRAPIkVTeptay9vb3)P3KUw4zdrfC)HQK8vsL0Wqb4jevj6Qr7jSkQQhPQynpwfvvvfhki7LCQU9raC)Hmfv1SakeeK(j6yHNpZMfYpcEQkzbuawabiq1k)5ltrMIQAwq1j22xcRAXuuvZcOaSak4yIfK(toPC8nXcNjX0XcsSTSGy3ljaP)KtkhFtSWOowWBybfatWA5zbl1(wEGfMy7LWanNVXcwNHMZGsJi5eZtRG1zOZ6PodnhTwYt86C1CWRf6AtZzqPrKC0s)MWSWJSWtwajlKMJbaw)0elDTa(s9YcizbuzbyvE(s9cG1pnXsxl4OV1lMfEKfGv55l1lW3i27Rlv)eGFEM01YcOrZcWQ88L6faRFAILUwWrg)dSGcAodkDTAoFJyVVUu9tArNv(1zO5O1sEIxNRMdETqxBAU0Cma3CjxnCrLA6aZiwajlGklm6JWIDcDGJ(wVyw4rwawLNVuVGpjuDa(5zsxllGgnlKjlm6JWIDcDadknIelOalGgnlaRYZxQxWnxYvdxuPMoWrFRxml8ili9NCs54BIfqYcgu6Ab3CjxnCrLA6aWy7EjmlKhl8KfqJMfqLfGv55l1l4tcvhGFEM01Yc5XcWQ88L6faRFAILUwWrFRxmlGgnlaRYZxQxaS(Pjw6Abhz8pWckWcizHmzbX80kGBUKRgUOsnDaATKN4zbKSaQSaSkpFPEbFsO6a8ZZKUwwipwy0hHf7e6ah9TEXSaA0SqMSGyEAfWOpcl2j0bO1sEINfqJMfYKfg9ryXoHoGbLgrIfuqZzqPRvZ9jHQtlArZjxViKeSodDwp1zO5mO01Q5MyY1c9XAoATKN415QfTO54PHn9IodDwp1zO5mO01Q5G1Cf6WrK3R5O1sEIxNRw0zLFDgAoATKN415Q5Gxl01MMlnhdaS(Pjw6Ab8L6vZzqPRvZ977QZ1F7L0IoluuNHMJwl5jEDUAo41cDTP5eZtRag9ryXoHoaTwYt8Saswy0hHf7e6ah9TEXSWJSWy69UJGX29soP)elGgnlaRYZxQxaS(Pjw6Abh9TEXSWJSaI21wYtay9ttS016UkYbNsngSaswinhdaS(Pjw6Ab8L6LfqJMfK(toPC8nXc5XcWQ88L6faRFAILUwWrFRxmlGKfsZXaaRFAILUwaFPE1Cgu6A1C3CjxnCrLA60IoR8vNHMJwl5jEDUAodkDTAoO59odkDToFJfnh8AHU20COYcI5Pva3CjxnCrLA6a0AjpXZcizbyvE(s9cG1pnXsxl4OV1lMfYtjlyqPRfCZLC1WfvQPdanS4K(tSaA0SaSkpFPEbW6NMyPRfCKX)alOalGKfYKfg9ryXoHoGbLgrIfqJMfsZXaaRFAILUwWmsZ5BS4w7tAoy9ttS016IInmPfDw5JodnhTwYt86C1Cgu6A1CqZ7Dgu6AD(glAo41cDTP5sZXaCZLC1WfvQPdmJybKSqAogay9ttS01c4l1RMZ3yXT2N0Cxf5IInmPfDwQcDgAoen)K0CI5Pva3CjxnCrLA6a0AjpXZcizbyvE(s9cU5sUA4Ik10bo6B9IzH8ybyvE(s9cg9rUK3Wcym9E3rWy7EjN0FIfqYcOYcWQ88L6faRFAILUwWrFRxml8ilGODTL8eaw)0elDTURICWPuJblGgnlm6JWIDcDadknIelOalGKfqLfGv55l1l4Ml5QHlQuth4OV1lMfYJfK(toPC8nXcOrZcgu6Ab3CjxnCrLA6aWy7Ejml8ilGawqbwanAwawLNVuVay9ttS01co6B9IzH8ybdkDTGrFKl5nSagtV3Dem2UxYj9NyHCybyvE(s9cg9rUK3WcGFEM01YcOqzbt1qxlei5nSqN7ByHoaTwYt8Saswitwy0hHf7e6aguAejwajlaRYZxQxaS(Pjw6Abh9TEXSqESG0FYjLJVjwanAwqmpTcy0hHf7e6a0AjpXZcizHrFewStOdyqPrKybKSWOpcl2j0bo6B9IzH8ybyvE(s9cg9rUK3Wcym9E3rWy7EjN0FIfYHfGv55l1ly0h5sEdla(5zsxllGcLfmvdDTqGK3WcDUVHf6a0AjpXR5O1sEIxNRMZGsxRMdr7Al5jnhI25w7tAUrFKl5nS4IQY37Rw0zP61zO5q08tsZjMNwbCZLC1WfvQPdqRL8eplGKfGv55l1l4Ml5QHlQuth4OV1lMfYJfGv55l1likUOTrPB4TpHbJP37ocgB3l5K(tSaswawLNVuVay9ttS01co6B9IzHhzbeTRTKNaW6NMyPR1DvKdoLAmybKSaQSaSkpFPEb3CjxnCrLA6ah9TEXSqESG0FYjLJVjwanAwWGsxl4Ml5QHlQuthagB3lHzHhzbeWckWcOrZcWQ88L6faRFAILUwWrFRxmlKhlyqPRfefx02O0n82NWGX07DhbJT7LCs)jwajlaRYZxQxaS(Pjw6Abh9TEXSqESG0FYjLJVjnhTwYt86C1Cgu6A1CiAxBjpP5q0o3AFsZffx02O0fvLV3xTOZsvQZqZrRL8eVoxnNbLUwnh08ENbLUwNVXIMZ3yXT2N0CyXwE74DxjM01QfTO5UkYffBysNHoRN6m0Cgu6A1C3CjxnCrLA60C0AjpXRZvl6SYVodnhTwYt86C1CWRf6AtZHklGkliMNwbm82NCrMaJb0AjpXZcizbdknIKJw63eMfEKfEYckWcOrZcguAejhT0Vjml8ilKVSGcSaswinhdqCjoSCKHqWrgu0Cgu6A1CdV9jSCncjTOZcf1zO5O1sEIxNRMdETqxBAU0CmaXL4WYrgcbhzqrZzqPRvZf9WvjVHfTOZkF1zO5O1sEIxNRMBIjN642toOHLEF1Cp1CWRf6AtZHklaRYZxQxaS(Pjw6Abh9TEXSWJSacyb0OzHrFewStOdyqPrKybKSqAogGBUKRgUOsnDGzelOalGKfqLfYKfsZXaetM07RBgboYGclGKfYKfsZXaexIdlhzieCKbfwajlKjleDeIUAmCVqEWOpYL8gwybKSaQSGbLUwWOpYL8gwaWy7Ejml8Oswi)SaA0SaQSGbLUwquCrBJs3WBFcdGX29syw4rLSWtwajliMNwbefx02O0n82NWaATKN4zbfyb0OzbuzbX80kaZtOelNHvng2nM3daATKN4zbKSaSkpFPEb8N9wl2LoYKyWrg)dSGcSaA0SaQSGyEAfaMSR3xNutymGwl5jEwajli29sciMmVedIGclKNswafralOalGgnlGkliMNwbm6JWIDcDaATKN4zbKSWOpcl2j0bmO0isSGcSGcSGcAUjMC1y4EH8AUNAodkDTAUrFKl5nSOfDw5JodnhTwYt86C1Cgu6A1CqZ7Dgu6AD(glAoFJf3AFsZzqPrKCI5PvWArNLQqNHMJwl5jEDUAo41cDTP5sZXae9WvqVH)GJmOWcizbOHfN0FIfYJfsZXae9WvqVH)GJ(wVywajlKMJb4Ml5QHlQuth4OV1lMfEKfGgwCs)jnNbLUwnx0dxL8gw0IolvVodnhTwYt86C1Ctm5uh3EYbnS07RM7PMdETqxBAouzbyvE(s9cG1pnXsxl4OV1lMfEKfqalGgnlm6JWIDcDadknIelGKfsZXaCZLC1WfvQPdmJybfybKSaQSqAogGyYKEFDZiWrguybKSaQSGy3ljGyY8smickSWJkzbuebSaA0SqMSGyEAfaMSR3xNutymGwl5jEwqbwqbn3etUAmCVqEn3tnNbLUwn3OpYL8gw0IolvPodnhTwYt86C1Ctm5uh3EYbnS07RM7PMdETqxBAouzbyvE(s9cG1pnXsxl4OV1lMfEKfqalGgnlm6JWIDcDadknIelGKfsZXaCZLC1WfvQPdmJybfybKSGyEAfaMSR3xNutymGwl5jEwajli29sciMmVedIGclKNswafralGKfqLfsZXaetM07RBgboYGclGKfYKfmO01cWW6GXacLeCk9(YcOrZczYcP5yaIjt691nJahzqHfqYczYcP5yaIlXHLJmecoYGclOGMBIjxngUxiVM7PMZGsxRMB0h5sEdlArNfkSodnhTwYt86C1CWRf6AtZfDeIUxip4jadRdgZcizH0CmaXKj9(6MrGzelGKfeZtRaWKD9(6KAcJb0AjpXZcizbXUxsaXK5LyqeuyH8uYcOicybKSaQSqMSGyEAfWWBFYfzcmgqRL8eplGgnlyqPrKC0s)MWSGsw4jlOGMZGsxRMl6HRsEdlArN1teOZqZrRL8eVoxnh8AHU20CzYcrhHO7fYdEcIIlABu6gE7tywajlKMJbiMmP3x3mcCKbfnNbLUwnxuCrBJs3WBFcRfDwpFQZqZrRL8eVoxnh8AHU20CIDVKaIjZlXGiOWc5PKfqreWcizbX80kamzxVVoPMWyaTwYt8AodkDTAomSoySw0z9m)6m0C0AjpXRZvZbVwORnnNbLgrYrl9BcZcpYc5xZzqPRvZXF2BTyx6itI1IoRNOOodnhTwYt86C1CWRf6AtZHkliMNwbm82NCrMaJb0AjpXZcizbdknIKJw63eMfEKfYplOalGgnlyqPrKC0s)MWSWJSq(O5mO01Q5gE7ty5AesArN1Z8vNHMZGsxRMB0hLmVxZrRL8eVoxTOfnhS(Pjw6ADrXgM0zOZ6PodnhTwYt86C1CWRf6AtZLMJbaw)0elDTa(s9Q5mO01Q589BSGDQ2M8VFAfTOZk)6m0C0AjpXRZvZzqPRvZbnV3zqPR15BSO5Gxl01MMZun01cbsEdl05(gwOdqRL8eplGKfeZtRagE7tUAb0AjpXR58nwCR9jnx67G1pnXsxRlk2WKw0zHI6m0C0AjpXRZvZbVwORnnxAogay9ttS01c4l1RMZGsxRM7Ml5QHlQutNw0zLV6m0C0AjpXRZvZzqPRvZbnV3zqPR15BSO58nwCR9jnNbLgrYjMNwbRfDw5JodnhTwYt86C1Ctm5uh3EYbnS07RM7PMdETqxBAouzHmzbt1qxlei5nSqN7ByHoaTwYt8SaA0SqMSGyEAfWWBFYvlGwl5jEwqbwajlGklGklyqPRf8jHQd0RB473yHfqYcgu6AbFsO6a96g((nwCh9TEXSqEkzbeaYhwqbwanAwitwqmpTc4tcvhGwl5jEwqbwajlGklKMJb4Ml5QHlQuthygXcOrZczYcI5Pva3CjxnCrLA6a0AjpXZckO5MyYvJH7fYR5EQ5mO01Q5G1pnXsxRw0zPk0zO5mO01Q5IkPRvZrRL8eVoxTOZs1RZqZzqPRvZL8vX7gZ7bnhTwYt86C1IolvPodnNbLUwnxIomDiS3xnhTwYt86C1IoluyDgAodkDTAUrFuYxfVMJwl5jEDUArN1teOZqZzqPRvZzlKWYzEh08EnhTwYt86C1IoRNp1zO5O1sEIxNRMZGsxRMdAEVZGsxRZ3yrZ5BS4w7tAo56fHKG1IoRN5xNHMJwl5jEDUAo41cDTP5qLfqLfeZtRagE7tUitGXaATKN4zbKSGbLgrYrl9BcZcpYc5NfuGfqJMfmO0isoAPFtyw4rwqvWckWcizH0CmaXL4WYrgcbhzqrZzqPRvZn82NWY1iK0IoRNOOodnhTwYt86C1CWRf6AtZLMJbi6HRGEd)bhzqHfqYcP5yaG1pnXsxl4OV1lMfEKfGgwCs)jnNbLUwnx0dxL8gw0IoRN5RodnhTwYt86C1CWRf6AtZLMJbiUehwoYqi4idkAodkDTAUOhUk5nSOfDwpZhDgAoATKN415Q5MyYPoU9KdAyP3xn3tnh8AHU20COYczYcMQHUwiqYByHo33WcDaATKN4zb0OzHmzbX80kGH3(KRwaTwYt8SGcSaswavwavwinhdaS(Pjw6AbZiwajlGklKMJbiMmP3x3mcCKbfwajlKjlyqPRfe9WvjVHfqVUHVFJfwajlKjlyqPRfGH1bJbekj4u69LfuGfqJMfqLfmO01cWW6GXacLeCkK7OV1lMfqYcP5yaIjt691nJa8L6LfqYcP5yaIlXHLJmec4l1llGKfYKfmO01cIE4QK3WcOx3W3VXclOalOalOGMBIjxngUxiVM7PMZGsxRMB0h5sEdlArN1tvHodnhTwYt86C1CWRf6AtZfDeIUxip4jadRdgZcizH0CmaXKj9(6MrGzKMZGsxRMl6HRsEdlArN1tvVodnNbLUwnxuCrBJs3WBFcR5O1sEIxNRw0z9uvQZqZrRL8eVoxnh8AHU20CP5yaG1pnXsxl4OV1lMfEKfGgwCs)jwajlKMJbaw)0elDTGzelGgnlKMJbaw)0elDTa(s9Q5mO01Q5WW6GXArN1tuyDgAoATKN415Q5Gxl01MMlnhdaS(Pjw6Abh9TEXSqESWlKh8nuYcizbdknIKJw63eMfEKfEQ5mO01Q58nI9(6s1pPfDw5hb6m0C0AjpXRZvZbVwORnnxAogay9ttS01co6B9IzH8yHxip4BOKfqYcP5yaG1pnXsxlygP5mO01Q54p7TwSlDKjXArNv(FQZqZrRL8eVoxnh8AHU20CIDVKaIjZlXGiOWc5PKfqreWcizbX80kamzxVVoPMWyaTwYt8AodkDTAomSoySw0IMl9DW6NMyPR1ffBysNHoRN6m0C0AjpXRZvZbVwORnnxAogay9ttS01c4l1RMZGsxRMZ3VXc2PABY)(Pv0IoR8RZqZrRL8eVoxnh8AHU20CP5yaG1pnXsxlGVuVSaswWGsJi5OL(nHzHhzHNAodkDTAoFJyVVUu9tArNfkQZqZrRL8eVoxnh8AHU20CP5yaG1pnXsxlGVuVAodkDTAUBUKRgUOsnDArNv(QZqZrRL8eVoxn3eto1XTNCqdl9(Q5EQ5mO01Q5g9rUK3WIMdETqxBAU0CmajVHf6CFdl0b4l1llGKfqLfeZtRaU5sUA4Ik10bO1sEINfqYcgu6Ab3CjxnCrLA6aekj4u69LfqYcgu6Ab3CjxnCrLA6aekj4ui3rFRxmlKhlGaGQGfqJMfqLfGv55l1law)0elDTGJm(hyb0OzH0CmaW6NMyPRfmJybfybKSqMSGyEAfWnxYvdxuPMoaTwYt8SaswitwWGsxli6HRsEdlGEDdF)glSaswitwWGsxly0hLmVh0RB473yHfuql6SYhDgAoATKN415Q5mO01Q5GM37mO0168nw0C(glU1(KMZGsJi5eZtRG1IolvHodnhTwYt86C1Ctm5uh3EYbnS07RM7PMdETqxBAot1qxlei5nSqN7ByHoaTwYt8SaswavwavwWGsxl4tcvhOx3W3VXclGKfmO01c(Kq1b61n89BS4o6B9IzH8ybeaYplOalGgnlKjliMNwb8jHQdqRL8eplGgnleDeIUxip4j4tcvhlOalGKfqLfsZXaCZLC1WfvQPdmJyb0OzHmzbX80kGBUKRgUOsnDaATKN4zbf0Ctm5QXW9c51Cp1Cgu6A1CW6NMyPRvl6Su96m0Cgu6A1CrL01Q5O1sEIxNRw0zPk1zO5mO01Q5s(Q4DJ59GMJwl5jEDUArNfkSodnNbLUwnxIomDiS3xnhTwYt86C1IoRNiqNHMZGsxRMB0hL8vXR5O1sEIxNRw0z98PodnNbLUwnNTqclN5DqZ71C0AjpXRZvl6SEMFDgAoATKN415Q5mO01Q5GM37mO0168nw0C(glU1(KMtUErijyTOZ6jkQZqZrRL8eVoxnh8AHU20CrhHO7fYdEcWW6GXSaswinhdqmzsVVUzeygP5mO01Q5IE4QK3WIw0z9mF1zO5O1sEIxNRMdETqxBAU0CmaXL4WYrgcbZinNbLUwnx0dxL8gw0IoRN5JodnhTwYt86C1CWRf6AtZLMJbi6HRGEd)bhzqHfqYcqdloP)elKhlKMJbaw)0elDTGJ(wVynNbLUwnx0dxL8gw0IoRNQcDgAodkDTAUO4I2gLUH3(ewZrRL8eVoxTOZ6PQxNHMBIjxngUxiVM7PMJwl5jEDUAo41cDTP5sZXaK8gwOZ9nSqhalgeHSGsw4jlGKfsZXaexIdlhzieWxQxwajlKjlKMJbi6HRGEd)bhzqHfqYcrhHO7fYdEcIE4QK3WclGKfqLfsZXaK8gwOZ9nSqh4OV1lMfYJfqa4z(WcOrZcVqEWrFRxmlKhlGaWZ8HfuqZzqPRvZn6JCjVHfTOZ6PQuNHMJwl5jEDUAUjMCQJBp5Ggw69vZ9uZzqPRvZn6JCjVHfnh8AHU20CP5yasEdl05(gwOdGfdIqwqjl8KfqYcOYcgu6AbyyDWyaHscoLEFzbKSGbLUwagwhmgqOKGtHCh9TEXSqESacapZhwanAwinhdqYByHo33WcDGJ(wVywipwabGN5dlOGw0z9efwNHMJwl5jEDUAo41cDTP5sZXaexIdlhzieWxQxwajlGklaRYZxQxWOpYL8gwah9TEXSqESa0WIt6pXcOrZcgu6AbJ(ixYBybaJT7LWSWJSacybf0Cgu6A1CyyDWyTOZk)iqNHMJwl5jEDUAUjMCQJBp5Ggw69vZ9uZbVwORnnxAogGK3WcDUVHf6ayXGiKfEKfEYcizbuzHOJq09c5bpbyyDWywajlKjlKMJbiUehwoYqiygXcizHmzbdkDTamSoymGqjbNsVVSaA0SqAogGK3WcDUVHf6ah9TEXSqESacapZhwqbn3etUAmCVqEn3tnNbLUwn3OpYL8gw0IoR8)uNHMJwl5jEDUAo41cDTP5sZXaaRFAILUwWrFRxmlKhl8c5bFdLSaswWGsJi5OL(nHzHhzHNAodkDTAoFJyVVUu9tArNv(ZVodnhTwYt86C1CWRf6AtZLMJbaw)0elDTGJ(wVywipw4fYd(gk1Cgu6A1C8N9wl2LoYKyTOZk)OOodnNbLUwnhgwhmwZrRL8eVoxTOfnhwSL3oE3vIjDT6m0z9uNHMJwl5jEDUAo41cDTP5qLfqLfeZtRagE7tUitGXaATKN4zbKSGbLgrYrl9BcZcpYcpzbKSqMSWOpcl2j0bmO0isSGcSaA0SGbLgrYrl9BcZcpYc5llOalGKfsZXaexIdlhzieCKbfnNbLUwn3WBFclxJqsl6SYVodnhTwYt86C1CWRf6AtZLMJbiUehwoYqi4idkSaswinhdqCjoSCKHqWrFRxmlKhlyqPRfm6JsM3diusWPqoP)KMZGsxRMl6HRsEdlArNfkQZqZrRL8eVoxnh8AHU20CP5yaIlXHLJmecoYGclGKfqLfIocr3lKh8em6JsM3ZcOrZcJ(iSyNqhWGsJiXcOrZcgu6AbrpCvYByb0RB473yHfuqZzqPRvZf9WvjVHfTOZkF1zO5O1sEIxNRMdETqxBAU0CmaXL4WYrgcbhzqHfqYcIDVKaIjZlXGiOWc5PKfqreWcizbX80kamzxVVoPMWyaTwYt8AodkDTAUOhUk5nSOfDw5JodnhTwYt86C1CWRf6AtZLMJbi6HRGEd)bhzqHfqYcqdloP)elKhlKMJbi6HRGEd)bh9TEXAodkDTAUOhUk5nSOfDwQcDgAoATKN415Q5MyYPoU9KdAyP3xn3tnh8AHU20COYcWQ88L6faRFAILUwWrFRxml8ilGawajlKMJb4Ml5QHlQuthGVuVSaA0SWOpcl2j0bmO0isSGcSaswitwqmpTcaH9Y779fqRL8eplGKfYKfq0U2sEcm6JCjVHfxuv(EFzbKSaQSaQSaQSGbLUwWOpkzEpGqjbNsVVSaA0SGbLUwq0dxL8gwaekj4u69LfuGfqYcOYcP5yaIjt691nJahzqHfqJMfg9ryXoHoGbLgrIfqYczYcP5yaIlXHLJmecoYGclGKfYKfsZXaetM07RBgboYGclOalOalGgnlGkliMNwbGj7691j1egdO1sEINfqYcIDVKaIjZlXGiOWc5PKfqreWcizbuzH0CmaXKj9(6MrGJmOWcizHmzbdkDTamSoymGqjbNsVVSaA0SqMSqAogG4sCy5idHGJmOWcizHmzH0CmaXKj9(6MrGJmOWcizbdkDTamSoymGqjbNsVVSaswitwWGsxli6HRsEdlGEDdF)glSaswitwWGsxly0hLmVh0RB473yHfuGfuGfqJMfqLfg9ryXoHoGbLgrIfqYcOYcgu6AbrpCvYByb0RB473yHfqJMfmO01cg9rjZ7b96g((nwybfybKSqMSqAogGyYKEFDZiWrguybKSqMSqAogG4sCy5idHGJmOWckWckO5MyYvJH7fYR5EQ5mO01Q5g9rUK3WIw0zP61zO5O1sEIxNRMdETqxBAoX80kae2lVV3xaTwYt8SaswinhdqmzsVVUze4idkSaswavwawLNVuVay9ttS01co6B9IzHhzHX07DhbJT7LCs)jwihwi)SqoSGyEAfac7L337lGwl5jEwanAwy0hHf7e6ah9TEXSWJSWy69UJGX29soP)elGgnlGklKjliMNwbCZLC1WfvQPdqRL8eplGgnlaRYZxQxWnxYvdxuPMoWrFRxml8ili9NCs54BIfqYcgu6Ab3CjxnCrLA6aWy7EjmlKhl8KfuGfqYcWQ88L6faRFAILUwWrFRxml8ili9NCs54BIfuqZzqPRvZn6JCjVHfTOZsvQZqZrRL8eVoxnh8AHU20CrhHO7fYdEcWW6GXSaswinhdqmzsVVUzeygXcizbX80kamzxVVoPMWyaTwYt8SaswqS7LeqmzEjgebfwipLSakIawajlGklGkliMNwbm82NCrMaJb0AjpXZcizbdknIKJw63eMfuYcpzbKSqMSWOpcl2j0bmO0isSGcSaA0SaQSGbLgrYrl9BcZc5Xc5llGKfYKfeZtRagE7tUitGXaATKN4zbfybf0Cgu6A1CrpCvYByrl6SqH1zO5O1sEIxNRMdETqxBAouzH0CmaXKj9(6MrGJmOWcOrZcOYczYcP5yaIlXHLJmecoYGclGKfqLfmO01cg9rUK3WcagB3lHzHhzbeWcOrZcI5PvayYUEFDsnHXaATKN4zbKSGy3ljGyY8smickSqEkzbuebSGcSGcSGcSaswitwar7Al5jquCrBJsxuv(EF1Cgu6A1CrXfTnkDdV9jSw0z9eb6m0C0AjpXRZvZzqPRvZbnV3zqPR15BSO58nwCR9jnNbLgrYjMNwbRfDwpFQZqZrRL8eVoxnh8AHU20CguAejhT0Vjml8il8uZzqPRvZXF2BTyx6itI1IoRN5xNHMJwl5jEDUAo41cDTP5e7EjbetMxIbrqHfYtjlGIiGfqYcI5PvayYUEFDsnHXaATKN41Cgu6A1CyyDWyTOZ6jkQZqZzqPRvZn6JsM3R5O1sEIxNRw0z9mF1zO5mO01Q5WW6GXAoATKN415QfTO5Iocw)Kj6m0z9uNHMJwl5jEDUArNv(1zO5O1sEIxNRw0zHI6m0C0AjpXRZvl6SYxDgAodkDTAo7G2sUEfY7jOO5O1sEIxNRw0zLp6m0C0AjpXRZvZvrAomjAodkDTAoeTRTKN0CiA(jP5ufiqZHODU1(KMdw)0elDTURICWPuJHw0zPk0zO5O1sEIxNRw0zP61zO5mO01Q5(9D156V9sAoATKN415QfDwQsDgAodkDTAUOs6A1C0AjpXRZvl6SqH1zO5mO01Q5IE4QK3WIMJwl5jEDUArlArZHiD4UwDw5hbpvLiafgfra4PQhb5RMtTDBVVynhkK)O6eINfuLSGbLUwwW3ybdykQ5WreuNLQaf1CrxnApP5u1SGQBFelGcYEjMIQAwiwKiSQLkQ82s8mbG1xfC)NEt6AHNnevW9hQsYxjvsddfGNquLORgTNWQOQEKQI18yvuvvvCOGSxYP62hbW9hYuuvZcOqqq6NOJfE(mBwi)i4PQKfqbybeGavR8NVmfzkQQzbvNyBFjSQftrvnlGcWcOGJjwq6p5KYX3elCMethliX2YcIDVKaK(toPC8nXcJ6ybVHfuambRLNfSu7B5bwyITxcdykYuuvZcOGHscofINfs0OoIfG1pzclKO3EXawq1oiKIemlS1IceB3Fm9SGbLUwmluR)batrdkDTyq0rW6Nmr5WByeYu0GsxlgeDeS(jtYrPkJQ4zkAqPRfdIocw)Kj5OufB((PvmPRLPObLUwmi6iy9tMKJsvSdAl56viVNGctrvnlKrCJzbeTRTKNybmjywqIjwq6pXcMWcQJBymlOQmxIfQblOQwQPJfWX10ZZcyXoHfsuVVSa2qK4zHrDSGetSWsOuybvN6NMyPRLfIInmXu0GsxlgeDeS(jtYrPkiAxBjpL9AFsjS(Pjw6ADxf5GtPgJSRiLysYgrZpjLQceWu0GsxlgeDeS(jtYrPk41IWXL4WIjyMIgu6AXGOJG1pzsokv533vNR)2lXu0GsxlgeDeS(jtYrPkrL01Yu0GsxlgeDeS(jtYrPkrpCvYByHPitrvnlGcgkj4uiEwGqKUhybP)eliXelyqPowOXSGHO1El5jatrdkDTyLWAUcD4iY7zkAqPRfNJsv(9D156V9sz3dLP5yaG1pnXsxlGVuVmfnO01IZrPk3CjxnCrLA6YUhkfZtRag9ryXoHoaTwYt8ih9ryXoHoWrFRx8JJP37ocgB3l5K(tOrdRYZxQxaS(Pjw6Abh9TEXpIODTL8eaw)0elDTURICWPuJbY0CmaW6NMyPRfWxQx0OL(toPC8nLhSkpFPEbW6NMyPRfC036fJmnhdaS(Pjw6Ab8L6LPObLUwCokvbAEVZGsxRZ3yj71(Ksy9ttS016IInmLDpuIQyEAfWnxYvdxuPMoaTwYt8iHv55l1law)0elDTGJ(wV48uAqPRfCZLC1WfvQPdanS4K(tOrdRYZxQxaS(Pjw6Abhz8pOaYmh9ryXoHoGbLgrcn60CmaW6NMyPRfmJykAqPRfNJsvGM37mO0168nwYETpP8QixuSHPS7HY0Cma3CjxnCrLA6aZiKP5yaG1pnXsxlGVuVmfnO01IZrPkiAxBjpL9AFs5OpYL8gwCrv579nBen)KukMNwbCZLC1WfvQPdqRL8epsyvE(s9cU5sUA4Ik10bo6B9IZdwLNVuVGrFKl5nSagtV3Dem2UxYj9NqIkSkpFPEbW6NMyPRfC036f)iI21wYtay9ttS016UkYbNsngOrp6JWIDcDadknIKcirfwLNVuVGBUKRgUOsnDGJ(wV48K(toPC8nHgTbLUwWnxYvdxuPMoam2Uxc)icuanAyvE(s9cG1pnXsxl4OV1lopdkDTGrFKl5nSagtV3Dem2UxYj9NYbwLNVuVGrFKl5nSa4NNjDTOqnvdDTqGK3WcDUVHf6a0AjpXJmZrFewStOdyqPrKqcRYZxQxaS(Pjw6Abh9TEX5j9NCs54BcnAX80kGrFewStOdqRL8epYrFewStOdyqPrKqo6JWIDcDGJ(wV48Gv55l1ly0h5sEdlGX07DhbJT7LCs)PCGv55l1ly0h5sEdla(5zsxlkut1qxlei5nSqN7ByHoaTwYt8mfnO01IZrPkiAxBjpL9AFszuCrBJsxuv(EFZgrZpjLI5Pva3CjxnCrLA6a0AjpXJewLNVuVGBUKRgUOsnDGJ(wV48Gv55l1likUOTrPB4TpHbJP37ocgB3l5K(tiHv55l1law)0elDTGJ(wV4hr0U2sEcaRFAILUw3vro4uQXajQWQ88L6fCZLC1WfvQPdC036fNN0FYjLJVj0OnO01cU5sUA4Ik10bGX29s4hrGcOrdRYZxQxaS(Pjw6Abh9TEX5zqPRfefx02O0n82NWGX07DhbJT7LCs)jKWQ88L6faRFAILUwWrFRxCEs)jNuo(MykAqPRfNJsvGM37mO0168nwYETpPel2YBhV7kXKUwMImfnO01IbguAejNyEAfSsFJyVVUu9tz3dLguAejhT0Vj8JprMMJbaw)0elDTa(s9IevyvE(s9cG1pnXsxl4OV1l(ryvE(s9c8nI9(6s1pb4NNjDTOrdRYZxQxaS(Pjw6Abhz8pOatrdkDTyGbLgrYjMNwbNJsv(Kq1LDpuMMJb4Ml5QHlQuthygHe1rFewStOdC036f)iSkpFPEbFsO6a8ZZKUw0OZC0hHf7e6aguAejfqJgwLNVuVGBUKRgUOsnDGJ(wV4hL(toPC8nH0Gsxl4Ml5QHlQuthagB3lHZ7jA0OcRYZxQxWNeQoa)8mPRnpyvE(s9cG1pnXsxl4OV1lgnAyvE(s9cG1pnXsxl4iJ)bfqMPyEAfWnxYvdxuPMoaTwYt8irfwLNVuVGpjuDa(5zsxBEJ(iSyNqh4OV1lgn6mfZtRag9ryXoHoaTwYt8OrN5Opcl2j0bmO0iskWuKPObLUwmi9DW6NMyPR1ffBysPVFJfSt12K)9tRKDpuMMJbaw)0elDTa(s9Yu0GsxlgK(oy9ttS016IInmLJsv8nI9(6s1pLDpuMMJbaw)0elDTa(s9I0GsJi5OL(nHF8jtrdkDTyq67G1pnXsxRlk2Wuokv5Ml5QHlQutx29qzAogay9ttS01c4l1ltrdkDTyq67G1pnXsxRlk2Wuokvz0h5sEdlzpXKtDC7jh0WsVVkFMDpuMMJbi5nSqN7ByHoaFPErIQyEAfWnxYvdxuPMoaTwYt8inO01cU5sUA4Ik10biusWP07lsdkDTGBUKRgUOsnDacLeCkK7OV1lopeaufOrJkSkpFPEbW6NMyPRfCKX)aA0P5yaG1pnXsxlygPaYmfZtRaU5sUA4Ik10bO1sEIhzMgu6AbrpCvYByb0RB473ybzMgu6AbJ(OK59GEDdF)glkWu0GsxlgK(oy9ttS016IInmLJsvGM37mO0168nwYETpP0GsJi5eZtRGzkAqPRfdsFhS(Pjw6ADrXgMYrPkW6NMyPRn7jMC1y4EH8kFM9eto1XTNCqdl9(Q8z29qPPAORfcK8gwOZ9nSqhGwl5jEKOIQbLUwWNeQoqVUHVFJfKgu6AbFsO6a96g((nwCh9TEX5Haq(van6mfZtRa(Kq1bO1sEIhn6OJq09c5bpbFsO6uajQP5yaU5sUA4Ik10bMrOrNPyEAfWnxYvdxuPMoaTwYt8kWu0GsxlgK(oy9ttS016IInmLJsvIkPRLPObLUwmi9DW6NMyPR1ffBykhLQK8vX7gZ7bMIgu6AXG03bRFAILUwxuSHPCuQsIomDiS3xMIgu6AXG03bRFAILUwxuSHPCuQYOpk5RINPObLUwmi9DW6NMyPR1ffBykhLQylKWYzEh08EMIgu6AXG03bRFAILUwxuSHPCuQc08ENbLUwNVXs2R9jLY1lcjbZu0GsxlgK(oy9ttS016IInmLJsvIE4QK3Ws29qz0ri6EH8GNamSoymY0CmaXKj9(6MrGzetrdkDTyq67G1pnXsxRlk2Wuokvj6HRsEdlz3dLP5yaIlXHLJmecMrmfnO01IbPVdw)0elDTUOydt5OuLOhUk5nSKDpuMMJbi6HRGEd)bhzqbj0WIt6pLxAogay9ttS01co6B9IzkAqPRfdsFhS(Pjw6ADrXgMYrPkrXfTnkDdV9jmtrdkDTyq67G1pnXsxRlk2Wuokvz0h5sEdlzpXKRgd3lKx5ZS7HY0CmajVHf6CFdl0bWIbrOYNitZXaexIdlhzieWxQxKzMMJbi6HRGEd)bhzqbz0ri6EH8GNGOhUk5nSGe10CmajVHf6CFdl0bo6B9IZdbGN5dA0VqEWrFRxCEia8mFuGPObLUwmi9DW6NMyPR1ffBykhLQm6JCjVHLSNyYPoU9KdAyP3xLpZUhktZXaK8gwOZ9nSqhalgeHkFIevdkDTamSoymGqjbNsVVinO01cWW6GXacLeCkK7OV1lopeaEMpOrNMJbi5nSqN7ByHoWrFRxCEia8mFuGPObLUwmi9DW6NMyPR1ffBykhLQGH1bJZUhktZXaexIdlhzieWxQxKOcRYZxQxWOpYL8gwah9TEX5bnS4K(tOrBqPRfm6JCjVHfam2Uxc)icuGPObLUwmi9DW6NMyPR1ffBykhLQm6JCjVHLSNyYPoU9KdAyP3xLpZEIjxngUxiVYNz3dLP5yasEdl05(gwOdGfdIWhFIe1OJq09c5bpbyyDWyKzMMJbiUehwoYqiygHmtdkDTamSoymGqjbNsVVOrNMJbi5nSqN7ByHoWrFRxCEia8mFuGPObLUwmi9DW6NMyPR1ffBykhLQ4Be791LQFk7EOmnhdaS(Pjw6Abh9TEX59c5bFdLinO0isoAPFt4hFYu0GsxlgK(oy9ttS016IInmLJsv4p7TwSlDKjXz3dLP5yaG1pnXsxl4OV1loVxip4BOKPObLUwmi9DW6NMyPR1ffBykhLQGH1bJzkYuuvZcQo1pnXsxllefByIfIokYocZcwQ9T0eMfu3smlySap5ThYMfKyAzbVnxymHzHELIfKyIfuDQFAILUwwatQ2pPfsmfnO01IbW6NMyPR1ffBysPVFJfSt12K)9tRKDpuMMJbaw)0elDTa(s9Yu0GsxlgaRFAILUwxuSHPCuQc08ENbLUwNVXs2R9jLPVdw)0elDTUOydtz3dLMQHUwiqYByHo33WcDaATKN4rkMNwbm82NC1cO1sEINPObLUwmaw)0elDTUOydt5OuLBUKRgUOsnDz3dLP5yaG1pnXsxlGVuVmfnO01IbW6NMyPR1ffBykhLQanV3zqPR15BSK9AFsPbLgrYjMNwbZu0GsxlgaRFAILUwxuSHPCuQcS(Pjw6AZEIjxngUxiVYNzpXKtDC7jh0WsVVkFMDpuIAMMQHUwiqYByHo33WcDaATKN4rJotX80kGH3(KRwaTwYt8kGevunO01c(Kq1b61n89BSG0Gsxl4tcvhOx3W3VXI7OV1lopLiaKpkGgDMI5PvaFsO6a0AjpXRasutZXaCZLC1WfvQPdmJqJotX80kGBUKRgUOsnDaATKN4vGPObLUwmaw)0elDTUOydt5OuLOs6AzkAqPRfdG1pnXsxRlk2Wuokvj5RI3nM3dmfnO01IbW6NMyPR1ffBykhLQKOdthc79LPObLUwmaw)0elDTUOydt5OuLrFuYxfptrdkDTyaS(Pjw6ADrXgMYrPk2cjSCM3bnVNPObLUwmaw)0elDTUOydt5OufO59odkDToFJLSx7tkLRxescMPObLUwmaw)0elDTUOydt5OuLH3(ewUgHu29qjQOkMNwbm82NCrMaJb0AjpXJ0GsJi5OL(nHFm)kGgTbLgrYrl9Bc)OQqbKP5yaIlXHLJmecoYGctrdkDTyaS(Pjw6ADrXgMYrPkrpCvYByj7EOmnhdq0dxb9g(doYGcY0CmaW6NMyPRfC036f)i0WIt6pXu0GsxlgaRFAILUwxuSHPCuQs0dxL8gwYUhktZXaexIdlhzieCKbfMIgu6AXay9ttS016IInmLJsvg9rUK3Ws2tm5QXW9c5v(m7jMCQJBp5Ggw69v5ZS7HsuZ0un01cbsEdl05(gwOdqRL8epA0zkMNwbm82NC1cO1sEIxbKOIAAogay9ttS01cMrirnnhdqmzsVVUze4idkiZ0Gsxli6HRsEdlGEDdF)gliZ0GsxladRdgdiusWP07RcOrJQbLUwagwhmgqOKGtHCh9TEXitZXaetM07RBgb4l1lY0CmaXL4WYrgcb8L6fzMgu6AbrpCvYByb0RB473yrbfuGPObLUwmaw)0elDTUOydt5OuLOhUk5nSKDpugDeIUxip4jadRdgJmnhdqmzsVVUzeygXu0GsxlgaRFAILUwxuSHPCuQsuCrBJs3WBFcZu0GsxlgaRFAILUwxuSHPCuQcgwhmo7EOmnhdaS(Pjw6Abh9TEXpcnS4K(titZXaaRFAILUwWmcn60CmaW6NMyPRfWxQxMIgu6AXay9ttS016IInmLJsv8nI9(6s1pLDpuMMJbaw)0elDTGJ(wV48EH8GVHsKguAejhT0Vj8JpzkAqPRfdG1pnXsxRlk2WuokvH)S3AXU0rMeNDpuMMJbaw)0elDTGJ(wV48EH8GVHsKP5yaG1pnXsxlygXu0GsxlgaRFAILUwxuSHPCuQcgwhmo7EOuS7LeqmzEjgebL8uIIiaPyEAfaMSR3xNutymGwl5jEMImfnO01Ibxf5IInmP8Ml5QHlQuthtrdkDTyWvrUOydt5OuLH3(ewUgHu29qjQOkMNwbm82NCrMaJb0AjpXJ0GsJi5OL(nHF8PcOrBqPrKC0s)MWpMVkGmnhdqCjoSCKHqWrguykAqPRfdUkYffBykhLQe9WvjVHLS7HY0CmaXL4WYrgcbhzqHPObLUwm4QixuSHPCuQYOpYL8gwYEIjxngUxiVYNzpXKtDC7jh0WsVVkFMDpuIkSkpFPEbW6NMyPRfC036f)icqJE0hHf7e6aguAejKP5yaU5sUA4Ik10bMrkGe1mtZXaetM07RBgboYGcYmtZXaexIdlhzieCKbfKzgDeIUAmCVqEWOpYL8gwqIQbLUwWOpYL8gwaWy7Ej8JkZpA0OAqPRfefx02O0n82NWaySDVe(rLprkMNwbefx02O0n82NWaATKN4vanAufZtRampHsSCgw1yy3yEpaO1sEIhjSkpFPEb8N9wl2LoYKyWrg)dkGgnQI5PvayYUEFDsnHXaATKN4rk29sciMmVedIGsEkrreOaA0OkMNwbm6JWIDcDaATKN4ro6JWIDcDadknIKckOatrdkDTyWvrUOydt5OufO59odkDToFJLSx7tknO0isoX80kyMIgu6AXGRICrXgMYrPkrpCvYByj7EOmnhdq0dxb9g(doYGcsOHfN0FkV0CmarpCf0B4p4OV1lgzAogGBUKRgUOsnDGJ(wV4hHgwCs)jMIgu6AXGRICrXgMYrPkJ(ixYByj7jMC1y4EH8kFM9eto1XTNCqdl9(Q8z29qjQWQ88L6faRFAILUwWrFRx8Jian6rFewStOdyqPrKqMMJb4Ml5QHlQuthygPasutZXaetM07RBgboYGcsuf7EjbetMxIbrq5rLOicqJotX80kamzxVVoPMWyaTwYt8kOatrdkDTyWvrUOydt5OuLrFKl5nSK9etUAmCVqELpZEIjN642toOHLEFv(m7EOevyvE(s9cG1pnXsxl4OV1l(reGg9Opcl2j0bmO0isitZXaCZLC1WfvQPdmJuaPyEAfaMSR3xNutymGwl5jEKIDVKaIjZlXGiOKNsuebirnnhdqmzsVVUze4idkiZ0GsxladRdgdiusWP07lA0zMMJbiMmP3x3mcCKbfKzMMJbiUehwoYqi4idkkWu0GsxlgCvKlk2Wuokvj6HRsEdlz3dLrhHO7fYdEcWW6GXitZXaetM07RBgbMrifZtRaWKD9(6KAcJb0AjpXJuS7LeqmzEjgebL8uIIiajQzkMNwbm82NCrMaJb0AjpXJgTbLgrYrl9BcR8PcmfnO01Ibxf5IInmLJsvIIlABu6gE7t4S7HYmJocr3lKh8eefx02O0n82NWitZXaetM07RBgboYGctrdkDTyWvrUOydt5OufmSoyC29qPy3ljGyY8smick5PefrasX80kamzxVVoPMWyaTwYt8mfnO01Ibxf5IInmLJsv4p7TwSlDKjXz3dLguAejhT0Vj8J5NPObLUwm4QixuSHPCuQYWBFclxJqk7EOevX80kGH3(KlYeymGwl5jEKguAejhT0Vj8J5xb0OnO0isoAPFt4hZhMIgu6AXGRICrXgMYrPkJ(OK59mfzkAqPRfdWIT82X7UsmPRv5WBFclxJqk7EOevufZtRagE7tUitGXaATKN4rAqPrKC0s)MWp(ezMJ(iSyNqhWGsJiPaA0guAejhT0Vj8J5RcitZXaexIdlhzieCKbfMIgu6AXaSylVD8URet6AZrPkrpCvYByj7EOmnhdqCjoSCKHqWrguqMMJbiUehwoYqi4OV1lopdkDTGrFuY8EaHscofYj9NykAqPRfdWIT82X7UsmPRnhLQe9WvjVHLS7HY0CmaXL4WYrgcbhzqbjQrhHO7fYdEcg9rjZ7rJE0hHf7e6aguAej0OnO01cIE4QK3WcOx3W3VXIcmfnO01IbyXwE74DxjM01MJsvIE4QK3Ws29qzAogG4sCy5idHGJmOGuS7LeqmzEjgebL8uIIiaPyEAfaMSR3xNutymGwl5jEMIgu6AXaSylVD8URet6AZrPkrpCvYByj7EOmnhdq0dxb9g(doYGcsOHfN0FkV0CmarpCf0B4p4OV1lMPObLUwmal2YBhV7kXKU2CuQYOpYL8gwYEIjxngUxiVYNzpXKtDC7jh0WsVVkFMDpuIkSkpFPEbW6NMyPRfC036f)icqMMJb4Ml5QHlQuthGVuVOrp6JWIDcDadknIKciZumpTcaH9Y779fqRL8epYmr0U2sEcm6JCjVHfxuv(EFrIkQOAqPRfm6JsM3diusWP07lA0gu6AbrpCvYBybqOKGtP3xfqIAAogGyYKEFDZiWrguqJE0hHf7e6aguAejKzMMJbiUehwoYqi4idkiZmnhdqmzsVVUze4idkkOaA0OkMNwbGj7691j1egdO1sEIhPy3ljGyY8smick5PefrasutZXaetM07RBgboYGcYmnO01cWW6GXacLeCk9(IgDMP5yaIlXHLJmecoYGcYmtZXaetM07RBgboYGcsdkDTamSoymGqjbNsVViZ0Gsxli6HRsEdlGEDdF)gliZ0Gsxly0hLmVh0RB473yrbfqJg1rFewStOdyqPrKqIQbLUwq0dxL8gwa96g((nwqJ2Gsxly0hLmVh0RB473yrbKzMMJbiMmP3x3mcCKbfKzMMJbiUehwoYqi4idkkOatrdkDTyawSL3oE3vIjDT5OuLrFKl5nSKDpukMNwbGWE599(cO1sEIhzAogGyYKEFDZiWrguqIkSkpFPEbW6NMyPRfC036f)4y69UJGX29soP)uo5phX80kae2lVV3xaTwYt8Orp6JWIDcDGJ(wV4hhtV3Dem2UxYj9NqJg1mfZtRaU5sUA4Ik10bO1sEIhnAyvE(s9cU5sUA4Ik10bo6B9IFu6p5KYX3esdkDTGBUKRgUOsnDaySDVeoVNkGewLNVuVay9ttS01co6B9IFu6p5KYX3KcmfnO01IbyXwE74DxjM01MJsvIE4QK3Ws29qz0ri6EH8GNamSoymY0CmaXKj9(6MrGzesX80kamzxVVoPMWyaTwYt8if7EjbetMxIbrqjpLOicqIkQI5PvadV9jxKjWyaTwYt8inO0isoAPFtyLprM5Opcl2j0bmO0iskGgnQguAejhT0VjCE5lYmfZtRagE7tUitGXaATKN4vqbMIgu6AXaSylVD8URet6AZrPkrXfTnkDdV9jC29qjQP5yaIjt691nJahzqbnAuZmnhdqCjoSCKHqWrguqIQbLUwWOpYL8gwaWy7Ej8JianAX80kamzxVVoPMWyaTwYt8if7EjbetMxIbrqjpLOicuqbfqMjI21wYtGO4I2gLUOQ89(Yu0GsxlgGfB5TJ3DLysxBokvbAEVZGsxRZ3yj71(KsdknIKtmpTcMPObLUwmal2YBhV7kXKU2CuQc)zV1IDPJmjo7EO0GsJi5OL(nHF8jtrdkDTyawSL3oE3vIjDT5OufmSoyC29qPy3ljGyY8smick5PefrasX80kamzxVVoPMWyaTwYt8mfnO01IbyXwE74DxjM01MJsvg9rjZ7zkAqPRfdWIT82X7UsmPRnhLQGH1bJzkYu0GsxlgixViKeSYjMCTqFSw0Iwda]] )


end
