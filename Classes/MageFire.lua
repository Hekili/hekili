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



    spec:RegisterPack( "Fire", 20200614, [[d8u2QcqieIhrvQCjLQa2Ki8jekOrjICkQQAvkvrVsPuZcvYTqOQDr0VuQyykv6yuLSmLQ0ZOkLMgvPORPqQTPuf6BkKKghcf15OkvzDiuiVJQuvjZtPQUhQyFkfoivPaluPOhIqjteHcCrLQaTrek1hPkvvQrIqrojcfQvsvLxsvQQYmvijUPcj1ovi(jvPQIHQuf0sPkvv1trvtvPKRsvQkFLQuq7vu)fLbJ0HPSyjEmHjJOldTzj9zemAr60cRMQuOxlIA2u52kA3Q8BPgUcoUcjwUQEoOPt66kz7uv(Uc14riDEuPwpcvMpvX(bo7vERmpPPyEK9U7E3D39OxEtPxEZr792lXCMx5EaZ8dMizJaM5pBIzEID8yMFW421gzERmpSxVaZ8PQoajgTZoecnDvKIEUdmMlNPrFI3Q6oWyk2jZxwHtjgF5sMN0umpYE3DV7U7E0lVP0lV5O9E7D0zEBPP9N55JjXkZNgKK4LlzEsekY8EhGsSJhb0rTrab(5DaAQQdqIr7SdHqtxfPON7aJ5YzA0N4TQUdmMIDa(5DaQFRdbuV8MCbO7D39UlWpGFEhGsSsTJacjgb8Z7auIhq9(GiGQXezAZideqFttXhq1u7au1EcOk1yImTzKbcO1(buNbvIhII(ibuReUq5gqxqJacLa)8oaL4buVVbstra11ecbG(iXiaDuzjcsaLyWJ2ekb(5DakXdOJkDdXdqfgub0hhLv84epfcO1(buIvpllOg9bOjfsuYfGs2hXqfqtBhjGgkGw7hqnaT(imfqh1OI9dOcdQ(lb(5DakXdOedcOvCiGAhGIN(CdOAQPa64E5ib0hHlNcOXbOgGMApPWGkGUhY93fNbvanoINGnrjWpVdqjEaDp4zfhcOq9dHcOIuuKCCea0(audqR4yaT2FYqanoavtra1BWE4OcGQnG(i5sGa64(t21gPmZ7cOcZBL5dfNqMRhZg(O)q5oVvEeVYBL5XZkoKmVzM3eA0xMxdseQ9pzIMejAMx8HIFyzEF2hwXHsnMitBMONLfuJ(a0nauF2hwXHY(yliYelTR1m)ztmZRbjc1(NmrtIenR5r2BERmpEwXHK5nZ8MqJ(Y8cUfUw)(cbR4mOM5fFO4hwM3N9HvCOuJjY0Mj6zzb1OpaDda1N9HvCOSp2cImXs7AnZJ1kku2ztmZl4w4A97leSIZGAwZAMx0ZYcQrFSHudI5TYJ4vERmpEwXHK5nZ8Ipu8dlZxw1Qu0ZYcQrFsYE8L5nHg9L5DbHufY8gxKeM4PznpYEZBL5XZkoKmVzMx8HIFyz(YQwLIEwwqn6ts2JVmVj0OVmFXiW6kt)qKmmR5r828wzE8SIdjZBM5fFO4hwM3eA4dz4HZaHa6gaQxaAcaTSQvPONLfuJ(KK94lZBcn6lZ7cFXrGv6zjR5r8M5TY8MqJ(Y8fx3KSUY0uKHho5oZJNvCizEZSMhz05TY8MqJ(Y8tC2p3SUYClrqYiF0MWmpEwXHK5nZAEK9yERmVj0OVm)4(DK(W4ypc7ZobM5XZkoKmVzwZJmQM3kZJNvCizEZm)cISXPHdzcdQXripIxzEXhk(HL5fP2taHa6gCauVa0eaAsaAsaQj0OpznEKvCguLIu7jGqw9nHg9zoaDBanjaTSQvPONLfuJ(KpoT4GakXdOLvTklodQ4ZMguXxsUEtJ(au)b09aaQOBhzp(K14rwXzqvsUEtJ(auIhqtcqlRAvk6zzb1Op5JtloiG6pGUhaqtcqlRAvwCguXNnnOIVKC9Mg9bOepGURC0aQ)aQ)a6gCa0DbupEauIaOgXHFOOS4mOIpBAqfFjEwXHKaQhpakrau1C4PYQZMiRpjEwXHKaQhpaAzvRsrpllOg9jFCAXbb095aOLvTklodQ4ZMguXxsUEtJ(aupEa0YQwLfNbv8ztdQ4lFCAXbb09b0DLJgq94bqXrzfddiPmL7b810hns24pG643gGaAcav0TJShFYuUhWxtF0izJ)aQJFBaY82D31lV5ELpoT4Ga6(a6Obu)b0eaAzvRsrpllOg9jxdaAcanjaLiaQj0Opju0VivIefflnocaAcaLiaQj0Op5a3FxCguLXXQUGqQcOja0YQwLPOPXrGTgKRba1Jha1eA0Nek6xKkrIIILghbanbGww1QmTvguF0sws2JpanbGMeGww1QmfnnocS1GKShFaQhpaQrC4hkklodQ4ZMguXxINvCijG6pG6XdGAeh(HIYIZGk(SPbv8L4zfhscOjau1C4PYQZMiRpjEwXHKaAca1eA0NCG7VlodQY4yvxqivb0eaAzvRYu004iWwdsYE8bOja0YQwLPTYG6JwYsYE8bO(N5xqK11kJGGmpIxzEtOrFz(A8iR4mOM18ieZ5TY84zfhsM3mZl(qXpSmFzvRYFDiRRSHEm(sYE8bOja0YQwLIEwwqn6ts2JVmVj0OVm)VoK1v2qpg)SMhX7L3kZJNvCizEZm)cISXPHdzcdQXripIxzEtOrFz(A8iR4mOM5fFO4hwM3io8dfLfNbv8ztdQ4lXZkoKeqtaOjbOieINaLtC2p3SUYClrqYiF0Mq508g7hq94bqjcGIqiEcuoXz)CZ6kZTebjJ8rBcLZ46hq9hqtaOQ5WtLtuX(L4zfhscOjau1C4PYQZMiRpjEwXHKaAcaTSQvzXzqfF20Gk(sYE8bOja0Kau1C4PYFDiRRSHEm(s8SIdjb0eaQj0Op5VoK1v2qpgFjsuuS04iaOjautOrFYFDiRRSHEm(sKOOyPi7XPfheq3hq3vUhbupEa0KauF2hwXHsnMitBMONLfuJ(a095aO7cOE8aOLvTkf9SSGA0NCnaO(dOjauIaOQ5WtL)6qwxzd9y8L4zfhscOjauIaOMqJ(KdC)DXzqvghR6ccPkGMaqjcGAcn6twJhlMZjJJvDbHufq9pR5r8A38wzE8SIdjZBM5nHg9L5fMZXmHg9XCbuZ8UaQSZMyM3eA4dzQ5WtHznpIxEL3kZJNvCizEZm)cISXPHdzcdQXripIxzEXhk(HL5tcqtcqnHg9jNOI9lJJvDbHufqtaOMqJ(KtuX(LXXQUGqQYECAXbb095aO7khnG6pG6XdGAcn6torf7xghR6ccPkG6XdGIqiEcuoXz)CZ6kZTebjJ8rBcLtZBSFa1JhaTSQvzARmO(OLS8rtOaQhpaQj0Opju0VivIefflnocaAca1eA0Nek6xKkrIIILIShNwCqaDFaDx5ObupEautOrFYbU)U4mOkrIIILghbanbGAcn6toW93fNbvjsuuSuK940IdcO7dO7khnG6pGMaqtcqlRAv(RdzDLn0JXxUgaupEauIaOQ5WtL)6qwxzd9y8L4zfhscO(N5xqK11kJGGmpIxzEtOrFzErpllOg9L18iET38wzEtOrFz(HwJ(Y84zfhsM3mR5r8YBZBL5nHg9L5lUUjz11ZDMhpR4qY8MznpIxEZ8wzEtOrFz(c(q8tooczE8SIdjZBM18iEn68wzEtOrFz(A8yX1nzMhpR4qY8MznpIx7X8wzEtOrFzE7eiuFZXeMZL5XZkoKmVzwZJ41OAERmpEwXHK5nZ8Ipu8dlZNeGMeGQMdpvwD2ezdMksL4zfhscOjautOHpKHhodecOBaO7fq9hq94bqnHg(qgE4mqiGUbGUhbu)b0eaAzvRY0wzq9rlz5JMqb0eakrauJ4WpuuwCguXNnnOIVepR4qYmVj0OVmF1zteQFKmM18iErmN3kZJNvCizEZmV4df)WY8LvTkh4(BHZGt5JMqb0eaAzvRsrpllOg9jFCAXbb0nauHbvMgtmZBcn6lZpW93fNb1SMhXlVxERmpEwXHK5nZ8Ipu8dlZxw1QmTvguF0sw(Oj0mVj0OVm)a3FxCguZAEK9UBERmVj0OVm)qAJxquw1zteM5XZkoKmVzwZJSxVYBL5XZkoKmVzMx8HIFyz(YQwLIEwwqn6t(40IdcOBaOcdQmnMiGMaqlRAvk6zzb1Op5Aaq94bqlRAvk6zzb1Opjzp(a0eaQOBhzp(KIEwwqn6t(40IdcO7dOcdQmnMyM3eA0xMhk6xKM18i7DV5TY84zfhsM3mZl(qXpSmFzvRsrpllOg9jFCAXbb09buccs50ikGMaqnHg(qgE4mqiGUbG6vM3eA0xM3f(IJaR0ZswZJSxVnVvMhpR4qY8MzEXhk(HL5lRAvk6zzb1Op5JtloiGUpGsqqkNgrb0eaAzvRsrpllOg9jxdzEtOrFzEY3i0hKvE000SMhzVEZ8wzE8SIdjZBM5fFO4hwMxTNaQYu0CAQCqOa6(CauVDxanbGQMdpvcr7JJat7LivINvCizM3eA0xMhk6xKM1SM5nHg(qMAo8uyER8iEL3kZJNvCizEZmV4df)WY8MqdFidpCgieq3aq9cqtaOLvTkf9SSGA0NKShFaAcanja1N9HvCOuJjY0Mj6zzb1OpaDdav0TJShFsx4locSsplsY1BA0hG6XdG6Z(WkouQXezAZe9SSGA0hGUphaDxa1)mVj0OVmVl8fhbwPNLSMhzV5TY84zfhsM3mZl(qXpSmVp7dR4qPgtKPnt0ZYcQrFa6(Ca0DbupEa0Ka0YQwL)6qwxzd9y8LRba1Jhav0TJShFYFDiRRSHEm(YhNwCqaDdavJjY0MrgiGMaqnHg9j)1HSUYg6X4lfP2taHa6(aQxaQhpakrau1C4PYFDiRRSHEm(s8SIdjbu)b0eaAsaQOBhzp(KtuX(LKR30OpaDFa1N9HvCOuJjY0Mj6zzb1Opa1JhavJjY0MrgiGUpG6Z(WkouQXezAZe9SSGA0hG6FM3eA0xMFIk2FwZJ4T5TY84zfhsM3mZl(qXpSmVAo8uP5qIc13GeNbz11ZTepR4qsanbGMeGww1Qu0ZYcQrFsYE8bOjauIaOLvTktBLb1hTKLpAcfq94bqlRAvk6zzb1Op5AaqtaOMqJ(K14rwXzqvksTNacb09butOrFYA8iR4mOkNgrzIu7jGqanbGseaTSQvzARmO(OLS8rtOaQ)zEtOrFzEY3i0hKvE000SM1mFO4eYsdcPSHp6puUZBLhXR8wzE8SIdjZBM5fFO4hwM3N9HvCOuJjY0Mj6zzb1OpaDFoa6UzEtOrFzEH5CmtOrFmxa1mVlGk7SjM5dfNqMONLfuJ(YAEK9M3kZBcn6lZVGiluCcZ84zfhsM3mR5r828wzE8SIdjZBM5nHg9L5N2fveQnRRSPrEieM5fFO4hwMNiakokRyyajLgXbtT3GSAFkRRSHEm(aAca1N9HvCOuJjY0Mj6zzb1OpaDFaLyoZF2eZ8t7Ikc1M1v20ipecZAEeVzERmpEwXHK5nZ8MqJ(Y8gXbtT3GSAFkRRSHEm(zEXhk(HL59zFyfhk1yImTzIEwwqn6dq3NdGoAaDBa1RrdO7jG6Z(Wkouw7tzK9Q4qwFSfeZ8NnXmVrCWu7niR2NY6kBOhJFwZJm68wzE8SIdjZBM5nHg9L5)wf)cQijZx3KDZiBNlZl(qXpSmVp7dR4qPgtKPnt0ZYcQrFa6gaQp7dR4qzFSfezIL21AM)SjM5)wf)cQijZx3KDZiBNlR5r2J5TY84zfhsM3mZBcn6lZBJYkgAfpLD2sd3cM5fFO4hwM3N9HvCOuJjY0Mj6zzb1OpaDda1N9HvCOSp2cImXs7AnZF2eZ82OSIHwXtzNT0WTGznpYOAERmpEwXHK5nZ8MqJ(Y8W0Wh(mF41t2JUqK5fFO4hwM3N9HvCOuJjY0Mj6zzb1OpaDda1N9HvCOSp2cImXs7AnZF2eZ8W0Wh(mF41t2JUqK18ieZ5TY84zfhsM3mZBcn6lZx7VeKK4X6cmid7ycNnoZl(qXpSmVp7dR4qPgtKPnt0ZYcQrFa6gaQp7dR4qzFSfezIL21AM)SjM5R9xcss8yDbgKHDmHZgN18iEV8wzE8SIdjZBM5nHg9L5tTF2xiyK40u8dZfeh(zESwrHYoBIz(u7N9fcgjonf)WCbXHFwZJ41U5TY84zfhsM3mZBcn6lZpnxT)jsYsX3CKqMdjm(TbyMx8HIFyzEF2hwXHsnMitBMONLfuJ(a0n4aOJE0aAcaTSQvPONLfuJ(KK94dqtaO(SpSIdLAmrM2mrpllOg9bOBaO(SpSIdL9XwqKjwAxRz(ZMyMFAUA)tKKLIV5iHmhsy8BdWSMhXlVYBL5XZkoKmVzM3eA0xM3orGNYs(AL1v24as2ZmV4df)WY8(SpSIdLAmrM2mrpllOg9bOBWbqh9Ob0eaAzvRsrpllOg9jj7XhGMaq9zFyfhk1yImTzIEwwqn6dq3aq9zFyfhk7JTGitS0UwZ8NnXmVDIapLL81kRRSXbKSNznpIx7nVvMhpR4qY8MzEtOrFz(dxV5yqUpBaIm8sTtGFMx8HIFyzEF2hwXHsnMitBMONLfuJ(a0n4aOEZrdOja0YQwLIEwwqn6ts2JpanbG6Z(WkouQXezAZe9SSGA0hGUbG6Z(Wkou2hBbrMyPDTM5pBIz(dxV5yqUpBaIm8sTtGFwZAMNeR2YP5TYJ4vERmVj0OVmVOxNIpCaDUmpEwXHK5nZAEK9M3kZJNvCizEZmFpK5HOM5nHg9L59zFyfhM59zUfM5vZHNkRXJq1EfFjEwXHKa6EcO14rOAVIV8XPfheq3gqtcqfD7i7XNu0ZYcQrFYhNwCqaDpb0KauVauIhq9zFyfhktoosxCeypsUeA0hGUNaQAo8uzYXr6IJGepR4qsa1FaL4butOrFYFDiRRSHEm(sKOOyPitJjcO7jGQMdpv(RdzDLn0JXxINvCijG6pGUNakraur3oYE8jf9SSGA0N8rJKBaDpb0YQwLIEwwqn6ts2JVmVp7zNnXmVgtKPnt0ZYcQrFznpI3M3kZJNvCizEZmFpK5NgrZ8MqJ(Y8(SpSIdZ8(m3cZ8IUDK94toXz)CZ6kZTebjJ8rBcLpoT4GzEXhk(HL5riepbkN4SFUzDL5wIGKr(OnHYP5n2pGMaqlRAvoXz)CZ6kZTebjJ8rBcLK94dqtaOIUDK94toXz)CZ6kZTebjJ8rBcLpoT4GakXdO(SpSIdLAmrM2mrpllOg9bO7Zbq9zFyfhktBhjt0ZYcQrFmn9ryA7iZ8(SND2eZ8AmrM2mrpllOg9L18iEZ8wzE8SIdjZBM57Hm)0iAM3eA0xM3N9HvCyM3N5wyMx0TJShFYX97i9HXXEe2NDcu(40IdM5fFO4hwMhHq8eOCC)osFyCShH9zNaLtZBSFanbGww1QCC)osFyCShH9zNaLK94dqtaOIUDK94toUFhPpmo2JW(StGYhNwCqaL4buF2hwXHsnMitBMONLfuJ(a095aO(SpSIdLPTJKj6zzb1OpMM(imTDKzEF2ZoBIzEnMitBMONLfuJ(YAEKrN3kZJNvCizEZmVj0OVmVWCoMj0OpMlGAM3fqLD2eZ8HItilniKYg(O)q5oR5r2J5TY84zfhsM3mZl(qXpSmFzvRsrpllOg9jj7XxM3eA0xMFg)3plMgbmR5rgvZBL5XZkoKmVzMx8HIFyz(KauF2hwXHsnMitBMONLfuJ(a09buV2fq94bq1yImTzKbcO7dO(SpSIdLAmrM2mrpllOg9bO(N5nHg9L5jSSNmSJ1vMrC43AAwZJqmN3kZBcn6lZl6tGN(MIKSQZMyMhpR4qY8MznpI3lVvM3eA0xM)rBiocSQZMimZJNvCizEZSMhXRDZBL5nHg9L5RTybrsMrC4hkYkOnZ84zfhsM3mR5r8YR8wzEtOrFz(H1hvUJJaR4mOM5XZkoKmVzwZJ41EZBL5nHg9L5)yyWHS4yWbtGzE8SIdjZBM18iE5T5TY8MqJ(Y8AkYwxPxhjR2VaZ84zfhsM3mR5r8YBM3kZJNvCizEZmV4df)WY8LvTk)1HSUYg6X4lj7XhGMaqlRAvk6zzb1Opjzp(a0eaAsaQp7dR4qPgtKPnt0ZYcQrFa6gaAD5CShfP2tazAmra1Jha1N9HvCOuJjY0Mj6zzb1OpaDdavTNaQsnMitBgzGaQ)zEtOrFz(FDiRRSHEm(znpIxJoVvMhpR4qY8MzEXhk(HL59zFyfhk1yImTzIEwwqn6dq3NdGUBM3eA0xMxyohZeA0hZfqnZ7cOYoBIzErpllOg9XgsniM18iEThZBL5XZkoKmVzMFbr240WHmHb14iKhXRmV4df)WY8jbOieINaLtC2p3SUYClrqYiF0Mq508g7hq94bqriepbkN4SFUzDL5wIGKr(OnHYzC9dOjauJ4WpuuwCguXNnnOIVepR4qsa1FanbGksTNacbuoa60iktKApbecOjauIaOLvTktBLb1hTKLpAcfqtaOebqtcqlRAvMIMghb2Aq(OjuanbGMeGww1Qu0ZYcQrFY1aGMaqtcqnHg9jRXJfZ5KXXQUGqQcOE8aOMqJ(KdC)DXzqvghR6ccPkG6XdGAcn6tcf9lsLirrXsJJaG6pG6XdGQ2tavzkAonvoiuaDFoaQ3UlGMaqnHg9jHI(fPsKOOyPXraq9hq9hqtaOebqtcqjcGww1QmfnnocS1G8rtOaAcaLiaAzvRY0wzq9rlz5JMqb0eaAzvRsrpllOg9jj7XhGMaqtcqnHg9jRXJfZ5KXXQUGqQcOE8aOMqJ(KdC)DXzqvghR6ccPkG6pG6FMFbrwxRmccY8iEL5nHg9L5RXJSIZGAwZJ41OAERmpEwXHK5nZ89qMhIAM3eA0xM3N9HvCyM3N5wyMxnhEQ8xhY6kBOhJVepR4qsanbGk62r2Jp5VoK1v2qpgF5JtloiGUpGk62r2JpznEKvCguL1LZXEuKApbKPXeb0eaAsaQp7dR4qPgtKPnt0ZYcQrFa6gaQj0Op5VoK1v2qpgFzD5CShfP2tazAmra1FanbGMeGk62r2Jp5VoK1v2qpgF5JtloiGUpGQXezAZideq94bqnHg9j)1HSUYg6X4lfP2taHa6ga6UaQ)aQhpaQp7dR4qPgtKPnt0ZYcQrFa6(aQj0OpznEKvCguL1LZXEuKApbKPXeb0eaQp7dR4qPgtKPnt0ZYcQrFa6(aQgtKPnJmWmVp7zNnXmFnEKvCguzdD7IJqwZJ4fXCERmpEwXHK5nZ8Ipu8dlZxw1Q8xhY6kBOhJVCnaOja0KauF2hwXHsnMitBMONLfuJ(a0na0Dbu)Z8q9dHMhXRmVj0OVmVWCoMj0OpMlGAM3fqLD2eZ8FpWgsniM18iE59YBL5XZkoKmVzMVhY8quZ8MqJ(Y8(SpSIdZ8(m3cZ8Q5WtL)6qwxzd9y8L4zfhscOjaur3oYE8j)1HSUYg6X4lFCAXbb09bur3oYE8jhsB8cIYQoBIqzD5CShfP2tazAmranbGMeG6Z(WkouQXezAZe9SSGA0hGUbGAcn6t(RdzDLn0JXxwxoh7rrQ9eqMgteq9hqtaOjbOIUDK94t(RdzDLn0JXx(40IdcO7dOAmrM2mYabupEautOrFYFDiRRSHEm(srQ9eqiGUbGUlG6pG6XdG6Z(WkouQXezAZe9SSGA0hGUpGAcn6toK24feLvD2eHY6Y5ypksTNaY0yIaAca1N9HvCOuJjY0Mj6zzb1OpaDFavJjY0MrgyM3N9SZMyMFiTXlikBOBxCeYAEK9UBERmpEwXHK5nZ8liYgNgoKjmOghH8iEL5fFO4hwMpjaLiaQp7dR4qznEKvCguzdD7IJaG6XdGww1Q8xhY6kBOhJVCnaO(dOja0KauF2hwXHsnMitBMONLfuJ(a0na0Dbu)b0eaAsaQj0WhYWdNbcb0n4aO(SpSIdLP2tYeguzvNnrO(rYiGMaqtcq1yIakXdOLvTkf9SSGA0N0zqLHeDiEeq3aq9zFyfhkjrNXnR6Sjc1psgbu)bu)b0eakra0A8iuTxXxAcn8HaAcaTSQvzARmO(OLSKShFaAcanjaLiaQrC4hkklodQ4ZMguXxINvCijG6XdGww1QS4mOIpBAqfF5JtloiGUpGURC0aQ)z(fezDTYiiiZJ4vM3eA0xMVgpYkodQznpYE9kVvMhpR4qY8Mz(fezJtdhYeguJJqEeVY8Ipu8dlZxJhHQ9k(stOHpeqtaOIu7jGqaDdoaQxaAcanjaLiaQp7dR4qznEKvCguzdD7IJaG6XdGww1Q8xhY6kBOhJVCnaO(dOja0KauIaOgXHFOOS4mOIpBAqfFjEwXHKaQhpaAzvRYIZGk(SPbv8LpoT4Ga6(a6UYrdO(dOja0KauIaOMqJ(K14XI5CsKOOyPXraqtaOebqnHg9jh4(7IZGQmow1fesvanbGww1QmfnnocS1GCnaOE8aOMqJ(K14XI5CsKOOyPXraqtaOLvTktBLb1hTKLK94dq94bqnHg9jh4(7IZGQmow1fesvanbGww1QmfnnocS1GKShFaAcaTSQvzARmO(OLSKShFaQ)z(fezDTYiiiZJ4vM3eA0xMVgpYkodQznpYE3BERmpEwXHK5nZ8Ipu8dlZ7Z(WkouQXezAZe9SSGA0hGUbGUBMhQFi08iEL5nHg9L5fMZXmHg9XCbuZ8UaQSZMyMhQ2rApj7B10OVSM1mFO4eYe9SSGA0xER8iEL3kZJNvCizEZm)ztmZheUqJ(ytJacz1feZ8MqJ(Y8bHl0Op20iGqwDbXSMhzV5TY84zfhsM3mZBcn6lZNY9a(A6JgjB8hqD8BdWmV4df)WY8LvTkf9SSGA0NCnaOjautOrFYA8iR4mOkfP2taHakhaDxanbGAcn6twJhzfNbv5JIu7jGmnMiGUbGsqqkNgrZ8NnXmFk3d4RPpAKSXFa1XVnaZAEeVnVvMhpR4qY8Mz(ZMyMFAxurO2SUYMg5HqyM3eA0xMFAxurO2SUYMg5HqywZJ4nZBL5lRALD2eZ8t7Ikc1M1v20ipeczIuBqXN1hM5fFO4hwMVSQvPONLfuJ(KRba1Jha1eA0NCIk2Vmow1fesvanbGAcn6torf7xghR6ccPk7XPfheq3NdGURC0z(fezDTYiiiZJ4vM3eA0xMxyNaDSYQwZ84zfhsM3mR5rgDERmpEwXHK5nZ8NnXmVrCRh10gYGXrajzdU10iGz(fezDTYiiiZJ4vM3eA0xM3iU1JAAdzW4iGKSb3AAeWmV4df)WY8LvTkf9SSGA0NCnaOE8aOMqJ(KtuX(LXXQUGqQcOjautOrFYjQy)Y4yvxqivzpoT4Ga6(Ca0DLJoR5r2J5TY84zfhsM3mZBcn6lZtWzKHP9dzfJKaM5xqK11kJGGmpIxzEXhk(HL5lRAvk6zzb1Op5Aaq94bqnHg9jNOI9lJJvDbHufqtaOMqJ(KtuX(LXXQUGqQYECAXbb095aO7khDMhRvuOSZMyMNGZidt7hYkgjbmR5rgvZBL5XZkoKmVzM3eA0xMNGZidt7hYMiP5CrFz(fezDTYiiiZJ4vMx8HIFyz(YQwLIEwwqn6tUgaupEautOrFYjQy)Y4yvxqivb0eaQj0Op5evSFzCSQliKQShNwCqaDFoa6UYrN5XAffk7SjM5j4mYW0(HSjsAox0xwZJqmN3kZJNvCizEZm)ztmZxmhwJhzL3orAMFbrwxRmccY8iEL5nHg9L5lMdRXJSYBNinZl(qXpSmFzvRsrpllOg9jxdaQhpaQj0Op5evSFzCSQliKQaAca1eA0NCIk2Vmow1fesv2JtloiGUphaDx5OZAEeVxERmpEwXHK5nZ8NnXmpmTfjxcfFiRAhHm)cISUwzeeK5r8kZBcn6lZdtBrYLqXhYQ2riZl(qXpSmFzvRsrpllOg9jxdaQhpaQj0Op5evSFzCSQliKQaAca1eA0NCIk2Vmow1fesv2JtloiGUphaDx5OZAEeV2nVvMhpR4qY8Mz(ZMyMxjo7qiRyFYWH4qyMFbrwxRmccY8iEL5nHg9L5vIZoeYk2NmCioeM5fFO4hwMVSQvPONLfuJ(KRba1Jha1eA0NCIk2Vmow1fesvanbGAcn6torf7xghR6ccPk7XPfheq3NdGURC0znpIxEL3kZJNvCizEZm)ztmZBNiWtzjFTY6kBCaj7zMFbrwxRmccY8iEL5nHg9L5Tte4PSKVwzDLnoGK9mZl(qXpSmFzvRsrpllOg9jxdaQhpaQj0Op5evSFzCSQliKQaAca1eA0NCIk2Vmow1fesv2JtloiGUphaDx5OZAEeV2BERmpEwXHK5nZ8NnXm)HR3Cmi3NnargEP2jWpZVGiRRvgbbzEeVY8MqJ(Y8hUEZXGCF2aez4LANa)mV4df)WY8LvTkf9SSGA0NCnaOE8aOMqJ(KtuX(LXXQUGqQcOjautOrFYjQy)Y4yvxqivzpoT4Ga6(Ca0DLJoR5r8YBZBL5XZkoKmVzM)SjM5NMR2)ejzP4BosiZHeg)2amZVGiRRvgbbzEeVY8MqJ(Y8tZv7FIKSu8nhjK5qcJFBaM5fFO4hwMVSQvPONLfuJ(KRba1Jha1eA0NCIk2Vmow1fesvanbGAcn6torf7xghR6ccPk7XPfheq3NdGURC0znRz(VhydPgeZBLhXR8wzE8SIdjZBM5fFO4hwMpja1eA4dz4HZaHa6gCauF2hwXHY0wzq9rlzw1zteQFKmcOja0KaunMiGs8aAzvRsrpllOg9jDguzirhIhb0nauF2hwXHss0zCZQoBIq9JKra1Jha1N9HvCOKmGwXHmrpllOg9bO(dO(dOja0YQwLPTYG6JwYYhnHM5nHg9L5RoBIq9JKXSMhzV5TY84zfhsM3mZl(qXpSmFzvRY0wzq9rlz5JMqZ8MqJ(Y8dC)DXzqnR5r828wzE8SIdjZBM5xqKnonCityqnoc5r8kZl(qXpSmpra0KautOHpKHhodecOBWbq9zFyfhktTNKjmOYQoBIq9JKranbGMeGQXebuIhqlRAvk6zzb1OpPZGkdj6q8iGUbG6Z(WkousIoJBw1zteQFKmcOE8aO(SpSIdLKb0koKj6zzb1Opa1Fa1FanbGseaTgpcv7v8LMqdFiGMaqtcqjcGww1QmfnnocS1G8rtOaAcaLiaAzvRY0wzq9rlz5JMqb0eakra0Hh9X6ALrqqkRXJSIZGkGMaqtcqnHg9jRXJSIZGQuKApbecOBWbq3lG6XdGMeGAcn6toK24feLvD2eHsrQ9eqiGUbha1lanbGQMdpvoK24feLvD2eHs8SIdjbu)bupEa0Kau1C4PsZHefQVbjodYQRNBjEwXHKaAcav0TJShFsY3i0hKvE00u5Jgj3aQ)aQhpaAsaQAo8ujeTpocmTxIujEwXHKaAcavTNaQYu0CAQCqOa6(CauVDxa1JhafoGoht8HcOBWbq9cq9hq9hq9pZVGiRRvgbbzEeVY8MqJ(Y814rwXzqnR5r8M5TY84zfhsM3mZBcn6lZlmNJzcn6J5cOM5DbuzNnXmVj0WhYuZHNcZAEKrN3kZJNvCizEZmV4df)WY8LvTkh4(BHZGt5JMqb0eaQWGktJjcO7dOLvTkh4(BHZGt5JtloiGMaqlRAv(RdzDLn0JXx(40IdcOBaOcdQmnMyM3eA0xMFG7VlodQznpYEmVvMhpR4qY8Mz(fezJtdhYeguJJqEeVY8Ipu8dlZteanja1eA4dz4HZaHa6gCauF2hwXHYu7jzcdQSQZMiu)izeqtaOjbOAmraL4b0YQwLIEwwqn6t6mOYqIoepcOBaO(SpSIdLKOZ4MvD2eH6hjJaQhpaQp7dR4qjzaTIdzIEwwqn6dq9hq9hqtaOebqRXJq1EfFPj0WhcOja0Ka0YQwLPOPXrGTgKpAcfqtaOWb05yIpuaDFa1lanbGMeGQ2tavzkAonvoiuaDdoaQ3UlG6XdGseavnhEQeI2hhbM2lrQepR4qsa1Fa1)m)cISUwzeeK5r8kZBcn6lZxJhzfNb1SMhzunVvMhpR4qY8Mz(fezJtdhYeguJJqEeVY8Ipu8dlZteanja1eA4dz4HZaHa6gCauF2hwXHYu7jzcdQSQZMiu)izeqtaOjbOAmraL4b0YQwLIEwwqn6t6mOYqIoepcOBaO(SpSIdLKOZ4MvD2eH6hjJaQhpaQp7dR4qjzaTIdzIEwwqn6dq9hq9hqtaOebqRXJq1EfFPj0WhcOja0Kau1C4PsiAFCeyAVePs8SIdjb0eaQApbuLPO50u5Gqb095aOE7UaQhpakCaDoM4dfq3GdG6fG6pGMaqtcqlRAvMIMghb2Aq(OjuanbGsea1eA0Nek6xKkrIIILghba1JhaLiaAzvRYu004iWwdYhnHcOjauIaOLvTktBLb1hTKLpAcfq9pZVGiRRvgbbzEeVY8MqJ(Y814rwXzqnR5riMZBL5XZkoKmVzMx8HIFyzEIaOdp6Jrqqk9soK24feLvD2eHaAcaTSQvzkAACeyRb5JMqZ8MqJ(Y8dPnEbrzvNnrywZJ49YBL5XZkoKmVzMx8HIFyzE1EcOktrZPPYbHcO7Zbq92Db0eaQAo8ujeTpocmTxIujEwXHKaQhpakCaDoM4dfq3GdG6vM3eA0xMhk6xKM18iETBERmpEwXHK5nZ8Ipu8dlZBcn8Hm8WzGqaDdaDVzEtOrFzEY3i0hKvE000SMhXlVYBL5XZkoKmVzMx8HIFyz(KautOHpKHhodecOBWbq9zFyfhktTNKjmOYQoBIq9JKranbGMeGQXebuIhqlRAvk6zzb1OpPZGkdj6q8iGUbG6Z(WkousIoJBw1zteQFKmcOE8aO(SpSIdLKb0koKj6zzb1Opa1Fa1)mVj0OVmF1zteQFKmM18iET38wzEtOrFz(A8yXCUmpEwXHK5nZAwZ8q1os7jzFRMg9L3kpIx5TY84zfhsM3mZl(qXpSmFsaQj0WhYWdNbcb0n4aO(SpSIdLPTYG6JwYSQZMiu)izeqtaOjbOAmraL4b0YQwLIEwwqn6t6mOYqIoepcOBaO(SpSIdLKOZ4MvD2eH6hjJaQ)aQ)aAcaTSQvzARmO(OLS8rtOzEtOrFz(QZMiu)izmR5r2BERmpEwXHK5nZ8Ipu8dlZxw1QmTvguF0sw(OjuanbGww1QmTvguF0sw(40IdcO7dOMqJ(K14XI5CsKOOyPitJjM5nHg9L5h4(7IZGAwZJ4T5TY84zfhsM3mZl(qXpSmFzvRY0wzq9rlz5JMqb0eaAsa6WJ(yeeKsVK14XI5CaQhpaAnEeQ2R4lnHg(qa1Jha1eA0NCG7VlodQY4yvxqivbupEa0z7locaQ)zEtOrFz(bU)U4mOM18iEZ8wzE8SIdjZBM5fFO4hwMxKApbecOBWbq9wanbGAcn8Hm8WzGqaDdaDVaAcaLiaQp7dR4q5qAJxqu2q3U4iK5nHg9L5hsB8cIYQoBIWSMhz05TY84zfhsM3mZl(qXpSmFzvRY0wzq9rlz5JMqb0eaAsaQApbuLPO50u5Gqb095aOE7UaAcavnhEQeI2hhbM2lrQepR4qsa1JhafoGoht8HcOBWbq9cq9pZBcn6lZpW93fNb1SMhzpM3kZJNvCizEZmV4df)WY8LvTkh4(BHZGt5JMqb0eaQWGktJjcO7dOLvTkh4(BHZGt5JtloyM3eA0xMFG7VlodQznpYOAERmpEwXHK5nZ8liYgNgoKjmOghH8iEL5fFO4hwMpjaTSQv5VoK1v2qpgFjzp(a0eakra0A8iuTxXxAcn8HaQ)aAcaLiaQp7dR4qznEKvCguzdD7IJaGMaqtcqtcqtcqnHg9jRXJfZ5KirrXsJJaG6XdGAcn6toW93fNbvjsuuS04iaO(dOja0YQwLPOPXrGTgKpAcfq9hq94bqtcqtcqvZHNkHO9XrGP9sKkXZkoKeqtaOQ9eqvMIMttLdcfq3NdG6T7cOE8aOWb05yIpuaDdoaQxaQ)aAcanjaTSQvzkAACeyRb5JMqb0eakrautOrFsOOFrQejkkwACeaupEauIaOLvTktBLb1hTKLpAcfqtaOebqlRAvMIMghb2Aq(OjuanbGAcn6tcf9lsLirrXsJJaGMaqjcGAcn6toW93fNbvzCSQliKQaAcaLiaQj0OpznESyoNmow1fesva1Fa1Fa1)m)cISUwzeeK5r8kZBcn6lZxJhzfNb1SMhHyoVvMhpR4qY8MzEXhk(HL5tcqlRAvMIMghb2Aq(Ojua1JhanjaLiaAzvRY0wzq9rlz5JMqb0eaAsaQj0OpznEKvCguLIu7jGqaDdaDxa1JhavnhEQeI2hhbM2lrQepR4qsanbGQ2tavzkAonvoiuaDFoaQ3UlG6XdGchqNJj(qb0n4aOEbO(dO(dO(dOjauIaO(SpSIdLdPnEbrzdD7IJqM3eA0xMFiTXlikR6SjcZAEeVxERmpEwXHK5nZ8MqJ(Y8cZ5yMqJ(yUaQzExav2ztmZBcn8Hm1C4PWSMhXRDZBL5XZkoKmVzMx8HIFyzEtOHpKHhodecOBaOEL5nHg9L5jFJqFqw5rttZAEeV8kVvMhpR4qY8MzEtOrFzEH5CmtOrFmxa1mVlGk7SjM5dfNqMRhZg(O)q5oR5r8AV5TY84zfhsM3mZl(qXpSmVApbuLPO50u5Gqb095aOE7UaAcavnhEQeI2hhbM2lrQepR4qsa1JhafoGoht8HcOBWbq9kZBcn6lZdf9lsZAEeV828wzE8SIdjZBM5fFO4hwM3eA4dz4HZaHa6gCauF2hwXHYu7jzcdQSQZMiu)izeqtaOjbOAmraL4b0YQwLIEwwqn6t6mOYqIoepcOBaO(SpSIdLKOZ4MvD2eH6hjJaQ)zEtOrFz(QZMiu)izmR5r8YBM3kZBcn6lZxJhlMZL5XZkoKmVzwZJ41OZBL5nHg9L5HI(fPzE8SIdjZBM1SM5hEu0ZIP5TYJ4vERmVj0OVmV9c7qwCk6COqZ84zfhsM3mR5r2BERmpEwXHK5nZ89qMhIAM3eA0xM3N9HvCyM3N5wyMhhLvmmGKYPDrfHAZ6kBAKhcHaQhpakokRyyajLeCgzyA)qwXijGaQhpakokRyyajLeCgzyA)q2ejnNl6dq94bqXrzfddiPmiCHg9XMgbeYQlicOE8aO4OSIHbKuQeNDiKvSpz4qCieq94bqXrzfddiP0iU1JAAdzW4iGKSb3AAeqa1JhafhLvmmGKs7ebEkl5RvwxzJdizpbupEauCuwXWaskHPTi5sO4dzv7iaOE8aO4OSIHbKuE46nhdY9zdqKHxQDc8bupEauCuwXWasklMdRXJSYBNinZ7ZE2ztmZl6zzb1OpwFSfeZAEeVnVvMhpR4qY8Mz(EiZdrnZBcn6lZ7Z(WkomZ7ZClmZJJYkggqsPrCWu7niR2NY6kBOhJpGMaq9zFyfhkf9SSGA0hRp2cIzEF2ZoBIz(AFkJSxfhY6JTGywZJ4nZBL5XZkoKmVzMVhY8quZ8MqJ(Y8(SpSIdZ8(m3cZ87DxaDpb0KauF2hwXHsrpllOg9X6JTGiGMaqjcG6Z(Wkouw7tzK9Q4qwFSfebu)b0TbuV5Ua6EcOjbO(SpSIdL1(ugzVkoK1hBbra1FaDBaDVJgq3tanjafhLvmmGKsJ4GP2BqwTpL1v2qpgFanbGsea1N9HvCOS2NYi7vXHS(ylicO(dOBdOeZa6EcOjbO4OSIHbKuoTlQiuBwxztJ8qieqtaOebq9zFyfhkR9PmYEvCiRp2cIaQ)zEF2ZoBIz((yliYelTR1SMhz05TY84zfhsM3mZ3dz(hHOM5nHg9L59zFyfhM59zp7SjM5tBhjt0ZYcQrFmn9ryA7iZ8Ky1wonZV3DZAEK9yERmpEwXHK5nZ89qMhIAM3eA0xM3N9HvCyM3N5wyMFVa6EcOQ5WtLvNnr2GPIujEwXHKa62aQ3Z7bO7jGseavnhEQS6SjYgmvKkXZkoKmZl(qXpSmVp7dR4qzARmO(OLmR6Sjc1psgbuoa6UzEF2ZoBIz(0wzq9rlzw1zteQFKmM18iJQ5TY84zfhsM3mZ3dzEiQzEtOrFzEF2hwXHzEFMBHzEVfq3tavnhEQS6SjYgmvKkXZkoKeq3gq9EEpaDpbuIaOQ5WtLvNnr2GPIujEwXHKzEXhk(HL59zFyfhktTNKjmOYQoBIq9JKraLdGUBM3N9SZMyMp1EsMWGkR6Sjc1psgZAEeI58wzE8SIdjZBM57Hm)JquZ8MqJ(Y8(SpSIdZ8(SND2eZ8KOZ4MvD2eH6hjJzEsSAlNM537OZAEeVxERmpEwXHK5nZ89qM)riQzEtOrFzEF2hwXHzEF2ZoBIz(KJJ0fhb2JKlHg9L5jXQTCAMFx5EZAEeV2nVvMhpR4qY8Mz(ZMyM3ioyQ9gKv7tzDLn0JXpZBcn6lZBehm1EdYQ9PSUYg6X4N18iE5vERmVj0OVm)m(VFwmncyMhpR4qY8MznpIx7nVvM3eA0xMFO1OVmpEwXHK5nZAEeV828wzEtOrFz(bU)U4mOM5XZkoKmVzwZAwZ8(Whg9LhzV7U3D3D07D0z(X2FXraM5jgph6xrsa17bOMqJ(auxavOe4xMF47A4WmV3bOe74raDuBeqGFEhGMQ6aKy0o7qi00vrk65oWyUCMg9jERQ7aJPyhGFEhG636qa1lVjxa6E3DV7c8d4N3bOeRu7iGqIra)8oaL4buVpicOAmrM2mYab030u8bun1oavTNaQsnMitBgzGaATFa1zqL4HOOpsa1kHluUb0f0iGqjWpVdqjEa17BG0ueqDnHqaOpsmcqhvwIGeqjg8OnHsGFEhGs8a6Os3q8auHbva9XrzfpoXtHaATFaLy1ZYcQrFaAsHeLCbOK9rmub002rcOHcO1(budqRpctb0rnQy)aQWGQ)sGFEhGs8akXGaAfhcO2bO4Pp3aQMAkGoUxosa9r4YPaACaQbOP2tkmOcO7HC)DXzqfqJJ4jytuc8Z7auIhq3dEwXHaku)qOaQiffjhhbaTpa1a0kogqR9NmeqJdq1ueq9gShoQaOAdOpsUeiGoU)KDTrkb(b8Z7a09Gefflfjb0cw7hburplMcOfKqCqjG6nqiWbfcOxFeFQ9Z6YbOMqJ(GaAFoULa)8oa1eA0huo8OONft5uDgmzGFEhGAcn6dkhEu0ZIPBZzNA3Ka)8oa1eA0huo8OONft3MZo2IWep10OpGFMqJ(GYHhf9Sy62C2XEHDilofDouOa)mHg9bLdpk6zX0T5SJp7dR4qUoBICe9SSGA0hRp2cIC1dCGOYLpZTqo4OSIHbKuoTlQiuBwxztJ8qi0JhCuwXWaskj4mYW0(HSIrsa94bhLvmmGKscoJmmTFiBIKMZf95XdokRyyajLbHl0Op20iGqwDbrpEWrzfddiPujo7qiRyFYWH4qOhp4OSIHbKuAe36rnTHmyCeqs2GBnncOhp4OSIHbKuANiWtzjFTY6kBCaj7Php4OSIHbKuctBrYLqXhYQ2rWJhCuwXWaskpC9MJb5(SbiYWl1ob(E8GJYkggqszXCynEKvE7ePa)mHg9bLdpk6zX0T5SJp7dR4qUoBICQ9PmYEvCiRp2cIC1dCGOYLpZTqo4OSIHbKuAehm1EdYQ9PSUYg6X4NWN9HvCOu0ZYcQrFS(ylic8Z7auIXkoHaQMAkGApcOliscO9sHbjcODfqjw9SSGA0hGApcOxRa6cIKaQvv8bunnGaQgteqJkGQPi3a64E5ib0HLcOgGQFCjJkGUGijGoo0uaLy1ZYcQrFaAFaQbOWu7jrsav0TJShFsGFMqJ(GYHhf9Sy62C2XN9HvCixNnro9XwqKjwAxRC1dCGOYLpZTqo7D39mjF2hwXHsrpllOg9X6JTGycI4Z(Wkouw7tzK9Q4qwFSfe9FBV5U7zs(SpSIdL1(ugzVkoK1hBbr)3EVJEptchLvmmGKsJ4GP2BqwTpL1v2qpg)eeXN9HvCOS2NYi7vXHS(yli6)2eZ7zs4OSIHbKuoTlQiuBwxztJ8qimbr8zFyfhkR9PmYEvCiRp2cI(d8Z7auIvpllOg9bObeq7ZXnGUGijGoo00EPaQ3W(DK(W4auV)ryF2jqaTFaDuJZ(5gq7kGoQSebjGsm4rBcb0OcOHcOJdNdqliGA(SWzfhcOMcOo0GkGQPbeqN2XnGcrrFKqaTG1(ravtrafHq8eiXqiGk62r2JpanGa6Jgj3sGFMqJ(GYHhf9Sy62C2XN9HvCixNnroPTJKj6zzb1OpMM(imTDKC1dCEeIkxKy1woLZE3f4N3bOBLgqa1N9HvCiGchqrudecOAkcO3AwWhq7kGQ2taviGAkGoonePakXuRakV(OLmGsSD2eH6hjJqaTxkmiraTRakXQNLfuJ(auyAVCKaAbb0fejLa)mHg9bLdpk6zX0T5SJp7dR4qUoBICsBLb1hTKzvNnrO(rYix9ahiQCfvo(SpSIdLPTYG6JwYSQZMiu)izKZUC5ZClKZE3t1C4PYQZMiBWurQepR4qYT9EEV9KiQ5WtLvNnr2GPIujEwXHKa)8oaDR0acO(SpSIdbu4akIAGqavtra9wZc(aAxbu1EcOcbutb0XPHifqjMSNeqjwgubuITZMiu)izecO9sHbjcODfqjw9SSGA0hGct7LJeqliGUGijGAqaTgoh(sGFMqJ(GYHhf9Sy62C2XN9HvCixNnroP2tYeguzvNnrO(rYix9ahiQCfvo(SpSIdLP2tYeguzvNnrO(rYiND5YN5wihVDpvZHNkRoBISbtfPs8SIdj327592tIOMdpvwD2ezdMksL4zfhsc8Z7auVpyCeauITZMiu)izeqTQIpGsS6zzb1OpanGaA7dFavyhGkSfebudqHbHlQHWofqTzVofq7kGsAtJacOAdOfeqDnubuYfcOAdOAkcOTp8h)HghbaTRakXycxOiGQPMcOTqSEiGoofpavtraLymHlueqRFpbuU71dOdFmTNBaLy1ZYcQrFaQApbubu4WJgjucOBLgqa1N9HvCiGgqaDbrsavBafoGIOYnGQPiGAZEDkG2vavJjcOXbOqu0hjeq1utb05cQa6GbHaQvv8buIvpllOg9bOirhIhHaAbR9JakX2zteQFKmcb0XHZbOfeqxqKeqV(NMZXTe4Nj0OpOC4rrplMUnND8zFyfhY1ztKdj6mUzvNnrO(rYixKy1woLZEhnx9aNhHOc8Z7auVHHMcOE)fhPlocCbOeREwwqn6JyieqfD7i7XhGooCoaTGa6JKlbscOfUbudqF7i7jGAZEDkxaAzPaQMIa6TMf8b0UcOIpuiGcv7viG6dFUb00GqkGAvfFa1eA4Z04iaOeREwwqn6dqTJeqHUEmeqj7XhGQ9y7jHaQMIakEKaAxbuIvpllOg9rmecOIUDK94tcOEdtXdqNwYXraqjrraJ(GaACaQMIaQ3G9WrfUauIvpllOg9rmecOpoT4IJaGk62r2JpanGa6JKlbscOfUbunnGaA9nHg9bOAdOMq0Rtb0A)aQ3FXr6IJGe4Nj0OpOC4rrplMUnND8zFyfhY1ztKtYXr6IJa7rYLqJ(4IeR2YPC2vUxU6bopcrf4N3bOMqJ(GYHhf9Sy62C2bE2amTvgunfc8ZeA0huo8OONft3MZoliYcfNCD2e5yehm1EdYQ9PSUYg6X4d8ZeA0huo8OONft3MZoZ4)(zX0iGa)mHg9bLdpk6zX0T5SZqRrFa)mHg9bLdpk6zX0T5SZa3FxCgub(b8Z7a09Gefflfjbu0h(CdOAmravtra1eA)aAabuZNfoR4qjWptOrFqoIEDk(Wb05a(zcn6dUnND8zFyfhY1ztKJgtKPnt0ZYcQrFC1dCGOYLpZTqoQ5WtL14rOAVIVepR4qY9Sgpcv7v8LpoT4GBNKOBhzp(KIEwwqn6t(40IdUNj5fX7Z(WkouMCCKU4iWEKCj0OV9unhEQm54iDXrqINvCiP)eVj0Op5VoK1v2qpgFjsuuSuKPXe3t1C4PYFDiRRSHEm(s8SIdj9FpjIOBhzp(KIEwwqn6t(OrY9Eww1Qu0ZYcQrFsYE8b8ZeA0hCBo74Z(WkoKRZMihnMitBMONLfuJ(4Qh4mnIYLpZTqoIUDK94toXz)CZ6kZTebjJ8rBcLpoT4GCfvoieINaLtC2p3SUYClrqYiF0Mq508g7przvRYjo7NBwxzULiizKpAtOKShFjeD7i7XNCIZ(5M1vMBjcsg5J2ekFCAXbjEF2hwXHsnMitBMONLfuJ(2NJp7dR4qzA7izIEwwqn6JPPpctBhjWptOrFWT5SJp7dR4qUoBIC0yImTzIEwwqn6JREGZ0ikx(m3c5i62r2Jp54(DK(W4ypc7ZobkFCAXb5kQCqiepbkh3VJ0hgh7ryF2jq508g7przvRYX97i9HXXEe2NDcus2JVeIUDK94toUFhPpmo2JW(StGYhNwCqI3N9HvCOuJjY0Mj6zzb1OV954Z(WkouM2osMONLfuJ(yA6JW02rc8ZeA0hCBo7imNJzcn6J5cOY1ztKtO4eYsdcPSHp6puUb(zcn6dUnNDMX)9ZIPra5kQCkRAvk6zzb1Opjzp(a(zcn6dUnNDiSSNmSJ1vMrC43AkxrLts(SpSIdLAmrM2mrpllOg9TVx76XJgtKPnJmW99zFyfhk1yImTzIEwwqn6ZFGFMqJ(GBZzhrFc803uKKvD2eb(zcn6dUnNDE0gIJaR6Sjcb(zcn6dUnNDQTybrsMrC4hkYkOnb(zcn6dUnNDgwFu5oocSIZGkWptOrFWT5SZhddoKfhdoyce4Nj0Op42C2rtr26k96iz1(fiWptOrFWT5SZVoK1v2qpgFUIkNYQwL)6qwxzd9y8LK94lrzvRsrpllOg9jj7XxIK8zFyfhk1yImTzIEwwqn6BJ6Y5ypksTNaY0yIE84Z(WkouQXezAZe9SSGA03gQ9eqvQXezAZid0FGFMqJ(GBZzhH5CmtOrFmxavUoBICe9SSGA0hBi1GixrLJp7dR4qPgtKPnt0ZYcQrF7ZzxGFMqJ(GBZzNA8iR4mOY1cISUwzeeKC8IRfezJtdhYeguJJahV4kQCscHq8eOCIZ(5M1vMBjcsg5J2ekNM3y)E8GqiEcuoXz)CZ6kZTebjJ8rBcLZ46pHrC4hkklodQ4ZMguXxINvCiP)jeP2taHCMgrzIu7jGWeePSQvzARmO(OLS8rtOjissLvTktrtJJaBniF0eAIKkRAvk6zzb1Op5AirsMqJ(K14XI5CY4yvxqiv94XeA0NCG7VlodQY4yvxqiv94XeA0Nek6xKkrIIILghb)94rTNaQYu0CAQCqO7ZXB3nHj0Opju0VivIefflnoc(7FcIKerkRAvMIMghb2Aq(Oj0eePSQvzARmO(OLS8rtOjkRAvk6zzb1Opjzp(sKKj0OpznESyoNmow1fesvpEmHg9jh4(7IZGQmow1fesv)9h4Nj0Op42C2XN9HvCixNnro14rwXzqLn0TlocC5ZClKJAo8u5VoK1v2qpgFjEwXHKjeD7i7XN8xhY6kBOhJV8XPfhCFr3oYE8jRXJSIZGQSUCo2JIu7jGmnMyIK8zFyfhk1yImTzIEwwqn6BdtOrFYFDiRRSHEm(Y6Y5ypksTNaY0yI(Nijr3oYE8j)1HSUYg6X4lFCAXb3xJjY0MrgOhpMqJ(K)6qwxzd9y8LIu7jGWn21FpE8zFyfhk1yImTzIEwwqn6BFtOrFYA8iR4mOkRlNJ9Oi1EcitJjMWN9HvCOuJjY0Mj6zzb1OV91yImTzKbc8ZeA0hCBo7imNJzcn6J5cOY1ztKZ3dSHudICb1pekhV4kQCkRAv(RdzDLn0JXxUgsKKp7dR4qPgtKPnt0ZYcQrFBSR)a)mHg9b3MZo(SpSId56SjYziTXlikBOBxCe4YN5wih1C4PYFDiRRSHEm(s8SIdjti62r2Jp5VoK1v2qpgF5Jtlo4(IUDK94toK24feLvD2eHY6Y5ypksTNaY0yIjsYN9HvCOuJjY0Mj6zzb1OVnmHg9j)1HSUYg6X4lRlNJ9Oi1EcitJj6FIKeD7i7XN8xhY6kBOhJV8XPfhCFnMitBgzGE8ycn6t(RdzDLn0JXxksTNac3yx)94XN9HvCOuJjY0Mj6zzb1OV9nHg9jhsB8cIYQoBIqzD5CShfP2tazAmXe(SpSIdLAmrM2mrpllOg9TVgtKPnJmqGFEhG6nmfpaLyYEsHb14iaOeBNnraLx)izKlaLyhpcOB6mOcbuyAVCKaAbb0fejbuTbuc4HVPiGsm1kGYRpAjdbu7ibuTbuKOkEKa6ModQ4dOJAdQ4lb(zcn6dUnNDQXJSIZGkxliY6ALrqqYXlUwqKnonCityqnocC8IROYjjI4Z(WkouwJhzfNbv2q3U4i4XtzvRYFDiRRSHEm(Y1G)jsYN9HvCOuJjY0Mj6zzb1OVn21)ejzcn8Hm8WzGWn44Z(WkouMApjtyqLvD2eH6hjJjssJjs8LvTkf9SSGA0N0zqLHeDiECdF2hwXHss0zCZQoBIq9JKr)9pbrQXJq1EfFPj0WhMOSQvzARmO(OLSKShFjsIigXHFOOS4mOIpBAqfFjEwXHKE8uw1QS4mOIpBAqfF5Jtlo4(7khT)a)8oaLyW6JJaGsSJhHQ9k(CbOe74raDtNbviGApcOliscOWygo7DCdOAdOKRpocakXQNLfuJ(KaQ3VXdFZ54MlavtrUbu7raDbrsavBaLaE4BkcOetTcO86JwYqaDCkEaQ4dfcOJdNdqVwb0ccOJnOIKaQDKa64qtb0nDguXhqh1guXNlavtrUbuyAVCKaAbbu4WJgjG2lfq1gqNwCQfhGQPiGUPZGk(a6O2Gk(aAzvRsGFMqJ(GBZzNA8iR4mOY1cISUwzeeKC8IRfezJtdhYeguJJahV4kQCQXJq1EfFPj0WhMqKApbeUbhVsKer8zFyfhkRXJSIZGkBOBxCe84PSQv5VoK1v2qpgF5AW)ejreJ4WpuuwCguXNnnOIVepR4qspEkRAvwCguXNnnOIV8XPfhC)DLJ2)ejretOrFYA8yXCojsuuS04iKGiMqJ(KdC)DXzqvghR6ccPAIYQwLPOPXrGTgKRbpEmHg9jRXJfZ5KirrXsJJqIYQwLPTYG6JwYsYE85XJj0Op5a3FxCguLXXQUGqQMOSQvzkAACeyRbjzp(suw1QmTvguF0sws2Jp)b(zcn6dUnNDeMZXmHg9XCbu56SjYbQ2rApj7B10OpUG6hcLJxCfvo(SpSIdLAmrM2mrpllOg9TXUa)a(zcn6dknHg(qMAo8uihx4locSsplCfvoMqdFidpCgiCdVsuw1Qu0ZYcQrFsYE8LijF2hwXHsnMitBMONLfuJ(2q0TJShFsx4locSsplsY1BA0Nhp(SpSIdLAmrM2mrpllOg9TpND9h4Nj0OpO0eA4dzQ5WtHBZzNjQy)Cfvo(SpSIdLAmrM2mrpllOg9TpND94jPYQwL)6qwxzd9y8LRbpEeD7i7XN8xhY6kBOhJV8XPfhCdnMitBgzGjmHg9j)1HSUYg6X4lfP2taH77LhpernhEQ8xhY6kBOhJVepR4qs)tKKOBhzp(KtuX(LKR30OV99zFyfhk1yImTzIEwwqn6ZJhnMitBgzG77Z(WkouQXezAZe9SSGA0N)a)mHg9bLMqdFitnhEkCBo7q(gH(GSYJMMYvu5OMdpvAoKOq9niXzqwD9ClXZkoKmrsLvTkf9SSGA0NKShFjiszvRY0wzq9rlz5JMq94PSQvPONLfuJ(KRHeMqJ(K14rwXzqvksTNac33eA0NSgpYkodQYPruMi1EcimbrkRAvM2kdQpAjlF0eQ)a)a(5DakXQNLfuJ(a0HudIa6WJd2Jqa1kHl0aHa64qtbudqjrNXnxaQMIhG6S1jsriGgN2aQMIakXQNLfuJ(auiokl8eiWptOrFqPONLfuJ(ydPge54ccPkK5nUijmXt5kQCkRAvk6zzb1Opjzp(a(zcn6dkf9SSGA0hBi1G42C2PyeyDLPFisgYvu5uw1Qu0ZYcQrFsYE8b8ZeA0huk6zzb1Op2qQbXT5SJl8fhbwPNfUIkhtOHpKHhodeUHxjkRAvk6zzb1Opjzp(a(zcn6dkf9SSGA0hBi1G42C2P46MK1vMMIm8Wj3a)mHg9bLIEwwqn6JnKAqCBo7mXz)CZ6kZTebjJ8rBcb(zcn6dkf9SSGA0hBi1G42C2zC)osFyCShH9zNab(5DakXG1hhbaLy1ZYcQrFCbOe74raDtNbviGApcOliscOAdOeWdFtraLyQvaLxF0sgcO2rcOZ4IzqCiGQPiGAZEDkG2vavJjcOWb8uafjkkwACea0wtXhqHdOZbLakXUFafQ2rApjGsSJh5cqj2XJa6ModQqa1Eeq7ZXnGUGijGoofpaLycnnocaQ33aGgqa1eA4db0(b0XP4bOgGYl6xKcOcdQaAab04a0HVj8iecO2rcOetOPXraq9(gau7ibuIPwbuE9rlza1EeqVwbutOHpucOEddnfq30zqfFaDuBqfFa1osaLy7SjcOE)CCbOe74raDtNbviGkSdqnsYqJ(mNJBaTGa6cIKa640WHakXuRakV(OLmGAhjGsmHMghba17BaqThb0Rva1eA4dbu7ibudq3d5(7IZGkGgqanoavtra1IhqTJeqnhSb0XPHdbuHb14iaO8I(fPak6dpanQakXeAACeauVVbanGaQ5E0i5gqnHg(qjGUvkcOotv8buZ56Xqavh3akXuRakV(OLmGUhY93fNbviGQnGwqavyqfqJdqHlHaHWOpa1Qk(aQMIakVOFrQeq9gqsgA0N5CCdOJdnfq30zqfFaDuBqfFa1osaLy7SjcOE)CCbOe74raDtNbviGct7LJeqVwb0ccOliscORZHqiGUPZGk(a6O2Gk(aAabuR0lfq1gqrIoepcO9dOAk(iGApcOZ(ravtTdqXRxesbuID8iGUPZGkeq1gqrIQ4rcOB6mOIpGoQnOIpGQnGQPiGIhjG2vaLy1ZYcQrFsGFMqJ(GsrpllOg9XgsniUnNDQXJSIZGkxliY6ALrqqYXlUwqKnonCityqnocC8IROYrKApbeUbhVsKusMqJ(K14rwXzqvksTNacz13eA0N52oPYQwLIEwwqn6t(40Ids8LvTklodQ4ZMguXxsUEtJ(8FpGOBhzp(K14rwXzqvsUEtJ(i(KkRAvk6zzb1Op5JtloO)7bsQSQvzXzqfF20Gk(sY1BA0hXVRC0(7)gC21JhIyeh(HIYIZGk(SPbv8L4zfhs6XdruZHNkRoBIS(K4zfhs6XtzvRsrpllOg9jFCAXb3NtzvRYIZGk(SPbv8LKR30OppEkRAvwCguXNnnOIV8XPfhC)DLJ2JhCuwXWaskt5EaFn9rJKn(dOo(Tbycr3oYE8jt5EaFn9rJKn(dOo(TbiZB3DxV8M7v(40IdU)O9przvRsrpllOg9jxdjsIiMqJ(Kqr)IujsuuS04iKGiMqJ(KdC)DXzqvghR6ccPAIYQwLPOPXrGTgKRbpEmHg9jHI(fPsKOOyPXrirzvRY0wzq9rlzjzp(sKuzvRYu004iWwdsYE85XJrC4hkklodQ4ZMguXxINvCiP)E8yeh(HIYIZGk(SPbv8L4zfhsMqnhEQS6SjY6tINvCizctOrFYbU)U4mOkJJvDbHunrzvRYu004iWwdsYE8LOSQvzARmO(OLSKShF(d8ZeA0huk6zzb1Op2qQbXT5SZVoK1v2qpgFUIkNYQwL)6qwxzd9y8LK94lrzvRsrpllOg9jj7XhWpVdq9gaOe74raDtNbvafM2lhjGwqaDbrsavBa1ggCCdOB6mOIpGoQnOIpGoonCiGkmOghba17)1HaAxb09WEm(a64u8a0fmoca6ModQ4dOJAdQ4ZfGsSD2ebuVFoUau7ib0rnQy)saLyCfq7ZXnGoQXz)CdODfqhvwIGeqjg8OnHa6OoU(b0acO4OSIHbKKlavtdiG6Idb0acObHRFKeqlOWwqeqdfqhhohGc7jQXeHa6JWLtb04aucDCea040gqjw9SSGA0hGoo0uaTIJbuID8iGUPZGkGksTNacLa)mHg9bLIEwwqn6JnKAqCBo7uJhzfNbvUwqKnonCityqnocC8IROYXio8dfLfNbv8ztdQ4lXZkoKmrsieINaLtC2p3SUYClrqYiF0Mq508g73JhIGqiEcuoXz)CZ6kZTebjJ8rBcLZ463)eQ5WtLtuX(L4zfhsMqnhEQS6SjY6tINvCizIYQwLfNbv8ztdQ4lj7XxIKuZHNk)1HSUYg6X4lXZkoKmHj0Op5VoK1v2qpgFjsuuS04iKWeA0N8xhY6kBOhJVejkkwkYECAXb3Fx5E0JNK8zFyfhk1yImTzIEwwqn6BFo76XtzvRsrpllOg9jxd(NGiQ5WtL)6qwxzd9y8L4zfhsMGiMqJ(KdC)DXzqvghR6ccPAcIycn6twJhlMZjJJvDbHu1FGFMqJ(GsrpllOg9XgsniUnNDeMZXmHg9XCbu56SjYXeA4dzQ5WtHa)mHg9bLIEwwqn6JnKAqCBo7i6zzb1OpUwqK11kJGGKJxCTGiBCA4qMWGACe44fxrLtsjzcn6torf7xghR6ccPActOrFYjQy)Y4yvxqivzpoT4G7Zzx5O93JhtOrFYjQy)Y4yvxqiv94bHq8eOCIZ(5M1vMBjcsg5J2ekNM3y)E8uw1QmTvguF0sw(OjupEmHg9jHI(fPsKOOyPXriHj0Opju0VivIefflfzpoT4G7VRC0E8ycn6toW93fNbvjsuuS04iKWeA0NCG7VlodQsKOOyPi7XPfhC)DLJ2)ejvw1Q8xhY6kBOhJVCn4XdruZHNk)1HSUYg6X4lXZkoK0FGFMqJ(GsrpllOg9XgsniUnNDgAn6d4Nj0OpOu0ZYcQrFSHudIBZzNIRBswD9Cd8ZeA0huk6zzb1Op2qQbXT5StbFi(jhhbGFMqJ(GsrpllOg9XgsniUnNDQXJfx3Ka)mHg9bLIEwwqn6JnKAqCBo7yNaH6BoMWCoGFMqJ(GsrpllOg9XgsniUnNDQoBIq9JKrUIkNKssnhEQS6SjYgmvKkXZkoKmHj0WhYWdNbc3yV(7XJj0WhYWdNbc3yp6FIYQwLPTYG6JwYYhnHMGigXHFOOS4mOIpBAqfFjEwXHKa)mHg9bLIEwwqn6JnKAqCBo7mW93fNbvUIkNYQwLdC)TWzWP8rtOjkRAvk6zzb1Op5Jtlo4gcdQmnMiWptOrFqPONLfuJ(ydPge3MZodC)DXzqLROYPSQvzARmO(OLS8rtOa)8oaLy1ZjEACeaunnGakE6ZnG2l17xaAOedHa6JoUJJaG2hGAa6JMqJ(aunMiGsIoJBaDCkEak39cqt(6Xak396buEr)IuaDC4CaQ4dfqTJeq5UxaAQrcOetOPXraq9(ga0XP4bOC3lavyqfq5f9lsLa)8oaLy8r8eSjYfGQPbeqdiGMAhPdjb0z)iGEMUEZ54wc8Z7autOrFqPONLfuJ(ydPge3MZodC)DXzqLROYz4rFmccsPxsOOFrAIYQwLPOPXrGTgKRbGFMqJ(GsrpllOg9XgsniUnNDgsB8cIYQoBIqGFMqJ(GsrpllOg9XgsniUnNDGI(fPCfvoLvTkf9SSGA0N8XPfhCdHbvMgtmrzvRsrpllOg9jxdE8uw1Qu0ZYcQrFsYE8Lq0TJShFsrpllOg9jFCAXb3xyqLPXeb(zcn6dkf9SSGA0hBi1G42C2Xf(IJaR0ZcxrLtzvRsrpllOg9jFCAXb3NGGuonIMWeA4dz4HZaHB4fWptOrFqPONLfuJ(ydPge3MZoKVrOpiR8OPPCfvoLvTkf9SSGA0N8XPfhCFccs50iAIYQwLIEwwqn6tUga(zcn6dkf9SSGA0hBi1G42C2bk6xKYvu5O2tavzkAonvoi0954T7MqnhEQeI2hhbM2lrQepR4qsGFa)mHg9bLHItit0ZYcQrFCwqKfko56SjYjiCHg9XMgbeYQlic8ZeA0hugkoHmrpllOg9TnNDwqKfko56SjYjL7b810hns24pG643gGCfvoLvTkf9SSGA0NCnKWeA0NSgpYkodQsrQ9eqiNDtycn6twJhzfNbv5JIu7jGmnM4geeKYPruGFMqJ(GYqXjKj6zzb1OVT5SZcISqXjxNnrot7Ikc1M1v20ipecb(zcn6dkdfNqMONLfuJ(2MZoc7eOJvw1kxliY6ALrqqYXlUoBICM2fveQnRRSPrEieYeP2GIpRpKROYPSQvPONLfuJ(KRbpEmHg9jNOI9lJJvDbHunHj0Op5evSFzCSQliKQShNwCW95SRC0a)mHg9bLHItit0ZYcQrFBZzNfezHItUwqK11kJGGKJxCD2e5ye36rnTHmyCeqs2GBnncixrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPActOrFYjQy)Y4yvxqivzpoT4G7Zzx5Ob(zcn6dkdfNqMONLfuJ(2MZoliYcfNCTGiRRvgbbjhV4cRvuOSZMihcoJmmTFiRyKeqUIkNYQwLIEwwqn6tUg84XeA0NCIk2Vmow1fes1eMqJ(KtuX(LXXQUGqQYECAXb3NZUYrd8ZeA0hugkoHmrpllOg9TnNDwqKfko5AbrwxRmccsoEXfwROqzNnroeCgzyA)q2ejnNl6JROYPSQvPONLfuJ(KRbpEmHg9jNOI9lJJvDbHunHj0Op5evSFzCSQliKQShNwCW95SRC0a)mHg9bLHItit0ZYcQrFBZzNfezHItUwqK11kJGGKJxCD2e5umhwJhzL3orkxrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPActOrFYjQy)Y4yvxqivzpoT4G7Zzx5Ob(zcn6dkdfNqMONLfuJ(2MZoliYcfNCTGiRRvgbbjhV46SjYbM2IKlHIpKvTJaxrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPActOrFYjQy)Y4yvxqivzpoT4G7Zzx5Ob(zcn6dkdfNqMONLfuJ(2MZoliYcfNCTGiRRvgbbjhV46SjYrjo7qiRyFYWH4qixrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPActOrFYjQy)Y4yvxqivzpoT4G7Zzx5Ob(zcn6dkdfNqMONLfuJ(2MZoliYcfNCTGiRRvgbbjhV46SjYXorGNYs(AL1v24as2tUIkNYQwLIEwwqn6tUg84XeA0NCIk2Vmow1fes1eMqJ(KtuX(LXXQUGqQYECAXb3NZUYrd8ZeA0hugkoHmrpllOg9TnNDwqKfko5AbrwxRmccsoEX1ztKZHR3Cmi3NnargEP2jWNROYPSQvPONLfuJ(KRbpEmHg9jNOI9lJJvDbHunHj0Op5evSFzCSQliKQShNwCW95SRC0a)mHg9bLHItit0ZYcQrFBZzNfezHItUwqK11kJGGKJxCD2e5mnxT)jsYsX3CKqMdjm(TbixrLtzvRsrpllOg9jxdE8ycn6torf7xghR6ccPActOrFYjQy)Y4yvxqivzpoT4G7Zzx5Ob(b8ZeA0hugkoHS0GqkB4J(dLBocZ5yMqJ(yUaQCD2e5ekoHmrpllOg9Xvu54Z(WkouQXezAZe9SSGA03(C2f4Nj0OpOmuCczPbHu2Wh9hk3BZzNfezHItiWptOrFqzO4eYsdcPSHp6puU3MZoliYcfNCD2e5mTlQiuBwxztJ8qiKROYHi4OSIHbKuAehm1EdYQ9PSUYg6X4NWN9HvCOuJjY0Mj6zzb1OV9jMb(zcn6dkdfNqwAqiLn8r)HY92C2zbrwO4KRZMihJ4GP2BqwTpL1v2qpgFUIkhF2hwXHsnMitBMONLfuJ(2NZO32RrVN(SpSIdL1(ugzVkoK1hBbrGFMqJ(GYqXjKLgeszdF0FOCVnNDwqKfko56SjY5Bv8lOIKmFDt2nJSDoUIkhF2hwXHsnMitBMONLfuJ(2WN9HvCOSp2cImXs7Af4Nj0OpOmuCczPbHu2Wh9hk3BZzNfezHItUoBICSrzfdTINYoBPHBb5kQC8zFyfhk1yImTzIEwwqn6BdF2hwXHY(yliYelTRvGFMqJ(GYqXjKLgeszdF0FOCVnNDwqKfko56SjYbMg(WN5dVEYE0fcUIkhF2hwXHsnMitBMONLfuJ(2WN9HvCOSp2cImXs7Af4Nj0OpOmuCczPbHu2Wh9hk3BZzNfezHItUoBICQ9xcss8yDbgKHDmHZgZvu54Z(WkouQXezAZe9SSGA03g(SpSIdL9XwqKjwAxRa)mHg9bLHItilniKYg(O)q5EBo7SGiluCYfwROqzNnroP2p7lemsCAk(H5cIdFGFMqJ(GYqXjKLgeszdF0FOCVnNDwqKfko56SjYzAUA)tKKLIV5iHmhsy8BdqUIkhF2hwXHsnMitBMONLfuJ(2GZOhDIYQwLIEwwqn6ts2JVe(SpSIdLAmrM2mrpllOg9THp7dR4qzFSfezIL21kWptOrFqzO4eYsdcPSHp6puU3MZoliYcfNCD2e5yNiWtzjFTY6kBCaj7jxrLJp7dR4qPgtKPnt0ZYcQrFBWz0JorzvRsrpllOg9jj7XxcF2hwXHsnMitBMONLfuJ(2WN9HvCOSp2cImXs7Af4Nj0OpOmuCczPbHu2Wh9hk3BZzNfezHItUoBICoC9MJb5(SbiYWl1ob(Cfvo(SpSIdLAmrM2mrpllOg9TbhV5Otuw1Qu0ZYcQrFsYE8LWN9HvCOuJjY0Mj6zzb1OVn8zFyfhk7JTGitS0Uwb(b8ZeA0hugkoHmxpMn8r)HYnNfezHItUoBIC0GeHA)tMOjrIYvu54Z(WkouQXezAZe9SSGA03g(SpSIdL9XwqKjwAxRa)mHg9bLHItiZ1JzdF0FOCVnNDwqKfko5cRvuOSZMihb3cxRFFHGvCgu5kQC8zFyfhk1yImTzIEwwqn6BdF2hwXHY(yliYelTRvGFa)mHg9bLFpWgsniYP6Sjc1psg5kQCsYeA4dz4HZaHBWXN9HvCOmTvguF0sMvD2eH6hjJjssJjs8LvTkf9SSGA0N0zqLHeDiECdF2hwXHss0zCZQoBIq9JKrpE8zFyfhkjdOvCit0ZYcQrF(7FIYQwLPTYG6JwYYhnHc8ZeA0hu(9aBi1G42C2zG7VlodQCfvoLvTktBLb1hTKLpAcf4Nj0OpO87b2qQbXT5StnEKvCgu5AbrwxRmccsoEX1cISXPHdzcdQXrGJxCfvoejjtOHpKHhodeUbhF2hwXHYu7jzcdQSQZMiu)izmrsAmrIVSQvPONLfuJ(KodQmKOdXJB4Z(WkousIoJBw1zteQFKm6XJp7dR4qjzaTIdzIEwwqn6ZF)tqKA8iuTxXxAcn8HjsIiLvTktrtJJaBniF0eAcIuw1QmTvguF0sw(Oj0eez4rFSUwzeeKYA8iR4mOMijtOrFYA8iR4mOkfP2taHBWzVE8KKj0Op5qAJxquw1ztekfP2taHBWXReQ5WtLdPnEbrzvNnrOepR4qs)94jj1C4PsZHefQVbjodYQRNBjEwXHKjeD7i7XNK8nc9bzLhnnv(OrYT)E8KKAo8ujeTpocmTxIujEwXHKju7jGQmfnNMkhe6(C82D94boGoht8HUbhV83F)b(zcn6dk)EGnKAqCBo7imNJzcn6J5cOY1ztKJj0WhYuZHNcb(zcn6dk)EGnKAqCBo7mW93fNbvUIkNYQwLdC)TWzWP8rtOjeguzAmX9lRAvoW93cNbNYhNwCWeLvTk)1HSUYg6X4lFCAXb3qyqLPXeb(zcn6dk)EGnKAqCBo7uJhzfNbvUwqK11kJGGKJxCTGiBCA4qMWGACe44fxrLdrsYeA4dz4HZaHBWXN9HvCOm1EsMWGkR6Sjc1psgtKKgtK4lRAvk6zzb1OpPZGkdj6q84g(SpSIdLKOZ4MvD2eH6hjJE84Z(WkousgqR4qMONLfuJ(83)eePgpcv7v8LMqdFyIKkRAvMIMghb2Aq(Oj0eWb05yIp099krsQ9eqvMIMttLdcDdoE7UE8qe1C4PsiAFCeyAVePs8SIdj93FGFMqJ(GYVhydPge3MZo14rwXzqLRfezDTYiii54fxliYgNgoKjmOghboEXvu5qKKmHg(qgE4mq4gC8zFyfhktTNKjmOYQoBIq9JKXejPXej(YQwLIEwwqn6t6mOYqIoepUHp7dR4qjj6mUzvNnrO(rYOhp(SpSIdLKb0koKj6zzb1Op)9pbrQXJq1EfFPj0WhMij1C4PsiAFCeyAVePs8SIdjtO2tavzkAonvoi0954T76XdCaDoM4dDdoE5FIKkRAvMIMghb2Aq(Oj0eeXeA0Nek6xKkrIIILghbpEiszvRYu004iWwdYhnHMGiLvTktBLb1hTKLpAc1FGFEhGAcn6dk)EGnKAqCBo7mW93fNbvUIkNHh9XiiiLEjHI(fPjkRAvMIMghb2AqUgsKKAo8ujeTpocmTxIujEwXHKju7jGQmfnNMkhe6(C82D94boGoht8HUbhV8pbrsYeA4dz4HZaHBWXN9HvCOmTvguF0sMvD2eH6hjJjssJjs8LvTkf9SSGA0N0zqLHeDiECdF2hwXHss0zCZQoBIq9JKrpE8zFyfhkjdOvCit0ZYcQrF(7pWptOrFq53dSHudIBZzNH0gVGOSQZMiKROYHidp6Jrqqk9soK24feLvD2eHjkRAvMIMghb2Aq(OjuGFMqJ(GYVhydPge3MZoqr)IuUIkh1EcOktrZPPYbHUphVD3eQ5WtLq0(4iW0EjsL4zfhs6XdCaDoM4dDdoEb8ZeA0hu(9aBi1G42C2H8nc9bzLhnnLROYXeA4dz4HZaHBSxGFMqJ(GYVhydPge3MZovNnrO(rYixrLtsMqdFidpCgiCdo(SpSIdLP2tYeguzvNnrO(rYyIK0yIeFzvRsrpllOg9jDguzirhIh3WN9HvCOKeDg3SQZMiu)iz0JhF2hwXHsYaAfhYe9SSGA0N)(d8ZeA0hu(9aBi1G42C2PgpwmNd4hWptOrFqjuTJ0Es23QPrFCQoBIq9JKrUIkNKmHg(qgE4mq4gC8zFyfhktBLb1hTKzvNnrO(rYyIK0yIeFzvRsrpllOg9jDguzirhIh3WN9HvCOKeDg3SQZMiu)iz0F)tuw1QmTvguF0sw(OjuGFMqJ(GsOAhP9KSVvtJ(2MZodC)DXzqLROYPSQvzARmO(OLS8rtOjkRAvM2kdQpAjlFCAXb33eA0NSgpwmNtIefflfzAmrGFMqJ(GsOAhP9KSVvtJ(2MZodC)DXzqLROYPSQvzARmO(OLS8rtOjsA4rFmccsPxYA8yXCopEQXJq1EfFPj0Wh6XJj0Op5a3FxCguLXXQUGqQ6XZS9fhb)b(zcn6dkHQDK2tY(wnn6BBo7mK24feLvD2eHCfvoIu7jGWn44TjmHg(qgE4mq4g7nbr8zFyfhkhsB8cIYg62fhbGFMqJ(GsOAhP9KSVvtJ(2MZodC)DXzqLROYPSQvzARmO(OLS8rtOjssTNaQYu0CAQCqO7ZXB3nHAo8ujeTpocmTxIujEwXHKE8ahqNJj(q3GJx(d8ZeA0hucv7iTNK9TAA032C2zG7VlodQCfvoLvTkh4(BHZGt5JMqtimOY0yI7xw1QCG7VfodoLpoT4Ga)mHg9bLq1os7jzFRMg9TnNDQXJSIZGkxliY6ALrqqYXlUwqKnonCityqnocC8IROYjPYQwL)6qwxzd9y8LK94lbrQXJq1EfFPj0Wh6FcI4Z(WkouwJhzfNbv2q3U4iKiPKsYeA0NSgpwmNtIefflnocE8ycn6toW93fNbvjsuuS04i4FIYQwLPOPXrGTgKpAc1FpEskj1C4PsiAFCeyAVePs8SIdjtO2tavzkAonvoi0954T76XdCaDoM4dDdoE5FIKkRAvMIMghb2Aq(Oj0eeXeA0Nek6xKkrIIILghbpEiszvRY0wzq9rlz5JMqtqKYQwLPOPXrGTgKpAcnHj0Opju0VivIefflnocjiIj0Op5a3FxCguLXXQUGqQMGiMqJ(K14XI5CY4yvxqiv93F)b(5DaQj0OpOeQ2rApj7B10OVT5SZa3FxCgu5kQCgE0hJGGu6Lek6xKMOSQvzkAACeyRb5AirsQ5WtLq0(4iW0EjsL4zfhsMqTNaQYu0CAQCqO7ZXB31Jh4a6CmXh6gC8Y)eejjtOHpKHhodeUbhF2hwXHY0wzq9rlzw1zteQFKmMijnMiXxw1Qu0ZYcQrFsNbvgs0H4Xn8zFyfhkjrNXnR6Sjc1psg94XN9HvCOKmGwXHmrpllOg95V)a)mHg9bLq1os7jzFRMg9TnNDgsB8cIYQoBIqUIkNKkRAvMIMghb2Aq(OjupEsIiLvTktBLb1hTKLpAcnrsMqJ(K14rwXzqvksTNac3yxpEuZHNkHO9XrGP9sKkXZkoKmHApbuLPO50u5Gq3NJ3URhpWb05yIp0n44L)(7FcI4Z(WkouoK24feLn0Tloca)mHg9bLq1os7jzFRMg9TnNDeMZXmHg9XCbu56SjYXeA4dzQ5WtHa)mHg9bLq1os7jzFRMg9TnNDiFJqFqw5rtt5kQCmHg(qgE4mq4gEb8ZeA0hucv7iTNK9TAA032C2ryohZeA0hZfqLRZMiNqXjK56XSHp6puUb(zcn6dkHQDK2tY(wnn6BBo7af9ls5kQCu7jGQmfnNMkhe6(C82DtOMdpvcr7JJat7LivINvCiPhpWb05yIp0n44fWpVdq9ggAkGIxViKcOQ9eqfYfGgkGgqa1aucwCaQ2aQWGkGsSD2eH6hjJaQbb0A4C4dOXbv0ib0UcOe74XI5CsGFMqJ(GsOAhP9KSVvtJ(2MZovNnrO(rYixrLJj0WhYWdNbc3GJp7dR4qzQ9KmHbvw1zteQFKmMijnMiXxw1Qu0ZYcQrFsNbvgs0H4Xn8zFyfhkjrNXnR6Sjc1psg9h4Nj0OpOeQ2rApj7B10OVT5StnESyohWptOrFqjuTJ0Es23QPrFBZzhOOFrAMhoGI8i7rVnRznNb]] )


end
