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


    spec:RegisterPack( "Fire", 20201125, [[de10idqiqspskuUekPkztIOprkzusrDkPiRskOELksZIu4wQOQ2fj)cKyyKICmrOLjf4zQOY0ifvDnsrzBOGQVHsQyCsHkNtfr16qjL5HcCpuQ9HsY)qjvPCqvuflufLhQIWevrvkxuku1grbLpQIQKrkfK6KOKkTsuIxIsQIzIcYnvruANsP8tsrfdLuuPLQIO4PKQPkLQRkfKSvusvQ(kkPQgRui7vQ(lfdgYHjwSOEmQMmOUmYMvYNbXOvHtlSAvuLQxlcMnLUTkTBf)wYWfPJRIilh45qnDQUUsTDu03LsgpPuNhfA9sbX8bP2VQUNyV9UoS4uVTgOPgOPetSbAMstN8e1mnpdVR7mMsD9uHNGaH66JCPUodlauxpvy0wcCV9UoU2ao11pCpfZAqbkqc)yNv86cfCC3wXJA4az5qbhxou665DyDw3PN76WIt92AGMAGMsmXgOzknDYtuZ08A(UUS9Jc011J7j66hbmmn9CxhMW8UEJ9igwaOhDYkqONLg7rhUNIznOafiHFSZkEDHcoUBR4rnCGSCOGJlhkpln2JARys3mbEudoNgpQbAQbA6z5zPXE0joKbcHzTNLg7rN)JAOW0JwbKd3aORed(raXpiWJ8dzEKlaiKR84sgVmWb9OvbEKvW(5JjEnWpsYHnCgF0glqiS6zPXE05)OgQuyXPhzlib)raI1EedT5b8JoVbi5Ivpln2Jo)hXqvHP5rCb7pcqN0oa0Lgh)OvbE0jQBEJ9OMh1COiLgpcUgT8hDuw4hf(Jwf4rYJwacF8OtwYPc8iUG9Mupln2Jo)h14hjBPhHDqW9hXpiEcXa5r18i5rlQ1Jwfib8JI5r(b9OZJMld9iVEeGG3C6rTkqc2sGvDDBGDCV9UoVU5n2JAm8QSWvRb3BV3wI9276c3JA66PLh101PrYwcUFw37T1GE7DDH7rnD9STkyZAdySRtJKTeC)SU3B7C9276c3JA66zcGjqcXaPRtJKTeC)SU3BtZ3BVRlCpQPRVcaLTvb31PrYwcUFw37TPz9276c3JA66YWjSdeRHlwBxNgjBj4(zDV3gdV3Exx4EutxFJjt40f31PrYwcUFw37TX60BVRtJKTeC)SUUW9OMUoeRahIxaSjlWqOU(gtMATmq4W92sSRZbHtGq66c3JAuxYPcOIXSSbKd)rqd9J4vzHRwJ6sovafGUsm4hXQhLOM660ArC3mYL66qScCiEbWMSadH6EVTgxV9Uons2sW9Z66Cq4eiKUoyp0QaqiLt30ciwtlbKQOrYwc(rjFuEVwks7dzJ9Og1oTRlCpQPR7XLmTeqA37ExhMwY26927TLyV9Uons2sW9Z66Cq4eiKUouFeyp0QaqifCG5rQngbWOHx3RmWkAKSLG76c3JA668ApobWPK129EBnO3ExNgjBj4(zD9kTRJjVRlCpQPRZuaHKTuxNPy3ux3flnUAfac7cWjGIgjBj4h1WpAfac7cWjGcqxjg8Jo9rn)iEvw4Q1O41nVXEuJYbBYaORed(rn8JA(rj(OZ)rmfqizlPsigyBmqmacEZ9OMh1WpYflnUkHyGTXarrJKTe8JA6rn9Og(rq9r8QSWvRrXRBEJ9OgfGeygFud)O8ETu86M3ypQrbxTMUotbyg5sDDpUKXldVU5n2JA6EVTZ1BVRtJKTeC)SUEL21VI2DDH7rnDDMciKSL66mf7M66mfqizlPOBkJasSMcapYWjdmzfgF05)OMFeVklC1Au0nLrajwtbGhz4KcEdepQ5rN)J4vzHRwJIUPmciXAka8idNua6kXGFutpQHFeuFeVklC1Au0nLrajwtbGhz4KcqcmJDDoiCcesxNoPDKMsWk6MYiGeRPaWJmCQRZuaMrUux3Jlz8YWRBEJ9OMU3BtZ3BVRtJKTeC)SUEL21VI2DDH7rnDDMciKSL66mf7M668QSWvRrbXkWH4faBYcmesbORedURZbHtGq660jTJ0ucwbXkWH4faBYcmeQRZuaMrUux3Jlz8YWRBEJ9OMU3BtZ6T31PrYwcUFwxVs76xr7UUW9OMUotbes2sDDMIDtD98ETuG9qMAzsRweqbORedURZbHtGq66UyPXvG9qMAzsRweqrJKTe8Js(O8ETu86M3ypQrbxTMUotbyg5sDDpUKXldVU5n2JA6EVngEV9Uons2sW9Z66vAx)kA31fUh101zkGqYwQRZuSBQRZRYcxTgfypKPwM0Qfbua6kXGF0PpkVxlfypKPwM0QfbuWBG4rnDDoiCcesx3flnUcShYultA1IakAKSLGFuYhL3RLIx38g7rnk4Q18OKpIxLfUAnkWEitTmPvlcOa0vIb)OtFKM9ig8iMciKSLuECjJxgEDZBSh101zkaZixQR7XLmEz41nVXEut37TX60BVRtJKTeC)SUoheobcPRN3RLIx38g7rnk4Q18OKpIPacjBjLhxY4LHx38g7rnpIvpATTwdGG3CpQ5rjFuZpIxLfUAnkWEitTmPvlcOa0vIb)iw9O12AnacEZ9OMhbn0pcQpYflnUcShYultA1IakAKSLGFutDDH7rnDD8rS8yGysRweO792AC92760izlb3pRRZbHtGq66n)O8ETu86M3ypQrbxTMhL8r59APa7Hm1YKwTiGcUAnpk5JA(rmfqizlP84sgVm86M3ypQ5rm4rK2eF7KXJl9iOH(rmfqizlP84sgVm86M3ypQ5rS6r8QSWvRrbe4qg3Gtfqck4nq8OMh10JA6rqd9JA(r59APa7Hm1YKwTiGAN(OKpIPacjBjLhxY4LHx38g7rnpIvp6CA6rn11fUh101bcCiJBWPciHU3B7K3BVRtJKTeC)SUoheobcPRN3RLIx38g7rnk4Q18OKpkVxlfypKPwM0QfbuWvR5rjFetbes2skpUKXldVU5n2JAEedEePnX3oz84sDDH7rnDDys8JCbgQ792sut92760izlb3pRRZbHtGq6659AP41nVXEuJcUAnpk5JGP8ETuaboKXn4ubKGH52oeqYHnCgvWvRPRlCpQPRFdaOaM4kqOU3BlXe7T31PrYwcUFwxx4EutxhIvGdXla2KfyiuxNdcNaH01zkGqYws5XLmEz41nVXEuZJy1JeUh1y4vzHRwZJo)hPzDDATiUBg5sDDiwboeVaytwGHqDV3wInO3ExNgjBj4(zDDH7rnDD6MYiGeRPaWJmCQRZbHtGq66mfqizlP84sgVm86M3ypQ5rmG9JykGqYwsr3ugbKynfaEKHtgyYkm21h5sDD6MYiGeRPaWJmCQ792s8C92760izlb3pRRlCpQPRJRT1eqMWjqxNdcNaH01zkGqYws5XLmEz41nVXEuZJyf7hXuaHKTKQgZgtg(2R1QRpYL664ABnbKjCc09EBjQ57T31PrYwcUFwxx4EutxhILX0dtTmcgh3WkEutxNdcNaH01zkGqYws5XLmEz41nVXEuZJyf7hXuaHKTKQgZgtg(2R1QRpYL66qSmMEyQLrW44gwXJA6EVTe1SE7DDAKSLG7N11fUh101VcxYaYGpiYn3no4DDoiCcesxNPacjBjLhxY4LHx38g7rnpIbSFKM11h5sD9RWLmGm4dICZDJdE37TLidV3ExNgjBj4(zDDH7rnDDyajWRaqgMegt2UoheobcPRZuaHKTKYJlz8YWRBEJ9OMhXk2pIPacjBjvnMnMm8TxRvxFKl11HbKaVcazysymz7EVTezD6T31PrYwcUFwxx4EutxxAi4dbiyZQg3ultA1IaDDoiCcesxNPacjBjLhxY4LHx38g7rnpIbSFKM9OtFuIA2JA4hXuaHKTKAvJBGRD2sMAmBm9OKpIPacjBjLhxY4LHx38g7rnpIvpstD9rUuxxAi4dbiyZQg3ultA1IaDV3wInUE7DDAKSLG7N115GWjqiD9MFetbes2skpUKXldVU5n2JAEedEuIA6rqd9JwbKd3aORed(rm4rmfqizlP84sgVm86M3ypQ5rn11fUh101HSfaCiJPwgPHqGYp6EVTep59276c3JA668A404aXjyZYkxQRtJKTeC)SU3BRbAQ3Exx4EutxhqsAmqmlRCjCxNgjBj4(zDV3wdsS3Exx4EutxFv8nMGnsdHaHtMmj3Uons2sW9Z6EVTg0GE7DDH7rnD90niwmgdet2kyVRtJKTeC)SU3BRbNR3Exx4EutxhePPwYeJbNkCQRtJKTeC)SU3BRbA(E7DDH7rnDD)Gm7jx7b2SkaN660izlb3pR792AGM1BVRtJKTeC)SUoheobcPRd2dTkaesbhyEKAJramA419kdSIgjBj4hL8r8QSWvRrL3RLboW8i1gJay0WR7vgyfGeygFuYhL3RLcoW8i1gJay0WR7vgyJa4Yqk4Q18OKpIPacjBjLhxY4LHx38g7rnpIvp6CA6rjFeuFuEVwk4aZJuBmcGrdVUxzGv70UUW9OMUoV2JtaCkzTDV3wdy492760izlb3pRRZbHtGq66G9qRcaHuWbMhP2yeaJgEDVYaROrYwc(rjFeVklC1Au59AzGdmpsTXiagn86ELbwbibMXhL8r59APGdmpsTXiagn86ELb2iaUmKcUAnpk5JykGqYws5XLmEz41nVXEuZJy1JoNMEuYhb1hL3RLcoW8i1gJay0WR7vgy1oTRlCpQPRlaUmKH0o1w4OMU3BRbSo92760izlb3pRRZbHtGq66G9qRcaHuWbMhP2yeaJgEDVYaROrYwc(rjFeVklC1Au59AzGdmpsTXiagn86ELbwbibMXhL8r59APGdmpsTXiagn86ELb2Saf2vWvR5rjFetbes2skpUKXldVU5n2JAEeRE0500Js(iO(O8ETuWbMhP2yeaJgEDVYaR2PDDH7rnD9fOWEUSE37T1GgxV9Uons2sW9Z66Cq4eiKUouFetbes2sk4alzlz41nVXEuZJs(iMciKSLuECjJxgEDZBSh18igW(rAQRlCpQPRZfR1iCpQXydS31Tb2nJCPUoVU5n2JAmPhcM6EVTgCY7T31PrYwcUFwxVs76yY76c3JA66mfqizl11zk2n11H6JykGqYwsbhyjBjdVU5n2JAEuYhXuaHKTKYJlz8YWRBEJ9OMhXGhjCpQrTcazYwb7Q12AnaIFiaiKXJl9OZ)rc3JAu4Jy5XaXKwTiGATTwdGG3CpQ5rn8JA(r8QSWvRrHpILhdetA1IakaDLyWpIbpIPacjBjLhxY4LHx38g7rnpQPhL8rmfqizlP84sgVm86M3ypQ5rm4rRaYHBa0vIb)iOH(rUyPXvG9qMAzsRweqrJKTe8Js(O8ETuG9qMAzsRweqbxTMhL8r8QSWvRrb2dzQLjTArafGUsm4hXGhjCpQrTcazYwb7Q12AnaIFiaiKXJl9OZ)rc3JAu4Jy5XaXKwTiGATTwdGG3CpQ5rn8JA(r8QSWvRrHpILhdetA1IakaDLyWpIbpIxLfUAnkWEitTmPvlcOa0vIb)OMEuYhXRYcxTgfypKPwM0Qfbua6kXGFedE0kGC4gaDLyWDDMcWmYL66RaqMSvWUjTkBmq6EVTZPPE7DDAKSLG7N11R0UoM8UUW9OMUotbes2sDDMIDtDDO(iMciKSLuWbwYwYWRBEJ9OMhL8rmfqizlP84sgVm86M3ypQ5rm4rc3JAuPhfnH2MLvUewT2wRbq8dbaHmECPhD(ps4EuJcFelpgiM0QfbuRT1Aae8M7rnpQHFuZpIxLfUAnk8rS8yGysRweqbORed(rm4rmfqizlP84sgVm86M3ypQ5rn9OKpIPacjBjLhxY4LHx38g7rnpIbpAfqoCdGUsm4hbn0pcShAvaiKcVhtcXabBYwcJJbIIgjBj4Uotbyg5sD90JIMqBtAv2yG09EBNlXE7DDAKSLG7N115GWjqiD98ETuG9qMAzsRweqbxTMhL8rq9r59APwbGWEbUkajC)rjFuZpIPacjBjLhxY4LHx38g7rnpIvSFuEVwkWEitTmPvlcOG3aXJAEuYhXuaHKTKYJlz8YWRBEJ9OMhXQhjCpQrTcazYwb7Q12AnaIFiaiKXJl9iOH(rmfqizlP84sgVm86M3ypQ5rS6rRaYHBa0vIb)iOH(rmfqizlPGdSKTKHx38g7rnpQPUUW9OMUoypKPwM0Qfb6EVTZ1GE7DDAKSLG7N115GWjqiD98ETuG9qMAzsRweqTtFuYh18JykGqYws5XLmEz41nVXEuZJy1J00JAQRlCpQPRZfR1iCpQXydS31Tb2nJCPUoOsnPhcM6EVTZDUE7DDAKSLG7N11R0UoM8UUW9OMUotbes2sDDMIDtDDMciKSLuECjJxgEDZBSh18ig8iH7rnQ0JIMqBZYkxcRwBR1ai(HaGqgpU0Js(iMciKSLuECjJxgEDZBSh18ig8Ova5Wna6kXGFe0q)iWEOvbGqk8EmjedeSjBjmogikAKSLG76mfGzKl11tpkAcTnPvzJbs37TDonFV9Uons2sW9Z66BmzADewYWfShdKEBj215GWjqiDDO(iMciKSLuRaqMSvWUjTkBmqEuYh18JykGqYws5XLmEz41nVXEuZJy1J00JGg6hjCpysgAOBq4hXk2pIPacjBj1HaGnCb7MLvUe2brc0Js(iO(OvaiSlaNakH7bt6rjFeuFuEVwQJYnyhqsckajC)rjFuZpkVxl1bjEmqm7ufGeU)OKps4EuJAzLlHDqKaPiTj(2jdGUsm4hXGhPjLM9iOH(r8dbaHWMfq4EuJyFeRy)Og8OMEutD9nMm1AzGWH7TLyxx4EutxFfaYKTc27EVTZPz92760izlb3pRRVXKP1ryjdxWEmq6TLyxNdcNaH01xbGWUaCcOeUhmPhL8r8dbaHWpIvSFuIpk5JG6JykGqYwsTcazYwb7M0QSXa5rjFuZpcQps4EuJAfaklwRI0M4Bpgipk5JG6JeUh1OszeuzRGDvmMLnGC4pk5JY71sDqIhdeZovbiH7pcAOFKW9Og1kauwSwfPnX3EmqEuYhb1hL3RL6OCd2bKKGcqc3Fe0q)iH7rnQugbv2kyxfJzzdih(Js(O8ETuhK4XaXStvas4(Js(iO(O8ETuhLBWoGKeuas4(JAQRVXKPwldeoCVTe76c3JA66RaqMSvWE37TDogEV9Uons2sW9Z66BmzADewYWfShdKEBj21fUh101xbGmzRG9UoheobcPRlCpQrHpILhdetA1IaksBIV9yG8OKpATTwdG4hcacz84spIbps4EuJcFelpgiM0QfbuEWtWai4n3JAEuYhL3RL6OCd2bKKGcUAnDV325yD6T31PrYwcUFwxNdcNaH01B(rmfqizlP84sgVm86M3ypQ5rS6rA6rqd9JykGqYwsbhyjBjdVU5n2JAEutpk5JY71sb2dzQLjTArafC1A66c3JA66CXAnc3JAm2a7DDBGDZixQRJDzGfaSbuU4rnDV325AC9276c3JA66yEb4hDDAKSLG7N19U31tbeVUzX7T3BlXE7DDH7rnDDbWLHmX4K1sCVRtJKTeC)SU3BRb92760izlb3pRRxPDDm5DDH7rnDDMciKSL66mf7M66n4rn8JCXsJRww5sMuX5hkAKSLGF0Pp6CpQHFeuFKlwAC1YkxYKko)qrJKTeCxNdcNaH01zkGqYwsDuUb7assWSSYLWoisGEe7hPPUotbyg5sD9JYnyhqscMLvUe2brcu37TDUE7DDAKSLG7N11R0UoM8UUW9OMUotbes2sDDMIDtD9g8Og(rUyPXvlRCjtQ48dfns2sWp60hDUh1WpcQpYflnUAzLlzsfNFOOrYwcURZbHtGq66mfqizlPoeaSHly3SSYLWoisGEe7hPPUotbyg5sD9dbaB4c2nlRCjSdIeOU3BtZ3BVRtJKTeC)SUEL21XK31fUh101zkGqYwQRZuSBQRFUh1WpYflnUAzLlzsfNFOOrYwc(rN(ig(JA4hb1h5ILgxTSYLmPIZpu0izlb315GWjqiDDMciKSLu86M3ypQXSSYLWoisGEe7hPPUotbyg5sDDEDZBSh1yww5syhejqDV3MM1BVRtJKTeC)SUEL21XK31fUh101zkGqYwQRZuSBQRFYp5pQHFKlwAC1YkxYKko)qrJKTe8Jo9rn4rn8JG6JCXsJRww5sMuX5hkAKSLG76Cq4eiKUotbes2skbWLHmK2P2ch18i2pstDDMcWmYL66cGldziTtTfoQP792y492760izlb3pRRxPDDaHjVRlCpQPRZuaHKTuxNPamJCPUUa4Yqgs7uBHJAmxzKUomTKT176AEn19EBSo92760izlb3pRRxPDDaHjVRlCpQPRZuaHKTuxNPamJCPUomzfgnlRCjSdIeOUomTKT176AQ792AC92760izlb3pRRxPDDaHjVRlCpQPRZuaHKTuxNPamJCPUEcXaBJbIbqWBUh101HPLSTExxtknF37TDY7T31PrYwcUFwxVs76yY76c3JA66mfqizl11zk2n111SUotbyg5sDDCczd8giEut37TLOM6T31PrYwcUFwxVs76yY76c3JA66mfqizl11zk2n11PtAhPPeS6kCjdid(Gi3C34G)iOH(r0jTJ0ucwDLjwe2ltTmxbEim(rqd9JOtAhPPeScIvGdXla2Kfyi0JGg6hrN0ostjyfeRahIxaS5sWI1g18iOH(r0jTJ0ucwfqMWJAmxbcHnRnMEe0q)i6K2rAkbR8gIme2Kfqc40yi8JGg6hrN0ostjyL0q2aYpkSbhdec2KA3xbc9iOH(r0jTJ0ucwjdpOXnjmLBQLPvGHR7JGg6hrN0ostjyf(O4jKdNayZsgipcAOFeDs7inLGvdTbI1GzCKumzO5qgobEe0q)i6K2rAkbRYILwbGmzGm8JUotbyg5sDDEDZBSh1yQXSXu37TLyI92760izlb3pRRxPDDm5DDH7rnDDMciKSL66mf7M660jTJ0ucwjne8HaeSzvJBQLjTArGhL8rmfqizlP41nVXEuJPgZgtDDMcWmYL66RACdCTZwYuJzJPU3BlXg0BVRtJKTeC)SUEL21XK31fUh101zkGqYwQRZuSBQR3an9Og(rmfqizlP41nVXEuJPgZgtp60hPzpQHFeDs7inLGvxHlzazWhe5M7gh8Uotbyg5sD9AmBmz4BVwRU3BlXZ1BVRtJKTeC)SUEL21XK31fUh101zkGqYwQRZuSBQRNyJRRZbHtGq66mfqizlPw14g4ANTKPgZgtpk5JG6JCXsJRwbGWUaCcOOrYwc(rjFetbes2sQvnUPwM0QfbmPaIx3S4g(HmdzFe7hPPUotbyg5sD9vnUPwM0QfbmPaIx3S4g(Hmdz7EVTe1892760izlb3pRRxPDDaHjVRlCpQPRZuaHKTuxNPamJCPUoDtzeqI1ua4rgozGjRWyxhMwY26D9eBCDV3wIAwV9Uons2sW9Z66vAxhqyY76c3JA66mfqizl11zkaZixQRZRBEJ9Ogd(iwEmqmPvlc01HPLSTExVbDV3wIm8E7DDAKSLG7N11h5sDDPHGpeGGnRACtTmPvlc01fUh101Lgc(qac2SQXn1YKwTiq37TLiRtV9UUW9OMU(naGcyIRaH660izlb3pR792sSX1BVRtJKTeC)SUoheobcPRd1hLciMQugbv2kyVRlCpQPRNYiOYwb7DV7DDEDZBSh1yspem1BV3wI92760izlb3pRRZbHtGq6659AP41nVXEuJcUAnDDH7rnDDBa5WXMZ7ByixA8U3BRb92760izlb3pRRxPDDm5DDH7rnDDMciKSL66mf7M6659AP41nVXEuJcqxjg8Jo9r59AP41nVXEuJcEdepQ5rn8JA(r8QSWvRrXRBEJ9OgfGUsm4hXGhL3RLIx38g7rnkaDLyWpQPUotbyg5sDDsBNgyc2WRBEJ9OgdGUsm4U3B7C92760izlb3pRRxPDDbgURlCpQPRZuaHKTuxNPy3uxNPacjBjfoHSbEdepQPRZbHtGq6659APW7XKqmqWMSLW4yGyaKaZOAN(iOH(rmfqizlPiTDAGjydVU5n2JAma6kXGFeREuIkn7rn8JGWHvxr7h1WpQ5hL3RLcVhtcXabBYwcJJbI6kABWUWt4rN)JY71sH3JjHyGGnzlHXXarHDHNWJAQRZuaMrUuxN02PbMGn86M3ypQXaORedU7920892760izlb3pRRZbHtGq6659AP41nVXEuJcUAnDDH7rnD9SaXulJdcEc4U3BtZ6T31PrYwcUFwxNdcNaH01fUhmjdn0ni8Jy1Js8rjFuEVwkEDZBSh1OGRwtxx4Eutx3gmJbIjx3C37TXW7T31PrYwcUFwxNdcNaH01Z71sXRBEJ9OgfC1AEuYhL3RLcShYultA1Iak4Q101fUh101VbauaSPwgVaxA8U3BJ1P3ExNgjBj4(zDDH7rnD9dgtjGFaib20ceyVfqsXDDoiCcesxpVxlfVU5n2JAu70hL8rc3JAuRaqMSvWUIFiaie(rSFKMEuYhjCpQrTcazYwb7kaXpeaeY4XLEeREeeoS6kA31h5sD9dgtjGFaib20ceyVfqsXDV3wJR3Exx4EutxpBRc2ulJFqgAOlJDDAKSLG7N19EBN8E7DDH7rnD9lDlaJMAzSBEaBGbKCXDDAKSLG7N19EBjQPE7DDH7rnD9wfWcZKIXaiCnYWPUons2sW9Z6EVTetS3ExNgjBj4(zD9nMmToclz4c2JbsVTe76c3JA66RaqMSvWExNdcNaH01fUh1OUbauaSPwgVaxACfPnX3EmqEuYhT2wRbq8dbaHmECPhD(ps4EuJ6gaqbWMAz8cCPXvK2eF7Kbqxjg8JyWJ08pk5JG6Jok3GDajjyWPK1InXyw2aYH)OKpcQpkVxl1r5gSdijbfGeU)OKpQ5hL3RLIx38g7rnQD6JGg6hb1hXRbEhUkMfbgXA4cMlWKIgjBj4h1u37TLyd6T31PrYwcUFwxFJjtRJWsgUG9yG0BlXUoheobcPRd1hjneceoPYwb7eWCfStafns2sWpk5JA(rc3dMKHg6ge(rmG9JeUhmjdC5QaYeo9iOH(rq9r8QSWvRrLEu0eABww5syfGeygFutpk5JG6J41aVdxfZIaJynCbZfysrJKTe8Js(i(HaGq4hXk2pkXhL8r59AP41nVXEuJAN(OKpcQpkVxl1kae2lWvbiH7pk5JG6JY71sDuUb7assqbiH7pk5Jok3GDajjyWPK1InXyw2aYH)OtFuEVwQds8yGy2PkajC)rm4rnORVXKPwldeoCVTe76c3JA66RaqMSvWE37TL456T31PrYwcUFwxFJjtRJWsgUG9yG0BlXUoheobcPRd1hjneceoPYwb7eWCfStafns2sWpk5JA(rc3dMKHg6ge(rmG9JeUhmjdC5QaYeo9iOH(rq9r8QSWvRrLEu0eABww5syfGeygFutpk5J41aVdxfZIaJynCbZfysrJKTe8Js(i(HaGq4hXk2pkXhL8rn)OMFKW9Og1kaKjBfSR4hcacHnlGW9OgX(OtFuZpIPacjBjfPTtdmbB41nVXEuJbqxjg8Jo)hL3RLkMfbgXA4cMlWKcEdepQ5rn9iO8iEvw4Q1OwbGmzRGDf8giEuZJo)hXuaHKTKI02PbMGn86M3ypQXaORed(rq5rn)O8ETuXSiWiwdxWCbMuWBG4rnp68FeeoS6kA)OMEutpIvSFKMEe0q)iMciKSLuK2onWeSHx38g7rngaDLyWpIbSFuEVwQyweyeRHlyUatk4nq8OMhbn0pkVxlvmlcmI1WfmxGjfGUsm4hXGhbHdRUI2pcAOFeVklC1Au4Jy5XaXKwTiGcqcmJpk5JeUhmjdn0ni8Jyf7hXuaHKTKIx38g7rng8rS8yGysRwe4rjFeVysJmUAcihUzj0JA6rjFuEVwkEDZBSh1O2Ppk5JA(rq9r59APwbGWEbUkajC)rqd9JY71sfZIaJynCbZfysbORed(rm4rAsPzpQPhL8rq9r59APok3GDajjOaKW9hL8rhLBWoGKem4uYAXMymlBa5WF0PpkVxl1bjEmqm7ufGeU)ig8Og013yYuRLbchU3wIDDH7rnD9vait2kyV792suZ3BVRtJKTeC)SUoheobcPRd2dTkaesbhyEKAJramA419kdSIgjBj4hL8r59APGdmpsTXiagn86ELbwbxTMhL8r59APGdmpsTXiagn86ELb2iaUmKcUAnpk5J4vzHRwJkVxldCG5rQngbWOHx3RmWkajWm21fUh10151ECcGtjRT792suZ6T31PrYwcUFwxNdcNaH01b7HwfacPGdmpsTXiagn86ELbwrJKTe8Js(O8ETuWbMhP2yeaJgEDVYaRGRwZJs(O8ETuWbMhP2yeaJgEDVYaBeaxgsbxTMhL8r8QSWvRrL3RLboW8i1gJay0WR7vgyfGeyg76c3JA66cGldziTtTfoQP792sKH3BVRtJKTeC)SUoheobcPRd2dTkaesbhyEKAJramA419kdSIgjBj4hL8r59APGdmpsTXiagn86ELbwbxTMhL8r59APGdmpsTXiagn86ELb2Saf2vWvRPRlCpQPRVaf2ZL17EVTezD6T31PrYwcUFwxx4EutxNlwRr4EuJXgyVRBdSBg5sDDH7btY4ILgh39EBj246T31PrYwcUFwxFJjtRJWsgUG9yG0BlXUoheobcPRN3RLIx38g7rnk4Q18OKpQ5hb2dTkaesbhyEKAJramA419kdSIgjBj4hX(r59APGdmpsTXiagn86ELbwTtFutpk5JA(rc3JAuxYPcOIXSSbKd)rjFKW9Og1LCQaQymlBa5Wna6kXGFedy)inPy4pcAOFKW9OgfMxa(HI0M4Bpgipk5JeUh1OW8cWpuK2eF7Kbqxjg8JyWJ0KIH)iOH(rc3JAuRaqzXAvK2eF7Xa5rjFKW9Og1kauwSwfPnX3oza0vIb)ig8inPy4pcAOFKW9OgvkJGkBfSRiTj(2JbYJs(iH7rnQugbv2kyxrAt8TtgaDLyWpIbpstkg(JAQRVXKPwldeoCVTe76c3JA6686M3ypQP792s8K3BVRtJKTeC)SUoheobcPRN3RLIx38g7rnkRGDdPDAaOhXa2ps4EuJIx38g7rnkRGDZgtWDDH7rnDDUyTgH7rngBG9UUnWUzKl1151nVXEuJHxLfUAn4U3BRbAQ3ExNgjBj4(zDDoiCcesxV5hL3RL6OCd2bKKGcqc3Fe0q)O8ETuRaqyVaxfGeU)OMEuYhjCpysgAOBq4hXk2pIPacjBjfVU5n2JAmlRCjSdIeOUUW9OMU(Ykxc7GibQ792AqI92760izlb3pRRZbHtGq6659APW7XKqmqWMSLW4yGyaKaZOAN(OKpkVxlfEpMeIbc2KTeghdedGeygva6kXGFeREexWUXJl11fUh101tzeuzRG9U3BRbnO3ExNgjBj4(zDDoiCcesxpVxl1kae2lWvbiH7DDH7rnD9ugbv2kyV792AW56T31PrYwcUFwxNdcNaH01Z71sLYiO4wbFvas4(Js(O8ETuPmckUvWxfGUsm4hXQhXfSB84spk5JA(r59AP41nVXEuJcqxjg8Jy1J4c2nECPhbn0pkVxlfVU5n2JAuWvR5rn11fUh101tzeuzRG9U3BRbA(E7DDAKSLG7N115GWjqiD98ETuhLBWoGKeuas4(Js(O8ETu86M3ypQrTt76c3JA66PmcQSvWE37T1anR3ExNgjBj4(zDDoiCcesxpfqmnq4WQevyEb4hpk5JY71sDqIhdeZovbiH7DDH7rnD9ugbv2kyV792AadV3ExNgjBj4(zDDH7rnDD8rS8yGysRweORZbHtGq6659AP41nVXEuJAN(OKpcQps4EuJAfaYKTc2v8dbaHWpk5JeUhmjdn0ni8Jyf7hXuaHKTKIx38g7rng8rS8yGysRwe4rjFKW9Ogv6rrtOTzzLlHvRT1Aae)qaqiJhx6rS6rRT1Aae8M7rnD9yCca2PUjwDDH7rnQvait2kyxXpeaecZw4EuJAfaYKTc2vxrBd)qaqiC37T1awNE7DDAKSLG7N115GWjqiD98ETu86M3ypQrTtFuYh18JA(rc3JAuRaqMSvWUIFiaie(rm4rj(OKpYflnUkLrqXTc(QOrYwc(rjFKW9GjzOHUbHFe7hL4JA6rqd9JG6JCXsJRszeuCRGVkAKSLGFe0q)iH7btYqdDdc)iw9OeFutpk5JY71sDqIhdeZovbiH7p60hDuUb7assWGtjRfBIXSSbKd)rm4rnORlCpQPRNEu0eABww5s4U3BRbnUE7DDAKSLG7N115GWjqiD98ETu86M3ypQrbxTMhL8r8QSWvRrXRBEJ9OgfGUsm4hXGhXfSB84spk5JG6J41aVdxTSYLmcNdipQrrJKTe8Js(OMFemL3RL6gaqbWMAz8cCPXvWvR5rqd9JG6J41aVdxfZIaJynCbZfysrJKTe8JAQRlCpQPRVcaLfRT792AWjV3ExNgjBj4(zDDoiCcesxpVxlfVU5n2JAua6kXGFeREexWUXJl9OKpkVxlfVU5n2JAu70hbn0pkVxlfVU5n2JAuWvR5rjFeVklC1Au86M3ypQrbORed(rm4rCb7gpUuxx4EutxhZla)O792oNM6T31PrYwcUFwxNdcNaH01Z71sXRBEJ9OgfGUsm4hXGhbHdRUI2pk5JeUhmjdn0ni8Jy1JsSRlCpQPRBdMXaXKRBU792oxI92760izlb3pRRZbHtGq6659AP41nVXEuJcqxjg8JyWJGWHvxr7hL8r59AP41nVXEuJAN21fUh101HbcKAWMmGe)O792oxd6T31PrYwcUFwxNdcNaH01DbaHC1bjw)qLY9hXa2p6CA6rjFKlwACfMeqmqmET5hkAKSLG76c3JA66yEb4hDV7DDH7btY4ILgh3BV3wI92760izlb3pRRZbHtGq66c3dMKHg6ge(rS6rj(OKpkVxlfVU5n2JAuWvR5rjFuZpIPacjBjLhxY4LHx38g7rnpIvpIxLfUAnkBWmgiMCDZk4nq8OMhbn0pIPacjBjLhxY4LHx38g7rnpIbSFKMEutDDH7rnDDBWmgiMCDZDV3wd6T31PrYwcUFwxNdcNaH01H6JykGqYwsbhyjBjdVU5n2JAEuYhXuaHKTKYJlz8YWRBEJ9OMhXa2pstpcAOFuZpIxLfUAnQl5ubuWBG4rnpIbpIPacjBjLhxY4LHx38g7rnpk5JG6JCXsJRa7Hm1YKwTiGIgjBj4h10JGg6h5ILgxb2dzQLjTArafns2sWpk5JY71sb2dzQLjTAra1o9rjFetbes2skpUKXldVU5n2JAEeREKW9Og1LCQakEvw4Q18iOH(rRaYHBa0vIb)ig8iMciKSLuECjJxgEDZBSh18iOH(rmfqizlPGdSKTKHx38g7rnDDH7rnD9l5ub6EVTZ1BVRtJKTeC)SUoheobcPR7ILgxjwsBSdeCdrWM1gWOIgjBj4hL8rn)O8ETu86M3ypQrbxTMhL8rq9r59APok3GDajjOaKW9h1uxx4EutxhgiqQbBYas8JU39Uo2LbwaWgq5Ih10BV3wI92760izlb3pRRZbHtGq66c3dMKHg6ge(rSI9JykGqYwsDuUb7assWSSYLWoisGEuYh18JY71sDuUb7assqbiH7pcAOFuEVwQvaiSxGRcqc3FutDDH7rnD9LvUe2brcu37T1GE7DDAKSLG7N115GWjqiD98ETuRaqyVaxfGeU31fUh101tzeuzRG9U3B7C92760izlb3pRRZbHtGq6659APok3GDajjOaKW9hL8r59APok3GDajjOa0vIb)ig8iH7rnQvaOSyTksBIVDY4XL66c3JA66PmcQSvWE37TP57T31PrYwcUFwxNdcNaH01Z71sDuUb7assqbiH7pk5JA(rPaIPbchwLOAfaklw7JGg6hTcaHDb4eqjCpyspcAOFKW9OgvkJGkBfSRIXSSbKd)rn11fUh101tzeuzRG9U3BtZ6T31PrYwcUFwxNdcNaH01Z71sH3JjHyGGnzlHXXaXaibMr1o9rjFuZpIxLfUAnkWEitTmPvlcOa0vIb)OtFKW9OgfypKPwM0QfbuK2eF7KXJl9OtFexWUXJl9iw9O8ETu49ysigiyt2syCmqmasGzubORed(rqd9JG6JCXsJRa7Hm1YKwTiGIgjBj4h10Js(iMciKSLuECjJxgEDZBSh18OtFexWUXJl9iw9O8ETu49ysigiyt2syCmqmasGzubORedURlCpQPRNYiOYwb7DV3gdV3ExNgjBj4(zDDoiCcesxpVxl1r5gSdijbfGeU)OKpYfaeYvhKy9dvk3Fedy)OZPPhL8rUyPXvysaXaX41MFOOrYwcURlCpQPRNYiOYwb7DV3gRtV9Uons2sW9Z66Cq4eiKUEEVwQugbf3k4Rcqc3FuYhXfSB84spIbpkVxlvkJGIBf8vbORedURlCpQPRNYiOYwb7DV3wJR3ExNgjBj4(zD9nMmToclz4c2JbsVTe76Cq4eiKUouF0kae2fGtaLW9Gj9OKpcQpIPacjBj1kaKjBfSBsRYgdKhL8rn)OMFuZps4EuJAfaklwRI0M4Bpgipk5JA(rc3JAuRaqzXAvK2eF7Kbqxjg8JyWJ0KsZEe0q)iO(iWEOvbGqQvaiSxGRIgjBj4h10JGg6hjCpQrLYiOYwb7ksBIV9yG8OKpQ5hjCpQrLYiOYwb7ksBIVDYaORed(rm4rAsPzpcAOFeuFeyp0Qaqi1kae2lWvrJKTe8JA6rn9OKpkVxl1bjEmqm7ufGeU)OMEe0q)OMFKlwACfMeqmqmET5hkAKSLGFuYh5cac5QdsS(HkL7pIbSF0500Js(OMFuEVwQds8yGy2PkajC)rjFeuFKW9OgfMxa(HI0M4BpgipcAOFeuFuEVwQJYnyhqsckajC)rjFeuFuEVwQds8yGy2PkajC)rjFKW9OgfMxa(HI0M4Bpgipk5JG6Jok3GDajjyWPK1InXyw2aYH)OMEutpQPU(gtMATmq4W92sSRlCpQPRVcazYwb7DV32jV3ExNgjBj4(zDDoiCcesxpfqmnq4WQevyEb4hpk5JY71sDqIhdeZovbiH7pk5JCXsJRWKaIbIXRn)qrJKTe8Js(ixaqixDqI1puPC)rmG9JoNMEuYhjCpysgAOBq4hXGhXuaHKTK6OCd2bKKGzzLlHDqKa11fUh101tzeuzRG9U3Blrn1BVRtJKTeC)SUoheobcPRd1hXuaHKTKk9OOj02KwLngipk5JA(rq9rUyPXvlqDn(bze8bHv0izlb)iOH(rc3dMKHg6ge(rS6rj(OMEuYh18JeUhmjdC5QaYeo9ig8Og8iOH(rc3dMKHg6ge(rSI9JykGqYwsDiaydxWUzzLlHDqKa9iOH(rc3dMKHg6ge(rSI9JykGqYwsDuUb7assWSSYLWoisGEutDDH7rnD90JIMqBZYkxc39EBjMyV9Uons2sW9Z66c3JA66CXAnc3JAm2a7DDBGDZixQRlCpysgxS044U3BlXg0BVRtJKTeC)SUoheobcPRlCpysgAOBq4hXQhLyxx4EutxhgiqQbBYas8JU3BlXZ1BVRtJKTeC)SUoheobcPR7cac5QdsS(HkL7pIbSF0500Js(ixS04kmjGyGy8AZpu0izlb31fUh101X8cWp6EVTe1892760izlb3pRRZbHtGq66c3dMKHg6ge(rSI9JykGqYwsjaUmKH0o1w4OMhL8rxzevk3FeRy)iMciKSLucGldziTtTfoQXCLr66c3JA66cGldziTtTfoQP792suZ6T31PrYwcUFwxNdcNaH01fUhmjdn0ni8Jyf7hXuaHKTK6qaWgUGDZYkxc7GibQRlCpQPRVSYLWoisG6EVTez49276c3JA66RaqzXA760izlb3pR7DVRdQut6HGPE792sS3ExNgjBj4(zDDoiCcesxx4EWKm0q3GWpIvSFetbes2sQJYnyhqscMLvUe2brc0Js(OMFuEVwQJYnyhqsckajC)rqd9JY71sTcaH9cCvas4(JAQRlCpQPRVSYLWoisG6EVTg0BVRtJKTeC)SUoheobcPRN3RLcVhtcXabBYwcJJbIbqcmJQD6Js(O8ETu49ysigiyt2syCmqmasGzubORed(rS6rCb7gpUuxx4EutxpLrqLTc27EVTZ1BVRtJKTeC)SUoheobcPRN3RLAfac7f4QaKW9UUW9OMUEkJGkBfS39EBA(E7DDAKSLG7N115GWjqiD98ETuhLBWoGKeuas4Exx4EutxpLrqLTc27EVnnR3ExNgjBj4(zD9nMmToclz4c2JbsVTe76Cq4eiKUouFetbes2sQvait2ky3KwLngipk5JY71sH3JjHyGGnzlHXXaXaibMrfC1AEuYhjCpysgAOBq4hXGhXuaHKTK6qaWgUGDZYkxc7Gib6rjFeuF0kae2fGtaLW9Gj9OKpQ5hb1hL3RL6GepgiMDQcqc3FuYhb1hL3RL6OCd2bKKGcqc3FuYhb1hLciMMATmq4WQvait2ky)rjFuZps4EuJAfaYKTc2v8dbaHWpIvSFudEe0q)OMFKlwACLyjTXoqWnebBwBaJkAKSLGFuYhXRYcxTgfmqGud2KbK4hkajWm(OMEe0q)OMFKlwACfMeqmqmET5hkAKSLGFuYh5cac5QdsS(HkL7pIbSF0500JA6rn9OM66BmzQ1YaHd3BlXUUW9OMU(kaKjBfS39EBm8E7DDAKSLG7N113yY06iSKHlypgi92sSRZbHtGq66q9rmfqizlPwbGmzRGDtAv2yG8OKpcQpAfac7cWjGs4EWKEuYh18JA(rn)iH7rnQvaOSyTksBIV9yG8OKpQ5hjCpQrTcaLfRvrAt8TtgaDLyWpIbpstkn7rqd9JG6Ja7HwfacPwbGWEbUkAKSLGFutpcAOFKW9OgvkJGkBfSRiTj(2JbYJs(OMFKW9OgvkJGkBfSRiTj(2jdGUsm4hXGhPjLM9iOH(rq9rG9qRcaHuRaqyVaxfns2sWpQPh10Js(O8ETuhK4XaXStvas4(JA6rqd9JA(rUyPXvysaXaX41MFOOrYwc(rjFKlaiKRoiX6hQuU)igW(rNttpk5JA(r59APoiXJbIzNQaKW9hL8rq9rc3JAuyEb4hksBIV9yG8iOH(rq9r59APok3GDajjOaKW9hL8rq9r59APoiXJbIzNQaKW9hL8rc3JAuyEb4hksBIV9yG8OKpcQp6OCd2bKKGbNswl2eJzzdih(JA6rn9OM66BmzQ1YaHd3BlXUUW9OMU(kaKjBfS39EBSo92760izlb3pRRlCpQPRZfR1iCpQXydS31Tb2nJCPUUW9GjzCXsJJ7EVTgxV9Uons2sW9Z66Cq4eiKUEEVwQugbf3k4Rcqc3FuYhXfSB84spIbpkVxlvkJGIBf8vbORed(rjFexWUXJl9ig8O8ETuG9qMAzsRweqbORedURlCpQPRNYiOYwb7DV32jV3ExNgjBj4(zDDoiCcesxpfqmnq4WQevyEb4hpk5JY71sDqIhdeZovbiH7pk5JCXsJRWKaIbIXRn)qrJKTe8Js(ixaqixDqI1puPC)rmG9JoNMEuYhjCpysgAOBq4hXGhXuaHKTK6OCd2bKKGzzLlHDqKa11fUh101tzeuzRG9U3Blrn1BVRtJKTeC)SUoheobcPRd1hXuaHKTKk9OOj02KwLngipk5JY71sDqIhdeZovbiH7pk5JG6JY71sDuUb7assqbiH7pk5JA(rc3dMKbUCvazcNEedEudEe0q)iH7btYqdDdc)iwX(rmfqizlPoeaSHly3SSYLWoisGEe0q)iH7btYqdDdc)iwX(rmfqizlPok3GDajjyww5syhejqpQPUUW9OMUE6rrtOTzzLlH7EVTetS3ExNgjBj4(zDDoiCcesx3faeYvhKy9dvk3Fedy)OZPPhL8rUyPXvysaXaX41MFOOrYwcURlCpQPRJ5fGF09EBj2GE7DDAKSLG7N115GWjqiDDH7btYqdDdc)iw9Og01fUh101HbcKAWMmGe)O792s8C92760izlb3pRRZbHtGq66c3dMKHg6ge(rSI9JykGqYwsjaUmKH0o1w4OMhL8rxzevk3FeRy)iMciKSLucGldziTtTfoQXCLr66c3JA66cGldziTtTfoQP792suZ3BVRtJKTeC)SUoheobcPRlCpysgAOBq4hXk2pIPacjBj1HaGnCb7MLvUe2brcuxx4EutxFzLlHDqKa19EBjQz9276c3JA66RaqzXA760izlb3pR7DV7DDMeah10BRbAQbAkXeBW566TeWedeCxN1)8CY0gRBBNxS2JEu7h0JIBAb8hTkWJ0cuPM0dbtA9iaDs7aqWpcxx6rY2RR4e8J4hYaHWQNfgkg6rAgR9Otudtc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwpQ5gODtQNfgkg6rmCw7rNOgMeWj4hPLlwACvJ06rE9iTCXsJRAKIgjBjyTEuZjQDtQNfgkg6rmCw7rNOgMeWj4hPfyp0QaqivJ06rE9iTa7HwfacPAKIgjBjyTEuZnq7Muplmum0Jo5S2JornmjGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMtu7Muplmum0Jsmrw7rNOgMeWj4hPLlwACvJ06rE9iTCXsJRAKIgjBjyTEK4pQXR5WqpQ5e1Uj1ZYZcR)55KPnw32oVyTh9O2pOhf30c4pAvGhPfmTKT116ra6K2bGGFeUU0JKTxxXj4hXpKbcHvplmum0JsK1E0jQHjbCc(rAb2dTkaes1iTEKxpslWEOvbGqQgPOrYwcwRhj(JA8Aom0JAorTBs9SWqXqpQbS2JornmjGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMBG2nPEwyOyOhPzS2JornmjGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMtu7Muplmum0Jy4S2JornmjGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMtu7Muplmum0JyDyThDIAysaNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rnNO2nPEwyOyOh1anJ1E0jQHjbCc(rAb2dTkaes1iTEKxpslWEOvbGqQgPOrYwcwRh1CIA3K6zHHIHEudy4S2JornmjGtWpslWEOvbGqQgP1J86rAb2dTkaes1ifns2sWA9OMtu7Muplmum0JAaRdR9Otudtc4e8J0cShAvaiKQrA9iVEKwG9qRcaHunsrJKTeSwpQ5e1Uj1Zcdfd9OgCYzThDIAysaNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rnNO2nPEwyOyOhDonXAp6e1WKaob)iTa7HwfacPAKwpYRhPfyp0QaqivJu0izlbR1Je)rnEnhg6rnNO2nPEwyOyOhDUZXAp6e1WKaob)iTa7HwfacPAKwpYRhPfyp0QaqivJu0izlbR1Je)rnEnhg6rnNO2nPEwEwy9ppNmTX6225fR9Oh1(b9O4Mwa)rRc8iTsbeVUzX16ra6K2bGGFeUU0JKTxxXj4hXpKbcHvplmum0JAaR9Otudtc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwpQ5e1Uj1Zcdfd9OgWAp6e1WKaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1Je)rnEnhg6rnNO2nPEwyOyOhDow7rNOgMeWj4hPLlwACvJ06rE9iTCXsJRAKIgjBjyTEuZjQDtQNfgkg6rNJ1E0jQHjbCc(rA5ILgx1iTEKxpslxS04QgPOrYwcwRhj(JA8Aom0JAorTBs9SWqXqpsZZAp6e1WKaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1JAorTBs9SWqXqpsZZAp6e1WKaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1Je)rnEnhg6rnNO2nPEwyOyOhPzS2JornmjGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMtu7Muplmum0J0mw7rNOgMeWj4hPLlwACvJ06rE9iTCXsJRAKIgjBjyTEK4pQXR5WqpQ5e1Uj1Zcdfd9OephR9Otudtc4e8J0YflnUQrA9iVEKwUyPXvnsrJKTeSwpQ5e1Uj1ZYZcR)55KPnw32oVyTh9O2pOhf30c4pAvGhPfVU5n2JAm8QSWvRbR1Ja0jTdab)iCDPhjBVUItWpIFidecREwyOyOh14yThDIAysaNGFKwG9qRcaHunsRh51J0cShAvaiKQrkAKSLG16rnNO2nPEwEwy9ppNmTX6225fR9Oh1(b9O4Mwa)rRc8iTeUhmjJlwACSwpcqN0oae8JW1LEKS96kob)i(HmqiS6zHHIHEudyThDIAysaNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rn3aTBs9SWqXqp6CS2JornmjGtWpslxS04QgP1J86rA5ILgx1ifns2sWA9OMtu7MuplplS(NNtM2yDB78I1E0JA)GEuCtlG)OvbEKwyxgybaBaLlEuJwpcqN0oae8JW1LEKS96kob)i(HmqiS6zHHIHEKMXAp6e1WKaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1JAorTBs9SWqXqpIHZAp6e1WKaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1Je)rnEnhg6rnNO2nPEwyOyOh14yThDIAysaNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rnNO2nPEwyOyOh14yThDIAysaNGFKwG9qRcaHunsRh51J0cShAvaiKQrkAKSLG16rn3aTBs9SWqXqp6KZAp6e1WKaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1JAorTBs9SWqXqpkrnXAp6e1WKaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1JAorTBs9SWqXqpkXZXAp6e1WKaob)iTCXsJRAKwpYRhPLlwACvJu0izlbR1Je)rnEnhg6rnNO2nPEwEwy9ppNmTX6225fR9Oh1(b9O4Mwa)rRc8iT41nVXEuJj9qWKwpcqN0oae8JW1LEKS96kob)i(HmqiS6zHHIHEuIjYAp6e1WKaob)iT41aVdx1iTEKxpslEnW7WvnsrJKTeSwpQ5e1Uj1Zcdfd9OeBaR9Otudtc4e8J0Ixd8oCvJ06rE9iT41aVdx1ifns2sWA9OMtu7Muplmum0Js8CS2JornmjGtWpspUN4ryghx0(rSE9iVEedTLhbhmdCuZJQuciEbEuZqPPh1Cd0Uj1Zcdfd9OephR9Otudtc4e8J0Ixd8oCvJ06rE9iT41aVdx1ifns2sWA9OMtu7Muplmum0JsuZZAp6e1WKaob)iTa7HwfacPAKwpYRhPfyp0QaqivJu0izlbR1JAorTBs9SWqXqpkrnJ1E0jQHjbCc(rAb2dTkaes1iTEKxpslWEOvbGqQgPOrYwcwRh1CIA3K6zHHIHEuImCw7rNOgMeWj4hPfyp0QaqivJ06rE9iTa7HwfacPAKIgjBjyTEuZjQDtQNfgkg6rj24yThDIAysaNGFKwG9qRcaHunsRh51J0cShAvaiKQrkAKSLG16rnNO2nPEwyOyOh1awhw7rNOgMeWj4hPLlwACvJ06rE9iTCXsJRAKIgjBjyTEuZnq7Muplmum0JAqJJ1E0jQHjbCc(rAXRbEhUQrA9iVEKw8AG3HRAKIgjBjyTEuZnq7Muplmum0JoxdyThDIAysaNGFKwUyPXvnsRh51J0YflnUQrkAKSLG16rI)OgVMdd9OMtu7MuplplSU30c4e8JyDEKW9OMhzdSJvplD9uqTcl11BShXWca9Otwbc9S0yp6W9umRbfOaj8JDwXRluWXDBfpQHdKLdfCC5q5zPXEuBft6MjWJAW504rnqtnqtplpln2JoXHmqimR9S0yp68FudfME0kGC4gaDLyWpci(bbEKFiZJCbaHCLhxY4LboOhTkWJSc2pFmXRb(rsoSHZ4J2ybcHvpln2Jo)h1qLclo9iBbj4pcqS2JyOnpGF05najxS6zPXE05)igQkmnpIly)ra6K2bGU044hTkWJorDZBSh18OMdfP04rW1OL)OJYc)OWF0QapsE0cq4JhDYsovGhXfS3K6zPXE05)Og)izl9iSdcU)i(bXtigipQMhjpArTE0QajGFumpYpOhDE0CzOh51Jae8MtpQvbsWwcS6z5zPXEuJxBIVDc(rzAva6r86Mf)rzcsmy1JopCoL64hn1C(hc4U22hjCpQb)OASmQEweUh1GvPaIx3S4NYgkcGldzIXjRL4(ZsJ9O2pc8JykGqYw6r4uIhRGWpYpOhn7BMapQwpYfaeYXps8h16i4hpQHU8hP7ass4rmmRCjSdIei8JQTJdy6r16rNOU5n2JAEe(O2w4hLPhTXeS6zr4EudwLciEDZIFkBOWuaHKTKgJCj2hLBWoGKemlRCjSdIeinQu2yY1iwSzkGqYwsDuUb7assWSSYLWoisGyRjnyk2nXUbnSlwAC1YkxYKko)40Z1Wq1flnUAzLlzsfNF8S0ypQ9Ja)iMciKSLEeoL4Xki8J8d6rZ(MjWJQ1JCbaHC8Je)rToc(XJAOfa8JoHG9hXWSYLWoisGWpQ2ooGPhvRhDI6M3ypQ5r4JABHFuME0gtWpsWpAfwlbuplc3JAWQuaXRBw8tzdfMciKSL0yKlX(qaWgUGDZYkxc7GibsJkLnMCnIfBMciKSLuhca2WfSBww5syhejqS1Kgmf7My3Gg2flnUAzLlzsfNFC65AyO6ILgxTSYLmPIZpEwASh1(rGFetbes2spcNs8yfe(r(b9OzFZe4r16rUaGqo(rI)Owhb)4rn0L)iDhqscpIHzLlHDqKaHFKaOhTXe8JG3GyG8Otu38g7rnQNfH7rnyvkG41nl(PSHctbes2sAmYLyZRBEJ9OgZYkxc7GibsJkLnMCnIfBMciKSLu86M3ypQXSSYLWoisGyRjnyk2nX(CnSlwAC1YkxYKko)4ugEddvxS04QLvUKjvC(XZsJ9O2pc8JykGqYw6r4uIhRGWpYpOhn7BMapQwpYfaeYXps8h16i4hp68a4YqpQXRDQTWrnpQ2ooGPhvRhDI6M3ypQ5r4JABHFuME0gtWQNfH7rnyvkG41nl(PSHctbes2sAmYLylaUmKH0o1w4OgnQu2yY1iwSzkGqYwsjaUmKH0o1w4Og2AsdMIDtSp5N8g2flnUAzLlzsfNFCAdAyO6ILgxTSYLmPIZpEwASh1(rGFetbes2spcNs8yfe(r(b9OucWPXfi0JQ1JUYipkt2Q1JADe8JhDEaCzOh141o1w4OMh1kS2hnL)Om9OnMGvplc3JAWQuaXRBw8tzdfMciKSL0yKlXwaCzidPDQTWrnMRmIgW0s2wNTMxtAuPSbeM8NLg7rTFe4hXuaHKT0Jc8J2yc(rE9iCkXJfJpYpOhj3Ap(JQ1J84spkMhHjEnW4h5hI)O7g7pkvW4hjlNap6e1nVXEuZJiTtdaHFuMwfGEedZkxc7Gibc)OwH1(Om9OnMGF0uGRyTmQEweUh1GvPaIx3S4NYgkmfqizlPXixInmzfgnlRCjSdIeinGPLSToBnPrLYgqyYFwAShX6h(XJy9edSngiA8Otu38g7rnAHFeVklC1AEuRWAFuMEeGG3Cc(rzgFK8iGmW19rYT2JRXJYB)r(b9OzFZe4r16rCq44hHDb44hXKam(OJaYXJKLtGhjCpykEmqE0jQBEJ9OMhjd8JW2Qf(rWvR5rE1saW4h5h0JOb(r16rNOU5n2JA0c)iEvw4Q1OEeR)bnp6kjedKhbt8ah1GFumpYpOhDE0CzinE0jQBEJ9OgTWpcqxjMyG8iEvw4Q18Oa)iabV5e8JYm(i)iWpAbeUh18iVEKW51E8hTkWJy9edSngiQNfH7rnyvkG41nl(PSHctbes2sAmYLyNqmW2yGyae8M7rnAatlzBD2AsP51Oszdim5pln2JA)GEe8giEuZJQ1JKhPVNhX6jgiAHF0zwcJJbYJorDZBSh1OEweUh1GvPaIx3S4NYgkmfqizlPXixInoHSbEdepQrJkLnMCnyk2nXwZEweUh1GvPaIx3S4NYgkmfqizlPXixInVU5n2JAm1y2ysJkLnMCnyk2nXMoPDKMsWQRWLmGm4dICZDJdo0qtN0ostjy1vMyryVm1YCf4HWyOHMoPDKMsWkiwboeVaytwGHqqdnDs7inLGvqScCiEbWMlblwBud0qtN0ostjyvazcpQXCfie2S2ycAOPtAhPPeSYBiYqytwajGtJHWqdnDs7inLGvsdzdi)OWgCmqiytQDFfie0qtN0ostjyLm8Gg3KWuUPwMwbgUUqdnDs7inLGv4JINqoCcGnlzGan00jTJ0ucwn0giwdMXrsXKHMdz4eaAOPtAhPPeSklwAfaYKbYWpEweUh1GvPaIx3S4NYgkmfqizlPXixI9Qg3ax7SLm1y2ysJkLnMCnyk2nXMoPDKMsWkPHGpeGGnRACtTmPvlcKKPacjBjfVU5n2JAm1y2y6zr4EudwLciEDZIFkBOWuaHKTKgJCj21y2yYW3ETwAuPSXKRbtXUj2nqtnmtbes2skEDZBSh1yQXSX0PAwdtN0ostjy1v4sgqg8brU5UXb)zPXEu7hb(rmfqizl9iyYjWngc)Owh08OZtdbFiarl8Jyy14pQwpsZTArGhf4hTXe8JY0Qa0J8d6rPBR9rX6r5LOw14MAzsRweWKciEDZIB4hYmK9rb(rt5pcNs8yfeS6zr4EudwLciEDZIFkBOWuaHKTKgJCj2RACtTmPvlcysbeVUzXn8dzgYQrLYgtUgmf7MyNyJtJyXMPacjBj1Qg3ax7SLm1y2ykjuDXsJRwbGWUaCcKKPacjBj1Qg3ultA1IaMuaXRBwCd)qMHSS10ZsJ9Og6Q1JS1a5rzAva6rNOU5n2JAEe(O2w4h14VPmciX(inha8idNEuME0gtWSE7zr4EudwLciEDZIFkBOWuaHKTKgJCj20nLrajwtbGhz4KbMScJAatlzBD2j240Oszdim5pln2JA)GE0SVzc8OA9ixaqih)i9Jy5Xa5rAUvlc8i8rTTWpktpAJj4hvZJG3GyG8Otu38g7rnQNfH7rnyvkG41nl(PSHctbes2sAmYLyZRBEJ9Ogd(iwEmqmPvlcObmTKT1z3anQu2act(ZIW9OgSkfq86Mf)u2qzJjt40vJrUeBPHGpeGGnRACtTmPvlc8SiCpQbRsbeVUzXpLnuUbauatCfi0ZIW9OgSkfq86Mf)u2qjLrqLTc21iwSHAkGyQszeuzRG9NLNLg7rnETj(2j4hrmjaJpYJl9i)GEKW9c8Oa)iHPewjBj1ZIW9OgmBEThNa4uYA1iwSHkyp0QaqifCG5rQngbWOHx3RmWplc3JAWNYgkmfqizlPXixIThxY4LHx38g7rnAuPSXKRbtXUj2UyPXvRaqyxaobA4vaiSlaNakaDLyWN2mVklC1Au86M3ypQr5Gnza0vIb3WnN45ZuaHKTKkHyGTXaXai4n3JAAyxS04QeIb2gdKMAQHHkVklC1Au86M3ypQrbibMXgoVxlfVU5n2JAuWvR5zPXE0jRKa9i8gqp6e1nVXEuZJc8JGjRWib)Oy9OHiyc(rzbtWpQMh5h0JOBkJasSMcapYWjdmzfgFetbes2splc3JAWNYgkmfqizlPXixIThxY4LHx38g7rnAuPSVI2AWuSBIntbes2sk6MYiGeRPaWJmCYatwHXZVzEvw4Q1OOBkJasSMcapYWjf8giEuZ5ZRYcxTgfDtzeqI1ua4rgoPa0vIb3uddvEvw4Q1OOBkJasSMcapYWjfGeyg1iwSPtAhPPeSIUPmciXAka8idNEweUh1GpLnuykGqYwsJrUeBpUKXldVU5n2JA0OszFfT1GPy3eBEvw4Q1OGyf4q8cGnzbgcPa0vIbRrSytN0ostjyfeRahIxaSjlWqONfH7rn4tzdfMciKSL0yKlX2Jlz8YWRBEJ9OgnQu2xrBnyk2nXoVxlfypKPwM0Qfbua6kXG1iwSDXsJRa7Hm1YKwTiqY8ETu86M3ypQrbxTMNfH7rn4tzdfMciKSL0yKlX2Jlz8YWRBEJ9OgnQu2xrBnyk2nXMxLfUAnkWEitTmPvlcOa0vIbFAEVwkWEitTmPvlcOG3aXJA0iwSDXsJRa7Hm1YKwTiqY8ETu86M3ypQrbxTMK8QSWvRrb2dzQLjTArafGUsm4t1mgWuaHKTKYJlz8YWRBEJ9OMNfH7rn4tzdf8rS8yGysRweqJyXoVxlfVU5n2JAuWvRjjtbes2skpUKXldVU5n2JAy1ABTgabV5EutYM5vzHRwJcShYultA1IakaDLyWSATTwdGG3CpQbAOHQlwACfypKPwM0QfbA6zr4Eud(u2qbiWHmUbNkGe0iwSBoVxlfVU5n2JAuWvRjzEVwkWEitTmPvlcOGRwtYMzkGqYws5XLmEz41nVXEuddiTj(2jJhxcAOzkGqYws5XLmEz41nVXEudR4vzHRwJciWHmUbNkGeuWBG4rnn1e0q3CEVwkWEitTmPvlcO2PjzkGqYws5XLmEz41nVXEudRoNMA6zr4Eud(u2qbMe)ixGH0iwSZ71sXRBEJ9OgfC1AsM3RLcShYultA1Iak4Q1KKPacjBjLhxY4LHx38g7rnmG0M4BNmECPNfH7rn4tzdLBaafWexbcPrSyN3RLIx38g7rnk4Q1KeMY71sbe4qg3GtfqcgMB7qajh2WzubxTMNfH7rn4tzdLnMmHtxnO1I4UzKlXgIvGdXla2KfyiKgXIntbes2skpUKXldVU5n2JAyfVklC1AoFn7zr4Eud(u2qzJjt40vJrUeB6MYiGeRPaWJmCsJyXMPacjBjLhxY4LHx38g7rnmGntbes2sk6MYiGeRPaWJmCYatwHXNfH7rn4tzdLnMmHtxng5sSX12Acit4eqJyXMPacjBjLhxY4LHx38g7rnSIntbes2sQAmBmz4BVwRNfH7rn4tzdLnMmHtxng5sSHyzm9WulJGXXnSIh1OrSyZuaHKTKYJlz8YWRBEJ9OgwXMPacjBjvnMnMm8TxR1ZIW9Og8PSHYgtMWPRgJCj2xHlzazWhe5M7ghCnIfBMciKSLuECjJxgEDZBSh1Wa2A2ZIW9Og8PSHYgtMWPRgJCj2WasGxbGmmjmMSAel2mfqizlP84sgVm86M3ypQHvSzkGqYwsvJzJjdF71A9SiCpQbFkBOSXKjC6QXixIT0qWhcqWMvnUPwM0Qfb0iwSzkGqYws5XLmEz41nVXEuddyRzNMOM1WmfqizlPw14g4ANTKPgZgtjzkGqYws5XLmEz41nVXEudR00ZIW9Og8PSHcKTaGdzm1Yinecu(HgXIDZmfqizlP84sgVm86M3ypQHbjQjOHEfqoCdGUsmygWuaHKTKYJlz8YWRBEJ9OMMEweUh1GpLnu41WPXbItWMLvU0ZIW9Og8PSHcGK0yGyww5s4NfH7rn4tzdLvX3yc2ineceozYKCFweUh1GpLnus3GyXymqmzRG9NfH7rn4tzdfqKMAjtmgCQWPNfH7rn4tzdf)Gm7jx7b2SkaNEwAShDEr(J8d6rWbMhP2yeaJgEDVYa)O8ETE0ovJhThlHXpIx38g7rnpkWpcx1OEweUh1GpLnu41ECcGtjRvJyXgShAvaiKcoW8i1gJay0WR7vg4K8QSWvRrL3RLboW8i1gJay0WR7vgyfGeygtM3RLcoW8i1gJay0WR7vgyJa4Yqk4Q1KKPacjBjLhxY4LHx38g7rnS6CAkjuZ71sbhyEKAJramA419kdSAN(SiCpQbFkBOiaUmKH0o1w4OgnIfBWEOvbGqk4aZJuBmcGrdVUxzGtYRYcxTgvEVwg4aZJuBmcGrdVUxzGvasGzmzEVwk4aZJuBmcGrdVUxzGncGldPGRwtsMciKSLuECjJxgEDZBSh1WQZPPKqnVxlfCG5rQngbWOHx3RmWQD6ZIW9Og8PSHYcuypxwxJyXgShAvaiKcoW8i1gJay0WR7vg4K8QSWvRrL3RLboW8i1gJay0WR7vgyfGeygtM3RLcoW8i1gJay0WR7vgyZcuyxbxTMKmfqizlP84sgVm86M3ypQHvNttjHAEVwk4aZJuBmcGrdVUxzGv70NfH7rn4tzdfUyTgH7rngBGDng5sS51nVXEuJj9qWKgXInuzkGqYwsbhyjBjdVU5n2JAsYuaHKTKYJlz8YWRBEJ9OggWwtplc3JAWNYgkmfqizlPXixI9kaKjBfSBsRYgdenyk2nXgQmfqizlPGdSKTKHx38g7rnjzkGqYws5XLmEz41nVXEuddeUh1OwbGmzRGD1ABTgaXpeaeY4XLoFH7rnk8rS8yGysRweqT2wRbqWBUh10WnZRYcxTgf(iwEmqmPvlcOa0vIbZaMciKSLuECjJxgEDZBSh10usMciKSLuECjJxgEDZBSh1WGva5Wna6kXGHgAxS04kWEitTmPvlcKmVxlfypKPwM0QfbuWvRjjVklC1AuG9qMAzsRweqbORedMbc3JAuRaqMSvWUATTwdG4hcacz84sNVW9Ogf(iwEmqmPvlcOwBR1ai4n3JAA4M5vzHRwJcFelpgiM0Qfbua6kXGzaVklC1AuG9qMAzsRweqbORedUPK8QSWvRrb2dzQLjTArafGUsmygScihUbqxjg8ZIW9Og8PSHctbes2sAmYLyNEu0eABsRYgdenyk2nXgQmfqizlPGdSKTKHx38g7rnjzkGqYws5XLmEz41nVXEuddeUh1OspkAcTnlRCjSATTwdG4hcacz84sNVW9Ogf(iwEmqmPvlcOwBR1ai4n3JAA4M5vzHRwJcFelpgiM0Qfbua6kXGzatbes2skpUKXldVU5n2JAAkjtbes2skpUKXldVU5n2JAyWkGC4gaDLyWqdnyp0QaqifEpMeIbc2KTeghdKNfH7rn4tzdfWEitTmPvlcOrSyN3RLcShYultA1Iak4Q1KeQ59APwbGWEbUkajCpzZmfqizlP84sgVm86M3ypQHvSZ71sb2dzQLjTAraf8giEutsMciKSLuECjJxgEDZBSh1WkH7rnQvait2kyxT2wRbq8dbaHmECjOHMPacjBjLhxY4LHx38g7rnSAfqoCdGUsmyOHMPacjBjfCGLSLm86M3ypQPPNfH7rn4tzdfUyTgH7rngBGDng5sSbvQj9qWKgXIDEVwkWEitTmPvlcO2PjBMPacjBjLhxY4LHx38g7rnSstn9SiCpQbFkBOWuaHKTKgJCj2PhfnH2M0QSXardMIDtSzkGqYws5XLmEz41nVXEuddeUh1OspkAcTnlRCjSATTwdG4hcacz84sjzkGqYws5XLmEz41nVXEuddwbKd3aORedgAOb7HwfacPW7XKqmqWMSLW4yG8S0ypI1)GMh1qlayUG9yG8igMvU0J0DqKaPXJyybGE0zwb74hHpQTf(rz6rBmb)iVEeeAiG40JAOl)r6oGKeWpsg4h51JiTDAGF0zwb7e4rNSc2jG6zr4Eud(u2qzfaYKTc21yJjtTwgiCy2jQXgtMwhHLmCb7XaHDIAel2qLPacjBj1kaKjBfSBsRYgdKKnZuaHKTKYJlz8YWRBEJ9OgwPjOHw4EWKm0q3GWSIntbes2sQdbaB4c2nlRCjSdIeOKqDfac7cWjGs4EWKsc18ETuhLBWoGKeuas4EYMZ71sDqIhdeZovbiH7jfUh1Oww5syhejqksBIVDYaORedMbAsPzqdn)qaqiSzbeUh1iwwXUbn10ZsJ9OZBBqmqEedlae2fGtanEedla0JoZkyh)ibqpAJj4hHJByfGLXh51JG3GyG8Otu38g7rnQhDErdbeRLrnEKFqm(ibqpAJj4h51JGqdbeNEudD5ps3bKKa(rToO5rCq44h1kS2hnL)Om9Owc2j4hjd8JAf(XJoZkyNap6KvWob04r(bX4JWh12c)Om9iCkGe4hvB)rE9OReJlX8i)GE0zwb7e4rNSc2jWJY71s9SiCpQbFkBOScazYwb7ASXKPwldeom7e1yJjtRJWsgUG9yGWornIf7vaiSlaNakH7btkj)qaqimRyNysOYuaHKTKAfaYKTc2nPvzJbsYMHQW9Og1kauwSwfPnX3EmqscvH7rnQugbv2kyxfJzzdihEY8ETuhK4XaXStvas4o0qlCpQrTcaLfRvrAt8ThdKKqnVxl1r5gSdijbfGeUdn0c3JAuPmcQSvWUkgZYgqo8K59APoiXJbIzNQaKW9KqnVxl1r5gSdijbfGeU30ZsJ9OZdZkGFexstJbYJyybGE0zwb7pIFiaie(rTocl9i(HmdzJbYJ0pILhdKhP5wTiWZIW9Og8PSHYkaKjBfSRXgtMwhHLmCb7XaHDIAel2c3JAu4Jy5XaXKwTiGI0M4BpgijxBR1ai(HaGqgpUedeUh1OWhXYJbIjTAraLh8emacEZ9OMK59APok3GDajjOGRwZZIW9Og8PSHcxSwJW9OgJnWUgJCj2yxgybaBaLlEuJgXIDZmfqizlP84sgVm86M3ypQHvAcAOzkGqYwsbhyjBjdVU5n2JAAkzEVwkWEitTmPvlcOGRwZZIW9Og8PSHcMxa(XZYZIW9OgSs4EWKmUyPXXSTbZyGyY1nRrSylCpysgAOBqywLyY8ETu86M3ypQrbxTMKnZuaHKTKYJlz8YWRBEJ9OgwXRYcxTgLnygdetUUzf8giEud0qZuaHKTKYJlz8YWRBEJ9OggWwtn9SiCpQbReUhmjJlwAC8PSHYLCQaAel2qLPacjBjfCGLSLm86M3ypQjjtbes2skpUKXldVU5n2JAyaBnbn0nZRYcxTg1LCQak4nq8OggWuaHKTKYJlz8YWRBEJ9OMKq1flnUcShYultA1Ianbn0UyPXvG9qMAzsRweizEVwkWEitTmPvlcO2PjzkGqYws5XLmEz41nVXEudReUh1OUKtfqXRYcxTgOHEfqoCdGUsmygWuaHKTKYJlz8YWRBEJ9OgOHMPacjBjfCGLSLm86M3ypQ5zr4EudwjCpysgxS044tzdfyGaPgSjdiXp0iwSDXsJRelPn2bcUHiyZAdymzZ59AP41nVXEuJcUAnjHAEVwQJYnyhqsckajCVPNLNfH7rnyfVU5n2JAm8QSWvRbZoT8OMNfH7rnyfVU5n2JAm8QSWvRbFkBOKTvbBwBaJplc3JAWkEDZBSh1y4vzHRwd(u2qjtambsigiplc3JAWkEDZBSh1y4vzHRwd(u2qzfakBRc(zr4EudwXRBEJ9OgdVklC1AWNYgkYWjSdeRHlw7ZIW9OgSIx38g7rngEvw4Q1GpLnu2yYeoDXplc3JAWkEDZBSh1y4vzHRwd(u2qzJjt40vJnMm1AzGWHzNOg0ArC3mYLydXkWH4faBYcmesJyXw4EuJ6sovavmMLnGC4qdnVklC1AuxYPcOa0vIbZQe10ZIW9OgSIx38g7rngEvw4Q1GpLnu84sMwcivJyXgShAvaiKYPBAbeRPLastM3RLI0(q2ypQrTtFwEweUh1Gv86M3ypQXKEiyITnGC4yZ59nmKlnUgXIDEVwkEDZBSh1OGRwZZsJ9Ogp2JR40JoQwpYwdKhDI6M3ypQ5rTcR9rwb7pYpKjb8J86r675rSEIbIw4hDMLW4yG8iVEem5e4gd9OJQ1JyybGE0zwb74hHpQTf(rz6rBmbREweUh1Gv86M3ypQXKEiy6u2qHPacjBjng5sSjTDAGjydVU5n2JAma6kXG1OszJjxdMIDtSZ71sXRBEJ9OgfGUsm4tZ71sXRBEJ9Ogf8giEutd3mVklC1Au86M3ypQrbORedMb59AP41nVXEuJcqxjgCtpln2JopWW4h5h0JG3aXJAEuTEKFqpsFppI1tmq0c)OZSeghdKhDI6M3ypQ5rE9i)GEenWpQwpYpOhX3aan(JorDZBSh18Oy9i)GEexW(JAvBl8J41n1so9i4nigipYpc8JorDZBSh1OEweUh1Gv86M3ypQXKEiy6u2qHPacjBjng5sSjTDAGjydVU5n2JAma6kXG1OszlWWAWuSBIntbes2skCczd8giEuJgXIDEVwk8EmjedeSjBjmogigajWmQ2Pqdntbes2sksBNgyc2WRBEJ9OgdGUsmywLOsZAyiCy1v0UHBoVxlfEpMeIbc2KTeghde1v02GDHNW5N3RLcVhtcXabBYwcJJbIc7cpHMEweUh1Gv86M3ypQXKEiy6u2qjlqm1Y4GGNawJyXoVxlfVU5n2JAuWvR5zr4EudwXRBEJ9Ogt6HGPtzdfBWmgiMCDZAel2c3dMKHg6geMvjMmVxlfVU5n2JAuWvR5zr4EudwXRBEJ9Ogt6HGPtzdLBaafaBQLXlWLgxJyXoVxlfVU5n2JAuWvRjzEVwkWEitTmPvlcOGRwZZIW9OgSIx38g7rnM0dbtNYgkBmzcNUAmYLyFWykb8dajWMwGa7TaskwJyXoVxlfVU5n2JAu70Kc3JAuRaqMSvWUIFiaieMTMskCpQrTcazYwb7kaXpeaeY4XLyfeoS6kA)SiCpQbR41nVXEuJj9qW0PSHs2wfSPwg)Gm0qxgFweUh1Gv86M3ypQXKEiy6u2q5s3cWOPwg7MhWgyajx8ZIW9OgSIx38g7rnM0dbtNYgkTkGfMjfJbq4AKHtpln2Jyyf4rSENg)GrGgpAJPhjpIHfa6rNzfS)i(HaGqpcEdIbYJozdaOa4hvRh1EbU04pIly)rE9iHzfWpIlPPXa5r8dbaHWpkwpI1Dweye7JoHG5cm9Oa)OP8hHjlXDcw9SiCpQbR41nVXEuJj9qW0PSHYkaKjBfSRXgtMwhHLmCb7XaHDIAel2c3JAu3aaka2ulJxGlnUI0M4BpgijxBR1ai(HaGqgpU05lCpQrDdaOaytTmEbU04ksBIVDYaORedMbA(Kq9OCd2bKKGbNswl2eJzzdihEsOM3RL6OCd2bKKGcqc3t2CEVwkEDZBSh1O2Pqdnu51aVdxfZIaJynCbZfyQPNLg7rS(HFuB)rSUZIaJyF0jemxGjnE059n2F0gtpIHfa6rNzfSJFuRdAEKFqm(Ow1OL)O7E4hpIdch)izGFuRdAEedlae2lW9rb(rWvRr9SiCpQbR41nVXEuJj9qW0PSHYkaKjBfSRXgtMATmq4WStuJnMmToclz4c2Jbc7e1iwSHQ0qiq4KkBfStaZvWobu0izlbNSzH7btYqdDdcZa2c3dMKbUCvazcNGgAOYRYcxTgv6rrtOTzzLlHvasGzSPKqLxd8oCvmlcmI1WfmxGPK8dbaHWSIDIjZ71sXRBEJ9Og1onjuZ71sTcaH9cCvas4EsOM3RL6OCd2bKKGcqc3tEuUb7assWGtjRfBIXSSbKd)08ETuhK4XaXStvas4odAWZsJ9iw)WpEeR7SiWi2hDcbZfysJhXWca9OZSc2F0gtpcFuBl8JY0Jey4WJAelJpIxd2bsme8JW1J8dXFu4pkWpAk)rz6rBmb)O9yjm(rSUZIaJyF0jemxGPhf4hj5A7pYRhrANga6rf4r(bbOhja6r3cqpYpK5r0uBihpIHfa6rNzfSJFKxpI02Pb(rSUZIaJyF0jemxGPh51J8d6r0a)OA9Otu38g7rnQNfH7rnyfVU5n2JAmPhcMoLnuwbGmzRGDn2yYuRLbchMDIASXKP1ryjdxWEmqyNOgXInuLgcbcNuzRGDcyUc2jGIgjBj4KnlCpysgAOBqygWw4EWKmWLRcit4e0qdvEvw4Q1OspkAcTnlRCjScqcmJnLKxd8oCvmlcmI1WfmxGPK8dbaHWSIDIjBUzH7rnQvait2kyxXpeaecBwaH7rnI90MzkGqYwsrA70atWgEDZBSh1ya0vIbF(59APIzrGrSgUG5cmPG3aXJAAI1lEvw4Q1OwbGmzRGDf8giEuZ5ZuaHKTKI02PbMGn86M3ypQXaORedM1RMZ71sfZIaJynCbZfysbVbIh1C(q4WQRODtnXk2AcAOzkGqYwsrA70atWgEDZBSh1ya0vIbZa259APIzrGrSgUG5cmPG3aXJAGg68ETuXSiWiwdxWCbMua6kXGzaeoS6kAdn08QSWvRrHpILhdetA1IakajWmMu4EWKm0q3GWSIntbes2skEDZBSh1yWhXYJbIjTArGK8IjnY4QjGC4MLqnLmVxlfVU5n2JAu70Knd18ETuRaqyVaxfGeUdn059APIzrGrSgUG5cmPa0vIbZanP0SMsc18ETuhLBWoGKeuas4EYJYnyhqscgCkzTytmMLnGC4NM3RL6GepgiMDQcqc3zqdEweUh1Gv86M3ypQXKEiy6u2qHx7XjaoLSwnIfBWEOvbGqk4aZJuBmcGrdVUxzGtM3RLcoW8i1gJay0WR7vgyfC1AsM3RLcoW8i1gJay0WR7vgyJa4Yqk4Q1KKxLfUAnQ8ETmWbMhP2yeaJgEDVYaRaKaZ4ZIW9OgSIx38g7rnM0dbtNYgkcGldziTtTfoQrJyXgShAvaiKcoW8i1gJay0WR7vg4K59APGdmpsTXiagn86ELbwbxTMK59APGdmpsTXiagn86ELb2iaUmKcUAnj5vzHRwJkVxldCG5rQngbWOHx3RmWkajWm(SiCpQbR41nVXEuJj9qW0PSHYcuypxwxJyXgShAvaiKcoW8i1gJay0WR7vg4K59APGdmpsTXiagn86ELbwbxTMK59APGdmpsTXiagn86ELb2Saf2vWvR5zr4EudwXRBEJ9Ogt6HGPtzdfUyTgH7rngBGDng5sSfUhmjJlwAC8ZIW9OgSIx38g7rnM0dbtNYgk86M3ypQrJnMm1AzGWHzNOgBmzADewYWfShde2jQrSyN3RLIx38g7rnk4Q1KSzWEOvbGqk4aZJuBmcGrdVUxzGzN3RLcoW8i1gJay0WR7vgy1oTPKnlCpQrDjNkGkgZYgqo8Kc3JAuxYPcOIXSSbKd3aORedMbS1KIHdn0c3JAuyEb4hksBIV9yGKu4EuJcZla)qrAt8TtgaDLyWmqtkgo0qlCpQrTcaLfRvrAt8ThdKKc3JAuRaqzXAvK2eF7Kbqxjgmd0KIHdn0c3JAuPmcQSvWUI0M4BpgijfUh1OszeuzRGDfPnX3oza0vIbZanPy4n9S0ypsZXpiWJ4vzHRwd(r(H4pcFuBl8JY0J2yc(rTc)4rNOU5n2JAEe(O2w4hvJLXhLPhTXe8JAf(XJK5rc33I9rNOU5n2JAEexW(JKb(rt5pQv4hpsEK(EEeRNyGOf(rNzjmogipkfuC1ZIW9OgSIx38g7rnM0dbtNYgkCXAnc3JAm2a7AmYLyZRBEJ9OgdVklC1AWAel259AP41nVXEuJYky3qANgaIbSfUh1O41nVXEuJYky3SXe8ZIW9OgSIx38g7rnM0dbtNYgklRCjSdIeinIf7MZ71sDuUb7assqbiH7qdDEVwQvaiSxGRcqc3BkPW9GjzOHUbHzfBMciKSLu86M3ypQXSSYLWoisGEweUh1Gv86M3ypQXKEiy6u2qjLrqLTc21iwSZ71sH3JjHyGGnzlHXXaXaibMr1onzEVwk8EmjedeSjBjmogigajWmQa0vIbZkUGDJhx6zr4EudwXRBEJ9Ogt6HGPtzdLugbv2kyxJyXoVxl1kae2lWvbiH7plc3JAWkEDZBSh1yspemDkBOKYiOYwb7Ael259APszeuCRGVkajCpzEVwQugbf3k4RcqxjgmR4c2nECPKnN3RLIx38g7rnkaDLyWSIly34XLGg68ETu86M3ypQrbxTMMEweUh1Gv86M3ypQXKEiy6u2qjLrqLTc21iwSZ71sDuUb7assqbiH7jZ71sXRBEJ9Og1o9zr4EudwXRBEJ9Ogt6HGPtzdLugbv2kyxJyXofqmnq4WQevyEb4hjZ71sDqIhdeZovbiH7pln2JAOWXa5r6hXYJbYJ0CRwe4rWBqmqE0jQBEJ9OMh51Jae2la9igwaOhDMvW(JKb(rAUhfnH2pIHzLl9i(HaGq4hXL5rz6rzAOvWdXQXJYB)rB8wSwgFunwgFunp68unE1ZIW9OgSIx38g7rnM0dbtNYgk4Jy5XaXKwTiGgXIDEVwkEDZBSh1O2PjHQW9Og1kaKjBfSR4hcacHtkCpysgAOBqywXMPacjBjfVU5n2JAm4Jy5XaXKwTiqsH7rnQ0JIMqBZYkxcRwBR1ai(HaGqgpUeRwBR1ai4n3JA0igNaGDQBIfBH7rnQvait2kyxXpeaecZw4EuJAfaYKTc2vxrBd)qaqi8ZIW9OgSIx38g7rnM0dbtNYgkPhfnH2MLvUewJyXoVxlfVU5n2JAu70Kn3SW9Og1kaKjBfSR4hcacHzqIjDXsJRszeuCRGVjfUhmjdn0nim7eBcAOHQlwACvkJGIBf8fAOfUhmjdn0nimRsSPK59APoiXJbIzNQaKW9tpk3GDajjyWPK1InXyw2aYHZGg8SiCpQbR41nVXEuJj9qW0PSHYkauwSwnIf78ETu86M3ypQrbxTMK8QSWvRrXRBEJ9OgfGUsmygWfSB84sjHkVg4D4QLvUKr4Ca5rnjBgMY71sDdaOaytTmEbU04k4Q1an0qLxd8oCvmlcmI1WfmxGPMEweUh1Gv86M3ypQXKEiy6u2qbZla)qJyXoVxlfVU5n2JAua6kXGzfxWUXJlLmVxlfVU5n2JAu7uOHoVxlfVU5n2JAuWvRjjVklC1Au86M3ypQrbORedMbCb7gpU0ZIW9OgSIx38g7rnM0dbtNYgk2Gzmqm56M1iwSZ71sXRBEJ9OgfGUsmygaHdRUI2jfUhmjdn0nimRs8zr4EudwXRBEJ9Ogt6HGPtzdfyGaPgSjdiXp0iwSZ71sXRBEJ9OgfGUsmygaHdRUI2jZ71sXRBEJ9Og1o9zr4EudwXRBEJ9Ogt6HGPtzdfmVa8dnIfBxaqixDqI1puPCNbSpNMs6ILgxHjbedeJxB(XZYZIW9OgScuPM0dbtSxw5syhejqAel2c3dMKHg6geMvSzkGqYwsDuUb7assWSSYLWoisGs2CEVwQJYnyhqsckajChAOZ71sTcaH9cCvas4Etplc3JAWkqLAspemDkBOKYiOYwb7Ael259APW7XKqmqWMSLW4yGyaKaZOANMmVxlfEpMeIbc2KTeghdedGeygva6kXGzfxWUXJl9SiCpQbRavQj9qW0PSHskJGkBfSRrSyN3RLAfac7f4QaKW9NfH7rnyfOsnPhcMoLnuszeuzRGDnIf78ETuhLBWoGKeuas4(ZsJ9Ogkm9OAOhXWca9OZSc2FejalJpkMhDYuAUpkwpIXA)i4A0YF0HWKEef(bbEudnjEmqEudv6JkWJAOl)r6oGKeEeJK)izGFef(bbyTh1S00JoeM0JUfGEKFiZJ8w1JelGeyg14rnNB6rhct6rNhlPn2bcUHiAHFedBdy8rasGz8rE9OnM04rf4rnZB6r6KaIbYJAV28Jhf4hjCpysQhDERgT8hbxpYpc8JADew6rhca(rCb7Xa5rmmRCjhejq4hvGh16GMhPVNhX6jgiAHF0zwcJJbYJc8JaKaZO6zr4EudwbQut6HGPtzdLvait2kyxJnMm1AzGWHzNOgBmzADewYWfShde2jQrSydvMciKSLuRaqMSvWUjTkBmqsM3RLcVhtcXabBYwcJJbIbqcmJk4Q1Ku4EWKm0q3GWmGPacjBj1HaGnCb7MLvUe2brcusOUcaHDb4eqjCpysjBgQ59APoiXJbIzNQaKW9KqnVxl1r5gSdijbfGeUNeQPaIPPwldeoSAfaYKTc2t2SW9Og1kaKjBfSR4hcacHzf7gan0n7ILgxjwsBSdeCdrWM1gWysEvw4Q1OGbcKAWMmGe)qbibMXMGg6MDXsJRWKaIbIXRn)iPlaiKRoiX6hQuUZa2Nttn1utpln2JAOW0JyybGE0zwb7pIc)GapcEdIbYJKhXWcaLfRfkAUmcQSvW(J4c2FuRdAEudnjEmqEudv6Jc8JeUhmPhvGhbVbXa5rK2eF70JAf(XJ0jbedKh1ET5hQNfH7rnyfOsnPhcMoLnuwbGmzRGDn2yYuRLbchMDIASXKP1ryjdxWEmqyNOgXInuzkGqYwsTcazYwb7M0QSXajjuxbGWUaCcOeUhmPKn3CZc3JAuRaqzXAvK2eF7XajzZc3JAuRaqzXAvK2eF7Kbqxjgmd0KsZGgAOc2dTkaesTcaH9cCBcAOfUh1OszeuzRGDfPnX3Emqs2SW9OgvkJGkBfSRiTj(2jdGUsmygOjLMbn0qfShAvaiKAfac7f42utjZ71sDqIhdeZovbiH7nbn0n7ILgxHjbedeJxB(rsxaqixDqI1puPCNbSpNMs2CEVwQds8yGy2PkajCpjufUh1OW8cWpuK2eF7XabAOHAEVwQJYnyhqsckajCpjuZ71sDqIhdeZovbiH7jfUh1OW8cWpuK2eF7Xajjupk3GDajjyWPK1InXyw2aYH3utn9SiCpQbRavQj9qW0PSHcxSwJW9OgJnWUgJCj2c3dMKXflno(zr4EudwbQut6HGPtzdLugbv2kyxJyXoVxlvkJGIBf8vbiH7j5c2nECjgK3RLkLrqXTc(Qa0vIbNKly34XLyqEVwkWEitTmPvlcOa0vIb)SiCpQbRavQj9qW0PSHskJGkBfSRrSyNciMgiCyvIkmVa8JK59APoiXJbIzNQaKW9KUyPXvysaXaX41MFK0faeYvhKy9dvk3za7ZPPKc3dMKHg6geMbmfqizlPok3GDajjyww5syhejqplc3JAWkqLAspemDkBOKEu0eABww5synIfBOYuaHKTKk9OOj02KwLngijZ71sDqIhdeZovbiH7jHAEVwQJYnyhqsckajCpzZc3dMKbUCvazcNyqdGgAH7btYqdDdcZk2mfqizlPoeaSHly3SSYLWoisGGgAH7btYqdDdcZk2mfqizlPok3GDajjyww5syhejqn9SiCpQbRavQj9qW0PSHcMxa(HgXITlaiKRoiX6hQuUZa2NttjDXsJRWKaIbIXRn)4zr4EudwbQut6HGPtzdfyGaPgSjdiXp0iwSfUhmjdn0nimRAWZIW9OgScuPM0dbtNYgkcGldziTtTfoQrJyXw4EWKm0q3GWSIntbes2skbWLHmK2P2ch1K8kJOs5oRyZuaHKTKsaCzidPDQTWrnMRmYZIW9OgScuPM0dbtNYgklRCjSdIeinIfBH7btYqdDdcZk2mfqizlPoeaSHly3SSYLWoisGEweUh1GvGk1KEiy6u2qzfaklw7ZYZIW9OgSc7YalaydOCXJAyVSYLWoisG0iwSfUhmjdn0nimRyZuaHKTK6OCd2bKKGzzLlHDqKaLS58ETuhLBWoGKeuas4o0qN3RLAfac7f4QaKW9MEweUh1GvyxgybaBaLlEuZPSHskJGkBfSRrSyN3RLAfac7f4QaKW9NfH7rnyf2LbwaWgq5Ih1CkBOKYiOYwb7Ael259APok3GDajjOaKW9K59APok3GDajjOa0vIbZaH7rnQvaOSyTksBIVDY4XLEweUh1GvyxgybaBaLlEuZPSHskJGkBfSRrSyN3RL6OCd2bKKGcqc3t2CkGyAGWHvjQwbGYI1cn0Raqyxaobuc3dMe0qlCpQrLYiOYwb7QymlBa5WB6zPXEu7agFKxpcc5psN1ZzpkfuC8JIbhW0Jozkn3hLEiyc)Oc8Otu38g7rnpk9qWe(rToO5rPfghzlPEweUh1GvyxgybaBaLlEuZPSHskJGkBfSRrSyN3RLcVhtcXabBYwcJJbIbqcmJQDAYM5vzHRwJcShYultA1IakaDLyWNkCpQrb2dzQLjTArafPnX3oz84sNYfSB84sSkVxlfEpMeIbc2KTeghdedGeygva6kXGHgAO6ILgxb2dzQLjTArGMsYuaHKTKYJlz8YWRBEJ9OMt5c2nECjwL3RLcVhtcXabBYwcJJbIbqcmJkaDLyWplc3JAWkSldSaGnGYfpQ5u2qjLrqLTc21iwSZ71sDuUb7assqbiH7jDbaHC1bjw)qLYDgW(CAkPlwACfMeqmqmET5hplc3JAWkSldSaGnGYfpQ5u2qjLrqLTc21iwSZ71sLYiO4wbFvas4EsUGDJhxIb59APszeuCRGVkaDLyWpln2JoVTbXa5r(b9iSldSaGFeOCXJA04r1yz8rBm9igwaOhDMvWo(rToO5r(bX4Jea9OP8hLPyG8O0QSe8Jwf4rNmLM7JkWJorDZBSh1OEudfMEedla0JoZky)ru4he4rWBqmqEK8igwaOSyTqrZLrqLTc2FexW(JADqZJAOjXJbYJAOsFuGFKW9Gj9Oc8i4nigipI0M4BNEuRWpEKojGyG8O2Rn)q9SiCpQbRWUmWca2akx8OMtzdLvait2kyxJnMm1AzGWHzNOgBmzADewYWfShde2jQrSyd1vaiSlaNakH7btkjuzkGqYwsTcazYwb7M0QSXajzZn3SW9Og1kauwSwfPnX3Emqs2SW9Og1kauwSwfPnX3oza0vIbZanP0mOHgQG9qRcaHuRaqyVa3MGgAH7rnQugbv2kyxrAt8ThdKKnlCpQrLYiOYwb7ksBIVDYaORedMbAsPzqdnub7HwfacPwbGWEbUn1uY8ETuhK4XaXStvas4EtqdDZUyPXvysaXaX41MFK0faeYvhKy9dvk3za7ZPPKnN3RL6GepgiMDQcqc3tcvH7rnkmVa8dfPnX3EmqGgAOM3RL6OCd2bKKGcqc3tc18ETuhK4XaXStvas4EsH7rnkmVa8dfPnX3Emqsc1JYnyhqscgCkzTytmMLnGC4n1utplc3JAWkSldSaGnGYfpQ5u2qjLrqLTc21iwStbetdeoSkrfMxa(rY8ETuhK4XaXStvas4EsxS04kmjGyGy8AZps6cac5QdsS(HkL7mG950usH7btYqdDdcZaMciKSLuhLBWoGKemlRCjSdIeONfH7rnyf2LbwaWgq5Ih1CkBOKEu0eABww5synIfBOYuaHKTKk9OOj02KwLngijBgQUyPXvlqDn(bze8bHHgAH7btYqdDdcZQeBkzZc3dMKbUCvazcNyqdGgAH7btYqdDdcZk2mfqizlPoeaSHly3SSYLWoisGGgAH7btYqdDdcZk2mfqizlPok3GDajjyww5syhejqn9SiCpQbRWUmWca2akx8OMtzdfUyTgH7rngBGDng5sSfUhmjJlwAC8ZIW9OgSc7YalaydOCXJAoLnuGbcKAWMmGe)qJyXw4EWKm0q3GWSkXNfH7rnyf2LbwaWgq5Ih1CkBOG5fGFOrSy7cac5QdsS(HkL7mG950usxS04kmjGyGy8AZpEwAShX6h(XJOP2qoEKlaiKJ14rH)Oa)i5rqKyEKxpIly)rmmRCjSdIeOhj4hTcRLapkgStc8JQ1JyybGYI1QEweUh1GvyxgybaBaLlEuZPSHIa4Yqgs7uBHJA0iwSfUhmjdn0nimRyZuaHKTKsaCzidPDQTWrnjVYiQuUZk2mfqizlPeaxgYqANAlCuJ5kJ8SiCpQbRWUmWca2akx8OMtzdLLvUe2brcKgXITW9GjzOHUbHzfBMciKSLuhca2WfSBww5syhejqplc3JAWkSldSaGnGYfpQ5u2qzfaklwBxhNs8EBm8Z19U37a]] )

end
