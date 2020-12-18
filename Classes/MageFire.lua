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


    spec:RegisterPack( "Fire", 20201217, [[defJqdqiuqpIOQCjIQQAtIuFcLQrjsCkrsRskv8kvPmluk3svISlc)cfyyevCmIWYik5zeLY0ikvDnuc2gqv6BsPsghqv05uLOSoGQAEQs19is7dLO)HsirheLqSqGkpKOkteOk0fjQQSruc1hvLOYijkv6KsPQSsusVeLqQzQkHBcufStPu(PuQQgkrvvwQuQuEQiMQQKUQQevTvucj8vIsfJLOs7vP(lLgmKdtAXs1Jr1KbCzKnlQpdKrRkoTWQrjK0RjIMnf3wvTBf)wYWLIJlLQSCqphQPt11vY2rrFxkz8efNhfA9sPs18bk7xL3sSFDNaOoTBtwYrwYrczjr7siXlt2dEzbW7oXzSH2jnkxsfeTtg9t7ewCaPDsJYOPuG9R7eCTGCAN84Edg8zadaf(ZQl41Nb44VmQh1WHA2zao(CgSt6RW4TVz33jaQt72KLCKLCKqws0Ues8YK9GxwqIDIU8NcUtsIV82jpbaan7(obGW8DI8DiwCaPdbEqbrhRY3HECVbd(mGbGc)z1f86ZaC8xg1JA4qn7mahFodowLVdbEK40VtWdjr7ITdjl5il5CSESkFhsEp6aIWG)XQ8DOx6qV8y6q5a0JBH0xJbFiO6pe8q(JohYviiYfE8jRxwGGouUGhYOy)LWeVgGdP9WeoJhAHvqewCSkFh6Lo0lQctZH4k2peKAVvaPpno(q5cEi5v)(c7rnhkLqqc2oeqnS7h6Pmahk8dLl4H0dLHe(5qGhiNk4H4k2tvCSkFh6LoK8B0UHoe2Hb3pe)H4sgdOdvZH0dLPwhkxqjXhkMd5p0HyrK)EXH86qqcyXPd1QGsAkfqStmb2X7x3j863xypQX28OyA)6Unj2VUtOr7gcydUDchgobdDN0x5SGx)(c7rncGQ1StuUh1StmbOhhBzrDba6tJV9DBYA)6oHgTBiGn42jvZobt(or5EuZoHPcdTBODYct2kNTG4a72KyNWuH2r)0oHKXPbGaS863xypQXcPVgdENWHHtWq3j8AawHlIjtWrnwUI5kajOr7gcyNSWKT1tyilxXEmG2TjXoHPAw0oPVYzbV(9f2JAeq6RXGp0BhQVYzbV(9f2JAealO6rnhQDoukhIxLbOAncE97lSh1iG0xJbFO3puFLZcE97lSh1iG0xJbFOu3(UnzB)6oHgTBiGn42jvZorba2jk3JA2jmvyODdTtwyYw5Sfehy3Me7eMk0o6N2jKmonaeGLx)(c7rnwi91yW7eomCcg6oHxdWkCrmzcoQXYvmxbibnA3qahk9Hs5q9volWRXkzmGW2UHW4yazHKcWOy1CiWa7qmvyODdjizCAaialV(9f2JASq6RXGpelpKecw4qTZHaXbeFvMd1ohkLd1x5SaVgRKXacB7gcJJbK4RYyXUYL8qV0H6RCwGxJvYyaHTDdHXXasGDLl5Hs9qPUtwyY26jmKLRypgq72KyNWunlANWuHH2nKalz3cSGQh1S9DBY(9R7eA0UHa2GBNWHHtWq3j9vol41VVWEuJaOAn7eL7rn7KUcYwzRddUK4TVBJf2VUtOr7gcydUDchgobdDNOCpyswAOFq4dXYdjXHsFO(kNf863xypQrauTMDIY9OMDIjygdiBV(9TVBd8UFDNqJ2neWgC7KfMSTEcdz5k2Jb0Unj2jCy4em0Dskhs5EWKS0q)GWh6DPhs5EWKSaLlcqt40HadSdXWdXRYauTgrZtrtiJnB0pHfqsby8qPEO0hIHhIxdWkCrmzcoQXYvmxbibnA3qahk9H4pkeeHpelLEijou6d1x5SGx)(c7rnIvZHsFigEO(kNf5asyVGFbKuUFO0hIHhQVYzXt5wSdjvsbKuUFO0h6PCl2HKkPf3qgd2gJnBcqp(HE7q9volEi1JbKD1iGKY9d9(HK1ozHjBLZwqCGDBsStuUh1StYbKSDJI9TVBRDTFDNqJ2neWgC7KQzNGjFNOCpQzNWuHH2n0ozHjBLZwqCGDBsStyQq7OFANqY0qCNaS5as2UrXoENWHHtWq3j8AawHlIjtWrnwUI5kajOr7gcyNSWKT1tyilxXEmG2TjXoHPAw0or5EuJihqY2nk2f8hfcIW2mu5EuJAo0BhkLdXuHH2nKGKXPbGaS863xypQXcPVgd(qV0H6RCwetMGJASCfZvasaSGQh1COupedoeVkdq1Ae5as2UrXUaybvpQz772ap3VUtOr7gcydUDs1StWKVtuUh1StyQWq7gANSWKTYzlioWUnj2jmvOD0pTtgIaiaBoGKTBuSJ3jCy4em0DcVgGv4IyYeCuJLRyUcqcA0UHa2jlmzB9egYYvShdODBsStyQMfTt4uyoukhIPcdTBibjJtdaby51VVWEuJfsFng8HyWHs5q9volIjtWrnwUI5kajawq1JAo0lDiqCaXxL5qPEOu3(UTx2(1DcnA3qaBWTtwyY26jmKLRypgq72KyNWHHtWq3jPCiL7btYsd9dcFO3LEiL7btYcuUianHthcmWoedpeVkdq1AenpfnHm2Sr)ewajfGXdL6HsFiEnaRWfXKj4OglxXCfGe0ODdbCO0hI)Oqqe(qSu6HK4qPpukhIPcdTBibjtdXDcWMdiz7gf74dXsPhIPcdTBiXqeabyZbKSDJID8HadSdXuHH2nKGKXPbGaS863xypQXcPVgd(qVl9q9volIjtWrnwUI5kajawq1JAoeyGDO(kNfXKj4OglxXCfGeyx5sEO3pKSoeyGDO(kNfXKj4OglxXCfGeq6RXGp07hcehq8vzoeyGDiEvgGQ1iWpr2JbKTPArqbKuagpu6dPCpyswAOFq4dXsPhIPcdTBibV(9f2JAS4Ni7XaY2uTi4HsFiEXKgDCXeGECBwPdL6HsFO(kNf863xypQrSAou6dLYHy4H6RCwKdiH9c(fqs5(HadSd1x5SiMmbh1y5kMRaKasFng8HE)qYrWchk1dL(qm8q9volEk3IDiPskGKY9dL(qpLBXoKujT4gYyW2ySzta6Xp0BhQVYzXdPEmGSRgbKuUFO3pKS2jlmzRC2cIdSBtIDIY9OMDsoGKTBuSV9DBsiN9R7eA0UHa2GBNWHHtWq3jW1q5ccIeabMhnMyuiJwE9)6aiOr7gc4qPpuFLZcGaZJgtmkKrlV(FDaeavR5qPpuFLZcGaZJgtmkKrlV(FDaSkKRdjaQwZHsFiEvgGQ1i6RC2ceyE0yIrHmA51)RdGaskaJhk9Hy4HC1qJlGRHSv22uTiOGgTBiGDIY9OMDcVwJtqCdzmBF3MesSFDNqJ2neWgC7eomCcg6obUgkxqqKaiW8OXeJcz0YR)xhabnA3qahk9H6RCwaeyE0yIrHmA51)RdGaOAnhk9H6RCwaeyE0yIrHmA51)RdGvHCDibq1Aou6dXRYauTgrFLZwGaZJgtmkKrlV(FDaeqsby8qPpedpKRgACbCnKTY2MQfbf0ODdbStuUh1StuixhYsY0ykCuZ23TjHS2VUtOr7gcydUDchgobdDNaxdLliisaeyE0yIrHmA51)RdGGgTBiGdL(q9volacmpAmXOqgT86)1bqauTMdL(q9volacmpAmXOqgT86)1bWMHf2favRzNOCpQzNKHf27LX3(UnjKT9R7eA0UHa2GBNWHHtWq3jW1q5ccIeGGb2WOn4b3qcA0UHaou6d1x5SGx)(c7rncGQ1StuUh1StYWc72PyQBF3MeY(9R7eA0UHa2GBNOCpQzNWvJXQCpQXAcSVtmb2TJ(PDIY9GjzD1qJJ3(UnjyH9R7eA0UHa2GBNSWKT1tyilxXEmG2TjXoHddNGHUt6RCwWRFFH9Ogbq1Aou6dLYHy4HGRHYfeejacmpAmXOqgT86)1bqqJ2neWHadSd1x5SaiW8OXeJcz0YR)xhaXQ5qGb2H6RCwaeyE0yIrHmA51)RdGndlSlwnhk9HC1qJlGRHSv22uTiOGgTBiGdL(q8QmavRr0x5SfiW8OXeJcz0YR)xhabKuagpuQhk9Hs5qm8qW1q5ccIeGGb2WOn4b3qcA0UHaoeyGDiaQVYzbiyGnmAdEWnKy1COupu6dLYHuUh1i(KtfueJnBcqp(HsFiL7rnIp5ubfXyZMa0JBH0xJbFO3LEi5iaVhcmWoKY9OgbMxq(JGKH4lpgqhk9HuUh1iW8cYFeKmeF5KfsFng8HE)qYraEpeyGDiL7rnICaPUAmcsgIV8yaDO0hs5EuJihqQRgJGKH4lNSq6RXGp07hsocW7HadSdPCpQr0WiS6gf7csgIV8yaDO0hs5EuJOHry1nk2fKmeF5KfsFng8HE)qYraEpeyGDiL7rnISr)e2HHKKGKH4lpgqhk9HuUh1iYg9tyhgsscsgIVCYcPVgd(qVFi5iaVhk1DYct2kNTG4a72KyNOCpQzNWRFFH9OMTVBtcW7(1DcnA3qaBWTt4WWjyO7K(kNf863xypQryuSBjzAciDO3LEiL7rncE97lSh1imk2TlmbStuUh1St4QXyvUh1ynb23jMa72r)0oHx)(c7rnwEvgGQ1G3(UnjAx7x3j0ODdbSb3oHddNGHUts5q9volEk3IDiPskGKY9dbgyhQVYzroGe2l4xajL7hk1dL(qk3dMKLg6he(qSu6HyQWq7gsWRFFH9OgB2OFc7WqsANOCpQzNKn6NWomKK2(Unjap3VUtOr7gcydUDchgobdDN0x5SaVgRKXacB7gcJJbKfskaJIvZHsFO(kNf41yLmgqyB3qyCmGSqsbyuaPVgd(qS8qCf7wp(0or5EuZoPHry1nk23(UnjEz7x3j0ODdbSb3oHddNGHUt6RCwKdiH9c(fqs5(or5EuZoPHry1nk23(UnzjN9R7eA0UHa2GBNWHHtWq3j9volAyewCJI)ciPC)qPpuFLZIggHf3O4VasFng8Hy5H4k2TE8PdL(qPCO(kNf863xypQraPVgd(qS8qCf7wp(0HadSd1x5SGx)(c7rncGQ1COupu6dPCpyswAOFq4d9(HyQWq7gsWRFFH9OgB2OFc7WqsANOCpQzN0WiS6gf7BF3MSKy)6oHgTBiGn42jCy4em0DsFLZINYTyhsQKciPC)qPpuFLZcE97lSh1iwn7eL7rn7KggHv3OyF772KLS2VUtOr7gcydUDchgobdDN0ajMwqCaHecmVG8NdL(q9volEi1JbKD1iGKY9dL(qk3dMKLg6he(qVFiMkm0UHe863xypQXMn6NWomKK2jk3JA2jnmcRUrX(23TjlzB)6oHgTBiGn42jk3JA2j4Ni7XaY2uTi4oHddNGHUt6RCwWRFFH9OgXQ5qPpedpKY9OgroGKTBuSl4pkeeHpu6dPCpyswAOFq4dXsPhIPcdTBibV(9f2JAS4Ni7XaY2uTi4HsFiL7rnIMNIMqgB2OFclYlJXcj(Jcbrwp(0Hy5HYlJXcjGf3JA2jX4eeUACBK3jk3JAe5as2UrXUG)OqqewQY9OgroGKTBuSl(Qmw(Jcbr4TVBtwY(9R7eA0UHa2GBNWHHtWq3j9vol41VVWEuJy1CO0hkLdLYHuUh1iYbKSDJIDb)rHGi8HE)qsCO0hYvdnUOHryXnk(lOr7gc4qPpKY9GjzPH(bHpK0djXHs9qGb2Hy4HC1qJlAyewCJI)cA0UHaoeyGDiL7btYsd9dcFiwEijouQhk9H6RCw8qQhdi7QrajL7h6Td9uUf7qsL0IBiJbBJXMnbOh)qVFizTtuUh1StAEkAczSzJ(j823Tjlwy)6oHgTBiGn42jCy4em0DsFLZcE97lSh1iaQwZHsFiEvgGQ1i41VVWEuJasFng8HE)qCf7wp(0HsFiL7btYsd9dcFiwk9qmvyODdj41VVWEuJnB0pHDyijTtuUh1StYg9tyhgssBF3MSaV7x3j0ODdbSb3oHddNGHUt6RCwWRFFH9Ogbq1Aou6dXRYauTgbV(9f2JAeq6RXGp07hIRy36XNou6dXWdXRbyfUiB0pzvohsEuJGgTBiGDIY9OMDsoGuxnMTVBtwTR9R7eA0UHa2GBNWHHtWq3j9vol41VVWEuJasFng8Hy5H4k2TE8PdL(q9vol41VVWEuJy1CiWa7q9vol41VVWEuJaOAnhk9H4vzaQwJGx)(c7rnci91yWh69dXvSB94t7eL7rn7emVG8NTVBtwGN7x3j0ODdbSb3oHddNGHUt6RCwWRFFH9OgbK(Am4d9(HaXbeFvMdL(qk3dMKLg6he(qS8qsStuUh1StmbZyaz71VV9DBY6LTFDNqJ2neWgC7eomCcg6oPVYzbV(9f2JAeq6RXGp07hcehq8vzou6d1x5SGx)(c7rnIvZor5EuZobaQGQbB7qs9NTVBt2KZ(1DcnA3qaBWTt4WWjyO7exHGix8qQXFenC)qVl9qYMCou6d5QHgxGjfgdiRxl(JGgTBiGDIY9OMDcMxq(Z23(obGY6Y47x3TjX(1DcnA3qaBWTt4WWjyO7egEi4AOCbbrcGaZJgtmkKrlV(FDae0ODdbStuUh1St41ACcIBiJz772K1(1DcnA3qaBWTtQMDcM8DIY9OMDctfgA3q7eMQzr7exn04ICajSRqNGcA0UHaou7COCajSRqNGci91yWh6TdLYH4vzaQwJGx)(c7rnci91yWhQDoukhsId9shIPcdTBiHKXayIbKfsalUh1CO25qUAOXfsgdGjgqcA0UHaouQhk1d1ohIHhIxLbOAncE97lSh1iGKcW4HANd1x5SGx)(c7rncGQ1StyQq7OFAN4XNSEz51VVWEuZ23TjB7x3j0ODdbSb3oPA2jFvMDIY9OMDctfgA3q7eMQzr7eMkm0UHe0VHriPgBbbgD4KfGmkJh6LoukhIxLbOAnc63WiKuJTGaJoCsaSGQh1COx6q8QmavRrq)ggHKASfey0Htci91yWhk1d1ohIHhIxLbOAnc63WiKuJTGaJoCsajfGXDchgobdDNqT3kAAiab9ByesQXwqGrhoTtyQq7OFAN4XNSEz51VVWEuZ23Tj73VUtOr7gcydUDs1St(Qm7eL7rn7eMkm0UH2jmvZI2j8QmavRraYOaH6feB7kaisaPVgdENWHHtWq3ju7TIMgcqaYOaH6feB7kaiANWuH2r)0oXJpz9YYRFFH9OMTVBJf2VUtOr7gcydUDs1St(Qm7eL7rn7eMkm0UH2jmvZI2j9volGRHSv22uTiOasFng8oHddNGHUtC1qJlGRHSv22uTiOGgTBiGdL(q9vol41VVWEuJaOAn7eMk0o6N2jE8jRxwE97lSh1S9DBG39R7eA0UHa2GBNun7KVkZor5EuZoHPcdTBODct1SODcVkdq1AeW1q2kBBQweuaPVgd(qVDO(kNfW1q2kBBQweuaSGQh1St4WWjyO7exn04c4AiBLTnvlckOr7gc4qPpuFLZcE97lSh1iaQwZHsFiEvgGQ1iGRHSv22uTiOasFng8HE7qSWHE)qmvyODdj84twVS863xypQzNWuH2r)0oXJpz9YYRFFH9OMTVBRDTFDNqJ2neWgC7eomCcg6oPVYzbV(9f2JAeavR5qPpetfgA3qcp(K1llV(9f2JAoelpuEzmwibS4EuZHsFOuoeVkdq1AeW1q2kBBQweuaPVgd(qS8q5LXyHeWI7rnhcmWoedpKRgACbCnKTY2MQfbf0ODdbCOupu6dXWdLYH6RCwetMGJASCfZvasSAou6d1x5S4PCl2HKkPask3puQhk9Hs5qk3dMKLg6he(qVFiMkm0UHe863xypQXIFIShdiBt1IGhcmWoKY9GjzPH(bHp07hIPcdTBibV(9f2JASzJ(jSddjPdbgyhIPcdTBiHhFY6LLx)(c7rnh6LouEzmwibS4EuZHy5HuUh1y5vzaQwZHsDNOCpQzNGFIShdiBt1IGBF3g45(1DcnA3qaBWTt4WWjyO7KuouFLZcE97lSh1iaQwZHsFO(kNfW1q2kBBQweuauTMdL(qPCiMkm0UHeE8jRxwE97lSh1CO3pejdXxoz94thcmWoetfgA3qcp(K1llV(9f2JAoelpeVkdq1Aeqfi0XT4gfkPaybvpQ5qPEOupeyGDOuouFLZc4AiBLTnvlckwnhk9HyQWq7gs4XNSEz51VVWEuZHy5HKn5COu3jk3JA2jqfi0XT4gfk523T9Y2VUtOr7gcydUDchgobdDN0x5SGx)(c7rncGQ1CO0hQVYzbCnKTY2MQfbfavR5qPpetfgA3qcp(K1llV(9f2JAo07hIKH4lNSE8PDIY9OMDcaP(tVGdT9DBsiN9R7eA0UHa2GBNWHHtWq3jmvyODdj84twVS863xypQ5qVl9qY2HsFO(kNf863xypQrauTMDIY9OMDYpGWcITv26f8tJV9DBsiX(1DcnA3qaBWTtwyY26jmKLRypgq72KyNOCpQzNKdiz7gf77eomCcg6or5EuJ4hqybX2kB9c(PXfKmeF5Xa6qPpuEzmwiXFuiiY6XNo0lDiL7rnIFaHfeBRS1l4NgxqYq8Ltwi91yWh69dj7pu6dXWd9uUf7qsL0IBiJbBJXMnbOh)qPpedpuFLZINYTyhsQKciPCF772Kqw7x3j0ODdbSb3oHddNGHUt6RCwWRFFH9Ogbq1Aou6dbq9volGkqOJBXnkuslZLziO2dt4mkaQwZor5EuZo5hqybTXxbrBF3MeY2(1DcnA3qaBWTtuUh1StazuGq9cITDfaeTt4WWjyO7eMkm0UHeE8jRxwE97lSh1CiwEiL7rnwEvgGQ1COx6qSWoHYzI72r)0obKrbc1li22vaq023TjHSF)6oHgTBiGn42jk3JA2j0VHriPgBbbgD40oHddNGHUtyQWq7gs4XNSEz51VVWEuZHEx6HyQWq7gsq)ggHKASfey0HtwaYOmUtg9t7e63WiKuJTGaJoCA772KGf2VUtOr7gcydUDIY9OMDcidJnp2kBvmo(Hr9OMDchgobdDNWuHH2nKWJpz9YYRFFH9OMdXsPhIPcdTBirn2fMS8Lx58oz0pTtazyS5XwzRIXXpmQh1S9DBsaE3VUtOr7gcydUDIY9OMDYx5Ahsw8drU9VWbFNWHHtWq3jmvyODdj84twVS863xypQ5qVl9qSWoz0pTt(kx7qYIFiYT)fo4BF3MeTR9R7eA0UHa2GBNOCpQzNaajfihqYYKWyYSt4WWjyO7eMkm0UHeE8jRxwE97lSh1Ciwk9qmvyODdjQXUWKLV8kNpu6dLYH6RCwetMGJASCfZvasGDLl5HKEO(kNfXKj4OglxXCfGeFvgl2vUKhcmWoedpeVgGv4IyYeCuJLRyUcqcA0UHaoeyGDiMkm0UHe863xypQXwJDHPdbgyhIPcdTBiHhFY6LLx)(c7rnh6TdXchILhkhGEClK(Am4dj)FiL7rnwEvgGQ1COu3jJ(PDcaKuGCajltcJjZ23Tjb45(1DcnA3qaBWTtuUh1StW1Yydqt4eCNWHHtWq3jmvyODdj84twVS863xypQ5qSu6HyQWq7gsuJDHjlF5voFO3oKeSWHANdLYHyQWq7gsuJDHjlF5voFiwEi5COupeyGDiMkm0UHeE8jRxwE97lSh1CO3pKeYzNm6N2j4AzSbOjCcU9DBs8Y2VUtOr7gcydUDchgobdDNWuHH2nKWJpz9YYRFFH9OMdXsPhIPcdTBirn2fMS8Lx58HsFiMkm0UHeE8jRxwE97lSh1Ciwk9qsWchQDoe1EROPHaeaqsbYbKSmjmMmhk9H84th69dXchk9Hy4H41aScxetMGJASCfZvasqJ2neWHadSd1x5SiMmbh1y5kMRaKa7kxYdj9q9volIjtWrnwUI5kaj(QmwSRCj3jk3JA2jCD4KX2x58oPVYz7OFANGRLXgGMWJA2(UnzjN9R7eA0UHa2GBNWHHtWq3jW1q5ccIeabMhnMyuiJwE9)6aiOr7gc4qPpeVkdq1Ae9voBbcmpAmXOqgT86)1bqajfGXdL(q9volacmpAmXOqgT86)1bWQqUoKaOAnhk9Hy4H6RCwaeyE0yIrHmA51)RdGy1CO0hIPcdTBiHhFY6LLx)(c7rnhILhswSWor5EuZoHxRXjiUHmMTVBtwsSFDNqJ2neWgC7eomCcg6obUgkxqqKaiW8OXeJcz0YR)xhabnA3qahk9H4vzaQwJOVYzlqG5rJjgfYOLx)VoaciPamEO0hQVYzbqG5rJjgfYOLx)VoawfY1HeavR5qPpedpuFLZcGaZJgtmkKrlV(FDaeRMdL(qmvyODdj84twVS863xypQ5qS8qYIf2jk3JA2jkKRdzjzAmfoQz772KLS2VUtOr7gcydUDchgobdDNaxdLliisaeyE0yIrHmA51)RdGGgTBiGdL(q8QmavRr0x5SfiW8OXeJcz0YR)xhabKuagpu6d1x5SaiW8OXeJcz0YR)xhaBgwyxauTMdL(qm8q9volacmpAmXOqgT86)1bqSAou6dXuHH2nKWJpz9YYRFFH9OMdXYdjlwyNOCpQzNKHf27LX3(UnzjB7x3j0ODdbSb3oHddNGHUtyQWq7gs4XNSEz51VVWEuZHEx6HKZor5EuZoHRgJv5EuJ1eyFNycSBh9t7eE97lSh1yBEumT9DBYs2VFDNqJ2neWgC7KQzNGjFNOCpQzNWuHH2n0ozHjBLZwqCGDBsStyQMfTtyQWq7gs4XNSEz51VVWEuZHEPdjBh69dPCpQrKdiz7gf7I8YySqI)OqqK1JpDOx6qk3JAe4Ni7XaY2uTiOiVmglKawCpQ5qTZHs5q8QmavRrGFIShdiBt1IGci91yWh69dXuHH2nKWJpz9YYRFFH9OMdL6HsFiMkm0UHeE8jRxwE97lSh1CO3puoa94wi91yWhcmWoKRgACbCnKTY2MQfbf0ODdbCO0hQVYzbCnKTY2MQfbfavR5qPpeVkdq1AeW1q2kBBQweuaPVgd(qVFiL7rnICajB3OyxKxgJfs8hfcISE8Pd9shs5EuJa)ezpgq2MQfbf5LXyHeWI7rnhQDoukhIxLbOAnc8tK9yazBQweuaPVgd(qVFiEvgGQ1iGRHSv22uTiOasFng8Hs9qPpeVkdq1AeW1q2kBBQweuaPVgd(qVFOCa6XTq6RXG3jmvOD0pTtYbKSDJIDBtvMyaTtwyY26jmKLRypgq72Ky772KflSFDNqJ2neWgC7KQzNGjFNOCpQzNWuHH2n0oHPAw0oHPcdTBiHhFY6LLx)(c7rnh69dPCpQr08u0eYyZg9tyrEzmwiXFuiiY6XNo0lDiL7rnc8tK9yazBQweuKxgJfsalUh1CO25qPCiEvgGQ1iWpr2JbKTPArqbK(Am4d9(HyQWq7gs4XNSEz51VVWEuZHs9qPpetfgA3qcp(K1llV(9f2JAo07hkhGEClK(Am4dbgyhcUgkxqqKaVgRKXacB7gcJJbKGgTBiGdbgyhYJpDO3pelStyQq7OFAN08u0eYyBQYedOTVBtwG39R7eA0UHa2GBNWHHtWq3j9volGRHSv22uTiOaOAnhk9Hy4H6RCwKdiH9c(fqs5(HsFOuoetfgA3qcp(K1llV(9f2JAoelLEO(kNfW1q2kBBQweuaSGQh1CO0hIPcdTBiHhFY6LLx)(c7rnhILhs5EuJihqY2nk2f5LXyHe)rHGiRhF6qGb2HyQWq7gs4XNSEz51VVWEuZHy5HYbOh3cPVgd(qPUtuUh1StGRHSv22uTi423TjR21(1DcnA3qaBWTt4WWjyO7K(kNfW1q2kBBQweuSAou6dLYHyQWq7gs4XNSEz51VVWEuZHy5HKZHsDNOCpQzNWvJXQCpQXAcSVtmb2TJ(PDcSASnpkM2(UnzbEUFDNqJ2neWgC7KfMSTEcdz5k2Jb0Unj2jCy4em0DcdpetfgA3qICajB3Oy32uLjgqhk9Hs5qmvyODdj84twVS863xypQ5qS8qY5qGb2HuUhmjln0pi8HyP0dXuHH2nK4rHawUIDB2OFc7Wqs6qPpedpuoGe2vOtqHY9GjDO0hIHhQVYzXt5wSdjvsbKuUFO0hkLd1x5S4Hupgq2vJask3pu6dPCpQrKn6NWomKKeKmeF5KfsFng8HE)qYrWchcmWoe)rHGiSndvUh1OMdXsPhswhk1dL6ozHjBLZwqCGDBsStuUh1StYbKSDJI9TVBtwVS9R7eA0UHa2GBNSWKT1tyilxXEmG2TjXoHddNGHUtYbKWUcDckuUhmPdL(q8hfcIWhILspKehk9Hy4HyQWq7gsKdiz7gf72MQmXa6qPpukhIHhs5EuJihqQRgJGKH4lpgqhk9Hy4HuUh1iAyewDJIDrm2Sja94hk9H6RCw8qQhdi7QrajL7hcmWoKY9OgroGuxngbjdXxEmGou6dXWd1x5S4PCl2HKkPask3peyGDiL7rnIggHv3OyxeJnBcqp(HsFO(kNfpK6XaYUAeqs5(HsFigEO(kNfpLBXoKujfqs5(HsDNSWKTYzlioWUnj2jk3JA2j5as2UrX(23TjBYz)6oHgTBiGn42jlmzB9egYYvShdODBsStuUh1StYbKSDJI9DchgobdDNOCpQrGFIShdiBt1IGcsgIV8yaDO0hkVmglK4pkeez94th69dPCpQrGFIShdiBt1IGcp4sAHeWI7rnhk9H6RCw8uUf7qsLuauTMdL(qE8PdXYdjHC2(UnztI9R7eA0UHa2GBNWHHtWq3jPCiMkm0UHeE8jRxwE97lSh1CiwEi5COupu6d1x5SaUgYwzBt1IGcGQ1StuUh1St4QXyvUh1ynb23jMa72r)0ob76aOqalSC1JA2(Unztw7x3jk3JA2jyEb5p7eA0UHa2GB7BFNaRgBZJIP9R72Ky)6oHgTBiGn42jCy4em0DIY9GjzPH(bHpelLEiMkm0UHepLBXoKujTzJ(jSddjPdL(qPCO(kNfpLBXoKujfqs5(HadSd1x5Sihqc7f8lGKY9dL6or5EuZojB0pHDyijT9DBYA)6oHgTBiGn42jCy4em0DsFLZc8ASsgdiSTBimogqwiPamkwnhk9H6RCwGxJvYyaHTDdHXXaYcjfGrbK(Am4dXYdXvSB94t7eL7rn7KggHv3OyF772KT9R7eA0UHa2GBNWHHtWq3j9volYbKWEb)ciPCFNOCpQzN0WiS6gf7BF3MSF)6oHgTBiGn42jCy4em0DsFLZINYTyhsQKciPCFNOCpQzN0WiS6gf7BF3glSFDNqJ2neWgC7KfMSTEcdz5k2Jb0Unj2jCy4em0DcdpetfgA3qICajB3Oy32uLjgqhk9H6RCwGxJvYyaHTDdHXXaYcjfGrbq1Aou6dPCpyswAOFq4d9(HyQWq7gs8OqalxXUnB0pHDyijDO0hIHhkhqc7k0jOq5EWKou6dLYHy4H6RCw8qQhdi7QrajL7hk9Hy4H6RCw8uUf7qsLuajL7hk9Hy4HAGetBLZwqCaroGKTBuSFO0hkLdPCpQrKdiz7gf7c(Jcbr4dXsPhswhcmWoukhYvdnUqnKmyhQ42DfBZliJcA0UHaou6dXRYauTgbaubvd22HK6pciPamEOupeyGDOuoKRgACbMuymGSET4pcA0UHaou6d5kee5Ihsn(JOH7h6DPhs2KZHs9qPEOu3jlmzRC2cIdSBtIDIY9OMDsoGKTBuSV9DBG39R7eA0UHa2GBNSWKT1tyilxXEmG2TjXoHddNGHUty4HyQWq7gsKdiz7gf72MQmXa6qPpedpuoGe2vOtqHY9GjDO0hkLdLYHs5qk3JAe5asD1yeKmeF5Xa6qPpukhs5EuJihqQRgJGKH4lNSq6RXGp07hsocw4qGb2Hy4HGRHYfeejYbKWEb)cA0UHaouQhcmWoKY9OgrdJWQBuSlizi(YJb0HsFOuoKY9OgrdJWQBuSlizi(YjlK(Am4d9(HKJGfoeyGDigEi4AOCbbrICajSxWVGgTBiGdL6Hs9qPpuFLZIhs9yazxnciPC)qPEiWa7qPCixn04cmPWyaz9AXFe0ODdbCO0hYviiYfpKA8hrd3p07spKSjNdL(qPCO(kNfpK6XaYUAeqs5(HsFigEiL7rncmVG8hbjdXxEmGoeyGDigEO(kNfpLBXoKujfqs5(HsFigEO(kNfpK6XaYUAeqs5(HsFiL7rncmVG8hbjdXxEmGou6dXWd9uUf7qsL0IBiJbBJXMnbOh)qPEOupuQ7KfMSvoBbXb2TjXor5EuZojhqY2nk23(UT21(1DcnA3qaBWTtuUh1St4QXyvUh1ynb23jMa72r)0or5EWKSUAOXXBF3g45(1DcnA3qaBWTt4WWjyO7K(kNfnmclUrXFbKuUFO0hIRy36XNo07hQVYzrdJWIBu8xaPVgd(qPpexXU1JpDO3puFLZc4AiBLTnvlckG0xJbVtuUh1StAyewDJI9TVB7LTFDNqJ2neWgC7eomCcg6oPbsmTG4acjeyEb5phk9H6RCw8qQhdi7QrajL7hk9HC1qJlWKcJbK1Rf)rqJ2neWHsFixHGix8qQXFenC)qVl9qYMCou6dPCpyswAOFq4d9(HyQWq7gs8uUf7qsL0Mn6NWomKK2jk3JA2jnmcRUrX(23TjHC2VUtOr7gcydUDchgobdDNWWdXuHH2nKO5POjKX2uLjgqhk9H6RCw8qQhdi7QrajL7hk9Hy4H6RCw8uUf7qsLuajL7hk9Hs5qk3dMKfOCraAcNo07hswhcmWoKY9GjzPH(bHpelLEiMkm0UHepkeWYvSBZg9tyhgsshcmWoKY9GjzPH(bHpelLEiMkm0UHepLBXoKujTzJ(jSddjPdL6or5EuZoP5POjKXMn6NWBF3MesSFDNqJ2neWgC7eomCcg6oXviiYfpKA8hrd3p07spKSjNdL(qUAOXfysHXaY61I)iOr7gcyNOCpQzNG5fK)S9DBsiR9R7eA0UHa2GBNWHHtWq3jk3dMKLg6he(qS8qYANOCpQzNaavq1GTDiP(Z23TjHSTFDNqJ2neWgC7eomCcg6or5EWKS0q)GWhILspetfgA3qcfY1HSKmnMch1CO0h6RJkA4(HyP0dXuHH2nKqHCDiljtJPWrn2Vo6or5EuZorHCDiljtJPWrnBF3MeY(9R7eA0UHa2GBNWHHtWq3jk3dMKLg6he(qSu6HyQWq7gs8OqalxXUnB0pHDyijTtuUh1StYg9tyhgssBF3MeSW(1DIY9OMDsoGuxnMDcnA3qaBWT9TVt41VVWEuJLxLbOAn49R72Ky)6or5EuZoPP8OMDcnA3qaBWT9DBYA)6or5EuZoPBQcWMxqg3j0ODdbSb323TjB7x3jk3JA2jDcIjOKXaANqJ2neWgCBF3MSF)6or5EuZojhqQBQcyNqJ2neWgCBF3glSFDNOCpQzNOdNWounwUAm7eA0UHa2GB772aV7x3jk3JA2jlmzdN(4DcnA3qaBWT9DBTR9R7eA0UHa2GBNOCpQzNaYOaH6feB7kaiANSWKTYzlioWUnj2jCy4em0DIY9OgXNCQGIySzta6XTq6RXGp07spKCeSWoHYzI72r)0obKrbc1li22vaq023TbEUFDNqJ2neWgC7eomCcg6obUgkxqqKWPFtbvJTLcBe0ODdbCO0hQVYzbjZJUWEuJy1StuUh1St84t2wkSz7BFNOCpyswxn0449R72Ky)6oHgTBiGn42jCy4em0DIY9GjzPH(bHpelpKehk9H6RCwWRFFH9Ogbq1Aou6dLYHyQWq7gs4XNSEz51VVWEuZHy5H4vzaQwJWemJbKTx)UaybvpQ5qGb2HyQWq7gs4XNSEz51VVWEuZHEx6HKZHsDNOCpQzNycMXaY2RFF772K1(1DcnA3qaBWTt4WWjyO7eMkm0UHeE8jRxwE97lSh1CO3LEi5CiWa7qPCiEvgGQ1i(KtfuaSGQh1CO3petfgA3qcp(K1llV(9f2JAou6dXWd5QHgxaxdzRSTPArqbnA3qahk1dbgyhYvdnUaUgYwzBt1IGcA0UHaou6d1x5SaUgYwzBt1IGIvZHsFiMkm0UHeE8jRxwE97lSh1CiwEiL7rnIp5ubf8QmavR5qGb2HYbOh3cPVgd(qVFiMkm0UHeE8jRxwE97lSh1StuUh1St(KtfC772KT9R7eA0UHa2GBNWHHtWq3jUAOXfQHKb7qf3URyBEbzuqJ2neWHsFOuouFLZcE97lSh1iaQwZHsFigEO(kNfpLBXoKujfqs5(HsDNOCpQzNaavq1GTDiP(Z23(ob76aOqalSC1JA2VUBtI9R7eA0UHa2GBNWHHtWq3jk3dMKLg6he(qSu6HyQWq7gs8uUf7qsL0Mn6NWomKKou6dLYH6RCw8uUf7qsLuajL7hcmWouFLZICajSxWVask3puQ7eL7rn7KSr)e2HHK023TjR9R7eA0UHa2GBNWHHtWq3j9volYbKWEb)ciPCFNOCpQzN0WiS6gf7BF3MSTFDNqJ2neWgC7eomCcg6oPVYzXt5wSdjvsbKuUFO0hQVYzXt5wSdjvsbK(Am4d9(HuUh1iYbK6QXiizi(YjRhFANOCpQzN0WiS6gf7BF3MSF)6oHgTBiGn42jCy4em0DsFLZINYTyhsQKciPC)qPpukhQbsmTG4acje5asD1yoeyGDOCajSRqNGcL7bt6qGb2HuUh1iAyewDJIDrm2Sja94hk1DIY9OMDsdJWQBuSV9DBSW(1DcnA3qaBWTt4WWjyO7K(kNf41yLmgqyB3qyCmGSqsbyuSAou6dLYH4vzaQwJaUgYwzBt1IGci91yWh6TdPCpQraxdzRSTPArqbjdXxoz94th6TdXvSB94thILhQVYzbEnwjJbe22neghdilKuagfq6RXGpeyGDigEixn04c4AiBLTnvlckOr7gc4qPEO0hIPcdTBiHhFY6LLx)(c7rnh6TdXvSB94thILhQVYzbEnwjJbe22neghdilKuagfq6RXG3jk3JA2jnmcRUrX(23TbE3VUtOr7gcydUDchgobdDN0x5S4PCl2HKkPask3pu6d5kee5Ihsn(JOH7h6DPhs2KZHsFixn04cmPWyaz9AXFe0ODdbStuUh1StAyewDJI9TVBRDTFDNqJ2neWgC7eomCcg6oPVYzrdJWIBu8xajL7hk9H4k2TE8Pd9(H6RCw0WiS4gf)fq6RXG3jk3JA2jnmcRUrX(23TbEUFDNqJ2neWgC7KfMSTEcdz5k2Jb0Unj2jCy4em0DcdpuoGe2vOtqHY9GjDO0hIHhIPcdTBiroGKTBuSBBQYedOdL(qPCOuoukhs5EuJihqQRgJGKH4lpgqhk9Hs5qk3JAe5asD1yeKmeF5KfsFng8HE)qYrWchcmWoedpeCnuUGGiroGe2l4xqJ2neWHs9qGb2HuUh1iAyewDJIDbjdXxEmGou6dLYHuUh1iAyewDJIDbjdXxozH0xJbFO3pKCeSWHadSdXWdbxdLliisKdiH9c(f0ODdbCOupuQhk9H6RCw8qQhdi7QrajL7hk1dbgyhkLd5QHgxGjfgdiRxl(JGgTBiGdL(qUcbrU4HuJ)iA4(HEx6HKn5CO0hkLd1x5S4Hupgq2vJask3pu6dXWdPCpQrG5fK)iizi(YJb0HadSdXWd1x5S4PCl2HKkPask3pu6dXWd1x5S4Hupgq2vJask3pu6dPCpQrG5fK)iizi(YJb0HsFigEONYTyhsQKwCdzmyBm2Sja94hk1dL6HsDNSWKTYzlioWUnj2jk3JA2j5as2UrX(23T9Y2VUtOr7gcydUDchgobdDN0ajMwqCaHecmVG8NdL(q9volEi1JbKD1iGKY9dL(qUAOXfysHXaY61I)iOr7gc4qPpKRqqKlEi14pIgUFO3LEiztohk9HuUhmjln0pi8HE)qmvyODdjEk3IDiPsAZg9tyhgss7eL7rn7KggHv3OyF772Kqo7x3j0ODdbSb3oHddNGHUty4HyQWq7gs08u0eYyBQYedOdL(qPCigEixn04ImS(w)HSk(HWcA0UHaoeyGDiL7btYsd9dcFiwEijouQhk9Hs5qk3dMKfOCraAcNo07hswhcmWoKY9GjzPH(bHpelLEiMkm0UHepkeWYvSBZg9tyhgsshcmWoKY9GjzPH(bHpelLEiMkm0UHepLBXoKujTzJ(jSddjPdL6or5EuZoP5POjKXMn6NWBF3MesSFDNqJ2neWgC7eL7rn7eUAmwL7rnwtG9DIjWUD0pTtuUhmjRRgAC823TjHS2VUtOr7gcydUDchgobdDNOCpyswAOFq4dXYdjXor5EuZobaQGQbB7qs9NTVBtczB)6oHgTBiGn42jCy4em0DIRqqKlEi14pIgUFO3LEiztohk9HC1qJlWKcJbK1Rf)rqJ2neWor5EuZobZli)z772Kq2VFDNqJ2neWgC7eomCcg6or5EWKS0q)GWhILspetfgA3qcfY1HSKmnMch1CO0h6RJkA4(HyP0dXuHH2nKqHCDiljtJPWrn2Vo6or5EuZorHCDiljtJPWrnBF3MeSW(1DcnA3qaBWTt4WWjyO7eL7btYsd9dcFiwk9qmvyODdjEuiGLRy3Mn6NWomKK2jk3JA2jzJ(jSddjPTVBtcW7(1DIY9OMDsoGuxnMDcnA3qaBWT9TVtAGeV(D13VUBtI9R7eL7rn7efY1HSX4KXqCFNqJ2neWgCBF3MS2VUtOr7gcydUDs1StWKVtuUh1StyQWq7gANWunlANiRd1ohYvdnUiB0pzBuN)iOr7gc4qVDiz7qTZHy4HC1qJlYg9t2g15pcA0UHa2jCy4em0DctfgA3qINYTyhsQK2Sr)e2HHK0HKEi5StyQq7OFAN8uUf7qsL0Mn6NWomKK2(UnzB)6oHgTBiGn42jvZobt(or5EuZoHPcdTBODct1SODISou7Cixn04ISr)KTrD(JGgTBiGd92HKTd1ohIHhYvdnUiB0pzBuN)iOr7gcyNWHHtWq3jmvyODdjEuiGLRy3Mn6NWomKKoK0djNDctfAh9t7Khfcy5k2TzJ(jSddjPTVBt2VFDNqJ2neWgC7KQzNGjFNOCpQzNWuHH2n0oHPAw0or2ou7Cixn04ISr)KTrD(JGgTBiGd92HaVhQDoedpKRgACr2OFY2Oo)rqJ2neWoHddNGHUtyQWq7gsWRFFH9OgB2OFc7Wqs6qspKC2jmvOD0pTt41VVWEuJnB0pHDyijT9DBSW(1DcnA3qaBWTtQMDcM8DIY9OMDctfgA3q7eMQzr7Kx2l7qTZHC1qJlYg9t2g15pcA0UHao0BhswhQDoedpKRgACr2OFY2Oo)rqJ2neWoHddNGHUtyQWq7gsOqUoKLKPXu4OMdj9qYzNWuH2r)0orHCDiljtJPWrnBF3g4D)6oHgTBiGn42jvZobsyY3jk3JA2jmvyODdTtyQq7OFANOqUoKLKPXu4Og7xhDNaqzDz8DISxoBF3w7A)6oHgTBiGn42jvZobsyY3jk3JA2jmvyODdTtyQq7OFANaqgLrB2OFc7WqsANaqzDz8DIC2(UnWZ9R7eA0UHa2GBNun7eiHjFNOCpQzNWuHH2n0oHPcTJ(PDIKXayIbKfsalUh1StaOSUm(orocz)23T9Y2VUtOr7gcydUDs1StWKVtuUh1StyQWq7gANWunlANWc7eMk0o6N2jyj7wGfu9OMTVBtc5SFDNqJ2neWgC7KQzNGjFNOCpQzNWuHH2n0oHPAw0oHAVv00qaIVY1oKS4hIC7FHd(HadSdrT3kAAiaXxNityVSv2(vGHW4dbgyhIAVv00qacqgfiuVGyBxbarhcmWoe1EROPHaeGmkqOEbX2pbOgtuZHadSdrT3kAAiaraAcpQX(vqe2Mxy6qGb2HO2BfnneGWB31HW2UcLe3edHpeyGDiQ9wrtdbi029fK8NcBXXaIaSnM1xbrhcmWoe1EROPHae6WdACRKt52kBBfyG6FiWa7qu7TIMgcqGFkUK9Wji2M1b0HadSdrT3kAAiaXqlOASyghTbtwAE0HtWdbgyhIAVv00qaIUAOCajBhQd)zNWuH2r)0oHx)(c7rn2ASlmT9DBsiX(1DcnA3qaBWTtQMDcKWKVtuUh1StyQWq7gANWuH2r)0oH(nmcj1yliWOdNSaKrzCNaqzDz8DIeGNBF3MeYA)6oHgTBiGn42jvZobt(or5EuZoHPcdTBODct1SODISKZoHddNGHUtyQWq7gsWRFFH9OgBn2fM2jmvOD0pTtQXUWKLV8kN3(UnjKT9R7eA0UHa2GBNun7em57eL7rn7eMkm0UH2jmvZI2jYIf2jCy4em0Dc1EROPHaeFLRDizXpe52)ch8DctfAh9t7KASlmz5lVY5TVBtcz)(1DcnA3qaBWTtQMDcM8DIY9OMDctfgA3q7eMQzr7ezjNd92HyQWq7gsq)ggHKASfey0HtwaYOmUt4WWjyO7eQ9wrtdbiOFdJqsn2ccm6WPDctfAh9t7KASlmz5lVY5TVBtcwy)6oHgTBiGn42jvZobsyY3jk3JA2jmvyODdTtyQq7OFANWRFFH9Ogl(jYEmGSnvlcUtaOSUm(orwBF3MeG39R7eA0UHa2GBNm6N2j4AzSbOjCcUtuUh1StW1Yydqt4eC772KODTFDNOCpQzN8diSG24RGODcnA3qaBWT9DBsaEUFDNqJ2neWgC7eomCcg6oHHhQbsmfnmcRUrX(or5EuZoPHry1nk23(23(oHjbXrn72KLCKLCKqwYb8UtAPWjgq4DISdls7wBTV2E5a)dDOxFOdf)Mc6hkxWdXoSASnpkMy)qqQ9wbKaoeU(0H0LxF1jGdXF0beHfhRVig6qSa4Fi5vdtc6eWHy3vdnUqUSFiVoe7UAOXfYvqJ2nea7hkfzjtQIJ1xedDiWl4Fi5vdtc6eWHy3vdnUqUSFiVoe7UAOXfYvqJ2nea7hkfjKjvXX6lIHoe4f8pK8QHjbDc4qSdxdLliisix2pKxhID4AOCbbrc5kOr7gcG9dLISKjvXX6lIHo0ld8pK8QHjbDc4qS7QHgxix2pKxhIDxn04c5kOr7gcG9dLIeYKQ4y9fXqhscja)djVAysqNaoe7UAOXfYL9d51Hy3vdnUqUcA0UHay)qQFi5x7)fhkfjKjvXX6XQSdls7wBTV2E5a)dDOxFOdf)Mc6hkxWdXoaL1LXz)qqQ9wbKaoeU(0H0LxF1jGdXF0beHfhRVig6qsa(hsE1WKGobCi2HRHYfeejKl7hYRdXoCnuUGGiHCf0ODdbW(Hu)qYV2)louksitQIJ1xedDizb(hsE1WKGobCi2D1qJlKl7hYRdXURgACHCf0ODdbW(HsrwYKQ4y9fXqhIfa)djVAysqNaoe7UAOXfYL9d51Hy3vdnUqUcA0UHay)qPiHmPkowFrm0HaVG)HKxnmjOtahIDxn04c5Y(H86qS7QHgxixbnA3qaSFOuKqMufhRVig6qTlW)qYRgMe0jGdXURgACHCz)qEDi2D1qJlKRGgTBia2puksitQIJ1xedDijAxG)HKxnmjOtahkj(Y7qyghxL5qY)Y)hYRd9ILEOFbSml8HQgcQEbpukY)PEOuKqMufhRVig6qs0Ua)djVAysqNaoe78AawHlKl7hYRdXoVgGv4c5kOr7gcG9dLIeYKQ4y9fXqhsIxg4Fi5vdtc6eWHyNxdWkCHCz)qEDi251aScxixbnA3qaSFOuKqMufhRVig6qYsoG)HKxnmjOtahID4AOCbbrc5Y(H86qSdxdLliisixbnA3qaSFOuKqMufhRVig6qYscW)qYRgMe0jGdXoCnuUGGiHCz)qEDi2HRHYfeejKRGgTBia2puksitQIJ1xedDizjlW)qYRgMe0jGdXoCnuUGGiHCz)qEDi2HRHYfeejKRGgTBia2puksitQIJ1xedDizj7b)djVAysqNaoe7UAOXfYL9d51Hy3vdnUqUcA0UHay)qPiHmPkowFrm0HKfla(hsE1WKGobCi2HRHYfeejKl7hYRdXoCnuUGGiHCf0ODdbW(HsrczsvCSESk7WI0U1w7RTxoW)qh61h6qXVPG(HYf8qS3ajE97QZ(HGu7TcibCiC9PdPlV(QtahI)OdiclowFrm0HKf4Fi5vdtc6eWHy3vdnUqUSFiVoe7UAOXfYvqJ2nea7hkfjKjvXX6lIHoKSa)djVAysqNaoe7UAOXfYL9d51Hy3vdnUqUcA0UHay)qQFi5x7)fhkfjKjvXX6lIHoKSb(hsE1WKGobCi2D1qJlKl7hYRdXURgACHCf0ODdbW(HsrczsvCS(IyOdjBG)HKxnmjOtahIDxn04c5Y(H86qS7QHgxixbnA3qaSFi1pK8R9)IdLIeYKQ4y9fXqhs2d(hsE1WKGobCi2D1qJlKl7hYRdXURgACHCf0ODdbW(HsrczsvCS(IyOdj7b)djVAysqNaoe7UAOXfYL9d51Hy3vdnUqUcA0UHay)qQFi5x7)fhkfjKjvXX6lIHoela(hsE1WKGobCi2D1qJlKl7hYRdXURgACHCf0ODdbW(HsrczsvCS(IyOdXcG)HKxnmjOtahIDxn04c5Y(H86qS7QHgxixbnA3qaSFi1pK8R9)IdLIeYKQ4y9yv2HfPDRT2xBVCG)Ho0Rp0HIFtb9dLl4HyNx)(c7rnwEvgGQ1Gz)qqQ9wbKaoeU(0H0LxF1jGdXF0beHfhRVig6qGNG)HKxnmjOtahID4AOCbbrc5Y(H86qSdxdLliisixbnA3qaSFOuKqMufhRhRYoSiTBT1(A7Ld8p0HE9Hou8BkOFOCbpe7k3dMK1vdnoM9dbP2Bfqc4q46thsxE9vNaoe)rhqewCS(IyOdjlW)qYRgMe0jGdXURgACHCz)qEDi2D1qJlKRGgTBia2pukYsMufhRVig6qYg4Fi5vdtc6eWHy3vdnUqUSFiVoe7UAOXfYvqJ2nea7hkfjKjvXX6XQSdls7wBTV2E5a)dDOxFOdf)Mc6hkxWdXo21bqHawy5Qh1W(HGu7TcibCiC9PdPlV(QtahI)OdiclowFrm0HybW)qYRgMe0jGdXURgACHCz)qEDi2D1qJlKRGgTBia2puksitQIJ1xedDiWl4Fi5vdtc6eWHy3vdnUqUSFiVoe7UAOXfYvqJ2nea7hs9dj)A)V4qPiHmPkowFrm0Hapb)djVAysqNaoe7UAOXfYL9d51Hy3vdnUqUcA0UHay)qPiHmPkowFrm0Hapb)djVAysqNaoe7W1q5ccIeYL9d51HyhUgkxqqKqUcA0UHay)qPilzsvCS(IyOd9Ya)djVAysqNaoe7UAOXfYL9d51Hy3vdnUqUcA0UHay)qPiHmPkowFrm0HKqoG)HKxnmjOtahIDxn04c5Y(H86qS7QHgxixbnA3qaSFOuKqMufhRVig6qsiBG)HKxnmjOtahIDxn04c5Y(H86qS7QHgxixbnA3qaSFi1pK8R9)IdLIeYKQ4y9yv2HfPDRT2xBVCG)Ho0Rp0HIFtb9dLl4HyNx)(c7rn2MhftSFii1ERasahcxF6q6YRV6eWH4p6aIWIJ1xedDizb(hsE1WKGobCi251aScxix2pKxhIDEnaRWfYvqJ2nea7hs9dj)A)V4qPiHmPkowFrm0HKnW)qYRgMe0jGdXoVgGv4c5Y(H86qSZRbyfUqUcA0UHay)qPiHmPkowFrm0HaVG)HKxnmjOtahIDEnaRWfYL9d51HyNxdWkCHCf0ODdbW(HsrczsvCS(IyOd1Ua)djVAysqNaous8L3HWmoUkZHK)pKxh6fl9qabZah1COQHGQxWdLcds9qPiHmPkowFrm0HAxG)HKxnmjOtahIDEnaRWfYL9d51HyNxdWkCHCf0ODdbW(Hu)qYV2)louksitQIJ1xedDiWtW)qYRgMe0jGdLeF5DimJJRYCi5)d51HEXspeqWmWrnhQAiO6f8qPWGupuksitQIJ1xedDiWtW)qYRgMe0jGdXoVgGv4c5Y(H86qSZRbyfUqUcA0UHay)qQFi5x7)fhkfjKjvXX6lIHo0ld8pK8QHjbDc4qSZRbyfUqUSFiVoe78AawHlKRGgTBia2puksitQIJ1xedDijKd4Fi5vdtc6eWHy3vdnUqUSFiVoe7UAOXfYvqJ2nea7hs9dj)A)V4qPiHmPkowFrm0HKqoG)HKxnmjOtahID4AOCbbrc5Y(H86qSdxdLliisixbnA3qaSFOuKqMufhRVig6qsib4Fi5vdtc6eWHy3vdnUqUSFiVoe7UAOXfYvqJ2nea7hs9dj)A)V4qPiHmPkowFrm0HKqcW)qYRgMe0jGdXoCnuUGGiHCz)qEDi2HRHYfeejKRGgTBia2puksitQIJ1xedDijKf4Fi5vdtc6eWHyhUgkxqqKqUSFiVoe7W1q5ccIeYvqJ2nea7hkfjKjvXX6lIHoKeYg4Fi5vdtc6eWHyhUgkxqqKqUSFiVoe7W1q5ccIeYvqJ2nea7hkfjKjvXX6lIHoKeSa4Fi5vdtc6eWHy3vdnUqUSFiVoe7UAOXfYvqJ2nea7hkfjKjvXX6lIHoKeSa4Fi5vdtc6eWHyhUgkxqqKqUSFiVoe7W1q5ccIeYvqJ2nea7hkfzjtQIJ1xedDizj7b)djVAysqNaoe7UAOXfYL9d51Hy3vdnUqUcA0UHay)qPilzsvCS(IyOdjlWl4Fi5vdtc6eWHyNxdWkCHCz)qEDi251aScxixbnA3qaSFi1pK8R9)IdLIeYKQ4y9fXqhs2Kd4Fi5vdtc6eWHy3vdnUqUSFiVoe7UAOXfYvqJ2nea7hs9dj)A)V4qPiHmPkowpwBF)Mc6eWHAxhs5EuZHmb2XIJ1DsdSYHH2jY3HyXbKoe4bfeDSkFh6X9gm4Zagak8NvxWRpdWXFzupQHd1SZaC85m4yv(oe4rIt)obpKeTl2oKSKJSKZX6XQ8Di59Odicd(hRY3HEPd9YJPdLdqpUfsFng8HGQ)qWd5p6CixHGix4XNSEzbc6q5cEiJI9xct8AaoK2dt4mEOfwbryXXQ8DOx6qVOkmnhIRy)qqQ9wbK(044dLl4HKx97lSh1COucbjy7qa1WUFONYaCOWpuUGhspugs4NdbEGCQGhIRypvXXQ8DOx6qYVr7g6qyhgC)q8hIlzmGounhspuMADOCbLeFOyoK)qhIfr(7fhYRdbjGfNouRckPPuaXX6XQ8Di5NmeF5eWH6uUG0H41VR(H6eOyWIdXIW5uJJp0uZl9OWFEzoKY9Og8HQXWO4yv5Eudw0ajE97Q)MugOqUoKngNmgI7hRY3HE9jWhIPcdTBOdHBiEKdcFi)Ho0S(DcEOkFixHGihFi1puRNG)Ciz3YpuIdjvYdXIn6NWomKKWhQwooaOdv5djV63xypQ5q4NAzaouNo0ctaIJvL7rnyrdK41VR(BszatfgA3qSn6NK(uUf7qsL0Mn6NWomKKyRAKIjNTilLPcdTBiXt5wSdjvsB2OFc7WqssQCyJPAwKuz1oUAOXfzJ(jBJ68N3KT2HHUAOXfzJ(jBJ68NJv57qV(e4dXuHH2n0HWnepYbHpK)qhAw)obpuLpKRqqKJpK6hQ1tWFoKSRcboK8uSFiwSr)e2HHKe(q1YXbaDOkFi5v)(c7rnhc)uldWH60Hwyc4qk(q5WyiO4yv5Eudw0ajE97Q)MugWuHH2neBJ(jPpkeWYvSBZg9tyhgssSvnsXKZwKLYuHH2nK4rHawUIDB2OFc7WqssQCyJPAwKuz1oUAOXfzJ(jBJ68N3KT2HHUAOXfzJ(jBJ68NJv57qV(e4dXuHH2n0HWnepYbHpK)qhAw)obpuLpKRqqKJpK6hQ1tWFoKSB5hkXHKk5HyXg9tyhgss4dPq6qlmbCiGfmgqhsE1VVWEuJ4yv5Eudw0ajE97Q)MugWuHH2neBJ(jP863xypQXMn6NWomKKyRAKIjNTilLPcdTBibV(9f2JASzJ(jSddjjPYHnMQzrsLT2XvdnUiB0pzBuN)8g4TDyORgACr2OFY2Oo)5yv(o0Rpb(qmvyODdDiCdXJCq4d5p0HM1VtWdv5d5kee54dP(HA9e8NdXIa56qhs(jtJPWrnhQwooaOdv5djV63xypQ5q4NAzaouNo0ctaIJvL7rnyrdK41VR(BszatfgA3qSn6NKQqUoKLKPXu4Og2QgPyYzlYszQWq7gsOqUoKLKPXu4OgPYHnMQzrsFzVS2XvdnUiB0pzBuN)8MSAhg6QHgxKn6NSnQZFowLVd96tGpetfgA3qhc3q8ihe(q(dDOgcYPXvq0HQ8H(6OhQtMQ1HA9e8NdXIa56qhs(jtJPWrnhQvymhAk)qD6qlmbiowvUh1GfnqIx)U6VjLbmvyODdX2OFsQc56qwsMgtHJASFDu2aOSUmUuzVCyRAKcjm5hRY3HE9jWhIPcdTBOdf4dTWeWH86q4gIhzgpK)qhs)1A8dv5d5XNoumhct8AaWhYFu)q)f2puJIXhsZobpK8QFFH9OMdrY0eqcFOoLliDiwSr)e2HHKe(qTcJ5qD6qlmbCOPGF1yyuCSQCpQblAGeV(D1FtkdyQWq7gITr)KuaYOmAZg9tyhgssSbqzDzCPYHTQrkKWKFSkFhs2j8NdXIogatmGy7qYR(9f2JAyhFiEvgGQ1COwHXCOoDiibS4eWH6mEi9qqDaQ)H0FTgNTd1x(H8h6qZ63j4HQ8H4WWXhc7k0XhIjbz8qpbONdPzNGhs5EWu9yaDi5v)(c7rnhshGdHnvl8HaQwZH8QLcbWhYFOdrdWHQ8HKx97lSh1Wo(q8QmavRrCizNhAo0xLmgqhcG4boQbFOyoK)qhIfr(7fSDi5v)(c7rnSJpeK(AmXa6q8QmavR5qb(qqcyXjGd1z8q(tGpugQCpQ5qEDiLZR14hkxWdXIogatmGehRk3JAWIgiXRFx93KYaMkm0UHyB0pjvYyamXaYcjGf3JAydGY6Y4sLJq2Zw1ifsyYpwLVd96dDiGfu9OMdv5dPhkznhIfDmGyhFiWzimogqhsE1VVWEuJ4yv5Eudw0ajE97Q)MugWuHH2neBJ(jPyj7wGfu9Og2QgPyYzJPAwKuw4yv5Eudw0ajE97Q)MugWuHH2neBJ(jP863xypQXwJDHj2QgPyYzJPAwKuQ9wrtdbi(kx7qYIFiYT)fo4Gbg1EROPHaeFDImH9Ywz7xbgcJbdmQ9wrtdbiazuGq9cITDfaebgyu7TIMgcqaYOaH6feB)eGAmrnGbg1EROPHaebOj8Og7xbryBEHjWaJAVv00qacVDxhcB7kusCtmegmWO2BfnneGqB3xqYFkSfhdicW2ywFfebgyu7TIMgcqOdpOXTsoLBRSTvGbQpyGrT3kAAiab(P4s2dNGyBwhqGbg1EROPHaedTGQXIzC0gmzP5rhobbdmQ9wrtdbi6QHYbKSDOo8NJv57qYUvRdzQb0H6uUG0HKx97lSh1Ci8tTmahs(9ByesQ5qTFiWOdNouNo0ctaSO8yv5Eudw0ajE97Q)MugWuHH2neBJ(jP0VHriPgBbbgD4KfGmkJSbqzDzCPsaEYw1ifsyYpwLVdj7wToKPgqhQt5cshsE1VVWEuZHWp1YaCihgJKKJpK)O(HCyacebpKEi8JcjGdjl5CimXRb4qYd84HQ5qL)qWd5WyKKC8HMYpuNo0ctaSO8yv5Eudw0ajE97Q)MugWuHH2neBJ(jP1yxyYYxELZSvnsXKZgt1SiPYsoSfzPmvyODdj41VVWEuJTg7cthRk3JAWIgiXRFx93KYaMkm0UHyB0pjTg7ctw(YRCMTQrkMC2yQMfjvwSaBrwk1EROPHaeFLRDizXpe52)ch8JvL7rnyrdK41VR(BszatfgA3qSn6NKwJDHjlF5voZw1iftoBmvZIKkl58gtfgA3qc63WiKuJTGaJoCYcqgLr2ISuQ9wrtdbiOFdJqsn2ccm6WPJv57qV(qhAw)obpuLpKRqqKJpuYtK9yaDi5VQfbpe(PwgGd1PdTWeWHQ5qalymGoK8QFFH9OgXXQY9OgSObs863v)nPmGPcdTBi2g9ts51VVWEuJf)ezpgq2MQfbzdGY6Y4sLfBvJuiHj)yv5Eudw0ajE97Q)MugSWKnC6Z2OFskUwgBaAcNGhRk3JAWIgiXRFx93KYGFaHf0gFfeDSQCpQblAGeV(D1FtkdAyewDJID2ISug2ajMIggHv3Oy)y9yv(oK8tgIVCc4qetcY4H84thYFOdPCVGhkWhszQHr7gsCSQCpQblLxRXjiUHmg2ISugcxdLliisaeyE0yIrHmA51)RdWXQY9Og8BszatfgA3qSn6NK6XNSEz51VVWEudBvJum5SXunlsQRgACroGe2vOtW2jhqc7k0jOasFng8BPWRYauTgbV(9f2JAeq6RXGBNuK4LyQWq7gsizmaMyazHeWI7rnTJRgACHKXayIbuQP2omKxLbOAncE97lSh1iGKcWy70x5SGx)(c7rncGQ1CSkFhc8GkjDi8cshsE1VVWEuZHc8HaiJYibCOiFOHiac4qDftahQMd5p0HOFdJqsn2ccm6WjlazugpetfgA3qhRk3JAWVjLbmvyODdX2OFsQhFY6LLx)(c7rnSvns)QmSXunlsktfgA3qc63WiKuJTGaJoCYcqgLXxkfEvgGQ1iOFdJqsn2ccm6WjbWcQEuZlXRYauTgb9ByesQXwqGrhojG0xJbNA7WqEvgGQ1iOFdJqsn2ccm6WjbKuagzlYsP2BfnneGG(nmcj1yliWOdNowvUh1GFtkdyQWq7gITr)Kup(K1llV(9f2JAyRAK(vzyJPAwKuEvgGQ1iazuGq9cITDfaejG0xJbZwKLsT3kAAiabiJceQxqSTRaGOJvL7rn43KYaMkm0UHyB0pj1Jpz9YYRFFH9Og2QgPFvg2yQMfjTVYzbCnKTY2MQfbfq6RXGzlYsD1qJlGRHSv22uTiy6(kNf863xypQrauTMJvL7rn43KYaMkm0UHyB0pj1Jpz9YYRFFH9Og2QgPFvg2yQMfjLxLbOAnc4AiBLTnvlckG0xJb)wFLZc4AiBLTnvlckawq1JAylYsD1qJlGRHSv22uTiy6(kNf863xypQrauTM08QmavRraxdzRSTPArqbK(Am43yH3zQWq7gs4XNSEz51VVWEuZXQY9Og8Bsza(jYEmGSnvlcYwKL2x5SGx)(c7rncGQ1KMPcdTBiHhFY6LLx)(c7rnSmVmglKawCpQjDk8QmavRraxdzRSTPArqbK(AmywMxgJfsalUh1agym0vdnUaUgYwzBt1IGPMMHP0x5SiMmbh1y5kMRaKy1KUVYzXt5wSdjvsbKuUNA6uuUhmjln0pi87mvyODdj41VVWEuJf)ezpgq2MQfbbdmL7btYsd9dc)otfgA3qcE97lSh1yZg9tyhgssGbgtfgA3qcp(K1llV(9f2JAEP8YySqcyX9OgwYRYauTMupwvUh1GFtkdGkqOJBXnkus2IS0u6RCwWRFFH9Ogbq1As3x5SaUgYwzBt1IGcGQ1KofMkm0UHeE8jRxwE97lSh18ojdXxoz94tGbgtfgA3qcp(K1llV(9f2JAyjVkdq1Aeqfi0XT4gfkPaybvpQj1ubdSu6RCwaxdzRSTPArqXQjntfgA3qcp(K1llV(9f2JAyPSjNupwvUh1GFtkdai1F6fCi2IS0(kNf863xypQrauTM09volGRHSv22uTiOaOAnPzQWq7gs4XNSEz51VVWEuZ7KmeF5K1JpDSQCpQb)Mug8diSGyBLTEb)04SfzPmvyODdj84twVS863xypQ5DPYw6(kNf863xypQrauTMJv57qS4cEiwuqJ)WiKTdTW0H0dXIdiDiWzuSFi(JcbrhcybJb0HapeqybXhQYh61c(PXpexX(H86qkZkaoexBAIb0H4pkeeHpuKpu7BYeCuZHKNI5kaDOaFOP8dHjdXDcqCSQCpQb)MugKdiz7gf7STWKT1tyilxXEmGKkbBrwQY9OgXpGWcITv26f8tJlizi(YJbu68YySqI)OqqK1Jp9sk3JAe)acli2wzRxWpnUGKH4lNSq6RXGFx2NMHpLBXoKujT4gYyW2ySzta6XtZW(kNfpLBXoKujfqs5(XQY9Og8BszWpGWcAJVcIylYs7RCwWRFFH9Ogbq1Asdq9volGkqOJBXnkuslZLziO2dt4mkaQwZXQY9Og8BszWct2WPpBuotC3o6NKcYOaH6feB7kaiITilLPcdTBiHhFY6LLx)(c7rnSKxLbOAnVelCSQCpQb)MugSWKnC6Z2OFsk9ByesQXwqGrhoXwKLYuHH2nKWJpz9YYRFFH9OM3LYuHH2nKG(nmcj1yliWOdNSaKrz8yv5Eud(nPmyHjB40NTr)KuqggBESv2QyC8dJ6rnSfzPmvyODdj84twVS863xypQHLszQWq7gsuJDHjlF5voFSQCpQb)MugSWKnC6Z2OFs6x5Ahsw8drU9VWbNTilLPcdTBiHhFY6LLx)(c7rnVlLfowLVd1(YhAHJb0H0dHDcwbWHQ5Lwy6qHtF2oKAAPmIp0cthc8iKuGCaPdXIccJjZHQLJda6qv(qYR(9f2JAehQ97peSvGj2oudmky4T70Hw4yaDiWJqsbYbKoelkimMmhQv4phsE1VVWEuZHQXW4HI8HAFtMGJAoK8umxbOdf4drJ2neWH0b4q6HwyfeDOw1WUFOoDitH9dvmj4H8h6qalO6rnhQYhYFOdLdqpU4yv5Eud(nPmyHjB40NTr)KuaiPa5aswMegtg2ISuMkm0UHeE8jRxwE97lSh1WsPmvyODdjQXUWKLV8kNtNsFLZIyYeCuJLRyUcqcSRCjL2x5SiMmbh1y5kMRaK4RYyXUYLemWyiVgGv4IyYeCuJLRyUcqGbgtfgA3qcE97lSh1yRXUWeyGXuHH2nKWJpz9YYRFFH9OM3ybwMdqpUfsFngS8V8pVkdq1As9yv(ousTmhQ9bAcNGhc)uldWH60Hwyc4qXCi9qTugpK)O(HakcpS7hkgNGzcshQv4phQ8hcEOAEPfMoKdJrsYXId1(9hcEihgJKKJpeqDOP8d5WaeicEi9q4hfsahQ9jpWJhQMdfoBhcxhk8dX15qD6qlmbCiya6XpKMDcEiDy8qL)qWdvZlTW0HCymssU4yv5Eud(nPmyHjB40NTr)KuCTm2a0eobzlYszQWq7gs4XNSEz51VVWEudlLYuHH2nKOg7ctw(YRC(njyH2jfMkm0UHe1yxyYYxELZSuoPcgymvyODdj84twVS863xypQ5DjKZXQ8DOxHbiqe8qj1YCO2hOWj4HifAy8qTc)5qTVjtWrnhsEkMRa0Hk4HA9qZHc)qTu8HAGexXU4yv5Eud(nPmGRdNm2(kNzB0pjfxlJnanHh1WwKLYuHH2nKWJpz9YYRFFH9OgwkLPcdTBirn2fMS8Lx5CAMkm0UHeE8jRxwE97lSh1WsPsWcTd1EROPHaeaqsbYbKSmjmMmP94tVZcPziVgGv4IyYeCuJLRyUcqGbwFLZIyYeCuJLRyUcqcSRCjL2x5SiMmbh1y5kMRaK4RYyXUYL8yv(o0lh5hYFOdbeyE0yIrHmA51)RdWH6RC(qRg2o0AmegFiE97lSh1COaFiCvJ4yv5Eud(nPmGxRXjiUHmg2ISu4AOCbbrcGaZJgtmkKrlV(FDasZRYauTgrFLZwGaZJgtmkKrlV(FDaeqsbymDFLZcGaZJgtmkKrlV(FDaSkKRdjaQwtAg2x5SaiW8OXeJcz0YR)xhaXQjntfgA3qcp(K1llV(9f2JAyPSyHJvL7rn43KYafY1HSKmnMch1WwKLcxdLliisaeyE0yIrHmA51)RdqAEvgGQ1i6RC2ceyE0yIrHmA51)RdGaskaJP7RCwaeyE0yIrHmA51)RdGvHCDibq1AsZW(kNfabMhnMyuiJwE9)6aiwnPzQWq7gs4XNSEz51VVWEudlLflCSQCpQb)MugKHf27LXzlYsHRHYfeejacmpAmXOqgT86)1binVkdq1Ae9voBbcmpAmXOqgT86)1bqajfGX09volacmpAmXOqgT86)1bWMHf2favRjnd7RCwaeyE0yIrHmA51)RdGy1KMPcdTBiHhFY6LLx)(c7rnSuwSWXQY9Og8BszaxngRY9OgRjWoBJ(jP863xypQX28OyITilLPcdTBiHhFY6LLx)(c7rnVlvohRk3JAWVjLbmvyODdX2ct2kNTG4asLGTfMSTEcdz5k2JbKujyB0pjnhqY2nk2TnvzIbeBmvZIKYuHH2nKWJpz9YYRFFH9OMxs2Ex5EuJihqY2nk2f5LXyHe)rHGiRhF6LuUh1iWpr2JbKTPArqrEzmwibS4Eut7KcVkdq1Ae4Ni7XaY2uTiOasFng87mvyODdj84twVS863xypQj10mvyODdj84twVS863xypQ59Ca6XTq6RXGbdmxn04c4AiBLTnvlcMUVYzbCnKTY2MQfbfavRjnVkdq1AeW1q2kBBQweuaPVgd(DL7rnICajB3OyxKxgJfs8hfcISE8Pxs5EuJa)ezpgq2MQfbf5LXyHeWI7rnTtk8QmavRrGFIShdiBt1IGci91yWVZRYauTgbCnKTY2MQfbfq6RXGtnnVkdq1AeW1q2kBBQweuaPVgd(9Ca6XTq6RXGpwvUh1GFtkdyQWq7gITr)K0MNIMqgBtvMyaXgt1SiPmvyODdj84twVS863xypQ5DL7rnIMNIMqgB2OFclYlJXcj(Jcbrwp(0lPCpQrGFIShdiBt1IGI8YySqcyX9OM2jfEvgGQ1iWpr2JbKTPArqbK(Am43zQWq7gs4XNSEz51VVWEutQPzQWq7gs4XNSEz51VVWEuZ75a0JBH0xJbdgyW1q5ccIe41yLmgqyB3qyCmGadmp(07SWXQY9Og8BszaCnKTY2MQfbzlYs7RCwaxdzRSTPArqbq1AsZW(kNf5asyVGFbKuUNofMkm0UHeE8jRxwE97lSh1WsP9volGRHSv22uTiOaybvpQjntfgA3qcp(K1llV(9f2JAyPY9OgroGKTBuSlYlJXcj(Jcbrwp(eyGXuHH2nKWJpz9YYRFFH9OgwMdqpUfsFngCQhRk3JAWVjLbC1ySk3JASMa7Sn6NKcRgBZJIj2IS0(kNfW1q2kBBQweuSAsNctfgA3qcp(K1llV(9f2JAyPCs9yv(oKSZdnhs2vHaCf7Xa6qSyJ(PdL4WqsITdXIdiDiWzuSJpe(PwgGd1PdTWeWH86qGOHGQths2T8dL4qsLeFiDaoKxhIKXPb4qGZOyNGhc8GIDckowvUh1GFtkdYbKSDJID2wyYw5SfehqQeSTWKT1tyilxXEmGKkbBrwkdzQWq7gsKdiz7gf72MQmXakDkmvyODdj84twVS863xypQHLYbmWuUhmjln0pimlLYuHH2nK4rHawUIDB2OFc7WqskndZbKWUcDckuUhmP0mSVYzXt5wSdjvsbKuUNoL(kNfpK6XaYUAeqs5EAL7rnISr)e2HHKKGKH4lNSq6RXGFxocwamW4pkeeHTzOY9Og1WsPYk1upwLVdbECbJb0HyXbKWUcDcY2HyXbKoe4mk2XhsH0Hwyc4q44hgfAy8qEDiGfmgqhsE1VVWEuJ4qVC0qq1yyKTd5peJhsH0Hwyc4qEDiq0qq1Pdj7w(HsCiPsIpuRhAoehgo(qTcJ5qt5hQthQLIDc4q6aCOwH)CiWzuStWdbEqXobz7q(dX4HWp1YaCOoDiCdKuGdvl)qEDOVgJRXCi)Hoe4mk2j4HapOyNGhQVYzXXQY9Og8BszqoGKTBuSZ2ct2kNTG4asLGTfMSTEcdz5k2JbKujylYsZbKWUcDckuUhmP08hfcIWSuQePzitfgA3qICajB3Oy32uLjgqPtHHk3JAe5asD1yeKmeF5XakndvUh1iAyewDJIDrm2Sja94P7RCw8qQhdi7QrajL7GbMY9OgroGuxngbjdXxEmGsZW(kNfpLBXoKujfqs5oyGPCpQr0WiS6gf7IySzta6Xt3x5S4Hupgq2vJask3tZW(kNfpLBXoKujfqs5EQhRY3HyrywbWH4AttmGoeloG0HaNrX(H4pkeeHpuRNWqhI)OZqMyaDOKNi7Xa6qYFvlcESQCpQb)MugKdiz7gf7STWKT1tyilxXEmGKkbBrwQY9Ogb(jYEmGSnvlckizi(YJbu68YySqI)OqqK1Jp9UY9Ogb(jYEmGSnvlck8GlPfsalUh1KUVYzXt5wSdjvsbq1As7XNyPeY5yv5Eud(nPmGRgJv5EuJ1eyNTr)KuSRdGcbSWYvpQHTilnfMkm0UHeE8jRxwE97lSh1Ws5KA6(kNfW1q2kBBQweuauTMJvL7rn43KYamVG8NJ1JvL7rnyHY9GjzD1qJJLAcMXaY2RFNTilv5EWKS0q)GWSuI09vol41VVWEuJaOAnPtHPcdTBiHhFY6LLx)(c7rnSKxLbOAnctWmgq2E97cGfu9OgWaJPcdTBiHhFY6LLx)(c7rnVlvoPESQCpQbluUhmjRRgAC8BszWNCQGSfzPmvyODdj84twVS863xypQ5DPYbmWsHxLbOAnIp5ubfalO6rnVZuHH2nKWJpz9YYRFFH9OM0m0vdnUaUgYwzBt1IGPcgyUAOXfW1q2kBBQwemDFLZc4AiBLTnvlckwnPzQWq7gs4XNSEz51VVWEudlvUh1i(KtfuWRYauTgWalhGEClK(Am43zQWq7gs4XNSEz51VVWEuZXQY9OgSq5EWKSUAOXXVjLbaqfunyBhsQ)WwKL6QHgxOgsgSdvC7UIT5fKX0P0x5SGx)(c7rncGQ1KMH9volEk3IDiPskGKY9upwpwvUh1Gf863xypQXYRYauTgS0MYJAowvUh1Gf863xypQXYRYauTg8Bszq3ufGnVGmESQCpQbl41VVWEuJLxLbOAn43KYGobXeuYyaDSQCpQbl41VVWEuJLxLbOAn43KYGCaPUPkGJvL7rnybV(9f2JAS8QmavRb)MugOdNWounwUAmhRk3JAWcE97lSh1y5vzaQwd(nPmyHjB40hFSQCpQbl41VVWEuJLxLbOAn43KYGfMSHtF2wyYw5SfehqQeSr5mXD7OFskiJceQxqSTRaGi2ISuL7rnIp5ubfXyZMa0JBH0xJb)Uu5iyHJvL7rnybV(9f2JAS8QmavRb)Mug4XNSTuydBrwkCnuUGGiHt)McQgBlf2KUVYzbjZJUWEuJy1CSESQCpQbl41VVWEuJT5rXKuta6XXwwuxaG(04SfzP9vol41VVWEuJaOAnhRY3HKFyp(Qth6PADitnGoK8QFFH9OMd1kmMdzuSFi)rhjXhYRdLSMdXIogqSJpe4meghdOd51HaiNG)yOd9uToeloG0HaNrXo(q4NAzaouNo0ctaIJvL7rnybV(9f2JASnpkMEtkdyQWq7gITfMSvoBbXbKkbBlmzB9egYYvShdiPsW2OFskjJtdaby51VVWEuJfsFngmBvJum5SXunlsAFLZcE97lSh1iG0xJb)wFLZcE97lSh1iawq1JAANu4vzaQwJGx)(c7rnci91yWV3x5SGx)(c7rnci91yWPYwKLYRbyfUiMmbh1y5kMRa0XQ8Diweaa8H8h6qalO6rnhQYhYFOdLSMdXIogqSJpe4meghdOdjV63xypQ5qEDi)HoenahQYhYFOdXxqin(HKx97lSh1COiFi)HoexX(HAvldWH41VXqoDiGfmgqhYFc8HKx97lSh1iowvUh1Gf863xypQX28Oy6nPmGPcdTBi2wyYw5SfehqQeSTWKT1tyilxXEmGKkbBJ(jPKmonaeGLx)(c7rnwi91yWSvnsvaa2yQMfjLPcdTBibwYUfybvpQHTilLxdWkCrmzcoQXYvmxbO0P0x5SaVgRKXacB7gcJJbKfskaJIvdyGXuHH2nKGKXPbGaS863xypQXcPVgdMLsiyH2behq8vzANu6RCwGxJvYyaHTDdHXXas8vzSyx5s(s9volWRXkzmGW2UHW4yajWUYLm1upwvUh1Gf863xypQX28Oy6nPmORGSv26WGljMTilTVYzbV(9f2JAeavR5yv5EudwWRFFH9OgBZJIP3KYatWmgq2E97SfzPk3dMKLg6heMLsKUVYzbV(9f2JAeavR5yv(oKSt4p1Ypu7BYeCuZHKNI5kaX2HyrDH9dTW0HyXbKoe4mk2XhQ1dnhYFigpuRAy3p0Fn8NdXHHJpKoahQ1dnhIfhqc7f8FOaFiGQ1iowvUh1Gf863xypQX28Oy6nPmihqY2nk2zBHjBLZwqCaPsW2ct2wpHHSCf7XasQeSfzPPOCpyswAOFq43LQCpyswGYfbOjCcmWyiVkdq1AenpfnHm2Sr)ewajfGXutZqEnaRWfXKj4OglxXCfGsZFuiicZsPsKUVYzbV(9f2JAeRM0mSVYzroGe2l4xajL7PzyFLZINYTyhsQKciPCp9t5wSdjvslUHmgSngB2eGE836RCw8qQhdi7QrajL7VlRJv57qYoH)CO23Kj4OMdjpfZvaITdXIdiDiWzuSFOfMoe(PwgGd1PdPaaHh1OggpeVgSd1yiGdHRd5pQFOWpuGp0u(H60Hwyc4qRXqy8HAFtMGJAoK8umxbOdf4dP9A5hYRdrY0eq6qf8q(dbPdPq6q)cshYF05q0ulqphIfhq6qGZOyhFiVoejJtdWHAFtMGJAoK8umxbOd51H8h6q0aCOkFi5v)(c7rnIJvL7rnybV(9f2JASnpkMEtkdyQWq7gITfMSvoBbXbKkbBlmzB9egYYvShdiPsW2OFskjtdXDcWMdiz7gf7y2QgPyYzJPAwKuL7rnICajB3OyxWFuiicBZqL7rnQ5TuyQWq7gsqY40aqawE97lSh1yH0xJb)s9volIjtWrnwUI5kajawq1JAsv(NxLbOAnICajB3OyxaSGQh1WwKLYRbyfUiMmbh1y5kMRa0XQY9OgSGx)(c7rn2MhftVjLbmvyODdX2ct2kNTG4asLGTfMSTEcdz5k2JbKujyB0pjDicGaS5as2UrXoMTQrkMC2yQMfjLtHjfMkm0UHeKmonaeGLx)(c7rnwi91yWY)P0x5SiMmbh1y5kMRaKaybvpQ5LaXbeFvMutLTilLxdWkCrmzcoQXYvmxbOJvL7rnybV(9f2JASnpkMEtkdYbKSDJID2wyYw5SfehqQeSTWKT1tyilxXEmGKkbBrwAkk3dMKLg6he(DPk3dMKfOCraAcNadmgYRYauTgrZtrtiJnB0pHfqsbym108AawHlIjtWrnwUI5kaLM)OqqeMLsLiDkmvyODdjizAiUta2CajB3OyhZsPmvyODdjgIaiaBoGKTBuSJbdmMkm0UHeKmonaeGLx)(c7rnwi91yWVlTVYzrmzcoQXYvmxbibWcQEudyG1x5SiMmbh1y5kMRaKa7kxY3LfyG1x5SiMmbh1y5kMRaKasFng87G4aIVkdyGXRYauTgb(jYEmGSnvlckGKcWyAL7btYsd9dcZsPmvyODdj41VVWEuJf)ezpgq2MQfbtZlM0OJlMa0JBZkLA6(kNf863xypQrSAsNcd7RCwKdiH9c(fqs5oyG1x5SiMmbh1y5kMRaKasFng87YrWcPMMH9volEk3IDiPskGKY90pLBXoKujT4gYyW2ySzta6XFRVYzXdPEmGSRgbKuU)USowvUh1Gf863xypQX28Oy6nPmGxRXjiUHmg2ISu4AOCbbrcGaZJgtmkKrlV(FDas3x5SaiW8OXeJcz0YR)xhabq1As3x5SaiW8OXeJcz0YR)xhaRc56qcGQ1KMxLbOAnI(kNTabMhnMyuiJwE9)6aiGKcWyAg6QHgxaxdzRSTPArWJvL7rnybV(9f2JASnpkMEtkduixhYsY0ykCudBrwkCnuUGGibqG5rJjgfYOLx)VoaP7RCwaeyE0yIrHmA51)RdGaOAnP7RCwaeyE0yIrHmA51)RdGvHCDibq1AsZRYauTgrFLZwGaZJgtmkKrlV(FDaeqsbymndD1qJlGRHSv22uTi4XQY9OgSGx)(c7rn2MhftVjLbzyH9EzC2ISu4AOCbbrcGaZJgtmkKrlV(FDas3x5SaiW8OXeJcz0YR)xhabq1As3x5SaiW8OXeJcz0YR)xhaBgwyxauTMJvL7rnybV(9f2JASnpkMEtkdYWc72PyQSfzPW1q5ccIeGGb2WOn4b3qP7RCwWRFFH9Ogbq1AowvUh1Gf863xypQX28Oy6nPmGRgJv5EuJ1eyNTr)KuL7btY6QHghFSQCpQbl41VVWEuJT5rX0BszaV(9f2JAyBHjBLZwqCaPsW2ct2wpHHSCf7XasQeSfzP9vol41VVWEuJaOAnPtHHW1q5ccIeabMhnMyuiJwE9)6aagy9volacmpAmXOqgT86)1bqSAadS(kNfabMhnMyuiJwE9)6ayZWc7IvtAxn04c4AiBLTnvlcMMxLbOAnI(kNTabMhnMyuiJwE9)6aiGKcWyQPtHHW1q5ccIeGGb2WOn4b3qGbga1x5SaemWggTbp4gsSAsnDkk3JAeFYPckIXMnbOhpTY9OgXNCQGIySzta6XTq6RXGFxQCeGxWat5EuJaZli)rqYq8LhdO0k3JAeyEb5pcsgIVCYcPVgd(D5iaVGbMY9OgroGuxngbjdXxEmGsRCpQrKdi1vJrqYq8Ltwi91yWVlhb4fmWuUh1iAyewDJIDbjdXxEmGsRCpQr0WiS6gf7csgIVCYcPVgd(D5iaVGbMY9Ogr2OFc7WqssqYq8LhdO0k3JAezJ(jSddjjbjdXxozH0xJb)UCeG3upwLVd1(9hcEiEvgGQ1GpK)O(HWp1YaCOoDOfMaouRWFoK8QFFH9OMdHFQLb4q1yy8qD6qlmbCOwH)CiDoKY9LAoK8QFFH9OMdXvSFiDao0u(HAf(ZH0dLSMdXIogqSJpe4meghdOd1alU4yv5EudwWRFFH9OgBZJIP3KYaUAmwL7rnwtGD2g9ts51VVWEuJLxLbOAny2IS0(kNf863xypQryuSBjzAci9UuL7rncE97lSh1imk2TlmbCSQCpQbl41VVWEuJT5rX0Bszq2OFc7WqsITilnL(kNfpLBXoKujfqs5oyG1x5Sihqc7f8lGKY9utRCpyswAOFqywkLPcdTBibV(9f2JASzJ(jSddjPJvL7rnybV(9f2JASnpkMEtkdAyewDJID2IS0(kNf41yLmgqyB3qyCmGSqsbyuSAs3x5SaVgRKXacB7gcJJbKfskaJci91yWSKRy36XNowvUh1Gf863xypQX28Oy6nPmOHry1nk2zlYs7RCwKdiH9c(fqs5(XQY9OgSGx)(c7rn2MhftVjLbnmcRUrXoBrwAFLZIggHf3O4Vask3t3x5SOHryXnk(lG0xJbZsUIDRhFkDk9vol41VVWEuJasFngml5k2TE8jWaRVYzbV(9f2JAeavRj10k3dMKLg6he(DMkm0UHe863xypQXMn6NWomKKowvUh1Gf863xypQX28Oy6nPmOHry1nk2zlYs7RCw8uUf7qsLuajL7P7RCwWRFFH9OgXQ5yv5EudwWRFFH9OgBZJIP3KYGggHv3OyNTilTbsmTG4acjeyEb5pP7RCw8qQhdi7QrajL7PvUhmjln0pi87mvyODdj41VVWEuJnB0pHDyijDSkFh6LhhdOdL8ezpgqhs(RArWdbSGXa6qYR(9f2JAoKxhcsyVG0HyXbKoe4mk2pKoahs(7POjK5qSyJ(PdXFuiicFiUohQthQtdLdEOg2ouF5hAHxQXW4HQXW4HQ5qSiL8tCSQCpQbl41VVWEuJT5rX0Bsza(jYEmGSnvlcYwKL2x5SGx)(c7rnIvtAgQCpQrKdiz7gf7c(Jcbr40k3dMKLg6heMLszQWq7gsWRFFH9Ogl(jYEmGSnvlcMw5EuJO5POjKXMn6NWI8YySqI)OqqK1JpXY8YySqcyX9Og2IXjiC142ilv5EuJihqY2nk2f8hfcIWsvUh1iYbKSDJIDXxLXYFuiicFSQCpQbl41VVWEuJT5rX0BszqZtrtiJnB0pHzlYs7RCwWRFFH9OgXQjDkPOCpQrKdiz7gf7c(Jcbr43LiTRgACrdJWIBu8pTY9GjzPH(bHLkrQGbgdD1qJlAyewCJI)GbMY9GjzPH(bHzPePMUVYzXdPEmGSRgbKuU)2t5wSdjvslUHmgSngB2eGE83L1XQY9OgSGx)(c7rn2MhftVjLbzJ(jSddjj2IS0(kNf863xypQrauTM08QmavRrWRFFH9OgbK(Am435k2TE8P0k3dMKLg6heMLszQWq7gsWRFFH9OgB2OFc7Wqs6yv5EudwWRFFH9OgBZJIP3KYGCaPUAmSfzP9vol41VVWEuJaOAnP5vzaQwJGx)(c7rnci91yWVZvSB94tPziVgGv4ISr)Kv5Ci5rnhRk3JAWcE97lSh1yBEum9MugG5fK)WwKL2x5SGx)(c7rnci91yWSKRy36XNs3x5SGx)(c7rnIvdyG1x5SGx)(c7rncGQ1KMxLbOAncE97lSh1iG0xJb)oxXU1JpDSQCpQbl41VVWEuJT5rX0BszGjygdiBV(D2IS0(kNf863xypQraPVgd(DqCaXxLjTY9GjzPH(bHzPehRk3JAWcE97lSh1yBEum9Mugaavq1GTDiP(dBrwAFLZcE97lSh1iG0xJb)oioG4RYKUVYzbV(9f2JAeRMJvL7rnybV(9f2JASnpkMEtkdW8cYFylYsDfcICXdPg)r0W93LkBYjTRgACbMuymGSET4phRhRk3JAWcy1yBEumjnB0pHDyijXwKLQCpyswAOFqywkLPcdTBiXt5wSdjvsB2OFc7WqskDk9volEk3IDiPskGKYDWaRVYzroGe2l4xajL7PESQCpQblGvJT5rX0BszqdJWQBuSZwKL2x5SaVgRKXacB7gcJJbKfskaJIvt6(kNf41yLmgqyB3qyCmGSqsbyuaPVgdMLCf7wp(0XQY9OgSawn2MhftVjLbnmcRUrXoBrwAFLZICajSxWVask3pwvUh1GfWQX28Oy6nPmOHry1nk2zlYs7RCw8uUf7qsLuajL7hRY3HE5X0HQHoeloG0HaNrX(HifAy8qXCO2Ts(7qr(qmwRdbud7(HEuM0HOWFi4HKDj1Jb0HE5BoubpKSB5hkXHKk5HyK8dPdWHOWFii4FOu0up0JYKo0VG0H8hDoK3QoKAGKcWiBhkLEQh6rzshIfXqYGDOIB3v2XhIfVGmEiiPamEiVo0ctSDOcEOu4PEOesHXa6qVwl(ZHc8HuUhmjXHapwd7(HaQd5pb(qTEcdDOhfcCiUI9yaDiwSr)Kddjj8Hk4HA9qZHswZHyrhdi2XhcCgcJJb0Hc8HGKcWO4yv5EudwaRgBZJIP3KYGCajB3OyNTfMSvoBbXbKkbBlmzB9egYYvShdiPsWwKLYqMkm0UHe5as2UrXUTPktmGs3x5SaVgRKXacB7gcJJbKfskaJcGQ1Kw5EWKS0q)GWVZuHH2nK4rHawUIDB2OFc7WqskndZbKWUcDckuUhmP0PWW(kNfpK6XaYUAeqs5EAg2x5S4PCl2HKkPask3tZWgiX0w5SfehqKdiz7gf7Ptr5EuJihqY2nk2f8hfcIWSuQSadSuC1qJludjd2HkUDxX28cYyAEvgGQ1iaGkOAW2oKu)rajfGXubdSuC1qJlWKcJbK1Rf)jTRqqKlEi14pIgU)UuztoPMAQhRY3HE5X0HyXbKoe4mk2pef(dbpeWcgdOdPhIfhqQRgddK)yewDJI9dXvSFOwp0Cizxs9yaDOx(Mdf4dPCpyshQGhcybJb0Hizi(YPd1k8NdLqkmgqh61AXFehRk3JAWcy1yBEum9MugKdiz7gf7STWKTYzlioGujyBHjBRNWqwUI9yajvc2ISugYuHH2nKihqY2nk2TnvzIbuAgMdiHDf6euOCpysPtjLuuUh1iYbK6QXiizi(YJbu6uuUh1iYbK6QXiizi(YjlK(Am43LJGfadmgcxdLliisKdiH9c(tfmWuUh1iAyewDJIDbjdXxEmGsNIY9OgrdJWQBuSlizi(YjlK(Am43LJGfadmgcxdLliisKdiH9c(tn109volEi1JbKD1iGKY9ubdSuC1qJlWKcJbK1Rf)jTRqqKlEi14pIgU)UuztoPtPVYzXdPEmGSRgbKuUNMHk3JAeyEb5pcsgIV8yabgymSVYzXt5wSdjvsbKuUNMH9volEi1JbKD1iGKY90k3JAeyEb5pcsgIV8yaLMHpLBXoKujT4gYyW2ySzta6Xtn1upwvUh1GfWQX28Oy6nPmGRgJv5EuJ1eyNTr)KuL7btY6QHghFSQCpQblGvJT5rX0BszqdJWQBuSZwKL2x5SOHryXnk(lGKY90Cf7wp(079volAyewCJI)ci91yWP5k2TE8P37RCwaxdzRSTPArqbK(Am4JvL7rnybSASnpkMEtkdAyewDJID2IS0giX0cIdiKqG5fK)KUVYzXdPEmGSRgbKuUN2vdnUatkmgqwVw8N0UcbrU4HuJ)iA4(7sLn5Kw5EWKS0q)GWVZuHH2nK4PCl2HKkPnB0pHDyijDSQCpQblGvJT5rX0BszqZtrtiJnB0pHzlYszitfgA3qIMNIMqgBtvMyaLUVYzXdPEmGSRgbKuUNMH9volEk3IDiPskGKY90POCpyswGYfbOjC6Dzbgyk3dMKLg6heMLszQWq7gs8OqalxXUnB0pHDyijbgyk3dMKLg6heMLszQWq7gs8uUf7qsL0Mn6NWomKKs9yv5EudwaRgBZJIP3KYamVG8h2ISuxHGix8qQXFenC)DPYMCs7QHgxGjfgdiRxl(ZXQY9OgSawn2MhftVjLbaqfunyBhsQ)WwKLQCpyswAOFqywkRJvL7rnybSASnpkMEtkduixhYsY0ykCudBrwQY9GjzPH(bHzPuMkm0UHekKRdzjzAmfoQj9xhv0WDwkLPcdTBiHc56qwsMgtHJASFD0JvL7rnybSASnpkMEtkdYg9tyhgssSfzPk3dMKLg6heMLszQWq7gs8OqalxXUnB0pHDyijDSQCpQblGvJT5rX0BszqoGuxnMJ1JvL7rnyb21bqHawy5Qh1inB0pHDyijXwKLQCpyswAOFqywkLPcdTBiXt5wSdjvsB2OFc7WqskDk9volEk3IDiPskGKYDWaRVYzroGe2l4xajL7PESQCpQblWUoakeWclx9OM3KYGggHv3OyNTilTVYzroGe2l4xajL7hRk3JAWcSRdGcbSWYvpQ5nPmOHry1nk2zlYs7RCw8uUf7qsLuajL7P7RCw8uUf7qsLuaPVgd(DL7rnICaPUAmcsgIVCY6XNowvUh1GfyxhafcyHLREuZBszqdJWQBuSZwKL2x5S4PCl2HKkPask3tNsdKyAbXbesiYbK6QXagy5asyxHobfk3dMeyGPCpQr0WiS6gf7IySzta6Xt9yv(o0RqgpKxhce5hkHfn4oudS44dfdoaOd1UvYFhQ5rXe(qf8qYR(9f2JAouZJIj8HA9qZHAkmo6gsCSQCpQblWUoakeWclx9OM3KYGggHv3OyNTilTVYzbEnwjJbe22neghdilKuagfRM0PWRYauTgbCnKTY2MQfbfq6RXGFt5EuJaUgYwzBt1IGcsgIVCY6XNEJRy36XNyzFLZc8ASsgdiSTBimogqwiPamkG0xJbdgym0vdnUaUgYwzBt1IGPMMPcdTBiHhFY6LLx)(c7rnVXvSB94tSSVYzbEnwjJbe22neghdilKuagfq6RXGpwvUh1GfyxhafcyHLREuZBszqdJWQBuSZwKL2x5S4PCl2HKkPask3t7kee5Ihsn(JOH7Vlv2KtAxn04cmPWyaz9AXFowvUh1GfyxhafcyHLREuZBszqdJWQBuSZwKL2x5SOHryXnk(lGKY90Cf7wp(079volAyewCJI)ci91yWhRY3HapUGXa6q(dDiSRdGcboeSC1JAy7q1yy8qlmDiwCaPdboJID8HA9qZH8hIXdPq6qt5hQtXa6qnvziGdLl4HA3k5VdvWdjV63xypQrCOxEmDiwCaPdboJI9drH)qWdbSGXa6q6HyXbK6QXWa5pgHv3Oy)qCf7hQ1dnhs2Lupgqh6LV5qb(qk3dM0Hk4HawWyaDisgIVC6qTc)5qjKcJb0HETw8hXXQY9OgSa76aOqalSC1JAEtkdYbKSDJID2wyYw5SfehqQeSTWKT1tyilxXEmGKkbBrwkdZbKWUcDckuUhmP0mKPcdTBiroGKTBuSBBQYedO0PKskk3JAe5asD1yeKmeF5XakDkk3JAe5asD1yeKmeF5KfsFng87YrWcGbgdHRHYfeejYbKWEb)Pcgyk3JAenmcRUrXUGKH4lpgqPtr5EuJOHry1nk2fKmeF5KfsFng87YrWcGbgdHRHYfeejYbKWEb)PMA6(kNfpK6XaYUAeqs5EQGbwkUAOXfysHXaY61I)K2viiYfpKA8hrd3FxQSjN0P0x5S4Hupgq2vJask3tZqL7rncmVG8hbjdXxEmGadmg2x5S4PCl2HKkPask3tZW(kNfpK6XaYUAeqs5EAL7rncmVG8hbjdXxEmGsZWNYTyhsQKwCdzmyBm2Sja94PMAQhRk3JAWcSRdGcbSWYvpQ5nPmOHry1nk2zlYsBGetlioGqcbMxq(t6(kNfpK6XaYUAeqs5EAxn04cmPWyaz9AXFs7kee5Ihsn(JOH7Vlv2KtAL7btYsd9dc)otfgA3qINYTyhsQK2Sr)e2HHK0XQY9OgSa76aOqalSC1JAEtkdAEkAczSzJ(jmBrwkdzQWq7gs08u0eYyBQYedO0PWqxn04ImS(w)HSk(HWGbMY9GjzPH(bHzPePMofL7btYcuUianHtVllWat5EWKS0q)GWSuktfgA3qIhfcy5k2TzJ(jSddjjWat5EWKS0q)GWSuktfgA3qINYTyhsQK2Sr)e2HHKuQhRk3JAWcSRdGcbSWYvpQ5nPmGRgJv5EuJ1eyNTr)KuL7btY6QHghFSQCpQblWUoakeWclx9OM3KYaaOcQgSTdj1FylYsvUhmjln0pimlL4yv5EudwGDDauiGfwU6rnVjLbyEb5pSfzPUcbrU4HuJ)iA4(7sLn5K2vdnUatkmgqwVw8NJv57qYoH)CiAQfONd5kee5y2ou4hkWhspeinMd51H4k2pel2OFc7Wqs6qk(q5Wyi4HIb7KcCOkFiwCaPUAmIJvL7rnyb21bqHawy5Qh18MugOqUoKLKPXu4Og2ISuL7btYsd9dcZsPmvyODdjuixhYsY0ykCut6VoQOH7SuktfgA3qcfY1HSKmnMch1y)6OhRk3JAWcSRdGcbSWYvpQ5nPmiB0pHDyijXwKLQCpyswAOFqywkLPcdTBiXJcbSCf72Sr)e2HHK0XQY9OgSa76aOqalSC1JAEtkdYbK6QXStWneF3g4v22(23Ba]] )

end
