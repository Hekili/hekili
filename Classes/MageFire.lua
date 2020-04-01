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
    
    spec:RegisterPack( "Fire", 20200401.1, [[d8eYNcqieIhPqHlPuLs2evLpPuLkJsK0PejwLsvYRukzwOsUfvb2fr)sPudtPIJrvLLPufpJQGMgcLCnfkTnek4BufIghcf15OkKwNcfX7uOiH5Puv3dvSpLkDqeksluKQhIqPMOsvkUOcfjTreQYhvOirJeHcDsekIvsv0lvOivZuPkvDtfkQDks5NkvPudfHQslvHIuEkQAQkuDvQcHVIqvXEf1FrzWiDyklwspMWKr0LH2SeFgbJweNwy1iuv9AQQA2u52kA3Q8BPgUcoovHA5Q65GMoPRRKTtv67kfJhH05rLA9iuz(kK9dC2V84zEstXCA7zN9SZoeRD8t6hXASEKEOFzEL7bmZpyc)ncyM)SjM5jEXJz(bJBxBK5XZ8WE9cmZNO6aCmz7TjeAYQkf9CBymxotJ(eVv0THXuSDMVUcNsm5Y1mpPPyoT9SZE2zhI1o(j9JynwpCN9K5TLM0FMNpMe7mFsqsIxUM5jrOiZpgakXlEeqhZgbe45yaOjQoaht2EBcHMSQsrp3ggZLZ0OpXBfDBymfBd8CmauIPdF4au)4cq3Zo7zha1dau)iwJjJ1pGNaphdaLyNyhbeoMa8Cmaupaq9iGiGQXezAZideqFttWhq1e7au1EcOk1yImTzKbcOL(buNbvpaII(ibuRgUq5gqxqJacLaphda1daupIbstra11ecbG(4ycGU3VebjGU38OnHsGNJbG6ba6EF3q8auHbva9rpEfpoXtHaAPFaLy3Z6cQrFaAQHeLCbOK9T3PaAs7ib0qb0s)aQbOLhHja6ygvSFavyqnfjWZXaq9aaDVjGw1HaQDakE6ZnGQjMcOB6LJeqFeUCkGghGAaAI9KcdQakXxU)U6mOcOX5beSjkZ8UaQW84z(qXjK56nSHp6puUZJNtZV84zE8SQdjZPN5pBIzEnirO2)KjAsKOzEtOrFzEnirO2)KjAsKOzEXhk(HL59AFyvhk1yImTzIEwxqn6dq3fq9AFyvhk7JTGitS0UuYAoT9KhpZJNvDizo9mV4df)WY8ETpSQdLAmrM2mrpRlOg9bO7cOETpSQdL9XwqKjwAxkzEtOrFzEb3cxRFFHGvDguZ8yPGcLD2eZ8cUfUw)(cbR6mOM1SM5f9SUGA0hBiXGyE8CA(LhpZJNvDizo9mV4df)WY81vPif9SUGA0NKS3CzEtOrFzExqirHmI)fjHjEAwZPTN84zE8SQdjZPN5fFO4hwMVUkfPON1fuJ(KK9MlZBcn6lZxncSUW0pe(dZAonpmpEMhpR6qYC6zEXhk(HL5nHgErgE4mqiGUlG6hG6dqRRsrk6zDb1OpjzV5Y8MqJ(Y8UWBCey1EwZAonIvE8mVj0OVmF11njRlmnbz4HtUZ84zvhsMtpR50gBE8mVj0OVm)eN9ZnRlm3seKmYhTjmZJNvDizo9SMtJyipEM3eA0xMFt)osVyCShH9zNaZ84zvhsMtpR508iZJN5XZQoKmNEMFbr2MKWHmHb14iKtZVmV4df)WY8Ie7jGqaDxoaQFaQpanvanva1eA0NSepYQodQsrI9eqiR8MqJ(mhGUfGMkGwxLIu0Z6cQrFYhNwCqa1da06QuKvNbv8ztdQ4ljxVPrFaAka6Elav0TJS3CYs8iR6mOkjxVPrFaQhaOPcO1vPif9SUGA0N8XPfheqtbq3BbOPcO1vPiRodQ4ZMguXxsUEtJ(aupaq3rowanfanfaDxoa6oa6OrakrauJ4WpuuwDguXNnnOIVepR6qsaD0iaLiaQAo8uzXztK1NepR6qsaD0iaTUkfPON1fuJ(KpoT4Ga6(Ca06QuKvNbv8ztdQ4ljxVPrFa6OraADvkYQZGk(SPbv8LpoT4Ga6(a6oYXcOJgbOOhVIHbKuMW9a(AYJgjBZhqDZBdqa1hGk62r2Bozc3d4RjpAKSnFa1nVnazE4o74hXApYhNwCqaDFaDSaAkaQpaTUkfPON1fuJ(KRba1hGMkGsea1eA0Nek6xKirIIILghba1hGsea1eA0NCG7VRodQY4yfxqirbuFaADvkYe004iWwdY1aGoAeGAcn6tcf9lsKirrXsJJaG6dqRRsrM0kdQpA(lj7nhG6dqtfqRRsrMGMghb2Aqs2BoaD0ia1io8dfLvNbv8ztdQ4lXZQoKeqtbqhncqnId)qrz1zqfF20Gk(s8SQdjbuFaQAo8uzXztK1NepR6qsa1hGAcn6toW93vNbvzCSIliKOaQpaTUkfzcAACeyRbjzV5auFaADvkYKwzq9rZFjzV5a0uY8liY6sHrqqMtZVmVj0OVmFjEKvDguZAonI584zE8SQdjZPN5fFO4hwMVUkfPON1fuJ(KK9MlZBcn6lZ)RdzDHn0BWpR508O5XZ84zvhsMtpZVGiBts4qMWGACeYP5xM3eA0xMVepYQodQzEXhk(HL5nId)qrz1zqfF20Gk(s8SQdjbuFaAQakcH4jq5eN9ZnRlm3seKmYhTjuonI)(b0rJauIaOieINaLtC2p3SUWClrqYiF0Mq5mU(b0uauFaQAo8u5evSFjEw1HKaQpavnhEQS4SjY6tINvDijG6dqRRsrwDguXNnnOIVKS3CaQpanvavnhEQ8xhY6cBO3GVepR6qsa1hGAcn6t(RdzDHn0BWxIefflnocaQpa1eA0N8xhY6cBO3GVejkkwkYECAXbb09b0DKeda6OraAQaQx7dR6qPgtKPnt0Z6cQrFa6(Ca0Da0rJa06QuKIEwxqn6tUga0uauFakrau1C4PYFDiRlSHEd(s8SQdjbuFakrautOrFYbU)U6mOkJJvCbHefq9bOebqnHg9jlXJvZ5KXXkUGqIcOPK1CA(TtE8mpEw1HK50Z8MqJ(Y8cZ5yMqJ(yUaQzExav2ztmZBcn8Im1C4PWSMtZp)YJN5XZQoKmNEMFbr2MKWHmHb14iKtZVmV4df)WY8PcOieINaLtC2p3SUWClrqYiF0Mq50i(7hqhncqRRsrM0kdQpA(lF0ekGoAeGAcn6tcf9lsKirrXsJJaG6dqnHg9jHI(fjsKOOyPi7XPfheq3hq3rowaD0ia1eA0NCG7VRodQsKOOyPXraq9bOMqJ(KdC)D1zqvIefflfzpoT4Ga6(a6oYXcOPaO(a0ub06QuK)6qwxyd9g8LRbaD0iaLiaQAo8u5VoK1f2qVbFjEw1HKaAkz(fezDPWiiiZP5xM3eA0xMx0Z6cQrFznNMF7jpEM3eA0xMFO1OVmpEw1HK50ZAon)8W84zEtOrFz(QRBswz9CN5XZQoKmNEwZP5hXkpEM3eA0xMVIpeF)JJqMhpR6qYC6znNMFJnpEM3eA0xMVepwDDtM5XZQoKmNEwZP5hXqE8mVj0OVmVDceQV5ycZ5Y84zvhsMtpR508ZJmpEMhpR6qYC6zEXhk(HL5tfqtfqvZHNkloBISbtfjs8SQdjbuFaQj0WlYWdNbcb0Db09aOPaOJgbOMqdVidpCgieq3fqjga0uauFaADvkYKwzq9rZF5JMqbuFakrauJ4WpuuwDguXNnnOIVepR6qYmVj0OVmFXzteQF4pM1CA(rmNhpZJNvDizo9mV4df)WY81vPih4(BHZGt5JMqbuFaADvksrpRlOg9jFCAXbb0DbuHbvMgtmZBcn6lZpW93vNb1SMtZppAE8mpEw1HK50Z8Ipu8dlZxxLImPvguF08x(Oj0mVj0OVm)a3FxDguZAoT9StE8mpEw1HK50Z8Ipu8dlZp8OxgbbP0pju0Vibq9bO1vPitqtJJaBnixdzEtOrFz(bU)U6mOM1CA7XV84zEtOrFz(HKgVGOSIZMimZJNvDizo9SMtBp7jpEMhpR6qYC6zEXhk(HL5RRsrk6zDb1Op5JtloiGUlGkmOY0yIaQpaTUkfPON1fuJ(KRbaD0iaTUkfPON1fuJ(KK9Mdq9bOIUDK9Mtk6zDb1Op5JtloiGUpGkmOY0yIzEtOrFzEOOFrswZPThpmpEMhpR6qYC6zEXhk(HL5RRsrk6zDb1Op5JtloiGUpGsqqkNgrbuFaQj0WlYWdNbcb0Dbu)Y8MqJ(Y8UWBCey1EwZAoT9qSYJN5XZQoKmNEMx8HIFyz(6QuKIEwxqn6t(40IdcO7dOeeKYPrua1hGwxLIu0Z6cQrFY1qM3eA0xMN8nc9bz1hnnjR502ZyZJN5XZQoKmNEMx8HIFyzE1EcOktqZPjYbHcO7Zbq9WDauFaQAo8ujeTpocmTxIejEw1HKzEtOrFzEOOFrswZAM3eA4fzQ5WtH5XZP5xE8mpEw1HK50Z8Ipu8dlZBcn8Im8WzGqaDxa1pa1hGwxLIu0Z6cQrFsYEZbO(a0ubuV2hw1HsnMitBMON1fuJ(a0Dbur3oYEZjDH34iWQ9SkjxVPrFa6OraQx7dR6qPgtKPnt0Z6cQrFa6(Ca0Da0uY8MqJ(Y8UWBCey1EwZAoT9KhpZJNvDizo9mV4df)WY8ETpSQdLAmrM2mrpRlOg9bO7Zbq3bqhncqtfqRRsr(RdzDHn0BWxUga0rJaur3oYEZj)1HSUWg6n4lFCAXbb0DbunMitBgzGaQpa1eA0N8xhY6cBO3GVuKypbecO7dO(bOJgbOebqvZHNk)1HSUWg6n4lXZQoKeqtbq9bOPcOIUDK9Mtorf7xsUEtJ(a09buV2hw1HsnMitBMON1fuJ(a0rJaunMitBgzGa6(aQx7dR6qPgtKPnt0Z6cQrFaAkzEtOrFz(jQy)znNMhMhpZJNvDizo9mV4df)WY8Q5WtLMdjkuFdsCgKvwp3s8SQdjbuFaAQaADvksrpRlOg9jj7nhG6dqjcGwxLImPvguF08x(OjuaD0iaTUkfPON1fuJ(KRba1hGAcn6twIhzvNbvPiXEcieq3hqnHg9jlXJSQZGQCAeLjsSNacbuFakra06QuKjTYG6JM)YhnHcOPK5nHg9L5jFJqFqw9rttYAwZ8HItiljiKWg(O)q5opEon)YJN5XZQoKmNEM3eA0xMxyohZeA0hZfqnZl(qXpSmVx7dR6qPgtKPnt0Z6cQrFa6(Ca0DY8UaQSZMyMpuCczIEwxqn6lR502tE8mVj0OVm)cISqXjmZJNvDizo9SMtZdZJN5XZQoKmNEM)SjM5N2ffeQnRlSPrEieM5nHg9L5N2ffeQnRlSPrEieM5fFO4hwMNiak6XRyyajLgXbtS3GSsFkRlSHEd(aQpa1R9HvDOuJjY0Mj6zDb1OpaDFaLyoR50iw5XZ84zvhsMtpZF2eZ8gXbtS3GSsFkRlSHEd(zEtOrFzEJ4Gj2BqwPpL1f2qVb)mV4df)WY8ETpSQdLAmrM2mrpRlOg9bO7ZbqhlGUfG63yb09cq9AFyvhkl9PmYEvDiRp2cIznN2yZJN5XZQoKmNEM)SjM5)wf)cQijZB3KDZiBNlZBcn6lZ)Tk(fursM3Uj7Mr2oxMx8HIFyzEV2hw1HsnMitBMON1fuJ(a0DbuV2hw1HY(yliYelTlLSMtJyipEMhpR6qYC6z(ZMyM384vm0kEk7SLgUfmZBcn6lZBE8kgAfpLD2sd3cM5fFO4hwM3R9HvDOuJjY0Mj6zDb1OpaDxa1R9HvDOSp2cImXs7sjR508iZJN5XZQoKmNEM)SjM5HjHx8zEXRNShDHiZBcn6lZdtcV4Z8Ixpzp6crMx8HIFyzEV2hw1HsnMitBMON1fuJ(a0DbuV2hw1HY(yliYelTlLSMtJyopEMhpR6qYC6z(ZMyMV0FnijXJ1vyqg2XeoBtM3eA0xMV0FnijXJ1vyqg2XeoBtMx8HIFyzEV2hw1HsnMitBMON1fuJ(a0DbuV2hw1HY(yliYelTlLSMtZJMhpZJNvDizo9mVj0OVmFI9Z(cbJeNMIFyUG4WpZJLcku2ztmZNy)SVqWiXPP4hMlio8ZAon)2jpEMhpR6qYC6z(ZMyMFAUs)tKKLGV5iHmhsyZBdWmVj0OVm)0CL(NijlbFZrczoKWM3gGzEXhk(HL59AFyvhk1yImTzIEwxqn6dq3LdGo2XcO(a06QuKIEwxqn6ts2Boa1hG61(WQouQXezAZe9SUGA0hGUlG61(WQou2hBbrMyPDPK1CA(5xE8mpEw1HK50Z8NnXmVDIapL5)1kRlSnbKSNzEtOrFzE7ebEkZ)RvwxyBcizpZ8Ipu8dlZ71(WQouQXezAZe9SUGA0hGUlhaDSJfq9bO1vPif9SUGA0NKS3CaQpa1R9HvDOuJjY0Mj6zDb1OpaDxa1R9HvDOSp2cImXs7sjR508Bp5XZ84zvhsMtpZF2eZ8hUEZXGCF2aez4LyNa)mVj0OVm)HR3Cmi3NnargEj2jWpZl(qXpSmVx7dR6qPgtKPnt0Z6cQrFa6UCauI1ybuFaADvksrpRlOg9jj7nhG6dq9AFyvhk1yImTzIEwxqn6dq3fq9AFyvhk7JTGitS0UuYAwZ8KyXwonpEon)YJN5nHg9L5f96u8HdOZL5XZQoKmNEwZPTN84zE8SQdjZPN57Hmpe1mVj0OVmVx7dR6WmVxZTWmVAo8uzjEeQ2R4lXZQoKeq3laTepcv7v8LpoT4Ga6waAQaQOBhzV5KIEwxqn6t(40IdcO7fGMkG6hG6baQx7dR6qP)Xr6IJa7rYLqJ(a09cqvZHNk9posxCeK4zvhscOPaOEaGAcn6t(RdzDHn0BWxIefflfzAmraDVau1C4PYFDiRlSHEd(s8SQdjb0ua09cqjcGk62r2BoPON1fuJ(KpAKCdO7fGwxLIu0Z6cQrFsYEZL59Ap7SjM51yImTzIEwxqn6lR508W84zE8SQdjZPN57Hm)0iAM3eA0xM3R9HvDyM3R5wyMx0TJS3CYjo7NBwxyULiizKpAtO8XPfhmZ71E2ztmZRXezAZe9SUGA0xMx8HIFyzEecXtGYjo7NBwxyULiizKpAtOCAe)9dO(a06QuKtC2p3SUWClrqYiF0MqjzV5auFaQOBhzV5KtC2p3SUWClrqYiF0Mq5JtloiG6baQx7dR6qPgtKPnt0Z6cQrFa6(CauV2hw1HYK2rYe9SUGA0httEeM0oYSMtJyLhpZJNvDizo9mFpK5NgrZ8MqJ(Y8ETpSQdZ8En3cZ8IUDK9MtUPFhPxmo2JW(StGYhNwCWmVx7zNnXmVgtKPnt0Z6cQrFzEXhk(HL5riepbk30VJ0lgh7ryF2jq50i(7hq9bO1vPi30VJ0lgh7ryF2jqjzV5auFaQOBhzV5KB63r6fJJ9iSp7eO8XPfheq9aa1R9HvDOuJjY0Mj6zDb1OpaDFoaQx7dR6qzs7izIEwxqn6JPjpctAhzwZPn284zE8SQdjZPN5nHg9L5fMZXmHg9XCbuZ8UaQSZMyMpuCczjbHe2Wh9hk3znNgXqE8mpEw1HK50Z8Ipu8dlZxxLIu0Z6cQrFsYEZL5nHg9L5NX)9ZIPraZAonpY84zE8SQdjZPN5fFO4hwMpva1R9HvDOuJjY0Mj6zDb1OpaDFa1VDa0rJaunMitBgzGa6(aQx7dR6qPgtKPnt0Z6cQrFaAkzEtOrFzEcl7jd7yDHzeh(TMK1CAeZ5XZ8MqJ(Y8I(e4PVPijR4SjM5XZQoKmNEwZP5rZJN5nHg9L5F0gIJaR4SjcZ84zvhsMtpR508BN84zEtOrFz(slwqKKzeh(HISkAZmpEw1HK50ZAon)8lpEM3eA0xMFy9rH74iWQodQzE8SQdjZPN1CA(TN84zEtOrFz(pggCilogCWeyMhpR6qYC6znNMFEyE8mVj0OVmVMGS1v71rYk9lWmpEw1HK50ZAon)iw5XZ84zvhsMtpZl(qXpSmFDvksrpRlOg9jj7nhG6dqtfq9AFyvhk1yImTzIEwxqn6dq3fqllNJ9OiXEcitJjcOJgbOETpSQdLAmrM2mrpRlOg9bO7cOAmrM2mYab0uY8MqJ(Y8)6qwxyd9g8ZAon)gBE8mpEw1HK50Z8MqJ(Y8cZ5yMqJ(yUaQzEXhk(HL59AFyvhk1yImTzIEwxqn6dq3NdGUtM3fqLD2eZ8IEwxqn6JnKyqmR508JyipEMhpR6qYC6z(fezBschYeguJJqon)Y8Ipu8dlZNkGIqiEcuoXz)CZ6cZTebjJ8rBcLtJ4VFaD0iafHq8eOCIZ(5M1fMBjcsg5J2ekNX1pG6dqnId)qrz1zqfF20Gk(s8SQdjb0uauFaQiXEcieq5aOtJOmrI9eqiG6dqjcGwxLImPvguF08x(Ojua1hGseanvaTUkfzcAACeyRb5JMqbuFaAQaADvksrpRlOg9jxdaQpanva1eA0NSepwnNtghR4ccjkGoAeGAcn6toW93vNbvzCSIliKOa6OraQj0Opju0VirIefflnocaAka6OraQApbuLjO50e5Gqb095aOE4oaQpa1eA0Nek6xKirIIILghbanfanfa1hGseanvaLiaADvkYe004iWwdYhnHcO(auIaO1vPitALb1hn)LpAcfq9bO1vPif9SUGA0NKS3CaQpanva1eA0NSepwnNtghR4ccjkGoAeGAcn6toW93vNbvzCSIliKOaAkaAkz(fezDPWiiiZP5xM3eA0xMVepYQodQznNMFEK5XZ84zvhsMtpZ3dzEiQzEtOrFzEV2hw1HzEVMBHzE1C4PYFDiRlSHEd(s8SQdjbuFaQOBhzV5K)6qwxyd9g8LpoT4Ga6(aQOBhzV5KL4rw1zqvwwoh7rrI9eqMgteq9bOPcOETpSQdLAmrM2mrpRlOg9bO7cOMqJ(K)6qwxyd9g8LLLZXEuKypbKPXeb0uauFaAQaQOBhzV5K)6qwxyd9g8LpoT4Ga6(aQgtKPnJmqaD0ia1eA0N8xhY6cBO3GVuKypbecO7cO7aOPaOJgbOETpSQdLAmrM2mrpRlOg9bO7dOMqJ(KL4rw1zqvwwoh7rrI9eqMgteq9bOETpSQdLAmrM2mrpRlOg9bO7dOAmrM2mYaZ8ETND2eZ8L4rw1zqLn0TlocznNMFeZ5XZ84zvhsMtpZBcn6lZlmNJzcn6J5cOM5fFO4hwMVUkf5VoK1f2qVbF5Aaq9bOPcOETpSQdLAmrM2mrpRlOg9bO7cO7aOPK5DbuzNnXm)3dSHedIznNMFE084zE8SQdjZPN57Hmpe1mVj0OVmVx7dR6WmVxZTWmVAo8u5VoK1f2qVbFjEw1HKaQpav0TJS3CYFDiRlSHEd(YhNwCqaDFav0TJS3CYHKgVGOSIZMiuwwoh7rrI9eqMgteq9bOPcOETpSQdLAmrM2mrpRlOg9bO7cOMqJ(K)6qwxyd9g8LLLZXEuKypbKPXeb0uauFaAQaQOBhzV5K)6qwxyd9g8LpoT4Ga6(aQgtKPnJmqaD0ia1eA0N8xhY6cBO3GVuKypbecO7cO7aOPaOJgbOETpSQdLAmrM2mrpRlOg9bO7dOMqJ(KdjnEbrzfNnrOSSCo2JIe7jGmnMiG6dq9AFyvhk1yImTzIEwxqn6dq3hq1yImTzKbM59Ap7SjM5hsA8cIYg62fhHSMtBp7KhpZJNvDizo9m)cISnjHdzcdQXriNMFzEXhk(HL5tfqjcG61(WQouwIhzvNbv2q3U4iaOJgbO1vPi)1HSUWg6n4lxdaAkaQpanva1R9HvDOuJjY0Mj6zDb1OpaDxaDhanfa1hGMkGAcn8Im8WzGqaDxoaQx7dR6qzI9KmHbvwXzteQF4pcO(a0ubunMiG6baADvksrpRlOg9jDguzirhIhb0DbuV2hw1Hss0zCZkoBIq9d)ranfanfa1hGseaTepcv7v8LMqdViG6dqRRsrM0kdQpA(lj7nhG6dqtfqjcGAeh(HIYQZGk(SPbv8L4zvhscOJgbO1vPiRodQ4ZMguXx(40IdcO7dO7ihlGMsMFbrwxkmccYCA(L5nHg9L5lXJSQZGAwZPTh)YJN5XZQoKmNEMFbr2MKWHmHb14iKtZVmV4df)WY8L4rOAVIV0eA4fbuFaQiXEcieq3LdG6hG6dqtfqjcG61(WQouwIhzvNbv2q3U4iaOJgbO1vPi)1HSUWg6n4lxdaAkaQpanvaLiaQrC4hkkRodQ4ZMguXxINvDijGoAeGwxLIS6mOIpBAqfF5JtloiGUpGUJCSaAkaQpanvaLiaQj0OpzjESAoNejkkwACeauFakrautOrFYbU)U6mOkJJvCbHefq9bO1vPitqtJJaBnixda6OraQj0OpzjESAoNejkkwACeauFaADvkYKwzq9rZFjzV5a0rJautOrFYbU)U6mOkJJvCbHefq9bO1vPitqtJJaBnij7nhG6dqRRsrM0kdQpA(lj7nhGMsMFbrwxkmccYCA(L5nHg9L5lXJSQZGAwZPTN9KhpZJNvDizo9mVj0OVmVWCoMj0OpMlGAMx8HIFyzEV2hw1HsnMitBMON1fuJ(a0Db0DY8UaQSZMyMhQ2rApj7B10OVSM1mFO4eYe9SUGA0xE8CA(LhpZJNvDizo9m)ztmZheUqJ(ytJaczLfeZ8MqJ(Y8bHl0Op20iGqwzbXSMtBp5XZ84zvhsMtpZF2eZ8jCpGVM8OrY28bu382amZBcn6lZNW9a(AYJgjBZhqDZBdWmV4df)WY81vPif9SUGA0NCnaO(autOrFYs8iR6mOkfj2taHakhaDha1hGAcn6twIhzvNbv5JIe7jGmnMiGUlGsqqkNgrZAonpmpEMhpR6qYC6z(ZMyMFAxuqO2SUWMg5HqyM3eA0xMFAxuqO2SUWMg5HqywZPrSYJN5RRsHD2eZ8t7Icc1M1f20ipeczIeBqXN1hM5fFO4hwMVUkfPON1fuJ(KRbaD0ia1eA0NCIk2VmowXfesua1hGAcn6torf7xghR4ccjk7XPfheq3NdGUJCSz(fezDPWiiiZP5xMhpR6qYC6zEtOrFzEHDc0XQRsjR50gBE8mpEw1HK50Z8NnXmVrCRh1KgYGXrajzdU10iGz(fezDPWiiiZP5xMx8HIFyz(6QuKIEwxqn6tUga0rJautOrFYjQy)Y4yfxqirbuFaQj0Op5evSFzCSIliKOShNwCqaDFoa6oYXM5nHg9L5nIB9OM0qgmocijBWTMgbmR50igYJN5XZQoKmNEM3eA0xMNGZidt7hYQgjbmZVGiRlfgbbzon)Y8Ipu8dlZxxLIu0Z6cQrFY1aGoAeGAcn6torf7xghR4ccjkG6dqnHg9jNOI9lJJvCbHeL940IdcO7Zbq3ro2mpwkOqzNnXmpbNrgM2pKvnscywZP5rMhpZJNvDizo9mVj0OVmpbNrgM2pKnrsZ5I(Y8liY6sHrqqMtZVmV4df)WY81vPif9SUGA0NCnaOJgbOMqJ(KtuX(LXXkUGqIcO(autOrFYjQy)Y4yfxqirzpoT4Ga6(Ca0DKJnZJLcku2ztmZtWzKHP9dztK0CUOVSMtJyopEMhpR6qYC6z(ZMyMVAoSepYQVDIKm)cISUuyeeK508lZl(qXpSmFDvksrpRlOg9jxda6OraQj0Op5evSFzCSIliKOaQpa1eA0NCIk2VmowXfesu2JtloiGUphaDh5yZ8MqJ(Y8vZHL4rw9TtKK1CAE084zE8SQdjZPN5pBIzEysl8Vgk(qwXocz(fezDPWiiiZP5xMx8HIFyz(6QuKIEwxqn6tUga0rJautOrFYjQy)Y4yfxqirbuFaQj0Op5evSFzCSIliKOShNwCqaDFoa6oYXM5nHg9L5HjTW)AO4dzf7iK1CA(TtE8mpEw1HK50Z8NnXmVsC2Hqw1E)HdXHWm)cISUuyeeK508lZl(qXpSmFDvksrpRlOg9jxda6OraQj0Op5evSFzCSIliKOaQpa1eA0NCIk2VmowXfesu2JtloiGUphaDh5yZ8MqJ(Y8kXzhczv79hoehcZAon)8lpEMhpR6qYC6z(ZMyM3orGNY8)AL1f2Mas2Zm)cISUuyeeK508lZl(qXpSmFDvksrpRlOg9jxda6OraQj0Op5evSFzCSIliKOaQpa1eA0NCIk2VmowXfesu2JtloiGUphaDh5yZ8MqJ(Y82jc8uM)xRSUW2eqYEM1CA(TN84zE8SQdjZPN5pBIz(dxV5yqUpBaIm8sStGFMFbrwxkmccYCA(L5fFO4hwMVUkfPON1fuJ(KRbaD0ia1eA0NCIk2VmowXfesua1hGAcn6torf7xghR4ccjk7XPfheq3NdGUJCSzEtOrFz(dxV5yqUpBaIm8sStGFwZP5NhMhpZJNvDizo9m)ztmZpnxP)jsYsW3CKqMdjS5TbyMFbrwxkmccYCA(L5fFO4hwMVUkfPON1fuJ(KRbaD0ia1eA0NCIk2VmowXfesua1hGAcn6torf7xghR4ccjk7XPfheq3NdGUJCSzEtOrFz(P5k9prswc(MJeYCiHnVnaZAwZ8dpk6z1084508lpEM3eA0xM3EHDilofDouOzE8SQdjZPN1CA7jpEMhpR6qYC6z(EiZdrnZBcn6lZ71(WQomZ71ClmZJE8kggqs50UOGqTzDHnnYdHqaD0iaf94vmmGKscoJmmTFiRAKeqaD0iaf94vmmGKscoJmmTFiBIKMZf9bOJgbOOhVIHbKugeUqJ(ytJaczLfeb0rJau0JxXWaskvIZoeYQ27pCioecOJgbOOhVIHbKuAe36rnPHmyCeqs2GBnnciGoAeGIE8kggqsPDIapL5)1kRlSnbKSNa6Orak6XRyyajLWKw4Fnu8HSIDea0rJau0JxXWaskpC9MJb5(SbiYWlXob(a6Orak6XRyyajLvZHL4rw9TtKK59Ap7SjM5f9SUGA0hRp2cIznNMhMhpZJNvDizo9mFpK5HOM5nHg9L59AFyvhM59AUfM5rpEfddiP0ioyI9gKv6tzDHn0BWhq9bOETpSQdLIEwxqn6J1hBbXmVx7zNnXmFPpLr2RQdz9XwqmR50iw5XZ84zvhsMtpZ3dzEiQzEtOrFzEV2hw1HzEVMBHz(9SdGUxaAQaQx7dR6qPON1fuJ(y9Xwqeq9bOebq9AFyvhkl9PmYEvDiRp2cIaAka6wakXAhaDVa0ubuV2hw1HYsFkJSxvhY6JTGiGMcGUfGUNXcO7fGMkGIE8kggqsPrCWe7niR0NY6cBO3GpG6dqjcG61(WQouw6tzK9Q6qwFSfeb0ua0TauIzaDVa0ubu0JxXWaskN2ffeQnRlSPrEiecO(auIaOETpSQdLL(ugzVQoK1hBbranLmVx7zNnXmFFSfezIL2LswZPn284zE8SQdjZPN57Hm)JquZ8MqJ(Y8ETpSQdZ8ETND2eZ8jTJKj6zDb1OpMM8imPDKzEsSylNM53ZoznNgXqE8mpEw1HK50Z89qMhIAM3eA0xM3R9HvDyM3R5wyMFpa6EbOQ5WtLfNnr2GPIejEw1HKa6waQh1JcO7fGseavnhEQS4SjYgmvKiXZQoKmZ71E2ztmZN0kdQpA(ZkoBIq9d)XmV4df)WY8ETpSQdLjTYG6JM)SIZMiu)WFeq5aO7K1CAEK5XZ84zvhsMtpZ3dzEiQzEtOrFzEV2hw1HzEVMBHzEpeq3lavnhEQS4SjYgmvKiXZQoKeq3cq9OEuaDVauIaOQ5WtLfNnr2GPIejEw1HKzEV2ZoBIz(e7jzcdQSIZMiu)WFmZl(qXpSmVx7dR6qzI9KmHbvwXzteQF4pcOCa0DYAonI584zE8SQdjZPN57Hm)JquZ8MqJ(Y8ETpSQdZ8ETND2eZ8KOZ4MvC2eH6h(JzEsSylNM53ZyZAonpAE8mpEw1HK50Z89qM)riQzEtOrFzEV2hw1HzEV2ZoBIzE)JJ0fhb2JKlHg9L5jXITCAMFh5EYAon)2jpEMhpR6qYC6znNMF(LhpZJNvDizo9m)ztmZBehmXEdYk9PSUWg6n4N5nHg9L5nIdMyVbzL(uwxyd9g8ZAon)2tE8mVj0OVm)m(VFwmncyMhpR6qYC6znNMFEyE8mVj0OVm)qRrFzE8SQdjZPN1CA(rSYJN5nHg9L5h4(7QZGAMhpR6qYC6znRzEOAhP9KSVvtJ(YJNtZV84zE8SQdjZPN5fFO4hwMpva1eA4fz4HZaHa6UCauV2hw1HYKwzq9rZFwXzteQF4pcO(a0ubunMiG6baADvksrpRlOg9jDguzirhIhb0DbuV2hw1Hss0zCZkoBIq9d)ranfanfa1hGwxLImPvguF08x(Oj0mVj0OVmFXzteQF4pM1CA7jpEMhpR6qYC6zEXhk(HL5RRsrM0kdQpA(lF0ekG6dqRRsrM0kdQpA(lFCAXbb09butOrFYs8y1CojsuuSuKPXeZ8MqJ(Y8dC)D1zqnR508W84zE8SQdjZPN5fFO4hwMVUkfzsRmO(O5V8rtOaQpanvaD4rVmccsPFYs8y1CoaD0iaTepcv7v8LMqdViGoAeGAcn6toW93vNbvzCSIliKOaAkzEtOrFz(bU)U6mOM1CAeR84zE8SQdjZPN5fFO4hwMxKypbecO7Ybq9qa1hGAcn8Im8WzGqaDxaDpaQpaLiaQx7dR6q5qsJxqu2q3U4iK5nHg9L5hsA8cIYkoBIWSMtBS5XZ84zvhsMtpZl(qXpSmFDvkYKwzq9rZF5JMqbuFaQApbuLjO50e5Gqb095aOE4oaQpavnhEQeI2hhbM2lrIepR6qYmVj0OVm)a3FxDguZAonIH84zE8SQdjZPN5fFO4hwMVUkf5a3FlCgCkF0ekG6dqfguzAmraDFaTUkf5a3FlCgCkFCAXbZ8MqJ(Y8dC)D1zqnR508iZJN5XZQoKmNEMFbr2MKWHmHb14iKtZVmV4df)WY8PcO1vPi)1HSUWg6n4lj7nhG6dqjcGwIhHQ9k(stOHxeqtbq9bOebq9AFyvhklXJSQZGkBOBxCeauFaAQaAQaAQaQj0OpzjESAoNejkkwACea0rJautOrFYbU)U6mOkrIIILghbanfa1hGwxLImbnnocS1G8rtOaAka6OraAQaQAo8ujeTpocmTxIejEw1HKaQpavTNaQYe0CAICqOa6(CaupCha1hGMkGwxLImbnnocS1G8rtOaQpaLiaQj0Opju0VirIefflnoca6Orakra06QuKjTYG6JM)YhnHcO(auIaO1vPitqtJJaBniF0ekG6dqnHg9jHI(fjsKOOyPXraq9bOebqnHg9jh4(7QZGQmowXfesua1hGsea1eA0NSepwnNtghR4ccjkGMcGMcGMsMFbrwxkmccYCA(L5nHg9L5lXJSQZGAwZPrmNhpZJNvDizo9mV4df)WY8PcO1vPitqtJJaBniF0ekGoAeGMkGseaTUkfzsRmO(O5V8rtOaQpanva1eA0NSepYQodQsrI9eqiGUlGUdGoAeGQMdpvcr7JJat7LirINvDijG6dqv7jGQmbnNMihekGUpha1d3bqtbqtbqtbq9bOebq9AFyvhkhsA8cIYg62fhHmVj0OVm)qsJxquwXzteM1CAE084zE8SQdjZPN5nHg9L5fMZXmHg9XCbuZ8UaQSZMyM3eA4fzQ5WtHznNMF7KhpZJNvDizo9mV4df)WY8MqdVidpCgieq3fq9lZBcn6lZt(gH(GS6JMMK1CA(5xE8mpEw1HK50Z8MqJ(Y8cZ5yMqJ(yUaQzExav2ztmZhkoHmxVHn8r)HYDwZP53EYJN5XZQoKmNEMx8HIFyzE1EcOktqZPjYbHcO7Zbq9WDauFaQAo8ujeTpocmTxIejEw1HKzEtOrFzEOOFrswZP5NhMhpZJNvDizo9mV4df)WY8MqdVidpCgieq3LdG61(WQouMypjtyqLvC2eH6h(JaQpanvavJjcOEaGwxLIu0Z6cQrFsNbvgs0H4raDxa1R9HvDOKeDg3SIZMiu)WFeqtjZBcn6lZxC2eH6h(JznNMFeR84zEtOrFz(s8y1CUmpEw1HK50ZAon)gBE8mVj0OVmpu0VijZJNvDizo9SM1m)3dSHedI5XZP5xE8mVj0OVm)VoK1f2qVb)mpEw1HK50ZAoT9KhpZJNvDizo9mV4df)WY8PcOMqdVidpCgieq3LdG61(WQouM0kdQpA(ZkoBIq9d)ra1hGMkGQXebupaqRRsrk6zDb1OpPZGkdj6q8iGUlG61(WQousIoJBwXzteQF4pcOPaOPaO(a06QuKjTYG6JM)YhnHM5nHg9L5loBIq9d)XSMtZdZJN5XZQoKmNEMx8HIFyz(6QuKjTYG6JM)YhnHM5nHg9L5h4(7QZGAwZPrSYJN5XZQoKmNEMFbr2MKWHmHb14iKtZVmV4df)WY8ebqtfqnHgErgE4mqiGUlha1R9HvDOmXEsMWGkR4Sjc1p8hbuFaAQaQgteq9aaTUkfPON1fuJ(KodQmKOdXJa6UaQx7dR6qjj6mUzfNnrO(H)iGMcGMcG6dqjcGwIhHQ9k(stOHxeq9bOPcOebqRRsrMGMghb2Aq(Ojua1hGseaTUkfzsRmO(O5V8rtOaQpaLia6WJEzDPWiiiLL4rw1zqfq9bOPcOMqJ(KL4rw1zqvksSNacb0D5aO7bqhncqtfqnHg9jhsA8cIYkoBIqPiXEcieq3LdG6hG6dqvZHNkhsA8cIYkoBIqjEw1HKaAka6OraAQaQAo8uP5qIc13GeNbzL1ZTepR6qsa1hGk62r2Boj5Be6dYQpAAI8rJKBanfaD0ianvavnhEQeI2hhbM2lrIepR6qsa1hGQ2tavzcAonroiuaDFoaQhUdGMcGMcGMsMFbrwxkmccYCA(L5nHg9L5lXJSQZGAwZPn284zE8SQdjZPN5nHg9L5fMZXmHg9XCbuZ8UaQSZMyM3eA4fzQ5WtHznNgXqE8mpEw1HK50Z8Ipu8dlZxxLICG7VfodoLpAcfq9bOcdQmnMiGUpGwxLICG7VfodoLpoT4GaQpaTUkf5VoK1f2qVbF5JtloiGUlGkmOY0yIzEtOrFz(bU)U6mOM1CAEK5XZ84zvhsMtpZVGiBts4qMWGACeYP5xMx8HIFyzEIaOPcOMqdVidpCgieq3LdG61(WQouMypjtyqLvC2eH6h(JaQpanvavJjcOEaGwxLIu0Z6cQrFsNbvgs0H4raDxa1R9HvDOKeDg3SIZMiu)WFeqtbqtbq9bOebqlXJq1EfFPj0WlcO(a0ub06QuKjOPXrGTgKpAcfq9bOPcOQ9eqvMGMttKdcfq3LdG6H7aOJgbOebqvZHNkHO9XrGP9sKiXZQoKeqtbqtjZVGiRlfgbbzon)Y8MqJ(Y8L4rw1zqnR50iMZJN5XZQoKmNEMFbr2MKWHmHb14iKtZVmV4df)WY8ebqtfqnHgErgE4mqiGUlha1R9HvDOmXEsMWGkR4Sjc1p8hbuFaAQaQgteq9aaTUkfPON1fuJ(KodQmKOdXJa6UaQx7dR6qjj6mUzfNnrO(H)iGMcGMcG6dqjcGwIhHQ9k(stOHxeq9bOQ5WtLq0(4iW0EjsK4zvhscO(au1EcOktqZPjYbHcO7Zbq9WDauFaAQaADvkYe004iWwdYhnHcO(auIaOMqJ(Kqr)IejsuuS04iaOJgbOebqRRsrMGMghb2Aq(Ojua1hGseaTUkfzsRmO(O5V8rtOaAkz(fezDPWiiiZP5xM3eA0xMVepYQodQznNMhnpEMhpR6qYC6zEXhk(HL5hE0lJGGu6Nek6xKaO(a06QuKjOPXrGTgKRba1hGQMdpvcr7JJat7LirINvDijG6dqv7jGQmbnNMihekGUpha1d3bq9bOebqtfqnHgErgE4mqiGUlha1R9HvDOmPvguF08NvC2eH6h(JaQpanvavJjcOEaGwxLIu0Z6cQrFsNbvgs0H4raDxa1R9HvDOKeDg3SIZMiu)WFeqtbqtjZBcn6lZpW93vNb1SMtZVDYJN5XZQoKmNEMx8HIFyzEIaOdp6Lrqqk9toK04feLvC2eHaQpaTUkfzcAACeyRb5JMqZ8MqJ(Y8djnEbrzfNnrywZP5NF5XZ84zvhsMtpZl(qXpSmVApbuLjO50e5Gqb095aOE4oaQpavnhEQeI2hhbM2lrIepR6qYmVj0OVmpu0VijR508Bp5XZ84zvhsMtpZl(qXpSmVj0WlYWdNbcb0Db09K5nHg9L5jFJqFqw9rttYAon)8W84zE8SQdjZPN5fFO4hwMpva1eA4fz4HZaHa6UCauV2hw1HYe7jzcdQSIZMiu)WFeq9bOPcOAmra1da06QuKIEwxqn6t6mOYqIoepcO7cOETpSQdLKOZ4MvC2eH6h(JaAkaAkzEtOrFz(IZMiu)WFmR508JyLhpZBcn6lZxIhRMZL5XZQoKmNEwZAwZ8EXhg9LtBp7SND2HyTJFz(n2FXraM5jMmh6xrsa1JcOMqJ(auxavOe4zMhoGICAedEyMF47s4Wm)yaOeV4raDmBeqGNJbGMO6aCmz7TjeAYQkf9CBymxotJ(eVv0THXuSnWZXaqjMo8Hdq9JlaDp7SNDaupaq9JynMmw)aEc8CmauIDIDeq4ycWZXaq9aa1JaIaQgtKPnJmqa9nnbFavtSdqv7jGQuJjY0MrgiGw6hqDgu9aik6JeqTA4cLBaDbnciuc8Cmaupaq9iginfbuxtiea6JJja6E)seKa6EZJ2ekbEogaQhaO79DdXdqfgub0h94v84epfcOL(buIDpRlOg9bOPgsuYfGs23ENcOjTJeqdfql9dOgGwEeMaOJzuX(buHb1uKaphda1da09MaAvhcO2bO4Pp3aQMykGUPxosa9r4YPaACaQbOj2tkmOcOeF5(7QZGkGgNhqWMOe4jWZXaqhtLOOyPijGwXs)iGk6z1uaTIeIdkbuIPcboOqa96ZdsSFwwoa1eA0heq7ZXTe45yaOMqJ(GYHhf9SAkNIZG(d8CmautOrFq5WJIEwnDloBx6Me45yaOMqJ(GYHhf9SA6wC22weM4PMg9b80eA0huo8OONvt3IZ22lSdzXPOZHcf4Pj0OpOC4rrpRMUfNT9AFyvhY1ztKJON1fuJ(y9XwqKREGdevU8AUfYb94vmmGKYPDrbHAZ6cBAKhcHJgHE8kggqsjbNrgM2pKvnsc4OrOhVIHbKusWzKHP9dztK0CUOVrJqpEfddiPmiCHg9XMgbeYklioAe6XRyyajLkXzhczv79hoehchnc94vmmGKsJ4wpQjnKbJJasYgCRPrahnc94vmmGKs7ebEkZ)RvwxyBcizphnc94vmmGKsysl8Vgk(qwXocJgHE8kggqs5HR3Cmi3NnargEj2jWF0i0JxXWaskRMdlXJS6BNib4Pj0OpOC4rrpRMUfNT9AFyvhY1ztKtPpLr2RQdz9XwqKREGdevU8AUfYb94vmmGKsJ4Gj2BqwPpL1f2qVbFFETpSQdLIEwxqn6J1hBbrGNJbGsmrXjeq1etbu7raDbrsaTxkmiraTlakXUN1fuJ(au7ra9AfqxqKeqTIIpGQjbeq1yIaAuaunb5gq30lhjGoSua1au9JZFub0fejb0nHMaOe7Ewxqn6dq7dqnafMypjscOIUDK9Mtc80eA0huo8OONvt3IZ2ETpSQd56SjYPp2cImXs7sHREGdevU8AUfYzp7SxP61(WQouk6zDb1OpwFSfe9reV2hw1HYsFkJSxvhY6JTGykBrS2zVs1R9HvDOS0NYi7v1HS(yliMYw7zS7vQOhVIHbKuAehmXEdYk9PSUWg6n47JiETpSQdLL(ugzVQoK1hBbXu2IyEVsf94vmmGKYPDrbHAZ6cBAKhcH(iIx7dR6qzPpLr2RQdz9XwqmfGNJbGsS7zDb1OpanGaAFoUb0fejb0nHM0lfqj(0VJ0lghGoMgc7ZobcO9dOJzC2p3aAxa09(Liib09MhTjeqJcGgkGUjCoaTIaQ51cNvDiGAkG6qdQaQMeqaDAh3akef9rcb0kw6hbunbbuecXtG7Dqav0TJS3CaAab0hnsULapnHg9bLdpk6z10T4STx7dR6qUoBICsAhjt0Z6cQrFmn5rys7i5Qh48ievUiXITCkN9SdWZXaqhpjGaQx7dR6qafoGIOeieq1eeqV1SIpG2favTNaQqa1uaDtsisauIXwbuE9rZFaL45Sjc1p8hHaAVuyqIaAxauIDpRlOg9bOWKE5ib0kcOliskbEAcn6dkhEu0ZQPBXzBV2hw1HCD2e5K0kdQpA(ZkoBIq9d)rU6boqu5kkC8AFyvhktALb1hn)zfNnrO(H)iND4YR5wiN9SxQ5WtLfNnr2GPIejEw1HKB5r9O7fruZHNkloBISbtfjs8SQdjbEoga64jbeq9AFyvhcOWbueLaHaQMGa6TMv8b0UaOQ9eqfcOMcOBscrcGsmApjGsSnOcOepNnrO(H)ieq7Lcdseq7cGsS7zDb1OpafM0lhjGwraDbrsa1GaAjCo8LapnHg9bLdpk6z10T4STx7dR6qUoBICsSNKjmOYkoBIq9d)rU6boqu5kkC8AFyvhktSNKjmOYkoBIq9d)ro7WLxZTqoE4EPMdpvwC2ezdMksK4zvhsULh1JUxernhEQS4SjYgmvKiXZQoKe45yaOEeW4iaOepNnrO(H)iGAffFaLy3Z6cQrFaAab02l(aQWoavylicOgGcdcxucHDkGAZEDkG2faL0Mgbeq1gqRiG6AOcOKleq1gq1eeqBV4V5dnocaAxauIjeUqravtmfqBHy9qaDtcEaQMGakXecxOiGw(EcOC3Rhqh(yAp3akXUN1fuJ(au1EcOcOWHhnsOeqhpjGaQx7dR6qanGa6cIKaQ2akCafrHBavtqa1M96uaTlaQgteqJdqHOOpsiGQjMcOZfub0bdcbuRO4dOe7Ewxqn6dqrIoepcb0kw6hbuINZMiu)WFecOBcNdqRiGUGijGE9pnNJBjWttOrFq5WJIEwnDloB71(WQoKRZMihs0zCZkoBIq9d)rUiXITCkN9mwU6bopcrf45yaOeFcnbqhtposxCe4cqj29SUGA03EheqfD7i7nhGUjCoaTIa6JKlbscOvUbudqF7i7jGAZEDkxaADPaQMGa6TMv8b0UaOIpuiGcv7viG6fFUb0KGqcGAffFa1eA4104iaOe7Ewxqn6dqTJeqHUEdeqj7nhGQ9g7jHaQMGakEKaAxauIDpRlOg9T3bbur3oYEZjbuIpj4bOtZ)4iaOKOiGrFqanoavtqaLykX39EUauIDpRlOg9T3bb0hNwCXraqfD7i7nhGgqa9rYLajb0k3aQMeqaT8MqJ(auTbuti61PaAPFaDm94iDXrqc80eA0huo8OONvt3IZ2ETpSQd56SjYX)4iDXrG9i5sOrFCrIfB5uo7i3dx9aNhHOc80eA0huo8OONvt3IZ2WZgGjTYGQPqGNMqJ(GYHhf9SA6wC2EbrwO4KRZMihJ4Gj2BqwPpL1f2qVbFGNMqJ(GYHhf9SA6wC2Eg)3plMgbe4Pj0OpOC4rrpRMUfNThAn6d4Pj0OpOC4rrpRMUfNTh4(7QZGkWtGNJbGoMkrrXsrsaf9Ip3aQgteq1eeqnH2pGgqa18AHZQouc80eA0hKJOxNIpCaDoGNMqJ(GBXzBV2hw1HCD2e5OXezAZe9SUGA0hx9ahiQC51ClKJAo8uzjEeQ2R4lXZQoKCVkXJq1EfF5Jtlo4wPk62r2BoPON1fuJ(KpoT4G7vQ(5bETpSQdL(hhPlocShjxcn6BVuZHNk9posxCeK4zvhsMIhycn6t(RdzDHn0BWxIefflfzAmX9snhEQ8xhY6cBO3GVepR6qYu2lIi62r2BoPON1fuJ(KpAKCVx1vPif9SUGA0NKS3CapnHg9b3IZ2ETpSQd56SjYrJjY0Mj6zDb1OpU6botJOC51ClKJOBhzV5KtC2p3SUWClrqYiF0Mq5JtloixrHdcH4jq5eN9ZnRlm3seKmYhTjuonI)(9vxLICIZ(5M1fMBjcsg5J2ekj7nNpr3oYEZjN4SFUzDH5wIGKr(OnHYhNwCqpWR9HvDOuJjY0Mj6zDb1OV9541(WQouM0osMON1fuJ(yAYJWK2rc80eA0hCloB71(WQoKRZMihnMitBMON1fuJ(4Qh4mnIYLxZTqoIUDK9MtUPFhPxmo2JW(StGYhNwCqUIchecXtGYn97i9IXXEe2NDcuonI)(9vxLICt)osVyCShH9zNaLK9MZNOBhzV5KB63r6fJJ9iSp7eO8XPfh0d8AFyvhk1yImTzIEwxqn6BFoETpSQdLjTJKj6zDb1OpMM8imPDKapnHg9b3IZ2cZ5yMqJ(yUaQCD2e5ekoHSKGqcB4J(dLBGNMqJ(GBXz7z8F)SyAeqUIcN6QuKIEwxqn6ts2BoGNMqJ(GBXzBcl7jd7yDHzeh(TMWvu4KQx7dR6qPgtKPnt0Z6cQrF773oJgPXezAZidCFV2hw1HsnMitBMON1fuJ(sb4Pj0Op4wC2w0Nap9nfjzfNnrGNMqJ(GBXz7hTH4iWkoBIqGNMqJ(GBXz7slwqKKzeh(HISkAtGNMqJ(GBXz7H1hfUJJaR6mOc80eA0hCloB)XWGdzXXGdMabEAcn6dUfNT1eKTUAVoswPFbc80eA0hCloB)RdzDHn0BWNROWPUkfPON1fuJ(KK9MZxQETpSQdLAmrM2mrpRlOg9TBz5CShfj2tazAmXrJ8AFyvhk1yImTzIEwxqn6BxnMitBgzGPa80eA0hCloBlmNJzcn6J5cOY1ztKJON1fuJ(ydjge5kkC8AFyvhk1yImTzIEwxqn6BFo7a80eA0hCloBxIhzvNbvUwqK1LcJGGKJFCTGiBts4qMWGACe44hxrHtQieINaLtC2p3SUWClrqYiF0Mq50i(7F0iecXtGYjo7NBwxyULiizKpAtOCgx)(mId)qrz1zqfF20Gk(s8SQdjtXNiXEciKZ0iktKypbe6Ji1vPitALb1hn)LpAc1hrsTUkfzcAACeyRb5JMq9LADvksrpRlOg9jxd(s1eA0NSepwnNtghR4ccj6OrMqJ(KdC)D1zqvghR4ccj6OrMqJ(Kqr)IejsuuS04iKYOrQ9eqvMGMttKdcDFoE4o(mHg9jHI(fjsKOOyPXriLu8rKujsDvkYe004iWwdYhnH6Ji1vPitALb1hn)LpAc1xDvksrpRlOg9jj7nNVunHg9jlXJvZ5KXXkUGqIoAKj0Op5a3FxDguLXXkUGqIMskapnHg9b3IZ2ETpSQd56SjYPepYQodQSHUDXrGlVMBHCuZHNk)1HSUWg6n4lXZQoK0NOBhzV5K)6qwxyd9g8LpoT4G7l62r2BozjEKvDguLLLZXEuKypbKPXe9LQx7dR6qPgtKPnt0Z6cQrF7Acn6t(RdzDHn0BWxwwoh7rrI9eqMgtmfFPk62r2Bo5VoK1f2qVbF5Jtlo4(AmrM2mYahnYeA0N8xhY6cBO3GVuKypbeU7oPmAKx7dR6qPgtKPnt0Z6cQrF7Bcn6twIhzvNbvzz5CShfj2tazAmrFETpSQdLAmrM2mrpRlOg9TVgtKPnJmqGNMqJ(GBXzBH5CmtOrFmxavUoBIC(EGnKyqKROWPUkf5VoK1f2qVbF5AWxQETpSQdLAmrM2mrpRlOg9T7oPa80eA0hCloB71(WQoKRZMiNHKgVGOSHUDXrGlVMBHCuZHNk)1HSUWg6n4lXZQoK0NOBhzV5K)6qwxyd9g8LpoT4G7l62r2Bo5qsJxquwXztekllNJ9OiXEcitJj6lvV2hw1HsnMitBMON1fuJ(21eA0N8xhY6cBO3GVSSCo2JIe7jGmnMyk(sv0TJS3CYFDiRlSHEd(YhNwCW91yImTzKboAKj0Op5VoK1f2qVbFPiXEciC3Dsz0iV2hw1HsnMitBMON1fuJ(23eA0NCiPXlikR4SjcLLLZXEuKypbKPXe951(WQouQXezAZe9SUGA03(AmrM2mYabEogakXNe8auIr7jfguJJaGs8C2ebuE9d)rUauIx8iGMUZGkeqHj9YrcOveqxqKeq1gqjGh(MIakXyRakV(O5peqTJeq1gqrIQ4rcOP7mOIpGoMnOIVe4Pj0Op4wC2UepYQodQCTGiRlfgbbjh)4Abr2MKWHmHb14iWXpUIcNujIx7dR6qzjEKvDguzdD7IJWOr1vPi)1HSUWg6n4lxdP4lvV2hw1HsnMitBMON1fuJ(2DNu8LQj0WlYWdNbc3LJx7dR6qzI9KmHbvwXzteQF4p6lvnMOhuxLIu0Z6cQrFsNbvgs0H4XD9AFyvhkjrNXnR4Sjc1p8htjfFePepcv7v8LMqdVOV6QuKjTYG6JM)sYEZ5lvIyeh(HIYQZGk(SPbv8L4zvhsoAuDvkYQZGk(SPbv8LpoT4G7VJCSPa8Cma09M1hhbaL4fpcv7v85cqjEXJaA6odQqa1EeqxqKeqHXmC274gq1gqjxFCeauIDpRlOg9jb0XuIh(MZXnxaQMGCdO2Ja6cIKaQ2akb8W3ueqjgBfq51hn)Ha6Me8auXhkeq3eohGETcOveq3yqfjbu7ib0nHMaOP7mOIpGoMnOIpxaQMGCdOWKE5ib0kcOWHhnsaTxkGQnGoT4uloavtqanDNbv8b0XSbv8b06QuKapnHg9b3IZ2L4rw1zqLRfezDPWiii54hxliY2KeoKjmOghbo(Xvu4uIhHQ9k(stOHx0NiXEciCxo(5lvI41(WQouwIhzvNbv2q3U4imAuDvkYFDiRlSHEd(Y1qk(sLigXHFOOS6mOIpBAqfFjEw1HKJgvxLIS6mOIpBAqfF5Jtlo4(7ihBk(sLiMqJ(KL4XQ5CsKOOyPXrWhrmHg9jh4(7QZGQmowXfesuF1vPitqtJJaBnixdJgzcn6twIhRMZjrIIILghbF1vPitALb1hn)LK9MB0itOrFYbU)U6mOkJJvCbHe1xDvkYe004iWwdsYEZ5RUkfzsRmO(O5VKS3CPa80eA0hCloBlmNJzcn6J5cOY1ztKduTJ0Es23QPrFCffoETpSQdLAmrM2mrpRlOg9T7oapbEAcn6dknHgErMAo8uihx4nocSApRCffoMqdVidpCgiCx)8vxLIu0Z6cQrFsYEZ5lvV2hw1HsnMitBMON1fuJ(2v0TJS3Csx4nocSApRsY1BA03OrETpSQdLAmrM2mrpRlOg9TpNDsb4Pj0OpO0eA4fzQ5WtHBXz7jQy)CffoETpSQdLAmrM2mrpRlOg9TpNDgnk16QuK)6qwxyd9g8LRHrJeD7i7nN8xhY6cBO3GV8XPfhCxnMitBgzG(mHg9j)1HSUWg6n4lfj2taH773OrernhEQ8xhY6cBO3GVepR6qYu8LQOBhzV5KtuX(LKR30OV99AFyvhk1yImTzIEwxqn6B0inMitBgzG771(WQouQXezAZe9SUGA0xkapnHg9bLMqdVitnhEkCloBt(gH(GS6JMMWvu4OMdpvAoKOq9niXzqwz9ClXZQoK0xQ1vPif9SUGA0NKS3C(isDvkYKwzq9rZF5JMqhnQUkfPON1fuJ(KRbFMqJ(KL4rw1zqvksSNac33eA0NSepYQodQYPruMiXEci0hrQRsrM0kdQpA(lF0eAkapbEogakXUN1fuJ(a0HedIa6WJd2Jqa1QHl0aHa6MqtaudqjrNXnxaQMGhG6S1jsqiGgN2aQMGakXUN1fuJ(aui6Xl8eiWttOrFqPON1fuJ(ydjge54ccjkKr8VijmXt5kkCQRsrk6zDb1OpjzV5aEAcn6dkf9SUGA0hBiXG4wC2UAeyDHPFi8hYvu4uxLIu0Z6cQrFsYEZb80eA0huk6zDb1Op2qIbXT4STl8ghbwTNvUIchtOHxKHhodeURF(QRsrk6zDb1OpjzV5aEAcn6dkf9SUGA0hBiXG4wC2U66MK1fMMGm8Wj3apnHg9bLIEwxqn6JnKyqCloBpXz)CZ6cZTebjJ8rBcbEAcn6dkf9SUGA0hBiXG4wC2Et)osVyCShH9zNabEoga6EZ6JJaGsS7zDb1OpUauIx8iGMUZGkeqThb0fejbuTbuc4HVPiGsm2kGYRpA(dbu7ib0zCXmioeq1eeqTzVofq7cGQXebu4aEkGIefflnocaARj4dOWb05GsaL41pGcv7iTNeqjEXJCbOeV4ranDNbviGApcO954gqxqKeq3KGhGsmIMghba1JyaqdiGAcn8IaA)a6Me8audq5f9lsauHbvanGaACa6W3eEecbu7ibuIr004iaOEedaQDKakXyRakV(O5pGApcOxRaQj0WlkbuIpHMaOP7mOIpGoMnOIpGAhjGs8C2eb092hxakXlEeqt3zqfcOc7auJKm0OpZ54gqRiGUGijGUjjCiGsm2kGYRpA(dO2rcOeJOPXraq9igau7ra9AfqnHgEra1osa1auIVC)D1zqfqdiGghGQjiGAXdO2rcOMd2a6MKWHaQWGACeauEr)Ieaf9IhGgfaLyennocaQhXaGgqa1CpAKCdOMqdVOeqhpbbuNPk(aQ5C9giGQBAaLySvaLxF08hqj(Y93vNbviGQnGwravyqfqJdqHlHaHWOpa1kk(aQMGakVOFrIeqjMssgA0N5CCdOBcnbqt3zqfFaDmBqfFa1osaL45SjcO7TpUauIx8iGMUZGkeqHj9YrcOxRaAfb0fejb015qieqt3zqfFaDmBqfFanGaQv7LcOAdOirhIhb0(bunbFeqThb0z)iGQj2bO41lcjakXlEeqt3zqfcOAdOirv8ib00DguXhqhZguXhq1gq1eeqXJeq7cGsS7zDb1OpjWttOrFqPON1fuJ(ydjge3IZ2L4rw1zqLRfezDPWiii54hxliY2KeoKjmOghbo(Xvu4isSNac3LJF(snvtOrFYs8iR6mOkfj2taHSYBcn6ZCBLADvksrpRlOg9jFCAXb9G6QuKvNbv8ztdQ4ljxVPrFPS3s0TJS3CYs8iR6mOkjxVPrFEqQ1vPif9SUGA0N8XPfhmL9wPwxLIS6mOIpBAqfFj56nn6Zd2ro2uszxo7mAermId)qrz1zqfF20Gk(s8SQdjhnIiQ5WtLfNnrwFs8SQdjhnQUkfPON1fuJ(KpoT4G7ZPUkfz1zqfF20Gk(sY1BA03Or1vPiRodQ4ZMguXx(40IdU)oYXoAe6XRyyajLjCpGVM8OrY28bu382a0NOBhzV5KjCpGVM8OrY28bu382aK5H7SJFeR9iFCAXb3FSP4RUkfPON1fuJ(KRbFPsetOrFsOOFrIejkkwACe8retOrFYbU)U6mOkJJvCbHe1xDvkYe004iWwdY1WOrMqJ(Kqr)IejsuuS04i4RUkfzsRmO(O5VKS3C(sTUkfzcAACeyRbjzV5gnYio8dfLvNbv8ztdQ4lXZQoKmLrJmId)qrz1zqfF20Gk(s8SQdj9PMdpvwC2ez9jXZQoK0Nj0Op5a3FxDguLXXkUGqI6RUkfzcAACeyRbjzV58vxLImPvguF08xs2BUuaEAcn6dkf9SUGA0hBiXG4wC2(xhY6cBO3GpxrHtDvksrpRlOg9jj7nhWZXaqjMcOeV4ranDNbvafM0lhjGwraDbrsavBa1ggCCdOP7mOIpGoMnOIpGUjjCiGkmOghbaDmT1HaAxauIV9g8b0nj4bOlyCea00DguXhqhZguXNlaL45SjcO7TpUau7ib0XmQy)saLysbq7ZXnGoMXz)CdODbq37xIGeq3BE0MqaDmhx)aAabu0JxXWasYfGQjbeqDXHaAab0GW1pscOvuylicOHcOBcNdqH9e1yIqa9r4YPaACakHoocaACAdOe7Ewxqn6dq3eAcGwWnakXlEeqt3zqfqfj2taHsGNMqJ(GsrpRlOg9XgsmiUfNTlXJSQZGkxliY2KeoKjmOghbo(Xvu4yeh(HIYQZGk(SPbv8L4zvhs6lvecXtGYjo7NBwxyULiizKpAtOCAe)9pAerqiepbkN4SFUzDH5wIGKr(OnHYzC9NIp1C4PYjQy)s8SQdj9PMdpvwC2ez9jXZQoK0xDvkYQZGk(SPbv8LK9MZxQQ5WtL)6qwxyd9g8L4zvhs6ZeA0N8xhY6cBO3GVejkkwACe8zcn6t(RdzDHn0BWxIefflfzpoT4G7VJKyy0Ou9AFyvhk1yImTzIEwxqn6BFo7mAuDvksrpRlOg9jxdP4JiQ5WtL)6qwxyd9g8L4zvhs6JiMqJ(KdC)D1zqvghR4ccjQpIycn6twIhRMZjJJvCbHenfGNMqJ(GsrpRlOg9XgsmiUfNTfMZXmHg9XCbu56SjYXeA4fzQ5WtHapnHg9bLIEwxqn6JnKyqCloBl6zDb1OpUwqK1LcJGGKJFCTGiBts4qMWGACe44hxrHtQieINaLtC2p3SUWClrqYiF0Mq50i(7F0O6QuKjTYG6JM)YhnHoAKj0Opju0VirIefflnoc(mHg9jHI(fjsKOOyPi7XPfhC)DKJD0itOrFYbU)U6mOkrIIILghbFMqJ(KdC)D1zqvIefflfzpoT4G7VJCSP4l16QuK)6qwxyd9g8LRHrJiIAo8u5VoK1f2qVbFjEw1HKPa80eA0huk6zDb1Op2qIbXT4S9qRrFapnHg9bLIEwxqn6JnKyqCloBxDDtYkRNBGNMqJ(GsrpRlOg9XgsmiUfNTR4dX3)4ia80eA0huk6zDb1Op2qIbXT4SDjES66Me4Pj0OpOu0Z6cQrFSHedIBXzB7eiuFZXeMZb80eA0huk6zDb1Op2qIbXT4SDXzteQF4pYvu4KAQQ5WtLfNnr2GPIejEw1HK(mHgErgE4mq4U7jLrJmHgErgE4mq4UedP4RUkfzsRmO(O5V8rtO(iIrC4hkkRodQ4ZMguXxINvDijWttOrFqPON1fuJ(ydjge3IZ2dC)D1zqLROWPUkf5a3FlCgCkF0eQV6QuKIEwxqn6t(40IdURWGktJjc80eA0huk6zDb1Op2qIbXT4S9a3FxDgu5kkCQRsrM0kdQpA(lF0ekWttOrFqPON1fuJ(ydjge3IZ2dC)D1zqLROWz4rVmccsPFsOOFrIV6QuKjOPXrGTgKRbGNMqJ(GsrpRlOg9XgsmiUfNThsA8cIYkoBIqGNMqJ(GsrpRlOg9XgsmiUfNTHI(fjCffo1vPif9SUGA0N8XPfhCxHbvMgt0xDvksrpRlOg9jxdJgvxLIu0Z6cQrFsYEZ5t0TJS3CsrpRlOg9jFCAXb3xyqLPXebEAcn6dkf9SUGA0hBiXG4wC22fEJJaR2ZkxrHtDvksrpRlOg9jFCAXb3NGGuonI6ZeA4fz4HZaH76hWttOrFqPON1fuJ(ydjge3IZ2KVrOpiR(OPjCffo1vPif9SUGA0N8XPfhCFccs50iQV6QuKIEwxqn6tUgaEAcn6dkf9SUGA0hBiXG4wC2gk6xKWvu4O2tavzcAonroi0954H74tnhEQeI2hhbM2lrIepR6qsGNapnHg9bLHItit0Z6cQrFCwqKfko56SjYjiCHg9XMgbeYklic80eA0hugkoHmrpRlOg9TfNTxqKfko56SjYjH7b81Khns2MpG6M3gGCffo1vPif9SUGA0NCn4ZeA0NSepYQodQsrI9eqiND8zcn6twIhzvNbv5JIe7jGmnM4UeeKYPruGNMqJ(GYqXjKj6zDb1OVT4S9cISqXjxNnrot7Icc1M1f20ipecbEAcn6dkdfNqMON1fuJ(2IZ2c7eOJvxLcxliY6sHrqqYXpUoBICM2ffeQnRlSPrEieYej2GIpRpKROWPUkfPON1fuJ(KRHrJmHg9jNOI9lJJvCbHe1Nj0Op5evSFzCSIliKOShNwCW95SJCSapnHg9bLHItit0Z6cQrFBXz7fezHItUwqK1LcJGGKJFCD2e5ye36rnPHmyCeqs2GBnncixrHtDvksrpRlOg9jxdJgzcn6torf7xghR4ccjQptOrFYjQy)Y4yfxqirzpoT4G7Zzh5ybEAcn6dkdfNqMON1fuJ(2IZ2liYcfNCTGiRlfgbbjh)4clfuOSZMihcoJmmTFiRAKeqUIcN6QuKIEwxqn6tUggnYeA0NCIk2VmowXfesuFMqJ(KtuX(LXXkUGqIYECAXb3NZoYXc80eA0hugkoHmrpRlOg9TfNTxqKfko5Abrwxkmccso(XfwkOqzNnroeCgzyA)q2ejnNl6JROWPUkfPON1fuJ(KRHrJmHg9jNOI9lJJvCbHe1Nj0Op5evSFzCSIliKOShNwCW95SJCSapnHg9bLHItit0Z6cQrFBXz7fezHItUwqK1LcJGGKJFCD2e5unhwIhz13orcxrHtDvksrpRlOg9jxdJgzcn6torf7xghR4ccjQptOrFYjQy)Y4yfxqirzpoT4G7Zzh5ybEAcn6dkdfNqMON1fuJ(2IZ2liYcfNCTGiRlfgbbjh)46SjYbM0c)RHIpKvSJaxrHtDvksrpRlOg9jxdJgzcn6torf7xghR4ccjQptOrFYjQy)Y4yfxqirzpoT4G7Zzh5ybEAcn6dkdfNqMON1fuJ(2IZ2liYcfNCTGiRlfgbbjh)46SjYrjo7qiRAV)WH4qixrHtDvksrpRlOg9jxdJgzcn6torf7xghR4ccjQptOrFYjQy)Y4yfxqirzpoT4G7Zzh5ybEAcn6dkdfNqMON1fuJ(2IZ2liYcfNCTGiRlfgbbjh)46SjYXorGNY8)AL1f2Mas2tUIcN6QuKIEwxqn6tUggnYeA0NCIk2VmowXfesuFMqJ(KtuX(LXXkUGqIYECAXb3NZoYXc80eA0hugkoHmrpRlOg9TfNTxqKfko5Abrwxkmccso(X1ztKZHR3Cmi3NnargEj2jWNROWPUkfPON1fuJ(KRHrJmHg9jNOI9lJJvCbHe1Nj0Op5evSFzCSIliKOShNwCW95SJCSapnHg9bLHItit0Z6cQrFBXz7fezHItUwqK1LcJGGKJFCD2e5mnxP)jsYsW3CKqMdjS5TbixrHtDvksrpRlOg9jxdJgzcn6torf7xghR4ccjQptOrFYjQy)Y4yfxqirzpoT4G7Zzh5ybEc80eA0hugkoHSKGqcB4J(dLBocZ5yMqJ(yUaQCD2e5ekoHmrpRlOg9Xvu441(WQouQXezAZe9SUGA03(C2b4Pj0OpOmuCczjbHe2Wh9hk3BXz7fezHItiWttOrFqzO4eYsccjSHp6puU3IZ2liYcfNCD2e5mTlkiuBwxytJ8qiKROWHiOhVIHbKuAehmXEdYk9PSUWg6n47ZR9HvDOuJjY0Mj6zDb1OV9jMbEAcn6dkdfNqwsqiHn8r)HY9wC2EbrwO4KRZMihJ4Gj2BqwPpL1f2qVbFUIchV2hw1HsnMitBMON1fuJ(2NZy3YVXUxETpSQdLL(ugzVQoK1hBbrGNMqJ(GYqXjKLeesydF0FOCVfNTxqKfko56SjY5Bv8lOIKmVDt2nJSDoUIchV2hw1HsnMitBMON1fuJ(21R9HvDOSp2cImXs7sb4Pj0OpOmuCczjbHe2Wh9hk3BXz7fezHItUoBICmpEfdTINYoBPHBb5kkC8AFyvhk1yImTzIEwxqn6BxV2hw1HY(yliYelTlfGNMqJ(GYqXjKLeesydF0FOCVfNTxqKfko56SjYbMeEXN5fVEYE0fcUIchV2hw1HsnMitBMON1fuJ(21R9HvDOSp2cImXs7sb4Pj0OpOmuCczjbHe2Wh9hk3BXz7fezHItUoBICk9xdss8yDfgKHDmHZ2Wvu441(WQouQXezAZe9SUGA03UETpSQdL9XwqKjwAxkapnHg9bLHItiljiKWg(O)q5EloBVGiluCYfwkOqzNnroj2p7lemsCAk(H5cIdFGNMqJ(GYqXjKLeesydF0FOCVfNTxqKfko56SjYzAUs)tKKLGV5iHmhsyZBdqUIchV2hw1HsnMitBMON1fuJ(2LZyhRV6QuKIEwxqn6ts2BoFETpSQdLAmrM2mrpRlOg9TRx7dR6qzFSfezIL2LcWttOrFqzO4eYsccjSHp6puU3IZ2liYcfNCD2e5yNiWtz(FTY6cBtaj7jxrHJx7dR6qPgtKPnt0Z6cQrF7YzSJ1xDvksrpRlOg9jj7nNpV2hw1HsnMitBMON1fuJ(21R9HvDOSp2cImXs7sb4Pj0OpOmuCczjbHe2Wh9hk3BXz7fezHItUoBICoC9MJb5(SbiYWlXob(CffoETpSQdLAmrM2mrpRlOg9TlhI1y9vxLIu0Z6cQrFsYEZ5ZR9HvDOuJjY0Mj6zDb1OVD9AFyvhk7JTGitS0UuaEc80eA0hugkoHmxVHn8r)HYnNfezHItUoBIC0GeHA)tMOjrIYvu441(WQouQXezAZe9SUGA03UETpSQdL9XwqKjwAxkapnHg9bLHItiZ1BydF0FOCVfNTxqKfko5clfuOSZMihb3cxRFFHGvDgu5kkC8AFyvhk1yImTzIEwxqn6BxV2hw1HY(yliYelTlfGNapnHg9bLFpWgsmiY5xhY6cBO3GpWttOrFq53dSHedIBXz7IZMiu)WFKROWjvtOHxKHhodeUlhV2hw1HYKwzq9rZFwXzteQF4p6lvnMOhuxLIu0Z6cQrFsNbvgs0H4XD9AFyvhkjrNXnR4Sjc1p8htjfF1vPitALb1hn)LpAcf4Pj0OpO87b2qIbXT4S9a3FxDgu5kkCQRsrM0kdQpA(lF0ekWttOrFq53dSHedIBXz7s8iR6mOY1cISUuyeeKC8JRfezBschYeguJJah)4kkCisQMqdVidpCgiCxoETpSQdLj2tYeguzfNnrO(H)OVu1yIEqDvksrpRlOg9jDguzirhIh31R9HvDOKeDg3SIZMiu)WFmLu8rKs8iuTxXxAcn8I(sLi1vPitqtJJaBniF0eQpIuxLImPvguF08x(OjuFez4rVSUuyeeKYs8iR6mO6lvtOrFYs8iR6mOkfj2taH7YzpJgLQj0Op5qsJxquwXztekfj2taH7YXpFQ5WtLdjnEbrzfNnrOepR6qYugnkv1C4PsZHefQVbjodYkRNBjEw1HK(eD7i7nNK8nc9bz1hnnr(OrYDkJgLQAo8ujeTpocmTxIejEw1HK(u7jGQmbnNMihe6(C8WDsjLuaEAcn6dk)EGnKyqCloBlmNJzcn6J5cOY1ztKJj0WlYuZHNcbEAcn6dk)EGnKyqCloBpW93vNbvUIcN6QuKdC)TWzWP8rtO(eguzAmX9RRsroW93cNbNYhNwCqF1vPi)1HSUWg6n4lFCAXb3vyqLPXebEAcn6dk)EGnKyqCloBxIhzvNbvUwqK1LcJGGKJFCTGiBts4qMWGACe44hxrHdrs1eA4fz4HZaH7YXR9HvDOmXEsMWGkR4Sjc1p8h9LQgt0dQRsrk6zDb1OpPZGkdj6q84UETpSQdLKOZ4MvC2eH6h(JPKIpIuIhHQ9k(stOHx0xQ1vPitqtJJaBniF0eQVuv7jGQmbnNMihe6UC8WDgnIiQ5WtLq0(4iW0EjsK4zvhsMskapnHg9bLFpWgsmiUfNTlXJSQZGkxliY6sHrqqYXpUwqKTjjCityqnocC8JROWHiPAcn8Im8WzGWD541(WQouMypjtyqLvC2eH6h(J(svJj6b1vPif9SUGA0N0zqLHeDiECxV2hw1Hss0zCZkoBIq9d)XusXhrkXJq1EfFPj0Wl6tnhEQeI2hhbM2lrIepR6qsFQ9eqvMGMttKdcDFoE4o(sTUkfzcAACeyRb5JMq9retOrFsOOFrIejkkwACegnIi1vPitqtJJaBniF0eQpIuxLImPvguF08x(Oj0uaEAcn6dk)EGnKyqCloBpW93vNbvUIcNHh9YiiiL(jHI(fj(QRsrMGMghb2AqUg8PMdpvcr7JJat7LirINvDiPp1EcOktqZPjYbHUphpChFejvtOHxKHhodeUlhV2hw1HYKwzq9rZFwXzteQF4p6lvnMOhuxLIu0Z6cQrFsNbvgs0H4XD9AFyvhkjrNXnR4Sjc1p8htjfGNMqJ(GYVhydjge3IZ2djnEbrzfNnrixrHdrgE0lJGGu6NCiPXlikR4Sjc9vxLImbnnocS1G8rtOapnHg9bLFpWgsmiUfNTHI(fjCffoQ9eqvMGMttKdcDFoE4o(uZHNkHO9XrGP9sKiXZQoKe4Pj0OpO87b2qIbXT4Sn5Be6dYQpAAcxrHJj0WlYWdNbc3DpapnHg9bLFpWgsmiUfNTloBIq9d)rUIcNunHgErgE4mq4UC8AFyvhktSNKjmOYkoBIq9d)rFPQXe9G6QuKIEwxqn6t6mOYqIoepURx7dR6qjj6mUzfNnrO(H)ykPa80eA0hu(9aBiXG4wC2UepwnNd4jWttOrFqjuTJ0Es23QPrFCkoBIq9d)rUIcNunHgErgE4mq4UC8AFyvhktALb1hn)zfNnrO(H)OVu1yIEqDvksrpRlOg9jDguzirhIh31R9HvDOKeDg3SIZMiu)WFmLu8vxLImPvguF08x(OjuGNMqJ(GsOAhP9KSVvtJ(2IZ2dC)D1zqLROWPUkfzsRmO(O5V8rtO(QRsrM0kdQpA(lFCAXb33eA0NSepwnNtIefflfzAmrGNMqJ(GsOAhP9KSVvtJ(2IZ2dC)D1zqLROWPUkfzsRmO(O5V8rtO(sD4rVmccsPFYs8y1CUrJkXJq1EfFPj0WloAKj0Op5a3FxDguLXXkUGqIMcWttOrFqjuTJ0Es23QPrFBXz7HKgVGOSIZMiKROWrKypbeUlhp0Nj0WlYWdNbc3Dp(iIx7dR6q5qsJxqu2q3U4ia80eA0hucv7iTNK9TAA03wC2EG7VRodQCffo1vPitALb1hn)LpAc1NApbuLjO50e5Gq3NJhUJp1C4PsiAFCeyAVejs8SQdjbEAcn6dkHQDK2tY(wnn6BloBpW93vNbvUIcN6QuKdC)TWzWP8rtO(eguzAmX9RRsroW93cNbNYhNwCqGNMqJ(GsOAhP9KSVvtJ(2IZ2L4rw1zqLRfezDPWiii54hxliY2KeoKjmOghbo(Xvu4KADvkYFDiRlSHEd(sYEZ5JiL4rOAVIV0eA4ftXhr8AFyvhklXJSQZGkBOBxCe8LAQPAcn6twIhRMZjrIIILghHrJmHg9jh4(7QZGQejkkwACesXxDvkYe004iWwdYhnHMYOrPQMdpvcr7JJat7LirINvDiPp1EcOktqZPjYbHUphpChFPwxLImbnnocS1G8rtO(iIj0Opju0VirIefflnocJgrK6QuKjTYG6JM)YhnH6Ji1vPitqtJJaBniF0eQptOrFsOOFrIejkkwACe8retOrFYbU)U6mOkJJvCbHe1hrmHg9jlXJvZ5KXXkUGqIMskPa8CmauIDpN4PXraq1KacO4Pp3aAV0XuaOHU3bb0hDChhbaTpa1a0hnHg9bOAmraLeDg3a6Me8auU7fG6)1BauU71dO8I(fja6MW5auXhkGAhjGYDVa0eJeqjgrtJJaG6rmaOBsWdq5UxaQWGkGYl6xKibEogakXKZdiytKlavtciGgqanXoshscOZ(ra9mD9MZXTe45yaOMqJ(GsOAhP9KSVvtJ(2IZ2dC)D1zqLROWz4rVmccsPFsOOFrIV6QuKjOPXrGTgKRbFQ5WtLq0(4iW0EjsK4zvhs6tTNaQYe0CAICqO7ZXd3Xhrs1eA4fz4HZaH7YXR9HvDOmPvguF08NvC2eH6h(J(svJj6b1vPif9SUGA0N0zqLHeDiECxV2hw1Hss0zCZkoBIq9d)Xusb4Pj0OpOeQ2rApj7B10OVT4S9qsJxquwXzteYvu4KADvkYe004iWwdYhnHoAuQePUkfzsRmO(O5V8rtO(s1eA0NSepYQodQsrI9eq4U7mAKAo8ujeTpocmTxIejEw1HK(u7jGQmbnNMihe6(C8WDsjLu8reV2hw1HYHKgVGOSHUDXra4Pj0OpOeQ2rApj7B10OVT4STWCoMj0OpMlGkxNnroMqdVitnhEke4Pj0OpOeQ2rApj7B10OVT4Sn5Be6dYQpAAcxrHJj0WlYWdNbc31pGNMqJ(GsOAhP9KSVvtJ(2IZ2cZ5yMqJ(yUaQCD2e5ekoHmxVHn8r)HYnWttOrFqjuTJ0Es23QPrFBXzBOOFrcxrHJApbuLjO50e5Gq3NJhUJp1C4PsiAFCeyAVejs8SQdjbEogakXNqtau86fHeavTNaQqUa0qb0acOgGsWIdq1gqfgubuINZMiu)WFeqniGwcNdFanoOIgjG2faL4fpwnNtc80eA0hucv7iTNK9TAA03wC2U4Sjc1p8h5kkCmHgErgE4mq4UC8AFyvhktSNKjmOYkoBIq9d)rFPQXe9G6QuKIEwxqn6t6mOYqIoepURx7dR6qjj6mUzfNnrO(H)ykapnHg9bLq1os7jzFRMg9TfNTlXJvZ5aEAcn6dkHQDK2tY(wnn6BloBdf9lsYAwZza]] )


end
