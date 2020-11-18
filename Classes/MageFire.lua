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
            duration = 12,
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
            duration = 4,
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

    spec:RegisterStateExpr( "hot_streak_spells_in_flight", function ()
        local num = 0

        if state:IsInFlight( "fireball" ) then num = num + 1 end
        if state:IsInFlight( "phoenix_flames" ) then num = num + 1 end
        if state:IsInFlight( "pyroblast" ) then num = num + 1 end

        return num
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


    spec:RegisterPack( "Fire", 20201118, [[daf88cqiqvEKifUKiLsBse(eQkPrPsQtPsYQqvPELcvZcv0TePKDrYVujAyGQ6yIOwMkHEgQattKI6AOQW2qfu(gQksJtKICoubX6qvrmpvQ6EOs7dvO)HkivDquvuwOcXdvjWefPu4IQur1gvjOpQsfjJuKs1jrfKSsrKxQsfLzIQs0nrvr1ovi9tubPmuuvclvKsrpLunvfkxfvq1xvPIySOcsL9kXFPyWqDyIflQhJYKb5YiBwsFgugTcoTWQvPIuVgvvZMs3wf7wPFl1WjLJRsLwUQEoKPt11v02rv(Uiz8IuDEqL1RsfMVkL9dCj5YyfDiXPYOxe(xe(jNCYPjvYPP0mFAYfDhonQORjm(fyurFLdv0VW4PIUMaNTfOYyfDupFgv0hCxdXNC5LWcFyMvS(CjkotR4rVSxQ(LO4WUSONNH15qTLCrhsCQm6fH)fHFYjNCAsLCAId4a(GdPOltFO)IUECUGI(qabrBjx0HieRONga8fgpbW85cmcKuAaWdURH4tU8syHpmZkwFUefNPv8Ox2lv)suCyxcskna4rBE0jtpaNCAIta(IW)IWhKeiP0aGVGbzHri(eqsPbaNwamhoIa4AaBWnpDKyra8l(a9aSpila7YdJCLhhY4TbkiaU2paBfKNwiI1leal5WgoCa8ejWiKcKuAaWPfaZHRbjobW2gwWa4N4tay(YjlGa40gpjhKcKuAaWPfaZx2nIwaMjihGF6UZ4PdTocGR9dWxqFYtKh9cWxhksXjad1lF1b4H2cbWHdW1(bybGRpHgay(CYP(byMG8RuGKsdaoTa478vYwcGr(hmhGzdeJ)yHbW9cWcaxPuaCTF(raCSaSpqamFgFbFja7na)e0KraCQ(532cKQOBdKJkJv0z9jprE0RrBqquzSYOjxgROtRKTeuzKIo7dN(qk65zTQy9jprE0RcQtTfDH5rVfDBaBWrM70tiyhA9Ixg9ILXk60kzlbvgPO3AfDe5fDH5rVfDEYhs2sfDEIDsf98SwvS(KNip6v90rIfbWJdW5zTQy9jprE0RcA(Ih9cW8naFnaZ62c1PwfRp5jYJEvpDKyra89aCEwRkwFYtKh9QE6iXIa4Rk68K3SYHk6u6oTqeKH1N8e5rVMNosSOIxgLdkJv0PvYwcQmsrV1k6ceurxyE0BrNN8HKTurNNyNurNN8HKTKcXF2anFXJEl68K3SYHk6u6oTqeKH1N8e5rVMNosSOIo7dN(qk65zTQqZ1WFSWqMSLqOyHzEsGGtn1a4B3ayEYhs2skkDNwicYW6tEI8OxZthjweaZraozfFaW8nadJbPos6amFdWxdW5zTQqZ1WFSWqMSLqOyHPos6gKlm(b40cGZZAvHMRH)yHHmzlHqXctHCHXpaFvXlJMMlJv0PvYwcQmsrN9HtFif98SwvS(KNip6vb1P2IUW8O3IEwGz6QX)GXpQ4Lr5JYyfDALSLGkJu0zF40hsrxyEWJm0sNGqamhb4Kb4eaCEwRkwFYtKh9QG6uBrxyE0Br3g8IfMj3NCXlJYHvgROtRKTeuzKIo7dN(qk65zTQy9jprE0RcQtTaCcaopRv1pxY0vJwNIEfuNAl6cZJEl6N4)(rMUA8(p06fVmkFAzSIoTs2sqLrk6RCOI(aCA07dpjqMuFG8uVOHk6cZJEl6dWPrVp8Kazs9bYt9IgQOZ(WPpKIEEwRkwFYtKh9QMAaCcawyE0RQgpzYwb5k2G8WieaZfGHpaNaGfMh9QQXtMSvqU6j2G8WiJhhcG5iadJbPos6fVmAAQmwrxyE0BrpB7gY0vJpqgAPdCfDALSLGkJu8YOCiLXk6cZJEl6h60pCMUAStwazGEsoOIoTs2sqLrkEz0KHFzSIUW8O3IEQ(Tq8OynpH6vwgv0PvYwcQmsXlJMCYLXk60kzlbvgPOprKj1qyjdtqESWkJMCrN9HtFifD5oOpCsLTcYP3CeKtVIwjBjiaobaZgKhgHayoYfGtgGtaWxdWxdWcZJEv14jt2kixXgKhgHm1xyE0Ryb4Xb4Rb48SwvS(KNip6v90rIfbWPfaNN1QkBfKtV5iiNEf08fp6fGVcGVeGzDBH6uRQgpzYwb5kO5lE0laNwa81aCEwRkwFYtKh9QE6iXIa4Ra4lb4Rb48SwvzRGC6nhb50RGMV4rVaCAbWWxXha8va8vamh5cWWhGVDdGHhal3b9HtQSvqo9MJGC6v0kzlbbW3UbWWdGDXsRRQw5qMEv0kzlbbW3UbW5zTQy9jprE0R6PJelcGVNlaNN1QkBfKtV5iiNEf08fp6fGVDdGZZAvLTcYP3CeKtV6PJelcGVhGHVIpa4B3ay6UZqtJGudWPrVp8Kazs9bYt9IgcGtaWSUTqDQvnaNg9(WtcKj1hip1lAidhaF4NCA(IQNosSia(EaMpa4Ra4eaCEwRkwFYtKh9QMAaCca(AagEaSW8OxfI1pBqrPtSPhlmaobadpawyE0RsdUVZwb5QynvBaBWb4eaCEwRQbs8yHzMAQPgaF7galmp6vHy9Zguu6eB6XcdGtaW5zTQgA3G8Ne(vqDQfGtaWxdW5zTQgiXJfMzQPG6ulaF7gal3b9HtQSvqo9MJGC6v0kzlbbWxbW3UbWYDqF4KkBfKtV5iiNEfTs2sqaCca2flTUQALdz6vrRKTeeaNaGfMh9Q0G77SvqUkwt1gWgCaobaNN1QAGepwyMPMcQtTaCcaopRv1q7gK)KWVcQtTa8vf9jImDTAGXGkJMCrxyE0BrVgpzYwb5fVmAYxSmwrNwjBjOYif9jImPgclzycYJfwz0Kl6SpC6dPOdpawUd6dNuzRGC6nhb50ROvYwccGtaWxdWcZdEKHw6eecGVNlalmp4rgO2vbSnCcGVDdGHhaZ62c1PwL2qtBKUPALdHupjqWbWxbWjay4bWSEHMHRITs)kwdtqmbIu0kzlbbWjay2G8WieaZrUaCYaCcaopRvfRp5jYJEvtnaobadpaopRvvnEc59FupjmhGtaWWdGZZAvn0Ub5pj8REsyoaNaGhA3G8Ne(ninYArMynvBaBWb4Xb48SwvdK4XcZm1upjmhGVhGVyrFIitxRgymOYOjx0fMh9w0RXtMSvqEXlJMmhugROtRKTeuzKI(erMudHLmmb5XcRmAYfD2ho9Hu0Hhal3b9HtQSvqo9MJGC6v0kzlbbWja4RbyH5bpYqlDccbW3ZfGfMh8idu7Qa2gobW3UbWWdGzDBH6uRsBOPns3uTYHqQNei4a4Ra4eamRxOz4QyR0VI1WeetGifTs2sqaCcaMnipmcbWCKlaNmaNaGVgGVgGfMh9QQXtMSvqUInipmczQVW8OxXcWJdWxdW8KpKSLuu6oTqeKH1N8e5rVMNosSiaoTa48SwvXwPFfRHjiMarkO5lE0laFfaFjaZ62c1PwvnEYKTcYvqZx8OxaoTayEYhs2skkDNwicYW6tEI8OxZthjweaFjaFnaNN1Qk2k9RynmbXeisbnFXJEb40cGHXGuhjDa(ka(kaMJCby4dW3UbW8KpKSLuu6oTqeKH1N8e5rVMNosSia(EUaCEwRQyR0VI1WeetGif08fp6fGVDdGZZAvfBL(vSgMGycePE6iXIa47byymi1rshGVDdGzDBH6uRcnevpwygTof9QNei4a4eamp5djBjfRp5jYJEnOHO6XcZO1POhGVcGtaW5zTQy9jprE0RAQbWja4Rby4bW5zTQQXtiV)J6jH5a8TBaCEwRQyR0VI1WeetGi1thjweaFpadFfFaWxbWjay4bW5zTQgA3G8Ne(vpjmhGtaWdTBq(tc)gKgzTitSMQnGn4a84aCEwRQbs8yHzMAQNeMdW3dWxSOprKPRvdmguz0Kl6cZJEl614jt2kiV4LrtonxgROtRKTeuzKIo7dN(qk6)CPA)WifuGyHMnw5HZW6ZrwifD3zOPrqaCcaopRvfuGyHMnw5HZW6ZrwifuNAb4eaCEwRkOaXcnBSYdNH1NJSqg5zYskOo1cWjayw3wOo1QYZA1afiwOzJvE4mS(CKfs9KabxrxyE0BrN1Z1PhPrwBXlJMmFugROtRKTeuzKIo7dN(qk6)CPA)WifuGyHMnw5HZW6ZrwifD3zOPrqaCcaopRvfuGyHMnw5HZW6ZrwifuNAb4eaCEwRkOaXcnBSYdNH1NJSqg5zYskOo1cWjayw3wOo1QYZA1afiwOzJvE4mS(CKfs9KabxrxyE0BrxEMSKHsxZ2OO3IxgnzoSYyfDALSLGkJu0zF40hsr)Nlv7hgPGcel0SXkpCgwFoYcPO7odnnccGtaW5zTQGcel0SXkpCgwFoYcPG6ulaNaGZZAvbfiwOzJvE4mS(CKfYu)g5kOo1w0fMh9w0RFJ8CB9Ixgnz(0YyfDALSLGkJu0fMh9w0zI1AeMh9ASbYl62a5MvourxyEWJmUyP1rfVmAYPPYyfDALSLGkJu0NiYKAiSKHjipwyLrtUOZ(WPpKIEEwRkwFYtKh9QG6ulaNaGVgG)5s1(HrkOaXcnBSYdNH1NJSqk6UZqtJGayUaCEwRkOaXcnBSYdNH1NJSqQPgaFfaNaGVgGfMh9QoKt9RI1uTbSbhGVDdGfMh9QqS(zdkkDIn9yHbWjayH5rVkeRF2GIsNytNmpDKyra89am8v8baF7galmp6vvJNYI1QO0j20JfgaNaGfMh9QQXtzXAvu6eB6K5PJelcGVhGHVIpa4B3ayH5rVkn4(oBfKRO0j20JfgaNaGfMh9Q0G77SvqUIsNytNmpDKyra89am8v8baFvrFIitxRgymOYOjx0fMh9w0z9jprE0BXlJMmhszSIoTs2sqLrk6cZJEl6mXAncZJEn2a5fD2ho9Hu0ZZAvX6tEI8OxLvqUHsxlEcGVNlalmp6vX6tEI8OxLvqUzIiOIUnqUzLdv0z9jprE0RH1TfQtTOIxg9IWVmwrNwjBjOYifD2ho9Hu0VgGZZAvn0Ub5pj8REsyoaF7gaNN1QQgpH8(pQNeMdWxbWjayH5bpYqlDccbWCKlaZt(qYwsX6tEI8Oxt1khc5FWpv0fMh9w0Rw5qi)d(PIxg9IjxgROtRKTeuzKIo7dN(qk65zTQqZ1WFSWqMSLqOyHzEsGGtn1a4eaCEwRk0Cn8hlmKjBjekwyMNei4upDKyramhbyMGCJhhQOlmp6TORb33zRG8Ixg9IxSmwrNwjBjOYifD2ho9Hu0ZZAvvJNqE)h1tcZl6cZJEl6AW9D2kiV4LrVihugROtRKTeuzKIo7dN(qk65zTQ0G7BMvqh1tcZb4eaCEwRkn4(Mzf0r90rIfbWCeGzcYnECiaobaFnaNN1QI1N8e5rVQNosSiaMJamtqUXJdbW3UbW5zTQy9jprE0RcQtTa8vfDH5rVfDn4(oBfKx8YOxmnxgROtRKTeuzKIo7dN(qk65zTQgA3G8Ne(vpjmhGtaW5zTQy9jprE0RAQv0fMh9w01G77SvqEXlJEr(OmwrNwjBjOYifD2ho9Hu01EINbgdsLScX6NnaWja48SwvdK4XcZm1upjmVOlmp6TORb33zRG8Ixg9ICyLXk6X60)tn3e1IUW8OxvnEYKTcYvSb5HriUcZJEv14jt2kixDK0nSb5HrOIoTs2sqLrk6cZJEl6OHO6XcZO1POVOZ(WPpKIEEwRkwFYtKh9QMAaCcagEaSW8OxvnEYKTcYvSb5HriaobaZt(qYwsX6tEI8OxdAiQESWmADk6lEz0lYNwgROtRKTeuzKIo7dN(qk65zTQy9jprE0RAQbWja4Rb4RbyH5rVQA8KjBfKRydYdJqa89aCYaCca2flTUsdUVzwbDu0kzlbbWjayH5bpYqlDccbWCb4Kb4Ra4B3ay4bWUyP1vAW9nZkOJIwjBjia(2nawyEWJm0sNGqamhb4Kb4Rk6cZJEl6AdnTr6MQvoeQ4LrVyAQmwrNwjBjOYifD2ho9Hu0ZZAvX6tEI8OxfuNAb4eamRBluNAvS(KNip6v90rIfbW3dWmb5gpoeaNaGHhaZ6fAgUQALdzeg7jp6vrRKTeurxyE0BrVgpLfRT4LrVihszSIoTs2sqLrk6SpC6dPONN1QI1N8e5rVQNosSiaMJamtqUXJdbWja48SwvS(KNip6vn1a4B3a48SwvS(KNip6vb1PwaobaZ62c1PwfRp5jYJEvpDKyra89amtqUXJdv0fMh9w0rS(zdfVmkha)YyfDALSLGkJu0zF40hsrppRvfRp5jYJEvpDKyra89ammgK6iPdWjayH5bpYqlDccbWCeGtUOlmp6TOBdEXcZK7tU4Lr5GKlJv0PvYwcQmsrN9HtFif98SwvS(KNip6v90rIfbW3dWWyqQJKoaNaGZZAvX6tEI8Ox1uROlmp6TOd9cSErM8tIpu8YOCWflJv0PvYwcQmsrN9HtFifDxEyKRgiX6dknMdW3ZfG5a4dWjayxS06kejFSWmEpzdkALSLGk6cZJEl6iw)SHIx8IoevLP1lJvgn5YyfDALSLGkJu0zF40hsrhEa8pxQ2pmsbfiwOzJvE4mS(CKfsr3DgAAeurxyE0BrN1Z1PhPrwBXlJEXYyfDALSLGkJu0BTIoI8IUW8O3Iop5djBPIopXoPIUlwADvnEc5Y70ROvYwccG5BaUgpHC5D6vpDKyra84a81amRBluNAvS(KNip6v90rIfbW8naFnaNmaNwamp5djBjf)XczJfM5jOjZJEby(gGDXsRR4pwiBSWu0kzlbbWxbWxbW8nadpaM1TfQtTkwFYtKh9QEsGGdG5BaopRvfRp5jYJEvqDQTOZtEZkhQO7XHmEBy9jprE0BXlJYbLXk60kzlbvgPO3Af9JKErxyE0BrNN8HKTurNNyNurNN8HKTKIoAW9Kyn9dTYYidezf4a40cGVgGzDBH6uRIoAW9Kyn9dTYYif08fp6fGtlaM1TfQtTk6Ob3tI10p0klJupDKyra8vamFdWWdGzDBH6uRIoAW9Kyn9dTYYi1tceCfDEYBw5qfDpoKXBdRp5jYJEl6SpC6dPOt3DgAAeKIoAW9Kyn9dTYYOIxgnnxgROtRKTeuzKIo7dN(qk65zTQy9jprE0RcQtTaCcaopRv1pxY0vJwNIEfuNAb4eamRBluNAvS(KNip6v90rIfbWCeGHFrxyE0BrhnevpwygTof9fVmkFugROtRKTeuzKIo7dN(qk6xdW5zTQy9jprE0RcQtTaCcaopRv1pxY0vJwNIEfuNAb4ea81amRBluNAvS(KNip6v90rIfbW3dWu6eB6KXJdbW3UbWSUTqDQvX6tEI8Ox1thjweaZraM1TfQtTQxGczDdstE(vqZx8Oxa(ka(ka(2na(AaopRv1pxY0vJwNIE1udGtaWSUTqDQvX6tEI8Ox1thjweaZraMdGpaFvrxyE0Br)fOqw3G0KN)IxgLdRmwrNwjBjOYifD2ho9Hu0ZZAvX6tEI8OxfuNAb4eaCEwRQFUKPRgTof9kOo1cWjayw3wOo1Qy9jprE0R6PJelcGVhGP0j20jJhhQOlmp6TOdrIpK7FPIxgLpTmwrNwjBjOYifD2ho9Hu0ZZAvX6tEI8OxfuNAb4eameLN1Q6fOqw3G0KNFdVPDPxYHnC4uqDQTOlmp6TOFI)73ehbgv8YOPPYyfDALSLGkJu0zF40hsrNN8HKTKYJdz82W6tEI8OxaMJaSW8OxdRBluNAb40cG5JIUW8O3IomRafI3pYKfiyurNQvI5MvourhMvGcX7hzYcemQ4Lr5qkJv0PvYwcQmsrFLdv0PJgCpjwt)qRSmQOlmp6TOthn4EsSM(HwzzurN9HtFifDEYhs2skpoKXBdRp5jYJEb475cW8KpKSLu0rdUNeRPFOvwgzGiRaxXlJMm8lJv0PvYwcQmsrFLdv0r90AcyB40x0fMh9w0r90AcyB40x0zF40hsrNN8HKTKYJdz82W6tEI8OxaMJCbyEYhs2sQEntezytVR1Ixgn5KlJv0PvYwcQmsrFLdv0HzHtBW0vJGqXjSIh9w0fMh9w0HzHtBW0vJGqXjSIh9w0zF40hsrNN8HKTKYJdz82W6tEI8OxaMJCbyEYhs2sQEntezytVR1Ixgn5lwgROtRKTeuzKI(khQOFeMKFYGgiYnNjkyfDH5rVf9JWK8tg0arU5mrbROZ(WPpKIop5djBjLhhY4TH1N8e5rVa89Cby(O4LrtMdkJv0PvYwcQmsrFLdv0HEsGQXtgEecr2IUW8O3Io0tcunEYWJqiYw0zF40hsrNN8HKTKYJdz82W6tEI8OxaMJCbyEYhs2sQEntezytVR1Ixgn50CzSIoTs2sqLrk6RCOIUChOb5fKP2RB6QrRtrFrxyE0BrxUd0G8cYu71nD1O1POVOZ(WPpKIop5djBjLhhY4TH1N8e5rVa89Cby(aGhhGtMpay(gG5jFizlPQ96gOEMTKPxZeraCcaMN8HKTKYJdz82W6tEI8OxaMJam8lEz0K5JYyfDALSLGkJu0zF40hsr)AaMN8HKTKYJdz82W6tEI8Oxa(Eaoz4dW3UbW1a2GBE6iXIa47byEYhs2skpoKXBdRp5jYJEb4Rk6cZJEl6WMYdfYA6QrUd6BFO4LrtMdRmwrxyE0BrN1lJw)fNGmvRCOIoTs2sqLrkEz0K5tlJv0fMh9w0Fs0IfMPALdHk60kzlbvgP4LrtonvgROlmp6TOxB2erqg5oOpCYKj5u0PvYwcQmsXlJMmhszSIUW8O3IU28JkCXcZKTcYl60kzlbvgP4LrVi8lJv0fMh9w0)qtZsMyninHrfDALSLGkJu8YOxm5YyfDH5rVfDFGmZn3ZfYu7NrfDALSLGkJu8YOx8ILXk60kzlbvgPOZ(WPpKI(pxQ2pmsbfiwOzJvE4mS(CKfsr3DgAAeeaNaGzDBH6uRkpRvduGyHMnw5HZW6Zrwi1tceCaCcaopRvfuGyHMnw5HZW6ZrwiJ8mzjfuNAb4eamRBluNAvS(KNip6v90rIfbWCeG5a4dWjay4bW5zTQGcel0SXkpCgwFoYcPMAfDH5rVfDwpxNEKgzTfVm6f5GYyfDALSLGkJu0zF40hsr)Nlv7hgPGcel0SXkpCgwFoYcPO7odnnccGtaWSUTqDQvLN1QbkqSqZgR8Wzy95ilK6jbcoaobaNN1QckqSqZgR8Wzy95ilKrEMSKcQtTaCcaM1TfQtTkwFYtKh9QE6iXIayocWCa8b4eam8a48SwvqbIfA2yLhodRphzHutTIUW8O3IU8mzjdLUMTrrVfVm6ftZLXk60kzlbvgPOZ(WPpKI(pxQ2pmsbfiwOzJvE4mS(CKfsr3DgAAeeaNaGzDBH6uRkpRvduGyHMnw5HZW6Zrwi1tceCaCcaopRvfuGyHMnw5HZW6Zrwit9BKRG6ulaNaGzDBH6uRI1N8e5rVQNosSiaMJamhaFaobadpaopRvfuGyHMnw5HZW6Zrwi1uROlmp6TOx)g5526fVm6f5JYyfDALSLGkJu0zF40hsrppRv1pxY0vJwNIEfuNAb4eam8a48Swv14jK3)r9KWCaobaFnaZt(qYws5XHmEBy9jprE0laZraopRv1pxY0vJwNIEf08fp6fGtaW8KpKSLuECiJ3gwFYtKh9cWCeGfMh9QQXtMSvqUQoTwZtSb5HrgpoeaF7gaZt(qYws5XHmEBy9jprE0laZraUgWgCZthjweaFvrxyE0Br)Nlz6QrRtrFXlJEroSYyfDALSLGkJu0fMh9w0zI1AeMh9ASbYl6SpC6dPOZt(qYws5XHmEBy9jprE0laFpxag(fDBGCZkhQOZ6tEI8OxJ2GGOIxg9I8PLXk60kzlbvgPO3AfDe5fDH5rVfDEYhs2sfDEIDsfDEYhs2skpoKXBdRp5jYJEb47byH5rVQA8KjBfKRQtR18eBqEyKXJdbWPfaZt(qYwsHgIQhlmJwNIEZtqtMh9cW8naFnaZ62c1PwfAiQESWmADk6vpDKyra89amp5djBjLhhY4TH1N8e5rVa8vaCcaMN8HKTKYJdz82W6tEI8Oxa(EaUgWgCZthjweaF7ga7ILwx9ZLmD1O1POxrRKTeeaNaGZZAv9ZLmD1O1POxb1PwaobaZ62c1Pw1pxY0vJwNIE1thjweaFpalmp6vvJNmzRGCvDATMNydYdJmECiaoTayEYhs2sk0qu9yHz06u0BEcAY8OxaMVb4Rbyw3wOo1Qqdr1JfMrRtrV6PJelcGVhGzDBH6uR6Nlz6QrRtrV6PJelcGVcGtaWSUTqDQv9ZLmD1O1POx90rIfbW3dW1a2GBE6iXIk68K3SYHk614jt2ki3O1TnwyfVm6fttLXk60kzlbvgPO3AfDe5fDH5rVfDEYhs2sfDEIDsfDEYhs2skpoKXBdRp5jYJEb47byH5rVkTHM2iDt1khcPQtR18eBqEyKXJdbWPfaZt(qYwsHgIQhlmJwNIEZtqtMh9cW8naFnaZ62c1PwfAiQESWmADk6vpDKyra89amp5djBjLhhY4TH1N8e5rVa8vaCcaMN8HKTKYJdz82W6tEI8Oxa(EaUgWgCZthjweaF7ga)ZLQ9dJuO5A4pwyit2siuSWu0DNHMgbv05jVzLdv01gAAJ0nADBJfwXlJEroKYyfDALSLGkJu0fMh9w0zI1AeMh9ASbYl6SpC6dPONN1Q6Nlz6QrRtrVAQbWja4RbyEYhs2skpoKXBdRp5jYJEbyocWWhGVQOBdKBw5qf9V1mAdcIkEzuoa(LXk60kzlbvgPO3AfDe5fDH5rVfDEYhs2sfDEIDsfDEYhs2skpoKXBdRp5jYJEb47byH5rVkTHM2iDt1khcPQtR18eBqEyKXJdbWjayEYhs2skpoKXBdRp5jYJEb47b4AaBWnpDKyra8TBa8pxQ2pmsHMRH)yHHmzlHqXctr3DgAAeurNN8MvourxBOPns3O1TnwyfVmkhKCzSIoTs2sqLrk6tezsnewYWeKhlSYOjx0zF40hsrhEamp5djBjvnEYKTcYnADBJfgaNaGVgG5jFizlP84qgVnS(KNip6fG5iadFa(2nawyEWJm0sNGqamh5cW8KpKSLudYdzycYnvRCiK)b)eaNaGHhaxJNqU8o9kH5bpcGtaWWdGZZAvn0Ub5pj8REsyoaNaGVgGZZAvnqIhlmZut9KWCaobalmp6vvTYHq(h8tkkDInDY80rIfbW3dWWxXha8TBamBqEyeYuFH5rVIfG5ixa(Ia8va8vf9jImDTAGXGkJMCrxyE0BrVgpzYwb5fVmkhCXYyfDALSLGkJu0NiYKAiSKHjipwyLrtUOZ(WPpKIEnEc5Y70ReMh8iaobaZgKhgHayoYfGtgGtaWWdG5jFizlPQXtMSvqUrRBBSWa4ea81am8ayH5rVQA8uwSwfLoXMESWa4eam8ayH5rVkn4(oBfKRI1uTbSbhGtaW5zTQgiXJfMzQPEsyoaF7galmp6vvJNYI1QO0j20JfgaNaGHhaNN1QAODdYFs4x9KWCa(2nawyE0RsdUVZwb5QynvBaBWb4eaCEwRQbs8yHzMAQNeMdWjay4bW5zTQgA3G8Ne(vpjmhGVQOprKPRvdmguz0Kl6cZJEl614jt2kiV4Lr5aoOmwrNwjBjOYifDH5rVfDMyTgH5rVgBG8Io7dN(qk6xdW8KpKSLuECiJ3gwFYtKh9cWCeGHpaFfaNaGZZAv9ZLmD1O1POxb1P2IUnqUzLdv0rUSqYdz(2fp6T4fVO)TMrBqquzSYOjxgROtRKTeuzKIo7dN(qk6cZdEKHw6eecG5ixaMN8HKTKAODdYFs43uTYHq(h8taCca(AaopRv1q7gK)KWV6jH5a8TBaCEwRQA8eY7)OEsyoaFvrxyE0BrVALdH8p4NkEz0lwgROtRKTeuzKIo7dN(qk65zTQqZ1WFSWqMSLqOyHzEsGGtn1a4eaCEwRk0Cn8hlmKjBjekwyMNei4upDKyramhbyMGCJhhQOlmp6TORb33zRG8IxgLdkJv0PvYwcQmsrN9HtFif98Swv14jK3)r9KW8IUW8O3IUgCFNTcYlEz00CzSIoTs2sqLrk6SpC6dPONN1QAODdYFs4x9KW8IUW8O3IUgCFNTcYlEzu(OmwrNwjBjOYif9jImPgclzycYJfwz0Kl6SpC6dPOdpaMN8HKTKQgpzYwb5gTUTXcdGtaW5zTQqZ1WFSWqMSLqOyHzEsGGtb1Pwaobalmp4rgAPtqia(EaMN8HKTKAqEidtqUPALdH8p4Na4eam8a4A8eYL3Pxjmp4raCca(AagEaCEwRQbs8yHzMAQNeMdWjay4bW5zTQgA3G8Ne(vpjmhGtaWWdG1EINPRvdmgKQgpzYwb5aCca(AawyE0RQgpzYwb5k2G8WieaZrUa8fb4B3a4RbyxS06kXsPJ8xq3HGm15dNIwjBjiaobaZ62c1Pwf0lW6fzYpj(G6jbcoa(ka(2na(Aa2flTUcrYhlmJ3t2GIwjBjiaoba7YdJC1ajwFqPXCa(EUamhaFa(ka(ka(QI(erMUwnWyqLrtUOlmp6TOxJNmzRG8IxgLdRmwrNwjBjOYif9jImPgclzycYJfwz0Kl6SpC6dPOdpaMN8HKTKQgpzYwb5gTUTXcdGtaWWdGRXtixENELW8GhbWja4Rb4Rb4RbyH5rVQA8uwSwfLoXMESWa4ea81aSW8OxvnEklwRIsNytNmpDKyra89am8v8baF7gadpa(Nlv7hgPQXtiV)JIU7m00iia(ka(2nawyE0RsdUVZwb5kkDIn9yHbWja4RbyH5rVkn4(oBfKRO0j20jZthjweaFpadFfFaW3UbWWdG)5s1(HrQA8eY7)OO7odnnccGVcGVcGtaW5zTQgiXJfMzQPEsyoaFfaF7gaFna7ILwxHi5JfMX7jBqrRKTeeaNaGD5HrUAGeRpO0yoaFpxaMdGpaNaGVgGZZAvnqIhlmZut9KWCaobadpawyE0RcX6NnOO0j20JfgaF7gadpaopRv1q7gK)KWV6jH5aCcagEaCEwRQbs8yHzMAQNeMdWjayH5rVkeRF2GIsNytpwyaCcagEa8q7gK)KWVbPrwlYeRPAdydoaFfaFfaFvrFIitxRgymOYOjx0fMh9w0RXtMSvqEXlJYNwgROtRKTeuzKIUW8O3IotSwJW8OxJnqEr3gi3SYHk6cZdEKXflToQ4LrttLXk60kzlbvgPOZ(WPpKIEEwRkn4(Mzf0r9KWCaobaZeKB84qa89aCEwRkn4(Mzf0r90rIfbWjayMGCJhhcGVhGZZAv9ZLmD1O1POx90rIfv0fMh9w01G77SvqEXlJYHugROtRKTeuzKIo7dN(qk6ApXZaJbPswHy9Zga4eaCEwRQbs8yHzMAQNeMdWjayxS06kejFSWmEpzdkALSLGa4eaSlpmYvdKy9bLgZb475cWCa8b4eaSW8GhzOLobHa47byEYhs2sQH2ni)jHFt1khc5FWpv0fMh9w01G77SvqEXlJMm8lJv0PvYwcQmsrN9HtFifD4bW8KpKSLuAdnTr6gTUTXcdGtaW5zTQgiXJfMzQPEsyoaNaGHhaNN1QAODdYFs4x9KWCaobaFnalmp4rgO2vbSnCcGVhGViaF7galmp4rgAPtqiaMJCbyEYhs2sQb5Hmmb5MQvoeY)GFcGVDdGfMh8idT0jieaZrUamp5djBj1q7gK)KWVPALdH8p4Na4Rk6cZJEl6AdnTr6MQvoeQ4Lrto5YyfDALSLGkJu0zF40hsr3Lhg5QbsS(GsJ5a89Cbyoa(aCca2flTUcrYhlmJ3t2GIwjBjOIUW8O3IoI1pBO4Lrt(ILXk60kzlbvgPOZ(WPpKIUW8GhzOLobHayoYfG5jFizlPKNjlzO01Snk6fGtaWhzfLgZbyoYfG5jFizlPKNjlzO01Snk61CKvk6cZJEl6YZKLmu6A2gf9w8YOjZbLXk60kzlbvgPOZ(WPpKIUW8GhzOLobHayoYfG5jFizlPgKhYWeKBQw5qi)d(PIUW8O3IE1khc5FWpv8YOjNMlJv0fMh9w0RXtzXAl60kzlbvgP4fVOZ6tEI8OxdRBluNArLXkJMCzSIUW8O3IUw7rVfDALSLGkJu8YOxSmwrxyE0BrpB7gYuNpCfDALSLGkJu8YOCqzSIUW8O3IEMEe98hlSIoTs2sqLrkEz00CzSIUW8O3IEnEkB7gQOtRKTeuzKIxgLpkJv0fMh9w0LLri)fRHjwBrNwjBjOYifVmkhwzSIUW8O3I(erMWPdQOtRKTeuzKIxgLpTmwrNwjBjOYifDH5rVfDywbkeVFKjlqWOI(erMUwnWyqLrtUOZ(WPpKIUW8Ox1HCQFvSMQnGn4a8TBamRBluNAvhYP(vpDKyramhb4KHFrNQvI5MvourhMvGcX7hzYcemQ4LrttLXk60kzlbvgPOZ(WPpKI(pxQ2pms50rRFXAsjVMIU7m00iiaobaNN1QIsFqMip6vn1k6cZJEl6ECitk51kEXl6cZdEKXflToQmwz0KlJv0PvYwcQmsrN9HtFifDH5bpYqlDccbWCeGtgGtaW5zTQy9jprE0RcQtTaCca(AaMN8HKTKYJdz82W6tEI8OxaMJamRBluNAv2GxSWm5(KvqZx8Oxa(2naMN8HKTKYJdz82W6tEI8Oxa(EUam8b4Rk6cZJEl62GxSWm5(KlEz0lwgROtRKTeuzKIo7dN(qk68KpKSLuECiJ3gwFYtKh9cW3ZfGHpaF7gaFnaZ62c1Pw1HCQFf08fp6fGVhG5jFizlP84qgVnS(KNip6fGtaWWdGDXsRR(5sMUA06u0ROvYwccGVcGVDdGDXsRR(5sMUA06u0ROvYwccGtaW5zTQ(5sMUA06u0RMAaCcaMN8HKTKYJdz82W6tEI8OxaMJaSW8Ox1HCQFfRBluNAb4B3a4AaBWnpDKyra89amp5djBjLhhY4TH1N8e5rVfDH5rVf9d5u)fVmkhugROtRKTeuzKIo7dN(qk6UyP1vILsh5VGUdbzQZhofTs2sqaCca(AaopRvfRp5jYJEvqDQfGtaWWdGZZAvn0Ub5pj8REsyoaFvrxyE0Brh6fy9Im5NeFO4fVOJCzHKhY8TlE0BzSYOjxgROtRKTeuzKIo7dN(qk6cZdEKHw6eecG5ixaMN8HKTKAODdYFs43uTYHq(h8taCca(AaopRv1q7gK)KWV6jH5a8TBaCEwRQA8eY7)OEsyoaFvrxyE0BrVALdH8p4NkEz0lwgROtRKTeuzKIo7dN(qk65zTQQXtiV)J6jH5fDH5rVfDn4(oBfKx8YOCqzSIoTs2sqLrk6SpC6dPONN1QAODdYFs4x9KWCaobaNN1QAODdYFs4x90rIfbW3dWcZJEv14PSyTkkDInDY4XHk6cZJEl6AW9D2kiV4LrtZLXk60kzlbvgPOZ(WPpKIEEwRQH2ni)jHF1tcZb4ea81aS2t8mWyqQKv14PSyTa8TBaCnEc5Y70ReMh8ia(2nawyE0RsdUVZwb5QynvBaBWb4Rk6cZJEl6AW9D2kiV4Lr5JYyfDALSLGkJu0zF40hsrppRvfAUg(JfgYKTecflmZtceCQPgaNaGVgGzDBH6uR6Nlz6QrRtrV6PJelcGhhGfMh9Q(5sMUA06u0RO0j20jJhhcGhhGzcYnECiaMJaCEwRk0Cn8hlmKjBjekwyMNei4upDKyra8TBam8ayxS06QFUKPRgTof9kALSLGa4Ra4eamp5djBjLhhY4TH1N8e5rVa84amtqUXJdbWCeGZZAvHMRH)yHHmzlHqXcZ8KabN6PJelQOlmp6TORb33zRG8IxgLdRmwrNwjBjOYifD2ho9Hu0ZZAvn0Ub5pj8REsyoaNaGD5HrUAGeRpO0yoaFpxaMdGpaNaGDXsRRqK8XcZ49KnOOvYwcQOlmp6TORb33zRG8IxgLpTmwrNwjBjOYifD2ho9Hu0ZZAvPb33mRGoQNeMdWjayMGCJhhcGVhGZZAvPb33mRGoQNosSOIUW8O3IUgCFNTcYlEz00uzSIoTs2sqLrk6tezsnewYWeKhlSYOjx0zF40hsrhEaCnEc5Y70ReMh8iaobadpaMN8HKTKQgpzYwb5gTUTXcdGtaWxdWxdWxdWcZJEv14PSyTkkDIn9yHbWja4RbyH5rVQA8uwSwfLoXMozE6iXIa47by4R4da(2nagEa8pxQ2pmsvJNqE)hfD3zOPrqa8va8TBaSW8OxLgCFNTcYvu6eB6XcdGtaWxdWcZJEvAW9D2kixrPtSPtMNosSia(Eag(k(aGVDdGHha)ZLQ9dJu14jK3)rr3DgAAeeaFfaFfaNaGZZAvnqIhlmZut9KWCa(ka(2na(Aa2flTUcrYhlmJ3t2GIwjBjiaoba7YdJC1ajwFqPXCa(EUamhaFaobaFnaNN1QAGepwyMPM6jH5aCcagEaSW8OxfI1pBqrPtSPhlma(2nagEaCEwRQH2ni)jHF1tcZb4eam8a48SwvdK4XcZm1upjmhGtaWcZJEviw)SbfLoXMESWa4eam8a4H2ni)jHFdsJSwKjwt1gWgCa(ka(ka(QI(erMUwnWyqLrtUOlmp6TOxJNmzRG8IxgLdPmwrNwjBjOYifD2ho9Hu01EINbgdsLScX6NnaWja48SwvdK4XcZm1upjmhGtaWUyP1vis(yHz8EYgu0kzlbbWjayxEyKRgiX6dknMdW3ZfG5a4dWjayH5bpYqlDccbW3dW8KpKSLudTBq(tc)MQvoeY)GFQOlmp6TORb33zRG8Ixgnz4xgROtRKTeuzKIo7dN(qk6WdG5jFizlP0gAAJ0nADBJfgaNaGVgGHha7ILwxv)(y8bYiObcPOvYwccGVDdGfMh8idT0jieaZraoza(kaobaFnalmp4rgAPtqiaMJaCYaCcawyEWJmqTRcyB4eaFpaFra(2nawyEWJm0sNGqamh5cW8KpKSLudYdzycYnvRCiK)b)eaF7galmp4rgAPtqiaMJCbyEYhs2sQH2ni)jHFt1khc5FWpbWxv0fMh9w01gAAJ0nvRCiuXlJMCYLXk60kzlbvgPOlmp6TOZeR1imp61ydKx0TbYnRCOIUW8GhzCXsRJkEz0KVyzSIoTs2sqLrk6SpC6dPOlmp4rgAPtqiaMJaCYfDH5rVfDOxG1lYKFs8HIxgnzoOmwrNwjBjOYifD2ho9Hu0D5HrUAGeRpO0yoaFpxaMdGpaNaGDXsRRqK8XcZ49KnOOvYwcQOlmp6TOJy9ZgkEz0KtZLXk60kzlbvgPOZ(WPpKIUW8GhzOLobHayoYfG5jFizlPKNjlzO01Snk6fGtaWhzfLgZbyoYfG5jFizlPKNjlzO01Snk61CKvk6cZJEl6YZKLmu6A2gf9w8YOjZhLXk60kzlbvgPOZ(WPpKIUW8GhzOLobHayoYfG5jFizlPgKhYWeKBQw5qi)d(PIUW8O3IE1khc5FWpv8YOjZHvgROlmp6TOxJNYI1w0PvYwcQmsXlJMmFAzSIUW8O3IoI1pBOOtRKTeuzKIx8IU2tS(KfVmwz0KlJv0fMh9w0LNjlzI1jRLyErNwjBjOYifVm6flJv0PvYwcQmsrV1k6iYl6cZJEl68KpKSLk68e7Kk6xeG5Ba2flTUQALdz0eNnOOvYwccGhhG5aaMVby4bWUyP1vvRCiJM4SbfTs2sqfDEYBw5qf9H2ni)jHFt1khc5FWpv0zF40hsrNN8HKTKAODdYFs43uTYHq(h8tamxag(fVmkhugROtRKTeuzKIERv0rKx0fMh9w05jFizlv05j2jv0ViaZ3aSlwADv1khYOjoBqrRKTeeapoaZbamFdWWdGDXsRRQw5qgnXzdkALSLGk68K3SYHk6dYdzycYnvRCiK)b)urN9HtFifDEYhs2sQb5Hmmb5MQvoeY)GFcG5cWWV4LrtZLXk60kzlbvgPO3AfDe5fDH5rVfDEYhs2sfDEIDsfDoaG5Ba2flTUQALdz0eNnOOvYwccGhhG5Way(gGHha7ILwxvTYHmAIZgu0kzlbv05jVzLdv0z9jprE0RPALdH8p4Nk6SpC6dPOZt(qYwsX6tEI8Oxt1khc5FWpbWCby4x8YO8rzSIoTs2sqLrk6TwrhrErxyE0BrNN8HKTurNNyNurNdHdbG5Ba2flTUQALdz0eNnOOvYwccGhhGViaZ3am8ayxS06QQvoKrtC2GIwjBjOIop5nRCOIU8mzjdLUMTrrVfD2ho9Hu05jFizlPKNjlzO01Snk6fG5cWWV4Lr5WkJv0PvYwcQmsrV1k6pHiVOlmp6TOZt(qYwQOZtEZkhQOlptwYqPRzBu0R5iRu0HOQmTErpnd)IxgLpTmwrNwjBjOYif9wRO)eI8IUW8O3Iop5djBPIop5nRCOIoezf4mvRCiK)b)urhIQY06fD4x8YOPPYyfDALSLGkJu0BTI(tiYl6cZJEl68KpKSLk68K3SYHk68hlKnwyMNGMmp6TOdrvzA9Io8vP5IxgLdPmwrNwjBjOYif9wROJiVOlmp6TOZt(qYwQOZtStQOlmp6vHgIQhlmJwNIEfd6l68K3SYHk6OHO6XcZO1PO38e0K5rVfD2ho9Hu0znpAL1vBaBWnvHkEz0KHFzSIoTs2sqLrk6TwrhrErxyE0BrNN8HKTurNNyNurNpk68K3SYHk6i(ZgO5lE0BXlJMCYLXk60kzlbvgPO3AfDe5fDH5rVfDEYhs2sfDEIDsfD6UZqtJGuhHj5NmObICZzIcgaF7gat3DgAAeK6iBujK3MUAoc0sieaF7gat3DgAAeKcMvGcX7hzYcemcGVDdGP7odnncsbZkqH49JmhcsS2Oxa(2naMU7m00iivaBdp61CeyeYuNicGVDdGP7odnncs53HSeYKLNFKwSecGVDdGP7odnncsj3X8jFOrguSWiiJMDEeyeaF7gat3DgAAeKswwqRB4FB30vtQab1ha(2naMU7m00iifAOz8NdNEKPklma(2naMU7m00ii1sZxSgeCROHidTdYYOhGVDdGP7odnncsLflvJNm5xw2qrNN8MvourN1N8e5rVMEntev8YOjFXYyfDALSLGkJu0BTIoI8IUW8O3Iop5djBPIopXoPIoD3zOPrqk5oqdYlitTx30vJwNIEaobaZt(qYwsX6tEI8OxtVMjIk68K3SYHk61EDdupZwY0RzIOIxgnzoOmwrNwjBjOYif9wROJiVOlmp6TOZt(qYwQOZtStQOFr4dW8naZt(qYwsX6tEI8OxtVMjIa4Xby(aG5BaMU7m00ii1rys(jdAGi3CMOGv05jVzLdv071mrKHn9UwlEz0KtZLXk60kzlbvgPO3AfDe5fDH5rVfDEYhs2sfDEIDsf9KttfDEYBw5qf9AVUPRgTof9gTNy9jlUHni7s2Io7dN(qk68KpKSLu1EDdupZwY0RzIiaobadpa2flTUQgpHC5D6v0kzlbbWjayEYhs2sQAVUPRgTof9gTNy9jlUHni7swaMlad)Ixgnz(OmwrNwjBjOYif9wRO)eI8IUW8O3Iop5djBPIop5nRCOIoD0G7jXA6hALLrgiYkWv0HOQmTErp50uXlJMmhwzSIoTs2sqLrk6Twr)je5fDH5rVfDEYhs2sfDEYBw5qfDwFYtKh9Aqdr1JfMrRtrFrhIQY06f9KlEz0K5tlJv0PvYwcQmsrFLdv0L7aniVGm1EDtxnADk6l6cZJEl6YDGgKxqMAVUPRgTof9fVmAYPPYyfDH5rVf9t8F)M4iWOIoTs2sqLrkEz0K5qkJv0fMh9w01G77SvqErNwjBjOYifV4fVOZJEu0Bz0lc)lc)Kto50CrpL8BSWqf97e(S0MJYHA07u8jamap2abWXrRFhGR9dW8vTNy9jloFfGF6UZ4jiag1hcGLP3hXjiaMnilmcPajXxglbWCi8ja8f0lp6DccG5RSMhTY6ko0POvYwcIVcWEdW8vwZJwzDfh64Ra81jN(vkqsGKUt4ZsBokhQrVtXNaWa8ydeahhT(DaU2paZxz9jprE0RrBqqeFfGF6UZ4jiag1hcGLP3hXjiaMnilmcPajXxglbWjNmFcaFb9YJENGay94CbamcU1L0b40wa2BaMVCkamuWlqrVaCRrV49dWxF5va81xm9RuGK4lJLa4K5a(ea(c6Lh9obbW6X5cayeCRlPdWPTaS3amF5uayOGxGIEb4wJEX7hGV(YRa4RVy6xPajbsId1rRFNGay(uawyE0laBdKJuGKk6AFxdlv0tda(cJNay(Cbgbskna4b31q8jxEjSWhMzfRpxIIZ0kE0l7LQFjkoSlbjLga8Onp6KPhGtonXjaFr4Fr4dscKuAaWxWGSWieFciP0aGtlaMdhraCnGn4MNosSia(fFGEa2hKfGD5HrUYJdz82afeax7hGTcYtleX6fcGLCydhoaEIeyesbskna40cG5W1GeNayBdlya8t8jamF5KfqaCAJNKdsbskna40cG5l7grlaZeKdWpD3z80HwhbW1(b4lOp5jYJEb4RdfP4eGH6LV6a8qBHa4Wb4A)aSaW1NqdamFo5u)amtq(vkqsPbaNwa8D(kzlbWi)dMdWSbIXFSWa4EbybGRukaU2p)iaowa2hiaMpJVGVeG9gGFcAYiaov)8BBbsbscKuAaW35PtSPtqaCMQ9tamRpzXb4mblwKcG5ZymsZra82BAni)PoTaSW8Oxea3RfofijH5rViL2tS(KfFCUxkptwYeRtwlXCqsPbap2qGayEYhs2samsJyrniea7deaVZtMEaURaSlpmYraS4aCQHGnaWP92byD)jHFa(cTYHq(h8tiaUNokGiaURa8f0N8e5rVamAONwiaota8erqkqscZJErkTNy9jl(4CVKN8HKTeNRCiUdTBq(tc)MQvoeY)GFIZwJlICoJkxEYhs2sQH2ni)jHFt1khc5FWpXf(CYtStI7f5BxS06QQvoKrtC2GIwjBjOX5a(gEUyP1vvRCiJM4SbfTs2sqGKsdaESHabW8KpKSLayKgXIAqia2hiaENNm9aCxbyxEyKJayXb4udbBaGt7YdbWxGGCa(cTYHq(h8tiaUNokGiaURa8f0N8e5rVamAONwiaota8erqaSGa4AyT0Rajjmp6fP0EI1NS4JZ9sEYhs2sCUYH4oipKHji3uTYHq(h8tC2ACrKZzu5Yt(qYwsnipKHji3uTYHq(h8tCHpN8e7K4Er(2flTUQALdz0eNnOOvYwcACoGVHNlwADv1khYOjoBqrRKTeeiP0aGhBiqamp5djBjagPrSOgecG9bcG35jtpa3va2Lhg5iawCao1qWga40E7aSU)KWpaFHw5qi)d(jealpbWtebbWqZpwya8f0N8e5rVkqscZJErkTNy9jl(4CVKN8HKTeNRCiUS(KNip61uTYHq(h8tC2ACrKZzu5Yt(qYwsX6tEI8Oxt1khc5FWpXf(CYtStIlhW3UyP1vvRCiJM4SbfTs2sqJZHX3WZflTUQALdz0eNnOOvYwccKuAaWJneiaMN8HKTeaJ0iwudcbW(abW78KPhG7ka7YdJCealoaNAiydamF2ZKLa47801Snk6fG7PJcicG7kaFb9jprE0laJg6PfcGZeapreKcKKW8OxKs7jwFYIpo3l5jFizlX5khIR8mzjdLUMTrrVC2ACrKZzu5Yt(qYwsjptwYqPRzBu0lx4ZjpXojUCiCi8TlwADv1khYOjoBqrRKTe04xKVHNlwADv1khYOjoBqrRKTeeiP0aGhBiqamp5djBjagPrSOgecG9bcG1ONrRlWiaURa8rwbGZKTtbWPgc2aaZN9mzja(opDnBJIEb4uH1cWB7aCMa4jIGuGKeMh9IuApX6tw8X5Ejp5djBjox5qCLNjlzO01Snk61CKv4eIQY06CtZWNZwJ7tiYbjLga8ydbcG5jFizlbWbcGNiccG9gGrAelQWbW(abWYPNRdWDfG94qaCSamIy9cHayFqCa(mroaRjiealvNEa(c6tEI8OxaMsxlEcbWzQ2pbWxOvoeY)GFcbWPcRfGZeapreeaV9FeRfofijH5rViL2tS(KfFCUxYt(qYwIZvoexiYkWzQw5qi)d(joHOQmTox4ZzRX9je5GKsda(oj8ba(olwiBSW4eGVG(KNip6LVIayw3wOo1cWPcRfGZea)e0KrqaCgoawa4xwO(aWYPNRZjaNNoa7deaVZtMEaURam7dhbWixEhbW8OhoaEiGnaWs1PhGfMh8epwya8f0N8e5rVaSSqamY2PqamuNAbyVtjpecG9bcGPfcG7kaFb9jprE0lFfbWSUTqDQvbW3jd0cWhH)yHbWqelqrViaowa2hiaMpJVGVKta(c6tEI8Ox(kcGF6iXglmaM1TfQtTaCGa4NGMmccGZWbW(qGa46lmp6fG9gGfgRNRdW1(b47SyHSXctbssyE0lsP9eRpzXhN7L8KpKSL4CLdXL)yHSXcZ8e0K5rVCcrvzADUWxLM5S14(eICqsPbap2abWYPNRdWDfGzDBH6ula)e0K5rVaCSamIy9cHayybpAb4mCaSaW1P1cWSbzxYcWDfG1hIQhlmaMVOtrVcGhBGayOmtr1kXCvAkz(GpGphOYcIm8e7KsBtg(Wh(amLU2tiu0ladl4ria2hiaENNm9aCxbyeX6fcbWpDAEeeaNHdGjHnaWEW4hG3(pI1challeaZ6fAgUckqSqZglz6QXhidSV5rkpoKHNyNeadl4ria2hiawGGcp6vSaSaDNEI8dToax)(aW(G4amRxOz4kqsPbalmp6fP0EI1NS4JZ9sEYhs2sCUYH4IgIQhlmJwNIEZtqtMh9YzRXfroN8e7K4MwcZJEvOHO6XcZO1POxrPtSPtgpouARW8OxfAiQESWmADk6vlLY4bJFJhhIVVgkZuuTsmxLMsMp4d4ZbQSGidpXoP02KHp8H)4SEHMHRGcel0SXsMUA8bYa7BEKYJdz4j2jDfNrLlR5rRSUAdydUPkKIwjBjiqscZJErkTNy9jl(4CVKN8HKTeNRCiUOHO6XcZO1PO38e0K5rVC2ACrKZjpXojUcZJEvOHO6XcZO1POxXGEoJkxwZJwzD1gWgCtvifTs2sqGKsdaESbcGHMV4rVaCxbybG1NlaFNflm(kcGhXsiuSWa4lOp5jYJEvGKeMh9IuApX6tw8X5Ejp5djBjox5qCr8NnqZx8OxoBnUiY5KNyNex(aKKW8OxKs7jwFYIpo3l5jFizlX5khIlRp5jYJEn9AMiIZwJlICo5j2jXLU7m00ii1rys(jdAGi3CMOGD7gD3zOPrqQJSrLqEB6Q5iqlHq3Ur3DgAAeKcMvGcX7hzYcem62n6UZqtJGuWScuiE)iZHGeRn692n6UZqtJGubSn8OxZrGritDIOB3O7odnncs53HSeYKLNFKwSe62n6UZqtJGuYDmFYhAKbflmcYOzNhbgD7gD3zOPrqkzzbTUH)TDtxnPceuFUDJU7m00iifAOz8NdNEKPklSB3O7odnncsT08fRbb3kAiYq7GSm6VDJU7m00iivwSunEYKFzzdGKeMh9IuApX6tw8X5Ejp5djBjox5qCR96gOEMTKPxZerC2ACrKZjpXojU0DNHMgbPK7aniVGm1EDtxnADk6tWt(qYwsX6tEI8OxtVMjIajjmp6fP0EI1NS4JZ9sEYhs2sCUYH42RzIidB6DTYzRXfroN8e7K4Er4Z38KpKSLuS(KNip610RzIOX5d(MU7m00ii1rys(jdAGi3CMOGbskna4XgceaZt(qYwcGHiN(tSecGtnqlaZNDhOb5f(kcGVWEDaURamFrNIEaoqa8erqaCMQ9taSpqaS20Ab4OcW5QOQ96MUA06u0B0EI1NS4g2GSlzb4abWB7amsJyrniifijH5rViL2tS(KfFCUxYt(qYwIZvoe3AVUPRgTof9gTNy9jlUHni7swoBnUiY5KNyNe3KttCgvU8KpKSLu1EDdupZwY0RzIOeWZflTUQgpHC5D6v0kzlbLGN8HKTKQ2RB6QrRtrVr7jwFYIBydYUKLl8bjLgaCAVtbW2EHbWzQ2pbWxqFYtKh9cWOHEAHa478JgCpjwaMdThALLraCMa4jIG4qpijH5rViL2tS(KfFCUxYt(qYwIZvoex6Ob3tI10p0klJmqKvGJtiQktRZn50eNTg3NqKdssyE0lsP9eRpzXhN7L8KpKSL4CLdXL1N8e5rVg0qu9yHz06u0ZjevLP15MmNTg3NqKdssyE0lsP9eRpzXhN7LtezcNoCUYH4k3bAqEbzQ96MUA06u0dssyE0lsP9eRpzXhN7LN4)(nXrGrGKeMh9IuApX6tw8X5EPgCFNTcYbjbskna4780j20jiaM4rpCaShhcG9bcGfM3pahiaw4jHvYwsbssyE0lIlRNRtpsJSwoJkx49ZLQ9dJuqbIfA2yLhodRphzHu0DNHMgbbssyE0lACUxYt(qYwIZvoexpoKXBdRp5jYJE5S14IiNtEIDsCDXsRRQXtixENEfTs2sq8DnEc5Y70RE6iXIg)Aw3wOo1Qy9jprE0R6PJelIVVo50IN8HKTKI)yHSXcZ8e0K5rV8TlwADf)XczJfMIwjBjORUIVHhRBluNAvS(KNip6v9KabhFNN1QI1N8e5rVkOo1csknay(CHFcGrZNa4lOp5jYJEb4abWqKvGJGa4OcWlrqeeaNfebbW9cW(abW0rdUNeRPFOvwgzGiRahaZt(qYwcKKW8Ox04CVKN8HKTeNRCiUECiJ3gwFYtKh9YzRX9iPZjpXojU8KpKSLu0rdUNeRPFOvwgzGiRaxADnRBluNAv0rdUNeRPFOvwgPGMV4rVPfRBluNAv0rdUNeRPFOvwgPE6iXIUIVHhRBluNAv0rdUNeRPFOvwgPEsGGJZOYLU7m00iifD0G7jXA6hALLrGKeMh9IgN7LOHO6XcZO1PONZOYnpRvfRp5jYJEvqDQnrEwRQFUKPRgTof9kOo1MG1TfQtTkwFYtKh9QE6iXI4i8bjjmp6fno3lFbkK1nin55NZOY968SwvS(KNip6vb1P2e5zTQ(5sMUA06u0RG6uBIRzDBH6uRI1N8e5rVQNosSO7P0j20jJhh62nw3wOo1Qy9jprE0R6PJelIJSUTqDQv9cuiRBqAYZVcA(Ih9E1v3UDDEwRQFUKPRgTof9QPwcw3wOo1Qy9jprE0R6PJelIJCa8VcKKW8Ox04CVeIeFi3)sCgvU5zTQy9jprE0RcQtTjYZAv9ZLmD1O1POxb1P2eSUTqDQvX6tEI8Ox1thjw09u6eB6KXJdbssyE0lACUxEI)73ehbgXzu5MN1QI1N8e5rVkOo1MaIYZAv9cuiRBqAYZVH30U0l5WgoCkOo1cssyE0lACUxorKjC6WjvReZnRCiUWScuiE)itwGGrCgvU8KpKSLuECiJ3gwFYtKh9Yrw3wOo1Mw8bijH5rVOX5E5erMWPdNRCiU0rdUNeRPFOvwgXzu5Yt(qYws5XHmEBy9jprE079C5jFizlPOJgCpjwt)qRSmYarwboqscZJErJZ9YjImHthox5qCr90AcyB40Zzu5Yt(qYws5XHmEBy9jprE0lh5Yt(qYws1RzIidB6DTcssyE0lACUxorKjC6W5khIlmlCAdMUAeekoHv8OxoJkxEYhs2skpoKXBdRp5jYJE5ixEYhs2sQEntezytVRvqscZJErJZ9YjImHthox5qCpctYpzqde5MZefmoJkxEYhs2skpoKXBdRp5jYJEVNlFassyE0lACUxorKjC6W5khIl0tcunEYWJqiYYzu5Yt(qYws5XHmEBy9jprE0lh5Yt(qYws1RzIidB6DTcssyE0lACUxorKjC6W5khIRChOb5fKP2RB6QrRtrpNrLlp5djBjLhhY4TH1N8e5rV3ZLpgpz(GV5jFizlPQ96gOEMTKPxZerj4jFizlP84qgVnS(KNip6LJWhKKW8Ox04CVe2uEOqwtxnYDqF7dCgvUxZt(qYws5XHmEBy9jprE079jd)B3QbSb380rIfDpp5djBjLhhY4TH1N8e5rVxbssyE0lACUxY6LrR)ItqMQvoeijH5rVOX5E5tIwSWmvRCieijH5rVOX5EzTztebzK7G(WjtMKdijH5rVOX5EP28JkCXcZKTcYbjjmp6fno3l)qtZsMyninHrGKeMh9IgN7L(azMBUNlKP2pJajLga8DkYbyFGayOaXcnBSYdNH1NJSqaCEwRa8uJtaEUwcHaywFYtKh9cWbcGrDVkqscZJErJZ9swpxNEKgzTCgvU)CPA)WifuGyHMnw5HZW6ZrwifD3zOPrqjyDBH6uRkpRvduGyHMnw5HZW6Zrwi1tceCjYZAvbfiwOzJvE4mS(CKfYiptwsb1P2eSUTqDQvX6tEI8Ox1thjweh5a4NaE5zTQGcel0SXkpCgwFoYcPMAGKeMh9IgN7LYZKLmu6A2gf9Yzu5(ZLQ9dJuqbIfA2yLhodRphzHu0DNHMgbLG1TfQtTQ8SwnqbIfA2yLhodRphzHupjqWLipRvfuGyHMnw5HZW6ZrwiJ8mzjfuNAtW62c1PwfRp5jYJEvpDKyrCKdGFc4LN1QckqSqZgR8Wzy95ilKAQbssyE0lACUxw)g5526CgvU)CPA)WifuGyHMnw5HZW6ZrwifD3zOPrqjyDBH6uRkpRvduGyHMnw5HZW6Zrwi1tceCjYZAvbfiwOzJvE4mS(CKfYu)g5kOo1MG1TfQtTkwFYtKh9QE6iXI4iha)eWlpRvfuGyHMnw5HZW6Zrwi1udKKW8Ox04CV8Nlz6QrRtrpNrLBEwRQFUKPRgTof9kOo1MaE5zTQQXtiV)J6jH5jUMN8HKTKYJdz82W6tEI8OxoMN1Q6Nlz6QrRtrVcA(Ih9MGN8HKTKYJdz82W6tEI8Oxokmp6vvJNmzRGCvDATMNydYdJmECOB34jFizlP84qgVnS(KNip6LJ1a2GBE6iXIUcKKW8Ox04CVKjwRryE0RXgiNZvoexwFYtKh9A0geeXzu5Yt(qYws5XHmEBy9jprE079CHpijH5rVOX5Ejp5djBjox5qCRXtMSvqUrRBBSW4KNyNexEYhs2skpoKXBdRp5jYJEVxyE0RQgpzYwb5Q60AnpXgKhgz84qPfp5djBjfAiQESWmADk6npbnzE0lFFnRBluNAvOHO6XcZO1POx90rIfDpp5djBjLhhY4TH1N8e5rVxLGN8HKTKYJdz82W6tEI8O37RbSb380rIfD7MlwAD1pxY0vJwNIEfTs2sqjYZAv9ZLmD1O1POxb1P2eSUTqDQv9ZLmD1O1POx90rIfDVW8OxvnEYKTcYv1P1AEInipmY4XHslEYhs2sk0qu9yHz06u0BEcAY8Ox((Aw3wOo1Qqdr1JfMrRtrV6PJel6Ew3wOo1Q(5sMUA06u0RE6iXIUkbRBluNAv)CjtxnADk6vpDKyr3xdydU5PJelcKKW8Ox04CVKN8HKTeNRCiUAdnTr6gTUTXcJtEIDsC5jFizlP84qgVnS(KNip69EH5rVkTHM2iDt1khcPQtR18eBqEyKXJdLw8KpKSLuOHO6XcZO1PO38e0K5rV891SUTqDQvHgIQhlmJwNIE1thjw098KpKSLuECiJ3gwFYtKh9EvcEYhs2skpoKXBdRp5jYJEVVgWgCZthjw0TB)CPA)WifAUg(JfgYKTecflmfD3zOPrqGKeMh9IgN7LmXAncZJEn2a5CUYH4(TMrBqqeNrLBEwRQFUKPRgTof9QPwIR5jFizlP84qgVnS(KNip6LJW)kqscZJErJZ9sEYhs2sCUYH4Qn00gPB062glmo5j2jXLN8HKTKYJdz82W6tEI8O37fMh9Q0gAAJ0nvRCiKQoTwZtSb5HrgpoucEYhs2skpoKXBdRp5jYJEVVgWgCZthjw0TB)CPA)WifAUg(JfgYKTecflmfD3zOPrqGKsda(ozGwaoTlpetqESWa4l0khcG19p4N4eGVW4jaEeRGCeaJg6PfcGZeapreea7nadJw6fNa40E7aSU)KWpcGLfcG9gGP0DAHa4rScYPhG5ZfKtVcKKW8Ox04CVSgpzYwb5CorKPRvdmge3K5CIitQHWsgMG8yHXnzoJkx4Xt(qYwsvJNmzRGCJw32yHL4AEYhs2skpoKXBdRp5jYJE5i8VDtyEWJm0sNGqCKlp5djBj1G8qgMGCt1khc5FWpLaE14jKlVtVsyEWJsaV8SwvdTBq(tc)QNeMN468SwvdK4XcZm1upjmpHW8Oxv1khc5FWpPO0j20jZthjw09WxXh3UXgKhgHm1xyE0Ry5i3lE1vGKsdaoTX8JfgaFHXtixENEob4lmEcGhXkihbWYta8erqamkoHvElCaS3am08JfgaFb9jprE0RcGVtrl9I1chNaSpqWbWYta8erqaS3ammAPxCcGt7TdW6(tc)iao1aTam7dhbWPcRfG32b4mbWPeKtqaSSqaCQWha4rScYPhG5ZfKtpNaSpqWbWOHEAHa4mbWiTNeiaUNoa7naFKyDjwa2hiaEeRGC6by(Cb50dW5zTQajjmp6fno3lRXtMSvqoNtez6A1aJbXnzoNiYKAiSKHjipwyCtMZOYTgpHC5D6vcZdEuc2G8Wieh5MCc4Xt(qYwsvJNmzRGCJw32yHL4A4jmp6vvJNYI1QO0j20Jfwc4jmp6vPb33zRGCvSMQnGn4jYZAvnqIhlmZut9KW8B3eMh9QQXtzXAvu6eB6Xclb8YZAvn0Ub5pj8REsy(TBcZJEvAW9D2kixfRPAdydEI8SwvdK4XcZm1upjmpb8YZAvn0Ub5pj8REsy(vGKeMh9IgN7LmXAncZJEn2a5CUYH4ICzHKhY8TlE0lNrL718KpKSLuECiJ3gwFYtKh9Yr4FvI8Swv)CjtxnADk6vqDQfKeijH5rViLW8GhzCXsRJ4AdEXcZK7tMZOYvyEWJm0sNGqCm5e5zTQy9jprE0RcQtTjUMN8HKTKYJdz82W6tEI8OxoY62c1PwLn4flmtUpzf08fp692nEYhs2skpoKXBdRp5jYJEVNl8VcKKW8OxKsyEWJmUyP1rJZ9Yd5u)CgvU8KpKSLuECiJ3gwFYtKh9Epx4F721SUTqDQvDiN6xbnFXJEVNN8HKTKYJdz82W6tEI8O3eWZflTU6Nlz6QrRtrVIwjBjORUDZflTU6Nlz6QrRtrVIwjBjOe5zTQ(5sMUA06u0RMAj4jFizlP84qgVnS(KNip6LJcZJEvhYP(vSUTqDQ92TAaBWnpDKyr3Zt(qYws5XHmEBy9jprE0lijH5rViLW8GhzCXsRJgN7LqVaRxKj)K4dCgvUUyP1vILsh5VGUdbzQZhofTs2sqjUopRvfRp5jYJEvqDQnb8YZAvn0Ub5pj8REsy(vGKajjmp6fPy9jprE0RH1TfQtTiUATh9cssyE0lsX6tEI8OxdRBluNArJZ9YSTBitD(WbssyE0lsX6tEI8OxdRBluNArJZ9Ym9i65pwyGKeMh9IuS(KNip61W62c1Pw04CVSgpLTDdbssyE0lsX6tEI8OxdRBluNArJZ9szzeYFXAyI1cssyE0lsX6tEI8OxdRBluNArJZ9YjImHtheijH5rVifRp5jYJEnSUTqDQfno3lNiYeoD4CIitxRgymiUjZjvReZnRCiUWScuiE)itwGGrCgvUcZJEvhYP(vXAQ2a2GF7gRBluNAvhYP(vpDKyrCmz4dssyE0lsX6tEI8OxdRBluNArJZ9spoKjL8ACgvU)CPA)WiLthT(fRjL8Ak6UZqtJGsKN1QIsFqMip6vn1ajbssyE0lsX6tEI8OxJ2GGiU2a2GJm3PNqWo06CgvU5zTQy9jprE0RcQtTGKsda(oh5XrCcGh6uaSTxya8f0N8e5rVaCQWAbyRGCa2hKLFea7naRpxa(olwy8veapILqOyHbWEdWqKt)jwcGh6ua8fgpbWJyfKJay0qpTqaCMa4jIGuGKeMh9IuS(KNip61OniiACUxYt(qYwIZvoexkDNwicYW6tEI8OxZthjweNTgxe5CYtStIBEwRkwFYtKh9QE6iXIgppRvfRp5jYJEvqZx8Ox((Aw3wOo1Qy9jprE0R6PJel6(8SwvS(KNip6v90rIfDfiP0aG5ZGGqaSpqam08fp6fG7ka7deaRpxa(olwy8veapILqOyHbWxqFYtKh9cWEdW(abW0cbWDfG9bcGzZ)P1b4lOp5jYJEb4OcW(abWmb5aCQEAHaywF0SKtam08Jfga7dbcGVG(KNip6vbssyE0lsX6tEI8OxJ2GGOX5Ejp5djBjox5qCP0DAHiidRp5jYJEnpDKyrC2ACfiio5j2jXLN8HKTKcXF2anFXJE5mQCZZAvHMRH)yHHmzlHqXcZ8KabNAQD7gp5djBjfLUtlebzy9jprE0R5PJelIJjR4d(ggdsDK057RZZAvHMRH)yHHmzlHqXctDK0nixy8Nw5zTQqZ1WFSWqMSLqOyHPqUW4)kqscZJErkwFYtKh9A0geeno3lZcmtxn(hm(rCgvU5zTQy9jprE0RcQtTGKeMh9IuS(KNip61OniiACUxAdEXcZK7tMZOYvyEWJm0sNGqCm5e5zTQy9jprE0RcQtTGKeMh9IuS(KNip61OniiACUxEI)7hz6QX7)qRZzu5MN1QI1N8e5rVkOo1MipRv1pxY0vJwNIEfuNAbjjmp6fPy9jprE0RrBqq04CVCIit40HZvoe3b40O3hEsGmP(a5PErdXzu5MN1QI1N8e5rVQPwcH5rVQA8KjBfKRydYdJqCHFcH5rVQA8KjBfKREInipmY4XH4imgK6iPdssyE0lsX6tEI8OxJ2GGOX5Ez22nKPRgFGm0sh4ajjmp6fPy9jprE0RrBqq04CV8qN(HZ0vJDYcid0tYbbssyE0lsX6tEI8OxJ2GGOX5EzQ(Tq8OynpH6vwgbskna4rUq(ma(cJNa4rScYb4jsGr8jaCAJ5hlma(c6tEI8Oxob4lmEcGhXkihbWYta8erqaS3ammAPxCcGt7TdW6(tc)iawwia(eBCI7GayFGay50Z1b4UcWECiagPrRdWu6eB6XcdGBFGEagPrwlsbWxy)amYLfsEia(cJN4eGVW4jaEeRGCealpbW9AHdGNiccGtnqlaN2jXJfgaZHRbWbcGfMh8iaUFao1aTaSaW6S(zdamtqoahiaowaw7BypHqaSSqaCANepwyamhUgalleaN2BhG19Ne(by5jaEBhGfMh8ifaFNe(aapIvqo9amFUGC6byzHa4l0khcG5qB5eGVW4jaEeRGCeaZKfGfiOWJEfRfoaota8erqaCQHWsaCAVDaw3Fs4hGLfcGt7K4XcdG5W1ay5jaEBhGfMh8iawwiaway(c4(oBfKdWbcGJfG9bcGL4byzHayXIAao1qyjaMjipwyaSoRF2aat8OfGJkaN2jXJfgaZHRbWbcGf7tceCaSW8GhPa4Xgia2kUtpalwBNcbWEQgGt7TdW6(tc)amFbCFNTcYraS3aCMayMGCaowagnzmcHIEbyP60dW(abW6S(zdkaMpdck8OxXAHdGtf(aapIvqo9amFUGC6byzHa4l0khcG5qB5eGVW4jaEeRGCeaJg6PfcG32b4mbWtebbWZ1sieapIvqo9amFUGC6b4abWsUNoa7natPRfpbW9dW(a9ealpbWN(ja2hKfGPTNWga4lmEcGhXkihbWEdWu6oTqa8iwb50dW85cYPhG9gG9bcGPfcG7kaFb9jprE0RcKKW8OxKI1N8e5rVgTbbrJZ9YA8KjBfKZ5erMUwnWyqCtMZjImPgclzycYJfg3K5mQCL7G(Wjv2kiNEZrqo9kALSLGsWgKhgH4i3KtC91cZJEv14jt2kixXgKhgHm1xyE0Ryh)68SwvS(KNip6v90rIfLw5zTQYwb50BocYPxbnFXJEVkTL1TfQtTQA8KjBfKRGMV4rVP115zTQy9jprE0R6PJel6Q02RZZAvLTcYP3CeKtVcA(Ih9MwWxXhxDfh5c)B3GNCh0hoPYwb50BocYPxrRKTe0TBWZflTUQALdz6vrRKTe0TB5zTQy9jprE0R6PJel6EU5zTQYwb50BocYPxbnFXJEVDlpRvv2kiNEZrqo9QNosSO7HVIpUDJU7m00ii1aCA07dpjqMuFG8uVOHsW62c1Pw1aCA07dpjqMuFG8uVOHmCa8HFYP5lQE6iXIUNpUkrEwRkwFYtKh9QMAjUgEcZJEviw)SbfLoXMESWsapH5rVkn4(oBfKRI1uTbSbprEwRQbs8yHzMAQP2TBcZJEviw)SbfLoXMESWsKN1QAODdYFs4xb1P2exNN1QAGepwyMPMcQtT3Uj3b9HtQSvqo9MJGC6v0kzlbD1TBYDqF4KkBfKtV5iiNEfTs2sqjCXsRRQw5qMEv0kzlbLqyE0RsdUVZwb5QynvBaBWtKN1QAGepwyMPMcQtTjYZAvn0Ub5pj8RG6u7vGKsda(oj8HE6amhQTs)kwa(ceetGiob470tKdWtebWxy8eapIvqocGtnqla7deCaCQE5RoaFMlBaGzF4iawwiao1aTa8fgpH8(paCGayOo1Qajjmp6fPy9jprE0RrBqq04CVSgpzYwb5CorKPRvdmge3K5CIitQHWsgMG8yHXnzoJkx4j3b9HtQSvqo9MJGC6v0kzlbL4AH5bpYqlDccDpxH5bpYa1UkGTHt3Ubpw3wOo1Q0gAAJ0nvRCiK6jbcURsapwVqZWvXwPFfRHjiMarkALSLGsWgKhgH4i3KtKN1QI1N8e5rVQPwc4LN1QQgpH8(pQNeMNaE5zTQgA3G8Ne(vpjmpXq7gK)KWVbPrwlYeRPAdyd(45zTQgiXJfMzQPEsy(9xeKuAaW3jHpaWCO2k9Ryb4lqqmbI4eGVW4jaEeRGCaEIiagn0tleaNjawGGcp6vSWbWSEr(lXsqamQbyFqCaoCaoqa82oaNjaEIiiaEUwcHayouBL(vSa8fiiMaraCGayj3thG9gGP01INa4(byFGEcGLNa4t)ea7dYcW02tyda8fgpbWJyfKJayVbykDNwiaMd1wPFflaFbcIjqea7na7deatlea3va(c6tEI8OxfijH5rVifRp5jYJEnAdcIgN7L14jt2kiNZjImDTAGXG4MmNtezsnewYWeKhlmUjZzu5cp5oOpCsLTcYP3CeKtVIwjBjOexlmp4rgAPtqO75kmp4rgO2vbSnC62n4X62c1PwL2qtBKUPALdHupjqWDvcwVqZWvXwPFfRHjiMarkALSLGsWgKhgH4i3KtC91cZJEv14jt2kixXgKhgHm1xyE0Ryh)AEYhs2skkDNwicYW6tEI8OxZthjwuALN1Qk2k9RynmbXeisbnFXJEVkTL1TfQtTQA8KjBfKRGMV4rVPfp5djBjfLUtlebzy9jprE0R5PJelkT968SwvXwPFfRHjiMarkO5lE0BAbJbPos6xDfh5c)B34jFizlPO0DAHiidRp5jYJEnpDKyr3ZnpRvvSv6xXAycIjqKcA(Ih9E7wEwRQyR0VI1WeetGi1thjw09WyqQJK(TBSUTqDQvHgIQhlmJwNIE1tceCj4jFizlPy9jprE0RbnevpwygTof9xLipRvfRp5jYJEvtTexdV8Swv14jK3)r9KW8B3YZAvfBL(vSgMGycePE6iXIUh(k(4QeWlpRv1q7gK)KWV6jH5jgA3G8Ne(ninYArMynvBaBWhppRv1ajESWmtn1tcZV)IGKeMh9IuS(KNip61OniiACUxY6560J0iRLZOY9Nlv7hgPGcel0SXkpCgwFoYcPO7odnnckrEwRkOaXcnBSYdNH1NJSqkOo1MipRvfuGyHMnw5HZW6ZrwiJ8mzjfuNAtW62c1PwvEwRgOaXcnBSYdNH1NJSqQNei4ajjmp6fPy9jprE0RrBqq04CVuEMSKHsxZ2OOxoJk3FUuTFyKckqSqZgR8Wzy95ilKIU7m00iOe5zTQGcel0SXkpCgwFoYcPG6uBI8SwvqbIfA2yLhodRphzHmYZKLuqDQnbRBluNAv5zTAGcel0SXkpCgwFoYcPEsGGdKKW8OxKI1N8e5rVgTbbrJZ9Y63ip3wNZOY9Nlv7hgPGcel0SXkpCgwFoYcPO7odnnckrEwRkOaXcnBSYdNH1NJSqkOo1MipRvfuGyHMnw5HZW6Zrwit9BKRG6ulijH5rVifRp5jYJEnAdcIgN7LmXAncZJEn2a5CUYH4kmp4rgxS06iqscZJErkwFYtKh9A0geeno3lz9jprE0lNtez6A1aJbXnzoNiYKAiSKHjipwyCtMZOYnpRvfRp5jYJEvqDQnX1)CPA)WifuGyHMnw5HZW6ZrwifD3zOPrqCZZAvbfiwOzJvE4mS(CKfsn1UkX1cZJEvhYP(vXAQ2a2GF7MW8OxfI1pBqrPtSPhlSecZJEviw)SbfLoXMozE6iXIUh(k(42nH5rVQA8uwSwfLoXMESWsimp6vvJNYI1QO0j20jZthjw09WxXh3Ujmp6vPb33zRGCfLoXMESWsimp6vPb33zRGCfLoXMozE6iXIUh(k(4kqsPbaZHMpqpaZ62c1Pwea7dIdWOHEAHa4mbWtebbWPcFaGVG(KNip6fGrd90cbW9AHdGZeapreeaNk8bawwawy(uSa8f0N8e5rVamtqoalleaVTdWPcFaGfawFUa8DwSW4RiaEelHqXcdG1(MPajjmp6fPy9jprE0RrBqq04CVKjwRryE0RXgiNZvoexwFYtKh9AyDBH6ulIZOYnpRvfRp5jYJEvwb5gkDT4P75kmp6vX6tEI8OxLvqUzIiiqscZJErkwFYtKh9A0geeno3lRw5qi)d(joJk3RZZAvn0Ub5pj8REsy(TB5zTQQXtiV)J6jH5xLqyEWJm0sNGqCKlp5djBjfRp5jYJEnvRCiK)b)eijH5rVifRp5jYJEnAdcIgN7LAW9D2kiNZOYnpRvfAUg(JfgYKTecflmZtceCQPwI8SwvO5A4pwyit2siuSWmpjqWPE6iXI4itqUXJdbssyE0lsX6tEI8OxJ2GGOX5EPgCFNTcY5mQCZZAvvJNqE)h1tcZbjjmp6fPy9jprE0RrBqq04CVudUVZwb5CgvU5zTQ0G7BMvqh1tcZtKN1QsdUVzwbDupDKyrCKji34XHsCDEwRkwFYtKh9QE6iXI4itqUXJdD7wEwRkwFYtKh9QG6u7vGKeMh9IuS(KNip61OniiACUxQb33zRGCoJk38SwvdTBq(tc)QNeMNipRvfRp5jYJEvtnqscZJErkwFYtKh9A0geeno3l1G77SvqoNrLR2t8mWyqQKviw)SHe5zTQgiXJfMzQPEsyoijH5rVifRp5jYJEnAdcIgN7LOHO6XcZO1PONZOYnpRvfRp5jYJEvtTeWtyE0RQgpzYwb5k2G8WiucEYhs2skwFYtKh9Aqdr1JfMrRtrpNX60)tn3evUcZJEv14jt2kixXgKhgH4kmp6vvJNmzRGC1rs3WgKhgHajjmp6fPy9jprE0RrBqq04CVuBOPns3uTYHqCgvU5zTQy9jprE0RAQL46RfMh9QQXtMSvqUInipmcDFYjCXsRR0G7BMvqhfTs2sqjeMh8idT0jie3KV62n45ILwxPb33mRGokALSLGUDtyEWJm0sNGqCm5Rajjmp6fPy9jprE0RrBqq04CVSgpLfRLZOYnpRvfRp5jYJEvqDQnbRBluNAvS(KNip6v90rIfDptqUXJdLaESEHMHRQw5qgHXEYJEv0kzlbbssyE0lsX6tEI8OxJ2GGOX5EjI1pBGZOYnpRvfRp5jYJEvpDKyrCKji34XHsKN1QI1N8e5rVQP2TB5zTQy9jprE0RcQtTjyDBH6uRI1N8e5rVQNosSO7zcYnECiqscZJErkwFYtKh9A0geeno3lTbVyHzY9jZzu5MN1QI1N8e5rVQNosSO7HXGuhj9ecZdEKHw6eeIJjdssyE0lsX6tEI8OxJ2GGOX5Ej0lW6fzYpj(aNrLBEwRkwFYtKh9QE6iXIUhgdsDK0tKN1QI1N8e5rVQPgijH5rVifRp5jYJEnAdcIgN7Liw)SboJkxxEyKRgiX6dknMFpxoa(jCXsRRqK8XcZ49KnOOvYwccKeijH5rVi13AgTbbrCRw5qi)d(joJkxH5bpYqlDccXrU8KpKSLudTBq(tc)MQvoeY)GFkX15zTQgA3G8Ne(vpjm)2T8Swv14jK3)r9KW8Rajjmp6fP(wZOniiACUxQb33zRGCoJk38SwvO5A4pwyit2siuSWmpjqWPMAjYZAvHMRH)yHHmzlHqXcZ8KabN6PJelIJmb5gpoeijH5rVi13AgTbbrJZ9sn4(oBfKZzu5MN1QQgpH8(pQNeMdssyE0ls9TMrBqq04CVudUVZwb5CgvU5zTQgA3G8Ne(vpjmhKuAaWC4icG7La4lmEcGhXkihGj5TWbWXcWPnB(caoQamC9eGH6LV6a8GWJayk8b6b40ojESWayoCnaUFaoT3oaR7pj8dWWroalleatHpqpFcaFTCfapi8ia(0pbW(GSaSNQbyX(KabhNa815Ra4bHhbW8zwkDK)c6oe(kcGVW5dha)Kabha7napreNaC)a81SRayDs(yHbWJ1t2aahiawyEWJuaCAJE5Road1aSpeiao1qyjaEqEiaMjipwya8fALd5FWpHa4(b4ud0cW6ZfGVZIfgFfbWJyjekwyaCGa4Nei4uGKeMh9IuFRz0geeno3lRXtMSvqoNtez6A1aJbXnzoNiYKAiSKHjipwyCtMZOYfE8KpKSLu14jt2ki3O1TnwyjYZAvHMRH)yHHmzlHqXcZ8KabNcQtTjeMh8idT0ji098KpKSLudYdzycYnvRCiK)b)uc4vJNqU8o9kH5bpkX1WlpRv1ajESWmtn1tcZtaV8SwvdTBq(tc)QNeMNaEApXZ01QbgdsvJNmzRG8exlmp6vvJNmzRGCfBqEyeIJCV4TBx7ILwxjwkDK)c6oeKPoF4u0kzlbLG1TfQtTkOxG1lYKFs8b1tceCxD721UyP1vis(yHz8EYgu0kzlbLWLhg5QbsS(GsJ53ZLdG)vxDfiP0aG5WreaFHXta8iwb5amf(a9am08Jfgala8fgpLfR9s(c4(oBfKdWmb5aCQbAb40ojESWayoCnaoqaSW8GhbW9dWqZpwyamLoXMobWPcFaG1j5JfgapwpzdkqscZJErQV1mAdcIgN7L14jt2kiNZjImDTAGXG4MmNtezsnewYWeKhlmUjZzu5cpEYhs2sQA8KjBfKB062glSeWRgpHC5D6vcZdEuIRV(AH5rVQA8uwSwfLoXMESWsCTW8OxvnEklwRIsNytNmpDKyr3dFfFC7g8(5s1(HrQA8eY7)OO7odnnc6QB3eMh9Q0G77SvqUIsNytpwyjUwyE0RsdUVZwb5kkDInDY80rIfDp8v8XTBW7Nlv7hgPQXtiV)JIU7m00iORUkrEwRQbs8yHzMAQNeMF1TBx7ILwxHi5JfMX7jBqrRKTeucxEyKRgiX6dknMFpxoa(jUopRv1ajESWmtn1tcZtapH5rVkeRF2GIsNytpwy3UbV8SwvdTBq(tc)QNeMNaE5zTQgiXJfMzQPEsyEcH5rVkeRF2GIsNytpwyjG3q7gK)KWVbPrwlYeRPAdyd(vxDfijH5rVi13AgTbbrJZ9sMyTgH5rVgBGCox5qCfMh8iJlwADeijH5rVi13AgTbbrJZ9sn4(oBfKZzu5MN1QsdUVzwbDupjmpbtqUXJdDFEwRkn4(Mzf0r90rIfLGji34XHUppRv1pxY0vJwNIE1thjweijH5rVi13AgTbbrJZ9sn4(oBfKZzu5Q9epdmgKkzfI1pBirEwRQbs8yHzMAQNeMNWflTUcrYhlmJ3t2GIwjBjOeU8WixnqI1huAm)EUCa8timp4rgAPtqO75jFizlPgA3G8Ne(nvRCiK)b)eijH5rVi13AgTbbrJZ9sTHM2iDt1khcXzu5cpEYhs2skTHM2iDJw32yHLipRv1ajESWmtn1tcZtaV8SwvdTBq(tc)QNeMN4AH5bpYa1UkGTHt3FXB3eMh8idT0jieh5Yt(qYwsnipKHji3uTYHq(h8t3Ujmp4rgAPtqioYLN8HKTKAODdYFs43uTYHq(h8txbssyE0ls9TMrBqq04CVeX6NnWzu56YdJC1ajwFqPX875YbWpHlwADfIKpwygVNSbfTs2sqGKeMh9IuFRz0geeno3lLNjlzO01Snk6LZOYvyEWJm0sNGqCKlp5djBjL8mzjdLUMTrrVjoYkknMZrU8KpKSLuYZKLmu6A2gf9AoYkGKeMh9IuFRz0geeno3lRw5qi)d(joJkxH5bpYqlDccXrU8KpKSLudYdzycYnvRCiK)b)eijH5rVi13AgTbbrJZ9YA8uwSwqsGKeMh9Iuixwi5HmF7Ih9YTALdH8p4N4mQCfMh8idT0jieh5Yt(qYwsn0Ub5pj8BQw5qi)d(PexNN1QAODdYFs4x9KW8B3YZAvvJNqE)h1tcZVcKKW8OxKc5YcjpK5Bx8O3X5EPgCFNTcY5mQCZZAvvJNqE)h1tcZbjjmp6fPqUSqYdz(2fp6DCUxQb33zRGCoJk38SwvdTBq(tc)QNeMNipRv1q7gK)KWV6PJel6EH5rVQA8uwSwfLoXMoz84qGKeMh9Iuixwi5HmF7Ih9oo3l1G77SvqoNrLBEwRQH2ni)jHF1tcZtCT2t8mWyqQKv14PSyT3UvJNqU8o9kH5bp62nH5rVkn4(oBfKRI1uTbSb)kqsPbap2dha7nadJCaw)oBeaw7BgcGJffqeaN2S5layTbbriaUFa(c6tEI8OxawBqqecGtnqlaR1iuKTKcKKW8OxKc5YcjpK5Bx8O3X5EPgCFNTcY5mQCZZAvHMRH)yHHmzlHqXcZ8KabNAQL4Aw3wOo1Q(5sMUA06u0RE6iXIgxyE0R6Nlz6QrRtrVIsNytNmECOXzcYnECioMN1Qcnxd)XcdzYwcHIfM5jbco1thjw0TBWZflTU6Nlz6QrRtrVIwjBjORsWt(qYws5XHmEBy9jprE074mb5gpoehZZAvHMRH)yHHmzlHqXcZ8KabN6PJelcKKW8OxKc5YcjpK5Bx8O3X5EPgCFNTcY5mQCZZAvn0Ub5pj8REsyEcxEyKRgiX6dknMFpxoa(jCXsRRqK8XcZ49KnOOvYwccKKW8OxKc5YcjpK5Bx8O3X5EPgCFNTcY5mQCZZAvPb33mRGoQNeMNGji34XHUppRvLgCFZSc6OE6iXIajLgaCAJ5hlma2hiag5Ycjpea)TlE0lNaCVw4a4jIa4lmEcGhXkihbWPgOfG9bcoawEcG32b4mflmawRBlbbW1(b40MnFba3paFb9jprE0RcG5WreaFHXta8iwb5amf(a9am08Jfgala8fgpLfR9s(c4(oBfKdWmb5aCQbAb40ojESWayoCnaoqaSW8GhbW9dWqZpwyamLoXMobWPcFaG1j5JfgapwpzdkqscZJErkKllK8qMVDXJEhN7L14jt2kiNZjImDTAGXG4MmNtezsnewYWeKhlmUjZzu5cVA8eYL3Pxjmp4rjGhp5djBjvnEYKTcYnADBJfwIRV(AH5rVQA8uwSwfLoXMESWsCTW8OxvnEklwRIsNytNmpDKyr3dFfFC7g8(5s1(HrQA8eY7)OO7odnnc6QB3eMh9Q0G77SvqUIsNytpwyjUwyE0RsdUVZwb5kkDInDY80rIfDp8v8XTBW7Nlv7hgPQXtiV)JIU7m00iORUkrEwRQbs8yHzMAQNeMF1TBx7ILwxHi5JfMX7jBqrRKTeucxEyKRgiX6dknMFpxoa(jUopRv1ajESWmtn1tcZtapH5rVkeRF2GIsNytpwy3UbV8SwvdTBq(tc)QNeMNaE5zTQgiXJfMzQPEsyEcH5rVkeRF2GIsNytpwyjG3q7gK)KWVbPrwlYeRPAdyd(vxDfijH5rVifYLfsEiZ3U4rVJZ9sn4(oBfKZzu5Q9epdmgKkzfI1pBirEwRQbs8yHzMAQNeMNWflTUcrYhlmJ3t2GIwjBjOeU8WixnqI1huAm)EUCa8timp4rgAPtqO75jFizlPgA3G8Ne(nvRCiK)b)eijH5rVifYLfsEiZ3U4rVJZ9sTHM2iDt1khcXzu5cpEYhs2skTHM2iDJw32yHL4A45ILwxv)(y8bYiObcPOvYwc62nH5bpYqlDccXXKVkX1cZdEKHw6eeIJjNqyEWJmqTRcyB409x82nH5bpYqlDccXrU8KpKSLudYdzycYnvRCiK)b)0TBcZdEKHw6eeIJC5jFizlPgA3G8Ne(nvRCiK)b)0vGKeMh9Iuixwi5HmF7Ih9oo3lzI1AeMh9ASbY5CLdXvyEWJmUyP1rGKeMh9Iuixwi5HmF7Ih9oo3lHEbwVit(jXh4mQCfMh8idT0jiehtgKKW8OxKc5YcjpK5Bx8O3X5EjI1pBGZOY1Lhg5QbsS(GsJ53ZLdGFcxS06kejFSWmEpzdkALSLGajLga8Ds4damT9e2aa7YdJCeNaC4aCGaybGHjXcWEdWmb5a8fALdH8p4NaybbW1WAPhGJf5KabWDfGVW4PSyTkqscZJErkKllK8qMVDXJEhN7LYZKLmu6A2gf9Yzu5kmp4rgAPtqioYLN8HKTKsEMSKHsxZ2OO3ehzfLgZ5ixEYhs2sk5zYsgkDnBJIEnhzfqscZJErkKllK8qMVDXJEhN7LvRCiK)b)eNrLRW8GhzOLobH4ixEYhs2sQb5Hmmb5MQvoeY)GFcKKW8OxKc5YcjpK5Bx8O3X5EznEklwlijH5rVifYLfsEiZ3U4rVJZ9seRF2qrhPrSYOCyCqXlEPaa]] )

end
