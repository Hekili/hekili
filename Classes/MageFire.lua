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
        rune_of_power = {
            id = 116014,
            duration = 10,
            max_stack = 1,
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
                return target.time_to_pct_90
            end
        end, state )
    } ) )


    spec:RegisterTotem( "rune_of_power", 609815 )


    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        incanters_flow.reset()
    end )

    spec:RegisterHook( "advance", function ( time )
        if Hekili.ActiveDebug then Hekili:Debug( "STREAK DATA:  Heating Up ( %.2f ), Hot Streak ( %.2f ).", state.buff.heating_up.remains, state.buff.hot_streak.remains ) end
    end )

    spec:RegisterStateFunction( "hot_streak", function( willCrit )
        willCrit = willCrit or buff.combustion.up or stat.crit >= 100

        if Hekili.ActiveDebug then Hekili:Debug( "HOT STREAK START:\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f\nCrit: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains, willCrit and "Yes" or "No", stat.crit ) end

        if willCrit then
            if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
            elseif buff.hot_streak.down then applyBuff( "heating_up" ) end
            
            if Hekili.ActiveDebug then Hekili:Debug( "HOT STREAK END:\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains ) end
            return true
        end
        
        -- Apparently it's safe to not crit within 0.2 seconds.
        if buff.heating_up.up and query_time - buff.heating_up.applied > 0.2 then removeBuff( "heating_up" ) end
        if Hekili.ActiveDebug then Hekili:Debug( "HOT STREAK END:\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains ) end
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
                hot_streak( talent.alexstraszas_fury.enabled )
                applyDebuff( "target", "dragons_breath" )
            end,

            impact = function ()
                hot_streak( talent.alexstraszas_fury.enabled )
            end,
        },


        fire_blast = {
            id = 108853,
            cast = 0,
            charges = function () return ( talent.flame_on.enabled and 3 or 2 ) end,
            cooldown = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) end,
            recharge = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) end,
            gcd = "off",
            castableWhileCasting = true,

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135807,

            nobuff = "fire_blasting", -- horrible.

            usable = function ()
                return time > 0
            end,

            handler = function ()
                hot_streak( true )

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                if azerite.blaster_master.enabled then addStack( "blaster_master", nil, 1 ) end

                applyBuff( "fire_blasting" ) -- Causes 1 second ICD on Fire Blast; addon only.
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
            usable = function ()
                if moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
                return true
            end,

            handler = function ()
                if talent.kindling.enabled and firestarter.active or stat.crit + buff.enhanced_pyrotechnics.stack * 10 >= 100 then
                    setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
                end
            end,

            impact = function ()
                if hot_streak( firestarter.active or stat.crit + buff.enhanced_pyrotechnics.stack * 10 >= 100 ) then
                    removeBuff( "enhanced_pyrotechnics" )
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
                if not hardcast then removeBuff( "hot_streak" ) end
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

            flightTime = 1,

            --[[ handler = function ()
                applyDebuff( "target", "meteor_burn" )
            end, ]]

            impact = function ()
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

            handler = function ()
                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
            end,

            impact = function ()
                hot_streak( true )
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

            usable = function ()
                if action.pyroblast.cast > 0 then
                    if moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
                    if not boss or not settings.pyroblast_pull and combat == 0 then return false, "opener pyroblast disabled and/or target is not a boss" end
                end
                return true
            end,

            handler = function ()
                if not hardcast then
                    removeBuff( "hot_streak" )
                    removeStack( "pyroclasm" )
                end
            end,

            velocity = 35,

            impact = function ()
                if hot_streak( firestarter.active ) then
                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                end
                applyDebuff( "target", "ignite" )
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

            readyTime = function ()
                if settings.reserve_runes > 0 and buff.combustion.down then
                    local cremains = cooldown.combustion.true_remains
                    local runes_by_then = min( 2, charges_fractional - 1 + ( cremains / action.rune_of_power.recharge ) )

                    return max( 0, action.rune_of_power.recharge * ( settings.reserve_runes - runes_by_then ) )
                end
            end,

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
                hot_streak( talent.searing_touch.enabled and target.health_pct < 30 or firestarter.active )
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
        -- canCastWhileCasting = true,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "potion_of_unbridled_fury",

        package = "Fire",
    } )


    spec:RegisterSetting( "prevent_hardcasts", false, {
        name = "Prevent |T135808:0|t Pyroblast and |T135812:0|t Fireball Hardcasts While Moving",
        desc = "If checked, the addon will not recommend |T135808:0|t Pyroblast or |T135812:0|t Fireball if they have a cast time and you are moving.\n\n" ..
            "Instant |T135808:0|t Pyroblasts will not be affected.",
        type = "toggle",
        width = 3
    } )

    spec:RegisterSetting( "pyroblast_pull", false, {
        name = "Allow |T135808:0|t Pyroblast Hardcast Pre-Pull",
        desc = "If checked, the addon will recommend an opener |T135808:0|t Pyroblast against bosses, if included in the current priority.",
        type = "toggle",
        width = 3,
    } )
    
    spec:RegisterSetting( "reserve_runes", 1, {
        name = "Reserve |T609815:0|t Rune of Power Charges for Combustion",
        desc = "While |T609815:0|t Rune of Power is not considered a Cooldown by default, saving charge(s) to line up with |T135824:0|t Combustion is generally a good idea.\n\n" ..
            "The addon will reserve this many charges to line up with |T135824:0|t Combustion, regardless of whether Cooldowns are toggled on/off.",
        type = "range",
        min = 0,
        max = 1.75,
        step = 0.01,
        width = 3
    } )


    spec:RegisterPack( "Fire", 20191111, [[dWKWEcqibPhrqjxIkvLSjeAuurDkQuwfbf6vsv1SOIClckv7cPFPsXWqqogbzzsv0ZiOQPrqrxtQcBJkvvFJkvrJJkvHZrLQ06OsvH5Psv3JkSpbvhuLkPAHsv6HeurtKGsjxKkvf1gjOsFKGsPAKeuWjvPssRuqmtckLYnvPsStvk9tvQKYqvPsILsLQI8ucnvPQCvckfFLkvLAVc9xIgmQomLfRKhJYKr0LH2Su(Skz0cCArRMGk8AeuZMQUTk2TIFlz4sLJRsLA5Q65atN01vQTJaFNkz8uPY5fuwVkvmFcSFqhfk2xuK0umEBpjKqUxHesiHOc1ZE2tcjmJIAyDyuSZye2UWO4yhmkkCZhJIDwy(YiJ9ffb1(zyumq1oG7JBU5k1G9IYQZnG8S9MM1WERP3aYd7MO4ANE9U6exrrstX4T9Kqc5EfsiHeIkup7zpjKWhfTTguFuumpBVPzncNV10OyqssItCffjralkkSGCHB(iKFxSlegIWcYduTd4(4MBUsnyVOS6CdipBVPznS3A6nG8WUbgIWcYVTiapl8HCHeYjiVNesi3lmeyiclix4mWMle4(agIWcYf2HCHnaeY18GsTKKjc5VPb4d5AGnqUA)fQunpOuljzIqEREi3BavyhGSAiHCBL(uddY3a7cb0OOpbki2xumv8aK(YLS7Z6tnSyFXBfk2xuehB5rYyVrrJPznrrnjrGw)rYks0Drr2Nk(Pffzv5jlxdLvN1gOzn0hpwoaipCiNa7tB5rAnYnaLSTwTgKlqaKRMhhL2YhbQ9k(uCSLhjHCIqElFeO2R4tF8y5aG8WHCcSpTLhP1i3auY2A1ArXXoyuutseO1FKSIeDxuJ32ZyFrrCSLhjJ9gfnMM1efzHX8L(1Km5YBankY(uXpTOiRkpz5AOS6S2anRH(4XYba5Hd5eyFAlpsRrUbOKT1Q1GCbcGC184O0w(iqTxXNIJT8ijKteYB5Ja1EfF6JhlhaKhoKtG9PT8iTg5gGs2wRwlkITgYu5yhmkYcJ5l9RjzYL3aAuJAuKvN1gOznYUadGX(I3kuSVOio2YJKXEJISpv8tlkU2TgLvN1gOznuYY1efnMM1ef95vGcKchBYRdoAuJ32ZyFrrJPznrXLVksz1KAakXbpHffXXwEKm2BuJ3k8X(IIgtZAIIh8uFyYQj9BwskjF0oGOio2YJKXEJA8wHzSVOio2YJKXEJIBakDfKEuYmGMZvuuOOi7tf)0IISa7VqaKhUdixiiNiK7mK7mKBmnRH2YhLlVbuklW(leiBVX0SgZd59d5od5RDRrz1zTbAwd9XJLdaYf2H81U1OlVbu8LhdO4tj3VPznqUBqU7liNvLNSCn0w(OC5nGsj3VPznqUWoK7mKV2TgLvN1gOzn0hpwoai3ni39fK7mKV2TgD5nGIV8yafFk5(nnRbYf2HCcr7bK7gK7gKhUdiNqqUabqEOqUDh8tfPlVbu8LhdO4tXXwEKeYfiaYdfYvZJJsBE7GYAO4ylpsc5cea5RDRrz1zTbAwd9XJLdaYV3bKV2TgD5nGIV8yafFk5(nnRbYfiaYx7wJU8gqXxEmGIp9XJLdaYVhYjeThqUabqoE37SRdjPbH1HVg8OrkD9jqD9whaYjc5SQ8KLRHgewh(AWJgP01Na11BDaPWticjKWSN0hpwoai)EiVhqUBqoriFTBnkRoRnqZAO7oiNiK7mKhkKBmnRHcy1ZcOO7q2wZ5cYjc5Hc5gtZAODH91YBaLMJS5ZRafYjc5RDRrdqtZ5sU7O7oixGai3yAwdfWQNfqr3HSTMZfKteYx7wJguQeOpAeMswUgiNiK7mKV2TgnannNl5UJswUgixGai3Ud(PI0L3ak(YJbu8P4ylpsc5Ub5cea52DWpvKU8gqXxEmGIpfhB5rsiNiKRMhhL282bL1qXXwEKeYjc5gtZAODH91YBaLMJS5ZRafYjc5RDRrdqtZ5sU7OKLRbYjc5RDRrdkvc0hnctjlxdK7wuCdqz1AYlgzuuOOOX0SMOylFuU8gqJA82Ee7lkIJT8izS3Oi7tf)0IIRDRrz1zTbAwdLSCnrrJPznrXFpOSAYUYf(rnER7p2xuehB5rYyVrXnaLUcspkzgqZ5kkkuu0yAwtuSLpkxEdOrr2Nk(PffT7GFQiD5nGIV8yafFko2YJKqorihbaCyi9GN6dtwnPFZssj5J2bqpMWr9qorixnpok9GkwpfhB5rsiNiKRMhhL282bL1qXXwEKeYjc5RDRrxEdO4lpgqXNswUgiNiK7mKRMhhL(7bLvt2vUWNIJT8ijKteYnMM1q)9GYQj7kx4tr3HSTMZfKteYnMM1q)9GYQj7kx4tr3HSTIYhpwoai)EiNqu3pKlqaK7mKZQYtwUgkRoRnqZAOpAKHb5cea5RDRrz1zTbAwdD3b5Ub5eH8qHC184O0FpOSAYUYf(uCSLhjHCIqEOqUX0SgAxyFT8gqP5iB(8kqHCIqEOqUX0SgAlFCzEpnhzZNxbkK7wuJ36Eg7lkIJT8izS3OOX0SMOiZ8EPX0SgPpbAu0Navo2bJIgttcqPAECuquJ36Ee7lkIJT8izS3O4gGsxbPhLmdO5CfffkkY(uXpTOOZqUZqUX0Sg6bvSEAoYMpVcuiNiKBmnRHEqfRNMJS5ZRav(4XYba537aYjeThqUBqUabqEOqUAECu6bvSEko2YJKqUBqori3ziFTBn6Vhuwnzx5cF6UdYfiaYdfYvZJJs)9GYQj7kx4tXXwEKeYDlkUbOSAn5fJmkkuu0yAwtuKvN1gOznrnER7n2xu0yAwtuSR0SMOio2YJKXEJA8wHiuSVOOX0SMO4YxfPST)WII4ylpsg7nQXBfsOyFrrJPznrXf(a8jCoxrrCSLhjJ9g14Tc1ZyFrrJPznrXw(4YxfzuehB5rYyVrnERqcFSVOOX0SMOOnmeOV5LmZ7JI4ylpsg7nQXBfsyg7lkIJT8izS3OOX0SMOiZ8EPX0SgPpbAu0Navo2bJI6NdHrfe14Tc1JyFrrCSLhjJ9gfzFQ4Nwu0zi3zixnpokT5Tdk7mLfqXXwEKeYjc5gttcqjo4jraKhoK3ti3nixGai3yAsakXbpjcG8WHC3pK7gKteYx7wJguQeOpAeM(OXuiNiKhkKB3b)ur6YBafF5Xak(uCSLhjJIgtZAIInVDqG(jHXOgVvi3FSVOio2YJKXEJISpv8tlkU2TgTlSVyEdCOpAmfYjc5RDRrz1zTbAwd9XJLdaYdhYzgqLAEWOOX0SMOyxyFT8gqJA8wHCpJ9ffXXwEKm2BuK9PIFArX1U1ObLkb6JgHPpAmnkAmnRjk2f2xlVb0OgVvi3JyFrrCSLhjJ9gf3au6ki9OKzanNROOqrr2Nk(Pffraahgsp4P(WKvt63SKus(ODa0JjCupKteYDgYzb2FHaz7nMM1yEipCixiQWd5cea5RDRrxEdO4lpgqXN(4XYba53d5eI2dixGaiFTBnkRoRnqZAOpESCaq(9q(A3A0L3ak(YJbu8PK730SgixGaipui3Ud(PI0L3ak(YJbu8P4ylpsc5Ub5eHCNHCNH81U1OS6S2anRHU7GCIqUZq(A3A0a00CUK7o6JgtHCIqEOqUX0SgAxyFT8gqP5iB(8kqHCIqEOqUX0SgkGvplGIUdzBnNli3nixGai3zi3yAwdfWQNfqr3HSTIYhpwoaiNiKV2TgnannNl5UJswUgiNiKV2TgnOujqF0imLSCnqoripui3yAwdTlSVwEdO0CKnFEfOqUBqUBqUBrXnaLvRjVyKrrHIIgtZAIIT8r5YBanQXBfY9g7lkIJT8izS3O4gGsxbPhLmdO5CfffkkY(uXpTOyOqoca4Wq6bp1hMSAs)MLKsYhTdGEmHJ6HCIqUZqEOqUDh8tfPlVbu8LhdO4tXXwEKeYfiaYdfYvZJJsBE7GYAO4ylpsc5Ub5eHCNHCNH81U1OS6S2anRHU7GCIqUZq(A3A0a00CUK7o6JgtHCIqEOqUX0SgAxyFT8gqP5iB(8kqHCIqEOqUX0SgkGvplGIUdzBnNli3nixGai3zi3yAwdfWQNfqr3HSTIYhpwoaiNiKV2TgnannNl5UJswUgiNiKV2TgnOujqF0imLSCnqoripui3yAwdTlSVwEdO0CKnFEfOqUBqUBqUBrXnaLvRjVyKrrHIIgtZAIIT8r5YBanQXB7jHI9ffXXwEKm2BuK9PIFArXUhjqEXiPcrbS6zbqoriFTBnAaAAoxYDhD3ffnMM1ef7c7RL3aAuJ32tHI9ffnMM1ef7ckCs3jBE7GGOio2YJKXEJA82E2ZyFrrCSLhjJ9gfzFQ4NwuCTBnkRoRnqZAOpESCaqE4qoZaQuZdc5eH81U1OS6S2anRHU7GCbcG81U1OS6S2anRHswUMOOX0SMOiGvpliQXB7PWh7lkIJT8izS3Oi7tf)0IIRDRrz1zTbAwd9XJLdaYVhYVyK0J5oiNiKBmnjaL4GNebqE4qUqrrJPznrrFsqoxYvDwrnEBpfMX(II4ylpsg7nkY(uXpTO4A3AuwDwBGM1qF8y5aG87H8lgj9yUdYjc5RDRrz1zTbAwdD3ffnMM1efjF7QgGC9OPbrnEBp7rSVOio2YJKXEJISpv8tlkQ2FHknanVgq7ykKFVdix4jeKteYvZJJsbO95Cj1AZcO4ylpsgfnMM1efbS6zbrnQrrJPjbOunpoki2x8wHI9ffXXwEKm2BuK9PIFArrJPjbOeh8KiaYdhYfcYjc5RDRrz1zTbAwdLSCnqori3ziNvLNSCnuwDwBGM1qF8y5aG8WHCwvEYY1q9jb5Cjx1zrj3VPznqUabqoRkpz5AOS6S2anRH(OrggK7wu0yAwtu0NeKZLCvNvuJ32ZyFrrCSLhjJ9gfzFQ4NwuCTBn6Vhuwnzx5cF6UdYjc5od5T8rGAVIp9XJLdaYdhYzv5jlxd9GkwpLC)MM1a5cea5Hc5T8rGAVIp1yAsac5Ub5cea5SQ8KLRH(7bLvt2vUWN(4XYba5Hd5AEqPwsYeHCIqUX0Sg6Vhuwnzx5cFklW(lea53d5cb5cea5od5SQ8KLRHEqfRNsUFtZAG87HCwvEYY1qz1zTbAwd9XJLdaYfiaYzv5jlxdLvN1gOzn0hnYWGC3GCIqEOqUAECu6Vhuwnzx5cFko2YJKqori3ziNvLNSCn0dQy9uY9BAwdKFpK3YhbQ9k(0hpwoaixGaipuixnpokTLpcu7v8P4ylpsc5cea5Hc5T8rGAVIp1yAsac5UffnMM1efpOI1h1OgftfpazqEfi7(S(udl2x8wHI9ffXXwEKm2BuK9PIFArrNHC184O0FpOSAYUYf(uCSLhjHCIqoRkpz5AOS6S2anRH(4XYba537aYnMM1q)9GYQj7kx4tzgqLAEqixGaiNvLNSCnuwDwBGM1qF0iddYDdYjc5Hc5T8rGAVIp1yAsac5cea5RDRrz1zTbAwdD3ffnMM1efzM3lnMM1i9jqJI(eOYXoyumv8aKS6S2anRjQXB7zSVOOX0SMO4gGYuXdikIJT8izS3OgVv4J9ffXXwEKm2Bu0yAwtu0UdiWEdiB1OYQj7kx4hfzFQ4NwuKvLNSCnuwDwBGM1qF8y5aG87Da59aY7hYfQhqUWiKtG9PT8iTvJkjR9YJYAKBagfh7Grr7oGa7nGSvJkRMSRCHFuJ3kmJ9ffXXwEKm2Bu0yAwtu8lL9BGIKscQISkjz59rr2Nk(Pffzv5jlxdLvN1gOzn0hpwoaipCiNa7tB5rAnYnaLSTwTwuCSdgf)sz)gOiPKGQiRsswEFuJ32JyFrrCSLhjJ9gfnMM1efT7ENDLIJkhBRPFdIISpv8tlkYQYtwUgkRoRnqZAOpESCaqE4qob2N2YJ0AKBakzBTATO4yhmkA39o7kfhvo2wt)ge14TU)yFrrCSLhjJ9gfnMM1efbbjb4ljaN6iF0NSOi7tf)0IISQ8KLRHYQZAd0Sg6JhlhaKhoKtG9PT8iTg5gGs2wRwlko2bJIGGKa8LeGtDKp6twuJ36Eg7lkIJT8izS3OOX0SMOyG9NAsMKepMIFA(8o4hfXwdzQCSdgfdS)utYKK4Xu8tZN3b)OgV19i2xuehB5rYyVrrJPznrXJ5B1Fqsza(MNei94LR36arr2Nk(Pffzv5jlxdLvN1gOzn0hpwoaipChqEp6bKteYx7wJYQZAd0Sgkz5AGCIqoRkpz5AOS6S2anRH(4XYba5Hd5eyFAlpsRrUbOKT1Q1IIJDWO4X8T6piPmaFZtcKE8Y1BDGOgV19g7lkIJT8izS3OOX0SMOOnSehvs4Puz1KUsazDIISpv8tlkYQYtwUgkRoRnqZAOpESCaqE4oG8E0diNiKV2TgLvN1gOznuYY1a5eHCwvEYY1qz1zTbAwd9XJLdaYdhYjW(0wEKwJCdqjBRvRffh7GrrByjoQKWtPYQjDLaY6e14TcrOyFrrCSLhjJ9gfnMM1ef3auMkEIISpv8tlkYQYtwUgkRoRnqZAOpESCaqE4oGCHzpGCIq(A3AuwDwBGM1qjlxdKteYzv5jlxdLvN1gOzn0hpwoaipCiNa7tB5rAnYnaLSTwTwuCSdgfhC)MxccBSoakXjWgg(rnQrrsSzBVg7lERqX(IIgtZAIISApk(Go07JI4ylpsg7nQXB7zSVOio2YJKXEJIgtZAIImZ7LgtZAK(eOrrFcu5yhmkMkEaYG8kq29z9PgwuJ3k8X(II4ylpsg7nkY(uXpTO4A3AuwDwBGM1qjlxtu0yAwtu8K)xVmp2fg14TcZyFrrCSLhjJ9gfzFQ4NwuKvLNSCnuwDwBGM1qF8y5aG87HCHieKlqaKR5bLAjjteYVhYzv5jlxdLvN1gOzn0hpwoGOOX0SMO412EY0gz1K2DWV0GOgVThX(IIgtZAIISAy4OVPiPS5TdgfXXwEKm2BuJ36(J9ffnMM1efBfBdqsPDh8tfLl0orrCSLhjJ9g14TUNX(IIgtZAIID7pBHLZLC5nGgfXXwEKm2BuJ36Ee7lkAmnRjk(zxNhL5ibDgdJI4ylpsg7nQXBDVX(IIgtZAIIAak3ZQ2dPSvpdJI4ylpsg7nQXBfIqX(IIgtZAIIUQ3tsaMJ8rqn2WWOio2YJKXEJA8wHek2xuehB5rYyVrr2Nk(PffvZJJsB5Ja1EfFko2YJKqoriVLpcu7v8PpESCaqE4qEB79Yhzb2FHsnpiKlqaKZQYtwUgkRoRnqZAOpESCaqE4qob2N2YJuwDwBGM1i)QtY2A1AqoriFTBnkRoRnqZAOKLRbYfiaYv7VqLQ5bLAjjteYVhYzv5jlxdLvN1gOzn0hpwoaiNiKV2TgLvN1gOznuYY1a5cea5eyFAlpsjtGT8OKvN1gOznrrJPznrXFpOSAYUYf(rnERq9m2xuehB5rYyVrr2Nk(PffdfYjW(0wEKsMaB5rjRoRnqZAGCIqUZqUAECu6Vhuwnzx5cFko2YJKqoriNvLNSCnuwDwBGM1qF8y5aG87Da5gtZAO)Eqz1KDLl8PmdOsnpiKlqaKZQYtwUgkRoRnqZAOpAKHb5Ub5eH8qH8w(iqTxXNAmnjaHCbcG81U1OS6S2anRHU7IIgtZAIImZ7LgtZAK(eOrrFcu5yhmkYQZAd0SgzxGbWOgVviHp2xuehB5rYyVrXnaLUcspkzgqZ5kkkuuK9PIFArrNHCeaWHH0dEQpmz1K(nljLKpAha9ych1d5cea5iaGddPh8uFyYQj9BwskjF0oa6jN6HCIqUDh8tfPlVbu8LhdO4tXXwEKeYDdYjc5Sa7VqaK7aYpM7KSa7VqaKteYdfYx7wJguQeOpAeM(OXuiNiKhkK7mKV2TgnannNl5UJ(OXuiNiK7mKV2TgLvN1gOzn0DhKteYDgYnMM1qB5JlZ7P5iB(8kqHCbcGCJPzn0UW(A5nGsZr285vGc5cea5gtZAOaw9Sak6oKT1CUGC3GCbcGC1(luPbO51aAhtH87Da5cpHGCIqUX0SgkGvplGIUdzBnNli3ni3niNiKhkK7mKhkKV2TgnannNl5UJ(OXuiNiKhkKV2TgnOujqF0im9rJPqoriFTBnkRoRnqZAOKLRbYjc5od5gtZAOT8XL590CKnFEfOqUabqUX0SgAxyFT8gqP5iB(8kqHC3GC3IIBakRwtEXiJIcffnMM1efB5JYL3aAuJ3kKWm2xuehB5rYyVrXnaLUcspkzgqZ5kkkuuK9PIFArXw(iqTxXNAmnjaHCIqolW(lea5H7aYfcYjc5od5Hc5eyFAlpsB5JYL3aQSRkFoxqUabq(A3A0FpOSAYUYf(0DhK7gKteYDgYdfYT7GFQiD5nGIV8yafFko2YJKqUabq(A3A0L3ak(YJbu8PpESCaq(9qoHO9aYDdYjc5od5Hc5gtZAOT8XL59u0DiBR5Cb5eH8qHCJPzn0UW(A5nGsZr285vGc5eH81U1ObOP5Cj3D0DhKlqaKBmnRH2YhxM3tr3HSTMZfKteYx7wJguQeOpAeMswUgixGai3yAwdTlSVwEdO0CKnFEfOqoriFTBnAaAAoxYDhLSCnqoriFTBnAqPsG(Orykz5AGC3IIBakRwtEXiJIcffnMM1efB5JYL3aAuJ3kupI9ffXXwEKm2BuK9PIFArX1U1O)Eqz1KDLl8P7oiNiKV2TgLvN1gOznuYY1efnMM1efzM3lnMM1i9jqJI(eOYXoyu8RozxGbWOgVvi3FSVOio2YJKXEJIvxueGAu0yAwtuKa7tB5XOibMFJrr184O0FpOSAYUYf(uCSLhjHCIqoRkpz5AO)Eqz1KDLl8PpESCaq(9qoRkpz5AOT8r5YBaL22EV8rwG9xOuZdc5eHCNHCwvEYY1qz1zTbAwd9XJLdaYdhYjW(0wEKYQZAd0Sg5xDs2wRwdYfiaYB5Ja1EfFQX0KaeYDdYjc5od5SQ8KLRH(7bLvt2vUWN(4XYba53d5AEqPwsYeHCbcGCJPzn0FpOSAYUYf(uwG9xiaYdhYjeK7gKlqaKZQYtwUgkRoRnqZAOpESCaq(9qUX0SgAlFuU8gqPTT3lFKfy)fk18GqE)qoRkpz5AOT8r5YBaLsUFtZAGCHri3Ud(PI0L3ak(YJbu8P4ylpsc5eH8qH8w(iqTxXNAmnjaHCIqoRkpz5AOS6S2anRH(4XYba53d5AEqPwsYeHCbcGC184O0w(iqTxXNIJT8ijKteYB5Ja1EfFQX0KaeYjc5T8rGAVIp9XJLdaYVhYzv5jlxdTLpkxEdO0227LpYcS)cLAEqiVFiNvLNSCn0w(OC5nGsj3VPznqUWiKB3b)ur6YBafF5Xak(uCSLhjJIeyVCSdgfB5JYL3aQSRkFoxrnERqUNX(II4ylpsg7nkwDrraQrrJPznrrcSpTLhJIey(ngfvZJJs)9GYQj7kx4tXXwEKeYjc5SQ8KLRH(7bLvt2vUWN(4XYba53d5SQ8KLRH2fu4KUt282bb0227LpYcS)cLAEqiNiKZQYtwUgkRoRnqZAOpESCaqE4qob2N2YJuwDwBGM1i)QtY2A1Aqori3ziNvLNSCn0FpOSAYUYf(0hpwoai)EixZdk1ssMiKlqaKBmnRH(7bLvt2vUWNYcS)cbqE4qoHGC3GCbcGCwvEYY1qz1zTbAwd9XJLdaYVhYnMM1q7ckCs3jBE7GaAB79Yhzb2FHsnpiKteYzv5jlxdLvN1gOzn0hpwoai)EixZdk1ssMyuKa7LJDWOyxqHt6ozxv(CUIA8wHCpI9ffXXwEKm2Bu0yAwtuKzEV0yAwJ0Nank6tGkh7GrrGAdP9KYVutZAIAuJIPIhGKvN1gOznX(I3kuSVOio2YJKXEJIJDWOyEnPM1ip2fcKTnaJIgtZAII51KAwJ8yxiq22amQXB7zSVOio2YJKXEJIgtZAIIbH1HVg8OrkD9jqD9whikY(uXpTO4A3AuwDwBGM1q3Dqori3yAwdTLpkxEdOuwG9xiaYDa5ecYjc5gtZAOT8r5YBaL(ilW(luQ5bH8WH8lgj9yUlko2bJIbH1HVg8OrkD9jqD9whiQXBf(yFrrCSLhjJ9gfh7Grr7o7h1Gcib5CHKYo)(yxyuCdqz1AYlgzuuOOOX0SMOODN9JAqbKGCUqszNFFSlmkY(uXpTO4A3AuwDwBGM1q3DqUabqUX0Sg6bvSEAoYMpVcuiNiKBmnRHEqfRNMJS5ZRav(4XYba537aYjeThrnERWm2xuehB5rYyVrrJPznrXlVrMMwpqUmYlmkUbOSAn5fJmkkuuK9PIFArX1U1OS6S2anRHU7GCbcGCJPzn0dQy90CKnFEfOqori3yAwd9GkwpnhzZNxbQ8XJLdaYV3bKtiApIIyRHmvo2bJIxEJmnTEGCzKxyuJ32JyFrrCSLhjJ9gfnMM1efV8gzAA9a5bjnVpRjkUbOSAn5fJmkkuuK9PIFArX1U1OS6S2anRHU7GCbcGCJPzn0dQy90CKnFEfOqori3yAwd9GkwpnhzZNxbQ8XJLdaYV3bKtiApIIyRHmvo2bJIxEJmnTEG8GKM3N1e14TU)yFrrCSLhjJ9gfh7GrXL5Xw(OC92WcIIBakRwtEXiJIcffnMM1efxMhB5JY1BdlikY(uXpTO4A3AuwDwBGM1q3DqUabqUX0Sg6bvSEAoYMpVcuiNiKBmnRHEqfRNMJS5ZRav(4XYba537aYjeThrnER7zSVOio2YJKXEJIJDWOiiOyeELk(azZMRO4gGYQ1KxmYOOqrrJPznrrqqXi8kv8bYMnxrr2Nk(Pffx7wJYQZAd0Sg6UdYfiaYnMM1qpOI1tZr285vGc5eHCJPzn0dQy90CKnFEfOYhpwoai)EhqoHO9iQXBDpI9ffXXwEKm2BuCSdgf17ydcKl7jmOlheef3auwTM8IrgffkkAmnRjkQ3Xgeix2tyqxoiikY(uXpTO4A3AuwDwBGM1q3DqUabqUX0Sg6bvSEAoYMpVcuiNiKBmnRHEqfRNMJS5ZRav(4XYba537aYjeThrnER7n2xuehB5rYyVrXXoyu0gwIJkj8uQSAsxjGSorXnaLvRjVyKrrHIIgtZAII2WsCujHNsLvt6kbK1jkY(uXpTO4A3AuwDwBGM1q3DqUabqUX0Sg6bvSEAoYMpVcuiNiKBmnRHEqfRNMJS5ZRav(4XYba537aYjeThrnERqek2xuehB5rYyVrXXoyuCW9BEjiSX6aOeNaBy4hf3auwTM8IrgffkkAmnRjkUbOmv8efzFQ4NwuCTBnkRoRnqZAO7oixGai3yAwd9GkwpnhzZNxbkKteYnMM1qpOI1tZr285vGkF8y5aG87Da5eI2JOgVviHI9ffXXwEKm2BuCSdgfpMVv)bjLb4BEsG0JxUERdef3auwTM8IrgffkkAmnRjkEmFR(dskdW38KaPhVC9whikY(uXpTO4A3AuwDwBGM1q3DqUabqUX0Sg6bvSEAoYMpVcuiNiKBmnRHEqfRNMJS5ZRav(4XYba537aYjeThrnQrXV6KDbgaJ9fVvOyFrrJPznrXFpOSAYUYf(rrCSLhjJ9g14T9m2xuehB5rYyVrr2Nk(PffDgYvZJJsBE7GYotzbuCSLhjHCIqUX0KauIdEsea5Hd5cb5cea5gttcqjo4jraKhoKlmHC3GCIq(A3A0GsLa9rJW0hnMgfnMM1efBE7Ga9tcJrnERWh7lkIJT8izS3Oi7tf)0IIRDRrdkvc0hnctF0yAu0yAwtuSlSVwEdOrnERWm2xuehB5rYyVrXnaLUcspkzgqZ5kkkuuK9PIFArXqHCNHC184O0M3oOSZuwafhB5rsiNiKBmnjaL4GNebqE4qEpHCbcGCJPjbOeh8KiaYdhY7bK7gKteYDgYdfYB5Ja1EfFQX0KaeYjc5SQ8KLRHYQZAd0Sg6JhlhaKhoKtii3niNiK7mKhkKV2TgnannNl5UJ(OXuiNiKhkKV2TgnOujqF0im9rJPqoripuiV7rcKvRjVyK0w(OC5nGc5eHCNHCJPzn0w(OC5nGszb2FHaipChqEpHCbcGCNHCJPzn0UGcN0DYM3oiGYcS)cbqE4oGCHGCIqUAECuAxqHt6ozZBheqXXwEKeYDdYfiaYDgYvZJJsnp6oG(g4ogq22FyuCSLhjHCIqoRkpz5AOKVDvdqUE00a6JgzyqUBqUabqUZqUAECukaTpNlPwBwafhB5rsiNiKR2FHknanVgq7ykKFVdix4jeK7gK7gK7wuCdqz1AYlgzuuOOOX0SMOylFuU8gqJA82Ee7lkIJT8izS3OOX0SMOiZ8EPX0SgPpbAu0Navo2bJIgttcqPAECuquJ36(J9ffXXwEKm2BuK9PIFArX1U1ODH9fZBGd9rJPqoriNzavQ5bH87H81U1ODH9fZBGd9XJLdaYjc5RDRr)9GYQj7kx4tF8y5aG8WHCMbuPMhmkAmnRjk2f2xlVb0OgV19m2xuehB5rYyVrXnaLUcspkzgqZ5kkkuuK9PIFArXqHCNHC184O0M3oOSZuwafhB5rsiNiKBmnjaL4GNebqE4qEpHCbcGCJPjbOeh8KiaYdhY7bK7gKteYDgYdfYB5Ja1EfFQX0KaeYjc5SQ8KLRHYQZAd0Sg6JhlhaKhoKtii3niNiK7mKV2TgnannNl5UJ(OXuiNiK7mKR2FHknanVgq7ykKhUdix4jeKlqaKhkKRMhhLcq7Z5sQ1MfqXXwEKeYDdYDlkUbOSAn5fJmkkuu0yAwtuSLpkxEdOrnER7rSVOio2YJKXEJIBakDfKEuYmGMZvuuOOi7tf)0IIHc5od5Q5XrPnVDqzNPSako2YJKqori3yAsakXbpjcG8WH8Ec5cea5gttcqjo4jraKhoK3di3niNiK7mKhkK3YhbQ9k(uJPjbiKteYzv5jlxdLvN1gOzn0hpwoaipCiNqqUBqorixnpokfG2NZLuRnlGIJT8ijKteYv7VqLgGMxdODmfYV3bKl8ecYjc5od5RDRrdqtZ5sU7OpAmfYjc5Hc5gtZAOaw9Sak6oKT1CUGCbcG8qH81U1ObOP5Cj3D0hnMc5eH8qH81U1ObLkb6JgHPpAmfYDlkUbOSAn5fJmkkuu0yAwtuSLpkxEdOrnER7n2xuehB5rYyVrr2Nk(Pff7EKa5fJKkefWQNfa5eH81U1ObOP5Cj3D0DhKteYvZJJsbO95Cj1AZcO4ylpsc5eHC1(luPbO51aAhtH87Da5cpHGCIqUZqEOqUAECuAZBhu2zklGIJT8ijKlqaKBmnjaL4GNebqUdixii3TOOX0SMOyxyFT8gqJA8wHiuSVOio2YJKXEJISpv8tlkgkK39ibYlgjviAxqHt6ozZBhea5eH81U1ObOP5Cj3D0hnMgfnMM1ef7ckCs3jBE7GGOgVviHI9ffXXwEKm2BuK9PIFArr1(luPbO51aAhtH87Da5cpHGCIqUAECukaTpNlPwBwafhB5rYOOX0SMOiGvpliQXBfQNX(II4ylpsg7nkY(uXpTOOX0KauIdEsea5Hd59mkAmnRjks(2vna56rtdIA8wHe(yFrrCSLhjJ9gf3au6ki9OKzanNROOqrr2Nk(PffDgYvZJJsBE7GYotzbuCSLhjHCIqUX0KauIdEsea5Hd59eYfiaYnMMeGsCWtIaipCiVhqUBqori3ziNvLNSCnuwDwBGM1qF8y5aG8WHCcb5eH8qH8w(iqTxXNAmnjaHC3GCIq(A3A0GsLa9rJWuYY1a5eHCNH8qHC7o4NksxEdO4lpgqXNIJT8ijKlqaKV2TgD5nGIV8yafF6JhlhaKFpKtiApGC3IIBakRwtEXiJIcffnMM1efB5JYL3aAuJ3kKWm2xuehB5rYyVrr2Nk(PffvZJJsBE7GYotzbuCSLhjHCIqUX0KauIdEsea5Hd59eYfiaYnMMeGsCWtIaipCiVhrrJPznrXM3oiq)KWyuJ3kupI9ffnMM1efB5JlZ7JI4ylpsg7nQrnkQFoegvqSV4Tcf7lkAmnRjkUbOmv8aII4ylpsg7nQXB7zSVOio2YJKXEJIJDWOyG9NAsMKepMIFA(8o4hfnMM1efdS)utYKK4Xu8tZN3b)Og1OiqTH0Es5xQPznX(I3kuSVOio2YJKXEJISpv8tlk6mK7mKRMhhL282bLDMYcO4ylpsc5eHCJPjbOeh8KiaYdhYfcYjc5Hc5T8rGAVIp1yAsac5Ub5cea5gttcqjo4jraKhoKlmHC3GCIq(A3A0GsLa9rJW0hnMgfnMM1efBE7Ga9tcJrnEBpJ9ffXXwEKm2BuK9PIFArX1U1ObLkb6JgHPpAmfYjc5RDRrdkvc0hnctF8y5aG87HCJPzn0w(4Y8Ek6oKTvuQ5bJIgtZAIIDH91YBanQXBf(yFrrCSLhjJ9gfzFQ4NwuCTBnAqPsG(Ory6JgtHCIqUZqE3JeiVyKuHOT8XL59qUabqElFeO2R4tnMMeGqUabqUX0SgAxyFT8gqP5iB(8kqHC3IIgtZAIIDH91YBanQXBfMX(II4ylpsg7nkY(uXpTOilW(lea5H7aYfEiNiKBmnjaL4GNebqE4qEpHCIqEOqob2N2YJ0UGcN0DYUQ85CffnMM1ef7ckCs3jBE7GGOgVThX(II4ylpsg7nkY(uXpTO4A3A0GsLa9rJW0hnMc5eHC1(luPbO51aAhtH87Da5cpHGCIqUAECukaTpNlPwBwafhB5rYOOX0SMOyxyFT8gqJA8w3FSVOio2YJKXEJISpv8tlkU2TgTlSVyEdCOpAmfYjc5mdOsnpiKFpKV2TgTlSVyEdCOpESCarrJPznrXUW(A5nGg14TUNX(II4ylpsg7nkUbO0vq6rjZaAoxrrHIISpv8tlk6mKZQYtwUgkRoRnqZAOpESCaqE4qoHGCIq(A3A0FpOSAYUYf(uYY1a5eH8qH8w(iqTxXNAmnjaHC3GCIqEOqUAECukHZH0NZffhB5rsiNiKhkKtG9PT8iTLpkxEdOYUQ85Cb5eHCNHCNHCNHCJPzn0w(4Y8Ek6oKT1CUGCbcGCJPzn0UW(A5nGsr3HSTMZfK7gKteYDgYx7wJgGMMZLC3rF0ykK7gK7gKlqaK7mKRMhhLcq7Z5sQ1MfqXXwEKeYjc5Q9xOsdqZRb0oMc537aYfEcb5eHCNH81U1ObOP5Cj3D0hnMc5eH8qHCJPznuaREwafDhY2AoxqUabqEOq(A3A0GsLa9rJW0hnMc5eH8qH81U1ObOP5Cj3D0hnMc5eHCJPznuaREwafDhY2Aoxqoripui3yAwdTlSVwEdO0CKnFEfOqoripui3yAwdTLpUmVNMJS5ZRafYDdYDdYDlkUbOSAn5fJmkkuu0yAwtuSLpkxEdOrnER7rSVOio2YJKXEJISpv8tlkQMhhLs4Ci95CrXXwEKeYjc5RDRrdqtZ5sU7OpAmfYjc5Hc5T8rGAVIp1yAsac5eHCNHCwvEYY1qz1zTbAwd9XJLdaYdhYBBVx(ilW(luQ5bH8(H8Ec59d5Q5XrPeohsFoxuCSLhjHCbcGCNH8qHC184O0FpOSAYUYf(uCSLhjHCbcGCwvEYY1q)9GYQj7kx4tF8y5aG8WHCnpOuljzIqori3yAwd93dkRMSRCHpLfy)fcG87HCHGC3GCIqoRkpz5AOS6S2anRH(4XYba5Hd5AEqPwsYeHC3IIgtZAIIT8r5YBanQXBDVX(II4ylpsg7nkY(uXpTOy3JeiVyKuHOaw9SaiNiKV2TgnannNl5UJU7GCIqUAECukaTpNlPwBwafhB5rsiNiKR2FHknanVgq7ykKFVdix4jeKteYDgYDgYvZJJsBE7GYotzbuCSLhjHCIqUX0KauIdEsea5oGCHGCIqEOqElFeO2R4tnMMeGqUBqUabqUZqUX0KauIdEsea53d5ctiNiKhkKRMhhL282bLDMYcO4ylpsc5Ub5UffnMM1ef7c7RL3aAuJ3keHI9ffXXwEKm2BuK9PIFArrNH81U1ObOP5Cj3D0hnMc5cea5od5Hc5RDRrdkvc0hnctF0ykKteYDgYnMM1qB5JYL3akLfy)fcG8WHCcb5cea5Q5XrPa0(CUKATzbuCSLhjHCIqUA)fQ0a08AaTJPq(9oGCHNqqUBqUBqUBqoripuiNa7tB5rAxqHt6ozxv(CUIIgtZAIIDbfoP7KnVDqquJ3kKqX(II4ylpsg7nkAmnRjkYmVxAmnRr6tGgf9jqLJDWOOX0KauQMhhfe14Tc1ZyFrrCSLhjJ9gfzFQ4Nwu0yAsakXbpjcG8WHCHIIgtZAIIKVDvdqUE00GOgVviHp2xuehB5rYyVrrJPznrrM59sJPznsFc0OOpbQCSdgftfpaPVCj7(S(udlQXBfsyg7lkIJT8izS3Oi7tf)0IIQ9xOsdqZRb0oMc537aYfEcb5eHC184OuaAFoxsT2Sako2YJKrrJPznrraREwquJ3kupI9ffXXwEKm2BuCdqPRG0JsMb0CUIIcffzFQ4Nwu0zixnpokT5Tdk7mLfqXXwEKeYjc5gttcqjo4jraKhoK3tixGai3yAsakXbpjcG8WHC3lK7gKteYDgYzv5jlxdLvN1gOzn0hpwoaipCiNqqoripuiVLpcu7v8Pgttcqi3niNiKV2TgnOujqF0imLSCnqori3zipui3Ud(PI0L3ak(YJbu8P4ylpsc5cea5RDRrxEdO4lpgqXN(4XYba53d5eI2di3TO4gGYQ1KxmYOOqrrJPznrXw(OC5nGg14Tc5(J9ffXXwEKm2BuK9PIFArr184O0M3oOSZuwafhB5rsiNiKBmnjaL4GNebqE4qEpHCbcGCJPjbOeh8KiaYdhYDVrrJPznrXM3oiq)KWyuJ3kK7zSVOOX0SMOylFCzEFuehB5rYyVrnERqUhX(IIgtZAIIaw9SGOio2YJKXEJAuJIDpYQZY0yFXBfk2xu0yAwtu0EMnOmhf9EKPrrCSLhjJ9g14T9m2xuehB5rYyVrXQlkcqnkAmnRjksG9PT8yuKaZVXOO7NqrrcSxo2bJIS6S2anRr(vNKT1Q1IA8wHp2xuehB5rYyVrXQlkcqnkAmnRjksG9PT8yuKaZVXOiE37SRdjPxEJmnTEGCzKxiKlqaKJ39o76qs6L3ittRhipiP59znqUabqoE37SRdjP51KAwJ8yxiq22aeYfiaYX7ENDDijvVJniqUSNWGUCqaKlqaKJ39o76qsQDN9JAqbKGCUqszNFFSleYfiaYX7ENDDij1gwIJkj8uQSAsxjGSoqUabqoE37SRdjPGGIr4vQ4dKnBUGCbcGC8U3zxhsshC)MxccBSoakXjWgg(qUabqoE37SRdjPlZJT8r56THfefjWE5yhmkYQZAd0SgznYnaJA8wHzSVOio2YJKXEJIvxueGAu0yAwtuKa7tB5XOibMFJrr8U3zxhssT7acS3aYwnQSAYUYf(qoriNa7tB5rkRoRnqZAK1i3amksG9YXoyuSvJkjR9YJYAKBag14T9i2xuehB5rYyVrXQlkcqnkAmnRjksG9PT8yuKaZVXOypjeKlmc5eyFAlpsz1zTbAwJSg5gGqoripuiNa7tB5rARgvsw7LhL1i3aeY7hYfMecYfgHCcSpTLhPTAujzTxEuwJCdqiVFiVN9aYfgHC8U3zxhssT7acS3aYwnQSAYUYf(qoripuiNa7tB5rARgvsw7LhL1i3amksG9YXoyuSg5gGs2wRwlQXBD)X(II4ylpsg7nQXBDpJ9ffXXwEKm2BuCSdgfT7acS3aYwnQSAYUYf(rrJPznrr7oGa7nGSvJkRMSRCHFuJ36Ee7lkAmnRjkEY)RxMh7cJI4ylpsg7nQXBDVX(IIgtZAIIDLM1efXXwEKm2BuJ3keHI9ffnMM1ef7c7RL3aAuehB5rYyVrnQrnksa(GSM4T9Kqc5EjK7TNekk6Y(jNlqu8U6PREfjHCHieKBmnRbY9jqbuyirXUVAPhJIclix4Mpc53f7cHHiSG8av7aUpU5MRud2lkRo3aYZ2BAwd7TMEdipSBGHiSG8BlcWZcFixiHCcY7jHeY9cdbgIWcYfodS5cbUpGHiSGCHDixydaHCnpOuljzIq(BAa(qUgydKR2FHkvZdk1ssMiK3QhY9gqf2biRgsi3wPp1WG8nWUqafgcmeHfK7(S7q2wrsiFHT6riNvNLPq(cVYbqH876mg2PaiFQrypW(tB7HCJPznaiVgFyuyicli3yAwdG29iRoltD08gGWWqewqUX0SgaT7rwDwM2VJBAvrcdryb5gtZAa0Uhz1zzA)oUX2xhCutZAGHymnRbq7EKvNLP974g7z2GYCu07rMcdryb59fKaiNa7tB5rihGkaY1aeY18GqUPqURGKfa5UpTheYRgKFxPCHpKdcQTNeYbQ9kKVWCUGCGrasc5T6HCnaH8bDNc5cN1zTbAwdK3fyaegIX0SgaT7rwDwM2VJBiW(0wE0PXoOdwDwBGM1i)QtY2A1AovDoaO6ebMFJoC)ecgIX0SgaT7rwDwM2VJBiW(0wE0PXoOdwDwBGM1iRrUbOtvNdaQorG53Od8U3zxhssV8gzAA9a5YiVqbcW7ENDDij9YBKPP1dKhK08(SgbcW7ENDDijnVMuZAKh7cbY2gGceG39o76qsQEhBqGCzpHbD5GabcW7ENDDij1UZ(rnOasqoxiPSZVp2fkqaE37SRdjP2WsCujHNsLvt6kbK1rGa8U3zxhssbbfJWRuXhiB2CjqaE37SRdjPdUFZlbHnwhaL4eyddFbcW7ENDDijDzESLpkxVnSayigtZAa0Uhz1zzA)oUHa7tB5rNg7GoA1OsYAV8OSg5gGovDoaO6ebMFJoW7ENDDij1UdiWEdiB1OYQj7kx4tKa7tB5rkRoRnqZAK1i3aegIWcYVRQ4ba5AGPqU9iKVbijKxBfKKiKxnix4SoRnqZAGC7riFkfY3aKeYTMIpKRbjaY18GqE2GCnaddYDvBpjK3Tvi3GC9ZHWOc5Basc5UsnaYfoRZAd0SgiVgi3GCqG9KijKZQYtwUgkmeJPznaA3JS6SmTFh3qG9PT8OtJDqh1i3auY2A1AovDoaO6ebMFJo6jHegjW(0wEKYQZAd0SgznYnajgkb2N2YJ0wnQKS2lpkRrUby)ctcjmsG9PT8iTvJkjR9YJYAKBa2Fp7HWiE37SRdjP2Dab2BazRgvwnzx5cFIHsG9PT8iTvJkjR9YJYAKBacdXyAwdG29iRolt73XnGX6abLkbQPayigtZAa0Uhz1zzA)oUzdqzQ4XPXoOd7oGa7nGSvJkRMSRCHpmeJPznaA3JS6SmTFh3CY)RxMh7cHHymnRbq7EKvNLP974MUsZAGHymnRbq7EKvNLP974MUW(A5nGcdbgIWcYDF2DiBRijKJeGFyqUMheY1aeYnMwpKNai3iWsVT8ifgIX0SgGdwThfFqh69WqmMM1a63XnmZ7LgtZAK(eOon2bDKkEaYG8kq29z9PggmeJPznG(DCZj)VEzESl0PS5yTBnkRoRnqZAOKLRbgIX0Sgq)oU5ABpzAJSAs7o4xAGtzZbRkpz5AOS6S2anRH(4XYbCVqesGanpOuljzI3ZQYtwUgkRoRnqZAOpESCaWqmMM1a63XnSAy4OVPiPS5TdcdXyAwdOFh30k2gGKs7o4NkkxODGHymnRb0VJB62F2clNl5YBafgIX0Sgq)oU5ZUopkZrc6mgcdXyAwdOFh3ObOCpRApKYw9megIX0Sgq)oUXv9EscWCKpcQXggcdXyAwdOFh387bLvt2vUW3PS5qnpokTLpcu7v8P4ylpssSLpcu7v8PpESCaH32EV8rwG9xOuZdkqaRkpz5AOS6S2anRH(4XYbeob2N2YJuwDwBGM1i)QtY2A1Aex7wJYQZAd0Sgkz5AeiqT)cvQMhuQLKmX7zv5jlxdLvN1gOzn0hpwoaIRDRrz1zTbAwdLSCnceqG9PT8iLmb2YJswDwBGM1adXyAwdOFh3WmVxAmnRr6tG60yh0bRoRnqZAKDbgaDkBocLa7tB5rkzcSLhLS6S2anRHOZQ5XrP)Eqz1KDLl8P4ylpssKvLNSCnuwDwBGM1qF8y5aU3HX0Sg6Vhuwnzx5cFkZaQuZdkqaRkpz5AOS6S2anRH(OrgMBedTLpcu7v8Pgttcqbcw7wJYQZAd0Sg6UdgIX0Sgq)oUPLpkxEdOoTbO0vq6rjZaAoxoeYPnaLvRjVyKoeYPS5WzeaWHH0dEQpmz1K(nljLKpAha9ych1lqaca4Wq6bp1hMSAs)MLKsYhTdGEYPEI2DWpvKU8gqXxEmGIpfhB5rs3iYcS)cbooM7KSa7VqaXqx7wJguQeOpAeM(OXuIH68A3A0a00CUK7o6Jgtj68A3AuwDwBGM1q3DeD2yAwdTLpUmVNMJS5ZRavGaJPzn0UW(A5nGsZr285vGkqGX0SgkGvplGIUdzBnNl3eiqT)cvAaAEnG2X07Di8eIOX0SgkGvplGIUdzBnNl3CJyOoh6A3A0a00CUK7o6Jgtjg6A3A0GsLa9rJW0hnMsCTBnkRoRnqZAOKLRHOZgtZAOT8XL590CKnFEfOceymnRH2f2xlVbuAoYMpVcu3CdgIWcYf2A)5Cb5c38rGAVIVtqUWnFeY71Bafa52Jq(gGKqoipP3EFyqUwqo5(Z5cYfoRZAd0SgkKlSDCW38(WCcY1ammi3EeY3aKeY1cYVWbFtrixyOuixuF0imaYDfGdKZ(ubqUR07H8PuiFHqUldOijKBdjK7k1aiVxVbu8H87Ibu8DcY1ammiheuBpjKVqih09Orc51wHCTG8JLJA5a5Aac596nGIpKFxmGIpKV2TgfgIX0Sgq)oUPLpkxEdOoTbO0vq6rjZaAoxoeYPnaLvRjVyKoeYPS5OLpcu7v8PgttcqISa7Vqq4oeIOZHsG9PT8iTLpkxEdOYUQ85CjqWA3A0FpOSAYUYf(0DNBeDou7o4NksxEdO4lpgqXNIJT8iPabRDRrxEdO4lpgqXN(4XYbCpHO9WnIohQX0SgAlFCzEpfDhY2Aoxed1yAwdTlSVwEdO0CKnFEfOex7wJgGMMZLC3r3DceymnRH2YhxM3tr3HSTMZfX1U1ObLkb6JgHPKLRrGaJPzn0UW(A5nGsZr285vGsCTBnAaAAoxYDhLSCnex7wJguQeOpAeMswUg3GHymnRb0VJByM3lnMM1i9jqDASd64RozxGbqNYMJ1U1O)Eqz1KDLl8P7oIRDRrz1zTbAwdLSCnWqmMM1a63XneyFAlp60yh0rlFuU8gqLDv5Z5Yjcm)gDOMhhL(7bLvt2vUWNIJT8ijrwvEYY1q)9GYQj7kx4tF8y5aUNvLNSCn0w(OC5nGsBBVx(ilW(luQ5bj6mRkpz5AOS6S2anRH(4XYbeob2N2YJuwDwBGM1i)QtY2A1Ace0YhbQ9k(uJPjbOBeDMvLNSCn0FpOSAYUYf(0hpwoG718GsTKKjkqGX0Sg6Vhuwnzx5cFklW(leeoHCtGawvEYY1qz1zTbAwd9XJLd4EJPzn0w(OC5nGsBBVx(ilW(luQ5b7NvLNSCn0w(OC5nGsj3VPzncJ2DWpvKU8gqXxEmGIpfhB5rsIH2YhbQ9k(uJPjbirwvEYY1qz1zTbAwd9XJLd4EnpOuljzIceOMhhL2YhbQ9k(uCSLhjj2YhbQ9k(uJPjbiXw(iqTxXN(4XYbCpRkpz5AOT8r5YBaL22EV8rwG9xOuZd2pRkpz5AOT8r5YBaLsUFtZAegT7GFQiD5nGIV8yafFko2YJKWqmMM1a63XneyFAlp60yh0rxqHt6ozxv(CUCIaZVrhQ5XrP)Eqz1KDLl8P4ylpssKvLNSCn0FpOSAYUYf(0hpwoG7zv5jlxdTlOWjDNS5TdcOTT3lFKfy)fk18Gezv5jlxdLvN1gOzn0hpwoGWjW(0wEKYQZAd0Sg5xDs2wRwJOZSQ8KLRH(7bLvt2vUWN(4XYbCVMhuQLKmrbcmMM1q)9GYQj7kx4tzb2FHGWjKBceWQYtwUgkRoRnqZAOpESCa3BmnRH2fu4KUt282bb0227LpYcS)cLAEqISQ8KLRHYQZAd0Sg6JhlhW9AEqPwsYeHHymnRb0VJByM3lnMM1i9jqDASd6aO2qApP8l10SgyiWqmMM1aOgttcqPAECuGdFsqoxYvDwoLnhgttcqjo4jrq4crCTBnkRoRnqZAOKLRHOZSQ8KLRHYQZAd0Sg6Jhlhq4SQ8KLRH6tcY5sUQZIsUFtZAeiGvLNSCnuwDwBGM1qF0idZnyigtZAauJPjbOunpokOFh3CqfR3PS5yTBn6Vhuwnzx5cF6UJOZT8rGAVIp9XJLdiCwvEYY1qpOI1tj3VPznceeAlFeO2R4tnMMeGUjqaRkpz5AO)Eqz1KDLl8PpESCaHR5bLAjjtKOX0Sg6Vhuwnzx5cFklW(leCVqce4mRkpz5AOhuX6PK730SM7zv5jlxdLvN1gOzn0hpwoabcyv5jlxdLvN1gOzn0hnYWCJyOQ5XrP)Eqz1KDLl8P4ylpss0zwvEYY1qpOI1tj3VPzn33YhbQ9k(0hpwoabccvnpokTLpcu7v8P4ylpskqqOT8rGAVIp1yAsa6gmeyiclix4SoRnqZAG8UadGqE3JD2Jai3wPp1ebqURudGCdYjrVfMtqUgGdK7T9WcqaKNJwqUgGqUWzDwBGM1a5a8U34WqyigtZAauwDwBGM1i7cma6WNxbkqkCSjVo4OoLnhRDRrz1zTbAwdLSCnWqmMM1aOS6S2anRr2fyaSFh3S8vrkRMudqjo4jmyigtZAauwDwBGM1i7cma2VJBo4P(WKvt63SKus(ODaWqewqUWw7pNlix4SoRnqZACcYfU5JqEVEdOai3EeY3aKeY1cYVWbFtrixyOuixuF0imaYTHeYp5KN8oiKRbiKBNApkKxnixZdc5GoCuihDhY2AoxqEPb4d5Go07buix4wpKduBiTNeYfU5Job5c38riVxVbuaKBpc514ddY3aKeYDfGdKlmGMMZfKlSPdYtaKBmnjaH86HCxb4a5gKlYQNfa5mdOqEcG8CG8UVUEeaGCBiHCHb00CUGCHnDqUnKqUWqPqUO(Oryi3EeYNsHCJPjbifYDFNAaK3R3ak(q(DXak(qUnKqUW1BheYVRnob5c38riVxVbuaKZSbYnsYuZAmVpmiFHq(gGKqURG0JqUWqPqUO(Oryi3gsixyannNlixythKBpc5tPqUX0KaeYTHeYni)UsyFT8gqH8ea55a5Aac5w(qUnKqU5bfK7ki9iKZmGMZfKlYQNfa5ib4a5zdYfgqtZ5cYf20b5jaYn)JgzyqUX0KaKc59fGqU3ufFi38(YfaYvxfKlmukKlQpAegYVRe2xlVbuaKRfKVqiNzafYZbYbBgdbGSgi3Ak(qUgGqUiREwafYVRtsMAwJ59Hb5UsnaY71BafFi)UyafFi3gsix46Tdc531gNGCHB(iK3R3akaYbb12tc5tPq(cH8najH894raaY71BafFi)UyafFipbqUTQTc5Ab5O76YhH86HCnaFeYThH8t9iKRb2a54u7Raix4Mpc596nGcGCTGC0DkoKqEVEdO4d53fdO4d5Ab5Aac54qc5vdYfoRZAd0SgkmeJPznakRoRnqZAKDbga73XnT8r5YBa1PnaLUcspkzgqZ5YHqoTbOSAn5fJ0HqoLnhSa7Vqq4oeIOZoBmnRH2YhLlVbuklW(leiBVX0SgZ3VZRDRrz1zTbAwd9XJLdqyFTBn6YBafF5Xak(uY9BAwJBUVyv5jlxdTLpkxEdOuY9BAwJWUZRDRrz1zTbAwd9XJLdWn3xoV2TgD5nGIV8yafFk5(nnRryNq0E4MBH7GqceeQDh8tfPlVbu8LhdO4tXXwEKuGGqvZJJsBE7GYAO4ylpskqWA3AuwDwBGM1qF8y5aU3XA3A0L3ak(YJbu8PK730Sgbcw7wJU8gqXxEmGIp9XJLd4Ecr7Hab4DVZUoKKgewh(AWJgP01Na11BDaISQ8KLRHgewh(AWJgP01Na11BDaPWticjKWSN0hpwoG77HBex7wJYQZAd0Sg6UJOZHAmnRHcy1ZcOO7q2wZ5IyOgtZAODH91YBaLMJS5ZRaL4A3A0a00CUK7o6UtGaJPznuaREwafDhY2Aoxex7wJguQeOpAeMswUgIoV2TgnannNl5UJswUgbcS7GFQiD5nGIV8yafFko2YJKUjqGDh8tfPlVbu8LhdO4tXXwEKKOAECuAZBhuwdfhB5rsIgtZAODH91YBaLMJS5ZRaL4A3A0a00CUK7okz5AiU2TgnOujqF0imLSCnUbdXyAwdGYQZAd0SgzxGbW(DCZVhuwnzx5cFNYMJ1U1OS6S2anRHswUgyicli)UoKlCZhH8E9gqHCqqT9Kq(cH8najHCTGCRRZhgK3R3ak(q(DXak(qURG0JqoZaAoxqU7t7bH8Qb53vkx4d5UcWbY3GCUG8E9gqXhYVlgqX3ji)UGN6ddYRgKlSTnljHCHTE0oai)Uych17eKlC92bH87AJtqUnKq(DbvSEkmeJPznakRoRnqZAKDbga73XnT8r5YBa1PnaLUcspkzgqZ5YHqoLnh2DWpvKU8gqXxEmGIpfhB5rsIiaGddPh8uFyYQj9BwskjF0oa6XeoQNOAECu6bvSEko2YJKevZJJsBE7GYAO4ylpssCTBn6YBafF5Xak(uYY1q0z184O0FpOSAYUYf(uCSLhjjAmnRH(7bLvt2vUWNIUdzBnNlIgtZAO)Eqz1KDLl8PO7q2wr5JhlhW9eI6(fiWzwvEYY1qz1zTbAwd9rJmmbcw7wJYQZAd0Sg6UZnIHQMhhL(7bLvt2vUWNIJT8ijXqnMM1q7c7RL3aknhzZNxbkXqnMM1qB5JlZ7P5iB(8kqDdgIX0SgaLvN1gOznYUadG974gM59sJPznsFcuNg7GomMMeGs184OayigtZAauwDwBGM1i7cma2VJBy1zTbAwJtBakRwtEXiDiKtBakDfKEuYmGMZLdHCkBoC2zJPzn0dQy90CKnFEfOenMM1qpOI1tZr285vGkF8y5aU3bHO9Wnbccvnpok9GkwpfhB5rs3i68A3A0FpOSAYUYf(0DNabHQMhhL(7bLvt2vUWNIJT8iPBWqmMM1aOS6S2anRr2fyaSFh30vAwdmeJPznakRoRnqZAKDbga73XnlFvKY2(ddgIX0SgaLvN1gOznYUadG974Mf(a8jCoxWqmMM1aOS6S2anRr2fyaSFh30Yhx(QiHHymnRbqz1zTbAwJSlWay)oUXggc038sM59WqmMM1aOS6S2anRr2fyaSFh3WmVxAmnRr6tG60yh0H(5qyubWqmMM1aOS6S2anRr2fyaSFh3082bb6NegDkBoC2z184O0M3oOSZuwafhB5rsIgttcqjo4jrq490nbcmMMeGsCWtIGWD)UrCTBnAqPsG(Ory6JgtjgQDh8tfPlVbu8LhdO4tXXwEKegIX0SgaLvN1gOznYUadG974MUW(A5nG6u2CS2TgTlSVyEdCOpAmL4A3AuwDwBGM1qF8y5acNzavQ5bHHymnRbqz1zTbAwJSlWay)oUPlSVwEdOoLnhRDRrdkvc0hnctF0ykmeJPznakRoRnqZAKDbga73XnT8r5YBa1PnaLvRjVyKoeYPnaLUcspkzgqZ5YHqoLnhiaGddPh8uFyYQj9BwskjF0oa6XeoQNOZSa7VqGS9gtZAmF4crfEbcw7wJU8gqXxEmGIp9XJLd4Ecr7HabRDRrz1zTbAwd9XJLd4(1U1OlVbu8LhdO4tj3VPznceeQDh8tfPlVbu8LhdO4tXXwEK0nIo78A3AuwDwBGM1q3DeDETBnAaAAoxYDh9rJPed1yAwdTlSVwEdO0CKnFEfOed1yAwdfWQNfqr3HSTMZLBce4SX0SgkGvplGIUdzBfLpESCaex7wJgGMMZLC3rjlxdX1U1ObLkb6JgHPKLRHyOgtZAODH91YBaLMJS5ZRa1n3CdgIX0SgaLvN1gOznYUadG974Mw(OC5nG60gGYQ1Kxmshc50gGsxbPhLmdO5C5qiNYMJqraahgsp4P(WKvt63SKus(ODa0JjCuprNd1Ud(PI0L3ak(YJbu8P4ylpskqqOQ5XrPnVDqznuCSLhjDJOZoV2TgLvN1gOzn0DhrNx7wJgGMMZLC3rF0ykXqnMM1q7c7RL3aknhzZNxbkXqnMM1qbS6zbu0DiBR5C5MaboBmnRHcy1ZcOO7q2wr5JhlhaX1U1ObOP5Cj3DuYY1qCTBnAqPsG(Orykz5AigQX0SgAxyFT8gqP5iB(8kqDZn3GHymnRbqz1zTbAwJSlWay)oUPlSVwEdOoLnhDpsG8IrsfIcy1ZciU2TgnannNl5UJU7GHymnRbqz1zTbAwJSlWay)oUPlOWjDNS5TdcGHymnRbqz1zTbAwJSlWay)oUbWQNf4u2CS2TgLvN1gOzn0hpwoGWzgqLAEqIRDRrz1zTbAwdD3jqWA3AuwDwBGM1qjlxdmeJPznakRoRnqZAKDbga73Xn(KGCUKR6SCkBow7wJYQZAd0Sg6JhlhW9xms6XChrJPjbOeh8KiiCHGHymnRbqz1zTbAwJSlWay)oUH8TRAaY1JMg4u2CS2TgLvN1gOzn0hpwoG7VyK0J5oIRDRrz1zTbAwdD3bdXyAwdGYQZAd0SgzxGbW(DCdGvplWPS5qT)cvAaAEnG2X07Di8eIOAECukaTpNlPwBwafhB5rsyiWqmMM1aOPIhGKvN1gOzno2auMkECASd6iVMuZAKh7cbY2gGWqmMM1aOPIhGKvN1gOzn974MnaLPIhNg7GoccRdFn4rJu66tG66ToGtzZXA3AuwDwBGM1q3DenMM1qB5JYL3akLfy)fcCqiIgtZAOT8r5YBaL(ilW(luQ5bd)IrspM7GHymnRbqtfpajRoRnqZA63XnBaktfpoTbOSAn5fJ0Hqon2bDy3z)OguajiNlKu253h7cDkBow7wJYQZAd0Sg6UtGaJPzn0dQy90CKnFEfOenMM1qpOI1tZr285vGkF8y5aU3bHO9agIX0Sganv8aKS6S2anRPFh3SbOmv840gGYQ1Kxmshc5e2AitLJDqhxEJmnTEGCzKxOtzZXA3AuwDwBGM1q3DceymnRHEqfRNMJS5ZRaLOX0Sg6bvSEAoYMpVcu5JhlhW9oieThWqmMM1aOPIhGKvN1gOzn974MnaLPIhN2auwTM8Ir6qiNWwdzQCSd64YBKPP1dKhK08(SgNYMJ1U1OS6S2anRHU7eiWyAwd9GkwpnhzZNxbkrJPzn0dQy90CKnFEfOYhpwoG7DqiApGHymnRbqtfpajRoRnqZA63XnBaktfpoTbOSAn5fJ0Hqon2bDSmp2YhLR3gwGtzZXA3AuwDwBGM1q3DceymnRHEqfRNMJS5ZRaLOX0Sg6bvSEAoYMpVcu5JhlhW9oieThWqmMM1aOPIhGKvN1gOzn974MnaLPIhN2auwTM8Ir6qiNg7GoabfJWRuXhiB2C5u2CS2TgLvN1gOzn0DNabgtZAOhuX6P5iB(8kqjAmnRHEqfRNMJS5ZRav(4XYbCVdcr7bmeJPznaAQ4biz1zTbAwt)oUzdqzQ4XPnaLvRjVyKoeYPXoOd9o2Ga5YEcd6YbboLnhRDRrz1zTbAwdD3jqGX0Sg6bvSEAoYMpVcuIgtZAOhuX6P5iB(8kqLpESCa37Gq0EadXyAwdGMkEaswDwBGM10VJB2auMkECAdqz1AYlgPdHCASd6WgwIJkj8uQSAsxjGSooLnhRDRrz1zTbAwdD3jqGX0Sg6bvSEAoYMpVcuIgtZAOhuX6P5iB(8kqLpESCa37Gq0EadXyAwdGMkEaswDwBGM10VJB2auMkECAdqz1AYlgPdHCASd6yW9BEjiSX6aOeNaBy47u2CS2TgLvN1gOzn0DNabgtZAOhuX6P5iB(8kqjAmnRHEqfRNMJS5ZRav(4XYbCVdcr7bmeJPznaAQ4biz1zTbAwt)oUzdqzQ4XPnaLvRjVyKoeYPXoOJJ5B1Fqsza(MNei94LR36aoLnhRDRrz1zTbAwdD3jqGX0Sg6bvSEAoYMpVcuIgtZAOhuX6P5iB(8kqLpESCa37Gq0EadbgIX0Sganv8aKb5vGS7Z6tnmhmZ7LgtZAK(eOon2bDKkEaswDwBGM14u2C4SAECu6Vhuwnzx5cFko2YJKezv5jlxdLvN1gOzn0hpwoG7DymnRH(7bLvt2vUWNYmGk18GceWQYtwUgkRoRnqZAOpAKH5gXqB5Ja1EfFQX0KauGG1U1OS6S2anRHU7GHymnRbqtfpazqEfi7(S(udRFh3SbOmv8aGHymnRbqtfpazqEfi7(S(udRFh3SbOmv840yh0HDhqG9gq2QrLvt2vUW3PS5GvLNSCnuwDwBGM1qF8y5aU3rp6xOEimsG9PT8iTvJkjR9YJYAKBacdXyAwdGMkEaYG8kq29z9Pgw)oUzdqzQ4XPXoOJVu2VbkskjOkYQKKL37u2CWQYtwUgkRoRnqZAOpESCaHtG9PT8iTg5gGs2wRwdgIX0Sganv8aKb5vGS7Z6tnS(DCZgGYuXJtJDqh2DVZUsXrLJT10VboLnhSQ8KLRHYQZAd0Sg6Jhlhq4eyFAlpsRrUbOKT1Q1GHymnRbqtfpazqEfi7(S(udRFh3SbOmv840yh0biijaFjb4uh5J(K5u2CWQYtwUgkRoRnqZAOpESCaHtG9PT8iTg5gGs2wRwdgIX0Sganv8aKb5vGS7Z6tnS(DCZgGYuXJtyRHmvo2bDey)PMKjjXJP4NMpVd(WqmMM1aOPIhGmiVcKDFwFQH1VJB2auMkECASd64y(w9hKugGV5jbspE56ToGtzZbRkpz5AOS6S2anRH(4XYbeUJE0dIRDRrz1zTbAwdLSCnezv5jlxdLvN1gOzn0hpwoGWjW(0wEKwJCdqjBRvRbdXyAwdGMkEaYG8kq29z9Pgw)oUzdqzQ4XPXoOdByjoQKWtPYQjDLaY64u2CWQYtwUgkRoRnqZAOpESCaH7Oh9G4A3AuwDwBGM1qjlxdrwvEYY1qz1zTbAwd9XJLdiCcSpTLhP1i3auY2A1AWqmMM1aOPIhGmiVcKDFwFQH1VJB2auMkECASd6yW9BEjiSX6aOeNaBy47u2CWQYtwUgkRoRnqZAOpESCaH7qy2dIRDRrz1zTbAwdLSCnezv5jlxdLvN1gOzn0hpwoGWjW(0wEKwJCdqjBRvRbdbgIX0Sganv8aK(YLS7Z6tnmhBaktfpon2bDOjjc06pswrIUZPS5GvLNSCnuwDwBGM1qF8y5acNa7tB5rAnYnaLSTwTMabQ5XrPT8rGAVIpfhB5rsIT8rGAVIp9XJLdiCcSpTLhP1i3auY2A1AWqmMM1aOPIhG0xUKDFwFQH1VJB2auMkECcBnKPYXoOdwymFPFnjtU8gqDkBoyv5jlxdLvN1gOzn0hpwoGWjW(0wEKwJCdqjBRvRjqGAECuAlFeO2R4tXXwEKKylFeO2R4tF8y5acNa7tB5rAnYnaLSTwTgmeyigtZAa0V6KDbgaD87bLvt2vUWhgIX0Sga9RozxGbW(DCtZBheOFsy0PS5Wz184O0M3oOSZuwafhB5rsIgttcqjo4jrq4cjqGX0KauIdEseeUW0nIRDRrdkvc0hnctF0ykmeJPzna6xDYUadG974MUW(A5nG6u2CS2TgnOujqF0im9rJPWqmMM1aOF1j7cma2VJBA5JYL3aQtBakRwtEXiDiKtBakDfKEuYmGMZLdHCkBoc1z184O0M3oOSZuwafhB5rsIgttcqjo4jrq49uGaJPjbOeh8Kii8E4grNdTLpcu7v8PgttcqISQ8KLRHYQZAd0Sg6Jhlhq4eYnIoh6A3A0a00CUK7o6Jgtjg6A3A0GsLa9rJW0hnMsm0UhjqwTM8IrsB5JYL3akrNnMM1qB5JYL3akLfy)fcc3rpfiWzJPzn0UGcN0DYM3oiGYcS)cbH7qiIQ5XrPDbfoP7KnVDqafhB5rs3eiWz184OuZJUdOVbUJbKT9hgfhB5rsISQ8KLRHs(2vna56rtdOpAKH5MaboRMhhLcq7Z5sQ1MfqXXwEKKOA)fQ0a08AaTJP37q4jKBU5gmeJPzna6xDYUadG974gM59sJPznsFcuNg7GomMMeGs184OayigtZAa0V6KDbga73XnDH91YBa1PS5yTBnAxyFX8g4qF0ykrMbuPMh8(1U1ODH9fZBGd9XJLdG4A3A0FpOSAYUYf(0hpwoGWzgqLAEqyigtZAa0V6KDbga73XnT8r5YBa1PnaLvRjVyKoeYPnaLUcspkzgqZ5YHqoLnhH6SAECuAZBhu2zklGIJT8ijrJPjbOeh8Kii8EkqGX0KauIdEseeEpCJOZH2YhbQ9k(uJPjbirwvEYY1qz1zTbAwd9XJLdiCc5grNx7wJgGMMZLC3rF0ykrNv7VqLgGMxdODmnChcpHeiiu184OuaAFoxsT2Sako2YJKU5gmeJPzna6xDYUadG974Mw(OC5nG60gGYQ1Kxmshc50gGsxbPhLmdO5C5qiNYMJqDwnpokT5Tdk7mLfqXXwEKKOX0KauIdEseeEpfiWyAsakXbpjccVhUr05qB5Ja1EfFQX0KaKiRkpz5AOS6S2anRH(4XYbeoHCJOAECukaTpNlPwBwafhB5rsIQ9xOsdqZRb0oMEVdHNqeDETBnAaAAoxYDh9rJPed1yAwdfWQNfqr3HSTMZLabHU2TgnannNl5UJ(OXuIHU2TgnOujqF0im9rJPUbdXyAwdG(vNSlWay)oUPlSVwEdOoLnhDpsG8IrsfIcy1ZciU2TgnannNl5UJU7iQMhhLcq7Z5sQ1MfqXXwEKKOA)fQ0a08AaTJP37q4jerNdvnpokT5Tdk7mLfqXXwEKuGaJPjbOeh8KiWHqUbdXyAwdG(vNSlWay)oUPlOWjDNS5TdcCkBocT7rcKxmsQq0UGcN0DYM3oiG4A3A0a00CUK7o6JgtHHymnRbq)Qt2fyaSFh3ay1ZcCkBou7VqLgGMxdODm9EhcpHiQMhhLcq7Z5sQ1MfqXXwEKegIX0Sga9RozxGbW(DCd5Bx1aKRhnnWPS5WyAsakXbpjccVNWqewqU77aCGCHb7jzgqZ5cYfUE7GqUO(jHrNGCHB(iK3R3akaYbb12tc5leY3aKeY1cYVWbFtrixyOuixuF0imaYTHeY1cYr3P4qc596nGIpKFxmGIpfgIX0Sga9RozxGbW(DCtlFuU8gqDAdqz1AYlgPdHCAdqPRG0JsMb0CUCiKtzZHZQ5XrPnVDqzNPSako2YJKenMMeGsCWtIGW7Pabgttcqjo4jrq49WnIoZQYtwUgkRoRnqZAOpESCaHtiIH2YhbQ9k(uJPjbOBex7wJguQeOpAeMswUgIohQDh8tfPlVbu8LhdO4tXXwEKuGG1U1OlVbu8LhdO4tF8y5aUNq0E4gmeJPzna6xDYUadG974MM3oiq)KWOtzZHAECuAZBhu2zklGIJT8ijrJPjbOeh8Kii8EkqGX0KauIdEseeEpGHymnRbq)Qt2fyaSFh30YhxM3ddbgIX0SgafO2qApP8l10SghnVDqG(jHrNYMdNDwnpokT5Tdk7mLfqXXwEKKOX0KauIdEseeUqedTLpcu7v8Pgttcq3eiWyAsakXbpjccxy6gX1U1ObLkb6JgHPpAmfgIX0SgafO2qApP8l10SM(DCtxyFT8gqDkBow7wJguQeOpAeM(OXuIRDRrdkvc0hnctF8y5aU3yAwdTLpUmVNIUdzBfLAEqyigtZAauGAdP9KYVutZA63XnDH91YBa1PS5yTBnAqPsG(Ory6Jgtj6C3JeiVyKuHOT8XL59ce0YhbQ9k(uJPjbOabgtZAODH91YBaLMJS5ZRa1nyigtZAauGAdP9KYVutZA63XnDbfoP7KnVDqGtzZblW(leeUdHNOX0KauIdEseeEpjgkb2N2YJ0UGcN0DYUQ85CbdXyAwdGcuBiTNu(LAAwt)oUPlSVwEdOoLnhRDRrdkvc0hnctF0ykr1(luPbO51aAhtV3HWtiIQ5XrPa0(CUKATzbuCSLhjHHymnRbqbQnK2tk)snnRPFh30f2xlVbuNYMJ1U1ODH9fZBGd9rJPezgqLAEW7x7wJ2f2xmVbo0hpwoayigtZAauGAdP9KYVutZA63XnT8r5YBa1PnaLvRjVyKoeYPnaLUcspkzgqZ5YHqoLnhoZQYtwUgkRoRnqZAOpESCaHtiIRDRr)9GYQj7kx4tjlxdXqB5Ja1EfFQX0Ka0nIHQMhhLs4Ci95CrXXwEKKyOeyFAlpsB5JYL3aQSRkFoxeD2zNnMM1qB5JlZ7PO7q2wZ5sGaJPzn0UW(A5nGsr3HSTMZLBeDETBnAaAAoxYDh9rJPU5MaboRMhhLcq7Z5sQ1MfqXXwEKKOA)fQ0a08AaTJP37q4jerNx7wJgGMMZLC3rF0ykXqnMM1qbS6zbu0DiBR5CjqqORDRrdkvc0hnctF0ykXqx7wJgGMMZLC3rF0ykrJPznuaREwafDhY2Aoxed1yAwdTlSVwEdO0CKnFEfOed1yAwdTLpUmVNMJS5ZRa1n3CdgIX0SgafO2qApP8l10SM(DCtlFuU8gqDkBouZJJsjCoK(CUO4ylpssCTBnAaAAoxYDh9rJPedTLpcu7v8PgttcqIoZQYtwUgkRoRnqZAOpESCaH32EV8rwG9xOuZd2Fp7xnpokLW5q6Z5IIJT8iPabohQAECu6Vhuwnzx5cFko2YJKceWQYtwUg6Vhuwnzx5cF6Jhlhq4AEqPwsYejAmnRH(7bLvt2vUWNYcS)cb3lKBezv5jlxdLvN1gOzn0hpwoGW18GsTKKj6gmeJPznakqTH0Es5xQPzn974MUW(A5nG6u2C09ibYlgjvikGvplG4A3A0a00CUK7o6UJOAECukaTpNlPwBwafhB5rsIQ9xOsdqZRb0oMEVdHNqeD2z184O0M3oOSZuwafhB5rsIgttcqjo4jrGdHigAlFeO2R4tnMMeGUjqGZgttcqjo4jrW9ctIHQMhhL282bLDMYcO4ylps6MBWqmMM1aOa1gs7jLFPMM10VJB6ckCs3jBE7GaNYMdNx7wJgGMMZLC3rF0yQaboh6A3A0GsLa9rJW0hnMs0zJPzn0w(OC5nGszb2FHGWjKabQ5XrPa0(CUKATzbuCSLhjjQ2FHknanVgq7y69oeEc5MBUrmucSpTLhPDbfoP7KDv5Z5cgIX0SgafO2qApP8l10SM(DCdZ8EPX0SgPpbQtJDqhgttcqPAECuameJPznakqTH0Es5xQPzn974gY3UQbixpAAGtzZHX0KauIdEseeUqWqmMM1aOa1gs7jLFPMM10VJByM3lnMM1i9jqDASd6iv8aK(YLS7Z6tnmyigtZAauGAdP9KYVutZA63Xnaw9SaNYMd1(luPbO51aAhtV3HWtiIQ5XrPa0(CUKATzbuCSLhjHHiSGC33b4a5cd2tYmGMZfKlC92bHCr9tcJob5c38riVxVbuaKdcQTNeYxiKVbijKRfKFHd(MIqUWqPqUO(OryaKBdjKRfKJUtXHeY71BafFi)UyafFkmeJPznakqTH0Es5xQPzn974Mw(OC5nG60gGYQ1Kxmshc50gGsxbPhLmdO5C5qiNYMdNvZJJsBE7GYotzbuCSLhjjAmnjaL4GNebH3tbcmMMeGsCWtIGWDVUr0zwvEYY1qz1zTbAwd9XJLdiCcrm0w(iqTxXNAmnjaDJ4A3A0GsLa9rJWuYY1q05qT7GFQiD5nGIV8yafFko2YJKceS2TgD5nGIV8yafF6JhlhW9eI2d3GHiSGC33Pga54u7RaixT)cvGtqEQqEcGCdYVSCGCTGCMbuix46Tdc0pjmc5gaYBP3JpKNdqrJeYRgKlCZhxM3tHHymnRbqbQnK2tk)snnRPFh3082bb6NegDkBouZJJsBE7GYotzbuCSLhjjAmnjaL4GNebH3tbcmMMeGsCWtIGWDVWqmMM1aOa1gs7jLFPMM10VJBA5JlZ7HHymnRbqbQnK2tk)snnRPFh3ay1ZcGHadXyAwdGQFoegvGJnaLPIhameJPznaQ(5qyub974MnaLPIhNg7GocS)utYKK4Xu8tZN3b)OiOdzXBD)cFuJAmc]] )


end
