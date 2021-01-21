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

            usable = function () return time > 0, "must already be in combat" end,
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

        potion = "spectral_intellect",

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


    spec:RegisterPack( "Fire", 20210121, [[de1JrdqiuqpIOQCjfQI2Ki5tOugLiLtjs1QuOIxPkLzreULcv1Ui8lqvnmIkDmuQwgrPEgrjMgrvLRHsKTHsu9nuGyCQsuoNQeP1HcyEQs19is7dLW)qbsPdIcuwiOkpKOktefOQlsusTruIYhvLOYijkjDsfQsReL0lrbQmtvjCtvjQANku(PQeXqjQQYsjQQQNkIPQkPRIcKSvuGu8vIsIXsuXEvQ)sPbd5WKwSIEmQMmixgzZI6ZGYOvfNwy1OaP61erZMIBRQ2Tu)wYWvWXvOslh45qnDQUUs2ok67kKXtuCEuO1Rqvy(Gk7xL3SVFDNaPoTht2Yv2Slx2Ln7c5(sLfzr(9Y2joJd0ozq5sQWODsRFANWYcaTtgugnLcTFDNGRfGt7Kh3hWma8HpSWFwtbV(Whh)Lr9OAoqZo8XXNd)DYCfgF8275obsDApMSLRSzxUSlB2fY9LklYISil7eD5pfyNKeF5TtEciiQ3ZDceH57e57qSSaqh6LxHrhRY3HECFaZaWh(Wc)znf86dFC8xg1JQ5an7WhhFo8pwLVdXQ2lfW4HKn7sCizlxzZ(X6XQ8Di59OnmcZahRY3Hg)dXGcthkhWEClG(A04dbu)HahYF0(qUcGrUWJpz9Ycf0HYf4qgf7JpM4vdDiDgMWz8qlScJWIJv57qJ)HErvyQpexX(Ha04Uca9P2XhkxGdjV6pxypQ(qPfcsiXHGQMn)qpLb6qHFOCboKEOmGWph6LNCQahIRypDXXQ8DOX)qY6wNg6qyheC)q8hIlz0Wou1hspuMgDOCbKeFOOpK)qhIbt(7fhYRdbiOfNo0OciPPuiXoXeyhVFDNmaiE9NQVFDpg77x3jk3JQ3jkGRnzJ2jJH4(oHADAiOn82(EmzVFDNqTone0gE7KAyNGjFNOCpQENWubHon0oHPAw0or2hACoKRgQDr2OFYoOo)rqTone0HE7qYYHgNdXWd5QHAxKn6NSdQZFeuRtdbTt4GWjqO7eMki0PHepLBXoGujTzJ(jSdcjPdj9qYDNWub2w)0o5PCl2bKkPnB0pHDqijT99yYY(1Dc160qqB4TtQHDcM8DIY9O6Dctfe60q7eMQzr7ezFOX5qUAO2fzJ(j7G68hb160qqh6TdjlhACoedpKRgQDr2OFYoOo)rqTone0oHdcNaHUtyQGqNgs8OailxXUnB0pHDqijDiPhsU7eMkW26N2jpkaYYvSBZg9tyhessBFpM8B)6oHADAiOn82j1Wobt(or5Eu9oHPccDAODct1SODISCOX5qUAO2fzJ(j7G68hb160qqh6TdXYp04CigEixnu7ISr)KDqD(JGADAiODcheobcDNWubHonKGx)5c7r12Sr)e2bHK0HKEi5UtyQaBRFANWR)CH9OAB2OFc7GqsA77XyP9R7eQ1PHG2WBNud7em57eL7r17eMki0PH2jmvZI2jV0x6HgNd5QHAxKn6NSdQZFeuRtdbDO3oKSp04CigEixnu7ISr)KDqD(JGADAiODcheobcDNWubHonKqbCTjljZGPWr1hs6HK7oHPcST(PDIc4AtwsMbtHJQ3(Emw((1Dc160qqB4TtQHDcGWKVtuUhvVtyQGqNgANWub2w)0orbCTjljZGPWr12V26obIY6Y47e5NC3(EmgK9R7eQ1PHG2WBNud7eaHjFNOCpQENWubHon0oHPcST(PDcezugTzJ(jSdcjPDceL1LX3jYD77XEz7x3juRtdbTH3oPg2jact(or5Eu9oHPccDAODctfyB9t7ejJgYenmlGGwCpQENarzDz8DICfYVTVh7LUFDNqTone0gE7KAyNGjFNOCpQENWubHon0oHPAw0oHL2jmvGT1pTtWsoTqlG6r1BFpg7YD)6oHADAiOn82j1Wobt(or5Eu9oHPccDAODct1SODcnURyyGGeFLRtazXpe52)ch8dbhChIg3vmmqqIV2rMWEzRS9RqnHXhco4oenURyyGGeWmkuOEbW2PcbJoeCWDiACxXWabjGzuOq9cGTFcsnMO6dbhChIg3vmmqqIawhEuT9RWiSnVW0HGdUdrJ7kggiiHpEOnHTtfijEiAcFi4G7q04UIHbcsOJhla5pf2IJggbzhmRVcJoeCWDiACxXWabj0Mhu7wj7YTv2okWq1)qWb3HOXDfddeKa)uCjNHtaSnRnSdbhChIg3vmmqqIMwa1yXm26aMSu)OnNahco4oenURyyGGet1q5aq2jqB(ZoHPcST(PDcV(Zf2JQTvBxyA77XyN99R7eQ1PHG2WBNud7eaHjFNOCpQENWubHon0oHPcST(PDc9hyeqQXwaOwBozHiJY4obIY6Y47e2FzBFpg7YE)6oHADAiOn82j1Wobt(or5Eu9oHPccDAODct1SODISL7oHdcNaHUtyQGqNgsWR)CH9OAB12fM2jmvGT1pTtQ2UWKLV8kN3(Em2LL9R7eQ1PHG2WBNud7em57eL7r17eMki0PH2jmvZI2jYML2jCq4ei0DcnURyyGGeFLRtazXpe52)ch8DctfyB9t7KQTlmz5lVY5TVhJD53(1Dc160qqB4TtQHDcM8DIY9O6Dctfe60q7eMQzr7ezl3d92HyQGqNgsq)bgbKASfaQ1MtwiYOmUt4GWjqO7eACxXWabjO)aJasn2ca1AZPDctfyB9t7KQTlmz5lVY5TVhJDwA)6oHADAiOn82j1WobqyY3jk3JQ3jmvqOtdTtyQaBRFANWR)CH9OAl(jYE0WSd1icStGOSUm(or2BFpg7S89R7eQ1PHG2WBN06N2j4AzSbSoCcStuUhvVtW1YydyD4ey77XyNbz)6or5Eu9o5haqbSXxHr7eQ1PHG2WB77Xy)LTFDNqTone0gE7eoiCce6oHHhAaqmfdmcQPrX(or5Eu9ozGrqnnk23(23jquwxgF)6Em23VUtOwNgcAdVDcheobcDNWWdbwnLlamsafyEmyIwbmA51)RnKGADAiODIY9O6DcVwTta8azmBFpMS3VUtOwNgcAdVDsnStWKVtuUhvVtyQGqNgANWunlAN4QHAxKdaHDf4eqqTone0HgNdLdaHDf4eqaOVgn(qVDO0oeVkdunQf86pxypQwaOVgn(qJZHs7qSFOX)qmvqOtdjKmAit0WSacAX9O6dnohYvd1UqYOHmrdtqTone0Hs)qPFOX5qm8q8Qmq1OwWR)CH9OAbGuigp04CO5kNf86pxypQwavJ6DctfyB9t7ep(K1llV(Zf2JQ3(Emzz)6oHADAiOn82j1Wo5RYStuUhvVtyQGqNgANWunlANWubHonKG(dmci1ylauRnNSqKrz8qJ)Hs7q8Qmq1Owq)bgbKASfaQ1MtcOfq9O6dn(hIxLbQg1c6pWiGuJTaqT2CsaOVgn(qPFOX5qm8q8Qmq1Owq)bgbKASfaQ1MtcaPqmUt4GWjqO7eACxXWabjO)aJasn2ca1AZPDctfyB9t7ep(K1llV(Zf2JQ3(Em53(1Dc160qqB4TtQHDYxLzNOCpQENWubHon0oHPAw0oHxLbQg1cygfkuVay7uHGrca91OX7eoiCce6oHg3vmmqqcygfkuVay7uHGr7eMkW26N2jE8jRxwE9NlShvV99yS0(1Dc160qqB4TtQHDYxLzNOCpQENWubHon0oHPAw0ozUYzby1KTY2HAebea6RrJ3jCq4ei0DIRgQDby1KTY2HAebeuRtdbDOuhAUYzbV(Zf2JQfq1OENWub2w)0oXJpz9YYR)CH9O6TVhJLVFDNqTone0gE7KAyN8vz2jk3JQ3jmvqOtdTtyQMfTt4vzGQrTaSAYwz7qnIaca91OXh6Tdnx5SaSAYwz7qnIacOfq9O6DcheobcDN4QHAxawnzRSDOgrab160qqhk1HMRCwWR)CH9OAbunQpuQdXRYavJAby1KTY2HAebea6RrJp0BhILo07hIPccDAiHhFY6LLx)5c7r17eMkW26N2jE8jRxwE9NlShvV99ymi7x3juRtdbTH3oHdcNaHUtMRCwWR)CH9OAbunQpuQdXubHonKWJpz9YYR)CH9O6dXIdLxgJfqqlUhvFOuhkTdXRYavJAby1KTY2HAebea6RrJpelouEzmwabT4Eu9HGdUdXWd5QHAxawnzRSDOgrab160qqhk9dL6qm8qPDO5kNfrNjqRglxXCfIeRHdL6qZvolEk3IDaPskaKY9dL(HsDO0oKY9GjzPM(bHp07hIPccDAibV(Zf2JQT4Ni7rdZouJiWHGdUdPCpyswQPFq4d9(HyQGqNgsWR)CH9OAB2OFc7Gqs6qWb3HyQGqNgs4XNSEz51FUWEu9Hg)dLxgJfqqlUhvFiwCiL7r1wEvgOAuFO03jk3JQ3j4Ni7rdZouJiW23J9Y2VUtOwNgcAdVDcheobcDNK2HMRCwWR)CH9OAbunQpuQdnx5SaSAYwz7qnIacOAuFOuhkTdXubHonKWJpz9YYR)CH9O6d9(Hizi(YjRhF6qWb3HyQGqNgs4XNSEz51FUWEu9HyXH4vzGQrTaOqH2UfpOajfqlG6r1hk9dL(HGdUdL2HMRCwawnzRSDOgraXA4qPoetfe60qcp(K1llV(Zf2JQpeloKSi3dL(or5Eu9obOqH2UfpOaj3(ESx6(1Dc160qqB4Tt4GWjqO7K5kNf86pxypQwavJ6dL6qZvolaRMSv2ouJiGaQg1hk1HyQGqNgs4XNSEz51FUWEu9HE)qKmeF5K1JpTtuUhvVtGi1FMfOPTVhJD5UFDNqTone0gE7eoiCce6oHPccDAiHhFY6LLx)5c7r1h6DPhswouQdnx5SGx)5c7r1cOAuVtuUhvVt(bauaSTYwVaFQ9TVhJD23VUtOwNgcAdVDYct2rpHHSCf7rdBpg77eL7r17KCai70OyFNWbHtGq3jk3JQf)aaka2wzRxGp1UGKH4lpAyhk1HYlJXci(JcGrwp(0Hg)dPCpQw8daOayBLTEb(u7csgIVCYcOVgn(qVFi53HsDigEONYTyhqQKw8azmyB02SjG94hk1Hy4HMRCw8uUf7asLuaiL7BFpg7YE)6oHADAiOn82jCq4ei0DYCLZcE9NlShvlGQr9HsDiiAUYzbqHcTDlEqbsAzUmnb0zycNrbunQpuQdnx5SaSAYwz7qnIacOAuVtuUhvVt(bauaB8vy023JXUSSFDNqTone0gE7eL7r17eygfkuVay7uHGr7eoiCce6oHPccDAiHhFY6LLx)5c7r1hIfhs5EuTLxLbQg1hA8pelTtOCM4UT1pTtGzuOq9cGTtfcgT99ySl)2VUtOwNgcAdVDIY9O6Dc9hyeqQXwaOwBoTt4GWjqO7eMki0PHeE8jRxwE9NlShvFO3LEiMki0PHe0FGraPgBbGAT5KfImkJ7Kw)0oH(dmci1ylauRnN2(Em2zP9R7eQ1PHG2WBNOCpQENaZW4WJTYwfJJFyupQENWbHtGq3jmvqOtdj84twVS86pxypQ(qSq6HyQGqNgsuTDHjlF5voVtA9t7eygghESv2QyC8dJ6r1BFpg7S89R7eQ1PHG2WBNOCpQEN8vUobKf)qKB)lCW3jCq4ei0Dctfe60qcp(K1llV(Zf2JQp07spelTtA9t7KVY1jGS4hIC7FHd(23JXodY(1Dc160qqB4TtuUhvVtGaKcLdazzsymz2jCq4ei0Dctfe60qcp(K1llV(Zf2JQpelKEiMki0PHevBxyYYxELZhk1Hs7qZvolIotGwnwUI5kejWUYL8qsp0CLZIOZeOvJLRyUcrIVkJf7kxYdbhChIHhIxn0kCr0zc0QXYvmxHib160qqhco4oetfe60qcE9NlShvBR2UW0HGdUdXubHonKWJpz9YYR)CH9O6d92HyPdXIdLdypUfqFnA8HgppKY9OAlVkdunQpu67Kw)0obcqkuoaKLjHXKz77Xy)LTFDNqTone0gE7eL7r17eCTm2awhob2jCq4ei0Dctfe60qcp(K1llV(Zf2JQpelKEiMki0PHevBxyYYxELZh6TdXolDOX5qPDiMki0PHevBxyYYxELZhIfhsUhk9dbhChIPccDAiHhFY6LLx)5c7r1h69dXUC3jT(PDcUwgBaRdNaBFpg7V09R7eQ1PHG2WBNWbHtGq3jmvqOtdj84twVS86pxypQ(qSq6HyQGqNgsuTDHjlF5voFOuhIPccDAiHhFY6LLx)5c7r1hIfspe7S0HgNdrJ7kggiibeGuOCailtcJjZHsDip(0HE)qS0HsDigEiE1qRWfrNjqRglxXCfIeuRtdbDi4G7qZvolIotGwnwUI5kejWUYL8qsp0CLZIOZeOvJLRyUcrIVkJf7kxYDIY9O6DcxBozSZvoVtMRC226N2j4AzSbSo8O6TVht2YD)6oHADAiOn82jCq4ei0Dcy1uUaWibuG5XGjAfWOLx)V2qcQ1PHGouQdXRYavJAXCLZwOaZJbt0kGrlV(FTHeasHy8qPo0CLZcOaZJbt0kGrlV(FTHSkGRnjGQr9HsDigEO5kNfqbMhdMOvaJwE9)Adjwdhk1HyQGqNgs4XNSEz51FUWEu9HyXHKnlTtuUhvVt41QDcGhiJz77XKn77x3juRtdbTH3oHdcNaHUtaRMYfagjGcmpgmrRagT86)1gsqTone0HsDiEvgOAulMRC2cfyEmyIwbmA51)RnKaqkeJhk1HMRCwafyEmyIwbmA51)RnKvbCTjbunQpuQdXWdnx5SakW8yWeTcy0YR)xBiXA4qPoetfe60qcp(K1llV(Zf2JQpeloKSzPDIY9O6DIc4AtwsMbtHJQ3(Emzl79R7eQ1PHG2WBNWbHtGq3jGvt5caJeqbMhdMOvaJwE9)AdjOwNgc6qPoeVkdunQfZvoBHcmpgmrRagT86)1gsaifIXdL6qZvolGcmpgmrRagT86)1gYMbf2fq1O(qPoedp0CLZcOaZJbt0kGrlV(FTHeRHdL6qmvqOtdj84twVS86pxypQ(qS4qYML2jk3JQ3jzqH9zz8TVht2YY(1Dc160qqB4Tt4GWjqO7eMki0PHeE8jRxwE9NlShvFO3LEi5UtuUhvVt4QXyvUhvBnb23jMa72w)0oHx)5c7r12HhftBFpMSLF7x3juRtdbTH3oPg2jyY3jk3JQ3jmvqOtdTtwyYw5SfghApg77eMQzr7eMki0PHeE8jRxwE9NlShvFOX)qYYHE)qk3JQf5aq2PrXUiVmglG4pkagz94thA8pKY9OAb(jYE0WSd1iciYlJXciOf3JQp04CO0oeVkdunQf4Ni7rdZouJiGaqFnA8HE)qmvqOtdj84twVS86pxypQ(qPFOuhIPccDAiHhFY6LLx)5c7r1h69dLdypUfqFnA8HGdUd5QHAxawnzRSDOgrab160qqhk1HMRCwawnzRSDOgrabunQpuQdXRYavJAby1KTY2HAebea6RrJp07hs5EuTihaYonk2f5LXybe)rbWiRhF6qJ)HuUhvlWpr2JgMDOgrarEzmwabT4Eu9HgNdL2H4vzGQrTa)ezpAy2HAebea6RrJp07hIxLbQg1cWQjBLTd1icia0xJgFO0puQdXRYavJAby1KTY2HAebea6RrJp07hkhWEClG(A04DctfyB9t7KCai70Oy3ouLjAy7KfMSJEcdz5k2Jg2Em23(EmzZs7x3juRtdbTH3oPg2jyY3jk3JQ3jmvqOtdTtyQMfTtyQGqNgs4XNSEz51FUWEu9HE)qk3JQfdpf1Hm2Sr)ewKxgJfq8hfaJSE8Pdn(hs5EuTa)ezpAy2HAebe5LXybe0I7r1hACouAhIxLbQg1c8tK9OHzhQreqaOVgn(qVFiMki0PHeE8jRxwE9NlShvFO0puQdXubHonKWJpz9YYR)CH9O6d9(HYbSh3cOVgn(qWb3HaRMYfagjWR2kz0WW2PHW4OHjOwNgc6qWb3H84th69dXs7eMkW26N2jdpf1Hm2HQmrdB77XKnlF)6oHADAiOn82jCq4ei0DYCLZcWQjBLTd1iciGQr9HsDigEO5kNf5aqyVaFbGuUFOuhkTdXubHonKWJpz9YYR)CH9O6dXcPhAUYzby1KTY2HAebeqlG6r1hk1HyQGqNgs4XNSEz51FUWEu9HyXHuUhvlYbGStJIDrEzmwaXFuamY6XNoeCWDiMki0PHeE8jRxwE9NlShvFiwCOCa7XTa6RrJpu67eL7r17eWQjBLTd1icS99yYMbz)6oHADAiOn82jCq4ei0DYCLZcWQjBLTd1iciwdhk1HyQGqNgs4XNSEz51FUWEu9HyXHK7or5Eu9oHRgJv5EuT1eyFNycSBB9t7eqnyhEumT99yY(LTFDNqTone0gE7KfMSJEcdz5k2Jg2Em23jCq4ei0Dcdpetfe60qICai70Oy3ouLjAyhk1HyQGqNgs4XNSEz51FUWEu9HyXHK7HsDiL7btYsn9dcFiwi9qmvqOtdjEuaKLRy3Mn6NWoiKKouQdXWdLdaHDf4eqOCpyshk1Hy4HMRCw8uUf7asLuaiL7hk1Hs7qZvolEi1JgMDniaKY9dL6qk3JQfzJ(jSdcjjbjdXxozb0xJgFO3pKCfS0HGdUdXFuamcBZaL7r1Q5qSq6HK9HsFNSWKTYzlmo0Em23jk3JQ3j5aq2PrX(23Jj7x6(1Dc160qqB4TtwyYo6jmKLRypAy7XyFNWbHtGq3j5aqyxbobek3dM0HsDi(JcGr4dXcPhI9dL6qm8qmvqOtdjYbGStJID7qvMOHDOuhkTdXWdPCpQwKdanvJrqYq8LhnSdL6qm8qk3JQfdmcQPrXUiAB2eWE8dL6qZvolEi1JgMDniaKY9dbhChs5EuTihaAQgJGKH4lpAyhk1Hy4HMRCw8uUf7asLuaiL7hco4oKY9OAXaJGAAuSlI2MnbSh)qPo0CLZIhs9OHzxdcaPC)qPoedp0CLZINYTyhqQKcaPC)qPVtwyYw5SfghApg77eL7r17KCai70OyF77XKf5UFDNqTone0gE7KfMSJEcdz5k2Jg2Em23jk3JQ3j5aq2PrX(oHdcNaHUtuUhvlWpr2JgMDOgrabjdXxE0WouQdLxgJfq8hfaJSE8Pd9(HuUhvlWpr2JgMDOgraHhCjTacAX9O6dL6qZvolEk3IDaPskGQr9HsDip(0HyXHyxUBFpMSW((1Dc160qqB4Tt4GWjqO7eMki0PHeE8jRxwE9NlShvFiwCi5EOuhAUYzby1KTY2HAebeq1OENOCpQENWvJXQCpQ2AcSVtmb2TT(PDc21gsbqwq5QhvV99yYIS3VUtuUhvVtW8cWF2juRtdbTH323(obud2Hhft7x3JX((1Dc160qqB4Tt4GWjqO7eL7btYsn9dcFiwi9qmvqOtdjEk3IDaPsAZg9tyhesshk1Hs7qZvolEk3IDaPskaKY9dbhChAUYzroae2lWxaiL7hk9DIY9O6Ds2OFc7GqsA77XK9(1Dc160qqB4Tt4GWjqO7K5kNf4vBLmAyy70qyC0WSasHyuSgouQdnx5SaVARKrddBNgcJJgMfqkeJca91OXhIfhIRy36XN2jk3JQ3jdmcQPrX(23Jjl7x3juRtdbTH3oHdcNaHUtMRCwKdaH9c8fas5(or5Eu9ozGrqnnk23(Em53(1Dc160qqB4Tt4GWjqO7K5kNfpLBXoGujfas5(or5Eu9ozGrqnnk23(EmwA)6oHADAiOn82jlmzh9egYYvShnS9ySVt4GWjqO7egEiMki0PHe5aq2PrXUDOkt0WouQdnx5SaVARKrddBNgcJJgMfqkeJcOAuFOuhs5EWKSut)GWh69dXubHonK4rbqwUIDB2OFc7Gqs6qPoedpuoae2vGtaHY9GjDOuhkTdXWdnx5S4HupAy21Gaqk3puQdXWdnx5S4PCl2bKkPaqk3puQdXWdnaiM2kNTW4qICai70Oy)qPouAhs5EuTihaYonk2f8hfaJWhIfspKSpeCWDO0oKRgQDHAizWoqXJhk2MxagfuRtdbDOuhIxLbQg1ciGcRASDci1FeasHy8qPFi4G7qPDixnu7cmPGOHz9AXFeuRtdbDOuhYvamYfpKA8hXa3p07spKSi3dL(Hs)qPVtwyYw5SfghApg77eL7r17KCai70OyF77Xy57x3juRtdbTH3ozHj7ONWqwUI9OHThJ9DcheobcDNWWdXubHonKihaYonk2TdvzIg2HsDigEOCaiSRaNacL7bt6qPouAhkTdL2HuUhvlYbGMQXiizi(YJg2HsDO0oKY9OAroa0ungbjdXxozb0xJgFO3pKCfS0HGdUdXWdbwnLlamsKdaH9c8fuRtdbDO0peCWDiL7r1Ibgb10OyxqYq8LhnSdL6qPDiL7r1Ibgb10OyxqYq8Ltwa91OXh69djxblDi4G7qm8qGvt5caJe5aqyVaFb160qqhk9dL(HsDO5kNfpK6rdZUgeas5(Hs)qWb3Hs7qUAO2fysbrdZ61I)iOwNgc6qPoKRayKlEi14pIbUFO3LEizrUhk1Hs7qZvolEi1JgMDniaKY9dL6qm8qk3JQfyEb4pcsgIV8OHDi4G7qm8qZvolEk3IDaPskaKY9dL6qm8qZvolEi1JgMDniaKY9dL6qk3JQfyEb4pcsgIV8OHDOuhIHh6PCl2bKkPfpqgd2gTnBcyp(Hs)qPFO03jlmzRC2cJdThJ9DIY9O6DsoaKDAuSV99ymi7x3juRtdbTH3or5Eu9oHRgJv5EuT1eyFNycSBB9t7eL7btY6QHAhV99yVS9R7eQ1PHG2WBNWbHtGq3jZvolgyeuCJI)caPC)qPoexXU1JpDO3p0CLZIbgbf3O4VaqFnA8HsDiUIDRhF6qVFO5kNfGvt2kBhQreqaOVgnENOCpQENmWiOMgf7BFp2lD)6oHADAiOn82jCq4ei0DYaGyAHXHeSlW8cWFouQdnx5S4HupAy21Gaqk3puQd5QHAxGjfenmRxl(JGADAiOdL6qUcGrU4HuJ)ig4(HEx6HKf5EOuhs5EWKSut)GWh69dXubHonK4PCl2bKkPnB0pHDqijTtuUhvVtgyeutJI9TVhJD5UFDNqTone0gE7eoiCce6oHHhIPccDAiXWtrDiJDOkt0WouQdnx5S4HupAy21Gaqk3puQdXWdnx5S4PCl2bKkPaqk3puQdL2HuUhmjlu5IawhoDO3pKSpeCWDiL7btYsn9dcFiwi9qmvqOtdjEuaKLRy3Mn6NWoiKKoeCWDiL7btYsn9dcFiwi9qmvqOtdjEk3IDaPsAZg9tyhesshk9DIY9O6DYWtrDiJnB0pH3(Em2zF)6oHADAiOn82jCq4ei0DIRayKlEi14pIbUFO3LEizrUhk1HC1qTlWKcIgM1Rf)rqTone0or5Eu9obZla)z77Xyx27x3juRtdbTH3oHdcNaHUtuUhmjl10pi8HyXHK9or5Eu9obcOWQgBNas9NTVhJDzz)6oHADAiOn82jCq4ei0DIY9GjzPM(bHpelKEiMki0PHekGRnzjzgmfoQ(qPo0xBvmW9dXcPhIPccDAiHc4AtwsMbtHJQTFT1DIY9O6DIc4AtwsMbtHJQ3(Em2LF7x3juRtdbTH3oHdcNaHUtuUhmjl10pi8HyH0dXubHonK4rbqwUIDB2OFc7GqsANOCpQENKn6NWoiKK2(Em2zP9R7eL7r17KCaOPAm7eQ1PHG2WB7BFNWR)CH9OA7WJIP9R7XyF)6oHADAiOn82jCq4ei0DYCLZcE9NlShvlGQr9or5Eu9oXeWECSLb9feSp1(23Jj79R7eQ1PHG2WBNud7em57eL7r17eMki0PH2jlmzRC2cJdThJ9DctfyB9t7esgNAicYYR)CH9OAlG(A04DcheobcDNWRgAfUi6mbA1y5kMRqKGADAiODYct2rpHHSCf7rdBpg77eMQzr7K5kNf86pxypQwaOVgn(qVDO5kNf86pxypQwaTaQhvFOX5qPDiEvgOAul41FUWEuTaqFnA8HE)qZvol41FUWEuTaqFnA8HsF77XKL9R7eQ1PHG2WBNud7efcANOCpQENWubHon0ozHjBLZwyCO9ySVtyQaBRFANqY4udrqwE9NlShvBb0xJgVt4GWjqO7eE1qRWfrNjqRglxXCfIeuRtdbDOuhkTdnx5SaVARKrddBNgcJJgMfqkeJI1WHGdUdXubHonKGKXPgIGS86pxypQ2cOVgn(qS4qSlyPdnohcghs8vzo04CO0o0CLZc8QTsgnmSDAimoAyIVkJf7kxYdn(hAUYzbE1wjJgg2oneghnmb2vUKhk9dL(ozHj7ONWqwUI9OHThJ9Dct1SODctfe60qcSKtl0cOEu923Jj)2VUtOwNgcAdVDcheobcDNmx5SGx)5c7r1cOAuVtuUhvVtMkmBLToi4sI3(EmwA)6oHADAiOn82jCq4ei0DIY9GjzPM(bHpeloe7hk1HMRCwWR)CH9OAbunQ3jk3JQ3jMGz0WSZ6p3(Emw((1Dc160qqB4TtwyYo6jmKLRypAy7XyFNWbHtGq3jPDiL7btYsn9dcFO3LEiL7btYcvUiG1Hthco4oedpeVkdunQfdpf1Hm2Sr)ewaifIXdL(HsDigEiE1qRWfrNjqRglxXCfIeuRtdbDOuhI)Oaye(qSq6Hy)qPo0CLZcE9NlShvlwdhk1Hy4HMRCwKdaH9c8fas5(HsDigEO5kNfpLBXoGujfas5(HsDONYTyhqQKw8azmyB02SjG94h6Tdnx5S4HupAy21Gaqk3p07hs27KfMSvoBHXH2JX(or5Eu9ojhaYonk23(EmgK9R7eQ1PHG2WBNud7em57eL7r17eMki0PH2jlmzRC2cJdThJ9DctfyB9t7esMbI7eKnhaYonk2X7eoiCce6oHxn0kCr0zc0QXYvmxHib160qq7KfMSJEcdz5k2Jg2Em23jmvZI2jk3JQf5aq2PrXUG)Oaye2Mbk3JQvZHE7qPDiMki0PHeKmo1qeKLx)5c7r1wa91OXhA8p0CLZIOZeOvJLRyUcrcOfq9O6dL(HG)H4vzGQrTihaYonk2fqlG6r1BFp2lB)6oHADAiOn82j1Wobt(or5Eu9oHPccDAODYct2kNTW4q7XyFNWub2w)0oPjcIGS5aq2PrXoENWbHtGq3j8QHwHlIotGwnwUI5kejOwNgcANSWKD0tyilxXE0W2JX(oHPAw0oHtH5qPDiMki0PHeKmo1qeKLx)5c7r1wa91OXhc(hkTdnx5Si6mbA1y5kMRqKaAbupQ(qJ)HGXHeFvMdL(HsF77XEP7x3juRtdbTH3ozHj7ONWqwUI9OHThJ9DcheobcDNK2HuUhmjl10pi8HEx6HuUhmjlu5IawhoDi4G7qm8q8Qmq1Owm8uuhYyZg9tybGuigpu6hk1H4vdTcxeDMaTASCfZvisqTone0HsDi(JcGr4dXcPhI9dL6qPDiMki0PHeKmde3jiBoaKDAuSJpelKEiMki0PHenrqeKnhaYonk2Xhco4oetfe60qcsgNAicYYR)CH9OAlG(A04d9U0dnx5Si6mbA1y5kMRqKaAbupQ(qWb3HMRCweDMaTASCfZvisGDLl5HE)qY(qWb3HMRCweDMaTASCfZvisaOVgn(qVFiyCiXxL5qWb3H4vzGQrTa)ezpAy2HAebeasHy8qPoKY9GjzPM(bHpelKEiMki0PHe86pxypQ2IFIShnm7qnIahk1H4ftQ12fDa7XTzLou6hk1HMRCwWR)CH9OAXA4qPouAhIHhAUYzroae2lWxaiL7hco4o0CLZIOZeOvJLRyUcrca91OXh69djxblDO0puQdXWdnx5S4PCl2bKkPaqk3puQd9uUf7asL0IhiJbBJ2MnbSh)qVDO5kNfpK6rdZUgeas5(HE)qYENSWKTYzlmo0Em23jk3JQ3j5aq2PrX(23JXUC3VUtOwNgcAdVDcheobcDNawnLlamsafyEmyIwbmA51)RnKGADAiOdL6qZvolGcmpgmrRagT86)1gsavJ6dL6qZvolGcmpgmrRagT86)1gYQaU2KaQg1hk1H4vzGQrTyUYzluG5XGjAfWOLx)V2qcaPqmEOuhIHhYvd1UaSAYwz7qnIacQ1PHG2jk3JQ3j8A1obWdKXS99ySZ((1Dc160qqB4Tt4GWjqO7eWQPCbGrcOaZJbt0kGrlV(FTHeuRtdbDOuhAUYzbuG5XGjAfWOLx)V2qcOAuFOuhAUYzbuG5XGjAfWOLx)V2qwfW1Meq1O(qPoeVkdunQfZvoBHcmpgmrRagT86)1gsaifIXdL6qm8qUAO2fGvt2kBhQreqqTone0or5Eu9orbCTjljZGPWr1BFpg7YE)6oHADAiOn82jCq4ei0Dcy1uUaWibuG5XGjAfWOLx)V2qcQ1PHGouQdnx5SakW8yWeTcy0YR)xBibunQpuQdnx5SakW8yWeTcy0YR)xBiBguyxavJ6DIY9O6DsguyFwgF77Xyxw2VUtOwNgcAdVDcheobcDNawnLlamsadeydJ2GhCdjOwNgc6qPo0CLZcE9NlShvlGQr9or5Eu9ojdkSB7IPU99ySl)2VUtOwNgcAdVDIY9O6DcxngRY9OARjW(oXey326N2jk3dMK1vd1oE77XyNL2VUtOwNgcAdVDYct2rpHHSCf7rdBpg77eoiCce6ozUYzbV(Zf2JQfq1O(qPouAhIHhcSAkxayKakW8yWeTcy0YR)xBib160qqhco4o0CLZcOaZJbt0kGrlV(FTHeRHdbhChAUYzbuG5XGjAfWOLx)V2q2mOWUynCOuhYvd1UaSAYwz7qnIacQ1PHGouQdXRYavJAXCLZwOaZJbt0kGrlV(FTHeasHy8qPFOuhkTdXWdbwnLlamsadeydJ2GhCdjOwNgc6qWb3HGO5kNfWab2WOn4b3qI1WHs)qPouAhs5EuT4tovar02SjG94hk1HuUhvl(KtfqeTnBcypUfqFnA8HEx6HKRGLFi4G7qk3JQfyEb4pcsgIV8OHDOuhs5EuTaZla)rqYq8Ltwa91OXh69djxbl)qWb3HuUhvlYbGMQXiizi(YJg2HsDiL7r1ICaOPAmcsgIVCYcOVgn(qVFi5ky5hco4oKY9OAXaJGAAuSlizi(YJg2HsDiL7r1Ibgb10OyxqYq8Ltwa91OXh69djxbl)qWb3HuUhvlYg9tyhesscsgIV8OHDOuhs5EuTiB0pHDqijjizi(YjlG(A04d9(HKRGLFO03jlmzRC2cJdThJ9DIY9O6DcV(Zf2JQ3(Em2z57x3juRtdbTH3oHdcNaHUtMRCwWR)CH9OAHrXULKzia0HEx6HuUhvl41FUWEuTWOy3UWe0or5Eu9oHRgJv5EuT1eyFNycSBB9t7eE9NlShvB5vzGQrnE77XyNbz)6oHADAiOn82jCq4ei0DsAhAUYzXt5wSdivsbGuUFOuhs5EWKSut)GWhIfspetfe60qcE9NlShvBZg9tyhesshk9dbhChkTdnx5Sihac7f4laKY9dL6qk3dMKLA6he(qSq6HyQGqNgsWR)CH9OAB2OFc7Gqs6qJ)HaRMYfagjYbGWEb(cQ1PHGou67eL7r17KSr)e2bHK023JX(lB)6oHADAiOn82jCq4ei0DYCLZc8QTsgnmSDAimoAywaPqmkwdhk1HMRCwGxTvYOHHTtdHXrdZcifIrbG(A04dXIdXvSB94t7eL7r17Kbgb10OyF77Xy)LUFDNqTone0gE7eoiCce6ozUYzroae2lWxaiL77eL7r17Kbgb10OyF77XKTC3VUtOwNgcAdVDcheobcDNmx5SyGrqXnk(laKY9dL6qZvolgyeuCJI)ca91OXhIfhIRy36XNouQdL2HMRCwWR)CH9OAbG(A04dXIdXvSB94thco4o0CLZcE9NlShvlGQr9Hs)qPoKY9GjzPM(bHp07hIPccDAibV(Zf2JQTzJ(jSdcjPDIY9O6DYaJGAAuSV99yYM99R7eQ1PHG2WBNWbHtGq3jZvolEk3IDaPskaKY9dL6qZvol41FUWEuTynStuUhvVtgyeutJI9TVht2YE)6oHADAiOn82jCq4ei0DYaGyAHXHeSlW8cWFouQdnx5S4HupAy21Gaqk3puQdPCpyswQPFq4d9(HyQGqNgsWR)CH9OAB2OFc7GqsANOCpQENmWiOMgf7BFpMSLL9R7eQ1PHG2WBNOCpQENGFIShnm7qnIa7eoiCce6ozUYzbV(Zf2JQfRHdL6qm8qk3JQf5aq2PrXUG)Oaye(qPoKY9GjzPM(bHpelKEiMki0PHe86pxypQ2IFIShnm7qnIahk1HuUhvlgEkQdzSzJ(jSiVmglG4pkagz94thIfhkVmglGGwCpQENeTtaWAWTrENOCpQwKdazNgf7c(JcGryPk3JQf5aq2PrXU4RYy5pkagH3(Emzl)2VUtOwNgcAdVDcheobcDNmx5SGx)5c7r1I1WHsDO0ouAhs5EuTihaYonk2f8hfaJWh69dX(HsDixnu7Ibgbf3O4VGADAiOdL6qk3dMKLA6he(qspe7hk9dbhChIHhYvd1UyGrqXnk(lOwNgc6qWb3HuUhmjl10pi8HyXHy)qPFOuhAUYzXdPE0WSRbbGuUFO3o0t5wSdivslEGmgSnAB2eWE8d9(HK9or5Eu9oz4POoKXMn6NWBFpMSzP9R7eQ1PHG2WBNWbHtGq3jZvol41FUWEuTaQg1hk1H4vzGQrTGx)5c7r1ca91OXh69dXvSB94thk1HuUhmjl10pi8HyH0dXubHonKGx)5c7r12Sr)e2bHK0or5Eu9ojB0pHDqijT99yYMLVFDNqTone0gE7eoiCce6ozUYzbV(Zf2JQfq1O(qPoeVkdunQf86pxypQwaOVgn(qVFiUIDRhF6qPoedpeVAOv4ISr)Kv5Ca5r1cQ1PHG2jk3JQ3j5aqt1y2(EmzZGSFDNqTone0gE7eoiCce6ozUYzbV(Zf2JQfa6RrJpeloexXU1JpDOuhAUYzbV(Zf2JQfRHdbhChAUYzbV(Zf2JQfq1O(qPoeVkdunQf86pxypQwaOVgn(qVFiUIDRhFANOCpQENG5fG)S99yY(LTFDNqTone0gE7eoiCce6ozUYzbV(Zf2JQfa6RrJp07hcghs8vzouQdPCpyswQPFq4dXIdX(or5Eu9oXemJgMDw)523Jj7x6(1Dc160qqB4Tt4GWjqO7K5kNf86pxypQwaOVgn(qVFiyCiXxL5qPo0CLZcE9NlShvlwd7eL7r17eiGcRASDci1F2(EmzrU7x3juRtdbTH3oHdcNaHUtCfaJCXdPg)rmW9d9U0djlY9qPoKRgQDbMuq0WSET4pcQ1PHG2jk3JQ3jyEb4pBF77eL7btY6QHAhVFDpg77x3juRtdbTH3oHdcNaHUtuUhmjl10pi8HyXHy)qPo0CLZcE9NlShvlGQr9HsDO0oetfe60qcp(K1llV(Zf2JQpeloeVkdunQfMGz0WSZ6pfqlG6r1hco4oetfe60qcp(K1llV(Zf2JQp07spKCpu67eL7r17etWmAy2z9NBFpMS3VUtOwNgcAdVDcheobcDNWubHonKWJpz9YYR)CH9O6d9U0dj3dbhChkTdXRYavJAXNCQacOfq9O6d9(HyQGqNgs4XNSEz51FUWEu9HsDigEixnu7cWQjBLTd1iciOwNgc6qPFi4G7qUAO2fGvt2kBhQreqqTone0HsDO5kNfGvt2kBhQreqSgouQdXubHonKWJpz9YYR)CH9O6dXIdPCpQw8jNkGGxLbQg1hco4ouoG94wa91OXh69dXubHonKWJpz9YYR)CH9O6DIY9O6DYNCQaBFpMSSFDNqTone0gE7eoiCce6oXvd1UqnKmyhO4XdfBZlaJcQ1PHGouQdL2HMRCwWR)CH9OAbunQpuQdXWdnx5S4PCl2bKkPaqk3pu67eL7r17eiGcRASDci1F2(23jyxBifazbLREu9(19ySVFDNqTone0gE7eoiCce6or5EWKSut)GWhIfspetfe60qINYTyhqQK2Sr)e2bHK0HsDO0o0CLZINYTyhqQKcaPC)qWb3HMRCwKdaH9c8fas5(HsFNOCpQENKn6NWoiKK2(EmzVFDNqTone0gE7eoiCce6ozUYzroae2lWxaiL77eL7r17Kbgb10OyF77XKL9R7eQ1PHG2WBNWbHtGq3jZvolEk3IDaPskaKY9dL6qZvolEk3IDaPska0xJgFO3pKY9OAroa0ungbjdXxoz94t7eL7r17Kbgb10OyF77XKF7x3juRtdbTH3oHdcNaHUtMRCw8uUf7asLuaiL7hk1Hs7qdaIPfghsWUihaAQgZHGdUdLdaHDf4eqOCpyshco4oKY9OAXaJGAAuSlI2MnbSh)qPVtuUhvVtgyeutJI9TVhJL2VUtOwNgcAdVDcheobcDNmx5SaVARKrddBNgcJJgMfqkeJI1WHsDO0oeVkdunQfGvt2kBhQreqaOVgn(qVDiL7r1cWQjBLTd1iciizi(YjRhF6qVDiUIDRhF6qS4qZvolWR2kz0WW2PHW4OHzbKcXOaqFnA8HGdUdXWd5QHAxawnzRSDOgrab160qqhk9dL6qmvqOtdj84twVS86pxypQ(qVDiUIDRhF6qS4qZvolWR2kz0WW2PHW4OHzbKcXOaqFnA8or5Eu9ozGrqnnk23(Emw((1Dc160qqB4Tt4GWjqO7K5kNfpLBXoGujfas5(HsDixbWix8qQXFedC)qVl9qYICpuQd5QHAxGjfenmRxl(JGADAiODIY9O6DYaJGAAuSV99ymi7x3juRtdbTH3oHdcNaHUtMRCwmWiO4gf)fas5(HsDiUIDRhF6qVFO5kNfdmckUrXFbG(A04DIY9O6DYaJGAAuSV99yVS9R7eQ1PHG2WBNSWKD0tyilxXE0W2JX(oHdcNaHUty4HYbGWUcCciuUhmPdL6qm8qmvqOtdjYbGStJID7qvMOHDOuhkTdL2Hs7qk3JQf5aqt1yeKmeF5rd7qPouAhs5EuTihaAQgJGKH4lNSa6RrJp07hsUcw6qWb3Hy4HaRMYfagjYbGWEb(cQ1PHGou6hco4oKY9OAXaJGAAuSlizi(YJg2HsDO0oKY9OAXaJGAAuSlizi(YjlG(A04d9(HKRGLoeCWDigEiWQPCbGrICaiSxGVGADAiOdL(Hs)qPo0CLZIhs9OHzxdcaPC)qPFi4G7qPDixnu7cmPGOHz9AXFeuRtdbDOuhYvamYfpKA8hXa3p07spKSi3dL6qPDO5kNfpK6rdZUgeas5(HsDigEiL7r1cmVa8hbjdXxE0WoeCWDigEO5kNfpLBXoGujfas5(HsDigEO5kNfpK6rdZUgeas5(HsDiL7r1cmVa8hbjdXxE0WouQdXWd9uUf7asL0IhiJbBJ2MnbSh)qPFO0pu67KfMSvoBHXH2JX(or5Eu9ojhaYonk23(ESx6(1Dc160qqB4Tt4GWjqO7KbaX0cJdjyxG5fG)COuhAUYzXdPE0WSRbbGuUFOuhYvd1UatkiAywVw8hb160qqhk1HCfaJCXdPg)rmW9d9U0djlY9qPoKY9GjzPM(bHp07hIPccDAiXt5wSdivsB2OFc7GqsANOCpQENmWiOMgf7BFpg7YD)6oHADAiOn82jCq4ei0Dcdpetfe60qIHNI6qg7qvMOHDOuhkTdXWd5QHAxKb136pKvXpewqTone0HGdUdPCpyswQPFq4dXIdX(Hs)qPouAhs5EWKSqLlcyD40HE)qY(qWb3HuUhmjl10pi8HyH0dXubHonK4rbqwUIDB2OFc7Gqs6qWb3HuUhmjl10pi8HyH0dXubHonK4PCl2bKkPnB0pHDqijDO03jk3JQ3jdpf1Hm2Sr)eE77XyN99R7eQ1PHG2WBNOCpQENWvJXQCpQ2AcSVtmb2TT(PDIY9GjzD1qTJ3(Em2L9(1Dc160qqB4Tt4GWjqO7eL7btYsn9dcFiwCi23jk3JQ3jqafw1y7eqQ)S99ySll7x3juRtdbTH3oHdcNaHUtCfaJCXdPg)rmW9d9U0djlY9qPoKRgQDbMuq0WSET4pcQ1PHG2jk3JQ3jyEb4pBFpg7YV9R7eQ1PHG2WBNWbHtGq3jk3dMKLA6he(qSq6HyQGqNgsOaU2KLKzWu4O6dL6qFTvXa3pelKEiMki0PHekGRnzjzgmfoQ2(1w3jk3JQ3jkGRnzjzgmfoQE77XyNL2VUtOwNgcAdVDcheobcDNOCpyswQPFq4dXcPhIPccDAiXJcGSCf72Sr)e2bHK0or5Eu9ojB0pHDqijT99ySZY3VUtuUhvVtYbGMQXStOwNgcAdVTV9DcV(Zf2JQT8Qmq1OgVFDpg77x3jk3JQ3jdLhvVtOwNgcAdVTVht27x3jk3JQ3jttvq28cW4oHADAiOn82(Emzz)6or5Eu9ozsambKmAy7eQ1PHG2WB77XKF7x3jk3JQ3j5aqttvq7eQ1PHG2WB77XyP9R7eL7r17eT5e2bQXYvJzNqTone0gEBFpglF)6or5Eu9ozHjB40hVtOwNgcAdVTVhJbz)6oHADAiOn82jk3JQ3jWmkuOEbW2PcbJ2jlmzRC2cJdThJ9DcheobcDNOCpQw8jNkGiAB2eWEClG(A04d9U0djxblTtOCM4UT1pTtGzuOq9cGTtfcgT99yVS9R7eQ1PHG2WBNWbHtGq3jGvt5caJeo9hkGASJuWGGADAiOdL6qZvolizE0f2JQfRHDIY9O6DIhFYosbdBF7BFNWKa4O69yYwUYwUSlBzZs7KrkOJggENiRWGj)p24DSxog4qh61h6qXFOa(HYf4qSbQb7WJIj2oeGg3vaiOdHRpDiD51xDc6q8hTHryXX6lIMoelXahsEvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2Hst2YKU4y9frthILZahsEvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2HsJDzsxCS(IOPdXYzGdjVQzsaNGoeBGvt5caJeYHTd51HydSAkxayKqocQ1PHGy7qPjBzsxCS(IOPd9szGdjVQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qPXUmPlowFr00HyNDg4qYRAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2oK6hsw)sEXHsJDzsxCSESkRWGj)p24DSxog4qh61h6qXFOa(HYf4qSbrzDzC2oeGg3vaiOdHRpDiD51xDc6q8hTHryXX6lIMoe7mWHKx1mjGtqhInWQPCbGrc5W2H86qSbwnLlamsihb160qqSDi1pKS(L8IdLg7YKU4y9frths2mWHKx1mjGtqhInxnu7c5W2H86qS5QHAxihb160qqSDO0KTmPlowFr00Hyjg4qYRAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2ouASlt6IJ1xenDiwodCi5vntc4e0HyZvd1UqoSDiVoeBUAO2fYrqToneeBhkn2LjDXX6lIMoedcdCi5vntc4e0HyZvd1UqoSDiVoeBUAO2fYrqToneeBhkn2LjDXX6lIMoe7mimWHKx1mjGtqhkj(Y7qygBxL5qJNJNhYRd9ILEOFbTml8HQbcOEbouAJNPFO0yxM0fhRViA6qSZGWahsEvZKaobDi24vdTcxih2oKxhInE1qRWfYrqToneeBhkn2LjDXX6lIMoe7Vug4qYRAMeWjOdXgVAOv4c5W2H86qSXRgAfUqocQ1PHGy7qPXUmPlowFr00HKTCzGdjVQzsaNGoeBGvt5caJeYHTd51HydSAkxayKqocQ1PHGy7qPXUmPlowFr00HKn7mWHKx1mjGtqhInWQPCbGrc5W2H86qSbwnLlamsihb160qqSDO0yxM0fhRViA6qYw2mWHKx1mjGtqhInWQPCbGrc5W2H86qSbwnLlamsihb160qqSDO0yxM0fhRViA6qYw(XahsEvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2HsJDzsxCS(IOPdjBwIboK8QMjbCc6qSbwnLlamsih2oKxhInWQPCbGrc5iOwNgcITdLg7YKU4y9yvwHbt(FSX7yVCmWHo0Rp0HI)qb8dLlWHyBaq86pvNTdbOXDfac6q46thsxE9vNGoe)rByewCS(IOPdjBg4qYRAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2ouASlt6IJ1xenDizZahsEvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2Hu)qY6xYlouASlt6IJ1xenDizHboK8QMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdLg7YKU4y9frthswyGdjVQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qQFiz9l5fhkn2LjDXX6lIMoK8JboK8QMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdLg7YKU4y9frths(XahsEvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2Hu)qY6xYlouASlt6IJ1xenDiwIboK8QMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdLg7YKU4y9frthILyGdjVQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qQFiz9l5fhkn2LjDXX6XQScdM8)yJ3XE5yGdDOxFOdf)Hc4hkxGdXgV(Zf2JQT8Qmq1OgZ2Ha04UcabDiC9PdPlV(QtqhI)OnmclowFr00HEzmWHKx1mjGtqhInWQPCbGrc5W2H86qSbwnLlamsihb160qqSDO0yxM0fhRhRYkmyY)JnEh7LJbo0HE9Hou8hkGFOCboeBk3dMK1vd1oMTdbOXDfac6q46thsxE9vNGoe)rByewCS(IOPdjBg4qYRAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2ouAYwM0fhRViA6qYcdCi5vntc4e0HyZvd1UqoSDiVoeBUAO2fYrqToneeBhkn2LjDXX6XQScdM8)yJ3XE5yGdDOxFOdf)Hc4hkxGdXg21gsbqwq5QhvZ2Ha04UcabDiC9PdPlV(QtqhI)OnmclowFr00Hyjg4qYRAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2ouASlt6IJ1xenDiwodCi5vntc4e0HyZvd1UqoSDiVoeBUAO2fYrqToneeBhs9djRFjV4qPXUmPlowFr00HEzmWHKx1mjGtqhInxnu7c5W2H86qS5QHAxihb160qqSDO0yxM0fhRViA6qVmg4qYRAMeWjOdXgy1uUaWiHCy7qEDi2aRMYfagjKJGADAii2ouAYwM0fhRViA6qVug4qYRAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2ouASlt6IJ1xenDi2LldCi5vntc4e0HyZvd1UqoSDiVoeBUAO2fYrqToneeBhkn2LjDXX6lIMoe7YcdCi5vntc4e0HyZvd1UqoSDiVoeBUAO2fYrqToneeBhs9djRFjV4qPXUmPlowpwLvyWK)hB8o2lhdCOd96dDO4pua)q5cCi241FUWEuTD4rXeBhcqJ7kae0HW1NoKU86RobDi(J2WiS4y9frths2mWHKx1mjGtqhInE1qRWfYHTd51HyJxn0kCHCeuRtdbX2Hu)qY6xYlouASlt6IJ1xenDizHboK8QMjbCc6qSXRgAfUqoSDiVoeB8QHwHlKJGADAii2ouASlt6IJ1xenDiwodCi5vntc4e0HyJxn0kCHCy7qEDi24vdTcxihb160qqSDO0yxM0fhRViA6qmimWHKx1mjGtqhkj(Y7qygBxL5qJNhYRd9ILEiOGzGJQpunqa1lWHsd(PFO0yxM0fhRViA6qmimWHKx1mjGtqhInE1qRWfYHTd51HyJxn0kCHCeuRtdbX2Hu)qY6xYlouASlt6IJ1xenDOxgdCi5vntc4e0HsIV8oeMX2vzo045H86qVyPhckyg4O6dvdeq9cCO0GF6hkn2LjDXX6lIMo0lJboK8QMjbCc6qSXRgAfUqoSDiVoeB8QHwHlKJGADAii2oK6hsw)sEXHsJDzsxCS(IOPd9szGdjVQzsaNGoeB8QHwHlKdBhYRdXgVAOv4c5iOwNgcITdLg7YKU4y9frthID5YahsEvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2Hu)qY6xYlouASlt6IJ1xenDi2LldCi5vntc4e0HydSAkxayKqoSDiVoeBGvt5caJeYrqToneeBhkn2LjDXX6lIMoe7SZahsEvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2Hu)qY6xYlouASlt6IJ1xenDi2zNboK8QMjbCc6qSbwnLlamsih2oKxhInWQPCbGrc5iOwNgcITdLg7YKU4y9frthIDzZahsEvZKaobDi2aRMYfagjKdBhYRdXgy1uUaWiHCeuRtdbX2HsJDzsxCS(IOPdXUSWahsEvZKaobDi2aRMYfagjKdBhYRdXgy1uUaWiHCeuRtdbX2HsJDzsxCS(IOPdXolXahsEvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2HsJDzsxCS(IOPdXolXahsEvZKaobDi2aRMYfagjKdBhYRdXgy1uUaWiHCeuRtdbX2Hst2YKU4y9frthIDgeg4qYRAMeWjOdXgy1uUaWiHCy7qEDi2aRMYfagjKJGADAii2ouASlt6IJ1xenDizl)yGdjVQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qPjBzsxCS(IOPdjBwodCi5vntc4e0HyJxn0kCHCy7qEDi24vdTcxihb160qqSDi1pKS(L8IdLg7YKU4y9frthswKldCi5vntc4e0HyZvd1UqoSDiVoeBUAO2fYrqToneeBhs9djRFjV4qPXUmPlowpwhV)Hc4e0HyqoKY9O6dzcSJfhR7e8aX3JXYLLDYaOYHH2jY3HyzbGo0lVcJowLVd94(aMbGp8Hf(ZAk41h(44VmQhvZbA2Hpo(C4FSkFhIvTxkGXdjB2L4qYwUYM9J1Jv57qY7rByeMbowLVdn(hIbfMouoG94wa91OXhcO(dboK)O9HCfaJCHhFY6LfkOdLlWHmk2hFmXRg6q6mmHZ4HwyfgHfhRY3Hg)d9IQWuFiUI9dbOXDfa6tTJpuUahsE1FUWEu9HsleKqIdbvnB(HEkd0Hc)q5cCi9qzaHFo0lp5uboexXE6IJv57qJ)HK1Ton0HWoi4(H4pexYOHDOQpKEOmn6q5cij(qrFi)HoedM83loKxhcqqloDOrfqstPqIJ1Jv57qYAzi(YjOdnPCbOdXR)u9dnjyrJfhIbJZPbhFOU6X)rb)8YCiL7r14dvTHrXXQY9OASyaq86pv)nPWxbCTjB0ozme3pwLVd96tGpetfe60qhcpq8ihe(q(dDOE9Ne4qv(qUcGro(qQFOrpb)5qYQLFOehqQKhILz0pHDqijHpuTCCarhQYhsE1FUWEu9HWp1YaDOjDOfMGehRk3JQXIbaXR)u93KcFMki0PHKO1pj9PCl2bKkPnB0pHDqijjrniftUerwktfe60qINYTyhqQK2Sr)e2bHKKu5kbt1SiPYECC1qTlYg9t2b15pVjlJddD1qTlYg9t2b15phRY3HE9jWhIPccDAOdHhiEKdcFi)HouV(tcCOkFixbWihFi1p0ONG)CizvfaDi5Py)qSmJ(jSdcjj8HQLJdi6qv(qYR(Zf2JQpe(PwgOdnPdTWe0Hu8HYHXqaXXQY9OASyaq86pv)nPWNPccDAijA9tsFuaKLRy3Mn6NWoiKKKOgKIjxIilLPccDAiXJcGSCf72Sr)e2bHKKu5kbt1SiPYECC1qTlYg9t2b15pVjlJddD1qTlYg9t2b15phRY3HE9jWhIPccDAOdHhiEKdcFi)HouV(tcCOkFixbWihFi1p0ONG)Ciz1YpuIdivYdXYm6NWoiKKWhsb0Hwyc6qqlq0WoK8Q)CH9OAXXQY9OASyaq86pv)nPWNPccDAijA9ts51FUWEuTnB0pHDqijjrniftUerwktfe60qcE9NlShvBZg9tyhesssLRemvZIKklJJRgQDr2OFYoOo)5nw(4Wqxnu7ISr)KDqD(ZXQ8DOxFc8HyQGqNg6q4bIh5GWhYFOd1R)KahQYhYvamYXhs9dn6j4phIbdW1MoKSwMbtHJQpuTCCarhQYhsE1FUWEu9HWp1YaDOjDOfMGehRk3JQXIbaXR)u93KcFMki0PHKO1pjvbCTjljZGPWr1sudsXKlrKLYubHonKqbCTjljZGPWr1sLRemvZIK(sFPJJRgQDr2OFYoOo)5nzpom0vd1UiB0pzhuN)CSkFh61NaFiMki0PHoeEG4roi8H8h6qdeGtTRWOdv5d91wp0Km1Odn6j4phIbdW1MoKSwMbtHJQp0OWyoux(HM0HwycsCSQCpQglgaeV(t1Ftk8zQGqNgsIw)KufW1MSKmdMchvB)ARsarzDzCPYp5krnifqyYpwLVd96tGpetfe60qhkWhAHjOd51HWdepYmEi)HoK(Rv7hQYhYJpDOOpeM4vdHpK)O(H(lSFObfJpKMDcCi5v)5c7r1hIKziae(qtkxa6qSmJ(jSdcjj8HgfgZHM0Hwyc6qDb(QXWO4yv5EunwmaiE9NQ)Mu4ZubHonKeT(jPqKrz0Mn6NWoiKKKaIY6Y4sLRe1GuaHj)yv(oKSs4phIbx0qMOHjXHKx9NlShvZg(q8Qmq1O(qJcJ5qt6qacAXjOdnz8q6HaAdv)dP)A1UehAU8d5p0H61FsGdv5dXbHJpe2vGJpetcW4HEcyphsZoboKY9GP6rd7qYR(Zf2JQpK2qhcBQr4dbvJ6d51ifaHpK)qhIAOdv5djV6pxypQMn8H4vzGQrT4qYkpuFOVkz0WoeeXdCun(qrFi)HoedM83lK4qYR(Zf2JQzdFia91OJg2H4vzGQr9Hc8Hae0ItqhAY4H8NaFOmq5Eu9H86qkNxR2puUahIbx0qMOHjowvUhvJfdaIx)P6Vjf(mvqOtdjrRFsQKrdzIgMfqqlUhvlbeL1LXLkxH8tIAqkGWKFSkFh61h6qqlG6r1hQYhspuYQpedUOHXg(qWZqyC0WoK8Q)CH9OAXXQY9OASyaq86pv)nPWNPccDAijA9tsXsoTqlG6r1sudsXKlbt1SiPS0XQY9OASyaq86pv)nPWNPccDAijA9ts51FUWEuTTA7ctsudsXKlbt1SiP04UIHbcs8vUobKf)qKB)lCWHdoACxXWabj(Ahzc7LTY2Vc1egdhC04UIHbcsaZOqH6faBNkemco4OXDfddeKaMrHc1la2(ji1yIQHdoACxXWabjcyD4r12VcJW28ctWbhnURyyGGe(4H2e2ovGK4HOjmCWrJ7kggiiHoESaK)uyloAyeKDWS(kmco4OXDfddeKqBEqTBLSl3wz7OadvF4GJg3vmmqqc8tXLCgobW2S2WGdoACxXWabjAAbuJfZyRdyYs9J2CcahC04UIHbcsmvdLdazNaT5phRY3HKvRrhYunSdnPCbOdjV6pxypQ(q4NAzGoKS(pWiGuZHEjaOwBoDOjDOfMGyq7XQY9OASyaq86pv)nPWNPccDAijA9tsP)aJasn2ca1AZjlezugLaIY6Y4sz)LjrnifqyYpwLVdjRwJoKPAyhAs5cqhsE1FUWEu9HWp1YaDiheTKKJpK)O(HCqadgboKEi8JciOdjB5EimXRg6qYJb)HQ(qL)qGd5GOLKC8H6Yp0Ko0ctqmO9yv5EunwmaiE9NQ)Mu4ZubHonKeT(jPvBxyYYxELZsudsXKlbt1SiPYwUsezPmvqOtdj41FUWEuTTA7cthRk3JQXIbaXR)u93KcFMki0PHKO1pjTA7ctw(YRCwIAqkMCjyQMfjv2SKerwknURyyGGeFLRtazXpe52)ch8JvL7r1yXaG41FQ(BsHptfe60qs06NKwTDHjlF5volrniftUemvZIKkB5(gtfe60qc6pWiGuJTaqT2CYcrgLrjISuACxXWabjO)aJasn2ca1AZPJv57qV(qhQx)jbouLpKRayKJpuYtK9OHDi5VAeboe(PwgOdnPdTWe0HQ(qqlq0WoK8Q)CH9OAXXQY9OASyaq86pv)nPWNPccDAijA9ts51FUWEuTf)ezpAy2HAebKaIY6Y4sLTe1GuaHj)yv5EunwmaiE9NQ)Mu4VWKnC6lrRFskUwgBaRdNahRk3JQXIbaXR)u93Kc)FaafWgFfgDSQCpQglgaeV(t1Ftk8hyeutJIDjISugoaiMIbgb10Oy)y9yv(oKSwgIVCc6qetcW4H84thYFOdPCVahkWhszQHrNgsCSQCpQglLxR2jaEGmgjISugcwnLlamsafyEmyIwbmA51)Rn0XQY9OA8BsHptfe60qs06NK6XNSEz51FUWEuTe1Gum5sWunlsQRgQDroae2vGtGXjhac7kWjGaqFnA8BPXRYavJAbV(Zf2JQfa6RrJhN0yF8zQGqNgsiz0qMOHzbe0I7r1JJRgQDHKrdzIgw6PpomKxLbQg1cE9NlShvlaKcX44mx5SGx)5c7r1cOAuFSkFh6LxLKoeEbOdjV6pxypQ(qb(qqKrzKGouKputeebDOPIjOdv9H8h6q0FGraPgBbGAT5KfImkJhIPccDAOJvL7r143KcFMki0PHKO1pj1Jpz9YYR)CH9OAjQbPFvgjyQMfjLPccDAib9hyeqQXwaOwBozHiJY44NgVkdunQf0FGraPgBbGAT5KaAbupQE85vzGQrTG(dmci1ylauRnNea6RrJtFCyiVkdunQf0FGraPgBbGAT5KaqkeJsezP04UIHbcsq)bgbKASfaQ1MthRk3JQXVjf(mvqOtdjrRFsQhFY6LLx)5c7r1suds)QmsWunlskVkdunQfWmkuOEbW2PcbJea6RrJLiYsPXDfddeKaMrHc1la2oviy0XQY9OA8BsHptfe60qs06NK6XNSEz51FUWEuTe1G0VkJemvZIKox5SaSAYwz7qnIaca91OXsezPUAO2fGvt2kBhQrei1CLZcE9NlShvlGQr9XQY9OA8BsHptfe60qs06NK6XNSEz51FUWEuTe1G0VkJemvZIKYRYavJAby1KTY2HAebea6RrJFBUYzby1KTY2HAebeqlG6r1sezPUAO2fGvt2kBhQrei1CLZcE9NlShvlGQrDkEvgOAulaRMSv2ouJiGaqFnA8BS07mvqOtdj84twVS86pxypQ(yv5Eun(nPWh)ezpAy2HAebKiYsNRCwWR)CH9OAbunQtXubHonKWJpz9YYR)CH9OAwKxgJfqqlUhvNknEvgOAulaRMSv2ouJiGaqFnAmlYlJXciOf3JQHdog6QHAxawnzRSDOgrG0tXW0MRCweDMaTASCfZvisSgsnx5S4PCl2bKkPaqk3tpvAk3dMKLA6he(DMki0PHe86pxypQ2IFIShnm7qnIaWbNY9GjzPM(bHFNPccDAibV(Zf2JQTzJ(jSdcjj4GJPccDAiHhFY6LLx)5c7r1JFEzmwabT4Eunl4vzGQrD6hRk3JQXVjf(afk02T4bfiPerwAAZvol41FUWEuTaQg1PMRCwawnzRSDOgrabunQtLgtfe60qcp(K1llV(Zf2JQFNKH4lNSE8j4GJPccDAiHhFY6LLx)5c7r1SGxLbQg1cGcfA7w8GcKuaTaQhvNE6WbxAZvolaRMSv2ouJiGynKIPccDAiHhFY6LLx)5c7r1SqwKB6hRk3JQXVjf(qK6pZc0Kerw6CLZcE9NlShvlGQrDQ5kNfGvt2kBhQreqavJ6umvqOtdj84twVS86pxypQ(DsgIVCY6XNowvUhvJFtk8)bauaSTYwVaFQDjISuMki0PHeE8jRxwE9NlShv)Uuzj1CLZcE9NlShvlGQr9XQ8DiwwboedAO2FyeiXHwy6q6HyzbGoe8mk2pe)rbWOdbTard7qV8baua8HQ8HETaFQ9dXvSFiVoKYScOdX1HHOHDi(JcGr4df5dnE7mbA1Ci5PyUcrhkWhQl)qyYqCNGehRk3JQXVjf(5aq2PrXUelmzh9egYYvShnmPSlrKLQCpQw8daOayBLTEb(u7csgIV8OHLkVmglG4pkagz94tJVY9OAXpaGcGTv26f4tTlizi(YjlG(A043LFPy4t5wSdivslEGmgSnAB2eWE8umCUYzXt5wSdivsbGuUFSQCpQg)Mu4)daOa24RWijIS05kNf86pxypQwavJ6uq0CLZcGcfA7w8GcK0YCzAcOZWeoJcOAuNAUYzby1KTY2HAebeq1O(yv5Eun(nPWFHjB40xckNjUBB9tsHzuOq9cGTtfcgjrKLYubHonKWJpz9YYR)CH9OAwWRYavJ6XNLowvUhvJFtk8xyYgo9LO1pjL(dmci1ylauRnNKiYszQGqNgs4XNSEz51FUWEu97szQGqNgsq)bgbKASfaQ1MtwiYOmESQCpQg)Mu4VWKnC6lrRFskmdJdp2kBvmo(Hr9OAjISuMki0PHeE8jRxwE9NlShvZcPmvqOtdjQ2UWKLV8kNpwvUhvJFtk8xyYgo9LO1pj9RCDcil(Hi3(x4GlrKLYubHonKWJpz9YYR)CH9O63LYshRY3HgV5dTWrd7q6HWobQa6qvp(lmDOWPVehsnJugXhAHPdXGhqkuoa0HyqdHXK5q1YXbeDOkFi5v)5c7r1Id9s8hcmkWKehAaefi8Xd6qlC0WoedEaPq5aqhIbnegtMdnk8NdjV6pxypQ(qvBy8qr(qJ3otGwnhsEkMRq0Hc8HOwNgc6qAdDi9qlScJo0OQzZp0KoKPW(HkMe4q(dDiOfq9O6dv5d5p0HYbShxCSQCpQg)Mu4VWKnC6lrRFskeGuOCailtcJjJerwktfe60qcp(K1llV(Zf2JQzHuMki0PHevBxyYYxELZPsBUYzr0zc0QXYvmxHib2vUKsNRCweDMaTASCfZvis8vzSyx5schCmKxn0kCr0zc0QXYvmxHi4GJPccDAibV(Zf2JQTvBxyco4yQGqNgs4XNSEz51FUWEu9BSelYbSh3cOVgnE8C8KxLbQg1PFSkFhkPwMdnEH1HtGdHFQLb6qt6qlmbDOOpKEOrkJhYFu)qqfHB28dfTtGmbOdnk8Ndv(dbou1J)cthYbrlj5yXHEj(dboKdIwsYXhcQoux(HCqadgboKEi8JciOdnELhd(dv9HcxIdHRdf(H4AFOjDOfMGoeiG94hsZoboK2mEOYFiWHQE8xy6qoiAjjxCSQCpQg)Mu4VWKnC6lrRFskUwgBaRdNasezPmvqOtdj84twVS86pxypQMfszQGqNgsuTDHjlF5vo)g7S04Kgtfe60qIQTlmz5lVYzwi30HdoMki0PHeE8jRxwE9NlShv)o7Y9yv(o0RGagmcCOKAzo04fw4e4qKcmmEOrH)COXBNjqRMdjpfZvi6qf4qJEO(qHFOrk(qdaIRyxCSQCpQg)Mu4Z1Mtg7CLZs06NKIRLXgW6WJQLiYszQGqNgs4XNSEz51FUWEunlKYubHonKOA7ctw(YRCoftfe60qcp(K1llV(Zf2JQzHu2zPXHg3vmmqqciaPq5aqwMegtMuE8P3zPumKxn0kCr0zc0QXYvmxHi4GBUYzr0zc0QXYvmxHib2vUKsNRCweDMaTASCfZvis8vzSyx5sESkFh6LJ8d5p0HGcmpgmrRagT86)1g6qZvoFO1GehA1gcJpeV(Zf2JQpuGpeUQwCSQCpQg)Mu4ZRv7eapqgJerwky1uUaWibuG5XGjAfWOLx)V2qP4vzGQrTyUYzluG5XGjAfWOLx)V2qcaPqmMAUYzbuG5XGjAfWOLx)V2qwfW1Meq1OofdNRCwafyEmyIwbmA51)RnKynKIPccDAiHhFY6LLx)5c7r1Sq2S0XQY9OA8BsHVc4AtwsMbtHJQLiYsbRMYfagjGcmpgmrRagT86)1gkfVkdunQfZvoBHcmpgmrRagT86)1gsaifIXuZvolGcmpgmrRagT86)1gYQaU2KaQg1Py4CLZcOaZJbt0kGrlV(FTHeRHumvqOtdj84twVS86pxypQMfYMLowvUhvJFtk8ZGc7ZY4sezPGvt5caJeqbMhdMOvaJwE9)AdLIxLbQg1I5kNTqbMhdMOvaJwE9)AdjaKcXyQ5kNfqbMhdMOvaJwE9)AdzZGc7cOAuNIHZvolGcmpgmrRagT86)1gsSgsXubHonKWJpz9YYR)CH9OAwiBw6yv5Eun(nPWNRgJv5EuT1eyxIw)KuE9NlShvBhEumjrKLYubHonKWJpz9YYR)CH9O63Lk3JvL7r143KcFMki0PHKyHjBLZwyCiPSlXct2rpHHSCf7rdtk7s06NKMdazNgf72HQmrdtcMQzrszQGqNgs4XNSEz51FUWEu94llVRCpQwKdazNgf7I8YySaI)OayK1Jpn(k3JQf4Ni7rdZouJiGiVmglGGwCpQECsJxLbQg1c8tK9OHzhQreqaOVgn(DMki0PHeE8jRxwE9NlShvNEkMki0PHeE8jRxwE9NlShv)EoG94wa91OXWbNRgQDby1KTY2HAebsnx5SaSAYwz7qnIacOAuNIxLbQg1cWQjBLTd1icia0xJg)UY9OAroaKDAuSlYlJXci(JcGrwp(04RCpQwGFIShnm7qnIaI8YySacAX9O6XjnEvgOAulWpr2JgMDOgrabG(A0435vzGQrTaSAYwz7qnIaca91OXPNIxLbQg1cWQjBLTd1icia0xJg)EoG94wa91OXhRk3JQXVjf(mvqOtdjrRFs6WtrDiJDOkt0WKGPAwKuMki0PHeE8jRxwE9NlShv)UY9OAXWtrDiJnB0pHf5LXybe)rbWiRhFA8vUhvlWpr2JgMDOgrarEzmwabT4Eu94KgVkdunQf4Ni7rdZouJiGaqFnA87mvqOtdj84twVS86pxypQo9umvqOtdj84twVS86pxypQ(9Ca7XTa6RrJHdoWQPCbGrc8QTsgnmSDAimoAyWbNhF6Dw6yv5Eun(nPWhSAYwz7qnIasezPZvolaRMSv2ouJiGaQg1Py4CLZICaiSxGVaqk3tLgtfe60qcp(K1llV(Zf2JQzH05kNfGvt2kBhQreqaTaQhvNIPccDAiHhFY6LLx)5c7r1Sq5EuTihaYonk2f5LXybe)rbWiRhFco4yQGqNgs4XNSEz51FUWEunlYbSh3cOVgno9JvL7r143KcFUAmwL7r1wtGDjA9tsb1GD4rXKerw6CLZcWQjBLTd1iciwdPyQGqNgs4XNSEz51FUWEunlK7XQ8DizLhQpKSQcG4k2Jg2Hyzg9thkXbHKKehILfa6qWZOyhFi8tTmqhAshAHjOd51HGrnbuNoKSA5hkXbKkj(qAdDiVoejJtn0HGNrXobo0lVIDciowvUhvJFtk8ZbGStJIDjwyYw5Sfghsk7sSWKD0tyilxXE0WKYUerwkdzQGqNgsKdazNgf72HQmrdlftfe60qcp(K1llV(Zf2JQzHCtPCpyswQPFqywiLPccDAiXJcGSCf72Sr)e2bHKukgMdaHDf4eqOCpysPy4CLZINYTyhqQKcaPCpvAZvolEi1JgMDniaKY9uk3JQfzJ(jSdcjjbjdXxozb0xJg)UCfSeCWXFuamcBZaL7r1QHfsLD6hRY3HyWVard7qSSaqyxbobK4qSSaqhcEgf74dPa6qlmbDiC8dJcmmEiVoe0cenSdjV6pxypQwCOxoQjGAmmkXH8hIXdPa6qlmbDiVoemQjG60HKvl)qjoGujXhA0d1hIdchFOrHXCOU8dnPdnsXobDiTHo0OWFoe8mk2jWHE5vStajoK)qmEi8tTmqhAshcpaif6q1YpKxh6Rr7A0hYFOdbpJIDcCOxEf7e4qZvolowvUhvJFtk8ZbGStJIDjwyYw5Sfghsk7sSWKD0tyilxXE0WKYUerwAoae2vGtaHY9GjLI)OayeMfszpfdzQGqNgsKdazNgf72HQmrdlvAmu5EuTihaAQgJGKH4lpAyPyOY9OAXaJGAAuSlI2MnbShp1CLZIhs9OHzxdcaPCho4uUhvlYbGMQXiizi(YJgwkgox5S4PCl2bKkPaqk3HdoL7r1Ibgb10OyxeTnBcypEQ5kNfpK6rdZUgeas5Ekgox5S4PCl2bKkPaqk3t)yv(oedgZkGoexhgIg2HyzbGoe8mk2pe)rbWi8Hg9eg6q8hTBYenSdL8ezpAyhs(RgrGJvL7r143Kc)Cai70OyxIfMSJEcdz5k2JgMu2LiYsvUhvlWpr2JgMDOgrabjdXxE0WsLxgJfq8hfaJSE8P3vUhvlWpr2JgMDOgraHhCjTacAX9O6uZvolEk3IDaPskGQrDkp(elyxUhRk3JQXVjf(C1ySk3JQTMa7s06NKIDTHuaKfuU6r1sezPmvqOtdj84twVS86pxypQMfYn1CLZcWQjBLTd1iciGQr9XQY9OA8BsHpMxa(ZX6XQY9OASq5EWKSUAO2XsnbZOHzN1FkrKLQCpyswQPFqywWEQ5kNf86pxypQwavJ6uPXubHonKWJpz9YYR)CH9OAwWRYavJAHjygnm7S(tb0cOEunCWXubHonKWJpz9YYR)CH9O63Lk30pwvUhvJfk3dMK1vd1o(nPW)tovajISuMki0PHeE8jRxwE9NlShv)Uu5chCPXRYavJAXNCQacOfq9O63zQGqNgs4XNSEz51FUWEuDkg6QHAxawnzRSDOgrG0Hdoxnu7cWQjBLTd1icKAUYzby1KTY2HAebeRHumvqOtdj84twVS86pxypQMfk3JQfFYPci4vzGQrnCWLdypUfqFnA87mvqOtdj84twVS86pxypQ(yv5EunwOCpyswxnu743KcFiGcRASDci1FKiYsD1qTludjd2bkE8qX28cWyQ0MRCwWR)CH9OAbunQtXW5kNfpLBXoGujfas5E6hRhRk3JQXcE9NlShvB5vzGQrnw6q5r1hRk3JQXcE9NlShvB5vzGQrn(nPWFAQcYMxagpwvUhvJf86pxypQ2YRYavJA8BsH)Kayciz0WowvUhvJf86pxypQ2YRYavJA8BsHFoa00uf0XQY9OASGx)5c7r1wEvgOAuJFtk81MtyhOglxnMJvL7r1ybV(Zf2JQT8Qmq1Og)Mu4VWKnC6JpwvUhvJf86pxypQ2YRYavJA8BsH)ct2WPVelmzRC2cJdjLDjOCM4UT1pjfMrHc1la2oviyKerwQY9OAXNCQaIOTzta7XTa6RrJFxQCfS0XQY9OASGx)5c7r1wEvgOAuJFtk894t2rkyqIilfSAkxayKWP)qbuJDKcgsnx5SGK5rxypQwSgowpwvUhvJf86pxypQ2o8OysQjG94yld6liyFQDjIS05kNf86pxypQwavJ6Jv57qYAShF1Pd9uJoKPAyhsE1FUWEu9HgfgZHmk2pK)OTK4d51Hsw9HyWfnm2WhcEgcJJg2H86qqKtGF00HEQrhILfa6qWZOyhFi8tTmqhAshAHjiXXQY9OASGx)5c7r12HhftVjf(mvqOtdjXct2kNTW4qszxIfMSJEcdz5k2JgMu2LO1pjLKXPgIGS86pxypQ2cOVgnwIAqkMCjyQMfjDUYzbV(Zf2JQfa6RrJFBUYzbV(Zf2JQfqlG6r1JtA8Qmq1OwWR)CH9OAbG(A043NRCwWR)CH9OAbG(A040LiYs5vdTcxeDMaTASCfZvi6yv(oedgee(q(dDiOfq9O6dv5d5p0Hsw9HyWfnm2WhcEgcJJg2HKx9NlShvFiVoK)qhIAOdv5d5p0H4laGA)qYR(Zf2JQpuKpK)qhIRy)qJQLb6q86pyiNoe0cenSd5pb(qYR(Zf2JQfhRk3JQXcE9NlShvBhEum9Mu4ZubHonKelmzRC2cJdjLDjwyYo6jmKLRypAyszxIw)KusgNAicYYR)CH9OAlG(A0yjQbPkeKemvZIKYubHonKal50cTaQhvlrKLYRgAfUi6mbA1y5kMRquQ0MRCwGxTvYOHHTtdHXrdZcifIrXAao4yQGqNgsqY4udrqwE9NlShvBb0xJgZc2fS04aJdj(QmJtAZvolWR2kz0WW2PHW4OHj(QmwSRCjh)5kNf4vBLmAyy70qyC0Weyx5sME6hRk3JQXcE9NlShvBhEum9Mu4pvy2kBDqWLelrKLox5SGx)5c7r1cOAuFSQCpQgl41FUWEuTD4rX0BsHVjygnm7S(tjISuL7btYsn9dcZc2tnx5SGx)5c7r1cOAuFSkFhswj8NA5hA82zc0Q5qYtXCfIK4qmOVW(Hwy6qSSaqhcEgf74dn6H6d5peJhAu1S5h6VA(ZH4GWXhsBOdn6H6dXYcaH9c8puGpeunQfhRk3JQXcE9NlShvBhEum9Mu4NdazNgf7sSWKTYzlmoKu2LyHj7ONWqwUI9OHjLDjIS00uUhmjl10pi87svUhmjlu5IawhobhCmKxLbQg1IHNI6qgB2OFclaKcXy6PyiVAOv4IOZeOvJLRyUcrP4pkagHzHu2tnx5SGx)5c7r1I1qkgox5Sihac7f4laKY9umCUYzXt5wSdivsbGuUN6PCl2bKkPfpqgd2gTnBcyp(BZvolEi1JgMDniaKY93L9XQ8DizLWFo04TZeOvZHKNI5kejXHyzbGoe8mk2p0cthc)uld0HM0HuiOWJQvdJhIxn2bA0e0HW1H8h1pu4hkWhQl)qt6qlmbDOvBim(qJ3otGwnhsEkMRq0Hc8H0zT8d51HizgcaDOcCi)Ha0HuaDOFbOd5pAFiQRfSNdXYcaDi4zuSJpKxhIKXPg6qJ3otGwnhsEkMRq0H86q(dDiQHouLpK8Q)CH9OAXXQY9OASGx)5c7r12HhftVjf(mvqOtdjXct2kNTW4qszxIfMSJEcdz5k2JgMu2LO1pjLKzG4obzZbGStJIDSe1Gum5sWunlsQY9OAroaKDAuSl4pkagHTzGY9OA18wAmvqOtdjizCQHiilV(Zf2JQTa6RrJh)5kNfrNjqRglxXCfIeqlG6r1PpEYRYavJAroaKDAuSlGwa1JQLiYs5vdTcxeDMaTASCfZvi6yv5EunwWR)CH9OA7WJIP3KcFMki0PHKyHjBLZwyCiPSlXct2rpHHSCf7rdtk7s06NK2ebrq2Cai70OyhlrniftUemvZIKYPWKgtfe60qcsgNAicYYR)CH9OAlG(A04XZ0MRCweDMaTASCfZvisaTaQhvp(W4qIVkt6PlrKLYRgAfUi6mbA1y5kMRq0XQY9OASGx)5c7r12HhftVjf(5aq2PrXUelmzRC2cJdjLDjwyYo6jmKLRypAyszxIilnnL7btYsn9dc)UuL7btYcvUiG1HtWbhd5vzGQrTy4POoKXMn6NWcaPqmMEkE1qRWfrNjqRglxXCfIsXFuamcZcPSNknMki0PHeKmde3jiBoaKDAuSJzHuMki0PHenrqeKnhaYonk2XWbhtfe60qcsgNAicYYR)CH9OAlG(A043Lox5Si6mbA1y5kMRqKaAbupQgo4MRCweDMaTASCfZvisGDLl57Ygo4MRCweDMaTASCfZvisaOVgn(DyCiXxLbo44vzGQrTa)ezpAy2HAebeasHymLY9GjzPM(bHzHuMki0PHe86pxypQ2IFIShnm7qnIaP4ftQ12fDa7XTzLsp1CLZcE9NlShvlwdPsJHZvolYbGWEb(caPCho4MRCweDMaTASCfZvisaOVgn(D5kyP0tXW5kNfpLBXoGujfas5EQNYTyhqQKw8azmyB02SjG94Vnx5S4HupAy21Gaqk3Fx2hRk3JQXcE9NlShvBhEum9Mu4ZRv7eapqgJerwky1uUaWibuG5XGjAfWOLx)V2qPMRCwafyEmyIwbmA51)RnKaQg1PMRCwafyEmyIwbmA51)RnKvbCTjbunQtXRYavJAXCLZwOaZJbt0kGrlV(FTHeasHymfdD1qTlaRMSv2ouJiWXQY9OASGx)5c7r12HhftVjf(kGRnzjzgmfoQwIilfSAkxayKakW8yWeTcy0YR)xBOuZvolGcmpgmrRagT86)1gsavJ6uZvolGcmpgmrRagT86)1gYQaU2KaQg1P4vzGQrTyUYzluG5XGjAfWOLx)V2qcaPqmMIHUAO2fGvt2kBhQre4yv5EunwWR)CH9OA7WJIP3Kc)mOW(SmUerwky1uUaWibuG5XGjAfWOLx)V2qPMRCwafyEmyIwbmA51)RnKaQg1PMRCwafyEmyIwbmA51)RnKndkSlGQr9XQY9OASGx)5c7r12HhftVjf(zqHDBxmvjISuWQPCbGrcyGaBy0g8GBOuZvol41FUWEuTaQg1hRk3JQXcE9NlShvBhEum9Mu4ZvJXQCpQ2AcSlrRFsQY9GjzD1qTJpwvUhvJf86pxypQ2o8Oy6nPWNx)5c7r1sSWKTYzlmoKu2LyHj7ONWqwUI9OHjLDjIS05kNf86pxypQwavJ6uPXqWQPCbGrcOaZJbt0kGrlV(FTHGdU5kNfqbMhdMOvaJwE9)AdjwdWb3CLZcOaZJbt0kGrlV(FTHSzqHDXAiLRgQDby1KTY2HAebsXRYavJAXCLZwOaZJbt0kGrlV(FTHeasHym9uPXqWQPCbGrcyGaBy0g8GBi4GdIMRCwadeydJ2GhCdjwdPNknL7r1Ip5uberBZMa2JNs5EuT4tovar02SjG94wa91OXVlvUcwoCWPCpQwG5fG)iizi(YJgwkL7r1cmVa8hbjdXxozb0xJg)UCfSC4Gt5EuTihaAQgJGKH4lpAyPuUhvlYbGMQXiizi(YjlG(A043LRGLdhCk3JQfdmcQPrXUGKH4lpAyPuUhvlgyeutJIDbjdXxozb0xJg)UCfSC4Gt5EuTiB0pHDqijjizi(YJgwkL7r1ISr)e2bHKKGKH4lNSa6RrJFxUcwE6hRY3HEj(dboeVkdunQXhYFu)q4NAzGo0Ko0ctqhAu4phsE1FUWEu9HWp1YaDOQnmEOjDOfMGo0OWFoK2hs5(snhsE1FUWEu9H4k2pK2qhQl)qJc)5q6Hsw9HyWfnm2WhcEgcJJg2HgafxCSQCpQgl41FUWEuTD4rX0BsHpxngRY9OARjWUeT(jP86pxypQ2YRYavJASerw6CLZcE9NlShvlmk2TKmdbGExQY9OAbV(Zf2JQfgf72fMGowvUhvJf86pxypQ2o8Oy6nPWpB0pHDqijjrKLM2CLZINYTyhqQKcaPCpLY9GjzPM(bHzHuMki0PHe86pxypQ2Mn6NWoiKKsho4sBUYzroae2lWxaiL7PuUhmjl10pimlKYubHonKGx)5c7r12Sr)e2bHK04dwnLlamsKdaH9c8t)yv5EunwWR)CH9OA7WJIP3Kc)bgb10OyxIilDUYzbE1wjJgg2oneghnmlGuigfRHuZvolWR2kz0WW2PHW4OHzbKcXOaqFnAml4k2TE8PJvL7r1ybV(Zf2JQTdpkMEtk8hyeutJIDjIS05kNf5aqyVaFbGuUFSQCpQgl41FUWEuTD4rX0BsH)aJGAAuSlrKLox5SyGrqXnk(laKY9uZvolgyeuCJI)ca91OXSGRy36XNsL2CLZcE9NlShvla0xJgZcUIDRhFco4MRCwWR)CH9OAbunQtpLY9GjzPM(bHFNPccDAibV(Zf2JQTzJ(jSdcjPJvL7r1ybV(Zf2JQTdpkMEtk8hyeutJIDjIS05kNfpLBXoGujfas5EQ5kNf86pxypQwSgowvUhvJf86pxypQ2o8Oy6nPWFGrqnnk2LiYshaetlmoKGDbMxa(tQ5kNfpK6rdZUgeas5EkL7btYsn9dc)otfe60qcE9NlShvBZg9tyhesshRY3HyqHJg2HsEIShnSdj)vJiWHGwGOHDi5v)5c7r1hYRdbiSxa6qSSaqhcEgf7hsBOdj)9uuhYCiwMr)0H4pkagHpex7dnPdnPMYbpuJehAU8dTWl1yy8qvBy8qvFigSswlowvUhvJf86pxypQ2o8Oy6nPWh)ezpAy2HAebKiYsNRCwWR)CH9OAXAifdvUhvlYbGStJIDb)rbWiCkL7btYsn9dcZcPmvqOtdj41FUWEuTf)ezpAy2HAebsPCpQwm8uuhYyZg9tyrEzmwaXFuamY6XNyrEzmwabT4EuTer7eaSgCBKLQCpQwKdazNgf7c(JcGryPk3JQf5aq2PrXU4RYy5pkagHpwvUhvJf86pxypQ2o8Oy6nPWF4POoKXMn6NWsezPZvol41FUWEuTynKkT0uUhvlYbGStJIDb)rbWi87SNYvd1UyGrqXnk(Ns5EWKSut)GWszpD4GJHUAO2fdmckUrXF4Gt5EWKSut)GWSG90tnx5S4HupAy21Gaqk3F7PCl2bKkPfpqgd2gTnBcyp(7Y(yv5EunwWR)CH9OA7WJIP3Kc)Sr)e2bHKKerw6CLZcE9NlShvlGQrDkEvgOAul41FUWEuTaqFnA87Cf7wp(ukL7btYsn9dcZcPmvqOtdj41FUWEuTnB0pHDqijDSQCpQgl41FUWEuTD4rX0BsHFoa0ungjIS05kNf86pxypQwavJ6u8Qmq1OwWR)CH9OAbG(A0435k2TE8PumKxn0kCr2OFYQCoG8O6JvL7r1ybV(Zf2JQTdpkMEtk8X8cWFKiYsNRCwWR)CH9OAbG(A0ywWvSB94tPMRCwWR)CH9OAXAao4MRCwWR)CH9OAbunQtXRYavJAbV(Zf2JQfa6RrJFNRy36XNowvUhvJf86pxypQ2o8Oy6nPW3emJgMDw)Perw6CLZcE9NlShvla0xJg)omoK4RYKs5EWKSut)GWSG9JvL7r1ybV(Zf2JQTdpkMEtk8HakSQX2jGu)rIilDUYzbV(Zf2JQfa6RrJFhghs8vzsnx5SGx)5c7r1I1WXQY9OASGx)5c7r12HhftVjf(yEb4psezPUcGrU4HuJ)ig4(7sLf5MYvd1UatkiAywVw8NJ1JvL7r1ybOgSdpkMKMn6NWoiKKKiYsvUhmjl10pimlKYubHonK4PCl2bKkPnB0pHDqijLkT5kNfpLBXoGujfas5oCWnx5Sihac7f4laKY90pwvUhvJfGAWo8Oy6nPWFGrqnnk2LiYsNRCwGxTvYOHHTtdHXrdZcifIrXAi1CLZc8QTsgnmSDAimoAywaPqmka0xJgZcUIDRhF6yv5EunwaQb7WJIP3Kc)bgb10OyxIilDUYzroae2lWxaiL7hRk3JQXcqnyhEum9Mu4pWiOMgf7sezPZvolEk3IDaPskaKY9Jv57qmOW0HQMoella0HGNrX(Hifyy8qrFi5)s(7qr(qmwRdbvnB(HEuM0HOWFiWHKvj1Jg2HyqnCOcCiz1YpuIdivYdXi5hsBOdrH)qag4qPPPFOhLjDOFbOd5pAFiFuDi1aifIrjouAZ0p0JYKoedMHKb7afpEOSHpelBby8qasHy8qEDOfMK4qf4qPXt)qjKcIg2HETw8Ndf4dPCpysIdXGVA28dbvhYFc8Hg9eg6qpka6qCf7rd7qSmJ(jhess4dvGdn6H6dLS6dXGlAySHpe8meghnSdf4dbifIrXXQY9OASaud2HhftVjf(5aq2PrXUelmzRC2cJdjLDjwyYo6jmKLRypAyszxIilLHmvqOtdjYbGStJID7qvMOHLAUYzbE1wjJgg2oneghnmlGuigfq1OoLY9GjzPM(bHFNPccDAiXJcGSCf72Sr)e2bHKukgMdaHDf4eqOCpysPsJHZvolEi1JgMDniaKY9umCUYzXt5wSdivsbGuUNIHdaIPTYzlmoKihaYonk2tLMY9OAroaKDAuSl4pkagHzHuzdhCP5QHAxOgsgSdu84HIT5fGXu8Qmq1OwabuyvJTtaP(JaqkeJPdhCP5QHAxGjfenmRxl(tkxbWix8qQXFedC)DPYICtp90pwLVdXGcthILfa6qWZOy)qu4pe4qqlq0WoKEiwwaOPAmWx(Jrqnnk2pexX(Hg9q9HKvj1Jg2HyqnCOaFiL7bt6qf4qqlq0WoejdXxoDOrH)COesbrd7qVwl(J4yv5EunwaQb7WJIP3Kc)Cai70OyxIfMSvoBHXHKYUelmzh9egYYvShnmPSlrKLYqMki0PHe5aq2PrXUDOkt0WsXWCaiSRaNacL7btkvAPLMY9OAroa0ungbjdXxE0WsLMY9OAroa0ungbjdXxozb0xJg)UCfSeCWXqWQPCbGrICaiSxGF6WbNY9OAXaJGAAuSlizi(YJgwQ0uUhvlgyeutJIDbjdXxozb0xJg)UCfSeCWXqWQPCbGrICaiSxGF6PNAUYzXdPE0WSRbbGuUNoCWLMRgQDbMuq0WSET4pPCfaJCXdPg)rmW93LklYnvAZvolEi1JgMDniaKY9umu5EuTaZla)rqYq8Lhnm4GJHZvolEk3IDaPskaKY9umCUYzXdPE0WSRbbGuUNs5EuTaZla)rqYq8LhnSum8PCl2bKkPfpqgd2gTnBcypE6PN(XQY9OASaud2HhftVjf(C1ySk3JQTMa7s06NKQCpyswxnu74JvL7r1ybOgSdpkMEtk8hyeutJIDjIS05kNfdmckUrXFbGuUNIRy36XNEFUYzXaJGIBu8xaOVgnofxXU1Jp9(CLZcWQjBLTd1icia0xJgFSQCpQgla1GD4rX0BsH)aJGAAuSlrKLoaiMwyCib7cmVa8NuZvolEi1JgMDniaKY9uUAO2fysbrdZ61I)KYvamYfpKA8hXa3FxQSi3uk3dMKLA6he(DMki0PHepLBXoGujTzJ(jSdcjPJvL7r1ybOgSdpkMEtk8hEkQdzSzJ(jSerwkdzQGqNgsm8uuhYyhQYenSuZvolEi1JgMDniaKY9umCUYzXt5wSdivsbGuUNknL7btYcvUiG1HtVlB4Gt5EWKSut)GWSqktfe60qIhfaz5k2TzJ(jSdcjj4Gt5EWKSut)GWSqktfe60qINYTyhqQK2Sr)e2bHKu6hRk3JQXcqnyhEum9Mu4J5fG)irKL6kag5Ihsn(JyG7VlvwKBkxnu7cmPGOHz9AXFowvUhvJfGAWo8Oy6nPWhcOWQgBNas9hjISuL7btYsn9dcZczFSQCpQgla1GD4rX0BsHVc4AtwsMbtHJQLiYsvUhmjl10pimlKYubHonKqbCTjljZGPWr1P(ARIbUZcPmvqOtdjuaxBYsYmykCuT9RTESQCpQgla1GD4rX0BsHF2OFc7GqssIilv5EWKSut)GWSqktfe60qIhfaz5k2TzJ(jSdcjPJvL7r1ybOgSdpkMEtk8ZbGMQXCSESQCpQglWU2qkaYckx9OAPzJ(jSdcjjjISuL7btYsn9dcZcPmvqOtdjEk3IDaPsAZg9tyhessPsBUYzXt5wSdivsbGuUdhCZvolYbGWEb(caPCp9JvL7r1yb21gsbqwq5Qhv)Mu4pWiOMgf7sezPZvolYbGWEb(caPC)yv5EunwGDTHuaKfuU6r1Vjf(dmcQPrXUerw6CLZINYTyhqQKcaPCp1CLZINYTyhqQKca91OXVRCpQwKdanvJrqYq8Ltwp(0XQY9OASa7AdPailOC1JQFtk8hyeutJIDjIS05kNfpLBXoGujfas5EQ0gaetlmoKGDroa0ung4Glhac7kWjGq5EWKGdoL7r1Ibgb10OyxeTnBcypE6hRY3HEfW4H86qWi)qjm4G3HgafhFOOXbeDi5)s(7qdpkMWhQahsE1FUWEu9HgEumHp0OhQp0qHXX0qIJvL7r1yb21gsbqwq5Qhv)Mu4pWiOMgf7sezPZvolWR2kz0WW2PHW4OHzbKcXOynKknEvgOAulaRMSv2ouJiGaqFnA8Bk3JQfGvt2kBhQreqqYq8Ltwp(0BCf7wp(elMRCwGxTvYOHHTtdHXrdZcifIrbG(A0y4GJHUAO2fGvt2kBhQrei9umvqOtdj84twVS86pxypQ(nUIDRhFIfZvolWR2kz0WW2PHW4OHzbKcXOaqFnA8XQY9OASa7AdPailOC1JQFtk8hyeutJIDjIS05kNfpLBXoGujfas5EkxbWix8qQXFedC)DPYICt5QHAxGjfenmRxl(ZXQY9OASa7AdPailOC1JQFtk8hyeutJIDjIS05kNfdmckUrXFbGuUNIRy36XNEFUYzXaJGIBu8xaOVgn(yv(oed(fiAyhYFOdHDTHua0HaLREuTehQAdJhAHPdXYcaDi4zuSJp0OhQpK)qmEifqhQl)qtkAyhAOkdbDOCboK8Fj)DOcCi5v)5c7r1IdXGcthILfa6qWZOy)qu4pe4qqlq0WoKEiwwaOPAmWx(Jrqnnk2pexX(Hg9q9HKvj1Jg2HyqnCOaFiL7bt6qf4qqlq0WoejdXxoDOrH)COesbrd7qVwl(J4yv5EunwGDTHuaKfuU6r1Vjf(5aq2PrXUelmzRC2cJdjLDjwyYo6jmKLRypAyszxIilLH5aqyxbobek3dMukgYubHonKihaYonk2TdvzIgwQ0slnL7r1ICaOPAmcsgIV8OHLknL7r1ICaOPAmcsgIVCYcOVgn(D5kyj4GJHGvt5caJe5aqyVa)0HdoL7r1Ibgb10OyxqYq8LhnSuPPCpQwmWiOMgf7csgIVCYcOVgn(D5kyj4GJHGvt5caJe5aqyVa)0tp1CLZIhs9OHzxdcaPCpD4Glnxnu7cmPGOHz9AXFs5kag5Ihsn(JyG7VlvwKBQ0MRCw8qQhnm7AqaiL7PyOY9OAbMxa(JGKH4lpAyWbhdNRCw8uUf7asLuaiL7Py4CLZIhs9OHzxdcaPCpLY9OAbMxa(JGKH4lpAyPy4t5wSdivslEGmgSnAB2eWE80tp9JvL7r1yb21gsbqwq5Qhv)Mu4pWiOMgf7sezPdaIPfghsWUaZla)j1CLZIhs9OHzxdcaPCpLRgQDbMuq0WSET4pPCfaJCXdPg)rmW93LklYnLY9GjzPM(bHFNPccDAiXt5wSdivsB2OFc7Gqs6yv5EunwGDTHuaKfuU6r1Vjf(dpf1Hm2Sr)ewIilLHmvqOtdjgEkQdzSdvzIgwQ0yORgQDrguFR)qwf)qy4Gt5EWKSut)GWSG90tLMY9GjzHkxeW6WP3LnCWPCpyswQPFqywiLPccDAiXJcGSCf72Sr)e2bHKeCWPCpyswQPFqywiLPccDAiXt5wSdivsB2OFc7Gqsk9JvL7r1yb21gsbqwq5Qhv)Mu4ZvJXQCpQ2AcSlrRFsQY9GjzD1qTJpwvUhvJfyxBifazbLREu9BsHpeqHvn2obK6psezPk3dMKLA6heMfSFSQCpQglWU2qkaYckx9O63KcFmVa8hjISuxbWix8qQXFedC)DPYICt5QHAxGjfenmRxl(ZXQ8DizLWFoe11c2ZHCfaJCSehk8df4dPhcMg9H86qCf7hILz0pHDqijDifFOCyme4qrJDsHouLpella0ungXXQY9OASa7AdPailOC1JQFtk8vaxBYsYmykCuTerwQY9GjzPM(bHzHuMki0PHekGRnzjzgmfoQo1xBvmWDwiLPccDAiHc4AtwsMbtHJQTFT1JvL7r1yb21gsbqwq5Qhv)Mu4Nn6NWoiKKKiYsvUhmjl10pimlKYubHonK4rbqwUIDB2OFc7Gqs6yv5EunwGDTHuaKfuU6r1Vjf(5aqt1y2(23Ba]] )

end
