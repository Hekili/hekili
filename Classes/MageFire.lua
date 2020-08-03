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
                    if combat == 0 and not boss and not settings.pyroblast_pull then return false, "opener pyroblast disabled and/or target is not a boss" end
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



    spec:RegisterPack( "Fire", 20200802, [[d80hRcqieIhrvPCjLQeSjQQ(ecjXOebNseAviK4vkvmluj3cHQ2fr)sPsdtPuhJQILPuONrvjnnQkrxtPk2MsvQ(MsbPXPuLY5OQu16qij9oQkvsMNsvDpuX(uiDqLQeTqLIEicPAIkvj5Ikvj0gPQe(ivLkPgjcj1jrifwPiYlPQuPmtLcIBQuqTtfIFsvPsmuLQKAPuvQu9uu1uvk5QuvQ4RiKI2RO(lkdgPdtzXs8yctgrxgAZs6Ziy0I0PfwncP0RfrnBQCBfTBv(TudxbhxPalxvph00jDDLSDQsFxHA8iuopQuRhHkZNQy)aN9jVvMN0umpYg3EJBV9EB7nk34g32x6R((mVY9aM5hmrYgbmZF2eZ8(I4Xm)GXTRnY8wzEyVEbM5tvDasuD3DjeA6Qif9CxymxotJ(eVv1DHXuSBMVScNs04YLmpPPyEKnU9g3E7922BuUXnUTV0x3BzEBPP9N55JjrpZNgKK4LlzEsekY8(gG6lIhb0nSrabj5BaAQQdqIQ7UlHqtxfPON7cJ5YzA0N4TQUlmMIDbj5Ba6E5IWcQa6g5cq342BCBqsGK8naLONAhbesufKKVbOepG67aravJjY0MrgiG(MMIpGQP2bOQ9eqvQXezAZideqR9dOodQepef9rcOwjCHYnGUGgbekbj5BakXdO(odKMIaQRjeca9rIQa6gYseKa6E1J2ekbj5BakXdOBiDdXdqfgub0h3Gv84epfcO1(buIEpllOg9bOjesuYfGs2hrffqtBhjGgkGw7hqnaT(imfq3WOI9dOcdQjkbj5BakXdO7vb0koeqTdqXtFUbun1uaDCVCKa6JWLtb04audqtTNuyqfq3R5(7IZGkGghXtWMOeKKVbOepGUx8SIdbuO(HqburkksoocaAFaQbOvCmGw7pziGghGQPiGUxUxVHaOAdOpsUeiGoU)KDTrkZ8UaQW8wz(qXjK56XSHp6puUZBLhXN8wzE8SIdjZBM5nHg9L51GeHA)tMOjrIL5fFO4hwM3R9HvCOuJjY0Mj6zzb1OpaDua1R9HvCOSp2cImXs7AnZF2eZ8AqIqT)jt0KiXYAEKnM3kZJNvCizEZmVj0OVmVGBHR1VVqWkodQzEXhk(HL59AFyfhk1yImTzIEwwqn6dqhfq9AFyfhk7JTGitS0UwZ8yTIcLD2eZ8cUfUw)(cbR4mOM1SM5f9SSGA0hBi1GyER8i(K3kZJNvCizEZmV4df)WY8LvTkf9SSGA0NKShFzEtOrFzExqivHmI2fjHjEAwZJSX8wzE8SIdjZBM5fFO4hwMVSQvPONLfuJ(KK94lZBcn6lZxmcSUY0pejdZAEeFnVvMhpR4qY8MzEXhk(HL5nHgErgE4mqiGokG6dG6hqlRAvk6zzb1Opjzp(Y8MqJ(Y8UWBCeyLEwYAEeFzERmVj0OVmFX1njRRmnfz4HtUZ84zfhsM3mR5r2tERmVj0OVm)eN9ZnRRm3seKmYhTjmZJNvCizEZSMhzVN3kZBcn6lZpUFhPxmo2JW(StGzE8SIdjZBM18iBO5TY84zfhsM3mZVGiBCA4qMWGACeYJ4tMx8HIFyzErQ9eqiGokha1ha1pGMaGMaGAcn6twJhzfNbvPi1EciKvFtOrFMdq3bqtaqlRAvk6zzb1Op5JtloiGs8aAzvRYIZGk(SPbv8LKR30OpanraDVaGk62r2JpznEKvCguLKR30OpaL4b0ea0YQwLIEwwqn6t(40IdcOjcO7fa0ea0YQwLfNbv8ztdQ4ljxVPrFakXdOBl3dGMiGMiGokhaDBa1JhaLiaQrC4hkklodQ4ZMguXxINvCijG6XdGseavnhEQS6SjY6tINvCijG6XdGww1Qu0ZYcQrFYhNwCqaDFoaAzvRYIZGk(SPbv8LKR30Opa1JhaTSQvzXzqfF20Gk(YhNwCqaDFaDB5EaupEauCdwXWaskt5EaFn9rJKn(dOo(TbiG6hqfD7i7XNmL7b810hns24pG643gGmFD7T9XxUr5JtloiGUpGUhanra1pGww1Qu0ZYcQrFY1aG6hqtaqjcGAcn6tcf9lsLiXqXsJJaG6hqjcGAcn6toW93fNbvzCSQliKQaQFaTSQvzkAACeyRb5Aaq94bqnHg9jHI(fPsKyOyPXraq9dOLvTktBLb1hTKLK94dq9dOjaOLvTktrtJJaBnij7XhG6XdGAeh(HIYIZGk(SPbv8L4zfhscOjcOE8aOgXHFOOS4mOIpBAqfFjEwXHKaQFavnhEQS6SjY6tINvCijG6hqnHg9jh4(7IZGQmow1fesva1pGww1QmfnnocS1GKShFaQFaTSQvzARmO(OLSKShFaAIz(fezDTYiiiZJ4tM3eA0xMVgpYkodQznpYElVvMhpR4qY8MzEXhk(HL5lRAv(RdzDLn0JXxs2Jpa1pGww1Qu0ZYcQrFsYE8L5nHg9L5)1HSUYg6X4N18i((8wzE8SIdjZBM5xqKnonCityqnoc5r8jZBcn6lZxJhzfNb1mV4df)WY8gXHFOOS4mOIpBAqfFjEwXHKaQFanbafHq8eOCIZ(5M1vMBjcsg5J2ekNgrB)aQhpakrauecXtGYjo7NBwxzULiizKpAtOCgx)aAIaQFavnhEQCIk2VepR4qsa1pGQMdpvwD2ez9jXZkoKeq9dOLvTklodQ4ZMguXxs2Jpa1pGMaGQMdpv(RdzDLn0JXxINvCijG6hqnHg9j)1HSUYg6X4lrIHILghba1pGAcn6t(RdzDLn0JXxIedflfzpoT4Ga6(a62Y9oG6XdGMaG61(WkouQXezAZe9SSGA0hGUphaDBa1JhaTSQvPONLfuJ(KRbanra1pGseavnhEQ8xhY6kBOhJVepR4qsa1pGsea1eA0NCG7VlodQY4yvxqivbu)akrautOrFYA8yXCozCSQliKQaAIznpIpBN3kZJNvCizEZmVj0OVmVWCoMj0OpMlGAM3fqLD2eZ8MqdVitnhEkmR5r8XN8wzE8SIdjZBM5xqKnonCityqnoc5r8jZl(qXpSmFcaAcaQj0Op5evSFzCSQliKQaQFa1eA0NCIk2Vmow1fesv2JtloiGUphaDB5Ea0ebupEautOrFYjQy)Y4yvxqivbupEauecXtGYjo7NBwxzULiizKpAtOCAeT9dOE8aOLvTktBLb1hTKLpAcfq94bqnHg9jHI(fPsKyOyPXraq9dOMqJ(Kqr)IujsmuSuK940IdcO7dOBl3dG6XdGAcn6toW93fNbvjsmuS04iaO(butOrFYbU)U4mOkrIHILIShNwCqaDFaDB5Ea0ebu)aAcaAzvRYFDiRRSHEm(Y1aG6XdGseavnhEQ8xhY6kBOhJVepR4qsanXm)cISUwzeeK5r8jZBcn6lZl6zzb1OVSMhXNnM3kZBcn6lZp0A0xMhpR4qY8MznpIp(AERmVj0OVmFX1njRUEUZ84zfhsM3mR5r8XxM3kZBcn6lZxWhIFYXriZJNvCizEZSMhXN9K3kZBcn6lZxJhlUUjZ84zfhsM3mR5r8zVN3kZBcn6lZBNaH6BoMWCUmpEwXHK5nZAEeF2qZBL5XZkoKmVzMx8HIFyz(ea0eau1C4PYQZMiBWurQepR4qsa1pGAcn8Im8WzGqaDuaDJaAIaQhpaQj0WlYWdNbcb0rb09oGMiG6hqlRAvM2kdQpAjlF0ekG6hqjcGAeh(HIYIZGk(SPbv8L4zfhsM5nHg9L5RoBIq9JKXSMhXN9wERmpEwXHK5nZ8Ipu8dlZxw1QCG7VfodoLpAcfq9dOLvTkf9SSGA0N8XPfheqhfqfguzAmXmVj0OVm)a3FxCguZAEeF895TY84zfhsM3mZl(qXpSmFzvRY0wzq9rlz5JMqZ8MqJ(Y8dC)DXzqnR5r2425TY8MqJ(Y8dPnEbXyvNnryMhpR4qY8MznpYg9jVvMhpR4qY8MzEXhk(HL5lRAvk6zzb1Op5JtloiGokGkmOY0yIaQFaTSQvPONLfuJ(KRba1JhaTSQvPONLfuJ(KK94dq9dOIUDK94tk6zzb1Op5JtloiGUpGkmOY0yIzEtOrFzEOOFrAwZJSXnM3kZJNvCizEZmV4df)WY8LvTkf9SSGA0N8XPfheq3hqjiiLtJyaQFa1eA4fz4HZaHa6OaQpzEtOrFzEx4nocSsplznpYg918wzE8SIdjZBM5fFO4hwMVSQvPONLfuJ(KpoT4Ga6(akbbPCAedq9dOLvTkf9SSGA0NCnK5nHg9L5jFJqFqw5rttZAEKn6lZBL5XZkoKmVzMx8HIFyzE1EcOktrZPPYbHcO7Zbq91Tbu)aQAo8ujeTpocmTxIujEwXHKzEtOrFzEOOFrAwZAM3eA4fzQ5WtH5TYJ4tERmpEwXHK5nZ8Ipu8dlZBcn8Im8WzGqaDua1ha1pGww1Qu0ZYcQrFsYE8bO(b0eauV2hwXHsnMitBMONLfuJ(a0rbur3oYE8jDH34iWk9SijxVPrFaQhpaQx7dR4qPgtKPnt0ZYcQrFa6(Ca0Tb0eZ8MqJ(Y8UWBCeyLEwYAEKnM3kZJNvCizEZmV4df)WY8ETpSIdLAmrM2mrpllOg9bO7Zbq3gq94bqtaqlRAv(RdzDLn0JXxUgaupEaur3oYE8j)1HSUYg6X4lFCAXbb0rbunMitBgzGaQFa1eA0N8xhY6kBOhJVuKApbecO7dO(aOE8aOebqvZHNk)1HSUYg6X4lXZkoKeqteq9dOjaOIUDK94torf7xsUEtJ(a09buV2hwXHsnMitBMONLfuJ(aupEaunMitBgzGa6(aQx7dR4qPgtKPnt0ZYcQrFaAIzEtOrFz(jQy)znpIVM3kZJNvCizEZmV4df)WY8Q5WtLMdjguFdsCgKvxp3s8SIdjbu)aAcaAzvRsrpllOg9jj7XhG6hqjcGww1QmTvguF0sw(Ojua1JhaTSQvPONLfuJ(KRba1pGAcn6twJhzfNbvPi1Ecieq3hqnHg9jRXJSIZGQCAeJjsTNacbu)akra0YQwLPTYG6JwYYhnHcOjM5nHg9L5jFJqFqw5rttZAwZ8HItilniKYg(O)q5oVvEeFYBL5XZkoKmVzMx8HIFyzEV2hwXHsnMitBMONLfuJ(a095aOBN5nHg9L5fMZXmHg9XCbuZ8UaQSZMyMpuCczIEwwqn6lR5r2yERmVj0OVm)cISqXjmZJNvCizEZSMhXxZBL5XZkoKmVzM3eA0xMFAxurO2SUYMg5HqyMx8HIFyzEIaO4gSIHbKuAehm1EdYQ9PSUYg6X4dO(buV2hwXHsnMitBMONLfuJ(a09b09wM)SjM5N2fveQnRRSPrEieM18i(Y8wzE8SIdjZBM5nHg9L5nIdMAVbz1(uwxzd9y8Z8Ipu8dlZ71(WkouQXezAZe9SSGA0hGUphaDpa6oaQp7bqjkaQx7dR4qzTpLr2RIdz9Xwqeq9dOETpSIdLAmrM2mrpllOg9bOJcOBN5pBIzEJ4GP2BqwTpL1v2qpg)SMhzp5TY84zfhsM3mZBcn6lZ)Tk(fursM3Uj7Mr2oxMx8HIFyzEV2hwXHsnMitBMONLfuJ(a0rbuV2hwXHY(yliYelTR1m)ztmZ)Tk(fursM3Uj7Mr2oxwZJS3ZBL5XZkoKmVzM3eA0xM32Gvm0kEk7SLgUfmZl(qXpSmVx7dR4qPgtKPnt0ZYcQrFa6OaQx7dR4qzFSfezIL21AM)SjM5TnyfdTINYoBPHBbZAEKn08wzE8SIdjZBM5nHg9L5HPHx8zEXRNShDHiZl(qXpSmVx7dR4qPgtKPnt0ZYcQrFa6OaQx7dR4qzFSfezIL21AM)SjM5HPHx8zEXRNShDHiR5r2B5TY84zfhsM3mZBcn6lZx7VeKK4X6cmid7ycNnoZl(qXpSmVx7dR4qPgtKPnt0ZYcQrFa6OaQx7dR4qzFSfezIL21AM)SjM5R9xcss8yDbgKHDmHZgN18i((8wzE8SIdjZBM5nHg9L5tTF2xiyK40u8dZfeh(zESwrHYoBIz(u7N9fcgjonf)WCbXHFwZJ4Z25TY84zfhsM3mZBcn6lZpnxT)jsYsX3CKqMdjm(TbyMx8HIFyzEV2hwXHsnMitBMONLfuJ(a0r5aO7zpaQFaTSQvPONLfuJ(KK94dq9dOETpSIdLAmrM2mrpllOg9bOJcOETpSIdL9XwqKjwAxRz(ZMyMFAUA)tKKLIV5iHmhsy8BdWSMhXhFYBL5XZkoKmVzM3eA0xM3orGNYs(AL1v24as2ZmV4df)WY8ETpSIdLAmrM2mrpllOg9bOJYbq3ZEau)aAzvRsrpllOg9jj7XhG6hq9AFyfhk1yImTzIEwwqn6dqhfq9AFyfhk7JTGitS0UwZ8NnXmVDIapLL81kRRSXbKSNznpIpBmVvMhpR4qY8MzEtOrFz(dxV5yqUpBaIm8sTtGFMx8HIFyzEV2hwXHsnMitBMONLfuJ(a0r5aO(Y9aO(b0YQwLIEwwqn6ts2Jpa1pG61(WkouQXezAZe9SSGA0hGokG61(Wkou2hBbrMyPDTM5pBIz(dxV5yqUpBaIm8sTtGFwZAMNeR2YP5TYJ4tERmVj0OVmVOxNIpCaDUmpEwXHK5nZAEKnM3kZJNvCizEZmFpK5HOM5nHg9L59AFyfhM59AUfM5vZHNkRXJq1EfFjEwXHKakrbqRXJq1EfF5JtloiGUdGMaGk62r2JpPONLfuJ(KpoT4Gakrbqtaq9bqjEa1R9HvCOm54iDXrG9i5sOrFakrbqvZHNktoosxCeK4zfhscOjcOepGAcn6t(RdzDLn0JXxIedflfzAmraLOaOQ5WtL)6qwxzd9y8L4zfhscOjcOefaLiaQOBhzp(KIEwwqn6t(OrYnGsua0YQwLIEwwqn6ts2JVmVx7zNnXmVgtKPnt0ZYcQrFznpIVM3kZJNvCizEZmFpK5NgXY8MqJ(Y8ETpSIdZ8En3cZ8IUDK94toXz)CZ6kZTebjJ8rBcLpoT4GzEXhk(HL5riepbkN4SFUzDL5wIGKr(OnHYPr02pG6hqlRAvoXz)CZ6kZTebjJ8rBcLK94dq9dOIUDK94toXz)CZ6kZTebjJ8rBcLpoT4GakXdOETpSIdLAmrM2mrpllOg9bO7Zbq9AFyfhktBhjt0ZYcQrFmn9ryA7iZ8ETND2eZ8AmrM2mrpllOg9L18i(Y8wzE8SIdjZBM57Hm)0iwM3eA0xM3R9HvCyM3R5wyMx0TJShFYX97i9IXXEe2NDcu(40IdM5fFO4hwMhHq8eOCC)osVyCShH9zNaLtJOTFa1pGww1QCC)osVyCShH9zNaLK94dq9dOIUDK94toUFhPxmo2JW(StGYhNwCqaL4buV2hwXHsnMitBMONLfuJ(a095aOETpSIdLPTJKj6zzb1OpMM(imTDKzEV2ZoBIzEnMitBMONLfuJ(YAEK9K3kZJNvCizEZmVj0OVmVWCoMj0OpMlGAM3fqLD2eZ8HItilniKYg(O)q5oR5r275TY84zfhsM3mZl(qXpSmFzvRsrpllOg9jj7XxM3eA0xMFg)3plMgbmR5r2qZBL5XZkoKmVzMx8HIFyz(eauV2hwXHsnMitBMONLfuJ(a09buF2gq94bq1yImTzKbcO7dOETpSIdLAmrM2mrpllOg9bOjM5nHg9L5jSSNmSJ1vMrC43AAwZJS3YBL5nHg9L5f9jWtFtrsw1ztmZJNvCizEZSMhX3N3kZBcn6lZ)Onehbw1zteM5XZkoKmVzwZJ4Z25TY8MqJ(Y81wSGijZio8dfzf0MzE8SIdjZBM18i(4tERmVj0OVm)W6Jk3XrGvCguZ84zfhsM3mR5r8zJ5TY8MqJ(Y8Fmm4qwCm4GjWmpEwXHK5nZAEeF818wzEtOrFzEnfzRR0RJKv7xGzE8SIdjZBM18i(4lZBL5XZkoKmVzMx8HIFyz(YQwL)6qwxzd9y8LK94dq9dOLvTkf9SSGA0NKShFaQFanba1R9HvCOuJjY0Mj6zzb1OpaDuaTUCo2JIu7jGmnMiG6XdG61(WkouQXezAZe9SSGA0hGokGQ2tavPgtKPnJmqanXmVj0OVm)VoK1v2qpg)SMhXN9K3kZJNvCizEZmV4df)WY8ETpSIdLAmrM2mrpllOg9bO7Zbq3oZBcn6lZlmNJzcn6J5cOM5DbuzNnXmVONLfuJ(ydPgeZAEeF275TY84zfhsM3mZVGiBCA4qMWGACeYJ4tMx8HIFyz(eauecXtGYjo7NBwxzULiizKpAtOCAeT9dOE8aOieINaLtC2p3SUYClrqYiF0Mq5mU(bu)aQrC4hkklodQ4ZMguXxINvCijGMiG6hqfP2taHakhaDAeJjsTNacbu)akra0YQwLPTYG6JwYYhnHcO(buIaOjaOLvTktrtJJaBniF0ekG6hqtaqlRAvk6zzb1Op5Aaq9dOjaOMqJ(K14XI5CY4yvxqivbupEautOrFYbU)U4mOkJJvDbHufq94bqnHg9jHI(fPsKyOyPXraqteq94bqv7jGQmfnNMkhekGUpha1x3gq9dOMqJ(Kqr)IujsmuS04iaOjcOjcO(buIaOjaOebqlRAvMIMghb2Aq(Ojua1pGseaTSQvzARmO(OLS8rtOaQFaTSQvPONLfuJ(KK94dq9dOjaOMqJ(K14XI5CY4yvxqivbupEautOrFYbU)U4mOkJJvDbHufqteqtmZVGiRRvgbbzEeFY8MqJ(Y814rwXzqnR5r8zdnVvMhpR4qY8Mz(EiZdrnZBcn6lZ71(WkomZ71ClmZRMdpv(RdzDLn0JXxINvCijG6hqfD7i7XN8xhY6kBOhJV8XPfheq3hqfD7i7XNSgpYkodQY6Y5ypksTNaY0yIaQFanba1R9HvCOuJjY0Mj6zzb1OpaDua1eA0N8xhY6kBOhJVSUCo2JIu7jGmnMiGMiG6hqtaqfD7i7XN8xhY6kBOhJV8XPfheq3hq1yImTzKbcOE8aOMqJ(K)6qwxzd9y8LIu7jGqaDuaDBanra1Jha1R9HvCOuJjY0Mj6zzb1OpaDFa1eA0NSgpYkodQY6Y5ypksTNaY0yIaQFa1R9HvCOuJjY0Mj6zzb1OpaDFavJjY0MrgyM3R9SZMyMVgpYkodQSHUDXriR5r8zVL3kZJNvCizEZmV4df)WY8LvTk)1HSUYg6X4lxdaQFanba1R9HvCOuJjY0Mj6zzb1OpaDuaDBanXmpu)qO5r8jZBcn6lZlmNJzcn6J5cOM5DbuzNnXm)3dSHudIznpIp((8wzE8SIdjZBM57Hmpe1mVj0OVmVx7dR4WmVxZTWmVAo8u5VoK1v2qpgFjEwXHKaQFav0TJShFYFDiRRSHEm(YhNwCqaDFav0TJShFYH0gVGySQZMiuwxoh7rrQ9eqMgteq9dOjaOETpSIdLAmrM2mrpllOg9bOJcOMqJ(K)6qwxzd9y8L1LZXEuKApbKPXeb0ebu)aAcaQOBhzp(K)6qwxzd9y8LpoT4Ga6(aQgtKPnJmqa1Jha1eA0N8xhY6kBOhJVuKApbecOJcOBdOjcOE8aOETpSIdLAmrM2mrpllOg9bO7dOMqJ(KdPnEbXyvNnrOSUCo2JIu7jGmnMiG6hq9AFyfhk1yImTzIEwwqn6dq3hq1yImTzKbM59Ap7SjM5hsB8cIXg62fhHSMhzJBN3kZJNvCizEZm)cISXPHdzcdQXripIpzEXhk(HL5taqjcG61(WkouwJhzfNbv2q3U4iaOE8aOLvTk)1HSUYg6X4lxdaAIaQFanba1R9HvCOuJjY0Mj6zzb1OpaDuaDBanra1pGMaGAcn8Im8WzGqaDuoaQx7dR4qzQ9KmHbvw1zteQFKmcO(b0eaunMiGs8aAzvRsrpllOg9jDguziXgIhb0rbuV2hwXHss0zCZQoBIq9JKranranra1pGseaTgpcv7v8LMqdViG6hqlRAvM2kdQpAjlj7XhG6hqtaqjcGAeh(HIYIZGk(SPbv8L4zfhscOE8aOLvTklodQ4ZMguXx(40IdcO7dOBl3dGMyMFbrwxRmccY8i(K5nHg9L5RXJSIZGAwZJSrFYBL5XZkoKmVzMFbr240WHmHb14iKhXNmV4df)WY814rOAVIV0eA4fbu)aQi1EcieqhLdG6dG6hqtaqjcG61(WkouwJhzfNbv2q3U4iaOE8aOLvTk)1HSUYg6X4lxdaAIaQFanbaLiaQrC4hkklodQ4ZMguXxINvCijG6XdGww1QS4mOIpBAqfF5JtloiGUpGUTCpaAIaQFanbaLiaQj0OpznESyoNejgkwACeau)akrautOrFYbU)U4mOkJJvDbHufq9dOLvTktrtJJaBnixdaQhpaQj0OpznESyoNejgkwACeau)aAzvRY0wzq9rlzjzp(aupEautOrFYbU)U4mOkJJvDbHufq9dOLvTktrtJJaBnij7XhG6hqlRAvM2kdQpAjlj7XhGMyMFbrwxRmccY8i(K5nHg9L5RXJSIZGAwZJSXnM3kZJNvCizEZmV4df)WY8ETpSIdLAmrM2mrpllOg9bOJcOBN5H6hcnpIpzEtOrFzEH5CmtOrFmxa1mVlGk7SjM5HQDK2tY(wnn6lRznZhkoHmrpllOg9L3kpIp5TY84zfhsM3mZF2eZ8bHl0Op20iGqwDbXmVj0OVmFq4cn6JnnciKvxqmR5r2yERmpEwXHK5nZ8MqJ(Y8PCpGVM(OrYg)buh)2amZl(qXpSmFzvRsrpllOg9jxdaQFa1eA0NSgpYkodQsrQ9eqiGYbq3gq9dOMqJ(K14rwXzqv(Oi1EcitJjcOJcOeeKYPrSm)ztmZNY9a(A6JgjB8hqD8BdWSMhXxZBL5XZkoKmVzM)SjM5N2fveQnRRSPrEieM5nHg9L5N2fveQnRRSPrEieM18i(Y8wz(YQwzNnXm)0UOIqTzDLnnYdHqMi1gu8z9HzEXhk(HL5lRAvk6zzb1Op5Aaq94bqnHg9jNOI9lJJvDbHufq9dOMqJ(KtuX(LXXQUGqQYECAXbb095aOBl3tMFbrwxRmccY8i(K5nHg9L5f2jqhRSQ1mpEwXHK5nZAEK9K3kZJNvCizEZm)ztmZBe36rnTHmyCeqs2GBnncyMFbrwxRmccY8i(K5nHg9L5nIB9OM2qgmocijBWTMgbmZl(qXpSmFzvRsrpllOg9jxdaQhpaQj0Op5evSFzCSQliKQaQFa1eA0NCIk2Vmow1fesv2JtloiGUphaDB5EYAEK9EERmpEwXHK5nZ8MqJ(Y8eCgzyA)qwXijGz(fezDTYiiiZJ4tMx8HIFyz(YQwLIEwwqn6tUgaupEautOrFYjQy)Y4yvxqivbu)aQj0Op5evSFzCSQliKQShNwCqaDFoa62Y9K5XAffk7SjM5j4mYW0(HSIrsaZAEKn08wzE8SIdjZBM5nHg9L5j4mYW0(HSjsAox0xMFbrwxRmccY8i(K5fFO4hwMVSQvPONLfuJ(KRba1Jha1eA0NCIk2Vmow1fesva1pGAcn6torf7xghR6ccPk7XPfheq3NdGUTCpzESwrHYoBIzEcoJmmTFiBIKMZf9L18i7T8wzE8SIdjZBM5pBIz(I5WA8iR82jsZ8liY6ALrqqMhXNmVj0OVmFXCynEKvE7ePzEXhk(HL5lRAvk6zzb1Op5Aaq94bqnHg9jNOI9lJJvDbHufq9dOMqJ(KtuX(LXXQUGqQYECAXbb095aOBl3twZJ47ZBL5XZkoKmVzM)SjM5HPTi5sO4dzv7iK5xqK11kJGGmpIpzEtOrFzEyAlsUek(qw1oczEXhk(HL5lRAvk6zzb1Op5Aaq94bqnHg9jNOI9lJJvDbHufq9dOMqJ(KtuX(LXXQUGqQYECAXbb095aOBl3twZJ4Z25TY84zfhsM3mZF2eZ8kXzhczf7tgoehcZ8liY6ALrqqMhXNmVj0OVmVsC2HqwX(KHdXHWmV4df)WY8LvTkf9SSGA0NCnaOE8aOMqJ(KtuX(LXXQUGqQcO(butOrFYjQy)Y4yvxqivzpoT4Ga6(Ca0TL7jR5r8XN8wzE8SIdjZBM5pBIzE7ebEkl5RvwxzJdizpZ8liY6ALrqqMhXNmVj0OVmVDIapLL81kRRSXbKSNzEXhk(HL5lRAvk6zzb1Op5Aaq94bqnHg9jNOI9lJJvDbHufq9dOMqJ(KtuX(LXXQUGqQYECAXbb095aOBl3twZJ4ZgZBL5XZkoKmVzM)SjM5pC9MJb5(SbiYWl1ob(z(fezDTYiiiZJ4tM3eA0xM)W1BogK7ZgGidVu7e4N5fFO4hwMVSQvPONLfuJ(KRba1Jha1eA0NCIk2Vmow1fesva1pGAcn6torf7xghR6ccPk7XPfheq3NdGUTCpznpIp(AERmpEwXHK5nZ8NnXm)0C1(NijlfFZrczoKW43gGz(fezDTYiiiZJ4tM3eA0xMFAUA)tKKLIV5iHmhsy8BdWmV4df)WY8LvTkf9SSGA0NCnaOE8aOMqJ(KtuX(LXXQUGqQcO(butOrFYjQy)Y4yvxqivzpoT4Ga6(Ca0TL7jRznZp8OONftZBLhXN8wzEtOrFzE7f2HS4u05qHM5XZkoKmVzwZJSX8wzE8SIdjZBM57Hmpe1mVj0OVmVx7dR4WmVxZTWmpUbRyyajLt7Ikc1M1v20ipecbupEauCdwXWaskj4mYW0(HSIrsabupEauCdwXWaskj4mYW0(HSjsAox0hG6XdGIBWkggqszq4cn6JnnciKvxqeq94bqXnyfddiPujo7qiRyFYWH4qiG6XdGIBWkggqsPrCRh10gYGXrajzdU10iGaQhpakUbRyyajL2jc8uwYxRSUYghqYEcOE8aO4gSIHbKuctBrYLqXhYQ2raq94bqXnyfddiP8W1BogK7ZgGidVu7e4dOE8aO4gSIHbKuwmhwJhzL3orAM3R9SZMyMx0ZYcQrFS(yliM18i(AERmpEwXHK5nZ89qMhIAM3eA0xM3R9HvCyM3R5wyMh3GvmmGKsJ4GP2BqwTpL1v2qpgFa1pG61(Wkouk6zzb1OpwFSfeZ8ETND2eZ81(ugzVkoK1hBbXSMhXxM3kZJNvCizEZmFpK5HOM5nHg9L59AFyfhM59AUfM5342akrbqtaq9AFyfhkf9SSGA0hRp2cIaQFaLiaQx7dR4qzTpLr2RIdz9Xwqeqteq3bq9LBdOefanba1R9HvCOS2NYi7vXHS(ylicOjcO7aOBCpakrbqtaqXnyfddiP0ioyQ9gKv7tzDLn0JXhq9dOebq9AFyfhkR9PmYEvCiRp2cIaAIa6oa6EdqjkaAcakUbRyyajLt7Ikc1M1v20ipecbu)akrauV2hwXHYAFkJSxfhY6JTGiGMyM3R9SZMyMVp2cImXs7AnR5r2tERmpEwXHK5nZ89qM)riQzEtOrFzEV2hwXHzEV2ZoBIz(02rYe9SSGA0httFeM2oYmpjwTLtZ8BC7SMhzVN3kZJNvCizEZmFpK5HOM5nHg9L59AFyfhM59AUfM53iGsuau1C4PYQZMiBWurQepR4qsaDha1377buIcGseavnhEQS6SjYgmvKkXZkoKmZl(qXpSmVx7dR4qzARmO(OLmR6Sjc1psgbuoa62zEV2ZoBIz(0wzq9rlzw1zteQFKmM18iBO5TY84zfhsM3mZ3dzEiQzEtOrFzEV2hwXHzEVMBHzEFfqjkaQAo8uz1ztKnyQivINvCijGUdG6799akrbqjcGQMdpvwD2ezdMksL4zfhsM5fFO4hwM3R9HvCOm1EsMWGkR6Sjc1psgbuoa62zEV2ZoBIz(u7jzcdQSQZMiu)izmR5r2B5TY84zfhsM3mZ3dz(hHOM5nHg9L59AFyfhM59Ap7SjM5jrNXnR6Sjc1psgZ8Ky1wonZVX9K18i((8wzE8SIdjZBM57Hm)JquZ8MqJ(Y8ETpSIdZ8ETND2eZ8jhhPlocShjxcn6lZtIvB50m)2YnM18i(SDERmpEwXHK5nZ8NnXmVrCWu7niR2NY6kBOhJFM3eA0xM3ioyQ9gKv7tzDLn0JXpR5r8XN8wzEtOrFz(z8F)SyAeWmpEwXHK5nZAEeF2yERmVj0OVm)qRrFzE8SIdjZBM18i(4R5TY8MqJ(Y8dC)DXzqnZJNvCizEZSM1mpuTJ0Es23QPrF5TYJ4tERmpEwXHK5nZ8Ipu8dlZNaGAcn8Im8WzGqaDuoaQx7dR4qzARmO(OLmR6Sjc1psgbu)aAcaQgteqjEaTSQvPONLfuJ(KodQmKydXJa6OaQx7dR4qjj6mUzvNnrO(rYiGMiGMiG6hqlRAvM2kdQpAjlF0eAM3eA0xMV6Sjc1psgZAEKnM3kZJNvCizEZmV4df)WY8LvTktBLb1hTKLpAcfq9dOLvTktBLb1hTKLpoT4Ga6(aQj0OpznESyoNejgkwkY0yIzEtOrFz(bU)U4mOM18i(AERmpEwXHK5nZ8Ipu8dlZxw1QmTvguF0sw(Ojua1pGMaGo8OxgbbP0hznESyohG6XdGwJhHQ9k(stOHxeq94bqnHg9jh4(7IZGQmow1fesva1JhaD2EJJaGMyM3eA0xMFG7VlodQznpIVmVvMhpR4qY8MzEXhk(HL5fP2taHa6OCauFfq9dOMqdVidpCgieqhfq3iG6hqjcG61(WkouoK24feJn0TloczEtOrFz(H0gVGySQZMimR5r2tERmpEwXHK5nZ8Ipu8dlZxw1QmTvguF0sw(Ojua1pGMaGQ2tavzkAonvoiuaDFoaQVUnG6hqvZHNkHO9XrGP9sKkXZkoKeq94bqHdOZXeFOa6OCauFa0eZ8MqJ(Y8dC)DXzqnR5r275TY84zfhsM3mZl(qXpSmFzvRYbU)w4m4u(Ojua1pGkmOY0yIa6(aAzvRYbU)w4m4u(40IdM5nHg9L5h4(7IZGAwZJSHM3kZJNvCizEZm)cISXPHdzcdQXripIpzEXhk(HL5taqlRAv(RdzDLn0JXxs2Jpa1pGseaTgpcv7v8LMqdViGMiG6hqjcG61(WkouwJhzfNbv2q3U4iaO(b0ea0ea0eautOrFYA8yXCojsmuS04iaOE8aOMqJ(KdC)DXzqvIedflnocaAIaQFaTSQvzkAACeyRb5JMqb0ebupEa0ea0eau1C4PsiAFCeyAVePs8SIdjbu)aQApbuLPO50u5Gqb095aO(62aQhpakCaDoM4dfqhLdG6dGMiG6hqtaqlRAvMIMghb2Aq(Ojua1pGsea1eA0Nek6xKkrIHILghba1JhaLiaAzvRY0wzq9rlz5JMqbu)akra0YQwLPOPXrGTgKpAcfq9dOMqJ(Kqr)IujsmuS04iaO(buIaOMqJ(KdC)DXzqvghR6ccPkG6hqjcGAcn6twJhlMZjJJvDbHufqteqteqtmZVGiRRvgbbzEeFY8MqJ(Y814rwXzqnR5r2B5TY84zfhsM3mZl(qXpSmFcaAzvRYu004iWwdYhnHcOE8aOjaOebqlRAvM2kdQpAjlF0ekG6hqtaqnHg9jRXJSIZGQuKApbecOJcOBdOE8aOQ5WtLq0(4iW0EjsL4zfhscO(bu1EcOktrZPPYbHcO7Zbq91TbupEau4a6CmXhkGokha1hanranranra1pGsea1R9HvCOCiTXligBOBxCeY8MqJ(Y8dPnEbXyvNnrywZJ47ZBL5XZkoKmVzM3eA0xMxyohZeA0hZfqnZ7cOYoBIzEtOHxKPMdpfM18i(SDERmpEwXHK5nZ8Ipu8dlZBcn8Im8WzGqaDua1NmVj0OVmp5Be6dYkpAAAwZJ4Jp5TY84zfhsM3mZBcn6lZlmNJzcn6J5cOM5DbuzNnXmFO4eYC9y2Wh9hk3znpIpBmVvMhpR4qY8MzEXhk(HL5v7jGQmfnNMkhekGUpha1x3gq9dOQ5WtLq0(4iW0EjsL4zfhscOE8aOWb05yIpuaDuoaQpzEtOrFzEOOFrAwZJ4JVM3kZJNvCizEZmV4df)WY8MqdVidpCgieqhLdG61(WkouMApjtyqLvD2eH6hjJaQFanbavJjcOepGww1Qu0ZYcQrFsNbvgsSH4raDua1R9HvCOKeDg3SQZMiu)izeqtmZBcn6lZxD2eH6hjJznpIp(Y8wzEtOrFz(A8yXCUmpEwXHK5nZAEeF2tERmVj0OVmpu0VinZJNvCizEZSM1m)3dSHudI5TYJ4tERmpEwXHK5nZ8Ipu8dlZNaGAcn8Im8WzGqaDuoaQx7dR4qzARmO(OLmR6Sjc1psgbu)aAcaQgteqjEaTSQvPONLfuJ(KodQmKydXJa6OaQx7dR4qjj6mUzvNnrO(rYiG6XdG61(WkousgqR4qMONLfuJ(a0eb0ebu)aAzvRY0wzq9rlz5JMqZ8MqJ(Y8vNnrO(rYywZJSX8wzE8SIdjZBM5fFO4hwMVSQvzARmO(OLS8rtOzEtOrFz(bU)U4mOM18i(AERmpEwXHK5nZ8liYgNgoKjmOghH8i(K5fFO4hwMNiaAcaQj0WlYWdNbcb0r5aOETpSIdLP2tYeguzvNnrO(rYiG6hqtaq1yIakXdOLvTkf9SSGA0N0zqLHeBiEeqhfq9AFyfhkjrNXnR6Sjc1psgbupEauV2hwXHsYaAfhYe9SSGA0hGMiGMiG6hqjcGwJhHQ9k(stOHxeq9dOjaOebqlRAvMIMghb2Aq(Ojua1pGseaTSQvzARmO(OLS8rtOaQFaLia6WJEzDTYiiiL14rwXzqfq9dOjaOMqJ(K14rwXzqvksTNacb0r5aOBeq94bqtaqnHg9jhsB8cIXQoBIqPi1EcieqhLdG6dG6hqvZHNkhsB8cIXQoBIqjEwXHKaAIaQhpaAcaQAo8uP5qIb13GeNbz11ZTepR4qsa1pGk62r2Jpj5Be6dYkpAAQ8rJKBanra1JhanbavnhEQeI2hhbM2lrQepR4qsa1pGQ2tavzkAonvoiuaDFoaQVUnG6XdGchqNJj(qb0r5aO(aOjcOjcOjM5xqK11kJGGmpIpzEtOrFz(A8iR4mOM18i(Y8wzE8SIdjZBM5nHg9L5fMZXmHg9XCbuZ8UaQSZMyM3eA4fzQ5WtHznpYEYBL5XZkoKmVzMx8HIFyz(YQwLdC)TWzWP8rtOaQFavyqLPXeb09b0YQwLdC)TWzWP8XPfheq9dOLvTk)1HSUYg6X4lFCAXbb0rbuHbvMgtmZBcn6lZpW93fNb1SMhzVN3kZJNvCizEZm)cISXPHdzcdQXripIpzEXhk(HL5jcGMaGAcn8Im8WzGqaDuoaQx7dR4qzQ9KmHbvw1zteQFKmcO(b0eaunMiGs8aAzvRsrpllOg9jDguziXgIhb0rbuV2hwXHss0zCZQoBIq9JKra1Jha1R9HvCOKmGwXHmrpllOg9bOjcOjcO(buIaO14rOAVIV0eA4fbu)aAcaAzvRYu004iWwdYhnHcO(bu4a6CmXhkGUpG6dG6hqtaqv7jGQmfnNMkhekGokha1x3gq94bqjcGQMdpvcr7JJat7LivINvCijGMiGMyMFbrwxRmccY8i(K5nHg9L5RXJSIZGAwZJSHM3kZJNvCizEZm)cISXPHdzcdQXripIpzEXhk(HL5jcGMaGAcn8Im8WzGqaDuoaQx7dR4qzQ9KmHbvw1zteQFKmcO(b0eaunMiGs8aAzvRsrpllOg9jDguziXgIhb0rbuV2hwXHss0zCZQoBIq9JKra1Jha1R9HvCOKmGwXHmrpllOg9bOjcOjcO(buIaO14rOAVIV0eA4fbu)aAcaQAo8ujeTpocmTxIujEwXHKaQFavTNaQYu0CAQCqOa6(CauFDBa1JhafoGoht8HcOJYbq9bqteq9dOjaOLvTktrtJJaBniF0ekG6hqjcGAcn6tcf9lsLiXqXsJJaG6XdGseaTSQvzkAACeyRb5JMqbu)akra0YQwLPTYG6JwYYhnHcOjM5xqK11kJGGmpIpzEtOrFz(A8iR4mOM18i7T8wzE8SIdjZBM5fFO4hwMNia6WJEzeeKsFKdPnEbXyvNnriG6hqlRAvMIMghb2Aq(Oj0mVj0OVm)qAJxqmw1zteM18i((8wzE8SIdjZBM5fFO4hwMxTNaQYu0CAQCqOa6(CauFDBa1pGQMdpvcr7JJat7LivINvCijG6XdGchqNJj(qb0r5aO(K5nHg9L5HI(fPznpIpBN3kZJNvCizEZmV4df)WY8MqdVidpCgieqhfq3yM3eA0xMN8nc9bzLhnnnR5r8XN8wzE8SIdjZBM5fFO4hwMpba1eA4fz4HZaHa6OCauV2hwXHYu7jzcdQSQZMiu)izeq9dOjaOAmraL4b0YQwLIEwwqn6t6mOYqInepcOJcOETpSIdLKOZ4MvD2eH6hjJaQhpaQx7dR4qjzaTIdzIEwwqn6dqteqtmZBcn6lZxD2eH6hjJznpIpBmVvM3eA0xMVgpwmNlZJNvCizEZSM1SM59Ipm6lpYg3EJBV9E3hFzMFS9xCeGzEIgZH(vKeq99aQj0Opa1fqfkbjL5HdOipYE3xZ8dFxdhM59na1xepcOByJacsY3a0uvhGev3DxcHMUksrp3fgZLZ0OpXBvDxymf7csY3a09YfHfub0nYfGUXT342GKaj5Bakrp1ociKOkijFdqjEa13bIaQgtKPnJmqa9nnfFavtTdqv7jGQuJjY0MrgiGw7hqDgujEik6JeqTs4cLBaDbnciucsY3auIhq9Dginfbuxtiea6Jevb0nKLiib09QhTjucsY3auIhq3q6gIhGkmOcOpUbR4XjEkeqR9dOe9Ewwqn6dqtiKOKlaLSpIkkGM2osanuaT2pGAaA9rykGUHrf7hqfgutucsY3auIhq3RcOvCiGAhGIN(CdOAQPa64E5ib0hHlNcOXbOgGMApPWGkGUxZ93fNbvanoINGnrjijFdqjEaDV4zfhcOq9dHcOIuuKCCea0(audqR4yaT2FYqanoavtraDVCVEdbq1gqFKCjqaDC)j7AJucscKKVbO7fjgkwkscOfS2pcOIEwmfqliH4GsaDVuiWbfcOxFeFQ9Z6YbOMqJ(GaAFoULGK8na1eA0huo8OONft5uDgmzqs(gGAcn6dkhEu0ZIP7Wz3A3KGK8na1eA0huo8OONft3HZU2IWep10OpqsMqJ(GYHhf9Sy6oC21EHDilofDouOGKmHg9bLdpk6zX0D4SRx7dR4qUoBICe9SSGA0hRp2cIC1dCGOYLxZTqo4gSIHbKuoTlQiuBwxztJ8qi0JhCdwXWaskj4mYW0(HSIrsa94b3GvmmGKscoJmmTFiBIKMZf95XdUbRyyajLbHl0Op20iGqwDbrpEWnyfddiPujo7qiRyFYWH4qOhp4gSIHbKuAe36rnTHmyCeqs2GBnncOhp4gSIHbKuANiWtzjFTY6kBCaj7Php4gSIHbKuctBrYLqXhYQ2rWJhCdwXWaskpC9MJb5(SbiYWl1ob(E8GBWkggqszXCynEKvE7ePGKmHg9bLdpk6zX0D4SRx7dR4qUoBICQ9PmYEvCiRp2cIC1dCGOYLxZTqo4gSIHbKuAehm1EdYQ9PSUYg6X473R9HvCOu0ZYcQrFS(ylicsY3auIgkoHaQMAkGApcOliscO9sHbjcODfqj69SSGA0hGApcOxRa6cIKaQvv8bunnGaQgteqJkGQPi3a64E5ib0HLcOgGQFCjJkGUGijGoo0uaLO3ZYcQrFaAFaQbOWu7jrsav0TJShFsqsMqJ(GYHhf9Sy6oC21R9HvCixNnro9XwqKjwAxRC1dCGOYLxZTqoBCBIscETpSIdLIEwwqn6J1hBbr)eXR9HvCOS2NYi7vXHS(yliM4o(YTjkj41(Wkouw7tzK9Q4qwFSfetCNnUhIsc4gSIHbKuAehm1EdYQ9PSUYg6X47NiETpSIdL1(ugzVkoK1hBbXe3zVrusa3GvmmGKYPDrfHAZ6kBAKhcH(jIx7dR4qzTpLr2RIdz9Xwqmrqs(gGs07zzb1OpanGaAFoUb0fejb0XHM2lfqjA2VJ0lghG67oc7ZobcO9dOByC2p3aAxb0nKLiib09QhTjeqJkGgkGooCoaTGaQ51cNvCiGAkG6qdQaQMgqaDAh3akef9rcb0cw7hbunfbuecXtGevGaQOBhzp(a0acOpAKClbjzcn6dkhEu0ZIP7WzxV2hwXHCD2e5K2osMONLfuJ(yA6JW02rYvpW5riQCrIvB5uoBCBqs(gGUvAabuV2hwXHakCafrnqiGQPiGERzbFaTRaQApbuHaQPa640qKcOe1TcO86JwYaQVWzteQFKmcb0EPWGeb0UcOe9Ewwqn6dqHP9YrcOfeqxqKucsYeA0huo8OONft3HZUETpSId56SjYjTvguF0sMvD2eH6hjJC1dCGOYvu541(WkouM2kdQpAjZQoBIq9JKroBZLxZTqoBKOOMdpvwD2ezdMksL4zfhsUJV33tuiIAo8uz1ztKnyQivINvCijijFdq3knGaQx7dR4qafoGIOgieq1ueqV1SGpG2vavTNaQqa1uaDCAisbuIA7jbuIUbva1x4Sjc1psgHaAVuyqIaAxbuIEpllOg9bOW0E5ib0ccOliscOgeqRHZHVeKKj0OpOC4rrplMUdND9AFyfhY1ztKtQ9KmHbvw1zteQFKmYvpWbIkxrLJx7dR4qzQ9KmHbvw1zteQFKmYzBU8AUfYXxjkQ5WtLvNnr2GPIujEwXHK74799efIOMdpvwD2ezdMksL4zfhscsY3auFhyCeauFHZMiu)izeqTQIpGs07zzb1OpanGaA7fFavyhGkSfebudqHbHlQHWofqTzVofq7kGsAtJacOAdOfeqDnubuYfcOAdOAkcOTx8h)HghbaTRakrdcxOiGQPMcOTqSEiGoofpavtraLObHlueqRFpbuU71dOdFmTNBaLO3ZYcQrFaQApbubu4WJgjucOBLgqa1R9HvCiGgqaDbrsavBafoGIOYnGQPiGAZEDkG2vavJjcOXbOqu0hjeq1utb05cQa6GbHaQvv8buIEpllOg9bOiXgIhHaAbR9JaQVWzteQFKmcb0XHZbOfeqxqKeqV(NMZXTeKKj0OpOC4rrplMUdND9AFyfhY1ztKdj6mUzvNnrO(rYixKy1woLZg3dx9aNhHOcsY3auIMHMcO(UfhPlocCbOe9Ewwqn6JOceqfD7i7XhGooCoaTGa6JKlbscOfUbudqF7i7jGAZEDkxaAzPaQMIa6TMf8b0UcOIpuiGcv7viG6fFUb00GqkGAvfFa1eA4104iaOe9Ewwqn6dqTJeqHUEmeqj7XhGQ9y7jHaQMIakEKaAxbuIEpllOg9rubcOIUDK94tcOentXdqNwYXraqjrraJ(GaACaQMIa6E5E9gcxakrVNLfuJ(iQab0hNwCXraqfD7i7XhGgqa9rYLajb0c3aQMgqaT(MqJ(auTbuti61PaATFa13T4iDXrqcsYeA0huo8OONft3HZUETpSId56SjYj54iDXrG9i5sOrFCrIvB5uoBl3ix9aNhHOcsY3autOrFq5WJIEwmDho7cpBaM2kdQMcbjzcn6dkhEu0ZIP7Wz3fezHItUoBICmIdMAVbz1(uwxzd9y8bjzcn6dkhEu0ZIP7Wz3z8F)SyAeqqsMqJ(GYHhf9Sy6oC2DO1OpqsMqJ(GYHhf9Sy6oC2DG7VlodQGKaj5Ba6ErIHILIKak6fFUbunMiGQPiGAcTFanGaQ51cNvCOeKKj0OpihrVofF4a6CGKmHg9b3HZUETpSId56SjYrJjY0Mj6zzb1OpU6boqu5YR5wih1C4PYA8iuTxXxINvCijrPgpcv7v8LpoT4G7KGOBhzp(KIEwwqn6t(40IdsusWhI3R9HvCOm54iDXrG9i5sOrFef1C4PYKJJ0fhbjEwXHKjs8MqJ(K)6qwxzd9y8LiXqXsrMgtKOOMdpv(RdzDLn0JXxINvCizIefIi62r2JpPONLfuJ(KpAKCtukRAvk6zzb1Opjzp(ajzcn6dUdND9AFyfhY1ztKJgtKPnt0ZYcQrFC1dCMgX4YR5wihr3oYE8jN4SFUzDL5wIGKr(OnHYhNwCqUIkhecXtGYjo7NBwxzULiizKpAtOCAeT97VSQv5eN9ZnRRm3seKmYhTjus2Jp)IUDK94toXz)CZ6kZTebjJ8rBcLpoT4GeVx7dR4qPgtKPnt0ZYcQrF7ZXR9HvCOmTDKmrpllOg9X00hHPTJeKKj0Op4oC21R9HvCixNnroAmrM2mrpllOg9XvpWzAeJlVMBHCeD7i7XNCC)osVyCShH9zNaLpoT4GCfvoieINaLJ73r6fJJ9iSp7eOCAeT97VSQv54(DKEX4ypc7Zobkj7XNFr3oYE8jh3VJ0lgh7ryF2jq5JtloiX71(WkouQXezAZe9SSGA03(C8AFyfhktBhjt0ZYcQrFmn9ryA7ibjzcn6dUdNDfMZXmHg9XCbu56SjYjuCczPbHu2Wh9hk3GKmHg9b3HZUZ4)(zX0iGCfvoLvTkf9SSGA0NKShFGKmHg9b3HZUew2tg2X6kZio8BnLROYjbV2hwXHsnMitBMONLfuJ(23NT94rJjY0Mrg4(ETpSIdLAmrM2mrpllOg9LiijtOrFWD4SROpbE6BksYQoBIGKmHg9b3HZUpAdXrGvD2eHGKmHg9b3HZU1wSGijZio8dfzf0MGKmHg9b3HZUdRpQChhbwXzqfKKj0Op4oC29JHbhYIJbhmbcsYeA0hCho7QPiBDLEDKSA)ceKKj0Op4oC29xhY6kBOhJpxrLtzvRYFDiRRSHEm(sYE85VSQvPONLfuJ(KK94ZFcETpSIdLAmrM2mrpllOg9nAD5CShfP2tazAmrpE8AFyfhk1yImTzIEwwqn6Bu1EcOk1yImTzKbMiijtOrFWD4SRWCoMj0OpMlGkxNnroIEwwqn6JnKAqKROYXR9HvCOuJjY0Mj6zzb1OV95SnijtOrFWD4SBnEKvCgu5AbrwxRmccso(W1cISXPHdzcdQXrGJpCfvojGqiEcuoXz)CZ6kZTebjJ8rBcLtJOTFpEqiepbkN4SFUzDL5wIGKr(OnHYzC973io8dfLfNbv8ztdQ4lXZkoKmr)Iu7jGqotJymrQ9eqOFIuw1QmTvguF0sw(Oju)ejHYQwLPOPXrGTgKpAc1FcLvTkf9SSGA0NCn4pbtOrFYA8yXCozCSQliKQE8ycn6toW93fNbvzCSQliKQE8ycn6tcf9lsLiXqXsJJqIE8O2tavzkAonvoi0954RB73eA0Nek6xKkrIHILghHet0prsGiLvTktrtJJaBniF0eQFIuw1QmTvguF0sw(Oju)LvTkf9SSGA0NKShF(tWeA0NSgpwmNtghR6ccPQhpMqJ(KdC)DXzqvghR6ccPAIjcsYeA0hCho761(WkoKRZMiNA8iR4mOYg62fhbU8AUfYrnhEQ8xhY6kBOhJVepR4qs)IUDK94t(RdzDLn0JXx(40IdUVOBhzp(K14rwXzqvwxoh7rrQ9eqMgt0FcETpSIdLAmrM2mrpllOg9nQj0Op5VoK1v2qpgFzD5CShfP2tazAmXe9NGOBhzp(K)6qwxzd9y8LpoT4G7RXezAZid0JhtOrFYFDiRRSHEm(srQ9eq4OBNOhpETpSIdLAmrM2mrpllOg9TVj0OpznEKvCguL1LZXEuKApbKPXe971(WkouQXezAZe9SSGA03(AmrM2mYabjzcn6dUdNDfMZXmHg9XCbu56SjY57b2qQbrUG6hcLJpCfvoLvTk)1HSUYg6X4lxd(tWR9HvCOuJjY0Mj6zzb1OVr3orqsMqJ(G7WzxV2hwXHCD2e5mK24feJn0TlocC51ClKJAo8u5VoK1v2qpgFjEwXHK(fD7i7XN8xhY6kBOhJV8XPfhCFr3oYE8jhsB8cIXQoBIqzD5CShfP2tazAmr)j41(WkouQXezAZe9SSGA03OMqJ(K)6qwxzd9y8L1LZXEuKApbKPXet0FcIUDK94t(RdzDLn0JXx(40IdUVgtKPnJmqpEmHg9j)1HSUYg6X4lfP2taHJUDIE841(WkouQXezAZe9SSGA03(MqJ(KdPnEbXyvNnrOSUCo2JIu7jGmnMOFV2hwXHsnMitBMONLfuJ(2xJjY0MrgiijFdqjAMIhGsuBpPWGACeauFHZMiGYRFKmYfG6lIhb0nDguHakmTxosaTGa6cIKaQ2akb8W3ueqjQBfq51hTKHaQDKaQ2aksmfpsaDtNbv8b0nSbv8LGKmHg9b3HZU14rwXzqLRfezDTYiii54dxliYgNgoKjmOghbo(Wvu5Kar8AFyfhkRXJSIZGkBOBxCe84PSQv5VoK1v2qpgF5Air)j41(WkouQXezAZe9SSGA03OBNO)emHgErgE4mq4OC8AFyfhktTNKjmOYQoBIq9JKr)jOXej(YQwLIEwwqn6t6mOYqInepoQx7dR4qjj6mUzvNnrO(rYyIj6Ni14rOAVIV0eA4f9xw1QmTvguF0sws2Jp)jqeJ4WpuuwCguXNnnOIVepR4qspEkRAvwCguXNnnOIV8XPfhC)TL7jrqs(gGUxT(4iaO(I4rOAVIpxaQViEeq30zqfcO2Ja6cIKakmMHZEh3aQ2ak56JJaGs07zzb1OpjG67A8W3CoU5cq1uKBa1EeqxqKeq1gqjGh(MIakrDRakV(OLmeqhNIhGk(qHa64W5a0RvaTGa6ydQijGAhjGoo0uaDtNbv8b0nSbv85cq1uKBafM2lhjGwqafo8OrcO9sbuTb0PfNAXbOAkcOB6mOIpGUHnOIpGww1QeKKj0Op4oC2TgpYkodQCTGiRRvgbbjhF4Abr240WHmHb14iWXhUIkNA8iuTxXxAcn8I(fP2taHJYXh)jqeV2hwXHYA8iR4mOYg62fhbpEkRAv(RdzDLn0JXxUgs0FceXio8dfLfNbv8ztdQ4lXZkoK0JNYQwLfNbv8ztdQ4lFCAXb3FB5Es0FceXeA0NSgpwmNtIedflnoc(jIj0Op5a3FxCguLXXQUGqQ6VSQvzkAACeyRb5AWJhtOrFYA8yXCojsmuS04i4VSQvzARmO(OLSKShFE8ycn6toW93fNbvzCSQliKQ(lRAvMIMghb2Aqs2Jp)LvTktBLb1hTKLK94lrqsMqJ(G7WzxH5CmtOrFmxavUoBICGQDK2tY(wnn6JlO(Hq54dxrLJx7dR4qPgtKPnt0ZYcQrFJUnijqsMqJ(GstOHxKPMdpfYXfEJJaR0ZcxrLJj0WlYWdNbch1h)LvTkf9SSGA0NKShF(tWR9HvCOuJjY0Mj6zzb1OVrfD7i7XN0fEJJaR0ZIKC9Mg95XJx7dR4qPgtKPnt0ZYcQrF7Zz7ebjzcn6dknHgErMAo8u4oC2DIk2pxrLJx7dR4qPgtKPnt0ZYcQrF7ZzBpEsOSQv5VoK1v2qpgF5AWJhr3oYE8j)1HSUYg6X4lFCAXbhvJjY0MrgOFtOrFYFDiRRSHEm(srQ9eq4((4XdruZHNk)1HSUYg6X4lXZkoKmr)ji62r2Jp5evSFj56nn6BFV2hwXHsnMitBMONLfuJ(84rJjY0Mrg4(ETpSIdLAmrM2mrpllOg9LiijtOrFqPj0WlYuZHNc3HZUKVrOpiR8OPPCfvoQ5WtLMdjguFdsCgKvxp3s8SIdj9NqzvRsrpllOg9jj7XNFIuw1QmTvguF0sw(OjupEkRAvk6zzb1Op5AWVj0OpznEKvCguLIu7jGW9nHg9jRXJSIZGQCAeJjsTNac9tKYQwLPTYG6JwYYhnHMiijqs(gGs07zzb1OpaDi1GiGo84G9ieqTs4cnqiGoo0ua1aus0zCZfGQP4bOoBDIuecOXPnGQPiGs07zzb1OpafIBWcpbcsYeA0huk6zzb1Op2qQbroUGqQczeTlsct8uUIkNYQwLIEwwqn6ts2JpqsMqJ(GsrpllOg9XgsniUdNDlgbwxz6hIKHCfvoLvTkf9SSGA0NKShFGKmHg9bLIEwwqn6JnKAqCho76cVXrGv6zHROYXeA4fz4HZaHJ6J)YQwLIEwwqn6ts2JpqsMqJ(GsrpllOg9XgsniUdNDlUUjzDLPPidpCYnijtOrFqPONLfuJ(ydPge3HZUtC2p3SUYClrqYiF0MqqsMqJ(GsrpllOg9XgsniUdNDh3VJ0lgh7ryF2jqqs(gGUxT(4iaOe9Ewwqn6Jla1xepcOB6mOcbu7raDbrsavBaLaE4BkcOe1TcO86JwYqa1osaDgxmdIdbunfbuB2Rtb0UcOAmrafoGNcOiXqXsJJaG2Ak(akCaDoOeq9f9dOq1os7jbuFr8ixaQViEeq30zqfcO2JaAFoUb0fejb0XP4bOe1OPXraq9Dga0acOMqdViG2pGoofpa1auEr)IuavyqfqdiGghGo8nHhHqa1osaLOgnnocaQVZaGAhjGsu3kGYRpAjdO2Ja61kGAcn8IsaLOzOPa6ModQ4dOBydQ4dO2rcO(cNnra13LJla1xepcOB6mOcbuHDaQrsgA0N5CCdOfeqxqKeqhNgoeqjQBfq51hTKbu7ibuIA004iaO(odaQ9iGETcOMqdViGAhjGAa6En3FxCgub0acOXbOAkcOw8aQDKaQ5GnGoonCiGkmOghbaLx0VifqrV4bOrfqjQrtJJaG67maObeqn3Jgj3aQj0Wlkb0Tsra1zQIpGAoxpgcO64gqjQBfq51hTKb09AU)U4mOcbuTb0ccOcdQaACakCjeieg9bOwvXhq1ueq5f9lsLa6EjjzOrFMZXnGoo0uaDtNbv8b0nSbv8bu7ibuFHZMiG67YXfG6lIhb0nDguHakmTxosa9AfqliGUGijGUohcHa6ModQ4dOBydQ4dObeqTsVuavBafj2q8iG2pGQP4JaQ9iGo7hbun1oafVErifq9fXJa6ModQqavBafjMIhjGUPZGk(a6g2Gk(aQ2aQMIakEKaAxbuIEpllOg9jbjzcn6dkf9SSGA0hBi1G4oC2TgpYkodQCTGiRRvgbbjhF4Abr240WHmHb14iWXhUIkhrQ9eq4OC8XFcjycn6twJhzfNbvPi1EciKvFtOrFMBNekRAvk6zzb1Op5JtloiXxw1QS4mOIpBAqfFj56nn6lX9cIUDK94twJhzfNbvj56nn6J4tOSQvPONLfuJ(KpoT4GjUxiHYQwLfNbv8ztdQ4ljxVPrFe)2Y9KyIJYzBpEiIrC4hkklodQ4ZMguXxINvCiPhpernhEQS6SjY6tINvCiPhpLvTkf9SSGA0N8XPfhCFoLvTklodQ4ZMguXxsUEtJ(84PSQvzXzqfF20Gk(YhNwCW93wUhpEWnyfddiPmL7b810hns24pG643gG(fD7i7XNmL7b810hns24pG643gGmFD7T9XxUr5Jtlo4(7jr)LvTkf9SSGA0NCn4pbIycn6tcf9lsLiXqXsJJGFIycn6toW93fNbvzCSQliKQ(lRAvMIMghb2AqUg84XeA0Nek6xKkrIHILghb)LvTktBLb1hTKLK94ZFcLvTktrtJJaBnij7XNhpgXHFOOS4mOIpBAqfFjEwXHKj6XJrC4hkklodQ4ZMguXxINvCiPF1C4PYQZMiRpjEwXHK(nHg9jh4(7IZGQmow1fesv)LvTktrtJJaBnij7XN)YQwLPTYG6JwYsYE8LiijtOrFqPONLfuJ(ydPge3HZU)6qwxzd9y85kQCkRAv(RdzDLn0JXxs2Jp)LvTkf9SSGA0NKShFGK8naDVeq9fXJa6ModQakmTxosaTGa6cIKaQ2aQnm44gq30zqfFaDdBqfFaDCA4qavyqnocaQV7Rdb0UcO719y8b0XP4bOlyCea0nDguXhq3WguXNla1x4SjcO(UCCbO2rcOByuX(LakrJkG2NJBaDdJZ(5gq7kGUHSebjGUx9OnHa6goU(b0acO4gSIHbKKlavtdiG6Idb0acObHRFKeqlOWwqeqdfqhhohGc7jQXeHa6JWLtb04aucDCea040gqj69SSGA0hGoo0uaTIJbuFr8iGUPZGkGksTNacLGKmHg9bLIEwwqn6JnKAqCho7wJhzfNbvUwqKnonCityqnocC8HROYXio8dfLfNbv8ztdQ4lXZkoK0FcieINaLtC2p3SUYClrqYiF0Mq50iA73JhIGqiEcuoXz)CZ6kZTebjJ8rBcLZ46pr)Q5WtLtuX(L4zfhs6xnhEQS6SjY6tINvCiP)YQwLfNbv8ztdQ4lj7XN)euZHNk)1HSUYg6X4lXZkoK0Vj0Op5VoK1v2qpgFjsmuS04i43eA0N8xhY6kBOhJVejgkwkYECAXb3FB5E3JNe8AFyfhk1yImTzIEwwqn6BFoB7XtzvRsrpllOg9jxdj6NiQ5WtL)6qwxzd9y8L4zfhs6NiMqJ(KdC)DXzqvghR6ccPQFIycn6twJhlMZjJJvDbHunrqsMqJ(GsrpllOg9XgsniUdNDfMZXmHg9XCbu56SjYXeA4fzQ5WtHGKmHg9bLIEwwqn6JnKAqCho7k6zzb1OpUwqK11kJGGKJpCTGiBCA4qMWGACe44dxrLtcjycn6torf7xghR6ccPQFtOrFYjQy)Y4yvxqivzpoT4G7ZzB5Es0JhtOrFYjQy)Y4yvxqiv94bHq8eOCIZ(5M1vMBjcsg5J2ekNgrB)E8uw1QmTvguF0sw(OjupEmHg9jHI(fPsKyOyPXrWVj0Opju0VivIedflfzpoT4G7VTCpE8ycn6toW93fNbvjsmuS04i43eA0NCG7VlodQsKyOyPi7XPfhC)TL7jr)juw1Q8xhY6kBOhJVCn4XdruZHNk)1HSUYg6X4lXZkoKmrqsMqJ(GsrpllOg9XgsniUdNDhAn6dKKj0OpOu0ZYcQrFSHudI7Wz3IRBswD9CdsYeA0huk6zzb1Op2qQbXD4SBbFi(jhhbqsMqJ(GsrpllOg9XgsniUdNDRXJfx3KGKmHg9bLIEwwqn6JnKAqCho7ANaH6BoMWCoqsMqJ(GsrpllOg9XgsniUdNDRoBIq9JKrUIkNesqnhEQS6SjYgmvKkXZkoK0Vj0WlYWdNbchDJj6XJj0WlYWdNbchDVNO)YQwLPTYG6JwYYhnH6NigXHFOOS4mOIpBAqfFjEwXHKGKmHg9bLIEwwqn6JnKAqCho7oW93fNbvUIkNYQwLdC)TWzWP8rtO(lRAvk6zzb1Op5Jtlo4OcdQmnMiijtOrFqPONLfuJ(ydPge3HZUdC)DXzqLROYPSQvzARmO(OLS8rtOGK8naLO3ZjEACeaunnGakE6ZnG2l13vaAOevGa6JoUJJaG2hGAa6JMqJ(aunMiGsIoJBaDCkEak39cqt(6Xak396buEr)IuaDC4CaQ4dfqTJeq5UxaAQrcOe1OPXraq9Dga0XP4bOC3lavyqfq5f9lsLGK8naLOXr8eSjYfGQPbeqdiGMAhPdjb0z)iGEMUEZ54wcsY3autOrFqPONLfuJ(ydPge3HZUdC)DXzqLROYz4rVmccsPpsOOFrQ)YQwLPOPXrGTgKRbqsMqJ(GsrpllOg9XgsniUdNDhsB8cIXQoBIqqsMqJ(GsrpllOg9XgsniUdNDHI(fPCfvoLvTkf9SSGA0N8XPfhCuHbvMgt0FzvRsrpllOg9jxdE8uw1Qu0ZYcQrFsYE85x0TJShFsrpllOg9jFCAXb3xyqLPXebjzcn6dkf9SSGA0hBi1G4oC21fEJJaR0ZcxrLtzvRsrpllOg9jFCAXb3NGGuonI53eA4fz4HZaHJ6dijtOrFqPONLfuJ(ydPge3HZUKVrOpiR8OPPCfvoLvTkf9SSGA0N8XPfhCFccs50iM)YQwLIEwwqn6tUgajzcn6dkf9SSGA0hBi1G4oC2fk6xKYvu5O2tavzkAonvoi0954RB7xnhEQeI2hhbM2lrQepR4qsqsGKmHg9bLHItit0ZYcQrFCwqKfko56SjYjiCHg9XMgbeYQlicsYeA0hugkoHmrpllOg9TdNDxqKfko56SjYjL7b810hns24pG643gGCfvoLvTkf9SSGA0NCn43eA0NSgpYkodQsrQ9eqiNT9Bcn6twJhzfNbv5JIu7jGmnM4OeeKYPrmqsMqJ(GYqXjKj6zzb1OVD4S7cISqXjxNnrot7Ikc1M1v20ipecbjzcn6dkdfNqMONLfuJ(2HZUc7eOJvw1kxliY6ALrqqYXhUoBICM2fveQnRRSPrEieYeP2GIpRpKROYPSQvPONLfuJ(KRbpEmHg9jNOI9lJJvDbHu1Vj0Op5evSFzCSQliKQShNwCW95STCpGKmHg9bLHItit0ZYcQrF7Wz3fezHItUwqK11kJGGKJpCD2e5ye36rnTHmyCeqs2GBnncixrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPQFtOrFYjQy)Y4yvxqivzpoT4G7ZzB5Eajzcn6dkdfNqMONLfuJ(2HZUliYcfNCTGiRRvgbbjhF4cRvuOSZMihcoJmmTFiRyKeqUIkNYQwLIEwwqn6tUg84XeA0NCIk2Vmow1fesv)MqJ(KtuX(LXXQUGqQYECAXb3NZ2Y9asYeA0hugkoHmrpllOg9TdNDxqKfko5AbrwxRmccso(WfwROqzNnroeCgzyA)q2ejnNl6JROYPSQvPONLfuJ(KRbpEmHg9jNOI9lJJvDbHu1Vj0Op5evSFzCSQliKQShNwCW95STCpGKmHg9bLHItit0ZYcQrF7Wz3fezHItUwqK11kJGGKJpCD2e5umhwJhzL3orkxrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPQFtOrFYjQy)Y4yvxqivzpoT4G7ZzB5Eajzcn6dkdfNqMONLfuJ(2HZUliYcfNCTGiRRvgbbjhF46SjYbM2IKlHIpKvTJaxrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPQFtOrFYjQy)Y4yvxqivzpoT4G7ZzB5Eajzcn6dkdfNqMONLfuJ(2HZUliYcfNCTGiRRvgbbjhF46SjYrjo7qiRyFYWH4qixrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPQFtOrFYjQy)Y4yvxqivzpoT4G7ZzB5Eajzcn6dkdfNqMONLfuJ(2HZUliYcfNCTGiRRvgbbjhF46SjYXorGNYs(AL1v24as2tUIkNYQwLIEwwqn6tUg84XeA0NCIk2Vmow1fesv)MqJ(KtuX(LXXQUGqQYECAXb3NZ2Y9asYeA0hugkoHmrpllOg9TdNDxqKfko5AbrwxRmccso(W1ztKZHR3Cmi3NnargEP2jWNROYPSQvPONLfuJ(KRbpEmHg9jNOI9lJJvDbHu1Vj0Op5evSFzCSQliKQShNwCW95STCpGKmHg9bLHItit0ZYcQrF7Wz3fezHItUwqK11kJGGKJpCD2e5mnxT)jsYsX3CKqMdjm(TbixrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPQFtOrFYjQy)Y4yvxqivzpoT4G7ZzB5EajbsYeA0hugkoHS0GqkB4J(dLBocZ5yMqJ(yUaQCD2e5ekoHmrpllOg9Xvu541(WkouQXezAZe9SSGA03(C2gKKj0OpOmuCczPbHu2Wh9hk37Wz3fezHItiijtOrFqzO4eYsdcPSHp6puU3HZUliYcfNCD2e5mTlQiuBwxztJ8qiKROYHi4gSIHbKuAehm1EdYQ9PSUYg6X473R9HvCOuJjY0Mj6zzb1OV93BGKmHg9bLHItilniKYg(O)q5Eho7UGiluCY1ztKJrCWu7niR2NY6kBOhJpxrLJx7dR4qPgtKPnt0ZYcQrF7Zzp74ZEikETpSIdL1(ugzVkoK1hBbr)ETpSIdLAmrM2mrpllOg9n62GKmHg9bLHItilniKYg(O)q5Eho7UGiluCY1ztKZ3Q4xqfjzE7MSBgz7CCfvoETpSIdLAmrM2mrpllOg9nQx7dR4qzFSfezIL21kijtOrFqzO4eYsdcPSHp6puU3HZUliYcfNCD2e5yBWkgAfpLD2sd3cYvu541(WkouQXezAZe9SSGA03OETpSIdL9XwqKjwAxRGKmHg9bLHItilniKYg(O)q5Eho7UGiluCY1ztKdmn8IpZlE9K9OleCfvoETpSIdLAmrM2mrpllOg9nQx7dR4qzFSfezIL21kijtOrFqzO4eYsdcPSHp6puU3HZUliYcfNCD2e5u7VeKK4X6cmid7ycNnMROYXR9HvCOuJjY0Mj6zzb1OVr9AFyfhk7JTGitS0Uwbjzcn6dkdfNqwAqiLn8r)HY9oC2DbrwO4KlSwrHYoBICsTF2xiyK40u8dZfeh(GKmHg9bLHItilniKYg(O)q5Eho7UGiluCY1ztKZ0C1(NijlfFZrczoKW43gGCfvoETpSIdLAmrM2mrpllOg9nkN9Sh)LvTkf9SSGA0NKShF(9AFyfhk1yImTzIEwwqn6BuV2hwXHY(yliYelTRvqsMqJ(GYqXjKLgeszdF0FOCVdNDxqKfko56SjYXorGNYs(AL1v24as2tUIkhV2hwXHsnMitBMONLfuJ(gLZE2J)YQwLIEwwqn6ts2Jp)ETpSIdLAmrM2mrpllOg9nQx7dR4qzFSfezIL21kijtOrFqzO4eYsdcPSHp6puU3HZUliYcfNCD2e5C46nhdY9zdqKHxQDc85kQC8AFyfhk1yImTzIEwwqn6Buo(Y94VSQvPONLfuJ(KK94ZVx7dR4qPgtKPnt0ZYcQrFJ61(Wkou2hBbrMyPDTcscKKj0OpOmuCczUEmB4J(dLBoliYcfNCD2e5Objc1(NmrtIeJROYXR9HvCOuJjY0Mj6zzb1OVr9AFyfhk7JTGitS0Uwbjzcn6dkdfNqMRhZg(O)q5Eho7UGiluCYfwROqzNnrocUfUw)(cbR4mOYvu541(WkouQXezAZe9SSGA03OETpSIdL9XwqKjwAxRGKajzcn6dk)EGnKAqKt1zteQFKmYvu5KGj0WlYWdNbchLJx7dR4qzARmO(OLmR6Sjc1psg9NGgtK4lRAvk6zzb1OpPZGkdj2q84OETpSIdLKOZ4MvD2eH6hjJE841(WkousgqR4qMONLfuJ(smr)LvTktBLb1hTKLpAcfKKj0OpO87b2qQbXD4S7a3FxCgu5kQCkRAvM2kdQpAjlF0ekijtOrFq53dSHudI7Wz3A8iR4mOY1cISUwzeeKC8HRfezJtdhYeguJJahF4kQCiscMqdVidpCgiCuoETpSIdLP2tYeguzvNnrO(rYO)e0yIeFzvRsrpllOg9jDguziXgIhh1R9HvCOKeDg3SQZMiu)iz0JhV2hwXHsYaAfhYe9SSGA0xIj6Ni14rOAVIV0eA4f9NarkRAvMIMghb2Aq(Oju)ePSQvzARmO(OLS8rtO(jYWJEzDTYiiiL14rwXzq1FcMqJ(K14rwXzqvksTNachLZg94jbtOrFYH0gVGySQZMiuksTNachLJp(vZHNkhsB8cIXQoBIqjEwXHKj6XtcQ5WtLMdjguFdsCgKvxp3s8SIdj9l62r2Jpj5Be6dYkpAAQ8rJK7e94jb1C4PsiAFCeyAVePs8SIdj9R2tavzkAonvoi0954RB7XdCaDoM4dDuo(KyIjcsYeA0hu(9aBi1G4oC2vyohZeA0hZfqLRZMihtOHxKPMdpfcsYeA0hu(9aBi1G4oC2DG7VlodQCfvoLvTkh4(BHZGt5JMq9lmOY0yI7xw1QCG7VfodoLpoT4G(lRAv(RdzDLn0JXx(40IdoQWGktJjcsYeA0hu(9aBi1G4oC2TgpYkodQCTGiRRvgbbjhF4Abr240WHmHb14iWXhUIkhIKGj0WlYWdNbchLJx7dR4qzQ9KmHbvw1zteQFKm6pbnMiXxw1Qu0ZYcQrFsNbvgsSH4Xr9AFyfhkjrNXnR6Sjc1psg94XR9HvCOKmGwXHmrpllOg9LyI(jsnEeQ2R4lnHgEr)juw1QmfnnocS1G8rtO(HdOZXeFO77J)eu7jGQmfnNMkhe6OC81T94HiQ5WtLq0(4iW0EjsL4zfhsMyIGKmHg9bLFpWgsniUdNDRXJSIZGkxliY6ALrqqYXhUwqKnonCityqnocC8HROYHijycn8Im8WzGWr541(WkouMApjtyqLvD2eH6hjJ(tqJjs8LvTkf9SSGA0N0zqLHeBiECuV2hwXHss0zCZQoBIq9JKrpE8AFyfhkjdOvCit0ZYcQrFjMOFIuJhHQ9k(stOHx0FcQ5WtLq0(4iW0EjsL4zfhs6xTNaQYu0CAQCqO7ZXx32Jh4a6CmXh6OC8jr)juw1QmfnnocS1G8rtO(jIj0Opju0VivIedflnocE8qKYQwLPOPXrGTgKpAc1prkRAvM2kdQpAjlF0eAIGK8na1eA0hu(9aBi1G4oC2DG7VlodQCfvodp6Lrqqk9rcf9ls9xw1QmfnnocS1GCn4pb1C4PsiAFCeyAVePs8SIdj9R2tavzkAonvoi0954RB7XdCaDoM4dDuo(KOFIKGj0WlYWdNbchLJx7dR4qzARmO(OLmR6Sjc1psg9NGgtK4lRAvk6zzb1OpPZGkdj2q84OETpSIdLKOZ4MvD2eH6hjJE841(WkousgqR4qMONLfuJ(smrqsMqJ(GYVhydPge3HZUdPnEbXyvNnrixrLdrgE0lJGGu6JCiTXligR6Sjc9xw1QmfnnocS1G8rtOGKmHg9bLFpWgsniUdNDHI(fPCfvoQ9eqvMIMttLdcDFo(62(vZHNkHO9XrGP9sKkXZkoK0Jh4a6CmXh6OC8bKKj0OpO87b2qQbXD4Sl5Be6dYkpAAkxrLJj0WlYWdNbchDJGKmHg9bLFpWgsniUdNDRoBIq9JKrUIkNemHgErgE4mq4OC8AFyfhktTNKjmOYQoBIq9JKr)jOXej(YQwLIEwwqn6t6mOYqInepoQx7dR4qjj6mUzvNnrO(rYOhpETpSIdLKb0koKj6zzb1OVeteKKj0OpO87b2qQbXD4SBnESyohijqsMqJ(GsOAhP9KSVvtJ(4uD2eH6hjJCfvojycn8Im8WzGWr541(WkouM2kdQpAjZQoBIq9JKr)jOXej(YQwLIEwwqn6t6mOYqInepoQx7dR4qjj6mUzvNnrO(rYyIj6VSQvzARmO(OLS8rtOGKmHg9bLq1os7jzFRMg9TdNDh4(7IZGkxrLtzvRY0wzq9rlz5JMq9xw1QmTvguF0sw(40IdUVj0OpznESyoNejgkwkY0yIGKmHg9bLq1os7jzFRMg9TdNDh4(7IZGkxrLtzvRY0wzq9rlz5JMq9NWWJEzeeKsFK14XI5CE8uJhHQ9k(stOHx0JhtOrFYbU)U4mOkJJvDbHu1JNz7nocjcsYeA0hucv7iTNK9TAA03oC2DiTXligR6Sjc5kQCeP2taHJYXx9Bcn8Im8WzGWr3OFI41(WkouoK24feJn0TlocGKmHg9bLq1os7jzFRMg9TdNDh4(7IZGkxrLtzvRY0wzq9rlz5JMq9NGApbuLPO50u5Gq3NJVUTF1C4PsiAFCeyAVePs8SIdj94boGoht8HokhFseKKj0OpOeQ2rApj7B10OVD4S7a3FxCgu5kQCkRAvoW93cNbNYhnH6xyqLPXe3VSQv5a3FlCgCkFCAXbbjzcn6dkHQDK2tY(wnn6Bho7wJhzfNbvUwqK11kJGGKJpCTGiBCA4qMWGACe44dxrLtcLvTk)1HSUYg6X4lj7XNFIuJhHQ9k(stOHxmr)eXR9HvCOSgpYkodQSHUDXrWFcjKGj0OpznESyoNejgkwACe84XeA0NCG7VlodQsKyOyPXrir)LvTktrtJJaBniF0eAIE8KqcQ5WtLq0(4iW0EjsL4zfhs6xTNaQYu0CAQCqO7ZXx32Jh4a6CmXh6OC8jr)juw1QmfnnocS1G8rtO(jIj0Opju0VivIedflnocE8qKYQwLPTYG6JwYYhnH6NiLvTktrtJJaBniF0eQFtOrFsOOFrQejgkwACe8tetOrFYbU)U4mOkJJvDbHu1prmHg9jRXJfZ5KXXQUGqQMyIjcsY3autOrFqjuTJ0Es23QPrF7Wz3bU)U4mOYvu5m8OxgbbP0hju0Vi1FzvRYu004iWwdY1G)euZHNkHO9XrGP9sKkXZkoK0VApbuLPO50u5Gq3NJVUThpWb05yIp0r54tI(jscMqdVidpCgiCuoETpSIdLPTYG6JwYSQZMiu)iz0FcAmrIVSQvPONLfuJ(KodQmKydXJJ61(WkousIoJBw1zteQFKm6XJx7dR4qjzaTIdzIEwwqn6lXebjzcn6dkHQDK2tY(wnn6Bho7oK24feJvD2eHCfvojuw1QmfnnocS1G8rtOE8KarkRAvM2kdQpAjlF0eQ)emHg9jRXJSIZGQuKApbeo62E8OMdpvcr7JJat7LivINvCiPF1EcOktrZPPYbHUphFDBpEGdOZXeFOJYXNetmr)eXR9HvCOCiTXligBOBxCeajzcn6dkHQDK2tY(wnn6Bho7kmNJzcn6J5cOY1ztKJj0WlYuZHNcbjzcn6dkHQDK2tY(wnn6Bho7s(gH(GSYJMMYvu5ycn8Im8WzGWr9bKKj0OpOeQ2rApj7B10OVD4SRWCoMj0OpMlGkxNnroHItiZ1JzdF0FOCdsYeA0hucv7iTNK9TAA03oC2fk6xKYvu5O2tavzkAonvoi0954RB7xnhEQeI2hhbM2lrQepR4qspEGdOZXeFOJYXhqs(gGs0m0uafVErifqv7jGkKlanuanGaQbOeS4auTbuHbva1x4Sjc1psgbudcO1W5WhqJdQOrcODfq9fXJfZ5KGKmHg9bLq1os7jzFRMg9TdNDRoBIq9JKrUIkhtOHxKHhodeokhV2hwXHYu7jzcdQSQZMiu)iz0FcAmrIVSQvPONLfuJ(KodQmKydXJJ61(WkousIoJBw1zteQFKmMiijtOrFqjuTJ0Es23QPrF7Wz3A8yXCoqsMqJ(GsOAhP9KSVvtJ(2HZUqr)I0SM1Cg]] )


end
