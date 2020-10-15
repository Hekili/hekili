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
        firestorm = {
            id = 333100,
            duration = 5,
            max_stack = 1
        },

        sun_kings_blessing = {
            id = 333314,
            duration = 30,
            max_stack = 16
        },

        sun_kings_blessing_ready = {
            id = 333315,
            duration = 15,
            max_stack = 1
        }
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
            

            impact = function ()
                if hot_streak( firestarter.active or stat.crit + buff.fireball.stack * 10 >= 100 ) then
                    removeBuff( "fireball" )
                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    addStack( "fireball", nil, 1 )
                    if conduit.flame_accretion.enabled then addStack( "flame_accretion" ) end
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
                        if buff.sun_kings_blessing.stack == 16 then
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
                    if buff.sun_kings_blessing_ready.up then applyBuff( "combustion", 4 ) end
                else
                    if buff.hot_streak.up then
                        if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                        else removeBuff( "hot_streak" ) end
                        if legendary.sun_kings_blessing.enabled then
                            addStack( "sun_kings_blessing", nil, 1 )
                            if buff.sun_kings_blessing.stack == 16 then
                                removeBuff( "sun_kings_blessing" )
                                applyBuff( "sun_kings_blessing_ready" )
                            end
                        end
                    end
                end
            end,

            velocity = 35,

            impact = function ()
                if hot_streak( firestarter.active or buff.firestorm.up ) then
                    if talent.kindling.enabled then
                        setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
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


    spec:RegisterPack( "Fire", 20201013, [[d809KcqivOEKkK6sQqI2ef8jkK0OKioLeQvjvf9kPQAwuOUffc7cv)sfLHrc5ysuwMkeptQknnie5AuiABQqsFtQkW4OqcNdcbwhecnpiu3JeTpvuDqviHfQc6HqizIuirDrPQqzJqi1hjHQ0iHquNKeQWkLqEjfsKzscv6MKqvTtjQ(jjufdvQkOLscvKNsrtvf4QqiOVkvfYyLQcv7vk)LudgQdtSyrEmktgsxgzZI6Zq0OLkNwy1Kqf1RjbZMs3wL2Ts)wXWjPJtcLLRQNdmDQUUK2Ue8DPkJxI05HG1tHuZxfz)GUvw7GMjQ4uR8JOOJOOYuuz9LRif1xJ0iBMocQuZuvykiiPM5kxQzIOJNAMQcc2rqBh0mbt9zuZSZDvaI4zNHm8UAIZM7zG4wTIhZYEj7NbIl7SMzQgwxXX2sntuXPw5hrrhrrLPOY6lxrkQVgzFnkAMs17MVzAgxevZSlqrPTLAMOeG1mpAigrhpbXk(cscw0rdXDURcqep7mKH3vtC2Cpde3Qv8yw2lz)mqCzNbl6OHyfpmFs0dXL1xJH4JOOJOiyrWIoAigr1jlscGicl6OHyJaIreciiohi7C9txjwae)I3rpe7DYcXU8ijN7XL0(OrdcIZZdXwb4gbGyZIcXskSHJaexbcscWBM2a4G2bntuklvR3oOvEzTdAM0kjlH2oSzY(WPpKM5Xq8xxkppsIJgawOAJvEe0S5ELfLtkwnuvj0MPW8y2MjBQRtpqLS2M3k)iTdAM0kjlH2oSzoQnta5ntH5XSnZcYhsYsnZcITsntxS068C8eWL3PNtRKSeke3NqCoEc4Y70ZF6kXcG4(H4sGy2mw0P3YzZnvbEml)PRelaI7tiUeiUmi2iG4cYhsYsCfIf1gls9tOvMhZcX9je7ILwNRqSO2yrYPvswcfIlgIlgI7ti(yiMnJfD6TC2CtvGhZYFsqraI7tiovZzoBUPkWJz5OtVTzwqE9kxQz6XL0(OzZnvbEmBZBL332bntALKLqBh2mzF40hsZmvZzoBUPkWJz5OtVfInaXPAoZ)6s6jRvNE0ZrNEleBaIzZyrNElNn3uf4XS8NUsSai(CiwrqSbiUeiMnJfD6T8VUKEYA1Ph98NUsSai(Ciwrq8Ptq8XqSlwAD(xxspzT60JEoTsYsOqCXntH5XSntqxK9yrQvNE038w5isTdAM0kjlH2oSzY(WPpKMzjqCQMZC2CtvGhZYrNEleBaIt1CM)1L0twRo9ONJo9wi2aexceZMXIo9woBUPkWJz5pDLybqmIHyQuIvDs7XLG4tNGy2mw0P3YzZnvbEml)PRelaIphIzZyrNEl)f0qwxduLxboA9fpMfIlgIlgIpDcIlbIt1CM)1L0twRo9ONxvHydqmBgl60B5S5MQapML)0vIfaXNdX9vrqCXntH5XSnZxqdzDnqvEfAERCJSDqZKwjzj02Hnt2ho9H0mt1CMZMBQc8ywo60BHydqCQMZ8VUKEYA1Ph9C0P3cXgGy2mw0P3YzZnvbEml)PRelaIrmetLsSQtApUuZuyEmBZeLeVln)snVv(rTDqZKwjzj02Hnt2ho9H0mt1CMZMBQc8ywo60BHydqmkLQ5m)f0qwxduLxbDHQDPxsHnCe4OtVTzkmpMTzEJ)Nxhxbj18w59bTdAM0kjlH2oSzkmpMTzkgnOtEbOZZ66jRvNE03mzF40hsZSG8HKSe3JlP9rZMBQc8ywigXkHyJeI7hIlZiH4(eIliFijlXZZ6A0PMSKEwDfqqSbiUG8HKSe3JlP9rZMBQc8ywi(CiwrnZvUuZumAqN8cqNN11twRo9OV5TYnkAh0mPvswcTDyZK9HtFinZsG4cYhsYsCpUK2hnBUPkWJzHyedXLPii(0jiohi7C9txjwaeJyiUG8HKSe3JlP9rZMBQc8ywiU4MPW8y2MjYQ8OHS6jRfJM(X7AERCebTdAMcZJzBMSzz06V4eQoBLl1mPvswcTDyZBLxMIAh0mfMhZ2mFsuJfPoBLlbAM0kjlH2oS5TYlRS2bntH5XSnZ8WQacvlgn9Ht6ej3MjTsYsOTdBER8Yos7GMPW8y2MPA9JmcXIuNScWBM0kjlH2oS5TYlRVTdAMcZJzBMFOQAjDSAGQWOMjTsYsOTdBER8YqKAh0mfMhZ2m9osx30uxuDEEg1mPvswcTDyZBLxMr2oOzsRKSeA7WMj7dN(qAMFDP88ijoAayHQnw5rqZM7vwuoPy1qvLqHydqmBgl60B5PAoRrdaluTXkpcA2CVYIYFsqraInaXPAoZrdaluTXkpcA2CVYIQLNjlXrNEleBaIzZyrNElNn3uf4XS8NUsSai(CiUVkcInaXhdXPAoZrdaluTXkpcA2CVYIYRQntH5XSnt2uxNEGkzTnVvEzh12bntALKLqBh2mzF40hsZ8RlLNhjXrdaluTXkpcA2CVYIYjfRgQQekeBaIzZyrNElpvZznAayHQnw5rqZM7vwu(tckcqSbiovZzoAayHQnw5rqZM7vwuT8mzjo60BHydqmBgl60B5S5MQapML)0vIfaXNdX9vrqSbi(yiovZzoAayHQnw5rqZM7vwuEvTzkmpMTzkptwstLQAhqmBZBLxwFq7GMjTsYsOTdBMSpC6dPz(1LYZJK4ObGfQ2yLhbnBUxzr5KIvdvvcfInaXSzSOtVLNQ5SgnaSq1gR8iOzZ9klk)jbfbi2aeNQ5mhnaSq1gR8iOzZ9klQo)dW5OtVfInaXSzSOtVLZMBQc8yw(txjwaeFoe3xfbXgG4JH4unN5ObGfQ2yLhbnBUxzr5v1MPW8y2Mz(hGNgR38w5Lzu0oOzsRKSeA7WMj7dN(qAMPAoZ)6s6jRvNE0ZrNEleBaIlbIliFijlX94sAF0S5MQapMfIphIt1CM)1L0twRo9ONJwFXJzHydqCb5djzjUhxs7JMn3uf4XSq85qSW8ywEoEsNScW55Q1QFI1jpss7XLG4tNG4cYhsYsCpUK2hnBUPkWJzH4ZH4CGSZ1pDLybqCXntH5XSnZVUKEYA1Ph9nVvEzicAh0mPvswcTDyZK9HtFinZJH4cYhsYsC0aijlPzZnvbEmleBaIliFijlX94sAF0S5MQapMfIrSsiwrntH5XSntMyTAH5XSABa8MPnaUELl1mzZnvbEmRwTtauZBLFef1oOzsRKSeA7WM5O2mbK3mfMhZ2mliFijl1mli2k1mpgIliFijlXrdGKSKMn3uf4XSqSbiUG8HKSe3JlP9rZMBQc8ywigXqSW8ywEoEsNScW55Q1QFI1jpss7XLGyJaIliFijlXbDr2JfPwD6rV(j0kZJzH4(eIlbIzZyrNElh0fzpwKA1Ph98NUsSaigXqCb5djzjUhxs7JMn3uf4XSqCXqSbiUG8HKSe3JlP9rZMBQc8ywigXqCoq256NUsSai(0ji(RlLNhjXb1vRqSib6KLaGyrYjfRgQQekeBaIfMhZYZXt6KvaoN1jpscOZVW8ywXcXigIfMhZYZXt6Kvao)kLQzDYJKaqSraXkIBKqSbiUeiMnJfD6TCqxK9yrQvNE0ZF6kXcG4ZH4Ymsi(0ji(yiMnfOvwNVbYoxNfcIlUzwqE9kxQzMJN0jRaCT6m2yr28w5hPS2bntALKLqBh2mzF40hsZmvZz(xxspzT60JEEvfInaXLaXfKpKKL4ECjTpA2CtvGhZcXNdXkcIlUzkmpMTzYeRvlmpMvBdG3mTbW1RCPM5pQA1obqnVv(ros7GMjTsYsOTdBMJAZeqEZuyEmBZSG8HKSuZSGyRuZ8yiUG8HKSehnasYsA2CtvGhZcXgG4cYhsYsCpUK2hnBUPkWJzHyedXcZJz5QDdTrP6SvUeGNRwR(jwN8ijThxcInaXfKpKKL4ECjTpA2CtvGhZcXigIZbYox)0vIfaXNobXFDP88ijoOUAfIfjqNSeaelsoPy1qvLqBMfKxVYLAMQDdTrPA1zSXIS5TYpsFBh0mPvswcTDyZSciDVUWsAMa8yr2kVSMj7dN(qAMhdXfKpKKL454jDYkaxRoJnwKqSbiUeiUG8HKSe3JlP9rZMBQc8ywi(CiwrqCXqSbiUeiwyEuG00s3Gaq85kH4cYhsYs8o5r1mb46SvUeW)qbcInaXLaXECji2iG4unN5S5MQapMLBfGRPsvJNG4ZH4cYhsYsCuYkiOZw5sa)dfiiUyiUyi2aeFmeNJNaU8o9CH5rbcInaXhdXPAoZ7gxd8Nef4pjmVzwbKEYznsgAR8YAMcZJzBM54jDYkaV5TYpcIu7GMjTsYsOTdBMvaP71fwsZeGhlYw5L1mzF40hsZmhpbC5D65cZJceeBaIzDYJKaq85kH4YGydq8XqCb5djzjEoEsNScW1QZyJfjeBaIlbIpgIfMhZYZXtjXA5uPeR6XIeInaXhdXcZJz5Qi8tYkaNhRoBdKDoeBaIt1CM3rIhlsDvL)KWCi(0jiwyEmlphpLeRLtLsSQhlsi2aeFmeNQ5mVBCnWFsuG)KWCi(0jiwyEmlxfHFswb48y1zBGSZHydqCQMZ8os8yrQRQ8NeMdXgG4JH4unN5DJRb(tIc8NeMdXf3mRasp5SgjdTvEzntH5XSnZC8KozfG38w5hXiBh0mPvswcTDyZK9HtFinZsG4cYhsYsCpUK2hnBUPkWJzH4ZHyfbXfdXgG4unN5FDj9K1Qtp65OtVTzkmpMTzYeRvlmpMvBdG3mTbW1RCPMjWLfvEu9pU4XSnV5nZFu1QDcGAh0kVS2bntALKLqBh2mzF40hsZSeiwyEuG00s3Gaq85kH4cYhsYs8UX1a)jrbD2kxc4FOabXgG4sGypUeeBeqCQMZC2CtvGhZYTcW1uPQXtq85qCb5djzjokzfe0zRCjG)HceexmexmeBaIt1CM3nUg4pjkWFsyEZuyEmBZmBLlb8puGAER8J0oOzsRKSeA7WMj7dN(qAMPAoZb1vRqSib6KLaGyrQFsqrGxvHydqCQMZCqD1kelsGozjaiwK6Neue4pDLybq85qmtaU2Jl1mfMhZ2mvr4NKvaEZBL332bntALKLqBh2mzF40hsZmvZzEoEc4ZF5pjmVzkmpMTzQIWpjRa8M3khrQDqZKwjzj02Hnt2ho9H0mt1CM3nUg4pjkWFsyEZuyEmBZufHFswb4nVvUr2oOzsRKSeA7WMzfq6EDHL0mb4XISvEznt2ho9H0mt1CMdQRwHyrc0jlbaXIu)KGIahD6TqSbi(yiUeiwyEuG00s3Gaq85kH4cYhsYs8o5r1mb46SvUeW)qbcInaXLaXECji2iG4unN5S5MQapMLBfGRPsvJNG4ZH4cYhsYsCuYkiOZw5sa)dfiiUyiUyi2aeFmeNJNaU8o9CH5rbcInaXLaXhdXPAoZ7iXJfPUQYFsyoeBaIpgIt1CM3nUg4pjkWFsyoeBaIpgIvFQGEYznsgkphpPtwb4qSbiUeiwyEmlphpPtwb4CwN8ijaeFUsi(iq8PtqCjqSlwADUyPsb(laJwa6C9rGtRKSekeBaIzZyrNElh9fKZc0PNeVJ)KGIaexmeF6eexce7ILwNdi5JfP2NkRJtRKSekeBaID5rsoVJeR3XvzoeJyLqCFveexmexmexCZSci9KZAKm0w5L1mfMhZ2mZXt6KvaEZBLFuBh0mPvswcTDyZSciDVUWsAMa8yr2kVSMj7dN(qAMhdX54jGlVtpxyEuGGydqCjqCjqCjqSW8ywEoEkjwlNkLyvpwKq8PtqSW8ywUkc)KScW5uPeR6XIeIlgInaXPAoZ7iXJfPUQYFsyoexmeF6eexce7ILwNdi5JfP2NkRJtRKSekeBaID5rsoVJeR3XvzoeJyLqCFveeBaIlbIt1CM3rIhlsDvL)KWCi2aeFmelmpMLdyZZ64uPeR6XIeIpDcIpgIt1CM3nUg4pjkWFsyoeBaIpgIt1CM3rIhlsDvL)KWCi2aelmpMLdyZZ64uPeR6XIeInaXhdXDJRb(tIcAGkzTaDS6Snq25qCXqCXqCXnZkG0toRrYqBLxwZuyEmBZmhpPtwb4nVvEFq7GMjTsYsOTdBMcZJzBMmXA1cZJz12a4ntBaC9kxQzkmpkqAxS06GM3k3OODqZKwjzj02Hnt2ho9H0mt1CMRIWpmRaU8NeMdXgGyMaCThxcIrmeNQ5mxfHFywbC5pDLybqSbiMjax7XLGyedXPAoZ)6s6jRvNE0ZF6kXcGydqCjqCQMZCve(HzfWL)KWCiwjeNQ5mxfHFywbC5xPunWfMcq8PtqCQMZCve(HzfWL)0vIfaXigIzcW1ECjiUFiwyEmlphpLeRLtLsSQtApUeeF6eeNQ5mxSuPa)fGrlaDU(iWRQq8Ptq8Xq8xxkppsIdQRwHyrc0jlbaXIKtkwnuvjuiU4MPW8y2MPkc)KScWBERCebTdAM0kjlH2oSzY(WPpKMP6tf0izO8Y4a28Soi2aeNQ5mVJepwK6Qk)jH5qSbi2flTohqYhlsTpvwhNwjzjui2ae7YJKCEhjwVJRYCigXkH4(Qii2aeFmexcelmpkqAAPBqai(CLqCb5djzjE34AG)KOGoBLlb8puGGydqCjqShxcInciovZzoBUPkWJz5wb4AQu14ji(CiUG8HKSehLScc6SvUeW)qbcIlgIlUzkmpMTzQIWpjRa8M3kVmf1oOzsRKSeA7WMj7dN(qAMhdXfKpKKL4QDdTrPA1zSXIeInaXPAoZ7iXJfPUQYFsyoeBaIpgIt1CM3nUg4pjkWFsyoeBaIlbIfMhfin648a5gobXigIpceF6eelmpkqAAPBqai(CLqCb5djzjEN8OAMaCD2kxc4FOabXNobXcZJcKMw6geaIpxjexq(qswI3nUg4pjkOZw5sa)dfiiU4MPW8y2MPA3qBuQoBLlbAER8YkRDqZKwjzj02Hnt2ho9H0mD5rsoVJeR3XvzoeJyLqCFveeBaIDXsRZbK8XIu7tL1XPvswcTzkmpMTzcyZZ6AER8Yos7GMjTsYsOTdBMSpC6dPzkmpkqAAPBqai(Ci(intH5XSnt0xqolqNEs8UM3kVS(2oOzsRKSeA7WMj7dN(qAMLaXcZJcKMw6geaIpxjexq(qswI3jpQMjaxNTYLa(hkqqSbiUei2JlbXgbeNQ5mNn3uf4XSCRaCnvQA8eeFoexq(qswIJswbbD2kxc4FOabXfdXf3mfMhZ2mZw5sa)dfOM3kVmeP2bntH5XSnZC8usS2MjTsYsOTdBEZBMS5MQapMvR2jaQDqR8YAh0mPvswcTDyZK9HtFinZunN5S5MQapMLJo92MPW8y2MPnq25aTIZvuKxA9M3k)iTdAM0kjlH2oSzoQnta5ntH5XSnZcYhsYsnZcITsnZunN5S5MQapML)0vIfaX9dXPAoZzZnvbEmlhT(IhZcX9jexceZMXIo9woBUPkWJz5pDLybqmIH4unN5S5MQapML)0vIfaXf3mliVELl1mPsDArjunBUPkWJz1pDLybnVvEFBh0mPvswcTDyZCuBMckAZuyEmBZSG8HKSuZSGyRuZ8O2mzF40hsZmvZzoOUAfIfjqNSeaels9tckc8QkeF6eexq(qswItL60IsOA2CtvGhZQF6kXcG4ZH4Y4gje3Nqmsgk)kLcX9jexceNQ5mhuxTcXIeOtwcaIfj)kLQbUWuaInciovZzoOUAfIfjqNSeaelsoWfMcqCXnZcYRx5sntQuNwucvZMBQc8yw9txjwqZBLJi1oOzsRKSeA7WMj7dN(qAMPAoZzZnvbEmlhD6TntH5XSnZKGupzT)btbqZBLBKTdAM0kjlH2oSzY(WPpKMPW8OaPPLUbbG4ZH4YGydqCQMZC2CtvGhZYrNEBZuyEmBZ0gfIfPon3uZBLFuBh0mPvswcTDyZK9HtFinZunN5S5MQapMLJo9wi2aeNQ5m)RlPNSwD6rphD6TntH5XSnZB8)8a9K1(8xA9M3kVpODqZKwjzj02HntH5XSnZoeuP37Esq19(a49Erf0mzF40hsZmvZzoBUPkWJz5vvi2aelmpMLNJN0jRaCoRtEKeaIvcXkcInaXcZJz554jDYkaN)eRtEKK2JlbXNdXizO8RuAZCLl1m7qqLEV7jbv37dG37fvqZBLBu0oOzkmpMTzMSZGQNS27inT0fHMjTsYsOTdBERCebTdAMcZJzBMx6opc6jRTvwGQrFsUGMjTsYsOTdBER8Yuu7GMPW8y2MzV5TOfOy1pbMvwg1mPvswcTDyZBLxwzTdAM0kjlH2oSzwbKUxxyjntaESiBLxwZK9HtFintXOPpCINScWPxFfGtpNwjzjui2aeZ6KhjbG4ZvcXLbXgG4sG4sGyH5XS8C8KozfGZzDYJKa68lmpMvSqC)qCjqCQMZC2CtvGhZYF6kXcGyJaIt1CMNScWPxFfGtphT(IhZcXfdXNbXSzSOtVLNJN0jRaCoA9fpMfInciUeiovZzoBUPkWJz5pDLybqCXq8zqCjqCQMZ8Kvao96RaC65O1x8ywi2iGyfXnsiUyiUyi(CLqSIG4tNG4JHyXOPpCINScWPxFfGtpNwjzjui(0ji(yi2flTopBLlPNLtRKSekeF6eeNQ5mNn3uf4XS8NUsSaigXkH4unN5jRaC61xb40ZrRV4XSq8PtqCQMZ8Kvao96RaC65pDLybqmIHyfXnsi(0jiMuSAOQsO8oeuP37Esq19(a49ErfaXgGy2mw0P3Y7qqLEV7jbv37dG37fvGUVksrLHiDe(txjwaeJyi2iH4IHydqCQMZC2CtvGhZYRQqSbiUei(yiwyEmlhWMN1XPsjw1JfjeBaIpgIfMhZYvr4NKvaopwD2gi7Ci2aeNQ5mVJepwK6QkVQcXNobXcZJz5a28SoovkXQESiHydqCQMZ8UX1a)jrbo60BHydqCjqCQMZ8os8yrQRQC0P3cXNobXIrtF4epzfGtV(kaNEoTsYsOqCXq8PtqSy00hoXtwb40RVcWPNtRKSekeBaIDXsRZZw5s6z50kjlHcXgGyH5XSCve(jzfGZJvNTbYohInaXPAoZ7iXJfPUQYrNEleBaIt1CM3nUg4pjkWrNElexCZSci9KZAKm0w5L1mfMhZ2mZXt6KvaEZBLx2rAh0mPvswcTDyZSciDVUWsAMa8yr2kVSMj7dN(qAMhdXIrtF4epzfGtV(kaNEoTsYsOqSbiUeiwyEuG00s3GaqmIvcXcZJcKgDCEGCdNG4tNG4JHy2mw0P3Yv7gAJs1zRCja)jbfbiUyi2aeZMfTgop2m9Ry1mbWeuItRKSekeBaIzDYJKaq85kH4YGydqCjqCjqSW8ywEoEsNScW5So5rsaD(fMhZkwiUFiUeiUG8HKSeNk1PfLq1S5MQapMv)0vIfaXgbeNQ5mp2m9Ry1mbWeuIJwFXJzH4IH4ZGy2mw0P3YZXt6KvaohT(IhZcXgbexq(qswItL60IsOA2CtvGhZQF6kXcG4ZG4sG4unN5XMPFfRMjaMGsC06lEmleBeqSI4gjexmexmeFUsiwrq8PtqCb5djzjovQtlkHQzZnvbEmR(PRelaIrSsiovZzESz6xXQzcGjOehT(IhZcXNobXPAoZJnt)kwntambL4pDLybqmIHyfXnsiUyi2aeNQ5mNn3uf4XS8QkeBaIpgIt1CMNJNa(8x(tcZHydq8XqCQMZ8UX1a)jrb(tcZHydqC34AG)KOGgOswlqhRoBdKDoe3peNQ5mVJepwK6Qk)jH5qmIH4J0mRasp5SgjdTvEzntH5XSnZC8KozfG38w5L132bntALKLqBh2mRas3RlSKMjapwKTYlRzY(WPpKM5XqSy00hoXtwb40RVcWPNtRKSekeBaIlbIfMhfinT0niaeJyLqSW8OaPrhNhi3Wji(0ji(yiMnJfD6TC1UH2OuD2kxcWFsqraIlgInaXhdXSzrRHZJnt)kwntambL40kjlHcXgGywN8ijaeFUsiUmi2aeNQ5mNn3uf4XS8QkeBaIpgIt1CMNJNa(8x(tcZHydq8XqCQMZ8UX1a)jrb(tcZHydqC34AG)KOGgOswlqhRoBdKDoe3peNQ5mVJepwK6Qk)jH5qmIH4J0mRasp5SgjdTvEzntH5XSnZC8KozfG38w5LHi1oOzsRKSeA7WMj7dN(qAMFDP88ijoAayHQnw5rqZM7vwuoPy1qvLqHydqCQMZC0aWcvBSYJGMn3RSOC0P3cXgG4unN5ObGfQ2yLhbnBUxzr1YZKL4OtVfInaXSzSOtVLNQ5SgnaSq1gR8iOzZ9klk)jbfHMPW8y2MjBQRtpqLS2M3kVmJSDqZKwjzj02Hnt2ho9H0m)6s55rsC0aWcvBSYJGMn3RSOCsXQHQkHcXgG4unN5ObGfQ2yLhbnBUxzr5OtVfInaXPAoZrdaluTXkpcA2CVYIQLNjlXrNEleBaIzZyrNElpvZznAayHQnw5rqZM7vwu(tckcntH5XSnt5zYsAQuv7aIzBER8YoQTdAM0kjlH2oSzY(WPpKM5xxkppsIJgawOAJvEe0S5ELfLtkwnuvjui2aeNQ5mhnaSq1gR8iOzZ9klkhD6TqSbiovZzoAayHQnw5rqZM7vwuD(hGZrNEBZuyEmBZm)dWtJ1BER8Y6dAh0mPvswcTDyZuyEmBZKjwRwyEmR2gaVzAdGRx5sntH5rbs7ILwh08w5Lzu0oOzsRKSeA7WMzfq6EDHL0mb4XISvEznt2ho9H0mt1CMZMBQc8ywo60BHydqCjq8xxkppsIJgawOAJvEe0S5ELfLtkwnuvjuiwjeNQ5mhnaSq1gR8iOzZ9klkVQcXfdXgG4sGyH5XS8l5088y1zBGSZHydqSW8yw(LCAEES6Snq256NUsSaigXkHyfXnsi(0jiwyEmlhWMN1XPsjw1JfjeBaIfMhZYbS5zDCQuIvDs)0vIfaXigIve3iH4tNGyH5XS8C8usSwovkXQESiHydqSW8ywEoEkjwlNkLyvN0pDLybqmIHyfXnsi(0jiwyEmlxfHFswb4CQuIv9yrcXgGyH5XSCve(jzfGZPsjw1j9txjwaeJyiwrCJeIlUzwbKEYznsgAR8YAMcZJzBMS5MQapMT5TYldrq7GMjTsYsOTdBMSpC6dPzMQ5mNn3uf4XSCRaCnvQA8eeJyLqSW8ywoBUPkWJz5wb46kGqBMcZJzBMQJhZ28w5hrrTdAM0kjlH2oSzY(WPpKMzQMZC2CtvGhZYTcW1uPQXtqmIvcXcZJz5S5MQapMLBfGRRacTzkmpMTzMSZGQZ1hHM3k)iL1oOzsRKSeA7WMj7dN(qAMPAoZzZnvbEml3kaxtLQgpbXiwjelmpMLZMBQc8ywUvaUUci0MPW8y2MzIEa9kelYM3k)ihPDqZKwjzj02Hnt2ho9H0mt1CMZMBQc8ywUvaUMkvnEcIrSsiwyEmlNn3uf4XSCRaCDfqOntH5XSnZC8uYodAZBLFK(2oOzsRKSeA7WMj7dN(qAMPAoZzZnvbEml3kaxtLQgpbXiwjelmpMLZMBQc8ywUvaUUci0MPW8y2MPSmc4Vy1mXABER8JGi1oOzsRKSeA7WMj7dN(qAMPAoZzZnvbEml3kaxtLQgpbXiwjelmpMLZMBQc8ywUvaUUci0MPW8y2Mzfq6WPlO5TYpIr2oOzsRKSeA7WMj7dN(qAMPAoZ7gxd8Nef4pjmhInaXcZJcKMw6geaIpxjexq(qswIZMBQc8ywD2kxc4FOa1mfMhZ2mZw5sa)dfOM3k)ih12bntALKLqBh2mzF40hsZmvZzoOUAfIfjqNSeaels9tckc8QkeBaIt1CMdQRwHyrc0jlbaXIu)KGIa)PRelaIphIzcW1ECPMPW8y2MPkc)KScWBER8J0h0oOzsRKSeA7WMj7dN(qAMPAoZZXtaF(l)jH5ntH5XSntve(jzfG38w5hXOODqZKwjzj02Hnt2ho9H0mt1CMRIWpmRaU8NeMdXgG4unN5Qi8dZkGl)PRelaIphIzcW1ECji2aexceNQ5mNn3uf4XS8NUsSai(CiMjax7XLG4tNG4unN5S5MQapMLJo9wiU4MPW8y2MPkc)KScWBER8JGiODqZKwjzj02Hnt2ho9H0mt1CM3nUg4pjkWFsyoeBaIt1CMZMBQc8ywEvTzkmpMTzQIWpjRa8M3kVVkQDqZKwjzj02Hnt2ho9H0mvFQGgjdLxghWMN1bXgG4unN5DK4XIuxv5pjmVzkmpMTzQIWpjRa8M3kVVL1oOzsRKSeA7WMj7dN(qAMPAoZzZnvbEmlVQ2mfMhZ2mv7gAJs1zRCjqZBL33J0oOzsRKSeA7WMj7dN(qAMPAoZzZnvbEmlhD6TqSbiMnJfD6TC2CtvGhZYF6kXcGyedXmb4ApUeeBaIpgIzZIwdNNTYL0cJ9KhZYPvswcTzkmpMTzMJNsI128w59TVTdAM0kjlH2oSzY(WPpKMzQMZC2CtvGhZYF6kXcG4ZHyMaCThxcInaXPAoZzZnvbEmlVQcXNobXPAoZzZnvbEmlhD6TqSbiMnJfD6TC2CtvGhZYF6kXcGyedXmb4ApUuZuyEmBZeWMN118w59frQDqZKwjzj02Hnt2ho9H0mt1CMZMBQc8yw(txjwaeJyigjdLFLsHydqSW8OaPPLUbbG4ZH4YAMcZJzBM2OqSi1P5MAER8(AKTdAM0kjlH2oSzY(WPpKMzQMZC2CtvGhZYF6kXcGyedXizO8RukeBaIt1CMZMBQc8ywEvTzkmpMTzI(cYzb60tI318w599O2oOzsRKSeA7WMj7dN(qAMU8ijN3rI174QmhIrSsiUVkcInaXUyP15as(yrQ9PY640kjlH2mfMhZ2mbS5zDnV5ntH5rbs7ILwh0oOvEzTdAM0kjlH2oSzY(WPpKMPW8OaPPLUbbG4ZH4YGydqCQMZC2CtvGhZYrNEleBaIlbIliFijlX94sAF0S5MQapMfIphIzZyrNEl3gfIfPon3ehT(IhZcXNobXfKpKKL4ECjTpA2CtvGhZcXiwjeRiiU4MPW8y2MPnkelsDAUPM3k)iTdAM0kjlH2oSzY(WPpKM5XqCb5djzjoAaKKL0S5MQapMfInaXfKpKKL4ECjTpA2CtvGhZcXiwjeRii(0jiUeiMnJfD6T8l508C06lEmleJyiUG8HKSe3JlP9rZMBQc8ywi2aeFme7ILwN)1L0twRo9ONtRKSekexmeF6ee7ILwN)1L0twRo9ONtRKSekeBaIt1CM)1L0twRo9ONxvHydqCb5djzjUhxs7JMn3uf4XSq85qSW8yw(LCAEoBgl60BH4tNG4CGSZ1pDLybqmIH4cYhsYsCpUK2hnBUPkWJzBMcZJzBMxYP5BER8(2oOzsRKSeA7WMj7dN(qAMUyP15ILkf4VamAbOZ1hboTsYsOqSbiUeiovZzoBUPkWJz5OtVfInaXhdXPAoZ7gxd8Nef4pjmhIlUzkmpMTzI(cYzb60tI318M3mbUSOYJQ)XfpMTDqR8YAh0mPvswcTDyZK9HtFinZsGyH5rbstlDdcaXNReIliFijlX7gxd8Nef0zRCjG)HceeBaIlbI94sqSraXPAoZzZnvbEml3kaxtLQgpbXNdXfKpKKL4OKvqqNTYLa(hkqqCXqCXqSbiovZzE34AG)KOa)jH5ntH5XSnZSvUeW)qbQ5TYps7GMjTsYsOTdBMSpC6dPzMQ5mphpb85V8NeM3mfMhZ2mvr4NKvaEZBL332bntALKLqBh2mzF40hsZmvZzE34AG)KOa)jH5qSbiovZzE34AG)KOa)PRelaIrmelmpMLNJNsI1YPsjw1jThxQzkmpMTzQIWpjRa8M3khrQDqZKwjzj02Hnt2ho9H0mt1CM3nUg4pjkWFsyoeBaIlbIvFQGgjdLxgphpLeRfIpDcIZXtaxENEUW8OabXNobXcZJz5Qi8tYkaNhRoBdKDoexCZuyEmBZufHFswb4nVvUr2oOzsRKSeA7WMj7dN(qAMPAoZb1vRqSib6KLaGyrQFsqrGxvHydqCjqmBgl60B5FDj9K1Qtp65pDLybqC)qSW8yw(xxspzT60JEovkXQoP94sqC)qmtaU2JlbXNdXPAoZb1vRqSib6KLaGyrQFsqrG)0vIfaXNobXhdXUyP15FDj9K1Qtp650kjlHcXfdXgG4cYhsYsCpUK2hnBUPkWJzH4(HyMaCThxcIphIt1CMdQRwHyrc0jlbaXIu)KGIa)PRelOzkmpMTzQIWpjRa8M3k)O2oOzsRKSeA7WMj7dN(qAMPAoZ7gxd8Nef4pjmhInaXU8ijN3rI174QmhIrSsiUVkcInaXUyP15as(yrQ9PY640kjlH2mfMhZ2mvr4NKvaEZBL3h0oOzsRKSeA7WMj7dN(qAMPAoZvr4hMvax(tcZHydqmtaU2JlbXigIt1CMRIWpmRaU8NUsSai2aexceNQ5mxfHFywbC5pjmhIvcXPAoZvr4hMvax(vkvdCHPaeF6eeNQ5mxfHFywbC5pDLybqmIHyMaCThxcI7hIfMhZYZXtjXA5uPeR6K2JlbXNobXPAoZflvkWFby0cqNRpc8QkeF6eeFme)1LYZJK4G6QviwKaDYsaqSi5KIvdvvcfIlUzkmpMTzQIWpjRa8M3k3OODqZKwjzj02HnZkG096clPzcWJfzR8YAMSpC6dPzEmeNJNaU8o9CH5rbcInaXhdXfKpKKL454jDYkaxRoJnwKqSbiUeiUeiUeiwyEmlphpLeRLtLsSQhlsi(0jiwyEmlxfHFswb4CQuIv9yrcXfdXgG4unN5DK4XIuxv5pjmhIlgIpDcIlbIDXsRZbK8XIu7tL1XPvswcfInaXU8ijN3rI174QmhIrSsiUVkcInaXLaXPAoZ7iXJfPUQYFsyoeBaIpgIfMhZYbS5zDCQuIv9yrcXNobXhdXPAoZ7gxd8Nef4pjmhInaXhdXPAoZ7iXJfPUQYFsyoeBaIfMhZYbS5zDCQuIv9yrcXgG4JH4UX1a)jrbnqLSwGowD2gi7CiUyiUyiU4Mzfq6jN1izOTYlRzkmpMTzMJN0jRa8M3khrq7GMjTsYsOTdBMSpC6dPzQ(ubnsgkVmoGnpRdInaXPAoZ7iXJfPUQYFsyoeBaIDXsRZbK8XIu7tL1XPvswcfInaXU8ijN3rI174QmhIrSsiUVkcInaXhdXLaXcZJcKMw6geaIpxjexq(qswI3nUg4pjkOZw5sa)dfii2aexce7XLGyJaIt1CMZMBQc8ywUvaUMkvnEcIphIliFijlXrjRGGoBLlb8puGG4IH4IBMcZJzBMQi8tYkaV5TYltrTdAM0kjlH2oSzY(WPpKM5XqCb5djzjUA3qBuQwDgBSiHydqCjq8XqSlwADE(NR27iTa6iaNwjzjui(0jiwyEuG00s3Gaq85qCzqCXqSbiUeiwyEuG00s3Gaq85qCzqSbiwyEuG0OJZdKB4eeJyi(iq8PtqSW8OaPPLUbbG4ZvcXfKpKKL4DYJQzcW1zRCjG)HceeF6eelmpkqAAPBqai(CLqCb5djzjE34AG)KOGoBLlb8puGG4IBMcZJzBMQDdTrP6SvUeO5TYlRS2bntALKLqBh2mfMhZ2mzI1QfMhZQTbWBM2a46vUuZuyEuG0UyP1bnVvEzhPDqZKwjzj02Hnt2ho9H0mfMhfinT0niaeFoexwZuyEmBZe9fKZc0PNeVR5TYlRVTdAM0kjlH2oSzY(WPpKMPlpsY5DKy9oUkZHyeReI7RIGydqSlwADoGKpwKAFQSooTsYsOntH5XSntaBEwxZBLxgIu7GMjTsYsOTdBMSpC6dPzkmpkqAAPBqai(CLqCb5djzjEN8OAMaCD2kxc4FOabXgG4sGypUeeBeqCQMZC2CtvGhZYTcW1uPQXtq85qCb5djzjokzfe0zRCjG)HceexCZuyEmBZmBLlb8puGAER8YmY2bntH5XSnZC8usS2MjTsYsOTdBER8YoQTdAMcZJzBMa28SUMjTsYsOTdBEZBMQpXMBs82bTYlRDqZuyEmBZuEMSKowNSwI5ntALKLqBh28w5hPDqZKwjzj02HnZrTzciVzkmpMTzwq(qswQzwqSvQzEeiUpHyxS068SvUKwvCwhNwjzjuiUFiUVqCFcXhdXUyP15zRCjTQ4SooTsYsOnt2ho9H0mliFijlX7gxd8Nef0zRCjG)HceeReIvuZSG86vUuZSBCnWFsuqNTYLa(hkqnVvEFBh0mPvswcTDyZCuBMaYBMcZJzBMfKpKKLAMfeBLAMhbI7ti2flTopBLlPvfN1XPvswcfI7hI7le3Nq8XqSlwADE2kxsRkoRJtRKSeAZK9HtFinZcYhsYs8o5r1mb46SvUeW)qbcIvcXkQzwqE9kxQz2jpQMjaxNTYLa(hkqnVvoIu7GMjTsYsOTdBMJAZeqEZuyEmBZSG8HKSuZSGyRuZSVqCFcXUyP15zRCjTQ4SooTsYsOqC)q8rfI7ti(yi2flTopBLlPvfN1XPvswcTzY(WPpKMzb5djzjoBUPkWJz1zRCjG)HceeReIvuZSG86vUuZKn3uf4XS6SvUeW)qbQ5TYnY2bntALKLqBh2mh1M5taYBMcZJzBMfKpKKLAMfKxVYLAMOKvqqNTYLa(hkqntuklvR3mvuZBLFuBh0mPvswcTDyZCuBMpbiVzkmpMTzwq(qswQzwqE9kxQzQqSO2yrQFcTY8y2MjkLLQ1BMkIFKM3kVpODqZKwjzj02HnZrTzciVzkmpMTzwq(qswQzwqSvQzkmpMLd6IShlsT60JEotaU2JlbXNbXcZJz5GUi7XIuRo9ON7btbThxcI7tiUVnt2ho9H0mztbAL15BGSZ1zHAMfKxVYLAMGUi7XIuRo9Ox)eAL5XSnVvUrr7GMjTsYsOTdBMJAZeqEZuyEmBZSG8HKSuZSGyRuZKuSAOQsO8RSrMa(ONS(kOlbaq8PtqmPy1qvLq5iTcAi(8aDsqrsq8PtqmPy1qvLq5iTcAi(8a9LqfRnMfIpDcIjfRgQQekpqUHhZQVcscOZvabXNobXKIvdvvcL7gTSeqNKxbGASeaIpDcIjfRgQQekxm66tE3a0GyrsOAvB9kiji(0jiMuSAOQsOCzzbTUwHDC9K19ca6CH4tNGysXQHQkHYbDdtHu40d0zzrcXNobXKIvdvvcLVu9fRgGWkQastBNSm6H4tNGysXQHQkHYtILYXt60llRRzwqE9kxQzYMBQc8yw9S6kGAERCebTdAM0kjlH2oSzoQnta5ntH5XSnZcYhsYsnZcITsntsXQHQkHYfJg0jVa05zD9K1Qtp6HydqCb5djzjoBUPkWJz1ZQRaQzwqE9kxQzMN11Otnzj9S6kGAER8Yuu7GMjTsYsOTdBMJAZeqEZuyEmBZSG8HKSuZSGyRuZSmJIMj7dN(qAMfKpKKL45zDn6utwspRUcii2aeFme7ILwNNJNaU8o9CALKLqHydqCb5djzjEEwxpzT60JET6tS5MexZ6KDjleReIvuZSG86vUuZmpRRNSwD6rVw9j2CtIRzDYUKT5TYlRS2bntALKLqBh28w5LDK2bntALKLqBh2mx5sntXObDYlaDEwxpzT60J(MPW8y2MPy0Go5fGopRRNSwD6rFZBLxwFBh0mfMhZ2mVX)ZRJRGKAM0kjlH2oS5TYldrQDqZuyEmBZufHFswb4ntALKLqBh28M38Mzb6bXSTYpIIoIIktrLDKMzp53yrcAM9rhfkovUIJYv8IicXq8bDeehx15DioppeBurPSuTUrfIFsXQXtOqmyUeelvFUItOqmRtwKeGdlsXnwcIpIIqeHye1SfO3jui2OYMc0kRZ7JZPvswc1OcX(aXgv2uGwzDEFCJkexszLwmhweSO(OJcfNkxXr5kEreHyi(GocIJR68oeNNhInQQpXMBsCJke)KIvJNqHyWCjiwQ(CfNqHywNSijahwKIBSee3hGicXiQzlqVtOqSzCruqmaH1LsH4Jsi2hiwXTkqmAuiaXSq8OsV4ZdXLCwXqCjLvAXCyrkUXsqCFaIieJOMTa9oHcXgv2uGwzDEFCoTsYsOgvi2hi2OYMc0kRZ7JBuH4skR0I5WIGf1hDuO4u5kokxXlIiedXh0rqCCvN3H488qSrLn3uf4XSA1obqgvi(jfRgpHcXG5sqSu95koHcXSozrsaoSif3yjiUSYqeHye1SfO3jui2mUikigGW6sPq8rje7deR4wfignkeGywiEuPx85H4soRyiUKJuAXCyrkUXsqCzhbreIruZwGENqHyZ4IOGyacRlLcXhLqSpqSIBvGy0OqaIzH4rLEXNhIl5SIH4sosPfZHfblsXXvDENqH4JkelmpMfITbWbCyrntGkXALFu7BZu9NCyPM5rdXi64jiwXxqsWIoAiUZDvaI4zNHm8UAIZM7zG4wTIhZYEj7NbIl7myrhneR4H5tIEiUS(AmeFefDefblcw0rdXiQozrsaeryrhneBeqmIqabX5azNRF6kXcG4x8o6HyVtwi2Lhj5CpUK2hnAqqCEEi2ka3iaeBwuiwsHnCeG4kqqsaoSOJgIncigrOkQ4eeBhKbdIFcreIvCRSafInk)KCbCyrhneBeqSI7maAHyMaCi(jfRgpDP1bqCEEigrn3uf4XSqCjbN4gdXOZAuDiUBSOqC4qCEEiwG48tGoiwXNCAEiMjaVyoSOJgInci2OCaKKLGyzHyA9hbi27ehI7nvlke)eOADiowiwG4o5rzcWH4(qe(jzfGdXXAeiLlXHfD0qSraX9Xwjzjig4FWCiM1rmfIfjeplelqCM6bX55vaaXXcXEhbXhf9HkUqSpq8tOvgbX9Mxb7iOCyrWIoAiUpwPeR6ekeNO88eeZMBsCioriJfWH4JcgJuDaeVZAeDYFZvlelmpMfaXZArGdlsyEmlGR(eBUjX7x5zYZKL0X6K1smhw0rdXh0faiUG8HKSeedujwKdcaXEhbXB9MOhINme7YJKCaeloe3RlyDqmI84qSP)KOaeJOTYLa(hkqaiEQoiqjiEYqmIAUPkWJzHyq3uTOqCIG4kGq5WIeMhZc4QpXMBs8(vEwb5djzjJx5sk7gxd8Nef0zRCjG)HcKXJQsa5ghzLfKpKKL4DJRb(tIc6SvUeW)qbsPImUGyRKYJ0NUyP15zRCjTQ4SooTsYsO933(8yxS068SvUKwvCwhNwjzjuyrhneFqxaG4cYhsYsqmqLyroiae7DeeV1BIEiEYqSlpsYbqS4qCVUG1bXiYYJcXikb4qmI2kxc4FOabG4P6GaLG4jdXiQ5MQapMfIbDt1IcXjcIRacfIfaeNdRLEoSiH5XSaU6tS5MeVFLNvq(qswY4vUKYo5r1mb46SvUeW)qbY4rvjGCJJSYcYhsYs8o5r1mb46SvUeW)qbsPImUGyRKYJ0NUyP15zRCjTQ4SooTsYsO933(8yxS068SvUKwvCwhNwjzjuyrhneFqxaG4cYhsYsqmqLyroiae7DeeV1BIEiEYqSlpsYbqS4qCVUG1bXiYJdXM(tIcqmI2kxc4FOabGy5jiUciuigT(XIeIruZnvbEmlhwKW8ywax9j2CtI3VYZkiFijlz8kxsjBUPkWJz1zRCjG)HcKXJQsa5ghzLfKpKKL4S5MQapMvNTYLa(hkqkvKXfeBLu23(0flTopBLlPvfN1XPvswcT)JAFESlwADE2kxsRkoRJtRKSekSOJgIpOlaqCb5djzjioaqCfqOqSpqmqLyrgbi27iiwUtDDiEYqShxcIJfIbeBwuae7DIdX3kWHyvbaGyj70dXiQ5MQapMfIPsvJNaqCIYZtqmI2kxc4FOabG4EH1cXjcIRacfI35VI1IahwKW8ywax9j2CtI3VYZkiFijlz8kxsjkzfe0zRCjG)HcKXOuwQwxPImEuv(eGCyrhne3hfEheBukwuBSingIruZnvbEmRrfaXSzSOtVfI7fwleNii(j0kJqH4ecqSaXVSOZfIL7ux3yiovDi27iiER3e9q8KHy2hoaIbU8oaIlqpcqCxGSdILStpelmpkiESiHye1CtvGhZcXYIcXa70daXOtVfI9PN8Oai27iiMwuiEYqmIAUPkWJznQaiMnJfD6TCiUpQJwi(kkelsigLybiMfaXXcXEhbXhf9HkUgdXiQ5MQapM1OcG4NUsSXIeIzZyrNElehai(j0kJqH4ecqS3faio)cZJzHyFGyHXM66qCEEi2OuSO2yrYHfjmpMfWvFIn3K49R8ScYhsYsgVYLuQqSO2yrQFcTY8ywJrPSuTUsfXpIXJQYNaKdlsyEmlGR(eBUjX7x5zfKpKKLmELlPe0fzpwKA1Ph96NqRmpM14rvjGCJli2kPuyEmlh0fzpwKA1Ph9CMaCThx6OuyEmlh0fzpwKA1Ph9CpykO94s9zFnoYkztbAL15BGSZ1zH40kjlHclsyEmlGR(eBUjX7x5zfKpKKLmELlPKn3uf4XS6z1vaz8OQeqUXfeBLuskwnuvju(v2itaF0twFf0LaGtNifRgQQekhPvqdXNhOtcks60jsXQHQkHYrAf0q85b6lHkwBm7PtKIvdvvcLhi3WJz1xbjb05kGoDIuSAOQsOC3OLLa6K8kauJLaNorkwnuvjuUy01N8UbObXIKq1Q26vqsNorkwnuvjuUSSGwxRWoUEY6EbaDUNorkwnuvjuoOBykKcNEGollYtNifRgQQekFP6lwnaHvubKM2ozz0F6ePy1qvLq5jXs54jD6LL1blsyEmlGR(eBUjX7x5zfKpKKLmELlPmpRRrNAYs6z1vaz8OQeqUXfeBLuskwnuvjuUy0Go5fGopRRNSwD6rVHcYhsYsC2CtvGhZQNvxbeSOJgIpOlaqCb5djzjigLC6VXsaiUxhTq8rHrd6KxmQaigrpRdXtgI7dNE0dXbaIRacfItuEEcI9ocIvRwlehzioLfEEwxpzT60JET6tS5MexZ6KDjlehaiEhhIbQelYbHYHfjmpMfWvFIn3K49R8ScYhsYsgVYLuMN11twRo9OxR(eBUjX1SozxYA8OQeqUXfeBLuwMrHXrwzb5djzjEEwxJo1KL0ZQRaYWXUyP1554jGlVtpNwjzjudfKpKKL45zD9K1Qtp61QpXMBsCnRt2LSkveSiH5XSaU6tS5MeVFLNbwrf0nUg4IdGfjmpMfWvFIn3K49R8SkG0HtxJx5skfJg0jVa05zD9K1Qtp6HfjmpMfWvFIn3K49R8SB8)864kijyrcZJzbC1NyZnjE)kptfHFswb4WIGfD0qCFSsjw1juiMkqpcqShxcI9ocIfMppehaiwkiHvswIdlsyEmlqjBQRtpqLSwJJSYJ)6s55rsC0aWcvBSYJGMn3RSOCsXQHQkHclsyEmlOFLNvq(qswY4vUKspUK2hnBUPkWJznEuvci34cITskDXsRZZXtaxENEoTsYsO9zoEc4Y70ZF6kXc6Ve2mw0P3YzZnvbEml)PRelOplPmJOG8HKSexHyrTXIu)eAL5XS9PlwADUcXIAJfjNwjzj0IlUppMnJfD6TC2CtvGhZYFsqrOpt1CMZMBQc8ywo60BHfjmpMf0VYZaDr2JfPwD6rVXrwzQMZC2CtvGhZYrNERHunN5FDj9K1Qtp65OtV1aBgl60B5S5MQapML)0vIfCUImucBgl60B5FDj9K1Qtp65pDLybNROtNo2flTo)RlPNSwD6rpNwjzj0IHfjmpMf0VYZEbnK11av5vW4iRSKunN5S5MQapMLJo9wdPAoZ)6s6jRvNE0ZrNERHsyZyrNElNn3uf4XS8NUsSaetLsSQtApU0PtSzSOtVLZMBQc8yw(txjwW5SzSOtVL)cAiRRbQYRahT(IhZwCXNovsQMZ8VUKEYA1Ph98QQb2mw0P3YzZnvbEml)PRel48(QOIHfjmpMf0VYZqjX7sZVKXrwzQMZC2CtvGhZYrNERHunN5FDj9K1Qtp65OtV1aBgl60B5S5MQapML)0vIfGyQuIvDs7XLGfjmpMf0VYZUX)ZRJRGKmoYkt1CMZMBQc8ywo60BnGsPAoZFbnK11av5vqxOAx6Luydhbo60BHfjmpMf0VYZQashoDnELlPumAqN8cqNN11twRo9O34iRSG8HKSe3JlP9rZMBQc8yweR0i7VmJSpliFijlXZZ6A0PMSKEwDfqgkiFijlX94sAF0S5MQapM9CfblsyEmlOFLNHSkpAiREYAXOPF8oJJSYskiFijlX94sAF0S5MQapMfXLPOtNYbYox)0vIfG4cYhsYsCpUK2hnBUPkWJzlgwKW8ywq)kpJnlJw)fNq1zRCjyrcZJzb9R8SNe1yrQZw5sayrcZJzb9R8S8WQacvlgn9Ht6ejxyrcZJzb9R8m16hzeIfPozfGdlsyEmlOFLN9HQQL0XQbQcJGfjmpMf0VYZ8osx30uxuDEEgbl6OHyfVKdXEhbXObGfQ2yLhbnBUxzrH4unNH4QQXqCDTeaaXS5MQapMfIdaedMz5WIeMhZc6x5zSPUo9avYAnoYk)6s55rsC0aWcvBSYJGMn3RSOCsXQHQkHAGnJfD6T8unN1ObGfQ2yLhbnBUxzr5pjOiyivZzoAayHQnw5rqZM7vwuT8mzjo60BnWMXIo9woBUPkWJz5pDLybN3xfz44unN5ObGfQ2yLhbnBUxzr5vvyrcZJzb9R8m5zYsAQuv7aIznoYk)6s55rsC0aWcvBSYJGMn3RSOCsXQHQkHAGnJfD6T8unN1ObGfQ2yLhbnBUxzr5pjOiyivZzoAayHQnw5rqZM7vwuT8mzjo60BnWMXIo9woBUPkWJz5pDLybN3xfz44unN5ObGfQ2yLhbnBUxzr5vvyrcZJzb9R8S8papnw34iR8RlLNhjXrdaluTXkpcA2CVYIYjfRgQQeQb2mw0P3Yt1CwJgawOAJvEe0S5ELfL)KGIGHunN5ObGfQ2yLhbnBUxzr15FaohD6TgyZyrNElNn3uf4XS8NUsSGZ7RImCCQMZC0aWcvBSYJGMn3RSO8QkSiH5XSG(vE2xxspzT60JEJJSYunN5FDj9K1Qtp65OtV1qjfKpKKL4ECjTpA2CtvGhZEEQMZ8VUKEYA1Ph9C06lEmRHcYhsYsCpUK2hnBUPkWJzpxyEmlphpPtwb48C1A1pX6KhjP94sNovq(qswI7XL0(OzZnvbEm755azNRF6kXckgwKW8ywq)kpJjwRwyEmR2ga34vUKs2CtvGhZQv7eazCKvECb5djzjoAaKKL0S5MQapM1qb5djzjUhxs7JMn3uf4XSiwPIGfD0q8bkEmkR4breIpOJG4YmsiEj5HyVJGyArH4jdXExaGy2SOHhZcXbaILfILpf(lpcqmBw0WJzH488qmRJykelsioYqSzxK9yrcX9Htp6H4EH1cXjcIRQqmyMLdXi6yrHybIVZtqSWy1xCcI7jiaX(aXkStpi27ehIn7IShlsiUpC6rpe3lSwiw9NKKSiaXjcIRacfItuEEcI9ocInnkDieR(dJdlsyEmlOFLNvq(qswY4vUKYC8KozfGRvNXglsJli2kP84cYhsYsC0aijlPzZnvbEmRHcYhsYsCpUK2hnBUPkWJzrSW8ywEoEsNScW55Q1QFI1jpss7XLmIcYhsYsCqxK9yrQvNE0RFcTY8y2(Se2mw0P3YbDr2JfPwD6rp)PRelaXfKpKKL4ECjTpA2CtvGhZwSHcYhsYsCpUK2hnBUPkWJzrCoq256NUsSGtN(6s55rsCqD1kelsGozjaiwKCsXQHQkHAqyEmlphpPtwb4CwN8ijGo)cZJzflIfMhZYZXt6Kvao)kLQzDYJKagHI4gPHsyZyrNElh0fzpwKA1Ph98NUsSGZlZipD6y2uGwzD(gi7CDwioTsYsOfdlsyEmlOFLNXeRvlmpMvBdGB8kxs5pQA1obqghzLPAoZ)6s6jRvNE0ZRQgkPG8HKSe3JlP9rZMBQc8y2ZvuXWIeMhZc6x5zfKpKKLmELlPuTBOnkvRoJnwKgxqSvs5XfKpKKL4ObqswsZMBQc8ywdfKpKKL4ECjTpA2CtvGhZIyH5XSC1UH2OuD2kxcWZvRv)eRtEKK2JlzOG8HKSe3JlP9rZMBQc8yweNdKDU(PRel40PVUuEEKehuxTcXIeOtwcaIfjNuSAOQsOWIoAiUpQJwigrwEuMa8yrcXiARCji20)qbYyigrhpbXhAfGdGyq3uTOqCIG4kGqHyFGyK0sV4eeJipoeB6pjkaGyzrHyFGyQuNwui(qRaC6HyfFb40ZHfjmpMf0VYZYXt6KvaUXvaPNCwJKHQSmJRas3RlSKMjapwKklZ4iR84cYhsYs8C8KozfGRvNXglsdLuq(qswI7XL0(OzZnvbEm75kQydLimpkqAAPBqGZvwq(qswI3jpQMjaxNTYLa(hkqgkXJlzePAoZzZnvbEml3kaxtLQgpDEb5djzjokzfe0zRCjG)HcuXfB44C8eWL3PNlmpkqgoovZzE34AG)KOa)jH5WIoAi2OC9JfjeJOJNaU8o9gdXi64ji(qRaCaelpbXvaHcXG4gw5TiaX(aXO1pwKqmIAUPkWJz5qSIxAPxSwemgI9ocbiwEcIRacfI9bIrsl9ItqmI84qSP)KOaaI71rleZ(WbqCVWAH4DCiorqCpb4ekellke3l8oi(qRaC6HyfFb40Bme7DecqmOBQwuiorqmq9jbfINQdX(aXxjwxIfI9ocIp0kaNEiwXxao9qCQMZCyrcZJzb9R8SC8KozfGBCfq6jN1izOklZ4kG096clPzcWJfPYYmoYkZXtaxENEUW8OazG1jpscCUYYmCCb5djzjEoEsNScW1QZyJfPHsowyEmlphpLeRLtLsSQhlsdhlmpMLRIWpjRaCES6Snq25gs1CM3rIhlsDvL)KW8tNeMhZYZXtjXA5uPeR6XI0WXPAoZ7gxd8Nef4pjm)0jH5XSCve(jzfGZJvNTbYo3qQMZ8os8yrQRQ8NeMB44unN5DJRb(tIc8NeMxmSiH5XSG(vEgtSwTW8ywTnaUXRCjLaxwu5r1)4IhZACKvwsb5djzjUhxs7JMn3uf4XSNROInKQ5m)RlPNSwD6rphD6TWIGfjmpMfWfMhfiTlwADGsBuiwK60CtghzLcZJcKMw6ge48YmKQ5mNn3uf4XSC0P3AOKcYhsYsCpUK2hnBUPkWJzpNnJfD6TCBuiwK60CtC06lEm7PtfKpKKL4ECjTpA2CtvGhZIyLkQyyrcZJzbCH5rbs7ILwh0VYZUKtZBCKvECb5djzjoAaKKL0S5MQapM1qb5djzjUhxs7JMn3uf4XSiwPIoDQe2mw0P3YVKtZZrRV4XSiUG8HKSe3JlP9rZMBQc8ywdh7ILwN)1L0twRo9ONtRKSeAXNo5ILwN)1L0twRo9ONtRKSeQHunN5FDj9K1Qtp65vvdfKpKKL4ECjTpA2CtvGhZEUW8yw(LCAEoBgl60BpDkhi7C9txjwaIliFijlX94sAF0S5MQapMfwKW8ywaxyEuG0UyP1b9R8m0xqolqNEs8oJJSsxS06CXsLc8xagTa056JaNwjzjudLKQ5mNn3uf4XSC0P3A44unN5DJRb(tIc8NeMxmSiyrcZJzbC2CtvGhZQv7eaP0gi7CGwX5kkYlTUXrwzQMZC2CtvGhZYrNElSOJgI7Jb84kobXDtpi2olsigrn3uf4XSqCVWAHyRaCi27Kvbae7deBwxi2OuSinQai(qlbaXIeI9bIrjN(BSee3n9GyeD8eeFOvaoaIbDt1IcXjcIRacLdlsyEmlGZMBQc8ywTANaO(vEwb5djzjJx5skPsDArjunBUPkWJz1pDLybgpQkbKBCbXwjLPAoZzZnvbEml)PRelO)unN5S5MQapMLJwFXJz7ZsyZyrNElNn3uf4XS8NUsSaeNQ5mNn3uf4XS8NUsSGIHfjmpMfWzZnvbEmRwTtau)kpRG8HKSKXRCjLuPoTOeQMn3uf4XS6NUsSaJhvLckQXfeBLuEunoYkt1CMdQRwHyrc0jlbaXIu)KGIaVQE6ub5djzjovQtlkHQzZnvbEmR(PRel48Y4gzFIKHYVsP9zjPAoZb1vRqSib6KLaGyrYVsPAGlmfmIunN5G6QviwKaDYsaqSi5axykumSiH5XSaoBUPkWJz1QDcG6x5zjbPEYA)dMcaJJSYunN5S5MQapMLJo9wyrcZJzbC2CtvGhZQv7ea1VYZSrHyrQtZnzCKvkmpkqAAPBqGZlZqQMZC2CtvGhZYrNElSiH5XSaoBUPkWJz1QDcG6x5z34)5b6jR95V06ghzLPAoZzZnvbEmlhD6Tgs1CM)1L0twRo9ONJo9wyrcZJzbC2CtvGhZQv7ea1VYZQashoDnELlPSdbv69UNeuDVpaEVxubghzLPAoZzZnvbEmlVQAqyEmlphpPtwb4CwN8ijGsfzqyEmlphpPtwb48NyDYJK0ECPZrYq5xPuyrcZJzbC2CtvGhZQv7ea1VYZs2zq1tw7DKMw6IaSiH5XSaoBUPkWJz1QDcG6x5zx6opc6jRTvwGQrFsUayrcZJzbC2CtvGhZQv7ea1VYZ6nVfTafR(jWSYYiyrhneBuU(XIeIruZnvbEmRXqmIoEcIp0kahaXYtqCfqOqSpqmsAPxCcIrKhhIn9NefaqSSOq8n24ggnbXEhbXYDQRdXtgI94sqmqLwhIPsjw1JfjepEh9qmqLSwahIr0ZdXaxwu5rHyeD8KXqmIoEcIp0kahaXYtq8SweG4kGqH4ED0cXiYK4XIeIreQcXbaIfMhfiiEEiUxhTqSaXMS5zDqmtaoehaiowiw9hKpbaqSSOqmImjESiHyeHQqSSOqmI84qSP)KOaelpbX74qSW8OaXH4(OW7G4dTcWPhIv8fGtpellkeJOTYLGyfpRXqmIoEcIp0kahaXmzHybfn8ywXAraIteexbeke3RlSeeJipoeB6pjkaXYIcXiYK4XIeIreQcXYtq8ooelmpkqqSSOqSaX9Hi8tYkahIdaehle7DeelXdXYIcXIfmqCVUWsqmtaESiHyt28SoiMkqlehzigrMepwKqmIqvioaqSyFsqraIfMhfioeFqhbXwXD6HyXANEai27nqmI84qSP)KOae3hIWpjRaCae7deNiiMjahIJfIbvgJaGywiwYo9qS3rqSjBEwhhIpkqrdpMvSweG4EH3bXhAfGtpeR4laNEiwwuigrBLlbXkEwJHyeD8eeFOvaoaIbDt1IcX74qCIG4kGqH46AjaaIp0kaNEiwXxao9qCaGyjnvhI9bIPsvJNG45HyVJEcILNG478ee7DYcX0ovKDqmIoEcIp0kahaX(aXuPoTOq8Hwb40dXk(cWPhI9bI9ocIPffINmeJOMBQc8ywoSiH5XSaoBUPkWJz1QDcG6x5z54jDYka34kG0toRrYqvwMXvaP71fwsZeGhlsLLzCKvkgn9Ht8Kvao96RaC650kjlHAG1jpscCUYYmusjcZJz554jDYkaNZ6Khjb05xyEmRy7VKunN5S5MQapML)0vIfyePAoZtwb40RVcWPNJwFXJzl(OKnJfD6T8C8KozfGZrRV4XSgrjPAoZzZnvbEml)PRelO4JYss1CMNScWPxFfGtphT(IhZAekIBKfx85kv0Pthlgn9Ht8Kvao96RaC650kjlHE60XUyP15zRCj9SCALKLqpDkvZzoBUPkWJz5pDLybiwzQMZ8Kvao96RaC65O1x8y2tNs1CMNScWPxFfGtp)PRelaXkIBKNorkwnuvjuEhcQ07DpjO6EFa8EVOcmWMXIo9wEhcQ07DpjO6EFa8EVOc09vrkQmePJWF6kXcqSrwSHunN5S5MQapMLxvnuYXcZJz5a28SoovkXQESinCSW8ywUkc)KScW5XQZ2azNBivZzEhjESi1vvEv90jH5XSCaBEwhNkLyvpwKgs1CM3nUg4pjkWrNERHss1CM3rIhlsDvLJo92tNeJM(WjEYkaNE9vao9CALKLql(0jXOPpCINScWPxFfGtpNwjzjudUyP15zRCj9SCALKLqnimpMLRIWpjRaCES6Snq25gs1CM3rIhlsDvLJo9wdPAoZ7gxd8Nef4OtVTyyrhne3hfEheR4yZ0VIfIrucGjOKXqmIoEcIp0kahaXGUPArH4DCiorqCfqOqCDTeaaXko2m9RyHyeLayckbXbaIL0uDi2hiMkvnEcINhI9o6jiwEcIVZtqS3jlet7ur2bXi64ji(qRaCae7detL60IcXhAfGtpeR4laNEi2hi27iiMwuiEYqmIAUPkWJz5WIeMhZc4S5MQapMvR2jaQFLNLJN0jRaCJRasp5SgjdvzzgxbKUxxyjntaESivwMXrw5XIrtF4epzfGtV(kaNEoTsYsOgkryEuG00s3GaiwPW8OaPrhNhi3WPtNoMnJfD6TC1UH2OuD2kxcWFsqrOydSzrRHZJnt)kwntambL40kjlHAG1jpscCUYYmusjcZJz554jDYkaNZ6Khjb05xyEmRy7VKcYhsYsCQuNwucvZMBQc8yw9txjwGrKQ5mp2m9Ry1mbWeuIJwFXJzl(OKnJfD6T8C8KozfGZrRV4XSgrb5djzjovQtlkHQzZnvbEmR(PRel4OSKunN5XMPFfRMjaMGsC06lEmRrOiUrwCXNRurNovq(qswItL60IsOA2CtvGhZQF6kXcqSYunN5XMPFfRMjaMGsC06lEm7PtPAoZJnt)kwntambL4pDLybiwrCJSydPAoZzZnvbEmlVQA44unN554jGp)L)KWCdhNQ5mVBCnWFsuG)KWCdDJRb(tIcAGkzTaDS6Snq259NQ5mVJepwK6Qk)jH5i(iWIeMhZc4S5MQapMvR2jaQFLNLJN0jRaCJRasp5SgjdvzzgxbKUxxyjntaESivwMXrw5XIrtF4epzfGtV(kaNEoTsYsOgkryEuG00s3GaiwPW8OaPrhNhi3WPtNoMnJfD6TC1UH2OuD2kxcWFsqrOydhZMfTgop2m9Ry1mbWeuItRKSeQbwN8ijW5klZqQMZC2CtvGhZYRQgoovZzEoEc4ZF5pjm3WXPAoZ7gxd8Nef4pjm3q34AG)KOGgOswlqhRoBdKDE)PAoZ7iXJfPUQYFsyoIpcSiH5XSaoBUPkWJz1QDcG6x5zSPUo9avYAnoYk)6s55rsC0aWcvBSYJGMn3RSOCsXQHQkHAivZzoAayHQnw5rqZM7vwuo60BnKQ5mhnaSq1gR8iOzZ9klQwEMSehD6TgyZyrNElpvZznAayHQnw5rqZM7vwu(tckcWIeMhZc4S5MQapMvR2jaQFLNjptwstLQAhqmRXrw5xxkppsIJgawOAJvEe0S5ELfLtkwnuvjudPAoZrdaluTXkpcA2CVYIYrNERHunN5ObGfQ2yLhbnBUxzr1YZKL4OtV1aBgl60B5PAoRrdaluTXkpcA2CVYIYFsqrawKW8ywaNn3uf4XSA1obq9R8S8papnw34iR8RlLNhjXrdaluTXkpcA2CVYIYjfRgQQeQHunN5ObGfQ2yLhbnBUxzr5OtV1qQMZC0aWcvBSYJGMn3RSO68paNJo9wyrcZJzbC2CtvGhZQv7ea1VYZyI1QfMhZQTbWnELlPuyEuG0UyP1bWIeMhZc4S5MQapMvR2jaQFLNXMBQc8ywJRasp5SgjdvzzgxbKUxxyjntaESivwMXrwzQMZC2CtvGhZYrNERHs(6s55rsC0aWcvBSYJGMn3RSOCsXQHQkHQmvZzoAayHQnw5rqZM7vwuEvTydLimpMLFjNMNhRoBdKDUbH5XS8l5088y1zBGSZ1pDLybiwPI4g5PtcZJz5a28SoovkXQESinimpMLdyZZ64uPeR6K(PRelaXkIBKNojmpMLNJNsI1YPsjw1JfPbH5XS8C8usSwovkXQoPF6kXcqSI4g5PtcZJz5Qi8tYkaNtLsSQhlsdcZJz5Qi8tYkaNtLsSQt6NUsSaeRiUrwmSiH5XSaoBUPkWJz1QDcG6x5zQJhZACKvMQ5mNn3uf4XSCRaCnvQA8eIvkmpMLZMBQc8ywUvaUUciuyrcZJzbC2CtvGhZQv7ea1VYZs2zq156JGXrwzQMZC2CtvGhZYTcW1uPQXtiwPW8ywoBUPkWJz5wb46kGqHfjmpMfWzZnvbEmRwTtau)kplrpGEfIfPXrwzQMZC2CtvGhZYTcW1uPQXtiwPW8ywoBUPkWJz5wb46kGqHfjmpMfWzZnvbEmRwTtau)kplhpLSZGACKvMQ5mNn3uf4XSCRaCnvQA8eIvkmpMLZMBQc8ywUvaUUciuyrcZJzbC2CtvGhZQv7ea1VYZKLra)fRMjwRXrwzQMZC2CtvGhZYTcW1uPQXtiwPW8ywoBUPkWJz5wb46kGqHfjmpMfWzZnvbEmRwTtau)kpRciD40fyCKvMQ5mNn3uf4XSCRaCnvQA8eIvkmpMLZMBQc8ywUvaUUciuyrcZJzbC2CtvGhZQv7ea1VYZYw5sa)dfiJJSYunN5DJRb(tIc8NeMBqyEuG00s3GaNRSG8HKSeNn3uf4XS6SvUeW)qbcwKW8ywaNn3uf4XSA1obq9R8mve(jzfGBCKvMQ5mhuxTcXIeOtwcaIfP(jbfbEv1qQMZCqD1kelsGozjaiwK6Neue4pDLybNZeGR94sWIeMhZc4S5MQapMvR2jaQFLNPIWpjRaCJJSYunN554jGp)L)KWCyrcZJzbC2CtvGhZQv7ea1VYZur4NKvaUXrwzQMZCve(HzfWL)KWCdPAoZvr4hMvax(txjwW5mb4ApUKHss1CMZMBQc8yw(txjwW5mb4ApU0PtPAoZzZnvbEmlhD6TfdlsyEmlGZMBQc8ywTANaO(vEMkc)KScWnoYkt1CM3nUg4pjkWFsyUHunN5S5MQapMLxvHfjmpMfWzZnvbEmRwTtau)kptfHFswb4ghzLQpvqJKHYlJdyZZ6mKQ5mVJepwK6Qk)jH5WIeMhZc4S5MQapMvR2jaQFLNP2n0gLQZw5saJJSYunN5S5MQapMLxvHfjmpMfWzZnvbEmRwTtau)kplhpLeR14iRmvZzoBUPkWJz5OtV1aBgl60B5S5MQapML)0vIfGyMaCThxYWXSzrRHZZw5sAHXEYJz50kjlHclsyEmlGZMBQc8ywTANaO(vEgGnpRZ4iRmvZzoBUPkWJz5pDLybNZeGR94sgs1CMZMBQc8ywEv90PunN5S5MQapMLJo9wdSzSOtVLZMBQc8yw(txjwaIzcW1ECjyrcZJzbC2CtvGhZQv7ea1VYZSrHyrQtZnzCKvMQ5mNn3uf4XS8NUsSaeJKHYVsPgeMhfinT0niW5LblsyEmlGZMBQc8ywTANaO(vEg6liNfOtpjENXrwzQMZC2CtvGhZYF6kXcqmsgk)kLAivZzoBUPkWJz5vvyrcZJzbC2CtvGhZQv7ea1VYZaS5zDghzLU8ijN3rI174QmhXk7RIm4ILwNdi5JfP2NkRJtRKSekSiyrcZJzb8Fu1QDcGuMTYLa(hkqghzLLimpkqAAPBqGZvwq(qswI3nUg4pjkOZw5sa)dfidL4XLmIunN5S5MQapMLBfGRPsvJNoVG8HKSehLScc6SvUeW)qbQ4InKQ5mVBCnWFsuG)KWCyrcZJzb8Fu1QDcG6x5zQi8tYka34iRmvZzoOUAfIfjqNSeaels9tckc8QQHunN5G6QviwKaDYsaqSi1pjOiWF6kXcoNjax7XLGfjmpMfW)rvR2jaQFLNPIWpjRaCJJSYunN554jGp)L)KWCyrcZJzb8Fu1QDcG6x5zQi8tYka34iRmvZzE34AG)KOa)jH5WIeMhZc4)OQv7ea1VYZYXt6KvaUXvaPNCwJKHQSmJRas3RlSKMjapwKklZ4iRmvZzoOUAfIfjqNSeaels9tckcC0P3A44seMhfinT0niW5kliFijlX7KhvZeGRZw5sa)dfidL4XLmIunN5S5MQapMLBfGRPsvJNoVG8HKSehLScc6SvUeW)qbQ4InCCoEc4Y70ZfMhfidLCCQMZ8os8yrQRQ8NeMB44unN5DJRb(tIc8NeMB4y1NkONCwJKHYZXt6KvaUHseMhZYZXt6KvaoN1jpscCUYJC6ujUyP15ILkf4VamAbOZ1hboTsYsOgyZyrNElh9fKZc0PNeVJ)KGIqXNovIlwADoGKpwKAFQSooTsYsOgC5rsoVJeR3XvzoIv2xfvCXfdlsyEmlG)JQwTtau)kplhpPtwb4gxbKEYznsgQYYmUciDVUWsAMa8yrQSmJJSYJZXtaxENEUW8OazOKskryEmlphpLeRLtLsSQhlYtNeMhZYvr4NKvaoNkLyvpwKfBivZzEhjESi1vv(tcZl(0PsCXsRZbK8XIu7tL1XPvswc1GlpsY5DKy9oUkZrSY(QidLKQ5mVJepwK6Qk)jH5gowyEmlhWMN1XPsjw1Jf5PthNQ5mVBCnWFsuG)KWCdhNQ5mVJepwK6Qk)jH5geMhZYbS5zDCQuIv9yrA44UX1a)jrbnqLSwGowD2gi78IlUyyrcZJzb8Fu1QDcG6x5zmXA1cZJz12a4gVYLukmpkqAxS06ayrcZJzb8Fu1QDcG6x5zQi8tYka34iRmvZzUkc)WSc4YFsyUbMaCThxcXPAoZvr4hMvax(txjwGbMaCThxcXPAoZ)6s6jRvNE0ZF6kXcmusQMZCve(HzfWL)KWCLPAoZvr4hMvax(vkvdCHPWPtPAoZvr4hMvax(txjwaIzcW1ECP(fMhZYZXtjXA5uPeR6K2JlD6uQMZCXsLc8xagTa056JaVQE60XFDP88ijoOUAfIfjqNSeaelsoPy1qvLqlgwKW8ywa)hvTANaO(vEMkc)KScWnoYkvFQGgjdLxghWMN1zivZzEhjESi1vv(tcZn4ILwNdi5JfP2NkRJtRKSeQbxEKKZ7iX6DCvMJyL9vrgoUeH5rbstlDdcCUYcYhsYs8UX1a)jrbD2kxc4FOazOepUKrKQ5mNn3uf4XSCRaCnvQA805fKpKKL4OKvqqNTYLa(hkqfxmSiH5XSa(pQA1obq9R8m1UH2OuD2kxcyCKvECb5djzjUA3qBuQwDgBSinKQ5mVJepwK6Qk)jH5goovZzE34AG)KOa)jH5gkryEuG0OJZdKB4eIpYPtcZJcKMw6ge4CLfKpKKL4DYJQzcW1zRCjG)Hc0PtcZJcKMw6ge4CLfKpKKL4DJRb(tIc6SvUeW)qbQyyrcZJzb8Fu1QDcG6x5za28SoJJSsxEKKZ7iX6DCvMJyL9vrgCXsRZbK8XIu7tL1XPvswcfwKW8ywa)hvTANaO(vEg6liNfOtpjENXrwPW8OaPPLUbbo)iWIeMhZc4)OQv7ea1VYZYw5sa)dfiJJSYseMhfinT0niW5kliFijlX7KhvZeGRZw5sa)dfidL4XLmIunN5S5MQapMLBfGRPsvJNoVG8HKSehLScc6SvUeW)qbQ4IHfjmpMfW)rvR2jaQFLNLJNsI1clcwKW8ywah4YIkpQ(hx8ywLzRCjG)HcKXrwzjcZJcKMw6ge4CLfKpKKL4DJRb(tIc6SvUeW)qbYqjECjJivZzoBUPkWJz5wb4AQu14PZliFijlXrjRGGoBLlb8puGkUydPAoZ7gxd8Nef4pjmhwKW8ywah4YIkpQ(hx8y2(vEMkc)KScWnoYkt1CMNJNa(8x(tcZHfjmpMfWbUSOYJQ)XfpMTFLNPIWpjRaCJJSYunN5DJRb(tIc8NeMBivZzE34AG)KOa)PRelaXcZJz554PKyTCQuIvDs7XLGfjmpMfWbUSOYJQ)XfpMTFLNPIWpjRaCJJSYunN5DJRb(tIc8NeMBOe1NkOrYq5LXZXtjXApDkhpbC5D65cZJc0PtcZJz5Qi8tYkaNhRoBdKDEXWIoAi(Ghbi2higj5qSPrPdHy1FyaiowqGsqSIttFieR2jacaXZdXiQ5MQapMfIv7eabG4ED0cXQdaejlXHfjmpMfWbUSOYJQ)XfpMTFLNPIWpjRaCJJSYunN5G6QviwKaDYsaqSi1pjOiWRQgkHnJfD6T8VUKEYA1Ph98NUsSG(fMhZY)6s6jRvNE0ZPsjw1jThxQFMaCThx68unN5G6QviwKaDYsaqSi1pjOiWF6kXcoD6yxS068VUKEYA1Ph9CALKLql2qb5djzjUhxs7JMn3uf4XS9ZeGR94sNNQ5mhuxTcXIeOtwcaIfP(jbfb(txjwaSiH5XSaoWLfvEu9pU4XS9R8mve(jzfGBCKvMQ5mVBCnWFsuG)KWCdU8ijN3rI174QmhXk7RIm4ILwNdi5JfP2NkRJtRKSekSiH5XSaoWLfvEu9pU4XS9R8mve(jzfGBCKvMQ5mxfHFywbC5pjm3ataU2JlH4unN5Qi8dZkGl)PRelWqjPAoZvr4hMvax(tcZvMQ5mxfHFywbC5xPunWfMcNoLQ5mxfHFywbC5pDLybiMjax7XL6xyEmlphpLeRLtLsSQtApU0PtPAoZflvkWFby0cqNRpc8Q6Pth)1LYZJK4G6QviwKaDYsaqSi5KIvdvvcTyyrcZJzbCGllQ8O6FCXJz7x5z54jDYka34kG0toRrYqvwMXvaP71fwsZeGhlsLLzCKvECoEc4Y70ZfMhfidhxq(qswINJN0jRaCT6m2yrAOKskryEmlphpLeRLtLsSQhlYtNeMhZYvr4NKvaoNkLyvpwKfBivZzEhjESi1vv(tcZl(0PsCXsRZbK8XIu7tL1XPvswc1GlpsY5DKy9oUkZrSY(QidLKQ5mVJepwK6Qk)jH5gowyEmlhWMN1XPsjw1Jf5PthNQ5mVBCnWFsuG)KWCdhNQ5mVJepwK6Qk)jH5geMhZYbS5zDCQuIv9yrA44UX1a)jrbnqLSwGowD2gi78IlUyyrcZJzbCGllQ8O6FCXJz7x5zQi8tYka34iRu9PcAKmuEzCaBEwNHunN5DK4XIuxv5pjm3GlwADoGKpwKAFQSooTsYsOgC5rsoVJeR3XvzoIv2xfz44seMhfinT0niW5kliFijlX7gxd8Nef0zRCjG)HcKHs84sgrQMZC2CtvGhZYTcW1uPQXtNxq(qswIJswbbD2kxc4FOavCXWIeMhZc4axwu5r1)4IhZ2VYZu7gAJs1zRCjGXrw5XfKpKKL4QDdTrPA1zSXI0qjh7ILwNN)5Q9oslGocWPvswc90jH5rbstlDdcCEzfBOeH5rbstlDdcCEzgeMhfin648a5goH4JC6KW8OaPPLUbboxzb5djzjEN8OAMaCD2kxc4FOaD6KW8OaPPLUbboxzb5djzjE34AG)KOGoBLlb8puGkgwKW8ywah4YIkpQ(hx8y2(vEgtSwTW8ywTnaUXRCjLcZJcK2flToawKW8ywah4YIkpQ(hx8y2(vEg6liNfOtpjENXrwPW8OaPPLUbboVmyrcZJzbCGllQ8O6FCXJz7x5za28SoJJSsxEKKZ7iX6DCvMJyL9vrgCXsRZbK8XIu7tL1XPvswcfw0rdX9rH3bX0ovKDqSlpsYbgdXHdXbaIfigPele7deZeGdXiARCjG)Hceelaiohwl9qCSaNeuiEYqmIoEkjwlhwKW8ywah4YIkpQ(hx8y2(vEw2kxc4FOazCKvkmpkqAAPBqGZvwq(qswI3jpQMjaxNTYLa(hkqgkXJlzePAoZzZnvbEml3kaxtLQgpDEb5djzjokzfe0zRCjG)HcuXWIeMhZc4axwu5r1)4IhZ2VYZYXtjXAHfjmpMfWbUSOYJQ)XfpMTFLNbyZZ6AEZBna]] )

end
