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


    spec:RegisterPack( "Fire", 20190710.0900, [[du095bqisfpsvqSjiAuqItbjTksLk5vIuMLiXTivQYUa9lrKHjs1XGGLPkWZGqmniKCnsLY2GqQVPkinovbvNJujSosLQAEQICpsP9Pk0bvfukluK0dvfuCrsLk0gjvQuNKuPIALKIUjPsfStrudvvqPAPQckXtrPPsQYvjvQi7Lk)LKbtvhMYIv4XatgfxgzZI6ZQsJwOoTuRMuj61QIA2cUTQA3k9BjdxihxvqjTCvEoutN46kA7KcFxegpeQZtQQ1tQKMpKA)OAhco9CSmMqUKFq6iOls)HIq6W01fPJiikhROFe5yJmWZ2l5yx7towD39ro2it)qzmo9CS4AEaYXglsew3pPKEBjEoGG6NeU)ZGjDTGZYss4(dsYXoMDq0DEDdhlJjKl5hKoc6I0FOiKomDDr6iYdEOowBkX15yz7)mysx7dZzzXXg3mm06gowgcdCSpeUx3DFe3R7G9sCnFiCFSiryD)Ks6TL45acQFs4(pdM01colljH7pijUMpeUxZzqFUhH0tH7Fq6iOl4EDpUpDDHUF6PZ1KR5dH7FyIT9LW6(CnFiCVUh3R7eM4EP)KskfttC)zsmDCVeBl3l29scu6pPKsX0e3NRJ7dgw09WeOwgU3gDOf95(j2Ejm0XgASGD65yJocu)Hjo9CjJGtphlT2iqmUuDIl5h40ZXsRnceJlvN4sgrC65yP1gbIXLQtCjJOC65ynG016yTdylP6vOqGaIJLwBeigxQoXLSU50ZXsRnceJlvhBf5yXK4ynG016y1WU2gbYXQHfMKJfrNUJvd7uR9jhlO(Jjw6AvxfPatPYzN4sgr70ZXsRnceJlvN4s(H60ZXAaPR1X(77Qt1F7LCS0AJaX4s1jUKF4o9CSgq6ADSrL016yP1gbIXLQtCjRlC65ynG016yJ0)QrWWIJLwBeigxQoXjo2XxbQ)yILUwvuSHjNEUKrWPNJLwBeigxQowW1cDT5yhZCgcQ)yILUwitLyDSgq6ADSH(nwWkD5K59tR4exYpWPNJLwBeigxQowW1cDT5yhZCgcQ)yILUwitLy5EKCVbKwdsrl9BcZ9pY9i4ynG016ydTg9(Qg1F4exYiItphlT2iqmUuDSGRf6AZXoM5meu)XelDTqMkX6ynG016yV5sQkRIQe05exYikNEowATrGyCP6yNysLiUdKcyyP3xhlcowdiDTo2CFKAemS4ybxl01MJDmZz4iyyHo13WcDqMkXY9i5Eu4EXc0kWBUKQYQOkbDqATrGy4EKCVbKUw4nxsvzvuLGoiHycmLEF5EKCVbKUw4nxsvzvuLGoiHycmfsD036fZ9pX9Pdr0CpA0CpkCpOQatLyHG6pMyPRfEKXOp3Jgn3pM5meu)XelDTWze3Jk3JK71H7flqRaV5sQkRIQe0bP1gbIH7rY96W9gq6AHr6F1iyyb2Rkh63yH7rY96W9gq6AH5(OHfcWEv5q)glCpQoXLSU50ZXsRnceJlvhRbKUwhlWcbLbKUwvOXIJn0yrT2NCSgqAniLybAfStCjJOD65yP1gbIXLQJDIjvI4oqkGHLEFDSi4ybxl01MJ10v6AHGJGHf6uFdl0bP1gbIH7rY9OW9OW9gq6AHFsO6G9QYH(nw4EKCVbKUw4NeQoyVQCOFJf1rFRxm3)e3No8bCpQCpA0CVoCVybAf4NeQoiT2iqmCpA0CF0rAOEbmqeGFsO64Eu5EKCpkC)yMZWBUKQYQOkbDWze3Jgn3Rd3lwGwbEZLuvwfvjOdsRnced3JQJDIjvLZQxaJJfbhRbKUwhlO(Jjw6ADIl5hQtphRbKUwhBujDTowATrGyCP6exYpCNEowdiDTo2rOkgvEE67yP1gbIXLQtCjRlC65ynG016yh0HP75EFDS0AJaX4s1jUKriDNEowdiDTo2CF0iufJJLwBeigxQoXLmci40ZXAaPR1XAlGWYzbfWcbhlT2iqmUuDIlzeEGtphlT2iqmUuDSgq6ADSaleugq6AvHglo2qJf1AFYXkxVptc2jUKrarC65yP1gbIXLQJfCTqxBo2OJ0q9cyGiaXG6aXCpsUFmZzymzsVVQzeCg5ynG016yJ0)QrWWItCjJaIYPNJLwBeigxQowW1cDT5yhZCggxIclhzpdNrowdiDTo2i9VAemS4exYiOBo9CS0AJaX4s1XcUwORnh7yMZWi9Vcem8hEKbeUhj3dmSOK(tC)tC)yMZqq9htS01cp6B9IDSgq6ADSr6F1iyyXjUKrar70ZXAaPR1Xgfx02iwLd2NWowATrGyCP6exYi8qD65yP1gbIXLQJfCTqxBo2XmNHJGHf6uFdl0bXIbEM71Y9iW9i5(XmNHXLOWYr2ZqMkXY9i5ED4(XmNHr6Ffiy4p8idiCpsUp6inuVagicWi9VAemSW9i5Eu4(XmNHJGHf6uFdl0bp6B9I5(N4(0HiOBCpA0C)lGbE036fZ9pX9Pdrq34EuDSgq6ADS5(i1iyyXXoXKQYz1lGXXIGtCjJWd3PNJLwBeigxQo2jMujI7aPagw691XIGJ1asxRJn3hPgbdlowW1cDT5yhZCgocgwOt9nSqhelg4zUxl3Ja3JK7rH7nG01cXG6aXqcXeyk9(Y9i5EdiDTqmOoqmKqmbMcPo6B9I5(N4(0HiOBCpA0C)yMZWrWWcDQVHf6Gh9TEXC)tCF6qe0nUhvN4sgbDHtphlT2iqmUuDSGRf6AZXoM5mmUefwoYEgYujwUhj3Jc3dQkWujwyUpsncgwGh9TEXC)tCpWWIs6pX9OrZ9gq6AH5(i1iyybcIT7LWC)JCF6CpQowdiDTowmOoqStCj)G0D65yP1gbIXLQJDIjvI4oqkGHLEFDSi4ybxl01MJDmZz4iyyHo13WcDqSyGN5(h5Ee4EKCpkCF0rAOEbmqeGyqDGyUhj3Rd3pM5mmUefwoYEgoJ4EKCVoCVbKUwiguhigsiMatP3xUhnAUFmZz4iyyHo13WcDWJ(wVyU)jUpDic6g3JQJDIjvLZQxaJJfbhRbKUwhBUpsncgwCIl5hGGtphlT2iqmUuDSGRf6AZXoM5meu)XelDTWJ(wVyU)jU)fWa)gI5EKCVbKwdsrl9BcZ9pY9i4ynG016ydTg9(Qg1F4exYp4bo9CS0AJaX4s1XcUwORnh7yMZqq9htS01cp6B9I5(N4(xad8Bi2XAaPR1XYC2BTy14itIDIl5hGio9CSgq6ADSyqDGyhlT2iqmUuDItCSmu2MbXPNlzeC65ynG016yb1Cf6Wrui4yP1gbIXLQtCj)aNEowATrGyCP6ybxl01MJDmZziO(Jjw6AHmvI1XAaPR1X(77Qt1F7LCIlzeXPNJ1asxRJfulGw5mHyu5G9jhlT2iqmUuDIlzeLtphRbKUwhBUatmXOmDLUwi1GSVJLwBeigxQoXLSU50ZXAaPR1XgnVoRFVVQrWWIJLwBeigxQoXLmI2PNJ1asxRJ96OOaP6vHJma5yP1gbIXLQtCj)qD65ynG016yLysn3rnxgvUoa5yP1gbIXLQtCj)WD65ynG016ytuxGrdQx1r4ATfqowATrGyCP6exY6cNEowATrGyCP6ybxl01MJvSaTcm3hHf7e6G0AJaXW9i5(CFewStOdE036fZ9pY95ziOoceB3lPK(tCpA0CpOQatLyHG6pMyPRfE036fZ9pY9AyxBJabb1FmXsxR6QifykvoZ9i5(XmNHG6pMyPRfYujwUhnAUx6pPKsX0e3)e3dQkWujwiO(Jjw6AHh9TEXCpsUFmZziO(Jjw6AHmvI1XAaPR1XEZLuvwfvjOZjUKriDNEowATrGyCP6ynG016y)wix3NyuX0zbgSkqVjolc7ybxl01MJfuvGPsSqq9htS01cp6B9I5(h5EDt3CSR9jh73c56(eJkMolWGvb6nXzryN4sgbeC65yP1gbIXLQJfCTqxBowu4EXc0kWBUKQYQOkbDqATrGy4EKCpOQatLyHG6pMyPRfE036fZ9pPL7nG01cV5sQkRIQe0bbgwus)jUhnAUhuvGPsSqq9htS01cpYy0N7rL7rY96W95(iSyNqh0asRbX9OrZ9Jzodb1FmXsxlCg5ynG016ybwiOmG01QcnwCSHglQ1(KJfu)XelDTQOydtoXLmcpWPNJLwBeigxQo2jMujI7aPagw691XIGJfCTqxBowu4EcJPfqWp9RtFvLvHjOzumhzFm8B6Y64E0O5EcJPfqWp9RtFvLvHjOzumhzFm83BDCpsU30v6AHGJGHf6uFdl0bP1gbIH7rL7rY9Gy7Ejm3RL7)gIvGy7Ejm3JK71H7hZCggxIclhzpdpYac3JK71H7rH7hZCggtM07RAgbpYac3JK7rH7hZCgcQ)yILUw4mI7rY9OW9gq6AH5(OHfcWEv5q)glCpA0CVbKUwyK(xncgwG9QYH(nw4E0O5EdiDTqmOoqmKqmbMsVVCpQCpA0CVy3ljWyYcsmmciC)tA5EejDUhj3BaPRfIb1bIHeIjWu69L7rL7rL7rY96W9OW96W9JzodJjt69vnJGhzaH7rY96W9JzodJlrHLJSNHhzaH7rY9Jzodb1FmXsxlKPsSCpsUhfU3asxlm3hnSqa2Rkh63yH7rJM7nG01cJ0)QrWWcSxvo0VXc3Jk3JQJDIjvLZQxaJJfbhRbKUwhBUpsncgwCIlzeqeNEowATrGyCP6ybxl01MJDmZz4nxsvzvuLGo4mI7rY9Jzodb1FmXsxlKPsSowdiDTowGfckdiDTQqJfhBOXIATp5yVksffByYjUKrar50ZXsRnceJlvhBf5yXK4ynG016y1WU2gbYXQHfMKJvSaTc8MlPQSkQsqhKwBeigUhj3dQkWujw4nxsvzvuLGo4rFRxm3)e3dQkWujwyUpsncgwG5ziOoceB3lPK(tCpsUhfUhuvGPsSqq9htS01cp6B9I5(h5EnSRTrGGG6pMyPRvDvKcmLkN5E0O5(CFewStOdAaP1G4Eu5EKCpkCpOQatLyH3CjvLvrvc6Gh9TEXC)tCV0FsjLIPjUhnAU3asxl8MlPQSkQsqheeB3lH5(h5(05Eu5E0O5EqvbMkXcb1FmXsxl8OV1lM7FI7nG01cZ9rQrWWcmpdb1rGy7EjL0FI7tJ7bvfyQelm3hPgbdlqM5zsxl3R7I7nDLUwi4iyyHo13WcDqATrGy4EKCVoCFUpcl2j0bnG0AqCpsUhuvGPsSqq9htS01cp6B9I5(N4EP)KskfttCpA0CVybAfyUpcl2j0bP1gbIH7rY95(iSyNqh0asRbX9i5(CFewStOdE036fZ9pX9GQcmvIfM7JuJGHfyEgcQJaX29skP)e3Ng3dQkWujwyUpsncgwGmZZKUwUx3f3B6kDTqWrWWcDQVHf6G0AJaX4y1Wo1AFYXM7JuJGHfvuvHEFDIlze0nNEowATrGyCP6yRihlMehRbKUwhRg212iqownSWKCSIfOvG3CjvLvrvc6G0AJaXW9i5EqvbMkXcV5sQkRIQe0bp6B9I5(N4EqvbMkXcJIlABeRYb7tyyEgcQJaX29skP)e3JK7bvfyQeleu)XelDTWJ(wVyU)rUxd7ABeiiO(Jjw6AvxfPatPYzUhj3Jc3dQkWujw4nxsvzvuLGo4rFRxm3)e3l9NusPyAI7rJM7nG01cV5sQkRIQe0bbX29syU)rUpDUhvUhnAUhuvGPsSqq9htS01cp6B9I5(N4EdiDTWO4I2gXQCW(egMNHG6iqSDVKs6pX9i5EqvbMkXcb1FmXsxl8OV1lM7FI7L(tkPumn5y1Wo1AFYXgfx02iwfvvO3xN4sgbeTtphlT2iqmUuDSgq6ADSaleugq6AvHglo2qJf1AFYXIfBzSJrDLysxRtCIJ9QivuSHjNEUKrWPNJ1asxRJ9MlPQSkQsqNJLwBeigxQoXL8dC65yP1gbIXLQJfCTqxBowu4Eu4EXc0kWCW(KkYeqmKwBeigUhj3BaP1Gu0s)MWC)JCpcCpQCpA0CVbKwdsrl9BcZ9pY9ikUhvUhj3pM5mmUefwoYEgEKbehRbKUwhBoyFclx)m5exYiItphlT2iqmUuDSGRf6AZXoM5mmUefwoYEgEKbehRbKUwhBK(xncgwCIlzeLtphlT2iqmUuDStmPse3bsbmS07RJfbhl4AHU2CSOW9GQcmvIfcQ)yILUw4rFRxm3)i3No3Jgn3N7JWIDcDqdiTge3JK7hZCgEZLuvwfvjOdoJ4Eu5EKCpkCVoC)yMZWyYKEFvZi4rgq4EKCVoC)yMZW4suy5i7z4rgq4EKCVoCF0rAOQCw9cyG5(i1iyyH7rY9OW9gq6AH5(i1iyybcIT7LWC)JA5(hW9OrZ9OW9gq6AHrXfTnIv5G9jmeeB3lH5(h1Y9iW9i5EXc0kWO4I2gXQCW(egsRnced3Jk3Jgn3Jc3lwGwbAbcXy5mSUAyvEE6dP1gbIH7rY9GQcmvIfYC2BTy14itIHhzm6Z9OY9OrZ9OW9IfOvGyYUEFvsnbXqATrGy4EKCVy3ljWyYcsmmciC)tA5EejDUhvUhnAUhfUxSaTcm3hHf7e6G0AJaXW9i5(CFewStOdAaP1G4Eu5Eu5EuDStmPQCw9cyCSi4ynG016yZ9rQrWWItCjRBo9CS0AJaX4s1XAaPR1XcSqqzaPRvfAS4ydnwuR9jhRbKwdsjwGwb7exYiANEowATrGyCP6ybxl01MJDmZzyK(xbcg(dpYac3JK7bgwus)jU)jUFmZzyK(xbcg(dp6B9I5EKC)yMZWBUKQYQOkbDWJ(wVyU)rUhyyrj9NCSgq6ADSr6F1iyyXjUKFOo9CS0AJaX4s1XoXKkrChifWWsVVoweCSGRf6AZXIc3dQkWujwiO(Jjw6AHh9TEXC)JCF6CpA0CFUpcl2j0bnG0AqCpsUFmZz4nxsvzvuLGo4mI7rL7rY9OW9JzodJjt69vnJGhzaH7rY9OW9IDVKaJjliXWiGW9pQL7rK05E0O5ED4EXc0kqmzxVVkPMGyiT2iqmCpQCpQo2jMuvoREbmoweCSgq6ADS5(i1iyyXjUKF4o9CS0AJaX4s1XoXKkrChifWWsVVoweCSGRf6AZXIc3dQkWujwiO(Jjw6AHh9TEXC)JCF6CpA0CFUpcl2j0bnG0AqCpsUFmZz4nxsvzvuLGo4mI7rL7rY9IfOvGyYUEFvsnbXqATrGy4EKCVy3ljWyYcsmmciC)tA5EejDUhj3Jc3pM5mmMmP3x1mcEKbeUhj3Rd3BaPRfIb1bIHeIjWu69L7rJM71H7hZCggtM07RAgbpYac3JK71H7hZCggxIclhzpdpYac3JQJDIjvLZQxaJJfbhRbKUwhBUpsncgwCIlzDHtphlT2iqmUuDSGRf6AZXgDKgQxadebiguhiM7rY9JzodJjt69vnJGZiUhj3lwGwbIj769vj1eedP1gbIH7rY9IDVKaJjliXWiGW9pPL7rK05EKCpkCVoCVybAfyoyFsfzcigsRnced3Jgn3BaP1Gu0s)MWCVwUhbUhvhRbKUwhBK(xncgwCIlzes3PNJLwBeigxQowW1cDT5y1H7Josd1lGbIamkUOTrSkhSpH5EKC)yMZWyYKEFvZi4rgqCSgq6ADSrXfTnIv5G9jStCjJaco9CS0AJaX4s1XcUwORnhRy3ljWyYcsmmciC)tA5EejDUhj3lwGwbIj769vj1eedP1gbIXXAaPR1XIb1bIDIlzeEGtphlT2iqmUuDSGRf6AZXAaP1Gu0s)MWC)JC)dCSgq6ADSmN9wlwnoYKyN4sgbeXPNJLwBeigxQowW1cDT5yrH7flqRaZb7tQitaXqATrGy4EKCVbKwdsrl9BcZ9pY9pG7rL7rJM7nG0AqkAPFtyU)rUx3CSgq6ADS5G9jSC9ZKtCjJaIYPNJ1asxRJn3hnSqWXsRnceJlvN4ehlO(Jjw6AvrXgMC65sgbNEowATrGyCP6ybxl01MJDmZziO(Jjw6AHmvI1XAaPR1Xg63ybR0LtM3pTItCj)aNEowATrGyCP6ybxl01MJ10v6AHGJGHf6uFdl0bP1gbIH7rY9IfOvG5G9jvTqATrGy4EKCVoCpHX0ci4N(1PVQYQWe0mkMJSpg(nDzDowdiDTowGfckdiDTQqJfhBOXIATp5yhFfO(Jjw6AvrXgMCIlzeXPNJ1asxRJDeQIrvzLetkAPV(owATrGyCP6exYikNEowdiDTo2p9RtFvLvHjOzumhzFSJLwBeigxQoXLSU50ZXAaPR1X(oTJPTvvzLPR0vsSJLwBeigxQoXLmI2PNJLwBeigxQowW1cDT5yhZCgcQ)yILUwitLyDSgq6ADS3CjvLvrvc6CIl5hQtphlT2iqmUuDSGRf6AZXIc3B6kDTqWrWWcDQVHf6G0AJaXW9i5(XmNHJGHf6uFdl0bXIbEM7Ful3JiCpQCpA0CVoCVPR01cbhbdl0P(gwOdsRnceJJ1asxRJfyHGYasxRk0yXXgASOw7towdiTgKsSaTc2jUKF4o9CS0AJaX4s1XoXKkrChifWWsVVoweCSGRf6AZXQd3tymTac(PFD6RQSkmbnJI5i7JHFtxwh3JK7rH71H7nDLUwi4iyyHo13WcDqATrGy4E0O5ED4EXc0kWCW(KQwiT2iqmCpQCpsUhfUhfU3asxl8tcvhSxvo0VXc3JK7nG01c)Kq1b7vLd9BSOo6B9I5(N0Y9Pd1nUhvUhnAUxhUxSaTc8tcvhKwBeigUhvUhj3Jc3pM5m8MlPQSkQsqhCgX9OrZ96W9IfOvG3CjvLvrvc6G0AJaXW9O6yNysv5S6fW4yrWXAaPR1XcQ)yILUwN4swx40ZXsRnceJlvh7etQeXDGuadl9(6yrWXcUwORnhlHX0ci4N(1PVQYQWe0mkMJSpg(nDzDCpsUhfUFmZz4nxsvzvuLGo4mI7rJM71H7flqRaV5sQkRIQe0bP1gbIH7r1XoXKQYz1lGXXIGJ1asxRJfu)XelDToXLmcP70ZXAaPR1XgvsxRJLwBeigxQoXLmci40ZXAaPR1XocvXOYZtFhlT2iqmUuDIlzeEGtphRbKUwh7GomDp37RJLwBeigxQoXLmciItphRbKUwhBUpAeQIXXsRnceJlvN4sgbeLtphRbKUwhRTaclNfualeCS0AJaX4s1jUKrq3C65yP1gbIXLQJ1asxRJfyHGYasxRk0yXXgASOw7tow569zsWoXLmciANEowATrGyCP6ybxl01MJffUhfUxSaTcmhSpPImbedP1gbIH7rY9gqAnifT0Vjm3)i3)aUhvUhnAU3asRbPOL(nH5(h5Een3Jk3JK7hZCggxIclhzpdpYac3JK71H7nDLUwi4iyyHo13WcDqATrGyCSgq6ADS5G9jSC9ZKtCjJWd1PNJLwBeigxQowW1cDT5yhZCggP)vGGH)WJmGW9i5(XmNHG6pMyPRfE036fZ9pY9adlkP)KJ1asxRJns)RgbdloXLmcpCNEowATrGyCP6ybxl01MJDmZzyCjkSCK9m8idiowdiDTo2i9VAemS4exYiOlC65yP1gbIXLQJDIjvI4oqkGHLEFDSi4ybxl01MJLWyAbe8t)60xvzvycAgfZr2hd)MUSoUhj3Jc3dIT7LWQ8zaPR1cC)JCpcqeH7rJM7hZCgocgwOt9nSqh8OV1lM7FI7thQBCpA0C)yMZqq9htS01cp6B9I5(N4(XmNHJGHf6uFdl0bzMNjDTCpA0CVoCVPR01cbhbdl0P(gwOdsRnced3Jk3JK7rH7rH7hZCgcQ)yILUw4mI7rY9OW9JzodJjt69vnJGhzaH7rY96W9gq6AHr6F1iyyb2Rkh63yH7rY96W9gq6AHyqDGyiHycmLEF5Eu5E0O5Eu4EdiDTqmOoqmKqmbMcPo6B9I5EKC)yMZWyYKEFvZiitLy5EKC)yMZW4suy5i7zitLy5EKCVoCVbKUwyK(xncgwG9QYH(nw4Eu5Eu5EuDStmPQCw9cyCSi4ynG016yZ9rQrWWItCj)G0D65yP1gbIXLQJDIjvI4oqkGHLEFDSi4ybxl01MJvhUNWyAbe8t)60xvzvycAgfZr2hd)MUSoUhj3Jc3Rd3B6kDTqWrWWcDQVHf6G0AJaXW9OrZ96W9IfOvG5G9jvTqATrGy4Eu5EKCpkCpkC)yMZqq9htS01cNrCpsUhfUFmZzymzsVVQze8idiCpsUxhU3asxlms)RgbdlWEv5q)glCpsUxhU3asxledQdedjetGP07l3Jk3Jgn3Jc3BaPRfIb1bIHeIjWui1rFRxm3JK7hZCggtM07RAgbzQel3JK7hZCggxIclhzpdzQel3JK71H7nG01cJ0)QrWWcSxvo0VXc3Jk3Jk3JQJDIjvLZQxaJJfbhRbKUwhBUpsncgwCIl5hGGtphlT2iqmUuDSGRf6AZXgDKgQxadebiguhiM7rY9JzodJjt69vnJGZihRbKUwhBK(xncgwCIl5h8aNEowdiDTo2O4I2gXQCW(e2XsRnceJlvN4s(biItphlT2iqmUuDSGRf6AZXoM5meu)XelDTWJ(wVyU)rUhyyrj9N4EKC)yMZqq9htS01cNrCpA0C)yMZqq9htS01czQeRJ1asxRJfdQde7exYpar50ZXsRnceJlvhl4AHU2CSJzodb1FmXsxl8OV1lM7FI7FbmWVHyUhj3BaP1Gu0s)MWC)JCpcowdiDTo2qRrVVQr9hoXL8d0nNEowATrGyCP6ybxl01MJDmZziO(Jjw6AHh9TEXC)tC)lGb(neZ9i5(XmNHG6pMyPRfoJCSgq6ADSmN9wlwnoYKyN4s(biANEowATrGyCP6ybxl01MJvS7LeymzbjggbeU)jTCpIKo3JK7flqRaXKD9(QKAcIH0AJaX4ynG016yXG6aXoXjowdiTgKsSaTc2PNlzeC65yP1gbIXLQJfCTqxBowdiTgKIw63eM7FK7rG7rY9Jzodb1FmXsxlKPsSCpsUhfUhuvGPsSqq9htS01cp6B9I5(h5EqvbMkXcdTg9(Qg1FazMNjDTCpA0CpOQatLyHG6pMyPRfEKXOp3JQJ1asxRJn0A07RAu)HtCj)aNEowATrGyCP6ybxl01MJDmZz4nxsvzvuLGo4mI7rY9OW95(iSyNqh8OV1lM7FK7bvfyQel8tcvhKzEM01Y9OrZ96W95(iSyNqh0asRbX9OY9OrZ9GQcmvIfEZLuvwfvjOdE036fZ9pY9s)jLukMM4EKCVbKUw4nxsvzvuLGoii2UxcZ9pX9iW9OrZ9OW9GQcmvIf(jHQdYmpt6A5(N4EqvbMkXcb1FmXsxl8OV1lM7rJM7bvfyQeleu)XelDTWJmg95Eu5EKCVoCVybAf4nxsvzvuLGoiT2iqmCpsUhfUhuvGPsSWpjuDqM5zsxl3)e3N7JWIDcDWJ(wVyUhnAUxhUxSaTcm3hHf7e6G0AJaXW9OrZ96W95(iSyNqh0asRbX9O6ynG016y)Kq15eN4yXITm2XOUsmPR1PNlzeC65yP1gbIXLQJfCTqxBowu4Eu4EXc0kWCW(KkYeqmKwBeigUhj3BaP1Gu0s)MWC)JCpcCpsUxhUp3hHf7e6GgqAniUhvUhnAU3asRbPOL(nH5(h5Eef3Jk3JK7hZCggxIclhzpdpYaIJ1asxRJnhSpHLRFMCIl5h40ZXsRnceJlvhl4AHU2CSJzodJlrHLJSNHhzaH7rY9JzodJlrHLJSNHh9TEXC)tCVbKUwyUpAyHaKqmbMcPK(towdiDTo2i9VAemS4exYiItphlT2iqmUuDSGRf6AZXoM5mmUefwoYEgEKbeUhj3Jc3hDKgQxadebyUpAyHa3Jgn3N7JWIDcDqdiTge3Jgn3BaPRfgP)vJGHfyVQCOFJfUhvhRbKUwhBK(xncgwCIlzeLtphlT2iqmUuDSGRf6AZXoM5mmUefwoYEgEKbeUhj3l29scmMSGedJac3)KwUhrsN7rY9IfOvGyYUEFvsnbXqATrGyCSgq6ADSr6F1iyyXjUK1nNEowATrGyCP6ybxl01MJDmZzyK(xbcg(dpYac3JK7bgwus)jU)jUFmZzyK(xbcg(dp6B9IDSgq6ADSr6F1iyyXjUKr0o9CS0AJaX4s1XoXKkrChifWWsVVoweCSGRf6AZXIc3dQkWujwiO(Jjw6AHh9TEXC)JCF6CpsUFmZz4nxsvzvuLGoitLy5E0O5(CFewStOdAaP1G4Eu5EKCVoCVybAf4Z9Ye69fsRnced3JK71H71WU2gbcM7JuJGHfvuvHEF5EKCpkCpkCpkCVbKUwyUpAyHaKqmbMsVVCpA0CVbKUwyK(xncgwGeIjWu69L7rL7rY9OW9JzodJjt69vnJGhzaH7rJM7Z9ryXoHoObKwdI7rY96W9JzodJlrHLJSNHhzaH7rY96W9JzodJjt69vnJGhzaH7rL7rL7rJM7rH7flqRaXKD9(QKAcIH0AJaXW9i5EXUxsGXKfKyyeq4(N0Y9is6CpsUhfUFmZzymzsVVQze8idiCpsUxhU3asxledQdedjetGP07l3Jgn3Rd3pM5mmUefwoYEgEKbeUhj3Rd3pM5mmMmP3x1mcEKbeUhj3BaPRfIb1bIHeIjWu69L7rY96W9gq6AHr6F1iyyb2Rkh63yH7rY96W9gq6AH5(OHfcWEv5q)glCpQCpQCpA0CpkCFUpcl2j0bnG0AqCpsUhfU3asxlms)RgbdlWEv5q)glCpA0CVbKUwyUpAyHaSxvo0VXc3Jk3JK71H7hZCggtM07RAgbpYac3JK71H7hZCggxIclhzpdpYac3Jk3JQJDIjvLZQxaJJfbhRbKUwhBUpsncgwCIl5hQtphlT2iqmUuDSGRf6AZXkwGwb(CVmHEFH0AJaXW9i5(XmNHXKj9(QMrWJmGW9i5Eu4EqvbMkXcb1FmXsxl8OV1lM7FK7ZZqqDei2Uxsj9N4(04(hW9PX9IfOvGp3ltO3xiT2iqmCpA0CFUpcl2j0bp6B9I5(h5(8meuhbIT7Lus)jUhnAUhfUxhUxSaTc8MlPQSkQsqhKwBeigUhnAUhuvGPsSWBUKQYQOkbDWJ(wVyU)rUx6pPKsX0e3JK7nG01cV5sQkRIQe0bbX29syU)jUhbUhvUhj3dQkWujwiO(Jjw6AHh9TEXC)JCV0FsjLIPjUhvhRbKUwhBUpsncgwCIl5hUtphlT2iqmUuDSGRf6AZXgDKgQxadebiguhiM7rY9JzodJjt69vnJGZiUhj3lwGwbIj769vj1eedP1gbIH7rY9IDVKaJjliXWiGW9pPL7rK05EKCpkCpkCVybAfyoyFsfzcigsRnced3JK7nG0AqkAPFtyUxl3Ja3JK71H7Z9ryXoHoObKwdI7rL7rJM7rH7nG0AqkAPFtyU)jUhrX9i5ED4EXc0kWCW(KkYeqmKwBeigUhvUhvhRbKUwhBK(xncgwCIlzDHtphlT2iqmUuDSGRf6AZXIc3pM5mmMmP3x1mcEKbeUhnAUhfUxhUFmZzyCjkSCK9m8idiCpsUhfU3asxlm3hPgbdlqqSDVeM7FK7tN7rJM7flqRaXKD9(QKAcIH0AJaXW9i5EXUxsGXKfKyyeq4(N0Y9is6CpQCpQCpQCpsUxhUxd7ABeiyuCrBJyvuvHEFDSgq6ADSrXfTnIv5G9jStCjJq6o9CS0AJaX4s1XAaPR1XcSqqzaPRvfAS4ydnwuR9jhRbKwdsjwGwb7exYiGGtphlT2iqmUuDSGRf6AZXAaP1Gu0s)MWC)JCpcowdiDTowMZERfRghzsStCjJWdC65yP1gbIXLQJ1asxRJvAgcl19vGIHqSJfCTqxBowqvbMkXcb1FmXsxl8OV1lM7FK7Fq6CpA0CVybAfyUpcl2j0bP1gbIH7rY95(iSyNqh8OV1lM7FK7Fq6o21(KJvAgcl19vGIHqStCjJaI40ZXsRnceJlvhRbKUwhBubEMeCRReJcu)OPysxRIH0ObKJfCTqxBowqvbMkXcb6dcLC12a1iyybYmpt6A5EKCpkCpOQatLyHG6pMyPRfE036fZ9pY9piDUhnAUxSaTcm3hHf7e6G0AJaXW9i5(CFewStOdE036fZ9pY9piDUhvh7AFYXgvGNjb36kXOa1pAkM01QyinAa5exYiGOC65yP1gbIXLQJfCTqxBowXUxsGXKfKyyeq4(N0Y9is6CpsUxSaTcet217RsQjigsRnceJJ1asxRJfdQde7exYiOBo9CSgq6ADS5(OHfcowATrGyCP6exYiGOD65ynG016yXG6aXowATrGyCP6eN4yLR3Njb70ZLmco9CSgq6ADStmPAH(yhlT2iqmUuDIl5h40ZXsRnceJlvhRbKUwhBubEMeCRReJcu)OPysxRIH0ObKJfCTqxBowD4EqvbMkXcb6dcLC12a1iyybYmpt6ADSR9jhBubEMeCRReJcu)OPysxRIH0ObKtCItCSAqhUR1L8dshbDr6p001fqe0neXXMWUT3xSJv35FuDcXW9pCU3asxl3hASGHCnDSrxL7a5yFiCVU7(iUx3b7L4A(q4(yrIW6(jL0BlXZbeu)KW9FgmPRfCwwsc3FqsCnFiCVMZG(CpcPNc3)G0rqxW96ECF66cD)0tNRjxZhc3)WeB7lH195A(q4EDpUx3jmX9s)jLukMM4(ZKy64Ej2wUxS7LeO0FsjLIPjUpxh3hmSO7HjqTmCVn6ql6Z9tS9syixtUMpeUx3retGPqmC)GY1rCpO(dt4(b92lgY9pSbauKG5(TwDVy7(5zG7nG01I5(Ad6d5AAaPRfdJocu)HjAZbd)mxtdiDTyy0rG6pmjnTjLRIHRPbKUwmm6iq9hMKM2KS57NwXKUwUMgq6AXWOJa1FysAAtYoGTKQxHcbciCnFiCVEXnM71WU2gbI7XKG5EjM4EP)e3Bc3NiUbXC)dlZL4(kZ9pSxjOJ7XX1mWW9yXoH7huVVCp20Gy4(CDCVetC)siw4(hM6pMyPRL7JInmX10asxlggDeO(dtstBsAyxBJaLYAFslO(Jjw6AvxfPatPY5uQiTyssrdlmjTi605AAaPRfdJocu)HjPPnj8Ar44suyXemxtdiDTyy0rG6pmjnTj977Qt1F7L4AAaPRfdJocu)HjPPnPOs6A5AAaPRfdJocu)HjPPnPi9VAemSW1KR5dH71DeXeyked3tAqN(CV0FI7LyI7nGuh33yU30W6GnceKRPbKUwSwqnxHoCefcCnnG01IttBs)(U6u93EPu6S2XmNHG6pMyPRfYujwUMgq6AXPPnjqTaALZeIrLd2N4AAaPRfNM2KYfyIjgLPR01cPgK95AAaPRfNM2KIMxN1V3x1iyyHRPbKUwCAAt66OOaP6vHJmaX10asxlonTjjXKAUJAUmQCDaIRPbKUwCAAtkrDbgnOEvhHR1waX10asxlonTjDZLuvwfvjOlLoRvSaTcm3hHf7e6G0AJaXGm3hHf7e6Gh9TEXpMNHG6iqSDVKs6pHgnOQatLyHG6pMyPRfE036f)Og212iqqq9htS01QUksbMsLZihZCgcQ)yILUwitLyrJw6pPKsX00tGQcmvIfcQ)yILUw4rFRxmYXmNHG6pMyPRfYujwUMgq6AXPPnPjMuTq)uw7tA)wix3NyuX0zbgSkqVjolcNsN1cQkWujwiO(Jjw6AHh9TEXpQB6gxtdiDT400MeWcbLbKUwvOXskR9jTG6pMyPRvffBykLoRffXc0kWBUKQYQOkbDqATrGyqcQkWujwiO(Jjw6AHh9TEXpP1asxl8MlPQSkQsqheyyrj9NqJguvGPsSqq9htS01cpYy0hvK6K7JWIDcDqdiTgeA0Jzodb1FmXsxlCgX10asxlonTjL7JuJGHLuMysLiUdKcyyP3xTiKYetQkNvVagTiKsN1IcHX0ci4N(1PVQYQWe0mkMJSpg(nDzDOrtymTac(PFD6RQSkmbnJI5i7JH)ERdPPR01cbhbdl0P(gwOdsRncedQibX29syTFdXkqSDVegPoJzodJlrHLJSNHhzabPoOmM5mmMmP3x1mcEKbeKOmM5meu)XelDTWzesumG01cZ9rdleG9QYH(nwqJ2asxlms)RgbdlWEv5q)glOrBaPRfIb1bIHeIjWu69fv0Of7EjbgtwqIHra5jTis6inG01cXG6aXqcXeyk9(IkQi1bfDgZCggtM07RAgbpYacsDgZCggxIclhzpdpYacYXmNHG6pMyPRfYujwKOyaPRfM7Jgwia7vLd9BSGgTbKUwyK(xncgwG9QYH(nwqfvUMgq6AXPPnjGfckdiDTQqJLuw7tAVksffBykLoRDmZz4nxsvzvuLGo4mc5yMZqq9htS01czQelxtdiDT400MKg212iqPS2N0M7JuJGHfvuvHEFtrdlmjTIfOvG3CjvLvrvc6G0AJaXGeuvGPsSWBUKQYQOkbDWJ(wV4NavfyQelm3hPgbdlW8meuhbIT7Lus)jKOaQkWujwiO(Jjw6AHh9TEXpQHDTnceeu)XelDTQRIuGPu5mA05(iSyNqh0asRbHksuavfyQel8MlPQSkQsqh8OV1l(jP)KskfttOrBaPRfEZLuvwfvjOdcIT7LWpMoQOrdQkWujwiO(Jjw6AHh9TEXpzaPRfM7JuJGHfyEgcQJaX29skP)uAGQcmvIfM7JuJGHfiZ8mPRv3LPR01cbhbdl0P(gwOdsRncedsDY9ryXoHoObKwdcjOQatLyHG6pMyPRfE036f)K0FsjLIPj0OflqRaZ9ryXoHoiT2iqmiZ9ryXoHoObKwdczUpcl2j0bp6B9IFcuvGPsSWCFKAemSaZZqqDei2Uxsj9NsduvGPsSWCFKAemSazMNjDT6UmDLUwi4iyyHo13WcDqATrGy4AAaPRfNM2K0WU2gbkL1(K2O4I2gXQOQc9(MIgwysAflqRaV5sQkRIQe0bP1gbIbjOQatLyH3CjvLvrvc6Gh9TEXpbQkWujwyuCrBJyvoyFcdZZqqDei2Uxsj9NqcQkWujwiO(Jjw6AHh9TEXpQHDTnceeu)XelDTQRIuGPu5msuavfyQel8MlPQSkQsqh8OV1l(jP)KskfttOrBaPRfEZLuvwfvjOdcIT7LWpMoQOrdQkWujwiO(Jjw6AHh9TEXpzaPRfgfx02iwLd2NWW8meuhbIT7Lus)jKGQcmvIfcQ)yILUw4rFRx8ts)jLukMM4AAaPRfNM2KawiOmG01QcnwszTpPfl2YyhJ6kXKUwUMCnnG01IHgqAniLybAfS2qRrVVQr9hP0zTgqAnifT0Vj8JiGCmZziO(Jjw6AHmvIfjkGQcmvIfcQ)yILUw4rFRx8JGQcmvIfgAn69vnQ)aYmpt6ArJguvGPsSqq9htS01cpYy0hvUMgq6AXqdiTgKsSaTconTj9jHQlLoRDmZz4nxsvzvuLGo4mcjk5(iSyNqh8OV1l(rqvbMkXc)Kq1bzMNjDTOrRtUpcl2j0bnG0AqOIgnOQatLyH3CjvLvrvc6Gh9TEXpk9NusPyAcPbKUw4nxsvzvuLGoii2Uxc)ecOrJcOQatLyHFsO6GmZZKU2NavfyQeleu)XelDTWJ(wVy0ObvfyQeleu)XelDTWJmg9rfPoIfOvG3CjvLvrvc6G0AJaXGefqvbMkXc)Kq1bzMNjDTpL7JWIDcDWJ(wVy0O1rSaTcm3hHf7e6G0AJaXGgTo5(iSyNqh0asRbHkxtUMgq6AXWXxbQ)yILUwvuSHjTH(nwWkD5K59tRKsN1oM5meu)XelDTqMkXY10asxlgo(kq9htS01QIInmLM2KcTg9(Qg1FKsN1oM5meu)XelDTqMkXI0asRbPOL(nHFebUMgq6AXWXxbQ)yILUwvuSHP00M0nxsvzvuLGUu6S2XmNHG6pMyPRfYujwUMgq6AXWXxbQ)yILUwvuSHP00MuUpsncgwszIjvI4oqkGHLEF1IqkDw7yMZWrWWcDQVHf6GmvIfjkIfOvG3CjvLvrvc6G0AJaXG0asxl8MlPQSkQsqhKqmbMsVVinG01cV5sQkRIQe0bjetGPqQJ(wV4NshIOrJgfqvbMkXcb1FmXsxl8iJrF0OhZCgcQ)yILUw4mcvK6iwGwbEZLuvwfvjOdsRncedsDmG01cJ0)QrWWcSxvo0VXcsDmG01cZ9rdleG9QYH(nwqLRPbKUwmC8vG6pMyPRvffByknTjbSqqzaPRvfASKYAFsRbKwdsjwGwbZ10asxlgo(kq9htS01QIInmLM2Ka1FmXsxBktmPQCw9cy0IqktmPse3bsbmS07RwesPZAnDLUwi4iyyHo13WcDqATrGyqIckgq6AHFsO6G9QYH(nwqAaPRf(jHQd2Rkh63yrD036f)u6WhGkA06iwGwb(jHQdsRncedA0rhPH6fWara(jHQdvKOmM5m8MlPQSkQsqhCgHgToIfOvG3CjvLvrvc6G0AJaXGkxtdiDTy44Ra1FmXsxRkk2WuAAtkQKUwUMgq6AXWXxbQ)yILUwvuSHP00M0iufJkpp95AAaPRfdhFfO(Jjw6AvrXgMstBsd6W09CVVCnnG01IHJVcu)XelDTQOydtPPnPCF0iufdxtdiDTy44Ra1FmXsxRkk2WuAAtYwaHLZckGfcCnnG01IHJVcu)XelDTQOydtPPnjGfckdiDTQqJLuw7tALR3NjbZ10asxlgo(kq9htS01QIInmLM2KI0)QrWWskDwB0rAOEbmqeGyqDGyKJzodJjt69vnJGZiUMgq6AXWXxbQ)yILUwvuSHP00MuK(xncgwsPZAhZCggxIclhzpdNrCnnG01IHJVcu)XelDTQOydtPPnPi9VAemSKsN1oM5mms)Rabd)HhzabjWWIs6p90yMZqq9htS01cp6B9I5AAaPRfdhFfO(Jjw6AvrXgMstBsrXfTnIv5G9jmxtdiDTy44Ra1FmXsxRkk2WuAAtk3hPgbdlPmXKQYz1lGrlcP0zTJzodhbdl0P(gwOdIfd8SweqoM5mmUefwoYEgYujwK6mM5mms)Rabd)Hhzabz0rAOEbmqeGr6F1iyybjkJzodhbdl0P(gwOdE036f)u6qe0n0OFbmWJ(wV4NshIGUHkxtdiDTy44Ra1FmXsxRkk2WuAAtk3hPgbdlPmXKkrChifWWsVVAriLoRDmZz4iyyHo13WcDqSyGN1IasumG01cXG6aXqcXeyk9(I0asxledQdedjetGPqQJ(wV4NshIGUHg9yMZWrWWcDQVHf6Gh9TEXpLoebDdvUMgq6AXWXxbQ)yILUwvuSHP00MeguhioLoRDmZzyCjkSCK9mKPsSirbuvGPsSWCFKAemSap6B9IFcyyrj9NqJ2asxlm3hPgbdlqqSDVe(X0rLRPbKUwmC8vG6pMyPRvffByknTjL7JuJGHLuMysLiUdKcyyP3xTiKYetQkNvVagTiKsN1oM5mCemSqN6ByHoiwmWZpIasuIosd1lGbIaedQdeJuNXmNHXLOWYr2ZWzesDmG01cXG6aXqcXeyk9(Ig9yMZWrWWcDQVHf6Gh9TEXpLoebDdvUMgq6AXWXxbQ)yILUwvuSHP00MuO1O3x1O(Ju6S2XmNHG6pMyPRfE036f)0lGb(neJ0asRbPOL(nHFebUMgq6AXWXxbQ)yILUwvuSHP00MeZzV1IvJJmjoLoRDmZziO(Jjw6AHh9TEXp9cyGFdXCnnG01IHJVcu)XelDTQOydtPPnjmOoqmxtUMpeU)HP(Jjw6A5(OydtCF0rr2ryU3gDOLMWCFIwI5EJ7zOGPFkCVetl3hS5cIjm33RuCVetC)dt9htS01Y9y6H1jTaIRPbKUwmeu)XelDTQOydtAd9BSGv6YjZ7NwjLoRDmZziO(Jjw6AHmvILRPbKUwmeu)XelDTQOydtPPnjGfckdiDTQqJLuw7tAhFfO(Jjw6AvrXgMsPZAnDLUwi4iyyHo13WcDqATrGyqkwGwbMd2Nu1cP1gbIbPoegtlGGF6xN(QkRctqZOyoY(y430L1X10asxlgcQ)yILUwvuSHP00M0iufJQYkjMu0sF95AAaPRfdb1FmXsxRkk2WuAAt6t)60xvzvycAgfZr2hZ10asxlgcQ)yILUwvuSHP00M070oM2wvLvMUsxjXCnnG01IHG6pMyPRvffByknTjDZLuvwfvjOlLoRDmZziO(Jjw6AHmvILRPbKUwmeu)XelDTQOydtPPnjGfckdiDTQqJLuw7tAnG0AqkXc0k4u6SwumDLUwi4iyyHo13WcDqATrGyqoM5mCemSqN6ByHoiwmWZpQfrqfnADmDLUwi4iyyHo13WcDqATrGy4AAaPRfdb1FmXsxRkk2WuAAtcu)XelDTPmXKQYz1lGrlcPmXKkrChifWWsVVAriLoRvhcJPfqWp9RtFvLvHjOzumhzFm8B6Y6qIIoMUsxleCemSqN6ByHoiT2iqmOrRJybAfyoyFsvlKwBeigurIckgq6AHFsO6G9QYH(nwqAaPRf(jHQd2Rkh63yrD036f)K20H6gQOrRJybAf4NeQoiT2iqmOIeLXmNH3CjvLvrvc6GZi0O1rSaTc8MlPQSkQsqhKwBeigu5AAaPRfdb1FmXsxRkk2WuAAtcu)XelDTPmXKQYz1lGrlcPmXKkrChifWWsVVAriLoRLWyAbe8t)60xvzvycAgfZr2hd)MUSoKOmM5m8MlPQSkQsqhCgHgToIfOvG3CjvLvrvc6G0AJaXGkxtdiDTyiO(Jjw6AvrXgMstBsrL01Y10asxlgcQ)yILUwvuSHP00M0iufJkpp95AAaPRfdb1FmXsxRkk2WuAAtAqhMUN79LRPbKUwmeu)XelDTQOydtPPnPCF0iufdxtdiDTyiO(Jjw6AvrXgMstBs2ciSCwqbSqGRPbKUwmeu)XelDTQOydtPPnjGfckdiDTQqJLuw7tALR3NjbZ10asxlgcQ)yILUwvuSHP00MuoyFclx)mLsN1IckIfOvG5G9jvKjGyiT2iqminG0AqkAPFt4hFaQOrBaP1Gu0s)MWpIOrf5yMZW4suy5i7z4rgqqQJPR01cbhbdl0P(gwOdsRncedxtdiDTyiO(Jjw6AvrXgMstBsr6F1iyyjLoRDmZzyK(xbcg(dpYacYXmNHG6pMyPRfE036f)iWWIs6pX10asxlgcQ)yILUwvuSHP00MuK(xncgwsPZAhZCggxIclhzpdpYacxtdiDTyiO(Jjw6AvrXgMstBs5(i1iyyjLjMuvoREbmAriLjMujI7aPagw69vlcP0zTegtlGGF6xN(QkRctqZOyoY(y430L1HefqSDVewLpdiDTw4reGicA0Jzodhbdl0P(gwOdE036f)u6qDdn6XmNHG6pMyPRfE036f)0yMZWrWWcDQVHf6GmZZKUw0O1X0v6AHGJGHf6uFdl0bP1gbIbvKOGYyMZqq9htS01cNrirzmZzymzsVVQze8idii1Xasxlms)RgbdlWEv5q)gli1XasxledQdedjetGP07lQOrJIbKUwiguhigsiMatHuh9TEXihZCggtM07RAgbzQelYXmNHXLOWYr2ZqMkXIuhdiDTWi9VAemSa7vLd9BSGkQOY10asxlgcQ)yILUwvuSHP00MuUpsncgwszIjvLZQxaJweszIjvI4oqkGHLEF1IqkDwRoegtlGGF6xN(QkRctqZOyoY(y430L1HefDmDLUwi4iyyHo13WcDqATrGyqJwhXc0kWCW(KQwiT2iqmOIefugZCgcQ)yILUw4mcjkJzodJjt69vnJGhzabPogq6AHr6F1iyyb2Rkh63ybPogq6AHyqDGyiHycmLEFrfnAumG01cXG6aXqcXeykK6OV1lg5yMZWyYKEFvZiitLyroM5mmUefwoYEgYujwK6yaPRfgP)vJGHfyVQCOFJfurfvUMgq6AXqq9htS01QIInmLM2KI0)QrWWskDwB0rAOEbmqeGyqDGyKJzodJjt69vnJGZiUMgq6AXqq9htS01QIInmLM2KIIlABeRYb7tyUMgq6AXqq9htS01QIInmLM2KWG6aXP0zTJzodb1FmXsxl8OV1l(rGHfL0Fc5yMZqq9htS01cNrOrpM5meu)XelDTqMkXY10asxlgcQ)yILUwvuSHP00MuO1O3x1O(Ju6S2XmNHG6pMyPRfE036f)0lGb(neJ0asRbPOL(nHFebUMgq6AXqq9htS01QIInmLM2Kyo7TwSACKjXP0zTJzodb1FmXsxl8OV1l(Pxad8Big5yMZqq9htS01cNrCnnG01IHG6pMyPRvffByknTjHb1bItPZAf7EjbgtwqIHra5jTis6iflqRaXKD9(QKAcIH0AJaXW1KRPbKUwm8QivuSHjT3CjvLvrvc64AAaPRfdVksffByknTjLd2NWY1ptP0zTOGIybAfyoyFsfzcigsRncedsdiTgKIw63e(reqfnAdiTgKIw63e(refQihZCggxIclhzpdpYacxtdiDTy4vrQOydtPPnPi9VAemSKsN1oM5mmUefwoYEgEKbeUMgq6AXWRIurXgMstBs5(i1iyyjLjMuvoREbmAriLjMujI7aPagw69vlcP0zTOaQkWujwiO(Jjw6AHh9TEXpMoA05(iSyNqh0asRbHCmZz4nxsvzvuLGo4mcvKOOZyMZWyYKEFvZi4rgqqQZyMZW4suy5i7z4rgqqQt0rAOQCw9cyG5(i1iyybjkgq6AH5(i1iyybcIT7LWpQ9bOrJIbKUwyuCrBJyvoyFcdbX29s4h1IasXc0kWO4I2gXQCW(egsRncedQOrJIybAfOfieJLZW6QHv55PpKwBeigKGQcmvIfYC2BTy14itIHhzm6JkA0OiwGwbIj769vj1eedP1gbIbPy3ljWyYcsmmcipPfrshv0OrrSaTcm3hHf7e6G0AJaXGm3hHf7e6GgqAniurfvUMgq6AXWRIurXgMstBsaleugq6AvHglPS2N0AaP1GuIfOvWCnnG01IHxfPIInmLM2KI0)QrWWskDw7yMZWi9Vcem8hEKbeKadlkP)0tJzodJ0)kqWWF4rFRxmYXmNH3CjvLvrvc6Gh9TEXpcmSOK(tCnnG01IHxfPIInmLM2KY9rQrWWsktmPQCw9cy0IqktmPse3bsbmS07RwesPZArbuvGPsSqq9htS01cp6B9IFmD0OZ9ryXoHoObKwdc5yMZWBUKQYQOkbDWzeQirzmZzymzsVVQze8idiirrS7LeymzbjggbKh1IiPJgToIfOvGyYUEFvsnbXqATrGyqfvUMgq6AXWRIurXgMstBs5(i1iyyjLjMuvoREbmAriLjMujI7aPagw69vlcP0zTOaQkWujwiO(Jjw6AHh9TEXpMoA05(iSyNqh0asRbHCmZz4nxsvzvuLGo4mcvKIfOvGyYUEFvsnbXqATrGyqk29scmMSGedJaYtArK0rIYyMZWyYKEFvZi4rgqqQJbKUwiguhigsiMatP3x0O1zmZzymzsVVQze8idii1zmZzyCjkSCK9m8idiOY10asxlgEvKkk2WuAAtks)RgbdlP0zTrhPH6fWaraIb1bIroM5mmMmP3x1mcoJqkwGwbIj769vj1eedP1gbIbPy3ljWyYcsmmcipPfrshjk6iwGwbMd2NurMaIH0AJaXGgTbKwdsrl9BcRfbu5AAaPRfdVksffByknTjffx02iwLd2NWP0zT6eDKgQxadebyuCrBJyvoyFcJCmZzymzsVVQze8idiCnnG01IHxfPIInmLM2KWG6aXP0zTIDVKaJjliXWiG8KwejDKIfOvGyYUEFvsnbXqATrGy4AAaPRfdVksffByknTjXC2BTy14itItPZAnG0AqkAPFt4hFaxtdiDTy4vrQOydtPPnPCW(ewU(zkLoRffXc0kWCW(KkYeqmKwBeigKgqAnifT0Vj8Jpav0OnG0AqkAPFt4h1nUMgq6AXWRIurXgMstBs5(OHfcCn5AAaPRfdXITm2XOUsmPRvBoyFclx)mLsN1IckIfOvG5G9jvKjGyiT2iqminG0AqkAPFt4hraPo5(iSyNqh0asRbHkA0gqAnifT0Vj8JikuroM5mmUefwoYEgEKbeUMgq6AXqSylJDmQRet6AttBsr6F1iyyjLoRDmZzyCjkSCK9m8idiihZCggxIclhzpdp6B9IFYasxlm3hnSqasiMatHus)jUMgq6AXqSylJDmQRet6AttBsr6F1iyyjLoRDmZzyCjkSCK9m8idiirj6inuVagicWCF0Wcb0OZ9ryXoHoObKwdcnAdiDTWi9VAemSa7vLd9BSGkxtdiDTyiwSLXog1vIjDTPPnPi9VAemSKsN1oM5mmUefwoYEgEKbeKIDVKaJjliXWiG8KwejDKIfOvGyYUEFvsnbXqATrGy4AAaPRfdXITm2XOUsmPRnnTjfP)vJGHLu6S2XmNHr6Ffiy4p8idiibgwus)PNgZCggP)vGGH)WJ(wVyUMgq6AXqSylJDmQRet6AttBs5(i1iyyjLjMuvoREbmAriLjMujI7aPagw69vlcP0zTOaQkWujwiO(Jjw6AHh9TEXpMoYXmNH3CjvLvrvc6GmvIfn6CFewStOdAaP1GqfPoIfOvGp3ltO3xiT2iqmi1rd7ABeiyUpsncgwurvf69fjkOGIbKUwyUpAyHaKqmbMsVVOrBaPRfgP)vJGHfiHycmLEFrfjkJzodJjt69vnJGhzabn6CFewStOdAaP1GqQZyMZW4suy5i7z4rgqqQZyMZWyYKEFvZi4rgqqfv0OrrSaTcet217RsQjigsRncedsXUxsGXKfKyyeqEslIKosugZCggtM07RAgbpYacsDmG01cXG6aXqcXeyk9(IgToJzodJlrHLJSNHhzabPoJzodJjt69vnJGhzabPbKUwiguhigsiMatP3xK6yaPRfgP)vJGHfyVQCOFJfK6yaPRfM7Jgwia7vLd9BSGkQOrJsUpcl2j0bnG0AqirXasxlms)RgbdlWEv5q)glOrBaPRfM7Jgwia7vLd9BSGksDgZCggtM07RAgbpYacsDgZCggxIclhzpdpYacQOY10asxlgIfBzSJrDLysxBAAtk3hPgbdlP0zTIfOvGp3ltO3xiT2iqmihZCggtM07RAgbpYacsuavfyQeleu)XelDTWJ(wV4hZZqqDei2Uxsj9Ns7bPjwGwb(CVmHEFH0AJaXGgDUpcl2j0bp6B9IFmpdb1rGy7EjL0FcnAu0rSaTc8MlPQSkQsqhKwBeig0ObvfyQel8MlPQSkQsqh8OV1l(rP)KskfttinG01cV5sQkRIQe0bbX29s4NqavKGQcmvIfcQ)yILUw4rFRx8Js)jLukMMqLRPbKUwmel2YyhJ6kXKU200MuK(xncgwsPZAJosd1lGbIaedQdeJCmZzymzsVVQzeCgHuSaTcet217RsQjigsRncedsXUxsGXKfKyyeqEslIKosuqrSaTcmhSpPImbedP1gbIbPbKwdsrl9BcRfbK6K7JWIDcDqdiTgeQOrJIbKwdsrl9Bc)eIcPoIfOvG5G9jvKjGyiT2iqmOIkxtdiDTyiwSLXog1vIjDTPPnPO4I2gXQCW(eoLoRfLXmNHXKj9(QMrWJmGGgnk6mM5mmUefwoYEgEKbeKOyaPRfM7JuJGHfii2Uxc)y6OrlwGwbIj769vj1eedP1gbIbPy3ljWyYcsmmcipPfrshvurfPoAyxBJabJIlABeRIQk07lxtdiDTyiwSLXog1vIjDTPPnjGfckdiDTQqJLuw7tAnG0AqkXc0kyUMgq6AXqSylJDmQRet6AttBsmN9wlwnoYK4u6SwdiTgKIw63e(re4AAaPRfdXITm2XOUsmPRnnTjnXKQf6NYAFsR0mewQ7RafdH4u6SwqvbMkXcb1FmXsxl8OV1l(XhKoA0IfOvG5(iSyNqhKwBeigK5(iSyNqh8OV1l(XhKoxtdiDTyiwSLXog1vIjDTPPnPjMuTq)uw7tAJkWZKGBDLyuG6hnft6AvmKgnGsPZAbvfyQeleOpiuYvBduJGHfiZ8mPRfjkGQcmvIfcQ)yILUw4rFRx8JpiD0OflqRaZ9ryXoHoiT2iqmiZ9ryXoHo4rFRx8JpiDu5AAaPRfdXITm2XOUsmPRnnTjHb1bItPZAf7EjbgtwqIHra5jTis6iflqRaXKD9(QKAcIH0AJaXW10asxlgIfBzSJrDLysxBAAtk3hnSqGRPbKUwmel2YyhJ6kXKU200MeguhiMRjxtdiDTyOC9(mjyTtmPAH(yUMgq6AXq569zsWPPnPjMuTq)uw7tAJkWZKGBDLyuG6hnft6AvmKgnGsPZA1buvGPsSqG(GqjxTnqncgwGmZZKUwhloIaUKr0iItCIZb]] )


end
