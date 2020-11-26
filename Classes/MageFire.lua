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


    spec:RegisterPack( "Fire", 20201126.1, [[deLWidqiqspskixcfvLSjr0NiLmkPOoLuKvjfuVsfPzrkClqISls(LkQggPihteAzsbEgiHPjfkUgPOABGe13qrvmoPqLZHcIwhkQmpuG7HsTpuu(hkQkLdQIOAHQO8qveMikiKlkfQAJOG0hrbbJukuYjrrvALOiVefvfZefu3ufrPDkLYprrv1qjffTuvefpLunvPuDvPqP2kkQkvFLuuySsHSxP6VumyihMyXI6XOAYG6YiBwjFgeJwfoTWQrbH61IGztPBRs7wXVLmCr64QiYYbEoutNQRRuBhL8DPKXtk15rHwpPO08bP2VQUNyV9UoS4uVTgOPgOPetSbqzLMyEAqJlrgYUUZyk11tfEcceQRpYL66m0aqD9uHrBjW92764Ad4ux)W9umZD(5qc)yNv86EooUBR4rnCGS8ZXXLFExpVdRZ8o9CxhwCQ3wd0ud0uIj2aOCxx2(rb666X9eD9JagMMEURdtyExVHEedna0Jozfi0Zud9Od3tXm35Ndj8JDwXR7544UTIh1WbYYphhx(5ptn0JARyr3mbEudGYA8OgOPgOPNPNPg6rN4qgieM5EMAOhbLEuJnME0kGC4gaDLyWpci(bbEKFiZJCbaHCLhxY4LboOhTkWJSc2HsyIxd8JKCydNXhTXcecREMAOhbLEuJDkS40JSfKG)iaXCpIH38a(rmebi5Ivptn0JGspIHRctZJ4c2FeGoPDaOlno(rRc8Otu38g7rnpQ5qrknEeCnA5p6OSWpk8hTkWJKhTae(4rNSKtf4rCb7nPEMAOhbLEuJFKSLEe2bb3Fe)G4jedKhvZJKhTOwpAvGeWpkMh5h0Jo5AMm8J86racEZPh1Qajylbw11Tb2X9276Gk1KEiyQ3EVTe7T31PrYwcUFwxNdcNaH01fUhSidn0ni8Jyg7hXsaHKTK6OCd2bKKGzzLlHDqKa9OKpQ5hL3RL6OCd2bKKGcqc3Fe0q)O8ETuRaqyVaxfGeU)OM66c3JA66lRCjSdIeOU3BRb92760izlb3pRRZbHtGq6659APW7XKqmqWMSLW4yGyaKaZOAN(OKpkVxlfEpMeIbc2KTeghdedGeygva6kXGFeZEexWUXJl11fUh101tzeuzRG9U3Bdk6T31PrYwcUFwxNdcNaH01Z71sTcaH9cCvas4Exx4EutxpLrqLTc27EVTgtV9Uons2sW9Z66Cq4eiKUEEVwQJYnyhqsckajCVRlCpQPRNYiOYwb7DV3MM3BVRtJKTeC)SU(gtMwhHLmCb7XaP3wIDDoiCcesxhQpILacjBj1kaKjBfSBsRYgdKhL8r59APW7XKqmqWMSLW4yGyaKaZOcUAnpk5JeUhSidn0ni8JyWJyjGqYwsDiaydxWUzzLlHDqKa9OKpcQpAfac7cWjGs4EWIEuYh18JG6JY71sDqIhdeZovbiH7pk5JG6JY71sDuUb7assqbiH7pk5JG6JsbeltTwgiCy1kaKjBfS)OKpQ5hjCpQrTcazYwb7k(HaGq4hXm2pQbpcAOFuZpYflnUsSK2yhiynRGnRnGrfns2sWpk5J4vzHRwJcgiqQbBYas8dfGeygFutpcAOFuZpYflnUctcigigV28dfns2sWpk5JCbaHC1bjw)qLY9hXa2pck00JA6rn9OM66BmzQ1YaHd3BlXUUW9OMU(kaKjBfS39EBq5E7DDAKSLG7N113yY06iSKHlypgi92sSRZbHtGq66q9rSeqizlPwbGmzRGDtAv2yG8OKpcQpAfac7cWjGs4EWIEuYh18JA(rn)iH7rnQvaOSyTksBIV9yG8OKpQ5hjCpQrTcaLfRvrAt8TtgaDLyWpIbpstkn)rqd9JG6Ja7HwfacPwbGWEbUkAKSLGFutpcAOFKW9OgvkJGkBfSRiTj(2JbYJs(OMFKW9OgvkJGkBfSRiTj(2jdGUsm4hXGhPjLM)iOH(rq9rG9qRcaHuRaqyVaxfns2sWpQPh10Js(O8ETuhK4XaXStvas4(JA6rqd9JA(rUyPXvysaXaX41MFOOrYwc(rjFKlaiKRoiX6hQuU)igW(rqHMEuYh18JY71sDqIhdeZovbiH7pk5JG6JeUh1OW8cWpuK2eF7Xa5rqd9JG6JY71sDuUb7assqbiH7pk5JG6JY71sDqIhdeZovbiH7pk5JeUh1OW8cWpuK2eF7Xa5rjFeuF0r5gSdijbdoLSwSjgZYgqo8h10JA6rn113yYuRLbchU3wIDDH7rnD9vait2kyV792yE6T31PrYwcUFwxx4EutxNlwRr4EuJXgyVRBdSBg5sDDH7blY4ILgh39EBnUE7DDAKSLG7N115GWjqiD98ETuPmckUvWxfGeU)OKpIly34XLEedEuEVwQugbf3k4Rcqxjg8Js(iUGDJhx6rm4r59APa7Hm1YKwTiGcqxjgCxx4EutxpLrqLTc27EVngYE7DDAKSLG7N115GWjqiD9uaXYaHdRsuH5fGF8OKpkVxl1bjEmqm7ufGeU)OKpYflnUctcigigV28dfns2sWpk5JCbaHC1bjw)qLY9hXa2pck00Js(iH7blYqdDdc)ig8iwciKSLuhLBWoGKemlRCjSdIeOUUW9OMUEkJGkBfS39EBjQPE7DDAKSLG7N115GWjqiDDO(iwciKSLuPhfnH2M0QSXa5rjFuEVwQds8yGy2PkajC)rjFeuFuEVwQJYnyhqsckajC)rjFuZps4EWImWLRcit40JyWJAWJGg6hjCpyrgAOBq4hXm2pILacjBj1HaGnCb7MLvUe2brc0JGg6hjCpyrgAOBq4hXm2pILacjBj1r5gSdijbZYkxc7Gib6rn11fUh101tpkAcTnlRCjC37TLyI92760izlb3pRRZbHtGq66UaGqU6GeRFOs5(Jya7hbfA6rjFKlwACfMeqmqmET5hkAKSLG76c3JA66yEb4hDV3wInO3ExNgjBj4(zDDoiCcesxx4EWIm0q3GWpIzpQbDDH7rnDDyGaPgSjdiXp6EVTeHIE7DDAKSLG7N115GWjqiDDH7blYqdDdc)iMX(rSeqizlPeaxgYqANAlCuZJs(ORmIkL7pIzSFelbes2skbWLHmK2P2ch1yUYiDDH7rnDDbWLHmK2P2ch109EBj2y6T31PrYwcUFwxNdcNaH01fUhSidn0ni8Jyg7hXsaHKTK6qaWgUGDZYkxc7GibQRlCpQPRVSYLWoisG6EVTe18E7DDH7rnD9vaOSyTDDAKSLG7N19U31HPLSTEV9EBj2BVRtJKTeC)SUoheobcPRd1hb2dTkaesbhyEKAJramA419kdSIgjBj4UUW9OMUoV2JtaCkzTDV3wd6T31PrYwcUFwxVs76yY76c3JA66Seqizl11zj2n11DXsJRwbGWUaCcOOrYwc(rn8JwbGWUaCcOa0vIb)OtFuZpIxLfUAnkEDZBSh1Oa0vIb)Og(rn)OeFeu6rSeqizlPsigyBmqmacEZ9OMh1WpYflnUkHyGTXarrJKTe8JA6rn9Og(rq9r8QSWvRrXRBEJ9OgfGeygFud)O8ETu86M3ypQrbxTMUolbyg5sDDpUKXldVU5n2JA6EVnOO3ExNgjBj4(zD9kTRFfT76c3JA66Seqizl11zj2n11zjGqYwsr3ugbKynfaEKHtgyYkm(iO0JA(r8QSWvRrr3ugbKynfaEKHtk4nq8OMhbLEeVklC1Au0nLrajwtbGhz4Kcqxjg8JA6rn8JG6J4vzHRwJIUPmciXAka8idNuasGzSRZbHtGq660jTJ0ucwr3ugbKynfaEKHtDDwcWmYL66ECjJxgEDZBSh109EBnME7DDAKSLG7N11R0U(v0URlCpQPRZsaHKTuxNLy3uxNxLfUAnkiwboeVaytwGHqkaDLyWDDoiCcesxNoPDKMsWkiwboeVaytwGHqDDwcWmYL66ECjJxgEDZBSh109EBAEV9Uons2sW9Z66vAx)kA31fUh101zjGqYwQRZsSBQRN3RLcShYultA1IakaDLyWDDoiCcesx3flnUcShYultA1IakAKSLGFuYhL3RLIx38g7rnk4Q101zjaZixQR7XLmEz41nVXEut37TbL7T31PrYwcUFwxVs76xr7UUW9OMUolbes2sDDwIDtDDEvw4Q1Oa7Hm1YKwTiGcqxjg8Jo9r59APa7Hm1YKwTiGcEdepQPRZbHtGq66UyPXvG9qMAzsRweqrJKTe8Js(O8ETu86M3ypQrbxTMhL8r8QSWvRrb2dzQLjTArafGUsm4hD6J08hXGhXsaHKTKYJlz8YWRBEJ9OMUolbyg5sDDpUKXldVU5n2JA6EVnMNE7DDAKSLG7N115GWjqiD98ETu86M3ypQrbxTMhL8rSeqizlP84sgVm86M3ypQ5rm7rRT1Aae8M7rnpk5JA(r8QSWvRrb2dzQLjTArafGUsm4hXShT2wRbqWBUh18iOH(rq9rUyPXvG9qMAzsRweqrJKTe8JAQRlCpQPRJpILhdetA1IaDV3wJR3ExNgjBj4(zDDoiCcesxV5hL3RLIx38g7rnk4Q18OKpkVxlfypKPwM0QfbuWvR5rjFuZpILacjBjLhxY4LHx38g7rnpIbpI0M4BNmECPhbn0pILacjBjLhxY4LHx38g7rnpIzpIxLfUAnkGahY4gCQasqbVbIh18OMEutpcAOFuZpkVxlfypKPwM0Qfbu70hL8rSeqizlP84sgVm86M3ypQ5rm7rqHMEutDDH7rnDDGahY4gCQasO792yi7T31PrYwcUFwxNdcNaH01Z71sXRBEJ9OgfC1AEuYhL3RLcShYultA1Iak4Q18OKpILacjBjLhxY4LHx38g7rnpIbpI0M4BNmECPUUW9OMUomj(rUad19EBjQPE7DDAKSLG7N115GWjqiD98ETu86M3ypQrbxTMhL8rWuEVwkGahY4gCQasWWABhci5WgoJk4Q101fUh101VbauatCfiu37TLyI92760izlb3pRRlCpQPRdXkWH4faBYcmeQRZbHtGq66SeqizlP84sgVm86M3ypQ5rm7rc3JAm8QSWvR5rqPhP5DDATiUBg5sDDiwboeVaytwGHqDV3wInO3ExNgjBj4(zDDoiCcesxNLacjBjLhxY4LHx38g7rnpIbSFelbes2sk6MYiGeRPaWJmCYatwHXU(ixQRt3ugbKynfaEKHtDDH7rnDD6MYiGeRPaWJmCQ792sek6T31PrYwcUFwxNdcNaH01zjGqYws5XLmEz41nVXEuZJyg7hXsaHKTKQgZgtg(2R1QRpYL664ABnbKjCc01fUh101X12Acit4eO792sSX0BVRtJKTeC)SUoheobcPRZsaHKTKYJlz8YWRBEJ9OMhXm2pILacjBjvnMnMm8TxRvxFKl11Hyzm9WulJGXXnSIh101fUh101Hyzm9WulJGXXnSIh109EBjQ592760izlb3pRRZbHtGq66SeqizlP84sgVm86M3ypQ5rmG9J08U(ixQRFfUKbKbFqKBUBCW76c3JA66xHlzazWhe5M7gh8U3BlrOCV9Uons2sW9Z66Cq4eiKUolbes2skpUKXldVU5n2JAEeZy)iwciKSLu1y2yYW3ETwD9rUuxhgqc8kaKHfHXKTRlCpQPRddibEfaYWIWyY29EBjY80BVRtJKTeC)SUoheobcPRZsaHKTKYJlz8YWRBEJ9OMhXa2psZF0Ppkrn)rn8JyjGqYwsTQXnW1oBjtnMnMEuYhXsaHKTKYJlz8YWRBEJ9OMhXShPPU(ixQRlAw8HaeSzvJBQLjTArGUUW9OMUUOzXhcqWMvnUPwM0Qfb6EVTeBC92760izlb3pRRZbHtGq66n)iwciKSLuECjJxgEDZBSh18ig8Oe10JGg6hTcihUbqxjg8JyWJyjGqYws5XLmEz41nVXEuZJAQRlCpQPRdzla4qgtTmIMLaLF09EBjYq2BVRlCpQPRZRHtJdeNGnlRCPUons2sW9Z6EVTgOPE7DDH7rnDDajPXaXSSYLWDDAKSLG7N19EBniXE7DDH7rnD9vX3yc2iAwceozYKC760izlb3pR792Aqd6T31fUh101t3GyXymqmzRG9Uons2sW9Z6EVTgaf9276c3JA66Gin1sMym4uHtDDAKSLG7N19EBnOX0BVRlCpQPR7hKzp5ApWMvb4uxNgjBj4(zDV3wd08E7DDAKSLG7N115GWjqiDDWEOvbGqk4aZJuBmcGrdVUxzGv0izlb)OKpIxLfUAnQ8ETmWbMhP2yeaJgEDVYaRaKaZ4Js(O8ETuWbMhP2yeaJgEDVYaBeaxgsbxTMhL8rSeqizlP84sgVm86M3ypQ5rm7rqHMEuYhb1hL3RLcoW8i1gJay0WR7vgy1oTRlCpQPRZR94eaNswB37T1aOCV9Uons2sW9Z66Cq4eiKUoyp0QaqifCG5rQngbWOHx3RmWkAKSLGFuYhXRYcxTgvEVwg4aZJuBmcGrdVUxzGvasGz8rjFuEVwk4aZJuBmcGrdVUxzGncGldPGRwZJs(iwciKSLuECjJxgEDZBSh18iM9iOqtpk5JG6JY71sbhyEKAJramA419kdSAN21fUh101faxgYqANAlCut37T1aMNE7DDAKSLG7N115GWjqiDDWEOvbGqk4aZJuBmcGrdVUxzGv0izlb)OKpIxLfUAnQ8ETmWbMhP2yeaJgEDVYaRaKaZ4Js(O8ETuWbMhP2yeaJgEDVYaBwGc7k4Q18OKpILacjBjLhxY4LHx38g7rnpIzpck00Js(iO(O8ETuWbMhP2yeaJgEDVYaR2PDDH7rnD9fOWEUSE37T1GgxV9Uons2sW9Z66Cq4eiKUouFelbes2sk4alzlz41nVXEuZJs(iwciKSLuECjJxgEDZBSh18igW(rAQRlCpQPRZfR1iCpQXydS31Tb2nJCPUoVU5n2JAmPhcM6EVTgWq2BVRtJKTeC)SUEL21XK31fUh101zjGqYwQRZsSBQRd1hXsaHKTKcoWs2sgEDZBSh18OKpILacjBjLhxY4LHx38g7rnpIbps4EuJAfaYKTc2vRT1Aae)qaqiJhx6rqPhjCpQrHpILhdetA1IaQ12AnacEZ9OMh1WpQ5hXRYcxTgf(iwEmqmPvlcOa0vIb)ig8iwciKSLuECjJxgEDZBSh18OMEuYhXsaHKTKYJlz8YWRBEJ9OMhXGhTcihUbqxjg8JGg6h5ILgxb2dzQLjTArafns2sWpk5JY71sb2dzQLjTArafC1AEuYhXRYcxTgfypKPwM0Qfbua6kXGFedEKW9Og1kaKjBfSRwBR1ai(HaGqgpU0JGsps4EuJcFelpgiM0QfbuRT1Aae8M7rnpQHFuZpIxLfUAnk8rS8yGysRweqbORed(rm4r8QSWvRrb2dzQLjTArafGUsm4h10Js(iEvw4Q1Oa7Hm1YKwTiGcqxjg8JyWJwbKd3aORedURZsaMrUuxFfaYKTc2nPvzJbs37TbfAQ3ExNgjBj4(zD9kTRJjVRlCpQPRZsaHKTuxNLy3uxhQpILacjBjfCGLSLm86M3ypQ5rjFelbes2skpUKXldVU5n2JAEedEKW9Ogv6rrtOTzzLlHvRT1Aae)qaqiJhx6rqPhjCpQrHpILhdetA1IaQ12AnacEZ9OMh1WpQ5hXRYcxTgf(iwEmqmPvlcOa0vIb)ig8iwciKSLuECjJxgEDZBSh18OMEuYhXsaHKTKYJlz8YWRBEJ9OMhXGhTcihUbqxjg8JGg6hb2dTkaesH3JjHyGGnzlHXXarrJKTeCxNLamJCPUE6rrtOTjTkBmq6EVnOiXE7DDAKSLG7N115GWjqiD98ETuG9qMAzsRweqbxTMhL8rq9r59APwbGWEbUkajC)rjFuZpILacjBjLhxY4LHx38g7rnpIzSFuEVwkWEitTmPvlcOG3aXJAEuYhXsaHKTKYJlz8YWRBEJ9OMhXShjCpQrTcazYwb7Q12AnaIFiaiKXJl9iOH(rSeqizlP84sgVm86M3ypQ5rm7rRaYHBa0vIb)iOH(rSeqizlPGdSKTKHx38g7rnpQPUUW9OMUoypKPwM0Qfb6EVnOOb92760izlb3pRRZbHtGq6659APa7Hm1YKwTiGAN(OKpQ5hXsaHKTKYJlz8YWRBEJ9OMhXShPPh1uxx4EutxNlwRr4EuJXgyVRBdSBg5sDDqLAspem19EBqbu0BVRtJKTeC)SUEL21XK31fUh101zjGqYwQRZsSBQRZsaHKTKYJlz8YWRBEJ9OMhXGhjCpQrLEu0eABww5sy1ABTgaXpeaeY4XLEuYhXsaHKTKYJlz8YWRBEJ9OMhXGhTcihUbqxjg8JGg6hb2dTkaesH3JjHyGGnzlHXXarrJKTeCxNLamJCPUE6rrtOTjTkBmq6EVnOOX0BVRtJKTeC)SU(gtMwhHLmCb7XaP3wIDDoiCcesxhQpILacjBj1kaKjBfSBsRYgdKhL8rn)iwciKSLuECjJxgEDZBSh18iM9in9iOH(rc3dwKHg6ge(rmJ9JyjGqYwsDiaydxWUzzLlHDqKa9OKpcQpAfac7cWjGs4EWIEuYhb1hL3RL6OCd2bKKGcqc3FuYh18JY71sDqIhdeZovbiH7pk5JeUh1Oww5syhejqksBIVDYaORed(rm4rAsP5pcAOFe)qaqiSzbeUh1i2hXm2pQbpQPh1uxFJjtTwgiC4EBj21fUh101xbGmzRG9U3Bdk08E7DDAKSLG7N113yY06iSKHlypgi92sSRZbHtGq66Raqyxaobuc3dw0Js(i(HaGq4hXm2pkXhL8rq9rSeqizlPwbGmzRGDtAv2yG8OKpQ5hb1hjCpQrTcaLfRvrAt8ThdKhL8rq9rc3JAuPmcQSvWUkgZYgqo8hL8r59APoiXJbIzNQaKW9hbn0ps4EuJAfaklwRI0M4Bpgipk5JG6JY71sDuUb7assqbiH7pcAOFKW9OgvkJGkBfSRIXSSbKd)rjFuEVwQds8yGy2PkajC)rjFeuFuEVwQJYnyhqsckajC)rn113yYuRLbchU3wIDDH7rnD9vait2kyV792GcOCV9Uons2sW9Z66BmzADewYWfShdKEBj21fUh101xbGmzRG9UoheobcPRlCpQrHpILhdetA1IaksBIV9yG8OKpATTwdG4hcacz84spIbps4EuJcFelpgiM0QfbuEWtWai4n3JAEuYhL3RL6OCd2bKKGcUAnDV3guW80BVRtJKTeC)SUoheobcPR38JyjGqYws5XLmEz41nVXEuZJy2J00JGg6hXsaHKTKcoWs2sgEDZBSh18OMEuYhL3RLcShYultA1Iak4Q101fUh1015I1AeUh1ySb2762a7MrUuxh7YalaydOCXJA6EVnOOX1BVRlCpQPRJ5fGF01PrYwcUFw37Expfq86MfV3EVTe7T31fUh101faxgYeJtwlX9Uons2sW9Z6EVTg0BVRtJKTeC)SUEL21XK31fUh101zjGqYwQRZsSBQR3Gh1WpYflnUAzLlzsfNFOOrYwc(rN(iO4rn8JG6JCXsJRww5sMuX5hkAKSLG76Cq4eiKUolbes2sQJYnyhqscMLvUe2brc0Jy)in11zjaZixQRFuUb7assWSSYLWoisG6EVnOO3ExNgjBj4(zD9kTRJjVRlCpQPRZsaHKTuxNLy3uxVbpQHFKlwAC1YkxYKko)qrJKTe8Jo9rqXJA4hb1h5ILgxTSYLmPIZpu0izlb315GWjqiDDwciKSLuhca2WfSBww5syhejqpI9J0uxNLamJCPU(HaGnCb7MLvUe2brcu37T1y6T31PrYwcUFwxVs76yY76c3JA66Seqizl11zj2n11HIh1WpYflnUAzLlzsfNFOOrYwc(rN(iO8JA4hb1h5ILgxTSYLmPIZpu0izlb315GWjqiDDwciKSLu86M3ypQXSSYLWoisGEe7hPPUolbyg5sDDEDZBSh1yww5syhejqDV3MM3BVRtJKTeC)SUEL21XK31fUh101zjGqYwQRZsSBQRZqYq(Og(rUyPXvlRCjtQ48dfns2sWp60h1Gh1WpcQpYflnUAzLlzsfNFOOrYwcURZbHtGq66SeqizlPeaxgYqANAlCuZJy)in11zjaZixQRlaUmKH0o1w4OMU3Bdk3BVRtJKTeC)SUEL21beM8UUW9OMUolbes2sDDwcWmYL66cGldziTtTfoQXCLr66W0s2wVR3y0u37TX80BVRtJKTeC)SUEL21beM8UUW9OMUolbes2sDDwcWmYL66WKvy0SSYLWoisG66W0s2wVRRPU3BRX1BVRtJKTeC)SUEL21beM8UUW9OMUolbes2sDDwcWmYL66jedSngigabV5EutxhMwY26DDnPAmDV3gdzV9Uons2sW9Z66vAxhtExx4EutxNLacjBPUolXUPUUM31zjaZixQRJtiBG3aXJA6EVTe1uV9Uons2sW9Z66vAxhtExx4EutxNLacjBPUolXUPUoDs7inLGvxHlzazWhe5M7gh8hbn0pIoPDKMsWQRmXIWEzQL5kWdHXpcAOFeDs7inLGvqScCiEbWMSadHEe0q)i6K2rAkbRGyf4q8cGnxcwS2OMhbn0pIoPDKMsWQaYeEuJ5kqiSzTX0JGg6hrN0ostjyLRzLHWMSasaNgdHFe0q)i6K2rAkbRen7gq(rHn4yGqWMu7(kqOhbn0pIoPDKMsWkz4bnUjHPCtTmTcmCDFe0q)i6K2rAkbRWhfpHC4eaBwYa5rqd9JOtAhPPeSAOnqSgmJJKIjdnhYWjWJGg6hrN0ostjyvwS0kaKjdKHF01zjaZixQRZRBEJ9OgtnMnM6EVTetS3ExNgjBj4(zD9kTRJjVRlCpQPRZsaHKTuxNLy3uxNoPDKMsWkrZIpeGGnRACtTmPvlc8OKpILacjBjfVU5n2JAm1y2yQRZsaMrUuxFvJBGRD2sMAmBm19EBj2GE7DDAKSLG7N11R0UoM8UUW9OMUolbes2sDDwIDtD9gOPh1WpILacjBjfVU5n2JAm1y2y6rN(in)rn8JOtAhPPeS6kCjdid(Gi3C34G31zjaZixQRxJzJjdF71A19EBjcf92760izlb3pRRxPDDm5DDH7rnDDwciKSL66Se7M66j2466Cq4eiKUolbes2sQvnUbU2zlzQXSX0Js(iO(ixS04QvaiSlaNakAKSLGFuYhXsaHKTKAvJBQLjTAratkG41nlUHFiZq2hX(rAQRZsaMrUuxFvJBQLjTAratkG41nlUHFiZq2U3BlXgtV9Uons2sW9Z66vAxhqyY76c3JA66Seqizl11zjaZixQRt3ugbKynfaEKHtgyYkm21HPLSTExpXgx37TLOM3BVRtJKTeC)SUEL21beM8UUW9OMUolbes2sDDwcWmYL6686M3ypQXGpILhdetA1IaDDyAjBR31Bq37TLiuU3ExNgjBj4(zD9rUuxx0S4dbiyZQg3ultA1IaDDH7rnDDrZIpeGGnRACtTmPvlc09EBjY80BVRlCpQPRFdaOaM4kqOUons2sW9Z6EVTeBC92760izlb3pRRZbHtGq66q9rPaILkLrqLTc276c3JA66PmcQSvWE37ExNx38g7rnM0dbt927TLyV9Uons2sW9Z66Cq4eiKUEEVwkEDZBSh1OGRwtxx4Eutx3gqoCSHH4nmKlnE37T1GE7DDAKSLG7N11R0UoM8UUW9OMUolbes2sDDwIDtD98ETu86M3ypQrbORed(rN(O8ETu86M3ypQrbVbIh18Og(rn)iEvw4Q1O41nVXEuJcqxjg8JyWJY71sXRBEJ9OgfGUsm4h1uxNLamJCPUoPTtdmbB41nVXEuJbqxjgC37Tbf92760izlb3pRRxPDDbgURlCpQPRZsaHKTuxNLy3uxNLacjBjfoHSbEdepQPRZbHtGq6659APW7XKqmqWMSLW4yGyaKaZOAN(iOH(rSeqizlPiTDAGjydVU5n2JAma6kXGFeZEuIkn)rn8JGWHvxr7h1WpQ5hL3RLcVhtcXabBYwcJJbI6kABWUWt4rqPhL3RLcVhtcXabBYwcJJbIc7cpHh1uxNLamJCPUoPTtdmbB41nVXEuJbqxjgC37T1y6T31PrYwcUFwxNdcNaH01Z71sXRBEJ9OgfC1A66c3JA66zbIPwghe8eWDV3MM3BVRtJKTeC)SUoheobcPRlCpyrgAOBq4hXShL4Js(O8ETu86M3ypQrbxTMUUW9OMUUnyfdetUU5U3Bdk3BVRtJKTeC)SUoheobcPRN3RLIx38g7rnk4Q18OKpkVxlfypKPwM0QfbuWvRPRlCpQPRFdaOaytTmEbU04DV3gZtV9Uons2sW9Z66Cq4eiKUEEVwkEDZBSh1O2Ppk5JeUh1OwbGmzRGDf)qaqi8Jy)in9OKps4EuJAfaYKTc2vaIFiaiKXJl9iM9iiCy1v0URpYL66hmMsa)aqcSPfiWElGKI76c3JA66hmMsa)aqcSPfiWElGKI7EVTgxV9UUW9OMUE2wfSPwg)Gm0qxg760izlb3pR792yi7T31fUh101V0TamAQLXU5bSbgqYf31PrYwcUFw37TLOM6T31fUh101BvalmlkgdGW1idN660izlb3pR792smXE7DDAKSLG7N113yY06iSKHlypgi92sSRlCpQPRVcazYwb7DDoiCcesxx4EuJ6gaqbWMAz8cCPXvK2eF7Xa5rjF0ABTgaXpeaeY4XLEeu6rc3JAu3aaka2ulJxGlnUI0M4BNma6kXGFedEuJ5rjFeuF0r5gSdijbdoLSwSjgZYgqo8hL8rq9r59APok3GDajjOaKW9hL8rn)O8ETu86M3ypQrTtFe0q)iO(iEnW7WvXSiWiwdxWCbMu0izlb)OM6EVTeBqV9Uons2sW9Z66BmzADewYWfShdKEBj215GWjqiDDO(irZsGWjv2kyNaMRGDcOOrYwc(rjFuZps4EWIm0q3GWpIbSFKW9GfzGlxfqMWPhbn0pcQpIxLfUAnQ0JIMqBZYkxcRaKaZ4JA6rjFeuFeVg4D4QyweyeRHlyUatkAKSLGFuYhXpeaec)iMX(rj(OKpkVxlfVU5n2JAu70hL8rq9r59APwbGWEbUkajC)rjFeuFuEVwQJYnyhqsckajC)rjF0r5gSdijbdoLSwSjgZYgqo8hD6JY71sDqIhdeZovbiH7pIbpQbD9nMm1AzGWH7TLyxx4EutxFfaYKTc27EVTeHIE7DDAKSLG7N113yY06iSKHlypgi92sSRZbHtGq66q9rIMLaHtQSvWobmxb7eqrJKTe8Js(OMFKW9GfzOHUbHFedy)iH7blYaxUkGmHtpcAOFeuFeVklC1AuPhfnH2MLvUewbibMXh10Js(iEnW7WvXSiWiwdxWCbMu0izlb)OKpIFiaie(rmJ9Js8rjFuZpQ5hjCpQrTcazYwb7k(HaGqyZciCpQrSp60h18JyjGqYwsrA70atWgEDZBSh1ya0vIb)iO0JY71sfZIaJynCbZfysbVbIh18OME05pIxLfUAnQvait2kyxbVbIh18iO0JyjGqYwsrA70atWgEDZBSh1ya0vIb)OZFuZpkVxlvmlcmI1WfmxGjf8giEuZJGspcchwDfTFutpQPhXm2pstpcAOFelbes2sksBNgyc2WRBEJ9OgdGUsm4hXa2pkVxlvmlcmI1WfmxGjf8giEuZJGg6hL3RLkMfbgXA4cMlWKcqxjg8JyWJGWHvxr7hbn0pIxLfUAnk8rS8yGysRweqbibMXhL8rc3dwKHg6ge(rmJ9JyjGqYwsXRBEJ9Ogd(iwEmqmPvlc8OKpIxSOrgxnbKd3Se6rn9OKpkVxlfVU5n2JAu70hL8rn)iO(O8ETuRaqyVaxfGeU)iOH(r59APIzrGrSgUG5cmPa0vIb)ig8inP08h10Js(iO(O8ETuhLBWoGKeuas4(Js(OJYnyhqscgCkzTytmMLnGC4p60hL3RL6GepgiMDQcqc3FedEud66BmzQ1YaHd3BlXUUW9OMU(kaKjBfS39EBj2y6T31PrYwcUFwxNdcNaH01b7HwfacPGdmpsTXiagn86ELbwrJKTe8Js(O8ETuWbMhP2yeaJgEDVYaRGRwZJs(O8ETuWbMhP2yeaJgEDVYaBeaxgsbxTMhL8r8QSWvRrL3RLboW8i1gJay0WR7vgyfGeyg76c3JA668ApobWPK129EBjQ592760izlb3pRRZbHtGq66G9qRcaHuWbMhP2yeaJgEDVYaROrYwc(rjFuEVwk4aZJuBmcGrdVUxzGvWvR5rjFuEVwk4aZJuBmcGrdVUxzGncGldPGRwZJs(iEvw4Q1OY71YahyEKAJramA419kdScqcmJDDH7rnDDbWLHmK2P2ch109EBjcL7T31PrYwcUFwxNdcNaH01b7HwfacPGdmpsTXiagn86ELbwrJKTe8Js(O8ETuWbMhP2yeaJgEDVYaRGRwZJs(O8ETuWbMhP2yeaJgEDVYaBwGc7k4Q101fUh101xGc75Y6DV3wImp92760izlb3pRRlCpQPRZfR1iCpQXydS31Tb2nJCPUUW9GfzCXsJJ7EVTeBC92760izlb3pRRVXKP1ryjdxWEmq6TLyxNdcNaH01Z71sXRBEJ9OgfC1AEuYh18Ja7HwfacPGdmpsTXiagn86ELbwrJKTe8Jy)O8ETuWbMhP2yeaJgEDVYaR2PpQPhL8rn)iH7rnQl5ubuXyw2aYH)OKps4EuJ6sovavmMLnGC4gaDLyWpIbSFKMuq5hbn0ps4EuJcZla)qrAt8ThdKhL8rc3JAuyEb4hksBIVDYaORed(rm4rAsbLFe0q)iH7rnQvaOSyTksBIV9yG8OKps4EuJAfaklwRI0M4BNma6kXGFedEKMuq5hbn0ps4EuJkLrqLTc2vK2eF7Xa5rjFKW9OgvkJGkBfSRiTj(2jdGUsm4hXGhPjfu(rn113yYuRLbchU3wIDDH7rnDDEDZBSh109EBjYq2BVRtJKTeC)SUoheobcPRN3RLIx38g7rnkRGDdPDAaOhXa2ps4EuJIx38g7rnkRGDZgtWDDH7rnDDUyTgH7rngBG9UUnWUzKl1151nVXEuJHxLfUAn4U3BRbAQ3ExNgjBj4(zDDoiCcesxV5hL3RL6OCd2bKKGcqc3Fe0q)O8ETuRaqyVaxfGeU)OMEuYhjCpyrgAOBq4hXm2pILacjBjfVU5n2JAmlRCjSdIeOUUW9OMU(Ykxc7GibQ792AqI92760izlb3pRRZbHtGq6659APW7XKqmqWMSLW4yGyaKaZOAN(OKpkVxlfEpMeIbc2KTeghdedGeygva6kXGFeZEexWUXJl11fUh101tzeuzRG9U3BRbnO3ExNgjBj4(zDDoiCcesxpVxl1kae2lWvbiH7DDH7rnD9ugbv2kyV792Aau0BVRtJKTeC)SUoheobcPRN3RLkLrqXTc(QaKW9hL8r59APszeuCRGVkaDLyWpIzpIly34XLEuYh18JY71sXRBEJ9OgfGUsm4hXShXfSB84spcAOFuEVwkEDZBSh1OGRwZJAQRlCpQPRNYiOYwb7DV3wdAm92760izlb3pRRZbHtGq6659APok3GDajjOaKW9hL8r59AP41nVXEuJAN21fUh101tzeuzRG9U3BRbAEV9Uons2sW9Z66Cq4eiKUEkGyzGWHvjQW8cWpEuYhL3RL6GepgiMDQcqc376c3JA66PmcQSvWE37T1aOCV9UEmoba7u3eRUUW9Og1kaKjBfSR4hcacHzlCpQrTcazYwb7QROTHFiaieURZbHtGq6659AP41nVXEuJAN(OKpcQps4EuJAfaYKTc2v8dbaHWpk5JeUhSidn0ni8Jyg7hXsaHKTKIx38g7rng8rS8yGysRwe4rjFKW9Ogv6rrtOTzzLlHvRT1Aae)qaqiJhx6rm7rRT1Aae8M7rnDDH7rnDD8rS8yGysRweORtJKTeC)SU3BRbmp92760izlb3pRRZbHtGq6659AP41nVXEuJAN(OKpQ5h18JeUh1OwbGmzRGDf)qaqi8JyWJs8rjFKlwACvkJGIBf8vrJKTe8Js(iH7blYqdDdc)i2pkXh10JGg6hb1h5ILgxLYiO4wbFv0izlb)iOH(rc3dwKHg6ge(rm7rj(OMEuYhL3RL6GepgiMDQcqc3F0Pp6OCd2bKKGbNswl2eJzzdih(JyWJAqxx4Eutxp9OOj02SSYLWDV3wdAC92760izlb3pRRZbHtGq6659AP41nVXEuJcUAnpk5J4vzHRwJIx38g7rnkaDLyWpIbpIly34XLEuYhb1hXRbEhUAzLlzeohqEuJIgjBj4hL8rn)iykVxl1naGcGn1Y4f4sJRGRwZJGg6hb1hXRbEhUkMfbgXA4cMlWKIgjBj4h1uxx4EutxFfaklwB37T1agYE7DDAKSLG7N115GWjqiD98ETu86M3ypQrbORed(rm7rCb7gpU0Js(O8ETu86M3ypQrTtFe0q)O8ETu86M3ypQrbxTMhL8r8QSWvRrXRBEJ9OgfGUsm4hXGhXfSB84sDDH7rnDDmVa8JU3Bdk0uV9Uons2sW9Z66Cq4eiKUEEVwkEDZBSh1Oa0vIb)ig8iiCy1v0(rjFKW9GfzOHUbHFeZEuIDDH7rnDDBWkgiMCDZDV3guKyV9Uons2sW9Z66Cq4eiKUEEVwkEDZBSh1Oa0vIb)ig8iiCy1v0(rjFuEVwkEDZBSh1O2PDDH7rnDDyGaPgSjdiXp6EVnOOb92760izlb3pRRZbHtGq66UaGqU6GeRFOs5(Jya7hbfA6rjFKlwACfMeqmqmET5hkAKSLG76c3JA66yEb4hDV7DDH7blY4ILgh3BV3wI92760izlb3pRRZbHtGq66c3dwKHg6ge(rm7rj(OKpkVxlfVU5n2JAuWvR5rjFuZpILacjBjLhxY4LHx38g7rnpIzpIxLfUAnkBWkgiMCDZk4nq8OMhbn0pILacjBjLhxY4LHx38g7rnpIbSFKMEutDDH7rnDDBWkgiMCDZDV3wd6T31PrYwcUFwxNdcNaH01H6JyjGqYwsbhyjBjdVU5n2JAEuYhXsaHKTKYJlz8YWRBEJ9OMhXa2pstpcAOFuZpIxLfUAnQl5ubuWBG4rnpIbpILacjBjLhxY4LHx38g7rnpk5JG6JCXsJRa7Hm1YKwTiGIgjBj4h10JGg6h5ILgxb2dzQLjTArafns2sWpk5JY71sb2dzQLjTAra1o9rjFelbes2skpUKXldVU5n2JAEeZEKW9Og1LCQakEvw4Q18iOH(rRaYHBa0vIb)ig8iwciKSLuECjJxgEDZBSh18iOH(rSeqizlPGdSKTKHx38g7rnDDH7rnD9l5ub6EVnOO3ExNgjBj4(zDDoiCcesx3flnUsSK2yhiynRGnRnGrfns2sWpk5JA(r59AP41nVXEuJcUAnpk5JG6JY71sDuUb7assqbiH7pQPUUW9OMUomqGud2KbK4hDV7DDSldSaGnGYfpQP3EVTe7T31PrYwcUFwxNdcNaH01fUhSidn0ni8Jyg7hXsaHKTK6OCd2bKKGzzLlHDqKa9OKpQ5hL3RL6OCd2bKKGcqc3Fe0q)O8ETuRaqyVaxfGeU)OM66c3JA66lRCjSdIeOU3BRb92760izlb3pRRZbHtGq6659APwbGWEbUkajCVRlCpQPRNYiOYwb7DV3gu0BVRtJKTeC)SUoheobcPRN3RL6OCd2bKKGcqc3FuYhL3RL6OCd2bKKGcqxjg8JyWJeUh1OwbGYI1QiTj(2jJhxQRlCpQPRNYiOYwb7DV3wJP3ExNgjBj4(zDDoiCcesxpVxl1r5gSdijbfGeU)OKpQ5hLciwgiCyvIQvaOSyTpcAOF0kae2fGtaLW9Gf9iOH(rc3JAuPmcQSvWUkgZYgqo8h1uxx4EutxpLrqLTc27EVnnV3ExNgjBj4(zDDoiCcesxpVxlfEpMeIbc2KTeghdedGeygv70hL8rn)iEvw4Q1Oa7Hm1YKwTiGcqxjg8Jo9rc3JAuG9qMAzsRweqrAt8TtgpU0Jo9rCb7gpU0Jy2JY71sH3JjHyGGnzlHXXaXaibMrfGUsm4hbn0pcQpYflnUcShYultA1IakAKSLGFutpk5JyjGqYws5XLmEz41nVXEuZJo9rCb7gpU0Jy2JY71sH3JjHyGGnzlHXXaXaibMrfGUsm4UUW9OMUEkJGkBfS39EBq5E7DDAKSLG7N115GWjqiD98ETuhLBWoGKeuas4(Js(ixaqixDqI1puPC)rmG9JGcn9OKpYflnUctcigigV28dfns2sWDDH7rnD9ugbv2kyV792yE6T31PrYwcUFwxNdcNaH01Z71sLYiO4wbFvas4(Js(iUGDJhx6rm4r59APszeuCRGVkaDLyWDDH7rnD9ugbv2kyV792AC92760izlb3pRRVXKP1ryjdxWEmq6TLyxNdcNaH01H6JwbGWUaCcOeUhSOhL8rq9rSeqizlPwbGmzRGDtAv2yG8OKpQ5h18JA(rc3JAuRaqzXAvK2eF7Xa5rjFuZps4EuJAfaklwRI0M4BNma6kXGFedEKMuA(JGg6hb1hb2dTkaesTcaH9cCv0izlb)OMEe0q)iH7rnQugbv2kyxrAt8ThdKhL8rn)iH7rnQugbv2kyxrAt8TtgaDLyWpIbpstkn)rqd9JG6Ja7HwfacPwbGWEbUkAKSLGFutpQPhL8r59APoiXJbIzNQaKW9h10JGg6h18JCXsJRWKaIbIXRn)qrJKTe8Js(ixaqixDqI1puPC)rmG9JGcn9OKpQ5hL3RL6GepgiMDQcqc3FuYhb1hjCpQrH5fGFOiTj(2JbYJGg6hb1hL3RL6OCd2bKKGcqc3FuYhb1hL3RL6GepgiMDQcqc3FuYhjCpQrH5fGFOiTj(2JbYJs(iO(OJYnyhqscgCkzTytmMLnGC4pQPh10JAQRVXKPwldeoCVTe76c3JA66RaqMSvWE37TXq2BVRtJKTeC)SUoheobcPRNciwgiCyvIkmVa8JhL8r59APoiXJbIzNQaKW9hL8rUyPXvysaXaX41MFOOrYwc(rjFKlaiKRoiX6hQuU)igW(rqHMEuYhjCpyrgAOBq4hXGhXsaHKTK6OCd2bKKGzzLlHDqKa11fUh101tzeuzRG9U3Blrn1BVRtJKTeC)SUoheobcPRd1hXsaHKTKk9OOj02KwLngipk5JA(rq9rUyPXvlqDn(bze8bHv0izlb)iOH(rc3dwKHg6ge(rm7rj(OMEuYh18JeUhSidC5QaYeo9ig8Og8iOH(rc3dwKHg6ge(rmJ9JyjGqYwsDiaydxWUzzLlHDqKa9iOH(rc3dwKHg6ge(rmJ9JyjGqYwsDuUb7assWSSYLWoisGEutDDH7rnD90JIMqBZYkxc39EBjMyV9Uons2sW9Z66c3JA66CXAnc3JAm2a7DDBGDZixQRlCpyrgxS044U3BlXg0BVRtJKTeC)SUoheobcPRlCpyrgAOBq4hXShLyxx4EutxhgiqQbBYas8JU3BlrOO3ExNgjBj4(zDDoiCcesx3faeYvhKy9dvk3Fedy)iOqtpk5JCXsJRWKaIbIXRn)qrJKTeCxx4EutxhZla)O792sSX0BVRtJKTeC)SUoheobcPRlCpyrgAOBq4hXm2pILacjBjLa4Yqgs7uBHJAEuYhDLruPC)rmJ9JyjGqYwsjaUmKH0o1w4OgZvgPRlCpQPRlaUmKH0o1w4OMU3BlrnV3ExNgjBj4(zDDoiCcesxx4EWIm0q3GWpIzSFelbes2sQdbaB4c2nlRCjSdIeOUUW9OMU(Ykxc7GibQ792sek3BVRlCpQPRVcaLfRTRtJKTeC)SU39UoVU5n2JAm8QSWvRb3BV3wI9276c3JA66PLh101PrYwcUFw37T1GE7DDH7rnD9STkyZAdySRtJKTeC)SU3Bdk6T31fUh101ZeatGeIbsxNgjBj4(zDV3wJP3Exx4EutxFfakBRcURtJKTeC)SU3BtZ7T31fUh101LHtyhiwdxS2Uons2sW9Z6EVnOCV9UUW9OMU(gtMWPlURtJKTeC)SU3BJ5P3ExNgjBj4(zDDH7rnDDiwboeVaytwGHqD9nMm1AzGWH7TLyxNdcNaH01fUh1OUKtfqfJzzdih(JGg6hXRYcxTg1LCQakaDLyWpIzpkrn11P1I4UzKl11Hyf4q8cGnzbgc19EBnUE7DDAKSLG7N115GWjqiDDWEOvbGqkNUPfqSMwcivrJKTe8Js(O8ETuK2hYg7rnQDAxx4Eutx3JlzAjG0U39U31zraCutVTgOPgOPetSbq5UElbmXab311mo5NmTX82gdbM7rpQ9d6rXnTa(Jwf4rAbQut6HGjTEeGoPDai4hHRl9iz71vCc(r8dzGqy1Zedhd9inN5E0jQHfbCc(rA5ILgx1iTEKxpslxS04QgPOrYwcwRh1Cd0Uj1Zedhd9iOmZ9Otudlc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwpQ5e1Uj1Zedhd9iOmZ9Otudlc4e8J0cShAvaiKQrA9iVEKwG9qRcaHunsrJKTeSwpQ5gODtQNjgog6rmKm3JornSiGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMtu7MuptmCm0JsmrM7rNOgweWj4hPLlwACvJ06rE9iTCXsJRAKIgjBjyTEK4pQXZ8ZWpQ5e1Uj1Z0ZKMXj)KPnM32yiWCp6rTFqpkUPfWF0QapslyAjBRR1Ja0jTdab)iCDPhjBVUItWpIFidecREMy4yOhLiZ9Otudlc4e8J0cShAvaiKQrA9iVEKwG9qRcaHunsrJKTeSwps8h14z(z4h1CIA3K6zIHJHEudyUhDIAyraNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rn3aTBs9mXWXqpsZzUhDIAyraNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rnNO2nPEMy4yOhbLzUhDIAyraNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rnNO2nPEMy4yOhX8WCp6e1WIaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1JAorTBs9mXWXqpQbAoZ9Otudlc4e8J0cShAvaiKQrA9iVEKwG9qRcaHunsrJKTeSwpQ5e1Uj1Zedhd9OgaLzUhDIAyraNGFKwG9qRcaHunsRh51J0cShAvaiKQrkAKSLG16rnNO2nPEMy4yOh1aMhM7rNOgweWj4hPfyp0QaqivJ06rE9iTa7HwfacPAKIgjBjyTEuZjQDtQNjgog6rnGHK5E0jQHfbCc(rA5ILgx1iTEKxpslxS04QgPOrYwcwRh1CIA3K6zIHJHEeuOjM7rNOgweWj4hPfyp0QaqivJ06rE9iTa7HwfacPAKIgjBjyTEK4pQXZ8ZWpQ5e1Uj1Zedhd9iOakyUhDIAyraNGFKwG9qRcaHunsRh51J0cShAvaiKQrkAKSLG16rI)OgpZpd)OMtu7MuptptAgN8tM2yEBJHaZ9Oh1(b9O4Mwa)rRc8iTsbeVUzX16ra6K2bGGFeUU0JKTxxXj4hXpKbcHvptmCm0JAaZ9Otudlc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwpQ5e1Uj1Zedhd9OgWCp6e1WIaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1Je)rnEMFg(rnNO2nPEMy4yOhbfm3JornSiGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMtu7MuptmCm0JGcM7rNOgweWj4hPLlwACvJ06rE9iTCXsJRAKIgjBjyTEK4pQXZ8ZWpQ5e1Uj1Zedhd9OgdZ9Otudlc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwpQ5e1Uj1Zedhd9OgdZ9Otudlc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwps8h14z(z4h1CIA3K6zIHJHEKMZCp6e1WIaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1JAorTBs9mXWXqpsZzUhDIAyraNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rI)OgpZpd)OMtu7MuptmCm0JsekyUhDIAyraNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rnNO2nPEMEM0mo5NmTX82gdbM7rpQ9d6rXnTa(Jwf4rAXRBEJ9OgdVklC1AWA9iaDs7aqWpcxx6rY2RR4e8J4hYaHWQNjgog6rnoM7rNOgweWj4hPfyp0QaqivJ06rE9iTa7HwfacPAKIgjBjyTEuZjQDtQNPNjnJt(jtBmVTXqG5E0JA)GEuCtlG)OvbEKwc3dwKXflnowRhbOtAhac(r46sps2EDfNGFe)qgiew9mXWXqpQbm3JornSiGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMBG2nPEMy4yOhbfm3JornSiGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMtu7MuptptAgN8tM2yEBJHaZ9Oh1(b9O4Mwa)rRc8iTWUmWca2akx8OgTEeGoPDai4hHRl9iz71vCc(r8dzGqy1Zedhd9inN5E0jQHfbCc(rA5ILgx1iTEKxpslxS04QgPOrYwcwRh1CIA3K6zIHJHEeuM5E0jQHfbCc(rA5ILgx1iTEKxpslxS04QgPOrYwcwRhj(JA8m)m8JAorTBs9mXWXqpQXXCp6e1WIaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1JAorTBs9mXWXqpQXXCp6e1WIaob)iTa7HwfacPAKwpYRhPfyp0QaqivJu0izlbR1JAUbA3K6zIHJHEedjZ9Otudlc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwpQ5e1Uj1Zedhd9Oe1eZ9Otudlc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwpQ5e1Uj1Zedhd9OeHcM7rNOgweWj4hPLlwACvJ06rE9iTCXsJRAKIgjBjyTEK4pQXZ8ZWpQ5e1Uj1Z0ZKMXj)KPnM32yiWCp6rTFqpkUPfWF0QapslEDZBSh1yspemP1Ja0jTdab)iCDPhjBVUItWpIFidecREMy4yOhLyIm3JornSiGtWpslEnW7WvnsRh51J0Ixd8oCvJu0izlbR1JAorTBs9mXWXqpkXgWCp6e1WIaob)iT41aVdx1iTEKxpslEnW7WvnsrJKTeSwpQ5e1Uj1Zedhd9OeHcM7rNOgweWj4hPh3t8imJJlA)iMVEKxpIH3YJGdwboQ5rvkbeVapQ5ZB6rn3aTBs9mXWXqpkrOG5E0jQHfbCc(rAXRbEhUQrA9iVEKw8AG3HRAKIgjBjyTEuZjQDtQNjgog6rj2yyUhDIAyraNGFKwG9qRcaHunsRh51J0cShAvaiKQrkAKSLG16rnNO2nPEMy4yOhLOMZCp6e1WIaob)iTa7HwfacPAKwpYRhPfyp0QaqivJu0izlbR1JAorTBs9mXWXqpkrOmZ9Otudlc4e8J0cShAvaiKQrA9iVEKwG9qRcaHunsrJKTeSwpQ5e1Uj1Zedhd9OeBCm3JornSiGtWpslWEOvbGqQgP1J86rAb2dTkaes1ifns2sWA9OMtu7MuptmCm0JAaZdZ9Otudlc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwpQ5gODtQNjgog6rnOXXCp6e1WIaob)iT41aVdx1iTEKxpslEnW7WvnsrJKTeSwpQ5gODtQNjgog6rqrdyUhDIAyraNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rI)OgpZpd)OMtu7MuptptmV30c4e8JyEEKW9OMhzdSJvptDDCkX7TbLHIUEkOwHL66n0JyObGE0jRaHEMAOhD4EkM5o)CiHFSZkEDphh3Tv8Ogoqw(544Yp)zQHEuBfl6MjWJAauwJh1an1an9m9m1qp6ehYaHWm3Zud9iO0JASX0JwbKd3aORed(raXpiWJ8dzEKlaiKR84sgVmWb9OvbEKvWouct8AGFKKdB4m(OnwGqy1Zud9iO0JAStHfNEKTGe8hbiM7rm8MhWpIHiajxS6zQHEeu6rmCvyAEexW(Ja0jTdaDPXXpAvGhDI6M3ypQ5rnhksPXJGRrl)rhLf(rH)OvbEK8OfGWhp6KLCQapIlyVj1Zud9iO0JA8JKT0JWoi4(J4hepHyG8OAEK8Of16rRcKa(rX8i)GE0jxZKHFKxpcqWBo9OwfibBjWQNPNPg6rnETj(2j4hLPvbOhXRBw8hLjiXGvp6KZ5uQJF0udu6qa312(iH7rn4hvJLr1ZKW9OgSkfq86Mf)u2NlaUmKjgNSwI7ptn0JA)iWpILacjBPhHtjEScc)i)GE0SVzc8OA9ixaqih)iXFuRJGF8OgRYFKUdijHhXqTYLWoisGWpQ2ooGPhvRhDI6M3ypQ5r4JABHFuME0gtWQNjH7rnyvkG41nl(PSpNLacjBjng5sSpk3GDajjyww5syhejqAuPSXKRrSyZsaHKTK6OCd2bKKGzzLlHDqKaXwtAWsSBIDdAyxS04QLvUKjvC(XPqrddvxS04QLvUKjvC(XZud9O2pc8JyjGqYw6r4uIhRGWpYpOhn7BMapQwpYfaeYXps8h16i4hpQXsaWp6ec2Fed1kxc7Gibc)OA74aMEuTE0jQBEJ9OMhHpQTf(rz6rBmb)ib)OvyTeq9mjCpQbRsbeVUzXpL95SeqizlPXixI9HaGnCb7MLvUe2brcKgvkBm5Ael2SeqizlPoeaSHly3SSYLWoisGyRjnyj2nXUbnSlwAC1YkxYKko)4uOOHHQlwAC1YkxYKko)4zQHEu7hb(rSeqizl9iCkXJvq4h5h0JM9ntGhvRh5cac54hj(JADe8Jh1yv(J0Dajj8igQvUe2brce(rcGE0gtWpcEdIbYJorDZBSh1OEMeUh1GvPaIx3S4NY(CwciKSL0yKlXMx38g7rnMLvUe2brcKgvkBm5Ael2SeqizlP41nVXEuJzzLlHDqKaXwtAWsSBInu0WUyPXvlRCjtQ48JtHYnmuDXsJRww5sMuX5hptn0JA)iWpILacjBPhHtjEScc)i)GE0SVzc8OA9ixaqih)iXFuRJGF8OtoGld9OgV2P2ch18OA74aMEuTE0jQBEJ9OMhHpQTf(rz6rBmbREMeUh1GvPaIx3S4NY(CwciKSL0yKlXwaCzidPDQTWrnAuPSXKRrSyZsaHKTKsaCzidPDQTWrnS1KgSe7MyZqYq2WUyPXvlRCjtQ48JtBqddvxS04QLvUKjvC(XZud9O2pc8JyjGqYw6r4uIhRGWpYpOhLsaonUaHEuTE0vg5rzYwTEuRJGF8OtoGld9OgV2P2ch18OwH1(OP8hLPhTXeS6zs4EudwLciEDZIFk7ZzjGqYwsJrUeBbWLHmK2P2ch1yUYiAatlzBD2ngnPrLYgqyYFMAOh1(rGFelbes2spkWpAJj4h51JWPepwm(i)GEKCR94pQwpYJl9OyEeM41aJFKFi(JUBS)OubJFKSCc8Otu38g7rnpI0onae(rzAva6rmuRCjSdIei8JAfw7JY0J2yc(rtbUI1YO6zs4EudwLciEDZIFk7ZzjGqYwsJrUeByYkmAww5syhejqAatlzBD2AsJkLnGWK)m1qpsZi8JhX8jgyBmq04rNOU5n2JA0c)iEvw4Q18OwH1(Om9iabV5e8JYm(i5razGR7JKBThxJhL3(J8d6rZ(MjWJQ1J4GWXpc7cWXpIfby8rhbKJhjlNaps4EWs8yG8Otu38g7rnpsg4hHTvl8JGRwZJ8QLaGXpYpOhrd8JQ1JorDZBSh1Of(r8QSWvRr9inJdAE0vsigipcM4boQb)OyEKFqp6KRzYWA8Otu38g7rnAHFeGUsmXa5r8QSWvR5rb(racEZj4hLz8r(rGF0ciCpQ5rE9iHZR94pAvGhX8jgyBmquptc3JAWQuaXRBw8tzFolbes2sAmYLyNqmW2yGyae8M7rnAatlzBD2As1y0Oszdim5ptn0JA)GEe8giEuZJQ1JKhPVNhX8jgiAHF0zwcJJbYJorDZBSh1OEMeUh1GvPaIx3S4NY(CwciKSL0yKlXgNq2aVbIh1OrLYgtUgSe7MyR5ptc3JAWQuaXRBw8tzFolbes2sAmYLyZRBEJ9OgtnMnM0OszJjxdwIDtSPtAhPPeS6kCjdid(Gi3C34Gdn00jTJ0ucwDLjwe2ltTmxbEimgAOPtAhPPeScIvGdXla2Kfyie0qtN0ostjyfeRahIxaS5sWI1g1an00jTJ0ucwfqMWJAmxbcHnRnMGgA6K2rAkbRCnRme2Kfqc40yim0qtN0ostjyLOz3aYpkSbhdec2KA3xbcbn00jTJ0ucwjdpOXnjmLBQLPvGHRl0qtN0ostjyf(O4jKdNayZsgiqdnDs7inLGvdTbI1GzCKumzO5qgobGgA6K2rAkbRYILwbGmzGm8JNjH7rnyvkG41nl(PSpNLacjBjng5sSx14g4ANTKPgZgtAuPSXKRblXUj20jTJ0ucwjAw8HaeSzvJBQLjTArGKSeqizlP41nVXEuJPgZgtptc3JAWQuaXRBw8tzFolbes2sAmYLyxJzJjdF71APrLYgtUgSe7My3an1WSeqizlP41nVXEuJPgZgtNQ5nmDs7inLGvxHlzazWhe5M7gh8NPg6rTFe4hXsaHKT0JGjNa3yi8JADqZJo5Aw8HaeTWpIHwJ)OA9inZQfbEuGF0gtWpktRcqpYpOhLUT2hfRhLxIAvJBQLjTAratkG41nlUHFiZq2hf4hnL)iCkXJvqWQNjH7rnyvkG41nl(PSpNLacjBjng5sSx14MAzsRweWKciEDZIB4hYmKvJkLnMCnyj2nXoXgNgXInlbes2sQvnUbU2zlzQXSXusO6ILgxTcaHDb4eijlbes2sQvnUPwM0QfbmPaIx3S4g(HmdzzRPNPg6rnwvRhzRbYJY0Qa0JorDZBSh18i8rTTWpQXFtzeqI9rm)a4rgo9Om9OnMGz(2ZKW9OgSkfq86Mf)u2NZsaHKTKgJCj20nLrajwtbGhz4KbMScJAatlzBD2j240Oszdim5ptn0JA)GE0SVzc8OA9ixaqih)i9Jy5Xa5rAMvlc8i8rTTWpktpAJj4hvZJG3GyG8Otu38g7rnQNjH7rnyvkG41nl(PSpNLacjBjng5sS51nVXEuJbFelpgiM0Qfb0aMwY26SBGgvkBaHj)zs4EudwLciEDZIFk7Z3yYeoD1yKlXw0S4dbiyZQg3ultA1Iaptc3JAWQuaXRBw8tzF(naGcyIRaHEMeUh1GvPaIx3S4NY(8ugbv2kyxJyXgQPaILkLrqLTc2FMEMAOh141M4BNGFeXIam(ipU0J8d6rc3lWJc8JewsyLSLuptc3JAWS51ECcGtjRvJyXgQG9qRcaHuWbMhP2yeaJgEDVYa)mjCpQbFk7ZzjGqYwsJrUeBpUKXldVU5n2JA0OszJjxdwIDtSDXsJRwbGWUaCc0WRaqyxaobua6kXGpTzEvw4Q1O41nVXEuJcqxjgCd3CIqjwciKSLujedSngigabV5Eutd7ILgxLqmW2yG0utnmu5vzHRwJIx38g7rnkajWm2W59AP41nVXEuJcUAnptn0JozLeOhH3a6rNOU5n2JAEuGFemzfgj4hfRhnebtWpklyc(r18i)GEeDtzeqI1ua4rgozGjRW4JyjGqYw6zs4Eud(u2NZsaHKTKgJCj2ECjJxgEDZBSh1OrLY(kARblXUj2SeqizlPOBkJasSMcapYWjdmzfgHsnZRYcxTgfDtzeqI1ua4rgoPG3aXJAGs8QSWvRrr3ugbKynfaEKHtkaDLyWn1WqLxLfUAnk6MYiGeRPaWJmCsbibMrnIfB6K2rAkbROBkJasSMcapYWPNjH7rn4tzFolbes2sAmYLy7XLmEz41nVXEuJgvk7ROTgSe7MyZRYcxTgfeRahIxaSjlWqifGUsmynIfB6K2rAkbRGyf4q8cGnzbgc9mjCpQbFk7ZzjGqYwsJrUeBpUKXldVU5n2JA0OszFfT1GLy3e78ETuG9qMAzsRweqbORedwJyX2flnUcShYultA1IajZ71sXRBEJ9OgfC1AEMeUh1GpL95SeqizlPXixIThxY4LHx38g7rnAuPSVI2AWsSBInVklC1AuG9qMAzsRweqbORed(08ETuG9qMAzsRweqbVbIh1OrSy7ILgxb2dzQLjTArGK59AP41nVXEuJcUAnj5vzHRwJcShYultA1IakaDLyWNQ5mGLacjBjLhxY4LHx38g7rnptc3JAWNY(C8rS8yGysRweqJyXoVxlfVU5n2JAuWvRjjlbes2skpUKXldVU5n2JAy2ABTgabV5EutYM5vzHRwJcShYultA1IakaDLyWmBTTwdGG3CpQbAOHQlwACfypKPwM0QfbA6zs4Eud(u2Nde4qg3GtfqcAel2nN3RLIx38g7rnk4Q1KmVxlfypKPwM0QfbuWvRjzZSeqizlP84sgVm86M3ypQHbK2eF7KXJlbn0SeqizlP84sgVm86M3ypQHz8QSWvRrbe4qg3Gtfqck4nq8OMMAcAOBoVxlfypKPwM0Qfbu70KSeqizlP84sgVm86M3ypQHzqHMA6zs4Eud(u2NdtIFKlWqAel259AP41nVXEuJcUAnjZ71sb2dzQLjTArafC1AsYsaHKTKYJlz8YWRBEJ9OggqAt8TtgpU0ZKW9Og8PSp)gaqbmXvGqAel259AP41nVXEuJcUAnjHP8ETuaboKXn4ubKGH12oeqYHnCgvWvR5zs4Eud(u2NVXKjC6QbTwe3nJCj2qScCiEbWMSadH0iwSzjGqYws5XLmEz41nVXEudZ4vzHRwdusZFMeUh1GpL95BmzcNUAmYLyt3ugbKynfaEKHtAel2SeqizlP84sgVm86M3ypQHbSzjGqYwsr3ugbKynfaEKHtgyYkm(mjCpQbFk7Z3yYeoD1yKlXgxBRjGmHtanIfBwciKSLuECjJxgEDZBSh1Wm2SeqizlPQXSXKHV9ATEMeUh1GpL95BmzcNUAmYLydXYy6HPwgbJJByfpQrJyXMLacjBjLhxY4LHx38g7rnmJnlbes2sQAmBmz4BVwRNjH7rn4tzF(gtMWPRgJCj2xHlzazWhe5M7ghCnIfBwciKSLuECjJxgEDZBSh1Wa2A(ZKW9Og8PSpFJjt40vJrUeByajWRaqgwegtwnIfBwciKSLuECjJxgEDZBSh1Wm2SeqizlPQXSXKHV9ATEMeUh1GpL95BmzcNUAmYLylAw8HaeSzvJBQLjTAranIfBwciKSLuECjJxgEDZBSh1Wa2A(PjQ5nmlbes2sQvnUbU2zlzQXSXuswciKSLuECjJxgEDZBSh1Wmn9mjCpQbFk7ZHSfaCiJPwgrZsGYp0iwSBMLacjBjLhxY4LHx38g7rnmirnbn0RaYHBa0vIbZawciKSLuECjJxgEDZBSh100ZKW9Og8PSpNxdNghiobBww5sptc3JAWNY(CajPXaXSSYLWptc3JAWNY(8vX3yc2iAwceozYKCFMeUh1GpL95PBqSymgiMSvW(ZKW9Og8PSphePPwYeJbNkC6zs4Eud(u2N7hKzp5ApWMvb40Zud9igcK)i)GEeCG5rQngbWOHx3RmWpkVxRhTt14r7Xsy8J41nVXEuZJc8JWvnQNjH7rn4tzFoV2JtaCkzTAel2G9qRcaHuWbMhP2yeaJgEDVYaNKxLfUAnQ8ETmWbMhP2yeaJgEDVYaRaKaZyY8ETuWbMhP2yeaJgEDVYaBeaxgsbxTMKSeqizlP84sgVm86M3ypQHzqHMsc18ETuWbMhP2yeaJgEDVYaR2Pptc3JAWNY(CbWLHmK2P2ch1OrSyd2dTkaesbhyEKAJramA419kdCsEvw4Q1OY71YahyEKAJramA419kdScqcmJjZ71sbhyEKAJramA419kdSraCzifC1AsYsaHKTKYJlz8YWRBEJ9OgMbfAkjuZ71sbhyEKAJramA419kdSAN(mjCpQbFk7ZxGc75Y6Ael2G9qRcaHuWbMhP2yeaJgEDVYaNKxLfUAnQ8ETmWbMhP2yeaJgEDVYaRaKaZyY8ETuWbMhP2yeaJgEDVYaBwGc7k4Q1KKLacjBjLhxY4LHx38g7rnmdk0usOM3RLcoW8i1gJay0WR7vgy1o9zs4Eud(u2NZfR1iCpQXydSRXixInVU5n2JAmPhcM0iwSHklbes2sk4alzlz41nVXEutswciKSLuECjJxgEDZBSh1Wa2A6zs4Eud(u2NZsaHKTKgJCj2RaqMSvWUjTkBmq0GLy3eBOYsaHKTKcoWs2sgEDZBSh1KKLacjBjLhxY4LHx38g7rnmq4EuJAfaYKTc2vRT1Aae)qaqiJhxckjCpQrHpILhdetA1IaQ12AnacEZ9OMgUzEvw4Q1OWhXYJbIjTArafGUsmygWsaHKTKYJlz8YWRBEJ9OMMsYsaHKTKYJlz8YWRBEJ9OggScihUbqxjgm0q7ILgxb2dzQLjTArGK59APa7Hm1YKwTiGcUAnj5vzHRwJcShYultA1IakaDLyWmq4EuJAfaYKTc2vRT1Aae)qaqiJhxckjCpQrHpILhdetA1IaQ12AnacEZ9OMgUzEvw4Q1OWhXYJbIjTArafGUsmygWRYcxTgfypKPwM0Qfbua6kXGBkjVklC1AuG9qMAzsRweqbORedMbRaYHBa0vIb)mjCpQbFk7ZzjGqYwsJrUe70JIMqBtAv2yGOblXUj2qLLacjBjfCGLSLm86M3ypQjjlbes2skpUKXldVU5n2JAyGW9Ogv6rrtOTzzLlHvRT1Aae)qaqiJhxckjCpQrHpILhdetA1IaQ12AnacEZ9OMgUzEvw4Q1OWhXYJbIjTArafGUsmygWsaHKTKYJlz8YWRBEJ9OMMsYsaHKTKYJlz8YWRBEJ9OggScihUbqxjgm0qd2dTkaesH3JjHyGGnzlHXXa5zs4Eud(u2Nd2dzQLjTAranIf78ETuG9qMAzsRweqbxTMKqnVxl1kae2lWvbiH7jBMLacjBjLhxY4LHx38g7rnmJDEVwkWEitTmPvlcOG3aXJAsYsaHKTKYJlz8YWRBEJ9OgMjCpQrTcazYwb7Q12AnaIFiaiKXJlbn0SeqizlP84sgVm86M3ypQHzRaYHBa0vIbdn0SeqizlPGdSKTKHx38g7rnn9mjCpQbFk7Z5I1AeUh1ySb21yKlXguPM0dbtAel259APa7Hm1YKwTiGANMSzwciKSLuECjJxgEDZBSh1Wmn10ZKW9Og8PSpNLacjBjng5sStpkAcTnPvzJbIgSe7MyZsaHKTKYJlz8YWRBEJ9OggiCpQrLEu0eABww5sy1ABTgaXpeaeY4XLsYsaHKTKYJlz8YWRBEJ9OggScihUbqxjgm0qd2dTkaesH3JjHyGGnzlHXXa5zQHEKMXbnpQXsaWCb7Xa5rmuRCPhP7GibsJhXqda9OZSc2XpcFuBl8JY0J2yc(rE9ii0qaXPh1yv(J0DajjGFKmWpYRhrA70a)OZSc2jWJozfSta1ZKW9Og8PSpFfaYKTc21yJjtTwgiCy2jQXgtMwhHLmCb7XaHDIAel2qLLacjBj1kaKjBfSBsRYgdKKnZsaHKTKYJlz8YWRBEJ9OgMPjOHw4EWIm0q3GWmJnlbes2sQdbaB4c2nlRCjSdIeOKqDfac7cWjGs4EWIsc18ETuhLBWoGKeuas4EYMZ71sDqIhdeZovbiH7jfUh1Oww5syhejqksBIVDYaORedMbAsP5qdn)qaqiSzbeUh1iwMXUbn10Zud9igI2GyG8igAaiSlaNaA8igAaOhDMvWo(rcGE0gtWpch3WkalJpYRhbVbXa5rNOU5n2JAupIHaneqSwg14r(bX4Jea9OnMGFKxpccneqC6rnwL)iDhqsc4h16GMhXbHJFuRWAF0u(JY0JAjyNGFKmWpQv4hp6mRGDc8Otwb7eqJh5heJpcFuBl8JY0JWPasGFuT9h51JUsmUeZJ8d6rNzfStGhDYkyNapkVxl1ZKW9Og8PSpFfaYKTc21yJjtTwgiCy2jQXgtMwhHLmCb7XaHDIAel2Raqyxaobuc3dwus(HaGqyMXoXKqLLacjBj1kaKjBfSBsRYgdKKndvH7rnQvaOSyTksBIV9yGKeQc3JAuPmcQSvWUkgZYgqo8K59APoiXJbIzNQaKWDOHw4EuJAfaklwRI0M4BpgijHAEVwQJYnyhqsckajChAOfUh1OszeuzRGDvmMLnGC4jZ71sDqIhdeZovbiH7jHAEVwQJYnyhqsckajCVPNPg6rNCwva)iUKMgdKhXqda9OZSc2Fe)qaqi8JADew6r8dzgYgdKhPFelpgipsZSArGNjH7rn4tzF(kaKjBfSRXgtMwhHLmCb7XaHDIAel2c3JAu4Jy5XaXKwTiGI0M4BpgijxBR1ai(HaGqgpUedeUh1OWhXYJbIjTAraLh8emacEZ9OMK59APok3GDajjOGRwZZKW9Og8PSpNlwRr4EuJXgyxJrUeBSldSaGnGYfpQrJyXUzwciKSLuECjJxgEDZBSh1Wmnbn0SeqizlPGdSKTKHx38g7rnnLmVxlfypKPwM0QfbuWvR5zs4Eud(u2NJ5fGF8m9mjCpQbReUhSiJlwACmBBWkgiMCDZAel2c3dwKHg6geMzjMmVxlfVU5n2JAuWvRjzZSeqizlP84sgVm86M3ypQHz8QSWvRrzdwXaXKRBwbVbIh1an0SeqizlP84sgVm86M3ypQHbS1utptc3JAWkH7blY4ILghFk7ZVKtfqJyXgQSeqizlPGdSKTKHx38g7rnjzjGqYws5XLmEz41nVXEuddyRjOHUzEvw4Q1OUKtfqbVbIh1WawciKSLuECjJxgEDZBSh1KeQUyPXvG9qMAzsRweOjOH2flnUcShYultA1IajZ71sb2dzQLjTAra1onjlbes2skpUKXldVU5n2JAyMW9Og1LCQakEvw4Q1an0RaYHBa0vIbZawciKSLuECjJxgEDZBSh1an0SeqizlPGdSKTKHx38g7rnptc3JAWkH7blY4ILghFk7ZHbcKAWMmGe)qJyX2flnUsSK2yhiynRGnRnGXKnN3RLIx38g7rnk4Q1KeQ59APok3GDajjOaKW9MEMEMeUh1Gv86M3ypQXWRYcxTgm70YJAEMeUh1Gv86M3ypQXWRYcxTg8PSppBRc2S2agFMeUh1Gv86M3ypQXWRYcxTg8PSpptambsigiptc3JAWkEDZBSh1y4vzHRwd(u2NVcaLTvb)mjCpQbR41nVXEuJHxLfUAn4tzFUmCc7aXA4I1(mjCpQbR41nVXEuJHxLfUAn4tzF(gtMWPl(zs4EudwXRBEJ9OgdVklC1AWNY(8nMmHtxn2yYuRLbchMDIAqRfXDZixIneRahIxaSjlWqinIfBH7rnQl5ubuXyw2aYHdn08QSWvRrDjNkGcqxjgmZsutptc3JAWkEDZBSh1y4vzHRwd(u2N7XLmTeqQgXInyp0QaqiLt30ciwtlbKMmVxlfP9HSXEuJAN(m9mjCpQbR41nVXEuJj9qWeBBa5WXggI3WqU04Ael259AP41nVXEuJcUAnptn0JA8ypUItp6OA9iBnqE0jQBEJ9OMh1kS2hzfS)i)qMeWpYRhPVNhX8jgiAHF0zwcJJbYJ86rWKtGBm0JoQwpIHga6rNzfSJFe(O2w4hLPhTXeS6zs4EudwXRBEJ9Ogt6HGPtzFolbes2sAmYLytA70atWgEDZBSh1ya0vIbRrLYgtUgSe7MyN3RLIx38g7rnkaDLyWNM3RLIx38g7rnk4nq8OMgUzEvw4Q1O41nVXEuJcqxjgmdY71sXRBEJ9OgfGUsm4MEMAOhDYHHXpYpOhbVbIh18OA9i)GEK(EEeZNyGOf(rNzjmogip6e1nVXEuZJ86r(b9iAGFuTEKFqpIVbaA8hDI6M3ypQ5rX6r(b9iUG9h1Q2w4hXRBQLC6rWBqmqEKFe4hDI6M3ypQr9mjCpQbR41nVXEuJj9qW0PSpNLacjBjng5sSjTDAGjydVU5n2JAma6kXG1OszlWWAWsSBInlbes2skCczd8giEuJgXIDEVwk8EmjedeSjBjmogigajWmQ2Pqdnlbes2sksBNgyc2WRBEJ9OgdGUsmyMLOsZByiCy1v0UHBoVxlfEpMeIbc2KTeghde1v02GDHNaukVxlfEpMeIbc2KTeghdef2fEcn9mjCpQbR41nVXEuJj9qW0PSpplqm1Y4GGNawJyXoVxlfVU5n2JAuWvR5zs4EudwXRBEJ9Ogt6HGPtzFUnyfdetUUznIfBH7blYqdDdcZSetM3RLIx38g7rnk4Q18mjCpQbR41nVXEuJj9qW0PSp)gaqbWMAz8cCPX1iwSZ71sXRBEJ9OgfC1AsM3RLcShYultA1Iak4Q18mjCpQbR41nVXEuJj9qW0PSpFJjt40vJrUe7dgtjGFaib20ceyVfqsXAel259AP41nVXEuJANMu4EuJAfaYKTc2v8dbaHWS1usH7rnQvait2kyxbi(HaGqgpUeZGWHvxr7NjH7rnyfVU5n2JAmPhcMoL95zBvWMAz8dYqdDz8zs4EudwXRBEJ9Ogt6HGPtzF(LUfGrtTm2npGnWasU4NjH7rnyfVU5n2JAmPhcMoL95TkGfMffJbq4AKHtptn0JyOf4rmFNg)GrGgpAJPhjpIHga6rNzfS)i(HaGqpcEdIbYJozdaOa4hvRh1EbU04pIly)rE9iHvfWpIlPPXa5r8dbaHWpkwpI5Dweye7JoHG5cm9Oa)OP8hHjlXDcw9mjCpQbR41nVXEuJj9qW0PSpFfaYKTc21yJjtRJWsgUG9yGWornIfBH7rnQBaafaBQLXlWLgxrAt8ThdKKRT1Aae)qaqiJhxckjCpQrDdaOaytTmEbU04ksBIVDYaORedMbnMKq9OCd2bKKGbNswl2eJzzdihEsOM3RL6OCd2bKKGcqc3t2CEVwkEDZBSh1O2Pqdnu51aVdxfZIaJynCbZfyQPNPg6rAgHFuB)rmVZIaJyF0jemxGjnEedXBS)OnMEedna0JoZkyh)Owh08i)Gy8rTQrl)r39WpEeheo(rYa)Owh08igAaiSxG7Jc8JGRwJ6zs4EudwXRBEJ9Ogt6HGPtzF(kaKjBfSRXgtMATmq4WStuJnMmToclz4c2Jbc7e1iwSHQOzjq4KkBfStaZvWobu0izlbNSzH7blYqdDdcZa2c3dwKbUCvazcNGgAOYRYcxTgv6rrtOTzzLlHvasGzSPKqLxd8oCvmlcmI1WfmxGPK8dbaHWmJDIjZ71sXRBEJ9Og1onjuZ71sTcaH9cCvas4EsOM3RL6OCd2bKKGcqc3tEuUb7assWGtjRfBIXSSbKd)08ETuhK4XaXStvas4odAWZud9inJWpEeZ7SiWi2hDcbZfysJhXqda9OZSc2F0gtpcFuBl8JY0Jey4WJAelJpIxd2bsme8JW1J8dXFu4pkWpAk)rz6rBmb)O9yjm(rmVZIaJyF0jemxGPhf4hj5A7pYRhrANga6rf4r(bbOhja6r3cqpYpK5r0uBihpIHga6rNzfSJFKxpI02Pb(rmVZIaJyF0jemxGPh51J8d6r0a)OA9Otu38g7rnQNjH7rnyfVU5n2JAmPhcMoL95RaqMSvWUgBmzQ1YaHdZorn2yY06iSKHlypgiStuJyXgQIMLaHtQSvWobmxb7eqrJKTeCYMfUhSidn0nimdylCpyrg4YvbKjCcAOHkVklC1AuPhfnH2MLvUewbibMXMsYRbEhUkMfbgXA4cMlWus(HaGqyMXoXKn3SW9Og1kaKjBfSR4hcacHnlGW9OgXEAZSeqizlPiTDAGjydVU5n2JAma6kXGHs59APIzrGrSgUG5cmPG3aXJAAI5lEvw4Q1OwbGmzRGDf8giEuduILacjBjfPTtdmbB41nVXEuJbqxjgmZxnN3RLkMfbgXA4cMlWKcEdepQbkbHdRUI2n1eZyRjOHMLacjBjfPTtdmbB41nVXEuJbqxjgmdyN3RLkMfbgXA4cMlWKcEdepQbAOZ71sfZIaJynCbZfysbORedMbq4WQROn0qZRYcxTgf(iwEmqmPvlcOaKaZysH7blYqdDdcZm2SeqizlP41nVXEuJbFelpgiM0QfbsYlw0iJRMaYHBwc1uY8ETu86M3ypQrTtt2muZ71sTcaH9cCvas4o0qN3RLkMfbgXA4cMlWKcqxjgmd0KsZBkjuZ71sDuUb7assqbiH7jpk3GDajjyWPK1InXyw2aYHFAEVwQds8yGy2PkajCNbn4zs4EudwXRBEJ9Ogt6HGPtzFoV2JtaCkzTAel2G9qRcaHuWbMhP2yeaJgEDVYaNmVxlfCG5rQngbWOHx3RmWk4Q1KmVxlfCG5rQngbWOHx3RmWgbWLHuWvRjjVklC1Au59AzGdmpsTXiagn86ELbwbibMXNjH7rnyfVU5n2JAmPhcMoL95cGldziTtTfoQrJyXgShAvaiKcoW8i1gJay0WR7vg4K59APGdmpsTXiagn86ELbwbxTMK59APGdmpsTXiagn86ELb2iaUmKcUAnj5vzHRwJkVxldCG5rQngbWOHx3RmWkajWm(mjCpQbR41nVXEuJj9qW0PSpFbkSNlRRrSyd2dTkaesbhyEKAJramA419kdCY8ETuWbMhP2yeaJgEDVYaRGRwtY8ETuWbMhP2yeaJgEDVYaBwGc7k4Q18mjCpQbR41nVXEuJj9qW0PSpNlwRr4EuJXgyxJrUeBH7blY4ILgh)mjCpQbR41nVXEuJj9qW0PSpNx38g7rnASXKPwldeom7e1yJjtRJWsgUG9yGWornIf78ETu86M3ypQrbxTMKnd2dTkaesbhyEKAJramA419kdm78ETuWbMhP2yeaJgEDVYaR2PnLSzH7rnQl5ubuXyw2aYHNu4EuJ6sovavmMLnGC4gaDLyWmGTMuqzOHw4EuJcZla)qrAt8ThdKKc3JAuyEb4hksBIVDYaORedMbAsbLHgAH7rnQvaOSyTksBIV9yGKu4EuJAfaklwRI0M4BNma6kXGzGMuqzOHw4EuJkLrqLTc2vK2eF7XajPW9OgvkJGkBfSRiTj(2jdGUsmygOjfuUPNPg6rm)(bbEeVklC1AWpYpe)r4JABHFuME0gtWpQv4hp6e1nVXEuZJWh12c)OASm(Om9OnMGFuRWpEKmps4(wSp6e1nVXEuZJ4c2FKmWpAk)rTc)4rYJ03ZJy(edeTWp6mlHXXa5rPGIREMeUh1Gv86M3ypQXKEiy6u2NZfR1iCpQXydSRXixInVU5n2JAm8QSWvRbRrSyN3RLIx38g7rnkRGDdPDAaigWw4EuJIx38g7rnkRGDZgtWptc3JAWkEDZBSh1yspemDk7Zxw5syhejqAel2nN3RL6OCd2bKKGcqc3Hg68ETuRaqyVaxfGeU3usH7blYqdDdcZm2SeqizlP41nVXEuJzzLlHDqKa9mjCpQbR41nVXEuJj9qW0PSppLrqLTc21iwSZ71sH3JjHyGGnzlHXXaXaibMr1onzEVwk8EmjedeSjBjmogigajWmQa0vIbZmUGDJhx6zs4EudwXRBEJ9Ogt6HGPtzFEkJGkBfSRrSyN3RLAfac7f4QaKW9NjH7rnyfVU5n2JAmPhcMoL95PmcQSvWUgXIDEVwQugbf3k4Rcqc3tM3RLkLrqXTc(Qa0vIbZmUGDJhxkzZ59AP41nVXEuJcqxjgmZ4c2nECjOHoVxlfVU5n2JAuWvRPPNjH7rnyfVU5n2JAmPhcMoL95PmcQSvWUgXIDEVwQJYnyhqsckajCpzEVwkEDZBSh1O2Pptc3JAWkEDZBSh1yspemDk7ZtzeuzRGDnIf7uaXYaHdRsuH5fGFKmVxl1bjEmqm7ufGeU)m1qpQXghdKhPFelpgipsZSArGhbVbXa5rNOU5n2JAEKxpcqyVa0JyObGE0zwb7psg4hPzEu0eA)igQvU0J4hcacHFexMhLPhLPHwbpeRgpkV9hTXBXAz8r1yz8r18OtE14vptc3JAWkEDZBSh1yspemDk7ZXhXYJbIjTAranIf78ETu86M3ypQrTttcvH7rnQvait2kyxXpeaecNu4EWIm0q3GWmJnlbes2skEDZBSh1yWhXYJbIjTArGKc3JAuPhfnH2MLvUewT2wRbq8dbaHmECjMT2wRbqWBUh1Ormoba7u3el2c3JAuRaqMSvWUIFiaieMTW9Og1kaKjBfSRUI2g(HaGq4NjH7rnyfVU5n2JAmPhcMoL95PhfnH2MLvUewJyXoVxlfVU5n2JAu70Kn3SW9Og1kaKjBfSR4hcacHzqIjDXsJRszeuCRGVjfUhSidn0nim7eBcAOHQlwACvkJGIBf8fAOfUhSidn0nimZsSPK59APoiXJbIzNQaKW9tpk3GDajjyWPK1InXyw2aYHZGg8mjCpQbR41nVXEuJj9qW0PSpFfaklwRgXIDEVwkEDZBSh1OGRwtsEvw4Q1O41nVXEuJcqxjgmd4c2nECPKqLxd8oC1YkxYiCoG8OMKndt59APUbauaSPwgVaxACfC1AGgAOYRbEhUkMfbgXA4cMlWutptc3JAWkEDZBSh1yspemDk7ZX8cWp0iwSZ71sXRBEJ9OgfGUsmyMXfSB84sjZ71sXRBEJ9Og1ofAOZ71sXRBEJ9OgfC1AsYRYcxTgfVU5n2JAua6kXGzaxWUXJl9mjCpQbR41nVXEuJj9qW0PSp3gSIbIjx3SgXIDEVwkEDZBSh1Oa0vIbZaiCy1v0oPW9GfzOHUbHzwIptc3JAWkEDZBSh1yspemDk7ZHbcKAWMmGe)qJyXoVxlfVU5n2JAua6kXGzaeoS6kANmVxlfVU5n2JAu70NjH7rnyfVU5n2JAmPhcMoL95yEb4hAel2UaGqU6GeRFOs5odydfAkPlwACfMeqmqmET5hptptc3JAWkqLAspemXEzLlHDqKaPrSylCpyrgAOBqyMXMLacjBj1r5gSdijbZYkxc7GibkzZ59APok3GDajjOaKWDOHoVxl1kae2lWvbiH7n9mjCpQbRavQj9qW0PSppLrqLTc21iwSZ71sH3JjHyGGnzlHXXaXaibMr1onzEVwk8EmjedeSjBjmogigajWmQa0vIbZmUGDJhx6zs4EudwbQut6HGPtzFEkJGkBfSRrSyN3RLAfac7f4QaKW9NjH7rnyfOsnPhcMoL95PmcQSvWUgXIDEVwQJYnyhqsckajC)zQHEuJnMEun0JyObGE0zwb7pIeGLXhfZJozknZhfRhXyTFeCnA5p6qyrpIc)GapQXIepgipQXo9rf4rnwL)iDhqscpIrYFKmWpIc)Gam3JAwA6rhcl6r3cqpYpK5rER6rIfqcmJA8OMZn9OdHf9OtUL0g7abRzfTWpIHUbm(iajWm(iVE0gtA8Oc8OM5n9iDsaXa5rTxB(XJc8JeUhSi1JyiQgT8hbxpYpc8JADew6rhca(rCb7Xa5rmuRCjhejq4hvGh16GMhPVNhX8jgiAHF0zwcJJbYJc8JaKaZO6zs4EudwbQut6HGPtzF(kaKjBfSRXgtMATmq4WStuJnMmToclz4c2Jbc7e1iwSHklbes2sQvait2ky3KwLngijZ71sH3JjHyGGnzlHXXaXaibMrfC1AskCpyrgAOBqygWsaHKTK6qaWgUGDZYkxc7GibkjuxbGWUaCcOeUhSOKnd18ETuhK4XaXStvas4EsOM3RL6OCd2bKKGcqc3tc1uaXYuRLbchwTcazYwb7jBw4EuJAfaYKTc2v8dbaHWmJDdGg6MDXsJRelPn2bcwZkyZAdymjVklC1AuWabsnytgqIFOaKaZytqdDZUyPXvysaXaX41MFK0faeYvhKy9dvk3zaBOqtn1utptn0JASX0JyObGE0zwb7pIc)GapcEdIbYJKhXqdaLfR9Cntgbv2ky)rCb7pQ1bnpQXIepgipQXo9rb(rc3dw0JkWJG3GyG8isBIVD6rTc)4r6KaIbYJAV28d1ZKW9OgScuPM0dbtNY(8vait2kyxJnMm1AzGWHzNOgBmzADewYWfShde2jQrSydvwciKSLuRaqMSvWUjTkBmqsc1vaiSlaNakH7blkzZn3SW9Og1kauwSwfPnX3Emqs2SW9Og1kauwSwfPnX3oza0vIbZanP0COHgQG9qRcaHuRaqyVa3MGgAH7rnQugbv2kyxrAt8ThdKKnlCpQrLYiOYwb7ksBIVDYaORedMbAsP5qdnub7HwfacPwbGWEbUn1uY8ETuhK4XaXStvas4EtqdDZUyPXvysaXaX41MFK0faeYvhKy9dvk3zaBOqtjBoVxl1bjEmqm7ufGeUNeQc3JAuyEb4hksBIV9yGan0qnVxl1r5gSdijbfGeUNeQ59APoiXJbIzNQaKW9Kc3JAuyEb4hksBIV9yGKeQhLBWoGKem4uYAXMymlBa5WBQPMEMeUh1GvGk1KEiy6u2NZfR1iCpQXydSRXixITW9GfzCXsJJFMeUh1GvGk1KEiy6u2NNYiOYwb7Ael259APszeuCRGVkajCpjxWUXJlXG8ETuPmckUvWxfGUsm4KCb7gpUedY71sb2dzQLjTArafGUsm4NjH7rnyfOsnPhcMoL95PmcQSvWUgXIDkGyzGWHvjQW8cWpsM3RL6GepgiMDQcqc3t6ILgxHjbedeJxB(rsxaqixDqI1puPCNbSHcnLu4EWIm0q3GWmGLacjBj1r5gSdijbZYkxc7Gib6zs4EudwbQut6HGPtzFE6rrtOTzzLlH1iwSHklbes2sQ0JIMqBtAv2yGKmVxl1bjEmqm7ufGeUNeQ59APok3GDajjOaKW9KnlCpyrg4YvbKjCIbnaAOfUhSidn0nimZyZsaHKTK6qaWgUGDZYkxc7GibcAOfUhSidn0nimZyZsaHKTK6OCd2bKKGzzLlHDqKa10ZKW9OgScuPM0dbtNY(CmVa8dnIfBxaqixDqI1puPCNbSHcnL0flnUctcigigV28JNjH7rnyfOsnPhcMoL95WabsnytgqIFOrSylCpyrgAOBqyM1GNjH7rnyfOsnPhcMoL95cGldziTtTfoQrJyXw4EWIm0q3GWmJnlbes2skbWLHmK2P2ch1K8kJOs5oZyZsaHKTKsaCzidPDQTWrnMRmYZKW9OgScuPM0dbtNY(8LvUe2brcKgXITW9GfzOHUbHzgBwciKSLuhca2WfSBww5syhejqptc3JAWkqLAspemDk7ZxbGYI1(m9mjCpQbRWUmWca2akx8Og2lRCjSdIeinIfBH7blYqdDdcZm2SeqizlPok3GDajjyww5syhejqjBoVxl1r5gSdijbfGeUdn059APwbGWEbUkajCVPNjH7rnyf2LbwaWgq5Ih1Ck7ZtzeuzRGDnIf78ETuRaqyVaxfGeU)mjCpQbRWUmWca2akx8OMtzFEkJGkBfSRrSyN3RL6OCd2bKKGcqc3tM3RL6OCd2bKKGcqxjgmdeUh1OwbGYI1QiTj(2jJhx6zs4EudwHDzGfaSbuU4rnNY(8ugbv2kyxJyXoVxl1r5gSdijbfGeUNS5uaXYaHdRsuTcaLfRfAOxbGWUaCcOeUhSiOHw4EuJkLrqLTc2vXyw2aYH30Zud9O2bm(iVEeeYFKoZNZEukO44hfdoGPhDYuAMpk9qWe(rf4rNOU5n2JAEu6HGj8JADqZJslmoYws9mjCpQbRWUmWca2akx8OMtzFEkJGkBfSRrSyN3RLcVhtcXabBYwcJJbIbqcmJQDAYM5vzHRwJcShYultA1IakaDLyWNkCpQrb2dzQLjTArafPnX3oz84sNYfSB84smlVxlfEpMeIbc2KTeghdedGeygva6kXGHgAO6ILgxb2dzQLjTArGMsYsaHKTKYJlz8YWRBEJ9OMt5c2nECjML3RLcVhtcXabBYwcJJbIbqcmJkaDLyWptc3JAWkSldSaGnGYfpQ5u2NNYiOYwb7Ael259APok3GDajjOaKW9KUaGqU6GeRFOs5odydfAkPlwACfMeqmqmET5hptc3JAWkSldSaGnGYfpQ5u2NNYiOYwb7Ael259APszeuCRGVkajCpjxWUXJlXG8ETuPmckUvWxfGUsm4NPg6rmeTbXa5r(b9iSldSaGFeOCXJA04r1yz8rBm9igAaOhDMvWo(rToO5r(bX4Jea9OP8hLPyG8O0QSe8Jwf4rNmLM5JkWJorDZBSh1OEuJnMEedna0JoZky)ru4he4rWBqmqEK8igAaOSyTNRzYiOYwb7pIly)rToO5rnwK4Xa5rn2PpkWps4EWIEubEe8gedKhrAt8TtpQv4hpsNeqmqEu71MFOEMeUh1GvyxgybaBaLlEuZPSpFfaYKTc21yJjtTwgiCy2jQXgtMwhHLmCb7XaHDIAel2qDfac7cWjGs4EWIscvwciKSLuRaqMSvWUjTkBmqs2CZnlCpQrTcaLfRvrAt8ThdKKnlCpQrTcaLfRvrAt8TtgaDLyWmqtknhAOHkyp0Qaqi1kae2lWTjOHw4EuJkLrqLTc2vK2eF7XajzZc3JAuPmcQSvWUI0M4BNma6kXGzGMuAo0qdvWEOvbGqQvaiSxGBtnLmVxl1bjEmqm7ufGeU3e0q3SlwACfMeqmqmET5hjDbaHC1bjw)qLYDgWgk0uYMZ71sDqIhdeZovbiH7jHQW9OgfMxa(HI0M4BpgiqdnuZ71sDuUb7assqbiH7jHAEVwQds8yGy2PkajCpPW9OgfMxa(HI0M4BpgijH6r5gSdijbdoLSwSjgZYgqo8MAQPNjH7rnyf2LbwaWgq5Ih1Ck7ZtzeuzRGDnIf7uaXYaHdRsuH5fGFKmVxl1bjEmqm7ufGeUN0flnUctcigigV28JKUaGqU6GeRFOs5odydfAkPW9GfzOHUbHzalbes2sQJYnyhqscMLvUe2brc0ZKW9OgSc7YalaydOCXJAoL95PhfnH2MLvUewJyXgQSeqizlPspkAcTnPvzJbsYMHQlwAC1cuxJFqgbFqyOHw4EWIm0q3GWmlXMs2SW9GfzGlxfqMWjg0aOHw4EWIm0q3GWmJnlbes2sQdbaB4c2nlRCjSdIeiOHw4EWIm0q3GWmJnlbes2sQJYnyhqscMLvUe2brcutptc3JAWkSldSaGnGYfpQ5u2NZfR1iCpQXydSRXixITW9GfzCXsJJFMeUh1GvyxgybaBaLlEuZPSphgiqQbBYas8dnIfBH7blYqdDdcZSeFMeUh1GvyxgybaBaLlEuZPSphZla)qJyX2faeYvhKy9dvk3zaBOqtjDXsJRWKaIbIXRn)4zQHEKMr4hpIMAd54rUaGqowJhf(Jc8JKhbrI5rE9iUG9hXqTYLWoisGEKGF0kSwc8OyWojWpQwpIHgaklwR6zs4EudwHDzGfaSbuU4rnNY(CbWLHmK2P2ch1OrSylCpyrgAOBqyMXMLacjBjLa4Yqgs7uBHJAsELruPCNzSzjGqYwsjaUmKH0o1w4OgZvg5zs4EudwHDzGfaSbuU4rnNY(8LvUe2brcKgXITW9GfzOHUbHzgBwciKSLuhca2WfSBww5syhejqptc3JAWkSldSaGnGYfpQ5u2NVcaLfRT7DV3b]] )

end
