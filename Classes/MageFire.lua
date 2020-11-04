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


    spec:RegisterPack( "Fire", 20201101, [[d80YRcqivQ8ifv4sQuvytOQ(KkvLgLOsNsuXQeLuVsrvZsu4wOczxK8lvknmubhtuLLPOspdsKPPOI6AIsY2uPk13eLigNOeLZbjkToirvZds4EOs7tLIdkkrAHQK6HQuvnruHkUOkvfTruHYhvurQrcjQCsuHkTsrPEPIksMjKO4MOcvTtrv9trjQ0qvurSurjQ4PKQPQsYvvPkXxvPkPXkkrv2RK(lLgmuhMyXI8yuMmexgzZs8zi1OvKtlSArjQQxJkA2uCBvSBL(TudNuoUOewUQEoOPt11vy7OkFxrz8IIopK06vPkMVkX(bUMx9QQoI4un)5YH5YH8YJdOKAUOekLhhU3vDhvnQQRjmof0uvFLdv15yXtvDnbvtli1RQ6WE8mQQp5UgeL)2Brh(0iPy95wyCggXJEzVu8BHXHDBvpncJZXDRPQoI4un)5YH5YH8YJd5v1LHp1Fvxpo3FvFkqqOTMQ6ieKv1NdaMJfpbWC8cAcK9CaWtURbr5V9w0HpnskwFUfgNHr8Ox2lf)wyCy3cYEoa48BE0jrpaNxga8C5WC5aiBq2ZbaF)tYIMGO8GSNdaMJa47fibWLa9KBF6iXcb4x8j6byFswa2Lhn5kpoK1BlsqaCPFa2iqNJGeRxeawsHjCub4buqtqfi75aG5ia(ErdrCcGnn6GbWpHYdWOmdwGaWCCEsoqfi75aG5iagLPBiTamtGoa)uwmINo06qaU0paF)9jnGE0laNBOivgamsV3xhGNAdcahoax6hGfaU8eCcG54jN6hGzc0ZrbYEoayocG54eqjziawwaMw)rfG9jXb4z9WGaWpbhghGJfGfaEsEeMaDaEob1Vtgb6aCSCeA5qkq2ZbaZra895kjdbWq)dMdWSjIXzSOb4EbybGl0maU0pNqaowa2NiaolDobLbG9gGFczWiaEw)CAAbrv1nb0H1RQ6iurggVEvn)8Qxv1PvsgcPEDvN9HtFiv97a4FSuPF0KcjGSqZeR8OAz95ilIIYIrOPrivDH5rVvDwpwNEOgzmvVM)CRxv1PvsgcPEDvV1Q6qYR6cZJER68KpKKHQ68eZGQ6UyO1vL4jOlVtVIwjzieaoRb4s8e0L3Px90rIfcWZdW5cWSUni9SvX6tAa9Ox1thjwiaN1aCUaCEamhbW8KpKKHuCglIjw02Nqgmp6fGZAa2fdTUIZyrmXIwrRKmecaNdaNdaN1a8DamRBdspBvS(Kgqp6v9KGGkaN1aCAukkwFsdOh9Qq6zBvNN82vouv3Jdz92Y6tAa9O3QxZhLQxv1PvsgcPEDvN9HtFiv90OuuS(Kgqp6vH0ZwaMpaNgLI6hlz7IvRNrVcPNTamFaM1TbPNTkwFsdOh9QE6iXcb4BayoaW8b4Cbyw3gKE2Q(Xs2Uy16z0RE6iXcb4BayoaWxUaW3bWUyO1v)yjBxSA9m6v0kjdHaW5u1fMh9w1HtrXJfTvRNrF1R5pNRxv1PvsgcPEDvN9HtFiv9Cb40OuuS(Kgqp6vH0ZwaMpaNgLI6hlz7IvRNrVcPNTamFaoxaM1TbPNTkwFsdOh9QE6iXcbyuaWuMeB4K1JdbWxUaWSUni9SvX6tAa9Ox1thjwiaFdaZ62G0Zw1liHSUfQjpNkKXlE0laNdaNdaF5caNlaNgLI6hlz7IvRNrVAObW8byw3gKE2Qy9jnGE0R6PJeleGVbGrjoaW5u1fMh9w1FbjK1Tqn55S618ZQ6vvDALKHqQxx1zF40hsvpnkffRpPb0JEvi9SfG5dWPrPO(Xs2Uy16z0Rq6zlaZhGzDBq6zRI1N0a6rVQNosSqagfamLjXgoz94qvDH5rVvDes8Pu)lv9A(376vvDALKHqQxx1zF40hsvpnkffRpPb0JEvi9SfG5dWiuAukQxqczDlutEoT8gMLEjfMWrvH0Z2QUW8O3Q(j(VFBCe0u1R5NLuVQQtRKmes96QUW8O3QUCpWj5fOT0RB7IvRNrFvN9HtFivDEYhsYqkpoK1BlRpPb0JEbyuWfGZkaEEaoVScGZAaMN8HKmKQ0RBr6rYq2ETdibW8byEYhsYqkpoK1BlRpPb0JEb4Bayou1x5qvD5EGtYlqBPx32fRwpJ(QxZplREvvNwjziK61vD2ho9Hu1ZfG5jFijdP84qwVTS(Kgqp6fGrbaNhha4lxa4sGEYTpDKyHamkayEYhsYqkpoK1BlRpPb0JEb4CQ6cZJER6OhYJeYA7IvUh6BFQ618rzRxv1fMh9w1z9YO1FXjeBXihQQtRKmes96QxZppouVQQlmp6TQ)KOflABXihcw1PvsgcPED1R5NxE1RQ6cZJER6LMnGeIvUh6dNSjsovDALKHqQxx9A(5n36vvDH5rVvDTXhfuJfTnzeOx1PvsgcPED1R5NhkvVQQlmp6TQ)HMMHSXAHAcJQ60kjdHuVU618ZBoxVQQlmp6TQ7tKDSPESi2s)mQQtRKmes96QxZpVSQEvvNwjziK61vD2ho9Hu1)XsL(rtkKaYcntSYJQL1NJSikklgHMgHaW8byw3gKE2QsJsXIeqwOzIvEuTS(CKfr9KGGkaZhGtJsrHeqwOzIvEuTS(CKfXkptwsH0ZwaMpaZ62G0ZwfRpPb0JEvpDKyHa8namkXbaMpaFhaNgLIcjGSqZeR8OAz95ilIAOv1fMh9w1z9yD6HAKXu9A(5DVRxv1PvsgcPEDvN9HtFiv9FSuPF0KcjGSqZeR8OAz95ilIIYIrOPriamFaM1TbPNTQ0OuSibKfAMyLhvlRphzrupjiOcW8b40OuuibKfAMyLhvlRphzrSYZKLui9SfG5dWSUni9SvX6tAa9Ox1thjwiaFdaJsCaG5dW3bWPrPOqcil0mXkpQwwFoYIOgAvDH5rVvD5zYswktntdJEREn)8YsQxv1PvsgcPEDvN9HtFiv9FSuPF0KcjGSqZeR8OAz95ilIIYIrOPriamFaM1TbPNTQ0OuSibKfAMyLhvlRphzrupjiOcW8b40OuuibKfAMyLhvlRphzrSLVHUcPNTamFaM1TbPNTkwFsdOh9QE6iXcb4BayuIdamFa(oaonkffsazHMjw5r1Y6Zrwe1qRQlmp6TQx(g6P24vVMFEzz1RQ60kjdHuVUQZ(WPpKQEAukQFSKTlwTEg9kKE2cW8b4CbyEYhsYqkpoK1BlRpPb0JEb4Ba40Ouu)yjBxSA9m6viJx8OxaMpaZt(qsgs5XHSEBz9jnGE0laFdalmp6vvINSjJaDvzym2NytYJMSECia(YfaMN8HKmKYJdz92Y6tAa9Oxa(gaUeONC7thjwiaNtvxyE0Bv)hlz7IvRNrF1R5NhkB9QQoTsYqi1RR6cZJER6mXyScZJETMa6vD2ho9Hu1VdG5jFijdPqcOKmKL1N0a6rVamFaMN8HKmKYJdz92Y6tAa9OxagfCbyou1nb0TRCOQoRpPb0JETAtcKQEn)5YH6vvDALKHqQxx1BTQoK8QUW8O3Qop5djzOQopXmOQ(Damp5djzifsaLKHSS(Kgqp6fG5dW8KpKKHuECiR3wwFsdOh9cWOaGfMh9QkXt2KrGUQmmg7tSj5rtwpoeaZramp5djzifCkkESOTA9m6TpHmyE0laN1aCUamRBdspBvWPO4XI2Q1ZOx90rIfcWOaG5jFijdP84qwVTS(Kgqp6fGZbG5dW8KpKKHuECiR3wwFsdOh9cWOaGlb6j3(0rIfw15jVDLdv1lXt2KrGUvRBtSOREn)5Mx9QQoTsYqi1RR6TwvhsEvxyE0BvNN8HKmuvNNyguv)oaMN8HKmKcjGsYqwwFsdOh9cW8byEYhsYqkpoK1BlRpPb0JEbyuaWcZJEvAtnTrM2IroeuvggJ9j2K8OjRhhcG5iaMN8HKmKcoffpw0wTEg92Nqgmp6fGZAaoxaM1TbPNTk4uu8yrB16z0RE6iXcbyuaW8KpKKHuECiR3wwFsdOh9cW5aW8byEYhsYqkpoK1BlRpPb0JEbyuaWLa9KBF6iXcb4lxa4FSuPF0KcowlNXIgAtgccJfTIYIrOPrivDEYBx5qvDTPM2itRw3Myrx9A(ZDU1RQ60kjdHuVUQlmp6TQZeJXkmp61AcOx1zF40hsvpnkf1pwY2fRwpJE1qdG5dW5cW8KpKKHuECiR3wwFsdOh9cW3aWCaGZPQBcOBx5qv9V1SAtcKQEn)5Is1RQ60kjdHuVUQ3AvDi5vDH5rVvDEYhsYqvDEIzqv97ayEYhsYqkKakjdzz9jnGE0laZhG5jFijdP84qwVTS(Kgqp6fGrbalmp6vPn10gzAlg5qqvzym2NytYJMSECiaMpaZt(qsgs5XHSEBz9jnGE0laJcaUeONC7thjwiaF5ca)JLk9JMuWXA5mw0qBYqqySOvuwmcnncPQZtE7khQQRn10gzA162el6QxZFUZ56vvDALKHqQxx1hqYoBkmKLjqpw018ZRQZ(WPpKQ(Damp5djzivjEYMmc0TADBIfnaZhGZfG5jFijdP84qwVTS(Kgqp6fGVbG5aaF5caZt(qsgsHeqjzilRpPb0JEb4Cay(aCUaSW8GhzPLobbb4B4cW8KpKKHutYJyzc0TfJCiO)bNeaZhGZfG94qamhbWPrPOy9jnGE0RYiq3szQfpbW3aW8KpKKHuiKrq1wmYHG(hCsa8Llamp5djzifsaLKHSS(Kgqp6fGZbGZbG5dW3bWL4jOlVtVsyEWJay(a8DaCAukQP2Tq)jHt1tcZby(aCUaCAukQjs8yrBhAQNeMdWxUaWSj5rtqB5fMh9kga(gUa8Cb4CQ6diz7sXIMHuZpVQUW8O3QEjEYMmc0REn)5Mv1RQ60kjdHuVUQpGKD2uyiltGESOR5NxvN9HtFiv9s8e0L3Pxjmp4ramFaMnjpAccW3WfGZdG5dW3bW8KpKKHuL4jBYiq3Q1Tjw0amFaoxa(oawyE0RQepLeJrrzsSHhlAaMpaFhalmp6vPH63jJaDvS2Ijqp5amFaonkf1ejESOTdn1tcZb4lxayH5rVQs8usmgfLjXgESOby(a8DaCAukQP2Tq)jHt1tcZb4lxayH5rVknu)ozeORI1wmb6jhG5dWPrPOMiXJfTDOPEsyoaZhGVdGtJsrn1Uf6pjCQEsyoaNtvFajBxkw0mKA(5v1fMh9w1lXt2KrGE1R5p37D9QQoTsYqi1RR6cZJER6mXyScZJETMa6vD2ho9Hu1ZfG5jFijdP84qwVTS(Kgqp6fGVbG5aaNdaZhGtJsr9JLSDXQ1ZOxH0Z2QUjGUDLdv1HUSiYJy)2fp6T6vVQ)TMvBsGu9QA(5vVQQtRKmes96Qo7dN(qQ65cWcZdEKLw6eeeGVHlaZt(qsgsn1Uf6pjCAlg5qq)dojaMpaNla7XHayocGtJsrX6tAa9OxLrGULYulEcGVbG5jFijdPqiJGQTyKdb9p4Ka4lxayEYhsYqkKakjdzz9jnGE0laNdaNdaZhGZfGtJsrn1Uf6pjCQEsyoaF5caNgLIQepb9(pQNeMdW5u1fMh9w1lg5qq)doPQxZFU1RQ60kjdHuVUQZ(WPpKQEAukk4yTCglAOnziimw02NeeuvdnaMpaNgLIcowlNXIgAtgccJfT9jbbv1thjwiaFdaZeOB94qvDH5rVvDnu)ozeOx9A(Ou9QQoTsYqi1RR6SpC6dPQNgLIQepb9(pQNeMx1fMh9w11q97KrGE1R5pNRxv1PvsgcPEDvN9HtFiv90OuutTBH(tcNQNeMx1fMh9w11q97KrGE1R5Nv1RQ60kjdHuVUQpGKD2uyiltGESOR5NxvN9HtFiv90OuuWXA5mw0qBYqqySOTpjiOQq6zlaZhGVdGZfGfMh8ilT0jiiaFdxaMN8HKmKAsEeltGUTyKdb9p4Kay(aCUaShhcG5iaonkffRpPb0JEvgb6wktT4ja(gaMN8HKmKcHmcQ2Iroe0)GtcGZbGZbG5dW3bWL4jOlVtVsyEWJay(aCUa8DaCAukQjs8yrBhAQNeMdW8b47a40OuutTBH(tcNQNeMdW8b47ayTN4z7sXIMHOkXt2KrGoaZhGZfGfMh9QkXt2KrGUInjpAccW3WfGNlaF5caNla7IHwxjgktO)c8EeOTmEuv0kjdHaW8byw3gKE2QqEbDVqB6jXNupjiOcW5aWxUaW5cWUyO1vqs(yrB9EWMu0kjdHaW8byxE0KRMiX4tknMdWOGlaJsCaGZbGZbGZPQpGKTlflAgsn)8Q6cZJER6L4jBYiqV618V31RQ60kjdHuVUQpGKD2uyiltGESOR5NxvN9HtFiv97a4s8e0L3Pxjmp4ramFaoxaoxaoxawyE0RQepLeJrrzsSHhlAa(YfawyE0Rsd1Vtgb6kktIn8yrdW5aW8b40OuutK4XI2o0upjmhGZbGVCbGZfGDXqRRGK8XI269GnPOvsgcbG5dWU8OjxnrIXNuAmhGrbxagL4aaZhGZfGtJsrnrIhlA7qt9KWCaMpaFhalmp6vbz9ZMuuMeB4XIgGVCbGVdGtJsrn1Uf6pjCQEsyoaZhGVdGtJsrnrIhlA7qt9KWCaMpalmp6vbz9ZMuuMeB4XIgG5dW3bWtTBH(tcNwOgzmqBS2Ijqp5aCoaCoaCov9bKSDPyrZqQ5NxvxyE0BvVepztgb6vVMFws9QQoTsYqi1RR6cZJER6mXyScZJETMa6vDtaD7khQQlmp4rwxm06WQxZplREvvNwjziK61vD2ho9Hu1tJsrPH63mJapQNeMdW8byMaDRhhcGrbaNgLIsd1VzgbEupDKyHamFaMjq36XHayuaWPrPO(Xs2Uy16z0RE6iXcR6cZJER6AO(DYiqV618rzRxv1PvsgcPEDvN9HtFivDTN4zrZqu5PGS(ztamFaonkf1ejESOTdn1tcZby(aSlgADfKKpw0wVhSjfTsYqiamFa2Lhn5Qjsm(KsJ5amk4cWOehay(a8DaCUaSW8GhzPLobbb4B4cW8KpKKHutTBH(tcN2Iroe0)GtcG5dW5cWECiaMJa40OuuS(Kgqp6vzeOBPm1INa4BayEYhsYqkeYiOAlg5qq)dojaohaoNQUW8O3QUgQFNmc0REn)84q9QQoTsYqi1RR6SpC6dPQFhaZt(qsgsPn10gzA162elAaMpaNgLIAIepw02HM6jH5amFa(oaonkf1u7wO)KWP6jH5amFaoxawyEWJSiTRc0B4eaJcaEUa8LlaSW8GhzPLobbb4B4cW8KpKKHutYJyzc0TfJCiO)bNeaF5calmp4rwAPtqqa(gUamp5djzi1u7wO)KWPTyKdb9p4Ka4CQ6cZJER6AtnTrM2IroeS618ZlV6vvDALKHqQxx1zF40hsv3Lhn5Qjsm(KsJ5amk4cWOehay(aSlgADfKKpw0wVhSjfTsYqivDH5rVvDiRF2u1R5N3CRxv1PvsgcPEDvN9HtFivDH5bpYslDcccW3WfG5jFijdPKNjlzPm1mnm6fG5dWhzfLgZb4B4cW8KpKKHuYZKLSuMAMgg9ApYkvDH5rVvD5zYswktntdJEREn)8qP6vvDALKHqQxx1zF40hsvpxawyEWJS0sNGGa8nCbyEYhsYqQj5rSmb62Iroe0)GtcG5dW5cWECiaMJa40OuuS(Kgqp6vzeOBPm1INa4BayEYhsYqkeYiOAlg5qq)dojaohaoNQUW8O3QEXihc6FWjv9A(5nNRxv1fMh9w1lXtjXyQ60kjdHuVU6vVQZ6tAa9OxR2KaP6v18ZREvvNwjziK61vD2ho9Hu1tJsrX6tAa9OxfspBR6cZJER6Ma9KdTz5pqqFO1REn)5wVQQtRKmes96QERv1HKx1fMh9w15jFijdv15jMbv1tJsrX6tAa9Ox1thjwiappaNgLII1N0a6rVkKXlE0laN1aCUamRBdspBvS(Kgqp6v90rIfcWOaGtJsrX6tAa9Ox1thjwiaNtvNN82vouvNY0PfHqSS(Kgqp61(0rIfw9A(Ou9QQoTsYqi1RR6TwvxqqQ6cZJER68KpKKHQ68eZGQ6zvvNN82vouvNY0PfHqSS(Kgqp61(0rIfw1zF40hsvpnkffCSwoJfn0MmeeglA7tccQQHgaF5caZt(qsgsrz60IqiwwFsdOh9AF6iXcb4Ba48uzfaN1amAgI6izcWznaNlaNgLIcowlNXIgAtgccJfT6izAHUW4eG5iaonkffCSwoJfn0MmeeglAf0fgNaCovVM)CUEvvNwjziK61vD2ho9Hu1tJsrX6tAa9OxfspBR6cZJER6jbTTlw)dgNWQxZpRQxv1PvsgcPEDvN9HtFivDH5bpYslDcccW3aW5bW8b40OuuS(Kgqp6vH0Z2QUW8O3QUj4flABQpPQxZ)ExVQQtRKmes96Qo7dN(qQ6PrPOy9jnGE0RcPNTamFaonkf1pwY2fRwpJEfspBR6cZJER6N4)(H2Uy9(p06vVMFws9QQoTsYqi1RR6cZJER6tOQrVp9KGyN9b0N9IgSQZ(WPpKQEAukkwFsdOh9QgAamFawyE0RQepztgb6k2K8OjiaZfG5aaZhGfMh9QkXt2KrGU6j2K8OjRhhcGVbGrZquhjZQ(khQQpHQg9(0tcID2hqF2lAWQxZplREvvxyE0Bvpz6gX2fRprwAPdQvDALKHqQxx9A(OS1RQ6cZJER6h60pQ2UyndwGyrEsoWQoTsYqi1RREn)84q9QQUW8O3Q(S(ni8OyTpb7vwgv1PvsgcPED1R5NxE1RQ60kjdHuVUQpGKD2uyiltGESOR5NxvN9HtFivD5EOpCsLmc0P3EeOtVIwjzieaMpaZMKhnbb4B4cW5bW8b4Cb4CbyH5rVQs8KnzeORytYJMG2Ylmp6vma88aCUaCAukkwFsdOh9QE6iXcbyocGtJsrLmc0P3EeOtVcz8Ih9cW5aW3cWSUni9SvvINSjJaDfY4fp6fG5iaoxaonkffRpPb0JEvpDKyHaCoa8TaCUaCAukQKrGo92JaD6viJx8OxaMJayoOYkaohaoha(gUamha4lxa47ay5EOpCsLmc0P3EeOtVIwjziea(Yfa(oa2fdTUQyKdz7vrRKmecaF5caNgLII1N0a6rVQNosSqagfCb40OuujJaD6Thb60RqgV4rVa8LlaCAukQKrGo92JaD6vpDKyHamkayoOYka(YfaMYIrOPriQju1O3NEsqSZ(a6ZErdcW8byw3gKE2QMqvJEF6jbXo7dOp7fnOfL4ahYBopx1thjwiaJcaoRa4Cay(aCAukkwFsdOh9QgAamFaoxa(oawyE0RcY6NnPOmj2WJfnaZhGVdGfMh9Q0q97KrGUkwBXeONCaMpaNgLIAIepw02HMAObWxUaWcZJEvqw)SjfLjXgESOby(aCAukQP2Tq)jHtfspBby(aCUaCAukQjs8yrBhAkKE2cWxUaWY9qF4KkzeOtV9iqNEfTsYqiaCoa8LlaSCp0hoPsgb60Bpc0PxrRKmecaZhGDXqRRkg5q2Ev0kjdHaW8byH5rVknu)ozeORI1wmb6jhG5dWPrPOMiXJfTDOPq6zlaZhGtJsrn1Uf6pjCQq6zlaNtvFajBxkw0mKA(5v1fMh9w1lXt2KrGE1R5N3CRxv1PvsgcPEDvFaj7SPWqwMa9yrxZpVQo7dN(qQ63bWY9qF4KkzeOtV9iqNEfTsYqiamFaoxawyEWJS0sNGGamk4cWcZdEKfPDvGEdNa4lxa47ayw3gKE2Q0MAAJmTfJCiO6jbbvaohaMpaZ6fzeUk2c9RySmbYeesrRKmecaZhGztYJMGa8nCb48ay(aCUaCUaSW8OxvjEYMmc0vSj5rtqB5fMh9kgaEEaoxaMN8HKmKIY0PfHqSS(Kgqp61(0rIfcWCeaNgLIk2c9RySmbYeesHmEXJEb4Ca4Bbyw3gKE2QkXt2KrGUcz8Ih9cWCeaZt(qsgsrz60IqiwwFsdOh9AF6iXcb4Bb4Cb40OuuXwOFfJLjqMGqkKXlE0laZramhuzfaNdaNdaFdxaMda8Llamp5djzifLPtlcHyz9jnGE0R9PJeleGrbxaonkfvSf6xXyzcKjiKcz8Ih9cWxUaWPrPOITq)kgltGmbHupDKyHamkayoOYkaohaMpaNgLII1N0a6rVQHgaZhGVdGtJsrvINGE)h1tcZby(a8DaCAukQP2Tq)jHt1tcZby(a8u7wO)KWPfQrgd0gRTyc0toappaNgLIAIepw02HM6jH5amka45w1hqY2LIfndPMFEvDH5rVv9s8KnzeOx9A(5Hs1RQ60kjdHuVUQpGKD2uyiltGESOR5NxvN9HtFiv97ay5EOpCsLmc0P3EeOtVIwjzieaMpaNlalmp4rwAPtqqagfCbyH5bpYI0UkqVHta8Lla8DamRBdspBvAtnTrM2Iroeu9KGGkaNdaZhGVdGz9ImcxfBH(vmwMazccPOvsgcbG5dWSj5rtqa(gUaCEamFaonkffRpPb0JEvdnaMpaFhaNgLIQepb9(pQNeMdW8b47a40OuutTBH(tcNQNeMdW8b4P2Tq)jHtluJmgOnwBXeONCaEEaonkf1ejESOTdn1tcZbyuaWZTQpGKTlflAgsn)8Q6cZJER6L4jBYiqV618ZBoxVQQtRKmes96Qo7dN(qQ6)yPs)OjfsazHMjw5r1Y6ZrwefLfJqtJqay(aCAukkKaYcntSYJQL1NJSikKE2cW8b40OuuibKfAMyLhvlRphzrSYZKLui9SfG5dWSUni9SvLgLIfjGSqZeR8OAz95ilI6jbb1QUW8O3QoRhRtpuJmMQxZpVSQEvvNwjziK61vD2ho9Hu1)XsL(rtkKaYcntSYJQL1NJSikklgHMgHaW8b40OuuibKfAMyLhvlRphzrui9SfG5dWPrPOqcil0mXkpQwwFoYIyLNjlPq6zlaZhGzDBq6zRknkflsazHMjw5r1Y6Zrwe1tccQvDH5rVvD5zYswktntdJEREn)8U31RQ60kjdHuVUQZ(WPpKQ(pwQ0pAsHeqwOzIvEuTS(CKfrrzXi00ieaMpaNgLIcjGSqZeR8OAz95ilIcPNTamFaonkffsazHMjw5r1Y6ZrweB5BORq6zBvxyE0BvV8n0tTXREn)8YsQxv1PvsgcPEDvxyE0BvNjgJvyE0R1eqVQBcOBx5qvDH5bpY6IHwhw9A(5LLvVQQtRKmes96Q(as2ztHHSmb6XIUMFEvD2ho9Hu1tJsrX6tAa9OxfspBby(aCUa8pwQ0pAsHeqwOzIvEuTS(CKfrrzXi00ieaMlaNgLIcjGSqZeR8OAz95ilIAObW5aW8b4CbyH5rVQd5u)QyTftGEYby(aSW8Ox1HCQFvS2Ijqp52NosSqagfCbyoOYka(YfawyE0RcY6NnPOmj2WJfnaZhGfMh9QGS(ztkktInCY(0rIfcWOaG5GkRa4lxayH5rVQs8usmgfLjXgESOby(aSW8OxvjEkjgJIYKydNSpDKyHamkayoOYka(YfawyE0Rsd1Vtgb6kktIn8yrdW8byH5rVknu)ozeOROmj2Wj7thjwiaJcaMdQScGZPQpGKTlflAgsn)8Q6cZJER6S(Kgqp6T618ZdLTEvvNwjziK61vD2ho9Hu1tJsrX6tAa9OxLrGULYulEcGrbxawyE0RI1N0a6rVkJaD7asivDH5rVvDT2JEREn)5YH6vvDALKHqQxx1zF40hsvpnkffRpPb0JEvgb6wktT4jagfCbyH5rVkwFsdOh9Qmc0TdiHu1fMh9w1tMUrSLXJA1R5p38Qxv1PvsgcPEDvN9HtFiv90OuuS(Kgqp6vzeOBPm1INayuWfGfMh9Qy9jnGE0RYiq3oGesvxyE0BvprpKEoJfD1R5p35wVQQtRKmes96Qo7dN(qQ6PrPOy9jnGE0RYiq3szQfpbWOGlalmp6vX6tAa9OxLrGUDajKQUW8O3QEjEkz6gP618NlkvVQQtRKmes96Qo7dN(qQ6PrPOy9jnGE0RYiq3szQfpbWOGlalmp6vX6tAa9OxLrGUDajKQUW8O3QUSmc6VySmXyQEn)5oNRxv1PvsgcPEDvN9HtFiv90OuuS(Kgqp6vzeOBPm1INayuWfGfMh9Qy9jnGE0RYiq3oGesvxyE0BvFajB40bw9A(ZnRQxv1PvsgcPEDvN9HtFiv9FSuPF0KYPJw)IXotEnfLfJqtJqay(aCAukkwFsdOh9Qmc0TuMAXtamk4cWcZJEvS(Kgqp6vzeOBhqcbG5dW5cWW20a8LlaCAukkkZjza9Ox1qdGZPQlmp6TQ7XHSZKxR618N79UEvvNwjziK61vD2ho9Hu1ZfGtJsrn1Uf6pjCQEsyoaF5caNgLIQepb9(pQNeMdW5aW8byH5bpYslDcccW3WfG5jFijdPy9jnGE0RTyKdb9p4KQ6cZJER6fJCiO)bNu1R5p3SK6vvDALKHqQxx1zF40hsvpnkffCSwoJfn0MmeeglA7tccQQHgaZhGtJsrbhRLZyrdTjdbHXI2(KGGQ6PJeleGVbGzc0TECOQUW8O3QUgQFNmc0REn)5MLvVQQtRKmes96Qo7dN(qQ6PrPOkXtqV)J6jH5vDH5rVvDnu)ozeOx9A(ZfLTEvvNwjziK61vD2ho9Hu1tJsrPH63mJapQNeMdW8b40OuuAO(nZiWJ6PJeleGVbGzc0TECiaMpaNlaNgLII1N0a6rVQNosSqa(gaMjq36XHa4lxa40OuuS(Kgqp6vH0ZwaoNQUW8O3QUgQFNmc0REnFuId1RQ60kjdHuVUQZ(WPpKQEAukQP2Tq)jHt1tcZby(aCAukkwFsdOh9QgAvDH5rVvDnu)ozeOx9A(OuE1RQ60kjdHuVUQZ(WPpKQU2t8SOziQ8uqw)SjaMpaNgLIAIepw02HM6jH5vDH5rVvDnu)ozeOx9A(O0CRxv1PvsgcPEDvN9HtFiv90OuuS(Kgqp6vn0ay(aCUaCUaSW8OxvjEYMmc0vSj5rtqagfaCEamFa2fdTUsd1VzgbEu0kjdHaW8byH5bpYslDcccWCb48a4Ca4lxa47ayxm06knu)Mze4rrRKmecaF5calmp4rwAPtqqa(gaopaoNQUW8O3QU2utBKPTyKdbREnFucLQxv1PvsgcPEDvN9HtFiv90OuuS(Kgqp6vH0ZwaMpaZ62G0ZwfRpPb0JEvpDKyHamkayMaDRhhcG5dW3bWSErgHRkg5qwHXEYJEv0kjdHu1fMh9w1lXtjXyQEnFuAoxVQQtRKmes96Qo7dN(qQ6PrPOy9jnGE0R6PJeleGVbGzc0TECiaMpaNgLII1N0a6rVQHgaF5caNgLII1N0a6rVkKE2cW8byw3gKE2Qy9jnGE0R6PJeleGrbaZeOB94qvDH5rVvDiRF2u1R5Jszv9QQoTsYqi1RR6SpC6dPQNgLII1N0a6rVQNosSqagfamAgI6izcW8byH5bpYslDcccW3aW5v1fMh9w1nbVyrBt9jv9A(O09UEvvNwjziK61vD2ho9Hu1tJsrX6tAa9Ox1thjwiaJcagndrDKmby(aCAukkwFsdOh9QgAvDH5rVvDKxq3l0MEs8PQxZhLYsQxv1PvsgcPEDvN9HtFivDxE0KRMiX4tknMdWOGlaJsCaG5dWUyO1vqs(yrB9EWMu0kjdHu1fMh9w1HS(ztvV6vDH5bpY6IHwhwVQMFE1RQ60kjdHuVUQZ(WPpKQUW8GhzPLobbb4Ba48ay(aCAukkwFsdOh9Qq6zlaZhGZfG5jFijdP84qwVTS(Kgqp6fGVbGzDBq6zRYe8IfTn1NKcz8Ih9cWxUaW8KpKKHuECiR3wwFsdOh9cWOGlaZbaoNQUW8O3QUj4flABQpPQxZFU1RQ60kjdHuVUQZ(WPpKQ(Damp5djzifsaLKHSS(Kgqp6fG5dW8KpKKHuECiR3wwFsdOh9cWOGlaZba(YfaoxaM1TbPNTQd5u)kKXlE0laJcaMN8HKmKYJdz92Y6tAa9OxaMpaFha7IHwx9JLSDXQ1ZOxrRKmecaNdaF5ca7IHwx9JLSDXQ1ZOxrRKmecaZhGtJsr9JLSDXQ1ZOxn0ay(amp5djziLhhY6TL1N0a6rVa8naSW8Ox1HCQFfRBdspBb4lxa4sGEYTpDKyHamkayEYhsYqkpoK1BlRpPb0JER6cZJER6hYP(REnFuQEvvNwjziK61vD2ho9Hu1DXqRRedLj0FbEpc0wgpQkALKHqay(aCUaCAukkwFsdOh9Qq6zlaZhGVdGtJsrn1Uf6pjCQEsyoaNtvxyE0Bvh5f09cTPNeFQ6vVQdDzrKhX(TlE0B9QA(5vVQQtRKmes96Qo7dN(qQ65cWcZdEKLw6eeeGVHlaZt(qsgsn1Uf6pjCAlg5qq)dojaMpaNla7XHayocGtJsrX6tAa9OxLrGULYulEcGVbG5jFijdPqiJGQTyKdb9p4Ka4lxayEYhsYqkKakjdzz9jnGE0laNdaNdaZhGZfGtJsrn1Uf6pjCQEsyoaF5caNgLIQepb9(pQNeMdW5u1fMh9w1lg5qq)doPQxZFU1RQ60kjdHuVUQZ(WPpKQEAukQs8e07)OEsyEvxyE0Bvxd1Vtgb6vVMpkvVQQtRKmes96Qo7dN(qQ6PrPOMA3c9NeovpjmhG5dWPrPOMA3c9NeovpDKyHamkayH5rVQs8usmgfLjXgoz94qvDH5rVvDnu)ozeOx9A(Z56vvDALKHqQxx1zF40hsvpnkf1u7wO)KWP6jH5amFaoxaw7jEw0mevEQs8usmga(YfaUepbD5D6vcZdEeaF5calmp6vPH63jJaDvS2Ijqp5aCovDH5rVvDnu)ozeOx9A(zv9QQoTsYqi1RR6SpC6dPQNgLIcowlNXIgAtgccJfT9jbbv1qdG5dW5cWSUni9Sv9JLSDXQ1ZOx90rIfcWZdWcZJEv)yjBxSA9m6vuMeB4K1JdbWZdWmb6wpoeaFdaNgLIcowlNXIgAtgccJfT9jbbv1thjwiaF5caFha7IHwx9JLSDXQ1ZOxrRKmecaNdaZhG5jFijdP84qwVTS(Kgqp6fGNhGzc0TECia(gaonkffCSwoJfn0MmeeglA7tccQQNosSWQUW8O3QUgQFNmc0REn)7D9QQoTsYqi1RR6SpC6dPQNgLIAQDl0Fs4u9KWCaMpa7YJMC1ejgFsPXCagfCbyuIdamFa2fdTUcsYhlAR3d2KIwjziKQUW8O3QUgQFNmc0REn)SK6vvDALKHqQxx1zF40hsvpnkfLgQFZmc8OEsyoaZhGzc0TECiagfaCAukknu)Mze4r90rIfw1fMh9w11q97KrGE1R5NLvVQQtRKmes96Q(as2ztHHSmb6XIUMFEvD2ho9Hu1VdGlXtqxENELW8GhbW8b47ayEYhsYqQs8KnzeOB162elAaMpaNlaNlaNlalmp6vvINsIXOOmj2WJfnaF5calmp6vPH63jJaDfLjXgESOb4Cay(aCAukQjs8yrBhAQNeMdW5aWxUaW5cWUyO1vqs(yrB9EWMu0kjdHaW8byxE0KRMiX4tknMdWOGlaJsCaG5dW5cWPrPOMiXJfTDOPEsyoaZhGVdGfMh9QGS(ztkktIn8yrdWxUaW3bWPrPOMA3c9NeovpjmhG5dW3bWPrPOMiXJfTDOPEsyoaZhGfMh9QGS(ztkktIn8yrdW8b47a4P2Tq)jHtluJmgOnwBXeONCaohaohaoNQ(as2UuSOzi18ZRQlmp6TQxINSjJa9QxZhLTEvvNwjziK61vD2ho9Hu11EINfndrLNcY6NnbW8b40OuutK4XI2o0upjmhG5dWUyO1vqs(yrB9EWMu0kjdHaW8byxE0KRMiX4tknMdWOGlaJsCaG5dW3bW5cWcZdEKLw6eeeGVHlaZt(qsgsn1Uf6pjCAlg5qq)dojaMpaNla7XHayocGtJsrX6tAa9OxLrGULYulEcGVbG5jFijdPqiJGQTyKdb9p4Ka4Ca4CQ6cZJER6AO(DYiqV618ZJd1RQ60kjdHuVUQZ(WPpKQ(Damp5djziL2utBKPvRBtSOby(aCUa8DaSlgADv57J1NiRaNiOIwjziea(YfawyEWJS0sNGGa8naCEaCoamFaoxawyEWJS0sNGGa8naCEamFawyEWJSiTRc0B4eaJcaEUa8LlaSW8GhzPLobbb4B4cW8KpKKHutYJyzc0TfJCiO)bNeaF5calmp4rwAPtqqa(gUamp5djzi1u7wO)KWPTyKdb9p4Ka4CQ6cZJER6AtnTrM2IroeS618ZlV6vvDALKHqQxx1fMh9w1zIXyfMh9Anb0R6Ma62vouvxyEWJSUyO1HvVMFEZTEvvNwjziK61vD2ho9Hu1fMh8ilT0jiiaFdaNxvxyE0Bvh5f09cTPNeFQ618ZdLQxv1PvsgcPEDvN9HtFivDxE0KRMiX4tknMdWOGlaJsCaG5dWUyO1vqs(yrB9EWMu0kjdHu1fMh9w1HS(ztvVMFEZ56vvDALKHqQxx1zF40hsvxyEWJS0sNGGa8nCbyEYhsYqk5zYswktntdJEby(a8rwrPXCa(gUamp5djziL8mzjlLPMPHrV2JSsvxyE0BvxEMSKLYuZ0WO3QxZpVSQEvvNwjziK61vD2ho9Hu1fMh8ilT0jiiaFdxaMN8HKmKAsEeltGUTyKdb9p4Kay(aCUaShhcG5iaonkffRpPb0JEvgb6wktT4ja(gaMN8HKmKcHmcQ2Iroe0)GtcGZPQlmp6TQxmYHG(hCsvVMFE376vvDH5rVv9s8usmMQoTsYqi1RREn)8YsQxv1fMh9w1HS(ztvDALKHqQxx9Qx11EI1NK41RQ5Nx9QQUW8O3QU8mzjBSozmeZR60kjdHuVU618NB9QQoTsYqi1RR6TwvhsEvxyE0BvNN8HKmuvNNyguvFUaCwdWUyO1vfJCiRM4SjfTsYqia88amkbWznaFha7IHwxvmYHSAIZMu0kjdHu15jVDLdv1NA3c9NeoTfJCiO)bNuvN9HtFivDEYhsYqQP2Tq)jHtBXihc6FWjbWCbyou9A(Ou9QQoTsYqi1RR6TwvhsEvxyE0BvNN8HKmuvNNyguvFUaCwdWUyO1vfJCiRM4SjfTsYqia88amkbWznaFha7IHwxvmYHSAIZMu0kjdHu15jVDLdv1NKhXYeOBlg5qq)doPQo7dN(qQ68KpKKHutYJyzc0TfJCiO)bNeaZfG5q1R5pNRxv1PvsgcPEDvV1Q6qYR6cZJER68KpKKHQ68eZGQ6OeaN1aSlgADvXihYQjoBsrRKmecappaFVb4SgGVdGDXqRRkg5qwnXztkALKHqQ68K3UYHQ6S(Kgqp61wmYHG(hCsvD2ho9Hu15jFijdPy9jnGE0RTyKdb9p4KayUamhQEn)SQEvvNwjziK61v9wRQdjVQlmp6TQZt(qsgQQZtmdQQJYIYcWzna7IHwxvmYHSAIZMu0kjdHaWZdWZfGZAa(oa2fdTUQyKdz1eNnPOvsgcPQZtE7khQQlptwYszQzAy0BvN9HtFivDEYhsYqk5zYswktntdJEbyUamhQEn)7D9QQoTsYqi1RR6Twv)ji5vDH5rVvDEYhsYqvDEYBx5qvD5zYswktntdJEThzLQocvKHXR6Zzou9A(zj1RQ60kjdHuVUQ3Av9NGKx1fMh9w15jFijdv15jVDLdv1riJGQTyKdb9p4KQ6iurggVQZHQxZplREvvNwjziK61v9wRQ)eK8QUW8O3Qop5djzOQop5TRCOQoNXIyIfT9jKbZJER6iurggVQZb1CREnFu26vvDALKHqQxx1BTQoK8QUW8O3Qop5djzOQopXmOQohbWcZJEvWPO4XI2Q1ZOxrzsSHtwpoeaFlalmp6vbNIIhlARwpJEfd5R68K3UYHQ6WPO4XI2Q1ZO3(eYG5rVvD2ho9Hu1znpAL1vBGEYTfHQEn)84q9QQoTsYqi1RR6TwvhsEvxyE0BvNN8HKmuvNNyguvNYIrOPriQJSrHGEB7I9iilbHa8LlamLfJqtJquOncsiE)qBsqqta8LlamLfJqtJquOncsiE)q7HqeJj6fGVCbGPSyeAAeIkqVHh9ApcAcAldibWxUaWuwmcnncr53JSe0MKNtOwSeeGVCbGPSyeAAeIsUNXt(udTWyrtiwnZ4iOja(YfaMYIrOPrikzzbTULZTDBxSZcisFa4lxayklgHMgHOGtnJZu40dTfzrdWxUaWuwmcnncrT04fJfI6kAqYs7KSm6b4lxayklgHMgHOsIHkXt20llBQQZtE7khQQZ6tAa9OxBV2bKQEn)8YREvvNwjziK61v9wRQdjVQlmp6TQZt(qsgQQZtmdQQtzXi00ieLCpWj5fOT0RB7IvRNrpaZhG5jFijdPy9jnGE0RTx7asvDEYBx5qv9sVUfPhjdz71oGu1R5N3CRxv1PvsgcPEDvV1Q6qYR6cZJER68KpKKHQ68eZGQ65LLv15jVDLdv1l962Uy16z0B1EI1NK4w2KSlzQ6SpC6dPQZt(qsgsv61Ti9iziBV2bKay(a8DaSlgADvjEc6Y70ROvsgcbG5dW8KpKKHuLEDBxSA9m6TApX6tsClBs2LmamxaMdvVMFEOu9QQoTsYqi1RR6RCOQUCpWj5fOT0RB7IvRNrFvxyE0BvxUh4K8c0w61TDXQ1ZOV618ZBoxVQQlmp6TQFI)73ghbnv1PvsgcPED1R5NxwvVQQlmp6TQRH63jJa9QoTsYqi1RRE1REvNh9WO3A(ZLdZLd5LhhYRQpt(nw0WQ(9AwAwo5ZXn)50O8amaF1ebWXrRFhGl9dW3xTNy9jj(9fGFklgXtiamSpealdVpItiamBsw0eubYgLjwcGrzr5b47VxE07ecaRhN7hGHOUUKjaFFaWEdWOmdbGrcEbm6fGBn6fVFao3BZbGZnVmZrbYgLjwcGrzr5b47VxE07ecaFFznpAL1vz5POvsgc5(cWEdW3xwZJwzDvwE3xao38YmhfiBq23RzPz5Kph38NtJYdWa8vteahhT(DaU0paFFz9jnGE0RvBsG09fGFklgXtiamSpealdVpItiamBsw0eubYgLjwcGZlpuEa((7Lh9oHaW6X5(byiQRlzcW3haS3amkZqayKGxaJEb4wJEX7hGZ92Ca4CNBM5OazJYelbW5nxuEa((7Lh9oHaW6X5(byiQRlzcW3haS3amkZqayKGxaJEb4wJEX7hGZ92Ca4CNBM5OazdYMJ7rRFNqa47nalmp6fGnb0Hkq2vDTVlHHQ6ZbaZXINayoEbnbYEoa4j31GO83El6WNgjfRp3cJZWiE0l7LIFlmoSBbzphaC(np6KOhGZldaEUCyUCaKni75aGV)jzrtquEq2ZbaZra89cKa4sGEYTpDKyHa8l(e9aSpjla7YJMCLhhY6TfjiaU0paBeOZrqI1lcalPWeoQa8akOjOcK9CaWCeaFVOHiobWMgDWa4Nq5byuMblqayoopjhOcK9CaWCeaJY0nKwaMjqhGFklgXthADiax6hGV)(Kgqp6fGZnuKkdagP37RdWtTbbGdhGl9dWcaxEcobWC8Kt9dWmb65OazphamhbWCCcOKmeallatR)OcW(K4a8SEyqa4NGdJdWXcWcapjpctGoapNG63jJaDaowocTCifi75aG5ia((CLKHayO)bZby2eX4mw0aCVaSaWfAgax6Ntiahla7teaNLoNGYaWEdWpHmyeapRFonTGOazdYEoa47Zmj2WjeaorL(jaM1NK4aCIqhlubWzPmgP5qaE7LJMK)uggawyE0leG71GQcKTW8OxOs7jwFsIpp3BLNjlzJ1jJHyoi75aGVAkGamp5djziagQrSOeeeG9jcG3Xjrpa3fa2Lhn5qawCaE2uWMayuU2byD)jHtaMJzKdb9p4KGaCpCyGqaCxa47VpPb0JEby4upmiaCIa4bKquGSfMh9cvApX6ts855Elp5djzOmw5qCNA3c9NeoTfJCiO)bNugTgxi5zefU8KpKKHutTBH(tcN2Iroe0)GtIlhYGNyge35M1UyO1vfJCiRM4SjfTsYqiZJsz9DUyO1vfJCiRM4SjfTsYqiGSNda(QPacW8KpKKHayOgXIsqqa2NiaEhNe9aCxayxE0KdbyXb4ztbBcGr5KhbGVFb6amhZihc6FWjbb4E4WaHa4UaW3FFsdOh9cWWPEyqa4ebWdiHaWceGlHXqVcKTW8OxOs7jwFsIpp3B5jFijdLXkhI7K8iwMaDBXihc6FWjLrRXfsEgrHlp5djzi1K8iwMaDBXihc6FWjXLdzWtmdI7CZAxm06QIroKvtC2KIwjziK5rPS(oxm06QIroKvtC2KIwjzieq2ZbaF1uabyEYhsYqamuJyrjiia7teaVJtIEaUlaSlpAYHaS4a8SPGnbWOCTdW6(tcNamhZihc6FWjbby5jaEajeagz8XIgGV)(Kgqp6vbYwyE0luP9eRpjXNN7T8KpKKHYyLdXL1N0a6rV2Iroe0)GtkJwJlK8mIcxEYhsYqkwFsdOh9Alg5qq)dojUCidEIzqCrPS2fdTUQyKdz1eNnPOvsgcz(7DwFNlgADvXihYQjoBsrRKmeci75aGVAkGamp5djziagQrSOeeeG9jcG3Xjrpa3fa2Lhn5qawCaE2uWMa4S0NjlbW3NzQzAy0la3dhgiea3fa((7tAa9Oxago1ddcaNiaEajefiBH5rVqL2tS(KeFEU3Yt(qsgkJvoex5zYswktntdJEZO14cjpJOWLN8HKmKsEMSKLYuZ0WOxUCidEIzqCrzrzZAxm06QIroKvtC2KIwjziK5NBwFNlgADvXihYQjoBsrRKmeci75aGVAkGamp5djziagQrSOeeeG9jcG1ONrRlOjaUla8rwbGtKPNbWZMc2eaNL(mzja((mtntdJEb4zHXaWB7aCIa4bKquGSfMh9cvApX6ts855Elp5djzOmw5qCLNjlzPm1mnm61EKvYaHkYW4CNZCiJwJ7tqYbzpha8vtbeG5jFijdbWbeGhqcbG9gGHAelkOcW(ebWYPhRdWDbG94qaCSamKy9IabyFsCa(mGoaRjqialfNEa((7tAa9OxaMYulEccWjQ0pbWCmJCiO)bNeeGNfgdaNiaEajeaE7)igdQkq2cZJEHkTNy9jj(8CVLN8HKmugRCiUiKrq1wmYHG(hCszGqfzyCUCiJwJ7tqYbzpha89A4ta8CQyrmXIoda((7tAa9O37leGzDBq6zlaplmgaora8tidgHaWjubybGFzr6dalNESEgaCA4aSpra8ooj6b4UaWSpCiadD5DiaZJEub4Pa9ealfNEawyEWt8yrdW3FFsdOh9cWYIaWqtpdcWi9SfG9EM8iqa2NiaMweaUla893N0a6rV3xiaZ62G0ZwfaFVorlaFeoJfnaJqSag9cb4ybyFIa4S05euMma47VpPb0JEVVqa(PJeBSObyw3gKE2cWbeGFczWieaoHka7tbeGlVW8Oxa2BawySESoax6hGNtflIjw0kq2cZJEHkTNy9jj(8CVLN8HKmugRCiUCglIjw02Nqgmp6ndeQidJZLdQ5MrRX9ji5GSfMh9cvApX6ts855Elp5djzOmw5qCHtrXJfTvRNrV9jKbZJEZO14cjpdEIzqC5iH5rVk4uu8yrB16z0ROmj2WjRhh6(qyE0Rcoffpw0wTEg9kgYNru4YAE0kRR2a9KBlcPOvsgcbKTW8OxOs7jwFsIpp3B5jFijdLXkhIlRpPb0JET9AhqkJwJlK8m4jMbXLYIrOPriQJSrHGEB7I9iilbHxUqzXi00iefAJGeI3p0Mee00LluwmcnncrH2iiH49dThcrmMO3lxOSyeAAeIkqVHh9ApcAcAldiD5cLfJqtJqu(9ilbTj55eQflbVCHYIrOPrik5Egp5tn0cJfnHy1mJJGMUCHYIrOPrikzzbTULZTDBxSZcisFUCHYIrOPrik4uZ4mfo9qBrw0xUqzXi00ie1sJxmwiQRObjlTtYYO)YfklgHMgHOsIHkXt20llBcKTW8OxOs7jwFsIpp3B5jFijdLXkhIBPx3I0JKHS9AhqkJwJlK8m4jMbXLYIrOPrik5EGtYlqBPx32fRwpJE(8KpKKHuS(Kgqp612RDajq2ZbaF1uabyEYhsYqamc50FILGa8SjAb4S07bojVCFHamhRxhG7capN0ZOhGdiapGecaNOs)ea7teaRnmgaokaCQiQsVUTlwTEg9wTNy9jjULnj7sgaoGa82oad1iwuccrbYwyE0luP9eRpjXNN7T8KpKKHYyLdXT0RB7IvRNrVv7jwFsIBztYUKjJwJlK8m4jMbXnVSSmIcxEYhsYqQsVUfPhjdz71oGe)7CXqRRkXtqxENEfTsYqi85jFijdPk962Uy16z0B1EI1NK4w2KSlz4Ybq2cZJEHkTNy9jj(8CVDajB40jJvoex5EGtYlqBPx32fRwpJEq2cZJEHkTNy9jj(8CV9e)3VnocAcKTW8OxOs7jwFsIpp3B1q97KrGoiBq2ZbaFFMjXgoHaWep6rfG94qaSpraSW8(b4acWcpjmsYqkq2cZJEHCz9yD6HAKXKru4E3pwQ0pAsHeqwOzIvEuTS(CKfrrzXi00ieq2cZJEHZZ9wEYhsYqzSYH46XHSEBz9jnGE0BgTgxi5zWtmdIRlgADvjEc6Y70ROvsgcjRlXtqxENE1thjw485Y62G0ZwfRpPb0JEvpDKyHzDU5Xr8KpKKHuCglIjw02Nqgmp6nRDXqRR4mwetSOv0kjdHKtoz9DSUni9SvX6tAa9Ox1tccQzDAukkwFsdOh9Qq6zliBH5rVW55ElCkkESOTA9m6ZikCtJsrX6tAa9OxfspB5NgLI6hlz7IvRNrVcPNT8zDBq6zRI1N0a6rVQNosSWB4a)CzDBq6zR6hlz7IvRNrV6PJel8goC5YDUyO1v)yjBxSA9m6v0kjdHKdiBH5rVW55E7liHSUfQjpNzefU5MgLII1N0a6rVkKE2Ypnkf1pwY2fRwpJEfspB5NlRBdspBvS(Kgqp6v90rIfIcktInCY6XHUCH1TbPNTkwFsdOh9QE6iXcVH1TbPNTQxqczDlutEoviJx8O3CY5YLCtJsr9JLSDXQ1ZOxn04Z62G0ZwfRpPb0JEvpDKyH3GsCihq2cZJEHZZ9wes8Pu)lLru4MgLII1N0a6rVkKE2Ypnkf1pwY2fRwpJEfspB5Z62G0ZwfRpPb0JEvpDKyHOGYKydNSECiq2cZJEHZZ92t8F)24iOPmIc30OuuS(Kgqp6vH0Zw(iuAukQxqczDlutEoT8gMLEjfMWrvH0Zwq2cZJEHZZ92bKSHtNmw5qCL7bojVaTLEDBxSA9m6ZikC5jFijdP84qwVTS(Kgqp6ffCZQ5ZlRYAEYhsYqQsVUfPhjdz71oGeFEYhsYqkpoK1BlRpPb0JEVHdGSfMh9cNN7TOhYJeYA7IvUh6BFkJOWnxEYhsYqkpoK1BlRpPb0JErrEC4YLsGEYTpDKyHOGN8HKmKYJdz92Y6tAa9O3Cazlmp6fop3Bz9YO1FXjeBXihcKTW8Ox48CV9jrlw02IroeeKTW8Ox48CVT0SbKqSY9qF4KnrYbKTW8Ox48CVvB8rb1yrBtgb6GSfMh9cNN7TFOPziBSwOMWiq2cZJEHZZ9wFISJn1JfXw6NrGSNdaEon5aSpramsazHMjw5r1Y6ZrweaonkfaEOLbapwdbHamRpPb0JEb4acWWUxfiBH5rVW55ElRhRtpuJmMmIc3FSuPF0KcjGSqZeR8OAz95ilIIYIrOPri8zDBq6zRknkflsazHMjw5r1Y6Zrwe1tccQ8tJsrHeqwOzIvEuTS(CKfXkptwsH0Zw(SUni9SvX6tAa9Ox1thjw4nOeh4FxAukkKaYcntSYJQL1NJSiQHgiBH5rVW55ER8mzjlLPMPHrVzefU)yPs)OjfsazHMjw5r1Y6ZrwefLfJqtJq4Z62G0ZwvAukwKaYcntSYJQL1NJSiQNeeu5NgLIcjGSqZeR8OAz95ilIvEMSKcPNT8zDBq6zRI1N0a6rVQNosSWBqjoW)U0OuuibKfAMyLhvlRphzrudnq2cZJEHZZ92Y3qp1gpJOW9hlv6hnPqcil0mXkpQwwFoYIOOSyeAAecFw3gKE2QsJsXIeqwOzIvEuTS(CKfr9KGGk)0OuuibKfAMyLhvlRphzrSLVHUcPNT8zDBq6zRI1N0a6rVQNosSWBqjoW)U0OuuibKfAMyLhvlRphzrudnq2cZJEHZZ92FSKTlwTEg9zefUPrPO(Xs2Uy16z0Rq6zl)C5jFijdP84qwVTS(Kgqp69M0Ouu)yjBxSA9m6viJx8Ox(8KpKKHuECiR3wwFsdOh9EJW8OxvjEYMmc0vLHXyFInjpAY6XHUCHN8HKmKYJdz92Y6tAa9O3Bkb6j3(0rIfMdiBH5rVW55EltmgRW8OxRjGEgRCiUS(Kgqp61QnjqkJOW9oEYhsYqkKakjdzz9jnGE0lFEYhsYqkpoK1BlRpPb0JErbxoaYwyE0lCEU3Yt(qsgkJvoe3s8KnzeOB162el6m4jMbX9oEYhsYqkKakjdzz9jnGE0lFEYhsYqkpoK1BlRpPb0JErHW8OxvjEYMmc0vLHXyFInjpAY6XH4iEYhsYqk4uu8yrB16z0BFczW8O3Soxw3gKE2QGtrXJfTvRNrV6PJelef8KpKKHuECiR3wwFsdOh9MdFEYhsYqkpoK1BlRpPb0JErrjqp52NosSqq2cZJEHZZ9wEYhsYqzSYH4Qn10gzA162el6m4jMbX9oEYhsYqkKakjdzz9jnGE0lFEYhsYqkpoK1BlRpPb0JErHW8OxL2utBKPTyKdbvLHXyFInjpAY6XH4iEYhsYqk4uu8yrB16z0BFczW8O3Soxw3gKE2QGtrXJfTvRNrV6PJelef8KpKKHuECiR3wwFsdOh9MdFEYhsYqkpoK1BlRpPb0JErrjqp52NosSWlx(XsL(rtk4yTCglAOnziimw0kklgHMgHaYwyE0lCEU3YeJXkmp61AcONXkhI73AwTjbszefUPrPO(Xs2Uy16z0RgA8ZLN8HKmKYJdz92Y6tAa9O3B4qoGSfMh9cNN7T8KpKKHYyLdXvBQPnY0Q1Tjw0zWtmdI7D8KpKKHuibusgYY6tAa9Ox(8KpKKHuECiR3wwFsdOh9IcH5rVkTPM2itBXihcQkdJX(eBsE0K1JdXNN8HKmKYJdz92Y6tAa9Oxuuc0tU9PJel8YLFSuPF0KcowlNXIgAtgccJfTIYIrOPriGSNda(EDIwagLtEeMa9yrdWCmJCiaw3)GtkdaMJfpbWxBeOdby4upmiaCIa4bKqayVby00sV4eaJY1oaR7pjCcbyzrayVbyktNwea(AJaD6byoEb60Razlmp6fop3BlXt2KrGEgdiz7sXIMHWnVmgqYoBkmKLjqpw0CZlJOW9oEYhsYqQs8KnzeOB162elA(5Yt(qsgs5XHSEBz9jnGE07nC4YfEYhsYqkKakjdzz9jnGE0Bo8ZvyEWJS0sNGG3WLN8HKmKAsEeltGUTyKdb9p4K4NRhhIJsJsrX6tAa9OxLrGULYulE6gEYhsYqkeYiOAlg5qq)doPlx4jFijdPqcOKmKL1N0a6rV5Kd)7kXtqxENELW8GhX)U0OuutTBH(tcNQNeMZp30OuutK4XI2o0upjm)Yf2K8OjOT8cZJEfZnCNBoGSNdaMJZ4JfnaZXINGU8o9zaWCS4ja(AJaDialpbWdiHaWW4eg5nOcWEdWiJpw0a893N0a6rVkaEonT0lgdQzaW(eHkalpbWdiHaWEdWOPLEXjagLRDaw3Fs4ecWZMOfGzF4qaEwyma82oaNiaEMaDcbGLfbGNf(eaFTrGo9amhVaD6ZaG9jcvago1ddcaNiagQ9KGaW9WbyVb4JeRlXcW(ebWxBeOtpaZXlqNEaonkffiBH5rVW55EBjEYMmc0ZyajBxkw0meU5LXas2ztHHSmb6XIMBEzefUL4jOlVtVsyEWJ4ZMKhnbVHBE8VJN8HKmKQepztgb6wTUnXIMFU3jmp6vvINsIXOOmj2WJfn)7eMh9Q0q97KrGUkwBXeONC(PrPOMiXJfTDOPEsy(LlcZJEvL4PKymkktIn8yrZ)U0OuutTBH(tcNQNeMF5IW8OxLgQFNmc0vXAlMa9KZpnkf1ejESOTdn1tcZ5FxAukQP2Tq)jHt1tcZZbKTW8Ox48CVLjgJvyE0R1eqpJvoexOllI8i2VDXJEZikCZLN8HKmKYJdz92Y6tAa9O3B4qo8tJsr9JLSDXQ1ZOxH0Zwq2GSfMh9cvcZdEK1fdToKRj4flABQpPmIcxH5bpYslDccEtE8tJsrX6tAa9OxfspB5Nlp5djziLhhY6TL1N0a6rV3W62G0ZwLj4flABQpjfY4fp69YfEYhsYqkpoK1BlRpPb0JErbxoKdiBH5rVqLW8GhzDXqRdNN7ThYP(ZikCVJN8HKmKcjGsYqwwFsdOh9YNN8HKmKYJdz92Y6tAa9OxuWLdxUKlRBdspBvhYP(viJx8OxuWt(qsgs5XHSEBz9jnGE0l)7CXqRR(Xs2Uy16z0ROvsgcjNlxCXqRR(Xs2Uy16z0ROvsgcHFAukQFSKTlwTEg9QHgFEYhsYqkpoK1BlRpPb0JEVryE0R6qo1VI1TbPNTxUuc0tU9PJelef8KpKKHuECiR3wwFsdOh9cYwyE0lujmp4rwxm06W55ElYlO7fAtpj(ugrHRlgADLyOmH(lW7rG2Y4rvrRKmec)CtJsrX6tAa9OxfspB5FxAukQP2Tq)jHt1tcZZbKniBH5rVqfRpPb0JETAtcK4Ac0to0ML)ab9HwpJOWnnkffRpPb0JEvi9SfK9CaW3NqpoIta8updGn9IgGV)(Kgqp6fGNfgdaBeOdW(KSCcbyVby9XcWZPIf99fcWxBiimw0aS3amc50FILa4PEgaZXINa4Rnc0HamCQhgeaora8asikq2cZJEHkwFsdOh9A1Meinp3B5jFijdLXkhIlLPtlcHyz9jnGE0R9PJelmJwJlK8m4jMbXnnkffRpPb0JEvpDKyHZNgLII1N0a6rVkKXlE0BwNlRBdspBvS(Kgqp6v90rIfII0OuuS(Kgqp6v90rIfMdiBH5rVqfRpPb0JETAtcKMN7T8KpKKHYyLdXLY0PfHqSS(Kgqp61(0rIfMrRXvqqYGNyge3SkJOWnnkffCSwoJfn0MmeeglA7tccQQH2Ll8KpKKHuuMoTieIL1N0a6rV2NosSWBYtLvznAgI6izM15MgLIcowlNXIgAtgccJfT6izAHUW4KJsJsrbhRLZyrdTjdbHXIwbDHXzoGSfMh9cvS(Kgqp61QnjqAEU3Me02Uy9pyCcZikCtJsrX6tAa9OxfspBbzlmp6fQy9jnGE0RvBsG08CV1e8IfTn1NugrHRW8GhzPLobbVjp(PrPOy9jnGE0RcPNTGSfMh9cvS(Kgqp61QnjqAEU3EI)7hA7I17)qRNru4MgLII1N0a6rVkKE2Ypnkf1pwY2fRwpJEfspBbzlmp6fQy9jnGE0RvBsG08CVDajB40jJvoe3ju1O3NEsqSZ(a6ZErdMru4MgLII1N0a6rVQHgFH5rVQs8KnzeORytYJMGC5aFH5rVQs8KnzeOREInjpAY6XHUbndrDKmbzlmp6fQy9jnGE0RvBsG08CVnz6gX2fRprwAPdQGSfMh9cvS(Kgqp61QnjqAEU3EOt)OA7I1mybIf5j5abzlmp6fQy9jnGE0RvBsG08CVDw)geEuS2NG9klJazphamhNXhlAa((7tAa9O3mayow8eaFTrGoeGLNa4bKqayVby00sV4eaJY1oaR7pjCcbyzra4tSXjUhcG9jcGLtpwhG7ca7XHayOgToatzsSHhlAaU9j6byOgzmqfaZX6hGHUSiYJaWCS4Pmayow8eaFTrGoeGLNa4EnOcWdiHaWZMOfGr5iXJfnaFVObWbeGfMh8iaUFaE2eTaSaW6S(ztamtGoahqaowaw7B0pbHaSSiamkhjESOb47fnawweagLRDaw3Fs4eGLNa4TDawyEWJua89A4ta81gb60dWC8c0PhGLfbG5yg5qaCwUBgamhlEcGV2iqhcWmzbybbj8OxXyqfGteapGecapBkmeaJY1oaR7pjCcWYIaWOCK4XIgGVx0ay5jaEBhGfMh8iawweawa45eu)ozeOdWbeGJfG9jcGL4byzrayXaBaE2uyiaMjqpw0aSoRF2eat8OfGJcaJYrIhlAa(ErdGdialMNeeubyH5bpsbWxnraSrCNEawmMEgeG9znaJY1oaR7pjCcWZjO(DYiqhcWEdWjcGzc0b4yby4GXiim6fGLItpa7teaRZ6NnPa4SueKWJEfJbvaEw4ta81gb60dWC8c0PhGLfbG5yg5qaCwUBgamhlEcGV2iqhcWWPEyqa4TDaora8asia8yneecWxBeOtpaZXlqNEaoGaSK6HdWEdWuMAXtaC)aSprpbWYta8PFcG9jzbyA7b6jaMJfpbWxBeOdbyVbyktNwea(AJaD6byoEb60dWEdW(ebW0IaWDbGV)(Kgqp6vbYwyE0luX6tAa9OxR2KaP55EBjEYMmc0ZyajBxkw0meU5LXas2ztHHSmb6XIMBEzefUY9qF4KkzeOtV9iqNEfTsYqi8ztYJMG3Wnp(5MRW8OxvjEYMmc0vSj5rtqB5fMh9kM5ZnnkffRpPb0JEvpDKyHCuAukQKrGo92JaD6viJx8O3CUpyDBq6zRQepztgb6kKXlE0lhLBAukkwFsdOh9QE6iXcZ5(i30OuujJaD6Thb60RqgV4rVCehuzvo5CdxoC5YDY9qF4KkzeOtV9iqNEfTsYqixUCNlgADvXihY2RIwjziKlxsJsrX6tAa9Ox1thjwik4MgLIkzeOtV9iqNEfY4fp69YL0OuujJaD6Thb60RE6iXcrbhuz1LluwmcnncrnHQg9(0tcID2hqF2lAq(SUni9SvnHQg9(0tcID2hqF2lAqlkXboK3CEUQNosSquKv5WpnkffRpPb0JEvdn(5ENW8OxfK1pBsrzsSHhlA(3jmp6vPH63jJaDvS2Ijqp58tJsrnrIhlA7qtn0UCryE0RcY6NnPOmj2WJfn)0OuutTBH(tcNkKE2Yp30OuutK4XI2o0ui9S9Yf5EOpCsLmc0P3EeOtVIwjziKCUCrUh6dNujJaD6Thb60ROvsgcHVlgADvXihY2RIwjzie(cZJEvAO(DYiqxfRTyc0to)0OuutK4XI2o0ui9SLFAukQP2Tq)jHtfspBZbK9CaW3RHpbWCC3c9Rya47xGmbHYaG5yXta81gb6qago1ddcaVTdWjcGhqcbGhRHGqaMJ7wOFfdaF)cKjieahqaws9WbyVbyktT4jaUFa2NONay5ja(0pbW(KSamT9a9eaZXINa4Rnc0HaS3amLPtlcaFTrGo9amhVaD6byVbyFIayAra4UaW3FFsdOh9Qazlmp6fQy9jnGE0RvBsG08CVTepztgb6zmGKTlflAgc38Yyaj7SPWqwMa9yrZnVmIc37K7H(WjvYiqNE7rGo9kALKHq4NRW8GhzPLobbrbxH5bpYI0UkqVHtxUChRBdspBvAtnTrM2Iroeu9KGGAo8z9ImcxfBH(vmwMazccPOvsgcHpBsE0e8gU5Xp3CfMh9QkXt2KrGUInjpAcAlVW8OxXmFU8KpKKHuuMoTieIL1N0a6rV2NosSqoknkfvSf6xXyzcKjiKcz8Ih9MZ9bRBdspBvL4jBYiqxHmEXJE5iEYhsYqkktNwecXY6tAa9Ox7thjw49rUPrPOITq)kgltGmbHuiJx8OxoIdQSkNCUHlhUCHN8HKmKIY0PfHqSS(Kgqp61(0rIfIcUPrPOITq)kgltGmbHuiJx8O3lxsJsrfBH(vmwMazccPE6iXcrbhuzvo8tJsrX6tAa9Ox1qJ)DPrPOkXtqV)J6jH58Vlnkf1u7wO)KWP6jH58NA3c9NeoTqnYyG2yTftGEYNpnkf1ejESOTdn1tcZrXCbzlmp6fQy9jnGE0RvBsG08CVTepztgb6zmGKTlflAgc38Yyaj7SPWqwMa9yrZnVmIc37K7H(WjvYiqNE7rGo9kALKHq4NRW8GhzPLobbrbxH5bpYI0UkqVHtxUChRBdspBvAtnTrM2Iroeu9KGGAo8VJ1lYiCvSf6xXyzcKjiKIwjzie(Sj5rtWB4Mh)0OuuS(Kgqp6vn04FxAukQs8e07)OEsyo)7sJsrn1Uf6pjCQEsyo)P2Tq)jHtluJmgOnwBXeON85tJsrnrIhlA7qt9KWCumxq2cZJEHkwFsdOh9A1Meinp3Bz9yD6HAKXKru4(JLk9JMuibKfAMyLhvlRphzruuwmcnncHFAukkKaYcntSYJQL1NJSikKE2YpnkffsazHMjw5r1Y6ZrweR8mzjfspB5Z62G0ZwvAukwKaYcntSYJQL1NJSiQNeeubzlmp6fQy9jnGE0RvBsG08CVvEMSKLYuZ0WO3mIc3FSuPF0KcjGSqZeR8OAz95ilIIYIrOPri8tJsrHeqwOzIvEuTS(CKfrH0Zw(PrPOqcil0mXkpQwwFoYIyLNjlPq6zlFw3gKE2QsJsXIeqwOzIvEuTS(CKfr9KGGkiBH5rVqfRpPb0JETAtcKMN7TLVHEQnEgrH7pwQ0pAsHeqwOzIvEuTS(CKfrrzXi00ie(PrPOqcil0mXkpQwwFoYIOq6zl)0OuuibKfAMyLhvlRphzrSLVHUcPNTGSfMh9cvS(Kgqp61QnjqAEU3YeJXkmp61AcONXkhIRW8GhzDXqRdbzlmp6fQy9jnGE0RvBsG08CVL1N0a6rVzmGKTlflAgc38Yyaj7SPWqwMa9yrZnVmIc30OuuS(Kgqp6vH0Zw(5(JLk9JMuibKfAMyLhvlRphzruuwmcnncHBAukkKaYcntSYJQL1NJSiQHwo8ZvyE0R6qo1VkwBXeONC(cZJEvhYP(vXAlMa9KBF6iXcrbxoOYQlxeMh9QGS(ztkktIn8yrZxyE0RcY6NnPOmj2Wj7thjwik4GkRUCryE0RQepLeJrrzsSHhlA(cZJEvL4PKymkktInCY(0rIfIcoOYQlxeMh9Q0q97KrGUIYKydpw08fMh9Q0q97KrGUIYKydNSpDKyHOGdQSkhq2cZJEHkwFsdOh9A1Meinp3B1Ap6nJOWnnkffRpPb0JEvgb6wktT4juWvyE0RI1N0a6rVkJaD7asiGSfMh9cvS(Kgqp61QnjqAEU3MmDJylJh1mIc30OuuS(Kgqp6vzeOBPm1INqbxH5rVkwFsdOh9Qmc0TdiHaYwyE0luX6tAa9OxR2KaP55EBIEi9Cgl6mIc30OuuS(Kgqp6vzeOBPm1INqbxH5rVkwFsdOh9Qmc0TdiHaYwyE0luX6tAa9OxR2KaP55EBjEkz6gjJOWnnkffRpPb0JEvgb6wktT4juWvyE0RI1N0a6rVkJaD7asiGSfMh9cvS(Kgqp61QnjqAEU3klJG(lgltmMmIc30OuuS(Kgqp6vzeOBPm1INqbxH5rVkwFsdOh9Qmc0TdiHaYwyE0luX6tAa9OxR2KaP55E7as2WPdmJOWnnkffRpPb0JEvgb6wktT4juWvyE0RI1N0a6rVkJaD7asiGSfMh9cvS(Kgqp61QnjqAEU36XHSZKxlJOW9hlv6hnPC6O1VySZKxtrzXi00ie(PrPOy9jnGE0RYiq3szQfpHcUcZJEvS(Kgqp6vzeOBhqcHFUW20xUKgLIIYCsgqp6vn0YbKTW8OxOI1N0a6rVwTjbsZZ92Iroe0)GtkJOWn30OuutTBH(tcNQNeMF5sAukQs8e07)OEsyEo8fMh8ilT0ji4nC5jFijdPy9jnGE0RTyKdb9p4Kazlmp6fQy9jnGE0RvBsG08CVvd1Vtgb6zefUPrPOGJ1YzSOH2KHGWyrBFsqqvn04NgLIcowlNXIgAtgccJfT9jbbv1thjw4nmb6wpoeiBH5rVqfRpPb0JETAtcKMN7TAO(DYiqpJOWnnkfvjEc69FupjmhKTW8OxOI1N0a6rVwTjbsZZ9wnu)ozeONru4MgLIsd1VzgbEupjmNFAukknu)Mze4r90rIfEdtGU1JdXp30OuuS(Kgqp6v90rIfEdtGU1JdD5sAukkwFsdOh9Qq6zBoGSfMh9cvS(Kgqp61QnjqAEU3QH63jJa9mIc30OuutTBH(tcNQNeMZpnkffRpPb0JEvdnq2cZJEHkwFsdOh9A1Meinp3B1q97KrGEgrHR2t8SOziQ8uqw)Sj(PrPOMiXJfTDOPEsyoiBH5rVqfRpPb0JETAtcKMN7TAtnTrM2IroemJOWnnkffRpPb0JEvdn(5MRW8OxvjEYMmc0vSj5rtquKhFxm06knu)Mze4rrRKmecFH5bpYslDccYnVCUC5oxm06knu)Mze4rrRKmeYLlcZdEKLw6ee8M8YbKTW8OxOI1N0a6rVwTjbsZZ92s8usmMmIc30OuuS(Kgqp6vH0Zw(SUni9SvX6tAa9Ox1thjwikyc0TECi(3X6fzeUQyKdzfg7jp6vrRKmeciBH5rVqfRpPb0JETAtcKMN7Tqw)SPmIc30OuuS(Kgqp6v90rIfEdtGU1JdXpnkffRpPb0JEvdTlxsJsrX6tAa9OxfspB5Z62G0ZwfRpPb0JEvpDKyHOGjq36XHazlmp6fQy9jnGE0RvBsG08CV1e8IfTn1NugrHBAukkwFsdOh9QE6iXcrbAgI6izYxyEWJS0sNGG3KhiBH5rVqfRpPb0JETAtcKMN7TiVGUxOn9K4tzefUPrPOy9jnGE0R6PJelefOziQJKj)0OuuS(Kgqp6vn0azlmp6fQy9jnGE0RvBsG08CVfY6NnLru46YJMC1ejgFsPXCuWfL4aFxm06kijFSOTEpytkALKHqazdYwyE0lu9TMvBsGe3Iroe0)GtkJOWnxH5bpYslDccEdxEYhsYqQP2Tq)jHtBXihc6FWjXpxpoehLgLII1N0a6rVkJaDlLPw80n8KpKKHuiKrq1wmYHG(hCsxUWt(qsgsHeqjzilRpPb0JEZjh(5MgLIAQDl0Fs4u9KW8lxsJsrvINGE)h1tcZZbKTW8OxO6BnR2KaP55ERgQFNmc0ZikCtJsrbhRLZyrdTjdbHXI2(KGGQAOXpnkffCSwoJfn0MmeeglA7tccQQNosSWByc0TECiq2cZJEHQV1SAtcKMN7TAO(DYiqpJOWnnkfvjEc69FupjmhKTW8OxO6BnR2KaP55ERgQFNmc0ZikCtJsrn1Uf6pjCQEsyoiBH5rVq13AwTjbsZZ92s8KnzeONXas2UuSOziCZlJbKSZMcdzzc0Jfn38YikCtJsrbhRLZyrdTjdbHXI2(KGGQcPNT8VlxH5bpYslDccEdxEYhsYqQj5rSmb62Iroe0)GtIFUECioknkffRpPb0JEvgb6wktT4PB4jFijdPqiJGQTyKdb9p4KYjh(3vINGU8o9kH5bpIFU3LgLIAIepw02HM6jH58Vlnkf1u7wO)KWP6jH58Vt7jE2UuSOziQs8KnzeOZpxH5rVQs8KnzeORytYJMG3WDUxUKRlgADLyOmH(lW7rG2Y4rvrRKmecFw3gKE2QqEbDVqB6jXNupjiOMZLl56IHwxbj5JfT17bBsrRKmecFxE0KRMiX4tknMJcUOehYjNCazlmp6fQ(wZQnjqAEU3wINSjJa9mgqY2LIfndHBEzmGKD2uyiltGESO5MxgrH7DL4jOlVtVsyEWJ4NBU5kmp6vvINsIXOOmj2WJf9LlcZJEvAO(DYiqxrzsSHhl6C4NgLIAIepw02HM6jH55C5sUUyO1vqs(yrB9EWMu0kjdHW3Lhn5Qjsm(KsJ5OGlkXb(5MgLIAIepw02HM6jH58VtyE0RcY6NnPOmj2WJf9Ll3LgLIAQDl0Fs4u9KWC(3LgLIAIepw02HM6jH58fMh9QGS(ztkktIn8yrZ)UP2Tq)jHtluJmgOnwBXeON8CYjhq2cZJEHQV1SAtcKMN7TmXyScZJETMa6zSYH4kmp4rwxm06qq2cZJEHQV1SAtcKMN7TAO(DYiqpJOWnnkfLgQFZmc8OEsyoFMaDRhhcfPrPO0q9BMrGh1thjwiFMaDRhhcfPrPO(Xs2Uy16z0RE6iXcbzlmp6fQ(wZQnjqAEU3QH63jJa9mIcxTN4zrZqu5PGS(zt8tJsrnrIhlA7qt9KWC(UyO1vqs(yrB9EWMu0kjdHW3Lhn5Qjsm(KsJ5OGlkXb(3LRW8GhzPLobbVHlp5djzi1u7wO)KWPTyKdb9p4K4NRhhIJsJsrX6tAa9OxLrGULYulE6gEYhsYqkeYiOAlg5qq)doPCYbKTW8OxO6BnR2KaP55ER2utBKPTyKdbZikCVJN8HKmKsBQPnY0Q1Tjw08tJsrnrIhlA7qt9KWC(3LgLIAQDl0Fs4u9KWC(5kmp4rwK2vb6nCcfZ9YfH5bpYslDccEdxEYhsYqQj5rSmb62Iroe0)Gt6YfH5bpYslDccEdxEYhsYqQP2Tq)jHtBXihc6FWjLdiBH5rVq13AwTjbsZZ9wiRF2ugrHRlpAYvtKy8jLgZrbxuId8DXqRRGK8XI269GnPOvsgcbKTW8OxO6BnR2KaP55ER8mzjlLPMPHrVzefUcZdEKLw6ee8gU8KpKKHuYZKLSuMAMgg9Y)iRO0y(nC5jFijdPKNjlzPm1mnm61EKvazlmp6fQ(wZQnjqAEU3wmYHG(hCszefU5kmp4rwAPtqWB4Yt(qsgsnjpILjq3wmYHG(hCs8Z1JdXrPrPOy9jnGE0RYiq3szQfpDdp5djzifczeuTfJCiO)bNuo5aYwyE0lu9TMvBsG08CVTepLeJbKniBH5rVqf0LfrEe73U4rVClg5qq)doPmIc3CfMh8ilT0ji4nC5jFijdPMA3c9NeoTfJCiO)bNe)C94qCuAukkwFsdOh9Qmc0TuMAXt3Wt(qsgsHqgbvBXihc6FWjD5cp5djzifsaLKHSS(Kgqp6nNC4NBAukQP2Tq)jHt1tcZVCjnkfvjEc69Fupjmphq2cZJEHkOllI8i2VDXJENN7TAO(DYiqpJOWnnkfvjEc69FupjmhKTW8OxOc6YIipI9Bx8O355ERgQFNmc0ZikCtJsrn1Uf6pjCQEsyo)0OuutTBH(tcNQNosSquimp6vvINsIXOOmj2WjRhhcKTW8OxOc6YIipI9Bx8O355ERgQFNmc0ZikCtJsrn1Uf6pjCQEsyo)C1EINfndrLNQepLeJ5YLs8e0L3Pxjmp4rxUimp6vPH63jJaDvS2Ijqp55aYEoa4REubyVby0KdW6ZPUgG1(Mbb4yHbcbWz50ZjaS2Kajia3paF)9jnGE0laRnjqccWZMOfG1AimsgsbYwyE0lubDzrKhX(TlE078CVvd1Vtgb6zefUPrPOGJ1YzSOH2KHGWyrBFsqqvn04NlRBdspBv)yjBxSA9m6vpDKyHZlmp6v9JLSDXQ1ZOxrzsSHtwpo08mb6wpo0nPrPOGJ1YzSOH2KHGWyrBFsqqv90rIfE5YDUyO1v)yjBxSA9m6v0kjdHKdFEYhsYqkpoK1BlRpPb0JENNjq36XHUjnkffCSwoJfn0MmeeglA7tccQQNosSqq2cZJEHkOllI8i2VDXJENN7TAO(DYiqpJOWnnkf1u7wO)KWP6jH58D5rtUAIeJpP0yok4IsCGVlgADfKKpw0wVhSjfTsYqiGSfMh9cvqxwe5rSF7Ih9op3B1q97KrGEgrHBAukknu)Mze4r9KWC(mb6wpoeksJsrPH63mJapQNosSqq2cZJEHkOllI8i2VDXJENN7TL4jBYiqpJbKSDPyrZq4MxgdizNnfgYYeOhlAU5Lru4ExjEc6Y70ReMh8i(3Xt(qsgsvINSjJaDRw3MyrZp3CZvyE0RQepLeJrrzsSHhl6lxeMh9Q0q97KrGUIYKydpw05Wpnkf1ejESOTdn1tcZZ5YLCDXqRRGK8XI269GnPOvsgcHVlpAYvtKy8jLgZrbxuId8Znnkf1ejESOTdn1tcZ5FNW8OxfK1pBsrzsSHhl6lxUlnkf1u7wO)KWP6jH58Vlnkf1ejESOTdn1tcZ5lmp6vbz9ZMuuMeB4XIM)DtTBH(tcNwOgzmqBS2Ijqp55KtoGSfMh9cvqxwe5rSF7Ih9op3B1q97KrGEgrHR2t8SOziQ8uqw)Sj(PrPOMiXJfTDOPEsyoFxm06kijFSOTEpytkALKHq47YJMC1ejgFsPXCuWfL4a)7YvyEWJS0sNGG3WLN8HKmKAQDl0Fs40wmYHG(hCs8Z1JdXrPrPOy9jnGE0RYiq3szQfpDdp5djzifczeuTfJCiO)bNuo5aYwyE0lubDzrKhX(TlE078CVvBQPnY0wmYHGzefU3Xt(qsgsPn10gzA162elA(5ENlgADv57J1NiRaNiOIwjziKlxeMh8ilT0ji4n5Ld)CfMh8ilT0ji4n5XxyEWJSiTRc0B4ekM7LlcZdEKLw6ee8gU8KpKKHutYJyzc0TfJCiO)bN0LlcZdEKLw6ee8gU8KpKKHutTBH(tcN2Iroe0)Gtkhq2cZJEHkOllI8i2VDXJENN7TmXyScZJETMa6zSYH4kmp4rwxm06qq2cZJEHkOllI8i2VDXJENN7TiVGUxOn9K4tzefUcZdEKLw6ee8M8azlmp6fQGUSiYJy)2fp6DEU3cz9ZMYikCD5rtUAIeJpP0yok4IsCGVlgADfKKpw0wVhSjfTsYqiGSfMh9cvqxwe5rSF7Ih9op3BLNjlzPm1mnm6nJOWvyEWJS0sNGG3WLN8HKmKsEMSKLYuZ0WOx(hzfLgZVHlp5djziL8mzjlLPMPHrV2JSci75aGVxdFcGPThONayxE0KdZaGdhGdialamAjwa2BaMjqhG5yg5qq)dojawGaCjmg6b4yHojiaCxayow8usmgfiBH5rVqf0LfrEe73U4rVZZ92Iroe0)GtkJOWvyEWJS0sNGG3WLN8HKmKAsEeltGUTyKdb9p4K4NRhhIJsJsrX6tAa9OxLrGULYulE6gEYhsYqkeYiOAlg5qq)doPCazlmp6fQGUSiYJy)2fp6DEU3wINsIXaYwyE0lubDzrKhX(TlE078CVfY6Nnv1HAeRM)9gLQE1Rva]] )

end
