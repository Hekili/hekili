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


    spec:RegisterPack( "Fire", 20210126, [[devS3dqiukEekqxcsfLnbGpraJcGCkaQvbPcVcsvZcf6wIQk7sKFHcAyIQYXiOwMOsEgbkttuLQRHsP2MOsvFdLsyCIkvohkLO1HsW8qj6EII9rG8prvs1bjqLfcj6HqsnrrvIlkQuSruc9rrvsgPOkLtsGQwjkvVeLsQzcPs3uuPKDcj8trvvgkkGwQOQQEkHMkKKRIsjzRIkL6RqQiJvuf7vv9xPmyfhM0IvPhJQjd0Lr2SQ8zanAPQtt1QHur1RjiZMOBdXUv63sgUu54OaSCqphQPt56Qy7OOVlknErfNhsz9IQKY8rjTFH)c)r1xeun6JICLVCjC(eox5(u(YD5k3jSWFrdTo6l2PCHuG0xCve6lYIoK(IDkAYsb)O6lIRdKtFXEZ6WSadziq36p3eVqyi2ros18A5q9zme7iCg(fVhxAc(9F)IGQrFuKR8LlHZNW5k3NYxUlx5U8Xw(f1J1xWVOOJG6VyVdcs7)(fbjm)lYGmymSOdPyYTuGuWodYGX0BwhMfyidb6w)5M4fcdXoYrQMxlhQpJHyhHZWGDgKbJHDDpkeTyYvUNXyYv(YLWb7b7midgdQ71fiHzHGDgKbJj)IHTctX8CG9wdsiQV4yGQ1tWySEDJXuiqYsMJqnRAGofZRGXivSLFyIxlym61LUHwmhScKWPGDgKbJj)IbDRctBmCfBXajgWXHecTgoMxbJb1fY9GnV2yaKNOeJXawRawm9Lemg3I5vWy0yEqc3htUfzubJHRydWPGDgKbJj)Ij3S6vsXGnOZTy49exiFbgtTXOX8OSX8kOq4y8ngRNIrWXar3ySkgibE4umzlOqYsbtFrPJn8hvFXoiXlKRAFu9rHWFu9fvU51(fvixxQ5RrsjXTViT6vsGFu(TpkY1hvFrA1RKa)O8lwDFrmzFrLBETFrMk01RK(ImvyBve6l2xwdBqsfQ9KkcHnOle9f5q3iORFrMk01RKs9L1WgKuHApPIqyd6crXKjM89fbjmh6DMx7xev9oogMk01RKIb3rC)5eogRNIzpixcgt9IXuiqYWXOwmz7DEFm5TYIr0GKkumSOuriSbDHiCm1XWoift9Ib1fY9GnV2yW91rcgZLI5GjW0xKPkp0xmxXGoIXujTw6jveQ1PgVprRELeymOpgblg0rmSjgtL0APNurOwNA8(eT6vsGF7Jcb7JQViT6vsGFu(fRUViMSVOYnV2Vitf66vsFrMkSTkc9f7viyJRyR9KkcHnOle9f5q3iORFrMk01RKs9keSXvS1EsfHWg0fIIjtm57lcsyo07mV2ViQ6DCmmvORxjfdUJ4(ZjCmwpfZEqUemM6fJPqGKHJrTyY278(yYBkemguRylgwuQie2GUqeoM6yyhKIPEXG6c5EWMxBm4(6ibJ5sXCWeymkoMNlLem9fzQYd9fZvmOJymvsRLEsfHADQX7t0Qxjbgd6JrWIbDedBIXujTw6jveQ1PgVprRELe43(OiV)r1xKw9kjWpk)Iv3xet2xu5Mx7xKPcD9kPVitf2wfH(I8c5EWMxB7jvecBqxi6lYHUrqx)ImvORxjL4fY9GnV22tQie2GUqumzIjFFrqcZHEN51(frvVJJHPcD9kPyWDe3FoHJX6Py2dYLGXuVymfcKmCmQft2EN3htERSyeniPcfdlkvecBqxichJcPyoycmgWd0xGXG6c5EWMxB6lYuLh6lkyXGoIXujTw6jveQ1PgVprRELeymOpMCFmOJyytmMkP1spPIqTo149jA1RKa)2hfS9hvFrA1RKa)O8lwDFrmzFrLBETFrMk01RK(ImvyBve6lQqUUuJYPtwyV2Vih6gbD9lYuHUELusHCDPgLtNSWETXKjM89fbjmh6DMx7xev9oogMk01RKIb3rC)5eogRNIzpixcgt9IXuiqYWXOwmz7DEFmcoixxkMCtoDYc71gtDmSdsXuVyqDHCpyZRngCFDKGXCPyoycm9fzQYd9fzlzlJbDeJPsAT0tQiuRtnEFIw9kjWyqFm5kg0rmSjgtL0APNurOwNA8(eT6vsGF7JIC)hvFrA1RKa)O8lwDFriHj7lQCZR9lYuHUEL0xKPcBRIqFrfY1LAuoDYc712q0v)IG0tps7lM3Z3xeKWCO3zETFru174yyQqxVskgChX9Nt4ySEkMocYP1uGum1lgeD1yUKSYgt2EN3hJGdY1LIj3KtNSWETXK1LYy2YI5sXCWey6BFuWw8r1xKw9kjWpk)Iv3xesyY(Ik38A)ImvORxj9fzQW2Qi0xuiFbL(cSbjWd38A)IG0tps7lMVuE)lcsyo07mV2Vi6KB9XWw7lO0xGmgdQlK7bBETcGJHxLeSYUXK1LYyUumqc8WjWyUOfJgduxWcjgfPoRXym3JfJ1tXShKlbJPEXWHUHJbBk0WXWKGOftVdSpg9zemgLBot18fymOUqUhS51gJUGXGLvwCmGv2ngRYQqqCmwpfdTGXuVyqDHCpyZRvaCm8QKGv2nfd6upTXGOc5lWyajUJ9AXX4BmwpfJGJbIUmgdQlK7bBETcGJbsiQV(cmgEvsWk7gJJJbsGhobgZfTySEhhZdQCZRngRIr586SwmVcgdBTVGsFbM(2hf5UpQ(I0Qxjb(r5xS6(IyY(Ik38A)ImvORxj9fzQYd9fz7ViiH5qVZ8A)IOQNIb8avZRnM6fJgJ4zJHT2xGcGJbLscJ9fymOUqUhS51M(ImvyBve6lIf62apq18A)2hfSLFu9fPvVsc8JYVy19fXK9fvU51(fzQqxVs6lYuLh6lsmGJ31rGjGsf0vRG42vbbsXWkRXqmGJ31rGjeLRxi1W9eznKd25XWkRXqmGJ31rGjFXC4X0RKAmGJU2bPbsmDofdRSgdXaoExhbMWN9kRcSPiK1Jg2IHvwJHyahVRJateshAqsLTccU6YPyyL1yigWX76iW0tQiuRETRAMKIHvwJHyahVRJatzvHOLG42dwlymSYAmed44DDeyYxSbpCRG4gOZ0xQDjP8lYuHTvrOViVqUhS512QTDW03(Oq489r1xKw9kjWpk)Iv3xesyY(Ik38A)ImvORxj9fzQW2Qi0xKq6qdsQSvqWvxo1ajPI2xeKE6rAFrHZDFrqcZHEN51(fZBv2yK1cmMl9kifdQlK7bBETXG7RJemMCdshAqsLXK)GGRUCkMlfZbtG51)2hfcl8hvFrA1RKa)O8lwDFrmzFrLBETFrMk01RK(ImvyBve6lwB7GPg)y179f5q3iORFrMk01RKs8c5EWMxBR22btFrqcZHEN51(fZBv2yK1cmMl9kifdQlK7bBETXG7RJemgd6RqKHJX6vlgd6absWy0yW9kKaJHRgbSGOfdVkjyLDJP2ykRNGXyqFfImCmBzXCPyoycmV(xKPkp0xmx57BFuiCU(O6lsRELe4hLFXQ7lIj7lQCZR9lYuHUEL0xKPkp0xmxS9xKdDJGU(fjgWX76iWeIY1lKA4EISgYb78Vitf2wfH(I12oyQXpw9EF7JcHfSpQ(I0Qxjb(r5xS6(IyY(Ik38A)ImvORxj9fzQYd9fZv(Ib9XWuHUELuIq6qdsQSvqWvxo1ajPI2xKdDJGU(fjgWX76iWeH0HgKuzRGGRUC6lYuHTvrOVyTTdMA8JvV33(Oq48(hvFrA1RKa)O8lwDFriHj7lQCZR9lYuHUEL0xKPcBRIqFrEHCpyZRTH79N5lWwxLLGFrq6PhP9fZ1xeKWCO3zETFru1tXShKlbJPEXykeiz4ye79N5lWyyGvwcgdUVosWyUumhmbgtTXaEG(cmguxi3d28AtF7JcHz7pQ(I0Qxjb(r5xS6(Iqct2xu5Mx7xKPcD9kPVitf2wfH(I8c5EWMxBJRyRbje1x8xeKE6rAFX8Lyl(IGeMd9oZR9lIQEkgZrOyGeI6RVaJP2y0y4k2IjBpTXG6c5EWMxBmCDJ5sXCWeym(gdM41cItF7JcHZ9Fu9fPvVsc8JYV4Qi0xexhzZbUUrWVOYnV2ViUoYMdCDJGF7JcHzl(O6lQCZR9lI4qybBoIcK(I0Qxjb(r53(Oq4C3hvFrA1RKa)O8lYHUrqx)ISjMoiXm1HgSUsfBFrLBETFXo0G1vQy7BF7lcsp9iTpQ(Oq4pQ(I0Qxjb(r5xKdDJGU(fztmWZsVccKsGoM7DsFviAnEHGOlyIw9kjWVOYnV2ViVoRrqChjLF7JIC9r1xKw9kjWpk)Iv3xet2xu5Mx7xKPcD9kPVitvEOVOPsAT0ZHe2uOrWeT6vsGXGoI55qcBk0iycsiQV4yqFmakgEvsWk7M4fY9GnV2eKquFXXGoIbqXiCm5xmmvORxjLeYxqPVaBqc8WnV2yqhXyQKwljKVGsFbMOvVscmgahdGJbDedBIHxLeSYUjEHCpyZRnbjfeTyqhXCpVxIxi3d28AtGv29lcsyo07mV2VyUTcD9kPySE1IHxRbljoMS90gdQlK7bBETX44yoycmfdQ6DCmsFPyWKHJb1fY9GnV2ySkMlfZbtGXOpJGXWIoKWMcncgJUGXODDsNWXy9umc5lO0xGnibE4MxBmmvORxjfJvXy9umqcr91xGXWRscwz3yQxmOUqUhS51MIrWbc6MxRkLOXym(lguxi3d28AJXXXa6y9kjWySEhhd68d2IbtgogRNIHPcD9kPySkgngZrOy6uSfJ1tXqlym1lgRNIb7ihPAETPVitf2wfH(IMJqnRA8c5EWMx73(OqW(O6lsRELe4hLFXQ7lIO58fvU51(fzQqxVs6lYuHTvrOVO5iuZQgVqUhS51(f5q3iORFrIbC8UocmriDObjv2ki4QlN(IGeMd9oZR9lMBPcrXGpqkguxi3d28AJXXXassfncmg)fZseibgZvXeym1gJ1tXqiDObjv2ki4QlNAGKurlgMk01RKsFrMQ8qFrMk01RKseshAqsLTccU6YPgijv0Ij)IbqXWRscwz3eH0HgKuzRGGRUCkbEGQ51gt(fdVkjyLDteshAqsLTccU6YPeKquFXXa4yqhXWMy4vjbRSBIq6qdsQSvqWvxoLGKcI23(OiV)r1xKw9kjWpk)Iv3xerZ5lQCZR9lYuHUEL0xKPcBRIqFrZrOMvnEHCpyZR9lYHUrqx)Ied44DDeycOubD1kiUDvqG0xeKWCO3zETFX8cjv0Ib1fY9GnV2yEfmM8kPc6QvqbWXGsfeiL(Imv5H(I8QKGv2nbuQGUAfe3Ukiqkbje1x83(OGT)O6lsRELe4hLFXQ7lIO58fvU51(fzQqxVs6lYuHTvrOVO5iuZQgVqUhS51(f5q3iORFrtL0Aj4zPw9ADvwcMOvVscmgaI5EEVeVqUhS51MaRS7xeKWCO3zETFX8cjv0Ib1fY9GnV2yoR5YyY)fdmgkNohs4y8xmUjaoMtx6lYuLh6lEpVxcEwQvVwxLLGjiHO(I)2hf5(pQ(I0Qxjb(r5xS6(IiAoFrLBETFrMk01RK(ImvyBve6lAoc1SQXlK7bBETFro0nc66x0ujTwcEwQvVwxLLGjA1RKaJbGyUN3lXlK7bBETjWk7gdaXWRscwz3e8SuRETUklbtqcr9fhd6JHTJHLXWuHUELuYCeQzvJxi3d28A)IGeMd9oZR9lMxiPIwmOUqUhS51gZRGXOBmuoguJj)FwkM6fddSYsWy8xmwpft()Sum1lggyLLGXKTosWy4fcft9EXWRscwz3yulgjPylg2ogmXRfehZLEfKIb1fY9GnV2yYwhjy6lYuLh6lYRscwz3e8SuRETUklbtqcr9fhd6J5EEVe8SuRETUklbtGhOAETF7Jc2IpQ(I0Qxjb(r5xS6(IiAoFrLBETFrMk01RK(ImvyBve6lAoc1SQXlK7bBETFro0nc66xeEw6vqGuc0XCVt6RcrRXleeDbt0QxjbgdaXCpVxc0XCVt6RcrRXleeDbtGv29lcsyo07mV2VyEHKkAXG6c5EWMxBm(lM8IJ5EN0xfIwmOUqq0fmMS1rcgZwwmxkgiPGOfZRGX4wmOrw6lYuLh6lYRscwz3098EnqhZ9oPVkeTgVqq0fmbje1x83(Oi39r1xKw9kjWpk)Iv3xet2xu5Mx7xKPcD9kPVitvEOViGIr5MZKA0sioHJHLXWuHUELuIxi3d28AB4E)z(cS1vzjymSYAmk3CMuJwcXjCmSmgMk01RKs8c5EWMxB7jvecBqxikgwzngMk01RKsMJqnRA8c5EWMxBm5xmk38At4E)z(cS1vzjy6DKYgKapCZRngbfdVkjyLDt4E)z(cS1vzjyc8avZRngahdaXWuHUELuYCeQzvJxi3d28AJj)IHxLeSYUjCV)mFb26QSembje1xCmckgLBETjCV)mFb26QSem9oszdsGhU51gdaXaOy4vjbRSBcEwQvVwxLLGjiHO(IJj)IHxLeSYUjCV)mFb26QSembje1xCmckg2ogwzng2eJPsATe8SuRETUklbt0QxjbgdG)IGeMd9oZR9lMBRqxVskgRxTyiS5iQr4yY2twpbJrS3FMVaJHbwzjymzDPmMlfZbtGXCPxbPyqDHCpyZRnghhdKuq0sFrMkSTkc9fX9(Z8fyRRYsW2LEfKA8c5EWMx73(OGT8JQViT6vsGFu(f5q3iORFX759s8c5EWMxBcSYUXaqmSjgafZ98EjFFeCvzJRyUcsPtxmaeZ98EP(YAydsQqjiPClgahdaXWuHUELuc37pZxGTUklbBx6vqQXlK7bBETFrLBETFrCV)mFb26QSe8BFuiC((O6lsRELe4hLFro0nc66xeqXCpVxIxi3d28AtGv2ngaI5EEVe8SuRETUklbtGv2ngaIbqXWuHUELuYCeQzvJxi3d28AJHLXq5q8JrnZrOyyL1yyQqxVskzoc1SQXlK7bBETXiOy4vjbRSBcQGUUwd3PqHsGhOAETXa4yaCmSYAmakM759sWZsT616QSemD6IbGyyQqxVskzoc1SQXlK7bBETXiOyeS8fdG)Ik38A)Iqf011A4ofk03(OqyH)O6lsRELe4hLFro0nc66x8EEVeVqUhS51MaRSBmaeZ98Ej4zPw9ADvwcMaRSBmaedtf66vsjZrOMvnEHCpyZRngwgdLdXpg1mhH(Ik38A)IGKA93cU03(Oq4C9r1xKw9kjWpk)ICOBe01Vitf66vsjZrOMvnEHCpyZRngwMjgblgaI5EEVeVqUhS51MaRS7xu5Mx7xeXHWcIB1RzfeHw7BFuiSG9r1xKw9kjWpk)Ihm1Y27sQXvS5lWpke(lcsyo07mV2VilwWyYTP16rdYymhmfJgdl6qkgukvSfdVxHaPyapqFbgtULdHfeht9IbvfeHwlgUITySkgLz5GXW1UoFbgdVxHajC6lQCZR9l(Ci1UsfBFro0nc66xu5MxBcXHWcIB1RzfeHwlr5q8J5lWyaiM3rkBqI3RqGuZCekM8lgLBETjehcliUvVMvqeATeLdXpg1GeI6logwgtEpgaIHnX0xwdBqsfQH7iPe38T9KoWElgaIHnXCpVxQVSg2GKkucsk3(2hfcN3)O6lsRELe4hLFrLBETFrGsf0vRG42vbbsFro0nc66xKPcD9kPK5iuZQgVqUhS51gJGIr5MxBJxLeSYUXKFXW2Fr69iU1wfH(IaLkORwbXTRccK(2hfcZ2Fu9fPvVsc8JYVOYnV2ViH0HgKuzRGGRUC6lYHUrqx)ImvORxjLmhHAw14fY9GnV2yyzMyyQqxVskriDObjv2ki4QlNAGKur7lUkc9fjKo0GKkBfeC1LtF7JcHZ9Fu9fPvVsc8JYVOYnV2ViqjAD9T61um2rCPAETFro0nc66xKPcD9kPK5iuZQgVqUhS51gJGYedtf66vsPABhm14hREVV4Qi0xeOeTU(w9Akg7iUunV2V9rHWSfFu9fPvVsc8JYVOYnV2ViIY1lKA4EISgYb78Vih6gbD9lYuHUELuYCeQzvJxi3d28AJHLzIHT)IRIqFreLRxi1W9eznKd25F7JcHZDFu9fPvVsc8JYViiH5qVZ8A)Ic(xmhSVaJrJbBeSCWyQn)oykg3iegJrLzv0WXCWum5fiPGphsXKBtymjJPog2bPyQxmOUqUhS51MIj)z9emRJjgJPd6f0npVgfZb7lWyYlqsbFoKIj3MWysgtw36Jb1fY9GnV2yQvIwm(lgb)(i4QYyqTI5kifJJJHw9kjWy0fmgnMdwbsXKTwbSyUumYcBXumjymwpfd4bQMxBm1lgRNI55a7T0xCve6lccjf85qQXKWys(f5q3iORFrMk01RKsMJqnRA8c5EWMxBmcktmmvORxjLQTDWuJFS69IbGyaum3Z7L89rWvLnUI5kiLWMYfkMmXCpVxY3hbxv24kMRGucrZPHnLlumSYAmSjgETGh3s((i4QYgxXCfKs0QxjbgdRSgdtf66vsjEHCpyZRTvB7GPyyL1yyQqxVskzoc1SQXlK7bBETXG(yy7yeumphyV1GeI6log0zXOCZRTXRscwz3ya8xu5Mx7xeesk4ZHuJjHXK8BFuimB5hvFrA1RKa)O8lcsyo07mV2VOyDKXi4bUUrWyW91rcgZLI5GjWy8ngnMSkAXy9Qfdyr4valgFnc(iiftw36JPSEcgtT53btXyqFfImCkM8N1tWymOVcrgogWkMTSymOdeibJrJb3RqcmgbpQZlXuBmUXym4kg3IHRBmxkMdMaJb6a7Ty0NrWy0fTykRNGXuB(DWumg0xHil9fxfH(I46iBoW1nc(f5q3iORFrMk01RKsMJqnRA8c5EWMxBmcktmcw(IbDedGIHPcD9kPuTTdMA8JvVxmckM8fdGJbGyaumSjgIbC8Uocmbcjf85qQXKWysgdRSgdVkjyLDtGqsbFoKAmjmMKjiHO(IJrqXW2Xa4VOYnV2ViUoYMdCDJGF7JICLVpQ(I0Qxjb(r5xu5Mx7xKRlNKT759(ICOBe01ViBIHxl4XTKVpcUQSXvmxbPeT6vsGXaqmMJqXWYyy7yyL1yUN3l57JGRkBCfZvqkHnLlumzI5EEVKVpcUQSXvmxbPeIMtdBkxOV498ETvrOViUoYMdCDZR9lcsyo07mV2ViQGoqGemgX6iJrWdCDJGXqkuIwmzDRpgb)(i4QYyqTI5kiftbJjBpTX4wmzvCmDqIRyl9TpkYLWFu9fPvVsc8JYVOYnV2V4btn3ie8xeKWCO3zETFrbVri4ySE1IbSIzllMlT0ZTyqDHCpyZRngCFDKGXGo)GTyUumhmbgtDmSdsXuVyqDHCpyZRng1IbxiumDLVw6lYHUrqx)ImvORxjLmhHAw14fY9GnV2yeuMyyQqxVskvB7GPg)y179TpkYvU(O6lsRELe4hLFrLBETFrEDwJG4osk)IGeMd9oZR9lMxrwmwpftEXXCVt6Rcrlguxii6cgZ98EXC6ymMZkjmogEHCpyZRnghhdUQn9f5q3iORFr4zPxbbsjqhZ9oPVkeTgVqq0fmrRELeymaedVkjyLDt3Z71aDm37K(Qq0A8cbrxWeKuq0IbGyUN3lb6yU3j9vHO14fcIUGnfY1LsGv2ngaIHnXCpVxc0XCVt6RcrRXleeDbtNUyaigMk01RKsMJqnRA8c5EWMxBmckMCX2F7JICjyFu9fPvVsc8JYVih6gbD9lcpl9kiqkb6yU3j9vHO14fcIUGjA1RKaJbGy4vjbRSB6EEVgOJ5EN0xfIwJxii6cMGKcIwmaeZ98EjqhZ9oPVkeTgVqq0fSPqUUucSYUXaqmSjM759sGoM7DsFviAnEHGOly60fdaXWuHUELuYCeQzvJxi3d28AJrqXKl2(lQCZR9lQqUUuJYPtwyV2V9rrUY7Fu9fPvVsc8JYVih6gbD9lcpl9kiqkb6yU3j9vHO14fcIUGjA1RKaJbGy4vjbRSB6EEVgOJ5EN0xfIwJxii6cMGKcIwmaeZ98EjqhZ9oPVkeTgVqq0fS9Gf2sGv2ngaIHnXCpVxc0XCVt6RcrRXleeDbtNUyaigMk01RKsMJqnRA8c5EWMxBmckMCX2FrLBETFXhSW2TK23(OixS9hvFrA1RKa)O8lYHUrqx)ImvORxjLmhHAw14fY9GnV2yyzMyY3xu5Mx7xKRszt5MxBt6y7lkDS1wfH(I8c5EWMxBRRxX03(Oix5(pQ(I0Qxjb(r5xKdDJGU(fVN3lbpl1QxRRYsWeyLDJbGyytm3Z7LEoKWwbrsqs5wmaedGIHPcD9kPK5iuZQgVqUhS51gJGYeZ98Ej4zPw9ADvwcMapq18AJbGyyQqxVskzoc1SQXlK7bBETXiOyuU51MEoKAxPIT07iLniX7viqQzocfdRSgdtf66vsjZrOMvnEHCpyZRngbfZZb2BniHO(IJbWFrLBETFr4zPw9ADvwc(TpkYfBXhvFrA1RKa)O8lwDFrmzFrLBETFrMk01RK(Ihm1Q3RbKd(rHWFrMkSTkc9fFoKAxPITwxvsFb(fbjmh6DMx7xm3wHUELumwVAXWR1GLehdl6qkgukvSfZbRaPySkgAXhifJB4y49keiHJPRkjbgZRGXG6c5EWMxB6lEWulBVlPgxXMVa)Oq4VitvEOVitf66vsjZrOMvnEHCpyZRnM8lgblgwgJYnV20ZHu7kvSLEhPSbjEVcbsnZrOyYVyuU51MW9(Z8fyRRYsW07iLnibE4MxBmOJyyQqxVskH79N5lWwxLLGTl9ki14fY9GnV2yaigMk01RKsMJqnRA8c5EWMxBmSmMNdS3Aqcr9f)TpkYvU7JQViT6vsGFu(fRUViMSVOYnV2Vitf66vsFrMQ8qFrMk01RKsMJqnRA8c5EWMxBmSmgLBETPU(IwpN2tQieo9oszds8EfcKAMJqXKFXOCZRnH79N5lWwxLLGP3rkBqc8WnV2yqhXWuHUELuc37pZxGTUklbBx6vqQXlK7bBETXaqmmvORxjLmhHAw14fY9GnV2yyzmphyV1GeI6logwzng4zPxbbsj8zBc5lqC7kjm2xGjA1RKaJHvwJXCekgwgdB)fbjmh6DMx7xm3wHUELumwVAXWR1GLehddSVO1ZjgwuQieoMdwbsXyvm0Ipqkg3WXW7viqchJcPy6QssGX8kymOUqUhS51M(ImvyBve6l21x06506Qs6lWV9rrUyl)O6lsRELe4hLFro0nc66x8EEVe8SuRETUklbtNUyaigMk01RKsMJqnRA8c5EWMxBmckM89fvU51(f5Qu2uU512Ko2(IshBTvrOViS6AD9kM(2hfcw((O6lsRELe4hLFXdMAz7Dj14k28f4hfc)fbjmh6DMx7xuWbIo)GTySEkgMk01RKIX6vlgETgSK4yyrhsXGsPITyoyfifJvXql(aPyCdhdVxHajCmkKIrL4kMUQKeymVcgt()Sum1lggyLLGPVy19fXK9f5q3iORFr2edtf66vsPNdP2vQyR1vL0xGXaqmMkP1sWZsT616QSemrRELeymaeZ98Ej4zPw9ADvwcMaRS7xKPkp0xKxLeSYUj4zPw9ADvwcMGeI6logwgJYnV20ZHu7kvSLEhPSbjEVcbsnZrOyYVyuU51MW9(Z8fyRRYsW07iLnibE4MxBmOJyaummvORxjLW9(Z8fyRRYsW2LEfKA8c5EWMxBmaedVkjyLDt4E)z(cS1vzjycsiQV4yyzm8QKGv2nbpl1QxRRYsWeKquFXXa4yaigEvsWk7MGNLA1R1vzjycsiQV4yyzmphyV1GeI6l(lEWuREVgqo4hfc)fvU51(fzQqxVs6lYuHTvrOV4ZHu7kvS16Qs6lWV9rHGj8hvFrA1RKa)O8lEWulBVlPgxXMVa)Oq4Vih6gbD9lYMyyQqxVsk9Ci1UsfBTUQK(cmgaIHPcD9kPK5iuZQgVqUhS51gJGIjFXaqmk3CMuJwcXjCmcktmmvORxjL6viyJRyR9KkcHnOlefdaXWMyEoKWMcncMuU5mPyaig2eZ98EP(YAydsQqjiPClgaIbqXCpVxQNuZxGTtxcsk3IbGyuU51MEsfHWg0fIsuoe)yudsiQV4yyzm5lX2XWkRXW7viqc3EqLBETQmgbLjMCfdG)Ihm1Q3RbKd(rHWFrLBETFXNdP2vQy7lcsyo07mV2Vi6upTXK3uiixXMVaJHfLkcfJObDHigJHfDifdkLk2WXG7RJemMlfZbtGXyvmaPLGQrXK3klgrdsQq4y0fmgRIHYXOfmgukvSrWyYTuSrW03(OqWY1hvFrA1RKa)O8lEWulBVlPgxXMVa)Oq4Vih6gbD9l(CiHnfAemPCZzsXaqm8EfcKWXiOmXiCmaedBIHPcD9kP0ZHu7kvS16Qs6lWyaigafdBIr5MxB65q6QszIYH4hZxGXaqmSjgLBETPo0G1vQyl5B7jDG9wmaeZ98EPEsnFb2oDjiPClgwzngLBETPNdPRkLjkhIFmFbgdaXWMyUN3l1xwdBqsfkbjLBXWkRXOCZRn1HgSUsfBjFBpPdS3IbGyUN3l1tQ5lW2PlbjLBXaqmSjM759s9L1WgKuHsqs5wma(lEWuREVgqo4hfc)fvU51(fFoKAxPITViiH5qVZ8A)I5Ld0xGXWIoKWMcncYymSOdPyqPuXgogfsXCWeymyhXLkuIwmwfd4b6lWyqDHCpyZRnftEfTeuLs0ymgRNqlgfsXCWeymwfdqAjOAum5TYIr0GKkeoMS90gdh6goMSUugZwwmxkMSk2iWy0fmMSU1hdkLk2iym5wk2iiJXy9eAXG7RJemMlfdUdskym1XIXQyquFn13ySEkgukvSrWyYTuSrWyUN3l9Tpkemb7JQViT6vsGFu(fpyQLT3LuJRyZxGFui8xeKWCO3zETFrbhZYbJHRDD(cmgw0HumOuQylgEVcbs4yY27skgEVUlj9fymI9(Z8fymmWklb)Ik38A)IphsTRuX2xKdDJGU(fvU51MW9(Z8fyRRYsWeLdXpMVaJbGyEhPSbjEVcbsnZrOyyzmk38At4E)z(cS1vzjyYCUqnibE4MxBmaeZ98EP(YAydsQqjWk7gdaXyocfJGIr489TpkeS8(hvFrA1RKa)O8lYHUrqx)ImvORxjLmhHAw14fY9GnV2yeum5lgaI5EEVe8SuRETUklbtGv29lQCZR9lYvPSPCZRTjDS9fLo2ARIqFrSPlOcbBWYuZR9BFuiyS9hvFrLBETFrmVG8(ViT6vsGFu(TV9fHvxRRxX0hvFui8hvFrA1RKa)O8lYHUrqx)Ik3CMuJwcXjCmcktmmvORxjL6lRHniPc1EsfHWg0fIIbGyaum3Z7L6lRHniPcLGKYTyyL1yUN3l9CiHTcIKGKYTya8xu5Mx7x8jvecBqxi6BFuKRpQ(I0Qxjb(r5xKdDJGU(fVN3lHpBtiFbIBxjHX(cSbjfeT0PlgaI5EEVe(SnH8fiUDLeg7lWgKuq0sqcr9fhJGIHRyRzoc9fvU51(f7qdwxPITV9rHG9r1xKw9kjWpk)ICOBe01V498EPNdjSvqKeKuU9fvU51(f7qdwxPITV9rrE)JQViT6vsGFu(f5q3iORFX759s9L1WgKuHsqs52xu5Mx7xSdnyDLk2(2hfS9hvFrA1RKa)O8lEWulBVlPgxXMVa)Oq4Vih6gbD9lYMyyQqxVsk9Ci1UsfBTUQK(cmgaI5EEVe(SnH8fiUDLeg7lWgKuq0sGv2ngaIr5MZKA0sioHJHLXWuHUELuQxHGnUIT2tQie2GUqumaedBI55qcBk0iys5MZKIbGyaumSjM759s9KA(cSD6sqs5wmaedBI5EEVuFznSbjvOeKuUfdaXWMy6GeZw9EnGCW0ZHu7kvSfdaXaOyuU51MEoKAxPITeVxHajCmcktm5kgwzngafJPsATKkPCWguX51uC7DGOLOvVscmgaIHxLeSYUjqOcSwC7cj16tqsbrlgahdRSgdGIXujTwctk0xGnRo8(eT6vsGXaqmMcbswQNuP1N64wmSmtmcw(IbWXa4ya8x8GPw9EnGCWpke(lQCZR9l(Ci1UsfBFrqcZHEN51(fzRWum1sXWIoKIbLsfBXqkuIwm(gt(VyGX4VyqRoXawRawm9ktkgYTEcgtEJuZxGXWw1ftbJjVvwmIgKuHIbnYIrxWyi36jiledGuahtVYKIbPGumwVUXyzRyujKuq0ymgaDbCm9ktkgbNKYbBqfNxtfahdlEGOfdKuq0IXQyoyIXykymaId4yejf6lWyqvD49X44yuU5mPum5LAfWIbSIX6DCmz7DjftVcbJHRyZxGXWIsfHWg0fIWXuWyY2tBmINng2AFbkaogukjm2xGX44yGKcIw6BFuK7)O6lsRELe4hLFXdMAz7Dj14k28f4hfc)f5q3iORFr2edtf66vsPNdP2vQyR1vL0xGXaqmSjMNdjSPqJGjLBotkgaIbqXaOyaumk38Atphsxvktuoe)y(cmgaIbqXOCZRn9CiDvPmr5q8JrniHO(IJHLXKVeBhdRSgdBIbEw6vqGu65qcBfejrRELeymaogwzngLBETPo0G1vQylr5q8J5lWyaigafJYnV2uhAW6kvSLOCi(XOgKquFXXWYyYxITJHvwJHnXapl9kiqk9CiHTcIKOvVscmgahdGJbGyUN3l1tQ5lW2PlbjLBXa4yyL1yaumMkP1sysH(cSz1H3NOvVscmgaIXuiqYs9KkT(uh3IHLzIrWYxmaedGI5EEVupPMVaBNUeKuUfdaXWMyuU51MW8cY7tuoe)y(cmgwzng2eZ98EP(YAydsQqjiPClgaIHnXCpVxQNuZxGTtxcsk3IbGyuU51MW8cY7tuoe)y(cmgaIHnX0xwdBqsfQH7iPe38T9KoWElgahdGJbWFXdMA171aYb)Oq4VOYnV2V4ZHu7kvS9fbjmh6DMx7xKTctXWIoKIbLsfBXqU1tWyapqFbgJgdl6q6QsjdzGObRRuXwmCfBXKTN2yYBKA(cmg2QUyCCmk3CMumfmgWd0xGXq5q8JrXK1T(yejf6lWyqvD49PV9rbBXhvFrA1RKa)O8lQCZR9lYvPSPCZRTjDS9fLo2ARIqFrLBotQzQKwd)TpkYDFu9fPvVsc8JYVih6gbD9lEpVxQdnyXLkgjbjLBXaqmCfBnZrOyyzm3Z7L6qdwCPIrsqcr9fhdaXWvS1mhHIHLXCpVxcEwQvVwxLLGjiHO(I)Ik38A)IDObRRuX23(OGT8JQViT6vsGFu(f5q3iORFXoiXSbKdMeoH5fK3hdaXCpVxQNuZxGTtxcsk3IbGymvsRLWKc9fyZQdVprRELeymaeJPqGKL6jvA9PoUfdlZeJGLVyaigLBotQrlH4eogwgdtf66vsP(YAydsQqTNuriSbDHOVOYnV2VyhAW6kvS9TpkeoFFu9fPvVsc8JYVih6gbD9lYMyyQqxVsk11x06506Qs6lWyaiM759s9KA(cSD6sqs5wmaedBI5EEVuFznSbjvOeKuUfdaXaOyuU5mPgyzjh46gfdlJjxXWkRXOCZzsnAjeNWXiOmXWuHUELuQxHGnUIT2tQie2GUqumSYAmk3CMuJwcXjCmcktmmvORxjL6lRHniPc1EsfHWg0fIIbWFrLBETFXU(IwpN2tQie(BFuiSWFu9fPvVsc8JYVih6gbD9lAkeizPEsLwFQJBXWYmXiy5lgaIXujTwctk0xGnRo8(eT6vsGFrLBETFrmVG8(V9rHW56JQViT6vsGFu(f5q3iORFrLBotQrlH4eogbftU(Ik38A)IGqfyT42fsQ1)TpkewW(O6lsRELe4hLFro0nc66xu5MZKA0sioHJrqzIHPcD9kPKc56snkNozH9AJbGyq0vtDClgbLjgMk01RKskKRl1OC6Kf2RTHOR(fvU51(fvixxQr50jlSx73(Oq48(hvFrA1RKa)O8lQCZR9l(KkcHnOle9fbjmh6DMx7xeDYT(yOToa7JXuiqYWmgJBX44y0yaQ(gJvXWvSfdlkvecBqxikgfhZZLscgJVyJuWyQxmSOdPRkLPVih6gbD9lQCZzsnAjeNWXiOmXWuHUELuQxHGnUIT2tQie2GUq03(Oqy2(JQVOYnV2V4ZH0vLYViT6vsGFu(TV9f5fY9GnV2wxVIPpQ(Oq4pQ(I0Qxjb(r5xKdDJGU(fVN3lXlK7bBETjWk7(fvU51(fLoWEd3qNFabIqR9TpkY1hvFrA1RKa)O8lEWulBVlPgxXMVa)Oq4ViiH5qVZ8A)I5gS5iQrX0xzJrwlWyqDHCpyZRnMSUugJuXwmwVUcHJXQyepBmS1(cuaCmOusySVaJXQyajJGi(sX0xzJHfDifdkLk2WXG7RJemMlfZbtGPVy19fXK9f5q3iORFrETGh3s((i4QYgxXCfKs0Qxjb(fzQYd9fVN3lXlK7bBETjiHO(IJb9XCpVxIxi3d28AtGhOAETXGoIbqXWRscwz3eVqUhS51MGeI6logwgZ98EjEHCpyZRnbje1xCma(lEWuREVgqo4hfc)fvU51(fzQqxVs6lYuHTvrOViLJrlib24fY9GnV2gKquFXF7Jcb7JQViT6vsGFu(fpyQLT3LuJRyZxGFui8xeKWCO3zETFrbhiiogRNIb8avZRnM6fJ1tXiE2yyR9fOa4yqPKWyFbgdQlK7bBETXyvmwpfdTGXuVySEkg(bcP1Ib1fY9GnV2y8xmwpfdxXwmzRJemgEH0jjJIb8a9fymwVJJb1fY9GnV20xS6(Iki4xKdDJGU(f51cECl57JGRkBCfZvqkrRELeymaedGI5EEVe(SnH8fiUDLeg7lWgKuq0sNUyyL1yyQqxVskr5y0csGnEHCpyZRTbje1xCmckgHtSDmOJyaYbtiAoXGoIbqXCpVxcF2Mq(ce3UscJ9fycrZPHnLlum5xm3Z7LWNTjKVaXTRKWyFbMWMYfkgahdG)Imv5H(ImvORxjLWcDBGhOAETFXdMA171aYb)Oq4VOYnV2Vitf66vsFrMkSTkc9fPCmAbjWgVqUhS512GeI6l(BFuK3)O6lsRELe4hLFro0nc66x8EEVeVqUhS51MaRS7xu5Mx7x8QaB1RzqNle(BFuW2Fu9fPvVsc8JYVih6gbD9lQCZzsnAjeNWXiOyeogaI5EEVeVqUhS51MaRS7xu5Mx7xu6m9fy7wi3V9rrU)JQViT6vsGFu(fpyQLT3LuJRyZxGFui8xKdDJGU(fztm8AbpUL89rWvLnUI5kiLOvVscmgaIH3RqGeogbLjgHJbGyUN3lXlK7bBETPtxmaedBI5EEV0ZHe2kiscsk3IbGyytm3Z7L6lRHniPcLGKYTyaiM(YAydsQqnChjL4MVTN0b2BXG(yUN3l1tQ5lW2PlbjLBXWYyY1x8GPw9EnGCWpke(lQCZR9l(Ci1UsfBFrqcZHEN51(frNCRVowmc(9rWvLXGAfZvqIXyqNFWwmhmfdl6qkgukvSHJjBpTXy9eAXKTwbSyqolVpgo0nCm6cgt2EAJHfDiHTcIeJJJbSYUPV9rbBXhvFrA1RKa)O8lEWulBVlPgxXMVa)Oq4ViiH5qVZ8A)IOtU1hJGFFeCvzmOwXCfKymgw0HumOuQylMdMIb3xhjymxkgfe0nVwvkrlgETydQ(sGXGRySE1IXTyCCmBzXCPyoycmMZkjmogb)(i4QYyqTI5kifJJJrV1XIXQyOC6CiftbJX6jifJcPyqkifJ1RBm0whG9XWIoKIbLsfB4ySkgkhJwWye87JGRkJb1kMRGumwfJ1tXqlym1lguxi3d28AtFXQ7lIj7lYHUrqx)I8AbpUL89rWvLnUI5kiLOvVsc8lYuLh6lQCZRn9Ci1UsfBjEVcbs42dQCZRvLXG(yaummvORxjLOCmAbjWgVqUhS512GeI6loM8lM759s((i4QYgxXCfKsGhOAETXa4yyym8QKGv2n9Ci1UsfBjWdunV2V4btT69Aa5GFui8xu5Mx7xKPcD9kPVitf2wfH(IuoDe3iW2ZHu7kvSH)2hf5UpQ(I0Qxjb(r5xS6(IyY(Ik38A)ImvORxj9fpyQvVxdih8JcH)ImvyBve6lUebsGTNdP2vQyd)f5q3iORFrETGh3s((i4QYgxXCfKs0Qxjb(fpyQLT3LuJRyZxGFui8xKPkp0xKtUmgafdtf66vsjkhJwqcSXlK7bBETniHO(IJHHXaOyUN3l57JGRkBCfZvqkbEGQ51gt(fdqoycrZjgahdG)2hfSLFu9fPvVsc8JYV4btTS9UKACfB(c8JcH)ICOBe01ViVwWJBjFFeCvzJRyUcsjA1RKaJbGy49keiHJrqzIr4yaigafdtf66vsjkNoIBey75qQDLk2WXiOmXWuHUELuAjcKaBphsTRuXgogwzngMk01RKsuogTGeyJxi3d28ABqcr9fhdlZeZ98EjFFeCvzJRyUcsjWdunV2yyL1yUN3l57JGRkBCfZvqkHnLlumSmMCfdRSgZ98EjFFeCvzJRyUcsjiHO(IJHLXaKdMq0CIHvwJHxLeSYUjCV)mFb26QSembjfeTyaigLBotQrlH4eogbLjgMk01RKs8c5EWMxBd37pZxGTUklbJbGy4ftA11sRdS3ApLIbWXaqm3Z7L4fY9GnV20PlgaIbqXWMyUN3l9CiHTcIKGKYTyyL1yUN3l57JGRkBCfZvqkbje1xCmSmM8Ly7yaCmaedBI5EEVuFznSbjvOeKuUfdaX0xwdBqsfQH7iPe38T9KoWElg0hZ98EPEsnFb2oDjiPClgwgtU(Ihm1Q3RbKd(rHWFrLBETFXNdP2vQy7BFuiC((O6lsRELe4hLFrLBETFrEDwJG4osk)IGeMd9oZR9lYaHuNcPyYloM7DsFviAXG6cbrxWyEfmguxi3d28AtXGIYOySE1IX6PyY)NLIPEXWaRSemMhSqIb1fY9GnV2y41znCmkogDJrWb56sXG7iPKXyWvmcoixxkgChjL4yuiftTs0IzjoHXkeTy8xmwVAXyQKwlghhZwwmhmbM(ICOBe01Vi8S0RGaPeOJ5EN0xfIwJxii6cMOvVscmgaI5EEVeOJ5EN0xfIwJxii6cMaRSBmaeZ98EjqhZ9oPVkeTgVqq0fSPqUUucSYUXaqm8QKGv2nDpVxd0XCVt6RcrRXleeDbtqsbrlgaIHnXyQKwlbpl1QxRRYsWeT6vsGF7JcHf(JQViT6vsGFu(f5q3iORFr4zPxbbsjqhZ9oPVkeTgVqq0fmrRELeymaeZ98EjqhZ9oPVkeTgVqq0fmbwz3yaiM759sGoM7DsFviAnEHGOlytHCDPeyLDJbGy4vjbRSB6EEVgOJ5EN0xfIwJxii6cMGKcIwmaedBIXujTwcEwQvVwxLLGjA1RKa)Ik38A)IkKRl1OC6Kf2R9BFuiCU(O6lsRELe4hLFro0nc66xeEw6vqGuc0XCVt6RcrRXleeDbt0QxjbgdaXCpVxc0XCVt6RcrRXleeDbtGv2ngaI5EEVeOJ5EN0xfIwJxii6c2EWcBjWk7(fvU51(fFWcB3sAF7JcHfSpQ(I0Qxjb(r5xKdDJGU(fHNLEfeiLacDSeTMZDUKs0QxjbgdaXCpVxIxi3d28AtGv29lQCZR9l(Gf2ABXu)2hfcN3)O6lsRELe4hLFrLBETFrUkLnLBETnPJTVO0XwBve6lQCZzsntL0A4V9rHWS9hvFrA1RKa)O8lEWulBVlPgxXMVa)Oq4Vih6gbD9lEpVxIxi3d28AtGv2ngaIbqXWMyGNLEfeiLaDm37K(Qq0A8cbrxWeT6vsGXWkRXCpVxc0XCVt6RcrRXleeDbtNUyyL1yUN3lb6yU3j9vHO14fcIUGThSWw60fdaXyQKwlbpl1QxRRYsWeT6vsGXaqm8QKGv2nDpVxd0XCVt6RcrRXleeDbtqsbrlgahdaXaOyytmWZsVccKsaHowIwZ5oxsjA1RKaJHvwJbKUN3lbe6yjAnN7CjLoDXa4yaigafJYnV2eczubt(2EshyVfdaXOCZRnHqgvWKVTN0b2BniHO(IJHLzIHPcD9kPeVqUhS5124k2Aqcr9fhdRSgJYnV2eMxqEFIYH4hZxGXaqmk38AtyEb59jkhIFmQbje1xCmSmgMk01RKs8c5EWMxBJRyRbje1xCmSYAmk38Atphsxvktuoe)y(cmgaIr5MxB65q6QszIYH4hJAqcr9fhdlJHPcD9kPeVqUhS5124k2Aqcr9fhdRSgJYnV2uhAW6kvSLOCi(X8fymaeJYnV2uhAW6kvSLOCi(XOgKquFXXWYyyQqxVskXlK7bBETnUITgKquFXXWkRXOCZRn9KkcHnOleLOCi(X8fymaeJYnV20tQie2GUquIYH4hJAqcr9fhdlJHPcD9kPeVqUhS5124k2Aqcr9fhdG)Ihm1Q3RbKd(rHWFrLBETFrEHCpyZR9BFuiCU)JQViT6vsGFu(fbjmh6DMx7xm)z9emgEvsWk7IJX6vlgCFDKGXCPyoycmMSU1hdQlK7bBETXG7RJemMALOfZLI5GjWyY6wFm6gJYTJkJb1fY9GnV2y4k2IrxWy2YIjRB9XOXiE2yyR9fOa4yqPKWyFbgthS4PVOYnV2VixLYMYnV2M0X2xKdDJGU(fVN3lXlK7bBETjiHO(IJrqXK7IHvwJHxLeSYUjEHCpyZRnbje1xCmSmg2(lkDS1wfH(I8c5EWMxBJxLeSYU4V9rHWSfFu9fPvVsc8JYVih6gbD9lcOyUN3l1xwdBqsfkbjLBXaqmk3CMuJwcXjCmcktmmvORxjL4fY9GnV22tQie2GUqumaogwzngafZ98EPNdjSvqKeKuUfdaXOCZzsnAjeNWXiOmXWuHUELuIxi3d28ABpPIqyd6crXKFXapl9kiqk9CiHTcIKOvVscmga)fvU51(fFsfHWg0fI(2hfcN7(O6lsRELe4hLFro0nc66x8EEVe(SnH8fiUDLeg7lWgKuq0sNUyaiM759s4Z2eYxG42vsySVaBqsbrlbje1xCmckgUITM5i0xu5Mx7xSdnyDLk2(2hfcZw(r1xKw9kjWpk)ICOBe01V498EPNdjSvqKeKuU9fvU51(f7qdwxPITV9rrUY3hvFrA1RKa)O8lYHUrqx)I3Z7L6qdwCPIrsqs5wmaeZ98EPo0GfxQyKeKquFXXiOy4k2AMJqXaqmakM759s8c5EWMxBcsiQV4yeumCfBnZrOyyL1yUN3lXlK7bBETjWk7gdGJbGyuU5mPgTeIt4yyzmmvORxjL4fY9GnV22tQie2GUq0xu5Mx7xSdnyDLk2(2hf5s4pQ(I0Qxjb(r5xKdDJGU(fVN3l1xwdBqsfkbjLBXaqm3Z7L4fY9GnV20P7lQCZR9l2HgSUsfBF7JICLRpQ(I0Qxjb(r5xKdDJGU(f7GeZgqoys4eMxqEFmaeZ98EPEsnFb2oDjiPClgaIr5MZKA0sioHJHLXWuHUELuIxi3d28ABpPIqyd6crFrLBETFXo0G1vQy7BFuKlb7JQViT6vsGFu(fvU51(fX9(Z8fyRRYsWVOVgbHNoR5VVOYnV20ZHu7kvSL49keiHZOCZRn9Ci1UsfBjenNgVxHaj8xKdDJGU(fVN3lXlK7bBETPtxmaedBIr5MxB65qQDLk2s8EfcKWXaqmk3CMuJwcXjCmcktmmvORxjL4fY9GnV2gU3FMVaBDvwcgdaXOCZRn11x0650EsfHWP3rkBqI3RqGuZCekgbfZ7iLnibE4Mx7xeKWCO3zETFr2kSVaJrS3FMVaJHbwzjymGhOVaJb1fY9GnV2ySkgiHTcsXWIoKIbLsfBXOlymmW(IwpNyyrPIqXW7viqchdx3yUumxAPNZDvYym3JfZbFuPeTyQvIwm1gJGRYnPV9rrUY7Fu9fPvVsc8JYVih6gbD9lEpVxIxi3d28AtNUyaigdQmjzZCekgwgZ98EjEHCpyZRnbje1xCmaedGIbqXOCZRn9Ci1UsfBjEVcbs4yyzmchdaXyQKwl1HgS4sfJKOvVscmgaIr5MZKA0sioHJjtmchdGJHvwJHnXyQKwl1HgS4sfJKOvVscmgwzngLBotQrlH4eogbfJWXa4yaiM759s9KA(cSD6sqs5wmOpM(YAydsQqnChjL4MVTN0b2BXWYyY1xu5Mx7xSRVO1ZP9KkcH)2hf5IT)O6lsRELe4hLFro0nc66x8EEVeVqUhS51MaRSBmaedVkjyLDt8c5EWMxBcsiQV4yyzmCfBnZrOyaigLBotQrlH4eogbLjgMk01RKs8c5EWMxB7jvecBqxi6lQCZR9l(KkcHnOle9TpkYvU)JQViT6vsGFu(f5q3iORFX759s8c5EWMxBcSYUXaqm8QKGv2nXlK7bBETjiHO(IJHLXWvS1mhHIbGyytm8AbpULEsfHAkNdjZRnrRELe4xu5Mx7x85q6Qs53(OixSfFu9fPvVsc8JYVih6gbD9lEpVxIxi3d28Atqcr9fhJGIHRyRzocfdaXCpVxIxi3d28AtNUyyL1yUN3lXlK7bBETjWk7gdaXWRscwz3eVqUhS51MGeI6logwgdxXwZCe6lQCZR9lI5fK3)TpkYvU7JQViT6vsGFu(f5q3iORFX759s8c5EWMxBcsiQV4yyzma5GjenNyaigLBotQrlH4eogbfJWFrLBETFrPZ0xGTBHC)2hf5IT8JQViT6vsGFu(f5q3iORFX759s8c5EWMxBcsiQV4yyzma5GjenNyaiM759s8c5EWMxB609fvU51(fbHkWAXTlKuR)BFuiy57JQViT6vsGFu(f5q3iORFrtHajl1tQ06tDClgwMjgblFXaqmMkP1sysH(cSz1H3NOvVsc8lQCZR9lI5fK3)TV9fvU5mPMPsAn8hvFui8hvFrA1RKa)O8lYHUrqx)Ik3CMuJwcXjCmckgHJbGyUN3lXlK7bBETjWk7gdaXaOyyQqxVskzoc1SQXlK7bBETXiOy4vjbRSBs6m9fy7wi3e4bQMxBmSYAmmvORxjLmhHAw14fY9GnV2yyzMyYxma(lQCZR9lkDM(cSDlK73(OixFu9fPvVsc8JYVih6gbD9lYuHUELuYCeQzvJxi3d28AJHLzIjFXWkRXaOy4vjbRSBcHmQGjWdunV2yyzmmvORxjLmhHAw14fY9GnV2yaig2eJPsATe8SuRETUklbt0QxjbgdGJHvwJXujTwcEwQvVwxLLGjA1RKaJbGyUN3lbpl1QxRRYsW0PlgaIHPcD9kPK5iuZQgVqUhS51gJGIr5MxBcHmQGjEvsWk7gdRSgZZb2BniHO(IJHLXWuHUELuYCeQzvJxi3d28A)Ik38A)IiKrf8BFuiyFu9fPvVsc8JYVih6gbD9lAQKwlPskhSbvCEnf3EhiAjA1RKaJbGyaum3Z7L4fY9GnV2eyLDJbGyytm3Z7L6lRHniPcLGKYTya8xu5Mx7xeeQaRf3UqsT(V9TVi20fuHGnyzQ51(r1hfc)r1xKw9kjWpk)ICOBe01VOYnNj1OLqCchJGYedtf66vsP(YAydsQqTNuriSbDHOyaigafZ98EP(YAydsQqjiPClgwznM759sphsyRGijiPClga)fvU51(fFsfHWg0fI(2hf56JQViT6vsGFu(f5q3iORFX759sphsyRGijiPC7lQCZR9l2HgSUsfBF7Jcb7JQViT6vsGFu(f5q3iORFX759s9L1WgKuHsqs5wmaeZ98EP(YAydsQqjiHO(IJHLXOCZRn9CiDvPmr5q8JrnZrOVOYnV2VyhAW6kvS9TpkY7Fu9fPvVsc8JYVih6gbD9lEpVxQVSg2GKkucsk3IbGyaumDqIzdihmjC65q6QszmSYAmphsytHgbtk3CMumSYAmk38AtDObRRuXwY32t6a7Tya8xu5Mx7xSdnyDLk2(2hfS9hvFrA1RKa)O8lQCZR9l2HgSUsfBFrqcZHEN51(frfeTySkgGKfJiBnkJPdwCCm(IDqkM8FXaJPRxXeoMcgdQlK7bBETX01Rycht2EAJPRWy)kP0xKdDJGU(fVN3lHpBtiFbIBxjHX(cSbjfeT0PlgaIbqXWRscwz3e8SuRETUklbtqcr9fhd6Jr5MxBcEwQvVwxLLGjkhIFmQzocfd6JHRyRzocfJGI5EEVe(SnH8fiUDLeg7lWgKuq0sqcr9fhdRSgdBIXujTwcEwQvVwxLLGjA1RKaJbWXaqmmvORxjLmhHAw14fY9GnV2yqFmCfBnZrOyeum3Z7LWNTjKVaXTRKWyFb2GKcIwcsiQV4V9rrU)JQViT6vsGFu(f5q3iORFX759s9L1WgKuHsqs5wmaeJPqGKL6jvA9PoUfdlZeJGLVyaigtL0AjmPqFb2S6W7t0Qxjb(fvU51(f7qdwxPITV9rbBXhvFrA1RKa)O8lYHUrqx)I3Z7L6qdwCPIrsqs5wmaedxXwZCekgwgZ98EPo0GfxQyKeKquFXFrLBETFXo0G1vQy7BFuK7(O6lsRELe4hLFXdMAz7Dj14k28f4hfc)f5q3iORFr2eZZHe2uOrWKYnNjfdaXWMyyQqxVsk9Ci1UsfBTUQK(cmgaIbqXaOyaumk38Atphsxvktuoe)y(cmgaIbqXOCZRn9CiDvPmr5q8JrniHO(IJHLXKVeBhdRSgdBIbEw6vqGu65qcBfejrRELeymaogwzngLBETPo0G1vQylr5q8J5lWyaigafJYnV2uhAW6kvSLOCi(XOgKquFXXWYyYxITJHvwJHnXapl9kiqk9CiHTcIKOvVscmgahdGJbGyUN3l1tQ5lW2PlbjLBXa4yyL1yaumMkP1sysH(cSz1H3NOvVscmgaIXuiqYs9KkT(uh3IHLzIrWYxmaedGI5EEVupPMVaBNUeKuUfdaXWMyuU51MW8cY7tuoe)y(cmgwzng2eZ98EP(YAydsQqjiPClgaIHnXCpVxQNuZxGTtxcsk3IbGyuU51MW8cY7tuoe)y(cmgaIHnX0xwdBqsfQH7iPe38T9KoWElgahdGJbWFXdMA171aYb)Oq4VOYnV2V4ZHu7kvS9fbjmh6DMx7xmVCG(cmgRNIbB6cQqWyGLPMxlJXuReTyoykgw0HumOuQydht2EAJX6j0IrHumBzXCjFbgtxvscmMxbJj)xmWykymOUqUhS51MIHTctXWIoKIbLsfBXqU1tWyapqFbgJgdl6q6QsjdzGObRRuXwmCfBXKTN2yYBKA(cmg2QUyCCmk3CMumfmgWd0xGXq5q8JrXK1T(yejf6lWyqvD49PV9rbB5hvFrA1RKa)O8lYHUrqx)IDqIzdihmjCcZliVpgaI5EEVupPMVaBNUeKuUfdaXyQKwlHjf6lWMvhEFIw9kjWyaigtHajl1tQ06tDClgwMjgblFXaqmk3CMuJwcXjCmSmgMk01RKs9L1WgKuHApPIqyd6crFrLBETFXo0G1vQy7BFuiC((O6lsRELe4hLFro0nc66xKnXWuHUELuQRVO1ZP1vL0xGXaqmakg2eJPsAT0dwinRNAkUNWjA1RKaJHvwJr5MZKA0sioHJrqXiCmaogaIbqXOCZzsnWYsoW1nkgwgtUIHvwJr5MZKA0sioHJrqzIHPcD9kPuVcbBCfBTNuriSbDHOyyL1yuU5mPgTeIt4yeuMyyQqxVsk1xwdBqsfQ9KkcHnOlefdG)Ik38A)ID9fTEoTNuri83(OqyH)O6lsRELe4hLFrLBETFrUkLnLBETnPJTVO0XwBve6lQCZzsntL0A4V9rHW56JQViT6vsGFu(f5q3iORFrLBotQrlH4eogbfJWFrLBETFrqOcSwC7cj16)2hfclyFu9fPvVsc8JYVih6gbD9lAkeizPEsLwFQJBXWYmXiy5lgaIXujTwctk0xGnRo8(eT6vsGFrLBETFrmVG8(V9rHW59pQ(I0Qxjb(r5xKdDJGU(fvU5mPgTeIt4yeuMyyQqxVskPqUUuJYPtwyV2yaigeD1uh3IrqzIHPcD9kPKc56snkNozH9ABi6QFrLBETFrfY1LAuoDYc71(TpkeMT)O6lsRELe4hLFrLBETFXNuriSbDHOViiH5qVZ8A)IOtU1hdT1byFmMcbsgMXyClghhJgdq13ySkgUITyyrPIqyd6crXO4yEUusWy8fBKcgt9IHfDiDvPm9f5q3iORFrLBotQrlH4eogbLjgMk01RKs9keSXvS1EsfHWg0fI(2hfcN7)O6lQCZR9l(CiDvP8lsRELe4hLF7BFrEHCpyZRTXRscwzx8hvFui8hvFrLBETFXUY8A)I0Qxjb(r53(OixFu9fvU51(fVYQaBVdeTViT6vsGFu(TpkeSpQ(I0Qxjb(r5xKdDJGU(fVN3lXlK7bBETPt3xu5Mx7x8sqmbfYxGF7JI8(hvFrLBETFXNdPRSkWViT6vsGFu(Tpky7pQ(Ik38A)I6YjSbvzJRs5xKw9kjWpk)2hf5(pQ(I0Qxjb(r5xKdDJGU(fHNLEfeiLmcPRGQSLvHDjA1RKaJbGyUN3lr50RhS51MoDFrLBETFrZrOwwf29Tpkyl(O6lsRELe4hLFrLBETFrGsf0vRG42vbbsFr69iU1wfH(IaLkORwbXTRccK(2hf5UpQ(I0Qxjb(r5xCve6l6lMdpMELuJbC01oinqIPZPVOYnV2VOVyo8y6vsngWrx7G0ajMoN(2hfSLFu9fPvVsc8JYV4Qi0x8jveQvV2vntsFrLBETFXNurOw9Ax1mj9TpkeoFFu9fPvVsc8JYV4Qi0xmRkeTee3EWAb)Ik38A)IzvHOLG42dwl43(OqyH)O6lsRELe4hLFXvrOVOVydE4wbXnqNPVu7ss5xu5Mx7x0xSbpCRG4gOZ0xQDjP8BFuiCU(O6lsRELe4hLFXvrOVi(SxzvGnfHSE0W2xu5Mx7xeF2RSkWMIqwpAy7BFuiSG9r1xu5Mx7x8GPMBec(lsRELe4hLF7BF7lYKGyV2pkYv(YLW5t4CX2FXSkC9fi(lIoj4Y)OqWJI8kwiMyqvpfJJ0vqlMxbJray1166vmjqmqIbCCibgdUqOy0JviQrGXW71fiHtb7ORVumSnledQRLjbncmgbmvsRLYJaXyvmcyQKwlLNeT6vsGcedGYvoaofSJU(sXK7zHyqDTmjOrGXiGPsATuEeigRIratL0AP8KOvVscuGyaKW5a4uWo66lftUNfIb11YKGgbgJaWZsVccKs5rGySkgbGNLEfeiLYtIw9kjqbIbq5khaNc2rxFPyylzHyqDTmjOrGXiGPsATuEeigRIratL0AP8KOvVscuGyaKW5a4uWo66lfJWcZcXG6AzsqJaJratL0AP8iqmwfJaMkP1s5jrRELeOaXOwm5M8h6gdGeohaNc2d2rNeC5Fui4rrEfletmOQNIXr6kOfZRGXiai90J0eigiXaooKaJbxium6Xke1iWy496cKWPGD01xkgHzHyqDTmjOrGXia8S0RGaPuEeigRIra4zPxbbsP8KOvVscuGyulMCt(dDJbqcNdGtb7ORVum5IfIb11YKGgbgJaMkP1s5rGySkgbmvsRLYtIw9kjqbIbq5khaNc2rxFPyyBwiguxltcAeymcyQKwlLhbIXQyeWujTwkpjA1RKafigajCoaofSJU(sXK7zHyqDTmjOrGXiGPsATuEeigRIratL0AP8KOvVscuGyaKW5a4uWo66lfdBbledQRLjbncmgbGNLEfeiLYJaXyvmcapl9kiqkLNeT6vsGcedGeohaNc2rxFPyYDSqmOUwMe0iWyeWujTwkpceJvXiGPsATuEs0Qxjbkqmas4CaCkyhD9LIr4ChledQRLjbncmgrhb1XGrBnnNyqNHolgRIbDpAmif4rEWXuDeuTcgdGqNb4yaKW5a4uWo66lfJW5owiguxltcAeymcWRf84wkpceJvXiaVwWJBP8KOvVscuGyaKW5a4uWo66lftUYhledQRLjbncmgb41cEClLhbIXQyeGxl4XTuEs0Qxjbkqmas4CaCkyhD9LIjx5IfIb11YKGgbgJaWZsVccKs5rGySkgbGNLEfeiLYtIw9kjqbIbqcNdGtb7ORVum5sWyHyqDTmjOrGXia8S0RGaPuEeigRIra4zPxbbsP8KOvVscuGyaKW5a4uWo66lftUY7SqmOUwMe0iWyeaEw6vqGukpceJvXia8S0RGaPuEs0Qxjbkqmas4CaCkyhD9LIjx5owiguxltcAeymcapl9kiqkLhbIXQyeaEw6vqGukpjA1RKafigajCoaofSJU(sXiy5JfIb11YKGgbgJaMkP1s5rGySkgbmvsRLYtIw9kjqbIbqcNdGtb7b7OtcU8pke8OiVIfIjgu1tX4iDf0I5vWyeOds8c5QMaXajgWXHeym4cHIrpwHOgbgdVxxGeofSJU(sXKlwiguxltcAeymcyQKwlLhbIXQyeWujTwkpjA1RKafigajCoaofSJU(sXKlwiguxltcAeymcyQKwlLhbIXQyeWujTwkpjA1RKafig1Ij3K)q3yaKW5a4uWo66lfJGXcXG6AzsqJaJratL0AP8iqmwfJaMkP1s5jrRELeOaXaiHZbWPGD01xkgbJfIb11YKGgbgJaMkP1s5rGySkgbmvsRLYtIw9kjqbIrTyYn5p0ngajCoaofSJU(sXK3zHyqDTmjOrGXiGPsATuEeigRIratL0AP8KOvVscuGyaKW5a4uWo66lftENfIb11YKGgbgJaMkP1s5rGySkgbmvsRLYtIw9kjqbIrTyYn5p0ngajCoaofSJU(sXW2SqmOUwMe0iWyeWujTwkpceJvXiGPsATuEs0Qxjbkqmas4CaCkyhD9LIHTzHyqDTmjOrGXiGPsATuEeigRIratL0AP8KOvVscuGyulMCt(dDJbqcNdGtb7b7OtcU8pke8OiVIfIjgu1tX4iDf0I5vWyeGxi3d28AB8QKGv2flqmqIbCCibgdUqOy0JviQrGXW71fiHtb7ORVum5EwiguxltcAeymcapl9kiqkLhbIXQyeaEw6vqGukpjA1RKafigajCoaofShSJoj4Y)OqWJI8kwiMyqvpfJJ0vqlMxbJraLBotQzQKwdlqmqIbCCibgdUqOy0JviQrGXW71fiHtb7ORVum5IfIb11YKGgbgJaMkP1s5rGySkgbmvsRLYtIw9kjqbIbq5khaNc2rxFPyemwiguxltcAeymcyQKwlLhbIXQyeWujTwkpjA1RKafigajCoaofShSJoj4Y)OqWJI8kwiMyqvpfJJ0vqlMxbJraSPlOcbBWYuZRvGyGed44qcmgCHqXOhRquJaJH3RlqcNc2rxFPyyBwiguxltcAeymcyQKwlLhbIXQyeWujTwkpjA1RKafigajCoaofSJU(sXK7zHyqDTmjOrGXiGPsATuEeigRIratL0AP8KOvVscuGyulMCt(dDJbqcNdGtb7ORVum5owiguxltcAeymcyQKwlLhbIXQyeWujTwkpjA1RKafigajCoaofSJU(sXK7yHyqDTmjOrGXia8S0RGaPuEeigRIra4zPxbbsP8KOvVscuGyauUYbWPGD01xkg2swiguxltcAeymcyQKwlLhbIXQyeWujTwkpjA1RKafigajCoaofSJU(sXiC(yHyqDTmjOrGXiGPsATuEeigRIratL0AP8KOvVscuGyaKW5a4uWo66lfJWcgledQRLjbncmgbmvsRLYJaXyvmcyQKwlLNeT6vsGceJAXKBYFOBmas4CaCkypyhDsWL)rHGhf5vSqmXGQEkghPRGwmVcgJa8c5EWMxBRRxXKaXajgWXHeym4cHIrpwHOgbgdVxxGeofSJU(sXKlwiguxltcAeymcWRf84wkpceJvXiaVwWJBP8KOvVscuGyulMCt(dDJbqcNdGtb7ORVumcgledQRLjbncmgb41cEClLhbIXQyeGxl4XTuEs0Qxjbkqmas4CaCkyhD9LIj3ZcXG6AzsqJaJraETGh3s5rGySkgb41cEClLNeT6vsGcedGeohaNc2rxFPyylyHyqDTmjOrGXi6iOogmARP5ed6SySkg09OXa6mDSxBmvhbvRGXaigc4yaKW5a4uWo66lfdBbledQRLjbncmgb41cEClLhbIXQyeGxl4XTuEs0QxjbkqmQftUj)HUXaiHZbWPGD01xkMChledQRLjbncmgrhb1XGrBnnNyqNfJvXGUhngqNPJ9AJP6iOAfmgaXqahdGeohaNc2rxFPyYDSqmOUwMe0iWyeGxl4XTuEeigRIraETGh3s5jrRELeOaXOwm5M8h6gdGeohaNc2rxFPyylzHyqDTmjOrGXiaVwWJBP8iqmwfJa8AbpULYtIw9kjqbIbqcNdGtb7ORVumcNpwiguxltcAeymcyQKwlLhbIXQyeWujTwkpjA1RKafig1Ij3K)q3yaKW5a4uWo66lfJW5JfIb11YKGgbgJaWZsVccKs5rGySkgbGNLEfeiLYtIw9kjqbIbqcNdGtb7ORVumclmledQRLjbncmgbmvsRLYJaXyvmcyQKwlLNeT6vsGceJAXKBYFOBmas4CaCkyhD9LIryHzHyqDTmjOrGXia8S0RGaPuEeigRIra4zPxbbsP8KOvVscuGyaKW5a4uWo66lfJW5IfIb11YKGgbgJaWZsVccKs5rGySkgbGNLEfeiLYtIw9kjqbIbqcNdGtb7ORVumclySqmOUwMe0iWyeaEw6vqGukpceJvXia8S0RGaPuEs0Qxjbkqmas4CaCkyhD9LIry2MfIb11YKGgbgJaMkP1s5rGySkgbmvsRLYtIw9kjqbIbqcNdGtb7ORVumcZ2SqmOUwMe0iWyeaEw6vqGukpceJvXia8S0RGaPuEs0Qxjbkqmakx5a4uWo66lfJWSfSqmOUwMe0iWyeaEw6vqGukpceJvXia8S0RGaPuEs0Qxjbkqmas4CaCkyhD9LIjx5DwiguxltcAeymcyQKwlLhbIXQyeWujTwkpjA1RKafigaLRCaCkyhD9LIjx5EwiguxltcAeymcWRf84wkpceJvXiaVwWJBP8KOvVscuGyulMCt(dDJbqcNdGtb7ORVumcw(yHyqDTmjOrGXiGPsATuEeigRIratL0AP8KOvVscuGyulMCt(dDJbqcNdGtb7b7cEKUcAeymSfXOCZRngPJnCky)lI7i(hf5Eb7l2bRNlPVidYGXWIoKIj3sbsb7midgtVzDywGHmeOB9NBIxime7ihPAETCO(mgIDeodd2zqgmg219Oq0Ijx5EgJjx5lxchShSZGmymOUxxGeMfc2zqgmM8lg2kmfZZb2BniHO(IJbQwpbJX61ngtHajlzoc1SQb6umVcgJuXw(HjETGXOxx6gAXCWkqcNc2zqgmM8lg0TkmTXWvSfdKyahhsi0A4yEfmguxi3d28AJbqEIsmgdyTcyX0xsWyClMxbJrJ5bjCFm5wKrfmgUInaNc2zqgmM8lMCZQxjfd2Go3IH3tCH8fym1gJgZJYgZRGcHJX3ySEkgbhdeDJXQyGe4HtXKTGcjlfmfShSZGmym5MCi(XiWyU0RGum8c5QwmxcOV4umcooN6mCmBT5xVcrEhzmk38AXXuReTuWUYnVwCQds8c5Qg6ZWqfY1LA(AKusClyNbJbv9oogMk01RKIb3rC)5eogRNIzpixcgt9IXuiqYWXOwmz7DEFm5TYIr0GKkumSOuriSbDHiCm1XWoift9Ib1fY9GnV2yW91rcgZLI5GjWuWUYnVwCQds8c5Qg6ZWqMk01RKyCvektFznSbjvO2tQie2GUqeJvxgmzm6VmmvORxjL6lRHniPc1EsfHWg0fIYKpgzQYdLjxOdtL0APNurOwNA8E0lyOd2yQKwl9Kkc16uJ3hSZGXGQEhhdtf66vsXG7iU)CchJ1tXShKlbJPEXykeiz4yulMS9oVpM8McbJb1k2IHfLkcHnOleHJPog2bPyQxmOUqUhS51gdUVosWyUumhmbgJIJ55sjbtb7k38AXPoiXlKRAOpddzQqxVsIXvrOm9keSXvS1EsfHWg0fIyS6YGjJr)LHPcD9kPuVcbBCfBTNuriSbDHOm5JrMQ8qzYf6WujTw6jveQ1PgVh9cg6GnMkP1spPIqTo149b7mymOQ3XXWuHUELum4oI7pNWXy9um7b5sWyQxmMcbsgog1IjBVZ7JjVvwmIgKuHIHfLkcHnOleHJrHumhmbgd4b6lWyqDHCpyZRnfSRCZRfN6GeVqUQH(mmKPcD9kjgxfHYWlK7bBETTNuriSbDHigRUmyYy0FzyQqxVskXlK7bBETTNuriSbDHOm5JrMQ8qzem0HPsAT0tQiuRtnEp6Z9Od2yQKwl9Kkc16uJ3hSZGXGQEhhdtf66vsXG7iU)CchJ1tXShKlbJPEXykeiz4yulMS9oVpgbhKRlftUjNozH9AJPog2bPyQxmOUqUhS51gdUVosWyUumhmbMc2vU51ItDqIxix1qFggYuHUELeJRIqzuixxQr50jlSxlJvxgmzm6VmmvORxjLuixxQr50jlSxBM8XitvEOmSLSLOdtL0APNurOwNA8E0Nl0bBmvsRLEsfHADQX7d2zWyqvVJJHPcD9kPyWDe3FoHJX6Py6iiNwtbsXuVyq0vJ5sYkBmz7DEFmcoixxkMCtoDYc71gtwxkJzllMlfZbtGPGDLBET4uhK4fYvn0NHHmvORxjX4QiugfY1LAuoDYc712q0vzeKE6rAzY75JXQldKWKfSZGXGo5wFmS1(ck9fiJXG6c5EWMxRa4y4vjbRSBmzDPmMlfdKapCcmMlAXOXa1fSqIrrQZAmgZ9yXy9um7b5sWyQxmCOB4yWMcnCmmjiAX07a7JrFgbJr5MZunFbgdQlK7bBETXOlymyzLfhdyLDJXQSkeehJ1tXqlym1lguxi3d28AfahdVkjyLDtXGo1tBmiQq(cmgqI7yVwCm(gJ1tXi4yGOlJXG6c5EWMxRa4yGeI6RVaJHxLeSYUX44yGe4HtGXCrlgR3XX8Gk38AJXQyuoVoRfZRGXWw7lO0xGPGDLBET4uhK4fYvn0NHHmvORxjX4QiugH8fu6lWgKapCZRLrq6PhPLjFP8oJvxgiHjlyNbJbv9umGhOAETXuVy0yepBmS1(cuaCmOusySVaJb1fY9GnV2uWUYnVwCQds8c5Qg6ZWqMk01RKyCvekdwOBd8avZRLXQldMmgzQYdLHTd2vU51ItDqIxix1qFggYuHUELeJRIqz4fY9GnV2wTTdMyS6YGjJrMQ8qzigWX76iWeqPc6QvqC7QGajwzLyahVRJatikxVqQH7jYAihSZzLvIbC8Uocm5lMdpMELuJbC01oinqIPZjwzLyahVRJat4ZELvb2ueY6rdBSYkXaoExhbMiKo0GKkBfeC1LtSYkXaoExhbMEsfHA1RDvZKeRSsmGJ31rGPSQq0sqC7bRfKvwjgWX76iWKVydE4wbXnqNPVu7sszWodgtERYgJSwGXCPxbPyqDHCpyZRngCFDKGXKBq6qdsQmM8heC1LtXCPyoycmVEWUYnVwCQds8c5Qg6ZWqMk01RKyCvekdH0HgKuzRGGRUCQbssfngbPNEKwgHZDmwDzGeMSGDgmM8wLngzTaJ5sVcsXG6c5EWMxBm4(6ibJXG(kez4ySE1IXGoqGemgngCVcjWy4QraliAXWRscwz3yQnMY6jymg0xHidhZwwmxkMdMaZRhSRCZRfN6GeVqUQH(mmKPcD9kjgxfHYuB7GPg)y17Xy1LbtgJmv5HYKR8XO)YWuHUELuIxi3d28AB12oykyx5Mxlo1bjEHCvd9zyitf66vsmUkcLP22btn(XQ3JXQldMmgzQYdLjxSnJ(ldXaoExhbMquUEHud3tK1qoyNhSRCZRfN6GeVqUQH(mmKPcD9kjgxfHYuB7GPg)y17Xy1LbtgJmv5HYKR8HEMk01RKseshAqsLTccU6YPgijv0y0FzigWX76iWeH0HgKuzRGGRUCkyNbJbv9um7b5sWyQxmMcbsgogXE)z(cmggyLLGXG7RJemMlfZbtGXuBmGhOVaJb1fY9GnV2uWUYnVwCQds8c5Qg6ZWqMk01RKyCvekdVqUhS512W9(Z8fyRRYsqgbPNEKwMCXy1LbsyYc2zWyqvpfJ5iumqcr91xGXuBmAmCfBXKTN2yqDHCpyZRngUUXCPyoycmgFJbt8AbXPGDLBET4uhK4fYvn0NHHmvORxjX4QiugEHCpyZRTXvS1GeI6lMrq6PhPLjFj2cgRUmqctwWUYnVwCQds8c5Qg6ZWWdMAUrimUkcLbxhzZbUUrWGDLBET4uhK4fYvn0NHHioewWMJOaPGDLBET4uhK4fYvn0NHHDObRRuXgJ(ldB6GeZuhAW6kvSfShSZGmym5MCi(XiWyiMeeTymhHIX6PyuUvWyCCmkt1L6vsPGDLBET4m86SgbXDKuYO)YWg4zPxbbsjqhZ9oPVkeTgVqq0fmyNbJj3wHUELumwVAXWR1GLeht2EAJb1fY9GnV2yCCmhmbMIbv9oogPVumyYWXG6c5EWMxBmwfZLI5GjWy0NrWyyrhsytHgbJrxWy0UoPt4ySEkgH8fu6lWgKapCZRngMk01RKIXQySEkgiHO(6lWy4vjbRSBm1lguxi3d28AtXi4abDZRvLs0ymg)fdQlK7bBETX44yaDSELeymwVJJbD(bBXGjdhJ1tXWuHUELumwfJgJ5iumDk2IX6PyOfmM6fJ1tXGDKJunV2uWUYnVwm6ZWqMk01RKyCvekJ5iuZQgVqUhS51Yy1LbtgJmv5HYyQKwl9CiHnfAeeD8CiHnfAembje1xm6beVkjyLDt8c5EWMxBcsiQVy0bGeo)yQqxVskjKVGsFb2Ge4HBETOdtL0AjH8fu6lqady0bB4vjbRSBIxi3d28AtqsbrdDCpVxIxi3d28AtGv2nyNbJj3sfIIbFGumOUqUhS51gJJJbKKkAeym(lMLiqcmMRIjWyQngRNIHq6qdsQSvqWvxo1ajPIwmmvORxjLc2vU51IrFggYuHUELeJRIqzmhHAw14fY9GnVwgRUmiAomYuLhkdtf66vsjcPdniPYwbbxD5udKKkA5hG4vjbRSBIq6qdsQSvqWvxoLapq18AZpEvsWk7MiKo0GKkBfeC1LtjiHO(Ibm6Gn8QKGv2nriDObjv2ki4QlNsqsbrJr)LHyahVRJateshAqsLTccU6YPGDgmM8cjv0Ib1fY9GnV2yEfmM8kPc6QvqbWXGsfeiLc2vU51IrFggYuHUELeJRIqzmhHAw14fY9GnVwgRUmiAomYuLhkdVkjyLDtaLkORwbXTRccKsqcr9fZO)YqmGJ31rGjGsf0vRG42vbbsb7mym5fsQOfdQlK7bBETXCwZLXK)lgymuoDoKWX4VyCtaCmNUuWUYnVwm6ZWqMk01RKyCvekJ5iuZQgVqUhS51Yy1LbrZHrMQ8qzUN3lbpl1QxRRYsWeKquFXm6VmMkP1sWZsT616QSeeG759s8c5EWMxBcSYUb7mym5fsQOfdQlK7bBETX8kym6gdLJb1yY)NLIPEXWaRSemg)fJ1tXK)plft9IHbwzjymzRJemgEHqXuVxm8QKGv2ng1Irsk2IHTJbt8AbXXCPxbPyqDHCpyZRnMS1rcMc2vU51IrFggYuHUELeJRIqzmhHAw14fY9GnVwgRUmiAomYuLhkdVkjyLDtWZsT616QSembje1xm6VN3lbpl1QxRRYsWe4bQMxlJ(lJPsATe8SuRETUklbb4EEVeVqUhS51MaRSla8QKGv2nbpl1QxRRYsWeKquFXONTzjtf66vsjZrOMvnEHCpyZRnyNbJjVqsfTyqDHCpyZRng)ftEXXCVt6Rcrlguxii6cgt26ibJzllMlfdKuq0I5vWyClg0ilfSRCZRfJ(mmKPcD9kjgxfHYyoc1SQXlK7bBETmwDzq0CyKPkpugEvsWk7MUN3Rb6yU3j9vHO14fcIUGjiHO(Iz0FzGNLEfeiLaDm37K(Qq0A8cbrxqaUN3lb6yU3j9vHO14fcIUGjWk7gSZGXKBRqxVskgRxTyiS5iQr4yY2twpbJrS3FMVaJHbwzjymzDPmMlfZbtGXCPxbPyqDHCpyZRnghhdKuq0sb7k38AXOpddzQqxVsIXvrOm4E)z(cS1vzjy7sVcsnEHCpyZRLXQldMmgzQYdLbqk3CMuJwcXjmlzQqxVskXlK7bBETnCV)mFb26QSeKvwvU5mPgTeItywYuHUELuIxi3d28ABpPIqyd6crSYktf66vsjZrOMvnEHCpyZRn)uU51MW9(Z8fyRRYsW07iLnibE4MxRG4vjbRSBc37pZxGTUklbtGhOAETagaMk01RKsMJqnRA8c5EWMxB(XRscwz3eU3FMVaBDvwcMGeI6lwqk38At4E)z(cS1vzjy6DKYgKapCZRfaaXRscwz3e8SuRETUklbtqcr9fNF8QKGv2nH79N5lWwxLLGjiHO(IfeBZkRSXujTwcEwQvVwxLLGaoyx5Mxlg9zyiU3FMVaBDvwcYO)YCpVxIxi3d28AtGv2fa2aO759s((i4QYgxXCfKsNoaUN3l1xwdBqsfkbjLBagaMk01RKs4E)z(cS1vzjy7sVcsnEHCpyZRnyx5Mxlg9zyiubDDTgUtHcXO)YaO759s8c5EWMxBcSYUaCpVxcEwQvVwxLLGjWk7caGyQqxVskzoc1SQXlK7bBETSKYH4hJAMJqSYktf66vsjZrOMvnEHCpyZRvq8QKGv2nbvqxxRH7uOqjWdunVwadywzfq3Z7LGNLA1R1vzjy60batf66vsjZrOMvnEHCpyZRvqcw(aCWUYnVwm6ZWqqsT(BbxIr)L5EEVeVqUhS51MaRSla3Z7LGNLA1R1vzjycSYUaWuHUELuYCeQzvJxi3d28AzjLdXpg1mhHc2vU51IrFggI4qybXT61ScIqRXO)YWuHUELuYCeQzvJxi3d28AzzgbdG759s8c5EWMxBcSYUb7mymSybJj3MwRhniJXCWumAmSOdPyqPuXwm8EfcKIb8a9fym5woewqCm1lguvqeATy4k2IXQyuMLdgdx768fym8EfcKWPGDLBETy0NHHphsTRuXgJhm1Y27sQXvS5lWmcZO)YOCZRnH4qybXT61ScIqRLOCi(X8fiaVJu2GeVxHaPM5iu(PCZRnH4qybXT61ScIqRLOCi(XOgKquFXSmVdaB6lRHniPc1WDKuIB(2EshyVbaBUN3l1xwdBqsfkbjLBb7k38AXOpddpyQ5gHWi9Ee3ARIqzakvqxTcIBxfeiXO)YWuHUELuYCeQzvJxi3d28AfeVkjyLDZp2oyx5Mxlg9zy4btn3iegxfHYqiDObjv2ki4QlNy0FzyQqxVskzoc1SQXlK7bBETSmdtf66vsjcPdniPYwbbxD5udKKkAb7k38AXOpddpyQ5gHW4QiugGs066B1RPySJ4s18Az0FzyQqxVskzoc1SQXlK7bBETckdtf66vsPABhm14hREVGDLBETy0NHHhm1CJqyCvekdIY1lKA4EISgYb7Cg9xgMk01RKsMJqnRA8c5EWMxllZW2b7mymc(xmhSVaJrJbBeSCWyQn)oykg3iegJrLzv0WXCWum5fiPGphsXKBtymjJPog2bPyQxmOUqUhS51MIj)z9emRJjgJPd6f0npVgfZb7lWyYlqsbFoKIj3MWysgtw36Jb1fY9GnV2yQvIwm(lgb)(i4QYyqTI5kifJJJHw9kjWy0fmgnMdwbsXKTwbSyUumYcBXumjymwpfd4bQMxBm1lgRNI55a7TuWUYnVwm6ZWWdMAUrimUkcLbesk4ZHuJjHXKKr)LHPcD9kPK5iuZQgVqUhS51kOmmvORxjLQTDWuJFS69aaq3Z7L89rWvLnUI5kiLWMYfkZ98EjFFeCvzJRyUcsjenNg2uUqSYkB41cECl57JGRkBCfZvqIvwzQqxVskXlK7bBETTABhmXkRmvORxjLmhHAw14fY9GnVw0Z2c65a7TgKquFXOZqNXRscwzxahSZGXiwhzmcEGRBemgCFDKGXCPyoycmgFJrJjRIwmwVAXaweEfWIXxJGpcsXK1T(ykRNGXuB(DWumg0xHidNIj)z9emgd6RqKHJbSIzllgd6absWy0yW9kKaJrWJ68sm1gJBmgdUIXTy46gZLI5GjWyGoWElg9zemgDrlMY6jym1MFhmfJb9viYsb7k38AXOpddpyQ5gHW4QiugCDKnh46gbz0FzyQqxVskzoc1SQXlK7bBETckJGLp0bGyQqxVskvB7GPg)y17jO8byaaeBigWX76iWeiKuWNdPgtcJjjRSYRscwz3eiKuWNdPgtcJjzcsiQVybX2aoyNbJbvqhiqcgJyDKXi4bUUrWyifkrlMSU1hJGFFeCvzmOwXCfKIPGXKTN2yClMSkoMoiXvSLc2vU51IrFggY1LtY298EmUkcLbxhzZbUU51YO)YWgETGh3s((i4QYgxXCfKaWCeILSnRSEpVxY3hbxv24kMRGucBkxOm3Z7L89rWvLnUI5kiLq0CAyt5cfSZGXi4ncbhJ1RwmGvmBzXCPLEUfdQlK7bBETXG7RJemg05hSfZLI5GjWyQJHDqkM6fdQlK7bBETXOwm4cHIPR81sb7k38AXOpddpyQ5gHGz0FzyQqxVskzoc1SQXlK7bBETckdtf66vsPABhm14hREVGDgmM8kYIX6PyYloM7DsFviAXG6cbrxWyUN3lMthJXCwjHXXWlK7bBETX44yWvTPGDLBETy0NHH86SgbXDKuYO)Yapl9kiqkb6yU3j9vHO14fcIUGaWRscwz3098EnqhZ9oPVkeTgVqq0fmbjfenaUN3lb6yU3j9vHO14fcIUGnfY1LsGv2fa2CpVxc0XCVt6RcrRXleeDbtNoayQqxVskzoc1SQXlK7bBETckxSDWUYnVwm6ZWqfY1LAuoDYc71YO)Yapl9kiqkb6yU3j9vHO14fcIUGaWRscwz3098EnqhZ9oPVkeTgVqq0fmbjfenaUN3lb6yU3j9vHO14fcIUGnfY1LsGv2fa2CpVxc0XCVt6RcrRXleeDbtNoayQqxVskzoc1SQXlK7bBETckxSDWUYnVwm6ZWWhSW2TKgJ(ld8S0RGaPeOJ5EN0xfIwJxii6ccaVkjyLDt3Z71aDm37K(Qq0A8cbrxWeKuq0a4EEVeOJ5EN0xfIwJxii6c2EWcBjWk7caBUN3lb6yU3j9vHO14fcIUGPthamvORxjLmhHAw14fY9GnVwbLl2oyx5Mxlg9zyixLYMYnV2M0XgJRIqz4fY9GnV2wxVIjg9xgMk01RKsMJqnRA8c5EWMxllZKVGDLBETy0NHHWZsT616QSeKr)L5EEVe8SuRETUklbtGv2fa2CpVx65qcBfejbjLBaaiMk01RKsMJqnRA8c5EWMxRGYCpVxcEwQvVwxLLGjWdunVwayQqxVskzoc1SQXlK7bBETcs5MxB65qQDLk2sVJu2GeVxHaPM5ieRSYuHUELuYCeQzvJxi3d28Af0Zb2BniHO(IbCWodgtUTcD9kPySE1IHxRbljogw0HumOuQylMdwbsXyvm0Ipqkg3WXW7viqchtxvscmMxbJb1fY9GnV2uWUYnVwm6ZWqMk01RKy8GPw9EnGCWmcZ4btTS9UKACfB(cmJWmUkcL55qQDLk2ADvj9fiJvxgmzmYuLhkdtf66vsjZrOMvnEHCpyZRn)emwQCZRn9Ci1UsfBP3rkBqI3RqGuZCek)uU51MW9(Z8fyRRYsW07iLnibE4Mxl6GPcD9kPeU3FMVaBDvwc2U0RGuJxi3d28AbGPcD9kPK5iuZQgVqUhS51YYNdS3Aqcr9fhSZGXKBRqxVskgRxTy41AWsIJHb2x065edlkvechZbRaPySkgAXhifJB4y49keiHJrHumDvjjWyEfmguxi3d28Atb7k38AXOpddzQqxVsIXvrOmD9fTEoTUQK(cKXQldMmgzQYdLHPcD9kPK5iuZQgVqUhS51YsLBETPU(IwpN2tQieo9oszds8EfcKAMJq5NYnV2eU3FMVaBDvwcMEhPSbjWd38ArhmvORxjLW9(Z8fyRRYsW2LEfKA8c5EWMxlamvORxjLmhHAw14fY9GnVww(CG9wdsiQVywzfEw6vqGucF2Mq(ce3UscJ9fiRSAocXs2oyx5Mxlg9zyixLYMYnV2M0XgJRIqzGvxRRxXeJ(lZ98Ej4zPw9ADvwcMoDaWuHUELuYCeQzvJxi3d28Afu(c2zWyeCGOZpylgRNIHPcD9kPySE1IHxRbljogw0HumOuQylMdwbsXyvm0Ipqkg3WXW7viqchJcPyujUIPRkjbgZRGXK)plft9IHbwzjykyx5Mxlg9zyitf66vsmEWuREVgqoygHz8GPw2ExsnUInFbMrygxfHY8Ci1UsfBTUQK(cKXQldMmgzQYdLHxLeSYUj4zPw9ADvwcMGeI6lMLk38AtphsTRuXw6DKYgK49kei1mhHYpLBETjCV)mFb26QSem9oszdsGhU51Ioaetf66vsjCV)mFb26QSeSDPxbPgVqUhS51caVkjyLDt4E)z(cS1vzjycsiQVywYRscwz3e8SuRETUklbtqcr9fdya4vjbRSBcEwQvVwxLLGjiHO(Iz5Zb2BniHO(Iz0Fzydtf66vsPNdP2vQyR1vL0xGayQKwlbpl1QxRRYsqaUN3lbpl1QxRRYsWeyLDd2zWyqN6PnM8Mcb5k28fymSOurOyenOleXymSOdPyqPuXgogCFDKGXCPyoycmgRIbiTeunkM8wzXiAqsfchJUGXyvmuogTGXGsPIncgtULIncMc2vU51IrFgg(Ci1UsfBmEWuREVgqoygHz8GPw2ExsnUInFbMryg9xg2WuHUELu65qQDLk2ADvj9fiamvORxjLmhHAw14fY9GnVwbLpauU5mPgTeItybLHPcD9kPuVcbBCfBTNuriSbDHiayZZHe2uOrWKYnNjbaBUN3l1xwdBqsfkbjLBaaO759s9KA(cSD6sqs5gak38AtpPIqyd6crjkhIFmQbje1xmlZxITzLvEVcbs42dQCZRvLcktUaCWodgtE5a9fymSOdjSPqJGmgdl6qkgukvSHJrHumhmbgd2rCPcLOfJvXaEG(cmguxi3d28AtXKxrlbvPengJX6j0IrHumhmbgJvXaKwcQgftERSyeniPcHJjBpTXWHUHJjRlLXSLfZLIjRIncmgDbJjRB9XGsPIncgtULIncYymwpHwm4(6ibJ5sXG7GKcgtDSySkge1xt9ngRNIbLsfBemMClfBemM759sb7k38AXOpddFoKAxPIngpyQvVxdihmJWmEWulBVlPgxXMVaZimJ(lZZHe2uOrWKYnNjbaVxHajSGYimaSHPcD9kP0ZHu7kvS16Qs6lqaaeBuU51MEoKUQuMOCi(X8fiaSr5MxBQdnyDLk2s(2EshyVbW98EPEsnFb2oDjiPCJvwvU51MEoKUQuMOCi(X8fiaS5EEVuFznSbjvOeKuUXkRk38AtDObRRuXwY32t6a7naUN3l1tQ5lW2PlbjLBaWM759s9L1WgKuHsqs5gGd2zWyeCmlhmgU215lWyyrhsXGsPITy49keiHJjBVlPy496UK0xGXi27pZxGXWaRSemyx5Mxlg9zy4ZHu7kvSX4btTS9UKACfB(cmJWm6Vmk38At4E)z(cS1vzjyIYH4hZxGa8oszds8EfcKAMJqSu5MxBc37pZxGTUklbtMZfQbjWd38Ab4EEVuFznSbjvOeyLDbWCesqcNVGDLBETy0NHHCvkBk38ABshBmUkcLbB6cQqWgSm18Az0FzyQqxVskzoc1SQXlK7bBETckFaCpVxcEwQvVwxLLGjWk7gSRCZRfJ(mmeZliVpypyx5MxloPCZzsntL0A4msNPVaB3c5YO)YOCZzsnAjeNWcsyaUN3lXlK7bBETjWk7caGyQqxVskzoc1SQXlK7bBETcIxLeSYUjPZ0xGTBHCtGhOAETSYktf66vsjZrOMvnEHCpyZRLLzYhGd2vU51Itk3CMuZujTgg9zyiczubz0FzyQqxVskzoc1SQXlK7bBETSmt(yLvaXRscwz3eczubtGhOAETSKPcD9kPK5iuZQgVqUhS51caBmvsRLGNLA1R1vzjiGzLvtL0Aj4zPw9ADvwccW98Ej4zPw9ADvwcMoDaWuHUELuYCeQzvJxi3d28AfKYnV2eczubt8QKGv2LvwFoWERbje1xmlzQqxVskzoc1SQXlK7bBETb7k38AXjLBotQzQKwdJ(mmeeQaRf3UqsTEg9xgtL0Ajvs5GnOIZRP427ardaaDpVxIxi3d28AtGv2fa2CpVxQVSg2GKkucsk3aCWEWUYnVwCIxi3d28AB8QKGv2fNPRmV2GDLBET4eVqUhS5124vjbRSlg9zy4vwfy7DGOfSRCZRfN4fY9GnV2gVkjyLDXOpddVeetqH8fiJ(lZ98EjEHCpyZRnD6c2vU51It8c5EWMxBJxLeSYUy0NHHphsxzvGb7k38AXjEHCpyZRTXRscwzxm6ZWqD5e2GQSXvPmyx5MxloXlK7bBETnEvsWk7IrFggAoc1YQWog9xg4zPxbbsjJq6kOkBzvyha3Z7LOC61d28AtNUGDLBET4eVqUhS5124vjbRSlg9zy4btn3iegP3J4wBvekdqPc6QvqC7QGaPGDLBET4eVqUhS5124vjbRSlg9zy4btn3iegxfHY4lMdpMELuJbC01oinqIPZPGDLBET4eVqUhS5124vjbRSlg9zy4btn3iegxfHY8Kkc1Qx7QMjPGDLBET4eVqUhS5124vjbRSlg9zy4btn3iegxfHYKvfIwcIBpyTGb7k38AXjEHCpyZRTXRscwzxm6ZWWdMAUrimUkcLXxSbpCRG4gOZ0xQDjPmyx5MxloXlK7bBETnEvsWk7IrFggEWuZncHXvrOm4ZELvb2ueY6rdBb7k38AXjEHCpyZRTXRscwzxm6ZWWdMAUri4G9GDLBET4eVqUhS51266vmLr6a7nCdD(beicTgJ(lZ98EjEHCpyZRnbwz3GDgmMCd2Ce1Oy6RSXiRfymOUqUhS51gtwxkJrQylgRxxHWXyvmINng2AFbkaogukjm2xGXyvmGKrqeFPy6RSXWIoKIbLsfB4yW91rcgZLI5GjWuWUYnVwCIxi3d28ABD9kMqFggYuHUELeJhm1Q3RbKdMrygpyQLT3LuJRyZxGzeMXvrOmuogTGeyJxi3d28ABqcr9fZy1LbtgJmv5HYCpVxIxi3d28Atqcr9fJ(759s8c5EWMxBc8avZRfDaiEvsWk7M4fY9GnV2eKquFXS8EEVeVqUhS51MGeI6lgWm6Vm8AbpUL89rWvLnUI5kifSZGXi4abXXy9umGhOAETXuVySEkgXZgdBTVafahdkLeg7lWyqDHCpyZRngRIX6PyOfmM6fJ1tXWpqiTwmOUqUhS51gJ)IX6Py4k2IjBDKGXWlKojzumGhOVaJX6DCmOUqUhS51Mc2vU51It8c5EWMxBRRxXe6ZWqMk01RKy8GPw9EnGCWmcZ4btTS9UKACfB(cmJWmUkcLHYXOfKaB8c5EWMxBdsiQVygRUmkiiJmv5HYWuHUELucl0TbEGQ51YO)YWRf84wY3hbxv24kMRGeaa6EEVe(SnH8fiUDLeg7lWgKuq0sNowzLPcD9kPeLJrlib24fY9GnV2gKquFXcs4eBJoaYbtiAoOdaDpVxcF2Mq(ce3UscJ9fycrZPHnLlu(DpVxcF2Mq(ce3UscJ9fycBkxiad4GDLBET4eVqUhS51266vmH(mm8QaB1RzqNleMr)L5EEVeVqUhS51MaRSBWUYnVwCIxi3d28ABD9kMqFggkDM(cSDlKlJ(lJYnNj1OLqCcliHb4EEVeVqUhS51MaRSBWodgd6KB91XIrWVpcUQmguRyUcsmgd68d2I5GPyyrhsXGsPInCmz7PngRNqlMS1kGfdYz59XWHUHJrxWyY2tBmSOdjSvqKyCCmGv2nfSRCZRfN4fY9GnV2wxVIj0NHHphsTRuXgJhm1Q3RbKdMrygpyQLT3LuJRyZxGzeMr)LHn8AbpUL89rWvLnUI5kibaVxHajSGYima3Z7L4fY9GnV20Pda2CpVx65qcBfejbjLBaWM759s9L1WgKuHsqs5ga9L1WgKuHA4oskXnFBpPdS3q)98EPEsnFb2oDjiPCJL5kyNbJbDYT(ye87JGRkJb1kMRGeJXWIoKIbLsfBXCWum4(6ibJ5sXOGGU51QsjAXWRfBq1xcmgCfJ1RwmUfJJJzllMlfZbtGXCwjHXXi43hbxvgdQvmxbPyCCm6TowmwfdLtNdPykymwpbPyuifdsbPySEDJH26aSpgw0HumOuQydhJvXq5y0cgJGFFeCvzmOwXCfKIXQySEkgAbJPEXG6c5EWMxBkyx5MxloXlK7bBETTUEftOpddzQqxVsIXdMA171aYbZimJhm1Y27sQXvS5lWmcZ4QiugkNoIBey75qQDLk2WmwDzWKXitvEOmk38AtphsTRuXwI3RqGeU9Gk38Avj6betf66vsjkhJwqcSXlK7bBETniHO(IZV759s((i4QYgxXCfKsGhOAETagDgVkjyLDtphsTRuXwc8avZRLr)LHxl4XTKVpcUQSXvmxbPGDLBET4eVqUhS51266vmH(mmKPcD9kjgpyQvVxdihmJWmEWulBVlPgxXMVaZimJRIqzwIajW2ZHu7kvSHzS6YGjJrMQ8qz4Klbetf66vsjkhJwqcSXlK7bBETniHO(IrNbO759s((i4QYgxXCfKsGhOAET5hqoycrZbWaMr)LHxl4XTKVpcUQSXvmxbPGDLBET4eVqUhS51266vmH(mm85qQDLk2y8GPw9EnGCWmcZ4btTS9UKACfB(cmJWm6Vm8AbpUL89rWvLnUI5kibaVxHajSGYimaaIPcD9kPeLthXncS9Ci1UsfBybLHPcD9kP0seib2EoKAxPInmRSYuHUELuIYXOfKaB8c5EWMxBdsiQVywM5EEVKVpcUQSXvmxbPe4bQMxlRSEpVxY3hbxv24kMRGucBkxiwMlwz9EEVKVpcUQSXvmxbPeKquFXSeihmHO5WkR8QKGv2nH79N5lWwxLLGjiPGObGYnNj1OLqCclOmmvORxjL4fY9GnV2gU3FMVaBDvwccaVysRUwADG9w7PeGb4EEVeVqUhS51MoDaai2CpVx65qcBfejbjLBSY698EjFFeCvzJRyUcsjiHO(Izz(sSnGbGn3Z7L6lRHniPcLGKYna6lRHniPc1WDKuIB(2EshyVH(759s9KA(cSD6sqs5glZvWodgddesDkKIjV4yU3j9vHOfdQleeDbJ5vWyqDHCpyZRnfdkkJIX6vlgRNIj)FwkM6fddSYsWyEWcjguxi3d28AJHxN1WXO4y0ngbhKRlfdUJKsgJbxXi4GCDPyWDKuIJrHum1krlML4egRq0IXFXy9QfJPsATyCCmBzXCWeykyx5MxloXlK7bBETTUEftOpdd51zncI7iPKr)LbEw6vqGuc0XCVt6RcrRXleeDbb4EEVeOJ5EN0xfIwJxii6cMaRSla3Z7LaDm37K(Qq0A8cbrxWMc56sjWk7caVkjyLDt3Z71aDm37K(Qq0A8cbrxWeKuq0aGnMkP1sWZsT616QSemyx5MxloXlK7bBETTUEftOpddvixxQr50jlSxlJ(ld8S0RGaPeOJ5EN0xfIwJxii6ccW98EjqhZ9oPVkeTgVqq0fmbwzxaUN3lb6yU3j9vHO14fcIUGnfY1LsGv2faEvsWk7MUN3Rb6yU3j9vHO14fcIUGjiPGObaBmvsRLGNLA1R1vzjyWUYnVwCIxi3d28ABD9kMqFgg(Gf2UL0y0FzGNLEfeiLaDm37K(Qq0A8cbrxqaUN3lb6yU3j9vHO14fcIUGjWk7cW98EjqhZ9oPVkeTgVqq0fS9Gf2sGv2nyx5MxloXlK7bBETTUEftOpddFWcBTTyQm6VmWZsVccKsaHowIwZ5oxsaCpVxIxi3d28AtGv2nyx5MxloXlK7bBETTUEftOpdd5Qu2uU512Ko2yCvekJYnNj1mvsRHd2vU51It8c5EWMxBRRxXe6ZWqEHCpyZRLXdMA171aYbZimJhm1Y27sQXvS5lWmcZO)YCpVxIxi3d28AtGv2faaXg4zPxbbsjqhZ9oPVkeTgVqq0fKvwVN3lb6yU3j9vHO14fcIUGPthRSEpVxc0XCVt6RcrRXleeDbBpyHT0PdatL0Aj4zPw9ADvwccaVkjyLDt3Z71aDm37K(Qq0A8cbrxWeKuq0amaaInWZsVccKsaHowIwZ5oxsSYkiDpVxci0Xs0Ao35skD6amaas5MxBcHmQGjFBpPdS3aq5MxBcHmQGjFBpPdS3Aqcr9fZYmmvORxjL4fY9GnV2gxXwdsiQVywzv5MxBcZliVpr5q8J5lqauU51MW8cY7tuoe)yudsiQVywYuHUELuIxi3d28ABCfBniHO(IzLvLBETPNdPRkLjkhIFmFbcGYnV20ZH0vLYeLdXpg1GeI6lMLmvORxjL4fY9GnV2gxXwdsiQVywzv5MxBQdnyDLk2suoe)y(ceaLBETPo0G1vQylr5q8JrniHO(Izjtf66vsjEHCpyZRTXvS1GeI6lMvwvU51MEsfHWg0fIsuoe)y(ceaLBETPNuriSbDHOeLdXpg1GeI6lMLmvORxjL4fY9GnV2gxXwdsiQVyahSZGXK)SEcgdVkjyLDXXy9QfdUVosWyUumhmbgtw36Jb1fY9GnV2yW91rcgtTs0I5sXCWeymzDRpgDJr52rLXG6c5EWMxBmCfBXOlymBzXK1T(y0yepBmS1(cuaCmOusySVaJPdw8uWUYnVwCIxi3d28ABD9kMqFggYvPSPCZRTjDSX4QiugEHCpyZRTXRscwzxmJ(lZ98EjEHCpyZRnbje1xSGYDSYkVkjyLDt8c5EWMxBcsiQVywY2b7k38AXjEHCpyZRT11Ryc9zy4tQie2GUqeJ(ldGUN3l1xwdBqsfkbjLBaOCZzsnAjeNWckdtf66vsjEHCpyZRT9KkcHnOlebywzfq3Z7LEoKWwbrsqs5gak3CMuJwcXjSGYWuHUELuIxi3d28ABpPIqyd6cr5h8S0RGaP0ZHe2kicGd2vU51It8c5EWMxBRRxXe6ZWWo0G1vQyJr)L5EEVe(SnH8fiUDLeg7lWgKuq0sNoaUN3lHpBtiFbIBxjHX(cSbjfeTeKquFXcIRyRzocfSRCZRfN4fY9GnV2wxVIj0NHHDObRRuXgJ(lZ98EPNdjSvqKeKuUfSRCZRfN4fY9GnV2wxVIj0NHHDObRRuXgJ(lZ98EPo0GfxQyKeKuUbW98EPo0GfxQyKeKquFXcIRyRzocbaGUN3lXlK7bBETjiHO(IfexXwZCeIvwVN3lXlK7bBETjWk7cyauU5mPgTeItywYuHUELuIxi3d28ABpPIqyd6crb7k38AXjEHCpyZRT11Ryc9zyyhAW6kvSXO)YCpVxQVSg2GKkucsk3a4EEVeVqUhS51MoDb7k38AXjEHCpyZRT11Ryc9zyyhAW6kvSXO)Y0bjMnGCWKWjmVG8EaUN3l1tQ5lW2PlbjLBaOCZzsnAjeNWSKPcD9kPeVqUhS512EsfHWg0fIc2zWyyRW(cmgXE)z(cmggyLLGXaEG(cmguxi3d28AJXQyGe2kifdl6qkgukvSfJUGXWa7lA9CIHfLkcfdVxHajCmCDJ5sXCPLEo3vjJXCpwmh8rLs0IPwjAXuBmcUk3Kc2vU51It8c5EWMxBRRxXe6ZWqCV)mFb26QSeKr)L5EEVeVqUhS51MoDaWgLBETPNdP2vQylX7viqcdGYnNj1OLqCclOmmvORxjL4fY9GnV2gU3FMVaBDvwccGYnV2uxFrRNt7jvecNEhPSbjEVcbsnZrib9oszdsGhU51YOVgbHNoR5Vmk38AtphsTRuXwI3RqGeoJYnV20ZHu7kvSLq0CA8EfcKWb7k38AXjEHCpyZRT11Ryc9zyyxFrRNt7jvecZO)YCpVxIxi3d28AtNoamOYKKnZriwEpVxIxi3d28Atqcr9fdaGaKYnV20ZHu7kvSL49keiHzPWayQKwl1HgS4sfJaGYnNj1OLqCcNryaZkRSXujTwQdnyXLkgHvwvU5mPgTeItybjmGb4EEVupPMVaBNUeKuUH((YAydsQqnChjL4MVTN0b2BSmxb7k38AXjEHCpyZRT11Ryc9zy4tQie2GUqeJ(lZ98EjEHCpyZRnbwzxa4vjbRSBIxi3d28Atqcr9fZsUITM5ieak3CMuJwcXjSGYWuHUELuIxi3d28ABpPIqyd6crb7k38AXjEHCpyZRT11Ryc9zy4ZH0vLsg9xM759s8c5EWMxBcSYUaWRscwz3eVqUhS51MGeI6lMLCfBnZriaydVwWJBPNurOMY5qY8Ad2vU51It8c5EWMxBRRxXe6ZWqmVG8Eg9xM759s8c5EWMxBcsiQVybXvS1mhHa4EEVeVqUhS51MoDSY698EjEHCpyZRnbwzxa4vjbRSBIxi3d28Atqcr9fZsUITM5iuWUYnVwCIxi3d28ABD9kMqFggkDM(cSDlKlJ(lZ98EjEHCpyZRnbje1xmlbYbtiAoaOCZzsnAjeNWcs4GDLBET4eVqUhS51266vmH(mmeeQaRf3UqsTEg9xM759s8c5EWMxBcsiQVywcKdMq0Ca4EEVeVqUhS51MoDb7k38AXjEHCpyZRT11Ryc9zyiMxqEpJ(lJPqGKL6jvA9PoUXYmcw(aWujTwctk0xGnRo8(G9GDLBET4eS6AD9kMY8KkcHnOleXO)YOCZzsnAjeNWckdtf66vsP(YAydsQqTNuriSbDHiaa098EP(YAydsQqjiPCJvwVN3l9CiHTcIKGKYnahSRCZRfNGvxRRxXe6ZWWo0G1vQyJr)L5EEVe(SnH8fiUDLeg7lWgKuq0sNoaUN3lHpBtiFbIBxjHX(cSbjfeTeKquFXcIRyRzocfSRCZRfNGvxRRxXe6ZWWo0G1vQyJr)L5EEV0ZHe2kiscsk3c2vU51ItWQR11Ryc9zyyhAW6kvSXO)YCpVxQVSg2GKkucsk3c2zWyyRWum1sXWIoKIbLsfBXqkuIwm(gt(VyGX4VyqRoXawRawm9ktkgYTEcgtEJuZxGXWw1ftbJjVvwmIgKuHIbnYIrxWyi36jiledGuahtVYKIbPGumwVUXyzRyujKuq0ymgaDbCm9ktkgbNKYbBqfNxtfahdlEGOfdKuq0IXQyoyIXykymaId4yejf6lWyqvD49X44yuU5mPum5LAfWIbSIX6DCmz7DjftVcbJHRyZxGXWIsfHWg0fIWXuWyY2tBmINng2AFbkaogukjm2xGX44yGKcIwkyx5MxlobRUwxVIj0NHHphsTRuXgJhm1Q3RbKdMrygpyQLT3LuJRyZxGzeMr)LHnmvORxjLEoKAxPITwxvsFbcW98Ej8zBc5lqC7kjm2xGniPGOLaRSlak3CMuJwcXjmlzQqxVsk1RqWgxXw7jvecBqxica28CiHnfAemPCZzsaai2CpVxQNuZxGTtxcsk3aGn3Z7L6lRHniPcLGKYnaythKy2Q3RbKdMEoKAxPInaaKYnV20ZHu7kvSL49keiHfuMCXkRaYujTwsLuoydQ48AkU9oq0aGxLeSYUjqOcSwC7cj16tqsbrdWSYkGmvsRLWKc9fyZQdVhatHajl1tQ06tDCJLzeS8byad4GDgmg2kmfdl6qkgukvSfd5wpbJb8a9fymAmSOdPRkLmKbIgSUsfBXWvSft2EAJjVrQ5lWyyR6IXXXOCZzsXuWyapqFbgdLdXpgftw36JrKuOVaJbv1H3Nc2vU51ItWQR11Ryc9zy4ZHu7kvSX4btT69Aa5GzeMXdMAz7Dj14k28fygHz0Fzydtf66vsPNdP2vQyR1vL0xGaWMNdjSPqJGjLBotcaabiaPCZRn9CiDvPmr5q8J5lqaaKYnV20ZH0vLYeLdXpg1GeI6lML5lX2SYkBGNLEfeiLEoKWwbramRSQCZRn1HgSUsfBjkhIFmFbcaGuU51M6qdwxPITeLdXpg1GeI6lML5lX2SYkBGNLEfeiLEoKWwbramGb4EEVupPMVaBNUeKuUbywzfqMkP1sysH(cSz1H3dGPqGKL6jvA9PoUXYmcw(aaq3Z7L6j18fy70LGKYnayJYnV2eMxqEFIYH4hZxGSYkBUN3l1xwdBqsfkbjLBaWM759s9KA(cSD6sqs5gak38AtyEb59jkhIFmFbcaB6lRHniPc1WDKuIB(2EshyVbyad4GDLBET4eS6AD9kMqFggYvPSPCZRTjDSX4QiugLBotQzQKwdhSRCZRfNGvxRRxXe6ZWWo0G1vQyJr)L5EEVuhAWIlvmscsk3aGRyRzocXY759sDOblUuXijiHO(IbGRyRzocXY759sWZsT616QSembje1xCWUYnVwCcwDTUEftOpdd7qdwxPIng9xMoiXSbKdMeoH5fK3dW98EPEsnFb2oDjiPCdatL0AjmPqFb2S6W7bWuiqYs9KkT(uh3yzgblFaOCZzsnAjeNWSKPcD9kPuFznSbjvO2tQie2GUquWUYnVwCcwDTUEftOpdd76lA9CApPIqyg9xg2WuHUELuQRVO1ZP1vL0xGaCpVxQNuZxGTtxcsk3aGn3Z7L6lRHniPcLGKYnaaKYnNj1all5ax3iwMlwzv5MZKA0sioHfugMk01RKs9keSXvS1EsfHWg0fIyLvLBotQrlH4ewqzyQqxVsk1xwdBqsfQ9KkcHnOleb4GDLBET4eS6AD9kMqFggI5fK3ZO)YykeizPEsLwFQJBSmJGLpamvsRLWKc9fyZQdVpyx5MxlobRUwxVIj0NHHGqfyT42fsQ1ZO)YOCZzsnAjeNWckxb7k38AXjy1166vmH(mmuHCDPgLtNSWETm6Vmk3CMuJwcXjSGYWuHUELusHCDPgLtNSWETaGORM64MGYWuHUELusHCDPgLtNSWETneD1GDgmg0j36JH26aSpgtHajdZymUfJJJrJbO6BmwfdxXwmSOuriSbDHOyuCmpxkjym(InsbJPEXWIoKUQuMc2vU51ItWQR11Ryc9zy4tQie2GUqeJ(lJYnNj1OLqCclOmmvORxjL6viyJRyR9KkcHnOlefSRCZRfNGvxRRxXe6ZWWNdPRkLb7b7k38AXjSPlOcbBWYuZRnZtQie2GUqeJ(lJYnNj1OLqCclOmmvORxjL6lRHniPc1EsfHWg0fIaaq3Z7L6lRHniPcLGKYnwz9EEV0ZHe2kiscsk3aCWUYnVwCcB6cQqWgSm18ArFgg2HgSUsfBm6Vm3Z7LEoKWwbrsqs5wWUYnVwCcB6cQqWgSm18ArFgg2HgSUsfBm6Vm3Z7L6lRHniPcLGKYnaUN3l1xwdBqsfkbje1xmlvU51MEoKUQuMOCi(XOM5iuWUYnVwCcB6cQqWgSm18ArFgg2HgSUsfBm6Vm3Z7L6lRHniPcLGKYnaauhKy2aYbtcNEoKUQuYkRphsytHgbtk3CMeRSQCZRn1HgSUsfBjFBpPdS3aCWodgdQGOfJvXaKSyezRrzmDWIJJXxSdsXK)lgymD9kMWXuWyqDHCpyZRnMUEft4yY2tBmDfg7xjLc2vU51Itytxqfc2GLPMxl6ZWWo0G1vQyJr)L5EEVe(SnH8fiUDLeg7lWgKuq0sNoaaeVkjyLDtWZsT616QSembje1xm6vU51MGNLA1R1vzjyIYH4hJAMJqONRyRzocjO759s4Z2eYxG42vsySVaBqsbrlbje1xmRSYgtL0Aj4zPw9ADvwccyayQqxVskzoc1SQXlK7bBETONRyRzocjO759s4Z2eYxG42vsySVaBqsbrlbje1xCWUYnVwCcB6cQqWgSm18ArFgg2HgSUsfBm6Vm3Z7L6lRHniPcLGKYnamfcKSupPsRp1XnwMrWYhaMkP1sysH(cSz1H3hSRCZRfNWMUGkeSbltnVw0NHHDObRRuXgJ(lZ98EPo0GfxQyKeKuUbaxXwZCeIL3Z7L6qdwCPIrsqcr9fhSZGXKxoqFbgJ1tXGnDbviymWYuZRLXyQvIwmhmfdl6qkgukvSHJjBpTXy9eAXOqkMTSyUKVaJPRkjbgZRGXK)lgymfmguxi3d28AtXWwHPyyrhsXGsPITyi36jymGhOVaJrJHfDiDvPKHmq0G1vQylgUITyY2tBm5nsnFbgdBvxmoogLBotkMcgd4b6lWyOCi(XOyY6wFmIKc9fymOQo8(uWUYnVwCcB6cQqWgSm18ArFgg(Ci1UsfBmEWuREVgqoygHz8GPw2ExsnUInFbMryg9xg28CiHnfAemPCZzsaWgMk01RKsphsTRuXwRRkPVabaqacqk38Atphsxvktuoe)y(ceaaPCZRn9CiDvPmr5q8JrniHO(Izz(sSnRSYg4zPxbbsPNdjSvqeaZkRk38AtDObRRuXwIYH4hZxGaaiLBETPo0G1vQylr5q8JrniHO(Izz(sSnRSYg4zPxbbsPNdjSvqeadyaUN3l1tQ5lW2PlbjLBaMvwbKPsATeMuOVaBwD49aykeizPEsLwFQJBSmJGLpaa098EPEsnFb2oDjiPCda2OCZRnH5fK3NOCi(X8fiRSYM759s9L1WgKuHsqs5gaS5EEVupPMVaBNUeKuUbGYnV2eMxqEFIYH4hZxGaWM(YAydsQqnChjL4MVTN0b2BagWaoyx5MxloHnDbviydwMAETOpdd7qdwxPIng9xMoiXSbKdMeoH5fK3dW98EPEsnFb2oDjiPCdatL0AjmPqFb2S6W7bWuiqYs9KkT(uh3yzgblFaOCZzsnAjeNWSKPcD9kPuFznSbjvO2tQie2GUquWUYnVwCcB6cQqWgSm18ArFgg21x0650EsfHWm6VmSHPcD9kPuxFrRNtRRkPVabaqSXujTw6blKM1tnf3tywzv5MZKA0sioHfKWagaaPCZzsnWYsoW1nIL5IvwvU5mPgTeItybLHPcD9kPuVcbBCfBTNuriSbDHiwzv5MZKA0sioHfugMk01RKs9L1WgKuHApPIqyd6craoyx5MxloHnDbviydwMAETOpdd5Qu2uU512Ko2yCvekJYnNj1mvsRHd2vU51Itytxqfc2GLPMxl6ZWqqOcSwC7cj16z0FzuU5mPgTeItybjCWUYnVwCcB6cQqWgSm18ArFggI5fK3ZO)YykeizPEsLwFQJBSmJGLpamvsRLWKc9fyZQdVpyx5MxloHnDbviydwMAETOpddvixxQr50jlSxlJ(lJYnNj1OLqCclOmmvORxjLuixxQr50jlSxlai6QPoUjOmmvORxjLuixxQr50jlSxBdrxnyNbJbDYT(yOToa7JXuiqYWmgJBX44y0yaQ(gJvXWvSfdlkvecBqxikgfhZZLscgJVyJuWyQxmSOdPRkLPGDLBET4e20fuHGnyzQ51I(mm8jvecBqxiIr)Lr5MZKA0sioHfugMk01RKs9keSXvS1EsfHWg0fIc2vU51Itytxqfc2GLPMxl6ZWWNdPRkLF7B)pa]] )

end
