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

        if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK (Cast/Impact) ***\n    Heating Up: %s, %.2f\n    Hot Streak: %s, %.2f\n    Crit: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains, willCrit and "Yes" or "No", stat.crit ) end

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
            cooldown = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste end,
            recharge = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste end,
            gcd = "off",
            castableWhileCasting = true,

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135807,

            nobuff = "fire_blasting", -- horrible.

            --[[ readyTime = function ()
                if settings.no_scorch_blast and action.scorch.executing and ( ( talent.searing_touch.enabled and target.health_pct < 30 ) or ( buff.combustion.up and buff.combustion.remains >= buff.casting.remains ) ) then
                    return buff.casting.remains
                end
            end, ]]

            usable = function ()
                if time == 0 then return false, "no fire_blast out of combat" end
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

            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",

            usable = function ()
                if settings.save_2_runes then
                    local combustime = max( variable.time_to_combustion, cooldown.combustion.remains )
                    if combustime > 0 and ( charges <= 1 or cooldown.combustion.true_remains < action.rune_of_power.recharge ) then return false, "saving rune_of_power charges for combustion" end
                end
                return true
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
                hot_streak( talent.searing_touch.enabled and target.health_pct < 30 )
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

        potion = "superior_battle_potion_of_intellect",

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

    --[[ spec:RegisterSetting( "no_scorch_blast", true, {
        name = "Prevent |T135807:0|t Fire Blast During Critical |T135827:0|t Scorch Casts",
        desc = "If checked, the addon will not recommend |T135827:0|t Fire Blast during any of your |T135827:0|t Scorch casts that are expected to critically strike.\n\n" ..
            "This will override the priority's logic that allows for some interwoven Blaster Master refreshes that tend to confuse users.",
        type = "toggle",
        width = 3
    } ) ]]

    spec:RegisterSetting( "save_2_runes", true, {
        name = "Reserve |T609815:0|t Rune of Power Charges for Combustion",
        desc = "While |T609815:0|t Rune of Power is not considered a Cooldown by default, saving 2 charges to line up with |T135824:0|t Combustion is generally a good idea.\n\n" ..
            "The addon will reserve this many charges to line up with |T135824:0|t Combustion, regardless of whether Cooldowns are toggled on/off.",
        type = "toggle",
        width = 3
    } )



    spec:RegisterPack( "Fire IV", 20200204.1, [[diKjyaqiLQ4rkvLnrPmkvv5uQQQxHqnlvvUfcIAxe9leLHrPQJrHwgI4zusnnkv4AkvvBJsL8neuzCiQ05OuPwhLkQMNsv6EkL9HahKsfLfIi9qeezJuQiNerfRuvXnrqYovvAOiOyPii4PQYuriBfbvTxG)kYGj1HLSybpgQjdPlJAZK8zky0q0PvSAee61iQA2I62kz3Q8BQgofTCqpNW0L66cTDkjFhcJhbPopLy9iO08vQSFKgyeqe4Hwnd(sI9KyV9wBTrPr7YOrsiCGxBXKbpZct(YadExTyWZonqMQjhcp4zwwYEHcic8eEeIzWdz3Mc7CYiBWwiKTINtiX(ImWleNCtohiaEOvZGVKypj2BV1wBuA0UmA0iHd8QyJ0HGh5GTqit455euTDwSr6qb4HCqr5deapuwGbV9r12PbYunHQmW0p7JQjTemkv7kfvtoylunHNNtq1MWXHtBrs)SpQMqvqmsQ2AJ)OAsSNe7bV8iAbGiWdLvvm3aIaFncic8kCp(bEypEndfMCodE8vHmJcif0GVKaic84Rczgfqk4HHtZWPapS7zuhXjX(kef94NeYfQfWRW94h4bJhNCvY0rWqqd(AnGiWJVkKzuaPGhgondNc8WUNrDeNe7Rqu0JFsixOwaVc3JFG3Ixo0sYvPCepOjuixlbObFTdarGhFviZOasbpmCAgof4fIkLe7Rqu0JFsuhXbEfUh)aVOGttZlbObF3pGiWJVkKzuaPGhgondNc8(JQ3dv3vMVwcJhNCvY0rWqjFviZOu9UDuDiQusy84KRsMocgkJMu9)uTnQ(pQg7Eg1rCsSVcrrp(jHCHAHQ3TJQXUNrDeNe7Rqu0JFsiVQ5eunbBuTDSFQ(FWRW94h4T4MDiObFTlarGhFviZOasbVOGtiqozoHlrpNbWxJGhgondNc8(JQ3dvZcbFywU4LdTKCvkhXdAcfY1sixfHOdP6D7O6quPKlE5qljxLYr8GMqHCTeYOjvVBhvJDpJ6io5Ixo0sYvPCepOjuixlHeYRAobvtavB04(P6)PABu9Fu9EO6UY81Yf3SdL8vHmJs172r1y3ZOoItU4MDOeYRAobv)p4ffCYvQKbmk4RrWRW94h4H9vik6Xpqd(s4aebE8vHmJcif8kCp(bEiTyYWgjKl0ec4iAeWYuaEy40mCkWlevkj2xHOOh)KrtQ2gvx4E8tQgiNc5s0smYcAGfu9gvBpvBJQlCp(jvdKtHCjAjKXilObo1ZIPAcOAdyu5Qi0G3vlg8qAXKHnsixOjeWr0iGLPa0GVKlGiWJVkKzuaPGhgondNc8uXCobzmYcAGt9SyQEVunjGxH7XpWdgpo5QKPJGHGg81UbebE8vHmJcif8WWPz4uGhgzbnWIKcw4E8RYunbBunjs7g8kCp(bEMiD(gcDsLRflan4Rr7bebE8vHmJcif8WWPz4uG3EO6UY81svUwCYSAmsjFviZOuTnQ(pQoevkj2xHOOh)KrtQ2gvx4ESIt8XRHfunbBun5s172r1HOsjX(kef94Ne1rCuTnQUW9yfN4JxdlOAc2O69t1)t12O6quPKi9ojAixKxgnbVc3JFGNkxlw0WH8mObFnAeqe4XxfYmkGuWddNMHtbEDL5RLQCT4Kz1yKs(QqMrPABu9FuDiQusSVcrrp(jJMuTnQUW9yfN4JxdlOAc2OARP6D7O6quPKyFfIIE8tI6ioQ2gvx4ESIt8XRHfunbBunju9)uTnQoevkjsVtIgYf5LrtWRW94h4PY1IfnCipdAWxJKaic84Rczgfqk4HHtZWPaVquPKMwGooxILmAs12O6)O6quPKyFfIIE8tc5vnNGQjGQdrLsAAb64CjwsiVQ5eu9UDuDiQusSVcrrp(jrDehvBJQXUNrDeNe7Rqu0JFsiVQ5eunbuDiQustlqhNlXsc5vnNGQjMQTMQ)NQTr1)r1HOsjHXJtUkz6iyOeYRAobvtavhIkL00c0X5sSKqEvZjO6D7O69q1DL5RLW4XjxLmDemuYxfYmkvVBhv3vMVwcJhNCvY0rWqjFviZOuTnQoevkjmECYvjthbdLOoIJQTr1y3ZOoItcJhNCvY0rWqjKx1CcQMaQoevkPPfOJZLyjH8QMtq1et1wt1)dEfUh)aptlqpKlrdAWxJwdic84Rczgfqk4HHtZWPaVquPKi9ojAixKxgnbVc3JFGNPfOhYLObn4Rr7aqe4XxfYmkGuWddNMHtbEfUhR4eF8AybvtWgvBnvBJQ7zXP2tOdt1eSr1Kl4v4E8d8YJvZzif8va0GVg3pGiWJVkKzuaPGhgondNc8crLsI9vik6Xpz0KQTr1HOsjX(kef94NeYRAobvVxQ2i4v4E8d8qHLb)ePaKRgjObFnAxaIap(QqMrbKcEy40mCkWRW9yfN4JxdlOAc2OARbVc3JFGhkSm4NifGC1ibn4RrchGiWJVkKzuaPGxuWjeiNmNWLONZa4RrWddNMHtbEHOsjrYvpNHu0ugnbVOGtUsLmGrbFncEfUh)ap1a5uixIg0GVgjxarGxH7XpWdfwg8tKcqUAKGhFviZOasbn4Rr7gqe4XxfYmkGuWddNMHtbEDL5RLcUGZzi1EeJuYxfYmkvBJQ7cAGBjsUYnsPjUP69s1wBpvBJQ7cAGBzplo1EcDyQMaQgxIo1ZIbVc3JFGNa7qmsqd(sI9aIap(QqMrbKcErbNqGCYCcxIEodGVgbpmCAgof41ZItTNqhMQ3lvx4E8tkWoeJuIlrdErbNCLkzaJc(Ae8kCp(bEQbYPqUenObFjXiGiWJVkKzuaPGhgondNc8crLsI9vik6XpjQJ4aVc3JFGNAGCOYzqd(scjaIaVLB1CgapJGxH7XpWtGDigj4XxfYmkGuqdAWZeYyFfQgqe4RrarGxH7XpWRG4640CnNZmUbp(QqMrbKcAWxsaebE8vHmJcif8WWPz4uGxiQuYqUiSZzifkiCyOe1rCGxH7XpWlKlc7CgsHcchgcAWxRbebEfUh)aptVh)ap(QqMrbKcAWx7aqe4v4E8d8mTa9qUen4XxfYmkGuqdAqdEwXqX4h4lj2tI92tI92H0i4HOG3CgeGh5SmDyZOunjuDH7XpQopIwiPFaptORMmdE7JQTtdKPAcvzGPF2hvtAjyuQ2vkQMCWwOAcppNGQnHJdN2IK(zFunHQGyKuT1g)r1Kypj2t)q)u4E8tinHm2xHQ3kiUoonxZ5mJB6Nc3JFcPjKX(ku9wixe25mKcfeom83O2crLsgYfHDodPqbHddLOoIJ(PW94NqAczSVcvVz694h9tH7XpH0eYyFfQEZ0c0d5s00p0pfUh)eeVrg2JxZqHjNZ0pfUh)eeVrgmECYvjthbd)nQnS7zuhXjX(kef94NeYfQf6Nc3JFcI3iBXlhAj5QuoIh0ekKRL43O2WUNrDeNe7Rqu0JFsixOwOFkCp(jiEJSOGttZlXVrTfIkLe7Rqu0JFsuhXr)u4E8tq8gzlUzh(BuB)TNUY81sy84KRsMocgk5RczgD3UquPKW4XjxLmDemugn)32Fy3ZOoItI9vik6XpjKlul72HDpJ6ioj2xHOOh)KqEvZjiyZo2))0pfUh)eeVrg2xHOOh)(ffCcbYjZjCj65mSz8xuWjxPsgWOBg)nQT)2dle8Hz5Ixo0sYvPCepOjuixlHCveIoC3UquPKlE5qljxLYr8GMqHCTeYO5UDy3ZOoItU4LdTKCvkhXdAcfY1siH8QMtqGrJ7)FB)TNUY81Yf3SdL8vHmJUBh29mQJ4KlUzhkH8QMt8p9tH7XpbXBKffCAAE97QfVH0IjdBKqUqtiGJOraltXVrTfIkLe7Rqu0JFYOPTc3JFs1a5uixIwIrwqdSyZEBfUh)KQbYPqUeTeYyKf0aN6zXeyaJkxfHM(zFuDH7XpbXBKH0IjdBKqUqtiGJOraltXVrTfIkLe7Rqu0JFYOPnS7zuhXjvdKtHCjAjgzbnWIn7T9NjKTsAuQgiNc5s0eBczRKKivdKtHCjAInHSvsRLQbYPqUenbBK8p9tH7XpbXBKbJhNCvY0rWWFJAtfZ5eKXilObo1ZI3lj0p7JQlCp(jiEJmy84KRsMocg(BuByKf0alskyH7XVktWMrPDVFB4s07TNfNApHom9tH7XpbXBKzI05Bi0jvUwS43O2WilObwKuWc3JFvMGnsK2n9tH7XpbXBKPY1IfnCip)BuB7PRmFTuLRfNmRgJuYxfYmQT)crLsI9vik6Xpz00wH7XkoXhVgwqWg5UBxiQusSVcrrp(jrDeNTc3JvCIpEnSGGT9)VTquPKi9ojAixKxgnPFkCp(jiEJmvUwSOHd55FJARRmFTuLRfNmRgJuYxfYmQT)crLsI9vik6Xpz00wH7XkoXhVgwqWM172fIkLe7Rqu0JFsuhXzRW9yfN4JxdliyJK)TfIkLeP3jrd5I8YOj9Z(OAYrr1es(kef94hv7qQMqiEmv7kQMW4iyivpcQghHq(6SfQ(8MQlCpwX)O6qSPAetot1bMQlRQjxHmt1bw5qMQBKmvtySaDCUelQoevkQgHhZOuDplMQ9y)JQRdLQT4rQ2VSfQgzzft1(XuTOlm5PAxr1eglqhNlX6hvBXJuTaPhZOunspJs1tt1XRNmv3izQMqYxHOOh)OAhs1ecXJPAxr1eghbdP6rq1rtj9tH7XpbXBKzAb6HCj6FJAlevkPPfOJZLyjJM2(levkj2xHOOh)KqEvZjiievkPPfOJZLyjH8QMtSBxiQusSVcrrp(jrDeNnS7zuhXjX(kef94NeYRAobbHOsjnTaDCUeljKx1CcIT(FB)fIkLegpo5QKPJGHsiVQ5eeeIkL00c0X5sSKqEvZj2TBpDL5RLW4XjxLmDemuYxfYm6UDDL5RLW4XjxLmDemuYxfYmQTquPKW4XjxLmDemuI6ioBy3ZOoItcJhNCvY0rWqjKx1CcccrLsAAb64CjwsiVQ5eeB9)0pfUh)eeVrMPfOhYLO)nQTquPKi9ojAixKxgnPFkCp(jiEJS8y1CgsbFf(nQTc3JvCIpEnSGGnRT1ZItTNqhMGnYL(PW94NG4nYqHLb)ePaKRg5VrTfIkLe7Rqu0JFYOPTquPKyFfIIE8tc5vnNyVgPFkCp(jiEJmuyzWprka5Qr(BuBfUhR4eF8AybbBwt)u4E8tq8gzQbYPqUe9VOGtiqozoHlrpNHnJ)Ico5kvYagDZ4VrTfIkLejx9Cgsrtz0K(PW94NG4nYqHLb)ePaKRgj9tH7XpbXBKjWoeJ83O26kZxlfCbNZqQ9igPKVkKzuBDbnWTejx5gP0e371A7T1f0a3YEwCQ9e6WeGlrN6zX0pfUh)eeVrMAGCkKlr)lk4ecKtMt4s0ZzyZ4VOGtUsLmGr3m(BuB9S4u7j0H3BH7XpPa7qmsjUen9tH7XpbXBKPgihQC(3O2crLsI9vik6XpjQJ4OFkCp(jiEJmb2HyK)wUvZzyZi4jmzm4RDznObnaa]] )
    
    spec:RegisterPack( "Fire", 20200422, [[d80JScqieIhrvixcHkvBIQ0NKusAuIOoLiXQqiXRukzwis3cHu7IOFPuPHPuXXejTmjL6zuf00OkuUMsr2gcj5BskPACiKuNJQq16qOs8oeQKAEkv19qu7tPkhuPOOfQu4HiuXevkQ0fLus0gPkGpIqLKgPsrvNuPOWkPk6Lskj0mLus5MkfL2PKIFkPKGHQuuXsrOsINIQMQsPUkvbYxrOszVI6VOmyKomLfRWJjmzu5YqBwIpJGrtvDAHvtvG61IiZMk3wr7wLFl1WLKJlPelxvph00jDDLSDr47sQgpcLZJiwpcvnFrQ9dCo182zEotXCn1ENAVZoESAxB5oECpS2ESuZ8kjvyMVYejzeWm)ztmZ7bIhZ8vgjU24YBN5H96fyM3x1kiXLD3LqO(RHu0ZDHXC5mn6t8wr3fgtXUz(XkC6MXLhzEotXCn1ENAVZoESAxB5oECpmvpgrDM3wQF)zE(ysCY8(bhhE5rMNdHImVhbOEG4raDZAeqGNEeG6RAfK4YU7siu)1qk65UWyUCMg9jERO7cJPyxGNEeGUzw9HdqRDTjfqR9o1EhGNap9iaL44BhbesCb4PhbOenG6bbravJjY0MXfiG(M6JpGQ(2bOQ9eqvQXezAZ4ceql9dOodQenef9XbO2iCHscGUGgbekbE6rakrdOEqvCMIaQRjeca9rIlaAT2seCa6M7J2ekbE6rakrdO1ADdXdqfgub0hRLv84epfcOL(buItphlOg9bOjhsuskGY1xTQcO(TJdqdfql9dOgGwEe6dOBwuX(buHb1uKap9iaLOb0n3aAdhcO2bO4PpjaQ6BkGwVxooa9r4YPaACaQbO(2ZjmOcOBoK89WzqfqJJOjytuc80JauIgqRvE2WHaku)qOaQWhfjfhbaTpa1a0cwhql9NeeqJdqvFeq3m3CQ1auTb0h5wceqR3FsU24KzExavyE7mFO4eYCDDw1h9hkj5TZ1KAE7mpE2WHC5nY8NnXmVgCiu7FYenhsSmVj0OVmVgCiu7FYenhsSmV4df)WY8jSpSHdLAmrM2mrphlOg9bO7bOjSpSHdL9XwqKjwAxkznxtTZBN5XZgoKlVrMx8HIFyz(e2h2WHsnMitBMONJfuJ(a09a0e2h2WHY(yliYelTlLmVj0OVmVGeHR1VVqWgodQzESuqHYoBIzEbjcxRFFHGnCguZAwZ8IEowqn6Jv5BqmVDUMuZBN5XZgoKlVrMx8HIFyz(XQuKIEowqn6tY11VmVj0OVmVli4RqMh8IJWepnR5AQDE7mpE2WHC5nY8Ipu8dlZpwLIu0ZXcQrFsUU(L5nHg9L5hgbwxy6hIKGznxJhM3oZJNnCixEJmV4df)WY8MqJeidpCgieq3dqtfq9cOJvPif9CSGA0NKRRFzEtOrFzExKiocSrphznxJhlVDM3eA0xMF46MJ1fM6Jm8WjjzE8SHd5YBK1CnBkVDM3eA0xMFIZ(jH1fMBjcog3J2eM5XZgoKlVrwZ1quL3oZBcn6lZxVFhxcmo2JW(StGzE8SHd5YBK1Cn165TZ84zdhYL3iZVGiRUF4qMWGACeY1KAMx8HIFyzEHV9eqiGUhzanva1lGMmGMmGAcn6twIhzdNbvPW3EciKvEtOrFMdq3cqtgqhRsrk65yb1Op5JtloiGs0a6yvkYHZGk(SPbv8LCR30OpanfaL4oGk62X11pzjEKnCguLCR30OpaLOb0Kb0XQuKIEowqn6t(40IdcOPaOe3b0Kb0XQuKdNbv8ztdQ4l5wVPrFakrdO7i3eGMcGMcGUhzaDhanDAaLiaQr84hkkhodQ4ZMguXxINnCihGMonGseavnhEQS4SjY6tINnCihGMonGowLIu0ZXcQrFYhNwCqaDFYa6yvkYHZGk(SPbv8LCR30OpanDAaDSkf5WzqfF20Gk(YhNwCqaDFaDh5Ma00PbuSwwrvfYj9jPcF1)rJJv)dOw)TkiG6fqfD7466N0NKk8v)hnow9pGA93QGmpCNDs1JvB5JtloiGUpGUjanfa1lGowLIu0ZXcQrFYvfG6fqtgqjcGAcn6tcf9l8LiXqXsJJaG6fqjcGAcn6twrY3dNbvzCSIli4RaQxaDSkfPpAACeyRk5QcqtNgqnHg9jHI(f(sKyOyPXraq9cOJvPi9BLb1hTKKCD9dq9cOJvPi9rtJJaBvj566hGMonGAep(HIYHZGk(SPbv8L4zdhYbOEbu1C4PYIZMiRpjE2WHCaQxa1eA0NSIKVhodQY4yfxqWxbuVa6yvksF004iWwvsUU(bOEb0XQuK(TYG6JwssUU(bOPK5xqK1LcJGGlxtQzEtOrFz(s8iB4mOM1Cne15TZ84zdhYL3iZl(qXpSm)yvksrphlOg9j566xM3eA0xM)xhY6cRQRJFwZ14XZBN5XZgoKlVrMFbrwD)WHmHb14iKRj1mVj0OVmFjEKnCguZ8Ipu8dlZBep(HIYHZGk(SPbv8L4zdhYbOEb0KbuecXtGYjo7NewxyULi4yCpAtOCAEW9dOPtdOebqriepbkN4SFsyDH5wIGJX9OnHYzC9dOPaOEbu1C4PYjQy)s8SHd5auVaQAo8uzXztK1NepB4qoa1lGowLIC4mOIpBAqfFjxx)auVaAYaQAo8u5VoK1fwvxhFjE2WHCaQxa1eA0N8xhY6cRQRJVejgkwACeauVaQj0Op5VoK1fwvxhFjsmuSuK940IdcO7dO7ijQa00Pb0Kb0e2h2WHsnMitBMONJfuJ(a09jdO7aOPtdOJvPif9CSGA0NCvbOPaOEbuIaOQ5WtL)6qwxyvDD8L4zdhYbOEbuIaOMqJ(KvK89WzqvghR4cc(kG6fqjcGAcn6twIhhMZjJJvCbbFfqtjR5AsDN82zE8SHd5YBK5nHg9L5fMZXmHg9XCbuZ8UaQSZMyM3eAKazQ5WtHznxtQPM3oZJNnCixEJm)cIS6(HdzcdQXrixtQzEXhk(HL5tgqtgqnHg9jNOI9lJJvCbbFfq9cOMqJ(KtuX(LXXkUGGVYECAXbb09jdO7i3eGMcGMonGAcn6torf7xghR4cc(kGMonGIqiEcuoXz)KW6cZTebhJ7rBcLtZdUFanDAaDSkfPFRmO(OLK8rtOaA60aQj0Opju0VWxIedflnocaQxa1eA0Nek6x4lrIHILIShNwCqaDFaDh5Ma00PbutOrFYks(E4mOkrIHILghba1lGAcn6twrY3dNbvjsmuSuK940IdcO7dO7i3eGMcG6fqtgqhRsr(RdzDHv11XxUQa00PbuIaOQ5WtL)6qwxyvDD8L4zdhYbOPK5xqK1LcJGGlxtQzEtOrFzErphlOg9L1CnPw782zEtOrFz(QwJ(Y84zdhYL3iR5As1dZBN5nHg9L5hUU5yL1tsMhpB4qU8gznxtQES82zEtOrFz(b(q8tkoczE8SHd5YBK1CnPUP82zEtOrFz(s84W1nxMhpB4qU8gznxtQev5TZ8MqJ(Y82jqO(MJjmNlZJNnCixEJSMRj1A982zE8SHd5YBK5fFO4hwMpzanzavnhEQS4SjYQmv4lXZgoKdq9cOMqJeidpCgieq3dqRnGMcGMonGAcnsGm8WzGqaDpaLOcqtbq9cOJvPi9BLb1hTKKpAcfq9cOebqnIh)qr5WzqfF20Gk(s8SHd5Y8MqJ(Y8fNnrO(rsywZ1KkrDE7mpE2WHC5nY8Ipu8dlZpwLISIKVfodoLpAcfq9cOJvPif9CSGA0N8XPfheq3dqfguzAmXmVj0OVmFfjFpCguZAUMu945TZ84zdhYL3iZl(qXpSm)yvks)wzq9rlj5JMqZ8MqJ(Y8vK89WzqnR5AQ9o5TZ8MqJ(Y8v(nEbXyfNnryMhpB4qU8gznxtTtnVDMhpB4qU8gzEXhk(HL5hRsrk65yb1Op5JtloiGUhGkmOY0yIaQxaDSkfPONJfuJ(KRkanDAaDSkfPONJfuJ(KCD9dq9cOIUDCD9tk65yb1Op5JtloiGUpGkmOY0yIzEtOrFzEOOFHFwZ1u7AN3oZJNnCixEJmV4df)WY8JvPif9CSGA0N8XPfheq3hqji4KtJyaQxa1eAKaz4HZaHa6EaAQzEtOrFzExKiocSrphznxtT9W82zE8SHd5YBK5fFO4hwMFSkfPONJfuJ(KpoT4Ga6(akbbNCAedq9cOJvPif9CSGA0NCvL5nHg9L55EJqFq24rt9ZAUMA7XYBN5XZgoKlVrMx8HIFyzE1EcOk9rZP(YkHcO7tgq9WDauVaQAo8ujeTpocmTxcFjE2WHCzEtOrFzEOOFHFwZAM3eAKazQ5WtH5TZ1KAE7mpE2WHC5nY8Ipu8dlZBcnsGm8WzGqaDpanva1lGowLIu0ZXcQrFsUU(bOEb0Kb0e2h2WHsnMitBMONJfuJ(a09aur3oUU(jDrI4iWg9Ci5wVPrFaA60aAc7dB4qPgtKPnt0ZXcQrFa6(Kb0Da0uY8MqJ(Y8UirCeyJEoYAUMAN3oZJNnCixEJmV4df)WY8jSpSHdLAmrM2mrphlOg9bO7tgq3bqtNgqtgqhRsr(RdzDHv11XxUQa00Pbur3oUU(j)1HSUWQ664lFCAXbb09aunMitBgxGaQxa1eA0N8xhY6cRQRJVu4BpbecO7dOPcOPtdOebqvZHNk)1HSUWQ664lXZgoKdqtbq9cOjdOIUDCD9torf7xYTEtJ(a09b0e2h2WHsnMitBMONJfuJ(a00PbunMitBgxGa6(aAc7dB4qPgtKPnt0ZXcQrFaAkzEtOrFz(jQy)znxJhM3oZJNnCixEJmV4df)WY8Q5WtLMdjguFds8gKvwpjs8SHd5auVaAYa6yvksrphlOg9j566hG6fqjcGowLI0VvguF0ss(OjuanDAaDSkfPONJfuJ(KRka1lGAcn6twIhzdNbvPW3Ecieq3hqnHg9jlXJSHZGQCAeJj8TNacbuVakra0XQuK(TYG6JwsYhnHcOPK5nHg9L55EJqFq24rt9ZAwZ8HItiZpi4ZQ(O)qjjVDUMuZBN5XZgoKlVrM3eA0xMxyohZeA0hZfqnZl(qXpSmFc7dB4qPgtKPnt0ZXcQrFa6(Kb0DY8UaQSZMyMpuCczIEowqn6lR5AQDE7mVj0OVm)cISqXjmZJNnCixEJSMRXdZBN5XZgoKlVrM)SjM5N2ffeQnRlSPXDieM5nHg9L5N2ffeQnRlSPXDieM5fFO4hwMNiakwlROQc5KgXd9T3GSsFkRlSQUo(aQxanH9HnCOuJjY0Mj65yb1OpaDFaLOoR5A8y5TZ84zdhYL3iZF2eZ8gXd9T3GSsFkRlSQUo(zEtOrFzEJ4H(2BqwPpL1fwvxh)mV4df)WY8jSpSHdLAmrM2mrphlOg9bO7tgq3eGUfGM6MauIcGMW(Wgouw6tzC9A4qwFSfeZAUMnL3oZJNnCixEJm)ztmZ)Tk(furowIU56MX1oxM3eA0xM)Bv8lOICSeDZ1nJRDUmV4df)WY8jSpSHdLAmrM2mrphlOg9bO7bOjSpSHdL9XwqKjwAxkznxdrvE7mpE2WHC5nY8NnXmVvlROQv8u2zlnClyM3eA0xM3QLvu1kEk7SLgUfmZl(qXpSmFc7dB4qPgtKPnt0ZXcQrFa6EaAc7dB4qzFSfezIL2LswZ1uRN3oZJNnCixEJm)ztmZd9Je4ZsGxpzp6crM3eA0xMh6hjWNLaVEYE0fImV4df)WY8jSpSHdLAmrM2mrphlOg9bO7bOjSpSHdL9XwqKjwAxkznxdrDE7mpE2WHC5nY8NnXmFP)rWXHhRhWGlSJjCw9mVj0OVmFP)rWXHhRhWGlSJjCw9mV4df)WY8jSpSHdLAmrM2mrphlOg9bO7bOjSpSHdL9XwqKjwAxkznxJhpVDMhpB4qU8gzEtOrFzEF7N9fcghonf)WCbXJFMhlfuOSZMyM33(zFHGXHttXpmxq84N1CnPUtE7mpE2WHC5nY8NnXm)0CL(NihZhFZXbzoKq93QGzEtOrFz(P5k9proMp(MJdYCiH6VvbZ8Ipu8dlZNW(WgouQXezAZe9CSGA0hGUhzaDtBcq9cOJvPif9CSGA0NKRRFaQxanH9HnCOuJjY0Mj65yb1OpaDpanH9HnCOSp2cImXs7sjR5Asn182zE8SHd5YBK5pBIzE7ebEklPRvwxy1dixpZ8MqJ(Y82jc8uwsxRSUWQhqUEM5fFO4hwMpH9HnCOuJjY0Mj65yb1OpaDpYa6M2eG6fqhRsrk65yb1Opjxx)auVaAc7dB4qPgtKPnt0ZXcQrFa6EaAc7dB4qzFSfezIL2LswZ1KATZBN5XZgoKlVrM)SjM5pC9MJbj5SkiYWZ3ob(zEtOrFz(dxV5yqsoRcIm88TtGFMx8HIFyz(e2h2WHsnMitBMONJfuJ(a09idOESnbOEb0XQuKIEowqn6tY11pa1lGMW(WgouQXezAZe9CSGA0hGUhGMW(Wgou2hBbrMyPDPK1SM55WITCAE7CnPM3oZBcn6lZl61P4dRqNlZJNnCixEJSMRP25TZ84zdhYL3iZ3vzEiQzEtOrFz(e2h2WHz(eMBHzE1C4PYs8iuTxXxINnCihGsua0s8iuTxXx(40IdcOBbOjdOIUDCD9tk65yb1Op5JtloiGsua0Kb0ubuIgqtyFydhktkooxCeypYTeA0hGsuau1C4PYKIJZfhbjE2WHCaAkakrdOMqJ(K)6qwxyvDD8LiXqXsrMgteqjkaQAo8u5VoK1fwvxhFjE2WHCaAkakrbqjcGk62X11pPONJfuJ(KpACKaOefaDSkfPONJfuJ(KCD9lZNWE2ztmZRXezAZe9CSGA0xwZ14H5TZ84zdhYL3iZ3vz(PrSmVj0OVmFc7dB4WmFcZTWmVOBhxx)KtC2pjSUWClrWX4E0Mq5JtloyMpH9SZMyMxJjY0Mj65yb1OVmV4df)WY8ieINaLtC2pjSUWClrWX4E0Mq508G7hq9cOJvPiN4SFsyDH5wIGJX9OnHsUU(bOEbur3oUU(jN4SFsyDH5wIGJX9OnHYhNwCqaLOb0e2h2WHsnMitBMONJfuJ(a09jdOjSpSHdL(TJJj65yb1OpM6)i0VDCznxJhlVDMhpB4qU8gz(UkZpnIL5nHg9L5tyFydhM5tyUfM5fD7466NSE)oUeyCShH9zNaLpoT4Gz(e2ZoBIzEnMitBMONJfuJ(Y8Ipu8dlZJqiEcuwVFhxcmo2JW(StGYP5b3pG6fqhRsrwVFhxcmo2JW(StGsUU(bOEbur3oUU(jR3VJlbgh7ryF2jq5JtloiGs0aAc7dB4qPgtKPnt0ZXcQrFa6(Kb0e2h2WHs)2XXe9CSGA0ht9Fe63oUSMRzt5TZ84zdhYL3iZBcn6lZlmNJzcn6J5cOM5DbuzNnXmFO4eY8dc(SQp6pusYAUgIQ82zE8SHd5YBK5fFO4hwMFSkfPONJfuJ(KCD9lZBcn6lZpJ)7NftJaM1Cn165TZ84zdhYL3iZl(qXpSmFYaAc7dB4qPgtKPnt0ZXcQrFa6(aAQ7aOPtdOAmrM2mUab09b0e2h2WHsnMitBMONJfuJ(a0uY8MqJ(Y8ew2Zf2X6cZiE8B1pR5AiQZBN5nHg9L5f9jWtFtrowXztmZJNnCixEJSMRXJN3oZBcn6lZ)OvfhbwXzteM5XZgoKlVrwZ1K6o5TZ8MqJ(Y8LwSGihZiE8dfzd0MzE8SHd5YBK1CnPMAE7mVj0OVmF16JcjXrGnCguZ84zdhYL3iR5AsT25TZ8MqJ(Y8Fuv5qwCmyLjWmpE2WHC5nYAUMu9W82zEtOrFzE1hzRB0RJJv6xGzE8SHd5YBK1CnP6XYBN5XZgoKlVrMx8HIFyz(XQuKIEowqn6tY11pa1lGMmGMW(WgouQXezAZe9CSGA0hGUhGwwoh7rHV9eqMgteqtNgqtyFydhk1yImTzIEowqn6dq3dq1yImTzCbcOPK5nHg9L5)1HSUWQ664N1CnPUP82zE8SHd5YBK5nHg9L5fMZXmHg9XCbuZ8Ipu8dlZNW(WgouQXezAZe9CSGA0hGUpzaDNmVlGk7SjM5f9CSGA0hRY3GywZ1KkrvE7mpE2WHC5nY8liYQ7hoKjmOghHCnPM5fFO4hwMpzafHq8eOCIZ(jH1fMBjcog3J2ekNMhC)aA60akcH4jq5eN9tcRlm3seCmUhTjuoJRFa1lGAep(HIYHZGk(SPbv8L4zdhYbOPaOEbuHV9eqiGsgqNgXycF7jGqa1lGseaDSkfPFRmO(OLK8rtOaQxaLiaAYa6yvksF004iWwvYhnHcOEb0Kb0XQuKIEowqn6tUQauVaAYaQj0OpzjECyoNmowXfe8vanDAa1eA0NSIKVhodQY4yfxqWxb00PbutOrFsOOFHVejgkwACea0ua00Pbu1EcOk9rZP(YkHcO7tgq9WDauVaQj0Opju0VWxIedflnocaAkaAkaQxaLiaAYakra0XQuK(OPXrGTQKpAcfq9cOebqhRsr63kdQpAjjF0ekG6fqhRsrk65yb1Opjxx)auVaAYaQj0OpzjECyoNmowXfe8vanDAa1eA0NSIKVhodQY4yfxqWxb0ua0uY8liY6sHrqWLRj1mVj0OVmFjEKnCguZAUMuR1ZBN5XZgoKlVrMVRY8quZ8MqJ(Y8jSpSHdZ8jm3cZ8Q5WtL)6qwxyvDD8L4zdhYbOEbur3oUU(j)1HSUWQ664lFCAXbb09bur3oUU(jlXJSHZGQSSCo2JcF7jGmnMiG6fqtgqtyFydhk1yImTzIEowqn6dq3dqnHg9j)1HSUWQ664lllNJ9OW3EcitJjcOPaOEb0Kbur3oUU(j)1HSUWQ664lFCAXbb09bunMitBgxGaA60aQj0Op5VoK1fwvxhFPW3Ecieq3dq3bqtbqtNgqtyFydhk1yImTzIEowqn6dq3hqnHg9jlXJSHZGQSSCo2JcF7jGmnMiG6fqtyFydhk1yImTzIEowqn6dq3hq1yImTzCbM5typ7SjM5lXJSHZGkRQBxCeYAUMujQZBN5XZgoKlVrMx8HIFyz(XQuK)6qwxyvDD8LRka1lGMmGMW(WgouQXezAZe9CSGA0hGUhGUdGMsMhQFi0CnPM5nHg9L5fMZXmHg9XCbuZ8UaQSZMyM)7kwLVbXSMRjvpEE7mpE2WHC5nY8DvMhIAM3eA0xMpH9HnCyMpH5wyMxnhEQ8xhY6cRQRJVepB4qoa1lGk62X11p5VoK1fwvxhF5JtloiGUpGk62X11pzLFJxqmwXztekllNJ9OW3EcitJjcOEb0Kb0e2h2WHsnMitBMONJfuJ(a09autOrFYFDiRlSQUo(YYY5ypk8TNaY0yIaAkaQxanzav0TJRRFYFDiRlSQUo(YhNwCqaDFavJjY0MXfiGMonGAcn6t(RdzDHv11Xxk8TNacb09a0Da0ua00Pb0e2h2WHsnMitBMONJfuJ(a09butOrFYk)gVGySIZMiuwwoh7rHV9eqMgteq9cOjSpSHdLAmrM2mrphlOg9bO7dOAmrM2mUaZ8jSND2eZ8v(nEbXyvD7IJqwZ1u7DYBN5XZgoKlVrMFbrwD)WHmHb14iKRj1mV4df)WY8jdOebqtyFydhklXJSHZGkRQBxCea00Pb0XQuK)6qwxyvDD8LRkanfa1lGMmGMW(WgouQXezAZe9CSGA0hGUhGUdGMcG6fqtgqnHgjqgE4mqiGUhzanH9HnCO03EoMWGkR4Sjc1pscbuVaAYaQgteqjAaDSkfPONJfuJ(KodQmKyvXJa6EaAc7dB4qjh6msyfNnrO(rsiGMcGMcG6fqjcGwIhHQ9k(stOrceq9cOJvPi9BLb1hTKKCD9dq9cOjdOebqnIh)qr5WzqfF20Gk(s8SHd5a00Pb0XQuKdNbv8ztdQ4lFCAXbb09b0DKBcqtjZVGiRlfgbbxUMuZ8MqJ(Y8L4r2WzqnR5AQDQ5TZ84zdhYL3iZVGiRUF4qMWGACeY1KAMx8HIFyz(s8iuTxXxAcnsGaQxav4BpbecO7rgqtfq9cOjdOebqtyFydhklXJSHZGkRQBxCea00Pb0XQuK)6qwxyvDD8LRkanfa1lGMmGsea1iE8dfLdNbv8ztdQ4lXZgoKdqtNgqhRsroCguXNnnOIV8XPfheq3hq3rUjanfa1lGMmGsea1eA0NSepomNtIedflnocaQxaLiaQj0OpzfjFpCguLXXkUGGVcOEb0XQuK(OPXrGTQKRkanDAa1eA0NSepomNtIedflnocaQxaDSkfPFRmO(OLKKRRFaA60aQj0OpzfjFpCguLXXkUGGVcOEb0XQuK(OPXrGTQKCD9dq9cOJvPi9BLb1hTKKCD9dqtjZVGiRlfgbbxUMuZ8MqJ(Y8L4r2WzqnR5AQDTZBN5XZgoKlVrMx8HIFyz(e2h2WHsnMitBMONJfuJ(a09a0DY8q9dHMRj1mVj0OVmVWCoMj0OpMlGAM3fqLD2eZ8q1oo75yFRMg9L1SM5dfNqMONJfuJ(YBNRj182zE8SHd5YBK5pBIz(GWfA0hBAeqiRSGyM3eA0xMpiCHg9XMgbeYkliM1Cn1oVDMhpB4qU8gz(ZMyM3NKk8v)hnow9pGA93QGzEtOrFzEFsQWx9F04y1)aQ1FRcM5fFO4hwMFSkfPONJfuJ(KRka1lGAcn6twIhzdNbvPW3EcieqjdO7aOEbutOrFYs8iB4mOkFu4BpbKPXeb09aucco50iwwZ14H5TZ84zdhYL3iZF2eZ8t7Icc1M1f204oecZ8MqJ(Y8t7Icc1M1f204oecZAUgpwE7m)yvkSZMyMFAxuqO2SUWMg3Hqit4Bvk(S(WmV4df)WY8JvPif9CSGA0NCvbOPtdOMqJ(KtuX(LXXkUGGVcOEbutOrFYjQy)Y4yfxqWxzpoT4Ga6(Kb0DKBkZVGiRlfgbbxUMuZ84zdhYL3iZBcn6lZlStGo2yvkznxZMYBN5XZgoKlVrM)SjM5nIF9O63qgmocihRYTMgbmZVGiRlfgbbxUMuZ8Ipu8dlZpwLIu0ZXcQrFYvfGMonGAcn6torf7xghR4cc(kG6fqnHg9jNOI9lJJvCbbFL940IdcO7tgq3rUPmVj0OVmVr8Rhv)gYGXra5yvU10iGznxdrvE7mpE2WHC5nY8MqJ(Y8eCgxyA)q2W4iGz(fezDPWii4Y1KAMx8HIFyz(XQuKIEowqn6tUQa00PbutOrFYjQy)Y4yfxqWxbuVaQj0Op5evSFzCSIli4RShNwCqaDFYa6oYnL5Xsbfk7SjM5j4mUW0(HSHXraZAUMA982zE8SHd5YBK5nHg9L5j4mUW0(HSjYzox0xMFbrwxkmccUCnPM5fFO4hwMFSkfPONJfuJ(KRkanDAa1eA0NCIk2VmowXfe8va1lGAcn6torf7xghR4cc(k7XPfheq3NmGUJCtzESuqHYoBIzEcoJlmTFiBICMZf9L1Cne15TZ84zdhYL3iZF2eZ8dZHL4r24Tt4N5xqK1LcJGGlxtQzEXhk(HL5hRsrk65yb1Op5QcqtNgqnHg9jNOI9lJJvCbbFfq9cOMqJ(KtuX(LXXkUGGVYECAXbb09jdO7i3uM3eA0xMFyoSepYgVDc)SMRXJN3oZJNnCixEJm)ztmZd9BrsJqXhYk2riZVGiRlfgbbxUMuZ8Ipu8dlZpwLIu0ZXcQrFYvfGMonGAcn6torf7xghR4cc(kG6fqnHg9jNOI9lJJvCbbFL940IdcO7tgq3rUPmVj0OVmp0VfjncfFiRyhHSMRj1DYBN5XZgoKlVrM)SjM5vI3oeYg2NeSkoeM5xqK1LcJGGlxtQzEXhk(HL5hRsrk65yb1Op5QcqtNgqnHg9jNOI9lJJvCbbFfq9cOMqJ(KtuX(LXXkUGGVYECAXbb09jdO7i3uM3eA0xMxjE7qiByFsWQ4qywZ1KAQ5TZ84zdhYL3iZF2eZ82jc8uwsxRSUWQhqUEM5xqK1LcJGGlxtQzEXhk(HL5hRsrk65yb1Op5QcqtNgqnHg9jNOI9lJJvCbbFfq9cOMqJ(KtuX(LXXkUGGVYECAXbb09jdO7i3uM3eA0xM3orGNYs6AL1fw9aY1ZSMRj1AN3oZJNnCixEJm)ztmZF46nhdsYzvqKHNVDc8Z8liY6sHrqWLRj1mV4df)WY8JvPif9CSGA0NCvbOPtdOMqJ(KtuX(LXXkUGGVcOEbutOrFYjQy)Y4yfxqWxzpoT4Ga6(Kb0DKBkZBcn6lZF46nhdsYzvqKHNVDc8ZAUMu9W82zE8SHd5YBK5pBIz(P5k9proMp(MJdYCiH6VvbZ8liY6sHrqWLRj1mV4df)WY8JvPif9CSGA0NCvbOPtdOMqJ(KtuX(LXXkUGGVcOEbutOrFYjQy)Y4yfxqWxzpoT4Ga6(Kb0DKBkZBcn6lZpnxP)jYX8X3CCqMdju)TkywZAM)7kwLVbX825AsnVDM3eA0xM)xhY6cRQRJFMhpB4qU8gznxtTZBN5XZgoKlVrMx8HIFyz(KbutOrcKHhodecO7rgqtyFydhk9BLb1hTKyfNnrO(rsiG6fqtgq1yIakrdOJvPif9CSGA0N0zqLHeRkEeq3dqtyFydhk5qNrcR4Sjc1pscb0ua0uauVa6yvks)wzq9rlj5JMqZ8MqJ(Y8fNnrO(rsywZ14H5TZ84zdhYL3iZl(qXpSm)yvks)wzq9rlj5JMqZ8MqJ(Y8vK89WzqnR5A8y5TZ84zdhYL3iZVGiRUF4qMWGACeY1KAMx8HIFyzEIaOjdOMqJeidpCgieq3JmGMW(Wgou6BphtyqLvC2eH6hjHaQxanzavJjcOenGowLIu0ZXcQrFsNbvgsSQ4raDpanH9HnCOKdDgjSIZMiu)ijeqtbqtbq9cOebqlXJq1EfFPj0ibcOEb0KbuIaOJvPi9rtJJaBvjF0ekG6fqjcGowLI0VvguF0ss(Ojua1lGseaT6XeSUuyeeCYs8iB4mOcOEb0KbutOrFYs8iB4mOkf(2taHa6EKb0AdOPtdOjdOMqJ(Kv(nEbXyfNnrOu4BpbecO7rgqtfq9cOQ5WtLv(nEbXyfNnrOepB4qoanfanDAanzavnhEQ0CiXG6BqI3GSY6jrINnCihG6fqfD7466NK7nc9bzJhn1x(OXrcGMcGMonGMmGQMdpvcr7JJat7LWxINnCihG6fqv7jGQ0hnN6lRekGUpza1d3bqtbqtbqtjZVGiRlfgbbxUMuZ8MqJ(Y8L4r2WzqnR5A2uE7mpE2WHC5nY8MqJ(Y8cZ5yMqJ(yUaQzExav2ztmZBcnsGm1C4PWSMRHOkVDMhpB4qU8gzEXhk(HL5hRsrwrY3cNbNYhnHcOEbuHbvMgteq3hqhRsrwrY3cNbNYhNwCqa1lGowLI8xhY6cRQRJV8XPfheq3dqfguzAmXmVj0OVmFfjFpCguZAUMA982zE8SHd5YBK5xqKv3pCityqnoc5AsnZl(qXpSmpra0KbutOrcKHhodecO7rgqtyFydhk9TNJjmOYkoBIq9JKqa1lGMmGQXebuIgqhRsrk65yb1OpPZGkdjwv8iGUhGMW(WgouYHoJewXzteQFKecOPaOPaOEbuIaOL4rOAVIV0eAKabuVaAYa6yvksF004iWwvYhnHcOEb0Kbu1EcOk9rZP(YkHcO7rgq9WDa00PbuIaOQ5WtLq0(4iW0Ej8L4zdhYbOPaOPK5xqK1LcJGGlxtQzEtOrFz(s8iB4mOM1Cne15TZ84zdhYL3iZVGiRUF4qMWGACeY1KAMx8HIFyzEIaOjdOMqJeidpCgieq3JmGMW(Wgou6BphtyqLvC2eH6hjHaQxanzavJjcOenGowLIu0ZXcQrFsNbvgsSQ4raDpanH9HnCOKdDgjSIZMiu)ijeqtbqtbq9cOebqlXJq1EfFPj0ibcOEbu1C4PsiAFCeyAVe(s8SHd5auVaQApbuL(O5uFzLqb09jdOE4oaQxanzaDSkfPpAACeyRk5JMqbuVakrautOrFsOOFHVejgkwACea00PbuIaOJvPi9rtJJaBvjF0ekG6fqjcGowLI0VvguF0ss(OjuanLm)cISUuyeeC5AsnZBcn6lZxIhzdNb1SMRXJN3oZJNnCixEJmV4df)WY8ebqREmbJGGtMQSYVXligR4SjcbuVa6yvksF004iWwvYhnHM5nHg9L5R8B8cIXkoBIWSMRj1DYBN5XZgoKlVrMx8HIFyzE1EcOk9rZP(YkHcO7tgq9WDauVaQAo8ujeTpocmTxcFjE2WHCzEtOrFzEOOFHFwZ1KAQ5TZ84zdhYL3iZl(qXpSmVj0ibYWdNbcb09a0AN5nHg9L55EJqFq24rt9ZAUMuRDE7mpE2WHC5nY8Ipu8dlZNmGAcnsGm8WzGqaDpYaAc7dB4qPV9CmHbvwXzteQFKecOEb0KbunMiGs0a6yvksrphlOg9jDguziXQIhb09a0e2h2WHso0zKWkoBIq9JKqanfanLmVj0OVmFXzteQFKeM1CnP6H5TZ8MqJ(Y8L4XH5CzE8SHd5YBK1SM5HQDC2ZX(wnn6lVDUMuZBN5XZgoKlVrMx8HIFyz(KbutOrcKHhodecO7rgqtyFydhk9BLb1hTKyfNnrO(rsiG6fqtgq1yIakrdOJvPif9CSGA0N0zqLHeRkEeq3dqtyFydhk5qNrcR4Sjc1pscb0ua0uauVa6yvks)wzq9rlj5JMqZ8MqJ(Y8fNnrO(rsywZ1u782zE8SHd5YBK5fFO4hwMFSkfPFRmO(OLK8rtOaQxaDSkfPFRmO(OLK8XPfheq3hqnHg9jlXJdZ5KiXqXsrMgtmZBcn6lZxrY3dNb1SMRXdZBN5XZgoKlVrMx8HIFyz(XQuK(TYG6JwsYhnHcOEb0Kb0QhtWii4KPklXJdZ5a00Pb0s8iuTxXxAcnsGaA60aQj0OpzfjFpCguLXXkUGGVcOPtdOZorCea0uY8MqJ(Y8vK89WzqnR5A8y5TZ84zdhYL3iZl(qXpSmVW3Ecieq3JmG6HaQxa1eAKaz4HZaHa6EaATbuVakra0e2h2WHYk)gVGySQUDXriZBcn6lZx534feJvC2eHznxZMYBN5XZgoKlVrMx8HIFyz(XQuK(TYG6JwsYhnHcOEbu1EcOk9rZP(YkHcO7tgq9WDauVaQAo8ujeTpocmTxcFjE2WHCzEtOrFz(ks(E4mOM1Cnev5TZ84zdhYL3iZl(qXpSm)yvkYks(w4m4u(Ojua1lGkmOY0yIa6(a6yvkYks(w4m4u(40IdM5nHg9L5Ri57HZGAwZ1uRN3oZJNnCixEJm)cIS6(HdzcdQXrixtQzEXhk(HL5tgqhRsr(RdzDHv11XxY11pa1lGseaTepcv7v8LMqJeiGMcG6fqjcGMW(WgouwIhzdNbvwv3U4iaOEb0Kb0Kb0KbutOrFYs84WCojsmuS04iaOPtdOMqJ(KvK89WzqvIedflnocaAkaQxaDSkfPpAACeyRk5JMqb0ua00Pb0Kbu1C4PsiAFCeyAVe(s8SHd5auVaQApbuL(O5uFzLqb09jdOE4oaQxanzaDSkfPpAACeyRk5JMqbuVakrautOrFsOOFHVejgkwACea00PbuIaOJvPi9BLb1hTKKpAcfq9cOebqhRsr6JMghb2Qs(Ojua1lGAcn6tcf9l8LiXqXsJJaG6fqjcGAcn6twrY3dNbvzCSIli4RaQxaLiaQj0OpzjECyoNmowXfe8vanfanfanLm)cISUuyeeC5AsnZBcn6lZxIhzdNb1SMRHOoVDMhpB4qU8gzEXhk(HL5tgqhRsr6JMghb2Qs(OjuanDAanzaLia6yvks)wzq9rlj5JMqbuVaAYaQj0OpzjEKnCguLcF7jGqaDpaDhanDAavnhEQeI2hhbM2lHVepB4qoa1lGQ2tavPpAo1xwjuaDFYaQhUdGMcGMcGMcG6fqjcGMW(Wgouw534feJv1TloczEtOrFz(k)gVGySIZMimR5A845TZ84zdhYL3iZBcn6lZlmNJzcn6J5cOM5DbuzNnXmVj0ibYuZHNcZAUMu3jVDMhpB4qU8gzEXhk(HL5nHgjqgE4mqiGUhGMAM3eA0xMN7nc9bzJhn1pR5Asn182zE8SHd5YBK5nHg9L5fMZXmHg9XCbuZ8UaQSZMyMpuCczUUoR6J(dLKSMRj1AN3oZJNnCixEJmV4df)WY8Q9eqv6JMt9Lvcfq3NmG6H7aOEbu1C4PsiAFCeyAVe(s8SHd5Y8MqJ(Y8qr)c)SMRjvpmVDMhpB4qU8gzEXhk(HL5nHgjqgE4mqiGUhzanH9HnCO03EoMWGkR4Sjc1pscbuVaAYaQgteqjAaDSkfPONJfuJ(KodQmKyvXJa6EaAc7dB4qjh6msyfNnrO(rsiGMsM3eA0xMV4Sjc1pscZAUMu9y5TZ8MqJ(Y8L4XH5CzE8SHd5YBK1CnPUP82zEtOrFzEOOFHFMhpB4qU8gznRz(Qhf9CyAE7CnPM3oZBcn6lZBVWoKfNIohk0mpE2WHC5nYAUMAN3oZJNnCixEJmFxL5HOM5nHg9L5tyFydhM5tyUfM5XAzfvviNCAxuqO2SUWMg3HqiGMonGI1YkQQqojbNXfM2pKnmociGMonGI1YkQQqojbNXfM2pKnroZ5I(a00PbuSwwrvfYjdcxOrFSPraHSYcIaA60akwlROQc5KkXBhczd7tcwfhcb00PbuSwwrvfYjnIF9O63qgmocihRYTMgbeqtNgqXAzfvviN0orGNYs6AL1fw9aY1tanDAafRLvuvHCsOFlsAek(qwXocaA60akwlROQc5KhUEZXGKCwfez45BNaFanDAafRLvuvHCYH5Ws8iB82j8Z8jSND2eZ8IEowqn6J1hBbXSMRXdZBN5XZgoKlVrMVRY8quZ8MqJ(Y8jSpSHdZ8jm3cZ8yTSIQkKtAep03EdYk9PSUWQ664dOEb0e2h2WHsrphlOg9X6JTGyMpH9SZMyMV0NY461WHS(yliM1CnES82zE8SHd5YBK57Qmpe1mVj0OVmFc7dB4WmFcZTWmFT3bqjkaAYaAc7dB4qPONJfuJ(y9Xwqeq9cOebqtyFydhkl9PmUEnCiRp2cIaAka6waQhBhaLOaOjdOjSpSHdLL(ugxVgoK1hBbranfaDlaT2BcqjkaAYakwlROQc5KgXd9T3GSsFkRlSQUo(aQxaLiaAc7dB4qzPpLX1RHdz9Xwqeqtbq3cqjQbuIcGMmGI1YkQQqo50UOGqTzDHnnUdHqa1lGseanH9HnCOS0NY461WHS(ylicOPK5typ7SjM57JTGitS0UuYAUMnL3oZJNnCixEJmFxL5FeIAM3eA0xMpH9HnCyMpH9SZMyM3VDCmrphlOg9Xu)hH(TJlZZHfB50mFT3jR5AiQYBN5XZgoKlVrMVRY8quZ8MqJ(Y8jSpSHdZ8jm3cZ81gqjkaQAo8uzXztKvzQWxINnCihGUfG6X94akrbqjcGQMdpvwC2ezvMk8L4zdhYL5typ7SjM59BLb1hTKyfNnrO(rsyMx8HIFyz(e2h2WHs)wzq9rljwXzteQFKecOKb0DYAUMA982zE8SHd5YBK57Qmpe1mVj0OVmFc7dB4WmFcZTWmVhcOefavnhEQS4SjYQmv4lXZgoKdq3cq94ECaLOaOebqvZHNkloBISktf(s8SHd5Y8jSND2eZ8(2ZXeguzfNnrO(rsyMx8HIFyz(e2h2WHsF75ycdQSIZMiu)ijeqjdO7K1Cne15TZ84zdhYL3iZ3vz(hHOM5nHg9L5tyFydhM5typ7SjM55qNrcR4Sjc1pscZ8CyXwonZx7nL1CnE882zE8SHd5YBK57Qm)JquZ8MqJ(Y8jSpSHdZ8jSND2eZ8jfhNlocSh5wcn6lZZHfB50m)oYAN1CnPUtE7mpE2WHC5nY8NnXmVr8qF7niR0NY6cRQRJFM3eA0xM3iEOV9gKv6tzDHv11XpR5Asn182zEtOrFz(z8F)SyAeWmpE2WHC5nYAUMuRDE7mVj0OVmFvRrFzE8SHd5YBK1CnP6H5TZ8MqJ(Y8vK89WzqnZJNnCixEJSM1SM5tGpm6lxtT3P27SJhR27K5RB)fhbyMFZyw1VICaQhhqnHg9bOUaQqjWZmF13LWHzEpcq9aXJa6M1iGap9ia1x1kiXLD3LqO(RHu0ZDHXC5mn6t8wr3fgtXUap9iaDZS6dhGw7AtkGw7DQ9oapbE6rakXX3ociK4cWtpcqjAa1dcIaQgtKPnJlqa9n1hFav9Tdqv7jGQuJjY0MXfiGw6hqDgujAik6JdqTr4cLeaDbnciuc80JauIgq9GQ4mfbuxtiea6Jexa0ATLi4a0n3hTjuc80JauIgqR16gIhGkmOcOpwlR4XjEkeql9dOeNEowqn6dqtoKOKuaLRVAvfq9BhhGgkGw6hqnaT8i0hq3SOI9dOcdQPibE6rakrdOBUb0goeqTdqXtFsau13uaTEVCCa6JWLtb04audq9TNtyqfq3Ci57HZGkGghrtWMOe4PhbOenGwR8SHdbuO(HqbuHpkskocaAFaQbOfSoGw6pjiGghGQ(iGUzU5uRbOAdOpYTeiGwV)KCTXjbEc80Ja0ALedflf5a0bw6hburphMcOdKqCqjGUzkeyLcb0RpI23(zz5autOrFqaTphjsGNEeGAcn6dkREu0ZHPKlodMeWtpcqnHg9bLvpk65W0TiVBPBoGNEeGAcn6dkREu0ZHPBrExBryINAA0hWttOrFqz1JIEomDlY7AVWoKfNIohkuGNMqJ(GYQhf9Cy6wK3nH9HnCiPNnrYIEowqn6J1hBbrs7kYqujnH5wizSwwrvfYjN2ffeQnRlSPXDieMonwlROQc5KeCgxyA)q2W4iGPtJ1YkQQqojbNXfM2pKnroZ5I(sNgRLvuvHCYGWfA0hBAeqiRSGy60yTSIQkKtQeVDiKnSpjyvCimDASwwrvfYjnIF9O63qgmocihRYTMgbmDASwwrvfYjTte4PSKUwzDHvpGC9mDASwwrvfYjH(TiPrO4dzf7iKonwlROQc5KhUEZXGKCwfez45BNa)0PXAzfvviNCyoSepYgVDcFGNMqJ(GYQhf9Cy6wK3nH9HnCiPNnrYL(ugxVgoK1hBbrs7kYqujnH5wizSwwrvfYjnIh6BVbzL(uwxyvDD89MW(Wgouk65yb1OpwFSfebE6ra6MHItiGQ(McO2Ja6cICaAVuyWHaAxauItphlOg9bO2Ja61kGUGihGAffFav9diGQXeb0OaOQpscGwVxooaTAPaQbO6hxsOcOliYbO1d1hqjo9CSGA0hG2hGAak03EoKdqfD7466Ne4Pj0OpOS6rrphMUf5DtyFydhs6ztKCFSfezIL2LcPDfziQKMWClKCT3HOKCc7dB4qPONJfuJ(y9Xwq0lrsyFydhkl9PmUEnCiRp2cIPSLhBhIsYjSpSHdLL(ugxVgoK1hBbXu2Q2BIOKmwlROQc5KgXd9T3GSsFkRlSQUo(Ejsc7dB4qzPpLX1RHdz9XwqmLTiQjkjJ1YkQQqo50UOGqTzDHnnUdHqVejH9HnCOS0NY461WHS(yliMcWtpcqjo9CSGA0hGgqaTphja6cICaA9q97LcOe363XLaJdqjUcc7ZobcO9dOBwC2pjaAxa0ATLi4a0n3hTjeqJcGgkGwpCoaDGaQLWcNnCiGAkG6qdQaQ6hqaDAhjakef9Xbb0bw6hbu1hbuecXtG1Qqav0TJRRFaAab0hnosKapnHg9bLvpk65W0TiVBc7dB4qspBIK9Bhht0ZXcQrFm1)rOF74iTRi)ievs5WITCk5AVdWtpcq32pGaAc7dB4qafwHIOeieqvFeqV1CGpG2favTNaQqa1uaTUFi8b0nFRakV(OLeG6bC2eH6hjHqaTxkm4qaTlakXPNJfuJ(auOFVCCa6ab0fe5KapnHg9bLvpk65W0TiVBc7dB4qspBIK9BLb1hTKyfNnrO(rsiPDfziQKgfYjSpSHdL(TYG6JwsSIZMiu)ijK8oKMWClKCTjkQ5WtLfNnrwLPcFjE2WHCB5X94efIOMdpvwC2ezvMk8L4zdhYb80Ja0T9diGMW(WgoeqHvOikbcbu1hb0Bnh4dODbqv7jGkeqnfqR7hcFaDZBphGsCmOcOEaNnrO(rsieq7Lcdoeq7cGsC65yb1Opaf63lhhGoqaDbroa1GaAjCo8LapnHg9bLvpk65W0TiVBc7dB4qspBIK9TNJjmOYkoBIq9JKqs7kYqujnkKtyFydhk9TNJjmOYkoBIq9JKqY7qAcZTqYEirrnhEQS4SjYQmv4lXZgoKBlpUhNOqe1C4PYIZMiRYuHVepB4qoGNEeG6bbJJaG6bC2eH6hjHaQvu8buItphlOg9bObeq7e4dOc7auHTGiGAakmiCrje2PaQn71PaAxauoBAeqavBaDGaQRHkGYTqavBav9raTtGF9p04iaODbq3miCHIaQ6BkG2cX6HaADF8au1hb0ndcxOiGw(EcOK0RhqR(yApjakXPNJfuJ(au1EcOcOWQhnoOeq32pGaAc7dB4qanGa6cICaQ2akScfrHeav9ra1M96uaTlaQgteqJdqHOOpoiGQ(McOZfub0kdcbuRO4dOeNEowqn6dqrIvfpcb0bw6hbupGZMiu)ijecO1dNdqhiGUGihGE9pnNJejWttOrFqz1JIEomDlY7MW(WgoK0ZMizo0zKWkoBIq9JKqs5WITCk5AVjs7kYpcrf4PhbOe3c1hqRvmooxCeifqjo9CSGA0xTkeqfD7466hGwpCoaDGa6JClbYbOdsaudqF746jGAZEDkPa6yPaQ6Ja6TMd8b0UaOIpuiGcv7viGMaFsau)GGpGAffFa1eAKW04iaOeNEowqn6dqTJdqHUUoeq566hGQDD75GaQ6JakECaAxauItphlOg9vRcbur3oUU(jbuIB(4bOtlP4iaOCOiGrFqanoav9raDZCZPwJuaL40ZXcQrF1Qqa9XPfxCeaur3oUU(bObeqFKBjqoaDqcGQ(beqlVj0OpavBa1eIEDkGw6hqRvmooxCeKapnHg9bLvpk65W0TiVBc7dB4qspBIKtkooxCeypYTeA0hPCyXwoL8oYAtAxr(riQap9ia1eA0huw9OONdt3I8UWZQG(TYGQPqGNMqJ(GYQhf9Cy6wK3DbrwO4K0ZMizJ4H(2BqwPpL1fwvxhFGNMqJ(GYQhf9Cy6wK3Dg)3plMgbe4Pj0OpOS6rrphMUf5DRAn6d4Pj0OpOS6rrphMUf5DRi57HZGkWtGNEeGwRKyOyPihGIjWNeavJjcOQpcOMq7hqdiGAjSWzdhkbEAcn6dsw0RtXhwHohWttOrFWTiVBc7dB4qspBIK1yImTzIEowqn6J0UImevstyUfswnhEQSepcv7v8L4zdhYrukXJq1EfF5Jtlo4wjl62X11pPONJfuJ(KpoT4GeLKtLOtyFydhktkooxCeypYTeA0hrrnhEQmP44CXrqINnCixkeTj0Op5VoK1fwvxhFjsmuSuKPXejkQ5WtL)6qwxyvDD8L4zdhYLcrHiIUDCD9tk65yb1Op5JghjeLXQuKIEowqn6tY11pGNMqJ(GBrE3e2h2WHKE2ejRXezAZe9CSGA0hPDf5PrmstyUfsw0TJRRFYjo7NewxyULi4yCpAtO8XPfhK0OqgHq8eOCIZ(jH1fMBjcog3J2ekNMhC)EhRsroXz)KW6cZTebhJ7rBcLCD9ZROBhxx)KtC2pjSUWClrWX4E0Mq5JtloirNW(WgouQXezAZe9CSGA03(KtyFydhk9Bhht0ZXcQrFm1)rOF74aEAcn6dUf5DtyFydhs6ztKSgtKPnt0ZXcQrFK2vKNgXinH5wizr3oUU(jR3VJlbgh7ryF2jq5JtloiPrHmcH4jqz9(DCjW4ypc7ZobkNMhC)EhRsrwVFhxcmo2JW(StGsUU(5v0TJRRFY6974sGXXEe2NDcu(40Ids0jSpSHdLAmrM2mrphlOg9Tp5e2h2WHs)2XXe9CSGA0ht9Fe63ooGNMqJ(GBrExH5CmtOrFmxavspBIKdfNqMFqWNv9r)HscWttOrFWTiV7m(VFwmnciPrH8yvksrphlOg9j566hWttOrFWTiVlHL9CHDSUWmIh)w9jnkKtoH9HnCOuJjY0Mj65yb1OV9tDN0P1yImTzCbUFc7dB4qPgtKPnt0ZXcQrFPa80eA0hClY7k6tGN(MICSIZMiWttOrFWTiV7JwvCeyfNnriWttOrFWTiVBPfliYXmIh)qr2aTjWttOrFWTiVB16JcjXrGnCgubEAcn6dUf5D)OQYHS4yWktGapnHg9b3I8UQpYw3OxhhR0VabEAcn6dUf5D)1HSUWQ664tAuipwLIu0ZXcQrFsUU(5n5e2h2WHsnMitBMONJfuJ(2RSCo2JcF7jGmnMy60jSpSHdLAmrM2mrphlOg9TNgtKPnJlWuaEAcn6dUf5DfMZXmHg9XCbuj9Sjsw0ZXcQrFSkFdIKgfYjSpSHdLAmrM2mrphlOg9Tp5DaEAcn6dUf5DlXJSHZGkPliY6sHrqWrovsxqKv3pCityqnocKtL0OqozecXtGYjo7NewxyULi4yCpAtOCAEW9NoncH4jq5eN9tcRlm3seCmUhTjuoJRFVgXJFOOC4mOIpBAqfFjE2WHCP4v4BpbesEAeJj8TNac9sKXQuK(TYG6JwsYhnH6LijpwLI0hnnocSvL8rtOEtESkfPONJfuJ(KRkVjBcn6twIhhMZjJJvCbbFnDAtOrFYks(E4mOkJJvCbbFnDAtOrFsOOFHVejgkwACesjDA1EcOk9rZP(YkHUpzpChVMqJ(Kqr)cFjsmuS04iKskEjsYezSkfPpAACeyRk5JMq9sKXQuK(TYG6JwsYhnH6DSkfPONJfuJ(KCD9ZBYMqJ(KL4XH5CY4yfxqWxtN2eA0NSIKVhodQY4yfxqWxtjfGNMqJ(GBrE3e2h2WHKE2ejxIhzdNbvwv3U4iqAcZTqYQ5WtL)6qwxyvDD8L4zdhY5v0TJRRFYFDiRlSQUo(YhNwCW9fD7466NSepYgodQYYY5ypk8TNaY0yIEtoH9HnCOuJjY0Mj65yb1OV9mHg9j)1HSUWQ664lllNJ9OW3EcitJjMI3KfD7466N8xhY6cRQRJV8XPfhCFnMitBgxGPtBcn6t(RdzDHv11Xxk8TNac3BNusNoH9HnCOuJjY0Mj65yb1OV9nHg9jlXJSHZGQSSCo2JcF7jGmnMO3e2h2WHsnMitBMONJfuJ(2xJjY0MXfiWttOrFWTiVRWCoMj0OpMlGkPNnrYFxXQ8nisku)qOKtL0OqESkf5VoK1fwvxhF5QYBYjSpSHdLAmrM2mrphlOg9T3oPa80eA0hClY7MW(WgoK0ZMi5k)gVGySQUDXrG0eMBHKvZHNk)1HSUWQ664lXZgoKZROBhxx)K)6qwxyvDD8LpoT4G7l62X11pzLFJxqmwXztekllNJ9OW3EcitJj6n5e2h2WHsnMitBMONJfuJ(2ZeA0N8xhY6cRQRJVSSCo2JcF7jGmnMykEtw0TJRRFYFDiRlSQUo(YhNwCW91yImTzCbMoTj0Op5VoK1fwvxhFPW3EciCVDsjD6e2h2WHsnMitBMONJfuJ(23eA0NSYVXligR4SjcLLLZXEu4BpbKPXe9MW(WgouQXezAZe9CSGA03(AmrM2mUabE6rakXnF8a0nV9CcdQXraq9aoBIakV(rsiPaQhiEeq3WzqfcOq)E54a0bcOliYbOAdOeWdFtraDZ3kGYRpAjbbu74auTbuKykECa6godQ4dOBwdQ4lbEAcn6dUf5DlXJSHZGkPliY6sHrqWrovsxqKv3pCityqnocKtL0OqozIKW(WgouwIhzdNbvwv3U4iKo9yvkYFDiRlSQUo(YvvkEtoH9HnCOuJjY0Mj65yb1OV92jfVjBcnsGm8WzGW9iNW(Wgou6BphtyqLvC2eH6hjHEtwJjs0JvPif9CSGA0N0zqLHeRkECVe2h2WHso0zKWkoBIq9JKWusXlrkXJq1EfFPj0ib6DSkfPFRmO(OLKKRRFEtMigXJFOOC4mOIpBAqfFjE2WHCPtpwLIC4mOIpBAqfF5Jtlo4(7i3ukap9iaDZD9Xraq9aXJq1EfFsbupq8iGUHZGkeqThb0fe5auymdN9osauTbuU1hhbaL40ZXcQrFsaL4Q4HV5CKqkGQ(ijaQ9iGUGihGQnGsap8nfb0nFRakV(OLeeqR7JhGk(qHaA9W5a0RvaDGaADdQihGAhhGwpuFaDdNbv8b0nRbv8jfqvFKeaf63lhhGoqafw9OXbO9sbuTb0PfNAXbOQpcOB4mOIpGUznOIpGowLIe4Pj0Op4wK3TepYgodQKUGiRlfgbbh5ujDbrwD)WHmHb14iqovsJc5s8iuTxXxAcnsGEf(2taH7rovVjtKe2h2WHYs8iB4mOYQ62fhH0PhRsr(RdzDHv11XxUQsXBYeXiE8dfLdNbv8ztdQ4lXZgoKlD6XQuKdNbv8ztdQ4lFCAXb3Fh5MsXBYeXeA0NSepomNtIedflnocEjIj0OpzfjFpCguLXXkUGGV6DSkfPpAACeyRk5QkDAtOrFYs84WCojsmuS04i4DSkfPFRmO(OLKKRRFPtBcn6twrY3dNbvzCSIli4REhRsr6JMghb2QsY11pVJvPi9BLb1hTKKCD9lfGNMqJ(GBrExH5CmtOrFmxavspBIKHQDC2ZX(wnn6JuO(HqjNkPrHCc7dB4qPgtKPnt0ZXcQrF7TdWtGNMqJ(GstOrcKPMdpfs2fjIJaB0ZbPrHSj0ibYWdNbc3lvVJvPif9CSGA0NKRRFEtoH9HnCOuJjY0Mj65yb1OV9eD7466N0fjIJaB0ZHKB9Mg9LoDc7dB4qPgtKPnt0ZXcQrF7tENuaEAcn6dknHgjqMAo8u4wK3DIk2pPrHCc7dB4qPgtKPnt0ZXcQrF7tEN0PtESkf5VoK1fwvxhF5QkDAr3oUU(j)1HSUWQ664lFCAXb3tJjY0MXfOxtOrFYFDiRlSQUo(sHV9eq4(PMonruZHNk)1HSUWQ664lXZgoKlfVjl62X11p5evSFj36nn6B)e2h2WHsnMitBMONJfuJ(sNwJjY0MXf4(jSpSHdLAmrM2mrphlOg9LcWttOrFqPj0ibYuZHNc3I8UCVrOpiB8OP(KgfYQ5WtLMdjguFds8gKvwpjs8SHd58M8yvksrphlOg9j566NxImwLI0VvguF0ss(Oj00PhRsrk65yb1Op5QYRj0OpzjEKnCguLcF7jGW9nHg9jlXJSHZGQCAeJj8TNac9sKXQuK(TYG6JwsYhnHMcWtGNEeGsC65yb1OpaTY3GiGw9yL9ieqTr4cnqiGwpuFa1auo0zKqkGQ(4bOoBDcFecOXPnGQ(iGsC65yb1OpafI1Ycpbc80eA0huk65yb1OpwLVbrYUGGVczEWloct8usJc5XQuKIEowqn6tY11pGNMqJ(GsrphlOg9XQ8niUf5Dhgbwxy6hIKGKgfYJvPif9CSGA0NKRRFapnHg9bLIEowqn6Jv5BqClY76IeXrGn65G0Oq2eAKaz4HZaH7LQ3XQuKIEowqn6tY11pGNMqJ(GsrphlOg9XQ8niUf5DhUU5yDHP(idpCscWttOrFqPONJfuJ(yv(ge3I8UtC2pjSUWClrWX4E0MqGNMqJ(GsrphlOg9XQ8niUf5DR3VJlbgh7ryF2jqGNEeGU5U(4iaOeNEowqn6Jua1depcOB4mOcbu7raDbroavBaLaE4BkcOB(wbuE9rljiGAhhGoJlMbXJaQ6JaQn71PaAxaunMiGcRWtbuKyOyPXraqB1hFafwHohucOEG(buOAhN9CaQhiEKua1depcOB4mOcbu7raTphja6cICaADF8a0npAACeaupOkanGaQj0ibcO9dO19XdqnaLx0VWhqfgub0acOXbOvFt4rieqTJdq38OPXraq9GQau74a0nFRakV(OLeGApcOxRaQj0ibkbuIBH6dOB4mOIpGUznOIpGAhhG6bC2eb0Afosbupq8iGUHZGkeqf2bOghxOrFMZrcGoqaDbroaTUF4qaDZ3kGYRpAjbO2XbOBE004iaOEqvaQ9iGETcOMqJeiGAhhGAa6MdjFpCgub0acOXbOQpcOw8aQDCaQ5GnGw3pCiGkmOghbaLx0VWhqXe4bOrbq38OPXraq9GQa0acOM7rJJea1eAKaLa62(iG6mvXhqnNRRdbuTEdOB(wbuE9rljaDZHKVhodQqavBaDGaQWGkGghGcxcbcHrFaQvu8bu1hbuEr)cFjGUzYXfA0N5CKaO1d1hq3WzqfFaDZAqfFa1ooa1d4SjcO1kCKcOEG4raDdNbviGc97LJdqVwb0bcOliYbORZHqiGUHZGk(a6M1Gk(aAabuB0lfq1gqrIvfpcO9dOQp(iGApcOZ(rav9TdqXRxe8bupq8iGUHZGkeq1gqrIP4XbOB4mOIpGUznOIpGQnGQ(iGIhhG2faL40ZXcQrFsGNEeGAcn6dkf9CSGA0hRY3G4wK3TepYgodQKUGiRlfgbbh5ujDbrwD)WHmHb14iqovsJczHV9eq4EKt1BYjBcn6twIhzdNbvPW3EciKvEtOrFMBRKhRsrk65yb1Op5JtloirpwLIC4mOIpBAqfFj36nn6lfI7IUDCD9twIhzdNbvj36nn6JOtESkfPONJfuJ(KpoT4GPqCp5XQuKdNbv8ztdQ4l5wVPrFe9oYnLsk7rEN0PjIr84hkkhodQ4ZMguXxINnCix60ernhEQS4SjY6tINnCix60JvPif9CSGA0N8XPfhCFYJvPihodQ4ZMguXxYTEtJ(sNESkf5WzqfF20Gk(YhNwCW93rUP0PXAzfvviN0NKk8v)hnow9pGA93QGEfD7466N0NKk8v)hnow9pGA93QGmpCNDs1JvB5Jtlo4(BkfVJvPif9CSGA0NCv5nzIycn6tcf9l8LiXqXsJJGxIycn6twrY3dNbvzCSIli4REhRsr6JMghb2QsUQsN2eA0Nek6x4lrIHILghbVJvPi9BLb1hTKKCD9ZBYJvPi9rtJJaBvj566x60gXJFOOC4mOIpBAqfFjE2WHCPKoTr84hkkhodQ4ZMguXxINnCiNx1C4PYIZMiRpjE2WHCEnHg9jRi57HZGQmowXfe8vVJvPi9rtJJaBvj566N3XQuK(TYG6JwssUU(LcWttOrFqPONJfuJ(yv(ge3I8UL4r2WzqL0fezDPWii4iNkPliYQ7hoKjmOghbYPsAuil8TNac3JCQEtoztOrFYs8iB4mOkf(2taHSYBcn6ZCBL8yvksrphlOg9jFCAXbj6XQuKdNbv8ztdQ4l5wVPrFPqCx0TJRRFYs8iB4mOk5wVPrFeDYJvPif9CSGA0N8XPfhmfI7jpwLIC4mOIpBAqfFj36nn6JO3rUPuszpY7KonrmIh)qr5WzqfF20Gk(s8SHd5sNMiQ5WtLfNnrwFs8SHd5sNESkfPONJfuJ(KpoT4G7tESkf5WzqfF20Gk(sU1BA0x60JvPihodQ4ZMguXx(40IdU)oYnLonwlROQc5K(KuHV6)OXXQ)buR)wf0ROBhxx)K(KuHV6)OXXQ)buR)wfK5H7StQESAlFCAXb3FtP4DSkfPONJfuJ(KRkVjtetOrFsOOFHVejgkwACe8setOrFYks(E4mOkJJvCbbF17yvksF004iWwvYvv60MqJ(Kqr)cFjsmuS04i4DSkfPFRmO(OLKKRRFEhRsr6JMghb2QsY11V0PnIh)qr5WzqfF20Gk(s8SHd58QMdpvwC2ez9jXZgoKZRj0OpzfjFpCguLXXkUGGV6DSkfPpAACeyRkjxx)8owLI0VvguF0ssY11VuaEAcn6dkf9CSGA0hRY3G4wK39xhY6cRQRJpPrH8yvksrphlOg9j566hWtpcq3mbupq8iGUHZGkGc97LJdqhiGUGihGQnGAvvosa0nCguXhq3SguXhqR7hoeqfguJJaGsCL1HaAxa0nNUo(aADF8a0fmoca6godQ4dOBwdQ4tkG6bC2eb0Afosbu74a0nlQy)saDZOaO95ibq3S4SFsa0UaO1AlrWbOBUpAtiGUzJRFanGakwlROQc5ifqv)acOU4qanGaAq46h5a0bkSfeb0qb06HZbOWEIAmriG(iC5uanoaLqhhbanoTbuItphlOg9bO1d1hqlyDa1depcOB4mOcOcF7jGqjWttOrFqPONJfuJ(yv(ge3I8UL4r2WzqL0fez19dhYeguJJa5ujnkKnIh)qr5WzqfF20Gk(s8SHd58MmcH4jq5eN9tcRlm3seCmUhTjuonp4(tNMiieINaLtC2pjSUWClrWX4E0Mq5mU(tXRAo8u5evSFjE2WHCEvZHNkloBIS(K4zdhY5DSkf5WzqfF20Gk(sUU(5nz1C4PYFDiRlSQUo(s8SHd58Acn6t(RdzDHv11XxIedflnocEnHg9j)1HSUWQ664lrIHILIShNwCW93rsuLoDYjSpSHdLAmrM2mrphlOg9Tp5DsNESkfPONJfuJ(KRQu8se1C4PYFDiRlSQUo(s8SHd58setOrFYks(E4mOkJJvCbbF1lrmHg9jlXJdZ5KXXkUGGVMcWttOrFqPONJfuJ(yv(ge3I8UcZ5yMqJ(yUaQKE2ejBcnsGm1C4PqGNMqJ(GsrphlOg9XQ8niUf5Df9CSGA0hPliY6sHrqWrovsxqKv3pCityqnocKtL0Oqo5KnHg9jNOI9lJJvCbbF1Rj0Op5evSFzCSIli4RShNwCW9jVJCtPKoTj0Op5evSFzCSIli4RPtJqiEcuoXz)KW6cZTebhJ7rBcLtZdU)0PhRsr63kdQpAjjF0eA60MqJ(Kqr)cFjsmuS04i41eA0Nek6x4lrIHILIShNwCW93rUP0PnHg9jRi57HZGQejgkwACe8Acn6twrY3dNbvjsmuSuK940IdU)oYnLI3KhRsr(RdzDHv11XxUQsNMiQ5WtL)6qwxyvDD8L4zdhYLcWttOrFqPONJfuJ(yv(ge3I8UvTg9b80eA0huk65yb1OpwLVbXTiV7W1nhRSEsaEAcn6dkf9CSGA0hRY3G4wK3DGpe)KIJaWttOrFqPONJfuJ(yv(ge3I8UL4XHRBoGNMqJ(GsrphlOg9XQ8niUf5DTtGq9nhtyohWttOrFqPONJfuJ(yv(ge3I8UfNnrO(rsiPrHCYjRMdpvwC2ezvMk8L4zdhY51eAKaz4HZaH7v7usN2eAKaz4HZaH7ruLI3XQuK(TYG6JwsYhnH6LigXJFOOC4mOIpBAqfFjE2WHCapnHg9bLIEowqn6Jv5BqClY7wrY3dNbvsJc5XQuKvK8TWzWP8rtOEhRsrk65yb1Op5Jtlo4EcdQmnMiWttOrFqPONJfuJ(yv(ge3I8UvK89WzqL0OqESkfPFRmO(OLK8rtOap9iaL40ZjEACeau1pGakE6tcG2lL4Aan0AviG(OJK4iaO9bOgG(Oj0OpavJjcOCOZibqR7JhGssVa0KUUoGssVEaLx0VWhqRhohGk(qbu74aus6fG6BCa6MhnnocaQhufGw3hpaLKEbOcdQakVOFHVe4PhbOBghrtWMiPaQ6hqanGaQVDCoKdqN9Ja6z66nNJejWtpcqnHg9bLIEowqn6Jv5BqClY7wrY3dNbvsJc5QhtWii4KPkHI(f(EhRsr6JMghb2QsUQaEAcn6dkf9CSGA0hRY3G4wK3TYVXligR4SjcbEAcn6dkf9CSGA0hRY3G4wK3fk6x4tAuipwLIu0ZXcQrFYhNwCW9eguzAmrVJvPif9CSGA0NCvLo9yvksrphlOg9j566Nxr3oUU(jf9CSGA0N8XPfhCFHbvMgte4Pj0OpOu0ZXcQrFSkFdIBrExxKiocSrphKgfYJvPif9CSGA0N8XPfhCFcco50iMxtOrcKHhodeUxQapnHg9bLIEowqn6Jv5BqClY7Y9gH(GSXJM6tAuipwLIu0ZXcQrFYhNwCW9ji4KtJyEhRsrk65yb1Op5Qc4Pj0OpOu0ZXcQrFSkFdIBrExOOFHpPrHSApbuL(O5uFzLq3NShUJx1C4PsiAFCeyAVe(s8SHd5aEc80eA0hugkoHmrphlOg9rEbrwO4K0ZMi5GWfA0hBAeqiRSGiWttOrFqzO4eYe9CSGA03wK3DbrwO4K0ZMizFsQWx9F04y1)aQ1FRcsAuipwLIu0ZXcQrFYvLxtOrFYs8iB4mOkf(2taHK3XRj0OpzjEKnCguLpk8TNaY0yI7rqWjNgXaEAcn6dkdfNqMONJfuJ(2I8UliYcfNKE2ejpTlkiuBwxytJ7qie4Pj0OpOmuCczIEowqn6BlY7kStGo2yvkKUGiRlfgbbh5uj9SjsEAxuqO2SUWMg3Hqit4Bvk(S(qsJc5XQuKIEowqn6tUQsN2eA0NCIk2VmowXfe8vVMqJ(KtuX(LXXkUGGVYECAXb3N8oYnb80eA0hugkoHmrphlOg9Tf5DxqKfkojDbrwxkmccoYPs6ztKSr8Rhv)gYGXra5yvU10iGKgfYJvPif9CSGA0NCvLoTj0Op5evSFzCSIli4REnHg9jNOI9lJJvCbbFL940IdUp5DKBc4Pj0OpOmuCczIEowqn6BlY7UGiluCs6cISUuyeeCKtLuSuqHYoBIKj4mUW0(HSHXrajnkKhRsrk65yb1Op5QkDAtOrFYjQy)Y4yfxqWx9Acn6torf7xghR4cc(k7XPfhCFY7i3eWttOrFqzO4eYe9CSGA03wK3DbrwO4K0fezDPWii4iNkPyPGcLD2ejtWzCHP9dztKZCUOpsJc5XQuKIEowqn6tUQsN2eA0NCIk2VmowXfe8vVMqJ(KtuX(LXXkUGGVYECAXb3N8oYnb80eA0hugkoHmrphlOg9Tf5DxqKfkojDbrwxkmccoYPs6ztK8WCyjEKnE7e(KgfYJvPif9CSGA0NCvLoTj0Op5evSFzCSIli4REnHg9jNOI9lJJvCbbFL940IdUp5DKBc4Pj0OpOmuCczIEowqn6BlY7UGiluCs6cISUuyeeCKtL0ZMizOFlsAek(qwXocKgfYJvPif9CSGA0NCvLoTj0Op5evSFzCSIli4REnHg9jNOI9lJJvCbbFL940IdUp5DKBc4Pj0OpOmuCczIEowqn6BlY7UGiluCs6cISUuyeeCKtL0ZMizL4TdHSH9jbRIdHKgfYJvPif9CSGA0NCvLoTj0Op5evSFzCSIli4REnHg9jNOI9lJJvCbbFL940IdUp5DKBc4Pj0OpOmuCczIEowqn6BlY7UGiluCs6cISUuyeeCKtL0ZMiz7ebEklPRvwxy1dixpjnkKhRsrk65yb1Op5QkDAtOrFYjQy)Y4yfxqWx9Acn6torf7xghR4cc(k7XPfhCFY7i3eWttOrFqzO4eYe9CSGA03wK3DbrwO4K0fezDPWii4iNkPNnrYhUEZXGKCwfez45BNaFsJc5XQuKIEowqn6tUQsN2eA0NCIk2VmowXfe8vVMqJ(KtuX(LXXkUGGVYECAXb3N8oYnb80eA0hugkoHmrphlOg9Tf5DxqKfkojDbrwxkmccoYPs6ztK80CL(NihZhFZXbzoKq93QGKgfYJvPif9CSGA0NCvLoTj0Op5evSFzCSIli4REnHg9jNOI9lJJvCbbFL940IdUp5DKBc4jWttOrFqzO4eY8dc(SQp6pusilmNJzcn6J5cOs6ztKCO4eYe9CSGA0hPrHCc7dB4qPgtKPnt0ZXcQrF7tEhGNMqJ(GYqXjK5he8zvF0FOKSf5DxqKfkoHapnHg9bLHItiZpi4ZQ(O)qjzlY7UGiluCs6ztK80UOGqTzDHnnUdHqsJczIG1YkQQqoPr8qF7niR0NY6cRQRJV3e2h2WHsnMitBMONJfuJ(2NOg4Pj0OpOmuCcz(bbFw1h9hkjBrE3fezHItspBIKnIh6BVbzL(uwxyvDD8jnkKtyFydhk1yImTzIEowqn6BFYBARu3erjH9HnCOS0NY461WHS(ylic80eA0hugkoHm)GGpR6J(dLKTiV7cISqXjPNnrYFRIFbvKJLOBUUzCTZrAuiNW(WgouQXezAZe9CSGA03EjSpSHdL9XwqKjwAxkapnHg9bLHItiZpi4ZQ(O)qjzlY7UGiluCs6ztKSvlROQv8u2zlnCliPrHCc7dB4qPgtKPnt0ZXcQrF7LW(Wgou2hBbrMyPDPa80eA0hugkoHm)GGpR6J(dLKTiV7cISqXjPNnrYq)ib(Se41t2JUqqAuiNW(WgouQXezAZe9CSGA03EjSpSHdL9XwqKjwAxkapnHg9bLHItiZpi4ZQ(O)qjzlY7UGiluCs6ztKCP)rWXHhRhWGlSJjCwDsJc5e2h2WHsnMitBMONJfuJ(2lH9HnCOSp2cImXs7sb4Pj0OpOmuCcz(bbFw1h9hkjBrE3fezHItsXsbfk7Sjs23(zFHGXHttXpmxq84d80eA0hugkoHm)GGpR6J(dLKTiV7cISqXjPNnrYtZv6FICmF8nhhK5qc1FRcsAuiNW(WgouQXezAZe9CSGA03EK30M8owLIu0ZXcQrFsUU(5nH9HnCOuJjY0Mj65yb1OV9syFydhk7JTGitS0UuaEAcn6dkdfNqMFqWNv9r)HsYwK3DbrwO4K0ZMiz7ebEklPRvwxy1dixpjnkKtyFydhk1yImTzIEowqn6BpYBAtEhRsrk65yb1Opjxx)8MW(WgouQXezAZe9CSGA03EjSpSHdL9XwqKjwAxkapnHg9bLHItiZpi4ZQ(O)qjzlY7UGiluCs6ztK8HR3CmijNvbrgE(2jWN0OqoH9HnCOuJjY0Mj65yb1OV9i7X2K3XQuKIEowqn6tY11pVjSpSHdLAmrM2mrphlOg9Txc7dB4qzFSfezIL2LcWtGNMqJ(GYqXjK566SQp6pusiVGiluCs6ztKSgCiu7FYenhsmsJc5e2h2WHsnMitBMONJfuJ(2lH9HnCOSp2cImXs7sb4Pj0OpOmuCczUUoR6J(dLKTiV7cISqXjPyPGcLD2ejlir4A97leSHZGkPrHCc7dB4qPgtKPnt0ZXcQrF7LW(Wgou2hBbrMyPDPa8e4Pj0OpO87kwLVbrY)6qwxyvDD8bEAcn6dk)UIv5BqClY7wC2eH6hjHKgfYjBcnsGm8WzGW9iNW(Wgou63kdQpAjXkoBIq9JKqVjRXej6XQuKIEowqn6t6mOYqIvfpUxc7dB4qjh6msyfNnrO(rsykP4DSkfPFRmO(OLK8rtOapnHg9bLFxXQ8niUf5DRi57HZGkPrH8yvks)wzq9rlj5JMqbEAcn6dk)UIv5BqClY7wIhzdNbvsxqK1LcJGGJCQKUGiRUF4qMWGACeiNkPrHmrs2eAKaz4HZaH7roH9HnCO03EoMWGkR4Sjc1psc9MSgtKOhRsrk65yb1OpPZGkdjwv84EjSpSHdLCOZiHvC2eH6hjHPKIxIuIhHQ9k(stOrc0BYezSkfPpAACeyRk5JMq9sKXQuK(TYG6JwsYhnH6LivpMG1LcJGGtwIhzdNbvVjBcn6twIhzdNbvPW3EciCpY1oD6KnHg9jR8B8cIXkoBIqPW3EciCpYP6vnhEQSYVXligR4SjcL4zdhYLs60jRMdpvAoKyq9niXBqwz9KiXZgoKZROBhxx)KCVrOpiB8OP(YhnossjD6KvZHNkHO9XrGP9s4lXZgoKZRApbuL(O5uFzLq3NShUtkPKcWttOrFq53vSkFdIBrExH5CmtOrFmxavspBIKnHgjqMAo8uiWttOrFq53vSkFdIBrE3ks(E4mOsAuipwLISIKVfodoLpAc1RWGktJjU)yvkYks(w4m4u(40Id6DSkf5VoK1fwvxhF5Jtlo4EcdQmnMiWttOrFq53vSkFdIBrE3s8iB4mOs6cISUuyeeCKtL0fez19dhYeguJJa5ujnkKjsYMqJeidpCgiCpYjSpSHdL(2ZXeguzfNnrO(rsO3K1yIe9yvksrphlOg9jDguziXQIh3lH9HnCOKdDgjSIZMiu)ijmLu8sKs8iuTxXxAcnsGEtESkfPpAACeyRk5JMq9MSApbuL(O5uFzLq3JShUt60ernhEQeI2hhbM2lHVepB4qUusb4Pj0OpO87kwLVbXTiVBjEKnCgujDbrwxkmccoYPs6cIS6(HdzcdQXrGCQKgfYejztOrcKHhodeUh5e2h2WHsF75ycdQSIZMiu)ij0BYAmrIESkfPONJfuJ(KodQmKyvXJ7LW(WgouYHoJewXzteQFKeMskEjsjEeQ2R4lnHgjqVQ5WtLq0(4iW0Ej8L4zdhY5vTNaQsF0CQVSsO7t2d3XBYJvPi9rtJJaBvjF0eQxIycn6tcf9l8LiXqXsJJq60ezSkfPpAACeyRk5JMq9sKXQuK(TYG6JwsYhnHMcWtpcqjo9CINghbav9diGIN(KaO9sjUgqdTwfcOp6ijocaAFaQbOpAcn6dq1yIakh6msa06(4bOK0lanPRRdOK0Rhq5f9l8b06HZbOIpua1ooaLKEbO(ghGU5rtJJaG6bvbO19XdqjPxaQWGkGYl6x4lbE6ra6MXr0eSjskGQ(beqdiG6BhNd5a0z)iGEMUEZ5irc80JautOrFq53vSkFdIBrE3ks(E4mOsAuix9ycgbbNmvju0VW37yvksF004iWwvYvLx1C4PsiAFCeyAVe(s8SHd58Q2tavPpAo1xwj09j7H74LijBcnsGm8WzGW9iNW(Wgou63kdQpAjXkoBIq9JKqVjRXej6XQuKIEowqn6t6mOYqIvfpUxc7dB4qjh6msyfNnrO(rsykPa80eA0hu(DfRY3G4wK3TYVXligR4SjcjnkKjs1JjyeeCYuLv(nEbXyfNnrO3XQuK(OPXrGTQKpAcf4Pj0OpO87kwLVbXTiVlu0VWN0OqwTNaQsF0CQVSsO7t2d3XRAo8ujeTpocmTxcFjE2WHCapnHg9bLFxXQ8niUf5D5EJqFq24rt9jnkKnHgjqgE4mq4E1g4Pj0OpO87kwLVbXTiVBXzteQFKesAuiNSj0ibYWdNbc3JCc7dB4qPV9CmHbvwXzteQFKe6nznMirpwLIu0ZXcQrFsNbvgsSQ4X9syFydhk5qNrcR4Sjc1psctjfGNMqJ(GYVRyv(ge3I8UL4XH5CapbEAcn6dkHQDC2ZX(wnn6JCXzteQFKesAuiNSj0ibYWdNbc3JCc7dB4qPFRmO(OLeR4Sjc1psc9MSgtKOhRsrk65yb1OpPZGkdjwv84EjSpSHdLCOZiHvC2eH6hjHPKI3XQuK(TYG6JwsYhnHc80eA0hucv74SNJ9TAA03wK3TIKVhodQKgfYJvPi9BLb1hTKKpAc17yvks)wzq9rlj5Jtlo4(MqJ(KL4XH5CsKyOyPitJjc80eA0hucv74SNJ9TAA03wK3TIKVhodQKgfYJvPi9BLb1hTKKpAc1BYvpMGrqWjtvwIhhMZLoDjEeQ2R4lnHgjW0PnHg9jRi57HZGQmowXfe810PNDI4iKcWttOrFqjuTJZEo23QPrFBrE3k)gVGySIZMiK0Oqw4BpbeUhzp0Rj0ibYWdNbc3R2Ejsc7dB4qzLFJxqmwv3U4ia80eA0hucv74SNJ9TAA03wK3TIKVhodQKgfYJvPi9BLb1hTKKpAc1RApbuL(O5uFzLq3NShUJx1C4PsiAFCeyAVe(s8SHd5aEAcn6dkHQDC2ZX(wnn6BlY7wrY3dNbvsJc5XQuKvK8TWzWP8rtOEfguzAmX9hRsrwrY3cNbNYhNwCqGNMqJ(GsOAhN9CSVvtJ(2I8UL4r2WzqL0fezDPWii4iNkPliYQ7hoKjmOghbYPsAuiN8yvkYFDiRlSQUo(sUU(5LiL4rOAVIV0eAKatXlrsyFydhklXJSHZGkRQBxCe8MCYjBcn6twIhhMZjrIHILghH0PnHg9jRi57HZGQejgkwACesX7yvksF004iWwvYhnHMs60jRMdpvcr7JJat7LWxINnCiNx1EcOk9rZP(YkHUpzpChVjpwLI0hnnocSvL8rtOEjIj0Opju0VWxIedflnocPttKXQuK(TYG6JwsYhnH6LiJvPi9rtJJaBvjF0eQxtOrFsOOFHVejgkwACe8setOrFYks(E4mOkJJvCbbF1lrmHg9jlXJdZ5KXXkUGGVMskPa80JauItpN4PXraqv)acO4PpjaAVuIRb0qRvHa6JosIJaG2hGAa6JMqJ(aunMiGYHoJeaTUpEakj9cqt666akj96buEr)cFaTE4CaQ4dfqTJdqjPxaQVXbOBE004iaOEqvaADF8aus6fGkmOcO8I(f(sGNEeGUzCenbBIKcOQFab0acO(2X5qoaD2pcONPR3CosKap9ia1eA0hucv74SNJ9TAA03wK3TIKVhodQKgfYvpMGrqWjtvcf9l89owLI0hnnocSvLCv5vnhEQeI2hhbM2lHVepB4qoVQ9eqv6JMt9LvcDFYE4oEjsYMqJeidpCgiCpYjSpSHdL(TYG6JwsSIZMiu)ij0BYAmrIESkfPONJfuJ(KodQmKyvXJ7LW(WgouYHoJewXzteQFKeMskapnHg9bLq1oo75yFRMg9Tf5DR8B8cIXkoBIqsJc5KhRsr6JMghb2Qs(Oj00PtMiJvPi9BLb1hTKKpAc1BYMqJ(KL4r2Wzqvk8TNac3BN0PvZHNkHO9XrGP9s4lXZgoKZRApbuL(O5uFzLq3NShUtkPKIxIKW(Wgouw534feJv1TlocapnHg9bLq1oo75yFRMg9Tf5DfMZXmHg9XCbuj9Sjs2eAKazQ5WtHapnHg9bLq1oo75yFRMg9Tf5D5EJqFq24rt9jnkKnHgjqgE4mq4EPc80eA0hucv74SNJ9TAA03wK3vyohZeA0hZfqL0ZMi5qXjK566SQp6pusaEAcn6dkHQDC2ZX(wnn6BlY7cf9l8jnkKv7jGQ0hnN6lRe6(K9WD8QMdpvcr7JJat7LWxINnCihWtpcqjUfQpGIxVi4dOQ9eqfskGgkGgqa1aucwCaQ2aQWGkG6bC2eH6hjHaQbb0s4C4dOXbv04a0UaOEG4XH5CsGNMqJ(GsOAhN9CSVvtJ(2I8UfNnrO(rsiPrHSj0ibYWdNbc3JCc7dB4qPV9CmHbvwXzteQFKe6nznMirpwLIu0ZXcQrFsNbvgsSQ4X9syFydhk5qNrcR4Sjc1psctb4Pj0OpOeQ2Xzph7B10OVTiVBjECyohWttOrFqjuTJZEo23QPrFBrExOOFHFMhwHICnevEywZAod]] )


end
