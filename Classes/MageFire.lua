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

                removeDebuff( "target", "preheat" )

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

                if azerite.preheat.enabled then applyDebuff( "target", "preheat" ) end
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


    spec:RegisterPack( "Fire", 20190709.1530, [[duu)Zbqisv9isfPnbsJcf6uOiRIurKxjsmlHQULQur7cYVivAyQcDmvjltKkptKQMMQu01uLQ2MQuQVPkLyCQsfoNQuP1PkfyEQICpsP9Pk4GQsjLwOiPhQkf0fjveyJQsj5KKkcALOOUjPIq7uOYqvLczPQsH6PO0ujv5QQsjv7LK)sXGfCyQwSOEmWKb1Lr2ScFgeJweNwQvtQiQxRkQztPBRQ2Ts)wYWfYXvLskwUkphQPtCDfTDuW3fkJNuHZlsz9KkQ5tk2pQw9sPNIf2fsfx6E817(4B5X3f969Pp9p(2kwjTisXg5GNDiKID9pPyFR6JuSrEA2YHv6PyX18aKInrKi8BGU6cPLKzgbQVU4(pTU01coFi6I7pqxfBE2wrNWvLvSWUqQ4s3JVE3hFlp(UOxVp9P)X3uX6tjPoflB)Nwx6AFdpFik2KggMwvwXctyGIvNYdVv9r8GorhcXzwNYdjIeHFd0vxiTKmZiq91f3)P1LUwW5drxC)b6MTvw38WFNWed6gD1OTew33OJEJ9ggR7B0BSrNOdHmVv9riC)bCM1P8aZtBA8W7gppKUhF9U8W7KhE9(3G0)iNzoZ6uE4nmXxie(nGZSoLhEN8WBDmXds)jJug4M4HZLe64bjXxEq8dcjiP)KrkdCt8WOoEW6y5DIjqTW8GNBBlPXdtSdHWifRTXcwPNIvUEFMeSspvCVu6PyDG01QyNyY0c9XkwA9SLGvPQevCPtPNILwpBjyvQk21)KInQaptcU1zc2aQF0uCPR1atm0asX6aPRvXgvGNjb36mbBa1pAkU01AGjgAaPeLOyDG0mqgXT0kyLEQ4EP0tXsRNTeSkvfl4AHU2vSoqAgidT0Vjmp8ap8IhGYd55yGa1ppXsxlcUIT8auEGrEauLfUITiq9ZtS01Io679I5Hh4bqvw4k2ISnd9cXKRFgbppx6A5bnA4bqvw4k2Ia1ppXsxl6ihonEGjfRdKUwfRTzOxiMC9Zkrfx6u6PyP1ZwcwLQIfCTqx7k28Cmq3Cjtnmrvm6qZiEakpWipm6JWIFcDOJ(EVyE4bEauLfUITOpjuDi455sxlpOrdpOppm6JWIFcDihindepWepOrdpaQYcxXw0nxYudtufJo0rFVxmp8api9NmszGBIhGYdoq6Ar3Cjtnmrvm6qGe)GqyE4jE4fpOrdpWipaQYcxXw0NeQoe88CPRLhEIhavzHRylcu)8elDTOJ(EVyEqJgEauLfUITiq9ZtS01IoYHtJhyIhGYd6ZdIBPvq3Cjtnmrvm6q06zlbZdq5bg5bqvw4k2I(Kq1HGNNlDT8Wt8WOpcl(j0Ho679I5bnA4b95bXT0kOrFew8tOdrRNTempOrdpOppm6JWIFcDihindepWKI1bsxRI9tcvNsuIIfMg(0kk9uX9sPNI1bsxRIfuZvOdhrwRILwpBjyvQkrfx6u6PyP1ZwcwLQIfCTqx7k28CmqG6NNyPRfbxXwfRdKUwf7VVRot)DiKsuXLELEkwhiDTkwqTaALZfc2mS(NuS06zlbRsvjQ4EtLEkwhiDTk2rbMyc246mDTqMm5FflTE2sWQuvIkU3R0tX6aPRvXgnVEKwVqmzRJfflTE2sWQuvIkU3wPNI1bsxRI96Oilz61GJCaPyP1ZwcwLQsuX9wu6PyDG01QyLeYm3CnxyZOoaPyP1ZwcwLQsuX9ou6PyDG01QyJvNfMbQxZr4A9fqkwA9SLGvPQevCVRspflTE2sWQuvSGRf6AxXkULwbn6JWIFcDiA9SLG5bO8WOpcl(j0Ho679I5Hh4HX0Anhbs8dczK(t8Ggn8aOklCfBrG6NNyPRfD037fZdpWdm4x7zlHa1ppXsxR5Qidyk1yWdq5H8CmqG6NNyPRfbxXwEqJgEq6pzKYa3ep8epaQYcxXweO(5jw6Arh99EX8auEiphdeO(5jw6ArWvSvX6aPRvXEZLm1WevXOtjQ4E9OspflTE2sWQuvSoq6AvSF3oQ7tWMe6Clm2yjiXopcRybxl01UIfuLfUITiq9ZtS01Io679I5Hh4H3)Ef76FsX(D7OUpbBsOZTWyJLGe78iSsuX96LspflTE2sWQuvSGRf6AxXYipiULwbDZLm1WevXOdrRNTempaLhavzHRylcu)8elDTOJ(EVyE4jT8GdKUw0nxYudtufJoeWXIr6pXdA0WdGQSWvSfbQFEILUw0roCA8at8auEqFEy0hHf)e6qoqAgiEqJgEiphdeO(5jw6ArZifRdKUwflWTwJdKUwJTXII12yXS(NuSG6NNyPR1eL4ysjQ4ELoLEkwA9SLGvPQybxl01UInphd0nxYudtufJo0mIhGYd55yGa1ppXsxlcUITkwhiDTkwGBTghiDTgBJffRTXIz9pPyVkYeL4ysjQ4ELELEkwA9SLGvPQyRiflMefRdKUwfld(1E2skwgC7KuSIBPvq3Cjtnmrvm6q06zlbZdq5bqvw4k2IU5sMAyIQy0Ho679I5HN4bqvw4k2Ig9rMS1XcAmTwZrGe)GqgP)epaLhyKhavzHRylcu)8elDTOJ(EVyE4bEGb)ApBjeO(5jw6AnxfzatPgdEqJgEy0hHf)e6qoqAgiEGjEakpWipaQYcxXw0nxYudtufJo0rFVxmp8epi9NmszGBIh0OHhCG01IU5sMAyIQy0Haj(bHW8Wd8WJ8at8Ggn8aOklCfBrG6NNyPRfD037fZdpXdoq6ArJ(it26ybnMwR5iqIFqiJ0FIhsHhavzHRylA0hzYwhli455sxlpOtIhCDMUwiu26yHoZ3XcDiA9SLG5bO8G(8WOpcl(j0HCG0mq8auEauLfUITiq9ZtS01Io679I5HN4bP)KrkdCt8Ggn8G4wAf0Opcl(j0HO1ZwcMhGYdJ(iS4NqhYbsZaXdq5HrFew8tOdD037fZdpXdGQSWvSfn6JmzRJf0yATMJaj(bHms)jEifEauLfUITOrFKjBDSGGNNlDT8GojEW1z6AHqzRJf6mFhl0HO1ZwcwXYGFM1)KID0hzYwhlMOQS9crjQ4E9Mk9uS06zlbRsvXwrkwmjkwhiDTkwg8R9SLuSm42jPyf3sRGU5sMAyIQy0HO1ZwcMhGYdGQSWvSfDZLm1WevXOdD037fZdpXdGQSWvSffLu026WmS(NWOX0Anhbs8dczK(t8auEauLfUITiq9ZtS01Io679I5Hh4bg8R9SLqG6NNyPR1CvKbmLAm4bO8aJ8aOklCfBr3Cjtnmrvm6qh99EX8Wt8G0FYiLbUjEqJgEWbsxl6MlzQHjQIrhcK4hecZdpWdpYdmXdA0WdGQSWvSfbQFEILUw0rFVxmp8ep4aPRffLu026WmS(NWOX0Anhbs8dczK(t8auEauLfUITiq9ZtS01Io679I5HN4bP)KrkdCtkwg8ZS(NuSrjfTTomrvz7fIsuX969k9uS06zlbRsvX6aPRvXcCR14aPR1yBSOyTnwmR)jflw8f2pyZvIlDTkrjk2OJa1p7IspvCVu6PyP1ZwcwLQsuXLoLEkwA9SLGvPQevCPxPNILwpBjyvQkrf3BQ0tX6aPRvX6hWxY0RqwlbeflTE2sWQuvIkU3R0tXsRNTeSkvfBfPyXKOyDG01QyzWV2ZwsXYGBNKI9TFuXYGFM1)KIfu)8elDTMRImGPuJHsuX92k9uS06zlbRsvjQ4Elk9uSoq6AvS)(U6m93HqkwA9SLGvPQevCVdLEkwhiDTk2Os6AvS06zlbRsvjQ4ExLEkwhiDTk2O0UkBDSOyP1ZwcwLQsuIIfu)8elDTMOehtk9uX9sPNILwpBjyvQkwW1cDTRyZZXabQFEILUweCfBvSoq6AvS2gsIGn6KNWq(0kkrfx6u6PyP1ZwcwLQIfCTqx7kwxNPRfcLTowOZ8DSqhIwpBjyEakpiULwbnS(Nm1IO1ZwcMhGYd6ZdegtlGqF6xxAMAyStqdBGpY)yeTE2sWkwhiDTkwGBTghiDTgBJffRTXIz9pPyZFdO(5jw6AnrjoMuIkU0R0tX6aPRvXMTvbBQHrsidT0pnflTE2sWQuvIkU3uPNI1bsxRI9t)6sZudJDcAyd8r(hRyP1ZwcwLQsuX9ELEkwhiDTkwit)GBFn1W46mDLKOyP1ZwcwLQsuX92k9uS06zlbRsvXcUwORDfBEogiq9ZtS01IGRyRI1bsxRI9MlzQHjQIrNsuX9wu6PyP1ZwcwLQIfCTqx7kwg5bxNPRfcLTowOZ8DSqhIwpBjyEakpKNJbkBDSqN57yHoewCWZ8WdA5H0ZdmXdA0Wd6ZdUotxlekBDSqN57yHoeTE2sWkwhiDTkwGBTghiDTgBJffRTXIz9pPyDG0mqgXT0kyLOI7DO0tXsRNTeSkvf7etMyjTLmahl9crX(sXcUwORDfR(8aHX0ci0N(1LMPgg7e0Wg4J8pgrRNTempaLhyKh0NhCDMUwiu26yHoZ3XcDiA9SLG5bnA4b95bXT0kOH1)KPweTE2sW8at8auEGrEGrEWbsxl6tcvhQxZW2qseEakp4aPRf9jHQd1RzyBijI5OV3lMhEslp8i698at8Ggn8G(8G4wAf0NeQoeTE2sW8at8auEGrEiphd0nxYudtufJo0mIh0OHh0Nhe3sRGU5sMAyIQy0HO1ZwcMhysXoXKPgddeaSI9LI1bsxRIfu)8elDTkrf37Q0tXsRNTeSkvf7etMyjTLmahl9crX(sXcUwORDflHX0ci0N(1LMPgg7e0Wg4J8pgrRNTempaLhyKhYZXaDZLm1WevXOdnJ4bnA4b95bXT0kOBUKPgMOkgDiA9SLG5bMuStmzQXWabaRyFPyDG01Qyb1ppXsxRsuX96rLEkwhiDTk2Os6AvS06zlbRsvjQ4E9sPNI1bsxRInBRc2mMxAkwA9SLGvPQevCVsNspfRdKUwfBMomDp3leflTE2sWQuvIkUxPxPNI1bsxRID0hLTvbRyP1ZwcwLQsuX96nv6PyDG01Qy9fqy5CRb4wRILwpBjyvQkrf3R3R0tXsRNTeSkvfRdKUwflWTwJdKUwJTXII12yXS(NuSY17ZKGvIkUxVTspflTE2sWQuvSGRf6AxXYipWipiULwbnS(NmrUasq06zlbZdq5bhindKHw63eMhEGhshpWepOrdp4aPzGm0s)MW8Wd8WBZdmXdq5H8CmqjLyWYr(ZOJCGWdq5b95bxNPRfcLTowOZ8DSqhIwpBjyfRdKUwf7W6Fclx)mPevCVElk9uS06zlbRsvXcUwORDfBEogOO0UcyD8hDKdeEakpKNJbcu)8elDTOJ(EVyE4bEa4yXi9NuSoq6AvSrPDv26yrjQ4E9ou6PyP1ZwcwLQIfCTqx7k28CmqjLyWYr(ZOJCGOyDG01QyJs7QS1XIsuX96Dv6PyP1ZwcwLQIDIjtSK2sgGJLEHOyFPybxl01UILWyAbe6t)6sZudJDcAyd8r(hJO1ZwcMhGYdmYdmYd55yGa1ppXsxlAgXdq5bg5H8CmqjKl9cXmJqh5aHhGYd6Zdoq6ArrPDv26yb1RzyBijcpaLh0NhCG01IWG6ajisheyk9cHhyIh0OHhyKhCG01IWG6ajisheykK5OV3lMhGYd55yGsix6fIzgHGRylpaLhYZXaLuIblh5pJGRylpaLh0NhCG01IIs7QS1XcQxZW2qseEGjEGjEGjf7etMAmmqaWk2xkwhiDTk2rFKjBDSOevCP7rLEkwA9SLGvPQyNyYelPTKb4yPxik2xkwW1cDTRy1NhimMwaH(0VU0m1WyNGg2aFK)XiA9SLG5bO8aJ8G(8GRZ01cHYwhl0z(owOdrRNTempOrdpOppiULwbnS(Nm1IO1ZwcMhyIhGYdmYdmYd55yGa1ppXsxlAgXdq5bg5H8CmqjKl9cXmJqh5aHhGYd6Zdoq6ArrPDv26yb1RzyBijcpaLh0NhCG01IWG6ajisheyk9cHhyIh0OHhyKhCG01IWG6ajisheykK5OV3lMhGYd55yGsix6fIzgHGRylpaLhYZXaLuIblh5pJGRylpaLh0NhCG01IIs7QS1XcQxZW2qseEGjEGjEGjf7etMAmmqaWk2xkwhiDTk2rFKjBDSOevCP7LspflTE2sWQuvSGRf6AxXgDedgiay0leguhiHhGYd55yGsix6fIzgHMrkwhiDTk2O0UkBDSOevCPlDk9uSoq6AvSrjfTTomdR)jSILwpBjyvQkrfx6sVspflTE2sWQuvSGRf6AxXMNJbcu)8elDTOJ(EVyE4bEa4yXi9N4bO8qEogiq9ZtS01IMr8Ggn8qEogiq9ZtS01IGRyRI1bsxRIfdQdKOevCP7nv6PyP1ZwcwLQIfCTqx7k28CmqG6NNyPRfD037fZdpXdqaWOVRdEakp4aPzGm0s)MW8Wd8WlfRdKUwfRTzOxiMC9Zkrfx6EVspflTE2sWQuvSGRf6AxXMNJbcu)8elDTOJ(EVyE4jEacag9DDWdq5H8CmqG6NNyPRfnJuSoq6AvSWNdPwSjFKljkrfx6EBLEkwA9SLGvPQybxl01UIv8dcjOeYTsckci8WtA5H0)ipaLhe3sRGWKF9cXi1eKGO1ZwcwX6aPRvXIb1bsuIsuS5Vbu)8elDTMOehtk9uX9sPNILwpBjyvQkwW1cDTRyZZXabQFEILUweCfBvSoq6AvS2gsIGn6KNWq(0kkrfx6u6PyP1ZwcwLQIfCTqx7k28CmqG6NNyPRfbxXwEakp4aPzGm0s)MW8Wd8WlfRdKUwfRTzOxiMC9Zkrfx6v6PyP1ZwcwLQIfCTqx7k28CmqG6NNyPRfbxXwfRdKUwf7nxYudtufJoLOI7nv6PyP1ZwcwLQIDIjtSK2sgGJLEHOyFPyDG01Qyh9rMS1XIIfCTqx7k28CmqzRJf6mFhl0HGRylpaLhyKhe3sRGU5sMAyIQy0HO1ZwcMhGYdoq6Ar3Cjtnmrvm6qKoiWu6fcpaLhCG01IU5sMAyIQy0HiDqGPqMJ(EVyE4jE4r0BZdA0WdmYdGQSWvSfbQFEILUw0roCA8Ggn8qEogiq9ZtS01IMr8at8auEqFEqClTc6MlzQHjQIrhIwpBjyEakpOpp4aPRffL2vzRJfuVMHTHKi8auEqFEWbsxlA0hLDRf1RzyBijcpWKsuX9ELEkwA9SLGvPQyDG01QybU1ACG01ASnwuS2glM1)KI1bsZaze3sRGvIkU3wPNILwpBjyvQk2jMmXsAlzaow6fII9LIfCTqx7kwxNPRfcLTowOZ8DSqhIwpBjyEakpWipWip4aPRf9jHQd1RzyBijcpaLhCG01I(Kq1H61mSnKeXC037fZdpXdpIshpWepOrdpOppiULwb9jHQdrRNTempOrdpeDedgiay0l0NeQoEGjEakpWipKNJb6MlzQHjQIrhAgXdA0Wd6ZdIBPvq3Cjtnmrvm6q06zlbZdmPyNyYuJHbcawX(sX6aPRvXcQFEILUwLOI7TO0tX6aPRvXgvsxRILwpBjyvQkrf37qPNI1bsxRInBRc2mMxAkwA9SLGvPQevCVRspfRdKUwfBMomDp3leflTE2sWQuvIkUxpQ0tX6aPRvXo6JY2QGvS06zlbRsvjQ4E9sPNI1bsxRI1xaHLZTgGBTkwA9SLGvPQevCVsNspflTE2sWQuvSoq6AvSa3Anoq6An2glkwBJfZ6FsXkxVptcwjQ4ELELEkwA9SLGvPQybxl01UIn6igmqaWOximOoqcpaLhYZXaLqU0leZmcnJuSoq6AvSrPDv26yrjQ4E9Mk9uS06zlbRsvXcUwORDfBEogOKsmy5i)z0msX6aPRvXgL2vzRJfLOI717v6PyP1ZwcwLQIfCTqx7k28CmqrPDfW64p6ihi8auEa4yXi9N4HN4H8CmqG6NNyPRfD037fRyDG01QyJs7QS1XIsuX96Tv6PyDG01QyJskABDygw)tyflTE2sWQuvIkUxVfLEkwA9SLGvPQybxl01UInphdu26yHoZ3XcDiS4GN5bT8WlEakpKNJbkPedwoYFgbxXwEakpOppKNJbkkTRawh)rh5aHhGYdrhXGbcag9cfL2vzRJfEakpWipKNJbkBDSqN57yHo0rFVxmp8ep8i6175bnA4biay0rFVxmp8ep8i6175bMuSoq6AvSJ(it26yrXoXKPgddeaSI9LsuX96DO0tXsRNTeSkvf7etMyjTLmahl9crX(sX6aPRvXo6JmzRJffl4AHU2vS55yGYwhl0z(owOdHfh8mpOLhEXdq5bg5bhiDTimOoqcI0bbMsVq4bO8GdKUweguhibr6GatHmh99EX8Wt8WJOxVNh0OHhYZXaLTowOZ8DSqh6OV3lMhEIhEe9698atkrf3R3vPNILwpBjyvQkwW1cDTRyZZXaLuIblh5pJGRylpaLhyKhavzHRylA0hzYwhlOJ(EVyE4jEa4yXi9N4bnA4bhiDTOrFKjBDSGaj(bHW8Wd8WJ8atkwhiDTkwmOoqIsuXLUhv6PyP1ZwcwLQIDIjtSK2sgGJLEHOyFPybxl01UInphdu26yHoZ3XcDiS4GN5Hh4Hx8auEGrEi6igmqaWOximOoqcpaLh0NhYZXaLuIblh5pJMr8auEqFEWbsxlcdQdKGiDqGP0leEqJgEiphdu26yHoZ3XcDOJ(EVyE4jE4r0R3ZdmPyNyYuJHbcawX(sX6aPRvXo6JmzRJfLOIlDVu6PyP1ZwcwLQIfCTqx7k28CmqG6NNyPRfD037fZdpXdqaWOVRdEakp4aPzGm0s)MW8Wd8WlfRdKUwfRTzOxiMC9Zkrfx6sNspflTE2sWQuvSGRf6AxXMNJbcu)8elDTOJ(EVyE4jEacag9DDOyDG01QyHphsTyt(ixsuIkU0LELEkwhiDTkwmOoqIILwpBjyvQkrjkwS4lSFWMRex6Av6PI7LspflTE2sWQuvSGRf6AxXYipWipiULwbnS(NmrUasq06zlbZdq5bhindKHw63eMhEGhEXdq5b95HrFew8tOd5aPzG4bM4bnA4bhindKHw63eMhEGhEtEGjEakpKNJbkPedwoYFgDKdefRdKUwf7W6Fclx)mPevCPtPNILwpBjyvQkwW1cDTRyZZXaLuIblh5pJoYbcpaLhYZXaLuIblh5pJo679I5HN4bhiDTOrFu2TwePdcmfYi9NuSoq6AvSrPDv26yrjQ4sVspflTE2sWQuvSGRf6AxXMNJbkPedwoYFgDKdeEakpWipeDedgiay0l0Opk7wlpOrdpm6JWIFcDihindepOrdp4aPRffL2vzRJfuVMHTHKi8atkwhiDTk2O0UkBDSOevCVPspflTE2sWQuvSGRf6AxXMNJbkPedwoYFgDKdeEakpi(bHeuc5wjbfbeE4jT8q6FKhGYdIBPvqyYVEHyKAcsq06zlbRyDG01QyJs7QS1XIsuX9ELEkwA9SLGvPQybxl01UInphduuAxbSo(JoYbcpaLhaowms)jE4jEiphduuAxbSo(Jo679IvSoq6AvSrPDv26yrjQ4EBLEkwA9SLGvPQyNyYelPTKb4yPxik2xkwW1cDTRyzKhavzHRylcu)8elDTOJ(EVyE4bE4rEakpKNJb6MlzQHjQIrhcUIT8Ggn8WOpcl(j0HCG0mq8at8auEqFEqClTc65EHT9cbrRNTempaLh0NhyWV2Zwcn6JmzRJftuv2EHWdq5bg5bg5bg5bhiDTOrFu2TwePdcmLEHWdA0Wdoq6ArrPDv26ybr6GatPxi8at8auEGrEiphduc5sVqmZi0roq4bnA4HrFew8tOd5aPzG4bO8G(8qEogOKsmy5i)z0roq4bO8G(8qEogOeYLEHyMrOJCGWdmXdmXdA0WdmYdIBPvqyYVEHyKAcsq06zlbZdq5bXpiKGsi3kjOiGWdpPLhs)J8auEGrEiphduc5sVqmZi0roq4bO8G(8GdKUweguhibr6GatPxi8Ggn8G(8qEogOKsmy5i)z0roq4bO8G(8qEogOeYLEHyMrOJCGWdq5bhiDTimOoqcI0bbMsVq4bO8G(8GdKUwuuAxLTowq9Ag2gsIWdq5b95bhiDTOrFu2TwuVMHTHKi8at8at8Ggn8aJ8WOpcl(j0HCG0mq8auEGrEWbsxlkkTRYwhlOEndBdjr4bnA4bhiDTOrFu2TwuVMHTHKi8at8auEqFEiphduc5sVqmZi0roq4bO8G(8qEogOKsmy5i)z0roq4bM4bMuStmzQXWabaRyFPyDG01Qyh9rMS1XIsuX9wu6PyP1ZwcwLQIfCTqx7kwXT0kON7f22leeTE2sW8auEiphduc5sVqmZi0roq4bO8aJ8aOklCfBrG6NNyPRfD037fZdpWdJP1AocK4heYi9N4Hu4H0XdPWdIBPvqp3lSTxiiA9SLG5bnA4HrFew8tOdD037fZdpWdJP1AocK4heYi9N4bnA4bg5b95bXT0kOBUKPgMOkgDiA9SLG5bnA4bqvw4k2IU5sMAyIQy0Ho679I5Hh4bP)KrkdCt8auEWbsxl6MlzQHjQIrhcK4hecZdpXdV4bM4bO8aOklCfBrG6NNyPRfD037fZdpWds)jJug4M4bMuSoq6AvSJ(it26yrjQ4Ehk9uS06zlbRsvXcUwORDfB0rmyGaGrVqyqDGeEakpKNJbkHCPxiMzeAgXdq5bXT0kim5xVqmsnbjiA9SLG5bO8G4hesqjKBLeueq4HN0YdP)rEakpWipWipiULwbnS(NmrUasq06zlbZdq5bhindKHw63eMh0YdV4bO8G(8WOpcl(j0HCG0mq8at8Ggn8aJ8GdKMbYql9BcZdpXdVjpaLh0Nhe3sRGgw)tMixajiA9SLG5bM4bMuSoq6AvSrPDv26yrjQ4ExLEkwA9SLGvPQybxl01UILrEiphduc5sVqmZi0roq4bnA4bg5b95H8CmqjLyWYr(ZOJCGWdq5bg5bhiDTOrFKjBDSGaj(bHW8Wd8WJ8Ggn8G4wAfeM8RxigPMGeeTE2sW8auEq8dcjOeYTsckci8WtA5H0)ipWepWepWepaLh0NhyWV2ZwcfLu026WevLTxikwhiDTk2OKI2whMH1)ewjQ4E9OspflTE2sWQuvSoq6AvSa3Anoq6An2glkwBJfZ6FsX6aPzGmIBPvWkrf3Rxk9uS06zlbRsvXcUwORDfRdKMbYql9BcZdpWdVuSoq6AvSWNdPwSjFKljkrf3R0P0tXsRNTeSkvfRdKUwfR0WewQ7BafmPdfl4AHU2vSGQSWvSfbQFEILUw0rFVxmp8apKUh5bnA4bXT0kOrFew8tOdrRNTempaLhg9ryXpHo0rFVxmp8apKUhvSR)jfR0WewQ7BafmPdLOI7v6v6PyP1ZwcwLQI1bsxRInQaptcU1zc2aQF0uCPR1atm0asXcUwORDflJ8aOklCfBrG6NNyPRfD037fZdpWdP7rEqJgEqClTcA0hHf)e6q06zlbZdq5HrFew8tOdD037fZdpWdP7rEGjf76FsXgvGNjb36mbBa1pAkU01AGjgAaPevCVEtLEkwA9SLGvPQybxl01UIv8dcjOeYTsckci8WtA5H0)ipaLhe3sRGWKF9cXi1eKGO1ZwcwX6aPRvXIb1bsuIkUxVxPNI1bsxRID0hLDRvXsRNTeSkvLOI71BR0tX6aPRvXIb1bsuS06zlbRsvjkrXEvKjkXXKspvCVu6PyDG01QyV5sMAyIQy0PyP1ZwcwLQsuXLoLEkwA9SLGvPQybxl01UILrEGrEqClTcAy9pzICbKGO1ZwcMhGYdoqAgidT0Vjmp8ap8IhyIh0OHhCG0mqgAPFtyE4bE4n5bM4bO8qEogOKsmy5i)z0roquSoq6AvSdR)jSC9ZKsuXLELEkwA9SLGvPQybxl01UInphdusjgSCK)m6ihikwhiDTk2O0UkBDSOevCVPspflTE2sWQuvStmzIL0wYaCS0lef7lfl4AHU2vSmYdGQSWvSfbQFEILUw0rFVxmp8ap8ipOrdpm6JWIFcDihindepaLhYZXaDZLm1WevXOdnJ4bM4bO8aJ8G(8qEogOeYLEHyMrOJCGWdq5b95H8CmqjLyWYr(ZOJCGWdq5b95HOJyWuJHbcagn6JmzRJfEakpWip4aPRfn6JmzRJfeiXpieMhEqlpKoEqJgEGrEWbsxlkkPOT1Hzy9pHrGe)GqyE4bT8WlEakpiULwbfLu026WmS(NWiA9SLG5bM4bnA4bg5bXT0ki3s6alNJ1zhBgZlneTE2sW8auEauLfUITi4ZHul2KpYLe0roCA8at8Ggn8aJ8G4wAfeM8RxigPMGeeTE2sW8auEq8dcjOeYTsckci8WtA5H0)ipWepOrdpWipiULwbn6JWIFcDiA9SLG5bO8WOpcl(j0HCG0mq8at8at8atk2jMm1yyGaGvSVuSoq6AvSJ(it26yrjQ4EVspflTE2sWQuvSoq6AvSa3Anoq6An2glkwBJfZ6FsX6aPzGmIBPvWkrf3BR0tXsRNTeSkvfl4AHU2vS55yGIs7kG1XF0roq4bO8aWXIr6pXdpXd55yGIs7kG1XF0rFVxmpaLhYZXaDZLm1WevXOdD037fZdpWdahlgP)KI1bsxRInkTRYwhlkrf3BrPNILwpBjyvQk2jMmXsAlzaow6fII9LIfCTqx7kwg5bqvw4k2Ia1ppXsxl6OV3lMhEGhEKh0OHhg9ryXpHoKdKMbIhGYd55yGU5sMAyIQy0HMr8at8auEGrEiphduc5sVqmZi0roq4bO8aJ8G4hesqjKBLeueq4Hh0YdP)rEqJgEqFEqClTcct(1leJutqcIwpBjyEGjEGjf7etMAmmqaWk2xkwhiDTk2rFKjBDSOevCVdLEkwA9SLGvPQyNyYelPTKb4yPxik2xkwW1cDTRyzKhavzHRylcu)8elDTOJ(EVyE4bE4rEqJgEy0hHf)e6qoqAgiEakpKNJb6MlzQHjQIrhAgXdmXdq5bXT0kim5xVqmsnbjiA9SLG5bO8G4hesqjKBLeueq4HN0YdP)rEakpWipKNJbkHCPxiMze6ihi8auEqFEWbsxlcdQdKGiDqGP0leEqJgEqFEiphduc5sVqmZi0roq4bO8G(8qEogOKsmy5i)z0roq4bMuStmzQXWabaRyFPyDG01Qyh9rMS1XIsuX9Uk9uS06zlbRsvXcUwORDfB0rmyGaGrVqyqDGeEakpKNJbkHCPxiMzeAgXdq5bXT0kim5xVqmsnbjiA9SLG5bO8G4hesqjKBLeueq4HN0YdP)rEakpWipOppiULwbnS(NmrUasq06zlbZdA0WdoqAgidT0VjmpOLhEXdmPyDG01QyJs7QS1XIsuX96rLEkwA9SLGvPQybxl01UIvFEi6igmqaWOxOOKI2whMH1)eMhGYd55yGsix6fIzgHoYbII1bsxRInkPOT1Hzy9pHvIkUxVu6PyP1ZwcwLQIfCTqx7kwXpiKGsi3kjOiGWdpPLhs)J8auEqClTcct(1leJutqcIwpBjyfRdKUwflguhirjQ4ELoLEkwA9SLGvPQybxl01UI1bsZazOL(nH5Hh4H0PyDG01QyHphsTyt(ixsuIkUxPxPNILwpBjyvQkwW1cDTRyzKhe3sRGgw)tMixajiA9SLG5bO8GdKMbYql9BcZdpWdPJhyIh0OHhCG0mqgAPFtyE4bE49kwhiDTk2H1)ewU(zsjQ4E9Mk9uSoq6AvSJ(OSBTkwA9SLGvPQeLOefld0H7AvXLUhF9Up(2P79OhF33uXgZVTxiyfRoH)O6ecMhEh8GdKUwEW2ybJ4mRyXreqf3BNEfB0vJ2skwDkp8w1hXd6eDieNzDkpKise(nqxDH0sYmJa1xxC)Nwx6AbNpeDX9hOB2wzDZd)DctmOB0vJ2syDFJo6n2BySUVrVXgDIoeY8w1hHW9hWzwNYdmpTPXdVB88q6E817YdVtE417Fds)JCM5mRt5H3WeFHq43aoZ6uE4DYdV1Xepi9NmszGBIhoxsOJhKeF5bXpiKGK(tgPmWnXdJ64bRJL3jMa1cZdEUTTKgpmXoecJ4mZzwNYd6eOdcmfcMhY0OoIha1p7cpKji9Ir8WBTaafjyEyR9DM43FmT8GdKUwmpuRnneNzhiDTyu0rG6NDr7W64N5m7aPRfJIocu)SlPOv3rvWCMDG01IrrhbQF2Lu0QRpH8PvCPRLZSdKUwmk6iq9ZUKIwD9d4lz6viRLacNzDkpOxsJ5bg8R9SL4bmjyEqsiEq6pXdUWdXsAqcp8gpxIhQbp8gvXOJhWj10cZdyXpHhYuVq4bSZabZdJ64bjH4HL0HWdVH1ppXsxlpeL4yIZSdKUwmk6iq9ZUKIwDzWV2Zwk(1)Kwq9ZtS01AUkYaMsngXxrAXKepdUDsAF7h5m7aPRfJIocu)SlPOvx86r4KsmyXfmNzhiDTyu0rG6NDjfT6(77QZ0FhcXz2bsxlgfDeO(zxsrRUrL01Yz2bsxlgfDeO(zxsrRUrPDv26yHZmNzDkpOtGoiWuiyEGyGU04bP)epijep4aPoEOX8GZG3wpBjeNzhiDTyTGAUcD4iYA5m7aPRfNIwD)9D1z6VdHIVhAZZXabQFEILUweCfB5m7aPRfNIwDb1cOvoxiyZW6FIZSdKUwCkA1DuGjMGnUotxlKjt(NZSdKUwCkA1nAE9iTEHyYwhlCMDG01ItrRUxhfzjtVgCKdioZoq6AXPOvxjHmZnxZf2mQdqCMDG01ItrRUXQZcZa1R5iCT(cioZoq6AXPOv3BUKPgMOkgDX3dTIBPvqJ(iS4NqhIwpBjyOJ(iS4Nqh6OV3l(HX0Anhbs8dczK(tA0aQYcxXweO(5jw6Arh99EXpWGFTNTecu)8elDTMRImGPuJb08CmqG6NNyPRfbxXwnAK(tgPmWn9eOklCfBrG6NNyPRfD037fdnphdeO(5jw6ArWvSLZSdKUwCkA1DIjtl0p(1)K2VBh19jytcDUfgBSeKyNhHJVhAbvzHRylcu)8elDTOJ(EV4hE)75m7aPRfNIwDbU1ACG01ASnwIF9pPfu)8elDTMOehtX3dTmkULwbDZLm1WevXOdrRNTemuqvw4k2Ia1ppXsxl6OV3l(jToq6Ar3Cjtnmrvm6qahlgP)KgnGQSWvSfbQFEILUw0roCAmbv)rFew8tOd5aPzG0OjphdeO(5jw6ArZioZoq6AXPOvxGBTghiDTgBJL4x)tAVkYeL4yk(EOnphd0nxYudtufJo0mcAEogiq9ZtS01IGRylNzhiDT4u0Qld(1E2sXV(N0o6JmzRJftuv2EHepdUDsAf3sRGU5sMAyIQy0HO1ZwcgkOklCfBr3Cjtnmrvm6qh99EXpbQYcxXw0OpYKTowqJP1AocK4heYi9NGYiOklCfBrG6NNyPRfD037f)ad(1E2siq9ZtS01AUkYaMsngA0m6JWIFcDihindetqzeuLfUITOBUKPgMOkgDOJ(EV4NK(tgPmWnPrJdKUw0nxYudtufJoeiXpie(HhzsJgqvw4k2Ia1ppXsxl6OV3l(jhiDTOrFKjBDSGgtR1CeiXpiKr6pLcOklCfBrJ(it26ybbppx6A1j56mDTqOS1XcDMVJf6q06zlbdv)rFew8tOd5aPzGGcQYcxXweO(5jw6Arh99EXpj9NmszGBsJgXT0kOrFew8tOdrRNTem0rFew8tOd5aPzGGo6JWIFcDOJ(EV4NavzHRylA0hzYwhlOX0Anhbs8dczK(tPaQYcxXw0OpYKTowqWZZLUwDsUotxlekBDSqN57yHoeTE2sWCMDG01ItrRUm4x7zlf)6FsBusrBRdtuv2EHepdUDsAf3sRGU5sMAyIQy0HO1ZwcgkOklCfBr3Cjtnmrvm6qh99EXpbQYcxXwuusrBRdZW6FcJgtR1CeiXpiKr6pbfuLfUITiq9ZtS01Io679IFGb)ApBjeO(5jw6AnxfzatPgdOmcQYcxXw0nxYudtufJo0rFVx8ts)jJug4M0OXbsxl6MlzQHjQIrhcK4hec)WJmPrdOklCfBrG6NNyPRfD037f)KdKUwuusrBRdZW6FcJgtR1CeiXpiKr6pbfuLfUITiq9ZtS01Io679IFs6pzKYa3eNzhiDT4u0QlWTwJdKUwJTXs8R)jTyXxy)GnxjU01YzMZSdKUwmYbsZaze3sRG1ABg6fIjx)C89qRdKMbYql9Bc)WlO55yGa1ppXsxlcUITqzeuLfUITiq9ZtS01Io679IFauLfUITiBZqVqm56NrWZZLUwnAavzHRylcu)8elDTOJC40yIZSdKUwmYbsZaze3sRGtrRUFsO6IVhAZZXaDZLm1WevXOdnJGY4Opcl(j0Ho679IFauLfUITOpjuDi455sxRgn6p6JWIFcDihindetA0aQYcxXw0nxYudtufJo0rFVx8ds)jJug4MG6aPRfDZLm1WevXOdbs8dcHF6LgnmcQYcxXw0NeQoe88CPR9jqvw4k2Ia1ppXsxl6OV3lwJgqvw4k2Ia1ppXsxl6ihonMGQV4wAf0nxYudtufJoeTE2sWqzeuLfUITOpjuDi455sx7tJ(iS4Nqh6OV3lwJg9f3sRGg9ryXpHoeTE2sWA0O)Opcl(j0HCG0mqmXzMZSdKUwmk)nG6NNyPR1eL4ysRTHKiyJo5jmKpTs89qBEogiq9ZtS01IGRylNzhiDTyu(Ba1ppXsxRjkXXukA112m0letU(547H28CmqG6NNyPRfbxXwOoqAgidT0Vj8dV4m7aPRfJYFdO(5jw6AnrjoMsrRU3Cjtnmrvm6IVhAZZXabQFEILUweCfB5m7aPRfJYFdO(5jw6AnrjoMsrRUJ(it26yj(jMmXsAlzaow6fI2xX3dT55yGYwhl0z(owOdbxXwOmkULwbDZLm1WevXOdrRNTemuhiDTOBUKPgMOkgDisheyk9cbQdKUw0nxYudtufJoePdcmfYC037f)0JO3wJggbvzHRylcu)8elDTOJC400OjphdeO(5jw6ArZiMGQV4wAf0nxYudtufJoeTE2sWq13bsxlkkTRYwhlOEndBdjrGQVdKUw0Opk7wlQxZW2qseM4m7aPRfJYFdO(5jw6AnrjoMsrRUa3Anoq6An2glXV(N06aPzGmIBPvWCMDG01Ir5Vbu)8elDTMOehtPOvxq9ZtS01g)etMAmmqaWAFf)etMyjTLmahl9cr7R47HwxNPRfcLTowOZ8DSqhIwpBjyOmYOdKUw0NeQouVMHTHKiqDG01I(Kq1H61mSnKeXC037f)0JO0XKgn6lULwb9jHQdrRNTeSgnrhXGbcag9c9jHQJjOmMNJb6MlzQHjQIrhAgPrJ(IBPvq3Cjtnmrvm6q06zlbZeNzhiDTyu(Ba1ppXsxRjkXXukA1nQKUwoZoq6AXO83aQFEILUwtuIJPu0QB2wfSzmV04m7aPRfJYFdO(5jw6AnrjoMsrRUz6W09CVq4m7aPRfJYFdO(5jw6AnrjoMsrRUJ(OSTkyoZoq6AXO83aQFEILUwtuIJPu0QRVaclNBna3A5m7aPRfJYFdO(5jw6AnrjoMsrRUa3Anoq6An2glXV(N0kxVptcMZSdKUwmk)nG6NNyPR1eL4ykfT6gL2vzRJL47H2OJyWabaJEHWG6ajqZZXaLqU0leZmcnJ4m7aPRfJYFdO(5jw6AnrjoMsrRUrPDv26yj(EOnphdusjgSCK)mAgXz2bsxlgL)gq9ZtS01AIsCmLIwDJs7QS1Xs89qBEogOO0UcyD8hDKdeOahlgP)0t55yGa1ppXsxl6OV3lMZSdKUwmk)nG6NNyPR1eL4ykfT6gLu026WmS(NWCMDG01Ir5Vbu)8elDTMOehtPOv3rFKjBDSe)etMAmmqaWAFfFp0MNJbkBDSqN57yHoewCWZAFbnphdusjgSCK)mcUITq1pphduuAxbSo(JoYbc0OJyWabaJEHIs7QS1XcugZZXaLTowOZ8DSqh6OV3l(PhrVEVgnqaWOJ(EV4NEe969mXz2bsxlgL)gq9ZtS01AIsCmLIwDh9rMS1Xs8tmzIL0wYaCS0leTVIVhAZZXaLTowOZ8DSqhclo4zTVGYOdKUweguhibr6GatPxiqDG01IWG6ajisheykK5OV3l(PhrVEVgn55yGYwhl0z(owOdD037f)0JOxVNjoZoq6AXO83aQFEILUwtuIJPu0Qlguhij(EOnphdusjgSCK)mcUITqzeuLfUITOrFKjBDSGo679IFc4yXi9N0OXbsxlA0hzYwhliqIFqi8dpYeNzhiDTyu(Ba1ppXsxRjkXXukA1D0hzYwhlXpXKjwsBjdWXsVq0(k(jMm1yyGaG1(k(EOnphdu26yHoZ3XcDiS4GNF4fugJoIbdeam6fcdQdKav)8CmqjLyWYr(ZOzeu9DG01IWG6ajisheyk9crJM8CmqzRJf6mFhl0Ho679IF6r0R3ZeNzhiDTyu(Ba1ppXsxRjkXXukA112m0letU(547H28CmqG6NNyPRfD037f)eeam676aQdKMbYql9Bc)WloZoq6AXO83aQFEILUwtuIJPu0Ql85qQfBYh5ss89qBEogiq9ZtS01Io679IFccag9DDWz2bsxlgL)gq9ZtS01AIsCmLIwDXG6ajCM5mRt5H3W6NNyPRLhIsCmXdrhf5hH5bp32wAcZdXAjHhCEaMSEAXZdscT8G1NliHW8qVsXdscXdVH1ppXsxlpGP3AM0cioZoq6AXiq9ZtS01AIsCmP12qseSrN8egYNwj(EOnphdeO(5jw6ArWvSLZSdKUwmcu)8elDTMOehtPOvxGBTghiDTgBJL4x)tAZFdO(5jw6AnrjoMIVhADDMUwiu26yHoZ3XcDiA9SLGHkULwbnS(Nm1IO1ZwcgQ(egtlGqF6xxAMAyStqdBGpY)yeTE2sWCMDG01IrG6NNyPR1eL4ykfT6MTvbBQHrsidT0pnoZoq6AXiq9ZtS01AIsCmLIwD)0VU0m1WyNGg2aFK)XCMDG01IrG6NNyPR1eL4ykfT6cz6hC7RPggxNPRKeoZoq6AXiq9ZtS01AIsCmLIwDV5sMAyIQy0fFp0MNJbcu)8elDTi4k2Yz2bsxlgbQFEILUwtuIJPu0QlWTwJdKUwJTXs8R)jToqAgiJ4wAfC89qlJUotxlekBDSqN57yHoeTE2sWqZZXaLTowOZ8DSqhclo45h0MEM0OrFxNPRfcLTowOZ8DSqhIwpBjyoZoq6AXiq9ZtS01AIsCmLIwDb1ppXsxB8tmzQXWabaR9v8tmzIL0wYaCS0leTVIVhA1NWyAbe6t)6sZudJDcAyd8r(hJO1ZwcgkJ676mDTqOS1XcDMVJf6q06zlbRrJ(IBPvqdR)jtTiA9SLGzckJm6aPRf9jHQd1RzyBijcuhiDTOpjuDOEndBdjrmh99EXpP9r07zsJg9f3sRG(Kq1HO1ZwcMjOmMNJb6MlzQHjQIrhAgPrJ(IBPvq3Cjtnmrvm6q06zlbZeNzhiDTyeO(5jw6AnrjoMsrRUG6NNyPRn(jMm1yyGaG1(k(jMmXsAlzaow6fI2xX3dTegtlGqF6xxAMAyStqdBGpY)yeTE2sWqzmphd0nxYudtufJo0msJg9f3sRGU5sMAyIQy0HO1ZwcMjoZoq6AXiq9ZtS01AIsCmLIwDJkPRLZSdKUwmcu)8elDTMOehtPOv3STkyZyEPXz2bsxlgbQFEILUwtuIJPu0QBMomDp3leoZoq6AXiq9ZtS01AIsCmLIwDh9rzBvWCMDG01IrG6NNyPR1eL4ykfT66lGWY5wdWTwoZoq6AXiq9ZtS01AIsCmLIwDbU1ACG01ASnwIF9pPvUEFMemNzhiDTyeO(5jw6AnrjoMsrRUdR)jSC9Zu89qlJmkULwbnS(NmrUasq06zlbd1bsZazOL(nHFiDmPrJdKMbYql9Bc)WBZe08CmqjLyWYr(ZOJCGavFxNPRfcLTowOZ8DSqhIwpBjyoZoq6AXiq9ZtS01AIsCmLIwDJs7QS1Xs89qBEogOO0UcyD8hDKdeO55yGa1ppXsxl6OV3l(bGJfJ0FIZSdKUwmcu)8elDTMOehtPOv3O0UkBDSeFp0MNJbkPedwoYFgDKdeoZoq6AXiq9ZtS01AIsCmLIwDh9rMS1Xs8tmzQXWabaR9v8tmzIL0wYaCS0leTVIVhAjmMwaH(0VU0m1WyNGg2aFK)XiA9SLGHYiJ55yGa1ppXsxlAgbLX8CmqjKl9cXmJqh5abQ(oq6ArrPDv26yb1RzyBijcu9DG01IWG6ajisheyk9cHjnAy0bsxlcdQdKGiDqGPqMJ(EVyO55yGsix6fIzgHGRyl08CmqjLyWYr(Zi4k2cvFhiDTOO0UkBDSG61mSnKeHjMyIZSdKUwmcu)8elDTMOehtPOv3rFKjBDSe)etMAmmqaWAFf)etMyjTLmahl9cr7R47Hw9jmMwaH(0VU0m1WyNGg2aFK)XiA9SLGHYO(UotxlekBDSqN57yHoeTE2sWA0OV4wAf0W6FYulIwpBjyMGYiJ55yGa1ppXsxlAgbLX8CmqjKl9cXmJqh5abQ(oq6ArrPDv26yb1RzyBijcu9DG01IWG6ajisheyk9cHjnAy0bsxlcdQdKGiDqGPqMJ(EVyO55yGsix6fIzgHGRyl08CmqjLyWYr(Zi4k2cvFhiDTOO0UkBDSG61mSnKeHjMyIZSdKUwmcu)8elDTMOehtPOv3O0UkBDSeFp0gDedgiay0leguhibAEogOeYLEHyMrOzeNzhiDTyeO(5jw6AnrjoMsrRUrjfTTomdR)jmNzhiDTyeO(5jw6AnrjoMsrRUyqDGK47H28CmqG6NNyPRfD037f)aWXIr6pbnphdeO(5jw6ArZinAYZXabQFEILUweCfB5m7aPRfJa1ppXsxRjkXXukA112m0letU(547H28CmqG6NNyPRfD037f)eeam676aQdKMbYql9Bc)WloZoq6AXiq9ZtS01AIsCmLIwDHphsTyt(ixsIVhAZZXabQFEILUw0rFVx8tqaWOVRdO55yGa1ppXsxlAgXz2bsxlgbQFEILUwtuIJPu0Qlguhij(EOv8dcjOeYTsckcipPn9pcvClTcct(1leJutqcIwpBjyoZCMDG01IrxfzIsCmP9MlzQHjQIrhNzhiDTy0vrMOehtPOv3H1)ewU(zk(EOLrgf3sRGgw)tMixajiA9SLGH6aPzGm0s)MWp8IjnACG0mqgAPFt4hEtMGMNJbkPedwoYFgDKdeoZoq6AXORImrjoMsrRUrPDv26yj(EOnphdusjgSCK)m6ihiCMDG01IrxfzIsCmLIwDh9rMS1Xs8tmzQXWabaR9v8tmzIL0wYaCS0leTVIVhAzeuLfUITiq9ZtS01Io679IF4rnAg9ryXpHoKdKMbcAEogOBUKPgMOkgDOzetqzu)8CmqjKl9cXmJqh5abQ(55yGskXGLJ8Nrh5abQ(rhXGPgddeamA0hzYwhlqz0bsxlA0hzYwhliqIFqi8dAtNgnm6aPRffLu026WmS(NWiqIFqi8dAFbvClTckkPOT1Hzy9pHr06zlbZKgnmkULwb5wshy5CSo7yZyEPHO1ZwcgkOklCfBrWNdPwSjFKljOJC40ysJggf3sRGWKF9cXi1eKGO1ZwcgQ4hesqjKBLeueqEsB6FKjnAyuClTcA0hHf)e6q06zlbdD0hHf)e6qoqAgiMyIjoZoq6AXORImrjoMsrRUa3Anoq6An2glXV(N06aPzGmIBPvWCMDG01IrxfzIsCmLIwDJs7QS1Xs89qBEogOO0UcyD8hDKdeOahlgP)0t55yGIs7kG1XF0rFVxm08Cmq3Cjtnmrvm6qh99EXpaCSyK(tCMDG01IrxfzIsCmLIwDh9rMS1Xs8tmzQXWabaR9v8tmzIL0wYaCS0leTVIVhAzeuLfUITiq9ZtS01Io679IF4rnAg9ryXpHoKdKMbcAEogOBUKPgMOkgDOzetqzmphduc5sVqmZi0roqGYO4hesqjKBLeueqEqB6FuJg9f3sRGWKF9cXi1eKGO1ZwcMjM4m7aPRfJUkYeL4ykfT6o6JmzRJL4NyYuJHbcaw7R4NyYelPTKb4yPxiAFfFp0YiOklCfBrG6NNyPRfD037f)WJA0m6JWIFcDihinde08Cmq3Cjtnmrvm6qZiMGkULwbHj)6fIrQjibrRNTemuXpiKGsi3kjOiG8K20)iugZZXaLqU0leZmcDKdeO67aPRfHb1bsqKoiWu6fIgn6NNJbkHCPxiMze6ihiq1pphdusjgSCK)m6ihimXz2bsxlgDvKjkXXukA1nkTRYwhlX3dTrhXGbcag9cHb1bsGMNJbkHCPxiMzeAgbvClTcct(1leJutqcIwpBjyOIFqibLqUvsqra5jTP)rOmQV4wAf0W6FYe5cibrRNTeSgnoqAgidT0VjS2xmXz2bsxlgDvKjkXXukA1nkPOT1Hzy9pHJVhA1p6igmqaWOxOOKI2whMH1)egAEogOeYLEHyMrOJCGWz2bsxlgDvKjkXXukA1fdQdKeFp0k(bHeuc5wjbfbKN0M(hHkULwbHj)6fIrQjibrRNTemNzhiDTy0vrMOehtPOvx4ZHul2KpYLK47HwhindKHw63e(H0Xz2bsxlgDvKjkXXukA1Dy9pHLRFMIVhAzuClTcAy9pzICbKGO1ZwcgQdKMbYql9Bc)q6ysJghindKHw63e(H3Zz2bsxlgDvKjkXXukA1D0hLDRLZmNzhiDTyew8f2pyZvIlDTAhw)ty56NP47HwgzuClTcAy9pzICbKGO1ZwcgQdKMbYql9Bc)WlO6p6JWIFcDihindetA04aPzGm0s)MWp8MmbnphdusjgSCK)m6ihiCMDG01IryXxy)GnxjU01MIwDJs7QS1Xs89qBEogOKsmy5i)z0roqGMNJbkPedwoYFgD037f)KdKUw0Opk7wlI0bbMczK(tCMDG01IryXxy)GnxjU01MIwDJs7QS1Xs89qBEogOKsmy5i)z0roqGYy0rmyGaGrVqJ(OSBTA0m6JWIFcDihindKgnoq6ArrPDv26yb1RzyBijctCMDG01IryXxy)GnxjU01MIwDJs7QS1Xs89qBEogOKsmy5i)z0roqGk(bHeuc5wjbfbKN0M(hHkULwbHj)6fIrQjibrRNTemNzhiDTyew8f2pyZvIlDTPOv3O0UkBDSeFp0MNJbkkTRawh)rh5abkWXIr6p9uEogOO0UcyD8hD037fZz2bsxlgHfFH9d2CL4sxBkA1D0hzYwhlXpXKPgddeaS2xXpXKjwsBjdWXsVq0(k(EOLrqvw4k2Ia1ppXsxl6OV3l(HhHMNJb6MlzQHjQIrhcUITA0m6JWIFcDihindetq1xClTc65EHT9cbrRNTemu9zWV2Zwcn6JmzRJftuv2EHaLrgz0bsxlA0hLDRfr6GatPxiA04aPRffL2vzRJfePdcmLEHWeugZZXaLqU0leZmcDKdenAg9ryXpHoKdKMbcQ(55yGskXGLJ8Nrh5abQ(55yGsix6fIzgHoYbctmPrdJIBPvqyYVEHyKAcsq06zlbdv8dcjOeYTsckcipPn9pcLX8CmqjKl9cXmJqh5abQ(oq6AryqDGeePdcmLEHOrJ(55yGskXGLJ8Nrh5abQ(55yGsix6fIzgHoYbcuhiDTimOoqcI0bbMsVqGQVdKUwuuAxLTowq9Ag2gsIavFhiDTOrFu2TwuVMHTHKimXKgnmo6JWIFcDihindeugDG01IIs7QS1XcQxZW2qsenACG01Ig9rz3Ar9Ag2gsIWeu9ZZXaLqU0leZmcDKdeO6NNJbkPedwoYFgDKdeMyIZSdKUwmcl(c7hS5kXLU2u0Q7OpYKTowIVhAf3sRGEUxyBVqq06zlbdnphduc5sVqmZi0roqGYiOklCfBrG6NNyPRfD037f)WyATMJaj(bHms)PusxkIBPvqp3lSTxiiA9SLG1Oz0hHf)e6qh99EXpmMwR5iqIFqiJ0FsJgg1xClTc6MlzQHjQIrhIwpBjynAavzHRyl6MlzQHjQIrh6OV3l(bP)KrkdCtqDG01IU5sMAyIQy0Haj(bHWp9IjOGQSWvSfbQFEILUw0rFVx8ds)jJug4MyIZSdKUwmcl(c7hS5kXLU2u0QBuAxLTowIVhAJoIbdeam6fcdQdKanphduc5sVqmZi0mcQ4wAfeM8RxigPMGeeTE2sWqf)GqckHCRKGIaYtAt)JqzKrXT0kOH1)KjYfqcIwpBjyOoqAgidT0VjS2xq1F0hHf)e6qoqAgiM0OHrhindKHw63e(P3eQ(IBPvqdR)jtKlGeeTE2sWmXeNzhiDTyew8f2pyZvIlDTPOv3OKI2whMH1)eo(EOLX8CmqjKl9cXmJqh5arJgg1pphdusjgSCK)m6ihiqz0bsxlA0hzYwhliqIFqi8dpQrJ4wAfeM8RxigPMGeeTE2sWqf)GqckHCRKGIaYtAt)JmXetq1Nb)ApBjuusrBRdtuv2EHWz2bsxlgHfFH9d2CL4sxBkA1f4wRXbsxRX2yj(1)KwhindKrClTcMZSdKUwmcl(c7hS5kXLU2u0Ql85qQfBYh5ss89qRdKMbYql9Bc)WloZoq6AXiS4lSFWMRex6AtrRUtmzAH(XV(N0knmHL6(gqbt6i(EOfuLfUITiq9ZtS01Io679IFiDpQrJ4wAf0Opcl(j0HO1Zwcg6Opcl(j0Ho679IFiDpYz2bsxlgHfFH9d2CL4sxBkA1DIjtl0p(1)K2Oc8mj4wNjydO(rtXLUwdmXqdO47HwgbvzHRylcu)8elDTOJ(EV4hs3JA0iULwbn6JWIFcDiA9SLGHo6JWIFcDOJ(EV4hs3JmXz2bsxlgHfFH9d2CL4sxBkA1fdQdKeFp0k(bHeuc5wjbfbKN0M(hHkULwbHj)6fIrQjibrRNTemNzhiDTyew8f2pyZvIlDTPOv3rFu2TwoZoq6AXiS4lSFWMRex6AtrRUyqDGeoZCMDG01IrY17ZKG1oXKPf6J5m7aPRfJKR3NjbNIwDNyY0c9JF9pPnQaptcU1zc2aQF0uCPR1atm0asjkrPaa]] )


end
