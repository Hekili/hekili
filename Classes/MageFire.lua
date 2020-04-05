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
            cooldown = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) end,
            recharge = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) end,
            gcd = "off",
            castableWhileCasting = true,

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135807,

            nobuff = "fire_blasting", -- horrible.

            readyTime = function ()
                if settings.no_scorch_blast and action.scorch.executing and ( ( talent.searing_touch.enabled and target.health_pct < 30 ) or ( buff.combustion.up and buff.combustion.remains >= buff.casting.remains ) ) then
                    return buff.casting.remains
                end
            end,

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
        name = "Prevent |T135807:0|t Fire Blast During Critical |T135827:0|t Scorch Casts",
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
    
    spec:RegisterPack( "Fire", 20200401.2, [[d8eeOcqieIhrvixsPsQSjr4tIujgLiPtjsSkes8kLsMfI0TqOYUi6xkLAykvCmrKLPuPEgvbnnQc01ePQTHqs(MivsJtPs05ePsToQcv9oesQmpLQ6EiQ9PuLdsvaAHkfEicPmrLkPCrQcLYgrivFuPsQQrQuj5KufQSsQIEjvHs1mriPCtLkHDks5NiKu1qPkuYsvQKQ8uu1uvk6Qufk(kvbWEf1FrzWiDyklwQEmHjJkxgAZs5Ziy0uvNwy1ufqVwe1SPYTv0Uv53sgUcoUivSCv9CqtN01vY2Pk9DfQXJq58iI1JqvZxHSFGZjL3mZZzkMtB37S7D2XdUtsYDNu63LE4UmZRKmGz(btKSraZ8NnXmprpEmZpyK4kJlVzMhwRxGzEFvhGE8BVnHq9xDPOMBdJ5YzAuN4TMUnmMITZ89v4upUl3Z8CMI5029o7END8G7KKC37S7DzM3wQF9zE(ys0Y8(bhhE5EMNdHImVhbOe94raDxyeqGNEeG6R6a0JF7TjeQ)Qlf1CBymxotJ6eV10THXuSnWtpcq9ao8HdqtIuaD37S7DauIdqtYd6XN(KaEc80JauIMVDeqOhpWtpcqjoa1JbIaQgtKPfJlqa9n1hFav9Tdqv7jGQuJjY0IXfiG2QhqDgujoikQJdqTE4cLeaDbnciuc80JauIdq9yg4mfbuxriea6JE8akrTLi4a0DThTjuc80JauIdqjQvfepavyqfqFmDwXJt8uiG2QhqjA1SVGAuhGMAirjPakxDPlkG6xooanuaTvpGAaA7rOpGUlqfRhqfgutrc80JauIdq31cO1DiGAhGIN(KaOQVPa64A54a0hHlNcOXbOgG6BpNWGkG6XIKV6odQaACehbBIYmVlGkmVzMpuCczUAmB4J6dLK8M50skVzMhpR7qU8gz(ZMyMxdoeQ1pzIIdjwM3eAuxMxdoeQ1pzIIdjwMx8HIFyzEV2hw3HsnMitlMOM9fuJ6a09auV2hw3HY6yliYelTATSMtB35nZ84zDhYL3iZl(qXpSmVx7dR7qPgtKPftuZ(cQrDa6EaQx7dR7qzDSfezILwTwM3eAuxMxqIWv6xxiyDNb1mp2AOqzNnXmVGeHR0VUqW6odQznRzErn7lOg1Xg8niM3mNws5nZ84zDhYL3iZl(qXpSmFF1Asrn7lOg1j5QXxM3eAuxM3fe8viZdCXryINM1CA7oVzMhpR7qU8gzEXhk(HL57RwtkQzFb1Oojxn(Y8MqJ6Y8DJaRAm9drYWSMtZdZBM5XZ6oKlVrMx8HIFyzEtOHxKHhodecO7bOjbOja0(Q1KIA2xqnQtYvJVmVj0OUmVl8ghbwVM9SMtZdM3mZBcnQlZ3DvXXQgt9rgE4KKmpEw3HC5nYAoT0N3mZBcnQlZpXz9KWQgZTebhJ7rBcZ84zDhYL3iR50iQYBM5nHg1L5hxVJZlgh7ryD2jWmpEw3HC5nYAoT018MzE8SUd5YBK5xqKn2pCityqnoc50skZl(qXpSmVW3Ecieq3JmGMeGMaqtfqtfqnHg1jBXJSUZGQu4BpbeYAVj0OoZbOBbOPcO9vRjf1SVGAuN8XPfheqjoaTVAnz3zqfF20Gk(sU1BAuhGMcGURdqfv54QXNSfpY6odQsU1BAuhGsCaAQaAF1Asrn7lOg1jFCAXbb0ua0DDaAQaAF1AYUZGk(SPbv8LCR30OoaL4a0DKPhqtbqtbq3JmGUdGoAeGsea1iE8dfLDNbv8ztdQ4lXZ6oKdqhncqjcGQMdpv2C2ez1jXZ6oKdqhncq7RwtkQzFb1Oo5JtloiGUpzaTVAnz3zqfF20Gk(sU1BAuhGoAeG2xTMS7mOIpBAqfF5JtloiGUpGUJm9a6OrakMoRyya5K(KmGV6)OXXg)buh)2aeqtaOIQCC14t6tYa(Q)JghB8hqD8BdqMhUZoj5b3T8XPfheq3hqtpGMcGMaq7RwtkQzFb1Oo5AaqtaOPcOebqnHg1jHI6f(sKyOyPXraqtaOebqnHg1jhi5RUZGQmowZfe8vanbG2xTM0hnnocS1GCnaOJgbOMqJ6Kqr9cFjsmuS04iaOja0(Q1K(LYG6JwYsUA8bOja0ub0(Q1K(OPXrGTgKC14dqhncqnIh)qrz3zqfF20Gk(s8SUd5a0ua0rJauJ4Xpuu2DguXNnnOIVepR7qoanbGQMdpv2C2ez1jXZ6oKdqtaOMqJ6KdK8v3zqvghR5cc(kGMaq7Rwt6JMghb2AqYvJpanbG2xTM0VuguF0swYvJpanLm)cISQ1yeeC50skZBcnQlZ3IhzDNb1SMtBxM3mZJN1DixEJmV4df)WY89vRjf1SVGAuNKRgFzEtOrDz(FDiRASHAm(znNw6oVzMhpR7qU8gz(fezJ9dhYeguJJqoTKY8MqJ6Y8T4rw3zqnZl(qXpSmVr84hkk7odQ4ZMguXxIN1DihGMaqtfqriepbkN4SEsyvJ5wIGJX9OnHYP5bwpGoAeGseafHq8eOCIZ6jHvnMBjcog3J2ekNXvpGMcGMaqvZHNkNOI1lXZ6oKdqtaOQ5WtLnNnrwDs8SUd5a0eaAF1AYUZGk(SPbv8LC14dqtaOPcOQ5WtL)6qw1yd1y8L4zDhYbOjautOrDYFDiRASHAm(sKyOyPXraqtaOMqJ6K)6qw1yd1y8LiXqXsr2JtloiGUpGUJKOcqhncqtfq9AFyDhk1yImTyIA2xqnQdq3NmGUdGoAeG2xTMuuZ(cQrDY1aGMcGMaqjcGQMdpv(RdzvJnuJXxIN1DihGMaqjcGAcnQtoqYxDNbvzCSMli4RaAcaLiaQj0OozlESBoNmowZfe8vanLSMtlPDYBM5XZ6oKlVrM3eAuxMxyohZeAuhZfqnZ7cOYoBIzEtOHxKPMdpfM1CAjLuEZmpEw3HC5nY8liYg7hoKjmOghHCAjL5fFO4hwMpvafHq8eOCIZ6jHvnMBjcog3J2ekNMhy9a6OraAF1As)szq9rlz5JMqb0rJautOrDsOOEHVejgkwACea0eaQj0OojuuVWxIedflfzpoT4Ga6(a6oY0dOJgbOMqJ6KdK8v3zqvIedflnocaAca1eAuNCGKV6odQsKyOyPi7XPfheq3hq3rMEanfanbGMkG2xTM8xhYQgBOgJVCnaOJgbOebqvZHNk)1HSQXgQX4lXZ6oKdqtjZVGiRAngbbxoTKY8MqJ6Y8IA2xqnQlR50sA35nZ8MqJ6Y8dLg1L5XZ6oKlVrwZPLKhM3mZBcnQlZ3DvXXARNKmpEw3HC5nYAoTK8G5nZ8MqJ6Y8D8H4NCCeY84zDhYL3iR50sk95nZ8MqJ6Y8T4XURkUmpEw3HC5nYAoTKiQYBM5nHg1L5TtGq9nhtyoxMhpR7qU8gznNwsPR5nZ84zDhYL3iZl(qXpSmFQaAQaQAo8uzZztKnyQWxIN1DihGMaqnHgErgE4mqiGUhGUBanfaD0ia1eA4fz4HZaHa6EakrfGMcGMaq7Rwt6xkdQpAjlF0ekGMaqjcGAep(HIYUZGk(SPbv8L4zDhYL5nHg1L5BoBIq9JKXSMtlPDzEZmpEw3HC5nY8Ipu8dlZ3xTMCGKVeodoLpAcfqtaO9vRjf1SVGAuN8XPfheq3dqfguzAmXmVj0OUm)ajF1DguZAoTKs35nZ84zDhYL3iZl(qXpSmFF1As)szq9rlz5JMqZ8MqJ6Y8dK8v3zqnR5029o5nZ8MqJ6Y8d(fEbXynNnryMhpR7qU8gznN2UtkVzMhpR7qU8gzEXhk(HL57RwtkQzFb1Oo5JtloiGUhGkmOY0yIaAcaTVAnPOM9fuJ6KRbaD0iaTVAnPOM9fuJ6KC14dqtaOIQCC14tkQzFb1Oo5JtloiGUpGkmOY0yIzEtOrDzEOOEHFwZPT7DN3mZJN1DixEJmV4df)WY89vRjf1SVGAuN8XPfheq3hqji4KtJyaAca1eA4fz4HZaHa6EaAszEtOrDzEx4nocSEn7znN2U9W8MzE8SUd5YBK5fFO4hwMVVAnPOM9fuJ6KpoT4Ga6(akbbNCAedqtaO9vRjf1SVGAuNCnK5nHg1L55EJqDqw)rt9ZAoTD7bZBM5XZ6oKlVrMx8HIFyzE1EcOk9rZP(YbHcO7tgq9WDa0eaQAo8ujeTpocmTwcFjEw3HCzEtOrDzEOOEHFwZAM3eA4fzQ5WtH5nZPLuEZmpEw3HC5nY8Ipu8dlZBcn8Im8WzGqaDpanjanbG2xTMuuZ(cQrDsUA8bOja0ubuV2hw3HsnMitlMOM9fuJ6a09aurvoUA8jDH34iW61Sl5wVPrDa6OraQx7dR7qPgtKPftuZ(cQrDa6(Kb0Da0uY8MqJ6Y8UWBCey9A2ZAoTDN3mZJN1DixEJmV4df)WY8ETpSUdLAmrMwmrn7lOg1bO7tgq3bqhncqtfq7Rwt(RdzvJnuJXxUga0rJaurvoUA8j)1HSQXgQX4lFCAXbb09aunMitlgxGaAca1eAuN8xhYQgBOgJVu4BpbecO7dOjbOJgbOebqvZHNk)1HSQXgQX4lXZ6oKdqtbqtaOPcOIQCC14torfRxYTEtJ6a09buV2hw3HsnMitlMOM9fuJ6a0rJaunMitlgxGa6(aQx7dR7qPgtKPftuZ(cQrDaAkzEtOrDz(jQy9znNMhM3mZJN1DixEJmV4df)WY8Q5WtLMdjguFds8gK1wpjs8SUd5a0eaAQaAF1Asrn7lOg1j5QXhGMaqjcG2xTM0VuguF0sw(OjuaD0iaTVAnPOM9fuJ6KRbanbGAcnQt2IhzDNbvPW3Ecieq3hqnHg1jBXJSUZGQCAeJj8TNacb0eakra0(Q1K(LYG6JwYYhnHcOPK5nHg1L55EJqDqw)rt9ZAwZ8HItiZpi4Zg(O(qjjVzoTKYBM5XZ6oKlVrM3eAuxMxyohZeAuhZfqnZl(qXpSmVx7dR7qPgtKPftuZ(cQrDa6(Kb0DY8UaQSZMyMpuCczIA2xqnQlR502DEZmVj0OUm)cISqXjmZJN1DixEJSMtZdZBM5XZ6oKlVrM)SjM5N2fneQfRASPXDieM5nHg1L5N2fneQfRASPXDieM5fFO4hwMNiakMoRyya5KgXd9T3GSwDkRASHAm(aAca1R9H1DOuJjY0IjQzFb1OoaDFaDxM1CAEW8MzE8SUd5YBK5pBIzEJ4H(2BqwRoLvn2qng)mVj0OUmVr8qF7niRvNYQgBOgJFMx8HIFyzEV2hw3HsnMitlMOM9fuJ6a09jdOPhq3cqtk9akrbq9AFyDhkB1PmUA1DiRo2cIznNw6ZBM5XZ6oKlVrM)SjM5)sf)cQihZBvCvX4kNlZBcnQlZ)Lk(furoM3Q4QIXvoxMx8HIFyzEV2hw3HsnMitlMOM9fuJ6a09auV2hw3HY6yliYelTATSMtJOkVzMhpR7qU8gz(ZMyM3sNvmukEk7SLgUfmZBcnQlZBPZkgkfpLD2sd3cM5fFO4hwM3R9H1DOuJjY0IjQzFb1OoaDpa1R9H1DOSo2cImXsRwlR50sxZBM5XZ6oKlVrM)SjM5H(Hx8zEXRMShDHiZBcnQlZd9dV4Z8Ixnzp6crMx8HIFyzEV2hw3HsnMitlMOM9fuJ6a09auV2hw3HY6yliYelTATSMtBxM3mZJN1DixEJm)ztmZ3QVhCC4XQom4c7ycNnoZBcnQlZ3QVhCC4XQom4c7ycNnoZl(qXpSmVx7dR7qPgtKPftuZ(cQrDa6EaQx7dR7qzDSfezILwTwwZPLUZBM5XZ6oKlVrM3eAuxM33(zDHGXHttXpmxq84N5Xwdfk7SjM59TFwxiyC40u8dZfep(znNws7K3mZJN1DixEJm)ztmZpnxR(jYX8X3CCqMdjm(TbyM3eAuxMFAUw9tKJ5JV54Gmhsy8BdWmV4df)WY8ETpSUdLAmrMwmrn7lOg1bO7rgqtF6b0eaAF1Asrn7lOg1j5QXhGMaq9AFyDhk1yImTyIA2xqnQdq3dq9AFyDhkRJTGitS0Q1YAoTKskVzMhpR7qU8gz(ZMyM3orGNYs(kLvn24aYvZmVj0OUmVDIapLL8vkRASXbKRMzEXhk(HL59AFyDhk1yImTyIA2xqnQdq3JmGM(0dOja0(Q1KIA2xqnQtYvJpanbG61(W6ouQXezAXe1SVGAuhGUhG61(W6ouwhBbrMyPvRL1CAjT78MzE8SUd5YBK5pBIz(dxV5yqsoBaIm88TtGFM3eAuxM)W1BogKKZgGidpF7e4N5fFO4hwM3R9H1DOuJjY0IjQzFb1OoaDpYaQhm9aAcaTVAnPOM9fuJ6KC14dqtaOETpSUdLAmrMwmrn7lOg1bO7bOETpSUdL1XwqKjwA1AznRzEoSzlNM3mNws5nZ8MqJ6Y8IADk(Wb05Y84zDhYL3iR502DEZmpEw3HC5nY81qMhIAM3eAuxM3R9H1DyM3R5wyMxnhEQSfpcv7v8L4zDhYbOefaTfpcv7v8LpoT4Ga6waAQaQOkhxn(KIA2xqnQt(40IdcOefanvanjaL4auV2hw3HYKJJZfhb2JClHg1bOefavnhEQm544CXrqIN1DihGMcGsCaQj0Oo5VoKvn2qngFjsmuSuKPXebuIcGQMdpv(RdzvJnuJXxIN1DihGMcGsuauIaOIQCC14tkQzFb1Oo5Jghjakrbq7RwtkQzFb1Oojxn(Y8ETND2eZ8AmrMwmrn7lOg1L1CAEyEZmpEw3HC5nY81qMFAelZBcnQlZ71(W6omZ71ClmZlQYXvJp5eN1tcRAm3seCmUhTju(40IdM59Ap7SjM51yImTyIA2xqnQlZl(qXpSmpcH4jq5eN1tcRAm3seCmUhTjuonpW6b0eaAF1AYjoRNew1yULi4yCpAtOKRgFaAcavuLJRgFYjoRNew1yULi4yCpAtO8XPfheqjoa1R9H1DOuJjY0IjQzFb1OoaDFYaQx7dR7qPF54yIA2xqnQJP(pc9lhxwZP5bZBM5XZ6oKlVrMVgY8tJyzEtOrDzEV2hw3HzEVMBHzErvoUA8jhxVJZlgh7ryD2jq5JtloyM3R9SZMyMxJjY0IjQzFb1OUmV4df)WY8ieINaLJR3X5fJJ9iSo7eOCAEG1dOja0(Q1KJR3X5fJJ9iSo7eOKRgFaAcavuLJRgFYX1748IXXEewNDcu(40IdcOehG61(W6ouQXezAXe1SVGAuhGUpza1R9H1DO0VCCmrn7lOg1Xu)hH(LJlR50sFEZmpEw3HC5nY8MqJ6Y8cZ5yMqJ6yUaQzExav2ztmZhkoHm)GGpB4J6dLKSMtJOkVzMhpR7qU8gzEXhk(HL57RwtkQzFb1Oojxn(Y8MqJ6Y8Z4)6zX0iGznNw6AEZmpEw3HC5nY8Ipu8dlZNkG61(W6ouQXezAXe1SVGAuhGUpGM0oa6OraQgtKPfJlqaDFa1R9H1DOuJjY0IjQzFb1OoanLmVj0OUmpHL9CHDSQXmIh)s9ZAoTDzEZmVj0OUmVOobE6BkYXAoBIzE8SUd5YBK1CAP78MzEtOrDz(hTH4iWAoBIWmpEw3HC5nYAoTK2jVzM3eAuxMVvIfe5ygXJFOiRJ2mZJN1DixEJSMtlPKYBM5nHg1L5hwF0ijocSUZGAMhpR7qU8gznNws7oVzM3eAuxM)JHbhYIJbhmbM5XZ6oKlVrwZPLKhM3mZBcnQlZR(iBD9ADCSw9cmZJN1DixEJSMtljpyEZmpEw3HC5nY8Ipu8dlZ3xTMuuZ(cQrDsUA8bOja0ubuV2hw3HsnMitlMOM9fuJ6a09a02Y5ypk8TNaY0yIa6OraQx7dR7qPgtKPftuZ(cQrDa6EaQgtKPfJlqanLmVj0OUm)VoKvn2qng)SMtlP0N3mZJN1DixEJmVj0OUmVWCoMj0OoMlGAMx8HIFyzEV2hw3HsnMitlMOM9fuJ6a09jdO7K5DbuzNnXmVOM9fuJ6yd(geZAoTKiQYBM5XZ6oKlVrMFbr2y)WHmHb14iKtlPmV4df)WY8PcOieINaLtCwpjSQXClrWX4E0Mq508aRhqhncqriepbkN4SEsyvJ5wIGJX9OnHYzC1dOjauJ4Xpuu2DguXNnnOIVepR7qoanfanbGk8TNacbuYa60igt4BpbecOjauIaO9vRj9lLb1hTKLpAcfqtaOebqtfq7Rwt6JMghb2Aq(OjuanbGMkG2xTMuuZ(cQrDY1aGMaqtfqnHg1jBXJDZ5KXXAUGGVcOJgbOMqJ6KdK8v3zqvghR5cc(kGoAeGAcnQtcf1l8LiXqXsJJaGMcGoAeGQ2tavPpAo1xoiuaDFYaQhUdGMaqnHg1jHI6f(sKyOyPXraqtbqtbqtaOebqtfqjcG2xTM0hnnocS1G8rtOaAcaLiaAF1As)szq9rlz5JMqb0eaAF1Asrn7lOg1j5QXhGMaqtfqnHg1jBXJDZ5KXXAUGGVcOJgbOMqJ6KdK8v3zqvghR5cc(kGMcGMsMFbrw1AmccUCAjL5nHg1L5BXJSUZGAwZPLu6AEZmpEw3HC5nY81qMhIAM3eAuxM3R9H1DyM3R5wyMxnhEQ8xhYQgBOgJVepR7qoanbGkQYXvJp5VoKvn2qngF5JtloiGUpGkQYXvJpzlEK1DguLTLZXEu4BpbKPXeb0eaAQaQx7dR7qPgtKPftuZ(cQrDa6EaQj0Oo5VoKvn2qngFzB5CShf(2tazAmranfanbGMkGkQYXvJp5VoKvn2qngF5JtloiGUpGQXezAX4ceqhncqnHg1j)1HSQXgQX4lf(2taHa6Ea6oaAka6OraQx7dR7qPgtKPftuZ(cQrDa6(aQj0OozlEK1DguLTLZXEu4BpbKPXeb0eaQx7dR7qPgtKPftuZ(cQrDa6(aQgtKPfJlWmVx7zNnXmFlEK1Dguzdv5IJqwZPL0UmVzMhpR7qU8gzEtOrDzEH5CmtOrDmxa1mV4df)WY89vRj)1HSQXgQX4lxdaAcanva1R9H1DOuJjY0IjQzFb1OoaDpaDhanLmVlGk7SjM5)AGn4BqmR50skDN3mZJN1DixEJmFnK5HOM5nHg1L59AFyDhM59AUfM5vZHNk)1HSQXgQX4lXZ6oKdqtaOIQCC14t(RdzvJnuJXx(40IdcO7dOIQCC14to4x4feJ1C2eHY2Y5ypk8TNaY0yIaAcanva1R9H1DOuJjY0IjQzFb1OoaDpa1eAuN8xhYQgBOgJVSTCo2JcF7jGmnMiGMcGMaqtfqfv54QXN8xhYQgBOgJV8XPfheq3hq1yImTyCbcOJgbOMqJ6K)6qw1yd1y8LcF7jGqaDpaDhanfaD0ia1R9H1DOuJjY0IjQzFb1OoaDFa1eAuNCWVWligR5SjcLTLZXEu4BpbKPXeb0eaQx7dR7qPgtKPftuZ(cQrDa6(aQgtKPfJlWmVx7zNnXm)GFHxqm2qvU4iK1CA7EN8MzE8SUd5YBK5xqKn2pCityqnoc50skZl(qXpSmFQakrauV2hw3HYw8iR7mOYgQYfhbaD0iaTVAn5VoKvn2qngF5AaqtbqtaOPcOETpSUdLAmrMwmrn7lOg1bO7bO7aOPaOja0ubutOHxKHhodecO7rgq9AFyDhk9TNJjmOYAoBIq9JKranbGMkGQXebuIdq7RwtkQzFb1OoPZGkdj2q8iGUhG61(W6ouYHoJewZzteQFKmcOPaOPaOjauIaOT4rOAVIV0eA4fb0eaAF1As)szq9rlzjxn(a0eaAQakrauJ4Xpuu2DguXNnnOIVepR7qoaD0iaTVAnz3zqfF20Gk(YhNwCqaDFaDhz6b0uY8liYQwJrqWLtlPmVj0OUmFlEK1DguZAoTDNuEZmpEw3HC5nY8liYg7hoKjmOghHCAjL5fFO4hwMVfpcv7v8LMqdViGMaqf(2taHa6EKb0Ka0eaAQakrauV2hw3HYw8iR7mOYgQYfhbaD0iaTVAn5VoKvn2qngF5AaqtbqtaOPcOebqnIh)qrz3zqfF20Gk(s8SUd5a0rJa0(Q1KDNbv8ztdQ4lFCAXbb09b0DKPhqtbqtaOPcOebqnHg1jBXJDZ5KiXqXsJJaGMaqjcGAcnQtoqYxDNbvzCSMli4RaAcaTVAnPpAACeyRb5AaqhncqnHg1jBXJDZ5KiXqXsJJaGMaq7Rwt6xkdQpAjl5QXhGoAeGAcnQtoqYxDNbvzCSMli4RaAcaTVAnPpAACeyRbjxn(a0eaAF1As)szq9rlzjxn(a0uY8liYQwJrqWLtlPmVj0OUmFlEK1DguZAoTDV78MzE8SUd5YBK5nHg1L5fMZXmHg1XCbuZ8Ipu8dlZ71(W6ouQXezAXe1SVGAuhGUhGUtM3fqLD2eZ8q1oo75yFPMg1L1SM5dfNqMOM9fuJ6YBMtlP8MzE8SUd5YBK5pBIz(GWfAuhBAeqiRTGyM3eAuxMpiCHg1XMgbeYAliM1CA7oVzMhpR7qU8gz(ZMyM3NKb8v)hno24pG643gGzEtOrDzEFsgWx9F04yJ)aQJFBaM5fFO4hwMVVAnPOM9fuJ6KRbanbGAcnQt2IhzDNbvPW3EcieqjdO7aOjautOrDYw8iR7mOkFu4BpbKPXeb09aucco50iwwZP5H5nZ84zDhYL3iZF2eZ8t7Igc1Ivn204oecZ8MqJ6Y8t7Igc1Ivn204oecZAonpyEZmFF1ASZMyMFAx0qOwSQXMg3Hqit4Bdk(S6WmV4df)WY89vRjf1SVGAuNCnaOJgbOMqJ6KtuX6LXXAUGGVcOjautOrDYjQy9Y4ynxqWxzpoT4Ga6(Kb0DKPpZVGiRAngbbxoTKY84zDhYL3iZBcnQlZlStGowF1AznNw6ZBM5XZ6oKlVrM)SjM5nIF9O6xqgmocihBWTMgbmZVGiRAngbbxoTKY8Ipu8dlZ3xTMuuZ(cQrDY1aGoAeGAcnQtorfRxghR5cc(kGMaqnHg1jNOI1lJJ1CbbFL940IdcO7tgq3rM(mVj0OUmVr8Rhv)cYGXra5ydU10iGznNgrvEZmpEw3HC5nY8MqJ6Y8eCgxyA9qw34iGz(fezvRXii4YPLuMx8HIFyz((Q1KIA2xqnQtUga0rJautOrDYjQy9Y4ynxqWxb0eaQj0Oo5evSEzCSMli4RShNwCqaDFYa6oY0N5Xwdfk7SjM5j4mUW06HSUXraZAoT018MzE8SUd5YBK5nHg1L5j4mUW06HSjYzoxuxMFbrw1AmccUCAjL5fFO4hwMVVAnPOM9fuJ6KRbaD0ia1eAuNCIkwVmowZfe8vanbGAcnQtorfRxghR5cc(k7XPfheq3NmGUJm9zES1qHYoBIzEcoJlmTEiBICMZf1L1CA7Y8MzE8SUd5YBK5pBIz(U5Ww8iR)2j8Z8liYQwJrqWLtlPmV4df)WY89vRjf1SVGAuNCnaOJgbOMqJ6KtuX6LXXAUGGVcOjautOrDYjQy9Y4ynxqWxzpoT4Ga6(Kb0DKPpZBcnQlZ3nh2Ihz93oHFwZPLUZBM5XZ6oKlVrM)SjM5H(Li5EO4dzn7iK5xqKvTgJGGlNwszEXhk(HL57RwtkQzFb1Oo5AaqhncqnHg1jNOI1lJJ1CbbFfqtaOMqJ6KtuX6LXXAUGGVYECAXbb09jdO7itFM3eAuxMh6xIK7HIpK1SJqwZPL0o5nZ84zDhYL3iZF2eZ8kXBhczD7tgoehcZ8liYQwJrqWLtlPmV4df)WY89vRjf1SVGAuNCnaOJgbOMqJ6KtuX6LXXAUGGVcOjautOrDYjQy9Y4ynxqWxzpoT4Ga6(Kb0DKPpZBcnQlZReVDiK1Tpz4qCimR50skP8MzE8SUd5YBK5pBIzE7ebEkl5Ruw1yJdixnZ8liYQwJrqWLtlPmV4df)WY89vRjf1SVGAuNCnaOJgbOMqJ6KtuX6LXXAUGGVcOjautOrDYjQy9Y4ynxqWxzpoT4Ga6(Kb0DKPpZBcnQlZBNiWtzjFLYQgBCa5QzwZPL0UZBM5XZ6oKlVrM)SjM5pC9MJbj5SbiYWZ3ob(z(fezvRXii4YPLuMx8HIFyz((Q1KIA2xqnQtUga0rJautOrDYjQy9Y4ynxqWxb0eaQj0Oo5evSEzCSMli4RShNwCqaDFYa6oY0N5nHg1L5pC9MJbj5SbiYWZ3ob(znNwsEyEZmpEw3HC5nY8NnXm)0CT6NihZhFZXbzoKW43gGz(fezvRXii4YPLuMx8HIFyz((Q1KIA2xqnQtUga0rJautOrDYjQy9Y4ynxqWxb0eaQj0Oo5evSEzCSMli4RShNwCqaDFYa6oY0N5nHg1L5NMRv)e5y(4BooiZHeg)2amRznZ)1aBW3GyEZCAjL3mZBcnQlZ)RdzvJnuJXpZJN1DixEJSMtB35nZ84zDhYL3iZl(qXpSmFQaQj0WlYWdNbcb09idOETpSUdL(LYG6JwYSMZMiu)izeqtaOPcOAmraL4a0(Q1KIA2xqnQt6mOYqInepcO7bOETpSUdLCOZiH1C2eH6hjJaAkaAkaAcaTVAnPFPmO(OLS8rtOzEtOrDz(MZMiu)izmR508W8MzE8SUd5YBK5fFO4hwMVVAnPFPmO(OLS8rtOzEtOrDz(bs(Q7mOM1CAEW8MzE8SUd5YBK5xqKn2pCityqnoc50skZl(qXpSmpra0ubutOHxKHhodecO7rgq9AFyDhk9TNJjmOYAoBIq9JKranbGMkGQXebuIdq7RwtkQzFb1OoPZGkdj2q8iGUhG61(W6ouYHoJewZzteQFKmcOPaOPaOjauIaOT4rOAVIV0eA4fb0eaAQakra0(Q1K(OPXrGTgKpAcfqtaOebq7Rwt6xkdQpAjlF0ekGMaqjcGo8Oxw1AmccozlEK1Dgub0eaAQaQj0OozlEK1DguLcF7jGqaDpYa6Ub0rJa0ubutOrDYb)cVGySMZMiuk8TNacb09idOjbOjau1C4PYb)cVGySMZMiuIN1DihGMcGoAeGMkGQMdpvAoKyq9niXBqwB9KiXZ6oKdqtaOIQCC14tY9gH6GS(JM6lF04ibqtbqhncqtfqvZHNkHO9XrGP1s4lXZ6oKdqtaOQ9eqv6JMt9Ldcfq3NmG6H7aOPaOPaOPK5xqKvTgJGGlNwszEtOrDz(w8iR7mOM1CAPpVzMhpR7qU8gzEtOrDzEH5CmtOrDmxa1mVlGk7SjM5nHgErMAo8uywZPruL3mZJN1DixEJmV4df)WY89vRjhi5lHZGt5JMqb0eaQWGktJjcO7dO9vRjhi5lHZGt5JtloiGMaq7Rwt(RdzvJnuJXx(40IdcO7bOcdQmnMyM3eAuxMFGKV6odQznNw6AEZmpEw3HC5nY8liYg7hoKjmOghHCAjL5fFO4hwMNiaAQaQj0WlYWdNbcb09idOETpSUdL(2ZXeguznNnrO(rYiGMaqtfq1yIakXbO9vRjf1SVGAuN0zqLHeBiEeq3dq9AFyDhk5qNrcR5Sjc1psgb0ua0ua0eakra0w8iuTxXxAcn8IaAcanvaTVAnPpAACeyRb5JMqb0eaAQaQApbuL(O5uF5Gqb09idOE4oa6Orakrau1C4PsiAFCeyATe(s8SUd5a0ua0uY8liYQwJrqWLtlPmVj0OUmFlEK1DguZAoTDzEZmpEw3HC5nY8liYg7hoKjmOghHCAjL5fFO4hwMNiaAQaQj0WlYWdNbcb09idOETpSUdL(2ZXeguznNnrO(rYiGMaqtfq1yIakXbO9vRjf1SVGAuN0zqLHeBiEeq3dq9AFyDhk5qNrcR5Sjc1psgb0ua0ua0eakra0w8iuTxXxAcn8IaAcavnhEQeI2hhbMwlHVepR7qoanbGQ2tavPpAo1xoiuaDFYaQhUdGMaqtfq7Rwt6JMghb2Aq(OjuanbGsea1eAuNekQx4lrIHILghbaD0iaLiaAF1AsF004iWwdYhnHcOjauIaO9vRj9lLb1hTKLpAcfqtjZVGiRAngbbxoTKY8MqJ6Y8T4rw3zqnR50s35nZ84zDhYL3iZl(qXpSmpra0Hh9Yii4Kjjh8l8cIXAoBIqanbG2xTM0hnnocS1G8rtOzEtOrDz(b)cVGySMZMimR50sAN8MzE8SUd5YBK5fFO4hwMxTNaQsF0CQVCqOa6(KbupChanbGQMdpvcr7JJatRLWxIN1DixM3eAuxMhkQx4N1CAjLuEZmpEw3HC5nY8Ipu8dlZBcn8Im8WzGqaDpaD3zEtOrDzEU3iuhK1F0u)SMtlPDN3mZJN1DixEJmV4df)WY8PcOMqdVidpCgieq3JmG61(W6ou6BphtyqL1C2eH6hjJaAcanvavJjcOehG2xTMuuZ(cQrDsNbvgsSH4raDpa1R9H1DOKdDgjSMZMiu)izeqtbqtjZBcnQlZ3C2eH6hjJznNwsEyEZmVj0OUmFlESBoxMhpR7qU8gznRzEOAhN9CSVutJ6YBMtlP8MzE8SUd5YBK5fFO4hwMpva1eA4fz4HZaHa6EKbuV2hw3Hs)szq9rlzwZzteQFKmcOja0ubunMiGsCaAF1Asrn7lOg1jDguziXgIhb09auV2hw3Hso0zKWAoBIq9JKranfanfanbG2xTM0VuguF0sw(Oj0mVj0OUmFZzteQFKmM1CA7oVzMhpR7qU8gzEXhk(HL57Rwt6xkdQpAjlF0ekGMaq7Rwt6xkdQpAjlFCAXbb09butOrDYw8y3CojsmuSuKPXeZ8MqJ6Y8dK8v3zqnR508W8MzE8SUd5YBK5fFO4hwMVVAnPFPmO(OLS8rtOaAcanvaD4rVmccozsYw8y3CoaD0iaTfpcv7v8LMqdViGoAeGAcnQtoqYxDNbvzCSMli4RaAkzEtOrDz(bs(Q7mOM1CAEW8MzE8SUd5YBK5fFO4hwMx4BpbecO7rgq9qanbGAcn8Im8WzGqaDpaD3aAcaLiaQx7dR7q5GFHxqm2qvU4iK5nHg1L5h8l8cIXAoBIWSMtl95nZ84zDhYL3iZl(qXpSmFF1As)szq9rlz5JMqb0eaQApbuL(O5uF5Gqb09jdOE4oaAcavnhEQeI2hhbMwlHVepR7qUmVj0OUm)ajF1DguZAonIQ8MzE8SUd5YBK5fFO4hwMVVAn5ajFjCgCkF0ekGMaqfguzAmraDFaTVAn5ajFjCgCkFCAXbZ8MqJ6Y8dK8v3zqnR50sxZBM5XZ6oKlVrMFbr2y)WHmHb14iKtlPmV4df)WY8PcO9vRj)1HSQXgQX4l5QXhGMaqjcG2IhHQ9k(stOHxeqtbqtaOebq9AFyDhkBXJSUZGkBOkxCea0eaAQaAQaAQaQj0OozlESBoNejgkwACea0rJautOrDYbs(Q7mOkrIHILghbanfanbG2xTM0hnnocS1G8rtOaAka6OraAQaQAo8ujeTpocmTwcFjEw3HCaAcavTNaQsF0CQVCqOa6(KbupChanbGMkG2xTM0hnnocS1G8rtOaAcaLiaQj0OojuuVWxIedflnoca6Orakra0(Q1K(LYG6JwYYhnHcOjauIaO9vRj9rtJJaBniF0ekGMaqnHg1jHI6f(sKyOyPXraqtaOebqnHg1jhi5RUZGQmowZfe8vanbGsea1eAuNSfp2nNtghR5cc(kGMcGMcGMsMFbrw1AmccUCAjL5nHg1L5BXJSUZGAwZPTlZBM5XZ6oKlVrMx8HIFyz(ub0(Q1K(OPXrGTgKpAcfqhncqtfqjcG2xTM0VuguF0sw(OjuanbGMkGAcnQt2IhzDNbvPW3Ecieq3dq3bqhncqvZHNkHO9XrGP1s4lXZ6oKdqtaOQ9eqv6JMt9Ldcfq3NmG6H7aOPaOPaOPaOjauIaOETpSUdLd(fEbXydv5IJqM3eAuxMFWVWligR5SjcZAoT0DEZmpEw3HC5nY8MqJ6Y8cZ5yMqJ6yUaQzExav2ztmZBcn8Im1C4PWSMtlPDYBM5XZ6oKlVrMx8HIFyzEtOHxKHhodecO7bOjL5nHg1L55EJqDqw)rt9ZAoTKskVzMhpR7qU8gzEtOrDzEH5CmtOrDmxa1mVlGk7SjM5dfNqMRgZg(O(qjjR50sA35nZ84zDhYL3iZl(qXpSmVApbuL(O5uF5Gqb09jdOE4oaAcavnhEQeI2hhbMwlHVepR7qUmVj0OUmpuuVWpR50sYdZBM5XZ6oKlVrMx8HIFyzEtOHxKHhodecO7rgq9AFyDhk9TNJjmOYAoBIq9JKranbGMkGQXebuIdq7RwtkQzFb1OoPZGkdj2q8iGUhG61(W6ouYHoJewZzteQFKmcOPK5nHg1L5BoBIq9JKXSMtljpyEZmVj0OUmFlESBoxMhpR7qU8gznNwsPpVzM3eAuxMhkQx4N5XZ6oKlVrwZAMF4rrn7MM3mNws5nZ8MqJ6Y82lSdzXPOZHcnZJN1DixEJSMtB35nZ84zDhYL3iZxdzEiQzEtOrDzEV2hw3HzEVMBHzEmDwXWaYjN2fneQfRASPXDiecOJgbOy6SIHbKtsWzCHP1dzDJJacOJgbOy6SIHbKtsWzCHP1dztKZCUOoaD0iaftNvmmGCYGWfAuhBAeqiRTGiGoAeGIPZkggqoPs82Hqw3(KHdXHqaD0iaftNvmmGCsJ4xpQ(fKbJJaYXgCRPrab0rJaumDwXWaYjTte4PSKVszvJnoGC1eqhncqX0zfddiNe6xIK7HIpK1SJaGoAeGIPZkggqo5HR3CmijNnargE(2jWhqhncqX0zfddiNSBoSfpY6VDc)mVx7zNnXmVOM9fuJ6y1XwqmR508W8MzE8SUd5YBK5RHmpe1mVj0OUmVx7dR7WmVxZTWmpMoRyya5KgXd9T3GSwDkRASHAm(aAca1R9H1DOuuZ(cQrDS6yliM59Ap7SjM5B1PmUA1DiRo2cIznNMhmVzMhpR7qU8gz(AiZdrnZBcnQlZ71(W6omZ71ClmZV7DauIcGMkG61(W6oukQzFb1OowDSfeb0eakrauV2hw3HYwDkJRwDhYQJTGiGMcGUfG6b3bqjkaAQaQx7dR7qzRoLXvRUdz1Xwqeqtbq3cq3D6buIcGMkGIPZkggqoPr8qF7niRvNYQgBOgJpGMaqjcG61(W6ou2QtzC1Q7qwDSfeb0ua0Ta0DjGsua0ubumDwXWaYjN2fneQfRASPXDiecOjauIaOETpSUdLT6ugxT6oKvhBbranLmVx7zNnXmFDSfezILwTwwZPL(8MzE8SUd5YBK5RHm)JquZ8MqJ6Y8ETpSUdZ8ETND2eZ8(LJJjQzFb1OoM6)i0VCCzEoSzlNM539oznNgrvEZmpEw3HC5nY81qMhIAM3eAuxM3R9H1DyM3R5wyMF3akrbqvZHNkBoBISbtf(s8SUd5a0Ta00D6gqjkakrau1C4PYMZMiBWuHVepR7qUmVx7zNnXmVFPmO(OLmR5Sjc1psgZ8Ipu8dlZ71(W6ou6xkdQpAjZAoBIq9JKraLmGUtwZPLUM3mZJN1DixEJmFnK5HOM5nHg1L59AFyDhM59AUfM59qaLOaOQ5WtLnNnr2GPcFjEw3HCa6waA6oDdOefaLiaQAo8uzZztKnyQWxIN1DixM3R9SZMyM33EoMWGkR5Sjc1psgZ8Ipu8dlZ71(W6ou6BphtyqL1C2eH6hjJakzaDNSMtBxM3mZJN1DixEJmFnK5FeIAM3eAuxM3R9H1DyM3R9SZMyMNdDgjSMZMiu)izmZZHnB50m)UtFwZPLUZBM5XZ6oKlVrMVgY8pcrnZBcnQlZ71(W6omZ71E2ztmZNCCCU4iWEKBj0OUmph2SLtZ87i3DwZPL0o5nZ84zDhYL3iR50skP8MzE8SUd5YBK5pBIzEJ4H(2BqwRoLvn2qng)mVj0OUmVr8qF7niRvNYQgBOgJFwZPL0UZBM5nHg1L5NX)1ZIPraZ84zDhYL3iR50sYdZBM5nHg1L5hknQlZJN1DixEJSMtljpyEZmVj0OUm)ajF1DguZ84zDhYL3iRznRzEV4dJ6YPT7D29o74b3jjzsz(X2FXraM594Md1RihGMUbutOrDaQlGkuc8mZp8vlCyM3JauIE8iGUlmciWtpcq9vDa6XV92ec1F1LIAUnmMlNPrDI3A62Wyk2g4PhbOEah(WbOjrkGU7D29oakXbOj5b94tFsapbE6rakrZ3oci0Jh4PhbOehG6XaravJjY0IXfiG(M6JpGQ(2bOQ9eqvQXezAX4ceqB1dOodQehef1XbOwpCHscGUGgbekbE6rakXbOEmdCMIaQRieca9rpEaLO2seCa6U2J2ekbE6rakXbOe1QcIhGkmOcOpMoR4XjEkeqB1dOeTA2xqnQdqtnKOKuaLRU0ffq9lhhGgkG2QhqnaT9i0hq3fOI1dOcdQPibE6rakXbO7Ab06oeqTdqXtFsau13uaDCTCCa6JWLtb04audq9TNtyqfq9yrYxDNbvanoIJGnrjWtGNEeG6XgXqXsroaTJT6ravuZUPaAhjehucOEafcCqHa6vhX5B)STCaQj0OoiGwNJejWtpcqnHg1bLdpkQz3uYnNbtg4PhbOMqJ6GYHhf1SB6wK3UvfhWtpcqnHg1bLdpkQz30TiVTTimXtnnQd4Pj0OoOC4rrn7MUf5TTxyhYItrNdfkWttOrDq5WJIA2nDlYB71(W6oK0ZMizrn7lOg1XQJTGiP1aziQK61ClKmMoRyya5Kt7Igc1Ivn204oechnctNvmmGCscoJlmTEiRBCeWrJW0zfddiNKGZ4ctRhYMiN5CrDJgHPZkggqozq4cnQJnnciK1wqC0imDwXWaYjvI3oeY62NmCioeoAeMoRyya5KgXVEu9lidghbKJn4wtJaoAeMoRyya5K2jc8uwYxPSQXghqUAoAeMoRyya5Kq)sKCpu8HSMDegnctNvmmGCYdxV5yqsoBaIm88TtG)Ory6SIHbKt2nh2Ihz93oHpWttOrDq5WJIA2nDlYB71(W6oK0ZMi5wDkJRwDhYQJTGiP1aziQK61ClKmMoRyya5KgXd9T3GSwDkRASHAm(j8AFyDhkf1SVGAuhRo2cIap9ia1JtXjeqvFtbu7raDbroaTwkm4qaTAakrRM9fuJ6au7ra9kfqxqKdqTMIpGQ(beq1yIaA0au1hjbqhxlhhGoSua1au9Jlzub0fe5a0XH6dOeTA2xqnQdqRdqnaf6BphYbOIQCC14tc80eAuhuo8OOMDt3I82ETpSUdj9SjsUo2cImXsRwJ0AGmevs9AUfsE37qus1R9H1DOuuZ(cQrDS6yliMGiETpSUdLT6ugxT6oKvhBbXu2YdUdrjvV2hw3HYwDkJRwDhYQJTGykBT70tusftNvmmGCsJ4H(2BqwRoLvn2qng)eeXR9H1DOSvNY4Qv3HS6yliMYw7sIsQy6SIHbKtoTlAiulw1ytJ7qimbr8AFyDhkB1PmUA1DiRo2cIPa80JauIwn7lOg1bObeqRZrcGUGihGoou)APaQhG6DCEX4a0D9qyD2jqaTEaDxGZ6jbqRgGsuBjcoaDx7rBcb0ObOHcOJdNdq7iGAETWzDhcOMcOo0GkGQ(beqN2rcGcrrDCqaTJT6rav9rafHq8ey6ceqfv54QXhGgqa9rJJejWttOrDq5WJIA2nDlYB71(W6oK0ZMiz)YXXe1SVGAuht9Fe6xoosRbYpcrLuoSzlNsE37a80Ja0n9diG61(W6oeqHdOiAbcbu1hb0Bn74dOvdqv7jGkeqnfqh7hcFaDxvkGYRpAjdOeDNnrO(rYieqRLcdoeqRgGs0QzFb1Ooaf6xlhhG2raDbrojWttOrDq5WJIA2nDlYB71(W6oK0ZMiz)szq9rlzwZzteQFKmsAnqgIkPrJSx7dR7qPFPmO(OLmR5Sjc1psgjVdPEn3cjVBIIAo8uzZztKnyQWxIN1Di3wP70nrHiQ5WtLnNnr2GPcFjEw3HCap9iaDt)acOETpSUdbu4akIwGqav9ra9wZo(aA1au1EcOcbutb0X(HWhq3v2ZbOendQakr3zteQFKmcb0APWGdb0QbOeTA2xqnQdqH(1YXbODeqxqKdqniG2cNdFjWttOrDq5WJIA2nDlYB71(W6oK0ZMizF75ycdQSMZMiu)izK0AGmevsJgzV2hw3HsF75ycdQSMZMiu)izK8oK61ClKShsuuZHNkBoBISbtf(s8SUd52kDNUjkernhEQS5SjYgmv4lXZ6oKd4PhbOEmW4iaOeDNnrO(rYiGAnfFaLOvZ(cQrDaAab0Yl(aQWoavylicOgGcdcx0cHDkGAZADkGwnaLZMgbeq1cq7iG6kOcOCleq1cqvFeqlV4p(dnocaA1aupocxOiGQ(McOLqSEiGo2hpav9ra1JJWfkcOTVMakj16b0HpM2tcGs0QzFb1OoavTNaQakC4rJdkb0n9diG61(W6oeqdiGUGihGQfGchqr0ibqvFeqTzTofqRgGQXeb04auikQJdcOQVPa6CbvaDWGqa1Ak(akrRM9fuJ6auKydXJqaTJT6raLO7Sjc1psgHa64W5a0ocOliYbOx9tZ5irc80eAuhuo8OOMDt3I82ETpSUdj9SjsMdDgjSMZMiu)izKuoSzlNsE3PN0AG8JqubE6raQhGq9bup2JJZfhbsbuIwn7lOg1LUaburvoUA8bOJdNdq7iG(i3sGCaANea1a03oUAcO2SwNskG2xkGQ(iGERzhFaTAaQ4dfcOq1EfcOEXNea1pi4dOwtXhqnHgEnnocakrRM9fuJ6au74auORgdbuUA8bOAn2EoiGQ(iGIhhGwnaLOvZ(cQrDPlqavuLJRgFsa1dGpEa60soocakhkcyuheqJdqvFeq9a6XIOgPakrRM9fuJ6sxGa6JtlU4iaOIQCC14dqdiG(i3sGCaANeav9diG2EtOrDaQwaQje16uaTvpG6XECCU4iibEAcnQdkhEuuZUPBrEBV2hw3HKE2ejNCCCU4iWEKBj0Oos5WMTCk5DK7M0AG8JqubEAcnQdkhEuuZUPBrEB4zdq)szq1uiWttOrDq5WJIA2nDlYBVGiluCs6ztKSr8qF7niRvNYQgBOgJpWttOrDq5WJIA2nDlYBpJ)RNftJac80eAuhuo8OOMDt3I82dLg1b80eAuhuo8OOMDt3I82dK8v3zqf4jWtpcq9yJyOyPihGIEXNeavJjcOQpcOMqRhqdiGAETWzDhkbEAcnQdswuRtXhoGohWttOrDWTiVTx7dR7qspBIK1yImTyIA2xqnQJ0AGmevs9AUfswnhEQSfpcv7v8L4zDhYruAXJq1EfF5Jtlo4wPkQYXvJpPOM9fuJ6KpoT4GeLutI48AFyDhktoooxCeypYTeAuhrrnhEQm544CXrqIN1DixkeNj0Oo5VoKvn2qngFjsmuSuKPXejkQ5WtL)6qw1yd1y8L4zDhYLcrHiIQCC14tkQzFb1Oo5JghjeL(Q1KIA2xqnQtYvJpGNMqJ6GBrEBV2hw3HKE2ejRXezAXe1SVGAuhP1a5Prms9AUfswuLJRgFYjoRNew1yULi4yCpAtO8XPfhK0OrgHq8eOCIZ6jHvnMBjcog3J2ekNMhy9j6RwtoXz9KWQgZTebhJ7rBcLC14lHOkhxn(KtCwpjSQXClrWX4E0Mq5JtloiX51(W6ouQXezAXe1SVGAu3(K9AFyDhk9lhhtuZ(cQrDm1)rOF54aEAcnQdUf5T9AFyDhs6ztKSgtKPftuZ(cQrDKwdKNgXi1R5wizrvoUA8jhxVJZlgh7ryD2jq5JtloiPrJmcH4jq546DCEX4ypcRZobkNMhy9j6RwtoUEhNxmo2JW6StGsUA8LquLJRgFYX1748IXXEewNDcu(40IdsCETpSUdLAmrMwmrn7lOg1TpzV2hw3Hs)YXXe1SVGAuht9Fe6xooGNMqJ6GBrEBH5CmtOrDmxavspBIKdfNqMFqWNn8r9HscWttOrDWTiV9m(VEwmnciPrJCF1Asrn7lOg1j5QXhWttOrDWTiVnHL9CHDSQXmIh)s9jnAKt1R9H1DOuJjY0IjQzFb1OU9tANrJ0yImTyCbUVx7dR7qPgtKPftuZ(cQrDPa80eAuhClYBlQtGN(MICSMZMiWttOrDWTiV9J2qCeynNnriWttOrDWTiVDReliYXmIh)qrwhTjWttOrDWTiV9W6JgjXrG1DgubEAcnQdUf5T)yyWHS4yWbtGapnHg1b3I82QpYwxVwhhRvVabEAcnQdUf5T)1HSQXgQX4tA0i3xTMuuZ(cQrDsUA8LivV2hw3HsnMitlMOM9fuJ62RTCo2JcF7jGmnM4OrETpSUdLAmrMwmrn7lOg1TNgtKPfJlWuaEAcnQdUf5TfMZXmHg1XCbuj9SjswuZ(cQrDSbFdIKgnYETpSUdLAmrMwmrn7lOg1Tp5DaEAcnQdUf5TBXJSUZGkPliYQwJrqWrojsxqKn2pCityqnocKtI0OrovecXtGYjoRNew1yULi4yCpAtOCAEG1pAecH4jq5eN1tcRAm3seCmUhTjuoJR(egXJFOOS7mOIpBAqfFjEw3HCPKq4BpbesEAeJj8TNactqK(Q1K(LYG6JwYYhnHMGiP2xTM0hnnocS1G8rtOjsTVAnPOM9fuJ6KRHePAcnQt2Ih7MZjJJ1CbbFD0itOrDYbs(Q7mOkJJ1CbbFD0itOrDsOOEHVejgkwACesz0i1EcOk9rZP(YbHUpzpCNeMqJ6Kqr9cFjsmuS04iKskjisQePVAnPpAACeyRb5JMqtqK(Q1K(LYG6JwYYhnHMOVAnPOM9fuJ6KC14lrQMqJ6KT4XU5CY4ynxqWxhnYeAuNCGKV6odQY4ynxqWxtjfGNMqJ6GBrEBV2hw3HKE2ej3IhzDNbv2qvU4iqQxZTqYQ5WtL)6qw1yd1y8L4zDhYLquLJRgFYFDiRASHAm(YhNwCW9fv54QXNSfpY6odQY2Y5ypk8TNaY0yIjs1R9H1DOuJjY0IjQzFb1OU9mHg1j)1HSQXgQX4lBlNJ9OW3EcitJjMsIufv54QXN8xhYQgBOgJV8XPfhCFnMitlgxGJgzcnQt(RdzvJnuJXxk8TNac3BNugnYR9H1DOuJjY0IjQzFb1OU9nHg1jBXJSUZGQSTCo2JcF7jGmnMycV2hw3HsnMitlMOM9fuJ62xJjY0IXfiWttOrDWTiVTWCoMj0OoMlGkPNnrYFnWg8nisA0i3xTM8xhYQgBOgJVCnKivV2hw3HsnMitlMOM9fuJ62BNuaEAcnQdUf5T9AFyDhs6ztK8GFHxqm2qvU4iqQxZTqYQ5WtL)6qw1yd1y8L4zDhYLquLJRgFYFDiRASHAm(YhNwCW9fv54QXNCWVWligR5SjcLTLZXEu4BpbKPXetKQx7dR7qPgtKPftuZ(cQrD7zcnQt(RdzvJnuJXx2woh7rHV9eqMgtmLePkQYXvJp5VoKvn2qngF5Jtlo4(AmrMwmUahnYeAuN8xhYQgBOgJVu4BpbeU3oPmAKx7dR7qPgtKPftuZ(cQrD7BcnQto4x4feJ1C2eHY2Y5ypk8TNaY0yIj8AFyDhk1yImTyIA2xqnQBFnMitlgxGap9ia1dGpEa6UYEoHb14iaOeDNnraLx)izKuaLOhpcOB4mOcbuOFTCCaAhb0fe5auTauc4HVPiGURkfq51hTKHaQDCaQwaksmfpoaDdNbv8b0DHbv8LapnHg1b3I82T4rw3zqL0fezvRXii4iNePliYg7hoKjmOghbYjrA0iNkr8AFyDhkBXJSUZGkBOkxCegnQVAn5VoKvn2qngF5AiLeP61(W6ouQXezAXe1SVGAu3E7KsIunHgErgE4mq4EK9AFyDhk9TNJjmOYAoBIq9JKXePQXejU(Q1KIA2xqnQt6mOYqInepUNx7dR7qjh6msynNnrO(rYykPKGiT4rOAVIV0eA4ft0xTM0VuguF0swYvJVePseJ4Xpuu2DguXNnnOIVepR7qUrJ6Rwt2DguXNnnOIV8XPfhC)DKPpfGNEeGURT(4iaOe94rOAVIpPakrpEeq3WzqfcO2Ja6cICakmMHZEhjaQwak36JJaGs0QzFb1OojGURpE4BohjKcOQpscGApcOliYbOAbOeWdFtraDxvkGYRpAjdb0X(4bOIpuiGooCoa9kfq7iGo2GkYbO2XbOJd1hq3WzqfFaDxyqfFsbu1hjbqH(1YXbODeqHdpACaATuavlaDAXPwCaQ6Ja6godQ4dO7cdQ4dO9vRjbEAcnQdUf5TBXJSUZGkPliYQwJrqWrojsxqKn2pCityqnocKtI0OrUfpcv7v8LMqdVycHV9eq4EKtkrQeXR9H1DOSfpY6odQSHQCXry0O(Q1K)6qw1yd1y8LRHusKkrmIh)qrz3zqfF20Gk(s8SUd5gnQVAnz3zqfF20Gk(YhNwCW93rM(usKkrmHg1jBXJDZ5KiXqXsJJqcIycnQtoqYxDNbvzCSMli4Rj6Rwt6JMghb2AqUggnYeAuNSfp2nNtIedflnocj6Rwt6xkdQpAjl5QX3OrMqJ6KdK8v3zqvghR5cc(AI(Q1K(OPXrGTgKC14lrF1As)szq9rlzjxn(sb4Pj0Oo4wK3wyohZeAuhZfqL0ZMizOAhN9CSVutJ6inAK9AFyDhk1yImTyIA2xqnQBVDaEc80eAuhuAcn8Im1C4PqYUWBCey9A2jnAKnHgErgE4mq4EjLOVAnPOM9fuJ6KC14lrQETpSUdLAmrMwmrn7lOg1TNOkhxn(KUWBCey9A2LCR30OUrJ8AFyDhk1yImTyIA2xqnQBFY7KcWttOrDqPj0WlYuZHNc3I82tuX6jnAK9AFyDhk1yImTyIA2xqnQBFY7mAuQ9vRj)1HSQXgQX4lxdJgjQYXvJp5VoKvn2qngF5Jtlo4EAmrMwmUatycnQt(RdzvJnuJXxk8TNac3pPrJiIAo8u5VoKvn2qngFjEw3HCPKivrvoUA8jNOI1l5wVPrD771(W6ouQXezAXe1SVGAu3OrAmrMwmUa33R9H1DOuJjY0IjQzFb1OUuaEAcnQdknHgErMAo8u4wK3M7nc1bz9hn1N0OrwnhEQ0CiXG6BqI3GS26jrIN1DixIu7RwtkQzFb1Oojxn(sqK(Q1K(LYG6JwYYhnHoAuF1Asrn7lOg1jxdjmHg1jBXJSUZGQu4BpbeUVj0OozlEK1DguLtJymHV9eqycI0xTM0VuguF0sw(Oj0uaEc80JauIwn7lOg1bOd(geb0HhhShHaQ1dxObcb0XH6dOgGYHoJesbu1hpa1zRt4JqanoTau1hbuIwn7lOg1bOqmDw4jqGNMqJ6Gsrn7lOg1Xg8nis2fe8viZdCXryINsA0i3xTMuuZ(cQrDsUA8b80eAuhukQzFb1Oo2GVbXTiVD3iWQgt)qKmK0OrUVAnPOM9fuJ6KC14d4Pj0OoOuuZ(cQrDSbFdIBrEBx4nocSEn7KgnYMqdVidpCgiCVKs0xTMuuZ(cQrDsUA8b80eAuhukQzFb1Oo2GVbXTiVD3vfhRAm1hz4HtsaEAcnQdkf1SVGAuhBW3G4wK3EIZ6jHvnMBjcog3J2ec80eAuhukQzFb1Oo2GVbXTiV946DCEX4ypcRZobc80Ja0DT1hhbaLOvZ(cQrDKcOe94raDdNbviGApcOliYbOAbOeWdFtraDxvkGYRpAjdbu74a0zCXmiEeqvFeqTzTofqRgGQXebu4aEkGIedflnocaAP(4dOWb05GsaLOxpGcv74SNdqj6XJKcOe94raDdNbviGApcO15ibqxqKdqh7JhGURqtJJaG6XmaObeqnHgEraTEaDSpEaQbO8I6f(aQWGkGgqanoaD4lcpcHaQDCa6UcnnocaQhZaGAhhGURkfq51hTKbu7ra9kfqnHgErjG6biuFaDdNbv8b0DHbv8bu74auIUZMiGsu)rkGs0Jhb0nCguHaQWoa144cnQZCosa0ocOliYbOJ9dhcO7QsbuE9rlza1ooaDxHMghba1JzaqThb0Rua1eA4fbu74audq9yrYxDNbvanGaACaQ6JaQfpGAhhGAoybOJ9dhcOcdQXraq5f1l8bu0lEaA0a0DfAACeaupMbanGaQ5E04ibqnHgErjGUPpcOotv8buZ5QXqavhxa6UQuaLxF0sgq9yrYxDNbviGQfG2ravyqfqJdqHlHaHWOoa1Ak(aQ6JakVOEHVeq9aYXfAuN5CKaOJd1hq3WzqfFaDxyqfFa1ooaLO7SjcOe1FKcOe94raDdNbviGc9RLJdqVsb0ocOliYbORZHqiGUHZGk(a6UWGk(aAabuRxlfq1cqrInepcO1dOQp(iGApcOZ6rav9TdqXRwe8buIE8iGUHZGkeq1cqrIP4XbOB4mOIpGUlmOIpGQfGQ(iGIhhGwnaLOvZ(cQrDsGNMqJ6Gsrn7lOg1Xg8niUf5TBXJSUZGkPliYQwJrqWrojsxqKn2pCityqnocKtI0Orw4BpbeUh5KsKAQMqJ6KT4rw3zqvk8TNaczT3eAuN52k1(Q1KIA2xqnQt(40IdsC9vRj7odQ4ZMguXxYTEtJ6szxNOkhxn(KT4rw3zqvYTEtJ6iUu7RwtkQzFb1Oo5Jtloyk76sTVAnz3zqfF20Gk(sU1BAuhXTJm9PKYEK3z0iIyep(HIYUZGk(SPbv8L4zDhYnAeruZHNkBoBIS6K4zDhYnAuF1Asrn7lOg1jFCAXb3NCF1AYUZGk(SPbv8LCR30OUrJ6Rwt2DguXNnnOIV8XPfhC)DKPF0imDwXWaYj9jzaF1)rJJn(dOo(TbycrvoUA8j9jzaF1)rJJn(dOo(TbiZd3zNK8G7w(40IdUF6tjrF1Asrn7lOg1jxdjsLiMqJ6Kqr9cFjsmuS04iKGiMqJ6KdK8v3zqvghR5cc(AI(Q1K(OPXrGTgKRHrJmHg1jHI6f(sKyOyPXrirF1As)szq9rlzjxn(sKAF1AsF004iWwdsUA8nAKr84hkk7odQ4ZMguXxIN1DixkJgzep(HIYUZGk(SPbv8L4zDhYLqnhEQS5SjYQtIN1DixctOrDYbs(Q7mOkJJ1CbbFnrF1AsF004iWwdsUA8LOVAnPFPmO(OLSKRgFPa80eAuhukQzFb1Oo2GVbXTiV9VoKvn2qngFsJg5(Q1KIA2xqnQtYvJpGNEeG6beqj6XJa6godQak0VwooaTJa6cICaQwaQnm4ibq3WzqfFaDxyqfFaDSF4qavyqnoca6UERdb0QbOESQX4dOJ9XdqxW4iaOB4mOIpGUlmOIpPakr3zteqjQ)ifqTJdq3fOI1lbupUgGwNJeaDxGZ6jbqRgGsuBjcoaDx7rBcb0DrC1dObeqX0zfddihPaQ6hqa1fhcObeqdcx9ihG2rHTGiGgkGooCoafwtuJjcb0hHlNcOXbOeQ4iaOXPfGs0QzFb1OoaDCO(aAdhdOe94raDdNbvav4BpbekbEAcnQdkf1SVGAuhBW3G4wK3UfpY6odQKUGiBSF4qMWGACeiNePrJSr84hkk7odQ4ZMguXxIN1DixIuriepbkN4SEsyvJ5wIGJX9OnHYP5bw)OrebHq8eOCIZ6jHvnMBjcog3J2ekNXvFkjuZHNkNOI1lXZ6oKlHAo8uzZztKvNepR7qUe9vRj7odQ4ZMguXxYvJVePQMdpv(RdzvJnuJXxIN1DixctOrDYFDiRASHAm(sKyOyPXriHj0Oo5VoKvn2qngFjsmuSuK940IdU)osIQrJs1R9H1DOuJjY0IjQzFb1OU9jVZOr9vRjf1SVGAuNCnKscIOMdpv(RdzvJnuJXxIN1DixcIycnQtoqYxDNbvzCSMli4RjiIj0OozlESBoNmowZfe81uaEAcnQdkf1SVGAuhBW3G4wK3wyohZeAuhZfqL0ZMiztOHxKPMdpfc80eAuhukQzFb1Oo2GVbXTiVTOM9fuJ6iDbrw1AmccoYjr6cISX(HdzcdQXrGCsKgnYPIqiEcuoXz9KWQgZTebhJ7rBcLtZdS(rJ6Rwt6xkdQpAjlF0e6OrMqJ6Kqr9cFjsmuS04iKWeAuNekQx4lrIHILIShNwCW93rM(rJmHg1jhi5RUZGQejgkwACesycnQtoqYxDNbvjsmuSuK940IdU)oY0NsIu7Rwt(RdzvJnuJXxUggnIiQ5WtL)6qw1yd1y8L4zDhYLcWttOrDqPOM9fuJ6yd(ge3I82dLg1b80eAuhukQzFb1Oo2GVbXTiVD3vfhRTEsaEAcnQdkf1SVGAuhBW3G4wK3UJpe)KJJaWttOrDqPOM9fuJ6yd(ge3I82T4XURkoGNMqJ6Gsrn7lOg1Xg8niUf5TTtGq9nhtyohWttOrDqPOM9fuJ6yd(ge3I82nNnrO(rYiPrJCQPQMdpv2C2ezdMk8L4zDhYLWeA4fz4HZaH7T7ugnYeA4fz4HZaH7ruLsI(Q1K(LYG6JwYYhnHMGigXJFOOS7mOIpBAqfFjEw3HCapnHg1bLIA2xqnQJn4BqClYBpqYxDNbvsJg5(Q1KdK8LWzWP8rtOj6RwtkQzFb1Oo5Jtlo4EcdQmnMiWttOrDqPOM9fuJ6yd(ge3I82dK8v3zqL0OrUVAnPFPmO(OLS8rtOap9iaLOvZjEACeau1pGakE6tcGwlLOoan00fiG(OJK4iaO1bOgG(Oj0OoavJjcOCOZibqh7JhGssTa0KVAmGssTEaLxuVWhqhhohGk(qbu74ausQfG6BCa6UcnnocaQhZaGo2hpaLKAbOcdQakVOEHVe4PhbOEChXrWMiPaQ6hqanGaQVDCoKdqN1Ja6z66nNJejWtpcqnHg1bLIA2xqnQJn4BqClYBpqYxDNbvsJg5Hh9Yii4KjjHI6f(j6Rwt6JMghb2AqUgaEAcnQdkf1SVGAuhBW3G4wK3EWVWligR5SjcbEAcnQdkf1SVGAuhBW3G4wK3gkQx4tA0i3xTMuuZ(cQrDYhNwCW9eguzAmXe9vRjf1SVGAuNCnmAuF1Asrn7lOg1j5QXxcrvoUA8jf1SVGAuN8XPfhCFHbvMgte4Pj0OoOuuZ(cQrDSbFdIBrEBx4nocSEn7KgnY9vRjf1SVGAuN8XPfhCFcco50iwctOHxKHhodeUxsapnHg1bLIA2xqnQJn4BqClYBZ9gH6GS(JM6tA0i3xTMuuZ(cQrDYhNwCW9ji4KtJyj6RwtkQzFb1Oo5Aa4Pj0OoOuuZ(cQrDSbFdIBrEBOOEHpPrJSApbuL(O5uF5Gq3NShUtc1C4PsiAFCeyATe(s8SUd5aEc80eAuhugkoHmrn7lOg1rEbrwO4K0ZMi5GWfAuhBAeqiRTGiWttOrDqzO4eYe1SVGAu3wK3EbrwO4K0ZMizFsgWx9F04yJ)aQJFBasA0i3xTMuuZ(cQrDY1qctOrDYw8iR7mOkf(2taHK3jHj0OozlEK1DguLpk8TNaY0yI7rqWjNgXaEAcnQdkdfNqMOM9fuJ62I82liYcfNKE2ejpTlAiulw1ytJ7qie4Pj0OoOmuCczIA2xqnQBlYBlStGowF1AKUGiRAngbbh5Ki9SjsEAx0qOwSQXMg3Hqit4Bdk(S6qsJg5(Q1KIA2xqnQtUggnYeAuNCIkwVmowZfe81eMqJ6KtuX6LXXAUGGVYECAXb3N8oY0d80eAuhugkoHmrn7lOg1Tf5TxqKfkojDbrw1AmccoYjr6ztKSr8Rhv)cYGXra5ydU10iGKgnY9vRjf1SVGAuNCnmAKj0Oo5evSEzCSMli4RjmHg1jNOI1lJJ1CbbFL940IdUp5DKPh4Pj0OoOmuCczIA2xqnQBlYBVGiluCs6cISQ1yeeCKtIuS1qHYoBIKj4mUW06HSUXrajnAK7RwtkQzFb1Oo5Ay0itOrDYjQy9Y4ynxqWxtycnQtorfRxghR5cc(k7XPfhCFY7itpWttOrDqzO4eYe1SVGAu3wK3EbrwO4K0fezvRXii4iNePyRHcLD2ejtWzCHP1dztKZCUOosJg5(Q1KIA2xqnQtUggnYeAuNCIkwVmowZfe81eMqJ6KtuX6LXXAUGGVYECAXb3N8oY0d80eAuhugkoHmrn7lOg1Tf5TxqKfkojDbrw1AmccoYjr6ztKC3CylEK1F7e(KgnY9vRjf1SVGAuNCnmAKj0Oo5evSEzCSMli4RjmHg1jNOI1lJJ1CbbFL940IdUp5DKPh4Pj0OoOmuCczIA2xqnQBlYBVGiluCs6cISQ1yeeCKtI0ZMizOFjsUhk(qwZocKgnY9vRjf1SVGAuNCnmAKj0Oo5evSEzCSMli4RjmHg1jNOI1lJJ1CbbFL940IdUp5DKPh4Pj0OoOmuCczIA2xqnQBlYBVGiluCs6cISQ1yeeCKtI0ZMizL4TdHSU9jdhIdHKgnY9vRjf1SVGAuNCnmAKj0Oo5evSEzCSMli4RjmHg1jNOI1lJJ1CbbFL940IdUp5DKPh4Pj0OoOmuCczIA2xqnQBlYBVGiluCs6cISQ1yeeCKtI0ZMiz7ebEkl5Ruw1yJdixnjnAK7RwtkQzFb1Oo5Ay0itOrDYjQy9Y4ynxqWxtycnQtorfRxghR5cc(k7XPfhCFY7itpWttOrDqzO4eYe1SVGAu3wK3EbrwO4K0fezvRXii4iNePNnrYhUEZXGKC2aez45BNaFsJg5(Q1KIA2xqnQtUggnYeAuNCIkwVmowZfe81eMqJ6KtuX6LXXAUGGVYECAXb3N8oY0d80eAuhugkoHmrn7lOg1Tf5TxqKfkojDbrw1AmccoYjr6ztK80CT6NihZhFZXbzoKW43gGKgnY9vRjf1SVGAuNCnmAKj0Oo5evSEzCSMli4RjmHg1jNOI1lJJ1CbbFL940IdUp5DKPh4jWttOrDqzO4eY8dc(SHpQpusilmNJzcnQJ5cOs6ztKCO4eYe1SVGAuhPrJSx7dR7qPgtKPftuZ(cQrD7tEhGNMqJ6GYqXjK5he8zdFuFOKSf5TxqKfkoHapnHg1bLHItiZpi4Zg(O(qjzlYBVGiluCs6ztK80UOHqTyvJnnUdHqsJgzIGPZkggqoPr8qF7niRvNYQgBOgJFcV2hw3HsnMitlMOM9fuJ62Fxc80eAuhugkoHm)GGpB4J6dLKTiV9cISqXjPNnrYgXd9T3GSwDkRASHAm(KgnYETpSUdLAmrMwmrn7lOg1Tp50VvsPNO41(W6ou2QtzC1Q7qwDSfebEAcnQdkdfNqMFqWNn8r9HsYwK3EbrwO4K0ZMi5VuXVGkYX8wfxvmUY5inAK9AFyDhk1yImTyIA2xqnQBpV2hw3HY6yliYelTAnGNMqJ6GYqXjK5he8zdFuFOKSf5TxqKfkoj9Sjs2sNvmukEk7SLgUfK0Or2R9H1DOuJjY0IjQzFb1OU98AFyDhkRJTGitS0Q1aEAcnQdkdfNqMFqWNn8r9HsYwK3EbrwO4K0ZMizOF4fFMx8Qj7rxiinAK9AFyDhk1yImTyIA2xqnQBpV2hw3HY6yliYelTAnGNMqJ6GYqXjK5he8zdFuFOKSf5TxqKfkoj9SjsUvFp44WJvDyWf2XeoBmPrJSx7dR7qPgtKPftuZ(cQrD751(W6ouwhBbrMyPvRb80eAuhugkoHm)GGpB4J6dLKTiV9cISqXjPyRHcLD2ej7B)SUqW4WPP4hMliE8bEAcnQdkdfNqMFqWNn8r9HsYwK3EbrwO4K0ZMi5P5A1proMp(MJdYCiHXVnajnAK9AFyDhk1yImTyIA2xqnQBpYPp9j6RwtkQzFb1Oojxn(s41(W6ouQXezAXe1SVGAu3EETpSUdL1XwqKjwA1AapnHg1bLHItiZpi4Zg(O(qjzlYBVGiluCs6ztKSDIapLL8vkRASXbKRMKgnYETpSUdLAmrMwmrn7lOg1Th50N(e9vRjf1SVGAuNKRgFj8AFyDhk1yImTyIA2xqnQBpV2hw3HY6yliYelTAnGNMqJ6GYqXjK5he8zdFuFOKSf5TxqKfkoj9Sjs(W1BogKKZgGidpF7e4tA0i71(W6ouQXezAXe1SVGAu3EK9GPprF1Asrn7lOg1j5QXxcV2hw3HsnMitlMOM9fuJ62ZR9H1DOSo2cImXsRwd4jWttOrDqzO4eYC1y2Wh1hkjKxqKfkoj9SjswdoeQ1pzIIdjgPrJSx7dR7qPgtKPftuZ(cQrD751(W6ouwhBbrMyPvRb80eAuhugkoHmxnMn8r9HsYwK3EbrwO4KuS1qHYoBIKfKiCL(1fcw3zqL0Or2R9H1DOuJjY0IjQzFb1OU98AFyDhkRJTGitS0Q1aEc80eAuhu(1aBW3Gi5FDiRASHAm(apnHg1bLFnWg8niUf5TBoBIq9JKrsJg5unHgErgE4mq4EK9AFyDhk9lLb1hTKznNnrO(rYyIu1yIexF1Asrn7lOg1jDguziXgIh3ZR9H1DOKdDgjSMZMiu)izmLus0xTM0VuguF0sw(OjuGNMqJ6GYVgyd(ge3I82dK8v3zqL0OrUVAnPFPmO(OLS8rtOapnHg1bLFnWg8niUf5TBXJSUZGkPliYQwJrqWrojsxqKn2pCityqnocKtI0OrMiPAcn8Im8WzGW9i71(W6ou6BphtyqL1C2eH6hjJjsvJjsC9vRjf1SVGAuN0zqLHeBiECpV2hw3Hso0zKWAoBIq9JKXusjbrAXJq1EfFPj0WlMivI0xTM0hnnocS1G8rtOjisF1As)szq9rlz5JMqtqKHh9YQwJrqWjBXJSUZGAIunHg1jBXJSUZGQu4BpbeUh5DpAuQMqJ6Kd(fEbXynNnrOu4BpbeUh5KsOMdpvo4x4feJ1C2eHs8SUd5sz0OuvZHNknhsmO(gK4niRTEsK4zDhYLquLJRgFsU3iuhK1F0uF5JghjPmAuQQ5WtLq0(4iW0Aj8L4zDhYLqTNaQsF0CQVCqO7t2d3jLusb4Pj0OoO8Rb2GVbXTiVTWCoMj0OoMlGkPNnrYMqdVitnhEke4Pj0OoO8Rb2GVbXTiV9ajF1DgujnAK7RwtoqYxcNbNYhnHMqyqLPXe3VVAn5ajFjCgCkFCAXbt0xTM8xhYQgBOgJV8XPfhCpHbvMgte4Pj0OoO8Rb2GVbXTiVDlEK1DgujDbrw1AmccoYjr6cISX(HdzcdQXrGCsKgnYejvtOHxKHhodeUhzV2hw3HsF75ycdQSMZMiu)izmrQAmrIRVAnPOM9fuJ6KodQmKydXJ751(W6ouYHoJewZzteQFKmMskjislEeQ2R4lnHgEXeP2xTM0hnnocS1G8rtOjsvTNaQsF0CQVCqO7r2d3z0iIOMdpvcr7JJatRLWxIN1DixkPa80eAuhu(1aBW3G4wK3UfpY6odQKUGiRAngbbh5KiDbr2y)WHmHb14iqojsJgzIKQj0WlYWdNbc3JSx7dR7qPV9CmHbvwZzteQFKmMivnMiX1xTMuuZ(cQrDsNbvgsSH4X98AFyDhk5qNrcR5Sjc1psgtjLeePfpcv7v8LMqdVyc1C4PsiAFCeyATe(s8SUd5sO2tavPpAo1xoi09j7H7Ki1(Q1K(OPXrGTgKpAcnbrmHg1jHI6f(sKyOyPXry0iI0xTM0hnnocS1G8rtOjisF1As)szq9rlz5JMqtb4PhbOeTAoXtJJaGQ(beqXtFsa0APe1bOHMUab0hDKehbaToa1a0hnHg1bOAmraLdDgja6yF8ausQfGM8vJbusQ1dO8I6f(a64W5auXhkGAhhGssTauFJdq3vOPXraq9yga0X(4bOKulavyqfq5f1l8Lap9ia1J7ioc2ejfqv)acObeq9TJZHCa6SEeqptxV5CKibE6raQj0OoO8Rb2GVbXTiV9ajF1DgujnAKhE0lJGGtMKekQx4NOVAnPpAACeyRb5AiHAo8ujeTpocmTwcFjEw3HCju7jGQ0hnN6lhe6(K9WDsqKunHgErgE4mq4EK9AFyDhk9lLb1hTKznNnrO(rYyIu1yIexF1Asrn7lOg1jDguziXgIh3ZR9H1DOKdDgjSMZMiu)izmLuaEAcnQdk)AGn4BqClYBp4x4feJ1C2eHKgnYez4rVmccozsYb)cVGySMZMimrF1AsF004iWwdYhnHc80eAuhu(1aBW3G4wK3gkQx4tA0iR2tavPpAo1xoi09j7H7KqnhEQeI2hhbMwlHVepR7qoGNMqJ6GYVgyd(ge3I82CVrOoiR)OP(KgnYMqdVidpCgiCVDd80eAuhu(1aBW3G4wK3U5Sjc1psgjnAKt1eA4fz4HZaH7r2R9H1DO03EoMWGkR5Sjc1psgtKQgtK46RwtkQzFb1OoPZGkdj2q84EETpSUdLCOZiH1C2eH6hjJPKcWttOrDq5xdSbFdIBrE7w8y3CoGNapnHg1bLq1oo75yFPMg1rU5Sjc1psgjnAKt1eA4fz4HZaH7r2R9H1DO0VuguF0sM1C2eH6hjJjsvJjsC9vRjf1SVGAuN0zqLHeBiECpV2hw3Hso0zKWAoBIq9JKXusjrF1As)szq9rlz5JMqbEAcnQdkHQDC2ZX(snnQBlYBpqYxDNbvsJg5(Q1K(LYG6JwYYhnHMOVAnPFPmO(OLS8XPfhCFtOrDYw8y3CojsmuSuKPXebEAcnQdkHQDC2ZX(snnQBlYBpqYxDNbvsJg5(Q1K(LYG6JwYYhnHMi1Hh9Yii4KjjBXJDZ5gnQfpcv7v8LMqdV4OrMqJ6KdK8v3zqvghR5cc(AkapnHg1bLq1oo75yFPMg1Tf5Th8l8cIXAoBIqsJgzHV9eq4EK9WeMqdVidpCgiCVDNGiETpSUdLd(fEbXydv5IJaWttOrDqjuTJZEo2xQPrDBrE7bs(Q7mOsA0i3xTM0VuguF0sw(Oj0eQ9eqv6JMt9LdcDFYE4ojuZHNkHO9XrGP1s4lXZ6oKd4Pj0OoOeQ2Xzph7l10OUTiV9ajF1DgujnAK7RwtoqYxcNbNYhnHMqyqLPXe3VVAn5ajFjCgCkFCAXbbEAcnQdkHQDC2ZX(snnQBlYB3IhzDNbvsxqKvTgJGGJCsKUGiBSF4qMWGACeiNePrJCQ9vRj)1HSQXgQX4l5QXxcI0IhHQ9k(stOHxmLeeXR9H1DOSfpY6odQSHQCXrirQPMQj0OozlESBoNejgkwACegnYeAuNCGKV6odQsKyOyPXriLe9vRj9rtJJaBniF0eAkJgLQAo8ujeTpocmTwcFjEw3HCju7jGQ0hnN6lhe6(K9WDsKAF1AsF004iWwdYhnHMGiMqJ6Kqr9cFjsmuS04imAer6Rwt6xkdQpAjlF0eAcI0xTM0hnnocS1G8rtOjmHg1jHI6f(sKyOyPXribrmHg1jhi5RUZGQmowZfe81eeXeAuNSfp2nNtghR5cc(AkPKcWtpcqjA1CINghbav9diGIN(KaO1sjQdqdnDbcOp6ijocaADaQbOpAcnQdq1yIakh6msa0X(4bOKulan5RgdOKuRhq5f1l8b0XHZbOIpua1ooaLKAbO(ghGURqtJJaG6XmaOJ9XdqjPwaQWGkGYlQx4lbE6raQh3rCeSjskGQ(beqdiG6BhNd5a0z9iGEMUEZ5irc80JautOrDqjuTJZEo2xQPrDBrE7bs(Q7mOsA0ip8OxgbbNmjjuuVWprF1AsF004iWwdY1qc1C4PsiAFCeyATe(s8SUd5sO2tavPpAo1xoi09j7H7KGiPAcn8Im8WzGW9i71(W6ou6xkdQpAjZAoBIq9JKXePQXejU(Q1KIA2xqnQt6mOYqInepUNx7dR7qjh6msynNnrO(rYykPa80eAuhucv74SNJ9LAAu3wK3EWVWligR5SjcjnAKtTVAnPpAACeyRb5JMqhnkvI0xTM0VuguF0sw(Oj0ePAcnQt2IhzDNbvPW3EciCVDgnsnhEQeI2hhbMwlHVepR7qUeQ9eqv6JMt9LdcDFYE4oPKskjiIx7dR7q5GFHxqm2qvU4ia80eAuhucv74SNJ9LAAu3wK3wyohZeAuhZfqL0ZMiztOHxKPMdpfc80eAuhucv74SNJ9LAAu3wK3M7nc1bz9hn1N0Or2eA4fz4HZaH7LeWttOrDqjuTJZEo2xQPrDBrEBH5CmtOrDmxavspBIKdfNqMRgZg(O(qjb4Pj0OoOeQ2Xzph7l10OUTiVnuuVWN0OrwTNaQsF0CQVCqO7t2d3jHAo8ujeTpocmTwcFjEw3HCap9ia1dqO(akE1IGpGQ2taviPaAOaAabudqjyXbOAbOcdQakr3zteQFKmcOgeqBHZHpGghurJdqRgGs0Jh7MZjbEAcnQdkHQDC2ZX(snnQBlYB3C2eH6hjJKgnYMqdVidpCgiCpYETpSUdL(2ZXeguznNnrO(rYyIu1yIexF1Asrn7lOg1jDguziXgIh3ZR9H1DOKdDgjSMZMiu)izmfGNMqJ6GsOAhN9CSVutJ62I82T4XU5CapnHg1bLq1oo75yFPMg1Tf5THI6f(zE4akYPru5HznR5ma]] )


end
