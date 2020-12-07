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


    spec:RegisterPack( "Fire", 20201206, [[deL9pdqiGQEKiPCjrvfTjrQpHs1OiQ6uIeRsuv8kvPmluk3suv1Ui8luqdJOOJrewgrHNruHPjsQCnucTnvjvFdfqnoua6COaY6qbAEQs19is7dLO)HsGOdIsaleOYdfjzIOaOlsurTruc6JQsk1ijQiDsrvLwjkPxIsGAMQsYnvLuYofv5NQskgQiPklvuvHNkIPQkXvrbGTIsG0xjQiglrL2Rs9xknyihM0Iv0Jr1KvvxgzZk8zGmAvXPfwnkbcVMiA2uCBa7wQFlz4IYXfvLwoONd10P66kz7OOVlQmEIsNhfA9IKQA(aL9RYBj2VSt(Qt78KHmLHmLqgY81fYqIuNmLPCStCgZODsMYLubr7KwbODclmG0ojtz0u6F)YobxliN2jpUNHzqgYqqH)SMcEbWqCaSmQhvZH6Wzioa4mCNmxHXZV9EUt(Qt78KHmLHmLqgY81fYqMSOes867eD5pfCNKeaPAN8e)p175o5ty(oj1oelmG0HETuq0XAQDOh3ZWmidziOWFwtbVayioawg1JQ5qD4mehaCgESMAhIbiXjGjbp0RZ2HKHmLHmpwpwtTdLQhTbryg8yn1ou(Figay6qJa0JBHeGgn(qq1Fi4H8hTpKRqqKl8aGSEz)bDOrbpKrXE(JjE1)dPZWeoJhAHvqewCSMAhk)p0RQct9H4k2peKY3vajaQD8Hgf8qPQaMlShvFi5dbjy7q)Qz3p0tz(hk8dnk4H0dnGe(5qVwKtf8qCf7PiowtTdL)hso360qhc7WG7hI)qCjJg0HQ(q6HguUdnkOK4df9H8h6qSaPEV6qEDii9xC6q5kOKMs)IDIjWoE)Yobwz2Shft7x25jX(LDc160q)n42jCy4em0DIY9GjzPMaccFiwk9qmvyOtdjEk3IDiPsAhgfGWomKKou6dj)HMRXq8uUf7qsLuajL7hcmWo0CngIrajSxqabKuUFOu2jk3JQ3jdJcqyhgssBFNNm2VStOwNg6Vb3oHddNGHUtMRXqGxTvYObHTtdHXrdYcj9ZOyLDO0hAUgdbE1wjJge2oneghnilK0pJcibOrJpelpexXU1daANOCpQENKXiSMgf7BFNNCSFzNqTon0FdUDchgobdDNmxJHyeqc7feqajL77eL7r17KmgH10OyF778sD7x2juRtd93GBNWHHtWq3jZ1yiEk3IDiPskGKY9DIY9O6DsgJWAAuSV9DES4(LDc160q)n42jlmzZ9egYYvShnODEsSt4WWjyO7eWFiMkm0PHeJas2PrXUnRkt0Gou6dnxJHaVARKrdcBNgcJJgKfs6NrXVY1hk9HuUhmjl1eqq4d9(HyQWqNgs8OWVLRy3omkaHDyijDO0hc8hAeqc7k0jOq5EWKou6dj)Ha)HMRXq8qQhni7ktajL7hk9Ha)HMRXq8uUf7qsLuajL7hk9Ha)HYGetBngwq8VyeqYonk2pu6dj)HuUhvlgbKStJIDb)rHGi8HyP0djJdbgyhs(d5QHAxOgswSdvCQVITJfKrb160q)dL(q8Qm)kxl(qfu1y7esQ)iGK(z8qPCiWa7qYFixnu7cmPWObz9AXFeuRtd9pu6d5kee5Ihsn(JiJ7h6DPhsoK5Hs5qPCOu2jlmzRXWcI)35jXor5Eu9ozeqYonk23(oVxF)YoHADAO)gC7KfMS5Ecdz5k2Jg0opj2jCy4em0Dc4petfg60qIraj70Oy3MvLjAqhk9Ha)HgbKWUcDckuUhmPdL(qYFi5pK8hs5EuTyeqAQgJGKL4lpAqhk9HK)qk3JQfJast1yeKSeF5KfsaA04d9(HKPGfpeyGDiWFi4QPrbbrIrajSxqab160q)dLYHadSdPCpQwKXiSMgf7cswIV8ObDO0hs(dPCpQwKXiSMgf7cswIVCYcjanA8HE)qYuWIhcmWoe4peC10OGGiXiGe2liGGADAO)Hs5qPCO0hAUgdXdPE0GSRmbKuUFOuoeyGDi5pKRgQDbMuy0GSET4pcQ1PH(hk9HCfcICXdPg)rKX9d9U0djhY8qPpK8hAUgdXdPE0GSRmbKuUFO0hc8hs5EuTaZli)rqYs8LhnOdbgyhc8hAUgdXt5wSdjvsbKuUFO0hc8hAUgdXdPE0GSRmbKuUFO0hs5EuTaZli)rqYs8LhnOdL(qG)qpLBXoKujT4mYyW2OTdta6XpukhkLdLYozHjBngwq8)opj2jk3JQ3jJas2PrX(235XaVFzNqTon0FdUDIY9O6DcxngRY9OARjW(oXey32kaTtuUhmjRRgQD8235XaUFzNqTon0FdUDchgobdDNmxJHiJryXnkgqajL7hk9H4k2TEaqh69dnxJHiJryXnkgqajanA8HsFiUIDRha0HE)qZ1yiGRMS1WMv5iOasaA04DIY9O6DsgJWAAuSV9DEmq7x2juRtd93GBNWHHtWq3jzqIPfe)lKqG5fK)CO0hAUgdXdPE0GSRmbKuUFO0hYvd1UatkmAqwVw8hb160q)dL(qUcbrU4HuJ)iY4(HEx6HKdzEO0hs5EWKSutabHp07hIPcdDAiXt5wSdjvs7WOae2HHK0or5Eu9ojJrynnk23(opjK5(LDc160q)n42jCy4em0Dc4petfg60qISNI6qwBwvMObDO0hAUgdXdPE0GSRmbKuUFO0hc8hAUgdXt5wSdjvsbKuUFO0hs(dPCpys2F5IauhoDO3pKmoeyGDiL7btYsnbee(qSu6HyQWqNgs8OWVLRy3omkaHDyijDiWa7qk3dMKLAcii8HyP0dXuHHonK4PCl2HKkPDyuac7Wqs6qPStuUhvVtYEkQdzTdJcq4TVZtcj2VStOwNg6Vb3oHddNGHUtCfcICXdPg)rKX9d9U0djhY8qPpKRgQDbMuy0GSET4pcQ1PH(7eL7r17emVG8NTVZtczSFzNqTon0FdUDchgobdDNOCpyswQjGGWhILhsg7eL7r17Kpubvn2oHK6pBFNNeYX(LDc160q)n42jCy4em0DIY9GjzPMaccFiwk9qmvyOtdjuixBYsYMzkCu9HsFiaTvrg3pelLEiMkm0PHekKRnzjzZmfoQ2cOTUtuUhvVtuixBYsYMzkCu9235jrQB)YoHADAO)gC7eomCcg6or5EWKSutabHpelLEiMkm0PHepk8B5k2TdJcqyhgss7eL7r17KHrbiSddjPTVZtcwC)Yor5Eu9ozeqAQgZoHADAO)gCBF77Kpn0LX3VSZtI9l7eQ1PH(BWTt4WWjyO7eWFi4QPrbbrIFG5rMjAfYOLxaaA)fuRtd93jk3JQ3j8A1obXzKXS9DEYy)YoHADAO)gC7KkBNGjFNOCpQENWuHHon0oHPAw0oXvd1Uyeqc7k0jOGADAO)HYNdnciHDf6euajanA8HE7qYFiEvMFLRf8cyUWEuTasaA04dLphs(djXHY)dXuHHonKqYO)MObzH0FX9O6dLphYvd1UqYO)MObjOwNg6FOuoukhkFoe4peVkZVY1cEbmxypQwaj9Z4HYNdnxJHGxaZf2JQf)kxVtyQqBRa0oXdaY6LLxaZf2JQ3(op5y)YoHADAO)gC7KkBNaOYUtuUhvVtyQWqNgANWunlANWuHHonKGaYyesQXwWFRnNSFYOmEO8)qYFiEvMFLRfeqgJqsn2c(BT5K4VGQhvFO8)q8Qm)kxliGmgHKASf83AZjbKa0OXhkLdLphc8hIxL5x5AbbKXiKuJTG)wBojGK(zCNWHHtWq3ju(UISm6liGmgHKASf83AZPDctfABfG2jEaqwVS8cyUWEu9235L62VStOwNg6Vb3oPY2jaQS7eL7r17eMkm0PH2jmvZI2j8Qm)kxlaz0FOEbX2P(brcibOrJ3jCy4em0DcLVRilJ(cqg9hQxqSDQFq0oHPcTTcq7epaiRxwEbmxypQE778yX9l7eQ1PH(BWTtQSDcGk7or5Eu9oHPcdDAODct1SODYCngc4QjBnSzvockGeGgnENWHHtWq3jUAO2fWvt2AyZQCeuqTon0)qPp0CngcEbmxypQw8RC9oHPcTTcq7epaiRxwEbmxypQE778E99l7eQ1PH(BWTtQSDcGk7or5Eu9oHPcdDAODct1SODcVkZVY1c4QjBnSzvockGeGgn(qVDO5AmeWvt2AyZQCeu8xq1JQ3jCy4em0DIRgQDbC1KTg2SkhbfuRtd9pu6dnxJHGxaZf2JQf)kxFO0hIxL5x5AbC1KTg2SkhbfqcqJgFO3oelEO3petfg60qcpaiRxwEbmxypQENWuH2wbODIhaK1llVaMlShvV9DEmW7x2juRtd93GBNWHHtWq3jZ1yi4fWCH9OAXVY1hk9HyQWqNgs4baz9YYlG5c7r1hILhASmglK(lUhvFO0hs(dXRY8RCTaUAYwdBwLJGcibOrJpelp0yzmwi9xCpQ(qGb2Ha)HC1qTlGRMS1WMv5iOGADAO)Hs5qPpe4pK8hAUgdr0dc2QXYvmx)KyLDO0hAUgdXt5wSdjvsbKuUFOuou6dj)HuUhmjl1eqq4d9(HyQWqNgsWlG5c7r1w8tm8ObzZQCe8qGb2HuUhmjl1eqq4d9(HyQWqNgsWlG5c7r12HrbiSddjPdbgyhIPcdDAiHhaK1llVaMlShvFO8)qJLXyH0FX9O6dXYdPCpQ2YRY8RC9HszNOCpQENGFIHhniBwLJGBFNhd4(LDc160q)n42jCy4em0DI8hAUgdbVaMlShvl(vU(qPp0Cngc4QjBnSzvock(vU(qPpK8hIPcdDAiHhaK1llVaMlShvFO3pejlXxoz9aGoeyGDiMkm0PHeEaqwVS8cyUWEu9Hy5H4vz(vUwa1FOTBXzkusXFbvpQ(qPCOuoeyGDi5p0Cngc4QjBnSzvockwzhk9HyQWqNgs4baz9YYlG5c7r1hILhsoK5HszNOCpQENa1FOTBXzkuYTVZJbA)YoHADAO)gC7eomCcg6ozUgdbVaMlShvl(vU(qPp0Cngc4QjBnSzvock(vU(qPpetfg60qcpaiRxwEbmxypQ(qVFiswIVCY6baTtuUhvVt(K6pZc20235jHm3VStOwNg6Vb3oHddNGHUtyQWqNgs4baz9YYlG5c7r1h6DPhsoou6dnxJHGxaZf2JQf)kxVtuUhvVtaciSGyBnSEbbO23(opjKy)YoHADAO)gC7KfMS5Ecdz5k2Jg0opj2jk3JQ3jJas2PrX(oHddNGHUtuUhvlaciSGyBnSEbbO2fKSeF5rd6qPp0yzmwiXFuiiY6baDO8)qk3JQfabewqSTgwVGau7cswIVCYcjanA8HE)qPUdL(qG)qpLBXoKujT4mYyW2OTdta6Xpu6db(dnxJH4PCl2HKkPask33(opjKX(LDc160q)n42jCy4em0DYCngcEbmxypQw8RC9HsFOpnxJHaQ)qB3IZuOKwMlttqDgMWzu8RC9or5Eu9obiGWcAdafeT9DEsih7x2juRtd93GBNOCpQENaYO)q9cITt9dI2jCy4em0Dctfg60qcpaiRxwEbmxypQ(qS8qk3JQT8Qm)kxFO8)qS4oHgdI72wbODciJ(d1li2o1piA778Ki1TFzNqTon0FdUDchgobdDNWuHHonKWdaY6LLxaZf2JQp07spetfg60qcciJriPgBb)T2CY(jJY4oPvaANqazmcj1yl4V1Mt7eL7r17eciJriPgBb)T2CA778KGf3VStOwNg6Vb3oHddNGHUtyQWqNgs4baz9YYlG5c7r1hILspetfg60qIQTlmz5lVgJDsRa0obKHXShBnSkghaHr9O6DIY9O6DcidJzp2AyvmoacJ6r1BFNNeV((LDc160q)n42jCy4em0Dctfg60qcpaiRxwEbmxypQ(qVl9qS4oPvaANaOCDcjl(Hi3cSWbFNOCpQENaOCDcjl(Hi3cSWbF778KGbE)YoHADAO)gC7eomCcg6oHPcdDAiHhaK1llVaMlShvFiwk9qmvyOtdjQ2UWKLV8Amou6dj)HMRXqe9GGTASCfZ1pjWUYL8qspKmoeyGDiWFiE1)v4IOheSvJLRyU(jb160q)dbgyhIPcdDAibVaMlShvBR2UW0HadSdXuHHonKWdaY6LLxaZf2JQp0BhIfpelp0ia94wibOrJpu(5HuUhvB5vz(vU(qPStAfG2jFiP)rajltcJjZor5Eu9o5dj9pcizzsymz2(opjya3VStOwNg6Vb3oHddNGHUtyQWqNgs4baz9YYlG5c7r1hILspetfg60qIQTlmz5lVgJd92HKGfpu(Ci5petfg60qIQTlmz5lVgJdXYdjZdLYHsFi5pe4peLVRilJ(IpK0)iGKLjHXK5qGb2H4vz(vUw8HK(hbKSmjmMmcibOrJpelpelEOu2jTcq7eCTm2auhob3jk3JQ3j4AzSbOoCcU9DEsWaTFzNqTon0FdUDchgobdDNa(dXR(Vcxe9GGTASCfZ1pjOwNg6FO0hYda6qVFiw8qGb2HMRXqe9GGTASCfZ1pjWUYL8qsp0CngIOheSvJLRyU(jbGkRf7kxYDIY9O6DcxBozSZ1yStMRXW2kaTtW1YydqD4r1BFNNmK5(LDc160q)n42jCy4em0DcC10OGGiXpW8iZeTcz0YlaaT)cQ1PH(hk9H4vz(vUwmxJH9hyEKzIwHmA5faG2FbK0pJhk9HMRXq8dmpYmrRqgT8caq7VvHCTjXVY1hk9Ha)HMRXq8dmpYmrRqgT8caq7VyLDO0hIPcdDAiHhaK1llVaMlShvFiwEizWI7eL7r17eETANG4mYy2(opziX(LDc160q)n42jCy4em0DcC10OGGiXpW8iZeTcz0YlaaT)cQ1PH(hk9H4vz(vUwmxJH9hyEKzIwHmA5faG2FbK0pJhk9HMRXq8dmpYmrRqgT8caq7VvHCTjXVY1hk9Ha)HMRXq8dmpYmrRqgT8caq7VyLDO0hIPcdDAiHhaK1llVaMlShvFiwEizWI7eL7r17efY1MSKSzMchvV9DEYqg7x2juRtd93GBNWHHtWq3jWvtJccIe)aZJmt0kKrlVaa0(lOwNg6FO0hIxL5x5AXCng2FG5rMjAfYOLxaaA)fqs)mEO0hAUgdXpW8iZeTcz0YlaaT)2bSWU4x56dL(qG)qZ1yi(bMhzMOviJwEbaO9xSYou6dXuHHonKWdaY6LLxaZf2JQpelpKmyXDIY9O6DYawyFwgF778KHCSFzNqTon0FdUDchgobdDNWuHHonKWdaY6LLxaZf2JQp07spKm3jk3JQ3jC1ySk3JQTMa77etGDBRa0oHxaZf2JQTzpkM2(opzK62VStOwNg6Vb3ozHjBUNWqwUI9ObTZtIDIY9O6Dctfg60q7KfMS1yybX)78KyNWunlANWuHHonKWdaY6LLxaZf2JQpu(Fi54qVFiL7r1Iraj70OyxmwgJfs8hfcISEaqhk)pKY9OAb(jgE0GSzvockglJXcP)I7r1hkFoK8hIxL5x5Ab(jgE0GSzvockGeGgn(qVFiMkm0PHeEaqwVS8cyUWEu9Hs5qPpetfg60qcpaiRxwEbmxypQ(qVFOra6XTqcqJgFiWa7qUAO2fWvt2AyZQCeuqTon0)qPp0Cngc4QjBnSzvock(vU(qPpeVkZVY1c4QjBnSzvockGeGgn(qVFiL7r1Iraj70OyxmwgJfs8hfcISEaqhk)pKY9OAb(jgE0GSzvockglJXcP)I7r1hkFoK8hIxL5x5Ab(jgE0GSzvockGeGgn(qVFiEvMFLRfWvt2AyZQCeuajanA8Hs5qPpeVkZVY1c4QjBnSzvockGeGgn(qVFOra6XTqcqJgVtyQqBRa0ozeqYonk2TzvzIg0oPY2jyY3(opzWI7x2juRtd93GBNuz7em57eL7r17eMkm0PH2jmvZI2jmvyOtdj8aGSEz5fWCH9O6d9(HuUhvlYEkQdzTdJcqyXyzmwiXFuiiY6baDO8)qk3JQf4Ny4rdYMv5iOySmglK(lUhvFO85qYFiEvMFLRf4Ny4rdYMv5iOasaA04d9(HyQWqNgs4baz9YYlG5c7r1hkLdL(qmvyOtdj8aGSEz5fWCH9O6d9(HgbOh3cjanA8HadSdbxnnkiisGxTvYObHTtdHXrdsqTon0)qGb2H8aGo07hIf3jmvOTvaANK9uuhYAZQYenOTVZtgV((LDc160q)n42jCy4em0DYCngc4QjBnSzvock(vU(qPpe4p0CngIrajSxqabKuUFO0hs(dXuHHonKWdaY6LLxaZf2JQpelLEO5AmeWvt2AyZQCeu8xq1JQpu6dXuHHonKWdaY6LLxaZf2JQpelpKY9OAXiGKDAuSlglJXcj(JcbrwpaOdbgyhIPcdDAiHhaK1llVaMlShvFiwEOra6XTqcqJgFOu2jk3JQ3jWvt2AyZQCeC778Kbd8(LDc160q)n42jCy4em0DYCngc4QjBnSzvockwzhk9HK)qmvyOtdj8aGSEz5fWCH9O6dXYdjZdLYor5Eu9oHRgJv5EuT1eyFNycSBBfG2jWkZM9OyA778Kbd4(LDc160q)n42jlmzZ9egYYvShnODEsSt4WWjyO7eWFiMkm0PHeJas2PrXUnRkt0Gou6dj)HyQWqNgs4baz9YYlG5c7r1hILhsMhcmWoKY9GjzPMaccFiwk9qmvyOtdjEu43YvSBhgfGWomKKou6db(dnciHDf6euOCpyshk9Ha)HMRXq8uUf7qsLuajL7hk9HK)qZ1yiEi1JgKDLjGKY9dL(qk3JQfdJcqyhgsscswIVCYcjanA8HE)qYuWIhcmWoe)rHGiSDavUhvRMdXsPhsghkLdLYozHjBngwq8)opj2jk3JQ3jJas2PrX(235jdgO9l7eQ1PH(BWTtwyYM7jmKLRypAq78KyNWHHtWq3jJasyxHobfk3dM0HsFi(Jcbr4dXsPhsIdL(qG)qmvyOtdjgbKStJIDBwvMObDO0hs(db(dPCpQwmcinvJrqYs8LhnOdL(qG)qk3JQfzmcRPrXUiA7WeGE8dL(qZ1yiEi1JgKDLjGKY9dbgyhs5EuTyeqAQgJGKL4lpAqhk9Ha)HMRXq8uUf7qsLuajL7hcmWoKY9OArgJWAAuSlI2ombOh)qPp0CngIhs9ObzxzciPC)qPpe4p0CngINYTyhsQKciPC)qPStwyYwJHfe)VZtIDIY9O6DYiGKDAuSV9DEYHm3VStOwNg6Vb3ozHjBUNWqwUI9ObTZtIDIY9O6DYiGKDAuSVt4WWjyO7eL7r1c8tm8ObzZQCeuqYs8LhnOdL(qJLXyHe)rHGiRha0HE)qk3JQf4Ny4rdYMv5iOWdUKwi9xCpQ(qPp0CngINYTyhsQKIFLRpu6d5baDiwEijK5235jhsSFzNqTon0FdUDchgobdDNi)HyQWqNgs4baz9YYlG5c7r1hILhsMhkLdL(qZ1yiGRMS1WMv5iO4x56DIY9O6DcxngRY9OARjW(oXey32kaTtWU2Ff(TWYvpQE778KdzSFzNOCpQENG5fK)StOwNg6Vb323(ojds8cyQ((LDEsSFzNOCpQENOqU2KnANmgI77eQ1PH(BWT9DEYy)YoHADAO)gC7KkBNGjFNOCpQENWuHHon0oHPAw0orghkFoKRgQDXWOaKntD(JGADAO)HE7qYXHYNdb(d5QHAxmmkazZuN)iOwNg6Vt4WWjyO7eMkm0PHepLBXoKujTdJcqyhgsshs6HK5oHPcTTcq7KNYTyhsQK2HrbiSddjPTVZto2VStOwNg6Vb3oPY2jyY3jk3JQ3jmvyOtdTtyQMfTtKXHYNd5QHAxmmkazZuN)iOwNg6FO3oKCCO85qG)qUAO2fdJcq2m15pcQ1PH(7eomCcg6oHPcdDAiXJc)wUID7WOae2HHK0HKEizUtyQqBRa0o5rHFlxXUDyuac7WqsA778sD7x2juRtd93GBNuz7em57eL7r17eMkm0PH2jmvZI2jYXHYNd5QHAxmmkazZuN)iOwNg6FO3o0RFO85qG)qUAO2fdJcq2m15pcQ1PH(7eomCcg6oHPcdDAibVaMlShvBhgfGWomKKoK0djZDctfABfG2j8cyUWEuTDyuac7WqsA778yX9l7eQ1PH(BWTtQSDcM8DIY9O6Dctfg60q7eMQzr7egigOdLphYvd1UyyuaYMPo)rqTon0)qVDizCO85qG)qUAO2fdJcq2m15pcQ1PH(7eomCcg6oHPcdDAiHc5Atws2mtHJQpK0djZDctfABfG2jkKRnzjzZmfoQE778E99l7eQ1PH(BWTtQSDcKWKVtuUhvVtyQWqNgANWuH2wbODIc5Atws2mtHJQTaAR7Kpn0LX3jPozU9DEmW7x2juRtd93GBNuz7eiHjFNOCpQENWuHHon0oHPcTTcq7KpzugTdJcqyhgss7Kpn0LX3jYC778ya3VStOwNg6Vb3oPY2jqct(or5Eu9oHPcdDAODctfABfG2jsg93enilK(lUhvVt(0qxgFNitrQB778yG2VStOwNg6Vb3oPY2jyY3jk3JQ3jmvyOtdTtyQMfTtyXDctfABfG2jyjN2)cQEu9235jHm3VStOwNg6Vb3oPY2jyY3jk3JQ3jmvyOtdTtyQMfTtO8Dfzz0xaOCDcjl(Hi3cSWb)qGb2HO8Dfzz0xaODmiSx2Ayb0Fty8HadSdr57kYYOVaKr)H6feBN6heDiWa7qu(UISm6laz0FOEbXwa6Rgtu9HadSdr57kYYOVia1HhvBbuqe2owy6qGb2HO8Dfzz0x4P(Aty7uHsIZIMWhcmWoeLVRilJ(cn1Fbj)PWwC0GOVnZSauq0HadSdr57kYYOVqBEqTBLSl3wdBUa)lGdbgyhIY3vKLrFb(P4sodNGy7qBqhcmWoeLVRilJ(IMwq1yXm2AgMSu)OnNGhcmWoeLVRilJ(IPAOraj7eQn)zNWuH2wbODcVaMlShvBR2UW0235jHe7x2juRtd93GBNuz7eiHjFNOCpQENWuHHon0oHPcTTcq7eciJriPgBb)T2CY(jJY4o5tdDz8DIemGBFNNeYy)YoHADAO)gC7KkBNGjFNOCpQENWuHHon0oHPAw0orgYCNWHHtWq3jmvyOtdj4fWCH9OAB12fM2jmvOTvaANuTDHjlF51yS9DEsih7x2juRtd93GBNuz7em57eL7r17eMkm0PH2jmvZI2jYGf3jCy4em0DcLVRilJ(caLRtizXpe5wGfo47eMk02kaTtQ2UWKLV8Am2(opjsD7x2juRtd93GBNuz7em57eL7r17eMkm0PH2jmvZI2jYqMh6TdXuHHonKGaYyesQXwWFRnNSFYOmUt4WWjyO7ekFxrwg9feqgJqsn2c(BT50oHPcTTcq7KQTlmz5lVgJTVZtcwC)YoHADAO)gC7KkBNajm57eL7r17eMkm0PH2jmvOTvaANWlG5c7r1w8tm8ObzZQCeCN8PHUm(orgBFNNeV((LDc160q)n42jCy4em0Dc4petfg60qcEbmxypQ2wTDHPDsRa0obxlJna1HtWDIY9O6DcUwgBaQdNGBFNNemW7x2jk3JQ3jabewqBaOGODc160q)n42(opjya3VStOwNg6Vb3oHddNGHUta)HYGetrgJWAAuSVtuUhvVtYyewtJI9TV9DcVaMlShvB5vz(vUgVFzNNe7x2jk3JQ3jzLhvVtOwNg6Vb3235jJ9l7eL7r17KPPQVDSGmUtOwNg6Vb3235jh7x2jk3JQ3jtcIjOKrdANqTon0FdUTVZl1TFzNOCpQENmcinnv93juRtd93GB778yX9l7eL7r17eT5e2HQXYvJzNqTon0FdUTVZ713VStuUhvVtwyYgobG3juRtd93GB778yG3VStOwNg6Vb3or5Eu9obKr)H6feBN6heTtwyYwJHfe)VZtIDchgobdDNOCpQwaqovqr02Hja94wibOrJp07spKmfS4oHgdI72wbODciJ(d1li2o1piA778ya3VStOwNg6Vb3oHddNGHUtGRMgfeejCciRGQXMtHzcQ1PH(hk9HMRXqqY(OlShvlwz7eL7r17epaiBofMT9TVtuUhmjRRgQD8(LDEsSFzNqTon0FdUDchgobdDNOCpyswQjGGWhILhsIdL(qZ1yi4fWCH9OAXVY1hk9HK)qmvyOtdj8aGSEz5fWCH9O6dXYdXRY8RCTWemJgKDwatXFbvpQ(qGb2HyQWqNgs4baz9YYlG5c7r1h6DPhsMhkLDIY9O6DIjygni7SaMBFNNm2VStOwNg6Vb3oHddNGHUtyQWqNgs4baz9YYlG5c7r1h6DPhsMhcmWoK8hIxL5x5Aba5ubf)fu9O6d9(HyQWqNgs4baz9YYlG5c7r1hk9Ha)HC1qTlGRMS1WMv5iOGADAO)Hs5qGb2HC1qTlGRMS1WMv5iOGADAO)HsFO5AmeWvt2AyZQCeuSYou6dXuHHonKWdaY6LLxaZf2JQpelpKY9OAba5ubf8Qm)kxFiWa7qJa0JBHeGgn(qVFiMkm0PHeEaqwVS8cyUWEu9or5Eu9obGCQGBFNNCSFzNqTon0FdUDchgobdDN4QHAxOgswSdvCQVITJfKrb160q)dL(qYFO5Ame8cyUWEuT4x56dL(qG)qZ1yiEk3IDiPskGKY9dLYor5Eu9o5dvqvJTtiP(Z23(ob7A)v43clx9O69l78Ky)YoHADAO)gC7eomCcg6or5EWKSutabHpelLEiMkm0PHepLBXoKujTdJcqyhgsshk9HK)qZ1yiEk3IDiPskGKY9dbgyhAUgdXiGe2liGask3puk7eL7r17KHrbiSddjPTVZtg7x2juRtd93GBNWHHtWq3jZ1yigbKWEbbeqs5(or5Eu9ojJrynnk23(op5y)YoHADAO)gC7eomCcg6ozUgdXt5wSdjvsbKuUFO0hAUgdXt5wSdjvsbKa0OXh69dPCpQwmcinvJrqYs8LtwpaODIY9O6DsgJWAAuSV9DEPU9l7eQ1PH(BWTt4WWjyO7K5AmepLBXoKujfqs5(HsFi5pugKyAbX)cjeJast1yoeyGDOrajSRqNGcL7bt6qGb2HuUhvlYyewtJIDr02Hja94hkLDIY9O6DsgJWAAuSV9DES4(LDc160q)n42jCy4em0DYCngc8QTsgniSDAimoAqwiPFgfRSdL(qYFiEvMFLRfWvt2AyZQCeuajanA8HE7qk3JQfWvt2AyZQCeuqYs8LtwpaOd92H4k2TEaqhILhAUgdbE1wjJge2oneghnilK0pJcibOrJpeyGDiWFixnu7c4QjBnSzvockOwNg6FOuou6dXuHHonKWdaY6LLxaZf2JQp0BhIRy36baDiwEO5Ame4vBLmAqy70qyC0GSqs)mkGeGgnENOCpQENKXiSMgf7BFN3RVFzNqTon0FdUDchgobdDNmxJH4PCl2HKkPask3pu6d5kee5Ihsn(JiJ7h6DPhsoK5HsFixnu7cmPWObz9AXFeuRtd93jk3JQ3jzmcRPrX(235XaVFzNqTon0FdUDchgobdDNmxJHiJryXnkgqajL7hk9H4k2TEaqh69dnxJHiJryXnkgqajanA8or5Eu9ojJrynnk23(opgW9l7eQ1PH(BWTtwyYM7jmKLRypAq78KyNWHHtWq3jG)qJasyxHobfk3dM0HsFiWFiMkm0PHeJas2PrXUnRkt0Gou6dj)HK)qYFiL7r1IraPPAmcswIV8ObDO0hs(dPCpQwmcinvJrqYs8LtwibOrJp07hsMcw8qGb2Ha)HGRMgfeejgbKWEbbeuRtd9pukhcmWoKY9OArgJWAAuSlizj(YJg0HsFi5pKY9OArgJWAAuSlizj(YjlKa0OXh69djtblEiWa7qG)qWvtJccIeJasyVGacQ1PH(hkLdLYHsFO5AmepK6rdYUYeqs5(Hs5qGb2HK)qUAO2fysHrdY61I)iOwNg6FO0hYviiYfpKA8hrg3p07spKCiZdL(qYFO5AmepK6rdYUYeqs5(HsFiWFiL7r1cmVG8hbjlXxE0GoeyGDiWFO5AmepLBXoKujfqs5(HsFiWFO5AmepK6rdYUYeqs5(HsFiL7r1cmVG8hbjlXxE0Gou6db(d9uUf7qsL0IZiJbBJ2ombOh)qPCOuouk7KfMS1yybX)78KyNOCpQENmcizNgf7BFNhd0(LDc160q)n42jCy4em0DsgKyAbX)cjeyEb5phk9HMRXq8qQhni7ktajL7hk9HC1qTlWKcJgK1Rf)rqTon0)qPpKRqqKlEi14pImUFO3LEi5qMhk9HuUhmjl1eqq4d9(HyQWqNgs8uUf7qsL0omkaHDyijTtuUhvVtYyewtJI9TVZtczUFzNqTon0FdUDchgobdDNa(dXuHHonKi7POoK1MvLjAqhk9HK)qG)qUAO2fdyby9hYQ4hclOwNg6FiWa7qk3dMKLAcii8Hy5HK4qPCO0hs(dPCpys2F5IauhoDO3pKmoeyGDiL7btYsnbee(qSu6HyQWqNgs8OWVLRy3omkaHDyijDiWa7qk3dMKLAcii8HyP0dXuHHonK4PCl2HKkPDyuac7Wqs6qPStuUhvVtYEkQdzTdJcq4TVZtcj2VStOwNg6Vb3or5Eu9oHRgJv5EuT1eyFNycSBBfG2jk3dMK1vd1oE778Kqg7x2juRtd93GBNWHHtWq3jk3dMKLAcii8Hy5HKyNOCpQEN8HkOQX2jKu)z778Kqo2VStOwNg6Vb3oHddNGHUtCfcICXdPg)rKX9d9U0djhY8qPpKRgQDbMuy0GSET4pcQ1PH(7eL7r17emVG8NTVZtIu3(LDc160q)n42jCy4em0DIY9GjzPMaccFiwk9qmvyOtdjuixBYsYMzkCu9HsFiaTvrg3pelLEiMkm0PHekKRnzjzZmfoQ2cOTUtuUhvVtuixBYsYMzkCu9235jblUFzNqTon0FdUDchgobdDNOCpyswQjGGWhILspetfg60qIhf(TCf72HrbiSddjPDIY9O6DYWOae2HHK0235jXRVFzNOCpQENmcinvJzNqTon0FdUTV9DcVaMlShvBZEumTFzNNe7x2juRtd93GBNWHHtWq3jZ1yi4fWCH9OAXVY17eL7r17eta6XXwwqS(GaO23(opzSFzNqTon0FdUDsLTtWKVtuUhvVtyQWqNgANWuH2wbODcjRt9N(wEbmxypQ2cjanA8oHPAw0ozUgdbVaMlShvlGeGgn(qVDO5Ame8cyUWEuT4VGQhvFO85qYFiEvMFLRf8cyUWEuTasaA04d9(HMRXqWlG5c7r1cibOrJpuk7eomCcg6oHx9FfUi6bbB1y5kMRFsqTon0FNSWKn3tyilxXE0G25jXozHjBngwq8)opj2(op5y)YoHADAO)gC7KkBNO))or5Eu9oHPcdDAODctfABfG2jKSo1F6B5fWCH9OAlKa0OX7eMQzr7eMkm0PHeyjN2)cQEu9oHddNGHUt4v)xHlIEqWwnwUI56NeuRtd9pu6dj)HMRXqGxTvYObHTtdHXrdYcj9ZOyLDiWa7qmvyOtdjizDQ)03YlG5c7r1wibOrJpelpKecw8q5ZHaX)cav2dLphs(dnxJHaVARKrdcBNgcJJgKaqL1IDLl5HY)dnxJHaVARKrdcBNgcJJgKa7kxYdLYHszNSWKn3tyilxXE0G25jXozHjBngwq8)opj2(oVu3(LDc160q)n42jCy4em0DYCngcEbmxypQw8RC9or5Eu9ozQGS1W6WGljE778yX9l7eQ1PH(BWTt4WWjyO7eL7btYsnbee(qS8qsCO0hAUgdbVaMlShvl(vUENOCpQENycMrdYolG5235967x2juRtd93GBNSWKn3tyilxXE0G25jXoHddNGHUtK)qk3dMKLAcii8HEx6HuUhmj7VCraQdNoeyGDiWFiEvMFLRfzpf1HS2HrbiSas6NXdLYHsFiWFiE1)v4IOheSvJLRyU(jb160q)dL(q8hfcIWhILspKehk9HMRXqWlG5c7r1Iv2HsFiWFO5AmeJasyVGaciPC)qPpe4p0CngINYTyhsQKciPC)qPp0t5wSdjvsloJmgSnA7WeGE8d92HMRXq8qQhni7ktajL7h69djJDYct2AmSG4)DEsStuUhvVtgbKStJI9TVZJbE)YoHADAO)gC7KkBNGjFNOCpQENWuHHon0oHPcTTcq7es2mI703ocizNgf74Dct1SODIY9OAXiGKDAuSl4pkeeHTdOY9OA1CO3oK8hIPcdDAibjRt9N(wEbmxypQ2cjanA8HY)dnxJHi6bbB1y5kMRFs8xq1JQpukhIHhIxL5x5AXiGKDAuSl(lO6r17eomCcg6oHx9FfUi6bbB1y5kMRFsqTon0FNSWKn3tyilxXE0G25jXozHjBngwq8)opj2(opgW9l7eQ1PH(BWTtQSDcM8DIY9O6Dctfg60q7eMk02kaTtAI(03ocizNgf74Dct1SODcNcZHK)qmvyOtdjizDQ)03YlG5c7r1wibOrJpedpK8hAUgdr0dc2QXYvmx)K4VGQhvFO8)qG4FbGk7Hs5qPSt4WWjyO7eE1)v4IOheSvJLRyU(jb160q)DYct2CpHHSCf7rdANNe7KfMS1yybX)78Ky778yG2VStOwNg6Vb3ozHjBUNWqwUI9ObTZtIDchgobdDNi)HuUhmjl1eqq4d9U0dPCpys2F5IauhoDiWa7qG)q8Qm)kxlYEkQdzTdJcqybK0pJhkLdL(q8Q)RWfrpiyRglxXC9tcQ1PH(hk9H4pkeeHpelLEijou6dj)HyQWqNgsqYMrCN(2raj70OyhFiwk9qmvyOtdjAI(03ocizNgf74dbgyhIPcdDAibjRt9N(wEbmxypQ2cjanA8HEx6HMRXqe9GGTASCfZ1pj(lO6r1hcmWo0CngIOheSvJLRyU(jb2vUKh69djJdbgyhAUgdr0dc2QXYvmx)KasaA04d9(HaX)cav2dbgyhIxL5x5Ab(jgE0GSzvockGK(z8qPpKY9GjzPMaccFiwk9qmvyOtdj4fWCH9OAl(jgE0GSzvocEO0hIxmPwBx0bOh3ou6qPCO0hAUgdbVaMlShvlwzhk9HK)qG)qZ1yigbKWEbbeqs5(HadSdnxJHi6bbB1y5kMRFsajanA8HE)qYuWIhkLdL(qG)qZ1yiEk3IDiPskGKY9dL(qpLBXoKujT4mYyW2OTdta6Xp0BhAUgdXdPE0GSRmbKuUFO3pKm2jlmzRXWcI)35jXor5Eu9ozeqYonk23(opjK5(LDc160q)n42jCy4em0DcC10OGGiXpW8iZeTcz0YlaaT)cQ1PH(hk9HMRXq8dmpYmrRqgT8caq7V4x56dL(qZ1yi(bMhzMOviJwEbaO93QqU2K4x56dL(q8Qm)kxlMRXW(dmpYmrRqgT8caq7Vas6NXdL(qG)qUAO2fWvt2AyZQCeuqTon0FNOCpQENWRv7eeNrgZ235jHe7x2juRtd93GBNWHHtWq3jWvtJccIe)aZJmt0kKrlVaa0(lOwNg6FO0hAUgdXpW8iZeTcz0YlaaT)IFLRpu6dnxJH4hyEKzIwHmA5faG2FRc5AtIFLRpu6dXRY8RCTyUgd7pW8iZeTcz0YlaaT)ciPFgpu6db(d5QHAxaxnzRHnRYrqb160q)DIY9O6DIc5Atws2mtHJQ3(opjKX(LDc160q)n42jCy4em0DcC10OGGiXpW8iZeTcz0YlaaT)cQ1PH(hk9HMRXq8dmpYmrRqgT8caq7V4x56dL(qZ1yi(bMhzMOviJwEbaO93oGf2f)kxVtuUhvVtgWc7ZY4BFNNeYX(LDc160q)n42jCy4em0DcC10OGGibiyGnmAdEWnKGADAO)HsFO5Ame8cyUWEuT4x56DIY9O6DYawy32ftD778Ki1TFzNqTon0FdUDIY9O6DcxngRY9OARjW(oXey32kaTtuUhmjRRgQD8235jblUFzNqTon0FdUDYct2CpHHSCf7rdANNe7eomCcg6ozUgdbVaMlShvl(vU(qPpK8hc8hcUAAuqqK4hyEKzIwHmA5faG2Fb160q)dbgyhAUgdXpW8iZeTcz0YlaaT)Iv2HadSdnxJH4hyEKzIwHmA5faG2F7awyxSYou6d5QHAxaxnzRHnRYrqb160q)dL(q8Qm)kxlMRXW(dmpYmrRqgT8caq7Vas6NXdLYHsFi5pe4peC10OGGibiyGnmAdEWnKGADAO)HadSd9P5AmeGGb2WOn4b3qIv2Hs5qPpK8hs5EuTaGCQGIOTdta6Xpu6dPCpQwaqovqr02Hja94wibOrJp07spKmfV(HadSdPCpQwG5fK)iizj(YJg0HsFiL7r1cmVG8hbjlXxozHeGgn(qVFizkE9dbgyhs5EuTyeqAQgJGKL4lpAqhk9HuUhvlgbKMQXiizj(YjlKa0OXh69djtXRFiWa7qk3JQfzmcRPrXUGKL4lpAqhk9HuUhvlYyewtJIDbjlXxozHeGgn(qVFizkE9dbgyhs5EuTyyuac7WqssqYs8LhnOdL(qk3JQfdJcqyhgsscswIVCYcjanA8HE)qYu86hkLDYct2AmSG4)DEsStuUhvVt4fWCH9O6TVZtIxF)YoHADAO)gC7eomCcg6ozUgdbVaMlShvlmk2TKSzbKo07spKY9OAbVaMlShvlmk2Tlm93jk3JQ3jC1ySk3JQTMa77etGDBRa0oHxaZf2JQT8Qm)kxJ3(opjyG3VStOwNg6Vb3oHddNGHUtK)qZ1yiEk3IDiPskGKY9dbgyhAUgdXiGe2liGask3pukhk9HuUhmjl1eqq4dXsPhIPcdDAibVaMlShvBhgfGWomKK2jk3JQ3jdJcqyhgssBFNNemG7x2juRtd93GBNWHHtWq3jZ1yiWR2kz0GW2PHW4ObzHK(zuSYou6dnxJHaVARKrdcBNgcJJgKfs6NrbKa0OXhILhIRy36baTtuUhvVtYyewtJI9TVZtcgO9l7eQ1PH(BWTt4WWjyO7K5AmeJasyVGaciPCFNOCpQENKXiSMgf7BFNNmK5(LDc160q)n42jCy4em0DYCngImgHf3OyabKuUFO0hAUgdrgJWIBumGasaA04dXYdXvSB9aGou6dj)HMRXqWlG5c7r1cibOrJpelpexXU1da6qGb2HMRXqWlG5c7r1IFLRpukhk9HuUhmjl1eqq4d9(HyQWqNgsWlG5c7r12HrbiSddjPDIY9O6DsgJWAAuSV9DEYqI9l7eQ1PH(BWTt4WWjyO7K5AmepLBXoKujfqs5(HsFO5Ame8cyUWEuTyLTtuUhvVtYyewtJI9TVZtgYy)YoHADAO)gC7eomCcg6ojdsmTG4FHecmVG8NdL(qZ1yiEi1JgKDLjGKY9dL(qk3dMKLAcii8HE)qmvyOtdj4fWCH9OA7WOae2HHK0or5Eu9ojJrynnk23(opzih7x2juRtd93GBNOCpQENGFIHhniBwLJG7eomCcg6ozUgdbVaMlShvlwzhk9Ha)HuUhvlgbKStJIDb)rHGi8HsFiL7btYsnbee(qSu6HyQWqNgsWlG5c7r1w8tm8ObzZQCe8qPpKY9OAr2trDiRDyuaclglJXcj(JcbrwpaOdXYdnwgJfs)f3JQ3jr7eeUYCBm2jk3JQfJas2PrXUG)OqqewQY9OAXiGKDAuSlauzT8hfcIWBFNNmsD7x2juRtd93GBNWHHtWq3jZ1yi4fWCH9OAXk7qPpK8hs(dPCpQwmcizNgf7c(Jcbr4d9(HK4qPpKRgQDrgJWIBumGGADAO)HsFiL7btYsnbee(qspKehkLdbgyhc8hYvd1UiJryXnkgqqTon0)qGb2HuUhmjl1eqq4dXYdjXHs5qPp0CngIhs9ObzxzciPC)qVDONYTyhsQKwCgzmyB02Hja94h69djJDIY9O6Ds2trDiRDyuacV9DEYGf3VStOwNg6Vb3oHddNGHUtMRXqWlG5c7r1IFLRpu6dXRY8RCTGxaZf2JQfqcqJgFO3pexXU1da6qPpKY9GjzPMaccFiwk9qmvyOtdj4fWCH9OA7WOae2HHK0or5Eu9ozyuac7WqsA778KXRVFzNqTon0FdUDchgobdDNmxJHGxaZf2JQf)kxFO0hIxL5x5AbVaMlShvlGeGgn(qVFiUIDRha0HsFiWFiE1)v4IHrbiRY5qYJQfuRtd93jk3JQ3jJast1y2(opzWaVFzNqTon0FdUDchgobdDNmxJHGxaZf2JQfqcqJgFiwEiUIDRha0HsFO5Ame8cyUWEuTyLDiWa7qZ1yi4fWCH9OAXVY1hk9H4vz(vUwWlG5c7r1cibOrJp07hIRy36baTtuUhvVtW8cYF2(opzWaUFzNqTon0FdUDchgobdDNmxJHGxaZf2JQfqcqJgFO3pei(xaOYEO0hs5EWKSutabHpelpKe7eL7r17etWmAq2zbm3(opzWaTFzNqTon0FdUDchgobdDNmxJHGxaZf2JQfqcqJgFO3pei(xaOYEO0hAUgdbVaMlShvlwz7eL7r17Kpubvn2oHK6pBFNNCiZ9l7eQ1PH(BWTt4WWjyO7exHGix8qQXFezC)qVl9qYHmpu6d5QHAxGjfgniRxl(JGADAO)or5Eu9obZli)z7BF77eMeehvVZtgYugYucjKXRlKyNKtHD0GW7e5ewG8J8YV59AZGh6qV8qhkaYkOFOrbpe7WkZM9OyI9dbP8Dfq6FiCbqhsxEbOo9pe)rBqewCS(QOPdXIm4Hsv1mjOt)dXURgQDHCz)qEDi2D1qTlKRGADAOp7hsEziBkIJ1xfnDOxNbpuQQMjbD6Fi2D1qTlKl7hYRdXURgQDHCfuRtd9z)qYlHSPiowFv00HEDg8qPQAMe0P)HyhUAAuqqKqUSFiVoe7WvtJccIeYvqTon0N9djVmKnfXX6RIMoededEOuvntc60)qS7QHAxix2pKxhIDxnu7c5kOwNg6Z(HKxcztrCS(QOPdjHem4Hsv1mjOt)dXURgQDHCz)qEDi2D1qTlKRGADAOp7hs9djNFnV6qYlHSPiowpwLtybYpYl)M3RndEOd9YdDOaiRG(Hgf8qS)PHUmo7hcs57kG0)q4cGoKU8cqD6Fi(J2GiS4y9vrthscg8qPQAMe0P)HyhUAAuqqKqUSFiVoe7WvtJccIeYvqTon0N9dP(HKZVMxDi5Lq2uehRVkA6qYGbpuQQMjbD6Fi2D1qTlKl7hYRdXURgQDHCfuRtd9z)qYldztrCS(QOPdXIm4Hsv1mjOt)dXURgQDHCz)qEDi2D1qTlKRGADAOp7hsEjKnfXX6RIMo0RZGhkvvZKGo9pe7UAO2fYL9d51Hy3vd1UqUcQ1PH(SFi5Lq2uehRVkA6qmWm4Hsv1mjOt)dXURgQDHCz)qEDi2D1qTlKRGADAOp7hsEjKnfXX6RIMoKemWm4Hsv1mjOt)dLeaP6qygBxL9q5N5NhYRd9QLEiG6Vml8HQmcQEbpK85NPCi5Lq2uehRVkA6qsWaZGhkvvZKGo9pe78Q)RWfYL9d51HyNx9FfUqUcQ1PH(SFi5Lq2uehRVkA6qsWaXGhkvvZKGo9pe78Q)RWfYL9d51HyNx9FfUqUcQ1PH(SFi5Lq2uehRVkA6qYqMm4Hsv1mjOt)dXoC10OGGiHCz)qEDi2HRMgfeejKRGADAOp7hsEjKnfXX6RIMoKmKGbpuQQMjbD6Fi2HRMgfeejKl7hYRdXoC10OGGiHCfuRtd9z)qYlHSPiowFv00HKHmyWdLQQzsqN(hID4QPrbbrc5Y(H86qSdxnnkiisixb160qF2pK8siBkIJ1xfnDizK6yWdLQQzsqN(hIDxnu7c5Y(H86qS7QHAxixb160qF2pK8siBkIJ1xfnDizWIm4Hsv1mjOt)dXoC10OGGiHCz)qEDi2HRMgfeejKRGADAOp7hsEjKnfXX6XQCclq(rE538ETzWdDOxEOdfazf0p0OGhI9miXlGP6SFiiLVRas)dHla6q6Yla1P)H4pAdIWIJ1xfnDizWGhkvvZKGo9pe7UAO2fYL9d51Hy3vd1UqUcQ1PH(SFi5Lq2uehRVkA6qYGbpuQQMjbD6Fi2D1qTlKl7hYRdXURgQDHCfuRtd9z)qQFi58R5vhsEjKnfXX6RIMoKCWGhkvvZKGo9pe7UAO2fYL9d51Hy3vd1UqUcQ1PH(SFi5Lq2uehRVkA6qYbdEOuvntc60)qS7QHAxix2pKxhIDxnu7c5kOwNg6Z(Hu)qY5xZRoK8siBkIJ1xfnDOuhdEOuvntc60)qS7QHAxix2pKxhIDxnu7c5kOwNg6Z(HKxcztrCS(QOPdL6yWdLQQzsqN(hIDxnu7c5Y(H86qS7QHAxixb160qF2pK6hso)AE1HKxcztrCS(QOPdXIm4Hsv1mjOt)dXURgQDHCz)qEDi2D1qTlKRGADAOp7hsEjKnfXX6RIMoelYGhkvvZKGo9pe7UAO2fYL9d51Hy3vd1UqUcQ1PH(SFi1pKC(18QdjVeYMI4y9yvoHfi)iV8BEV2m4Ho0lp0HcGSc6hAuWdXoVaMlShvB5vz(vUgZ(HGu(Uci9peUaOdPlVauN(hI)OniclowFv00HyazWdLQQzsqN(hID4QPrbbrc5Y(H86qSdxnnkiisixb160qF2pK8siBkIJ1Jv5ewG8J8YV59AZGh6qV8qhkaYkOFOrbpe7k3dMK1vd1oM9dbP8Dfq6FiCbqhsxEbOo9pe)rBqewCS(QOPdjdg8qPQAMe0P)Hy3vd1UqUSFiVoe7UAO2fYvqTon0N9djVmKnfXX6RIMoKCWGhkvvZKGo9pe7UAO2fYL9d51Hy3vd1UqUcQ1PH(SFi5Lq2uehRhRYjSa5h5LFZ71Mbp0HE5HouaKvq)qJcEi2XU2Ff(TWYvpQM9dbP8Dfq6FiCbqhsxEbOo9pe)rBqewCS(QOPdXIm4Hsv1mjOt)dXURgQDHCz)qEDi2D1qTlKRGADAOp7hsEjKnfXX6RIMo0RZGhkvvZKGo9pe7UAO2fYL9d51Hy3vd1UqUcQ1PH(SFi1pKC(18QdjVeYMI4y9vrthIbKbpuQQMjbD6Fi2D1qTlKl7hYRdXURgQDHCfuRtd9z)qYlHSPiowFv00HyazWdLQQzsqN(hID4QPrbbrc5Y(H86qSdxnnkiisixb160qF2pK8Yq2uehRVkA6qmqm4Hsv1mjOt)dXURgQDHCz)qEDi2D1qTlKRGADAOp7hsEjKnfXX6RIMoKeYKbpuQQMjbD6Fi2D1qTlKl7hYRdXURgQDHCfuRtd9z)qYlHSPiowFv00HKqoyWdLQQzsqN(hIDxnu7c5Y(H86qS7QHAxixb160qF2pK6hso)AE1HKxcztrCSESkNWcKFKx(nVxBg8qh6Lh6qbqwb9dnk4HyNxaZf2JQTzpkMy)qqkFxbK(hcxa0H0LxaQt)dXF0geHfhRVkA6qYGbpuQQMjbD6Fi25v)xHlKl7hYRdXoV6)kCHCfuRtd9z)qQFi58R5vhsEjKnfXX6RIMoKCWGhkvvZKGo9pe78Q)RWfYL9d51HyNx9FfUqUcQ1PH(SFi5Lq2uehRVkA6qVodEOuvntc60)qSZR(Vcxix2pKxhIDE1)v4c5kOwNg6Z(HKxcztrCS(QOPdXaZGhkvvZKGo9pusaKQdHzSDv2dLFEiVo0Rw6H(bZahvFOkJGQxWdjpdt5qYlHSPiowFv00HyGzWdLQQzsqN(hIDE1)v4c5Y(H86qSZR(Vcxixb160qF2pK6hso)AE1HKxcztrCS(QOPdXaYGhkvvZKGo9pusaKQdHzSDv2dLFEiVo0Rw6H(bZahvFOkJGQxWdjpdt5qYlHSPiowFv00HyazWdLQQzsqN(hIDE1)v4c5Y(H86qSZR(Vcxixb160qF2pK6hso)AE1HKxcztrCS(QOPdXaXGhkvvZKGo9pe78Q)RWfYL9d51HyNx9FfUqUcQ1PH(SFi5Lq2uehRVkA6qsitg8qPQAMe0P)Hy3vd1UqUSFiVoe7UAO2fYvqTon0N9dP(HKZVMxDi5Lq2uehRVkA6qsitg8qPQAMe0P)HyhUAAuqqKqUSFiVoe7WvtJccIeYvqTon0N9djVeYMI4y9vrthscjyWdLQQzsqN(hIDxnu7c5Y(H86qS7QHAxixb160qF2pK6hso)AE1HKxcztrCS(QOPdjHem4Hsv1mjOt)dXoC10OGGiHCz)qEDi2HRMgfeejKRGADAOp7hsEjKnfXX6RIMoKeYGbpuQQMjbD6Fi2HRMgfeejKl7hYRdXoC10OGGiHCfuRtd9z)qYlHSPiowFv00HKqoyWdLQQzsqN(hID4QPrbbrc5Y(H86qSdxnnkiisixb160qF2pK8siBkIJ1xfnDijyrg8qPQAMe0P)Hy3vd1UqUSFiVoe7UAO2fYvqTon0N9djVeYMI4y9vrthscwKbpuQQMjbD6Fi2HRMgfeejKl7hYRdXoC10OGGiHCfuRtd9z)qYldztrCS(QOPdjJuhdEOuvntc60)qS7QHAxix2pKxhIDxnu7c5kOwNg6Z(HKxgYMI4y9vrthsgVodEOuvntc60)qSZR(Vcxix2pKxhIDE1)v4c5kOwNg6Z(Hu)qY5xZRoK8siBkIJ1xfnDi5qMm4Hsv1mjOt)dXURgQDHCz)qEDi2D1qTlKRGADAOp7hs9djNFnV6qYlHSPiowpwZVazf0P)HyGpKY9O6dzcSJfhR7eCgX3596YXojdwJWq7Ku7qSWash61sbrhRP2HECpdZGmKHGc)znf8cGH4ayzupQMd1HZqCaWz4XAQDigGeNaMe8qVoBhsgYugY8y9yn1ouQE0geHzWJ1u7q5)HyaGPdncqpUfsaA04dbv)HGhYF0(qUcbrUWdaY6L9h0Hgf8qgf75pM4v)pKodt4mEOfwbryXXAQDO8)qVQkm1hIRy)qqkFxbKaO2XhAuWdLQcyUWEu9HKpeKGTd9RMD)qpL5FOWp0OGhsp0as4Nd9ArovWdXvSNI4yn1ou(Fi5CRtdDiSddUFi(dXLmAqhQ6dPhAq5o0OGsIpu0hYFOdXcK69Qd51HG0FXPdLRGsAk9lowpwtTdjNLL4lN(hAsJcshIxat1p0KafnwCiwaoNYC8H6QZ)hfcmwMdPCpQgFOQnmkowvUhvJfzqIxat1FtkdvixBYgTtgdX9J1u7qV8e4dXuHHon0HWzepgbHpK)qhQxatcEOACixHGihFi1puUNG)Ci50YpuIdjvYdXcnkaHDyijHpuTCC8PdvJdLQcyUWEu9HWp1Y8p0Ko0ctFXXQY9OASids8cyQ(Bszitfg60qS1kaj9PCl2HKkPDyuac7WqsITktkMC2IHuMkm0PHepLBXoKujTdJcqyhgsssLjBmvZIKkJ8Xvd1UyyuaYMPo)5n5iFaVRgQDXWOaKntD(ZXAQDOxEc8HyQWqNg6q4mIhJGWhYFOd1lGjbpunoKRqqKJpK6hk3tWFoKCQc)hkvk2pel0Oae2HHKe(q1YXXNounouQkG5c7r1hc)ulZ)qt6qlm9pKIp0imgckowvUhvJfzqIxat1FtkdzQWqNgITwbiPpk8B5k2TdJcqyhgssSvzsXKZwmKYuHHonK4rHFlxXUDyuac7WqssQmzJPAwKuzKpUAO2fdJcq2m15pVjh5d4D1qTlggfGSzQZFowtTd9YtGpetfg60qhcNr8yee(q(dDOEbmj4HQXHCfcIC8Hu)q5Ec(ZHKtl)qjoKujpel0Oae2HHKe(qkKo0ct)d9xWObDOuvaZf2JQfhRk3JQXImiXlGP6VjLHmvyOtdXwRaKuEbmxypQ2omkaHDyijXwLjftoBXqktfg60qcEbmxypQ2omkaHDyijjvMSXunlsQCKpUAO2fdJcq2m15pV965d4D1qTlggfGSzQZFowtTd9YtGpetfg60qhcNr8yee(q(dDOEbmj4HQXHCfcIC8Hu)q5Ec(ZHybGCTPdjNLnZu4O6dvlhhF6q14qPQaMlShvFi8tTm)dnPdTW0xCSQCpQglYGeVaMQ)MugYuHHoneBTcqsvixBYsYMzkCunBvMum5SfdPmvyOtdjuixBYsYMzkCuTuzYgt1SiPmqmq5JRgQDXWOaKntD(ZBYiFaVRgQDXWOaKntD(ZXAQDOxEc8HyQWqNg6q4mIhJGWhYFOdLrqo1UcIounoeG26HMKPYDOCpb)5qSaqU20HKZYMzkCu9HYfgZH6Yp0Ko0ctFXXQY9OASids8cyQ(Bszitfg60qS1kajvHCTjljBMPWr1waTv2(0qxgxAQtMSvzsHeM8J1u7qV8e4dXuHHon0Hc8Hwy6FiVoeoJ4XGXd5p0HuGA1(HQXH8aGou0hct8Q)4d5pQFiGf2puMIXhshobpuQkG5c7r1hIKnlGe(qtAuq6qSqJcqyhgss4dLlmMdnPdTW0)qDbbuJHrXXQY9OASids8cyQ(Bszitfg60qS1kaj9tgLr7WOae2HHKeBFAOlJlvMSvzsHeM8J1u7qYjH)CiwWr)nrdITdLQcyUWEun74dXRY8RC9HYfgZHM0HG0FXP)HMmEi9qqT)fWHuGA1oBhAU8d5p0H6fWKGhQghIddhFiSRqhFiMeKXd9eGEoKoCcEiL7bt1Jg0HsvbmxypQ(qA)pe2u5Wh6x56d5vof(XhYFOdr9)q14qPQaMlShvZo(q8Qm)kxloKCYd1hcqLmAqh6t8ahvJpu0hYFOdXcK69k2ouQkG5c7r1SJpeKa0OJg0H4vz(vU(qb(qq6V40)qtgpK)e4dnGk3JQpKxhs58A1(Hgf8qSGJ(BIgK4yv5EunwKbjEbmv)nPmKPcdDAi2AfGKkz0Ft0GSq6V4EunBFAOlJlvMIuhBvMuiHj)yn1o0lp0H(lO6r1hQghspuYQpel4ObXo(qGZqyC0GouQkG5c7r1IJvL7r1yrgK4fWu93KYqMkm0PHyRvaskwYP9VGQhvZwLjftoBmvZIKYIhRk3JQXImiXlGP6VjLHmvyOtdXwRaKuEbmxypQ2wTDHj2QmPyYzJPAwKukFxrwg9fakxNqYIFiYTalCWbdmkFxrwg9faAhdc7LTgwa93egdgyu(UISm6laz0FOEbX2P(brGbgLVRilJ(cqg9hQxqSfG(QXevdgyu(UISm6lcqD4r1wafeHTJfMadmkFxrwg9fEQV2e2ovOK4SOjmyGr57kYYOVqt9xqYFkSfhni6BZmlafebgyu(UISm6l0Mhu7wj7YT1WMlW)camWO8Dfzz0xGFkUKZWji2o0geyGr57kYYOVOPfunwmJTMHjl1pAZjiyGr57kYYOVyQgAeqYoHAZFowtTdjNw5oKPAqhAsJcshkvfWCH9O6dHFQL5Fi5mqgJqsnh61a)T2C6qt6qlm9zb5XQY9OASids8cyQ(Bszitfg60qS1kajLaYyesQXwWFRnNSFYOmY2Ng6Y4sLGbKTktkKWKFSMAhsoTYDit1Go0KgfKouQkG5c7r1hc)ulZ)qomAjjhFi)r9d5WaeicEi9q4hfs)djdzEimXR(FOuXa8qvFOYFi4HCy0sso(qD5hAshAHPplipwvUhvJfzqIxat1FtkdzQWqNgITwbiPvBxyYYxEngSvzsXKZgt1SiPYqMSfdPmvyOtdj4fWCH9OAB12fMowvUhvJfzqIxat1FtkdzQWqNgITwbiPvBxyYYxEngSvzsXKZgt1SiPYGfzlgsP8Dfzz0xaOCDcjl(Hi3cSWb)yv5EunwKbjEbmv)nPmKPcdDAi2AfGKwTDHjlF51yWwLjftoBmvZIKkdz(gtfg60qcciJriPgBb)T2CY(jJYiBXqkLVRilJ(cciJriPgBb)T2C6yn1o0lp0H6fWKGhQghYviiYXhk5jgE0GouQxLJGhc)ulZ)qt6qlm9pu1h6VGrd6qPQaMlShvlowvUhvJfzqIxat1FtkdzQWqNgITwbiP8cyUWEuTf)edpAq2Skhbz7tdDzCPYGTktkKWKFSQCpQglYGeVaMQ)MugUWKnCcGTwbiP4AzSbOoCcYwmKcEMkm0PHe8cyUWEuTTA7cthRk3JQXImiXlGP6VjLHabewqBaOGOJvL7r1yrgK4fWu93KYWmgH10OyNTyif8zqIPiJrynnk2pwpwtTdjNLL4lN(hIysqgpKha0H8h6qk3l4Hc8HuMAy0PHehRk3JQXs51QDcIZiJHTyif8WvtJccIe)aZJmt0kKrlVaa0(FSQCpQg)MugYuHHoneBTcqs9aGSEz5fWCH9OA2QmPyYzJPAwKuxnu7IrajSRqNG5ZiGe2vOtqbKa0OXVjpVkZVY1cEbmxypQwajanAC(iVe5ptfg60qcjJ(BIgKfs)f3JQZhxnu7cjJ(BIgukPKpGNxL5x5AbVaMlShvlGK(zmFMRXqWlG5c7r1IFLRpwtTd9APsshcVG0HsvbmxypQ(qb(qFYOms)dfJd1e9P)HMkM(hQ6d5p0HiGmgHKASf83AZj7NmkJhIPcdDAOJvL7r143KYqMkm0PHyRvasQhaK1llVaMlShvZwLjfqLLnMQzrszQWqNgsqazmcj1yl4V1Mt2pzugZF55vz(vUwqazmcj1yl4V1MtI)cQEuD(ZRY8RCTGaYyesQXwWFRnNeqcqJgNs(aEEvMFLRfeqgJqsn2c(BT5Kas6Nr2IHukFxrwg9feqgJqsn2c(BT50XQY9OA8Bszitfg60qS1kaj1daY6LLxaZf2JQzRYKcOYYgt1SiP8Qm)kxlaz0FOEbX2P(brcibOrJzlgsP8Dfzz0xaYO)q9cITt9dIowvUhvJFtkdzQWqNgITwbiPEaqwVS8cyUWEunBvMuavw2yQMfjDUgdbC1KTg2SkhbfqcqJgZwmK6QHAxaxnzRHnRYrW0Z1yi4fWCH9OAXVY1hRk3JQXVjLHmvyOtdXwRaKupaiRxwEbmxypQMTktkGklBmvZIKYRY8RCTaUAYwdBwLJGcibOrJFBUgdbC1KTg2Skhbf)fu9OA2IHuxnu7c4QjBnSzvocMEUgdbVaMlShvl(vUonVkZVY1c4QjBnSzvockGeGgn(nw8DMkm0PHeEaqwVS8cyUWEu9XQY9OA8Bszi(jgE0GSzvocYwmKoxJHGxaZf2JQf)kxNMPcdDAiHhaK1llVaMlShvZYXYySq6V4EuDA55vz(vUwaxnzRHnRYrqbKa0OXSCSmglK(lUhvdgyG3vd1UaUAYwdBwLJGPKg8YpxJHi6bbB1y5kMRFsSYspxJH4PCl2HKkPask3tjT8k3dMKLAcii87mvyOtdj4fWCH9OAl(jgE0GSzvoccgyk3dMKLAcii87mvyOtdj4fWCH9OA7WOae2HHKeyGXuHHonKWdaY6LLxaZf2JQZ)XYySq6V4Eunl5vz(vUoLJvL7r143KYqO(dTDlotHsYwmKk)CngcEbmxypQw8RCD65AmeWvt2AyZQCeu8RCDA5zQWqNgs4baz9YYlG5c7r1VtYs8LtwpaiWaJPcdDAiHhaK1llVaMlShvZsEvMFLRfq9hA7wCMcLu8xq1JQtjfWat(5AmeWvt2AyZQCeuSYsZuHHonKWdaY6LLxaZf2JQzPCiZuowvUhvJFtkd)K6pZc2eBXq6CngcEbmxypQw8RCD65AmeWvt2AyZQCeu8RCDAMkm0PHeEaqwVS8cyUWEu97KSeF5K1da6yv5Eun(nPmeiGWcIT1W6feGANTyiLPcdDAiHhaK1llVaMlShv)Uu5i9CngcEbmxypQw8RC9XAQDiwybpelOu7pmcz7qlmDi9qSWashcCgf7hI)Oqq0H(ly0Go0RvaHfeFOACOxkia1(H4k2pKxhszwX)qCnllAqhI)Oqqe(qX4q53EqWwnhkvkMRF6qb(qD5hctgI70xCSQCpQg)MugocizNgf7STWKn3tyilxXE0GKkbBXqQY9OAbqaHfeBRH1lia1UGKL4lpAqPhlJXcj(JcbrwpaO8x5EuTaiGWcIT1W6feGAxqYs8LtwibOrJFp1Lg8pLBXoKujT4mYyW2OTdta6Xtd(5AmepLBXoKujfqs5(XQY9OA8BsziqaHf0gakiITyiDUgdbVaMlShvl(vUo9NMRXqa1FOTBXzkuslZLPjOodt4mk(vU(yv5Eun(nPmCHjB4eaB0yqC32kajfKr)H6feBN6heXwmKYuHHonKWdaY6LLxaZf2JQzjVkZVY15plESQCpQg)MugUWKnCcGTwbiPeqgJqsn2c(BT5eBXqktfg60qcpaiRxwEbmxypQ(DPmvyOtdjiGmgHKASf83AZj7NmkJhRk3JQXVjLHlmzdNayRvaskidJzp2AyvmoacJ6r1SfdPmvyOtdj8aGSEz5fWCH9OAwkLPcdDAir12fMS8LxJXXQY9OA8Bsz4ct2Wja2AfGKcOCDcjl(Hi3cSWbNTyiLPcdDAiHhaK1llVaMlShv)Uuw8yn1ou(DCOfoAqhspe2jyf)dvD(VW0HcNay7qQjNYi(qlmDigGqs)JashIfucJjZHQLJJpDOACOuvaZf2JQfh614pemxGj2ougmky4P(0Hw4ObDigGqs)JashIfucJjZHYf(ZHsvbmxypQ(qvBy8qX4q53EqWwnhkvkMRF6qb(quRtd9pK2)dPhAHvq0HYvn7(HM0Hmf2puXKGhYFOd9xq1JQpunoK)qhAeGECXXQY9OA8Bsz4ct2Wja2AfGK(HK(hbKSmjmMmSfdPmvyOtdj8aGSEz5fWCH9OAwkLPcdDAir12fMS8LxJrA5NRXqe9GGTASCfZ1pjWUYLuQmadmWZR(Vcxe9GGTASCfZ1pbgymvyOtdj4fWCH9OAB12fMadmMkm0PHeEaqwVS8cyUWEu9BSilhbOh3cjanAC(z(jVkZVY1PCSMAhkPwMdLFb1HtWdHFQL5FOjDOfM(hk6dPhkNY4H8h1p0ViCZUFOODcoiiDOCH)COYFi4HQo)xy6qomAjjhlo0RXFi4HCy0sso(q)6qD5hYHbiqe8q6HWpkK(hk)MkgGhQ6dfoBhcxhk8dX1(qt6qlm9pema94hshobpK2mEOYFi4HQo)xy6qomAjjxCSQCpQg)MugUWKnCcGTwbiP4AzSbOoCcYwmKYuHHonKWdaY6LLxaZf2JQzPuMkm0PHevBxyYYxEngVjblMpYZuHHonKOA7ctw(YRXGLYmL0YdEkFxrwg9fFiP)rajltcJjdyGXRY8RCT4dj9pcizzsymzeqcqJgZswmLJ1u7qVadqGi4HsQL5q5xqHtWdrk0W4HYf(ZHYV9GGTAouQumx)0Hk4HY9q9Hc)q5u8HYGexXU4yv5Eun(nPmKRnNm25AmyRvaskUwgBaQdpQMTyif88Q)RWfrpiyRglxXC9tP9aGENfbdS5AmerpiyRglxXC9tcSRCjLoxJHi6bbB1y5kMRFsaOYAXUYL8yn1o0Rn5hYFOd9dmpYmrRqgT8caq7)HMRX4qRm2o0QnegFiEbmxypQ(qb(q4QAXXQY9OA8BsziVwTtqCgzmSfdPWvtJccIe)aZJmt0kKrlVaa0(NMxL5x5AXCng2FG5rMjAfYOLxaaA)fqs)mMEUgdXpW8iZeTcz0YlaaT)wfY1Me)kxNg8Z1yi(bMhzMOviJwEbaO9xSYsZuHHonKWdaY6LLxaZf2JQzPmyXJvL7r143KYqfY1MSKSzMchvZwmKcxnnkiis8dmpYmrRqgT8caq7FAEvMFLRfZ1yy)bMhzMOviJwEbaO9xaj9Zy65Ame)aZJmt0kKrlVaa0(BvixBs8RCDAWpxJH4hyEKzIwHmA5faG2FXklntfg60qcpaiRxwEbmxypQMLYGfpwvUhvJFtkdhWc7ZY4SfdPWvtJccIe)aZJmt0kKrlVaa0(NMxL5x5AXCng2FG5rMjAfYOLxaaA)fqs)mMEUgdXpW8iZeTcz0YlaaT)2bSWU4x560GFUgdXpW8iZeTcz0YlaaT)IvwAMkm0PHeEaqwVS8cyUWEunlLblESQCpQg)MugYvJXQCpQ2AcSZwRaKuEbmxypQ2M9OyITyiLPcdDAiHhaK1llVaMlShv)UuzESQCpQg)MugYuHHoneBlmzRXWcI)LkbBlmzZ9egYYvShniPsWwRaK0raj70Oy3MvLjAqSXunlsktfg60qcpaiRxwEbmxypQo)LJ3vUhvlgbKStJIDXyzmwiXFuiiY6baL)k3JQf4Ny4rdYMv5iOySmglK(lUhvNpYZRY8RCTa)edpAq2SkhbfqcqJg)otfg60qcpaiRxwEbmxypQoL0mvyOtdj8aGSEz5fWCH9O63hbOh3cjanAmyG5QHAxaxnzRHnRYrW0Z1yiGRMS1WMv5iO4x5608Qm)kxlGRMS1WMv5iOasaA043vUhvlgbKStJIDXyzmwiXFuiiY6baL)k3JQf4Ny4rdYMv5iOySmglK(lUhvNpYZRY8RCTa)edpAq2SkhbfqcqJg)oVkZVY1c4QjBnSzvockGeGgnoL08Qm)kxlGRMS1WMv5iOasaA043hbOh3cjanA8XQY9OA8Bszitfg60qS1kajn7POoK1MvLjAqSXunlsktfg60qcpaiRxwEbmxypQ(DL7r1ISNI6qw7WOaewmwgJfs8hfcISEaq5VY9OAb(jgE0GSzvockglJXcP)I7r15J88Qm)kxlWpXWJgKnRYrqbKa0OXVZuHHonKWdaY6LLxaZf2JQtjntfg60qcpaiRxwEbmxypQ(9ra6XTqcqJgdgyWvtJccIe4vBLmAqy70qyC0GadmpaO3zXJvL7r143KYq4QjBnSzvocYwmKoxJHaUAYwdBwLJGIFLRtd(5AmeJasyVGaciPCpT8mvyOtdj8aGSEz5fWCH9OAwkDUgdbC1KTg2Skhbf)fu9O60mvyOtdj8aGSEz5fWCH9OAwQCpQwmcizNgf7IXYySqI)OqqK1dacmWyQWqNgs4baz9YYlG5c7r1SCeGEClKa0OXPCSQCpQg)MugYvJXQCpQ2AcSZwRaKuyLzZEumXwmKoxJHaUAYwdBwLJGIvwA5zQWqNgs4baz9YYlG5c7r1SuMPCSMAhso5H6djNQWpxXE0Goel0Oa0HsCyijX2HyHbKoe4mk2Xhc)ulZ)qt6qlm9pKxhce1euD6qYPLFOehsQK4dP9)qEDiswN6)HaNrXobp0RLIDckowvUhvJFtkdhbKStJID2wyYwJHfe)lvc2wyYM7jmKLRypAqsLGTyif8mvyOtdjgbKStJIDBwvMObLwEMkm0PHeEaqwVS8cyUWEunlLjyGPCpyswQjGGWSuktfg60qIhf(TCf72HrbiSddjP0GFeqc7k0jOq5EWKsd(5AmepLBXoKujfqs5EA5NRXq8qQhni7ktajL7PvUhvlggfGWomKKeKSeF5KfsaA043LPGfbdm(Jcbry7aQCpQwnSuQmsjLJ1u7qmaxWObDiwyajSRqNGSDiwyaPdboJID8HuiDOfM(hchaHrHggpKxh6VGrd6qPQaMlShvlo0Rn1eunggz7q(dX4HuiDOfM(hYRdbIAcQoDi50YpuIdjvs8HY9q9H4WWXhkxymhQl)qt6q5uSt)dP9)q5c)5qGZOyNGh61sXobz7q(dX4HWp1Y8p0Koeods6)q1YpKxhcqJ21OpK)qhcCgf7e8qVwk2j4HMRXqCSQCpQg)MugocizNgf7STWKTgdli(xQeSTWKn3tyilxXE0GKkbBXq6iGe2vOtqHY9GjLM)OqqeMLsLin4zQWqNgsmcizNgf72SQmrdkT8Gx5EuTyeqAQgJGKL4lpAqPbVY9OArgJWAAuSlI2ombOhp9CngIhs9ObzxzciPChmWuUhvlgbKMQXiizj(YJguAWpxJH4PCl2HKkPask3bdmL7r1ImgH10OyxeTDycqpE65AmepK6rdYUYeqs5EAWpxJH4PCl2HKkPask3t5yn1oelaZk(hIRzzrd6qSWashcCgf7hI)Oqqe(q5EcdDi(J2nzIg0HsEIHhnOdL6v5i4XQY9OA8Bsz4iGKDAuSZ2ct2CpHHSCf7rdsQeSfdPk3JQf4Ny4rdYMv5iOGKL4lpAqPhlJXcj(JcbrwpaO3vUhvlWpXWJgKnRYrqHhCjTq6V4EuD65AmepLBXoKujf)kxN2daILsiZJvL7r143KYqUAmwL7r1wtGD2AfGKIDT)k8BHLREunBXqQ8mvyOtdj8aGSEz5fWCH9OAwkZuspxJHaUAYwdBwLJGIFLRpwvUhvJFtkdX8cYFowpwvUhvJfk3dMK1vd1owQjygni7SaMSfdPk3dMKLAciimlLi9CngcEbmxypQw8RCDA5zQWqNgs4baz9YYlG5c7r1SKxL5x5AHjygni7SaMI)cQEunyGXuHHonKWdaY6LLxaZf2JQFxQmt5yv5EunwOCpyswxnu743KYqaYPcYwmKYuHHonKWdaY6LLxaZf2JQFxQmbdm55vz(vUwaqovqXFbvpQ(DMkm0PHeEaqwVS8cyUWEuDAW7QHAxaxnzRHnRYrWuadmxnu7c4QjBnSzvocMEUgdbC1KTg2SkhbfRS0mvyOtdj8aGSEz5fWCH9OAwQCpQwaqovqbVkZVY1Gb2ia94wibOrJFNPcdDAiHhaK1llVaMlShvFSQCpQgluUhmjRRgQD8Bsz4hQGQgBNqs9h2IHuxnu7c1qYIDOIt9vSDSGmMw(5Ame8cyUWEuT4x560GFUgdXt5wSdjvsbKuUNYX6XQY9OASGxaZf2JQT8Qm)kxJLMvEu9XQY9OASGxaZf2JQT8Qm)kxJFtkdNMQ(2XcY4XQY9OASGxaZf2JQT8Qm)kxJFtkdNeetqjJg0XQY9OASGxaZf2JQT8Qm)kxJFtkdhbKMMQ(hRk3JQXcEbmxypQ2YRY8RCn(nPmuBoHDOASC1yowvUhvJf8cyUWEuTLxL5x5A8Bsz4ct2Wja8XQY9OASGxaZf2JQT8Qm)kxJFtkdxyYgobW2ct2AmSG4FPsWgnge3TTcqsbz0FOEbX2P(brSfdPk3JQfaKtfueTDycqpUfsaA043LktblESQCpQgl4fWCH9OAlVkZVY143KYqpaiBofMXwmKcxnnkiis4eqwbvJnNcZspxJHGK9rxypQwSYowpwvUhvJf8cyUWEuTn7rXKuta6XXwwqS(GaO2zlgsNRXqWlG5c7r1IFLRpwtTdjNXEaOoDONk3Hmvd6qPQaMlShvFOCHXCiJI9d5pAlj(qEDOKvFiwWrdID8HaNHW4ObDiVo0NCccenDONk3HyHbKoe4mk2Xhc)ulZ)qt6qlm9fhRk3JQXcEbmxypQ2M9Oy6nPmKPcdDAi2wyYwJHfe)lvc2wyYM7jmKLRypAqsLGTwbiPKSo1F6B5fWCH9OAlKa0OXSvzsXKZgt1SiPZ1yi4fWCH9OAbKa0OXVnxJHGxaZf2JQf)fu9O68rEEvMFLRf8cyUWEuTasaA043NRXqWlG5c7r1cibOrJtHTyiLx9FfUi6bbB1y5kMRF6yn1oelW)JpK)qh6VGQhvFOACi)HouYQpel4ObXo(qGZqyC0GouQkG5c7r1hYRd5p0HO(FOACi)HoeFbHu7hkvfWCH9O6dfJd5p0H4k2puUAz(hIxazgYPd9xWObDi)jWhkvfWCH9OAXXQY9OASGxaZf2JQTzpkMEtkdzQWqNgITfMS1yybX)sLGTfMS5Ecdz5k2JgKujyRvaskjRt9N(wEbmxypQ2cjanAmBvMu9)zJPAwKuMkm0PHeyjN2)cQEunBXqkV6)kCr0dc2QXYvmx)uA5NRXqGxTvYObHTtdHXrdYcj9ZOyLbgymvyOtdjizDQ)03YlG5c7r1wibOrJzPecwmFaX)cav28r(5Ame4vBLmAqy70qyC0GeaQSwSRCjZ)5Ame4vBLmAqy70qyC0Geyx5sMskhRk3JQXcEbmxypQ2M9Oy6nPmCQGS1W6WGljMTyiDUgdbVaMlShvl(vU(yv5EunwWlG5c7r12ShftVjLHMGz0GSZcyYwmKQCpyswQjGGWSuI0Z1yi4fWCH9OAXVY1hRP2HKtc)Pw(HYV9GGTAouQumx)eBhIfelSFOfMoelmG0HaNrXo(q5EO(q(dX4HYvn7(Hawn)5qCy44dP9)q5EO(qSWasyVGahkWh6x5AXXQY9OASGxaZf2JQTzpkMEtkdhbKStJID2wyYwJHfe)lvc2wyYM7jmKLRypAqsLGTyivEL7btYsnbee(DPk3dMK9xUia1HtGbg45vz(vUwK9uuhYAhgfGWciPFgtjn45v)xHlIEqWwnwUI56NsZFuiicZsPsKEUgdbVaMlShvlwzPb)CngIrajSxqabKuUNg8Z1yiEk3IDiPskGKY90pLBXoKujT4mYyW2OTdta6XFBUgdXdPE0GSRmbKuU)UmowtTdjNe(ZHYV9GGTAouQumx)eBhIfgq6qGZOy)qlmDi8tTm)dnPdP)F4r1QHXdXRg7qnA6FiCDi)r9df(Hc8H6Yp0Ko0ct)dTAdHXhk)2dc2Q5qPsXC9thkWhsN1YpKxhIKnlG0Hk4H8hcshsH0HakiDi)r7drDTa9CiwyaPdboJID8H86qKSo1)dLF7bbB1COuPyU(Pd51H8h6qu)punouQkG5c7r1IJvL7r1ybVaMlShvBZEum9MugYuHHoneBlmzRXWcI)LkbBlmzZ9egYYvShniPsWwRaKus2mI703ocizNgf7y2QmPyYzJPAwKuL7r1Iraj70OyxWFuiicBhqL7r1Q5n5zQWqNgsqY6u)PVLxaZf2JQTqcqJgN)Z1yiIEqWwnwUI56Ne)fu9O6uYp5vz(vUwmcizNgf7I)cQEunBXqkV6)kCr0dc2QXYvmx)0XQY9OASGxaZf2JQTzpkMEtkdzQWqNgITfMS1yybX)sLGTfMS5Ecdz5k2JgKujyRvasAt0N(2raj70OyhZwLjftoBmvZIKYPWiptfg60qcswN6p9T8cyUWEuTfsaA048t5NRXqe9GGTASCfZ1pj(lO6r15pi(xaOYMskSfdP8Q)RWfrpiyRglxXC9thRk3JQXcEbmxypQ2M9Oy6nPmCeqYonk2zBHjBngwq8VujyBHjBUNWqwUI9Objvc2IHu5vUhmjl1eqq43LQCpys2F5IauhobgyGNxL5x5Ar2trDiRDyuaclGK(zmL08Q)RWfrpiyRglxXC9tP5pkeeHzPujslptfg60qcs2mI703ocizNgf7ywkLPcdDAirt0N(2raj70OyhdgymvyOtdjizDQ)03YlG5c7r1wibOrJFx6CngIOheSvJLRyU(jXFbvpQgmWMRXqe9GGTASCfZ1pjWUYL8DzagyZ1yiIEqWwnwUI56NeqcqJg)oi(xaOYcgy8Qm)kxlWpXWJgKnRYrqbK0pJPvUhmjl1eqqywkLPcdDAibVaMlShvBXpXWJgKnRYrW08Ij1A7Ioa942HsPKEUgdbVaMlShvlwzPLh8Z1yigbKWEbbeqs5oyGnxJHi6bbB1y5kMRFsajanA87YuWIPKg8Z1yiEk3IDiPskGKY90pLBXoKujT4mYyW2OTdta6XFBUgdXdPE0GSRmbKuU)UmowvUhvJf8cyUWEuTn7rX0BsziVwTtqCgzmSfdPWvtJccIe)aZJmt0kKrlVaa0(NEUgdXpW8iZeTcz0YlaaT)IFLRtpxJH4hyEKzIwHmA5faG2FRc5AtIFLRtZRY8RCTyUgd7pW8iZeTcz0YlaaT)ciPFgtdExnu7c4QjBnSzvocESQCpQgl4fWCH9OAB2JIP3KYqfY1MSKSzMchvZwmKcxnnkiis8dmpYmrRqgT8caq7F65Ame)aZJmt0kKrlVaa0(l(vUo9CngIFG5rMjAfYOLxaaA)TkKRnj(vUonVkZVY1I5AmS)aZJmt0kKrlVaa0(lGK(zmn4D1qTlGRMS1WMv5i4XQY9OASGxaZf2JQTzpkMEtkdhWc7ZY4SfdPWvtJccIe)aZJmt0kKrlVaa0(NEUgdXpW8iZeTcz0YlaaT)IFLRtpxJH4hyEKzIwHmA5faG2F7awyx8RC9XQY9OASGxaZf2JQTzpkMEtkdhWc72UyQSfdPWvtJccIeGGb2WOn4b3qPNRXqWlG5c7r1IFLRpwvUhvJf8cyUWEuTn7rX0BszixngRY9OARjWoBTcqsvUhmjRRgQD8XQY9OASGxaZf2JQTzpkMEtkd5fWCH9OA2wyYwJHfe)lvc2wyYM7jmKLRypAqsLGTyiDUgdbVaMlShvl(vUoT8GhUAAuqqK4hyEKzIwHmA5faG2FWaBUgdXpW8iZeTcz0YlaaT)IvgyGnxJH4hyEKzIwHmA5faG2F7awyxSYs7QHAxaxnzRHnRYrW08Qm)kxlMRXW(dmpYmrRqgT8caq7Vas6NXuslp4HRMgfeejabdSHrBWdUHadSpnxJHaemWggTbp4gsSYsjT8k3JQfaKtfueTDycqpEAL7r1caYPckI2ombOh3cjanA87sLP41bdmL7r1cmVG8hbjlXxE0GsRCpQwG5fK)iizj(YjlKa0OXVltXRdgyk3JQfJast1yeKSeF5rdkTY9OAXiG0ungbjlXxozHeGgn(DzkEDWat5EuTiJrynnk2fKSeF5rdkTY9OArgJWAAuSlizj(YjlKa0OXVltXRdgyk3JQfdJcqyhgsscswIV8ObLw5EuTyyuac7WqssqYs8LtwibOrJFxMIxpLJ1u7qVg)HGhIxL5x5A8H8h1pe(PwM)HM0Hwy6FOCH)COuvaZf2JQpe(PwM)HQ2W4HM0Hwy6FOCH)CiTpKY9LAouQkG5c7r1hIRy)qA)pux(HYf(ZH0dLS6dXcoAqSJpe4meghnOdLblU4yv5EunwWlG5c7r12ShftVjLHC1ySk3JQTMa7S1kajLxaZf2JQT8Qm)kxJzlgsNRXqWlG5c7r1cJIDljBwaP3LQCpQwWlG5c7r1cJID7ct)JvL7r1ybVaMlShvBZEum9MugomkaHDyijXwmKk)CngINYTyhsQKciPChmWMRXqmciH9cciGKY9usRCpyswQjGGWSuktfg60qcEbmxypQ2omkaHDyijDSQCpQgl4fWCH9OAB2JIP3KYWmgH10OyNTyiDUgdbE1wjJge2oneghnilK0pJIvw65Ame4vBLmAqy70qyC0GSqs)mkGeGgnMLCf7wpaOJvL7r1ybVaMlShvBZEum9MugMXiSMgf7SfdPZ1yigbKWEbbeqs5(XQY9OASGxaZf2JQTzpkMEtkdZyewtJID2IH05AmezmclUrXaciPCp9CngImgHf3OyabKa0OXSKRy36baLw(5Ame8cyUWEuTasaA0ywYvSB9aGadS5Ame8cyUWEuT4x56usRCpyswQjGGWVZuHHonKGxaZf2JQTdJcqyhgsshRk3JQXcEbmxypQ2M9Oy6nPmmJrynnk2zlgsNRXq8uUf7qsLuajL7PNRXqWlG5c7r1Iv2XQY9OASGxaZf2JQTzpkMEtkdZyewtJID2IH0miX0cI)fsiW8cYFspxJH4HupAq2vMask3tRCpyswQjGGWVZuHHonKGxaZf2JQTdJcqyhgsshRP2HyaGJg0HsEIHhnOdL6v5i4H(ly0GouQkG5c7r1hYRdbjSxq6qSWashcCgf7hs7)Hs9EkQdzpel0Oa0H4pkeeHpex7dnPdnPMgbpudBhAU8dTWl1yy8qvBy8qvFiwGsolowvUhvJf8cyUWEuTn7rX0Bszi(jgE0GSzvocYwmKoxJHGxaZf2JQfRS0Gx5EuTyeqYonk2f8hfcIWPvUhmjl1eqqywkLPcdDAibVaMlShvBXpXWJgKnRYrW0k3JQfzpf1HS2HrbiSySmglK4pkeez9aGy5yzmwi9xCpQMTODccxzUngsvUhvlgbKStJIDb)rHGiSuL7r1Iraj70OyxaOYA5pkeeHpwvUhvJf8cyUWEuTn7rX0Bszy2trDiRDyuacZwmKoxJHGxaZf2JQfRS0YlVY9OAXiGKDAuSl4pkeeHFxI0UAO2fzmclUrXaPvUhmjl1eqqyPsKcyGbExnu7ImgHf3OyaWat5EWKSutabHzPePKEUgdXdPE0GSRmbKuU)2t5wSdjvsloJmgSnA7WeGE83LXXQY9OASGxaZf2JQTzpkMEtkdhgfGWomKKylgsNRXqWlG5c7r1IFLRtZRY8RCTGxaZf2JQfqcqJg)oxXU1dakTY9GjzPMaccZsPmvyOtdj4fWCH9OA7WOae2HHK0XQY9OASGxaZf2JQTzpkMEtkdhbKMQXWwmKoxJHGxaZf2JQf)kxNMxL5x5AbVaMlShvlGeGgn(DUIDRhauAWZR(VcxmmkazvohsEu9XQY9OASGxaZf2JQTzpkMEtkdX8cYFylgsNRXqWlG5c7r1cibOrJzjxXU1dak9CngcEbmxypQwSYadS5Ame8cyUWEuT4x5608Qm)kxl4fWCH9OAbKa0OXVZvSB9aGowvUhvJf8cyUWEuTn7rX0BszOjygni7SaMSfdPZ1yi4fWCH9OAbKa0OXVdI)faQSPvUhmjl1eqqywkXXQY9OASGxaZf2JQTzpkMEtkd)qfu1y7esQ)WwmKoxJHGxaZf2JQfqcqJg)oi(xaOYMEUgdbVaMlShvlwzhRk3JQXcEbmxypQ2M9Oy6nPmeZli)HTyi1viiYfpKA8hrg3FxQCiZ0UAO2fysHrdY61I)CSESQCpQglGvMn7rXK0HrbiSddjj2IHuL7btYsnbeeMLszQWqNgs8uUf7qsL0omkaHDyijLw(5AmepLBXoKujfqs5oyGnxJHyeqc7feqajL7PCSQCpQglGvMn7rX0BszygJWAAuSZwmKoxJHaVARKrdcBNgcJJgKfs6NrXkl9Cngc8QTsgniSDAimoAqwiPFgfqcqJgZsUIDRha0XQY9OASawz2ShftVjLHzmcRPrXoBXq6CngIrajSxqabKuUFSQCpQglGvMn7rX0BszygJWAAuSZwmKoxJH4PCl2HKkPask3pwtTdXaathQA6qSWashcCgf7hIuOHXdf9HYpQuVdfJdXyTo0VA29d9OmPdrH)qWdjNsQhnOdXai7qf8qYPLFOehsQKhIrYpK2)drH)qqg8qYRPCOhLjDiGcshYF0(qEU6qQbs6Nr2oK8Zuo0JYKoelGHKf7qfN6RSJpelCbz8qqs)mEiVo0ctSDOcEi55PCOesHrd6qVul(ZHc8HuUhmjXHyawn7(H(1H8NaFOCpHHo0Jc)hIRypAqhIfAuaYHHKe(qf8q5EO(qjR(qSGJge74dbodHXrd6qb(qqs)mkowvUhvJfWkZM9Oy6nPmCeqYonk2zBHjBngwq8VujyBHjBUNWqwUI9Objvc2IHuWZuHHonKyeqYonk2TzvzIgu65Ame4vBLmAqy70qyC0GSqs)mk(vUoTY9GjzPMacc)otfg60qIhf(TCf72HrbiSddjP0GFeqc7k0jOq5EWKslp4NRXq8qQhni7ktajL7Pb)CngINYTyhsQKciPCpn4ZGetBngwq8VyeqYonk2tlVY9OAXiGKDAuSl4pkeeHzPuzagyY7QHAxOgswSdvCQVITJfKX08Qm)kxl(qfu1y7esQ)iGK(zmfWatExnu7cmPWObz9AXFs7kee5Ihsn(JiJ7VlvoKzkPKYXAQDigay6qSWashcCgf7hIc)HGh6VGrd6q6HyHbKMQXWWupgH10Oy)qCf7hk3d1hsoLupAqhIbq2Hc8HuUhmPdvWd9xWObDiswIVC6q5c)5qjKcJg0HEPw8hXXQY9OASawz2ShftVjLHJas2PrXoBlmzRXWcI)LkbBlmzZ9egYYvShniPsWwmKcEMkm0PHeJas2PrXUnRkt0Gsd(rajSRqNGcL7btkT8YlVY9OAXiG0ungbjlXxE0GslVY9OAXiG0ungbjlXxozHeGgn(DzkyrWad8WvtJccIeJasyVGaPagyk3JQfzmcRPrXUGKL4lpAqPLx5EuTiJrynnk2fKSeF5KfsaA043LPGfbdmWdxnnkiismciH9ccKskPNRXq8qQhni7ktajL7PagyY7QHAxGjfgniRxl(tAxHGix8qQXFezC)DPYHmtl)CngIhs9ObzxzciPCpn4vUhvlW8cYFeKSeF5rdcmWa)CngINYTyhsQKciPCpn4NRXq8qQhni7ktajL7PvUhvlW8cYFeKSeF5rdkn4Fk3IDiPsAXzKXGTrBhMa0JNskPCSQCpQglGvMn7rX0BszixngRY9OARjWoBTcqsvUhmjRRgQD8XQY9OASawz2ShftVjLHzmcRPrXoBXq6CngImgHf3OyabKuUNMRy36ba9(CngImgHf3OyabKa0OXP5k2TEaqVpxJHaUAYwdBwLJGcibOrJpwvUhvJfWkZM9Oy6nPmmJrynnk2zlgsZGetli(xiHaZli)j9CngIhs9ObzxzciPCpTRgQDbMuy0GSET4pPDfcICXdPg)rKX93LkhYmTY9GjzPMacc)otfg60qINYTyhsQK2HrbiSddjPJvL7r1ybSYSzpkMEtkdZEkQdzTdJcqy2IHuWZuHHonKi7POoK1MvLjAqPNRXq8qQhni7ktajL7Pb)CngINYTyhsQKciPCpT8k3dMK9xUia1HtVldWat5EWKSutabHzPuMkm0PHepk8B5k2TdJcqyhgssGbMY9GjzPMaccZsPmvyOtdjEk3IDiPsAhgfGWomKKs5yv5EunwaRmB2JIP3KYqmVG8h2IHuxHGix8qQXFezC)DPYHmt7QHAxGjfgniRxl(ZXQY9OASawz2ShftVjLHFOcQASDcj1FylgsvUhmjl1eqqywkJJvL7r1ybSYSzpkMEtkdvixBYsYMzkCunBXqQY9GjzPMaccZsPmvyOtdjuixBYsYMzkCuDAaTvrg3zPuMkm0PHekKRnzjzZmfoQ2cOTESQCpQglGvMn7rX0Bsz4WOae2HHKeBXqQY9GjzPMaccZsPmvyOtdjEu43YvSBhgfGWomKKowvUhvJfWkZM9Oy6nPmCeqAQgZX6XQY9OASa7A)v43clx9OAPdJcqyhgssSfdPk3dMKLAciimlLYuHHonK4PCl2HKkPDyuac7WqskT8Z1yiEk3IDiPskGKYDWaBUgdXiGe2liGask3t5yv5EunwGDT)k8BHLREu9BszygJWAAuSZwmKoxJHyeqc7feqajL7hRk3JQXcSR9xHFlSC1JQFtkdZyewtJID2IH05AmepLBXoKujfqs5E65AmepLBXoKujfqcqJg)UY9OAXiG0ungbjlXxoz9aGowvUhvJfyx7Vc)wy5Qhv)MugMXiSMgf7SfdPZ1yiEk3IDiPskGKY90YNbjMwq8VqcXiG0ungWaBeqc7k0jOq5EWKadmL7r1ImgH10OyxeTDycqpEkhRP2HEbY4H86qGi)qjSGb3HYGfhFOOXXNou(rL6DOShft4dvWdLQcyUWEu9HYEumHpuUhQpuwHXX0qIJvL7r1yb21(RWVfwU6r1VjLHzmcRPrXoBXq6Cngc8QTsgniSDAimoAqwiPFgfRS0YZRY8RCTaUAYwdBwLJGcibOrJFt5EuTaUAYwdBwLJGcswIVCY6ba9gxXU1daILZ1yiWR2kz0GW2PHW4ObzHK(zuajanAmyGbExnu7c4QjBnSzvocMsAMkm0PHeEaqwVS8cyUWEu9BCf7wpaiwoxJHaVARKrdcBNgcJJgKfs6NrbKa0OXhRk3JQXcSR9xHFlSC1JQFtkdZyewtJID2IH05AmepLBXoKujfqs5EAxHGix8qQXFezC)DPYHmt7QHAxGjfgniRxl(ZXQY9OASa7A)v43clx9O63KYWmgH10OyNTyiDUgdrgJWIBumGask3tZvSB9aGEFUgdrgJWIBumGasaA04J1u7qmaxWObDi)Hoe21(RW)HGLREunBhQAdJhAHPdXcdiDiWzuSJpuUhQpK)qmEifshQl)qtkAqhkRkd9p0OGhk)Os9oubpuQkG5c7r1IdXaathIfgq6qGZOy)qu4pe8q)fmAqhspelmG0unggM6XiSMgf7hIRy)q5EO(qYPK6rd6qmaYouGpKY9GjDOcEO)cgnOdrYs8Lthkx4phkHuy0Go0l1I)iowvUhvJfyx7Vc)wy5Qhv)MugocizNgf7STWKTgdli(xQeSTWKn3tyilxXE0GKkbBXqk4hbKWUcDckuUhmP0GNPcdDAiXiGKDAuSBZQYenO0YlV8k3JQfJast1yeKSeF5rdkT8k3JQfJast1yeKSeF5KfsaA043LPGfbdmWdxnnkiismciH9ccKcyGPCpQwKXiSMgf7cswIV8ObLwEL7r1ImgH10OyxqYs8LtwibOrJFxMcwemWapC10OGGiXiGe2liqkPKEUgdXdPE0GSRmbKuUNcyGjVRgQDbMuy0GSET4pPDfcICXdPg)rKX93LkhYmT8Z1yiEi1JgKDLjGKY90Gx5EuTaZli)rqYs8LhniWad8Z1yiEk3IDiPskGKY90GFUgdXdPE0GSRmbKuUNw5EuTaZli)rqYs8LhnO0G)PCl2HKkPfNrgd2gTDycqpEkPKYXQY9OASa7A)v43clx9O63KYWmgH10OyNTyindsmTG4FHecmVG8N0Z1yiEi1JgKDLjGKY90UAO2fysHrdY61I)K2viiYfpKA8hrg3FxQCiZ0k3dMKLAcii87mvyOtdjEk3IDiPsAhgfGWomKKowvUhvJfyx7Vc)wy5Qhv)MugM9uuhYAhgfGWSfdPGNPcdDAir2trDiRnRkt0Gslp4D1qTlgWcW6pKvXpegmWuUhmjl1eqqywkrkPLx5EWKS)YfbOoC6Dzagyk3dMKLAciimlLYuHHonK4rHFlxXUDyuac7WqscmWuUhmjl1eqqywkLPcdDAiXt5wSdjvs7WOae2HHKukhRk3JQXcSR9xHFlSC1JQFtkd5QXyvUhvBnb2zRvasQY9GjzD1qTJpwvUhvJfyx7Vc)wy5Qhv)Mug(HkOQX2jKu)HTyiv5EWKSutabHzPehRk3JQXcSR9xHFlSC1JQFtkdX8cYFylgsDfcICXdPg)rKX93LkhYmTRgQDbMuy0GSET4phRP2HKtc)5quxlqphYviiYXSDOWpuGpKEiqA0hYRdXvSFiwOrbiSddjPdP4dncJHGhkASt6)q14qSWast1yehRk3JQXcSR9xHFlSC1JQFtkdvixBYsYMzkCunBXqQY9GjzPMaccZsPmvyOtdjuixBYsYMzkCuDAaTvrg3zPuMkm0PHekKRnzjzZmfoQ2cOTESQCpQglWU2Ff(TWYvpQ(nPmCyuac7WqsITyiv5EWKSutabHzPuMkm0PHepk8B5k2TdJcqyhgsshRk3JQXcSR9xHFlSC1JQFtkdhbKMQXS9TV3a]] )

end
