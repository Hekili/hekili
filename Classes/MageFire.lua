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


    spec:RegisterPack( "Fire", 20201123, [[devsidqiqspskixcfvLSjr0NOqgLuKtjfAvsb1RurmlkWTurv2fj)cKyyuqoMi0YKc8mvuzAsrfxJckBdfu9nuufJtkQY5urv16qrL5HcCpuQ9HIY)qrvPCqvKQwOkkpufjtufvLCrPOQ2ikO8rvuvmsPOsojkQsRef5LOOQyMOGCtvKkTtPu(jkQQgkfuPLQIuXtPOPkLQRkfvQTIIQs1xPGkgRuu2Ru9xsnyihMyXI6XOAYG6YiBwjFgeJwfoTWQvrvPETiy2u62Q0Uv8BjdxKoUksz5aphQPt11vQTJs(UuY4PqDEuO1tbvnFqQ9RQ7j2BVBclo1BRbgQbgkXeBW5ujAyNZqjAyDtNXuQBMk8eeiu3CKl1nzybG6MPcJ2sG7T3nX1gWPU5H7PyMdkqbs4h7SIxxOGJ72kEudhilhk44YHs3mVdRZ8o9C3ewCQ3wdmudmuIj2GZPs0WAad3W6MY2pkq30mUNQBEeWW00ZDtycZ7Mn0JyybGE0PRaHEMAOhD4EkM5GcuGe(XoR41fk44UTIh1WbYYHcoUCO8m1qpQTIfDZe4rn4Cg8OgyOgyONPNPg6rN6qgieM5EMAOhDEpQ5gtpAfqoCnGUsm4hbe)GapYpK5rUaGqUYJlP9sdh0Jwf4rwb7NhM41a)ijh2Wz8rBSaHWQNPg6rN3JAUtHfNEKTGe8hbiM7rm0MhWp68fGKlw9m1qp68EedvfMMhXfS)iaDA7aqxAC8Jwf4rNQU5n2JAEutHIug8i4AmYF0rzHFu4pAvGhjpAbi8XJoDjNkWJ4c2Bu9m1qp68EuZFKSLEe2bb3Fe)G4jedKhvZJKhTOwpAvGeWpkMh5h0Jo9gUm0J86racEZPh1Qajylbw1nTb2X927M86M3ypQrZRYcxTgCV9EBj2BVBkCpQPBMwEut3KgjBj4(zDV3wd6T3nfUh10nZ2QG1RnGXUjns2sW9Z6EVTZ1BVBkCpQPBMjaMajedKUjns2sW9Z6EVTMtV9UPW9OMU5kau2wfC3KgjBj4(zDV3MH1BVBkCpQPBkdNWoqSAUyTDtAKSLG7N19EBm8E7DtH7rnDZnM0HtxC3KgjBj4(zDV3gZtV9Ujns2sW9Z6Mc3JA6MqScCiEbW6SadH6MBmPR1sdHd3BlXUjheobcPBkCpQrDjNkGkg9Ygqo8hbn0pIxLfUAnQl5ubua6kXGFeZEuIgQBsRfXD9ixQBcXkWH4faRZcmeQ792AE927M0izlb3pRBYbHtGq6MG9qRcaHuoDtlGy1TeqQIgjBj4hL8r59APiJpKn2JAu70UPW9OMUPhxs3saPDV7DtyAjBR3BV3wI927M0izlb3pRBYbHtGq6Mq9rG9qRcaHuWbMhP2yeaJAEDVYaROrYwcUBkCpQPBYR94eaNswB37T1GE7DtAKSLG7N1nR0UjM8UPW9OMUjlbes2sDtwIDtDtxS04QvaiSlaNakAKSLGFud)OvaiSlaNakaDLyWp6Kh10J4vzHRwJIx38g7rnkaDLyWpQHFutpkXhDEpILacjBjvcXaBJbIgqWBUh18Og(rUyPXvjedSngikAKSLGFuJpQXh1WpcQpIxLfUAnkEDZBSh1OaKaZ4JA4hL3RLIx38g7rnk4Q10nzja9ixQB6XL0EP51nVXEut37TDUE7DtAKSLG7N1nR0U5vmUBkCpQPBYsaHKTu3KLy3u3KLacjBjfDtzeqIvxa4rgoPHjRW4JoVh10J4vzHRwJIUPmciXQla8idNuWBG4rnp68EeVklC1Au0nLrajwDbGhz4Kcqxjg8JA8rn8JG6J4vzHRwJIUPmciXQla8idNuasGzSBYbHtGq6M0PTJ0ucwr3ugbKy1faEKHtDtwcqpYL6MECjTxAEDZBSh109EBnNE7DtAKSLG7N1nR0U5vmUBkCpQPBYsaHKTu3KLy3u3KxLfUAnkiwboeVayDwGHqkaDLyWDtoiCces3KoTDKMsWkiwboeVayDwGHqDtwcqpYL6MECjTxAEDZBSh109EBgwV9Ujns2sW9Z6MvA38kg3nfUh10nzjGqYwQBYsSBQBM3RLcShsxlDA1IakaDLyWDtoiCces30flnUcShsxlDA1IakAKSLGFuYhL3RLIx38g7rnk4Q10nzja9ixQB6XL0EP51nVXEut37TXW7T3nPrYwcUFw3Ss7MxX4UPW9OMUjlbes2sDtwIDtDtEvw4Q1Oa7H01sNwTiGcqxjg8Jo5r59APa7H01sNwTiGcEdepQPBYbHtGq6MUyPXvG9q6APtRweqrJKTe8Js(O8ETu86M3ypQrbxTMhL8r8QSWvRrb2dPRLoTArafGUsm4hDYJmShXGhXsaHKTKYJlP9sZRBEJ9OMUjlbOh5sDtpUK2lnVU5n2JA6EVnMNE7DtAKSLG7N1n5GWjqiDZ8ETu86M3ypQrbxTMhL8rSeqizlP84sAV086M3ypQ5rm7rRT1Qbe8M7rnpk5JA6r8QSWvRrb2dPRLoTArafGUsm4hXShT2wRgqWBUh18iOH(rq9rUyPXvG9q6APtRweqrJKTe8JASBkCpQPBIpILhdeDA1IaDV3wZR3E3KgjBj4(zDtoiCces3SPhL3RLIx38g7rnk4Q18OKpkVxlfypKUw60QfbuWvR5rjFutpILacjBjLhxs7LMx38g7rnpIbpImM4BN0ECPhbn0pILacjBjLhxs7LMx38g7rnpIzpIxLfUAnkGahY4ACQasqbVbIh18OgFuJpcAOFutpkVxlfypKUw60Qfbu70hL8rSeqizlP84sAV086M3ypQ5rm7rNZqpQXUPW9OMUjqGdzCnovaj09EBN)E7DtAKSLG7N1n5GWjqiDZ8ETu86M3ypQrbxTMhL8r59APa7H01sNwTiGcUAnpk5JyjGqYws5XL0EP51nVXEuZJyWJiJj(2jThxQBkCpQPBctIFKlWqDV3wIgQ3E3KgjBj4(zDtoiCces3mVxlfVU5n2JAuWvR5rjFemL3RLciWHmUgNkGe0S22HasoSHZOcUAnDtH7rnDZBaafqhxbc19EBjMyV9Ujns2sW9Z6Mc3JA6MqScCiEbW6SadH6MCq4eiKUjlbes2skpUK2lnVU5n2JAEeZEKW9OgnVklC1AE059idRBsRfXD9ixQBcXkWH4faRZcmeQ792sSb927M0izlb3pRBYbHtGq6MSeqizlP84sAV086M3ypQ5rmG9JyjGqYwsr3ugbKy1faEKHtAyYkm2nh5sDt6MYiGeRUaWJmCQBkCpQPBs3ugbKy1faEKHtDV3wINR3E3KgjBj4(zDtoiCces3KLacjBjLhxs7LMx38g7rnpIzSFelbes2sQA0BmP5BVwRU5ixQBIRTvhqMWjq3u4Eut3exBRoGmHtGU3BlXMtV9Ujns2sW9Z6MCq4eiKUjlbes2skpUK2lnVU5n2JAEeZy)iwciKSLu1O3ysZ3ETwDZrUu3eILX0dDT0cgh3WkEut3u4Eut3eILX0dDT0cgh3WkEut37TLOH1BVBsJKTeC)SUjheobcPBYsaHKTKYJlP9sZRBEJ9OMhXa2pYW6MJCPU5v4sgqA8brU(UXbVBkCpQPBEfUKbKgFqKRVBCW7EVTez4927M0izlb3pRBYbHtGq6MSeqizlP84sAV086M3ypQ5rmJ9JyjGqYwsvJEJjnF71A1nh5sDtyajWRaqAwegt2UPW9OMUjmGe4vainlcJjB37TLiZtV9Ujns2sW9Z6MCq4eiKUjlbes2skpUK2lnVU5n2JAEedy)id7rN8OenSh1WpILacjBj1Qgxdx7SL01O3y6rjFelbes2skpUK2lnVU5n2JAEeZEKH6MJCPUPy4XhcqW6vnUUw60Qfb6Mc3JA6MIHhFiabRx146APtRweO792sS51BVBsJKTeC)SUjheobcPB20JyjGqYws5XL0EP51nVXEuZJyWJs0qpcAOF0kGC4AaDLyWpIbpILacjBjLhxs7LMx38g7rnpQXUPW9OMUjKTaGdz01slgEcu(r37TL45V3E3u4Eut3KxdNghiobRxw5sDtAKSLG7N19EBnWq927Mc3JA6MassJbIEzLlH7M0izlb3pR792AqI927Mc3JA6MRIVXeSwm8eiCsNj52nPrYwcUFw37T1Gg0BVBkCpQPBMUbXIXyGOZwb7DtAKSLG7N19EBn4C927Mc3JA6MGin1s6y04uHtDtAKSLG7N19EBnO50BVBkCpQPB6hKEp5ApW6vb4u3KgjBj4(zDV3wdmSE7DtAKSLG7N1n5GWjqiDtWEOvbGqk4aZJuBmcGrnVUxzGv0izlb)OKpIxLfUAnQ8ET0WbMhP2yeaJAEDVYaRaKaZ4Js(O8ETuWbMhP2yeaJAEDVYaRfaxgsbxTMhL8rSeqizlP84sAV086M3ypQ5rm7rNZqpk5JG6JY71sbhyEKAJramQ519kdSAN2nfUh10n51ECcGtjRT792AadV3E3KgjBj4(zDtoiCces3eShAvaiKcoW8i1gJayuZR7vgyfns2sWpk5J4vzHRwJkVxlnCG5rQngbWOMx3RmWkajWm(OKpkVxlfCG5rQngbWOMx3RmWAbWLHuWvR5rjFelbes2skpUK2lnVU5n2JAEeZE05m0Js(iO(O8ETuWbMhP2yeaJAEDVYaR2PDtH7rnDtbWLH0KXP2ch109EBnG5P3E3KgjBj4(zDtoiCces3eShAvaiKcoW8i1gJayuZR7vgyfns2sWpk5J4vzHRwJkVxlnCG5rQngbWOMx3RmWkajWm(OKpkVxlfCG5rQngbWOMx3RmW6fOWUcUAnpk5JyjGqYws5XL0EP51nVXEuZJy2JoNHEuYhb1hL3RLcoW8i1gJayuZR7vgy1oTBkCpQPBUaf2ZL17EVTg086T3nPrYwcUFw3KdcNaH0nH6JyjGqYwsbhyjBjnVU5n2JAEuYhXsaHKTKYJlP9sZRBEJ9OMhXa2pYqDtH7rnDtUyTAH7rnABG9UPnWUEKl1n51nVXEuJo9qWu37T1GZFV9Ujns2sW9Z6MvA3etE3u4Eut3KLacjBPUjlXUPUjuFelbes2sk4alzlP51nVXEuZJs(iwciKSLuECjTxAEDZBSh18ig8iH7rnQvaiD2kyxT2wRgq8dbaH0ECPhDEps4EuJcFelpgi60QfbuRT1Qbe8M7rnpQHFutpIxLfUAnk8rS8yGOtRweqbORed(rm4rSeqizlP84sAV086M3ypQ5rn(OKpILacjBjLhxs7LMx38g7rnpIbpAfqoCnGUsm4hbn0pYflnUcShsxlDA1IakAKSLGFuYhL3RLcShsxlDA1Iak4Q18OKpIxLfUAnkWEiDT0PvlcOa0vIb)ig8iH7rnQvaiD2kyxT2wRgq8dbaH0ECPhDEps4EuJcFelpgi60QfbuRT1Qbe8M7rnpQHFutpIxLfUAnk8rS8yGOtRweqbORed(rm4r8QSWvRrb2dPRLoTArafGUsm4h14Js(iEvw4Q1Oa7H01sNwTiGcqxjg8JyWJwbKdxdORedUBYsa6rUu3CfasNTc21PvzJbs37TDod1BVBsJKTeC)SUzL2nXK3nfUh10nzjGqYwQBYsSBQBc1hXsaHKTKcoWs2sAEDZBSh18OKpILacjBjLhxs7LMx38g7rnpIbps4EuJk9OOjmwVSYLWQ12A1aIFiaiK2Jl9OZ7rc3JAu4Jy5XarNwTiGATTwnGG3CpQ5rn8JA6r8QSWvRrHpILhdeDA1IakaDLyWpIbpILacjBjLhxs7LMx38g7rnpQXhL8rSeqizlP84sAV086M3ypQ5rm4rRaYHRb0vIb)iOH(rG9qRcaHu49OtigiyD2syCmqu0izlb3nzja9ixQBMEu0egRtRYgdKU3B7Cj2BVBsJKTeC)SUjheobcPBM3RLcShsxlDA1Iak4Q18OKpcQpkVxl1kae2lWvbiH7pk5JA6rSeqizlP84sAV086M3ypQ5rmJ9JY71sb2dPRLoTAraf8giEuZJs(iwciKSLuECjTxAEDZBSh18iM9iH7rnQvaiD2kyxT2wRgq8dbaH0ECPhbn0pILacjBjLhxs7LMx38g7rnpIzpAfqoCnGUsm4hbn0pILacjBjfCGLSL086M3ypQ5rn2nfUh10nb7H01sNwTiq37TDUg0BVBsJKTeC)SUjheobcPBM3RLcShsxlDA1IaQD6Js(OMEelbes2skpUK2lnVU5n2JAEeZEKHEuJDtH7rnDtUyTAH7rnABG9UPnWUEKl1nbvQo9qWu37TDUZ1BVBsJKTeC)SUzL2nXK3nfUh10nzjGqYwQBYsSBQBYsaHKTKYJlP9sZRBEJ9OMhXGhjCpQrLEu0egRxw5sy1ABTAaXpeaes7XLEuYhXsaHKTKYJlP9sZRBEJ9OMhXGhTcihUgqxjg8JGg6hb2dTkaesH3JoHyGG1zlHXXarrJKTeC3KLa0JCPUz6rrtySoTkBmq6EVTZ1C6T3nPrYwcUFw3CJjDRJWsAUG9yG0BlXUjheobcPBc1hXsaHKTKAfasNTc21PvzJbYJs(OMEelbes2skpUK2lnVU5n2JAEeZEKHEe0q)iH7blstdDdc)iMX(rSeqizlPoeaSMlyxVSYLWoisGEuYhb1hTcaHDb4eqjCpyrpk5JG6JY71sDuUg7assqbiH7pk5JA6r59APoiXJbIENQaKW9hL8rc3JAulRCjSdIeifzmX3oPb0vIb)ig8idPmShbn0pIFiaiewVac3JAe7Jyg7h1Gh14JASBUXKUwlneoCVTe7Mc3JA6MRaq6SvWE37TDodR3E3KgjBj4(zDZnM0ToclP5c2JbsVTe7MCq4eiKU5kae2fGtaLW9Gf9OKpIFiaie(rmJ9Js8rjFeuFelbes2sQvaiD2kyxNwLngipk5JA6rq9rc3JAuRaqzXAvKXeF7Xa5rjFeuFKW9OgvkJGkBfSRIrVSbKd)rjFuEVwQds8yGO3PkajC)rqd9JeUh1OwbGYI1QiJj(2JbYJs(iO(O8ETuhLRXoGKeuas4(JGg6hjCpQrLYiOYwb7Qy0lBa5WFuYhL3RL6Gepgi6DQcqc3FuYhb1hL3RL6OCn2bKKGcqc3FuJDZnM01APHWH7TLy3u4Eut3CfasNTc27EVTZXW7T3nPrYwcUFw3CJjDRJWsAUG9yG0BlXUPW9OMU5kaKoBfS3n5GWjqiDtH7rnk8rS8yGOtRweqrgt8ThdKhL8rRT1Qbe)qaqiThx6rm4rc3JAu4Jy5XarNwTiGYdEcAabV5EuZJs(O8ETuhLRXoGKeuWvRP792ohZtV9Ujns2sW9Z6MCq4eiKUztpILacjBjLhxs7LMx38g7rnpIzpYqpcAOFelbes2sk4alzlP51nVXEuZJA8rjFuEVwkWEiDT0PvlcOGRwt3u4Eut3KlwRw4EuJ2gyVBAdSRh5sDtSldSaG1GYfpQP792oxZR3E3u4Eut3eZla)OBsJKTeC)SU39UjOs1PhcM6T3BlXE7DtAKSLG7N1n5GWjqiDtH7blstdDdc)iMX(rSeqizlPokxJDajjOxw5syhejqpk5JA6r59APokxJDajjOaKW9hbn0pkVxl1kae2lWvbiH7pQXUPW9OMU5Ykxc7GibQ792AqV9Ujns2sW9Z6MCq4eiKUzEVwk8E0jedeSoBjmogiAajWmQ2Ppk5JY71sH3JoHyGG1zlHXXardibMrfGUsm4hXShXfSR94sDtH7rnDZugbv2kyV792oxV9Ujns2sW9Z6MCq4eiKUzEVwQvaiSxGRcqc37Mc3JA6MPmcQSvWE37T1C6T3nPrYwcUFw3KdcNaH0nZ71sDuUg7assqbiH7DtH7rnDZugbv2kyV792mSE7DtAKSLG7N1n3ys36iSKMlypgi92sSBYbHtGq6Mq9rSeqizlPwbG0zRGDDAv2yG8OKpkVxlfEp6eIbcwNTeghdenGeygvWvR5rjFKW9GfPPHUbHFedEelbes2sQdbaR5c21lRCjSdIeOhL8rq9rRaqyxaobuc3dw0Js(OMEeuFuEVwQds8yGO3PkajC)rjFeuFuEVwQJY1yhqsckajC)rjFeuFukGyPR1sdHdRwbG0zRG9hL8rn9iH7rnQvaiD2kyxXpeaec)iMX(rn4rqd9JA6rUyPXvILmg7abB4fSETbmQOrYwc(rjFeVklC1AuWabsnyDgqIFOaKaZ4JA8rqd9JA6rUyPXvysaXar71MFOOrYwc(rjFKlaiKRoiX6hQuU)igW(rNZqpQXh14JASBUXKUwlneoCVTe7Mc3JA6MRaq6SvWE37TXW7T3nPrYwcUFw3CJjDRJWsAUG9yG0BlXUjheobcPBc1hXsaHKTKAfasNTc21PvzJbYJs(iO(OvaiSlaNakH7bl6rjFutpQPh10JeUh1OwbGYI1QiJj(2JbYJs(OMEKW9Og1kauwSwfzmX3oPb0vIb)ig8idPmShbn0pcQpcShAvaiKAfac7f4QOrYwc(rn(iOH(rc3JAuPmcQSvWUImM4Bpgipk5JA6rc3JAuPmcQSvWUImM4BN0a6kXGFedEKHug2JGg6hb1hb2dTkaesTcaH9cCv0izlb)OgFuJpk5JY71sDqIhde9ovbiH7pQXhbn0pQPh5ILgxHjbedeTxB(HIgjBj4hL8rUaGqU6GeRFOs5(Jya7hDod9OKpQPhL3RL6Gepgi6DQcqc3FuYhb1hjCpQrH5fGFOiJj(2JbYJGg6hb1hL3RL6OCn2bKKGcqc3FuYhb1hL3RL6Gepgi6DQcqc3FuYhjCpQrH5fGFOiJj(2JbYJs(iO(OJY1yhqscACkzTyDm6LnGC4pQXh14JASBUXKUwlneoCVTe7Mc3JA6MRaq6SvWE37TX80BVBsJKTeC)SUPW9OMUjxSwTW9OgTnWE30gyxpYL6Mc3dwK2flnoU792AE927M0izlb3pRBYbHtGq6M59APszeuCRGVkajC)rjFexWU2Jl9ig8O8ETuPmckUvWxfGUsm4hL8rCb7ApU0JyWJY71sb2dPRLoTArafGUsm4UPW9OMUzkJGkBfS39EBN)E7DtAKSLG7N1n5GWjqiDZuaXsdHdRsuH5fGF8OKpkVxl1bjEmq07ufGeU)OKpYflnUctcigiAV28dfns2sWpk5JCbaHC1bjw)qLY9hXa2p6Cg6rjFKW9GfPPHUbHFedEelbes2sQJY1yhqsc6LvUe2brcu3u4Eut3mLrqLTc27EVTenuV9Ujns2sW9Z6MCq4eiKUjuFelbes2sQ0JIMWyDAv2yG8OKpkVxl1bjEmq07ufGeU)OKpcQpkVxl1r5ASdijbfGeU)OKpQPhjCpyrA4YvbKjC6rm4rn4rqd9JeUhSinn0ni8Jyg7hXsaHKTK6qaWAUGD9Ykxc7Gib6rqd9JeUhSinn0ni8Jyg7hXsaHKTK6OCn2bKKGEzLlHDqKa9Og7Mc3JA6MPhfnHX6LvUeU792smXE7DtAKSLG7N1n5GWjqiDtxaqixDqI1puPC)rmG9JoNHEuYh5ILgxHjbedeTxB(HIgjBj4UPW9OMUjMxa(r37TLyd6T3nPrYwcUFw3KdcNaH0nfUhSinn0ni8Jy2JAq3u4Eut3egiqQbRZas8JU3BlXZ1BVBsJKTeC)SUjheobcPBkCpyrAAOBq4hXm2pILacjBjLa4YqAY4uBHJAEuYhDLruPC)rmJ9JyjGqYwsjaUmKMmo1w4Og9vgPBkCpQPBkaUmKMmo1w4OMU3BlXMtV9Ujns2sW9Z6MCq4eiKUPW9GfPPHUbHFeZy)iwciKSLuhcawZfSRxw5syhejqDtH7rnDZLvUe2brcu37TLOH1BVBkCpQPBUcaLfRTBsJKTeC)SU39UjVU5n2JA0PhcM6T3BlXE7DtAKSLG7N1n5GWjqiDZ8ETu86M3ypQrbxTMUPW9OMUPnGC4y957nmKlnE37T1GE7DtAKSLG7N1nR0UjM8UPW9OMUjlbes2sDtwIDtDZ8ETu86M3ypQrbORed(rN8O8ETu86M3ypQrbVbIh18Og(rn9iEvw4Q1O41nVXEuJcqxjg8JyWJY71sXRBEJ9OgfGUsm4h1y3KLa0JCPUjzStdmbR51nVXEuJgqxjgC37TDUE7DtAKSLG7N1nR0UPad3nfUh10nzjGqYwQBYsSBQBYsaHKTKcNqwdVbIh10n5GWjqiDZ8ETu49OtigiyD2syCmq0asGzuTtFe0q)iwciKSLuKXonWeSMx38g7rnAaDLyWpIzpkrLH9Og(rq4WQRy8JA4h10JY71sH3JoHyGG1zlHXXarDfJ1yx4j8OZ7r59APW7rNqmqW6SLW4yGOWUWt4rn2nzja9ixQBsg70atWAEDZBSh1Ob0vIb39EBnNE7DtAKSLG7N1n5GWjqiDZ8ETu86M3ypQrbxTMUPW9OMUzwGORL2bbpbC37Tzy927M0izlb3pRBYbHtGq6Mc3dwKMg6ge(rm7rj(OKpkVxlfVU5n2JAuWvRPBkCpQPBAdwXarNRBU792y4927M0izlb3pRBYbHtGq6M59AP41nVXEuJcUAnpk5JY71sb2dPRLoTArafC1A6Mc3JA6M3aakawxlTxGlnE37TX80BVBsJKTeC)SUjheobcPBM3RLIx38g7rnQD6Js(iH7rnQvaiD2kyxXpeaec)i2pYqpk5JeUh1OwbG0zRGDfG4hcacP94spIzpcchwDfJ7MJCPU5bJPeWpaKaRBbcS3ciP4UPW9OMU5bJPeWpaKaRBbcS3ciP4U3BR51BVBkCpQPBMTvbRRL2pinn0LXUjns2sW9Z6EVTZFV9UPW9OMU5LUfGrDT02npG1WasU4Ujns2sW9Z6EVTenuV9UPW9OMUzRcyHzrXObeUgz4u3KgjBj4(zDV3wIj2BVBsJKTeC)SU5gt6whHL0Cb7XaP3wIDtH7rnDZvaiD2kyVBYbHtGq6Mc3JAu3aakawxlTxGlnUImM4Bpgipk5JwBRvdi(HaGqApU0JoVhjCpQrDdaOayDT0EbU04kYyIVDsdORed(rm4rnNhL8rq9rhLRXoGKe04uYAX6y0lBa5WFuYhb1hL3RL6OCn2bKKGcqc3FuYh10JY71sXRBEJ9Og1o9rqd9JG6J41aVdxfZIaJy1CbZfysrJKTe8JAS792sSb927M0izlb3pRBUXKU1ryjnxWEmq6TLy3KdcNaH0nH6JedpbcNuzRGDcOVc2jGIgjBj4hL8rn9iH7blstdDdc)igW(rc3dwKgUCvazcNEe0q)iO(iEvw4Q1OspkAcJ1lRCjScqcmJpQXhL8rq9r8AG3HRIzrGrSAUG5cmPOrYwc(rjFe)qaqi8Jyg7hL4Js(O8ETu86M3ypQrTtFuYhb1hL3RLAfac7f4QaKW9hL8rq9r59APokxJDajjOaKW9hL8rhLRXoGKe04uYAX6y0lBa5WF0jpkVxl1bjEmq07ufGeU)ig8Og0n3ysxRLgchU3wIDtH7rnDZvaiD2kyV792s8C927M0izlb3pRBUXKU1ryjnxWEmq6TLy3KdcNaH0nH6JedpbcNuzRGDcOVc2jGIgjBj4hL8rn9iH7blstdDdc)igW(rc3dwKgUCvazcNEe0q)iO(iEvw4Q1OspkAcJ1lRCjScqcmJpQXhL8r8AG3HRIzrGrSAUG5cmPOrYwc(rjFe)qaqi8Jyg7hL4Js(OMEutps4EuJAfasNTc2v8dbaHW6fq4EuJyF0jpQPhXsaHKTKIm2PbMG186M3ypQrdORed(rN3JY71sfZIaJy1CbZfysbVbIh18OgFeuEeVklC1AuRaq6SvWUcEdepQ5rN3JyjGqYwsrg70atWAEDZBSh1Ob0vIb)iO8OMEuEVwQyweyeRMlyUatk4nq8OMhDEpcchwDfJFuJpQXhXm2pYqpcAOFelbes2skYyNgycwZRBEJ9OgnGUsm4hXa2pkVxlvmlcmIvZfmxGjf8giEuZJGg6hL3RLkMfbgXQ5cMlWKcqxjg8JyWJGWHvxX4hbn0pIxLfUAnk8rS8yGOtRweqbibMXhL8rc3dwKMg6ge(rmJ9JyjGqYwsXRBEJ9Ogn(iwEmq0Pvlc8OKpIxSOrgxnbKdxVe6rn(OKpkVxlfVU5n2JAu70hL8rn9iO(O8ETuRaqyVaxfGeU)iOH(r59APIzrGrSAUG5cmPa0vIb)ig8idPmSh14Js(iO(O8ETuhLRXoGKeuas4(Js(OJY1yhqscACkzTyDm6LnGC4p6KhL3RL6Gepgi6DQcqc3FedEud6MBmPR1sdHd3BlXUPW9OMU5kaKoBfS39EBj2C6T3nPrYwcUFw3KdcNaH0nb7HwfacPGdmpsTXiag186ELbwrJKTe8Js(O8ETuWbMhP2yeaJAEDVYaRGRwZJs(O8ETuWbMhP2yeaJAEDVYaRfaxgsbxTMhL8r8QSWvRrL3RLgoW8i1gJayuZR7vgyfGeyg7Mc3JA6M8ApobWPK129EBjAy927M0izlb3pRBYbHtGq6MG9qRcaHuWbMhP2yeaJAEDVYaROrYwc(rjFuEVwk4aZJuBmcGrnVUxzGvWvR5rjFuEVwk4aZJuBmcGrnVUxzG1cGldPGRwZJs(iEvw4Q1OY71sdhyEKAJramQ519kdScqcmJDtH7rnDtbWLH0KXP2ch109EBjYW7T3nPrYwcUFw3KdcNaH0nb7HwfacPGdmpsTXiag186ELbwrJKTe8Js(O8ETuWbMhP2yeaJAEDVYaRGRwZJs(O8ETuWbMhP2yeaJAEDVYaRxGc7k4Q10nfUh10nxGc75Y6DV3wImp927M0izlb3pRBkCpQPBYfRvlCpQrBdS3nTb21JCPUPW9GfPDXsJJ7EVTeBE927M0izlb3pRBUXKU1ryjnxWEmq6TLy3KdcNaH0nZ71sXRBEJ9OgfC1AEuYh10Ja7HwfacPGdmpsTXiag186ELb(rSFuEVwk4aZJuBmcGrnVUxzGv70h14Js(OMEKW9Og1LCQaQy0lBa5WFuYhjCpQrDjNkGkg9YgqoCnGUsm4hXa2pYqkg(JGg6hjCpQrH5fGFOiJj(2JbYJs(iH7rnkmVa8dfzmX3oPb0vIb)ig8idPy4pcAOFKW9Og1kauwSwfzmX3EmqEuYhjCpQrTcaLfRvrgt8TtAaDLyWpIbpYqkg(JGg6hjCpQrLYiOYwb7kYyIV9yG8OKps4EuJkLrqLTc2vKXeF7Kgqxjg8JyWJmKIH)Og7MBmPR1sdHd3BlXUPW9OMUjVU5n2JA6EVTep)927M0izlb3pRBYbHtGq6M59AP41nVXEuJYkyxtgNga6rmG9JeUh1O41nVXEuJYkyxVXeC3u4Eut3KlwRw4EuJ2gyVBAdSRh5sDtEDZBSh1O5vzHRwdU792AGH6T3nPrYwcUFw3KdcNaH0nB6r59APokxJDajjOaKW9hbn0pkVxl1kae2lWvbiH7pQXhL8rc3dwKMg6ge(rmJ9JyjGqYwsXRBEJ9Og9Ykxc7GibQBkCpQPBUSYLWoisG6EVTgKyV9Ujns2sW9Z6MCq4eiKUzEVwk8E0jedeSoBjmogiAajWmQ2Ppk5JY71sH3JoHyGG1zlHXXardibMrfGUsm4hXShXfSR94sDtH7rnDZugbv2kyV792Aqd6T3nPrYwcUFw3KdcNaH0nZ71sTcaH9cCvas4E3u4Eut3mLrqLTc27EVTgCUE7DtAKSLG7N1n5GWjqiDZ8ETuPmckUvWxfGeU)OKpkVxlvkJGIBf8vbORed(rm7rCb7ApU0Js(OMEuEVwkEDZBSh1Oa0vIb)iM9iUGDThx6rqd9JY71sXRBEJ9OgfC1AEuJDtH7rnDZugbv2kyV792AqZP3E3KgjBj4(zDtoiCces3mVxl1r5ASdijbfGeU)OKpkVxlfVU5n2JAu70UPW9OMUzkJGkBfS39EBnWW6T3nPrYwcUFw3KdcNaH0ntbelneoSkrfMxa(XJs(O8ETuhK4XarVtvas4E3u4Eut3mLrqLTc27EVTgWW7T3nPrYwcUFw3KdcNaH0nZ71sXRBEJ9Og1o9rjFeuFKW9Og1kaKoBfSR4hcacHFuYhjCpyrAAOBq4hXm2pILacjBjfVU5n2JA04Jy5XarNwTiWJs(iH7rnQ0JIMWy9YkxcRwBRvdi(HaGqApU0Jy2JwBRvdi4n3JA6Mc3JA6M4Jy5XarNwTiq3mgNaGDQRJv3u4EuJAfasNTc2v8dbaHWSfUh1OwbG0zRGD1vmwZpeaec39EBnG5P3E3KgjBj4(zDtoiCces3mVxlfVU5n2JAu70hL8rn9OMEKW9Og1kaKoBfSR4hcacHFedEuIpk5JCXsJRszeuCRGVkAKSLGFuYhjCpyrAAOBq4hX(rj(OgFe0q)iO(ixS04Qugbf3k4RIgjBj4hbn0ps4EWI00q3GWpIzpkXh14Js(O8ETuhK4XarVtvas4(Jo5rhLRXoGKe04uYAX6y0lBa5WFedEud6Mc3JA6MPhfnHX6LvUeU792AqZR3E3KgjBj4(zDtoiCces3mVxlfVU5n2JAuWvR5rjFeVklC1Au86M3ypQrbORed(rm4rCb7ApU0Js(iO(iEnW7WvlRCjTW5aYJAu0izlb)OKpQPhbt59APUbauaSUwAVaxACfC1AEe0q)iO(iEnW7WvXSiWiwnxWCbMu0izlb)Og7Mc3JA6MRaqzXA7EVTgC(7T3nPrYwcUFw3KdcNaH0nZ71sXRBEJ9OgfGUsm4hXShXfSR94spk5JY71sXRBEJ9Og1o9rqd9JY71sXRBEJ9OgfC1AEuYhXRYcxTgfVU5n2JAua6kXGFedEexWU2Jl1nfUh10nX8cWp6EVTZzOE7DtAKSLG7N1n5GWjqiDZ8ETu86M3ypQrbORed(rm4rq4WQRy8Js(iH7blstdDdc)iM9Oe7Mc3JA6M2Gvmq056M7EVTZLyV9Ujns2sW9Z6MCq4eiKUzEVwkEDZBSh1Oa0vIb)ig8iiCy1vm(rjFuEVwkEDZBSh1O2PDtH7rnDtyGaPgSodiXp6EVTZ1GE7DtAKSLG7N1n5GWjqiDtxaqixDqI1puPC)rmG9JoNHEuYh5ILgxHjbedeTxB(HIgjBj4UPW9OMUjMxa(r37E3u4EWI0UyPXX927TLyV9Ujns2sW9Z6MCq4eiKUPW9GfPPHUbHFeZEuIpk5JY71sXRBEJ9OgfC1AEuYh10JyjGqYws5XL0EP51nVXEuZJy2J4vzHRwJYgSIbIox3ScEdepQ5rqd9JyjGqYws5XL0EP51nVXEuZJya7hzOh1y3u4Eut30gSIbIox3C37T1GE7DtAKSLG7N1n5GWjqiDtO(iwciKSLuWbwYwsZRBEJ9OMhL8rSeqizlP84sAV086M3ypQ5rmG9Jm0JGg6h10J4vzHRwJ6sovaf8giEuZJyWJyjGqYws5XL0EP51nVXEuZJs(iO(ixS04kWEiDT0PvlcOOrYwc(rn(iOH(rUyPXvG9q6APtRweqrJKTe8Js(O8ETuG9q6APtRweqTtFuYhXsaHKTKYJlP9sZRBEJ9OMhXShjCpQrDjNkGIxLfUAnpcAOF0kGC4AaDLyWpIbpILacjBjLhxs7LMx38g7rnpcAOFelbes2sk4alzlP51nVXEut3u4Eut38sovGU3B7C927M0izlb3pRBYbHtGq6MUyPXvILmg7abB4fSETbmQOrYwc(rjFutpkVxlfVU5n2JAuWvR5rjFeuFuEVwQJY1yhqsckajC)rn2nfUh10nHbcKAW6mGe)O7DVBIDzGfaSguU4rn927TLyV9Ujns2sW9Z6MCq4eiKUPW9GfPPHUbHFeZy)iwciKSLuhLRXoGKe0lRCjSdIeOhL8rn9O8ETuhLRXoGKeuas4(JGg6hL3RLAfac7f4QaKW9h1y3u4Eut3CzLlHDqKa19EBnO3E3KgjBj4(zDtoiCces3mVxl1kae2lWvbiH7DtH7rnDZugbv2kyV792oxV9Ujns2sW9Z6MCq4eiKUzEVwQJY1yhqsckajC)rjFuEVwQJY1yhqsckaDLyWpIbps4EuJAfaklwRImM4BN0ECPUPW9OMUzkJGkBfS39EBnNE7DtAKSLG7N1n5GWjqiDZ8ETuhLRXoGKeuas4(Js(OMEukGyPHWHvjQwbGYI1(iOH(rRaqyxaobuc3dw0JGg6hjCpQrLYiOYwb7Qy0lBa5WFuJDtH7rnDZugbv2kyV792mSE7DtAKSLG7N1n5GWjqiDZ8ETu49OtigiyD2syCmq0asGzuTtFuYh10J4vzHRwJcShsxlDA1IakaDLyWp6KhjCpQrb2dPRLoTArafzmX3oP94sp6KhXfSR94spIzpkVxlfEp6eIbcwNTeghdenGeygva6kXGFe0q)iO(ixS04kWEiDT0PvlcOOrYwc(rn(OKpILacjBjLhxs7LMx38g7rnp6KhXfSR94spIzpkVxlfEp6eIbcwNTeghdenGeygva6kXG7Mc3JA6MPmcQSvWE37TXW7T3nPrYwcUFw3KdcNaH0nZ71sDuUg7assqbiH7pk5JCbaHC1bjw)qLY9hXa2p6Cg6rjFKlwACfMeqmq0ET5hkAKSLG7Mc3JA6MPmcQSvWE37TX80BVBsJKTeC)SUjheobcPBM3RLkLrqXTc(QaKW9hL8rCb7ApU0JyWJY71sLYiO4wbFva6kXG7Mc3JA6MPmcQSvWE37T186T3nPrYwcUFw3CJjDRJWsAUG9yG0BlXUjheobcPBc1hTcaHDb4eqjCpyrpk5JG6JyjGqYwsTcaPZwb760QSXa5rjFutpQPh10JeUh1OwbGYI1QiJj(2JbYJs(OMEKW9Og1kauwSwfzmX3oPb0vIb)ig8idPmShbn0pcQpcShAvaiKAfac7f4QOrYwc(rn(iOH(rc3JAuPmcQSvWUImM4Bpgipk5JA6rc3JAuPmcQSvWUImM4BN0a6kXGFedEKHug2JGg6hb1hb2dTkaesTcaH9cCv0izlb)OgFuJpk5JY71sDqIhde9ovbiH7pQXhbn0pQPh5ILgxHjbedeTxB(HIgjBj4hL8rUaGqU6GeRFOs5(Jya7hDod9OKpQPhL3RL6Gepgi6DQcqc3FuYhb1hjCpQrH5fGFOiJj(2JbYJGg6hb1hL3RL6OCn2bKKGcqc3FuYhb1hL3RL6Gepgi6DQcqc3FuYhjCpQrH5fGFOiJj(2JbYJs(iO(OJY1yhqscACkzTyDm6LnGC4pQXh14JASBUXKUwlneoCVTe7Mc3JA6MRaq6SvWE37TD(7T3nPrYwcUFw3KdcNaH0ntbelneoSkrfMxa(XJs(O8ETuhK4XarVtvas4(Js(ixS04kmjGyGO9AZpu0izlb)OKpYfaeYvhKy9dvk3Fedy)OZzOhL8rc3dwKMg6ge(rm4rSeqizlPokxJDajjOxw5syhejqDtH7rnDZugbv2kyV792s0q927M0izlb3pRBYbHtGq6Mq9rSeqizlPspkAcJ1PvzJbYJs(OMEeuFKlwAC1cuxTFqAbFqyfns2sWpcAOFKW9GfPPHUbHFeZEuIpQXhL8rn9iH7blsdxUkGmHtpIbpQbpcAOFKW9GfPPHUbHFeZy)iwciKSLuhcawZfSRxw5syhejqpcAOFKW9GfPPHUbHFeZy)iwciKSLuhLRXoGKe0lRCjSdIeOh1y3u4Eut3m9OOjmwVSYLWDV3wIj2BVBsJKTeC)SUPW9OMUjxSwTW9OgTnWE30gyxpYL6Mc3dwK2flnoU792sSb927M0izlb3pRBYbHtGq6Mc3dwKMg6ge(rm7rj2nfUh10nHbcKAW6mGe)O792s8C927M0izlb3pRBYbHtGq6MUaGqU6GeRFOs5(Jya7hDod9OKpYflnUctcigiAV28dfns2sWDtH7rnDtmVa8JU3BlXMtV9Ujns2sW9Z6MCq4eiKUPW9GfPPHUbHFeZy)iwciKSLucGldPjJtTfoQ5rjF0vgrLY9hXm2pILacjBjLa4YqAY4uBHJA0xzKUPW9OMUPa4YqAY4uBHJA6EVTenSE7DtAKSLG7N1n5GWjqiDtH7blstdDdc)iMX(rSeqizlPoeaSMlyxVSYLWoisG6Mc3JA6MlRCjSdIeOU3BlrgEV9UPW9OMU5kauwS2Ujns2sW9Z6E37MPaIx3S4927TLyV9UPW9OMUPa4Yq6yCYAjU3nPrYwcUFw37T1GE7DtAKSLG7N1nR0UjM8UPW9OMUjlbes2sDtwIDtDZg8Og(rUyPXvlRCjDQ48dfns2sWp6KhDUh1WpcQpYflnUAzLlPtfNFOOrYwcUBYbHtGq6MSeqizlPokxJDajjOxw5syhejqpI9Jmu3KLa0JCPU5r5ASdijb9Ykxc7GibQ792oxV9Ujns2sW9Z6MvA3etE3u4Eut3KLacjBPUjlXUPUzdEud)ixS04QLvUKovC(HIgjBj4hDYJo3JA4hb1h5ILgxTSYL0PIZpu0izlb3n5GWjqiDtwciKSLuhcawZfSRxw5syhejqpI9Jmu3KLa0JCPU5HaG1Cb76LvUe2brcu37T1C6T3nPrYwcUFw3Ss7MyY7Mc3JA6MSeqizl1nzj2n1np3JA4h5ILgxTSYL0PIZpu0izlb)OtEed)rn8JG6JCXsJRww5s6uX5hkAKSLG7MCq4eiKUjlbes2skEDZBSh1Oxw5syhejqpI9Jmu3KLa0JCPUjVU5n2JA0lRCjSdIeOU3BZW6T3nPrYwcUFw3Ss7MyY7Mc3JA6MSeqizl1nzj2n1np)N)h1WpYflnUAzLlPtfNFOOrYwc(rN8Og8Og(rq9rUyPXvlRCjDQ48dfns2sWDtoiCces3KLacjBjLa4YqAY4uBHJAEe7hzOUjlbOh5sDtbWLH0KXP2ch109EBm8E7DtAKSLG7N1nR0UjGWK3nfUh10nzjGqYwQBYsa6rUu3uaCzinzCQTWrn6Rms3eMwY26DZMJH6EVnMNE7DtAKSLG7N1nR0UjGWK3nfUh10nzjGqYwQBYsa6rUu3eMScJ6LvUe2brcu3eMwY26Dtd19EBnVE7DtAKSLG7N1nR0UjGWK3nfUh10nzjGqYwQBYsa6rUu3mHyGTXardi4n3JA6MW0s2wVBAivZP792o)927M0izlb3pRBwPDtm5DtH7rnDtwciKSL6MSe7M6Mgw3KLa0JCPUjoHSgEdepQP792s0q927M0izlb3pRBwPDtm5DtH7rnDtwciKSL6MSe7M6M0PTJ0ucwDfUKbKgFqKRVBCWFe0q)i602rAkbRUYelc7LUw6Rapeg)iOH(r0PTJ0ucwbXkWH4faRZcme6rqd9JOtBhPPeScIvGdXlawFjyXAJAEe0q)i602rAkbRcit4rn6RaHW61gtpcAOFeDA7inLGvUHxgcRZcibCAme(rqd9JOtBhPPeSsm8Ba5hfwJJbcbRtT7RaHEe0q)i602rAkbRKHh046eMY11s3kWW19rqd9JOtBhPPeScFu8eYHtaSEjdKhbn0pIoTDKMsWQH2aXQXmoskM00CidNapcAOFeDA7inLGvzXsRaq6mqg(r3KLa0JCPUjVU5n2JA01O3yQ792smXE7DtAKSLG7N1nR0UjM8UPW9OMUjlbes2sDtwIDtDt602rAkbRedp(qacwVQX11sNwTiWJs(iwciKSLu86M3ypQrxJEJPUjlbOh5sDZvnUgU2zlPRrVXu37TLyd6T3nPrYwcUFw3Ss7MyY7Mc3JA6MSeqizl1nzj2n1nBGHEud)iwciKSLu86M3ypQrxJEJPhDYJmSh1WpIoTDKMsWQRWLmG04dIC9DJdE3KLa0JCPUzn6nM08TxRv37TL456T3nPrYwcUFw3Ss7MyY7Mc3JA6MSeqizl1nzj2n1ntS51n5GWjqiDtwciKSLuRACnCTZwsxJEJPhL8rq9rUyPXvRaqyxaobu0izlb)OKpILacjBj1QgxxlDA1Ia6uaXRBwCn)qMHSpI9Jmu3KLa0JCPU5QgxxlDA1Ia6uaXRBwCn)qMHSDV3wInNE7DtAKSLG7N1nR0UjGWK3nfUh10nzjGqYwQBYsa6rUu3KUPmciXQla8idN0WKvySBctlzB9UzInVU3BlrdR3E3KgjBj4(zDZkTBcim5DtH7rnDtwciKSL6MSeGEKl1n51nVXEuJgFelpgi60Qfb6MW0s2wVB2GU3BlrgEV9Ujns2sW9Z6MJCPUPy4XhcqW6vnUUw60Qfb6Mc3JA6MIHhFiabRx146APtRweO792sK5P3E3u4Eut38gaqb0XvGqDtAKSLG7N19EBj286T3nfUh10ntzeuzRG9Ujns2sW9Z6E37E3KfbWrn92AGHAGHsmXeBEDZwcyIbcUBA4C6pDAJ5TTZhM7rpQ9d6rXnTa(Jwf4rgbQuD6HGjJEeGoTDai4hHRl9iz71vCc(r8dzGqy1Zedfd9idJ5E0PQHfbCc(rg5ILgx1mJEKxpYixS04QMPOrYwc2Oh1udmUr1Zedfd9igoZ9Otvdlc4e8JmYflnUQzg9iVEKrUyPXvntrJKTeSrpQPenUr1Zedfd9igoZ9Otvdlc4e8JmcShAvaiKQzg9iVEKrG9qRcaHuntrJKTeSrpQPgyCJQNjgkg6rNFM7rNQgweWj4hzKlwACvZm6rE9iJCXsJRAMIgjBjyJEutjACJQNjgkg6rjMiZ9Otvdlc4e8JmYflnUQzg9iVEKrUyPXvntrJKTeSrps8h18z(zOh1uIg3O6z6zYW50F60gZBBNpm3JEu7h0JIBAb8hTkWJmcMwY26g9iaDA7aqWpcxx6rY2RR4e8J4hYaHWQNjgkg6rjYCp6u1WIaob)iJa7HwfacPAMrpYRhzeyp0QaqivZu0izlbB0Je)rnFMFg6rnLOXnQEMyOyOh1aM7rNQgweWj4hzKlwACvZm6rE9iJCXsJRAMIgjBjyJEutnW4gvptmum0JmmM7rNQgweWj4hzKlwACvZm6rE9iJCXsJRAMIgjBjyJEutjACJQNjgkg6rmCM7rNQgweWj4hzKlwACvZm6rE9iJCXsJRAMIgjBjyJEutjACJQNjgkg6rmpm3JovnSiGtWpYixS04QMz0J86rg5ILgx1mfns2sWg9OMs04gvptmum0JAGHXCp6u1WIaob)iJa7HwfacPAMrpYRhzeyp0QaqivZu0izlbB0JAkrJBu9mXqXqpQbmCM7rNQgweWj4hzeyp0QaqivZm6rE9iJa7HwfacPAMIgjBjyJEutjACJQNjgkg6rnG5H5E0PQHfbCc(rgb2dTkaes1mJEKxpYiWEOvbGqQMPOrYwc2Oh1uIg3O6zIHIHEudo)m3JovnSiGtWpYixS04QMz0J86rg5ILgx1mfns2sWg9OMs04gvptmum0JoNHyUhDQAyraNGFKrG9qRcaHunZOh51JmcShAvaiKQzkAKSLGn6rI)OMpZpd9OMs04gvptmum0Jo35yUhDQAyraNGFKrG9qRcaHunZOh51JmcShAvaiKQzkAKSLGn6rI)OMpZpd9OMs04gvptptgoN(tN2yEB78H5E0JA)GEuCtlG)OvbEKrPaIx3S4g9iaDA7aqWpcxx6rY2RR4e8J4hYaHWQNjgkg6rnG5E0PQHfbCc(rg5ILgx1mJEKxpYixS04QMPOrYwc2Oh1uIg3O6zIHIHEudyUhDQAyraNGFKrUyPXvnZOh51JmYflnUQzkAKSLGn6rI)OMpZpd9OMs04gvptmum0JohZ9Otvdlc4e8JmYflnUQzg9iVEKrUyPXvntrJKTeSrpQPenUr1Zedfd9OZXCp6u1WIaob)iJCXsJRAMrpYRhzKlwACvZu0izlbB0Je)rnFMFg6rnLOXnQEMyOyOh1CyUhDQAyraNGFKrUyPXvnZOh51JmYflnUQzkAKSLGn6rnLOXnQEMyOyOh1CyUhDQAyraNGFKrUyPXvnZOh51JmYflnUQzkAKSLGn6rI)OMpZpd9OMs04gvptmum0JmmM7rNQgweWj4hzKlwACvZm6rE9iJCXsJRAMIgjBjyJEutjACJQNjgkg6rggZ9Otvdlc4e8JmYflnUQzg9iVEKrUyPXvntrJKTeSrps8h18z(zOh1uIg3O6zIHIHEuINJ5E0PQHfbCc(rg5ILgx1mJEKxpYixS04QMPOrYwc2Oh1uIg3O6z6zYW50F60gZBBNpm3JEu7h0JIBAb8hTkWJmIx38g7rnAEvw4Q1Gn6ra602bGGFeUU0JKTxxXj4hXpKbcHvptmum0JAEm3JovnSiGtWpYiWEOvbGqQMz0J86rgb2dTkaes1mfns2sWg9OMs04gvptptgoN(tN2yEB78H5E0JA)GEuCtlG)OvbEKrc3dwK2flno2OhbOtBhac(r46sps2EDfNGFe)qgiew9mXqXqpQbm3JovnSiGtWpYixS04QMz0J86rg5ILgx1mfns2sWg9OMAGXnQEMyOyOhDoM7rNQgweWj4hzKlwACvZm6rE9iJCXsJRAMIgjBjyJEutjACJQNPNjdNt)PtBmVTD(WCp6rTFqpkUPfWF0QapYiSldSaG1GYfpQXOhbOtBhac(r46sps2EDfNGFe)qgiew9mXqXqpYWyUhDQAyraNGFKrUyPXvnZOh51JmYflnUQzkAKSLGn6rnLOXnQEMyOyOhXWzUhDQAyraNGFKrUyPXvnZOh51JmYflnUQzkAKSLGn6rI)OMpZpd9OMs04gvptmum0JAEm3JovnSiGtWpYixS04QMz0J86rg5ILgx1mfns2sWg9OMs04gvptmum0JAEm3JovnSiGtWpYiWEOvbGqQMz0J86rgb2dTkaes1mfns2sWg9OMAGXnQEMyOyOhD(zUhDQAyraNGFKrUyPXvnZOh51JmYflnUQzkAKSLGn6rnLOXnQEMyOyOhLOHyUhDQAyraNGFKrUyPXvnZOh51JmYflnUQzkAKSLGn6rnLOXnQEMyOyOhL45yUhDQAyraNGFKrUyPXvnZOh51JmYflnUQzkAKSLGn6rI)OMpZpd9OMs04gvptptgoN(tN2yEB78H5E0JA)GEuCtlG)OvbEKr86M3ypQrNEiyYOhbOtBhac(r46sps2EDfNGFe)qgiew9mXqXqpkXezUhDQAyraNGFKr8AG3HRAMrpYRhzeVg4D4QMPOrYwc2Oh1uIg3O6zIHIHEuInG5E0PQHfbCc(rgXRbEhUQzg9iVEKr8AG3HRAMIgjBjyJEutjACJQNjgkg6rjEoM7rNQgweWj4hzg3t9imJJlg)iMVEKxpIH2YJGdwboQ5rvkbeVapQjO04JAQbg3O6zIHIHEuINJ5E0PQHfbCc(rgXRbEhUQzg9iVEKr8AG3HRAMIgjBjyJEutjACJQNjgkg6rj2CyUhDQAyraNGFKrG9qRcaHunZOh51JmcShAvaiKQzkAKSLGn6rnLOXnQEMyOyOhLOHXCp6u1WIaob)iJa7HwfacPAMrpYRhzeyp0QaqivZu0izlbB0JAkrJBu9mXqXqpkrgoZ9Otvdlc4e8JmcShAvaiKQzg9iVEKrG9qRcaHuntrJKTeSrpQPenUr1Zedfd9OgW8WCp6u1WIaob)iJCXsJRAMrpYRhzKlwACvZu0izlbB0JAQbg3O6zIHIHEudAEm3JovnSiGtWpYiEnW7WvnZOh51JmIxd8oCvZu0izlbB0JAQbg3O6zIHIHE05AaZ9Otvdlc4e8JmYflnUQzg9iVEKrUyPXvntrJKTeSrps8h18z(zOh1uIg3O6z6zI59MwaNGFeZZJeUh18iBGDS6zQBMcQvyPUzd9igwaOhD6kqONPg6rhUNIzoOafiHFSZkEDHcoUBR4rnCGSCOGJlhkptn0JARyr3mbEudoNbpQbgQbg6z6zQHE0PoKbcHzUNPg6rN3JAUX0JwbKdxdORed(raXpiWJ8dzEKlaiKR84sAV0Wb9OvbEKvW(5HjEnWpsYHnCgF0glqiS6zQHE059OM7uyXPhzlib)raI5EedT5b8JoFbi5Ivptn0JoVhXqvHP5rCb7pcqN2oa0Lgh)OvbE0PQBEJ9OMh1uOiLbpcUgJ8hDuw4hf(Jwf4rYJwacF8OtxYPc8iUG9gvptn0JoVh18hjBPhHDqW9hXpiEcXa5r18i5rlQ1Jwfib8JI5r(b9OtVHld9iVEeGG3C6rTkqc2sGvptptn0JA(gt8TtWpktRcqpIx3S4pktqIbRE0PNZPuh)OPMZ7qa312(iH7rn4hvJLr1ZKW9OgSkfq86Mf)e2qraCziDmozTe3FMAOh1(rGFelbes2spcNs8yfe(r(b9OzFZe4r16rUaGqo(rI)Owhb)4rnxL)ithqscpIHzLlHDqKaHFuTDCatpQwp6u1nVXEuZJWh12c)Om9OnMGvptc3JAWQuaXRBw8tydfwciKSLmyKlX(OCn2bKKGEzLlHDqKazqLYgtUbXInlbes2sQJY1yhqsc6LvUe2brceBdzalXUj2nOHDXsJRww5s6uX5hNCUggQUyPXvlRCjDQ48JNPg6rTFe4hXsaHKT0JWPepwbHFKFqpA23mbEuTEKlaiKJFK4pQ1rWpEuZLaGF0PeS)igMvUe2brce(r12Xbm9OA9Otv38g7rnpcFuBl8JY0J2yc(rc(rRWAjG6zs4EudwLciEDZIFcBOWsaHKTKbJCj2hcawZfSRxw5syhejqguPSXKBqSyZsaHKTK6qaWAUGD9Ykxc7GibITHmGLy3e7g0WUyPXvlRCjDQ48JtoxddvxS04QLvUKovC(XZud9O2pc8JyjGqYw6r4uIhRGWpYpOhn7BMapQwpYfaeYXps8h16i4hpQ5Q8hz6ass4rmmRCjSdIei8Jea9OnMGFe8gedKhDQ6M3ypQr9mjCpQbRsbeVUzXpHnuyjGqYwYGrUeBEDZBSh1Oxw5syhejqguPSXKBqSyZsaHKTKIx38g7rn6LvUe2brceBdzalXUj2NRHDXsJRww5s6uX5hNWWByO6ILgxTSYL0PIZpEMAOh1(rGFelbes2spcNs8yfe(r(b9OzFZe4r16rUaGqo(rI)Owhb)4rNEaxg6rnFJtTfoQ5r12Xbm9OA9Otv38g7rnpcFuBl8JY0J2ycw9mjCpQbRsbeVUzXpHnuyjGqYwYGrUeBbWLH0KXP2ch1yqLYgtUbXInlbes2skbWLH0KXP2ch1W2qgWsSBI95)83WUyPXvlRCjDQ48JtAqddvxS04QLvUKovC(XZud9O2pc8JyjGqYw6r4uIhRGWpYpOhLsaonUaHEuTE0vg5rzYwTEuRJGF8OtpGld9OMVXP2ch18OwH1(OP8hLPhTXeS6zs4EudwLciEDZIFcBOWsaHKTKbJCj2cGldPjJtTfoQrFLrmaMwY26SBogYGkLnGWK)m1qpQ9Ja)iwciKSLEuGF0gtWpYRhHtjESy8r(b9i5w7XFuTEKhx6rX8imXRbg)i)q8hD3y)rPcg)iz5e4rNQU5n2JAEezCAai8JY0Qa0Jyyw5syhejq4h1kS2hLPhTXe8JMcCfRLr1ZKW9OgSkfq86Mf)e2qHLacjBjdg5sSHjRWOEzLlHDqKazamTKT1zBidQu2act(Zud9idNWpEeZNyGTXaXGhDQ6M3ypQXi8J4vzHRwZJAfw7JY0Jae8MtWpkZ4JKhbKbUUpsU1ECdEuE7pYpOhn7BMapQwpIdch)iSlah)iweGXhDeqoEKSCc8iH7blXJbYJovDZBSh18izGFe2wTWpcUAnpYRwcag)i)GEenWpQwp6u1nVXEuJr4hXRYcxTg1JmCoO5rxjHyG8iyIh4Og8JI5r(b9OtVHldzWJovDZBSh1ye(ra6kXedKhXRYcxTMhf4hbi4nNGFuMXh5hb(rlGW9OMh51JeoV2J)OvbEeZNyGTXar9mjCpQbRsbeVUzXpHnuyjGqYwYGrUe7eIb2gdenGG3CpQXayAjBRZ2qQMJbvkBaHj)zQHEu7h0JG3aXJAEuTEK8iZ98iMpXaXi8JoZsyCmqE0PQBEJ9Og1ZKW9OgSkfq86Mf)e2qHLacjBjdg5sSXjK1WBG4rnguPSXKBalXUj2g2ZKW9OgSkfq86Mf)e2qHLacjBjdg5sS51nVXEuJUg9gtguPSXKBalXUj20PTJ0ucwDfUKbKgFqKRVBCWHgA602rAkbRUYelc7LUw6Rapegdn00PTJ0ucwbXkWH4faRZcmecAOPtBhPPeScIvGdXlawFjyXAJAGgA602rAkbRcit4rn6RaHW61gtqdnDA7inLGvUHxgcRZcibCAmegAOPtBhPPeSsm8Ba5hfwJJbcbRtT7RaHGgA602rAkbRKHh046eMY11s3kWW1fAOPtBhPPeScFu8eYHtaSEjdeOHMoTDKMsWQH2aXQXmoskM00CidNaqdnDA7inLGvzXsRaq6mqg(XZKW9OgSkfq86Mf)e2qHLacjBjdg5sSx14A4ANTKUg9gtguPSXKBalXUj20PTJ0ucwjgE8HaeSEvJRRLoTArGKSeqizlP41nVXEuJUg9gtptc3JAWQuaXRBw8tydfwciKSLmyKlXUg9gtA(2R1YGkLnMCdyj2nXUbgQHzjGqYwsXRBEJ9OgDn6nMoXWAy602rAkbRUcxYasJpiY13no4ptn0JA)iWpILacjBPhbtobUXq4h16GMhD6n84dbigHFedRg)r16rgUvlc8Oa)OnMGFuMwfGEKFqpkDBTpkwpkVe1QgxxlDA1Ia6uaXRBwCn)qMHSpkWpAk)r4uIhRGGvptc3JAWQuaXRBw8tydfwciKSLmyKlXEvJRRLoTAraDkG41nlUMFiZqwdQu2yYnGLy3e7eBEgel2SeqizlPw14A4ANTKUg9gtjHQlwAC1kae2fGtGKSeqizlPw146APtRweqNciEDZIR5hYmKLTHEMAOh1CvTEKTgipktRcqp6u1nVXEuZJWh12c)OM)nLraj2hX8dGhz40JY0J2ycM5Bptc3JAWQuaXRBw8tydfwciKSLmyKlXMUPmciXQla8idN0WKvy0ayAjBRZoXMNbvkBaHj)zQHEu7h0JM9ntGhvRh5cac54hzEelpgipYWTArGhHpQTf(rz6rBmb)OAEe8gedKhDQ6M3ypQr9mjCpQbRsbeVUzXpHnuyjGqYwYGrUeBEDZBSh1OXhXYJbIoTAradGPLSTo7gyqLYgqyYFMeUh1GvPaIx3S4NWgkBmPdNUgmYLylgE8HaeSEvJRRLoTArGNjH7rnyvkG41nl(jSHYnaGcOJRaHEMeUh1GvPaIx3S4NWgkPmcQSvW(Z0Zud9OMVXeF7e8JiweGXh5XLEKFqps4EbEuGFKWscRKTK6zs4EudMnV2JtaCkzTgel2qfShAvaiKcoW8i1gJayuZR7vg4NjH7rn4tydfwciKSLmyKlX2JlP9sZRBEJ9OgdQu2yYnGLy3eBxS04QvaiSlaNan8kae2fGtafGUsm4tAIxLfUAnkEDZBSh1Oa0vIb3WnL45XsaHKTKkHyGTXardi4n3JAAyxS04QeIb2gdKgBSHHkVklC1Au86M3ypQrbibMXgoVxlfVU5n2JAuWvR5zQHE0PRKa9i8gqp6u1nVXEuZJc8JGjRWib)Oy9OHiyc(rzbtWpQMh5h0JOBkJasS6capYWjnmzfgFelbes2sptc3JAWNWgkSeqizlzWixIThxs7LMx38g7rnguPSVIXgWsSBInlbes2sk6MYiGeRUaWJmCsdtwHXZRjEvw4Q1OOBkJasS6capYWjf8giEuZ5XRYcxTgfDtzeqIvxa4rgoPa0vIb3yddvEvw4Q1OOBkJasS6capYWjfGeygniwSPtBhPPeSIUPmciXQla8idNEMeUh1GpHnuyjGqYwYGrUeBpUK2lnVU5n2JAmOszFfJnGLy3eBEvw4Q1OGyf4q8cG1zbgcPa0vIbBqSytN2ostjyfeRahIxaSolWqONjH7rn4tydfwciKSLmyKlX2JlP9sZRBEJ9OgdQu2xXydyj2nXoVxlfypKUw60Qfbua6kXGniwSDXsJRa7H01sNwTiqY8ETu86M3ypQrbxTMNjH7rn4tydfwciKSLmyKlX2JlP9sZRBEJ9OgdQu2xXydyj2nXMxLfUAnkWEiDT0PvlcOa0vIbFsEVwkWEiDT0PvlcOG3aXJAmiwSDXsJRa7H01sNwTiqY8ETu86M3ypQrbxTMK8QSWvRrb2dPRLoTArafGUsm4tmmgWsaHKTKYJlP9sZRBEJ9OMNjH7rn4tydf8rS8yGOtRweWGyXoVxlfVU5n2JAuWvRjjlbes2skpUK2lnVU5n2JAy2ABTAabV5EutYM4vzHRwJcShsxlDA1IakaDLyWmBTTwnGG3CpQbAOHQlwACfypKUw60QfbA8zs4Eud(e2qbiWHmUgNkGemiwSBkVxlfVU5n2JAuWvRjzEVwkWEiDT0PvlcOGRwtYMyjGqYws5XL0EP51nVXEuddiJj(2jThxcAOzjGqYws5XL0EP51nVXEudZ4vzHRwJciWHmUgNkGeuWBG4rnn2i0q3uEVwkWEiDT0PvlcO2PjzjGqYws5XL0EP51nVXEudZoNHA8zs4Eud(e2qbMe)ixGHmiwSZ71sXRBEJ9OgfC1AsM3RLcShsxlDA1Iak4Q1KKLacjBjLhxs7LMx38g7rnmGmM4BN0ECPNjH7rn4tydLBaafqhxbczqSyN3RLIx38g7rnk4Q1KeMY71sbe4qgxJtfqcAwB7qajh2WzubxTMNjH7rn4tydLnM0HtxdO1I4UEKlXgIvGdXlawNfyiKbXInlbes2skpUK2lnVU5n2JAygVklC1Aopd7zs4Eud(e2qzJjD401GrUeB6MYiGeRUaWJmCYGyXMLacjBjLhxs7LMx38g7rnmGnlbes2sk6MYiGeRUaWJmCsdtwHXNjH7rn4tydLnM0Htxdg5sSX12Qdit4eWGyXMLacjBjLhxs7LMx38g7rnmJnlbes2sQA0BmP5BVwRNjH7rn4tydLnM0Htxdg5sSHyzm9qxlTGXXnSIh1yqSyZsaHKTKYJlP9sZRBEJ9OgMXMLacjBjvn6nM08TxR1ZKW9Og8jSHYgt6WPRbJCj2xHlzaPXhe567ghCdIfBwciKSLuECjTxAEDZBSh1Wa2g2ZKW9Og8jSHYgt6WPRbJCj2WasGxbG0SimMSgel2SeqizlP84sAV086M3ypQHzSzjGqYwsvJEJjnF71A9mjCpQbFcBOSXKoC6AWixITy4XhcqW6vnUUw60QfbmiwSzjGqYws5XL0EP51nVXEuddyByNKOH1WSeqizlPw14A4ANTKUg9gtjzjGqYws5XL0EP51nVXEudZm0ZKW9Og8jSHcKTaGdz01slgEcu(HbXIDtSeqizlP84sAV086M3ypQHbjAiOHEfqoCnGUsmygWsaHKTKYJlP9sZRBEJ9OMgFMeUh1GpHnu41WPXbItW6LvU0ZKW9Og8jSHcGK0yGOxw5s4NjH7rn4tydLvX3ycwlgEceoPZKCFMeUh1GpHnus3GyXymq0zRG9NjH7rn4tydfqKMAjDmACQWPNjH7rn4tydf)G07jx7bwVkaNEMAOhD(q(J8d6rWbMhP2yeaJAEDVYa)O8ETE0o1GhThlHXpIx38g7rnpkWpcx1OEMeUh1GpHnu41ECcGtjR1GyXgShAvaiKcoW8i1gJayuZR7vg4K8QSWvRrL3RLgoW8i1gJayuZR7vgyfGeygtM3RLcoW8i1gJayuZR7vgyTa4Yqk4Q1KKLacjBjLhxs7LMx38g7rnm7CgkjuZ71sbhyEKAJramQ519kdSAN(mjCpQbFcBOiaUmKMmo1w4OgdIfBWEOvbGqk4aZJuBmcGrnVUxzGtYRYcxTgvEVwA4aZJuBmcGrnVUxzGvasGzmzEVwk4aZJuBmcGrnVUxzG1cGldPGRwtswciKSLuECjTxAEDZBSh1WSZzOKqnVxlfCG5rQngbWOMx3RmWQD6ZKW9Og8jSHYcuypxw3GyXgShAvaiKcoW8i1gJayuZR7vg4K8QSWvRrL3RLgoW8i1gJayuZR7vgyfGeygtM3RLcoW8i1gJayuZR7vgy9cuyxbxTMKSeqizlP84sAV086M3ypQHzNZqjHAEVwk4aZJuBmcGrnVUxzGv70NjH7rn4tydfUyTAH7rnABGDdg5sS51nVXEuJo9qWKbXInuzjGqYwsbhyjBjnVU5n2JAsYsaHKTKYJlP9sZRBEJ9OggW2qptc3JAWNWgkSeqizlzWixI9kaKoBfSRtRYgdedyj2nXgQSeqizlPGdSKTKMx38g7rnjzjGqYws5XL0EP51nVXEuddeUh1OwbG0zRGD1ABTAaXpeaes7XLopH7rnk8rS8yGOtRweqT2wRgqWBUh10WnXRYcxTgf(iwEmq0PvlcOa0vIbZawciKSLuECjTxAEDZBSh10yswciKSLuECjTxAEDZBSh1WGva5W1a6kXGHgAxS04kWEiDT0PvlcKmVxlfypKUw60QfbuWvRjjVklC1AuG9q6APtRweqbORedMbc3JAuRaq6SvWUATTwnG4hcacP94sNNW9Ogf(iwEmq0PvlcOwBRvdi4n3JAA4M4vzHRwJcFelpgi60Qfbua6kXGzaVklC1AuG9q6APtRweqbORedUXK8QSWvRrb2dPRLoTArafGUsmygScihUgqxjg8ZKW9Og8jSHclbes2sgmYLyNEu0egRtRYgdedyj2nXgQSeqizlPGdSKTKMx38g7rnjzjGqYws5XL0EP51nVXEuddeUh1OspkAcJ1lRCjSATTwnG4hcacP94sNNW9Ogf(iwEmq0PvlcOwBRvdi4n3JAA4M4vzHRwJcFelpgi60Qfbua6kXGzalbes2skpUK2lnVU5n2JAAmjlbes2skpUK2lnVU5n2JAyWkGC4AaDLyWqdnyp0QaqifEp6eIbcwNTeghdKNjH7rn4tydfWEiDT0PvlcyqSyN3RLcShsxlDA1Iak4Q1KeQ59APwbGWEbUkajCpztSeqizlP84sAV086M3ypQHzSZ71sb2dPRLoTAraf8giEutswciKSLuECjTxAEDZBSh1WmH7rnQvaiD2kyxT2wRgq8dbaH0ECjOHMLacjBjLhxs7LMx38g7rnmBfqoCnGUsmyOHMLacjBjfCGLSL086M3ypQPXNjH7rn4tydfUyTAH7rnABGDdg5sSbvQo9qWKbXIDEVwkWEiDT0PvlcO2PjBILacjBjLhxs7LMx38g7rnmZqn(mjCpQbFcBOWsaHKTKbJCj2PhfnHX60QSXaXawIDtSzjGqYws5XL0EP51nVXEuddeUh1OspkAcJ1lRCjSATTwnG4hcacP94sjzjGqYws5XL0EP51nVXEuddwbKdxdORedgAOb7HwfacPW7rNqmqW6SLW4yG8m1qpYW5GMh1CjayUG9yG8igMvU0JmDqKazWJyybGE0zwb74hHpQTf(rz6rBmb)iVEeeAiG40JAUk)rMoGKeWpsg4h51JiJDAGF0zwb7e4rNUc2jG6zs4Eud(e2qzfasNTc2nyJjDTwAiCy2jAWgt6whHL0Cb7XaHDIgel2qLLacjBj1kaKoBfSRtRYgdKKnXsaHKTKYJlP9sZRBEJ9OgMziOHw4EWI00q3GWmJnlbes2sQdbaR5c21lRCjSdIeOKqDfac7cWjGs4EWIsc18ETuhLRXoGKeuas4EYMY71sDqIhde9ovbiH7jfUh1Oww5syhejqkYyIVDsdORedMbgszyqdn)qaqiSEbeUh1iwMXUbn24Zud9OZxBqmqEedlae2fGtadEedla0JoZkyh)ibqpAJj4hHJByfGLXh51JG3GyG8Otv38g7rnQhD(qdbeRLrdEKFqm(ibqpAJj4h51JGqdbeNEuZv5pY0bKKa(rToO5rCq44h1kS2hnL)Om9Owc2j4hjd8JAf(XJoZkyNap60vWobm4r(bX4JWh12c)Om9iCkGe4hvB)rE9OReJlX8i)GE0zwb7e4rNUc2jWJY71s9mjCpQbFcBOScaPZwb7gSXKUwlneom7enyJjDRJWsAUG9yGWordIf7vaiSlaNakH7blkj)qaqimZyNysOYsaHKTKAfasNTc21PvzJbsYMGQW9Og1kauwSwfzmX3EmqscvH7rnQugbv2kyxfJEzdihEY8ETuhK4XarVtvas4o0qlCpQrTcaLfRvrgt8ThdKKqnVxl1r5ASdijbfGeUdn0c3JAuPmcQSvWUkg9Ygqo8K59APoiXJbIENQaKW9KqnVxl1r5ASdijbfGeU34Zud9OtpRkGFexstJbYJyybGE0zwb7pIFiaie(rTocl9i(HmdzJbYJmpILhdKhz4wTiWZKW9Og8jSHYkaKoBfSBWgt6whHL0Cb7XaHDIgel2c3JAu4Jy5XarNwTiGImM4BpgijxBRvdi(HaGqApUedeUh1OWhXYJbIoTAraLh8e0acEZ9OMK59APokxJDajjOGRwZZKW9Og8jSHcxSwTW9OgTnWUbJCj2yxgybaRbLlEuJbXIDtSeqizlP84sAV086M3ypQHzgcAOzjGqYwsbhyjBjnVU5n2JAAmzEVwkWEiDT0PvlcOGRwZZKW9Og8jSHcMxa(XZ0ZKW9OgSs4EWI0UyPXXSTbRyGOZ1nBqSylCpyrAAOBqyMLyY8ETu86M3ypQrbxTMKnXsaHKTKYJlP9sZRBEJ9OgMXRYcxTgLnyfdeDUUzf8giEud0qZsaHKTKYJlP9sZRBEJ9OggW2qn(mjCpQbReUhSiTlwAC8jSHYLCQagel2qLLacjBjfCGLSL086M3ypQjjlbes2skpUK2lnVU5n2JAyaBdbn0nXRYcxTg1LCQak4nq8OggWsaHKTKYJlP9sZRBEJ9OMKq1flnUcShsxlDA1Iancn0UyPXvG9q6APtRweizEVwkWEiDT0PvlcO2PjzjGqYws5XL0EP51nVXEudZeUh1OUKtfqXRYcxTgOHEfqoCnGUsmygWsaHKTKYJlP9sZRBEJ9OgOHMLacjBjfCGLSL086M3ypQ5zs4EudwjCpyrAxS044tydfyGaPgSodiXpmiwSDXsJRelzm2bc2Wly9Adymzt59AP41nVXEuJcUAnjHAEVwQJY1yhqsckajCVXNPNjH7rnyfVU5n2JA08QSWvRbZoT8OMNjH7rnyfVU5n2JA08QSWvRbFcBOKTvbRxBaJptc3JAWkEDZBSh1O5vzHRwd(e2qjtambsigiptc3JAWkEDZBSh1O5vzHRwd(e2qzfakBRc(zs4EudwXRBEJ9OgnVklC1AWNWgkYWjSdeRMlw7ZKW9OgSIx38g7rnAEvw4Q1GpHnu2yshoDXptc3JAWkEDZBSh1O5vzHRwd(e2qzJjD401GnM01APHWHzNOb0ArCxpYLydXkWH4faRZcmeYGyXw4EuJ6sovavm6LnGC4qdnVklC1AuxYPcOa0vIbZSen0ZKW9OgSIx38g7rnAEvw4Q1GpHnu84s6wci1GyXgShAvaiKYPBAbeRULastM3RLIm(q2ypQrTtFMEMeUh1Gv86M3ypQrNEiyITnGC4y957nmKlnUbXIDEVwkEDZBSh1OGRwZZud9OMp2JR40JoQwpYwdKhDQ6M3ypQ5rTcR9rwb7pYpKjb8J86rM75rmFIbIr4hDMLW4yG8iVEem5e4gd9OJQ1JyybGE0zwb74hHpQTf(rz6rBmbREMeUh1Gv86M3ypQrNEiy6e2qHLacjBjdg5sSjJDAGjynVU5n2JA0a6kXGnOszJj3awIDtSZ71sXRBEJ9OgfGUsm4tY71sXRBEJ9Ogf8giEutd3eVklC1Au86M3ypQrbORedMb59AP41nVXEuJcqxjgCJptn0Jo9WW4h5h0JG3aXJAEuTEKFqpYCppI5tmqmc)OZSeghdKhDQ6M3ypQ5rE9i)GEenWpQwpYpOhX3aan(JovDZBSh18Oy9i)GEexW(JAvBl8J41n1so9i4nigipYpc8JovDZBSh1OEMeUh1Gv86M3ypQrNEiy6e2qHLacjBjdg5sSjJDAGjynVU5n2JA0a6kXGnOszlWWgWsSBInlbes2skCczn8giEuJbXIDEVwk8E0jedeSoBjmogiAajWmQ2Pqdnlbes2skYyNgycwZRBEJ9OgnGUsmyMLOYWAyiCy1vmUHBkVxlfEp6eIbcwNTeghde1vmwJDHNW5L3RLcVhDcXabRZwcJJbIc7cpHgFMeUh1Gv86M3ypQrNEiy6e2qjlq01s7GGNa2GyXoVxlfVU5n2JAuWvR5zs4EudwXRBEJ9OgD6HGPtydfBWkgi6CDZgel2c3dwKMg6geMzjMmVxlfVU5n2JAuWvR5zs4EudwXRBEJ9OgD6HGPtydLBaafaRRL2lWLg3GyXoVxlfVU5n2JAuWvRjzEVwkWEiDT0PvlcOGRwZZKW9OgSIx38g7rn60dbtNWgkBmPdNUgmYLyFWykb8dajW6wGa7Task2GyXoVxlfVU5n2JAu70Kc3JAuRaq6SvWUIFiaieMTHskCpQrTcaPZwb7kaXpeaes7XLygeoS6kg)mjCpQbR41nVXEuJo9qW0jSHs2wfSUwA)G00qxgFMeUh1Gv86M3ypQrNEiy6e2q5s3cWOUwA7MhWAyajx8ZKW9OgSIx38g7rn60dbtNWgkTkGfMffJgq4AKHtptn0Jyyf4rmFNg)GrGbpAJPhjpIHfa6rNzfS)i(HaGqpcEdIbYJoDdaOa4hvRh1EbU04pIly)rE9iHvfWpIlPPXa5r8dbaHWpkwpI5Dweye7JoLG5cm9Oa)OP8hHjlXDcw9mjCpQbR41nVXEuJo9qW0jSHYkaKoBfSBWgt6whHL0Cb7XaHDIgel2c3JAu3aakawxlTxGlnUImM4BpgijxBRvdi(HaGqApU05jCpQrDdaOayDT0EbU04kYyIVDsdORedMbnNKq9OCn2bKKGgNswlwhJEzdihEsOM3RL6OCn2bKKGcqc3t2uEVwkEDZBSh1O2Pqdnu51aVdxfZIaJy1CbZfyQXNPg6rgoHFuB)rmVZIaJyF0PemxGjdE057n2F0gtpIHfa6rNzfSJFuRdAEKFqm(Ow1yK)O7E4hpIdch)izGFuRdAEedlae2lW9rb(rWvRr9mjCpQbR41nVXEuJo9qW0jSHYkaKoBfSBWgt6AT0q4WSt0GnM0ToclP5c2Jbc7eniwSHQy4jq4KkBfSta9vWobu0izlbNSjH7blstdDdcZa2c3dwKgUCvazcNGgAOYRYcxTgv6rrtySEzLlHvasGzSXKqLxd8oCvmlcmIvZfmxGPK8dbaHWmJDIjZ71sXRBEJ9Og1onjuZ71sTcaH9cCvas4EsOM3RL6OCn2bKKGcqc3tEuUg7assqJtjRfRJrVSbKd)K8ETuhK4XarVtvas4odAWZud9idNWpEeZ7SiWi2hDkbZfyYGhXWca9OZSc2F0gtpcFuBl8JY0Jey4WJAelJpIxd2bsme8JW1J8dXFu4pkWpAk)rz6rBmb)O9yjm(rmVZIaJyF0PemxGPhf4hj5A7pYRhrgNga6rf4r(bbOhja6r3cqpYpK5r0uBihpIHfa6rNzfSJFKxpIm2Pb(rmVZIaJyF0PemxGPh51J8d6r0a)OA9Otv38g7rnQNjH7rnyfVU5n2JA0PhcMoHnuwbG0zRGDd2ysxRLgchMDIgSXKU1ryjnxWEmqyNObXInufdpbcNuzRGDcOVc2jGIgjBj4KnjCpyrAAOBqygWw4EWI0WLRcit4e0qdvEvw4Q1OspkAcJ1lRCjScqcmJnMKxd8oCvmlcmIvZfmxGPK8dbaHWmJDIjBQjH7rnQvaiD2kyxXpeaecRxaH7rnI9KMyjGqYwsrg70atWAEDZBSh1Ob0vIbFE59APIzrGrSAUG5cmPG3aXJAAK5lEvw4Q1OwbG0zRGDf8giEuZ5XsaHKTKIm2PbMG186M3ypQrdORedM5RMY71sfZIaJy1CbZfysbVbIh1CEq4WQRyCJnYm2gcAOzjGqYwsrg70atWAEDZBSh1Ob0vIbZa259APIzrGrSAUG5cmPG3aXJAGg68ETuXSiWiwnxWCbMua6kXGzaeoS6kgdn08QSWvRrHpILhdeDA1IakajWmMu4EWI00q3GWmJnlbes2skEDZBSh1OXhXYJbIoTArGK8IfnY4QjGC46LqnMmVxlfVU5n2JAu70Knb18ETuRaqyVaxfGeUdn059APIzrGrSAUG5cmPa0vIbZadPmSgtc18ETuhLRXoGKeuas4EYJY1yhqscACkzTyDm6LnGC4NK3RL6Gepgi6DQcqc3zqdEMeUh1Gv86M3ypQrNEiy6e2qHx7XjaoLSwdIfBWEOvbGqk4aZJuBmcGrnVUxzGtM3RLcoW8i1gJayuZR7vgyfC1AsM3RLcoW8i1gJayuZR7vgyTa4Yqk4Q1KKxLfUAnQ8ET0WbMhP2yeaJAEDVYaRaKaZ4ZKW9OgSIx38g7rn60dbtNWgkcGldPjJtTfoQXGyXgShAvaiKcoW8i1gJayuZR7vg4K59APGdmpsTXiag186ELbwbxTMK59APGdmpsTXiag186ELbwlaUmKcUAnj5vzHRwJkVxlnCG5rQngbWOMx3RmWkajWm(mjCpQbR41nVXEuJo9qW0jSHYcuypxw3GyXgShAvaiKcoW8i1gJayuZR7vg4K59APGdmpsTXiag186ELbwbxTMK59APGdmpsTXiag186ELbwVaf2vWvR5zs4EudwXRBEJ9OgD6HGPtydfUyTAH7rnABGDdg5sSfUhSiTlwAC8ZKW9OgSIx38g7rn60dbtNWgk86M3ypQXGnM01APHWHzNObBmPBDewsZfShde2jAqSyN3RLIx38g7rnk4Q1KSjWEOvbGqk4aZJuBmcGrnVUxzGzN3RLcoW8i1gJayuZR7vgy1oTXKnjCpQrDjNkGkg9Ygqo8Kc3JAuxYPcOIrVSbKdxdORedMbSnKIHdn0c3JAuyEb4hkYyIV9yGKu4EuJcZla)qrgt8TtAaDLyWmWqkgo0qlCpQrTcaLfRvrgt8ThdKKc3JAuRaqzXAvKXeF7KgqxjgmdmKIHdn0c3JAuPmcQSvWUImM4BpgijfUh1OszeuzRGDfzmX3oPb0vIbZadPy4n(m1qpI53piWJ4vzHRwd(r(H4pcFuBl8JY0J2yc(rTc)4rNQU5n2JAEe(O2w4hvJLXhLPhTXe8JAf(XJK5rc33I9rNQU5n2JAEexW(JKb(rt5pQv4hpsEK5EEeZNyGye(rNzjmogipkfuC1ZKW9OgSIx38g7rn60dbtNWgkCXA1c3JA02a7gmYLyZRBEJ9OgnVklC1AWgel259AP41nVXEuJYkyxtgNgaIbSfUh1O41nVXEuJYkyxVXe8ZKW9OgSIx38g7rn60dbtNWgklRCjSdIeidIf7MY71sDuUg7assqbiH7qdDEVwQvaiSxGRcqc3BmPW9GfPPHUbHzgBwciKSLu86M3ypQrVSYLWoisGEMeUh1Gv86M3ypQrNEiy6e2qjLrqLTc2niwSZ71sH3JoHyGG1zlHXXardibMr1onzEVwk8E0jedeSoBjmogiAajWmQa0vIbZmUGDThx6zs4EudwXRBEJ9OgD6HGPtydLugbv2ky3GyXoVxl1kae2lWvbiH7ptc3JAWkEDZBSh1OtpemDcBOKYiOYwb7gel259APszeuCRGVkajCpzEVwQugbf3k4RcqxjgmZ4c21ECPKnL3RLIx38g7rnkaDLyWmJlyx7XLGg68ETu86M3ypQrbxTMgFMeUh1Gv86M3ypQrNEiy6e2qjLrqLTc2niwSZ71sDuUg7assqbiH7jZ71sXRBEJ9Og1o9zs4EudwXRBEJ9OgD6HGPtydLugbv2ky3GyXofqS0q4WQevyEb4hjZ71sDqIhde9ovbiH7ptn0JAUXXa5rMhXYJbYJmCRwe4rWBqmqE0PQBEJ9OMh51Jae2la9igwaOhDMvW(JKb(rgUhfnHXpIHzLl9i(HaGq4hXL5rz6rzAOvWdXAWJYB)rB8wSwgFunwgFunp60xnF1ZKW9OgSIx38g7rn60dbtNWgk4Jy5XarNwTiGbXIDEVwkEDZBSh1O2PjHQW9Og1kaKoBfSR4hcacHtkCpyrAAOBqyMXMLacjBjfVU5n2JA04Jy5XarNwTiqsH7rnQ0JIMWy9YkxcRwBRvdi(HaGqApUeZwBRvdi4n3JAmigNaGDQRJfBH7rnQvaiD2kyxXpeaecZw4EuJAfasNTc2vxXyn)qaqi8ZKW9OgSIx38g7rn60dbtNWgkPhfnHX6LvUe2GyXoVxlfVU5n2JAu70Kn1KW9Og1kaKoBfSR4hcacHzqIjDXsJRszeuCRGVjfUhSinn0nim7eBeAOHQlwACvkJGIBf8fAOfUhSinn0nimZsSXK59APoiXJbIENQaKW9tokxJDajjOXPK1I1XOx2aYHZGg8mjCpQbR41nVXEuJo9qW0jSHYkauwSwdIf78ETu86M3ypQrbxTMK8QSWvRrXRBEJ9OgfGUsmygWfSR94sjHkVg4D4QLvUKw4Ca5rnjBcMY71sDdaOayDT0EbU04k4Q1an0qLxd8oCvmlcmIvZfmxGPgFMeUh1Gv86M3ypQrNEiy6e2qbZla)WGyXoVxlfVU5n2JAua6kXGzgxWU2JlLmVxlfVU5n2JAu7uOHoVxlfVU5n2JAuWvRjjVklC1Au86M3ypQrbORedMbCb7ApU0ZKW9OgSIx38g7rn60dbtNWgk2Gvmq056MniwSZ71sXRBEJ9OgfGUsmygaHdRUIXjfUhSinn0nimZs8zs4EudwXRBEJ9OgD6HGPtydfyGaPgSodiXpmiwSZ71sXRBEJ9OgfGUsmygaHdRUIXjZ71sXRBEJ9Og1o9zs4EudwXRBEJ9OgD6HGPtydfmVa8ddIfBxaqixDqI1puPCNbSpNHs6ILgxHjbedeTxB(XZ0ZKW9OgScuP60dbtSxw5syhejqgel2c3dwKMg6geMzSzjGqYwsDuUg7assqVSYLWoisGs2uEVwQJY1yhqsckajChAOZ71sTcaH9cCvas4EJptc3JAWkqLQtpemDcBOKYiOYwb7gel259APW7rNqmqW6SLW4yGObKaZOANMmVxlfEp6eIbcwNTeghdenGeygva6kXGzgxWU2Jl9mjCpQbRavQo9qW0jSHskJGkBfSBqSyN3RLAfac7f4QaKW9NjH7rnyfOs1PhcMoHnuszeuzRGDdIf78ETuhLRXoGKeuas4(Zud9OMBm9OAOhXWca9OZSc2FejalJpkMhD6ugUpkwpIXA)i4AmYF0HWIEef(bbEuZfjEmqEuZD6JkWJAUk)rMoGKeEeJK)izGFef(bbyUh1K04Joew0JUfGEKFiZJ8w1JelGeygn4rnLB8rhcl6rNElzm2bc2WlgHFedBdy8rasGz8rE9OnMm4rf4rnXB8rMKaIbYJAV28Jhf4hjCpyrQhD(QgJ8hbxpYpc8JADew6rhca(rCb7Xa5rmmRCjhejq4hvGh16GMhzUNhX8jgigHF0zwcJJbYJc8JaKaZO6zs4EudwbQuD6HGPtydLvaiD2ky3GnM01APHWHzNObBmPBDewsZfShde2jAqSydvwciKSLuRaq6SvWUoTkBmqsM3RLcVhDcXabRZwcJJbIgqcmJk4Q1Ku4EWI00q3GWmGLacjBj1HaG1Cb76LvUe2brcusOUcaHDb4eqjCpyrjBcQ59APoiXJbIENQaKW9KqnVxl1r5ASdijbfGeUNeQPaILUwlneoSAfasNTc2t2KW9Og1kaKoBfSR4hcacHzg7gan0n5ILgxjwYySdeSHxW61gWysEvw4Q1OGbcKAW6mGe)qbibMXgHg6MCXsJRWKaIbI2Rn)iPlaiKRoiX6hQuUZa2NZqn2yJptn0JAUX0JyybGE0zwb7pIc)GapcEdIbYJKhXWcaLfRfkgUmcQSvW(J4c2FuRdAEuZfjEmqEuZD6Jc8JeUhSOhvGhbVbXa5rKXeF70JAf(XJmjbedKh1ET5hQNjH7rnyfOs1PhcMoHnuwbG0zRGDd2ysxRLgchMDIgSXKU1ryjnxWEmqyNObXInuzjGqYwsTcaPZwb760QSXajjuxbGWUaCcOeUhSOKn1utc3JAuRaqzXAvKXeF7Xajztc3JAuRaqzXAvKXeF7KgqxjgmdmKYWGgAOc2dTkaesTcaH9cCBeAOfUh1OszeuzRGDfzmX3Emqs2KW9OgvkJGkBfSRiJj(2jnGUsmygyiLHbn0qfShAvaiKAfac7f42yJjZ71sDqIhde9ovbiH7ncn0n5ILgxHjbedeTxB(rsxaqixDqI1puPCNbSpNHs2uEVwQds8yGO3PkajCpjufUh1OW8cWpuKXeF7XabAOHAEVwQJY1yhqsckajCpjuZ71sDqIhde9ovbiH7jfUh1OW8cWpuKXeF7XajjupkxJDajjOXPK1I1XOx2aYH3yJn(mjCpQbRavQo9qW0jSHcxSwTW9OgTnWUbJCj2c3dwK2flno(zs4EudwbQuD6HGPtydLugbv2ky3GyXoVxlvkJGIBf8vbiH7j5c21ECjgK3RLkLrqXTc(Qa0vIbNKlyx7XLyqEVwkWEiDT0PvlcOa0vIb)mjCpQbRavQo9qW0jSHskJGkBfSBqSyNciwAiCyvIkmVa8JK59APoiXJbIENQaKW9KUyPXvysaXar71MFK0faeYvhKy9dvk3za7ZzOKc3dwKMg6geMbSeqizlPokxJDajjOxw5syhejqptc3JAWkqLQtpemDcBOKEu0egRxw5sydIfBOYsaHKTKk9OOjmwNwLngijZ71sDqIhde9ovbiH7jHAEVwQJY1yhqsckajCpztc3dwKgUCvazcNyqdGgAH7blstdDdcZm2SeqizlPoeaSMlyxVSYLWoisGGgAH7blstdDdcZm2SeqizlPokxJDajjOxw5syhejqn(mjCpQbRavQo9qW0jSHcMxa(HbXITlaiKRoiX6hQuUZa2NZqjDXsJRWKaIbI2Rn)4zs4EudwbQuD6HGPtydfyGaPgSodiXpmiwSfUhSinn0nimZAWZKW9OgScuP60dbtNWgkcGldPjJtTfoQXGyXw4EWI00q3GWmJnlbes2skbWLH0KXP2ch1K8kJOs5oZyZsaHKTKsaCzinzCQTWrn6RmYZKW9OgScuP60dbtNWgklRCjSdIeidIfBH7blstdDdcZm2SeqizlPoeaSMlyxVSYLWoisGEMeUh1GvGkvNEiy6e2qzfaklw7Z0ZKW9OgSc7YalaynOCXJAyVSYLWoisGmiwSfUhSinn0nimZyZsaHKTK6OCn2bKKGEzLlHDqKaLSP8ETuhLRXoGKeuas4o0qN3RLAfac7f4QaKW9gFMeUh1GvyxgybaRbLlEuZjSHskJGkBfSBqSyN3RLAfac7f4QaKW9NjH7rnyf2LbwaWAq5Ih1CcBOKYiOYwb7gel259APokxJDajjOaKW9K59APokxJDajjOa0vIbZaH7rnQvaOSyTkYyIVDs7XLEMeUh1GvyxgybaRbLlEuZjSHskJGkBfSBqSyN3RL6OCn2bKKGcqc3t2ukGyPHWHvjQwbGYI1cn0Raqyxaobuc3dwe0qlCpQrLYiOYwb7Qy0lBa5WB8zQHEu7agFKxpcc5pYK5ZzpkfuC8JIbhW0JoDkd3hLEiyc)Oc8Otv38g7rnpk9qWe(rToO5rPfghzlPEMeUh1GvyxgybaRbLlEuZjSHskJGkBfSBqSyN3RLcVhDcXabRZwcJJbIgqcmJQDAYM4vzHRwJcShsxlDA1IakaDLyWNiCpQrb2dPRLoTArafzmX3oP94sNWfSR94smlVxlfEp6eIbcwNTeghdenGeygva6kXGHgAO6ILgxb2dPRLoTArGgtYsaHKTKYJlP9sZRBEJ9OMt4c21ECjML3RLcVhDcXabRZwcJJbIgqcmJkaDLyWptc3JAWkSldSaG1GYfpQ5e2qjLrqLTc2niwSZ71sDuUg7assqbiH7jDbaHC1bjw)qLYDgW(CgkPlwACfMeqmq0ET5hptc3JAWkSldSaG1GYfpQ5e2qjLrqLTc2niwSZ71sLYiO4wbFvas4EsUGDThxIb59APszeuCRGVkaDLyWptn0JoFTbXa5r(b9iSldSaGFeOCXJAm4r1yz8rBm9igwaOhDMvWo(rToO5r(bX4Jea9OP8hLPyG8O0QSe8Jwf4rNoLH7JkWJovDZBSh1OEuZnMEedla0JoZky)ru4he4rWBqmqEK8igwaOSyTqXWLrqLTc2FexW(JADqZJAUiXJbYJAUtFuGFKW9Gf9Oc8i4nigipImM4BNEuRWpEKjjGyG8O2Rn)q9mjCpQbRWUmWcawdkx8OMtydLvaiD2ky3GnM01APHWHzNObBmPBDewsZfShde2jAqSyd1vaiSlaNakH7blkjuzjGqYwsTcaPZwb760QSXajztn1KW9Og1kauwSwfzmX3Emqs2KW9Og1kauwSwfzmX3oPb0vIbZadPmmOHgQG9qRcaHuRaqyVa3gHgAH7rnQugbv2kyxrgt8ThdKKnjCpQrLYiOYwb7kYyIVDsdORedMbgszyqdnub7HwfacPwbGWEbUn2yY8ETuhK4XarVtvas4EJqdDtUyPXvysaXar71MFK0faeYvhKy9dvk3za7ZzOKnL3RL6Gepgi6DQcqc3tcvH7rnkmVa8dfzmX3EmqGgAOM3RL6OCn2bKKGcqc3tc18ETuhK4XarVtvas4EsH7rnkmVa8dfzmX3Emqsc1JY1yhqscACkzTyDm6LnGC4n2yJptc3JAWkSldSaG1GYfpQ5e2qjLrqLTc2niwStbelneoSkrfMxa(rY8ETuhK4XarVtvas4EsxS04kmjGyGO9AZps6cac5QdsS(HkL7mG95musH7blstdDdcZawciKSLuhLRXoGKe0lRCjSdIeONjH7rnyf2LbwaWAq5Ih1CcBOKEu0egRxw5sydIfBOYsaHKTKk9OOjmwNwLngijBcQUyPXvlqD1(bPf8bHHgAH7blstdDdcZSeBmztc3dwKgUCvazcNyqdGgAH7blstdDdcZm2SeqizlPoeaSMlyxVSYLWoisGGgAH7blstdDdcZm2SeqizlPokxJDajjOxw5syhejqn(mjCpQbRWUmWcawdkx8OMtydfUyTAH7rnABGDdg5sSfUhSiTlwAC8ZKW9OgSc7YalaynOCXJAoHnuGbcKAW6mGe)WGyXw4EWI00q3GWmlXNjH7rnyf2LbwaWAq5Ih1CcBOG5fGFyqSy7cac5QdsS(HkL7mG95musxS04kmjGyGO9AZpEMAOhz4e(XJOP2qoEKlaiKJn4rH)Oa)i5rqKyEKxpIly)rmmRCjSdIeOhj4hTcRLapkgStc8JQ1JyybGYI1QEMeUh1GvyxgybaRbLlEuZjSHIa4YqAY4uBHJAmiwSfUhSinn0nimZyZsaHKTKsaCzinzCQTWrnjVYiQuUZm2SeqizlPeaxgstgNAlCuJ(kJ8mjCpQbRWUmWcawdkx8OMtydLLvUe2brcKbXITW9GfPPHUbHzgBwciKSLuhcawZfSRxw5syhejqptc3JAWkSldSaG1GYfpQ5e2qzfaklwB3eNs8EBm8Z19U37a]] )

end
