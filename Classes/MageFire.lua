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

    spec:RegisterSetting( "save_2_runes", true, {
        name = "Reserve |T609815:0|t Rune of Power Charges for Combustion",
        desc = "While |T609815:0|t Rune of Power is not considered a Cooldown by default, saving 2 charges to line up with |T135824:0|t Combustion is generally a good idea.\n\n" ..
            "The addon will reserve this many charges to line up with |T135824:0|t Combustion, regardless of whether Cooldowns are toggled on/off.",
        type = "toggle",
        width = 3
    } )



    spec:RegisterPack( "Fire IV", 20200204.1, [[diKjyaqiLQ4rkvLnrPmkvv5uQQQxHqnlvvUfcIAxe9leLHrPQJrHwgI4zusnnkv4AkvvBJsL8neuzCiQ05OuPwhLkQMNsv6EkL9HahKsfLfIi9qeezJuQiNerfRuvXnrqYovvAOiOyPii4PQYuriBfbvTxG)kYGj1HLSybpgQjdPlJAZK8zky0q0PvSAee61iQA2I62kz3Q8BQgofTCqpNW0L66cTDkjFhcJhbPopLy9iO08vQSFKgyeqe4Hwnd(sI9KyV9wBTrPr7YOrsiCGxBXKbpZct(YadExTyWZonqMQjhcp4zwwYEHcic8eEeIzWdz3Mc7CYiBWwiKTINtiX(ImWleNCtohiaEOvZGVKypj2BV1wBuA0UmA0iHd8QyJ0HGh5GTqit455euTDwSr6qb4HCqr5deapuwGbV9r12PbYunHQmW0p7JQjTemkv7kfvtoylunHNNtq1MWXHtBrs)SpQMqvqmsQ2AJ)OAsSNe7bV8iAbGiWdLvvm3aIaFncic8kCp(bEypEndfMCodE8vHmJcif0GVKaic84Rczgfqk4HHtZWPapS7zuhXjX(kef94NeYfQfWRW94h4bJhNCvY0rWqqd(AnGiWJVkKzuaPGhgondNc8WUNrDeNe7Rqu0JFsixOwaVc3JFG3Ixo0sYvPCepOjuixlbObFTdarGhFviZOasbpmCAgof4fIkLe7Rqu0JFsuhXbEfUh)aVOGttZlbObF3pGiWJVkKzuaPGhgondNc8(JQ3dv3vMVwcJhNCvY0rWqjFviZOu9UDuDiQusy84KRsMocgkJMu9)uTnQ(pQg7Eg1rCsSVcrrp(jHCHAHQ3TJQXUNrDeNe7Rqu0JFsiVQ5eunbBuTDSFQ(FWRW94h4T4MDiObFTlarGhFviZOasbVOGtiqozoHlrpNbWxJGhgondNc8(JQ3dvZcbFywU4LdTKCvkhXdAcfY1sixfHOdP6D7O6quPKlE5qljxLYr8GMqHCTeYOjvVBhvJDpJ6io5Ixo0sYvPCepOjuixlHeYRAobvtavB04(P6)PABu9Fu9EO6UY81Yf3SdL8vHmJs172r1y3ZOoItU4MDOeYRAobv)p4ffCYvQKbmk4RrWRW94h4H9vik6Xpqd(s4aebE8vHmJcif8kCp(bEiTyYWgjKl0ec4iAeWYuaEy40mCkWlevkj2xHOOh)KrtQ2gvx4E8tQgiNc5s0smYcAGfu9gvBpvBJQlCp(jvdKtHCjAjKXilObo1ZIPAcOAdyu5Qi0G3vlg8qAXKHnsixOjeWr0iGLPa0GVKlGiWJVkKzuaPGhgondNc8uXCobzmYcAGt9SyQEVunjGxH7XpWdgpo5QKPJGHGg81UbebE8vHmJcif8WWPz4uGhgzbnWIKcw4E8RYunbBunjs7g8kCp(bEMiD(gcDsLRflan4Rr7bebE8vHmJcif8WWPz4uG3EO6UY81svUwCYSAmsjFviZOuTnQ(pQoevkj2xHOOh)KrtQ2gvx4ESIt8XRHfunbBun5s172r1HOsjX(kef94Ne1rCuTnQUW9yfN4JxdlOAc2O69t1)t12O6quPKi9ojAixKxgnbVc3JFGNkxlw0WH8mObFnAeqe4XxfYmkGuWddNMHtbEDL5RLQCT4Kz1yKs(QqMrPABu9FuDiQusSVcrrp(jJMuTnQUW9yfN4JxdlOAc2OARP6D7O6quPKyFfIIE8tI6ioQ2gvx4ESIt8XRHfunbBunju9)uTnQoevkjsVtIgYf5LrtWRW94h4PY1IfnCipdAWxJKaic84Rczgfqk4HHtZWPaVquPKMwGooxILmAs12O6)O6quPKyFfIIE8tc5vnNGQjGQdrLsAAb64CjwsiVQ5eu9UDuDiQusSVcrrp(jrDehvBJQXUNrDeNe7Rqu0JFsiVQ5eunbuDiQustlqhNlXsc5vnNGQjMQTMQ)NQTr1)r1HOsjHXJtUkz6iyOeYRAobvtavhIkL00c0X5sSKqEvZjO6D7O69q1DL5RLW4XjxLmDemuYxfYmkvVBhv3vMVwcJhNCvY0rWqjFviZOuTnQoevkjmECYvjthbdLOoIJQTr1y3ZOoItcJhNCvY0rWqjKx1CcQMaQoevkPPfOJZLyjH8QMtq1et1wt1)dEfUh)aptlqpKlrdAWxJwdic84Rczgfqk4HHtZWPaVquPKi9ojAixKxgnbVc3JFGNPfOhYLObn4Rr7aqe4XxfYmkGuWddNMHtbEfUhR4eF8AybvtWgvBnvBJQ7zXP2tOdt1eSr1Kl4v4E8d8YJvZzif8va0GVg3pGiWJVkKzuaPGhgondNc8crLsI9vik6Xpz0KQTr1HOsjX(kef94NeYRAobvVxQ2i4v4E8d8qHLb)ePaKRgjObFnAxaIap(QqMrbKcEy40mCkWRW9yfN4JxdlOAc2OARbVc3JFGhkSm4NifGC1ibn4RrchGiWJVkKzuaPGxuWjeiNmNWLONZa4RrWddNMHtbEHOsjrYvpNHu0ugnbVOGtUsLmGrbFncEfUh)ap1a5uixIg0GVgjxarGxH7XpWdfwg8tKcqUAKGhFviZOasbn4Rr7gqe4XxfYmkGuWddNMHtbEDL5RLcUGZzi1EeJuYxfYmkvBJQ7cAGBjsUYnsPjUP69s1wBpvBJQ7cAGBzplo1EcDyQMaQgxIo1ZIbVc3JFGNa7qmsqd(sI9aIap(QqMrbKcErbNqGCYCcxIEodGVgbpmCAgof41ZItTNqhMQ3lvx4E8tkWoeJuIlrdErbNCLkzaJc(Ae8kCp(bEQbYPqUenObFjXiGiWJVkKzuaPGhgondNc8crLsI9vik6XpjQJ4aVc3JFGNAGCOYzqd(scjaIaVLB1CgapJGxH7XpWtGDigj4XxfYmkGuqdAWZeYyFfQgqe4RrarGxH7XpWRG4640CnNZmUbp(QqMrbKcAWxsaebE8vHmJcif8WWPz4uGxiQuYqUiSZzifkiCyOe1rCGxH7XpWlKlc7CgsHcchgcAWxRbebEfUh)aptVh)ap(QqMrbKcAWx7aqe4v4E8d8mTa9qUen4XxfYmkGuqdAqdEwXqX4h4lj2tI92tI92H0i4HOG3CgeGh5SmDyZOunjuDH7XpQopIwiPFaptORMmdE7JQTtdKPAcvzGPF2hvtAjyuQ2vkQMCWwOAcppNGQnHJdN2IK(zFunHQGyKuT1g)r1Kypj2t)q)u4E8tinHm2xHQ3kiUoonxZ5mJB6Nc3JFcPjKX(ku9wixe25mKcfeom83O2crLsgYfHDodPqbHddLOoIJ(PW94NqAczSVcvVz694h9tH7XpH0eYyFfQEZ0c0d5s00p0pfUh)eeVrg2JxZqHjNZ0pfUh)eeVrgmECYvjthbd)nQnS7zuhXjX(kef94NeYfQf6Nc3JFcI3iBXlhAj5QuoIh0ekKRL43O2WUNrDeNe7Rqu0JFsixOwOFkCp(jiEJSOGttZlXVrTfIkLe7Rqu0JFsuhXr)u4E8tq8gzlUzh(BuB)TNUY81sy84KRsMocgk5RczgD3UquPKW4XjxLmDemugn)32Fy3ZOoItI9vik6XpjKlul72HDpJ6ioj2xHOOh)KqEvZjiyZo2))0pfUh)eeVrg2xHOOh)(ffCcbYjZjCj65mSz8xuWjxPsgWOBg)nQT)2dle8Hz5Ixo0sYvPCepOjuixlHCveIoC3UquPKlE5qljxLYr8GMqHCTeYO5UDy3ZOoItU4LdTKCvkhXdAcfY1siH8QMtqGrJ7)FB)TNUY81Yf3SdL8vHmJUBh29mQJ4KlUzhkH8QMt8p9tH7XpbXBKffCAAE97QfVH0IjdBKqUqtiGJOraltXVrTfIkLe7Rqu0JFYOPTc3JFs1a5uixIwIrwqdSyZEBfUh)KQbYPqUeTeYyKf0aN6zXeyaJkxfHM(zFuDH7XpbXBKH0IjdBKqUqtiGJOraltXVrTfIkLe7Rqu0JFYOPnS7zuhXjvdKtHCjAjgzbnWIn7T9NjKTsAuQgiNc5s0eBczRKKivdKtHCjAInHSvsRLQbYPqUenbBK8p9tH7XpbXBKbJhNCvY0rWWFJAtfZ5eKXilObo1ZI3lj0p7JQlCp(jiEJmy84KRsMocg(BuByKf0alskyH7XVktWMrPDVFB4s07TNfNApHom9tH7XpbXBKzI05Bi0jvUwS43O2WilObwKuWc3JFvMGnsK2n9tH7XpbXBKPY1IfnCip)BuB7PRmFTuLRfNmRgJuYxfYmQT)crLsI9vik6Xpz00wH7XkoXhVgwqWg5UBxiQusSVcrrp(jrDeNTc3JvCIpEnSGGT9)VTquPKi9ojAixKxgnPFkCp(jiEJmvUwSOHd55FJARRmFTuLRfNmRgJuYxfYmQT)crLsI9vik6Xpz00wH7XkoXhVgwqWM172fIkLe7Rqu0JFsuhXzRW9yfN4JxdliyJK)TfIkLeP3jrd5I8YOj9Z(OAYrr1es(kef94hv7qQMqiEmv7kQMW4iyivpcQghHq(6SfQ(8MQlCpwX)O6qSPAetot1bMQlRQjxHmt1bw5qMQBKmvtySaDCUelQoevkQgHhZOuDplMQ9y)JQRdLQT4rQ2VSfQgzzft1(XuTOlm5PAxr1eglqhNlX6hvBXJuTaPhZOunspJs1tt1XRNmv3izQMqYxHOOh)OAhs1ecXJPAxr1eghbdP6rq1rtj9tH7XpbXBKzAb6HCj6FJAlevkPPfOJZLyjJM2(levkj2xHOOh)KqEvZjiievkPPfOJZLyjH8QMtSBxiQusSVcrrp(jrDeNnS7zuhXjX(kef94NeYRAobbHOsjnTaDCUeljKx1CcIT(FB)fIkLegpo5QKPJGHsiVQ5eeeIkL00c0X5sSKqEvZj2TBpDL5RLW4XjxLmDemuYxfYm6UDDL5RLW4XjxLmDemuYxfYmQTquPKW4XjxLmDemuI6ioBy3ZOoItcJhNCvY0rWqjKx1CcccrLsAAb64CjwsiVQ5eeB9)0pfUh)eeVrMPfOhYLO)nQTquPKi9ojAixKxgnPFkCp(jiEJS8y1CgsbFf(nQTc3JvCIpEnSGGnRT1ZItTNqhMGnYL(PW94NG4nYqHLb)ePaKRg5VrTfIkLe7Rqu0JFYOPTquPKyFfIIE8tc5vnNyVgPFkCp(jiEJmuyzWprka5Qr(BuBfUhR4eF8AybbBwt)u4E8tq8gzQbYPqUe9VOGtiqozoHlrpNHnJ)Ico5kvYagDZ4VrTfIkLejx9Cgsrtz0K(PW94NG4nYqHLb)ePaKRgj9tH7XpbXBKjWoeJ83O26kZxlfCbNZqQ9igPKVkKzuBDbnWTejx5gP0e371A7T1f0a3YEwCQ9e6WeGlrN6zX0pfUh)eeVrMAGCkKlr)lk4ecKtMt4s0ZzyZ4VOGtUsLmGr3m(BuB9S4u7j0H3BH7XpPa7qmsjUen9tH7XpbXBKPgihQC(3O2crLsI9vik6XpjQJ4OFkCp(jiEJmb2HyK)wUvZzyZi4jmzm4RDznObnaa]] )
    
    spec:RegisterPack( "Fire", 20200420, [[d8uJPcqiiIhrvixsPcsBse(evHsJse1PejwfejELsjZcs6wqu1Ui6xkLAykv6yIKwMiv9mQcAAufQUMsfTnisY3OkumoisLZjsfwhejL3brsvZtPQUhKAFkv5GkviwOsHhcrktuPcQlQubXgPkGpcrsLgPsfQtksf1kPk6LqKuXmfPICtLkWofP8tQcuzOkviTuQcu1trvtvPORcrQ6RufOSxr9xugmuhMYIv4XeMmQCzKnlLpdHrtvDAHvtvG8ArKztLBRODRYVLmCPYXfPslh45GMoPRRKTtv67svnEikNhsSEiQmFPk7xvNtnVzMNZukNw63n97URhp97ktVhMQhJhM5vu6OmFNjsYqqz(ZMuM3deakZ3zO4kJlVzMhwlGGY8(Q2brQT92ic1FnKIAUnmMlNPrDcG10THXuSDMFScNMoF5rMNZukNw63n97URhp97ktVhMQht6thzEBP(fiZZhtKwM3p44OlpY8CeuK59Oh7bca94DGHGEp9Oh7RAheP22BJiu)1qkQ52WyUCMg1jawt3ggtX2VNE0J3r6aH7XPFxuFC63n97(E(E6rpgP5BhccIu790JEmY)yKEi9ynMetlgxqpgyQpbES6B3JvdGGuPgtIPfJlOh3kWJDgurEijQJ7X2iCHIYJxqdbbLVNE0Jr(hJ03Xzk9yxHiepgqi1EC60seCpEhgq2ekFp9OhJ8poDQkiDpwyq9XakDxbGM0PWh3kWJrA1CSGAu3JtoKKe1hZvNhR(y)YX94qFCRap2ECdqq)hVdiLkWJfgutr(E6rpg5F8oCaTHJESDpMofGYJvFtFC)A54EmGGlN(44ES9yFdWjmO(4Duua1Wzq9XXH8iSjjFp9OhJ8pEhYzdh9yOccH(yHpjskoepUUhBpUr9FCRajbFCCpw9PhVJSJMo9yTEmG4wc6X9lqsUY4KzExavyEZmFO0eYCvFwhikqOOK3mNwQ5nZ80zdhXL3iZBcnQlZRbhb1cmzIIJqwMxacLaHL59AGWgosQXKyAXe1CSGAu3J37XEnqydhjRJTGetS0Q1Y8NnPmVgCeulWKjkoczznNw6ZBM5PZgoIlVrM3eAuxMxGIWvkOUqWgodQzEbiucewM3RbcB4iPgtIPftuZXcQrDpEVh71aHnCKSo2csmXsRwlZtTgju2ztkZlqr4kfuxiydNb1SM1mVOMJfuJ6yD(gKYBMtl18MzE6SHJ4YBK5fGqjqyz(XQ1KIAowqnQtYv9VmVj0OUmVlq4RqMh0IdXKonR50sFEZmpD2WrC5nY8cqOeiSm)y1AsrnhlOg1j5Q(xM3eAuxMFyiyvJPGqKemR508W8MzE6SHJ4YBK5fGqjqyzEtOHxIrhndc(49ECQpoXJhRwtkQ5yb1Oojx1)Y8MqJ6Y8UWBCiyJAoYAonpEEZmVj0OUm)WvfhRAm1Ny0rtuY80zdhXL3iR502zEZmVj0OUm)KMfafw1yULi4yCaYMWmpD2WrC5nYAonKQ8MzEtOrDz((fWX5LIJbiyD2jOmpD2WrC5nYAonpM8MzE6SHJ4YBK5xqI13pCetyqnoe50snZlaHsGWY8cFdGGGpEp0po1hN4Xj)4KFSj0OozlaeB4mOkf(gabbznGj0OoZ94TECYpESAnPOMJfuJ6KaAAXbFmY)4XQ1KdNbvcWMgujGKBbmnQ7XP84DOpwuLJR6FYwai2WzqvYTaMg19yK)Xj)4XQ1KIAowqnQtcOPfh8XP84DOpo5hpwTMC4mOsa20GkbKClGPrDpg5F8UYD(4uECkpEp0pE3h3R3JrYJnKJaHsYHZGkbytdQeqsNnCe3J717Xi5XQ5OtLnNnjwDs6SHJ4ECVEpESAnPOMJfuJ6KaAAXbF8(OF8y1AYHZGkbytdQeqYTaMg194E9E8y1AYHZGkbytdQeqcOPfh8X7)4DL78X969ykDxrxhXj9rPJaQpGmowFqa1(aRd(4epwuLJR6FsFu6iG6diJJ1heqTpW6GmpC3Dt1JNEjGMwCWhV)J35Jt5XjE8y1AsrnhlOg1jxDpoXJt(Xi5XMqJ6Kqrbe(sczKyPXH4XjEmsESj0OozhkGA4mOkJJ1CbcF9XjE8y1AsFY04qWwDYv3J717XMqJ6Kqrbe(sczKyPXH4XjE8y1As)szqfqwssUQ)94epo5hpwTM0NmnoeSvNKR6FpUxVhBihbcLKdNbvcWMgujGKoB4iUhNYJ717XgYrGqj5WzqLaSPbvciPZgoI7XjESAo6uzZztIvNKoB4iUhN4XMqJ6KDOaQHZGQmowZfi81hN4XJvRj9jtJdbB1j5Q(3Jt84XQ1K(LYGkGSKKCv)7XPK5xqIvTgdHGlNwQzEtOrDz(wai2WzqnR50q6YBM5PZgoIlVrMxacLaHL5hRwtkQ5yb1Oojx1)Y8MqJ6Y8G1rSQX6Q(eiR50sh5nZ80zdhXL3iZVGeRVF4iMWGACiYPLAM3eAuxMVfaInCguZ8cqOeiSmVHCeiusoCgujaBAqLas6SHJ4ECIhN8JjiKobjN0SaOWQgZTebhJdq2ekNMhubECVEpgjpMGq6eKCsZcGcRAm3seCmoaztOCgxbECkpoXJvZrNkNKsfqsNnCe3Jt8y1C0PYMZMeRojD2WrCpoXJhRwtoCgujaBAqLasUQ)94epo5hRMJovcwhXQgRR6tajD2WrCpoXJnHg1jbRJyvJ1v9jGKqgjwACiECIhBcnQtcwhXQgRR6tajHmsSuIbOPfh8X7)4DLivpUxVhN8J9AGWgosQXKyAXe1CSGAu3J3h9J39X9694XQ1KIAowqnQtU6ECkpoXJrYJvZrNkbRJyvJ1v9jGKoB4iUhN4Xi5XMqJ6KDOaQHZGQmowZfi81hN4Xi5XMqJ6KTaqdZ5KXXAUaHV(4uYAoTu3nVzMNoB4iU8gzEtOrDzEH5CmtOrDmxa1mVlGk7SjL5nHgEjMAo6uywZPLAQ5nZ80zdhXL3iZVGeRVF4iMWGACiYPLAMxacLaHL5t(Xj)ytOrDYjPubKXXAUaHV(4ep2eAuNCskvazCSMlq4RmanT4GpEF0pEx5oFCkpUxVhBcnQtojLkGmowZfi81h3R3JjiKobjN0SaOWQgZTebhJdq2ekNMhubECVEpESAnPFPmOciljjGmH(4E9ESj0OojuuaHVKqgjwACiECIhBcnQtcffq4ljKrILsmanT4GpE)hVRCNpUxVhBcnQt2HcOgodQsczKyPXH4XjESj0OozhkGA4mOkjKrILsmanT4GpE)hVRCNpoLhN4Xj)4XQ1KG1rSQX6Q(eqU6ECVEpgjpwnhDQeSoIvnwx1Nas6SHJ4ECkz(fKyvRXqi4YPLAM3eAuxMxuZXcQrDznNwQPpVzM3eAuxMVR0OUmpD2WrC5nYAoTu9W8MzEtOrDz(HRkowBbqjZtNnCexEJSMtlvpEEZmVj0OUm)GaqcKuCiY80zdhXL3iR50sDN5nZ8MqJ6Y8TaqdxvCzE6SHJ4YBK1CAPIuL3mZBcnQlZBNGGkWCmH5CzE6SHJ4YBK1CAP6XK3mZtNnCexEJmVaekbclZN8Jt(XQ5OtLnNnjwNPcFjD2WrCpoXJnHgEjgD0mi4J37XP)XP84E9ESj0WlXOJMbbF8EpgP6XP84epESAnPFPmOciljjGmH(4epgjp2qocekjhodQeGnnOsajD2WrCzEtOrDz(MZMeubrsuwZPLksxEZmpD2WrC5nY8cqOeiSm)y1AYouaLWzWPeqMqFCIhpwTMuuZXcQrDsanT4GpEVhlmOY0yszEtOrDz(oua1WzqnR50snDK3mZtNnCexEJmVaekbclZpwTM0VugubKLKeqMqZ8MqJ6Y8DOaQHZGAwZPL(DZBM5nHg1L578l6cKXAoBsWmpD2WrC5nYAoT0NAEZmpD2WrC5nY8cqOeiSm)y1AsrnhlOg1jb00Id(49ESWGktJj94epESAnPOMJfuJ6KRUh3R3JhRwtkQ5yb1Oojx1)ECIhlQYXv9pPOMJfuJ6KaAAXbF8(pwyqLPXKY8MqJ6Y8qrbe(znNw6tFEZmpD2WrC5nY8cqOeiSm)y1AsrnhlOg1jb00Id(49FmcbNCAi7XjESj0WlXOJMbbF8Epo1mVj0OUmVl8ghc2OMJSMtl9EyEZmpD2WrC5nY8cqOeiSm)y1AsrnhlOg1jb00Id(49FmcbNCAi7XjE8y1AsrnhlOg1jxDzEtOrDzEoGHOoiBait9ZAoT07XZBM5PZgoIlVrMxacLaHL5vdGGuPpzo1x2j0hVp6h7H7(4epwnhDQesgioemTwcFjD2WrCzEtOrDzEOOac)SM1mVj0WlXuZrNcZBMtl18MzE6SHJ4YBK5fGqjqyzEtOHxIrhndc(49ECQpoXJhRwtkQ5yb1Oojx1)ECIhN8J9AGWgosQXKyAXe1CSGAu3J37XIQCCv)t6cVXHGnQ5qYTaMg194E9ESxde2WrsnMetlMOMJfuJ6E8(OF8UpoLmVj0OUmVl8ghc2OMJSMtl95nZ80zdhXL3iZlaHsGWY8Enqydhj1ysmTyIAowqnQ7X7J(X7(4E9ECYpESAnjyDeRASUQpbKRUh3R3Jfv54Q(NeSoIvnwx1NasanT4GpEVhRXKyAX4c6XjESj0OojyDeRASUQpbKcFdGGGpE)hN6J717Xi5XQ5OtLG1rSQX6Q(eqsNnCe3Jt5XjECYpwuLJR6FYjPubKClGPrDpE)h71aHnCKuJjX0IjQ5yb1OUh3R3J1ysmTyCb949FSxde2WrsnMetlMOMJfuJ6ECkzEtOrDz(jPubYAonpmVzMNoB4iU8gzEbiucewMxnhDQ0CeYGkWGiNbzTfafjD2WrCpoXJt(XJvRjf1CSGAuNKR6FpoXJrYJhRwt6xkdQaYsscitOpUxVhpwTMuuZXcQrDYv3Jt8ytOrDYwai2Wzqvk8nacc(49FSj0OozlaeB4mOkNgYycFdGGGpoXJrYJhRwt6xkdQaYsscitOpoLmVj0OUmphWquhKnaKP(znRz(qPjK5hi8zDGOaHIsEZCAPM3mZtNnCexEJmVaekbclZ71aHnCKuJjX0IjQ5yb1OUhVp6hVBM3eAuxMxyohZeAuhZfqnZ7cOYoBsz(qPjKjQ5yb1OUSMtl95nZ8MqJ6Y8liXcLMWmpD2WrC5nYAonpmVzMNoB4iU8gzEtOrDz(PDrJGAXQgBAChbHzEbiucewMhjpMs3v01rCsd5G(gWGSwDkRASUQpbECIh71aHnCKuJjX0IjQ5yb1OUhV)Jr6Y8NnPm)0UOrqTyvJnnUJGWSMtZJN3mZtNnCexEJmVj0OUmVHCqFdyqwRoLvnwx1NazEbiucewM3RbcB4iPgtIPftuZXcQrDpEF0pENpERhN6oFms5XEnqydhjB1PmUAnCeRo2csz(ZMuM3qoOVbmiRvNYQgRR6tGSMtBN5nZ80zdhXL3iZBcnQlZdkvawqL4yERIRkgx5CzEbiucewM3RbcB4iPgtIPftuZXcQrDpEVh71aHnCKSo2csmXsRwlZF2KY8GsfGfujoM3Q4QIXvoxwZPHuL3mZtNnCexEJmVj0OUmVLURORu6u2zlnClyMxacLaHL59AGWgosQXKyAXe1CSGAu3J37XEnqydhjRJTGetS0Q1Y8NnPmVLURORu6u2zlnClywZP5XK3mZtNnCexEJmVj0OUmp0p8saMx6QjdqUqK5fGqjqyzEVgiSHJKAmjMwmrnhlOg1949ESxde2WrY6yliXelTATm)ztkZd9dVeG5LUAYaKleznNgsxEZmpD2WrC5nY8MqJ6Y8Tcmcoo6y1agCHDmHZ6N5fGqjqyzEVgiSHJKAmjMwmrnhlOg1949ESxde2WrY6yliXelTATm)ztkZ3kWi44OJvdyWf2XeoRFwZPLoYBM5PZgoIlVrM3eAuxM33aZ6cbJJMMsGWCbYrGmp1AKqzNnPmVVbM1fcghnnLaH5cKJaznNwQ7M3mZtNnCexEJmVj0OUm)0CTcmjoMpbmhhK5ie9bwhmZlaHsGWY8Enqydhj1ysmTyIAowqnQ7X7H(X7CNpoXJhRwtkQ5yb1Oojx1)ECIh71aHnCKuJjX0IjQ5yb1OUhV3J9AGWgoswhBbjMyPvRL5pBsz(P5AfysCmFcyooiZri6dSoywZPLAQ5nZ80zdhXL3iZBcnQlZBNiOtzjDLYQgRFa5QzMxacLaHL59AGWgosQXKyAXe1CSGAu3J3d9J35oFCIhpwTMuuZXcQrDsUQ)94ep2RbcB4iPgtIPftuZXcQrDpEVh71aHnCKSo2csmXsRwlZF2KY82jc6uwsxPSQX6hqUAM1CAPM(8MzE6SHJ4YBK5nHg1L5pAbmhdIYzDqIrNVDccK5fGqjqyzEVgiSHJKAmjMwmrnhlOg1949q)yp(oFCIhpwTMuuZXcQrDsUQ)94ep2RbcB4iPgtIPftuZXcQrDpEVh71aHnCKSo2csmXsRwlZF2KY8hTaMJbr5SoiXOZ3obbYAwZ8CuZwonVzoTuZBM5nHg1L5f16uca7iNlZtNnCexEJSMtl95nZ80zdhXL3iZxDzEiPzEtOrDzEVgiSHJY8En3IY8Q5OtLTaqq1akbK0zdhX9yKYJBbGGQbucib00Id(4TECYpwuLJR6FsrnhlOg1jb00Id(yKYJt(XP(yK)XEnqydhjtkooxCiyaIBj0OUhJuESAo6uzsXX5IdHKoB4iUhNYJr(hBcnQtcwhXQgRR6tajHmsSuIPXKEms5XQ5OtLG1rSQX6Q(eqsNnCe3Jt5XiLhJKhlQYXv9pPOMJfuJ6KaY4q5XiLhpwTMuuZXcQrDsUQ)L59Aa2ztkZRXKyAXe1CSGAuxwZP5H5nZ80zdhXL3iZxDz(PHSmVj0OUmVxde2WrzEVMBrzErvoUQ)jN0SaOWQgZTebhJdq2ekb00IdM5fGqjqyzEccPtqYjnlakSQXClrWX4aKnHYP5bvGhN4XJvRjN0SaOWQgZTebhJdq2ek5Q(3Jt8yrvoUQ)jN0SaOWQgZTebhJdq2ekb00Id(yK)XEnqydhj1ysmTyIAowqnQ7X7J(XEnqydhj9lhhtuZXcQrDm1hqq)YXL59Aa2ztkZRXKyAXe1CSGAuxwZP5XZBM5PZgoIlVrMV6Y8tdzzEtOrDzEVgiSHJY8En3IY8IQCCv)t2VaooVuCmabRZobjb00IdM5fGqjqyzEccPtqY(fWX5LIJbiyD2ji508GkWJt84XQ1K9lGJZlfhdqW6StqsUQ)94epwuLJR6FY(fWX5LIJbiyD2jijGMwCWhJ8p2RbcB4iPgtIPftuZXcQrDpEF0p2RbcB4iPF54yIAowqnQJP(ac6xoUmVxdWoBszEnMetlMOMJfuJ6YAoTDM3mZtNnCexEJmVj0OUmVWCoMj0OoMlGAM3fqLD2KY8HstiZpq4Z6arbcfLSMtdPkVzMNoB4iU8gzEbiucewMFSAnPOMJfuJ6KCv)lZBcnQlZpdaOaSyAiOSMtZJjVzMNoB4iU8gzEbiucewMp5h71aHnCKuJjX0IjQ5yb1OUhV)JtD3h3R3J1ysmTyCb949FSxde2WrsnMetlMOMJfuJ6ECkzEtOrDzEeldWf2XQgZqocuQFwZPH0L3mZBcnQlZlQtqNcmL4ynNnPmpD2WrC5nYAoT0rEZmVj0OUmpGSU4qWAoBsWmpD2WrC5nYAoTu3nVzM3eAuxMVvIfK4ygYrGqj2GSzMNoB4iU8gznNwQPM3mZBcnQlZ3TardL4qWgodQzE6SHJ4YBK1CAPM(8MzEtOrDzEq015iwCmyNjOmpD2WrC5nYAoTu9W8MzEtOrDzE1NyRBuRJJ1kGGY80zdhXL3iR50s1JN3mZtNnCexEJmVaekbclZpwTMuuZXcQrDsUQ)94epo5h71aHnCKuJjX0IjQ5yb1OUhV3JBlNJbiHVbqqmnM0J717XEnqydhj1ysmTyIAowqnQ7X79ynMetlgxqpoLmVj0OUmpyDeRASUQpbYAoTu3zEZmpD2WrC5nY8cqOeiSmVxde2WrsnMetlMOMJfuJ6E8(OF8UzEtOrDzEH5CmtOrDmxa1mVlGk7SjL5f1CSGAuhRZ3GuwZPLksvEZmpD2WrC5nY8liX67hoIjmOghICAPM5fGqjqyz(KFmbH0ji5KMfafw1yULi4yCaYMq508GkWJ717XeesNGKtAwauyvJ5wIGJXbiBcLZ4kWJt8yd5iqOKC4mOsa20GkbK0zdhX94uECIhl8nacc(y0pEAiJj8nacc(4epgjpESAnPFPmOciljjGmH(4epgjpo5hpwTM0NmnoeSvNeqMqFCIhN8JhRwtkQ5yb1Oo5Q7XjECYp2eAuNSfaAyoNmowZfi81h3R3JnHg1j7qbudNbvzCSMlq4RpUxVhBcnQtcffq4ljKrILghIhNYJ717XQbqqQ0NmN6l7e6J3h9J9WDFCIhBcnQtcffq4ljKrILghIhNYJt5XjEmsECYpgjpESAnPpzACiyRojGmH(4epgjpESAnPFPmOciljjGmH(4epESAnPOMJfuJ6KCv)7XjECYp2eAuNSfaAyoNmowZfi81h3R3JnHg1j7qbudNbvzCSMlq4RpoLhNsMFbjw1AmecUCAPM5nHg1L5BbGydNb1SMtlvpM8MzE6SHJ4YBK5RUmpK0mVj0OUmVxde2WrzEVMBrzE1C0PsW6iw1yDvFciPZgoI7XjESOkhx1)KG1rSQX6Q(eqcOPfh8X7)yrvoUQ)jBbGydNbvzB5Cmaj8nacIPXKECIhN8J9AGWgosQXKyAXe1CSGAu3J37XMqJ6KG1rSQX6Q(eq2wohdqcFdGGyAmPhNYJt84KFSOkhx1)KG1rSQX6Q(eqcOPfh8X7)ynMetlgxqpUxVhBcnQtcwhXQgRR6taPW3aii4J37X7(4uECVEp2RbcB4iPgtIPftuZXcQrDpE)hBcnQt2caXgodQY2Y5yas4BaeetJj94ep2RbcB4iPgtIPftuZXcQrDpE)hRXKyAX4ckZ71aSZMuMVfaInCguzDv5IdrwZPLksxEZmpD2WrC5nY8cqOeiSm)y1AsW6iw1yDvFcixDpoXJt(XEnqydhj1ysmTyIAowqnQ7X794DFCkzEOccHMtl1mVj0OUmVWCoMj0OoMlGAM3fqLD2KY8GQJ15BqkR50snDK3mZtNnCexEJmF1L5HKM5nHg1L59AGWgokZ71ClkZRMJovcwhXQgRR6tajD2WrCpoXJfv54Q(NeSoIvnwx1NasanT4GpE)hlQYXv9pzNFrxGmwZztckBlNJbiHVbqqmnM0Jt84KFSxde2WrsnMetlMOMJfuJ6E8Ep2eAuNeSoIvnwx1NaY2Y5yas4BaeetJj94uECIhN8Jfv54Q(NeSoIvnwx1NasanT4GpE)hRXKyAX4c6X969ytOrDsW6iw1yDvFcif(gabbF8EpE3hNYJ717XEnqydhj1ysmTyIAowqnQ7X7)ytOrDYo)IUazSMZMeu2wohdqcFdGGyAmPhN4XEnqydhj1ysmTyIAowqnQ7X7)ynMetlgxqzEVgGD2KY8D(fDbYyDv5IdrwZPL(DZBM5PZgoIlVrMFbjwF)WrmHb14qKtl1mVaekbclZN8JrYJ9AGWgos2caXgodQSUQCXH4X9694XQ1KG1rSQX6Q(eqU6ECkpoXJt(XEnqydhj1ysmTyIAowqnQ7X794DFCkpoXJt(XMqdVeJoAge8X7H(XEnqydhj9nahtyqL1C2KGkisIECIhN8J1yspg5F8y1AsrnhlOg1jDguzeY6ca949ESxde2WrsoYzOWAoBsqfejrpoLhNYJt8yK84waiOAaLastOHx6XjE8y1As)szqfqwssUQ)94epo5hJKhBihbcLKdNbvcWMgujGKoB4iUh3R3JhRwtoCgujaBAqLasanT4GpE)hVRCNpoLm)csSQ1yieC50snZBcnQlZ3caXgodQznNw6tnVzMNoB4iU8gz(fKy99dhXeguJdroTuZ8cqOeiSmFlaeunGsaPj0Wl94epw4Baee8X7H(XP(4epo5hJKh71aHnCKSfaInCguzDv5IdXJ717XJvRjbRJyvJ1v9jGC194uECIhN8JrYJnKJaHsYHZGkbytdQeqsNnCe3J717XJvRjhodQeGnnOsajGMwCWhV)J3vUZhNYJt84KFmsESj0Oozla0WCojHmsS04q84epgjp2eAuNSdfqnCguLXXAUaHV(4epESAnPpzACiyRo5Q7X969ytOrDYwaOH5CsczKyPXH4XjE8y1As)szqfqwssUQ)94E9ESj0OozhkGA4mOkJJ1CbcF9XjE8y1AsFY04qWwDsUQ)94epESAnPFPmOciljjx1)ECkz(fKyvRXqi4YPLAM3eAuxMVfaInCguZAoT0N(8MzE6SHJ4YBK5fGqjqyzEVgiSHJKAmjMwmrnhlOg1949E8UzEOccHMtl1mVj0OUmVWCoMj0OoMlGAM3fqLD2KY8q1oodWXaLAAuxwZAMpuAczIAowqnQlVzoTuZBM5PZgoIlVrM)SjL5dexOrDSPHGGS2cszEtOrDz(aXfAuhBAiiiRTGuwZPL(8MzE6SHJ4YBK5nHg1L59rPJaQpGmowFqa1(aRdM5fGqjqyz(XQ1KIAowqnQtU6ECIhBcnQt2caXgodQsHVbqqWhJ(X7(4ep2eAuNSfaInCguLas4BaeetJj949EmcbNCAilZF2KY8(O0ra1hqghRpiGAFG1bZAonpmVzMNoB4iU8gz(ZMuMFAx0iOwSQXMg3rqyM3eAuxMFAx0iOwSQXMg3rqywZP5XZBM5hRwJD2KY8t7Igb1Ivn204occzcFRtjaRokZlaHsGWY8JvRjf1CSGAuNC194E9ESj0Oo5KuQaY4ynxGWxFCIhBcnQtojLkGmowZfi8vgGMwCWhVp6hVRCNz(fKyvRXqi4YPLAM3eAuxMxyNGCSXQ1Y80zdhXL3iR502zEZmpD2WrC5nY8NnPmVHClaP(fKbJdbXX6CRPHGY8liXQwJHqWLtl1mVj0OUmVHClaP(fKbJdbXX6CRPHGY8cqOeiSm)y1AsrnhlOg1jxDpUxVhBcnQtojLkGmowZfi81hN4XMqJ6KtsPciJJ1CbcFLbOPfh8X7J(X7k3zwZPHuL3mZtNnCexEJmVj0OUmpcNXfMwaiByCiOm)csSQ1yieC50snZlaHsGWY8JvRjf1CSGAuNC194E9ESj0Oo5KuQaY4ynxGWxFCIhBcnQtojLkGmowZfi8vgGMwCWhVp6hVRCNzEQ1iHYoBszEeoJlmTaq2W4qqznNMhtEZmpD2WrC5nY8MqJ6Y8iCgxyAbGSjXzoxuxMFbjw1AmecUCAPM5fGqjqyz(XQ1KIAowqnQtU6ECVEp2eAuNCskvazCSMlq4RpoXJnHg1jNKsfqghR5ce(kdqtlo4J3h9J3vUZmp1AKqzNnPmpcNXfMwaiBsCMZf1L1CAiD5nZ80zdhXL3iZF2KY8dZrTaqSbWoHFMFbjw1AmecUCAPM5nHg1L5hMJAbGydGDc)mVaekbclZpwTMuuZXcQrDYv3J717XMqJ6KtsPciJJ1CbcF9XjESj0Oo5KuQaY4ynxGWxzaAAXbF8(OF8UYDM1CAPJ8MzE6SHJ4YBK5pBszEOFjsAekbGSMDiY8liXQwJHqWLtl1mVj0OUmp0VejncLaqwZoezEbiucewMFSAnPOMJfuJ6KRUh3R3JnHg1jNKsfqghR5ce(6Jt8ytOrDYjPubKXXAUaHVYa00Id(49r)4DL7mR50sD38MzE6SHJ4YBK5pBszEf5SJGSHbsc2fhbZ8liXQwJHqWLtl1mVj0OUmVIC2rq2Wajb7IJGzEbiucewMFSAnPOMJfuJ6KRUh3R3JnHg1jNKsfqghR5ce(6Jt8ytOrDYjPubKXXAUaHVYa00Id(49r)4DL7mR50sn18MzE6SHJ4YBK5pBszE7ebDklPRuw1y9dixnZ8liXQwJHqWLtl1mVj0OUmVDIGoLL0vkRAS(bKRMzEbiucewMFSAnPOMJfuJ6KRUh3R3JnHg1jNKsfqghR5ce(6Jt8ytOrDYjPubKXXAUaHVYa00Id(49r)4DL7mR50sn95nZ80zdhXL3iZF2KY8hTaMJbr5SoiXOZ3obbY8liXQwJHqWLtl1mVj0OUm)rlG5yquoRdsm68TtqGmVaekbclZpwTMuuZXcQrDYv3J717XMqJ6KtsPciJJ1CbcF9XjESj0Oo5KuQaY4ynxGWxzaAAXbF8(OF8UYDM1CAP6H5nZ80zdhXL3iZF2KY8tZ1kWK4y(eWCCqMJq0hyDWm)csSQ1yieC50snZBcnQlZpnxRatIJ5taZXbzocrFG1bZ8cqOeiSm)y1AsrnhlOg1jxDpUxVhBcnQtojLkGmowZfi81hN4XMqJ6KtsPciJJ1CbcFLbOPfh8X7J(X7k3zwZAMVdqIAomnVzoTuZBM5nHg1L5nGWoIfNsohj0mpD2WrC5nYAoT0N3mZtNnCexEJmF1L5HKM5nHg1L59AGWgokZ71ClkZtP7k66io50UOrqTyvJnnUJGWh3R3JP0DfDDeNeHZ4ctlaKnmoe0J717Xu6UIUoItIWzCHPfaYMeN5CrDpUxVhtP7k66iozG4cnQJnneeK1wq6X969ykDxrxhXjvKZocYggijyxCe8X969ykDxrxhXjnKBbi1VGmyCiiowNBnne0J717Xu6UIUoItANiOtzjDLYQgRFa5Q5J717Xu6UIUoItc9lrsJqjaK1SdXJ717Xu6UIUoItE0cyogeLZ6GeJoF7ee4X969ykDxrxhXjhMJAbGydGDc)mVxdWoBszErnhlOg1XQJTGuwZP5H5nZ80zdhXL3iZxDzEiPzEtOrDzEVgiSHJY8En3IY8u6UIUoItAih03agK1QtzvJ1v9jWJt8yVgiSHJKIAowqnQJvhBbPmVxdWoBsz(wDkJRwdhXQJTGuwZP5XZBM5PZgoIlVrMV6Y8qsZ8MqJ6Y8EnqydhL59AUfL5t)UpgP84KFSxde2WrsrnhlOg1XQJTG0Jt8yK8yVgiSHJKT6ugxTgoIvhBbPhNYJ36XE8DFms5Xj)yVgiSHJKT6ugxTgoIvhBbPhNYJ36XPFNpgP84KFmLURORJ4KgYb9nGbzT6uw1yDvFc84epgjp2RbcB4izRoLXvRHJy1Xwq6XP84TEms3Jrkpo5htP7k66io50UOrqTyvJnnUJGWhN4Xi5XEnqydhjB1PmUAnCeRo2cspoLmVxdWoBsz(6yliXelTATSMtBN5nZ80zdhXL3iZxDzEabjnZBcnQlZ71aHnCuM3RbyNnPmVF54yIAowqnQJP(ac6xoUmph1SLtZ8PF3SMtdPkVzMNoB4iU8gz(QlZdjnZBcnQlZ71aHnCuM3R5wuMp9pgP8y1C0PYMZMeRZuHVKoB4iUhV1JthPJhJuEmsESAo6uzZztI1zQWxsNnCexMxacLaHL59AGWgos6xkdQaYsI1C2KGkisIEm6hVBM3RbyNnPmVFPmOciljwZztcQGijkR508yYBM5PZgoIlVrMV6Y8qsZ8MqJ6Y8EnqydhL59AUfL59WhJuESAo6uzZztI1zQWxsNnCe3J36XPJ0XJrkpgjpwnhDQS5SjX6mv4lPZgoIlZlaHsGWY8Enqydhj9nahtyqL1C2KGkisIEm6hVBM3RbyNnPmVVb4ycdQSMZMeubrsuwZPH0L3mZtNnCexEJmF1L5beK0mVj0OUmVxde2WrzEVgGD2KY8CKZqH1C2KGkisIY8CuZwonZN(DM1CAPJ8MzE6SHJ4YBK5RUmpGGKM5nHg1L59AGWgokZ71aSZMuMpP44CXHGbiULqJ6Y8CuZwonZVRm9znNwQ7M3mZtNnCexEJm)ztkZBih03agK1QtzvJ1v9jqM3eAuxM3qoOVbmiRvNYQgRR6tGSMtl1uZBM5nHg1L5NbauawmneuMNoB4iU8gznNwQPpVzM3eAuxMVR0OUmpD2WrC5nYAoTu9W8MzEtOrDz(oua1WzqnZtNnCexEJSM1mpuTJZaCmqPMg1L3mNwQ5nZ80zdhXL3iZlaHsGWY8j)ytOHxIrhndc(49q)yVgiSHJK(LYGkGSKynNnjOcIKOhN4Xj)ynM0Jr(hpwTMuuZXcQrDsNbvgHSUaqpEVh71aHnCKKJCgkSMZMeubrs0Jt5XP84epESAnPFPmOciljjGmHM5nHg1L5BoBsqfejrznNw6ZBM5PZgoIlVrMxacLaHL5hRwt6xkdQaYsscitOpoXJhRwt6xkdQaYsscOPfh8X7)ytOrDYwaOH5CsczKyPetJjL5nHg1L57qbudNb1SMtZdZBM5PZgoIlVrMxacLaHL5hRwt6xkdQaYsscitOpoXJt(XDaYldHGtMQSfaAyo3J717XTaqq1akbKMqdV0J717XMqJ6KDOaQHZGQmowZfi81hNsM3eAuxMVdfqnCguZAonpEEZmpD2WrC5nY8cqOeiSmVW3aii4J3d9J9WhN4XMqdVeJoAge8X7940)4epgjp2RbcB4izNFrxGmwxvU4qK5nHg1L578l6cKXAoBsWSMtBN5nZ80zdhXL3iZlaHsGWY8JvRj9lLbvazjjbKj0hN4XQbqqQ0NmN6l7e6J3h9J9WDFCIhRMJovcjdehcMwlHVKoB4iUmVj0OUmFhkGA4mOM1CAiv5nZ80zdhXL3iZlaHsGWY8JvRj7qbucNbNsazc9XjESWGktJj949F8y1AYouaLWzWPeqtloyM3eAuxMVdfqnCguZAonpM8MzE6SHJ4YBK5xqI13pCetyqnoe50snZlaHsGWY8j)4XQ1KG1rSQX6Q(eqYv9VhN4Xi5XTaqq1akbKMqdV0Jt5XjEmsESxde2WrYwai2WzqL1vLloepoXJt(Xj)4KFSj0Oozla0WCojHmsS04q84E9ESj0OozhkGA4mOkjKrILghIhNYJt84XQ1K(KPXHGT6KaYe6Jt5X9694KFSAo6ujKmqCiyATe(s6SHJ4ECIhRgabPsFYCQVStOpEF0p2d39XjECYpESAnPpzACiyRojGmH(4epgjp2eAuNekkGWxsiJelnoepUxVhJKhpwTM0VugubKLKeqMqFCIhJKhpwTM0NmnoeSvNeqMqFCIhBcnQtcffq4ljKrILghIhN4Xi5XMqJ6KDOaQHZGQmowZfi81hN4Xi5XMqJ6KTaqdZ5KXXAUaHV(4uECkpoLm)csSQ1yieC50snZBcnQlZ3caXgodQznNgsxEZmpD2WrC5nY8cqOeiSmFYpESAnPpzACiyRojGmH(4E9ECYpgjpESAnPFPmOciljjGmH(4epo5hBcnQt2caXgodQsHVbqqWhV3J39X969y1C0PsizG4qW0Aj8L0zdhX94epwnacsL(K5uFzNqF8(OFShU7Jt5XP84uECIhJKh71aHnCKSZVOlqgRRkxCiY8MqJ6Y8D(fDbYynNnjywZPLoYBM5PZgoIlVrM3eAuxMxyohZeAuhZfqnZ7cOYoBszEtOHxIPMJofM1CAPUBEZmpD2WrC5nY8cqOeiSmVj0WlXOJMbbF8Epo1mVj0OUmphWquhKnaKP(znNwQPM3mZtNnCexEJmVj0OUmVWCoMj0OoMlGAM3fqLD2KY8HstiZv9zDGOaHIswZPLA6ZBM5PZgoIlVrMxacLaHL5vdGGuPpzo1x2j0hVp6h7H7(4epwnhDQesgioemTwcFjD2WrCzEtOrDzEOOac)SMtlvpmVzMNoB4iU8gzEbiucewM3eA4Ly0rZGGpEp0p2RbcB4iPVb4ycdQSMZMeubrs0Jt84KFSgt6Xi)JhRwtkQ5yb1OoPZGkJqwxaOhV3J9AGWgosYrodfwZztcQGij6XPK5nHg1L5BoBsqfejrznNwQE88MzEtOrDz(waOH5CzE6SHJ4YBK1CAPUZ8MzEtOrDzEOOac)mpD2WrC5nYAwZ8GQJ15BqkVzoTuZBM5nHg1L5bRJyvJ1v9jqMNoB4iU8gznNw6ZBM5PZgoIlVrMxacLaHL5t(XMqdVeJoAge8X7H(XEnqydhj9lLbvazjXAoBsqfejrpoXJt(XAmPhJ8pESAnPOMJfuJ6KodQmczDbGE8Ep2RbcB4ijh5muynNnjOcIKOhNYJt5XjE8y1As)szqfqwssazcnZBcnQlZ3C2KGkisIYAonpmVzMNoB4iU8gzEbiucewMFSAnPFPmOciljjGmHM5nHg1L57qbudNb1SMtZJN3mZtNnCexEJm)csS((HJycdQXHiNwQzEbiucewMhjpo5hBcn8sm6OzqWhVh6h71aHnCK03aCmHbvwZztcQGij6XjECYpwJj9yK)XJvRjf1CSGAuN0zqLriRla0J37XEnqydhj5iNHcR5SjbvqKe94uECkpoXJrYJBbGGQbucinHgEPhN4Xj)yK84XQ1K(KPXHGT6KaYe6Jt8yK84XQ1K(LYGkGSKKaYe6Jt8yK84oa5LvTgdHGt2caXgodQpoXJt(XMqJ6KTaqSHZGQu4Baee8X7H(XP)X9694KFSj0OozNFrxGmwZztckf(gabbF8EOFCQpoXJvZrNk78l6cKXAoBsqjD2WrCpoLh3R3Jt(XQ5OtLMJqgubge5miRTaOiPZgoI7XjESOkhx1)KCadrDq2aqM6lbKXHYJt5X9694KFSAo6ujKmqCiyATe(s6SHJ4ECIhRgabPsFYCQVStOpEF0p2d39XP84uECkz(fKyvRXqi4YPLAM3eAuxMVfaInCguZAoTDM3mZtNnCexEJmVj0OUmVWCoMj0OoMlGAM3fqLD2KY8MqdVetnhDkmR50qQYBM5PZgoIlVrMxacLaHL5hRwt2HcOeodoLaYe6Jt8yHbvMgt6X7)4XQ1KDOakHZGtjGMwCWhN4XJvRjbRJyvJ1v9jGeqtlo4J37XcdQmnMuM3eAuxMVdfqnCguZAonpM8MzE6SHJ4YBK5xqI13pCetyqnoe50snZlaHsGWY8i5Xj)ytOHxIrhndc(49q)yVgiSHJK(gGJjmOYAoBsqfejrpoXJt(XAmPhJ8pESAnPOMJfuJ6KodQmczDbGE8Ep2RbcB4ijh5muynNnjOcIKOhNYJt5XjEmsEClaeunGsaPj0Wl94epo5hpwTM0NmnoeSvNeqMqFCIhN8JvdGGuPpzo1x2j0hVh6h7H7(4E9EmsESAo6ujKmqCiyATe(s6SHJ4ECkpoLm)csSQ1yieC50snZBcnQlZ3caXgodQznNgsxEZmpD2WrC5nY8liX67hoIjmOghICAPM5fGqjqyzEK84KFSj0WlXOJMbbF8EOFSxde2WrsFdWXeguznNnjOcIKOhN4Xj)ynM0Jr(hpwTMuuZXcQrDsNbvgHSUaqpEVh71aHnCKKJCgkSMZMeubrs0Jt5XP84epgjpUfacQgqjG0eA4LECIhRMJovcjdehcMwlHVKoB4iUhN4XQbqqQ0NmN6l7e6J3h9J9WDFCIhN8JhRwt6tMghc2QtcitOpoXJrYJnHg1jHIci8LeYiXsJdXJ717Xi5XJvRj9jtJdbB1jbKj0hN4Xi5XJvRj9lLbvazjjbKj0hNsMFbjw1AmecUCAPM5nHg1L5BbGydNb1SMtlDK3mZtNnCexEJmVaekbclZJKh3biVmecozQYo)IUazSMZMe8XjE8y1AsFY04qWwDsazcnZBcnQlZ35x0fiJ1C2KGznNwQ7M3mZtNnCexEJmVaekbclZRgabPsFYCQVStOpEF0p2d39XjESAo6ujKmqCiyATe(s6SHJ4Y8MqJ6Y8qrbe(znNwQPM3mZtNnCexEJmVaekbclZBcn8sm6OzqWhV3JtFM3eAuxMNdyiQdYgaYu)SMtl10N3mZtNnCexEJmVaekbclZN8JnHgEjgD0mi4J3d9J9AGWgos6BaoMWGkR5SjbvqKe94epo5hRXKEmY)4XQ1KIAowqnQt6mOYiK1fa6X79yVgiSHJKCKZqH1C2KGkisIECkpoLmVj0OUmFZztcQGijkR50s1dZBM5nHg1L5BbGgMZL5PZgoIlVrwZAwZ8EjamQlNw63n97URhF3uLPpZ33axCiGz(05zxbuI7XPJhBcnQ7XUaQq57zMh2rICAivEyMVduTWrzEp6XEGaqpEhyiO3tp6X(Q2brQT92ic1FnKIAUnmMlNPrDcG10THXuS97Ph94DKoq4EC63f1hN(Dt)UVNVNE0JrA(2HGGi1Ep9OhJ8pgPhspwJjX0IXf0JbM6tGhR(29y1aiivQXKyAX4c6XTc8yNbvKhsI64ESncxOO84f0qqq57Ph9yK)Xi9DCMsp2vicXJbesThNoTeb3J3HbKnHY3tp6Xi)JtNQcs3JfguFmGs3vaOjDk8XTc8yKwnhlOg194Kdjjr9XC15XQp2VCCpo0h3kWJTh3ae0)X7asPc8yHb1uKVNE0Jr(hVdhqB4OhB3JPtbO8y130h3VwoUhdi4YPpoUhBp23aCcdQpEhffqnCguFCCipcBsY3tp6Xi)J3HC2WrpgQGqOpw4tIKIdXJR7X2JBu)h3kqsWhh3JvF6X7i7OPtpwRhdiULGEC)cKKRmo5757Ph94DiiJelL4E8GAfGESOMdtF8Gqehu(4DeHG6u4JV6qEFdmBl3JnHg1bFCDouKVNE0JnHg1bLDasuZHPOBodM07Ph9ytOrDqzhGe1Cy6wO3Uvf37Ph9ytOrDqzhGe1Cy6wO32wiM0PMg19EAcnQdk7aKOMdt3c92gqyhXItjNJe67Pj0OoOSdqIAomDl0B71aHnCeQNnj0IAowqnQJvhBbjuRo0qsr1R5weAkDxrxhXjN2fncQfRASPXDee2RhLURORJ4KiCgxyAbGSHXHG61Js3v01rCseoJlmTaq2K4mNlQRxpkDxrxhXjdexOrDSPHGGS2cs96rP7k66ioPIC2rq2Wajb7IJG96rP7k66ioPHClaP(fKbJdbXX6CRPHG61Js3v01rCs7ebDklPRuw1y9dixn71Js3v01rCsOFjsAekbGSMDi61Js3v01rCYJwaZXGOCwhKy05BNGa96rP7k66io5WCulaeBaSt4)EAcnQdk7aKOMdt3c92EnqydhH6ztcDRoLXvRHJy1Xwqc1QdnKuu9AUfHMs3v01rCsd5G(gWGSwDkRASUQpbs41aHnCKuuZXcQrDS6yli9E6rpoDwPj8XQVPp2a0JxqI7X1sHbh94Q9yKwnhlOg19ydqp(k9XliX9yRPe4XQFaFSgt6Xr7XQpHYJ7xlh3J7w6JThRG4sI0hVGe3J7hQ)JrA1CSGAu3JR7X2JH(gGJ4ESOkhx1)KVNMqJ6GYoajQ5W0TqVTxde2WrOE2KqxhBbjMyPvRHA1HgskQEn3IqN(Drkj71aHnCKuuZXcQrDS6yliLajEnqydhjB1PmUAnCeRo2csPSLhFxKsYEnqydhjB1PmUAnCeRo2csPSv63jsjzkDxrxhXjnKd6BadYA1PSQX6Q(eibs8AGWgos2QtzC1A4iwDSfKszlKoKsYu6UIUoItoTlAeulw1ytJ7iimbs8AGWgos2QtzC1A4iwDSfKs590JEmsRMJfuJ6ECaFCDouE8csCpUFO(1sFShSc448sX9yp4jyD2jOhxGhVdOzbq5Xv7XPtlrW94Dyazt4JJ2Jd9X9dN7Xd6XMxlC2Wrp20h7idQpw9d4JN2HYJHKOoo4JhuRa0JvF6XeesNG8yHpwuLJR6FpoGpgqghkY3ttOrDqzhGe1Cy6wO32RbcB4iupBsO9lhhtuZXcQrDm1hqq)YXHA1HgqqsrLJA2YPOt)UVNE0J30pGp2RbcB4Ohd7ir0cc(y1NE8TMdc84Q9y1aiif(ytFCF)q4)4DCPpMxbKL0J9aoBsqfejrWhxlfgC0JR2JrA1CSGAu3JH(1YX94b94fK4KVNMqJ6GYoajQ5W0TqVTxde2WrOE2Kq7xkdQaYsI1C2KGkisIqT6qdjf1OH2RbcB4iPFPmOciljwZztcQGijc9UO61ClcD6rkQ5OtLnNnjwNPcFjD2WrCBLoshifKOMJov2C2KyDMk8L0zdhX9E6rpEt)a(yVgiSHJEmSJerli4JvF6X3AoiWJR2JvdGGu4Jn9X99dH)J3XgG7XindQp2d4SjbvqKebFCTuyWrpUApgPvZXcQrDpg6xlh3Jh0JxqI7Xg8XTW5iG890eAuhu2birnhMUf6T9AGWgoc1ZMeAFdWXeguznNnjOcIKiuRo0qsrnAO9AGWgos6BaoMWGkR5SjbvqKeHExu9AUfH2drkQ5OtLnNnjwNPcFjD2WrCBLoshifKOMJov2C2KyDMk8L0zdhX9E6rpgPhghIh7bC2KGkisIES1uc8yKwnhlOg194a(4YlbESWUhlSfKES9yyG4IwiStFSnR1PpUApMZMgc6XA94b9yxb1hZTOhR1JvF6XLxc0heACiEC1EC6mIlu6XQVPpUeIfa(4((09y1NEC6mIlu6XnqnFmk1c84oqmnakpgPvZXcQrDpwnacsFmSdqghu(4n9d4J9AGWgo6Xb8XliX9yTEmSJerdLhR(0JTzTo9Xv7XAmPhh3JHKOoo4JvFtF8Cb1h3zq4JTMsGhJ0Q5yb1OUhtiRlae8XdQva6XEaNnjOcIKi4J7ho3Jh0JxqI7XxbMMZHI890eAuhu2birnhMUf6T9AGWgoc1ZMeAoYzOWAoBsqfejrOYrnB5u0PFNOwDObeK03tp6XEWc1)Xi1jooxCiq9XiTAowqnQZJf(yrvoUQ)94(HZ94b9yaXTee3JhO8y7Xa74Q5JTzTof1hpw6JvF6X3AoiWJR2JfGqHpgQgqHp2lbq5X(bc)hBnLap2eA4104q8yKwnhlOg19y74Em0v9HpMR6FpwR(gGd(y1NEmDCpUApgPvZXcQrDESWhlQYXv9p5J9G5t3JNwsXH4XCKiGrDWhh3JvF6X7i7OPtO(yKwnhlOg15XcFmGMwCXH4XIQCCv)7Xb8XaIBjiUhpq5XQFaFCdycnQ7XA9ytiQ1PpUvGhJuN44CXHq(EAcnQdk7aKOMdt3c92EnqydhH6ztcDsXX5IdbdqClHg1Hkh1SLtrVRm9OwDObeK03tp6XMqJ6GYoajQ5W0TqVn8SoOFPmOAk890eAuhu2birnhMUf6TxqIfknr9SjH2qoOVbmiRvNYQgRR6tG3ttOrDqzhGe1Cy6wO3EgaqbyX0qqVNMqJ6GYoajQ5W0TqVDxPrDVNMqJ6GYoajQ5W0TqVDhkGA4mO(E(E6rpEhcYiXsjUhtEjakpwJj9y1NESj0c84a(yZRfoB4i57Pj0OoiArToLaWoY5EpnHg1b3c92EnqydhH6ztcTgtIPftuZXcQrDOwDOHKIQxZTi0Q5OtLTaqq1akbK0zdhXHuAbGGQbucib00IdUvYIQCCv)tkQ5yb1OojGMwCqKsYPI8EnqydhjtkooxCiyaIBj0OoKIAo6uzsXX5IdHKoB4iUuqEtOrDsW6iw1yDvFcijKrILsmnMesrnhDQeSoIvnwx1Nas6SHJ4sbPGervoUQ)jf1CSGAuNeqghkiLXQ1KIAowqnQtYv9V3ttOrDWTqVTxde2WrOE2KqRXKyAXe1CSGAuhQvh6PHmu9AUfHwuLJR6FYjnlakSQXClrWX4aKnHsanT4GOgn0eesNGKtAwauyvJ5wIGJXbiBcLtZdQajgRwtoPzbqHvnMBjcoghGSjuYv9VeIQCCv)toPzbqHvnMBjcoghGSjucOPfhe59AGWgosQXKyAXe1CSGAu3(O9AGWgos6xooMOMJfuJ6yQpGG(LJ790eAuhCl0B71aHnCeQNnj0AmjMwmrnhlOg1HA1HEAidvVMBrOfv54Q(NSFbCCEP4yacwNDcscOPfhe1OHMGq6eKSFbCCEP4yacwNDcsonpOcKySAnz)c448sXXaeSo7eKKR6Fjev54Q(NSFbCCEP4yacwNDcscOPfhe59AGWgosQXKyAXe1CSGAu3(O9AGWgos6xooMOMJfuJ6yQpGG(LJ790eAuhCl0BlmNJzcnQJ5cOI6ztcDO0eY8de(SoquGqr590eAuhCl0BpdaOaSyAiiuJg6XQ1KIAowqnQtYv9V3ttOrDWTqVnILb4c7yvJzihbk1h1OHozVgiSHJKAmjMwmrnhlOg1TFQ72RNgtIPfJlO99AGWgosQXKyAXe1CSGAuxkVNMqJ6GBHEBrDc6uGPehR5Sj9EAcnQdUf6TbK1fhcwZztc(EAcnQdUf6TBLybjoMHCeiuIniB(EAcnQdUf6T7wGOHsCiydNb13ttOrDWTqVni66CelogSZe07Pj0Oo4wO3w9j26g164yTciO3ttOrDWTqVnyDeRASUQpbqnAOhRwtkQ5yb1Oojx1)sKSxde2WrsnMetlMOMJfuJ62RTCogGe(gabX0ys9651aHnCKuJjX0IjQ5yb1OU90ysmTyCbLY7Pj0Oo4wO3wyohZeAuhZfqf1ZMeArnhlOg1X68niHA0q71aHnCKuJjX0IjQ5yb1OU9rV77Pj0Oo4wO3UfaInCgurDbjw1Ameco0PI6csS((HJycdQXHaDQOgn0jtqiDcsoPzbqHvnMBjcoghGSjuonpOc0RhbH0ji5KMfafw1yULi4yCaYMq5mUcKWqocekjhodQeGnnOsajD2WrCPKq4Baeee90qgt4BaeembsgRwt6xkdQaYsscitOjqsYJvRj9jtJdbB1jbKj0ejpwTMuuZXcQrDYvxIKnHg1jBbGgMZjJJ1CbcFTxptOrDYoua1WzqvghR5ce(AVEMqJ6Kqrbe(sczKyPXHiLE9udGGuPpzo1x2j09r7H7MWeAuNekkGWxsiJelnoePKscKKmsgRwt6tMghc2QtcitOjqYy1As)szqfqwssazcnXy1AsrnhlOg1j5Q(xIKnHg1jBbGgMZjJJ1CbcFTxptOrDYoua1WzqvghR5ce(AkP8EAcnQdUf6T9AGWgoc1ZMe6wai2WzqL1vLloeO61ClcTAo6ujyDeRASUQpbK0zdhXLquLJR6FsW6iw1yDvFcib00IdUVOkhx1)KTaqSHZGQSTCogGe(gabX0ysjs2RbcB4iPgtIPftuZXcQrD7zcnQtcwhXQgRR6tazB5Cmaj8nacIPXKsjrYIQCCv)tcwhXQgRR6tajGMwCW91ysmTyCb1RNj0OojyDeRASUQpbKcFdGGG7TBk9651aHnCKuJjX0IjQ5yb1OU9nHg1jBbGydNbvzB5Cmaj8nacIPXKs41aHnCKuJjX0IjQ5yb1OU91ysmTyCb9EAcnQdUf6TfMZXmHg1XCbur9SjHguDSoFdsOcvqiu0PIA0qpwTMeSoIvnwx1NaYvxIK9AGWgosQXKyAXe1CSGAu3E7MY7Pj0Oo4wO32RbcB4iupBsO78l6cKX6QYfhcu9AUfHwnhDQeSoIvnwx1Nas6SHJ4siQYXv9pjyDeRASUQpbKaAAXb3xuLJR6FYo)IUazSMZMeu2wohdqcFdGGyAmPej71aHnCKuJjX0IjQ5yb1OU9mHg1jbRJyvJ1v9jGSTCogGe(gabX0ysPKizrvoUQ)jbRJyvJ1v9jGeqtlo4(AmjMwmUG61ZeAuNeSoIvnwx1NasHVbqqW92nLE98AGWgosQXKyAXe1CSGAu3(MqJ6KD(fDbYynNnjOSTCogGe(gabX0ysj8AGWgosQXKyAXe1CSGAu3(AmjMwmUGEp9Oh7bZNUhVJnaNWGACiEShWzt6X8kisIq9XEGaqpEdNbv4JH(1YX94b94fK4ESwpgbDeWu6X74sFmVcilj4JTJ7XA9yczkDCpEdNbvc84DGbvciFpnHg1b3c92TaqSHZGkQliXQwJHqWHovuxqI13pCetyqnoeOtf1OHozK41aHnCKSfaInCguzDv5IdrVEJvRjbRJyvJ1v9jGC1LsIK9AGWgosQXKyAXe1CSGAu3E7MsIKnHgEjgD0mi4EO9AGWgos6BaoMWGkR5SjbvqKeLiznMeYpwTMuuZXcQrDsNbvgHSUaq751aHnCKKJCgkSMZMeubrsukPKajTaqq1akbKMqdVuIXQ1K(LYGkGSKKCv)lrYiXqocekjhodQeGnnOsajD2WrC96nwTMC4mOsa20GkbKaAAXb3Fx5ot590JE8o8cehIh7bcabvdOea1h7bca94nCguHp2a0JxqI7XWygod4q5XA9yUfioepgPvZXcQrDYhJux6iG5COG6JvFcLhBa6XliX9yTEmc6iGP0J3XL(yEfqwsWh33NUhlaHcFC)W5E8v6Jh0J7BqL4ESDCpUFO(pEdNbvc84DGbvcG6JvFcLhd9RLJ7Xd6XWoazCpUw6J16Xtlo1I7XQp94nCgujWJ3bgujWJhRwt(EAcnQdUf6TBbGydNbvuxqIvTgdHGdDQOUGeRVF4iMWGACiqNkQrdDlaeunGsaPj0WlLq4BaeeCp0PMizK41aHnCKSfaInCguzDv5IdrVEJvRjbRJyvJ1v9jGC1LsIKrIHCeiusoCgujaBAqLas6SHJ461BSAn5WzqLaSPbvcib00IdU)UYDMsIKrIj0Oozla0WCojHmsS04qKajMqJ6KDOaQHZGQmowZfi81eJvRj9jtJdbB1jxD96zcnQt2canmNtsiJelnoejgRwt6xkdQaYssYv9VE9mHg1j7qbudNbvzCSMlq4RjgRwt6tMghc2QtYv9VeJvRj9lLbvazjj5Q(xkVNMqJ6GBHEBH5CmtOrDmxavupBsOHQDCgGJbk10OouHkiek6urnAO9AGWgosQXKyAXe1CSGAu3E7(E(EAcnQdknHgEjMAo6uiAx4noeSrnhOgn0MqdVeJoAgeCVutmwTMuuZXcQrDsUQ)LizVgiSHJKAmjMwmrnhlOg1TNOkhx1)KUWBCiyJAoKClGPrD9651aHnCKuJjX0IjQ5yb1OU9rVBkVNMqJ6GstOHxIPMJofUf6TNKsfa1OH2RbcB4iPgtIPftuZXcQrD7JE3E9sESAnjyDeRASUQpbKRUE9ev54Q(NeSoIvnwx1NasanT4G7PXKyAX4ckHj0OojyDeRASUQpbKcFdGGG7NAVEirnhDQeSoIvnwx1Nas6SHJ4sjrYIQCCv)tojLkGKBbmnQBFVgiSHJKAmjMwmrnhlOg11RNgtIPfJlO99AGWgosQXKyAXe1CSGAuxkVNMqJ6GstOHxIPMJofUf6T5agI6GSbGm1h1OHwnhDQ0CeYGkWGiNbzTfafjD2WrCjsESAnPOMJfuJ6KCv)lbsgRwt6xkdQaYsscitO96nwTMuuZXcQrDYvxctOrDYwai2Wzqvk8naccUVj0OozlaeB4mOkNgYycFdGGGjqYy1As)szqfqwssazcnL3Z3tp6XiTAowqnQ7XD(gKEChG6mabFSncxObbFC)q9FS9yoYzOG6JvF6ESZwNWNGpooTES6tpgPvZXcQrDpgsP7Iob9EAcnQdkf1CSGAuhRZ3GeAxGWxHmpOfhIjDkQrd9y1AsrnhlOg1j5Q(37Pj0OoOuuZXcQrDSoFdsBHE7HHGvnMccrsquJg6XQ1KIAowqnQtYv9V3ttOrDqPOMJfuJ6yD(gK2c92UWBCiyJAoqnAOnHgEjgD0mi4EPMySAnPOMJfuJ6KCv)790eAuhukQ5yb1OowNVbPTqV9WvfhRAm1Ny0rtuEpnHg1bLIAowqnQJ15BqAl0BpPzbqHvnMBjcoghGSj890eAuhukQ5yb1OowNVbPTqVD)c448sXXaeSo7e07Ph94D4fioepgPvZXcQrDO(ypqaOhVHZGk8XgGE8csCpwRhJGocyk94DCPpMxbKLe8X2X94zCXmqo6XQp9yBwRtFC1ESgt6XWo60htiJelnoepUuFc8yyh5Cq5J9af4Xq1oodW9ypqaiuFShia0J3Wzqf(ydqpUohkpEbjUh33NUhVJjtJdXJr67ECaFSj0Wl94c84((09y7X8Ici8FSWG6Jd4JJ7XDGcbGGWhBh3J3XKPXH4Xi9Dp2oUhVJl9X8kGSKESbOhFL(ytOHxs(ypyH6)4nCgujWJ3bgujWJTJ7XEaNnPh7b3H6J9abGE8godQWhlS7XghxOrDMZHYJh0JxqI7X99dh94DCPpMxbKL0JTJ7X7yY04q8yK(UhBa6XxPp2eA4LESDCp2E8okkGA4mO(4a(44ES6tp2cWJTJ7XMdwpUVF4OhlmOghIhZlkGW)XKx6EC0E8oMmnoepgPV7Xb8XMdqghkp2eA4LKpEtF6Xotvc8yZ5Q(WhR9RhVJl9X8kGSKE8okkGA4mOcFSwpEqpwyq9XX9y4siiimQ7XwtjWJvF6X8Ici8LpEhHJl0OoZ5q5X9d1)XB4mOsGhVdmOsGhBh3J9aoBsp2dUd1h7bca94nCguHpg6xlh3JVsF8GE8csCpEDoccF8godQe4X7adQe4Xb8X2Ow6J16XeY6ca94c8y1Na0Jna94zbOhR(29y6Qfc)h7bca94nCguHpwRhtitPJ7XB4mOsGhVdmOsGhR1JvF6X0X94Q9yKwnhlOg1jFpnHg1bLIAowqnQJ15BqAl0B3caXgodQOUGeRAngcbh6urDbjwF)WrmHb14qGovuJgAHVbqqW9qNAIKt2eAuNSfaInCguLcFdGGGSgWeAuN52k5XQ1KIAowqnQtcOPfhe5hRwtoCgujaBAqLasUfW0OUu2HkQYXv9pzlaeB4mOk5watJ6q(KhRwtkQ5yb1OojGMwCWu2HM8y1AYHZGkbytdQeqYTaMg1H87k3zkPSh6D71djgYrGqj5WzqLaSPbvciPZgoIRxpKOMJov2C2Ky1jPZgoIRxVXQ1KIAowqnQtcOPfhCF0JvRjhodQeGnnOsaj3cyAuxVEJvRjhodQeGnnOsajGMwCW93vUZE9O0DfDDeN0hLocO(aY4y9bbu7dSoycrvoUQ)j9rPJaQpGmowFqa1(aRdY8WD3nvpE6LaAAXb3FNPKySAnPOMJfuJ6KRUejJetOrDsOOacFjHmsS04qKajMqJ6KDOaQHZGQmowZfi81eJvRj9jtJdbB1jxD96zcnQtcffq4ljKrILghIeJvRj9lLbvazjj5Q(xIKhRwt6tMghc2QtYv9VE9mKJaHsYHZGkbytdQeqsNnCexk96zihbcLKdNbvcWMgujGKoB4iUeQ5OtLnNnjwDs6SHJ4sycnQt2HcOgodQY4ynxGWxtmwTM0NmnoeSvNKR6FjgRwt6xkdQaYssYv9VuEpnHg1bLIAowqnQJ15BqAl0BdwhXQgRR6tauJg6XQ1KIAowqnQtYv9V3tp6X7ip2dea6XB4mO(yOFTCCpEqpEbjUhR1JTUohkpEdNbvc84DGbvc84((HJESWGACiESh8RJEC1E8oA1NapUVpDpEbJdXJ3WzqLapEhyqLaO(ypGZM0J9G7q9X2X94DaPubKpoDU946CO84DanlakpUApoDAjcUhVddiBcF8oiUc84a(ykDxrxhXH6Jv)a(yxC0Jd4JdexbiUhpiHTG0Jd9X9dN7XWAsAmj4JbeC50hh3JruXH4XXP1JrA1CSGAu3J7hQ)JBu)h7bca94nCguFSW3aiiO890eAuhukQ5yb1OowNVbPTqVDlaeB4mOI6csS((HJycdQXHaDQOgn0gYrGqj5WzqLaSPbvciPZgoIlrYeesNGKtAwauyvJ5wIGJXbiBcLtZdQa96HeccPtqYjnlakSQXClrWX4aKnHYzCfiLeQ5OtLtsPciPZgoIlHAo6uzZztIvNKoB4iUeJvRjhodQeGnnOsajx1)sKSAo6ujyDeRASUQpbK0zdhXLWeAuNeSoIvnwx1NasczKyPXHiHj0OojyDeRASUQpbKeYiXsjgGMwCW93vIu1RxYEnqydhj1ysmTyIAowqnQBF072R3y1AsrnhlOg1jxDPKajQ5OtLG1rSQX6Q(eqsNnCexcKycnQt2HcOgodQY4ynxGWxtGetOrDYwaOH5CY4ynxGWxt590eAuhukQ5yb1OowNVbPTqVTWCoMj0OoMlGkQNnj0MqdVetnhDk890eAuhukQ5yb1OowNVbPTqVTOMJfuJ6qDbjw1Ameco0PI6csS((HJycdQXHaDQOgn0jNSj0Oo5KuQaY4ynxGWxtycnQtojLkGmowZfi8vgGMwCW9rVRCNP0RNj0Oo5KuQaY4ynxGWx71JGq6eKCsZcGcRAm3seCmoaztOCAEqfOxVXQ1K(LYGkGSKKaYeAVEMqJ6Kqrbe(sczKyPXHiHj0OojuuaHVKqgjwkXa00IdU)UYD2RNj0OozhkGA4mOkjKrILghIeMqJ6KDOaQHZGQKqgjwkXa00IdU)UYDMsIKhRwtcwhXQgRR6ta5QRxpKOMJovcwhXQgRR6tajD2WrCP8EAcnQdkf1CSGAuhRZ3G0wO3UR0OU3ttOrDqPOMJfuJ6yD(gK2c92dxvCS2cGY7Pj0OoOuuZXcQrDSoFdsBHE7bbGeiP4q8EAcnQdkf1CSGAuhRZ3G0wO3UfaA4QI790eAuhukQ5yb1OowNVbPTqVTDccQaZXeMZ9EAcnQdkf1CSGAuhRZ3G0wO3U5SjbvqKeHA0qNCYQ5OtLnNnjwNPcFjD2WrCjmHgEjgD0mi4EPpLE9mHgEjgD0mi4EivPKySAnPFPmOciljjGmHMajgYrGqj5WzqLaSPbvciPZgoI790eAuhukQ5yb1OowNVbPTqVDhkGA4mOIA0qpwTMSdfqjCgCkbKj0eJvRjf1CSGAuNeqtlo4EcdQmnM07Pj0OoOuuZXcQrDSoFdsBHE7oua1Wzqf1OHESAnPFPmOciljjGmH(E6rpgPvZjDACiES6hWhtNcq5X1srQ)XH6XcFmGCOehIhx3JThditOrDpwJj9yoYzO84((09yuQ1Jt6Q(pgLAbEmVOac)h3pCUhlaH(y74Emk16X(g3J3XKPXH4Xi9DpUVpDpgLA9yHb1hZlkGWx(E6rpoD(qEe2Kq9XQFaFCaFSVDCoI7XZcqp(mDbmNdf57Ph9ytOrDqPOMJfuJ6yD(gK2c92DOaQHZGkQrdDhG8Yqi4KPkHIci8tmwTM0NmnoeSvNC19EAcnQdkf1CSGAuhRZ3G0wO3UZVOlqgR5SjbFpnHg1bLIAowqnQJ15BqAl0Bdffq4JA0qpwTMuuZXcQrDsanT4G7jmOY0ysjgRwtkQ5yb1Oo5QRxVXQ1KIAowqnQtYv9VeIQCCv)tkQ5yb1OojGMwCW9fguzAmP3ttOrDqPOMJfuJ6yD(gK2c92UWBCiyJAoqnAOhRwtkQ5yb1OojGMwCW9ri4KtdzjmHgEjgD0mi4EP(EAcnQdkf1CSGAuhRZ3G0wO3MdyiQdYgaYuFuJg6XQ1KIAowqnQtcOPfhCFeco50qwIXQ1KIAowqnQtU6EpnHg1bLIAowqnQJ15BqAl0Bdffq4JA0qRgabPsFYCQVStO7J2d3nHAo6ujKmqCiyATe(s6SHJ4EpFpnHg1bLHstituZXcQrDOxqIfknr9SjHoqCHg1XMgccYAli9EAcnQdkdLMqMOMJfuJ62c92liXcLMOE2Kq7JshbuFazCS(GaQ9bwhe1OHESAnPOMJfuJ6KRUeMqJ6KTaqSHZGQu4Baeee9UjmHg1jBbGydNbvjGe(gabX0ys7HqWjNgYEpnHg1bLHstituZXcQrDBHE7fKyHstupBsON2fncQfRASPXDee(EAcnQdkdLMqMOMJfuJ62c92c7eKJnwTgQliXQwJHqWHovupBsON2fncQfRASPXDeeYe(wNsawDeQrd9y1AsrnhlOg1jxD96zcnQtojLkGmowZfi81eMqJ6KtsPciJJ1CbcFLbOPfhCF07k357Pj0OoOmuAczIAowqnQBl0BVGeluAI6csSQ1yieCOtf1ZMeAd5was9lidghcIJ15wtdbHA0qpwTMuuZXcQrDYvxVEMqJ6KtsPciJJ1CbcFnHj0Oo5KuQaY4ynxGWxzaAAXb3h9UYD(EAcnQdkdLMqMOMJfuJ62c92liXcLMOUGeRAngcbh6urLAnsOSZMeAeoJlmTaq2W4qqOgn0JvRjf1CSGAuNC11RNj0Oo5KuQaY4ynxGWxtycnQtojLkGmowZfi8vgGMwCW9rVRCNVNMqJ6GYqPjKjQ5yb1OUTqV9csSqPjQliXQwJHqWHovuPwJek7SjHgHZ4ctlaKnjoZ5I6qnAOhRwtkQ5yb1Oo5QRxptOrDYjPubKXXAUaHVMWeAuNCskvazCSMlq4RmanT4G7JEx5oFpnHg1bLHstituZXcQrDBHE7fKyHstuxqIvTgdHGdDQOE2Kqpmh1caXga7e(Ogn0JvRjf1CSGAuNC11RNj0Oo5KuQaY4ynxGWxtycnQtojLkGmowZfi8vgGMwCW9rVRCNVNMqJ6GYqPjKjQ5yb1OUTqV9csSqPjQliXQwJHqWHovupBsOH(LiPrOeaYA2Ha1OHESAnPOMJfuJ6KRUE9mHg1jNKsfqghR5ce(ActOrDYjPubKXXAUaHVYa00IdUp6DL7890eAuhugknHmrnhlOg1Tf6TxqIfknrDbjw1Ameco0PI6ztcTIC2rq2Wajb7IJGOgn0JvRjf1CSGAuNC11RNj0Oo5KuQaY4ynxGWxtycnQtojLkGmowZfi8vgGMwCW9rVRCNVNMqJ6GYqPjKjQ5yb1OUTqV9csSqPjQliXQwJHqWHovupBsOTte0PSKUszvJ1pGC1e1OHESAnPOMJfuJ6KRUE9mHg1jNKsfqghR5ce(ActOrDYjPubKXXAUaHVYa00IdUp6DL7890eAuhugknHmrnhlOg1Tf6TxqIfknrDbjw1Ameco0PI6ztc9rlG5yquoRdsm68TtqauJg6XQ1KIAowqnQtU661ZeAuNCskvazCSMlq4RjmHg1jNKsfqghR5ce(kdqtlo4(O3vUZ3ttOrDqzO0eYe1CSGAu3wO3EbjwO0e1fKyvRXqi4qNkQNnj0tZ1kWK4y(eWCCqMJq0hyDquJg6XQ1KIAowqnQtU661ZeAuNCskvazCSMlq4RjmHg1jNKsfqghR5ce(kdqtlo4(O3vUZ3Z3ttOrDqzO0eY8de(SoquGqrbTWCoMj0OoMlGkQNnj0HstituZXcQrDOgn0Enqydhj1ysmTyIAowqnQBF07(EAcnQdkdLMqMFGWN1bIcekkBHE7fKyHst47Pj0OoOmuAcz(bcFwhikqOOSf6TxqIfknr9SjHEAx0iOwSQXMg3rqiQrdnsO0DfDDeN0qoOVbmiRvNYQgRR6tGeEnqydhj1ysmTyIAowqnQBFKU3ttOrDqzO0eY8de(SoquGqrzl0BVGeluAI6ztcTHCqFdyqwRoLvnwx1NaOgn0Enqydhj1ysmTyIAowqnQBF07CRu3jsXRbcB4izRoLXvRHJy1Xwq690eAuhugknHm)aHpRdefiuu2c92liXcLMOE2KqdkvawqL4yERIRkgx5COgn0Enqydhj1ysmTyIAowqnQBpVgiSHJK1XwqIjwA1AVNMqJ6GYqPjK5hi8zDGOaHIYwO3EbjwO0e1ZMeAlDxrxP0PSZwA4wquJgAVgiSHJKAmjMwmrnhlOg1TNxde2WrY6yliXelTAT3ttOrDqzO0eY8de(SoquGqrzl0BVGeluAI6ztcn0p8saMx6QjdqUqGA0q71aHnCKuJjX0IjQ5yb1OU98AGWgoswhBbjMyPvR9EAcnQdkdLMqMFGWN1bIcekkBHE7fKyHstupBsOBfyeCC0XQbm4c7ycN1h1OH2RbcB4iPgtIPftuZXcQrD751aHnCKSo2csmXsRw790eAuhugknHm)aHpRdefiuu2c92liXcLMOsTgju2ztcTVbM1fcghnnLaH5cKJaVNMqJ6GYqPjK5hi8zDGOaHIYwO3EbjwO0e1ZMe6P5AfysCmFcyooiZri6dSoiQrdTxde2WrsnMetlMOMJfuJ62d9o3zIXQ1KIAowqnQtYv9VeEnqydhj1ysmTyIAowqnQBpVgiSHJK1XwqIjwA1AVNMqJ6GYqPjK5hi8zDGOaHIYwO3EbjwO0e1ZMeA7ebDklPRuw1y9dixnrnAO9AGWgosQXKyAXe1CSGAu3EO35otmwTMuuZXcQrDsUQ)LWRbcB4iPgtIPftuZXcQrD751aHnCKSo2csmXsRw790eAuhugknHm)aHpRdefiuu2c92liXcLMOE2KqF0cyogeLZ6GeJoF7eea1OH2RbcB4iPgtIPftuZXcQrD7H2JVZeJvRjf1CSGAuNKR6Fj8AGWgosQXKyAXe1CSGAu3EEnqydhjRJTGetS0Q1EpFpnHg1bLHstiZv9zDGOaHIc6fKyHstupBsO1GJGAbMmrXrid1OH2RbcB4iPgtIPftuZXcQrD751aHnCKSo2csmXsRw790eAuhugknHmx1N1bIcekkBHE7fKyHstuPwJek7SjHwGIWvkOUqWgodQOgn0Enqydhj1ysmTyIAowqnQBpVgiSHJK1XwqIjwA1AVNVNMqJ6Gsq1X68niHgSoIvnwx1NaVNMqJ6Gsq1X68niTf6TBoBsqfejrOgn0jBcn8sm6OzqW9q71aHnCK0VugubKLeR5SjbvqKeLiznMeYpwTMuuZXcQrDsNbvgHSUaq751aHnCKKJCgkSMZMeubrsukPKySAnPFPmOciljjGmH(EAcnQdkbvhRZ3G0wO3UdfqnCgurnAOhRwt6xkdQaYsscitOVNMqJ6Gsq1X68niTf6TBbGydNbvuxqIvTgdHGdDQOUGeRVF4iMWGACiqNkQrdnss2eA4Ly0rZGG7H2RbcB4iPVb4ycdQSMZMeubrsuIK1ysi)y1AsrnhlOg1jDguzeY6caTNxde2WrsoYzOWAoBsqfejrPKscK0cabvdOeqAcn8sjsgjJvRj9jtJdbB1jbKj0eizSAnPFPmOciljjGmHMajDaYlRAngcbNSfaInCgutKSj0OozlaeB4mOkf(gabb3dD671lztOrDYo)IUazSMZMeuk8naccUh6utOMJov25x0fiJ1C2KGs6SHJ4sPxVKvZrNknhHmOcmiYzqwBbqrsNnCexcrvoUQ)j5agI6GSbGm1xciJdLu61lz1C0PsizG4qW0Aj8L0zdhXLqnacsL(K5uFzNq3hThUBkPKY7Pj0OoOeuDSoFdsBHEBH5CmtOrDmxavupBsOnHgEjMAo6u47Pj0OoOeuDSoFdsBHE7oua1Wzqf1OHESAnzhkGs4m4ucitOjeguzAmP9hRwt2HcOeodoLaAAXbtmwTMeSoIvnwx1NasanT4G7jmOY0ysVNMqJ6Gsq1X68niTf6TBbGydNbvuxqIvTgdHGdDQOUGeRVF4iMWGACiqNkQrdnss2eA4Ly0rZGG7H2RbcB4iPVb4ycdQSMZMeubrsuIK1ysi)y1AsrnhlOg1jDguzeY6caTNxde2WrsoYzOWAoBsqfejrPKscK0cabvdOeqAcn8sjsESAnPpzACiyRojGmHMiz1aiiv6tMt9LDcDp0E4U96He1C0PsizG4qW0Aj8L0zdhXLskVNMqJ6Gsq1X68niTf6TBbGydNbvuxqIvTgdHGdDQOUGeRVF4iMWGACiqNkQrdnss2eA4Ly0rZGG7H2RbcB4iPVb4ycdQSMZMeubrsuIK1ysi)y1AsrnhlOg1jDguzeY6caTNxde2WrsoYzOWAoBsqfejrPKscK0cabvdOeqAcn8sjuZrNkHKbIdbtRLWxsNnCexc1aiiv6tMt9LDcDF0E4UjsESAnPpzACiyRojGmHMajMqJ6Kqrbe(sczKyPXHOxpKmwTM0NmnoeSvNeqMqtGKXQ1K(LYGkGSKKaYeAkVNE0JrA1CsNghIhR(b8X0PauECTuK6FCOESWhdihkXH4X19y7XaYeAu3J1yspMJCgkpUVpDpgLA94KUQ)JrPwGhZlkGW)X9dN7XcqOp2oUhJsTESVX94DmzACiEmsF3J77t3JrPwpwyq9X8Ici8LVNE0JtNpKhHnjuFS6hWhhWh7BhNJ4E8Sa0JptxaZ5qr(E6rp2eAuhucQowNVbPTqVDhkGA4mOIA0q3biVmecozQsOOac)eJvRj9jtJdbB1jxDjuZrNkHKbIdbtRLWxsNnCexc1aiiv6tMt9LDcDF0E4UjqsYMqdVeJoAgeCp0Enqydhj9lLbvazjXAoBsqfejrjswJjH8JvRjf1CSGAuN0zqLriRla0EEnqydhj5iNHcR5SjbvqKeLskVNMqJ6Gsq1X68niTf6T78l6cKXAoBsquJgAK0biVmecozQYo)IUazSMZMemXy1AsFY04qWwDsazc990eAuhucQowNVbPTqVnuuaHpQrdTAaeKk9jZP(YoHUpApC3eQ5OtLqYaXHGP1s4lPZgoI790eAuhucQowNVbPTqVnhWquhKnaKP(Ogn0MqdVeJoAgeCV0)EAcnQdkbvhRZ3G0wO3U5SjbvqKeHA0qNSj0WlXOJMbb3dTxde2WrsFdWXeguznNnjOcIKOejRXKq(XQ1KIAowqnQt6mOYiK1faApVgiSHJKCKZqH1C2KGkisIsjL3ttOrDqjO6yD(gK2c92TaqdZ5EpFpnHg1bLq1oodWXaLAAuh6MZMeubrseQrdDYMqdVeJoAgeCp0Enqydhj9lLbvazjXAoBsqfejrjswJjH8JvRjf1CSGAuN0zqLriRla0EEnqydhj5iNHcR5SjbvqKeLskjgRwt6xkdQaYsscitOVNMqJ6GsOAhNb4yGsnnQBl0B3HcOgodQOgn0JvRj9lLbvazjjbKj0eJvRj9lLbvazjjb00IdUVj0Oozla0WCojHmsSuIPXKEpnHg1bLq1oodWXaLAAu3wO3UdfqnCgurnAOhRwt6xkdQaYsscitOjsUdqEzieCYuLTaqdZ561RfacQgqjG0eA4L61ZeAuNSdfqnCguLXXAUaHVMY7Pj0OoOeQ2XzaogOutJ62c92D(fDbYynNnjiQrdTW3aii4EO9WeMqdVeJoAgeCV0NajEnqydhj78l6cKX6QYfhI3ttOrDqjuTJZaCmqPMg1Tf6T7qbudNbvuJg6XQ1K(LYGkGSKKaYeAc1aiiv6tMt9LDcDF0E4UjuZrNkHKbIdbtRLWxsNnCe37Pj0OoOeQ2XzaogOutJ62c92DOaQHZGkQrd9y1AYouaLWzWPeqMqtimOY0ys7pwTMSdfqjCgCkb00Id(EAcnQdkHQDCgGJbk10OUTqVDlaeB4mOI6csSQ1yieCOtf1fKy99dhXeguJdb6urnAOtESAnjyDeRASUQpbKCv)lbsAbGGQbucinHgEPusGeVgiSHJKTaqSHZGkRRkxCisKCYjBcnQt2canmNtsiJelnoe96zcnQt2HcOgodQsczKyPXHiLeJvRj9jtJdbB1jbKj0u61lz1C0PsizG4qW0Aj8L0zdhXLqnacsL(K5uFzNq3hThUBIKhRwt6tMghc2QtcitOjqIj0OojuuaHVKqgjwACi61djJvRj9lLbvazjjbKj0eizSAnPpzACiyRojGmHMWeAuNekkGWxsiJelnoejqIj0OozhkGA4mOkJJ1CbcFnbsmHg1jBbGgMZjJJ1CbcFnLus590JEmsRMt604q8y1pGpMofGYJRLIu)Jd1Jf(ya5qjoepUUhBpgqMqJ6ESgt6XCKZq5X99P7XOuRhN0v9Fmk1c8yErbe(pUF4Cpwac9X2X9yuQ1J9nUhVJjtJdXJr67ECFF6Emk16XcdQpMxuaHV890JEC68H8iSjH6Jv)a(4a(yF74Ce3JNfGE8z6cyohkY3tp6XMqJ6GsOAhNb4yGsnnQBl0B3HcOgodQOgn0DaYldHGtMQekkGWpXy1AsFY04qWwDYvxc1C0PsizG4qW0Aj8L0zdhXLqnacsL(K5uFzNq3hThUBcKKSj0WlXOJMbb3dTxde2Wrs)szqfqwsSMZMeubrsuIK1ysi)y1AsrnhlOg1jDguzeY6caTNxde2WrsoYzOWAoBsqfejrPKY7Pj0OoOeQ2XzaogOutJ62c92D(fDbYynNnjiQrdDYJvRj9jtJdbB1jbKj0E9sgjJvRj9lLbvazjjbKj0ejBcnQt2caXgodQsHVbqqW92Txp1C0PsizG4qW0Aj8L0zdhXLqnacsL(K5uFzNq3hThUBkPKscK41aHnCKSZVOlqgRRkxCiEpnHg1bLq1oodWXaLAAu3wO3wyohZeAuhZfqf1ZMeAtOHxIPMJof(EAcnQdkHQDCgGJbk10OUTqVnhWquhKnaKP(Ogn0MqdVeJoAgeCVuFpnHg1bLq1oodWXaLAAu3wO3wyohZeAuhZfqf1ZMe6qPjK5Q(SoquGqr590eAuhucv74mahduQPrDBHEBOOacFuJgA1aiiv6tMt9LDcDF0E4UjuZrNkHKbIdbtRLWxsNnCe37Ph9ypyH6)y6Qfc)hRgabPquFCOpoGp2EmclUhR1JfguFShWztcQGij6Xg8XTW5iWJJdQKX94Q9ypqaOH5CY3ttOrDqjuTJZaCmqPMg1Tf6TBoBsqfejrOgn0MqdVeJoAgeCp0Enqydhj9nahtyqL1C2KGkisIsKSgtc5hRwtkQ5yb1OoPZGkJqwxaO98AGWgosYrodfwZztcQGijkL3ttOrDqjuTJZaCmqPMg1Tf6TBbGgMZ9EAcnQdkHQDCgGJbk10OUTqVnuuaHFwZAod]] )


end
