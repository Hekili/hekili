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
    
    spec:RegisterPack( "Fire", 20200330, [[d4uhOcqieIhPukDjLQuytufFcHQOrrvPtrvXQuQsELsjZcvYTOQkTlI(LsfdtHQJjsAzkvXZqOyAuvfDnLs12ukf9nQQcnoekPZrvvP1PuLkZtPQUhQyFkv6GkLc1cfP6HiuvteHQKlQukeBeHs9rLQuLgjcL4KiufwPiXlvkfsZuPkLUjvvf7uKYpvQsvnuLQu0svQsv8uu1uvOCvLsbFfHQu7vu)fPbJYHPSyj9yctgrxgAZs8zemArCAHvtvvWRPQYSPYTv0Uv53snCfCCQQQwUQEoOPt66kz7uL(UsX4riDEuPwpcvMVcz)aNtnpwMN0umN2EgFpJpoXqmJl3tQ(ZTzQ(3mVY9aM5hmHFgbmZF2eZ8e74Xm)GXTRnY8yzEyVEbM5tuDaU3TZoecnzvLIEUdmMlNPrFI3k6oWyk2jZxxHtjEC5AMN0umN2EgFpJpoXqmJl3tQ(ZTzQ(JzEBPj9N55JjXpZNeKK4LRzEsekY8BlGrSJhbm)JrabPSTawIQdW9UD2HqOjRQu0ZDGXC5mn6t8wr3bgtXoGu2waZ)yVibWiMX5cW2Z47zCqkGu2waJ4NyhbeU3bszBbm)fW2gGiGPXePAtjdeWEttWhW0e7am1EcOk1yIuTPKbcyL(bmNbv)fII(ibmRgUq5gWwqJacLGu2waZFbSTHbstraZ1ecbG94EhGT3UebjGr86rBcLGu2waZFbS92UH4bycdQa2J()kECINcbSs)agXVN1fuJ(amFdjk5cWi7J4PcyjTJeWcfWk9dygGvEeMay(huX(bmHbvFKzExavyESmFO4esD9g6Wh9hk35XYPLAESmpEw1HK50Z8MqJ(Y8AqIqT)jv0KirZ8Ipu8dlZ71(WQouQXePAtf9SUGA0hGTlG51(WQou2hDbrQyPDPK5pBIzEnirO2)KkAsKOznN2EYJL5XZQoKmNEM3eA0xMxWTW163xiOvNb1mV4df)WY8ETpSQdLAmrQ2urpRlOg9by7cyETpSQdL9rxqKkwAxkzESuqHspBIzEb3cxRFFHGwDguZAwZ8IEwxqn6JoKyqmpwoTuZJL5XZQoKmNEMx8HIFyz(6QuKIEwxqn6ts2BUmVj0OVmVliKOqQ)WIKWepnR502tESmpEw1HK50Z8Ipu8dlZxxLIu0Z6cQrFsYEZL5nHg9L5RgbAxO6hc)GznNgXKhlZJNvDizo9mV4df)WY8MqdVifpCgieW2fWsfW8ay1vPif9SUGA0NKS3CzEtOrFzEx4noc0ApRznNM)mpwM3eA0xMV66MK2fQMGu8Wj3zE8SQdjZPN1CABppwM3eA0xMFIZ(5M2fQBjcsk5J2eM5XZQoKmNEwZPTnZJL5nHg9L530VJ0lgh9ryF2jWmpEw1HK50ZAon)X8yzE8SQdjZPN5xqKUjjCivyqnoc50snZl(qXpSmViXEcieW2LdGLkG5bW8fW8fWmHg9jlXJ0QZGQuKypbeslVj0OpZbyBby(cy1vPif9SUGA0N8XPfheW8xaRUkfz1zqfF60Gk(sY1BA0hG5dGT3aWeD7i7nNSepsRodQsY1BA0hG5VaMVawDvksrpRlOg9jFCAXbbmFaS9gaMVawDvkYQZGk(0Pbv8LKR30OpaZFbSXLBhW8bW8bW2LdGnoGnAeGreaZio8dfLvNbv8PtdQ4lXZQoKeWgncWicGPMdpvwC2eP9jXZQoKeWgncWQRsrk6zDb1Op5JtloiGTphaRUkfz1zqfF60Gk(sY1BA0hGnAeGvxLIS6mOIpDAqfF5JtloiGTpGnUC7a2Orag6)RyyajLjCpGVM8Ors38bu382aeW8ayIUDK9MtMW9a(AYJgjDZhqDZBdqkXm(4P6p3J8XPfheW2hW2oG5dG5bWQRsrk6zDb1Op5AaW8ay(cyebWmHg9jHI(fjsKOOyPXraW8ayebWmHg9jh4(7QZGQmoAXfesuaZdGvxLImbnnoc01GCnayJgbyMqJ(Kqr)IejsuuS04iayEaS6QuKjTsH6JMFsYEZbyEamFbS6QuKjOPXrGUgKK9MdWgncWmId)qrz1zqfF60Gk(s8SQdjbmFaSrJamJ4WpuuwDguXNonOIVepR6qsaZdGPMdpvwC2eP9jXZQoKeW8ayMqJ(KdC)D1zqvghT4ccjkG5bWQRsrMGMghb6Aqs2BoaZdGvxLImPvkuF08ts2BoaZNm)cI0UuOeeK50snZBcn6lZxIhPvNb1SMtJynpwMhpR6qYC6zEXhk(HL5RRsrk6zDb1OpjzV5Y8MqJ(Y8)6qAxOd9g8ZAon)BESmpEw1HK50Z8lis3KeoKkmOghHCAPM5nHg9L5lXJ0QZGAMx8HIFyzEJ4WpuuwDguXNonOIVepR6qsaZdG5lGHqiEcuoXz)Ct7c1TebjL8rBcLtZFOFaB0iaJiagcH4jq5eN9ZnTlu3seKuYhTjuoJRFaZhaZdGPMdpvorf7xINvDijG5bWuZHNkloBI0(K4zvhscyEaS6QuKvNbv8PtdQ4lj7nhG5bW8fWuZHNk)1H0Uqh6n4lXZQoKeW8ayMqJ(K)6qAxOd9g8LirrXsJJaG5bWmHg9j)1H0Uqh6n4lrIIILI0hNwCqaBFaBC52eWgncW8fW8AFyvhk1yIuTPIEwxqn6dW2NdGnoGnAeGvxLIu0Z6cQrFY1aG5dG5bWicGPMdpv(RdPDHo0BWxINvDijG5bWicGzcn6toW93vNbvzC0IliKOaMhaJiaMj0OpzjESAoNmoAXfesuaZNSMtl1XZJL5XZQoKmNEM3eA0xMxyoh1eA0h1fqnZ7cOspBIzEtOHxKQMdpfM1CAPMAESmpEw1HK50Z8lis3KeoKkmOghHCAPM5fFO4hwM3xaZxaZeA0NCIk2VmoAXfesuaZdGzcn6torf7xghT4ccjk9XPfheW2NdGnUC7aMpa2Oragram1C4PYjQy)s8SQdjbmpaMVagcH4jq5eN9ZnTlu3seKuYhTjuon)H(bSrJaS6QuKjTsH6JMFYhnHcyJgbyMqJ(Kqr)IejsuuS04iayEamtOrFsOOFrIejkkwksFCAXbbS9bSXLBhWgncWmHg9jh4(7QZGQejkkwACeampaMj0Op5a3FxDguLirrXsr6JtloiGTpGnUC7aMpaMpaMhaZxaRUkf5VoK2f6qVbF5AaWgncWicGPMdpv(RdPDHo0BWxINvDijG5tMFbrAxkuccYCAPM5nHg9L5f9SUGA0xwZPL6EYJL5nHg9L5hAn6lZJNvDizo9SMtlvIjpwM3eA0xMV66MKwwp3zE8SQdjZPN1CAP6pZJL5nHg9L5R4dX3V4iK5XZQoKmNEwZPL62ZJL5nHg9L5lXJvx3KzE8SQdjZPN1CAPUnZJL5nHg9L5TtGq9nhvyoxMhpR6qYC6znNwQ(J5XY84zvhsMtpZl(qXpSmVVaMVaMAo8uzXztKoyQirINvDijG5bWmHgErkE4mqiGTlGThaZhaB0iaZeA4fP4HZaHa2Ua22eW8bW8ay1vPitALc1hn)KpAcfW8ayebWmId)qrz1zqfF60Gk(s8SQdjZ8MqJ(Y8fNnrO(HFywZPLkXAESmpEw1HK50Z8Ipu8dlZxxLICG7VfodoLpAcfW8ay1vPif9SUGA0N8XPfheW2fWeguPAmXmVj0OVm)a3FxDguZAoTu9V5XY84zvhsMtpZl(qXpSmFDvkYKwPq9rZp5JMqZ8MqJ(Y8dC)D1zqnR502Z45XY84zvhsMtpZl(qXpSm)WJEPeeKYuLqr)IeaZdGvxLImbnnoc01GCnK5nHg9L5h4(7QZGAwZPTNuZJL5nHg9L5hsA8cIsloBIWmpEw1HK50ZAoT9SN8yzE8SQdjZPN5fFO4hwMVUkfPON1fuJ(KpoT4Ga2UaMWGkvJjcyEaS6QuKIEwxqn6tUgaSrJaS6QuKIEwxqn6ts2BoaZdGj62r2BoPON1fuJ(KpoT4Ga2(aMWGkvJjM5nHg9L5HI(fjznN2EiM8yzE8SQdjZPN5fFO4hwMVUkfPON1fuJ(KpoT4Ga2(agbbPCAefW8ayMqdVifpCgieW2fWsnZBcn6lZ7cVXrGw7znR502J)mpwMhpR6qYC6zEXhk(HL5RRsrk6zDb1Op5JtloiGTpGrqqkNgrbmpawDvksrpRlOg9jxdzEtOrFzEY3i0hKwF00KSMtBpBppwMhpR6qYC6zEXhk(HL5v7jGQmbnNMihekGTphaJyghW8ayQ5WtLq0(4iq1EjsK4zvhsM5nHg9L5HI(fjznRzEtOHxKQMdpfMhlNwQ5XY84zvhsMtpZl(qXpSmVj0WlsXdNbcbSDbSubmpawDvksrpRlOg9jj7nhG5bW8fW8AFyvhk1yIuTPIEwxqn6dW2fWeD7i7nN0fEJJaT2ZQKC9Mg9byJgbyETpSQdLAmrQ2urpRlOg9by7ZbWghW8jZBcn6lZ7cVXrGw7znR502tESmpEw1HK50Z8Ipu8dlZ71(WQouQXePAtf9SUGA0hGTphaBCaB0iaZxaRUkf5VoK2f6qVbF5AaWgncWeD7i7nN8xhs7cDO3GV8XPfheW2fW0yIuTPKbcyEamtOrFYFDiTl0HEd(srI9eqiGTpGLkGnAeGreatnhEQ8xhs7cDO3GVepR6qsaZhaZdG5lGj62r2Bo5evSFj56nn6dW2hW8AFyvhk1yIuTPIEwxqn6dWgncW0yIuTPKbcy7dyETpSQdLAmrQ2urpRlOg9by(K5nHg9L5NOI9N1CAetESmpEw1HK50Z8Ipu8dlZRMdpvAoKOq9niXzqAz9ClXZQoKeW8ay(cy1vPif9SUGA0NKS3CaMhaJiawDvkYKwPq9rZp5JMqbSrJaS6QuKIEwxqn6tUgampaMj0OpzjEKwDguLIe7jGqaBFaZeA0NSepsRodQYPruQiXEcieW8ayebWQRsrM0kfQpA(jF0ekG5tM3eA0xMN8nc9bP1hnnjRznZhkoH0KGqcD4J(dL78y50snpwMhpR6qYC6zEXhk(HL59AFyvhk1yIuTPIEwxqn6dW2NdGnEM3eA0xMxyoh1eA0h1fqnZ7cOspBIz(qXjKk6zDb1OVSMtBp5XY8MqJ(Y8lisdfNWmpEw1HK50ZAonIjpwMhpR6qYC6zEtOrFz(PDrbHAt7cDAKhcHzEXhk(HL5jcGH()kggqsPrCWe7niT0Ns7cDO3GpG5bW8AFyvhk1yIuTPIEwxqn6dW2hWiwZ8NnXm)0UOGqTPDHonYdHWSMtZFMhlZJNvDizo9mVj0OVmVrCWe7niT0Ns7cDO3GFMx8HIFyzEV2hw1HsnMivBQON1fuJ(aS95ayBhW2cWsD7a2EbyETpSQdLL(ukzVQoK2hDbXm)ztmZBehmXEdsl9P0Uqh6n4N1CABppwMhpR6qYC6zEtOrFz(VvXVGkss92nz3uY25Y8Ipu8dlZ71(WQouQXePAtf9SUGA0hGTlG51(WQou2hDbrQyPDPK5pBIz(VvXVGkss92nz3uY25YAoTTzESmpEw1HK50Z8MqJ(Y8M)VIHwXtPNT0WTGzEXhk(HL59AFyvhk1yIuTPIEwxqn6dW2fW8AFyvhk7JUGivS0UuY8NnXmV5)RyOv8u6zlnClywZP5pMhlZJNvDizo9mVj0OVmpmj8Ip1lE9K(OlezEXhk(HL59AFyvhk1yIuTPIEwxqn6dW2fW8AFyvhk7JUGivS0UuY8NnXmpmj8Ip1lE9K(OleznNgXAESmpEw1HK50Z8MqJ(Y8L(RbjjE0UcdYWoQWzBY8Ipu8dlZ71(WQouQXePAtf9SUGA0hGTlG51(WQou2hDbrQyPDPK5pBIz(s)1GKepAxHbzyhv4SnznNM)npwMhpR6qYC6zEtOrFz(e7N9fckjonf)WCbXHFMhlfuO0ZMyMpX(zFHGsIttXpmxqC4N1CAPoEESmpEw1HK50Z8MqJ(Y8tZv6FIK0e8nhjK6qcBEBaM5fFO4hwM3R9HvDOuJjs1Mk6zDb1OpaBxoa223oG5bWQRsrk6zDb1OpjzV5ampaMx7dR6qPgtKQnv0Z6cQrFa2UaMx7dR6qzF0fePIL2LsM)SjM5NMR0)ejPj4Bosi1He282amR50sn18yzE8SQdjZPN5nHg9L5Tte4Pu)UwPDHUjGK9mZl(qXpSmVx7dR6qPgtKQnv0Z6cQrFa2UCaSTVDaZdGvxLIu0Z6cQrFsYEZbyEamV2hw1HsnMivBQON1fuJ(aSDbmV2hw1HY(OlisflTlLm)ztmZBNiWtP(DTs7cDtaj7zwZPL6EYJL5XZQoKmNEM3eA0xM)W1BokK7ZgGifVe7e4N5fFO4hwM3R9HvDOuJjs1Mk6zDb1OpaBxoaM)C7aMhaRUkfPON1fuJ(KK9MdW8ayETpSQdLAmrQ2urpRlOg9by7cyETpSQdL9rxqKkwAxkz(ZMyM)W1BokK7ZgGifVe7e4N1SM5jXITCAESCAPMhlZBcn6lZl61P4dhqNlZJNvDizo9SMtBp5XY84zvhsMtpZ3dzEiQzEtOrFzEV2hw1HzEVMBHzE1C4PYs8iuTxXxINvDijGTxawjEeQ2R4lFCAXbbSTamFbmr3oYEZjf9SUGA0N8XPfheW2laZxalvaZFbmV2hw1Hs)IJ0fhb6JKlHg9by7fGPMdpv6xCKU4iiXZQoKeW8bW8xaZeA0N8xhs7cDO3GVejkkwks1yIa2EbyQ5WtL)6qAxOd9g8L4zvhscy(ay7fGreat0TJS3CsrpRlOg9jF0i5gW2laRUkfPON1fuJ(KK9MlZ71E6ztmZRXePAtf9SUGA0xwZPrm5XY84zvhsMtpZ3dz(Pr0mVj0OVmVx7dR6WmVxZTWmVOBhzV5KtC2p30UqDlrqsjF0Mq5JtloyMx8HIFyzEecXtGYjo7NBAxOULiiPKpAtOCA(d9dyEaS6QuKtC2p30UqDlrqsjF0MqjzV5ampaMOBhzV5KtC2p30UqDlrqsjF0Mq5JtloiG5VaMx7dR6qPgtKQnv0Z6cQrFa2(CamV2hw1HYK2rsf9SUGA0hvtEeM0oYmVx7PNnXmVgtKQnv0Z6cQrFznNM)mpwMhpR6qYC6z(EiZpnIM5nHg9L59AFyvhM59AUfM5fD7i7nNCt)osVyC0hH9zNaLpoT4GzEXhk(HL5riepbk30VJ0lgh9ryF2jq508h6hW8ay1vPi30VJ0lgh9ryF2jqjzV5ampaMOBhzV5KB63r6fJJ(iSp7eO8XPfheW8xaZR9HvDOuJjs1Mk6zDb1OpaBFoaMx7dR6qzs7iPIEwxqn6JQjpctAhzM3R90ZMyMxJjs1Mk6zDb1OVSMtB75XY84zvhsMtpZBcn6lZlmNJAcn6J6cOM5DbuPNnXmFO4estccj0Hp6puUZAoTTzESmpEw1HK50Z8Ipu8dlZxxLIu0Z6cQrFsYEZL5nHg9L5NX)9tJPraZAon)X8yzE8SQdjZPN5fFO4hwM3xaZR9HvDOuJjs1Mk6zDb1OpaBFal1XbSrJamnMivBkzGa2(aMx7dR6qPgtKQnv0Z6cQrFaMpzEtOrFzEcl7jd7ODHAeh(TMK1CAeR5XY8MqJ(Y8I(e4PVPijT4SjM5XZQoKmNEwZP5FZJL5nHg9L5F0gIJaT4SjcZ84zvhsMtpR50sD88yzEtOrFz(slwqKKAeh(HI0kAZmpEw1HK50ZAoTutnpwM3eA0xMFy9rH74iqRodQzE8SQdjZPN1CAPUN8yzEtOrFz(pggCinokCWeyMhpR6qYC6znNwQetESmVj0OVmVMG01v71rsl9lWmpEw1HK50ZAoTu9N5XY84zvhsMtpZl(qXpSmFDvksrpRlOg9jj7nhG5bW8fW8AFyvhk1yIuTPIEwxqn6dW2fWklNJ(OiXEcivJjcyJgbyETpSQdLAmrQ2urpRlOg9by7cyAmrQ2uYabmFY8MqJ(Y8)6qAxOd9g8ZAoTu3EESmpEw1HK50Z8Ipu8dlZ71(WQouQXePAtf9SUGA0hGTphaB8mVj0OVmVWCoQj0OpQlGAM3fqLE2eZ8IEwxqn6JoKyqmR50sDBMhlZJNvDizo9m)cI0njHdPcdQXriNwQzEXhk(HL59fWqiepbkN4SFUPDH6wIGKs(OnHYP5p0pGnAeGHqiEcuoXz)Ct7c1TebjL8rBcLZ46hW8aygXHFOOS6mOIpDAqfFjEw1HKaMpaMhatKypbecyCaSPruQiXEcieW8ayebWQRsrM0kfQpA(jF0ekG5bWicG5lGvxLImbnnoc01G8rtOaMhaZxaRUkfPON1fuJ(KRbaZdG5lGzcn6twIhRMZjJJwCbHefWgncWmHg9jh4(7QZGQmoAXfesuaB0iaZeA0Nek6xKirIIILghbaZhaB0iatTNaQYe0CAICqOa2(CamIzCaZdGzcn6tcf9lsKirrXsJJaG5dG5dG5bWicG5lGreaRUkfzcAACeORb5JMqbmpagraS6QuKjTsH6JMFYhnHcyEaS6QuKIEwxqn6ts2BoaZdG5lGzcn6twIhRMZjJJwCbHefWgncWmHg9jh4(7QZGQmoAXfesuaZhaZNm)cI0UuOeeK50snZBcn6lZxIhPvNb1SMtlv)X8yzE8SQdjZPN57Hmpe1mVj0OVmVx7dR6WmVxZTWmVAo8u5VoK2f6qVbFjEw1HKaMhat0TJS3CYFDiTl0HEd(YhNwCqaBFat0TJS3CYs8iT6mOkllNJ(OiXEcivJjcyEamFbmV2hw1HsnMivBQON1fuJ(aSDbmtOrFYFDiTl0HEd(YYY5OpksSNas1yIaMpaMhaZxat0TJS3CYFDiTl0HEd(YhNwCqaBFatJjs1MsgiGnAeGzcn6t(RdPDHo0BWxksSNacbSDbSXbmFaSrJamV2hw1HsnMivBQON1fuJ(aS9bmtOrFYs8iT6mOkllNJ(OiXEcivJjcyEamV2hw1HsnMivBQON1fuJ(aS9bmnMivBkzGzEV2tpBIz(s8iT6mOsh62fhHSMtlvI18yzE8SQdjZPN5fFO4hwMVUkf5VoK2f6qVbF5AaW8ay(cyETpSQdLAmrQ2urpRlOg9by7cyJdy(K5nHg9L5fMZrnHg9rDbuZ8UaQ0ZMyM)7b6qIbXSMtlv)BESmpEw1HK50Z89qMhIAM3eA0xM3R9HvDyM3R5wyMxnhEQ8xhs7cDO3GVepR6qsaZdGj62r2Bo5VoK2f6qVbF5JtloiGTpGj62r2Bo5qsJxquAXztekllNJ(OiXEcivJjcyEamFbmV2hw1HsnMivBQON1fuJ(aSDbmtOrFYFDiTl0HEd(YYY5OpksSNas1yIaMpaMhaZxat0TJS3CYFDiTl0HEd(YhNwCqaBFatJjs1MsgiGnAeGzcn6t(RdPDHo0BWxksSNacbSDbSXbmFaSrJamV2hw1HsnMivBQON1fuJ(aS9bmtOrFYHKgVGO0IZMiuwwoh9rrI9eqQgteW8ayETpSQdLAmrQ2urpRlOg9by7dyAmrQ2uYaZ8ETNE2eZ8djnEbrPdD7IJqwZPTNXZJL5XZQoKmNEMFbr6MKWHuHb14iKtl1mV4df)WY8(cyebW8AFyvhklXJ0QZGkDOBxCeaSrJaS6QuK)6qAxOd9g8LRbaZhaZdG5lG51(WQouQXePAtf9SUGA0hGTlGnoG5dG5bW8fWmHgErkE4mqiGTlhaZR9HvDOmXEsQWGkT4Sjc1p8dbmpaMVaMgteW8xaRUkfPON1fuJ(KodQuKOdXJa2UaMx7dR6qjj6mUPfNnrO(HFiG5dG5dG5bWicGvIhHQ9k(stOHxeW8ay1vPitALc1hn)KK9MdW8ay(cyebWmId)qrz1zqfF60Gk(s8SQdjbSrJaS6QuKvNbv8PtdQ4lFCAXbbS9bSXLBhW8jZVGiTlfkbbzoTuZ8MqJ(Y8L4rA1zqnR502tQ5XY84zvhsMtpZVGiDts4qQWGACeYPLAMx8HIFyz(s8iuTxXxAcn8IaMhatKypbecy7YbWsfW8ay(cyebW8AFyvhklXJ0QZGkDOBxCeaSrJaS6QuK)6qAxOd9g8LRbaZhaZdG5lGreaZio8dfLvNbv8PtdQ4lXZQoKeWgncWQRsrwDguXNonOIV8XPfheW2hWgxUDaZhaZdG5lGreaZeA0NSepwnNtIefflnocaMhaJiaMj0Op5a3FxDguLXrlUGqIcyEaS6QuKjOPXrGUgKRbaB0iaZeA0NSepwnNtIefflnocaMhaRUkfzsRuO(O5NKS3Ca2OraMj0Op5a3FxDguLXrlUGqIcyEaS6QuKjOPXrGUgKK9MdW8ay1vPitALc1hn)KK9MdW8jZVGiTlfkbbzoTuZ8MqJ(Y8L4rA1zqnR502ZEYJL5XZQoKmNEMx8HIFyzEV2hw1HsnMivBQON1fuJ(aSDbSXZ8MqJ(Y8cZ5OMqJ(OUaQzExav6ztmZdv7iTNK(TAA0xwZAMpuCcPIEwxqn6lpwoTuZJL5XZQoKmNEM)SjM5dcxOrF0PraH0YcIzEtOrFz(GWfA0hDAeqiTSGywZPTN8yzE8SQdjZPN5nHg9L5t4EaFn5rJKU5dOU5TbyMx8HIFyz(6QuKIEwxqn6tUgampaMj0OpzjEKwDguLIe7jGqaJdGnoG5bWmHg9jlXJ0QZGQ8rrI9eqQgteW2fWiiiLtJOz(ZMyMpH7b81Khns6MpG6M3gGznNgXKhlZJNvDizo9m)ztmZpTlkiuBAxOtJ8qimZBcn6lZpTlkiuBAxOtJ8qimR508N5XY81vPqpBIz(PDrbHAt7cDAKhcHurInO4t7dZ8Ipu8dlZxxLIu0Z6cQrFY1aGnAeGzcn6torf7xghT4ccjkG5bWmHg9jNOI9lJJwCbHeL(40Idcy7ZbWgxU9m)cI0UuOeeK50snZBcn6lZlStGoADvkzE8SQdjZPN1CABppwMhpR6qYC6z(ZMyM3iU1JAsdPW4iGK0b3AAeWm)cI0UuOeeK50snZBcn6lZBe36rnPHuyCeqs6GBnncyMx8HIFyz(6QuKIEwxqn6tUgaSrJamtOrFYjQy)Y4OfxqirbmpaMj0Op5evSFzC0IliKO0hNwCqaBFoa24YTN1CABZ8yzE8SQdjZPN5nHg9L5j4mYW0(H0QrsaZ8lis7sHsqqMtl1mV4df)WY81vPif9SUGA0NCnayJgbyMqJ(KtuX(LXrlUGqIcyEamtOrFYjQy)Y4OfxqirPpoT4Ga2(CaSXLBpZJLcku6ztmZtWzKHP9dPvJKaM1CA(J5XY84zvhsMtpZBcn6lZtWzKHP9dPtK0CUOVm)cI0UuOeeK50snZl(qXpSmFDvksrpRlOg9jxda2OraMj0Op5evSFzC0IliKOaMhaZeA0NCIk2VmoAXfesu6JtloiGTphaBC52Z8yPGcLE2eZ8eCgzyA)q6ejnNl6lR50iwZJL5XZQoKmNEM)SjM5RMdlXJ06BNijZVGiTlfkbbzoTuZ8MqJ(Y8vZHL4rA9TtKK5fFO4hwMVUkfPON1fuJ(KRbaB0iaZeA0NCIk2VmoAXfesuaZdGzcn6torf7xghT4ccjk9XPfheW2NdGnUC7znNM)npwMhpR6qYC6z(ZMyMhM0c)QHIpKwSJqMFbrAxkuccYCAPM5nHg9L5HjTWVAO4dPf7iK5fFO4hwMVUkfPON1fuJ(KRbaB0iaZeA0NCIk2VmoAXfesuaZdGzcn6torf7xghT4ccjk9XPfheW2NdGnUC7znNwQJNhlZJNvDizo9m)ztmZReNDiKwT3p4qCimZVGiTlfkbbzoTuZ8MqJ(Y8kXzhcPv79doehcZ8Ipu8dlZxxLIu0Z6cQrFY1aGnAeGzcn6torf7xghT4ccjkG5bWmHg9jNOI9lJJwCbHeL(40Idcy7ZbWgxU9SMtl1uZJL5XZQoKmNEM)SjM5Tte4Pu)UwPDHUjGK9mZVGiTlfkbbzoTuZ8MqJ(Y82jc8uQFxR0Uq3eqYEM5fFO4hwMVUkfPON1fuJ(KRbaB0iaZeA0NCIk2VmoAXfesuaZdGzcn6torf7xghT4ccjk9XPfheW2NdGnUC7znNwQ7jpwMhpR6qYC6z(ZMyM)W1BokK7ZgGifVe7e4N5xqK2LcLGGmNwQzEtOrFz(dxV5OqUpBaIu8sStGFMx8HIFyz(6QuKIEwxqn6tUgaSrJamtOrFYjQy)Y4OfxqirbmpaMj0Op5evSFzC0IliKO0hNwCqaBFoa24YTN1CAPsm5XY84zvhsMtpZF2eZ8tZv6FIK0e8nhjK6qcBEBaM5xqK2LcLGGmNwQzEtOrFz(P5k9prsAc(MJesDiHnVnaZ8Ipu8dlZxxLIu0Z6cQrFY1aGnAeGzcn6torf7xghT4ccjkG5bWmHg9jNOI9lJJwCbHeL(40Idcy7ZbWgxU9SM1m)WJIEwnnpwoTuZJL5nHg9L5TxyhsJtrNdfAMhpR6qYC6znN2EYJL5XZQoKmNEMVhY8quZ8MqJ(Y8ETpSQdZ8En3cZ8O)VIHbKuoTlkiuBAxOtJ8qieWgncWq)FfddiPKGZidt7hsRgjbeWgncWq)FfddiPKGZidt7hsNiP5CrFa2Orag6)RyyajLbHl0Op60iGqAzbraB0iad9)vmmGKsL4SdH0Q9(bhIdHa2Orag6)RyyajLgXTEutAifghbKKo4wtJacyJgbyO)VIHbKuANiWtP(DTs7cDtaj7jGnAeGH()kggqsjmPf(vdfFiTyhbaB0iad9)vmmGKYdxV5OqUpBaIu8sStGpGnAeGH()kggqsz1CyjEKwF7ejzEV2tpBIzErpRlOg9r7JUGywZPrm5XY84zvhsMtpZ3dzEiQzEtOrFzEV2hw1HzEVMBHzE0)xXWasknIdMyVbPL(uAxOd9g8bmpaMx7dR6qPON1fuJ(O9rxqmZ71E6ztmZx6tPK9Q6qAF0feZAon)zESmpEw1HK50Z89qMhIAM3eA0xM3R9HvDyM3R5wyMFpJdy7fG5lG51(WQouk6zDb1OpAF0febmpagramV2hw1HYsFkLSxvhs7JUGiG5dGTfG5phhW2laZxaZR9HvDOS0Nsj7v1H0(Olicy(ayBby7z7a2Eby(cyO)VIHbKuAehmXEdsl9P0Uqh6n4dyEamIayETpSQdLL(ukzVQoK2hDbraZhaBlaJyfW2laZxad9)vmmGKYPDrbHAt7cDAKhcHaMhaJiaMx7dR6qzPpLs2RQdP9rxqeW8jZ71E6ztmZ3hDbrQyPDPK1CABppwMhpR6qYC6z(EiZ)ie1mVj0OVmVx7dR6WmVx7PNnXmFs7iPIEwxqn6JQjpctAhzMNel2YPz(9mEwZPTnZJL5XZQoKmNEMVhY8quZ8MqJ(Y8ETpSQdZ8En3cZ87bW2latnhEQS4SjshmvKiXZQoKeW2cW8V(xaBVamIayQ5WtLfNnr6GPIejEw1HKzEXhk(HL59AFyvhktALc1hn)OfNnrO(HFiGXbWgpZ71E6ztmZN0kfQpA(rloBIq9d)WSMtZFmpwMhpR6qYC6z(EiZdrnZBcn6lZ71(WQomZ71ClmZtma2EbyQ5WtLfNnr6GPIejEw1HKa2waM)1)cy7fGreatnhEQS4SjshmvKiXZQoKmZl(qXpSmVx7dR6qzI9KuHbvAXzteQF4hcyCaSXZ8ETNE2eZ8j2tsfguPfNnrO(HFywZPrSMhlZJNvDizo9mFpK5FeIAM3eA0xM3R9HvDyM3R90ZMyMNeDg30IZMiu)WpmZtIfB50m)E2EwZP5FZJL5XZQoKmNEMVhY8pcrnZBcn6lZ71(WQomZ71E6ztmZ7xCKU4iqFKCj0OVmpjwSLtZ8Jl3twZPL645XY84zvhsMtpR50sn18yzE8SQdjZPN5pBIzEJ4Gj2BqAPpL2f6qVb)mVj0OVmVrCWe7niT0Ns7cDO3GFwZPL6EYJL5nHg9L5NX)9tJPraZ84zvhsMtpR50sLyYJL5nHg9L5hAn6lZJNvDizo9SMtlv)zESmVj0OVm)a3FxDguZ84zvhsMtpRznZdv7iTNK(TAA0xESCAPMhlZJNvDizo9mV4df)WY8(cyMqdVifpCgieW2LdG51(WQouM0kfQpA(rloBIq9d)qaZdG5lGPXebm)fWQRsrk6zDb1OpPZGkfj6q8iGTlG51(WQousIoJBAXzteQF4hcy(ay(ayEaS6QuKjTsH6JMFYhnHM5nHg9L5loBIq9d)WSMtBp5XY84zvhsMtpZl(qXpSmFDvkYKwPq9rZp5JMqbmpawDvkYKwPq9rZp5JtloiGTpGzcn6twIhRMZjrIIILIunMyM3eA0xMFG7VRodQznNgXKhlZJNvDizo9mV4df)WY81vPitALc1hn)KpAcfW8ay(cydp6LsqqktvwIhRMZbyJgbyL4rOAVIV0eA4fbSrJamtOrFYbU)U6mOkJJwCbHefW8jZBcn6lZpW93vNb1SMtZFMhlZJNvDizo9mV4df)WY8Ie7jGqaBxoagXayEamtOHxKIhodecy7cy7bW8ayebW8AFyvhkhsA8cIsh62fhHmVj0OVm)qsJxquAXzteM1CABppwMhpR6qYC6zEXhk(HL5RRsrM0kfQpA(jF0ekG5bWu7jGQmbnNMihekGTphaJyghW8ayQ5WtLq0(4iq1EjsK4zvhsM5nHg9L5h4(7QZGAwZPTnZJL5XZQoKmNEMx8HIFyz(6QuKdC)TWzWP8rtOaMhatyqLQXebS9bS6QuKdC)TWzWP8XPfhmZBcn6lZpW93vNb1SMtZFmpwMhpR6qYC6z(fePBschsfguJJqoTuZ8Ipu8dlZ7lGvxLI8xhs7cDO3GVKS3CaMhaJiawjEeQ2R4lnHgEraZhaZdGreaZR9HvDOSepsRodQ0HUDXraW8ay(cy(cy(cyMqJ(KL4XQ5CsKOOyPXraWgncWmHg9jh4(7QZGQejkkwACeamFampawDvkYe004iqxdYhnHcy(ayJgby(cyQ5WtLq0(4iq1EjsK4zvhscyEam1EcOktqZPjYbHcy7ZbWiMXbmpaMVawDvkYe004iqxdYhnHcyEamIayMqJ(Kqr)IejsuuS04iayJgbyebWQRsrM0kfQpA(jF0ekG5bWicGvxLImbnnoc01G8rtOaMhaZeA0Nek6xKirIIILghbaZdGreaZeA0NCG7VRodQY4OfxqirbmpagramtOrFYs8y1CozC0IliKOaMpaMpaMpz(fePDPqjiiZPLAM3eA0xMVepsRodQznNgXAESmpEw1HK50Z8Ipu8dlZp8OxkbbPmvju0VibW8ay1vPitqtJJaDnixdaMhatnhEQeI2hhbQ2lrIepR6qsaZdGP2tavzcAonroiuaBFoagXmoG5bWicG5lGzcn8Iu8WzGqaBxoaMx7dR6qzsRuO(O5hT4Sjc1p8dbmpaMVaMgteW8xaRUkfPON1fuJ(KodQuKOdXJa2UaMx7dR6qjj6mUPfNnrO(HFiG5dG5tM3eA0xMFG7VRodQznNM)npwMhpR6qYC6zEXhk(HL59fWQRsrMGMghb6Aq(OjuaB0iaZxaJiawDvkYKwPq9rZp5JMqbmpaMVaMj0OpzjEKwDguLIe7jGqaBxaBCaB0iatnhEQeI2hhbQ2lrIepR6qsaZdGP2tavzcAonroiuaBFoagXmoG5dG5dG5dG5bWicG51(WQouoK04feLo0TloczEtOrFz(HKgVGO0IZMimR50sD88yzE8SQdjZPN5nHg9L5fMZrnHg9rDbuZ8UaQ0ZMyM3eA4fPQ5WtHznNwQPMhlZJNvDizo9mV4df)WY8MqdVifpCgieW2fWsnZBcn6lZt(gH(G06JMMK1CAPUN8yzE8SQdjZPN5nHg9L5fMZrnHg9rDbuZ8UaQ0ZMyMpuCcPUEdD4J(dL7SMtlvIjpwMhpR6qYC6zEXhk(HL5v7jGQmbnNMihekGTphaJyghW8ayQ5WtLq0(4iq1EjsK4zvhsM5nHg9L5HI(fjznNwQ(Z8yzE8SQdjZPN5fFO4hwM3eA4fP4HZaHa2UCamV2hw1HYe7jPcdQ0IZMiu)WpeW8ay(cyAmraZFbS6QuKIEwxqn6t6mOsrIoepcy7cyETpSQdLKOZ4MwC2eH6h(HaMpzEtOrFz(IZMiu)WpmR50sD75XY8MqJ(Y8L4XQ5CzE8SQdjZPN1CAPUnZJL5nHg9L5HI(fjzE8SQdjZPN1SM5)EGoKyqmpwoTuZJL5nHg9L5)1H0Uqh6n4N5XZQoKmNEwZPTN8yzE8SQdjZPN5fFO4hwM3xaZeA4fP4HZaHa2UCamV2hw1HYKwPq9rZpAXzteQF4hcyEamFbmnMiG5VawDvksrpRlOg9jDguPirhIhbSDbmV2hw1Hss0zCtloBIq9d)qaZhaZhaZdGvxLImPvkuF08t(Oj0mVj0OVmFXzteQF4hM1CAetESmpEw1HK50Z8Ipu8dlZxxLImPvkuF08t(Oj0mVj0OVm)a3FxDguZAon)zESmpEw1HK50Z8lis3KeoKkmOghHCAPM5fFO4hwMNiaMVaMj0WlsXdNbcbSD5ayETpSQdLj2tsfguPfNnrO(HFiG5bW8fW0yIaM)cy1vPif9SUGA0N0zqLIeDiEeW2fW8AFyvhkjrNXnT4Sjc1p8dbmFamFampagraSs8iuTxXxAcn8IaMhaZxaJiawDvkYe004iqxdYhnHcyEamIay1vPitALc1hn)KpAcfW8ayebWgE0lTlfkbbPSepsRodQaMhaZxaZeA0NSepsRodQsrI9eqiGTlhaBpa2OraMVaMj0Op5qsJxquAXztekfj2taHa2UCaSubmpaMAo8u5qsJxquAXztekXZQoKeW8bWgncW8fWuZHNknhsuO(gK4miTSEUL4zvhscyEamr3oYEZjjFJqFqA9rttKpAKCdy(ayJgby(cyQ5WtLq0(4iq1EjsK4zvhscyEam1EcOktqZPjYbHcy7ZbWiMXbmFamFamFY8lis7sHsqqMtl1mVj0OVmFjEKwDguZAoTTNhlZJNvDizo9mVj0OVmVWCoQj0OpQlGAM3fqLE2eZ8MqdVivnhEkmR502M5XY84zvhsMtpZl(qXpSmFDvkYbU)w4m4u(OjuaZdGjmOs1yIa2(awDvkYbU)w4m4u(40IdcyEaS6QuK)6qAxOd9g8LpoT4Ga2UaMWGkvJjM5nHg9L5h4(7QZGAwZP5pMhlZJNvDizo9m)cI0njHdPcdQXriNwQzEXhk(HL5jcG5lGzcn8Iu8WzGqaBxoaMx7dR6qzI9KuHbvAXzteQF4hcyEamFbmnMiG5VawDvksrpRlOg9jDguPirhIhbSDbmV2hw1Hss0zCtloBIq9d)qaZhaZhaZdGreaRepcv7v8LMqdViG5bW8fWQRsrMGMghb6Aq(OjuaZdG5lGP2tavzcAonroiuaBxoagXmoGnAeGreatnhEQeI2hhbQ2lrIepR6qsaZhaZNm)cI0UuOeeK50snZBcn6lZxIhPvNb1SMtJynpwMhpR6qYC6z(fePBschsfguJJqoTuZ8Ipu8dlZteaZxaZeA4fP4HZaHa2UCamV2hw1HYe7jPcdQ0IZMiu)WpeW8ay(cyAmraZFbS6QuKIEwxqn6t6mOsrIoepcy7cyETpSQdLKOZ4MwC2eH6h(HaMpaMpaMhaJiawjEeQ2R4lnHgEraZdGPMdpvcr7JJav7LirINvDijG5bWu7jGQmbnNMihekGTphaJyghW8ay(cy1vPitqtJJaDniF0ekG5bWicGzcn6tcf9lsKirrXsJJaGnAeGreaRUkfzcAACeORb5JMqbmpagraS6QuKjTsH6JMFYhnHcy(K5xqK2LcLGGmNwQzEtOrFz(s8iT6mOM1CA(38yzE8SQdjZPN5fFO4hwMF4rVuccszQsOOFrcG5bWQRsrMGMghb6AqUgampaMAo8ujeTpocuTxIejEw1HKaMhatTNaQYe0CAICqOa2(CamIzCaZdGreaZxaZeA4fP4HZaHa2UCamV2hw1HYKwPq9rZpAXzteQF4hcyEamFbmnMiG5VawDvksrpRlOg9jDguPirhIhbSDbmV2hw1Hss0zCtloBIq9d)qaZhaZNmVj0OVm)a3FxDguZAoTuhppwMhpR6qYC6zEXhk(HL5jcGn8OxkbbPmv5qsJxquAXztecyEaS6QuKjOPXrGUgKpAcnZBcn6lZpK04feLwC2eHznNwQPMhlZJNvDizo9mV4df)WY8Q9eqvMGMttKdcfW2NdGrmJdyEam1C4PsiAFCeOAVejs8SQdjZ8MqJ(Y8qr)IKSMtl19KhlZJNvDizo9mV4df)WY8MqdVifpCgieW2fW2tM3eA0xMN8nc9bP1hnnjR50sLyYJL5XZQoKmNEMx8HIFyzEFbmtOHxKIhodecy7YbW8AFyvhktSNKkmOsloBIq9d)qaZdG5lGPXebm)fWQRsrk6zDb1OpPZGkfj6q8iGTlG51(WQousIoJBAXzteQF4hcy(ay(K5nHg9L5loBIq9d)WSMtlv)zESmVj0OVmFjESAoxMhpR6qYC6znRznZ7fFy0xoT9m(EgF89mU)uMAMFJ9xCeGzEIhZH(vKeW8VaMj0OpaZfqfkbPK5HdOiN22KyY8dFxchM53waJyhpcy(hJacszBbSevhG7D7SdHqtwvPON7aJ5YzA0N4TIUdmMIDaPSTaM)XErcGrmJZfGTNX3Z4GuaPSTagXpXociCVdKY2cy(lGTnaratJjs1MsgiG9MMGpGPj2byQ9eqvQXePAtjdeWk9dyodQ(lef9rcywnCHYnGTGgbekbPSTaM)cyBddKMIaMRjeca7X9oaBVDjcsaJ41J2ekbPSTaM)cy7TDdXdWegubSh9)v84epfcyL(bmIFpRlOg9by(gsuYfGr2hXtfWsAhjGfkGv6hWmaR8imbW8pOI9dycdQ(ibPaszBbSTrikkwkscyvS0pcyIEwnfWQiH4GsaBBSqGdkeWU(83e7NLLdWmHg9bbS(CClbPSTaMj0OpOC4rrpRMYP4mOFGu2waZeA0huo8OONvt3IZoLUjbPSTaMj0OpOC4rrpRMUfNDSfHjEQPrFGumHg9bLdpk6z10T4SJ9c7qACk6COqbPycn6dkhEu0ZQPBXzhV2hw1HCD2e5i6zDb1OpAF0fe5Qh4arLlVMBHCq)FfddiPCAxuqO20UqNg5Hq4OrO)VIHbKusWzKHP9dPvJKaoAe6)RyyajLeCgzyA)q6ejnNl6B0i0)xXWaskdcxOrF0PraH0YcIJgH()kggqsPsC2HqA1E)GdXHWrJq)FfddiP0iU1JAsdPW4iGK0b3AAeWrJq)FfddiP0orGNs97AL2f6Mas2ZrJq)FfddiPeM0c)QHIpKwSJWOrO)VIHbKuE46nhfY9zdqKIxIDc8hnc9)vmmGKYQ5Ws8iT(2jsaPycn6dkhEu0ZQPBXzhV2hw1HCD2e5u6tPK9Q6qAF0fe5Qh4arLlVMBHCq)FfddiP0ioyI9gKw6tPDHo0BW3Jx7dR6qPON1fuJ(O9rxqeKY2cyepuCcbmnXuaZEeWwqKeW6LcdseW6cGr87zDb1OpaZEeWUwbSfejbmRO4dyAsabmnMiGffattqUbSn9YrcydlfWmat)48dvaBbrsaBtOjagXVN1fuJ(aS(amdWGj2tIKaMOBhzV5KGumHg9bLdpk6z10T4SJx7dR6qUoBIC6JUGivS0Uu4Qh4arLlVMBHC2Z47LVETpSQdLIEwxqn6J2hDbrpeXR9HvDOS0Nsj7v1H0(Oli6Zw(ZX3lF9AFyvhkl9PuYEvDiTp6cI(S1E2(E5l6)RyyajLgXbtS3G0sFkTl0HEd(EiIx7dR6qzPpLs2RQdP9rxq0NTiw3lFr)FfddiPCAxuqO20UqNg5HqOhI41(WQouw6tPK9Q6qAF0fe9bKY2cye)Ewxqn6dWciG1NJBaBbrsaBtOj9sbmI397i9IXby79GW(StGaw)aM)bN9ZnG1faBVDjcsaJ41J2ecyrbWcfW2eohGvraZ8AHZQoeWmfWCObvattciGnTJBadII(iHawfl9JaMMGagcH4jqINqat0TJS3CawabShnsULGumHg9bLdpk6z10T4SJx7dR6qUoBICsAhjv0Z6cQrFun5rys7i5Qh48ievUiXITCkN9moiLTfWgljGaMx7dR6qadoGIOeieW0eeWU1SIpG1fatTNaQqaZuaBtsisamILwbmE9rZpaJy7Sjc1p8dHawVuyqIawxamIFpRlOg9byWKE5ibSkcyliskbPycn6dkhEu0ZQPBXzhV2hw1HCD2e5K0kfQpA(rloBIq9d)qU6boqu5kkC8AFyvhktALc1hn)OfNnrO(HFiNX5YR5wiN9SxQ5WtLfNnr6GPIejEw1HKB5F9V7fruZHNkloBI0btfjs8SQdjbPSTa2yjbeW8AFyvhcyWbueLaHaMMGa2TMv8bSUayQ9eqfcyMcyBscrcGrSypjGr8nOcyeBNnrO(HFieW6LcdseW6cGr87zDb1OpadM0lhjGvraBbrsaZGawjCo8LGumHg9bLdpk6z10T4SJx7dR6qUoBICsSNKkmOsloBIq9d)qU6boqu5kkC8AFyvhktSNKkmOsloBIq9d)qoJZLxZTqoeZEPMdpvwC2ePdMksK4zvhsUL)1)UxernhEQS4SjshmvKiXZQoKeKY2cyBdW4iayeBNnrO(HFiGzffFaJ43Z6cQrFawabS2l(aMWoatylicygGbdcxucHDkGzZEDkG1faJ0MgbeW0gWQiG5AOcyKleW0gW0eeWAV4V5dnocawxamIheUqrattmfWAHy9qaBtcEaMMGagXdcxOiGv(EcyC3RhWg(yAp3agXVN1fuJ(am1EcOcyWHhnsOeWgljGaMx7dR6qalGa2cIKaM2agCafrHBattqaZM96uaRlaMgteWIdWGOOpsiGPjMcyZfubSbdcbmRO4dye)Ewxqn6dWqIoepcbSkw6hbmITZMiu)WpecyBcNdWQiGTGijGD9pnNJBjiftOrFq5WJIEwnDlo741(WQoKRZMihs0zCtloBIq9d)qUiXITCkN9SDU6bopcrfKY2cyeVdnbW2gnosxCe4cWi(9SUGA0hXtiGj62r2BoaBt4CawfbShjxcKeWQCdygG92r2taZM96uUaS6sbmnbbSBnR4dyDbWeFOqadQ2RqaZl(CdyjbHeaZkk(aMj0WRPXraWi(9SUGA0hGzhjGbD9giGr2Boat7n2tcbmnbbm8ibSUaye)Ewxqn6J4jeWeD7i7nNeWiENGhGnn)IJaGrIIag9bbS4amnbbSTX7n3B5cWi(9SUGA0hXtiG940IlocaMOBhzV5aSacypsUeijGv5gW0KacyL3eA0hGPnGzcrVofWk9dyBJghPlocsqkMqJ(GYHhf9SA6wC2XR9HvDixNnro(fhPloc0hjxcn6JlsSylNYzC5E4Qh48ievqkMqJ(GYHhf9SA6wC2bE2amPvkunfcsXeA0huo8OONvt3IZolisdfNCD2e5yehmXEdsl9P0Uqh6n4dsXeA0huo8OONvt3IZoZ4)(PX0iGGumHg9bLdpk6z10T4SZqRrFGumHg9bLdpk6z10T4SZa3FxDgubPaszBbSTrikkwkscyOx85gW0yIaMMGaMj0(bSacyMxlCw1HsqkMqJ(GCe96u8HdOZbsXeA0hClo741(WQoKRZMihnMivBQON1fuJ(4Qh4arLlVMBHCuZHNklXJq1EfFjEw1HK7vjEeQ2R4lFCAXb3Yxr3oYEZjf9SUGA0N8XPfhCV8nv)1R9HvDO0V4iDXrG(i5sOrF7LAo8uPFXr6IJGepR6qsF8xtOrFYFDiTl0HEd(sKOOyPivJjUxQ5WtL)6qAxOd9g8L4zvhs6ZErer3oYEZjf9SUGA0N8rJK79QUkfPON1fuJ(KK9MdKIj0Op4wC2XR9HvDixNnroAmrQ2urpRlOg9XvpWzAeLlVMBHCeD7i7nNCIZ(5M2fQBjcsk5J2ekFCAXb5kkCqiepbkN4SFUPDH6wIGKs(OnHYP5p0VN6QuKtC2p30UqDlrqsjF0MqjzV58i62r2Bo5eN9ZnTlu3seKuYhTju(40Id6VETpSQdLAmrQ2urpRlOg9TphV2hw1HYK2rsf9SUGA0hvtEeM0osqkMqJ(GBXzhV2hw1HCD2e5OXePAtf9SUGA0hx9aNPruU8AUfYr0TJS3CYn97i9IXrFe2NDcu(40IdYvu4GqiEcuUPFhPxmo6JW(StGYP5p0VN6QuKB63r6fJJ(iSp7eOKS3CEeD7i7nNCt)osVyC0hH9zNaLpoT4G(Rx7dR6qPgtKQnv0Z6cQrF7ZXR9HvDOmPDKurpRlOg9r1KhHjTJeKIj0Op4wC2ryoh1eA0h1fqLRZMiNqXjKMeesOdF0FOCdsXeA0hClo7mJ)7NgtJaYvu4uxLIu0Z6cQrFsYEZbsXeA0hClo7qyzpzyhTluJ4WV1eUIchF9AFyvhk1yIuTPIEwxqn6B)uhF0inMivBkzG771(WQouQXePAtf9SUGA0NpGumHg9b3IZoI(e4PVPijT4SjcsXeA0hClo78OnehbAXztecsXeA0hClo7uAXcIKuJ4WpuKwrBcsXeA0hClo7mS(OWDCeOvNbvqkMqJ(GBXzNpggCinokCWeiiftOrFWT4SJMG01v71rsl9lqqkMqJ(GBXzNFDiTl0HEd(Cffo1vPif9SUGA0NKS3CE81R9HvDOuJjs1Mk6zDb1OVDllNJ(OiXEcivJjoAKx7dR6qPgtKQnv0Z6cQrF7QXePAtjd0hqkMqJ(GBXzhH5CutOrFuxavUoBICe9SUGA0hDiXGixrHJx7dR6qPgtKQnv0Z6cQrF7ZzCqkMqJ(GBXzNs8iT6mOY1cI0UuOeeKCsLRfePBschsfguJJaNu5kkC8fHq8eOCIZ(5M2fQBjcsk5J2ekNM)q)JgHqiEcuoXz)Ct7c1TebjL8rBcLZ463JrC4hkkRodQ4tNguXxINvDiPpEej2taHCMgrPIe7jGqpePUkfzsRuO(O5N8rtOEiIV1vPitqtJJaDniF0eQhFRRsrk6zDb1Op5AWJVMqJ(KL4XQ5CY4OfxqirhnYeA0NCG7VRodQY4OfxqirhnYeA0Nek6xKirIIILghbFgnsTNaQYe0CAICqO7ZHyg3Jj0Opju0VirIefflnoc(4JhI4lrQRsrMGMghb6Aq(OjupePUkfzsRuO(O5N8rtOEQRsrk6zDb1OpjzV584Rj0OpzjESAoNmoAXfes0rJmHg9jh4(7QZGQmoAXfesuF8bKIj0Op4wC2XR9HvDixNnroL4rA1zqLo0TlocC51ClKJAo8u5VoK2f6qVbFjEw1HKEeD7i7nN8xhs7cDO3GV8XPfhCFr3oYEZjlXJ0QZGQSSCo6JIe7jGunMOhF9AFyvhk1yIuTPIEwxqn6BxtOrFYFDiTl0HEd(YYY5OpksSNas1yI(4Xxr3oYEZj)1H0Uqh6n4lFCAXb3xJjs1Msg4OrMqJ(K)6qAxOd9g8LIe7jGWDh3NrJ8AFyvhk1yIuTPIEwxqn6BFtOrFYs8iT6mOkllNJ(OiXEcivJj6XR9HvDOuJjs1Mk6zDb1OV91yIuTPKbcsXeA0hClo7imNJAcn6J6cOY1ztKZ3d0HedICffo1vPi)1H0Uqh6n4lxdE81R9HvDOuJjs1Mk6zDb1OVDh3hqkMqJ(GBXzhV2hw1HCD2e5mK04feLo0TlocC51ClKJAo8u5VoK2f6qVbFjEw1HKEeD7i7nN8xhs7cDO3GV8XPfhCFr3oYEZjhsA8cIsloBIqzz5C0hfj2taPAmrp(61(WQouQXePAtf9SUGA03UMqJ(K)6qAxOd9g8LLLZrFuKypbKQXe9XJVIUDK9Mt(RdPDHo0BWx(40IdUVgtKQnLmWrJmHg9j)1H0Uqh6n4lfj2taH7oUpJg51(WQouQXePAtf9SUGA03(MqJ(KdjnEbrPfNnrOSSCo6JIe7jGunMOhV2hw1HsnMivBQON1fuJ(2xJjs1MsgiiLTfWiENGhGrSypPWGACeamITZMiGXRF4hYfGrSJhbS0DguHagmPxosaRIa2cIKaM2agb8W3ueWiwAfW41hn)GaMDKaM2agsufpsalDNbv8bm)Jbv8LGumHg9b3IZoL4rA1zqLRfePDPqjii5Kkxlis3KeoKkmOghboPYvu44lr8AFyvhklXJ0QZGkDOBxCegnQUkf5VoK2f6qVbF5AWhp(61(WQouQXePAtf9SUGA03UJ7JhFnHgErkE4mq4UC8AFyvhktSNKkmOsloBIq9d)qp(QXe936QuKIEwxqn6t6mOsrIoepURx7dR6qjj6mUPfNnrO(HFOp(4HiL4rOAVIV0eA4f9uxLImPvkuF08ts2Bop(seJ4WpuuwDguXNonOIVepR6qYrJQRsrwDguXNonOIV8XPfhC)XLB3hqkBlGr8A9XraWi2XJq1EfFUamID8iGLUZGkeWShbSfejbmymdN9oUbmTbmY1hhbaJ43Z6cQrFsaBVx8W3CoU5cW0eKBaZEeWwqKeW0gWiGh(MIagXsRagV(O5heW2KGhGj(qHa2MW5aSRvaRIa2gdQijGzhjGTj0ealDNbv8bm)Jbv85cW0eKBadM0lhjGvrado8Orcy9sbmTbSPfNAXbyAccyP7mOIpG5FmOIpGvxLIeKIj0Op4wC2PepsRodQCTGiTlfkbbjNu5Abr6MKWHuHb14iWjvUIcNs8iuTxXxAcn8IEej2taH7Yjvp(seV2hw1HYs8iT6mOsh62fhHrJQRsr(RdPDHo0BWxUg8XJVeXio8dfLvNbv8PtdQ4lXZQoKC0O6QuKvNbv8PtdQ4lFCAXb3FC529XJVeXeA0NSepwnNtIefflnocEiIj0Op5a3FxDguLXrlUGqI6PUkfzcAACeORb5Ay0itOrFYs8y1CojsuuS04i4PUkfzsRuO(O5NKS3CJgzcn6toW93vNbvzC0IliKOEQRsrMGMghb6Aqs2Bop1vPitALc1hn)KK9MZhqkMqJ(GBXzhH5CutOrFuxavUoBICGQDK2ts)wnn6JROWXR9HvDOuJjs1Mk6zDb1OVDhhKciftOrFqPj0WlsvZHNc54cVXrGw7zLROWXeA4fP4HZaH7MQN6QuKIEwxqn6ts2Bop(61(WQouQXePAtf9SUGA03UIUDK9Mt6cVXrGw7zvsUEtJ(gnYR9HvDOuJjs1Mk6zDb1OV95mUpGumHg9bLMqdVivnhEkClo7mrf7NROWXR9HvDOuJjs1Mk6zDb1OV95m(Or(wxLI8xhs7cDO3GVCnmAKOBhzV5K)6qAxOd9g8LpoT4G7QXePAtjd0Jj0Op5VoK2f6qVbFPiXEciC)uhnIiQ5WtL)6qAxOd9g8L4zvhs6JhFfD7i7nNCIk2VKC9Mg9TVx7dR6qPgtKQnv0Z6cQrFJgPXePAtjdCFV2hw1HsnMivBQON1fuJ(8bKIj0OpO0eA4fPQ5WtHBXzhY3i0hKwF00eUIch1C4PsZHefQVbjodslRNBjEw1HKE8TUkfPON1fuJ(KK9MZdrQRsrM0kfQpA(jF0e6Or1vPif9SUGA0NCn4XeA0NSepsRodQsrI9eq4(MqJ(KL4rA1zqvonIsfj2taHEisDvkYKwPq9rZp5JMq9bKciLTfWi(9SUGA0hGnKyqeWgECWEecywnCHgieW2eAcGzagj6mU5cW0e8amNTorccbS40gW0eeWi(9SUGA0hGbr)FHNabPycn6dkf9SUGA0hDiXGihxqirHu)HfjHjEkxrHtDvksrpRlOg9jj7nhiftOrFqPON1fuJ(Odjge3IZovJaTlu9dHFqUIcN6QuKIEwxqn6ts2BoqkMqJ(GsrpRlOg9rhsmiUfNDCH34iqR9SYvu4ycn8Iu8WzGWDt1tDvksrpRlOg9jj7nhiftOrFqPON1fuJ(Odjge3IZovx3K0Uq1eKIho5gKIj0OpOu0Z6cQrF0HedIBXzNjo7NBAxOULiiPKpAtiiftOrFqPON1fuJ(Odjge3IZoB63r6fJJ(iSp7eiiLTfWiET(4iaye)Ewxqn6JlaJyhpcyP7mOcbm7raBbrsatBaJaE4BkcyelTcy86JMFqaZosaBgxmdIdbmnbbmB2RtbSUayAmradoGNcyirrXsJJaG1Ac(agCaDoOeWi29dyq1os7jbmID8ixagXoEeWs3zqfcy2JawFoUbSfejbSnj4byelOPXraW2ggaSacyMqdViG1pGTjbpaZamEr)IeatyqfWciGfhGn8nHhHqaZosaJybnnoca22WaGzhjGrS0kGXRpA(by2Ja21kGzcn8IsaJ4DOjaw6odQ4dy(hdQ4dy2rcyeBNnraBV)XfGrSJhbS0DguHaMWoaZijdn6ZCoUbSkcyliscyBschcyelTcy86JMFaMDKagXcAACeaSTHbaZEeWUwbmtOHxeWSJeWmaBVj3FxDgubSacyXbyAccyw8aMDKaM5GnGTjjCiGjmOghbaJx0VibWqV4byrbWiwqtJJaGTnmaybeWm3Jgj3aMj0WlkbSXsqaZzQIpGzoxVbcy6MgWiwAfW41hn)aS9MC)D1zqfcyAdyveWegubS4am4siqim6dWSIIpGPjiGXl6xKibSTXKKHg9zoh3a2MqtaS0DguXhW8pguXhWSJeWi2oBIa2E)JlaJyhpcyP7mOcbmysVCKa21kGvraBbrsaBDoecbS0DguXhW8pguXhWciGz1EPaM2ags0H4raRFattWhbm7raB2pcyAIDagE9IqcGrSJhbS0DguHaM2agsufpsalDNbv8bm)Jbv8bmTbmnbbm8ibSUaye)Ewxqn6tcsXeA0huk6zDb1Op6qIbXT4StjEKwDgu5AbrAxkuccsoPY1cI0njHdPcdQXrGtQCffoIe7jGWD5KQhF91eA0NSepsRodQsrI9eqiT8MqJ(m3w(wxLIu0Z6cQrFYhNwCq)TUkfz1zqfF60Gk(sY1BA0Np7neD7i7nNSepsRodQsY1BA0N)6BDvksrpRlOg9jFCAXb9zVHV1vPiRodQ4tNguXxsUEtJ(83XLB3hF2LZ4JgreJ4WpuuwDguXNonOIVepR6qYrJiIAo8uzXztK2NepR6qYrJQRsrk6zDb1Op5Jtlo4(CQRsrwDguXNonOIVKC9Mg9nAuDvkYQZGk(0Pbv8LpoT4G7pUC7JgH()kggqszc3d4RjpAK0nFa1nVna9i62r2Bozc3d4RjpAK0nFa1nVnaPeZ4JNQ)CpYhNwCW93UpEQRsrk6zDb1Op5AWJVeXeA0Nek6xKirIIILghbpeXeA0NCG7VRodQY4Ofxqir9uxLImbnnoc01GCnmAKj0Opju0VirIefflnocEQRsrM0kfQpA(jj7nNhFRRsrMGMghb6Aqs2BUrJmId)qrz1zqfF60Gk(s8SQdj9z0iJ4WpuuwDguXNonOIVepR6qspQ5WtLfNnrAFs8SQdj9ycn6toW93vNbvzC0IliKOEQRsrMGMghb6Aqs2Bop1vPitALc1hn)KK9MZhqkMqJ(GsrpRlOg9rhsmiUfND(1H0Uqh6n4Zvu4uxLIu0Z6cQrFsYEZbszBbSTXagXoEeWs3zqfWGj9YrcyveWwqKeW0gWSHbh3aw6odQ4dy(hdQ4dyBschcycdQXraW27zDiG1faBVzVbFaBtcEa2cghbalDNbv8bm)Jbv85cWi2oBIa2E)JlaZosaZ)Gk2VeWiEuaS(CCdy(hC2p3awxaS92LiibmIxpAtiG5FIRFalGag6)Ryyaj5cW0KacyU4qalGawq46hjbSkkSfebSqbSnHZbyWEIAmriG9iC5ualoaJqhhbaloTbmIFpRlOg9byBcnbWk4gaJyhpcyP7mOcyIe7jGqjiftOrFqPON1fuJ(Odjge3IZoL4rA1zqLRfePBschsfguJJaNu5kkCmId)qrz1zqfF60Gk(s8SQdj94lcH4jq5eN9ZnTlu3seKuYhTjuon)H(hnIiieINaLtC2p30UqDlrqsjF0Mq5mU(9XJAo8u5evSFjEw1HKEuZHNkloBI0(K4zvhs6PUkfz1zqfF60Gk(sYEZ5Xx1C4PYFDiTl0HEd(s8SQdj9ycn6t(RdPDHo0BWxIefflnocEmHg9j)1H0Uqh6n4lrIIILI0hNwCW9hxUnhnYxV2hw1HsnMivBQON1fuJ(2NZ4JgvxLIu0Z6cQrFY1GpEiIAo8u5VoK2f6qVbFjEw1HKEiIj0Op5a3FxDguLXrlUGqI6HiMqJ(KL4XQ5CY4Ofxqir9bKIj0OpOu0Z6cQrF0HedIBXzhH5CutOrFuxavUoBICmHgErQAo8uiiftOrFqPON1fuJ(Odjge3IZoIEwxqn6JRfePDPqjii5Kkxlis3KeoKkmOghboPYvu44RVMqJ(KtuX(LXrlUGqI6XeA0NCIk2VmoAXfesu6Jtlo4(CgxUDFgnIiQ5WtLtuX(L4zvhs6XxecXtGYjo7NBAxOULiiPKpAtOCA(d9pAuDvkYKwPq9rZp5JMqhnYeA0Nek6xKirIIILghbpMqJ(Kqr)IejsuuSuK(40IdU)4YTpAKj0Op5a3FxDguLirrXsJJGhtOrFYbU)U6mOkrIIILI0hNwCW9hxUDF8XJV1vPi)1H0Uqh6n4lxdJgre1C4PYFDiTl0HEd(s8SQdj9bKIj0OpOu0Z6cQrF0HedIBXzNHwJ(aPycn6dkf9SUGA0hDiXG4wC2P66MKwwp3GumHg9bLIEwxqn6JoKyqClo7uXhIVFXraKIj0OpOu0Z6cQrF0HedIBXzNs8y11njiftOrFqPON1fuJ(Odjge3IZo2jqO(MJkmNdKIj0OpOu0Z6cQrF0HedIBXzNIZMiu)WpKROWXxFvZHNkloBI0btfjs8SQdj9ycn8Iu8WzGWD3JpJgzcn8Iu8WzGWD3M(4PUkfzsRuO(O5N8rtOEiIrC4hkkRodQ4tNguXxINvDijiftOrFqPON1fuJ(Odjge3IZodC)D1zqLROWPUkf5a3FlCgCkF0eQN6QuKIEwxqn6t(40IdURWGkvJjcsXeA0huk6zDb1Op6qIbXT4SZa3FxDgu5kkCQRsrM0kfQpA(jF0ekiftOrFqPON1fuJ(Odjge3IZodC)D1zqLROWz4rVuccszQsOOFrIN6QuKjOPXrGUgKRbqkMqJ(GsrpRlOg9rhsmiUfNDgsA8cIsloBIqqkMqJ(GsrpRlOg9rhsmiUfNDGI(fjCffo1vPif9SUGA0N8XPfhCxHbvQgt0tDvksrpRlOg9jxdJgvxLIu0Z6cQrFsYEZ5r0TJS3CsrpRlOg9jFCAXb3xyqLQXebPycn6dkf9SUGA0hDiXG4wC2XfEJJaT2ZkxrHtDvksrpRlOg9jFCAXb3NGGuonI6XeA4fP4HZaH7MkiftOrFqPON1fuJ(Odjge3IZoKVrOpiT(OPjCffo1vPif9SUGA0N8XPfhCFccs50iQN6QuKIEwxqn6tUgaPycn6dkf9SUGA0hDiXG4wC2bk6xKWvu4O2tavzcAonroi095qmJ7rnhEQeI2hhbQ2lrIepR6qsqkGumHg9bLHItiv0Z6cQrFCwqKgko56SjYjiCHg9rNgbesllicsXeA0hugkoHurpRlOg9TfNDwqKgko56SjYjH7b81Khns6MpG6M3gGCffo1vPif9SUGA0NCn4XeA0NSepsRodQsrI9eqiNX9ycn6twIhPvNbv5JIe7jGunM4UeeKYPruqkMqJ(GYqXjKk6zDb1OVT4SZcI0qXjxNnrot7Icc1M2f60ipecbPycn6dkdfNqQON1fuJ(2IZoc7eOJwxLcxlis7sHsqqYjvUoBICM2ffeQnTl0PrEiesfj2GIpTpKROWPUkfPON1fuJ(KRHrJmHg9jNOI9lJJwCbHe1Jj0Op5evSFzC0IliKO0hNwCW95mUC7GumHg9bLHItiv0Z6cQrFBXzNfePHItUwqK2LcLGGKtQCD2e5ye36rnPHuyCeqs6GBnncixrHtDvksrpRlOg9jxdJgzcn6torf7xghT4ccjQhtOrFYjQy)Y4OfxqirPpoT4G7ZzC52bPycn6dkdfNqQON1fuJ(2IZolisdfNCTGiTlfkbbjNu5clfuO0ZMihcoJmmTFiTAKeqUIcN6QuKIEwxqn6tUggnYeA0NCIk2VmoAXfesupMqJ(KtuX(LXrlUGqIsFCAXb3NZ4YTdsXeA0hugkoHurpRlOg9TfNDwqKgko5AbrAxkuccsoPYfwkOqPNnroeCgzyA)q6ejnNl6JROWPUkfPON1fuJ(KRHrJmHg9jNOI9lJJwCbHe1Jj0Op5evSFzC0IliKO0hNwCW95mUC7GumHg9bLHItiv0Z6cQrFBXzNfePHItUwqK2LcLGGKtQCD2e5unhwIhP13orcxrHtDvksrpRlOg9jxdJgzcn6torf7xghT4ccjQhtOrFYjQy)Y4OfxqirPpoT4G7ZzC52bPycn6dkdfNqQON1fuJ(2IZolisdfNCTGiTlfkbbjNu56SjYbM0c)QHIpKwSJaxrHtDvksrpRlOg9jxdJgzcn6torf7xghT4ccjQhtOrFYjQy)Y4OfxqirPpoT4G7ZzC52bPycn6dkdfNqQON1fuJ(2IZolisdfNCTGiTlfkbbjNu56SjYrjo7qiTAVFWH4qixrHtDvksrpRlOg9jxdJgzcn6torf7xghT4ccjQhtOrFYjQy)Y4OfxqirPpoT4G7ZzC52bPycn6dkdfNqQON1fuJ(2IZolisdfNCTGiTlfkbbjNu56SjYXorGNs97AL2f6Mas2tUIcN6QuKIEwxqn6tUggnYeA0NCIk2VmoAXfesupMqJ(KtuX(LXrlUGqIsFCAXb3NZ4YTdsXeA0hugkoHurpRlOg9TfNDwqKgko5AbrAxkuccsoPY1ztKZHR3Cui3NnarkEj2jWNROWPUkfPON1fuJ(KRHrJmHg9jNOI9lJJwCbHe1Jj0Op5evSFzC0IliKO0hNwCW95mUC7GumHg9bLHItiv0Z6cQrFBXzNfePHItUwqK2LcLGGKtQCD2e5mnxP)jsstW3CKqQdjS5TbixrHtDvksrpRlOg9jxdJgzcn6torf7xghT4ccjQhtOrFYjQy)Y4OfxqirPpoT4G7ZzC52bPasXeA0hugkoH0KGqcD4J(dLBocZ5OMqJ(OUaQCD2e5ekoHurpRlOg9Xvu441(WQouQXePAtf9SUGA03(CghKIj0OpOmuCcPjbHe6Wh9hk3BXzNfePHItiiftOrFqzO4estccj0Hp6puU3IZolisdfNCD2e5mTlkiuBAxOtJ8qiKROWHiO)VIHbKuAehmXEdsl9P0Uqh6n47XR9HvDOuJjs1Mk6zDb1OV9jwbPycn6dkdfNqAsqiHo8r)HY9wC2zbrAO4KRZMihJ4Gj2BqAPpL2f6qVbFUIchV2hw1HsnMivBQON1fuJ(2NZ23k1TVxETpSQdLL(ukzVQoK2hDbrqkMqJ(GYqXjKMeesOdF0FOCVfNDwqKgko56SjY5Bv8lOIKuVDt2nLSDoUIchV2hw1HsnMivBQON1fuJ(21R9HvDOSp6cIuXs7sbKIj0OpOmuCcPjbHe6Wh9hk3BXzNfePHItUoBICm)FfdTINspBPHBb5kkC8AFyvhk1yIuTPIEwxqn6BxV2hw1HY(OlisflTlfqkMqJ(GYqXjKMeesOdF0FOCVfNDwqKgko56SjYbMeEXN6fVEsF0fcUIchV2hw1HsnMivBQON1fuJ(21R9HvDOSp6cIuXs7sbKIj0OpOmuCcPjbHe6Wh9hk3BXzNfePHItUoBICk9xdss8ODfgKHDuHZ2Wvu441(WQouQXePAtf9SUGA03UETpSQdL9rxqKkwAxkGumHg9bLHItinjiKqh(O)q5Elo7SGinuCYfwkOqPNnroj2p7leusCAk(H5cIdFqkMqJ(GYqXjKMeesOdF0FOCVfNDwqKgko56SjYzAUs)tKKMGV5iHuhsyZBdqUIchV2hw1HsnMivBQON1fuJ(2LZ23UN6QuKIEwxqn6ts2BopETpSQdLAmrQ2urpRlOg9TRx7dR6qzF0fePIL2LciftOrFqzO4estccj0Hp6puU3IZolisdfNCD2e5yNiWtP(DTs7cDtaj7jxrHJx7dR6qPgtKQnv0Z6cQrF7Yz7B3tDvksrpRlOg9jj7nNhV2hw1HsnMivBQON1fuJ(21R9HvDOSp6cIuXs7sbKIj0OpOmuCcPjbHe6Wh9hk3BXzNfePHItUoBICoC9MJc5(SbisXlXob(CffoETpSQdLAmrQ2urpRlOg9Tlh)529uxLIu0Z6cQrFsYEZ5XR9HvDOuJjs1Mk6zDb1OVD9AFyvhk7JUGivS0UuaPasXeA0hugkoHuxVHo8r)HYnNfePHItUoBIC0GeHA)tQOjrIYvu441(WQouQXePAtf9SUGA03UETpSQdL9rxqKkwAxkGumHg9bLHIti11BOdF0FOCVfNDwqKgko5clfuO0ZMihb3cxRFFHGwDgu5kkC8AFyvhk1yIuTPIEwxqn6BxV2hw1HY(OlisflTlfqkGumHg9bLFpqhsmiY5xhs7cDO3GpiftOrFq53d0HedIBXzNIZMiu)WpKROWXxtOHxKIhodeUlhV2hw1HYKwPq9rZpAXzteQF4h6XxnMO)wxLIu0Z6cQrFsNbvks0H4XD9AFyvhkjrNXnT4Sjc1p8d9Xhp1vPitALc1hn)KpAcfKIj0OpO87b6qIbXT4SZa3FxDgu5kkCQRsrM0kfQpA(jF0ekiftOrFq53d0HedIBXzNs8iT6mOY1cI0UuOeeKCsLRfePBschsfguJJaNu5kkCiIVMqdVifpCgiCxoETpSQdLj2tsfguPfNnrO(HFOhF1yI(BDvksrpRlOg9jDguPirhIh31R9HvDOKeDg30IZMiu)Wp0hF8qKs8iuTxXxAcn8IE8Li1vPitqtJJaDniF0eQhIuxLImPvkuF08t(Ojupez4rV0UuOeeKYs8iT6mO6XxtOrFYs8iT6mOkfj2taH7YzpJg5Rj0Op5qsJxquAXztekfj2taH7YjvpQ5WtLdjnEbrPfNnrOepR6qsFgnYx1C4PsZHefQVbjodslRNBjEw1HKEeD7i7nNK8nc9bP1hnnr(OrYTpJg5RAo8ujeTpocuTxIejEw1HKEu7jGQmbnNMihe6(CiMX9XhFaPycn6dk)EGoKyqClo7imNJAcn6J6cOY1ztKJj0WlsvZHNcbPycn6dk)EGoKyqClo7mW93vNbvUIcN6QuKdC)TWzWP8rtOEeguPAmX9RRsroW93cNbNYhNwCqp1vPi)1H0Uqh6n4lFCAXb3vyqLQXebPycn6dk)EGoKyqClo7uIhPvNbvUwqK2LcLGGKtQCTGiDts4qQWGACe4KkxrHdr81eA4fP4HZaH7YXR9HvDOmXEsQWGkT4Sjc1p8d94Rgt0FRRsrk6zDb1OpPZGkfj6q84UETpSQdLKOZ4MwC2eH6h(H(4JhIuIhHQ9k(stOHx0JV1vPitqtJJaDniF0eQhFv7jGQmbnNMihe6UCiMXhnIiQ5WtLq0(4iq1EjsK4zvhs6JpGumHg9bLFpqhsmiUfNDkXJ0QZGkxlis7sHsqqYjvUwqKUjjCivyqnocCsLROWHi(Acn8Iu8WzGWD541(WQouMypjvyqLwC2eH6h(HE8vJj6V1vPif9SUGA0N0zqLIeDiECxV2hw1Hss0zCtloBIq9d)qF8XdrkXJq1EfFPj0Wl6rnhEQeI2hhbQ2lrIepR6qspQ9eqvMGMttKdcDFoeZ4E8TUkfzcAACeORb5JMq9qetOrFsOOFrIejkkwACegnIi1vPitqtJJaDniF0eQhIuxLImPvkuF08t(OjuFaPycn6dk)EGoKyqClo7mW93vNbvUIcNHh9sjiiLPkHI(fjEQRsrMGMghb6AqUg8OMdpvcr7JJav7LirINvDiPh1EcOktqZPjYbHUphIzCpeXxtOHxKIhodeUlhV2hw1HYKwPq9rZpAXzteQF4h6XxnMO)wxLIu0Z6cQrFsNbvks0H4XD9AFyvhkjrNXnT4Sjc1p8d9XhqkMqJ(GYVhOdjge3IZodjnEbrPfNnrixrHdrgE0lLGGuMQCiPXlikT4Sjc9uxLImbnnoc01G8rtOGumHg9bLFpqhsmiUfNDGI(fjCffoQ9eqvMGMttKdcDFoeZ4EuZHNkHO9XrGQ9sKiXZQoKeKIj0OpO87b6qIbXT4Sd5Be6dsRpAAcxrHJj0WlsXdNbc3DpGumHg9bLFpqhsmiUfNDkoBIq9d)qUIchFnHgErkE4mq4UC8AFyvhktSNKkmOsloBIq9d)qp(QXe936QuKIEwxqn6t6mOsrIoepURx7dR6qjj6mUPfNnrO(HFOp(asXeA0hu(9aDiXG4wC2PepwnNdKciftOrFqjuTJ0Es63QPrFCkoBIq9d)qUIchFnHgErkE4mq4UC8AFyvhktALc1hn)OfNnrO(HFOhF1yI(BDvksrpRlOg9jDguPirhIh31R9HvDOKeDg30IZMiu)Wp0hF8uxLImPvkuF08t(OjuqkMqJ(GsOAhP9K0VvtJ(2IZodC)D1zqLROWPUkfzsRuO(O5N8rtOEQRsrM0kfQpA(jFCAXb33eA0NSepwnNtIefflfPAmrqkMqJ(GsOAhP9K0VvtJ(2IZodC)D1zqLROWPUkfzsRuO(O5N8rtOE8D4rVuccszQYs8y1CUrJkXJq1EfFPj0WloAKj0Op5a3FxDguLXrlUGqI6diftOrFqjuTJ0Es63QPrFBXzNHKgVGO0IZMiKROWrKypbeUlhIXJj0WlsXdNbc3DpEiIx7dR6q5qsJxqu6q3U4iasXeA0hucv7iTNK(TAA03wC2zG7VRodQCffo1vPitALc1hn)KpAc1JApbuLjO50e5Gq3NdXmUh1C4PsiAFCeOAVejs8SQdjbPycn6dkHQDK2ts)wnn6Blo7mW93vNbvUIcN6QuKdC)TWzWP8rtOEeguPAmX9RRsroW93cNbNYhNwCqqkMqJ(GsOAhP9K0VvtJ(2IZoL4rA1zqLRfePDPqjii5Kkxlis3KeoKkmOghboPYvu44BDvkYFDiTl0HEd(sYEZ5HiL4rOAVIV0eA4f9Xdr8AFyvhklXJ0QZGkDOBxCe84RV(Acn6twIhRMZjrIIILghHrJmHg9jh4(7QZGQejkkwACe8XtDvkYe004iqxdYhnH6ZOr(QMdpvcr7JJav7LirINvDiPh1EcOktqZPjYbHUphIzCp(wxLImbnnoc01G8rtOEiIj0Opju0VirIefflnocJgrK6QuKjTsH6JMFYhnH6Hi1vPitqtJJaDniF0eQhtOrFsOOFrIejkkwACe8qetOrFYbU)U6mOkJJwCbHe1drmHg9jlXJvZ5KXrlUGqI6Jp(asXeA0hucv7iTNK(TAA03wC2zG7VRodQCffodp6Lsqqktvcf9ls8uxLImbnnoc01GCn4rnhEQeI2hhbQ2lrIepR6qspQ9eqvMGMttKdcDFoeZ4EiIVMqdVifpCgiCxoETpSQdLjTsH6JMF0IZMiu)Wp0JVAmr)TUkfPON1fuJ(KodQuKOdXJ761(WQousIoJBAXzteQF4h6JpGumHg9bLq1os7jPFRMg9TfNDgsA8cIsloBIqUIchFRRsrMGMghb6Aq(Oj0rJ8Li1vPitALc1hn)KpAc1JVMqJ(KL4rA1zqvksSNac3D8rJuZHNkHO9XrGQ9sKiXZQoK0JApbuLjO50e5Gq3NdXmUp(4JhI41(WQouoK04feLo0TlocGumHg9bLq1os7jPFRMg9TfNDeMZrnHg9rDbu56SjYXeA4fPQ5WtHGumHg9bLq1os7jPFRMg9TfNDiFJqFqA9rtt4kkCmHgErkE4mq4UPcsXeA0hucv7iTNK(TAA03wC2ryoh1eA0h1fqLRZMiNqXjK66n0Hp6puUbPycn6dkHQDK2ts)wnn6Blo7af9ls4kkCu7jGQmbnNMihe6(CiMX9OMdpvcr7JJav7LirINvDijiLTfWiEhAcGHxViKayQ9eqfYfGfkGfqaZamcwCaM2aMWGkGrSD2eH6h(HaMbbSs4C4dyXbv0ibSUaye74XQ5CsqkMqJ(GsOAhP9K0VvtJ(2IZofNnrO(HFixrHJj0WlsXdNbc3LJx7dR6qzI9KuHbvAXzteQF4h6XxnMO)wxLIu0Z6cQrFsNbvks0H4XD9AFyvhkjrNXnT4Sjc1p8d9bKIj0OpOeQ2rApj9B10OVT4StjESAohiftOrFqjuTJ0Es63QPrFBXzhOOFrswZAod]] )


end
