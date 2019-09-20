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


    spec:RegisterPack( "Fire", 20190920, [[dSuhHcqiPIEeqv1LuPePnrGrrf1POsSkGQIxjvvZIkYTiiP2fs)sLIHPsLJrqTmPk6zeKAAeK4AsvyBujv9nvkbJdOQ05OsQSoQKImpGk3JkSpPsDqvkHQfkvPhsqsMOkLq6IQusHnsLu6JQusrJuLsYjvPKsRuQWnPskStvQ6NQucXqvPeXsvPekpLqtvQkxvLsQ(kvsrTxH(lrdgvhMYIvQhJYKbCzOnlLpRsgTGoTOvRsjQxtqmBQ62Qy3k(TKHlWXbQYYv1ZbnDsxxjBhO8DQuJNkjNxQK1RsPMpq2pIJch7lkcykgVVN3jSR7oxxpVJk8D356fg8nkQDfGrXaJje7cJIJDWOORnFmkgyD5ldi2xuewRNHrXqvdGUMU5MRudxBkRo3aZZYBAwd7TMEdmpSBII7v61BTtChfbmfJ33Z7e21DNRRN3rf(U7C9cl0rrBPH1hffZZYBAwJq1BnnkgMaa4e3rraeYIIGFc31Mps4Ug2fs6a8t4HQgaDnDZnxPgU2uwDUbMNL30Sg2Bn9gyEy3q6a8t4IyGINn(eEpVZjcVN3jSRJ0bPdWpHlufAZfcDnr6a8t4c1e(ToejCnpOuljqIe(BAi(eUgAdHR2FHkvZdk1scKiH3QNW9gufQHiRgac32Pp1Ui8f0Uqink6tOcJ9fftfpqPVCld(S(u7k2x8EHJ9ffXX2Eei2Bu0yAwtuutaeQ1FKScaDvuK9PIFArrwvEGY9qz1zVGAwd9XJLdKW7MWbZ(02EKwJCbrjBPvRr4Gar4Q5XrPT8rOAVIpfhB7racxaH3YhHQ9k(0hpwoqcVBchm7tB7rAnYfeLSLwTwuCSdgf1eaHA9hjRaqxf1499m2xuehB7rGyVrrJPznrrwxmFPFnjtU9guJISpv8tlkYQYduUhkRo7fuZAOpESCGeE3eoy2N22J0AKlikzlTAncheicxnpokTLpcv7v8P4yBpcq4ci8w(iuTxXN(4XYbs4Dt4GzFABpsRrUGOKT0Q1IIyRHmvo2bJISUy(s)AsMC7nOg1Ogfz1zVGAwJmi0GySV49ch7lkIJT9iqS3Oi7tf)0II7vRrz1zVGAwdfOCprrJPznrrFEfQq5T8c46GJg1499m2xu0yAwtuC7RcqwnPgIsCWtxrrCSThbI9g149cDSVOOX0SMO4bp13LSAs)ILasGhTdmkIJT9iqS3OgVxOe7lkIJT9iqS3O4cIs3HPhLmdQ5CfffokY(uXpTOil0(les4D7GWfMWfq4ot4ot4gtZAOT8r52BqLYcT)cHY2BmnRX8eE)eUZe(E1AuwD2lOM1qF8y5ajCHAcFVAn62BqfF5XGk(uG1BAwdH7cHFlLWzv5bk3dTLpk3EdQuG1BAwdHlut4ot47vRrz1zVGAwd9XJLdKWDHWVLs4ot47vRr3EdQ4lpguXNcSEtZAiCHAc)oApiCxiCxi8UDq43r4Gar4Ds42TXpvKU9guXxEmOIpfhB7racheicVtcxnpokT5TdkRHIJT9iaHdceHVxTgLvN9cQzn0hpwoqchCoi89Q1OBVbv8LhdQ4tbwVPzneoiqe(E1A0T3Gk(YJbv8PpESCGeo4i87O9GWbbIWrWBLbbianSRa81WhnaP7pHQ73cGeUacNvLhOCp0WUcWxdF0aKU)eQUFlakf67UtyHspPpESCGeo4i8Eq4Uq4ci89Q1OS6SxqnRHUciCbeUZeENeUX0SgkKvplKIUczlnNlcxaH3jHBmnRHg01xBVbvAoYMpVcvcxaHVxTgnennNl5kGUciCqGiCJPznuiREwifDfYwAoxeUacFVAnAyPsO(Ojekq5EiCbeUZe(E1A0q00CUKRakq5EiCqGiC724Nks3EdQ4lpguXNIJT9iaH7cHdceHB3g)ur62BqfF5XGk(uCSThbiCbeUAECuAZBhuwdfhB7racxaHBmnRHg01xBVbvAoYMpVcvcxaHVxTgnennNl5kGcuUhcxaHVxTgnSujuF0ecfOCpeUlrXfeLvRjVyarrHJIgtZAIIT8r52BqnQX77rSVOio22JaXEJISpv8tlkUxTgLvN9cQznuGY9efnMM1ef)1GYQjdk34h149U(yFrrCSThbI9gfxqu6om9OKzqnNROOWrrJPznrXw(OC7nOgfzFQ4Nwu0Un(PI0T3Gk(YJbv8P4yBpcq4ciC184O0M3oOSgko22JaeUacFVAn62BqfF5XGk(uGY9q4ciCNjC184O0FnOSAYGYn(uCSThbiCbeUX0Sg6Vguwnzq5gFk6kKT0CUiCbeUX0Sg6Vguwnzq5gFk6kKTuu(4XYbs4GJWVJ66jCqGiCNjCwvEGY9qz1zVGAwd9rdOlcheicFVAnkRo7fuZAORac3fcxaH3jHRMhhL(RbLvtguUXNIJT9iaHlGW7KWnMM1qd66RT3GknhzZNxHkHlGW7KWnMM1qB5JBZ7P5iB(8kujCxIA8(BHyFrrCSThbI9gfnMM1efzM3lnMM1i9juJI(eQYXoyu0yAcgkvZJJcJA8EW3yFrrCSThbI9gfxqu6om9OKzqnNROOWrr2Nk(PffDMWDMWnMM1qpOI1tZr285vOs4ciCJPzn0dQy90CKnFEfQYhpwoqchCoi87O9GWDHWbbIW7KWvZJJspOI1tXX2EeGWDHWfq4ot47vRr)1GYQjdk34txbeoiqeENeUAECu6Vguwnzq5gFko22JaeUlrXfeLvRjVyarrHJIgtZAIIS6SxqnRjQX7DDX(IIgtZAIIbLM1efXX2Eei2BuJ3l8DX(IIgtZAIIBFvaY267kkIJT9iqS3OgVxyHJ9ffnMM1ef34dXxi5CffXX2Eei2BuJ3lCpJ9ffnMM1efB5JBFvarrCSThbI9g149cl0X(IIgtZAII2WqO(MxYmVpkIJT9iqS3OgVxyHsSVOio22JaXEJIgtZAIImZ7LgtZAK(eQrrFcv5yhmkQFocbvyuJ3lCpI9ffXX2Eei2BuK9PIFArrNjCNjC184O0M3oOmWuwifhB7racxaHBmnbdL4GNeHeE3eEpjCxiCqGiCJPjyOeh8KiKW7MWD9eUleUacFVAnAyPsO(Oje6JgtjCbeENeUDB8tfPBVbv8LhdQ4tXX2EeikAmnRjk282bH6NcbJA8EHD9X(II4yBpce7nkY(uXpTO4E1A0GU(I5n4H(OXucxaHVxTgLvN9cQzn0hpwoqcVBcNzqvQ5bJIgtZAIIbD912BqnQX7f(wi2xuehB7rGyVrr2Nk(Pff3RwJgwQeQpAcH(OX0OOX0SMOyqxFT9guJA8EHbFJ9ffXX2Eei2BuCbrP7W0JsMb1CUIIchfzFQ4NwueHqCyi9GN67swnPFXsajWJ2bsp2TC9eUac3zcNfA)fcLT3yAwJ5j8UjCHPcnHdceHVxTgD7nOIV8yqfF6JhlhiHdoc)oApiCqGi89Q1OS6SxqnRH(4XYbs4GJW3RwJU9guXxEmOIpfy9MM1q4Gar4Ds42TXpvKU9guXxEmOIpfhB7rac3fcxaH7mH7mHVxTgLvN9cQzn0vaHlGWDMW3RwJgIMMZLCfqF0ykHlGW7KWnMM1qd66RT3GknhzZNxHkHlGW7KWnMM1qHS6zHu0viBP5Cr4Uq4Gar4ot4gtZAOqw9Sqk6kKTuu(4XYbs4ci89Q1OHOP5CjxbuGY9q4ci89Q1OHLkH6JMqOaL7HWfq4Ds4gtZAObD912BqLMJS5ZRqLWDHWDHWDjkUGOSAn5fdikkCu0yAwtuSLpk3EdQrnEVWUUyFrrCSThbI9gfxqu6om9OKzqnNROOWrr2Nk(Pff7KWriehgsp4P(UKvt6xSeqc8ODG0JDlxpHlGWDMW7KWTBJFQiD7nOIV8yqfFko22JaeoiqeENeUAECuAZBhuwdfhB7rac3fcxaH7mH7mHVxTgLvN9cQzn0vaHlGWDMW3RwJgIMMZLCfqF0ykHlGW7KWnMM1qd66RT3GknhzZNxHkHlGW7KWnMM1qHS6zHu0viBP5Cr4Uq4Gar4ot4gtZAOqw9Sqk6kKTuu(4XYbs4ci89Q1OHOP5CjxbuGY9q4ci89Q1OHLkH6JMqOaL7HWfq4Ds4gtZAObD912BqLMJS5ZRqLWDHWDHWDjkUGOSAn5fdikkCu0yAwtuSLpk3EdQrnEFpVl2xuehB7rGyVrr2Nk(PffdEem5fdGkmfYQNfs4ci89Q1OHOP5Cjxb0vqu0yAwtumORV2EdQrnEFpfo2xu0yAwtumiSWjDLS5TdcJI4yBpce7nQX77zpJ9ffXX2Eei2BuK9PIFArX9Q1OS6SxqnRH(4XYbs4Dt4mdQsnpiHlGW3RwJYQZEb1Sg6kGWbbIW3RwJYQZEb1Sgkq5EIIgtZAIIqw9SWOgVVNcDSVOio22JaXEJISpv8tlkUxTgLvN9cQzn0hpwoqchCe(fdGEmxr4ciCJPjyOeh8KiKW7MWfokAmnRjk6tWY5sURZoQX77Pqj2xuehB7rGyVrr2Nk(Pff3RwJYQZEb1Sg6JhlhiHdoc)IbqpMRiCbe(E1AuwD2lOM1qxbrrJPznrrG3UQbk3pAAyuJ33ZEe7lkIJT9iqS3Oi7tf)0IIQ9xOsdrZRH0aMs4GZbHl03r4ciC184OuiAFoxsTwSqko22JarrJPznrriREwyuJAu0yAcgkvZJJcJ9fVx4yFrrCSThbI9gfzFQ4Nwu0yAcgkXbpjcj8UjCHjCbe(E1AuwD2lOM1qbk3dHlGWDMWzv5bk3dLvN9cQzn0hpwoqcVBcNvLhOCpuFcwoxYDD2uG1BAwdHdceHZQYduUhkRo7fuZAOpAaDr4UefnMM1ef9jy5Cj31zh1499m2xuehB7rGyVrr2Nk(Pff3RwJ(RbLvtguUXNUciCbeUZeElFeQ2R4tF8y5aj8UjCwvEGY9qpOI1tbwVPzneoiqeENeElFeQ2R4tnMMGHeUleoiqeoRkpq5EO)Aqz1KbLB8PpESCGeE3eUMhuQLeircxaHBmnRH(RbLvtguUXNYcT)cHeo4iCHjCqGiCNjCwvEGY9qpOI1tbwVPzneo4iCwvEGY9qz1zVGAwd9XJLdKWbbIWzv5bk3dLvN9cQzn0hnGUiCxiCbeENeUAECu6Vguwnzq5gFko22JaeUac3zcNvLhOCp0dQy9uG1BAwdHdocVLpcv7v8PpESCGeoiqeENeUAECuAlFeQ2R4tXX2EeGWbbIW7KWB5Jq1EfFQX0emKWDjkAmnRjkEqfRpQrnkMkEGYW8kug8z9P2vSV49ch7lkIJT9iqS3Oi7tf)0IIot4Q5XrP)Aqz1KbLB8P4yBpcq4ciCwvEGY9qz1zVGAwd9XJLdKWbNdc3yAwd9xdkRMmOCJpLzqvQ5bjCqGiCwvEGY9qz1zVGAwd9rdOlc3fcxaH3jH3YhHQ9k(uJPjyiHdceHVxTgLvN9cQzn0vqu0yAwtuKzEV0yAwJ0Nqnk6tOkh7GrXuXduYQZEb1SMOgVVNX(IIgtZAIIliktfpWOio22JaXEJA8EHo2xuehB7rGyVrrJPznrr72Wq7nOSvJkRMmOCJFuK9PIFArrwvEGY9qz1zVGAwd9XJLdKWbNdcVheE)eUW9GWbFiCWSpTThPTAujqT2EuwJCbXO4yhmkA3ggAVbLTAuz1KbLB8JA8EHsSVOio22JaXEJIgtZAIIFPSFbveqcwvavjbkVpkY(uXpTOiRkpq5EOS6SxqnRH(4XYbs4Dt4GzFABpsRrUGOKT0Q1IIJDWO4xk7xqfbKGvfqvsGY7JA8(Ee7lkIJT9iqS3OOX0SMOObERmOuCu5yln9lyuK9PIFArrwvEGY9qz1zVGAwd9XJLdKW7MWbZ(02EKwJCbrjBPvRffh7Grrd8wzqP4OYXwA6xWOgV31h7lkIJT9iqS3OOX0SMOimmbdFjy4uh5J(KffzFQ4NwuKvLhOCpuwD2lOM1qF8y5aj8UjCWSpTThP1ixquYwA1ArXXoyuegMGHVemCQJ8rFYIA8(BHyFrrCSThbI9gfnMM1efdT)utYKa4Xu8tZN3g)Oi2AitLJDWOyO9NAsMeapMIFA(824h149GVX(II4yBpce7nkAmnRjkEmFR(dcidX38aqPhVC)wamkY(uXpTOiRkpq5EOS6SxqnRH(4XYbs4D7GW7rpiCbe(E1AuwD2lOM1qbk3dHlGWzv5bk3dLvN9cQzn0hpwoqcVBchm7tB7rAnYfeLSLwTwuCSdgfpMVv)bbKH4BEaO0JxUFlag149UUyFrrCSThbI9gfnMM1efTHL4OsHmLkRM0DcbQtuK9PIFArrwvEGY9qz1zVGAwd9XJLdKW72bH3JEq4ci89Q1OS6SxqnRHcuUhcxaHZQYduUhkRo7fuZAOpESCGeE3eoy2N22J0AKlikzlTATO4yhmkAdlXrLczkvwnP7ecuNOgVx47I9ffXX2Eei2Bu0yAwtuCbrzQ4jkY(uXpTOiRkpq5EOS6SxqnRH(4XYbs4D7GWfk9GWfq47vRrz1zVGAwdfOCpeUacNvLhOCpuwD2lOM1qF8y5aj8UjCWSpTThP1ixquYwA1ArXXoyuCW1BEjSRXcGOeNqBy4h1OgfbWMT8ASV49ch7lkAmnRjkYQ1O4ddqVpkIJT9iqS3OgVVNX(II4yBpce7nkAmnRjkYmVxAmnRr6tOgf9juLJDWOyQ4bkdZRqzWN1NAxrnEVqh7lkIJT9iqS3Oi7tf)0II7vRrz1zVGAwdfOCprrJPznrXt(F9Y8yxyuJ3luI9ffXX2Eei2BuK9PIFArrwvEGY9qz1zVGAwd9XJLdKWbhHl8DeoiqeUMhuQLeirchCeoRkpq5EOS6SxqnRH(4XYbgfnMM1efVw2dK2iRM0Un(Lgg1499i2xu0yAwtuKvddh9nfbKnVDWOio22JaXEJA8ExFSVOOX0SMOyRyliciTBJFQOCJ2jkIJT9iqS3OgV)wi2xu0yAwtumy9zRRCUKBVb1Oio22JaXEJA8EW3yFrrJPznrXpdc8OmhjmWyyuehB7rGyVrnEVRl2xu0yAwtuudr5A21AaKT6zyuehB7rGyVrnEVW3f7lkAmnRjk6UEpayyoYhH1yddJI4yBpce7nQX7fw4yFrrCSThbI9gfzFQ4NwuunpokTLpcv7v8P4yBpcq4ci8w(iuTxXN(4XYbs4Dt4TL3lFKfA)fk18GeoiqeoRkpq5EOS6SxqnRH(4XYbs4Dt4GzFABpsz1zVGAwJ8RajBPvRr4ci89Q1OS6SxqnRHcuUhcheicxZdk1scKiHdocNvLhOCpuwD2lOM1qF8y5ajCbe(E1AuwD2lOM1qbk3tu0yAwtu8xdkRMmOCJFuJ3lCpJ9ffXX2Eei2BuK9PIFArrNjC184O0FnOSAYGYn(uCSThbiCbeoRkpq5EOS6SxqnRH(4XYbs4GZbHBmnRH(RbLvtguUXNYmOk18GeoiqeoRkpq5EOS6SxqnRH(Ob0fH7cHlGW7KWB5Jq1EfFQX0emKWbbIW3RwJYQZEb1Sg6kikAmnRjkYmVxAmnRr6tOgf9juLJDWOiRo7fuZAKbHgeJA8EHf6yFrrCSThbI9gfxqu6om9OKzqnNROOWrr2Nk(PffDMWriehgsp4P(UKvt6xSeqc8ODG0JDlxpHdceHJqiomKEWt9DjRM0VyjGe4r7aPNCQNWfq42TXpvKU9guXxEmOIpfhB7rac3fcxaHZcT)cHeUdc)yUsYcT)cHeUacVtcFVAnAyPsO(Oje6JgtjCbeENeUZe(E1A0q00CUKRa6JgtjCbeUZe(E1AuwD2lOM1qxbeUac3zc3yAwdTLpUnVNMJS5ZRqLWbbIWnMM1qd66RT3GknhzZNxHkHdceHBmnRHcz1ZcPORq2sZ5IWDHWbbIWv7VqLgIMxdPbmLWbNdcxOVJWfq4gtZAOqw9Sqk6kKT0CUiCxiCxiCbeENeUZeENe(E1A0q00CUKRa6JgtjCbeENe(E1A0WsLq9rti0hnMs4ci89Q1OS6SxqnRHcuUhcxaH7mHBmnRH2Yh3M3tZr285vOs4Gar4gtZAObD912BqLMJS5ZRqLWDHWDjkUGOSAn5fdikkCu0yAwtuSLpk3EdQrnEVWcLyFrrCSThbI9gfxqu6om9OKzqnNROOWrr2Nk(PffB5Jq1EfFQX0emKWfq4Sq7VqiH3TdcxycxaH7mH3jHdM9PT9iTLpk3EdQYGQ85Cr4Gar47vRr)1GYQjdk34txbeUleUac3zcVtc3Un(PI0T3Gk(YJbv8P4yBpcq4Gar47vRr3EdQ4lpguXN(4XYbs4GJWVJ2dc3fcxaH7mH3jHBmnRH2Yh3M3trxHSLMZfHlGW7KWnMM1qd66RT3GknhzZNxHkHlGW3RwJgIMMZLCfqxbeoiqeUX0SgAlFCBEpfDfYwAoxeUacFVAnAyPsO(Ojekq5EiCqGiCJPzn0GU(A7nOsZr285vOs4ci89Q1OHOP5CjxbuGY9q4ci89Q1OHLkH6JMqOaL7HWDjkUGOSAn5fdikkCu0yAwtuSLpk3EdQrnEVW9i2xuehB7rGyVrr2Nk(Pff3RwJ(RbLvtguUXNUciCbe(E1AuwD2lOM1qbk3tu0yAwtuKzEV0yAwJ0Nqnk6tOkh7GrXVcKbHgeJA8EHD9X(II4yBpce7nkwbrriQrrJPznrrWSpTThJIGz(fgfvZJJs)1GYQjdk34tXX2EeGWfq4SQ8aL7H(RbLvtguUXN(4XYbs4GJWzv5bk3dTLpk3EdQ02Y7LpYcT)cLAEqcxaH7mHZQYduUhkRo7fuZAOpESCGeE3eoy2N22JuwD2lOM1i)kqYwA1AeoiqeElFeQ2R4tnMMGHeUleUac3zcNvLhOCp0FnOSAYGYn(0hpwoqchCeUMhuQLeircheic3yAwd9xdkRMmOCJpLfA)fcj8Uj87iCxiCqGiCwvEGY9qz1zVGAwd9XJLdKWbhHBmnRH2YhLBVbvAB59YhzH2FHsnpiH3pHZQYduUhAlFuU9guPaR30Sgch8HWTBJFQiD7nOIV8yqfFko22JaeUacVtcVLpcv7v8PgttWqcxaHZQYduUhkRo7fuZAOpESCGeo4iCnpOuljqIeoiqeUAECuAlFeQ2R4tXX2EeGWfq4T8rOAVIp1yAcgs4ci8w(iuTxXN(4XYbs4GJWzv5bk3dTLpk3EdQ02Y7LpYcT)cLAEqcVFcNvLhOCp0w(OC7nOsbwVPzneo4dHB3g)ur62BqfF5XGk(uCSThbIIGzVCSdgfB5JYT3GQmOkFoxrnEVW3cX(II4yBpce7nkwbrriQrrJPznrrWSpTThJIGz(fgfvZJJs)1GYQjdk34tXX2EeGWfq4SQ8aL7H(RbLvtguUXN(4XYbs4GJWzv5bk3dniSWjDLS5TdcPTL3lFKfA)fk18GeUacNvLhOCpuwD2lOM1qF8y5aj8UjCWSpTThPS6SxqnRr(vGKT0Q1iCbeUZeoRkpq5EO)Aqz1KbLB8PpESCGeo4iCnpOuljqIeoiqeUX0Sg6Vguwnzq5gFkl0(les4Dt43r4Uq4Gar4SQ8aL7HYQZEb1Sg6JhlhiHdoc3yAwdniSWjDLS5TdcPTL3lFKfA)fk18GeUacNvLhOCpuwD2lOM1qF8y5ajCWr4AEqPwsGeJIGzVCSdgfdclCsxjdQYNZvuJ3lm4BSVOio22JaXEJIgtZAIImZ7LgtZAK(eQrrFcv5yhmkcvBaShq(LAAwtuJAumv8aLS6SxqnRj2x8EHJ9ffXX2Eei2BuCSdgfZRj1Sg5XUqOSTGyu0yAwtumVMuZAKh7cHY2cIrnEFpJ9ffXX2Eei2Bu0yAwtumSRa81WhnaP7pHQ73cGrr2Nk(Pff3RwJYQZEb1Sg6kGWfq4gtZAOT8r52BqLYcT)cHeUdc)ocxaHBmnRH2YhLBVbv6JSq7VqPMhKW7MWVya0J5QO4yhmkg2va(A4JgG09Nq19BbWOgVxOJ9ffXX2Eei2BuCSdgfTBVEudlOeMZfcid8RJDHrXfeLvRjVyarrHJIgtZAII2TxpQHfucZ5cbKb(1XUWOi7tf)0II7vRrz1zVGAwdDfq4Gar4gtZAOhuX6P5iB(8kujCbeUX0Sg6bvSEAoYMpVcv5JhlhiHdohe(D0Ee149cLyFrrCSThbI9gfnMM1efV8gqAA9q52aUWO4cIYQ1KxmGOOWrr2Nk(Pff3RwJYQZEb1Sg6kGWbbIWnMM1qpOI1tZr285vOs4ciCJPzn0dQy90CKnFEfQYhpwoqchCoi87O9ikITgYu5yhmkE5nG006HYTbCHrnEFpI9ffXX2Eei2Bu0yAwtu8YBaPP1dLheW8(SMO4cIYQ1KxmGOOWrr2Nk(Pff3RwJYQZEb1Sg6kGWbbIWnMM1qpOI1tZr285vOs4ciCJPzn0dQy90CKnFEfQYhpwoqchCoi87O9ikITgYu5yhmkE5nG006HYdcyEFwtuJ376J9ffXX2Eei2BuCSdgf3MhB5JY9BdlmkUGOSAn5fdikkCu0yAwtuCBESLpk3VnSWOi7tf)0II7vRrz1zVGAwdDfq4Gar4gtZAOhuX6P5iB(8kujCbeUX0Sg6bvSEAoYMpVcv5JhlhiHdohe(D0Ee1493cX(II4yBpce7nko2bJIWWIjKDQ4dLnBUIIlikRwtEXaIIchfnMM1efHHfti7uXhkB2CffzFQ4NwuCVAnkRo7fuZAORacheic3yAwd9GkwpnhzZNxHkHlGWnMM1qpOI1tZr285vOkF8y5ajCW5GWVJ2JOgVh8n2xuehB7rGyVrXXoyuuVTniuUTxiWGCqyuCbrz1AYlgquu4OOX0SMOOEBBqOCBVqGb5GWOi7tf)0II7vRrz1zVGAwdDfq4Gar4gtZAOhuX6P5iB(8kujCbeUX0Sg6bvSEAoYMpVcv5JhlhiHdohe(D0Ee149UUyFrrCSThbI9gfh7GrrByjoQuitPYQjDNqG6efxquwTM8IbeffokAmnRjkAdlXrLczkvwnP7ecuNOi7tf)0II7vRrz1zVGAwdDfq4Gar4gtZAOhuX6P5iB(8kujCbeUX0Sg6bvSEAoYMpVcv5JhlhiHdohe(D0Ee149cFxSVOio22JaXEJIJDWO4GR38syxJfarjoH2WWpkUGOSAn5fdikkCu0yAwtuCbrzQ4jkY(uXpTO4E1AuwD2lOM1qxbeoiqeUX0Sg6bvSEAoYMpVcvcxaHBmnRHEqfRNMJS5ZRqv(4XYbs4GZbHFhThrnEVWch7lkIJT9iqS3O4yhmkEmFR(dcidX38aqPhVC)wamkUGOSAn5fdikkCu0yAwtu8y(w9heqgIV5bGspE5(TayuK9PIFArX9Q1OS6SxqnRHUciCqGiCJPzn0dQy90CKnFEfQeUac3yAwd9GkwpnhzZNxHQ8XJLdKWbNdc)oApIAuJIFfidcnig7lEVWX(IIgtZAII)Aqz1KbLB8JI4yBpce7nQX77zSVOio22JaXEJISpv8tlk6mHRMhhL282bLbMYcP4yBpcq4ciCJPjyOeh8KiKW7MWfMWbbIWnMMGHsCWtIqcVBcxOq4Uq4ci89Q1OHLkH6JMqOpAmnkAmnRjk282bH6NcbJA8EHo2xuehB7rGyVrr2Nk(Pff3RwJgwQeQpAcH(OX0OOX0SMOyqxFT9guJA8EHsSVOio22JaXEJIlikDhMEuYmOMZvuu4Oi7tf)0IIDs4ot4Q5XrPnVDqzGPSqko22JaeUac3yAcgkXbpjcj8Uj8Es4Gar4gttWqjo4jriH3nH3dc3fcxaH7mH3jH3YhHQ9k(uJPjyiHlGWzv5bk3dLvN9cQzn0hpwoqcVBc)oc3fcxaH7mH3jHVxTgnennNl5kG(OXucxaH3jHVxTgnSujuF0ec9rJPeUacVtcp4rWKvRjVya0w(OC7nOs4ciCNjCJPzn0w(OC7nOszH2FHqcVBheEpjCqGiCNjCJPzn0GWcN0vYM3oiKYcT)cHeE3oiCHjCbeUAECuAqyHt6kzZBhesXX2EeGWDHWbbIWDMWvZJJsnp6kO(g82gu2wFxuCSThbiCbeoRkpq5EOaVDvduUF00q6JgqxeUleoiqeUZeUAECukeTpNlPwlwifhB7racxaHR2FHknenVgsdykHdoheUqFhH7cH7cH7suCbrz1AYlgquu4OOX0SMOylFuU9guJA8(Ee7lkIJT9iqS3OOX0SMOiZ8EPX0SgPpHAu0Nqvo2bJIgttWqPAECuyuJ376J9ffXX2Eei2BuK9PIFArX9Q1ObD9fZBWd9rJPeUacNzqvQ5bjCWr47vRrd66lM3Gh6JhlhiHlGW3RwJ(RbLvtguUXN(4XYbs4Dt4mdQsnpyu0yAwtumORV2EdQrnE)TqSVOio22JaXEJIlikDhMEuYmOMZvuu4Oi7tf)0IIDs4ot4Q5XrPnVDqzGPSqko22JaeUac3yAcgkXbpjcj8Uj8Es4Gar4gttWqjo4jriH3nH3dc3fcxaH7mH3jH3YhHQ9k(uJPjyiHlGWzv5bk3dLvN9cQzn0hpwoqcVBc)oc3fcxaH7mHVxTgnennNl5kG(OXucxaH7mHR2FHknenVgsdykH3TdcxOVJWbbIW7KWvZJJsHO95Cj1AXcP4yBpcq4Uq4UefxquwTM8IbeffokAmnRjk2YhLBVb1OgVh8n2xuehB7rGyVrXfeLUdtpkzguZ5kkkCuK9PIFArXojCNjC184O0M3oOmWuwifhB7racxaHBmnbdL4GNeHeE3eEpjCqGiCJPjyOeh8KiKW7MW7bH7cHlGWDMW7KWB5Jq1EfFQX0emKWfq4SQ8aL7HYQZEb1Sg6JhlhiH3nHFhH7cHlGWvZJJsHO95Cj1AXcP4yBpcq4ciC1(luPHO51qAatjCW5GWf67iCbeUZe(E1A0q00CUKRa6JgtjCbeENeUX0SgkKvplKIUczlnNlcheicVtcFVAnAiAAoxYva9rJPeUacVtcFVAnAyPsO(Oje6JgtjCxIIlikRwtEXaIIchfnMM1efB5JYT3GAuJ376I9ffXX2Eei2BuK9PIFArXGhbtEXaOctHS6zHeUacFVAnAiAAoxYvaDfq4ciC184OuiAFoxsTwSqko22JaeUacxT)cvAiAEnKgWuchCoiCH(ocxaH7mH3jHRMhhL282bLbMYcP4yBpcq4Gar4gttWqjo4jriH7GWfMWDjkAmnRjkg01xBVb1OgVx47I9ffXX2Eei2BuK9PIFArXoj8GhbtEXaOctdclCsxjBE7GqcxaHVxTgnennNl5kG(OX0OOX0SMOyqyHt6kzZBheg149clCSVOio22JaXEJISpv8tlkQ2FHknenVgsdykHdoheUqFhHlGWvZJJsHO95Cj1AXcP4yBpcefnMM1efHS6zHrnEVW9m2xuehB7rGyVrr2Nk(PffnMMGHsCWtIqcVBcVNrrJPznrrG3UQbk3pAAyuJ3lSqh7lkIJT9iqS3O4cIs3HPhLmdQ5CfffokY(uXpTOOZeUAECuAZBhugyklKIJT9iaHlGWnMMGHsCWtIqcVBcVNeoiqeUX0emuIdEses4Dt49GWDHWfq4ot4SQ8aL7HYQZEb1Sg6JhlhiH3nHFhHlGW7KWB5Jq1EfFQX0emKWDHWfq47vRrdlvc1hnHqbk3dHlGWDMW7KWTBJFQiD7nOIV8yqfFko22Jaeoiqe(E1A0T3Gk(YJbv8PpESCGeo4i87O9GWDjkUGOSAn5fdikkCu0yAwtuSLpk3EdQrnEVWcLyFrrCSThbI9gfzFQ4NwuunpokT5TdkdmLfsXX2EeGWfq4gttWqjo4jriH3nH3tcheic3yAcgkXbpjcj8Uj8EefnMM1efBE7Gq9tHGrnEVW9i2xu0yAwtuSLpUnVpkIJT9iqS3Og1OO(5ieuHX(I3lCSVOOX0SMO4cIYuXdmkIJT9iqS3OgVVNX(II4yBpce7nko2bJIH2FQjzsa8yk(P5ZBJFu0yAwtum0(tnjtcGhtXpnFEB8JAuJIq1ga7bKFPMM1e7lEVWX(II4yBpce7nkY(uXpTOOZeUZeUAECuAZBhugyklKIJT9iaHlGWnMMGHsCWtIqcVBcxycxaH3jH3YhHQ9k(uJPjyiH7cHdceHBmnbdL4GNeHeE3eUqHWDHWfq47vRrdlvc1hnHqF0yAu0yAwtuS5Tdc1pfcg1499m2xuehB7rGyVrr2Nk(Pff3RwJgwQeQpAcH(OXucxaHVxTgnSujuF0ec9XJLdKWbhHBmnRH2Yh3M3trxHSLIsnpyu0yAwtumORV2EdQrnEVqh7lkIJT9iqS3Oi7tf)0II7vRrdlvc1hnHqF0ykHlGWDMWdEem5fdGkmTLpUnVNWbbIWB5Jq1EfFQX0emKWbbIWnMM1qd66RT3GknhzZNxHkH7su0yAwtumORV2EdQrnEVqj2xuehB7rGyVrr2Nk(PffzH2FHqcVBheUqt4ciCJPjyOeh8KiKW7MW7jHlGW7KWbZ(02EKgew4KUsguLpNROOX0SMOyqyHt6kzZBheg1499i2xuehB7rGyVrr2Nk(Pff3RwJgwQeQpAcH(OXucxaHR2FHknenVgsdykHdoheUqFhHlGWvZJJsHO95Cj1AXcP4yBpcefnMM1efd66RT3GAuJ376J9ffXX2Eei2BuK9PIFArX9Q1ObD9fZBWd9rJPeUacNzqvQ5bjCWr47vRrd66lM3Gh6Jhlhyu0yAwtumORV2EdQrnE)TqSVOio22JaXEJIlikDhMEuYmOMZvuu4Oi7tf)0IIot4SQ8aL7HYQZEb1Sg6JhlhiH3nHFhHlGW3RwJ(RbLvtguUXNcuUhcxaH3jH3YhHQ9k(uJPjyiH7cHlGW7KWvZJJsfsoa(CUO4yBpcq4ci8ojCWSpTThPT8r52BqvguLpNlcxaH7mH7mH7mHBmnRH2Yh3M3trxHSLMZfHdceHBmnRHg01xBVbvk6kKT0CUiCxiCbeUZe(E1A0q00CUKRa6JgtjCxiCxiCqGiCNjC184OuiAFoxsTwSqko22JaeUacxT)cvAiAEnKgWuchCoiCH(ocxaH7mHVxTgnennNl5kG(OXucxaH3jHBmnRHcz1ZcPORq2sZ5IWbbIW7KW3RwJgwQeQpAcH(OXucxaH3jHVxTgnennNl5kG(OXucxaHBmnRHcz1ZcPORq2sZ5IWfq4Ds4gtZAObD912BqLMJS5ZRqLWfq4Ds4gtZAOT8XT590CKnFEfQeUleUleUlrXfeLvRjVyarrHJIgtZAIIT8r52BqnQX7bFJ9ffXX2Eei2BuK9PIFArr184OuHKdGpNlko22JaeUacFVAnAiAAoxYva9rJPeUacVtcVLpcv7v8PgttWqcxaH7mHZQYduUhkRo7fuZAOpESCGeE3eEB59YhzH2FHsnpiH3pH3tcVFcxnpokvi5a4Z5IIJT9iaHdceH7mH3jHRMhhL(RbLvtguUXNIJT9iaHdceHZQYduUh6Vguwnzq5gF6JhlhiH3nHR5bLAjbsKWfq4gtZAO)Aqz1KbLB8PSq7VqiHdocxyc3fcxaHZQYduUhkRo7fuZAOpESCGeE3eUMhuQLeirc3LOOX0SMOylFuU9guJA8ExxSVOio22JaXEJISpv8tlkg8iyYlgavykKvplKWfq47vRrdrtZ5sUcORacxaHRMhhLcr7Z5sQ1IfsXX2EeGWfq4Q9xOsdrZRH0aMs4GZbHl03r4ciCNjCNjC184O0M3oOmWuwifhB7racxaHBmnbdL4GNeHeUdcxycxaH3jH3YhHQ9k(uJPjyiH7cHdceH7mHBmnbdL4GNeHeo4iCHcHlGW7KWvZJJsBE7GYatzHuCSThbiCxiCxIIgtZAIIbD912BqnQX7f(UyFrrCSThbI9gfzFQ4Nwu0zcFVAnAiAAoxYva9rJPeoiqeUZeENe(E1A0WsLq9rti0hnMs4ciCNjCJPzn0w(OC7nOszH2FHqcVBc)ocheicxnpokfI2NZLuRflKIJT9iaHlGWv7VqLgIMxdPbmLWbNdcxOVJWDHWDHWDHWfq4Ds4GzFABpsdclCsxjdQYNZvu0yAwtumiSWjDLS5TdcJA8EHfo2xuehB7rGyVrrJPznrrM59sJPznsFc1OOpHQCSdgfnMMGHs184OWOgVx4Eg7lkIJT9iqS3Oi7tf)0IIgttWqjo4jriH3nHlCu0yAwtue4TRAGY9JMgg149cl0X(II4yBpce7nkAmnRjkYmVxAmnRr6tOgf9juLJDWOyQ4bk9LBzWN1NAxrnEVWcLyFrrCSThbI9gfzFQ4NwuuT)cvAiAEnKgWuchCoiCH(ocxaHRMhhLcr7Z5sQ1IfsXX2EeikAmnRjkcz1ZcJA8EH7rSVOio22JaXEJIlikDhMEuYmOMZvuu4Oi7tf)0IIot4Q5XrPnVDqzGPSqko22JaeUac3yAcgkXbpjcj8Uj8Es4Gar4gttWqjo4jriH3nH76iCxiCbeUZeoRkpq5EOS6SxqnRH(4XYbs4Dt43r4ci8oj8w(iuTxXNAmnbdjCxiCbe(E1A0WsLq9rtiuGY9q4ciCNj8ojC724Nks3EdQ4lpguXNIJT9iaHdceHVxTgD7nOIV8yqfF6JhlhiHdoc)oApiCxIIlikRwtEXaIIchfnMM1efB5JYT3GAuJ3lSRp2xuehB7rGyVrr2Nk(PffvZJJsBE7GYatzHuCSThbiCbeUX0emuIdEses4Dt49KWbbIWnMMGHsCWtIqcVBc31ffnMM1efBE7Gq9tHGrnEVW3cX(IIgtZAIIT8XT59rrCSThbI9g149cd(g7lkAmnRjkcz1ZcJI4yBpce7nQrnkg8iRoBtJ9fVx4yFrrJPznrr7z2GYCu07rMgfXX2Eei2BuJ33ZyFrrCSThbI9gfRGOie1OOX0SMOiy2N22JrrWm)cJIU(7IIGzVCSdgfz1zVGAwJ8RajBPvRf149cDSVOio22JaXEJIvqueIAu0yAwtuem7tB7XOiyMFHrre8wzqacqNsRpRfuAWG8TrHYTbCHeoiqeocERmiabOtP1N1ckV8gqAA9q52aUqcheichbVvgeGauyojuXxE5nG006HYTbCHeoiqeocERmiabOWCsOIV0Gb5BJcLBd4cjCqGiCe8wzqacqbE0aKxEdinTEOCBaxiHdceHJG3kdcqakWJgG0Gb5BJcLBd4cjCqGiCe8wzqacqbE0aKS6Sn1gfkZbMxtAeoiqeocERmiabOtP1N1cknyq(2Oq5bbmVpRHWbbIWrWBLbbiaDkT(Swq5L3astRhkpiG59zneoiqeocERmiabOWCsOIV8YBaPP1dLheW8(SgcheichbVvgeGauyojuXxAWG8TrHYdcyEFwdHdceHJG3kdcqakWJgG8YBaPP1dLheW8(SgcheichbVvgeGauGhnaPbdY3gfkpiG59zneoiqeocERmiabOapAaswD2MAJcLheW8(SgcheichbVvgeGa08AsnRrESlekBlis4Gar4i4TYGaeGQ32gek32leyqoiKWbbIWrWBLbbia1U96rnSGsyoxiGmWVo2fs4Gar4i4TYGaeGAdlXrLczkvwnP7ecuhcheichbVvgeGauyyXeYov8HYMnxeoiqeocERmiabOdUEZlHDnwaeL4eAddFcheichbVvgeGa0T5Xw(OC)2WcJIGzVCSdgfz1zVGAwJSg5cIrnEVqj2xuehB7rGyVrXkikcrnkAmnRjkcM9PT9yuemZVWOicERmiabO2THH2BqzRgvwnzq5gFcxaHdM9PT9iLvN9cQznYAKligfbZE5yhmk2QrLa1A7rznYfeJA8(Ee7lkIJT9iqS3OyfefHOgfnMM1efbZ(02EmkcM5xyuSN3r4Gpeoy2N22JuwD2lOM1iRrUGiHlGW7KWbZ(02EK2QrLa1A7rznYfej8(jCHYDeo4dHdM9PT9iTvJkbQ12JYAKlis49t49Sheo4dHJG3kdcqaQDByO9gu2QrLvtguUXNWfq4Ds4GzFABpsB1OsGAT9OSg5cIrrWSxo2bJI1ixquYwA1ArnEVRp2xuehB7rGyVrnE)TqSVOio22JaXEJIJDWOODByO9gu2QrLvtguUXpkAmnRjkA3ggAVbLTAuz1KbLB8JA8EW3yFrrJPznrXt(F9Y8yxyuehB7rGyVrnEVRl2xu0yAwtumO0SMOio22JaXEJA8EHVl2xu0yAwtumORV2EdQrrCSThbI9g1Og1Oiy4dZAI33Z7e21Dh4RW3ffDB)KZfmkER9euVIaeUW3r4gtZAiCFcviL0rum4Rw6XOi4NWDT5JeURHDHKoa)eEOQbqxt3CZvQHRnLvNBG5z5nnRH9wtVbMh2nKoa)eUigO4zJpH3Z7CIW75Dc76iDq6a8t4cvH2CHqxtKoa)eUqnHFRdrcxZdk1scKiH)MgIpHRH2q4Q9xOs18GsTKajs4T6jCVbvHAiYQbGWTD6tTlcFbTlesjDq6a8t43A4kKTueGW3yREKWz1zBkHVXRCGuc)wCgdduiHp1iuhA)PT8eUX0SgiHxJVlkPdWpHBmnRbsdEKvNTPoAEdkeshGFc3yAwdKg8iRoBt73XnTQaiDa(jCJPznqAWJS6SnTFh3yRRdoQPznKomMM1aPbpYQZ20(DCJ9mBqzok69itjDa(j8(ctiHdM9PT9iHdrfs4Ais4AEqc3uc3DyYcj8BXwds4vJWVLuUXNWHH1Ydq4q1ELW3yoxeo0adbi8w9eUgIe(GUsjCHQ6SxqnRHWdcnis6WyAwdKg8iRoBt73XnGzFABp60yh0bRo7fuZAKFfizlTAnNQahquDcmZVqhU(7iDymnRbsdEKvNTP974gWSpTThDASd6GvN9cQznYAKli6uf4aIQtGz(f6abVvgeGa0P06ZAbLgmiFBuOCBaxiiqi4TYGaeGoLwFwlO8YBaPP1dLBd4cbbcbVvgeGauyojuXxE5nG006HYTbCHGaHG3kdcqakmNeQ4lnyq(2Oq52aUqqGqWBLbbiaf4rdqE5nG006HYTbCHGaHG3kdcqakWJgG0Gb5BJcLBd4cbbcbVvgeGauGhnajRoBtTrHYCG51Kgiqi4TYGaeGoLwFwlO0Gb5BJcLheW8(SgqGqWBLbbiaDkT(Swq5L3astRhkpiG59znGaHG3kdcqakmNeQ4lV8gqAA9q5bbmVpRbeie8wzqacqH5KqfFPbdY3gfkpiG59znGaHG3kdcqakWJgG8YBaPP1dLheW8(SgqGqWBLbbiaf4rdqAWG8TrHYdcyEFwdiqi4TYGaeGc8Obiz1zBQnkuEqaZ7ZAabcbVvgeGa08AsnRrESlekBliccecERmiabO6TTbHYT9cbgKdcbbcbVvgeGau72Rh1WckH5CHaYa)6yxiiqi4TYGaeGAdlXrLczkvwnP7ecuhqGqWBLbbiafgwmHStfFOSzZfiqi4TYGaeGo46nVe21ybquItOnm8bbcbVvgeGa0T5Xw(OC)2WcjDymnRbsdEKvNTP974gWSpTThDASd6OvJkbQ12JYAKli6uf4aIQtGz(f6abVvgeGau72Wq7nOSvJkRMmOCJVaWSpTThPS6SxqnRrwJCbrshGFc)wRIhiHRHMs42Je(cIaeETuycGeE1iCHQ6SxqnRHWThj8PucFbrac3Ak(eUgMqcxZds4zJW1qSlc3DT8aeEWsjCJW1phHGkHVGiaH7o1qcxOQo7fuZAi8AiCJWHH2dGaeoRkpq5EOKomMM1aPbpYQZ20(DCdy2N22Jon2bDuJCbrjBPvR5uf4aIQtGz(f6ON3b(aM9PT9iLvN9cQznYAKlikOtWSpTThPTAujqT2EuwJCbX(fk3b(aM9PT9iTvJkbQ12JYAKli2Fp7b4dcERmiabO2THH2BqzRgvwnzq5gFbDcM9PT9iTvJkbQ12JYAKlis6WyAwdKg8iRoBt73XnWXcGHLkHQPqshgtZAG0Ghz1zBA)oUzbrzQ4XPXoOd72Wq7nOSvJkRMmOCJpPdJPznqAWJS6SnTFh3CY)RxMh7cjDymnRbsdEKvNTP974MGsZAiDymnRbsdEKvNTP974MGU(A7nOs6G0b4NWV1WviBPiaHJGHFxeUMhKW1qKWnMwpHNqc3aZsVT9iL0HX0SgOdwTgfFya69KomMM1a73XnmZ7LgtZAK(eQon2bDKkEGYW8kug8z9P2fPdJPznW(DCZj)VEzESl0PS5yVAnkRo7fuZAOaL7H0HX0Sgy)oU5AzpqAJSAs724xAOtzZbRkpq5EOS6SxqnRH(4XYbcoHVdeinpOuljqIGJvLhOCpuwD2lOM1qF8y5ajDymnRb2VJBy1WWrFtrazZBhK0HX0Sgy)oUPvSfebK2TXpvuUr7q6WyAwdSFh3eS(S1voxYT3GkPdJPznW(DCZNbbEuMJegymK0HX0Sgy)oUrdr5A21AaKT6ziPdJPznW(DCJ769aGH5iFewJnmK0HX0Sgy)oU5xdkRMmOCJVtzZHAECuAlFeQ2R4tXX2EeqqlFeQ2R4tF8y5a7UT8E5JSq7VqPMheeiwvEGY9qz1zVGAwd9XJLdSBWSpTThPS6SxqnRr(vGKT0Q1eSxTgLvN9cQznuGY9acKMhuQLeirWXQYduUhkRo7fuZAOpESCGc2RwJYQZEb1Sgkq5EiDymnRb2VJByM3lnMM1i9juDASd6GvN9cQznYGqdIoLnhoRMhhL(RbLvtguUXNIJT9iGawvEGY9qz1zVGAwd9XJLdeComMM1q)1GYQjdk34tzguLAEqqGyv5bk3dLvN9cQzn0hnGUCrqNT8rOAVIp1yAcgcc0E1AuwD2lOM1qxbKomMM1a73XnT8r52Bq1PfeLUdtpkzguZ5YHWoTGOSAn5fdWHWoLnhoJqiomKEWt9DjRM0VyjGe4r7aPh7wUEqGqiehgsp4P(UKvt6xSeqc8ODG0to1lWUn(PI0T3Gk(YJbv8P4yBpc4IawO9xi0XXCLKfA)fcf05E1A0WsLq9rti0hnMkOtN3RwJgIMMZLCfqF0yQaN3RwJYQZEb1Sg6kqGZgtZAOT8XT590CKnFEfQGazmnRHg01xBVbvAoYMpVcvqGmMM1qHS6zHu0viBP5C5ciqQ9xOsdrZRH0aMcohc9DcmMM1qHS6zHu0viBP5C5Ilc605o3RwJgIMMZLCfqF0yQGo3RwJgwQeQpAcH(OXub7vRrz1zVGAwdfOCpcC2yAwdTLpUnVNMJS5ZRqfeiJPzn0GU(A7nOsZr285vO6IlKoa)e(TORpNlc31Mpcv7v8DIWDT5JeEVEdQqc3EKWxqeGWH5j9277IW1IWbwFoxeUqvD2lOM1qj8BnXbFZ77YjcxdXUiC7rcFbracxlc)ch8nfj8BvPeUO(OjeiH7oehcN9PcjC3P3t4tPe(gjC3gurac3gac3DQHeEVEdQ4t4UgguX3jcxdXUiCyyT8ae(gjCyWJgaHxlLW1IWpwoQLdHRHiH3R3Gk(eURHbv8j89Q1OKomMM1a73XnT8r52Bq1PfeLUdtpkzguZ5YHWoTGOSAn5fdWHWoLnhT8rOAVIp1yAcgkGfA)fc72HWcCUtWSpTThPT8r52BqvguLpNlqG2RwJ(RbLvtguUXNUcCrGZDA3g)ur62BqfF5XGk(uCSThbabAVAn62BqfF5XGk(0hpwoqWDhThUiW5onMM1qB5JBZ7PORq2sZ5sqNgtZAObD912BqLMJS5ZRqvWE1A0q00CUKRa6kaeiJPzn0w(428Ek6kKT0CUeSxTgnSujuF0ecfOCpGazmnRHg01xBVbvAoYMpVcvb7vRrdrtZ5sUcOaL7rWE1A0WsLq9rtiuGY94cPdJPznW(DCdZ8EPX0SgPpHQtJDqhFfidcni6u2CSxTg9xdkRMmOCJpDfiyVAnkRo7fuZAOaL7H0HX0Sgy)oUbm7tB7rNg7GoA5JYT3GQmOkFoxobM5xOd184O0FnOSAYGYn(uCSThbeWQYduUh6Vguwnzq5gF6Jhlhi4yv5bk3dTLpk3EdQ02Y7LpYcT)cLAEqboZQYduUhkRo7fuZAOpESCGDdM9PT9iLvN9cQznYVcKSLwTgiqT8rOAVIp1yAcg6IaNzv5bk3d9xdkRMmOCJp9XJLdeCAEqPwsGebbYyAwd9xdkRMmOCJpLfA)fc7(oxabIvLhOCpuwD2lOM1qF8y5abNX0SgAlFuU9guPTL3lFKfA)fk18G9ZQYduUhAlFuU9guPaR30SgWh724Nks3EdQ4lpguXNIJT9iGGoB5Jq1EfFQX0emuaRkpq5EOS6SxqnRH(4XYbconpOuljqIGaPMhhL2YhHQ9k(uCSThbe0YhHQ9k(uJPjyOGw(iuTxXN(4XYbcowvEGY9qB5JYT3GkTT8E5JSq7VqPMhSFwvEGY9qB5JYT3Gkfy9MM1a(y3g)ur62BqfF5XGk(uCSThbiDymnRb2VJBaZ(02E0PXoOJGWcN0vYGQ85C5eyMFHouZJJs)1GYQjdk34tXX2EeqaRkpq5EO)Aqz1KbLB8PpESCGGJvLhOCp0GWcN0vYM3oiK2wEV8rwO9xOuZdkGvLhOCpuwD2lOM1qF8y5a7gm7tB7rkRo7fuZAKFfizlTAnboZQYduUh6Vguwnzq5gF6Jhlhi408GsTKajccKX0Sg6Vguwnzq5gFkl0(le29DUaceRkpq5EOS6SxqnRH(4XYbcoJPzn0GWcN0vYM3oiK2wEV8rwO9xOuZdkGvLhOCpuwD2lOM1qF8y5abNMhuQLeirshgtZAG974gM59sJPznsFcvNg7GoGQna2di)snnRH0bPdJPznqQX0emuQMhhf6WNGLZLCxNTtzZHX0emuIdEse2TWc2RwJYQZEb1Sgkq5Ee4mRkpq5EOS6SxqnRH(4XYb2nRkpq5EO(eSCUK76SPaR30SgqGyv5bk3dLvN9cQzn0hnGUCH0HX0Sgi1yAcgkvZJJc73XnhuX6DkBo2RwJ(RbLvtguUXNUce4ClFeQ2R4tF8y5a7MvLhOCp0dQy9uG1BAwdiqD2YhHQ9k(uJPjyOlGaXQYduUh6Vguwnzq5gF6Jhlhy3AEqPwsGefymnRH(RbLvtguUXNYcT)cHGtyqGCMvLhOCp0dQy9uG1BAwd4yv5bk3dLvN9cQzn0hpwoqqGyv5bk3dLvN9cQzn0hnGUCrqNQ5XrP)Aqz1KbLB8P4yBpciWzwvEGY9qpOI1tbwVPznGRLpcv7v8PpESCGGa1PAECuAlFeQ2R4tXX2EeaeOoB5Jq1EfFQX0em0fshKoa)eUqvD2lOM1q4bHgej8GhdShHeUTtFQjcjC3Pgs4gHdGERlNiCnehc3BRHfIqcphTiCnejCHQ6SxqnRHWHi4TWHHKomMM1aPS6SxqnRrgeAq0HpVcvO8wEbCDWrDkBo2RwJYQZEb1Sgkq5EiDymnRbsz1zVGAwJmi0Gy)oUz7RcqwnPgIsCWtxKomMM1aPS6SxqnRrgeAqSFh3CWt9DjRM0VyjGe4r7ajDa(j8BrxFoxeUqvD2lOM14eH7AZhj8E9guHeU9iHVGiaHRfHFHd(MIe(TQucxuF0ecKWTbGWp5KN82iHRHiHBNAnkHxncxZds4WaCuchDfYwAoxeEPH4t4Wa07Huc31wpHdvBaShGWDT5Jor4U28rcVxVbviHBps4147IWxqeGWDhIdHFRqtZ5IWV1di8es4gttWqcVEc3DioeUr4IS6zHeoZGkHNqcphcp4RRhHqc3gac)wHMMZfHFRhq42aq43QsjCr9rtieU9iHpLs4gttWqkH7Ao1qcVxVbv8jCxddQ4t42aq4UwVDqc)wKXjc31Mps496nOcjCMneUbaKAwJ59Dr4BKWxqeGWDhMEKWVvLs4I6JMqiCBai8BfAAoxe(TEaHBps4tPeUX0emKWTbGWnc)wsxFT9guj8es45q4Ais4w(eUnaeU5HfH7om9iHZmOMZfHlYQNfs4iy4q4zJWVvOP5Cr436beEcjCZ)Ob0fHBmnbdPeEFHiH7nvXNWnVVCdjC1Dr43QsjCr9rtie(TKU(A7nOcjCTi8ns4mdQeEoeoCXyieM1q4wtXNW1qKWfz1ZcPe(T4aaPM1yEFxeU7udj8E9guXNWDnmOIpHBdaH7A92bj8BrgNiCxB(iH3R3GkKWHH1Ydq4tPe(gj8febi814riKW71BqfFc31WGk(eEcjCBxlLW1IWrxfKps41t4Ai(iHBps4N6rcxdTHWXPwxHeURnFKW71Bqfs4Ar4ORuCai8E9guXNWDnmOIpHRfHRHiHJdaHxncxOQo7fuZAOKomMM1aPS6SxqnRrgeAqSFh30YhLBVbvNwqu6om9OKzqnNlhc70cIYQ1Kxmahc7u2CWcT)cHD7qybo7SX0SgAlFuU9guPSq7VqOS9gtZAmF)oVxTgLvN9cQzn0hpwoqH69Q1OBVbv8LhdQ4tbwVPznUClLvLhOCp0w(OC7nOsbwVPznc1oVxTgLvN9cQzn0hpwoqxUL68E1A0T3Gk(YJbv8PaR30SgH67O9Wfx62XDGa1PDB8tfPBVbv8LhdQ4tXX2EeaeOovZJJsBE7GYAO4yBpcac0E1AuwD2lOM1qF8y5abNJ9Q1OBVbv8LhdQ4tbwVPznGaTxTgD7nOIV8yqfF6Jhlhi4UJ2dqGqWBLbbianSRa81WhnaP7pHQ73cGcyv5bk3dnSRa81WhnaP7pHQ73cGsH(U7ewO0t6Jhlhi46Hlc2RwJYQZEb1Sg6kqGZDAmnRHcz1ZcPORq2sZ5sqNgtZAObD912BqLMJS5ZRqvWE1A0q00CUKRa6kaeiJPznuiREwifDfYwAoxc2RwJgwQeQpAcHcuUhboVxTgnennNl5kGcuUhqGSBJFQiD7nOIV8yqfFko22JaUacKDB8tfPBVbv8LhdQ4tXX2EeqGAECuAZBhuwdfhB7rabgtZAObD912BqLMJS5ZRqvWE1A0q00CUKRakq5EeSxTgnSujuF0ecfOCpUq6WyAwdKYQZEb1SgzqObX(DCZVguwnzq5gFNYMJ9Q1OS6SxqnRHcuUhshGFc31CQHeEVEdQ4t4UgguX3jc3iCxB(iH3R3GkHddRLhGW3iHVGiaH7om9iHZmOMZfHFl2AqcVAe(TKYn(ushgtZAGuwD2lOM1idcni2VJBA5JYT3GQtlikDhMEuYmOMZLdHDkBoSBJFQiD7nOIV8yqfFko22JacuZJJsBE7GYAO4yBpciyVAn62BqfF5XGk(uGY9iWz184O0FnOSAYGYn(uCSThbeymnRH(RbLvtguUXNIUczlnNlbgtZAO)Aqz1KbLB8PORq2sr5Jhlhi4UJ66bbYzwvEGY9qz1zVGAwd9rdOlqG2RwJYQZEb1Sg6kWfbDQMhhL(RbLvtguUXNIJT9iGGonMM1qd66RT3GknhzZNxHQGonMM1qB5JBZ7P5iB(8kuDH0HX0SgiLvN9cQznYGqdI974gM59sJPznsFcvNg7GomMMGHs184OqshgtZAGuwD2lOM1idcni2VJBy1zVGAwJtlikRwtEXaCiStlikDhMEuYmOMZLdHDkBoC2zJPzn0dQy90CKnFEfQcmMM1qpOI1tZr285vOkF8y5abNJ7O9WfqG6unpok9GkwpfhB7raxe48E1A0FnOSAYGYn(0vaiqDQMhhL(RbLvtguUXNIJT9iGlKomMM1aPS6SxqnRrgeAqSFh3euAwdPdJPznqkRo7fuZAKbHge73XnBFvaY267I0HX0SgiLvN9cQznYGqdI974Mn(q8fsoxKomMM1aPS6SxqnRrgeAqSFh30Yh3(QaiDymnRbsz1zVGAwJmi0Gy)oUXggc138sM59KomMM1aPS6SxqnRrgeAqSFh3WmVxAmnRr6tO60yh0H(5ieuHKomMM1aPS6SxqnRrgeAqSFh3082bH6NcbDkBoC2z184O0M3oOmWuwifhB7rabgttWqjo4jry390fqGmMMGHsCWtIWUD9UiyVAnAyPsO(Oje6Jgtf0PDB8tfPBVbv8LhdQ4tXX2EeG0HX0SgiLvN9cQznYGqdI974MGU(A7nO6u2CSxTgnORVyEdEOpAmvWE1AuwD2lOM1qF8y5a7MzqvQ5bjDymnRbsz1zVGAwJmi0Gy)oUjORV2EdQoLnh7vRrdlvc1hnHqF0ykPdJPznqkRo7fuZAKbHge73XnT8r52Bq1PfeLvRjVyaoe2PfeLUdtpkzguZ5YHWoLnhieIddPh8uFxYQj9lwcibE0oq6XULRxGZSq7VqOS9gtZAmF3ctfAqG2RwJU9guXxEmOIp9XJLdeC3r7biq7vRrz1zVGAwd9XJLdeC7vRr3EdQ4lpguXNcSEtZAabQt724Nks3EdQ4lpguXNIJT9iGlcC259Q1OS6SxqnRHUce48E1A0q00CUKRa6Jgtf0PX0SgAqxFT9guP5iB(8kuf0PX0SgkKvplKIUczlnNlxabYzJPznuiREwifDfYwkkF8y5afSxTgnennNl5kGcuUhb7vRrdlvc1hnHqbk3JGonMM1qd66RT3GknhzZNxHQlU4cPdJPznqkRo7fuZAKbHge73XnT8r52Bq1PfeLvRjVyaoe2PfeLUdtpkzguZ5YHWoLnhDIqiomKEWt9DjRM0VyjGe4r7aPh7wUEbo3PDB8tfPBVbv8LhdQ4tXX2EeaeOovZJJsBE7GYAO4yBpc4IaNDEVAnkRo7fuZAORaboVxTgnennNl5kG(OXubDAmnRHg01xBVbvAoYMpVcvbDAmnRHcz1ZcPORq2sZ5YfqGC2yAwdfYQNfsrxHSLIYhpwoqb7vRrdrtZ5sUcOaL7rWE1A0WsLq9rtiuGY9iOtJPzn0GU(A7nOsZr285vO6IlUq6WyAwdKYQZEb1SgzqObX(DCtqxFT9guDkBocEem5fdGkmfYQNfkyVAnAiAAoxYvaDfq6WyAwdKYQZEb1SgzqObX(DCtqyHt6kzZBhes6WyAwdKYQZEb1SgzqObX(DCdKvpl0PS5yVAnkRo7fuZAOpESCGDZmOk18Gc2RwJYQZEb1Sg6kaeO9Q1OS6SxqnRHcuUhshgtZAGuwD2lOM1idcni2VJB8jy5Cj31z7u2CSxTgLvN9cQzn0hpwoqWDXaOhZvcmMMGHsCWtIWUfM0HX0SgiLvN9cQznYGqdI974gG3UQbk3pAAOtzZXE1AuwD2lOM1qF8y5ab3fdGEmxjyVAnkRo7fuZAORashgtZAGuwD2lOM1idcni2VJBGS6zHoLnhQ9xOsdrZRH0aMcohc9DcuZJJsHO95Cj1AXcP4yBpcq6G0HX0Sginv8aLS6SxqnRXXcIYuXJtJDqh51KAwJ8yxiu2wqK0HX0Sginv8aLS6SxqnRPFh3SGOmv840yh0ryxb4RHpAas3Fcv3VfaDkBo2RwJYQZEb1Sg6kqGX0SgAlFuU9guPSq7VqOJ7eymnRH2YhLBVbv6JSq7VqPMhS7lga9yUI0HX0Sginv8aLS6SxqnRPFh3SGOmv840cIYQ1Kxmahc70yh0HD71JAybLWCUqazGFDSl0PS5yVAnkRo7fuZAORaqGmMM1qpOI1tZr285vOkWyAwd9GkwpnhzZNxHQ8XJLdeCoUJ2dshgtZAG0uXduYQZEb1SM(DCZcIYuXJtlikRwtEXaCiStyRHmvo2bDC5nG006HYTbCHoLnh7vRrz1zVGAwdDfacKX0Sg6bvSEAoYMpVcvbgtZAOhuX6P5iB(8kuLpESCGGZXD0Eq6WyAwdKMkEGswD2lOM10VJBwquMkECAbrz1AYlgGdHDcBnKPYXoOJlVbKMwpuEqaZ7ZACkBo2RwJYQZEb1Sg6kaeiJPzn0dQy90CKnFEfQcmMM1qpOI1tZr285vOkF8y5abNJ7O9G0HX0Sginv8aLS6SxqnRPFh3SGOmv840cIYQ1Kxmahc70yh0X28ylFuUFByHoLnh7vRrz1zVGAwdDfacKX0Sg6bvSEAoYMpVcvbgtZAOhuX6P5iB(8kuLpESCGGZXD0Eq6WyAwdKMkEGswD2lOM10VJBwquMkECAbrz1AYlgGdHDASd6agwmHStfFOSzZLtzZXE1AuwD2lOM1qxbGazmnRHEqfRNMJS5ZRqvGX0Sg6bvSEAoYMpVcv5Jhlhi4CChThKomMM1aPPIhOKvN9cQzn974MfeLPIhNwquwTM8Ib4qyNg7Go0BBdcLB7fcmihe6u2CSxTgLvN9cQzn0vaiqgtZAOhuX6P5iB(8kufymnRHEqfRNMJS5ZRqv(4XYbcoh3r7bPdJPznqAQ4bkz1zVGAwt)oUzbrzQ4XPfeLvRjVyaoe2PXoOdByjoQuitPYQjDNqG64u2CSxTgLvN9cQzn0vaiqgtZAOhuX6P5iB(8kufymnRHEqfRNMJS5ZRqv(4XYbcoh3r7bPdJPznqAQ4bkz1zVGAwt)oUzbrzQ4XPfeLvRjVyaoe2PXoOJbxV5LWUglaIsCcTHHVtzZXE1AuwD2lOM1qxbGazmnRHEqfRNMJS5ZRqvGX0Sg6bvSEAoYMpVcv5Jhlhi4CChThKomMM1aPPIhOKvN9cQzn974MfeLPIhNwquwTM8Ib4qyNg7GooMVv)bbKH4BEaO0JxUFla6u2CSxTgLvN9cQzn0vaiqgtZAOhuX6P5iB(8kufymnRHEqfRNMJS5ZRqv(4XYbcoh3r7bPdshgtZAG0uXdugMxHYGpRp1UCWmVxAmnRr6tO60yh0rQ4bkz1zVGAwJtzZHZQ5XrP)Aqz1KbLB8P4yBpciGvLhOCpuwD2lOM1qF8y5abNdJPzn0FnOSAYGYn(uMbvPMheeiwvEGY9qz1zVGAwd9rdOlxe0zlFeQ2R4tnMMGHGaTxTgLvN9cQzn0vaPdJPznqAQ4bkdZRqzWN1NAx974MfeLPIhiPdJPznqAQ4bkdZRqzWN1NAx974MfeLPIhNg7GoSBddT3GYwnQSAYGYn(oLnhSQ8aL7HYQZEb1Sg6Jhlhi4C0J(fUhGpGzFABpsB1OsGAT9OSg5cIKomMM1aPPIhOmmVcLbFwFQD1VJBwquMkECASd64lL9lOIasWQcOkjq59oLnhSQ8aL7HYQZEb1Sg6Jhlhy3GzFABpsRrUGOKT0Q1iDymnRbstfpqzyEfkd(S(u7QFh3SGOmv840yh0HbERmOuCu5yln9lOtzZbRkpq5EOS6SxqnRH(4XYb2ny2N22J0AKlikzlTAnshgtZAG0uXdugMxHYGpRp1U63Xnliktfpon2bDadtWWxcgo1r(OpzoLnhSQ8aL7HYQZEb1Sg6Jhlhy3GzFABpsRrUGOKT0Q1iDymnRbstfpqzyEfkd(S(u7QFh3SGOmv84e2AitLJDqhH2FQjzsa8yk(P5ZBJpPdJPznqAQ4bkdZRqzWN1NAx974MfeLPIhNg7GooMVv)bbKH4BEaO0JxUFla6u2CWQYduUhkRo7fuZAOpESCGD7Oh9qWE1AuwD2lOM1qbk3JawvEGY9qz1zVGAwd9XJLdSBWSpTThP1ixquYwA1AKomMM1aPPIhOmmVcLbFwFQD1VJBwquMkECASd6WgwIJkfYuQSAs3jeOooLnhSQ8aL7HYQZEb1Sg6Jhlhy3o6rpeSxTgLvN9cQznuGY9iGvLhOCpuwD2lOM1qF8y5a7gm7tB7rAnYfeLSLwTgPdJPznqAQ4bkdZRqzWN1NAx974MfeLPIhNg7GogC9Mxc7ASaikXj0gg(oLnhSQ8aL7HYQZEb1Sg6Jhlhy3oek9qWE1AuwD2lOM1qbk3JawvEGY9qz1zVGAwd9XJLdSBWSpTThP1ixquYwA1AKoiDymnRbstfpqPVCld(S(u7YXcIYuXJtJDqhAcGqT(JKvaORCkBoyv5bk3dLvN9cQzn0hpwoWUbZ(02EKwJCbrjBPvRbcKAECuAlFeQ2R4tXX2EeqqlFeQ2R4tF8y5a7gm7tB7rAnYfeLSLwTgPdJPznqAQ4bk9LBzWN1NAx974MfeLPIhNWwdzQCSd6G1fZx6xtYKBVbvNYMdwvEGY9qz1zVGAwd9XJLdSBWSpTThP1ixquYwA1AGaPMhhL2YhHQ9k(uCSThbe0YhHQ9k(0hpwoWUbZ(02EKwJCbrjBPvRr6G0HX0Sgi9RazqObrh)Aqz1KbLB8jDymnRbs)kqgeAqSFh3082bH6NcbDkBoCwnpokT5TdkdmLfsXX2EeqGX0emuIdEse2TWGazmnbdL4GNeHDluCrWE1A0WsLq9rti0hnMs6WyAwdK(vGmi0Gy)oUjORV2EdQoLnh7vRrdlvc1hnHqF0ykPdJPznq6xbYGqdI974Mw(OC7nO60cIYQ1Kxmahc70cIs3HPhLmdQ5C5qyNYMJoDwnpokT5TdkdmLfsXX2EeqGX0emuIdEse2DpbbYyAcgkXbpjc7UhUiW5oB5Jq1EfFQX0emuaRkpq5EOS6SxqnRH(4XYb29DUiW5o3RwJgIMMZLCfqF0yQGo3RwJgwQeQpAcH(OXubDg8iyYQ1KxmaAlFuU9guf4SX0SgAlFuU9guPSq7Vqy3o6jiqoBmnRHgew4KUs282bHuwO9xiSBhclqnpokniSWjDLS5TdcP4yBpc4ciqoRMhhLAE0vq9n4TnOST(UO4yBpciGvLhOCpuG3UQbk3pAAi9rdOlxabYz184OuiAFoxsTwSqko22Jacu7VqLgIMxdPbmfCoe67CXfxiDymnRbs)kqgeAqSFh3WmVxAmnRr6tO60yh0HX0emuQMhhfs6WyAwdK(vGmi0Gy)oUjORV2EdQoLnh7vRrd66lM3Gh6JgtfWmOk18GGBVAnAqxFX8g8qF8y5afSxTg9xdkRMmOCJp9XJLdSBMbvPMhK0HX0Sgi9RazqObX(DCtlFuU9guDAbrz1AYlgGdHDAbrP7W0JsMb1CUCiStzZrNoRMhhL282bLbMYcP4yBpciWyAcgkXbpjc7UNGazmnbdL4GNeHD3dxe4CNT8rOAVIp1yAcgkGvLhOCpuwD2lOM1qF8y5a7(oxe48E1A0q00CUKRa6Jgtf4SA)fQ0q08AinGPD7qOVdeOovZJJsHO95Cj1AXcP4yBpc4IlKomMM1aPFfidcni2VJBA5JYT3GQtlikRwtEXaCiStlikDhMEuYmOMZLdHDkBo60z184O0M3oOmWuwifhB7rabgttWqjo4jry39eeiJPjyOeh8KiS7E4IaN7SLpcv7v8PgttWqbSQ8aL7HYQZEb1Sg6Jhlhy335Ia184OuiAFoxsTwSqko22Jacu7VqLgIMxdPbmfCoe67e48E1A0q00CUKRa6Jgtf0PX0SgkKvplKIUczlnNlqG6CVAnAiAAoxYva9rJPc6CVAnAyPsO(Oje6JgtDH0HX0Sgi9RazqObX(DCtqxFT9guDkBocEem5fdGkmfYQNfkyVAnAiAAoxYvaDfiqnpokfI2NZLuRflKIJT9iGa1(luPHO51qAatbNdH(obo3PAECuAZBhugyklKIJT9iaiqgttWqjo4jrOdHDH0HX0Sgi9RazqObX(DCtqyHt6kzZBhe6u2C0zWJGjVyauHPbHfoPRKnVDqOG9Q1OHOP5Cjxb0hnMs6WyAwdK(vGmi0Gy)oUbYQNf6u2CO2FHknenVgsdyk4Ci03jqnpokfI2NZLuRflKIJT9iaPdJPznq6xbYGqdI974gG3UQbk3pAAOtzZHX0emuIdEse2DpjDa(jCxZH4q43k7byguZ5IWDTE7GeUO(PqqNiCxB(iH3R3GkKWHH1Ydq4BKWxqeGW1IWVWbFtrc)wvkHlQpAcbs42aq4Ar4ORuCai8E9guXNWDnmOIpL0HX0Sgi9RazqObX(DCtlFuU9guDAbrz1AYlgGdHDAbrP7W0JsMb1CUCiStzZHZQ5XrPnVDqzGPSqko22JacmMMGHsCWtIWU7jiqgttWqjo4jry39WfboZQYduUhkRo7fuZAOpESCGDFNGoB5Jq1EfFQX0em0fb7vRrdlvc1hnHqbk3JaN70Un(PI0T3Gk(YJbv8P4yBpcac0E1A0T3Gk(YJbv8PpESCGG7oApCH0HX0Sgi9RazqObX(DCtZBheQFke0PS5qnpokT5TdkdmLfsXX2EeqGX0emuIdEse2DpbbYyAcgkXbpjc7UhKomMM1aPFfidcni2VJBA5JBZ7jDq6WyAwdKcvBaShq(LAAwJJM3oiu)uiOtzZHZoRMhhL282bLbMYcP4yBpciWyAcgkXbpjc7wybD2YhHQ9k(uJPjyOlGazmnbdL4GNeHDluCrWE1A0WsLq9rti0hnMs6WyAwdKcvBaShq(LAAwt)oUjORV2EdQoLnh7vRrdlvc1hnHqF0yQG9Q1OHLkH6JMqOpESCGGZyAwdTLpUnVNIUczlfLAEqshgtZAGuOAdG9aYVutZA63XnbD912Bq1PS5yVAnAyPsO(Oje6Jgtf4CWJGjVyauHPT8XT59Ga1YhHQ9k(uJPjyiiqgtZAObD912BqLMJS5ZRq1fshgtZAGuOAdG9aYVutZA63XnbHfoPRKnVDqOtzZbl0(le2TdHwGX0emuIdEse2Dpf0jy2N22J0GWcN0vYGQ85Cr6WyAwdKcvBaShq(LAAwt)oUjORV2EdQoLnh7vRrdlvc1hnHqF0yQa1(luPHO51qAatbNdH(obQ5XrPq0(CUKATyHuCSThbiDymnRbsHQna2di)snnRPFh3e01xBVbvNYMJ9Q1ObD9fZBWd9rJPcyguLAEqWTxTgnORVyEdEOpESCGKomMM1aPq1ga7bKFPMM10VJBA5JYT3GQtlikRwtEXaCiStlikDhMEuYmOMZLdHDkBoCMvLhOCpuwD2lOM1qF8y5a7(ob7vRr)1GYQjdk34tbk3JGoB5Jq1EfFQX0em0fbDQMhhLkKCa85CrXX2EeqqNGzFABpsB5JYT3GQmOkFoxcC2zNnMM1qB5JBZ7PORq2sZ5ceiJPzn0GU(A7nOsrxHSLMZLlcCEVAnAiAAoxYva9rJPU4ciqoRMhhLcr7Z5sQ1IfsXX2EeqGA)fQ0q08AinGPGZHqFNaN3RwJgIMMZLCfqF0yQGonMM1qHS6zHu0viBP5CbcuN7vRrdlvc1hnHqF0yQGo3RwJgIMMZLCfqF0yQaJPznuiREwifDfYwAoxc60yAwdnORV2EdQ0CKnFEfQc60yAwdTLpUnVNMJS5ZRq1fxCH0HX0SgifQ2aypG8l10SM(DCtlFuU9guDkBouZJJsfsoa(CUO4yBpciyVAnAiAAoxYva9rJPc6SLpcv7v8PgttWqboZQYduUhkRo7fuZAOpESCGD3wEV8rwO9xOuZd2Fp7xnpokvi5a4Z5IIJT9iaiqo3PAECu6Vguwnzq5gFko22JaGaXQYduUh6Vguwnzq5gF6Jhlhy3AEqPwsGefymnRH(RbLvtguUXNYcT)cHGtyxeWQYduUhkRo7fuZAOpESCGDR5bLAjbs0fshgtZAGuOAdG9aYVutZA63XnbD912Bq1PS5i4rWKxmaQWuiREwOG9Q1OHOP5Cjxb0vGa184OuiAFoxsTwSqko22Jacu7VqLgIMxdPbmfCoe67e4SZQ5XrPnVDqzGPSqko22JacmMMGHsCWtIqhclOZw(iuTxXNAmnbdDbeiNnMMGHsCWtIqWjue0PAECuAZBhugyklKIJT9iGlUq6WyAwdKcvBaShq(LAAwt)oUjiSWjDLS5TdcDkBoCEVAnAiAAoxYva9rJPGa5CN7vRrdlvc1hnHqF0yQaNnMM1qB5JYT3GkLfA)fc7(oqGuZJJsHO95Cj1AXcP4yBpciqT)cvAiAEnKgWuW5qOVZfxCrqNGzFABpsdclCsxjdQYNZfPdJPznqkuTbWEa5xQPzn974gM59sJPznsFcvNg7GomMMGHs184OqshgtZAGuOAdG9aYVutZA63XnaVDvduUF00qNYMdJPjyOeh8KiSBHjDymnRbsHQna2di)snnRPFh3WmVxAmnRr6tO60yh0rQ4bk9LBzWN1NAxKomMM1aPq1ga7bKFPMM10VJBGS6zHoLnhQ9xOsdrZRH0aMcohc9DcuZJJsHO95Cj1AXcP4yBpcq6a8t4UMdXHWVv2dWmOMZfH7A92bjCr9tHGor4U28rcVxVbviHddRLhGW3iHVGiaHRfHFHd(MIe(TQucxuF0ecKWTbGW1IWrxP4aq496nOIpH7AyqfFkPdJPznqkuTbWEa5xQPzn974Mw(OC7nO60cIYQ1Kxmahc70cIs3HPhLmdQ5C5qyNYMdNvZJJsBE7GYatzHuCSThbeymnbdL4GNeHD3tqGmMMGHsCWtIWUDDUiWzwvEGY9qz1zVGAwd9XJLdS77e0zlFeQ2R4tnMMGHUiyVAnAyPsO(Ojekq5Ee4CN2TXpvKU9guXxEmOIpfhB7raqG2RwJU9guXxEmOIp9XJLdeC3r7HlKoa)eUR5udjCCQ1viHR2FHk0jcpvcpHeUr4xwoeUweoZGkH7A92bH6NcbjCds4T07XNWZbQObq4vJWDT5JBZ7PKomMM1aPq1ga7bKFPMM10VJBAE7Gq9tHGoLnhQ5XrPnVDqzGPSqko22JacmMMGHsCWtIWU7jiqgttWqjo4jry3UoshgtZAGuOAdG9aYVutZA63XnT8XT59KomMM1aPq1ga7bKFPMM10VJBGS6zHKoiDymnRbs1phHGk0XcIYuXdK0HX0Sgiv)CecQW(DCZcIYuXJtJDqhH2FQjzsa8yk(P5ZBJFuegGS49UEHoQrngb]] )


end
