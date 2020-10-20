-- MageFire.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [-] controlled_destruction
-- [-] flame_accretion -- adds to "fireball" buff
-- [-] master_flame
-- [x] infernal_cascade


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
            duration = function () return level > 55 and 12 or 10 end,
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
            meta = {
                tick_dmg = function( t )
                    return t.v1
                end,
            }
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


        -- Legendaries
        fevered_incantation = {
            id = 333049,
            duration = 6,
            max_stack = 5
        },
    
        firestorm = {
            id = 333100,
            duration = 5,
            max_stack = 1
        },

        molten_skyfall = {
            id = 333170,
            duration = 30,
            max_stack = 25
        },

        molten_skyfall_ready = {
            id = 333182,
            duration = 30,
            max_stack = 1
        },
        
        sun_kings_blessing = {
            id = 333314,
            duration = 30,
            max_stack = 12
        },

        sun_kings_blessing_ready = {
            id = 333315,
            duration = 15,
            max_stack = 1
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


    local hot_streak_spells = {
        "dragons_breath",
        "fireball",
        "fire_blast",
        "phoenix_flames",
        "pyroblast",
        "scorch",        
    }
    spec:RegisterStateExpr( "hot_streak_spells_in_flight", function ()
        for i, spell in ipairs( hot_streak_spells ) do
            if state:IsInFlight( spell ) then return true end
        end

        return false
    end )


    Hekili:EmbedDisciplinaryCommand( spec )


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
            charges = function () return talent.shimmer.enabled and 2 or nil end,
            cooldown = function () return ( talent.shimmer.enabled and 20 or 15 ) - conduit.flow_of_time.mod * 0.001 end,
            recharge = function () return ( talent.shimmer.enabled and ( 20 - conduit.flow_of_time.mod * 0.001 ) or nil ) end,
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
            cooldown = function () return 24 - ( conduit.grounding_surge.mod * 0.1 ) end,
            gcd = "off",

            discipline = "arcane",

            interrupt = true,
            toggle = "interrupts",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135856,

            debuff = function () return not runeforge.disciplinary_command.enabled and "casting" or nil end,
            readyTime = function () if debuff.casting.up then return state.timeToInterrupt() end end,

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
                applyDebuff( "target", "ignite" )

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                if azerite.blaster_master.enabled then addStack( "blaster_master", nil, 1 ) end
                if conduit.infernal_cascade.enabled and buff.combustion.up then addStack( "infernal_cascade" ) end
            end,

            auras = {
                -- Conduit
                infernal_cascade = {
                    id = 336832,
                    duration = 5,
                    max_stack = 3
                }
            }
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
                removeBuff( "molten_skyfall" )
            end,

            impact = function ()
                if hot_streak( firestarter.active or stat.crit + buff.fireball.stack * 10 >= 100 ) then
                    removeBuff( "fireball" )
                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    addStack( "fireball", nil, 1 )
                    if conduit.flame_accretion.enabled then addStack( "flame_accretion" ) end
                end

                if legendary.molten_skyfall.enabled and buff.molten_skyfall_ready.down then
                    addStack( "molten_skyfall" )
                    if buff.molten_skyfall.stack == 25 then
                        removeBuff( "molten_skyfall" )
                        applyBuff( "molten_skyfall_ready" )
                    end
                end

                applyDebuff( "target", "ignite" )
            end,
        },


        flamestrike = {
            id = 2120,
            cast = function () return ( buff.hot_streak.up or buff.firestorm.up ) and 0 or 4 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135826,

            handler = function ()
                if not hardcast then
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                    else removeBuff( "hot_streak" ) end

                    if legendary.sun_kings_blessing.enabled then
                        addStack( "sun_kings_blessing", nil, 1 )
                        if buff.sun_kings_blessing.stack == 12 then
                            removeBuff( "sun_kings_blessing" )
                            applyBuff( "sun_kings_blessing_ready" )
                        end
                    end
                end

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

            discipline = "arcane",
            
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

            discipline = "frost",

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
            cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) end,
            gcd = "spell",

            discipline = "frost",

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

            discipline = "arcane",

            spend = 0.03,
            spendType = "mana",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132220,

            handler = function ()
                applyBuff( "preinvisibility" )
                applyBuff( "invisibility", 23 )
                if conduit.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
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

            discipline = "arcane",

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
                if hot_streak( firestarter.active ) and talent.kindling.enabled then
                    setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
                end

                applyDebuff( "target", "ignite" )
                if active_dot.ignite < active_enemies then active_dot.ignite = active_enemies end
            end,
        },


        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            discipline = "arcane",

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
            cast = function () return ( buff.hot_streak.up or buff.firestorm.up ) and 0 or 4.5 * haste end,
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
                if hardcast then
                    removeStack( "pyroclasm" )
                    if buff.sun_kings_blessing_ready.up then applyBuff( "combustion", 5 ) end
                else
                    if buff.hot_streak.up then
                        if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                        else removeBuff( "hot_streak" ) end
                        if legendary.sun_kings_blessing.enabled then
                            addStack( "sun_kings_blessing", nil, 1 )
                            if buff.sun_kings_blessing.stack == 12 then
                                removeBuff( "sun_kings_blessing" )
                                applyBuff( "sun_kings_blessing_ready" )
                            end
                        end
                    end
                end

                removeBuff( "molten_skyfall_ready" )
            end,

            velocity = 35,

            impact = function ()
                if hot_streak( firestarter.active or buff.firestorm.up ) then
                    if talent.kindling.enabled then
                        setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
                    end

                end

                if legendary.molten_skyfall.enabled and buff.molten_skyfall_ready.down then
                    addStack( "molten_skyfall" )
                    if buff.molten_skyfall.stack == 25 then
                        removeBuff( "molten_skyfall" )
                        applyBuff( "molten_skyfall_ready" )
                    end
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

            discipline = "arcane",

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

            discipline = "frost",

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

            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

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

            discipline = "arcane",

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


    spec:RegisterPack( "Fire", 20201016, [[d8eYScqivepcskUKOQQSjk4tuukJsuXPOOAvIQIxPcAwuKUfffTlu9lvuggjWXevzzQOYZurvttuvLRrrHTjQQ4BqsvnokkPohKuX6GKQmpij3JeTpvKoifLklufQhcjLMifLQCrsqv2ijO8rkkjgjKuPtkQQQwPOsVKIssZKIs4MuuI2PkWpjbvAOIQk1sjbv4PIYuvHCvsqv9vrvLmwkkv1ELYFP0GH6WelwKhJYKH4YiBwIpdPgTu50cRMeurVMeA2K62Q0Uv63kgojDCsqwUQEoOPt11L02PqFxQQXtrCEiX6fvLMVuL9dClV2rTmeXP2bNtbNtb5PG8Yp88oVzG6Fou)wMJIk1YufMIcAQLTYLAzkS4PwMQGIEeK2rTm4uFg1Y6CxfI6D2zOdVRM4S5EgmUvT4XSSxk(zW4YoRLLQH2Z)3wQLHio1o4Ck4CkipfKx(HN35ndu)ZL)Azs17MVLLfxuBlRlqqOTLAzieK1YqnaSclEcGnlf0eixuda35Uke17SZqhExnXzZ9myCRAXJzzVu8ZGXLDgixudaRWL5tIEaoV8JPa85uW5uqlthqh2oQLHqfPQ92rTdYRDulJwjPjK2XTm2ho9H0YobG)6sL5rtCKaYcvDSYJILn3RSiCsHQHQkH0YeMhZ2YytDD6HQKw382bNRDulJwjPjK2XTSrTLbjVLjmpMTLzu(qsAQLzu0vQL5IMwNxINGU8o9CALKMqa48bGlXtqxENE(txjwiaFiaNdaZMrJm9xoBUPk0Jz5pDLyHaC(aW5aW5bWMjaBu(qsAIRySi6yrBFcPY8ywaoFayx006CfJfrhlAoTsstiaS5aS5aC(aWNaWSz0it)LZMBQc9yw(tcckaC(aWPAPWzZnvHEmlhz6VTmJYBx5sTmpUK1hlBUPk0JzBE7GZ3oQLrRK0es74wg7dN(qAzPAPWzZnvHEmlhz6VaSbaovlf(xxYofR60NEoY0FbydamBgnY0F5S5MQqpML)0vIfcWNcWkaGnaW5aWSz0it)L)1LStXQo9PN)0vIfcWNcWkaG71dGpbGDrtRZ)6s2PyvN(0ZPvsAcbGnVLjmpMTLb7IIhlAR60N(M3oi)1oQLrRK0es74wg7dN(qAz5aWPAPWzZnvHEmlhz6VaSbaovlf(xxYofR60NEoY0FbydaCoamBgnY0F5S5MQqpML)0vIfcWOcGjtiw1jRhxcG71dGzZOrM(lNn3uf6XS8NUsSqa(uaMnJgz6V8xqczDluvEf5i1x8ywa2Ca2CaUxpaohaovlf(xxYofR60NEEvfGnaWSz0it)LZMBQc9yw(txjwiaFkaFEfaWM3YeMhZ2YEbjK1Tqv5vS5TdmJ2rTmALKMqAh3YyF40hsllvlfoBUPk0Jz5it)fGnaWPAPW)6s2PyvN(0ZrM(laBaGzZOrM(lNn3uf6XS8NUsSqagvamzcXQoz94sTmH5XSTmes8U08l182b5N2rTmALKMqAh3YyF40hsllvlfoBUPk0Jz5it)fGnaWiuQwk8xqczDluvEfTgR6LEjf6WrHJm93wMW8y2w2n(FEBCf0uZBhG63oQLrRK0es74wMW8y2wMKVWo5fOTmRBNIvD6tFlJ9HtFiTmJYhsstCpUK1hlBUPk0JzbyuPeGnda(qaopZaGZha2O8HK0eVmRBrMAst2zTvibWgayJYhsstCpUK1hlBUPk0Jzb4tbyf0Yw5sTmjFHDYlqBzw3ofR60N(M3oWSUDulJwjPjK2XTm2ho9H0YYbGnkFijnX94swFSS5MQqpMfGrfaNNca4E9a4sGUZTpDLyHamQayJYhsstCpUK1hlBUPk0JzbyZBzcZJzBzORYJeYANIvYx6hVR5TdqDAh1YeMhZ2YyZYO1FXjeBrlxQLrRK0es74M3oipf0oQLjmpMTL9KOglABrlxc2YOvsAcPDCZBhKxETJAzcZJzBzLHvHeIvYx6dNSjsUTmALKMqAh382b5DU2rTmH5XSTm16hfuIfTnPfO3YOvsAcPDCZBhK35Bh1YeMhZ2Y(qvvt2yTqvHrTmALKMqAh382b5L)Ah1YeMhZ2Y8oYw30uxeBzEg1YOvsAcPDCZBhKNz0oQLrRK0es74wg7dN(qAzFDPY8OjosazHQow5rXYM7vweoPq1qvLqaydamBgnY0F5PAPyrcilu1Xkpkw2CVYIWFsqqbGnaWPAPWrcilu1Xkpkw2CVYIyLNjlXrM(laBaGzZOrM(lNn3uf6XS8NUsSqa(ua(8kaGnaWNaWPAPWrcilu1Xkpkw2CVYIWRQTmH5XSTm2uxNEOkP1nVDqE5N2rTmALKMqAh3YyF40hsl7RlvMhnXrcilu1Xkpkw2CVYIWjfQgQQecaBaGzZOrM(lpvlflsazHQow5rXYM7vwe(tcckaSbaovlfosazHQow5rXYM7vweR8mzjoY0FbydamBgnY0F5S5MQqpML)0vIfcWNcWNxbaSba(eaovlfosazHQow5rXYM7vweEvTLjmpMTLjptwYsMOQhymBZBhKhQF7OwgTsstiTJBzSpC6dPL91LkZJM4ibKfQ6yLhflBUxzr4KcvdvvcbGnaWSz0it)LNQLIfjGSqvhR8OyzZ9klc)jbbfa2aaNQLchjGSqvhR8OyzZ9klIT8d05it)fGnaWSz0it)LZMBQc9yw(txjwiaFkaFEfaWga4ta4uTu4ibKfQ6yLhflBUxzr4v1wMW8y2ww5hONgT382b5zw3oQLrRK0es74wg7dN(qAzPAPW)6s2PyvN(0ZrM(laBaGZbGnkFijnX94swFSS5MQqpMfGpfGt1sH)1LStXQo9PNJuFXJzbydaSr5djPjUhxY6JLn3uf6XSa8PaSW8ywEjEYM0c05LQwBFI1jpAY6XLa4E9ayJYhsstCpUK1hlBUPk0Jzb4tb4sGUZTpDLyHaS5TmH5XSTSVUKDkw1Pp9nVDqEOoTJAz0kjnH0oULX(WPpKw2jaSr5djPjosaLKMSS5MQqpMfGnaWgLpKKM4ECjRpw2CtvOhZcWOsjaRGwMW8y2wgt0ARW8ywRoGElthq3UYLAzS5MQqpM1Q2jqQ5TdoNcAh1YOvsAcPDClBuBzqYBzcZJzBzgLpKKMAzgfDLAzNaWgLpKKM4ibusAYYMBQc9ywa2aaBu(qsAI7XLS(yzZnvHEmlaJkawyEmlVepztAb68svRTpX6Khnz94saSzcWgLpKKM4WUO4XI2Qo9P3(esL5XSaC(aW5aWSz0it)Ld7IIhlAR60NE(txjwiaJka2O8HK0e3Jlz9XYMBQc9ywa2Ca2aaBu(qsAI7XLS(yzZnvHEmlaJkaUeO7C7txjwia3Rha)1LkZJM4W6Avmw0qBstqySO5KcvdvvcbGnaWcZJz5L4jBslqNZ6KhnbTLxyEmRObyubWcZJz5L4jBslqNFftSSo5rtqa2mbyfWnda2aaNdaZMrJm9xoSlkESOTQtF65pDLyHa8PaCEMba3RhaFcaZgJ0kRZ3aDNBlcbWM3YmkVDLl1YkXt2KwGUvDgDSOBE7GZLx7OwgTsstiTJBzSpC6dPLLQLc)RlzNIvD6tpVQcWga4CayJYhsstCpUK1hlBUPk0Jzb4tbyfaWM3YeMhZ2YyIwBfMhZA1b0Bz6a62vUul7hvRANaPM3o4CNRDulJwjPjK2XTSrTLbjVLjmpMTLzu(qsAQLzu0vQLDcaBu(qsAIJeqjPjlBUPk0JzbydaSr5djPjUhxY6JLn3uf6XSamQayH5XSC1UH2WeBrlxcYlvT2(eRtE0K1JlbWgayJYhsstCpUK1hlBUPk0JzbyubWLaDNBF6kXcb4E9a4VUuzE0ehwxRIXIgAtAccJfnNuOAOQsiTmJYBx5sTm1UH2WeR6m6yr382bN78TJAz0kjnH0oULvHKTFxOjltGESOBhKxlJ9HtFiTStayJYhsst8s8KnPfOBvNrhlAa2aaNdaBu(qsAI7XLS(yzZnvHEmlaFkaRaa2Ca2aaNdalmpmswAPBqqa(uLaSr5djPjEN8iwMaDBrlxc6FOibWga4CaypUeaBMaCQwkC2CtvOhZY1c0TKjQXta8PaSr5djPjocPfuSfTCjO)HIeaBoaBoaBaGpbGlXtqxENEUW8WibWga4ta4uTu4DJBH(tII8NeM3YQqYoLIfndPDqETmH5XSTSs8KnPfO382bNl)1oQLrRK0es74wwfs2(DHMSmb6XIUDqETm2ho9H0YkXtqxENEUW8WibWgaywN8OjiaFQsaopa2aaFcaBu(qsAIxINSjTaDR6m6yrdWga4Ca4tayH5XS8s8us0AozcXQESObyda8jaSW8ywUkk)K0c05XAl6aDNdWga4uTu4DK4XI2wv5pjmhG71dGfMhZYlXtjrR5KjeR6XIgGnaWNaWPAPW7g3c9Nef5pjmhG71dGfMhZYvr5NKwGopwBrhO7Ca2aaNQLcVJepw02Qk)jH5aSba(eaovlfE34wO)KOi)jH5aS5TSkKStPyrZqAhKxltyEmBlRepztAb6nVDW5mJ2rTmALKMqAh3YyF40hsllha2O8HK0e3Jlz9XYMBQc9ywa(uawbaS5aSbaovlf(xxYofR60NEoY0FBzcZJzBzmrRTcZJzT6a6TmDaD7kxQLbDzrKhX(JlEmBZBEl7hvRANaP2rTdYRDulJwjPjK2XTm2ho9H0YYbGfMhgjlT0niiaFQsa2O8HK0eVBCl0Fsu0w0YLG(hksaSbaoha2JlbWMjaNQLcNn3uf6XSCTaDlzIA8eaFkaBu(qsAIJqAbfBrlxc6FOibW96bWgLpKKM4ibusAYYMBQc9ywa2Ca2Ca2aaNdaNQLcVBCl0FsuK)KWCaUxpaovlfEjEc6ZF5pjmhGnVLjmpMTLv0YLG(hksnVDW5Ah1YOvsAcPDClJ9HtFiTSuTu4W6Avmw0qBstqySOTpjiOWRQaSbaovlfoSUwfJfn0M0eeglA7tcck8NUsSqa(uaMjq36XLAzcZJzBzQO8tslqV5TdoF7OwgTsstiTJBzSpC6dPLLQLcVepb95V8NeM3YeMhZ2Yur5NKwGEZBhK)Ah1YOvsAcPDClJ9HtFiTSuTu4DJBH(tII8NeM3YeMhZ2Yur5NKwGEZBhygTJAz0kjnH0oULvHKTFxOjltGESOBhKxlJ9HtFiTSuTu4W6Avmw0qBstqySOTpjiOWrM(laBaGpbGZbGfMhgjlT0niiaFQsa2O8HK0eVtEeltGUTOLlb9puKaydaCoaShxcGntaovlfoBUPk0Jz5Ab6wYe14ja(ua2O8HK0ehH0ck2IwUe0)qrcGnhGnhGnaWNaWL4jOlVtpxyEyKaydaCoa8jaCQwk8os8yrBRQ8NeMdWga4ta4uTu4DJBH(tII8NeMdWga4tay1NmANsXIMHWlXt2KwGoaBaGZbGfMhZYlXt2KwGoN1jpAccWNQeGpha3RhaNda7IMwNlAYeO)cmFfOTuFu40kjnHaWgay2mAKP)YrEb9SqB6jX74pjiOaWMdW96bW5aWUOP15qs(yrB9PY640kjnHaWgayxE0KZ7ir7DCvMdWOsjaFEfaWMdWMdWM3YQqYoLIfndPDqETmH5XSTSs8KnPfO382b5N2rTmALKMqAh3YQqY2Vl0KLjqpw0TdYRLX(WPpKw2jaCjEc6Y70ZfMhgja2aaNdaNdaNdalmpMLxINsIwZjtiw1Jfna3RhalmpMLRIYpjTaDozcXQESObyZbydaCQwk8os8yrBRQ8NeMdWMdW96bW5aWUOP15qs(yrB9PY640kjnHaWgayxE0KZ7ir7DCvMdWOsjaFEfaWga4Ca4uTu4DK4XI2wv5pjmhGnaWNaWcZJz5q28SoozcXQESOb4E9a4ta4uTu4DJBH(tII8NeMdWga4ta4uTu4DK4XI2wv5pjmhGnaWcZJz5q28SoozcXQESObyda8jaC34wO)KOOfQsAn0gRTOd0DoaBoaBoaBElRcj7ukw0mK2b51YeMhZ2YkXt2KwGEZBhG63oQLrRK0es74wMW8y2wgt0ARW8ywRoGElthq3UYLAzcZdJK1fnToS5TdmRBh1YOvsAcPDClJ9HtFiTSuTu4QO8dtlWl)jH5aSbaMjq36XLayubWPAPWvr5hMwGx(txjwiaBaGzc0TECjagvaCQwk8VUKDkw1Pp98NUsSqa2aaNdaNQLcxfLFyAbE5pjmhGvcWPAPWvr5hMwGx(vmXcDHPia3RhaNQLcxfLFyAbE5pDLyHamQayMaDRhxcGpeGfMhZYlXtjrR5KjeR6K1JlbW96bWPAPWfnzc0FbMVc0wQpk8Qka3RhaFca)1LkZJM4W6Avmw0qBstqySO5KcvdvvcbGnVLjmpMTLPIYpjTa9M3oa1PDulJwjPjK2XTm2ho9H0YuFYOfndHNhhYMN1bWga4uTu4DK4XI2wv5pjmhGnaWUOP15qs(yrB9PY640kjnHaWgayxE0KZ7ir7DCvMdWOsjaFEfaWga4ta4CayH5HrYslDdccWNQeGnkFijnX7g3c9NefTfTCjO)HIeaBaGZbG94saSzcWPAPWzZnvHEmlxlq3sMOgpbWNcWgLpKKM4iKwqXw0YLG(hksaS5aS5TmH5XSTmvu(jPfO382b5PG2rTmALKMqAh3YyF40hsl7ea2O8HK0exTBOnmXQoJow0aSbaovlfEhjESOTvv(tcZbyda8jaCQwk8UXTq)jrr(tcZbydaCoaSW8WizrgNhO3Wjagva85a4E9ayH5HrYslDdccWNQeGnkFijnX7KhXYeOBlA5sq)dfjaUxpawyEyKS0s3GGa8PkbyJYhsst8UXTq)jrrBrlxc6FOibWM3YeMhZ2Yu7gAdtSfTCjyZBhKxETJAz0kjnH0oULX(WPpKwMlpAY5DKO9oUkZbyuPeGpVcaydaSlAADoKKpw0wFQSooTsstiTmH5XSTmiBEwxZBhK35Ah1YOvsAcPDClJ9HtFiTmH5HrYslDdccWNQeGnkFijnXLNjlzjtu1dmMfGnaWxzfUkZb4tvcWgLpKKM4YZKLSKjQ6bgZAVYkTmH5XSTm5zYswYev9aJzBE7G8oF7OwgTsstiTJBzSpC6dPLLdalmpmswAPBqqa(uLaSr5djPjEN8iwMaDBrlxc6FOibWga4CaypUeaBMaCQwkC2CtvOhZY1c0TKjQXta8PaSr5djPjocPfuSfTCjO)HIeaBoaBEltyEmBlROLlb9puKAE7G8YFTJAzcZJzBzL4PKO1TmALKMqAh38M3YyZnvHEmRvTtGu7O2b51oQLrRK0es74wg7dN(qAzPAPWzZnvHEmlhz6VTmH5XSTmDGUZHwfoRiOV06nVDW5Ah1YOvsAcPDClBuBzqYBzcZJzBzgLpKKMAzgfDLAzPAPWzZnvHEml)PReleGpeGt1sHZMBQc9ywos9fpMfGZhaohaMnJgz6VC2CtvOhZYF6kXcbyubWPAPWzZnvHEml)PReleGnVLzuE7kxQLrM40Iqiw2CtvOhZAF6kXcBE7GZ3oQLrRK0es74w2O2YeeKwMW8y2wMr5djPPwMrrxPwMz0YyF40hsllvlfoSUwfJfn0M0eeglA7tcck8Qka3RhaBu(qsAItM40Iqiw2CtvOhZAF6kXcb4tb484MbaNpamAgc)kMaW5daNdaNQLchwxRIXIgAtAccJfn)kMyHUWueGntaovlfoSUwfJfn0M0eeglAo0fMIaS5TmJYBx5sTmYeNwecXYMBQc9yw7txjwyZBhK)Ah1YOvsAcPDClJ9HtFiTSuTu4S5MQqpMLJm93wMW8y2wwsqBNI1)GPiS5TdmJ2rTmALKMqAh3YyF40hsltyEyKS0s3GGa8PaCEaSbaovlfoBUPk0Jz5it)TLjmpMTLPdJXI2MMBQ5TdYpTJAz0kjnH0oULX(WPpKwwQwkC2CtvOhZYrM(laBaGt1sH)1LStXQo9PNJm93wMW8y2w2n(FEODkwF(lTEZBhG63oQLrRK0es74wMW8y2wwhkQ07Dpji2(Fa9(VOcBzSpC6dPLLQLcNn3uf6XS8QkaBaGfMhZYlXt2KwGoN1jpAccWkbyfaWgayH5XS8s8KnPfOZFI1jpAY6XLa4tby0me(vmPLTYLAzDOOsV39KGy7)b07)IkS5TdmRBh1YeMhZ2Ys6zqStX6DKLw6IslJwjPjK2XnVDaQt7OwMW8y2w2LUZJIDkwDLfiwKNKlSLrRK0es74M3oipf0oQLjmpMTL1FEnIrkw7tWzLLrTmALKMqAh382b5Lx7OwgTsstiTJBzviz73fAYYeOhl62b51YyF40hsltYx6dN4jTaD6Txb60ZPvsAcbGnaWSo5rtqa(uLaCEaSbaohaohawyEmlVepztAb6CwN8OjOT8cZJzfnaFiaNdaNQLcNn3uf6XS8NUsSqa2mb4uTu4jTaD6Txb60ZrQV4XSaS5a8zamBgnY0F5L4jBslqNJuFXJzbyZeGZbGt1sHZMBQc9yw(txjwiaBoaFgaNdaNQLcpPfOtV9kqNEos9fpMfGntawbCZaGnhGnhGpvjaRaaUxpa(eawYx6dN4jTaD6Txb60ZPvsAcbG71dGpbGDrtRZlA5s2z50kjnHaW96bWPAPWzZnvHEml)PReleGrLsaovlfEslqNE7vGo9CK6lEmla3RhaNQLcpPfOtV9kqNE(txjwiaJkawbCZaG71dGjfQgQQecVdfv69UNeeB)pGE)xuHaSbaMnJgz6V8ouuP37EsqS9)a69FrfApVcuqE5VZXF6kXcbyubWMbaBoaBaGt1sHZMBQc9ywEvfGnaW5aWNaWcZJz5q28SoozcXQESObyda8jaSW8ywUkk)K0c05XAl6aDNdWga4uTu4DK4XI2wv5vvaUxpawyEmlhYMN1Xjtiw1JfnaBaGt1sH3nUf6pjkYrM(laBaGZbGt1sH3rIhlABvLJm9xaUxpawYx6dN4jTaD6Txb60ZPvsAcbGnhG71dGL8L(WjEslqNE7vGo9CALKMqaydaSlAADErlxYolNwjPjea2aalmpMLRIYpjTaDES2Ioq35aSbaovlfEhjESOTvvoY0FbydaCQwk8UXTq)jrroY0FbyZBzvizNsXIMH0oiVwMW8y2wwjEYM0c0BE7G8ox7OwgTsstiTJBzviz73fAYYeOhl62b51YyF40hsl7eawYx6dN4jTaD6Txb60ZPvsAcbGnaW5aWcZdJKLw6geeGrLsawyEyKSiJZd0B4ea3RhaFcaZMrJm9xUA3qByITOLlb5pjiOaWMdWgay2Si1W5XwOFfTLjqMGqCALKMqaydamRtE0eeGpvjaNhaBaGZbGZbGfMhZYlXt2KwGoN1jpAcAlVW8ywrdWhcW5aWgLpKKM4KjoTieILn3uf6XS2NUsSqa2mb4uTu4XwOFfTLjqMGqCK6lEmlaBoaFgaZMrJm9xEjEYM0c05i1x8ywa2mbyJYhsstCYeNwecXYMBQc9yw7txjwiaFgaNdaNQLcp2c9ROTmbYeeIJuFXJzbyZeGva3mayZbyZb4tvcWkaG71dGnkFijnXjtCArielBUPk0JzTpDLyHamQucWPAPWJTq)kAltGmbH4i1x8ywaUxpaovlfESf6xrBzcKjie)PReleGrfaRaUzaWMdWga4uTu4S5MQqpMLxvbyda8jaCQwk8s8e0N)YFsyoaBaGpbGt1sH3nUf6pjkYFsyoaBaG7g3c9NefTqvsRH2yTfDGUZb4db4uTu4DK4XI2wv5pjmhGrfaFUwwfs2PuSOziTdYRLjmpMTLvINSjTa9M3oiVZ3oQLrRK0es74wwfs2(DHMSmb6XIUDqETm2ho9H0YobGL8L(WjEslqNE7vGo9CALKMqaydaCoaSW8WizPLUbbbyuPeGfMhgjlY48a9gobW96bWNaWSz0it)LR2n0gMylA5sq(tcckaS5aSba(eaMnlsnCESf6xrBzcKjieNwjPjea2aaZ6Khnbb4tvcW5bWga4uTu4S5MQqpMLxvbyda8jaCQwk8s8e0N)YFsyoaBaGpbGt1sH3nUf6pjkYFsyoaBaG7g3c9NefTqvsRH2yTfDGUZb4db4uTu4DK4XI2wv5pjmhGrfaFUwwfs2PuSOziTdYRLjmpMTLvINSjTa9M3oiV8x7OwgTsstiTJBzSpC6dPL91LkZJM4ibKfQ6yLhflBUxzr4KcvdvvcbGnaWPAPWrcilu1Xkpkw2CVYIWrM(laBaGt1sHJeqwOQJvEuSS5ELfXkptwIJm9xa2aaZMrJm9xEQwkwKaYcvDSYJILn3RSi8NeeuAzcZJzBzSPUo9qvsRBE7G8mJ2rTmALKMqAh3YyF40hsl7RlvMhnXrcilu1Xkpkw2CVYIWjfQgQQecaBaGt1sHJeqwOQJvEuSS5ELfHJm9xa2aaNQLchjGSqvhR8OyzZ9klIvEMSehz6VaSbaMnJgz6V8uTuSibKfQ6yLhflBUxzr4pjiO0YeMhZ2YKNjlzjtu1dmMT5TdYl)0oQLrRK0es74wg7dN(qAzFDPY8OjosazHQow5rXYM7vweoPq1qvLqaydaCQwkCKaYcvDSYJILn3RSiCKP)cWga4uTu4ibKfQ6yLhflBUxzrSLFGohz6VTmH5XSTSYpqpnAV5TdYd1VDulJwjPjK2XTmH5XSTmMO1wH5XSwDa9wMoGUDLl1YeMhgjRlAADyZBhKNzD7OwgTsstiTJBzviz73fAYYeOhl62b51YyF40hsllvlfoBUPk0Jz5it)fGnaW5aWFDPY8OjosazHQow5rXYM7vweoPq1qvLqayLaCQwkCKaYcvDSYJILn3RSi8QkaBoaBaGZbGfMhZYVKtZZJ1w0b6ohGnaWcZJz5xYP55XAl6aDNBF6kXcbyuPeGva3ma4E9ayH5XSCiBEwhNmHyvpw0aSbawyEmlhYMN1Xjtiw1j7txjwiaJkawbCZaG71dGfMhZYlXtjrR5KjeR6XIgGnaWcZJz5L4PKO1CYeIvDY(0vIfcWOcGva3ma4E9ayH5XSCvu(jPfOZjtiw1JfnaBaGfMhZYvr5NKwGoNmHyvNSpDLyHamQayfWnda28wwfs2PuSOziTdYRLjmpMTLXMBQc9y2M3oipuN2rTmALKMqAh3YyF40hsllvlfoBUPk0Jz5Ab6wYe14jagvkbyH5XSC2CtvOhZY1c0TviH0YeMhZ2YuhpMT5TdoNcAh1YOvsAcPDClJ9HtFiTSuTu4S5MQqpMLRfOBjtuJNayuPeGfMhZYzZnvHEmlxlq3wHesltyEmBllPNbXwQpknVDW5YRDulJwjPjK2XTm2ho9H0Ys1sHZMBQc9ywUwGULmrnEcGrLsawyEmlNn3uf6XSCTaDBfsiTmH5XSTSe9q6vmw0nVDW5ox7OwgTsstiTJBzSpC6dPLLQLcNn3uf6XSCTaDlzIA8eaJkLaSW8ywoBUPk0Jz5Ab62kKqAzcZJzBzL4PKEgKM3o4CNVDulJwjPjK2XTm2ho9H0Ys1sHZMBQc9ywUwGULmrnEcGrLsawyEmlNn3uf6XSCTaDBfsiTmH5XSTmzze0FrBzIw382bNl)1oQLrRK0es74wg7dN(qAzPAPWzZnvHEmlxlq3sMOgpbWOsjalmpMLZMBQc9ywUwGUTcjKwMW8y2wwfs2WPlS5TdoNz0oQLrRK0es74wg7dN(qAzFDPY8OjUtx15fTTV8QCsHQHQkHaWga4uTu4S5MQqpMLRfOBjtuJNayuPeGfMhZYzZnvHEmlxlq3wHecaBaGZbGHJEa4E9a4uTu4KjDsf6XS8QkaBEltyEmBlZJlz7lVAZBhCU8t7OwgTsstiTJBzSpC6dPLLdaNQLcVBCl0FsuK)KWCaUxpaovlfEjEc6ZF5pjmhGnhGnaWcZdJKLw6geeGpvjaBu(qsAIZMBQc9ywBrlxc6FOi1YeMhZ2YkA5sq)dfPM3o4CO(TJAz0kjnH0oULX(WPpKwwQwkCyDTkglAOnPjimw02Neeu4vva2aaNQLchwxRIXIgAtAccJfT9jbbf(txjwiaFkaZeOB94sTmH5XSTmvu(jPfO382bNZSUDulJwjPjK2XTm2ho9H0Ys1sHxING(8x(tcZBzcZJzBzQO8tslqV5TdohQt7OwgTsstiTJBzSpC6dPLLQLcxfLFyAbE5pjmhGnaWPAPWvr5hMwGx(txjwiaFkaZeOB94saSbaohaovlfoBUPk0Jz5pDLyHa8PamtGU1JlbW96bWPAPWzZnvHEmlhz6VaS5TmH5XSTmvu(jPfO382bNxbTJAz0kjnH0oULX(WPpKwwQwk8UXTq)jrr(tcZbydaCQwkC2CtvOhZYRQTmH5XSTmvu(jPfO382bNpV2rTmALKMqAh3YyF40hslt9jJw0meEECiBEwhaBaGt1sH3rIhlABvL)KW8wMW8y2wMkk)K0c0BE7GZFU2rTmALKMqAh3YyF40hsllvlfoBUPk0Jz5vva2aaNdaNdalmpMLxINSjTaDoRtE0eeGrfaNhaBaGDrtRZvr5hMwGxoTsstiaSbawyEyKS0s3GGaSsaopa2CaUxpa(ea2fnToxfLFyAbE50kjnHaW96bWcZdJKLw6geeGpfGZdGnVLjmpMTLP2n0gMylA5sWM3o48NVDulJwjPjK2XTm2ho9H0Ys1sHZMBQc9ywoY0FbydamBgnY0F5S5MQqpML)0vIfcWOcGzc0TECja2aaFcaZMfPgoVOLlzfg7jpMLtRK0esltyEmBlRepLeTU5TdoF(RDulJwjPjK2XTm2ho9H0Ys1sHZMBQc9yw(txjwiaFkaZeOB94saSbaovlfoBUPk0Jz5vvaUxpaovlfoBUPk0Jz5it)fGnaWSz0it)LZMBQc9yw(txjwiaJkaMjq36XLAzcZJzBzq28SUM3o48Mr7OwgTsstiTJBzSpC6dPLLQLcNn3uf6XS8NUsSqagvamAgc)kMaWgayH5HrYslDdccWNcW51YeMhZ2Y0HXyrBtZn182bNp)0oQLrRK0es74wg7dN(qAzPAPWzZnvHEml)PReleGrfaJMHWVIjaSbaovlfoBUPk0Jz5v1wMW8y2wgYlONfAtpjExZBhCEu)2rTmALKMqAh3YyF40hslZLhn58os0EhxL5amQucWNxbaSba2fnTohsYhlARpvwhNwjPjKwMW8y2wgKnpRR5nVLjmpmswx006W2rTdYRDulJwjPjK2XTm2ho9H0YeMhgjlT0niiaFkaNhaBaGt1sHZMBQc9ywoY0FbydaCoaSr5djPjUhxY6JLn3uf6XSa8PamBgnY0F56WySOTP5M4i1x8ywaUxpa2O8HK0e3Jlz9XYMBQc9ywagvkbyfaWM3YeMhZ2Y0HXyrBtZn182bNRDulJwjPjK2XTm2ho9H0YobGnkFijnXrcOK0KLn3uf6XSaSba2O8HK0e3Jlz9XYMBQc9ywagvkbyfaW96bW5aWSz0it)LFjNMNJuFXJzbyubWgLpKKM4ECjRpw2CtvOhZcWga4tayx0068VUKDkw1Pp9CALKMqayZb4E9ayx0068VUKDkw1Pp9CALKMqaydaCQwk8VUKDkw1Pp98QkaBaGnkFijnX94swFSS5MQqpMfGpfGfMhZYVKtZZzZOrM(la3Rhaxc0DU9PReleGrfaBu(qsAI7XLS(yzZnvHEmBltyEmBl7sonFZBhC(2rTmALKMqAh3YyF40hslZfnTox0Kjq)fy(kqBP(OWPvsAcbGnaW5aWPAPWzZnvHEmlhz6VaSba(eaovlfE34wO)KOi)jH5aS5TmH5XSTmKxqpl0MEs8UM38wg0LfrEe7pU4XSTJAhKx7OwgTsstiTJBzSpC6dPLLdalmpmswAPBqqa(uLaSr5djPjE34wO)KOOTOLlb9puKaydaCoaShxcGntaovlfoBUPk0Jz5Ab6wYe14ja(ua2O8HK0ehH0ck2IwUe0)qrcG71dGnkFijnXrcOK0KLn3uf6XSaS5aS5aSbaohaovlfE34wO)KOi)jH5aCVEaCQwk8s8e0N)YFsyoaBEltyEmBlROLlb9puKAE7GZ1oQLrRK0es74wg7dN(qAzPAPWlXtqF(l)jH5TmH5XSTmvu(jPfO382bNVDulJwjPjK2XTm2ho9H0Ys1sH3nUf6pjkYFsyoaBaGt1sH3nUf6pjkYF6kXcbyubWcZJz5L4PKO1CYeIvDY6XLAzcZJzBzQO8tslqV5TdYFTJAz0kjnH0oULX(WPpKwwQwk8UXTq)jrr(tcZbydaCoaS6tgTOzi884L4PKO1aCVEaCjEc6Y70ZfMhgjaUxpawyEmlxfLFsAb68yTfDGUZbyZBzcZJzBzQO8tslqV5TdmJ2rTmALKMqAh3YyF40hsllvlfoSUwfJfn0M0eeglA7tcck8QkaBaGZbGzZOrM(l)RlzNIvD6tp)PReleGpeGfMhZY)6s2PyvN(0Zjtiw1jRhxcGpeGzc0TECja(uaovlfoSUwfJfn0M0eeglA7tcck8NUsSqaUxpa(ea2fnTo)RlzNIvD6tpNwjPjea2Ca2aaBu(qsAI7XLS(yzZnvHEmlaFiaZeOB94sa8PaCQwkCyDTkglAOnPjimw02Neeu4pDLyHTmH5XSTmvu(jPfO382b5N2rTmALKMqAh3YyF40hsllvlfE34wO)KOi)jH5aSba2Lhn58os0EhxL5amQucWNxbaSba2fnTohsYhlARpvwhNwjPjKwMW8y2wMkk)K0c0BE7au)2rTmALKMqAh3YyF40hsllvlfUkk)W0c8YFsyoaBaGzc0TECjagvaCQwkCvu(HPf4L)0vIfcWga4Ca4uTu4QO8dtlWl)jH5aSsaovlfUkk)W0c8YVIjwOlmfb4E9a4uTu4QO8dtlWl)PReleGrfaZeOB94sa8HaSW8ywEjEkjAnNmHyvNSECjaUxpaovlfUOjtG(lW8vG2s9rHxvb4E9a4ta4VUuzE0ehwxRIXIgAtAccJfnNuOAOQsiaS5TmH5XSTmvu(jPfO382bM1TJAz0kjnH0oULvHKTFxOjltGESOBhKxlJ9HtFiTSta4s8e0L3PNlmpmsaSba(ea2O8HK0eVepztAb6w1z0XIgGnaW5aW5aW5aWcZJz5L4PKO1CYeIv9yrdW96bWcZJz5QO8tslqNtMqSQhlAa2Ca2aaNQLcVJepw02Qk)jH5aS5aCVEaCoaSlAADoKKpw0wFQSooTsstiaSba2Lhn58os0EhxL5amQucWNxbaSbaohaovlfEhjESOTvv(tcZbyda8jaSW8ywoKnpRJtMqSQhlAaUxpa(eaovlfE34wO)KOi)jH5aSba(eaovlfEhjESOTvv(tcZbydaSW8ywoKnpRJtMqSQhlAa2aaFca3nUf6pjkAHQKwdTXAl6aDNdWMdWMdWM3YQqYoLIfndPDqETmH5XSTSs8KnPfO382bOoTJAz0kjnH0oULX(WPpKwM6tgTOzi884q28Soa2aaNQLcVJepw02Qk)jH5aSba2fnTohsYhlARpvwhNwjPjea2aa7YJMCEhjAVJRYCagvkb4ZRaa2aaFcaNdalmpmswAPBqqa(uLaSr5djPjE34wO)KOOTOLlb9puKaydaCoaShxcGntaovlfoBUPk0Jz5Ab6wYe14ja(ua2O8HK0ehH0ck2IwUe0)qrcGnhGnVLjmpMTLPIYpjTa9M3oipf0oQLrRK0es74wg7dN(qAzNaWgLpKKM4QDdTHjw1z0XIgGnaW5aWNaWUOP15LFUwVJScSJGCALKMqa4E9ayH5HrYslDdccWNcW5bWMdWga4CayH5HrYslDdccWNcW5bWgayH5HrYImopqVHtamQa4ZbW96bWcZdJKLw6geeGpvjaBu(qsAI3jpILjq3w0YLG(hksaCVEaSW8WizPLUbbb4tvcWgLpKKM4DJBH(tII2IwUe0)qrcGnVLjmpMTLP2n0gMylA5sWM3oiV8Ah1YOvsAcPDCltyEmBlJjATvyEmRvhqVLPdOBx5sTmH5HrY6IMwh282b5DU2rTmALKMqAh3YyF40hsltyEyKS0s3GGa8PaCETmH5XSTmKxqpl0MEs8UM3oiVZ3oQLrRK0es74wg7dN(qAzU8OjN3rI274QmhGrLsa(8kaGnaWUOP15qs(yrB9PY640kjnH0YeMhZ2YGS5zDnVDqE5V2rTmALKMqAh3YyF40hsltyEyKS0s3GGa8PkbyJYhsstC5zYswYev9aJzbyda8vwHRYCa(uLaSr5djPjU8mzjlzIQEGXS2RSsltyEmBltEMSKLmrvpWy2M3oipZODulJwjPjK2XTm2ho9H0YeMhgjlT0niiaFQsa2O8HK0eVtEeltGUTOLlb9puKaydaCoaShxcGntaovlfoBUPk0Jz5Ab6wYe14ja(ua2O8HK0ehH0ck2IwUe0)qrcGnVLjmpMTLv0YLG(hksnVDqE5N2rTmH5XSTSs8us06wgTsstiTJBE7G8q9Bh1YeMhZ2YGS5zDTmALKMqAh38M3YuFIn3K4TJAhKx7OwMW8y2wM8mzjBSoP1eZBz0kjnH0oU5Tdox7OwgTsstiTJBzJAldsEltyEmBlZO8HK0ulZOORul7CaC(aWUOP15fTCjRQ4SooTsstia8Ha85b48bGpbGDrtRZlA5swvXzDCALKMqAzSpC6dPLzu(qsAI3nUf6pjkAlA5sq)dfjawjaRGwMr5TRCPww34wO)KOOTOLlb9puKAE7GZ3oQLrRK0es74w2O2YGK3YeMhZ2YmkFijn1Ymk6k1YohaNpaSlAADErlxYQkoRJtRK0ecaFiaFEaoFa4tayx0068IwUKvvCwhNwjPjKwg7dN(qAzgLpKKM4DYJyzc0TfTCjO)HIeaReGvqlZO82vUulRtEeltGUTOLlb9puKAE7G8x7OwgTsstiTJBzJAldsEltyEmBlZO8HK0ulZOORul78aC(aWUOP15fTCjRQ4SooTsstia8HaC(bGZha(ea2fnToVOLlzvfN1XPvsAcPLX(WPpKwMr5djPjoBUPk0JzTfTCjO)HIeaReGvqlZO82vUulJn3uf6XS2IwUe0)qrQ5TdmJ2rTmALKMqAh3Yg1wgK8wMW8y2wMr5djPPwMrrxPwgQdQdaNpaSlAADErlxYQkoRJtRK0ecaFiaFoaoFa4tayx0068IwUKvvCwhNwjPjKwg7dN(qAzgLpKKM4YZKLSKjQ6bgZcWkbyf0YmkVDLl1YKNjlzjtu1dmMT5TdYpTJAz0kjnH0oULnQTSNGK3YeMhZ2YmkFijn1YmkVDLl1YKNjlzjtu1dmM1ELvAziurQAVLL)uqZBhG63oQLrRK0es74w2O2YEcsEltyEmBlZO8HK0ulZO82vUuldH0ck2IwUe0)qrQLHqfPQ9wMcAE7aZ62rTmALKMqAh3Yg1w2tqYBzcZJzBzgLpKKMAzgL3UYLAzkglIow02NqQmpMTLHqfPQ9wMc4NR5TdqDAh1YOvsAcPDClBuBzqYBzcZJzBzgLpKKMAzgfDLAzcZJz5WUO4XI2Qo9PNZeOB94sa8zaSW8ywoSlkESOTQtF65EWu06XLa48bGpFlJ9HtFiTm2yKwzD(gO7CBrOwMr5TRCPwgSlkESOTQtF6TpHuzEmBZBhKNcAh1YOvsAcPDClBuBzqYBzcZJzBzgLpKKMAzgfDLAzKcvdvvcHFLnke0h7uSxbzjieG71dGjfQgQQechTwqcXNhAtccAcG71dGjfQgQQechTwqcXNhAVeIO1XSaCVEamPq1qvLq4b6n8yw7vqtqBPcjaUxpaMuOAOQsiCpFLLG2K8kcvJLGaCVEamPq1qvLq4s(wFY7gOfglAcXQQRxbnbW96bWKcvdvvcHlllO1TkUJBNITFarMla3RhatkunuvjeoSBykMcNEOTilAaUxpaMuOAOQsi8LQVOTquwrfswA7KLrpa3RhatkunuvjeEs0ujEYMEzzDTmJYBx5sTm2CtvOhZAN1wHuZBhKxETJAz0kjnH0oULnQTmi5TmH5XSTmJYhsstTmJIUsTmsHQHQkHWL8f2jVaTLzD7uSQtF6bydaSr5djPjoBUPk0JzTZARqQLzuE7kxQLvM1TitnPj7S2kKAE7G8ox7OwgTsstiTJBzJAldsEltyEmBlZO8HK0ulZOORullpZ6wg7dN(qAzgLpKKM4LzDlYutAYoRTcja2aaFca7IMwNxINGU8o9CALKMqaydaSr5djPjEzw3ofR60NER6tS5Me3Y6KDjnaReGvqlZO82vUulRmRBNIvD6tVv9j2CtIBzDYUKU5TdY78TJAz0kjnH0oU5TdYl)1oQLrRK0es74w2kxQLj5lStEbAlZ62PyvN(03YeMhZ2YK8f2jVaTLzD7uSQtF6BE7G8mJ2rTmH5XSTSB8)824kOPwgTsstiTJBE7G8YpTJAzcZJzBzQO8tslqVLrRK0es74M38M3YmspmMTDW5uW5uqEkiVZ3Y6l)glAyll)YStHJdY)pWScQhadWh1raCCvN3b4Y8aSzdHksv7Mna(jfQgpHaWW5saSu95koHaWSozrtqoixZIyja(Cka1dGrTZAKENqayZgBmsRSo3SpNwjPjeZga7daB2yJrAL15M9nBaCo5zI5CqUGCZVm7u44G8)dmRG6bWa8rDeahx15DaUmpaB2uFIn3K4Mna(jfQgpHaWW5saSu95koHaWSozrtqoixZIyjag1b1dGrTZAKENqa4S4IAbyikRlMaW5FaSpaSzrvayKWyaJzb4rLEXNhGZ5mZb4CYZeZ5GCnlILayuhupag1oRr6DcbGnBSXiTY6CZ(CALKMqmBaSpaSzJngPvwNB23SbW5KNjMZb5cYn)YStHJdY)pWScQhadWh1raCCvN3b4Y8aSzJn3uf6XSw1obsMna(jfQgpHaWW5saSu95koHaWSozrtqoixZIyjaoV8q9ayu7SgP3jeaolUOwagIY6IjaC(ha7daBwufagjmgWywaEuPx85b4CoZCaoNZzI5CqUMfXsaCENd1dGrTZAKENqa4S4IAbyikRlMaW5FaSpaSzrvayKWyaJzb4rLEXNhGZ5mZb4CoNjMZb5cYn))QoVtiaC(bGfMhZcW6a6qoi3wM6pLqtTmudaRWINayZsbnbYf1aWDURcr9o7m0H3vtC2Cpdg3Qw8yw2lf)myCzNbYf1aWkCz(KOhGZl)ykaFofCofaYfKlQbGrTDYIMGOEGCrnaSzcWk8Heaxc0DU9PReleGFX7OhG9ozbyxE0KZ94swFSibbWL5byTaDZesSzrayjf6WrbGRqbnb5GCrnaSzcWk8vreNay9Goya8tOEaSzrLfiaSzVNKlKdYf1aWMjaBwmdKwaMjqhGFsHQXtxADiaxMhGrTZnvHEmlaNtWjUPamYSMnhG7gncahoaxMhGfaU8eSdGnljNMhGzc0nNdYf1aWMjaB2lGsstaSSamT(Jca7DIdW9NQgbGFcw1oahlalaCN8imb6aC(nk)K0c0b4ynt0YL4GCrnaSzcWk8wjPjag6FWCaM1rmfJfnaplalaCH6dWL5vecWXcWEhbWMD53MfaSpa8tivgbW9Nxr9iiCqUGCrnaScptiw1jeaorL5jaMn3K4aCIqhlKdWMDmgP6qaEN1m7K)wQAawyEmleGNvJchKRW8ywix9j2CtIFOYZKNjlzJ1jTMyoixudaFuxabyJYhsstamuLyrjiia7DeaV1BIEaEkaSlpAYHaS4aC)UG1bWOUJdWz(tIIaSctlxc6FOibb4P6WaHa4PaWO25MQqpMfGHDtvJaWjcGRqcHdYvyEmlKR(eBUjXpu5zgLpKKMmDLlPSBCl0Fsu0w0YLG(hksMoQkHKBAuuAu(qsAI3nUf6pjkAlA5sq)dfjLkWuJIUskpx(4IMwNx0YLSQIZ640kjnHC45ZNtCrtRZlA5swvXzDCALKMqa5IAa4J6ciaBu(qsAcGHQelkbbbyVJa4TEt0dWtbGD5rtoeGfhG73fSoag1vEeag1kqhGvyA5sq)dfjiapvhgieapfag1o3uf6XSamSBQAeaoraCfsiaSab4sO10Zb5kmpMfYvFIn3K4hQ8mJYhsstMUYLu2jpILjq3w0YLG(hksMoQkHKBAuuAu(qsAI3jpILjq3w0YLG(hkskvGPgfDLuEU8XfnToVOLlzvfN1XPvsAc5WZNpN4IMwNx0YLSQIZ640kjnHaYf1aWh1fqa2O8HK0eadvjwucccWEhbWB9MOhGNca7YJMCialoa3VlyDamQ74aCM)KOiaRW0YLG(hksqawEcGRqcbGrQFSObyu7CtvOhZYb5kmpMfYvFIn3K4hQ8mJYhsstMUYLuYMBQc9ywBrlxc6FOiz6OQesUPrrPr5djPjoBUPk0JzTfTCjO)HIKsfyQrrxjLNpFCrtRZlA5swvXzDCALKMqom)KpN4IMwNx0YLSQIZ640kjnHaYf1aWh1fqa2O8HK0eadvjwucccWEhbWB9MOhGNca7YJMCialoa3VlyDaSz3ZKLayfEMOQhymlapvhgieapfag1o3uf6XSamSBQAeaoraCfsiCqUcZJzHC1NyZnj(HkpZO8HK0KPRCjLYZKLSKjQ6bgZA6OQesUPrrPr5djPjU8mzjlzIQEGXSkvGPgfDLuI6G6KpUOP15fTCjRQ4SooTsstihEU85ex0068IwUKvvCwhNwjPjeqUOga(OUacWgLpKKMayOkXIsqqa27iawLEgTUGMa4PaWxzfaor6Ppa3VlyDaSz3ZKLayfEMOQhymla3p0AaEhhGteaxHechKRW8ywix9j2CtIFOYZmkFijnz6kxsP8mzjlzIQEGXS2RSIPiurQAxz(tbMoQkFcsoixudaFuxabyJYhsstaCab4kKqayFayOkXIckaS3raSCN66a8uaypUeahladj2Siqa27ehGVvOdWQcecWsXPhGrTZnvHEmlatMOgpbb4evMNayfMwUe0)qrccW9dTgGteaxHecaVZFfTgfoixH5XSqU6tS5Me)qLNzu(qsAY0vUKseslOylA5sq)dfjtrOIu1Usfy6OQ8ji5GCrnaC(v4DaSz1yr0XI2uag1o3uf6XSMniaZMrJm9xaUFO1aCIa4NqQmcbGtOaWca)YImxawUtDDtb4u1byVJa4TEt0dWtbGzF4qag6Y7qa2i9OaWDb6oawko9aSW8WO4XIgGrTZnvHEmlallcad1tFiaJm9xa2N(YJabyVJayAra4PaWO25MQqpM1Sbby2mAKP)Yb48RoAb4ROySObyeIfWywiahla7DeaB2LFBwykaJANBQc9ywZgeGF6kXglAaMnJgz6VaCab4NqQmcbGtOaWExab4YlmpMfG9bGfgBQRdWL5byZQXIOJfnhKRW8ywix9j2CtIFOYZmkFijnz6kxsPIXIOJfT9jKkZJznfHksv7kva)CMoQkFcsoixH5XSqU6tS5Me)qLNzu(qsAY0vUKsyxu8yrBvN(0BFcPY8ywthvLqYn1OORKsH5XSCyxu8yrBvN(0Zzc0TECP8pH5XSCyxu8yrBvN(0Z9GPO1JlLpN30OOKngPvwNVb6o3weItRK0ecixH5XSqU6tS5Me)qLNzu(qsAY0vUKs2CtvOhZAN1wHKPJQsi5MAu0vsjPq1qvLq4xzJcb9Xof7vqwcc71JuOAOQsiC0AbjeFEOnjiOPE9ifQgQQechTwqcXNhAVeIO1XS96rkunuvjeEGEdpM1Ef0e0wQqQxpsHQHQkHW98vwcAtYRiunwc2RhPq1qvLq4s(wFY7gOfglAcXQQRxbn1RhPq1qvLq4YYcADRI742Py7hqK52RhPq1qvLq4WUHPykC6H2ISO71JuOAOQsi8LQVOTquwrfswA7KLrFVEKcvdvvcHNenvINSPxwwhixH5XSqU6tS5Me)qLNzu(qsAY0vUKYYSUfzQjnzN1wHKPJQsi5MAu0vsjPq1qvLq4s(c7KxG2YSUDkw1Pp9gmkFijnXzZnvHEmRDwBfsGCrna8rDbeGnkFijnbWiKt)nwccW97OfGn7YxyN8IzdcWkSzDaEkaC(90NEaoGaCfsiaCIkZtaS3raSAvRb4OaWPIWlZ62PyvN(0BvFIn3K4wwNSlPb4acW74amuLyrjieoixH5XSqU6tS5Me)qLNzu(qsAY0vUKYYSUDkw1Pp9w1NyZnjUL1j7sAthvLqYn1OORKY8mRnnkknkFijnXlZ6wKPM0KDwBfsgoXfnToVepbD5D650kjnHyWO8HK0eVmRBNIvD6tVv9j2CtIBzDYUKwPca5kmpMfYvFIn3K4hQ8m4kQWUXTqxCiixH5XSqU6tS5Me)qLNvHKnC6A6kxsPKVWo5fOTmRBNIvD6tpixH5XSqU6tS5Me)qLNDJ)N3gxbnbYvyEmlKR(eBUjXpu5zQO8tslqhKlixudaRWZeIvDcbGjJ0Jca7XLayVJayH5ZdWbeGfJsOLKM4GCfMhZcvYM660dvjT20OO8KVUuzE0ehjGSqvhR8OyzZ9klcNuOAOQsiGCfMhZcpu5zgLpKKMmDLlP0Jlz9XYMBQc9ywthvLqYn1OORKsx0068s8e0L3PNtRK0es(uINGU8o98NUsSWdZHnJgz6VC2CtvOhZYF6kXcZNCYZmnkFijnXvmweDSOTpHuzEmB(4IMwNRySi6yrZPvsAcXCZZNtyZOrM(lNn3uf6XS8NeeuYNuTu4S5MQqpMLJm9xqUcZJzHhQ8myxu8yrBvN(0BAuuMQLcNn3uf6XSCKP)Aivlf(xxYofR60NEoY0FnWMrJm9xoBUPk0Jz5pDLyHNQad5WMrJm9x(xxYofR60NE(txjw4PkOxVtCrtRZ)6s2PyvN(0ZPvsAcXCqUcZJzHhQ8SxqczDluvEfnnkkZjvlfoBUPk0Jz5it)1qQwk8VUKDkw1Pp9CKP)Aih2mAKP)YzZnvHEml)PRelevKjeR6K1Jl1RhBgnY0F5S5MQqpML)0vIfEkBgnY0F5VGeY6wOQ8kYrQV4XSMBEVE5KQLc)RlzNIvD6tpVQAGnJgz6VC2CtvOhZYF6kXcp98kWCqUcZJzHhQ8mes8U08lzAuuMQLcNn3uf6XSCKP)Aivlf(xxYofR60NEoY0FnWMrJm9xoBUPk0Jz5pDLyHOImHyvNSECjqUcZJzHhQ8SB8)824kOjtJIYuTu4S5MQqpMLJm9xdiuQwk8xqczDluvEfTgR6LEjf6WrHJm9xqUcZJzHhQ8SkKSHtxtx5skL8f2jVaTLzD7uSQtF6nnkknkFijnX94swFSS5MQqpMfvknJdZZmYhJYhsst8YSUfzQjnzN1wHKbJYhsstCpUK1hlBUPk0JzpvbGCfMhZcpu5zORYJeYANIvYx6hVZ0OOmhJYhsstCpUK1hlBUPk0JzrvEkOxVsGUZTpDLyHOYO8HK0e3Jlz9XYMBQc9ywZb5kmpMfEOYZyZYO1FXjeBrlxcKRW8yw4Hkp7jrnw02IwUeeKRW8yw4HkpRmSkKqSs(sF4KnrYfKRW8yw4HkptT(rbLyrBtAb6GCfMhZcpu5zFOQQjBSwOQWiqUcZJzHhQ8mVJS1nn1fXwMNrGCrnaSzfYbyVJayKaYcvDSYJILn3RSiaCQwkaCv1uaUUAccby2CtvOhZcWbeGHZSCqUcZJzHhQ8m2uxNEOkP1MgfLFDPY8OjosazHQow5rXYM7vweoPq1qvLqmWMrJm9xEQwkwKaYcvDSYJILn3RSi8NeeumKQLchjGSqvhR8OyzZ9klIvEMSehz6VgyZOrM(lNn3uf6XS8NUsSWtpVcmCsQwkCKaYcvDSYJILn3RSi8QkixH5XSWdvEM8mzjlzIQEGXSMgfLFDPY8OjosazHQow5rXYM7vweoPq1qvLqmWMrJm9xEQwkwKaYcvDSYJILn3RSi8NeeumKQLchjGSqvhR8OyzZ9klIvEMSehz6VgyZOrM(lNn3uf6XS8NUsSWtpVcmCsQwkCKaYcvDSYJILn3RSi8QkixH5XSWdvEw5hONgTBAuu(1LkZJM4ibKfQ6yLhflBUxzr4KcvdvvcXaBgnY0F5PAPyrcilu1Xkpkw2CVYIWFsqqXqQwkCKaYcvDSYJILn3RSi2YpqNJm9xdSz0it)LZMBQc9yw(txjw4PNxbgojvlfosazHQow5rXYM7vweEvfKRW8yw4Hkp7RlzNIvD6tVPrrzQwk8VUKDkw1Pp9CKP)AihJYhsstCpUK1hlBUPk0Jzpnvlf(xxYofR60NEos9fpM1Gr5djPjUhxY6JLn3uf6XSNkmpMLxINSjTaDEPQ12NyDYJMSECPE9mkFijnX94swFSS5MQqpM90sGUZTpDLyHMdYvyEml8qLNXeT2kmpM1QdOB6kxsjBUPk0JzTQDcKmnkkpXO8HK0ehjGsstw2CtvOhZAWO8HK0e3Jlz9XYMBQc9ywuPubGCrna8rkCn7PWf1dGpQJa48mdaEj5byVJayAra4PaWExaby2SiHhZcWbeGLfGLpf(lpkamBwKWJzb4Y8amRJykglAaokaCwxu8yrdW53tF6b4(HwdWjcGRQamCMLdWkSyraybGVZtaSWy1xCcG7lOaW(aWkUtFa27ehGZ6IIhlAao)E6tpa3p0Aaw9NKK0OaWjcGRqcbGtuzEcG9ocGZmREmaR(dJdYvyEml8qLNzu(qsAY0vUKYs8KnPfOBvNrhlAtnk6kP8eJYhsstCKakjnzzZnvHEmRbJYhsstCpUK1hlBUPk0JzrLW8ywEjEYM0c05LQwBFI1jpAY6XLmtJYhsstCyxu8yrBvN(0BFcPY8y28jh2mAKP)YHDrXJfTvD6tp)PRelevgLpKKM4ECjRpw2CtvOhZAUbJYhsstCpUK1hlBUPk0Jzrvjq352NUsSWE9(6sL5rtCyDTkglAOnPjimw0CsHQHQkHyqyEmlVepztAb6CwN8OjOT8cZJzfnQeMhZYlXt2KwGo)kMyzDYJMGMPc4MHHCyZOrM(lh2ffpw0w1Pp98NUsSWtZZm617e2yKwzD(gO7CBrioTsstiMdYvyEml8qLNXeT2kmpM1QdOB6kxs5pQw1obsMgfLPAPW)6s2PyvN(0ZRQgYXO8HK0e3Jlz9XYMBQc9y2tvG5GCfMhZcpu5zgLpKKMmDLlPuTBOnmXQoJow0MAu0vs5jgLpKKM4ibusAYYMBQc9ywdgLpKKM4ECjRpw2CtvOhZIkH5XSC1UH2WeBrlxcYlvT2(eRtE0K1JlzWO8HK0e3Jlz9XYMBQc9ywuvc0DU9PRelSxVVUuzE0ehwxRIXIgAtAccJfnNuOAOQsiGCrnaC(vhTamQR8imb6XIgGvyA5saCM)HIKPaSclEcGpwlqhcWWUPQra4ebWviHaW(aWOPLEXjag1DCaoZFsuecWYIaW(aWKjoTia8XAb60dWMLc0PNdYvyEml8qLNvINSjTaDtRqYoLIfndrzEMwHKTFxOjltGESOvMNPrr5jgLpKKM4L4jBslq3QoJow0gYXO8HK0e3Jlz9XYMBQc9y2tvG5gYryEyKS0s3GGNQ0O8HK0eVtEeltGUTOLlb9puKmKJhxYmt1sHZMBQc9ywUwGULmrnE6uJYhsstCeslOylA5sq)dfjZn3WjL4jOlVtpxyEyKmCsQwk8UXTq)jrr(tcZb5IAayZE1pw0aSclEc6Y70BkaRWINa4J1c0HaS8eaxHecadJBOLxJca7daJu)yrdWO25MQqpMLdWMvOLErRrXua27iuay5jaUcjea2hagnT0lobWOUJdWz(tIIqaUFhTam7dhcW9dTgG3Xb4ebW9fOtiaSSiaC)W7a4J1c0PhGnlfOtVPaS3rOaWWUPQra4ebWq1NeeaEQoa7daFLyDjwa27ia(yTaD6byZsb60dWPAPWb5kmpMfEOYZkXt2KwGUPvizNsXIMHOmptRqY2Vl0KLjqpw0kZZ0OOSepbD5D65cZdJKbwN8Oj4PkZZWjgLpKKM4L4jBslq3QoJow0gY5eH5XS8s8us0AozcXQESOnCIW8ywUkk)K0c05XAl6aDNBivlfEhjESOTvv(tcZ71tyEmlVepLeTMtMqSQhlAdNKQLcVBCl0FsuK)KW8E9eMhZYvr5NKwGopwBrhO7CdPAPW7iXJfTTQYFsyUHts1sH3nUf6pjkYFsyU5GCfMhZcpu5zmrRTcZJzT6a6MUYLucDzrKhX(JlEmRPrrzogLpKKM4ECjRpw2CtvOhZEQcm3qQwk8VUKDkw1Pp9CKP)cYfKRW8ywixyEyKSUOP1Hk1HXyrBtZnzAuukmpmswAPBqWtZZqQwkC2CtvOhZYrM(RHCmkFijnX94swFSS5MQqpM9u2mAKP)Y1HXyrBtZnXrQV4XS96zu(qsAI7XLS(yzZnvHEmlQuQaZb5kmpMfYfMhgjRlAAD4Hkp7sonVPrr5jgLpKKM4ibusAYYMBQc9ywdgLpKKM4ECjRpw2CtvOhZIkLkOxVCyZOrM(l)sonphP(IhZIkJYhsstCpUK1hlBUPk0JznCIlAAD(xxYofR60NEoTsstiM3RNlAAD(xxYofR60NEoTsstigs1sH)1LStXQo9PNxvnyu(qsAI7XLS(yzZnvHEm7PcZJz5xYP55Sz0it)TxVsGUZTpDLyHOYO8HK0e3Jlz9XYMBQc9ywqUcZJzHCH5HrY6IMwhEOYZqEb9SqB6jX7mnkkDrtRZfnzc0FbMVc0wQpkCALKMqmKtQwkC2CtvOhZYrM(RHts1sH3nUf6pjkYFsyU5GCb5kmpMfYzZnvHEmRvTtGKsDGUZHwfoRiOV06MgfLPAPWzZnvHEmlhz6VGCrnaScpOhxXjaUB6dW6zrdWO25MQqpMfG7hAnaRfOdWENSkcbyFa4S6cWMvJfTzdcWhRjimw0aSpamc50FJLa4UPpaRWINa4J1c0HamSBQAeaoraCfsiCqUcZJzHC2CtvOhZAv7eiDOYZmkFijnz6kxsjzItlcHyzZnvHEmR9PRel00rvjKCtnk6kPmvlfoBUPk0Jz5pDLyHhMQLcNn3uf6XSCK6lEmB(KdBgnY0F5S5MQqpML)0vIfIQuTu4S5MQqpML)0vIfAoixH5XSqoBUPk0JzTQDcKou5zgLpKKMmDLlPKmXPfHqSS5MQqpM1(0vIfA6OQuqqm1OORKsZW0OOmvlfoSUwfJfn0M0eeglA7tcck8QAVEgLpKKM4KjoTieILn3uf6XS2NUsSWtZJBg5dAgc)kMKp5KQLchwxRIXIgAtAccJfn)kMyHUWu0mt1sHdRRvXyrdTjnbHXIMdDHPO5GCfMhZc5S5MQqpM1Q2jq6qLNLe02Py9pykcnnkkt1sHZMBQc9ywoY0Fb5kmpMfYzZnvHEmRvTtG0HkpthgJfTnn3KPrrPW8WizPLUbbpnpdPAPWzZnvHEmlhz6VGCfMhZc5S5MQqpM1Q2jq6qLNDJ)NhANI1N)sRBAuuMQLcNn3uf6XSCKP)Aivlf(xxYofR60NEoY0Fb5kmpMfYzZnvHEmRvTtG0HkpRcjB4010vUKYouuP37EsqS9)a69FrfAAuuMQLcNn3uf6XS8QQbH5XS8s8KnPfOZzDYJMGkvGbH5XS8s8KnPfOZFI1jpAY6XLofndHFfta5kmpMfYzZnvHEmRvTtG0HkplPNbXofR3rwAPlkGCfMhZc5S5MQqpM1Q2jq6qLNDP78OyNIvxzbIf5j5cb5kmpMfYzZnvHEmRvTtG0HkpR)8AeJuS2NGZklJa5IAayZE1pw0amQDUPk0JznfGvyXta8XAb6qawEcGRqcbG9bGrtl9ItamQ74aCM)KOieGLfbGVXg3iFja27iawUtDDaEkaShxcGHQ06amzcXQESOb4X7OhGHQKwd5aScBEag6YIipcaRWINmfGvyXta8XAb6qawEcGNvJcaxHeca3VJwag1Lepw0aScFvaoGaSW8WibWZdW97OfGfaoJnpRdGzc0b4acWXcWQ)G(jieGLfbGrDjXJfnaRWxfGLfbGrDhhGZ8Nefby5jaEhhGfMhgjoaNFfEhaFSwGo9aSzPaD6byzrayfMwUeaRWDnfGvyXta8XAb6qaMjlaliiHhZkAnkaCIa4kKqa4(DHMayu3Xb4m)jrrawweag1Lepw0aScFvawEcG3XbyH5HrcGLfbGfao)gLFsAb6aCab4ybyVJayjEawweaw0WbG73fAcGzc0JfnaNXMN1bWKrAb4OaWOUK4XIgGv4RcWbeGf9tcckaSW8WiXb4J6iawlUtpalA90hcWE)bGrDhhGZ8Nefb48Bu(jPfOdbyFa4ebWmb6aCSamSYyeegZcWsXPhG9ocGZyZZ64aSzhcs4XSIwJca3p8oa(yTaD6byZsb60dWYIaWkmTCjawH7AkaRWINa4J1c0HamSBQAeaEhhGteaxHecaxxnbHa8XAb60dWMLc0PhGdialPP6aSpamzIA8eappa7D0taS8eaFNNayVtwaM2PIUdGvyXta8XAb6qa2haMmXPfbGpwlqNEa2SuGo9aSpaS3ramTia8uayu7CtvOhZYb5kmpMfYzZnvHEmRvTtG0HkpRepztAb6MwHKDkflAgIY8mTcjB)UqtwMa9yrRmptJIsjFPpCIN0c0P3EfOtpNwjPjedSo5rtWtvMNHCYryEmlVepztAb6CwN8OjOT8cZJzf9H5KQLcNn3uf6XS8NUsSqZmvlfEslqNE7vGo9CK6lEmR55FSz0it)LxINSjTaDos9fpM1mZjvlfoBUPk0Jz5pDLyHMN)LtQwk8KwGo92RaD65i1x8ywZubCZWCZpvPc617ejFPpCIN0c0P3EfOtpNwjPjKE9oXfnToVOLlzNLtRK0esVEPAPWzZnvHEml)PRelevkt1sHN0c0P3EfOtphP(IhZ2RxQwk8KwGo92RaD65pDLyHOsbCZOxpsHQHQkHW7qrLEV7jbX2)dO3)fvOb2mAKP)Y7qrLEV7jbX2)dO3)fvO98kqb5L)oh)PRelevMH5gs1sHZMBQc9ywEv1qoNimpMLdzZZ64KjeR6XI2WjcZJz5QO8tslqNhRTOd0DUHuTu4DK4XI2wv5v1E9eMhZYHS5zDCYeIv9yrBivlfE34wO)KOihz6VgYjvlfEhjESOTvvoY0F71tYx6dN4jTaD6Txb60ZPvsAcX8E9K8L(WjEslqNE7vGo9CALKMqm4IMwNx0YLSZYPvsAcXGW8ywUkk)K0c05XAl6aDNBivlfEhjESOTvvoY0FnKQLcVBCl0FsuKJm9xZb5IAa48RW7a48)Tq)kAag1kqMGqMcWkS4ja(yTaDiad7MQgbG3Xb4ebWviHaW1vtqiaN)Vf6xrdWOwbYeecGdialPP6aSpamzIA8eappa7D0taS8eaFNNayVtwaM2PIUdGvyXta8XAb6qa2haMmXPfbGpwlqNEa2SuGo9aSpaS3ramTia8uayu7CtvOhZYb5kmpMfYzZnvHEmRvTtG0HkpRepztAb6MwHKDkflAgIY8mTcjB)UqtwMa9yrRmptJIYtK8L(WjEslqNE7vGo9CALKMqmKJW8WizPLUbbrLsH5HrYImopqVHt96DcBgnY0F5QDdTHj2IwUeK)KGGI5gyZIudNhBH(v0wMazccXPvsAcXaRtE0e8uL5ziNCeMhZYlXt2KwGoN1jpAcAlVW8ywrFyogLpKKM4KjoTieILn3uf6XS2NUsSqZmvlfESf6xrBzcKjiehP(IhZAE(hBgnY0F5L4jBslqNJuFXJzntJYhsstCYeNwecXYMBQc9yw7txjwy(xoPAPWJTq)kAltGmbH4i1x8ywZubCZWCZpvPc61ZO8HK0eNmXPfHqSS5MQqpM1(0vIfIkLPAPWJTq)kAltGmbH4i1x8y2E9s1sHhBH(v0wMazccXF6kXcrLc4MH5gs1sHZMBQc9ywEv1WjPAPWlXtqF(l)jH5gojvlfE34wO)KOi)jH5g6g3c9NefTqvsRH2yTfDGUZpmvlfEhjESOTvv(tcZr15a5kmpMfYzZnvHEmRvTtG0HkpRepztAb6MwHKDkflAgIY8mTcjB)UqtwMa9yrRmptJIYtK8L(WjEslqNE7vGo9CALKMqmKJW8WizPLUbbrLsH5HrYImopqVHt96DcBgnY0F5QDdTHj2IwUeK)KGGI5goHnlsnCESf6xrBzcKjieNwjPjedSo5rtWtvMNHuTu4S5MQqpMLxvnCsQwk8s8e0N)YFsyUHts1sH3nUf6pjkYFsyUHUXTq)jrrluL0AOnwBrhO78dt1sH3rIhlABvL)KWCuDoqUcZJzHC2CtvOhZAv7eiDOYZytDD6HQKwBAuu(1LkZJM4ibKfQ6yLhflBUxzr4KcvdvvcXqQwkCKaYcvDSYJILn3RSiCKP)AivlfosazHQow5rXYM7vweR8mzjoY0FnWMrJm9xEQwkwKaYcvDSYJILn3RSi8Neeua5kmpMfYzZnvHEmRvTtG0HkptEMSKLmrvpWywtJIYVUuzE0ehjGSqvhR8OyzZ9klcNuOAOQsigs1sHJeqwOQJvEuSS5ELfHJm9xdPAPWrcilu1Xkpkw2CVYIyLNjlXrM(Rb2mAKP)Yt1sXIeqwOQJvEuSS5ELfH)KGGcixH5XSqoBUPk0JzTQDcKou5zLFGEA0UPrr5xxQmpAIJeqwOQJvEuSS5ELfHtkunuvjedPAPWrcilu1Xkpkw2CVYIWrM(RHuTu4ibKfQ6yLhflBUxzrSLFGohz6VGCfMhZc5S5MQqpM1Q2jq6qLNXeT2kmpM1QdOB6kxsPW8WizDrtRdb5kmpMfYzZnvHEmRvTtG0HkpJn3uf6XSMwHKDkflAgIY8mTcjB)UqtwMa9yrRmptJIYuTu4S5MQqpMLJm9xd581LkZJM4ibKfQ6yLhflBUxzr4KcvdvvcrzQwkCKaYcvDSYJILn3RSi8QQ5gYryEml)sonppwBrhO7CdcZJz5xYP55XAl6aDNBF6kXcrLsfWnJE9eMhZYHS5zDCYeIv9yrBqyEmlhYMN1Xjtiw1j7txjwiQua3m61tyEmlVepLeTMtMqSQhlAdcZJz5L4PKO1CYeIvDY(0vIfIkfWnJE9eMhZYvr5NKwGoNmHyvpw0geMhZYvr5NKwGoNmHyvNSpDLyHOsbCZWCqUcZJzHC2CtvOhZAv7eiDOYZuhpM10OOmvlfoBUPk0Jz5Ab6wYe14juPuyEmlNn3uf6XSCTaDBfsiGCfMhZc5S5MQqpM1Q2jq6qLNL0ZGyl1hftJIYuTu4S5MQqpMLRfOBjtuJNqLsH5XSC2CtvOhZY1c0TviHaYvyEmlKZMBQc9ywRANaPdvEwIEi9kglAtJIYuTu4S5MQqpMLRfOBjtuJNqLsH5XSC2CtvOhZY1c0TviHaYvyEmlKZMBQc9ywRANaPdvEwjEkPNbX0OOmvlfoBUPk0Jz5Ab6wYe14juPuyEmlNn3uf6XSCTaDBfsiGCfMhZc5S5MQqpM1Q2jq6qLNjlJG(lAlt0AtJIYuTu4S5MQqpMLRfOBjtuJNqLsH5XSC2CtvOhZY1c0TviHaYvyEmlKZMBQc9ywRANaPdvEwfs2WPl00OOmvlfoBUPk0Jz5Ab6wYe14juPuyEmlNn3uf6XSCTaDBfsiGCfMhZc5S5MQqpM1Q2jq6qLN5XLS9Lx10OO8RlvMhnXD6QoVOT9LxLtkunuvjedPAPWzZnvHEmlxlq3sMOgpHkLcZJz5S5MQqpMLRfOBRqcXqoWrp96LQLcNmPtQqpMLxvnhKRW8ywiNn3uf6XSw1obshQ8SIwUe0)qrY0OOmNuTu4DJBH(tII8NeM3RxQwk8s8e0N)YFsyU5geMhgjlT0ni4PknkFijnXzZnvHEmRTOLlb9puKa5kmpMfYzZnvHEmRvTtG0HkptfLFsAb6MgfLPAPWH11QySOH2KMGWyrBFsqqHxvnKQLchwxRIXIgAtAccJfT9jbbf(txjw4Pmb6wpUeixH5XSqoBUPk0JzTQDcKou5zQO8tslq30OOmvlfEjEc6ZF5pjmhKRW8ywiNn3uf6XSw1obshQ8mvu(jPfOBAuuMQLcxfLFyAbE5pjm3qQwkCvu(HPf4L)0vIfEktGU1JlziNuTu4S5MQqpML)0vIfEktGU1Jl1RxQwkC2CtvOhZYrM(R5GCfMhZc5S5MQqpM1Q2jq6qLNPIYpjTaDtJIYuTu4DJBH(tII8NeMBivlfoBUPk0Jz5vvqUcZJzHC2CtvOhZAv7eiDOYZur5NKwGUPrrP6tgTOzi884q28SodPAPW7iXJfTTQYFsyoixH5XSqoBUPk0JzTQDcKou5zQDdTHj2IwUe00OOmvlfoBUPk0Jz5vvd5KJW8ywEjEYM0c05So5rtquLNbx006Cvu(HPf4LtRK0eIbH5HrYslDdcQmpZ717ex006Cvu(HPf4LtRK0esVEcZdJKLw6ge808mhKRW8ywiNn3uf6XSw1obshQ8Ss8us0AtJIYuTu4S5MQqpMLJm9xdSz0it)LZMBQc9yw(txjwiQyc0TECjdNWMfPgoVOLlzfg7jpMLtRK0ecixH5XSqoBUPk0JzTQDcKou5zq28SotJIYuTu4S5MQqpML)0vIfEktGU1JlzivlfoBUPk0Jz5v1E9s1sHZMBQc9ywoY0FnWMrJm9xoBUPk0Jz5pDLyHOIjq36XLa5kmpMfYzZnvHEmRvTtG0HkpthgJfTnn3KPrrzQwkC2CtvOhZYF6kXcrfAgc)kMyqyEyKS0s3GGNMhixH5XSqoBUPk0JzTQDcKou5ziVGEwOn9K4DMgfLPAPWzZnvHEml)PRelevOzi8RyIHuTu4S5MQqpMLxvb5kmpMfYzZnvHEmRvTtG0HkpdYMN1zAuu6YJMCEhjAVJRYCuP88kWGlAADoKKpw0wFQSooTsstiGCb5kmpMfY)r1Q2jqszrlxc6FOizAuuMJW8WizPLUbbpvPr5djPjE34wO)KOOTOLlb9puKmKJhxYmt1sHZMBQc9ywUwGULmrnE6uJYhsstCeslOylA5sq)dfPE9mkFijnXrcOK0KLn3uf6XSMBUHCs1sH3nUf6pjkYFsyEVEPAPWlXtqF(l)jH5MdYvyEmlK)JQvTtG0HkptfLFsAb6MgfLPAPWH11QySOH2KMGWyrBFsqqHxvnKQLchwxRIXIgAtAccJfT9jbbf(txjw4Pmb6wpUeixH5XSq(pQw1obshQ8mvu(jPfOBAuuMQLcVepb95V8NeMdYvyEmlK)JQvTtG0HkptfLFsAb6MgfLPAPW7g3c9Nef5pjmhKRW8ywi)hvRANaPdvEwjEYM0c0nTcj7ukw0meL5zAfs2(DHMSmb6XIwzEMgfLPAPWH11QySOH2KMGWyrBFsqqHJm9xdNKJW8WizPLUbbpvPr5djPjEN8iwMaDBrlxc6FOizihpUKzMQLcNn3uf6XSCTaDlzIA80PgLpKKM4iKwqXw0YLG(hksMBUHtkXtqxENEUW8WiziNts1sH3rIhlABvL)KWCdNKQLcVBCl0FsuK)KWCdNO(Kr7ukw0meEjEYM0c0nKJW8ywEjEYM0c05So5rtWtvEUE9YXfnTox0Kjq)fy(kqBP(OWPvsAcXaBgnY0F5iVGEwOn9K4D8NeeumVxVCCrtRZHK8XI26tL1XPvsAcXGlpAY5DKO9oUkZrLYZRaZn3CqUcZJzH8FuTQDcKou5zL4jBslq30kKStPyrZquMNPviz73fAYYeOhlAL5zAuuEsjEc6Y70ZfMhgjd5KtocZJz5L4PKO1CYeIv9yr3RNW8ywUkk)K0c05KjeR6XI2CdPAPW7iXJfTTQYFsyU596LJlAADoKKpw0wFQSooTsstigC5rtoVJeT3XvzoQuEEfyiNuTu4DK4XI2wv5pjm3WjcZJz5q28SoozcXQESO717KuTu4DJBH(tII8NeMB4KuTu4DK4XI2wv5pjm3GW8ywoKnpRJtMqSQhlAdN0nUf6pjkAHQKwdTXAl6aDNBU5MdYvyEmlK)JQvTtG0HkpJjATvyEmRvhq30vUKsH5HrY6IMwhcYvyEmlK)JQvTtG0HkptfLFsAb6MgfLPAPWvr5hMwGx(tcZnWeOB94sOkvlfUkk)W0c8YF6kXcnWeOB94sOkvlf(xxYofR60NE(txjwOHCs1sHRIYpmTaV8NeMRmvlfUkk)W0c8YVIjwOlmf71lvlfUkk)W0c8YF6kXcrftGU1JlDOW8ywEjEkjAnNmHyvNSECPE9s1sHlAYeO)cmFfOTuFu4v1E9o5RlvMhnXH11QySOH2KMGWyrZjfQgQQeI5GCfMhZc5)OAv7eiDOYZur5NKwGUPrrP6tgTOzi884q28SodPAPW7iXJfTTQYFsyUbx006CijFSOT(uzDCALKMqm4YJMCEhjAVJRYCuP88kWWj5impmswAPBqWtvAu(qsAI3nUf6pjkAlA5sq)dfjd54XLmZuTu4S5MQqpMLRfOBjtuJNo1O8HK0ehH0ck2IwUe0)qrYCZb5kmpMfY)r1Q2jq6qLNP2n0gMylA5sqtJIYtmkFijnXv7gAdtSQZOJfTHuTu4DK4XI2wv5pjm3WjPAPW7g3c9Nef5pjm3qocZdJKfzCEGEdNq1561tyEyKS0s3GGNQ0O8HK0eVtEeltGUTOLlb9puK61tyEyKS0s3GGNQ0O8HK0eVBCl0Fsu0w0YLG(hksMdYvyEmlK)JQvTtG0HkpdYMN1zAuu6YJMCEhjAVJRYCuP88kWGlAADoKKpw0wFQSooTsstiGCfMhZc5)OAv7eiDOYZKNjlzjtu1dmM10OOuyEyKS0s3GGNQ0O8HK0exEMSKLmrvpWywdxzfUkZpvPr5djPjU8mzjlzIQEGXS2RScixH5XSq(pQw1obshQ8SIwUe0)qrY0OOmhH5HrYslDdcEQsJYhsst8o5rSmb62IwUe0)qrYqoECjZmvlfoBUPk0Jz5Ab6wYe14PtnkFijnXriTGITOLlb9puKm3CqUcZJzH8FuTQDcKou5zL4PKO1GCb5kmpMfYHUSiYJy)XfpMvzrlxc6FOizAuuMJW8WizPLUbbpvPr5djPjE34wO)KOOTOLlb9puKmKJhxYmt1sHZMBQc9ywUwGULmrnE6uJYhsstCeslOylA5sq)dfPE9mkFijnXrcOK0KLn3uf6XSMBUHCs1sH3nUf6pjkYFsyEVEPAPWlXtqF(l)jH5MdYvyEmlKdDzrKhX(JlEm7HkptfLFsAb6MgfLPAPWlXtqF(l)jH5GCfMhZc5qxwe5rS)4IhZEOYZur5NKwGUPrrzQwk8UXTq)jrr(tcZnKQLcVBCl0FsuK)0vIfIkH5XS8s8us0AozcXQoz94sGCfMhZc5qxwe5rS)4IhZEOYZur5NKwGUPrrzQwk8UXTq)jrr(tcZnKJ6tgTOzi884L4PKO196vINGU8o9CH5HrQxpH5XSCvu(jPfOZJ1w0b6o3CqUOga(Ohfa2hagn5aCMz1Jby1FyqaowyGqaScht(naR2jqccWZdWO25MQqpMfGv7eibb4(D0cWQdegjnXb5kmpMfYHUSiYJy)XfpM9qLNPIYpjTaDtJIYuTu4W6Avmw0qBstqySOTpjiOWRQgYHnJgz6V8VUKDkw1Pp98NUsSWdfMhZY)6s2PyvN(0Zjtiw1jRhx6qMaDRhx60uTu4W6Avmw0qBstqySOTpjiOWF6kXc717ex0068VUKDkw1Pp9CALKMqm3Gr5djPjUhxY6JLn3uf6XShYeOB94sNMQLchwxRIXIgAtAccJfT9jbbf(txjwiixH5XSqo0LfrEe7pU4XShQ8mvu(jPfOBAuuMQLcVBCl0FsuK)KWCdU8OjN3rI274QmhvkpVcm4IMwNdj5JfT1NkRJtRK0ecixH5XSqo0LfrEe7pU4XShQ8mvu(jPfOBAuuMQLcxfLFyAbE5pjm3atGU1JlHQuTu4QO8dtlWl)PRel0qoPAPWvr5hMwGx(tcZvMQLcxfLFyAbE5xXel0fMI96LQLcxfLFyAbE5pDLyHOIjq36XLouyEmlVepLeTMtMqSQtwpUuVEPAPWfnzc0FbMVc0wQpk8QAVEN81LkZJM4W6Avmw0qBstqySO5KcvdvvcXCqUcZJzHCOllI8i2FCXJzpu5zL4jBslq30kKStPyrZquMNPviz73fAYYeOhlAL5zAuuEsjEc6Y70ZfMhgjdNyu(qsAIxINSjTaDR6m6yrBiNCYryEmlVepLeTMtMqSQhl6E9eMhZYvr5NKwGoNmHyvpw0MBivlfEhjESOTvv(tcZnVxVCCrtRZHK8XI26tL1XPvsAcXGlpAY5DKO9oUkZrLYZRad5KQLcVJepw02Qk)jH5goryEmlhYMN1Xjtiw1JfDVENKQLcVBCl0FsuK)KWCdNKQLcVJepw02Qk)jH5geMhZYHS5zDCYeIv9yrB4KUXTq)jrrluL0AOnwBrhO7CZn3CqUcZJzHCOllI8i2FCXJzpu5zQO8tslq30OOu9jJw0meEECiBEwNHuTu4DK4XI2wv5pjm3GlAADoKKpw0wFQSooTsstigC5rtoVJeT3XvzoQuEEfy4KCeMhgjlT0ni4PknkFijnX7g3c9NefTfTCjO)HIKHC84sMzQwkC2CtvOhZY1c0TKjQXtNAu(qsAIJqAbfBrlxc6FOizU5GCfMhZc5qxwe5rS)4IhZEOYZu7gAdtSfTCjOPrr5jgLpKKM4QDdTHjw1z0XI2qoN4IMwNx(5A9oYkWocYPvsAcPxpH5HrYslDdcEAEMBihH5HrYslDdcEAEgeMhgjlY48a9goHQZ1RNW8WizPLUbbpvPr5djPjEN8iwMaDBrlxc6FOi1RNW8WizPLUbbpvPr5djPjE34wO)KOOTOLlb9puKmhKRW8ywih6YIipI9hx8y2dvEgt0ARW8ywRoGUPRCjLcZdJK1fnToeKRW8ywih6YIipI9hx8y2dvEgYlONfAtpjENPrrPW8WizPLUbbpnpqUcZJzHCOllI8i2FCXJzpu5zq28SotJIsxE0KZ7ir7DCvMJkLNxbgCrtRZHK8XI26tL1XPvsAcbKRW8ywih6YIipI9hx8y2dvEM8mzjlzIQEGXSMgfLcZdJKLw6ge8uLgLpKKM4YZKLSKjQ6bgZA4kRWvz(PknkFijnXLNjlzjtu1dmM1ELva5IAa48RW7ayANk6oa2Lhn5qtb4Wb4acWcaJwIfG9bGzc0byfMwUe0)qrcGfiaxcTMEaowOtccapfawHfpLeTMdYvyEmlKdDzrKhX(JlEm7HkpROLlb9puKmnkkfMhgjlT0ni4PknkFijnX7KhXYeOBlA5sq)dfjd54XLmZuTu4S5MQqpMLRfOBjtuJNo1O8HK0ehH0ck2IwUe0)qrYCqUcZJzHCOllI8i2FCXJzpu5zL4PKO1GCfMhZc5qxwe5rS)4IhZEOYZGS5zDTmOkXAhKFoFZBERb]] )

end
