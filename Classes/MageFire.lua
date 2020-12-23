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


    spec:RegisterPack( "Fire", 20201223, [[de1DrdqiuqpsKuUKcvHnjs9jukJIOQtjsSkfQ4vQszwOuDlfQQDr4xOadJOIJreTmIcpJOittKu5AOezBOeLVPkrACQseNduvP1bQkZtvQUhrAFOe(hOQQOdcQQYcbv5HIKmrvjQ6IefvBeLO6JQsuzKIKQCsfQsReL0lbvvvZuvc3euvHDQq5NQsugkrrPLksQQNkIPQkPRcQQOTcQQk8vIIIXsuP9Qu)LsdgYHjTyf9yunzqUmYMf1NbLrRkoTWQbvvLEnry2uCBv1UL63sgUcoUcvA5aphQPt11vY2rrFxHmEIsNhfA9kufnFqL9RYBj3VUtGuN2Jjd5id5iPmKHmjKZlHLyzYuQBN4moq7KbLlHcJ2jT(PDclpa0ozqz0uk0(1DcUwaoTtECFadFmGbWc)znf86ZaC8xg1JQ5an7mahFod2jZvy8XBVN7ei1P9yYqoYqoskdzitc58syjwMmKPDIU8NcStsIFQ2jpbee175obIW8DsQDiwEaOdb)qHrhRP2HECFadFmGbWc)znf86ZaC8xg1JQ5an7mahFodowtTd9YtC6pjWHKHmX(HKHCKHCowpwtTdLQhTHry47yn1o04Fi4Ny6q5a2JBb0xJgFiG6pe4q(J2hYvamYfE8jRxwOGouUahYOyF8XeVAOdPZWeoJhAHvyewCSMAhA8p0lQct9H4k2peGg3vaOp1o(q5cCOuv)5c7r1hs(qqc2peu1S5h6Pmqhk8dLlWH0dLbe(5qWpiNkWH4k2trCSMAhA8pKmV1PHoe2bb3pe)H4senSdv9H0dLPrhkxajWhk6d5p0HG)KzFXH86qacAXPdnQasykfsStmb2X7x3j86pxypQ2o8OyA)6Emj3VUtOwNgcAdVDcheobcDNmx5SGx)5c7r1cOAuVtuUhvVtmbShhBH)Dbb7tTV99yYy)6oHADAiOn82j1Wobt(or5Eu9oHPccDAODYct2kNTW4q7XKCNWub2w)0oHK1PgIGS86pxypQ2cOVgnENWbHtGq3j8QHwHlIotGwnwUI5kejOwNgcANSWKD0tyilxXE0W2Jj5oHPAw0ozUYzbV(Zf2JQfa6RrJp0BhAUYzbV(Zf2JQfqlG6r1hACoK8hIxLbQg1cE9NlShvla0xJgFO3p0CLZcE9NlShvla0xJgFOu2(EmzA)6oHADAiOn82j1WorHG2jk3JQ3jmvqOtdTtwyYw5SfghApMK7eMkW26N2jKSo1qeKLx)5c7r1wa91OX7eoiCce6oHxn0kCr0zc0QXYvmxHib160qqhk9HK)qZvolWR2kr0WW2PHW4OHzbKcXOynCi4G7qmvqOtdjizDQHiilV(Zf2JQTa6RrJpeloKKcw6qJZHGXHeFv2dnohs(dnx5SaVARerddBNgcJJgM4RYAXUYL4qJ)HMRCwGxTvIOHHTtdHXrdtGDLlXHs5qPStwyYo6jmKLRypAy7XKCNWunlANWubHonKalX0cTaQhvV99yPU9R7eQ1PHG2WBNWbHtGq3jZvol41FUWEuTaQg17eL7r17KPcZwzRdcUe4TVhJL2VUtOwNgcAdVDcheobcDNOCpyswQPFq4dXIdj5HsFO5kNf86pxypQwavJ6DIY9O6DIjygnm7S(ZTVhJLTFDNqTone0gE7KfMSJEcdz5k2Jg2Emj3jCq4ei0DI8hs5EWKSut)GWh6DPhs5EWKSqLlcyD40HGdUdXWdXRYavJAXWtrDiRnB0pHfasHy8qPCO0hIHhIxn0kCr0zc0QXYvmxHib160qqhk9H4pkagHpelKEijpu6dnx5SGx)5c7r1I1WHsFigEO5kNf5aqyVaFbGuUFO0hIHhAUYzXt5wSdivcbGuUFO0h6PCl2bKkHfpqgd2gTnBcyp(HE7qZvolEi1JgMDniaKY9d9(HKXozHjBLZwyCO9ysUtuUhvVtYbGStJI9TVh7LUFDNqTone0gE7KAyNGjFNOCpQENWubHon0ozHjBLZwyCO9ysUtyQaBRFANqYoqCNGS5aq2PrXoENWbHtGq3j8QHwHlIotGwnwUI5kejOwNgcANSWKD0tyilxXE0W2Jj5oHPAw0or5EuTihaYonk2f8hfaJW2mq5EuTAo0Bhs(dXubHonKGK1PgIGS86pxypQ2cOVgn(qJ)HMRCweDMaTASCfZvisaTaQhvFOuoedoeVkdunQf5aq2PrXUaAbupQE77XEj7x3juRtdbTH3oPg2jyY3jk3JQ3jmvqOtdTtwyYw5SfghApMK7eMkW26N2jnrqeKnhaYonk2X7eoiCce6oHxn0kCr0zc0QXYvmxHib160qq7KfMSJEcdz5k2Jg2Emj3jmvZI2jCkmhs(dXubHonKGK1PgIGS86pxypQ2cOVgn(qm4qYFO5kNfrNjqRglxXCfIeqlG6r1hA8pemoK4RYEOuoukBFpg87(1Dc160qqB4TtwyYo6jmKLRypAy7XKCNWbHtGq3jYFiL7btYsn9dcFO3LEiL7btYcvUiG1Hthco4oedpeVkdunQfdpf1HS2Sr)ewaifIXdLYHsFiE1qRWfrNjqRglxXCfIeuRtdbDO0hI)Oaye(qSq6HK8qPpK8hIPccDAibj7aXDcYMdazNgf74dXcPhIPccDAirteebzZbGStJID8HGdUdXubHonKGK1PgIGS86pxypQ2cOVgn(qVl9qZvolIotGwnwUI5kejGwa1JQpeCWDO5kNfrNjqRglxXCfIeyx5sCO3pKmoeCWDO5kNfrNjqRglxXCfIea6RrJp07hcghs8vzpeCWDiEvgOAulWpr2JgMDOgrabGuigpu6dPCpyswQPFq4dXcPhIPccDAibV(Zf2JQT4Ni7rdZouJiWHsFiEXKATDrhWECBwPdLYHsFO5kNf86pxypQwSgou6dj)Hy4HMRCwKdaH9c8fas5(HGdUdnx5Si6mbA1y5kMRqKaqFnA8HE)qYrWshkLdL(qm8qZvolEk3IDaPsiaKY9dL(qpLBXoGujS4bYyW2OTzta7Xp0BhAUYzXdPE0WSRbbGuUFO3pKm2jlmzRC2cJdThtYDIY9O6DsoaKDAuSV99yskN9R7eQ1PHG2WBNWbHtGq3jGvt5caJeqbMhdMOvaJwE9)AdjOwNgc6qPp0CLZcOaZJbt0kGrlV(FTHeq1O(qPp0CLZcOaZJbt0kGrlV(FTHSkGRnjGQr9HsFiEvgOAulMRC2cfyEmyIwbmA51)RnKaqkeJhk9Hy4HC1qTlaRMSv2ouJiGGADAiODIY9O6DcVwTta8azmBFpMKsUFDNqTone0gE7eoiCce6obSAkxayKakW8yWeTcy0YR)xBib160qqhk9HMRCwafyEmyIwbmA51)RnKaQg1hk9HMRCwafyEmyIwbmA51)RnKvbCTjbunQpu6dXRYavJAXCLZwOaZJbt0kGrlV(FTHeasHy8qPpedpKRgQDby1KTY2HAebeuRtdbTtuUhvVtuaxBYsYoykCu923JjPm2VUtOwNgcAdVDcheobcDNawnLlamsafyEmyIwbmA51)RnKGADAiOdL(qZvolGcmpgmrRagT86)1gsavJ6dL(qZvolGcmpgmrRagT86)1gYMbf2fq1OENOCpQENKbf2NLX3(EmjLP9R7eQ1PHG2WBNWbHtGq3jGvt5caJeWab2WOn4b3qcQ1PHGou6dnx5SGx)5c7r1cOAuVtuUhvVtYGc72UyQBFpMKPU9R7eQ1PHG2WBNOCpQENWvJXQCpQ2AcSVtmb2TT(PDIY9GjzD1qTJ3(EmjzP9R7eQ1PHG2WBNSWKD0tyilxXE0W2Jj5oHdcNaHUtMRCwWR)CH9OAbunQpu6dj)Hy4HaRMYfagjGcmpgmrRagT86)1gsqTone0HGdUdnx5SakW8yWeTcy0YR)xBiXA4qWb3HMRCwafyEmyIwbmA51)RnKndkSlwdhk9HC1qTlaRMSv2ouJiGGADAiOdL(q8Qmq1Owmx5SfkW8yWeTcy0YR)xBibGuigpukhk9HK)qm8qGvt5caJeWab2WOn4b3qcQ1PHGoeCWDiiAUYzbmqGnmAdEWnKynCOuou6dj)HuUhvl(KtfqeTnBcyp(HsFiL7r1Ip5uberBZMa2JBb0xJgFO3LEi5iyzhco4oKY9OAbMxa(JGKL4lpAyhk9HuUhvlW8cWFeKSeF5KfqFnA8HE)qYrWYoeCWDiL7r1ICaOPAmcswIV8OHDO0hs5EuTihaAQgJGKL4lNSa6RrJp07hsocw2HGdUdPCpQwmWiOMgf7cswIV8OHDO0hs5EuTyGrqnnk2fKSeF5KfqFnA8HE)qYrWYoeCWDiL7r1ISr)e2bHeKGKL4lpAyhk9HuUhvlYg9tyhesqcswIVCYcOVgn(qVFi5iyzhkLDYct2kNTW4q7XKCNOCpQENWR)CH9O6TVhtsw2(1Dc160qqB4Tt4GWjqO7K5kNf86pxypQwyuSBjzhcaDO3LEiL7r1cE9NlShvlmk2TlmbTtuUhvVt4QXyvUhvBnb23jMa72w)0oHx)5c7r1wEvgOAuJ3(EmjFP7x3juRtdbTH3oHdcNaHUtK)qZvolEk3IDaPsiaKY9dL(qk3dMKLA6he(qSq6HyQGqNgsWR)CH9OAB2OFc7Gqc6qPCi4G7qYFO5kNf5aqyVaFbGuUFO0hs5EWKSut)GWhIfspetfe60qcE9NlShvBZg9tyhesqhA8pey1uUaWiroae2lWxqTone0HszNOCpQENKn6NWoiKG2(EmjFj7x3juRtdbTH3oHdcNaHUtMRCwGxTvIOHHTtdHXrdZcifIrXA4qPp0CLZc8QTsenmSDAimoAywaPqmka0xJgFiwCiUIDRhFANOCpQENmWiOMgf7BFpMKWV7x3juRtdbTH3oHdcNaHUtMRCwKdaH9c8fas5(or5Eu9ozGrqnnk23(EmziN9R7eQ1PHG2WBNWbHtGq3jZvolgyeuCJI)caPC)qPp0CLZIbgbf3O4VaqFnA8HyXH4k2TE8PdL(qYFO5kNf86pxypQwaOVgn(qS4qCf7wp(0HGdUdnx5SGx)5c7r1cOAuFOuou6dPCpyswQPFq4d9(HyQGqNgsWR)CH9OAB2OFc7GqcANOCpQENmWiOMgf7BFpMmKC)6oHADAiOn82jCq4ei0DYCLZINYTyhqQecaPC)qPp0CLZcE9NlShvlwd7eL7r17Kbgb10OyF77XKHm2VUtOwNgcAdVDcheobcDNmaiMwyCiHKcmVa8NdL(qZvolEi1JgMDniaKY9dL(qk3dMKLA6he(qVFiMki0PHe86pxypQ2Mn6NWoiKG2jk3JQ3jdmcQPrX(23JjdzA)6oHADAiOn82jk3JQ3j4Ni7rdZouJiWoHdcNaHUtMRCwWR)CH9OAXA4qPpedpKY9OAroaKDAuSl4pkagHpu6dPCpyswQPFq4dXcPhIPccDAibV(Zf2JQT4Ni7rdZouJiWHsFiL7r1IHNI6qwB2OFclYlJXci(JcGrwp(0HyXHYlJXciOf3JQ3jr7eaSgCBK3jk3JQf5aq2PrXUG)OayewQY9OAroaKDAuSl(QSw(JcGr4TVhtgPU9R7eQ1PHG2WBNWbHtGq3jZvol41FUWEuTynCO0hs(dj)HuUhvlYbGStJIDb)rbWi8HE)qsEO0hYvd1UyGrqXnk(lOwNgc6qPpKY9GjzPM(bHpK0dj5Hs5qWb3Hy4HC1qTlgyeuCJI)cQ1PHGoeCWDiL7btYsn9dcFiwCijpukhk9HMRCw8qQhnm7AqaiL7h6Td9uUf7asLWIhiJbBJ2MnbSh)qVFizStuUhvVtgEkQdzTzJ(j823JjdwA)6oHADAiOn82jCq4ei0DYCLZcE9NlShvlGQr9HsFiEvgOAul41FUWEuTaqFnA8HE)qCf7wp(0HsFiL7btYsn9dcFiwi9qmvqOtdj41FUWEuTnB0pHDqibTtuUhvVtYg9tyhesqBFpMmyz7x3juRtdbTH3oHdcNaHUtMRCwWR)CH9OAbunQpu6dXRYavJAbV(Zf2JQfa6RrJp07hIRy36XNou6dXWdXRgAfUiB0pzvohqEuTGADAiODIY9O6Dsoa0unMTVhtgV09R7eQ1PHG2WBNWbHtGq3jZvol41FUWEuTaqFnA8HyXH4k2TE8PdL(qZvol41FUWEuTynCi4G7qZvol41FUWEuTaQg1hk9H4vzGQrTGx)5c7r1ca91OXh69dXvSB94t7eL7r17emVa8NTVhtgVK9R7eQ1PHG2WBNWbHtGq3jZvol41FUWEuTaqFnA8HE)qW4qIVk7HsFiL7btYsn9dcFiwCij3jk3JQ3jMGz0WSZ6p3(Emza)UFDNqTone0gE7eoiCce6ozUYzbV(Zf2JQfa6RrJp07hcghs8vzpu6dnx5SGx)5c7r1I1Wor5Eu9obcOWQgBNas9NTVhtMKZ(1Dc160qqB4Tt4GWjqO7exbWix8qQXFedC)qVl9qYKCou6d5QHAxGjfenmRxl(JGADAiODIY9O6DcMxa(Z23(obIY6Y47x3Jj5(1Dc160qqB4Tt4GWjqO7egEiWQPCbGrcOaZJbt0kGrlV(FTHeuRtdbTtuUhvVt41QDcGhiJz77XKX(1Dc160qqB4TtQHDcM8DIY9O6Dctfe60q7eMQzr7exnu7ICaiSRaNacQ1PHGo04COCaiSRaNaca91OXh6Tdj)H4vzGQrTGx)5c7r1ca91OXhACoK8hsYdn(hIPccDAiHerdzIgMfqqlUhvFOX5qUAO2fsenKjAycQ1PHGoukhkLdnohIHhIxLbQg1cE9NlShvlaKcX4HgNdnx5SGx)5c7r1cOAuVtyQaBRFAN4XNSEz51FUWEu923Jjt7x3juRtdbTH3oPg2jFv2DIY9O6Dctfe60q7eMQzr7eMki0PHe0FGraPgBbGAT5KfImkJhA8pK8hIxLbQg1c6pWiGuJTaqT2CsaTaQhvFOX)q8Qmq1Owq)bgbKASfaQ1Mtca91OXhkLdnohIHhIxLbQg1c6pWiGuJTaqT2CsaifIXDcheobcDNqJ7kggiib9hyeqQXwaOwBoTtyQaBRFAN4XNSEz51FUWEu923JL62VUtOwNgcAdVDsnSt(QS7eL7r17eMki0PH2jmvZI2j8Qmq1OwaZOqH6faBNkemsaOVgnENWbHtGq3j04UIHbcsaZOqH6faBNkemANWub2w)0oXJpz9YYR)CH9O6TVhJL2VUtOwNgcAdVDsnSt(QS7eL7r17eMki0PH2jmvZI2jZvolaRMSv2ouJiGaqFnA8oHdcNaHUtC1qTlaRMSv2ouJiGGADAiOdL(qZvol41FUWEuTaQg17eMkW26N2jE8jRxwE9NlShvV99ySS9R7eQ1PHG2WBNud7KVk7or5Eu9oHPccDAODct1SODcVkdunQfGvt2kBhQreqaOVgn(qVDO5kNfGvt2kBhQreqaTaQhvVt4GWjqO7exnu7cWQjBLTd1iciOwNgc6qPp0CLZcE9NlShvlGQr9HsFiEvgOAulaRMSv2ouJiGaqFnA8HE7qS0HE)qmvqOtdj84twVS86pxypQENWub2w)0oXJpz9YYR)CH9O6TVh7LUFDNqTone0gE7eoiCce6ozUYzbV(Zf2JQfq1O(qPpetfe60qcp(K1llV(Zf2JQpelouEzmwabT4Eu9HsFi5peVkdunQfGvt2kBhQreqaOVgn(qS4q5LXybe0I7r1hco4oedpKRgQDby1KTY2HAebeuRtdbDOuou6dXWdj)HMRCweDMaTASCfZvisSgou6dnx5S4PCl2bKkHaqk3pukhk9HK)qk3dMKLA6he(qVFiMki0PHe86pxypQ2IFIShnm7qnIahco4oKY9GjzPM(bHp07hIPccDAibV(Zf2JQTzJ(jSdcjOdbhChIPccDAiHhFY6LLx)5c7r1hA8puEzmwabT4Eu9HyXHuUhvB5vzGQr9HszNOCpQENGFIShnm7qnIaBFp2lz)6oHADAiOn82jCq4ei0DI8hAUYzbV(Zf2JQfq1O(qPp0CLZcWQjBLTd1iciGQr9HsFi5petfe60qcp(K1llV(Zf2JQp07hIKL4lNSE8PdbhChIPccDAiHhFY6LLx)5c7r1hIfhIxLbQg1cGcfA7w8GcKqaTaQhvFOuoukhco4oK8hAUYzby1KTY2HAebeRHdL(qmvqOtdj84twVS86pxypQ(qS4qYKCouk7eL7r17eGcfA7w8GcKy77XGF3VUtOwNgcAdVDcheobcDNmx5SGx)5c7r1cOAuFO0hAUYzby1KTY2HAebeq1O(qPpetfe60qcp(K1llV(Zf2JQp07hIKL4lNSE8PDIY9O6DceP(ZSanT99yskN9R7eQ1PHG2WBNWbHtGq3jmvqOtdj84twVS86pxypQ(qVl9qY0HsFO5kNf86pxypQwavJ6DIY9O6DYpaGcGTv26f4tTV99ysk5(1Dc160qqB4TtwyYo6jmKLRypAy7XKCNOCpQENKdazNgf77eoiCce6or5EuT4haqbW2kB9c8P2fKSeF5rd7qPpuEzmwaXFuamY6XNo04FiL7r1IFaafaBRS1lWNAxqYs8Ltwa91OXh69dL6ou6dXWd9uUf7asLWIhiJbBJ2MnbSh)qPpedp0CLZINYTyhqQecaPCF77XKug7x3juRtdbTH3oHdcNaHUtMRCwWR)CH9OAbunQpu6dbrZvolakuOTBXdkqclZLPjGodt4mkGQr9or5Eu9o5haqbSXxHrBFpMKY0(1Dc160qqB4TtuUhvVtGzuOq9cGTtfcgTt4GWjqO7eMki0PHeE8jRxwE9NlShvFiwCiL7r1wEvgOAuFOX)qS0oHYzI72w)0obMrHc1la2oviy023JjzQB)6oHADAiOn82jk3JQ3j0FGraPgBbGAT50oHdcNaHUtyQGqNgs4XNSEz51FUWEu9HEx6HyQGqNgsq)bgbKASfaQ1MtwiYOmUtA9t7e6pWiGuJTaqT2CA77XKKL2VUtOwNgcAdVDIY9O6DcmdJdp2kBvmo(Hr9O6DcheobcDNWubHonKWJpz9YYR)CH9O6dXcPhIPccDAir12fMS8Lx58oP1pTtGzyC4XwzRIXXpmQhvV99ysYY2VUtOwNgcAdVDIY9O6DYx56eqw8drU9VWbFNWbHtGq3jmvqOtdj84twVS86pxypQ(qVl9qS0oP1pTt(kxNaYIFiYT)fo4BFpMKV09R7eQ1PHG2WBNOCpQENabifkhaYYKWyYSt4GWjqO7eMki0PHeE8jRxwE9NlShvFiwi9qmvqOtdjQ2UWKLV8kNpu6dj)HMRCweDMaTASCfZvisGDLlXHKEO5kNfrNjqRglxXCfIeFvwl2vUehco4oedpeVAOv4IOZeOvJLRyUcrcQ1PHGoeCWDiMki0PHe86pxypQ2wTDHPdbhChIPccDAiHhFY6LLx)5c7r1h6TdXshIfhkhWEClG(A04dnECiL7r1wEvgOAuFOu2jT(PDceGuOCailtcJjZ23Jj5lz)6oHADAiOn82jk3JQ3j4AzSbSoCcSt4GWjqO7eMki0PHeE8jRxwE9NlShvFiwi9qmvqOtdjQ2UWKLV8kNp0Bhssw6qJZHK)qmvqOtdjQ2UWKLV8kNpeloKCoukhco4oetfe60qcp(K1llV(Zf2JQp07hss5StA9t7eCTm2awhob2(EmjHF3VUtOwNgcAdVDcheobcDNWubHonKWJpz9YYR)CH9O6dXcPhIPccDAir12fMS8Lx58HsFiMki0PHeE8jRxwE9NlShvFiwi9qsYshACoenURyyGGeqasHYbGSmjmMmhk9H84th69dXshk9Hy4H4vdTcxeDMaTASCfZvisqTone0HGdUdnx5Si6mbA1y5kMRqKa7kxIdj9qZvolIotGwnwUI5kej(QSwSRCj2jk3JQ3jCT5KXox58ozUYzBRFANGRLXgW6WJQ3(EmziN9R7eQ1PHG2WBNWbHtGq3jGvt5caJeqbMhdMOvaJwE9)AdjOwNgc6qPpeVkdunQfZvoBHcmpgmrRagT86)1gsaifIXdL(qZvolGcmpgmrRagT86)1gYQaU2KaQg1hk9Hy4HMRCwafyEmyIwbmA51)RnKynCO0hIPccDAiHhFY6LLx)5c7r1hIfhsgS0or5Eu9oHxR2jaEGmMTVhtgsUFDNqTone0gE7eoiCce6obSAkxayKakW8yWeTcy0YR)xBib160qqhk9H4vzGQrTyUYzluG5XGjAfWOLx)V2qcaPqmEO0hAUYzbuG5XGjAfWOLx)V2qwfW1Meq1O(qPpedp0CLZcOaZJbt0kGrlV(FTHeRHdL(qmvqOtdj84twVS86pxypQ(qS4qYGL2jk3JQ3jkGRnzjzhmfoQE77XKHm2VUtOwNgcAdVDcheobcDNawnLlamsafyEmyIwbmA51)RnKGADAiOdL(q8Qmq1Owmx5SfkW8yWeTcy0YR)xBibGuigpu6dnx5SakW8yWeTcy0YR)xBiBguyxavJ6dL(qm8qZvolGcmpgmrRagT86)1gsSgou6dXubHonKWJpz9YYR)CH9O6dXIdjdwANOCpQENKbf2NLX3(Emzit7x3juRtdbTH3oHdcNaHUtyQGqNgs4XNSEz51FUWEu9HEx6HKZor5Eu9oHRgJv5EuT1eyFNycSBB9t7eE9NlShvBhEumT99yYi1TFDNqTone0gE7KAyNGjFNOCpQENWubHon0ozHjBLZwyCO9ysUtyQMfTtyQGqNgs4XNSEz51FUWEu9Hg)djth69dPCpQwKdazNgf7I8YySaI)OayK1JpDOX)qk3JQf4Ni7rdZouJiGiVmglGGwCpQ(qJZHK)q8Qmq1OwGFIShnm7qnIaca91OXh69dXubHonKWJpz9YYR)CH9O6dLYHsFiMki0PHeE8jRxwE9NlShvFO3puoG94wa91OXhco4oKRgQDby1KTY2HAebeuRtdbDO0hAUYzby1KTY2HAebeq1O(qPpeVkdunQfGvt2kBhQreqaOVgn(qVFiL7r1ICai70OyxKxgJfq8hfaJSE8Pdn(hs5EuTa)ezpAy2HAebe5LXybe0I7r1hACoK8hIxLbQg1c8tK9OHzhQreqaOVgn(qVFiEvgOAulaRMSv2ouJiGaqFnA8Hs5qPpeVkdunQfGvt2kBhQreqaOVgn(qVFOCa7XTa6RrJ3jmvGT1pTtYbGStJID7qvMOHTtwyYo6jmKLRypAy7XKC77XKblTFDNqTone0gE7KAyNGjFNOCpQENWubHon0oHPAw0oHPccDAiHhFY6LLx)5c7r1h69dPCpQwm8uuhYAZg9tyrEzmwaXFuamY6XNo04FiL7r1c8tK9OHzhQreqKxgJfqqlUhvFOX5qYFiEvgOAulWpr2JgMDOgrabG(A04d9(HyQGqNgs4XNSEz51FUWEu9Hs5qPpetfe60qcp(K1llV(Zf2JQp07hkhWEClG(A04dbhChcSAkxayKaVARerddBNgcJJgMGADAiOdbhChYJpDO3pelTtyQaBRFANm8uuhYAhQYenSTVhtgSS9R7eQ1PHG2WBNWbHtGq3jZvolaRMSv2ouJiGaQg1hk9Hy4HMRCwKdaH9c8fas5(HsFi5petfe60qcp(K1llV(Zf2JQpelKEO5kNfGvt2kBhQreqaTaQhvFO0hIPccDAiHhFY6LLx)5c7r1hIfhs5EuTihaYonk2f5LXybe)rbWiRhF6qWb3HyQGqNgs4XNSEz51FUWEu9HyXHYbSh3cOVgn(qPStuUhvVtaRMSv2ouJiW23JjJx6(1Dc160qqB4Tt4GWjqO7K5kNfGvt2kBhQreqSgou6dj)HyQGqNgs4XNSEz51FUWEu9HyXHKZHszNOCpQENWvJXQCpQ2AcSVtmb2TT(PDcOgSdpkM2(Emz8s2VUtOwNgcAdVDYct2rpHHSCf7rdBpMK7eoiCce6oHHhIPccDAiroaKDAuSBhQYenSdL(qYFiMki0PHeE8jRxwE9NlShvFiwCi5Ci4G7qk3dMKLA6he(qSq6HyQGqNgs8OailxXUnB0pHDqibDO0hIHhkhac7kWjGq5EWKou6dXWdnx5S4PCl2bKkHaqk3pu6dj)HMRCw8qQhnm7AqaiL7hk9HuUhvlYg9tyhesqcswIVCYcOVgn(qVFi5iyPdbhChI)Oaye2Mbk3JQvZHyH0djJdLYHszNSWKTYzlmo0Emj3jk3JQ3j5aq2PrX(23Jjd439R7eQ1PHG2WBNSWKD0tyilxXE0W2Jj5oHdcNaHUtYbGWUcCciuUhmPdL(q8hfaJWhIfspKKhk9Hy4HyQGqNgsKdazNgf72HQmrd7qPpK8hIHhs5EuTihaAQgJGKL4lpAyhk9Hy4HuUhvlgyeutJIDr02SjG94hk9HMRCw8qQhnm7AqaiL7hco4oKY9OAroa0ungbjlXxE0Wou6dXWdnx5S4PCl2bKkHaqk3peCWDiL7r1Ibgb10OyxeTnBcyp(HsFO5kNfpK6rdZUgeas5(HsFigEO5kNfpLBXoGujeas5(HszNSWKTYzlmo0Emj3jk3JQ3j5aq2PrX(23JjtYz)6oHADAiOn82jlmzh9egYYvShnS9ysUtuUhvVtYbGStJI9DcheobcDNOCpQwGFIShnm7qnIacswIV8OHDO0hkVmglG4pkagz94th69dPCpQwGFIShnm7qnIacp4sybe0I7r1hk9HMRCw8uUf7asLqavJ6dL(qE8PdXIdjPC2(EmzsY9R7eQ1PHG2WBNWbHtGq3jYFiMki0PHeE8jRxwE9NlShvFiwCi5COuou6dnx5SaSAYwz7qnIacOAuVtuUhvVt4QXyvUhvBnb23jMa72w)0ob7AdPailOC1JQ3(Emzsg7x3jk3JQ3jyEb4p7eQ1PHG2WB7BFNmaiE9NQVFDpMK7x3jk3JQ3jkGRnzJ2jJH4(oHADAiOn82(EmzSFDNqTone0gE7KAyNGjFNOCpQENWubHon0oHPAw0orghACoKRgQDr2OFYoOo)rqTone0HE7qY0HgNdXWd5QHAxKn6NSdQZFeuRtdbTt4GWjqO7eMki0PHepLBXoGujSzJ(jSdcjOdj9qYzNWub2w)0o5PCl2bKkHnB0pHDqibT99yY0(1Dc160qqB4TtQHDcM8DIY9O6Dctfe60q7eMQzr7ezCOX5qUAO2fzJ(j7G68hb160qqh6TdjthACoedpKRgQDr2OFYoOo)rqTone0oHdcNaHUtyQGqNgs8OailxXUnB0pHDqibDiPhso7eMkW26N2jpkaYYvSBZg9tyhesqBFpwQB)6oHADAiOn82j1Wobt(or5Eu9oHPccDAODct1SODImDOX5qUAO2fzJ(j7G68hb160qqh6TdXYo04CigEixnu7ISr)KDqD(JGADAiODcheobcDNWubHonKGx)5c7r12Sr)e2bHe0HKEi5StyQaBRFANWR)CH9OAB2OFc7GqcA77XyP9R7eQ1PHG2WBNud7em57eL7r17eMki0PH2jmvZI2jWVWVhACoKRgQDr2OFYoOo)rqTone0HE7qY4qJZHy4HC1qTlYg9t2b15pcQ1PHG2jCq4ei0Dctfe60qcfW1MSKSdMchvFiPhso7eMkW26N2jkGRnzjzhmfoQE77Xyz7x3juRtdbTH3oPg2jact(or5Eu9oHPccDAODctfyB9t7efW1MSKSdMchvB)AR7eikRlJVtsDYz77XEP7x3juRtdbTH3oPg2jact(or5Eu9oHPccDAODctfyB9t7eiYOmAZg9tyhesq7eikRlJVtKZ23J9s2VUtOwNgcAdVDsnStaeM8DIY9O6Dctfe60q7eMkW26N2jsenKjAywabT4Eu9obIY6Y47e5isDBFpg87(1Dc160qqB4TtQHDcM8DIY9O6Dctfe60q7eMQzr7ewANWub2w)0oblX0cTaQhvV99yskN9R7eQ1PHG2WBNud7em57eL7r17eMki0PH2jmvZI2j04UIHbcs8vUobKf)qKB)lCWpeCWDiACxXWabj(Ahzc7LTY2Vc1egFi4G7q04UIHbcsaZOqH6faBNkem6qWb3HOXDfddeKaMrHc1la2(ji1yIQpeCWDiACxXWabjcyD4r12VcJW28cthco4oenURyyGGe(4P2e2ovGe4HOj8HGdUdrJ7kggiiHoEUaK)uyloAyeKDWS(km6qWb3HOXDfddeKqBEqTBLOl3wz7Oadv)dbhChIg3vmmqqc8tXLygobW2S2WoeCWDiACxXWabjAAbuJfZyRdyYs9J2CcCi4G7q04UIHbcsmvdLdazNaT5p7eMkW26N2j86pxypQ2wTDHPTVhtsj3VUtOwNgcAdVDsnStaeM8DIY9O6Dctfe60q7eMkW26N2j0FGraPgBbGAT5KfImkJ7eikRlJVtK8LS99yskJ9R7eQ1PHG2WBNud7em57eL7r17eMki0PH2jmvZI2jYqo7eoiCce6oHPccDAibV(Zf2JQTvBxyANWub2w)0oPA7ctw(YRCE77XKuM2VUtOwNgcAdVDsnStWKVtuUhvVtyQGqNgANWunlANidwANWbHtGq3j04UIHbcs8vUobKf)qKB)lCW3jmvGT1pTtQ2UWKLV8kN3(EmjtD7x3juRtdbTH3oPg2jyY3jk3JQ3jmvqOtdTtyQMfTtKHCo0BhIPccDAib9hyeqQXwaOwBozHiJY4oHdcNaHUtOXDfddeKG(dmci1ylauRnN2jmvGT1pTtQ2UWKLV8kN3(EmjzP9R7eQ1PHG2WBNud7eaHjFNOCpQENWubHon0oHPcST(PDcV(Zf2JQT4Ni7rdZouJiWobIY6Y47ezS99ysYY2VUtOwNgcAdVDsRFANGRLXgW6WjWor5Eu9obxlJnG1HtGTVhtYx6(1DIY9O6DYpaGcyJVcJ2juRtdbTH323Jj5lz)6oHADAiOn82jCq4ei0Dcdp0aGykgyeutJI9DIY9O6DYaJGAAuSV9TVt41FUWEuTLxLbQg149R7XKC)6or5Eu9ozO8O6Dc160qqB4T99yYy)6or5Eu9ozAQcYMxag3juRtdbTH323Jjt7x3jk3JQ3jtcGjGerdBNqTone0gEBFpwQB)6or5Eu9ojhaAAQcANqTone0gEBFpglTFDNOCpQENOnNWoqnwUAm7eQ1PHG2WB77Xyz7x3jk3JQ3jlmzdN(4Dc160qqB4T99yV09R7eQ1PHG2WBNOCpQENaZOqH6faBNkemANSWKTYzlmo0Emj3jCq4ei0DIY9OAXNCQaIOTzta7XTa6RrJp07spKCeS0oHYzI72w)0obMrHc1la2oviy023J9s2VUtOwNgcAdVDcheobcDNawnLlams40FOaQXosbdcQ1PHGou6dnx5SGK9rxypQwSg2jk3JQ3jE8j7ifmS9TVtuUhmjRRgQD8(19ysUFDNqTone0gE7eoiCce6or5EWKSut)GWhIfhsYdL(qZvol41FUWEuTaQg1hk9HK)qmvqOtdj84twVS86pxypQ(qS4q8Qmq1OwycMrdZoR)uaTaQhvFi4G7qmvqOtdj84twVS86pxypQ(qVl9qY5qPStuUhvVtmbZOHzN1FU99yYy)6oHADAiOn82jCq4ei0Dctfe60qcp(K1llV(Zf2JQp07spKCoeCWDi5peVkdunQfFYPciGwa1JQp07hIPccDAiHhFY6LLx)5c7r1hk9Hy4HC1qTlaRMSv2ouJiGGADAiOdLYHGdUd5QHAxawnzRSDOgrab160qqhk9HMRCwawnzRSDOgraXA4qPpetfe60qcp(K1llV(Zf2JQpeloKY9OAXNCQacEvgOAuFi4G7q5a2JBb0xJgFO3petfe60qcp(K1llV(Zf2JQ3jk3JQ3jFYPcS99yY0(1Dc160qqB4Tt4GWjqO7exnu7c1qYIDGIhpvSnVamkOwNgc6qPpK8hAUYzbV(Zf2JQfq1O(qPpedp0CLZINYTyhqQecaPC)qPStuUhvVtGakSQX2jGu)z7BFNGDTHuaKfuU6r17x3Jj5(1Dc160qqB4Tt4GWjqO7eL7btYsn9dcFiwi9qmvqOtdjEk3IDaPsyZg9tyhesqhk9HK)qZvolEk3IDaPsiaKY9dbhChAUYzroae2lWxaiL7hkLDIY9O6Ds2OFc7GqcA77XKX(1Dc160qqB4Tt4GWjqO7K5kNf5aqyVaFbGuUVtuUhvVtgyeutJI9TVhtM2VUtOwNgcAdVDcheobcDNmx5S4PCl2bKkHaqk3pu6dnx5S4PCl2bKkHaqFnA8HE)qk3JQf5aqt1yeKSeF5K1JpTtuUhvVtgyeutJI9TVhl1TFDNqTone0gE7eoiCce6ozUYzXt5wSdivcbGuUFO0hs(dnaiMwyCiHKICaOPAmhco4ouoae2vGtaHY9GjDi4G7qk3JQfdmcQPrXUiAB2eWE8dLYor5Eu9ozGrqnnk23(EmwA)6oHADAiOn82jCq4ei0DYCLZc8QTsenmSDAimoAywaPqmkwdhk9HK)q8Qmq1OwawnzRSDOgrabG(A04d92HuUhvlaRMSv2ouJiGGKL4lNSE8Pd92H4k2TE8PdXIdnx5SaVARerddBNgcJJgMfqkeJca91OXhco4oedpKRgQDby1KTY2HAebeuRtdbDOuou6dXubHonKWJpz9YYR)CH9O6d92H4k2TE8PdXIdnx5SaVARerddBNgcJJgMfqkeJca91OX7eL7r17Kbgb10OyF77Xyz7x3juRtdbTH3oHdcNaHUtMRCw8uUf7asLqaiL7hk9HCfaJCXdPg)rmW9d9U0djtY5qPpKRgQDbMuq0WSET4pcQ1PHG2jk3JQ3jdmcQPrX(23J9s3VUtOwNgcAdVDcheobcDNmx5SyGrqXnk(laKY9dL(qCf7wp(0HE)qZvolgyeuCJI)ca91OX7eL7r17Kbgb10OyF77XEj7x3juRtdbTH3ozHj7ONWqwUI9OHThtYDcheobcDNWWdLdaHDf4eqOCpyshk9Hy4HyQGqNgsKdazNgf72HQmrd7qPpK8hs(dj)HuUhvlYbGMQXiizj(YJg2HsFi5pKY9OAroa0ungbjlXxozb0xJgFO3pKCeS0HGdUdXWdbwnLlamsKdaH9c8fuRtdbDOuoeCWDiL7r1Ibgb10OyxqYs8LhnSdL(qYFiL7r1Ibgb10OyxqYs8Ltwa91OXh69djhblDi4G7qm8qGvt5caJe5aqyVaFb160qqhkLdLYHsFO5kNfpK6rdZUgeas5(Hs5qWb3HK)qUAO2fysbrdZ61I)iOwNgc6qPpKRayKlEi14pIbUFO3LEizsohk9HK)qZvolEi1JgMDniaKY9dL(qm8qk3JQfyEb4pcswIV8OHDi4G7qm8qZvolEk3IDaPsiaKY9dL(qm8qZvolEi1JgMDniaKY9dL(qk3JQfyEb4pcswIV8OHDO0hIHh6PCl2bKkHfpqgd2gTnBcyp(Hs5qPCOu2jlmzRC2cJdThtYDIY9O6DsoaKDAuSV99yWV7x3juRtdbTH3oHdcNaHUtgaetlmoKqsbMxa(ZHsFO5kNfpK6rdZUgeas5(HsFixnu7cmPGOHz9AXFeuRtdbDO0hYvamYfpKA8hXa3p07spKmjNdL(qk3dMKLA6he(qVFiMki0PHepLBXoGujSzJ(jSdcjODIY9O6DYaJGAAuSV99yskN9R7eQ1PHG2WBNWbHtGq3jm8qmvqOtdjgEkQdzTdvzIg2HsFi5pedpKRgQDrguFR)qwf)qyb160qqhco4oKY9GjzPM(bHpeloKKhkLdL(qYFiL7btYcvUiG1Hth69djJdbhChs5EWKSut)GWhIfspetfe60qIhfaz5k2TzJ(jSdcjOdbhChs5EWKSut)GWhIfspetfe60qINYTyhqQe2Sr)e2bHe0HszNOCpQENm8uuhYAZg9t4TVhtsj3VUtOwNgcAdVDIY9O6DcxngRY9OARjW(oXey326N2jk3dMK1vd1oE77XKug7x3juRtdbTH3oHdcNaHUtuUhmjl10pi8HyXHKCNOCpQENabuyvJTtaP(Z23JjPmTFDNqTone0gE7eoiCce6oXvamYfpKA8hXa3p07spKmjNdL(qUAO2fysbrdZ61I)iOwNgcANOCpQENG5fG)S99ysM62VUtOwNgcAdVDcheobcDNOCpyswQPFq4dXcPhIPccDAiHc4Atws2btHJQpu6d91wfdC)qSq6HyQGqNgsOaU2KLKDWu4OA7xBDNOCpQENOaU2KLKDWu4O6TVhtswA)6oHADAiOn82jCq4ei0DIY9GjzPM(bHpelKEiMki0PHepkaYYvSBZg9tyhesq7eL7r17KSr)e2bHe023JjjlB)6or5Eu9ojhaAQgZoHADAiOn82(23jGAWo8OyA)6Emj3VUtOwNgcAdVDcheobcDNOCpyswQPFq4dXcPhIPccDAiXt5wSdivcB2OFc7Gqc6qPpK8hAUYzXt5wSdivcbGuUFi4G7qZvolYbGWEb(caPC)qPStuUhvVtYg9tyhesqBFpMm2VUtOwNgcAdVDcheobcDNmx5SaVARerddBNgcJJgMfqkeJI1WHsFO5kNf4vBLiAyy70qyC0WSasHyuaOVgn(qS4qCf7wp(0or5Eu9ozGrqnnk23(EmzA)6oHADAiOn82jCq4ei0DYCLZICaiSxGVaqk33jk3JQ3jdmcQPrX(23JL62VUtOwNgcAdVDcheobcDNmx5S4PCl2bKkHaqk33jk3JQ3jdmcQPrX(23JXs7x3juRtdbTH3ozHj7ONWqwUI9OHThtYDcheobcDNWWdXubHonKihaYonk2TdvzIg2HsFO5kNf4vBLiAyy70qyC0WSasHyuavJ6dL(qk3dMKLA6he(qVFiMki0PHepkaYYvSBZg9tyhesqhk9Hy4HYbGWUcCciuUhmPdL(qYFigEO5kNfpK6rdZUgeas5(HsFigEO5kNfpLBXoGujeas5(HsFigEObaX0w5SfghsKdazNgf7hk9HK)qk3JQf5aq2PrXUG)Oaye(qSq6HKXHGdUdj)HC1qTludjl2bkE8uX28cWOGADAiOdL(q8Qmq1OwabuyvJTtaP(JaqkeJhkLdbhChs(d5QHAxGjfenmRxl(JGADAiOdL(qUcGrU4HuJ)ig4(HEx6HKj5COuoukhkLDYct2kNTW4q7XKCNOCpQENKdazNgf7BFpglB)6oHADAiOn82jlmzh9egYYvShnS9ysUt4GWjqO7egEiMki0PHe5aq2PrXUDOkt0Wou6dXWdLdaHDf4eqOCpyshk9HK)qYFi5pKY9OAroa0ungbjlXxE0Wou6dj)HuUhvlYbGMQXiizj(YjlG(A04d9(HKJGLoeCWDigEiWQPCbGrICaiSxGVGADAiOdLYHGdUdPCpQwmWiOMgf7cswIV8OHDO0hs(dPCpQwmWiOMgf7cswIVCYcOVgn(qVFi5iyPdbhChIHhcSAkxayKihac7f4lOwNgc6qPCOuou6dnx5S4HupAy21Gaqk3pukhco4oK8hYvd1UatkiAywVw8hb160qqhk9HCfaJCXdPg)rmW9d9U0djtY5qPpK8hAUYzXdPE0WSRbbGuUFO0hIHhs5EuTaZla)rqYs8LhnSdbhChIHhAUYzXt5wSdivcbGuUFO0hIHhAUYzXdPE0WSRbbGuUFO0hs5EuTaZla)rqYs8LhnSdL(qm8qpLBXoGujS4bYyW2OTzta7XpukhkLdLYozHjBLZwyCO9ysUtuUhvVtYbGStJI9TVh7LUFDNqTone0gE7eL7r17eUAmwL7r1wtG9DIjWUT1pTtuUhmjRRgQD823J9s2VUtOwNgcAdVDcheobcDNmx5SyGrqXnk(laKY9dL(qCf7wp(0HE)qZvolgyeuCJI)ca91OXhk9H4k2TE8Pd9(HMRCwawnzRSDOgrabG(A04DIY9O6DYaJGAAuSV99yWV7x3juRtdbTH3oHdcNaHUtgaetlmoKqsbMxa(ZHsFO5kNfpK6rdZUgeas5(HsFixnu7cmPGOHz9AXFeuRtdbDO0hYvamYfpKA8hXa3p07spKmjNdL(qk3dMKLA6he(qVFiMki0PHepLBXoGujSzJ(jSdcjODIY9O6DYaJGAAuSV99yskN9R7eQ1PHG2WBNWbHtGq3jm8qmvqOtdjgEkQdzTdvzIg2HsFO5kNfpK6rdZUgeas5(HsFigEO5kNfpLBXoGujeas5(HsFi5pKY9GjzHkxeW6WPd9(HKXHGdUdPCpyswQPFq4dXcPhIPccDAiXJcGSCf72Sr)e2bHe0HGdUdPCpyswQPFq4dXcPhIPccDAiXt5wSdivcB2OFc7Gqc6qPStuUhvVtgEkQdzTzJ(j823JjPK7x3juRtdbTH3oHdcNaHUtCfaJCXdPg)rmW9d9U0djtY5qPpKRgQDbMuq0WSET4pcQ1PHG2jk3JQ3jyEb4pBFpMKYy)6oHADAiOn82jCq4ei0DIY9GjzPM(bHpeloKm2jk3JQ3jqafw1y7eqQ)S99yskt7x3juRtdbTH3oHdcNaHUtuUhmjl10pi8HyH0dXubHonKqbCTjlj7GPWr1hk9H(ARIbUFiwi9qmvqOtdjuaxBYsYoykCuT9RTUtuUhvVtuaxBYsYoykCu923JjzQB)6oHADAiOn82jCq4ei0DIY9GjzPM(bHpelKEiMki0PHepkaYYvSBZg9tyhesq7eL7r17KSr)e2bHe023JjjlTFDNOCpQENKdanvJzNqTone0gEBF7BFNWKa4O69yYqoYqoskdjFP7KrkOJggENiZa)L6p24DSxo47qh61h6qXFOa(HYf4qSbQb7WJIj2oeGg3vaiOdHRpDiD51xDc6q8hTHryXX6lIMoelbFhkvvZKaobDi2C1qTlKlBhYRdXMRgQDHCfuRtdbX2HKxgYMI4y9frthILbFhkvvZKaobDi2C1qTlKlBhYRdXMRgQDHCfuRtdbX2HKxsztrCS(IOPdXYGVdLQQzsaNGoeBGvt5caJeYLTd51HydSAkxayKqUcQ1PHGy7qYldztrCS(IOPdb)cFhkvvZKaobDi2C1qTlKlBhYRdXMRgQDHCfuRtdbX2HKxsztrCS(IOPdjPKW3Hsv1mjGtqhInxnu7c5Y2H86qS5QHAxixb160qqSDi1pKm)L9IdjVKYMI4y9yvMb(l1FSX7yVCW3Ho0Rp0HI)qb8dLlWHydIY6Y4SDianURaqqhcxF6q6YRV6e0H4pAdJWIJ1xenDijHVdLQQzsaNGoeBGvt5caJeYLTd51HydSAkxayKqUcQ1PHGy7qQFiz(l7fhsEjLnfXX6lIMoKmGVdLQQzsaNGoeBUAO2fYLTd51HyZvd1UqUcQ1PHGy7qYldztrCS(IOPdXsW3Hsv1mjGtqhInxnu7c5Y2H86qS5QHAxixb160qqSDi5Lu2uehRViA6qSm47qPQAMeWjOdXMRgQDHCz7qEDi2C1qTlKRGADAii2oK8skBkIJ1xenDOxk8DOuvntc4e0HyZvd1UqUSDiVoeBUAO2fYvqToneeBhsEjLnfXX6lIMoKKVu47qPQAMeWjOdLe)uDimJTRYEOXJXJd51HEXsp0VGwMf(q1abuVahs(XJuoK8skBkIJ1xenDijFPW3Hsv1mjGtqhInE1qRWfYLTd51HyJxn0kCHCfuRtdbX2HKxsztrCS(IOPdjj8l8DOuvntc4e0HyJxn0kCHCz7qEDi24vdTcxixb160qqSDi5Lu2uehRViA6qYqoW3Hsv1mjGtqhInWQPCbGrc5Y2H86qSbwnLlamsixb160qqSDi5Lu2uehRViA6qYqs47qPQAMeWjOdXgy1uUaWiHCz7qEDi2aRMYfagjKRGADAii2oK8skBkIJ1xenDizid47qPQAMeWjOdXgy1uUaWiHCz7qEDi2aRMYfagjKRGADAii2oK8skBkIJ1xenDizK6GVdLQQzsaNGoeBUAO2fYLTd51HyZvd1UqUcQ1PHGy7qYlPSPiowFr00HKblbFhkvvZKaobDi2aRMYfagjKlBhYRdXgy1uUaWiHCfuRtdbX2HKxsztrCSESkZa)L6p24DSxo47qh61h6qXFOa(HYf4qSnaiE9NQZ2Ha04UcabDiC9PdPlV(QtqhI)OnmclowFr00HKb8DOuvntc4e0HyZvd1UqUSDiVoeBUAO2fYvqToneeBhsEjLnfXX6lIMoKmGVdLQQzsaNGoeBUAO2fYLTd51HyZvd1UqUcQ1PHGy7qQFiz(l7fhsEjLnfXX6lIMoKmbFhkvvZKaobDi2C1qTlKlBhYRdXMRgQDHCfuRtdbX2HKxsztrCS(IOPdjtW3Hsv1mjGtqhInxnu7c5Y2H86qS5QHAxixb160qqSDi1pKm)L9IdjVKYMI4y9frthk1bFhkvvZKaobDi2C1qTlKlBhYRdXMRgQDHCfuRtdbX2HKxsztrCS(IOPdL6GVdLQQzsaNGoeBUAO2fYLTd51HyZvd1UqUcQ1PHGy7qQFiz(l7fhsEjLnfXX6lIMoelbFhkvvZKaobDi2C1qTlKlBhYRdXMRgQDHCfuRtdbX2HKxsztrCS(IOPdXsW3Hsv1mjGtqhInxnu7c5Y2H86qS5QHAxixb160qqSDi1pKm)L9IdjVKYMI4y9yvMb(l1FSX7yVCW3Ho0Rp0HI)qb8dLlWHyJx)5c7r1wEvgOAuJz7qaACxbGGoeU(0H0LxF1jOdXF0ggHfhRViA6qVe47qPQAMeWjOdXgy1uUaWiHCz7qEDi2aRMYfagjKRGADAii2oK8skBkIJ1Jvzg4Vu)XgVJ9YbFh6qV(qhk(dfWpuUahInL7btY6QHAhZ2Ha04UcabDiC9PdPlV(QtqhI)OnmclowFr00HKb8DOuvntc4e0HyZvd1UqUSDiVoeBUAO2fYvqToneeBhsEziBkIJ1xenDizc(ouQQMjbCc6qS5QHAxix2oKxhInxnu7c5kOwNgcITdjVKYMI4y9yvMb(l1FSX7yVCW3Ho0Rp0HI)qb8dLlWHyd7AdPailOC1JQz7qaACxbGGoeU(0H0LxF1jOdXF0ggHfhRViA6qSe8DOuvntc4e0HyZvd1UqUSDiVoeBUAO2fYvqToneeBhsEjLnfXX6lIMoeld(ouQQMjbCc6qS5QHAxix2oKxhInxnu7c5kOwNgcITdP(HK5VSxCi5Lu2uehRViA6qVe47qPQAMeWjOdXMRgQDHCz7qEDi2C1qTlKRGADAii2oK8skBkIJ1xenDOxc8DOuvntc4e0HydSAkxayKqUSDiVoeBGvt5caJeYvqToneeBhsEziBkIJ1xenDi4x47qPQAMeWjOdXMRgQDHCz7qEDi2C1qTlKRGADAii2oK8skBkIJ1xenDijLd8DOuvntc4e0HyZvd1UqUSDiVoeBUAO2fYvqToneeBhsEjLnfXX6lIMoKKYe8DOuvntc4e0HyZvd1UqUSDiVoeBUAO2fYvqToneeBhs9djZFzV4qYlPSPiowpwLzG)s9hB8o2lh8DOd96dDO4pua)q5cCi241FUWEuTD4rXeBhcqJ7kae0HW1NoKU86RobDi(J2WiS4y9frthsgW3Hsv1mjGtqhInE1qRWfYLTd51HyJxn0kCHCfuRtdbX2Hu)qY8x2loK8skBkIJ1xenDizc(ouQQMjbCc6qSXRgAfUqUSDiVoeB8QHwHlKRGADAii2oK8skBkIJ1xenDiwg8DOuvntc4e0HyJxn0kCHCz7qEDi24vdTcxixb160qqSDi5Lu2uehRViA6qVu47qPQAMeWjOdLe)uDimJTRYEOXJd51HEXspeuWmWr1hQgiG6f4qYZGuoK8skBkIJ1xenDOxk8DOuvntc4e0HyJxn0kCHCz7qEDi24vdTcxixb160qqSDi1pKm)L9IdjVKYMI4y9frth6LaFhkvvZKaobDOK4NQdHzSDv2dnECiVo0lw6HGcMboQ(q1abuVahsEgKYHKxsztrCS(IOPd9sGVdLQQzsaNGoeB8QHwHlKlBhYRdXgVAOv4c5kOwNgcITdP(HK5VSxCi5Lu2uehRViA6qWVW3Hsv1mjGtqhInE1qRWfYLTd51HyJxn0kCHCfuRtdbX2HKxsztrCS(IOPdjPCGVdLQQzsaNGoeBUAO2fYLTd51HyZvd1UqUcQ1PHGy7qQFiz(l7fhsEjLnfXX6lIMoKKYb(ouQQMjbCc6qSbwnLlamsix2oKxhInWQPCbGrc5kOwNgcITdjVKYMI4y9frthssjHVdLQQzsaNGoeBUAO2fYLTd51HyZvd1UqUcQ1PHGy7qQFiz(l7fhsEjLnfXX6lIMoKKscFhkvvZKaobDi2aRMYfagjKlBhYRdXgy1uUaWiHCfuRtdbX2HKxsztrCS(IOPdjPmGVdLQQzsaNGoeBGvt5caJeYLTd51HydSAkxayKqUcQ1PHGy7qYlPSPiowFr00HKuMGVdLQQzsaNGoeBGvt5caJeYLTd51HydSAkxayKqUcQ1PHGy7qYlPSPiowFr00HKKLGVdLQQzsaNGoeBUAO2fYLTd51HyZvd1UqUcQ1PHGy7qYlPSPiowFr00HKKLGVdLQQzsaNGoeBGvt5caJeYLTd51HydSAkxayKqUcQ1PHGy7qYldztrCS(IOPdj5lf(ouQQMjbCc6qSbwnLlamsix2oKxhInWQPCbGrc5kOwNgcITdjVKYMI4y9frthsgPo47qPQAMeWjOdXMRgQDHCz7qEDi2C1qTlKRGADAii2oK8Yq2uehRViA6qYGLbFhkvvZKaobDi24vdTcxix2oKxhInE1qRWfYvqToneeBhs9djZFzV4qYlPSPiowFr00HKj5aFhkvvZKaobDi2C1qTlKlBhYRdXMRgQDHCfuRtdbX2Hu)qY8x2loK8skBkIJ1J1X7FOaobDOx6HuUhvFitGDS4yDNmaQCyODsQDiwEaOdb)qHrhRP2HECFadFmGbWc)znf86ZaC8xg1JQ5an7mahFodowtTd9YtC6pjWHKHmX(HKHCKHCowpwtTdLQhTHry47yn1o04Fi4Ny6q5a2JBb0xJgFiG6pe4q(J2hYvamYfE8jRxwOGouUahYOyF8XeVAOdPZWeoJhAHvyewCSMAhA8p0lQct9H4k2peGg3vaOp1o(q5cCOuv)5c7r1hs(qqc2peu1S5h6Pmqhk8dLlWH0dLbe(5qWpiNkWH4k2trCSMAhA8pKmV1PHoe2bb3pe)H4senSdv9H0dLPrhkxajWhk6d5p0HG)KzFXH86qacAXPdnQasykfsCSESMAhsMllXxobDOjLlaDiE9NQFOjblAS4qWFCon44d1vp(pk4NxMdPCpQgFOQnmkowvUhvJfdaIx)P6VjLbkGRnzJ2jJH4(XAQDOxFc8HyQGqNg6q4bIh5GWhYFOd1R)KahQYhYvamYXhs9dn6j4phk1R8dL4asL4qSCJ(jSdcji8HQLJdi6qv(qPQ(Zf2JQpe(PwgOdnPdTWeK4yv5EunwmaiE9NQ)MugWubHone7T(jPpLBXoGujSzJ(jSdcji2RbPyYzpYszQGqNgs8uUf7asLWMn6NWoiKGKkh2zQMfjvgJJRgQDr2OFYoOo)5nzACyORgQDr2OFYoOo)5yn1o0Rpb(qmvqOtdDi8aXJCq4d5p0H61FsGdv5d5kag54dP(Hg9e8NdL6PaOdLkf7hILB0pHDqibHpuTCCarhQYhkv1FUWEu9HWp1YaDOjDOfMGoKIpuomgciowvUhvJfdaIx)P6VjLbmvqOtdXERFs6JcGSCf72Sr)e2bHee71Gum5ShzPmvqOtdjEuaKLRy3Mn6NWoiKGKkh2zQMfjvgJJRgQDr2OFYoOo)5nzACyORgQDr2OFYoOo)5yn1o0Rpb(qmvqOtdDi8aXJCq4d5p0H61FsGdv5d5kag54dP(Hg9e8NdL6v(HsCaPsCiwUr)e2bHee(qkGo0ctqhcAbIg2Hsv9NlShvlowvUhvJfdaIx)P6VjLbmvqOtdXERFskV(Zf2JQTzJ(jSdcji2RbPyYzpYszQGqNgsWR)CH9OAB2OFc7GqcsQCyNPAwKuzACC1qTlYg9t2b15pVXYghg6QHAxKn6NSdQZFowtTd96tGpetfe60qhcpq8ihe(q(dDOE9Ne4qv(qUcGro(qQFOrpb)5qWFaU20HK5YoykCu9HQLJdi6qv(qPQ(Zf2JQpe(PwgOdnPdTWeK4yv5EunwmaiE9NQ)MugWubHone7T(jPkGRnzjzhmfoQM9AqkMC2JSuMki0PHekGRnzjzhmfoQwQCyNPAwKu4x43XXvd1UiB0pzhuN)8Mmghg6QHAxKn6NSdQZFowtTd96tGpetfe60qhcpq8ihe(q(dDObcWP2vy0HQ8H(ARhAsMA0Hg9e8Ndb)b4AthsMl7GPWr1hAuymhQl)qt6qlmbjowvUhvJfdaIx)P6VjLbmvqOtdXERFsQc4Atws2btHJQTFTv2HOSUmU0uNCyVgKcim5hRP2HE9jWhIPccDAOdf4dTWe0H86q4bIhzgpK)qhs)1Q9dv5d5XNou0hct8QHWhYFu)q)f2p0GIXhsZobouQQ)CH9O6drYoeacFOjLlaDiwUr)e2bHee(qJcJ5qt6qlmbDOUaF1yyuCSQCpQglgaeV(t1FtkdyQGqNgI9w)KuiYOmAZg9tyhesqSdrzDzCPYH9AqkGWKFSMAhsMj8Ndb)pAit0Wy)qPQ(Zf2JQzdFiEvgOAuFOrHXCOjDiabT4e0HMmEi9qaTHQ)H0FTAN9dnx(H8h6q96pjWHQ8H4GWXhc7kWXhIjby8qpbSNdPzNahs5EWu9OHDOuv)5c7r1hsBOdHn1i8HGQr9H8AKcGWhYFOdrn0HQ8Hsv9NlShvZg(q8Qmq1OwCizMhQp0xLiAyhcI4boQgFOOpK)qhc(tM9fSFOuv)5c7r1SHpeG(A0rd7q8Qmq1O(qb(qacAXjOdnz8q(tGpugOCpQ(qEDiLZRv7hkxGdb)pAit0WehRk3JQXIbaXR)u93KYaMki0PHyV1pjvIOHmrdZciOf3JQzhIY6Y4sLJi1XEnifqyYpwtTd96dDiOfq9O6dv5dPhkz1hc(F0WydFi4zimoAyhkv1FUWEuT4yv5EunwmaiE9NQ)MugWubHone7T(jPyjMwOfq9OA2RbPyYzNPAwKuw6yv5EunwmaiE9NQ)MugWubHone7T(jP86pxypQ2wTDHj2RbPyYzNPAwKuACxXWabj(kxNaYIFiYT)fo4WbhnURyyGGeFTJmH9Ywz7xHAcJHdoACxXWabjGzuOq9cGTtfcgbhC04UIHbcsaZOqH6faB)eKAmr1WbhnURyyGGebSo8OA7xHryBEHj4GJg3vmmqqcF8uBcBNkqc8q0ego4OXDfddeKqhpxaYFkSfhnmcYoywFfgbhC04UIHbcsOnpO2Ts0LBRSDuGHQpCWrJ7kggiib(P4smdNayBwByWbhnURyyGGenTaQXIzS1bmzP(rBobGdoACxXWabjMQHYbGStG28NJ1u7qPE1OdzQg2HMuUa0Hsv9NlShvFi8tTmqhsM)hyeqQ5qVmauRnNo0Ko0ctqW)8yv5EunwmaiE9NQ)MugWubHone7T(jP0FGraPgBbGAT5KfImkJSdrzDzCPs(syVgKcim5hRP2Hs9QrhYunSdnPCbOdLQ6pxypQ(q4NAzGoKdIwcYXhYFu)qoiGbJahspe(rbe0HKHCoeM4vdDOu9YFOQpu5pe4qoiAjihFOU8dnPdTWee8ppwvUhvJfdaIx)P6VjLbmvqOtdXERFsA12fMS8Lx5m71Gum5SZunlsQmKd7rwktfe60qcE9NlShvBR2UW0XQY9OASyaq86pv)nPmGPccDAi2B9tsR2UWKLV8kNzVgKIjNDMQzrsLblXEKLsJ7kggiiXx56eqw8drU9VWb)yv5EunwmaiE9NQ)MugWubHone7T(jPvBxyYYxELZSxdsXKZot1SiPYqoVXubHonKG(dmci1ylauRnNSqKrzK9ilLg3vmmqqc6pWiGuJTaqT2C6yn1o0Rp0H61FsGdv5d5kag54dL8ezpAyhsMTgrGdHFQLb6qt6qlmbDOQpe0cenSdLQ6pxypQwCSQCpQglgaeV(t1FtkdyQGqNgI9w)KuE9NlShvBXpr2JgMDOgra2HOSUmUuzWEnifqyYpwvUhvJfdaIx)P6VjLblmzdN(S36NKIRLXgW6WjWXQY9OASyaq86pv)nPm4haqbSXxHrhRk3JQXIbaXR)u93KYGbgb10OyN9ilLHdaIPyGrqnnk2pwpwtTdjZLL4lNGoeXKamEip(0H8h6qk3lWHc8HuMAy0PHehRk3JQXs51QDcGhiJH9ilLHGvt5caJeqbMhdMOvaJwE9)AdDSQCpQg)MugWubHone7T(jPE8jRxwE9NlShvZEnifto7mvZIK6QHAxKdaHDf4eyCYbGWUcCcia0xJg)M88Qmq1OwWR)CH9OAbG(A04XrEjhFMki0PHesenKjAywabT4Eu944QHAxir0qMOHLskJdd5vzGQrTGx)5c7r1caPqmooZvol41FUWEuTaQg1hRP2HGFOsqhcVa0Hsv9NlShvFOaFiiYOmsqhkYhQjcIGo0uXe0HQ(q(dDi6pWiGuJTaqT2CYcrgLXdXubHon0XQY9OA8Bszatfe60qS36NK6XNSEz51FUWEun71G0Vkl7mvZIKYubHonKG(dmci1ylauRnNSqKrzC8LNxLbQg1c6pWiGuJTaqT2CsaTaQhvp(8Qmq1Owq)bgbKASfaQ1Mtca91OXPmomKxLbQg1c6pWiGuJTaqT2CsaifIr2JSuACxXWabjO)aJasn2ca1AZPJvL7r143KYaMki0PHyV1pj1Jpz9YYR)CH9OA2RbPFvw2zQMfjLxLbQg1cygfkuVay7uHGrca91OXShzP04UIHbcsaZOqH6faBNkem6yv5Eun(nPmGPccDAi2B9ts94twVS86pxypQM9Aq6xLLDMQzrsNRCwawnzRSDOgrabG(A0y2JSuxnu7cWQjBLTd1icKEUYzbV(Zf2JQfq1O(yv5Eun(nPmGPccDAi2B9ts94twVS86pxypQM9Aq6xLLDMQzrs5vzGQrTaSAYwz7qnIaca91OXVnx5SaSAYwz7qnIacOfq9OA2JSuxnu7cWQjBLTd1icKEUYzbV(Zf2JQfq1OonVkdunQfGvt2kBhQreqaOVgn(nw6DMki0PHeE8jRxwE9NlShvFSQCpQg)MugGFIShnm7qnIaShzPZvol41FUWEuTaQg1PzQGqNgs4XNSEz51FUWEunlYlJXciOf3JQtlpVkdunQfGvt2kBhQreqaOVgnMf5LXybe0I7r1WbhdD1qTlaRMSv2ouJiqkPzO8ZvolIotGwnwUI5kejwdPNRCw8uUf7asLqaiL7PKwEL7btYsn9dc)otfe60qcE9NlShvBXpr2JgMDOgra4Gt5EWKSut)GWVZubHonKGx)5c7r12Sr)e2bHeeCWXubHonKWJpz9YYR)CH9O6XpVmglGGwCpQMf8Qmq1OoLJvL7r143KYaGcfA7w8GcKG9ilv(5kNf86pxypQwavJ60ZvolaRMSv2ouJiGaQg1PLNPccDAiHhFY6LLx)5c7r1VtYs8Ltwp(eCWXubHonKWJpz9YYR)CH9OAwWRYavJAbqHcTDlEqbsiGwa1JQtjf4Gt(5kNfGvt2kBhQreqSgsZubHonKWJpz9YYR)CH9OAwitYjLJvL7r143KYais9NzbAI9ilDUYzbV(Zf2JQfq1Oo9CLZcWQjBLTd1iciGQrDAMki0PHeE8jRxwE9NlShv)ojlXxoz94thRk3JQXVjLb)aaka2wzRxGp1o7rwktfe60qcp(K1llV(Zf2JQFxQmLEUYzbV(Zf2JQfq1O(yn1oelVahc(hu7pmcy)qlmDi9qS8aqhcEgf7hI)Oay0HGwGOHDi4hbaua8HQ8HETaFQ9dXvSFiVoKYScOdX1HHOHDi(JcGr4df5dnE7mbA1COuPyUcrhkWhQl)qyYqCNGehRk3JQXVjLb5aq2PrXo7lmzh9egYYvShnmPsYEKLQCpQw8daOayBLTEb(u7cswIV8OHLoVmglG4pkagz94tJVY9OAXpaGcGTv26f4tTlizj(YjlG(A043tDPz4t5wSdivclEGmgSnAB2eWE80mCUYzXt5wSdivcbGuUFSQCpQg)Mug8daOa24RWi2JS05kNf86pxypQwavJ60q0CLZcGcfA7w8GcKWYCzAcOZWeoJcOAuFSQCpQg)MugSWKnC6ZoLZe3TT(jPWmkuOEbW2PcbJypYszQGqNgs4XNSEz51FUWEunl4vzGQr94ZshRk3JQXVjLblmzdN(S36NKs)bgbKASfaQ1MtShzPmvqOtdj84twVS86pxypQ(DPmvqOtdjO)aJasn2ca1AZjlezugpwvUhvJFtkdwyYgo9zV1pjfMHXHhBLTkgh)WOEun7rwktfe60qcp(K1llV(Zf2JQzHuMki0PHevBxyYYxELZhRk3JQXVjLblmzdN(S36NK(vUobKf)qKB)lCWzpYszQGqNgs4XNSEz51FUWEu97szPJ1u7qJ38Hw4OHDi9qyNavaDOQh)fMou40N9dPMrkJ4dTW0HE5bKcLdaDi4FqymzouTCCarhQYhkv1FUWEuT4qVm)HaJcmX(HgarbcF8Ko0chnSd9Ydifkha6qW)GWyYCOrH)COuv)5c7r1hQAdJhkYhA82zc0Q5qPsXCfIouGpe160qqhsBOdPhAHvy0HgvnB(HM0Hmf2puXKahYFOdbTaQhvFOkFi)HouoG94IJvL7r143KYGfMSHtF2B9tsHaKcLdazzsymzypYszQGqNgs4XNSEz51FUWEunlKYubHonKOA7ctw(YRCoT8ZvolIotGwnwUI5kejWUYLq6CLZIOZeOvJLRyUcrIVkRf7kxc4GJH8QHwHlIotGwnwUI5kebhCmvqOtdj41FUWEuTTA7ctWbhtfe60qcp(K1llV(Zf2JQFJLyroG94wa91OXJhJh8Qmq1OoLJ1u7qj1YCOXlSoCcCi8tTmqhAshAHjOdf9H0dnsz8q(J6hcQiCZMFOODcKjaDOrH)COYFiWHQE8xy6qoiAjihlo0lZFiWHCq0sqo(qq1H6YpKdcyWiWH0dHFuabDOXBQE5pu1hkC2peUou4hIR9HM0Hwyc6qGa2JFin7e4qAZ4Hk)HahQ6XFHPd5GOLGCXXQY9OA8BszWct2WPp7T(jP4AzSbSoCcWEKLYubHonKWJpz9YYR)CH9OAwiLPccDAir12fMS8Lx58BsYsJJ8mvqOtdjQ2UWKLV8kNzHCsbo4yQGqNgs4XNSEz51FUWEu97skNJ1u7qVccyWiWHsQL5qJxyHtGdrkWW4Hgf(ZHgVDMaTAouQumxHOdvGdn6H6df(HgP4dnaiUIDXXQY9OA8BszaxBozSZvoZERFskUwgBaRdpQM9ilLPccDAiHhFY6LLx)5c7r1Sqktfe60qIQTlmz5lVY50mvqOtdj84twVS86pxypQMfsLKLghACxXWabjGaKcLdazzsymzs7XNENLsZqE1qRWfrNjqRglxXCfIGdU5kNfrNjqRglxXCfIeyx5siDUYzr0zc0QXYvmxHiXxL1IDLlXXAQDOxoYpK)qhckW8yWeTcy0YR)xBOdnx58HwdSFOvBim(q86pxypQ(qb(q4QAXXQY9OA8BszaVwTta8azmShzPGvt5caJeqbMhdMOvaJwE9)AdLMxLbQg1I5kNTqbMhdMOvaJwE9)AdjaKcXy65kNfqbMhdMOvaJwE9)AdzvaxBsavJ60mCUYzbuG5XGjAfWOLx)V2qI1qAMki0PHeE8jRxwE9NlShvZczWshRk3JQXVjLbkGRnzjzhmfoQM9ilfSAkxayKakW8yWeTcy0YR)xBO08Qmq1Owmx5SfkW8yWeTcy0YR)xBibGuigtpx5SakW8yWeTcy0YR)xBiRc4AtcOAuNMHZvolGcmpgmrRagT86)1gsSgsZubHonKWJpz9YYR)CH9OAwidw6yv5Eun(nPmidkSplJZEKLcwnLlamsafyEmyIwbmA51)RnuAEvgOAulMRC2cfyEmyIwbmA51)RnKaqkeJPNRCwafyEmyIwbmA51)RnKndkSlGQrDAgox5SakW8yWeTcy0YR)xBiXAintfe60qcp(K1llV(Zf2JQzHmyPJvL7r143KYaUAmwL7r1wtGD2B9ts51FUWEuTD4rXe7rwktfe60qcp(K1llV(Zf2JQFxQCowvUhvJFtkdyQGqNgI9fMSvoBHXHKkj7lmzh9egYYvShnmPsYERFsAoaKDAuSBhQYenm2zQMfjLPccDAiHhFY6LLx)5c7r1JVm9UY9OAroaKDAuSlYlJXci(JcGrwp(04RCpQwGFIShnm7qnIaI8YySacAX9O6XrEEvgOAulWpr2JgMDOgrabG(A043zQGqNgs4XNSEz51FUWEuDkPzQGqNgs4XNSEz51FUWEu975a2JBb0xJgdhCUAO2fGvt2kBhQrei9CLZcWQjBLTd1iciGQrDAEvgOAulaRMSv2ouJiGaqFnA87k3JQf5aq2PrXUiVmglG4pkagz94tJVY9OAb(jYE0WSd1iciYlJXciOf3JQhh55vzGQrTa)ezpAy2HAebea6RrJFNxLbQg1cWQjBLTd1icia0xJgNsAEvgOAulaRMSv2ouJiGaqFnA875a2JBb0xJgFSQCpQg)MugWubHone7T(jPdpf1HS2HQmrdJDMQzrszQGqNgs4XNSEz51FUWEu97k3JQfdpf1HS2Sr)ewKxgJfq8hfaJSE8PXx5EuTa)ezpAy2HAebe5LXybe0I7r1JJ88Qmq1OwGFIShnm7qnIaca91OXVZubHonKWJpz9YYR)CH9O6usZubHonKWJpz9YYR)CH9O63ZbSh3cOVgngo4aRMYfagjWR2kr0WW2PHW4OHbhCE8P3zPJvL7r143KYaWQjBLTd1icWEKLox5SaSAYwz7qnIacOAuNMHZvolYbGWEb(caPCpT8mvqOtdj84twVS86pxypQMfsNRCwawnzRSDOgrab0cOEuDAMki0PHeE8jRxwE9NlShvZcL7r1ICai70OyxKxgJfq8hfaJSE8j4GJPccDAiHhFY6LLx)5c7r1SihWEClG(A04uowvUhvJFtkd4QXyvUhvBnb2zV1pjfud2HhftShzPZvolaRMSv2ouJiGynKwEMki0PHeE8jRxwE9NlShvZc5KYXAQDizMhQpuQNcG4k2Jg2Hy5g9thkXbHee7hILha6qWZOyhFi8tTmqhAshAHjOd51HGrnbuNouQx5hkXbKkb(qAdDiVoejRtn0HGNrXoboe8df7eqCSQCpQg)MugKdazNgf7SVWKTYzlmoKujzFHj7ONWqwUI9OHjvs2JSugYubHonKihaYonk2TdvzIgwA5zQGqNgs4XNSEz51FUWEunlKdCWPCpyswQPFqywiLPccDAiXJcGSCf72Sr)e2bHeuAgMdaHDf4eqOCpysPz4CLZINYTyhqQecaPCpT8ZvolEi1JgMDniaKY90k3JQfzJ(jSdcjibjlXxozb0xJg)UCeSeCWXFuamcBZaL7r1QHfsLrkPCSMAh6LFbIg2Hy5bGWUcCcW(Hy5bGoe8mk2Xhsb0Hwyc6q44hgfyy8qEDiOfiAyhkv1FUWEuT4qVCuta1yyK9d5peJhsb0Hwyc6qEDiyuta1PdL6v(HsCaPsGp0OhQpeheo(qJcJ5qD5hAshAKIDc6qAdDOrH)Ci4zuStGdb)qXoby)q(dX4HWp1YaDOjDi8aGuOdvl)qEDOVgTRrFi)Hoe8mk2jWHGFOyNahAUYzXXQY9OA8BszqoaKDAuSZ(ct2kNTW4qsLK9fMSJEcdz5k2JgMujzpYsZbGWUcCciuUhmP08hfaJWSqQKPzitfe60qICai70Oy3ouLjAyPLNHk3JQf5aqt1yeKSeF5rdlndvUhvlgyeutJIDr02SjG94PNRCw8qQhnm7AqaiL7WbNY9OAroa0ungbjlXxE0WsZW5kNfpLBXoGujeas5oCWPCpQwmWiOMgf7IOTzta7Xtpx5S4HupAy21Gaqk3tZW5kNfpLBXoGujeas5EkhRP2HG)ywb0H46Wq0Woelpa0HGNrX(H4pkagHp0ONWqhI)ODtMOHDOKNi7rd7qYS1icCSQCpQg)MugKdazNgf7SVWKD0tyilxXE0WKkj7rwQY9OAb(jYE0WSd1iciizj(YJgw68YySaI)OayK1Jp9UY9OAb(jYE0WSd1ici8GlHfqqlUhvNEUYzXt5wSdivcbunQt7XNyHKY5yv5Eun(nPmGRgJv5EuT1eyN9w)KuSRnKcGSGYvpQM9ilvEMki0PHeE8jRxwE9NlShvZc5Ks65kNfGvt2kBhQreqavJ6JvL7r143KYamVa8NJ1JvL7r1yHY9GjzD1qTJLAcMrdZoR)K9ilv5EWKSut)GWSqY0Zvol41FUWEuTaQg1PLNPccDAiHhFY6LLx)5c7r1SGxLbQg1ctWmAy2z9NcOfq9OA4GJPccDAiHhFY6LLx)5c7r1VlvoPCSQCpQgluUhmjRRgQD8BszWNCQaShzPmvqOtdj84twVS86pxypQ(DPYbo4KNxLbQg1Ip5ubeqlG6r1VZubHonKWJpz9YYR)CH9O60m0vd1UaSAYwz7qnIaPahCUAO2fGvt2kBhQrei9CLZcWQjBLTd1iciwdPzQGqNgs4XNSEz51FUWEunluUhvl(KtfqWRYavJA4GlhWEClG(A043zQGqNgs4XNSEz51FUWEu9XQY9OASq5EWKSUAO2XVjLbqafw1y7eqQ)WEKL6QHAxOgswSdu84PIT5fGX0Ypx5SGx)5c7r1cOAuNMHZvolEk3IDaPsiaKY9uowpwvUhvJf86pxypQ2YRYavJAS0HYJQpwvUhvJf86pxypQ2YRYavJA8BszW0ufKnVamESQCpQgl41FUWEuTLxLbQg143KYGjbWeqIOHDSQCpQgl41FUWEuTLxLbQg143KYGCaOPPkOJvL7r1ybV(Zf2JQT8Qmq1Og)MugOnNWoqnwUAmhRk3JQXcE9NlShvB5vzGQrn(nPmyHjB40hFSQCpQgl41FUWEuTLxLbQg143KYGfMSHtF2xyYw5SfghsQKSt5mXDBRFskmJcfQxaSDQqWi2JSuL7r1Ip5uberBZMa2JBb0xJg)Uu5iyPJvL7r1ybV(Zf2JQT8Qmq1Og)Mug4XNSJuWa7rwky1uUaWiHt)HcOg7ifmKEUYzbj7JUWEuTynCSESQCpQgl41FUWEuTD4rXKuta7XXw4FxqW(u7ShzPZvol41FUWEuTaQg1hRP2HK5yp(Qth6PgDit1WouQQ)CH9O6dnkmMdzuSFi)rBjWhYRdLS6db)pAySHpe8meghnSd51HGiNa)OPd9uJoelpa0HGNrXo(q4NAzGo0Ko0ctqIJvL7r1ybV(Zf2JQTdpkMEtkdyQGqNgI9fMSvoBHXHKkj7lmzh9egYYvShnmPsYERFskjRtnebz51FUWEuTfqFnAm71Gum5SZunls6CLZcE9NlShvla0xJg)2CLZcE9NlShvlGwa1JQhh55vzGQrTGx)5c7r1ca91OXVpx5SGx)5c7r1ca91OXPWEKLYRgAfUi6mbA1y5kMRq0XAQDi4pii8H8h6qqlG6r1hQYhYFOdLS6db)pAySHpe8meghnSdLQ6pxypQ(qEDi)Hoe1qhQYhYFOdXxaa1(Hsv9NlShvFOiFi)HoexX(Hgvld0H41FWqoDiOfiAyhYFc8Hsv9NlShvlowvUhvJf86pxypQ2o8Oy6nPmGPccDAi2xyYw5SfghsQKSVWKD0tyilxXE0WKkj7T(jPKSo1qeKLx)5c7r1wa91OXSxdsvii2zQMfjLPccDAibwIPfAbupQM9ilLxn0kCr0zc0QXYvmxHO0Ypx5SaVARerddBNgcJJgMfqkeJI1aCWXubHonKGK1PgIGS86pxypQ2cOVgnMfskyPXbghs8vzhh5NRCwGxTvIOHHTtdHXrdt8vzTyx5sm(ZvolWR2kr0WW2PHW4OHjWUYLiLuowvUhvJf86pxypQ2o8Oy6nPmyQWSv26GGlbM9ilDUYzbV(Zf2JQfq1O(yv5EunwWR)CH9OA7WJIP3KYatWmAy2z9NShzPk3dMKLA6heMfsMEUYzbV(Zf2JQfq1O(yn1oKmt4p1Yp04TZeOvZHsLI5keX(HG)DH9dTW0Hy5bGoe8mk2XhA0d1hYFigp0OQzZp0F18NdXbHJpK2qhA0d1hILhac7f4FOaFiOAulowvUhvJf86pxypQ2o8Oy6nPmihaYonk2zFHjBLZwyCiPsY(ct2rpHHSCf7rdtQKShzPYRCpyswQPFq43LQCpyswOYfbSoCco4yiVkdunQfdpf1HS2Sr)ewaifIXusZqE1qRWfrNjqRglxXCfIsZFuamcZcPsMEUYzbV(Zf2JQfRH0mCUYzroae2lWxaiL7Pz4CLZINYTyhqQecaPCp9t5wSdivclEGmgSnAB2eWE83MRCw8qQhnm7AqaiL7VlJJ1u7qYmH)COXBNjqRMdLkfZviI9dXYdaDi4zuSFOfMoe(PwgOdnPdPqqHhvRggpeVASd0OjOdHRd5pQFOWpuGpux(HM0Hwyc6qR2qy8HgVDMaTAouQumxHOdf4dPZA5hYRdrYoea6qf4q(dbOdPa6q)cqhYF0(quxlyphILha6qWZOyhFiVoejRtn0HgVDMaTAouQumxHOd51H8h6qudDOkFOuv)5c7r1IJvL7r1ybV(Zf2JQTdpkMEtkdyQGqNgI9fMSvoBHXHKkj7lmzh9egYYvShnmPsYERFskj7aXDcYMdazNgf7y2RbPyYzNPAwKuL7r1ICai70OyxWFuamcBZaL7r1Q5n5zQGqNgsqY6udrqwE9NlShvBb0xJgp(ZvolIotGwnwUI5kejGwa1JQtz8GxLbQg1ICai70OyxaTaQhvZEKLYRgAfUi6mbA1y5kMRq0XQY9OASGx)5c7r12HhftVjLbmvqOtdX(ct2kNTW4qsLK9fMSJEcdz5k2JgMujzV1pjTjcIGS5aq2PrXoM9AqkMC2zQMfjLtHrEMki0PHeKSo1qeKLx)5c7r1wa91OXJhYpx5Si6mbA1y5kMRqKaAbupQE8HXHeFv2usH9ilLxn0kCr0zc0QXYvmxHOJvL7r1ybV(Zf2JQTdpkMEtkdYbGStJID2xyYw5SfghsQKSVWKD0tyilxXE0WKkj7rwQ8k3dMKLA6he(DPk3dMKfQCraRdNGdogYRYavJAXWtrDiRnB0pHfasHymL08QHwHlIotGwnwUI5keLM)OayeMfsLmT8mvqOtdjizhiUtq2Cai70OyhZcPmvqOtdjAIGiiBoaKDAuSJHdoMki0PHeKSo1qeKLx)5c7r1wa91OXVlDUYzr0zc0QXYvmxHib0cOEunCWnx5Si6mbA1y5kMRqKa7kxI3LbCWnx5Si6mbA1y5kMRqKaqFnA87W4qIVklCWXRYavJAb(jYE0WSd1iciaKcXyAL7btYsn9dcZcPmvqOtdj41FUWEuTf)ezpAy2HAebsZlMuRTl6a2JBZkLs65kNf86pxypQwSgslpdNRCwKdaH9c8fas5oCWnx5Si6mbA1y5kMRqKaqFnA87YrWsPKMHZvolEk3IDaPsiaKY90pLBXoGujS4bYyW2OTzta7XFBUYzXdPE0WSRbbGuU)UmowvUhvJf86pxypQ2o8Oy6nPmGxR2jaEGmg2JSuWQPCbGrcOaZJbt0kGrlV(FTHspx5SakW8yWeTcy0YR)xBibunQtpx5SakW8yWeTcy0YR)xBiRc4AtcOAuNMxLbQg1I5kNTqbMhdMOvaJwE9)AdjaKcXyAg6QHAxawnzRSDOgrGJvL7r1ybV(Zf2JQTdpkMEtkduaxBYsYoykCun7rwky1uUaWibuG5XGjAfWOLx)V2qPNRCwafyEmyIwbmA51)RnKaQg1PNRCwafyEmyIwbmA51)RnKvbCTjbunQtZRYavJAXCLZwOaZJbt0kGrlV(FTHeasHymndD1qTlaRMSv2ouJiWXQY9OASGx)5c7r12HhftVjLbzqH9zzC2JSuWQPCbGrcOaZJbt0kGrlV(FTHspx5SakW8yWeTcy0YR)xBibunQtpx5SakW8yWeTcy0YR)xBiBguyxavJ6JvL7r1ybV(Zf2JQTdpkMEtkdYGc72UyQShzPGvt5caJeWab2WOn4b3qPNRCwWR)CH9OAbunQpwvUhvJf86pxypQ2o8Oy6nPmGRgJv5EuT1eyN9w)KuL7btY6QHAhFSQCpQgl41FUWEuTD4rX0BszaV(Zf2JQzFHjBLZwyCiPsY(ct2rpHHSCf7rdtQKShzPZvol41FUWEuTaQg1PLNHGvt5caJeqbMhdMOvaJwE9)AdbhCZvolGcmpgmrRagT86)1gsSgGdU5kNfqbMhdMOvaJwE9)AdzZGc7I1qAxnu7cWQjBLTd1icKMxLbQg1I5kNTqbMhdMOvaJwE9)AdjaKcXykPLNHGvt5caJeWab2WOn4b3qWbhenx5SagiWggTbp4gsSgsjT8k3JQfFYPciI2MnbShpTY9OAXNCQaIOTzta7XTa6RrJFxQCeSm4Gt5EuTaZla)rqYs8LhnS0k3JQfyEb4pcswIVCYcOVgn(D5iyzWbNY9OAroa0ungbjlXxE0WsRCpQwKdanvJrqYs8Ltwa91OXVlhbldo4uUhvlgyeutJIDbjlXxE0WsRCpQwmWiOMgf7cswIVCYcOVgn(D5iyzWbNY9OAr2OFc7GqcsqYs8LhnS0k3JQfzJ(jSdcjibjlXxozb0xJg)UCeSSuowtTd9Y8hcCiEvgOAuJpK)O(HWp1YaDOjDOfMGo0OWFouQQ)CH9O6dHFQLb6qvBy8qt6qlmbDOrH)CiTpKY9LAouQQ)CH9O6dXvSFiTHoux(Hgf(ZH0dLS6db)pAySHpe8meghnSdnakU4yv5EunwWR)CH9OA7WJIP3KYaUAmwL7r1wtGD2B9ts51FUWEuTLxLbQg1y2JS05kNf86pxypQwyuSBjzhca9UuL7r1cE9NlShvlmk2TlmbDSQCpQgl41FUWEuTD4rX0Bszq2OFc7GqcI9ilv(5kNfpLBXoGujeas5EAL7btYsn9dcZcPmvqOtdj41FUWEuTnB0pHDqibLcCWj)CLZICaiSxGVaqk3tRCpyswQPFqywiLPccDAibV(Zf2JQTzJ(jSdcjOXhSAkxayKihac7f4NYXQY9OASGx)5c7r12HhftVjLbdmcQPrXo7rw6CLZc8QTsenmSDAimoAywaPqmkwdPNRCwGxTvIOHHTtdHXrdZcifIrbG(A0ywWvSB94thRk3JQXcE9NlShvBhEum9MugmWiOMgf7ShzPZvolYbGWEb(caPC)yv5EunwWR)CH9OA7WJIP3KYGbgb10OyN9ilDUYzXaJGIBu8xaiL7PNRCwmWiO4gf)fa6RrJzbxXU1JpLw(5kNf86pxypQwaOVgnMfCf7wp(eCWnx5SGx)5c7r1cOAuNsAL7btYsn9dc)otfe60qcE9NlShvBZg9tyhesqhRk3JQXcE9NlShvBhEum9MugmWiOMgf7ShzPZvolEk3IDaPsiaKY90Zvol41FUWEuTynCSQCpQgl41FUWEuTD4rX0BszWaJGAAuSZEKLoaiMwyCiHKcmVa8N0ZvolEi1JgMDniaKY90k3dMKLA6he(DMki0PHe86pxypQ2Mn6NWoiKGowtTdb)ehnSdL8ezpAyhsMTgrGdbTard7qPQ(Zf2JQpKxhcqyVa0Hy5bGoe8mk2pK2qhsM9POoK9qSCJ(PdXFuamcFiU2hAshAsnLdEOg2p0C5hAHxQXW4HQ2W4HQ(qWFLmxCSQCpQgl41FUWEuTD4rX0Bsza(jYE0WSd1icWEKLox5SGx)5c7r1I1qAgQCpQwKdazNgf7c(JcGr40k3dMKLA6heMfszQGqNgsWR)CH9OAl(jYE0WSd1icKw5EuTy4POoK1Mn6NWI8YySaI)OayK1JpXI8YySacAX9OA2J2jayn42ilv5EuTihaYonk2f8hfaJWsvUhvlYbGStJIDXxL1YFuamcFSQCpQgl41FUWEuTD4rX0BszWWtrDiRnB0pHzpYsNRCwWR)CH9OAXAiT8YRCpQwKdazNgf7c(JcGr43LmTRgQDXaJGIBu8pTY9GjzPM(bHLkzkWbhdD1qTlgyeuCJI)WbNY9GjzPM(bHzHKPKEUYzXdPE0WSRbbGuU)2t5wSdivclEGmgSnAB2eWE83LXXQY9OASGx)5c7r12HhftVjLbzJ(jSdcji2JS05kNf86pxypQwavJ608Qmq1OwWR)CH9OAbG(A0435k2TE8P0k3dMKLA6heMfszQGqNgsWR)CH9OAB2OFc7Gqc6yv5EunwWR)CH9OA7WJIP3KYGCaOPAmShzPZvol41FUWEuTaQg1P5vzGQrTGx)5c7r1ca91OXVZvSB94tPziVAOv4ISr)Kv5Ca5r1hRk3JQXcE9NlShvBhEum9MugG5fG)WEKLox5SGx)5c7r1ca91OXSGRy36XNspx5SGx)5c7r1I1aCWnx5SGx)5c7r1cOAuNMxLbQg1cE9NlShvla0xJg)oxXU1JpDSQCpQgl41FUWEuTD4rX0BszGjygnm7S(t2JS05kNf86pxypQwaOVgn(DyCiXxLnTY9GjzPM(bHzHKhRk3JQXcE9NlShvBhEum9MugabuyvJTtaP(d7rw6CLZcE9NlShvla0xJg)omoK4RYMEUYzbV(Zf2JQfRHJvL7r1ybV(Zf2JQTdpkMEtkdW8cWFypYsDfaJCXdPg)rmW93LktYjTRgQDbMuq0WSET4phRhRk3JQXcqnyhEumjnB0pHDqibXEKLQCpyswQPFqywiLPccDAiXt5wSdivcB2OFc7GqckT8ZvolEk3IDaPsiaKYD4GBUYzroae2lWxaiL7PCSQCpQgla1GD4rX0BszWaJGAAuSZEKLox5SaVARerddBNgcJJgMfqkeJI1q65kNf4vBLiAyy70qyC0WSasHyuaOVgnMfCf7wp(0XQY9OASaud2HhftVjLbdmcQPrXo7rw6CLZICaiSxGVaqk3pwvUhvJfGAWo8Oy6nPmyGrqnnk2zpYsNRCw8uUf7asLqaiL7hRP2HGFIPdvnDiwEaOdbpJI9drkWW4HI(qP(Lm7HI8HySwhcQA28d9OmPdrH)qGdL6rQhnSdb)C4qf4qPELFOehqQehIrYpK2qhIc)HaW3HKxt5qpkt6q)cqhYF0(q(O6qQbqkeJSFi5NPCOhLjDi4pdjl2bkE8uzdFiw(cW4HaKcX4H86qlmX(HkWHKNNYHsifenSd9AT4phkWhs5EWKeh6LVA28dbvhYFc8Hg9eg6qpka6qCf7rd7qSCJ(jhesq4dvGdn6H6dLS6db)pAySHpe8meghnSdf4dbifIrXXQY9OASaud2HhftVjLb5aq2PrXo7lmzRC2cJdjvs2xyYo6jmKLRypAysLK9ilLHmvqOtdjYbGStJID7qvMOHLEUYzbE1wjIgg2oneghnmlGuigfq1OoTY9GjzPM(bHFNPccDAiXJcGSCf72Sr)e2bHeuAgMdaHDf4eqOCpysPLNHZvolEi1JgMDniaKY90mCUYzXt5wSdivcbGuUNMHdaIPTYzlmoKihaYonk2tlVY9OAroaKDAuSl4pkagHzHuzahCY7QHAxOgswSdu84PIT5fGX08Qmq1OwabuyvJTtaP(JaqkeJPahCY7QHAxGjfenmRxl(tAxbWix8qQXFedC)DPYKCsjLuowtTdb)ethILha6qWZOy)qu4pe4qqlq0WoKEiwEaOPAmmqMLrqnnk2pexX(Hg9q9Hs9i1Jg2HGFoCOaFiL7bt6qf4qqlq0WoejlXxoDOrH)COesbrd7qVwl(J4yv5EunwaQb7WJIP3KYGCai70OyN9fMSvoBHXHKkj7lmzh9egYYvShnmPsYEKLYqMki0PHe5aq2PrXUDOkt0WsZWCaiSRaNacL7btkT8YlVY9OAroa0ungbjlXxE0WslVY9OAroa0ungbjlXxozb0xJg)UCeSeCWXqWQPCbGrICaiSxGFkWbNY9OAXaJGAAuSlizj(YJgwA5vUhvlgyeutJIDbjlXxozb0xJg)UCeSeCWXqWQPCbGrICaiSxGFkPKEUYzXdPE0WSRbbGuUNcCWjVRgQDbMuq0WSET4pPDfaJCXdPg)rmW93LktYjT8ZvolEi1JgMDniaKY90mu5EuTaZla)rqYs8Lhnm4GJHZvolEk3IDaPsiaKY90mCUYzXdPE0WSRbbGuUNw5EuTaZla)rqYs8LhnS0m8PCl2bKkHfpqgd2gTnBcypEkPKYXQY9OASaud2HhftVjLbC1ySk3JQTMa7S36NKQCpyswxnu74JvL7r1ybOgSdpkMEtkdgyeutJID2JS05kNfdmckUrXFbGuUNMRy36XNEFUYzXaJGIBu8xaOVgnonxXU1Jp9(CLZcWQjBLTd1icia0xJgFSQCpQgla1GD4rX0BszWaJGAAuSZEKLoaiMwyCiHKcmVa8N0ZvolEi1JgMDniaKY90UAO2fysbrdZ61I)K2vamYfpKA8hXa3FxQmjN0k3dMKLA6he(DMki0PHepLBXoGujSzJ(jSdcjOJvL7r1ybOgSdpkMEtkdgEkQdzTzJ(jm7rwkdzQGqNgsm8uuhYAhQYenS0ZvolEi1JgMDniaKY90mCUYzXt5wSdivcbGuUNwEL7btYcvUiG1HtVld4Gt5EWKSut)GWSqktfe60qIhfaz5k2TzJ(jSdcji4Gt5EWKSut)GWSqktfe60qINYTyhqQe2Sr)e2bHeukhRk3JQXcqnyhEum9MugG5fG)WEKL6kag5Ihsn(JyG7VlvMKtAxnu7cmPGOHz9AXFowvUhvJfGAWo8Oy6nPmacOWQgBNas9h2JSuL7btYsn9dcZczCSQCpQgla1GD4rX0BszGc4Atws2btHJQzpYsvUhmjl10pimlKYubHonKqbCTjlj7GPWr1P)ARIbUZcPmvqOtdjuaxBYsYoykCuT9RTESQCpQgla1GD4rX0Bszq2OFc7GqcI9ilv5EWKSut)GWSqktfe60qIhfaz5k2TzJ(jSdcjOJvL7r1ybOgSdpkMEtkdYbGMQXCSESQCpQglWU2qkaYckx9OAPzJ(jSdcji2JSuL7btYsn9dcZcPmvqOtdjEk3IDaPsyZg9tyhesqPLFUYzXt5wSdivcbGuUdhCZvolYbGWEb(caPCpLJvL7r1yb21gsbqwq5Qhv)MugmWiOMgf7ShzPZvolYbGWEb(caPC)yv5EunwGDTHuaKfuU6r1VjLbdmcQPrXo7rw6CLZINYTyhqQecaPCp9CLZINYTyhqQeca91OXVRCpQwKdanvJrqYs8Ltwp(0XQY9OASa7AdPailOC1JQFtkdgyeutJID2JS05kNfpLBXoGujeas5EA5haetlmoKqsroa0ung4Glhac7kWjGq5EWKGdoL7r1Ibgb10OyxeTnBcypEkhRP2HEfW4H86qWi)qjW)H3HgafhFOOXbeDOu)sM9qdpkMWhQahkv1FUWEu9HgEumHp0OhQp0qHXX0qIJvL7r1yb21gsbqwq5Qhv)MugmWiOMgf7ShzPZvolWR2kr0WW2PHW4OHzbKcXOynKwEEvgOAulaRMSv2ouJiGaqFnA8Bk3JQfGvt2kBhQreqqYs8Ltwp(0BCf7wp(elMRCwGxTvIOHHTtdHXrdZcifIrbG(A0y4GJHUAO2fGvt2kBhQreiL0mvqOtdj84twVS86pxypQ(nUIDRhFIfZvolWR2kr0WW2PHW4OHzbKcXOaqFnA8XQY9OASa7AdPailOC1JQFtkdgyeutJID2JS05kNfpLBXoGujeas5EAxbWix8qQXFedC)DPYKCs7QHAxGjfenmRxl(ZXQY9OASa7AdPailOC1JQFtkdgyeutJID2JS05kNfdmckUrXFbGuUNMRy36XNEFUYzXaJGIBu8xaOVgn(yn1o0l)cenSd5p0HWU2qka6qGYvpQM9dvTHXdTW0Hy5bGoe8mk2XhA0d1hYFigpKcOd1LFOjfnSdnuLHGouUahk1VKzpubouQQ)CH9OAXHGFIPdXYdaDi4zuSFik8hcCiOfiAyhspelpa0unggiZYiOMgf7hIRy)qJEO(qPEK6rd7qWphouGpKY9GjDOcCiOfiAyhIKL4lNo0OWFoucPGOHDOxRf)rCSQCpQglWU2qkaYckx9O63KYGCai70OyN9fMSvoBHXHKkj7lmzh9egYYvShnmPsYEKLYWCaiSRaNacL7btkndzQGqNgsKdazNgf72HQmrdlT8YlVY9OAroa0ungbjlXxE0WslVY9OAroa0ungbjlXxozb0xJg)UCeSeCWXqWQPCbGrICaiSxGFkWbNY9OAXaJGAAuSlizj(YJgwA5vUhvlgyeutJIDbjlXxozb0xJg)UCeSeCWXqWQPCbGrICaiSxGFkPKEUYzXdPE0WSRbbGuUNcCWjVRgQDbMuq0WSET4pPDfaJCXdPg)rmW93LktYjT8ZvolEi1JgMDniaKY90mu5EuTaZla)rqYs8Lhnm4GJHZvolEk3IDaPsiaKY90mCUYzXdPE0WSRbbGuUNw5EuTaZla)rqYs8LhnS0m8PCl2bKkHfpqgd2gTnBcypEkPKYXQY9OASa7AdPailOC1JQFtkdgyeutJID2JS0baX0cJdjKuG5fG)KEUYzXdPE0WSRbbGuUN2vd1UatkiAywVw8N0UcGrU4HuJ)ig4(7sLj5Kw5EWKSut)GWVZubHonK4PCl2bKkHnB0pHDqibDSQCpQglWU2qkaYckx9O63KYGHNI6qwB2OFcZEKLYqMki0PHedpf1HS2HQmrdlT8m0vd1UidQV1FiRIFimCWPCpyswQPFqywizkPLx5EWKSqLlcyD407Yao4uUhmjl10pimlKYubHonK4rbqwUIDB2OFc7Gqcco4uUhmjl10pimlKYubHonK4PCl2bKkHnB0pHDqibLYXQY9OASa7AdPailOC1JQFtkd4QXyvUhvBnb2zV1pjv5EWKSUAO2XhRk3JQXcSRnKcGSGYvpQ(nPmacOWQgBNas9h2JSuL7btYsn9dcZcjpwvUhvJfyxBifazbLREu9BszaMxa(d7rwQRayKlEi14pIbU)UuzsoPD1qTlWKcIgM1Rf)5yn1oKmt4phI6Ab75qUcGroM9df(Hc8H0dbtJ(qEDiUI9dXYn6NWoiKGoKIpuomgcCOOXoPqhQYhILhaAQgJ4yv5EunwGDTHuaKfuU6r1VjLbkGRnzjzhmfoQM9ilv5EWKSut)GWSqktfe60qcfW1MSKSdMchvN(RTkg4olKYubHonKqbCTjlj7GPWr12V26XQY9OASa7AdPailOC1JQFtkdYg9tyhesqShzPk3dMKLA6heMfszQGqNgs8OailxXUnB0pHDqibDSQCpQglWU2qkaYckx9O63KYGCaOPAm7e8aX3JXYKPTV99g]] )

end
