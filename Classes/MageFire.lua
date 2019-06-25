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


    -- f681cdeb24ca362198d9d31e1636583e97c07727
    spec:RegisterPack( "Fire", 20190625.0940, [[du0VQbqirIhrkLAtq0OGKofPWQiLIQxjuzwIKULQKs7c0ViLmmvjoMQOLjsXZuLKPjsjxJuQSnsPW3ePunosPQohPuY6iLQyEQcDpsL9Pk4GQskIfku1djLQ0fvLuuBuvsHtskfHvsk6MKsrANKQAOIukwQiLspfftLuLRskfr7LK)sLbl4WuwSOEmWKrPlJSzL8zimArCAPwnPuuEnKWSPQBRQ2TIFlz4c54QskslxLNd10jUUsTDvP(Uqz8qIoVivRxvs18Hu7hvREQ0tXWAcP0pnV8uB9I2inAh8fTvA9QNVsXiPhrkMidGcdbPyg7tkMxJ(iftKLUVmwLEkgCTpaPysejcR9OLwiAjzNHG6RfU)BVjDnGZwIw4(d0sXK3Tx0MyuzfdRjKs)08YtT1lAJ0ODWx0wP1REjTRySTKuNIHP)BVjDnAVNTeftsZYsJkRyyjmqXOT5HxJ(iEqBQHG4AQT5HerIWApAPfIws2ziO(AH7)2Bsxd4SLOfU)aTY(kRvEzVww6TwrxTApH1kT5O0wRzXAL2K260MAii3RrFee3FaxtTnpO5EiEinAxQ8qAE5P2IhET8WlAlTN06fUMCn128G2BIniiS2dxtTnp8A5bTjXepi9NCs5yBIhotsOJhKeB4bXoeKaL(toPCSnXdR64bVHLxlMa1WYdwU9TKopSXgccdvm(glyLEkgdi9BYjMNgbR0tP)tLEkgASSNyvXRyaxl01MIXas)MC0q)MW8Wd8WtEajpK3Rfeu)8glDnq2k2Wdi5bu5bqvE2k2ab1pVXsxd8OV1dMhEGhav5zRyd03V7bHlx)mKDFM01WdOrZdGQ8SvSbcQFEJLUg4rgB68GgkgdiDnkgF)UheUC9ZkrPFAu6PyOXYEIvfVIbCTqxBkM8ETG3EixTCrvm6G7iEajpGkpS6JWIDcDWJ(wpyE4bEauLNTInWpjuDq29zsxdpGgnpKcpS6JWIDcDqdi9BIh0GhqJMhav5zRyd82d5QLlQIrh8OV1dMhEGhK(toPCSnXdi5bdiDnWBpKRwUOkgDqqIDiimp8ip8KhqJMhqLhav5zRyd8tcvhKDFM01WdpYdGQ8SvSbcQFEJLUg4rFRhmpGgnpaQYZwXgiO(5nw6AGhzSPZdAWdi5Hu4bX80iWBpKRwUOkgDqASSNy5bK8aQ8aOkpBfBGFsO6GS7ZKUgE4rEy1hHf7e6Gh9TEW8aA08qk8GyEAe4Qpcl2j0bPXYEILhqJMhsHhw9ryXoHoObK(nXdAOymG01Oy(Kq1PeLOyKRhuqcwPNs)Nk9umgq6AumBm5AH(yfdnw2tSQ4vIsumS0Y2ErPNs)Nk9umgq6AumGApcD4iY7vm0yzpXQIxjk9tJspfdnw2tSQ4vmGRf6AtXK3Rfeu)8glDnq2k2OymG01Oy(9D156VHGuIs)xP0tXyaPRrXaQbqJCMqSUL3(KIHgl7jwv8krPFAP0tXyaPRrXSkWgtSo71PRfYLj7RyOXYEIvfVsu6RDk9umgq6Aumr7RxP3dcx2ByrXqJL9eRkELO0xBO0tXyaPRrXCDuKNC94WrgGum0yzpXQIxjk9t7k9umgq6Aumsc52tU2dRBvhGum0yzpXQIxjk91(k9umgq6AumXQZZ(M6XDeUgBaKIHgl7jwv8krPV2sPNIHgl7jwv8kgW1cDTPyeZtJax9ryXoHoinw2tS8asEy1hHf7e6Gh9TEW8Wd8WA79UJaj2HGCs)jEanAEauLNTInqq9ZBS01ap6B9G5Hh4H321w2tqq9ZBS014UkYb2sTw8asEiVxliO(5nw6AGSvSHhqJMhK(toPCSnXdpYdGQ8SvSbcQFEJLUg4rFRhmpGKhY71ccQFEJLUgiBfBumgq6Aum3EixTCrvm6uIs)NVO0tXqJL9eRkEfd4AHU2umOYdI5PrG3EixTCrvm6G0yzpXYdi5bqvE2k2ab1pVXsxd8OV1dMhEuhpyaPRbE7HC1YfvXOdcmS4K(t8aA08aOkpBfBGG6N3yPRbEKXMopObpGKhsHhw9ryXoHoObK(nXdOrZd59Abb1pVXsxdChPymG01OyaM37mG0148nwum(glUX(KIbu)8glDnUOedtkrP)ZNk9um0yzpXQIxXaUwORnftEVwWBpKRwUOkgDWDepGKhY71ccQFEJLUgiBfBumgq6AumaZ7Dgq6AC(glkgFJf3yFsXCvKlkXWKsu6)mnk9um0yzpXQIxXurkgmjkgdiDnkM321w2tkM3MFtkgX80iWBpKRwUOkgDqASSNy5bK8aOkpBfBG3EixTCrvm6Gh9TEW8WJ8aOkpBfBGR(ix2BybU2EV7iqIDiiN0FIhqYdOYdGQ8SvSbcQFEJLUg4rFRhmp8ap82U2YEccQFEJLUg3vroWwQ1IhqJMhw9ryXoHoObK(nXdAWdi5bu5bqvE2k2aV9qUA5IQy0bp6B9G5Hh5bP)KtkhBt8aA08GbKUg4ThYvlxufJoiiXoeeMhEGhEHh0GhqJMhav5zRydeu)8glDnWJ(wpyE4rEWasxdC1h5YEdlW127DhbsSdb5K(t8qC8aOkpBfBGR(ix2BybYUpt6A4bT58G9601cbZEdl05(gwOdsJL9elpGKhsHhw9ryXoHoObK(nXdi5bqvE2k2ab1pVXsxd8OV1dMhEKhK(toPCSnXdOrZdI5PrGR(iSyNqhKgl7jwEajpS6JWIDcDqdi9BIhqYdR(iSyNqh8OV1dMhEKhav5zRydC1h5YEdlW127DhbsSdb5K(t8qC8aOkpBfBGR(ix2BybYUpt6A4bT58G9601cbZEdl05(gwOdsJL9eRI5TDUX(KIz1h5YEdlUOQ89Gqjk9F(kLEkgASSNyvXRyQifdMefJbKUgfZB7Al7jfZBZVjfJyEAe4ThYvlxufJoinw2tS8asEauLNTInWBpKRwUOkgDWJ(wpyE4rEauLNTInWOKIMgLUL3(egU2EV7iqIDiiN0FIhqYdGQ8SvSbcQFEJLUg4rFRhmp8ap82U2YEccQFEJLUg3vroWwQ1IhqYdOYdGQ8SvSbE7HC1YfvXOdE036bZdpYds)jNuo2M4b0O5bdiDnWBpKRwUOkgDqqIDiimp8ap8cpObpGgnpaQYZwXgiO(5nw6AGh9TEW8WJ8GbKUgyusrtJs3YBFcdxBV3DeiXoeKt6pXdi5bqvE2k2ab1pVXsxd8OV1dMhEKhK(toPCSnPyEBNBSpPyIskAAu6IQY3dcLO0)zAP0tXqJL9eRkEfJbKUgfdW8ENbKUgNVXIIX3yXn2NumyXgw7yDxjM01OeLOyUkYfLyysPNs)Nk9umgq6Aum3EixTCrvm6um0yzpXQIxjk9tJspfdnw2tSQ4vmGRf6AtXGkpGkpiMNgbU82NCrMasG0yzpXYdi5bdi9BYrd9BcZdpWdp5bn4b0O5bdi9BYrd9BcZdpWdPfpObpGKhY71cMuIdlhzOaEKbefJbKUgfZYBFclxJcsjk9FLspfdnw2tSQ4vmGRf6AtXK3RfmPehwoYqb8idikgdiDnkMO0Vk7nSOeL(PLspfdnw2tSQ4vmBm5IL0EYbmS0dcfZtfd4AHU2umOYdGQ8SvSbcQFEJLUg4rFRhmp8ap8cpGgnpS6JWIDcDqdi9BIhqYd59AbV9qUA5IQy0b3r8Gg8asEavEifEiVxlyczspiC7i4rgq4bK8qk8qEVwWKsCy5idfWJmGWdi5Hu4HOJE7Q1YHaWcx9rUS3WcpGKhqLhmG01ax9rUS3WceKyhccZdpOJhsdpGgnpGkpyaPRbgLu00O0T82NWqqIDiimp8GoE4jpGKheZtJaJskAAu6wE7tyinw2tS8Gg8aA08aQ8GyEAeO5juILZWVUHDR9LoKgl7jwEajpaQYZwXgi7ziQb7Yhzsc8iJnDEqdEanAEavEqmpncet21dcNuBqcKgl7jwEajpi2HGeyczEjbgbeE4rD8WREHh0GhqJMhqLheZtJax9ryXoHoinw2tS8asEy1hHf7e6Ggq63epObpObpOHIzJjxTwoeawfZtfJbKUgfZQpYL9gwuIsFTtPNIHgl7jwv8kgdiDnkgG59odiDnoFJffJVXIBSpPymG0VjNyEAeSsu6Rnu6PyOXYEIvfVIbCTqxBkM8ETGrPFfWB4p8idi8asEayyXj9N4Hh5H8ETGrPFfWB4p8OV1dMhqYd59AbV9qUA5IQy0bp6B9G5Hh4bGHfN0FsXyaPRrXeL(vzVHfLO0pTR0tXqJL9eRkEfZgtUyjTNCadl9GqX8uXaUwORnfdQ8aOkpBfBGG6N3yPRbE036bZdpWdVWdOrZdR(iSyNqh0as)M4bK8qEVwWBpKRwUOkgDWDepObpGKhqLhY71cMqM0dc3ocEKbeEajpGkpi2HGeyczEjbgbeE4bD8WREHhqJMhsHheZtJaXKD9GWj1gKaPXYEILh0Gh0qXSXKRwlhcaRI5PIXasxJIz1h5YEdlkrPV2xPNIHgl7jwv8kMnMCXsAp5agw6bHI5PIbCTqxBkgu5bqvE2k2ab1pVXsxd8OV1dMhEGhEHhqJMhw9ryXoHoObK(nXdi5H8ETG3EixTCrvm6G7iEqdEajpiMNgbIj76bHtQnibsJL9elpGKhe7qqcmHmVKaJacp8OoE4vVWdi5bu5H8ETGjKj9GWTJGhzaHhqYdPWdgq6AGyqDGeiHscSLEqWdOrZdPWd59Abtit6bHBhbpYacpGKhsHhY71cMuIdlhzOaEKbeEqdfZgtUATCiaSkMNkgdiDnkMvFKl7nSOeL(AlLEkgASSNyvXRyaxl01MIj6O3oeaw4tiguhiHhqYd59Abtit6bHBhb3r8asEqmpncet21dcNuBqcKgl7jwEajpi2HGeyczEjbgbeE4rD8WREHhqYdOYdPWdI5PrGlV9jxKjGeinw2tS8aA08GbK(n5OH(nH5bD8WtEqdfJbKUgftu6xL9gwuIs)NVO0tXqJL9eRkEfd4AHU2umPWdrh92HaWcFcJskAAu6wE7tyEajpK3RfmHmPheUDe8idikgdiDnkMOKIMgLUL3(ewjk9F(uPNIHgl7jwv8kgW1cDTPye7qqcmHmVKaJacp8OoE4vVWdi5bX80iqmzxpiCsTbjqASSNyvmgq6AumyqDGeLO0)zAu6PyOXYEIvfVIbCTqxBkgdi9BYrd9BcZdpWdPrXyaPRrXWEgIAWU8rMKOeL(pFLspfdnw2tSQ4vmGRf6AtXGkpiMNgbU82NCrMasG0yzpXYdi5bdi9BYrd9BcZdpWdPHh0GhqJMhmG0Vjhn0Vjmp8apODkgdiDnkML3(ewUgfKsu6)mTu6PymG01Oyw9rzZ7vm0yzpXQIxjkrXaQFEJLUgxuIHjLEk9FQ0tXqJL9eRkEfd4AHU2um59Abb1pVXsxdKTInkgdiDnkgFJirWoTzBweFAeLO0pnk9um0yzpXQIxXaUwORnfJ9601cbZEdl05(gwOdsJL9elpGKheZtJaxE7tUAG0yzpXQymG01OyaM37mG0148nwum(glUX(KIj)DG6N3yPRXfLyysjk9FLspfJbKUgft2xfRRwojHC0q)0vm0yzpXQIxjk9tlLEkgdiDnkMp9RlDxTC(nOzDShzFSIHgl7jwv8krPV2P0tXyaPRrXGyBhBBJRwo71PRKefdnw2tSQ4vIsFTHspfdnw2tSQ4vmGRf6AtXK3Rfeu)8glDnq2k2OymG01OyU9qUA5IQy0PeL(PDLEkgASSNyvXRymG01OyaM37mG0148nwum(glUX(KIXas)MCI5PrWkrPV2xPNIHgl7jwv8kMnMCXsAp5agw6bHI5PIbCTqxBkgu5Hu4b71PRfcM9gwOZ9nSqhKgl7jwEanAEifEqmpncC5Tp5QbsJL9elpObpGKhqLhqLhmG01a)Kq1b7XT8nIeHhqJMhIo6TdbGf(e(jHQJhqJMhav5zRyd8tcvh8OV1dMhEGh0oEqdEanAEifEqmpnc8tcvhKgl7jwEqdEajpGkpK3Rf82d5QLlQIrhChXdOrZdPWdI5PrG3EixTCrvm6G0yzpXYdAOy2yYvRLdbGvX8uXyaPRrXaQFEJLUgLO0xBP0tXyaPRrXevsxJIHgl7jwv8krP)Zxu6PymG01OyY(QyDR9LUIHgl7jwv8krP)ZNk9umgq6Aumz6W0HIEqOyOXYEIvfVsu6)mnk9umgq6AumR(OSVkwfdnw2tSQ4vIs)NVsPNIXasxJIXgaHLZ8oG59kgASSNyvXReL(ptlLEkgASSNyvXRymG01OyaM37mG0148nwum(glUX(KIrUEqbjyLO0)P2P0tXqJL9eRkEfd4AHU2umOYdOYdI5PrGlV9jxKjGeinw2tS8asEWas)MC0q)MW8Wd8qA4bn4b0O5bdi9BYrd9BcZdpWdAdEqdEajpK3RfmPehwoYqb8idikgdiDnkML3(ewUgfKsu6)uBO0tXqJL9eRkEfd4AHU2um59AbJs)kG3WF4rgq4bK8qEVwqq9ZBS01ap6B9G5Hh4bGHfN0FsXyaPRrXeL(vzVHfLO0)zAxPNIHgl7jwv8kgW1cDTPyY71cMuIdlhzOaEKbefJbKUgftu6xL9gwuIs)NAFLEkgASSNyvXRy2yYflP9KdyyPhekMNkgW1cDTPyqLhsHhSxNUwiy2ByHo33WcDqASSNy5b0O5Hu4bX80iWL3(KRginw2tS8Gg8asEavEavEiVxliO(5nw6AG7iEajpGkpK3RfmHmPheUDe8idi8asEifEWasxdmk9RYEdlWEClFJir4bK8qk8GbKUgiguhibsOKaBPhe8Gg8aA08aQ8GbKUgiguhibsOKaBHCh9TEW8asEiVxlyczspiC7iiBfB4bK8qEVwWKsCy5idfq2k2Wdi5Hu4bdiDnWO0Vk7nSa7XT8nIeHh0Gh0Gh0qXSXKRwlhcaRI5PIXasxJIz1h5YEdlkrP)tTLspfdnw2tSQ4vmGRf6AtXeD0Bhcal8jedQdKWdi5H8ETGjKj9GWTJG7ifJbKUgftu6xL9gwuIs)08IspfJbKUgftusrtJs3YBFcRyOXYEIvfVsu6NMNk9um0yzpXQIxXaUwORnftEVwqq9ZBS01ap6B9G5Hh4bGHfN0FIhqYd59Abb1pVXsxdChXdOrZd59Abb1pVXsxdKTInkgdiDnkgmOoqIsu6NM0O0tXqJL9eRkEfd4AHU2um59Abb1pVXsxd8OV1dMhEKhqayHFdL8asEWas)MC0q)MW8Wd8WtfJbKUgfJVF3dcxU(zLO0pnVsPNIHgl7jwv8kgW1cDTPyY71ccQFEJLUg4rFRhmp8ipGaWc)gk5bK8qEVwqq9ZBS01a3rkgdiDnkg2Zqud2LpYKeLO0pnPLspfdnw2tSQ4vmGRf6AtXi2HGeyczEjbgbeE4rD8WREHhqYdI5PrGyYUEq4KAdsG0yzpXQymG01OyWG6ajkrjkM83bQFEJLUgxuIHjLEk9FQ0tXqJL9eRkEfd4AHU2um59Abb1pVXsxdKTInkgdiDnkgFJirWoTzBweFAeLO0pnk9um0yzpXQIxXaUwORnftEVwqq9ZBS01azRydpGKhmG0Vjhn0Vjmp8ap8uXyaPRrX4739GWLRFwjk9FLspfdnw2tSQ4vmGRf6AtXK3Rfeu)8glDnq2k2OymG01OyU9qUA5IQy0PeL(PLspfdnw2tSQ4vmBm5IL0EYbmS0dcfZtfJbKUgfZQpYL9gwumGRf6AtXK3Rfm7nSqN7ByHoiBfB4bK8aQ8GyEAe4ThYvlxufJoinw2tS8asEWasxd82d5QLlQIrhKqjb2spi4bK8GbKUg4ThYvlxufJoiHscSfYD036bZdpYdVa1g8aA08aQ8aOkpBfBGG6N3yPRbEKXMopGgnpK3Rfeu)8glDnWDepObpGKhsHheZtJaV9qUA5IQy0bPXYEILhqYdPWdgq6AGrPFv2Byb2JB5BejcpGKhsHhmG01ax9rzZ7H94w(grIWdAOeL(ANspfdnw2tSQ4vmgq6AumaZ7Dgq6AC(glkgFJf3yFsXyaPFtoX80iyLO0xBO0tXqJL9eRkEfZgtUyjTNCadl9GqX8uXaUwORnfJ9601cbZEdl05(gwOdsJL9elpGKhqLhqLhmG01a)Kq1b7XT8nIeHhqJMhIo6TdbGf(e(jHQJhqJMhav5zRyd8tcvh8OV1dMhEGh0oEqdEanAEifEqmpnc8tcvhKgl7jwEqdEajpGkpK3Rf82d5QLlQIrhChXdOrZdPWdI5PrG3EixTCrvm6G0yzpXYdAOy2yYvRLdbGvX8uXyaPRrXaQFEJLUgLO0pTR0tXyaPRrXevsxJIHgl7jwv8krPV2xPNIXasxJIj7RI1T2x6kgASSNyvXReL(AlLEkgdiDnkMmDy6qrpium0yzpXQIxjk9F(IspfJbKUgfZQpk7RIvXqJL9eRkELO0)5tLEkgdiDnkgBaewoZ7aM3RyOXYEIvfVsu6)mnk9um0yzpXQIxXyaPRrXamV3zaPRX5BSOy8nwCJ9jfJC9GcsWkrP)ZxP0tXqJL9eRkEfd4AHU2umrh92HaWcFcXG6aj8asEiVxlyczspiC7i4osXyaPRrXeL(vzVHfLO0)zAP0tXqJL9eRkEfd4AHU2um59AbtkXHLJmua3rkgdiDnkMO0Vk7nSOeL(p1oLEkgASSNyvXRyaxl01MIjVxlyu6xb8g(dpYacpGKhagwCs)jE4rEiVxliO(5nw6AGh9TEWkgdiDnkMO0Vk7nSOeL(p1gk9umgq6AumrjfnnkDlV9jSIHgl7jwv8krP)Z0Uspfdnw2tSQ4vmGRf6AtXK3Rfm7nSqN7ByHoiwmak4bD8WtEajpK3RfmPehwoYqbKTIn8asEifEiVxlyu6xb8g(dpYacpGKhIo6TdbGf(egL(vzVHfEajpGkpK3Rfm7nSqN7ByHo4rFRhmp8ip8c8P2XdOrZdiaSWJ(wpyE4rE4f4tTJh0qXyaPRrXS6JCzVHffZgtUATCiaSkMNkrP)tTVspfdnw2tSQ4vmBm5IL0EYbmS0dcfZtfJbKUgfZQpYL9gwumGRf6AtXK3Rfm7nSqN7ByHoiwmak4bD8WtEajpGkpyaPRbIb1bsGekjWw6bbpGKhmG01aXG6ajqcLeylK7OV1dMhEKhEb(u74b0O5H8ETGzVHf6CFdl0bp6B9G5Hh5HxGp1oEqdLO0)P2sPNIHgl7jwv8kgW1cDTPyY71cMuIdlhzOaYwXgEajpGkpaQYZwXg4QpYL9gwGh9TEW8WJ8aWWIt6pXdOrZdgq6AGR(ix2BybcsSdbH5Hh4Hx4bnumgq6AumyqDGeLO0pnVO0tXqJL9eRkEfZgtUyjTNCadl9GqX8uXaUwORnftEVwWS3WcDUVHf6GyXaOGhEGhEYdi5bu5HOJE7qayHpHyqDGeEajpKcpK3RfmPehwoYqbChXdi5Hu4bdiDnqmOoqcKqjb2spi4b0O5H8ETGzVHf6CFdl0bp6B9G5Hh5HxGp1oEqdfZgtUATCiaSkMNkgdiDnkMvFKl7nSOeL(P5Pspfdnw2tSQ4vmGRf6AtXK3Rfeu)8glDnWJ(wpyE4rEabGf(nuYdi5bdi9BYrd9BcZdpWdpvmgq6Aum((DpiC56NvIs)0KgLEkgASSNyvXRyaxl01MIjVxliO(5nw6AGh9TEW8WJ8acal8BOuXyaPRrXWEgIAWU8rMKOeL(P5vk9umgq6AumyqDGefdnw2tSQ4vIsumyXgw7yDxjM01O0tP)tLEkgASSNyvXRyaxl01MIbvEavEqmpncC5Tp5ImbKaPXYEILhqYdgq63KJg63eMhEGhEYdi5Hu4HvFewStOdAaPFt8Gg8aA08GbK(n5OH(nH5Hh4H0Ih0GhqYd59AbtkXHLJmuapYaIIXasxJIz5TpHLRrbPeL(PrPNIHgl7jwv8kgW1cDTPyY71cMuIdlhzOaEKbeEajpK3RfmPehwoYqb8OV1dMhEKhmG01ax9rzZ7HekjWwiN0FsXyaPRrXeL(vzVHfLO0)vk9um0yzpXQIxXaUwORnftEVwWKsCy5idfWJmGWdi5bu5HOJE7qayHpHR(OS598aA08WQpcl2j0bnG0VjEanAEWasxdmk9RYEdlWEClFJir4bnumgq6AumrPFv2Byrjk9tlLEkgASSNyvXRyaxl01MIjVxlysjoSCKHc4rgq4bK8GyhcsGjK5Leyeq4Hh1XdV6fEajpiMNgbIj76bHtQnibsJL9eRIXasxJIjk9RYEdlkrPV2P0tXqJL9eRkEfd4AHU2um59AbJs)kG3WF4rgq4bK8aWWIt6pXdpYd59AbJs)kG3WF4rFRhSIXasxJIjk9RYEdlkrPV2qPNIHgl7jwv8kMnMCXsAp5agw6bHI5PIbCTqxBkgu5bqvE2k2ab1pVXsxd8OV1dMhEGhEHhqYd59AbV9qUA5IQy0bzRydpGgnpS6JWIDcDqdi9BIh0GhqYdPWdI5PrGOOhwFpiG0yzpXYdi5Hu4H321w2tWvFKl7nS4IQY3dcEajpGkpGkpGkpyaPRbU6JYM3djusGT0dcEanAEWasxdmk9RYEdlqcLeyl9GGh0GhqYdOYd59Abtit6bHBhbpYacpGgnpS6JWIDcDqdi9BIhqYdPWd59AbtkXHLJmuapYacpGKhsHhY71cMqM0dc3ocEKbeEqdEqdEanAEavEqmpncet21dcNuBqcKgl7jwEajpi2HGeyczEjbgbeE4rD8WREHhqYdOYd59Abtit6bHBhbpYacpGKhsHhmG01aXG6ajqcLeyl9GGhqJMhsHhY71cMuIdlhzOaEKbeEajpKcpK3RfmHmPheUDe8idi8asEWasxdedQdKajusGT0dcEajpKcpyaPRbgL(vzVHfypULVrKi8asEifEWasxdC1hLnVh2JB5BejcpObpObpGgnpGkpS6JWIDcDqdi9BIhqYdOYdgq6AGrPFv2Byb2JB5BejcpGgnpyaPRbU6JYM3d7XT8nIeHh0GhqYdPWd59Abtit6bHBhbpYacpGKhsHhY71cMuIdlhzOaEKbeEqdEqdfZgtUATCiaSkMNkgdiDnkMvFKl7nSOeL(PDLEkgASSNyvXRyaxl01MIrmpncef9W67bbKgl7jwEajpK3RfmHmPheUDe8idi8asEavEauLNTInqq9ZBS01ap6B9G5Hh4H127DhbsSdb5K(t8qC8qA4H44bX80iqu0dRVheqASSNy5b0O5HvFewStOdE036bZdpWdRT37ocKyhcYj9N4b0O5bu5Hu4bX80iWBpKRwUOkgDqASSNy5b0O5bqvE2k2aV9qUA5IQy0bp6B9G5Hh4bP)KtkhBt8asEWasxd82d5QLlQIrheKyhccZdpYdp5bn4bK8aOkpBfBGG6N3yPRbE036bZdpWds)jNuo2M4bnumgq6AumR(ix2Byrjk91(k9um0yzpXQIxXaUwORnft0rVDiaSWNqmOoqcpGKhY71cMqM0dc3ocUJ4bK8GyEAeiMSRheoP2Geinw2tS8asEqSdbjWeY8scmci8WJ64Hx9cpGKhqLhqLheZtJaxE7tUitajqASSNy5bK8GbK(n5OH(nH5bD8WtEajpKcpS6JWIDcDqdi9BIh0GhqJMhqLhmG0Vjhn0Vjmp8ipKw8asEifEqmpncC5Tp5ImbKaPXYEILh0Gh0qXyaPRrXeL(vzVHfLO0xBP0tXqJL9eRkEfd4AHU2umOYd59Abtit6bHBhbpYacpGgnpGkpKcpK3RfmPehwoYqb8idi8asEavEWasxdC1h5YEdlqqIDiimp8ap8cpGgnpiMNgbIj76bHtQnibsJL9elpGKhe7qqcmHmVKaJacp8OoE4vVWdAWdAWdAWdi5Hu4H321w2tWOKIMgLUOQ89GqXyaPRrXeLu00O0T82NWkrP)Zxu6PyOXYEIvfVIXasxJIbyEVZasxJZ3yrX4BS4g7tkgdi9BYjMNgbReL(pFQ0tXqJL9eRkEfd4AHU2umgq63KJg63eMhEGhEQymG01Oyypdrnyx(itsuIs)NPrPNIHgl7jwv8kgdiDnkgPzjSu33bkwcLkgW1cDTPyav5zRydeu)8glDnWJ(wpyE4bEinVWdOrZdI5PrGR(iSyNqhKgl7jwEajpS6JWIDcDWJ(wpyE4bEinVOyg7tkgPzjSu33bkwcLkrP)ZxP0tXqJL9eRkEfd4AHU2umIDiibMqMxsGraHhEuhp8Qx4bK8GyEAeiMSRheoP2Geinw2tSkgdiDnkgmOoqIsu6)mTu6PymG01Oyw9rzZ7vm0yzpXQIxjk9FQDk9umgq6AumyqDGefdnw2tSQ4vIsumrhbQF2eLEk9FQ0tXqJL9eRkELO0pnk9um0yzpXQIxjk9FLspfdnw2tSQ4vIs)0sPNIXasxJIXoGnKRhH8EcikgASSNyvXReL(ANspfdnw2tSQ4vmvKIbtIIXasxJI5TDTL9KI5T53KIrB8II5TDUX(KIbu)8glDnURICGTuRLsu6Rnu6PyOXYEIvfVsu6N2v6PymG01Oy(9D156VHGum0yzpXQIxjk91(k9umgq6AumrL01OyOXYEIvfVsu6RTu6PymG01OyIs)QS3WIIHgl7jwv8krjkrX8MoCxJs)08YtT)Z088j8fTFAL2vmXSB6bbwXOnXpQoHy5bTppyaPRHh8nwWqUMkgCebu6RnELIj6Qv7jfJ2MhEn6J4bTPgcIRP2MhsejcR9OLwiAjzNHG6RfU)BVjDnGZwIw4(d0k7RSw5L9AzP3AfD1Q9ewR0MJsBTMfRvAtARtBQHGCVg9rqC)bCn128GM7H4H0ODPYdP5LNAlE41YdVOT0EsRx4AY1uBZdAVj2GGWApCn128WRLh0Met8G0FYjLJTjE4mjHoEqsSHhe7qqcu6p5KYX2epSQJh8gwETycudlpy523s68WgBiimKRjxtTnp8AgLeylelpKPvDepaQF2eEiti6bd5HxtaaksW8WuZRnXU)A75bdiDnyEOgF6qUMgq6AWWOJa1pBIUL3WOGRPbKUgmm6iq9ZMeNoTwvXY10asxdggDeO(ztItNw2gXNgXKUgUMgq6AWWOJa1pBsC60YoGnKRhH8EciCn128GEjnMhEBxBzpXdysW8GKq8G0FIhmHhIL0GeEiTDpepulEiTPIrhpGtQTNLhWIDcpKPEqWdy7nXYdR64bjH4HHqPWdAV1pVXsxdpeLyyIRPbKUgmm6iq9ZMeNoTEBxBzpL6yFshO(5nw6ACxf5aBPwRuRiDyss9T53KoTXlCnnG01GHrhbQF2K40PfESiCsjoSycMRPbKUgmm6iq9ZMeNoT(9D156VHG4AAaPRbdJocu)SjXPtROs6A4AAaPRbdJocu)SjXPtRO0Vk7nSW1KRP2MhEnJscSfILhO30Lopi9N4bjH4bdi1XdnMhS3w7TSNGCnnG01G1bQ9i0HJiVNRPbKUgCC60633vNR)gck1EPlVxliO(5nw6AGSvSHRPbKUgCC60cudGg5mHyDlV9jUMgq6AWXPtRvb2yI1zVoDTqUmzFUMgq6AWXPtRO91R07bHl7nSW10asxdooDADDuKNC94WrgG4AAaPRbhNoTKeYTNCThw3QoaX10asxdooDAfRop7BQh3r4ASbqCnnG01GJtNw3EixTCrvm6sTx6eZtJax9ryXoHoinw2tSix9ryXoHo4rFRh8dRT37ocKyhcYj9NqJguLNTInqq9ZBS01ap6B9GF4TDTL9eeu)8glDnURICGTuRfY8ETGG6N3yPRbYwXg0OL(toPCSn9iOkpBfBGG6N3yPRbE036bJmVxliO(5nw6AGSvSHRPbKUgCC60cyEVZasxJZ3yj1X(Koq9ZBS014IsmmLAV0HQyEAe4ThYvlxufJoinw2tSibv5zRydeu)8glDnWJ(wp4h1zaPRbE7HC1YfvXOdcmS4K(tOrdQYZwXgiO(5nw6AGhzSPRbYuw9ryXoHoObK(nHgDEVwqq9ZBS01a3rCnnG01GJtNwaZ7Dgq6AC(glPo2N0DvKlkXWuQ9sxEVwWBpKRwUOkgDWDeY8ETGG6N3yPRbYwXgUMgq6AWXPtR321w2tPo2N0T6JCzVHfxuv(EqK6BZVjDI5PrG3EixTCrvm6G0yzpXIeuLNTInWBpKRwUOkgDWJ(wp4hbv5zRydC1h5YEdlW127DhbsSdb5K(tirfuLNTInqq9ZBS01ap6B9GF4TDTL9eeu)8glDnURICGTuRfA0R(iSyNqh0as)M0ajQGQ8SvSbE7HC1YfvXOdE036b)O0FYjLJTj0OnG01aV9qUA5IQy0bbj2HGWp8IgOrdQYZwXgiO(5nw6AGh9TEWpAaPRbU6JCzVHf4A79UJaj2HGCs)P4av5zRydC1h5YEdlq29zsxJ2C71PRfcM9gwOZ9nSqhKgl7jwKPS6JWIDcDqdi9BcjOkpBfBGG6N3yPRbE036b)O0FYjLJTj0OfZtJax9ryXoHoinw2tSix9ryXoHoObK(nHC1hHf7e6Gh9TEWpcQYZwXg4QpYL9gwGRT37ocKyhcYj9NIduLNTInWvFKl7nSaz3NjDnAZTxNUwiy2ByHo33WcDqASSNy5AAaPRbhNoTEBxBzpL6yFsxusrtJsxuv(EqK6BZVjDI5PrG3EixTCrvm6G0yzpXIeuLNTInWBpKRwUOkgDWJ(wp4hbv5zRydmkPOPrPB5TpHHRT37ocKyhcYj9NqcQYZwXgiO(5nw6AGh9TEWp82U2YEccQFEJLUg3vroWwQ1cjQGQ8SvSbE7HC1YfvXOdE036b)O0FYjLJTj0OnG01aV9qUA5IQy0bbj2HGWp8IgOrdQYZwXgiO(5nw6AGh9TEWpAaPRbgLu00O0T82NWW127DhbsSdb5K(tibv5zRydeu)8glDnWJ(wp4hL(toPCSnX10asxdooDAbmV3zaPRX5BSK6yFshwSH1ow3vIjDnCn5AAaPRbdnG0VjNyEAeSoF)UheUC9ZP2lDgq63KJg63e(HNiZ71ccQFEJLUgiBfBqIkOkpBfBGG6N3yPRbE036b)aOkpBfBG((DpiC56NHS7ZKUg0Obv5zRydeu)8glDnWJm201GRPbKUgm0as)MCI5PrWXPtRpjuDP2lD59AbV9qUA5IQy0b3rirD1hHf7e6Gh9TEWpaQYZwXg4NeQoi7(mPRbn6uw9ryXoHoObK(nPbA0GQ8SvSbE7HC1YfvXOdE036b)G0FYjLJTjKgq6AG3EixTCrvm6GGe7qq4hFIgnQGQ8SvSb(jHQdYUpt6AEeuLNTInqq9ZBS01ap6B9GrJguLNTInqq9ZBS01apYytxdKPiMNgbE7HC1YfvXOdsJL9elsubv5zRyd8tcvhKDFM0184Qpcl2j0bp6B9GrJofX80iWvFewStOdsJL9elA0PS6JWIDcDqdi9BsdUMCnnG01GH5Vdu)8glDnUOedt68nIeb70MTzr8PrsTx6Y71ccQFEJLUgiBfB4AAaPRbdZFhO(5nw6ACrjgMItNw((DpiC56NtTx6Y71ccQFEJLUgiBfBqAaPFtoAOFt4hEY10asxdgM)oq9ZBS014IsmmfNoTU9qUA5IQy0LAV0L3Rfeu)8glDnq2k2W10asxdgM)oq9ZBS014IsmmfNoTw9rUS3WsQBm5IL0EYbmS0dcDptTx6Y71cM9gwOZ9nSqhKTInirvmpnc82d5QLlQIrhKgl7jwKgq6AG3EixTCrvm6GekjWw6bbsdiDnWBpKRwUOkgDqcLeylK7OV1d(XxGAd0OrfuLNTInqq9ZBS01apYythn68ETGG6N3yPRbUJ0azkI5PrG3EixTCrvm6G0yzpXImfdiDnWO0Vk7nSa7XT8nIebzkgq6AGR(OS59WEClFJir0GRPbKUgmm)DG6N3yPRXfLyykoDAbmV3zaPRX5BSK6yFsNbK(n5eZtJG5AAaPRbdZFhO(5nw6ACrjgMItNwG6N3yPRj1nMC1A5qay19m1nMCXsAp5agw6bHUNP2lD2Rtxlem7nSqN7ByHoinw2tSirfvdiDnWpjuDWEClFJirqJo6O3oeaw4t4NeQo0Obv5zRyd8tcvh8OV1d(bTtd0Otrmpnc8tcvhKgl7jwnqIAEVwWBpKRwUOkgDWDeA0PiMNgbE7HC1YfvXOdsJL9eRgCnnG01GH5Vdu)8glDnUOedtXPtROs6A4AAaPRbdZFhO(5nw6ACrjgMItNwzFvSU1(sNRPbKUgmm)DG6N3yPRXfLyykoDALPdthk6bbxtdiDnyy(7a1pVXsxJlkXWuC60A1hL9vXY10asxdgM)oq9ZBS014IsmmfNoTSbqy5mVdyEpxtdiDnyy(7a1pVXsxJlkXWuC60cyEVZasxJZ3yj1X(Ko56bfKG5AAaPRbdZFhO(5nw6ACrjgMItNwrPFv2Byj1EPl6O3oeaw4tiguhibzEVwWeYKEq42rWDextdiDnyy(7a1pVXsxJlkXWuC60kk9RYEdlP2lD59AbtkXHLJmua3rCnnG01GH5Vdu)8glDnUOedtXPtRO0Vk7nSKAV0L3Rfmk9RaEd)HhzabjWWIt6p9yEVwqq9ZBS01ap6B9G5AAaPRbdZFhO(5nw6ACrjgMItNwrjfnnkDlV9jmxtdiDnyy(7a1pVXsxJlkXWuC60A1h5YEdlPUXKRwlhcaRUNP2lD59AbZEdl05(gwOdIfdGcDprM3RfmPehwoYqbKTInitjVxlyu6xb8g(dpYacYOJE7qayHpHrPFv2BybjQ59AbZEdl05(gwOdE036b)4lWNAhA0iaSWJ(wp4hFb(u70GRPbKUgmm)DG6N3yPRXfLyykoDAT6JCzVHLu3yYflP9KdyyPhe6EMAV0L3Rfm7nSqN7ByHoiwmak09ejQgq6AGyqDGeiHscSLEqG0asxdedQdKajusGTqUJ(wp4hFb(u7qJoVxly2ByHo33WcDWJ(wp4hFb(u70GRPbKUgmm)DG6N3yPRXfLyykoDAHb1bssTx6Y71cMuIdlhzOaYwXgKOcQYZwXg4QpYL9gwGh9TEWpcmS4K(tOrBaPRbU6JCzVHfiiXoee(Hx0GRPbKUgmm)DG6N3yPRXfLyykoDAT6JCzVHLu3yYflP9KdyyPhe6EM6gtUATCiaS6EMAV0L3Rfm7nSqN7ByHoiwmakE4jsuJo6TdbGf(eIb1bsqMsEVwWKsCy5idfWDeYumG01aXG6ajqcLeyl9Gan68ETGzVHf6CFdl0bp6B9GF8f4tTtdUMgq6AWW83bQFEJLUgxuIHP40PLVF3dcxU(5u7LU8ETGG6N3yPRbE036b)ical8BOePbK(n5OH(nHF4jxtdiDnyy(7a1pVXsxJlkXWuC60I9me1GD5Jmjj1EPlVxliO(5nw6AGh9TEWpIaWc)gk5AAaPRbdZFhO(5nw6ACrjgMItNwyqDGeUMCn128G2B9ZBS01WdrjgM4HOJISJW8GLBFlnH5HyTKWdgpWsEl9u5bjHgEWB7bKqyEOhP4bjH4bT36N3yPRHhW0RPBAaextdiDnyiO(5nw6ACrjgM05Bejc2PnBZI4tJKAV0L3Rfeu)8glDnq2k2W10asxdgcQFEJLUgxuIHP40PfW8ENbKUgNVXsQJ9jD5Vdu)8glDnUOedtP2lD2Rtxlem7nSqN7ByHoinw2tSifZtJaxE7tUAG0yzpXY10asxdgcQFEJLUgxuIHP40Pv2xfRRwojHC0q)05AAaPRbdb1pVXsxJlkXWuC606t)6s3vlNFdAwh7r2hZ10asxdgcQFEJLUgxuIHP40PfITDSTnUA5SxNUss4AAaPRbdb1pVXsxJlkXWuC6062d5QLlQIrxQ9sxEVwqq9ZBS01azRydxtdiDnyiO(5nw6ACrjgMItNwaZ7Dgq6AC(glPo2N0zaPFtoX80iyUMgq6AWqq9ZBS014IsmmfNoTa1pVXsxtQBm5Q1YHaWQ7zQBm5IL0EYbmS0dcDptTx6qnf71PRfcM9gwOZ9nSqhKgl7jw0OtrmpncC5Tp5QbsJL9eRgirfvdiDnWpjuDWEClFJirqJo6O3oeaw4t4NeQo0Obv5zRyd8tcvh8OV1d(bTtd0Otrmpnc8tcvhKgl7jwnqIAEVwWBpKRwUOkgDWDeA0PiMNgbE7HC1YfvXOdsJL9eRgCnnG01GHG6N3yPRXfLyykoDAfvsxdxtdiDnyiO(5nw6ACrjgMItNwzFvSU1(sNRPbKUgmeu)8glDnUOedtXPtRmDy6qrpi4AAaPRbdb1pVXsxJlkXWuC60A1hL9vXY10asxdgcQFEJLUgxuIHP40PLnaclN5DaZ75AAaPRbdb1pVXsxJlkXWuC60cyEVZasxJZ3yj1X(Ko56bfKG5AAaPRbdb1pVXsxJlkXWuC60A5TpHLRrbLAV0HkQI5PrGlV9jxKjGeinw2tSinG0Vjhn0Vj8dPrd0OnG0Vjhn0Vj8dAdnqM3RfmPehwoYqb8idiCnnG01GHG6N3yPRXfLyykoDAfL(vzVHLu7LU8ETGrPFfWB4p8idiiZ71ccQFEJLUg4rFRh8dadloP)extdiDnyiO(5nw6ACrjgMItNwrPFv2Byj1EPlVxlysjoSCKHc4rgq4AAaPRbdb1pVXsxJlkXWuC60A1h5YEdlPUXKRwlhcaRUNPUXKlws7jhWWspi09m1EPd1uSxNUwiy2ByHo33WcDqASSNyrJofX80iWL3(KRginw2tSAGevuZ71ccQFEJLUg4ocjQ59Abtit6bHBhbpYacYumG01aJs)QS3WcSh3Y3iseKPyaPRbIb1bsGekjWw6bHgOrJQbKUgiguhibsOKaBHCh9TEWiZ71cMqM0dc3ocYwXgK59AbtkXHLJmuazRydYumG01aJs)QS3WcSh3Y3isen0qdUMgq6AWqq9ZBS014IsmmfNoTIs)QS3WsQ9sx0rVDiaSWNqmOoqcY8ETGjKj9GWTJG7iUMgq6AWqq9ZBS014IsmmfNoTIskAAu6wE7tyUMgq6AWqq9ZBS014IsmmfNoTWG6ajP2lD59Abb1pVXsxd8OV1d(bGHfN0FczEVwqq9ZBS01a3rOrN3Rfeu)8glDnq2k2W10asxdgcQFEJLUgxuIHP40PLVF3dcxU(5u7LU8ETGG6N3yPRbE036b)ical8BOePbK(n5OH(nHF4jxtdiDnyiO(5nw6ACrjgMItNwSNHOgSlFKjjP2lD59Abb1pVXsxd8OV1d(reaw43qjY8ETGG6N3yPRbUJ4AAaPRbdb1pVXsxJlkXWuC60cdQdKKAV0j2HGeyczEjbgbKh19QxqkMNgbIj76bHtQnibsJL9elxtUMgq6AWWRICrjgM0D7HC1YfvXOJRPbKUgm8QixuIHP40P1YBFclxJck1EPdvufZtJaxE7tUitajqASSNyrAaPFtoAOFt4hEQbA0gq63KJg63e(H0sdK59AbtkXHLJmuapYacxtdiDny4vrUOedtXPtRO0Vk7nSKAV0L3RfmPehwoYqb8idiCnnG01GHxf5IsmmfNoTw9rUS3WsQBm5Q1YHaWQ7zQBm5IL0EYbmS0dcDptTx6qfuLNTInqq9ZBS01ap6B9GF4f0Ox9ryXoHoObK(nHmVxl4ThYvlxufJo4osdKOMsEVwWeYKEq42rWJmGGmL8ETGjL4WYrgkGhzabzkrh92vRLdbGfU6JCzVHfKOAaPRbU6JCzVHfiiXoee(bDPbnAunG01aJskAAu6wE7tyiiXoee(bDprkMNgbgLu00O0T82NWqASSNy1anAufZtJanpHsSCg(1nSBTV0H0yzpXIeuLNTInq2Zqud2LpYKe4rgB6AGgnQI5PrGyYUEq4KAdsG0yzpXIuSdbjWeY8scmcipQ7vVObA0OkMNgbU6JWIDcDqASSNyrU6JWIDcDqdi9Bsdn0GRPbKUgm8QixuIHP40PfW8ENbKUgNVXsQJ9jDgq63KtmpncMRPbKUgm8QixuIHP40Pvu6xL9gwsTx6Y71cgL(vaVH)WJmGGeyyXj9NEmVxlyu6xb8g(dp6B9GrM3Rf82d5QLlQIrh8OV1d(bGHfN0FIRPbKUgm8QixuIHP40P1QpYL9gwsDJjxTwoeawDptDJjxSK2toGHLEqO7zQ9shQGQ8SvSbcQFEJLUg4rFRh8dVGg9Qpcl2j0bnG0VjK59AbV9qUA5IQy0b3rAGe18ETGjKj9GWTJGhzabjQIDiibMqMxsGra5bDV6f0Otrmpncet21dcNuBqcKgl7jwn0GRPbKUgm8QixuIHP40P1QpYL9gwsDJjxTwoeawDptDJjxSK2toGHLEqO7zQ9shQGQ8SvSbcQFEJLUg4rFRh8dVGg9Qpcl2j0bnG0VjK59AbV9qUA5IQy0b3rAGumpncet21dcNuBqcKgl7jwKIDiibMqMxsGra5rDV6fKOM3RfmHmPheUDe8idiitXasxdedQdKajusGT0dc0OtjVxlyczspiC7i4rgqqMsEVwWKsCy5idfWJmGObxtdiDny4vrUOedtXPtRO0Vk7nSKAV0fD0Bhcal8jedQdKGmVxlyczspiC7i4ocPyEAeiMSRheoP2Geinw2tSif7qqcmHmVKaJaYJ6E1lirnfX80iWL3(KlYeqcKgl7jw0OnG0Vjhn0VjSUNAW10asxdgEvKlkXWuC60kkPOPrPB5TpHtTx6sj6O3oeaw4tyusrtJs3YBFcJmVxlyczspiC7i4rgq4AAaPRbdVkYfLyykoDAHb1bssTx6e7qqcmHmVKaJaYJ6E1lifZtJaXKD9GWj1gKaPXYEILRPbKUgm8QixuIHP40Pf7ziQb7YhzssQ9sNbK(n5OH(nHFinCnnG01GHxf5IsmmfNoTwE7ty5AuqP2lDOkMNgbU82NCrMasG0yzpXI0as)MC0q)MWpKgnqJ2as)MC0q)MWpODCnnG01GHxf5IsmmfNoTw9rzZ75AY10asxdgIfByTJ1DLysxJUL3(ewUgfuQ9shQOkMNgbU82NCrMasG0yzpXI0as)MC0q)MWp8ezkR(iSyNqh0as)M0anAdi9BYrd9Bc)qAPbY8ETGjL4WYrgkGhzaHRPbKUgmel2WAhR7kXKUM40Pvu6xL9gwsTx6Y71cMuIdlhzOaEKbeK59AbtkXHLJmuap6B9GF0asxdC1hLnVhsOKaBHCs)jUMgq6AWqSydRDSURet6AItNwrPFv2Byj1EPlVxlysjoSCKHc4rgqqIA0rVDiaSWNWvFu28E0Ox9ryXoHoObK(nHgTbKUgyu6xL9gwG94w(grIObxtdiDnyiwSH1ow3vIjDnXPtRO0Vk7nSKAV0L3RfmPehwoYqb8idiif7qqcmHmVKaJaYJ6E1lifZtJaXKD9GWj1gKaPXYEILRPbKUgmel2WAhR7kXKUM40Pvu6xL9gwsTx6Y71cgL(vaVH)WJmGGeyyXj9NEmVxlyu6xb8g(dp6B9G5AAaPRbdXInS2X6UsmPRjoDAT6JCzVHLu3yYvRLdbGv3Zu3yYflP9KdyyPhe6EMAV0HkOkpBfBGG6N3yPRbE036b)WliZ71cE7HC1YfvXOdYwXg0Ox9ryXoHoObK(nPbYueZtJarrpS(EqaPXYEIfzkVTRTSNGR(ix2ByXfvLVheirfvunG01ax9rzZ7HekjWw6bbA0gq6AGrPFv2BybsOKaBPheAGe18ETGjKj9GWTJGhzabn6vFewStOdAaPFtitjVxlysjoSCKHc4rgqqMsEVwWeYKEq42rWJmGOHgOrJQyEAeiMSRheoP2Geinw2tSif7qqcmHmVKaJaYJ6E1lirnVxlyczspiC7i4rgqqMIbKUgiguhibsOKaBPheOrNsEVwWKsCy5idfWJmGGmL8ETGjKj9GWTJGhzabPbKUgiguhibsOKaBPheitXasxdmk9RYEdlWEClFJirqMIbKUg4QpkBEpSh3Y3isen0anAux9ryXoHoObK(nHevdiDnWO0Vk7nSa7XT8nIebnAdiDnWvFu28EypULVrKiAGmL8ETGjKj9GWTJGhzabzk59AbtkXHLJmuapYaIgAW10asxdgIfByTJ1DLysxtC60A1h5YEdlP2lDI5PrGOOhwFpiG0yzpXImVxlyczspiC7i4rgqqIkOkpBfBGG6N3yPRbE036b)WA79UJaj2HGCs)P4stCI5PrGOOhwFpiG0yzpXIg9Qpcl2j0bp6B9GFyT9E3rGe7qqoP)eA0OMIyEAe4ThYvlxufJoinw2tSOrdQYZwXg4ThYvlxufJo4rFRh8ds)jNuo2MqAaPRbE7HC1YfvXOdcsSdbHF8Pgibv5zRydeu)8glDnWJ(wp4hK(toPCSnPbxtdiDnyiwSH1ow3vIjDnXPtRO0Vk7nSKAV0fD0Bhcal8jedQdKGmVxlyczspiC7i4ocPyEAeiMSRheoP2Geinw2tSif7qqcmHmVKaJaYJ6E1lirfvX80iWL3(KlYeqcKgl7jwKgq63KJg63ew3tKPS6JWIDcDqdi9Bsd0Or1as)MC0q)MWpMwitrmpncC5Tp5ImbKaPXYEIvdn4AAaPRbdXInS2X6UsmPRjoDAfLu00O0T82NWP2lDOM3RfmHmPheUDe8idiOrJAk59AbtkXHLJmuapYacsunG01ax9rUS3WceKyhcc)WlOrlMNgbIj76bHtQnibsJL9elsXoeKatiZljWiG8OUx9IgAObYuEBxBzpbJskAAu6IQY3dcUMgq6AWqSydRDSURet6AItNwaZ7Dgq6AC(glPo2N0zaPFtoX80iyUMgq6AWqSydRDSURet6AItNwSNHOgSlFKjjP2lDgq63KJg63e(HNCnnG01GHyXgw7yDxjM01eNoT2yY1c9tDSpPtAwcl19DGILqzQ9shOkpBfBGG6N3yPRbE036b)qAEbnAX80iWvFewStOdsJL9elYvFewStOdE036b)qAEHRPbKUgmel2WAhR7kXKUM40Pfguhij1EPtSdbjWeY8scmcipQ7vVGumpncet21dcNuBqcKgl7jwUMgq6AWqSydRDSURet6AItNwR(OS59CnnG01GHyXgw7yDxjM01eNoTWG6ajCn5AAaPRbdLRhuqcw3gtUwOpwjkrPa]] )


end
