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


    spec:RegisterPack( "Fire", 20210125, [[de153dqius9iuGUeKkkBcaFIankrvDkaYQGuHxbPQzHcDlrvQDjYVqbnmakhJGAzIs5zOKyAIsvUgkjTnaQQVHcqJdGQCouaSoucMhkr3tuSpcO)jQsuhKaKfcj6HqsnrrPQUOOuXgja(OOkHrkQs6KeGALOu9sucLzcPs3uuQKDcj8taQyOOeYsbOspLqtfsYvrjuTvrPs9vivKXkQI9QQ(RugSIdtAXQ0Jr1Kb6YiBwv(mGgTu1PPA1qQO61eKzt0THy3k9BjdxQCCuaTCqphQPt56Qy7OOVlQmErjNhsz9IQez(Ou2VWFH)O6lcQg9rr2aSSjmGjC2y1u2egWyayLS9fn06OVyNYfsbsFXvrOVOa4q6l2POjlf8JQViUoqo9f7nRdZcmKHaDR)Ct8cHHyh5ivZRLd1NXqSJWz4x8ECPjG3)9lcQg9rr2aSSjmGjC2y1u2egWyaYgdWxupwFb)IIocQ)I9oiiT)7xeKW8VidYGXiaoKIj7sbsb7midgtVzDywGHmeOB9NBIxime7ihPAETCO(mgIDeodd2zqgmg219Oq0IjBSkJXKnalBchShSZGmymOUxxGeMfc2zqgmM8ogwCmfZZb2BniHO(IJbQwpbJX61ngtHajlzoc1SQb6umVcgJuXwEJjETGXOxx6gAXCWkqcNc2zqgmM8og0TkmTXWvSfdKyGhhsi0A4yEfmguxi3d28AJjFprjgJbSwbTy6ljymUfZRGXOX8GeUpMSlYOcgdxXgGsb7midgtEht2z1RKIbBqNBXW7jUq(cmMAJrJ5r5I5vqHWX4BmwpfJaIfHUXyvmqc8WPyYvqHKLcM(IshB4pQ(I8c5EWMxBJxLeSYT4pQ(Oq4pQ(Ik38A)IDL51(fPvVsc8JYV9rr2(O6lQCZR9lELvb2EhiAFrA1RKa)O8BFuWkFu9fPvVsc8JYVih6gbD9lEpVxIxi3d28AtNUVOYnV2V4LGyckKVa)2hfzVpQ(Ik38A)IphsxzvGFrA1RKa)O8BFuWQFu9fvU51(f1LtydQYgxLYViT6vsGFu(Tpka8)O6lsRELe4hLFro0nc66xeEw6vqGuYiKUcQYwof2LOvVscmgaI5EEVeLvVEWMxB609fvU51(fnhHA5uy33(OGb8JQViT6vsGFu(fvU51(fbkvqxTcIBxfei9fP3J4wBve6lcuQGUAfe3Ukiq6BFua49r1xKw9kjWpk)IRIqFrFXC4X0RKAmWJU2bPbsmDo9fvU51(f9fZHhtVsQXap6AhKgiX0503(OGb4JQViT6vsGFu(fxfH(IpPIqT61UQzs6lQCZR9l(Kkc1Qx7QMjPV9rHWa2hvFrA1RKa)O8lUkc9fZPcrlbXThSwWVOYnV2VyoviAjiU9G1c(Tpkew4pQ(I0Qxjb(r5xCve6l6l2GhUvqCd0z6l1UKu(fvU51(f9fBWd3kiUb6m9LAxsk)2hfcNTpQ(I0Qxjb(r5xCve6lIp7vwfytriRhnS9fvU51(fXN9kRcSPiK1Jg2(2hfcZkFu9fvU51(fpyQ5gHG)I0Qxjb(r53(2xeKE6rAFu9rHWFu9fPvVsc8JYVih6gbD9lY6yGNLEfeiLaDm37K(Qq0A8cbrxWeT6vsGFrLBETFrEDwJG4osk)2hfz7JQViT6vsGFu(fRUViMSVOYnV2Vitf66vsFrMQ8qFrtL0APNdjSPqJGjA1RKaJbDeZZHe2uOrWeKquFXXG(yYpgEvsWk3M4fY9GnV2eKquFXXGoIj)yeoM8ogMk01RKsc5lO0xGnibE4MxBmOJymvsRLeYxqPVat0QxjbgdGIbqXGoIH1XWRscw52eVqUhS51MGKcIwmOJyUN3lXlK7bBETjWk3gd6J55a7TgKquFXXGoIjBFrqcZHEN51(fZUvORxjfJ1Rwm8AnyjXXKRN2yqDHCpyZRnghhZbtGPyqvVJJr6lfdMmCmOUqUhS51gJvXCPyoycmg9zemgbWHe2uOrWy0fmgTRt6eogRNIriFbL(cSbjWd38AJHPcD9kPySkgRNIbsiQV(cmgEvsWk3gt9Ib1fY9GnV2umciqq38AvPengJXFXG6c5EWMxBmoogqhRxjbgJ174yqNFWwmyYWXy9ummvORxjfJvXOXyocftNITySEkgAbJPEXy9umyh5ivZRn9fzQW2Qi0x0CeQzvJxi3d28A)2hfSYhvFrA1RKa)O8lwDFrenRVOYnV2Vitf66vsFrMkSTkc9fnhHAw14fY9GnV2Vih6gbD9lsmWJ31rGjcPdniPYwbbxD50xeKWCO3zETFXSlvikg8bsXG6c5EWMxBmoogqsQOrGX4VywIajWyUkMaJP2ySEkgcPdniPYwbbxD5udKKkAXWuHUELu6lYuLh6lYuHUELuIq6qdsQSvqWvxo1ajPIwm5Dm5hdVkjyLBteshAqsLTccU6YPe4bQMxBm5Dm8QKGvUnriDObjv2ki4QlNsqcr9fhdGIbDedRJHxLeSYTjcPdniPYwbbxD5ucskiAF7JIS3hvFrA1RKa)O8lwDFrenRVOYnV2Vitf66vsFrMkSTkc9fnhHAw14fY9GnV2Vih6gbD9lsmWJ31rGjGsf0vRG42vbbsFrqcZHEN51(fZ(Kurlguxi3d28AJ5vWyYlKkORwbfehdkvqGu6lYuLh6lYRscw52eqPc6QvqC7QGaPeKquFXF7Jcw9JQViT6vsGFu(fRUViIM1xu5Mx7xKPcD9kPVitf2wfH(IMJqnRA8c5EWMx7xKdDJGU(fnvsRLGNLA1R1v5iyIw9kjWyaiM759s8c5EWMxBcSYTFrqcZHEN51(fZ(Kurlguxi3d28AJ5SMlJbWTyrXqz15qchJ)IXnbXXC6sFrMQ8qFX759sWZsT616QCembje1x83(OaW)JQViT6vsGFu(fRUViIM1xu5Mx7xKPcD9kPVitf2wfH(IMJqnRA8c5EWMx7xKdDJGU(fnvsRLGNLA1R1v5iyIw9kjWyaiM759s8c5EWMxBcSYTXaqm8QKGvUnbpl1QxRRYrWeKquFXXG(yy1yyzmmvORxjLmhHAw14fY9GnV2ViiH5qVZ8A)IzFsQOfdQlK7bBETX8kym6gdLLb1yaCplft9IHfv5iym(lgRNIbW9Sum1lgwuLJGXKRosWy4fcft9EXWRscw52yulgjPylgwngmXRfehZLEfKIb1fY9GnV2yYvhjy6lYuLh6lYRscw52e8SuRETUkhbtqcr9fhd6J5EEVe8SuRETUkhbtGhOAETF7JcgWpQ(I0Qxjb(r5xS6(IiAwFrLBETFrMk01RK(ImvyBve6lAoc1SQXlK7bBETFro0nc66xeEw6vqGuc0XCVt6RcrRXleeDbt0QxjbgdaXCpVxc0XCVt6RcrRXleeDbtGvU9lcsyo07mV2Vy2NKkAXG6c5EWMxBm(lMSVJ5EN0xfIwmOUqq0fmMC1rcgZwwmxkgiPGOfZRGX4wmOrw6lYuLh6lYRscw52098EnqhZ9oPVkeTgVqq0fmbje1x83(OaW7JQViT6vsGFu(fRUViMSVOYnV2Vitf66vsFrMQ8qFX8Jr5MZKA0sioHJHLXWuHUELuIxi3d28AB4E)z(cS1v5iymSXwmk3CMuJwcXjCmSmgMk01RKs8c5EWMxB7jvecBqxikg2ylgMk01RKsMJqnRA8c5EWMxBm5Dmk38At4E)z(cS1v5iy6DKYgKapCZRngbgdVkjyLBt4E)z(cS1v5iyc8avZRngafdaXWuHUELuYCeQzvJxi3d28AJjVJHxLeSYTjCV)mFb26QCembje1xCmcmgLBETjCV)mFb26QCem9oszdsGhU51gdaXKFm8QKGvUnbpl1QxRRYrWeKquFXXK3XWRscw52eU3FMVaBDvocMGeI6logbgdRgdBSfdRJXujTwcEwQvVwxLJGjA1RKaJbqFrqcZHEN51(fZUvORxjfJ1Rwme2Ce1iCm56jRNGXi27pZxGXWIQCemMCUugZLI5GjWyU0RGumOUqUhS51gJJJbskiAPVitf2wfH(I4E)z(cS1v5iy7sVcsnEHCpyZR9BFuWa8r1xKw9kjWpk)ICOBe01V498EjEHCpyZRnbw52yaigwht(XCpVxY3hbxv24kMRGu60fdaXCpVxQVSg2GKkucsk3IbqXaqmmvORxjLW9(Z8fyRRYrW2LEfKA8c5EWMx7xu5Mx7xe37pZxGTUkhb)2hfcdyFu9fPvVsc8JYVih6gbD9lMFm3Z7L4fY9GnV2eyLBJbGyUN3lbpl1QxRRYrWeyLBJbGyYpgMk01RKsMJqnRA8c5EWMxBmSmgklIFmQzocfdBSfdtf66vsjZrOMvnEHCpyZRngbgdVkjyLBtqf011A4ofkuc8avZRngafdGIHn2Ij)yUN3lbpl1QxRRYrW0PlgaIHPcD9kPK5iuZQgVqUhS51gJaJHvaSya0xu5Mx7xeQGUUwd3PqH(2hfcl8hvFrA1RKa)O8lYHUrqx)I3Z7L4fY9GnV2eyLBJbGyUN3lbpl1QxRRYrWeyLBJbGyyQqxVskzoc1SQXlK7bBETXWYyOSi(XOM5i0xu5Mx7xeKuR)wWL(2hfcNTpQ(I0Qxjb(r5xKdDJGU(fzQqxVskzoc1SQXlK7bBETXWYmXWkXaqm3Z7L4fY9GnV2eyLB)Ik38A)IioewqCREnRGi0AF7JcHzLpQ(I0Qxjb(r5x8GPwUExsnUInFb(rHWFrqcZHEN51(ffGcgt2nTwpAqgJ5GPy0yeahsXGsPITy49keifd4b6lWyYUCiSG4yQxmOQGi0AXWvSfJvXOmlhmgU215lWy49keiHtFrLBETFXNdP2vQy7lYHUrqx)Ik38AtioewqCREnRGi0AjklIFmFbgdaX8oszds8EfcKAMJqXK3XOCZRnH4qybXT61ScIqRLOSi(XOgKquFXXWYyYEXaqmSoM(YAydsQqnChjL4MVTN0b2BXaqmSoM759s9L1WgKuHsqs523(Oq4S3hvFrA1RKa)O8lQCZR9lcuQGUAfe3Ukiq6lYHUrqx)ImvORxjLmhHAw14fY9GnV2yeymk38AB8QKGvUnM8ogw9lsVhXT2Qi0xeOubD1kiUDvqG03(Oqyw9JQViT6vsGFu(fvU51(fjKo0GKkBfeC1LtFro0nc66xKPcD9kPK5iuZQgVqUhS51gdlZedtf66vsjcPdniPYwbbxD5udKKkAFXvrOViH0HgKuzRGGRUC6BFuimG)hvFrA1RKa)O8lQCZR9lcuIwxFREnfJDexQMx7xKdDJGU(fzQqxVskzoc1SQXlK7bBETXiWmXWuHUELuQ22btn(XQ37lUkc9fbkrRRVvVMIXoIlvZR9BFuimd4hvFrA1RKa)O8lQCZR9lIOC9cPgUNiRHCWo)lYHUrqx)ImvORxjLmhHAw14fY9GnV2yyzMyy1V4Qi0xer56fsnCprwd5GD(3(OqyaVpQ(I0Qxjb(r5xeKWCO3zETFrb8lMd2xGXOXGncwoym1M3hmfJBecJXOYCkA4yoykMSpKuWNdPyYUjmMKXuhd7Gum1lguxi3d28AtXa4y9emNJjgJPd6f0npVefZb7lWyY(qsbFoKIj7MWysgto36Jb1fY9GnV2yQvIwm(lgb8(i4QYyqTI5kifJJJHw9kjWy0fmgnMdwbsXKRwbTyUumYcBXumjymwpfd4bQMxBm1lgRNI55a7T0xCve6lccjf85qQXKWys(f5q3iORFrMk01RKsMJqnRA8c5EWMxBmcmtmmvORxjLQTDWuJFS69IbGyYpM759s((i4QYgxXCfKsyt5cftMyUN3l57JGRkBCfZvqkHOz1WMYfkg2ylgwhdVwWJBjFFeCvzJRyUcsjA1RKaJHn2IHPcD9kPeVqUhS512QTDWumSXwmmvORxjLmhHAw14fY9GnV2yqFmSAmcmMNdS3Aqcr9fhd6SyuU5124vjbRCBma6lQCZR9lccjf85qQXKWys(TpkeMb4JQViT6vsGFu(fbjmh6DMx7xuSoYyeWax3iym4(6ibJ5sXCWeym(gJgtofTySE1IbSi8kOfJVgbFeKIjNB9XuwpbJP28(GPymOVcrgofdGJ1tWymOVcrgogWkMTSymOdeibJrJb3RqcmgbmQZ(XuBmUXym4kg3IHRBmxkMdMaJb6a7Ty0NrWy0fTykRNGXuBEFWumg0xHil9fxfH(I46iBoW1nc(f5q3iORFrMk01RKsMJqnRA8c5EWMxBmcmtmScGfd6iM8JHPcD9kPuTTdMA8JvVxmcmgalgafdaXKFmSogIbE8Uocmbcjf85qQXKWysgdBSfdVkjyLBtGqsbFoKAmjmMKnwj7L9yazLSLGeI6logbgdRgdG(Ik38A)I46iBoW1nc(TpkYgG9r1xKw9kjWpk)Ik38A)ICD5KSDpV3xKdDJGU(fzDm8AbpUL89rWvLnUI5kiLOvVscmgaIXCekgwgdRgdBSfZ98EjFFeCvzJRyUcsjSPCHIjtm3Z7L89rWvLnUI5kiLq0SAyt5c9fVN3RTkc9fX1r2CGRBETFrqcZHEN51(frf0bcKGXiwhzmcyGRBemgsHs0IjNB9XiG3hbxvgdQvmxbPykym56Png3IjNIJPdsCfBPV9rr2e(JQViT6vsGFu(fvU51(fpyQ5gHG)IGeMd9oZR9lkGncbhJ1RwmGvmBzXCPLEUfdQlK7bBETXG7RJemg05hSfZLI5GjWyQJHDqkM6fdQlK7bBETXOwm4cHIPR81sFro0nc66xKPcD9kPK5iuZQgVqUhS51gJaZedtf66vsPABhm14hREVV9rr2Y2hvFrA1RKa)O8lQCZR9lYRZAee3rs5xeKWCO3zETFX8cYIX6PyY(oM7DsFviAXG6cbrxWyUN3lMthJXCwjHXXWlK7bBETX44yWvTPVih6gbD9lcpl9kiqkb6yU3j9vHO14fcIUGjA1RKaJbGy4vjbRCB6EEVgOJ5EN0xfIwJxii6cMGKcIwmaeZ98EjqhZ9oPVkeTgVqq0fSPqUUucSYTXaqmSoM759sGoM7DsFviAnEHGOly60fdaXWuHUELuYCeQzvJxi3d28AJrGXKnw9BFuKnw5JQViT6vsGFu(f5q3iORFr4zPxbbsjqhZ9oPVkeTgVqq0fmrRELeymaedVkjyLBt3Z71aDm37K(Qq0A8cbrxWeKuq0IbGyUN3lb6yU3j9vHO14fcIUGnfY1LsGvUngaIH1XCpVxc0XCVt6RcrRXleeDbtNUyaigMk01RKsMJqnRA8c5EWMxBmcmMSXQFrLBETFrfY1LAuwDYc71(TpkYw27JQViT6vsGFu(f5q3iORFr4zPxbbsjqhZ9oPVkeTgVqq0fmrRELeymaedVkjyLBt3Z71aDm37K(Qq0A8cbrxWeKuq0IbGyUN3lb6yU3j9vHO14fcIUGThSWwcSYTXaqmSoM759sGoM7DsFviAnEHGOly60fdaXWuHUELuYCeQzvJxi3d28AJrGXKnw9lQCZR9l(Gf2UL0(2hfzJv)O6lsRELe4hLFro0nc66xKPcD9kPK5iuZQgVqUhS51gdlZedG9fvU51(f5Qu2uU512Ko2(IshBTvrOViVqUhS51266vm9TpkYgG)hvFrA1RKa)O8lYHUrqx)I3Z7LGNLA1R1v5iycSYTXaqmSoM759sphsyRGijiPClgaIj)yyQqxVskzoc1SQXlK7bBETXiWmXCpVxcEwQvVwxLJGjWdunV2yaigMk01RKsMJqnRA8c5EWMxBmcmgLBETPNdP2vQyl9oszds8EfcKAMJqXWgBXWuHUELuYCeQzvJxi3d28AJrGX8CG9wdsiQV4ya0xu5Mx7xeEwQvVwxLJGF7JISXa(r1xKw9kjWpk)Iv3xet2xu5Mx7xKPcD9kPV4btT69Aa5GFui8xKPcBRIqFXNdP2vQyR1vL0xGFrqcZHEN51(fZUvORxjfJ1Rwm8AnyjXXiaoKIbLsfBXCWkqkgRIHw8bsX4gogEVcbs4y6QssGX8kymOUqUhS51M(Ihm1Y17sQXvS5lWpke(lYuLh6lYuHUELuYCeQzvJxi3d28AJjVJHvIHLXOCZRn9Ci1UsfBP3rkBqI3RqGuZCekM8ogLBETjCV)mFb26QCem9oszdsGhU51gd6igMk01RKs4E)z(cS1v5iy7sVcsnEHCpyZRngaIHPcD9kPK5iuZQgVqUhS51gdlJ55a7TgKquFXF7JISb49r1xKw9kjWpk)Iv3xet2xu5Mx7xKPcD9kPVitvEOVitf66vsjZrOMvnEHCpyZRngwgJYnV2uxFrRNv7jvecNEhPSbjEVcbsnZrOyY7yuU51MW9(Z8fyRRYrW07iLnibE4MxBmOJyyQqxVskH79N5lWwxLJGTl9ki14fY9GnV2yaigMk01RKsMJqnRA8c5EWMxBmSmMNdS3Aqcr9fhdBSfd8S0RGaPe(SnH8fiUDLeg7lWeT6vsGXWgBXyocfdlJHv)IGeMd9oZR9lMDRqxVskgRxTy41AWsIJHf1x06zfJaivechZbRaPySkgAXhifJB4y49keiHJrHumDvjjWyEfmguxi3d28AtFrMkSTkc9f76lA9SADvj9f43(OiBmaFu9fPvVsc8JYVih6gbD9lEpVxcEwQvVwxLJGPtxmaedtf66vsjZrOMvnEHCpyZRngbgdG9fvU51(f5Qu2uU512Ko2(IshBTvrOViS6AD9kM(2hfScG9r1xKw9kjWpk)Ihm1Y17sQXvS5lWpke(lcsyo07mV2VOaceD(bBXy9ummvORxjfJ1Rwm8AnyjXXiaoKIbLsfBXCWkqkgRIHw8bsX4gogEVcbs4yuifJkXvmDvjjWyEfmga3ZsXuVyyrvocM(Iv3xet2xKdDJGU(fzDmmvORxjLEoKAxPITwxvsFbgdaXyQKwlbpl1QxRRYrWeT6vsGXaqm3Z7LGNLA1R1v5iycSYTFrMQ8qFrEvsWk3MGNLA1R1v5iycsiQV4yyzmk38AtphsTRuXw6DKYgK49kei1mhHIjVJr5MxBc37pZxGTUkhbtVJu2Ge4HBETXGoIj)yyQqxVskH79N5lWwxLJGTl9ki14fY9GnV2yaigEvsWk3MW9(Z8fyRRYrWeKquFXXWYy4vjbRCBcEwQvVwxLJGjiHO(IJbqXaqm8QKGvUnbpl1QxRRYrWeKquFXXWYyEoWERbje1x8x8GPw9EnGCWpke(lQCZR9lYuHUEL0xKPcBRIqFXNdP2vQyR1vL0xGF7Jcwr4pQ(I0Qxjb(r5x8GPwUExsnUInFb(rHWFro0nc66xK1XWuHUELu65qQDLk2ADvj9fymaedtf66vsjZrOMvnEHCpyZRngbgdGfdaXOCZzsnAjeNWXiWmXWuHUELuQxHGnUIT2tQie2GUqumaedRJ55qcBk0iys5MZKIbGyyDm3Z7L6lRHniPcLGKYTyaiM8J5EEVupPMVaBNUeKuUfdaXOCZRn9KkcHnOleLOSi(XOgKquFXXWYyaSeRgdBSfdVxHajC7bvU51QYyeyMyYwma6lEWuREVgqo4hfc)fvU51(fFoKAxPITViiH5qVZ8A)IOt90gtEvHGCfB(cmgbqQiumIg0fIymgbWHumOuQydhdUVosWyUumhmbgJvXaKwcQgftETSyeniPcHJrxWySkgklJwWyqPuXgbJj7sXgbtF7JcwjBFu9fPvVsc8JYV4btTC9UKACfB(c8JcH)ICOBe01V4ZHe2uOrWKYnNjfdaXW7viqchJaZeJWXaqmSogMk01RKsphsTRuXwRRkPVaJbGyYpgwhJYnV20ZH0vLYeLfXpMVaJbGyyDmk38AtDObRRuXwY32t6a7TyaiM759s9KA(cSD6sqs5wmSXwmk38Atphsxvktuwe)y(cmgaIH1XCpVxQVSg2GKkucsk3IHn2Ir5MxBQdnyDLk2s(2EshyVfdaXCpVxQNuZxGTtxcsk3IbGyyDm3Z7L6lRHniPcLGKYTya0x8GPw9EnGCWpke(lQCZR9l(Ci1UsfBFrqcZHEN51(fZ(hOVaJraCiHnfAeKXyeahsXGsPInCmkKI5GjWyWoIlvOeTySkgWd0xGXG6c5EWMxBkM8cAjOkLOXymwpHwmkKI5GjWySkgG0sq1OyYRLfJObjviCm56Pngo0nCm5CPmMTSyUum5uSrGXOlym5CRpgukvSrWyYUuSrqgJX6j0Ib3xhjymxkgChKuWyQJfJvXGO(AQVXy9umOuQyJGXKDPyJGXCpVx6BFuWkSYhvFrA1RKa)O8lEWulxVlPgxXMVa)Oq4ViiH5qVZ8A)IciMLdgdx768fymcGdPyqPuXwm8EfcKWXKR3Lum8EDxs6lWye79N5lWyyrvoc(fvU51(fFoKAxPITVih6gbD9lQCZRnH79N5lWwxLJGjklIFmFbgdaX8oszds8EfcKAMJqXWYyuU51MW9(Z8fyRRYrWK5CHAqc8WnV2yaiM759s9L1WgKuHsGvUngaIXCekgbgJWa23(OGvYEFu9fPvVsc8JYVih6gbD9lYuHUELuYCeQzvJxi3d28AJrGXayXaqm3Z7LGNLA1R1v5iycSYTFrLBETFrUkLnLBETnPJTVO0XwBve6lInDbviydwMAETF7JcwHv)O6lQCZR9lI5fK3)fPvVsc8JYV9TVyhK4fYvTpQ(Oq4pQ(Ik38A)IkKRl181iPK42xKw9kjWpk)2hfz7JQViT6vsGFu(fRUViMSVOYnV2Vitf66vsFrMkSTkc9f7lRHniPc1EsfHWg0fI(ICOBe01Vitf66vsP(YAydsQqTNuriSbDHOyYedG9fbjmh6DMx7xev9oogMk01RKIb3rC)5eogRNIzpixcgt9IXuiqYWXOwm56DEFm51YIr0GKkumcGuriSbDHiCm1XWoift9Ib1fY9GnV2yW91rcgZLI5GjW0xKPkp0xmBXGoIXujTw6jveQ1PgVprRELeymOpgwjg0rmSogtL0APNurOwNA8(eT6vsGF7Jcw5JQViT6vsGFu(fRUViMSVOYnV2Vitf66vsFrMkSTkc9f7viyJRyR9KkcHnOle9f5q3iORFrMk01RKs9keSXvS1EsfHWg0fIIjtma2xeKWCO3zETFru174yyQqxVskgChX9Nt4ySEkM9GCjym1lgtHajdhJAXKR359XKxviymOwXwmcGuriSbDHiCm1XWoift9Ib1fY9GnV2yW91rcgZLI5GjWyuCmpxkjy6lYuLh6lMTyqhXyQKwl9Kkc16uJ3NOvVscmg0hdRed6igwhJPsAT0tQiuRtnEFIw9kjWV9rr27JQViT6vsGFu(fRUViMSVOYnV2Vitf66vsFrMkSTkc9f5fY9GnV22tQie2GUq0xKdDJGU(fzQqxVskXlK7bBETTNuriSbDHOyYedG9fbjmh6DMx7xev9oogMk01RKIb3rC)5eogRNIzpixcgt9IXuiqYWXOwm56DEFm51YIr0GKkumcGuriSbDHiCmkKI5GjWyapqFbgdQlK7bBETPVitvEOViRed6igtL0APNurOwNA8(eT6vsGXG(ya8JbDedRJXujTw6jveQ1PgVprRELe43(OGv)O6lsRELe4hLFXQ7lIj7lQCZR9lYuHUEL0xKPcBRIqFrfY1LAuwDYc71(f5q3iORFrMk01RKskKRl1OS6Kf2RnMmXayFrqcZHEN51(frvVJJHPcD9kPyWDe3FoHJX6Py2dYLGXuVymfcKmCmQftUEN3hJacY1LIj7KvNSWETXuhd7Gum1lguxi3d28AJb3xhjymxkMdMatFrMQ8qFrgagGyqhXyQKwl9Kkc16uJ3NOvVscmg0ht2IbDedRJXujTw6jveQ1PgVprRELe43(OaW)JQViT6vsGFu(fRUViKWK9fvU51(fzQqxVs6lYuHTvrOVOc56snkRozH9ABi6QFrq6PhP9fZEa2xeKWCO3zETFru174yyQqxVskgChX9Nt4ySEkMocYP1uGum1lgeD1yUKSYftUEN3hJacY1LIj7KvNSWETXKZLYy2YI5sXCWey6BFuWa(r1xKw9kjWpk)Iv3xesyY(Ik38A)ImvORxj9fzQW2Qi0xuiFbL(cSbjWd38A)IG0tps7lcyPS3xeKWCO3zETFr0j36JHfZxqPVazmguxi3d28AfehdVkjyLBJjNlLXCPyGe4HtGXCrlgngOUGfsmksDwJXyUhlgRNIzpixcgt9IHdDdhd2uOHJHjbrlMEhyFm6Ziymk3CMQ5lWyqDHCpyZRngDbJblRC4yaRCBmwLtHG4ySEkgAbJPEXG6c5EWMxRG4y4vjbRCBkg0PEAJbrfYxGXasCh71IJX3ySEkgbelcDzmguxi3d28AfehdKquF9fym8QKGvUnghhdKapCcmMlAXy9ooMhu5MxBmwfJY51zTyEfmgwmFbL(cm9Tpka8(O6lsRELe4hLFXQ7lIj7lQCZR9lYuHUEL0xKPkp0xKv)IGeMd9oZR9lIQEkgWdunV2yQxmAmINngwmFbkiogukjm2xGXG6c5EWMxB6lYuHTvrOViwOBd8avZR9BFuWa8r1xKw9kjWpk)Iv3xet2xu5Mx7xKPcD9kPVitvEOViXapExhbMakvqxTcIBxfeifdBSfdXapExhbMquUEHud3tK1qoyNhdBSfdXapExhbM8fZHhtVsQXap6AhKgiX05umSXwmed84DDeycF2RSkWMIqwpAylg2ylgIbE8UocmriDObjv2ki4QlNIHn2IHyGhVRJatpPIqT61UQzskg2ylgIbE8UocmLtfIwcIBpyTGXWgBXqmWJ31rGjFXg8WTcIBGotFP2LKYVitf2wfH(I8c5EWMxBR22btF7JcHbSpQ(I0Qxjb(r5xS6(Iqct2xu5Mx7xKPcD9kPVitf2wfH(IeshAqsLTccU6YPgijv0(IG0tps7lkmG3xeKWCO3zETFX8ALlgzTaJ5sVcsXG6c5EWMxBm4(6ibJj7G0HgKuzmaoqWvxofZLI5GjW8YF7JcHf(JQViT6vsGFu(fRUViMSVOYnV2Vitf66vsFrMkSTkc9fRTDWuJFS69(ICOBe01Vitf66vsjEHCpyZRTvB7GPViiH5qVZ8A)I51kxmYAbgZLEfKIb1fY9GnV2yW91rcgJb9viYWXy9QfJbDGajymAm4EfsGXWvJawq0IHxLeSYTXuBmL1tWymOVcrgoMTSyUumhmbMx(lYuLh6lMna7BFuiC2(O6lsRELe4hLFXQ7lIj7lQCZR9lYuHUEL0xKPkp0xmBS6xKdDJGU(fjg4X76iWeIY1lKA4EISgYb78Vitf2wfH(I12oyQXpw9EF7JcHzLpQ(I0Qxjb(r5xS6(IyY(Ik38A)ImvORxj9fzQYd9fZgGfd6JHPcD9kPeH0HgKuzRGGRUCQbssfTVih6gbD9lsmWJ31rGjcPdniPYwbbxD50xKPcBRIqFXABhm14hREVV9rHWzVpQ(I0Qxjb(r5xS6(Iqct2xu5Mx7xKPcD9kPVitf2wfH(I8c5EWMxBd37pZxGTUkhb)IG0tps7lMTViiH5qVZ8A)IOQNIzpixcgt9IXuiqYWXi27pZxGXWIQCemgCFDKGXCPyoycmMAJb8a9fymOUqUhS51M(2hfcZQFu9fPvVsc8JYVy19fHeMSVOYnV2Vitf66vsFrMkSTkc9f5fY9GnV2gxXwdsiQV4Vii90J0(IawIb8lcsyo07mV2ViQ6PymhHIbsiQV(cmMAJrJHRylMC90gdQlK7bBETXW1nMlfZbtGX4BmyIxlio9TpkegW)JQViT6vsGFu(fxfH(I46iBoW1nc(fvU51(fX1r2CGRBe8BFuimd4hvFrLBETFrehclyZruG0xKw9kjWpk)2hfcd49r1xKw9kjWpk)ICOBe01ViRJPdsmtDObRRuX2xu5Mx7xSdnyDLk2(23(I8c5EWMxBRRxX0hvFui8hvFrA1RKa)O8lYHUrqx)I3Z7L4fY9GnV2eyLB)Ik38A)IshyVHBOZpGarO1(2hfz7JQViT6vsGFu(fpyQLR3LuJRyZxGFui8xeKWCO3zETFXSd2Ce1Oy6RCXiRfymOUqUhS51gtoxkJrQylgRxxHWXyvmINngwmFbkiogukjm2xGXyvmGKrqeFPy6RCXiaoKIbLsfB4yW91rcgZLI5GjW0xS6(IyY(ICOBe01ViVwWJBjFFeCvzJRyUcsjA1RKa)Imv5H(I3Z7L4fY9GnV2eKquFXXG(yUN3lXlK7bBETjWdunV2yqhXKFm8QKGvUnXlK7bBETjiHO(IJHLXCpVxIxi3d28Atqcr9fhdG(Ihm1Q3RbKd(rHWFrLBETFrMk01RK(ImvyBve6lszz0csGnEHCpyZRTbje1x83(OGv(O6lsRELe4hLFXdMA56Dj14k28f4hfc)fbjmh6DMx7xuabcIJX6Pyapq18AJPEXy9umINngwmFbkiogukjm2xGXG6c5EWMxBmwfJ1tXqlym1lgRNIHFGqATyqDHCpyZRng)fJ1tXWvSftU6ibJHxiDsYOyapqFbgJ174yqDHCpyZRn9fRUVOcc(f5q3iORFrETGh3s((i4QYgxXCfKs0QxjbgdaXKFm3Z7LWNTjKVaXTRKWyFb2GKcIw60fdBSfdtf66vsjklJwqcSXlK7bBETniHO(IJrGXiCIvJbDedqoycrZkg0rm5hZ98Ej8zBc5lqC7kjm2xGjenRg2uUqXK3XCpVxcF2Mq(ce3UscJ9fycBkxOyauma6lYuLh6lYuHUELucl0TbEGQ51(fpyQvVxdih8JcH)Ik38A)ImvORxj9fzQW2Qi0xKYYOfKaB8c5EWMxBdsiQV4V9rr27JQViT6vsGFu(f5q3iORFX759s8c5EWMxBcSYTFrLBETFXRcSvVMbDUq4V9rbR(r1xKw9kjWpk)ICOBe01VOYnNj1OLqCchJaJr4yaiM759s8c5EWMxBcSYTFrLBETFrPZ0xGTBHC)2hfa(Fu9fPvVsc8JYV4btTC9UKACfB(c8JcH)ICOBe01ViRJHxl4XTKVpcUQSXvmxbPeT6vsGXaqm8EfcKWXiWmXiCmaeZ98EjEHCpyZRnD6IbGyyDm3Z7LEoKWwbrsqs5wmaedRJ5EEVuFznSbjvOeKuUfdaX0xwdBqsfQH7iPe38T9KoWElg0hZ98EPEsnFb2oDjiPClgwgt2(Ihm1Q3RbKd(rHWFrLBETFXNdP2vQy7lcsyo07mV2Vi6KB91XIraVpcUQmguRyUcsmgd68d2I5GPyeahsXGsPInCm56PngRNqlMC1kOfdYz59XWHUHJrxWyY1tBmcGdjSvqKyCCmGvUn9Tpkya)O6lsRELe4hLFXdMA56Dj14k28f4hfc)fbjmh6DMx7xeDYT(yeW7JGRkJb1kMRGeJXiaoKIbLsfBXCWum4(6ibJ5sXOGGU51QsjAXWRfBq1xcmgCfJ1RwmUfJJJzllMlfZbtGXCwjHXXiG3hbxvgdQvmxbPyCCm6TowmwfdLvNdPykymwpbPyuifdsbPySEDJH26aSpgbWHumOuQydhJvXqzz0cgJaEFeCvzmOwXCfKIXQySEkgAbJPEXG6c5EWMxB6lwDFrmzFro0nc66xKxl4XTKVpcUQSXvmxbPeT6vsGFrMQ8qFrLBETPNdP2vQylX7viqc3EqLBETQmg0ht(XWuHUELuIYYOfKaB8c5EWMxBdsiQV4yY7yUN3l57JGRkBCfZvqkbEGQ51gdGIHHXWRscw520ZHu7kvSLapq18A)Ihm1Q3RbKd(rHWFrLBETFrMk01RK(ImvyBve6lsz1rCJaBphsTRuXg(BFua49r1xKw9kjWpk)Iv3xet2xu5Mx7xKPcD9kPV4btT69Aa5GFui8xKPcBRIqFXLiqcS9Ci1UsfB4Vih6gbD9lYRf84wY3hbxv24kMRGuIw9kjWV4btTC9UKACfB(c8JcH)Imv5H(ICYLXKFmmvORxjLOSmAbjWgVqUhS512GeI6logggt(XCpVxY3hbxv24kMRGuc8avZRnM8ogGCWeIMvmakga9Tpkya(O6lsRELe4hLFXdMA56Dj14k28f4hfc)f5q3iORFrETGh3s((i4QYgxXCfKs0QxjbgdaXW7viqchJaZeJWXaqm5hdtf66vsjkRoIBey75qQDLk2WXiWmXWuHUELuAjcKaBphsTRuXgog2ylgMk01RKsuwgTGeyJxi3d28ABqcr9fhdlZeZ98EjFFeCvzJRyUcsjWdunV2yyJTyUN3l57JGRkBCfZvqkHnLlumSmMSfdBSfZ98EjFFeCvzJRyUcsjiHO(IJHLXaKdMq0SIHn2IHxLeSYTjCV)mFb26QCembjfeTyaigLBotQrlH4eogbMjgMk01RKs8c5EWMxBd37pZxGTUkhbJbGy4ftA11sRdS3ApLIbqXaqm3Z7L4fY9GnV20PlgaIj)yyDm3Z7LEoKWwbrsqs5wmSXwm3Z7L89rWvLnUI5kiLGeI6logwgdGLy1yaumaedRJ5EEVuFznSbjvOeKuUfdaX0xwdBqsfQH7iPe38T9KoWElg0hZ98EPEsnFb2oDjiPClgwgt2(Ihm1Q3RbKd(rHWFrLBETFXNdP2vQy7BFuimG9r1xKw9kjWpk)Ik38A)I86SgbXDKu(fbjmh6DMx7xKfbPofsXK9Dm37K(Qq0Ib1fcIUGX8kymOUqUhS51MIbfLrXy9QfJ1tXa4EwkM6fdlQYrWyEWcjguxi3d28AJHxN1WXO4y0ngbeKRlfdUJKsgJbxXiGGCDPyWDKuIJrHum1krlML4egRq0IXFXy9QfJPsATyCCmBzXCWey6lYHUrqx)IWZsVccKsGoM7DsFviAnEHGOlyIw9kjWyaiM759sGoM7DsFviAnEHGOlycSYTXaqm3Z7LaDm37K(Qq0A8cbrxWMc56sjWk3gdaXWRscw52098EnqhZ9oPVkeTgVqq0fmbjfeTyaigwhJPsATe8SuRETUkhbt0Qxjb(Tpkew4pQ(I0Qxjb(r5xKdDJGU(fHNLEfeiLaDm37K(Qq0A8cbrxWeT6vsGXaqm3Z7LaDm37K(Qq0A8cbrxWeyLBJbGyUN3lb6yU3j9vHO14fcIUGnfY1LsGvUngaIHxLeSYTP759AGoM7DsFviAnEHGOlycskiAXaqmSogtL0Aj4zPw9ADvocMOvVsc8lQCZR9lQqUUuJYQtwyV2V9rHWz7JQViT6vsGFu(f5q3iORFr4zPxbbsjqhZ9oPVkeTgVqq0fmrRELeymaeZ98EjqhZ9oPVkeTgVqq0fmbw52yaiM759sGoM7DsFviAnEHGOly7blSLaRC7xu5Mx7x8blSDlP9TpkeMv(O6lsRELe4hLFro0nc66xeEw6vqGuci0Xs0Ao35skrRELeymaeZ98EjEHCpyZRnbw52VOYnV2V4dwyRTft9BFuiC27JQViT6vsGFu(fvU51(f5Qu2uU512Ko2(IshBTvrOVOYnNj1mvsRH)2hfcZQFu9fPvVsc8JYV4btTC9UKACfB(c8JcH)ICOBe01V498EjEHCpyZRnbw52yaiM8JH1Xapl9kiqkb6yU3j9vHO14fcIUGjA1RKaJHn2I5EEVeOJ5EN0xfIwJxii6cMoDXWgBXCpVxc0XCVt6RcrRXleeDbBpyHT0PlgaIXujTwcEwQvVwxLJGjA1RKaJbGy4vjbRCB6EEVgOJ5EN0xfIwJxii6cMGKcIwmakgaIj)yyDmWZsVccKsaHowIwZ5oxsjA1RKaJHn2IbKUN3lbe6yjAnN7CjLoDXaOyaiM8Jr5MxBcHmQGjFBpPdS3IbGyuU51MqiJkyY32t6a7TgKquFXXWYmXWuHUELuIxi3d28ABCfBniHO(IJHn2Ir5MxBcZliVprzr8J5lWyaigLBETjmVG8(eLfXpg1GeI6logwgdtf66vsjEHCpyZRTXvS1GeI6log2ylgLBETPNdPRkLjklIFmFbgdaXOCZRn9CiDvPmrzr8JrniHO(IJHLXWuHUELuIxi3d28ABCfBniHO(IJHn2Ir5MxBQdnyDLk2suwe)y(cmgaIr5MxBQdnyDLk2suwe)yudsiQV4yyzmmvORxjL4fY9GnV2gxXwdsiQV4yyJTyuU51MEsfHWg0fIsuwe)y(cmgaIr5MxB6jvecBqxikrzr8JrniHO(IJHLXWuHUELuIxi3d28ABCfBniHO(IJbqFXdMA171aYb)Oq4VOYnV2ViVqUhS51(TpkegW)JQViT6vsGFu(fbjmh6DMx7xeWX6jym8QKGvUfhJ1Rwm4(6ibJ5sXCWeym5CRpguxi3d28AJb3xhjym1krlMlfZbtGXKZT(y0ngLBhvgdQlK7bBETXWvSfJUGXSLfto36JrJr8SXWI5lqbXXGsjHX(cmMoyXtFrLBETFrUkLnLBETnPJTVih6gbD9lEpVxIxi3d28Atqcr9fhJaJbWlg2ylgEvsWk3M4fY9GnV2eKquFXXWYyy1VO0XwBve6lYlK7bBETnEvsWk3I)2hfcZa(r1xKw9kjWpk)ICOBe01Vy(XCpVxQVSg2GKkucsk3IbGyuU5mPgTeIt4yeyMyyQqxVskXlK7bBETTNuriSbDHOyaumSXwm5hZ98EPNdjSvqKeKuUfdaXOCZzsnAjeNWXiWmXWuHUELuIxi3d28ABpPIqyd6crXK3Xapl9kiqk9CiHTcIKOvVscmga9fvU51(fFsfHWg0fI(2hfcd49r1xKw9kjWpk)ICOBe01V498Ej8zBc5lqC7kjm2xGniPGOLoDXaqm3Z7LWNTjKVaXTRKWyFb2GKcIwcsiQV4yeymCfBnZrOVOYnV2VyhAW6kvS9TpkeMb4JQViT6vsGFu(f5q3iORFX759sphsyRGijiPC7lQCZR9l2HgSUsfBF7JISbyFu9fPvVsc8JYVih6gbD9lEpVxQdnyXLkgjbjLBXaqm3Z7L6qdwCPIrsqcr9fhJaJHRyRzocfdaXKFm3Z7L4fY9GnV2eKquFXXiWy4k2AMJqXWgBXCpVxIxi3d28AtGvUngafdaXOCZzsnAjeNWXWYyyQqxVskXlK7bBETTNuriSbDHOVOYnV2VyhAW6kvS9TpkYMWFu9fPvVsc8JYVih6gbD9lEpVxQVSg2GKkucsk3IbGyUN3lXlK7bBETPt3xu5Mx7xSdnyDLk2(2hfzlBFu9fPvVsc8JYVih6gbD9l2bjMnGCWKWjmVG8(yaiM759s9KA(cSD6sqs5wmaeJYnNj1OLqCchdlJHPcD9kPeVqUhS512EsfHWg0fI(Ik38A)IDObRRuX23(OiBSYhvFrA1RKa)O8lQCZR9lI79N5lWwxLJGFrFnccpDwZFFrLBETPNdP2vQylX7viqcNr5MxB65qQDLk2siAwnEVcbs4Vih6gbD9lEpVxIxi3d28AtNUyaigwhJYnV20ZHu7kvSL49keiHJbGyuU5mPgTeIt4yeyMyyQqxVskXlK7bBETnCV)mFb26QCemgaIr5MxBQRVO1ZQ9KkcHtVJu2GeVxHaPM5iumcmM3rkBqc8WnV2ViiH5qVZ8A)IS4yFbgJyV)mFbgdlQYrWyapqFbgdQlK7bBETXyvmqcBfKIraCifdkLk2IrxWyyr9fTEwXiasfHIH3RqGeogUUXCPyU0spN7QKXyUhlMd(OsjAXuReTyQngbuLDsF7JISL9(O6lsRELe4hLFro0nc66x8EEVeVqUhS51MoDXaqmguzsYM5iumSmM759s8c5EWMxBcsiQV4yaiM8Jj)yuU51MEoKAxPITeVxHajCmSmgHJbGymvsRL6qdwCPIrs0QxjbgdaXOCZzsnAjeNWXKjgHJbqXWgBXW6ymvsRL6qdwCPIrs0QxjbgdBSfJYnNj1OLqCchJaJr4yaumaeZ98EPEsnFb2oDjiPClg0htFznSbjvOgUJKsCZ32t6a7Tyyzmz7lQCZR9l21x06z1EsfHWF7JISXQFu9fPvVsc8JYVih6gbD9lEpVxIxi3d28AtGvUngaIHxLeSYTjEHCpyZRnbje1xCmSmgUITM5iumaeJYnNj1OLqCchJaZedtf66vsjEHCpyZRT9KkcHnOle9fvU51(fFsfHWg0fI(2hfzdW)JQViT6vsGFu(f5q3iORFX759s8c5EWMxBcSYTXaqm8QKGvUnXlK7bBETjiHO(IJHLXWvS1mhHIbGyyDm8AbpULEsfHAkNdjZRnrRELe4xu5Mx7x85q6Qs53(OiBmGFu9fPvVsc8JYVih6gbD9lEpVxIxi3d28Atqcr9fhJaJHRyRzocfdaXCpVxIxi3d28AtNUyyJTyUN3lXlK7bBETjWk3gdaXWRscw52eVqUhS51MGeI6logwgdxXwZCe6lQCZR9lI5fK3)TpkYgG3hvFrA1RKa)O8lYHUrqx)I3Z7L4fY9GnV2eKquFXXWYyaYbtiAwXaqmk3CMuJwcXjCmcmgH)Ik38A)IsNPVaB3c5(TpkYgdWhvFrA1RKa)O8lYHUrqx)I3Z7L4fY9GnV2eKquFXXWYyaYbtiAwXaqm3Z7L4fY9GnV20P7lQCZR9lccvG1IBxiPw)3(OGvaSpQ(I0Qxjb(r5xKdDJGU(fnfcKSupPsRp1XTyyzMyyfalgaIXujTwctk0xGnRo8(eT6vsGFrLBETFrmVG8(V9TVOYnNj1mvsRH)O6JcH)O6lsRELe4hLFro0nc66xu5MZKA0sioHJrGXiCmaeZ98EjEHCpyZRnbw52yaiM8JHPcD9kPK5iuZQgVqUhS51gJaJHxLeSYTjPZ0xGTBHCtGhOAETXWgBXWuHUELuYCeQzvJxi3d28AJHLzIbWIbqFrLBETFrPZ0xGTBHC)2hfz7JQViT6vsGFu(f5q3iORFrMk01RKsMJqnRA8c5EWMxBmSmtmawmSXwm5hdVkjyLBtiKrfmbEGQ51gdlJHPcD9kPK5iuZQgVqUhS51gdaXW6ymvsRLGNLA1R1v5iyIw9kjWyaumSXwmMkP1sWZsT616QCemrRELeymaeZ98Ej4zPw9ADvocMoDXaqmmvORxjLmhHAw14fY9GnV2yeymk38AtiKrfmXRscw52yyJTyEoWERbje1xCmSmgMk01RKsMJqnRA8c5EWMx7xu5Mx7xeHmQGF7Jcw5JQViT6vsGFu(f5q3iORFrtL0AjvszHnOIZlP427arlrRELeymaet(XCpVxIxi3d28AtGvUngaIH1XCpVxQVSg2GKkucsk3IbqFrLBETFrqOcSwC7cj16)23(Iytxqfc2GLPMx7hvFui8hvFrA1RKa)O8lYHUrqx)Ik3CMuJwcXjCmcmtmmvORxjL6lRHniPc1EsfHWg0fIIbGyYpM759s9L1WgKuHsqs5wmSXwm3Z7LEoKWwbrsqs5wma6lQCZR9l(KkcHnOle9TpkY2hvFrA1RKa)O8lYHUrqx)I3Z7LEoKWwbrsqs52xu5Mx7xSdnyDLk2(2hfSYhvFrA1RKa)O8lYHUrqx)I3Z7L6lRHniPcLGKYTyaiM759s9L1WgKuHsqcr9fhdlJr5MxB65q6QszIYI4hJAMJqFrLBETFXo0G1vQy7BFuK9(O6lsRELe4hLFro0nc66x8EEVuFznSbjvOeKuUfdaXKFmDqIzdihmjC65q6QszmSXwmphsytHgbtk3CMumSXwmk38AtDObRRuXwY32t6a7Tya0xu5Mx7xSdnyDLk2(2hfS6hvFrA1RKa)O8lQCZR9l2HgSUsfBFrqcZHEN51(frfeTySkgGKfJilgkJPdwCCm(IDqkga3IfftxVIjCmfmguxi3d28AJPRxXeoMC90gtxHX(vsPVih6gbD9lEpVxcF2Mq(ce3UscJ9fydskiAPtxmaet(XWRscw52e8SuRETUkhbtqcr9fhd6Jr5MxBcEwQvVwxLJGjklIFmQzocfd6JHRyRzocfJaJ5EEVe(SnH8fiUDLeg7lWgKuq0sqcr9fhdBSfdRJXujTwcEwQvVwxLJGjA1RKaJbqXaqmmvORxjLmhHAw14fY9GnV2yqFmCfBnZrOyeym3Z7LWNTjKVaXTRKWyFb2GKcIwcsiQV4V9rbG)hvFrA1RKa)O8lYHUrqx)I3Z7L6lRHniPcLGKYTyaigtHajl1tQ06tDClgwMjgwbWIbGymvsRLWKc9fyZQdVprRELe4xu5Mx7xSdnyDLk2(2hfmGFu9fPvVsc8JYVih6gbD9lEpVxQdnyXLkgjbjLBXaqmCfBnZrOyyzm3Z7L6qdwCPIrsqcr9f)fvU51(f7qdwxPITV9rbG3hvFrA1RKa)O8lEWulxVlPgxXMVa)Oq4Vih6gbD9lY6yEoKWMcncMuU5mPyaigwhdtf66vsPNdP2vQyR1vL0xGXaqm5ht(XKFmk38Atphsxvktuwe)y(cmgaIj)yuU51MEoKUQuMOSi(XOgKquFXXWYyaSeRgdBSfdRJbEw6vqGu65qcBfejrRELeymakg2ylgLBETPo0G1vQylrzr8J5lWyaiM8Jr5MxBQdnyDLk2suwe)yudsiQV4yyzmawIvJHn2IH1Xapl9kiqk9CiHTcIKOvVscmgafdGIbGyUN3l1tQ5lW2PlbjLBXaOyyJTyYpgtL0AjmPqFb2S6W7t0QxjbgdaXykeizPEsLwFQJBXWYmXWkawmaet(XCpVxQNuZxGTtxcsk3IbGyyDmk38AtyEb59jklIFmFbgdBSfdRJ5EEVuFznSbjvOeKuUfdaXW6yUN3l1tQ5lW2PlbjLBXaqmk38AtyEb59jklIFmFbgdaXW6y6lRHniPc1WDKuIB(2EshyVfdGIbqXaOV4btT69Aa5GFui8xu5Mx7x85qQDLk2(IGeMd9oZR9lM9pqFbgJ1tXGnDbviymWYuZRLXyQvIwmhmfJa4qkgukvSHJjxpTXy9eAXOqkMTSyUKVaJPRkjbgZRGXa4wSOykymOUqUhS51MIHfhtXiaoKIbLsfBXqU1tWyapqFbgJgJa4q6QsjdzrObRRuXwmCfBXKRN2yYRKA(cmgw8UyCCmk3CMumfmgWd0xGXqzr8JrXKZT(yejf6lWyqvD49PV9rbdWhvFrA1RKa)O8lYHUrqx)IDqIzdihmjCcZliVpgaI5EEVupPMVaBNUeKuUfdaXyQKwlHjf6lWMvhEFIw9kjWyaigtHajl1tQ06tDClgwMjgwbWIbGyuU5mPgTeIt4yyzmmvORxjL6lRHniPc1EsfHWg0fI(Ik38A)IDObRRuX23(Oqya7JQViT6vsGFu(f5q3iORFrwhdtf66vsPU(IwpRwxvsFbgdaXKFmSogtL0APhSqAwp1uCpHt0QxjbgdBSfJYnNj1OLqCchJaJr4yaumaet(XOCZzsnWYsoW1nkgwgt2IHn2Ir5MZKA0sioHJrGzIHPcD9kPuVcbBCfBTNuriSbDHOyyJTyuU5mPgTeIt4yeyMyyQqxVsk1xwdBqsfQ9KkcHnOlefdG(Ik38A)ID9fTEwTNuri83(OqyH)O6lsRELe4hLFrLBETFrUkLnLBETnPJTVO0XwBve6lQCZzsntL0A4V9rHWz7JQViT6vsGFu(f5q3iORFrLBotQrlH4eogbgJWFrLBETFrqOcSwC7cj16)2hfcZkFu9fPvVsc8JYVih6gbD9lAkeizPEsLwFQJBXWYmXWkawmaeJPsATeMuOVaBwD49jA1RKa)Ik38A)IyEb59F7JcHZEFu9fPvVsc8JYVih6gbD9lQCZzsnAjeNWXiWmXWuHUELusHCDPgLvNSWETXaqmi6QPoUfJaZedtf66vsjfY1LAuwDYc712q0v)Ik38A)IkKRl1OS6Kf2R9BFuimR(r1xKw9kjWpk)Ik38A)IpPIqyd6crFrqcZHEN51(frNCRpgARdW(ymfcKmmJX4wmoogngGQVXyvmCfBXiasfHWg0fIIrXX8CPKGX4l2ifmM6fJa4q6Qsz6lYHUrqx)Ik3CMuJwcXjCmcmtmmvORxjL6viyJRyR9KkcHnOle9TpkegW)JQVOYnV2V4ZH0vLYViT6vsGFu(TV9fHvxRRxX0hvFui8hvFrA1RKa)O8lYHUrqx)Ik3CMuJwcXjCmcmtmmvORxjL6lRHniPc1EsfHWg0fIIbGyYpM759s9L1WgKuHsqs5wmSXwm3Z7LEoKWwbrsqs5wma6lQCZR9l(KkcHnOle9TpkY2hvFrA1RKa)O8lYHUrqx)I3Z7LWNTjKVaXTRKWyFb2GKcIw60fdaXCpVxcF2Mq(ce3UscJ9fydskiAjiHO(IJrGXWvS1mhH(Ik38A)IDObRRuX23(OGv(O6lsRELe4hLFro0nc66x8EEV0ZHe2kiscsk3(Ik38A)IDObRRuX23(Oi79r1xKw9kjWpk)ICOBe01V498EP(YAydsQqjiPC7lQCZR9l2HgSUsfBF7Jcw9JQViT6vsGFu(fpyQLR3LuJRyZxGFui8xKdDJGU(fzDmmvORxjLEoKAxPITwxvsFbgdaXCpVxcF2Mq(ce3UscJ9fydskiAjWk3gdaXOCZzsnAjeNWXWYyyQqxVsk1RqWgxXw7jvecBqxikgaIH1X8CiHnfAemPCZzsXaqm5hdRJ5EEVupPMVaBNUeKuUfdaXW6yUN3l1xwdBqsfkbjLBXaqmSoMoiXSvVxdihm9Ci1UsfBXaqm5hJYnV20ZHu7kvSL49keiHJrGzIjBXWgBXKFmMkP1sQKYcBqfNxsXT3bIwIw9kjWyaigEvsWk3MaHkWAXTlKuRpbjfeTyaumSXwm5hJPsATeMuOVaBwD49jA1RKaJbGymfcKSupPsRp1XTyyzMyyfalgafdGIbqFXdMA171aYb)Oq4VOYnV2V4ZHu7kvS9fbjmh6DMx7xKfhtXulfJa4qkgukvSfdPqjAX4BmaUflkg)fdA1jgWAf0IPxzsXqU1tWyYRKA(cmgw8Uykym51YIr0GKkumOrwm6cgd5wpbzHyYxbum9ktkgKcsXy96gJLRIrLqsbrJXyY)cOy6vMumcijLf2GkoVKkiogb4arlgiPGOfJvXCWeJXuWyYNdOyejf6lWyqvD49X44yuU5mPumz)Af0IbSIX6DCm56DjftVcbJHRyZxGXiasfHWg0fIWXuWyY1tBmINngwmFbkiogukjm2xGX44yGKcIw6BFua4)r1xKw9kjWpk)Ihm1Y17sQXvS5lWpke(lYHUrqx)ISogMk01RKsphsTRuXwRRkPVaJbGyyDmphsytHgbtk3CMumaet(XKFm5hJYnV20ZH0vLYeLfXpMVaJbGyYpgLBETPNdPRkLjklIFmQbje1xCmSmgalXQXWgBXW6yGNLEfeiLEoKWwbrs0QxjbgdGIHn2Ir5MxBQdnyDLk2suwe)y(cmgaIj)yuU51M6qdwxPITeLfXpg1GeI6logwgdGLy1yyJTyyDmWZsVccKsphsyRGijA1RKaJbqXaOyaiM759s9KA(cSD6sqs5wmakg2ylM8JXujTwctk0xGnRo8(eT6vsGXaqmMcbswQNuP1N64wmSmtmScGfdaXKFm3Z7L6j18fy70LGKYTyaigwhJYnV2eMxqEFIYI4hZxGXWgBXW6yUN3l1xwdBqsfkbjLBXaqmSoM759s9KA(cSD6sqs5wmaeJYnV2eMxqEFIYI4hZxGXaqmSoM(YAydsQqnChjL4MVTN0b2BXaOyauma6lEWuREVgqo4hfc)fvU51(fFoKAxPITViiH5qVZ8A)IS4ykgbWHumOuQylgYTEcgd4b6lWy0yeahsxvkzilcnyDLk2IHRylMC90gtELuZxGXWI3fJJJr5MZKIPGXaEG(cmgklIFmkMCU1hJiPqFbgdQQdVp9Tpkya)O6lsRELe4hLFrLBETFrUkLnLBETnPJTVO0XwBve6lQCZzsntL0A4V9rbG3hvFrA1RKa)O8lYHUrqx)I3Z7L6qdwCPIrsqs5wmaedxXwZCekgwgZ98EPo0GfxQyKeKquFXXaqmCfBnZrOyyzm3Z7LGNLA1R1v5iycsiQV4VOYnV2VyhAW6kvS9Tpkya(O6lsRELe4hLFro0nc66xSdsmBa5GjHtyEb59Xaqm3Z7L6j18fy70LGKYTyaigtL0AjmPqFb2S6W7t0QxjbgdaXykeizPEsLwFQJBXWYmXWkawmaeJYnNj1OLqCchdlJHPcD9kPuFznSbjvO2tQie2GUq0xu5Mx7xSdnyDLk2(2hfcdyFu9fPvVsc8JYVih6gbD9lY6yyQqxVsk11x06z16Qs6lWyaiM759s9KA(cSD6sqs5wmaedRJ5EEVuFznSbjvOeKuUfdaXKFmk3CMudSSKdCDJIHLXKTyyJTyuU5mPgTeIt4yeyMyyQqxVsk1RqWgxXw7jvecBqxikg2ylgLBotQrlH4eogbMjgMk01RKs9L1WgKuHApPIqyd6crXaOVOYnV2VyxFrRNv7jvec)Tpkew4pQ(I0Qxjb(r5xKdDJGU(fnfcKSupPsRp1XTyyzMyyfalgaIXujTwctk0xGnRo8(eT6vsGFrLBETFrmVG8(V9rHWz7JQViT6vsGFu(f5q3iORFrLBotQrlH4eogbgt2(Ik38A)IGqfyT42fsQ1)TpkeMv(O6lsRELe4hLFro0nc66xu5MZKA0sioHJrGzIHPcD9kPKc56snkRozH9AJbGyq0vtDClgbMjgMk01RKskKRl1OS6Kf2RTHOR(fvU51(fvixxQrz1jlSx73(Oq4S3hvFrA1RKa)O8lQCZR9l(KkcHnOle9fbjmh6DMx7xeDYT(yOToa7JXuiqYWmgJBX44y0yaQ(gJvXWvSfJaivecBqxikgfhZZLscgJVyJuWyQxmcGdPRkLPVih6gbD9lQCZzsnAjeNWXiWmXWuHUELuQxHGnUIT2tQie2GUq03(Oqyw9JQVOYnV2V4ZH0vLYViT6vsGFu(TV9TVitcI9A)OiBaw2egWeoBc)fZPW1xG4Vi6KacWffcyuKxWcXedQ6PyCKUcAX8kymccRUwxVIjbJbsmWJdjWyWfcfJEScrncmgEVUajCkyhD9LIHvzHyqDTmjOrGXiOPsATuEemgRIrqtL0AP8KOvVscuWyYpBzbOuWo66lfdGpledQRLjbncmgbnvsRLYJGXyvmcAQKwlLNeT6vsGcgt(cNfGsb7ORVuma(SqmOUwMe0iWyeeEw6vqGukpcgJvXii8S0RGaPuEs0Qxjbkym5NTSaukyhD9LIHbGfIb11YKGgbgJGMkP1s5rWySkgbnvsRLYtIw9kjqbJjFHZcqPGD01xkgHfMfIb11YKGgbgJGMkP1s5rWySkgbnvsRLYtIw9kjqbJrTyYoaoOBm5lCwakfShSJojGaCrHagf5fSqmXGQEkghPRGwmVcgJGG0tpstWyGed84qcmgCHqXOhRquJaJH3RlqcNc2rxFPyeMfIb11YKGgbgJGWZsVccKs5rWySkgbHNLEfeiLYtIw9kjqbJrTyYoaoOBm5lCwakfSJU(sXKnwiguxltcAeymcAQKwlLhbJXQye0ujTwkpjA1RKafmM8ZwwakfSJU(sXWQSqmOUwMe0iWye0ujTwkpcgJvXiOPsATuEs0Qxjbkym5lCwakfSJU(sXa4ZcXG6AzsqJaJrqtL0AP8iymwfJGMkP1s5jrRELeOGXKVWzbOuWo66lfddiledQRLjbncmgbHNLEfeiLYJGXyvmccpl9kiqkLNeT6vsGcgt(cNfGsb7ORVumaESqmOUwMe0iWye0ujTwkpcgJvXiOPsATuEs0Qxjbkym5lCwakfSJU(sXimGhledQRLjbncmgrhb1XGrBnnRyqNHolgRIbDpAmif4rEWXuDeuTcgt(OZaum5lCwakfSJU(sXimGhledQRLjbncmgb51cEClLhbJXQyeKxl4XTuEs0Qxjbkym5lCwakfSJU(sXKnaJfIb11YKGgbgJG8AbpULYJGXyvmcYRf84wkpjA1RKafmM8folaLc2rxFPyYw2yHyqDTmjOrGXii8S0RGaPuEemgRIrq4zPxbbsP8KOvVscuWyYx4SaukyhD9LIjBScledQRLjbncmgbHNLEfeiLYJGXyvmccpl9kiqkLNeT6vsGcgt(cNfGsb7ORVumzl7XcXG6AzsqJaJrq4zPxbbsP8iymwfJGWZsVccKs5jrRELeOGXKVWzbOuWo66lft2a8yHyqDTmjOrGXii8S0RGaPuEemgRIrq4zPxbbsP8KOvVscuWyYx4SaukyhD9LIHvamwiguxltcAeymcAQKwlLhbJXQye0ujTwkpjA1RKafmM8folaLc2d2rNeqaUOqaJI8cwiMyqvpfJJ0vqlMxbJrWoiXlKRAcgdKyGhhsGXGlekg9yfIAeym8EDbs4uWo66lft2yHyqDTmjOrGXiOPsATuEemgRIrqtL0AP8KOvVscuWyYx4SaukyhD9LIjBSqmOUwMe0iWye0ujTwkpcgJvXiOPsATuEs0QxjbkymQft2bWbDJjFHZcqPGD01xkgwHfIb11YKGgbgJGMkP1s5rWySkgbnvsRLYtIw9kjqbJjFHZcqPGD01xkgwHfIb11YKGgbgJGMkP1s5rWySkgbnvsRLYtIw9kjqbJrTyYoaoOBm5lCwakfSJU(sXK9yHyqDTmjOrGXiOPsATuEemgRIrqtL0AP8KOvVscuWyYx4SaukyhD9LIj7XcXG6AzsqJaJrqtL0AP8iymwfJGMkP1s5jrRELeOGXOwmzhah0nM8folaLc2rxFPyyvwiguxltcAeymcAQKwlLhbJXQye0ujTwkpjA1RKafmM8folaLc2rxFPyyvwiguxltcAeymcAQKwlLhbJXQye0ujTwkpjA1RKafmg1Ij7a4GUXKVWzbOuWEWo6KacWffcyuKxWcXedQ6PyCKUcAX8kymcYlK7bBETnEvsWk3IfmgiXapoKaJbxium6Xke1iWy496cKWPGD01xkgaFwiguxltcAeymccpl9kiqkLhbJXQyeeEw6vqGukpjA1RKafmM8folaLc2d2rNeqaUOqaJI8cwiMyqvpfJJ0vqlMxbJrqLBotQzQKwdlymqIbECibgdUqOy0JviQrGXW71fiHtb7ORVumzJfIb11YKGgbgJGMkP1s5rWySkgbnvsRLYtIw9kjqbJj)SLfGsb7ORVumScledQRLjbncmgbnvsRLYJGXyvmcAQKwlLNeT6vsGcgt(cNfGsb7b7OtciaxuiGrrEbletmOQNIXr6kOfZRGXii20fuHGnyzQ51kymqIbECibgdUqOy0JviQrGXW71fiHtb7ORVumSkledQRLjbncmgbnvsRLYJGXyvmcAQKwlLNeT6vsGcgt(cNfGsb7ORVuma(SqmOUwMe0iWye0ujTwkpcgJvXiOPsATuEs0QxjbkymQft2bWbDJjFHZcqPGD01xkgapwiguxltcAeymcAQKwlLhbJXQye0ujTwkpjA1RKafmM8folaLc2rxFPya8yHyqDTmjOrGXii8S0RGaPuEemgRIrq4zPxbbsP8KOvVscuWyYpBzbOuWo66lfddaledQRLjbncmgbnvsRLYJGXyvmcAQKwlLNeT6vsGcgt(cNfGsb7ORVumcdySqmOUwMe0iWye0ujTwkpcgJvXiOPsATuEs0Qxjbkym5lCwakfSJU(sXimRWcXG6AzsqJaJrqtL0AP8iymwfJGMkP1s5jrRELeOGXOwmzhah0nM8folaLc2d2rNeqaUOqaJI8cwiMyqvpfJJ0vqlMxbJrqEHCpyZRT11RysWyGed84qcmgCHqXOhRquJaJH3RlqcNc2rxFPyYgledQRLjbncmgb51cEClLhbJXQyeKxl4XTuEs0QxjbkymQft2bWbDJjFHZcqPGD01xkgwHfIb11YKGgbgJG8AbpULYJGXyvmcYRf84wkpjA1RKafmM8folaLc2rxFPya8zHyqDTmjOrGXiiVwWJBP8iymwfJG8AbpULYtIw9kjqbJjFHZcqPGD01xkggqwiguxltcAeymIocQJbJ2AAwXGolgRIbDpAmGoth71gt1rq1kym5Zqaft(cNfGsb7ORVummGSqmOUwMe0iWyeKxl4XTuEemgRIrqETGh3s5jrRELeOGXOwmzhah0nM8folaLc2rxFPya8yHyqDTmjOrGXi6iOogmARPzfd6SySkg09OXa6mDSxBmvhbvRGXKpdbum5lCwakfSJU(sXa4XcXG6AzsqJaJrqETGh3s5rWySkgb51cEClLNeT6vsGcgJAXKDaCq3yYx4SaukyhD9LIHbGfIb11YKGgbgJG8AbpULYJGXyvmcYRf84wkpjA1RKafmM8folaLc2rxFPyegWyHyqDTmjOrGXiOPsATuEemgRIrqtL0AP8KOvVscuWyulMSdGd6gt(cNfGsb7ORVumcdySqmOUwMe0iWyeeEw6vqGukpcgJvXii8S0RGaPuEs0Qxjbkym5lCwakfSJU(sXiSWSqmOUwMe0iWye0ujTwkpcgJvXiOPsATuEs0QxjbkymQft2bWbDJjFHZcqPGD01xkgHfMfIb11YKGgbgJGWZsVccKs5rWySkgbHNLEfeiLYtIw9kjqbJjFHZcqPGD01xkgHZgledQRLjbncmgbHNLEfeiLYJGXyvmccpl9kiqkLNeT6vsGcgt(cNfGsb7ORVumcZkSqmOUwMe0iWyeeEw6vqGukpcgJvXii8S0RGaPuEs0Qxjbkym5lCwakfSJU(sXimRYcXG6AzsqJaJrqtL0AP8iymwfJGMkP1s5jrRELeOGXKVWzbOuWo66lfJWSkledQRLjbncmgbHNLEfeiLYJGXyvmccpl9kiqkLNeT6vsGcgt(zllaLc2rxFPyeMbKfIb11YKGgbgJGWZsVccKs5rWySkgbHNLEfeiLYtIw9kjqbJjFHZcqPGD01xkMSL9yHyqDTmjOrGXiOPsATuEemgRIrqtL0AP8KOvVscuWyYpBzbOuWo66lft2a8zHyqDTmjOrGXiiVwWJBP8iymwfJG8AbpULYtIw9kjqbJrTyYoaoOBm5lCwakfSJU(sXWkagledQRLjbncmgbnvsRLYJGXyvmcAQKwlLNeT6vsGcgJAXKDaCq3yYx4SaukypyxaJ0vqJaJHbmgLBETXiDSHtb7FXoy9Cj9fzqgmgbWHumzxkqkyNbzWy6nRdZcmKHaDR)Ct8cHHyh5ivZRLd1NXqSJWzyWodYGXWUUhfIwmzJvzmMSbyzt4G9GDgKbJb196cKWSqWodYGXK3XWIJPyEoWERbje1xCmq16jymwVUXykeizjZrOMvnqNI5vWyKk2YBmXRfmg96s3qlMdwbs4uWodYGXK3XGUvHPngUITyGed84qcHwdhZRGXG6c5EWMxBm57jkXymG1kOftFjbJXTyEfmgnMhKW9XKDrgvWy4k2aukyNbzWyY7yYoRELumyd6ClgEpXfYxGXuBmAmpkxmVckeogFJX6PyeqSi0ngRIbsGhoftUckKSuWuWEWodYGXKDYI4hJaJ5sVcsXWlKRAXCjG(ItXiG4CQZWXS1M39ke5DKXOCZRfhtTs0sb7k38AXPoiXlKRAOpddvixxQ5RrsjXTGDgmgu174yyQqxVskgChX9Nt4ySEkM9GCjym1lgtHajdhJAXKR359XKxllgrdsQqXiasfHWg0fIWXuhd7Gum1lguxi3d28AJb3xhjymxkMdMatb7k38AXPoiXlKRAOpddzQqxVsIXvrOm9L1WgKuHApPIqyd6crmwDzWKXO)YWuHUELuQVSg2GKku7jvecBqxikdGXitvEOmzdDyQKwl9Kkc16uJ3JEwbDWAtL0APNurOwNA8(GDgmgu174yyQqxVskgChX9Nt4ySEkM9GCjym1lgtHajdhJAXKR359XKxviymOwXwmcGuriSbDHiCm1XWoift9Ib1fY9GnV2yW91rcgZLI5GjWyuCmpxkjykyx5Mxlo1bjEHCvd9zyitf66vsmUkcLPxHGnUIT2tQie2GUqeJvxgmzm6VmmvORxjL6viyJRyR9KkcHnOleLbWyKPkpuMSHomvsRLEsfHADQX7rpRGoyTPsAT0tQiuRtnEFWodgdQ6DCmmvORxjfdUJ4(ZjCmwpfZEqUemM6fJPqGKHJrTyY178(yYRLfJObjvOyeaPIqyd6cr4yuifZbtGXaEG(cmguxi3d28Atb7k38AXPoiXlKRAOpddzQqxVsIXvrOm8c5EWMxB7jvecBqxiIXQldMmg9xgMk01RKs8c5EWMxB7jvecBqxikdGXitvEOmSc6WujTw6jveQ1PgVh9a(OdwBQKwl9Kkc16uJ3hSZGXGQEhhdtf66vsXG7iU)CchJ1tXShKlbJPEXykeiz4yulMC9oVpgbeKRlft2jRozH9AJPog2bPyQxmOUqUhS51gdUVosWyUumhmbMc2vU51ItDqIxix1qFggYuHUELeJRIqzuixxQrz1jlSxlJvxgmzm6VmmvORxjLuixxQrz1jlSxBgaJrMQ8qzyayaqhMkP1spPIqTo149OpBOdwBQKwl9Kkc16uJ3hSZGXGQEhhdtf66vsXG7iU)CchJ1tX0rqoTMcKIPEXGORgZLKvUyY178(yeqqUUumzNS6Kf2RnMCUugZwwmxkMdMatb7k38AXPoiXlKRAOpddzQqxVsIXvrOmkKRl1OS6Kf2RTHORYii90J0YK9amgRUmqctwWodgd6KB9XWI5lO0xGmgdQlK7bBETcIJHxLeSYTXKZLYyUumqc8WjWyUOfJgduxWcjgfPoRXym3JfJ1tXShKlbJPEXWHUHJbBk0WXWKGOftVdSpg9zemgLBot18fymOUqUhS51gJUGXGLvoCmGvUngRYPqqCmwpfdTGXuVyqDHCpyZRvqCm8QKGvUnfd6upTXGOc5lWyajUJ9AXX4BmwpfJaIfHUmgdQlK7bBETcIJbsiQV(cmgEvsWk3gJJJbsGhobgZfTySEhhZdQCZRngRIr586SwmVcgdlMVGsFbMc2vU51ItDqIxix1qFggYuHUELeJRIqzeYxqPVaBqc8WnVwgbPNEKwgalL9yS6Yajmzb7mymOQNIb8avZRnM6fJgJ4zJHfZxGcIJbLscJ9fymOUqUhS51Mc2vU51ItDqIxix1qFggYuHUELeJRIqzWcDBGhOAETmwDzWKXitvEOmSAWUYnVwCQds8c5Qg6ZWqMk01RKyCvekdVqUhS512QTDWeJvxgmzmYuLhkdXapExhbMakvqxTcIBxfeiXgBed84DDeycr56fsnCprwd5GDoBSrmWJ31rGjFXC4X0RKAmWJU2bPbsmDoXgBed84DDeycF2RSkWMIqwpAyJn2ig4X76iWeH0HgKuzRGGRUCIn2ig4X76iW0tQiuRETRAMKyJnIbE8UocmLtfIwcIBpyTGSXgXapExhbM8fBWd3kiUb6m9LAxskd2zWyYRvUyK1cmMl9kifdQlK7bBETXG7RJemMSdshAqsLXa4abxD5umxkMdMaZlhSRCZRfN6GeVqUQH(mmKPcD9kjgxfHYqiDObjv2ki4QlNAGKurJrq6PhPLryapgRUmqctwWodgtETYfJSwGXCPxbPyqDHCpyZRngCFDKGXyqFfImCmwVAXyqhiqcgJgdUxHeymC1iGfeTy4vjbRCBm1gtz9emgd6RqKHJzllMlfZbtG5Ld2vU51ItDqIxix1qFggYuHUELeJRIqzQTDWuJFS69yS6YGjJrMQ8qzYgGXO)YWuHUELuIxi3d28AB12oykyx5Mxlo1bjEHCvd9zyitf66vsmUkcLP22btn(XQ3JXQldMmgzQYdLjBSkJ(ldXapExhbMquUEHud3tK1qoyNhSRCZRfN6GeVqUQH(mmKPcD9kjgxfHYuB7GPg)y17Xy1LbtgJmv5HYKnad9mvORxjLiKo0GKkBfeC1LtnqsQOXO)YqmWJ31rGjcPdniPYwbbxD5uWodgdQ6Py2dYLGXuVymfcKmCmI9(Z8fymSOkhbJb3xhjymxkMdMaJP2yapqFbgdQlK7bBETPGDLBET4uhK4fYvn0NHHmvORxjX4QiugEHCpyZRTH79N5lWwxLJGmcsp9iTmzJXQldKWKfSZGXGQEkgZrOyGeI6RVaJP2y0y4k2IjxpTXG6c5EWMxBmCDJ5sXCWeym(gdM41cItb7k38AXPoiXlKRAOpddzQqxVsIXvrOm8c5EWMxBJRyRbje1xmJG0tpsldGLyazS6Yajmzb7k38AXPoiXlKRAOpddpyQ5gHW4QiugCDKnh46gbd2vU51ItDqIxix1qFggI4qybBoIcKc2vU51ItDqIxix1qFgg2HgSUsfBm6VmSUdsmtDObRRuXwWEWodYGXKDYI4hJaJHysq0IXCekgRNIr5wbJXXXOmvxQxjLc2vU51IZWRZAee3rsjJ(ldRHNLEfeiLaDm37K(Qq0A8cbrxWGDgmMSBf66vsXy9QfdVwdwsCm56Pnguxi3d28AJXXXCWeykgu174yK(sXGjdhdQlK7bBETXyvmxkMdMaJrFgbJraCiHnfAemgDbJr76KoHJX6PyeYxqPVaBqc8WnV2yyQqxVskgRIX6PyGeI6RVaJHxLeSYTXuVyqDHCpyZRnfJace0nVwvkrJXy8xmOUqUhS51gJJJb0X6vsGXy9oog05hSfdMmCmwpfdtf66vsXyvmAmMJqX0PylgRNIHwWyQxmwpfd2ros18Atb7k38AXOpddzQqxVsIXvrOmMJqnRA8c5EWMxlJvxgmzmYuLhkJPsAT0ZHe2uOrq0XZHe2uOrWeKquFXOpFEvsWk3M4fY9GnV2eKquFXOJ8foVzQqxVskjKVGsFb2Ge4HBETOdtL0AjH8fu6lqabi0bR5vjbRCBIxi3d28AtqsbrdDCpVxIxi3d28AtGvUf9phyV1GeI6lgDKTGDgmMSlvikg8bsXG6c5EWMxBmoogqsQOrGX4VywIajWyUkMaJP2ySEkgcPdniPYwbbxD5udKKkAXWuHUELukyx5Mxlg9zyitf66vsmUkcLXCeQzvJxi3d28AzS6YGOzXitvEOmmvORxjLiKo0GKkBfeC1LtnqsQOL35ZRscw52eH0HgKuzRGGRUCkbEGQ51M38QKGvUnriDObjv2ki4QlNsqcr9fdi0bR5vjbRCBIq6qdsQSvqWvxoLGKcIgJ(ldXapExhbMiKo0GKkBfeC1Ltb7mymzFsQOfdQlK7bBETX8kym5fsf0vRGcIJbLkiqkfSRCZRfJ(mmKPcD9kjgxfHYyoc1SQXlK7bBETmwDzq0SyKPkpugEvsWk3MakvqxTcIBxfeiLGeI6lMr)LHyGhVRJataLkORwbXTRccKc2zWyY(Kurlguxi3d28AJ5SMlJbWTyrXqz15qchJ)IXnbXXC6sb7k38AXOpddzQqxVsIXvrOmMJqnRA8c5EWMxlJvxgenlgzQYdL5EEVe8SuRETUkhbtqcr9fZO)YyQKwlbpl1QxRRYrqaUN3lXlK7bBETjWk3gSZGXK9jPIwmOUqUhS51gZRGXOBmuwguJbW9Sum1lgwuLJGX4VySEkga3ZsXuVyyrvocgtU6ibJHxium17fdVkjyLBJrTyKKITyy1yWeVwqCmx6vqkguxi3d28AJjxDKGPGDLBETy0NHHmvORxjX4QiugZrOMvnEHCpyZRLXQldIMfJmv5HYWRscw52e8SuRETUkhbtqcr9fJ(759sWZsT616QCembEGQ51YO)YyQKwlbpl1QxRRYrqaUN3lXlK7bBETjWk3caVkjyLBtWZsT616QCembje1xm6zvwYuHUELuYCeQzvJxi3d28Ad2zWyY(Kurlguxi3d28AJXFXK9Dm37K(Qq0Ib1fcIUGXKRosWy2YI5sXajfeTyEfmg3IbnYsb7k38AXOpddzQqxVsIXvrOmMJqnRA8c5EWMxlJvxgenlgzQYdLHxLeSYTP759AGoM7DsFviAnEHGOlycsiQVyg9xg4zPxbbsjqhZ9oPVkeTgVqq0feG759sGoM7DsFviAnEHGOlycSYTb7mymz3k01RKIX6vlgcBoIAeoMC9K1tWye79N5lWyyrvocgtoxkJ5sXCWeymx6vqkguxi3d28AJXXXajfeTuWUYnVwm6ZWqMk01RKyCvekdU3FMVaBDvoc2U0RGuJxi3d28AzS6YGjJrMQ8qzYx5MZKA0sioHzjtf66vsjEHCpyZRTH79N5lWwxLJGSXMYnNj1OLqCcZsMk01RKs8c5EWMxB7jvecBqxiIn2yQqxVskzoc1SQXlK7bBET5TYnV2eU3FMVaBDvocMEhPSbjWd38AfiVkjyLBt4E)z(cS1v5iyc8avZRfqaWuHUELuYCeQzvJxi3d28AZBEvsWk3MW9(Z8fyRRYrWeKquFXcu5MxBc37pZxGTUkhbtVJu2Ge4HBETaKpVkjyLBtWZsT616QCembje1xCEZRscw52eU3FMVaBDvocMGeI6lwGSkBSXAtL0Aj4zPw9ADvoccOGDLBETy0NHH4E)z(cS1v5iiJ(lZ98EjEHCpyZRnbw5wayD(3Z7L89rWvLnUI5kiLoDaCpVxQVSg2GKkucsk3aeamvORxjLW9(Z8fyRRYrW2LEfKA8c5EWMxBWUYnVwm6ZWqOc66AnCNcfIr)Lj)759s8c5EWMxBcSYTaCpVxcEwQvVwxLJGjWk3cq(mvORxjLmhHAw14fY9GnVwwszr8JrnZri2yJPcD9kPK5iuZQgVqUhS51kqEvsWk3MGkORR1WDkuOe4bQMxlGaeBSL)98Ej4zPw9ADvocMoDaWuHUELuYCeQzvJxi3d28AfiRayakyx5Mxlg9zyiiPw)TGlXO)YCpVxIxi3d28AtGvUfG759sWZsT616QCembw5wayQqxVskzoc1SQXlK7bBETSKYI4hJAMJqb7k38AXOpddrCiSG4w9AwbrO1y0FzyQqxVskzoc1SQXlK7bBETSmdRaW98EjEHCpyZRnbw52GDgmgbOGXKDtR1JgKXyoykgngbWHumOuQylgEVcbsXaEG(cmMSlhclioM6fdQkicTwmCfBXyvmkZYbJHRDD(cmgEVcbs4uWUYnVwm6ZWWNdP2vQyJXdMA56Dj14k28fygHz0FzuU51MqCiSG4w9AwbrO1suwe)y(ceG3rkBqI3RqGuZCekVvU51MqCiSG4w9AwbrO1suwe)yudsiQVywM9aG19L1WgKuHA4oskXnFBpPdS3aG13Z7L6lRHniPcLGKYTGDLBETy0NHHhm1CJqyKEpIBTvrOmaLkORwbXTRccKy0FzyQqxVskzoc1SQXlK7bBETcKxLeSYT5nRgSRCZRfJ(mm8GPMBecJRIqziKo0GKkBfeC1Ltm6VmmvORxjLmhHAw14fY9GnVwwMHPcD9kPeH0HgKuzRGGRUCQbssfTGDLBETy0NHHhm1CJqyCvekdqjAD9T61um2rCPAETm6VmmvORxjLmhHAw14fY9GnVwbMHPcD9kPuTTdMA8JvVxWUYnVwm6ZWWdMAUrimUkcLbr56fsnCprwd5GDoJ(ldtf66vsjZrOMvnEHCpyZRLLzy1GDgmgb8lMd2xGXOXGncwoym1M3hmfJBecJXOYCkA4yoykMSpKuWNdPyYUjmMKXuhd7Gum1lguxi3d28AtXa4y9emNJjgJPd6f0npVefZb7lWyY(qsbFoKIj7MWysgto36Jb1fY9GnV2yQvIwm(lgb8(i4QYyqTI5kifJJJHw9kjWy0fmgnMdwbsXKRwbTyUumYcBXumjymwpfd4bQMxBm1lgRNI55a7TuWUYnVwm6ZWWdMAUrimUkcLbesk4ZHuJjHXKKr)LHPcD9kPK5iuZQgVqUhS51kWmmvORxjLQTDWuJFS69ai)759s((i4QYgxXCfKsyt5cL5EEVKVpcUQSXvmxbPeIMvdBkxi2yJ18AbpUL89rWvLnUI5kiXgBmvORxjL4fY9GnV2wTTdMyJnMk01RKsMJqnRA8c5EWMxl6zvb(CG9wdsiQVy0zOZ4vjbRClGc2zWyeRJmgbmW1ncgdUVosWyUumhmbgJVXOXKtrlgRxTyalcVcAX4RrWhbPyY5wFmL1tWyQnVpykgd6RqKHtXa4y9emgd6RqKHJbSIzllgd6absWy0yW9kKaJraJ6SFm1gJBmgdUIXTy46gZLI5GjWyGoWElg9zemgDrlMY6jym1M3hmfJb9viYsb7k38AXOpddpyQ5gHW4QiugCDKnh46gbz0FzyQqxVskzoc1SQXlK7bBETcmdRayOJ8zQqxVskvB7GPg)y17jqadqaKpRjg4X76iWeiKuWNdPgtcJjjBSXRscw52eiKuWNdPgtcJjzJvYEzpgqwjBjiHO(IfiRcOGDgmgubDGajymI1rgJag46gbJHuOeTyY5wFmc49rWvLXGAfZvqkMcgtUEAJXTyYP4y6GexXwkyx5Mxlg9zyixxojB3Z7X4QiugCDKnh46MxlJ(ldR51cECl57JGRkBCfZvqcaZriwYQSX298EjFFeCvzJRyUcsjSPCHYCpVxY3hbxv24kMRGucrZQHnLluWodgJa2ieCmwVAXawXSLfZLw65wmOUqUhS51gdUVosWyqNFWwmxkMdMaJPog2bPyQxmOUqUhS51gJAXGlekMUYxlfSRCZRfJ(mm8GPMBecMr)LHPcD9kPK5iuZQgVqUhS51kWmmvORxjLQTDWuJFS69c2zWyYlilgRNIj77yU3j9vHOfdQleeDbJ5EEVyoDmgZzLeghdVqUhS51gJJJbx1Mc2vU51IrFggYRZAee3rsjJ(ld8S0RGaPeOJ5EN0xfIwJxii6ccaVkjyLBt3Z71aDm37K(Qq0A8cbrxWeKuq0a4EEVeOJ5EN0xfIwJxii6c2uixxkbw5way998EjqhZ9oPVkeTgVqq0fmD6aGPcD9kPK5iuZQgVqUhS51kWSXQb7k38AXOpddvixxQrz1jlSxlJ(ld8S0RGaPeOJ5EN0xfIwJxii6ccaVkjyLBt3Z71aDm37K(Qq0A8cbrxWeKuq0a4EEVeOJ5EN0xfIwJxii6c2uixxkbw5way998EjqhZ9oPVkeTgVqq0fmD6aGPcD9kPK5iuZQgVqUhS51kWSXQb7k38AXOpddFWcB3sAm6VmWZsVccKsGoM7DsFviAnEHGOlia8QKGvUnDpVxd0XCVt6RcrRXleeDbtqsbrdG759sGoM7DsFviAnEHGOly7blSLaRClaS(EEVeOJ5EN0xfIwJxii6cMoDaWuHUELuYCeQzvJxi3d28Afy2y1GDLBETy0NHHCvkBk38ABshBmUkcLHxi3d28ABD9kMy0FzyQqxVskzoc1SQXlK7bBETSmdGfSRCZRfJ(mmeEwQvVwxLJGm6Vm3Z7LGNLA1R1v5iycSYTaW6759sphsyRGijiPCdG8zQqxVskzoc1SQXlK7bBETcmZ98Ej4zPw9ADvocMapq18AbGPcD9kPK5iuZQgVqUhS51kqLBETPNdP2vQyl9oszds8EfcKAMJqSXgtf66vsjZrOMvnEHCpyZRvGphyV1GeI6lgqb7mymz3k01RKIX6vlgETgSK4yeahsXGsPITyoyfifJvXql(aPyCdhdVxHajCmDvjjWyEfmguxi3d28Atb7k38AXOpddzQqxVsIXdMA171aYbZimJhm1Y17sQXvS5lWmcZ4QiuMNdP2vQyR1vL0xGmwDzWKXitvEOmmvORxjLmhHAw14fY9GnV28MvyPYnV20ZHu7kvSLEhPSbjEVcbsnZrO8w5MxBc37pZxGTUkhbtVJu2Ge4HBETOdMk01RKs4E)z(cS1v5iy7sVcsnEHCpyZRfaMk01RKsMJqnRA8c5EWMxllFoWERbje1xCWodgt2TcD9kPySE1IHxRbljogwuFrRNvmcGuriCmhScKIXQyOfFGumUHJH3RqGeogfsX0vLKaJ5vWyqDHCpyZRnfSRCZRfJ(mmKPcD9kjgxfHY01x06z16Qs6lqgRUmyYyKPkpugMk01RKsMJqnRA8c5EWMxllvU51M66lA9SApPIq407iLniX7viqQzocL3k38At4E)z(cS1v5iy6DKYgKapCZRfDWuHUELuc37pZxGTUkhbBx6vqQXlK7bBETaWuHUELuYCeQzvJxi3d28Az5Zb2BniHO(IzJn4zPxbbsj8zBc5lqC7kjm2xGSXM5ielz1GDLBETy0NHHCvkBk38ABshBmUkcLbwDTUEftm6Vm3Z7LGNLA1R1v5iy60batf66vsjZrOMvnEHCpyZRvGawWodgJaceD(bBXy9ummvORxjfJ1Rwm8AnyjXXiaoKIbLsfBXCWkqkgRIHw8bsX4gogEVcbs4yuifJkXvmDvjjWyEfmga3ZsXuVyyrvocMc2vU51IrFggYuHUELeJhm1Q3RbKdMrygpyQLR3LuJRyZxGzeMXvrOmphsTRuXwRRkPVazS6YGjJrMQ8qz4vjbRCBcEwQvVwxLJGjiHO(IzPYnV20ZHu7kvSLEhPSbjEVcbsnZrO8w5MxBc37pZxGTUkhbtVJu2Ge4HBETOJ8zQqxVskH79N5lWwxLJGTl9ki14fY9GnVwa4vjbRCBc37pZxGTUkhbtqcr9fZsEvsWk3MGNLA1R1v5iycsiQVyabaVkjyLBtWZsT616QCembje1xmlFoWERbje1xmJ(ldRzQqxVsk9Ci1UsfBTUQK(ceatL0Aj4zPw9ADvoccW98Ej4zPw9ADvocMaRCBWodgd6upTXKxviixXMVaJraKkcfJObDHigJraCifdkLk2WXG7RJemMlfZbtGXyvmaPLGQrXKxllgrdsQq4y0fmgRIHYYOfmgukvSrWyYUuSrWuWUYnVwm6ZWWNdP2vQyJXdMA171aYbZimJhm1Y17sQXvS5lWmcZO)YWAMk01RKsphsTRuXwRRkPVabGPcD9kPK5iuZQgVqUhS51kqadaLBotQrlH4ewGzyQqxVsk1RqWgxXw7jvecBqxicaw)CiHnfAemPCZzsaW6759s9L1WgKuHsqs5ga5FpVxQNuZxGTtxcsk3aq5MxB6jvecBqxikrzr8JrniHO(IzjGLyv2yJ3RqGeU9Gk38AvPaZKnafSZGXK9pqFbgJa4qcBk0iiJXiaoKIbLsfB4yuifZbtGXGDexQqjAXyvmGhOVaJb1fY9GnV2um5f0sqvkrJXySEcTyuifZbtGXyvmaPLGQrXKxllgrdsQq4yY1tBmCOB4yY5szmBzXCPyYPyJaJrxWyY5wFmOuQyJGXKDPyJGmgJ1tOfdUVosWyUum4oiPGXuhlgRIbr91uFJX6PyqPuXgbJj7sXgbJ5EEVuWUYnVwm6ZWWNdP2vQyJXdMA171aYbZimJhm1Y17sQXvS5lWmcZO)Y8CiHnfAemPCZzsaW7viqclWmcdaRzQqxVsk9Ci1UsfBTUQK(ceG8zTYnV20ZH0vLYeLfXpMVabG1k38AtDObRRuXwY32t6a7naUN3l1tQ5lW2PlbjLBSXMYnV20ZH0vLYeLfXpMVabG13Z7L6lRHniPcLGKYn2yt5MxBQdnyDLk2s(2EshyVbW98EPEsnFb2oDjiPCdawFpVxQVSg2GKkucsk3auWodgJaIz5GXW1UoFbgJa4qkgukvSfdVxHajCm56DjfdVx3LK(cmgXE)z(cmgwuLJGb7k38AXOpddFoKAxPIngpyQLR3LuJRyZxGzeMr)Lr5MxBc37pZxGTUkhbtuwe)y(ceG3rkBqI3RqGuZCeILk38At4E)z(cS1v5iyYCUqnibE4Mxla3Z7L6lRHniPcLaRClaMJqcuyalyx5Mxlg9zyixLYMYnV2M0XgJRIqzWMUGkeSbltnVwg9xgMk01RKsMJqnRA8c5EWMxRabmaUN3lbpl1QxRRYrWeyLBd2vU51IrFggI5fK3hShSRCZRfNuU5mPMPsAnCgPZ0xGTBHCz0FzuU5mPgTeItybkma3Z7L4fY9GnV2eyLBbiFMk01RKsMJqnRA8c5EWMxRa5vjbRCBs6m9fy7wi3e4bQMxlBSXuHUELuYCeQzvJxi3d28Azzgadqb7k38AXjLBotQzQKwdJ(mmeHmQGm6VmmvORxjLmhHAw14fY9GnVwwMbWyJT85vjbRCBcHmQGjWdunVwwYuHUELuYCeQzvJxi3d28AbG1MkP1sWZsT616QCeeqSXMPsATe8SuRETUkhbb4EEVe8SuRETUkhbtNoayQqxVskzoc1SQXlK7bBETcu5MxBcHmQGjEvsWk3YgBphyV1GeI6lMLmvORxjLmhHAw14fY9GnV2GDLBET4KYnNj1mvsRHrFggccvG1IBxiPwpJ(lJPsATKkPSWguX5LuC7DGObq(3Z7L4fY9GnV2eyLBbG13Z7L6lRHniPcLGKYnafShSRCZRfN4fY9GnV2gVkjyLBXz6kZRnyx5MxloXlK7bBETnEvsWk3IrFggELvb2EhiAb7k38AXjEHCpyZRTXRscw5wm6ZWWlbXeuiFbYO)YCpVxIxi3d28AtNUGDLBET4eVqUhS5124vjbRClg9zy4ZH0vwfyWUYnVwCIxi3d28AB8QKGvUfJ(mmuxoHnOkBCvkd2vU51It8c5EWMxBJxLeSYTy0NHHMJqTCkSJr)LbEw6vqGuYiKUcQYwof2bW98EjkRE9GnV20Plyx5MxloXlK7bBETnEvsWk3IrFggEWuZncHr69iU1wfHYauQGUAfe3Ukiqkyx5MxloXlK7bBETnEvsWk3IrFggEWuZncHXvrOm(I5WJPxj1yGhDTdsdKy6Ckyx5MxloXlK7bBETnEvsWk3IrFggEWuZncHXvrOmpPIqT61UQzskyx5MxloXlK7bBETnEvsWk3IrFggEWuZncHXvrOm5uHOLG42dwlyWUYnVwCIxi3d28AB8QKGvUfJ(mm8GPMBecJRIqz8fBWd3kiUb6m9LAxskd2vU51It8c5EWMxBJxLeSYTy0NHHhm1CJqyCvekd(SxzvGnfHSE0WwWUYnVwCIxi3d28AB8QKGvUfJ(mm8GPMBecoypyx5MxloXlK7bBETTUEftzKoWEd3qNFabIqRXO)YCpVxIxi3d28AtGvUnyNbJj7GnhrnkM(kxmYAbgdQlK7bBETXKZLYyKk2IX61viCmwfJ4zJHfZxGcIJbLscJ9fymwfdizeeXxkM(kxmcGdPyqPuXgogCFDKGXCPyoycmfSRCZRfN4fY9GnV2wxVIj0NHHmvORxjX4btT69Aa5GzeMXdMA56Dj14k28fygHzCvekdLLrlib24fY9GnV2gKquFXmwDzWKXitvEOm3Z7L4fY9GnV2eKquFXO)EEVeVqUhS51Mapq18Arh5ZRscw52eVqUhS51MGeI6lML3Z7L4fY9GnV2eKquFXaIr)LHxl4XTKVpcUQSXvmxbPGDgmgbeiiogRNIb8avZRnM6fJ1tXiE2yyX8fOG4yqPKWyFbgdQlK7bBETXyvmwpfdTGXuVySEkg(bcP1Ib1fY9GnV2y8xmwpfdxXwm5QJemgEH0jjJIb8a9fymwVJJb1fY9GnV2uWUYnVwCIxi3d28ABD9kMqFggYuHUELeJhm1Q3RbKdMrygpyQLR3LuJRyZxGzeMXvrOmuwgTGeyJxi3d28ABqcr9fZy1LrbbzKPkpugMk01RKsyHUnWdunVwg9xgETGh3s((i4QYgxXCfKai)759s4Z2eYxG42vsySVaBqsbrlD6yJnMk01RKsuwgTGeyJxi3d28ABqcr9flqHtSk6aihmHOzHoY)EEVe(SnH8fiUDLeg7lWeIMvdBkxO8(EEVe(SnH8fiUDLeg7lWe2uUqacqb7k38AXjEHCpyZRT11Ryc9zy4vb2QxZGoximJ(lZ98EjEHCpyZRnbw52GDLBET4eVqUhS51266vmH(mmu6m9fy7wixg9xgLBotQrlH4ewGcdW98EjEHCpyZRnbw52GDgmg0j36RJfJaEFeCvzmOwXCfKymg05hSfZbtXiaoKIbLsfB4yY1tBmwpHwm5QvqlgKZY7JHdDdhJUGXKRN2yeahsyRGiX44yaRCBkyx5MxloXlK7bBETTUEftOpddFoKAxPIngpyQvVxdihmJWmEWulxVlPgxXMVaZimJ(ldR51cECl57JGRkBCfZvqcaEVcbsybMryaUN3lXlK7bBETPthaS(EEV0ZHe2kiscsk3aG13Z7L6lRHniPcLGKYna6lRHniPc1WDKuIB(2EshyVH(759s9KA(cSD6sqs5glZwWodgd6KB9XiG3hbxvgdQvmxbjgJraCifdkLk2I5GPyW91rcgZLIrbbDZRvLs0IHxl2GQVeym4kgRxTyClghhZwwmxkMdMaJ5SscJJraVpcUQmguRyUcsX44y0BDSySkgkRohsXuWySEcsXOqkgKcsXy96gdT1byFmcGdPyqPuXgogRIHYYOfmgb8(i4QYyqTI5kifJvXy9um0cgt9Ib1fY9GnV2uWUYnVwCIxi3d28ABD9kMqFggYuHUELeJhm1Q3RbKdMrygpyQLR3LuJRyZxGzeMXvrOmuwDe3iW2ZHu7kvSHzS6YGjJrMQ8qzuU51MEoKAxPITeVxHajC7bvU51Qs0Nptf66vsjklJwqcSXlK7bBETniHO(IZ7759s((i4QYgxXCfKsGhOAETacDgVkjyLBtphsTRuXwc8avZRLr)LHxl4XTKVpcUQSXvmxbPGDLBET4eVqUhS51266vmH(mmKPcD9kjgpyQvVxdihmJWmEWulxVlPgxXMVaZimJRIqzwIajW2ZHu7kvSHzS6YGjJrMQ8qz4KlZNPcD9kPeLLrlib24fY9GnV2gKquFXOZY)EEVKVpcUQSXvmxbPe4bQMxBEdKdMq0SaeGy0Fz41cECl57JGRkBCfZvqkyx5MxloXlK7bBETTUEftOpddFoKAxPIngpyQvVxdihmJWmEWulxVlPgxXMVaZimJ(ldVwWJBjFFeCvzJRyUcsaW7viqclWmcdq(mvORxjLOS6iUrGTNdP2vQydlWmmvORxjLwIajW2ZHu7kvSHzJnMk01RKsuwgTGeyJxi3d28ABqcr9fZYm3Z7L89rWvLnUI5kiLapq18AzJT759s((i4QYgxXCfKsyt5cXYSXgB3Z7L89rWvLnUI5kiLGeI6lMLa5Gjenl2yJxLeSYTjCV)mFb26QCembjfenauU5mPgTeItybMHPcD9kPeVqUhS512W9(Z8fyRRYrqa4ftA11sRdS3ApLaea3Z7L4fY9GnV20PdG8z998EPNdjSvqKeKuUXgB3Z7L89rWvLnUI5kiLGeI6lMLawIvbeaS(EEVuFznSbjvOeKuUbqFznSbjvOgUJKsCZ32t6a7n0FpVxQNuZxGTtxcsk3yz2c2zWyyrqQtHumzFhZ9oPVkeTyqDHGOlymVcgdQlK7bBETPyqrzumwVAXy9umaUNLIPEXWIQCemMhSqIb1fY9GnV2y41znCmkogDJrab56sXG7iPKXyWvmciixxkgChjL4yuiftTs0IzjoHXkeTy8xmwVAXyQKwlghhZwwmhmbMc2vU51It8c5EWMxBRRxXe6ZWqEDwJG4oskz0FzGNLEfeiLaDm37K(Qq0A8cbrxqaUN3lb6yU3j9vHO14fcIUGjWk3cW98EjqhZ9oPVkeTgVqq0fSPqUUucSYTaWRscw52098EnqhZ9oPVkeTgVqq0fmbjfenayTPsATe8SuRETUkhbd2vU51It8c5EWMxBRRxXe6ZWqfY1LAuwDYc71YO)Yapl9kiqkb6yU3j9vHO14fcIUGaCpVxc0XCVt6RcrRXleeDbtGvUfG759sGoM7DsFviAnEHGOlytHCDPeyLBbGxLeSYTP759AGoM7DsFviAnEHGOlycskiAaWAtL0Aj4zPw9ADvocgSRCZRfN4fY9GnV2wxVIj0NHHpyHTBjng9xg4zPxbbsjqhZ9oPVkeTgVqq0feG759sGoM7DsFviAnEHGOlycSYTaCpVxc0XCVt6RcrRXleeDbBpyHTeyLBd2vU51It8c5EWMxBRRxXe6ZWWhSWwBlMkJ(ld8S0RGaPeqOJLO1CUZLea3Z7L4fY9GnV2eyLBd2vU51It8c5EWMxBRRxXe6ZWqUkLnLBETnPJngxfHYOCZzsntL0A4GDLBET4eVqUhS51266vmH(mmKxi3d28Az8GPw9EnGCWmcZ4btTC9UKACfB(cmJWm6Vm3Z7L4fY9GnV2eyLBbiFwdpl9kiqkb6yU3j9vHO14fcIUGSX298EjqhZ9oPVkeTgVqq0fmD6yJT759sGoM7DsFviAnEHGOly7blSLoDayQKwlbpl1QxRRYrqa4vjbRCB6EEVgOJ5EN0xfIwJxii6cMGKcIgGaiFwdpl9kiqkbe6yjAnN7CjXgBG098EjGqhlrR5CNlP0PdqaKVYnV2eczubt(2EshyVbGYnV2eczubt(2EshyV1GeI6lMLzyQqxVskXlK7bBETnUITgKquFXSXMYnV2eMxqEFIYI4hZxGaOCZRnH5fK3NOSi(XOgKquFXSKPcD9kPeVqUhS5124k2Aqcr9fZgBk38Atphsxvktuwe)y(ceaLBETPNdPRkLjklIFmQbje1xmlzQqxVskXlK7bBETnUITgKquFXSXMYnV2uhAW6kvSLOSi(X8fiak38AtDObRRuXwIYI4hJAqcr9fZsMk01RKs8c5EWMxBJRyRbje1xmBSPCZRn9KkcHnOleLOSi(X8fiak38AtpPIqyd6crjklIFmQbje1xmlzQqxVskXlK7bBETnUITgKquFXakyNbJbWX6jym8QKGvUfhJ1Rwm4(6ibJ5sXCWeym5CRpguxi3d28AJb3xhjym1krlMlfZbtGXKZT(y0ngLBhvgdQlK7bBETXWvSfJUGXSLfto36JrJr8SXWI5lqbXXGsjHX(cmMoyXtb7k38AXjEHCpyZRT11Ryc9zyixLYMYnV2M0XgJRIqz4fY9GnV2gVkjyLBXm6Vm3Z7L4fY9GnV2eKquFXceWJn24vjbRCBIxi3d28Atqcr9fZswnyx5MxloXlK7bBETTUEftOpddFsfHWg0fIy0FzY)EEVuFznSbjvOeKuUbGYnNj1OLqCclWmmvORxjL4fY9GnV22tQie2GUqeGyJT8VN3l9CiHTcIKGKYnauU5mPgTeItybMHPcD9kPeVqUhS512EsfHWg0fIYB4zPxbbsPNdjSvqeafSRCZRfN4fY9GnV2wxVIj0NHHDObRRuXgJ(lZ98Ej8zBc5lqC7kjm2xGniPGOLoDaCpVxcF2Mq(ce3UscJ9fydskiAjiHO(IfixXwZCekyx5MxloXlK7bBETTUEftOpdd7qdwxPIng9xM759sphsyRGijiPClyx5MxloXlK7bBETTUEftOpdd7qdwxPIng9xM759sDOblUuXijiPCdG759sDOblUuXijiHO(IfixXwZCecG8VN3lXlK7bBETjiHO(IfixXwZCeIn2UN3lXlK7bBETjWk3ciauU5mPgTeItywYuHUELuIxi3d28ABpPIqyd6crb7k38AXjEHCpyZRT11Ryc9zyyhAW6kvSXO)YCpVxQVSg2GKkucsk3a4EEVeVqUhS51MoDb7k38AXjEHCpyZRT11Ryc9zyyhAW6kvSXO)Y0bjMnGCWKWjmVG8EaUN3l1tQ5lW2PlbjLBaOCZzsnAjeNWSKPcD9kPeVqUhS512EsfHWg0fIc2zWyyXX(cmgXE)z(cmgwuLJGXaEG(cmguxi3d28AJXQyGe2kifJa4qkgukvSfJUGXWI6lA9SIraKkcfdVxHajCmCDJ5sXCPLEo3vjJXCpwmh8rLs0IPwjAXuBmcOk7Kc2vU51It8c5EWMxBRRxXe6ZWqCV)mFb26QCeKr)L5EEVeVqUhS51MoDaWALBETPNdP2vQylX7viqcdGYnNj1OLqCclWmmvORxjL4fY9GnV2gU3FMVaBDvoccGYnV2uxFrRNv7jvecNEhPSbjEVcbsnZrib(oszdsGhU51YOVgbHNoR5Vmk38AtphsTRuXwI3RqGeoJYnV20ZHu7kvSLq0SA8EfcKWb7k38AXjEHCpyZRT11Ryc9zyyxFrRNv7jvecZO)YCpVxIxi3d28AtNoamOYKKnZriwEpVxIxi3d28Atqcr9fdq(5RCZRn9Ci1UsfBjEVcbsywkmaMkP1sDOblUuXiaOCZzsnAjeNWzegqSXgRnvsRL6qdwCPIryJnLBotQrlH4ewGcdiaUN3l1tQ5lW2PlbjLBOVVSg2GKkud3rsjU5B7jDG9glZwWUYnVwCIxi3d28ABD9kMqFgg(KkcHnOleXO)YCpVxIxi3d28AtGvUfaEvsWk3M4fY9GnV2eKquFXSKRyRzocbGYnNj1OLqCclWmmvORxjL4fY9GnV22tQie2GUquWUYnVwCIxi3d28ABD9kMqFgg(CiDvPKr)L5EEVeVqUhS51MaRCla8QKGvUnXlK7bBETjiHO(IzjxXwZCecawZRf84w6jveQPCoKmV2GDLBET4eVqUhS51266vmH(mmeZliVNr)L5EEVeVqUhS51MGeI6lwGCfBnZriaUN3lXlK7bBETPthBSDpVxIxi3d28AtGvUfaEvsWk3M4fY9GnV2eKquFXSKRyRzocfSRCZRfN4fY9GnV2wxVIj0NHHsNPVaB3c5YO)YCpVxIxi3d28Atqcr9fZsGCWeIMfak3CMuJwcXjSafoyx5MxloXlK7bBETTUEftOpddbHkWAXTlKuRNr)L5EEVeVqUhS51MGeI6lMLa5GjenlaUN3lXlK7bBETPtxWUYnVwCIxi3d28ABD9kMqFggI5fK3ZO)YykeizPEsLwFQJBSmdRayayQKwlHjf6lWMvhEFWEWUYnVwCcwDTUEftzEsfHWg0fIy0FzuU5mPgTeItybMHPcD9kPuFznSbjvO2tQie2GUqea5FpVxQVSg2GKkucsk3yJT759sphsyRGijiPCdqb7k38AXjy1166vmH(mmSdnyDLk2y0FzUN3lHpBtiFbIBxjHX(cSbjfeT0PdG759s4Z2eYxG42vsySVaBqsbrlbje1xSa5k2AMJqb7k38AXjy1166vmH(mmSdnyDLk2y0FzUN3l9CiHTcIKGKYTGDLBET4eS6AD9kMqFgg2HgSUsfBm6Vm3Z7L6lRHniPcLGKYTGDgmgwCmftTumcGdPyqPuXwmKcLOfJVXa4wSOy8xmOvNyaRvqlMELjfd5wpbJjVsQ5lWyyX7IPGXKxllgrdsQqXGgzXOlymKB9eKfIjFfqX0RmPyqkifJ1RBmwUkgvcjfengJj)lGIPxzsXiGKuwydQ48sQG4yeGdeTyGKcIwmwfZbtmgtbJjFoGIrKuOVaJbv1H3hJJJr5MZKsXK9RvqlgWkgR3XXKR3Lum9kemgUInFbgJaivecBqxichtbJjxpTXiE2yyX8fOG4yqPKWyFbgJJJbskiAPGDLBET4eS6AD9kMqFgg(Ci1UsfBmEWuREVgqoygHz8GPwUExsnUInFbMryg9xgwZuHUELu65qQDLk2ADvj9fia3Z7LWNTjKVaXTRKWyFb2GKcIwcSYTaOCZzsnAjeNWSKPcD9kPuVcbBCfBTNuriSbDHiay9ZHe2uOrWKYnNjbq(S(EEVupPMVaBNUeKuUbaRVN3l1xwdBqsfkbjLBaW6oiXSvVxdihm9Ci1UsfBaKVYnV20ZHu7kvSL49keiHfyMSXgB5BQKwlPsklSbvCEjf3EhiAaWRscw52eiubwlUDHKA9jiPGObi2ylFtL0AjmPqFb2S6W7bWuiqYs9KkT(uh3yzgwbWaeGauWodgdloMIraCifdkLk2IHCRNGXaEG(cmgngbWH0vLsgYIqdwxPITy4k2IjxpTXKxj18fymS4DX44yuU5mPykymGhOVaJHYI4hJIjNB9Xisk0xGXGQ6W7tb7k38AXjy1166vmH(mm85qQDLk2y8GPw9EnGCWmcZ4btTC9UKACfB(cmJWm6VmSMPcD9kP0ZHu7kvS16Qs6lqay9ZHe2uOrWKYnNjbq(5NVYnV20ZH0vLYeLfXpMVabiFLBETPNdPRkLjklIFmQbje1xmlbSeRYgBSgEw6vqGu65qcBfebqSXMYnV2uhAW6kvSLOSi(X8fia5RCZRn1HgSUsfBjklIFmQbje1xmlbSeRYgBSgEw6vqGu65qcBfebqacG759s9KA(cSD6sqs5gGyJT8nvsRLWKc9fyZQdVhatHajl1tQ06tDCJLzyfadG8VN3l1tQ5lW2PlbjLBaWALBETjmVG8(eLfXpMVazJnwFpVxQVSg2GKkucsk3aG13Z7L6j18fy70LGKYnauU51MW8cY7tuwe)y(ceaw3xwdBqsfQH7iPe38T9KoWEdqacqb7k38AXjy1166vmH(mmKRszt5MxBt6yJXvrOmk3CMuZujTgoyx5MxlobRUwxVIj0NHHDObRRuXgJ(lZ98EPo0GfxQyKeKuUbaxXwZCeIL3Z7L6qdwCPIrsqcr9fdaxXwZCeIL3Z7LGNLA1R1v5iycsiQV4GDLBET4eS6AD9kMqFgg2HgSUsfBm6VmDqIzdihmjCcZliVhG759s9KA(cSD6sqs5gaMkP1sysH(cSz1H3dGPqGKL6jvA9PoUXYmScGbGYnNj1OLqCcZsMk01RKs9L1WgKuHApPIqyd6crb7k38AXjy1166vmH(mmSRVO1ZQ9KkcHz0Fzyntf66vsPU(IwpRwxvsFbcW98EPEsnFb2oDjiPCdawFpVxQVSg2GKkucsk3aiFLBotQbwwYbUUrSmBSXMYnNj1OLqCclWmmvORxjL6viyJRyR9KkcHnOleXgBk3CMuJwcXjSaZWuHUELuQVSg2GKku7jvecBqxicqb7k38AXjy1166vmH(mmeZliVNr)LXuiqYs9KkT(uh3yzgwbWaWujTwctk0xGnRo8(GDLBET4eS6AD9kMqFggccvG1IBxiPwpJ(lJYnNj1OLqCclWSfSRCZRfNGvxRRxXe6ZWqfY1LAuwDYc71YO)YOCZzsnAjeNWcmdtf66vsjfY1LAuwDYc71caIUAQJBcmdtf66vsjfY1LAuwDYc712q0vd2zWyqNCRpgARdW(ymfcKmmJX4wmoogngGQVXyvmCfBXiasfHWg0fIIrXX8CPKGX4l2ifmM6fJa4q6Qszkyx5MxlobRUwxVIj0NHHpPIqyd6crm6Vmk3CMuJwcXjSaZWuHUELuQxHGnUIT2tQie2GUquWUYnVwCcwDTUEftOpddFoKUQugShSRCZRfNWMUGkeSbltnV2mpPIqyd6crm6Vmk3CMuJwcXjSaZWuHUELuQVSg2GKku7jvecBqxicG8VN3l1xwdBqsfkbjLBSX298EPNdjSvqKeKuUbOGDLBET4e20fuHGnyzQ51I(mmSdnyDLk2y0FzUN3l9CiHTcIKGKYTGDLBET4e20fuHGnyzQ51I(mmSdnyDLk2y0FzUN3l1xwdBqsfkbjLBaCpVxQVSg2GKkucsiQVywQCZRn9CiDvPmrzr8JrnZrOGDLBET4e20fuHGnyzQ51I(mmSdnyDLk2y0FzUN3l1xwdBqsfkbjLBaKFhKy2aYbtcNEoKUQuYgBphsytHgbtk3CMeBSPCZRn1HgSUsfBjFBpPdS3auWodgdQGOfJvXaKSyezXqzmDWIJJXxSdsXa4wSOy66vmHJPGXG6c5EWMxBmD9kMWXKRN2y6km2VskfSRCZRfNWMUGkeSbltnVw0NHHDObRRuXgJ(lZ98Ej8zBc5lqC7kjm2xGniPGOLoDaKpVkjyLBtWZsT616QCembje1xm6vU51MGNLA1R1v5iyIYI4hJAMJqONRyRzocjW759s4Z2eYxG42vsySVaBqsbrlbje1xmBSXAtL0Aj4zPw9ADvocciayQqxVskzoc1SQXlK7bBETONRyRzocjW759s4Z2eYxG42vsySVaBqsbrlbje1xCWUYnVwCcB6cQqWgSm18ArFgg2HgSUsfBm6Vm3Z7L6lRHniPcLGKYnamfcKSupPsRp1XnwMHvamamvsRLWKc9fyZQdVpyx5MxloHnDbviydwMAETOpdd7qdwxPIng9xM759sDOblUuXijiPCdaUITM5ielVN3l1HgS4sfJKGeI6loyNbJj7FG(cmgRNIbB6cQqWyGLPMxlJXuReTyoykgbWHumOuQydhtUEAJX6j0IrHumBzXCjFbgtxvscmMxbJbWTyrXuWyqDHCpyZRnfdloMIraCifdkLk2IHCRNGXaEG(cmgngbWH0vLsgYIqdwxPITy4k2IjxpTXKxj18fymS4DX44yuU5mPykymGhOVaJHYI4hJIjNB9Xisk0xGXGQ6W7tb7k38AXjSPlOcbBWYuZRf9zy4ZHu7kvSX4btT69Aa5GzeMXdMA56Dj14k28fygHz0Fzy9ZHe2uOrWKYnNjbaRzQqxVsk9Ci1UsfBTUQK(ceG8ZpFLBETPNdPRkLjklIFmFbcq(k38Atphsxvktuwe)yudsiQVywcyjwLn2yn8S0RGaP0ZHe2kicGyJnLBETPo0G1vQylrzr8J5lqaYx5MxBQdnyDLk2suwe)yudsiQVywcyjwLn2yn8S0RGaP0ZHe2kicGaea3Z7L6j18fy70LGKYnaXgB5BQKwlHjf6lWMvhEpaMcbswQNuP1N64glZWkaga5FpVxQNuZxGTtxcsk3aG1k38AtyEb59jklIFmFbYgBS(EEVuFznSbjvOeKuUbaRVN3l1tQ5lW2PlbjLBaOCZRnH5fK3NOSi(X8fiaSUVSg2GKkud3rsjU5B7jDG9gGaeGc2vU51Itytxqfc2GLPMxl6ZWWo0G1vQyJr)LPdsmBa5GjHtyEb59aCpVxQNuZxGTtxcsk3aWujTwctk0xGnRo8EamfcKSupPsRp1XnwMHvamauU5mPgTeItywYuHUELuQVSg2GKku7jvecBqxikyx5MxloHnDbviydwMAETOpdd76lA9SApPIqyg9xgwZuHUELuQRVO1ZQ1vL0xGaKpRnvsRLEWcPz9utX9eMn2uU5mPgTeItybkmGaiFLBotQbwwYbUUrSmBSXMYnNj1OLqCclWmmvORxjL6viyJRyR9KkcHnOleXgBk3CMuJwcXjSaZWuHUELuQVSg2GKku7jvecBqxicqb7k38AXjSPlOcbBWYuZRf9zyixLYMYnV2M0XgJRIqzuU5mPMPsAnCWUYnVwCcB6cQqWgSm18ArFggccvG1IBxiPwpJ(lJYnNj1OLqCclqHd2vU51Itytxqfc2GLPMxl6ZWqmVG8Eg9xgtHajl1tQ06tDCJLzyfadatL0AjmPqFb2S6W7d2vU51Itytxqfc2GLPMxl6ZWqfY1LAuwDYc71YO)YOCZzsnAjeNWcmdtf66vsjfY1LAuwDYc71caIUAQJBcmdtf66vsjfY1LAuwDYc712q0vd2zWyqNCRpgARdW(ymfcKmmJX4wmoogngGQVXyvmCfBXiasfHWg0fIIrXX8CPKGX4l2ifmM6fJa4q6Qszkyx5MxloHnDbviydwMAETOpddFsfHWg0fIy0FzuU5mPgTeItybMHPcD9kPuVcbBCfBTNuriSbDHOGDLBET4e20fuHGnyzQ51I(mm85q6Qs5xe3r8pka8zLV9T)h]] )

end
