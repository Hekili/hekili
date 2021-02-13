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
            if state:IsInFlight( spell ) then return true end
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


    spec:RegisterPack( "Fire", 20210213, [[deLm8dqius9iqvCjqsP2eO4tQaJsfQtbsSkqs1Rav1SqHULkiTlr9luqddfWXejTmvq9mvqmnvi4AOKyBGQeFdLsyCGKOZHsPyDeLY8ik5EIu7dLI)PcHQdIsjTqqQEiOutKOu5IQqKnIc0hvHqgPke1jrPuTsuQEjkLsZeLKUjrPQ2jiLFcQsAOGK0sbjHNsKPck5QOuI2krPkFfKumwviTxv1FL0GvCyslwLEmQMmGlJSzv5ZGy0QOttz1GKsEnrXSjCBG2Ts)wQHlIJdQsTCiphQPt11Ly7OOVtunErIZdQSEviuMpkX(f(N6hwFja1Pp0omdC4uzGdN6HKt9qoKdN6H8LC4sOVuIYLrHqFPvbPVedAi6lLOWjAf4dRVeUlio9LoDpblBmKHqm)SCZ8gKHydSiu36LJ0NZqSbYz4x6wmHZ23)9lbOo9H2HzGdNkdC4upKCQhYHC4u)sAXpB0xsYaH9x60aaO9F)saeM)LGh4jgg0qumY(kekyhEGNyoDpblBmKHqm)SCZ8gKHydSiu36LJ0NZqSbYzyWo8apXWG0fvueCXK6HWymhMboCQb7b7Wd8edSp1fcHLTGD4bEI5qJHTetX8miNEfrGQT4yqQFsOy8tDJXveeYZUbsvVRagfZRrXiuSFOyI3lqm61eMdxmfScHW5GD4bEI5qJHv7gtBmCf7XGi4DXqeiTooMxJIb2n4TGDR3yo2YuMXya69apMZwaeJ5X8AumAmpeHpJr2NCQrXWvSdLCWo8apXCOXCKw9kOyWoY4Em8tIlJTqIP3y0yEK8yEnsgCm2gJFsXWwHQSAmEhdIakCkg5nsgrRa5GD4bEI5qJHTca1QG9y0yGQWH6RqXEm06i4IXpvpgGMWXSThdydqIyKtcrm2EOquqkMJXgymoHDcig1Jz7yWgK1Egxxpgzhuvkgdmr5ouYb7Wd8eZHgdS7LjH8yuHiMB59YhnxsIHwhzeogVJ5wEV8rZLegJr3yubyJ9ySfBqw7zCD9yKDqvPyGO2gJTXGnqC(ljmSJ)W6lXBWBb7wVvE3cGw(I)W6dTu)W6lPC369lL0U17xIw9kiGp0)(hAh(dRVKYDR3V0v0nq9vqW9LOvVcc4d9V)H2H8H1xIw9kiGp0)sCK5eY0V0T8EzEdEly36nxs(sk3TE)sxcHjKm2c57FODe(W6lPC369l9meDfDd8LOvVcc4d9V)HgR8H1xs5U17xsxoHDKkQCvi(s0Qxbb8H(3)qdE5dRVeT6vqaFO)L4iZjKPFjuzPxJGqzNatAKkQYvusMw9kiGyGjMB59YukNAb7wV5sYxs5U17xYnqQkxrjF)dn2IpS(s0Qxbb8H(xs5U17xcIqbm1BeUEvai0xIEpI71vbPVeeHcyQ3iC9QaqOV)Hgu5hwFjA1RGa(q)lTki9LSfZrfxVcQcVl66fWkaX040xs5U17xYwmhvC9kOk8UORxaRaetJtF)dn2MpS(s0Qxbb8H(xAvq6l9ekiv7x9QUlOVKYDR3V0tOGuTF1R6UG((hAPYaFy9LOvVcc4d9V0QG0xsUkdTecxFOEb(sk3TE)sYvzOLq46d1lW3)ql1u)W6lrREfeWh6FPvbPVKTyhv4EJWvaJPTu9scXxs5U17xYwSJkCVr4kGX0wQEjH47FOL6H)W6lrREfeWh6FPvbPVeUSxr3avfK8t4W(xs5U17xcx2ROBGQcs(jCy)7FOL6H8H1xs5U17xQGPQ5ei(lrREfeWh6F)7Fja6PfH)H1hAP(H1xIw9kiGp0)sCK5eY0VeRJbvw61iiugWWClryRIGRYBqqDbY0Qxbb8LuUB9(L4DzDcHtiH47FOD4pS(s0Qxbb8H(xQt(syY)sk3TE)smvKPxb9LyQIc9LCvqRNFgIWUICcLPvVccigOEmpdryxroHYicuTfhd8J54y4DlaA5BM3G3c2TEZicuTfhdupMJJj1yo0yyQitVcklJTacBHureqH7wVXa1JXvbTEwgBbe2cjtREfeqmqjgOedupgwhdVBbqlFZ8g8wWU1BgrkaCXa1J5wEVmVbVfSB9MbA57xcGWCKL4wVFjzpfz6vqX4NQhdVxh1cCmYpPngy3G3c2TEJXWXuWeqogyDA4ye2sXGjhhdSBWBb7wVX4DmxkMcMaIrFoHIHbneHDf5ekgDbIrtsegHJXpPyKXwaHTqQicOWDR3yyQitVckgVJXpPyqeOARTqIH3TaOLVX0VyGDdEly36nhdBfaWCRxviGJXySxmWUbVfSB9gJHJbWW6vqaX4NgogOwfShdMCCm(jfdtfz6vqX4DmAmUbsXKOypg)KIHwGy6xm(jfd2alc1TEZFjMkQUki9LCdKQEx5n4TGDR3V)H2H8H1xIw9kiGp0)sDYxcut5lPC369lXurMEf0xIPIQRcsFj3aPQ3vEdEly369lXrMtit)se8UyjjeqMatGdrQO2iGvxo9LaimhzjU17xs2xLHIbxqumWUbVfSB9gJHJbGekCeqm2lMLiaciMRIjGy6ng)KIHatGdrQO2iGvxovbiHcxmmvKPxbL)smvrH(smvKPxbLjWe4qKkQncy1LtvasOWfZHgZXXW7wa0Y3mbMahIurTraRUCkduqQB9gZHgdVBbqlFZeycCisf1gbS6YPmIavBXXaLyG6XW6y4DlaA5BMatGdrQO2iGvxoLrKca33)q7i8H1xIw9kiGp0)sDYxcut5lPC369lXurMEf0xIPIQRcsFj3aPQ3vEdEly369lXrMtit)se8UyjjeqgIqbm1BeUEvaiumWedVBbqlFZqekGPEJW1RcaHYicuTfhJSI5WmWxcGWCKL4wVFjzhju4Ib2n4TGDR3yEnkMJiHcyQ3iCmqxbGqmgtzfeghJ5XiVlcGyUumaKqHJaIr0lecfJFQBmhMbIbt8EbW5VetvuOVeVBbqlFZqekGPEJW1RcaHYicuTf)9p0yLpS(s0Qxbb8H(xQt(sGAkFjL7wVFjMkY0RG(smvuDvq6l5giv9UYBWBb7wVFjoYCcz6xYvbTEgvwQ2VAslNqzA1RGaIbMyUL3lZBWBb7wVzGw((LaimhzjU17xs2rcfUyGDdEly36nMY6MigOIgQgdLsIHiCm2lgZpahtjj)LyQIc9LUL3lJklv7xnPLtOmIavBXF)dn4LpS(s0Qxbb8H(xQt(sGAkFjL7wVFjMkY0RG(smvuDvq6l5giv9UYBWBb7wVFjoYCcz6xYvbTEgvwQ2VAslNqzA1RGaIbMyUL3lZBWBb7wVzGw(gdmXW7wa0Y3mQSuTF1KwoHYicuTfhd8JHvIrwXWurMEfu2nqQ6DL3G3c2TE)saeMJSe369lj7iHcxmWUbVfSB9gZRrXOBmukosJbQOSum9lgOAlNqXyVy8tkgOIYsX0VyGQTCcfJ8UiaIH3Gum97fdVBbqlFJr9yeKI9yyLyWeVxaCmx61ikgy3G3c2TEJrExea5VetvuOVeVBbqlFZOYs1(vtA5ekJiq1wCmWpMB59YOYs1(vtA5ekduqQB9(9p0yl(W6lrREfeWh6FPo5lbQP8LuUB9(LyQitVc6lXur1vbPVKBGu17kVbVfSB9(L4iZjKPFjuzPxJGqzadZTeHTkcUkVbb1fitREfeqmWeZT8EzadZTeHTkcUkVbb1fid0Y3VeaH5ilXTE)sYosOWfdSBWBb7wVXyVyKDgMBjcBveCXa7geuxGyK3fbqmB7XCPyqKcaxmVgfJ5Xah55VetvuOVeVBbqlFZ3Y7vbmm3se2Qi4Q8geuxGmIavBXF)dnOYpS(s0Qxbb8H(xQt(syY)sk3TE)smvKPxb9LyQIc9LoogL7gtQslbAeogzfdtfz6vqzEdEly36TIpTNBlKAslNqXWclXOC3ysvAjqJWXiRyyQitVckZBWBb7wV1NqbjSJmzOyyHLyyQitVck7giv9UYBWBb7wVXCOXOC36nJpTNBlKAslNq5xriQicOWDR3yytm8UfaT8nJpTNBlKAslNqzGcsDR3yGsmWedtfz6vqz3aPQ3vEdEly36nMdngE3cGw(MXN2ZTfsnPLtOmIavBXXWMyuUB9MXN2ZTfsnPLtO8Rievebu4U1BmWeZXXW7wa0Y3mQSuTF1KwoHYicuTfhZHgdVBbqlFZ4t752cPM0YjugrGQT4yytmSsmSWsmSogxf06zuzPA)QjTCcLPvVccigO8LaimhzjU17xs2trMEfum(P6Xqy3avNWXi)K8tcfJ0P9CBHeduTLtOyKBcrmxkMcMaI5sVgrXa7g8wWU1BmgogePaWL)smvuDvq6lHpTNBlKAslNq1l9Aev5n4TGDR3V)HgBZhwFjA1RGa(q)lXrMtit)s3Y7L5n4TGDR3mqlFJbMyyDmhhZT8EzBFeAvrLRyUcq5ssmWeZT8E5Z2RyhrQm5ssmqjgyIHPIm9kOm(0EUTqQjTCcvV0RruL3G3c2TE)sk3TE)s4t752cPM0Yj03)qlvg4dRVeT6vqaFO)L4iZjKPFPJJ5wEVmVbVfSB9MbA5BmWeZT8EzuzPA)QjTCcLbA5BmWeZXXWurMEfu2nqQ6DL3G3c2TEJrwXqPq8Itv3aPyyHLyyQitVck7giv9UYBWBb7wVXWMy4DlaA5BgPaMUEfNOizYafK6wVXaLyGsmSWsmhhZT8EzuzPA)QjTCcLljXatmmvKPxbLDdKQEx5n4TGDR3yytmhcdedu(sk3TE)sifW01R4efjZ3)ql1u)W6lrREfeWh6FjoYCcz6x6wEVmVbVfSB9MbA5BmWeZT8EzuzPA)QjTCcLbA5BmWedtfz6vqz3aPQ3vEdEly36ngzfdLcXlovDdK(sk3TE)saK6N3gT03)ql1d)H1xIw9kiGp0)sCK5eY0Vetfz6vqz3aPQ3vEdEly36ngzLoMdjgyI5wEVmVbVfSB9MbA57xs5U17xc0qOgHR9R6ncKw)7FOL6H8H1xIw9kiGp0)sfmvLFAcQYvSBlKp0s9lbqyoYsCR3Ved2OyK9O1pHdXymfmfJgddAikgOluShd)urqOyakiBHeJSVHqncht)IbwncKwpgUI9y8ogLzBaXW1KeBHed)urqiC(lPC369l9mevVcf7FjoYCcz6xs5U1Bg0qOgHR9R6ncKwptPq8IBlKyGjMxriQiIFQiiu1nqkMdngL7wVzqdHAeU2VQ3iqA9mLcXlovreOAlogzfZrigyIH1XC2Ef7isLPItiHaxTT(egKtpgyIH1XClVx(S9k2rKktUK89p0s9i8H1xIw9kiGp0)sk3TE)sqekGPEJW1RcaH(sCK5eY0Vetfz6vqz3aPQ3vEdEly36ng2eJYDR3kVBbqlFJ5qJHv(s07rCVUki9LGiuat9gHRxfac99p0sLv(W6lrREfeWh6FjL7wVFjcmboePIAJawD50xIJmNqM(LyQitVck7giv9UYBWBb7wVXiR0XWurMEfuMatGdrQO2iGvxovbiHc3xAvq6lrGjWHivuBeWQlN((hAPcV8H1xIw9kiGp0)sk3TE)sqeWLCw7xvXyd0eQB9(L4iZjKPFjMkY0RGYUbsvVR8g8wWU1BmSjDmmvKPxbL7TwWuLx8(9(sRcsFjic4soR9RQySbAc1TE)(hAPYw8H1xIw9kiGp0)sk3TE)sGkxViQIpjYRGfSX)sCK5eY0Vetfz6vqz3aPQ3vEdEly36ngzLogw5lTki9LavUErufFsKxblyJ)9p0sfQ8dRVeT6vqaFO)LaimhzjU17xIT)IPGTfsmAmyNqTbetVhAbtXyobYymQqUchoMcMIr2Hif4zikgzpcJjrmDXXgaft)Ib2n4TGDR3CmWR(jHKByIXysqwJm3oIrXuW2cjgzhIuGNHOyK9imMeXi38ZyGDdEly36nMEfWfJ9IHTVpcTQigyRyUcqXy4yOvVccigDbIrJPGviumY79apMlfJOXEmntcfJFsXauqQB9gt)IXpPyEgKtp)LwfK(saisbEgIQmjmMeFjoYCcz6xIPIm9kOSBGu17kVbVfSB9gdBshdtfz6vq5ERfmv5fVFVyGjMJJ5wEVSTpcTQOYvmxbOm2vUmXKoMB59Y2(i0QIkxXCfGYGAkvSRCzIHfwIH1XW7fOyE22hHwvu5kMRauMw9kiGyyHLyyQitVckZBWBb7wV1ERfmfdlSedtfz6vqz3aPQ3vEdEly36ng4hdRedBI5zqo9kIavBXXa1ogL7wVvE3cGw(gdu(sk3TE)saisbEgIQmjmMeF)dTuzB(W6lrREfeWh6FjacZrwIB9(LK6Iig2oK1Ccfd(SlcGyUumfmbeJTXOXixHlg)u9yaAcVh4XyRtOhHOyKB(zmTFsOy69qlykghzRmKJZXaV6NekghzRmKJJbOJzBpghzqGqOy0yWNkIaIHTdBzxm9gJ5mgdUJX8y46gZLIPGjGyqgKtpg95ekgDHlM2pjum9EOfmfJJSvgYZFPvbPVeUlIQbznNqFjoYCcz6xIPIm9kOSBGu17kVbVfSB9gdBshZHWaXa1J54yyQitVck3BTGPkV497fdBIHbIbkXatmhhdRJHG3fljHaYaisbEgIQmjmMeXWclXW7wa0Y3maIuGNHOktcJjrgrGQT4yytmSsmq5lPC369lH7IOAqwZj03)q7WmWhwFjA1RGa(q)lPC369lX1LtI6T8EFjoYCcz6xI1XW7fOyE22hHwvu5kMRauMw9kiGyGjg3aPyKvmSsmSWsm3Y7LT9rOvfvUI5kaLXUYLjM0XClVx22hHwvu5kMRaugutPIDLlZx6wEV6QG0xc3fr1GSMB9(LaimhzjU17xcwidcecfJuxeXW2HSMtOyifjGlg5MFgdBFFeAvrmWwXCfGIPrXi)K2ympg5koMeeXvSN)(hAho1pS(s0Qxbb8H(xs5U17xQGPQ5ei(lbqyoYsCR3VeB3jqCm(P6Xa0XSThZLw6zEmWUbVfSB9gd(SlcGyGAvWEmxkMcMaIPlo2aOy6xmWUbVfSB9gJ6XGBqkMK2wp)L4iZjKPFjMkY0RGYUbsvVR8g8wWU1BmSjDmmvKPxbL7TwWuLx8(9((hAh(WFy9LOvVcc4d9VKYDR3VeVlRtiCcjeFjacZrwIB9(LoIipg)KIr2zyULiSvrWfdSBqqDbI5wEVykjmgtzfeghdVbVfSB9gJHJb39M)sCK5eY0VeQS0RrqOmGH5wIWwfbxL3GG6cKPvVccigyIH3TaOLV5B59QagMBjcBveCvEdcQlqgrkaCXatm3Y7Lbmm3se2Qi4Q8geuxGQI46szGw(gdmXW6yUL3ldyyULiSvrWv5niOUa5ssmWedtfz6vqz3aPQ3vEdEly36ng2eZHzLV)H2HpKpS(s0Qxbb8H(xIJmNqM(LqLLEnccLbmm3se2Qi4Q8geuxGmT6vqaXatm8UfaT8nFlVxfWWClryRIGRYBqqDbYisbGlgyI5wEVmGH5wIWwfbxL3GG6cuvexxkd0Y3yGjgwhZT8EzadZTeHTkcUkVbb1fixsIbMyyQitVck7giv9UYBWBb7wVXWMyomR8LuUB9(LuexxQsPKiAS173)q7WhHpS(s0Qxbb8H(xIJmNqM(LqLLEnccLbmm3se2Qi4Q8geuxGmT6vqaXatm8UfaT8nFlVxfWWClryRIGRYBqqDbYisbGlgyI5wEVmGH5wIWwfbxL3GG6cuFOg7zGw(gdmXW6yUL3ldyyULiSvrWv5niOUa5ssmWedtfz6vqz3aPQ3vEdEly36ng2eZHzLVKYDR3V0d1y)2c)7FODyw5dRVeT6vqaFO)L4iZjKPFjMkY0RGYUbsvVR8g8wWU1BmYkDmmWxs5U17xIRcrv5U1Bvyy)ljmSxxfK(s8g8wWU1Bn5uX03)q7WWlFy9LOvVcc4d9VehzoHm9lDlVxgvwQ2VAslNqzGw(gdmXW6yUL3l)meH9gbMljXatmhhdtfz6vqz3aPQ3vEdEly36ng2KoMB59YOYs1(vtA5ekduqQB9gdmXWurMEfu2nqQ6DL3G3c2TEJHnXOC36n)mevVcf75xriQiIFQiiu1nqkgwyjgMkY0RGYUbsvVR8g8wWU1BmSjMNb50RicuTfhdu(sk3TE)sOYs1(vtA5e67FODy2IpS(s0Qxbb8H(xQt(syY)sk3TE)smvKPxb9LkyQ2Vxfch4dTu)smvuDvq6l9mevVcf71KUf2c5lbqyoYsCR3VKSNIm9kOy8t1JH3RJAbogg0qumqxOypMcwHqX4Dm0IlikgZXXWpveechts3cciMxJIb2n4TGDR38xQGPQ8ttqvUIDBH8HwQFjMQOqFjMkY0RGYUbsvVR8g8wWU1BmhAmhsmYkgL7wV5NHO6vOyp)kcrfr8tfbHQUbsXCOXOC36nJpTNBlKAslNq5xriQicOWDR3yG6XWurMEfugFAp3wi1KwoHQx61iQYBWBb7wVXatmmvKPxbLDdKQEx5n4TGDR3yKvmpdYPxreOAl(7FODyOYpS(s0Qxbb8H(xQt(syY)sk3TE)smvKPxb9LyQO6QG0xk5SP1sPM0TWwiFjoYCcz6xs5UXKQ0sGgHJrwXWurMEfuM3G3c2TERpHcsyhzYqFjacZrwIB9(LK9uKPxbfJFQEm8EDulWXavpBATuIHbfkiHJPGviumEhdT4cIIXCCm8tfbHWXOikMKUfeqmVgfdSBWBb7wV5yGxxbCXuWumq1ZMwlLyyqHcs4y6IJnakM(fdSBWBb7wVXi)K2yEfHig(PIGq4y46gZLIPVUAlbedqbzlKy8tkMLsXJb2n4TGDR38xIPkk0xIPIm9kOSBGu17kVbVfSB9gd8J5wEVmVbVfSB9Mbki1TEJ5qJHvIrwXOC36nNC20APuFcfKW5xriQiIFQiiu1nqkg4hdVBbqlFZjNnTwk1NqbjCgOGu36nMdngL7wVz8P9CBHutA5ek)kcrfrafUB9gdupgMkY0RGY4t752cPM0Yju9sVgrvEdEly36ngyIHPIm9kOSBGu17kVbVfSB9gJSI5zqo9kIavBXXWclXGkl9AeekJlBvgBHGRxbHX2cjtREfeqmSWsmUbsXiRyyLV)H2HzB(W6lrREfeWh6FPo5lHj)lPC369lXurMEf0xIPIQRcsFPKZMwlLAs3cBH8L4iZjKPFjL7gtQslbAeog2KogMkY0RGY8g8wWU1B9juqc7itg6lbqyoYsCR3VeuZjTXuW2cjgguOGe2rMmum2gdSBWBb7wVmgdwzsXO4ya1fUy4NkccHJrXXK0ySDfumVgfdSBWBb7wVXi38ZU4XW1KeBHK)smvrH(smvKPxbLDdKQEx5n4TGDR3yKvmk3TEZjNnTwk1NqbjC(veIkI4NkccvDdKI5qJr5U1BgFAp3wi1KwoHYVIqureqH7wVXa1JHPIm9kOm(0EUTqQjTCcvV0RruL3G3c2TEJbMyyQitVck7giv9UYBWBb7wVXiRyEgKtVIiq1wCmSWsmOYsVgbHY4YwLXwi46vqySTqY0QxbbedlSeJBGumYkgw57FODimWhwFjA1RGa(q)lXrMtit)s3Y7LrLLQ9RM0YjuUKedmXWurMEfu2nqQ6DL3G3c2TEJHnXWaFjSJmU)HwQFjL7wVFjUkevL7wVvHH9VKWWEDvq6lH6KAYPIPV)H2HK6hwFjA1RGa(q)lvWuv(PjOkxXUTq(ql1VeaH5ilXTE)sSvaOwfShJFsXWurMEfum(P6XW71rTahddAikgOluShtbRqOy8ogAXfefJ54y4NkccHJrrumQa3XK0TGaI51OyGkklft)IbQ2Yju(l1jFjm5FjoYCcz6xI1XWurMEfu(ziQEfk2RjDlSfsmWeJRcA9mQSuTF1KwoHY0QxbbedmXClVxgvwQ2VAslNqzGw((LyQIc9L4DlaA5BgvwQ2VAslNqzebQ2IJrwXOC36n)mevVcf75xriQiIFQiiu1nqkMdngL7wVz8P9CBHutA5ek)kcrfrafUB9gdupMJJHPIm9kOm(0EUTqQjTCcvV0RruL3G3c2TEJbMy4DlaA5BgFAp3wi1KwoHYicuTfhJSIH3TaOLVzuzPA)QjTCcLreOAlogOedmXW7wa0Y3mQSuTF1KwoHYicuTfhJSI5zqo9kIavBXFPcMQ97vHWb(ql1VKYDR3Vetfz6vqFjMkQUki9LEgIQxHI9As3cBH89p0oKd)H1xIw9kiGp0)sfmvLFAcQYvSBlKp0s9lXrMtit)sSogMkY0RGYpdr1RqXEnPBHTqIbMyyQitVck7giv9UYBWBb7wVXWMyyGyGjgL7gtQslbAeog2KogMkY0RGYNkcOYvSxFcfKWoYKHIbMyyDmpdryxroHYk3nMumWedRJ5wEV8z7vSJivMCjjgyI54yUL3lFsQBlKAjjxsIbMyuUB9MFcfKWoYKHYukeV4ufrGQT4yKvmmqMvIHfwIHFQiieU(qk3TEvrmSjDmhogO8LkyQ2Vxfch4dTu)sk3TE)spdr1RqX(xcGWCKL4wVFjOMtAJ5iRiaUIDBHeddkuqkgjhzYqmgddAikgOluSJJbF2fbqmxkMcMaIX7yGqlHuNI5i3EmsoIuzWXOlqmEhdLItlqmqxOyNqXi7RyNq5V)H2HCiFy9LOvVcc4d9Vubtv5NMGQCf72c5dTu)sCK5eY0V0Zqe2vKtOSYDJjfdmXWpveechdBshtQXatmSogMkY0RGYpdr1RqXEnPBHTqIbMyoogwhJYDR38Zq0vfImLcXlUTqIbMyyDmk3TEZjWH6RqXE226tyqo9yGjMB59YNK62cPwsYLKyyHLyuUB9MFgIUQqKPuiEXTfsmWedRJ5wEV8z7vSJivMCjjgwyjgL7wV5e4q9vOypBB9jmiNEmWeZT8E5tsDBHulj5ssmWedRJ5wEV8z7vSJivMCjjgO8LkyQ2Vxfch4dTu)sk3TE)spdr1RqX(xcGWCKL4wVFjzxbzlKyyqdryxroHymgg0qumqxOyhhJIOykycigSbAcfjGlgVJbOGSfsmWUbVfSB9MJ5iIwcPcbCmgJFsWfJIOykycigVJbcTesDkMJC7Xi5isLbhJ8tAJHJmhhJCtiIzBpMlfJCf7eqm6ceJCZpJb6cf7ekgzFf7eIXy8tcUyWNDraeZLIbNGifiMU4X4DmGQTUABm(jfd0fk2jumY(k2jum3Y7L)(hAhYr4dRVeT6vqaFO)LkyQk)0euLRy3wiFOL6xcGWCKL4wVFj2kZ2aIHRjj2cjgg0qumqxOypg(PIGq4yKFAckg(PUljSfsmsN2ZTfsmq1woH(sk3TE)spdr1RqX(xIJmNqM(LuUB9MXN2ZTfsnPLtOmLcXlUTqIbMyEfHOIi(PIGqv3aPyKvmk3TEZ4t752cPM0Yju2nUmvebu4U1BmWeZT8E5Z2RyhrQmzGw(gdmX4gifdBIjvg47FODiSYhwFjA1RGa(q)lXrMtit)smvKPxbLDdKQEx5n4TGDR3yytmmqmWeZT8EzuzPA)QjTCcLbA57xs5U17xIRcrv5U1Bvyy)ljmSxxfK(syxxafburTRU173)q7qGx(W6lPC369lH5nIF(LOvVcc4d9V)9VeQtQjNkM(W6dTu)W6lrREfeWh6FjoYCcz6xs5UXKQ0sGgHJHnPJHPIm9kO8z7vSJivM6tOGe2rMmumWeZXXClVx(S9k2rKktUKedlSeZT8E5NHiS3iWCjjgO8LuUB9(LEcfKWoYKH((hAh(dRVeT6vqaFO)L4iZjKPFPB59Y4YwLXwi46vqySTqQisbGlxsIbMyUL3lJlBvgBHGRxbHX2cPIifaUmIavBXXWMy4k2RUbsFjL7wVFPe4q9vOy)7FODiFy9LOvVcc4d9VehzoHm9lDlVx(zic7ncmxs(sk3TE)sjWH6RqX(3)q7i8H1xIw9kiGp0)sCK5eY0V0T8E5Z2RyhrQm5sYxs5U17xkbouFfk2)(hASYhwFjA1RGa(q)lvWuv(PjOkxXUTq(ql1VehzoHm9lX6yyQitVck)mevVcf71KUf2cjgyI5wEVmUSvzSfcUEfegBlKkIua4YaT8ngyIr5UXKQ0sGgHJrwXWurMEfu(uravUI96tOGe2rMmumWedRJ5zic7kYjuw5UXKIbMyoogwhZT8E5tsDBHulj5ssmWedRJ5wEV8z7vSJivMCjjgyIH1XKGiM1(9Qq4a5NHO6vOypgyI54yuUB9MFgIQxHI9m)urqiCmSjDmhogwyjMJJXvbTEwfukyhP4JykU(ki4Y0QxbbedmXW7wa0Y3masH0lUErK6NzePaWfduIHfwIbtkYwivVl8ZSYDJjfduIbkFPcMQ97vHWb(ql1VKYDR3V0Zqu9kuS)LaimhzjU17xITetX0lfddAikgOluShdPibCXyBmqfnung7fdCDjgGEpWJ5uzsXqMFsOyoYK62cjg2YKyAumh52JrYrKktmWrEm6cedz(jHKTyowHsmNktkgWgrX4N6gJlVJrfisbGJXyo(cLyovMumSvbLc2rk(iMEaoggSGGlgePaWfJ3XuWeJX0OyoMdLyKifzlKyGvx4NXy4yuUBmPCmYUEpWJbOJXpnCmYpnbfZPIaIHRy3wiXWGcfKWoYKHWX0OyKFsBmsLng2wBHCaogOlim2wiXy4yqKcax(7FObV8H1xIw9kiGp0)sfmvLFAcQYvSBlKp0s9lXrMtit)sSogMkY0RGYpdr1RqXEnPBHTqIbMyyDmpdryxroHYk3nMumWeZXXCCmhhJYDR38Zq0vfImLcXlUTqIbMyoogL7wV5NHORkezkfIxCQIiq1wCmYkggiZkXWclXW6yqLLEnccLFgIWEJaZ0QxbbeduIHfwIr5U1BobouFfk2ZukeV42cjgyI54yuUB9MtGd1xHI9mLcXlovreOAlogzfddKzLyyHLyyDmOYsVgbHYpdryVrGzA1RGaIbkXaLyGjMB59YNK62cPwsYLKyGsmSWsmhhdMuKTqQEx4NzL7gtkgyI54yUL3lFsQBlKAjjxsIbMyyDmk3TEZyEJ4NzkfIxCBHedlSedRJ5wEV8z7vSJivMCjjgyIH1XClVx(Ku3wi1ssUKedmXOC36nJ5nIFMPuiEXTfsmWedRJ5S9k2rKktfNqcbUAB9jmiNEmqjgOedu(sfmv73RcHd8HwQFjL7wVFPNHO6vOy)lbqyoYsCR3VeBjMIHbnefd0fk2JHm)KqXauq2cjgngg0q0vfcgcvHd1xHI9y4k2Jr(jTXCKj1TfsmSLjXy4yuUBmPyAumafKTqIHsH4fNIrU5NXirkYwiXaRUWpZF)dn2IpS(s0Qxbb8H(xs5U17xIRcrv5U1Bvyy)ljmSxxfK(sk3nMu1vbTo(7FObv(H1xIw9kiGp0)sCK5eY0V0T8E5e4qnxOyWCjjgyIHRyV6gifJSI5wEVCcCOMlumygrGQT4yGjgUI9QBGumYkMB59YOYs1(vtA5ekJiq1w8xs5U17xkbouFfk2)(hASnFy9LOvVcc4d9VehzoHm9lDlVx(S9k2rKktUKedmXGjfzlKQ3f(zw5UXKIbMyuUBmPkTeOr4yKvmmvKPxbLpBVIDePYuFcfKWoYKH(sk3TE)sjWH6RqX(3)qlvg4dRVeT6vqaFO)L4iZjKPFjwhdtfz6vq5KZMwlLAs3cBHedmXClVx(Ku3wi1ssUKedmXW6yUL3lF2Ef7isLjxsIbMyoogL7gtQc0E2GSMtXiRyoCmSWsmk3nMuLwc0iCmSjDmmvKPxbLpveqLRyV(ekiHDKjdfdlSeJYDJjvPLanchdBshdtfz6vq5Z2RyhrQm1NqbjSJmzOyGYxs5U17xk5SP1sP(ekiH)(hAPM6hwFjA1RGa(q)lXrMtit)sysr2cP6DHFMvUBmPVKYDR3VeM3i(53)ql1d)H1xIw9kiGp0)sCK5eY0VKYDJjvPLanchdBI5WFjL7wVFjaKcPxC9Ii1p)(hAPEiFy9LOvVcc4d9VehzoHm9lPC3ysvAjqJWXWM0XWurMEfuwrCDPkLsIOXwVXatmG6Q5eUhdBshdtfz6vqzfX1LQukjIgB9wb1v)sk3TE)skIRlvPusen2697FOL6r4dRVeT6vqaFO)LuUB9(LEcfKWoYKH(saeMJSe369lb1y(zm02fiNX4kcc5ygJX8ymCmAmquBJX7y4k2JHbfkiHDKjdfJIJ5zcbHIXwStkqm9lgg0q0vfI8xIJmNqM(LuUBmPkTeOr4yyt6yyQitVckFQiGkxXE9juqc7itg67FOLkR8H1xs5U17x6zi6QcXxIw9kiGp0)(3)s8g8wWU1Bn5uX0hwFOL6hwFjA1RGa(q)lXrMtit)s3Y7L5n4TGDR3mqlF)sk3TE)scdYPJRqTkaqaP1)(hAh(dRVeT6vqaFO)LkyQk)0euLRy3wiFOL6xcGWCKL4wVFPJe2nq1PyoB5Xi6fsmWUbVfSB9gJCtiIrOypg)uxzWX4DmsLng2wBHCaogOlim2wiX4DmaKtiqBPyoB5XWGgIIb6cf74yWNDraeZLIPGjG8xQt(syY)sCK5eY0VeVxGI5zBFeAvrLRyUcqzA1RGa(smvrH(s3Y7L5n4TGDR3mIavBXXa)yUL3lZBWBb7wVzGcsDR3yG6XCCm8UfaT8nZBWBb7wVzebQ2IJrwXClVxM3G3c2TEZicuTfhdu(sfmv73RcHd8HwQFjL7wVFjMkY0RG(smvuDvq6lrP40cqavEdEly36TIiq1w83)q7q(W6lrREfeWh6FPcMQYpnbv5k2TfYhAP(LaimhzjU17xITcaGJXpPyaki1TEJPFX4NumsLng2wBHCaogOlim2wiXa7g8wWU1BmEhJFsXqlqm9lg)KIHxqiA9yGDdEly36ng7fJFsXWvShJ8UiaIH3GjcYPyakiBHeJFA4yGDdEly36n)L6KVKca8L4iZjKPFjEVafZZ2(i0QIkxXCfGY0QxbbedmXCCm3Y7LXLTkJTqW1RGWyBHurKcaxUKedlSedtfz6vqzkfNwacOYBWBb7wVvebQ2IJHnXKAMvIbQhdeoqgutjgOEmhhZT8EzCzRYyleC9kim2wizqnLk2vUmXCOXClVxgx2Qm2cbxVccJTfsg7kxMyGsmq5lXuff6lXurMEfuglZTcuqQB9(LkyQ2Vxfch4dTu)sk3TE)smvKPxb9LyQO6QG0xIsXPfGaQ8g8wWU1BfrGQT4V)H2r4dRVeT6vqaFO)L4iZjKPFPB59Y8g8wWU1BgOLVFjL7wVFPRcP2VQJmUm4V)HgR8H1xIw9kiGp0)sCK5eY0VKYDJjvPLanchdBIj1yGjMB59Y8g8wWU1BgOLVFjL7wVFjHX0wi1BdE)(hAWlFy9LOvVcc4d9Vubtv5NMGQCf72c5dTu)sCK5eY0VeRJH3lqX8STpcTQOYvmxbOmT6vqaXatm8tfbHWXWM0XKAmWeZT8EzEdEly36nxsIbMyyDm3Y7LFgIWEJaZLKyGjgwhZT8E5Z2RyhrQm5ssmWeZz7vSJivMkoHecC126tyqo9yGFm3Y7Lpj1TfsTKKljXiRyo8xQGPA)EviCGp0s9lPC369l9mevVcf7FjacZrwIB9(LGAm)SlEmS99rOvfXaBfZvaIXyGAvWEmfmfddAikgOluSJJr(jTX4NeCXiV3d8yall)mgoYCCm6ceJ8tAJHbneH9gbgJHJbOLV5V)HgBXhwFjA1RGa(q)lvWuv(PjOkxXUTq(ql1VeaH5ilXTE)sqnMFgdBFFeAvrmWwXCfGymgg0qumqxOypMcMIbF2fbqmxkgfaWCRxviGlgEVyhP2saXG7y8t1JX8ymCmB7XCPykyciMYkimog2((i0QIyGTI5kafJHJrVDXJX7yOusmeftJIXpjefJIOyaBefJFQBm02fiNXWGgIIb6cf74y8ogkfNwGyy77JqRkIb2kMRaumEhJFsXqlqm9lgy3G3c2TEZFPo5lHj)lXrMtit)s8EbkMNT9rOvfvUI5kaLPvVcc4lXuff6lPC36n)mevVcf7z(PIGq46dPC36vfXa)yoogMkY0RGYukoTaeqL3G3c2TERicuTfhZHgZT8EzBFeAvrLRyUcqzGcsDR3yGsmmmgE3cGw(MFgIQxHI9mqbPU17xQGPA)EviCGp0s9lPC369lXurMEf0xIPIQRcsFjkLeI7eq9ziQEfk2XF)dnOYpS(s0Qxbb8H(xQt(syY)sk3TE)smvKPxb9LkyQ2Vxfch4dTu)smvuDvq6lTebqa1NHO6vOyh)L4iZjKPFjEVafZZ2(i0QIkxXCfGY0Qxbb8LkyQk)0euLRy3wiFOL6xIPkk0xItMiMJJHPIm9kOmLItlabu5n4TGDR3kIavBXXWWyooMB59Y2(i0QIkxXCfGYafK6wVXCOXaHdKb1uIbkXaLV)HgBZhwFjA1RGa(q)lvWuv(PjOkxXUTq(ql1VehzoHm9lX7fOyE22hHwvu5kMRauMw9kiGyGjg(PIGq4yyt6ysngyI54yyQitVcktPKqCNaQpdr1RqXoog2KogMkY0RGYlraeq9ziQEfk2XXWclXWurMEfuMsXPfGaQ8g8wWU1BfrGQT4yKv6yUL3lB7JqRkQCfZvakduqQB9gdlSeZT8EzBFeAvrLRyUcqzSRCzIrwXC4yyHLyUL3lB7JqRkQCfZvakJiq1wCmYkgiCGmOMsmSWsm8UfaT8nJpTNBlKAslNqzePaWfdmXOC3ysvAjqJWXWM0XWurMEfuM3G3c2TER4t752cPM0YjumWedVzsRUEEniNE9PumqjgyI5wEVmVbVfSB9MljXatmhhdRJ5wEV8Zqe2BeyUKedlSeZT8EzBFeAvrLRyUcqzebQ2IJrwXWazwjgOedmXW6yUL3lF2Ef7isLjxsIbMyoBVIDePYuXjKqGR2wFcdYPhd8J5wEV8jPUTqQLKCjjgzfZH)sfmv73RcHd8HwQFjL7wVFPNHO6vOy)7FOLkd8H1xIw9kiGp0)sk3TE)s8USoHWjKq8LaimhzjU17xcQIOefrXi7mm3se2Qi4Ib2niOUaX8AumWUbVfSB9MJbATtX4NQhJFsXavuwkM(fduTLtOyEOgmgy3G3c2TEJH3L1XXO4y0ng2kIRlfdoHecgJb3XWwrCDPyWjKqGJrrum9kGlML4egRi4IXEX4NQhJRcA9ymCmB7XuWeq(lXrMtit)sOYsVgbHYagMBjcBveCvEdcQlqMw9kiGyGjMB59YagMBjcBveCvEdcQlqgOLVXatm3Y7Lbmm3se2Qi4Q8geuxGQI46szGw(gdmXW7wa0Y38T8EvadZTeHTkcUkVbb1fiJifaUyGjgwhJRcA9mQSuTF1KwoHY0Qxbb89p0sn1pS(s0Qxbb8H(xIJmNqM(LqLLEnccLbmm3se2Qi4Q8geuxGmT6vqaXatm3Y7Lbmm3se2Qi4Q8geuxGmqlFJbMyUL3ldyyULiSvrWv5niOUavfX1LYaT8ngyIH3TaOLV5B59QagMBjcBveCvEdcQlqgrkaCXatmSogxf06zuzPA)QjTCcLPvVcc4lPC369lPiUUuLsjr0yR3V)HwQh(dRVeT6vqaFO)L4iZjKPFjuzPxJGqzadZTeHTkcUkVbb1fitREfeqmWeZT8EzadZTeHTkcUkVbb1fid0Y3yGjMB59YagMBjcBveCvEdcQlq9HASNbA57xs5U17x6HASFBH)9p0s9q(W6lrREfeWh6FjoYCcz6xcvw61iiugcYWc4Qg34cktREfeqmWeZT8EzEdEly36nd0Y3VKYDR3V0d1yVUnt97FOL6r4dRVeT6vqaFO)LuUB9(L4QquvUB9wfg2)scd71vbPVKYDJjvDvqRJ)(hAPYkFy9LOvVcc4d9Vubtv5NMGQCf72c5dTu)sCK5eY0V0T8EzEdEly36nd0Y3yGjMJJH1XGkl9AeekdyyULiSvrWv5niOUazA1RGaIHfwI5wEVmGH5wIWwfbxL3GG6cKljXWclXClVxgWWClryRIGRYBqqDbQpuJ9CjjgyIXvbTEgvwQ2VAslNqzA1RGaIbMy4DlaA5B(wEVkGH5wIWwfbxL3GG6cKrKcaxmqjgyI54yyDmOYsVgbHYqqgwax14gxqzA1RGaIHfwIbGUL3ldbzybCvJBCbLljXaLyGjMJJr5U1BgKCQrzBRpHb50JbMyuUB9MbjNAu226tyqo9kIavBXXiR0XWurMEfuM3G3c2TERCf7vebQ2IJHfwIr5U1BgZBe)mtPq8IBlKyGjgL7wVzmVr8ZmLcXlovreOAlogzfdtfz6vqzEdEly36TYvSxreOAlogwyjgL7wV5NHORkezkfIxCBHedmXOC36n)meDvHitPq8ItvebQ2IJrwXWurMEfuM3G3c2TERCf7vebQ2IJHfwIr5U1BobouFfk2ZukeV42cjgyIr5U1BobouFfk2ZukeV4ufrGQT4yKvmmvKPxbL5n4TGDR3kxXEfrGQT4yyHLyuUB9MFcfKWoYKHYukeV42cjgyIr5U1B(juqc7itgktPq8ItvebQ2IJrwXWurMEfuM3G3c2TERCf7vebQ2IJbkFPcMQ97vHWb(ql1VKYDR3VeVbVfSB9(9p0sfE5dRVeT6vqaFO)LaimhzjU17xcE1pjum8UfaT8fhJFQEm4ZUiaI5sXuWeqmYn)mgy3G3c2TEJbF2fbqm9kGlMlftbtaXi38Zy0ngL7fvedSBWBb7wVXWvShJUaXSThJCZpJrJrQSXW2AlKdWXaDbHX2cjMeuZZFjL7wVFjUkevL7wVvHH9VehzoHm9lDlVxM3G3c2TEZicuTfhdBIbQmgwyjgE3cGw(M5n4TGDR3mIavBXXiRyyLVKWWEDvq6lXBWBb7wVvE3cGw(I)(hAPYw8H1xIw9kiGp0)sCK5eY0V0XXClVx(S9k2rKktUKedmXOC3ysvAjqJWXWM0XWurMEfuM3G3c2TERpHcsyhzYqXaLyyHLyooMB59YpdryVrG5ssmWeJYDJjvPLanchdBshdtfz6vqzEdEly36T(ekiHDKjdfZHgdQS0RrqO8Zqe2BeyMw9kiGyGYxs5U17x6juqc7itg67FOLku5hwFjA1RGa(q)lXrMtit)s3Y7LXLTkJTqW1RGWyBHurKcaxUKedmXClVxgx2Qm2cbxVccJTfsfrkaCzebQ2IJHnXWvSxDdK(sk3TE)sjWH6RqX(3)qlv2MpS(s0Qxbb8H(xIJmNqM(LUL3l)meH9gbMljFjL7wVFPe4q9vOy)7FODyg4dRVeT6vqaFO)L4iZjKPFPB59YjWHAUqXG5ssmWeZT8E5e4qnxOyWmIavBXXWMy4k2RUbsXatmhhZT8EzEdEly36nJiq1wCmSjgUI9QBGumSWsm3Y7L5n4TGDR3mqlFJbkXatmk3nMuLwc0iCmYkgMkY0RGY8g8wWU1B9juqc7itg6lPC369lLahQVcf7F)dTdN6hwFjA1RGa(q)lXrMtit)s3Y7LpBVIDePYKljXatm3Y7L5n4TGDR3Cj5lPC369lLahQVcf7F)dTdF4pS(s0Qxbb8H(xIJmNqM(LsqeZkeoqo1mM3i(zmWeZT8E5tsDBHulj5ssmWeJYDJjvPLanchJSIHPIm9kOmVbVfSB9wFcfKWoYKH(sk3TE)sjWH6RqX(3)q7WhYhwFjA1RGa(q)lPC369lHpTNBlKAslNqFjBDcHkjE1EFjL7wV5NHO6vOypZpveecNw5U1B(ziQEfk2ZGAkv(PIGq4VehzoHm9lDlVxM3G3c2TEZLKyGjgwhJYDR38Zqu9kuSN5NkccHJbMyuUBmPkTeOr4yyt6yyQitVckZBWBb7wVv8P9CBHutA5ekgyIr5U1Bo5SP1sP(ekiHZVIqure)urqOQBGumSjMxriQicOWDR3VeaH5ilXTE)sSLyBHeJ0P9CBHeduTLtOyakiBHedSBWBb7wVX4Dmic7nIIHbnefd0fk2JrxGyGQNnTwkXWGcfKIHFQiieogUUXCPyU0spJBQGXyUfpMcUOcbCX0RaUy6ng2AFKYF)dTdFe(W6lrREfeWh6FjoYCcz6x6wEVmVbVfSB9MljXatmoszsIQBGumYkMB59Y8g8wWU1BgrGQT4yGjMJJ54yuUB9MFgIQxHI9m)urqiCmYkMuJbMyCvqRNtGd1CHIbZ0QxbbedmXOC3ysvAjqJWXKoMuJbkXWclXW6yCvqRNtGd1CHIbZ0QxbbedlSeJYDJjvPLanchdBIj1yGsmWeZT8E5tsDBHulj5ssmWpMZ2RyhrQmvCcje4QT1NWGC6XiRyo8xs5U17xk5SP1sP(ekiH)(hAhMv(W6lrREfeWh6FjoYCcz6x6wEVmVbVfSB9MbA5BmWedVBbqlFZ8g8wWU1BgrGQT4yKvmCf7v3aPyGjgL7gtQslbAeog2KogMkY0RGY8g8wWU1B9juqc7itg6lPC369l9ekiHDKjd99p0om8YhwFjA1RGa(q)lXrMtit)s3Y7L5n4TGDR3mqlFJbMy4DlaA5BM3G3c2TEZicuTfhJSIHRyV6gifdmXW6y49cump)ekivvohrU1BMw9kiGVKYDR3V0Zq0vfIV)H2Hzl(W6lrREfeWh6FjoYCcz6x6wEVmVbVfSB9MreOAlog2edxXE1nqkgyI5wEVmVbVfSB9MljXWclXClVxM3G3c2TEZaT8ngyIH3TaOLVzEdEly36nJiq1wCmYkgUI9QBG0xs5U17xcZBe)87FODyOYpS(s0Qxbb8H(xIJmNqM(LUL3lZBWBb7wVzebQ2IJrwXaHdKb1uIbMyuUBmPkTeOr4yytmP(LuUB9(LegtBHuVn497FODy2MpS(s0Qxbb8H(xIJmNqM(LUL3lZBWBb7wVzebQ2IJrwXaHdKb1uIbMyUL3lZBWBb7wV5sYxs5U17xcaPq6fxVis9ZV)H2HWaFy9LOvVcc4d9VehzoHm9lHjfzlKQ3f(zw5UXK(sk3TE)syEJ4NF)7FjL7gtQ6QGwh)H1hAP(H1xIw9kiGp0)sCK5eY0VKYDJjvPLanchdBIj1yGjMB59Y8g8wWU1BgOLVXatmhhdtfz6vqz3aPQ3vEdEly36ng2edVBbqlFZcJPTqQ3g8Mbki1TEJHfwIHPIm9kOSBGu17kVbVfSB9gJSshddedu(sk3TE)scJPTqQ3g8(9p0o8hwFjA1RGa(q)lXrMtit)smvKPxbLDdKQEx5n4TGDR3yKv6yyGyyHLyoogE3cGw(MbjNAugOGu36ngzfdtfz6vqz3aPQ3vEdEly36ngyIH1X4QGwpJklv7xnPLtOmT6vqaXaLyyHLyCvqRNrLLQ9RM0YjuMw9kiGyGjMB59YOYs1(vtA5ekxsIbMyyQitVck7giv9UYBWBb7wVXWMyuUB9MbjNAuM3TaOLVXWclX8miNEfrGQT4yKvmmvKPxbLDdKQEx5n4TGDR3VKYDR3Vei5uJ((hAhYhwFjA1RGa(q)lXrMtit)sUkO1ZQGsb7ifFetX1xbbxMw9kiGyGjMJJ5wEVmVbVfSB9MbA5BmWedRJ5wEV8z7vSJivMCjjgO8LuUB9(LaqkKEX1lIu)87F)lHDDbueqf1U6wVFy9HwQFy9LOvVcc4d9VehzoHm9lPC3ysvAjqJWXWM0XWurMEfu(S9k2rKkt9juqc7itgkgyI54yUL3lF2Ef7isLjxsIHfwI5wEV8Zqe2BeyUKedu(sk3TE)spHcsyhzYqF)dTd)H1xIw9kiGp0)sCK5eY0V0T8E5NHiS3iWCj5lPC369lLahQVcf7F)dTd5dRVeT6vqaFO)L4iZjKPFPB59YNTxXoIuzYLKyGjMB59YNTxXoIuzYicuTfhJSIr5U1B(zi6QcrMsH4fNQUbsFjL7wVFPe4q9vOy)7FODe(W6lrREfeWh6FjoYCcz6x6wEV8z7vSJivMCjjgyI54ysqeZkeoqo18Zq0vfIyyHLyEgIWUICcLvUBmPyyHLyuUB9MtGd1xHI9ST1NWGC6XaLVKYDR3VucCO(kuS)9p0yLpS(s0Qxbb8H(xs5U17xkbouFfk2)saeMJSe369lbleCX4Dmqipgj2wOhtcQ54ySfBaumqfnunMKtft4yAumWUbVfSB9gtYPIjCmYpPnMKgJTRGYFjoYCcz6x6wEVmUSvzSfcUEfegBlKkIua4YLKyGjMJJH3TaOLVzuzPA)QjTCcLreOAlog4hJYDR3mQSuTF1KwoHYukeV4u1nqkg4hdxXE1nqkg2eZT8EzCzRYyleC9kim2wivePaWLreOAlogwyjgwhJRcA9mQSuTF1KwoHY0QxbbeduIbMyyQitVck7giv9UYBWBb7wVXa)y4k2RUbsXWMyUL3lJlBvgBHGRxbHX2cPIifaUmIavBXF)dn4LpS(s0Qxbb8H(xIJmNqM(LUL3lF2Ef7isLjxsIbMyWKISfs17c)mRC3ysFjL7wVFPe4q9vOy)7FOXw8H1xIw9kiGp0)sCK5eY0V0T8E5e4qnxOyWCjjgyIHRyV6gifJSI5wEVCcCOMlumygrGQT4VKYDR3VucCO(kuS)9p0Gk)W6lrREfeWh6FPcMQYpnbv5k2TfYhAP(L4iZjKPFjwhZZqe2vKtOSYDJjfdmXW6yyQitVck)mevVcf71KUf2cjgyI54yooMJJr5U1B(zi6QcrMsH4f3wiXatmhhJYDR38Zq0vfImLcXlovreOAlogzfddKzLyyHLyyDmOYsVgbHYpdryVrGzA1RGaIbkXWclXOC36nNahQVcf7zkfIxCBHedmXCCmk3TEZjWH6RqXEMsH4fNQicuTfhJSIHbYSsmSWsmSoguzPxJGq5NHiS3iWmT6vqaXaLyGsmWeZT8E5tsDBHulj5ssmqjgwyjMJJbtkYwivVl8ZSYDJjfdmXCCm3Y7Lpj1TfsTKKljXatmSogL7wVzmVr8ZmLcXlUTqIHfwIH1XClVx(S9k2rKktUKedmXW6yUL3lFsQBlKAjjxsIbMyuUB9MX8gXpZukeV42cjgyIH1XC2Ef7isLPItiHaxTT(egKtpgOeduIbkFPcMQ97vHWb(ql1VKYDR3V0Zqu9kuS)LaimhzjU17xs2vq2cjg)KIb76cOiGyqTRU1lJX0RaUykykgg0qumqxOyhhJ8tAJXpj4IrrumB7XCjBHets3cciMxJIbQOHQX0OyGDdEly36nhdBjMIHbnefd0fk2JHm)KqXauq2cjgngg0q0vfcgcvHd1xHI9y4k2Jr(jTXCKj1TfsmSLjXy4yuUBmPyAumafKTqIHsH4fNIrU5NXirkYwiXaRUWpZF)dn2MpS(s0Qxbb8H(xIJmNqM(LUL3lF2Ef7isLjxsIbMyuUBmPkTeOr4yKvmmvKPxbLpBVIDePYuFcfKWoYKH(sk3TE)sjWH6RqX(3)qlvg4dRVeT6vqaFO)L4iZjKPFjwhdtfz6vq5KZMwlLAs3cBHedmXCCmSogxf065hQbR(jvv8jHZ0QxbbedlSeJYDJjvPLanchdBIj1yGsmWeZXXOC3ysvG2ZgK1CkgzfZHJHfwIr5UXKQ0sGgHJHnPJHPIm9kO8PIaQCf71NqbjSJmzOyyHLyuUBmPkTeOr4yyt6yyQitVckF2Ef7isLP(ekiHDKjdfdu(sk3TE)sjNnTwk1Nqbj83)ql1u)W6lrREfeWh6FjL7wVFjUkevL7wVvHH9VKWWEDvq6lPC3ysvxf064V)HwQh(dRVeT6vqaFO)L4iZjKPFjL7gtQslbAeog2etQFjL7wVFjaKcPxC9Ii1p)(hAPEiFy9LOvVcc4d9VehzoHm9lHjfzlKQ3f(zw5UXK(sk3TE)syEJ4NF)dTupcFy9LOvVcc4d9VehzoHm9lPC3ysvAjqJWXWM0XWurMEfuwrCDPkLsIOXwVXatmG6Q5eUhdBshdtfz6vqzfX1LQukjIgB9wb1v)sk3TE)skIRlvPusen2697FOLkR8H1xIw9kiGp0)sk3TE)spHcsyhzYqFjacZrwIB9(LGAm)mgA7cKZyCfbHCmJXyEmgogngiQTX4DmCf7XWGcfKWoYKHIrXX8mHGqXyl2jfiM(fddAi6Qcr(lXrMtit)sk3nMuLwc0iCmSjDmmvKPxbLpveqLRyV(ekiHDKjd99p0sfE5dRVKYDR3V0Zq0vfIVeT6vqaFO)9V)LsqeVbVQ)H1hAP(H1xs5U17xsrCDPQTojee3)s0Qxbb8H(3)q7WFy9LOvVcc4d9VuN8LWK)LuUB9(LyQitVc6lXur1vbPV0z7vSJivM6tOGe2rMm0xIJmNqM(LyQitVckF2Ef7isLP(ekiHDKjdft6yyGVeaH5ilXTE)sW60WXWurMEfum4eIBpJWX4NumBb8sOy6xmUIGqoog1Jr(PXpJ5i3EmsoIuzIHbfkiHDKjdHJPlo2aOy6xmWUbVfSB9gd(SlcGyUumfmbK)smvrH(shogOEmUkO1ZpHcs1e15NzA1RGaIb(XCiXa1JH1X4QGwp)ekivtuNFMPvVcc47FODiFy9LOvVcc4d9VuN8LWK)LuUB9(LyQitVc6lXur1vbPV0PIaQCf71NqbjSJmzOVehzoHm9lXurMEfu(uravUI96tOGe2rMmumPJHb(saeMJSe369lbRtdhdtfz6vqXGtiU9mchJFsXSfWlHIPFX4kcc54yupg5Ng)mMJSIaIb2k2JHbfkiHDKjdHJPlo2aOy6xmWUbVfSB9gd(SlcGyUumfmbeJIJ5zcbHYFjMQOqFPdhdupgxf065NqbPAI68ZmT6vqaXa)yoKyG6XW6yCvqRNFcfKQjQZpZ0Qxbb89p0ocFy9LOvVcc4d9VuN8LWK)LuUB9(LyQitVc6lXur1vbPVeVbVfSB9wFcfKWoYKH(sCK5eY0Vetfz6vqzEdEly36T(ekiHDKjdft6yyGVeaH5ilXTE)sW60WXWurMEfum4eIBpJWX4NumBb8sOy6xmUIGqoog1Jr(PXpJ5i3EmsoIuzIHbfkiHDKjdHJrrumfmbedqbzlKyGDdEly36n)LyQIc9LoKyG6X4QGwp)ekivtuNFMPvVccig4hd8smq9yyDmUkO1ZpHcs1e15NzA1RGa((hASYhwFjA1RGa(q)l1jFjm5FjL7wVFjMkY0RG(smvuDvq6lPiUUuLsjr0yR3VehzoHm9lXurMEfuwrCDPkLsIOXwVXKogg4lbqyoYsCR3VeSonCmmvKPxbfdoH42ZiCm(jfZwaVekM(fJRiiKJJr9yKFA8ZyyRiUUumhPusen26nMU4ydGIPFXa7g8wWU1Bm4ZUiaI5sXuWeq(lXuff6lX2W2edupgxf065NqbPAI68ZmT6vqaXa)yoCmq9yyDmUkO1ZpHcs1e15NzA1RGa((hAWlFy9LOvVcc4d9VuN8LqeM8VKYDR3Vetfz6vqFjMkQUki9LuexxQsPKiAS1Bfux9lbqpTi8V0rGb(saeMJSe369lbRtdhdtfz6vqXGtiU9mchJFsXKqioTUcHIPFXaQRgZLeT8yKFA8ZyyRiUUumhPusen26ng5MqeZ2EmxkMcMaYF)dn2IpS(s0Qxbb8H(xQt(sict(xs5U17xIPIm9kOVetfvxfK(sYylGWwivebu4U17xcGEAr4FjgiFe(saeMJSe369lb1y(zmST2ciSfcJXa7g8wWU17b4y4DlaA5BmYnHiMlfdIakCciMlCXOXG0fObJrb7Y6mgZT4X4NumBb8sOy6xmCK54yWUICCmmjeCXCAqoJrFoHIr5UXuDBHedSBWBb7wVXOlqmyrlhhdqlFJXB5kcahJFsXqlqm9lgy3G3c2TEpahdVBbqlFZXa1CsBmGQm2cjgaIByRxCm2gJFsXWwHQSkJXa7g8wWU17b4yqeOARTqIH3TaOLVXy4yqeqHtaXCHlg)0WX8qk3TEJX7yuoVlRhZRrXW2AlGWwi5V)Hgu5hwFjA1RGa(q)l1jFjm5FjL7wVFjMkY0RG(smvrH(sSYxcGWCKL4wVFjyDsXauqQB9gt)IrJrQSXW2AlKdWXaDbHX2cjgy3G3c2TEZFjMkQUki9LWYCRafK6wVF)dn2MpS(s0Qxbb8H(xQt(syY)sk3TE)smvKPxb9LyQIc9Li4DXssiGmeHcyQ3iC9QaqOyyHLyi4DXssiGmOY1lIQ4tI8kybB8yyHLyi4DXssiGSTyoQ46vqv4DrxVawbiMgNIHfwIHG3fljHaY4YEfDduvqYpHd7XWclXqW7ILKqazcmboePIAJawD5umSWsme8Uyjjeq(juqQ2V6vDxqXWclXqW7ILKqaz5Qm0siC9H6figwyjgcExSKeciBl2rfU3iCfWyAlvVKq8LyQO6QG0xI3G3c2TER9wly67FOLkd8H1xIw9kiGp0)sDYxcryY)sk3TE)smvKPxb9LyQO6QG0xIatGdrQO2iGvxovbiHc3xcGEAr4FPuHk)saeMJSe369lDKB5Xi6fsmx61ikgy3G3c2TEJbF2fbqmhjWe4qKkIbEfbS6YPyUumfmbCe)7FOLAQFy9LOvVcc4d9VuN8LWK)LuUB9(LyQitVc6lXur1vbPVuV1cMQ8I3V3xIJmNqM(LyQitVckZBWBb7wV1ERfm9LaimhzjU17x6i3YJr0lKyU0RrumWUbVfSB9gd(SlcGyCKTYqoog)u9yCKbbcHIrJbFQicigU6eKgbxm8UfaT8nMEJP9tcfJJSvgYXXSThZLIPGjGJ4FjMQOqFPdZaF)dTup8hwFjA1RGa(q)l1jFjm5FjL7wVFjMkY0RG(smvrH(shMv(sCK5eY0VebVlwscbKbvUErufFsKxblyJ)LyQO6QG0xQ3AbtvEX7377FOL6H8H1xIw9kiGp0)sDYxct(xs5U17xIPIm9kOVetvuOV0HzGyGFmmvKPxbLjWe4qKkQncy1LtvasOW9L4iZjKPFjcExSKecitGjWHivuBeWQlN(smvuDvq6l1BTGPkV49799p0s9i8H1xIw9kiGp0)sDYxcryY)sk3TE)smvKPxb9LyQO6QG0xI3G3c2TER4t752cPM0Yj0xcGEAr4FPd)LaimhzjU17xcwNumBb8sOy6xmUIGqoogPt752cjgOAlNqXGp7IaiMlftbtaX0BmafKTqIb2n4TGDR383)qlvw5dRVeT6vqaFO)L6KVeIWK)LuUB9(LyQitVc6lXur1vbPVeVbVfSB9w5k2RicuTf)LaONwe(xIbYSfFjacZrwIB9(LG1jfJBGumicuT1wiX0BmAmCf7Xi)K2yGDdEly36ngUUXCPykycigBJbt8EbW5V)HwQWlFy9LOvVcc4d9VKYDR3VeUlIQbznNqFjoYCcz6xI1XWurMEfuM3G3c2TER9wly6lTki9LWDruniR5e67FOLkBXhwFjL7wVFjqdHAu1avi0xIw9kiGp0)(hAPcv(H1xIw9kiGp0)sCK5eY0VeRJjbrmZjWH6RqX(xs5U17xkbouFfk2)(3)(xIjHWwVFODyg4WPYahMbGk)sYv0Ale8xcQHTcvan2o0oIKTyIbwNumgysJ8yEnkMdqDsn5uX0bXGi4DXqeqm4gKIrlEdQobed)uxieohSZQ2sXWkYwmWUxMeYjGyoWvbTE(OheJ3XCGRcA98rZ0QxbbCqmhNAkqjhSZQ2sXaViBXa7EzsiNaI5auzPxJGq5JEqmEhZbOYsVgbHYhntREfeWbXC8Htbk5G9GDOg2kub0y7q7is2IjgyDsXyGjnYJ51OyoaGEAr4hedIG3fdraXGBqkgT4nO6eqm8tDHq4CWoRAlftQYwmWUxMeYjGyoavw61iiu(OheJ3XCaQS0RrqO8rZ0QxbbCqmQhZrcELvJ54utbk5GDw1wkMdlBXa7EzsiNaI5axf065JEqmEhZbUkO1ZhntREfeWbXC8Htbk5GDw1wkgwr2Ib29YKqobeZbUkO1Zh9Gy8oMdCvqRNpAMw9kiGdI54utbk5GDw1wkg4fzlgy3ltc5eqmh4QGwpF0dIX7yoWvbTE(OzA1RGaoiMJtnfOKd2zvBPyylKTyGDVmjKtaXCaQS0RrqO8rpigVJ5auzPxJGq5JMPvVcc4Gyoo1uGsoyNvTLIbQu2Ib29YKqobeZbUkO1Zh9Gy8oMdCvqRNpAMw9kiGdI54utbk5GDw1wkMuHkLTyGDVmjKtaXizGWogmCRRPeduBO2X4DmSArJbSbkIcoMoHqQ3OyogQnuI54utbk5GDw1wkMuHkLTyGDVmjKtaXCaVxGI55JEqmEhZb8EbkMNpAMw9kiGdI54utbk5GDw1wkMdZaYwmWUxMeYjGyoG3lqX88rpigVJ5aEVafZZhntREfeWbXCCQPaLCWoRAlfZHpSSfdS7LjHCciMdqLLEnccLp6bX4DmhGkl9AeekF0mT6vqaheZXPMcuYb7SQTumh(qKTyGDVmjKtaXCaQS0RrqO8rpigVJ5auzPxJGq5JMPvVcc4Gyoo1uGsoyNvTLI5Whbzlgy3ltc5eqmhGkl9AeekF0dIX7yoavw61iiu(OzA1RGaoiMJtnfOKd2zvBPyomuPSfdS7LjHCciMdqLLEnccLp6bX4DmhGkl9AeekF0mT6vqaheZXPMcuYb7SQTumhMTr2Ib29YKqobeZbOYsVgbHYh9Gy8oMdqLLEnccLpAMw9kiGdI54utbk5GDw1wkMdjvzlgy3ltc5eqmh4QGwpF0dIX7yoWvbTE(OzA1RGaoiMJtnfOKd2d2HAyRqfqJTdTJizlMyG1jfJbM0ipMxJI5GeeXBWR6hedIG3fdraXGBqkgT4nO6eqm8tDHq4CWoRAlfZHLTyGDVmjKtaXCGRcA98rpigVJ5axf065JMPvVcc4Gyoo1uGsoyNvTLI5WYwmWUxMeYjGyoWvbTE(OheJ3XCGRcA98rZ0QxbbCqmQhZrcELvJ54utbk5GDw1wkMdr2Ib29YKqobeZbUkO1Zh9Gy8oMdCvqRNpAMw9kiGdI54utbk5GDw1wkMdr2Ib29YKqobeZbUkO1Zh9Gy8oMdCvqRNpAMw9kiGdIr9yosWRSAmhNAkqjhSZQ2sXCeKTyGDVmjKtaXCGRcA98rpigVJ5axf065JMPvVcc4Gyoo1uGsoyNvTLI5iiBXa7EzsiNaI5axf065JEqmEhZbUkO1ZhntREfeWbXOEmhj4vwnMJtnfOKd2zvBPyyfzlgy3ltc5eqmh4QGwpF0dIX7yoWvbTE(OzA1RGaoiMJtnfOKd2zvBPyyfzlgy3ltc5eqmh4QGwpF0dIX7yoWvbTE(OzA1RGaoig1J5ibVYQXCCQPaLCWEWoudBfQaASDODejBXedSoPymWKg5X8AumhWBWBb7wVvE3cGw(IpigebVlgIaIb3GumAXBq1jGy4N6cHW5GDw1wkg4fzlgy3ltc5eqmhGkl9AeekF0dIX7yoavw61iiu(OzA1RGaoiMJtnfOKd2d2HAyRqfqJTdTJizlMyG1jfJbM0ipMxJI5aL7gtQ6QGwhFqmicExmebedUbPy0I3GQtaXWp1fcHZb7SQTumhw2Ib29YKqobeZbUkO1Zh9Gy8oMdCvqRNpAMw9kiGdI54dNcuYb7SQTumhISfdS7LjHCciMdCvqRNp6bX4Dmh4QGwpF0mT6vqaheZXPMcuYb7b7qnSvOcOX2H2rKSftmW6KIXatAKhZRrXCa21fqravu7QB9EqmicExmebedUbPy0I3GQtaXWp1fcHZb7SQTumSISfdS7LjHCciMdCvqRNp6bX4Dmh4QGwpF0mT6vqaheZXPMcuYb7SQTumqLYwmWUxMeYjGyoavw61iiu(OheJ3XCaQS0RrqO8rZ0QxbbCqmhF4uGsoyNvTLIjvgq2Ib29YKqobeZbUkO1Zh9Gy8oMdCvqRNpAMw9kiGdI54utbk5G9GDOg2kub0y7q7is2IjgyDsXyGjnYJ51OyoG3G3c2TERjNkMoigebVlgIaIb3GumAXBq1jGy4N6cHW5GDw1wkMdlBXa7EzsiNaI5aEVafZZh9Gy8oMd49cumpF0mT6vqaheJ6XCKGxz1yoo1uGsoyNvTLI5qKTyGDVmjKtaXCaVxGI55JEqmEhZb8EbkMNpAMw9kiGdI54utbk5GDw1wkg4fzlgy3ltc5eqmhW7fOyE(OheJ3XCaVxGI55JMPvVcc4Gyoo1uGsoyNvTLIHTq2Ib29YKqobeJKbc7yWWTUMsmqTJX7yy1IgdGX0WwVX0jes9gfZXmekXCCQPaLCWoRAlfdBHSfdS7LjHCciMd49cumpF0dIX7yoG3lqX88rZ0QxbbCqmQhZrcELvJ54utbk5GDw1wkgOszlgy3ltc5eqmsgiSJbd36AkXa1ogVJHvlAmagtdB9gtNqi1BumhZqOeZXPMcuYb7SQTumqLYwmWUxMeYjGyoG3lqX88rpigVJ5aEVafZZhntREfeWbXOEmhj4vwnMJtnfOKd2zvBPyyBKTyGDVmjKtaXCaVxGI55JEqmEhZb8EbkMNpAMw9kiGdI54utbk5GDw1wkMuzazlgy3ltc5eqmh4QGwpF0dIX7yoWvbTE(OzA1RGaoig1J5ibVYQXCCQPaLCWoRAlftQmGSfdS7LjHCciMdqLLEnccLp6bX4DmhGkl9AeekF0mT6vqaheZXPMcuYb7SQTumPMQSfdS7LjHCciMdCvqRNp6bX4Dmh4QGwpF0mT6vqaheJ6XCKGxz1yoo1uGsoyNvTLIj1uLTyGDVmjKtaXCaQS0RrqO8rpigVJ5auzPxJGq5JMPvVcc4Gyoo1uGsoyNvTLIj1dlBXa7EzsiNaI5auzPxJGq5JEqmEhZbOYsVgbHYhntREfeWbXCCQPaLCWoRAlftQhISfdS7LjHCciMdqLLEnccLp6bX4DmhGkl9AeekF0mT6vqaheZXPMcuYb7SQTumPYkYwmWUxMeYjGyoWvbTE(OheJ3XCGRcA98rZ0QxbbCqmhNAkqjhSZQ2sXKkRiBXa7EzsiNaI5auzPxJGq5JEqmEhZbOYsVgbHYhntREfeWbXC8Htbk5GDw1wkMuzlKTyGDVmjKtaXCaQS0RrqO8rpigVJ5auzPxJGq5JMPvVcc4Gyoo1uGsoyNvTLI5Whbzlgy3ltc5eqmh4QGwpF0dIX7yoWvbTE(OzA1RGaoiMJpCkqjhSZQ2sXCy4fzlgy3ltc5eqmhW7fOyE(OheJ3XCaVxGI55JMPvVcc4GyupMJe8kRgZXPMcuYb7b7SDWKg5eqmSfXOC36ngHHDCoy)lLG6NjOVe8apXWGgIIr2xHqb7Wd8eZP7jyzJHmeI5NLBM3GmeBGfH6wVCK(CgInqodd2Hh4jggKUOIIGlMupegJ5WmWHtnypyhEGNyG9PUqiSSfSdpWtmhAmSLykMNb50RicuTfhds9tcfJFQBmUIGqE2nqQ6DfWOyEnkgHI9dft8EbIrVMWC4IPGvieohSdpWtmhAmSA3yAJHRypgebVlgIaP1XX8AumWUbVfSB9gZXwMYmgdqVh4XC2cGympMxJIrJ5Hi8zmY(KtnkgUIDOKd2Hh4jMdnMJ0Qxbfd2rg3JHFsCzSfsm9gJgZJKhZRrYGJX2y8tkg2kuLvJX7yqeqHtXiVrYiAfihSdpWtmhAmSvaOwfShJgdufouFfk2JHwhbxm(P6Xa0eoMT9yaBaseJCsiIX2dfIcsXCm2aJXjStaXOEmBhd2GS2Z466Xi7GQsXyGjk3HsoyhEGNyo0yGDVmjKhJkeXClVx(O5ssm06iJWX4Dm3Y7LpAUKWym6gJkaBShJTydYApJRRhJSdQkfde12ySngSbIZb7b7Wd8eZrkfIxCciMl9AefdVbVQhZLGylohdBLZPehhZ27HEQiWxreJYDRxCm9kGlhSRC36fNtqeVbVQd)0murCDPQTojee3d2HNyG1PHJHPIm9kOyWje3EgHJXpPy2c4LqX0VyCfbHCCmQhJ8tJFgZrU9yKCePYeddkuqc7itgchtxCSbqX0VyGDdEly36ng8zxeaXCPykycihSRC36fNtqeVbVQd)0mKPIm9kigxfKsF2Ef7isLP(ekiHDKjdXyNKgtoJ2lntfz6vq5Z2RyhrQm1NqbjSJmzO0maJmvrHsFyOURcA98tOGunrD(j8peOoRDvqRNFcfKQjQZpd2HNyG1PHJHPIm9kOyWje3EgHJXpPy2c4LqX0VyCfbHCCmQhJ8tJFgZrwraXaBf7XWGcfKWoYKHWX0fhBaum9lgy3G3c2TEJbF2fbqmxkMcMaIrXX8mHGq5GDL7wV4CcI4n4vD4NMHmvKPxbX4QGu6tfbu5k2RpHcsyhzYqm2jPXKZO9sZurMEfu(uravUI96tOGe2rMmuAgGrMQOqPpmu3vbTE(juqQMOo)e(hcuN1UkO1ZpHcs1e15Nb7WtmW60WXWurMEfum4eIBpJWX4NumBb8sOy6xmUIGqoog1Jr(PXpJ5i3EmsoIuzIHbfkiHDKjdHJrrumfmbedqbzlKyGDdEly36nhSRC36fNtqeVbVQd)0mKPIm9kigxfKsZBWBb7wV1NqbjSJmzig7K0yYz0EPzQitVckZBWBb7wV1NqbjSJmzO0maJmvrHsFiqDxf065NqbPAI68t4dVa1zTRcA98tOGunrD(zWo8edSonCmmvKPxbfdoH42ZiCm(jfZwaVekM(fJRiiKJJr9yKFA8ZyyRiUUumhPusen26nMU4ydGIPFXa7g8wWU1Bm4ZUiaI5sXuWeqoyx5U1loNGiEdEvh(Pzitfz6vqmUkiLwrCDPkLsIOXwVm2jPXKZO9sZurMEfuwrCDPkLsIOXwVPzagzQIcLMTHTbQ7QGwp)ekivtuNFc)dd1zTRcA98tOGunrD(zWo8edSonCmmvKPxbfdoH42ZiCm(jftcH406kekM(fdOUAmxs0YJr(PXpJHTI46sXCKsjr0yR3yKBcrmB7XCPykycihSRC36fNtqeVbVQd)0mKPIm9kigxfKsRiUUuLsjr0yR3kOUkJa0tlcp9rGbyStsJim5b7WtmqnMFgdBRTacBHWymWUbVfSB9EaogE3cGw(gJCtiI5sXGiGcNaI5cxmAmiDbAWyuWUSoJXClEm(jfZwaVekM(fdhzoogSRihhdtcbxmNgKZy0NtOyuUBmv3wiXa7g8wWU1Bm6cedw0YXXa0Y3y8wUIaWX4Num0cet)Ib2n4TGDR3dWXW7wa0Y3CmqnN0gdOkJTqIbG4g26fhJTX4NumSvOkRYymWUbVfSB9EaogebQ2AlKy4DlaA5Bmgogebu4eqmx4IXpnCmpKYDR3y8ogLZ7Y6X8AumST2ciSfsoyx5U1loNGiEdEvh(Pzitfz6vqmUkiLwgBbe2cPIiGc3TEzeGEAr4PzG8rGXojnIWKhSdpXaRtkgGcsDR3y6xmAmsLng2wBHCaogOlim2wiXa7g8wWU1Boyx5U1loNGiEdEvh(Pzitfz6vqmUkiLglZTcuqQB9YyNKgtoJmvrHsZkb7k3TEX5eeXBWR6WpndzQitVcIXvbP08g8wWU1BT3Abtm2jPXKZitvuO0e8UyjjeqgIqbm1BeUEvaielSqW7ILKqazqLRxevXNe5vWc24SWcbVlwscbKTfZrfxVcQcVl66fWkaX04elSqW7ILKqazCzVIUbQki5NWHDwyHG3fljHaYeycCisf1gbS6YjwyHG3fljHaYpHcs1(vVQ7cIfwi4DXssiGSCvgAjeU(q9cWcle8Uyjjeq2wSJkCVr4kGX0wQEjHiyhEI5i3YJr0lKyU0RrumWUbVfSB9gd(SlcGyosGjWHived8kcy1LtXCPykyc4iEWUYDRxCobr8g8Qo8tZqMkY0RGyCvqknbMahIurTraRUCQcqcfogbONweE6uHkzStsJim5b7Wtmh5wEmIEHeZLEnIIb2n4TGDR3yWNDraeJJSvgYXX4NQhJJmiqiumAm4tfraXWvNG0i4IH3TaOLVX0BmTFsOyCKTYqooMT9yUumfmbCepyx5U1loNGiEdEvh(Pzitfz6vqmUkiLU3AbtvEX73JXojnMCgzQIcL(WmaJ2lntfz6vqzEdEly36T2BTGPGDL7wV4CcI4n4vD4NMHmvKPxbX4QGu6ERfmv5fVFpg7K0yYzKPkku6dZkmAV0e8Uyjjeqgu56frv8jrEfSGnEWUYDRxCobr8g8Qo8tZqMkY0RGyCvqkDV1cMQ8I3VhJDsAm5mYuffk9Hza4ZurMEfuMatGdrQO2iGvxovbiHchJ2lnbVlwscbKjWe4qKkQncy1Ltb7WtmW6KIzlGxcft)IXveeYXXiDAp3wiXavB5ekg8zxeaXCPykyciMEJbOGSfsmWUbVfSB9Md2vUB9IZjiI3Gx1HFAgYurMEfeJRcsP5n4TGDR3k(0EUTqQjTCcXia90IWtFyg7K0ictEWo8edSoPyCdKIbrGQT2cjMEJrJHRypg5N0gdSBWBb7wVXW1nMlftbtaXyBmyI3laohSRC36fNtqeVbVQd)0mKPIm9kigxfKsZBWBb7wVvUI9kIavBXmcqpTi80mqMTGXojnIWKhSRC36fNtqeVbVQd)0mSGPQ5eiJRcsPXDruniR5eIr7LM1mvKPxbL5n4TGDR3AV1cMc2vUB9IZjiI3Gx1HFAgcAiuJQgOcHc2vUB9IZjiI3Gx1HFAgMahQVcf7mAV0SobrmZjWH6RqXEWEWo8apXCKsH4fNaIHysi4IXnqkg)KIr5EJIXWXOmvtOxbLd2vUB9ItZ7Y6ecNqcbJ2lnRrLLEnccLbmm3se2Qi4Q8geuxGGD4jgzpfz6vqX4NQhdVxh1cCmYpPngy3G3c2TEJXWXuWeqogyDA4ye2sXGjhhdSBWBb7wVX4DmxkMcMaIrFoHIHbneHDf5ekgDbIrtsegHJXpPyKXwaHTqQicOWDR3yyQitVckgVJXpPyqeOARTqIH3TaOLVX0VyGDdEly36nhdBfaWCRxviGJXySxmWUbVfSB9gJHJbWW6vqaX4NgogOwfShdMCCm(jfdtfz6vqX4DmAmUbsXKOypg)KIHwGy6xm(jfd2alc1TEZb7k3TEXWpndzQitVcIXvbP0UbsvVR8g8wWU1lJDsAm5mYuffkTRcA98Zqe2vKtiO(Zqe2vKtOmIavBXW)yE3cGw(M5n4TGDR3mIavBXq9Jt9qzQitVcklJTacBHureqH7wVqDxf06zzSfqyleOafOoR5DlaA5BM3G3c2TEZisbGdQFlVxM3G3c2TEZaT8nyhEIr2xLHIbxqumWUbVfSB9gJHJbGekCeqm2lMLiaciMRIjGy6ng)KIHatGdrQO2iGvxovbiHcxmmvKPxbLd2vUB9IHFAgYurMEfeJRcsPDdKQEx5n4TGDRxg7K0GAkmYuffkntfz6vqzcmboePIAJawD5ufGekCh6X8UfaT8ntGjWHivuBeWQlNYafK6wVhkVBbqlFZeycCisf1gbS6YPmIavBXqbQZAE3cGw(MjWe4qKkQncy1LtzePaWXO9stW7ILKqazcmboePIAJawD5uWo8eJSJekCXa7g8wWU1BmVgfZrKqbm1BeogORaqigJPSccJJX8yK3fbqmxkgasOWraXi6fcHIXp1nMdZaXGjEVa4CWUYDRxm8tZqMkY0RGyCvqkTBGu17kVbVfSB9YyNKgutHrMQOqP5DlaA5BgIqbm1BeUEvaiugrGQTygTxAcExSKecidrOaM6ncxVkaecgE3cGw(MHiuat9gHRxfacLreOAlwwhMbc2HNyKDKqHlgy3G3c2TEJPSUjIbQOHQXqPKyichJ9IX8dWXusYb7k3TEXWpndzQitVcIXvbP0UbsvVR8g8wWU1lJDsAqnfgzQIcL(wEVmQSuTF1KwoHYicuTfZO9s7QGwpJklv7xnPLtiyUL3lZBWBb7wVzGw(gSdpXi7iHcxmWUbVfSB9gZRrXOBmukosJbQOSum9lgOAlNqXyVy8tkgOIYsX0VyGQTCcfJ8UiaIH3Gum97fdVBbqlFJr9yeKI9yyLyWeVxaCmx61ikgy3G3c2TEJrExea5GDL7wVy4NMHmvKPxbX4QGuA3aPQ3vEdEly36LXojnOMcJmvrHsZ7wa0Y3mQSuTF1KwoHYicuTfd)B59YOYs1(vtA5ekduqQB9YO9s7QGwpJklv7xnPLtiyUL3lZBWBb7wVzGw(cdVBbqlFZOYs1(vtA5ekJiq1wm8zfzXurMEfu2nqQ6DL3G3c2TEd2HNyKDKqHlgy3G3c2TEJXEXi7mm3se2Qi4Ib2niOUaXiVlcGy22J5sXGifaUyEnkgZJboYZb7k3TEXWpndzQitVcIXvbP0UbsvVR8g8wWU1lJDsAqnfgzQIcLM3TaOLV5B59QagMBjcBveCvEdcQlqgrGQTygTxAuzPxJGqzadZTeHTkcUkVbb1faMB59YagMBjcBveCvEdcQlqgOLVb7WtmYEkY0RGIXpvpgc7gO6eog5NKFsOyKoTNBlKyGQTCcfJCtiI5sXuWeqmx61ikgy3G3c2TEJXWXGifaUCWUYDRxm8tZqMkY0RGyCvqkn(0EUTqQjTCcvV0RruL3G3c2TEzStsJjNrMQOqPpw5UXKQ0sGgHLftfz6vqzEdEly36TIpTNBlKAslNqSWIYDJjvPLancllMkY0RGY8g8wWU1B9juqc7itgIfwyQitVck7giv9UYBWBb7wVhQYDR3m(0EUTqQjTCcLFfHOIiGc3TEzdVBbqlFZ4t752cPM0YjugOGu36fkWWurMEfu2nqQ6DL3G3c2TEpuE3cGw(MXN2ZTfsnPLtOmIavBXSr5U1BgFAp3wi1KwoHYVIqureqH7wVWCmVBbqlFZOYs1(vtA5ekJiq1w8HY7wa0Y3m(0EUTqQjTCcLreOAlMnSclSWAxf06zuzPA)QjTCcbLGDL7wVy4NMH4t752cPM0YjeJ2l9T8EzEdEly36nd0Yxyy9X3Y7LT9rOvfvUI5kaLljWClVx(S9k2rKktUKafyyQitVckJpTNBlKAslNq1l9Aev5n4TGDR3GDL7wVy4NMHifW01R4efjdJ2l9X3Y7L5n4TGDR3mqlFH5wEVmQSuTF1KwoHYaT8fMJzQitVck7giv9UYBWBb7wVYIsH4fNQUbsSWctfz6vqz3aPQ3vEdEly36Ln8UfaT8nJuatxVItuKmzGcsDRxOafwy54B59YOYs1(vtA5ekxsGHPIm9kOSBGu17kVbVfSB9YMdHbGsWUYDRxm8tZqas9ZBJwIr7L(wEVmVbVfSB9MbA5lm3Y7LrLLQ9RM0YjugOLVWWurMEfu2nqQ6DL3G3c2TELfLcXlovDdKc2vUB9IHFAgcAiuJW1(v9gbsRZO9sZurMEfu2nqQ6DL3G3c2TELv6dbMB59Y8g8wWU1BgOLVb7WtmmyJIr2Jw)eoeJXuWumAmmOHOyGUqXEm8tfbHIbOGSfsmY(gc1iCm9lgy1iqA9y4k2JX7yuMTbedxtsSfsm8tfbHW5GDL7wVy4NMHpdr1RqXoJfmvLFAcQYvSBlK0PYO9sRC36ndAiuJW1(v9gbsRNPuiEXTfcmVIqure)urqOQBG0HQC36ndAiuJW1(v9gbsRNPuiEXPkIavBXY6iadRpBVIDePYuXjKqGR2wFcdYPddRVL3lF2Ef7isLjxsc2vUB9IHFAgwWu1CcKr69iUxxfKsdrOaM6ncxVkaeIr7LMPIm9kOSBGu17kVbVfSB9YgE3cGw(EOSsWUYDRxm8tZWcMQMtGmUkiLMatGdrQO2iGvxoXO9sZurMEfu2nqQ6DL3G3c2TELvAMkY0RGYeycCisf1gbS6YPkaju4c2vUB9IHFAgwWu1CcKXvbP0qeWLCw7xvXyd0eQB9YO9sZurMEfu2nqQ6DL3G3c2TEztAMkY0RGY9wlyQYlE)Eb7k3TEXWpndlyQAobY4QGuAqLRxevXNe5vWc24mAV0mvKPxbLDdKQEx5n4TGDRxzLMvc2HNyy7VykyBHeJgd2juBaX07HwWumMtGmgJkKRWHJPGPyKDisbEgIIr2JWysetxCSbqX0VyGDdEly36nhd8QFsi5gMymMeK1iZTJyumfSTqIr2Hif4zikgzpcJjrmYn)mgy3G3c2TEJPxbCXyVyy77JqRkIb2kMRaumgogA1RGaIrxGy0ykyfcfJ8EpWJ5sXiAShtZKqX4NumafK6wVX0Vy8tkMNb50Zb7k3TEXWpndlyQAobY4QGuAaePapdrvMegtcgTxAMkY0RGYUbsvVR8g8wWU1lBsZurMEfuU3AbtvEX73dMJVL3lB7JqRkQCfZvakJDLlt6B59Y2(i0QIkxXCfGYGAkvSRCzyHfwZ7fOyE22hHwvu5kMRaelSWurMEfuM3G3c2TER9wlyIfwyQitVck7giv9UYBWBb7wVWNvyZZGC6vebQ2IHAd1M3TaOLVqjyhEIrQlIyy7qwZjum4ZUiaI5sXuWeqm2gJgJCfUy8t1JbOj8EGhJToHEeIIrU5NX0(jHIP3dTGPyCKTYqoohd8QFsOyCKTYqoogGoMT9yCKbbcHIrJbFQicig2oSLDX0BmMZym4ogZJHRBmxkMcMaIbzqo9y0NtOy0fUyA)KqX07HwWumoYwziphSRC36fd)0mSGPQ5eiJRcsPXDruniR5eIr7LMPIm9kOSBGu17kVbVfSB9YM0hcda1pMPIm9kOCV1cMQ8I3VhByaOaZXSMG3fljHaYaisbEgIQmjmMeSWcVBbqlFZaisbEgIQmjmMezebQ2IzdRaLGD4bEIbAK8yK6Iig2oK1CcfdTocogJbrcJWX0Bm4tfraXyobgdSLDXy7RrGQB9gJFQEmgoMT9yGJ8yWLKKg5eqoMyGkOeHYjCm(jftcIyADbhJWwkg5N0gZRSC36vf5GD4bEIr5U1lg(PzybtvZjqgxfKsJ7IOAqwZjeJ2l9XmvKPxbLDdKQEx5n4TGDRx2K(qyaO(XmvKPxbL7TwWuLx8(9yddafwyH3TaOLVzZjWkhOMAQhHuZicuTfdfyoM1e8UyjjeqgarkWZquLjHXKGfw4DlaA5BgarkWZquLjHXKOEihHJaBXHC4mIavBXSHvGsWo8edSqgeiekgPUiIHTdznNqXqksaxmYn)mg2((i0QIyGTI5kaftJIr(jTXyEmYvCmjiIRyphSRC36fd)0mKRlNe1B59yCvqknUlIQbzn36Lr7LM18EbkMNT9rOvfvUI5kabJBGKSyfwy5wEVSTpcTQOYvmxbOm2vUmPVL3lB7JqRkQCfZvakdQPuXUYLjyhEIHT7eiog)u9ya6y22J5sl9mpgy3G3c2TEJbF2fbqmqTkypMlftbtaX0fhBaum9lgy3G3c2TEJr9yWniftsBRNd2vUB9IHFAgwWu1CceZO9sZurMEfu2nqQ6DL3G3c2TEztAMkY0RGY9wlyQYlE)Eb7WtmhrKhJFsXi7mm3se2Qi4Ib2niOUaXClVxmLegJPSccJJH3G3c2TEJXWXG7EZb7k3TEXWpnd5DzDcHtiHGr7Lgvw61iiugWWClryRIGRYBqqDbGH3TaOLV5B59QagMBjcBveCvEdcQlqgrkaCWClVxgWWClryRIGRYBqqDbQkIRlLbA5lmS(wEVmGH5wIWwfbxL3GG6cKljWWurMEfu2nqQ6DL3G3c2TEzZHzLGDL7wVy4NMHkIRlvPusen26Lr7Lgvw61iiugWWClryRIGRYBqqDbGH3TaOLV5B59QagMBjcBveCvEdcQlqgrkaCWClVxgWWClryRIGRYBqqDbQkIRlLbA5lmS(wEVmGH5wIWwfbxL3GG6cKljWWurMEfu2nqQ6DL3G3c2TEzZHzLGDL7wVy4NMHpuJ9BlCgTxAuzPxJGqzadZTeHTkcUkVbb1fagE3cGw(MVL3RcyyULiSvrWv5niOUazePaWbZT8EzadZTeHTkcUkVbb1fO(qn2ZaT8fgwFlVxgWWClryRIGRYBqqDbYLeyyQitVck7giv9UYBWBb7wVS5WSsWUYDRxm8tZqUkevL7wVvHHDgxfKsZBWBb7wV1KtftmAV0mvKPxbLDdKQEx5n4TGDRxzLMbc2vUB9IHFAgIklv7xnPLtigTx6B59YOYs1(vtA5ekd0Yxyy9T8E5NHiS3iWCjbMJzQitVck7giv9UYBWBb7wVSj9T8EzuzPA)QjTCcLbki1TEHHPIm9kOSBGu17kVbVfSB9YgL7wV5NHO6vOyp)kcrfr8tfbHQUbsSWctfz6vqz3aPQ3vEdEly36LnpdYPxreOAlgkb7WtmYEkY0RGIXpvpgEVoQf4yyqdrXaDHI9ykyfcfJ3XqlUGOymhhd)urqiCmjDliGyEnkgy3G3c2TEZb7k3TEXWpndzQitVcIXcMQ97vHWbsNkJfmvLFAcQYvSBlK0PY4QGu6NHO6vOyVM0TWwim2jPXKZitvuO0mvKPxbLDdKQEx5n4TGDR3d9qKLYDR38Zqu9kuSNFfHOIi(PIGqv3aPdv5U1BgFAp3wi1KwoHYVIqureqH7wVqDMkY0RGY4t752cPM0Yju9sVgrvEdEly36fgMkY0RGYUbsvVR8g8wWU1RSEgKtVIiq1wCWo8eJSNIm9kOy8t1JH3RJAbogO6ztRLsmmOqbjCmfScHIX7yOfxqumMJJHFQiieogfrXK0TGaI51OyGDdEly36nhd86kGlMcMIbQE20APeddkuqchtxCSbqX0VyGDdEly36ng5N0gZRieXWpveechdx3yUum91vBjGyakiBHeJFsXSukEmWUbVfSB9Md2vUB9IHFAgYurMEfeJRcsPtoBATuQjDlSfcJ2lTYDJjvPLancllMkY0RGY8g8wWU1B9juqc7itgIrMQOqPzQitVck7giv9UYBWBb7wVW)wEVmVbVfSB9Mbki1TEpuwrwk3TEZjNnTwk1NqbjC(veIkI4NkccvDdKGpVBbqlFZjNnTwk1NqbjCgOGu369qvUB9MXN2ZTfsnPLtO8Rievebu4U1luNPIm9kOm(0EUTqQjTCcvV0RruL3G3c2TEHHPIm9kOSBGu17kVbVfSB9kRNb50RicuTfZclOYsVgbHY4YwLXwi46vqySTqyHf3ajzXkb7WtmqnN0gtbBlKyyqHcsyhzYqXyBmWUbVfSB9YymyLjfJIJbux4IHFQiieogfhtsJX2vqX8AumWUbVfSB9gJCZp7IhdxtsSfsoyx5U1lg(Pzitfz6vqmUkiLo5SP1sPM0TWwimAV0k3nMuLwc0imBsZurMEfuM3G3c2TERpHcsyhzYqmYuffkntfz6vqz3aPQ3vEdEly36vwk3TEZjNnTwk1NqbjC(veIkI4NkccvDdKouL7wVz8P9CBHutA5ek)kcrfrafUB9c1zQitVckJpTNBlKAslNq1l9Aev5n4TGDRxyyQitVck7giv9UYBWBb7wVY6zqo9kIavBXSWcQS0RrqOmUSvzSfcUEfegBlewyXnqswSsWUYDRxm8tZqUkevL7wVvHHDgxfKsJ6KAYPIjgXoY4E6uz0EPVL3lJklv7xnPLtOCjbgMkY0RGYUbsvVR8g8wWU1lByGGD4jg2kauRc2JXpPyyQitVckg)u9y496OwGJHbnefd0fk2JPGviumEhdT4cIIXCCm8tfbHWXOikgvG7ys6wqaX8AumqfLLIPFXavB5ekhSRC36fd)0mKPIm9kiglyQ2VxfchiDQmwWuv(PjOkxXUTqsNkJRcsPFgIQxHI9As3cBHWyNKgtoJmvrHsZ7wa0Y3mQSuTF1KwoHYicuTfllL7wV5NHO6vOyp)kcrfr8tfbHQUbshQYDR3m(0EUTqQjTCcLFfHOIiGc3TEH6hZurMEfugFAp3wi1KwoHQx61iQYBWBb7wVWW7wa0Y3m(0EUTqQjTCcLreOAlww8UfaT8nJklv7xnPLtOmIavBXqbgE3cGw(MrLLQ9RM0YjugrGQTyz9miNEfrGQTygTxAwZurMEfu(ziQEfk2RjDlSfcmUkO1ZOYs1(vtA5ecMB59YOYs1(vtA5ekd0Y3GD4jgOMtAJ5iRiaUIDBHeddkuqkgjhzYqmgddAikgOluSJJbF2fbqmxkMcMaIX7yGqlHuNI5i3EmsoIuzWXOlqmEhdLItlqmqxOyNqXi7RyNq5GDL7wVy4NMHpdr1RqXoJfmv73RcHdKovglyQk)0euLRy3wiPtLr7LM1mvKPxbLFgIQxHI9As3cBHadtfz6vqz3aPQ3vEdEly36Lnmamk3nMuLwc0imBsZurMEfu(uravUI96tOGe2rMmemS(zic7kYjuw5UXKGH13Y7LpBVIDePYKljWC8T8E5tsDBHulj5scmk3TEZpHcsyhzYqzkfIxCQIiq1wSSyGmRWcl8tfbHW1hs5U1Rkyt6ddLGD4jgzxbzlKyyqdryxroHymgg0qumqxOyhhJIOykycigSbAcfjGlgVJbOGSfsmWUbVfSB9MJ5iIwcPcbCmgJFsWfJIOykycigVJbcTesDkMJC7Xi5isLbhJ8tAJHJmhhJCtiIzBpMlfJCf7eqm6ceJCZpJb6cf7ekgzFf7eIXy8tcUyWNDraeZLIbNGifiMU4X4DmGQTUABm(jfd0fk2jumY(k2jum3Y7Ld2vUB9IHFAg(mevVcf7mwWuTFVkeoq6uzSGPQ8ttqvUIDBHKovgTx6NHiSRiNqzL7gtcg(PIGqy2Kovyyntfz6vq5NHO6vOyVM0TWwiWCmRvUB9MFgIUQqKPuiEXTfcmSw5U1BobouFfk2Z2wFcdYPdZT8E5tsDBHulj5sclSOC36n)meDvHitPq8IBleyy9T8E5Z2RyhrQm5sclSOC36nNahQVcf7zBRpHb50H5wEV8jPUTqQLKCjbgwFlVx(S9k2rKktUKaLGD4jg2kZ2aIHRjj2cjgg0qumqxOypg(PIGq4yKFAckg(PUljSfsmsN2ZTfsmq1woHc2vUB9IHFAg(mevVcf7mwWuv(PjOkxXUTqsNkJ2lTYDR3m(0EUTqQjTCcLPuiEXTfcmVIqure)urqOQBGKSuUB9MXN2ZTfsnPLtOSBCzQicOWDRxyUL3lF2Ef7isLjd0YxyCdKytQmqWUYDRxm8tZqUkevL7wVvHHDgxfKsJDDbueqf1U6wVmAV0mvKPxbLDdKQEx5n4TGDRx2WaWClVxgvwQ2VAslNqzGw(gSRC36fd)0meZBe)mypyx5U1loRC3ysvxf0640cJPTqQ3g8YO9sRC3ysvAjqJWSjvyUL3lZBWBb7wVzGw(cZXmvKPxbLDdKQEx5n4TGDRx2W7wa0Y3SWyAlK6TbVzGcsDRxwyHPIm9kOSBGu17kVbVfSB9kR0mauc2vUB9IZk3nMu1vbTog(Pzii5uJy0EPzQitVck7giv9UYBWBb7wVYkndWclhZ7wa0Y3mi5uJYafK6wVYIPIm9kOSBGu17kVbVfSB9cdRDvqRNrLLQ9RM0YjeuyHfxf06zuzPA)QjTCcbZT8EzuzPA)QjTCcLljWWurMEfu2nqQ6DL3G3c2TEzJYDR3mi5uJY8UfaT8LfwEgKtVIiq1wSSyQitVck7giv9UYBWBb7wVb7k3TEXzL7gtQ6QGwhd)0meaPq6fxVis9tgTxAxf06zvqPGDKIpIP46RGGdMJVL3lZBWBb7wVzGw(cdRVL3lF2Ef7isLjxsGsWEWUYDRxCM3G3c2TER8UfaT8fNoPDR3GDL7wV4mVbVfSB9w5DlaA5lg(Pz4v0nq9vqWfSRC36fN5n4TGDR3kVBbqlFXWpndVectizSfcJ2l9T8EzEdEly36nxsc2vUB9IZ8g8wWU1BL3TaOLVy4NMHpdrxr3ab7k3TEXzEdEly36TY7wa0Yxm8tZqD5e2rQOYvHiyx5U1loZBWBb7wVvE3cGw(IHFAg6givLROegTxAuzPxJGqzNatAKkQYvucm3Y7LPuo1c2TEZLKGDL7wV4mVbVfSB9w5DlaA5lg(PzybtvZjqgP3J4EDvqkneHcyQ3iC9QaqOGDL7wV4mVbVfSB9w5DlaA5lg(PzybtvZjqgxfKsBlMJkUEfufEx01lGvaIPXPGDL7wV4mVbVfSB9w5DlaA5lg(PzybtvZjqgxfKs)ekiv7x9QUlOGDL7wV4mVbVfSB9w5DlaA5lg(PzybtvZjqgxfKslxLHwcHRpuVab7k3TEXzEdEly36TY7wa0Yxm8tZWcMQMtGmUkiL2wSJkCVr4kGX0wQEjHiyx5U1loZBWBb7wVvE3cGw(IHFAgwWu1CcKXvbP04YEfDduvqYpHd7b7k3TEXzEdEly36TY7wa0Yxm8tZWcMQMtG4G9GDL7wV4mVbVfSB9wtovmLwyqoDCfQvbaciToJ2l9T8EzEdEly36nd0Y3GD4jMJe2nq1PyoB5Xi6fsmWUbVfSB9gJCtiIrOypg)uxzWX4DmsLng2wBHCaogOlim2wiX4DmaKtiqBPyoB5XWGgIIb6cf74yWNDraeZLIPGjGCWUYDRxCM3G3c2TERjNkMGFAgYurMEfeJfmv73RcHdKovglyQk)0euLRy3wiPtLXvbP0ukoTaeqL3G3c2TERicuTfZyNKgtoJmvrHsFlVxM3G3c2TEZicuTfd)B59Y8g8wWU1BgOGu36fQFmVBbqlFZ8g8wWU1BgrGQTyzDlVxM3G3c2TEZicuTfdfgTxAEVafZZ2(i0QIkxXCfGc2HNyyRaa4y8tkgGcsDR3y6xm(jfJuzJHT1wihGJb6ccJTfsmWUbVfSB9gJ3X4Num0cet)IXpPy4feIwpgy3G3c2TEJXEX4NumCf7XiVlcGy4nyIGCkgGcYwiX4Ngogy3G3c2TEZb7k3TEXzEdEly36TMCQyc(Pzitfz6vqmwWuTFVkeoq6uzSGPQ8ttqvUIDBHKovgxfKstP40cqavEdEly36TIiq1wmJDsAfaGrMQOqPzQitVckJL5wbki1TEz0EP59cumpB7JqRkQCfZvacMJVL3lJlBvgBHGRxbHX2cPIifaUCjHfwyQitVcktP40cqavEdEly36TIiq1wmBsnZkqDiCGmOMcu)4B59Y4YwLXwi46vqySTqYGAkvSRCzo0B59Y4YwLXwi46vqySTqYyx5YafOeSRC36fN5n4TGDR3AYPIj4NMHxfsTFvhzCzWmAV03Y7L5n4TGDR3mqlFd2vUB9IZ8g8wWU1Bn5uXe8tZqHX0wi1BdEz0EPvUBmPkTeOry2Kkm3Y7L5n4TGDR3mqlFd2HNyGAm)SlEmS99rOvfXaBfZvaIXyGAvWEmfmfddAikgOluSJJr(jTX4NeCXiV3d8yall)mgoYCCm6ceJ8tAJHbneH9gbgJHJbOLV5GDL7wV4mVbVfSB9wtovmb)0m8ziQEfk2zSGPA)EviCG0PYybtv5NMGQCf72cjDQmAV0SM3lqX8STpcTQOYvmxbiy4NkccHzt6uH5wEVmVbVfSB9MljWW6B59YpdryVrG5scmS(wEV8z7vSJivMCjbMZ2RyhrQmvCcje4QT1NWGC6W)wEV8jPUTqQLKCjrwhoyhEIbQX8Zyy77JqRkIb2kMRaeJXWGgIIb6cf7XuWum4ZUiaI5sXOaaMB9QcbCXW7f7i1wcigChJFQEmMhJHJzBpMlftbtaXuwbHXXW23hHwvedSvmxbOymCm6TlEmEhdLsIHOyAum(jHOyuefdyJOy8tDJH2Ua5mgg0qumqxOyhhJ3XqP40cedBFFeAvrmWwXCfGIX7y8tkgAbIPFXa7g8wWU1Boyx5U1loZBWBb7wV1KtftWpndzQitVcIXcMQ97vHWbsNkJfmvLFAcQYvSBlK0PY4QGuAkLeI7eq9ziQEfk2Xm2jPXKZitvuO0k3TEZpdr1RqXEMFQiieU(qk3TEvb8pMPIm9kOmLItlabu5n4TGDR3kIavBXh6T8EzBFeAvrLRyUcqzGcsDRxOa1M3TaOLV5NHO6vOypduqQB9YO9sZ7fOyE22hHwvu5kMRauWUYDRxCM3G3c2TERjNkMGFAgYurMEfeJfmv73RcHdKovglyQk)0euLRy3wiPtLXvbP0lraeq9ziQEfk2Xm2jPXKZitvuO0CYehZurMEfuMsXPfGaQ8g8wWU1BfrGQTyO2hFlVx22hHwvu5kMRaugOGu369qHWbYGAkqbkmAV08EbkMNT9rOvfvUI5kafSRC36fN5n4TGDR3AYPIj4NMHpdr1RqXoJfmv73RcHdKovglyQk)0euLRy3wiPtLr7LM3lqX8STpcTQOYvmxbiy4NkccHzt6uH5yMkY0RGYukje3jG6Zqu9kuSJztAMkY0RGYlraeq9ziQEfk2XSWctfz6vqzkfNwacOYBWBb7wVvebQ2ILv6B59Y2(i0QIkxXCfGYafK6wVSWYT8EzBFeAvrLRyUcqzSRCzK1HzHLB59Y2(i0QIkxXCfGYicuTflliCGmOMclSW7wa0Y3m(0EUTqQjTCcLrKcahmk3nMuLwc0imBsZurMEfuM3G3c2TER4t752cPM0Yjem8MjT6651GC61NsqbMB59Y8g8wWU1BUKaZXS(wEV8Zqe2BeyUKWcl3Y7LT9rOvfvUI5kaLreOAlwwmqMvGcmS(wEV8z7vSJivMCjbMZ2RyhrQmvCcje4QT1NWGC6W)wEV8jPUTqQLKCjrwhoyhEIbQIOefrXi7mm3se2Qi4Ib2niOUaX8AumWUbVfSB9MJbATtX4NQhJFsXavuwkM(fduTLtOyEOgmgy3G3c2TEJH3L1XXO4y0ng2kIRlfdoHecgJb3XWwrCDPyWjKqGJrrum9kGlML4egRi4IXEX4NQhJRcA9ymCmB7XuWeqoyx5U1loZBWBb7wV1KtftWpnd5DzDcHtiHGr7Lgvw61iiugWWClryRIGRYBqqDbG5wEVmGH5wIWwfbxL3GG6cKbA5lm3Y7Lbmm3se2Qi4Q8geuxGQI46szGw(cdVBbqlFZ3Y7vbmm3se2Qi4Q8geuxGmIua4GH1UkO1ZOYs1(vtA5ekyx5U1loZBWBb7wV1KtftWpndvexxQsPKiAS1lJ2lnQS0RrqOmGH5wIWwfbxL3GG6caZT8EzadZTeHTkcUkVbb1fid0YxyUL3ldyyULiSvrWv5niOUavfX1LYaT8fgE3cGw(MVL3RcyyULiSvrWv5niOUazePaWbdRDvqRNrLLQ9RM0YjuWUYDRxCM3G3c2TERjNkMGFAg(qn2VTWz0EPrLLEnccLbmm3se2Qi4Q8geuxayUL3ldyyULiSvrWv5niOUazGw(cZT8EzadZTeHTkcUkVbb1fO(qn2ZaT8nyx5U1loZBWBb7wV1KtftWpndFOg71TzQmAV0OYsVgbHYqqgwax14gxqWClVxM3G3c2TEZaT8nyx5U1loZBWBb7wV1KtftWpnd5QquvUB9wfg2zCvqkTYDJjvDvqRJd2vUB9IZ8g8wWU1Bn5uXe8tZqEdEly36LXcMQ97vHWbsNkJfmvLFAcQYvSBlK0PYO9sFlVxM3G3c2TEZaT8fMJznQS0RrqOmGH5wIWwfbxL3GG6cWcl3Y7Lbmm3se2Qi4Q8geuxGCjHfwUL3ldyyULiSvrWv5niOUa1hQXEUKaJRcA9mQSuTF1KwoHGH3TaOLV5B59QagMBjcBveCvEdcQlqgrkaCqbMJznQS0RrqOmeKHfWvnUXfelSaq3Y7LHGmSaUQXnUGYLeOaZXk3TEZGKtnkBB9jmiNomk3TEZGKtnkBB9jmiNEfrGQTyzLMPIm9kOmVbVfSB9w5k2RicuTfZclk3TEZyEJ4NzkfIxCBHaJYDR3mM3i(zMsH4fNQicuTfllMkY0RGY8g8wWU1BLRyVIiq1wmlSOC36n)meDvHitPq8IBleyuUB9MFgIUQqKPuiEXPkIavBXYIPIm9kOmVbVfSB9w5k2RicuTfZclk3TEZjWH6RqXEMsH4f3wiWOC36nNahQVcf7zkfIxCQIiq1wSSyQitVckZBWBb7wVvUI9kIavBXSWIYDR38tOGe2rMmuMsH4f3wiWOC36n)ekiHDKjdLPuiEXPkIavBXYIPIm9kOmVbVfSB9w5k2RicuTfdLGD4jg4v)KqXW7wa0YxCm(P6XGp7IaiMlftbtaXi38ZyGDdEly36ng8zxeaX0RaUyUumfmbeJCZpJr3yuUxurmWUbVfSB9gdxXEm6ceZ2EmYn)mgngPYgdBRTqoahd0fegBlKysqnphSRC36fN5n4TGDR3AYPIj4NMHCviQk3TERcd7mUkiLM3G3c2TER8UfaT8fZO9sFlVxM3G3c2TEZicuTfZgOswyH3TaOLVzEdEly36nJiq1wSSyLGDL7wV4mVbVfSB9wtovmb)0m8juqc7itgIr7L(4B59YNTxXoIuzYLeyuUBmPkTeOry2KMPIm9kOmVbVfSB9wFcfKWoYKHGclSC8T8E5NHiS3iWCjbgL7gtQslbAeMnPzQitVckZBWBb7wV1NqbjSJmzOdfvw61iiu(zic7ncekb7k3TEXzEdEly36TMCQyc(PzycCO(kuSZO9sFlVxgx2Qm2cbxVccJTfsfrkaC5scm3Y7LXLTkJTqW1RGWyBHurKcaxgrGQTy2WvSxDdKc2vUB9IZ8g8wWU1Bn5uXe8tZWe4q9vOyNr7L(wEV8Zqe2BeyUKeSRC36fN5n4TGDR3AYPIj4NMHjWH6RqXoJ2l9T8E5e4qnxOyWCjbMB59YjWHAUqXGzebQ2IzdxXE1nqcMJVL3lZBWBb7wVzebQ2IzdxXE1nqIfwUL3lZBWBb7wVzGw(cfyuUBmPkTeOryzXurMEfuM3G3c2TERpHcsyhzYqb7k3TEXzEdEly36TMCQyc(PzycCO(kuSZO9sFlVx(S9k2rKktUKaZT8EzEdEly36nxsc2vUB9IZ8g8wWU1Bn5uXe8tZWe4q9vOyNr7LobrmRq4a5uZyEJ4NWClVx(Ku3wi1ssUKaJYDJjvPLancllMkY0RGY8g8wWU1B9juqc7itgkyhEIHTeBlKyKoTNBlKyGQTCcfdqbzlKyGDdEly36ngVJbryVrummOHOyGUqXEm6cedu9SP1sjgguOGum8tfbHWXW1nMlfZLw6zCtfmgZT4XuWfviGlMEfWftVXWw7Juoyx5U1loZBWBb7wV1KtftWpndXN2ZTfsnPLtigTx6B59Y8g8wWU1BUKadRvUB9MFgIQxHI9m)urqimmk3nMuLwc0imBsZurMEfuM3G3c2TER4t752cPM0Yjemk3TEZjNnTwk1NqbjC(veIkI4NkccvDdKyZRievebu4U1lJ26ecvs8Q9sRC36n)mevVcf7z(PIGq40k3TEZpdr1RqXEgutPYpveechSRC36fN5n4TGDR3AYPIj4NMHjNnTwk1NqbjmJ2l9T8EzEdEly36nxsGXrktsuDdKK1T8EzEdEly36nJiq1wmmhFSYDR38Zqu9kuSN5NkccHLvQW4QGwpNahQ5cfdcJYDJjvPLancNovOWclS2vbTEobouZfkgKfwuUBmPkTeOry2KkuG5wEV8jPUTqQLKCjb(NTxXoIuzQ4esiWvBRpHb50L1Hd2vUB9IZ8g8wWU1Bn5uXe8tZWNqbjSJmzigTx6B59Y8g8wWU1BgOLVWW7wa0Y3mVbVfSB9MreOAlwwCf7v3ajyuUBmPkTeOry2KMPIm9kOmVbVfSB9wFcfKWoYKHc2vUB9IZ8g8wWU1Bn5uXe8tZWNHORkemAV03Y7L5n4TGDR3mqlFHH3TaOLVzEdEly36nJiq1wSS4k2RUbsWWAEVafZZpHcsvLZrKB9gSRC36fN5n4TGDR3AYPIj4NMHyEJ4NmAV03Y7L5n4TGDR3mIavBXSHRyV6gibZT8EzEdEly36nxsyHLB59Y8g8wWU1BgOLVWW7wa0Y3mVbVfSB9MreOAlwwCf7v3aPGDL7wV4mVbVfSB9wtovmb)0muymTfs92GxgTx6B59Y8g8wWU1BgrGQTyzbHdKb1uGr5UXKQ0sGgHztQb7k3TEXzEdEly36TMCQyc(PziasH0lUErK6NmAV03Y7L5n4TGDR3mIavBXYcchidQPaZT8EzEdEly36nxsc2vUB9IZ8g8wWU1Bn5uXe8tZqmVr8tgTxAmPiBHu9UWpZk3nMuWEWUYDRxCg1j1KtftPFcfKWoYKHy0EPvUBmPkTeOry2KMPIm9kO8z7vSJivM6tOGe2rMmemhFlVx(S9k2rKktUKWcl3Y7LFgIWEJaZLeOeSRC36fNrDsn5uXe8tZWe4q9vOyNr7L(wEVmUSvzSfcUEfegBlKkIua4YLeyUL3lJlBvgBHGRxbHX2cPIifaUmIavBXSHRyV6gifSRC36fNrDsn5uXe8tZWe4q9vOyNr7L(wEV8Zqe2BeyUKeSRC36fNrDsn5uXe8tZWe4q9vOyNr7L(wEV8z7vSJivMCjjyhEIHTetX0lfddAikgOluShdPibCXyBmqfnung7fdCDjgGEpWJ5uzsXqMFsOyoYK62cjg2YKyAumh52JrYrKktmWrEm6cedz(jHKTyowHsmNktkgWgrX4N6gJlVJrfisbGJXyo(cLyovMumSvbLc2rk(iMEaoggSGGlgePaWfJ3XuWeJX0OyoMdLyKifzlKyGvx4NXy4yuUBmPCmYUEpWJbOJXpnCmYpnbfZPIaIHRy3wiXWGcfKWoYKHWX0OyKFsBmsLng2wBHCaogOlim2wiXy4yqKcaxoyx5U1loJ6KAYPIj4NMHpdr1RqXoJfmv73RcHdKovglyQk)0euLRy3wiPtLr7LM1mvKPxbLFgIQxHI9As3cBHaZT8EzCzRYyleC9kim2wivePaWLbA5lmk3nMuLwc0iSSyQitVckFQiGkxXE9juqc7itgcgw)meHDf5ekRC3ysWCmRVL3lFsQBlKAjjxsGH13Y7LpBVIDePYKljWW6eeXS2Vxfchi)mevVcf7WCSYDR38Zqu9kuSN5NkccHzt6dZclh7QGwpRckfSJu8rmfxFfeCWW7wa0Y3masH0lUErK6NzePaWbfwybtkYwivVl8ZSYDJjbfOeSdpXWwIPyyqdrXaDHI9yiZpjumafKTqIrJHbneDvHGHqv4q9vOypgUI9yKFsBmhzsDBHedBzsmgogL7gtkMgfdqbzlKyOuiEXPyKB(zmsKISfsmWQl8ZCWUYDRxCg1j1KtftWpndFgIQxHIDglyQ2VxfchiDQmwWuv(PjOkxXUTqsNkJ2lnRzQitVck)mevVcf71KUf2cbgw)meHDf5ekRC3ysWC8XhRC36n)meDvHitPq8IBleyow5U1B(zi6QcrMsH4fNQicuTfllgiZkSWcRrLLEnccLFgIWEJaHclSOC36nNahQVcf7zkfIxCBHaZXk3TEZjWH6RqXEMsH4fNQicuTfllgiZkSWcRrLLEnccLFgIWEJaHcuG5wEV8jPUTqQLKCjbkSWYXysr2cP6DHFMvUBmjyo(wEV8jPUTqQLKCjbgwRC36nJ5nIFMPuiEXTfclSW6B59YNTxXoIuzYLeyy9T8E5tsDBHulj5scmk3TEZyEJ4NzkfIxCBHadRpBVIDePYuXjKqGR2wFcdYPdfOaLGDL7wV4mQtQjNkMGFAgYvHOQC36TkmSZ4QGuAL7gtQ6QGwhhSRC36fNrDsn5uXe8tZWe4q9vOyNr7L(wEVCcCOMlumyUKadxXE1nqsw3Y7LtGd1CHIbZicuTfddxXE1nqsw3Y7LrLLQ9RM0YjugrGQT4GDL7wV4mQtQjNkMGFAgMahQVcf7mAV03Y7LpBVIDePYKljWGjfzlKQ3f(zw5UXKGr5UXKQ0sGgHLftfz6vq5Z2RyhrQm1NqbjSJmzOGDL7wV4mQtQjNkMGFAgMC20APuFcfKWmAV0SMPIm9kOCYztRLsnPBHTqG5wEV8jPUTqQLKCjbgwFlVx(S9k2rKktUKaZXk3nMufO9SbznNK1HzHfL7gtQslbAeMnPzQitVckFQiGkxXE9juqc7itgIfwuUBmPkTeOry2KMPIm9kO8z7vSJivM6tOGe2rMmeuc2vUB9IZOoPMCQyc(PziM3i(jJ2lnMuKTqQEx4NzL7gtkyx5U1loJ6KAYPIj4NMHaifsV46frQFYO9sRC3ysvAjqJWS5Wb7k3TEXzuNutovmb)0murCDPkLsIOXwVmAV0k3nMuLwc0imBsZurMEfuwrCDPkLsIOXwVWaQRMt4oBsZurMEfuwrCDPkLsIOXwVvqD1GD4jgOgZpJH2Ua5mgxrqihZymMhJHJrJbIABmEhdxXEmmOqbjSJmzOyuCmptiium2IDsbIPFXWGgIUQqKd2vUB9IZOoPMCQyc(Pz4tOGe2rMmeJ2lTYDJjvPLancZM0mvKPxbLpveqLRyV(ekiHDKjdfSRC36fNrDsn5uXe8tZWNHORkeb7b7k3TEXzSRlGIaQO2v36n9tOGe2rMmeJ2lTYDJjvPLancZM0mvKPxbLpBVIDePYuFcfKWoYKHG54B59YNTxXoIuzYLewy5wEV8Zqe2BeyUKaLGDL7wV4m21fqravu7QB9c)0mmbouFfk2z0EPVL3l)meH9gbMljb7k3TEXzSRlGIaQO2v36f(PzycCO(kuSZO9sFlVx(S9k2rKktUKaZT8E5Z2RyhrQmzebQ2ILLYDR38Zq0vfImLcXlovDdKc2vUB9IZyxxafburTRU1l8tZWe4q9vOyNr7L(wEV8z7vSJivMCjbMJtqeZkeoqo18Zq0vfcwy5zic7kYjuw5UXKyHfL7wV5e4q9vOypBB9jmiNouc2HNyGfcUy8ogiKhJeBl0Jjb1CCm2InakgOIgQgtYPIjCmnkgy3G3c2TEJj5uXeog5N0gtsJX2vq5GDL7wV4m21fqravu7QB9c)0mmbouFfk2z0EPVL3lJlBvgBHGRxbHX2cPIifaUCjbMJ5DlaA5BgvwQ2VAslNqzebQ2IHVYDR3mQSuTF1KwoHYukeV4u1nqc(Cf7v3aj2ClVxgx2Qm2cbxVccJTfsfrkaCzebQ2IzHfw7QGwpJklv7xnPLtiOadtfz6vqz3aPQ3vEdEly36f(Cf7v3aj2ClVxgx2Qm2cbxVccJTfsfrkaCzebQ2Id2vUB9IZyxxafburTRU1l8tZWe4q9vOyNr7L(wEV8z7vSJivMCjbgmPiBHu9UWpZk3nMuWUYDRxCg76cOiGkQD1TEHFAgMahQVcf7mAV03Y7LtGd1CHIbZLey4k2RUbsY6wEVCcCOMlumygrGQT4GD4jgzxbzlKy8tkgSRlGIaIb1U6wVmgtVc4IPGPyyqdrXaDHIDCmYpPng)KGlgfrXSThZLSfsmjDliGyEnkgOIgQgtJIb2n4TGDR3CmSLykgg0qumqxOypgY8tcfdqbzlKy0yyqdrxviyiufouFfk2JHRypg5N0gZrMu3wiXWwMeJHJr5UXKIPrXauq2cjgkfIxCkg5MFgJePiBHedS6c)mhSRC36fNXUUakcOIAxDRx4NMHpdr1RqXoJfmv73RcHdKovglyQk)0euLRy3wiPtLr7LM1pdryxroHYk3nMemSMPIm9kO8Zqu9kuSxt6wyleyo(4JvUB9MFgIUQqKPuiEXTfcmhRC36n)meDvHitPq8ItvebQ2ILfdKzfwyH1OYsVgbHYpdryVrGqHfwuUB9MtGd1xHI9mLcXlUTqG5yL7wV5e4q9vOyptPq8ItvebQ2ILfdKzfwyH1OYsVgbHYpdryVrGqbkWClVx(Ku3wi1ssUKafwy5ymPiBHu9UWpZk3nMemhFlVx(Ku3wi1ssUKadRvUB9MX8gXpZukeV42cHfwy9T8E5Z2RyhrQm5scmS(wEV8jPUTqQLKCjbgL7wVzmVr8ZmLcXlUTqGH1NTxXoIuzQ4esiWvBRpHb50HcuGsWUYDRxCg76cOiGkQD1TEHFAgMahQVcf7mAV03Y7LpBVIDePYKljWOC3ysvAjqJWYIPIm9kO8z7vSJivM6tOGe2rMmuWUYDRxCg76cOiGkQD1TEHFAgMC20APuFcfKWmAV0SMPIm9kOCYztRLsnPBHTqG5yw7QGwp)qny1pPQIpjmlSOC3ysvAjqJWSjvOaZXk3nMufO9SbznNK1HzHfL7gtQslbAeMnPzQitVckFQiGkxXE9juqc7itgIfwuUBmPkTeOry2KMPIm9kO8z7vSJivM6tOGe2rMmeuc2vUB9IZyxxafburTRU1l8tZqUkevL7wVvHHDgxfKsRC3ysvxf064GDL7wV4m21fqravu7QB9c)0meaPq6fxVis9tgTxAL7gtQslbAeMnPgSRC36fNXUUakcOIAxDRx4NMHyEJ4NmAV0ysr2cP6DHFMvUBmPGDL7wV4m21fqravu7QB9c)0murCDPkLsIOXwVmAV0k3nMuLwc0imBsZurMEfuwrCDPkLsIOXwVWaQRMt4oBsZurMEfuwrCDPkLsIOXwVvqD1GD4jgOgZpJH2Ua5mgxrqihZymMhJHJrJbIABmEhdxXEmmOqbjSJmzOyuCmptiium2IDsbIPFXWGgIUQqKd2vUB9IZyxxafburTRU1l8tZWNqbjSJmzigTxAL7gtQslbAeMnPzQitVckFQiGkxXE9juqc7itgkyx5U1loJDDbueqf1U6wVWpndFgIUQq8LWje)dn4Ld57F))b]] )

end
