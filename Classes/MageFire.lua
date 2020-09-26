-- MageFire.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( "player" ) == "MAGE" then
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
        focus_magic = 22445, -- 321358
        rune_of_power = 22447, -- 116011

        flame_on = 22450, -- 205029
        alexstraszas_fury = 22465, -- 235870
        from_the_ashes = 22468, -- 342344

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
        controlled_burn = 645, -- 280450
        dampened_magic = 3524, -- 236788
        firestarter = 646, -- 203283
        flamecannon = 647, -- 203284
        greater_pyroblast = 648, -- 203286
        kleptomania = 3530, -- 198100
        netherwind_armor = 53, -- 198062
        prismatic_cloak = 828, -- 198064
        tinder = 643, -- 203275
        world_in_flames = 644, -- 203280
    } )

    -- Auras
    spec:RegisterAuras( {
        alexstraszas_fury = {
            id = 334277,
            duration = 15,
            max_stack = 1,
        },
        alter_time = {
            id = 110909,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        arcane_intellect = {
            id = 1459,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        blast_wave = {
            id = 157981,
            duration = 6,
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
        chilled = {
            id = 205708,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        combustion = {
            id = 190319,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        conflagration = {
            id = 226757,
            duration = 8,
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
        fireball = {
            id = 157644,
            duration = 15,
            type = "Magic",
            max_stack = 10,
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
        frostbolt = {
            id = 59638,
            duration = 4,
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
        incanters_flow = {
            id = 116267,
            duration = 3600,
            max_stack = 5,
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
        pyroblast = {
            id = 321712,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        pyroclasm = {
            id = 269651,
            duration = 15,
            max_stack = 2,
        },
        ring_of_frost = {
            id = 321329,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        rune_of_power = {
            id = 116014,
            duration = 15,
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


    --[[ spec:RegisterVariable( "combustion_on_use", function ()
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
    end ) ]]
    
    
    -- Abilities
    spec:RegisterAbilities( {
        alter_time = {
            id = function () return buff.alter_time.down and 342247 or 342245 end,
            cast = 0,
            cooldown = function () return talent.master_of_time.enabled and 30 or 60 end,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 609811,
            
            handler = function ()
                if buff.alter_time.down then
                    applyBuff( "alter_time" )
                else
                    removeBuff( "alter_time" )                   
                    if talent.master_of_time.enabled then setCooldown( "blink", 0 ) end
                end
            end,

            copy = 342247,
        },
        
        
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

                if azerite.wildfire.enabled then applyBuff( "wildfire" ) end
                if talent.rune_of_power.enabled then applyBuff( "rune_of_power" ) end
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

            usable = function () return target.within12, "target must be within 12 yds" end,
            
            handler = function ()
                hot_streak( talent.alexstraszas_fury.enabled )
                applyDebuff( "target", "dragons_breath" )
                if talent.alexstraszas_fury.enabled then applyBuff( "alexstraszas_fury" ) end
            end,
        },


        fire_blast = {
            id = 108853,
            cast = 0,
            charges = function () return ( talent.flame_on.enabled and 3 or 2 ) end,
            cooldown = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste end,
            recharge = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste end,
            icd = 0.5,
            gcd = "off",
            castableWhileCasting = true,

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135807,

            usable = function ()
                if time == 0 then return false, "no fire_blast out of combat" end
            end,

            handler = function ()
                hot_streak( true )

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                if azerite.blaster_master.enabled then addStack( "blaster_master", nil, 1 ) end
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
            

            impact = function ()
                if hot_streak( firestarter.active or stat.crit + buff.fireball.stack * 10 >= 100 ) then
                    removeBuff( "fireball" )
                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    addStack( "fireball", nil, 1 )
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
                removeBuff( "alexstraszas_fury" )
            end,
        },


        focus_magic = {
            id = 321358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135754,

            talent = "focus_magic",
            
            usable = function () return active_dot.focus_magic == 0 and group, "can apply one in a group" end,
            handler = function ()
                applyBuff( "focus_magic" )
            end,
        },
        
        
        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = function () return talent.ice_ward.enabled and 30 or nil end,
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

            startsCombat = false,
            texture = 1033911,

            flightTime = 1,

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

            velocity = 50,

            impact = function ()
                if hot_streak( true ) and talent.kindling.enabled then
                    setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
                end
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
                if hot_streak( firestarter.active ) and talent.kindling.enabled then
                    setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
                end
                applyDebuff( "target", "ignite" )
                removeBuff( "alexstraszas_fury" )
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

            debuff = "dispellable_curse",
            handler = function ()
                removeDebuff( "player", "dispellable_curse" )
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

            talent = "ring_of_frost",

            handler = function ()                
            end,
        },


        rune_of_power = {
            id = 116011,
            cast = 1.5,
            cooldown = 45,
            gcd = "spell",

            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",

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

            spend = function () return 0.21 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135729,

            debuff = "stealable_magic",
            handler = function ()
                removeDebuff( "target", "stealable_magic" )
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


    spec:RegisterPack( "Fire", 20200926, [[d8upQcqieIhrvsDjLQqAtufFcHcAuIOoLiXQuQIELsjZcvYTqOQDr0Vuk1WuQ4yIKwMsv6zuLW0ePcxtKQ2gvjX3OkrzCiuuNJQK06qOq9orQiY8uQQ7Hk2NsLoivjcluPWdrOuteHcCrLQqSrek5JIuruJeHICsekKvkI8srQi1mfPI6Mkvb7uKYpfPIWqvQc1sfPIKNIQMQsrxLQevFLQer7vu)fLbJ0HPSyj9yctgrxgAZs8zemAQQtlSAQsKEnvPMnvUTI2Tk)wQHRGJlsLwUQEoOPt66kz7IW3vOgpcPZJk16rOY8vi7h4CQ5nZ8KMI5027o7DND8Q71RitDNu9YsVxK5vUhWm)Gj82iGz(ZMyMNyfpM5hmUDTrM3mZd71lWmVVQdqIXBVnHq9xvPONBdJ5YzA0N4TIUnmMITZ81v4uIrxUM5jnfZPT3D27o74v3RxrM6oP6LLo8ImVTu)(Z88XKyN59dss8Y1mpjcfzEVgqjwXJa6EWiGGK8Aa1x1biX4T3MqO(RQu0ZTHXC5mn6t8wr3ggtX2GK8AaLhhuCwXhq3RxHlaDV7S3DajbsYRbuITVDeqiXyqsEnGs8aQxoeb0sqWxzpoT4Ga6BQp(aQ6BhGQ2tavPgtKPnJmqaT0pG6mOs8qu0hjGA1Wfk3a6cAeqOeKKxdOepG6LpqAkcOUMqia0hjgdOPZlrqcOedE0MqjijVgqjEanDUBiEaQWGkG(y6UIhN4PqaT0pGsS7zDb1Opan5qIsUauY(igQaQF7ib0qb0s)aQbOLhH(a6EavSFavyqnfjijVgqjEaLyqaTQdbu7au80NBav9nfqh3lhjG(iC5uanoa1auF7jfgub09yU)U6mOcOXr8eSjkbj51akXdO7roR6qafQFiuav4JcVJJaG2hGAaAbhdOL(9gcOXbOQpcOEj2JtNbuTb0hjxceqh3V3U2iLzExavyEZmFO4eYC9y2Wh9hk35nZPLAEZmpEw1HK5nY8MqJ(Y8AqIqT)jt0KirZ8Ipu8dlZNW(WQouQXezAZe9SUGA0hGUlGMW(WQou2hBbrMyPDPK5pBIzEnirO2)KjAsKOznN2EZBM5XZQoKmVrM3eA0xMxWTW163xiyvNb1mV4df)WY8jSpSQdLAmrM2mrpRlOg9bO7cOjSpSQdL9XwqKjwAxkzESuqHYoBIzEb3cxRFFHGvDguZAwZ8IEwxqn6Jn4BqmVzoTuZBM5XZQoKmVrMx8HIFyz(6QuKIEwxqn6ts2JVmVj0OVmVli4RqMx6IKWepnR502BEZmpEw1HK5nY8Ipu8dlZxxLIu0Z6cQrFsYE8L5nHg9L5Rgbwxy6hcVHznNMxK3mZJNvDizEJmV4df)WY8MqJeidpCgieq3fqtfq9aO1vPif9SUGA0NKShFzEtOrFzExKiocSApRznNw6iVzM3eA0xMV66MK1fM6Jm8Wj3zE8SQdjZBK1CAPpVzM3eA0xMFIZ(5M1fMBjcsg5J2eM5XZQoKmVrwZP5vYBM5nHg9L5h3VJmbgh7ryF2jWmpEw1HK5nYAonVS8MzE8SQdjZBK5xqKn2pCityqnoc50snZl(qXpSmVW3Ecieq3LdGMkG6bqtgqtgqnHg9jlXJSQZGQu4BpbeYkVj0OpZbOBbOjdO1vPif9SUGA0N8XPfheqjEaTUkfz1zqfF20Gk(sY1BA0hGMcGUhfqfD7i7XNSepYQodQsY1BA0hGs8aAYaADvksrpRlOg9jFCAXbb0ua09OaAYaADvkYQZGk(SPbv8LKR30OpaL4b0DKPhqtbqtbq3LdGUdGoAeGsea1io8dfLvNbv8ztdQ4lXZQoKeqhncqjcGQMdpvwC2ez9jXZQoKeqhncqRRsrk6zDb1Op5JtloiGUphaTUkfz1zqfF20Gk(sY1BA0hGoAeGwxLIS6mOIpBAqfF5JtloiGUpGUJm9a6OrakMURyyajL(CpGV6)OrYg)buh)2aeq9aOIUDK94t6Z9a(Q)JgjB8hqD8BdqMxSZoPMo2R8XPfheq3hqtpGMcG6bqRRsrk6zDb1Op5Aaq9aOjdOebqnHg9jHI(f(sKOOyPXraq9aOebqnHg9jh4(7QZGQmowXfe8va1dGwxLI0hnnocS1GCnaOJgbOMqJ(Kqr)cFjsuuS04iaOEa06QuK(TYG6JM3sYE8bOEa0Kb06QuK(OPXrGTgKK94dqhncqnId)qrz1zqfF20Gk(s8SQdjb0ua0rJauJ4WpuuwDguXNnnOIVepR6qsa1dGQMdpvwC2ez9jXZQoKeq9aOMqJ(KdC)D1zqvghR4cc(kG6bqRRsr6JMghb2Aqs2Jpa1dGwxLI0VvguF08ws2JpanLm)cISUuyeeK50snZBcn6lZxIhzvNb1SMtJyoVzMhpR6qY8gzEXhk(HL5RRsr(RdzDHn0JXxs2Jpa1dGwxLIu0Z6cQrFsYE8L5nHg9L5)1HSUWg6X4N1CAE18MzE8SQdjZBK5xqKn2pCityqnoc50snZBcn6lZxIhzvNb1mV4df)WY8gXHFOOS6mOIpBAqfFjEw1HKaQhanzafHq8eOCIZ(5M1fMBjcsg5J2ekNMxA)a6OrakrauecXtGYjo7NBwxyULiizKpAtOCgx)aAkaQhavnhEQCIk2VepR6qsa1dGQMdpvwC2ez9jXZQoKeq9aO1vPiRodQ4ZMguXxs2Jpa1dGMmGQMdpv(RdzDHn0JXxINvDijG6bqnHg9j)1HSUWg6X4lrIIILghba1dGAcn6t(RdzDHn0JXxIefflfzpoT4Ga6(a6osVcGoAeGMmGMW(WQouQXezAZe9SUGA0hGUphaDhaD0iaTUkfPON1fuJ(KRbanfa1dGseavnhEQ8xhY6cBOhJVepR6qsa1dGsea1eA0NCG7VRodQY4yfxqWxbupakrautOrFYs8y1CozCSIli4RaAkznNwQ7K3mZJNvDizEJmVj0OVmVWCoMj0OpMlGAM3fqLD2eZ8MqJeitnhEkmR50sn18MzE8SQdjZBK5xqKn2pCityqnoc50snZl(qXpSmFYaAYaQj0Op5evSFzCSIli4RaQha1eA0NCIk2VmowXfe8v2JtloiGUphaDhz6b0ua0rJautOrFYjQy)Y4yfxqWxb0rJauecXtGYjo7NBwxyULiizKpAtOCAEP9dOJgbO1vPi9BLb1hnVLpAcfqhncqnHg9jHI(f(sKOOyPXraq9aOMqJ(Kqr)cFjsuuSuK940IdcO7dO7itpGoAeGAcn6toW93vNbvjsuuS04iaOEautOrFYbU)U6mOkrIIILIShNwCqaDFaDhz6b0uaupaAYaADvkYFDiRlSHEm(Y1aGoAeGseavnhEQ8xhY6cBOhJVepR6qsanLm)cISUuyeeK50snZBcn6lZl6zDb1OVSMtl19M3mZBcn6lZp0A0xMhpR6qY8gznNwQErEZmVj0OVmF11njRSEUZ84zvhsM3iR50snDK3mZBcn6lZxXhIV3XriZJNvDizEJSMtl10N3mZBcn6lZxIhRUUjZ84zvhsM3iR50s1RK3mZBcn6lZBNaH6BoMWCUmpEw1HK5nYAoTu9YYBM5XZQoKmVrMx8HIFyz(Kb0Kbu1C4PYIZMiBWuHVepR6qsa1dGAcnsGm8WzGqaDxaDVaAka6OraQj0ibYWdNbcb0DbuVcGMcG6bqRRsr63kdQpAElF0ekG6bqjcGAeh(HIYQZGk(SPbv8L4zvhsM5nHg9L5loBIq9dVXSMtlvI58MzE8SQdjZBK5fFO4hwMVUkf5a3FlCgCkF0ekG6bqRRsrk6zDb1Op5JtloiGUlGkmOY0yIzEtOrFz(bU)U6mOM1CAP6vZBM5XZQoKmVrMx8HIFyz(6QuK(TYG6JM3YhnHM5nHg9L5h4(7QZGAwZPT3DYBM5nHg9L5h8B8cIYkoBIWmpEw1HK5nYAoT9MAEZmpEw1HK5nY8Ipu8dlZxxLIu0Z6cQrFYhNwCqaDxavyqLPXebupaADvksrpRlOg9jxda6OraADvksrpRlOg9jj7XhG6bqfD7i7XNu0Z6cQrFYhNwCqaDFavyqLPXeZ8MqJ(Y8qr)c)SMtBV7nVzMhpR6qY8gzEXhk(HL5RRsrk6zDb1Op5JtloiGUpGsqqkNgrbupaQj0ibYWdNbcb0Db0uZ8MqJ(Y8UirCey1EwZAoT96f5nZ84zvhsM3iZl(qXpSmFDvksrpRlOg9jFCAXbb09buccs50ikG6bqRRsrk6zDb1Op5AiZBcn6lZt(gH(GS6JM6N1CA7nDK3mZJNvDizEJmV4df)WY8Q9eqv6JMt9Ldcfq3NdG6f7aOEau1C4PsiAFCeyAVe(s8SQdjZ8MqJ(Y8qr)c)SM1mVj0ibYuZHNcZBMtl18MzE8SQdjZBK5fFO4hwM3eAKaz4HZaHa6UaAQaQhaTUkfPON1fuJ(KK94dq9aOjdOjSpSQdLAmrM2mrpRlOg9bO7cOIUDK94t6IeXrGv7zvsUEtJ(a0rJa0e2hw1HsnMitBMON1fuJ(a095aO7aOPK5nHg9L5DrI4iWQ9SM1CA7nVzMhpR6qY8gzEXhk(HL5tyFyvhk1yImTzIEwxqn6dq3NdGUdGoAeGMmGwxLI8xhY6cBOhJVCnaOJgbOIUDK94t(RdzDHn0JXx(40IdcO7cOAmrM2mYabupaQj0Op5VoK1f2qpgFPW3Ecieq3hqtfqhncqjcGQMdpv(RdzDHn0JXxINvDijGMcG6bqtgqfD7i7XNCIk2VKC9Mg9bO7dOjSpSQdLAmrM2mrpRlOg9bOJgbOAmrM2mYab09b0e2hw1HsnMitBMON1fuJ(a0uY8MqJ(Y8tuX(ZAonViVzMhpR6qY8gzEXhk(HL5vZHNknhsuO(gK4miRSEUL4zvhscOEa0Kb06QuKIEwxqn6ts2Jpa1dGseaTUkfPFRmO(O5T8rtOa6OraADvksrpRlOg9jxdaQha1eA0NSepYQodQsHV9eqiGUpGAcn6twIhzvNbv50ikt4BpbecOEauIaO1vPi9BLb1hnVLpAcfqtjZBcn6lZt(gH(GS6JM6N1SM5dfNqMFqWNn8r)HYDEZCAPM3mZJNvDizEJmV4df)WY8jSpSQdLAmrM2mrpRlOg9bO7Zbq3jZBcn6lZlmNJzcn6J5cOM5DbuzNnXmFO4eYe9SUGA0xwZPT38MzEtOrFz(fezHItyMhpR6qY8gznNMxK3mZJNvDizEJmVj0OVm)0UOGqTzDHnnYdHWmV4df)WY8ebqX0DfddiP0ioOV9gKv6tzDHn0JXhq9aOjSpSQdLAmrM2mrpRlOg9bO7dOeZz(ZMyMFAxuqO2SUWMg5HqywZPLoYBM5XZQoKmVrM3eA0xM3ioOV9gKv6tzDHn0JXpZl(qXpSmFc7dR6qPgtKPnt0Z6cQrFa6(Ca00dOBbOPMEaDpb0e2hw1HYsFkJSxvhY6JTGyM)SjM5nId6BVbzL(uwxyd9y8ZAoT0N3mZJNvDizEJmVj0OVm)3Q4xqfjzj6MSBgz7CzEXhk(HL5tyFyvhk1yImTzIEwxqn6dq3fqtyFyvhk7JTGitS0UuY8NnXm)3Q4xqfjzj6MSBgz7CznNMxjVzMhpR6qY8gzEtOrFzElDxXqR4PSZwA4wWmV4df)WY8jSpSQdLAmrM2mrpRlOg9bO7cOjSpSQdL9XwqKjwAxkz(ZMyM3s3vm0kEk7SLgUfmR508YYBM5XZQoKmVrM3eA0xMh6hjWNLaVEYE0fImV4df)WY8jSpSQdLAmrM2mrpRlOg9bO7cOjSpSQdL9XwqKjwAxkz(ZMyMh6hjWNLaVEYE0fISMtJyoVzMhpR6qY8gzEtOrFz(s)1GKepwxHbzyht4SXzEXhk(HL5tyFyvhk1yImTzIEwxqn6dq3fqtyFyvhk7JTGitS0UuY8NnXmFP)AqsIhRRWGmSJjC24SMtZRM3mZJNvDizEJmVj0OVmVV9Z(cbJeNMIFyUG4WpZJLcku2ztmZ7B)SVqWiXPP4hMlio8ZAoTu3jVzMhpR6qY8gzEtOrFz(P5k9prsMp(MJeYCiHXVnaZ8Ipu8dlZNW(WQouQXezAZe9SUGA0hGUlhan9Phq9aO1vPif9SUGA0NKShFaQhanH9HvDOuJjY0Mj6zDb1OpaDxanH9HvDOSp2cImXs7sjZF2eZ8tZv6FIKmF8nhjK5qcJFBaM1CAPMAEZmpEw1HK5nY8MqJ(Y82jc8uM3xRSUWghqYEM5fFO4hwMpH9HvDOuJjY0Mj6zDb1OpaDxoaA6tpG6bqRRsrk6zDb1Opjzp(aupaAc7dR6qPgtKPnt0Z6cQrFa6UaAc7dR6qzFSfezIL2LsM)SjM5Tte4PmVVwzDHnoGK9mR50sDV5nZ84zvhsM3iZBcn6lZF46nhdY9zdqKHNVDc8Z8Ipu8dlZNW(WQouQXezAZe9SUGA0hGUlhanDKEa1dGwxLIu0Z6cQrFsYE8bOEa0e2hw1HsnMitBMON1fuJ(a0Db0e2hw1HY(yliYelTlLm)ztmZF46nhdY9zdqKHNVDc8ZAwZ8KyXwonVzoTuZBM5nHg9L5f96u8HdOZL5XZQoKmVrwZPT38MzE8SQdjZBK57Hmpe1mVj0OVmFc7dR6WmFcZTWmVAo8uzjEeQ2R4lXZQoKeq3taTepcv7v8LpoT4Ga6waAYaQOBhzp(KIEwxqn6t(40IdcO7jGMmGMkGs8aAc7dR6qP3Xr6IJa7rYLqJ(a09eqvZHNk9oosxCeK4zvhscOPaOepGAcn6t(RdzDHn0JXxIefflfzAmraDpbu1C4PYFDiRlSHEm(s8SQdjb0ua09eqjcGk62r2JpPON1fuJ(KpAKCdO7jGwxLIu0Z6cQrFsYE8L5typ7SjM51yImTzIEwxqn6lR508I8MzE8SQdjZBK57Hm)0iAM3eA0xMpH9HvDyMpH5wyMx0TJShFYjo7NBwxyULiizKpAtO8XPfhmZl(qXpSmpcH4jq5eN9ZnRlm3seKmYhTjuonV0(bupaADvkYjo7NBwxyULiizKpAtOKShFaQhav0TJShFYjo7NBwxyULiizKpAtO8XPfheqjEanH9HvDOuJjY0Mj6zDb1OpaDFoaAc7dR6qPF7izIEwxqn6JP(pc9BhzMpH9SZMyMxJjY0Mj6zDb1OVSMtlDK3mZJNvDizEJmFpK5NgrZ8MqJ(Y8jSpSQdZ8jm3cZ8IUDK94toUFhzcmo2JW(StGYhNwCWmV4df)WY8ieINaLJ73rMaJJ9iSp7eOCAEP9dOEa06QuKJ73rMaJJ9iSp7eOKShFaQhav0TJShFYX97itGXXEe2NDcu(40IdcOepGMW(WQouQXezAZe9SUGA0hGUphanH9HvDO0VDKmrpRlOg9Xu)hH(TJmZNWE2ztmZRXezAZe9SUGA0xwZPL(8MzE8SQdjZBK5nHg9L5fMZXmHg9XCbuZ8UaQSZMyMpuCcz(bbF2Wh9hk3znNMxjVzMhpR6qY8gzEXhk(HL5RRsrk6zDb1Opjzp(Y8MqJ(Y8Z4)(zX0iGznNMxwEZmpEw1HK5nY8Ipu8dlZNmGMW(WQouQXezAZe9SUGA0hGUpGM6oa6OraQgtKPnJmqaDFanH9HvDOuJjY0Mj6zDb1OpanLmVj0OVmpHL9KHDSUWmId)w9ZAonI58MzEtOrFzErFc803uKKvC2eZ84zvhsM3iR508Q5nZ8MqJ(Y8pAdXrGvC2eHzE8SQdjZBK1CAPUtEZmVj0OVmFPflisYmId)qrwfTzMhpR6qY8gznNwQPM3mZBcn6lZpS(OWDCeyvNb1mpEw1HK5nYAoTu3BEZmVj0OVm)hddoKfhdoycmZJNvDizEJSMtlvViVzM3eA0xMx9r26Q96izL(fyMhpR6qY8gznNwQPJ8MzE8SQdjZBK5fFO4hwMVUkf5VoK1f2qpgFjzp(aupaADvksrpRlOg9jj7XhG6bqtgqtyFyvhk1yImTzIEwxqn6dq3fqllNJ9OW3EcitJjcOJgbOjSpSQdLAmrM2mrpRlOg9bO7cOLGGVYECAXbb0uY8MqJ(Y8)6qwxyd9y8ZAoTutFEZmpEw1HK5nY8Ipu8dlZNW(WQouQXezAZe9SUGA0hGUphaDNmVj0OVmVWCoMj0OpMlGAM3fqLD2eZ8IEwxqn6Jn4BqmR50s1RK3mZJNvDizEJm)cISX(HdzcdQXriNwQzEXhk(HL5tgqriepbkN4SFUzDH5wIGKr(OnHYP5L2pGoAeGIqiEcuoXz)CZ6cZTebjJ8rBcLZ46hq9aOgXHFOOS6mOIpBAqfFjEw1HKaAkaQhav4BpbecOCa0PruMW3Ecieq9aOebqRRsr63kdQpAElF0ekG6bqjcGMmGwxLI0hnnocS1G8rtOaQhanzaTUkfPON1fuJ(KRba1dGMmGAcn6twIhRMZjJJvCbbFfqhncqnHg9jh4(7QZGQmowXfe8vaD0ia1eA0Nek6x4lrIIILghbanfaD0iavTNaQsF0CQVCqOa6(CauVyha1dGAcn6tcf9l8LirrXsJJaGMcGMcG6bqjcGMmGseaTUkfPpAACeyRb5JMqbupakra06QuK(TYG6JM3YhnHcOEa06QuKIEwxqn6ts2Jpa1dGMmGAcn6twIhRMZjJJvCbbFfqhncqnHg9jh4(7QZGQmowXfe8vanfanLm)cISUuyeeK50snZBcn6lZxIhzvNb1SMtlvVS8MzE8SQdjZBK57Hmpe1mVj0OVmFc7dR6WmFcZTWmVAo8u5VoK1f2qpgFjEw1HKaQhav0TJShFYFDiRlSHEm(YhNwCqaDFav0TJShFYs8iR6mOkllNJ9OW3EcitJjcOEa0Kb0e2hw1HsnMitBMON1fuJ(a0DbutOrFYFDiRlSHEm(YYY5ypk8TNaY0yIaAkaQhanzav0TJShFYFDiRlSHEm(YhNwCqaDFavJjY0MrgiGoAeGAcn6t(RdzDHn0JXxk8TNacb0Db0Da0ua0rJa0e2hw1HsnMitBMON1fuJ(a09butOrFYs8iR6mOkllNJ9OW3EcitJjcOEa0e2hw1HsnMitBMON1fuJ(a09bunMitBgzGz(e2ZoBIz(s8iR6mOYg62fhHSMtlvI58MzE8SQdjZBK5fFO4hwMVUkf5VoK1f2qpgF5Aaq9aOjdOjSpSQdLAmrM2mrpRlOg9bO7cO7aOPK5H6hcnNwQzEtOrFzEH5CmtOrFmxa1mVlGk7SjM5)EGn4BqmR50s1RM3mZJNvDizEJmFpK5HOM5nHg9L5tyFyvhM5tyUfM5vZHNk)1HSUWg6X4lXZQoKeq9aOIUDK94t(RdzDHn0JXx(40IdcO7dOIUDK94to434feLvC2eHYYY5ypk8TNaY0yIaQhanzanH9HvDOuJjY0Mj6zDb1OpaDxa1eA0N8xhY6cBOhJVSSCo2JcF7jGmnMiGMcG6bqtgqfD7i7XN8xhY6cBOhJV8XPfheq3hq1yImTzKbcOJgbOMqJ(K)6qwxyd9y8LcF7jGqaDxaDhanfaD0ianH9HvDOuJjY0Mj6zDb1OpaDFa1eA0NCWVXlikR4SjcLLLZXEu4BpbKPXebupaAc7dR6qPgtKPnt0Z6cQrFa6(aQgtKPnJmWmFc7zNnXm)GFJxqu2q3U4iK1CA7DN8MzE8SQdjZBK5xqKn2pCityqnoc50snZl(qXpSmFYakra0e2hw1HYs8iR6mOYg62fhbaD0iaTUkf5VoK1f2qpgF5Aaqtbq9aOjdOjSpSQdLAmrM2mrpRlOg9bO7cO7aOPaOEa0KbutOrcKHhodecO7YbqtyFyvhk9TNKjmOYkoBIq9dVra1dGMmGQXebuIhqRRsrk6zDb1OpPZGkdj6q8iGUlGMW(WQousIoJBwXzteQF4ncOPaOPaOEauIaOL4rOAVIV0eAKabupaADvks)wzq9rZBjzp(aupaAYakrauJ4WpuuwDguXNnnOIVepR6qsaD0iaTUkfz1zqfF20Gk(YhNwCqaDFaDhz6b0uY8liY6sHrqqMtl1mVj0OVmFjEKvDguZAoT9MAEZmpEw1HK5nY8liYg7hoKjmOghHCAPM5fFO4hwMVepcv7v8LMqJeiG6bqf(2taHa6UCa0ubupaAYakra0e2hw1HYs8iR6mOYg62fhbaD0iaTUkf5VoK1f2qpgF5Aaqtbq9aOjdOebqnId)qrz1zqfF20Gk(s8SQdjb0rJa06QuKvNbv8ztdQ4lFCAXbb09b0DKPhqtbq9aOjdOebqnHg9jlXJvZ5KirrXsJJaG6bqjcGAcn6toW93vNbvzCSIli4RaQhaTUkfPpAACeyRb5AaqhncqnHg9jlXJvZ5KirrXsJJaG6bqRRsr63kdQpAElj7XhGoAeGAcn6toW93vNbvzCSIli4RaQhaTUkfPpAACeyRbjzp(aupaADvks)wzq9rZBjzp(a0uY8liY6sHrqqMtl1mVj0OVmFjEKvDguZAoT9U38MzE8SQdjZBK5fFO4hwMpH9HvDOuJjY0Mj6zDb1OpaDxaDNmpu)qO50snZBcn6lZlmNJzcn6J5cOM5DbuzNnXmpuTJ0Es23QPrFznRz(qXjKj6zDb1OV8M50snVzMhpR6qY8gz(ZMyMpiCHg9XMgbeYkliM5nHg9L5dcxOrFSPraHSYcIznN2EZBM5XZQoKmVrM3eA0xM3N7b8v)hns24pG643gGzEXhk(HL5RRsrk6zDb1Op5Aaq9aOMqJ(KL4rw1zqvk8TNacbuoa6oaQha1eA0NSepYQodQYhf(2tazAmraDxaLGGuonIM5pBIzEFUhWx9F0izJ)aQJFBaM1CAErEZmpEw1HK5nY8NnXm)0UOGqTzDHnnYdHWmVj0OVm)0UOGqTzDHnnYdHWSMtlDK3mZxxLc7SjM5N2ffeQnRlSPrEieYe(2GIpRpmZl(qXpSmFDvksrpRlOg9jxda6OraQj0Op5evSFzCSIli4RaQha1eA0NCIk2VmowXfe8v2JtloiGUphaDhz6Z8liY6sHrqqMtl1mVj0OVmVWob6y1vPK5XZQoKmVrwZPL(8MzE8SQdjZBK5pBIzEJ4wpQ(nKbJJasYgCRPraZ8liY6sHrqqMtl1mVj0OVmVrCRhv)gYGXrajzdU10iGzEXhk(HL5RRsrk6zDb1Op5AaqhncqnHg9jNOI9lJJvCbbFfq9aOMqJ(KtuX(LXXkUGGVYECAXbb095aO7itFwZP5vYBM5XZQoKmVrM3eA0xMNGZidt7hYQgjbmZVGiRlfgbbzoTuZ8Ipu8dlZxxLIu0Z6cQrFY1aGoAeGAcn6torf7xghR4cc(kG6bqnHg9jNOI9lJJvCbbFL940IdcO7Zbq3rM(mpwkOqzNnXmpbNrgM2pKvnscywZP5LL3mZJNvDizEJmVj0OVmpbNrgM2pKnrsZ5I(Y8liY6sHrqqMtl1mV4df)WY81vPif9SUGA0NCnaOJgbOMqJ(KtuX(LXXkUGGVcOEautOrFYjQy)Y4yfxqWxzpoT4Ga6(Ca0DKPpZJLcku2ztmZtWzKHP9dztK0CUOVSMtJyoVzMhpR6qY8gz(ZMyMVAoSepYQVDc)m)cISUuyeeK50snZBcn6lZxnhwIhz13oHFMx8HIFyz(6QuKIEwxqn6tUga0rJautOrFYjQy)Y4yfxqWxbupaQj0Op5evSFzCSIli4RShNwCqaDFoa6oY0N1CAE18MzE8SQdjZBK5pBIzEOFl8Ugk(qwXocz(fezDPWiiiZPLAM3eA0xMh63cVRHIpKvSJqMx8HIFyz(6QuKIEwxqn6tUga0rJautOrFYjQy)Y4yfxqWxbupaQj0Op5evSFzCSIli4RShNwCqaDFoa6oY0N1CAPUtEZmpEw1HK5nY8NnXmVsC2Hqw1EVHdXHWm)cISUuyeeK50snZBcn6lZReNDiKvT3B4qCimZl(qXpSmFDvksrpRlOg9jxda6OraQj0Op5evSFzCSIli4RaQha1eA0NCIk2VmowXfe8v2JtloiGUphaDhz6ZAoTutnVzMhpR6qY8gz(ZMyM3orGNY8(AL1f24as2Zm)cISUuyeeK50snZBcn6lZBNiWtzEFTY6cBCaj7zMx8HIFyz(6QuKIEwxqn6tUga0rJautOrFYjQy)Y4yfxqWxbupaQj0Op5evSFzCSIli4RShNwCqaDFoa6oY0N1CAPU38MzE8SQdjZBK5pBIz(dxV5yqUpBaIm88TtGFMFbrwxkmccYCAPM5nHg9L5pC9MJb5(SbiYWZ3ob(zEXhk(HL5RRsrk6zDb1Op5AaqhncqnHg9jNOI9lJJvCbbFfq9aOMqJ(KtuX(LXXkUGGVYECAXbb095aO7itFwZPLQxK3mZJNvDizEJm)ztmZpnxP)jsY8X3CKqMdjm(TbyMFbrwxkmccYCAPM5nHg9L5NMR0)ejz(4BosiZHeg)2amZl(qXpSmFDvksrpRlOg9jxda6OraQj0Op5evSFzCSIli4RaQha1eA0NCIk2VmowXfe8v2JtloiGUphaDhz6ZAwZ8dpk6z108M50snVzM3eA0xM3EHDilofDouOzE8SQdjZBK1CA7nVzMhpR6qY8gz(EiZdrnZBcn6lZNW(WQomZNWClmZJP7kggqs50UOGqTzDHnnYdHqaD0iaft3vmmGKscoJmmTFiRAKeqaD0iaft3vmmGKscoJmmTFiBIKMZf9bOJgbOy6UIHbKugeUqJ(ytJaczLfeb0rJaumDxXWaskvIZoeYQ27nCioecOJgbOy6UIHbKuAe36r1VHmyCeqs2GBnnciGoAeGIP7kggqsPDIapL591kRlSXbKSNa6OrakMURyyajLq)w4Dnu8HSIDea0rJaumDxXWaskpC9MJb5(SbiYWZ3ob(a6OrakMURyyajLvZHL4rw9Tt4N5typ7SjM5f9SUGA0hRp2cIznNMxK3mZJNvDizEJmFpK5HOM5nHg9L5tyFyvhM5tyUfM5X0DfddiP0ioOV9gKv6tzDHn0JXhq9aOjSpSQdLIEwxqn6J1hBbXmFc7zNnXmFPpLr2RQdz9XwqmR50sh5nZ84zvhsM3iZ3dzEiQzEtOrFz(e2hw1Hz(eMBHz(9UdGUNaAYaAc7dR6qPON1fuJ(y9Xwqeq9aOebqtyFyvhkl9PmYEvDiRp2cIaAka6waA6yhaDpb0Kb0e2hw1HYsFkJSxvhY6JTGiGMcGUfGU30dO7jGMmGIP7kggqsPrCqF7niR0NY6cBOhJpG6bqjcGMW(WQouw6tzK9Q6qwFSfeb0ua0TauIzaDpb0KbumDxXWaskN2ffeQnRlSPrEiecOEauIaOjSpSQdLL(ugzVQoK1hBbranLmFc7zNnXmFFSfezIL2LswZPL(8MzE8SQdjZBK57Hm)JquZ8MqJ(Y8jSpSQdZ8jSND2eZ8(TJKj6zDb1OpM6)i0VDKzEsSylNM537oznNMxjVzMhpR6qY8gz(EiZdrnZBcn6lZNW(WQomZNWClmZVxaDpbu1C4PYIZMiBWuHVepR6qsaDla1R6vb09eqjcGQMdpvwC2ezdMk8L4zvhsM5fFO4hwMpH9HvDO0VvguF08MvC2eH6hEJakhaDNmFc7zNnXmVFRmO(O5nR4Sjc1p8gZAonVS8MzE8SQdjZBK57Hmpe1mVj0OVmFc7dR6WmFcZTWmVxaO7jGQMdpvwC2ezdMk8L4zvhscOBbOEvVkGUNakrau1C4PYIZMiBWuHVepR6qYmV4df)WY8jSpSQdL(2tYeguzfNnrO(H3iGYbq3jZNWE2ztmZ7BpjtyqLvC2eH6hEJznNgXCEZmpEw1HK5nY89qM)riQzEtOrFz(e2hw1Hz(e2ZoBIzEs0zCZkoBIq9dVXmpjwSLtZ87n9znNMxnVzMhpR6qY8gz(EiZ)ie1mVj0OVmFc7dR6WmFc7zNnXmV3Xr6IJa7rYLqJ(Y8KyXwonZVJCVznNwQ7K3mZJNvDizEJm)ztmZBeh03EdYk9PSUWg6X4N5nHg9L5nId6BVbzL(uwxyd9y8ZAoTutnVzM3eA0xMFg)3plMgbmZJNvDizEJSMtl19M3mZBcn6lZp0A0xMhpR6qY8gznNwQErEZmVj0OVm)a3FxDguZ84zvhsM3iRznZdv7iTNK9TAA0xEZCAPM3mZJNvDizEJmV4df)WY8jdOMqJeidpCgieq3LdGMW(WQou63kdQpAEZkoBIq9dVra1dGMmGQXebuIhqRRsrk6zDb1OpPZGkdj6q8iGUlGMW(WQousIoJBwXzteQF4ncOPaOPaOEa06QuK(TYG6JM3YhnHM5nHg9L5loBIq9dVXSMtBV5nZ84zvhsM3iZl(qXpSmFDvks)wzq9rZB5JMqbupaADvks)wzq9rZB5JtloiGUpGAcn6twIhRMZjrIIILImnMyM3eA0xMFG7VRodQznNMxK3mZJNvDizEJmV4df)WY81vPi9BLb1hnVLpAcfq9aOjdOdpMGrqqktvwIhRMZbOJgbOL4rOAVIV0eAKab0rJautOrFYbU)U6mOkJJvCbbFfqtjZBcn6lZpW93vNb1SMtlDK3mZJNvDizEJmV4df)WY8cF7jGqaDxoaQxaOEautOrcKHhodecO7cO7fq9aOebqtyFyvhkh8B8cIYg62fhHmVj0OVm)GFJxquwXzteM1CAPpVzMhpR6qY8gzEXhk(HL5RRsr63kdQpAElF0ekG6bqv7jGQ0hnN6lhekGUpha1l2bq9aOQ5WtLq0(4iW0Ej8L4zvhsM5nHg9L5h4(7QZGAwZP5vYBM5XZQoKmVrMx8HIFyz(6QuKdC)TWzWP8rtOaQhavyqLPXeb09b06QuKdC)TWzWP8XPfhmZBcn6lZpW93vNb1SMtZllVzMhpR6qY8gz(fezJ9dhYeguJJqoTuZ8Ipu8dlZNmGwxLI8xhY6cBOhJVKShFaQhaLiaAjEeQ2R4lnHgjqanfa1dGseanH9HvDOSepYQodQSHUDXraq9aOjdOjdOjdOMqJ(KL4XQ5CsKOOyPXraqhncqnHg9jh4(7QZGQejkkwACea0uaupaADvksF004iWwdYhnHcOPaOJgbOjdOQ5WtLq0(4iW0Ej8L4zvhscOEau1EcOk9rZP(YbHcO7Zbq9IDaupaAYaADvksF004iWwdYhnHcOEauIaOMqJ(Kqr)cFjsuuS04iaOJgbOebqRRsr63kdQpAElF0ekG6bqjcGwxLI0hnnocS1G8rtOaQha1eA0Nek6x4lrIIILghba1dGsea1eA0NCG7VRodQY4yfxqWxbupakrautOrFYs8y1CozCSIli4RaAkaAkaAkz(fezDPWiiiZPLAM3eA0xMVepYQodQznNgXCEZmpEw1HK5nY8Ipu8dlZp8ycgbbPmvju0VWhq9aO1vPi9rtJJaBnixdaQhavnhEQeI2hhbM2lHVepR6qsa1dGQ2tavPpAo1xoiuaDFoaQxSdG6bqjcGMmGAcnsGm8WzGqaDxoaAc7dR6qPFRmO(O5nR4Sjc1p8gbupaAYaQgteqjEaTUkfPON1fuJ(KodQmKOdXJa6UaAc7dR6qjj6mUzfNnrO(H3iGMcGMsM3eA0xMFG7VRodQznNMxnVzMhpR6qY8gzEXhk(HL5tgqRRsr6JMghb2Aq(OjuaD0ianzaLiaADvks)wzq9rZB5JMqbupaAYaQj0OpzjEKvDguLcF7jGqaDxaDhaD0iavnhEQeI2hhbM2lHVepR6qsa1dGQ2tavPpAo1xoiuaDFoaQxSdGMcGMcGMcG6bqjcGMW(WQouo434feLn0TloczEtOrFz(b)gVGOSIZMimR50sDN8MzE8SQdjZBK5nHg9L5fMZXmHg9XCbuZ8UaQSZMyM3eAKazQ5WtHznNwQPM3mZJNvDizEJmV4df)WY8MqJeidpCgieq3fqtnZBcn6lZt(gH(GS6JM6N1CAPU38MzE8SQdjZBK5nHg9L5fMZXmHg9XCbuZ8UaQSZMyMpuCczUEmB4J(dL7SMtlvViVzMhpR6qY8gzEXhk(HL5v7jGQ0hnN6lhekGUpha1l2bq9aOQ5WtLq0(4iW0Ej8L4zvhsM5nHg9L5HI(f(znNwQPJ8MzE8SQdjZBK5fFO4hwM3eAKaz4HZaHa6UCa0e2hw1HsF7jzcdQSIZMiu)WBeq9aOjdOAmraL4b06QuKIEwxqn6t6mOYqIoepcO7cOjSpSQdLKOZ4MvC2eH6hEJaAkzEtOrFz(IZMiu)WBmR50sn95nZ8MqJ(Y8L4XQ5CzE8SQdjZBK1CAP6vYBM5nHg9L5HI(f(zE8SQdjZBK1SM5)EGn4BqmVzoTuZBM5XZQoKmVrMx8HIFyz(KbutOrcKHhodecO7YbqtyFyvhk9BLb1hnVzfNnrO(H3iG6bqtgq1yIakXdO1vPif9SUGA0N0zqLHeDiEeq3fqtyFyvhkjrNXnR4Sjc1p8gb0ua0uaupaADvks)wzq9rZB5JMqZ8MqJ(Y8fNnrO(H3ywZPT38MzE8SQdjZBK5fFO4hwMVUkfPFRmO(O5T8rtOzEtOrFz(bU)U6mOM1CAErEZmpEw1HK5nY8liYg7hoKjmOghHCAPM5fFO4hwMNiaAYaQj0ibYWdNbcb0D5aOjSpSQdL(2tYeguzfNnrO(H3iG6bqtgq1yIakXdO1vPif9SUGA0N0zqLHeDiEeq3fqtyFyvhkjrNXnR4Sjc1p8gb0ua0uaupakra0s8iuTxXxAcnsGaQhanzaLiaADvksF004iWwdYhnHcOEauIaO1vPi9BLb1hnVLpAcfq9aOebqhEmbRlfgbbPSepYQodQaQhanza1eA0NSepYQodQsHV9eqiGUlhaDVa6OraAYaQj0Op5GFJxquwXztekf(2taHa6UCa0ubupaQAo8u5GFJxquwXztekXZQoKeqtbqhncqtgqvZHNknhsuO(gK4miRSEUL4zvhscOEaur3oYE8jjFJqFqw9rt9LpAKCdOPaOJgbOjdOQ5WtLq0(4iW0Ej8L4zvhscOEau1EcOk9rZP(YbHcO7Zbq9IDa0ua0ua0uY8liY6sHrqqMtl1mVj0OVmFjEKvDguZAoT0rEZmpEw1HK5nY8MqJ(Y8cZ5yMqJ(yUaQzExav2ztmZBcnsGm1C4PWSMtl95nZ84zvhsM3iZl(qXpSmFDvkYbU)w4m4u(Ojua1dGkmOY0yIa6(aADvkYbU)w4m4u(40IdcOEa06QuK)6qwxyd9y8LpoT4Ga6UaQWGktJjM5nHg9L5h4(7QZGAwZP5vYBM5XZQoKmVrMFbr2y)WHmHb14iKtl1mV4df)WY8ebqtgqnHgjqgE4mqiGUlhanH9HvDO03EsMWGkR4Sjc1p8gbupaAYaQgteqjEaTUkfPON1fuJ(KodQmKOdXJa6UaAc7dR6qjj6mUzfNnrO(H3iGMcGMcG6bqjcGwIhHQ9k(stOrceq9aOjdO1vPi9rtJJaBniF0ekG6bqtgqv7jGQ0hnN6lhekGUlha1l2bqhncqjcGQMdpvcr7JJat7LWxINvDijGMcGMsMFbrwxkmccYCAPM5nHg9L5lXJSQZGAwZP5LL3mZJNvDizEJm)cISX(HdzcdQXriNwQzEXhk(HL5jcGMmGAcnsGm8WzGqaDxoaAc7dR6qPV9KmHbvwXzteQF4ncOEa0KbunMiGs8aADvksrpRlOg9jDguzirhIhb0Db0e2hw1Hss0zCZkoBIq9dVranfanfa1dGseaTepcv7v8LMqJeiG6bqvZHNkHO9XrGP9s4lXZQoKeq9aOQ9eqv6JMt9Ldcfq3NdG6f7aOEa0Kb06QuK(OPXrGTgKpAcfq9aOebqnHg9jHI(f(sKOOyPXraqhncqjcGwxLI0hnnocS1G8rtOaQhaLiaADvks)wzq9rZB5JMqb0uY8liY6sHrqqMtl1mVj0OVmFjEKvDguZAonI58MzE8SQdjZBK5fFO4hwMF4XemccszQsOOFHpG6bqRRsr6JMghb2AqUgaupaQAo8ujeTpocmTxcFjEw1HKaQhavTNaQsF0CQVCqOa6(CauVyha1dGseanza1eAKaz4HZaHa6UCa0e2hw1Hs)wzq9rZBwXzteQF4ncOEa0KbunMiGs8aADvksrpRlOg9jDguzirhIhb0Db0e2hw1Hss0zCZkoBIq9dVranfanLmVj0OVm)a3FxDguZAonVAEZmpEw1HK5nY8Ipu8dlZteaD4XemccszQYb)gVGOSIZMieq9aO1vPi9rtJJaBniF0eAM3eA0xMFWVXlikR4SjcZAoTu3jVzMhpR6qY8gzEXhk(HL5v7jGQ0hnN6lhekGUpha1l2bq9aOQ5WtLq0(4iW0Ej8L4zvhsM5nHg9L5HI(f(znNwQPM3mZJNvDizEJmV4df)WY8MqJeidpCgieq3fq3BM3eA0xMN8nc9bz1hn1pR50sDV5nZ84zvhsM3iZl(qXpSmFYaQj0ibYWdNbcb0D5aOjSpSQdL(2tYeguzfNnrO(H3iG6bqtgq1yIakXdO1vPif9SUGA0N0zqLHeDiEeq3fqtyFyvhkjrNXnR4Sjc1p8gb0ua0uY8MqJ(Y8fNnrO(H3ywZPLQxK3mZBcn6lZxIhRMZL5XZQoKmVrwZAwZ8jWhg9LtBV7S3D2XRKA6iZp2(locWmpXO5q)kscOEva1eA0hG6cOcLGKY8WbuKtZR4fz(HVlHdZ8EnGsSIhb09Grabj51aQVQdqIXBVnHq9xvPONBdJ5YzA0N4TIUnmMITbj51akpoO4SIpGUxVcxa6E3zV7ascKKxdOeBF7iGqIXGK8AaL4buVCicOLGGVYECAXbb03uF8bu13oavTNaQsnMitBgzGaAPFa1zqL4HOOpsa1QHluUb0f0iGqjijVgqjEa1lFG0ueqDnHqaOpsmgqtNxIGeqjg8OnHsqsEnGs8aA6C3q8auHbva9X0DfpoXtHaAPFaLy3Z6cQrFaAYHeLCbOK9rmubu)2rcOHcOL(budqlpc9b09aQy)aQWGAksqsEnGs8akXGaAvhcO2bO4Pp3aQ6BkGoUxosa9r4YPaACaQbO(2tkmOcO7XC)D1zqfqJJ4jytucsYRbuIhq3JCw1Haku)qOaQWhfEhhbaTpa1a0cogql97neqJdqvFeq9sShNodOAdOpsUeiGoUFVDTrkbjbsYRb09iefflfjb0kw6hburpRMcOvKqCqjG6LqiWbfcOxFeVV9ZYYbOMqJ(GaAFoULGK8Aa1eA0huo8OONvt5uCg0BqsEnGAcn6dkhEu0ZQPBXz7s3KGK8Aa1eA0huo8OONvt3IZ22IWep10OpqsMqJ(GYHhf9SA6wC22EHDilofDouOGKmHg9bLdpk6z10T4SDc7dR6qUoBICe9SUGA0hRp2cIC1dCGOYvcZTqoy6UIHbKuoTlkiuBwxytJ8qiC0imDxXWaskj4mYW0(HSQrsahnct3vmmGKscoJmmTFiBIKMZf9nAeMURyyajLbHl0Op20iGqwzbXrJW0DfddiPujo7qiRAV3WH4q4Ory6UIHbKuAe36r1VHmyCeqs2GBnnc4Ory6UIHbKuANiWtzEFTY6cBCaj75Ory6UIHbKuc9BH31qXhYk2ry0imDxXWaskpC9MJb5(SbiYWZ3ob(JgHP7kggqsz1CyjEKvF7e(GKmHg9bLdpk6z10T4SDc7dR6qUoBICk9PmYEvDiRp2cIC1dCGOYvcZTqoy6UIHbKuAeh03EdYk9PSUWg6X47jH9HvDOu0Z6cQrFS(ylicsYRbuIrkoHaQ6BkGApcOliscO9sHbjcODbqj29SUGA0hGApcOxRa6cIKaQvu8bu1pGaQgteqJcGQ(i3a64E5ib0HLcOgGQFCEJkGUGijGoouFaLy3Z6cQrFaAFaQbOqF7jrsav0TJShFsqsMqJ(GYHhf9SA6wC2oH9HvDixNnro9XwqKjwAxkC1dCGOYvcZTqo7DN9m5e2hw1HsrpRlOg9X6JTGOhIKW(WQouw6tzK9Q6qwFSfetzR0Xo7zYjSpSQdLL(ugzVQoK1hBbXu2AVPFptgt3vmmGKsJ4G(2BqwPpL1f2qpgFpejH9HvDOS0NYi7v1HS(yliMYweZ7zYy6UIHbKuoTlkiuBwxytJ8qi0drsyFyvhkl9PmYEvDiRp2cIPasYRbuIDpRlOg9bObeq7ZXnGUGijGoou)EPaQxY(DKjW4a00PqyF2jqaTFaDpGZ(5gq7cGMoVebjGsm4rBcb0OaOHcOJdNdqRiGAjSWzvhcOMcOo0GkGQ(beqN2XnGcrrFKqaTIL(rav9rafHq8eiXqiGk62r2JpanGa6Jgj3sqsMqJ(GYHhf9SA6wC2oH9HvDixNnro(TJKj6zDb1OpM6)i0VDKC1dCEeIkxKyXwoLZE3bKKxdOB6hqanH9HvDiGchqrucecOQpcO3AwXhq7cGQ2taviGAkGo2pe(akXuRakV(O5nGsSC2eH6hEJqaTxkmiraTlakXUN1fuJ(auOFVCKaAfb0fejLGKmHg9bLdpk6z10T4SDc7dR6qUoBIC8BLb1hnVzfNnrO(H3ix9ahiQCffojSpSQdL(TYG6JM3SIZMiu)WBKZoCLWClKZE3t1C4PYIZMiBWuHVepR6qYT8QE19KiQ5WtLfNnr2GPcFjEw1HKGK8AaDt)acOjSpSQdbu4akIsGqav9ra9wZk(aAxau1EcOcbutb0X(HWhqjMSNeqj2gubuILZMiu)WBecO9sHbjcODbqj29SUGA0hGc97LJeqRiGUGijGAqaTeoh(sqsMqJ(GYHhf9SA6wC2oH9HvDixNnro(2tYeguzfNnrO(H3ix9ahiQCffojSpSQdL(2tYeguzfNnrO(H3iND4kH5wihVypvZHNkloBISbtf(s8SQdj3YR6v3tIOMdpvwC2ezdMk8L4zvhscsYRbuVCyCeauILZMiu)WBeqTIIpGsS7zDb1OpanGaANaFavyhGkSfebudqHbHlkHWofqTzVofq7cGsAtJacOAdOveqDnubuYfcOAdOQpcODc8h)HghbaTlakXicxOiGQ(McOTqSEiGo2hpav9raLyeHlueqlFpbuU71dOdFmTNBaLy3Z6cQrFaQApbubu4WJgjucOB6hqanH9HvDiGgqaDbrsavBafoGIOWnGQ(iGAZEDkG2favJjcOXbOqu0hjeqvFtb05cQa6GbHaQvu8buIDpRlOg9bOirhIhHaAfl9JakXYzteQF4ncb0XHZbOveqxqKeqV(NMZXTeKKj0OpOC4rrpRMUfNTtyFyvhY1ztKdj6mUzfNnrO(H3ixKyXwoLZEtpx9aNhHOcsYRbuVKH6dOPthhPlocCbOe7Ewxqn6JyieqfD7i7XhGooCoaTIa6JKlbscOvUbudqF7i7jGAZEDkxaADPaQ6Ja6TMv8b0UaOIpuiGcv7viGMaFUbu)GGpGAffFa1eAKW04iaOe7Ewxqn6dqTJeqHUEmeqj7XhGQ9y7jHaQ6JakEKaAxauIDpRlOg9rmecOIUDK94tcOEj9XdqNM3XraqjrraJ(GaACaQ6JaQxI940zUauIDpRlOg9rmecOpoT4IJaGk62r2JpanGa6JKlbscOvUbu1pGaA5nHg9bOAdOMq0Rtb0s)aA60Xr6IJGeKKj0OpOC4rrpRMUfNTtyFyvhY1ztKJ3Xr6IJa7rYLqJ(4Iel2YPC2rUxU6bopcrfKKxdOMqJ(GYHhf9SA6wC2gE2a0VvgunfcsYeA0huo8OONvt3IZ2liYcfNCD2e5yeh03EdYk9PSUWg6X4dsYeA0huo8OONvt3IZ2Z4)(zX0iGGKmHg9bLdpk6z10T4S9qRrFGKmHg9bLdpk6z10T4S9a3FxDgubjbsYRb09iefflfjbumb(CdOAmrav9ra1eA)aAabulHfoR6qjijtOrFqoIEDk(Wb05ajzcn6dUfNTtyFyvhY1ztKJgtKPnt0Z6cQrFC1dCGOYvcZTqoQ5WtLL4rOAVIVepR6qY9Sepcv7v8LpoT4GBLSOBhzp(KIEwxqn6t(40IdUNjNkXNW(WQou6DCKU4iWEKCj0OV9unhEQ074iDXrqINvDizkeVj0Op5VoK1f2qpgFjsuuSuKPXe3t1C4PYFDiRlSHEm(s8SQdjtzpjIOBhzp(KIEwxqn6t(OrY9EwxLIu0Z6cQrFsYE8bsYeA0hCloBNW(WQoKRZMihnMitBMON1fuJ(4Qh4mnIYvcZTqoIUDK94toXz)CZ6cZTebjJ8rBcLpoT4GCffoieINaLtC2p3SUWClrqYiF0Mq508s73tDvkYjo7NBwxyULiizKpAtOKShFEeD7i7XNCIZ(5M1fMBjcsg5J2ekFCAXbj(e2hw1HsnMitBMON1fuJ(2Ntc7dR6qPF7izIEwxqn6JP(pc9BhjijtOrFWT4SDc7dR6qUoBIC0yImTzIEwxqn6JREGZ0ikxjm3c5i62r2Jp54(DKjW4ypc7ZobkFCAXb5kkCqiepbkh3VJmbgh7ryF2jq508s73tDvkYX97itGXXEe2NDcus2JppIUDK94toUFhzcmo2JW(StGYhNwCqIpH9HvDOuJjY0Mj6zDb1OV95KW(WQou63osMON1fuJ(yQ)Jq)2rcsYeA0hCloBlmNJzcn6J5cOY1ztKtO4eY8dc(SHp6puUbjzcn6dUfNTNX)9ZIPra5kkCQRsrk6zDb1Opjzp(ajzcn6dUfNTjSSNmSJ1fMrC43QpxrHtYjSpSQdLAmrM2mrpRlOg9TFQ7mAKgtKPnJmW9tyFyvhk1yImTzIEwxqn6lfqsMqJ(GBXzBrFc803uKKvC2ebjzcn6dUfNTF0gIJaR4Sjcbjzcn6dUfNTlTybrsMrC4hkYQOnbjzcn6dUfNThwFu4oocSQZGkijtOrFWT4S9hddoKfhdoyceKKj0Op4wC2w9r26Q96izL(fiijtOrFWT4S9VoK1f2qpgFUIcN6QuK)6qwxyd9y8LK94ZtDvksrpRlOg9jj7XNNKtyFyvhk1yImTzIEwxqn6B3YY5ypk8TNaY0yIJgLW(WQouQXezAZe9SUGA03ULGGVYECAXbtbKKj0Op4wC2wyohZeA0hZfqLRZMihrpRlOg9Xg8niYvu4KW(WQouQXezAZe9SUGA03(C2bKKj0Op4wC2UepYQodQCTGiRlfgbbjNu5Abr2y)WHmHb14iWjvUIcNKriepbkN4SFUzDH5wIGKr(OnHYP5L2)OrieINaLtC2p3SUWClrqYiF0Mq5mU(9yeh(HIYQZGk(SPbv8L4zvhsMIhHV9eqiNPruMW3Eci0drQRsr63kdQpAElF0eQhIKCDvksF004iWwdYhnH6j56QuKIEwxqn6tUg8KSj0OpzjESAoNmowXfe81rJmHg9jh4(7QZGQmowXfe81rJmHg9jHI(f(sKOOyPXriLrJu7jGQ0hnN6lhe6(C8ID8ycn6tcf9l8LirrXsJJqkP4HijtK6QuK(OPXrGTgKpAc1drQRsr63kdQpAElF0eQN6QuKIEwxqn6ts2JppjBcn6twIhRMZjJJvCbbFD0itOrFYbU)U6mOkJJvCbbFnLuajzcn6dUfNTtyFyvhY1ztKtjEKvDguzdD7IJaxjm3c5OMdpv(RdzDHn0JXxINvDiPhr3oYE8j)1HSUWg6X4lFCAXb3x0TJShFYs8iR6mOkllNJ9OW3EcitJj6j5e2hw1HsnMitBMON1fuJ(21eA0N8xhY6cBOhJVSSCo2JcF7jGmnMykEsw0TJShFYFDiRlSHEm(YhNwCW91yImTzKboAKj0Op5VoK1f2qpgFPW3EciC3Dsz0Oe2hw1HsnMitBMON1fuJ(23eA0NSepYQodQYYY5ypk8TNaY0yIEsyFyvhk1yImTzIEwxqn6BFnMitBgzGGKmHg9b3IZ2cZ5yMqJ(yUaQCD2e589aBW3Gixq9dHYjvUIcN6QuK)6qwxyd9y8LRbpjNW(WQouQXezAZe9SUGA03U7KcijtOrFWT4SDc7dR6qUoBICg8B8cIYg62fhbUsyUfYrnhEQ8xhY6cBOhJVepR6qspIUDK94t(RdzDHn0JXx(40IdUVOBhzp(Kd(nEbrzfNnrOSSCo2JcF7jGmnMONKtyFyvhk1yImTzIEwxqn6BxtOrFYFDiRlSHEm(YYY5ypk8TNaY0yIP4jzr3oYE8j)1HSUWg6X4lFCAXb3xJjY0Mrg4OrMqJ(K)6qwxyd9y8LcF7jGWD3jLrJsyFyvhk1yImTzIEwxqn6BFtOrFYb)gVGOSIZMiuwwoh7rHV9eqMgt0tc7dR6qPgtKPnt0Z6cQrF7RXezAZideKKxdOEj9XdqjMSNuyqnocakXYzteq51p8g5cqjwXJa6godQqaf63lhjGwraDbrsavBaLaE4BkcOetTcO86JM3qa1osavBafjQIhjGUHZGk(a6EWGk(sqsMqJ(GBXz7s8iR6mOY1cISUuyeeKCsLRfezJ9dhYeguJJaNu5kkCsMijSpSQdLL4rw1zqLn0TlocJgvxLI8xhY6cBOhJVCnKINKtyFyvhk1yImTzIEwxqn6B3DsXtYMqJeidpCgiCxojSpSQdL(2tYeguzfNnrO(H3ONK1yIeFDvksrpRlOg9jDguzirhIh3nH9HvDOKeDg3SIZMiu)WBmLu8qKs8iuTxXxAcnsGEQRsr63kdQpAElj7XNNKjIrC4hkkRodQ4ZMguXxINvDi5Or1vPiRodQ4ZMguXx(40IdU)oY0NcijVgqjgS(4iaOeR4rOAVIpxakXkEeq3WzqfcO2Ja6cIKakmMHZEh3aQ2ak56JJaGsS7zDb1OpjGMoz8W3CoU5cqvFKBa1EeqxqKeq1gqjGh(MIakXuRakV(O5neqh7JhGk(qHa64W5a0RvaTIa6ydQijGAhjGoouFaDdNbv8b09Gbv85cqvFKBaf63lhjGwrafo8OrcO9sbuTb0PfNAXbOQpcOB4mOIpGUhmOIpGwxLIeKKj0Op4wC2UepYQodQCTGiRlfgbbjNu5Abr2y)WHmHb14iWjvUIcNs8iuTxXxAcnsGEe(2taH7YjvpjtKe2hw1HYs8iR6mOYg62fhHrJQRsr(RdzDHn0JXxUgsXtYeXio8dfLvNbv8ztdQ4lXZQoKC0O6QuKvNbv8ztdQ4lFCAXb3Fhz6tXtYeXeA0NSepwnNtIefflnocEiIj0Op5a3FxDguLXXkUGGV6PUkfPpAACeyRb5Ay0itOrFYs8y1CojsuuS04i4PUkfPFRmO(O5TKShFJgzcn6toW93vNbvzCSIli4REQRsr6JMghb2Aqs2Jpp1vPi9BLb1hnVLK94lfqsMqJ(GBXzBH5CmtOrFmxavUoBICGQDK2tY(wnn6JlO(Hq5KkxrHtc7dR6qPgtKPnt0Z6cQrF7UdijqsMqJ(GstOrcKPMdpfYXfjIJaR2ZkxrHJj0ibYWdNbc3nvp1vPif9SUGA0NKShFEsoH9HvDOuJjY0Mj6zDb1OVDfD7i7XN0fjIJaR2ZQKC9Mg9nAuc7dR6qPgtKPnt0Z6cQrF7ZzNuajzcn6dknHgjqMAo8u4wC2EIk2pxrHtc7dR6qPgtKPnt0Z6cQrF7ZzNrJsUUkf5VoK1f2qpgF5Ay0ir3oYE8j)1HSUWg6X4lFCAXb3vJjY0MrgOhtOrFYFDiRlSHEm(sHV9eq4(PoAeruZHNk)1HSUWg6X4lXZQoKmfpjl62r2Jp5evSFj56nn6B)e2hw1HsnMitBMON1fuJ(gnsJjY0Mrg4(jSpSQdLAmrM2mrpRlOg9LcijtOrFqPj0ibYuZHNc3IZ2KVrOpiR(OP(CffoQ5WtLMdjkuFdsCgKvwp3s8SQdj9KCDvksrpRlOg9jj7XNhIuxLI0VvguF08w(Oj0rJQRsrk6zDb1Op5AWJj0OpzjEKvDguLcF7jGW9nHg9jlXJSQZGQCAeLj8TNac9qK6QuK(TYG6JM3YhnHMcijqsEnGsS7zDb1OpaDW3GiGo84G9ieqTA4cnqiGoouFa1aus0zCZfGQ(4bOoBDcFecOXPnGQ(iGsS7zDb1OpafIP7cpbcsYeA0huk6zDb1Op2GVbroUGGVczEPlsct8uUIcN6QuKIEwxqn6ts2JpqsMqJ(GsrpRlOg9Xg8niUfNTRgbwxy6hcVHCffo1vPif9SUGA0NKShFGKmHg9bLIEwxqn6Jn4BqCloB7IeXrGv7zLROWXeAKaz4HZaH7MQN6QuKIEwxqn6ts2JpqsMqJ(GsrpRlOg9Xg8niUfNTRUUjzDHP(idpCYnijtOrFqPON1fuJ(yd(ge3IZ2tC2p3SUWClrqYiF0MqqsMqJ(GsrpRlOg9Xg8niUfNTh3VJmbgh7ryF2jqqsEnGsmy9Xraqj29SUGA0hxakXkEeq3WzqfcO2Ja6cIKaQ2akb8W3ueqjMAfq51hnVHaQDKa6mUygehcOQpcO2SxNcODbq1yIakCapfqrIIILghbaTvF8bu4a6CqjGsS6hqHQDK2tcOeR4rUauIv8iGUHZGkeqThb0(CCdOliscOJ9XdqjMqtJJaG6LpaObeqnHgjqaTFaDSpEaQbO8I(f(aQWGkGgqanoaD4BcpcHaQDKakXeAACeauV8ba1osaLyQvaLxF08gqThb0Rva1eAKaLaQxYq9b0nCguXhq3dguXhqTJeqjwoBIaA6ehxakXkEeq3WzqfcOc7auJKm0OpZ54gqRiGUGijGo2pCiGsm1kGYRpAEdO2rcOetOPXraq9Yhau7ra9AfqnHgjqa1osa1a09yU)U6mOcObeqJdqvFeqT4bu7ibuZbBaDSF4qavyqnocakVOFHpGIjWdqJcGsmHMghba1lFaqdiGAUhnsUbutOrcucOB6JaQZufFa1CUEmeq1XnGsm1kGYRpAEdO7XC)D1zqfcOAdOveqfgub04au4siqim6dqTIIpGQ(iGYl6x4lbuVeKKHg9zoh3a64q9b0nCguXhq3dguXhqTJeqjwoBIaA6ehxakXkEeq3WzqfcOq)E5ib0RvaTIa6cIKa66CiecOB4mOIpGUhmOIpGgqa1Q9sbuTbuKOdXJaA)aQ6JpcO2Ja6SFeqvF7au86fbFaLyfpcOB4mOcbuTbuKOkEKa6godQ4dO7bdQ4dOAdOQpcO4rcODbqj29SUGA0NeKKj0OpOu0Z6cQrFSbFdIBXz7s8iR6mOY1cISUuyeeKCsLRfezJ9dhYeguJJaNu5kkCe(2taH7YjvpjNSj0OpzjEKvDguLcF7jGqw5nHg9zUTsUUkfPON1fuJ(KpoT4GeFDvkYQZGk(SPbv8LKR30OVu2Jk62r2JpzjEKvDguLKR30OpIp56QuKIEwxqn6t(40IdMYE0KRRsrwDguXNnnOIVKC9Mg9r87itFkPSlNDgnIigXHFOOS6mOIpBAqfFjEw1HKJgre1C4PYIZMiRpjEw1HKJgvxLIu0Z6cQrFYhNwCW95uxLIS6mOIpBAqfFj56nn6B0O6QuKvNbv8ztdQ4lFCAXb3Fhz6hnct3vmmGKsFUhWx9F0izJ)aQJFBa6r0TJShFsFUhWx9F0izJ)aQJFBaY8ID2j10XELpoT4G7N(u8uxLIu0Z6cQrFY1GNKjIj0Opju0VWxIefflnocEiIj0Op5a3FxDguLXXkUGGV6PUkfPpAACeyRb5Ay0itOrFsOOFHVejkkwACe8uxLI0VvguF08ws2JppjxxLI0hnnocS1GKShFJgzeh(HIYQZGk(SPbv8L4zvhsMYOrgXHFOOS6mOIpBAqfFjEw1HKEuZHNkloBIS(K4zvhs6XeA0NCG7VRodQY4yfxqWx9uxLI0hnnocS1GKShFEQRsr63kdQpAElj7XxkGKmHg9bLIEwxqn6Jn4BqCloB)RdzDHn0JXNROWPUkf5VoK1f2qpgFjzp(8uxLIu0Z6cQrFsYE8bsYRbuVeakXkEeq3WzqfqH(9YrcOveqxqKeq1gqTHbh3a6godQ4dO7bdQ4dOJ9dhcOcdQXraqtNADiG2faDpUhJpGo2hpaDbJJaGUHZGk(a6EWGk(CbOelNnranDIJla1osaDpGk2Veqjgva0(CCdO7bC2p3aAxa005LiibuIbpAtiGUhIRFanGakMURyyaj5cqv)acOU4qanGaAq46hjb0kkSfeb0qb0XHZbOWEIAmriG(iC5uanoaLqhhbanoTbuIDpRlOg9bOJd1hql4yaLyfpcOB4mOcOcF7jGqjijtOrFqPON1fuJ(yd(ge3IZ2L4rw1zqLRfezJ9dhYeguJJaNu5kkCmId)qrz1zqfF20Gk(s8SQdj9KmcH4jq5eN9ZnRlm3seKmYhTjuonV0(hnIiieINaLtC2p3SUWClrqYiF0Mq5mU(tXJAo8u5evSFjEw1HKEuZHNkloBIS(K4zvhs6PUkfz1zqfF20Gk(sYE85jz1C4PYFDiRlSHEm(s8SQdj9ycn6t(RdzDHn0JXxIefflnocEmHg9j)1HSUWg6X4lrIIILIShNwCW93r6vgnk5e2hw1HsnMitBMON1fuJ(2NZoJgvxLIu0Z6cQrFY1qkEiIAo8u5VoK1f2qpgFjEw1HKEiIj0Op5a3FxDguLXXkUGGV6HiMqJ(KL4XQ5CY4yfxqWxtbKKj0OpOu0Z6cQrFSbFdIBXzBH5CmtOrFmxavUoBICmHgjqMAo8uiijtOrFqPON1fuJ(yd(ge3IZ2IEwxqn6JRfezDPWiii5KkxliYg7hoKjmOghboPYvu4KCYMqJ(KtuX(LXXkUGGV6XeA0NCIk2VmowXfe8v2Jtlo4(C2rM(ugnYeA0NCIk2VmowXfe81rJqiepbkN4SFUzDH5wIGKr(OnHYP5L2)Or1vPi9BLb1hnVLpAcD0itOrFsOOFHVejkkwACe8ycn6tcf9l8LirrXsr2Jtlo4(7it)OrMqJ(KdC)D1zqvIefflnocEmHg9jh4(7QZGQejkkwkYECAXb3Fhz6tXtY1vPi)1HSUWg6X4lxdJgre1C4PYFDiRlSHEm(s8SQdjtbKKj0OpOu0Z6cQrFSbFdIBXz7HwJ(ajzcn6dkf9SUGA0hBW3G4wC2U66MKvwp3GKmHg9bLIEwxqn6Jn4BqCloBxXhIV3XraKKj0OpOu0Z6cQrFSbFdIBXz7s8y11njijtOrFqPON1fuJ(yd(ge3IZ22jqO(MJjmNdKKj0OpOu0Z6cQrFSbFdIBXz7IZMiu)WBKROWj5KvZHNkloBISbtf(s8SQdj9ycnsGm8WzGWD3BkJgzcnsGm8WzGWD9kP4PUkfPFRmO(O5T8rtOEiIrC4hkkRodQ4ZMguXxINvDijijtOrFqPON1fuJ(yd(ge3IZ2dC)D1zqLROWPUkf5a3FlCgCkF0eQN6QuKIEwxqn6t(40IdURWGktJjcsYeA0huk6zDb1Op2GVbXT4S9a3FxDgu5kkCQRsr63kdQpAElF0ekijVgqj29CINghbav9diGIN(CdO9stNeGgkXqiG(OJ74iaO9bOgG(Oj0OpavJjcOKOZ4gqh7JhGYDVauVVEmGYDVEaLx0VWhqhhohGk(qbu7ibuU7fG6BKakXeAACeauV8baDSpEak39cqfgubuEr)cFjijVgqjgDepbBICbOQFab0acO(2r6qsaD2pcONPR3CoULGK8Aa1eA0huk6zDb1Op2GVbXT4S9a3FxDgu5kkCgEmbJGGuMQek6x47PUkfPpAACeyRb5AaKKj0OpOu0Z6cQrFSbFdIBXz7b)gVGOSIZMieKKj0OpOu0Z6cQrFSbFdIBXzBOOFHpxrHtDvksrpRlOg9jFCAXb3vyqLPXe9uxLIu0Z6cQrFY1WOr1vPif9SUGA0NKShFEeD7i7XNu0Z6cQrFYhNwCW9fguzAmrqsMqJ(GsrpRlOg9Xg8niUfNTDrI4iWQ9SYvu4uxLIu0Z6cQrFYhNwCW9jiiLtJOEmHgjqgE4mq4UPcsYeA0huk6zDb1Op2GVbXT4Sn5Be6dYQpAQpxrHtDvksrpRlOg9jFCAXb3NGGuonI6PUkfPON1fuJ(KRbqsMqJ(GsrpRlOg9Xg8niUfNTHI(f(CffoQ9eqv6JMt9LdcDFoEXoEuZHNkHO9XrGP9s4lXZQoKeKeijtOrFqzO4eYe9SUGA0hNfezHItUoBICccxOrFSPraHSYcIGKmHg9bLHItit0Z6cQrFBXz7fezHItUoBIC85EaF1)rJKn(dOo(TbixrHtDvksrpRlOg9jxdEmHg9jlXJSQZGQu4BpbeYzhpMqJ(KL4rw1zqv(OW3EcitJjUlbbPCAefKKj0OpOmuCczIEwxqn6BloBVGiluCY1ztKZ0UOGqTzDHnnYdHqqsMqJ(GYqXjKj6zDb1OVT4STWob6y1vPW1cISUuyeeKCsLRZMiNPDrbHAZ6cBAKhcHmHVnO4Z6d5kkCQRsrk6zDb1Op5Ay0itOrFYjQy)Y4yfxqWx9ycn6torf7xghR4cc(k7XPfhCFo7itpijtOrFqzO4eYe9SUGA03wC2EbrwO4KRfezDPWiii5KkxNnrogXTEu9BidghbKKn4wtJaYvu4uxLIu0Z6cQrFY1WOrMqJ(KtuX(LXXkUGGV6XeA0NCIk2VmowXfe8v2Jtlo4(C2rMEqsMqJ(GYqXjKj6zDb1OVT4S9cISqXjxliY6sHrqqYjvUWsbfk7SjYHGZidt7hYQgjbKROWPUkfPON1fuJ(KRHrJmHg9jNOI9lJJvCbbF1Jj0Op5evSFzCSIli4RShNwCW95SJm9GKmHg9bLHItit0Z6cQrFBXz7fezHItUwqK1LcJGGKtQCHLcku2ztKdbNrgM2pKnrsZ5I(4kkCQRsrk6zDb1Op5Ay0itOrFYjQy)Y4yfxqWx9ycn6torf7xghR4cc(k7XPfhCFo7itpijtOrFqzO4eYe9SUGA03wC2EbrwO4KRfezDPWiii5KkxNnrovZHL4rw9Tt4Zvu4uxLIu0Z6cQrFY1WOrMqJ(KtuX(LXXkUGGV6XeA0NCIk2VmowXfe8v2Jtlo4(C2rMEqsMqJ(GYqXjKj6zDb1OVT4S9cISqXjxliY6sHrqqYjvUoBICG(TW7AO4dzf7iWvu4uxLIu0Z6cQrFY1WOrMqJ(KtuX(LXXkUGGV6XeA0NCIk2VmowXfe8v2Jtlo4(C2rMEqsMqJ(GYqXjKj6zDb1OVT4S9cISqXjxliY6sHrqqYjvUoBICuIZoeYQ27nCioeYvu4uxLIu0Z6cQrFY1WOrMqJ(KtuX(LXXkUGGV6XeA0NCIk2VmowXfe8v2Jtlo4(C2rMEqsMqJ(GYqXjKj6zDb1OVT4S9cISqXjxliY6sHrqqYjvUoBICSte4PmVVwzDHnoGK9KROWPUkfPON1fuJ(KRHrJmHg9jNOI9lJJvCbbF1Jj0Op5evSFzCSIli4RShNwCW95SJm9GKmHg9bLHItit0Z6cQrFBXz7fezHItUwqK1LcJGGKtQCD2e5C46nhdY9zdqKHNVDc85kkCQRsrk6zDb1Op5Ay0itOrFYjQy)Y4yfxqWx9ycn6torf7xghR4cc(k7XPfhCFo7itpijtOrFqzO4eYe9SUGA03wC2EbrwO4KRfezDPWiii5KkxNnrotZv6FIKmF8nhjK5qcJFBaYvu4uxLIu0Z6cQrFY1WOrMqJ(KtuX(LXXkUGGV6XeA0NCIk2VmowXfe8v2Jtlo4(C2rMEqsGKmHg9bLHItiZpi4Zg(O)q5MJWCoMj0OpMlGkxNnroHItit0Z6cQrFCffojSpSQdLAmrM2mrpRlOg9TpNDajzcn6dkdfNqMFqWNn8r)HY9wC2EbrwO4ecsYeA0hugkoHm)GGpB4J(dL7T4S9cISqXjxNnrot7Icc1M1f20ipec5kkCicMURyyajLgXb9T3GSsFkRlSHEm(EsyFyvhk1yImTzIEwxqn6BFIzqsMqJ(GYqXjK5he8zdF0FOCVfNTxqKfko56SjYXioOV9gKv6tzDHn0JXNROWjH9HvDOuJjY0Mj6zDb1OV95K(Tsn97zc7dR6qzPpLr2RQdz9XwqeKKj0OpOmuCcz(bbF2Wh9hk3BXz7fezHItUoBIC(wf)cQijlr3KDZiBNJROWjH9HvDOuJjY0Mj6zDb1OVDtyFyvhk7JTGitS0Uuajzcn6dkdfNqMFqWNn8r)HY9wC2EbrwO4KRZMihlDxXqR4PSZwA4wqUIcNe2hw1HsnMitBMON1fuJ(2nH9HvDOSp2cImXs7sbKKj0OpOmuCcz(bbF2Wh9hk3BXz7fezHItUoBICG(rc8zjWRNShDHGROWjH9HvDOuJjY0Mj6zDb1OVDtyFyvhk7JTGitS0Uuajzcn6dkdfNqMFqWNn8r)HY9wC2EbrwO4KRZMiNs)1GKepwxHbzyht4SXCffojSpSQdLAmrM2mrpRlOg9TBc7dR6qzFSfezIL2LcijtOrFqzO4eY8dc(SHp6puU3IZ2liYcfNCHLcku2ztKJV9Z(cbJeNMIFyUG4WhKKj0OpOmuCcz(bbF2Wh9hk3BXz7fezHItUoBICMMR0)ejz(4BosiZHeg)2aKROWjH9HvDOuJjY0Mj6zDb1OVD5K(07PUkfPON1fuJ(KK94Ztc7dR6qPgtKPnt0Z6cQrF7MW(WQou2hBbrMyPDPasYeA0hugkoHm)GGpB4J(dL7T4S9cISqXjxNnro2jc8uM3xRSUWghqYEYvu4KW(WQouQXezAZe9SUGA03UCsF69uxLIu0Z6cQrFsYE85jH9HvDOuJjY0Mj6zDb1OVDtyFyvhk7JTGitS0Uuajzcn6dkdfNqMFqWNn8r)HY9wC2EbrwO4KRZMiNdxV5yqUpBaIm88TtGpxrHtc7dR6qPgtKPnt0Z6cQrF7YjDKEp1vPif9SUGA0NKShFEsyFyvhk1yImTzIEwxqn6B3e2hw1HY(yliYelTlfqsGKmHg9bLHItiZ1JzdF0FOCZzbrwO4KRZMihnirO2)KjAsKOCffojSpSQdLAmrM2mrpRlOg9TBc7dR6qzFSfezIL2LcijtOrFqzO4eYC9y2Wh9hk3BXz7fezHItUWsbfk7SjYrWTW163xiyvNbvUIcNe2hw1HsnMitBMON1fuJ(2nH9HvDOSp2cImXs7sbKeijtOrFq53dSbFdICkoBIq9dVrUIcNKnHgjqgE4mq4UCsyFyvhk9BLb1hnVzfNnrO(H3ONK1yIeFDvksrpRlOg9jDguzirhIh3nH9HvDOKeDg3SIZMiu)WBmLu8uxLI0VvguF08w(OjuqsMqJ(GYVhyd(ge3IZ2dC)D1zqLROWPUkfPFRmO(O5T8rtOGKmHg9bLFpWg8niUfNTlXJSQZGkxliY6sHrqqYjvUwqKn2pCityqnocCsLROWHijBcnsGm8WzGWD5KW(WQou6BpjtyqLvC2eH6hEJEswJjs81vPif9SUGA0N0zqLHeDiEC3e2hw1Hss0zCZkoBIq9dVXusXdrkXJq1EfFPj0ib6jzIuxLI0hnnocS1G8rtOEisDvks)wzq9rZB5JMq9qKHhtW6sHrqqklXJSQZGQNKnHg9jlXJSQZGQu4BpbeUlN9oAuYMqJ(Kd(nEbrzfNnrOu4BpbeUlNu9OMdpvo434feLvC2eHs8SQdjtz0OKvZHNknhsuO(gK4miRSEUL4zvhs6r0TJShFsY3i0hKvF0uF5Jgj3PmAuYQ5WtLq0(4iW0Ej8L4zvhs6rTNaQsF0CQVCqO7ZXl2jLusbKKj0OpO87b2GVbXT4STWCoMj0OpMlGkxNnroMqJeitnhEkeKKj0OpO87b2GVbXT4S9a3FxDgu5kkCQRsroW93cNbNYhnH6ryqLPXe3VUkf5a3FlCgCkFCAXb9uxLI8xhY6cBOhJV8XPfhCxHbvMgteKKj0OpO87b2GVbXT4SDjEKvDgu5AbrwxkmccsoPY1cISX(HdzcdQXrGtQCffoejztOrcKHhodeUlNe2hw1HsF7jzcdQSIZMiu)WB0tYAmrIVUkfPON1fuJ(KodQmKOdXJ7MW(WQousIoJBwXzteQF4nMskEisjEeQ2R4lnHgjqpjxxLI0hnnocS1G8rtOEswTNaQsF0CQVCqO7YXl2z0iIOMdpvcr7JJat7LWxINvDizkPasYeA0hu(9aBW3G4wC2UepYQodQCTGiRlfgbbjNu5Abr2y)WHmHb14iWjvUIchIKSj0ibYWdNbc3Ltc7dR6qPV9KmHbvwXzteQF4n6jznMiXxxLIu0Z6cQrFsNbvgs0H4XDtyFyvhkjrNXnR4Sjc1p8gtjfpePepcv7v8LMqJeOh1C4PsiAFCeyAVe(s8SQdj9O2tavPpAo1xoi0954f74j56QuK(OPXrGTgKpAc1drmHg9jHI(f(sKOOyPXry0iIuxLI0hnnocS1G8rtOEisDvks)wzq9rZB5JMqtbKKj0OpO87b2GVbXT4S9a3FxDgu5kkCgEmbJGGuMQek6x47PUkfPpAACeyRb5AWJAo8ujeTpocmTxcFjEw1HKEu7jGQ0hnN6lhe6(C8ID8qKKnHgjqgE4mq4UCsyFyvhk9BLb1hnVzfNnrO(H3ONK1yIeFDvksrpRlOg9jDguzirhIh3nH9HvDOKeDg3SIZMiu)WBmLuajzcn6dk)EGn4BqCloBp434feLvC2eHCffoez4XemccszQYb)gVGOSIZMi0tDvksF004iWwdYhnHcsYeA0hu(9aBW3G4wC2gk6x4Zvu4O2tavPpAo1xoi0954f74rnhEQeI2hhbM2lHVepR6qsqsMqJ(GYVhyd(ge3IZ2KVrOpiR(OP(CffoMqJeidpCgiC39csYeA0hu(9aBW3G4wC2U4Sjc1p8g5kkCs2eAKaz4HZaH7YjH9HvDO03EsMWGkR4Sjc1p8g9KSgtK4RRsrk6zDb1OpPZGkdj6q84UjSpSQdLKOZ4MvC2eH6hEJPKcijtOrFq53dSbFdIBXz7s8y1CoqsGKmHg9bLq1os7jzFRMg9XP4Sjc1p8g5kkCs2eAKaz4HZaH7YjH9HvDO0VvguF08MvC2eH6hEJEswJjs81vPif9SUGA0N0zqLHeDiEC3e2hw1Hss0zCZkoBIq9dVXusXtDvks)wzq9rZB5JMqbjzcn6dkHQDK2tY(wnn6BloBpW93vNbvUIcN6QuK(TYG6JM3YhnH6PUkfPFRmO(O5T8XPfhCFtOrFYs8y1CojsuuSuKPXebjzcn6dkHQDK2tY(wnn6BloBpW93vNbvUIcN6QuK(TYG6JM3YhnH6j5HhtWiiiLPklXJvZ5gnQepcv7v8LMqJe4OrMqJ(KdC)D1zqvghR4cc(AkGKmHg9bLq1os7jzFRMg9TfNTh8B8cIYkoBIqUIchHV9eq4UC8cpMqJeidpCgiC396HijSpSQdLd(nEbrzdD7IJaijtOrFqjuTJ0Es23QPrFBXz7bU)U6mOYvu4uxLI0VvguF08w(OjupQ9eqv6JMt9LdcDFoEXoEuZHNkHO9XrGP9s4lXZQoKeKKj0OpOeQ2rApj7B10OVT4S9a3FxDgu5kkCQRsroW93cNbNYhnH6ryqLPXe3VUkf5a3FlCgCkFCAXbbjzcn6dkHQDK2tY(wnn6BloBxIhzvNbvUwqK1LcJGGKtQCTGiBSF4qMWGACe4KkxrHtY1vPi)1HSUWg6X4lj7XNhIuIhHQ9k(stOrcmfpejH9HvDOSepYQodQSHUDXrWtYjNSj0OpzjESAoNejkkwACegnYeA0NCG7VRodQsKOOyPXrifp1vPi9rtJJaBniF0eAkJgLSAo8ujeTpocmTxcFjEw1HKEu7jGQ0hnN6lhe6(C8ID8KCDvksF004iWwdYhnH6HiMqJ(Kqr)cFjsuuS04imAerQRsr63kdQpAElF0eQhIuxLI0hnnocS1G8rtOEmHg9jHI(f(sKOOyPXrWdrmHg9jh4(7QZGQmowXfe8vpeXeA0NSepwnNtghR4cc(AkPKcijtOrFqjuTJ0Es23QPrFBXz7bU)U6mOYvu4m8ycgbbPmvju0VW3tDvksF004iWwdY1Gh1C4PsiAFCeyAVe(s8SQdj9O2tavPpAo1xoi0954f74HijBcnsGm8WzGWD5KW(WQou63kdQpAEZkoBIq9dVrpjRXej(6QuKIEwxqn6t6mOYqIoepUBc7dR6qjj6mUzfNnrO(H3ykPasYeA0hucv7iTNK9TAA03wC2EWVXlikR4Sjc5kkCsUUkfPpAACeyRb5JMqhnkzIuxLI0VvguF08w(OjupjBcn6twIhzvNbvPW3EciC3DgnsnhEQeI2hhbM2lHVepR6qspQ9eqv6JMt9LdcDFoEXoPKskEisc7dR6q5GFJxqu2q3U4iasYeA0hucv7iTNK9TAA03wC2wyohZeA0hZfqLRZMihtOrcKPMdpfcsYeA0hucv7iTNK9TAA03wC2M8nc9bz1hn1NROWXeAKaz4HZaH7MkijtOrFqjuTJ0Es23QPrFBXzBH5CmtOrFmxavUoBICcfNqMRhZg(O)q5gKKj0OpOeQ2rApj7B10OVT4Snu0VWNROWrTNaQsF0CQVCqO7ZXl2XJAo8ujeTpocmTxcFjEw1HKGK8Aa1lzO(akE9IGpGQ2tavixaAOaAabudqjyXbOAdOcdQakXYzteQF4ncOgeqlHZHpGghurJeq7cGsSIhRMZjbjzcn6dkHQDK2tY(wnn6BloBxC2eH6hEJCffoMqJeidpCgiCxojSpSQdL(2tYeguzfNnrO(H3ONK1yIeFDvksrpRlOg9jDguzirhIh3nH9HvDOKeDg3SIZMiu)WBmfqsMqJ(GsOAhP9KSVvtJ(2IZ2L4XQ5CGKmHg9bLq1os7jzFRMg9TfNTHI(f(znR5m]] )


end
