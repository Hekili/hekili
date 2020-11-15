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
            max_stack = 5
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
                if legendary.triune_ward.enabled then
                    applyBuff( "ice_barrier" )
                    applyBuff( "prismatic_barrier" )
                end
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
                if legendary.grisly_icicle.enabled then applyDebuff( "target", "grisly_icicle" ) end
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


    spec:RegisterPack( "Fire", 20201114, [[davI3cqivQ8iuvQljcjTjr0NqvjnkvsoLkPwLieVssXSqfDlrOSls9lvIggOshtKyzQe6zOc10ujGRHQcBduH6BOQOmori15qfswhQkI5Psv3dvzFOc(hQkb1brvr1cfP8qrOAIGkixeuHyJQe0hbvGAKQeOtcQqALIGxcQGAMIqIBIQs0ofP6NOQeyOOQiTuuvc9usmvjLUkQqQVcQaglQkbzVs8xkgmuhMyXI6XOmzqUmYMv4ZGYOLKtlSAqfiVgvvZMs3wf7wPFl1WjPJdQOLd8CitNQRROTJk9DjvJxK05vPSEuHy(GQ2VQUKsP2IcK4uj9lc3lc3usjLlGoLenCt0xmLIIFtLkkQcJFbgvuw5qfLlmaurrvUzBbQuBrb1taJkkvURI4tU8syHxnZAwFUefNPv8Oxgqg(LO4WUSOKNH1HJULCrbsCQK(fH7fHBkPKYfqNsIgUj6lwuKPx1GIIsCs8IsvabrBjxuGieROW3p(cda9y(sbg9jW3pUYDveFYLxcl8QzwZ6ZLO4mTIh9YaYWVefh2LFc89JtV5sNmbECkxaoF8fH7fH7NWNaF)4eVswyeIp5tGVFCI9yoAe94raRYna6iXIEmq8kc8yVs2h7cag5ApoKXBduqpE0GhBfKNyiI1l0JLCyd)2JNibgH0Fc89JtShZrRcjo9yBdlypgq8jporzYcOhdhcqYbP)e47hNyporPBeTpMji)XacoNbGo06OhpAWJt8(KNip69XxfAsZ5JH6LV6pUQTqpo8hpAWJLhpaeQ6X8LKtn4Xmb5xR)e47hNypgouGKSLESSpMwhC7XEL4pUEpTqpgqOP1FCSpwECLaGycYFmF6nqNTcYFCSjgm5q6pb((Xj2JHJSs2spg5GG5pMvrm(Jf2J79XYJhu9hpAa)Ohh7J9k6X858Pjkp27hdiOjJEC9gWVTfiDrXgihvQTOaAvJALGOsTL0tPuBrHwjBjOsAffgiCcesrryEWLm0sNGqpMd8Emxbes2s6Q2nihqc)MHvoeYbb)0Jt(4RECEog6Q2nihqc)Aajm)XWd)JZZXqpcaH8gC0asy(JVUOimp6TOmSYHqoi4NkEj9lwQTOqRKTeujTIcdeobcPOKNJHgnxd)XcdzYwcHIfMbqc0n9u9XjFCEogA0Cn8hlmKjBjekwygajq30a6iXIEmhEmtqUXJdvueMh9wuuVb6SvqEXlPZXLAlk0kzlbvsROWaHtGqkk55yOhbGqEdoAajmVOimp6TOOEd0zRG8Ixs)cuQTOqRKTeujTIcdeobcPOKNJHUQDdYbKWVgqcZlkcZJElkQ3aD2kiV4L05JsTffALSLGkPvuMiYuVkSKHjipwyL0tPOWaHtGqkk55yOrZ1WFSWqMSLqOyHzaKaDtd113hN8XcZdUKHw6ee6X3)yUciKSL0vcaYWeKBgw5qihe8tpo5JV7XJaqixaob0cZdU0Jt(4RE8DpophdDfjESWmtvnGeM)4Kp(UhNNJHUQDdYbKWVgqcZFCYhF3Jvbextpggymi9iaKjBfK)4Kp(Qhlmp6vpcazYwb5AwLaGrOhZbEp(IpgE4F8vp2flTUwSuQihiioIGmJj4MMwjBjOhN8XSUTqD9vdbey9ImzajELgqc0ThF9JHh(hF1JDXsRRrKaIfMX7jRstRKTe0Jt(yxaWixxrI1R0Qm)X3Z7XCmCF81p(6hFDrzIitpggymOs6PuueMh9wugbGmzRG8IxshoUuBrHwjBjOsAfLjIm1RclzycYJfwj9ukkmq4eiKIYDpEeac5cWjGwyEWLECYhF1JV6Xx9yH5rV6raOSyTAkvIn9yH94Kp(Qhlmp6vpcaLfRvtPsSPtgaDKyrp((hdxnF8y4H)X39yWCPrdGr6raiK3GJMGZzOQsqp(6hdp8pwyE0Rw9gOZwb5AkvIn9yH94Kp(Qhlmp6vREd0zRGCnLkXMoza0rIf947FmC18XJHh(hF3JbZLgnagPhbGqEdoAcoNHQkb94RF81po5JZZXqxrIhlmZuvdiH5p(6hdp8p(Qh7ILwxJibelmJ3twLMwjBjOhN8XUaGrUUIeRxPvz(JVN3J5y4(4Kp(QhNNJHUIepwyMPQgqcZFCYhF3JfMh9QrSgWQ0uQeB6Xc7XWd)JV7X55yORA3GCaj8RbKW8hN8X3948Cm0vK4XcZmv1asy(Jt(yH5rVAeRbSknLkXMESWECYhF3JRA3GCaj8BqQK1ImXAg2awL)4RF81p(6IYerMEmmWyqL0tPOimp6TOmcazYwb5fVKoFwP2IcTs2sqL0kkcZJElkmXAncZJEn2a5ffBGCZkhQOimp4sgxS06OIxsprxQTOqRKTeujTIcdeobcPOKNJHw9gOzwbD0asy(Jt(yMGCJhh6X3)48Cm0Q3anZkOJgqhjw0Jt(yMGCJhh6X3)48Cm0G5sMEyu76eqdOJelQOimp6TOOEd0zRG8IxsNJQuBrHwjBjOsAffgiCcesrrfqCnWyq6u0iwdyvpo5JZZXqxrIhlmZuvdiH5po5JDXsRRrKaIfMX7jRstRKTe0Jt(yxaWixxrI1R0Qm)X3Z7XCmCFCYhlmp4sgAPtqOhF)J5kGqYwsx1Ub5as43mSYHqoi4NkkcZJElkQ3aD2kiV4L0tbULAlk0kzlbvsROWaHtGqkk39yUciKSL0QvnTrQg1UTXc7XjFCEog6ks8yHzMQAajm)XjF8DpophdDv7gKdiHFnGeM)4Kp(Qhlmp4sgO21bSnC6X3)4l(y4H)XcZdUKHw6ee6XCG3J5kGqYwsxjaidtqUzyLdHCqWp9y4H)XcZdUKHw6ee6XCG3J5kGqYwsx1Ub5as43mSYHqoi4NE81ffH5rVff1QM2ivZWkhcv8s6PKsP2IcTs2sqL0kkmq4eiKIIlayKRRiX6vAvM)4759yogUpo5JDXsRRrKaIfMX7jRstRKTeurryE0BrbXAaRQ4L0t5ILAlk0kzlbvsROWaHtGqkkcZdUKHw6ee6XCG3J5kGqYwslaMSKHsv12OO3hN8XhzfTkZFmh49yUciKSL0cGjlzOuvTnk61CKvkkcZJElkcGjlzOuvTnk6T4L0tHJl1wuOvYwcQKwrHbcNaHuueMhCjdT0ji0J5aVhZvaHKTKUsaqgMGCZWkhc5GGFQOimp6TOmSYHqoi4NkEj9uUaLAlkcZJElkJaqzXAlk0kzlbvsR4fVOardzA9sTL0tPuBrHwjBjOsAffgiCcesr5UhdMlnAamsdfiwOAJva3mS(CKfstW5muvjOIIW8O3IcRNRtaKkzTfVK(fl1wuOvYwcQKwrPvlkiYlkcZJElkCfqizlvu4k2jvuCXsRRhbGqUaCcOPvYwc6XjYJhbGqUaCcOb0rIf94AE8vpM1TfQRVAwFYtKh9Qb0rIf94e5Xx94uECI9yUciKSL08hlKnwygabnzE07JtKh7ILwxZFSq2yHPPvYwc6Xx)4RFCI847EmRBluxF1S(KNip6vdib62JtKhNNJHM1N8e5rVAOU(wu4kaZkhQO4XHmEBy9jprE0BXlPZXLAlk0kzlbvsRO0QfLJKArryE0BrHRacjBPIcxXoPIcxbes2sA6OEdqI10aOvwgzGiRC7Xj2JV6XSUTqD9vth1BasSMgaTYYin0eiE07JtShZ62c11xnDuVbiXAAa0klJ0a6iXIE81porE8DpM1TfQRVA6OEdqI10aOvwgPbKaDROWaHtGqkkeCodvvcsth1BasSMgaTYYOIcxbyw5qffpoKXBdRp5jYJElEj9lqP2IcTs2sqL0kkmq4eiKIsEogAwFYtKh9QH667Jt(48Cm0G5sMEyu76eqd113hN8XSUTqD9vZ6tEI8OxnGosSOhZHhd3IIW8O3IcQkgESWmQDDcu8s68rP2IcTs2sqL0kkmq4eiKIYvpophdnRp5jYJE1qD99XjFCEogAWCjtpmQDDcOH667Jt(4REmRBluxF1S(KNip6vdOJel6X3)ykvInDY4XHEm8W)yw3wOU(Qz9jprE0Rgqhjw0J5WJzDBH66RgiqHSUbPka(1qtG4rVp(6hF9JHh(hF1JZZXqdMlz6HrTRta9u9XjFmRBluxF1S(KNip6vdOJel6XC4XCmCF81ffH5rVffGafY6gKQa4V4L0HJl1wuOvYwcQKwrHbcNaHuuYZXqZ6tEI8OxnuxFFCYhNNJHgmxY0dJAxNaAOU((4KpM1TfQRVAwFYtKh9Qb0rIf947FmLkXMoz84qffH5rVffis8QCdwQ4L05Zk1wuOvYwcQKwrHbcNaHuuYZXqZ6tEI8OxnuxFFCYhdr55yObcuiRBqQcGFd3PDjGKdB430qD9TOimp6TOCcaObM4iWOIxsprxQTOqRKTeujTIIW8O3IcmRafI3aKjlqWOIcdeobcPOWvaHKTK2Jdz82W6tEI8O3hZHhlmp61W62c113hNypMpkk0yqm3SYHkkWScuiEdqMSabJkEjDoQsTffALSLGkPvueMh9wuOJ6najwtdGwzzurHbcNaHuu4kGqYws7XHmEBy9jprE07JVN3J5kGqYwsth1BasSMgaTYYidezLBfLvourHoQ3aKynnaALLrfVKEkWTuBrHwjBjOsAffH5rVffupTMa2gobkkmq4eiKIcxbes2sApoKXBdRp5jYJEFmh49yUciKSL09AMiYWMEpgfLvourb1tRjGTHtGIxspLuk1wuOvYwcQKwrryE0BrbM9MALPhgbHItyfp6TOWaHtGqkkCfqizlP94qgVnS(KNip69XCG3J5kGqYws3RzIidB69yuuw5qffy2BQvMEyeekoHv8O3IxspLlwQTOqRKTeujTIIW8O3IYrysgqgufrU5mrbROWaHtGqkkCfqizlP94qgVnS(KNip69X3Z7X8rrzLdvuoctYaYGQiYnNjkyfVKEkCCP2IcTs2sqL0kkcZJElkqasGgbGmCjeISffgiCcesrHRacjBjThhY4TH1N8e5rVpMd8Emxbes2s6EntezytVhJIYkhQOabibAeaYWLqiYw8s6PCbk1wuOvYwcQKwrryE0Brr4iOkbiiZOx30dJAxNaffgiCcesrHRacjBjThhY4TH1N8e5rVp(EEpMpECnpof(4XjYJ5kGqYwsp61nq9mBjtVMjIECYhZvaHKTK2Jdz82W6tEI8O3hZHhd3IYkhQOiCeuLaeKz0RB6HrTRtGIxspf(OuBrHwjBjOsAffgiCcesr5QhZvaHKTK2Jdz82W6tEI8O3hF)JtbUpgE4F8iGv5gaDKyrp((hZvaHKTK2Jdz82W6tEI8O3hFDrryE0Brb2uaqHSMEyeocbAVQ4L0tboUuBrryE0BrH1lJwhiobzgw5qffALSLGkPv8s6PWNvQTOimp6TOairnwyMHvoeQOqRKTeujTIxspLeDP2IIW8O3IYOztebzeocbcNmzsoffALSLGkPv8s6PWrvQTOimp6TOOobX4wSWmzRG8IcTs2sqL0kEj9lc3sTffH5rVffqOQAjtSgKQWOIcTs2sqL0kEj9lMsP2IIW8O3IIxrM5M75czgnGrffALSLGkPv8s6x8ILAlk0kzlbvsROWaHtGqkkG5sJgaJ0qbIfQ2yfWndRphzH0eCodvvc6XjFmRBluxF155yyGceluTXkGBgwFoYcPbKaD7XjFCEogAOaXcvBSc4MH1NJSqgbWKL0qD99XjFmRBluxF1S(KNip6vdOJel6XC4XCmCFCYhF3JZZXqdfiwOAJva3mS(CKfspvlkcZJElkSEUobqQK1w8s6xKJl1wuOvYwcQKwrHbcNaHuuaZLgnagPHceluTXkGBgwFoYcPj4CgQQe0Jt(yw3wOU(QZZXWafiwOAJva3mS(CKfsdib62Jt(48Cm0qbIfQ2yfWndRphzHmcGjlPH667Jt(yw3wOU(Qz9jprE0Rgqhjw0J5WJ5y4(4Kp(UhNNJHgkqSq1gRaUzy95ilKEQwueMh9wueatwYqPQABu0BXlPFXlqP2IcTs2sqL0kkmq4eiKIcyU0ObWinuGyHQnwbCZW6ZrwinbNZqvLGECYhZ62c11xDEoggOaXcvBSc4MH1NJSqAajq3ECYhNNJHgkqSq1gRaUzy95ilKzaAKRH667Jt(yw3wOU(Qz9jprE0Rgqhjw0J5WJ5y4(4Kp(UhNNJHgkqSq1gRaUzy95ilKEQwueMh9wugGg5526fVK(f5JsTffALSLGkPvuyGWjqifL8Cm0G5sMEyu76eqd113hN8Xx9yUciKSL0ECiJ3gwFYtKh9(yo848Cm0G5sMEyu76eqdnbIh9(4KpMRacjBjThhY4TH1N8e5rVpMdpwyE0REeaYKTcY1JP1AaeRsaWiJhh6XWd)J5kGqYws7XHmEBy9jprE07J5WJhbSk3aOJel6XxxueMh9wuaZLm9WO21jqXlPFr44sTffALSLGkPvuyGWjqifL7Emxbes2sAOajzlzy9jprE07Jt(yUciKSL0ECiJ3gwFYtKh9(4759y4wueMh9wuyI1AeMh9ASbYlk2a5MvourH1N8e5rVg1kbrfVK(f5Zk1wuOvYwcQKwrPvlkiYlkcZJElkCfqizlvu4k2jvuU7XCfqizlPHcKKTKH1N8e5rVpo5J5kGqYws7XHmEBy9jprE07JV)XcZJE1JaqMSvqUEmTwdGyvcagz84qpoXEmxbes2sAuvm8yHzu76eWaiOjZJEFCI84REmRBluxF1OQy4XcZO21jGgqhjw0JV)XCfqizlP94qgVnS(KNip69Xx)4KpMRacjBjThhY4TH1N8e5rVp((hpcyvUbqhjwurHRamRCOIYiaKjBfKBu72glSIxs)Ij6sTffALSLGkPvuA1IcI8IIW8O3Icxbes2sffUIDsfL7Emxbes2sAOajzlzy9jprE07Jt(yUciKSL0ECiJ3gwFYtKh9(47FSW8OxTAvtBKQzyLdH0JP1AaeRsaWiJhh6Xj2J5kGqYwsJQIHhlmJAxNagabnzE07JtKhF1JzDBH66Rgvfdpwyg1Uob0a6iXIE89pMRacjBjThhY4TH1N8e5rVp(6hN8XCfqizlP94qgVnS(KNip69X3)4raRYna6iXIEm8W)yWCPrdGrA0Cn8hlmKjBjekwyAcoNHQkbvu4kaZkhQOOw10gPAu72glSIxs)ICuLAlk0kzlbvsROWaHtGqkk55yObZLm9WO21jGEQ(4Kp(QhZvaHKTK2Jdz82W6tEI8O3hZHhd3hFDrryE0BrHjwRryE0RXgiVOydKBw5qffqRAuReev8s6CmCl1wuOvYwcQKwrPvlkiYlkcZJElkCfqizlvu4k2jvuU7XCfqizlPHcKKTKH1N8e5rVpo5J5kGqYws7XHmEBy9jprE07JV)XcZJE1QvnTrQMHvoespMwRbqSkbaJmECOhN8XCfqizlP94qgVnS(KNip69X3)4raRYna6iXIEm8W)yWCPrdGrA0Cn8hlmKjBjekwyAcoNHQkbvu4kaZkhQOOw10gPAu72glSIxsNJtPuBrHwjBjOsAfLjIm1RclzycYJfwj9ukkmq4eiKIYDpMRacjBj9iaKjBfKBu72glShN8Xx9yUciKSL0ECiJ3gwFYtKh9(yo8y4(y4H)XCfqizlPHcKKTKH1N8e5rVp(6hN8XcZdUKHw6ee6XCG3J5kGqYwsxjaidtqUzyLdHCqWp94Kp(UhpcaHCb4eqlmp4spo5JV7X55yORA3GCaj8RbKW8hN8Xx948Cm0vK4XcZmv1asy(Jt(yH5rV6HvoeYbb)KMsLytNma6iXIE89pgUA(4XWd)JzvcagHmdGW8OxX(yoW7Xx8XxxuMiY0JHbgdQKEkffH5rVfLrait2kiV4L054lwQTOqRKTeujTIYerM6vHLmmb5XcRKEkffgiCcesrzeac5cWjGwyEWLECYhZQeamc9yoW7XP84Kp(UhZvaHKTKEeaYKTcYnQDBJf2Jt(4RE8DpwyE0REeaklwRMsLytpwypo5JV7XcZJE1Q3aD2kixhRzydyv(Jt(48Cm0vK4XcZmv1asy(JHh(hlmp6vpcaLfRvtPsSPhlShN8X3948Cm0vTBqoGe(1asy(JHh(hlmp6vREd0zRGCDSMHnGv5po5JZZXqxrIhlmZuvdiH5po5JV7X55yORA3GCaj8RbKW8hFDrzIitpggymOs6PuueMh9wugbGmzRG8IxsNJ54sTffALSLGkPvuyGWjqifLREmxbes2sApoKXBdRp5jYJEFmhEmCF81po5JZZXqdMlz6HrTRtanuxFlkcZJElkmXAncZJEn2a5ffBGCZkhQOGCzHeaKb0U4rVfV4ffvaX6tw8sTL0tPuBrryE0BrramzjtSozTeZlk0kzlbvsR4L0VyP2IcTs2sqL0kkTArbrErryE0BrHRacjBPIcxXoPIYfFCI8yxS066HvoKrvCwLMwjBjOhxZJ54hNip(Uh7ILwxpSYHmQIZQ00kzlbvuyGWjqiffUciKSL0vTBqoGe(ndRCiKdc(PhZ7XWTOWvaMvourPQDdYbKWVzyLdHCqWpv8s6CCP2IcTs2sqL0kkTArbrErryE0BrHRacjBPIcxXoPIYfFCI8yxS066HvoKrvCwLMwjBjOhxZJ54hNip(Uh7ILwxpSYHmQIZQ00kzlbvuyGWjqiffUciKSL0vcaYWeKBgw5qihe8tpM3JHBrHRamRCOIsLaGmmb5MHvoeYbb)uXlPFbk1wuOvYwcQKwrPvlkiYlkcZJElkCfqizlvu4k2jvu44hNip2flTUEyLdzufNvPPvYwc6X18y44hNip(Uh7ILwxpSYHmQIZQ00kzlbvuyGWjqiffUciKSL0S(KNip61mSYHqoi4NEmVhd3Icxbyw5qffwFYtKh9Agw5qihe8tfVKoFuQTOqRKTeujTIsRwuqKxueMh9wu4kGqYwQOWvStQOWrXr94e5XUyP11dRCiJQ4SknTs2sqpUMhFXhNip(Uh7ILwxpSYHmQIZQ00kzlbvuyGWjqiffUciKSL0cGjlzOuvTnk69X8EmClkCfGzLdvueatwYqPQABu0BXlPdhxQTOqRKTeujTIsRwuaeI8IIW8O3Icxbes2sffUcWSYHkkcGjlzOuvTnk61CKvkkq0qMwVOCbGBXlPZNvQTOqRKTeujTIsRwuaeI8IIW8O3Icxbes2sffUcWSYHkkqKvUzgw5qihe8tffiAitRxuGBXlPNOl1wuOvYwcQKwrPvlkacrErryE0BrHRacjBPIcxbyw5qff(JfYglmdGGMmp6TOardzA9IcC1xS4L05Ok1wuOvYwcQKwrPvlkiYlkcZJElkCfqizlvu4k2jvueMh9QrvXWJfMrTRtandcuuyGWjqiffwZLwzD9gWQCZqOIcxbyw5qffuvm8yHzu76eWaiOjZJElEj9uGBP2IcTs2sqL0kkTArbrErryE0BrHRacjBPIcxXoPIcFuu4kaZkhQOG4pBGMaXJElEj9usPuBrHwjBjOsAfLwTOGiVOimp6TOWvaHKTurHRyNurHGZzOQsq6JWKmGmOkICZzIc2JHh(htW5muvji9r2yqiVn9WCeOLqOhdp8pMGZzOQsqAywbkeVbitwGGrpgE4FmbNZqvLG0WScuiEdqMdbjwB07JHh(htW5muvjiDaBdp61CeyeYmMi6XWd)Jj4CgQQeK25iYsitwa8JuJLqpgE4FmbNZqvLG0chzciVQrguSWiiJQDEey0JHh(htW5muvjiTSSGw3W)2UPhM6bcQppgE4FmbNZqvLG0OQMXFoCcGmdzH9y4H)XeCodvvcsV0eiwd62kQiYqBLSmc8y4H)XeCodvvcsNflncazYazzvffUcWSYHkkS(KNip610RzIOIxspLlwQTOqRKTeujTIsRwuqKxueMh9wu4kGqYwQOWvStQOqW5muvjiTWrqvcqqMrVUPhg1UobECYhZvaHKTKM1N8e5rVMEntevu4kaZkhQOm61nq9mBjtVMjIkEj9u44sTffALSLGkPvuA1IcI8IIW8O3Icxbes2sffUIDsfLlc3hNipMRacjBjnRp5jYJEn9AMi6X18y(4XjYJj4CgQQeK(imjdidQIi3CMOGvu4kaZkhQO0RzIidB69yu8s6PCbk1wuOvYwcQKwrPvlkiYlkcZJElkCfqizlvu4k2jvusjrxuyGWjqiffUciKSL0JEDdupZwY0RzIOhN8X39yxS066raiKlaNaAALSLGECYhZvaHKTKE0RB6HrTRtaJkGy9jlUHvj7s2hZ7XWTOWvaMvourz0RB6HrTRtaJkGy9jlUHvj7s2Ixspf(OuBrHwjBjOsAfLwTOaie5ffH5rVffUciKSLkkCfGzLdvuOJ6najwtdGwzzKbISYTIcenKP1lkPKOlEj9uGJl1wuOvYwcQKwrzLdvueocQsacYm61n9WO21jqrryE0Brr4iOkbiiZOx30dJAxNafVKEk8zLAlkcZJElkNaaAGjocmQOqRKTeujTIxspLeDP2IIW8O3II6nqNTcYlk0kzlbvsR4fVOW6tEI8OxdRBluxFrLAlPNsP2IIW8O3IIA7rVffALSLGkPv8s6xSuBrryE0BrjB7gYmMGBffALSLGkPv8s6CCP2IIW8O3IsMaicWFSWkk0kzlbvsR4L0VaLAlkcZJElkJaqzB3qffALSLGkPv8s68rP2IIW8O3IISmc5aXAyI1wuOvYwcQKwXlPdhxQTOimp6TOmrKjC6Gkk0kzlbvsR4L05Zk1wuOvYwcQKwrryE0BrbMvGcXBaYKfiyurzIitpggymOs6PuuyGWjqiffH5rV6d5ud0XAg2awL)y4H)XSUTqD9vFiNAGgqhjw0J5WJtbUffAmiMBw5qffywbkeVbitwGGrfVKEIUuBrHwjBjOsAffgiCcesrbmxA0ayK2PJAdeRPUau1eCodvvc6XjFCEogAk1kzI8Ox9uTOimp6TO4XHm1fGAXlErryEWLmUyP1rLAlPNsP2IcTs2sqL0kkmq4eiKIIW8GlzOLobHEmhECkpo5JZZXqZ6tEI8OxnuxFFCYhF1J5kGqYws7XHmEBy9jprE07J5WJzDBH66R2gCJfMj3NSgAcep69XWd)J5kGqYws7XHmEBy9jprE07JVN3JH7JVUOimp6TOydUXcZK7tU4L0VyP2IcTs2sqL0kkmq4eiKIYDpMRacjBjnuGKSLmS(KNip69XjFmxbes2sApoKXBdRp5jYJEF898EmCFm8W)4REmRBluxF1hYPgOHMaXJEF89pMRacjBjThhY4TH1N8e5rVpo5JV7XUyP11G5sMEyu76eqtRKTe0JV(XWd)JDXsRRbZLm9WO21jGMwjBjOhN8X55yObZLm9WO21jGEQ(4KpMRacjBjThhY4TH1N8e5rVpMdpwyE0R(qo1anRBluxFFm8W)4raRYna6iXIE89pMRacjBjThhY4TH1N8e5rVffH5rVfLd5udkEjDoUuBrHwjBjOsAffgiCcesrXflTUwSuQihiioIGmJj4MMwjBjOhN8Xx948Cm0S(KNip6vd113hN8X3948Cm0vTBqoGe(1asy(JVUOimp6TOabey9ImzajEvXlErb5YcjaidODXJEl1wspLsTffALSLGkPvuyGWjqiffH5bxYqlDcc9yoW7XCfqizlPRA3GCaj8Bgw5qihe8tpo5JV6X55yORA3GCaj8RbKW8hdp8pophd9iaeYBWrdiH5p(6IIW8O3IYWkhc5GGFQ4L0VyP2IcTs2sqL0kkmq4eiKIsEog6raiK3GJgqcZlkcZJElkQ3aD2kiV4L054sTffALSLGkPvuyGWjqifL8Cm0vTBqoGe(1asy(Jt(48Cm0vTBqoGe(1a6iXIE89pwyE0REeaklwRMsLytNmECOIIW8O3II6nqNTcYlEj9lqP2IcTs2sqL0kkmq4eiKIsEog6Q2nihqc)Aajm)XjF8vpwfqCnWyq6u0JaqzXAFm8W)4raiKlaNaAH5bx6XWd)JfMh9QvVb6SvqUowZWgWQ8hFDrryE0Brr9gOZwb5fVKoFuQTOqRKTeujTIcdeobcPOKNJHgnxd)XcdzYwcHIfMbqc0n9u9XjF8vpM1TfQRVAWCjtpmQDDcOb0rIf94AESW8OxnyUKPhg1Uob0uQeB6KXJd94AEmtqUXJd9yo848Cm0O5A4pwyit2siuSWmasGUPb0rIf9y4H)X39yxS06AWCjtpmQDDcOPvYwc6Xx)4KpMRacjBjThhY4TH1N8e5rVpUMhZeKB84qpMdpophdnAUg(JfgYKTecflmdGeOBAaDKyrffH5rVff1BGoBfKx8s6WXLAlk0kzlbvsROWaHtGqkk55yORA3GCaj8RbKW8hN8XUaGrUUIeRxPvz(JVN3J5y4(4Kp2flTUgrciwygVNSknTs2sqffH5rVff1BGoBfKx8s68zLAlk0kzlbvsROWaHtGqkk55yOvVbAMvqhnGeM)4KpMji34XHE89pophdT6nqZSc6Ob0rIfvueMh9wuuVb6SvqEXlPNOl1wuOvYwcQKwrzIit9QWsgMG8yHvspLIcdeobcPOC3JhbGqUaCcOfMhCPhN8X39yUciKSL0JaqMSvqUrTBBSWECYhF1JV6Xx9yH5rV6raOSyTAkvIn9yH94Kp(Qhlmp6vpcaLfRvtPsSPtgaDKyrp((hdxnF8y4H)X39yWCPrdGr6raiK3GJMGZzOQsqp(6hdp8pwyE0Rw9gOZwb5AkvIn9yH94Kp(Qhlmp6vREd0zRGCnLkXMoza0rIf947FmC18XJHh(hF3JbZLgnagPhbGqEdoAcoNHQkb94RF81po5JZZXqxrIhlmZuvdiH5p(6hdp8p(Qh7ILwxJibelmJ3twLMwjBjOhN8XUaGrUUIeRxPvz(JVN3J5y4(4Kp(QhNNJHUIepwyMPQgqcZFCYhF3JfMh9QrSgWQ0uQeB6Xc7XWd)JV7X55yORA3GCaj8RbKW8hN8X3948Cm0vK4XcZmv1asy(Jt(yH5rVAeRbSknLkXMESWECYhF3JRA3GCaj8BqQK1ImXAg2awL)4RF81p(6IYerMEmmWyqL0tPOimp6TOmcazYwb5fVKohvP2IcTs2sqL0kkmq4eiKIIkG4AGXG0POrSgWQECYhNNJHUIepwyMPQgqcZFCYh7ILwxJibelmJ3twLMwjBjOhN8XUaGrUUIeRxPvz(JVN3J5y4(4KpwyEWLm0sNGqp((hZvaHKTKUQDdYbKWVzyLdHCqWpvueMh9wuuVb6SvqEXlPNcCl1wuOvYwcQKwrHbcNaHuuU7XCfqizlPvRAAJunQDBJf2Jt(4RE8Dp2flTUEa6JXRiJGQiKMwjBjOhdp8pwyEWLm0sNGqpMdpoLhF9Jt(4RESW8GlzOLobHEmhECkpo5JfMhCjdu76a2go947F8fFm8W)yH5bxYqlDcc9yoW7XCfqizlPReaKHji3mSYHqoi4NEm8W)yH5bxYqlDcc9yoW7XCfqizlPRA3GCaj8Bgw5qihe8tp(6IIW8O3IIAvtBKQzyLdHkEj9usPuBrHwjBjOsAffH5rVffMyTgH5rVgBG8IInqUzLdvueMhCjJlwADuXlPNYfl1wuOvYwcQKwrHbcNaHuueMhCjdT0ji0J5WJtPOimp6TOabey9ImzajEvXlPNchxQTOqRKTeujTIcdeobcPO4cag56ksSELwL5p(EEpMJH7Jt(yxS06AejGyHz8EYQ00kzlbvueMh9wuqSgWQkEj9uUaLAlk0kzlbvsROWaHtGqkkcZdUKHw6ee6XCG3J5kGqYwslaMSKHsv12OO3hN8XhzfTkZFmh49yUciKSL0cGjlzOuvTnk61CKvkkcZJElkcGjlzOuvTnk6T4L0tHpk1wuOvYwcQKwrHbcNaHuueMhCjdT0ji0J5aVhZvaHKTKUsaqgMGCZWkhc5GGFQOimp6TOmSYHqoi4NkEj9uGJl1wueMh9wugbGYI1wuOvYwcQKwXlPNcFwP2IIW8O3IcI1awvrHwjBjOsAfV4ffwFYtKh9AuReevQTKEkLAlk0kzlbvsROWaHtGqkk55yOz9jprE0RgQRVffH5rVffBaRYrg4GMqWo06fVK(fl1wuOvYwcQKwrPvlkiYlkcZJElkCfqizlvu4k2jvuYZXqZ6tEI8OxnGosSOhxZJZZXqZ6tEI8Oxn0eiE07JtKhF1JzDBH66RM1N8e5rVAaDKyrp((hNNJHM1N8e5rVAaDKyrp(6Icxbyw5qffkvNwicYW6tEI8OxdGosSOIxsNJl1wuOvYwcQKwrPvlkceurryE0BrHRacjBPIcxXoPIcxbes2sAe)zd0eiE0BrHbcNaHuuYZXqJMRH)yHHmzlHqXcZaib6MEQ(y4H)XCfqizlPPuDAHiidRp5jYJEna6iXIEmhECkA(4XjYJHXG0hj1hNip(QhNNJHgnxd)XcdzYwcHIfM(iPAqUW4)Xj2JZZXqJMRH)yHHmzlHqXctJCHX)JVUOWvaMvourHs1PfIGmS(KNip61aOJelQ4L0VaLAlk0kzlbvsROWaHtGqkk55yOz9jprE0RgQRVffH5rVfLSaZ0dJdcg)OIxsNpk1wuOvYwcQKwrHbcNaHuueMhCjdT0ji0J5WJt5XjFCEogAwFYtKh9QH66BrryE0BrXgCJfMj3NCXlPdhxQTOqRKTeujTIcdeobcPOKNJHM1N8e5rVAOU((4KpophdnyUKPhg1Uob0qD9TOimp6TOCcaObitpmEdo06fVKoFwP2IcTs2sqL0kkcZJElkv3ujGxbibYuheiVoqurffgiCcesrjphdnRp5jYJE1t1hN8XcZJE1JaqMSvqUMvjaye6X8EmCFCYhlmp6vpcazYwb5AaXQeamY4XHEmhEmmgK(iPwuw5qfLQBQeWRaKazQdcKxhiQOIxsprxQTOimp6TOKTDdz6HXRidT05wrHwjBjOsAfVKohvP2IIW8O3IYHon4MPhg7KfqgiajhurHwjBjOsAfVKEkWTuBrryE0BrPEdSqCPynac1RSmQOqRKTeujTIxspLuk1wuOvYwcQKwrzIit9QWsgMG8yHvspLIcdeobcPOC3JfocbcN0zRGCcyocYjGMwjBjOhN8Xx9yH5bxYqlDcc94759yH5bxYa1UoGTHtpgE4F8DpM1TfQRVA1QM2ivZWkhcPbKaD7Xx)4KpM1l0mCDSdcSI1WeetGinTs2sqpo5JzvcagHEmh494uECYhF1JV6XcZJE1JaqMSvqUMvjayeYmacZJEf7JR5Xx9yUciKSL0uQoTqeKH1N8e5rVgaDKyrpoXECEog6yheyfRHjiMarAOjq8O3hF9JV8XSUTqD9vpcazYwb5AOjq8O3hNypMRacjBjnLQtlebzy9jprE0Rbqhjw0JV8Xx948Cm0XoiWkwdtqmbI0qtG4rVpoXEmC18XJV(Xx)yoW7XW9XWd)J5kGqYwstP60crqgwFYtKh9Aa0rIf9475948Cm0XoiWkwdtqmbI0qtG4rVpgE4FCEog6yheyfRHjiMarAaDKyrp((hdxnF84RFCYhNNJHM1N8e5rV6P6Jt(47ECEog6raiK3GJgqcZFCYhF3JZZXqx1Ub5as4xdiH5po5JRA3GCaj8BqQK1ImXAg2awL)4AECEog6ks8yHzMQAajm)X3)4lwuMiY0JHbgdQKEkffH5rVfLrait2kiV4L0t5ILAlk0kzlbvsROmrKPEvyjdtqESWkPNsrHbcNaHuuU7XchHaHt6Svqobmhb5eqtRKTe0Jt(4RESW8GlzOLobHE898ESW8GlzGAxhW2WPhdp8p(UhZ62c11xTAvtBKQzyLdH0asGU94RFCYhZ6fAgUo2bbwXAycIjqKMwjBjOhN8XSkbaJqpMd8ECkpo5JV6Xx9yH5rV6rait2kixZQeamczgaH5rVI9X184REmxbes2sAkvNwicYW6tEI8OxdGosSOhNypophdDSdcSI1WeetGin0eiE07JV(Xx(yw3wOU(QhbGmzRGCn0eiE07JtShZvaHKTKMs1PfIGmS(KNip61aOJel6Xx(4RECEog6yheyfRHjiMarAOjq8O3hNypgUA(4Xx)4RFmh49y4(y4H)XCfqizlPPuDAHiidRp5jYJEna6iXIE898ECEog6yheyfRHjiMarAOjq8O3hdp8pophdDSdcSI1WeetGinGosSOhF)JHRMpE81po5JZZXqZ6tEI8Ox9u9XjF8Dpophd9iaeYBWrdiH5po5JV7X55yORA3GCaj8RbKW8hN8XvTBqoGe(nivYArMyndBaRYFCnpophdDfjESWmtvnGeM)47F8flktez6XWaJbvspLIIW8O3IYiaKjBfKx8s6PWXLAlk0kzlbvsROmrKPEvyjdtqESWkPNsrHbcNaHuuU7XchHaHt6Svqobmhb5eqtRKTe0Jt(4RESW8GlzOLobHE898ESW8GlzGAxhW2WPhdp8p(UhZ62c11xTAvtBKQzyLdH0asGU94RFCYhF3Jz9cndxh7GaRynmbXeistRKTe0Jt(ywLaGrOhZbEpoLhN8X55yOz9jprE0REQ(4Kp(UhNNJHEeac5n4ObKW8hN8X3948Cm0vTBqoGe(1asy(Jt(4Q2nihqc)gKkzTitSMHnGv5pUMhNNJHUIepwyMPQgqcZF89p(IfLjIm9yyGXGkPNsrryE0BrzeaYKTcYlEj9uUaLAlk0kzlbvsROWaHtGqkkG5sJgaJ0qbIfQ2yfWndRphzH0eCodvvc6XjFCEogAOaXcvBSc4MH1NJSqAOU((4KpophdnuGyHQnwbCZW6ZrwiJayYsAOU((4KpM1TfQRV68CmmqbIfQ2yfWndRphzH0asGUvueMh9wuy9CDcGujRT4L0tHpk1wuOvYwcQKwrHbcNaHuuaZLgnagPHceluTXkGBgwFoYcPj4CgQQe0Jt(48Cm0qbIfQ2yfWndRphzH0qD99XjFCEogAOaXcvBSc4MH1NJSqgbWKL0qD99XjFmRBluxF155yyGceluTXkGBgwFoYcPbKaDROimp6TOiaMSKHsv12OO3Ixspf44sTffALSLGkPvuyGWjqiffWCPrdGrAOaXcvBSc4MH1NJSqAcoNHQkb94KpophdnuGyHQnwbCZW6ZrwinuxFFCYhNNJHgkqSq1gRaUzy95ilKzaAKRH66BrryE0BrzaAKNBRx8s6PWNvQTOqRKTeujTIIW8O3IctSwJW8OxJnqErXgi3SYHkkcZdUKXflToQ4L0tjrxQTOqRKTeujTIYerM6vHLmmb5XcRKEkffgiCcesrjphdnRp5jYJE1qD99XjF8vpgmxA0ayKgkqSq1gRaUzy95ilKMGZzOQsqpM3JZZXqdfiwOAJva3mS(CKfspvF81po5JV6XcZJE1hYPgOJ1mSbSk)XjFSW8Ox9HCQb6yndBaRYna6iXIE898EmC18XJHh(hlmp6vJynGvPPuj20Jf2Jt(yH5rVAeRbSknLkXMoza0rIf947FmC18XJHh(hlmp6vpcaLfRvtPsSPhlShN8XcZJE1JaqzXA1uQeB6Kbqhjw0JV)XWvZhpgE4FSW8OxT6nqNTcY1uQeB6Xc7XjFSW8OxT6nqNTcY1uQeB6Kbqhjw0JV)XWvZhp(6IYerMEmmWyqL0tPOimp6TOW6tEI8O3IxspfoQsTffALSLGkPvuyGWjqifL8Cm0S(KNip6vBfKBOuvda94759yH5rVAwFYtKh9QTcYntebvueMh9wuyI1AeMh9ASbYlk2a5MvourH1N8e5rVgw3wOU(IkEj9lc3sTffALSLGkPvuyGWjqifLRECEog6Q2nihqc)Aajm)XWd)JZZXqpcaH8gC0asy(JV(XjFSW8GlzOLobHEmh49yUciKSL0S(KNip61mSYHqoi4NkkcZJElkdRCiKdc(PIxs)IPuQTOqRKTeujTIcdeobcPOKNJHgnxd)XcdzYwcHIfMbqc0n9u9XjFCEogA0Cn8hlmKjBjekwygajq30a6iXIEmhEmtqUXJdvueMh9wuuVb6SvqEXlPFXlwQTOqRKTeujTIcdeobcPOKNJHEeac5n4ObKW8IIW8O3II6nqNTcYlEj9lYXLAlk0kzlbvsROWaHtGqkk55yOvVbAMvqhnGeM)4KpophdT6nqZSc6Ob0rIf9yo8yMGCJhh6XjF8vpophdnRp5jYJE1a6iXIEmhEmtqUXJd9y4H)X55yOz9jprE0RgQRVp(6IIW8O3II6nqNTcYlEj9lEbk1wuOvYwcQKwrHbcNaHuuYZXqx1Ub5as4xdiH5po5JZZXqZ6tEI8Ox9uTOimp6TOOEd0zRG8Ixs)I8rP2IcTs2sqL0kkmq4eiKIIkG4AGXG0POrSgWQECYhNNJHUIepwyMPQgqcZlkcZJElkQ3aD2kiV4L0ViCCP2IcTs2sqL0kkmq4eiKIsEogAwFYtKh9QNQpo5JV6Xx9yH5rV6rait2kixZQeamc947FCkpo5JDXsRRvVbAMvqhnTs2sqpo5JfMhCjdT0ji0J594uE81pgE4F8Dp2flTUw9gOzwbD00kzlb9y4H)XcZdUKHw6ee6XC4XP84RlkcZJElkQvnTrQMHvoeQ4L0ViFwP2IcTs2sqL0kkmq4eiKIsEogAwFYtKh9QH667Jt(yw3wOU(Qz9jprE0Rgqhjw0JV)Xmb5gpo0Jt(47EmRxOz46HvoKryma5rVAALSLGkkcZJElkJaqzXAlEj9lMOl1wuOvYwcQKwrHbcNaHuuYZXqZ6tEI8OxnGosSOhZHhZeKB84qpo5JZZXqZ6tEI8Ox9u9XWd)JZZXqZ6tEI8OxnuxFFCYhZ62c11xnRp5jYJE1a6iXIE89pMji34XHkkcZJElkiwdyvfVK(f5Ok1wuOvYwcQKwrHbcNaHuuYZXqZ6tEI8OxnGosSOhF)JHXG0hj1hN8XcZdUKHw6ee6XC4XPuueMh9wuSb3yHzY9jx8s6CmCl1wuOvYwcQKwrHbcNaHuuYZXqZ6tEI8OxnGosSOhF)JHXG0hj1hN8X55yOz9jprE0REQwueMh9wuGacSErMmGeVQ4L054uk1wuOvYwcQKwrHbcNaHuuCbaJCDfjwVsRY8hFpVhZXW9XjFSlwADnIeqSWmEpzvAALSLGkkcZJElkiwdyvfV4fVOWLaOO3s6xeUxeUPKcCtPOuxaBSWqff4a858fthoA6WbZN84hxBf944O2a)XJg8y(QkGy9jloF9XacoNbGGEmQp0JLP3hXjOhZQKfgH0FcjkXspMJIp5XjEVCjGtqpMVYAU0kRR5lKMwjBji(6J9(X8vwZLwzDnFH4Rp(Qus9A9NWNaCa(C(IPdhnD4G5tE8JRTIECCuBG)4rdEmFL1N8e5rVg1kbr81hdi4Cgac6XO(qpwMEFeNGEmRswyes)jKOel94usHp5XjEVCjGtqpwjoj(Jr3wxs9XjQp27hNOmLhdfCdu07JBvciEdE8vxE9JV6IPET(tirjw6XPCr(KhN49YLaob9yL4K4pgDBDj1hNO(yVFCIYuEmuWnqrVpUvjG4n4XxD51p(QlM616pHpb4Oh1g4e0J5ZESW8O3hBdKJ0FcffKkXkPdhZXffvqpclvu47hFHbGEmFPaJ(e47hx5UkIp5YlHfE1mRz95suCMwXJEzaz4xIId7Ypb((XP3CPtMapoLlaNp(IW9IW9t4tGVFCIxjlmcXN8jW3poXEmhnIE8iGv5gaDKyrpgiEfbESxj7JDbaJCThhY4TbkOhpAWJTcYtmeX6f6XsoSHF7XtKaJq6pb((Xj2J5OvHeNESTHfShdi(KhNOmzb0JHdbi5G0Fc89JtShNO0nI2hZeK)yabNZaqhAD0Jhn4XjEFYtKh9(4RcnP58Xq9Yx9hx1wOhh(Jhn4XYJhacv9y(sYPg8yMG8R1Fc89JtShdhkqs2spw2htRdU9yVs8hxVNwOhdi006po2hlpUsaqmb5pMp9gOZwb5po2edMCi9NaF)4e7XWrwjBPhJCqW8hZQig)Xc7X9(y5XdQ(JhnGF0JJ9XEf9y(C(0eLh79Jbe0KrpUEd432cK(t4tGVFmCKuj20jOhNPrdOhZ6tw8hNjyXI0pMpNXivh94T3eRsaNX0(yH5rVOh3R9M(tqyE0lsRciwFYIxdVlfatwYeRtwlX8pb((X1wfOhZvaHKT0JrQelgbHESxrpENNmbECpESlayKJES4pUEvWQE8fS9hR4as4)XxOvoeYbb)e6X90rbe94E84eVp5jYJEFmQQNwOhNPhpreK(tqyE0lsRciwFYIxdVl5kGqYwIZvoeVQ2nihqc)MHvoeYbb)eNTkpe5CgdECfqizlPRA3GCaj8Bgw5qihe8t8GlNCf7K4DXeXflTUEyLdzufNvPPvYwcQgoorUZflTUEyLdzufNvPPvYwc6tGVFCTvb6XCfqizl9yKkXIrqOh7v0J35jtGh3Jh7cag5Ohl(JRxfSQhFbfa0JtCb5p(cTYHqoi4NqpUNokGOh3JhN49jprE07Jrv90c94m94jIGESGE8iSwcO)eeMh9I0QaI1NS41W7sUciKSL4CLdXRsaqgMGCZWkhc5GGFIZwLhICoJbpUciKSL0vcaYWeKBgw5qihe8t8GlNCf7K4DXeXflTUEyLdzufNvPPvYwcQgoorUZflTUEyLdzufNvPPvYwc6tGVFCTvb6XCfqizl9yKkXIrqOh7v0J35jtGh3Jh7cag5Ohl(JRxfSQhFbB)XkoGe(F8fALdHCqWpHESaOhpre0JHMGyH94eVp5jYJE1FccZJErAvaX6tw8A4Djxbes2sCUYH4X6tEI8OxZWkhc5GGFIZwLhICoJbpUciKSL0S(KNip61mSYHqoi4N4bxo5k2jXJJtexS066HvoKrvCwLMwjBjOAGJtK7CXsRRhw5qgvXzvAALSLG(e47hxBvGEmxbes2spgPsSyee6XEf94DEYe4X94XUaGro6XI)46vbR6X85aMS0JHJKQQTrrVpUNokGOh3JhN49jprE07Jrv90c94m94jIG0FccZJErAvaX6tw8A4Djxbes2sCUYH4jaMSKHsv12OOxoBvEiY5mg84kGqYwslaMSKHsv12OOxEWLtUIDs84O4OsexS066HvoKrvCwLMwjBjOAUyICNlwAD9WkhYOkoRstRKTe0NaF)4ARc0J5kGqYw6XivIfJGqp2ROhRsagTUaJECpE8rw5XzY21FC9QGv9y(Catw6XWrsv12OO3hxpS2hVT)4m94jIG0FccZJErAvaX6tw8A4Djxbes2sCUYH4jaMSKHsv12OOxZrwHtiAitRZ7caxoBvEacr(NaF)4ARc0J5kGqYw6Xb6Xteb9yVFmsLyX42J9k6XYPNR)4E8ypo0JJ9XiI1le6XEL4p(mr(Jvfe6XYWjWJt8(KNip69XuQQbGqpotJgqp(cTYHqoi4NqpUEyTpotpEIiOhVn4iw7n9NGW8OxKwfqS(KfVgExYvaHKTeNRCiEqKvUzgw5qihe8tCcrdzADEWLZwLhGqK)jW3pgoq4vpgoCSq2yHX5Jt8(KNip6LVIEmRBluxFFC9WAFCMEmGGMmc6X5BpwEmqwO(8y50Z158X5P)yVIE8opzc84E8ygiC0JrUaC0J5sGBpUkGv9yz4e4XcZdUIhlShN49jprE07JLf6XiBxh9yOU((yVRlai0J9k6X0c94E84eVp5jYJE5ROhZ62c11x9JHdur7Jpc)Xc7XqelqrVOhh7J9k6X858PjkC(4eVp5jYJE5ROhdOJeBSWEmRBluxFFCGEmGGMmc6X5Bp2Rc0JhaH5rVp27hlmwpx)XJg8y4WXczJfM(tqyE0lsRciwFYIxdVl5kGqYwIZvoep(JfYglmdGGMmp6LtiAitRZdU6lYzRYdqiY)e47hxBf9y50Z1FCpEmRBluxFFmGGMmp69XX(yeX6fc9yybxAFC(2JLhpMw7JzvYUK9X94XkvXWJf2J5t76eq)4AROhdLzAAmiMRt0PWh8bC5yDwqKHRyNuIAkWfUW9XuQQacHIEFmSGlHESxrpENNmbECpEmIy9cHEmGonxc6X5BpMew1J9GX)J3gCeR92JLf6XSEHMHRHceluTXsMEy8kYad0CjThhYWvSt6XWcUe6XEf9ybck8OxX(ybcoOjYp06pEa6ZJ9kXFmRxOz46pb((XcZJErAvaX6tw8A4Djxbes2sCUYH4HQIHhlmJAxNagabnzE0lNTkpe5CYvStIxIjmp6vJQIHhlmJAxNaAkvInDY4XHsufMh9QrvXWJfMrTRta9s1nEW434XHsKRGYmnngeZ1j6u4d(aUCSoliYWvStkrnf4cx4wdRxOz4AOaXcvBSKPhgVImWanxs7XHmCf7KUMZyWJ1CPvwxVbSk3mestRKTe0NGW8OxKwfqS(KfVgExYvaHKTeNRCiEOQy4XcZO21jGbqqtMh9YzRYdroNCf7K4jmp6vJQIHhlmJAxNaAgeGZyWJ1CPvwxVbSk3mestRKTe0NaF)4AROhdnbIh9(4E8y5XkZ9XWHJfgFf940SecflShN49jprE0R(tqyE0lsRciwFYIxdVl5kGqYwIZvoepe)zd0eiE0lNTkpe5CYvStIhF8jimp6fPvbeRpzXRH3LCfqizlX5khIhRp5jYJEn9AMiIZwLhICo5k2jXJGZzOQsq6JWKmGmOkICZzIcg8WtW5muvji9r2yqiVn9WCeOLqi4HNGZzOQsqAywbkeVbitwGGrWdpbNZqvLG0WScuiEdqMdbjwB0l8WtW5muvjiDaBdp61CeyeYmMicE4j4CgQQeK25iYsitwa8JuJLqWdpbNZqvLG0chzciVQrguSWiiJQDEeye8WtW5muvjiTSSGw3W)2UPhM6bcQpWdpbNZqvLG0OQMXFoCcGmdzHbp8eCodvvcsV0eiwd62kQiYqBLSmcap8eCodvvcsNflncazYazzvFccZJErAvaX6tw8A4Djxbes2sCUYH4n61nq9mBjtVMjI4Sv5HiNtUIDs8i4CgQQeKw4iOkbiiZOx30dJAxNaj5kGqYwsZ6tEI8OxtVMjI(eeMh9I0QaI1NS41W7sUciKSL4CLdXRxZerg207XGZwLhICo5k2jX7IWnr4kGqYwsZ6tEI8OxtVMjIQHpsecoNHQkbPpctYaYGQiYnNjkyFc89JRTkqpMRacjBPhdroboXsOhxVI2hZNZrqvcq4ROhFH96pUhpMpTRtGhhOhpre0JZ0Ob0J9k6XQtR9XX4X5HOh96MEyu76eWOciwFYIByvYUK9Xb6XB7pgPsSyeeK(tqyE0lsRciwFYIxdVl5kGqYwIZvoeVrVUPhg1UobmQaI1NS4gwLSlz5Sv5HiNtUIDs8sjrZzm4XvaHKTKE0RBG6z2sMEnteL8oxS066raiKlaNaAALSLGsYvaHKTKE0RB6HrTRtaJkGy9jlUHvj7swEW9tGVF8fSR)yBVWECMgnGECI3N8e5rVpgv1tl0JHJCuVbiX(y(caqRSm6Xz6XtebXx4pbH5rViTkGy9jlEn8UKRacjBjox5q8OJ6najwtdGwzzKbISYnoHOHmToVus0C2Q8aeI8pbH5rViTkGy9jlEn8UCIit40HZvoepHJGQeGGmJEDtpmQDDc8jimp6fPvbeRpzXRH3LNaaAGjocm6tqyE0lsRciwFYIxdVlvVb6Svq(NWNaF)y4iPsSPtqpM4sGBp2Jd9yVIESW8g84a9yHRewjBj9NGW8OxepwpxNaivYA5mg8UdmxA0ayKgkqSq1gRaUzy95ilKMGZzOQsqFccZJEr1W7sUciKSL4CLdXZJdz82W6tEI8OxoBvEiY5KRyNepxS066raiKlaNaAALSLGsKraiKlaNaAaDKyr1CfRBluxF1S(KNip6vdOJelkrUkLeJRacjBjn)XczJfMbqqtMh9MiUyP118hlKnwyAALSLGU(6e5ow3wOU(Qz9jprE0Rgqc0TejphdnRp5jYJE1qD99tGVFmFPWp9y0eqpoX7tEI8O3hhOhdrw5gb94y84Liic6XzbrqpU3h7v0JPJ6najwtdGwzzKbISYThZvaHKT0NGW8Oxun8UKRacjBjox5q884qgVnS(KNip6LZwL3rsLtUIDs84kGqYwsth1BasSMgaTYYidezLBj2vSUTqD9vth1BasSMgaTYYin0eiE0BIX62c11xnDuVbiXAAa0klJ0a6iXIUorUJ1TfQRVA6OEdqI10aOvwgPbKaDJZyWJGZzOQsqA6OEdqI10aOvwg9jimp6fvdVlrvXWJfMrTRtaoJbV8Cm0S(KNip6vd113K55yObZLm9WO21jGgQRVjzDBH66RM1N8e5rVAaDKyrCaUFccZJEr1W7sGafY6gKQa4NZyW7Q8Cm0S(KNip6vd113K55yObZLm9WO21jGgQRVjVI1TfQRVAwFYtKh9Qb0rIfDpLkXMoz84qWdpRBluxF1S(KNip6vdOJelIdSUTqD9vdeOqw3Gufa)AOjq8O3RVgE4VkphdnyUKPhg1Uob0t1KSUTqD9vZ6tEI8OxnGosSioWXW96pbH5rVOA4DjejEvUblXzm4LNJHM1N8e5rVAOU(MmphdnyUKPhg1Uob0qD9njRBluxF1S(KNip6vdOJel6EkvInDY4XH(eeMh9IQH3LNaaAGjocmIZyWlphdnRp5jYJE1qD9njeLNJHgiqHSUbPka(nCN2LasoSHFtd113pbH5rVOA4D5erMWPdN0yqm3SYH4bZkqH4nazYcemIZyWJRacjBjThhY4TH1N8e5rVCG1TfQRVjgF8jimp6fvdVlNiYeoD4CLdXJoQ3aKynnaALLrCgdECfqizlP94qgVnS(KNip69EECfqizlPPJ6najwtdGwzzKbISYTpbH5rVOA4D5erMWPdNRCiEOEAnbSnCcWzm4XvaHKTK2Jdz82W6tEI8OxoWJRacjBjDVMjImSP3JXNGW8Oxun8UCIit40HZvoepy2BQvMEyeekoHv8OxoJbpUciKSL0ECiJ3gwFYtKh9YbECfqizlP71mrKHn9Em(eeMh9IQH3LtezcNoCUYH4DeMKbKbvrKBotuW4mg84kGqYws7XHmEBy9jprE07984JpbH5rVOA4D5erMWPdNRCiEqasGgbGmCjeISCgdECfqizlP94qgVnS(KNip6Ld84kGqYws3RzIidB69y8jimp6fvdVlNiYeoD4CLdXt4iOkbiiZOx30dJAxNaCgdECfqizlP94qgVnS(KNip69EE8rnPWhjcxbes2s6rVUbQNzlz61mrusUciKSL0ECiJ3gwFYtKh9Yb4(jimp6fvdVlHnfauiRPhgHJqG2R4mg8UIRacjBjThhY4TH1N8e5rV3NcCHh(raRYna6iXIUNRacjBjThhY4TH1N8e5rVx)jimp6fvdVlz9YO1bItqMHvo0NGW8Oxun8UeqIASWmdRCi0NGW8Oxun8UC0SjIGmchHaHtMmjNpbH5rVOA4DP6eeJBXcZKTcY)eeMh9IQH3LGqv1sMynivHrFccZJEr1W7sVImZn3ZfYmAaJ(e47hdhm5p2ROhdfiwOAJva3mS(CKf6X55y84PkNpEUwcHEmRp5jYJEFCGEmQ7v)jimp6fvdVlz9CDcGujRLZyWdmxA0ayKgkqSq1gRaUzy95ilKMGZzOQsqjzDBH66RophdduGyHQnwbCZW6ZrwinGeOBjZZXqdfiwOAJva3mS(CKfYiaMSKgQRVjzDBH66RM1N8e5rVAaDKyrCGJHBY7YZXqdfiwOAJva3mS(CKfspv)eeMh9IQH3LcGjlzOuvTnk6LZyWdmxA0ayKgkqSq1gRaUzy95ilKMGZzOQsqjzDBH66RophdduGyHQnwbCZW6ZrwinGeOBjZZXqdfiwOAJva3mS(CKfYiaMSKgQRVjzDBH66RM1N8e5rVAaDKyrCGJHBY7YZXqdfiwOAJva3mS(CKfspv)eeMh9IQH3LdqJ8CBDoJbpWCPrdGrAOaXcvBSc4MH1NJSqAcoNHQkbLK1TfQRV68CmmqbIfQ2yfWndRphzH0asGULmphdnuGyHQnwbCZW6ZrwiZa0ixd113KSUTqD9vZ6tEI8OxnGosSioWXWn5D55yOHceluTXkGBgwFoYcPNQFccZJEr1W7sWCjtpmQDDcWzm4LNJHgmxY0dJAxNaAOU(M8kUciKSL0ECiJ3gwFYtKh9YH8Cm0G5sMEyu76eqdnbIh9MKRacjBjThhY4TH1N8e5rVCqyE0REeaYKTcY1JP1AaeRsaWiJhhcE45kGqYws7XHmEBy9jprE0lhgbSk3aOJel66pbH5rVOA4DjtSwJW8OxJnqoNRCiES(KNip61OwjiIZyW7oUciKSL0qbsYwYW6tEI8O3KCfqizlP94qgVnS(KNip69EEW9tqyE0lQgExYvaHKTeNRCiEJaqMSvqUrTBBSW4KRyNeV74kGqYwsdfijBjdRp5jYJEtYvaHKTK2Jdz82W6tEI8O37fMh9QhbGmzRGC9yATgaXQeamY4XHsmUciKSL0OQy4XcZO21jGbqqtMh9MixX62c11xnQkgESWmQDDcOb0rIfDpxbes2sApoKXBdRp5jYJEVojxbes2sApoKXBdRp5jYJEVFeWQCdGosSOpbH5rVOA4Djxbes2sCUYH4Pw10gPAu72glmo5k2jX7oUciKSL0qbsYwYW6tEI8O3KCfqizlP94qgVnS(KNip69EH5rVA1QM2ivZWkhcPhtR1aiwLaGrgpouIXvaHKTKgvfdpwyg1UobmacAY8O3e5kw3wOU(QrvXWJfMrTRtanGosSO75kGqYws7XHmEBy9jprE071j5kGqYws7XHmEBy9jprE079JawLBa0rIfbp8G5sJgaJ0O5A4pwyit2siuSW0eCodvvc6tqyE0lQgExYeR1imp61ydKZ5khIhOvnQvcI4mg8YZXqdMlz6HrTRta9un5vCfqizlP94qgVnS(KNip6LdW96pbH5rVOA4Djxbes2sCUYH4Pw10gPAu72glmo5k2jX7oUciKSL0qbsYwYW6tEI8O3KCfqizlP94qgVnS(KNip69EH5rVA1QM2ivZWkhcPhtR1aiwLaGrgpousUciKSL0ECiJ3gwFYtKh9E)iGv5gaDKyrWdpyU0ObWinAUg(JfgYKTecflmnbNZqvLG(e47hdhOI2hFbfaetqESWE8fALd9yfhe8tC(4lma0JtZkih9yuvpTqpotpEIiOh79JHrlbeNE8fS9hR4as4h9yzHES3pMs1Pf6XPzfKtGhZxkiNa6pbH5rVOA4D5iaKjBfKZ5erMEmmWyq8sHZjIm1RclzycYJfgVu4mg8UJRacjBj9iaKjBfKBu72glSKxXvaHKTK2Jdz82W6tEI8Oxoax4HNRacjBjnuGKSLmS(KNip696KcZdUKHw6eeId84kGqYwsxjaidtqUzyLdHCqWpL8UraiKlaNaAH5bxk5D55yORA3GCaj8RbKW8KxLNJHUIepwyMPQgqcZtkmp6vpSYHqoi4N0uQeB6Kbqhjw09WvZhWdpRsaWiKzaeMh9kwoW7Ix)jW3pgo0eelShFHbGqUaCcW5JVWaqponRGC0Jfa94jIGEmkoHva2Bp27hdnbXc7XjEFYtKh9QFmCW0saXAVX5J9k62Jfa94jIGES3pggTeqC6XxW2FSIdiHF0JRxr7JzGWrpUEyTpEB)Xz6X1fKtqpwwOhxp8QhNMvqobEmFPGCcW5J9k62Jrv90c94m9yKkGeOh3t)XE)4JeRlX(yVIECAwb5e4X8LcYjWJZZXq)jimp6fvdVlhbGmzRGCoNiY0JHbgdIxkCorKPEvyjdtqESW4LcNXG3iaeYfGtaTW8GlLKvjayeId8sj5DCfqizlPhbGmzRGCJA32yHL8Q7eMh9QhbGYI1QPuj20JfwY7eMh9QvVb6SvqUowZWgWQ8K55yORiXJfMzQQbKWC4HxyE0REeaklwRMsLytpwyjVlphdDv7gKdiHFnGeMdp8cZJE1Q3aD2kixhRzydyvEY8Cm0vK4XcZmv1asyEY7YZXqx1Ub5as4xdiH5x)jimp6fvdVlzI1AeMh9ASbY5CLdXd5YcjaidODXJE5mg8UIRacjBjThhY4TH1N8e5rVCaUxNmphdnyUKPhg1Uob0qD99t4tqyE0lslmp4sgxS06iE2GBSWm5(K5mg8eMhCjdT0jiehsjzEogAwFYtKh9QH66BYR4kGqYws7XHmEBy9jprE0lhyDBH66R2gCJfMj3NSgAcep6fE45kGqYws7XHmEBy9jprE0798G71FccZJErAH5bxY4ILwhvdVlpKtnGZyW7oUciKSL0qbsYwYW6tEI8O3KCfqizlP94qgVnS(KNip69EEWfE4VI1TfQRV6d5ud0qtG4rV3ZvaHKTK2Jdz82W6tEI8O3K35ILwxdMlz6HrTRtanTs2sqxdp8UyP11G5sMEyu76eqtRKTeuY8Cm0G5sMEyu76eqpvtYvaHKTK2Jdz82W6tEI8Oxoimp6vFiNAGM1TfQRVWd)iGv5gaDKyr3ZvaHKTK2Jdz82W6tEI8O3pbH5rViTW8GlzCXsRJQH3LqabwVitgqIxXzm45ILwxlwkvKdeehrqMXeCttRKTeuYRYZXqZ6tEI8OxnuxFtExEog6Q2nihqc)Aajm)6pHpbH5rVinRp5jYJEnSUTqD9fXtT9O3pbH5rVinRp5jYJEnSUTqD9fvdVlZ2UHmJj42NGW8OxKM1N8e5rVgw3wOU(IQH3LzcGia)Xc7tqyE0lsZ6tEI8OxdRBluxFr1W7YraOSTBOpbH5rVinRp5jYJEnSUTqD9fvdVlLLrihiwdtS2pbH5rVinRp5jYJEnSUTqD9fvdVlNiYeoDqFccZJErAwFYtKh9AyDBH66lQgExorKjC6W5erMEmmWyq8sHtAmiMBw5q8GzfOq8gGmzbcgXzm4jmp6vFiNAGowZWgWQC4HN1TfQRV6d5ud0a6iXI4qkW9tqyE0lsZ6tEI8OxdRBluxFr1W7spoKPUau5mg8aZLgnagPD6O2aXAQlavnbNZqvLGsMNJHMsTsMip6vpv)e(eeMh9I0S(KNip61OwjiINnGv5idCqtiyhADoJbV8Cm0S(KNip6vd113pb((XWrqECeNECvx)X2EH94eVp5jYJEFC9WAFSvq(J9kz5h9yVFSYCFmC4yHXxrponlHqXc7XE)yiYjWjw6XvD9hFHbGECAwb5OhJQ6Pf6Xz6XtebP)eeMh9I0S(KNip61OwjiQgExYvaHKTeNRCiEuQoTqeKH1N8e5rVgaDKyrC2Q8qKZjxXojE55yOz9jprE0Rgqhjwun55yOz9jprE0RgAcep6nrUI1TfQRVAwFYtKh9Qb0rIfDFEogAwFYtKh9Qb0rIfD9NaF)y(Cii0J9k6XqtG4rVpUhp2ROhRm3hdhowy8v0JtZsiuSWECI3N8e5rVp27h7v0JPf6X94XEf9y2eaO1FCI3N8e5rVpogp2ROhZeK)4690c9ywFuTKtpgAcIf2J9Qa94eVp5jYJE1FccZJErAwFYtKh9AuReevdVl5kGqYwIZvoepkvNwicYW6tEI8OxdGosSioBvEceeNCf7K4XvaHKTKgXF2anbIh9Yzm4LNJHgnxd)XcdzYwcHIfMbqc0n9ufE45kGqYwstP60crqgwFYtKh9Aa0rIfXHu08rIaJbPpsQjYv55yOrZ1WFSWqMSLqOyHPpsQgKlm(tS8Cm0O5A4pwyit2siuSW0ixy8F9NGW8OxKM1N8e5rVg1kbr1W7YSaZ0dJdcg)ioJbV8Cm0S(KNip6vd113pbH5rVinRp5jYJEnQvcIQH3L2GBSWm5(K5mg8eMhCjdT0jiehsjzEogAwFYtKh9QH667NGW8OxKM1N8e5rVg1kbr1W7Ytaanaz6HXBWHwNZyWlphdnRp5jYJE1qD9nzEogAWCjtpmQDDcOH667NGW8OxKM1N8e5rVg1kbr1W7YjImHthox5q8QUPsaVcqcKPoiqEDGOI4mg8YZXqZ6tEI8Ox9unPW8Ox9iaKjBfKRzvcagH4b3KcZJE1JaqMSvqUgqSkbaJmECioaJbPpsQFccZJErAwFYtKh9AuReevdVlZ2UHm9W4vKHw6C7tqyE0lsZ6tEI8OxJALGOA4D5Hon4MPhg7Kfqgiajh0NGW8OxKM1N8e5rVg1kbr1W7Y6nWcXLI1aiuVYYOpb((XPDH85p(cda940ScYF8ejWi(KhdhAcIf2Jt8(KNip6LZhFHbGECAwb5Ohla6Xteb9yVFmmAjG40JVGT)yfhqc)Ohll0JpXgNGJqp2ROhlNEU(J7XJ94qpgPsR)ykvIn9yH942RiWJrQK1I0p(cBWJrUSqca6XxyaioF8fga6XPzfKJESaOh3R92JNic6X1RO9Xxqs8yH9yoA1hhOhlmp4spUbpUEfTpwEScRbSQhZeK)4a94yFSkOHbie6XYc94lijESWEmhT6JLf6XxW2FSIdiH)hla6XB7pwyEWL0pgoq4vponRGCc8y(sb5e4XYc94l0kh6X8fSC(4lma0JtZkih9yMSpwGGcp6vS2BpotpEIiOhxVkS0JVGT)yfhqc)pwwOhFbjXJf2J5OvFSaOhVT)yH5bx6XYc9y5X8P3aD2ki)Xb6XX(yVIESeGhll0JflQFC9QWspMjipwypwH1aw1JjU0(4y84lijESWEmhT6Jd0JflGeOBpwyEWL0pU2k6XwXDc8yXA76Oh717hFbB)XkoGe(FmF6nqNTcYrp27hNPhZeK)4yFmAYyecf9(yz4e4XEf9yfwdyv6hZNdbfE0RyT3EC9WRECAwb5e4X8LcYjWJLf6XxOvo0J5ly58XxyaOhNMvqo6XOQEAHE82(JZ0JNic6XZ1si0JtZkiNapMVuqobECGESK7P)yVFmLQAaOh3Gh7veGESaOhFAa9yVs2htBpHv94lma0JtZkih9yVFmLQtl0JtZkiNapMVuqobES3p2ROhtl0J7XJt8(KNip6v)jimp6fPz9jprE0RrTsqun8UCeaYKTcY5CIitpggymiEPW5erM6vHLmmb5XcJxkCgdE3jCeceoPZwb5eWCeKtanTs2sqjVsyEWLm0sNGq3ZtyEWLmqTRdyB4e8WFhRBluxF1QvnTrQMHvoesdib621jz9cndxh7GaRynmbXeistRKTeuswLaGrioWlLKxDLW8Ox9iaKjBfKRzvcagHmdGW8OxXwZvCfqizlPPuDAHiidRp5jYJEna6iXIsS8Cm0XoiWkwdtqmbI0qtG4rVxNOY62c11x9iaKjBfKRHMaXJEtmUciKSL0uQoTqeKH1N8e5rVgaDKyrjQxLNJHo2bbwXAycIjqKgAcep6nXGRMpU(AoWdUWdpxbes2sAkvNwicYW6tEI8OxdGosSO75LNJHo2bbwXAycIjqKgAcep6fE4ZZXqh7GaRynmbXeisdOJel6E4Q5JRtMNJHM1N8e5rV6PAY7YZXqpcaH8gC0asyEY7YZXqx1Ub5as4xdiH5jRA3GCaj8BqQK1ImXAg2awLxtEog6ks8yHzMQAajm)(l(jW3pgoq4v90FmC0DqGvSpoXfetGioFmCqtK)4jIE8fga6XPzfKJEC9kAFSxr3EC9E5R(JpZLv9ygiC0JLf6X1RO9XxyaiK3GZJd0JH66R(tqyE0lsZ6tEI8OxJALGOA4D5iaKjBfKZ5erMEmmWyq8sHZjIm1RclzycYJfgVu4mg8Ut4ieiCsNTcYjG5iiNaAALSLGsELW8GlzOLobHUNNW8GlzGAxhW2Wj4H)ow3wOU(QvRAAJundRCiKgqc0TRtY6fAgUo2bbwXAycIjqKMwjBjOKSkbaJqCGxkjV6kH5rV6rait2kixZQeamczgaH5rVITMR4kGqYwstP60crqgwFYtKh9Aa0rIfLy55yOJDqGvSgMGycePHMaXJEVorL1TfQRV6rait2kixdnbIh9MyCfqizlPPuDAHiidRp5jYJEna6iXIsuVkphdDSdcSI1WeetGin0eiE0BIbxnFC91CGhCHhEUciKSL0uQoTqeKH1N8e5rVgaDKyr3ZlphdDSdcSI1WeetGin0eiE0l8WNNJHo2bbwXAycIjqKgqhjw09WvZhxNmphdnRp5jYJE1t1K3LNJHEeac5n4ObKW8K3LNJHUQDdYbKWVgqcZtw1Ub5as43GujRfzI1mSbSkVM8Cm0vK4XcZmv1asy(9x8tGVFmCGWREmC0DqGvSpoXfetGioF8fga6XPzfK)4jIEmQQNwOhNPhlqqHh9k2BpM1lYbsSe0Jr9J9kXFC4poqpEB)Xz6Xteb945Aje6XWr3bbwX(4exqmbIECGESK7P)yVFmLQAaOh3Gh7veGESaOhFAa9yVs2htBpHv94lma0JtZkih9yVFmLQtl0JHJUdcSI9XjUGyce9yVFSxrpMwOh3JhN49jprE0R(tqyE0lsZ6tEI8OxJALGOA4D5iaKjBfKZ5erMEmmWyq8sHZjIm1RclzycYJfgVu4mg8Ut4ieiCsNTcYjG5iiNaAALSLGsELW8GlzOLobHUNNW8GlzGAxhW2Wj4H)ow3wOU(QvRAAJundRCiKgqc0TRtEhRxOz46yheyfRHjiMarAALSLGsYQeamcXbEPKmphdnRp5jYJE1t1K3LNJHEeac5n4ObKW8K3LNJHUQDdYbKWVgqcZtw1Ub5as43GujRfzI1mSbSkVM8Cm0vK4XcZmv1asy(9x8tqyE0lsZ6tEI8OxJALGOA4DjRNRtaKkzTCgdEG5sJgaJ0qbIfQ2yfWndRphzH0eCodvvckzEogAOaXcvBSc4MH1NJSqAOU(MmphdnuGyHQnwbCZW6ZrwiJayYsAOU(MK1TfQRV68CmmqbIfQ2yfWndRphzH0asGU9jimp6fPz9jprE0RrTsqun8UuamzjdLQQTrrVCgdEG5sJgaJ0qbIfQ2yfWndRphzH0eCodvvckzEogAOaXcvBSc4MH1NJSqAOU(MmphdnuGyHQnwbCZW6ZrwiJayYsAOU(MK1TfQRV68CmmqbIfQ2yfWndRphzH0asGU9jimp6fPz9jprE0RrTsqun8UCaAKNBRZzm4bMlnAamsdfiwOAJva3mS(CKfstW5muvjOK55yOHceluTXkGBgwFoYcPH66BY8Cm0qbIfQ2yfWndRphzHmdqJCnuxF)eeMh9I0S(KNip61OwjiQgExYeR1imp61ydKZ5khINW8GlzCXsRJ(eeMh9I0S(KNip61OwjiQgExY6tEI8OxoNiY0JHbgdIxkCorKPEvyjdtqESW4LcNXGxEogAwFYtKh9QH66BYRaZLgnagPHceluTXkGBgwFoYcPj4CgQQeeV8Cm0qbIfQ2yfWndRphzH0t1RtELW8Ox9HCQb6yndBaRYtkmp6vFiNAGowZWgWQCdGosSO75bxnFap8cZJE1iwdyvAkvIn9yHLuyE0RgXAaRstPsSPtgaDKyr3dxnFap8cZJE1JaqzXA1uQeB6XclPW8Ox9iauwSwnLkXMoza0rIfDpC18b8Wlmp6vREd0zRGCnLkXMESWskmp6vREd0zRGCnLkXMoza0rIfDpC18X1Fc89J5lWRiWJzDBH66l6XEL4pgv1tl0JZ0JNic6X1dV6XjEFYtKh9(yuvpTqpUx7ThNPhpre0JRhE1JL9XcZNI9XjEFYtKh9(yMG8hll0J32FC9WRES8yL5(y4WXcJVIECAwcHIf2Jvbnt)jimp6fPz9jprE0RrTsqun8UKjwRryE0RXgiNZvoepwFYtKh9AyDBH66lIZyWlphdnRp5jYJE1wb5gkv1aq3ZtyE0RM1N8e5rVARGCZerqFccZJErAwFYtKh9AuReevdVlhw5qihe8tCgdExLNJHUQDdYbKWVgqcZHh(8Cm0JaqiVbhnGeMFDsH5bxYqlDccXbECfqizlPz9jprE0RzyLdHCqWp9jimp6fPz9jprE0RrTsqun8Uu9gOZwb5CgdE55yOrZ1WFSWqMSLqOyHzaKaDtpvtMNJHgnxd)XcdzYwcHIfMbqc0nnGosSioWeKB84qFccZJErAwFYtKh9AuReevdVlvVb6SvqoNXGxEog6raiK3GJgqcZ)eeMh9I0S(KNip61OwjiQgExQEd0zRGCoJbV8Cm0Q3anZkOJgqcZtMNJHw9gOzwbD0a6iXI4atqUXJdL8Q8Cm0S(KNip6vdOJelIdmb5gpoe8WNNJHM1N8e5rVAOU(E9NGW8OxKM1N8e5rVg1kbr1W7s1BGoBfKZzm4LNJHUQDdYbKWVgqcZtMNJHM1N8e5rV6P6NGW8OxKM1N8e5rVg1kbr1W7s1BGoBfKZzm4PciUgymiDkAeRbSQK55yORiXJfMzQQbKW8pbH5rVinRp5jYJEnQvcIQH3LQvnTrQMHvoeIZyWlphdnRp5jYJE1t1KxDLW8Ox9iaKjBfKRzvcagHUpLKUyP11Q3anZkOJMwjBjOKcZdUKHw6eeIxkxdp835ILwxREd0mRGoAALSLGGhEH5bxYqlDccXHuU(tqyE0lsZ6tEI8OxJALGOA4D5iauwSwoJbV8Cm0S(KNip6vd113KSUTqD9vZ6tEI8OxnGosSO7zcYnECOK3X6fAgUEyLdzegdqE0RMwjBjOpbH5rVinRp5jYJEnQvcIQH3LiwdyvCgdE55yOz9jprE0RgqhjwehycYnECOK55yOz9jprE0REQcp855yOz9jprE0RgQRVjzDBH66RM1N8e5rVAaDKyr3ZeKB84qFccZJErAwFYtKh9AuReevdVlTb3yHzY9jZzm4LNJHM1N8e5rVAaDKyr3dJbPpsQjfMhCjdT0jiehs5tqyE0lsZ6tEI8OxJALGOA4DjeqG1lYKbK4vCgdE55yOz9jprE0Rgqhjw09Wyq6JKAY8Cm0S(KNip6vpv)eeMh9I0S(KNip61OwjiQgExIynGvXzm45cag56ksSELwL53ZJJHBsxS06AejGyHz8EYQ00kzlb9j8jimp6fPbTQrTsqeVHvoeYbb)eNXGNW8GlzOLobH4apUciKSL0vTBqoGe(ndRCiKdc(PKxLNJHUQDdYbKWVgqcZHh(8Cm0JaqiVbhnGeMF9NGW8OxKg0Qg1kbr1W7s1BGoBfKZzm4LNJHgnxd)XcdzYwcHIfMbqc0n9unzEogA0Cn8hlmKjBjekwygajq30a6iXI4atqUXJd9jimp6fPbTQrTsqun8Uu9gOZwb5CgdE55yOhbGqEdoAajm)tqyE0lsdAvJALGOA4DP6nqNTcY5mg8YZXqx1Ub5as4xdiH5Fc89J5Or0J7LE8fga6XPzfK)ysa2Bpo2hZxS5tFCmE8TE(yOE5R(JReU0JPWRiWJVGK4Xc7XC0QpUbp(c2(JvCaj8)4BK)yzHEmfEfb4tE8vY1pUs4sp(0a6XELSp2R3pwSasGUX5JVkF9JReU0J5ZTuQihiioIWxrp(cNGBpgqc0Th79JNiIZh3GhFf76hRqciwypU2EYQECGESW8GlPFmCOE5R(JH6h7vb6X1Rcl94kba9yMG8yH94l0khYbb)e6Xn4X1RO9XkZ9XWHJfgFf940SecflShhOhdib6M(tqyE0lsdAvJALGOA4D5iaKjBfKZ5erMEmmWyq8sHZjIm1RclzycYJfgVu4mg8YZXqJMRH)yHHmzlHqXcZaib6MgQRVjfMhCjdT0ji09CfqizlPReaKHji3mSYHqoi4NsE3iaeYfGtaTW8GlL8Q7YZXqxrIhlmZuvdiH5jVlphdDv7gKdiHFnGeMN8ovaX10JHbgdspcazYwb5jVsyE0REeaYKTcY1SkbaJqCG3fHh(RCXsRRflLkYbcIJiiZycUPPvYwckjRBluxF1qabwVitgqIxPbKaD7A4H)kxS06AejGyHz8EYQ00kzlbL0famY1vKy9kTkZVNhhd3RV(6pb((XC0i6XxyaOhNMvq(JPWRiWJHMGyH9y5XxyaOSyTxYNEd0zRG8hZeK)46v0(4lijESWEmhT6Jd0JfMhCPh3GhdnbXc7XuQeB60JRhE1JvibelShxBpzv6pbH5rVinOvnQvcIQH3LJaqMSvqoNtez6XWaJbXlfoNiYuVkSKHjipwy8sHZyW7UraiKlaNaAH5bxk5vxDLW8Ox9iauwSwnLkXMESWsELW8Ox9iauwSwnLkXMoza0rIfDpC18b8WFhyU0ObWi9iaeYBWrtW5muvjORHhEH5rVA1BGoBfKRPuj20JfwYReMh9QvVb6SvqUMsLytNma6iXIUhUA(aE4VdmxA0ayKEeac5n4Oj4CgQQe01xNmphdDfjESWmtvnGeMFn8WFLlwADnIeqSWmEpzvAALSLGs6cag56ksSELwL53ZJJHBYRYZXqxrIhlmZuvdiH5jVtyE0RgXAaRstPsSPhlm4H)U8Cm0vTBqoGe(1asyEY7YZXqxrIhlmZuvdiH5jfMh9QrSgWQ0uQeB6Xcl5DvTBqoGe(nivYArMyndBaRYV(6R)eeMh9I0Gw1OwjiQgExYeR1imp61ydKZ5khINW8GlzCXsRJ(eeMh9I0Gw1OwjiQgExQEd0zRGCoJbV8Cm0Q3anZkOJgqcZtYeKB84q3NNJHw9gOzwbD0a6iXIsYeKB84q3NNJHgmxY0dJAxNaAaDKyrFccZJErAqRAuReevdVlvVb6SvqoNXGNkG4AGXG0POrSgWQsMNJHUIepwyMPQgqcZt6ILwxJibelmJ3twLMwjBjOKUaGrUUIeRxPvz(984y4MuyEWLm0sNGq3ZvaHKTKUQDdYbKWVzyLdHCqWp9jimp6fPbTQrTsqun8UuTQPns1mSYHqCgdE3XvaHKTKwTQPns1O2TnwyjZZXqxrIhlmZuvdiH5jVlphdDv7gKdiHFnGeMN8kH5bxYa1UoGTHt3Fr4HxyEWLm0sNGqCGhxbes2s6kbazycYndRCiKdc(j4HxyEWLm0sNGqCGhxbes2s6Q2nihqc)MHvoeYbb)01FccZJErAqRAuReevdVlrSgWQ4mg8CbaJCDfjwVsRY875XXWnPlwADnIeqSWmEpzvAALSLG(eeMh9I0Gw1OwjiQgExkaMSKHsv12OOxoJbpH5bxYqlDccXbECfqizlPfatwYqPQABu0BYJSIwL5CGhxbes2sAbWKLmuQQ2gf9AoYkFccZJErAqRAuReevdVlhw5qihe8tCgdEcZdUKHw6eeId84kGqYwsxjaidtqUzyLdHCqWp9jimp6fPbTQrTsqun8UCeaklw7NWNGW8OxKg5YcjaidODXJE5nSYHqoi4N4mg8eMhCjdT0jieh4XvaHKTKUQDdYbKWVzyLdHCqWpL8Q8Cm0vTBqoGe(1asyo8WNNJHEeac5n4ObKW8R)eeMh9I0ixwibazaTlE0Bn8Uu9gOZwb5CgdE55yOhbGqEdoAajm)tqyE0lsJCzHeaKb0U4rV1W7s1BGoBfKZzm4LNJHUQDdYbKWVgqcZtMNJHUQDdYbKWVgqhjw09cZJE1JaqzXA1uQeB6KXJd9jimp6fPrUSqcaYaAx8O3A4DP6nqNTcY5mg8YZXqx1Ub5as4xdiH5jVsfqCnWyq6u0JaqzXAHh(raiKlaNaAH5bxcE4fMh9QvVb6SvqUowZWgWQ8R)e47hxl42J9(XWi)XkWHt7XQGMHECSOaIEmFXMp9XQvcIqpUbpoX7tEI8O3hRwjic946v0(y1gHISL0FccZJErAKllKaGmG2fp6TgExQEd0zRGCoJbV8Cm0O5A4pwyit2siuSWmasGUPNQjVI1TfQRVAWCjtpmQDDcOb0rIfvJW8OxnyUKPhg1Uob0uQeB6KXJdvdtqUXJdXH8Cm0O5A4pwyit2siuSWmasGUPb0rIfbp835ILwxdMlz6HrTRtanTs2sqxNKRacjBjThhY4TH1N8e5rV1WeKB84qCiphdnAUg(JfgYKTecflmdGeOBAaDKyrFccZJErAKllKaGmG2fp6TgExQEd0zRGCoJbV8Cm0vTBqoGe(1asyEsxaWixxrI1R0Qm)EECmCt6ILwxJibelmJ3twLMwjBjOpbH5rVinYLfsaqgq7Ih9wdVlvVb6SvqoNXGxEogA1BGMzf0rdiH5jzcYnECO7ZZXqREd0mRGoAaDKyrFc89JHdnbXc7XEf9yKllKaGEmODXJE58X9AV94jIE8fga6XPzfKJEC9kAFSxr3ESaOhVT)4mflShR2TLGE8ObpMVyZN(4g84eVp5jYJE1pMJgrp(cda940ScYFmfEfbEm0eelShlp(cdaLfR9s(0BGoBfK)yMG8hxVI2hFbjXJf2J5OvFCGESW8Gl94g8yOjiwypMsLytNEC9WREScjGyH94A7jRs)jimp6fPrUSqcaYaAx8O3A4D5iaKjBfKZ5erMEmmWyq8sHZjIm1RclzycYJfgVu4mg8UBeac5cWjGwyEWLsEhxbes2s6rait2ki3O2TnwyjV6QReMh9QhbGYI1QPuj20JfwYReMh9QhbGYI1QPuj20jdGosSO7HRMpGh(7aZLgnagPhbGqEdoAcoNHQkbDn8Wlmp6vREd0zRGCnLkXMESWsELW8OxT6nqNTcY1uQeB6Kbqhjw09WvZhWd)DG5sJgaJ0JaqiVbhnbNZqvLGU(6K55yORiXJfMzQQbKW8RHh(RCXsRRrKaIfMX7jRstRKTeusxaWixxrI1R0Qm)EECmCtEvEog6ks8yHzMQAajmp5DcZJE1iwdyvAkvIn9yHbp83LNJHUQDdYbKWVgqcZtExEog6ks8yHzMQAajmpPW8OxnI1awLMsLytpwyjVRQDdYbKWVbPswlYeRzydyv(1xF9NGW8OxKg5YcjaidODXJERH3LQ3aD2kiNZyWtfqCnWyq6u0iwdyvjZZXqxrIhlmZuvdiH5jDXsRRrKaIfMX7jRstRKTeusxaWixxrI1R0Qm)EECmCtkmp4sgAPtqO75kGqYwsx1Ub5as43mSYHqoi4N(eeMh9I0ixwibazaTlE0Bn8UuTQPns1mSYHqCgdE3XvaHKTKwTQPns1O2TnwyjV6oxS066bOpgVImcQIqAALSLGGhEH5bxYqlDccXHuUo5vcZdUKHw6eeIdPKuyEWLmqTRdyB409xeE4fMhCjdT0jieh4XvaHKTKUsaqgMGCZWkhc5GGFcE4fMhCjdT0jieh4XvaHKTKUQDdYbKWVzyLdHCqWpD9NGW8OxKg5YcjaidODXJERH3LmXAncZJEn2a5CUYH4jmp4sgxS06OpbH5rVinYLfsaqgq7Ih9wdVlHacSErMmGeVIZyWtyEWLm0sNGqCiLpbH5rVinYLfsaqgq7Ih9wdVlrSgWQ4mg8CbaJCDfjwVsRY875XXWnPlwADnIeqSWmEpzvAALSLG(e47hdhi8QhtBpHv9yxaWihX5Jd)Xb6XYJHjX(yVFmtq(JVqRCiKdc(PhlOhpcRLapowKtc0J7XJVWaqzXA1FccZJErAKllKaGmG2fp6TgExkaMSKHsv12OOxoJbpH5bxYqlDccXbECfqizlPfatwYqPQABu0BYJSIwL5CGhxbes2sAbWKLmuQQ2gf9AoYkFccZJErAKllKaGmG2fp6TgExoSYHqoi4N4mg8eMhCjdT0jieh4XvaHKTKUsaqgMGCZWkhc5GGF6tqyE0lsJCzHeaKb0U4rV1W7YraOSyTFccZJErAKllKaGmG2fp6TgExIynGvv8Ixka]] )

end
