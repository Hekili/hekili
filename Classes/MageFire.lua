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


    spec:RegisterPack( "Fire", 20201225, [[deLFrdqiuGhjsQUKcvHnjs9jukJIOQtjsSkfQ4vQszwOuDlfQQDr4xOGggrLogryzefEgrrMgrr11avLTHsO(McvPXbQQ4CGQkToucMNQuDpI0(qj6FGQQIoiOQkleuLhksYevLOQlksk2ikH8rvjknsrsjNuvIyLOKEjOQQAMQs4MQsuStfk)uvI0qjkkTufQIEQiMQQKUQQev2kOQQ0xjkkglrf7vP(lLgmKdtAXk6XOAYGCzKnlQpdkJwvCAHvdQQk8AIOztXTvv7wQFlz4k44kuPLd8COMovxxjBhf9DfY4jkDEuO1lsk18bv2VkVLy)6obsDApMmKRmKReYqgWNqc4tMgVYqMVtCghODYGYLuHr7Kw)0oHffaANmOmAkfA)6obxlaN2jpUpGzbgYqyH)SMcE9zio(lJ6r1CGMDgIJpNH7K5km(lP3ZDcK60EmzixzixjKHmGpHeWNmnELHmTt0L)uGDss8t1o5jGGOEp3jqeMVts9dXIcaDOxgfgDSM6h6LN40FsGdjd4J9djd5kd5ESESM6hkvpAdJWSWXAQFOX)qVCy6q5a2JBb0xJgFiG6pe4q(J2hYvamYfE8jRxwOGouUahYOyF8XeVAOdPZWeoJhAHvyewCSM6hA8p0lQct9H4k2peGg3vaOp1o(q5cCOuv)5c7r1hs(qqc2peu1S5h6Pmqhk8dLlWH0dLbe(5qVmKtf4qCf7Piowt9dn(hk1060qhc7GG7hI)qCjJg2HQ(q6HY0OdLlGK4df9H8h6qWFYSV4qEDiabT40HgvajnLcj2jMa749R7eqnyhEumTFDpMe7x3juRtdbTH3oHdcNaHUtuUhmjl10pi8HyP0dXubHonK4PCl2bKkPnB0pHDqijDO0hs(dnx5S4PCl2bKkPaqk3peCWDO5kNf5aqyVaFbGuUFOu2jk3JQ3jzJ(jSdcjPTVhtg7x3juRtdbTH3oHdcNaHUtMRCwGxTvYOHHTtdHXrdZcifIrXA4qPp0CLZc8QTsgnmSDAimoAywaPqmka0xJgFiwEiUIDRhFANOCpQENmWiOMgf7BFpMmTFDNqTone0gE7eoiCce6ozUYzroae2lWxaiL77eL7r17Kbgb10OyF77XK57x3juRtdbTH3oHdcNaHUtMRCw8uUf7asLuaiL77eL7r17Kbgb10OyF77XGV9R7eQ1PHG2WBNSWKD0tyilxXE0W2JjXoHdcNaHUtyWHyQGqNgsKdazNgf72HQmrd7qPp0CLZc8QTsgnmSDAimoAywaPqmkGQr9HsFiL7btYsn9dcFO3petfe60qIhfaz5k2TzJ(jSdcjPdL(qm4q5aqyxbobek3dM0HsFi5pedo0CLZIhs9OHzxdcaPC)qPpedo0CLZINYTyhqQKcaPC)qPpedo0aGyARC2cJdjYbGStJI9dL(qYFiL7r1ICai70OyxWFuamcFiwk9qY4qWb3HK)qUAO2fQHKf7afNARyBEbyuqTone0HsFiEvgOAulGakSQX2jGu)raifIXdLYHGdUdj)HC1qTlWKcIgM1Rf)rqTone0HsFixbWix8qQXFedC)qVl9qYKCpukhkLdLYozHjBLZwyCO9ysStuUhvVtYbGStJI9TVhJfVFDNqTone0gE7KfMSJEcdz5k2Jg2Emj2jCq4ei0Dcdoetfe60qICai70Oy3ouLjAyhk9HyWHYbGWUcCciuUhmPdL(qYFi5pK8hs5EuTihaAQgJGKL4lpAyhk9HK)qk3JQf5aqt1yeKSeF5KfqFnA8HE)qYvaFhco4oedoey1uUaWiroae2lWxqTone0Hs5qWb3HuUhvlgyeutJIDbjlXxE0Wou6dj)HuUhvlgyeutJIDbjlXxozb0xJgFO3pKCfW3HGdUdXGdbwnLlamsKdaH9c8fuRtdbDOuoukhk9HMRCw8qQhnm7AqaiL7hkLdbhChs(d5QHAxGjfenmRxl(JGADAiOdL(qUcGrU4HuJ)ig4(HEx6HKj5EO0hs(dnx5S4HupAy21Gaqk3pu6dXGdPCpQwG5fG)iizj(YJg2HGdUdXGdnx5S4PCl2bKkPaqk3pu6dXGdnx5S4HupAy21Gaqk3pu6dPCpQwG5fG)iizj(YJg2HsFigCONYTyhqQKw8azmyB02SjG94hkLdLYHszNSWKTYzlmo0Emj2jk3JQ3j5aq2PrX(23JnE3VUtOwNgcAdVDIY9O6DcxngRY9OARjW(oXey326N2jk3dMK1vd1oE77XGF2VUtOwNgcAdVDcheobcDNmx5SyGrqXnk(laKY9dL(qCf7wp(0HE)qZvolgyeuCJI)ca91OXhk9H4k2TE8Pd9(HMRCwawnzRSDOgrabG(A04DIY9O6DYaJGAAuSV99yWV7x3juRtdbTH3oHdcNaHUtgaetlmoKqcbMxa(ZHsFO5kNfpK6rdZUgeas5(HsFixnu7cmPGOHz9AXFeuRtdbDO0hYvamYfpKA8hXa3p07spKmj3dL(qk3dMKLA6he(qVFiMki0PHepLBXoGujTzJ(jSdcjPDIY9O6DYaJGAAuSV99ysi39R7eQ1PHG2WBNWbHtGq3jm4qmvqOtdjgEkQdzTdvzIg2HsFO5kNfpK6rdZUgeas5(HsFigCO5kNfpLBXoGujfas5(HsFi5pKY9GjzHkxeW6WPd9(HKXHGdUdPCpyswQPFq4dXsPhIPccDAiXJcGSCf72Sr)e2bHK0HGdUdPCpyswQPFq4dXsPhIPccDAiXt5wSdivsB2OFc7Gqs6qPStuUhvVtgEkQdzTzJ(j823JjHe7x3juRtdbTH3oHdcNaHUtCfaJCXdPg)rmW9d9U0djtY9qPpKRgQDbMuq0WSET4pcQ1PHG2jk3JQ3jyEb4pBFpMeYy)6oHADAiOn82jCq4ei0DIY9GjzPM(bHpelpKm2jk3JQ3jqafw1y7eqQ)S99ysit7x3juRtdbTH3oHdcNaHUtuUhmjl10pi8HyP0dXubHonKqbCTjlj7GPWr1hk9H(ARIbUFiwk9qmvqOtdjuaxBYsYoykCuT9RTUtuUhvVtuaxBYsYoykCu923JjHmF)6oHADAiOn82jCq4ei0DIY9GjzPM(bHpelLEiMki0PHepkaYYvSBZg9tyhess7eL7r17KSr)e2bHK023Jjb8TFDNOCpQENKdanvJzNqTone0gEBF77eikRlJVFDpMe7x3juRtdbTH3oHdcNaHUtyWHaRMYfagjGcmpgmrRagT86)1gsqTone0or5Eu9oHxR2jaEGmMTVhtg7x3juRtdbTH3oPg2jyY3jk3JQ3jmvqOtdTtyQMfTtC1qTlYbGWUcCciOwNgc6qJZHYbGWUcCcia0xJgFO3oK8hIxLbQg1cE9NlShvla0xJgFOX5qYFijo04FiMki0PHesgnKjAywabT4Eu9HgNd5QHAxiz0qMOHjOwNgc6qPCOuo04CigCiEvgOAul41FUWEuTaqkeJhACo0CLZcE9NlShvlGQr9oHPcST(PDIhFY6LLx)5c7r1BFpMmTFDNqTone0gE7KAyN8vz3jk3JQ3jmvqOtdTtyQMfTtyQGqNgsq)bgbKASfaQ1MtwiYOmEOX)qYFiEvgOAulO)aJasn2ca1AZjb0cOEu9Hg)dXRYavJAb9hyeqQXwaOwBoja0xJgFOuo04CigCiEvgOAulO)aJasn2ca1AZjbGuig3jCq4ei0DcnURyyGGe0FGraPgBbGAT50oHPcST(PDIhFY6LLx)5c7r1BFpMmF)6oHADAiOn82j1Wo5RYUtuUhvVtyQGqNgANWunlANWRYavJAbmJcfQxaSDQqWibG(A04DcheobcDNqJ7kggiibmJcfQxaSDQqWODctfyB9t7ep(K1llV(Zf2JQ3(Em4B)6oHADAiOn82j1Wo5RYUtuUhvVtyQGqNgANWunlANmx5SaSAYwz7qnIaca91OX7eoiCce6oXvd1UaSAYwz7qnIacQ1PHGou6dnx5SGx)5c7r1cOAuVtyQaBRFAN4XNSEz51FUWEu923JXI3VUtOwNgcAdVDsnSt(QS7eL7r17eMki0PH2jmvZI2j8Qmq1OwawnzRSDOgrabG(A04d92HMRCwawnzRSDOgrab0cOEu9oHdcNaHUtC1qTlaRMSv2ouJiGGADAiOdL(qZvol41FUWEuTaQg1hk9H4vzGQrTaSAYwz7qnIaca91OXh6TdbFh69dXubHonKWJpz9YYR)CH9O6DctfyB9t7ep(K1llV(Zf2JQ3(ESX7(1Dc160qqB4Tt4GWjqO7K5kNf86pxypQwavJ6dL(qmvqOtdj84twVS86pxypQ(qS8q5LXybe0I7r1hk9HK)q8Qmq1OwawnzRSDOgrabG(A04dXYdLxgJfqqlUhvFi4G7qm4qUAO2fGvt2kBhQreqqTone0Hs5qPpedoK8hAUYzr0zc0QXYvmxHiXA4qPp0CLZINYTyhqQKcaPC)qPCO0hs(dPCpyswQPFq4d9(HyQGqNgsWR)CH9OAl(jYE0WSd1icCi4G7qk3dMKLA6he(qVFiMki0PHe86pxypQ2Mn6NWoiKKoeCWDiMki0PHeE8jRxwE9NlShvFOX)q5LXybe0I7r1hILhs5EuTLxLbQg1hkLDIY9O6Dc(jYE0WSd1icS99yWp7x3juRtdbTH3oHdcNaHUtK)qZvol41FUWEuTaQg1hk9HMRCwawnzRSDOgrabunQpu6dj)HyQGqNgs4XNSEz51FUWEu9HE)qKSeF5K1JpDi4G7qmvqOtdj84twVS86pxypQ(qS8q8Qmq1OwauOqB3IhuGKcOfq9O6dLYHs5qWb3HK)qZvolaRMSv2ouJiGynCO0hIPccDAiHhFY6LLx)5c7r1hILhsMK7HszNOCpQENauOqB3IhuGKBFpg87(1Dc160qqB4Tt4GWjqO7K5kNf86pxypQwavJ6dL(qZvolaRMSv2ouJiGaQg1hk9HyQGqNgs4XNSEz51FUWEu9HE)qKSeF5K1JpTtuUhvVtGi1FMfOPTVhtc5UFDNqTone0gE7eoiCce6oHPccDAiHhFY6LLx)5c7r1h6DPhsMou6dnx5SGx)5c7r1cOAuVtuUhvVt(bauaSTYwVaFQ9TVhtcj2VUtOwNgcAdVDYct2rpHHSCf7rdBpMe7eL7r17KCai70OyFNWbHtGq3jk3JQf)aaka2wzRxGp1UGKL4lpAyhk9HYlJXci(JcGrwp(0Hg)dPCpQw8daOayBLTEb(u7cswIVCYcOVgn(qVFiz(HsFigCONYTyhqQKw8azmyB02SjG94hk9HyWHMRCw8uUf7asLuaiL7BFpMeYy)6oHADAiOn82jCq4ei0DYCLZcE9NlShvlGQr9HsFiiAUYzbqHcTDlEqbsAzUmnb0zycNrbunQpu6dnx5SaSAYwz7qnIacOAuVtuUhvVt(bauaB8vy023JjHmTFDNqTone0gE7eL7r17eygfkuVay7uHGr7eoiCce6oHPccDAiHhFY6LLx)5c7r1hILhs5EuTLxLbQg1hA8pe8TtOCM4UT1pTtGzuOq9cGTtfcgT99ysiZ3VUtOwNgcAdVDIY9O6Dc9hyeqQXwaOwBoTt4GWjqO7eMki0PHeE8jRxwE9NlShvFO3LEiMki0PHe0FGraPgBbGAT5KfImkJ7Kw)0oH(dmci1ylauRnN2(EmjGV9R7eQ1PHG2WBNOCpQENaZW4WJTYwfJJFyupQENWbHtGq3jmvqOtdj84twVS86pxypQ(qSu6HyQGqNgsuTDHjlF5voVtA9t7eygghESv2QyC8dJ6r1BFpMeS49R7eQ1PHG2WBNOCpQEN8vUobKf)qKB)lCW3jCq4ei0Dctfe60qcp(K1llV(Zf2JQp07spe8TtA9t7KVY1jGS4hIC7FHd(23JjX4D)6oHADAiOn82jk3JQ3jqasHYbGSmjmMm7eoiCce6oHPccDAiHhFY6LLx)5c7r1hILspetfe60qIQTlmz5lVY5dL(qYFO5kNfrNjqRglxXCfIeyx5sEiPhAUYzr0zc0QXYvmxHiXxL1IDLl5HGdUdXGdXRgAfUi6mbA1y5kMRqKGADAiOdbhChIPccDAibV(Zf2JQTvBxy6qWb3HyQGqNgs4XNSEz51FUWEu9HE7qW3Hy5HYbSh3cOVgn(qJhhs5EuTLxLbQg1hkLDsRFANabifkhaYYKWyYS99ysa)SFDNqTone0gE7eL7r17eCTm2awhob2jCq4ei0Dctfe60qcp(K1llV(Zf2JQpelLEiMki0PHevBxyYYxELZh6Tdjb8DOX5qYFiMki0PHevBxyYYxELZhILhsUhkLdbhChIPccDAiHhFY6LLx)5c7r1h69djHC3jT(PDcUwgBaRdNaBFpMeWV7x3juRtdbTH3oHdcNaHUtyQGqNgs4XNSEz51FUWEu9HyP0dXubHonKOA7ctw(YRC(qPpetfe60qcp(K1llV(Zf2JQpelLEijGVdnohIg3vmmqqciaPq5aqwMegtMdL(qE8Pd9(HGVdL(qm4q8QHwHlIotGwnwUI5kejOwNgc6qWb3HMRCweDMaTASCfZvisGDLl5HKEO5kNfrNjqRglxXCfIeFvwl2vUK7eL7r17eU2CYyNRCENmx5ST1pTtW1YydyD4r1BFpMmK7(1Dc160qqB4Tt4GWjqO7eWQPCbGrcOaZJbt0kGrlV(FTHeuRtdbDO0hIxLbQg1I5kNTqbMhdMOvaJwE9)AdjaKcX4HsFO5kNfqbMhdMOvaJwE9)AdzvaxBsavJ6dL(qm4qZvolGcmpgmrRagT86)1gsSgou6dXubHonKWJpz9YYR)CH9O6dXYdjd4BNOCpQENWRv7eapqgZ23Jjdj2VUtOwNgcAdVDcheobcDNawnLlamsafyEmyIwbmA51)RnKGADAiOdL(q8Qmq1Owmx5SfkW8yWeTcy0YR)xBibGuigpu6dnx5SakW8yWeTcy0YR)xBiRc4AtcOAuFO0hIbhAUYzbuG5XGjAfWOLx)V2qI1WHsFiMki0PHeE8jRxwE9NlShvFiwEizaF7eL7r17efW1MSKSdMchvV99yYqg7x3juRtdbTH3oHdcNaHUtaRMYfagjGcmpgmrRagT86)1gsqTone0HsFiEvgOAulMRC2cfyEmyIwbmA51)RnKaqkeJhk9HMRCwafyEmyIwbmA51)RnKndkSlGQr9HsFigCO5kNfqbMhdMOvaJwE9)Adjwdhk9HyQGqNgs4XNSEz51FUWEu9Hy5HKb8TtuUhvVtYGc7ZY4BFpMmKP9R7eQ1PHG2WBNWbHtGq3jmvqOtdj84twVS86pxypQ(qVl9qYDNOCpQENWvJXQCpQ2AcSVtmb2TT(PDcV(Zf2JQTdpkM2(EmziZ3VUtOwNgcAdVDsnStWKVtuUhvVtyQGqNgANSWKTYzlmo0Emj2jmvZI2jmvqOtdj84twVS86pxypQ(qJ)HKPd9(HuUhvlYbGStJIDrEzmwaXFuamY6XNo04FiL7r1c8tK9OHzhQreqKxgJfqqlUhvFOX5qYFiEvgOAulWpr2JgMDOgrabG(A04d9(HyQGqNgs4XNSEz51FUWEu9Hs5qPpetfe60qcp(K1llV(Zf2JQp07hkhWEClG(A04dbhChYvd1UaSAYwz7qnIacQ1PHGou6dnx5SaSAYwz7qnIacOAuFO0hIxLbQg1cWQjBLTd1icia0xJgFO3pKY9OAroaKDAuSlYlJXci(JcGrwp(0Hg)dPCpQwGFIShnm7qnIaI8YySacAX9O6dnohs(dXRYavJAb(jYE0WSd1icia0xJgFO3peVkdunQfGvt2kBhQreqaOVgn(qPCO0hIxLbQg1cWQjBLTd1icia0xJgFO3puoG94wa91OX7eMkW26N2j5aq2PrXUDOkt0W2jlmzh9egYYvShnS9ysS99yYa(2VUtOwNgcAdVDsnStWKVtuUhvVtyQGqNgANWunlANWubHonKWJpz9YYR)CH9O6d9(HuUhvlgEkQdzTzJ(jSiVmglG4pkagz94thA8pKY9OAb(jYE0WSd1iciYlJXciOf3JQp04Ci5peVkdunQf4Ni7rdZouJiGaqFnA8HE)qmvqOtdj84twVS86pxypQ(qPCO0hIPccDAiHhFY6LLx)5c7r1h69dLdypUfqFnA8HGdUdbwnLlamsGxTvYOHHTtdHXrdtqTone0HGdUd5XNo07hc(2jmvGT1pTtgEkQdzTdvzIg223Jjdw8(1Dc160qqB4Tt4GWjqO7K5kNfGvt2kBhQreqavJ6dL(qm4qZvolYbGWEb(caPC)qPpK8hIPccDAiHhFY6LLx)5c7r1hILsp0CLZcWQjBLTd1iciGwa1JQpu6dXubHonKWJpz9YYR)CH9O6dXYdPCpQwKdazNgf7I8YySaI)OayK1JpDi4G7qmvqOtdj84twVS86pxypQ(qS8q5a2JBb0xJgFOu2jk3JQ3jGvt2kBhQrey77XKX4D)6oHADAiOn82jCq4ei0DYCLZcWQjBLTd1iciwdhk9HK)qmvqOtdj84twVS86pxypQ(qS8qY9qPStuUhvVt4QXyvUhvBnb23jMa72w)0obud2HhftBFpMmGF2VUtOwNgcAdVDYct2rpHHSCf7rdBpMe7eoiCce6oHbhIPccDAiroaKDAuSBhQYenSdL(qYFiMki0PHeE8jRxwE9NlShvFiwEi5Ei4G7qk3dMKLA6he(qSu6HyQGqNgs8OailxXUnB0pHDqijDO0hIbhkhac7kWjGq5EWKou6dXGdnx5S4PCl2bKkPaqk3pu6dj)HMRCw8qQhnm7AqaiL7hk9HuUhvlYg9tyhesscswIVCYcOVgn(qVFi5kGVdbhChI)Oaye2Mbk3JQvZHyP0djJdLYHszNSWKTYzlmo0Emj2jk3JQ3j5aq2PrX(23Jjd439R7eQ1PHG2WBNSWKD0tyilxXE0W2JjXoHdcNaHUtYbGWUcCciuUhmPdL(q8hfaJWhILspKehk9HyWHyQGqNgsKdazNgf72HQmrd7qPpK8hIbhs5EuTihaAQgJGKL4lpAyhk9HyWHuUhvlgyeutJIDr02SjG94hk9HMRCw8qQhnm7AqaiL7hco4oKY9OAroa0ungbjlXxE0Wou6dXGdnx5S4PCl2bKkPaqk3peCWDiL7r1Ibgb10OyxeTnBcyp(HsFO5kNfpK6rdZUgeas5(HsFigCO5kNfpLBXoGujfas5(HszNSWKTYzlmo0Emj2jk3JQ3j5aq2PrX(23JjtYD)6oHADAiOn82jlmzh9egYYvShnS9ysStuUhvVtYbGStJI9DcheobcDNOCpQwGFIShnm7qnIacswIV8OHDO0hkVmglG4pkagz94th69dPCpQwGFIShnm7qnIacp4sAbe0I7r1hk9HMRCw8uUf7asLuavJ6dL(qE8PdXYdjHC3(EmzsI9R7eQ1PHG2WBNWbHtGq3jYFiMki0PHeE8jRxwE9NlShvFiwEi5EOuou6dnx5SaSAYwz7qnIacOAuVtuUhvVt4QXyvUhvBnb23jMa72w)0ob7AdPailOC1JQ3(Emzsg7x3jk3JQ3jyEb4p7eQ1PHG2WB7BFNmaiE9NQVFDpMe7x3jk3JQ3jkGRnzJ2jJH4(oHADAiOn82(EmzSFDNqTone0gE7KAyNGjFNOCpQENWubHon0oHPAw0orghACoKRgQDr2OFYoOo)rqTone0HE7qY0HgNdXGd5QHAxKn6NSdQZFeuRtdbTt4GWjqO7eMki0PHepLBXoGujTzJ(jSdcjPdj9qYDNWub2w)0o5PCl2bKkPnB0pHDqijT99yY0(1Dc160qqB4TtQHDcM8DIY9O6Dctfe60q7eMQzr7ezCOX5qUAO2fzJ(j7G68hb160qqh6TdjthACoedoKRgQDr2OFYoOo)rqTone0oHdcNaHUtyQGqNgs8OailxXUnB0pHDqijDiPhsU7eMkW26N2jpkaYYvSBZg9tyhessBFpMmF)6oHADAiOn82j1Wobt(or5Eu9oHPccDAODct1SODImDOX5qUAO2fzJ(j7G68hb160qqh6TdXIp04CigCixnu7ISr)KDqD(JGADAiODcheobcDNWubHonKGx)5c7r12Sr)e2bHK0HKEi5UtyQaBRFANWR)CH9OAB2OFc7GqsA77XGV9R7eQ1PHG2WBNud7em57eL7r17eMki0PH2jmvZI2jWVWVhACoKRgQDr2OFYoOo)rqTone0HE7qY4qJZHyWHC1qTlYg9t2b15pcQ1PHG2jCq4ei0Dctfe60qcfW1MSKSdMchvFiPhsU7eMkW26N2jkGRnzjzhmfoQE77XyX7x3juRtdbTH3oPg2jact(or5Eu9oHPccDAODctfyB9t7efW1MSKSdMchvB)AR7eikRlJVtK5YD77XgV7x3juRtdbTH3oPg2jact(or5Eu9oHPccDAODctfyB9t7eiYOmAZg9tyhess7eikRlJVtK723Jb)SFDNqTone0gE7KAyNaim57eL7r17eMki0PH2jmvGT1pTtKmAit0WSacAX9O6DceL1LX3jYviZ3(Em439R7eQ1PHG2WBNud7em57eL7r17eMki0PH2jmvZI2jW3oHPcST(PDcwYPfAbupQE77XKqU7x3juRtdbTH3oPg2jyY3jk3JQ3jmvqOtdTtyQMfTtOXDfddeK4RCDcil(Hi3(x4GFi4G7q04UIHbcs81oYe2lBLTFfQjm(qWb3HOXDfddeKaMrHc1la2oviy0HGdUdrJ7kggiibmJcfQxaS9tqQXevFi4G7q04UIHbcseW6WJQTFfgHT5fMoeCWDiACxXWabj8uBTjSDQajXdrt4dbhChIg3vmmqqcn1Ebi)PWwC0Wii7Gz9vy0HGdUdrJ7kggiiH28GA3kzxUTY2rbgQ(hco4oenURyyGGe4NIl5mCcGTzTHDi4G7q04UIHbcs00cOglMXwhWKL6hT5e4qWb3HOXDfddeKyQgkhaYobAZF2jmvGT1pTt41FUWEuTTA7ctBFpMesSFDNqTone0gE7KAyNaim57eL7r17eMki0PH2jmvGT1pTtO)aJasn2ca1AZjlezug3jquwxgFNib8Z23JjHm2VUtOwNgcAdVDsnStWKVtuUhvVtyQGqNgANWunlANid5Ut4GWjqO7eMki0PHe86pxypQ2wTDHPDctfyB9t7KQTlmz5lVY5TVhtczA)6oHADAiOn82j1Wobt(or5Eu9oHPccDAODct1SODImGVDcheobcDNqJ7kggiiXx56eqw8drU9VWbFNWub2w)0oPA7ctw(YRCE77XKqMVFDNqTone0gE7KAyNGjFNOCpQENWubHon0oHPAw0orgY9qVDiMki0PHe0FGraPgBbGAT5KfImkJ7eoiCce6oHg3vmmqqc6pWiGuJTaqT2CANWub2w)0oPA7ctw(YRCE77XKa(2VUtOwNgcAdVDsnStaeM8DIY9O6Dctfe60q7eMkW26N2j86pxypQ2IFIShnm7qnIa7eikRlJVtKX23JjblE)6oHADAiOn82jT(PDcUwgBaRdNa7eL7r17eCTm2awhob2(EmjgV7x3jk3JQ3j)aakGn(kmANqTone0gEBFpMeWp7x3juRtdbTH3oHdcNaHUtyWHgaetXaJGAAuSVtuUhvVtgyeutJI9TV9DcV(Zf2JQTdpkM2VUhtI9R7eQ1PHG2WBNWbHtGq3jZvol41FUWEuTaQg17eL7r17eta7XXw4FSGG9P23(EmzSFDNqTone0gE7KAyNGjFNOCpQENWubHon0ozHjBLZwyCO9ysStyQaBRFANqY6udrqwE9NlShvBb0xJgVt4GWjqO7eE1qRWfrNjqRglxXCfIeuRtdbTtwyYo6jmKLRypAy7XKyNWunlANmx5SGx)5c7r1ca91OXh6Tdnx5SGx)5c7r1cOfq9O6dnohs(dXRYavJAbV(Zf2JQfa6RrJp07hAUYzbV(Zf2JQfa6RrJpukBFpMmTFDNqTone0gE7KAyNOqq7eL7r17eMki0PH2jlmzRC2cJdThtIDctfyB9t7eswNAicYYR)CH9OAlG(A04DcheobcDNWRgAfUi6mbA1y5kMRqKGADAiOdL(qYFO5kNf4vBLmAyy70qyC0WSasHyuSgoeCWDiMki0PHeKSo1qeKLx)5c7r1wa91OXhILhscb8DOX5qW4qIVk7HgNdj)HMRCwGxTvYOHHTtdHXrdt8vzTyx5sEOX)qZvolWR2kz0WW2PHW4OHjWUYL8qPCOu2jlmzh9egYYvShnS9ysStyQMfTtyQGqNgsGLCAHwa1JQ3(Emz((1Dc160qqB4Tt4GWjqO7K5kNf86pxypQwavJ6DIY9O6DYuHzRS1bbxs823JbF7x3juRtdbTH3oHdcNaHUtuUhmjl10pi8Hy5HK4qPp0CLZcE9NlShvlGQr9or5Eu9oXemJgMDw)523JXI3VUtOwNgcAdVDYct2rpHHSCf7rdBpMe7eoiCce6or(dPCpyswQPFq4d9U0dPCpyswOYfbSoC6qWb3HyWH4vzGQrTy4POoK1Mn6NWcaPqmEOuou6dXGdXRgAfUi6mbA1y5kMRqKGADAiOdL(q8hfaJWhILspKehk9HMRCwWR)CH9OAXA4qPpedo0CLZICaiSxGVaqk3pu6dXGdnx5S4PCl2bKkPaqk3pu6d9uUf7asL0IhiJbBJ2MnbSh)qVDO5kNfpK6rdZUgeas5(HE)qYyNSWKTYzlmo0Emj2jk3JQ3j5aq2PrX(23JnE3VUtOwNgcAdVDsnStWKVtuUhvVtyQGqNgANSWKTYzlmo0Emj2jmvGT1pTtizhiUtq2Cai70OyhVt4GWjqO7eE1qRWfrNjqRglxXCfIeuRtdbTtwyYo6jmKLRypAy7XKyNWunlANOCpQwKdazNgf7c(JcGryBgOCpQwnh6Tdj)HyQGqNgsqY6udrqwE9NlShvBb0xJgFOX)qZvolIotGwnwUI5kejGwa1JQpukhIHhIxLbQg1ICai70OyxaTaQhvV99yWp7x3juRtdbTH3oPg2jyY3jk3JQ3jmvqOtdTtwyYw5SfghApMe7eMkW26N2jnrqeKnhaYonk2X7eoiCce6oHxn0kCr0zc0QXYvmxHib160qq7KfMSJEcdz5k2Jg2Emj2jmvZI2jCkmhs(dXubHonKGK1PgIGS86pxypQ2cOVgn(qm8qYFO5kNfrNjqRglxXCfIeqlG6r1hA8pemoK4RYEOuoukBFpg87(1Dc160qqB4TtwyYo6jmKLRypAy7XKyNWbHtGq3jYFiL7btYsn9dcFO3LEiL7btYcvUiG1Hthco4oedoeVkdunQfdpf1HS2Sr)ewaifIXdLYHsFiE1qRWfrNjqRglxXCfIeuRtdbDO0hI)Oaye(qSu6HK4qPpK8hIPccDAibj7aXDcYMdazNgf74dXsPhIPccDAirteebzZbGStJID8HGdUdXubHonKGK1PgIGS86pxypQ2cOVgn(qVl9qZvolIotGwnwUI5kejGwa1JQpeCWDO5kNfrNjqRglxXCfIeyx5sEO3pKmoeCWDO5kNfrNjqRglxXCfIea6RrJp07hcghs8vzpeCWDiEvgOAulWpr2JgMDOgrabGuigpu6dPCpyswQPFq4dXsPhIPccDAibV(Zf2JQT4Ni7rdZouJiWHsFiEXKATDrhWECBwPdLYHsFO5kNf86pxypQwSgou6dj)HyWHMRCwKdaH9c8fas5(HGdUdnx5Si6mbA1y5kMRqKaqFnA8HE)qYvaFhkLdL(qm4qZvolEk3IDaPskaKY9dL(qpLBXoGujT4bYyW2OTzta7Xp0BhAUYzXdPE0WSRbbGuUFO3pKm2jlmzRC2cJdThtIDIY9O6DsoaKDAuSV99ysi39R7eQ1PHG2WBNWbHtGq3jGvt5caJeqbMhdMOvaJwE9)AdjOwNgc6qPp0CLZcOaZJbt0kGrlV(FTHeq1O(qPp0CLZcOaZJbt0kGrlV(FTHSkGRnjGQr9HsFiEvgOAulMRC2cfyEmyIwbmA51)RnKaqkeJhk9HyWHC1qTlaRMSv2ouJiGGADAiODIY9O6DcVwTta8azmBFpMesSFDNqTone0gE7eoiCce6obSAkxayKakW8yWeTcy0YR)xBib160qqhk9HMRCwafyEmyIwbmA51)RnKaQg1hk9HMRCwafyEmyIwbmA51)RnKvbCTjbunQpu6dXRYavJAXCLZwOaZJbt0kGrlV(FTHeasHy8qPpedoKRgQDby1KTY2HAebeuRtdbTtuUhvVtuaxBYsYoykCu923JjHm2VUtOwNgcAdVDcheobcDNawnLlamsafyEmyIwbmA51)RnKGADAiOdL(qZvolGcmpgmrRagT86)1gsavJ6dL(qZvolGcmpgmrRagT86)1gYMbf2fq1OENOCpQENKbf2NLX3(EmjKP9R7eQ1PHG2WBNWbHtGq3jGvt5caJeWab2WOn4b3qcQ1PHGou6dnx5SGx)5c7r1cOAuVtuUhvVtYGc72UyQBFpMeY89R7eQ1PHG2WBNOCpQENWvJXQCpQ2AcSVtmb2TT(PDIY9GjzD1qTJ3(EmjGV9R7eQ1PHG2WBNSWKD0tyilxXE0W2JjXoHdcNaHUtMRCwWR)CH9OAbunQpu6dj)HyWHaRMYfagjGcmpgmrRagT86)1gsqTone0HGdUdnx5SakW8yWeTcy0YR)xBiXA4qWb3HMRCwafyEmyIwbmA51)RnKndkSlwdhk9HC1qTlaRMSv2ouJiGGADAiOdL(q8Qmq1Owmx5SfkW8yWeTcy0YR)xBibGuigpukhk9HK)qm4qGvt5caJeWab2WOn4b3qcQ1PHGoeCWDiiAUYzbmqGnmAdEWnKynCOuou6dj)HuUhvl(KtfqeTnBcyp(HsFiL7r1Ip5uberBZMa2JBb0xJgFO3LEi5kyXhco4oKY9OAbMxa(JGKL4lpAyhk9HuUhvlW8cWFeKSeF5KfqFnA8HE)qYvWIpeCWDiL7r1ICaOPAmcswIV8OHDO0hs5EuTihaAQgJGKL4lNSa6RrJp07hsUcw8HGdUdPCpQwmWiOMgf7cswIV8OHDO0hs5EuTyGrqnnk2fKSeF5KfqFnA8HE)qYvWIpeCWDiL7r1ISr)e2bHKKGKL4lpAyhk9HuUhvlYg9tyhesscswIVCYcOVgn(qVFi5kyXhkLDYct2kNTW4q7XKyNOCpQENWR)CH9O6TVhtcw8(1Dc160qqB4Tt4GWjqO7K5kNf86pxypQwyuSBjzhcaDO3LEiL7r1cE9NlShvlmk2TlmbTtuUhvVt4QXyvUhvBnb23jMa72w)0oHx)5c7r1wEvgOAuJ3(EmjgV7x3juRtdbTH3oHdcNaHUtK)qZvolEk3IDaPskaKY9dL(qk3dMKLA6he(qSu6HyQGqNgsWR)CH9OAB2OFc7Gqs6qPCi4G7qYFO5kNf5aqyVaFbGuUFO0hs5EWKSut)GWhILspetfe60qcE9NlShvBZg9tyhesshA8pey1uUaWiroae2lWxqTone0HszNOCpQENKn6NWoiKK2(EmjGF2VUtOwNgcAdVDcheobcDNmx5SaVARKrddBNgcJJgMfqkeJI1WHsFO5kNf4vBLmAyy70qyC0WSasHyuaOVgn(qS8qCf7wp(0or5Eu9ozGrqnnk23(EmjGF3VUtOwNgcAdVDcheobcDNmx5Sihac7f4laKY9DIY9O6DYaJGAAuSV99yYqU7x3juRtdbTH3oHdcNaHUtMRCwmWiO4gf)fas5(HsFO5kNfdmckUrXFbG(A04dXYdXvSB94thk9HK)qZvol41FUWEuTaqFnA8Hy5H4k2TE8PdbhChAUYzbV(Zf2JQfq1O(qPCO0hs5EWKSut)GWh69dXubHonKGx)5c7r12Sr)e2bHK0or5Eu9ozGrqnnk23(EmziX(1Dc160qqB4Tt4GWjqO7K5kNfpLBXoGujfas5(HsFO5kNf86pxypQwSg2jk3JQ3jdmcQPrX(23JjdzSFDNqTone0gE7eoiCce6ozaqmTW4qcjeyEb4phk9HMRCw8qQhnm7AqaiL7hk9HuUhmjl10pi8HE)qmvqOtdj41FUWEuTnB0pHDqijTtuUhvVtgyeutJI9TVhtgY0(1Dc160qqB4TtuUhvVtWpr2JgMDOgrGDcheobcDNmx5SGx)5c7r1I1WHsFigCiL7r1ICai70OyxWFuamcFO0hs5EWKSut)GWhILspetfe60qcE9NlShvBXpr2JgMDOgrGdL(qk3JQfdpf1HS2Sr)ewKxgJfq8hfaJSE8PdXYdLxgJfqqlUhvVtI2jayn42iVtuUhvlYbGStJIDb)rbWiSuL7r1ICai70Oyx8vzT8hfaJWBFpMmK57x3juRtdbTH3oHdcNaHUtMRCwWR)CH9OAXA4qPpK8hs(dPCpQwKdazNgf7c(JcGr4d9(HK4qPpKRgQDXaJGIBu8xqTone0HsFiL7btYsn9dcFiPhsIdLYHGdUdXGd5QHAxmWiO4gf)fuRtdbDi4G7qk3dMKLA6he(qS8qsCOuou6dnx5S4HupAy21Gaqk3p0Bh6PCl2bKkPfpqgd2gTnBcyp(HE)qYyNOCpQENm8uuhYAZg9t4TVhtgW3(1Dc160qqB4Tt4GWjqO7K5kNf86pxypQwavJ6dL(q8Qmq1OwWR)CH9OAbG(A04d9(H4k2TE8PdL(qk3dMKLA6he(qSu6HyQGqNgsWR)CH9OAB2OFc7GqsANOCpQENKn6NWoiKK2(EmzWI3VUtOwNgcAdVDcheobcDNmx5SGx)5c7r1cOAuFO0hIxLbQg1cE9NlShvla0xJgFO3pexXU1JpDO0hIbhIxn0kCr2OFYQCoG8OAb160qq7eL7r17KCaOPAmBFpMmgV7x3juRtdbTH3oHdcNaHUtMRCwWR)CH9OAbG(A04dXYdXvSB94thk9HMRCwWR)CH9OAXA4qWb3HMRCwWR)CH9OAbunQpu6dXRYavJAbV(Zf2JQfa6RrJp07hIRy36XN2jk3JQ3jyEb4pBFpMmGF2VUtOwNgcAdVDcheobcDNmx5SGx)5c7r1ca91OXh69dbJdj(QShk9HuUhmjl10pi8Hy5HKyNOCpQENycMrdZoR)C77XKb87(1Dc160qqB4Tt4GWjqO7K5kNf86pxypQwaOVgn(qVFiyCiXxL9qPp0CLZcE9NlShvlwd7eL7r17eiGcRASDci1F2(EmzsU7x3juRtdbTH3oHdcNaHUtCfaJCXdPg)rmW9d9U0djtY9qPpKRgQDbMuq0WSET4pcQ1PHG2jk3JQ3jyEb4pBF77eL7btY6QHAhVFDpMe7x3juRtdbTH3oHdcNaHUtuUhmjl10pi8Hy5HK4qPp0CLZcE9NlShvlGQr9HsFi5petfe60qcp(K1llV(Zf2JQpelpeVkdunQfMGz0WSZ6pfqlG6r1hco4oetfe60qcp(K1llV(Zf2JQp07spKCpuk7eL7r17etWmAy2z9NBFpMm2VUtOwNgcAdVDcheobcDNWubHonKWJpz9YYR)CH9O6d9U0dj3dbhChs(dXRYavJAXNCQacOfq9O6d9(HyQGqNgs4XNSEz51FUWEu9HsFigCixnu7cWQjBLTd1iciOwNgc6qPCi4G7qUAO2fGvt2kBhQreqqTone0HsFO5kNfGvt2kBhQreqSgou6dXubHonKWJpz9YYR)CH9O6dXYdPCpQw8jNkGGxLbQg1hco4ouoG94wa91OXh69dXubHonKWJpz9YYR)CH9O6DIY9O6DYNCQaBFpMmTFDNqTone0gE7eoiCce6oXvd1UqnKSyhO4uBfBZlaJcQ1PHGou6dj)HMRCwWR)CH9OAbunQpu6dXGdnx5S4PCl2bKkPaqk3puk7eL7r17eiGcRASDci1F2(23jyxBifazbLREu9(19ysSFDNqTone0gE7eoiCce6or5EWKSut)GWhILspetfe60qINYTyhqQK2Sr)e2bHK0HsFi5p0CLZINYTyhqQKcaPC)qWb3HMRCwKdaH9c8fas5(HszNOCpQENKn6NWoiKK2(EmzSFDNqTone0gE7eoiCce6ozUYzroae2lWxaiL77eL7r17Kbgb10OyF77XKP9R7eQ1PHG2WBNWbHtGq3jZvolEk3IDaPskaKY9dL(qZvolEk3IDaPska0xJgFO3pKY9OAroa0ungbjlXxoz94t7eL7r17Kbgb10OyF77XK57x3juRtdbTH3oHdcNaHUtMRCw8uUf7asLuaiL7hk9HK)qdaIPfghsiHihaAQgZHGdUdLdaHDf4eqOCpyshco4oKY9OAXaJGAAuSlI2MnbSh)qPStuUhvVtgyeutJI9TVhd(2VUtOwNgcAdVDcheobcDNmx5SaVARKrddBNgcJJgMfqkeJI1WHsFi5peVkdunQfGvt2kBhQreqaOVgn(qVDiL7r1cWQjBLTd1iciizj(YjRhF6qVDiUIDRhF6qS8qZvolWR2kz0WW2PHW4OHzbKcXOaqFnA8HGdUdXGd5QHAxawnzRSDOgrab160qqhkLdL(qmvqOtdj84twVS86pxypQ(qVDiUIDRhF6qS8qZvolWR2kz0WW2PHW4OHzbKcXOaqFnA8or5Eu9ozGrqnnk23(Emw8(1Dc160qqB4Tt4GWjqO7K5kNfpLBXoGujfas5(HsFixbWix8qQXFedC)qVl9qYKCpu6d5QHAxGjfenmRxl(JGADAiODIY9O6DYaJGAAuSV99yJ39R7eQ1PHG2WBNWbHtGq3jZvolgyeuCJI)caPC)qPpexXU1JpDO3p0CLZIbgbf3O4VaqFnA8or5Eu9ozGrqnnk23(Em4N9R7eQ1PHG2WBNSWKD0tyilxXE0W2JjXoHdcNaHUtyWHYbGWUcCciuUhmPdL(qm4qmvqOtdjYbGStJID7qvMOHDO0hs(dj)HK)qk3JQf5aqt1yeKSeF5rd7qPpK8hs5EuTihaAQgJGKL4lNSa6RrJp07hsUc47qWb3HyWHaRMYfagjYbGWEb(cQ1PHGoukhco4oKY9OAXaJGAAuSlizj(YJg2HsFi5pKY9OAXaJGAAuSlizj(YjlG(A04d9(HKRa(oeCWDigCiWQPCbGrICaiSxGVGADAiOdLYHs5qPp0CLZIhs9OHzxdcaPC)qPCi4G7qYFixnu7cmPGOHz9AXFeuRtdbDO0hYvamYfpKA8hXa3p07spKmj3dL(qYFO5kNfpK6rdZUgeas5(HsFigCiL7r1cmVa8hbjlXxE0WoeCWDigCO5kNfpLBXoGujfas5(HsFigCO5kNfpK6rdZUgeas5(HsFiL7r1cmVa8hbjlXxE0Wou6dXGd9uUf7asL0IhiJbBJ2MnbSh)qPCOuouk7KfMSvoBHXH2JjXor5Eu9ojhaYonk23(Em439R7eQ1PHG2WBNWbHtGq3jdaIPfghsiHaZla)5qPp0CLZIhs9OHzxdcaPC)qPpKRgQDbMuq0WSET4pcQ1PHGou6d5kag5Ihsn(JyG7h6DPhsMK7HsFiL7btYsn9dcFO3petfe60qINYTyhqQK2Sr)e2bHK0or5Eu9ozGrqnnk23(EmjK7(1Dc160qqB4Tt4GWjqO7egCiMki0PHedpf1HS2HQmrd7qPpK8hIbhYvd1UidQV1FiRIFiSGADAiOdbhChs5EWKSut)GWhILhsIdLYHsFi5pKY9GjzHkxeW6WPd9(HKXHGdUdPCpyswQPFq4dXsPhIPccDAiXJcGSCf72Sr)e2bHK0HGdUdPCpyswQPFq4dXsPhIPccDAiXt5wSdivsB2OFc7Gqs6qPStuUhvVtgEkQdzTzJ(j823JjHe7x3juRtdbTH3or5Eu9oHRgJv5EuT1eyFNycSBB9t7eL7btY6QHAhV99ysiJ9R7eQ1PHG2WBNWbHtGq3jk3dMKLA6he(qS8qsStuUhvVtGakSQX2jGu)z77XKqM2VUtOwNgcAdVDcheobcDN4kag5Ihsn(JyG7h6DPhsMK7HsFixnu7cmPGOHz9AXFeuRtdbTtuUhvVtW8cWF2(EmjK57x3juRtdbTH3oHdcNaHUtuUhmjl10pi8HyP0dXubHonKqbCTjlj7GPWr1hk9H(ARIbUFiwk9qmvqOtdjuaxBYsYoykCuT9RTUtuUhvVtuaxBYsYoykCu923Jjb8TFDNqTone0gE7eoiCce6or5EWKSut)GWhILspetfe60qIhfaz5k2TzJ(jSdcjPDIY9O6Ds2OFc7GqsA77XKGfVFDNOCpQENKdanvJzNqTone0gEBF77eE9NlShvB5vzGQrnE)6Emj2VUtuUhvVtgkpQENqTone0gEBFpMm2VUtuUhvVtMMQGS5fGXDc160qqB4T99yY0(1DIY9O6DYKayciz0W2juRtdbTH323JjZ3VUtuUhvVtYbGMMQG2juRtdbTH323JbF7x3jk3JQ3jAZjSduJLRgZoHADAiOn82(Emw8(1DIY9O6DYct2WPpENqTone0gEBFp24D)6oHADAiOn82jk3JQ3jWmkuOEbW2PcbJ2jlmzRC2cJdThtIDcheobcDNOCpQw8jNkGiAB2eWEClG(A04d9U0djxb8TtOCM4UT1pTtGzuOq9cGTtfcgT99yWp7x3juRtdbTH3oHdcNaHUtaRMYfagjC6pua1yhPGbb160qqhk9HMRCwqY(OlShvlwd7eL7r17ep(KDKcg2(23(oHjbWr17XKHCLHCLqgYqM2jJuqhnm8orMb(B8CSxYyVSSWHo0Rp0HI)qb8dLlWHydud2HhftSDianURaqqhcxF6q6YRV6e0H4pAdJWIJ1xenDi4JfouQQMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdjVmKnfXX6lIMoelMfouQQMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdjVeYMI4y9frthIfZchkvvZKaobDi2aRMYfagjKdBhYRdXgy1uUaWiHCeuRtdbX2HKxgYMI4y9frthc(LfouQQMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdjVeYMI4y9frthscjyHdLQQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qQFOuZl9fhsEjKnfXX6XQmd8345yVKXEzzHdDOxFOdf)Hc4hkxGdXgeL1LXz7qaACxbGGoeU(0H0LxF1jOdXF0ggHfhRViA6qsWchkvvZKaobDi2aRMYfagjKdBhYRdXgy1uUaWiHCeuRtdbX2Hu)qPMx6loK8siBkIJ1xenDizWchkvvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2HKxgYMI4y9frthc(yHdLQQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qYlHSPiowFr00HyXSWHsv1mjGtqhInxnu7c5W2H86qS5QHAxihb160qqSDi5Lq2uehRViA6qJxw4qPQAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2oK8siBkIJ1xenDijgVSWHsv1mjGtqhkj(P6qygBxL9qJhJhhYRd9ILEOFbTml8HQbcOEboK8JhPCi5Lq2uehRViA6qsmEzHdLQQzsaNGoeB8QHwHlKdBhYRdXgVAOv4c5iOwNgcITdjVeYMI4y9frthsc4xw4qPQAMeWjOdXgVAOv4c5W2H86qSXRgAfUqocQ1PHGy7qYlHSPiowFr00HKHCzHdLQQzsaNGoeBGvt5caJeYHTd51HydSAkxayKqocQ1PHGy7qYlHSPiowFr00HKHeSWHsv1mjGtqhInWQPCbGrc5W2H86qSbwnLlamsihb160qqSDi5Lq2uehRViA6qYqgSWHsv1mjGtqhInWQPCbGrc5W2H86qSbwnLlamsihb160qqSDi5Lq2uehRViA6qYqMZchkvvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2HKxcztrCS(IOPdjd4JfouQQMjbCc6qSbwnLlamsih2oKxhInWQPCbGrc5iOwNgcITdjVeYMI4y9yvMb(B8CSxYyVSSWHo0Rp0HI)qb8dLlWHyBaq86pvNTdbOXDfac6q46thsxE9vNGoe)rByewCS(IOPdjdw4qPQAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2oK8siBkIJ1xenDizWchkvvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2Hu)qPMx6loK8siBkIJ1xenDizIfouQQMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdjVeYMI4y9frthsMyHdLQQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qQFOuZl9fhsEjKnfXX6lIMoKmNfouQQMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdjVeYMI4y9frthsMZchkvvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2Hu)qPMx6loK8siBkIJ1xenDi4JfouQQMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdjVeYMI4y9frthc(yHdLQQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qQFOuZl9fhsEjKnfXX6XQmd8345yVKXEzzHdDOxFOdf)Hc4hkxGdXgV(Zf2JQT8Qmq1OgZ2Ha04UcabDiC9PdPlV(QtqhI)OnmclowFr00HGFyHdLQQzsaNGoeBGvt5caJeYHTd51HydSAkxayKqocQ1PHGy7qYlHSPiowpwLzG)gph7Lm2lllCOd96dDO4pua)q5cCi2uUhmjRRgQDmBhcqJ7kae0HW1NoKU86RobDi(J2WiS4y9frthsgSWHsv1mjGtqhInxnu7c5W2H86qS5QHAxihb160qqSDi5LHSPiowFr00HKjw4qPQAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2oK8siBkIJ1Jvzg4VXZXEjJ9YYch6qV(qhk(dfWpuUahInSRnKcGSGYvpQMTdbOXDfac6q46thsxE9vNGoe)rByewCS(IOPdbFSWHsv1mjGtqhInxnu7c5W2H86qS5QHAxihb160qqSDi5Lq2uehRViA6qSyw4qPQAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2oK6hk18sFXHKxcztrCS(IOPdb)WchkvvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2HKxcztrCS(IOPdb)WchkvvZKaobDi2aRMYfagjKdBhYRdXgy1uUaWiHCeuRtdbX2HKxgYMI4y9frthc(LfouQQMjbCc6qS5QHAxih2oKxhInxnu7c5iOwNgcITdjVeYMI4y9frthsc5YchkvvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2HKxcztrCS(IOPdjHmXchkvvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2Hu)qPMx6loK8siBkIJ1Jvzg4VXZXEjJ9YYch6qV(qhk(dfWpuUahInE9NlShvBhEumX2Ha04UcabDiC9PdPlV(QtqhI)OnmclowFr00HKblCOuvntc4e0HyJxn0kCHCy7qEDi24vdTcxihb160qqSDi1puQ5L(IdjVeYMI4y9frthsMyHdLQQzsaNGoeB8QHwHlKdBhYRdXgVAOv4c5iOwNgcITdjVeYMI4y9frthIfZchkvvZKaobDi24vdTcxih2oKxhInE1qRWfYrqToneeBhsEjKnfXX6lIMo04LfouQQMjbCc6qjXpvhcZy7QShA84qEDOxS0dbfmdCu9HQbcOEboK8mmLdjVeYMI4y9frthA8YchkvvZKaobDi24vdTcxih2oKxhInE1qRWfYrqToneeBhs9dLAEPV4qYlHSPiowFr00HGFyHdLQQzsaNGous8t1HWm2Uk7HgpoKxh6fl9qqbZahvFOAGaQxGdjpdt5qYlHSPiowFr00HGFyHdLQQzsaNGoeB8QHwHlKdBhYRdXgVAOv4c5iOwNgcITdP(HsnV0xCi5Lq2uehRViA6qWVSWHsv1mjGtqhInE1qRWfYHTd51HyJxn0kCHCeuRtdbX2HKxcztrCS(IOPdjHCzHdLQQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qQFOuZl9fhsEjKnfXX6lIMoKeYLfouQQMjbCc6qSbwnLlamsih2oKxhInWQPCbGrc5iOwNgcITdjVeYMI4y9frthscjyHdLQQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qQFOuZl9fhsEjKnfXX6lIMoKesWchkvvZKaobDi2aRMYfagjKdBhYRdXgy1uUaWiHCeuRtdbX2HKxcztrCS(IOPdjHmyHdLQQzsaNGoeBGvt5caJeYHTd51HydSAkxayKqocQ1PHGy7qYlHSPiowFr00HKqMyHdLQQzsaNGoeBGvt5caJeYHTd51HydSAkxayKqocQ1PHGy7qYlHSPiowFr00HKa(yHdLQQzsaNGoeBUAO2fYHTd51HyZvd1UqocQ1PHGy7qYlHSPiowFr00HKa(yHdLQQzsaNGoeBGvt5caJeYHTd51HydSAkxayKqocQ1PHGy7qYldztrCS(IOPdjX4LfouQQMjbCc6qSbwnLlamsih2oKxhInWQPCbGrc5iOwNgcITdjVeYMI4y9frthsgYCw4qPQAMeWjOdXMRgQDHCy7qEDi2C1qTlKJGADAii2oK8Yq2uehRViA6qYGfZchkvvZKaobDi24vdTcxih2oKxhInE1qRWfYrqToneeBhs9dLAEPV4qYlHSPiowFr00HKj5YchkvvZKaobDi2C1qTlKdBhYRdXMRgQDHCeuRtdbX2Hu)qPMx6loK8siBkIJ1J1xYFOaobDOX7HuUhvFitGDS4yDNGhi(EmwSmTtgavom0oj1pelka0HEzuy0XAQFOh3hWSadziSWFwtbV(meh)Lr9OAoqZodXXNZWJ1u)qV8eN(tcCizaFSFizixzi3J1J1u)qP6rByeMfowt9dn(h6LdthkhWEClG(A04dbu)HahYF0(qUcGrUWJpz9Ycf0HYf4qgf7JpM4vdDiDgMWz8qlScJWIJ1u)qJ)HErvyQpexX(Ha04Uca9P2XhkxGdLQ6pxypQ(qYhcsW(HGQMn)qpLb6qHFOCboKEOmGWph6LHCQahIRypfXXAQFOX)qPMwNg6qyheC)q8hIlz0Wou1hspuMgDOCbKeFOOpK)qhc(tM9fhYRdbiOfNo0OciPPuiXX6XAQFOuJSeF5e0HMuUa0H41FQ(HMeSOXIdb)X50GJpux94)OGFEzoKY9OA8HQ2WO4yv5EunwmaiE9NQ)MugQaU2KnANmgI7hRP(HE9jWhIPccDAOdHhiEKdcFi)HouV(tcCOkFixbWihFi1p0ONG)COuRYpuIdivYdXIm6NWoiKKWhQwooGOdv5dLQ6pxypQ(q4NAzGo0Ko0ctqIJvL7r1yXaG41FQ(Bszitfe60qS36NK(uUf7asL0Mn6NWoiKKyVgKIjN9ilLPccDAiXt5wSdivsB2OFc7GqssQCzNPAwKuzmoUAO2fzJ(j7G68N3KPXHbUAO2fzJ(j7G68NJ1u)qV(e4dXubHon0HWdepYbHpK)qhQx)jbouLpKRayKJpK6hA0tWFouQLcGouQuSFiwKr)e2bHKe(q1YXbeDOkFOuv)5c7r1hc)uld0HM0Hwyc6qk(q5WyiG4yv5EunwmaiE9NQ)MugYubHone7T(jPpkaYYvSBZg9tyhessSxdsXKZEKLYubHonK4rbqwUIDB2OFc7GqssQCzNPAwKuzmoUAO2fzJ(j7G68N3KPXHbUAO2fzJ(j7G68NJ1u)qV(e4dXubHon0HWdepYbHpK)qhQx)jbouLpKRayKJpK6hA0tWFouQv5hkXbKk5Hyrg9tyhess4dPa6qlmbDiOfiAyhkv1FUWEuT4yv5EunwmaiE9NQ)MugYubHone7T(jP86pxypQ2Mn6NWoiKKyVgKIjN9ilLPccDAibV(Zf2JQTzJ(jSdcjjPYLDMQzrsLPXXvd1UiB0pzhuN)8glECyGRgQDr2OFYoOo)5yn1p0Rpb(qmvqOtdDi8aXJCq4d5p0H61FsGdv5d5kag54dP(Hg9e8Ndb)b4Athk1i7GPWr1hQwooGOdv5dLQ6pxypQ(q4NAzGo0Ko0ctqIJvL7r1yXaG41FQ(Bszitfe60qS36NKQaU2KLKDWu4OA2RbPyYzpYszQGqNgsOaU2KLKDWu4OAPYLDMQzrsHFHFhhxnu7ISr)KDqD(ZBYyCyGRgQDr2OFYoOo)5yn1p0Rpb(qmvqOtdDi8aXJCq4d5p0HgiaNAxHrhQYh6RTEOjzQrhA0tWFoe8hGRnDOuJSdMchvFOrHXCOU8dnPdTWeK4yv5EunwmaiE9NQ)MugYubHone7T(jPkGRnzjzhmfoQ2(1wzhIY6Y4sL5YL9AqkGWKFSM6h61NaFiMki0PHouGp0ctqhYRdHhiEKz8q(dDi9xR2puLpKhF6qrFimXRgcFi)r9d9xy)qdkgFin7e4qPQ(Zf2JQpej7qai8HMuUa0Hyrg9tyhess4dnkmMdnPdTWe0H6c8vJHrXXQY9OASyaq86pv)nPmKPccDAi2B9tsHiJYOnB0pHDqijXoeL1LXLkx2RbPact(XAQFizMWFoe8)OHmrdJ9dLQ6pxypQMn8H4vzGQr9HgfgZHM0Hae0ItqhAY4H0db0gQ(hs)1QD2p0C5hYFOd1R)KahQYhIdchFiSRahFiMeGXd9eWEoKMDcCiL7bt1Jg2Hsv9NlShvFiTHoe2uJWhcQg1hYRrkacFi)Hoe1qhQYhkv1FUWEunB4dXRYavJAXHKzEO(qFvYOHDiiIh4OA8HI(q(dDi4pz2xW(Hsv9NlShvZg(qa6RrhnSdXRYavJ6df4dbiOfNGo0KXd5pb(qzGY9O6d51HuoVwTFOCboe8)OHmrdtCSQCpQglgaeV(t1FtkdzQGqNgI9w)KujJgYenmlGGwCpQMDikRlJlvUczo71GuaHj)yn1p0Rp0HGwa1JQpuLpKEOKvFi4)rdJn8HGNHW4OHDOuv)5c7r1IJvL7r1yXaG41FQ(Bszitfe60qS36NKILCAHwa1JQzVgKIjNDMQzrsHVJvL7r1yXaG41FQ(Bszitfe60qS36NKYR)CH9OAB12fMyVgKIjNDMQzrsPXDfddeK4RCDcil(Hi3(x4GdhC04UIHbcs81oYe2lBLTFfQjmgo4OXDfddeKaMrHc1la2oviyeCWrJ7kggiibmJcfQxaS9tqQXevdhC04UIHbcseW6WJQTFfgHT5fMGdoACxXWabj8uBTjSDQajXdrty4GJg3vmmqqcn1Ebi)PWwC0Wii7Gz9vyeCWrJ7kggiiH28GA3kzxUTY2rbgQ(WbhnURyyGGe4NIl5mCcGTzTHbhC04UIHbcs00cOglMXwhWKL6hT5eao4OXDfddeKyQgkhaYobAZFowt9dLAvJoKPAyhAs5cqhkv1FUWEu9HWp1YaDOuZFGraPMd9sbqT2C6qt6qlmbb)ZJvL7r1yXaG41FQ(Bszitfe60qS36NKs)bgbKASfaQ1MtwiYOmYoeL1LXLkb8d71GuaHj)yn1puQvn6qMQHDOjLlaDOuv)5c7r1hc)uld0HCq0sso(q(J6hYbbmye4q6HWpkGGoKmK7HWeVAOdLQx(dv9Hk)HahYbrlj54d1LFOjDOfMGG)5XQY9OASyaq86pv)nPmKPccDAi2B9tsR2UWKLV8kNzVgKIjNDMQzrsLHCzpYszQGqNgsWR)CH9OAB12fMowvUhvJfdaIx)P6VjLHmvqOtdXERFsA12fMS8Lx5m71Gum5SZunlsQmGp2JSuACxXWabj(kxNaYIFiYT)fo4hRk3JQXIbaXR)u93KYqMki0PHyV1pjTA7ctw(YRCM9AqkMC2zQMfjvgY9nMki0PHe0FGraPgBbGAT5KfImkJShzP04UIHbcsq)bgbKASfaQ1MthRP(HE9HouV(tcCOkFixbWihFOKNi7rd7qYS1icCi8tTmqhAshAHjOdv9HGwGOHDOuv)5c7r1IJvL7r1yXaG41FQ(Bszitfe60qS36NKYR)CH9OAl(jYE0WSd1icWoeL1LXLkd2RbPact(XQY9OASyaq86pv)nPmCHjB40N9w)KuCTm2awhobowvUhvJfdaIx)P6VjLH)aakGn(km6yv5EunwmaiE9NQ)MugoWiOMgf7ShzPmyaqmfdmcQPrX(X6XAQFOuJSeF5e0HiMeGXd5XNoK)qhs5EbouGpKYudJonK4yv5EunwkVwTta8azmShzPmaSAkxayKakW8yWeTcy0YR)xBOJvL7r143KYqMki0PHyV1pj1Jpz9YYR)CH9OA2RbPyYzNPAwKuxnu7ICaiSRaNaJtoae2vGtabG(A043KNxLbQg1cE9NlShvla0xJgpoYlX4ZubHonKqYOHmrdZciOf3JQhhxnu7cjJgYenSuszCyaVkdunQf86pxypQwaifIXXzUYzbV(Zf2JQfq1O(yn1p0lJkjDi8cqhkv1FUWEu9Hc8HGiJYibDOiFOMiic6qtftqhQ6d5p0HO)aJasn2ca1AZjlezugpetfe60qhRk3JQXVjLHmvqOtdXERFsQhFY6LLx)5c7r1Sxds)QSSZunlsktfe60qc6pWiGuJTaqT2CYcrgLXXxEEvgOAulO)aJasn2ca1AZjb0cOEu94ZRYavJAb9hyeqQXwaOwBoja0xJgNY4WaEvgOAulO)aJasn2ca1AZjbGuigzpYsPXDfddeKG(dmci1ylauRnNowvUhvJFtkdzQGqNgI9w)Kup(K1llV(Zf2JQzVgK(vzzNPAwKuEvgOAulGzuOq9cGTtfcgja0xJgZEKLsJ7kggiibmJcfQxaSDQqWOJvL7r143KYqMki0PHyV1pj1Jpz9YYR)CH9OA2RbPFvw2zQMfjDUYzby1KTY2HAebea6RrJzpYsD1qTlaRMSv2ouJiq65kNf86pxypQwavJ6JvL7r143KYqMki0PHyV1pj1Jpz9YYR)CH9OA2RbPFvw2zQMfjLxLbQg1cWQjBLTd1icia0xJg)2CLZcWQjBLTd1iciGwa1JQzpYsD1qTlaRMSv2ouJiq65kNf86pxypQwavJ608Qmq1OwawnzRSDOgrabG(A043GV3zQGqNgs4XNSEz51FUWEu9XQY9OA8Bszi(jYE0WSd1icWEKLox5SGx)5c7r1cOAuNMPccDAiHhFY6LLx)5c7r1SmVmglGGwCpQoT88Qmq1OwawnzRSDOgrabG(A0ywMxgJfqqlUhvdhCmWvd1UaSAYwz7qnIaPKMbYpx5Si6mbA1y5kMRqKynKEUYzXt5wSdivsbGuUNsA5vUhmjl10pi87mvqOtdj41FUWEuTf)ezpAy2HAebGdoL7btYsn9dc)otfe60qcE9NlShvBZg9tyhessWbhtfe60qcp(K1llV(Zf2JQh)8YySacAX9OAwYRYavJ6uowvUhvJFtkdbkuOTBXdkqs2JSu5NRCwWR)CH9OAbunQtpx5SaSAYwz7qnIacOAuNwEMki0PHeE8jRxwE9NlShv)ojlXxoz94tWbhtfe60qcp(K1llV(Zf2JQzjVkdunQfafk02T4bfiPaAbupQoLuGdo5NRCwawnzRSDOgraXAintfe60qcp(K1llV(Zf2JQzPmj3uowvUhvJFtkdHi1FMfOj2JS05kNf86pxypQwavJ60ZvolaRMSv2ouJiGaQg1PzQGqNgs4XNSEz51FUWEu97KSeF5K1JpDSQCpQg)Mug(daOayBLTEb(u7ShzPmvqOtdj84twVS86pxypQ(DPYu65kNf86pxypQwavJ6J1u)qSOcCi4FP2FyeW(Hwy6q6HyrbGoe8mk2pe)rbWOdbTard7qVmbaua8HQ8HETaFQ9dXvSFiVoKYScOdX1HHOHDi(JcGr4df5d9s6mbA1COuPyUcrhkWhQl)qyYqCNGehRk3JQXVjLH5aq2PrXo7lmzh9egYYvShnmPsWEKLQCpQw8daOayBLTEb(u7cswIV8OHLoVmglG4pkagz94tJVY9OAXpaGcGTv26f4tTlizj(YjlG(A043L5PzWt5wSdivslEGmgSnAB2eWE80myUYzXt5wSdivsbGuUFSQCpQg)Mug(daOa24RWi2JS05kNf86pxypQwavJ60q0CLZcGcfA7w8GcK0YCzAcOZWeoJcOAuNEUYzby1KTY2HAebeq1O(yv5Eun(nPmCHjB40NDkNjUBB9tsHzuOq9cGTtfcgXEKLYubHonKWJpz9YYR)CH9OAwYRYavJ6Xh(owvUhvJFtkdxyYgo9zV1pjL(dmci1ylauRnNypYszQGqNgs4XNSEz51FUWEu97szQGqNgsq)bgbKASfaQ1MtwiYOmESQCpQg)MugUWKnC6ZERFskmdJdp2kBvmo(Hr9OA2JSuMki0PHeE8jRxwE9NlShvZsPmvqOtdjQ2UWKLV8kNpwvUhvJFtkdxyYgo9zV1pj9RCDcil(Hi3(x4GZEKLYubHonKWJpz9YYR)CH9O63LcFhRP(HEj5dTWrd7q6HWobQa6qvp(lmDOWPp7hsnJugXhAHPd9Ydifkha6qW)symzouTCCarhQYhkv1FUWEuT4qVu)HaJcmX(Hgarbcp1Mo0chnSd9Ydifkha6qW)symzo0OWFouQQ)CH9O6dvTHXdf5d9s6mbA1COuPyUcrhkWhIADAiOdPn0H0dTWkm6qJQMn)qt6qMc7hQysGd5p0HGwa1JQpuLpK)qhkhWECXXQY9OA8Bsz4ct2WPp7T(jPqasHYbGSmjmMmShzPmvqOtdj84twVS86pxypQMLszQGqNgsuTDHjlF5voNw(5kNfrNjqRglxXCfIeyx5skDUYzr0zc0QXYvmxHiXxL1IDLljCWXaE1qRWfrNjqRglxXCfIGdoMki0PHe86pxypQ2wTDHj4GJPccDAiHhFY6LLx)5c7r1VbFSmhWEClG(A04XJXdEvgOAuNYXAQFOKAzo0lbwhoboe(PwgOdnPdTWe0HI(q6HgPmEi)r9dbveUzZpu0obYeGo0OWFou5pe4qvp(lmDiheTKKJfh6L6pe4qoiAjjhFiO6qD5hYbbmye4q6HWpkGGo0ljvV8hQ6dfo7hcxhk8dX1(qt6qlmbDiqa7XpKMDcCiTz8qL)qGdv94VW0HCq0ssU4yv5Eun(nPmCHjB40N9w)KuCTm2awhobypYszQGqNgs4XNSEz51FUWEunlLYubHonKOA7ctw(YRC(njGVXrEMki0PHevBxyYYxELZSuUPahCmvqOtdj84twVS86pxypQ(DjK7XAQFOxbbmye4qj1YCOxcSWjWHifyy8qJc)5qVKotGwnhkvkMRq0HkWHg9q9Hc)qJu8HgaexXU4yv5Eun(nPmKRnNm25kNzV1pjfxlJnG1HhvZEKLYubHonKWJpz9YYR)CH9OAwkLPccDAir12fMS8Lx5CAMki0PHeE8jRxwE9NlShvZsPsaFJdnURyyGGeqasHYbGSmjmMmP94tVdFPzaVAOv4IOZeOvJLRyUcrWb3CLZIOZeOvJLRyUcrcSRCjLox5Si6mbA1y5kMRqK4RYAXUYL8yn1p0ll5hYFOdbfyEmyIwbmA51)Rn0HMRC(qRb2p0QnegFiE9NlShvFOaFiCvT4yv5Eun(nPmKxR2jaEGmg2JSuWQPCbGrcOaZJbt0kGrlV(FTHsZRYavJAXCLZwOaZJbt0kGrlV(FTHeasHym9CLZcOaZJbt0kGrlV(FTHSkGRnjGQrDAgmx5SakW8yWeTcy0YR)xBiXAintfe60qcp(K1llV(Zf2JQzPmGVJvL7r143KYqfW1MSKSdMchvZEKLcwnLlamsafyEmyIwbmA51)RnuAEvgOAulMRC2cfyEmyIwbmA51)RnKaqkeJPNRCwafyEmyIwbmA51)RnKvbCTjbunQtZG5kNfqbMhdMOvaJwE9)AdjwdPzQGqNgs4XNSEz51FUWEunlLb8DSQCpQg)MugMbf2NLXzpYsbRMYfagjGcmpgmrRagT86)1gknVkdunQfZvoBHcmpgmrRagT86)1gsaifIX0ZvolGcmpgmrRagT86)1gYMbf2fq1OondMRCwafyEmyIwbmA51)RnKynKMPccDAiHhFY6LLx)5c7r1SugW3XQY9OA8BszixngRY9OARjWo7T(jP86pxypQ2o8OyI9ilLPccDAiHhFY6LLx)5c7r1VlvUhRk3JQXVjLHmvqOtdX(ct2kNTW4qsLG9fMSJEcdz5k2JgMujyV1pjnhaYonk2TdvzIgg7mvZIKYubHonKWJpz9YYR)CH9O6XxMEx5EuTihaYonk2f5LXybe)rbWiRhFA8vUhvlWpr2JgMDOgrarEzmwabT4Eu94ipVkdunQf4Ni7rdZouJiGaqFnA87mvqOtdj84twVS86pxypQoL0mvqOtdj84twVS86pxypQ(9Ca7XTa6RrJHdoxnu7cWQjBLTd1icKEUYzby1KTY2HAebeq1OonVkdunQfGvt2kBhQreqaOVgn(DL7r1ICai70OyxKxgJfq8hfaJSE8PXx5EuTa)ezpAy2HAebe5LXybe0I7r1JJ88Qmq1OwGFIShnm7qnIaca91OXVZRYavJAby1KTY2HAebea6RrJtjnVkdunQfGvt2kBhQreqaOVgn(9Ca7XTa6RrJpwvUhvJFtkdzQGqNgI9w)K0HNI6qw7qvMOHXot1SiPmvqOtdj84twVS86pxypQ(DL7r1IHNI6qwB2OFclYlJXci(JcGrwp(04RCpQwGFIShnm7qnIaI8YySacAX9O6XrEEvgOAulWpr2JgMDOgrabG(A043zQGqNgs4XNSEz51FUWEuDkPzQGqNgs4XNSEz51FUWEu975a2JBb0xJgdhCGvt5caJe4vBLmAyy70qyC0WGdop(07W3XQY9OA8Bsziy1KTY2HAebypYsNRCwawnzRSDOgrabunQtZG5kNf5aqyVaFbGuUNwEMki0PHeE8jRxwE9NlShvZsPZvolaRMSv2ouJiGaAbupQontfe60qcp(K1llV(Zf2JQzPY9OAroaKDAuSlYlJXci(JcGrwp(eCWXubHonKWJpz9YYR)CH9OAwMdypUfqFnACkhRk3JQXVjLHC1ySk3JQTMa7S36NKcQb7WJIj2JS05kNfGvt2kBhQreqSgslptfe60qcp(K1llV(Zf2JQzPCt5yn1pKmZd1hk1sbqCf7rd7qSiJ(PdL4GqsI9dXIcaDi4zuSJpe(PwgOdnPdTWe0H86qWOMaQthk1Q8dL4asLeFiTHoKxhIK1Pg6qWZOyNah6LrXobehRk3JQXVjLH5aq2PrXo7lmzRC2cJdjvc2xyYo6jmKLRypAysLG9ilLbmvqOtdjYbGStJID7qvMOHLwEMki0PHeE8jRxwE9NlShvZs5chCk3dMKLA6heMLszQGqNgs8OailxXUnB0pHDqijLMb5aqyxbobek3dMuAgmx5S4PCl2bKkPaqk3tl)CLZIhs9OHzxdcaPCpTY9OAr2OFc7GqssqYs8Ltwa91OXVlxb8bhC8hfaJW2mq5EuTAyPuzKskhRP(HE5xGOHDiwuaiSRaNaSFiwuaOdbpJID8HuaDOfMGoeo(HrbggpKxhcAbIg2Hsv9NlShvlo0ll1eqnggz)q(dX4HuaDOfMGoKxhcg1eqD6qPwLFOehqQK4dn6H6dXbHJp0OWyoux(HM0HgPyNGoK2qhAu4phcEgf7e4qVmk2ja7hYFigpe(PwgOdnPdHhaKcDOA5hYRd91ODn6d5p0HGNrXobo0lJIDcCO5kNfhRk3JQXVjLH5aq2PrXo7lmzRC2cJdjvc2xyYo6jmKLRypAysLG9ilnhac7kWjGq5EWKsZFuamcZsPsKMbmvqOtdjYbGStJID7qvMOHLwEgOCpQwKdanvJrqYs8LhnS0mq5EuTyGrqnnk2frBZMa2JNEUYzXdPE0WSRbbGuUdhCk3JQf5aqt1yeKSeF5rdlndMRCw8uUf7asLuaiL7WbNY9OAXaJGAAuSlI2MnbShp9CLZIhs9OHzxdcaPCpndMRCw8uUf7asLuaiL7PCSM6hc(JzfqhIRddrd7qSOaqhcEgf7hI)Oaye(qJEcdDi(J2nzIg2HsEIShnSdjZwJiWXQY9OA8BszyoaKDAuSZ(ct2rpHHSCf7rdtQeShzPk3JQf4Ni7rdZouJiGGKL4lpAyPZlJXci(JcGrwp(07k3JQf4Ni7rdZouJiGWdUKwabT4EuD65kNfpLBXoGujfq1OoThFILsi3JvL7r143KYqUAmwL7r1wtGD2B9tsXU2qkaYckx9OA2JSu5zQGqNgs4XNSEz51FUWEunlLBkPNRCwawnzRSDOgrabunQpwvUhvJFtkdX8cWFowpwvUhvJfk3dMK1vd1owQjygnm7S(t2JSuL7btYsn9dcZsjspx5SGx)5c7r1cOAuNwEMki0PHeE8jRxwE9NlShvZsEvgOAulmbZOHzN1FkGwa1JQHdoMki0PHeE8jRxwE9NlShv)Uu5MYXQY9OASq5EWKSUAO2XVjLHFYPcWEKLYubHonKWJpz9YYR)CH9O63Lkx4GtEEvgOAul(KtfqaTaQhv)otfe60qcp(K1llV(Zf2JQtZaxnu7cWQjBLTd1icKcCW5QHAxawnzRSDOgrG0ZvolaRMSv2ouJiGynKMPccDAiHhFY6LLx)5c7r1Su5EuT4tovabVkdunQHdUCa7XTa6RrJFNPccDAiHhFY6LLx)5c7r1hRk3JQXcL7btY6QHAh)MugcbuyvJTtaP(d7rwQRgQDHAizXoqXP2k2Mxagtl)CLZcE9NlShvlGQrDAgmx5S4PCl2bKkPaqk3t5y9yv5EunwWR)CH9OAlVkdunQXshkpQ(yv5EunwWR)CH9OAlVkdunQXVjLHttvq28cW4XQY9OASGx)5c7r1wEvgOAuJFtkdNeatajJg2XQY9OASGx)5c7r1wEvgOAuJFtkdZbGMMQGowvUhvJf86pxypQ2YRYavJA8BszO2Cc7a1y5QXCSQCpQgl41FUWEuTLxLbQg143KYWfMSHtF8XQY9OASGx)5c7r1wEvgOAuJFtkdxyYgo9zFHjBLZwyCiPsWoLZe3TT(jPWmkuOEbW2PcbJypYsvUhvl(KtfqeTnBcypUfqFnA87sLRa(owvUhvJf86pxypQ2YRYavJA8BszOhFYosbdShzPGvt5caJeo9hkGASJuWq65kNfKSp6c7r1I1WX6XQY9OASGx)5c7r12HhftsnbShhBH)Xcc2NAN9ilDUYzbV(Zf2JQfq1O(yn1puQb7XxD6qp1OdzQg2Hsv9NlShvFOrHXCiJI9d5pAlj(qEDOKvFi4)rdJn8HGNHW4OHDiVoee5e4hnDONA0HyrbGoe8mk2Xhc)uld0HM0HwycsCSQCpQgl41FUWEuTD4rX0Bszitfe60qSVWKTYzlmoKujyFHj7ONWqwUI9OHjvc2B9tsjzDQHiilV(Zf2JQTa6RrJzVgKIjNDMQzrsNRCwWR)CH9OAbG(A043MRCwWR)CH9OAb0cOEu94ipVkdunQf86pxypQwaOVgn(95kNf86pxypQwaOVgnof2JSuE1qRWfrNjqRglxXCfIowt9db)bbHpK)qhcAbupQ(qv(q(dDOKvFi4)rdJn8HGNHW4OHDOuv)5c7r1hYRd5p0HOg6qv(q(dDi(caO2puQQ)CH9O6df5d5p0H4k2p0OAzGoeV(dgYPdbTard7q(tGpuQQ)CH9OAXXQY9OASGx)5c7r12HhftVjLHmvqOtdX(ct2kNTW4qsLG9fMSJEcdz5k2JgMujyV1pjLK1PgIGS86pxypQ2cOVgnM9AqQcbXot1SiPmvqOtdjWsoTqlG6r1ShzP8QHwHlIotGwnwUI5keLw(5kNf4vBLmAyy70qyC0WSasHyuSgGdoMki0PHeKSo1qeKLx)5c7r1wa91OXSucb8noW4qIVk74i)CLZc8QTsgnmSDAimoAyIVkRf7kxYXFUYzbE1wjJgg2oneghnmb2vUKPKYXQY9OASGx)5c7r12HhftVjLHtfMTYwheCjXShzPZvol41FUWEuTaQg1hRk3JQXcE9NlShvBhEum9MugAcMrdZoR)K9ilv5EWKSut)GWSuI0Zvol41FUWEuTaQg1hRP(HKzc)Pw(HEjDMaTAouQumxHi2pe8pwy)qlmDiwuaOdbpJID8Hg9q9H8hIXdnQA28d9xn)5qCq44dPn0Hg9q9HyrbGWEb(hkWhcQg1IJvL7r1ybV(Zf2JQTdpkMEtkdZbGStJID2xyYw5SfghsQeSVWKD0tyilxXE0WKkb7rwQ8k3dMKLA6he(DPk3dMKfQCraRdNGdogWRYavJAXWtrDiRnB0pHfasHymL0mGxn0kCr0zc0QXYvmxHO08hfaJWSuQePNRCwWR)CH9OAXAindMRCwKdaH9c8fas5EAgmx5S4PCl2bKkPaqk3t)uUf7asL0IhiJbBJ2MnbSh)T5kNfpK6rdZUgeas5(7Y4yn1pKmt4ph6L0zc0Q5qPsXCfIy)qSOaqhcEgf7hAHPdHFQLb6qt6qkeu4r1QHXdXRg7anAc6q46q(J6hk8df4d1LFOjDOfMGo0QnegFOxsNjqRMdLkfZvi6qb(q6Sw(H86qKSdbGouboK)qa6qkGo0Va0H8hTpe11c2ZHyrbGoe8mk2XhYRdrY6udDOxsNjqRMdLkfZvi6qEDi)Hoe1qhQYhkv1FUWEuT4yv5EunwWR)CH9OA7WJIP3KYqMki0PHyFHjBLZwyCiPsW(ct2rpHHSCf7rdtQeS36NKsYoqCNGS5aq2PrXoM9AqkMC2zQMfjv5EuTihaYonk2f8hfaJW2mq5EuTAEtEMki0PHeKSo1qeKLx)5c7r1wa91OXJ)CLZIOZeOvJLRyUcrcOfq9O6ugp4vzGQrTihaYonk2fqlG6r1ShzP8QHwHlIotGwnwUI5keDSQCpQgl41FUWEuTD4rX0Bszitfe60qSVWKTYzlmoKujyFHj7ONWqwUI9OHjvc2B9tsBIGiiBoaKDAuSJzVgKIjNDMQzrs5uyKNPccDAibjRtnebz51FUWEuTfqFnA84H8ZvolIotGwnwUI5kejGwa1JQhFyCiXxLnLuypYs5vdTcxeDMaTASCfZvi6yv5EunwWR)CH9OA7WJIP3KYWCai70OyN9fMSvoBHXHKkb7lmzh9egYYvShnmPsWEKLkVY9GjzPM(bHFxQY9GjzHkxeW6Wj4GJb8Qmq1Owm8uuhYAZg9tybGuigtjnVAOv4IOZeOvJLRyUcrP5pkagHzPujslptfe60qcs2bI7eKnhaYonk2XSuktfe60qIMiicYMdazNgf7y4GJPccDAibjRtnebz51FUWEuTfqFnA87sNRCweDMaTASCfZvisaTaQhvdhCZvolIotGwnwUI5kejWUYL8DzahCZvolIotGwnwUI5keja0xJg)omoK4RYchC8Qmq1OwGFIShnm7qnIacaPqmMw5EWKSut)GWSuktfe60qcE9NlShvBXpr2JgMDOgrG08Ij1A7IoG942SsPKEUYzbV(Zf2JQfRH0YZG5kNf5aqyVaFbGuUdhCZvolIotGwnwUI5keja0xJg)UCfWxkPzWCLZINYTyhqQKcaPCp9t5wSdivslEGmgSnAB2eWE83MRCw8qQhnm7AqaiL7VlJJvL7r1ybV(Zf2JQTdpkMEtkd51QDcGhiJH9ilfSAkxayKakW8yWeTcy0YR)xBO0ZvolGcmpgmrRagT86)1gsavJ60ZvolGcmpgmrRagT86)1gYQaU2KaQg1P5vzGQrTyUYzluG5XGjAfWOLx)V2qcaPqmMMbUAO2fGvt2kBhQre4yv5EunwWR)CH9OA7WJIP3KYqfW1MSKSdMchvZEKLcwnLlamsafyEmyIwbmA51)Rnu65kNfqbMhdMOvaJwE9)AdjGQrD65kNfqbMhdMOvaJwE9)AdzvaxBsavJ608Qmq1Owmx5SfkW8yWeTcy0YR)xBibGuigtZaxnu7cWQjBLTd1icCSQCpQgl41FUWEuTD4rX0BszyguyFwgN9ilfSAkxayKakW8yWeTcy0YR)xBO0ZvolGcmpgmrRagT86)1gsavJ60ZvolGcmpgmrRagT86)1gYMbf2fq1O(yv5EunwWR)CH9OA7WJIP3KYWmOWUTlMk7rwky1uUaWibmqGnmAdEWnu65kNf86pxypQwavJ6JvL7r1ybV(Zf2JQTdpkMEtkd5QXyvUhvBnb2zV1pjv5EWKSUAO2XhRk3JQXcE9NlShvBhEum9MugYR)CH9OA2xyYw5SfghsQeSVWKD0tyilxXE0WKkb7rw6CLZcE9NlShvlGQrDA5zay1uUaWibuG5XGjAfWOLx)V2qWb3CLZcOaZJbt0kGrlV(FTHeRb4GBUYzbuG5XGjAfWOLx)V2q2mOWUynK2vd1UaSAYwz7qnIaP5vzGQrTyUYzluG5XGjAfWOLx)V2qcaPqmMsA5zay1uUaWibmqGnmAdEWneCWbrZvolGbcSHrBWdUHeRHuslVY9OAXNCQaIOTzta7XtRCpQw8jNkGiAB2eWEClG(A043Lkxblgo4uUhvlW8cWFeKSeF5rdlTY9OAbMxa(JGKL4lNSa6RrJFxUcwmCWPCpQwKdanvJrqYs8LhnS0k3JQf5aqt1yeKSeF5KfqFnA87YvWIHdoL7r1Ibgb10OyxqYs8LhnS0k3JQfdmcQPrXUGKL4lNSa6RrJFxUcwmCWPCpQwKn6NWoiKKeKSeF5rdlTY9OAr2OFc7GqssqYs8Ltwa91OXVlxbloLJ1u)qVu)HahIxLbQg14d5pQFi8tTmqhAshAHjOdnk8NdLQ6pxypQ(q4NAzGou1ggp0Ko0ctqhAu4phs7dPCFPMdLQ6pxypQ(qCf7hsBOd1LFOrH)Ci9qjR(qW)JggB4dbpdHXrd7qdGIlowvUhvJf86pxypQ2o8Oy6nPmKRgJv5EuT1eyN9w)KuE9NlShvB5vzGQrnM9ilDUYzbV(Zf2JQfgf7ws2HaqVlv5EuTGx)5c7r1cJID7ctqhRk3JQXcE9NlShvBhEum9MugMn6NWoiKKypYsLFUYzXt5wSdivsbGuUNw5EWKSut)GWSuktfe60qcE9NlShvBZg9tyhessPahCYpx5Sihac7f4laKY90k3dMKLA6heMLszQGqNgsWR)CH9OAB2OFc7GqsA8bRMYfagjYbGWEb(PCSQCpQgl41FUWEuTD4rX0Bsz4aJGAAuSZEKLox5SaVARKrddBNgcJJgMfqkeJI1q65kNf4vBLmAyy70qyC0WSasHyuaOVgnMLCf7wp(0XQY9OASGx)5c7r12HhftVjLHdmcQPrXo7rw6CLZICaiSxGVaqk3pwvUhvJf86pxypQ2o8Oy6nPmCGrqnnk2zpYsNRCwmWiO4gf)fas5E65kNfdmckUrXFbG(A0ywYvSB94tPLFUYzbV(Zf2JQfa6RrJzjxXU1JpbhCZvol41FUWEuTaQg1PKw5EWKSut)GWVZubHonKGx)5c7r12Sr)e2bHK0XQY9OASGx)5c7r12HhftVjLHdmcQPrXo7rw6CLZINYTyhqQKcaPCp9CLZcE9NlShvlwdhRk3JQXcE9NlShvBhEum9MugoWiOMgf7ShzPdaIPfghsiHaZla)j9CLZIhs9OHzxdcaPCpTY9GjzPM(bHFNPccDAibV(Zf2JQTzJ(jSdcjPJ1u)qVC4OHDOKNi7rd7qYS1icCiOfiAyhkv1FUWEu9H86qac7fGoelka0HGNrX(H0g6qYSpf1HShIfz0pDi(JcGr4dX1(qt6qtQPCWd1W(HMl)ql8snggpu1ggpu1hc(RsnIJvL7r1ybV(Zf2JQTdpkMEtkdXpr2JgMDOgra2JS05kNf86pxypQwSgsZaL7r1ICai70OyxWFuamcNw5EWKSut)GWSuktfe60qcE9NlShvBXpr2JgMDOgrG0k3JQfdpf1HS2Sr)ewKxgJfq8hfaJSE8jwMxgJfqqlUhvZE0obaRb3gzPk3JQf5aq2PrXUG)OayewQY9OAroaKDAuSl(QSw(JcGr4JvL7r1ybV(Zf2JQTdpkMEtkdhEkQdzTzJ(jm7rw6CLZcE9NlShvlwdPLxEL7r1ICai70OyxWFuamc)UePD1qTlgyeuCJI)PvUhmjl10piSujsbo4yGRgQDXaJGIBu8ho4uUhmjl10pimlLiL0ZvolEi1JgMDniaKY93Ek3IDaPsAXdKXGTrBZMa2J)UmowvUhvJf86pxypQ2o8Oy6nPmmB0pHDqijXEKLox5SGx)5c7r1cOAuNMxLbQg1cE9NlShvla0xJg)oxXU1JpLw5EWKSut)GWSuktfe60qcE9NlShvBZg9tyhesshRk3JQXcE9NlShvBhEum9MugMdanvJH9ilDUYzbV(Zf2JQfq1OonVkdunQf86pxypQwaOVgn(DUIDRhFknd4vdTcxKn6NSkNdipQ(yv5EunwWR)CH9OA7WJIP3KYqmVa8h2JS05kNf86pxypQwaOVgnMLCf7wp(u65kNf86pxypQwSgGdU5kNf86pxypQwavJ608Qmq1OwWR)CH9OAbG(A0435k2TE8PJvL7r1ybV(Zf2JQTdpkMEtkdnbZOHzN1FYEKLox5SGx)5c7r1ca91OXVdJdj(QSPvUhmjl10pimlL4yv5EunwWR)CH9OA7WJIP3KYqiGcRASDci1FypYsNRCwWR)CH9OAbG(A043HXHeFv20Zvol41FUWEuTynCSQCpQgl41FUWEuTD4rX0BsziMxa(d7rwQRayKlEi14pIbU)UuzsUPD1qTlWKcIgM1Rf)5y9yv5EunwaQb7WJIjPzJ(jSdcjj2JSuL7btYsn9dcZsPmvqOtdjEk3IDaPsAZg9tyhessPLFUYzXt5wSdivsbGuUdhCZvolYbGWEb(caPCpLJvL7r1ybOgSdpkMEtkdhyeutJID2JS05kNf4vBLmAyy70qyC0WSasHyuSgspx5SaVARKrddBNgcJJgMfqkeJca91OXSKRy36XNowvUhvJfGAWo8Oy6nPmCGrqnnk2zpYsNRCwKdaH9c8fas5(XQY9OASaud2HhftVjLHdmcQPrXo7rw6CLZINYTyhqQKcaPC)yn1p0lhMou10HyrbGoe8mk2pePadJhk6dnEwYShkYhIXADiOQzZp0JYKoef(dbouQfPE0Wo0l3WHkWHsTk)qjoGujpeJKFiTHoef(dbyHdjVMYHEuM0H(fGoK)O9H8r1HudGuigz)qYpt5qpkt6qWFgswSduCQTYg(qSOfGXdbifIXd51HwyI9dvGdjppLdLqkiAyh61AXFouGpKY9Gjjo0lF1S5hcQoK)e4dn6jm0HEua0H4k2Jg2Hyrg9toiKKWhQahA0d1hkz1hc(F0WydFi4zimoAyhkWhcqkeJIJvL7r1ybOgSdpkMEtkdZbGStJID2xyYw5SfghsQeSVWKD0tyilxXE0WKkb7rwkdyQGqNgsKdazNgf72HQmrdl9CLZc8QTsgnmSDAimoAywaPqmkGQrDAL7btYsn9dc)otfe60qIhfaz5k2TzJ(jSdcjP0mihac7kWjGq5EWKslpdMRCw8qQhnm7AqaiL7PzWCLZINYTyhqQKcaPCpndgaetBLZwyCiroaKDAuSNwEL7r1ICai70OyxWFuamcZsPYao4K3vd1UqnKSyhO4uBfBZlaJP5vzGQrTacOWQgBNas9hbGuigtbo4K3vd1UatkiAywVw8N0UcGrU4HuJ)ig4(7sLj5MskPCSM6h6LdthIffa6qWZOy)qu4pe4qqlq0WoKEiwuaOPAmmuMLrqnnk2pexX(Hg9q9HsTi1Jg2HE5gouGpKY9GjDOcCiOfiAyhIKL4lNo0OWFoucPGOHDOxRf)rCSQCpQgla1GD4rX0BszyoaKDAuSZ(ct2kNTW4qsLG9fMSJEcdz5k2JgMujypYszatfe60qICai70Oy3ouLjAyPzqoae2vGtaHY9GjLwE5Lx5EuTihaAQgJGKL4lpAyPLx5EuTihaAQgJGKL4lNSa6RrJFxUc4do4yay1uUaWiroae2lWpf4Gt5EuTyGrqnnk2fKSeF5rdlT8k3JQfdmcQPrXUGKL4lNSa6RrJFxUc4do4yay1uUaWiroae2lWpLuspx5S4HupAy21Gaqk3tbo4K3vd1UatkiAywVw8N0UcGrU4HuJ)ig4(7sLj5Mw(5kNfpK6rdZUgeas5EAgOCpQwG5fG)iizj(YJggCWXG5kNfpLBXoGujfas5EAgmx5S4HupAy21Gaqk3tRCpQwG5fG)iizj(YJgwAg8uUf7asL0IhiJbBJ2MnbShpLus5yv5EunwaQb7WJIP3KYqUAmwL7r1wtGD2B9tsvUhmjRRgQD8XQY9OASaud2HhftVjLHdmcQPrXo7rw6CLZIbgbf3O4Vaqk3tZvSB94tVpx5SyGrqXnk(la0xJgNMRy36XNEFUYzby1KTY2HAebea6RrJpwvUhvJfGAWo8Oy6nPmCGrqnnk2zpYshaetlmoKqcbMxa(t65kNfpK6rdZUgeas5EAxnu7cmPGOHz9AXFs7kag5Ihsn(JyG7VlvMKBAL7btYsn9dc)otfe60qINYTyhqQK2Sr)e2bHK0XQY9OASaud2HhftVjLHdpf1HS2Sr)eM9ilLbmvqOtdjgEkQdzTdvzIgw65kNfpK6rdZUgeas5EAgmx5S4PCl2bKkPaqk3tlVY9GjzHkxeW6WP3LbCWPCpyswQPFqywkLPccDAiXJcGSCf72Sr)e2bHKeCWPCpyswQPFqywkLPccDAiXt5wSdivsB2OFc7GqskLJvL7r1ybOgSdpkMEtkdX8cWFypYsDfaJCXdPg)rmW93LktYnTRgQDbMuq0WSET4phRk3JQXcqnyhEum9MugcbuyvJTtaP(d7rwQY9GjzPM(bHzPmowvUhvJfGAWo8Oy6nPmubCTjlj7GPWr1ShzPk3dMKLA6heMLszQGqNgsOaU2KLKDWu4O60FTvXa3zPuMki0PHekGRnzjzhmfoQ2(1wpwvUhvJfGAWo8Oy6nPmmB0pHDqijXEKLQCpyswQPFqywkLPccDAiXJcGSCf72Sr)e2bHK0XQY9OASaud2HhftVjLH5aqt1yowpwvUhvJfyxBifazbLREuT0Sr)e2bHKe7rwQY9GjzPM(bHzPuMki0PHepLBXoGujTzJ(jSdcjP0Ypx5S4PCl2bKkPaqk3HdU5kNf5aqyVaFbGuUNYXQY9OASa7AdPailOC1JQFtkdhyeutJID2JS05kNf5aqyVaFbGuUFSQCpQglWU2qkaYckx9O63KYWbgb10OyN9ilDUYzXt5wSdivsbGuUNEUYzXt5wSdivsbG(A043vUhvlYbGMQXiizj(YjRhF6yv5EunwGDTHuaKfuU6r1VjLHdmcQPrXo7rw6CLZINYTyhqQKcaPCpT8daIPfghsiHihaAQgdCWLdaHDf4eqOCpysWbNY9OAXaJGAAuSlI2MnbShpLJ1u)qVcy8qEDiyKFOe4)W7qdGIJpu04aIo04zjZEOHhft4dvGdLQ6pxypQ(qdpkMWhA0d1hAOW4yAiXXQY9OASa7AdPailOC1JQFtkdhyeutJID2JS05kNf4vBLmAyy70qyC0WSasHyuSgslpVkdunQfGvt2kBhQreqaOVgn(nL7r1cWQjBLTd1iciizj(YjRhF6nUIDRhFILZvolWR2kz0WW2PHW4OHzbKcXOaqFnAmCWXaxnu7cWQjBLTd1icKsAMki0PHeE8jRxwE9NlShv)gxXU1JpXY5kNf4vBLmAyy70qyC0WSasHyuaOVgn(yv5EunwGDTHuaKfuU6r1VjLHdmcQPrXo7rw6CLZINYTyhqQKcaPCpTRayKlEi14pIbU)UuzsUPD1qTlWKcIgM1Rf)5yv5EunwGDTHuaKfuU6r1VjLHdmcQPrXo7rw6CLZIbgbf3O4Vaqk3tZvSB94tVpx5SyGrqXnk(la0xJgFSM6h6LFbIg2H8h6qyxBifaDiq5QhvZ(HQ2W4Hwy6qSOaqhcEgf74dn6H6d5peJhsb0H6Yp0KIg2HgQYqqhkxGdnEwYShQahkv1FUWEuT4qVCy6qSOaqhcEgf7hIc)HahcAbIg2H0dXIcanvJHHYSmcQPrX(H4k2p0OhQpuQfPE0Wo0l3WHc8HuUhmPdvGdbTard7qKSeF50Hgf(ZHsifenSd9AT4pIJvL7r1yb21gsbqwq5Qhv)MugMdazNgf7SVWKTYzlmoKujyFHj7ONWqwUI9OHjvc2JSugKdaHDf4eqOCpysPzatfe60qICai70Oy3ouLjAyPLxE5vUhvlYbGMQXiizj(YJgwA5vUhvlYbGMQXiizj(YjlG(A043LRa(GdogawnLlamsKdaH9c8tbo4uUhvlgyeutJIDbjlXxE0WslVY9OAXaJGAAuSlizj(YjlG(A043LRa(GdogawnLlamsKdaH9c8tjL0ZvolEi1JgMDniaKY9uGdo5D1qTlWKcIgM1Rf)jTRayKlEi14pIbU)UuzsUPLFUYzXdPE0WSRbbGuUNMbk3JQfyEb4pcswIV8OHbhCmyUYzXt5wSdivsbGuUNMbZvolEi1JgMDniaKY90k3JQfyEb4pcswIV8OHLMbpLBXoGujT4bYyW2OTzta7XtjLuowvUhvJfyxBifazbLREu9Bsz4aJGAAuSZEKLoaiMwyCiHecmVa8N0ZvolEi1JgMDniaKY90UAO2fysbrdZ61I)K2vamYfpKA8hXa3FxQmj30k3dMKLA6he(DMki0PHepLBXoGujTzJ(jSdcjPJvL7r1yb21gsbqwq5Qhv)Mugo8uuhYAZg9ty2JSugWubHonKy4POoK1ouLjAyPLNbUAO2fzq9T(dzv8dHHdoL7btYsn9dcZsjsjT8k3dMKfQCraRdNExgWbNY9GjzPM(bHzPuMki0PHepkaYYvSBZg9tyhessWbNY9GjzPM(bHzPuMki0PHepLBXoGujTzJ(jSdcjPuowvUhvJfyxBifazbLREu9BszixngRY9OARjWo7T(jPk3dMK1vd1o(yv5EunwGDTHuaKfuU6r1VjLHqafw1y7eqQ)WEKLQCpyswQPFqywkXXQY9OASa7AdPailOC1JQFtkdX8cWFypYsDfaJCXdPg)rmW93LktYnTRgQDbMuq0WSET4phRP(HKzc)5quxlyphYvamYXSFOWpuGpKEiyA0hYRdXvSFiwKr)e2bHK0Hu8HYHXqGdfn2jf6qv(qSOaqt1yehRk3JQXcSRnKcGSGYvpQ(nPmubCTjlj7GPWr1ShzPk3dMKLA6heMLszQGqNgsOaU2KLKDWu4O60FTvXa3zPuMki0PHekGRnzjzhmfoQ2(1wpwvUhvJfyxBifazbLREu9Bszy2OFc7GqsI9ilv5EWKSut)GWSuktfe60qIhfaz5k2TzJ(jSdcjPJvL7r1yb21gsbqwq5Qhv)MugMdanvJz7BFVb]] )

end
