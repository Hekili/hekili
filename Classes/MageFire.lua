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
        if Hekili.ActiveDebug then Hekili:Debug( "\n*** Hot Streak (Advance) ***\n    Heating Up:  %.2f\n    Hot Streak:  %.2f\n", state.buff.heating_up.remains, state.buff.hot_streak.remains ) end
    end )

    spec:RegisterStateFunction( "hot_streak", function( willCrit )
        willCrit = willCrit or buff.combustion.up or stat.crit >= 100

        if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK (Cast/Impact) ***\n    Heating Up: %s, %.2f\n    Hot Streak: %s, %.2f\n    Crit: %s, %.2f\n*** HOT STREAK (Cast/Impact) ***\n", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains, willCrit and "Yes" or "No", stat.crit ) end

        if willCrit then
            if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
            elseif buff.hot_streak.down then applyBuff( "heating_up" ) end
            
            if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK END ***\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains ) end
            return true
        end
        
        -- Apparently it's safe to not crit within 0.2 seconds.
        if buff.heating_up.up then
            if query_time - buff.heating_up.applied > 0.2 then
                if Hekili.ActiveDebug then Hekili:Debug( "May not crit; Heating Up was applied %.2f ago, so removing Heating Up..", query_time - buff.heating_up.applied ) end
                removeBuff( "heating_up" )
            else
                if Hekili.ActiveDebug then Hekili:Debug( "May not crit; Heating Up was applied %.2f ago, so ignoring the non-crit impact.", query_time - buff.heating_up.applied ) end
            end
        end

        if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK END ***\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f\n***", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains ) end
    end )


    --[[
    spec:RegisterVariable( "combustion_on_use", function ()
        return equipped.manifesto_of_madness or equipped.gladiators_badge or equipped.gladiators_medallion or equipped.ignition_mages_fuse or equipped.tzanes_barkspines or equipped.azurethos_singed_plumage or equipped.ancient_knot_of_wisdom or equipped.shockbiters_fang or equipped.neural_synapse_enhancer or equipped.balefire_branch
    end )

    spec:RegisterVariable( "font_double_on_use", function ()
        return equipped.azsharas_font_of_power and variable.combustion_on_use
    end )

    -- Items that are used outside of Combustion are not used after this time if they would put a trinket used with Combustion on a sharded cooldown.
    spec:RegisterVariable( "on_use_cutoff", function ()
        return 20 * ( ( variable.combustion_on_use and not variable.font_double_on_use ) and 1 or 0 ) + 40 * ( variable.font_double_on_use and 1 or 0 ) + 25 * ( ( equipped.azsharas_font_of_power and not variable.font_double_on_use ) and 1 or 0 ) + 8 * ( ( equipped.manifesto_of_madness and not variable.font_double_on_use ) and 1 or 0 )
    end )

    -- Combustion is only used without Worldvein Resonance or Memory of Lucid Dreams if it will be available at least this many seconds before the essence's cooldown is ready.
    spec:RegisterVariable( "hold_combustion_threshold", function ()
        return 20
    end )

    -- This variable specifies the number of targets at which Hot Streak Flamestrikes outside of Combustion should be used.
    spec:RegisterVariable( "hot_streak_flamestrike", function ()
        if talent.flame_patch.enabled then return 2 end
        return 99
    end )

    -- This variable specifies the number of targets at which Hard Cast Flamestrikes outside of Combustion should be used as filler.
    spec:RegisterVariable( "hard_cast_flamestrike", function ()
        if talent.flame_patch.enabled then return 3 end
        return 99
    end )

    -- Using Flamestrike after Combustion is over can cause a significant amount of damage to be lost due to the overwriting of Ignite that occurs when the Ignite from your primary Combustion target spreads. This variable is used to specify the amount of time in seconds that must pass after Combustion expires before Flamestrikes will be used normally.
    spec:RegisterVariable( "delay_flamestrike", function ()
        return 25
    end )

    -- With Kindling, Combustion's cooldown will be reduced by a random amount, but the number of crits starts very high after activating Combustion and slows down towards the end of Combustion's cooldown. When making decisions in the APL, Combustion's remaining cooldown is reduced by this fraction to account for Kindling.
    spec:RegisterVariable( "kindling_reduction", function ()
        return 0.2
    end )

    spec:RegisterVariable( "time_to_combustion", function ()
        local out = ( talent.firestarter.enabled and 1 or 0 ) * firestarter.remains + ( cooldown.combustion.remains * ( 1 - variable.kindling_reduction * ( talent.kindling.enabled and 1 or 0 ) ) - action.rune_of_power.execute_time * ( talent.rune_of_power.enabled and 1 or 0 ) ) * ( not cooldown.combustion.ready and 1 or 0 ) * ( buff.combustion.down and 1 or 0 )

        if essence.memory_of_lucid_dreams.major and buff.memory_of_lucid_dreams.down and cooldown.memory_of_lucid_dreams.remains - out <= variable.hold_combustion_threshold then
            out = max( out, cooldown.memory_of_lucid_dreams.remains )
        end

        if essence.worldvein_resonance.major and buff.worldvein_resonance.down and cooldown.worldvein_resonance.remains - out <= variable.hold_combustion_threshold then
            out = max( out, cooldown.worldvein_resonance.remains )
        end

        return out
    end )

    spec:RegisterVariable( "fire_blast_pooling", function ()
        return talent.rune_of_power.enabled and cooldown.rune_of_power.remains < cooldown.fire_blast.full_recharge_time and ( variable.time_to_combustion > action.rune_of_power.full_recharge_time ) and ( cooldown.rune_of_power.remains < time_to_die or action.rune_of_power.charges > 0 ) or variable.time_to_combustion < action.fire_blast.full_recharge_time and variable.time_to_combustion < time_to_die
    end )

    spec:RegisterVariable( "phoenix_pooling", function ()
        return talent.rune_of_power.enabled and cooldown.rune_of_power.remains < cooldown.phoenix_flames.full_recharge_time and ( variable.time_to_combustion > action.rune_of_power.full_recharge_time ) and ( cooldown.rune_of_power.remains < time_to_die or action.rune_of_power.charges > 0 ) or variable.time_to_combustion < action.phoenix_flames.full_recharge_time and variable.time_to_combustion < time_to_die
    end ) 
    --]]


    
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
                if time == 0 then return false, "no fire_blast out of combat" end

                if settings.no_scorch_blast and action.scorch.executing and ( ( talent.searing_touch.enabled and target.health_pct < 30 ) or ( buff.combustion.up and buff.combustion.remains >= buff.casting.remains ) ) then
                    return "fire_blast during critical scorches are disabled"
                end

                return true
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
                    return time > 0 or not prev_gcd[1].pyroblast, "time is " .. time .. " or prev cast was pyro: " .. tostring( prev_gcd[1].pyroblast )
                end
                return true
            end,

            handler = function ()
                if hardcast then removeStack( "pyroclasm" )
                else removeBuff( "hot_streak" ) end
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


    spec:RegisterSetting( "pyroblast_pull", false, {
        name = "Allow |T135808:0|t Pyroblast Hardcast Pre-Pull",
        desc = "If checked, the addon will recommend an opener |T135808:0|t Pyroblast against bosses, if included in the current priority.",
        type = "toggle",
        width = 3,
    } )
    
    spec:RegisterSetting( "prevent_hardcasts", false, {
        name = "Prevent |T135808:0|t Pyroblast and |T135812:0|t Fireball Hardcasts While Moving",
        desc = "If checked, the addon will not recommend |T135808:0|t Pyroblast or |T135812:0|t Fireball if they have a cast time and you are moving.\n\n" ..
            "Instant |T135808:0|t Pyroblasts will not be affected.",
        type = "toggle",
        width = 3
    } )

    spec:RegisterSetting( "no_scorch_blast", true, {
        name = "Prevent |T135827:0|t Fire Blast During Critical |T135827:0|t Scorch Casts",
        desc = "If checked, the addon will not recommend |T135827:0|t Fire Blast during any of your |T135827:0|t Scorch casts that are expected to critically strike.\n\n" ..
            "This will override the priority's logic that allows for some interwoven Blaster Master refreshes that tend to confuse users.",
        type = "toggle",
        width = 3
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



    spec:RegisterPack( "Fire IV", 20200204.1, [[diKjyaqiLQ4rkvLnrPmkvv5uQQQxHqnlvvUfcIAxe9leLHrPQJrHwgI4zusnnkv4AkvvBJsL8neuzCiQ05OuPwhLkQMNsv6EkL9HahKsfLfIi9qeezJuQiNerfRuvXnrqYovvAOiOyPii4PQYuriBfbvTxG)kYGj1HLSybpgQjdPlJAZK8zky0q0PvSAee61iQA2I62kz3Q8BQgofTCqpNW0L66cTDkjFhcJhbPopLy9iO08vQSFKgyeqe4Hwnd(sI9KyV9wBTrPr7YOrsiCGxBXKbpZct(YadExTyWZonqMQjhcp4zwwYEHcic8eEeIzWdz3Mc7CYiBWwiKTINtiX(ImWleNCtohiaEOvZGVKypj2BV1wBuA0UmA0iHd8QyJ0HGh5GTqit455euTDwSr6qb4HCqr5deapuwGbV9r12PbYunHQmW0p7JQjTemkv7kfvtoylunHNNtq1MWXHtBrs)SpQMqvqmsQ2AJ)OAsSNe7bV8iAbGiWdLvvm3aIaFncic8kCp(bEypEndfMCodE8vHmJcif0GVKaic84Rczgfqk4HHtZWPapS7zuhXjX(kef94NeYfQfWRW94h4bJhNCvY0rWqqd(AnGiWJVkKzuaPGhgondNc8WUNrDeNe7Rqu0JFsixOwaVc3JFG3Ixo0sYvPCepOjuixlbObFTdarGhFviZOasbpmCAgof4fIkLe7Rqu0JFsuhXbEfUh)aVOGttZlbObF3pGiWJVkKzuaPGhgondNc8(JQ3dv3vMVwcJhNCvY0rWqjFviZOu9UDuDiQusy84KRsMocgkJMu9)uTnQ(pQg7Eg1rCsSVcrrp(jHCHAHQ3TJQXUNrDeNe7Rqu0JFsiVQ5eunbBuTDSFQ(FWRW94h4T4MDiObFTlarGhFviZOasbVOGtiqozoHlrpNbWxJGhgondNc8(JQ3dvZcbFywU4LdTKCvkhXdAcfY1sixfHOdP6D7O6quPKlE5qljxLYr8GMqHCTeYOjvVBhvJDpJ6io5Ixo0sYvPCepOjuixlHeYRAobvtavB04(P6)PABu9Fu9EO6UY81Yf3SdL8vHmJs172r1y3ZOoItU4MDOeYRAobv)p4ffCYvQKbmk4RrWRW94h4H9vik6Xpqd(s4aebE8vHmJcif8kCp(bEiTyYWgjKl0ec4iAeWYuaEy40mCkWlevkj2xHOOh)KrtQ2gvx4E8tQgiNc5s0smYcAGfu9gvBpvBJQlCp(jvdKtHCjAjKXilObo1ZIPAcOAdyu5Qi0G3vlg8qAXKHnsixOjeWr0iGLPa0GVKlGiWJVkKzuaPGhgondNc8uXCobzmYcAGt9SyQEVunjGxH7XpWdgpo5QKPJGHGg81UbebE8vHmJcif8WWPz4uGhgzbnWIKcw4E8RYunbBunjs7g8kCp(bEMiD(gcDsLRflan4Rr7bebE8vHmJcif8WWPz4uG3EO6UY81svUwCYSAmsjFviZOuTnQ(pQoevkj2xHOOh)KrtQ2gvx4ESIt8XRHfunbBun5s172r1HOsjX(kef94Ne1rCuTnQUW9yfN4JxdlOAc2O69t1)t12O6quPKi9ojAixKxgnbVc3JFGNkxlw0WH8mObFnAeqe4XxfYmkGuWddNMHtbEDL5RLQCT4Kz1yKs(QqMrPABu9FuDiQusSVcrrp(jJMuTnQUW9yfN4JxdlOAc2OARP6D7O6quPKyFfIIE8tI6ioQ2gvx4ESIt8XRHfunbBunju9)uTnQoevkjsVtIgYf5LrtWRW94h4PY1IfnCipdAWxJKaic84Rczgfqk4HHtZWPaVquPKMwGooxILmAs12O6)O6quPKyFfIIE8tc5vnNGQjGQdrLsAAb64CjwsiVQ5eu9UDuDiQusSVcrrp(jrDehvBJQXUNrDeNe7Rqu0JFsiVQ5eunbuDiQustlqhNlXsc5vnNGQjMQTMQ)NQTr1)r1HOsjHXJtUkz6iyOeYRAobvtavhIkL00c0X5sSKqEvZjO6D7O69q1DL5RLW4XjxLmDemuYxfYmkvVBhv3vMVwcJhNCvY0rWqjFviZOuTnQoevkjmECYvjthbdLOoIJQTr1y3ZOoItcJhNCvY0rWqjKx1CcQMaQoevkPPfOJZLyjH8QMtq1et1wt1)dEfUh)aptlqpKlrdAWxJwdic84Rczgfqk4HHtZWPaVquPKi9ojAixKxgnbVc3JFGNPfOhYLObn4Rr7aqe4XxfYmkGuWddNMHtbEfUhR4eF8AybvtWgvBnvBJQ7zXP2tOdt1eSr1Kl4v4E8d8YJvZzif8va0GVg3pGiWJVkKzuaPGhgondNc8crLsI9vik6Xpz0KQTr1HOsjX(kef94NeYRAobvVxQ2i4v4E8d8qHLb)ePaKRgjObFnAxaIap(QqMrbKcEy40mCkWRW9yfN4JxdlOAc2OARbVc3JFGhkSm4NifGC1ibn4RrchGiWJVkKzuaPGxuWjeiNmNWLONZa4RrWddNMHtbEHOsjrYvpNHu0ugnbVOGtUsLmGrbFncEfUh)ap1a5uixIg0GVgjxarGxH7XpWdfwg8tKcqUAKGhFviZOasbn4Rr7gqe4XxfYmkGuWddNMHtbEDL5RLcUGZzi1EeJuYxfYmkvBJQ7cAGBjsUYnsPjUP69s1wBpvBJQ7cAGBzplo1EcDyQMaQgxIo1ZIbVc3JFGNa7qmsqd(sI9aIap(QqMrbKcErbNqGCYCcxIEodGVgbpmCAgof41ZItTNqhMQ3lvx4E8tkWoeJuIlrdErbNCLkzaJc(Ae8kCp(bEQbYPqUenObFjXiGiWJVkKzuaPGhgondNc8crLsI9vik6XpjQJ4aVc3JFGNAGCOYzqd(scjaIaVLB1CgapJGxH7XpWtGDigj4XxfYmkGuqdAWZeYyFfQgqe4RrarGxH7XpWRG4640CnNZmUbp(QqMrbKcAWxsaebE8vHmJcif8WWPz4uGxiQuYqUiSZzifkiCyOe1rCGxH7XpWlKlc7CgsHcchgcAWxRbebEfUh)aptVh)ap(QqMrbKcAWx7aqe4v4E8d8mTa9qUen4XxfYmkGuqdAqdEwXqX4h4lj2tI92tI92H0i4HOG3CgeGh5SmDyZOunjuDH7XpQopIwiPFaptORMmdE7JQTtdKPAcvzGPF2hvtAjyuQ2vkQMCWwOAcppNGQnHJdN2IK(zFunHQGyKuT1g)r1Kypj2t)q)u4E8tinHm2xHQ3kiUoonxZ5mJB6Nc3JFcPjKX(ku9wixe25mKcfeom83O2crLsgYfHDodPqbHddLOoIJ(PW94NqAczSVcvVz694h9tH7XpH0eYyFfQEZ0c0d5s00p0pfUh)eeVrg2JxZqHjNZ0pfUh)eeVrgmECYvjthbd)nQnS7zuhXjX(kef94NeYfQf6Nc3JFcI3iBXlhAj5QuoIh0ekKRL43O2WUNrDeNe7Rqu0JFsixOwOFkCp(jiEJSOGttZlXVrTfIkLe7Rqu0JFsuhXr)u4E8tq8gzlUzh(BuB)TNUY81sy84KRsMocgk5RczgD3UquPKW4XjxLmDemugn)32Fy3ZOoItI9vik6XpjKlul72HDpJ6ioj2xHOOh)KqEvZjiyZo2))0pfUh)eeVrg2xHOOh)(ffCcbYjZjCj65mSz8xuWjxPsgWOBg)nQT)2dle8Hz5Ixo0sYvPCepOjuixlHCveIoC3UquPKlE5qljxLYr8GMqHCTeYO5UDy3ZOoItU4LdTKCvkhXdAcfY1siH8QMtqGrJ7)FB)TNUY81Yf3SdL8vHmJUBh29mQJ4KlUzhkH8QMt8p9tH7XpbXBKffCAAE97QfVH0IjdBKqUqtiGJOraltXVrTfIkLe7Rqu0JFYOPTc3JFs1a5uixIwIrwqdSyZEBfUh)KQbYPqUeTeYyKf0aN6zXeyaJkxfHM(zFuDH7XpbXBKH0IjdBKqUqtiGJOraltXVrTfIkLe7Rqu0JFYOPnS7zuhXjvdKtHCjAjgzbnWIn7T9NjKTsAuQgiNc5s0eBczRKKivdKtHCjAInHSvsRLQbYPqUenbBK8p9tH7XpbXBKbJhNCvY0rWWFJAtfZ5eKXilObo1ZI3lj0p7JQlCp(jiEJmy84KRsMocg(BuByKf0alskyH7XVktWMrPDVFB4s07TNfNApHom9tH7XpbXBKzI05Bi0jvUwS43O2WilObwKuWc3JFvMGnsK2n9tH7XpbXBKPY1IfnCip)BuB7PRmFTuLRfNmRgJuYxfYmQT)crLsI9vik6Xpz00wH7XkoXhVgwqWg5UBxiQusSVcrrp(jrDeNTc3JvCIpEnSGGT9)VTquPKi9ojAixKxgnPFkCp(jiEJmvUwSOHd55FJARRmFTuLRfNmRgJuYxfYmQT)crLsI9vik6Xpz00wH7XkoXhVgwqWM172fIkLe7Rqu0JFsuhXzRW9yfN4JxdliyJK)TfIkLeP3jrd5I8YOj9Z(OAYrr1es(kef94hv7qQMqiEmv7kQMW4iyivpcQghHq(6SfQ(8MQlCpwX)O6qSPAetot1bMQlRQjxHmt1bw5qMQBKmvtySaDCUelQoevkQgHhZOuDplMQ9y)JQRdLQT4rQ2VSfQgzzft1(XuTOlm5PAxr1eglqhNlX6hvBXJuTaPhZOunspJs1tt1XRNmv3izQMqYxHOOh)OAhs1ecXJPAxr1eghbdP6rq1rtj9tH7XpbXBKzAb6HCj6FJAlevkPPfOJZLyjJM2(levkj2xHOOh)KqEvZjiievkPPfOJZLyjH8QMtSBxiQusSVcrrp(jrDeNnS7zuhXjX(kef94NeYRAobbHOsjnTaDCUeljKx1CcIT(FB)fIkLegpo5QKPJGHsiVQ5eeeIkL00c0X5sSKqEvZj2TBpDL5RLW4XjxLmDemuYxfYm6UDDL5RLW4XjxLmDemuYxfYmQTquPKW4XjxLmDemuI6ioBy3ZOoItcJhNCvY0rWqjKx1CcccrLsAAb64CjwsiVQ5eeB9)0pfUh)eeVrMPfOhYLO)nQTquPKi9ojAixKxgnPFkCp(jiEJS8y1CgsbFf(nQTc3JvCIpEnSGGnRT1ZItTNqhMGnYL(PW94NG4nYqHLb)ePaKRg5VrTfIkLe7Rqu0JFYOPTquPKyFfIIE8tc5vnNyVgPFkCp(jiEJmuyzWprka5Qr(BuBfUhR4eF8AybbBwt)u4E8tq8gzQbYPqUe9VOGtiqozoHlrpNHnJ)Ico5kvYagDZ4VrTfIkLejx9Cgsrtz0K(PW94NG4nYqHLb)ePaKRgj9tH7XpbXBKjWoeJ83O26kZxlfCbNZqQ9igPKVkKzuBDbnWTejx5gP0e371A7T1f0a3YEwCQ9e6WeGlrN6zX0pfUh)eeVrMAGCkKlr)lk4ecKtMt4s0ZzyZ4VOGtUsLmGr3m(BuB9S4u7j0H3BH7XpPa7qmsjUen9tH7XpbXBKPgihQC(3O2crLsI9vik6XpjQJ4OFkCp(jiEJmb2HyK)wUvZzyZi4jmzm4RDznObnaa]] )
    
    spec:RegisterPack( "Fire", 20200401, [[d4ugOcqieIhPurDjLksAtufFcvsOrrvPtrvXQuQIELsjZcH6wuvr7IOFPuQHPq1XevAzkvPNHkPMgvvW1uQW2uQc(gvvOgNsvOZrvL06qLaMNsvDpuX(uQ0brLeSqrv9qujPjIkjYfPQsO2iQe6JOsG0irLGojvvcwPOIxsvLqMPsfPUPsfXofv5NOsGAOkvKyPOsG4POQPQq5Quvj6ROsIAVI8xKgmkhMYIL0JjmzeDzOnlXNrWOfLtlSAQQqEnvvnBQCBfTBv(TudxbhNQk1Yv1ZbnDsxxjBNQ03vkgpcPZJk16rLO5Rq2pWPCtJL4jnft5T3X374J7hgpx547r)GF847iXRCpGj(bt4Vrat8NnXepxmEmXpyC7AJmnwIh2RxGj(mvhGCb2EBcHMTQsrp3ggZLZ0OpXBfDBymfBN4RRWP(fUunXtAkMYBVJV3Xh3pmEUYX3J(b)4X9djEBPz9N45JjxnXNfKK4LQjEseks87mGXfJhbSDIrab5SZawMQdqUaBVnHqZwvPONBdJ5YzA0N4TIUnmMITb5SZagxHHpCawUedy7D89ooihqo7mGXvZSJac5caYzNbm)eW8lHiGPXePAtjdeWEtZWhW0m7am1EcOk1yIuTPKbcyL(bmNbv)eII(ibmRgUq5gWwqJacLGC2zaZpbm)YbstraZ1ecbG9ixaaBNEjcsaJR0J2ekb5SZaMFcy70DdXdWegubSh97v84epfcyL(bmUApRlOg9by(gsusmGr2hxrfWYAhjGfkGv6hWmaR8imdW2jOI9dycdQ(it8UaQW0yj(qXjK66n0Hp6puUtJLYl30yjE8SQdjt5N4nHg9L41GeHA)tQOjrIM4fFO4hwI3R9HvDOuJjs1Mk6zDb1OpaBxaZR9HvDOSp6cIuXs7sjXF2et8AqIqT)jv0KirtAkV9MglXJNvDizk)eVj0OVeVGBHR1VVqqRodQjEXhk(HL49AFyvhk1yIuTPIEwxqn6dW2fW8AFyvhk7JUGivS0Uus8yPGcLE2et8cUfUw)(cbT6mOM0KM4f9SUGA0hDiZGyASuE5MglXJNvDizk)eV4df)Ws81vPif9SUGA0NKS3CjEtOrFjExqitHu)OfjHjEAst5T30yjE8SQdjt5N4fFO4hwIVUkfPON1fuJ(KK9MlXBcn6lXxnc0Uq1pe(dtAkpUonwIhpR6qYu(jEXhk(HL4nHgErkE4mqiGTlGLlG5bWQRsrk6zDb1OpjzV5s8MqJ(s8UWBCeO1EwtAkp)qASeVj0OVeF11njTlundP4HtUt84zvhsMYpPP82rASeVj0OVe)eN9ZnTlu3seKuYhTjmXJNvDizk)KMYBpKglXBcn6lXVPFhPxmo6JW(StGjE8SQdjt5N0uE(XPXs84zvhsMYpXVGiDtw4qQWGACes5LBIx8HIFyjErM9eqiGTlhalxaZdG5lG5lGzcn6twIhPvNbvPiZEciKwEtOrFMdW2cW8fWQRsrk6zDb1Op5JtloiG5NawDvkYQZGk(0Pbv8LKR30OpaZhaBNkGj62r2BozjEKwDguLKR30OpaZpbmFbS6QuKIEwxqn6t(40Idcy(ay7ubmFbS6QuKvNbv8PtdQ4ljxVPrFaMFcyJl3bG5dG5dGTlhaBCaB0iaJiaMXL4hkkRodQ4tNguXxINvDijGnAeGreatnhEQS4Sjs7tINvDijGnAeGvxLIu0Z6cQrFYhNwCqaBFoawDvkYQZGk(0Pbv8LKR30OpaB0iaRUkfz1zqfF60Gk(YhNwCqaBFaBC5oaSrJam0VxXWaskZ4EaFn7rJKU5dOU5TbiG5bWeD7i7nNmJ7b81Shns6MpG6M3gGuUE8XZ1pSx5JtloiGTpGTdaZhaZdGvxLIu0Z6cQrFY1aG5bW8fWicGzcn6tcf9lYKirrXsJJaG5bWicGzcn6toW93vNbvzC0IliKPaMhaRUkfzgAACeORb5AaWgncWmHg9jHI(fzsKOOyPXraW8ay1vPiZALc1hn)LK9MdW8ay(cy1vPiZqtJJaDnij7nhGnAeGzCj(HIYQZGk(0Pbv8L4zvhscy(ayJgbygxIFOOS6mOIpDAqfFjEw1HKaMhatnhEQS4Sjs7tINvDijG5bWmHg9jh4(7QZGQmoAXfeYuaZdGvxLImdnnoc01GKS3CaMhaRUkfzwRuO(O5VKS3CaMpj(fePDPqjiit5LBI3eA0xIVepsRodQjnL3EmnwIhpR6qYu(jEXhk(HL4RRsrk6zDb1OpjzV5s8MqJ(s8)6qAxOd9g8tAkp)AASepEw1HKP8t8lis3KfoKkmOghHuE5M4nHg9L4lXJ0QZGAIx8HIFyjEJlXpuuwDguXNonOIVepR6qsaZdG5lGHqiEcuoXz)Ct7c1TebjL8rBcLtZpQFaB0iaJiagcH4jq5eN9ZnTlu3seKuYhTjuoJRFaZhaZdGPMdpvorf7xINvDijG5bWuZHNkloBI0(K4zvhscyEaS6QuKvNbv8PtdQ4lj7nhG5bW8fWuZHNk)1H0Uqh6n4lXZQoKeW8ayMqJ(K)6qAxOd9g8LirrXsJJaG5bWmHg9j)1H0Uqh6n4lrIIILI0hNwCqaBFaBC5EaWgncW8fW8AFyvhk1yIuTPIEwxqn6dW2NdGnoGnAeGvxLIu0Z6cQrFY1aG5dG5bWicGPMdpv(RdPDHo0BWxINvDijG5bWicGzcn6toW93vNbvzC0IliKPaMhaJiaMj0OpzjESAoNmoAXfeYuaZNKMYl3XtJL4XZQoKmLFI3eA0xIxyoh1eA0h1fqnX7cOspBIjEtOHxKQMdpfM0uE5MBASepEw1HKP8t8lis3KfoKkmOghHuE5M4fFO4hwI3xaZxaZeA0NCIk2VmoAXfeYuaZdGzcn6torf7xghT4cczk9XPfheW2NdGnUChaMpa2Oragram1C4PYjQy)s8SQdjbmpaMVagcH4jq5eN9ZnTlu3seKuYhTjuon)O(bSrJaS6QuKzTsH6JM)YhnHcyJgbyMqJ(Kqr)ImjsuuS04iayEamtOrFsOOFrMejkkwksFCAXbbS9bSXL7aWgncWmHg9jh4(7QZGQejkkwACeampaMj0Op5a3FxDguLirrXsr6JtloiGTpGnUChaMpaMpaMhaZxaRUkf5VoK2f6qVbF5AaWgncWicGPMdpv(RdPDHo0BWxINvDijG5tIFbrAxkuccYuE5M4nHg9L4f9SUGA0xst5L7EtJL4nHg9L4hAn6lXJNvDizk)KMYlxUonwI3eA0xIV66MKwwp3jE8SQdjt5N0uE56hsJL4nHg9L4R4dX3)4iK4XZQoKmLFst5L7osJL4nHg9L4lXJvx3KjE8SQdjt5N0uE5UhsJL4nHg9L4TtGq9nhvyoxIhpR6qYu(jnLxU(XPXs84zvhsMYpXl(qXpSeVVaMVaMAo8uzXztKoyQitINvDijG5bWmHgErkE4mqiGTlGTxaZhaB0iaZeA4fP4HZaHa2Ua2EaW8bW8ay1vPiZALc1hn)LpAcfW8ayebWmUe)qrz1zqfF60Gk(s8SQdjt8MqJ(s8fNnrO(H)yst5L7EmnwIhpR6qYu(jEXhk(HL4RRsroW93cNbNYhnHcyEaS6QuKIEwxqn6t(40Idcy7cycdQunMyI3eA0xIFG7VRodQjnLxU(10yjE8SQdjt5N4fFO4hwIVUkfzwRuO(O5V8rtOjEtOrFj(bU)U6mOM0uE7D80yjE8SQdjt5N4fFO4hwIF4rVuccszUsOOFrgG5bWQRsrMHMghb6AqUgs8MqJ(s8dC)D1zqnPP82BUPXs8MqJ(s8dznEbrPfNnryIhpR6qYu(jnL3E3BASepEw1HKP8t8Ipu8dlXxxLIu0Z6cQrFYhNwCqaBxatyqLQXebmpawDvksrpRlOg9jxda2OrawDvksrpRlOg9jj7nhG5bWeD7i7nNu0Z6cQrFYhNwCqaBFatyqLQXet8MqJ(s8qr)ISKMYBVCDASepEw1HKP8t8Ipu8dlXxxLIu0Z6cQrFYhNwCqaBFaJGGuonIcyEamtOHxKIhodecy7cy5M4nHg9L4DH34iqR9SM0uE71pKglXJNvDizk)eV4df)Ws81vPif9SUGA0N8XPfheW2hWiiiLtJOaMhaRUkfPON1fuJ(KRHeVj0OVep5Be6dsRpAAwst5T3DKglXJNvDizk)eV4df)Ws8Q9eqvMHMtZKdcfW2NdGX1JdyEam1C4PsiAFCeOAVezs8SQdjt8MqJ(s8qr)ISKM0eVj0WlsvZHNctJLYl30yjE8SQdjt5N4fFO4hwI3eA4fP4HZaHa2UawUaMhaRUkfPON1fuJ(KK9MdW8ay(cyETpSQdLAmrQ2urpRlOg9by7cyIUDK9Mt6cVXrGw7zvsUEtJ(aSrJamV2hw1HsnMivBQON1fuJ(aS95ayJdy(K4nHg9L4DH34iqR9SM0uE7nnwIhpR6qYu(jEXhk(HL49AFyvhk1yIuTPIEwxqn6dW2NdGnoGnAeG5lGvxLI8xhs7cDO3GVCnayJgbyIUDK9Mt(RdPDHo0BWx(40Idcy7cyAmrQ2uYabmpaMj0Op5VoK2f6qVbFPiZEcieW2hWYfWgncWicGPMdpv(RdPDHo0BWxINvDijG5dG5bW8fWeD7i7nNCIk2VKC9Mg9by7dyETpSQdLAmrQ2urpRlOg9byJgbyAmrQ2uYabS9bmV2hw1HsnMivBQON1fuJ(amFs8MqJ(s8tuX(tAkpUonwIhpR6qYu(jEXhk(HL4vZHNknhsuO(gKlniTSEUL4zvhscyEamFbS6QuKIEwxqn6ts2BoaZdGreaRUkfzwRuO(O5V8rtOa2OrawDvksrpRlOg9jxdaMhaZeA0NSepsRodQsrM9eqiGTpGzcn6twIhPvNbv50ikvKzpbecyEamIay1vPiZALc1hn)LpAcfW8jXBcn6lXt(gH(G06JMML0KM4dfNqAwqiJo8r)HYDASuE5MglXJNvDizk)eV4df)Ws8ETpSQdLAmrQ2urpRlOg9by7ZbWgpXBcn6lXlmNJAcn6J6cOM4DbuPNnXeFO4esf9SUGA0xst5T30yjEtOrFj(fePHItyIhpR6qYu(jnLhxNglXJNvDizk)eVj0OVe)0UOGqTPDHonYdHWeV4df)Ws8ebWq)EfddiP04syM9gKw6tPDHo0BWhW8ayETpSQdLAmrQ2urpRlOg9by7dy7Xe)ztmXpTlkiuBAxOtJ8qimPP88dPXs84zvhsMYpXBcn6lXBCjmZEdsl9P0Uqh6n4N4fFO4hwI3R9HvDOuJjs1Mk6zDb1OpaBFoa2oaSTaSC3bGTNaMx7dR6qzPpLs2RQdP9rxqmXF2et8gxcZS3G0sFkTl0HEd(jnL3osJL4XZQoKmLFI3eA0xI)Bv8lOIKuVDt2nLSDUeV4df)Ws8ETpSQdLAmrQ2urpRlOg9by7cyETpSQdL9rxqKkwAxkj(ZMyI)Bv8lOIKuVDt2nLSDUKMYBpKglXJNvDizk)eVj0OVeV53RyOv8u6zlnClyIx8HIFyjEV2hw1HsnMivBQON1fuJ(aSDbmV2hw1HY(OlisflTlLe)ztmXB(9kgAfpLE2sd3cM0uE(XPXs84zvhsMYpXBcn6lXdZcV4t9IxpPp6crIx8HIFyjEV2hw1HsnMivBQON1fuJ(aSDbmV2hw1HY(OlisflTlLe)ztmXdZcV4t9IxpPp6crst5ThtJL4XZQoKmLFI3eA0xIV0FnijXJ2vyqg2rfoBtIx8HIFyjEV2hw1HsnMivBQON1fuJ(aSDbmV2hw1HY(OlisflTlLe)ztmXx6VgKK4r7kmid7OcNTjPP88RPXs84zvhsMYpXBcn6lXNz)SVqqjXPP4hMl4s8t8yPGcLE2et8z2p7leusCAk(H5cUe)KMYl3XtJL4XZQoKmLFI3eA0xIFAUs)tKKMHV5iHuhsyZBdWeV4df)Ws8ETpSQdLAmrQ2urpRlOg9by7YbW2XoampawDvksrpRlOg9jj7nhG5bW8AFyvhk1yIuTPIEwxqn6dW2fW8AFyvhk7JUGivS0Uus8NnXe)0CL(NijndFZrcPoKWM3gGjnLxU5MglXJNvDizk)eVj0OVeVDIapL6)1kTl0nbKSNjEXhk(HL49AFyvhk1yIuTPIEwxqn6dW2LdGTJDayEaS6QuKIEwxqn6ts2BoaZdG51(WQouQXePAtf9SUGA0hGTlG51(WQou2hDbrQyPDPK4pBIjE7ebEk1)RvAxOBcizptAkVC3BASepEw1HKP8t8MqJ(s8hUEZrHCF2aeP4LzNa)eV4df)Ws8ETpSQdLAmrQ2urpRlOg9by7YbW8d7aW8ay1vPif9SUGA0NKS3CaMhaZR9HvDOuJjs1Mk6zDb1OpaBxaZR9HvDOSp6cIuXs7sjXF2et8hUEZrHCF2aeP4LzNa)KM0epjwSLttJLYl30yjEtOrFjErVofF4a6CjE8SQdjt5N0uE7nnwIhpR6qYu(j(EiXdrnXBcn6lX71(WQomX71ClmXRMdpvwIhHQ9k(s8SQdjbS9eWkXJq1EfF5JtloiGTfG5lGj62r2BoPON1fuJ(KpoT4Ga2Ecy(cy5cy(jG51(WQou6FCKU4iqFKCj0OpaBpbm1C4Ps)JJ0fhbjEw1HKaMpaMFcyMqJ(K)6qAxOd9g8LirrXsrQgteW2tatnhEQ8xhs7cDO3GVepR6qsaZhaBpbmIayIUDK9Mtk6zDb1Op5Jgj3a2Ecy1vPif9SUGA0NKS3CjEV2tpBIjEnMivBQON1fuJ(sAkpUonwIhpR6qYu(j(EiXpnIM4nHg9L49AFyvhM49AUfM4fD7i7nNCIZ(5M2fQBjcsk5J2ekFCAXbt8Ipu8dlXJqiEcuoXz)Ct7c1TebjL8rBcLtZpQFaZdGvxLICIZ(5M2fQBjcsk5J2ekj7nhG5bWeD7i7nNCIZ(5M2fQBjcsk5J2ekFCAXbbm)eW8AFyvhk1yIuTPIEwxqn6dW2NdG51(WQouM1osQON1fuJ(OA2JWS2rM49Ap9SjM41yIuTPIEwxqn6lPP88dPXs84zvhsMYpX3dj(Pr0eVj0OVeVx7dR6WeVxZTWeVOBhzV5KB63r6fJJ(iSp7eO8XPfhmXl(qXpSepcH4jq5M(DKEX4Opc7ZobkNMFu)aMhaRUkf5M(DKEX4Opc7Zobkj7nhG5bWeD7i7nNCt)osVyC0hH9zNaLpoT4GaMFcyETpSQdLAmrQ2urpRlOg9by7ZbW8AFyvhkZAhjv0Z6cQrFun7ryw7it8ETNE2et8AmrQ2urpRlOg9L0uE7inwIhpR6qYu(jEtOrFjEH5CutOrFuxa1eVlGk9SjM4dfNqAwqiJo8r)HYDst5ThsJL4XZQoKmLFIx8HIFyj(6QuKIEwxqn6ts2BUeVj0OVe)m(VFAmncyst55hNglXJNvDizk)eV4df)Ws8(cyETpSQdLAmrQ2urpRlOg9by7dy5ooGnAeGPXePAtjdeW2hW8AFyvhk1yIuTPIEwxqn6dW8jXBcn6lXtyzpzyhTluJlXV1SKMYBpMglXBcn6lXl6tGN(MIK0IZMyIhpR6qYu(jnLNFnnwI3eA0xI)rBioc0IZMimXJNvDizk)KMYl3XtJL4nHg9L4lTybrsQXL4hksROnt84zvhsMYpPP8Yn30yjEtOrFj(H1hfUJJaT6mOM4XZQoKmLFst5L7EtJL4nHg9L4)yyWH04OWbtGjE8SQdjt5N0uE5Y1PXs8MqJ(s8AgsxxTxhjT0Vat84zvhsMYpPP8Y1pKglXJNvDizk)eV4df)Ws81vPif9SUGA0NKS3CaMhaZxaZR9HvDOuJjs1Mk6zDb1OpaBxaRSCo6JIm7jGunMiGnAeG51(WQouQXePAtf9SUGA0hGTlGPXePAtjdeW8jXBcn6lX)RdPDHo0BWpPP8YDhPXs84zvhsMYpXl(qXpSeVx7dR6qPgtKQnv0Z6cQrFa2(CaSXt8MqJ(s8cZ5OMqJ(OUaQjExav6ztmXl6zDb1Op6qMbXKMYl39qASepEw1HKP8t8lis3KfoKkmOghHuE5M4fFO4hwI3xadHq8eOCIZ(5M2fQBjcsk5J2ekNMFu)a2OragcH4jq5eN9ZnTlu3seKuYhTjuoJRFaZdGzCj(HIYQZGk(0Pbv8L4zvhscy(ayEamrM9eqiGXbWMgrPIm7jGqaZdGreaRUkfzwRuO(O5V8rtOaMhaJiaMVawDvkYm004iqxdYhnHcyEamFbS6QuKIEwxqn6tUgampaMVaMj0OpzjESAoNmoAXfeYuaB0iaZeA0NCG7VRodQY4OfxqitbSrJamtOrFsOOFrMejkkwACeamFaSrJam1EcOkZqZPzYbHcy7ZbW46XbmpaMj0Opju0VitIefflnocaMpaMpaMhaJiaMVagraS6QuKzOPXrGUgKpAcfW8ayebWQRsrM1kfQpA(lF0ekG5bWQRsrk6zDb1OpjzV5ampaMVaMj0OpzjESAoNmoAXfeYuaB0iaZeA0NCG7VRodQY4OfxqitbmFamFs8lis7sHsqqMYl3eVj0OVeFjEKwDgutAkVC9JtJL4XZQoKmLFIVhs8qut8MqJ(s8ETpSQdt8En3ct8Q5WtL)6qAxOd9g8L4zvhscyEamr3oYEZj)1H0Uqh6n4lFCAXbbS9bmr3oYEZjlXJ0QZGQSSCo6JIm7jGunMiG5bW8fW8AFyvhk1yIuTPIEwxqn6dW2fWmHg9j)1H0Uqh6n4lllNJ(OiZEcivJjcy(ayEamFbmr3oYEZj)1H0Uqh6n4lFCAXbbS9bmnMivBkzGa2OraMj0Op5VoK2f6qVbFPiZEcieW2fWghW8bWgncW8AFyvhk1yIuTPIEwxqn6dW2hWmHg9jlXJ0QZGQSSCo6JIm7jGunMiG5bW8AFyvhk1yIuTPIEwxqn6dW2hW0yIuTPKbM49Ap9SjM4lXJ0QZGkDOBxCesAkVC3JPXs84zvhsMYpXl(qXpSeFDvkYFDiTl0HEd(Y1aG5bW8fW8AFyvhk1yIuTPIEwxqn6dW2fWghW8jXBcn6lXlmNJAcn6J6cOM4DbuPNnXe)3d0HmdIjnLxU(10yjE8SQdjt5N47Hepe1eVj0OVeVx7dR6WeVxZTWeVAo8u5VoK2f6qVbFjEw1HKaMhat0TJS3CYFDiTl0HEd(YhNwCqaBFat0TJS3CYHSgVGO0IZMiuwwoh9rrM9eqQgteW8ay(cyETpSQdLAmrQ2urpRlOg9by7cyMqJ(K)6qAxOd9g8LLLZrFuKzpbKQXebmFampaMVaMOBhzV5K)6qAxOd9g8LpoT4Ga2(aMgtKQnLmqaB0iaZeA0N8xhs7cDO3GVuKzpbecy7cyJdy(ayJgbyETpSQdLAmrQ2urpRlOg9by7dyMqJ(KdznEbrPfNnrOSSCo6JIm7jGunMiG5bW8AFyvhk1yIuTPIEwxqn6dW2hW0yIuTPKbM49Ap9SjM4hYA8cIsh62fhHKMYBVJNglXJNvDizk)e)cI0nzHdPcdQXriLxUjEXhk(HL49fWicG51(WQouwIhPvNbv6q3U4iayJgby1vPi)1H0Uqh6n4lxdaMpaMhaZxaZR9HvDOuJjs1Mk6zDb1OpaBxaBCaZhaZdG5lGzcn8Iu8WzGqaBxoaMx7dR6qzM9KuHbvAXzteQF4pcyEamFbmnMiG5NawDvksrpRlOg9jDguPirhIhbSDbmV2hw1Hss0zCtloBIq9d)raZhaZhaZdGreaRepcv7v8LMqdViG5bWQRsrM1kfQpA(lj7nhG5bW8fWicGzCj(HIYQZGk(0Pbv8L4zvhscyJgby1vPiRodQ4tNguXx(40Idcy7dyJl3bG5tIFbrAxkuccYuE5M4nHg9L4lXJ0QZGAst5T3CtJL4XZQoKmLFIFbr6MSWHuHb14iKYl3eV4df)Ws8L4rOAVIV0eA4fbmpaMiZEcieW2LdGLlG5bW8fWicG51(WQouwIhPvNbv6q3U4iayJgby1vPi)1H0Uqh6n4lxdaMpaMhaZxaJiaMXL4hkkRodQ4tNguXxINvDijGnAeGvxLIS6mOIpDAqfF5JtloiGTpGnUChaMpaMhaZxaJiaMj0OpzjESAoNejkkwACeampagramtOrFYbU)U6mOkJJwCbHmfW8ay1vPiZqtJJaDnixda2OraMj0OpzjESAoNejkkwACeampawDvkYSwPq9rZFjzV5aSrJamtOrFYbU)U6mOkJJwCbHmfW8ay1vPiZqtJJaDnij7nhG5bWQRsrM1kfQpA(lj7nhG5tIFbrAxkuccYuE5M4nHg9L4lXJ0QZGAst5T39MglXJNvDizk)eV4df)Ws8ETpSQdLAmrQ2urpRlOg9by7cyJN4nHg9L4fMZrnHg9rDbut8UaQ0ZMyIhQ2rApj9B10OVKM0eFO4esf9SUGA0xASuE5MglXJNvDizk)e)ztmXheUqJ(OtJacPLfet8MqJ(s8bHl0Op60iGqAzbXKMYBVPXs84zvhsMYpXBcn6lXNX9a(A2JgjDZhqDZBdWeV4df)Ws81vPif9SUGA0NCnayEamtOrFYs8iT6mOkfz2taHaghaBCaZdGzcn6twIhPvNbv5JIm7jGunMiGTlGrqqkNgrt8NnXeFg3d4RzpAK0nFa1nVnatAkpUonwIhpR6qYu(j(ZMyIFAxuqO20UqNg5HqyI3eA0xIFAxuqO20UqNg5Hqyst55hsJL4RRsHE2et8t7Icc1M2f60ipecPImBqXN2hM4fFO4hwIVUkfPON1fuJ(KRbaB0iaZeA0NCIk2VmoAXfeYuaZdGzcn6torf7xghT4cczk9XPfheW2NdGnUChj(fePDPqjiit5LBI3eA0xIxyNaD06Qus84zvhsMYpPP82rASepEw1HKP8t8NnXeVXLRh1SgsHXrajPdU10iGj(fePDPqjiit5LBI3eA0xI34Y1JAwdPW4iGK0b3AAeWeV4df)Ws81vPif9SUGA0NCnayJgbyMqJ(KtuX(LXrlUGqMcyEamtOrFYjQy)Y4OfxqitPpoT4Ga2(CaSXL7iPP82dPXs84zvhsMYpXBcn6lXtWzKHP9dPvJKaM4xqK2LcLGGmLxUjEXhk(HL4RRsrk6zDb1Op5AaWgncWmHg9jNOI9lJJwCbHmfW8ayMqJ(KtuX(LXrlUGqMsFCAXbbS95ayJl3rIhlfuO0ZMyINGZidt7hsRgjbmPP88JtJL4XZQoKmLFI3eA0xINGZidt7hsNiP5CrFj(fePDPqjiit5LBIx8HIFyj(6QuKIEwxqn6tUgaSrJamtOrFYjQy)Y4OfxqitbmpaMj0Op5evSFzC0IliKP0hNwCqaBFoa24YDK4Xsbfk9SjM4j4mYW0(H0jsAox0xst5ThtJL4XZQoKmLFI)SjM4RMdlXJ06BNilXVGiTlfkbbzkVCt8MqJ(s8vZHL4rA9TtKL4fFO4hwIVUkfPON1fuJ(KRbaB0iaZeA0NCIk2VmoAXfeYuaZdGzcn6torf7xghT4cczk9XPfheW2NdGnUChjnLNFnnwIhpR6qYu(j(ZMyIhM1c)RHIpKwSJqIFbrAxkuccYuE5M4nHg9L4HzTW)AO4dPf7iK4fFO4hwIVUkfPON1fuJ(KRbaB0iaZeA0NCIk2VmoAXfeYuaZdGzcn6torf7xghT4cczk9XPfheW2NdGnUChjnLxUJNglXJNvDizk)e)ztmXRCPDiKwT3F4qCimXVGiTlfkbbzkVCt8MqJ(s8kxAhcPv79hoehct8Ipu8dlXxxLIu0Z6cQrFY1aGnAeGzcn6torf7xghT4cczkG5bWmHg9jNOI9lJJwCbHmL(40Idcy7ZbWgxUJKMYl3CtJL4XZQoKmLFI)SjM4Tte4Pu)VwPDHUjGK9mXVGiTlfkbbzkVCt8MqJ(s82jc8uQ)xR0Uq3eqYEM4fFO4hwIVUkfPON1fuJ(KRbaB0iaZeA0NCIk2VmoAXfeYuaZdGzcn6torf7xghT4cczk9XPfheW2NdGnUChjnLxU7nnwIhpR6qYu(j(ZMyI)W1BokK7ZgGifVm7e4N4xqK2LcLGGmLxUjEtOrFj(dxV5OqUpBaIu8YStGFIx8HIFyj(6QuKIEwxqn6tUgaSrJamtOrFYjQy)Y4OfxqitbmpaMj0Op5evSFzC0IliKP0hNwCqaBFoa24YDK0uE5Y1PXs84zvhsMYpXF2et8tZv6FIK0m8nhjK6qcBEBaM4xqK2LcLGGmLxUjEtOrFj(P5k9prsAg(MJesDiHnVnat8Ipu8dlXxxLIu0Z6cQrFY1aGnAeGzcn6torf7xghT4cczkG5bWmHg9jNOI9lJJwCbHmL(40Idcy7ZbWgxUJKM0e)WJIEwnnnwkVCtJL4nHg9L4TxyhsJtrNdfAIhpR6qYu(jnL3EtJL4XZQoKmLFIVhs8qut8MqJ(s8ETpSQdt8En3ct8OFVIHbKuoTlkiuBAxOtJ8qieWgncWq)EfddiPKGZidt7hsRgjbeWgncWq)EfddiPKGZidt7hsNiP5CrFa2Orag63RyyajLbHl0Op60iGqAzbraB0iad97vmmGKsLlTdH0Q9(dhIdHa2Orag63RyyajLgxUEuZAifghbKKo4wtJacyJgbyOFVIHbKuANiWtP(FTs7cDtaj7jGnAeGH(9kggqsjmRf(xdfFiTyhbaB0iad97vmmGKYdxV5OqUpBaIu8YStGpGnAeGH(9kggqsz1CyjEKwF7ezjEV2tpBIjErpRlOg9r7JUGyst5X1PXs84zvhsMYpX3djEiQjEtOrFjEV2hw1HjEVMBHjE0VxXWasknUeMzVbPL(uAxOd9g8bmpaMx7dR6qPON1fuJ(O9rxqmX71E6ztmXx6tPK9Q6qAF0fetAkp)qASepEw1HKP8t89qIhIAI3eA0xI3R9HvDyI3R5wyIFVJdy7jG5lG51(WQouk6zDb1OpAF0febmpagramV2hw1HYsFkLSxvhs7JUGiG5dGTfG5hghW2taZxaZR9HvDOS0Nsj7v1H0(Olicy(ayBby7Dha2Ecy(cyOFVIHbKuACjmZEdsl9P0Uqh6n4dyEamIayETpSQdLL(ukzVQoK2hDbraZhaBlaBpcy7jG5lGH(9kggqs50UOGqTPDHonYdHqaZdGreaZR9HvDOS0Nsj7v1H0(Olicy(K49Ap9SjM47JUGivS0UusAkVDKglXJNvDizk)eFpK4FeIAI3eA0xI3R9HvDyI3R90ZMyIpRDKurpRlOg9r1ShHzTJmXtIfB50e)EhpPP82dPXs84zvhsMYpX3djEiQjEtOrFjEV2hw1HjEVMBHj(9cy7jGPMdpvwC2ePdMkYK4zvhscyBby(v)kGTNagram1C4PYIZMiDWurMepR6qYeV4df)Ws8ETpSQdLzTsH6JM)0IZMiu)WFeW4ayJN49Ap9SjM4ZALc1hn)PfNnrO(H)yst55hNglXJNvDizk)eFpK4HOM4nHg9L49AFyvhM49AUfM45AaBpbm1C4PYIZMiDWurMepR6qsaBlaZV6xbS9eWicGPMdpvwC2ePdMkYK4zvhsM4fFO4hwI3R9HvDOmZEsQWGkT4Sjc1p8hbmoa24jEV2tpBIj(m7jPcdQ0IZMiu)WFmPP82JPXs84zvhsMYpX3dj(hHOM4nHg9L49AFyvhM49Ap9SjM4jrNXnT4Sjc1p8ht8KyXwonXV3DK0uE(10yjE8SQdjt5N47He)Jqut8MqJ(s8ETpSQdt8ETNE2et8(hhPloc0hjxcn6lXtIfB50e)4Y9M0uE5oEASepEw1HKP8tAkVCZnnwIhpR6qYu(j(ZMyI34syM9gKw6tPDHo0BWpXBcn6lXBCjmZEdsl9P0Uqh6n4N0uE5U30yjEtOrFj(z8F)0yAeWepEw1HKP8tAkVC560yjEtOrFj(HwJ(s84zvhsMYpPP8Y1pKglXBcn6lXpW93vNb1epEw1HKP8tAst8q1os7jPFRMg9LglLxUPXs84zvhsMYpXl(qXpSeVVaMj0WlsXdNbcbSD5ayETpSQdLzTsH6JM)0IZMiu)WFeW8ay(cyAmraZpbS6QuKIEwxqn6t6mOsrIoepcy7cyETpSQdLKOZ4MwC2eH6h(JaMpaMpaMhaRUkfzwRuO(O5V8rtOjEtOrFj(IZMiu)WFmPP82BASepEw1HKP8t8Ipu8dlXxxLImRvkuF08x(OjuaZdGvxLImRvkuF08x(40Idcy7dyMqJ(KL4XQ5CsKOOyPivJjM4nHg9L4h4(7QZGAst5X1PXs84zvhsMYpXl(qXpSeFDvkYSwPq9rZF5JMqbmpaMVa2WJEPeeKYCLL4XQ5Ca2OrawjEeQ2R4lnHgEraB0iaZeA0NCG7VRodQY4OfxqitbmFs8MqJ(s8dC)D1zqnPP88dPXs84zvhsMYpXl(qXpSeViZEcieW2LdGX1aMhaZeA4fP4HZaHa2Ua2EbmpagramV2hw1HYHSgVGO0HUDXriXBcn6lXpK14feLwC2eHjnL3osJL4XZQoKmLFIx8HIFyj(6QuKzTsH6JM)YhnHcyEam1EcOkZqZPzYbHcy7ZbW46XbmpaMAo8ujeTpocuTxImjEw1HKjEtOrFj(bU)U6mOM0uE7H0yjE8SQdjt5N4fFO4hwIVUkf5a3FlCgCkF0ekG5bWeguPAmraBFaRUkf5a3FlCgCkFCAXbt8MqJ(s8dC)D1zqnPP88JtJL4XZQoKmLFIFbr6MSWHuHb14iKYl3eV4df)Ws8(cy1vPi)1H0Uqh6n4lj7nhG5bWicGvIhHQ9k(stOHxeW8bW8ayebW8AFyvhklXJ0QZGkDOBxCeampaMVaMVaMVaMj0OpzjESAoNejkkwACeaSrJamtOrFYbU)U6mOkrIIILghbaZhaZdGvxLImdnnoc01G8rtOaMpa2OraMVaMAo8ujeTpocuTxImjEw1HKaMhatTNaQYm0CAMCqOa2(CamUECaZdG5lGvxLImdnnoc01G8rtOaMhaJiaMj0Opju0VitIefflnoca2OragraS6QuKzTsH6JM)YhnHcyEamIay1vPiZqtJJaDniF0ekG5bWmHg9jHI(fzsKOOyPXraW8ayebWmHg9jh4(7QZGQmoAXfeYuaZdGreaZeA0NSepwnNtghT4cczkG5dG5dG5tIFbrAxkuccYuE5M4nHg9L4lXJ0QZGAst5ThtJL4XZQoKmLFIx8HIFyj(Hh9sjiiL5kHI(fzaMhaRUkfzgAACeORb5AaW8ayQ5WtLq0(4iq1EjYK4zvhscyEam1EcOkZqZPzYbHcy7ZbW46XbmpagramFbmtOHxKIhodecy7YbW8AFyvhkZALc1hn)PfNnrO(H)iG5bW8fW0yIaMFcy1vPif9SUGA0N0zqLIeDiEeW2fW8AFyvhkjrNXnT4Sjc1p8hbmFamFs8MqJ(s8dC)D1zqnPP88RPXs84zvhsMYpXl(qXpSeVVawDvkYm004iqxdYhnHcyJgby(cyebWQRsrM1kfQpA(lF0ekG5bW8fWmHg9jlXJ0QZGQuKzpbecy7cyJdyJgbyQ5WtLq0(4iq1EjYK4zvhscyEam1EcOkZqZPzYbHcy7ZbW46XbmFamFamFampagramV2hw1HYHSgVGO0HUDXriXBcn6lXpK14feLwC2eHjnLxUJNglXJNvDizk)eVj0OVeVWCoQj0OpQlGAI3fqLE2et8MqdVivnhEkmPP8Yn30yjE8SQdjt5N4fFO4hwI3eA4fP4HZaHa2UawUjEtOrFjEY3i0hKwF00SKMYl39MglXJNvDizk)eVj0OVeVWCoQj0OpQlGAI3fqLE2et8HIti11BOdF0FOCN0uE5Y1PXs84zvhsMYpXl(qXpSeVApbuLzO50m5GqbS95ayC94aMhatnhEQeI2hhbQ2lrMepR6qYeVj0OVepu0VilPP8Y1pKglXJNvDizk)eV4df)Ws8MqdVifpCgieW2LdG51(WQouMzpjvyqLwC2eH6h(JaMhaZxatJjcy(jGvxLIu0Z6cQrFsNbvks0H4raBxaZR9HvDOKeDg30IZMiu)WFeW8jXBcn6lXxC2eH6h(JjnLxU7inwI3eA0xIVepwnNlXJNvDizk)KMYl39qASeVj0OVepu0VilXJNvDizk)KM0e)3d0HmdIPXs5LBASeVj0OVe)VoK2f6qVb)epEw1HKP8tAkV9MglXJNvDizk)eV4df)Ws8(cyMqdVifpCgieW2LdG51(WQouM1kfQpA(tloBIq9d)raZdG5lGPXebm)eWQRsrk6zDb1OpPZGkfj6q8iGTlG51(WQousIoJBAXzteQF4pcy(ay(ayEaS6QuKzTsH6JM)YhnHM4nHg9L4loBIq9d)XKMYJRtJL4XZQoKmLFIx8HIFyj(6QuKzTsH6JM)YhnHM4nHg9L4h4(7QZGAst55hsJL4XZQoKmLFIFbr6MSWHuHb14iKYl3eV4df)Ws8ebW8fWmHgErkE4mqiGTlhaZR9HvDOmZEsQWGkT4Sjc1p8hbmpaMVaMgteW8taRUkfPON1fuJ(KodQuKOdXJa2UaMx7dR6qjj6mUPfNnrO(H)iG5dG5dG5bWicGvIhHQ9k(stOHxeW8ay(cyebWQRsrMHMghb6Aq(OjuaZdGreaRUkfzwRuO(O5V8rtOaMhaJia2WJEPDPqjiiLL4rA1zqfW8ay(cyMqJ(KL4rA1zqvkYSNacbSD5ay7fWgncW8fWmHg9jhYA8cIsloBIqPiZEcieW2LdGLlG5bWuZHNkhYA8cIsloBIqjEw1HKaMpa2OraMVaMAo8uP5qIc13GCPbPL1ZTepR6qsaZdGj62r2Boj5Be6dsRpAAM8rJKBaZhaB0iaZxatnhEQeI2hhbQ2lrMepR6qsaZdGP2tavzgAontoiuaBFoagxpoG5dG5dG5tIFbrAxkuccYuE5M4nHg9L4lXJ0QZGAst5TJ0yjE8SQdjt5N4nHg9L4fMZrnHg9rDbut8UaQ0ZMyI3eA4fPQ5WtHjnL3EinwIhpR6qYu(jEXhk(HL4RRsroW93cNbNYhnHcyEamHbvQgteW2hWQRsroW93cNbNYhNwCqaZdGvxLI8xhs7cDO3GV8XPfheW2fWeguPAmXeVj0OVe)a3FxDgutAkp)40yjE8SQdjt5N4xqKUjlCivyqnocP8YnXl(qXpSepramFbmtOHxKIhodecy7YbW8AFyvhkZSNKkmOsloBIq9d)raZdG5lGPXebm)eWQRsrk6zDb1OpPZGkfj6q8iGTlG51(WQousIoJBAXzteQF4pcy(ay(ayEamIayL4rOAVIV0eA4fbmpaMVawDvkYm004iqxdYhnHcyEamFbm1EcOkZqZPzYbHcy7YbW46XbSrJamIayQ5WtLq0(4iq1EjYK4zvhscy(ay(K4xqK2LcLGGmLxUjEtOrFj(s8iT6mOM0uE7X0yjE8SQdjt5N4xqKUjlCivyqnocP8YnXl(qXpSepramFbmtOHxKIhodecy7YbW8AFyvhkZSNKkmOsloBIq9d)raZdG5lGPXebm)eWQRsrk6zDb1OpPZGkfj6q8iGTlG51(WQousIoJBAXzteQF4pcy(ay(ayEamIayL4rOAVIV0eA4fbmpaMAo8ujeTpocuTxImjEw1HKaMhatTNaQYm0CAMCqOa2(CamUECaZdG5lGvxLImdnnoc01G8rtOaMhaJiaMj0Opju0VitIefflnoca2OragraS6QuKzOPXrGUgKpAcfW8ayebWQRsrM1kfQpA(lF0ekG5tIFbrAxkuccYuE5M4nHg9L4lXJ0QZGAst55xtJL4XZQoKmLFIx8HIFyj(Hh9sjiiL5kHI(fzaMhaRUkfzgAACeORb5AaW8ayQ5WtLq0(4iq1EjYK4zvhscyEam1EcOkZqZPzYbHcy7ZbW46XbmpagramFbmtOHxKIhodecy7YbW8AFyvhkZALc1hn)PfNnrO(H)iG5bW8fW0yIaMFcy1vPif9SUGA0N0zqLIeDiEeW2fW8AFyvhkjrNXnT4Sjc1p8hbmFamFs8MqJ(s8dC)D1zqnPP8YD80yjE8SQdjt5N4fFO4hwINia2WJEPeeKYCLdznEbrPfNnriG5bWQRsrMHMghb6Aq(Oj0eVj0OVe)qwJxquAXzteM0uE5MBASepEw1HKP8t8Ipu8dlXR2tavzgAontoiuaBFoagxpoG5bWuZHNkHO9XrGQ9sKjXZQoKmXBcn6lXdf9lYsAkVC3BASepEw1HKP8t8Ipu8dlXBcn8Iu8WzGqaBxaBVjEtOrFjEY3i0hKwF00SKMYlxUonwIhpR6qYu(jEXhk(HL49fWmHgErkE4mqiGTlhaZR9HvDOmZEsQWGkT4Sjc1p8hbmpaMVaMgteW8taRUkfPON1fuJ(KodQuKOdXJa2UaMx7dR6qjj6mUPfNnrO(H)iG5dG5tI3eA0xIV4Sjc1p8htAkVC9dPXs8MqJ(s8L4XQ5CjE8SQdjt5N0KM0eVx8HrFP82747D8X5AUE8e)g7V4iat8(fMd9RijG5xbmtOrFaMlGkucYjXdhqrkV9axN4h(UeomXVZagxmEeW2jgbeKZodyzQoa5cS92ecnBvLIEUnmMlNPrFI3k62Wyk2gKZodyCfg(Wby5smGT3X374GCa5SZagxnZociKlaiNDgW8taZVeIaMgtKQnLmqa7nndFatZSdWu7jGQuJjs1MsgiGv6hWCgu9tik6JeWSA4cLBaBbnciucYzNbm)eW8lhinfbmxtiea2JCbaSD6LiibmUspAtOeKZody(jGTt3nepatyqfWE0VxXJt8uiGv6hW4Q9SUGA0hG5BirjXagzFCfvalRDKawOawPFaZaSYJWmaBNGk2pGjmO6JeKdiNDgW8lMOOyPijGvXs)iGj6z1uaRIeIdkbmUccboOqa76ZpZSFwwoaZeA0heW6ZXTeKZodyMqJ(GYHhf9SAkNIZG(dYzNbmtOrFq5WJIEwnDloBx6MeKZodyMqJ(GYHhf9SA6wC22weM4PMg9bYXeA0huo8OONvt3IZ22lSdPXPOZHcfKJj0OpOC4rrpRMUfNT9AFyvhs8ztKJON1fuJ(O9rxqK4EGdevI9AUfYb97vmmGKYPDrbHAt7cDAKhcHJgH(9kggqsjbNrgM2pKwnsc4OrOFVIHbKusWzKHP9dPtK0CUOVrJq)EfddiPmiCHg9rNgbesllioAe63RyyajLkxAhcPv79hoehchnc97vmmGKsJlxpQznKcJJasshCRPrahnc97vmmGKs7ebEk1)RvAxOBcizphnc97vmmGKsywl8Vgk(qAXocJgH(9kggqs5HR3Cui3NnarkEz2jWF0i0VxXWaskRMdlXJ06BNidKJj0OpOC4rrpRMUfNT9AFyvhs8ztKtPpLs2RQdP9rxqK4EGdevI9AUfYb97vmmGKsJlHz2BqAPpL2f6qVbFpETpSQdLIEwxqn6J2hDbrqo7mG5xqXjeW0mtbm7raBbrsaRxkmiraRlagxTN1fuJ(am7ra7AfWwqKeWSIIpGPzbeW0yIawuamnd5gW20lhjGnSuaZam9JZFubSfejbSnHMbyC1Ewxqn6dW6dWmadMzpjscyIUDK9MtcYXeA0huo8OONvt3IZ2ETpSQdj(SjYPp6cIuXs7sH4EGdevI9AUfYzVJVN(61(WQouk6zDb1OpAF0fe9qeV2hw1HYsFkLSxvhs7JUGOpB5hgFp91R9HvDOS0Nsj7v1H0(Oli6Zw7Dh7PVOFVIHbKuACjmZEdsl9P0Uqh6n47HiETpSQdLL(ukzVQoK2hDbrF2ApUN(I(9kggqs50UOGqTPDHonYdHqpeXR9HvDOS0Nsj7v1H0(Oli6diNDgW4Q9SUGA0hGfqaRph3a2cIKa2MqZ6LcyCL73r6fJdW4ccc7Zobcy9dy7eC2p3awxaSD6LiibmUspAtiGffaluaBt4CawfbmZRfoR6qaZuaZHgubmnlGa20oUbmik6JecyvS0pcyAgcyieINa5kcbmr3oYEZbybeWE0i5wcYXeA0huo8OONvt3IZ2ETpSQdj(SjYjRDKurpRlOg9r1ShHzTJK4EGZJqujMel2YPC274GC2zaBSSacyETpSQdbm4akIsGqatZqa7wZk(awxam1EcOcbmtbSnzHidW4cBfW41hn)bmUOZMiu)WFecy9sHbjcyDbW4Q9SUGA0hGbZ6LJeWQiGTGiPeKJj0OpOC4rrpRMUfNT9AFyvhs8ztKtwRuO(O5pT4Sjc1p8hjUh4arL4OWXR9HvDOmRvkuF08NwC2eH6h(JCgNyVMBHC27EQMdpvwC2ePdMkYK4zvhsULF1VUNernhEQS4SjshmvKjXZQoKeKZodyJLfqaZR9HvDiGbhqrucecyAgcy3AwXhW6cGP2taviGzkGTjlezagxO9Kagx1GkGXfD2eH6h(JqaRxkmiraRlagxTN1fuJ(amywVCKawfbSfejbmdcyLW5WxcYXeA0huo8OONvt3IZ2ETpSQdj(SjYjZEsQWGkT4Sjc1p8hjUh4arL4OWXR9HvDOmZEsQWGkT4Sjc1p8h5moXEn3c5W17PAo8uzXztKoyQitINvDi5w(v)6Ese1C4PYIZMiDWurMepR6qsqo7mG5xcJJaGXfD2eH6h(JaMvu8bmUApRlOg9bybeWAV4dyc7amHTGiGzagmiCrje2PaMn71PawxamsBAeqatBaRIaMRHkGrUqatBatZqaR9I)Mp04iayDbW8lq4cfbmnZuaRfI1dbSnz4byAgcy(fiCHIaw57jGXDVEaB4JP9CdyC1Ewxqn6dWu7jGkGbhE0iHsaBSSacyETpSQdbSacyliscyAdyWbuefUbmndbmB2RtbSUayAmraloadII(iHaMMzkGnxqfWgmieWSIIpGXv7zDb1Opadj6q8ieWQyPFeW4IoBIq9d)riGTjCoaRIa2cIKa21)0CoULGCmHg9bLdpk6z10T4STx7dR6qIpBICirNXnT4Sjc1p8hjMel2YPC27oiUh48ievqo7mGXvo0maZVO4iDXrGyaJR2Z6cQrFCfHaMOBhzV5aSnHZbyveWEKCjqsaRYnGza2BhzpbmB2RtjgWQlfW0meWU1SIpG1fat8HcbmOAVcbmV4ZnGLfeYamRO4dyMqdVMghbaJR2Z6cQrFaMDKag01BGagzV5amT3ypjeW0meWWJeW6cGXv7zDb1OpUIqat0TJS3CsaJRCgEa208pocagjkcy0heWIdW0meW4kStzNMyaJR2Z6cQrFCfHa2JtlU4iayIUDK9MdWciG9i5sGKawLBatZciGvEtOrFaM2aMje96uaR0pG5xuCKU4iib5ycn6dkhEu0ZQPBXzBV2hw1HeF2e54FCKU4iqFKCj0OpIjXITCkNXL7L4EGZJqub5ycn6dkhEu0ZQPBXzB4zdWSwPq1uiihtOrFq5WJIEwnDloBVGinuCs8ztKJXLWm7niT0Ns7cDO3GpihtOrFq5WJIEwnDloBpJ)7NgtJacYXeA0huo8OONvt3IZ2dTg9bYXeA0huo8OONvt3IZ2dC)D1zqfKdiNDgW8lMOOyPijGHEXNBatJjcyAgcyMq7hWciGzETWzvhkb5ycn6dYr0RtXhoGohihtOrFWT4STx7dR6qIpBIC0yIuTPIEwxqn6J4EGdevI9AUfYrnhEQSepcv7v8L4zvhsUNL4rOAVIV8XPfhClFfD7i7nNu0Z6cQrFYhNwCW903C9tV2hw1Hs)JJ0fhb6JKlHg9TNQ5WtL(hhPlocs8SQdj9XpnHg9j)1H0Uqh6n4lrIIILIunM4EQMdpv(RdPDHo0BWxINvDiPp7jreD7i7nNu0Z6cQrFYhnsU3Z6QuKIEwxqn6ts2BoqoMqJ(GBXzBV2hw1HeF2e5OXePAtf9SUGA0hX9aNPruI9AUfYr0TJS3CYjo7NBAxOULiiPKpAtO8XPfhK4OWbHq8eOCIZ(5M2fQBjcsk5J2ekNMFu)EQRsroXz)Ct7c1TebjL8rBcLK9MZJOBhzV5KtC2p30UqDlrqsjF0Mq5JtloOF61(WQouQXePAtf9SUGA03(C8AFyvhkZAhjv0Z6cQrFun7ryw7ib5ycn6dUfNT9AFyvhs8ztKJgtKQnv0Z6cQrFe3dCMgrj2R5wihr3oYEZj30VJ0lgh9ryF2jq5JtloiXrHdcH4jq5M(DKEX4Opc7ZobkNMFu)EQRsrUPFhPxmo6JW(StGsYEZ5r0TJS3CYn97i9IXrFe2NDcu(40Id6NETpSQdLAmrQ2urpRlOg9TphV2hw1HYS2rsf9SUGA0hvZEeM1osqoMqJ(GBXzBH5CutOrFuxavIpBICcfNqAwqiJo8r)HYnihtOrFWT4S9m(VFAmnciXrHtDvksrpRlOg9jj7nhihtOrFWT4SnHL9KHD0UqnUe)wZiokC81R9HvDOuJjs1Mk6zDb1OV9ZD8rJ0yIuTPKbUVx7dR6qPgtKQnv0Z6cQrF(aYXeA0hCloBl6tGN(MIK0IZMiihtOrFWT4S9J2qCeOfNnriihtOrFWT4SDPflissnUe)qrAfTjihtOrFWT4S9W6Jc3XrGwDgub5ycn6dUfNT)yyWH04OWbtGGCmHg9b3IZ2AgsxxTxhjT0Vab5ycn6dUfNT)1H0Uqh6n4tCu4uxLIu0Z6cQrFsYEZ5XxV2hw1HsnMivBQON1fuJ(2TSCo6JIm7jGunM4OrETpSQdLAmrQ2urpRlOg9TRgtKQnLmqFa5ycn6dUfNTfMZrnHg9rDbuj(SjYr0Z6cQrF0HmdIehfoETpSQdLAmrQ2urpRlOg9TpNXb5ycn6dUfNTlXJ0QZGkXlis7sHsqqYjxIxqKUjlCivyqnocCYL4OWXxecXtGYjo7NBAxOULiiPKpAtOCA(r9pAecH4jq5eN9ZnTlu3seKuYhTjuoJRFpgxIFOOS6mOIpDAqfFjEw1HK(4rKzpbeYzAeLkYSNac9qK6QuKzTsH6JM)YhnH6Hi(wxLImdnnoc01G8rtOE8TUkfPON1fuJ(KRbp(Acn6twIhRMZjJJwCbHmD0itOrFYbU)U6mOkJJwCbHmD0itOrFsOOFrMejkkwACe8z0i1EcOkZqZPzYbHUphUECpMqJ(Kqr)ImjsuuS04i4JpEiIVePUkfzgAACeORb5JMq9qK6QuKzTsH6JM)YhnH6PUkfPON1fuJ(KK9MZJVMqJ(KL4XQ5CY4OfxqithnYeA0NCG7VRodQY4Ofxqit9XhqoMqJ(GBXzBV2hw1HeF2e5uIhPvNbv6q3U4iqSxZTqoQ5WtL)6qAxOd9g8L4zvhs6r0TJS3CYFDiTl0HEd(YhNwCW9fD7i7nNSepsRodQYYY5OpkYSNas1yIE81R9HvDOuJjs1Mk6zDb1OVDnHg9j)1H0Uqh6n4lllNJ(OiZEcivJj6JhFfD7i7nN8xhs7cDO3GV8XPfhCFnMivBkzGJgzcn6t(RdPDHo0BWxkYSNac3DCFgnYR9HvDOuJjs1Mk6zDb1OV9nHg9jlXJ0QZGQSSCo6JIm7jGunMOhV2hw1HsnMivBQON1fuJ(2xJjs1MsgiihtOrFWT4STWCoQj0OpQlGkXNnroFpqhYmisCu4uxLI8xhs7cDO3GVCn4XxV2hw1HsnMivBQON1fuJ(2DCFa5ycn6dUfNT9AFyvhs8ztKZqwJxqu6q3U4iqSxZTqoQ5WtL)6qAxOd9g8L4zvhs6r0TJS3CYFDiTl0HEd(YhNwCW9fD7i7nNCiRXlikT4SjcLLLZrFuKzpbKQXe94Rx7dR6qPgtKQnv0Z6cQrF7Acn6t(RdPDHo0BWxwwoh9rrM9eqQgt0hp(k62r2Bo5VoK2f6qVbF5Jtlo4(AmrQ2uYahnYeA0N8xhs7cDO3GVuKzpbeU74(mAKx7dR6qPgtKQnv0Z6cQrF7Bcn6toK14feLwC2eHYYY5OpkYSNas1yIE8AFyvhk1yIuTPIEwxqn6BFnMivBkzGGC2zaJRCgEagxO9KcdQXraW4IoBIagV(H)iXagxmEeWY3zqfcyWSE5ibSkcyliscyAdyeWdFtraJlSvaJxF08hcy2rcyAdyirv8ibS8DguXhW2jguXxcYXeA0hCloBxIhPvNbvIxqK2LcLGGKtUeVGiDtw4qQWGACe4KlXrHJVeXR9HvDOSepsRodQ0HUDXry0O6QuK)6qAxOd9g8LRbF84Rx7dR6qPgtKQnv0Z6cQrF7oUpE81eA4fP4HZaH7YXR9HvDOmZEsQWGkT4Sjc1p8h94Rgt0pRRsrk6zDb1OpPZGkfj6q84UETpSQdLKOZ4MwC2eH6h(J(4JhIuIhHQ9k(stOHx0tDvkYSwPq9rZFjzV584lrmUe)qrz1zqfF60Gk(s8SQdjhnQUkfz1zqfF60Gk(YhNwCW9hxUdFa5SZagxP1hhbaJlgpcv7v8jgW4IXJaw(odQqaZEeWwqKeWGXmC274gW0gWixFCeamUApRlOg9jbmUGIh(MZXnXaMMHCdy2Ja2cIKaM2agb8W3ueW4cBfW41hn)Ha2Mm8amXhkeW2eohGDTcyveW2yqfjbm7ibSnHMby57mOIpGTtmOIpXaMMHCdyWSE5ibSkcyWHhnsaRxkGPnGnT4uloatZqalFNbv8bSDIbv8bS6QuKGCmHg9b3IZ2L4rA1zqL4fePDPqjii5KlXlis3KfoKkmOghbo5sCu4uIhHQ9k(stOHx0JiZEciCxo56XxI41(WQouwIhPvNbv6q3U4imAuDvkYFDiTl0HEd(Y1GpE8LigxIFOOS6mOIpDAqfFjEw1HKJgvxLIS6mOIpDAqfF5Jtlo4(Jl3HpE8LiMqJ(KL4XQ5CsKOOyPXrWdrmHg9jh4(7QZGQmoAXfeYup1vPiZqtJJaDnixdJgzcn6twIhRMZjrIIILghbp1vPiZALc1hn)LK9MB0itOrFYbU)U6mOkJJwCbHm1tDvkYm004iqxdsYEZ5PUkfzwRuO(O5VKS3C(aYXeA0hCloBlmNJAcn6J6cOs8ztKduTJ0Es63QPrFehfoETpSQdLAmrQ2urpRlOg9T74GCa5ycn6dknHgErQAo8uihx4noc0ApRehfoMqdVifpCgiC3C9uxLIu0Z6cQrFsYEZ5XxV2hw1HsnMivBQON1fuJ(2v0TJS3Csx4noc0ApRsY1BA03OrETpSQdLAmrQ2urpRlOg9TpNX9bKJj0OpO0eA4fPQ5WtHBXz7jQy)ehfoETpSQdLAmrQ2urpRlOg9TpNXhnY36QuK)6qAxOd9g8LRHrJeD7i7nN8xhs7cDO3GV8XPfhCxnMivBkzGEmHg9j)1H0Uqh6n4lfz2taH7N7OrernhEQ8xhs7cDO3GVepR6qsF84ROBhzV5KtuX(LKR30OV99AFyvhk1yIuTPIEwxqn6B0inMivBkzG771(WQouQXePAtf9SUGA0NpGCmHg9bLMqdVivnhEkCloBt(gH(G06JMMrCu4OMdpvAoKOq9nixAqAz9ClXZQoK0JV1vPif9SUGA0NKS3CEisDvkYSwPq9rZF5JMqhnQUkfPON1fuJ(KRbpMqJ(KL4rA1zqvkYSNac33eA0NSepsRodQYPruQiZEci0drQRsrM1kfQpA(lF0eQpGCa5SZagxTN1fuJ(aSHmdIa2WJd2JqaZQHl0aHa2MqZamdWirNXnXaMMHhG5S1jYqiGfN2aMMHagxTN1fuJ(ami63l8eiihtOrFqPON1fuJ(Odzge54cczkK6hTijmXtjokCQRsrk6zDb1OpjzV5a5ycn6dkf9SUGA0hDiZG4wC2UAeODHQFi8hsCu4uxLIu0Z6cQrFsYEZbYXeA0huk6zDb1Op6qMbXT4STl8ghbATNvIJchtOHxKIhodeUBUEQRsrk6zDb1OpjzV5a5ycn6dkf9SUGA0hDiZG4wC2U66MK2fQMHu8Wj3GCmHg9bLIEwxqn6JoKzqCloBpXz)Ct7c1TebjL8rBcb5ycn6dkf9SUGA0hDiZG4wC2Et)osVyC0hH9zNab5SZagxP1hhbaJR2Z6cQrFedyCX4ralFNbviGzpcyliscyAdyeWdFtraJlSvaJxF08hcy2rcyZ4IzWLiGPziGzZEDkG1fatJjcyWb8uadjkkwACeaSwZWhWGdOZbLagxSFadQ2rApjGXfJhjgW4IXJaw(odQqaZEeW6ZXnGTGijGTjdpaJlennocaMF5aGfqaZeA4fbS(bSnz4bygGXl6xKbycdQawabS4aSHVj8iecy2rcyCHOPXraW8lham7ibmUWwbmE9rZFaZEeWUwbmtOHxucyCLdndWY3zqfFaBNyqfFaZosaJl6SjcyCbFedyCX4ralFNbviGjSdWmsYqJ(mNJBaRIa2cIKa2MSWHagxyRagV(O5pGzhjGXfIMghbaZVCaWShbSRvaZeA4fbm7ibmdW2PW93vNbvalGawCaMMHaMfpGzhjGzoydyBYchcycdQXraW4f9lYam0lEawuamUq004iay(LdawabmZ9OrYnGzcn8IsaBSmeWCMQ4dyMZ1BGaMUPbmUWwbmE9rZFaBNc3FxDguHaM2awfbmHbvaloadUececJ(amRO4dyAgcy8I(fzsaJRajzOrFMZXnGTj0malFNbv8bSDIbv8bm7ibmUOZMiGXf8rmGXfJhbS8DguHagmRxosa7AfWQiGTGijGTohcHaw(odQ4dy7edQ4dybeWSAVuatBadj6q8iG1pGPz4JaM9iGn7hbmnZoadVEridW4IXJaw(odQqatBadjQIhjGLVZGk(a2oXGk(aM2aMMHagEKawxamUApRlOg9jb5ycn6dkf9SUGA0hDiZG4wC2UepsRodQeVGiTlfkbbjNCjEbr6MSWHuHb14iWjxIJchrM9eq4UCY1JV(Acn6twIhPvNbvPiZEciKwEtOrFMBlFRRsrk6zDb1Op5JtloOFwxLIS6mOIpDAqfFj56nn6ZNDQIUDK9MtwIhPvNbvj56nn6Zp9TUkfPON1fuJ(KpoT4G(St136QuKvNbv8PtdQ4ljxVPrF(54YD4Jp7Yz8rJiIXL4hkkRodQ4tNguXxINvDi5OrernhEQS4Sjs7tINvDi5Or1vPif9SUGA0N8XPfhCFo1vPiRodQ4tNguXxsUEtJ(gnQUkfz1zqfF60Gk(YhNwCW9hxUJrJq)EfddiPmJ7b81Shns6MpG6M3gGEeD7i7nNmJ7b81Shns6MpG6M3gGuUE8XZ1pSx5Jtlo4(7Whp1vPif9SUGA0NCn4XxIycn6tcf9lYKirrXsJJGhIycn6toW93vNbvzC0IliKPEQRsrMHMghb6AqUggnYeA0Nek6xKjrIIILghbp1vPiZALc1hn)LK9MZJV1vPiZqtJJaDnij7n3OrgxIFOOS6mOIpDAqfFjEw1HK(mAKXL4hkkRodQ4tNguXxINvDiPh1C4PYIZMiTpjEw1HKEmHg9jh4(7QZGQmoAXfeYup1vPiZqtJJaDnij7nNN6QuKzTsH6JM)sYEZ5dihtOrFqPON1fuJ(Odzge3IZ2)6qAxOd9g8jokCQRsrk6zDb1OpjzV5a5SZagxbaJlgpcy57mOcyWSE5ibSkcyliscyAdy2WGJBalFNbv8bSDIbv8bSnzHdbmHb14iayCbzDiG1faBNsVbFaBtgEa2cghbalFNbv8bSDIbv8jgW4IoBIagxWhXaMDKa2obvSFjG5xOay954gW2j4SFUbSUay70lrqcyCLE0MqaBNex)awabm0VxXWassmGPzbeWCXHawabSGW1pscyvuylicyHcyBcNdWG9e1yIqa7r4YPawCagHoocawCAdyC1Ewxqn6dW2eAgGvWnagxmEeWY3zqfWez2taHsqoMqJ(GsrpRlOg9rhYmiUfNTlXJ0QZGkXlis3KfoKkmOghbo5sCu4yCj(HIYQZGk(0Pbv8L4zvhs6XxecXtGYjo7NBAxOULiiPKpAtOCA(r9pAerqiepbkN4SFUPDH6wIGKs(OnHYzC97Jh1C4PYjQy)s8SQdj9OMdpvwC2eP9jXZQoK0tDvkYQZGk(0Pbv8LK9MZJVQ5WtL)6qAxOd9g8L4zvhs6XeA0N8xhs7cDO3GVejkkwACe8ycn6t(RdPDHo0BWxIefflfPpoT4G7pUCpmAKVETpSQdLAmrQ2urpRlOg9TpNXhnQUkfPON1fuJ(KRbF8qe1C4PYFDiTl0HEd(s8SQdj9qetOrFYbU)U6mOkJJwCbHm1drmHg9jlXJvZ5KXrlUGqM6dihtOrFqPON1fuJ(Odzge3IZ2cZ5OMqJ(OUaQeF2e5ycn8Iu1C4PqqoMqJ(GsrpRlOg9rhYmiUfNTf9SUGA0hXlis7sHsqqYjxIxqKUjlCivyqnocCYL4OWXxFnHg9jNOI9lJJwCbHm1Jj0Op5evSFzC0IliKP0hNwCW95mUCh(mAeruZHNkNOI9lXZQoK0JVieINaLtC2p30UqDlrqsjF0Mq508J6F0O6QuKzTsH6JM)YhnHoAKj0Opju0VitIefflnocEmHg9jHI(fzsKOOyPi9XPfhC)XL7y0itOrFYbU)U6mOkrIIILghbpMqJ(KdC)D1zqvIefflfPpoT4G7pUCh(4JhFRRsr(RdPDHo0BWxUggnIiQ5WtL)6qAxOd9g8L4zvhs6dihtOrFqPON1fuJ(Odzge3IZ2dTg9bYXeA0huk6zDb1Op6qMbXT4SD11njTSEUb5ycn6dkf9SUGA0hDiZG4wC2UIpeF)JJaihtOrFqPON1fuJ(Odzge3IZ2L4XQRBsqoMqJ(GsrpRlOg9rhYmiUfNTTtGq9nhvyohihtOrFqPON1fuJ(Odzge3IZ2fNnrO(H)iXrHJV(QMdpvwC2ePdMkYK4zvhs6XeA4fP4HZaH7UxFgnYeA4fP4HZaH7Uh8XtDvkYSwPq9rZF5JMq9qeJlXpuuwDguXNonOIVepR6qsqoMqJ(GsrpRlOg9rhYmiUfNTh4(7QZGkXrHtDvkYbU)w4m4u(Ojup1vPif9SUGA0N8XPfhCxHbvQgteKJj0OpOu0Z6cQrF0HmdIBXz7bU)U6mOsCu4uxLImRvkuF08x(OjuqoMqJ(GsrpRlOg9rhYmiUfNTh4(7QZGkXrHZWJEPeeKYCLqr)Imp1vPiZqtJJaDnixdGCmHg9bLIEwxqn6JoKzqCloBpK14feLwC2eHGCmHg9bLIEwxqn6JoKzqCloBdf9lYiokCQRsrk6zDb1Op5Jtlo4UcdQunMON6QuKIEwxqn6tUggnQUkfPON1fuJ(KK9MZJOBhzV5KIEwxqn6t(40IdUVWGkvJjcYXeA0huk6zDb1Op6qMbXT4STl8ghbATNvIJcN6QuKIEwxqn6t(40IdUpbbPCAe1Jj0WlsXdNbc3nxqoMqJ(GsrpRlOg9rhYmiUfNTjFJqFqA9rtZiokCQRsrk6zDb1Op5Jtlo4(eeKYPrup1vPif9SUGA0NCnaYXeA0huk6zDb1Op6qMbXT4Snu0ViJ4OWrTNaQYm0CAMCqO7ZHRh3JAo8ujeTpocuTxImjEw1HKGCa5ycn6dkdfNqQON1fuJ(4SGinuCs8ztKtq4cn6JonciKwwqeKJj0OpOmuCcPIEwxqn6BloBVGinuCs8ztKtg3d4RzpAK0nFa1nVnajokCQRsrk6zDb1Op5AWJj0OpzjEKwDguLIm7jGqoJ7XeA0NSepsRodQYhfz2taPAmXDjiiLtJOGCmHg9bLHItiv0Z6cQrFBXz7fePHItIpBICM2ffeQnTl0PrEiecYXeA0hugkoHurpRlOg9TfNTf2jqhTUkfIxqK2LcLGGKtUeF2e5mTlkiuBAxOtJ8qiKkYSbfFAFiXrHtDvksrpRlOg9jxdJgzcn6torf7xghT4cczQhtOrFYjQy)Y4OfxqitPpoT4G7ZzC5oa5ycn6dkdfNqQON1fuJ(2IZ2lisdfNeVGiTlfkbbjNCj(SjYX4Y1JAwdPW4iGK0b3AAeqIJcN6QuKIEwxqn6tUggnYeA0NCIk2VmoAXfeYupMqJ(KtuX(LXrlUGqMsFCAXb3NZ4YDaYXeA0hugkoHurpRlOg9TfNTxqKgkojEbrAxkuccso5smwkOqPNnroeCgzyA)qA1ijGehfo1vPif9SUGA0NCnmAKj0Op5evSFzC0IliKPEmHg9jNOI9lJJwCbHmL(40IdUpNXL7aKJj0OpOmuCcPIEwxqn6BloBVGinuCs8cI0UuOeeKCYLySuqHspBICi4mYW0(H0jsAox0hXrHtDvksrpRlOg9jxdJgzcn6torf7xghT4cczQhtOrFYjQy)Y4OfxqitPpoT4G7ZzC5oa5ycn6dkdfNqQON1fuJ(2IZ2lisdfNeVGiTlfkbbjNCj(SjYPAoSepsRVDImIJcN6QuKIEwxqn6tUggnYeA0NCIk2VmoAXfeYupMqJ(KtuX(LXrlUGqMsFCAXb3NZ4YDaYXeA0hugkoHurpRlOg9TfNTxqKgkojEbrAxkuccso5s8ztKdmRf(xdfFiTyhbIJcN6QuKIEwxqn6tUggnYeA0NCIk2VmoAXfeYupMqJ(KtuX(LXrlUGqMsFCAXb3NZ4YDaYXeA0hugkoHurpRlOg9TfNTxqKgkojEbrAxkuccso5s8ztKJYL2HqA1E)HdXHqIJcN6QuKIEwxqn6tUggnYeA0NCIk2VmoAXfeYupMqJ(KtuX(LXrlUGqMsFCAXb3NZ4YDaYXeA0hugkoHurpRlOg9TfNTxqKgkojEbrAxkuccso5s8ztKJDIapL6)1kTl0nbKSNehfo1vPif9SUGA0NCnmAKj0Op5evSFzC0IliKPEmHg9jNOI9lJJwCbHmL(40IdUpNXL7aKJj0OpOmuCcPIEwxqn6BloBVGinuCs8cI0UuOeeKCYL4ZMiNdxV5OqUpBaIu8YStGpXrHtDvksrpRlOg9jxdJgzcn6torf7xghT4cczQhtOrFYjQy)Y4OfxqitPpoT4G7ZzC5oa5ycn6dkdfNqQON1fuJ(2IZ2lisdfNeVGiTlfkbbjNCj(SjYzAUs)tKKMHV5iHuhsyZBdqIJcN6QuKIEwxqn6tUggnYeA0NCIk2VmoAXfeYupMqJ(KtuX(LXrlUGqMsFCAXb3NZ4YDaYbKJj0OpOmuCcPzbHm6Wh9hk3CeMZrnHg9rDbuj(SjYjuCcPIEwxqn6J4OWXR9HvDOuJjs1Mk6zDb1OV95moihtOrFqzO4esZccz0Hp6puU3IZ2lisdfNqqoMqJ(GYqXjKMfeYOdF0FOCVfNTxqKgkoj(SjYzAxuqO20UqNg5HqiXrHdrq)EfddiP04syM9gKw6tPDHo0BW3Jx7dR6qPgtKQnv0Z6cQrF7Vhb5ycn6dkdfNqAwqiJo8r)HY9wC2EbrAO4K4ZMihJlHz2BqAPpL2f6qVbFIJchV2hw1HsnMivBQON1fuJ(2NZo2k3DSNETpSQdLL(ukzVQoK2hDbrqoMqJ(GYqXjKMfeYOdF0FOCVfNTxqKgkoj(SjY5Bv8lOIKuVDt2nLSDoIJchV2hw1HsnMivBQON1fuJ(21R9HvDOSp6cIuXs7sbKJj0OpOmuCcPzbHm6Wh9hk3BXz7fePHItIpBICm)EfdTINspBPHBbjokC8AFyvhk1yIuTPIEwxqn6BxV2hw1HY(OlisflTlfqoMqJ(GYqXjKMfeYOdF0FOCVfNTxqKgkoj(SjYbMfEXN6fVEsF0fcIJchV2hw1HsnMivBQON1fuJ(21R9HvDOSp6cIuXs7sbKJj0OpOmuCcPzbHm6Wh9hk3BXz7fePHItIpBICk9xdss8ODfgKHDuHZ2qCu441(WQouQXePAtf9SUGA03UETpSQdL9rxqKkwAxkGCmHg9bLHItinliKrh(O)q5EloBVGinuCsmwkOqPNnroz2p7leusCAk(H5cUeFqoMqJ(GYqXjKMfeYOdF0FOCVfNTxqKgkoj(SjYzAUs)tKKMHV5iHuhsyZBdqIJchV2hw1HsnMivBQON1fuJ(2LZo2HN6QuKIEwxqn6ts2BopETpSQdLAmrQ2urpRlOg9TRx7dR6qzF0fePIL2LcihtOrFqzO4esZccz0Hp6puU3IZ2lisdfNeF2e5yNiWtP(FTs7cDtaj7jXrHJx7dR6qPgtKQnv0Z6cQrF7Yzh7WtDvksrpRlOg9jj7nNhV2hw1HsnMivBQON1fuJ(21R9HvDOSp6cIuXs7sbKJj0OpOmuCcPzbHm6Wh9hk3BXz7fePHItIpBICoC9MJc5(SbisXlZob(ehfoETpSQdLAmrQ2urpRlOg9Tlh)Wo8uxLIu0Z6cQrFsYEZ5XR9HvDOuJjs1Mk6zDb1OVD9AFyvhk7JUGivS0Uua5aYXeA0hugkoHuxVHo8r)HYnNfePHItIpBIC0GeHA)tQOjrIsCu441(WQouQXePAtf9SUGA03UETpSQdL9rxqKkwAxkGCmHg9bLHIti11BOdF0FOCVfNTxqKgkojglfuO0ZMihb3cxRFFHGwDgujokC8AFyvhk1yIuTPIEwxqn6BxV2hw1HY(OlisflTlfqoGCmHg9bLFpqhYmiY5xhs7cDO3GpihtOrFq53d0HmdIBXz7IZMiu)WFK4OWXxtOHxKIhodeUlhV2hw1HYSwPq9rZFAXzteQF4p6XxnMOFwxLIu0Z6cQrFsNbvks0H4XD9AFyvhkjrNXnT4Sjc1p8h9Xhp1vPiZALc1hn)LpAcfKJj0OpO87b6qMbXT4S9a3FxDgujokCQRsrM1kfQpA(lF0ekihtOrFq53d0HmdIBXz7s8iT6mOs8cI0UuOeeKCYL4fePBYchsfguJJaNCjokCiIVMqdVifpCgiCxoETpSQdLz2tsfguPfNnrO(H)OhF1yI(zDvksrpRlOg9jDguPirhIh31R9HvDOKeDg30IZMiu)WF0hF8qKs8iuTxXxAcn8IE8Li1vPiZqtJJaDniF0eQhIuxLImRvkuF08x(Ojupez4rV0UuOeeKYs8iT6mO6XxtOrFYs8iT6mOkfz2taH7YzVJg5Rj0Op5qwJxquAXztekfz2taH7YjxpQ5WtLdznEbrPfNnrOepR6qsFgnYx1C4PsZHefQVb5sdslRNBjEw1HKEeD7i7nNK8nc9bP1hnnt(OrYTpJg5RAo8ujeTpocuTxImjEw1HKEu7jGQmdnNMjhe6(C46X9XhFa5ycn6dk)EGoKzqCloBlmNJAcn6J6cOs8ztKJj0WlsvZHNcb5ycn6dk)EGoKzqCloBpW93vNbvIJcN6QuKdC)TWzWP8rtOEeguPAmX9RRsroW93cNbNYhNwCqp1vPi)1H0Uqh6n4lFCAXb3vyqLQXeb5ycn6dk)EGoKzqCloBxIhPvNbvIxqK2LcLGGKtUeVGiDtw4qQWGACe4KlXrHdr81eA4fP4HZaH7YXR9HvDOmZEsQWGkT4Sjc1p8h94Rgt0pRRsrk6zDb1OpPZGkfj6q84UETpSQdLKOZ4MwC2eH6h(J(4JhIuIhHQ9k(stOHx0JV1vPiZqtJJaDniF0eQhFv7jGQmdnNMjhe6UC46XhnIiQ5WtLq0(4iq1EjYK4zvhs6JpGCmHg9bLFpqhYmiUfNTlXJ0QZGkXlis7sHsqqYjxIxqKUjlCivyqnocCYL4OWHi(Acn8Iu8WzGWD541(WQouMzpjvyqLwC2eH6h(JE8vJj6N1vPif9SUGA0N0zqLIeDiECxV2hw1Hss0zCtloBIq9d)rF8XdrkXJq1EfFPj0Wl6rnhEQeI2hhbQ2lrMepR6qspQ9eqvMHMtZKdcDFoC94E8TUkfzgAACeORb5JMq9qetOrFsOOFrMejkkwACegnIi1vPiZqtJJaDniF0eQhIuxLImRvkuF08x(OjuFa5ycn6dk)EGoKzqCloBpW93vNbvIJcNHh9sjiiL5kHI(fzEQRsrMHMghb6AqUg8OMdpvcr7JJav7LitINvDiPh1EcOkZqZPzYbHUphUECpeXxtOHxKIhodeUlhV2hw1HYSwPq9rZFAXzteQF4p6XxnMOFwxLIu0Z6cQrFsNbvks0H4XD9AFyvhkjrNXnT4Sjc1p8h9XhqoMqJ(GYVhOdzge3IZ2dznEbrPfNnriXrHdrgE0lLGGuMRCiRXlikT4Sjc9uxLImdnnoc01G8rtOGCmHg9bLFpqhYmiUfNTHI(fzehfoQ9eqvMHMtZKdcDFoC94EuZHNkHO9XrGQ9sKjXZQoKeKJj0OpO87b6qMbXT4Sn5Be6dsRpAAgXrHJj0WlsXdNbc3DVGCmHg9bLFpqhYmiUfNTloBIq9d)rIJchFnHgErkE4mq4UC8AFyvhkZSNKkmOsloBIq9d)rp(QXe9Z6QuKIEwxqn6t6mOsrIoepURx7dR6qjj6mUPfNnrO(H)Op(aYXeA0hu(9aDiZG4wC2UepwnNdKdihtOrFqjuTJ0Es63QPrFCkoBIq9d)rIJchFnHgErkE4mq4UC8AFyvhkZALc1hn)PfNnrO(H)OhF1yI(zDvksrpRlOg9jDguPirhIh31R9HvDOKeDg30IZMiu)WF0hF8uxLImRvkuF08x(OjuqoMqJ(GsOAhP9K0VvtJ(2IZ2dC)D1zqL4OWPUkfzwRuO(O5V8rtOEQRsrM1kfQpA(lFCAXb33eA0NSepwnNtIefflfPAmrqoMqJ(GsOAhP9K0VvtJ(2IZ2dC)D1zqL4OWPUkfzwRuO(O5V8rtOE8D4rVuccszUYs8y1CUrJkXJq1EfFPj0WloAKj0Op5a3FxDguLXrlUGqM6dihtOrFqjuTJ0Es63QPrFBXz7HSgVGO0IZMiK4OWrKzpbeUlhU2Jj0WlsXdNbc3DVEiIx7dR6q5qwJxqu6q3U4iaYXeA0hucv7iTNK(TAA03wC2EG7VRodQehfo1vPiZALc1hn)LpAc1JApbuLzO50m5Gq3NdxpUh1C4PsiAFCeOAVezs8SQdjb5ycn6dkHQDK2ts)wnn6BloBpW93vNbvIJcN6QuKdC)TWzWP8rtOEeguPAmX9RRsroW93cNbNYhNwCqqoMqJ(GsOAhP9K0VvtJ(2IZ2L4rA1zqL4fePDPqjii5KlXlis3KfoKkmOghbo5sCu44BDvkYFDiTl0HEd(sYEZ5HiL4rOAVIV0eA4f9Xdr8AFyvhklXJ0QZGkDOBxCe84RV(Acn6twIhRMZjrIIILghHrJmHg9jh4(7QZGQejkkwACe8XtDvkYm004iqxdYhnH6ZOr(QMdpvcr7JJav7LitINvDiPh1EcOkZqZPzYbHUphUECp(wxLImdnnoc01G8rtOEiIj0Opju0VitIefflnocJgrK6QuKzTsH6JM)YhnH6Hi1vPiZqtJJaDniF0eQhtOrFsOOFrMejkkwACe8qetOrFYbU)U6mOkJJwCbHm1drmHg9jlXJvZ5KXrlUGqM6Jp(aYXeA0hucv7iTNK(TAA03wC2EG7VRodQehfodp6LsqqkZvcf9lY8uxLImdnnoc01GCn4rnhEQeI2hhbQ2lrMepR6qspQ9eqvMHMtZKdcDFoC94EiIVMqdVifpCgiCxoETpSQdLzTsH6JM)0IZMiu)WF0JVAmr)SUkfPON1fuJ(KodQuKOdXJ761(WQousIoJBAXzteQF4p6JpGCmHg9bLq1os7jPFRMg9TfNThYA8cIsloBIqIJchFRRsrMHMghb6Aq(Oj0rJ8Li1vPiZALc1hn)LpAc1JVMqJ(KL4rA1zqvkYSNac3D8rJuZHNkHO9XrGQ9sKjXZQoK0JApbuLzO50m5Gq3NdxpUp(4JhI41(WQouoK14feLo0TlocGCmHg9bLq1os7jPFRMg9TfNTfMZrnHg9rDbuj(SjYXeA4fPQ5WtHGCmHg9bLq1os7jPFRMg9TfNTjFJqFqA9rtZiokCmHgErkE4mq4U5cYXeA0hucv7iTNK(TAA03wC2wyoh1eA0h1fqL4ZMiNqXjK66n0Hp6puUb5ycn6dkHQDK2ts)wnn6BloBdf9lYiokCu7jGQmdnNMjhe6(C46X9OMdpvcr7JJav7LitINvDijiNDgW4khAgGHxViKbyQ9eqfsmGfkGfqaZamcwCaM2aMWGkGXfD2eH6h(JaMbbSs4C4dyXbv0ibSUayCX4XQ5CsqoMqJ(GsOAhP9K0VvtJ(2IZ2fNnrO(H)iXrHJj0WlsXdNbc3LJx7dR6qzM9KuHbvAXzteQF4p6XxnMOFwxLIu0Z6cQrFsNbvks0H4XD9AFyvhkjrNXnT4Sjc1p8h9bKJj0OpOeQ2rApj9B10OVT4SDjESAohihtOrFqjuTJ0Es63QPrFBXzBOOFrwstAkba]] )


end
