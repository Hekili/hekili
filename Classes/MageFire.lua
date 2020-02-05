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


    spec:RegisterPack( "Fire IV", 20200204.1, [[diegyaqiHQ8ivL0MesJsvvDkikVcHAwQQClvLQAxe9leLHju5ycLLHiEMQQmnHOUMQsSnev03quPghevDoevzDcvvAEQkL7Pu2he5GcvvSqePhQQuLnkuvojIQALkvDtvLkTtvfdfrfwQQsfpvvMkczRiQK9c8xjgmfhw0IP0JHAYq6YO2mjFMumAeCAfRwOQQxlez2s62kz3Q8BQgoPA5GEostxQRly7cHVdHXdrfNNuA9quP5Ruz)egedqe4HMnd(qsCKexCKexKLXijYiFCKBWR1QZGNEIJuQHbVlxm4fFdKbp9uB1tuarGh1dqmdEe6wNg)sgzdw73pcEoQe7lYapByQn5Fal4HMnd(qsCKexCKexKLXijYip4LHMGdbpYhR97tU45Oct8tOj4qk4ryqr5dybpuMIbVVkmX3azH57MAyX(VkmKMugvyCLsyiFSwHHCXZrfgD44WP1kf7)QWeFSfgsOwHjY)egsIJK4aV6qBkGiWdLvzO2aIaFIbic8sCp(bEypCndP6CTcE8L2kJcif0GpKaic84lTvgfqk4HHtZWjbpS7vuhXjX(YgO94NeYjQwWlX94h4bdhxCvr3rWqqd(8hGiWJV0wzuaPGhgondNe8WUxrDeNe7lBG2JFsiNOAbVe3JFG3IxouBXvLAapOfuiNlkObFImGiWJV0wzuaPGhgondNe8SbLsI9Lnq7XpjQJ4aVe3JFGxGYLP5ff0GpFbqe4XxARmkGuWddNMHtcE)lmXty6SYxlHHJlUQO7iyOKV0wzuHz3oHXgukjmCCXvfDhbdLbDHbzctuH5FHb7Ef1rCsSVSbAp(jHCIQvy2TtyWUxrDeNe7lBG2JFsiVY5OcdsBctK)IWGmWlX94h4T4MDiObFiNaIap(sBLrbKcEbkxqqyQCbN0EonGpXapmCAgoj49VWepHHPu(WSCXlhQT4QsnGh0ckKZfvUY4VdfMD7egBqPKlE5qTfxvQb8GwqHCUOYGUWSBNWGDVI6io5IxouBXvLAapOfuiNlQeYRCoQWGKWel2xegKjmrfM)fM4jmDw5RLlUzhk5lTvgvy2TtyWUxrDeNCXn7qjKx5CuHbzGxGYfxPkAWOGpXaVe3JFGh2x2aTh)an4d5gqe4XxARmkGuWlX94h4rqRodBcqorliGdTratDk4HHtZWjbpBqPKyFzd0E8tg0fMOctI7XpPAGCXwtAlXesOgMkmBctCctuHjX94NunqUyRjTLqgtiHA4splwyqsy0GrLRe5aExUyWJGwDg2eGCIwqahAJaM6uqd(G8aIap(sBLrbKcEy40mCsWtfQ1cKXesOgU0ZIfMVjmKaEjUh)apy44IRk6ocgcAWhYdqe4XxARmkGuWddNMHtcEycjudtlkyI7XVSkmiTjmKijpWlX94h4PtW5Bqofvnxmf0GpXIdqe4XxARmkGuWddNMHtcEXty6SYxlv1CXf9SXeK8L2kJkmrfM)fgBqPKyFzd0E8tg0fMOctI7jcUWhVgMkmiTjmiVWSBNWydkLe7lBG2JFsuhXjmrfMe3teCHpEnmvyqAty(IWGmHjQWydkLKG3fAd5msYGo4L4E8d8u1CX0gorIbn4tSyaIap(sBLrbKcEy40mCsWRZkFTuvZfx0ZgtqYxARmQWevy(xySbLsI9Lnq7XpzqxyIkmjUNi4cF8AyQWG0MW8NWSBNWydkLe7lBG2JFsuhXjmrfMe3teCHpEnmvyqAtyiryqMWevySbLssW7cTHCgjzqh8sCp(bEQAUyAdNiXGg8jgjaIap(sBLrbKcEy40mCsWZgukPUwOJRjDjd6ctuH5FHXgukj2x2aTh)KqELZrfgKegBqPK6AHoUM0LeYRCoQWSBNWydkLe7lBG2JFsuhXjmrfgS7vuhXjX(YgO94NeYRCoQWGKWydkLuxl0X1KUKqELZrfgIfM)egKjmrfM)fgBqPKWWXfxv0Demuc5vohvyqsySbLsQRf64AsxsiVY5OcZUDct8eMoR81sy44IRk6ocgk5lTvgvy2Tty6SYxlHHJlUQO7iyOKV0wzuHjQWydkLegoU4QIUJGHsuhXjmrfgS7vuhXjHHJlUQO7iyOeYRCoQWGKWydkLuxl0X1KUKqELZrfgIfM)egKbEjUh)apDTq3wtAdAWNy)bic84lTvgfqk4HHtZWjbpBqPKe8UqBiNrsg0bVe3JFGNUwOBRjTbn4tSidic84lTvgfqk4HHtZWjbVe3teCHpEnmvyqAty(tyIkm9S4s7f0HfgK2egKh8sCp(bE1jI50uS(YcAWNyFbqe4XxARmkGuWddNMHtcE2GsjX(YgO94NmOlmrfgBqPKyFzd0E8tc5vohvy(MWed8sCp(bEOWuJF0IfYzta0GpXiNaIap(sBLrbKcEy40mCsWlX9ebx4JxdtfgK2eM)aVe3JFGhkm14hTyHC2ean4tmYnGiWJV0wzuaPGxGYfeeMkxWjTNtd4tmWddNMHtcE2GsjjWzpNMsqxg0bVaLlUsv0GrbFIbEjUh)ap1a5ITM0g0GpXqEarGxI7XpWdfMA8JwSqoBcGhFPTYOasbn4tmYdqe4XxARmkGuWddNMHtcEDw5RLuoHZPP0EatqYxARmQWevy6eQHBjboRnbPoUfMVjm)fNWevy6eQHBzplU0EbDyHbjHbN0g8sCp(bEuSdXean4djXbic84lTvgfqk4fOCbbHPYfCs750a(ed8WWPz4KGxplU0EbDyH5BctI7Xpjf7qmbjoPn4fOCXvQIgmk4tmWlX94h4PgixS1K2Gg8HKyaIap(sBLrbKcEy40mCsWZgukj2x2aTh)KOoId8sCp(bEQbY2Swbn4djKaic8wEeZPb8IbEjUh)apk2HycGhFPTYOasbnObpDiJ9LnBarGpXaebEjUh)aVeIZJlZ1CTY4g84lTvgfqkObFibqe4XxARmkGuWddNMHtcE2GsjT1e5oNMInHWHHsuhXbEjUh)apBnrUZPPytiCyiObF(dqe4L4E8d809E8d84lTvgfqkObFImGiWlX94h4PRf62AsBWJV0wzuaPGg0Gg8IGH0XpWhsIlg5flwSyGhIeEZPHcEK)s3HnJkmKimjUh)eM6qBQuSh80HUAQm49vHj(gilmF3udl2)vHH0KYOcJRucd5J1kmKlEoQWOdhhoTwPy)xfM4JTWqc1kmr(NWqsCKeNyVyFI7XpQuhYyFzZElH484YCnxRmUf7tCp(rL6qg7lB2B2AICNttXMq4WWFJAZgukPTMi350uSjeomuI6ioX(e3JFuPoKX(YM9MU3JFI9jUh)OsDiJ9Ln7nDTq3wtAl2l2N4E8Js8gzypCndP6CTk2N4E8Js8gzWWXfxv0Dem83O2WUxrDeNe7lBG2JFsiNOAf7tCp(rjEJSfVCO2IRk1aEqlOqox0FJAd7Ef1rCsSVSbAp(jHCIQvSpX94hL4nYcuUmnVO)g1MnOusSVSbAp(jrDeNyFI7XpkXBKT4MD4VrT9F86SYxlHHJlUQO7iyOKV0wz0D7SbLscdhxCvr3rWqzqhzr)h7Ef1rCsSVSbAp(jHCIQD3oS7vuhXjX(YgO94NeYRCoksBr(litSpX94hL4nYW(YgO943VaLliimvUGtApNMTy)cuU4kvrdgDl2VrT9F8ykLpmlx8YHAlUQud4bTGc5CrLRm(7WD7SbLsU4Ld1wCvPgWdAbfY5Ikd672HDVI6io5IxouBXvLAapOfuiNlQeYRCoksXI9fKf9)41zLVwU4MDOKV0wz0D7WUxrDeNCXn7qjKx5CuKj2N4E8Js8gzbkxMMx)UCXBe0QZWMaKt0cc4qBeWuN(BuB2GsjX(YgO94NmOhnX94NunqUyRjTLycjudt3IlAI7XpPAGCXwtAlHmMqc1WLEwmsAWOYvICe7)QWK4E8Js8gze0QZWMaKt0cc4qBeWuN(BuB2GsjX(YgO94NmOhf7Ef1rCs1a5ITM0wIjKqnmDlUO)Rd5iKXKQbYfBnPnX6qocjjs1a5ITM0MyDihH8pPAGCXwtAJ0gjitSpX94hL4nYGHJlUQO7iy4VrTPc1AbYycjudx6zXFJeX(VkmjUh)OeVrgmCCXvfDhbd)nQnmHeQHPffmX94xwrAlMK8(suCs7V1ZIlTxqhwSpX94hL4nY0j48niNIQMlM(BuBycjudtlkyI7XVSI0gjsYtSpX94hL4nYu1CX0gorI)nQT41zLVwQQ5Il6zJji5lTvgn6)2GsjX(YgO94NmOhnX9ebx4JxdtrAd53TZgukj2x2aTh)KOoIlAI7jcUWhVgMI02xqwuBqPKe8UqBiNrsg0f7tCp(rjEJmvnxmTHtK4FJARZkFTuvZfx0ZgtqYxARmA0)TbLsI9Lnq7XpzqpAI7jcUWhVgMI02F72zdkLe7lBG2JFsuhXfnX9ebx4JxdtrAJeKf1gukjbVl0gYzKKbDX(VkmKVsy(E(YgO94NW4qH57eowyCLWqoCemuygQWGdqiFDvRWCElmjUNi4FcJn0cdIPwfgllmze5utBLfglRCilmnbwyihAHoUM0LWydkLWGWdvuHPNflmEO)jm5HkmA9GW4xvRWqiJGfg)yHH2joscJRegYHwOJRjD9ty06bHHsWdvuHHGxrfMPfMW1tvyAcSW898Lnq7XpHXHcZ3jCSW4kHHC4iyOWmuHjOlf7tCp(rjEJmDTq3wtA)BuB2Gsj11cDCnPlzqp6)2GsjX(YgO94NeYRCoks2Gsj11cDCnPljKx5C0D7SbLsI9Lnq7XpjQJ4IIDVI6ioj2x2aTh)KqELZrrYgukPUwOJRjDjH8kNJs8Fil6)2GsjHHJlUQO7iyOeYRCoks2Gsj11cDCnPljKx5C0D7IxNv(AjmCCXvfDhbdL8L2kJUBxNv(AjmCCXvfDhbdL8L2kJg1gukjmCCXvfDhbdLOoIlk29kQJ4KWWXfxv0Demuc5vohfjBqPK6AHoUM0LeYRCokX)HmX(e3JFuI3itxl0T1K2)g1MnOuscExOnKZijd6I9jUh)OeVrwDIyonfRVS)g1wI7jcUWhVgMI02Fr7zXL2lOdJ0gYl2N4E8Js8gzOWuJF0IfYzt43O2SbLsI9Lnq7XpzqpQnOusSVSbAp(jH8kNJ(TyI9jUh)OeVrgkm14hTyHC2e(nQTe3teCHpEnmfPT)e7tCp(rjEJm1a5ITM0(xGYfeeMkxWjTNtZwSFbkxCLQObJUf73O2SbLssGZEonLGUmOl2N4E8Js8gzOWuJF0IfYztqSpX94hL4nYOyhIj8BuBDw5RLuoHZPP0EatqYxARmA0oHA4wsGZAtqQJ7V9xCr7eQHBzplU0EbDyKWjTf7tCp(rjEJm1a5ITM0(xGYfeeMkxWjTNtZwSFbkxCLQObJUf73O26zXL2lOd)Te3JFsk2HycsCsBX(e3JFuI3itnq2M16VrTzdkLe7lBG2JFsuhXj2N4E8Js8gzuSdXe(T8iMtZwmWJQZyWhY5FGg0aaa]] )
    
    spec:RegisterPack( "Fire", 20200204.1, [[d0KDMcqivcpsLQ0LevLuBcH(ercfJIOQtruzvejWRujzwePULOczxO6xQummvkDmQuwMkP8mrfmnvsvxtuvTnrfQVjQkX4uPkCovQIwhrcY8uPY9iI9jvXbjsqzHsv6HQKkMircvxuLuPYgjsKpQsQu1ijsiNuLuPSsQuntIef3uuvQDkQ0pjsq1qfvLKLsKqPNsftvLORQsQKVsKO0Ef5VinyuomLfRWJjmzeDzWMLYNrWOfLtlSAIevVMiPztv3wr7wPFlz4sLJlQkwUQEoutN01vX2Ps(UuvJxurNxuL1RsvnFIY(HCYT0LjhstHuUx72RD7Tx72RN721U(C81NC086GKtNjKQrasoRnHKJukEaXCI51j50z55lJmDzYbxNxajNmv7WsHU5gcHMDgCrnVbhZJ30OwXBn9gCmf3KCgNWRx320i5qAkKY9A3ETBV9A3E9C3U21NJZH7rYXoAw9jhNyEDsozbjjSPrYHeWIKZ9IysP4belFBeaK73lILPAhwk0n3qi0SZGlQ5n4yE8Mg1kERP3GJP4gK73lIjLGXFSppe76LgXU2Tx7wK7i3Vxe76Kzlbalfc5(9Iy5ie76cdiMgtGQfLmae7nndEetZSfXu7jakxJjq1IsgaI1QhX8gwZryquljIzJWhAEi2bBeamh5(9Iy5ie76QJ0uaX8fHqGypifcXKYCebjIjf)bBI5i3VxelhHyszQcdlIjmSIypKpN4HjSkgXA1JyxNAooynQfXKp4axAeJSwPyuelR8KiwOiwREeZqS2d4melFdkupIjmSkhp54dSItxMCcfMyQV6t7(O(qZlDzkx3sxMCG1gEGm1BYXeAuBYrdsaR1pPIIeYzYr8HcFyjhx2h2WdCnMavlQOMJdwJArSEqmx2h2Wd8APhmqfhTAnetMmetnpSkVfpGv7v45WAdpqIyerSw8awTxHN)W0IfJy9GyUSpSHh41spyGkoA1AjN1MqYrdsaR1pPIIeYzst5ET0LjhyTHhit9MCmHg1MCe5j8L(1gc6WByn5i(qHpSKJl7dB4bUgtGQfvuZXbRrTiwpiMl7dB4bET0dgOIJwTgIjtgIPMhwL3IhWQ9k8CyTHhirmIiwlEaR2RWZFyAXIrSEqmx2h2Wd8APhmqfhTATKd0AGqPRnHKJipHV0V2qqhEdRjnPjhrnhhSg1s7YmmKUmLRBPltoWAdpqM6n5i(qHpSKZ40ACrnhhSg1YjR(BYXeAuBYXheYumvk)qsycRM0uUxlDzYbwB4bYuVjhXhk8HLCgNwJlQ54G1Owoz1FtoMqJAtodJaTAu9dHuXjnLBoKUm5aRn8azQ3KJ4df(WsoMqdxafwygagX6bXCdXiIyJtRXf1CCWAulNS6VjhtOrTjhF4kwc0rnhjnL71NUm5ycnQn5m8vrsRgvZakSWmVKdS2WdKPEtAk38NUm5ycnQn5mHz95rRg1FebjL8bBItoWAdpqM6nPPCZXPltoMqJAto9R3t6cIL(aUwBfqYbwB4bYuVjnLB(s6YKdS2WdKPEtohmq7NfEGkmSglHuUULCeFOWhwYrKzpbaJy9ibXCdXiIyYJyYJyMqJA5T4b6WByLlYSNaGPT3eAuR5rSRqm5rSXP14IAooynQL)W0IfJy5ieBCAn(WByfE60Wk8CYZBAulIjhILVgXev5jR(lVfpqhEdRCYZBAulILJqm5rSXP14IAooynQL)W0IfJyYHy5Rrm5rSXP14dVHv4PtdRWZjpVPrTiwocXULNFetoetoeRhji2TiMmzi2fiMDF4df4dVHv4PtdRWZH1gEGeXKjdXUaXuZdRYBEBc0A5WAdpqIyYKHyJtRXf1CCWAul)HPflgXUtcInoTgF4nScpDAyfEo55nnQfXKjdXgNwJp8gwHNonScp)HPflgXUdXULNFetMmedYNt01bK8S86GxZEWiP9)aR9FRdJyermrvEYQ)YZYRdEn7bJK2)dS2)TomnhU9w3U(RXFyAXIrS7qS8JyYHyerSXP14IAooynQLF6qmIiM8i2fiMj0OwowuViJd5eehnwcigre7ceZeAulVlVVgEdR8yPnFqitrmIi240A8mW0yjqpD8thIjtgIzcnQLJf1lY4qobXrJLaIreXgNwJNvkfRpysLtw9xeJiIjpInoTgpdmnwc0thNS6ViMmziMDF4df4dVHv4PtdRWZH1gEGeXKdXKjdXS7dFOaF4nScpDAyfEoS2WdKigretnpSkV5TjqRLdRn8ajIreXmHg1Y7Y7RH3WkpwAZheYueJiInoTgpdmnwc0thNS6VigreBCAnEwPuS(Gjvoz1Frm5sohmqRwJsqqMY1TKJj0O2KtlEGo8gwtAk37r6YKdS2WdKPEtoIpu4dl5moTgxuZXbRrTCYQ)MCmHg1MC(Zc0Qr7Q(WN0uU3Z0LjhyTHhit9MCoyG2pl8avyynwcPCDl5ycnQn50IhOdVH1KJ4df(Wso29HpuGp8gwHNonScphwB4bseJiIjpIbymScGpHz95rRg1FebjL8bBI5ttkVEetMme7cedWyyfaFcZ6ZJwnQ)icsk5d2eZNXwpIjhIreXuZdRYNGc1ZH1gEGeXiIyQ5Hv5nVnbATCyTHhirmIi240A8H3Wk80PHv45Kv)fXiIyYJyQ5Hv5)zbA1ODvF45WAdpqIyermtOrT8)SaTA0UQp8CiNG4OXsaXiIyMqJA5)zbA1ODvF45qobXrb6dtlwmIDhIDlphJyYKHyYJyUSpSHh4AmbQwurnhhSg1Iy3jbXUfXKjdXgNwJlQ54G1Ow(PdXKdXiIyxGyQ5Hv5)zbA1ODvF45WAdpqIyerSlqmtOrT8U8(A4nSYJL28bHmfXiIyxGyMqJA5T4HH598yPnFqitrm5sAkx3UnDzYbwB4bYuVjhtOrTjhH59utOrTuFG1KJpWkDTjKCmHgUaQAEyvCst56MBPltoWAdpqM6n5CWaTFw4bQWWASes56wYr8HcFyjh5rmtOrT8jOq98yPnFqitrmIiMj0Ow(euOEES0MpiKP0hMwSye7oji2T88JyYKHyxGyMqJA5tqH65XsB(GqMIyermrvEYQ)YNGc1ZFyAXIrmzYqSlqm18WQ8jOq9CyTHhirm5qmIiM8i240A8)SaTA0UQp88thIjtgIDbIPMhwL)NfOvJ2v9HNdRn8ajIjxY5GbA1AuccYuUULCmHg1MCe1CCWAuBst5621sxMCmHg1MC6knQn5aRn8azQ3KMY1TCiDzYXeAuBYz4RIK2oFEjhyTHhit9M0uUUD9PltoMqJAtod4XWl1yjKCG1gEGm1Bst56w(txMCmHg1MCAXddFvKjhyTHhit9M0uUULJtxMCmHg1MCSvay9npvyEFYbwB4bYuVjnLRB5lPltoWAdpqM6n5i(qHpSKJ8iM8iMAEyvEZBtG2zQiJdRn8ajIreXmHgUakSWmamI1dIDnetoetMmeZeA4cOWcZaWiwpiwogXKdXiIyJtRXZkLI1hmPYFWekIreXUaXS7dFOaF4nScpDAyfEoS2WdKjhtOrTjNM3Maw)qQqst5629iDzYbwB4bYuVjhXhk8HLCgNwJ3L3xcVHN8hmHIyerSXP14IAooynQL)W0IfJy9GycdRunMqYXeAuBYPlVVgEdRjnLRB3Z0LjhyTHhit9MCeFOWhwYzCAnEwPuS(Gjv(dMqtoMqJAtoD591WBynPPCV2TPltoWAdpqM6n5i(qHpSKt3dUOeeKC34yr9ImeJiInoTgpdmnwc0th)0LCmHg1MC6Y7RH3WAst5En3sxMCmHg1MC6YkyJCsBEBc4KdS2WdKPEtAk3RDT0LjhyTHhit9MCeFOWhwYzCAnUOMJdwJA5pmTyXiwpiMWWkvJjGyerSXP14IAooynQLF6qmzYqSXP14IAooynQLtw93KJj0O2KdwuVilPPCVwoKUm5aRn8azQ3KJ4df(WsoJtRXf1CCWAul)HPflgXUdXiii5tlNigreZeA4cOWcZaWiwpiMBjhtOrTjhF4kwc0rnhjnL71U(0LjhyTHhit9MCeFOWhwYzCAnUOMJdwJA5pmTyXi2DigbbjFA5eXiIyJtRXf1CCWAul)0LCmHg1MCiFJqTy64btZsAk3RL)0LjhyTHhit9MCeFOWhwYrTNaO8mW8AgVtOi2DsqSC4weJiIPMhwLJb7JLavRJiJdRn8azYXeAuBYblQxKL0KMCmHgUaQAEyvC6YuUULUm5aRn8azQ3KJ4df(WsoMqdxafwygagX6bXCdXiIyJtRXf1CCWAulNS6VigretEeZL9Hn8axJjq1IkQ54G1OweRhetuLNS6VCF4kwc0rnhCYZBAulIjtgI5Y(WgEGRXeOArf1CCWAulIDNee7wetUKJj0O2KJpCflb6OMJKMY9APltoWAdpqM6n5i(qHpSKZ40A8)SaTA0UQp88thIreXKhXAXdy1EfE(dtlwmI1dIjQYtw9x(euOEo55nnQfXKjdXUaXAXdy1EfEUj0WfGyYHyYKHyIQ8Kv)L)NfOvJ2v9HN)W0IfJy9GyAmbQwuYaqmIiMj0Ow(FwGwnAx1hEUiZEcagXUdXCdXKjdXKhXev5jR(lFckupN88Mg1Iy3HyUSpSHh4AmbQwurnhhSg1IyYKHyUSpSHh4AmbQwurnhhSg1Iy3jbXUfXKdXiIyxGyQ5Hv5)zbA1ODvF45WAdpqIyerm5rmrvEYQ)YNGc1ZjpVPrTi2DiwlEaR2RWZFyAXIrmzYqSlqm18WQ8w8awTxHNdRn8ajIjtgIDbI1IhWQ9k8CtOHlaXKl5ycnQn5mbfQpPjn5ekmX0SGqgT7J6dnV0LPCDlDzYbwB4bYuVjhXhk8HLCKhXuZdRY)Zc0Qr7Q(WZH1gEGeXiIyUSpSHh4AmbQwurnhhSg1Iy3jbXmHg1Y)Zc0Qr7Q(WZfgwPAmbetMmeZL9Hn8axJjq1IkQ54G1Owe7oji2TiMCigre7ceRfpGv7v45MqdxaIjtgInoTgxuZXbRrT8txYXeAuBYryEp1eAul1hyn54dSsxBcjNqHjMkQ54G1O2KMY9APltoMqJAtohmqdfM4KdS2WdKPEtAk3CiDzYbwB4bYuVjhtOrTjNPTrdWArRgDAKlGXjhXhk8HLCUaXG85eDDaj3UpoZEdtB1Q0Qr7Q(WJyermx2h2WdCnMavlQOMJdwJArS7qS7rYzTjKCM2gnaRfTA0PrUagN0uUxF6YKdS2WdKPEtoMqJAto29Xz2ByARwLwnAx1h(KJ4df(WsoUSpSHh4AmbQwurnhhSg1Iy3jbXYpIDfI5w(rmPaeZL9Hn8aVvRsjRZWd0APhmKCwBcjh7(4m7nmTvRsRgTR6dFst5M)0LjhyTHhit9MCmHg1MC(sf)bRaj1vvKvrjlVp5i(qHpSKJl7dB4bUgtGQfvuZXbRrTiwpiMl7dB4bET0dgOIJwTwYzTjKC(sf)bRaj1vvKvrjlVpPPCZXPltoWAdpqM6n5ycnQn5y5Zj6kfwLU2rd)bNCeFOWhwYXL9Hn8axJjq1IkQ54G1OweRheZL9Hn8aVw6bduXrRwl5S2esow(CIUsHvPRD0WFWjnLB(s6YKdS2WdKPEtoMqJAto4SWf8uxWwt6d(qKCeFOWhwYXL9Hn8axJjq1IkQ54G1OweRheZL9Hn8aVw6bduXrRwl5S2eso4SWf8uxWwt6d(qK0uU3J0LjhyTHhit9MCmHg1MCA1pcssyP1ahKHTuH36NCeFOWhwYXL9Hn8axJjq1IkQ54G1OweRheZL9Hn8aVw6bduXrRwl5S2esoT6hbjjS0AGdYWwQWB9tAk37z6YKdS2WdKPEtoMqJAtoz2pRneusyAk8H5J7dFYbAnqO01MqYjZ(zTHGscttHpmFCF4tAkx3UnDzYbwB4bYuVjhtOrTjNP5B1pbsAg8MNet9aH(V1HtoIpu4dl54Y(WgEGRXeOArf1CCWAulI1Jeel)5hXiIyJtRXf1CCWAulNS6VigreZL9Hn8axJjq1IkQ54G1OweRheZL9Hn8aVw6bduXrRwl5S2esotZ3QFcK0m4npjM6bc9FRdN0uUU5w6YKdS2WdKPEtoMqJAto2kcyvQu3sPvJ2pWK1m5i(qHpSKJl7dB4bUgtGQfvuZXbRrTiwpsqS8NFeJiInoTgxuZXbRrTCYQ)Iyermx2h2WdCnMavlQOMJdwJArSEqmx2h2Wd8APhmqfhTATKZAti5yRiGvPsDlLwnA)atwZKMY1TRLUm5aRn8azQ3KJj0O2KZcN38uCER1HbkSz2kGp5i(qHpSKJl7dB4bUgtGQfvuZXbRrTiwpsqSRp)igreBCAnUOMJdwJA5Kv)fXiIyUSpSHh4AmbQwurnhhSg1Iy9GyUSpSHh41spyGkoA1AjN1MqYzHZBEkoV16Waf2mBfWN0KMCiHMD8A6YuUULUm5ycnQn5iQZQWJ7aVp5aRn8azQ3KMY9APltoWAdpqM6n5uDjhmOjhtOrTjhx2h2WdjhxM)ajhrvEYQ)Yf1CCWAul)HPflo54YE6Ati5OXeOArf1CCWAuBst5MdPltoWAdpqM6n5uDjNPLZKJj0O2KJl7dB4HKJlZFGKJOkpz1F5tywFE0Qr9hrqsjFWMy(dtlwCYr8HcFyjhaJHva8jmRppA1O(JiiPKpytmFAs51JyerSXP14tywFE0Qr9hrqsjFWMyoz1FrmIiMOkpz1F5tywFE0Qr9hrqsjFWMy(dtlwmILJqmrvEYQ)Yf1CCWAul)HPflgXUtcI5Y(WgEGNvEsQOMJdwJAPA2d4SYtMCCzpDTjKC0ycuTOIAooynQnPPCV(0LjhyTHhit9MCQUKZ0YzYXeAuBYXL9Hn8qYXL5pqYruLNS6V8(17jDbXsFaxRTcG)W0IfNCeFOWhwYbWyyfaVF9EsxqS0hW1ARa4ttkVEeJiInoTgVF9EsxqS0hW1ARa4Kv)fXiIyIQ8Kv)L3VEpPliw6d4ATva8hMwSyelhHyIQ8Kv)LlQ54G1Ow(dtlwmIDNeeZL9Hn8apR8KurnhhSg1s1ShWzLNm54YE6Ati5OXeOArf1CCWAuBst5M)0LjhyTHhit9MCmHg1MCeM3tnHg1s9bwto(aR01MqYjuyIPzbHmA3h1hAEjnLBooDzYbwB4bYuVjhXhk8HLCgNwJlQ54G1Owoz1FtoMqJAtoZ4)6PX0iajnLB(s6YKdS2WdKPEtoIpu4dl5ipI5Y(WgEGRXeOArf1CCWAulIDhI52TiMmziMgtGQfLmae7oeZL9Hn8axJjq1IkQ54G1OwetUKJj0O2KdHJ9KHT0QrT7dFPzjnL79iDzYXeAuBYruRaw9nfiPnVnHKdS2WdKPEtAk37z6YKJj0O2KZdwxSeOnVnbCYbwB4bYuVjnLRB3MUm5ycnQn50kXbdKu7(WhkqhGntoWAdpqM6nPPCDZT0LjhtOrTjNUZhT8ILaD4nSMCG1gEGm1Bst5621sxMCmHg1MC(ORZd0yP4otajhyTHhit9M0uUULdPltoMqJAtoAgqp7OoljTvVasoWAdpqM6nPPCD76txMCG1gEGm1BYr8HcFyjh18WQ8w8awTxHNdRn8ajIreXAXdy1EfE(dtlwmI1dI1oEp9brM9eaQgtaXKjdXCzFydpW1ycuTOIAooynQfX6bXCzFydpWf1CCWAul9RoQ4OvRHyerSXP14IAooynQLtw9xetMmetJjq1IsgaIDhI5Y(WgEGRXeOArf1CCWAulIreXgNwJlQ54G1Owoz1FtoMqJAto)zbA1ODvF4tAkx3YF6YKdS2WdKPEtoIpu4dl5ipIPMhwL)NfOvJ2v9HNdRn8ajIreXCzFydpW1ycuTOIAooynQfXUtcIzcnQL)NfOvJ2v9HNlmSs1yciMmziMl7dB4bUgtGQfvuZXbRrTi2DsqSBrm5qmIi2fiwlEaR2RWZnHgUaetMmeBCAnUOMJdwJA5NUKJj0O2KJW8EQj0OwQpWAYXhyLU2esoIAooynQL2LzyiPPCDlhNUm5aRn8azQ3Kt1LCWGMCmHg1MCCzFydpKCCz(dKCuZdRY)Zc0Qr7Q(WZH1gEGeXiIyIQ8Kv)L)NfOvJ2v9HN)W0IfJy3HyIQ8Kv)L3IhOdVHvE7490hez2taOAmbeJiIjpI5Y(WgEGRXeOArf1CCWAulI1dI5Y(WgEGlQ54G1Ow6xDuXrRwdXKjdXAXdy1EfEUj0WfGyYHyerm5rmrvEYQ)Y)Zc0Qr7Q(WZFyAXIrS7qmnMavlkzaiMmziMj0Ow(FwGwnAx1hEUiZEcagX6bXUfXKdXKjdXCzFydpW1ycuTOIAooynQfXUdXmHg1YBXd0H3WkVD8E6dIm7jaunMaIDfIjQYtw9xElEGo8gw5KN30OwetkaXS7dFOaF4nScpDAyfEoS2WdKigre7ceRfpGv7v45MqdxaIreXCzFydpW1ycuTOIAooynQfXUdX0ycuTOKbGyYKHyQ5Hv5T4bSAVcphwB4bseJiI1IhWQ9k8CtOHlaXiIyT4bSAVcp)HPflgXUdXev5jR(lVfpqhEdR82X7PpiYSNaq1yci2viMOkpz1F5T4b6WByLtEEtJArmPaeZUp8Hc8H3Wk80PHv45WAdpqMCCzpDTjKCAXd0H3WkTRkFSesAkx3YxsxMCG1gEGm1BY5GbA)SWduHH1yjKY1TKJ4df(WsoYJyagdRa4tywFE0Qr9hrqsjFWMy(0KYRhXKjdXamgwbWNWS(8OvJ6pIGKs(GnX8zS1Jyerm7(WhkWhEdRWtNgwHNdRn8ajIjhIreXez2taWiMeeBA5KkYSNaGrmIi2fi240A8SsPy9btQ8hmHIyerSlqm5rSXP14zGPXsGE64pycfXiIyYJyJtRXf1CCWAul)0Hyerm5rmtOrT8w8WW8EES0MpiKPiMmziMj0OwExEFn8gw5XsB(GqMIyYKHyMqJA5yr9ImoKtqC0yjGyYHyYKHyQ9eaLNbMxZ4DcfXUtcILd3IyermtOrTCSOErghYjioASeqm5qm5qmIi2fiM8i2fi240A8mW0yjqpD8hmHIyerSlqSXP14zLsX6dMu5pycfXiIyJtRXf1CCWAulNS6VigretEeZeAulVfpmmVNhlT5dczkIjtgIzcnQL3L3xdVHvES0MpiKPiMCiMCjNdgOvRrjiit56wYXeAuBYPfpqhEdRjnLRB3J0LjhyTHhit9MCoyG2pl8avyynwcPCDl5i(qHpSKtlEaR2RWZnHgUaeJiIjYSNaGrSEKGyUHyerm5rSlqmx2h2Wd8w8aD4nSs7QYhlbetMmeBCAn(FwGwnAx1hE(PdXKdXiIyYJyxGy29HpuGp8gwHNonScphwB4bsetMmeBCAn(WByfE60Wk88hMwSye7oe7wE(rm5qmIiM8i2fiMj0OwElEyyEphYjioASeqmIi2fiMj0OwExEFn8gw5XsB(GqMIyerSXP14zGPXsGE64NoetMmeZeAulVfpmmVNd5eehnwcigreBCAnEwPuS(Gjvoz1FrmzYqmtOrT8U8(A4nSYJL28bHmfXiIyJtRXZatJLa90XjR(lIreXgNwJNvkfRpysLtw9xetUKZbd0Q1OeeKPCDl5ycnQn50IhOdVH1KMY1T7z6YKdS2WdKPEtoIpu4dl5moTg)plqRgTR6dp)0HyerSXP14IAooynQLtw93KJj0O2KJW8EQj0OwQpWAYXhyLU2esoF1r7YmmK0uUx720LjhyTHhit9MCQUKdg0KJj0O2KJl7dB4HKJlZFGKJAEyv(FwGwnAx1hEoS2WdKigretuLNS6V8)SaTA0UQp88hMwSye7oetuLNS6V8USc2iN0M3MaM3oEp9brM9eaQgtaXiIyYJyUSpSHh4AmbQwurnhhSg1Iy9GyUSpSHh4IAooynQL(vhvC0Q1qm5qmIiM8iMOkpz1F5)zbA1ODvF45pmTyXi2DiMgtGQfLmaetMmeZeAul)plqRgTR6dpxKzpbaJy9Gy3IyYHyYKHyUSpSHh4AmbQwurnhhSg1Iy3HyMqJA5DzfSroPnVnbmVD8E6dIm7jaunMaIreXCzFydpW1ycuTOIAooynQfXUdX0ycuTOKbKCCzpDTjKC6YkyJCs7QYhlHKMY9AULUm5aRn8azQ3KJj0O2KJW8EQj0OwQpWAYXhyLU2esoy1ws7jPFPMg1M0KMCcfMyQOMJdwJAtxMY1T0LjhyTHhit9MCwBcjNGWgAulDAeamTDWqYXeAuBYjiSHg1sNgbatBhmK0uUxlDzYbwB4bYuVjhtOrTjNS86GxZEWiP9)aR9FRdNCeFOWhwYzCAnUOMJdwJA5NoeJiIzcnQL3IhOdVHvUiZEcagXKGy3IyermtOrT8w8aD4nSYFqKzpbGQXeqSEqmccs(0YzYzTjKCYYRdEn7bJK2)dS2)ToCst5MdPltoWAdpqM6n5S2esotBJgG1Iwn60ixaJtoMqJAtotBJgG1Iwn60ixaJtAk3RpDzYzCAn6Ati5mTnAawlA1OtJCbmMkYSofEATqYr8HcFyjNXP14IAooynQLF6qmzYqmtOrT8jOq98yPnFqitrmIiMj0Ow(euOEES0MpiKP0hMwSye7oji2T88NCoyGwTgLGGmLRBjhtOrTjhHTcWthNwl5aRn8azQ3KMYn)PltoWAdpqM6n5S2eso29ppOzfMIJLaqs78NPrasohmqRwJsqqMY1TKJj0O2KJD)ZdAwHP4yjaK0o)zAeGKJ4df(WsoJtRXf1CCWAul)0HyYKHyMqJA5tqH65XsB(GqMIyermtOrT8jOq98yPnFqitPpmTyXi2DsqSB55pPPCZXPltoWAdpqM6n5ycnQn5qWBKHP1JPdJKaKCoyGwTgLGGmLRBjhXhk8HLCgNwJlQ54G1Ow(PdXKjdXmHg1YNGc1ZJL28bHmfXiIyMqJA5tqH65XsB(GqMsFyAXIrS7KGy3YZFYbAnqO01MqYHG3idtRhthgjbiPPCZxsxMCG1gEGm1BYXeAuBYHG3idtRhtNaP59rTjNdgOvRrjiit56wYr8HcFyjNXP14IAooynQLF6qmzYqmtOrT8jOq98yPnFqitrmIiMj0Ow(euOEES0MpiKP0hMwSye7oji2T88NCGwdekDTjKCi4nYW06X0jqAEFuBst5EpsxMCG1gEGm1BYzTjKCgMhAXd0XBRil5CWaTAnkbbzkx3soMqJAtodZdT4b64TvKLCeFOWhwYzCAnUOMJdwJA5NoetMmeZeAulFckuppwAZheYueJiIzcnQLpbfQNhlT5dczk9HPflgXUtcIDlp)jnL79mDzYbwB4bYuVjN1MqYbNvcPocfEmTzlHKZbd0Q1OeeKPCDl5ycnQn5GZkHuhHcpM2SLqYr8HcFyjNXP14IAooynQLF6qmzYqmtOrT8jOq98yPnFqitrmIiMj0Ow(euOEES0MpiKP0hMwSye7oji2T88N0uUUDB6YKdS2WdKPEtoRnHKJEFBbmDyVuXDXc4KZbd0Q1OeeKPCDl5ycnQn5O33wath2lvCxSao5i(qHpSKZ40ACrnhhSg1YpDiMmziMj0Ow(euOEES0MpiKPigreZeAulFckuppwAZheYu6dtlwmIDNee7wE(tAkx3ClDzYbwB4bYuVjN1MqYXwraRsL6wkTA0(bMSMjNdgOvRrjiit56wYXeAuBYXwraRsL6wkTA0(bMSMjhXhk8HLCgNwJlQ54G1Ow(PdXKjdXmHg1YNGc1ZJL28bHmfXiIyMqJA5tqH65XsB(GqMsFyAXIrS7KGy3YZFst5621sxMCG1gEGm1BYzTjKCw48MNIZBTomqHnZwb8jNdgOvRrjiit56wYXeAuBYzHZBEkoV16Waf2mBfWNCeFOWhwYzCAnUOMJdwJA5NoetMmeZeAulFckuppwAZheYueJiIzcnQLpbfQNhlT5dczk9HPflgXUtcIDlp)jnLRB5q6YKdS2WdKPEtoRnHKZ08T6NajndEZtIPEGq)36WjNdgOvRrjiit56wYXeAuBYzA(w9tGKMbV5jXupqO)BD4KJ4df(WsoJtRXf1CCWAul)0HyYKHyMqJA5tqH65XsB(GqMIyermtOrT8jOq98yPnFqitPpmTyXi2DsqSB55pPjn509GOMdttxMY1T0LjhtOrTjh7f2c0yvW7bHMCG1gEGm1Bst5ET0LjhyTHhit9MCQUKdg0KJj0O2KJl7dB4HKJlZFGKto(2KJl7PRnHKJOMJdwJAPF1rfhTATKMYnhsxMCG1gEGm1BYP6soyqtoMqJAtoUSpSHhsoUm)bsoq(CIUoGKpTnAawlA1OtJCbmgXKjdXG85eDDajNG3idtRhthgjbaXKjdXG85eDDajNG3idtRhtNaP59rTiMmzigKpNORdi5bHn0Ow60iayA7GbetMmedYNt01bKC9(2cy6WEPI7IfWiMmzigKpNORdi529ppOzfMIJLaqs78NPraqmzYqmiForxhqYTveWQuPULsRgTFGjRjIjtgIb5Zj66asooResDek8yAZwciMmzigKpNORdi5lCEZtX5TwhgOWMzRaEetMmedYNt01bK8H5Hw8aD82kYsoUSNU2esoIAooynQLwl9GHKMY96txMCG1gEGm1BYP6soyqtoMqJAtoUSpSHhsoUm)bsoq(CIUoGKB3hNzVHPTAvA1ODvF4rmIiMl7dB4bUOMJdwJAP1spyi54YE6Ati50QvPK1z4bAT0dgsAk38NUm5aRn8azQ3Kt1LCWGMCmHg1MCCzFydpKCCz(dKCU2TiMuaIjpI5Y(WgEGlQ54G1OwAT0dgqmIi2fiMl7dB4bERwLswNHhO1spyaXKdXUcXU(BrmPaetEeZL9Hn8aVvRsjRZWd0APhmGyYHyxHyxl)iMuaIjpIb5Zj66asUDFCM9gM2QvPvJ2v9HhXiIyxGyUSpSHh4TAvkzDgEGwl9Gbetoe7ke7EGysbiM8igKpNORdi5tBJgG1Iwn60ixaJrmIi2fiMl7dB4bERwLswNHhO1spyaXKl54YE6Ati5ul9GbQ4OvRL0uU540LjhyTHhit9MCQUKZdyqtoMqJAtoUSpSHhsoUSNU2esozLNKkQ54G1OwQM9aoR8KjhsOzhVMCU2TjnLB(s6YKdS2WdKPEtAk37r6YKdS2WdKPEtoRnHKJDFCM9gM2QvPvJ2v9Hp5ycnQn5y3hNzVHPTAvA1ODvF4tAk37z6YKJj0O2KZm(VEAmncqYbwB4bYuVjnLRB3MUm5ycnQn50vAuBYbwB4bYuVjnLRBULUm5ycnQn50L3xdVH1KdS2WdKPEtAstoy1ws7jPFPMg1MUmLRBPltoWAdpqM6n5i(qHpSKJ8iM8iMAEyvEZBtG2zQiJdRn8ajIreXmHgUakSWmamI1dI5gIreXUaXAXdy1EfEUj0WfGyYHyYKHyMqdxafwygagX6bXUEetoeJiInoTgpRukwFWKk)btOjhtOrTjNM3Maw)qQqst5ET0LjhyTHhit9MCeFOWhwYzCAnEwPuS(Gjv(dMqrmIi240A8SsPy9btQ8hMwSye7oeZeAulVfpmmVNd5eehfOAmHKJj0O2KtxEFn8gwtAk3CiDzYbwB4bYuVjhXhk8HLCgNwJNvkfRpysL)GjueJiIjpI19Glkbbj3nElEyyEpIjtgI1IhWQ9k8CtOHlaXKjdXmHg1Y7Y7RH3WkpwAZheYuetUKJj0O2KtxEFn8gwtAk3RpDzYbwB4bYuVjhXhk8HLCez2taWiwpsqSCaXiIyMqdxafwygagX6bXUgIreXUaXCzFydpW7YkyJCs7QYhlHKJj0O2KtxwbBKtAZBtaN0uU5pDzYbwB4bYuVjhXhk8HLCgNwJNvkfRpysL)GjueJiIP2tauEgyEnJ3jue7ojiwoClIreXuZdRYXG9XsGQ1rKXH1gEGm5ycnQn50L3xdVH1KMYnhNUm5aRn8azQ3KJ4df(WsoJtRX7Y7lH3Wt(dMqrmIiMWWkvJjGy3HyJtRX7Y7lH3Wt(dtlwCYXeAuBYPlVVgEdRjnLB(s6YKdS2WdKPEtohmq7NfEGkmSglHuUULCeFOWhwYrEetEeZL9Hn8axJjq1IkQ54G1OweRhe7wetoeJiInoTg)plqRgTR6dpNS6Vigre7ceRfpGv7v45MqdxaIjhIreXUaXuZdRYLASK(yjWH1gEGeXiIyxGyUSpSHh4T4b6WByL2vLpwcigretEetEetEeZeAulVfpmmVNd5eehnwciMmziMj0OwExEFn8gw5qobXrJLaIjhIreXKhXgNwJNbMglb6PJ)GjuetoetoetMmetEetnpSkhd2hlbQwhrghwB4bseJiIP2tauEgyEnJ3jue7ojiwoClIreXKhXgNwJNbMglb6PJ)GjueJiIDbIzcnQLJf1lY4qobXrJLaIjtgIDbInoTgpRukwFWKk)btOigre7ceBCAnEgyASeONo(dMqrmIiMj0OwowuViJd5eehnwcigre7ceZeAulVlVVgEdR8yPnFqitrmIi2fiMj0OwElEyyEppwAZheYuetoetoetUKZbd0Q1OeeKPCDl5ycnQn50IhOdVH1KMY9EKUm5aRn8azQ3KJ4df(WsoQ5Hv5snwsFSe4WAdpqIyerSXP14zGPXsGE64pycfXiIyxGyT4bSAVcp3eA4cqmIiM8iMl7dB4bUgtGQfvuZXbRrTiwpiw7490hez2taOAmbe7ke7Ai2viMAEyvUuJL0hlboS2WdKiMmziM8i2fiMAEyv(FwGwnAx1hEoS2WdKiMmziMOkpz1F5)zbA1ODvF45pmTyXiwpiMgtGQfLmaeJiIzcnQL)NfOvJ2v9HNlYSNaGrS7qm3qm5qmIiMl7dB4bUgtGQfvuZXbRrTiwpiMgtGQfLmaetUKJj0O2KtlEGo8gwtAk37z6YKdS2WdKPEtoIpu4dl509Glkbbj3nowuVidXiIyJtRXZatJLa90XpDigretnpSkhd2hlbQwhrghwB4bseJiIP2tauEgyEnJ3jue7ojiwoClIreXKhXKhXuZdRYBEBc0otfzCyTHhirmIiMj0WfqHfMbGrmjiMBigre7ceRfpGv7v45MqdxaIjhIjtgIjpIzcnCbuyHzaye7oe76rmIi2fiMAEyvEZBtG2zQiJdRn8ajIjhIjxYXeAuBYPlVVgEdRjnLRB3MUm5aRn8azQ3KJ4df(WsoYJyJtRXZatJLa90XFWekIjtgIjpIDbInoTgpRukwFWKk)btOigretEeZeAulVfpqhEdRCrM9eamI1dIDlIjtgIPMhwLJb7JLavRJiJdRn8ajIreXu7jakpdmVMX7ekIDNeelhUfXKdXKdXKdXiIyxGyUSpSHh4DzfSroPDv5JLqYXeAuBYPlRGnYjT5TjGtAkx3ClDzYbwB4bYuVjhtOrTjhH59utOrTuFG1KJpWkDTjKCmHgUaQAEyvCst5621sxMCG1gEGm1BYr8HcFyjhtOHlGclmdaJy9GyULCmHg1MCiFJqTy64btZsAkx3YH0LjhyTHhit9MCmHg1MCeM3tnHg1s9bwto(aR01MqYjuyIP(QpT7J6dnVKMY1TRpDzYbwB4bYuVjhXhk8HLCu7jakpdmVMX7ekIDNeelhUfXiIyQ5Hv5yW(yjq16iY4WAdpqMCmHg1MCWI6fzjnLRB5pDzYbwB4bYuVjNdgO9ZcpqfgwJLqkx3soIpu4dl5CbI5Y(WgEG3IhOdVHvAxv(yjGyerm5rm18WQ8M3MaTZurghwB4bseJiIzcnCbuyHzayeRhe7AiMmziMj0WfqHfMbGrSEqS7jIjhIreXKhXKhXCzFydpW1ycuTOIAooynQfX6bXUfXKdXiIyxGyT4bSAVcp3eA4cqm5qmIi240A8SsPy9btQCYQ)Iyerm5rSlqm7(WhkWhEdRWtNgwHNdRn8ajIjtgInoTgF4nScpDAyfE(dtlwmIDhIDlp)iMCjNdgOvRrjiit56wYXeAuBYPfpqhEdRjnLRB540LjhyTHhit9MCeFOWhwYrnpSkV5Tjq7mvKXH1gEGeXiIyMqdxafwygagX6bXUgIjtgIzcnCbuyHzayeRhe7EMCmHg1MCAEBcy9dPcjnLRB5lPltoMqJAtoT4HH59jhyTHhit9M0uUUDpsxMCmHg1MCWI6fzjhyTHhit9M0KMC(QJ2LzyiDzkx3sxMCmHg1MC(Zc0Qr7Q(WNCG1gEGm1Bst5ET0LjhyTHhit9MCeFOWhwYrEetnpSkV5Tjq7mvKXH1gEGeXiIyMqdxafwygagX6bXCdXKjdXmHgUakSWmamI1dID9iMCigreBCAnEwPuS(Gjv(dMqtoMqJAtonVnbS(HuHKMYnhsxMCG1gEGm1BYr8HcFyjNXP14zLsX6dMu5pycn5ycnQn50L3xdVH1KMY96txMCG1gEGm1BY5GbA)SWduHH1yjKY1TKJ4df(WsoxGyYJyQ5Hv5nVnbANPImoS2WdKigreZeA4cOWcZaWiwpi21qmzYqmtOHlGclmdaJy9Gy5hXKdXiIyYJyxGyT4bSAVcp3eA4cqmIiM8iMl7dB4bUgtGQfvuZXbRrTiwpi2TiMCiMCigretEe7ceBCAnEgyASeONo(dMqrmIi2fi240A8SsPy9btQ8hmHIyerSlqSUhCrRwJsqqYBXd0H3WkIreXKhXmHg1YBXd0H3WkxKzpbaJy9ibXUgIjtgIjpIzcnQL3LvWg5K282eWCrM9eamI1JeeZneJiIPMhwL3LvWg5K282eWCyTHhirm5qmzYqm5rm18WQCZd5eRVHVVHPTZNhhwB4bseJiIjQYtw9xo5BeQfthpyAg)bJmpetoetMmetEetnpSkhd2hlbQwhrghwB4bseJiIP2tauEgyEnJ3jue7ojiwoClIjhIjhIjxY5GbA1AuccYuUULCmHg1MCAXd0H3WAst5M)0LjhyTHhit9MCmHg1MCeM3tnHg1s9bwto(aR01MqYXeA4cOQ5HvXjnLBooDzYbwB4bYuVjhXhk8HLCgNwJ3L3xcVHN8hmHIyermHHvQgtaXUdXgNwJ3L3xcVHN8hMwSyeJiInoTg)plqRgTR6dp)HPflgX6bXegwPAmHKJj0O2KtxEFn8gwtAk38L0LjhyTHhit9MCoyG2pl8avyynwcPCDl5i(qHpSKZfiM8iMAEyvEZBtG2zQiJdRn8ajIreXmHgUakSWmamI1dIDnetMmeZeA4cOWcZaWiwpiw(rm5qmIiM8i2fiwlEaR2RWZnHgUaeJiIjpI5Y(WgEGRXeOArf1CCWAulI1dIDlIjhIjhIreXKhXgNwJNbMglb6PJ)GjueJiIjpIP2tauEgyEnJ3jueRhjiwoClIjtgIDbIPMhwLJb7JLavRJiJdRn8ajIjhIjxY5GbA1AuccYuUULCmHg1MCAXd0H3WAst5EpsxMCG1gEGm1BY5GbA)SWduHH1yjKY1TKJ4df(WsoxGyYJyQ5Hv5nVnbANPImoS2WdKigreZeA4cOWcZaWiwpi21qmzYqmtOHlGclmdaJy9Gy5hXKdXiIyYJyxGyT4bSAVcp3eA4cqmIiM8iMl7dB4bUgtGQfvuZXbRrTiwpi2TiMCiMCigretnpSkhd2hlbQwhrghwB4bseJiIP2tauEgyEnJ3jue7ojiwoClIreXKhXgNwJNbMglb6PJ)GjueJiIDbIzcnQLJf1lY4qobXrJLaIjtgIDbInoTgpdmnwc0th)btOigre7ceBCAnEwPuS(Gjv(dMqrm5sohmqRwJsqqMY1TKJj0O2KtlEGo8gwtAk37z6YKdS2WdKPEtoIpu4dl509Glkbbj3nowuVidXiIyJtRXZatJLa90XpDigretnpSkhd2hlbQwhrghwB4bseJiIP2tauEgyEnJ3jue7ojiwoClIreXKhXUaXuZdRYBEBc0otfzCyTHhirmzYqmtOHlGclmdaJysqm3qm5soMqJAtoD591WBynPPCD720LjhyTHhit9MCeFOWhwY5ceR7bxuccsUB8USc2iN0M3MagXiIyJtRXZatJLa90XFWeAYXeAuBYPlRGnYjT5TjGtAkx3ClDzYbwB4bYuVjhXhk8HLCu7jakpdmVMX7ekIDNeelhUfXiIyQ5Hv5yW(yjq16iY4WAdpqMCmHg1MCWI6fzjnLRBxlDzYbwB4bYuVjhXhk8HLCmHgUakSWmamI1dIDTKJj0O2Kd5BeQfthpyAwst56woKUm5aRn8azQ3KZbd0(zHhOcdRXsiLRBjhXhk8HLCKhXuZdRYBEBc0otfzCyTHhirmIiMj0WfqHfMbGrSEqSRHyYKHyMqdxafwygagX6bXYpIjhIreXKhXKhXCzFydpW1ycuTOIAooynQfX6bXUfXKdXiIyxGyT4bSAVcp3eA4cqm5qmIi240A8SsPy9btQCYQ)Iyerm5rSlqm7(WhkWhEdRWtNgwHNdRn8ajIjtgInoTgF4nScpDAyfE(dtlwmIDhIDlp)iMCjNdgOvRrjiit56wYXeAuBYPfpqhEdRjnLRBxF6YKdS2WdKPEtoIpu4dl5OMhwL382eODMkY4WAdpqIyermtOHlGclmdaJy9GyxdXKjdXmHgUakSWmamI1dIL)KJj0O2KtZBtaRFiviPPCDl)PltoMqJAtoT4HH59jhyTHhit9M0KM0KtF73yjGtox3MD1RajIDprmtOrTiMpWkMJCp5G7ark3CCoKC6(QfEi5CViMukEaXY3gba5(9IyzQ2HLcDZnecn7m4IAEdoMhVPrTI3A6n4ykUb5(9Iysjy8h7ZdXUEPrSRD71Uf5oY97fXUoz2saWsHqUFViwocXUUWaIPXeOArjdaXEtZGhX0mBrm1EcGY1ycuTOKbGyT6rmVH1Cege1sIy2i8HMhIDWgbaZrUFViwocXUU6infqmFriei2dsHqmPmhrqIysXFWMyoY97fXYriMuMQWWIycdRi2d5ZjEycRIrSw9i21PMJdwJArm5doWLgXiRvkgfXYkpjIfkI1QhXmeR9aodXY3Gc1JycdRYXrUJC)ErSR7YjiokqIydOvpGyIAomfXgaHyXCetkmHa6umIT1MJYSF2oEeZeAulgXQ1Nhh5(9IyMqJAX8Uhe1CyQKM3Wsf5(9IyMqJAX8Uhe1Cy6vsUPvfjY97fXmHg1I5DpiQ5W0RKCJDimHvnnQf5Uj0OwmV7brnhMELKBSxylqJvbVhekY97fXUmlWiMl7dB4beddkgX0maX0yciMPiw)SqKHysXEwaXQgILVQ6dpIHZQJNeXWQ9kInGyjGyyZfqIyT6rmndqSfYPIyxNAooynQfX6YmmGC3eAulM39GOMdtVsYnUSpSHhKETjiruZXbRrT0V6OIJwTM0vNemOs7Y8hqso(wK7MqJAX8Uhe1Cy6vsUXL9Hn8G0RnbjIAooynQLwl9GbPRojyqL2L5pGeiForxhqYN2gnaRfTA0PrUagltgKpNORdi5e8gzyA9y6WijaYKb5Zj66asobVrgMwpMobsZ7JALjdYNt01bK8GWgAulDAeamTDWGmzq(CIUoGKR33wath2lvCxSawMmiForxhqYT7FEqZkmfhlbGK25ptJaitgKpNORdi52kcyvQu3sPvJ2pWK1uMmiForxhqYXzLqQJqHhtB2sqMmiForxhqYx48MNIZBTomqHnZwb8YKb5Zj66as(W8qlEGoEBfzi3nHg1I5DpiQ5W0RKCJl7dB4bPxBcsA1QuY6m8aTw6bdsxDsWGkTlZFajq(CIUoGKB3hNzVHPTAvA1ODvF4j6Y(WgEGlQ54G1OwAT0dgqUFVi21nfMyetZmfXShqSdgirS6O4GeqSQHyxNAooynQfXShqSTue7GbseZAk8iMMfyetJjGyrdX0mipeRFD8Kiw3rrmdX0pwPckIDWajI1p0me76uZXbRrTiwTiMHy4m7jbsetuLNS6VCK7MqJAX8Uhe1Cy6vsUXL9Hn8G0Rnbj1spyGkoA1AsxDsWGkTlZFajx7wPa5DzFydpWf1CCWAulTw6bdeVWL9Hn8aVvRsjRZWd0APhmi3vx)TsbY7Y(WgEG3QvPK1z4bAT0dgK7QRLFPa5H85eDDaj3UpoZEdtB1Q0Qr7Q(Wt8cx2h2Wd8wTkLSodpqRLEWGCxDpKcKhYNt01bK8PTrdWArRgDAKlGXeVWL9Hn8aVvRsjRZWd0APhmihY97fXUo1CCWAulIfyeRwFEi2bdKiw)qZQJIyszR3t6cIfXKIfW1ARaqS6rS8nmRppeRAiMuMJiirmP4pytmIfnelueRF49i2aqmZLfEB4beZueZdgwrmnlWi2028qmmiQLeJydOvpGyAgGyagdRaKIbJyIQ8Kv)fXcmI9GrMhh5Uj0OwmV7brnhMELKBCzFydpi9Atqsw5jPIAooynQLQzpGZkpP0vNKhWGknj0SJxLCTBrUBcnQfZ7EquZHPxj5g8AD4SsPy1umYDtOrTyE3dIAom9kj3CWanuyk9AtqIDFCM9gM2QvPvJ2v9Hh5Uj0OwmV7brnhMELKBMX)1tJPraqUBcnQfZ7EquZHPxj5MUsJArUBcnQfZ7EquZHPxj5MU8(A4nSICh5(9Iyx3LtqCuGeXaxWNhIPXeqmndqmtO1JybgXmxw4THh4i3nHg1ILiQZQWJ7aVh5Uj0Ow8vsUXL9Hn8G0RnbjAmbQwurnhhSg1kD1jbdQ0Um)bKiQYtw9xUOMJdwJA5pmTyXi3nHg1IVsYnUSpSHhKETjirJjq1IkQ54G1OwPRojtlNs7Y8hqIOkpz1F5tywFE0Qr9hrqsjFWMy(dtlwS0rtcGXWka(eM1NhTAu)reKuYhSjMpnP86jooTgFcZ6ZJwnQ)icsk5d2eZjR(lrrvEYQ)YNWS(8OvJ6pIGKs(GnX8hMwS4CKOkpz1F5IAooynQL)W0IfFNex2h2Wd8SYtsf1CCWAulvZEaNvEsK7MqJAXxj5gx2h2WdsV2eKOXeOArf1CCWAuR0vNKPLtPDz(diruLNS6V8(17jDbXsFaxRTcG)W0IflD0KaymScG3VEpPliw6d4ATva8PjLxpXXP149R3t6cIL(aUwBfaNS6Vefv5jR(lVF9EsxqS0hW1ARa4pmTyX5irvEYQ)Yf1CCWAul)HPfl(ojUSpSHh4zLNKkQ54G1OwQM9aoR8Ki3nHg1IVsYncZ7PMqJAP(aRsV2eKekmX0SGqgT7J6dnpK7MqJAXxj5Mz8F90yAeaPJMKXP14IAooynQLtw9xK7MqJAXxj5gch7jdBPvJA3h(sZKoAsK3L9Hn8axJjq1IkQ54G1O27C7wzY0ycuTOKbCNl7dB4bUgtGQfvuZXbRrTYHC3eAul(kj3iQvaR(McK0M3MaYDtOrT4RKCZdwxSeOnVnbmYDtOrT4RKCtRehmqsT7dFOaDa2e5Uj0Ow8vsUP78rlVyjqhEdRi3nHg1IVsYnF015bASuCNjaK7MqJAXxj5gndONDuNLK2Qxai3nHg1IVsYn)zbA1ODvF4LoAsuZdRYBXdy1EfEoS2WdKeBXdy1EfE(dtlwCpTJ3tFqKzpbGQXeKjZL9Hn8axJjq1IkQ54G1O2ECzFydpWf1CCWAul9RoQ4OvRrCCAnUOMJdwJA5Kv)vMmnMavlkza35Y(WgEGRXeOArf1CCWAulXXP14IAooynQLtw9xK7MqJAXxj5gH59utOrTuFGvPxBcse1CCWAulTlZWG0rtI8Q5Hv5)zbA1ODvF45WAdpqs0L9Hn8axJjq1IkQ54G1O27KycnQL)NfOvJ2v9HNlmSs1ycYK5Y(WgEGRXeOArf1CCWAu7DsUvoIx0IhWQ9k8CtOHlqMSXP14IAooynQLF6qUBcnQfFLKBCzFydpi9AtqslEGo8gwPDv5JLG0Um)bKOMhwL)NfOvJ2v9HNdRn8ajrrvEYQ)Y)Zc0Qr7Q(WZFyAXIVtuLNS6V8w8aD4nSYBhVN(GiZEcavJjquEx2h2WdCnMavlQOMJdwJA7XL9Hn8axuZXbRrT0V6OIJwTMmzT4bSAVcp3eA4cKJO8IQ8Kv)L)NfOvJ2v9HN)W0IfFNgtGQfLmazYmHg1Y)Zc0Qr7Q(WZfz2taW9CRCYK5Y(WgEGRXeOArf1CCWAu7DMqJA5T4b6WByL3oEp9brM9eaQgt4krvEYQ)YBXd0H3WkN88Mg1kfy3h(qb(WByfE60Wk8CyTHhijErlEaR2RWZnHgUaIUSpSHh4AmbQwurnhhSg1ENgtGQfLmazYuZdRYBXdy1EfEoS2WdKeBXdy1EfEUj0WfqSfpGv7v45pmTyX3jQYtw9xElEGo8gw5TJ3tFqKzpbGQXeUsuLNS6V8w8aD4nSYjpVPrTsb29HpuGp8gwHNonScphwB4bsK7MqJAXxj5Mw8aD4nSk9bd0(zHhOcdRXsqIBsFWaTAnkbbPe3KoAsKhWyyfaFcZ6ZJwnQ)icsk5d2eZNMuE9YKbymScGpHz95rRg1FebjL8bBI5ZyRNODF4df4dVHv4PtdRWZH1gEGuoIIm7jayjtlNurM9eamXlgNwJNvkfRpysL)GjuIxi)40A8mW0yjqpD8hmHsu(XP14IAooynQLF6ikVj0OwElEyyEppwAZheYuzYmHg1Y7Y7RH3WkpwAZheYuzYmHg1YXI6fzCiNG4OXsqozYu7jakpdmVMX7e6DsYHBjAcnQLJf1lY4qobXrJLGCYr8c5VyCAnEgyASeONo(dMqjEX40A8SsPy9btQ8hmHsCCAnUOMJdwJA5Kv)LO8MqJA5T4HH598yPnFqitLjZeAulVlVVgEdR8yPnFqitLtoK73lIjf)8XsaXKsXdy1EfEPrmPu8aI1R3WkgXShqSdgirmCmdV9(8qmTqmYZhlbe76uZXbRrTCe76EyH38(8KgX0mipeZEaXoyGeX0cXial8MciMuuPiMJ(GjvmI1pdwet8HIrS(H3JyBPi2aqS(gwbseZwseRFOziwVEdRWJy5BdRWlnIPzqEigoRoEseBaigU7bJeXQJIyAHytlw1IfX0maX61ByfEelFByfEeBCAnoYDtOrT4RKCtlEGo8gwL(GbA)SWduHH1yjiXnPpyGwTgLGGuIBshnjT4bSAVcp3eA4cikYSNaG7rIBeL)cx2h2Wd8w8aD4nSs7QYhlbzYgNwJ)NfOvJ2v9HNF6KJO8xy3h(qb(WByfE60Wk8CyTHhiLjBCAn(WByfE60Wk88hMwS47ULNF5ik)fMqJA5T4HH59CiNG4OXsG4fMqJA5D591WByLhlT5dczkXXP14zGPXsGE64NozYmHg1YBXddZ75qobXrJLaXXP14zLsX6dMu5Kv)vMmtOrT8U8(A4nSYJL28bHmL440A8mW0yjqpDCYQ)sCCAnEwPuS(Gjvoz1FLd5Uj0Ow8vsUryEp1eAul1hyv61MGKV6ODzggKoAsgNwJ)NfOvJ2v9HNF6iooTgxuZXbRrTCYQ)IC3eAul(kj34Y(WgEq61MGKUSc2iN0UQ8XsqAxM)asuZdRY)Zc0Qr7Q(WZH1gEGKOOkpz1F5)zbA1ODvF45pmTyX3jQYtw9xExwbBKtAZBtaZBhVN(GiZEcavJjquEx2h2WdCnMavlQOMJdwJA7XL9Hn8axuZXbRrT0V6OIJwTMCeLxuLNS6V8)SaTA0UQp88hMwS470ycuTOKbitMj0Ow(FwGwnAx1hEUiZEcaUNBLtMmx2h2WdCnMavlQOMJdwJAVZeAulVlRGnYjT5TjG5TJ3tFqKzpbGQXei6Y(WgEGRXeOArf1CCWAu7DAmbQwuYaqUBcnQfFLKBeM3tnHg1s9bwLETjibR2sApj9l10OwK7i3nHg1I5MqdxavnpSkwIpCflb6OMdPJMetOHlGclmda3JBehNwJlQ54G1Owoz1FjkVl7dB4bUgtGQfvuZXbRrT9iQYtw9xUpCflb6OMdo55nnQvMmx2h2WdCnMavlQOMJdwJAVtYTYHC3eAulMBcnCbu18WQ4RKCZeuOEPJMKXP14)zbA1ODvF45NoIY3IhWQ9k88hMwS4Eev5jR(lFckupN88Mg1kt2fT4bSAVcp3eA4cKtMmrvEYQ)Y)Zc0Qr7Q(WZFyAXI7rJjq1IsgartOrT8)SaTA0UQp8CrM9ea8DUjtM8IQ8Kv)LpbfQNtEEtJAVZL9Hn8axJjq1IkQ54G1OwzYCzFydpW1ycuTOIAooynQ9oj3khXluZdRY)Zc0Qr7Q(WZH1gEGKO8IQ8Kv)LpbfQNtEEtJAVRfpGv7v45pmTyXYKDHAEyvElEaR2RWZH1gEGuMSlAXdy1EfEUj0WfihYDK73lIDDQ54G1OweRlZWaI19qN9agXSr4dnamI1p0meZqmsWB5jnIPzWIyE7SImaJyXQfIPzaIDDQ54G1Owedd5ZbwbGC3eAulMlQ54G1OwAxMHbj(GqMIPs5hsctyvPJMKXP14IAooynQLtw9xK7MqJAXCrnhhSg1s7YmmCLKBggbA1O6hcPILoAsgNwJlQ54G1Owoz1FrUBcnQfZf1CCWAulTlZWWvsUXhUILaDuZH0rtIj0WfqHfMbG7XnIJtRXf1CCWAulNS6Vi3nHg1I5IAooynQL2Lzy4kj3m8vrsRgvZakSWmpK7MqJAXCrnhhSg1s7YmmCLKBMWS(8OvJ6pIGKs(GnXi3nHg1I5IAooynQL2Lzy4kj30VEpPliw6d4ATvai3Vxetk(5JLaIDDQ54G1OwPrmPu8aI1R3WkgXShqSdgirmTqmcWcVPaIjfvkI5OpysfJy2sIyZyJzCFaX0maXSzDwfXQgIPXeqmChSkIb5eehnwciwPzWJy4oW7XCetkvpIHvBjTNeXKsXdsJysP4beRxVHvmIzpGy16ZdXoyGeX6NblIjfbMglbe76QdXcmIzcnCbiw9iw)myrmdXCe1lYqmHHvelWiwSiw3xeEaJrmBjrmPiW0yjGyxxDiMTKiMuuPiMJ(GjveZEaX2srmtOHlGJyszdndX61ByfEelFByfEeZwsetk5TjGysHVsJysP4beRxVHvmIjSfXmsYqJAnVppeBai2bdKiw)SWdiMuuPiMJ(GjveZwsetkcmnwci21vhIzpGyBPiMj0WfGy2sIygILVkVVgEdRiwGrSyrmndqmlEeZwseZ84cX6NfEaXegwJLaI5iQxKHyGlyrSOHysrGPXsaXUU6qSaJyM)bJmpeZeA4c4i2LzaI5nvHhXmVV6JrmTFHysrLIyo6dMurS8v591WByfJyAHydaXegwrSyrm8riamoQfXSMcpIPzaI5iQxKXrmPWijdnQ18(8qS(HMHy96nScpILVnScpIzljIjL82eqmPWxPrmPu8aI1R3WkgXWz1XtIyBPi2aqSdgirSZ6bmgX61ByfEelFByfEelWiMnQJIyAHyqo7IhqS6rmndEaXShqSz9aIPz2IyWwhcziMukEaX61ByfJyAHyqovyjrSE9gwHhXY3gwHhX0cX0maXGLeXQgIDDQ54G1OwoYDtOrTyUOMJdwJAPDzggUsYnT4b6WByv6dgO9ZcpqfgwJLGe3K(GbA1AuccsjUjD0KiYSNaG7rIBeLxEtOrT8w8aD4nSYfz2taW02BcnQ18xj)40ACrnhhSg1YFyAXIZrJtRXhEdRWtNgwHNtEEtJALlFTOkpz1F5T4b6WByLtEEtJAZrYpoTgxuZXbRrT8hMwSy5Yxl)40A8H3Wk80PHv45KN30O2C0T88lNC9i5wzYUWUp8Hc8H3Wk80PHv45WAdpqkt2fQ5Hv5nVnbATCyTHhiLjBCAnUOMJdwJA5pmTyX3jzCAn(WByfE60Wk8CYZBAuRmzJtRXhEdRWtNgwHN)W0IfF3T88ltgKpNORdi5z51bVM9Grs7)bw7)whMOOkpz1F5z51bVM9Grs7)bw7)whMMd3ERBx)14pmTyX3LF5iooTgxuZXbRrT8thr5VWeAulhlQxKXHCcIJglbIxycnQL3L3xdVHvES0MpiKPehNwJNbMglb6PJF6KjZeAulhlQxKXHCcIJglbIJtRXZkLI1hmPYjR(lr5hNwJNbMglb6PJtw9xzYS7dFOaF4nScpDAyfEoS2WdKYjtMDF4df4dVHv4PtdRWZH1gEGKOAEyvEZBtGwlhwB4bsIMqJA5D591WByLhlT5dczkXXP14zGPXsGE64Kv)L440A8SsPy9btQCYQ)khYDtOrTyUOMJdwJAPDzggUsYn)zbA1ODvF4LoAsgNwJlQ54G1Owoz1FrUFViMuyiMukEaX61ByfXWz1XtIydaXoyGeX0cXSUoFEiwVEdRWJy5BdRWJy9ZcpGycdRXsaXKI9SaIvnelFv1hEeRFgSi2bhlbeRxVHv4rS8THv4LgXKsEBciMu4R0iMTKiw(guOEoIDDRHy16ZdXY3WS(8qSQHyszoIGeXKI)GnXiw(o26rSaJyq(CIUoGuAetZcmI5JfqSaJybHTEGeXgGWoyaXcfX6hEpIHRjOXeWi2d4JxrSyrmcvSeqSy1cXUo1CCWAulI1p0meRb9rmPu8aI1R3WkIjYSNaG5i3nHg1I5IAooynQL2Lzy4kj30IhOdVHvPpyG2pl8avyynwcsCt6OjXUp8Hc8H3Wk80PHv45WAdpqsuEaJHva8jmRppA1O(JiiPKpytmFAs51lt2fagdRa4tywFE0Qr9hrqsjFWMy(m26LJOAEyv(euOEoS2WdKevZdRYBEBc0A5WAdpqsCCAn(WByfE60Wk8CYQ)suE18WQ8)SaTA0UQp8CyTHhijAcnQL)NfOvJ2v9HNd5eehnwcenHg1Y)Zc0Qr7Q(WZHCcIJc0hMwS47ULNJLjtEx2h2WdCnMavlQOMJdwJAVtYTYKnoTgxuZXbRrT8tNCeVqnpSk)plqRgTR6dphwB4bsIxycnQL3L3xdVHvES0MpiKPeVWeAulVfpmmVNhlT5dczQCi3rUBcnQfZf1CCWAulTlZWWvsUryEp1eAul1hyv61MGetOHlGQMhwfJC3eAulMlQ54G1OwAxMHHRKCJOMJdwJAL(GbA1AuccsjUj9bd0(zHhOcdRXsqIBshnjYBcnQLpbfQNhlT5dczkrtOrT8jOq98yPnFqitPpmTyX3j5wE(Lj7ctOrT8jOq98yPnFqitjkQYtw9x(euOE(dtlwSmzxOMhwLpbfQNdRn8aPCeLFCAn(FwGwnAx1hE(PtMSluZdRY)Zc0Qr7Q(WZH1gEGuoK7MqJAXCrnhhSg1s7YmmCLKB6knQf5Uj0OwmxuZXbRrT0Umddxj5MHVksA785HC3eAulMlQ54G1OwAxMHHRKCZaEm8snwci3nHg1I5IAooynQL2Lzy4kj30Ihg(QirUBcnQfZf1CCWAulTlZWWvsUXwbG138uH59i3nHg1I5IAooynQL2Lzy4kj3082eW6hsfKoAsKxE18WQ8M3MaTZurghwB4bsIMqdxafwygaUNRjNmzMqdxafwygaUNCSCehNwJNvkfRpysL)GjuIxy3h(qb(WByfE60Wk8CyTHhirUBcnQfZf1CCWAulTlZWWvsUPlVVgEdRshnjJtRX7Y7lH3Wt(dMqjooTgxuZXbRrT8hMwS4EegwPAmbK7MqJAXCrnhhSg1s7YmmCLKB6Y7RH3WQ0rtY40A8SsPy9btQ8hmHIC3eAulMlQ54G1OwAxMHHRKCtxEFn8gwLoAs6EWfLGGK7ghlQxKrCCAnEgyASeONo(Pd5Uj0OwmxuZXbRrT0Umddxj5MUSc2iN0M3Mag5Uj0OwmxuZXbRrT0Umddxj5gSOErM0rtY40ACrnhhSg1YFyAXI7ryyLQXeiooTgxuZXbRrT8tNmzJtRXf1CCWAulNS6Vi3nHg1I5IAooynQL2Lzy4kj34dxXsGoQ5q6OjzCAnUOMJdwJA5pmTyX3rqqYNwojAcnCbuyHza4ECd5Uj0OwmxuZXbRrT0Umddxj5gY3iulMoEW0mPJMKXP14IAooynQL)W0IfFhbbjFA5K440ACrnhhSg1YpDi3nHg1I5IAooynQL2Lzy4kj3Gf1lYKoAsu7jakpdmVMX7e6DsYHBjQMhwLJb7JLavRJiJdRn8ajYDK7MqJAX8qHjMkQ54G1OwjhmqdfMsV2eKee2qJAPtJaGPTdgqUBcnQfZdfMyQOMJdwJAVsYnhmqdfMsV2eKKLxh8A2dgjT)hyT)BDyPJMKXP14IAooynQLF6iAcnQL3IhOdVHvUiZEcawYTenHg1YBXd0H3Wk)brM9eaQgtOhccs(0YjYDtOrTyEOWetf1CCWAu7vsU5GbAOWu61MGKPTrdWArRgDAKlGXi3nHg1I5HctmvuZXbRrTxj5gHTcWthNwt6dgOvRrjiiL4M0RnbjtBJgG1Iwn60ixaJPImRtHNwliD0KmoTgxuZXbRrT8tNmzMqJA5tqH65XsB(GqMs0eAulFckuppwAZheYu6dtlw8DsULNFK7MqJAX8qHjMkQ54G1O2RKCZbd0qHP0hmqRwJsqqkXnPxBcsS7FEqZkmfhlbGK25ptJaiD0KmoTgxuZXbRrT8tNmzMqJA5tqH65XsB(GqMs0eAulFckuppwAZheYu6dtlw8DsULNFK7MqJAX8qHjMkQ54G1O2RKCZbd0qHP0hmqRwJsqqkXnPHwdekDTjiHG3idtRhthgjbq6OjzCAnUOMJdwJA5NozYmHg1YNGc1ZJL28bHmLOj0Ow(euOEES0MpiKP0hMwS47KClp)i3nHg1I5HctmvuZXbRrTxj5MdgOHctPpyGwTgLGGuIBsdTgiu6AtqcbVrgMwpMobsZ7JALoAsgNwJlQ54G1Ow(PtMmtOrT8jOq98yPnFqitjAcnQLpbfQNhlT5dczk9HPfl(oj3YZpYDtOrTyEOWetf1CCWAu7vsU5GbAOWu6dgOvRrjiiL4M0RnbjdZdT4b64TvKjD0KmoTgxuZXbRrT8tNmzMqJA5tqH65XsB(GqMs0eAulFckuppwAZheYu6dtlw8DsULNFK7MqJAX8qHjMkQ54G1O2RKCZbd0qHP0hmqRwJsqqkXnPxBcsWzLqQJqHhtB2sq6OjzCAnUOMJdwJA5NozYmHg1YNGc1ZJL28bHmLOj0Ow(euOEES0MpiKP0hMwS47KClp)i3nHg1I5HctmvuZXbRrTxj5MdgOHctPpyGwTgLGGuIBsV2eKO33wath2lvCxSaw6OjzCAnUOMJdwJA5NozYmHg1YNGc1ZJL28bHmLOj0Ow(euOEES0MpiKP0hMwS47KClp)i3nHg1I5HctmvuZXbRrTxj5MdgOHctPpyGwTgLGGuIBsV2eKyRiGvPsDlLwnA)atwtPJMKXP14IAooynQLF6KjZeAulFckuppwAZheYuIMqJA5tqH65XsB(GqMsFyAXIVtYT88JC3eAulMhkmXurnhhSg1ELKBoyGgkmL(GbA1AuccsjUj9AtqYcN38uCER1HbkSz2kGx6OjzCAnUOMJdwJA5NozYmHg1YNGc1ZJL28bHmLOj0Ow(euOEES0MpiKP0hMwS47KClp)i3nHg1I5HctmvuZXbRrTxj5MdgOHctPpyGwTgLGGuIBsV2eKmnFR(jqsZG38KyQhi0)ToS0rtY40ACrnhhSg1YpDYKzcnQLpbfQNhlT5dczkrtOrT8jOq98yPnFqitPpmTyX3j5wE(rUJC3eAulMhkmX0SGqgT7J6dnpjcZ7PMqJAP(aRsV2eKekmXurnhhSg1kD0KiVAEyv(FwGwnAx1hEoS2WdKeDzFydpW1ycuTOIAooynQ9ojMqJA5)zbA1ODvF45cdRunMGmzUSpSHh4AmbQwurnhhSg1ENKBLJ4fT4bSAVcp3eA4cKjBCAnUOMJdwJA5NoK7MqJAX8qHjMMfeYODFuFO5DLKBoyGgkmXi3nHg1I5HctmnliKr7(O(qZ7kj3CWanuyk9AtqY02ObyTOvJonYfWyPJMKlG85eDDaj3UpoZEdtB1Q0Qr7Q(Wt0L9Hn8axJjq1IkQ54G1O27Uhi3nHg1I5HctmnliKr7(O(qZ7kj3CWanuyk9AtqIDFCM9gM2QvPvJ2v9Hx6OjXL9Hn8axJjq1IkQ54G1O27KK)RCl)sbUSpSHh4TAvkzDgEGwl9GbK7MqJAX8qHjMMfeYODFuFO5DLKBoyGgkmLETji5lv8hScKuxvrwfLS8EPJMex2h2WdCnMavlQOMJdwJA7XL9Hn8aVw6bduXrRwd5Uj0OwmpuyIPzbHmA3h1hAExj5MdgOHctPxBcsS85eDLcRsx7OH)GLoAsCzFydpW1ycuTOIAooynQThx2h2Wd8APhmqfhTAnK7MqJAX8qHjMMfeYODFuFO5DLKBoyGgkmLETjibNfUGN6c2AsFWhcPJMex2h2WdCnMavlQOMJdwJA7XL9Hn8aVw6bduXrRwd5Uj0OwmpuyIPzbHmA3h1hAExj5MdgOHctPxBcsA1pcssyP1ahKHTuH36lD0K4Y(WgEGRXeOArf1CCWAuBpUSpSHh41spyGkoA1Ai3nHg1I5HctmnliKr7(O(qZ7kj3CWanuykn0AGqPRnbjz2pRneusyAk8H5J7dpYDtOrTyEOWetZccz0UpQp08UsYnhmqdfMsV2eKmnFR(jqsZG38KyQhi0)ToS0rtIl7dB4bUgtGQfvuZXbRrT9ij)5N440ACrnhhSg1YjR(lrx2h2WdCnMavlQOMJdwJA7XL9Hn8aVw6bduXrRwd5Uj0OwmpuyIPzbHmA3h1hAExj5MdgOHctPxBcsSveWQuPULsRgTFGjRP0rtIl7dB4bUgtGQfvuZXbRrT9ij)5N440ACrnhhSg1YjR(lrx2h2WdCnMavlQOMJdwJA7XL9Hn8aVw6bduXrRwd5Uj0OwmpuyIPzbHmA3h1hAExj5MdgOHctPxBcsw48MNIZBTomqHnZwb8shnjUSpSHh4AmbQwurnhhSg12JKRp)ehNwJlQ54G1Owoz1Fj6Y(WgEGRXeOArf1CCWAuBpUSpSHh41spyGkoA1Ai3rUBcnQfZdfMyQV6t7(O(qZtYbd0qHP0RnbjAqcyT(jvuKqoLoAsCzFydpW1ycuTOIAooynQThx2h2Wd8APhmqfhTAnzYuZdRYBXdy1EfEoS2WdKeBXdy1EfE(dtlwCpUSpSHh41spyGkoA1Ai3nHg1I5Hctm1x9PDFuFO5DLKBoyGgkmLgAnqO01MGerEcFPFTHGo8gwLoAsCzFydpW1ycuTOIAooynQThx2h2Wd8APhmqfhTAnzYuZdRYBXdy1EfEoS2WdKeBXdy1EfE(dtlwCpUSpSHh41spyGkoA1Ai3rUBcnQfZ)QJ2LzyqYFwGwnAx1hEK7MqJAX8V6ODzggUsYnnVnbS(HubPJMe5vZdRYBEBc0otfzCyTHhijAcnCbuyHza4ECtMmtOHlGclmda3Z1lhXXP14zLsX6dMu5pycf5Uj0Owm)RoAxMHHRKCtxEFn8gwLoAsgNwJNvkfRpysL)GjuK7MqJAX8V6ODzggUsYnT4b6WByv6dgOvRrjiiL4M0hmq7NfEGkmSglbjUjD0KCH8Q5Hv5nVnbANPImoS2WdKenHgUakSWmaCpxtMmtOHlGclmda3t(LJO8x0IhWQ9k8CtOHlGO8USpSHh4AmbQwurnhhSg12ZTYjhr5VyCAnEgyASeONo(dMqjEX40A8SsPy9btQ8hmHs8IUhCrRwJsqqYBXd0H3Wkr5nHg1YBXd0H3WkxKzpba3JKRjtM8MqJA5DzfSroPnVnbmxKzpba3Je3iQMhwL3LvWg5K282eWCyTHhiLtMm5vZdRYnpKtS(g((gM2oFECyTHhijkQYtw9xo5BeQfthpyAg)bJmp5KjtE18WQCmyFSeOADezCyTHhijQ2tauEgyEnJ3j07KKd3kNCYHC3eAulM)vhTlZWWvsUryEp1eAul1hyv61MGetOHlGQMhwfJC3eAulM)vhTlZWWvsUPlVVgEdRshnjJtRX7Y7lH3Wt(dMqjkmSs1yc3noTgVlVVeEdp5pmTyXehNwJ)NfOvJ2v9HN)W0If3JWWkvJjGC3eAulM)vhTlZWWvsUPfpqhEdRsFWaTAnkbbPe3K(GbA)SWduHH1yjiXnPJMKlKxnpSkV5Tjq7mvKXH1gEGKOj0WfqHfMbG75AYKzcnCbuyHza4EYVCeL)Iw8awTxHNBcnCbeL3L9Hn8axJjq1IkQ54G1O2EUvo5ik)40A8mW0yjqpD8hmHsuE1EcGYZaZRz8oH2JKC4wzYUqnpSkhd2hlbQwhrghwB4bs5Kd5Uj0Owm)RoAxMHHRKCtlEGo8gwL(GbA1AuccsjUj9bd0(zHhOcdRXsqIBshnjxiVAEyvEZBtG2zQiJdRn8ajrtOHlGclmda3Z1KjZeA4cOWcZaW9KF5ik)fT4bSAVcp3eA4cikVl7dB4bUgtGQfvuZXbRrT9CRCYrunpSkhd2hlbQwhrghwB4bsIQ9eaLNbMxZ4Dc9oj5WTeLFCAnEgyASeONo(dMqjEHj0OwowuViJd5eehnwcYKDX40A8mW0yjqpD8hmHs8IXP14zLsX6dMu5pycvoK7MqJAX8V6ODzggUsYnD591WByv6OjP7bxuccsUBCSOErgXXP14zGPXsGE64NoIQ5Hv5yW(yjq16iY4WAdpqsuTNaO8mW8AgVtO3jjhULO8xOMhwL382eODMkY4WAdpqktMj0WfqHfMbGL4MCi3nHg1I5F1r7YmmCLKB6YkyJCsBEBcyPJMKl6EWfLGGK7gVlRGnYjT5TjGjooTgpdmnwc0th)btOi3nHg1I5F1r7YmmCLKBWI6fzshnjQ9eaLNbMxZ4Dc9oj5WTevZdRYXG9XsGQ1rKXH1gEGe5Uj0Owm)RoAxMHHRKCd5BeQfthpyAM0rtIj0WfqHfMbG75Ai3VxetkBgSiMuK9KcdRXsaXKsEBciMJ(HubPrmPu8aI1R3WkgXWz1XtIydaXoyGeX0cXial8MciMuuPiMJ(GjvmIzljIPfIb5uHLeX61ByfEelFByfEoYDtOrTy(xD0Umddxj5Mw8aD4nSk9bd0Q1OeeKsCt6dgO9ZcpqfgwJLGe3KoAsKxnpSkV5Tjq7mvKXH1gEGKOj0WfqHfMbG75AYKzcnCbuyHza4EYVCeLxEx2h2WdCnMavlQOMJdwJA75w5iErlEaR2RWZnHgUa5iooTgpRukwFWKkNS6VeL)c7(WhkWhEdRWtNgwHNdRn8aPmzJtRXhEdRWtNgwHN)W0IfF3T88lhYDtOrTy(xD0Umddxj5MM3Maw)qQG0rtIAEyvEZBtG2zQiJdRn8ajrtOHlGclmda3Z1KjZeA4cOWcZaW9KFK7MqJAX8V6ODzggUsYnT4HH59i3rUBcnQfZXQTK2ts)snnQvsZBtaRFivq6OjrE5vZdRYBEBc0otfzCyTHhijAcnCbuyHza4ECJ4fT4bSAVcp3eA4cKtMmtOHlGclmda3Z1lhXXP14zLsX6dMu5pycf5Uj0OwmhR2sApj9l10O2RKCtxEFn8gwLoAsgNwJNvkfRpysL)GjuIJtRXZkLI1hmPYFyAXIVZeAulVfpmmVNd5eehfOAmbK7MqJAXCSAlP9K0VutJAVsYnD591WByv6OjzCAnEwPuS(Gjv(dMqjkF3dUOeeKC34T4HH59YK1IhWQ9k8CtOHlqMmtOrT8U8(A4nSYJL28bHmvoK7MqJAXCSAlP9K0VutJAVsYnDzfSroPnVnbS0rtIiZEcaUhj5artOHlGclmda3Z1iEHl7dB4bExwbBKtAxv(yjGC3eAulMJvBjTNK(LAAu7vsUPlVVgEdRshnjJtRXZkLI1hmPYFWekr1EcGYZaZRz8oHENKC4wIQ5Hv5yW(yjq16iY4WAdpqIC3eAulMJvBjTNK(LAAu7vsUPlVVgEdRshnjJtRX7Y7lH3Wt(dMqjkmSs1yc3noTgVlVVeEdp5pmTyXi3nHg1I5y1ws7jPFPMg1ELKBAXd0H3WQ0hmqRwJsqqkXnPpyG2pl8avyynwcsCt6OjrE5DzFydpW1ycuTOIAooynQTNBLJ440A8)SaTA0UQp8CYQ)s8Iw8awTxHNBcnCbYr8c18WQCPglPpwcCyTHhijEHl7dB4bElEGo8gwPDv5JLar5LxEtOrT8w8WW8EoKtqC0yjitMj0OwExEFn8gw5qobXrJLGCeLFCAnEgyASeONo(dMqLtozYKxnpSkhd2hlbQwhrghwB4bsIQ9eaLNbMxZ4Dc9oj5WTeLFCAnEgyASeONo(dMqjEHj0OwowuViJd5eehnwcYKDX40A8SsPy9btQ8hmHs8IXP14zGPXsGE64pycLOj0OwowuViJd5eehnwceVWeAulVlVVgEdR8yPnFqitjEHj0OwElEyyEppwAZheYu5KtoK7MqJAXCSAlP9K0VutJAVsYnT4b6WByv6OjrnpSkxQXs6JLahwB4bsIJtRXZatJLa90XFWekXlAXdy1EfEUj0WfquEx2h2WdCnMavlQOMJdwJA7PD8E6dIm7jaunMWvx7k18WQCPglPpwcCyTHhiLjt(luZdRY)Zc0Qr7Q(WZH1gEGuMmrvEYQ)Y)Zc0Qr7Q(WZFyAXI7rJjq1IsgartOrT8)SaTA0UQp8CrM9ea8DUjhrx2h2WdCnMavlQOMJdwJA7rJjq1IsgGCi3nHg1I5y1ws7jPFPMg1ELKB6Y7RH3WQ0rts3dUOeeKC34yr9ImIJtRXZatJLa90XpDevZdRYXG9XsGQ1rKXH1gEGKOApbq5zG51mENqVtsoClr5LxnpSkV5Tjq7mvKXH1gEGKOj0WfqHfMbGL4gXlAXdy1EfEUj0WfiNmzYBcnCbuyHza47UEIxOMhwL382eODMkY4WAdpqkNCi3nHg1I5y1ws7jPFPMg1ELKB6YkyJCsBEBcyPJMe5hNwJNbMglb6PJ)GjuzYK)IXP14zLsX6dMu5pycLO8MqJA5T4b6WByLlYSNaG75wzYuZdRYXG9XsGQ1rKXH1gEGKOApbq5zG51mENqVtsoCRCYjhXlCzFydpW7YkyJCs7QYhlbK7MqJAXCSAlP9K0VutJAVsYncZ7PMqJAP(aRsV2eKycnCbu18WQyK7MqJAXCSAlP9K0VutJAVsYnKVrOwmD8GPzshnjMqdxafwygaUh3qUBcnQfZXQTK2ts)snnQ9kj3imVNAcnQL6dSk9AtqsOWet9vFA3h1hAEi3nHg1I5y1ws7jPFPMg1ELKBWI6fzshnjQ9eaLNbMxZ4Dc9oj5WTevZdRYXG9XsGQ1rKXH1gEGe5(9IyszZGfXKISNuyynwciMuYBtaXC0pKkinIjLIhqSE9gwXigoRoEseBai2bdKiMwigbyH3uaXKIkfXC0hmPIrmBjrmTqmiNkSKiwVEdRWJy5BdRWZrUBcnQfZXQTK2ts)snnQ9kj30IhOdVHvPpyGwTgLGGuIBsFWaTFw4bQWWASeK4M0rtYfUSpSHh4T4b6WByL2vLpwceLxnpSkV5Tjq7mvKXH1gEGKOj0WfqHfMbG75AYKzcnCbuyHza4EUNYruE5DzFydpW1ycuTOIAooynQTNBLJ4fT4bSAVcp3eA4cKJ440A8SsPy9btQCYQ)su(lS7dFOaF4nScpDAyfEoS2WdKYKnoTgF4nScpDAyfE(dtlw8D3YZVCi3VxetkBOzigS1HqgIP2tauS0iwOiwGrmdXiyXIyAHycdRiMuYBtaRFivaXmmI1cVhEelwScgjIvnetkfpmmVNJC3eAulMJvBjTNK(LAAu7vsUP5TjG1pKkiD0KOMhwL382eODMkY4WAdpqs0eA4cOWcZaW9CnzYmHgUakSWmaCp3tK7MqJAXCSAlP9K0VutJAVsYnT4HH59i3nHg1I5y1ws7jPFPMg1ELKBWI6fzjnPPe]] )


end
