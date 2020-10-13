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
            readyTime = function () if debuff.casting.up then return state.timeToInterrupt end end,

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


    spec:RegisterPack( "Fire", 20201012, [[d8KnLcqivipsffDjvuO2ef8jke1Oev5uIsTkrvPxjvvZIc1TOqyxO6xQqnmsihtuXYevvptfLMgeICnkKSnrvrFJcrmorvbNdcbwhecnpiu3JeTpvuDqvuiluf0dHqYePqK6IQOGSriK6JKqvAKqiQtscvyLIsEjfIKzscv6MKqvTtPQ8tsOkgQOQqlLeQipLIMQkWvHqqFvffySQOGAVs5VKAWqDyIflYJrzYq6YiBwIpdrJwQCAHvtcvuVMemBkDBvA3k9BfdNKoojuwUQEoW0P66sA7IIVlvz8IkDEiy9ui18vr2pOB50oOzIko16l)kk)kkhfLt(55pNZMppBZ0rqLAMQctbbj1mx5snteD8uZuvqWocA7GMjyQpJAMDURcqep(yKH3vtC2Cpge3Qv8yw2lf)yqCzh3mt1W6ko2wQzIko16l)kk)kkhfLt(55pNZMpZVrsZuQE38ntZ4IOAMDbkkTTuZeLaSM5zcXi64jiwXxqsWSotiUZDvaI4XhJm8UAIZM7XG4wTIhZYEP4hdIl7yywNjeR4H5tIEioNCmgIZVIYVIGzbZ6mHyevNSijaIimRZeIncigriGG4sGSZ1pDLybq8lEh9qS3jle7YJKCUhxs7JgniiUmpeBfGBeaInlkelPWgocqCfiijaVzAdGdAh0mrPIuTE7GwF50oOzsRKSeA7WMj7dN(qAMhbXFDPY8ijoAayHQnw5rqZM7vwuoPy1qvLqBMcZJzBMSPUo9avYABERV83oOzsRKSeA7WM5O2mbK3mfMhZ2mZiFijl1mZi2k1mDXsRZlXtaxENEoTsYsOqC(cXL4jGlVtp)PRelaI7hIZdIzZyrNElNn3uf4XS8NUsSaioFH48G4CGyJaIZiFijlXviwuBSi1pHwzEmleNVqSlwADUcXIAJfjNwjzjuioBioBioFH4JGy2mw0P3YzZnvbEml)jbfbioFH4uTu4S5MQapMLJo92Mzg51RCPMPhxs7JMn3uf4XSnV13zBh0mPvswcTDyZK9HtFinZuTu4S5MQapMLJo9wi2aeNQLc)RlPNIwD6rphD6TqSbiMnJfD6TC2CtvGhZYF6kXcG4ZHyfbXgG48Gy2mw0P3Y)6s6POvNE0ZF6kXcG4ZHyfbXNobXhbXUyP15FDj9u0Qtp650kjlHcXz3mfMhZ2mbDrXJfPwD6rFZB9Hi1oOzsRKSeA7WMj7dN(qAM5bXPAPWzZnvbEmlhD6TqSbiovlf(xxspfT60JEo60BHydqCEqmBgl60B5S5MQapML)0vIfaXigIPCjw1jThxcIpDcIzZyrNElNn3uf4XS8NUsSai(CiMnJfD6T8xqdzDnqvEf4O1x8ywioBioBi(0jiopiovlf(xxspfT60JEEvfInaXSzSOtVLZMBQc8yw(txjwaeFoeFwfbXz3mfMhZ2mFbnK11av5vO5T(mQ2bntALKLqBh2mzF40hsZmvlfoBUPkWJz5OtVfInaXPAPW)6s6POvNE0ZrNEleBaIzZyrNElNn3uf4XS8NUsSaigXqmLlXQoP94sntH5XSntus8U08l18wF5Z2bntALKLqBh2mzF40hsZmvlfoBUPkWJz5OtVfInaXOuQwk8xqdzDnqvEf0zQ2LEjf2WrGJo92MPW8y2M5n(FEDCfKuZB9zK0oOzsRKSeA7WMPW8y2MPy0Go5fGUmRRNIwD6rFZK9HtFinZmYhsYsCpUK2hnBUPkWJzHyeReInkiUFiohJcIZxioJ8HKSeVmRRrNAYs6z1vabXgG4mYhsYsCpUK2hnBUPkWJzH4ZHyf1mx5sntXObDYlaDzwxpfT60J(M36lFODqZKwjzj02Hnt2ho9H0mZdIZiFijlX94sAF0S5MQapMfIrmeNJIG4tNG4sGSZ1pDLybqmIH4mYhsYsCpUK2hnBUPkWJzH4SBMcZJzBMiRYJgYQNIwmA6hVR5T(qe0oOzkmpMTzYMLrR)ItO6IvUuZKwjzj02HnV1xokQDqZuyEmBZ8jrnwK6IvUeOzsRKSeA7WM36lNCAh0mfMhZ2mldRciuTy00hoPtKCBM0kjlH2oS5T(Yj)TdAMcZJzBMQ1pkielsDYkaVzsRKSeA7WM36lNZ2oOzkmpMTz(HQQL0XQbQcJAM0kjlH2oS5T(YbrQDqZuyEmBZ07iDDttDr1L5zuZKwjzj02HnV1xogv7GMjTsYsOTdBMSpC6dPz(1LkZJK4ObGfQ2yLhbnBUxzr5KIvdvvcfInaXSzSOtVLNQLIgnaSq1gR8iOzZ9klk)jbfbi2aeNQLchnaSq1gR8iOzZ9klQwEMSehD6TqSbiMnJfD6TC2CtvGhZYF6kXcG4ZH4ZQii2aeFeeNQLchnaSq1gR8iOzZ9klkVQ2mfMhZ2mztDD6bQK128wF5KpBh0mPvswcTDyZK9HtFinZVUuzEKehnaSq1gR8iOzZ9klkNuSAOQsOqSbiMnJfD6T8uTu0ObGfQ2yLhbnBUxzr5pjOiaXgG4uTu4ObGfQ2yLhbnBUxzr1YZKL4OtVfInaXSzSOtVLZMBQc8yw(txjwaeFoeFwfbXgG4JG4uTu4ObGfQ2yLhbnBUxzr5v1MPW8y2MP8mzjnLRQDaXSnV1xogjTdAM0kjlH2oSzY(WPpKM5xxQmpsIJgawOAJvEe0S5ELfLtkwnuvjui2aeZMXIo9wEQwkA0aWcvBSYJGMn3RSO8NeueGydqCQwkC0aWcvBSYJGMn3RSO6YpaNJo9wi2aeZMXIo9woBUPkWJz5pDLybq85q8zveeBaIpcIt1sHJgawOAJvEe0S5ELfLxvBMcZJzBMLFaEASEZB9Lt(q7GMjTsYsOTdBMSpC6dPzMQLc)RlPNIwD6rphD6TqSbiopioJ8HKSe3JlP9rZMBQc8ywi(Ciovlf(xxspfT60JEoA9fpMfInaXzKpKKL4ECjTpA2CtvGhZcXNdXcZJz5L4jDYkaNxQwR(jwN8ijThxcIpDcIZiFijlX94sAF0S5MQapMfIphIlbYox)0vIfaXz3mfMhZ2m)6s6POvNE038wF5GiODqZKwjzj02Hnt2ho9H0mpcIZiFijlXrdGKSKMn3uf4XSqSbioJ8HKSe3JlP9rZMBQc8ywigXkHyf1mfMhZ2mzI1QfMhZQTbWBM2a46vUuZKn3uf4XSA1obqnV1x(vu7GMjTsYsOTdBMJAZeqEZuyEmBZmJ8HKSuZmJyRuZ8iioJ8HKSehnasYsA2CtvGhZcXgG4mYhsYsCpUK2hnBUPkWJzHyedXcZJz5L4jDYkaNxQwR(jwN8ijThxcIncioJ8HKSeh0ffpwKA1Ph96NqRmpMfIZxiopiMnJfD6TCqxu8yrQvNE0ZF6kXcGyedXzKpKKL4ECjTpA2CtvGhZcXzdXgG4mYhsYsCpUK2hnBUPkWJzHyedXLazNRF6kXcG4tNG4VUuzEKehuxTcXIeOtwcaIfjNuSAOQsOqSbiwyEmlVepPtwb4CwN8ijGU8cZJzfleJyiwyEmlVepPtwb48RKRM1jpscaXgbeRiUrbXgG48Gy2mw0P3YbDrXJfPwD6rp)PRelaIphIZXOG4tNG4JGy2KHwzD(gi7CDriio7Mzg51RCPMzjEsNScW1QZyJfzZB9L)CAh0mPvswcTDyZK9HtFinZuTu4FDj9u0Qtp65vvi2aeNheNr(qswI7XL0(OzZnvbEmleFoeRiio7MPW8y2MjtSwTW8ywTnaEZ0gaxVYLAM)OQv7ea18wF5p)TdAM0kjlH2oSzoQnta5ntH5XSnZmYhsYsnZmITsnZJG4mYhsYsC0aijlPzZnvbEmleBaIZiFijlX94sAF0S5MQapMfIrmelmpMLR2n0g5Qlw5saEPAT6NyDYJK0ECji2aeNr(qswI7XL0(OzZnvbEmleJyiUei7C9txjwaeF6ee)1LkZJK4G6QviwKaDYsaqSi5KIvdvvcTzMrE9kxQzQ2n0g5QvNXglYM36l)NTDqZKwjzj02HnZkG096clPzcWJfzRVCAMSpC6dPzEeeNr(qswIxIN0jRaCT6m2yrcXgG48G4mYhsYsCpUK2hnBUPkWJzH4ZHyfbXzdXgG48GyH5rgstlDdcaXNReIZiFijlX7KhvZeGRlw5sa)dfii2aeNhe7XLGyJaIt1sHZMBQc8ywUvaUMYvnEcIphIZiFijlXrjRGGUyLlb8puGG4SH4SHydq8rqCjEc4Y70ZfMhzii2aeFeeNQLcVBCnWFsuG)KW8Mzfq6Pu0izOT(YPzkmpMTzwIN0jRa8M36l)isTdAM0kjlH2oSzwbKUxxyjntaESiB9LtZK9HtFinZs8eWL3PNlmpYqqSbiM1jpscaXNReIZbInaXhbXzKpKKL4L4jDYkaxRoJnwKqSbiopi(iiwyEmlVepLeRLt5sSQhlsi2aeFeelmpMLRIWpjRaCES6Inq25qSbiovlfEhjESi1vv(tcZH4tNGyH5XS8s8usSwoLlXQESiHydq8rqCQwk8UX1a)jrb(tcZH4tNGyH5XSCve(jzfGZJvxSbYohInaXPAPW7iXJfPUQYFsyoeBaIpcIt1sH3nUg4pjkWFsyoeNDZSci9ukAKm0wF50mfMhZ2mlXt6KvaEZB9LFJQDqZKwjzj02Hnt2ho9H0mZdIZiFijlX94sAF0S5MQapMfIphIveeNneBaIt1sH)1L0trRo9ONJo92MPW8y2MjtSwTW8ywTnaEZ0gaxVYLAMaxwu5r1)4IhZ28M3m)rvR2jaQDqRVCAh0mPvswcTDyZK9HtFinZ8GyH5rgstlDdcaXNReIZiFijlX7gxd8Nef0fRCjG)HceeBaIZdI94sqSraXPAPWzZnvbEml3kaxt5QgpbXNdXzKpKKL4OKvqqxSYLa(hkqqC2qC2qSbiovlfE34AG)KOa)jH5ntH5XSnZIvUeW)qbQ5T(YF7GMjTsYsOTdBMSpC6dPzMQLchuxTcXIeOtwcaIfP(jbfbEvfInaXPAPWb1vRqSib6KLaGyrQFsqrG)0vIfaXNdXmb4ApUuZuyEmBZufHFswb4nV13zBh0mPvswcTDyZK9HtFinZuTu4L4jGp)L)KW8MPW8y2MPkc)KScWBERpeP2bntALKLqBh2mzF40hsZmvlfE34AG)KOa)jH5ntH5XSntve(jzfG38wFgv7GMjTsYsOTdBMvaP71fwsZeGhlYwF50mzF40hsZmvlfoOUAfIfjqNSeaels9tckcC0P3cXgG4JG48GyH5rgstlDdcaXNReIZiFijlX7KhvZeGRlw5sa)dfii2aeNhe7XLGyJaIt1sHZMBQc8ywUvaUMYvnEcIphIZiFijlXrjRGGUyLlb8puGG4SH4SHydq8rqCjEc4Y70ZfMhzii2aeNheFeeNQLcVJepwK6Qk)jH5qSbi(iiovlfE34AG)KOa)jH5qSbi(iiw9Pm6Pu0izO8s8KozfGdXgG48GyH5XS8s8KozfGZzDYJKaq85kH48dXNobX5bXUyP15ILYf4VamAbOl1hboTsYsOqSbiMnJfD6TC0xqolqNEs8o(tckcqC2q8PtqCEqSlwADoGKpwKAFQSooTsYsOqSbi2Lhj58osSEhxL5qmIvcXNvrqC2qC2qC2nZkG0tPOrYqB9LtZuyEmBZSepPtwb4nV1x(SDqZKwjzj02HnZkG096clPzcWJfzRVCAMSpC6dPzEeexINaU8o9CH5rgcInaX5bX5bX5bXcZJz5L4PKyTCkxIv9yrcXNobXcZJz5Qi8tYkaNt5sSQhlsioBi2aeNQLcVJepwK6Qk)jH5qC2q8PtqCEqSlwADoGKpwKAFQSooTsYsOqSbi2Lhj58osSEhxL5qmIvcXNvrqSbiopiovlfEhjESi1vv(tcZHydq8rqSW8ywoGnpRJt5sSQhlsi(0ji(iiovlfE34AG)KOa)jH5qSbi(iiovlfEhjESi1vv(tcZHydqSW8ywoGnpRJt5sSQhlsi2aeFee3nUg4pjkObQK1c0XQl2azNdXzdXzdXz3mRaspLIgjdT1xontH5XSnZs8KozfG38wFgjTdAM0kjlH2oSzkmpMTzYeRvlmpMvBdG3mTbW1RCPMPW8idPDXsRdAERV8H2bntALKLqBh2mzF40hsZmvlfUkc)WSc4YFsyoeBaIzcW1ECjigXqCQwkCve(HzfWL)0vIfaXgGyMaCThxcIrmeNQLc)RlPNIwD6rp)PRelaInaX5bXPAPWvr4hMvax(tcZHyLqCQwkCve(HzfWLFLC1axykaXNobXPAPWvr4hMvax(txjwaeJyiMjax7XLG4(HyH5XS8s8usSwoLlXQoP94sq8PtqCQwkCXs5c8xagTa0L6JaVQcXNobXhbXFDPY8ijoOUAfIfjqNSeaelsoPy1qvLqH4SBMcZJzBMQi8tYkaV5T(qe0oOzsRKSeA7WMj7dN(qAMQpLrJKHYZHdyZZ6GydqCQwk8os8yrQRQ8NeMdXgGyxS06CajFSi1(uzDCALKLqHydqSlpsY5DKy9oUkZHyeReIpRIGydq8rqCEqSW8idPPLUbbG4ZvcXzKpKKL4DJRb(tIc6IvUeW)qbcInaX5bXECji2iG4uTu4S5MQapMLBfGRPCvJNG4ZH4mYhsYsCuYkiOlw5sa)dfiioBio7MPW8y2MPkc)KScWBERVCuu7GMjTsYsOTdBMSpC6dPzEeeNr(qswIR2n0g5QvNXglsi2aeNQLcVJepwK6Qk)jH5qSbi(iiovlfE34AG)KOa)jH5qSbiopiwyEKH0OJZdKB4eeJyio)q8PtqSW8idPPLUbbG4ZvcXzKpKKL4DYJQzcW1fRCjG)HceeF6eelmpYqAAPBqai(CLqCg5djzjE34AG)KOGUyLlb8puGG4SBMcZJzBMQDdTrU6IvUeO5T(YjN2bntALKLqBh2mzF40hsZ0Lhj58osSEhxL5qmIvcXNvrqSbi2flTohqYhlsTpvwhNwjzj0MPW8y2MjGnpRR5T(Yj)TdAM0kjlH2oSzY(WPpKMPW8idPPLUbbG4ZH483mfMhZ2mrFb5SaD6jX7AERVCoB7GMjTsYsOTdBMSpC6dPzMhelmpYqAAPBqai(CLqCg5djzjEN8OAMaCDXkxc4FOabXgG48GypUeeBeqCQwkC2CtvGhZYTcW1uUQXtq85qCg5djzjokzfe0fRCjG)HceeNneNDZuyEmBZSyLlb8puGAERVCqKAh0mfMhZ2mlXtjXABM0kjlH2oS5nVzYMBQc8ywTANaO2bT(YPDqZKwjzj02Hnt2ho9H0mt1sHZMBQc8ywo60BBMcZJzBM2azNd0koxrrEP1BERV83oOzsRKSeA7WM5O2mbK3mfMhZ2mZiFijl1mZi2k1mt1sHZMBQc8yw(txjwae3peNQLcNn3uf4XSC06lEmleNVqCEqmBgl60B5S5MQapML)0vIfaXigIt1sHZMBQc8yw(txjwaeNDZmJ86vUuZKY1PfLq1S5MQapMv)0vIf08wFNTDqZKwjzj02HnZrTzkOOntH5XSnZmYhsYsnZmITsnZ8zZK9HtFinZuTu4G6QviwKaDYsaqSi1pjOiWRQq8PtqCg5djzjoLRtlkHQzZnvbEmR(PRelaIphIZHBuqC(cXizO8RKleNVqCEqCQwkCqD1kelsGozjaiwK8RKRg4ctbi2iG4uTu4G6QviwKaDYsaqSi5axykaXz3mZiVELl1mPCDArjunBUPkWJz1pDLybnV1hIu7GMjTsYsOTdBMSpC6dPzMQLcNn3uf4XSC0P32mfMhZ2mtcs9u0(hmfanV1Nr1oOzsRKSeA7WMj7dN(qAMcZJmKMw6geaIphIZbInaXPAPWzZnvbEmlhD6TntH5XSntBKjwK60CtnV1x(SDqZKwjzj02Hnt2ho9H0mt1sHZMBQc8ywo60BHydqCQwk8VUKEkA1Ph9C0P32mfMhZ2mVX)Zd0tr7ZFP1BERpJK2bntALKLqBh2mfMhZ2m7qqLEV7jbv37dG37fvqZK9HtFinZuTu4S5MQapMLxvHydqSW8ywEjEsNScW5So5rsaiwjeRii2aelmpMLxIN0jRaC(tSo5rsApUeeFoeJKHYVsUnZvUuZSdbv69UNeuDVpaEVxubnV1x(q7GMPW8y2MzYodQEkAVJ00sxeAM0kjlH2oS5T(qe0oOzkmpMTzEP78iONI2wzbQg9j5cAM0kjlH2oS5T(YrrTdAMcZJzBM9M3IMHIv)eywzzuZKwjzj02HnV1xo50oOzsRKSeA7WMzfq6EDHL0mb4XIS1xont2ho9H0mfJM(WjEYkaNE9vao9CALKLqHydqmRtEKeaIpxjeNdeBaIZdIZdIfMhZYlXt6KvaoN1jpscOlVW8ywXcX9dX5bXPAPWzZnvbEml)PRelaInciovlfEYkaNE9vao9C06lEmleNneFmeZMXIo9wEjEsNScW5O1x8ywi2iG48G4uTu4S5MQapML)0vIfaXzdXhdX5bXPAPWtwb40RVcWPNJwFXJzHyJaIve3OG4SH4SH4ZvcXkcIpDcIpcIfJM(WjEYkaNE9vao9CALKLqH4tNG4JGyxS068IvUKEwoTsYsOq8PtqCQwkC2CtvGhZYF6kXcGyeReIt1sHNScWPxFfGtphT(IhZcXNobXPAPWtwb40RVcWPN)0vIfaXigIve3OG4tNGysXQHQkHY7qqLEV7jbv37dG37fvaeBaIzZyrNElVdbv69UNeuDVpaEVxub6ZQifLdIu(5pDLybqmIHyJcIZgInaXPAPWzZnvbEmlVQcXgG48G4JGyH5XSCaBEwhNYLyvpwKqSbi(iiwyEmlxfHFswb48y1fBGSZHydqCQwk8os8yrQRQ8QkeF6eelmpMLdyZZ64uUeR6XIeInaXPAPW7gxd8Nef4OtVfInaX5bXPAPW7iXJfPUQYrNEleF6eelgn9Ht8Kvao96RaC650kjlHcXzdXNobXIrtF4epzfGtV(kaNEoTsYsOqSbi2flToVyLlPNLtRKSekeBaIfMhZYvr4NKvaopwDXgi7Ci2aeNQLcVJepwK6QkhD6TqSbiovlfE34AG)KOahD6TqC2nZkG0tPOrYqB9LtZuyEmBZSepPtwb4nV1xo5VDqZKwjzj02HnZkG096clPzcWJfzRVCAMSpC6dPzEeelgn9Ht8Kvao96RaC650kjlHcXgG48GyH5rgstlDdcaXiwjelmpYqA0X5bYnCcIpDcIpcIzZyrNElxTBOnYvxSYLa8NeueG4SHydqmBw0A48yl0VIvZeatqjoTsYsOqSbiM1jpscaXNReIZbInaX5bX5bXcZJz5L4jDYkaNZ6Khjb0LxyEmRyH4(H48G4mYhsYsCkxNwucvZMBQc8yw9txjwaeBeqCQwk8yl0VIvZeatqjoA9fpMfIZgIpgIzZyrNElVepPtwb4C06lEmleBeqCg5djzjoLRtlkHQzZnvbEmR(PRelaIpgIZdIt1sHhBH(vSAMayckXrRV4XSqSraXkIBuqC2qC2q85kHyfbXNobXzKpKKL4uUoTOeQMn3uf4XS6NUsSaigXkH4uTu4XwOFfRMjaMGsC06lEmleF6eeNQLcp2c9Ry1mbWeuI)0vIfaXigIve3OG4SHydqCQwkC2CtvGhZYRQqSbi(iiovlfEjEc4ZF5pjmhInaXhbXPAPW7gxd8Nef4pjmhInaXDJRb(tIcAGkzTaDS6Inq25qC)qCQwk8os8yrQRQ8NeMdXigIZFZSci9ukAKm0wF50mfMhZ2mlXt6KvaEZB9LZzBh0mPvswcTDyZSciDVUWsAMa8yr26lNMj7dN(qAMhbXIrtF4epzfGtV(kaNEoTsYsOqSbiopiwyEKH00s3GaqmIvcXcZJmKgDCEGCdNG4tNG4JGy2mw0P3Yv7gAJC1fRCja)jbfbioBi2aeFeeZMfTgop2c9Ry1mbWeuItRKSekeBaIzDYJKaq85kH4CGydqCQwkC2CtvGhZYRQqSbi(iiovlfEjEc4ZF5pjmhInaXhbXPAPW7gxd8Nef4pjmhInaXDJRb(tIcAGkzTaDS6Inq25qC)qCQwk8os8yrQRQ8NeMdXigIZFZSci9ukAKm0wF50mfMhZ2mlXt6KvaEZB9LdIu7GMjTsYsOTdBMSpC6dPz(1LkZJK4ObGfQ2yLhbnBUxzr5KIvdvvcfInaXPAPWrdaluTXkpcA2CVYIYrNEleBaIt1sHJgawOAJvEe0S5ELfvlptwIJo9wi2aeZMXIo9wEQwkA0aWcvBSYJGMn3RSO8NeueAMcZJzBMSPUo9avYABERVCmQ2bntALKLqBh2mzF40hsZ8RlvMhjXrdaluTXkpcA2CVYIYjfRgQQekeBaIt1sHJgawOAJvEe0S5ELfLJo9wi2aeNQLchnaSq1gR8iOzZ9klQwEMSehD6TqSbiMnJfD6T8uTu0ObGfQ2yLhbnBUxzr5pjOi0mfMhZ2mLNjlPPCvTdiMT5T(YjF2oOzsRKSeA7WMj7dN(qAMFDPY8ijoAayHQnw5rqZM7vwuoPy1qvLqHydqCQwkC0aWcvBSYJGMn3RSOC0P3cXgG4uTu4ObGfQ2yLhbnBUxzr1LFaohD6TntH5XSnZYpapnwV5T(YXiPDqZKwjzj02HntH5XSntMyTAH5XSABa8MPnaUELl1mfMhziTlwADqZB9Lt(q7GMjTsYsOTdBMvaP71fwsZeGhlYwF50mzF40hsZmvlfoBUPkWJz5OtVfInaX5bXFDPY8ijoAayHQnw5rqZM7vwuoPy1qvLqHyLqCQwkC0aWcvBSYJGMn3RSO8QkeNneBaIZdIfMhZYVKtZZJvxSbYohInaXcZJz5xYP55XQl2azNRF6kXcGyeReIve3OG4tNGyH5XSCaBEwhNYLyvpwKqSbiwyEmlhWMN1XPCjw1j9txjwaeJyiwrCJcIpDcIfMhZYlXtjXA5uUeR6XIeInaXcZJz5L4PKyTCkxIvDs)0vIfaXigIve3OG4tNGyH5XSCve(jzfGZPCjw1JfjeBaIfMhZYvr4NKvaoNYLyvN0pDLybqmIHyfXnkio7Mzfq6Pu0izOT(YPzkmpMTzYMBQc8y2M36lhebTdAM0kjlH2oSzY(WPpKMzQwkC2CtvGhZYTcW1uUQXtqmIvcXcZJz5S5MQapMLBfGRRacTzkmpMTzQoEmBZB9LFf1oOzsRKSeA7WMj7dN(qAMPAPWzZnvbEml3kaxt5QgpbXiwjelmpMLZMBQc8ywUvaUUci0MPW8y2MzYodQUuFeAERV8Nt7GMjTsYsOTdBMSpC6dPzMQLcNn3uf4XSCRaCnLRA8eeJyLqSW8ywoBUPkWJz5wb46kGqBMcZJzBMj6b0RqSiBERV8N)2bntALKLqBh2mzF40hsZmvlfoBUPkWJz5wb4Akx14jigXkHyH5XSC2CtvGhZYTcW1vaH2mfMhZ2mlXtj7mOnV1x(pB7GMjTsYsOTdBMSpC6dPzMQLcNn3uf4XSCRaCnLRA8eeJyLqSW8ywoBUPkWJz5wb46kGqBMcZJzBMYYiG)IvZeRT5T(YpIu7GMjTsYsOTdBMSpC6dPzMQLcNn3uf4XSCRaCnLRA8eeJyLqSW8ywoBUPkWJz5wb46kGqBMcZJzBMvaPdNUGM36l)gv7GMjTsYsOTdBMSpC6dPzMQLcVBCnWFsuG)KWCi2aelmpYqAAPBqai(CLqCg5djzjoBUPkWJz1fRCjG)HcuZuyEmBZSyLlb8puGAERV8NpBh0mPvswcTDyZK9HtFinZuTu4G6QviwKaDYsaqSi1pjOiWRQqSbiovlfoOUAfIfjqNSeaels9tckc8NUsSai(CiMjax7XLAMcZJzBMQi8tYkaV5T(YVrs7GMjTsYsOTdBMSpC6dPzMQLcVepb85V8NeM3mfMhZ2mvr4NKvaEZB9L)8H2bntALKLqBh2mzF40hsZmvlfUkc)WSc4YFsyoeBaIt1sHRIWpmRaU8NUsSai(CiMjax7XLGydqCEqCQwkC2CtvGhZYF6kXcG4ZHyMaCThxcIpDcIt1sHZMBQc8ywo60BH4SBMcZJzBMQi8tYkaV5T(YpIG2bntALKLqBh2mzF40hsZmvlfE34AG)KOa)jH5qSbiovlfoBUPkWJz5v1MPW8y2MPkc)KScWBERVZQO2bntALKLqBh2mzF40hsZu9PmAKmuEoCaBEwheBaIt1sH3rIhlsDvL)KW8MPW8y2MPkc)KScWBERVZMt7GMjTsYsOTdBMSpC6dPzMQLcNn3uf4XS8QAZuyEmBZuTBOnYvxSYLanV13zZF7GMjTsYsOTdBMSpC6dPzMQLcNn3uf4XSC0P3cXgGy2mw0P3YzZnvbEml)PRelaIrmeZeGR94sqSbi(iiMnlAnCEXkxslm2tEmlNwjzj0MPW8y2MzjEkjwBZB9D2Z2oOzsRKSeA7WMj7dN(qAMPAPWzZnvbEml)PRelaIphIzcW1ECji2aeNQLcNn3uf4XS8QkeF6eeNQLcNn3uf4XSC0P3cXgGy2mw0P3YzZnvbEml)PRelaIrmeZeGR94sntH5XSntaBEwxZB9DweP2bntALKLqBh2mzF40hsZmvlfoBUPkWJz5pDLybqmIHyKmu(vYfInaXcZJmKMw6geaIphIZPzkmpMTzAJmXIuNMBQ5T(oRr1oOzsRKSeA7WMj7dN(qAMPAPWzZnvbEml)PRelaIrmeJKHYVsUqSbiovlfoBUPkWJz5v1MPW8y2Mj6liNfOtpjExZB9D28z7GMjTsYsOTdBMSpC6dPz6YJKCEhjwVJRYCigXkH4ZQii2ae7ILwNdi5JfP2NkRJtRKSeAZuyEmBZeWMN118M3mfMhziTlwADq7GwF50oOzsRKSeA7WMj7dN(qAMcZJmKMw6geaIphIZbInaXPAPWzZnvbEmlhD6TqSbiopioJ8HKSe3JlP9rZMBQc8ywi(CiMnJfD6TCBKjwK60CtC06lEmleF6eeNr(qswI7XL0(OzZnvbEmleJyLqSIG4SBMcZJzBM2itSi1P5MAERV83oOzsRKSeA7WMj7dN(qAMhbXzKpKKL4ObqswsZMBQc8ywi2aeNr(qswI7XL0(OzZnvbEmleJyLqSIG4tNG48Gy2mw0P3YVKtZZrRV4XSqmIH4mYhsYsCpUK2hnBUPkWJzHydq8rqSlwAD(xxspfT60JEoTsYsOqC2q8PtqSlwAD(xxspfT60JEoTsYsOqSbiovlf(xxspfT60JEEvfInaXzKpKKL4ECjTpA2CtvGhZcXNdXcZJz5xYP55SzSOtVfIpDcIlbYox)0vIfaXigIZiFijlX94sAF0S5MQapMTzkmpMTzEjNMV5T(oB7GMjTsYsOTdBMSpC6dPz6ILwNlwkxG)cWOfGUuFe40kjlHcXgG48G4uTu4S5MQapMLJo9wi2aeFeeNQLcVBCnWFsuG)KWCio7MPW8y2Mj6liNfOtpjExZBEZe4YIkpQ(hx8y22bT(YPDqZKwjzj02Hnt2ho9H0mZdIfMhzinT0niaeFUsioJ8HKSeVBCnWFsuqxSYLa(hkqqSbiopi2JlbXgbeNQLcNn3uf4XSCRaCnLRA8eeFoeNr(qswIJswbbDXkxc4FOabXzdXzdXgG4uTu4DJRb(tIc8NeM3mfMhZ2mlw5sa)dfOM36l)TdAM0kjlH2oSzY(WPpKMzQwk8s8eWN)YFsyEZuyEmBZufHFswb4nV13zBh0mPvswcTDyZK9HtFinZuTu4DJRb(tIc8NeMdXgG4uTu4DJRb(tIc8NUsSaigXqSW8ywEjEkjwlNYLyvN0ECPMPW8y2MPkc)KScWBERpeP2bntALKLqBh2mzF40hsZmvlfE34AG)KOa)jH5qSbiopiw9PmAKmuEo8s8usSwi(0jiUepbC5D65cZJmeeF6eelmpMLRIWpjRaCES6Inq25qC2ntH5XSntve(jzfG38wFgv7GMjTsYsOTdBMSpC6dPzMQLchuxTcXIeOtwcaIfP(jbfbEvfInaX5bXSzSOtVL)1L0trRo9ON)0vIfaX9dXcZJz5FDj9u0Qtp65uUeR6K2JlbX9dXmb4ApUeeFoeNQLchuxTcXIeOtwcaIfP(jbfb(txjwaeF6eeFee7ILwN)1L0trRo9ONtRKSekeNneBaIZiFijlX94sAF0S5MQapMfI7hIzcW1ECji(CiovlfoOUAfIfjqNSeaels9tckc8NUsSGMPW8y2MPkc)KScWBERV8z7GMjTsYsOTdBMSpC6dPzMQLcVBCnWFsuG)KWCi2ae7YJKCEhjwVJRYCigXkH4ZQii2ae7ILwNdi5JfP2NkRJtRKSeAZuyEmBZufHFswb4nV1Nrs7GMjTsYsOTdBMSpC6dPzMQLcxfHFywbC5pjmhInaXmb4ApUeeJyiovlfUkc)WSc4YF6kXcGydqCEqCQwkCve(HzfWL)KWCiwjeNQLcxfHFywbC5xjxnWfMcq8PtqCQwkCve(HzfWL)0vIfaXigIzcW1ECjiUFiwyEmlVepLeRLt5sSQtApUeeF6eeNQLcxSuUa)fGrlaDP(iWRQq8Ptq8rq8xxQmpsIdQRwHyrc0jlbaXIKtkwnuvjuio7MPW8y2MPkc)KScWBERV8H2bntALKLqBh2mRas3RlSKMjapwKT(YPzY(WPpKM5rqCjEc4Y70ZfMhzii2aeFeeNr(qswIxIN0jRaCT6m2yrcXgG48G48G48GyH5XS8s8usSwoLlXQESiH4tNGyH5XSCve(jzfGZPCjw1JfjeNneBaIt1sH3rIhlsDvL)KWCioBi(0jiopi2flTohqYhlsTpvwhNwjzjui2ae7YJKCEhjwVJRYCigXkH4ZQii2aeNheNQLcVJepwK6Qk)jH5qSbi(iiwyEmlhWMN1XPCjw1JfjeF6eeFeeNQLcVBCnWFsuG)KWCi2aeFeeNQLcVJepwK6Qk)jH5qSbiwyEmlhWMN1XPCjw1JfjeBaIpcI7gxd8Nef0avYAb6y1fBGSZH4SH4SH4SBMvaPNsrJKH26lNMPW8y2MzjEsNScWBERpebTdAM0kjlH2oSzY(WPpKMP6tz0izO8C4a28Soi2aeNQLcVJepwK6Qk)jH5qSbi2flTohqYhlsTpvwhNwjzjui2ae7YJKCEhjwVJRYCigXkH4ZQii2aeFeeNhelmpYqAAPBqai(CLqCg5djzjE34AG)KOGUyLlb8puGGydqCEqShxcInciovlfoBUPkWJz5wb4Akx14ji(CioJ8HKSehLScc6IvUeW)qbcIZgIZUzkmpMTzQIWpjRa8M36lhf1oOzsRKSeA7WMj7dN(qAMhbXzKpKKL4QDdTrUA1zSXIeInaX5bXhbXUyP15LFUAVJ0cOJaCALKLqH4tNGyH5rgstlDdcaXNdX5aXzdXgG48GyH5rgstlDdcaXNdX5aXgGyH5rgsJoopqUHtqmIH48dXNobXcZJmKMw6geaIpxjeNr(qswI3jpQMjaxxSYLa(hkqq8PtqSW8idPPLUbbG4ZvcXzKpKKL4DJRb(tIc6IvUeW)qbcIZUzkmpMTzQ2n0g5Qlw5sGM36lNCAh0mPvswcTDyZuyEmBZKjwRwyEmR2gaVzAdGRx5sntH5rgs7ILwh08wF5K)2bntALKLqBh2mzF40hsZuyEKH00s3Gaq85qContH5XSnt0xqolqNEs8UM36lNZ2oOzsRKSeA7WMj7dN(qAMU8ijN3rI174QmhIrSsi(SkcInaXUyP15as(yrQ9PY640kjlH2mfMhZ2mbS5zDnV1xoisTdAM0kjlH2oSzY(WPpKMPW8idPPLUbbG4ZvcXzKpKKL4DYJQzcW1fRCjG)HceeBaIZdI94sqSraXPAPWzZnvbEml3kaxt5QgpbXNdXzKpKKL4OKvqqxSYLa(hkqqC2ntH5XSnZIvUeW)qbQ5T(YXOAh0mfMhZ2mlXtjXABM0kjlH2oS5T(YjF2oOzkmpMTzcyZZ6AM0kjlH2oS5nVzQ(eBUjXBh06lN2bntH5XSnt5zYs6yDYAjM3mPvswcTDyZB9L)2bntALKLqBh2mh1MjG8MPW8y2Mzg5djzPMzgXwPMz(H48fIDXsRZlw5sAvXzDCALKLqH4(H4ZcX5leFee7ILwNxSYL0QIZ640kjlH2mzF40hsZmJ8HKSeVBCnWFsuqxSYLa(hkqqSsiwrnZmYRx5snZUX1a)jrbDXkxc4FOa18wFNTDqZKwjzj02HnZrTzciVzkmpMTzMr(qswQzMrSvQzMFioFHyxS068IvUKwvCwhNwjzjuiUFi(SqC(cXhbXUyP15fRCjTQ4SooTsYsOnt2ho9H0mZiFijlX7KhvZeGRlw5sa)dfiiwjeROMzg51RCPMzN8OAMaCDXkxc4FOa18wFisTdAM0kjlH2oSzoQnta5ntH5XSnZmYhsYsnZmITsnZZcX5le7ILwNxSYL0QIZ640kjlHcX9dX5tioFH4JGyxS068IvUKwvCwhNwjzj0Mj7dN(qAMzKpKKL4S5MQapMvxSYLa(hkqqSsiwrnZmYRx5snt2CtvGhZQlw5sa)dfOM36ZOAh0mPvswcTDyZCuBMpbiVzkmpMTzMr(qswQzMrE9kxQzIswbbDXkxc4FOa1mrPIuTEZurnV1x(SDqZKwjzj02HnZrTz(eG8MPW8y2Mzg5djzPMzg51RCPMPcXIAJfP(j0kZJzBMOurQwVzQiE(BERpJK2bntALKLqBh2mh1MjG8MPW8y2Mzg5djzPMzgXwPMPW8ywoOlkESi1Qtp65mb4ApUeeFmelmpMLd6IIhlsT60JEUhmf0ECjioFH4Z2mzF40hsZKnzOvwNVbYoxxeQzMrE9kxQzc6IIhlsT60JE9tOvMhZ28wF5dTdAM0kjlH2oSzoQnta5ntH5XSnZmYhsYsnZmITsntsXQHQkHYVYgfc4JEk6RGUeaaXNobXKIvdvvcLJ0kOH4Zd0jbfjbXNobXKIvdvvcLJ0kOH4Zd0xcvS2ywi(0jiMuSAOQsO8a5gEmR(kijGUubeeF6eetkwnuvjuUB0YsaDsEfaQXsai(0jiMuSAOQsOCXORp5DdqdIfjHQvT1RGKG4tNGysXQHQkHYLLf06Af2X1tr3laOZfIpDcIjfRgQQekh0nmfsHtpqxKfjeF6eetkwnuvju(s1xSAacROcinTDYYOhIpDcIjfRgQQekpjwQepPtVSSUMzg51RCPMjBUPkWJz1ZQRaQ5T(qe0oOzsRKSeA7WM5O2mbK3mfMhZ2mZiFijl1mZi2k1mjfRgQQekxmAqN8cqxM11trRo9OhInaXzKpKKL4S5MQapMvpRUcOMzg51RCPMzzwxJo1KL0ZQRaQ5T(YrrTdAM0kjlH2oSzoQnta5ntH5XSnZmYhsYsnZmITsnZCYhAMSpC6dPzMr(qswIxM11Otnzj9S6kGGydq8rqSlwADEjEc4Y70ZPvswcfInaXzKpKKL4LzD9u0Qtp61QpXMBsCnRt2LSqSsiwrnZmYRx5snZYSUEkA1Ph9A1NyZnjUM1j7s2M36lNCAh0mPvswcTDyZB9Lt(Bh0mPvswcTDyZCLl1mfJg0jVa0LzD9u0Qtp6BMcZJzBMIrd6Kxa6YSUEkA1Ph9nV1xoNTDqZuyEmBZ8g)pVoUcsQzsRKSeA7WM36lheP2bntH5XSnt1XJzBM0kjlH2oS5T(YXOAh0mfMhZ2mvr4NKvaEZKwjzj02HnV5nVzMHEqmBRV8RO8ROCuuo50m7j)glsqZ8m4msXP(uC0NIxerigIpOJG44QoVdXL5HyJmkvKQ1nYq8tkwnEcfIbZLGyP6ZvCcfIzDYIKaCywkUXsqC(veIieJOMnd9oHcXgz2KHwzD(zyoTsYsOgzi2hi2iZMm0kRZpdBKH48Yj3S5WSGzDgCgP4uFko6tXlIiedXh0rqCCvN3H4Y8qSrw9j2CtIBKH4NuSA8ekedMlbXs1NR4ekeZ6Kfjb4WSuCJLGyJeerigrnBg6DcfInJlIcIbiSUKleFgdX(aXkUvbIrJmbiMfIhv6fFEioVJZgIZlNCZMdZsXnwcInsqeHye1SzO3jui2iZMm0kRZpdZPvswc1idX(aXgz2KHwzD(zyJmeNxo5MnhMfmRZGZifN6tXrFkEreHyi(GocIJR68oexMhInYS5MQapMvR2jaYidXpPy14juigmxcILQpxXjuiM1jlscWHzP4glbX5KdIieJOMnd9oHcXMXfrbXaewxYfIpJHyFGyf3QaXOrMaeZcXJk9IppeN3XzdX5L)CZMdZsXnwcIZj)iIqmIA2m07ekeBgxefedqyDjxi(mgI9bIvCRceJgzcqmlepQ0l(8qCEhNneNx(ZnBomlywkoUQZ7ekeNpHyH5XSqSnaoGdZQzcujwRV85zBMQ)ucl1mptigrhpbXk(cscM1zcXDURcqep(yKH3vtC2Cpge3Qv8yw2lf)yqCzhdZ6mHyfpmFs0dX5KJXqC(vu(vemlywNjeJO6KfjbqeHzDMqSraXicbeexcKDU(PRelaIFX7OhI9ozHyxEKKZ94sAF0ObbXL5HyRaCJaqSzrHyjf2WraIRabjb4WSoti2iGyeHQOItqSDqgmi(jeriwXTYcui2i9tYfWHzDMqSraXkUZaOfIzcWH4NuSA80LwhaXL5Hye1CtvGhZcX5fCIBmeJoRr2H4UXIcXHdXL5HybIlpb6GyfFYP5HyMa8S5WSoti2iGyJ0bqswcILfIP1FeGyVtCiU3uTOq8tGQ1H4yHybI7KhLjahIZhr4NKvaoehRrGuUehM1zcXgbeFgALKLGyG)bZHywhXuiwKq8SqSaXfQhexMxbaehle7DeeFgLpQ4cX(aXpHwzee3BEfSJGYHzbZ6mH4Zq5sSQtOqCIkZtqmBUjXH4eHmwahIpJyms1bq8oRr0j)TuTqSW8ywaepRfbomlH5XSaU6tS5MeVFLhlptwshRtwlXCywNjeFqxaG4mYhsYsqmqLyrjiae7DeeV1BIEiEkqSlpsYbqS4qCVUG1bXiYJdXM(tIcqmI2kxc4FOabG4P6GaLG4PaXiQ5MQapMfIbDt1IcXjcIRacLdZsyEmlGR(eBUjX7x5XzKpKKLmELlPSBCnWFsuqxSYLa(hkqgpQkbKBCuuMr(qswI3nUg4pjkOlw5sa)dfiLkY4mITskZF(6ILwNxSYL0QIZ640kjlH2)zZ3JCXsRZlw5sAvXzDCALKLqHzDMq8bDbaIZiFijlbXavIfLGaqS3rq8wVj6H4PaXU8ijhaXIdX96cwheJilpkeJOeGdXiARCjG)HceaINQdcucINceJOMBQc8ywig0nvlkeNiiUciuiwaqCjSw65WSeMhZc4QpXMBs8(vECg5djzjJx5sk7KhvZeGRlw5sa)dfiJhvLaYnokkZiFijlX7KhvZeGRlw5sa)dfiLkY4mITskZF(6ILwNxSYL0QIZ640kjlH2)zZ3JCXsRZlw5sAvXzDCALKLqHzDMq8bDbaIZiFijlbXavIfLGaqS3rq8wVj6H4PaXU8ijhaXIdX96cwheJipoeB6pjkaXiARCjG)HceaILNG4kGqHy06hlsigrn3uf4XSCywcZJzbC1NyZnjE)kpoJ8HKSKXRCjLS5MQapMvxSYLa(hkqgpQkbKBCuuMr(qswIZMBQc8ywDXkxc4FOaPurgNrSvs5zZxxS068IvUKwvCwhNwjzj0(ZN57rUyP15fRCjTQ4SooTsYsOWSoti(GUaaXzKpKKLG4aaXvaHcX(aXavIffeGyVJGy5o11H4PaXECjiowigqSzrbqS3joeFRahIvfaaILItpeJOMBQc8ywiMYvnEcaXjQmpbXiARCjG)HceaI7fwleNiiUciuiEN)kwlcCywcZJzbC1NyZnjE)kpoJ8HKSKXRCjLOKvqqxSYLa(hkqgJsfPADLkY4rv5taYHzDMq8zq4DqSrQyrTXI0yigrn3uf4XSgzaeZMXIo9wiUxyTqCIG4NqRmcfItiaXce)YIoxiwUtDDJH4u1HyVJG4TEt0dXtbIzF4aig4Y7aiod9iaXDbYoiwko9qSW8iJ4XIeIruZnvbEmlellkedStpaeJo9wi2NEYJcGyVJGyArH4PaXiQ5MQapM1idGy2mw0P3YH4ZGoAH4ROqSiHyuIfGywaehle7DeeFgLpQ4AmeJOMBQc8ywJmaIF6kXglsiMnJfD6TqCaG4NqRmcfItiaXExaG4YlmpMfI9bIfgBQRdXL5HyJuXIAJfjhMLW8ywax9j2CtI3VYJZiFijlz8kxsPcXIAJfP(j0kZJzngLks16kvep)gpQkFcqomlH5XSaU6tS5MeVFLhNr(qswY4vUKsqxu8yrQvNE0RFcTY8ywJhvLaYnoJyRKsH5XSCqxu8yrQvNE0ZzcW1ECPZyH5XSCqxu8yrQvNE0Z9GPG2JlLVN14OOKnzOvwNVbYoxxeItRKSekmlH5XSaU6tS5MeVFLhNr(qswY4vUKs2CtvGhZQNvxbKXJQsa5gNrSvsjPy1qvLq5xzJcb8rpf9vqxcaoDIuSAOQsOCKwbneFEGojOiPtNifRgQQekhPvqdXNhOVeQyTXSNorkwnuvjuEGCdpMvFfKeqxQa60jsXQHQkHYDJwwcOtYRaqnwcC6ePy1qvLq5IrxFY7gGgelscvRARxbjD6ePy1qvLq5YYcADTc746PO7fa05E6ePy1qvLq5GUHPqkC6b6ISipDIuSAOQsO8LQVy1aewrfqAA7KLr)PtKIvdvvcLNelvIN0PxwwhmlH5XSaU6tS5MeVFLhNr(qswY4vUKYYSUgDQjlPNvxbKXJQsa5gNrSvsjPy1qvLq5Ird6Kxa6YSUEkA1Ph9gYiFijlXzZnvbEmREwDfqWSoti(GUaaXzKpKKLGyuYP)glbG4ED0cXNrgnOtEXidGye9SoepfioFC6rpehaiUciuiorL5ji27iiwTATqCuG4ur4LzD9u0Qtp61QpXMBsCnRt2LSqCaG4DCigOsSOeekhMLW8ywax9j2CtI3VYJZiFijlz8kxszzwxpfT60JET6tS5MexZ6KDjRXJQsa5gNrSvszo5dghfLzKpKKL4LzDn6utwspRUcidh5ILwNxINaU8o9CALKLqnKr(qswIxM11trRo9OxR(eBUjX1SozxYQurWSeMhZc4QpXMBs8(vEmyfvq34AGloaMLW8ywax9j2CtI3VYJRashoDnELlPumAqN8cqxM11trRo9OhMLW8ywax9j2CtI3VYJVX)ZRJRGKGzjmpMfWvFIn3K49R8y1XJzHzjmpMfWvFIn3K49R8yve(jzfGdZcM1zcXNHYLyvNqHykd9iaXECji27iiwy(8qCaGyjJewjzjomlH5XSaLSPUo9avYAnokkp6RlvMhjXrdaluTXkpcA2CVYIYjfRgQQekmlH5XSG(vECg5djzjJx5sk94sAF0S5MQapM14rvjGCJZi2kP0flToVepbC5D650kjlHMVL4jGlVtp)PRelO)8yZyrNElNn3uf4XS8NUsSG8nVCmImYhsYsCfIf1gls9tOvMhZMVUyP15kelQnwKCALKLqZo789i2mw0P3YzZnvbEml)jbfH8nvlfoBUPkWJz5OtVfMLW8ywq)kpg0ffpwKA1Ph9ghfLPAPWzZnvbEmlhD6Tgs1sH)1L0trRo9ONJo9wdSzSOtVLZMBQc8yw(txjwW5kYqESzSOtVL)1L0trRo9ON)0vIfCUIoD6ixS068VUKEkA1Ph9CALKLqZgMLW8ywq)kp(f0qwxduLxbJJIY8s1sHZMBQc8ywo60BnKQLc)RlPNIwD6rphD6TgYJnJfD6TC2CtvGhZYF6kXcqmLlXQoP94sNoXMXIo9woBUPkWJz5pDLybNZMXIo9w(lOHSUgOkVcC06lEmB2zF6uEPAPW)6s6POvNE0ZRQgyZyrNElNn3uf4XS8NUsSGZpRIYgMLW8ywq)kpgLeVln)sghfLPAPWzZnvbEmlhD6Tgs1sH)1L0trRo9ONJo9wdSzSOtVLZMBQc8yw(txjwaIPCjw1jThxcMLW8ywq)kp(g)pVoUcsY4OOmvlfoBUPkWJz5OtV1akLQLc)f0qwxduLxbDMQDPxsHnCe4OtVfMLW8ywq)kpUciD4014vUKsXObDYlaDzwxpfT60JEJJIYmYhsYsCpUK2hnBUPkWJzrSsJQ)CmQ8nJ8HKSeVmRRrNAYs6z1vaziJ8HKSe3JlP9rZMBQc8y2ZvemlH5XSG(vEmYQ8OHS6POfJM(X7mokkZlJ8HKSe3JlP9rZMBQc8yweNJIoDQei7C9txjwaIZiFijlX94sAF0S5MQapMnBywcZJzb9R8y2SmA9xCcvxSYLGzjmpMf0VYJFsuJfPUyLlbGzjmpMf0VYJldRciuTy00hoPtKCHzjmpMf0VYJvRFuqiwK6KvaomlH5XSG(vE8hQQwshRgOkmcMLW8ywq)kp27iDDttDr1L5zemRZeIv8soe7DeeJgawOAJvEe0S5ELffIt1sbIRQgdX11saaeZMBQc8ywioaqmyMLdZsyEmlOFLhZM660dujR14OO8RlvMhjXrdaluTXkpcA2CVYIYjfRgQQeQb2mw0P3Yt1srJgawOAJvEe0S5ELfL)KGIGHuTu4ObGfQ2yLhbnBUxzr1YZKL4OtV1aBgl60B5S5MQapML)0vIfC(zvKHJs1sHJgawOAJvEe0S5ELfLxvHzjmpMf0VYJLNjlPPCvTdiM14OO8RlvMhjXrdaluTXkpcA2CVYIYjfRgQQeQb2mw0P3Yt1srJgawOAJvEe0S5ELfL)KGIGHuTu4ObGfQ2yLhbnBUxzr1YZKL4OtV1aBgl60B5S5MQapML)0vIfC(zvKHJs1sHJgawOAJvEe0S5ELfLxvHzjmpMf0VYJl)a80yDJJIYVUuzEKehnaSq1gR8iOzZ9klkNuSAOQsOgyZyrNElpvlfnAayHQnw5rqZM7vwu(tckcgs1sHJgawOAJvEe0S5ELfvx(b4C0P3AGnJfD6TC2CtvGhZYF6kXco)SkYWrPAPWrdaluTXkpcA2CVYIYRQWSeMhZc6x5XFDj9u0Qtp6nokkt1sH)1L0trRo9ONJo9wd5Lr(qswI7XL0(OzZnvbEm75PAPW)6s6POvNE0ZrRV4XSgYiFijlX94sAF0S5MQapM9CH5XS8s8KozfGZlvRv)eRtEKK2JlD6ug5djzjUhxs7JMn3uf4XSNxcKDU(PReliBywcZJzb9R8yMyTAH5XSABaCJx5skzZnvbEmRwTtaKXrr5rzKpKKL4ObqswsZMBQc8ywdzKpKKL4ECjTpA2CtvGhZIyLkcM1zcXhO4XiTIheri(GocIZXOG4LKhI9ocIPffINce7DbaIzZIgEmlehaiwwiw(u4V8iaXSzrdpMfIlZdXSoIPqSiH4OaXMDrXJfjeNpo9OhI7fwleNiiUQcXGzwoeJOJffIfi(opbXcJvFXjiUNGae7deRWo9GyVtCi2SlkESiH48XPh9qCVWAHy1FssYIaeNiiUciuiorL5ji27ii20i1HqS6pmomlH5XSG(vECg5djzjJx5sklXt6KvaUwDgBSinoJyRKYJYiFijlXrdGKSKMn3uf4XSgYiFijlX94sAF0S5MQapMfXcZJz5L4jDYkaNxQwR(jwN8ijThxYiYiFijlXbDrXJfPwD6rV(j0kZJzZ38yZyrNElh0ffpwKA1Ph98NUsSaeNr(qswI7XL0(OzZnvbEmB2gYiFijlX94sAF0S5MQapMfXLazNRF6kXcoD6RlvMhjXb1vRqSib6KLaGyrYjfRgQQeQbH5XS8s8KozfGZzDYJKa6YlmpMvSiwyEmlVepPtwb48RKRM1jpscyekIBugYJnJfD6TCqxu8yrQvNE0ZF6kXcophJ60PJytgAL15BGSZ1fH40kjlHMnmlH5XSG(vEmtSwTW8ywTnaUXRCjL)OQv7eazCuuMQLc)RlPNIwD6rpVQAiVmYhsYsCpUK2hnBUPkWJzpxrzdZsyEmlOFLhNr(qswY4vUKs1UH2ixT6m2yrACgXwjLhLr(qswIJgajzjnBUPkWJznKr(qswI7XL0(OzZnvbEmlIfMhZYv7gAJC1fRCjaVuTw9tSo5rsApUKHmYhsYsCpUK2hnBUPkWJzrCjq256NUsSGtN(6sL5rsCqD1kelsGozjaiwKCsXQHQkHcZ6mH4ZGoAHyez5rzcWJfjeJOTYLGyt)dfiJHyeD8eeFOvaoaIbDt1IcXjcIRacfI9bIrsl9ItqmI84qSP)KOaaILffI9bIPCDArH4dTcWPhIv8fGtphMLW8ywq)kpUepPtwb4gxbKEkfnsgQYCmUciDVUWsAMa8yrQmhJJIYJYiFijlXlXt6KvaUwDgBSinKxg5djzjUhxs7JMn3uf4XSNROSnKNW8idPPLUbboxzg5djzjEN8OAMaCDXkxc4FOazippUKrKQLcNn3uf4XSCRaCnLRA805zKpKKL4OKvqqxSYLa(hkqzNTHJkXtaxENEUW8idz4OuTu4DJRb(tIc8NeMdZ6mHyJ01pwKqmIoEc4Y70BmeJOJNG4dTcWbqS8eexbekedIByL3Iae7deJw)yrcXiQ5MQapMLdXkEPLEXArWyi27ieGy5jiUciui2higjT0lobXiYJdXM(tIcaiUxhTqm7dhaX9cRfI3XH4ebX9eGtOqSSOqCVW7G4dTcWPhIv8fGtVXqS3riaXGUPArH4ebXa1NeuiEQoe7deFLyDjwi27ii(qRaC6HyfFb40dXPAPWHzjmpMf0VYJlXt6KvaUXvaPNsrJKHQmhJRas3RlSKMjapwKkZX4OOSepbC5D65cZJmKbwN8ijW5kZXWrzKpKKL4L4jDYkaxRoJnwKgY7iH5XS8s8usSwoLlXQESinCKW8ywUkc)KScW5XQl2azNBivlfEhjESi1vv(tcZpDsyEmlVepLeRLt5sSQhlsdhLQLcVBCnWFsuG)KW8tNeMhZYvr4NKvaopwDXgi7CdPAPW7iXJfPUQYFsyUHJs1sH3nUg4pjkWFsyE2WSeMhZc6x5XmXA1cZJz12a4gVYLucCzrLhv)JlEmRXrrzEzKpKKL4ECjTpA2CtvGhZEUIY2qQwk8VUKEkA1Ph9C0P3cZcMLW8ywaxyEKH0UyP1bkTrMyrQtZnzCuukmpYqAAPBqGZZXqQwkC2CtvGhZYrNERH8YiFijlX94sAF0S5MQapM9C2mw0P3YTrMyrQtZnXrRV4XSNoLr(qswI7XL0(OzZnvbEmlIvQOSHzjmpMfWfMhziTlwADq)kp(sonVXrr5rzKpKKL4ObqswsZMBQc8ywdzKpKKL4ECjTpA2CtvGhZIyLk60P8yZyrNEl)sonphT(IhZI4mYhsYsCpUK2hnBUPkWJznCKlwAD(xxspfT60JEoTsYsOzF6KlwAD(xxspfT60JEoTsYsOgs1sH)1L0trRo9ONxvnKr(qswI7XL0(OzZnvbEm75cZJz5xYP55SzSOtV90PsGSZ1pDLybioJ8HKSe3JlP9rZMBQc8ywywcZJzbCH5rgs7ILwh0VYJrFb5SaD6jX7mokkDXsRZflLlWFby0cqxQpcCALKLqnKxQwkC2CtvGhZYrNERHJs1sH3nUg4pjkWFsyE2WSGzjmpMfWzZnvbEmRwTtaKsBGSZbAfNROiV06ghfLPAPWzZnvbEmlhD6TWSoti(meWJR4ee3n9Gy7SiHye1CtvGhZcX9cRfITcWHyVtwfaqSpqSzDHyJuXI0idG4dTeaelsi2higLC6VXsqC30dIr0Xtq8Hwb4aig0nvlkeNiiUciuomlH5XSaoBUPkWJz1QDcG6x5XzKpKKLmELlPKY1PfLq1S5MQapMv)0vIfy8OQeqUXzeBLuMQLcNn3uf4XS8NUsSG(t1sHZMBQc8ywoA9fpMnFZJnJfD6TC2CtvGhZYF6kXcqCQwkC2CtvGhZYF6kXcYgMLW8ywaNn3uf4XSA1obq9R84mYhsYsgVYLus560IsOA2CtvGhZQF6kXcmEuvkOOgNrSvsz(04OOmvlfoOUAfIfjqNSeaels9tckc8Q6PtzKpKKL4uUoTOeQMn3uf4XS6NUsSGZZHBu5lsgk)k5MV5LQLchuxTcXIeOtwcaIfj)k5QbUWuWis1sHdQRwHyrc0jlbaXIKdCHPq2WSeMhZc4S5MQapMvR2jaQFLhNeK6PO9pykamokkt1sHZMBQc8ywo60BHzjmpMfWzZnvbEmRwTtau)kp2gzIfPon3KXrrPW8idPPLUbbophdPAPWzZnvbEmlhD6TWSeMhZc4S5MQapMvR2jaQFLhFJ)NhONI2N)sRBCuuMQLcNn3uf4XSC0P3Aivlf(xxspfT60JEo60BHzjmpMfWzZnvbEmRwTtau)kpUciD4014vUKYoeuP37Esq19(a49ErfyCuuMQLcNn3uf4XS8QQbH5XS8s8KozfGZzDYJKakvKbH5XS8s8KozfGZFI1jpss7XLohjdLFLCHzjmpMfWzZnvbEmRwTtau)kpozNbvpfT3rAAPlcWSeMhZc4S5MQapMvR2jaQFLhFP78iONI2wzbQg9j5cGzjmpMfWzZnvbEmRwTtau)kpU38w0muS6NaZklJGzDMqSr66hlsigrn3uf4XSgdXi64ji(qRaCaelpbXvaHcX(aXiPLEXjigrECi20FsuaaXYIcX3yJBy0ee7Deel3PUoepfi2JlbXavADiMYLyvpwKq84D0dXavYAbCigrppedCzrLhfIr0XtgdXi64ji(qRaCaelpbXZAraIRacfI71rleJitIhlsigrOkehaiwyEKHG45H4ED0cXceBYMN1bXmb4qCaG4yHy1Fq(eaaXYIcXiYK4XIeIreQcXYIcXiYJdXM(tIcqS8eeVJdXcZJmehIpdcVdIp0kaNEiwXxao9qSSOqmI2kxcIv8SgdXi64ji(qRaCaeZKfIfu0WJzfRfbiorqCfqOqCVUWsqmI84qSP)KOaellkeJitIhlsigrOkelpbX74qSW8idbXYIcXceNpIWpjRaCioaqCSqS3rqSepellkelwWaX96clbXmb4XIeInzZZ6GykdTqCuGyezs8yrcXicvH4aaXI9jbfbiwyEKH4q8bDeeBf3PhIfRD6bGyV3aXiYJdXM(tIcqC(ic)KScWbqSpqCIGyMaCiowiguzmcaIzHyP40dXEhbXMS5zDCi(mcfn8ywXAraI7fEheFOvao9qSIVaC6HyzrHyeTvUeeR4zngIr0Xtq8Hwb4aig0nvlkeVJdXjcIRacfIRRLaai(qRaC6HyfFb40dXbaIL0uDi2hiMYvnEcINhI9o6jiwEcIVZtqS3jlet7ur2bXi64ji(qRaCae7det560IcXhAfGtpeR4laNEi2hi27iiMwuiEkqmIAUPkWJz5WSeMhZc4S5MQapMvR2jaQFLhxIN0jRaCJRaspLIgjdvzogxbKUxxyjntaESivMJXrrPy00hoXtwb40RVcWPNtRKSeQbwN8ijW5kZXqE5jmpMLxIN0jRaCoRtEKeqxEH5XSIT)8s1sHZMBQc8yw(txjwGrKQLcpzfGtV(kaNEoA9fpMn7Zy2mw0P3YlXt6KvaohT(IhZAe5LQLcNn3uf4XS8NUsSGSpJZlvlfEYkaNE9vao9C06lEmRrOiUrLD2NRurNoDKy00hoXtwb40RVcWPNtRKSe6Pth5ILwNxSYL0ZYPvswc90PuTu4S5MQapML)0vIfGyLPAPWtwb40RVcWPNJwFXJzpDkvlfEYkaNE9vao98NUsSaeRiUrD6ePy1qvLq5DiOsV39KGQ79bW79IkWaBgl60B5DiOsV39KGQ79bW79IkqFwfPOCqKYp)PRelaXgv2gs1sHZMBQc8ywEv1qEhjmpMLdyZZ64uUeR6XI0WrcZJz5Qi8tYkaNhRUydKDUHuTu4DK4XIuxv5v1tNeMhZYbS5zDCkxIv9yrAivlfE34AG)KOahD6TgYlvlfEhjESi1vvo60BpDsmA6dN4jRaC61xb40ZPvswcn7tNeJM(WjEYkaNE9vao9CALKLqn4ILwNxSYL0ZYPvswc1GW8ywUkc)KScW5XQl2azNBivlfEhjESi1vvo60BnKQLcVBCnWFsuGJo92SHzDMq8zq4DqSIJTq)kwigrjaMGsgdXi64ji(qRaCaed6MQffI3XH4ebXvaHcX11saaeR4yl0VIfIrucGjOeehaiwst1HyFGykx14jiEEi27ONGy5ji(opbXENSqmTtfzheJOJNG4dTcWbqSpqmLRtlkeFOvao9qSIVaC6HyFGyVJGyArH4PaXiQ5MQapMLdZsyEmlGZMBQc8ywTANaO(vECjEsNScWnUci9ukAKmuL5yCfq6EDHL0mb4XIuzoghfLhjgn9Ht8Kvao96RaC650kjlHAipH5rgstlDdcGyLcZJmKgDCEGCdNoD6i2mw0P3Yv7gAJC1fRCja)jbfHSnWMfTgop2c9Ry1mbWeuItRKSeQbwN8ijW5kZXqE5jmpMLxIN0jRaCoRtEKeqxEH5XSIT)8YiFijlXPCDArjunBUPkWJz1pDLybgrQwk8yl0VIvZeatqjoA9fpMn7Zy2mw0P3YlXt6KvaohT(IhZAezKpKKL4uUoTOeQMn3uf4XS6NUsSGZ48s1sHhBH(vSAMayckXrRV4XSgHI4gv2zFUsfD6ug5djzjoLRtlkHQzZnvbEmR(PRelaXkt1sHhBH(vSAMayckXrRV4XSNoLQLcp2c9Ry1mbWeuI)0vIfGyfXnQSnKQLcNn3uf4XS8QQHJs1sHxINa(8x(tcZnCuQwk8UX1a)jrb(tcZn0nUg4pjkObQK1c0XQl2azN3FQwk8os8yrQRQ8NeMJ48dZsyEmlGZMBQc8ywTANaO(vECjEsNScWnUci9ukAKmuL5yCfq6EDHL0mb4XIuzoghfLhjgn9Ht8Kvao96RaC650kjlHAipH5rgstlDdcGyLcZJmKgDCEGCdNoD6i2mw0P3Yv7gAJC1fRCja)jbfHSnCeBw0A48yl0VIvZeatqjoTsYsOgyDYJKaNRmhdPAPWzZnvbEmlVQA4OuTu4L4jGp)L)KWCdhLQLcVBCnWFsuG)KWCdDJRb(tIcAGkzTaDS6Inq259NQLcVJepwK6Qk)jH5io)WSeMhZc4S5MQapMvR2jaQFLhZM660dujR14OO8RlvMhjXrdaluTXkpcA2CVYIYjfRgQQeQHuTu4ObGfQ2yLhbnBUxzr5OtV1qQwkC0aWcvBSYJGMn3RSOA5zYsC0P3AGnJfD6T8uTu0ObGfQ2yLhbnBUxzr5pjOiaZsyEmlGZMBQc8ywTANaO(vES8mzjnLRQDaXSghfLFDPY8ijoAayHQnw5rqZM7vwuoPy1qvLqnKQLchnaSq1gR8iOzZ9klkhD6Tgs1sHJgawOAJvEe0S5ELfvlptwIJo9wdSzSOtVLNQLIgnaSq1gR8iOzZ9klk)jbfbywcZJzbC2CtvGhZQv7ea1VYJl)a80yDJJIYVUuzEKehnaSq1gR8iOzZ9klkNuSAOQsOgs1sHJgawOAJvEe0S5ELfLJo9wdPAPWrdaluTXkpcA2CVYIQl)aCo60BHzjmpMfWzZnvbEmRwTtau)kpMjwRwyEmR2ga34vUKsH5rgs7ILwhaZsyEmlGZMBQc8ywTANaO(vEmBUPkWJznUci9ukAKmuL5yCfq6EDHL0mb4XIuzoghfLPAPWzZnvbEmlhD6TgY7RlvMhjXrdaluTXkpcA2CVYIYjfRgQQeQYuTu4ObGfQ2yLhbnBUxzr5v1SnKNW8yw(LCAEES6Inq25geMhZYVKtZZJvxSbYox)0vIfGyLkIBuNojmpMLdyZZ64uUeR6XI0GW8ywoGnpRJt5sSQt6NUsSaeRiUrD6KW8ywEjEkjwlNYLyvpwKgeMhZYlXtjXA5uUeR6K(PRelaXkIBuNojmpMLRIWpjRaCoLlXQESinimpMLRIWpjRaCoLlXQoPF6kXcqSI4gv2WSeMhZc4S5MQapMvR2jaQFLhRoEmRXrrzQwkC2CtvGhZYTcW1uUQXtiwPW8ywoBUPkWJz5wb46kGqHzjmpMfWzZnvbEmRwTtau)kpozNbvxQpcghfLPAPWzZnvbEml3kaxt5QgpHyLcZJz5S5MQapMLBfGRRacfMLW8ywaNn3uf4XSA1obq9R84e9a6viwKghfLPAPWzZnvbEml3kaxt5QgpHyLcZJz5S5MQapMLBfGRRacfMLW8ywaNn3uf4XSA1obq9R84s8uYodQXrrzQwkC2CtvGhZYTcW1uUQXtiwPW8ywoBUPkWJz5wb46kGqHzjmpMfWzZnvbEmRwTtau)kpwwgb8xSAMyTghfLPAPWzZnvbEml3kaxt5QgpHyLcZJz5S5MQapMLBfGRRacfMLW8ywaNn3uf4XSA1obq9R84kG0HtxGXrrzQwkC2CtvGhZYTcW1uUQXtiwPW8ywoBUPkWJz5wb46kGqHzjmpMfWzZnvbEmRwTtau)kpUyLlb8puGmokkt1sH3nUg4pjkWFsyUbH5rgstlDdcCUYmYhsYsC2CtvGhZQlw5sa)dfiywcZJzbC2CtvGhZQv7ea1VYJvr4NKvaUXrrzQwkCqD1kelsGozjaiwK6Neue4vvdPAPWb1vRqSib6KLaGyrQFsqrG)0vIfCotaU2JlbZsyEmlGZMBQc8ywTANaO(vESkc)KScWnokkt1sHxINa(8x(tcZHzjmpMfWzZnvbEmRwTtau)kpwfHFswb4ghfLPAPWvr4hMvax(tcZnKQLcxfHFywbC5pDLybNZeGR94sgYlvlfoBUPkWJz5pDLybNZeGR94sNoLQLcNn3uf4XSC0P3MnmlH5XSaoBUPkWJz1QDcG6x5XQi8tYka34OOmvlfE34AG)KOa)jH5gs1sHZMBQc8ywEvfMLW8ywaNn3uf4XSA1obq9R8yve(jzfGBCuuQ(ugnsgkphoGnpRZqQwk8os8yrQRQ8NeMdZsyEmlGZMBQc8ywTANaO(vESA3qBKRUyLlbmokkt1sHZMBQc8ywEvfMLW8ywaNn3uf4XSA1obq9R84s8usSwJJIYuTu4S5MQapMLJo9wdSzSOtVLZMBQc8yw(txjwaIzcW1ECjdhXMfTgoVyLlPfg7jpMLtRKSekmlH5XSaoBUPkWJz1QDcG6x5Xa28SoJJIYuTu4S5MQapML)0vIfCotaU2JlzivlfoBUPkWJz5v1tNs1sHZMBQc8ywo60BnWMXIo9woBUPkWJz5pDLybiMjax7XLGzjmpMfWzZnvbEmRwTtau)kp2gzIfPon3KXrrzQwkC2CtvGhZYF6kXcqmsgk)k5AqyEKH00s3GaNNdmlH5XSaoBUPkWJz1QDcG6x5XOVGCwGo9K4DghfLPAPWzZnvbEml)PRelaXizO8RKRHuTu4S5MQapMLxvHzjmpMfWzZnvbEmRwTtau)kpgWMN1zCuu6YJKCEhjwVJRYCeR8SkYGlwADoGKpwKAFQSooTsYsOWSGzjmpMfW)rvR2jaszXkxc4FOazCuuMNW8idPPLUbboxzg5djzjE34AG)KOGUyLlb8puGmKNhxYis1sHZMBQc8ywUvaUMYvnE68mYhsYsCuYkiOlw5sa)dfOSZ2qQwk8UX1a)jrb(tcZHzjmpMfW)rvR2jaQFLhRIWpjRaCJJIYuTu4G6QviwKaDYsaqSi1pjOiWRQgs1sHdQRwHyrc0jlbaXIu)KGIa)PRel4CMaCThxcMLW8ywa)hvTANaO(vESkc)KScWnokkt1sHxINa(8x(tcZHzjmpMfW)rvR2jaQFLhRIWpjRaCJJIYuTu4DJRb(tIc8NeMdZsyEmlG)JQwTtau)kpUepPtwb4gxbKEkfnsgQYCmUciDVUWsAMa8yrQmhJJIYuTu4G6QviwKaDYsaqSi1pjOiWrNERHJYtyEKH00s3GaNRmJ8HKSeVtEuntaUUyLlb8puGmKNhxYis1sHZMBQc8ywUvaUMYvnE68mYhsYsCuYkiOlw5sa)dfOSZ2WrL4jGlVtpxyEKHmK3rPAPW7iXJfPUQYFsyUHJs1sH3nUg4pjkWFsyUHJuFkJEkfnsgkVepPtwb4gYtyEmlVepPtwb4CwN8ijW5kZ)Pt55ILwNlwkxG)cWOfGUuFe40kjlHAGnJfD6TC0xqolqNEs8o(tckczF6uEUyP15as(yrQ9PY640kjlHAWLhj58osSEhxL5iw5zvu2zNnmlH5XSa(pQA1obq9R84s8KozfGBCfq6Pu0izOkZX4kG096clPzcWJfPYCmokkpQepbC5D65cZJmKH8YlpH5XS8s8usSwoLlXQESipDsyEmlxfHFswb4CkxIv9yrMTHuTu4DK4XIuxv5pjmp7tNYZflTohqYhlsTpvwhNwjzjudU8ijN3rI174QmhXkpRImKxQwk8os8yrQRQ8NeMB4iH5XSCaBEwhNYLyvpwKNoDuQwk8UX1a)jrb(tcZnCuQwk8os8yrQRQ8NeMBqyEmlhWMN1XPCjw1JfPHJ6gxd8Nef0avYAb6y1fBGSZZo7SHzjmpMfW)rvR2jaQFLhZeRvlmpMvBdGB8kxsPW8idPDXsRdGzjmpMfW)rvR2jaQFLhRIWpjRaCJJIYuTu4Qi8dZkGl)jH5gycW1ECjeNQLcxfHFywbC5pDLybgycW1ECjeNQLc)RlPNIwD6rp)PRelWqEPAPWvr4hMvax(tcZvMQLcxfHFywbC5xjxnWfMcNoLQLcxfHFywbC5pDLybiMjax7XL6xyEmlVepLeRLt5sSQtApU0PtPAPWflLlWFby0cqxQpc8Q6Pth91LkZJK4G6QviwKaDYsaqSi5KIvdvvcnBywcZJzb8Fu1QDcG6x5XQi8tYka34OOu9PmAKmuEoCaBEwNHuTu4DK4XIuxv5pjm3GlwADoGKpwKAFQSooTsYsOgC5rsoVJeR3XvzoIvEwfz4O8eMhzinT0niW5kZiFijlX7gxd8Nef0fRCjG)HcKH884sgrQwkC2CtvGhZYTcW1uUQXtNNr(qswIJswbbDXkxc4FOaLD2WSeMhZc4)OQv7ea1VYJv7gAJC1fRCjGXrr5rzKpKKL4QDdTrUA1zSXI0qQwk8os8yrQRQ8NeMB4OuTu4DJRb(tIc8NeMBipH5rgsJoopqUHtio)NojmpYqAAPBqGZvMr(qswI3jpQMjaxxSYLa(hkqNojmpYqAAPBqGZvMr(qswI3nUg4pjkOlw5sa)dfOSHzjmpMfW)rvR2jaQFLhdyZZ6mokkD5rsoVJeR3XvzoIvEwfzWflTohqYhlsTpvwhNwjzjuywcZJzb8Fu1QDcG6x5XOVGCwGo9K4DghfLcZJmKMw6ge488dZsyEmlG)JQwTtau)kpUyLlb8puGmokkZtyEKH00s3GaNRmJ8HKSeVtEuntaUUyLlb8puGmKNhxYis1sHZMBQc8ywUvaUMYvnE68mYhsYsCuYkiOlw5sa)dfOSZgMLW8ywa)hvTANaO(vECjEkjwlmlywcZJzbCGllQ8O6FCXJzvwSYLa(hkqghfL5jmpYqAAPBqGZvMr(qswI3nUg4pjkOlw5sa)dfid55XLmIuTu4S5MQapMLBfGRPCvJNopJ8HKSehLScc6IvUeW)qbk7SnKQLcVBCnWFsuG)KWCywcZJzbCGllQ8O6FCXJz7x5XQi8tYka34OOmvlfEjEc4ZF5pjmhMLW8ywah4YIkpQ(hx8y2(vESkc)KScWnokkt1sH3nUg4pjkWFsyUHuTu4DJRb(tIc8NUsSaelmpMLxINsI1YPCjw1jThxcMLW8ywah4YIkpQ(hx8y2(vESkc)KScWnokkt1sH3nUg4pjkWFsyUH8uFkJgjdLNdVepLeR90Ps8eWL3PNlmpYqNojmpMLRIWpjRaCES6Inq25zdZ6mH4dEeGyFGyKKdXMgPoeIv)HbG4ybbkbXkon5JqSANaiaeppeJOMBQc8ywiwTtaeaI71rleRoaqKSehMLW8ywah4YIkpQ(hx8y2(vESkc)KScWnokkt1sHdQRwHyrc0jlbaXIu)KGIaVQAip2mw0P3Y)6s6POvNE0ZF6kXc6xyEml)RlPNIwD6rpNYLyvN0ECP(zcW1ECPZt1sHdQRwHyrc0jlbaXIu)KGIa)PRel40PJCXsRZ)6s6POvNE0ZPvswcnBdzKpKKL4ECjTpA2CtvGhZ2ptaU2JlDEQwkCqD1kelsGozjaiwK6Neue4pDLybWSeMhZc4axwu5r1)4IhZ2VYJvr4NKvaUXrrzQwk8UX1a)jrb(tcZn4YJKCEhjwVJRYCeR8SkYGlwADoGKpwKAFQSooTsYsOWSeMhZc4axwu5r1)4IhZ2VYJvr4NKvaUXrrzQwkCve(HzfWL)KWCdmb4ApUeIt1sHRIWpmRaU8NUsSad5LQLcxfHFywbC5pjmxzQwkCve(HzfWLFLC1axykC6uQwkCve(HzfWL)0vIfGyMaCThxQFH5XS8s8usSwoLlXQoP94sNoLQLcxSuUa)fGrlaDP(iWRQNoD0xxQmpsIdQRwHyrc0jlbaXIKtkwnuvj0SHzjmpMfWbUSOYJQ)XfpMTFLhxIN0jRaCJRaspLIgjdvzogxbKUxxyjntaESivMJXrr5rL4jGlVtpxyEKHmCug5djzjEjEsNScW1QZyJfPH8YlpH5XS8s8usSwoLlXQESipDsyEmlxfHFswb4CkxIv9yrMTHuTu4DK4XIuxv5pjmp7tNYZflTohqYhlsTpvwhNwjzjudU8ijN3rI174QmhXkpRImKxQwk8os8yrQRQ8NeMB4iH5XSCaBEwhNYLyvpwKNoDuQwk8UX1a)jrb(tcZnCuQwk8os8yrQRQ8NeMBqyEmlhWMN1XPCjw1JfPHJ6gxd8Nef0avYAb6y1fBGSZZo7SHzjmpMfWbUSOYJQ)XfpMTFLhRIWpjRaCJJIs1NYOrYq55WbS5zDgs1sH3rIhlsDvL)KWCdUyP15as(yrQ9PY640kjlHAWLhj58osSEhxL5iw5zvKHJYtyEKH00s3GaNRmJ8HKSeVBCnWFsuqxSYLa(hkqgYZJlzePAPWzZnvbEml3kaxt5QgpDEg5djzjokzfe0fRCjG)Hcu2zdZsyEmlGdCzrLhv)JlEmB)kpwTBOnYvxSYLaghfLhLr(qswIR2n0g5QvNXglsd5DKlwADE5NR27iTa6iaNwjzj0tNeMhzinT0niW55KTH8eMhzinT0niW55yqyEKH0OJZdKB4eIZ)PtcZJmKMw6ge4CLzKpKKL4DYJQzcW1fRCjG)Hc0PtcZJmKMw6ge4CLzKpKKL4DJRb(tIc6IvUeW)qbkBywcZJzbCGllQ8O6FCXJz7x5XmXA1cZJz12a4gVYLukmpYqAxS06aywcZJzbCGllQ8O6FCXJz7x5XOVGCwGo9K4DghfLcZJmKMw6ge48CGzjmpMfWbUSOYJQ)XfpMTFLhdyZZ6mokkD5rsoVJeR3XvzoIvEwfzWflTohqYhlsTpvwhNwjzjuywNjeFgeEhet7ur2bXU8ijhymehoehaiwGyKsSqSpqmtaoeJOTYLa(hkqqSaG4syT0dXXcCsqH4PaXi64PKyTCywcZJzbCGllQ8O6FCXJz7x5XfRCjG)HcKXrrPW8idPPLUbboxzg5djzjEN8OAMaCDXkxc4FOazippUKrKQLcNn3uf4XSCRaCnLRA805zKpKKL4OKvqqxSYLa(hkqzdZsyEmlGdCzrLhv)JlEmB)kpUepLeRfMLW8ywah4YIkpQ(hx8y2(vEmGnpRR5nV1a]] )

end
