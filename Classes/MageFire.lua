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

    spec:RegisterStateTable( "searing_touch", setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "active" then return talent.searing_touch.enabled and target.health.pct < 30
            elseif k == "remains" then
                if not talent.searing_touch.enabled or target.health.pct < 30 then return 0 end
                return target.time_to_die
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


    local hot_streak_spells = {
        -- "dragons_breath",
        "fireball",
        -- "fire_blast",
        "phoenix_flames",
        "pyroblast",
        -- "scorch",        
    }
    spec:RegisterStateExpr( "hot_streak_spells_in_flight", function ()
        local count = 0

        for i, spell in ipairs( hot_streak_spells ) do
            if state:IsInFlight( spell ) then count = count + 1 end
        end

        return count
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


    spec:RegisterPack( "Fire", 20210307, [[defRMeqiuQ6rOeCjuskBcf5tQKmkOqNckYQujLEfuuZcf1TqPIDPWVqj1WujvhJO0YujYZujftJOQY1qjX2qjj9nusIXHceNdfuzDOGmpuIUNuQ9ruL)HcK0bvjQwiuvEiuWeHQqxKOQQnIsOpIss1iHQGojkvYkjkEPkrHzIc4MQefTtOQ6NOGYqjQklvLO0tjYuHQ0vrbvTvuQuFfQcmwOkAVQQ)QObl6WKwSkEmHjd0Lr2mGpdvgTk1PPSAuGuVMOYSr1TvLDR0VLmCP44Oa1YH8Cqtx46s12HsFxkz8Qeopk06rbsmFuk7NQ)Y(X7xcud6J)lD9lj71VMRZQmU0LyfgUlXkFPGXg6l1Oc5uC0xA1h9LyrdrFPgLrEPGF8(LGvhjOV0DenqgI1SgNf39ZqupwdTxNRHvRaPabRH2tW6V0PB8GDT)Zxcud6J)lD9lj71VMRZQmU0Lyfgozzv)sApUl0xsYEy4lDBGG0(pFjqck(sSOHipVmvCKlZDenqgI1SgNf39ZqupwdTxNRHvRaPabRH2tWAxMltfjU9KvHzpV01VKSUmUmy4wxCeKHCzyhpz4HKNagU7yIONAl0tKg3eYZ4wxpdfHJIrypAg1e0ipbkKNCfgSdKe1c6PEmUfm6zhQ4i4WLHD8KbQcsRNcfgEIigC3q0J2a6jqH8ed170HHvRNy0g0GzpbR9QWZ7Id6PfEcuipvpbqe82ZltkOc5PqHbMgUmSJNY)vpCYtyGmr4P4MeYzlopR1t1taQLNafsoON26zCtEE5Yhd4zuEIiWUG8SvHKJxk4WLHD88Ybzq3HHNQNYhJO6Wvy4jTbIrpJBn8eSiONBfE(kqI7zlIZ90w2bN(ipXi0EEgemiqp1WZT8eA4wdWe6gEIhLpjpTxJkcmnCzyhpXqTyju4PY5EE6aad8CGiveEsBGmc6zuEE6aad8C0By2tD9u5VcgEAl0WTgGj0n8epkFsEItT1tB9eAp44lXnya)49ljQ3PddR2zypBX9X7h)Y(X7xIw9WjWp((svZxcsXxsfHv7xcRIm9WPVewL3PVKOkoy1AhI6D6WWQDGONAl0ZR1tm6PSEYoEIrpXQitpCAiNTGCBXnreyxewTEIzpV(4sEETEcyicgkki0qfHHL8etEETEgkN2yiNTGCBXnOvpCc0tm9LajOaznHv7xcpK4neYtSkY0dN8mU1WtrTHAl0Z4M8ufrx5EsWWEAqGEg2J8mU1WZ4M8CPlcpXq9oDyy16zlJZ98qEIifKXXxcRIMR(OVKOENomSANisbzCg2J(Xh)x6J3VeT6HtGF89LQMVeKIVKkcR2Vewfz6HtFjSkVtFjSkY0dNgI6D6WWQDIifKXzyp6lHvrZvF0xsuVthgwTZWE0p(4)A(49lrRE4e4hFFPQ5l90l(sQiSA)syvKPho9LWQO5Qp6ljQ3PddR2zyp6ljqwqit)sHYPngagIGHIccnOvpCc0tM8K9EIvrME40aWqemuuqOPOENomSA)sGeuGSMWQ9lHhjUYONyOENomSA9eOqEQabH8KfnebdffeYZ(Yji0tSkY0dNgagIGHIccnf170HHvRNg0tifJVewL3PVeGHiyOOGqde9uBH)4JF53hVFjA1dNa)47lvnFPNEXxsfHv7xcRIm9WPVewfnx9rFjr9oDyy1od7rFjbYccz6xsuyPv3yihJitxpzYtrvCWQ1oqkOPBmHnksUbIEQTqpzhpL96EYspXQitpCAiQ3PddR2zyp6lbsqbYAcR2VeEK4kJEIH6D6WWQ1tGc55LvbnDdpLAuKCEAaEAHNTmo3tr9iplaapfvXbRwRNWQ2XxcRY70xsufhSATdKcA6gtyJIKBGONAl8hF8ZkF8(LOvpCc8JVVu18LE6fFjvewTFjSkY0dN(syv0C1h9Le170HHv7mSh9LeiliKPFjrHLwDJXscuXleONm5POkoy1AhGKg3NcT0arp1wONSJNYEDpzPNyvKPhone170HHv7mSh9LajOaznHv7xcpsCLrpXq9oDyy16jqH8epsACFk0sJVewL3PVKOkoy1AhGKg3NcT0arp1w4p(4Nv9J3VeT6HtGF89LQMV0tV4lPIWQ9lHvrME40xcRIMR(OVKOENomSANH9OVKazbHm9lrm4U10qGd61WiIu(SqGRUc6lbsqbYAcR2VeEK4kJEIH6D6WWQ1tGc5zCtEk)FnmIiL7jddbU6kippDaapnapJBYZgUYiH80GE2H2IZZ4wdpdKTYrX4lHv5D6lHvrME40GEnmIiLple4QRGMGexz0t2Xtm6POkoy1Ah0RHreP8zHaxDf0aSJ0WQ1t2XtrvCWQ1oOxdJis5ZcbU6kObIEQTqpXKNxRNS3trvCWQ1oOxdJis5ZcbU6kObIuqg)Xh)SkF8(LOvpCc8JVVu18LE6fFjvewTFjSkY0dN(syv0C1h9Le170HHv7mSh9LeiliKPFjIb3TMgcCGJRGMgfcopkioYtM8uufhSATdCCf00OqW5rbXrZRr(Xkx6smide9uBHEYoEEPR7jl9eRIm9WPHOENomSANH9OVeibfiRjSA)s4rIRm6jgQ3PddRwpbkKNS6Cf00OqqpXNcIJy2Z(Yji0tl8Sv15GEEipbjUYib6jVwCeYZ4wxpV019esIAbHJVewL3PVKOkoy1Ah44kOPrHGZJcIJMxJ8JvU0Lyqgi6P2c)Xh)miF8(LOvpCc8JVVu18LE6fFjvewTFjSkY0dN(syv0C1h9Le170HHv7mSh9LeiliKPFPq50gduFPzbmBQweAqRE4eONm55Pdame170HHv7aSATFjqckqwty1(LWJexz0tmuVthgwTE23W4EEzl5Zt6IgdrqpnapT4kON9MXxcRY70x60bagO(sZcy2uTi0arp1w4p(4NH7J3VeT6HtGF89LQMV0tV4lPIWQ9lHvrME40xcRIMR(OVKOENomSANH9OVKazbHm9lfkN2yG6lnlGzt1IqdA1dNa9KjppDaGHOENomSAhGvR1tM8uufhSATduFPzbmBQweAGONAl0tm7jR4jl9eRIm9WPHOENomSANH9OVeibfiRjSA)s4rIRm6jgQ3PddRwpbkKN66jDrGupVS9L8Sa8u(QweYtdWZ4M88Y2xYZcWt5RAripBvDoONI6rEwaaEkQIdwTwp1WtoPWWtwXtijQfe65Hake5jgQ3PddRwpBvDo44lHv5D6ljQIdwT2bQV0SaMnvlcnq0tTf6jM980bagO(sZcy2uTi0aSJ0WQ9hF8l71)49lrRE4e4hFFPQ5l90l(sQiSA)syvKPho9LWQO5Qp6ljQ3PddR2zyp6ljqwqit)sIQ4GvRDC6aatqdkSgUTkIXPOEpDbhi6P2c9eZEkQIdwT2XPdambnOWA42QigNI690fCa2rAy16jl9eRIm9WPHOENomSANH9ipzhpL96Fjqckqwty1(LWJexz0tmuVthgwTEEy0ZEJNr5PSx3tijQfe6zuEcyHN26jDrGup7qfhb9Sa8epAqH1WTvrm6jgQ3txWXxcRY70xsufhSATJthaycAqH1WTvrmof17Pl4aSJ0WQ1tm7POkoy1AhNoaWe0GcRHBRIyCkQ3txWbIEQTWF8XVSY(X7xIw9WjWp((svZx6Px8Lury1(LWQitpC6lHvrZvF0xsuVthgwTZWE0xsGSGqM(Lq9LakeoAaAqH1WTvrmof17Pl4Gw9WjqpzYZthayaAqH1WTvrmof17Pl4aSATFjqckqwty1(LWJexz0tmuVthgwTEAaEIhnOWA42Qig9ed17PlONTQoh0ZTcppKNisbz0tGc5PfEYifJVewL3PVKOkoy1AhNoaWe0GcRHBRIyCkQ3txWbIEQTWF8XVSx6J3VeT6HtGF89LQMV0tV4lPIWQ9lHvrME40xcRIMR(OVKOENomSANH9OVKazbHm9lHudCsyPngkiiCqxyWa6jtEIudCsyPngkiiCiQ(gEkV2EEnEYKNi1aNewAJHccchGDKgwTEkppLLv(sGeuGSMWQ9lDzvd0t5pwAdid5jEK4kJEIH6D6WWQ1tGc5Pcc6jSrBTqplapVgplKNVcrEQGGqpJBn8SLX5EYvy4jVwCeYZ4wxpLLv8esIAbHdpX7nbjpXQ8ob9ur0Ev45scccvKXz0ZQjSNY90wpvo3tHcj44lHv5D6lHudCsyPngkiiCy7p(4x2R5J3VeT6HtGF89LQMVeKIVKkcR2Vewfz6HtFjSkAU6J(sI6D6WWQDg2J(scKfeY0VesnWjHL2yGTZxcPhonOlmya9KjpXQitpCAiQ3PddR2jIuqgNH9ipzPNi1aNewAJb2oFjKE40W2VeibfiRjSA)sxw1a9u(JL2aYqEE58wkJqp7qYtmuVthgwTE2YIBpX25lH0JXTGrprQb6jHL2aYSNfwcHmqYtDz0tqIRmc9KBWGa9upfwYZO88PYrEc7iYtl8ehfqp7qc0ZBcrJVewL3PVesnWjHL2yGTZxcPhonS1ZR1t27jsnWjHL2yGTZxcPhon6n)4JFzLFF8(LOvpCc8JVVu18LGu8Lury1(LWQitpC6lHvrZvF0xsuVthgwTZWE0xsGSGqM(LWQitpCAiQ3PddR2jIuqgNH9ipXSNIQ4GvRDiQ3PddR2byhPHvRNxRNy0tz9KD8eJEE9XL8eZEIvrME40qoBb52IBIiWUiSA9eZEE9XL88A9eWqemuuqOHkcdl5jM88A9muoTXqoBb52IBqRE4eONyYtw22tSkY0dNgI6D6WWQDg2J8Kn28eRIm9WPHOENomSANH9ipLNNagU7yIONAl0t2XZlD9VeibfiRjSA)sm8qYZ4M8CPlcpXq9oDyy16zTEkQIdwTwpnapTWZwvNd65wHNhYt6IgseeONr5jiXvg9mUjpHIBcSZjqpRL8SqEg3KNqXnb25eON1sE2Q6CqpV1MgA9KtqONXTUEklR4jKe1cc98qafI8mUjpbmC3HN0cchEE5GGEgLNyvKPhonKZwqUT4MicSlcRwppKq7qYZ42GEARG3bjONXn5jaQ2Gxkib6zGmC4ie0tWoYwCEIH6D6WWQ1tDb9mU1WtSkY0dN80GE(iDdpJYZd5zhsGEQabH8ed170HHv74lHv5D6lHvrME40quVthgwTtePGmod7r)4JFzzLpE)s0Qhob(X3xQA(ski4xsfHv7xcRIm9WPVewL3PVuyp6lbsqbYAcR2V0Ldc6zCtEk6ieTHNH9ipJYZ4M8ekUjWoNa9ed170HHvRNr5ztp80cpT1t9alEpipd7rEclpJBn80cpnONWW4CpvHOJ0G8ubcc5P6j3IGtEg2J8SrHqco(syv0C1h9Le170HHv7mSh9Jp(LLv9J3VeT6HtGF89LQMVeKIVKkcR2Vewfz6HtFjqckqwty1(LyrBvoNrM9uulwcfEcGQNN6bw8EqEg2J8uxqpHrHipJBYteX1WWsEg2J80wpXQitpCAe2JMrnf170HHv7Wtg(LBYrEg3KNicgEwaEg3KNcLl6CnSAHm7zRBtC75T20qRNCcc9earm4oTbNrpJYtydrGE2B8mUjpH2RZ1WQLzpJBd65T20ql0ZcaGDy1XaE0tDb9S1TXjpfkmSf34lHv5D6lHrpXQitpCAiQ3PddR2zypYt2XZWEKNyYZR1ZthayiQ3PddR2by1A)sDinlaGjob4h)Y(LWQO5Qp6lf2JMrnf170HHv7xQdPzRBJttHcdBX9XVS)4hFju1mBUvi9X7h)Y(X7xIw9WjWp((scKfeY0VKkcdlnPLEgb9uET9eRIm9WPXDftyGivUjaxFemqMCKNm5jg980bag3vmHbIu5g9gpzJnppDaGbGHiyuO3O34jM(sQiSA)saC9rWazYr)4J)l9X7xIw9WjWp((scKfeY0V0PdamG9DkNT4GZdNGqBXnrKcY4O34jtEE6aadyFNYzlo48Wji0wCtePGmoq0tTf6P88uOWyg2J(sQiSA)snmIQdxHXp(4)A(49lrRE4e4hFFjbYccz6x60bagagIGrHEJEZxsfHv7xQHruD4km(Xh)YVpE)s0Qhob(X3xsGSGqM(LoDaGXDftyGivUrV5lPIWQ9l1WiQoCfg)4JFw5J3VeT6HtGF89L6qA26240uOWWwCF8l7xsGSGqM(LyVNyvKPhonamenpCfgZMQ42IZtM880bagW(oLZwCW5HtqOT4MisbzCawTwpzYtvegwAsl9mc6jl9eRIm9WPXTIaNcfgtaU(iyGm5ipzYt27jGHiyOOGqdvegwYtM8eJEYEppDaGXnPHT4M9MrVXtM8K9EE6aaJ7kMWarQCJEJNm5j79SbryNfaWeNaCayiAE4km8KjpXONQiSAhagIMhUcJH4wr4iONYRTNxYt2yZtm6zOCAJHYPlGbsHmOOWjqhX4Gw9WjqpzYtrvCWQ1oarkUAHZdI04EGifKrpXKNSXMNqsr2IBgvxCpuryyjpXKNy6l1H0SaaM4eGF8l7xsfHv7xcWq08Wvy8LajOaznHv7xIHhsEwl5jlAiYt8Xvy4jPioJEARNx2s(80a8KXQ7jyTxfEERyjpjlUjKN4HKg2IZtg(gplKN4Hv4PuGivopzKcp1f0tYIBcXqEIrftEERyjpFfI8mU11ZOv5PYrKcYiZEIXdM88wXsEE5C6cyGuidk6vqpzXoIrprKcYONr5zhsm7zH8eJcm5PePiBX5jERU42td6Pkcdln8epw7vHNGLNXTb9S1TXjpVveONcfg2IZtwKRpcgitoc6zH8S1nTEk1xpVmSf3vqpXhNGqBX5Pb9erkiJJF8XpR6hVFjA1dNa)47l1H0S1TXPPqHHT4(4x2VKazbHm9lXEpXQitpCAayiAE4kmMnvXTfNNm5j79eWqemuuqOHkcdl5jtEIrpXONy0tvewTdadrhLZh0fKOh2IZtM8eJEQIWQDayi6OC(GUGe9GMi6P2c9KLEE9bR4jBS5j79e1xcOq4ObGHiyuO3Gw9WjqpXKNSXMNQiSAhnmIQdxHXGUGe9WwCEYKNy0tvewTJggr1HRWyqxqIEqte9uBHEYspV(Gv8Kn28K9EI6lbuiC0aWqemk0BqRE4eONyYtm5jtEE6aaJBsdBXn7nJEJNyYt2yZtm6jKuKT4Mr1f3dvegwYtM8eJEE6aaJBsdBXn7nJEJNm5j79ufHv7akkK4EqxqIEylopzJnpzVNNoaW4UIjmqKk3O34jtEYEppDaGXnPHT4M9MrVXtM8ufHv7akkK4EqxqIEylopzYt275DftyGivUjSH4C402ja3WDhEIjpXKNy6l1H0SaaM4eGF8l7xsfHv7xcWq08Wvy8LajOaznHv7xIHhsEYIgI8eFCfgEswCtipb7iBX5P6jlAi6OCoRLpgr1HRWWtHcdpBDtRN4HKg2IZtg(gpnONQimSKNfYtWoYwCEsxqIEqE2YIBpLifzlopXB1f3JF8XpRYhVFjA1dNa)47lPIWQ9ljuoFQIWQDYny8L4gmMR(OVKkcdlndLtBa)Xh)miF8(LOvpCc8JVVKazbHm9lD6aaJggrLGRW3O34jtEkuymd7rEYsppDaGrdJOsWv4BGONAl0tM8uOWyg2J8KLEE6aaduFPzbmBQweAGONAl8lPIWQ9l1WiQoCfg)4JFgUpE)s0Qhob(X3xsGSGqM(LoDaGXDftyGivUrVXtM8eskYwCZO6I7Hkcdl5jtEQIWWstAPNrqpzPNyvKPhonURycdePYnb46JGbYKJ(sQiSA)snmIQdxHXp(4x2R)X7xIw9WjWp((scKfeY0Ve79eRIm9WPrZDrRDXSPkUT48KjppDaGXnPHT4M9MrVXtM8K9EE6aaJ7kMWarQCJEJNm5jg9ufHHLMGvmmCRfKNS0Zl5jBS5PkcdlnPLEgb9uET9eRIm9WPXTIaNcfgtaU(iyGm5ipzJnpvryyPjT0ZiONYRTNyvKPhonURycdePYnb46JGbYKJ8etFjvewTFPM7Iw7IjaxFe8hF8lRSF8(LOvpCc8JVVKazbHm9lbjfzlUzuDX9qfHHL(sQiSA)sqrHe3)4JFzV0hVFjA1dNa)47ljqwqit)sQimS0Kw6ze0t555L(sQiSA)sGifxTW5brAC)Jp(L9A(49lrRE4e4hFFjbYccz6xsfHHLM0spJGEkV2EIvrME40qrcDPjDrdVGwTEYKNpD1rJi8uET9eRIm9WPHIe6st6IgEbTANpD1VKkcR2VKIe6st6IgEbTA)Xh)Yk)(49lrRE4e4hFFjvewTFjaU(iyGm5OVeibfiRjSA)s4bwC7jTvh3TNHIWrbKzpTWtd6P6jo1wpJYtHcdpzrU(iyGm5ipvONagNtipTfgKc6zb4jlAi6OC(4ljqwqit)sQimS0Kw6ze0t512tSkY0dNg3kcCkuymb46JGbYKJ(Xh)YYkF8(Lury1(LameDuo)lrRE4e4hF)4hFjqcq784J3p(L9J3VeT6HtGF89LeiliKPFj27jQVeqHWrdqdkSgUTkIXPOEpDbh0Qhob(Lury1(LevFdcbBio)hF8FPpE)s0Qhob(X3xcKGcK1ewTFj8EtEkQ3PddR2zypBX5PkcRwp5gm8ekUjWoNGE26MwpXq9oDyy16zlJZ98qE2HeON6c6jmkeb9mUjpreSZdpT1tSkY0dNgH9Ozutr9oDyy1o(sQiSA)scLZNQiSANCdgFjUbJ5Qp6ljQ3PddR2zypBX9Jp(VMpE)s0Qhob(X3xQA(sqk(sQiSA)syvKPho9LWQ8o9LWONQimS0Kw6ze0tw6jwfz6Htdr9oDyy1oH3gqylUzt1IqEYgBEQIWWstAPNrqpzPNyvKPhone170HHv7eGRpcgitoYt2yZtSkY0dNgH9Ozutr9oDyy16j74PkcR2b82acBXnBQweAa058jIa7IWQ1t55POkoy1AhWBdiSf3SPArObyhPHvRNyYtM8eRIm9WPrypAg1uuVthgwTEYoEkQIdwT2b82acBXnBQweAGONAl0t55PkcR2b82acBXnBQweAa058jIa7IWQ1tM8eJEkQIdwT2bQV0SaMnvlcnq0tTf6j74POkoy1AhWBdiSf3SPArObIEQTqpLNNSINSXMNS3Zq50gduFPzbmBQweAqRE4eONy6lbsqbYAcR2Ve7wrME4KNXTgEsWWEAqqpBDtXnH8u62acBX5P8vTiKNTmo3Zd5zhsGEEiGcrEIH6D6WWQ1td6jIuqghFjSkAU6J(sWBdiSf3SPArO5Hakenf170HHv7p(4x(9X7xIw9WjWp((scKfeY0V0Pdame170HHv7aSATEYKNQiSAhagIMhUcJH4wr4iONSSTNY6jtEYEpXONNoaWWwacTkFkuOqbPrVXtM880bag3vmHbIu5gisfHNyYtM8eRIm9WPb82acBXnBQweAEiGcrtr9oDyy1(Lury1(LG3gqylUzt1Iq)4JFw5J3VeT6HtGF89LeiliKPFPthayiQ3PddR2by1A9KjpXONyvKPhonc7rZOMI6D6WWQ1tw6jwfz6Htdr9oDyy1oBqKqHXmSh5jM9KUGe9GMH9ipzJnpXQitpCAe2JMrnf170HHvRNYZtvewTtrvCWQ16j74PSx3tm9Lury1(LqkOPBmHnksUF8XpR6hVFjA1dNa)47ljqwqit)sNoaWquVthgwTdWQ16jtEE6aaduFPzbmBQweAawTwpzYtSkY0dNgH9Ozutr9oDyy16jl9eRIm9WPHOENomSANnisOWyg2J8eZEsxqIEqZWE0xsfHv7xcK04(uOL(Xh)SkF8(LOvpCc8JVVKazbHm9lHvrME40iShnJAkQ3PddRwpzPNyvKPhone170HHv7SbrcfgZWEKNy2t6cs0dAg2J8KjppDaGHOENomSAhGvR9lPIWQ9l9meQqWzbmJc9On(Xh)miF8(LOvpCc8JVVuhsZw3gNMcfg2I7JFz)sGeuGSMWQ9lXIfYt2nTXnJiM9SdjpvpzrdrEIpUcdpf3kch5jyhzlopVmneQqqplapXBHE0gEkuy4zuEQyld0tH20ylopf3kchbhFjvewTFjadrZdxHXxsGSGqM(Lury1oEgcvi4SaMrHE0gd6cs0dBX5jtEc058jIe3kchnd7rEYoEQIWQD8meQqWzbmJc9Ong0fKOh0erp1wONS0t5NNm5j798UIjmqKk3e2qCoCA7eGB4UdpzYt275PdamURycdePYn6n)4JFgUpE)s0Qhob(X3xsfHv7xchxbnnkeCEuqC0xsGSGqM(LWQitpCAe2JMrnf170HHvRNYZtvewTtrvCWQ16j74jR8LiaaseZvF0xchxbnnkeCEuqC0p(4x2R)X7xIw9WjWp((sQiSA)s0RHreP8zHaxDf0xsGSGqM(LWQitpCAe2JMrnf170HHvRNSSTNyvKPhonOxdJis5ZcbU6kOjiXvg9KjpXQitpCAe2JMrnf170HHvRNYZtSkY0dNg0RHreP8zHaxDf0eK4kJEYoEYkFPvF0xIEnmIiLple4QRG(Xh)Yk7hVFjA1dNa)47lPIWQ9lHJZyZ9SaMkeApJRHv7xsGSGqM(LWQitpCAe2JMrnf170HHvRNYRTNyvKPhonQD2H0u0Jca4lT6J(s44m2CplGPcH2Z4Ay1(Jp(L9sF8(LOvpCc8JVVKkcR2V0tf6brt4nrX81HM4ljqwqit)syvKPhonc7rZOMI6D6WWQ1tw22tw5lT6J(spvOhenH3efZxhAIF8XVSxZhVFjA1dNa)47lbsqbYAcR2Ve7cWZo0wCEQEcdcvgON1YoDi5Pf0JzpvElLrONDi5jEerkiGHipz3eesCpREanqYZcWtmuVthgwTdpzyXnHAzqIzpBqwHSWyqH8SdTfNN4rePGagI8KDtqiX9SLf3EIH6D6WWQ1ZA5m6Pb4j7Abi0QCpXGcfki5Pb9Kw9Wjqp1f0t1ZouXrE2Q2RcppKN8cgEwyjKNXn5jyhPHvRNfGNXn5jGH7ogEI3Bd6Pccc9u9e(uo3tSkVtEgLNXn5POkoy1A9Sa8epIifeWqKNSBccjUNTUP1tWYwCEg3g0tHYfDUgwTEEiH2HKNw4Pb9SVis5WWeEgLNke2FKNXTgEAHNTmo3Zd5zhsGE2qiaseCg9SwpfvXbRw74lT6J(sGisbbmenXsqiX)scKfeY0Vewfz6HtJWE0mQPOENomSA9uET9eRIm9WPrTZoKMIEuaaEYKNy0ZthayylaHwLpfkuOG0agQqopB75PdamSfGqRYNcfkuqA80lMWqfY5jBS5j79uuly3IHTaeAv(uOqHcsdA1dNa9Kn28eRIm9WPHOENomSAN1o7qYt2yZtSkY0dNgH9Ozutr9oDyy16P8802GqnfxdcCcy4UJjIEQTqpz180tm6PkcR2POkoy1A9eZEk719etEIPVKkcR2VeiIuqadrtSees8F8XVSYVpE)s0Qhob(X3xcKGcK1ewTFjPQZ9KDHBTGqEcVRoh0Zd5zhsGEARNQNTug9mU1WtWIG7vHN2gecGqKNTS42ZkUjKN1YoDi5zGSvokGdpzyXnH8mq2khfqpblp3k8mqgoCeYt1t4TIiqpzxyap6zTEAbZEclpTWtHUEEip7qc0tKH7o8ubcc5PUm6zf3eYZAzNoK8mq2khfJV0Qp6lbRoFA4wli0xsGSGqM(LWQitpCAe2JMrnf170HHvRNYRTNxZ198A9eJEIvrME40O2zhstrpkaapLNNx3tm5jtEIrpzVNedUBnne4aerkiGHOjwccjUNSXMNIQ4GvRDaIifeWq0elbHeFGONAl0t55jR4jM(sQiSA)sWQZNgU1cc9Jp(LLv(49lrRE4e4hFFjvewTFjHUcIppDaGVKazbHm9lXEpf1c2TyylaHwLpfkuOG0Gw9WjqpzYZWEKNS0twXt2yZZthayylaHwLpfkuOG0agQqopB75PdamSfGqRYNcfkuqA80lMWqfY9LoDaG5Qp6lbRoFA4wlSA)sGeuGSMWQ9lHxKHdhH8uQ6Cpzx4wliKNKI4m6zllU9KDTaeAvUNyqHcfK8SqE26MwpTWZwk0Zgejuym(Xh)YYQ(X7xIw9WjWp((sQiSA)sDinTGEWVeibfiRjSA)sSRGEqpJBn8eS8CRWZdTeGfEIH6D6WWQ1t4D15GEYGUddppKNDib6z1dObsEwaEIH6D6WWQ1tn8ewpYZMY2y8LeiliKPFjSkY0dNgH9Ozutr9oDyy16P8A7jwfz6HtJANDinf9Oaa(Xh)YYQ8X7xIw9WjWp((sQiSA)saOcgZTWQFjqckqwty1(Ly4HKNSiQGHN4VWQEgLNbYWHJqEYQJmiNrpzxctWPXxsGSGqM(Lq9LakeoAGdzqoJttyconOvpCc0tM880bagI6D6WWQDawTwpzYtm6jwfz6HtJWE0mQPOENomSA9uEEQIWQDkQIdwTwpzJnpXQitpCAe2JMrnf170HHvRNS0tSkY0dNgI6D6WWQD2GiHcJzypYtm7jDbj6bnd7rEIPF8XVSmiF8(LOvpCc8JVVKkcR2VKO6BqiydX5Fjqckqwty1(Ly1PWZ4M8epAqH1WTvrm6jgQ3txqppDaap7nm7zF5ee6POENomSA90GEcRAhFjbYccz6xc1xcOq4ObObfwd3wfX4uuVNUGdA1dNa9KjpfvXbRw740baMGguynCBveJtr9E6coq0tTf6jl9ufHv7aavW4u8yiuymd7rEYKNNoaWa0GcRHBRIyCkQ3txWPIe6sdWQ16jtEYEppDaGbObfwd3wfX4uuVNUGJEJNm5jg9eRIm9WPrypAg1uuVthgwTEkppfvXbRw740baMGguynCBveJtr9E6coa7inSA9Kn28eRIm9WPrypAg1uuVthgwTEYspzfpX0p(4xwgUpE)s0Qhob(X3xsGSGqM(Lq9LakeoAaAqH1WTvrmof17Pl4Gw9WjqpzYtrvCWQ1ooDaGjObfwd3wfX4uuVNUGde9uBHEYspPlirpOzypYtm7PkcR2baQGXP4XqOWyg2J8KjppDaGbObfwd3wfX4uuVNUGtfj0LgGvR1tM8K9EE6aadqdkSgUTkIXPOEpDbh9gpzYtm6jwfz6HtJWE0mQPOENomSA9uEEkQIdwT2XPdambnOWA42QigNI690fCa2rAy16jBS5jwfz6HtJWE0mQPOENomSA9KLEYkEYKNS3Zq50gduFPzbmBQweAqRE4eONy6lPIWQ9lPiHU0KUOHxqR2F8X)LU(hVFjA1dNa)47ljqwqit)sO(safchnanOWA42QigNI690fCqRE4eONm5POkoy1AhNoaWe0GcRHBRIyCkQ3txWbIEQTqpzPNcfgZWEKNm55PdamanOWA42QigNI690fCcGkymaRwRNm5j7980bagGguynCBveJtr9E6co6nEYKNy0tSkY0dNgH9Ozutr9oDyy16P88uufhSATJthaycAqH1WTvrmof17Pl4aSJ0WQ1t2yZtSkY0dNgH9Ozutr9oDyy16jl9Kv8etFjvewTFjaubJtXJF8X)LK9J3VeT6HtGF89LeiliKPFjSkY0dNgH9Ozutr9oDyy16jlB7519Kn28eRIm9WPrypAg1uuVthgwTEYspXQitpCAiQ3PddR2zdIekmMH9ipzYtrvCWQ1oe170HHv7arp1wONS0tSkY0dNgI6D6WWQD2GiHcJzyp6lPIWQ9ljuoFQIWQDYny8L4gmMR(OVKOENomSANn3kK(Xh)x6sF8(LOvpCc8JVVKazbHm9lD6aaduFPzbmBQweAawTwpzYt275PdamamebJc9g9gpzYtm6jwfz6HtJWE0mQPOENomSA9uET980bagO(sZcy2uTi0aSJ0WQ1tM8eRIm9WPrypAg1uuVthgwTEkppvry1oamenpCfgdGoNprK4wr4OzypYt2yZtSkY0dNgH9Ozutr9oDyy16P88eWWDhte9uBHEIPVKkcR2VeQV0SaMnvlc9Jp(V018X7xIw9WjWp((svZxcsXxsfHv7xcRIm9WPVeibfiRjSA)sYxvCpvONpDz0tw0qKN4JRWa6Pc9SPGq7WjpbkKNyOENomSAhEk1pbsfHNvp8Sa8mUjpbqQiSAvUNI61ulTHNfGNXn552Fhc5zb4jlAiYt8Xvya9mU1WZwgN75QrhPCoJEIiXTIWrEc2r2IZZ4M8ed170HHvRNn3kK88qcTdjpBQIBlop1LX42wCE2OWWZ4wdpBzCUNBfEIdPB4PUEsxei1tw0qKN4JRWWtWoYwCEIH6D6WWQD8LWQ8o9Lury1oamenpCfgdXTIWrWjasfHvRY9eZEIrpXQitpCAe2JMrnf170HHvRNy2tvewTd4Tbe2IB2uTi0aOZ5teb2fHvRNxRNyvKPhonG3gqylUzt1IqZdbuiAkQ3PddRwpXKNS2trvCWQ1oamenpCfgdWosdRwpzhpL1tw6POkoy1AhagIMhUcJXtVykUveoc6jM9eRIm9WPrHLqnvXNagIMhUcdONS2trvCWQ1oamenpCfgdWosdRwpzhpXONNoaWquVthgwTdWosdRwpzTNIQ4GvRDayiAE4kmgGDKgwTEIjp9KvZtz9KjpXQitpCAe2JMrnf170HHvRNS0tad3Dmr0tTf(L6qAwaatCcWp(L9lHvrZvF0xcWq08WvymBQIBlUVuhsZw3gNMcfg2I7JFz)Xh)xs(9X7xIw9WjWp((svZxcsXxsfHv7xcRIm9WPVewfnx9rFPM7Iw7IztvCBX9LeiliKPFjvegwAsl9mc6jl9eRIm9WPHOENomSANaC9rWazYrFjqckqwty1(Ly3kY0dN8mU1WtrTbQ4qpLV7Iw7cpzrU(iONDOIJ8mkpPf2rKNwa9uCRiCe0tfrE2ufNa9eOqEIH6D6WWQD4jdB5m6zhsEkF3fT2fEYIC9rqpREanqYZcWtmuVthgwTE26Mwpb6CUNIBfHJGEk01Zd5zDc1wc0tWoYwCEg3KNlDr4jgQ3PddR2XxcRY70xcRIm9WPrypAg1uuVthgwTEIzppDaGHOENomSAhGDKgwTEYoEYkEYspvry1oAUlATlMaC9rWbqNZNisCRiC0mSh5jM9uufhSATJM7Iw7IjaxFeCa2rAy16j74PkcR2b82acBXnBQweAa058jIa7IWQ1ZR1tSkY0dNgWBdiSf3SPArO5Hakenf170HHvRNm5jwfz6HtJWE0mQPOENomSA9KLEcy4UJjIEQTqpzJnpr9LakeoAa77uoBXbNhobH2IBqRE4eONSXMNH9ipzPNSYp(4)sSYhVFjA1dNa)47lvnFjifFjvewTFjSkY0dN(syv0C1h9LAUlATlMnvXTf3xsGSGqM(LuryyPjT0ZiONYRTNyvKPhone170HHv7eGRpcgito6lbsqbYAcR2VeEWnTE2H2IZtwKRpcgitoYtB9ed170HHvlZEcvSKNk0ZNUm6P4wr4iONk0ZMccTdN8eOqEIH6D6WWQ1ZwwCx9WtH20ylUXxcRY70xcRIm9WPrypAg1uuVthgwTEYspvry1oAUlATlMaC9rWbqNZNisCRiC0mSh5j74PkcR2b82acBXnBQweAa058jIa7IWQ1ZR1tSkY0dNgWBdiSf3SPArO5Hakenf170HHvRNm5jwfz6HtJWE0mQPOENomSA9KLEcy4UJjIEQTqpzJnpr9LakeoAa77uoBXbNhobH2IBqRE4eONSXMNH9ipzPNSYp(4)sSQF8(LOvpCc8JVVKazbHm9lD6aaduFPzbmBQweA0B8KjpXQitpCAe2JMrnf170HHvRNYZZR)LGbYeXh)Y(Lury1(LekNpvry1o5gm(sCdgZvF0xcvnZMBfs)4J)lXQ8X7xIw9WjWp((sDinBDBCAkuyylUp(L9lbsqbYAcR2V0LdYGUddpJBYtSkY0dN8mU1WtrTbQ4qpzrdrEIpUcdp7qfh5zuEslSJipTa6P4wr4iONkI8u5WYZMQ4eONafYZlBFjplapLVQfHgFPQ5lbP4ljqwqit)sS3tSkY0dNgagIMhUcJztvCBX5jtEgkN2yG6lnlGzt1IqdA1dNa9KjppDaGbQV0SaMnvlcnaRw7xcRY70xsufhSATduFPzbmBQweAGONAl0tw6PkcR2bGHO5HRWya058jIe3kchnd7rEYoEQIWQDaVnGWwCZMQfHgaDoFIiWUiSA98A9eJEIvrME40aEBaHT4MnvlcnpeqHOPOENomSA9KjpfvXbRw7aEBaHT4Mnvlcnq0tTf6jl9uufhSATduFPzbmBQweAGONAl0tm5jtEkQIdwT2bQV0SaMnvlcnq0tTf6jl9eWWDhte9uBHFPoKMfaWeNa8JFz)sQiSA)syvKPho9LWQO5Qp6lbyiAE4kmMnvXTf3p(4)smiF8(LOvpCc8JVVuhsZw3gNMcfg2I7JFz)scKfeY0Ve79eRIm9WPbGHO5HRWy2uf3wCEYKNyvKPhonc7rZOMI6D6WWQ1t55519KjpvryyPjT0ZiONYRTNyvKPhonUve4uOWycW1hbdKjh5jtEYEpbmebdffeAOIWWsEYKNS3ZthayCxXegisLB0B8KjpXONNoaW4M0WwCZEZO34jtEQIWQDaW1hbdKjhnOlirpOjIEQTqpzPNxFWkEYgBEkUveocobqQiSAvUNYRTNxYtm9L6qAwaatCcWp(L9lPIWQ9lbyiAE4km(sGeuGSMWQ9lHhCtRN4HkcuOWWwCEYIC9rEkfitoIzpzrdrEIpUcdONW7QZb98qE2HeONr5joAjKgKN4Hv4PuGivoON6c6zuEsxe0c6j(4kmiKNxMkmi04hF8FjgUpE)s0Qhob(X3xQdPzRBJttHcdBX9XVSFjbYccz6xcWqemuuqOHkcdl5jtEkUveoc6P8A7PSEYKNS3tSkY0dNgagIMhUcJztvCBX5jtEIrpzVNQiSAhagIokNpOlirpSfNNm5j79ufHv7OHruD4kmg2ob4gU7WtM880bag3Kg2IB2Bg9gpzJnpvry1oameDuoFqxqIEylopzYt275PdamURycdePYn6nEYgBEQIWQD0WiQoCfgdBNaCd3D4jtEE6aaJBsdBXn7nJEJNm5j7980bag3vmHbIu5g9gpX0xQdPzbamXja)4x2VKkcR2VeGHO5HRW4lbsqbYAcR2VeESJSfNNSOHiyOOGqm7jlAiYt8Xvya9urKNDib6j0EgxrCg9mkpb7iBX5jgQ3PddR2HNS60siLZzKzpJBIrpve5zhsGEgLN4OLqAqEIhwHNsbIu5GE26MwpfilGE2Y4Cp3k88qE2sHbb6PUGE2YIBpXhxHbH88YuHbHy2Z4My0t4D15GEEipHnisb9S6HNr55tTnuB9mUjpXhxHbH88YuHbH880bag)4J)R56F8(LOvpCc8JVVuhsZw3gNMcfg2I7JFz)sGeuGSMWQ9lD5yld0tH20ylopzrdrEIpUcdpf3kchb9S1TXjpf36Ue3wCEkDBaHT48u(Qwe6lPIWQ9lbyiAE4km(scKfeY0VKkcR2b82acBXnBQweAqxqIEylopzYtGoNprK4wr4OzypYtw6PkcR2b82acBXnBQweAeMqUjIa7IWQ1tM880bag3vmHbIu5gGvR1tM8mSh5P88u2R)Jp(Vgz)49lrRE4e4hFFjbYccz6xcRIm9WPrypAg1uuVthgwTEkppVUNm55Pdamq9LMfWSPArOby1A)sQiSA)scLZNQiSANCdgFjUbJ5Qp6lbdDbve4evHgwT)4J)R5sF8(Lury1(LGIcjU)s0Qhob(X3p(XxQbrI6D04J3p(L9J3VKkcR2VKIe6stBdIZjr8LOvpCc8JVF8X)L(49lrRE4e4hFFPQ5lbP4ljqwqit)syvKPhonamebdffeAkQ3PddRwpzPNx)lbsqbYAcR2V0LlFmGNSBfz6HtEYWAcRwgYt8EBqpXQitpCYtydjmaJGE26MIBc5jgQ3PddRwpH3vNd65H8Sdjqpb7iBX5jlAicgkki04lHvrZvF0xcWqemuuqOPOENomSA)sQiSA)syvKPho9LWQ8onjoK(sSJNY(LWQ8o9LK1ZR1t27zOCAJrdJOsWv4BqRE4e4p(4)A(49lrRE4e4hFFPQ5lbP4lPIWQ9lHvrME40xcRIMR(OV0DftyGivUjaxFemqMC0xsGSGqM(LWQitpCACxXegisLBcW1hbdKjh5zBpV(xcKGcK1ewTFPlx(yapz3kY0dN8KH1ewTmKN492GEIvrME4KNWgsyagb9mUjp3(7qiplapdfHJcONA4zRBtC7jEyfEkfisLZtwKRpcgitoc6z1dObsEwaEIH6D6WWQ1t4D15GEEip7qcC8LWQ8o9LUKNxRNHYPngaC9rZgne3dA1dNa9eZEEnEETEYEpdLtBma46JMnAiUh0Qhob(Jp(LFF8(LOvpCc8JVVu18LGu8Lury1(LWQitpC6lHvrZvF0x6wrGtHcJjaxFemqMC0xsGSGqM(LWQitpCACRiWPqHXeGRpcgitoYZ2EE9VeibfiRjSA)sxU8XaEYUvKPho5jdRjSAzipX7Tb9eRIm9WjpHnKWamc6zCtEU93HqEwaEgkchfqp1WZw3M42t8qfb6jguy4jlY1hbdKjhb9S6b0ajplapXq9oDyy16j8U6CqppKNDib6Pc9eW4Ccn(syvEN(sxYZR1Zq50gdaU(OzJgI7bT6HtGEIzpVgpVwpzVNHYPngaC9rZgne3dA1dNa)Xh)SYhVFjA1dNa)47lvnFjifFjvewTFjSkY0dN(syv0C1h9Le170HHv7eGRpcgito6ljqwqit)syvKPhone170HHv7eGRpcgitoYZ2EE9VeibfiRjSA)sxU8XaEYUvKPho5jdRjSAzipX7Tb9eRIm9WjpHnKWamc6zCtEU93HqEwaEgkchfqp1WZw3M42t8Wk8ukqKkNNSixFemqMCe0tfrE2HeONGDKT48ed170HHv74lHv5D6lDnEETEgkN2yaW1hnB0qCpOvpCc0tm7jRQNxRNS3Zq50gdaU(OzJgI7bT6HtG)4JFw1pE)s0Qhob(X3xQA(sqk(sQiSA)syvKPho9LWQO5Qp6lPiHU0KUOHxqR2VKazbHm9lHvrME40qrcDPjDrdVGwTE22ZR)LajOaznHv7x6YLpgWt2TIm9WjpzynHvld5jEVnONyvKPho5jSHegGrqpJBYZT)oeYZcWZqr4Oa6PgE262e3EE5iHUKNY)lA4f0Q1ZQhqdK8Sa8ed170HHvRNW7QZb98qE2He44lHv5D6lXWXW5516zOCAJbaxF0SrdX9Gw9WjqpXSNxYZR1t27zOCAJbaxF0SrdX9Gw9WjWF8XpRYhVFjA1dNa)47lvnFjebP4lPIWQ9lHvrME40xcRIMR(OVKIe6st6IgEbTANpD1VeibODE8LKFx)lbsqbYAcR2V0LlFmGNSBfz6HtEYWAcRwgYt8EBqpXQitpCYtydjmaJGEg3KNnesqBO4iplapF6QEEiE1YZw3M42Zlhj0L8u(FrdVGwTE2Y4Cp3k88qE2He44hF8ZG8X7xIw9WjWp((svZxcrqk(sQiSA)syvKPho9LWQO5Qp6ljNTGCBXnreyxewTFjqcq784lD9H87lbsqbYAcR2V0LlFmGNSBfz6HtEYWAcRwgYt8alU98YWwqUT4y2tmuVthgwTxb9uufhSATE2Y4CppKNicSliqppm6P6jsxW65P(Q(gm75PhEg3KNB)DiKNfGNcKfqpHHIcONyjeJEEB4U9ubcc5PkcdRg2IZtmuVthgwTEQlONqE1c6jy1A9mQwkce6zCtEslONfGNyOENomSAVc6POkoy1AhEIhCtRNpvoBX5jijmOvl0tB9mUjpVC5Jby2tmuVthgwTxb9erp1wBX5POkoy1A90GEIiWUGa98WONXTb9eaPIWQ1ZO8ufIQVHNafYZldBb52IB8Jp(z4(49lrRE4e4hFFPQ5lHiifFjvewTFjSkY0dN(syv0C1h9Le170HHv7eEBaHT4Mnvlc9LajaTZJV0L(sGeuGSMWQ9lD5Yhd4j7wrME4KNmSMWQLH8eV3KNB)DiKNfGNHIWrb0tPBdiSfNNYx1IqEcVRoh0Zd5zhsGEwRNGDKT48ed170HHv74hF8l71)49lrRE4e4hFFPQ5lHiifFjvewTFjSkY0dN(syv0C1h9Le170HHv7uOWyIONAl8lbsaANhFPRpyv(sGeuGSMWQ9lD5Yhd4j7wrME4KNmSMWQLH8eV3KNH9ipr0tT1wCEwRNQNcfgE26MwpXq9oDyy16PqxppKNDib6PTEcjrTGWXp(4xwz)49lrRE4e4hFFPQ5lHiifFjvewTFjSkY0dN(syv0C1h9LkSeQPk(eWq08Wvya)sGeG25Xx66Fjqckqwty1(LUC5Jb8KDRitpCYtgwty1YqEI3Bd6jwfz6HtEcBiHbye0Z4M8C7VdH8Sa8esIAbHEwaEYIgI8eFCfgEg3A4j8U6CqppKNnvXjqpBuy4zCtEcsaANhEQVQVX4hF8l7L(49lrRE4e4hFFPQ5lHiifFjvewTFjSkY0dN(syv0C1h9LOxdJis5ZcbU6kOjiXvg)sGeG25XxswgKVeibfiRjSA)sxU8XaEYUvKPho5jdRjSAzipXdRwEYRfNNhcOqKNyOENomSA9eExDoONY)xdJis5EYWqGRUcYZd5zhsGmO(Jp(L9A(49lrRE4e4hFFPQ5lbP4lPIWQ9lHvrME40xcRIMR(OVuypAg1uuVthgwTFjbYccz6xcRIm9WPbOb1dNMI6D6WWQ9lbsqbYAcR2Ve7cWtmuVthgwTEAqpbnOE4eiZEcf3eyNtEg3KNagcgEIH6D6WWQ1taf5PceeYZ4M8eWWDhEsliC8LWQ8o9LamC3Xerp1wONy2tzV(1)Xh)Yk)(49lrRE4e4hFFPQ5lbP4lPIWQ9lHvrME40xcRY70xIv(sGeuGSMWQ9lH3BYtWosdRwplapvpL6RNxg2I7kON4JtqOT48ed170HHv74lHvrZvF0xck3zc2rAy1(Jp(LLv(49lrRE4e4hFFPQ5lbP4lPIWQ9lHvrME40xcRY70xIyWDRPHah44kOPrHGZJcIJ8Kn28KyWDRPHahpvOhenH3efZxhAcpzJnpjgC3AAiWHTqbQh6HttgCx3O)MGewtqEYgBEsm4U10qGdyFp8QaN6JIBgHHNSXMNedUBnne4GEnmIiLple4QRG8Kn28KyWDRPHahaC9rZcyE0i4KNSXMNedUBnne4OLkhTecobq1c6jBS5jXG7wtdboSfgOUikeCcAyTLMhIZ)sGeuGSMWQ9lHhCtXnH8u9Sd1dN80c65zhsGEgLNNoaGNyOENomSA90GEsm4U10qGJVewfnx9rFjr9oDyy1oRD2H0p(4xww1pE)s0Qhob(X3xQA(sqk(sQiSA)syvKPho9LWQO5Qp6lv7SdPPOhfaWxsGSGqM(LWQitpCAiQ3PddR2zTZoK(sGeuGSMWQ9lHhwT8KxloppeqHipXq9oDyy16j8U6CqpdKTYrb0Z4wdpdKHdhH8u9eERic0tHgeUcXONIQ4GvR1ZA9SIBc5zGSvokGEUv45H8Sdjqgu)syvEN(sx66)4JFzzv(49lrRE4e4hFFPQ5lbP4lPIWQ9lHvrME40xcRY70x6sSYxsGSGqM(LigC3AAiWXtf6brt4nrX81HM4lHvrZvF0xQ2zhstrpkaGF8XVSmiF8(LOvpCc8JVVu18LGu8Lury1(LWQitpC6lHv5D6lDPR7jM9eRIm9WPb9AyerkFwiWvxbnbjUY4xsGSGqM(LigC3AAiWb9AyerkFwiWvxb9LWQO5Qp6lv7SdPPOhfaWp(4xwgUpE)s0Qhob(X3xsfHv7xcwD(0WTwqOVKazbHm9lXEpXQitpCAiQ3PddR2zTZoK8KjpzVNedUBnne4aerkiGHOjwccjUNm5j79muoTXaWqemuuqObT6HtGFPvF0xcwD(0WTwqOF8X)LU(hVFjvewTFPNHqfAApfh9LOvpCc8JVF8X)LK9J3VeT6HtGF89LeiliKPFj27zdIWoAyevhUcJVKkcR2VudJO6Wvy8JF8Le170HHv7uufhSATWpE)4x2pE)sQiSA)snvy1(LOvpCc8JVF8X)L(49lPIWQ9lD4vbob6ig)s0Qhob(X3p(4)A(49lrRE4e4hFFjbYccz6x60bagI6D6WWQD0B(sQiSA)shcbjKC2I7hF8l)(49lPIWQ9lbyi6WRc8lrRE4e4hF)4JFw5J3VKkcR2VKUccgiLpfkN)LOvpCc8JVF8XpR6hVFjA1dNa)47ljqwqit)sO(safchnc61uiLpBPOMbT6HtGEYKNNoaWGU4w7WWQD0B(sQiSA)sH9Ozlf18Jp(zv(49lrRE4e4hFFjvewTFjCCf00OqW5rbXrFjcaGeXC1h9LWXvqtJcbNhfeh9Jp(zq(49lrRE4e4hFFPvF0xYwOa1d9WPjdURB0FtqcRjOVKkcR2VKTqbQh6HttgCx3O)MGewtq)4JFgUpE)s0Qhob(X3xA1h9La46JMfW8OrWPVKkcR2VeaxF0SaMhnco9Jp(L96F8(LOvpCc8JVV0Qp6l1sLJwcbNaOAb)sQiSA)sTu5OLqWjaQwWF8XVSY(X7xIw9WjWp((sR(OVKTWa1frHGtqdRT08qC(xsfHv7xYwyG6IOqWjOH1wAEio)hF8l7L(49lrRE4e4hFFPvF0xc23dVkWP(O4Mry8Lury1(LG99WRcCQpkUzeg)4JFzVMpE)sQiSA)sDinTGEWVeT6HtGF89JF8LuryyPzOCAd4hVF8l7hVFjA1dNa)47ljqwqit)sQimS0Kw6ze0t55PSEYKNNoaWquVthgwTdWQ16jtEIrpXQitpCAe2JMrnf170HHvRNYZtrvCWQ1o4gwBXnp17ma7inSA9Kn28eRIm9WPrypAg1uuVthgwTEYY2EEDpX0xsfHv7xIByTf38uVZp(4)sF8(LOvpCc8JVVKazbHm9lHvrME40iShnJAkQ3PddRwpzzBpVUNSXMNy0trvCWQ1oEuqfAa2rAy16jl9eRIm9WPrypAg1uuVthgwTEYKNS3Zq50gduFPzbmBQweAqRE4eONyYt2yZZq50gduFPzbmBQweAqRE4eONm55Pdamq9LMfWSPArOrVXtM8eRIm9WPrypAg1uuVthgwTEkppvry1oEuqfAiQIdwTwpzJnpbmC3Xerp1wONS0tSkY0dNgH9Ozutr9oDyy1(Lury1(LEuqf6hF8FnF8(LOvpCc8JVVKazbHm9lfkN2yOC6cyGuidkkCc0rmoOvpCc0tM8eJEE6aadr9oDyy1oaRwRNm5j7980bag3vmHbIu5g9gpX0xsfHv7xceP4QfopisJ7F8JVem0furGtufAy1(X7h)Y(X7xIw9WjWp((scKfeY0VKkcdlnPLEgb9uET9eRIm9WPXDftyGivUjaxFemqMCKNm5jg980bag3vmHbIu5g9gpzJnppDaGbGHiyuO3O34jM(sQiSA)saC9rWazYr)4J)l9X7xIw9WjWp((scKfeY0V0PdamamebJc9g9MVKkcR2VudJO6Wvy8Jp(VMpE)s0Qhob(X3xsGSGqM(LoDaGXDftyGivUrVXtM880bag3vmHbIu5gi6P2c9KLEQIWQDayi6OC(GUGe9GMH9OVKkcR2VudJO6Wvy8Jp(LFF8(LOvpCc8JVVKazbHm9lD6aaJ7kMWarQCJEJNm5jg9SbryN4eGdzhagIokN7jBS5jGHiyOOGqdvegwYt2yZtvewTJggr1HRWyy7eGB4UdpX0xsfHv7xQHruD4km(Xh)SYhVFjA1dNa)47lPIWQ9l1WiQoCfgFjqckqwty1(LWlIrpJYtCu4P0Lb(8SbvcON2cnqYZlBjFE2CRqc6zH8ed170HHvRNn3kKGE26MwpBki0oCA8LeiliKPFPthaya77uoBXbNhobH2IBIifKXrVXtM8eJEkQIdwT2bQV0SaMnvlcnq0tTf6jM9ufHv7a1xAwaZMQfHg0fKOh0mSh5jM9uOWyg2J8uEEE6aadyFNYzlo48Wji0wCtePGmoq0tTf6jBS5j79muoTXa1xAwaZMQfHg0Qhob6jM8KjpXQitpCAe2JMrnf170HHvRNy2tHcJzypYt555PdamG9DkNT4GZdNGqBXnrKcY4arp1w4p(4Nv9J3VeT6HtGF89LeiliKPFPthayCxXegisLB0B8KjpHKISf3mQU4EOIWWsFjvewTFPggr1HRW4hF8ZQ8X7xIw9WjWp((scKfeY0V0PdamAyevcUcFJEJNm5PqHXmSh5jl980bagnmIkbxHVbIEQTWVKkcR2VudJO6Wvy8Jp(zq(49lrRE4e4hFFPoKMTUnonfkmSf3h)Y(LeiliKPFj27jGHiyOOGqdvegwYtM8K9EIvrME40aWq08WvymBQIBlopzYtm6jg9eJEQIWQDayi6OC(GUGe9WwCEYKNy0tvewTdadrhLZh0fKOh0erp1wONS0ZRpyfpzJnpzVNO(safchnamebJc9g0Qhob6jM8Kn28ufHv7OHruD4kmg0fKOh2IZtM8eJEQIWQD0WiQoCfgd6cs0dAIONAl0tw651hSINSXMNS3tuFjGcHJgagIGrHEdA1dNa9etEIjpzYZthayCtAylUzVz0B8etEYgBEIrpHKISf3mQU4EOIWWsEYKNy0ZthayCtAylUzVz0B8KjpzVNQiSAhqrHe3d6cs0dBX5jBS5j7980bag3vmHbIu5g9gpzYt275PdamUjnSf3S3m6nEYKNQiSAhqrHe3d6cs0dBX5jtEYEpVRycdePYnHneNdN2ob4gU7Wtm5jM8etFPoKMfaWeNa8JFz)sQiSA)sagIMhUcJVeibfiRjSA)s4XoYwCEg3KNWqxqfb6jQcnSAz2ZA5m6zhsEYIgI8eFCfgqpBDtRNXnXONkI8CRWZdzlopBQItGEcuipVSL85zH8ed170HHv7WtgEi5jlAiYt8Xvy4jzXnH8eSJSfNNQNSOHOJY5Sw(yevhUcdpfkm8S1nTEIhsAylopz4B80GEQIWWsEwipb7iBX5jDbj6b5zllU9uIuKT48eVvxCp(Xh)mCF8(LOvpCc8JVVKazbHm9lD6aaJ7kMWarQCJEJNm5PkcdlnPLEgb9KLEIvrME404UIjmqKk3eGRpcgito6lPIWQ9l1WiQoCfg)4JFzV(hVFjA1dNa)47ljqwqit)sS3tSkY0dNgn3fT2fZMQ42IZtM8eJEYEpdLtBmaq1Bg30uH3eCqRE4eONSXMNQimS0Kw6ze0t55PSEIjpzYtm6PkcdlnbRyy4wlipzPNxYt2yZtvegwAsl9mc6P8A7jwfz6HtJBfbofkmMaC9rWazYrEYgBEQIWWstAPNrqpLxBpXQitpCACxXegisLBcW1hbdKjh5jM(sQiSA)sn3fT2ftaU(i4p(4xwz)49lrRE4e4hFFjvewTFjHY5tvewTtUbJVe3GXC1h9LuryyPzOCAd4p(4x2l9X7xIw9WjWp((scKfeY0VKkcdlnPLEgb9uEEk7xsfHv7xceP4QfopisJ7F8XVSxZhVFjA1dNa)47ljqwqit)sqsr2IBgvxCpuryyPVKkcR2VeuuiX9p(4xw53hVFjA1dNa)47ljqwqit)sQimS0Kw6ze0t512tSkY0dNgksOlnPlA4f0Q1tM88PRoAeHNYRTNyvKPhonuKqxAsx0WlOv78PR(Lury1(LuKqxAsx0WlOv7p(4xww5J3VeT6HtGF89Lury1(La46JGbYKJ(sGeuGSMWQ9lHhyXTN0wDC3EgkchfqM90cpnONQN4uB9mkpfkm8Kf56JGbYKJ8uHEcyCoH80wyqkONfGNSOHOJY5JVKazbHm9lPIWWstAPNrqpLxBpXQitpCACRiWPqHXeGRpcgito6hF8llR6hVFjvewTFjadrhLZ)s0Qhob(X3p(XxsuVthgwTZMBfsF8(XVSF8(LOvpCc8JVVKazbHm9lD6aadr9oDyy1oaRw7xsfHv7xIB4Ud4KbDhe3J24hF8FPpE)s0Qhob(X3xQdPzRBJttHcdBX9XVSFjqckqwty1(LK)WWEAqEExT8KxlopXq9oDyy16zlJZ9KRWWZ4wx5GEgLNs91ZldBXDf0t8Xji0wCEgLNGuqONTKN3vlpzrdrEIpUcdONW7QZb98qE2He44lvnFjifFjbYccz6xsuly3IHTaeAv(uOqHcsdA1dNa)syvEN(sNoaWquVthgwTde9uBHEIzppDaGHOENomSAhGDKgwTEETEIrpfvXbRw7quVthgwTde9uBHEYsppDaGHOENomSAhi6P2c9etFPoKMfaWeNa8JFz)sQiSA)syvKPho9LWQO5Qp6lrxe0csGtr9oDyy1or0tTf(Jp(VMpE)s0Qhob(X3xQdPzRBJttHcdBX9XVSFjqckqwty1(LUCqqONXn5jyhPHvRNfGNXn5PuF98YWwCxb9eFCccTfNNyOENomSA9mkpJBYtAb9Sa8mUjpfDeI2WtmuVthgwTEAaEg3KNcfgE2Q6Cqpf1RHtb5jyhzlopJBd6jgQ3PddR2XxQA(ski4xsGSGqM(Le1c2TyylaHwLpfkuOG0Gw9WjqpzYtm65PdamG9DkNT4GZdNGqBXnrKcY4O34jBS5jwfz6Htd6IGwqcCkQ3PddR2jIEQTqpLNNYoyfpVwpXjahp9cpVwpXONNoaWa23PC2IdopCccTf34PxmHHkKZt2XZthaya77uoBXbNhobH2IBadviNNyYtm9LWQ8o9LWQitpCAaL7mb7inSA)sDinlaGjob4h)Y(Lury1(LWQitpC6lHvrZvF0xIUiOfKaNI6D6WWQDIONAl8hF8l)(49lrRE4e4hFFjbYccz6x60bagI6D6WWQDawT2VKkcR2V0rXnlGzGmHCWF8XpR8X7xIw9WjWp((scKfeY0VKkcdlnPLEgb9uEEkRNm55Pdame170HHv7aSATFjvewTFjUH1wCZt9o)4JFw1pE)s0Qhob(X3xQdPzRBJttHcdBX9XVSFjbYccz6xI9EkQfSBXWwacTkFkuOqbPbT6HtGEYKNIBfHJGEkV2EkRNm55Pdame170HHv7O34jtEYEppDaGbGHiyuO3O34jtEYEppDaGXDftyGivUrVXtM88UIjmqKk3e2qCoCA7eGB4UdpXSNNoaW4M0WwCZEZO34jl98sFPoKMfaWeNa8JFz)sQiSA)sagIMhUcJVeibfiRjSA)s4bwCx9Wt21cqOv5EIbfkuqIzpzq3HHNDi5jlAiYt8Xvya9S1nTEg3eJE2Q2RcpF9vC7Pazb0tDb9S1nTEYIgIGrHEEAqpbRw74hF8ZQ8X7xIw9WjWp((sDinBDBCAkuyylUp(L9lbsqbYAcR2VeEGf3EYUwacTk3tmOqHcsm7jlAiYt8Xvy4zhsEcVRoh0Zd5PccAHvRY5m6POwyGuBjqpHLNXTgEAHNg0ZTcppKNDib6zF5ee6j7Abi0QCpXGcfki5Pb9upvp8mkpPlAme5zH8mUje5PIipFfI8mU11tARoUBpzrdrEIpUcdONr5jDrqlONSRfGqRY9edkuOGKNr5zCtEslONfGNyOENomSAhFPQ5lbP4ljqwqit)sIAb7wmSfGqRYNcfkuqAqRE4e4xcRY70xsfHv7aWq08Wvyme3kchbNaivewTk3tm7jg9eRIm9WPbDrqlibof170HHv7erp1wONSJNNoaWWwacTkFkuOqbPbyhPHvRNyYtw7POkoy1AhagIMhUcJbyhPHv7xQdPzbamXja)4x2VKkcR2Vewfz6HtFjSkAU6J(s0fnKiiWjGHO5HRWa(Jp(zq(49lrRE4e4hFFPQ5lbP4lPIWQ9lHvrME40xQdPzbamXja)4x2Vewfnx9rFPLiqcCcyiAE4kmGFjbYccz6xsuly3IHTaeAv(uOqHcsdA1dNa)sDinBDBCAkuyylUp(L9lHv5D6ljiJ7jg9eRIm9WPbDrqlibof170HHv7erp1wONS2tm65PdamSfGqRYNcfkuqAa2rAy16j74job44Px4jM8et)4JFgUpE)s0Qhob(X3xQdPzRBJttHcdBX9XVSFjbYccz6xsuly3IHTaeAv(uOqHcsdA1dNa9Kjpf3kchb9uET9uwpzYtm6jwfz6Htd6Igsee4eWq08Wvya9uET9eRIm9WPXseibobmenpCfgqpzJnpXQitpCAqxe0csGtr9oDyy1or0tTf6jlB75PdamSfGqRYNcfkuqAa2rAy16jBS55PdamSfGqRYNcfkuqAadviNNS0Zl5jBS55PdamSfGqRYNcfkuqAGONAl0tw6job44Px4jBS5POkoy1AhWBdiSf3SPArObIuqg9KjpvryyPjT0ZiONYRTNyvKPhone170HHv7eEBaHT4Mnvlc5jtEkkS0QBmwd3DmbuYtm5jtEE6aadr9oDyy1o6nEYKNy0t275PdamamebJc9g9gpzJnppDaGHTaeAv(uOqHcsde9uBHEYspV(Gv8etEYKNS3ZthayCxXegisLB0B8KjpVRycdePYnHneNdN2ob4gU7Wtm75PdamUjnSf3S3m6nEYspV0xQdPzbamXja)4x2VKkcR2VeGHO5HRW4hF8l71)49lrRE4e4hFFjvewTFjHY5tvewTtUbJVe3GXC1h9LuryyPzOCAd4p(4xwz)49lrRE4e4hFFPoKMTUnonfkmSf3h)Y(LeiliKPFPthayiQ3PddR2by1A9KjpXQitpCAe2JMrnf170HHvRNSSTNx3tM8eJEYEpr9LakeoAaAqH1WTvrmof17Pl4Gw9WjqpzJnppDaGbObfwd3wfX4uuVNUGJEJNSXMNNoaWa0GcRHBRIyCkQ3txWjaQGXO34jtEgkN2yG6lnlGzt1IqdA1dNa9KjpfvXbRw740baMGguynCBveJtr9E6coqKcYONyYtM8eJEYEpr9LakeoAGdzqoJttyconOvpCc0t2yZtq60bag4qgKZ40eMGtJEJNyYtM8eJEYEpffwA1ngljqfVqGEYgBEkQIdwT2biPX9Pqlnq0tTf6jBS55PdamajnUpfAPrVXtm5jtEIrpvry1oEuqfAy7eGB4UdpzYtvewTJhfuHg2ob4gU7yIONAl0tw22tSkY0dNgI6D6WWQDkuymr0tTf6jBS5PkcR2buuiX9GUGe9WwCEYKNQiSAhqrHe3d6cs0dAIONAl0tw6jwfz6Htdr9oDyy1ofkmMi6P2c9Kn28ufHv7aWq0r58bDbj6HT48Kjpvry1oameDuoFqxqIEqte9uBHEYspXQitpCAiQ3PddR2PqHXerp1wONSXMNQiSAhnmIQdxHXGUGe9WwCEYKNQiSAhnmIQdxHXGUGe9GMi6P2c9KLEIvrME40quVthgwTtHcJjIEQTqpzJnpvry1oa46JGbYKJg0fKOh2IZtM8ufHv7aGRpcgitoAqxqIEqte9uBHEYspXQitpCAiQ3PddR2PqHXerp1wONy6l1H0SaaM4eGF8l7xsfHv7xsuVthgwT)4JFzV0hVFjA1dNa)47lbsqbYAcR2VedlUjKNIQ4GvRf6zCRHNW7QZb98qE2HeONTS42tmuVthgwTEcVRoh0ZA5m65H8SdjqpBzXTN66PkIUY9ed170HHvRNcfgEQlONBfE2YIBpvpL6RNxg2I7kON4JtqOT48SbvIXxsfHv7xsOC(ufHv7KBW4ljqwqit)sNoaWquVthgwTde9uBHEkppzq8Kn28uufhSATdr9oDyy1oq0tTf6jl9Kv(sCdgZvF0xsuVthgwTtrvCWQ1c)Xh)YEnF8(LOvpCc8JVVKazbHm9lHrppDaGXDftyGivUrVXtM8ufHHLM0spJGEkV2EIvrME40quVthgwTtaU(iyGm5ipXKNSXMNy0Zthayayicgf6n6nEYKNQimS0Kw6ze0t512tSkY0dNgI6D6WWQDcW1hbdKjh5j74jQVeqHWrdadrWOqVbT6HtGEIPVKkcR2VeaxFemqMC0p(4xw53hVFjA1dNa)47ljqwqit)sNoaWa23PC2IdopCccTf3erkiJJEJNm55PdamG9DkNT4GZdNGqBXnrKcY4arp1wONYZtHcJzyp6lPIWQ9l1WiQoCfg)4JFzzLpE)s0Qhob(X3xsGSGqM(LoDaGbGHiyuO3O38Lury1(LAyevhUcJF8XVSSQF8(LOvpCc8JVVKazbHm9lD6aaJggrLGRW3O34jtEE6aaJggrLGRW3arp1wONYZtHcJzypYtM8eJEE6aadr9oDyy1oq0tTf6P88uOWyg2J8Kn2880bagI6D6WWQDawTwpXKNm5PkcdlnPLEgb9KLEIvrME40quVthgwTtaU(iyGm5OVKkcR2VudJO6Wvy8Jp(LLv5J3VeT6HtGF89LeiliKPFPthayCxXegisLB0B8KjppDaGHOENomSAh9MVKkcR2VudJO6Wvy8Jp(LLb5J3VeT6HtGF89LeiliKPFPgeHDItaoKDaffsC7jtEE6aaJBsdBXn7nJEJNm5PkcdlnPLEgb9KLEIvrME40quVthgwTtaU(iyGm5OVKkcR2VudJO6Wvy8Jp(LLH7J3VeT6HtGF89Lury1(LG3gqylUzt1IqFjBdcH6nX0a(sQiSAhagIMhUcJH4wr4iyBvewTdadrZdxHX4Pxmf3kchb)scKfeY0V0Pdame170HHv7O34jtEYEpvry1oamenpCfgdXTIWrqpzYtvegwAsl9mc6P8A7jwfz6Htdr9oDyy1oH3gqylUzt1IqEYKNQiSAhn3fT2ftaU(i4aOZ5tejUveoAg2J8uEEc058jIa7IWQ9lbsqbYAcR2Vedp0wCEkDBaHT48u(QweYtWoYwCEIH6D6WWQ1ZO8erWOqKNSOHipXhxHHN6c6P8Dx0Ax4jlY1h5P4wr4iONcD98qEEOLamHPCM980dp7WUY5m6zTCg9SwpV8s(p(Xh)x66F8(LOvpCc8JVVKazbHm9lD6aadr9oDyy1o6nEYKNbsXs8zypYtw65Pdame170HHv7arp1wONm5jg9eJEQIWQDayiAE4kmgIBfHJGEYspL1tM8muoTXOHruj4k8nOvpCc0tM8ufHHLM0spJGE22tz9etEYgBEYEpdLtBmAyevcUcFdA1dNa9Kn28ufHHLM0spJGEkppL1tm5jtEE6aaJBsdBXn7nJEJNy2Z7kMWarQCtydX5WPTtaUH7o8KLEEPVKkcR2VuZDrRDXeGRpc(Jp(VKSF8(LOvpCc8JVVKazbHm9lD6aadr9oDyy1oaRwRNm5POkoy1AhI6D6WWQDGONAl0tw6PqHXmSh5jtEQIWWstAPNrqpLxBpXQitpCAiQ3PddR2jaxFemqMC0xsfHv7xcGRpcgito6hF8FPl9X7xIw9WjWp((scKfeY0V0Pdame170HHv7aSATEYKNIQ4GvRDiQ3PddR2bIEQTqpzPNcfgZWEKNm5j79uuly3IbaxF0ufcefwTdA1dNa)sQiSA)sagIokN)Jp(V018X7xIw9WjWp((scKfeY0V0Pdame170HHv7arp1wONYZtHcJzypYtM880bagI6D6WWQD0B8Kn2880bagI6D6WWQDawTwpzYtrvCWQ1oe170HHv7arp1wONS0tHcJzyp6lPIWQ9lbffsC)Jp(VK87J3VeT6HtGF89LeiliKPFPthayiQ3PddR2bIEQTqpzPN4eGJNEHNm5PkcdlnPLEgb9uEEk7xsfHv7xIByTf38uVZp(4)sSYhVFjA1dNa)47ljqwqit)sNoaWquVthgwTde9uBHEYspXjahp9cpzYZthayiQ3PddR2rV5lPIWQ9lbIuC1cNhePX9p(Xp(syje0Q9J)lD9lj71VKSxZxQLIwBXb)s4bx(Lf)Sl8ZQZqE6jEVjpTxtHcpbkKNxjQ3PddR2zypBXDLNiIb3neb6jSEKNApQNgeONIBDXrWHlddyl5PSmKNyOwSekiqpVkuoTXapVYZO88Qq50gd8CqRE4e4vEIrzVatdxggWwYZRHH8ed1ILqbb65vHYPng45vEgLNxfkN2yGNdA1dNaVYtmk7fyA4YWa2sEYGWqEIHAXsOGa98Qq50gd88kpJYZRcLtBmWZbT6HtGx5jgL9cmnCzyaBjpz4yipXqTyjuqGEEvOCAJbEELNr55vHYPng45Gw9WjWR8eJYEbMgUmmGTKNYkld5jgQflHcc0ZRq9LakeoAGNx5zuEEfQVeqHWrd8CqRE4e4vEIrzVatdxggWwYtzLFmKNyOwSekiqpVkuoTXapVYZO88Qq50gd8CqRE4e4vEIrzVatdxgxg8Gl)YIF2f(z1zip9eV3KN2RPqHNafYZRqvZS5wH0vEIigC3qeONW6rEQ9OEAqGEkU1fhbhUmmGTKNScd5jgQflHcc0ZRcLtBmWZR8mkpVkuoTXaph0QhobELNyu2lW0WLHbSL8KvLH8ed1ILqbb65vO(safchnWZR8mkpVc1xcOq4ObEoOvpCc8kpX4LUatdxgxg8Gl)YIF2f(z1zip9eV3KN2RPqHNafYZRajaTZJR8erm4UHiqpH1J8u7r90Ga9uCRlocoCzyaBjpLLH8ed1ILqbb65vO(safchnWZR8mkpVc1xcOq4ObEoOvpCc8kp1Wt5pdJb8eJYEbMgUmmGTKNxdd5jgQflHcc0ZRcLtBmWZR8mkpVkuoTXaph0QhobELNyu2lW0WLHbSL8u2RHH8ed1ILqbb6PK9WGNqg3qVWtwnwnpJYtgORE(kWoVd9SAiKgfYtmYQHjpXOSxGPHlddyl5PSxdd5jgQflHcc0ZRe1c2TyGNx5zuEELOwWUfd8CqRE4e4vEIrzVatdxggWwYtzzfgYtmulwcfeONxjQfSBXapVYZO88krTGDlg45Gw9WjWR8eJYEbMgUmmGTKNYYQWqEIHAXsOGa98kuFjGcHJg45vEgLNxH6lbuiC0aph0QhobELNyu2lW0WLHbSL8uwgegYtmulwcfeONxH6lbuiC0apVYZO88kuFjGcHJg45Gw9WjWR8eJYEbMgUmmGTKNYYWXqEIHAXsOGa98Qq50gd88kpJYZRcLtBmWZbT6HtGx5jgL9cmnCzyaBjpLLHJH8ed1ILqbb65vO(safchnWZR8mkpVc1xcOq4ObEoOvpCc8kpXOSxGPHlddyl55LUod5jgQflHcc0ZRq9LakeoAGNx5zuEEfQVeqHWrd8CqRE4e4vEIrzVatdxggWwYZlDnmKNyOwSekiqpLShg8eY4g6fEYQ5zuEYaD1tqdRbTA9SAiKgfYtmYAm5jgVMlW0WLHbSL88sxdd5jgQflHcc0tj7HbpHmUHEHNSASAEgLNmqx98vGDEh6z1qinkKNyKvdtEIrzVatdxggWwYZlj)yipXqTyjuqGEEfQVeqHWrd88kpJYZRq9LakeoAGNdA1dNaVYtmk7fyA4YWa2sEEjwHH8ed1ILqbb65vO(safchnWZR8mkpVc1xcOq4ObEoOvpCc8kpXOSxGPHlddyl55LyvyipXqTyjuqGEEvOCAJbEELNr55vHYPng45Gw9WjWR8eJYEbMgUmUm4bx(Lf)Sl8ZQZqE6jEVjpTxtHcpbkKNx1Gir9oACLNiIb3neb6jSEKNApQNgeONIBDXrWHlddyl55LyipXqTyjuqGEEvOCAJbEELNr55vHYPng45Gw9WjWR8udpL)mmgWtmk7fyA4YWa2sEEnmKNyOwSekiqpVkuoTXapVYZO88Qq50gd8CqRE4e4vEIrzVatdxggWwYZRHH8ed1ILqbb65vHYPng45vEgLNxfkN2yGNdA1dNaVYtn8u(ZWyapXOSxGPHlddyl5P8JH8ed1ILqbb65vHYPng45vEgLNxfkN2yGNdA1dNaVYtmk7fyA4YWa2sEk)yipXqTyjuqGEEvOCAJbEELNr55vHYPng45Gw9WjWR8udpL)mmgWtmk7fyA4YWa2sEYkmKNyOwSekiqpVkuoTXapVYZO88Qq50gd8CqRE4e4vEIrzVatdxggWwYtwHH8ed1ILqbb65vHYPng45vEgLNxfkN2yGNdA1dNaVYtn8u(ZWyapXOSxGPHlddyl5jRkd5jgQflHcc0ZRcLtBmWZR8mkpVkuoTXaph0QhobELNyu2lW0WLHbSL8KvLH8ed1ILqbb65vHYPng45vEgLNxfkN2yGNdA1dNaVYtn8u(ZWyapXOSxGPHlddyl5PSmCmKNyOwSekiqpVkuoTXapVYZO88Qq50gd8CqRE4e4vEQHNYFggd4jgL9cmnCzCzWdU8ll(zx4NvNH80t8EtEAVMcfEcuipVsuVthgwTtrvCWQ1cVYteXG7gIa9ewpYtTh1tdc0tXTU4i4WLHbSL8KvLH8ed1ILqbb65vO(safchnWZR8mkpVc1xcOq4ObEoOvpCc8kpXOSxGPHlJldEWLFzXp7c)S6mKNEI3BYt71uOWtGc55vQimS0muoTb8kpredUBic0ty9ip1Eupniqpf36IJGdxggWwYZlXqEIHAXsOGa98Qq50gd88kpJYZRcLtBmWZbT6HtGx5jgV0fyA4YWa2sEEnmKNyOwSekiqpVkuoTXapVYZO88Qq50gd8CqRE4e4vEIrzVatdxgxg8Gl)YIF2f(z1zip9eV3KN2RPqHNafYZRGHUGkcCIQqdR2R8erm4UHiqpH1J8u7r90Ga9uCRlocoCzyaBjpzfgYtmulwcfeONxfkN2yGNx5zuEEvOCAJbEoOvpCc8kpXOSxGPHlddyl5jdcd5jgQflHcc0ZRq9LakeoAGNx5zuEEfQVeqHWrd8CqRE4e4vEIXlDbMgUmmGTKNYEDgYtmulwcfeONxfkN2yGNx5zuEEvOCAJbEoOvpCc8kpXOSxGPHlJldEWLFzXp7c)S6mKNEI3BYt71uOWtGc55vI6D6WWQD2CRq6kpredUBic0ty9ip1Eupniqpf36IJGdxggWwYZlXqEIHAXsOGa98krTGDlg45vEgLNxjQfSBXaph0QhobELNA4P8NHXaEIrzVatdxggWwYZRHH8ed1ILqbb65vIAb7wmWZR8mkpVsuly3IbEoOvpCc8kpXOSxGPHlddyl5jRkd5jgQflHcc0ZRe1c2TyGNx5zuEELOwWUfd8CqRE4e4vEIrzVatdxggWwYtwfgYtmulwcfeONs2ddEczCd9cpz18mkpzGU6jOH1GwTEwnesJc5jgznM8eJYEbMgUmmGTKNSkmKNyOwSekiqpVsuly3IbEELNr55vIAb7wmWZbT6HtGx5PgEk)zymGNyu2lW0WLHbSL8KbHH8ed1ILqbb6PK9WGNqg3qVWtwnpJYtgOREcAynOvRNvdH0OqEIrwJjpXOSxGPHlddyl5jdcd5jgQflHcc0ZRe1c2TyGNx5zuEELOwWUfd8CqRE4e4vEQHNYFggd4jgL9cmnCzyaBjpz4yipXqTyjuqGEELOwWUfd88kpJYZRe1c2TyGNdA1dNaVYtmk7fyA4YWa2sEkRSmKNyOwSekiqpVkuoTXapVYZO88Qq50gd8CqRE4e4vEIrzVatdxggWwYtzLLH8ed1ILqbb65vO(safchnWZR8mkpVc1xcOq4ObEoOvpCc8kpX4LUatdxggWwYtzVggYtmulwcfeONxH6lbuiC0apVYZO88kuFjGcHJg45Gw9WjWR8eJYEbMgUmmGTKNx66mKNyOwSekiqpVkuoTXapVYZO88Qq50gd8CqRE4e4vEIXlDbMgUmmGTKNx6smKNyOwSekiqpVsuly3IbEELNr55vIAb7wmWZbT6HtGx5PgEk)zymGNyu2lW0WLXLHD9AkuqGEYG4PkcRwp5gmGdxMVeSHeF8ZQEnFPgubyC6lXcSGNSOHipVmvCKldlWcEEhrdKHynRXzXD)me1J1q715Ay1kqkqWAO9eS2LHfybpVmvK42twfM98sx)sY6Y4YWcSGNy4wxCeKHCzybwWt2XtgEi5jGH7oMi6P2c9ePXnH8mU11Zqr4Oye2JMrnbnYtGc5jxHb7ajrTGEQhJBbJE2HkocoCzybwWt2XtgOkiTEkuy4jIyWDdrpAdONafYtmuVthgwTEIrBqdM9eS2RcpVloONw4jqH8u9earWBpVmPGkKNcfgyA4YWcSGNSJNY)vpCYtyGmr4P4MeYzlopR1t1taQLNafsoON26zCtEE5Yhd4zuEIiWUG8SvHKJxk4WLHfybpzhpVCqg0Dy4P6P8XiQoCfgEsBGy0Z4wdpblc65wHNVcK4E2I4CpTLDWPpYtmcTNNbbdc0tn8ClpHgU1amHUHN4r5tYt71OIatdxgwGf8KD8ed1ILqHNkN75PdamWZbIur4jTbYiONr55PdamWZrVHzp11tL)ky4PTqd3AaMq3Wt8O8j5jo1wpT1tO9GdxgxgwGf8u(Fbj6bb65Hake5POEhn88q4Sfo88YfcQjGEU1Yo3k6b05EQIWQf6zTCghUmQiSAHJgejQ3rdm3M1ksOlnTnioNeHldlWcEE5Yhd4j7wrME4KNmSMWQLH8KDb4jKcpJYt1ZTw2HbfcvEIv5DIzpJBYtmuVthgwTEQIWQ1tDb9uufhSATqpJBn8urKNIAHbsTLa9mkpRLZONhYZoKa9S1nTEIH6D6WWQ1td6zVXZwgN75wHNhYZoKa9eSJSfNNXn5j0EDUgwTdxgwGf8ufHvlC0Gir9oAG52SgRIm9WjMx9rTbnOE40uuVthgwTmxnTreKcxgwWZlx(yapz3kY0dN8KH1ewTmKN492GEIvrME4KNWgsyagb9S1nf3eYtmuVthgwTEcVRoh0Zd5zhsGEc2r2IZtw0qemuuqOHlJkcRw4ObrI6D0aZTznwfz6HtmV6JAdyicgkki0uuVthgwTmBaTXQitpCAayicgkki0uuVthgwTS86mJv5DQTSxl7dLtBmAyevcUcFmJv5DAsCi1MDK1LHf88YLpgWt2TIm9WjpzynHvld5jEVnONyvKPho5jSHegGrqpJBYZT)oeYZcWZqr4Oa6PgE262e3EIhwHNsbIu58Kf56JGbYKJGEw9aAGKNfGNyOENomSA9eExDoONhYZoKahUmQiSAHJgejQ3rdm3M1yvKPhoX8QpQ9DftyGivUjaxFemqMCeZvtBifmBaTXQitpCACxXegisLBcW1hbdKjh1(6mJv5DQ9LU2q50gdaU(OzJgIBmFnxl7dLtBma46JMnAiUDzybpVC5Jb8KDRitpCYtgwty1YqEI3Bd6jwfz6HtEcBiHbye0Z4M8C7VdH8Sa8mueokGEQHNTUnXTN4Hkc0tmOWWtwKRpcgitoc6z1dObsEwaEIH6D6WWQ1t4D15GEEip7qc0tf6jGX5eA4YOIWQfoAqKOEhnWCBwJvrME4eZR(O23kcCkuymb46JGbYKJyUAAdPGzdOnwfz6HtJBfbofkmMaC9rWazYrTVoZyvENAFPRnuoTXaGRpA2OH4gZxZ1Y(q50gdaU(OzJgIBxgwWZlx(yapz3kY0dN8KH1ewTmKN492GEIvrME4KNWgsyagb9mUjp3(7qiplapdfHJcONA4zRBtC7jEyfEkfisLZtwKRpcgitoc6PIip7qc0tWoYwCEIH6D6WWQD4YOIWQfoAqKOEhnWCBwJvrME4eZR(O2I6D6WWQDcW1hbdKjhXC10gsbZgqBSkY0dNgI6D6WWQDcW1hbdKjh1(6mJv5DQ91CTHYPngaC9rZgne3yMv9AzFOCAJbaxF0SrdXTldl45LlFmGNSBfz6HtEYWAcRwgYt8EBqpXQitpCYtydjmaJGEg3KNB)DiKNfGNHIWrb0tn8S1TjU98YrcDjpL)x0WlOvRNvpGgi5zb4jgQ3PddRwpH3vNd65H8SdjWHlJkcRw4ObrI6D0aZTznwfz6HtmV6JARiHU0KUOHxqRwMRM2qky2aAJvrME40qrcDPjDrdVGwTTVoZyvENAZWXWDTHYPngaC9rZgne3y(sxl7dLtBma46JMnAiUDzybpVC5Jb8KDRitpCYtgwty1YqEI3Bd6jwfz6HtEcBiHbye0Z4M8SHqcAdfh5zb45tx1ZdXRwE262e3EE5iHUKNY)lA4f0Q1ZwgN75wHNhYZoKahUmQiSAHJgejQ3rdm3M1yvKPhoX8QpQTIe6st6IgEbTANpDvMbjaTZJ2YVRZC10grqkCzybpVC5Jb8KDRitpCYtgwty1YqEIhyXTNxg2cYTfhZEIH6D6WWQ9kONIQ4GvR1ZwgN75H8erGDbb65Hrpvpr6cwpp1x13Gzpp9WZ4M8C7VdH8Sa8uGSa6jmuua9elHy0ZBd3TNkqqipvryy1WwCEIH6D6WWQ1tDb9eYRwqpbRwRNr1srGqpJBYtAb9Sa8ed170HHv7vqpfvXbRw7Wt8GBA98PYzlopbjHbTAHEARNXn55LlFmaZEIH6D6WWQ9kONi6P2AlopfvXbRwRNg0teb2feONhg9mUnONaivewTEgLNQqu9n8eOqEEzyli3wCdxgvewTWrdIe17ObMBZASkY0dNyE1h1woBb52IBIiWUiSAzgKa0opAF9H8J5QPnIGu4YWcEE5Yhd4j7wrME4KNmSMWQLH8eV3KNB)DiKNfGNHIWrb0tPBdiSfNNYx1IqEcVRoh0Zd5zhsGEwRNGDKT48ed170HHv7WLrfHvlC0Gir9oAG52SgRIm9WjMx9rTf170HHv7eEBaHT4MnvlcXmibODE0(smxnTreKcxgwWZlx(yapz3kY0dN8KH1ewTmKN49M8mSh5jIEQT2IZZA9u9uOWWZw306jgQ3PddRwpf665H8SdjqpT1tijQfeoCzury1chnisuVJgyUnRXQitpCI5vFuBr9oDyy1ofkmMi6P2czgKa0opAF9bRcZvtBebPWLHf88YLpgWt2TIm9WjpzynHvld5jEVnONyvKPho5jSHegGrqpJBYZT)oeYZcWtijQfe6zb4jlAiYt8Xvy4zCRHNW7QZb98qE2ufNa9SrHHNXn5jibODE4P(Q(gdxgvewTWrdIe17ObMBZASkY0dNyE1h1UWsOMQ4tadrZdxHbKzqcq78O91zUAAJiifUmSGNxU8XaEYUvKPho5jdRjSAzipXdRwEYRfNNhcOqKNyOENomSA9eExDoONY)xdJis5EYWqGRUcYZd5zhsGmO6YOIWQfoAqKOEhnWCBwJvrME4eZR(O20RHreP8zHaxDf0eK4kJmdsaANhTLLbH5QPnIGu4YWcEYUa8ed170HHvRNg0tqdQhobYSNqXnb25KNXn5jGHGHNyOENomSA9eqrEQabH8mUjpbmC3HN0cchUmQiSAHJgejQ3rdm3M1yvKPhoX8QpQDypAg1uuVthgwTmJv5DQnGH7oMi6P2cXSSx)6mBaTXQitpCAaAq9WPPOENomSADzybpX7n5jyhPHvRNfGNQNs91ZldBXDf0t8Xji0wCEIH6D6WWQD4YOIWQfoAqKOEhnWCBwJvrME4eZR(O2q5otWosdRwMRM2qkygRY7uBwXLHf8ep4MIBc5P6zhQho5Pf0ZZoKa9mkppDaapXq9oDyy16Pb9KyWDRPHahUmQiSAHJgejQ3rdm3M1yvKPhoX8QpQTOENomSAN1o7qI5QPnKcMXQ8o1MyWDRPHah44kOPrHGZJcIJyJnIb3TMgcC8uHEq0eEtumFDOjyJnIb3TMgcCyluG6HE40Kb31n6VjiH1eeBSrm4U10qGdyFp8QaN6JIBgHbBSrm4U10qGd61WiIu(SqGRUcIn2igC3AAiWbaxF0SaMhncoXgBedUBnne4OLkhTecobq1cYgBedUBnne4WwyG6IOqWjOH1wAEio3LHf8epSA5jVwCEEiGcrEIH6D6WWQ1t4D15GEgiBLJcONXTgEgidhoc5P6j8wreONcniCfIrpfvXbRwRN16zf3eYZazRCua9CRWZd5zhsGmO6YOIWQfoAqKOEhnWCBwJvrME4eZR(O21o7qAk6rbaWC10gsbZyvENAFPRZSb0gRIm9WPHOENomSAN1o7qYLrfHvlC0Gir9oAG52SgRIm9WjMx9rTRD2H0u0JcaG5QPnKcMXQ8o1(sScZgqBIb3TMgcC8uHEq0eEtumFDOjCzury1chnisuVJgyUnRXQitpCI5vFu7ANDinf9OaayUAAdPGzSkVtTV01Xmwfz6Htd61WiIu(SqGRUcAcsCLrMnG2edUBnne4GEnmIiLple4QRGCzury1chnisuVJgyUnR7qAAb9yE1h1gwD(0WTwqiMnG2ShRIm9WPHOENomSAN1o7qIj2tm4U10qGdqePGagIMyjiK4mX(q50gdadrWqrbHCzury1chnisuVJgyUnRFgcvOP9uCKlJkcRw4ObrI6D0aZTzDdJO6WvyWSb0M9nic7OHruD4kmCzCzybwWt5)fKOheONewcXONH9ipJBYtvefYtd6PIvnUE40WLrfHvlSTO6BqiydX5mBaTzpQVeqHWrdqdkSgUTkIXPOEpDbDzybpX7n5POENomSANH9SfNNQiSA9KBWWtO4Ma7Cc6zRBA9ed170HHvRNTmo3Zd5zhsGEQlONWOqe0Z4M8erWop80wpXQitpCAe2JMrnf170HHv7WLrfHvleZTzTq58PkcR2j3GbZR(O2I6D6WWQDg2ZwCUmSGNSBfz6HtEg3A4jbd7Pbb9S1nf3eYtPBdiSfNNYx1IqE2Y4CppKNDib65Hake5jgQ3PddRwpnONisbzC4YOIWQfI52SgRIm9WjMx9rTH3gqylUzt1IqZdbuiAkQ3PddRwMRM2qkygRY7uBmQIWWstAPNrqwIvrME40quVthgwTt4Tbe2IB2uTieBSPIWWstAPNrqwIvrME40quVthgwTtaU(iyGm5i2ydRIm9WPrypAg1uuVthgwTSJkcR2b82acBXnBQweAa058jIa7IWQvEIQ4GvRDaVnGWwCZMQfHgGDKgwTyIjSkY0dNgH9Ozutr9oDyy1YoIQ4GvRDaVnGWwCZMQfHgi6P2cLNkcR2b82acBXnBQweAa058jIa7IWQLjmkQIdwT2bQV0SaMnvlcnq0tTfYoIQ4GvRDaVnGWwCZMQfHgi6P2cLhRWgBSpuoTXa1xAwaZMQfHWKlJkcRwiMBZA4Tbe2IB2uTieZgq7thayiQ3PddR2by1AzsfHv7aWq08Wvyme3kchbzzBzzI9y80bag2cqOv5tHcfkin6nmD6aaJ7kMWarQCdePIatmHvrME40aEBaHT4MnvlcnpeqHOPOENomSADzury1cXCBwJuqt3ycBuKCmBaTpDaGHOENomSAhGvRLjmIvrME40iShnJAkQ3PddRwwIvrME40quVthgwTZgejuymd7ryMUGe9GMH9i2ydRIm9WPrypAg1uuVthgwTYtufhSATSJSxhtUmQiSAHyUnRbjnUpfAjMnG2NoaWquVthgwTdWQ1Y0Pdamq9LMfWSPArOby1AzcRIm9WPrypAg1uuVthgwTSeRIm9WPHOENomSANnisOWyg2JWmDbj6bnd7rUmQiSAHyUnRFgcvi4SaMrHE0gmBaTXQitpCAe2JMrnf170HHvllXQitpCAiQ3PddR2zdIekmMH9imtxqIEqZWEetNoaWquVthgwTdWQ16YWcEYIfYt2nTXnJiM9SdjpvpzrdrEIpUcdpf3kch5jyhzlopVmneQqqplapXBHE0gEkuy4zuEQyld0tH20ylopf3kchbhUmQiSAHyUnRbmenpCfgm3H0S1TXPPqHHT4AllZgqBvewTJNHqfcolGzuOhTXGUGe9WwCmb058jIe3kchnd7rSJkcR2XZqOcbNfWmk0J2yqxqIEqte9uBHSu(Xe7VRycdePYnHneNdN2ob4gU7Gj2F6aaJ7kMWarQCJEJlJkcRwiMBZ6oKMwqpMjaaseZvFuBCCf00OqW5rbXrmBaTXQitpCAe2JMrnf170HHvR8evXbRwl7WkUmQiSAHyUnR7qAAb9yE1h1MEnmIiLple4QRGy2aAJvrME40iShnJAkQ3PddRww2gRIm9WPb9AyerkFwiWvxbnbjUYityvKPhonc7rZOMI6D6WWQvEyvKPhonOxdJis5ZcbU6kOjiXvgzhwXLrfHvleZTzDhstlOhZR(O244m2CplGPcH2Z4Ay1YSb0gRIm9WPrypAg1uuVthgwTYRnwfz6HtJANDinf9OaaCzury1cXCBw3H00c6X8QpQ9tf6brt4nrX81HMGzdOnwfz6HtJWE0mQPOENomSAzzBwXLHf8KDb4zhAlopvpHbHkd0ZAzNoK80c6XSNkVLYi0ZoK8epIifeWqKNSBccjUNvpGgi5zb4jgQ3PddR2HNmS4MqTmiXSNniRqwymOqE2H2IZt8iIuqadrEYUjiK4E2YIBpXq9oDyy16zTCg90a8KDTaeAvUNyqHcfK80GEsRE4eON6c6P6zhQ4ipBv7vHNhYtEbdplSeYZ4M8eSJ0WQ1ZcWZ4M8eWWDhdpX7Tb9ubbHEQEcFkN7jwL3jpJYZ4M8uufhSATEwaEIhrKccyiYt2nbHe3Zw306jyzlopJBd6Pq5IoxdRwppKq7qYtl80GE2xePCyycpJYtfc7pYZ4wdpTWZwgN75H8SdjqpBieajcoJEwRNIQ4GvRD4YOIWQfI52SUdPPf0J5vFuBqePGagIMyjiK4mBaTXQitpCAe2JMrnf170HHvR8AJvrME40O2zhstrpkaaMW4PdamSfGqRYNcfkuqAadvix7thayylaHwLpfkuOG04PxmHHkKJn2yVOwWUfdBbi0Q8PqHcfKyJnSkY0dNgI6D6WWQDw7Sdj2ydRIm9WPrypAg1uuVthgwTYZ2GqnfxdcCcy4UJjIEQTqwnwnmkQIdwTwml71XeMCzybpLQo3t2fU1cc5j8U6CqppKNDib6PTEQE2sz0Z4wdpblcUxfEABqiacrE2YIBpR4MqEwl70HKNbYw5Oao8KHf3eYZazRCua9eS8CRWZaz4WripvpH3kIa9KDHb8ON16Pfm7jS80cpf665H8SdjqprgU7WtfiiKN6YONvCtipRLD6qYZazRCumCzury1cXCBw3H00c6X8QpQnS68PHBTGqmBaTXQitpCAe2JMrnf170HHvR8AFnx)AXiwfz6HtJANDinf9OaaK31XetyK9edUBnne4aerkiGHOjwccjoBSjQIdwT2biIuqadrtSees8bIEQTq5XkyYLHfybpXp1YtPQZ9KDHBTGqEsBGyKzpre3iON16j8wreONwqppXaE0tBbk0tdRwpJBn80GEUv4jJu4jS30uOGahE65LLA4QGGEg3KNnicRvDONCBjpBDtRNa9vewTkF4YWcSGNQiSAHyUnR7qAAb9yE1h1gwD(0WTwqiMnG2yeRIm9WPrypAg1uuVthgwTYR91C9RfJyvKPhonQD2H0u0JcaqExhtSXMOkoy1AhwqVPaCkRSYpzhi6P2cXetyK9edUBnne4aerkiGHOjwccjoBSjQIdwT2biIuqadrtSees851i)KFSkxZLgi6P2cLhRGjxgwWt8ImC4iKNsvN7j7c3AbH8KueNrpBzXTNSRfGqRY9edkuOGKNfYZw306PfE2sHE2GiHcJHlJkcRwiMBZAHUcIppDaaMx9rTHvNpnCRfwTmBaTzVOwWUfdBbi0Q8PqHcfKykShXswHn2oDaGHTaeAv(uOqHcsdyOc5AF6aadBbi0Q8PqHcfKgp9IjmuHCUmSGNSRGEqpJBn8eS8CRWZdTeGfEIH6D6WWQ1t4D15GEYGUddppKNDib6z1dObsEwaEIH6D6WWQ1tn8ewpYZMY2y4YOIWQfI52SUdPPf0dYSb0gRIm9WPrypAg1uuVthgwTYRnwfz6HtJANDinf9OaaCzybpz4HKNSiQGHN4VWQEgLNbYWHJqEYQJmiNrpzxctWPHlJkcRwiMBZAaubJ5wyvMnG2O(safchnWHmiNXPjmbNy60bagI6D6WWQDawTwMWiwfz6HtJWE0mQPOENomSALNOkoy1AzJnSkY0dNgH9Ozutr9oDyy1YsSkY0dNgI6D6WWQD2GiHcJzypcZ0fKOh0mShHjxgwWtwDk8mUjpXJguynCBveJEIH690f0ZthaWZEdZE2xobHEkQ3PddRwpnONWQ2HlJkcRwiMBZAr13GqWgIZz2aAJ6lbuiC0a0GcRHBRIyCkQ3txqMevXbRw740baMGguynCBveJtr9E6coq0tTfYsvewTdaubJtXJHqHXmShX0PdamanOWA42QigNI690fCQiHU0aSATmX(thayaAqH1WTvrmof17Pl4O3WegXQitpCAe2JMrnf170HHvR8evXbRw740baMGguynCBveJtr9E6coa7inSAzJnSkY0dNgH9Ozutr9oDyy1YswbtUmQiSAHyUnRvKqxAsx0WlOvlZgqBuFjGcHJgGguynCBveJtr9E6cYKOkoy1AhNoaWe0GcRHBRIyCkQ3txWbIEQTqwsxqIEqZWEeMvry1oaqfmofpgcfgZWEetNoaWa0GcRHBRIyCkQ3txWPIe6sdWQ1Ye7pDaGbObfwd3wfX4uuVNUGJEdtyeRIm9WPrypAg1uuVthgwTYtufhSATJthaycAqH1WTvrmof17Pl4aSJ0WQLn2WQitpCAe2JMrnf170HHvllzfMyFOCAJbQV0SaMnvlcHjxgvewTqm3M1aOcgNIhmBaTr9LakeoAaAqH1WTvrmof17PlitIQ4GvRDC6aatqdkSgUTkIXPOEpDbhi6P2czPqHXmShX0PdamanOWA42QigNI690fCcGkymaRwltS)0bagGguynCBveJtr9E6co6nmHrSkY0dNgH9Ozutr9oDyy1kprvCWQ1ooDaGjObfwd3wfX4uuVNUGdWosdRw2ydRIm9WPrypAg1uuVthgwTSKvWKlJkcRwiMBZAHY5tvewTtUbdMx9rTf170HHv7S5wHeZgqBSkY0dNgH9Ozutr9oDyy1YY2xNn2WQitpCAe2JMrnf170HHvllXQitpCAiQ3PddR2zdIekmMH9iMevXbRw7quVthgwTde9uBHSeRIm9WPHOENomSANnisOWyg2JCzury1cXCBwJ6lnlGzt1IqmBaTpDaGbQV0SaMnvlcnaRwltS)0bagagIGrHEJEdtyeRIm9WPrypAg1uuVthgwTYR9Pdamq9LMfWSPArObyhPHvltyvKPhonc7rZOMI6D6WWQvEQiSAhagIMhUcJbqNZNisCRiC0mShXgByvKPhonc7rZOMI6D6WWQvEagU7yIONAletUmSGNYxvCpvONpDz0tw0qKN4JRWa6Pc9SPGq7WjpbkKNyOENomSAhEk1pbsfHNvp8Sa8mUjpbqQiSAvUNI61ulTHNfGNXn552Fhc5zb4jlAiYt8Xvya9mU1WZwgN75QrhPCoJEIiXTIWrEc2r2IZZ4M8ed170HHvRNn3kK88qcTdjpBQIBlop1LX42wCE2OWWZ4wdpBzCUNBfEIdPB4PUEsxei1tw0qKN4JRWWtWoYwCEIH6D6WWQD4YOIWQfI52SgRIm9WjM7qAwaatCcW2YYChsZw3gNMcfg2IRTSmV6JAdyiAE4kmMnvXTfhZyvENARIWQDayiAE4kmgIBfHJGtaKkcRwLJzmIvrME40iShnJAkQ3PddRwmRIWQDaVnGWwCZMQfHgaDoFIiWUiSAVwSkY0dNgWBdiSf3SPArO5Hakenf170HHvlMy1evXbRw7aWq08Wvyma7inSAzhzzPOkoy1AhagIMhUcJXtVykUveocIzSkY0dNgfwc1ufFcyiAE4kmGSAIQ4GvRDayiAE4kmgGDKgwTSdgpDaGHOENomSAhGDKgwTSAIQ4GvRDayiAE4kmgGDKgwTyIvJvtwMWQitpCAe2JMrnf170HHvllbmC3Xerp1wOldl4j7wrME4KNXTgEkQnqfh6P8Dx0Ax4jlY1hb9SdvCKNr5jTWoI80cONIBfHJGEQiYZMQ4eONafYtmuVthgwTdpzylNrp7qYt57UO1UWtwKRpc6z1dObsEwaEIH6D6WWQ1Zw306jqNZ9uCRiCe0tHUEEipRtO2sGEc2r2IZZ4M8CPlcpXq9oDyy1oCzury1cXCBwJvrME4eZR(O2n3fT2fZMQ42IJzdOTkcdlnPLEgbzjwfz6Htdr9oDyy1ob46JGbYKJygRY7uBSkY0dNgH9Ozutr9oDyy1I5thayiQ3PddR2byhPHvl7WkSufHv7O5UO1UycW1hbhaDoFIiXTIWrZWEeMfvXbRw7O5UO1UycW1hbhGDKgwTSJkcR2b82acBXnBQweAa058jIa7IWQ9AXQitpCAaVnGWwCZMQfHMhcOq0uuVthgwTmHvrME40iShnJAkQ3PddRwwcy4UJjIEQTq2yd1xcOq4ObSVt5SfhCE4eeAlo2ylShXswXLHf8ep4Mwp7qBX5jlY1hbdKjh5PTEIH6D6WWQLzpHkwYtf65txg9uCRiCe0tf6ztbH2HtEcuipXq9oDyy16zllURE4PqBASf3WLrfHvleZTznwfz6HtmV6JA3Cx0AxmBQIBloMnG2QimS0Kw6zeuETXQitpCAiQ3PddR2jaxFemqMCeZyvENAJvrME40iShnJAkQ3PddRwwQIWQD0Cx0Axmb46JGdGoNprK4wr4OzypIDury1oG3gqylUzt1IqdGoNpreyxewTxlwfz6Htd4Tbe2IB2uTi08qafIMI6D6WWQLjSkY0dNgH9Ozutr9oDyy1Ysad3Dmr0tTfYgBO(safchnG9DkNT4GZdNGqBXXgBH9iwYkUmQiSAHyUnRfkNpvry1o5gmyE1h1gvnZMBfsmddKjI2YYSb0(0bagO(sZcy2uTi0O3Wewfz6HtJWE0mQPOENomSAL31DzybpVCqg0Dy4zCtEIvrME4KNXTgEkQnqfh6jlAiYt8Xvy4zhQ4ipJYtAHDe5Pfqpf3kchb9urKNkhwE2ufNa9eOqEEz7l5zb4P8vTi0WLrfHvleZTznwfz6Htm3H0SaaM4eGTLL5oKMTUnonfkmSfxBzzE1h1gWq08WvymBQIBloMRM2qkygRY7uBrvCWQ1oq9LMfWSPArObIEQTqwQIWQDayiAE4kmgaDoFIiXTIWrZWEe7OIWQDaVnGWwCZMQfHgaDoFIiWUiSAVwmIvrME40aEBaHT4MnvlcnpeqHOPOENomSAzsufhSATd4Tbe2IB2uTi0arp1wilfvXbRw7a1xAwaZMQfHgi6P2cXetIQ4GvRDG6lnlGzt1Iqde9uBHSeWWDhte9uBHmBaTzpwfz6HtdadrZdxHXSPkUT4ykuoTXa1xAwaZMQfHy60bagO(sZcy2uTi0aSATUmSGN4b306jEOIafkmSfNNSixFKNsbYKJy2tw0qKN4JRWa6j8U6CqppKNDib6zuEIJwcPb5jEyfEkfisLd6PUGEgLN0fbTGEIpUcdc55LPcdcnCzury1cXCBwdyiAE4kmyUdPzbamXjaBllZDinBDBCAkuyylU2YYSb0M9yvKPhonamenpCfgZMQ42IJjSkY0dNgH9Ozutr9oDyy1kVRZKkcdlnPLEgbLxBSkY0dNg3kcCkuymb46JGbYKJyI9agIGHIccnuryyjMy)PdamURycdePYn6nmHXthayCtAylUzVz0BysfHv7aGRpcgitoAqxqIEqte9uBHS86dwHn2e3kchbNaivewTkxETVeMCzybpXJDKT48KfnebdffeIzpzrdrEIpUcdONkI8SdjqpH2Z4kIZONr5jyhzlopXq9oDyy1o8KvNwcPCoJm7zCtm6PIip7qc0ZO8ehTesdYt8Wk8ukqKkh0Zw306Pazb0ZwgN75wHNhYZwkmiqp1f0ZwwC7j(4kmiKNxMkmieZEg3eJEcVRoh0Zd5jSbrkONvp8mkpFQTHARNXn5j(4kmiKNxMkmiKNNoaWWLrfHvleZTznGHO5HRWG5oKMfaWeNaSTSm3H0S1TXPPqHHT4AllZgqBadrWqrbHgQimSetIBfHJGYRTSmXESkY0dNgagIMhUcJztvCBXXegzVkcR2bGHOJY5d6cs0dBXXe7vry1oAyevhUcJHTtaUH7oy60bag3Kg2IB2Bg9g2ytfHv7aWq0r58bDbj6HT4yI9NoaW4UIjmqKk3O3WgBQiSAhnmIQdxHXW2ja3WDhmD6aaJBsdBXn7nJEdtS)0bag3vmHbIu5g9gm5YWcEE5yld0tH20ylopzrdrEIpUcdpf3kchb9S1TXjpf36Ue3wCEkDBaHT48u(QweYLrfHvleZTznGHO5HRWG5oKMTUnonfkmSfxBzz2aARIWQDaVnGWwCZMQfHg0fKOh2IJjGoNprK4wr4OzypILQiSAhWBdiSf3SPArOryc5MicSlcRwMoDaGXDftyGivUby1AzkShjpzVUlJkcRwiMBZAHY5tvewTtUbdMx9rTHHUGkcCIQqdRwMnG2yvKPhonc7rZOMI6D6WWQvExNPthayG6lnlGzt1IqdWQ16YOIWQfI52SgkkK42LXLrfHvlCOIWWsZq50gW2CdRT4MN6Dy2aARIWWstAPNrq5jltNoaWquVthgwTdWQ1YegXQitpCAe2JMrnf170HHvR8evXbRw7GByTf38uVZaSJ0WQLn2WQitpCAe2JMrnf170HHvllBFDm5YOIWQfouryyPzOCAdiMBZ6hfuHy2aAJvrME40iShnJAkQ3PddRww2(6SXggfvXbRw74rbvObyhPHvllXQitpCAe2JMrnf170HHvltSpuoTXa1xAwaZMQfHWeBSfkN2yG6lnlGzt1IqmD6aaduFPzbmBQweA0BycRIm9WPrypAg1uuVthgwTYtfHv74rbvOHOkoy1AzJnad3Dmr0tTfYsSkY0dNgH9Ozutr9oDyy16YOIWQfouryyPzOCAdiMBZAqKIRw48GinUz2aAhkN2yOC6cyGuidkkCc0rmYegpDaGHOENomSAhGvRLj2F6aaJ7kMWarQCJEdMCzCzury1chI6D6WWQDkQIdwTwy7MkSADzury1chI6D6WWQDkQIdwTwiMBZ6dVkWjqhXOlJkcRw4quVthgwTtrvCWQ1cXCBwFieKqYzloMnG2NoaWquVthgwTJEJlJkcRw4quVthgwTtrvCWQ1cXCBwdyi6WRc0LrfHvlCiQ3PddR2POkoy1AHyUnR1vqWaP8Pq5CxgvewTWHOENomSANIQ4GvRfI52SoShnBPOgMnG2O(safchnc61uiLpBPOgMoDaGbDXT2HHv7O34YOIWQfoe170HHv7uufhSATqm3M1DinTGEmtaaKiMR(O244kOPrHGZJcIJCzury1chI6D6WWQDkQIdwTwiMBZ6oKMwqpMx9rTTfkq9qpCAYG76g93eKWAcYLrfHvlCiQ3PddR2POkoy1AHyUnR7qAAb9yE1h1gGRpAwaZJgbNCzury1chI6D6WWQDkQIdwTwiMBZ6oKMwqpMx9rTBPYrlHGtauTGUmQiSAHdr9oDyy1ofvXbRwleZTzDhstlOhZR(O22cduxefcobnS2sZdX5UmQiSAHdr9oDyy1ofvXbRwleZTzDhstlOhZR(O2W(E4vbo1hf3mcdxgvewTWHOENomSANIQ4GvRfI52SUdPPf0d6Y4YOIWQfoe170HHv7S5wHuBUH7oGtg0DqCpAdMnG2NoaWquVthgwTdWQ16YWcEk)HH90G88UA5jVwCEIH6D6WWQ1ZwgN7jxHHNXTUYb9mkpL6RNxg2I7kON4JtqOT48mkpbPGqpBjpVRwEYIgI8eFCfgqpH3vNd65H8SdjWHlJkcRw4quVthgwTZMBfsyUnRXQitpCI5oKMfaWeNaSTSm3H0S1TXPPqHHT4AllZR(O20fbTGe4uuVthgwTte9uBHmxnTHuWmwL3P2NoaWquVthgwTde9uBHy(0bagI6D6WWQDa2rAy1ETyuufhSATdr9oDyy1oq0tTfYYthayiQ3PddR2bIEQTqmXSb0wuly3IHTaeAv(uOqHcsUmSGNxoii0Z4M8eSJ0WQ1ZcWZ4M8uQVEEzylURGEIpobH2IZtmuVthgwTEgLNXn5jTGEwaEg3KNIocrB4jgQ3PddRwpnapJBYtHcdpBvDoONI61WPG8eSJSfNNXTb9ed170HHv7WLrfHvlCiQ3PddR2zZTcjm3M1yvKPhoXChsZcayIta2wwM7qA26240uOWWwCTLL5vFuB6IGwqcCkQ3PddR2jIEQTqMRM2kiiZyvENAJvrME40ak3zc2rAy1YSb0wuly3IHTaeAv(uOqHcsmHXthaya77uoBXbNhobH2IBIifKXrVHn2WQitpCAqxe0csGtr9oDyy1or0tTfkpzhSY1ItaoE6fxlgpDaGbSVt5SfhCE4eeAlUXtVycdvih7C6aadyFNYzlo48Wji0wCdyOc5WeMCzury1chI6D6WWQD2CRqcZTz9rXnlGzGmHCqMnG2NoaWquVthgwTdWQ16YOIWQfoe170HHv7S5wHeMBZAUH1wCZt9omBaTvryyPjT0ZiO8KLPthayiQ3PddR2by1ADzybpXdS4U6HNSRfGqRY9edkuOGeZEYGUddp7qYtw0qKN4JRWa6zRBA9mUjg9SvTxfE(6R42tbYcON6c6zRBA9KfnebJc980GEcwT2HlJkcRw4quVthgwTZMBfsyUnRbmenpCfgm3H0SaaM4eGTLL5oKMTUnonfkmSfxBzz2aAZErTGDlg2cqOv5tHcfkiXK4wr4iO8AlltNoaWquVthgwTJEdtS)0bagagIGrHEJEdtS)0bag3vmHbIu5g9gMURycdePYnHneNdN2ob4gU7aZNoaW4M0WwCZEZO3WYl5YWcEIhyXTNSRfGqRY9edkuOGeZEYIgI8eFCfgE2HKNW7QZb98qEQGGwy1QCoJEkQfgi1wc0ty5zCRHNw4Pb9CRWZd5zhsGE2xobHEYUwacTk3tmOqHcsEAqp1t1dpJYt6IgdrEwipJBcrEQiYZxHipJBD9K2QJ72tw0qKN4JRWa6zuEsxe0c6j7Abi0QCpXGcfki5zuEg3KN0c6zb4jgQ3PddR2HlJkcRw4quVthgwTZMBfsyUnRXQitpCI5oKMfaWeNaSTSm3H0S1TXPPqHHT4AllZR(O20fnKiiWjGHO5HRWaYC10gsbZyvENARIWQDayiAE4kmgIBfHJGtaKkcRwLJzmIvrME40GUiOfKaNI6D6WWQDIONAlKDoDaGHTaeAv(uOqHcsdWosdRwmXQjQIdwT2bGHO5HRWya2rAy1YSb0wuly3IHTaeAv(uOqHcsUmQiSAHdr9oDyy1oBUviH52SgRIm9WjM7qAwaatCcW2YYChsZw3gNMcfg2IRTSmV6JAVebsGtadrZdxHbK5QPnKcMXQ8o1wqghJyvKPhonOlcAbjWPOENomSANi6P2cz1W4PdamSfGqRYNcfkuqAa2rAy1Yo4eGJNEbMWeZgqBrTGDlg2cqOv5tHcfki5YOIWQfoe170HHv7S5wHeMBZAadrZdxHbZDinlaGjobyBzzUdPzRBJttHcdBX1wwMnG2IAb7wmSfGqRYNcfkuqIjXTIWrq51wwMWiwfz6Htd6Igsee4eWq08WvyaLxBSkY0dNglrGe4eWq08WvyazJnSkY0dNg0fbTGe4uuVthgwTte9uBHSS9PdamSfGqRYNcfkuqAa2rAy1YgBNoaWWwacTkFkuOqbPbmuHCS8sSX2PdamSfGqRYNcfkuqAGONAlKL4eGJNEbBSjQIdwT2b82acBXnBQweAGifKrMuryyPjT0ZiO8AJvrME40quVthgwTt4Tbe2IB2uTietIclT6gJ1WDhtaLWetNoaWquVthgwTJEdtyK9NoaWaWqemk0B0ByJTthayylaHwLpfkuOG0arp1wilV(GvWetS)0bag3vmHbIu5g9gMURycdePYnHneNdN2ob4gU7aZNoaW4M0WwCZEZO3WYl5YOIWQfoe170HHv7S5wHeMBZAHY5tvewTtUbdMx9rTvryyPzOCAdOlJkcRw4quVthgwTZMBfsyUnRf170HHvlZDinlaGjobyBzzUdPzRBJttHcdBX1wwMnG2NoaWquVthgwTdWQ1Yewfz6HtJWE0mQPOENomSAzz7RZegzpQVeqHWrdqdkSgUTkIXPOEpDbzJTthayaAqH1WTvrmof17Pl4O3WgBNoaWa0GcRHBRIyCkQ3txWjaQGXO3WuOCAJbQV0SaMnvlcXKOkoy1AhNoaWe0GcRHBRIyCkQ3txWbIuqgXetyK9O(safchnWHmiNXPjmbNyJnq60bag4qgKZ40eMGtJEdMycJSxuyPv3ySKav8cbYgBIQ4GvRDasACFk0sde9uBHSX2PdamajnUpfAPrVbtmHrvewTJhfuHg2ob4gU7GjvewTJhfuHg2ob4gU7yIONAlKLTXQitpCAiQ3PddR2PqHXerp1wiBSPIWQDaffsCpOlirpSfhtQiSAhqrHe3d6cs0dAIONAlKLyvKPhone170HHv7uOWyIONAlKn2ury1oameDuoFqxqIEyloMury1oameDuoFqxqIEqte9uBHSeRIm9WPHOENomSANcfgte9uBHSXMkcR2rdJO6WvymOlirpSfhtQiSAhnmIQdxHXGUGe9GMi6P2czjwfz6Htdr9oDyy1ofkmMi6P2czJnvewTdaU(iyGm5ObDbj6HT4ysfHv7aGRpcgitoAqxqIEqte9uBHSeRIm9WPHOENomSANcfgte9uBHyYLHf8KHf3eYtrvCWQ1c9mU1Wt4D15GEEip7qc0ZwwC7jgQ3PddRwpH3vNd6zTCg98qE2HeONTS42tD9ufrx5EIH6D6WWQ1tHcdp1f0ZTcpBzXTNQNs91ZldBXDf0t8Xji0wCE2GkXWLrfHvlCiQ3PddR2zZTcjm3M1cLZNQiSANCdgmV6JAlQ3PddR2POkoy1AHmBaTpDaGHOENomSAhi6P2cLhdcBSjQIdwT2HOENomSAhi6P2czjR4YOIWQfoe170HHv7S5wHeMBZAaU(iyGm5iMnG2y80bag3vmHbIu5g9gMuryyPjT0ZiO8AJvrME40quVthgwTtaU(iyGm5imXgBy80bagagIGrHEJEdtQimS0Kw6zeuETXQitpCAiQ3PddR2jaxFemqMCe7G6lbuiC0aWqemk0dtUmQiSAHdr9oDyy1oBUviH52SUHruD4kmy2aAF6aadyFNYzlo48Wji0wCtePGmo6nmD6aadyFNYzlo48Wji0wCtePGmoq0tTfkpHcJzypYLrfHvlCiQ3PddR2zZTcjm3M1nmIQdxHbZgq7thayayicgf6n6nUmQiSAHdr9oDyy1oBUviH52SUHruD4kmy2aAF6aaJggrLGRW3O3W0PdamAyevcUcFde9uBHYtOWyg2JycJNoaWquVthgwTde9uBHYtOWyg2JyJTthayiQ3PddR2by1AXetQimS0Kw6zeKLyvKPhone170HHv7eGRpcgitoYLrfHvlCiQ3PddR2zZTcjm3M1nmIQdxHbZgq7thayCxXegisLB0By60bagI6D6WWQD0BCzury1chI6D6WWQD2CRqcZTzDdJO6WvyWSb0UbryN4eGdzhqrHe3mD6aaJBsdBXn7nJEdtQimS0Kw6zeKLyvKPhone170HHv7eGRpcgitoYLHf8KHhAlopLUnGWwCEkFvlc5jyhzlopXq9oDyy16zuEIiyuiYtw0qKN4JRWWtDb9u(UlATl8Kf56J8uCRiCe0tHUEEipp0saMWuoZEE6HNDyx5Cg9SwoJEwRNxEj)hUmQiSAHdr9oDyy1oBUviH52SgEBaHT4MnvlcXSb0(0bagI6D6WWQD0ByI9QiSAhagIMhUcJH4wr4iitQimS0Kw6zeuETXQitpCAiQ3PddR2j82acBXnBQweIjvewTJM7Iw7IjaxFeCa058jIe3kchnd7rYdOZ5teb2fHvlZ2gec1BIPb0wfHv7aWq08Wvyme3kchbBRIWQDayiAE4kmgp9IP4wr4iOlJkcRw4quVthgwTZMBfsyUnRBUlATlMaC9rqMnG2NoaWquVthgwTJEdtbsXs8zypILNoaWquVthgwTde9uBHmHrmQIWQDayiAE4kmgIBfHJGSuwMcLtBmAyevcUcFmPIWWstAPNrW2YIj2yJ9HYPngnmIkbxHp2ytfHHLM0spJGYtwmX0PdamUjnSf3S3m6ny(UIjmqKk3e2qCoCA7eGB4UdwEjxgvewTWHOENomSANn3kKWCBwdW1hbdKjhXSb0(0bagI6D6WWQDawTwMevXbRw7quVthgwTde9uBHSuOWyg2JysfHHLM0spJGYRnwfz6Htdr9oDyy1ob46JGbYKJCzury1chI6D6WWQD2CRqcZTznGHOJY5mBaTpDaGHOENomSAhGvRLjrvCWQ1oe170HHv7arp1wilfkmMH9iMyVOwWUfdaU(OPkeikSADzury1chI6D6WWQD2CRqcZTznuuiXnZgq7thayiQ3PddR2bIEQTq5juymd7rmD6aadr9oDyy1o6nSX2Pdame170HHv7aSATmjQIdwT2HOENomSAhi6P2czPqHXmSh5YOIWQfoe170HHv7S5wHeMBZAUH1wCZt9omBaTpDaGHOENomSAhi6P2czjob44PxWKkcdlnPLEgbLNSUmQiSAHdr9oDyy1oBUviH52SgeP4QfopisJBMnG2NoaWquVthgwTde9uBHSeNaC80ly60bagI6D6WWQD0BCzCzybpXdjEdH8eRIm9WjpJBn8uuBO2c9mUjpvr0vUNemSNgeONH9ipJBn8mUjpx6IWtmuVthgwTE2Y4CppKNisbzC4YOIWQfoe170HHv7mSNT4AJvrME4eZR(O2I6D6WWQDIifKXzypIzSkVtTfvXbRw7quVthgwTde9uBHxlgLLDWiwfz6Htd5SfKBlUjIa7IWQfZxFCPRfWqemuuqOHkcdlHPRnuoTXqoBb52IdtUmQiSAHdr9oDyy1od7zlom3M1yvKPhoX8QpQTOENomSANH9iMXQ8o1gRIm9WPHOENomSANisbzCg2JCzybpXJexz0tmuVthgwTEcuipvGGqEYIgIGHIcc5zF5ee6jwfz6HtdadrWqrbHMI6D6WWQ1td6jKIHlJkcRw4quVthgwTZWE2IdZTznwfz6HtmV6JAlQ3PddR2zypI5QP9tVGzSkVtTbmebdffeAGONAlKzdODOCAJbGHiyOOGqmXESkY0dNgagIGHIccnf170HHvRldl4jEK4kJEIH6D6WWQ1tGc55LvbnDdpLAuKCEAaEAHNTmo3tr9iplaapfvXbRwRNWQ2HlJkcRw4quVthgwTZWE2IdZTznwfz6HtmV6JAlQ3PddR2zypI5QP9tVGzSkVtTfvXbRw7aPGMUXe2Oi5gi6P2cz2aAlkS0QBmKJrKPltIQ4GvRDGuqt3ycBuKCde9uBHSJSxNLyvKPhone170HHv7mSh5YWcEIhjUYONyOENomSA9eOqEIhjnUpfAPHlJkcRw4quVthgwTZWE2IdZTznwfz6HtmV6JAlQ3PddR2zypI5QP9tVGzSkVtTfvXbRw7aK04(uOLgi6P2cz2aAlkS0QBmwsGkEHazsufhSATdqsJ7tHwAGONAlKDK96SeRIm9WPHOENomSANH9ixgwWt8iXvg9ed170HHvRNafYZ4M8u()Ayerk3tggcC1vqEE6aaEAaEg3KNnCLrc5Pb9SdTfNNXTgEgiBLJIHlJkcRw4quVthgwTZWE2IdZTznwfz6HtmV6JAlQ3PddR2zypI5QP9tVGzSkVtTXQitpCAqVggrKYNfcC1vqtqIRmYoyuufhSATd61WiIu(SqGRUcAa2rAy1YoIQ4GvRDqVggrKYNfcC1vqde9uBHy6AzVOkoy1Ah0RHreP8zHaxDf0arkiJmBaTjgC3AAiWb9AyerkFwiWvxb5YWcEIhjUYONyOENomSA9eOqEYQZvqtJcb9eFkioIzp7lNGqpTWZwvNd65H8eK4kJeON8AXripJBD98sx3tijQfeoCzury1chI6D6WWQDg2ZwCyUnRXQitpCI5vFuBr9oDyy1od7rmxnTF6fmJv5DQTOkoy1Ah44kOPrHGZJcIJMxJ8JvU0Lyqgi6P2cz2aAtm4U10qGdCCf00OqW5rbXrmjQIdwT2boUcAAui48OG4O51i)yLlDjgKbIEQTq25sxNLyvKPhone170HHv7mSh5YWcEIhjUYONyOENomSA9SVHX98YwYNN0fngIGEAaEAXvqp7ndxgvewTWHOENomSANH9SfhMBZASkY0dNyE1h1wuVthgwTZWEeZvt7NEbZyvENAF6aaduFPzbmBQweAGONAlKzdODOCAJbQV0SaMnvlcX0Pdame170HHv7aSATUmSGN4rIRm6jgQ3PddRwpbkKN66jDrGupVS9L8Sa8u(QweYtdWZ4M88Y2xYZcWt5RAripBvDoONI6rEwaaEkQIdwTwp1WtoPWWtwXtijQfe65Hake5jgQ3PddRwpBvDo4WLrfHvlCiQ3PddR2zypBXH52SgRIm9WjMx9rTf170HHv7mShXC10(PxWmwL3P2IQ4GvRDG6lnlGzt1Iqde9uBHy(0bagO(sZcy2uTi0aSJ0WQLzdODOCAJbQV0SaMnvlcX0Pdame170HHv7aSATmjQIdwT2bQV0SaMnvlcnq0tTfIzwHLyvKPhone170HHv7mSh5YWcEIhjUYONyOENomSA98WON9gpJYtzVUNqsuli0ZO8eWcpT1t6IaPE2Hkoc6zb4jE0GcRHBRIy0tmuVNUGdxgvewTWHOENomSANH9SfhMBZASkY0dNyE1h1wuVthgwTZWEeZvt7NEbZyvENAlQIdwT2XPdambnOWA42QigNI690fCa2rAy1IzrvCWQ1ooDaGjObfwd3wfX4uuVNUGde9uBHmBaTfvXbRw740baMGguynCBveJtr9E6coq0tTfIzrvCWQ1ooDaGjObfwd3wfX4uuVNUGdWosdRwwIvrME40quVthgwTZWEe7i71DzybpXJexz0tmuVthgwTEAaEIhnOWA42Qig9ed17PlONTQoh0ZTcppKNisbz0tGc5PfEYifdxgvewTWHOENomSANH9SfhMBZASkY0dNyE1h1wuVthgwTZWEeZvt7NEbZyvENAlQIdwT2XPdambnOWA42QigNI690fCGONAlKzdOnQVeqHWrdqdkSgUTkIXPOEpDbz60bagGguynCBveJtr9E6coaRwRldl45LvnqpL)yPnGmKN4rIRm6jgQ3PddRwpbkKNkiONWgT1c9Sa88A8SqE(ke5Pccc9mU1WZwgN7jxHHN8AXripJBD9uwwXtijQfeo8eV3eK8eRY7e0tfr7vHNljiiurgNrpRMWEk3tB9u5CpfkKGdxgvewTWHOENomSANH9SfhMBZASkY0dNyE1h1wuVthgwTZWEeZvt7NEbZyvENAJudCsyPngkiiCylZgqBKAGtclTXqbbHd6cdgqMqQbojS0gdfeeoevFd51(AycPg4KWsBmuqq4aSJ0WQvEYYkUmSGNxw1a9u(JL2aYqEE58wkJqp7qYtmuVthgwTE2YIBpX25lH0JXTGrprQb6jHL2aYSNfwcHmqYtDz0tqIRmc9KBWGa9upfwYZO88PYrEc7iYtl8ehfqp7qc0ZBcrdxgvewTWHOENomSANH9SfhMBZASkY0dNyE1h1wuVthgwTZWEeZyvENAJudCsyPngy78Lq6HtdBVw2JudCsyPngy78Lq6HtJEdZgqBKAGtclTXaBNVespCAqxyWaYewfz6Htdr9oDyy1orKcY4mShXsKAGtclTXaBNVespCAyRldl4jdpK8mUjpx6IWtmuVthgwTEwRNIQ4GvR1tdWtl8Sv15GEUv45H8KUOHebb6zuEcsCLrpJBYtO4Ma7Cc0ZAjplKNXn5juCtGDob6zTKNTQoh0ZBTPHwp5ee6zCRRNYYkEcjrTGqppeqHipJBYtad3D4jTGWHNxoiONr5jwfz6Htd5SfKBlUjIa7IWQ1Zdj0oK8mUnON2k4Dqc6zCtEcGQn4LcsGEgidhocb9eSJSfNNyOENomSA9uxqpJBn8eRIm9WjpnONps3WZO88qE2HeONkqqipXq9oDyy1oCzury1chI6D6WWQDg2ZwCyUnRXQitpCI5vFuBr9oDyy1od7rmJv5DQnwfz6Htdr9oDyy1orKcY4mShXSb0gRIm9WPHOENomSANisbzCg2JWSOkoy1AhI6D6WWQDa2rAy1ETyuw2bJxFCjmJvrME40qoBb52IBIiWUiSAX81hx6AbmebdffeAOIWWsy6AdLtBmKZwqUT4WelBJvrME40quVthgwTZWEeBSHvrME40quVthgwTZWEK8amC3Xerp1wi7CPR7YWcEE5GGEg3KNIocrB4zypYZO8mUjpHIBcSZjqpXq9oDyy16zuE20dpTWtB9upWI3dYZWEKNWYZ4wdpTWtd6jmmo3tvi6inipvGGqEQEYTi4KNH9ipBuiKGdxgvewTWHOENomSANH9SfhMBZASkY0dNyE1h1wuVthgwTZWEeZvtBfeKzSkVtTd7rUmSGNSOTkNZiZEkQflHcpbq1Zt9alEpipd7rEQlONWOqKNXn5jI4Ayyjpd7rEARNyvKPhonc7rZOMI6D6WWQD4jd)Yn5ipJBYtebdplapJBYtHYfDUgwTqM9S1TjU98wBAO1tobHEcGigCN2GZONr5jSHiqp7nEg3KNq715Ay1YSNXTb98wBAOf6zbaWoS6yap6PUGE2624KNcfg2IB4YOIWQfoe170HHv7mSNT4WCBwJvrME4eZDinlaGjobyBzzUdPzRBJttHcdBX1wwMx9rTd7rZOMI6D6WWQLzSkVtTXiwfz6Htdr9oDyy1od7rStypctx7Pdame170HHv7aSATUmUmQiSAHdu1mBUvi1gGRpcgitoIzdOTkcdlnPLEgbLxBSkY0dNg3vmHbIu5MaC9rWazYrmHXthayCxXegisLB0ByJTthayayicgf6n6nyYLrfHvlCGQMzZTcjm3M1nmIQdxHbZgq7thaya77uoBXbNhobH2IBIifKXrVHPthaya77uoBXbNhobH2IBIifKXbIEQTq5juymd7rUmQiSAHdu1mBUviH52SUHruD4kmy2aAF6aadadrWOqVrVXLrfHvlCGQMzZTcjm3M1nmIQdxHbZgq7thayCxXegisLB0BCzybpz4HKN1sEYIgI8eFCfgEskIZON265LTKppnapzS6Ecw7vHN3kwYtYIBc5jEiPHT48KHVXZc5jEyfEkfisLZtgPWtDb9KS4MqmKNyuXKN3kwYZxHipJBD9mAvEQCePGmYSNy8GjpVvSKNxoNUagifYGIEf0twSJy0tePGm6zuE2HeZEwipXOatEkrkYwCEI3QlU90GEQIWWsdpXJ1Ev4jy5zCBqpBDBCYZBfb6PqHHT48Kf56JGbYKJGEwipBDtRNs91ZldBXDf0t8Xji0wCEAqprKcY4WLrfHvlCGQMzZTcjm3M1agIMhUcdM7qAwaatCcW2YYChsZw3gNMcfg2IRTSmBaTzpwfz6HtdadrZdxHXSPkUT4y60bagW(oLZwCW5HtqOT4MisbzCawTwMuryyPjT0ZiilXQitpCACRiWPqHXeGRpcgitoIj2dyicgkki0qfHHLycJS)0bag3Kg2IB2Bg9gMy)PdamURycdePYn6nmX(geHDwaatCcWbGHO5HRWGjmQIWQDayiAE4kmgIBfHJGYR9LyJnmgkN2yOC6cyGuidkkCc0rmYKOkoy1AhGifxTW5brACpqKcYiMyJniPiBXnJQlUhQimSeMWKldl4jdpK8Kfne5j(4km8KS4MqEc2r2IZt1tw0q0r5CwlFmIQdxHHNcfgE26MwpXdjnSfNNm8nEAqpvryyjplKNGDKT48KUGe9G8SLf3EkrkYwCEI3QlUhUmQiSAHdu1mBUviH52SgWq08WvyWChsZcayIta2wwM7qA26240uOWWwCTLLzdOn7XQitpCAayiAE4kmMnvXTfhtShWqemuuqOHkcdlXegXigvry1oameDuoFqxqIEyloMWOkcR2bGHOJY5d6cs0dAIONAlKLxFWkSXg7r9LakeoAayicgf6Hj2ytfHv7OHruD4kmg0fKOh2IJjmQIWQD0WiQoCfgd6cs0dAIONAlKLxFWkSXg7r9LakeoAayicgf6HjmX0PdamUjnSf3S3m6nyIn2WiKuKT4Mr1f3dvegwIjmE6aaJBsdBXn7nJEdtSxfHv7akkK4EqxqIEylo2yJ9NoaW4UIjmqKk3O3We7pDaGXnPHT4M9MrVHjvewTdOOqI7bDbj6HT4yI93vmHbIu5MWgIZHtBNaCd3DGjmHjxgvewTWbQAMn3kKWCBwluoFQIWQDYnyW8QpQTkcdlndLtBaDzury1chOQz2CRqcZTzDdJO6WvyWSb0(0bagnmIkbxHVrVHjHcJzypILNoaWOHruj4k8nq0tTfYKqHXmShXYthayG6lnlGzt1Iqde9uBHUmQiSAHdu1mBUviH52SUHruD4kmy2aAF6aaJ7kMWarQCJEdtqsr2IBgvxCpuryyjMuryyPjT0ZiilXQitpCACxXegisLBcW1hbdKjh5YOIWQfoqvZS5wHeMBZ6M7Iw7IjaxFeKzdOn7XQitpCA0Cx0AxmBQIBloMoDaGXnPHT4M9MrVHj2F6aaJ7kMWarQCJEdtyufHHLMGvmmCRfelVeBSPIWWstAPNrq51gRIm9WPXTIaNcfgtaU(iyGm5i2ytfHHLM0spJGYRnwfz6HtJ7kMWarQCtaU(iyGm5im5YOIWQfoqvZS5wHeMBZAOOqIBMnG2qsr2IBgvxCpuryyjxgvewTWbQAMn3kKWCBwdIuC1cNhePXnZgqBvegwAsl9mckVl5YOIWQfoqvZS5wHeMBZAfj0LM0fn8cA1YSb0wfHHLM0spJGYRnwfz6Htdfj0LM0fn8cA1Y0txD0ic51gRIm9WPHIe6st6IgEbTANpDvxgwWt8alU9K2QJ72Zqr4OaYSNw4Pb9u9eNARNr5PqHHNSixFemqMCKNk0taJZjKN2cdsb9Sa8KfneDuoF4YOIWQfoqvZS5wHeMBZAaU(iyGm5iMnG2QimS0Kw6zeuETXQitpCACRiWPqHXeGRpcgitoYLrfHvlCGQMzZTcjm3M1agIokN7Y4YOIWQfoGHUGkcCIQqdR22aC9rWazYrmBaTvryyPjT0ZiO8AJvrME404UIjmqKk3eGRpcgitoIjmE6aaJ7kMWarQCJEdBSD6aadadrWOqVrVbtUmQiSAHdyOlOIaNOk0WQfZTzDdJO6WvyWSb0(0bagagIGrHEJEJlJkcRw4ag6cQiWjQcnSAXCBw3WiQoCfgmBaTpDaGXDftyGivUrVHPthayCxXegisLBGONAlKLQiSAhagIokNpOlirpOzypYLrfHvlCadDbve4evHgwTyUnRByevhUcdMnG2NoaW4UIjmqKk3O3WegBqe2job4q2bGHOJY5SXgGHiyOOGqdvegwIn2ury1oAyevhUcJHTtaUH7oWKldl4jErm6zuEIJcpLUmWNNnOsa90wObsEEzl5ZZMBfsqplKNyOENomSA9S5wHe0Zw306ztbH2HtdxgvewTWbm0furGtufAy1I52SUHruD4kmy2aAF6aadyFNYzlo48Wji0wCtePGmo6nmHrrvCWQ1oq9LMfWSPArObIEQTqmRIWQDG6lnlGzt1Iqd6cs0dAg2JWSqHXmShjVthaya77uoBXbNhobH2IBIifKXbIEQTq2yJ9HYPngO(sZcy2uTieMycRIm9WPrypAg1uuVthgwTywOWyg2JK3PdamG9DkNT4GZdNGqBXnrKcY4arp1wOlJkcRw4ag6cQiWjQcnSAXCBw3WiQoCfgmBaTpDaGXDftyGivUrVHjiPiBXnJQlUhQimSKlJkcRw4ag6cQiWjQcnSAXCBw3WiQoCfgmBaTpDaGrdJOsWv4B0BysOWyg2Jy5PdamAyevcUcFde9uBHUmSGN4XoYwCEg3KNWqxqfb6jQcnSAz2ZA5m6zhsEYIgI8eFCfgqpBDtRNXnXONkI8CRWZdzlopBQItGEcuipVSL85zH8ed170HHv7WtgEi5jlAiYt8Xvy4jzXnH8eSJSfNNQNSOHOJY5Sw(yevhUcdpfkm8S1nTEIhsAylopz4B80GEQIWWsEwipb7iBX5jDbj6b5zllU9uIuKT48eVvxCpCzury1chWqxqfborvOHvlMBZAadrZdxHbZDinlaGjobyBzzUdPzRBJttHcdBX1wwMnG2ShWqemuuqOHkcdlXe7XQitpCAayiAE4kmMnvXTfhtyeJyufHv7aWq0r58bDbj6HT4ycJQiSAhagIokNpOlirpOjIEQTqwE9bRWgBSh1xcOq4ObGHiyuOhMyJnvewTJggr1HRWyqxqIEyloMWOkcR2rdJO6WvymOlirpOjIEQTqwE9bRWgBSh1xcOq4ObGHiyuOhMWetNoaW4M0WwCZEZO3Gj2ydJqsr2IBgvxCpuryyjMW4PdamUjnSf3S3m6nmXEvewTdOOqI7bDbj6HT4yJn2F6aaJ7kMWarQCJEdtS)0bag3Kg2IB2Bg9gMury1oGIcjUh0fKOh2IJj2FxXegisLBcBiohoTDcWnC3bMWeMCzury1chWqxqfborvOHvlMBZ6ggr1HRWGzdO9PdamURycdePYn6nmPIWWstAPNrqwIvrME404UIjmqKk3eGRpcgitoYLrfHvlCadDbve4evHgwTyUnRBUlATlMaC9rqMnG2ShRIm9WPrZDrRDXSPkUT4ycJSpuoTXaavVzCttfEtq2ytfHHLM0spJGYtwmXegvryyPjyfdd3AbXYlXgBQimS0Kw6zeuETXQitpCACRiWPqHXeGRpcgitoIn2uryyPjT0ZiO8AJvrME404UIjmqKk3eGRpcgitoctUmQiSAHdyOlOIaNOk0WQfZTzTq58PkcR2j3GbZR(O2QimS0muoTb0LrfHvlCadDbve4evHgwTyUnRbrkUAHZdI04MzdOTkcdlnPLEgbLNSUmQiSAHdyOlOIaNOk0WQfZTznuuiXnZgqBiPiBXnJQlUhQimSKlJkcRw4ag6cQiWjQcnSAXCBwRiHU0KUOHxqRwMnG2QimS0Kw6zeuETXQitpCAOiHU0KUOHxqRwME6QJgriV2yvKPhonuKqxAsx0WlOv78PR6YWcEIhyXTN0wDC3EgkchfqM90cpnONQN4uB9mkpfkm8Kf56JGbYKJ8uHEcyCoH80wyqkONfGNSOHOJY5dxgvewTWbm0furGtufAy1I52SgGRpcgitoIzdOTkcdlnPLEgbLxBSkY0dNg3kcCkuymb46JGbYKJCzury1chWqxqfborvOHvlMBZAadrhLZ)Xp(F]] )

end
