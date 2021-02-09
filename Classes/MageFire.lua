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


    spec:RegisterPack( "Fire", 20210208, [[de1H4dqius9iqfDjqfQ2ea9jc0OuH6uaWQavIxHcmluOBPcj7IQ(fkOHbG6yeultfINHssttfK6Aeq2MkKY3aviJdajNduj16qj08qj6Euj7Ja8pviv6GOe0cbf9qqPMOki6IQGWgrjXhbvOmsaeDscOALOu9scOyMGk1nvbj2jOWpbqQHcQGLcGWtj0ubLCvcO0wvbj9vqLKXQcQ9QQ(RKgSIdtAXQ0Jr1Kb6YiBwv(mGgTk60IwTkKQEnbz2eDBq2Ts)wQHtfhhLalhYZHA6uUUeBhf9DQuJxf48GQwVkKkMpkL9l8x4pS(IGQrFyCea(icdWhbGbO8cdxZQhnbs4VObVd9fDuUqkq6lUke9fzLerFrhfEzRGFy9fXDbXPV4PzoywKHmeyANLRN3qmeNqfPAzVCK(mgItiod)I3sknb((VFrq1OpmocaFeHb4JaWauEHHRz1J2HgG6lQf7SrFrXec2FXZeeK2)9lcsy(xeoHZyyLerXCOOaPGD4eoJ50mhmlYqgcmTZY1ZBigItOIuTSxosFgdXjeNHb7WjCgdRqxurrWhdafJXCea(ichShSdNWzmW(uxGeMfd2Ht4mMJkgbwmfZlbEAvebP5IJbP2jHIXo1ngtrajZBjevTUcMumVgfJuX2rHjEVGXO3uMg8XuWkqc7d2Ht4mMJkg4UBmTXWvSfdIybLerq0A4yEnkgy3q3c2YEJ540tEgJbSxbTyoBjymPfZRrXOX8qe(mMdfYOgfdxXga8b7WjCgZrfZHy1RKIbBOKBXWpjUq5cmMEJrJ5rUJ51iHWXKBm2jfdleoa3XyDmicSWPyC3iHKTc6d2Ht4mMJkgwi4rFbBXOXahGh1xPITyO1qWhJDQwmGnHJzBlgOgKKX4MKYyY9OaQqumhJtOymcBeymQfZ2XGtGB(sUUwmhs4GymjKJYna4d2Ht4mMJkgy3ltczXOszm3Y75pShrk3IHwdLeogRJ5wEp)H9fhgJr3yujuJTyYfNa38LCDTyoKWbXyaQ5gtUXGtiS)lktSH)W6lYBOBbBzVvNtftFy9HHWFy9fPvVsc8dZVihLgHs9lElVNN3q3c2YE9GT79lQCl79lktGNgUE0xabcrR9TpmoYhwFrA1RKa)W8lwWu19zkPkxXwUa)Wq4ViiH5O0XYE)IhcSLqQrXC2UJr2lWyGDdDlyl7ng3PugJuXwm2PUcHJX6yelBmcm5cuqCmWusyCUaJX6yajJqq5sXC2UJHvsefdmLk2WXGp7IemMlftbtG(Vy78fXK9f5O0iuQFrEVGL085(i0QYkxXCfK80Qxjb(fzQYc9fVL3ZZBOBbBzVEebP5IJHbXClVNN3q3c2YE9GfKAzVXaxI54y4DlbB3RN3q3c2YE9icsZfhdlJ5wEppVHUfSL96reKMloga8flyQ2Vxfih8ddH)Ik3YE)ImvuQxj9fzQO6Qq0xKoWOfKaR8g6wWw2BfrqAU4V9HbR(H1xKw9kjWpm)IfmvDFMsQYvSLlWpme(lcsyokDSS3VileeehJDsXawqQL9gt)IXoPyelBmcm5cuqCmWusyCUaJb2n0TGTS3ySog7KIHwWy6xm2jfdVGq0AXa7g6wWw2Bm5lg7KIHRylg3DrcgdVHCKKrXawq5cmg7mXXa7g6wWw2R)l2oFrfe8lYrPrOu)I8EblP5Z9rOvLvUI5ki5PvVscmgaJ54yUL3ZJlBvOCbIRxjHX5cSIifeEFXjg2ylgMkk1RK80bgTGeyL3q3c2YERicsZfhJaIryVafdCjgGCqpKEqmWLyooMB5984YwfkxG46vsyCUa9q6bvSPCHI5OI5wEppUSvHYfiUELegNlqp2uUqXaGyaWxKPkl0xKPIs9kjpwOBfSGul79lwWuTFVkqo4hgc)fvUL9(fzQOuVs6lYur1vHOViDGrlibw5n0TGTS3kIG0CXF7dJd9hwFrA1RKa)W8lYrPrOu)I3Y755n0TGTSxpy7E)Ik3YE)IxfyTFvdLCHWF7ddb6dRViT6vsGFy(f5O0iuQFrLBjtQslbLeogbeJWXaym3Y755n0TGTSxpy7E)Ik3YE)IYKzUaR3g6(TpmoAFy9fPvVsc8dZVybtv3NPKQCfB5c8ddH)ICuAek1ViRJH3lyjnFUpcTQSYvmxbjpT6vsGXaym8tfbKWXiaxXiCmagZT8EEEdDlyl71xCIbWyyDm3Y75FjIWwJG8fNyamgwhZT8E(Z2QydrQq(ItmagZzBvSHivOk2HKsCn36tMapTyyqm3Y75pj1YfyT44loXWYyoYxSGPA)EvGCWpme(lQCl79l(sevVsfBFrqcZrPJL9(fHRs7Slwmc89rOvLXaBfZvqIXyo6lylMcMIHvsefdmLk2WX4(K2yStc(yC3RGwmqLLFgdhLgogDbJX9jTXWkjIWwJGIjXXa2Ux)3(Wao6dRViT6vsGFy(flyQ6(mLuLRylxGFyi8xeKWCu6yzVFr4Q0oJrGVpcTQmgyRyUcsmgdRKikgykvSftbtXGp7IemMlfJccMw2RkLWhdVxSH0CjWyWDm2PAXKwmjoMTTyUumfmbgtzLeghJaFFeAvzmWwXCfKIjXXO3UyXyDm0bojIIPrXyNeIIrrumqnIIXo1ngA7cWZyyLerXatPInCmwhdDGrlymc89rOvLXaBfZvqkgRJXoPyOfmM(fdSBOBbBzV(Vy78fXK9f5O0iuQFrEVGL085(i0QYkxXCfK80Qxjb(fzQYc9fvUL96FjIQxPInp)urajC9HuUL9QYyyqmhhdtfL6vsE6aJwqcSYBOBbBzVvebP5IJ5OI5wEpFUpcTQSYvmxbjpybPw2BmaigggdVBjy7E9Ver1RuXMhSGul79lwWuTFVkqo4hgc)fvUL9(fzQOuVs6lYur1vHOViDGdXncS(sevVsfB4V9Hba1hwFrA1RKa)W8l2oFrmzFrLBzVFrMkk1RK(Ifmv73RcKd(HHWFrMkQUke9fxIajW6lru9kvSH)ICuAek1ViVxWsA(CFeAvzLRyUcsEA1RKa)IfmvDFMsQYvSLlWpme(lYuLf6lYPugZXXWurPELKNoWOfKaR8g6wWw2BfrqAU4yyymhhZT8E(CFeAvzLRyUcsEWcsTS3yoQyaYb9q6bXaGyaW3(WaU(dRViT6vsGFy(flyQ6(mLuLRylxGFyi8xKJsJqP(f59cwsZN7JqRkRCfZvqYtRELeymagd)urajCmcWvmchdGXCCmmvuQxj5PdCiUrG1xIO6vQydhJaCfdtfL6vs(LiqcS(sevVsfB4yyJTyyQOuVsYthy0csGvEdDlyl7TIiinxCmS0vm3Y75Z9rOvLvUI5ki5bli1YEJHn2I5wEpFUpcTQSYvmxbjp2uUqXWYyosmSXwm3Y75Z9rOvLvUI5ki5reKMlogwgdqoOhspig2ylgE3sW296XN5ZYfy1PDtipIuq4JbWyuULmPkTeus4yeGRyyQOuVsYZBOBbBzVv8z(SCbwDA3ekgaJH3mPvxZVjWtR(ukgaedGXClVNN3q3c2YE9fNyamMJJH1XClVN)LicBncYxCIHn2I5wEpFUpcTQSYvmxbjpIG0CXXWYyayVafdaIbWyyDm3Y75pBRInePc5loXaymNTvXgIuHQyhskX1CRpzc80IHbXClVN)KulxG1IJV4edlJ5iFXcMQ97vbYb)Wq4VOYTS3V4lru9kvS9TpmegG)W6lsRELe4hMFrLBzVFrExwJqyhsk)IGeMJshl79lchqKJIOyoKjMNoYCve8Xa7gcsxWyEnkgy3q3c2YE9XaJ2OySt1IXoPyaiklft)Ibo0UjumpudfdSBOBbBzVXW7YA4yuCm6gdleX1LIb7qsjJXG7yyHiUUumyhskXXOikMELWhZsCcJve8XKVySt1IXujTwmjoMTTykyc0)f5O0iuQFruzPxJasEWeZthzUkc(kVHG0f0tRELeymagZT8EEWeZthzUkc(kVHG0f0d2U3yamMB598GjMNoYCve8vEdbPlyvrCDjpy7EJbWy4DlbB3R)wEVkyI5PJmxfbFL3qq6c6rKccFmagdRJXujTMhvwQ2VQt7MqEA1RKa)2hgcl8hwFrA1RKa)W8lYrPrOu)IOYsVgbK8GjMNoYCve8vEdbPlONw9kjWyamMB598GjMNoYCve8vEdbPlOhSDVXaym3Y75btmpDK5Qi4R8gcsxWQI46sEW29gdGXW7wc2Ux)T8EvWeZthzUkc(kVHG0f0Jife(yamgwhJPsAnpQSuTFvN2nH80Qxjb(fvUL9(fvexxQsh4iBC273(Wq4J8H1xKw9kjWpm)ICuAek1ViQS0RrajpyI5PJmxfbFL3qq6c6PvVscmgaJ5wEppyI5PJmxfbFL3qq6c6bB3BmagZT8EEWeZthzUkc(kVHG0fS(qn28GT79lQCl79l(qn2UT0(2hgcZQFy9fPvVsc8dZVihLgHs9lIkl9AeqYdeLyj81KNCj5PvVscmgaJ5wEppVHUfSL96bB37xu5w27x8HASv3MP(Tpme(q)H1xKw9kjWpm)Ik3YE)ICvkRk3YERYeBFrzIT6Qq0xu5wYKQMkP1WF7ddHfOpS(I0Qxjb(H5xSGPQ7ZusvUITCb(HHWFrokncL6x8wEppVHUfSL96bB3BmagZXXW6yqLLEnci5btmpDK5Qi4R8gcsxqpT6vsGXWgBXClVNhmX80rMRIGVYBiiDb9fNyyJTyUL3ZdMyE6iZvrWx5neKUG1hQXMV4edGXyQKwZJklv7x1PDtipT6vsGXaym8ULGT71FlVxfmX80rMRIGVYBiiDb9isbHpgaedGXCCmSoguzPxJasEGOelHVM8KljpT6vsGXWgBXas3Y75bIsSe(AYtUK8fNyaqmagZXXOCl71drg1iFU1NmbEAXaymk3YE9qKrnYNB9jtGNwfrqAU4yyPRyyQOuVsYZBOBbBzVvUITkIG0CXXWgBXOCl71J5nIF6PdiEXYfymagJYTSxpM3i(PNoG4fJQicsZfhdlJHPIs9kjpVHUfSL9w5k2QicsZfhdBSfJYTSx)lr0vLspDaXlwUaJbWyuUL96FjIUQu6PdiEXOkIG0CXXWYyyQOuVsYZBOBbBzVvUITkIG0CXXWgBXOCl717apQVsfBE6aIxSCbgdGXOCl717apQVsfBE6aIxmQIiinxCmSmgMkk1RK88g6wWw2BLRyRIiinxCmSXwmk3YE9pPcrydLcrE6aIxSCbgdGXOCl71)KkeHnuke5PdiEXOkIG0CXXWYyyQOuVsYZBOBbBzVvUITkIG0CXXaGVybt1(9Qa5GFyi8xu5w27xK3q3c2YE)2hgcF0(W6lsRELe4hMFrqcZrPJL9(fbOTtcfdVBjy7EXXyNQfd(SlsWyUumfmbgJ70oJb2n0TGTS3yWNDrcgtVs4J5sXuWeymUt7mgDJr5wrLXa7g6wWw2BmCfBXOlymBBX4oTZy0yelBmcm5cuqCmWusyCUaJXb1C)xu5w27xKRszv5w2BvMy7lYrPrOu)I3Y755n0TGTSxpIG0CXXiGyaOIHn2IH3TeSDVEEdDlyl71JiinxCmSmgb6lktSvxfI(I8g6wWw2BL3TeSDV4V9HHWWrFy9fPvVsc8dZVihLgHs9lECm3Y75pBRInePc5loXaymk3sMuLwckjCmcWvmmvuQxj55n0TGTS36tQqe2qPqumaig2ylMJJ5wEp)lre2AeKV4edGXOClzsvAjOKWXiaxXWurPELKN3q3c2YERpPcrydLcrXCuXGkl9AeqY)seHTgb5PvVscmga8fvUL9(fFsfIWgkfI(2hgcdq9H1xKw9kjWpm)ICuAek1V4T8EECzRcLlqC9kjmoxGvePGW7loXaym3Y75XLTkuUaX1RKW4CbwrKccVhrqAU4yeqmCfBvlHOVOYTS3VOd8O(kvS9TpmegU(dRViT6vsGFy(f5O0iuQFXB598VeryRrq(IZxu5w27x0bEuFLk2(2hghbG)W6lsRELe4hMFrokncL6x8wEpVd8OMlvmKV4edGXClVN3bEuZLkgYJiinxCmcigUITQLqumagZXXClVNN3q3c2YE9icsZfhJaIHRyRAjefdBSfZT8EEEdDlyl71d2U3yaqmagJYTKjvPLGschdlJHPIs9kjpVHUfSL9wFsfIWgkfI(Ik3YE)IoWJ6RuX23(W4ic)H1xKw9kjWpm)ICuAek1V4T8E(Z2QydrQq(ItmagZT8EEEdDlyl71xC(Ik3YE)IoWJ6RuX23(W4ih5dRViT6vsGFy(f5O0iuQFrheXScKd6f2J5nIFgdGXClVN)KulxG1IJV4edGXOClzsvAjOKWXWYyyQOuVsYZBOBbBzV1NuHiSHsHOVOYTS3VOd8O(kvS9TpmocR(H1xKw9kjWpm)Ik3YE)I4Z8z5cS60Uj0xmxJqOIJvZ3xu5w2R)LiQELk288tfbKWUuUL96FjIQxPInpKEqLFQiGe(lYrPrOu)I3Y755n0TGTSxFXjgaJH1XOCl71)sevVsfBE(PIas4yamgLBjtQslbLeogb4kgMkk1RK88g6wWw2BfFMplxGvN2nHIbWyuUL96DoBAZdQpPcry)RiLveXpveqQAjefJaI5vKYkIalCl79lcsyokDSS3VOaloxGXiEMplxGXahA3ekgWckxGXa7g6wWw2BmwhdIWwJOyyLerXatPITy0fmg4WztBEqmSIuHOy4NkciHJHRBmxkMlT0l5PkzmMBXIPGlQucFm9kHpMEJHf2hc)3(W4ih6pS(I0Qxjb(H5xKJsJqP(fVL3ZZBOBbBzV(ItmagJHuMKSAjefdlJ5wEppVHUfSL96reKMlogaJ54yoogLBzV(xIO6vQyZZpveqchdlJr4yamgtL0AEh4rnxQyipT6vsGXaymk3sMuLwckjCmUIr4yaqmSXwmSogtL0AEh4rnxQyipT6vsGXWgBXOClzsvAjOKWXiGyeogaedGXClVN)KulxG1IJV4eddI5STk2qKkuf7qsjUMB9jtGNwmSmMJ8fvUL9(fDoBAZdQpPcr4V9HXreOpS(I0Qxjb(H5xKJsJqP(fVL3ZZBOBbBzVEW29gdGXW7wc2UxpVHUfSL96reKMlogwgdxXw1sikgaJr5wYKQ0sqjHJraUIHPIs9kjpVHUfSL9wFsfIWgkfI(Ik3YE)IpPcrydLcrF7dJJC0(W6lsRELe4hMFrokncL6x8wEppVHUfSL96bB3BmagdVBjy7E98g6wWw2RhrqAU4yyzmCfBvlHOyamgwhdVxWsA(NuHOQY5iYYE90Qxjb(fvUL9(fFjIUQu(TpmocC0hwFrA1RKa)W8lYrPrOu)I3Y755n0TGTSxpIG0CXXiGy4k2QwcrXaym3Y755n0TGTSxFXjg2ylMB5988g6wWw2RhSDVXaym8ULGT71ZBOBbBzVEebP5IJHLXWvSvTeI(Ik3YE)IyEJ4NF7dJJaq9H1xKw9kjWpm)ICuAek1V4T8EEEdDlyl71JiinxCmSmgGCqpKEqmagJYTKjvPLGschJaIr4VOYTS3VOmzMlW6THUF7dJJax)H1xKw9kjWpm)ICuAek1V4T8EEEdDlyl71JiinxCmSmgGCqpKEqmagZT8EEEdDlyl71xC(Ik3YE)IGifyV46frQD(Tpmyva(dRViT6vsGFy(f5O0iuQFrtrajZFsQ0o9oClgw6kgwfGJbWymvsR5XKIYfy16c)0tRELe4xu5w27xeZBe)8BF7lcspTiTpS(Wq4pS(I0Qxjb(H5xKJsJqP(fzDmOYsVgbK8GjMNoYCve8vEdbPlONw9kjWVOYTS3ViVlRriSdjLF7dJJ8H1xKw9kjWpm)ITZxet2xu5w27xKPIs9kPVitvwOVOPsAn)lre2uKripT6vsGXaxI5LicBkYiKhrqAU4yyqmhhdVBjy7E98g6wWw2RhrqAU4yGlXCCmchZrfdtfL6vsEHYfuMlWkIalCl7ng4smMkP18cLlOmxGEA1RKaJbaXaGyGlXW6y4DlbB3RN3q3c2YE9isbHpg4sm3Y755n0TGTSxpy7E)IGeMJshl79lEOQOuVskg7uTy49AOwIJX9jTXa7g6wWw2BmjoMcMa9XaRZehJmxkgmz4yGDdDlyl7ngRJ5sXuWeym6ZiumSsIiSPiJqXOlymQJJmjCm2jfJq5ckZfyfrGfUL9gdtfL6vsXyDm2jfdIG0CZfym8ULGT7nM(fdSBOBbBzV(yyHGGPL9Qsj8mgt(Ib2n0TGTS3ysCmGjwVscmg7mXXC0xWwmyYWXyNummvuQxjfJ1XOXyjefJJITyStkgAbJPFXyNum4eQivl71)fzQO6Qq0x0siQADL3q3c2YE)2hgS6hwFrA1RKa)W8l2oFri9GVOYTS3VitfL6vsFrMkQUke9fTeIQwx5n0TGTS3VihLgHs9lsSGs64qGEcYbEePYAJaxD50xeKWCu6yzVFXdfvikgCbrXa7g6wWw2BmjogqsQWtGXKVywIajWyUkMaJP3yStkgcYbEePYAJaxD5ufKKk8XWurPELK)lYuLf6lYurPELKNGCGhrQS2iWvxovbjPcFmhvmhhdVBjy7E9eKd8isL1gbU6YjpybPw2Bmhvm8ULGT71tqoWJivwBe4QlN8icsZfhdaIbUedRJH3TeSDVEcYbEePYAJaxD5Khrki8F7dJd9hwFrA1RKa)W8l2oFri9GVOYTS3VitfL6vsFrMkQUke9fTeIQwx5n0TGTS3VihLgHs9lAQKwZJklv7x1PDtipT6vsGXaym3Y755n0TGTSxpy7E)IGeMJshl79lEijPcFmWUHUfSL9gtzTugdardhIHoWjreoM8ftAcIJP44)ImvzH(I3Y75rLLQ9R60UjKhrqAU4V9HHa9H1xKw9kjWpm)ITZxesp4lQCl79lYurPEL0xKPIQRcrFrlHOQ1vEdDlyl79lYrPrOu)IMkP18OYs1(vDA3eYtRELeymagZT8EEEdDlyl71d2U3yamgE3sW296rLLQ9R60UjKhrqAU4yyqmcumSmgMkk1RK8wcrvRR8g6wWw27xeKWCu6yzVFXdjjv4Jb2n0TGTS3yEnkgDJHoWqAmaeLLIPFXahA3ekM8fJDsXaquwkM(fdCODtOyC3fjym8gIIPFVy4DlbB3BmQfJKuSfJafdM49cIJ5sVgrXa7g6wWw2BmU7Ie0)fzQYc9f5DlbB3RhvwQ2VQt7MqEebP5IJHbXClVNhvwQ2VQt7MqEWcsTS3V9HXr7dRViT6vsGFy(fBNViKEWxu5w27xKPIs9kPVitfvxfI(IwcrvRR8g6wWw27xKJsJqP(frLLEnci5btmpDK5Qi4R8gcsxqpT6vsGXaym3Y75btmpDK5Qi4R8gcsxqpy7E)IGeMJshl79lEijPcFmWUHUfSL9gt(I5qMyE6iZvrWhdSBiiDbJXDxKGXSTfZLIbrki8X8AumPfd8K5)ImvzH(I8ULGT71FlVxfmX80rMRIGVYBiiDb9icsZf)TpmGJ(W6lsRELe4hMFX25lIj7lQCl79lYurPEL0xKPkl0x84yuULmPkTeus4yyzmmvuQxj55n0TGTS3k(mFwUaRoTBcfdBSfJYTKjvPLGschdlJHPIs9kjpVHUfSL9wFsfIWgkfIIHn2IHPIs9kjVLqu16kVHUfSL9gZrfJYTSxp(mFwUaRoTBc5FfPSIiWc3YEJraXW7wc2Uxp(mFwUaRoTBc5bli1YEJbaXaymmvuQxj5TeIQwx5n0TGTS3yoQy4DlbB3RhFMplxGvN2nH8icsZfhJaIr5w2RhFMplxGvN2nH8VIuwreyHBzVXaymhhdVBjy7E9OYs1(vDA3eYJiinxCmhvm8ULGT71JpZNLlWQt7MqEebP5IJraXiqXWgBXW6ymvsR5rLLQ9R60UjKNw9kjWyaWxeKWCu6yzVFXdvfL6vsXyNQfdHTesnchJ7tYojumIN5ZYfymWH2nHIXDkLXCPykycmMl9AefdSBOBbBzVXK4yqKccV)lYur1vHOVi(mFwUaRoTBcvV0RruL3q3c2YE)2hgauFy9fPvVsc8dZVihLgHs9lElVNN3q3c2YE9GT7ngaJH1XCCm3Y75Z9rOvLvUI5ki5loXaym3Y75pBRInePc5loXaGyamgMkk1RK84Z8z5cS60Uju9sVgrvEdDlyl79lQCl79lIpZNLlWQt7MqF7dd46pS(I0Qxjb(H5xKJsJqP(fpoMB5988g6wWw2RhSDVXaym3Y75rLLQ9R60UjKhSDVXaymhhdtfL6vsElHOQ1vEdDlyl7ngwgdDaXlgvTeIIHn2IHPIs9kjVLqu16kVHUfSL9gJaIH3TeSDVEKcM6AvSJIeYdwqQL9gdaIbaXWgBXCCm3Y75rLLQ9R60UjKV4edGXWurPELK3siQADL3q3c2YEJraXWQaCma4lQCl79lIuWuxRIDuKqF7ddHb4pS(I0Qxjb(H5xKJsJqP(fVL3ZZBOBbBzVEW29gdGXClVNhvwQ2VQt7MqEW29gdGXWurPELK3siQADL3q3c2YEJHLXqhq8IrvlHOVOYTS3ViiP25Trl9Tpmew4pS(I0Qxjb(H5xKJsJqP(fzQOuVsYBjevTUYBOBbBzVXWsxXWQXaym3Y755n0TGTSxpy7E)Ik3YE)Iqjc1iCTFvRrq0AF7ddHpYhwFrA1RKa)W8lwWu19zkPkxXwUa)Wq4ViiH5O0XYE)ISsJI5qLw7eEeJXuWumAmSsIOyGPuXwm8tfbKIbSGYfymhkjc1iCm9lgy1iiATy4k2IX6yuMDcgdxDCYfym8tfbKW(VOYTS3V4lru9kvS9f5O0iuQFrLBzVEOeHAeU2VQ1iiAnpDaXlwUaJbWyEfPSIi(PIasvlHOyoQyuUL96HseQr4A)QwJGO180beVyufrqAU4yyzmh6yamgwhZzBvSHivOk2HKsCn36tMapTyamgwhZT8E(Z2QydrQq(IZ3(Wqyw9dRViT6vsGFy(fvUL9(fbkvWuTgHRxfei9f5O0iuQFrMkk1RK8wcrvRR8g6wWw2BmcigLBzVvE3sW29gZrfJa9fP3J4wDvi6lcuQGPAncxVkiq6BFyi8H(dRViT6vsGFy(fvUL9(fjih4rKkRncC1LtFrokncL6xKPIs9kjVLqu16kVHUfSL9gdlDfdtfL6vsEcYbEePYAJaxD5ufKKk8FXvHOVib5apIuzTrGRUC6BFyiSa9H1xKw9kjWpm)Ik3YE)IaLW7Cw7xvX4ekLQL9(f5O0iuQFrMkk1RK8wcrvRR8g6wWw2BmcWvmmvuQxj57TwWuLxS(9(IRcrFrGs4DoR9RQyCcLs1YE)2hgcF0(W6lsRELe4hMFrLBzVFriLRxevXNezvOco5FrokncL6xKPIs9kjVLqu16kVHUfSL9gdlDfJa9fxfI(IqkxViQIpjYQqfCY)2hgcdh9H1xKw9kjWpm)IGeMJshl79lkWFXuW5cmgngSrOobJP3JQGPysJGymgv6wHhhtbtXCirKc(sefZHkHXKmMUy4eKIPFXa7g6wWw2RpgaA7KqUtmXymoOSrPLhDOyk4CbgZHerk4lrumhQegtYyCN2zmWUHUfSL9gtVs4JjFXiW3hHwvgdSvmxbPysCm0QxjbgJUGXOXuWkqkg39kOfZLIr2ylMMjHIXoPyali1YEJPFXyNumVe4P5)IRcrFrqePGVervMegtYVihLgHs9lYurPELK3siQADL3q3c2YEJraUIHPIs9kjFV1cMQ8I1VxmagZXXClVNp3hHwvw5kMRGKhBkxOyCfZT8E(CFeAvzLRyUcsEi9Gk2uUqXWgBXW6y49cwsZN7JqRkRCfZvqYtRELeymSXwmmvuQxj55n0TGTS3AV1cMIHn2IHPIs9kjVLqu16kVHUfSL9gddIrGIraX8sGNwfrqAU4yGJhJYTS3kVBjy7EJbaFrLBzVFrqePGVervMegtYV9HHWauFy9fPvVsc8dZViiH5O0XYE)IIDrgJah4MgHIbF2fjymxkMcMaJj3y0yCRWhJDQwmGnHxbTyY1i0JqumUt7mM2ojum9EufmfJHYviYW(yaOTtcfJHYviYWXa2XSTfJHsGajumAm4tfrGXiWH9HmMEJjngJb3XKwmCDJ5sXuWeymOe4PfJ(mcfJUWhtBNekMEpQcMIXq5kez(V4Qq0xe3fznbUPrOVihLgHs9lYurPELK3siQADL3q3c2YEJraUIHvb4yGlXCCmmvuQxj57TwWuLxS(9IraXaWXaGyamMJJH1XqSGs64qGEqePGVervMegtYyyJTy4DlbB3Rherk4lruLjHXK0JiinxCmcigbkga8fvUL9(fXDrwtGBAe6BFyimC9hwFrA1RKa)W8lQCl79lY1LtY6T8EFrokncL6xK1XW7fSKMp3hHwvw5kMRGKNw9kjWyamglHOyyzmcumSXwm3Y75Z9rOvLvUI5ki5XMYfkgxXClVNp3hHwvw5kMRGKhspOInLl0x8wEV6Qq0xe3fznbUPL9(fbjmhLow27xewOeiqcfJyxKXiWbUPrOyifjHpg3PDgJaFFeAvzmWwXCfKIPrX4(K2yslg3kogheXvS5)2hghbG)W6lsRELe4hMFrLBzVFXcMQPrq4ViiH5O0XYE)IcCJGWXyNQfdyhZ2wmxAPxAXa7g6wWw2Bm4ZUibJ5OVGTyUumfmbgtxmCcsX0VyGDdDlyl7ng1Ib3qumoDUM)lYrPrOu)ImvuQxj5TeIQwx5n0TGTS3yeGRyyQOuVsY3BTGPkVy979TpmoIWFy9fPvVsc8dZVOYTS3ViVlRriSdjLFrqcZrPJL9(fHJrwm2jfZHmX80rMRIGpgy3qq6cgZT8EXuCymMYkjmogEdDlyl7nMehdU71)f5O0iuQFruzPxJasEWeZthzUkc(kVHG0f0tRELeymagdVBjy7E93Y7vbtmpDK5Qi4R8gcsxqpIuq4JbWyUL3ZdMyE6iZvrWx5neKUGvfX1L8GT7ngaJH1XClVNhmX80rMRIGVYBiiDb9fNyamgMkk1RK8wcrvRR8g6wWw2BmciMJiqF7dJJCKpS(I0Qxjb(H5xKJsJqP(frLLEnci5btmpDK5Qi4R8gcsxqpT6vsGXaym8ULGT71FlVxfmX80rMRIGVYBiiDb9isbHpgaJ5wEppyI5PJmxfbFL3qq6cwvexxYd2U3yamgwhZT8EEWeZthzUkc(kVHG0f0xCIbWyyQOuVsYBjevTUYBOBbBzVXiGyoIa9fvUL9(fvexxQsh4iBC273(W4iS6hwFrA1RKa)W8lYrPrOu)IOYsVgbK8GjMNoYCve8vEdbPlONw9kjWyamgE3sW296VL3RcMyE6iZvrWx5neKUGEePGWhdGXClVNhmX80rMRIGVYBiiDbRpuJnpy7EJbWyyDm3Y75btmpDK5Qi4R8gcsxqFXjgaJHPIs9kjVLqu16kVHUfSL9gJaI5ic0xu5w27x8HASDBP9TpmoYH(dRViT6vsGFy(f5O0iuQFrMkk1RK8wcrvRR8g6wWw2BmS0vma8xu5w27xKRszv5w2BvMy7lktSvxfI(I8g6wWw2B15uX03(W4ic0hwFrA1RKa)W8lYrPrOu)I3Y75rLLQ9R60UjKhSDVXaymSoMB598VeryRrq(ItmagZXXWurPELK3siQADL3q3c2YEJraUI5wEppQSuTFvN2nH8GfKAzVXaymmvuQxj5TeIQwx5n0TGTS3yeqmk3YE9Ver1RuXM)vKYkI4NkcivTeIIHn2IHPIs9kjVLqu16kVHUfSL9gJaI5LapTkIG0CXXaGVOYTS3ViQSuTFvN2nH(2hgh5O9H1xKw9kjWpm)ITZxet2xu5w27xKPIs9kPVybt1(9Qa5GFyi8xKPIQRcrFXxIO6vQyR60TmxGFrqcZrPJL9(fpuvuQxjfJDQwm8EnulXXWkjIIbMsfBXuWkqkgRJHwCbrXKgog(PIas4yC6wsGX8AumWUHUfSL96)IfmvDFMsQYvSLlWpme(lYuLf6lYurPELK3siQADL3q3c2YEJ5OIHvJHLXOCl71)sevVsfB(xrkRiIFQiGu1sikMJkgLBzVE8z(SCbwDA3eY)kszfrGfUL9gdCjgMkk1RK84Z8z5cS60Uju9sVgrvEdDlyl7ngaJHPIs9kjVLqu16kVHUfSL9gdlJ5LapTkIG0CXF7dJJah9H1xKw9kjWpm)ITZxet2xu5w27xKPIs9kPVitvwOVitfL6vsElHOQ1vEdDlyl7ngwgJYTSxVZztBEq9jvic7FfPSIi(PIasvlHOyoQyuUL96XN5ZYfy1PDti)RiLvebw4w2BmWLyyQOuVsYJpZNLlWQt7Mq1l9Aev5n0TGTS3yamgMkk1RK8wcrvRR8g6wWw2BmSmMxc80QicsZfhdBSfdQS0RrajpUSvHYfiUELegNlqpT6vsGXWgBXyjefdlJrG(IGeMJshl79lEOQOuVskg7uTy49AOwIJboC20MhedRivichtbRaPySogAXfeftA4y4NkciHJrrumoDljWyEnkgy3q3c2YE9FrMkQUke9fDoBAZdQoDlZf43(W4iauFy9fPvVsc8dZVihLgHs9lElVNhvwQ2VQt7Mq(ItmagdtfL6vsElHOQ1vEdDlyl7ngbeda)fXgk52hgc)fvUL9(f5QuwvUL9wLj2(IYeB1vHOViQDQoNkM(2hghbU(dRViT6vsGFy(flyQ6(mLuLRylxGFyi8xeKWCu6yzVFrwi4rFbBXyNummvuQxjfJDQwm8EnulXXWkjIIbMsfBXuWkqkgRJHwCbrXKgog(PIas4yuefJkXDmoDljWyEnkgaIYsX0VyGdTBc5)ITZxet2xKJsJqP(fzDmmvuQxj5FjIQxPITQt3YCbgdGXyQKwZJklv7x1PDtipT6vsGXaym3Y75rLLQ9R60UjKhSDVFrMQSqFrE3sW296rLLQ9R60UjKhrqAU4yyzmk3YE9Ver1RuXM)vKYkI4NkcivTeII5OIr5w2RhFMplxGvN2nH8VIuwreyHBzVXaxI54yyQOuVsYJpZNLlWQt7Mq1l9Aev5n0TGTS3yamgE3sW296XN5ZYfy1PDtipIG0CXXWYy4DlbB3RhvwQ2VQt7MqEebP5IJbaXaym8ULGT71Jklv7x1PDtipIG0CXXWYyEjWtRIiinx8xSGPA)EvGCWpme(lQCl79lYurPEL0xKPIQRcrFXxIO6vQyR60TmxGF7ddwfG)W6lsRELe4hMFXcMQUptjv5k2Yf4hgc)f5O0iuQFrwhdtfL6vs(xIO6vQyR60TmxGXaymmvuQxj5TeIQwx5n0TGTS3yeqmaCmagJYTKjvPLGschJaCfdtfL6vs(tfbw5k2QpPcrydLcrXaymSoMxIiSPiJqELBjtkgaJH1XClVN)STk2qKkKV4edGXCCm3Y75pj1YfyT44loXaymk3YE9pPcrydLcrE6aIxmQIiinxCmSmga2lqXWgBXWpveqcxFiLBzVQmgb4kMJeda(Ifmv73RcKd(HHWFrLBzVFXxIO6vQy7lcsyokDSS3ViC1jTXaqQiqUITCbgdRivikgrdLcrmgdRKikgykvSHJbF2fjymxkMcMaJX6yaslHuJIbGSTyenePcHJrxWySog6aJwWyGPuXgHI5qrXgH8F7ddwv4pS(I0Qxjb(H5xSGPQ7ZusvUITCb(HHWFrokncL6x8LicBkYiKx5wYKIbWy4NkciHJraUIr4yamgwhdtfL6vs(xIO6vQyR60TmxGXaymhhdRJr5w2R)Li6QsPNoG4flxGXaymSogLBzVEh4r9vQyZNB9jtGNwmagZT8E(tsTCbwlo(ItmSXwmk3YE9Verxvk90beVy5cmgaJH1XClVN)STk2qKkKV4edBSfJYTSxVd8O(kvS5ZT(KjWtlgaJ5wEp)jPwUaRfhFXjgaJH1XClVN)STk2qKkKV4eda(Ifmv73RcKd(HHWFrLBzVFXxIO6vQy7lcsyokDSS3V4HSGYfymSsIiSPiJqmgdRKikgykvSHJrrumfmbgdoHsPIKWhJ1Xawq5cmgy3q3c2YE9XahJwcPsj8mgJDsWhJIOykycmgRJbiTesnkgaY2Ir0qKkeog3N0gdhLgog3PugZ2wmxkg3k2iWy0fmg3PDgdmLk2iumhkk2ieJXyNe8XGp7IemMlfd2brkymDXIX6yG0Cnn3yStkgykvSrOyouuSrOyUL3Z)Tpmy1J8H1xKw9kjWpm)IfmvDFMsQYvSLlWpme(lcsyokDSS3VilKzNGXWvhNCbgdRKikgykvSfd)urajCmUptjfd)u3LK5cmgXZ8z5cmg4q7MqFrLBzVFXxIO6vQy7lYrPrOu)Ik3YE94Z8z5cS60UjKNoG4flxGXaymVIuwre)uraPQLqumSmgLBzVE8z(SCbwDA3eYBjxOkIalCl7ngaJ5wEp)zBvSHivipy7EJbWySeIIraXima)Tpmyvw9dRViT6vsGFy(f5O0iuQFrMkk1RK8wcrvRR8g6wWw2BmcigaogaJ5wEppQSuTFvN2nH8GT79lQCl79lYvPSQCl7TktS9fLj2QRcrFrSPlOIaRO2ul79BFyWQh6pS(Ik3YE)IyEJ4NFrA1RKa)W8BF7lIANQZPIPpS(Wq4pS(I0Qxjb(H5xKJsJqP(fvULmPkTeus4yeGRyyQOuVsYF2wfBisfQ(KkeHnukefdGXCCm3Y75pBRInePc5loXWgBXClVN)LicBncYxCIbaFrLBzVFXNuHiSHsHOV9HXr(W6lsRELe4hMFrokncL6x8wEppUSvHYfiUELegNlWkIuq49fNyamMB5984YwfkxG46vsyCUaRisbH3JiinxCmcigUITQLq0xu5w27x0bEuFLk2(2hgS6hwFrA1RKa)W8lYrPrOu)I3Y75FjIWwJG8fNVOYTS3VOd8O(kvS9Tpmo0Fy9fPvVsc8dZVihLgHs9lElVN)STk2qKkKV48fvUL9(fDGh1xPITV9HHa9H1xKw9kjWpm)IfmvDFMsQYvSLlWpme(lYrPrOu)ISogMkk1RK8Ver1RuXw1PBzUaJbWyUL3ZJlBvOCbIRxjHX5cSIifeEpy7EJbWyuULmPkTeus4yyzmmvuQxj5pveyLRyR(KkeHnukefdGXW6yEjIWMImc5vULmPyamMJJH1XClVN)KulxG1IJV4edGXW6yUL3ZF2wfBisfYxCIbWyyDmoiIzTFVkqoO)LiQELk2IbWyoogLBzV(xIO6vQyZZpveqchJaCfZrIHn2I54ymvsR5vjDa2qk(OJIRVccEpT6vsGXaym8ULGT71dIuG9IRxeP2Phrki8XaGyyJTyoogtL0AEmPOCbwTUWp90QxjbgdGXykciz(tsL2P3HBXWsxXWQaCmaigaeda(Ifmv73RcKd(HHWFrLBzVFXxIO6vQy7lcsyokDSS3VOalMIPxkgwjrumWuQylgsrs4Jj3yaiA4qm5lg47smG9kOfZPYKIHs7KqXaqsQLlWyeyDIPrXaq2wmIgIuHIbEYIrxWyO0ojelgZXkaI5uzsXa1ikg7u3ym3DmQerki8mgZXxaeZPYKIHfkPdWgsXhDubXXWkfe8XGife(ySoMcMymMgfZXCaeJiPOCbgdS6c)mMehJYTKj5J5q2RGwmGDm2zIJX9zkPyoveymCfB5cmgwrQqe2qPqeoMgfJ7tAJrSSXiWKlqbXXatjHX5cmMehdIuq49F7dJJ2hwFrA1RKa)W8lwWu19zkPkxXwUa)Wq4VihLgHs9lY6yyQOuVsY)sevVsfBvNUL5cmgaJH1X8seHnfzeYRClzsXaymhhZXXCCmk3YE9Verxvk90beVy5cmgaJ54yuUL96FjIUQu6PdiEXOkIG0CXXWYyayVafdBSfdRJbvw61iGK)LicBncYtRELeymaig2ylgLBzVEh4r9vQyZthq8ILlWyamMJJr5w2R3bEuFLk280beVyufrqAU4yyzmaSxGIHn2IH1XGkl9AeqY)seHTgb5PvVscmgaedaIbWyUL3ZFsQLlWAXXxCIbaXWgBXCCmMkP18ysr5cSADHF6PvVscmgaJXueqY8NKkTtVd3IHLUIHvb4yamMJJ5wEp)jPwUaRfhFXjgaJH1XOCl71J5nIF6PdiEXYfymSXwmSoMB598NTvXgIuH8fNyamgwhZT8E(tsTCbwlo(ItmagJYTSxpM3i(PNoG4flxGXaymSoMZ2QydrQqvSdjL4AU1NmbEAXaGyaqma4lwWuTFVkqo4hgc)fvUL9(fFjIQxPITViiH5O0XYE)IcSykgwjrumWuQylgkTtcfdybLlWy0yyLerxvkziCaEuFLk2IHRylg3N0gdajPwUaJrG1jMehJYTKjftJIbSGYfym0beVyumUt7mgrsr5cmgy1f(P)BFyah9H1xKw9kjWpm)Ik3YE)ICvkRk3YERYeBFrzIT6Qq0xu5wYKQMkP1WF7ddaQpS(I0Qxjb(H5xKJsJqP(fVL3Z7apQ5sfd5loXaymCfBvlHOyyzm3Y75DGh1CPIH8icsZfhdGXWvSvTeIIHLXClVNhvwQ2VQt7MqEebP5I)Ik3YE)IoWJ6RuX23(WaU(dRViT6vsGFy(f5O0iuQFrheXScKd6f2J5nIFgdGXClVN)KulxG1IJV4edGXyQKwZJjfLlWQ1f(PNw9kjWyamgtrajZFsQ0o9oClgw6kgwfGJbWyuULmPkTeus4yyzmmvuQxj5pBRInePcvFsfIWgkfI(Ik3YE)IoWJ6RuX23(Wqya(dRViT6vsGFy(f5O0iuQFrwhdtfL6vsENZM28GQt3YCbgdGXClVN)KulxG1IJV4edGXW6yUL3ZF2wfBisfYxCIbWyoogLBjtQc2MpbUPrXWYyosmSXwmk3sMuLwckjCmcWvmmvuQxj5pveyLRyR(KkeHnukefdBSfJYTKjvPLGschJaCfdtfL6vs(Z2QydrQq1NuHiSHsHOyaWxu5w27x05SPnpO(KkeH)2hgcl8hwFrA1RKa)W8lYrPrOu)IMIasM)KuPD6D4wmS0vmSkahdGXyQKwZJjfLlWQ1f(PNw9kjWVOYTS3ViM3i(53(Wq4J8H1xKw9kjWpm)ICuAek1VOYTKjvPLGschJaI5iFrLBzVFrqKcSxC9Ii1o)2hgcZQFy9fPvVsc8dZVihLgHs9lQClzsvAjOKWXiaxXWurPELKxrCDPkDGJSXzVXaymq6QEhUfJaCfdtfL6vsEfX1LQ0boYgN9wH0v)Ik3YE)IkIRlvPdCKno79BFyi8H(dRViT6vsGFy(fvUL9(fFsfIWgkfI(IGeMJshl79lcxL2zm02fGNXykcizygJjTysCmAma1CJX6y4k2IHvKkeHnukefJIJ5LsjHIjxSrkym9lgwjr0vLs)xKJsJqP(fvULmPkTeus4yeGRyyQOuVsYFQiWkxXw9jvicBOui6BFyiSa9H1xu5w27x8Li6Qs5xKw9kjWpm)23(I8g6wWw2BL3TeSDV4pS(Wq4pS(Ik3YE)IoTL9(fPvVsc8dZV9HXr(W6lQCl79lELDdwFfe8FrA1RKa)W8BFyWQFy9fPvVsc8dZVihLgHs9lElVNN3q3c2YE9fNVOYTS3V4LqycjuUa)2hgh6pS(Ik3YE)IVerxz3GFrA1RKa)W8BFyiqFy9fvUL9(f1LtydPYkxLYViT6vsGFy(TpmoAFy9fPvVsc8dZVihLgHs9lIkl9AeqYBeKtJuz1TIC80QxjbgdGXClVNNo4ulyl71xC(Ik3YE)Iwcrv3kY5BFyah9H1xKw9kjWpm)Ik3YE)IaLkyQwJW1RccK(I07rCRUke9fbkvWuTgHRxfei9TpmaO(W6lsRELe4hMFXvHOVyUyoQy6vsvwqrxRavbjMjN(Ik3YE)I5I5OIPxjvzbfDTcufKyMC6BFyax)H1xKw9kjWpm)IRcrFXNuHOA)Qx1mj9fvUL9(fFsfIQ9REvZK03(Wqya(dRViT6vsGFy(fxfI(IUvHOLq46d1l4xu5w27x0TkeTecxFOEb)2hgcl8hwFrA1RKa)W8lUke9fZfBOc3AeUcMmZLQxsk)Ik3YE)I5InuHBncxbtM5s1ljLF7ddHpYhwFrA1RKa)W8lUke9fXL9k7gSQqKDcp2(Ik3YE)I4YELDdwviYoHhBF7ddHz1pS(Ik3YE)IfmvtJGWFrA1RKa)W8BF7lQClzsvtL0A4pS(Wq4pS(I0Qxjb(H5xKJsJqP(fvULmPkTeus4yeqmchdGXClVNN3q3c2YE9GT7ngaJ54yyQOuVsYBjevTUYBOBbBzVXiGy4DlbB3RxMmZfy92qxpybPw2BmSXwmmvuQxj5TeIQwx5n0TGTS3yyPRya4yaWxu5w27xuMmZfy92q3V9HXr(W6lsRELe4hMFrokncL6xKPIs9kjVLqu16kVHUfSL9gdlDfdahdBSfZXXW7wc2UxpezuJ8GfKAzVXWYyyQOuVsYBjevTUYBOBbBzVXaymSogtL0AEuzPA)QoTBc5PvVscmgaedBSfJPsAnpQSuTFvN2nH80QxjbgdGXClVNhvwQ2VQt7Mq(ItmagdtfL6vsElHOQ1vEdDlyl7ngbeJYTSxpezuJ88ULGT7ng2ylMxc80QicsZfhdlJHPIs9kjVLqu16kVHUfSL9(fvUL9(fHiJA03(WGv)W6lsRELe4hMFrokncL6x0ujTMxL0bydP4JokU(ki490QxjbgdGXCCm3Y755n0TGTSxpy7EJbWyyDm3Y75pBRInePc5loXaGVOYTS3Viisb2lUErKANF7BFrSPlOIaRO2ul79dRpme(dRViT6vsGFy(f5O0iuQFrLBjtQslbLeogb4kgMkk1RK8NTvXgIuHQpPcrydLcrXaymhhZT8E(Z2QydrQq(ItmSXwm3Y75FjIWwJG8fNyaWxu5w27x8jvicBOui6BFyCKpS(I0Qxjb(H5xKJsJqP(fVL3Z)seHTgb5loFrLBzVFrh4r9vQy7BFyWQFy9fPvVsc8dZVihLgHs9lElVN)STk2qKkKV4edGXClVN)STk2qKkKhrqAU4yyzmk3YE9Verxvk90beVyu1si6lQCl79l6apQVsfBF7dJd9hwFrA1RKa)W8lYrPrOu)I3Y75pBRInePc5loXaymhhJdIywbYb9c7FjIUQugdBSfZlre2uKriVYTKjfdBSfJYTSxVd8O(kvS5ZT(KjWtlga8fvUL9(fDGh1xPITV9HHa9H1xKw9kjWpm)Ik3YE)IoWJ6RuX2xeKWCu6yzVFryHGpgRJbizXikWaZyCqnhhtU4eKIbGOHdX4CQychtJIb2n0TGTS3yCovmHJX9jTX40yCELK)lYrPrOu)I3Y75XLTkuUaX1RKW4CbwrKccVV4edGXCCm8ULGT71Jklv7x1PDtipIG0CXXWGyuUL96rLLQ9R60UjKNoG4fJQwcrXWGy4k2QwcrXiGyUL3ZJlBvOCbIRxjHX5cSIifeEpIG0CXXWgBXW6ymvsR5rLLQ9R60UjKNw9kjWyaqmagdtfL6vsElHOQ1vEdDlyl7nggedxXw1sikgbeZT8EECzRcLlqC9kjmoxGvePGW7reKMl(BFyC0(W6lsRELe4hMFrokncL6x8wEp)zBvSHiviFXjgaJXueqY8NKkTtVd3IHLUIHvb4yamgtL0AEmPOCbwTUWp90Qxjb(fvUL9(fDGh1xPITV9HbC0hwFrA1RKa)W8lYrPrOu)I3Y75DGh1CPIH8fNyamgUITQLqumSmMB598oWJAUuXqEebP5I)Ik3YE)IoWJ6RuX23(WaG6dRViT6vsGFy(flyQ6(mLuLRylxGFyi8xKJsJqP(fzDmVerytrgH8k3sMumagdRJHPIs9kj)lru9kvSvD6wMlWyamMJJ54yoogLBzV(xIORkLE6aIxSCbgdGXCCmk3YE9Verxvk90beVyufrqAU4yyzmaSxGIHn2IH1XGkl9AeqY)seHTgb5PvVscmgaedBSfJYTSxVd8O(kvS5PdiEXYfymagZXXOCl717apQVsfBE6aIxmQIiinxCmSmga2lqXWgBXW6yqLLEnci5FjIWwJG80QxjbgdaIbaXaym3Y75pj1YfyT44loXaGyyJTyoogtL0AEmPOCbwTUWp90QxjbgdGXykciz(tsL2P3HBXWsxXWQaCmagZXXClVN)KulxG1IJV4edGXW6yuUL96X8gXp90beVy5cmg2ylgwhZT8E(Z2QydrQq(ItmagdRJ5wEp)jPwUaRfhFXjgaJr5w2RhZBe)0thq8ILlWyamgwhZzBvSHivOk2HKsCn36tMapTyaqmaiga8flyQ2Vxfih8ddH)Ik3YE)IVer1RuX2xeKWCu6yzVFXdzbLlWyStkgSPlOIaJb1MAzVmgtVs4JPGPyyLerXatPInCmUpPng7KGpgfrXSTfZLYfymoDljWyEnkgaIgoetJIb2n0TGTSxFmcSykgwjrumWuQylgkTtcfdybLlWy0yyLerxvkziCaEuFLk2IHRylg3N0gdajPwUaJrG1jMehJYTKjftJIbSGYfym0beVyumUt7mgrsr5cmgy1f(P)BFyax)H1xKw9kjWpm)ICuAek1V4T8E(Z2QydrQq(ItmagJPsAnpMuuUaRwx4NEA1RKaJbWymfbKm)jPs707WTyyPRyyvaogaJr5wYKQ0sqjHJHLXWurPELK)STk2qKku9jvicBOui6lQCl79l6apQVsfBF7ddHb4pS(I0Qxjb(H5xKJsJqP(fzDmmvuQxj5DoBAZdQoDlZfymagZXXW6ymvsR5FOgQANuvXNe2tRELeymSXwmk3sMuLwckjCmcigHJbaXaymhhJYTKjvbBZNa30Oyyzmhjg2ylgLBjtQslbLeogb4kgMkk1RK8NkcSYvSvFsfIWgkfIIHn2Ir5wYKQ0sqjHJraUIHPIs9kj)zBvSHivO6tQqe2qPquma4lQCl79l6C20MhuFsfIWF7ddHf(dRViT6vsGFy(fvUL9(f5QuwvUL9wLj2(IYeB1vHOVOYTKjvnvsRH)2hgcFKpS(I0Qxjb(H5xKJsJqP(fvULmPkTeus4yeqmc)fvUL9(fbrkWEX1lIu78BFyimR(H1xKw9kjWpm)ICuAek1VOPiGK5pjvANEhUfdlDfdRcWXaymMkP18ysr5cSADHF6PvVsc8lQCl79lI5nIF(Tpme(q)H1xKw9kjWpm)ICuAek1VOYTKjvPLGschJaCfdtfL6vsEfX1LQ0boYgN9gdGXaPR6D4wmcWvmmvuQxj5vexxQsh4iBC2Bfsx9lQCl79lQiUUuLoWr24S3V9HHWc0hwFrA1RKa)W8lQCl79l(KkeHnuke9fbjmhLow27xeUkTZyOTlapJXueqYWmgtAXK4y0yaQ5gJ1XWvSfdRivicBOuikgfhZlLscftUyJuWy6xmSsIORkL(VihLgHs9lQClzsvAjOKWXiaxXWurPELK)urGvUIT6tQqe2qPq03(Wq4J2hwFrLBzVFXxIORkLFrA1RKa)W8BF7l6GiEdDv7dRpme(dRVOYTS3VOI46s1CnskjU9fPvVsc8dZV9HXr(W6lsRELe4hMFX25lIj7lQCl79lYurPEL0xKPIQRcrFXZ2QydrQq1NuHiSHsHOVihLgHs9lYurPELK)STk2qKku9jvicBOuikgxXaWFrqcZrPJL9(fH1zIJHPIs9kPyWoepFjHJXoPy2c0LqX0VymfbKmCmQfJ7ZKFgdazBXiAisfkgwrQqe2qPqeoMUy4eKIPFXa7g6wWw2Bm4ZUibJ5sXuWeO)lYuLf6lEKyGlXyQKwZ)KkevDuJF6PvVscmggedRgdCjgwhJPsAn)tQqu1rn(PNw9kjWV9HbR(H1xKw9kjWpm)ITZxet2xu5w27xKPIs9kPVitfvxfI(INkcSYvSvFsfIWgkfI(ICuAek1VitfL6vs(tfbw5k2QpPcrydLcrX4kga(lcsyokDSS3ViSotCmmvuQxjfd2H45ljCm2jfZwGUekM(fJPiGKHJrTyCFM8ZyaiveymWwXwmSIuHiSHsHiCmDXWjift)Ib2n0TGTS3yWNDrcgZLIPGjWyuCmVukjK)lYuLf6lEKyGlXyQKwZ)KkevDuJF6PvVscmggedRgdCjgwhJPsAn)tQqu1rn(PNw9kjWV9HXH(dRViT6vsGFy(fBNViMSVOYTS3VitfL6vsFrMkQUke9f5n0TGTS36tQqe2qPq0xKJsJqP(fzQOuVsYZBOBbBzV1NuHiSHsHOyCfda)fbjmhLow27xewNjogMkk1RKIb7q88Leog7KIzlqxcft)IXueqYWXOwmUpt(zmaKTfJOHivOyyfPcrydLcr4yueftbtGXawq5cmgy3q3c2YE9FrMQSqFrwng4smMkP18pPcrvh14NEA1RKaJHbXC0IbUedRJXujTM)jviQ6Og)0tRELe43(WqG(W6lsRELe4hMFX25lIj7lQCl79lYurPEL0xKPIQRcrFrfX1LQ0boYgN9(f5O0iuQFrMkk1RK8kIRlvPdCKno7ngxXaWFrqcZrPJL9(fH1zIJHPIs9kPyWoepFjHJXoPy2c0LqX0VymfbKmCmQfJ7ZKFgdleX1LI5qCGJSXzVX0fdNGum9lgy3q3c2YEJbF2fjymxkMcMa9FrMQSqFr4A46yGlXyQKwZ)KkevDuJF6PvVscmggeZrIbUedRJXujTM)jviQ6Og)0tRELe43(W4O9H1xKw9kjWpm)ITZxeryY(Ik3YE)ImvuQxj9fzQO6Qq0xurCDPkDGJSXzVviD1Vii90I0(IhAa(lcsyokDSS3ViSotCmmvuQxjfd2H45ljCm2jfJdH40AkqkM(fdKUAmxs2UJX9zYpJHfI46sXCioWr24S3yCNszmBBXCPykyc0)TpmGJ(W6lsRELe4hMFX25lIimzFrLBzVFrMkk1RK(ImvuDvi6lkuUGYCbwreyHBzVFrq6PfP9fby)H(lcsyokDSS3ViCvANXiWKlOmxGmgdSBOBbBzVcIJH3TeSDVX4oLYyUumicSWjWyUWhJgdsxWgkgfQlRXym3IfJDsXSfOlHIPFXWrPHJbBkYWXWKqWhZzc8mg9zekgLBjt1YfymWUHUfSL9gJUGXGLTBCmGT7ngRDRiqCm2jfdTGX0VyGDdDlyl7vqCm8ULGT71hdC1jTXaPcLlWyajEIZEXXKBm2jfdleoa3mgdSBOBbBzVcIJbrqAU5cmgE3sW29gtIJbrGfobgZf(ySZehZdPCl7ngRJr58USwmVgfJatUGYCb6)2hgauFy9fPvVsc8dZVy78fXK9fvUL9(fzQOuVs6lYuLf6lkqFrqcZrPJL9(fH1jfdybPw2Bm9lgngXYgJatUafehdmLegNlWyGDdDlyl71)fzQO6Qq0xel0TcwqQL9(TpmGR)W6lsRELe4hMFX25lIj7lQCl79lYurPEL0xKPkl0xKybL0XHa9aLkyQwJW1RccKIHn2IHybL0XHa9qkxViQIpjYQqfCYJHn2IHybL0XHa95I5OIPxjvzbfDTcufKyMCkg2ylgIfushhc0Jl7v2nyvHi7eESfdBSfdXckPJdb6jih4rKkRncC1LtXWgBXqSGs64qG(NuHOA)Qx1mjfdBSfdXckPJdb6DRcrlHW1hQxWyyJTyiwqjDCiqFUydv4wJWvWKzUu9ss5xKPIQRcrFrEdDlyl7T2BTGPV9HHWa8hwFrA1RKa)W8l2oFreHj7lQCl79lYurPEL0xKPIQRcrFrcYbEePYAJaxD5ufKKk8Frq6PfP9ffgG6lcsyokDSS3Viaz7ogzVaJ5sVgrXa7g6wWw2Bm4ZUibJ5qa5apIuzma0iWvxofZLIPGjWJUF7ddHf(dRViT6vsGFy(fBNViMSVOYTS3VitfL6vsFrMkQUke9f7TwWuLxS(9(ICuAek1VitfL6vsEEdDlyl7T2BTGPViiH5O0XYE)IaKT7yK9cmMl9AefdSBOBbBzVXGp7IemgdLRqKHJXovlgdLabsOy0yWNkIaJHRgbSrWhdVBjy7EJP3yA7KqXyOCfImCmBBXCPykyc8O7xKPkl0x8ia83(Wq4J8H1xKw9kjWpm)ITZxet2xu5w27xKPIs9kPVitvwOV4reOVihLgHs9lsSGs64qGEiLRxevXNezvOco5FrMkQUke9f7TwWuLxS(9(2hgcZQFy9fPvVsc8dZVy78fXK9fvUL9(fzQOuVs6lYuLf6lEeaoggedtfL6vsEcYbEePYAJaxD5ufKKk8FrokncL6xKybL0XHa9eKd8isL1gbU6YPVitfvxfI(I9wlyQYlw)EF7ddHp0Fy9fPvVsc8dZVy78freMSVOYTS3VitfL6vsFrMkQUke9f5n0TGTS3k(mFwUaRoTBc9fbPNwK2x8iFrqcZrPJL9(fH1jfZwGUekM(fJPiGKHJr8mFwUaJbo0Ujum4ZUibJ5sXuWeym9gdybLlWyGDdDlyl71)TpmewG(W6lsRELe4hMFX25lIimzFrLBzVFrMkk1RK(ImvuDvi6lYBOBbBzVvUITkIG0CXFrq6PfP9fbypC0xeKWCu6yzVFryDsXyjefdIG0CZfym9gJgdxXwmUpPngy3q3c2YEJHRBmxkMcMaJj3yWeVxqS)BFyi8r7dRViT6vsGFy(fvUL9(fXDrwtGBAe6lYrPrOu)ISogMkk1RK88g6wWw2BT3AbtFXvHOViUlYAcCtJqF7ddHHJ(W6lQCl79lcLiuJQjKcK(I0Qxjb(H53(WqyaQpS(I0Qxjb(H5xKJsJqP(fzDmoiIP3bEuFLk2(Ik3YE)IoWJ6RuX23(23(Imjeo79dJJaWhryaw4JC0(IUv0Mlq8xeUIfcqadbomGJXIXedSoPysiNgzX8AumcIANQZPIjbJbrSGsIiWyWnefJwSgsncmg(PUajSpyhUZLIrGyXyGDVmjKrGXiOPsAn)HfmgRJrqtL0A(d7PvVscuWyo(ihaaFWoCNlfZrJfJb29YKqgbgJGMkP18hwWySogbnvsR5pSNw9kjqbJ5yHpaa(GD4oxkMJglgdS7LjHmcmgbrLLEnci5pSGXyDmcIkl9AeqYFypT6vsGcgZXh5aa4d2H7CPyGRzXyGDVmjKrGXiOPsAn)HfmgRJrqtL0A(d7PvVscuWyow4daGpyhUZLIryHzXyGDVmjKrGXiOPsAn)HfmgRJrqtL0A(d7PvVscuWyulMdbanChZXcFaa8b7b7WvSqacyiWHbCmwmMyG1jftc50ilMxJIrqq6PfPjymiIfusebgdUHOy0I1qQrGXWp1fiH9b7WDUumcZIXa7EzsiJaJrquzPxJas(dlymwhJGOYsVgbK8h2tRELeOGXOwmhcaA4oMJf(aa4d2H7CPyoclgdS7LjHmcmgbnvsR5pSGXyDmcAQKwZFypT6vsGcgZXh5aa4d2H7CPyo0SymWUxMeYiWye0ujTM)WcgJ1XiOPsAn)H90Qxjbkymhl8baWhSd35sXiqSymWUxMeYiWye0ujTM)WcgJ1XiOPsAn)H90Qxjbkymhl8baWhSd35sXC0yXyGDVmjKrGXiiQS0Rraj)HfmgRJrquzPxJas(d7PvVscuWyow4daGpyhUZLIboIfJb29YKqgbgJGMkP18hwWySogbnvsR5pSNw9kjqbJ5yHpaa(GD4oxkgHHJyXyGDVmjKrGXiMqWogm8RPhedCC44XyDmWDrJbQblYcoM2HqQ1OyogooaI5yHpaa(GD4oxkgHHJyXyGDVmjKrGXiiVxWsA(dlymwhJG8EblP5pSNw9kjqbJ5yHpaa(GD4oxkgHHRzXyGDVmjKrGXiiVxWsA(dlymwhJG8EblP5pSNw9kjqbJ5yHpaa(GD4oxkMJimlgdS7LjHmcmgbrLLEnci5pSGXyDmcIkl9AeqYFypT6vsGcgZXcFaa8b7WDUumh5iSymWUxMeYiWyeevw61iGK)WcgJ1XiiQS0Rraj)H90Qxjbkymhl8baWhSd35sXCewLfJb29YKqgbgJGOYsVgbK8hwWySogbrLLEnci5pSNw9kjqbJ5yHpaa(GD4oxkMJahXIXa7EzsiJaJrquzPxJas(dlymwhJGOYsVgbK8h2tRELeOGXCSWhaaFWoCNlfZrGRzXyGDVmjKrGXiOPsAn)HfmgRJrqtL0A(d7PvVscuWyow4daGpypyhUIfcqadbomGJXIXedSoPysiNgzX8Aumc6GiEdDvtWyqelOKicmgCdrXOfRHuJaJHFQlqc7d2H7CPyoclgdS7LjHmcmgbnvsR5pSGXyDmcAQKwZFypT6vsGcgZXcFaa8b7WDUumhHfJb29YKqgbgJGMkP18hwWySogbnvsR5pSNw9kjqbJrTyoea0WDmhl8baWhSd35sXWQSymWUxMeYiWye0ujTM)WcgJ1XiOPsAn)H90Qxjbkymhl8baWhSd35sXWQSymWUxMeYiWye0ujTM)WcgJ1XiOPsAn)H90QxjbkymQfZHaGgUJ5yHpaa(GD4oxkMdnlgdS7LjHmcmgbnvsR5pSGXyDmcAQKwZFypT6vsGcgZXcFaa8b7WDUumhAwmgy3ltczeymcAQKwZFybJX6ye0ujTM)WEA1RKafmg1I5qaqd3XCSWhaaFWoCNlfJaXIXa7EzsiJaJrqtL0A(dlymwhJGMkP18h2tRELeOGXCSWhaaFWoCNlfJaXIXa7EzsiJaJrqtL0A(dlymwhJGMkP18h2tRELeOGXOwmhcaA4oMJf(aa4d2d2HRyHaeWqGdd4ySymXaRtkMeYPrwmVgfJG8g6wWw2BL3TeSDVybJbrSGsIiWyWnefJwSgsncmg(PUajSpyhUZLI5OXIXa7EzsiJaJrquzPxJas(dlymwhJGOYsVgbK8h2tRELeOGXCSWhaaFWEWoCfleGagcCyahJfJjgyDsXKqonYI51Oyeu5wYKQMkP1WcgdIybLerGXGBikgTynKAeym8tDbsyFWoCNlfZryXyGDVmjKrGXiOPsAn)HfmgRJrqtL0A(d7PvVscuWyo(ihaaFWoCNlfdRYIXa7EzsiJaJrqtL0A(dlymwhJGMkP18h2tRELeOGXCSWhaaFWEWoCfleGagcCyahJfJjgyDsXKqonYI51OyeeB6cQiWkQn1YEfmgeXckjIaJb3qumAXAi1iWy4N6cKW(GD4oxkgbIfJb29YKqgbgJGMkP18hwWySogbnvsR5pSNw9kjqbJ5yHpaa(GD4oxkMJglgdS7LjHmcmgbnvsR5pSGXyDmcAQKwZFypT6vsGcgJAXCiaOH7yow4daGpyhUZLIbGIfJb29YKqgbgJGMkP18hwWySogbnvsR5pSNw9kjqbJ5yHpaa(GD4oxkgakwmgy3ltczeymcIkl9AeqYFybJX6yeevw61iGK)WEA1RKafmMJpYbaWhSd35sXaxZIXa7EzsiJaJrqtL0A(dlymwhJGMkP18h2tRELeOGXCSWhaaFWoCNlfJWamlgdS7LjHmcmgbnvsR5pSGXyDmcAQKwZFypT6vsGcgZXcFaa8b7WDUumcZQSymWUxMeYiWye0ujTM)WcgJ1XiOPsAn)H90QxjbkymQfZHaGgUJ5yHpaa(G9GD4kwiabme4WaoglgtmW6KIjHCAKfZRrXiiVHUfSL9wDovmjymiIfusebgdUHOy0I1qQrGXWp1fiH9b7WDUumhHfJb29YKqgbgJG8EblP5pSGXyDmcY7fSKM)WEA1RKafmg1I5qaqd3XCSWhaaFWoCNlfdRYIXa7EzsiJaJrqEVGL08hwWySogb59cwsZFypT6vsGcgZXcFaa8b7WDUumhnwmgy3ltczeymcY7fSKM)WcgJ1XiiVxWsA(d7PvVscuWyow4daGpyhUZLIboIfJb29YKqgbgJycb7yWWVMEqmWXJX6yG7IgdyYmXzVX0oesTgfZXmeaXCSWhaaFWoCNlfdCelgdS7LjHmcmgb59cwsZFybJX6yeK3lyjn)H90QxjbkymQfZHaGgUJ5yHpaa(GD4oxkgakwmgy3ltczeymIjeSJbd)A6bXahpgRJbUlAmGjZeN9gt7qi1AumhZqaeZXcFaa8b7WDUumauSymWUxMeYiWyeK3lyjn)HfmgRJrqEVGL08h2tRELeOGXOwmhcaA4oMJf(aa4d2H7CPyGRzXyGDVmjKrGXiiVxWsA(dlymwhJG8EblP5pSNw9kjqbJ5yHpaa(GD4oxkgHbywmgy3ltczeymcAQKwZFybJX6ye0ujTM)WEA1RKafmg1I5qaqd3XCSWhaaFWoCNlfJWamlgdS7LjHmcmgbrLLEnci5pSGXyDmcIkl9AeqYFypT6vsGcgZXcFaa8b7WDUumclmlgdS7LjHmcmgbnvsR5pSGXyDmcAQKwZFypT6vsGcgJAXCiaOH7yow4daGpyhUZLIryHzXyGDVmjKrGXiiQS0Rraj)HfmgRJrquzPxJas(d7PvVscuWyow4daGpyhUZLIr4JWIXa7EzsiJaJrquzPxJas(dlymwhJGOYsVgbK8h2tRELeOGXCSWhaaFWoCNlfJWSklgdS7LjHmcmgbrLLEnci5pSGXyDmcIkl9AeqYFypT6vsGcgZXcFaa8b7WDUumclqSymWUxMeYiWye0ujTM)WcgJ1XiOPsAn)H90Qxjbkymhl8baWhSd35sXiSaXIXa7EzsiJaJrquzPxJas(dlymwhJGOYsVgbK8h2tRELeOGXC8roaa(GD4oxkgHHJyXyGDVmjKrGXiiQS0Rraj)HfmgRJrquzPxJas(d7PvVscuWyow4daGpyhUZLI5ihAwmgy3ltczeymcAQKwZFybJX6ye0ujTM)WEA1RKafmMJpYbaWhSd35sXCKJglgdS7LjHmcmgb59cwsZFybJX6yeK3lyjn)H90QxjbkymQfZHaGgUJ5yHpaa(GD4oxkgwfGzXyGDVmjKrGXiOPsAn)HfmgRJrqtL0A(d7PvVscuWyulMdbanChZXcFaa8b7b7cCiNgzeymWrXOCl7ngzInSpy)l6G6xkPViCcNXWkjII5qrbsb7WjCgZPzoywKHmeyANLRN3qmeNqfPAzVCK(mgItiodd2Ht4mgwHUOIIGpgakgJ5ia8reoypyhoHZyG9PUajmlgSdNWzmhvmcSykMxc80QicsZfhdsTtcfJDQBmMIasM3siQADfmPyEnkgPITJct8EbJrVPmn4JPGvGe2hSdNWzmhvmWD3yAJHRylgeXckjIGO1WX8AumWUHUfSL9gZXPN8mgdyVcAXC2sWyslMxJIrJ5Hi8zmhkKrnkgUIna4d2Ht4mMJkMdXQxjfd2qj3IHFsCHYfym9gJgZJChZRrcHJj3yStkgwiCaUJX6yqeyHtX4UrcjBf0hSdNWzmhvmSqWJ(c2IrJboapQVsfBXqRHGpg7uTyaBchZ2wmqnijJXnjLXK7rbuHOyogNqXye2iWyulMTJbNa38LCDTyoKWbXysihLBaWhSdNWzmhvmWUxMeYIrLYyUL3ZFypIuUfdTgkjCmwhZT8E(d7lomgJUXOsOgBXKlobU5l56AXCiHdIXauZnMCJbNqyFWEWoCcNXCioG4fJaJ5sVgrXWBORAXCjG5I9XWc5CYXWXS9EuNkc6vKXOCl7fhtVs49b7k3YEXEheXBORAmWfdvexxQMRrsjXTGD4mgyDM4yyQOuVskgSdXZxs4yStkMTaDjum9lgtrajdhJAX4(m5NXaq2wmIgIuHIHvKkeHnukeHJPlgobPy6xmWUHUfSL9gd(SlsWyUumfmb6d2vUL9I9oiI3qx1yGlgYurPELeJRcrUoBRInePcvFsfIWgkfIySDCHjJX85IPIs9kj)zBvSHivO6tQqe2qPqKlaMrMQSqUocCXujTM)jviQ6Og)KbSkCH1MkP18pPcrvh14Nb7WzmW6mXXWurPELumyhINVKWXyNumBb6sOy6xmMIasgog1IX9zYpJbGurGXaBfBXWksfIWgkfIWX0fdNGum9lgy3q3c2YEJbF2fjymxkMcMaJrXX8sPKq(GDLBzVyVdI4n0vng4IHmvuQxjX4QqKRtfbw5k2QpPcrydLcrm2oUWKXy(CXurPELK)urGvUIT6tQqe2qPqKlaMrMQSqUocCXujTM)jviQ6Og)KbSkCH1MkP18pPcrvh14Nb7WzmW6mXXWurPELumyhINVKWXyNumBb6sOy6xmMIasgog1IX9zYpJbGSTyenePcfdRivicBOuichJIOykycmgWckxGXa7g6wWw2Rpyx5w2l27GiEdDvJbUyitfL6vsmUke5I3q3c2YERpPcrydLcrm2oUWKXy(CXurPELKN3q3c2YERpPcrydLcrUaygzQYc5IvHlMkP18pPcrvh14Nm4ObxyTPsAn)tQqu1rn(zWoCgdSotCmmvuQxjfd2H45ljCm2jfZwGUekM(fJPiGKHJrTyCFM8ZyyHiUUumhIdCKno7nMUy4eKIPFXa7g6wWw2Bm4ZUibJ5sXuWeOpyx5w2l27GiEdDvJbUyitfL6vsmUke5srCDPkDGJSXzVm2oUWKXy(CXurPELKxrCDPkDGJSXzVUaygzQYc5cUgUgUyQKwZ)KkevDuJFYGJaxyTPsAn)tQqu1rn(zWoCgdSotCmmvuQxjfd2H45ljCm2jfJdH40AkqkM(fdKUAmxs2UJX9zYpJHfI46sXCioWr24S3yCNszmBBXCPykyc0hSRCl7f7DqeVHUQXaxmKPIs9kjgxfICPiUUuLoWr24S3kKUkJG0tlsZ1HgGzSDCHimzb7WzmWvPDgJatUGYCbYymWUHUfSL9kiogE3sW29gJ7ukJ5sXGiWcNaJ5cFmAmiDbBOyuOUSgJXClwm2jfZwGUekM(fdhLgogSPidhdtcbFmNjWZy0NrOyuULmvlxGXa7g6wWw2Bm6cgdw2UXXa2U3yS2TIaXXyNum0cgt)Ib2n0TGTSxbXXW7wc2UxFmWvN0gdKkuUaJbK4jo7fhtUXyNumSq4aCZymWUHUfSL9kiogebP5MlWy4DlbB3Bmjogebw4eymx4JXotCmpKYTS3ySogLZ7YAX8Aumcm5ckZfOpyx5w2l27GiEdDvJbUyitfL6vsmUke5sOCbL5cSIiWc3YEzeKEArAUay)HMX2XfIWKfSdNXaRtkgWcsTS3y6xmAmILngbMCbkiogykjmoxGXa7g6wWw2Rpyx5w2l27GiEdDvJbUyitfL6vsmUke5cl0TcwqQL9Yy74ctgJmvzHCjqb7k3YEXEheXBORAmWfdzQOuVsIXvHix8g6wWw2BT3Abtm2oUWKXitvwixelOKooeOhOubt1AeUEvqGeBSrSGs64qGEiLRxevXNezvOco5SXgXckPJdb6ZfZrftVsQYck6AfOkiXm5eBSrSGs64qGECzVYUbRkezNWJn2yJybL0XHa9eKd8isL1gbU6Yj2yJybL0XHa9pPcr1(vVQzsIn2iwqjDCiqVBviAjeU(q9cYgBelOKooeOpxSHkCRr4kyYmxQEjPmyhoJbGSDhJSxGXCPxJOyGDdDlyl7ng8zxKGXCiGCGhrQmgaAe4QlNI5sXuWe4r3GDLBzVyVdI4n0vng4IHmvuQxjX4QqKlcYbEePYAJaxD5ufKKk8mcspTinxcdqXy74cryYc2HZyaiB3Xi7fymx61ikgy3q3c2YEJbF2fjymgkxHidhJDQwmgkbcKqXOXGpvebgdxncyJGpgE3sW29gtVX02jHIXq5kez4y22I5sXuWe4r3GDLBzVyVdI4n0vng4IHmvuQxjX4QqKRERfmv5fRFpgBhxyYyKPklKRJaWmMpxmvuQxj55n0TGTS3AV1cMc2vUL9I9oiI3qx1yGlgYurPELeJRcrU6TwWuLxS(9ySDCHjJrMQSqUoIaXy(CrSGs64qGEiLRxevXNezvOco5b7k3YEXEheXBORAmWfdzQOuVsIXvHix9wlyQYlw)Em2oUWKXitvwixhbGzatfL6vsEcYbEePYAJaxD5ufKKk8mMpxelOKooeONGCGhrQS2iWvxofSdNXaRtkMTaDjum9lgtrajdhJ4z(SCbgdCODtOyWNDrcgZLIPGjWy6ngWckxGXa7g6wWw2Rpyx5w2l27GiEdDvJbUyitfL6vsmUke5I3q3c2YER4Z8z5cS60UjeJG0tlsZ1rySDCHimzb7WzmW6KIXsikgebP5MlWy6ngngUITyCFsBmWUHUfSL9gdx3yUumfmbgtUXGjEVGyFWUYTSxS3br8g6QgdCXqMkk1RKyCviYfVHUfSL9w5k2QicsZfZii90I0CbWE4igBhxictwWUYTSxS3br8g6QgdCXWcMQPrqmUke5c3fznbUPrigZNlwZurPELKN3q3c2YER9wlykyx5w2l27GiEdDvJbUyiuIqnQMqkqkyx5w2l27GiEdDvJbUyOd8O(kvSXy(CXAheX07apQVsfBb7b7WjCgZH4aIxmcmgIjHGpglHOyStkgLBnkMehJYutPELKpyx5w2l2fVlRriSdjLmMpxSgvw61iGKhmX80rMRIGVYBiiDbd2HZyouvuQxjfJDQwm8EnulXX4(K2yGDdDlyl7nMehtbtG(yG1zIJrMlfdMmCmWUHUfSL9gJ1XCPykycmg9zekgwjre2uKrOy0fmg1XrMeog7KIrOCbL5cSIiWc3YEJHPIs9kPySog7KIbrqAU5cmgE3sW29gt)Ib2n0TGTSxFmSqqW0YEvPeEgJjFXa7g6wWw2BmjogWeRxjbgJDM4yo6lylgmz4yStkgMkk1RKIX6y0ySeIIXrXwm2jfdTGX0VyStkgCcvKQL96d2vUL9IzGlgYurPELeJRcrUSeIQwx5n0TGTSxgBhxyYyKPklKltL0A(xIiSPiJqWLxIiSPiJqEebP5IzWX8ULGT71ZBOBbBzVEebP5IHlhl8rXurPELKxOCbL5cSIiWc3YEHlMkP18cLlOmxGaaaWfwZ7wc2UxpVHUfSL96rKccpC5wEppVHUfSL96bB3BWoCgZHIkefdUGOyGDdDlyl7nMehdijv4jWyYxmlrGeymxftGX0Bm2jfdb5apIuzTrGRUCQcssf(yyQOuVsYhSRCl7fZaxmKPIs9kjgxfICzjevTUYBOBbBzVm2oUG0dyKPklKlMkk1RK8eKd8isL1gbU6YPkijv4pQJ5DlbB3RNGCGhrQS2iWvxo5bli1YEpkE3sW296jih4rKkRncC1LtEebP5IbaCH18ULGT71tqoWJivwBe4QlN8isbHNX85IybL0XHa9eKd8isL1gbU6YPGD4mMdjjv4Jb2n0TGTS3ykRLYyaiA4qm0bojIWXKVystqCmfhFWUYTSxmdCXqMkk1RKyCviYLLqu16kVHUfSL9Yy74cspGrMQSqUUL3ZJklv7x1PDtipIG0CXmMpxMkP18OYs1(vDA3ecWB5988g6wWw2RhSDVb7WzmhssQWhdSBOBbBzVX8Aum6gdDGH0yaiklft)Ibo0Ujum5lg7KIbGOSum9lg4q7MqX4UlsWy4neft)EXW7wc2U3yulgjPylgbkgmX7fehZLEnIIb2n0TGTS3yC3fjOpyx5w2lMbUyitfL6vsmUke5YsiQADL3q3c2YEzSDCbPhWitvwix8ULGT71Jklv7x1PDtipIG0CXm4wEppQSuTFvN2nH8GfKAzVmMpxMkP18OYs1(vDA3ecWB5988g6wWw2RhSDVaY7wc2UxpQSuTFvN2nH8icsZfZabILmvuQxj5TeIQwx5n0TGTS3GD4mMdjjv4Jb2n0TGTS3yYxmhYeZthzUkc(yGDdbPlymU7IemMTTyUumisbHpMxJIjTyGNmFWUYTSxmdCXqMkk1RKyCviYLLqu16kVHUfSL9Yy74cspGrMQSqU4DlbB3R)wEVkyI5PJmxfbFL3qq6c6reKMlMX85cvw61iGKhmX80rMRIGVYBiiDbb8wEppyI5PJmxfbFL3qq6c6bB3BWoCgZHQIs9kPySt1IHWwcPgHJX9jzNekgXZ8z5cmg4q7MqX4oLYyUumfmbgZLEnIIb2n0TGTS3ysCmisbH3hSRCl7fZaxmKPIs9kjgxfICHpZNLlWQt7Mq1l9Aev5n0TGTSxgBhxyYyKPklKRJvULmPkTeusywYurPELKN3q3c2YER4Z8z5cS60UjeBSPClzsvAjOKWSKPIs9kjpVHUfSL9wFsfIWgkfIyJnMkk1RK8wcrvRR8g6wWw27rPCl71JpZNLlWQt7Mq(xrkRicSWTSxbW7wc2Uxp(mFwUaRoTBc5bli1YEbaGmvuQxj5TeIQwx5n0TGTS3JI3TeSDVE8z(SCbwDA3eYJiinxSauUL96XN5ZYfy1PDti)RiLvebw4w2lGhZ7wc2UxpQSuTFvN2nH8icsZfFu8ULGT71JpZNLlWQt7MqEebP5IfGaXgBS2ujTMhvwQ2VQt7Mqaiyx5w2lMbUyi(mFwUaRoTBcXy(CDlVNN3q3c2YE9GT7fqwF8T8E(CFeAvzLRyUcs(IdG3Y75pBRInePc5loaaqMkk1RK84Z8z5cS60Uju9sVgrvEdDlyl7nyx5w2lMbUyisbtDTk2rrcXy(CD8T8EEEdDlyl71d2UxaVL3ZJklv7x1PDtipy7Eb8yMkk1RK8wcrvRR8g6wWw2llPdiEXOQLqeBSXurPELK3siQADL3q3c2YEfaVBjy7E9ifm11QyhfjKhSGul7faaGn2o(wEppQSuTFvN2nH8fhazQOuVsYBjevTUYBOBbBzVcGvbyaeSRCl7fZaxmeKu782OLymFUUL3ZZBOBbBzVEW29c4T8EEuzPA)QoTBc5bB3lGmvuQxj5TeIQwx5n0TGTSxwshq8IrvlHOGDLBzVyg4IHqjc1iCTFvRrq0AmMpxmvuQxj5TeIQwx5n0TGTSxw6Ivb8wEppVHUfSL96bB3BWoCgdR0OyouP1oHhXymfmfJgdRKikgykvSfd)uraPyalOCbgZHsIqncht)IbwncIwlgUITySogLzNGXWvhNCbgd)urajSpyx5w2lMbUy4lru9kvSXybtv3NPKQCfB5c0LWmMpxk3YE9qjc1iCTFvRrq0AE6aIxSCbc4RiLveXpveqQAjeDuk3YE9qjc1iCTFvRrq0AE6aIxmQIiinxmlp0aY6Z2QydrQqvSdjL4AU1NmbEAaY6B598NTvXgIuH8fNGDLBzVyg4IHfmvtJGyKEpIB1vHixaLkyQwJW1RccKymFUyQOuVsYBjevTUYBOBbBzVcG3TeSDVhLafSRCl7fZaxmSGPAAeeJRcrUiih4rKkRncC1LtmMpxmvuQxj5TeIQwx5n0TGTSxw6IPIs9kjpb5apIuzTrGRUCQcssf(GDLBzVyg4IHfmvtJGyCviYfqj8oN1(vvmoHsPAzVmMpxmvuQxj5TeIQwx5n0TGTSxb4IPIs9kjFV1cMQ8I1VxWUYTSxmdCXWcMQPrqmUke5cs56frv8jrwfQGtoJ5ZftfL6vsElHOQ1vEdDlyl7LLUeOGD4mgb(lMcoxGXOXGnc1jym9EufmftAeeJXOs3k84ykykMdjIuWxIOyoujmMKX0fdNGum9lgy3q3c2YE9XaqBNeYDIjgJXbLnkT8OdftbNlWyoKisbFjII5qLWysgJ70oJb2n0TGTS3y6vcFm5lgb((i0QYyGTI5kiftIJHw9kjWy0fmgnMcwbsX4UxbTyUumYgBX0mjum2jfdybPw2Bm9lg7KI5LapnFWUYTSxmdCXWcMQPrqmUke5cerk4lruLjHXKKX85IPIs9kjVLqu16kVHUfSL9kaxmvuQxj57TwWuLxS(9a84B5985(i0QYkxXCfK8yt5c56wEpFUpcTQSYvmxbjpKEqfBkxi2yJ18EblP5Z9rOvLvUI5kiXgBmvuQxj55n0TGTS3AV1cMyJnMkk1RK8wcrvRR8g6wWw2ldeib8sGNwfrqAUy44WX5DlbB3lac2HZye7ImgboWnncfd(SlsWyUumfmbgtUXOX4wHpg7uTyaBcVcAXKRrOhHOyCN2zmTDsOy69OkykgdLRqKH9XaqBNekgdLRqKHJbSJzBlgdLabsOy0yWNkIaJrGd7dzm9gtAmgdUJjTy46gZLIPGjWyqjWtlg9zekgDHpM2ojum9EufmfJHYviY8b7k3YEXmWfdlyQMgbX4QqKlCxK1e4MgHymFUyQOuVsYBjevTUYBOBbBzVcWfRcWWLJzQOuVsY3BTGPkVy97jaagaaEmRjwqjDCiqpiIuWxIOktcJjjBSX7wc2UxpiIuWxIOktcJjPhrqAUybiqaiyhoHZyGb5ogXUiJrGdCtJqXqRHGNXyqKmjCm9gd(ureymPrqXa7dzm5(AeKAzVXyNQftIJzBlg4jlgCXXPrgb6JjgacYrQCchJDsX4GiMzxWXiZLIX9jTX8kl3YEvPpyhoHZyuUL9IzGlgwWunncIXvHix4UiRjWnncXy(CDmtfL6vsElHOQ1vEdDlyl7vaUyvagUCmtfL6vs(ERfmv5fRFpbaWaGn24DlbB3RpncQYbRcl8HwypIG0CXaaWJznXckPJdb6brKc(sevzsymjzJnE3sW296brKc(sevzsymjRS6H(qdhXQhXJiinxSaeiaeSdNXaluceiHIrSlYye4a30iumKIKWhJ70oJrGVpcTQmgyRyUcsX0OyCFsBmPfJBfhJdI4k28b7k3YEXmWfd56Yjz9wEpgxfICH7ISMa30YEzmFUynVxWsA(CFeAvzLRyUcsaAjeXsbIn2UL3ZN7JqRkRCfZvqYJnLlKRB5985(i0QYkxXCfK8q6bvSPCHc2HZye4gbHJXovlgWoMTTyU0sV0Ib2n0TGTS3yWNDrcgZrFbBXCPykycmMUy4eKIPFXa7g6wWw2BmQfdUHOyC6CnFWUYTSxmdCXWcMQPrqygZNlMkk1RK8wcrvRR8g6wWw2RaCXurPELKV3AbtvEX63lyhoJbogzXyNumhYeZthzUkc(yGDdbPlym3Y7ftXHXykRKW4y4n0TGTS3ysCm4UxFWUYTSxmdCXqExwJqyhskzmFUqLLEnci5btmpDK5Qi4R8gcsxqa5DlbB3R)wEVkyI5PJmxfbFL3qq6c6rKccpG3Y75btmpDK5Qi4R8gcsxWQI46sEW29ciRVL3ZdMyE6iZvrWx5neKUG(IdGmvuQxj5TeIQwx5n0TGTSxbCebkyx5w2lMbUyOI46sv6ahzJZEzmFUqLLEnci5btmpDK5Qi4R8gcsxqa5DlbB3R)wEVkyI5PJmxfbFL3qq6c6rKccpG3Y75btmpDK5Qi4R8gcsxWQI46sEW29ciRVL3ZdMyE6iZvrWx5neKUG(IdGmvuQxj5TeIQwx5n0TGTSxbCebkyx5w2lMbUy4d1y72sJX85cvw61iGKhmX80rMRIGVYBiiDbbK3TeSDV(B59QGjMNoYCve8vEdbPlOhrki8aElVNhmX80rMRIGVYBiiDbRpuJnpy7EbK13Y75btmpDK5Qi4R8gcsxqFXbqMkk1RK8wcrvRR8g6wWw2RaoIafSRCl7fZaxmKRszv5w2BvMyJXvHix8g6wWw2B15uXeJ5ZftfL6vsElHOQ1vEdDlyl7LLUa4GDLBzVyg4IHOYs1(vDA3eIX856wEppQSuTFvN2nH8GT7fqwFlVN)LicBncYxCa8yMkk1RK8wcrvRR8g6wWw2RaCDlVNhvwQ2VQt7MqEWcsTSxazQOuVsYBjevTUYBOBbBzVcq5w2R)LiQELk28VIuwre)uraPQLqeBSXurPELK3siQADL3q3c2YEfWlbEAvebP5IbqWoCgZHQIs9kPySt1IH3RHAjogwjrumWuQylMcwbsXyDm0IlikM0WXWpveqchJt3scmMxJIb2n0TGTSxFWUYTSxmdCXqMkk1RKySGPA)EvGCqxcZybtv3NPKQCfB5c0LWmUke56LiQELk2QoDlZfiJTJlmzmYuLfYftfL6vsElHOQ1vEdDlyl79OyvwQCl71)sevVsfB(xrkRiIFQiGu1si6OuUL96XN5ZYfy1PDti)RiLvebw4w2lCHPIs9kjp(mFwUaRoTBcvV0RruL3q3c2YEbKPIs9kjVLqu16kVHUfSL9YYxc80QicsZfhSdNXCOQOuVskg7uTy49AOwIJboC20MhedRivichtbRaPySogAXfeftA4y4NkciHJrrumoDljWyEnkgy3q3c2YE9b7k3YEXmWfdzQOuVsIXvHixoNnT5bvNUL5cKX2XfMmgzQYc5IPIs9kjVLqu16kVHUfSL9YsLBzVENZM28G6tQqe2)kszfr8tfbKQwcrhLYTSxp(mFwUaRoTBc5FfPSIiWc3YEHlmvuQxj5XN5ZYfy1PDtO6LEnIQ8g6wWw2lGmvuQxj5TeIQwx5n0TGTSxw(sGNwfrqAUy2ydvw61iGKhx2Qq5cexVscJZfiBSzjeXsbkyx5w2lMbUyixLYQYTS3QmXgJRcrUqTt15uXeJydLCZLWmMpx3Y75rLLQ9R60UjKV4aitfL6vsElHOQ1vEdDlyl7vaaCWoCgdle8OVGTyStkgMkk1RKIXovlgEVgQL4yyLerXatPITykyfifJ1XqlUGOysdhd)urajCmkIIrL4ogNULeymVgfdarzPy6xmWH2nH8b7k3YEXmWfdzQOuVsIXcMQ97vbYbDjmJfmvDFMsQYvSLlqxcZ4QqKRxIO6vQyR60TmxGm2oUWKXitvwix8ULGT71Jklv7x1PDtipIG0CXSu5w2R)LiQELk28VIuwre)uraPQLq0rPCl71JpZNLlWQt7Mq(xrkRicSWTSx4YXmvuQxj5XN5ZYfy1PDtO6LEnIQ8g6wWw2lG8ULGT71JpZNLlWQt7MqEebP5IzjVBjy7E9OYs1(vDA3eYJiinxmaaK3TeSDVEuzPA)QoTBc5reKMlMLVe4PvreKMlMX85I1mvuQxj5FjIQxPITQt3YCbcOPsAnpQSuTFvN2nHa8wEppQSuTFvN2nH8GT7nyhoJbU6K2yaiveixXwUaJHvKkefJOHsHigJHvsefdmLk2WXGp7IemMlftbtGXyDmaPLqQrXaq2wmIgIuHWXOlymwhdDGrlymWuQyJqXCOOyJq(GDLBzVyg4IHVer1RuXgJfmv73RcKd6syglyQ6(mLuLRylxGUeMX85I1mvuQxj5FjIQxPITQt3YCbcitfL6vsElHOQ1vEdDlyl7vaamGk3sMuLwckjSaCXurPELK)urGvUIT6tQqe2qPqeGS(LicBkYiKx5wYKaK13Y75pBRInePc5loaE8T8E(tsTCbwlo(IdGk3YE9pPcrydLcrE6aIxmQIiinxmlbyVaXgB8tfbKW1hs5w2RkfGRJaGGD4mMdzbLlWyyLerytrgHymgwjrumWuQydhJIOykycmgCcLsfjHpgRJbSGYfymWUHUfSL96JbogTesLs4zmg7KGpgfrXuWeymwhdqAjKAumaKTfJOHiviCmUpPngoknCmUtPmMTTyUumUvSrGXOlymUt7mgykvSrOyouuSrigJXoj4JbF2fjymxkgSdIuWy6IfJ1XaP5AAUXyNumWuQyJqXCOOyJqXClVNpyx5w2lMbUy4lru9kvSXybt1(9Qa5GUeMXcMQUptjv5k2YfOlHzmFUEjIWMImc5vULmja5NkciHfGlHbK1mvuQxj5FjIQxPITQt3YCbc4XSw5w2R)Li6QsPNoG4flxGaYALBzVEh4r9vQyZNB9jtGNgG3Y75pj1YfyT44loSXMYTSx)lr0vLspDaXlwUabK13Y75pBRInePc5loSXMYTSxVd8O(kvS5ZT(KjWtdWB598NKA5cSwC8fhaz9T8E(Z2QydrQq(Idac2HZyyHm7emgU64KlWyyLerXatPITy4NkciHJX9zkPy4N6UKmxGXiEMplxGXahA3ekyx5w2lMbUy4lru9kvSXybtv3NPKQCfB5c0LWmMpxk3YE94Z8z5cS60UjKNoG4flxGa(kszfr8tfbKQwcrSu5w2RhFMplxGvN2nH8wYfQIiWc3YEb8wEp)zBvSHivipy7Eb0sisacdWb7k3YEXmWfd5QuwvUL9wLj2yCviYf20furGvuBQL9Yy(CXurPELK3siQADL3q3c2YEfaad4T8EEuzPA)QoTBc5bB3BWUYTSxmdCXqmVr8ZG9GDLBzVyVYTKjvnvsRHDjtM5cSEBOlJ5ZLYTKjvPLGsclaHb8wEppVHUfSL96bB3lGhZurPELK3siQADL3q3c2YEfaVBjy7E9YKzUaR3g66bli1YEzJnMkk1RK8wcrvRR8g6wWw2llDbWaiyx5w2l2RClzsvtL0Ayg4IHqKrnIX85IPIs9kjVLqu16kVHUfSL9YsxamBSDmVBjy7E9qKrnYdwqQL9YsMkk1RK8wcrvRR8g6wWw2lGS2ujTMhvwQ2VQt7MqaGn2mvsR5rLLQ9R60UjeG3Y75rLLQ9R60UjKV4aitfL6vsElHOQ1vEdDlyl7vak3YE9qKrnYZ7wc2Ux2y7LapTkIG0CXSKPIs9kjVLqu16kVHUfSL9gSRCl7f7vULmPQPsAnmdCXqqKcSxC9Ii1ozmFUmvsR5vjDa2qk(OJIRVccEap(wEppVHUfSL96bB3lGS(wEp)zBvSHiviFXbab7b7k3YEXEEdDlyl7TY7wc2UxSlN2YEd2vUL9I98g6wWw2BL3TeSDVyg4IHxz3G1xbbFWUYTSxSN3q3c2YER8ULGT7fZaxm8simHekxGmMpx3Y755n0TGTSxFXjyx5w2l2ZBOBbBzVvE3sW29IzGlg(seDLDdgSRCl7f75n0TGTS3kVBjy7EXmWfd1LtydPYkxLYGDLBzVypVHUfSL9w5DlbB3lMbUyOLqu1TICymFUqLLEnci5ncYPrQS6wroaElVNNo4ulyl71xCc2vUL9I98g6wWw2BL3TeSDVyg4IHfmvtJGyKEpIB1vHixaLkyQwJW1RccKc2vUL9I98g6wWw2BL3TeSDVyg4IHfmvtJGyCviYvUyoQy6vsvwqrxRavbjMjNc2vUL9I98g6wWw2BL3TeSDVyg4IHfmvtJGyCviY1tQquTF1RAMKc2vUL9I98g6wWw2BL3TeSDVyg4IHfmvtJGyCviYLBviAjeU(q9cgSRCl7f75n0TGTS3kVBjy7EXmWfdlyQMgbX4QqKRCXgQWTgHRGjZCP6LKYGDLBzVypVHUfSL9w5DlbB3lMbUyybt10iigxfICHl7v2nyvHi7eESfSRCl7f75n0TGTS3kVBjy7EXmWfdlyQMgbHd2d2vUL9I98g6wWw2B15uXKlzc80W1J(ciqiAngZNRB5988g6wWw2RhSDVb7WzmhcSLqQrXC2UJr2lWyGDdDlyl7ng3PugJuXwm2PUcHJX6yelBmcm5cuqCmWusyCUaJX6yajJqq5sXC2UJHvsefdmLk2WXGp7IemMlftbtG(GDLBzVypVHUfSL9wDovmXaxmKPIs9kjglyQ2Vxfih0LWmwWu19zkPkxXwUaDjmJRcrUOdmAbjWkVHUfSL9wreKMlMX2XfMmgzQYc56wEppVHUfSL96reKMlMb3Y755n0TGTSxpybPw2lC5yE3sW2965n0TGTSxpIG0CXS8wEppVHUfSL96reKMlgamMpx8EblP5Z9rOvLvUI5kifSdNXWcbbXXyNumGfKAzVX0VyStkgXYgJatUafehdmLegNlWyGDdDlyl7ngRJXoPyOfmM(fJDsXWlieTwmWUHUfSL9gt(IXoPy4k2IXDxKGXWBihjzumGfuUaJXotCmWUHUfSL96d2vUL9I98g6wWw2B15uXedCXqMkk1RKySGPA)EvGCqxcZybtv3NPKQCfB5c0LWmUke5IoWOfKaR8g6wWw2BfrqAUygBhxkiiJmvzHCXurPELKhl0TcwqQL9Yy(CX7fSKMp3hHwvw5kMRGeGhFlVNhx2Qq5cexVscJZfyfrki8(IdBSXurPELKNoWOfKaR8g6wWw2BfrqAUybiSxGGla5GEi9a4YX3Y75XLTkuUaX1RKW4Cb6H0dQyt5cDu3Y75XLTkuUaX1RKW4Cb6XMYfcaaiyx5w2l2ZBOBbBzVvNtftmWfdVkWA)Qgk5cHzmFUUL3ZZBOBbBzVEW29gSRCl7f75n0TGTS3QZPIjg4IHYKzUaR3g6Yy(CPClzsvAjOKWcqyaVL3ZZBOBbBzVEW29gSdNXaxL2zxSye47JqRkJb2kMRGeJXC0xWwmfmfdRKikgykvSHJX9jTXyNe8X4UxbTyGkl)mgoknCm6cgJ7tAJHvseHTgbftIJbSDV(GDLBzVypVHUfSL9wDovmXaxm8LiQELk2ySGPA)EvGCqxcZybtv3NPKQCfB5c0LWmMpxSM3lyjnFUpcTQSYvmxbja5NkciHfGlHb8wEppVHUfSL96loaY6B598VeryRrq(IdGS(wEp)zBvSHiviFXbWZ2QydrQqvSdjL4AU1NmbEAm4wEp)jPwUaRfhFXHLhjyhoJbUkTZye47JqRkJb2kMRGeJXWkjIIbMsfBXuWum4ZUibJ5sXOGGPL9Qsj8XW7fBinxcmgChJDQwmPftIJzBlMlftbtGXuwjHXXiW3hHwvgdSvmxbPysCm6TlwmwhdDGtIOyAum2jHOyuefduJOyStDJH2Ua8mgwjrumWuQydhJ1Xqhy0cgJaFFeAvzmWwXCfKIX6yStkgAbJPFXa7g6wWw2Rpyx5w2l2ZBOBbBzVvNtftmWfdzQOuVsIXcMQ97vbYbDjmJfmvDFMsQYvSLlqxcZ4QqKl6ahIBey9LiQELk2Wm2oUWKXitvwixk3YE9Ver1RuXMNFQiGeU(qk3YEvjdoMPIs9kjpDGrlibw5n0TGTS3kIG0CXh1T8E(CFeAvzLRyUcsEWcsTSxaahN3TeSDV(xIO6vQyZdwqQL9Yy(CX7fSKMp3hHwvw5kMRGuWUYTSxSN3q3c2YERoNkMyGlgYurPELeJfmv73RcKd6syglyQ6(mLuLRylxGUeMXvHixlrGey9LiQELk2Wm2oUWKXitvwixCkLhZurPELKNoWOfKaR8g6wWw2BfrqAUy44hFlVNp3hHwvw5kMRGKhSGul79OaYb9q6baaamMpx8EblP5Z9rOvLvUI5kifSRCl7f75n0TGTS3QZPIjg4IHVer1RuXgJfmv73RcKd6syglyQ6(mLuLRylxGUeMX85I3lyjnFUpcTQSYvmxbja5NkciHfGlHb8yMkk1RK80boe3iW6lru9kvSHfGlMkk1RK8lrGey9LiQELk2WSXgtfL6vsE6aJwqcSYBOBbBzVvebP5IzPRB5985(i0QYkxXCfK8GfKAzVSX2T8E(CFeAvzLRyUcsESPCHy5ryJTB5985(i0QYkxXCfK8icsZfZsGCqpKEaBSX7wc2Uxp(mFwUaRoTBc5rKccpGk3sMuLwckjSaCXurPELKN3q3c2YER4Z8z5cS60UjeG8MjT6A(nbEA1NsaaWB5988g6wWw2RV4a4XS(wEp)lre2AeKV4WgB3Y75Z9rOvLvUI5ki5reKMlMLaSxGaaGS(wEp)zBvSHiviFXbWZ2QydrQqvSdjL4AU1NmbEAm4wEp)jPwUaRfhFXHLhjyhoJboGihfrXCitmpDK5Qi4Jb2neKUGX8AumWUHUfSL96JbgTrXyNQfJDsXaquwkM(fdCODtOyEOgkgy3q3c2YEJH3L1WXO4y0ngwiIRlfd2HKsgJb3XWcrCDPyWoKuIJrrum9kHpML4egRi4JjFXyNQfJPsATysCmBBXuWeOpyx5w2l2ZBOBbBzVvNtftmWfd5DzncHDiPKX85cvw61iGKhmX80rMRIGVYBiiDbb8wEppyI5PJmxfbFL3qq6c6bB3lG3Y75btmpDK5Qi4R8gcsxWQI46sEW29ciVBjy7E93Y7vbtmpDK5Qi4R8gcsxqpIuq4bK1MkP18OYs1(vDA3ekyx5w2l2ZBOBbBzVvNtftmWfdvexxQsh4iBC2lJ5ZfQS0RrajpyI5PJmxfbFL3qq6cc4T8EEWeZthzUkc(kVHG0f0d2UxaVL3ZdMyE6iZvrWx5neKUGvfX1L8GT7fqE3sW296VL3RcMyE6iZvrWx5neKUGEePGWdiRnvsR5rLLQ9R60UjuWUYTSxSN3q3c2YERoNkMyGlg(qn2UT0ymFUqLLEnci5btmpDK5Qi4R8gcsxqaVL3ZdMyE6iZvrWx5neKUGEW29c4T8EEWeZthzUkc(kVHG0fS(qn28GT7nyx5w2l2ZBOBbBzVvNtftmWfdFOgB1TzQmMpxOYsVgbK8arjwcFn5jxsaElVNN3q3c2YE9GT7nyx5w2l2ZBOBbBzVvNtftmWfd5QuwvUL9wLj2yCviYLYTKjvnvsRHd2vUL9I98g6wWw2B15uXedCXqEdDlyl7LXcMQ97vbYbDjmJfmvDFMsQYvSLlqxcZy(CDlVNN3q3c2YE9GT7fWJznQS0RrajpyI5PJmxfbFL3qq6cYgB3Y75btmpDK5Qi4R8gcsxqFXHn2UL3ZdMyE6iZvrWx5neKUG1hQXMV4aOPsAnpQSuTFvN2nHaK3TeSDV(B59QGjMNoYCve8vEdbPlOhrki8aaWJznQS0RrajpquILWxtEYLeBSbs3Y75bIsSe(AYtUK8fhaa4Xk3YE9qKrnYNB9jtGNgGk3YE9qKrnYNB9jtGNwfrqAUyw6IPIs9kjpVHUfSL9w5k2QicsZfZgBk3YE9yEJ4NE6aIxSCbcOYTSxpM3i(PNoG4fJQicsZfZsMkk1RK88g6wWw2BLRyRIiinxmBSPCl71)seDvP0thq8ILlqavUL96FjIUQu6PdiEXOkIG0CXSKPIs9kjpVHUfSL9w5k2QicsZfZgBk3YE9oWJ6RuXMNoG4flxGaQCl717apQVsfBE6aIxmQIiinxmlzQOuVsYZBOBbBzVvUITkIG0CXSXMYTSx)tQqe2qPqKNoG4flxGaQCl71)KkeHnuke5PdiEXOkIG0CXSKPIs9kjpVHUfSL9w5k2QicsZfdGGD4mgaA7KqXW7wc2UxCm2PAXGp7IemMlftbtGX4oTZyGDdDlyl7ng8zxKGX0Re(yUumfmbgJ70oJr3yuUvuzmWUHUfSL9gdxXwm6cgZ2wmUt7mgngXYgJatUafehdmLegNlWyCqn3hSRCl7f75n0TGTS3QZPIjg4IHCvkRk3YERYeBmUke5I3q3c2YER8ULGT7fZy(CDlVNN3q3c2YE9icsZflaak2yJ3TeSDVEEdDlyl71JiinxmlfOGDLBzVypVHUfSL9wDovmXaxm8jvicBOuiIX8564B598NTvXgIuH8fhavULmPkTeusyb4IPIs9kjpVHUfSL9wFsfIWgkfIaaBSD8T8E(xIiS1iiFXbqLBjtQslbLewaUyQOuVsYZBOBbBzV1NuHiSHsHOJcvw61iGK)LicBnccab7k3YEXEEdDlyl7T6CQyIbUyOd8O(kvSXy(CDlVNhx2Qq5cexVscJZfyfrki8(IdG3Y75XLTkuUaX1RKW4CbwrKccVhrqAUybWvSvTeIc2vUL9I98g6wWw2B15uXedCXqh4r9vQyJX856wEp)lre2AeKV4eSRCl7f75n0TGTS3QZPIjg4IHoWJ6RuXgJ5Z1T8EEh4rnxQyiFXbWB598oWJAUuXqEebP5IfaxXw1sicWJVL3ZZBOBbBzVEebP5IfaxXw1siIn2UL3ZZBOBbBzVEW29caavULmPkTeusywYurPELKN3q3c2YERpPcrydLcrb7k3YEXEEdDlyl7T6CQyIbUyOd8O(kvSXy(CDlVN)STk2qKkKV4a4T8EEEdDlyl71xCc2vUL9I98g6wWw2B15uXedCXqh4r9vQyJX85YbrmRa5GEH9yEJ4NaElVN)KulxG1IJV4aOYTKjvPLGscZsMkk1RK88g6wWw2B9jvicBOuikyhoJrGfNlWyepZNLlWyGdTBcfdybLlWyGDdDlyl7ngRJbryRrumSsIOyGPuXwm6cgdC4SPnpigwrQqum8tfbKWXW1nMlfZLw6L8uLmgZTyXuWfvkHpMELWhtVXWc7dHpyx5w2l2ZBOBbBzVvNtftmWfdXN5ZYfy1PDtigZNRB5988g6wWw2RV4aiRvUL96FjIQxPInp)urajmGk3sMuLwckjSaCXurPELKN3q3c2YER4Z8z5cS60UjeGk3YE9oNnT5b1NuHiS)vKYkI4NkcivTeIeWRiLvebw4w2lJ5AecvCSA(CPCl71)sevVsfBE(PIasyxk3YE9Ver1RuXMhspOYpveqchSRCl7f75n0TGTS3QZPIjg4IHoNnT5b1NuHimJ5Z1T8EEEdDlyl71xCa0qktswTeIy5T8EEEdDlyl71JiinxmGhFSYTSx)lru9kvS55NkciHzPWaAQKwZ7apQ5sfdbOYTKjvPLGsc7syaWgBS2ujTM3bEuZLkgIn2uULmPkTeusybimaa8wEp)jPwUaRfhFXHbNTvXgIuHQyhskX1CRpzc80y5rc2vUL9I98g6wWw2B15uXedCXWNuHiSHsHigZNRB5988g6wWw2RhSDVaY7wc2UxpVHUfSL96reKMlMLCfBvlHiavULmPkTeusyb4IPIs9kjpVHUfSL9wFsfIWgkfIc2vUL9I98g6wWw2B15uXedCXWxIORkLmMpx3Y755n0TGTSxpy7EbK3TeSDVEEdDlyl71Jiinxml5k2QwcraYAEVGL08pPcrvLZrKL9gSRCl7f75n0TGTS3QZPIjg4IHyEJ4NmMpx3Y755n0TGTSxpIG0CXcGRyRAjeb4T8EEEdDlyl71xCyJTB5988g6wWw2RhSDVaY7wc2UxpVHUfSL96reKMlMLCfBvlHOGDLBzVypVHUfSL9wDovmXaxmuMmZfy92qxgZNRB5988g6wWw2RhrqAUywcKd6H0dau5wYKQ0sqjHfGWb7k3YEXEEdDlyl7T6CQyIbUyiisb2lUErKANmMpx3Y755n0TGTSxpIG0CXSeih0dPha4T8EEEdDlyl71xCc2vUL9I98g6wWw2B15uXedCXqmVr8tgZNltrajZFsQ0o9oCJLUyvagqtL0AEmPOCbwTUWpd2d2vUL9I9O2P6CQyY1tQqe2qPqeJ5ZLYTKjvPLGsclaxmvuQxj5pBRInePcvFsfIWgkfIa84B598NTvXgIuH8fh2y7wEp)lre2AeKV4aGGDLBzVypQDQoNkMyGlg6apQVsfBmMpx3Y75XLTkuUaX1RKW4CbwrKccVV4a4T8EECzRcLlqC9kjmoxGvePGW7reKMlwaCfBvlHOGDLBzVypQDQoNkMyGlg6apQVsfBmMpx3Y75FjIWwJG8fNGDLBzVypQDQoNkMyGlg6apQVsfBmMpx3Y75pBRInePc5lob7WzmcSykMEPyyLerXatPITyifjHpMCJbGOHdXKVyGVlXa2RGwmNktkgkTtcfdajPwUaJrG1jMgfdazBXiAisfkg4jlgDbJHs7KqSymhRaiMtLjfduJOyStDJXC3XOsePGWZymhFbqmNktkgwOKoaBifF0rfehdRuqWhdIuq4JX6ykyIXyAumhZbqmIKIYfymWQl8ZysCmk3sMKpMdzVcAXa2XyNjog3NPKI5urGXWvSLlWyyfPcrydLcr4yAumUpPngXYgJatUafehdmLegNlWysCmisbH3hSRCl7f7rTt15uXedCXWxIO6vQyJXcMQ97vbYbDjmJfmvDFMsQYvSLlqxcZy(CXAMkk1RK8Ver1RuXw1PBzUab8wEppUSvHYfiUELegNlWkIuq49GT7fqLBjtQslbLeMLmvuQxj5pveyLRyR(KkeHnukebiRFjIWMImc5vULmjapM13Y75pj1YfyT44loaY6B598NTvXgIuH8fhazTdIyw73RcKd6FjIQxPInapw5w2R)LiQELk288tfbKWcW1ryJTJnvsR5vjDa2qk(OJIRVccEa5DlbB3RhePa7fxVisTtpIuq4baBSDSPsAnpMuuUaRwx4NaAkciz(tsL2P3HBS0fRcWaaaaiyhoJrGftXWkjIIbMsfBXqPDsOyalOCbgJgdRKi6QsjdHdWJ6RuXwmCfBX4(K2yaij1YfymcSoXK4yuULmPyAumGfuUaJHoG4fJIXDANXiskkxGXaRUWp9b7k3YEXEu7uDovmXaxm8LiQELk2ySGPA)EvGCqxcZybtv3NPKQCfB5c0LWmMpxSMPIs9kj)lru9kvSvD6wMlqaz9lre2uKriVYTKjb4XhFSYTSx)lr0vLspDaXlwUab8yLBzV(xIORkLE6aIxmQIiinxmlbyVaXgBSgvw61iGK)LicBnccaSXMYTSxVd8O(kvS5PdiEXYfiGhRCl717apQVsfBE6aIxmQIiinxmlbyVaXgBSgvw61iGK)LicBnccaaaWB598NKA5cSwC8fhaWgBhBQKwZJjfLlWQ1f(jGMIasM)KuPD6D4glDXQamGhFlVN)KulxG1IJV4aiRvUL96X8gXp90beVy5cKn2y9T8E(Z2QydrQq(IdGS(wEp)jPwUaRfhFXbqLBzVEmVr8tpDaXlwUabK1NTvXgIuHQyhskX1CRpzc80aaaaqWUYTSxSh1ovNtftmWfd5QuwvUL9wLj2yCviYLYTKjvnvsRHd2vUL9I9O2P6CQyIbUyOd8O(kvSXy(CDlVN3bEuZLkgYxCaKRyRAjeXYB598oWJAUuXqEebP5IbKRyRAjeXYB598OYs1(vDA3eYJiinxCWUYTSxSh1ovNtftmWfdDGh1xPIngZNlheXScKd6f2J5nIFc4T8E(tsTCbwlo(IdGMkP18ysr5cSADHFcOPiGK5pjvANEhUXsxSkadOYTKjvPLGscZsMkk1RK8NTvXgIuHQpPcrydLcrb7k3YEXEu7uDovmXaxm05SPnpO(KkeHzmFUyntfL6vsENZM28GQt3YCbc4T8E(tsTCbwlo(IdGS(wEp)zBvSHiviFXbWJvULmPkyB(e4MgXYJWgBk3sMuLwckjSaCXurPELK)urGvUIT6tQqe2qPqeBSPClzsvAjOKWcWftfL6vs(Z2QydrQq1NuHiSHsHiaeSRCl7f7rTt15uXedCXqmVr8tgZNltrajZFsQ0o9oCJLUyvagqtL0AEmPOCbwTUWpd2vUL9I9O2P6CQyIbUyiisb2lUErKANmMpxk3sMuLwckjSaosWUYTSxSh1ovNtftmWfdvexxQsh4iBC2lJ5ZLYTKjvPLGsclaxmvuQxj5vexxQsh4iBC2lGq6QEhUjaxmvuQxj5vexxQsh4iBC2BfsxnyhoJbUkTZyOTlapJXueqYWmgtAXK4y0yaQ5gJ1XWvSfdRivicBOuikgfhZlLscftUyJuWy6xmSsIORkL(GDLBzVypQDQoNkMyGlg(KkeHnukeXy(CPClzsvAjOKWcWftfL6vs(tfbw5k2QpPcrydLcrb7k3YEXEu7uDovmXaxm8Li6QszWEWUYTSxShB6cQiWkQn1YED9KkeHnukeXy(CPClzsvAjOKWcWftfL6vs(Z2QydrQq1NuHiSHsHiap(wEp)zBvSHiviFXHn2UL3Z)seHTgb5loaiyx5w2l2JnDbveyf1MAzVmWfdDGh1xPIngZNRB598VeryRrq(ItWUYTSxShB6cQiWkQn1YEzGlg6apQVsfBmMpx3Y75pBRInePc5loaElVN)STk2qKkKhrqAUywQCl71)seDvP0thq8IrvlHOGDLBzVyp20furGvuBQL9Yaxm0bEuFLk2ymFUUL3ZF2wfBisfYxCa8yheXScKd6f2)seDvPKn2EjIWMImc5vULmj2yt5w2R3bEuFLk285wFYe4PbGGD4mgyHGpgRJbizXikWaZyCqnhhtU4eKIbGOHdX4CQychtJIb2n0TGTS3yCovmHJX9jTX40yCELKpyx5w2l2JnDbveyf1MAzVmWfdDGh1xPIngZNRB5984YwfkxG46vsyCUaRisbH3xCa8yE3sW296rLLQ9R60UjKhrqAUygOCl71Jklv7x1PDtipDaXlgvTeIyaxXw1sisa3Y75XLTkuUaX1RKW4CbwrKccVhrqAUy2yJ1MkP18OYs1(vDA3ecaaYurPELK3siQADL3q3c2YEzaxXw1sisa3Y75XLTkuUaX1RKW4CbwrKccVhrqAU4GDLBzVyp20furGvuBQL9Yaxm0bEuFLk2ymFUUL3ZF2wfBisfYxCa0ueqY8NKkTtVd3yPlwfGb0ujTMhtkkxGvRl8ZGDLBzVyp20furGvuBQL9Yaxm0bEuFLk2ymFUUL3Z7apQ5sfd5loaYvSvTeIy5T8EEh4rnxQyipIG0CXb7WzmhYckxGXyNumytxqfbgdQn1YEzmMELWhtbtXWkjIIbMsfB4yCFsBm2jbFmkIIzBlMlLlWyC6wsGX8AumaenCiMgfdSBOBbBzV(yeyXumSsIOyGPuXwmuANekgWckxGXOXWkjIUQuYq4a8O(kvSfdxXwmUpPngassTCbgJaRtmjogLBjtkMgfdybLlWyOdiEXOyCN2zmIKIYfymWQl8tFWUYTSxShB6cQiWkQn1YEzGlg(sevVsfBmwWuTFVkqoOlHzSGPQ7ZusvUITCb6sygZNlw)seHnfzeYRClzsaYAMkk1RK8Ver1RuXw1PBzUab84Jpw5w2R)Li6QsPNoG4flxGaESYTSx)lr0vLspDaXlgvreKMlMLaSxGyJnwJkl9AeqY)seHTgbba2yt5w2R3bEuFLk280beVy5ceWJvUL96DGh1xPInpDaXlgvreKMlMLaSxGyJnwJkl9AeqY)seHTgbbaaa4T8E(tsTCbwlo(IdayJTJnvsR5XKIYfy16c)eqtrajZFsQ0o9oCJLUyvagWJVL3ZFsQLlWAXXxCaK1k3YE9yEJ4NE6aIxSCbYgBS(wEp)zBvSHiviFXbqwFlVN)KulxG1IJV4aOYTSxpM3i(PNoG4flxGaY6Z2QydrQqvSdjL4AU1NmbEAaaaaiyx5w2l2JnDbveyf1MAzVmWfdDGh1xPIngZNRB598NTvXgIuH8fhanvsR5XKIYfy16c)eqtrajZFsQ0o9oCJLUyvagqLBjtQslbLeMLmvuQxj5pBRInePcvFsfIWgkfIc2vUL9I9ytxqfbwrTPw2ldCXqNZM28G6tQqeMX85I1mvuQxj5DoBAZdQoDlZfiGhZAtL0A(hQHQ2jvv8jHzJnLBjtQslbLewacdaapw5wYKQGT5tGBAelpcBSPClzsvAjOKWcWftfL6vs(tfbw5k2QpPcrydLcrSXMYTKjvPLGsclaxmvuQxj5pBRInePcvFsfIWgkfIaqWUYTSxShB6cQiWkQn1YEzGlgYvPSQCl7TktSX4QqKlLBjtQAQKwdhSRCl7f7XMUGkcSIAtTSxg4IHGifyV46frQDYy(CPClzsvAjOKWcq4GDLBzVyp20furGvuBQL9YaxmeZBe)KX85YueqY8NKkTtVd3yPlwfGb0ujTMhtkkxGvRl8ZGDLBzVyp20furGvuBQL9YaxmurCDPkDGJSXzVmMpxk3sMuLwckjSaCXurPELKxrCDPkDGJSXzVacPR6D4MaCXurPELKxrCDPkDGJSXzVviD1GD4mg4Q0oJH2Ua8mgtrajdZymPftIJrJbOMBmwhdxXwmSIuHiSHsHOyuCmVukjum5InsbJPFXWkjIUQu6d2vUL9I9ytxqfbwrTPw2ldCXWNuHiSHsHigZNlLBjtQslbLewaUyQOuVsYFQiWkxXw9jvicBOuikyx5w2l2JnDbveyf1MAzVmWfdFjIUQu(fXoe)dJJgR(TV9)a]] )

end
