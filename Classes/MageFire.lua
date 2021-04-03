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
            max_stack = 18
        },

        molten_skyfall_ready = {
            id = 333182,
            duration = 30,
            max_stack = 1
        },
        
        sun_kings_blessing = {
            id = 333314,
            duration = 30,
            max_stack =8
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

    spec:RegisterStateExpr( "expected_kindling_reduction", function ()
        -- This only really works well in combat; we'll use the old APL value instead of dynamically updating for now.
        return 0.4
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
                removeBuff( "molten_skyfall_ready" )
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
                    if buff.molten_skyfall.stack == 18 then
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
                        if buff.sun_kings_blessing.stack == 8 then
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
                    if buff.sun_kings_blessing_ready.up then
                        applyBuff( "combustion", 6 )
                        removeBuff( "sun_kings_blessing_ready" )
                    end
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
                    if buff.molten_skyfall.stack == 18 then
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


    spec:RegisterPack( "Fire", 20210403, [[devZPeqiuQ6rOe6sOqvTjuWNukzuGGtbcTkLsPxbImluu3IOk2Le)cLKHbIYXiQSmrQ8mIQY0qjvDnuszBOqHVruL04ukfDouOK1HcP5Hs09ej7dLk)tPuv6GkLkleu0dbLAIOqLlsuv1grj4JevjgPsPkNKOk1kjkEjkuKzIcXnvkvv7euYprjvgQivzPkLcpLitfu4QOqv2krvLVIcLASGOAVQQ)kPbR4WKwSsEmHjd0Lr2mGpdQgTs1PPSAuOOEnrPzJQBRk7wLFl1WfXXfPQwouphY0P66IA7G03vkgViLZJISELsvX8rPSFH)Y9HXxcuD6dR0bzPtoiJ1dzYxro5y9qgKX6)sotj0xkrfYQWPV0Pp6lXcgM(sjkt8wb)W4lH6mwqFPD3tqmkRyfCZ3ZRIOFSczVmxDRpbwbCwHSNGvFPv24U8((RVeO60hwPdYsNCqgRhYKVICYjFmwS228lPzFVXFjj7b7V0Ubcs3F9LajK4lXcgMIz7xHtHm7UNGyuwXk4MVNxfr)yfYEzU6wFcSc4SczpbRcz2UeSXJjDmht6GS0jxitidS31doHy0qg5jggpefdGbF3Ry6P2HIbR(oHJX31lgxXWjV42JQExbnkgGghdxrU8GirFGXOlJBotXKrkCcvczKNyyKUr0fJqrEmyk9ZgME05OyaACmWUFRmYT(IbcwHkmhdyFB5XS3CWympgGghJgdaMq7XS9to14yekYHyjKrEIr(F6ItXGCSj8ye7Kqw7GhtFXOXaqBIbOXYIIXUy8DkMTl9yKy8ogmbMfumBASS8wblHmYtmBhiJ5mYJrJj9yc3lUI8yOZXmfJVREmGnHI5ApMxds8y2qCEm2jpW1hfdeq2lgNqobgJ6XCDmid(zaMqppggx6jfJ9suHdXsiJ8edS7dkH9yuopMvgaOa5fmPcpg6CSrOy8oMvgaOa5LCcZXOxmk)1ipg7qg8ZamHEEmmU0tkg4QDXyxmi7HkFjUHC0hgFjr)wzKB9vD7zh8pm(WsUpm(s0Plob(H5xQt(siY)sQWT((sqvSPlo9LGQ8m9LeDZb7nxr0Vvg5wFfm9u7qXSTXqPLqcNaRYAhi3o4vmbMfU13xcKqcSL4wFFPThXtiCmqvSPlofJVREmI(C1oum(ofJk8SYJHqU9uNaJXThfJVREm(ofZrP5Xa7(TYi36lMngNhZIIbtkitLVeufxp9rFjr)wzKB9vXKcYu1Th99pSs3hgFj60fNa)W8l1jFje5Fjv4wFFjOk20fN(sqvEM(sqigv4wFfadtlLZlcf5v3EumBBmSpgrFGzZlaC9rvviWKB9vOtxCcmgifJkCRVcs0yXErOiV62JIbsXi6dmBEbGRpQQcbMCRVcD6ItGXaXy22yGqmQWnOuLo6zekgwgdufB6Itfr)wzKB9vb46Jqo2KLIbIXaPyuHB9va46Jqo2KLkcf5v3EumBBmqigv4guQsh9mcfd7sfdufB6Itfr)wzKB9vb46Jqo2KLIbIXipXavXMU4ur0Vvg5wFvHI8kMEQDOVeiHeylXT((sWyNIrOipg3Eumnqm(ofdkH48y8D1JzJX5XSOysWKqrEm25DmWUFRmYT(kFjOkUE6J(sI(TYi36RMGjHI8QBp67FyjFFy8LOtxCc8dZVuN8LqK)LuHB99LGQytxC6lbv5z6lbvXMU4ur0Vvg5wFvmPGmvD7rFjOkUE6J(sI(TYi36R62J((hwS(pm(s0Plob(H5xQt(spnTVKkCRVVeufB6ItFjOkUE6J(sI(TYi36R62J(scS5e20VKRC68cGHjKRyNWf60fNaJHHyyFmqvSPlovammHCf7eUk63kJCRVVeiHeylXT((smoIRmfdS73kJCRVyaACmkGt4yybdtixXoHJjFCcHIbQInDXPcGHjKRyNWvr)wzKB9fJHIbrE5lbv5z6lbyyc5k2jCbtp1o03)WI1(W4lrNU4e4hMFPo5l900(sQWT((sqvSPlo9LGQ46Pp6lj63kJCRVQBp6ljWMtyt)sIgkD65fzzcB6fddXi6Md2BUcwbn98kkrXYwW0tTdfJ8eJCqwmSmgOk20fNkI(TYi36R62J(sGesGTe367lX4iUYumWUFRmYT(IbOXXSnuqtppgPeflBmgqmMhZgJZJr0pkMgaigr3CWEZfdQ7R8LGQ8m9LeDZb7nxbRGMEEfLOyzly6P2H((hwmgFy8LOtxCc8dZVuN8LEAAFjv4wFFjOk20fN(sqvC90h9Le9BLrU1x1Th9LeyZjSPFjrdLo98YrcCZBmymmeJOBoyV5kGK67RgFubtp1oumYtmYbzXWYyGQytxCQi63kJCRVQBp6lbsib2sCRVVeJJ4ktXa7(TYi36lgGghdJJuFF14JkFjOkptFjr3CWEZvaj13xn(OcMEQDOV)HL86hgFj60fNa)W8l1jFPNM2xsfU13xcQInDXPVeufxp9rFjr)wzKB9vD7rFjb2CcB6xIs)SLKqGf6LWeMuETXGNEc6lbsib2sCRVVeJJ4ktXa7(TYi36lgGghJVtXi)FjmHjLhdRddE6jOywzaGymGy8DkMeUYeHJXqXKr2bpgFx9yCSDYsE5lbv5z6lbvXMU4uHEjmHjLxBm4PNGQGexzkg5jgieJOBoyV5k0lHjmP8AJbp9eubmJv36lg5jgr3CWEZvOxctys51gdE6jOcMEQDOyGymBBmSpgr3CWEZvOxctys51gdE6jOcMuqM((hwBZpm(s0Plob(H5xQt(spnTVKkCRVVeufB6ItFjOkUE6J(sI(TYi36R62J(scS5e20VeL(zljHalW5kOPEJr1LccNIHHyeDZb7nxboxbn1BmQUuq4uv(y9Sw6s32SGPNAhkg5jM0bzXWYyGQytxCQi63kJCRVQBp6lbsib2sCRVVeJJ4ktXa7(TYi36lgGghJ8cxbn1BmkgyQGWjMJjFCcHIX8y20zoymlkgqIRmrGXW7doHJX31lM0bzXGirFGOYxcQYZ0xs0nhS3Cf4Cf0uVXO6sbHtv5J1ZAPlDBZcMEQDOV)HfJ1hgFj60fNa)W8l1jFPNM2xsfU13xcQInDXPVeufxp9rFjr)wzKB9vD7rFjb2CcB6xYvoDEbNpQ2a1KEdHl0PlobgddXSYaafr)wzKB9va7n3xcKqcSL4wFFjghXvMIb29BLrU1xm5ZnEmBJo9IHslXWekgdigZ3cftoP8LGQ8m9LwzaGcoFuTbQj9gcxW0tTd99pSKdY(W4lrNU4e4hMFPo5l900(sQWT((sqvSPlo9LGQ46Pp6lj63kJCRVQBp6ljWMtyt)sUYPZl48r1gOM0BiCHoDXjWyyiMvgaOi63kJCRVcyV5IHHyeDZb7nxbNpQ2a1KEdHly6P2HIbsXWAXWYyGQytxCQi63kJCRVQBp6lbsib2sCRVVeJJ4ktXa7(TYi36lgGghJEXqP5ynMTr(OyAGysVEdHJXaIX3Py2g5JIPbIj96neoMnDMdgJOFumnaqmIU5G9Mlg1JHtkYJH1IbrI(arXSiGgtXa7(TYi36lMnDMdw(sqvEM(sIU5G9MRGZhvBGAsVHWfm9u7qXaPywzaGcoFuTbQj9gcxaZy1T(((hwYj3hgFj60fNa)W8l1jFPNM2xsfU13xcQInDXPVeufxp9rFjr)wzKB9vD7rFjb2CcB6xcNpcOXWPcOHewc3ofZuv0VNEGf60fNaJHHywzaGcOHewc3ofZuv0VNEGfWEZ9LajKaBjU13xIXrCLPyGD)wzKB9fJbedJZqclHBNIzkgy3VNEGXSPZCWyU2JzrXGjfKPyaACmMhdtKx(sqvEM(sIU5G9MRSYaavqdjSeUDkMPQOFp9aly6P2H((hwYLUpm(s0Plob(H5xQt(spnTVKkCRVVeufB6ItFjOkUE6J(sI(TYi36R62J(scS5e20VewnWkbLoVOGGOcLMHCummedwnWkbLoVOGGOIOZNhd7sfJ8fddXGvdSsqPZlkiiQaMXQB9fd7Irow7lbsib2sCRVV02qnWyK)qPZrmAmmoIRmfdS73kJCRVyaACmkiymOeDZHIPbIr(IPXX8AmfJccIIX3vpMngNhdxrEm8(Gt4y8D9Irowlgej6devIbg7eIIbQYZekgft3wEmhjiesXgNPy6e3Ekpg7Ir58yekIqLVeuLNPVewnWkbLoVOGGOIDF)dl5KVpm(s0Plob(H5xQt(siY)sQWT((sqvSPlo9LGQ46Pp6lj63kJCRVQBp6ljWMtyt)sy1aReu68c0m)iSU4uHsZqokggIbQInDXPIOFRmYT(QysbzQ62JIHLXGvdSsqPZlqZ8JW6Itf7(sGesGTe367lTnudmg5pu6CeJgZ2X3OmHIjJOyGD)wzKB9fZgZ3JbAMFewxg3CMIbRgymeu6CeZX0qjm2aPy0JPyajUYekgUHCcmgD1qPy8oMNklfdkJPympg4KJIjJiWy2jmv(sqvEM(sy1aReu68c0m)iSU4uXUy22yyFmy1aReu68c0m)iSU4ujN89pSKJ1)HXxIoDXjWpm)sDYxcr(xsfU13xcQInDXPVeufxp9rFjr)wzKB9vD7rFjb2CcB6xcQInDXPIOFRmYT(QysbzQ62JIbsXi6Md2BUIOFRmYT(kGzS6wFXSTXaHyKlg5jgiedKvymIbsXazL0fZ2gJRC68cGHjKRyNWf60fNaJbIXSTX4kNoViRDGC7GxOtxCcmgigdltfdufB6Itfr)wzKB9vD7rXWgBXavXMU4ur0Vvg5wFv3EumSlgad(UxX0tTdfJ8et6GSVeiHeylXT((smEikgFNI5O08yGD)wzKB9ftFXi6Md2BUymGympMnDMdgZ1EmlkgkTes4eymEhdiXvMIX3PyqIDcmZjWy6JIPXX47umiXobM5eym9rXSPZCWy21Ke6IHtium(UEXKoilgej6defZIaAmfJVtXayW39yOdev(sqvEM(sqvSPlove9BLrU1xftkitv3E03)Wsow7dJVeD6ItGFy(L6KVKcc(LuHB99LGQytxC6lbv5z6l52J(sGesGTe367lTDGGX47umImgtNhJBpkgVJX3PyqIDcmZjWyGD)wzKB9fJ3XKK9ympg7IrxOMNDkg3EumOogFx9ympgdfdYnopgviYy1PyuaNWXOXWn35umU9OysueIqLVeufxp9rFjr)wzKB9vD7rF)dl5ym(W4lrNU4e4hMFPo5lHi)lPc367lbvXMU40xcKqcSL4wFFjwWoLZzI5ye9bLWEma4(fJUqnp7umU9Oy0dmgK3ykgFNIbtC1nOumU9OySlgOk20fNkU9OQ3vr)wzKB9vIHX74MSum(ofdMqEmnqm(ofJq5ImxDRpeZXSz3e7XSRjj0fdNqOyaWu6NPZ5mfJ3XGsicmMCsm(ofdYEzU6wFmhJVBOy21Ke6qX0aaYJ8cSzCXOhymB2nofJqrUDWlFjOkptFjiedufB6Itfr)wzKB9vD7rXipX42JIbIXSTXSYaafr)wzKB9va7n3xkJOAdauHla)WsUVeufxp9rFj3Eu17QOFRmYT((szev3SBCQkuKBh8pSK77F)lH7KAYUIOpm(WsUpm(s0Plob(H5xsGnNWM(LuHBqPkD0ZiumSlvmqvSPlov2BVICmPYwb46Jqo2KLIHHyGqmRmaqzV9kYXKkBjNedBSfZkdauammH8g)k5KyG4xsfU13xcGRpc5ytw67FyLUpm(s0Plob(H5xsGnNWM(LwzaGckFvzTdoQU4eczh8kMuqMk5KyyiMvgaOGYxvw7GJQloHq2bVIjfKPcMEQDOyyxmcf5v3E0xsfU13xkHjCV4kY)(hwY3hgFj60fNa)W8ljWMtyt)sRmaqbWWeYB8RKt(sQWT((sjmH7fxr(3)WI1)HXxIoDXjWpm)scS5e20V0kdau2BVICmPYwYjFjv4wFFPeMW9IRi)7FyXAFy8LOtxCc8dZVugr1n7gNQcf52b)dl5(scS5e20Ve7JbQInDXPcGHP6IRiVM0n3o4XWqmRmaqbLVQS2bhvxCcHSdEftkitfWEZfddXOc3Gsv6ONrOyyzmqvSPlov2vmyvOiVcW1hHCSjlfddXW(yammHCf7eUOc3GsXWqmqig2hZkdau2j1TdEnNuYjXWqmSpMvgaOS3Ef5ysLTKtIHHyyFmjycATbaQWfGfadt1fxrEmmedeIrfU1xbWWuDXvKxe7kgoHIHDPIjDXWgBXaHyCLtNxuoLgYXkA7JIQazmtf60fNaJHHyeDZb7nxbeRW7dvxys99cMuqMIbIXWgBXGifBh8Q3zXErfUbLIbIXaXVugr1gaOcxa(HLCFjv4wFFjadt1fxr(xcKqcSL4wFFjgpeftFumSGHPyGjxrEmKI5mfJDXSn60lgdigM6CmG9TLhZUcLIHmFNWXS9i1TdEmmEjX04y2EThJKJjv2yyI8y0dmgY8DcZOXabfIXSRqPyEnMIX31lgFthJYXKcYeZXaHfeJzxHsXSDCknKJv02hDlumSqgZumysbzkgVJjJiMJPXXabbeJrIuSDWJbgDwShJHIrfUbLkXW46BlpgWogF3qXSz34um7kgmgHIC7GhdlW1hHCSjlHIPXXSzNUyKYxmmMSd(wOyGjNqi7GhJHIbtkitLV)HfJXhgFj60fNa)W8lLruDZUXPQqrUDW)WsUVKaBoHn9lX(yGQytxCQayyQU4kYRjDZTdEmmed7JbWWeYvSt4IkCdkfddXaHyGqmqigv4wFfadtlLZluAKi72bpggIbcXOc36RayyAPCEHsJezNQy6P2HIHLXazfwlg2ylg2hdoFeqJHtfadtiVXVcD6ItGXaXyyJTyuHB9vsyc3lUI8cLgjYUDWJHHyGqmQWT(kjmH7fxrEHsJezNQy6P2HIHLXazfwlg2ylg2hdoFeqJHtfadtiVXVcD6ItGXaXyGymmeZkdau2j1TdEnNuYjXaXyyJTyGqmisX2bV6DwSxuHBqPyyigieZkdau2j1TdEnNuYjXWqmSpgv4wFfKOXI9cLgjYUDWJHn2IH9XSYaaL92RihtQSLCsmmed7JzLbak7K62bVMtk5Kyyigv4wFfKOXI9cLgjYUDWJHHyyFm7TxroMuzROeIZrv7QaCd(UhdeJbIXaXVugr1gaOcxa(HLCFjv4wFFjadt1fxr(xcKqcSL4wFFjgpefdlyykgyYvKhdz(oHJbmJTdEmAmSGHPLY5Sk9yc3lUI8yekYJzZoDXS9i1TdEmmEjXyOyuHBqPyACmGzSDWJHsJezNIzJ57Xirk2o4XaJol2lF)dl51pm(s0Plob(H5xsfU13xsOCEvfU1xLBi)lXnKxp9rFjv4guQ6kNoh99pS2MFy8LOtxCc8dZVKaBoHn9lTYaaLeMWTGROxjNeddXiuKxD7rXWYywzaGsct4wWv0RGPNAhkggIrOiV62JIHLXSYaafC(OAdut6neUGPNAh6lPc367lLWeUxCf5F)dlgRpm(s0Plob(H5xsGnNWM(LwzaGYE7vKJjv2sojggIbrk2o4vVZI9IkCdkfddXOc3Gsv6ONrOyyzmqvSPlov2BVICmPYwb46Jqo2KL(sQWT((sjmH7fxr(3)Wsoi7dJVeD6ItGFy(LeyZjSPFj2hdufB6ItLK9MolTAs3C7GhddXSYaaLDsD7GxZjLCsmmed7JzLbak7TxroMuzl5KyyigieJkCdkvbBVyWpZPyyzmPlg2ylgv4guQsh9mcfd7sfdufB6ItLDfdwfkYRaC9rihBYsXWgBXOc3Gsv6ONrOyyxQyGQytxCQS3Ef5ysLTcW1hHCSjlfde)sQWT((sj7nDwAvaU(i03)Wso5(W4lrNU4e4hMFjb2CcB6xcrk2o4vVZI9IkCdk9LuHB99LqIgl2)(hwYLUpm(s0Plob(H5xsGnNWM(LuHBqPkD0ZiumSlM09LuHB99LaXk8(q1fMuF)7FyjN89HXxIoDXjWpm)scS5e20VKkCdkvPJEgHIHDPIbQInDXPIIf6rvkTeEJS(IHHyE6PLeHhd7sfdufB6Itffl0JQuAj8gz9vF6PFjv4wFFjfl0JQuAj8gz999pSKJ1)HXxIoDXjWpm)sQWT((saC9rihBYsFjqcjWwIB99LySnFpg66m89yCfdNCeZXyEmgkgng4QDX4Dmcf5XWcC9rihBYsXOOyamoNWXyhYjfmMgigwWW0s58YxsGnNWM(LuHBqPkD0ZiumSlvmqvSPlov2vmyvOiVcW1hHCSjl99pSKJ1(W4lPc367lbyyAPC(xIoDXjWpm)(3)sGeGM5(hgFyj3hgFj60fNa)W8ljWMtyt)sSpgC(iGgdNkGgsyjC7umtvr)E6bwOtxCc8lPc367lj685egLqC(3)WkDFy8LOtxCc8dZVeiHeylXT((sWyNIr0Vvg5wFv3E2bpgv4wFXWnKhdsStGzoHIzZoDXa7(TYi36lMngNhZIIjJiWy0dmgK3ycfJVtXGjuM7XyxmqvSPlovC7rvVRI(TYi36R8LuHB99LekNxvHB9v5gY)sCd51tF0xs0Vvg5wFv3E2b)7FyjFFy8LOtxCc8dZVuN8LqK)LuHB99LGQytxC6lbv5z6lbHyuHBqPkD0ZiumSmgOk20fNkI(TYi36RI2na3o41KEdHJHn2IrfUbLQ0rpJqXWYyGQytxCQi63kJCRVkaxFeYXMSumSXwmqvSPlovC7rvVRI(TYi36lg5jgv4wFf0Ub42bVM0BiCbiZ5vmbMfU1xmSlgr3CWEZvq7gGBh8AsVHWfWmwDRVyGymmedufB6Itf3Eu17QOFRmYT(IrEIr0nhS3Cf0Ub42bVM0BiCbtp1oumSlgv4wFf0Ub42bVM0BiCbiZ5vmbMfU1xmmedeIr0nhS3CfC(OAdut6neUGPNAhkg5jgr3CWEZvq7gGBh8AsVHWfm9u7qXWUyyTyyJTyyFmUYPZl48r1gOM0BiCHoDXjWyG4xcKqcSL4wFFj5NInDXPy8D1JHqU9uNqXSzN8DchJ0Ub42bpM0R3q4y2yCEmlkMmIaJzranMIb29BLrU1xmgkgmPGmv(sqvC90h9Lq7gGBh8AsVHW1fb0yQk63kJCRVV)HfR)dJVeD6ItGFy(LeyZjSPFPvgaOi63kJCRVcyV5IHHyuHB9vammvxCf5fXUIHtOyyzQyKlggIH9XaHywzaGIDae(uEvOiHcsLCsmmeZkdau2BVICmPYwWKk8yGymmedufB6Itf0Ub42bVM0BiCDranMQI(TYi367lPc367lH2na3o41KEdH)(hwS2hgFj60fNa)W8ljWMtyt)sRmaqr0Vvg5wFfWEZfddXaHyGQytxCQ42JQExf9BLrU1xmSmgOk20fNkI(TYi36RMGjHI8QBpkgifdLgjYovD7rXWgBXavXMU4uXThv9Uk63kJCRVyyxmQWT(QIU5G9Mlg5jg5GSyG4xsfU13xcRGMEEfLOyz)(hwmgFy8LOtxCc8dZVKaBoHn9lTYaafr)wzKB9va7nxmmeZkdauW5JQnqnP3q4cyV5IHHyGQytxCQ42JQExf9BLrU1xmSmgOk20fNkI(TYi36RMGjHI8QBpkgifdLgjYovD7rFjv4wFFjqs99vJp67FyjV(HXxIoDXjWpm)scS5e20VeufB6Itf3Eu17QOFRmYT(IHLXavXMU4ur0Vvg5wF1emjuKxD7rXaPyO0ir2PQBpkggIzLbakI(TYi36Ra2BUVKkCRVV0ZW4gJQnq1B8Jo)7FyTn)W4lrNU4e4hMFPmIQB2novfkYTd(hwY9LajKaBjU13xIfACmYp68DMWmhtgrXOXWcgMIbMCf5Xi2vmCkgWm2o4XS9ByCJrX0aXaJg)OZJrOipgVJrH2gymcnjXo4Xi2vmCcv(sQWT((sagMQlUI8VKaBoHn9lPc36R8mmUXOAdu9g)OZluAKi72bpggIbiZ5vmj2vmCQ62JIrEIrfU1x5zyCJr1gO6n(rNxO0ir2PkMEQDOyyzmS(yyig2hZE7vKJjv2kkH4Cu1Uka3GV7XWqmSpMvgaOS3Ef5ysLTKt((hwmwFy8LOtxCc8dZVKkCRVVeCUcAQ3yuDPGWPVKaBoHn9lbvXMU4uXThv9Uk63kJCRVyyxmQWT(QIU5G9Mlg5jgw7lraaKWRN(OVeCUcAQ3yuDPGWPV)HLCq2hgFj60fNa)W8lPc367lrVeMWKYRng80tqFjb2CcB6xcQInDXPIBpQ6Dv0Vvg5wFXWYuXavXMU4uHEjmHjLxBm4PNGQGexzkggIbQInDXPIBpQ6Dv0Vvg5wFXWUyGQytxCQqVeMWKYRng80tqvqIRmfJ8edR9Lo9rFj6LWeMuETXGNEc67FyjNCFy8LOtxCc8dZVKkCRVVeCotj71gOQiK9mU6wFFjb2CcB6xcQInDXPIBpQ6Dv0Vvg5wFXWUuXavXMU4uPVAgrvr2BaGV0Pp6lbNZuYETbQkczpJRU133)WsU09HXxIoDXjWpm)sQWT((spvOlmvr7e51xgzIVKaBoHn9lbvXMU4uXThv9Uk63kJCRVyyzQyyTV0Pp6l9uHUWufTtKxFzKj((hwYjFFy8LOtxCc8dZVeiHeylXT((sYBGyYi7GhJgdYjCBGX0N8KrumMtpMJr5BuMqXKrummomPGagMIr(rieXJPZoYaPyAGyGD)wzKB9vIH157eEJHiMJjbBn2CB7dftgzh8yyCysbbmmfJ8JqiIhZgZ3Jb29BLrU1xm9Xzkgdig59bq4t5XaBfjuqkgdfdD6ItGXOhymAmzKcNIztFB5XSOy4nYJPHs4y8DkgWmwDRVyAGy8Dkgad(UxIbg7gkgfeefJgd6PCEmqvEMIX7y8Dkgr3CWEZftdedJdtkiGHPyKFecr8y2StxmGTDWJX3numcLlYC1T(IzrcnJOympgdft(WKYrUjIX7yuek)Oy8D1JX8y2yCEmlkMmIaJjHWaKW5mftFXi6Md2BUYx60h9LaXKccyyQcLqiI)LeyZjSPFjOk20fNkU9OQ3vr)wzKB9fd7sfdufB6ItL(QzevfzVbaIHHyGqmRmaqXoacFkVkuKqbPcYvHSXKkMvgaOyhaHpLxfksOGu5PPvrUkKng2ylg2hJOpWS5f7ai8P8QqrcfKk0PlobgdBSfdufB6Itfr)wzKB9v7RMrumSXwmqvSPlovC7rvVRI(TYi36lg2fJDoHtAU6eyfWGV7vm9u7qXW4htmqigv4wFvr3CWEZfdKIroilgigde)sQWT((sGysbbmmvHsieX)(hwYX6)W4lrNU4e4hMFjv4wFFjuN5vd(zoH)scS5e20VeeIbQInDXPIBpQ6Dv0Vvg5wFXWUuXiFqwmBBmqigOk20fNk9vZiQkYEdaed7IbYIbIXWgBXaHyyFmo2ozjV4Yvmub1zE1GFMt4yyighBNSKxC5kzKU4ummeJJTtwYlUCfr3CWEZvW0tTdfdBSfd7JXX2jl5fpDfdvqDMxn4N5eoggIXX2jl5fpDLmsxCkggIXX2jl5fpDfr3CWEZvW0tTdfdeJbIXWqmqig2hdL(zljHalGysbbmmvHsieXJHn2Ir0nhS3CfqmPGagMQqjeI4v5J1ZyTnzn51cMEQDOyyxmSwmq8lD6J(sOoZRg8ZCc)9pSKJ1(W4lrNU4e4hMFjv4wFFjHEcIxxzaGVKaBoHn9lX(ye9bMnVyhaHpLxfksOGuHoDXjWyyig3EumSmgwlg2ylMvgaOyhaHpLxfksOGub5Qq2ysfZkdauSdGWNYRcfjuqQ800QixfY(LwzaG6Pp6lH6mVAWpZT((sGesGTe367lbdSbhoHJrQZ8yK3WpZjCmKI5mfZgZ3JrEFae(uEmWwrcfKIPXXSzNUympMnkkMemjuKx((hwYXy8HXxIoDXjWpm)sGesGTe367ljVD6HIX3vpgWoMR9yw0raMhdS73kJCRVyq7DMdgdJ5mYJzrXKreymD2rgiftdedS73kJCRVyupgu)OysA78Yx60h9LSdjWzxxCQM(z988Rcsqnb9LeyZjSPFjk9ZwscbwGZvqt9gJQlfeofddXavXMU4uXThv9Uk63kJCRVyyxQyGQytxCQ0xnJOQi7naWxsfU13xYoKaNDDXPA6N1ZZVkib1e03)Wso51pm(s0Plob(H5xsfU13xcGRpQ2a1L6oN(scS5e20VeL(zljHalW5kOPEJr1LccNIHHyGQytxCQ42JQExf9BLrU1xmSlvmqvSPlov6RMruvK9ga4lD6J(saC9r1gOUu3503)WsUT5hgFj60fNa)W8lPc367lTrLLocJQa4(a)scS5e20VeL(zljHalW5kOPEJr1LccNIHHyGQytxCQ42JQExf9BLrU1xmSlvmqvSPlov6RMruvK9ga4lD6J(sBuzPJWOkaUpWV)HLCmwFy8LOtxCc8dZVKkCRVVKDihNfEJrvqdQDuDrC(xsGnNWM(LO0pBjjeyboxbn1BmQUuq4ummedufB6Itf3Eu17QOFRmYT(IHDPIbQInDXPsF1mIQIS3aaFPtF0xYoKJZcVXOkOb1oQUio)7FyLoi7dJVeD6ItGFy(LuHB99Lq5BX7gSQpY3zc5Fjb2CcB6xIs)SLKqGf4Cf0uVXO6sbHtXWqmqvSPlovC7rvVRI(TYi36lg2LkgOk20fNk9vZiQkYEda8Lo9rFju(w8UbR6J8DMq(3)WkDY9HXxIoDXjWpm)scS5e20VeufB6Itf3Eu17QOFRmYT(IHDPIbQInDXPsF1mIQIS3aaFjv4wFFPmIQMtp03)WkDP7dJVeD6ItGFy(LuHB99LaWnYRxdv)sGesGTe367lX4HOyybCJ8yGvdvJX7yCSbhoHJrEbBiotXiVfMGtLVKaBoHn9lHZhb0y4ubo2qCMQMWeCQqNU4eymmeZkdaue9BLrU1xbS3CXWqmqigOk20fNkU9OQ3vr)wzKB9fd7IrfU1xv0nhS3CXWgBXavXMU4uXThv9Uk63kJCRVyyzmqvSPlove9BLrU1xnbtcf5v3EumqkgknsKDQ62JIbIF)dR0jFFy8LOtxCc8dZVKkCRVVKOZNtyucX5FjqcjWwIB99LKxipgFNIHXziHLWTtXmfdS73tpWywzaGyYjmht(4ecfJOFRmYT(IXqXG6(kFjb2CcB6xcNpcOXWPcOHewc3ofZuv0VNEGf60fNaJHHyeDZb7nxzLbaQGgsyjC7umtvr)E6bwW0tTdfdlJrfU1xba3iF1CViuKxD7rXWqmRmaqb0qclHBNIzQk63tpWQIf6rfWEZfddXW(ywzaGcOHewc3ofZuv0VNEGLCsmmedeIbQInDXPIBpQ6Dv0Vvg5wFXaPyuHB9vaWnYxn3lcf5v3EumSlgr3CWEZvwzaGkOHewc3ofZuv0VNEGfWmwDRVyyJTyGQytxCQ42JQExf9BLrU1xmSmgwlgi(9pSshR)dJVeD6ItGFy(LeyZjSPFjC(iGgdNkGgsyjC7umtvr)E6bwOtxCcmggIr0nhS3CLvgaOcAiHLWTtXmvf97Phybtp1oumSmgknsKDQ62JIbsXOc36RaGBKVAUxekYRU9OyyiMvgaOaAiHLWTtXmvf97PhyvXc9OcyV5IHHyyFmRmaqb0qclHBNIzQk63tpWsojggIbcXavXMU4uXThv9Uk63kJCRVyGumuAKi7u1ThfdKIrfU1xba3iF1CViuKxD7rXWUyeDZb7nxzLbaQGgsyjC7umtvr)E6bwaZy1T(IHn2IbQInDXPIBpQ6Dv0Vvg5wFXWYyyTyyig2hJRC68coFuTbQj9gcxOtxCcmgi(LuHB99LuSqpQsPLWBK133)WkDS2hgFj60fNa)W8ljWMtyt)s48rangovanKWs42PyMQI(90dSqNU4eymmeJOBoyV5kRmaqf0qclHBNIzQk63tpWcMEQDOyyzmcf5v3EummeZkdauanKWs42PyMQI(90dScGBKxa7nxmmed7JzLbakGgsyjC7umtvr)E6bwYjXWqmqigOk20fNkU9OQ3vr)wzKB9fdKIrOiV62JIHDXi6Md2BUYkdaubnKWs42PyMQI(90dSaMXQB9fdBSfdufB6Itf3Eu17QOFRmYT(IHLXWAXaXVKkCRVVeaUr(Q5(3)WkDmgFy8LOtxCc8dZVKaBoHn9lHZhb0y4ub0qclHBNIzQk63tpWcD6ItGXWqmIU5G9MRSYaavqdjSeUDkMPQOFp9alysbzkggIzLbakGgsyjC7umtvr)E6bwbWnYlG9MlggIH9XSYaafqdjSeUDkMPQOFp9al5KyyigiedufB6Itf3Eu17QOFRmYT(IHDXi6Md2BUYkdaubnKWs42PyMQI(90dSaMXQB9fdBSfdufB6Itf3Eu17QOFRmYT(IHLXWAXaXVKkCRVVeaUrE9AO63)WkDYRFy8LOtxCc8dZVKaBoHn9lbvXMU4uXThv9Uk63kJCRVyyzQyGSyyJTyGQytxCQ42JQExf9BLrU1xmSmgOk20fNkI(TYi36RMGjHI8QBpkggIr0nhS3Cfr)wzKB9vW0tTdfdlJbQInDXPIOFRmYT(QjysOiV62J(sQWT((scLZRQWT(QCd5FjUH86Pp6lj63kJCRVAYUIOV)Hv62MFy8LOtxCc8dZVKaBoHn9lTYaafC(OAdut6neUa2BUyyig2hZkdauammH8g)k5KyyigiedufB6Itf3Eu17QOFRmYT(IHDPIzLbak48r1gOM0BiCbmJv36lggIbQInDXPIBpQ6Dv0Vvg5wFXWUyuHB9vammvxCf5fGmNxXKyxXWPQBpkg2ylgOk20fNkU9OQ3vr)wzKB9fd7IbWGV7vm9u7qXaXVKkCRVVeoFuTbQj9gc)9pSshJ1hgFj60fNa)W8l1jFje5Fjv4wFFjOk20fN(sGesGTe367lLEDZJrrX80JPyybdtXatUICumkkMKgHSfNIbOXXa7(TYi36ReJuE5yv4X0zpMgigFNIbaRc36t5Xi6xsF05X0aX47umx(TiCmnqmSGHPyGjxrokgFx9y2yCEmN6zSY5mfdMe7kgofdygBh8y8Dkgy3Vvg5wFXKSRikMfj0mIIjPBUDWJrpM8D7GhtII8y8D1JzJX5XCThdCSEEm6fdLMJ1yybdtXatUI8yaZy7GhdS73kJCRVYxcQYZ0xsfU1xbWWuDXvKxe7kgoHQayv4wFkpgifdeIbQInDXPIBpQ6Dv0Vvg5wFXaPyuHB9vq7gGBh8AsVHWfGmNxXeyw4wFXSTXavXMU4ubTBaUDWRj9gcxxeqJPQOFRmYT(IbIXWQyeDZb7nxbWWuDXvKxaZy1T(IrEIrUyyzmIU5G9MRayyQU4kYlpnTQyxXWjumqkgOk20fNknucN0nVcyyQU4kYrXWQyeDZb7nxbWWuDXvKxaZy1T(IrEIbcXSYaafr)wzKB9vaZy1T(IHvXi6Md2BUcGHP6IRiVaMXQB9fdeJjgg)yKlggIbQInDXPIBpQ6Dv0Vvg5wFXWYyam47Eftp1o0xkJOAdauHla)WsUVeufxp9rFjadt1fxrEnPBUDW)szev3SBCQkuKBh8pSK77FyjFq2hgFj60fNa)W8l1jFje5Fjv4wFFjOk20fN(sqvC90h9Ls2B6S0QjDZTd(xsGnNWM(LuHBqPkD0ZiumSmgOk20fNkI(TYi36RcW1hHCSjl9LajKaBjU13xs(PytxCkgFx9ye954MJIj92B6S0IHf46JqXKrkCkgVJHougtXyokgXUIHtOyumfts3CcmgGghdS73kJCRVsmSUJZumzeft6T30zPfdlW1hHIPZoYaPyAGyGD)wzKB9fZMD6IbiZ5Xi2vmCcfJqVywum9Yv7iWyaZy7GhJVtXCuAEmWUFRmYT(kFjOkptFjOk20fNkU9OQ3vr)wzKB9fdKIzLbakI(TYi36RaMXQB9fJ8edRfdlJrfU1xjzVPZsRcW1hHkazoVIjXUIHtv3Eumqkgr3CWEZvs2B6S0QaC9rOcygRU1xmYtmQWT(kODdWTdEnP3q4cqMZRycmlCRVy22yGQytxCQG2na3o41KEdHRlcOXuv0Vvg5wFXWqmqvSPlovC7rvVRI(TYi36lgwgdGbF3Ry6P2HIHn2IbNpcOXWPckFvzTdoQU4eczh8cD6ItGXWgBX42JIHLXWAF)dl5tUpm(s0Plob(H5xQt(siY)sQWT((sqvSPlo9LGQ46Pp6lLS30zPvt6MBh8VKaBoHn9lPc3Gsv6ONrOyyxQyGQytxCQi63kJCRVkaxFeYXMS0xcKqcSL4wFFjg7D6IjJSdEmSaxFeYXMSum2fdS73kJCRpMJbPqPyuump9ykgXUIHtOyuumjnczlofdqJJb29BLrU1xmBmFVZEmcnjXo4LVeuLNPVeufB6Itf3Eu17QOFRmYT(IHLXOc36RKS30zPvb46JqfGmNxXKyxXWPQBpkg5jgv4wFf0Ub42bVM0BiCbiZ5vmbMfU1xmBBmqvSPlovq7gGBh8AsVHW1fb0yQk63kJCRVyyigOk20fNkU9OQ3vr)wzKB9fdlJbWGV7vm9u7qXWgBXGZhb0y4ubLVQS2bhvxCcHSdEHoDXjWyyJTyC7rXWYyyTV)HL8LUpm(s0Plob(H5xsGnNWM(LwzaGcoFuTbQj9gcxYjXWqmqvSPlovC7rvVRI(TYi36lg2fdK9Lqo2e(hwY9LuHB99LekNxvHB9v5gY)sCd51tF0xc3j1KDfrF)dl5t((W4lrNU4e4hMFPmIQB2novfkYTd(hwY9LajKaBjU13xA7azmNrEm(ofdufB6ItX47QhJOph3CumSGHPyGjxrEmzKcNIX7yOdLXumMJIrSRy4ekgftXOCuhts3CcmgGghZ2iFumnqmPxVHWLVuN8LqK)LeyZjSPFj2hdufB6Itfadt1fxrEnPBUDWJHHyCLtNxW5JQnqnP3q4cD6ItGXWqmRmaqbNpQ2a1KEdHlG9M7lbv5z6lj6Md2BUcoFuTbQj9gcxW0tTdfdlJrfU1xbWWuDXvKxaYCEftIDfdNQU9OyKNyuHB9vq7gGBh8AsVHWfGmNxXeyw4wFXSTXaHyGQytxCQG2na3o41KEdHRlcOXuv0Vvg5wFXWqmIU5G9MRG2na3o41KEdHly6P2HIHLXi6Md2BUcoFuTbQj9gcxW0tTdfdeJHHyeDZb7nxbNpQ2a1KEdHly6P2HIHLXayW39kMEQDOVugr1gaOcxa(HLCFjv4wFFjOk20fN(sqvC90h9LammvxCf51KU52b)7FyjFS(pm(s0Plob(H5xkJO6MDJtvHIC7G)HLCFjb2CcB6xI9XavXMU4ubWWuDXvKxt6MBh8yyigOk20fNkU9OQ3vr)wzKB9fd7IbYIHHyuHBqPkD0ZiumSlvmqvSPlov2vmyvOiVcW1hHCSjlfddXW(yammHCf7eUOc3GsXWqmSpMvgaOS3Ef5ysLTKtIHHyGqmRmaqzNu3o41CsjNeddXOc36RaW1hHCSjlvO0ir2PkMEQDOyyzmqwH1IHn2IrSRy4eQcGvHB9P8yyxQysxmq8lLruTbaQWfGFyj3xsfU13xcWWuDXvK)LajKaBjU13xIXENUy2EkguOi3o4XWcC9rXi5ytwI5yybdtXatUICumO9oZbJzrXKreymEhdC6iS6umBV2JrYXKklkg9aJX7yO0C6aJbMCf5eoMTFf5eU89pSKpw7dJVeD6ItGFy(LYiQUz34uvOi3o4Fyj3xsGnNWM(LammHCf7eUOc3GsXWqmIDfdNqXWUuXixmmed7JbQInDXPcGHP6IRiVM0n3o4XWqmqig2hJkCRVcGHPLY5fknsKD7GhddXW(yuHB9vsyc3lUI8IDvaUbF3JHHywzaGYoPUDWR5Ksojg2ylgv4wFfadtlLZluAKi72bpggIH9XSYaaL92RihtQSLCsmSXwmQWT(kjmH7fxrEXUka3GV7XWqmRmaqzNu3o41CsjNeddXW(ywzaGYE7vKJjv2sojgi(LYiQ2aav4cWpSK7lPc367lbyyQU4kY)sGesGTe367lX4Yy7Ghdlyyc5k2jmZXWcgMIbMCf5OyumftgrGXGSNXvmNPy8ogWm2o4Xa7(TYi36ReJ8cDew5CMyogFNykgftXKreymEhdC6iS6umBV2JrYXKklkMn70fJaBokMngNhZ1EmlkMnkYjWy0dmMnMVhdm5kYjCmB)kYjmZX47etXG27mhmMffdkbtkymD2JX7yEQDUAxm(ofdm5kYjCmB)kYjCmRmaq57FyjFmgFy8LOtxCc8dZVugr1n7gNQcf52b)dl5(sGesGTe367lTDqBdmgHMKyh8yybdtXatUI8ye7kgoHIzZUXPye76De3o4XiTBaUDWJj96ne(lPc367lbyyQU4kY)scS5e20VKkCRVcA3aC7Gxt6neUqPrISBh8yyigGmNxXKyxXWPQBpkgwgJkCRVcA3aC7Gxt6neU4Mq2kMaZc36lggIzLbak7TxroMuzlG9MlggIXThfd7Iroi77FyjFYRFy8LOtxCc8dZVKaBoHn9lbvXMU4uXThv9Uk63kJCRVyyxmqwmmeZkdauW5JQnqnP3q4cyV5(sQWT((scLZRQWT(QCd5FjUH86Pp6lHC9avmyf3U6wFF)dl5BB(HXxsfU13xcjASy)lrNU4e4hMF)7FPemj63s9pm(WsUpm(sQWT((skwOhvTZjoNe(xIoDXjWpm)(hwP7dJVeD6ItGFy(L6KVeI8VKaBoHn9lbvXMU4ubWWeYvSt4QOFRmYT(IHLXazFjqcjWwIB99L2U0JrIr(PytxCkgwxIB9XOXaJDdfdufB6ItXGsiHbyekMn7KVt4yGD)wzKB9fdAVZCWywumzebgdygBh8yybdtixXoHlFjOkUE6J(sagMqUIDcxf9BLrU13xsfU13xcQInDXPVeuLNPkXr0xsEIrUVeuLNPVKCXSTXW(yCLtNxsyc3cUIEf60fNa)(hwY3hgFj60fNa)W8l1jFje5Fjv4wFFjOk20fN(sqvC90h9L2BVICmPYwb46Jqo2KL(scS5e20VeufB6ItL92RihtQSvaU(iKJnzPysfdK9LajKaBjU13xA7spgjg5NInDXPyyDjU1hJgdm2numqvSPlofdkHegGrOy8DkMl)weoMgigxXWjhfJ6XSz3e7XS9ApgjhtQSXWcC9rihBYsOy6SJmqkMgigy3Vvg5wFXG27mhmMfftgrGLVeuLNPVu6IzBJXvoDEbGRpQMOUyVqNU4eymqkg5lMTng2hJRC68caxFunrDXEHoDXjWV)HfR)dJVeD6ItGFy(L6KVeI8VKkCRVVeufB6ItFjOkUE6J(s7kgSkuKxb46Jqo2KL(scS5e20VeufB6ItLDfdwfkYRaC9rihBYsXKkgi7lbsib2sCRVV02LEmsmYpfB6ItXW6sCRpgngySBOyGQytxCkgucjmaJqX47umx(TiCmnqmUIHtokg1JzZUj2Jz7PyWyGTI8yybU(iKJnzjumD2rgiftdedS73kJCRVyq7DMdgZIIjJiWyuumagNt4YxcQYZ0xkDXSTX4kNoVaW1hvtuxSxOtxCcmgifJ8fZ2gd7JXvoDEbGRpQMOUyVqNU4e43)WI1(W4lrNU4e4hMFPo5lHi)lPc367lbvXMU40xcQIRN(OVKOFRmYT(QaC9rihBYsFjb2CcB6xcQInDXPIOFRmYT(QaC9rihBYsXKkgi7lbsib2sCRVV02LEmsmYpfB6ItXW6sCRpgngySBOyGQytxCkgucjmaJqX47umx(TiCmnqmUIHtokg1JzZUj2Jz71EmsoMuzJHf46Jqo2KLqXOykMmIaJbmJTdEmWUFRmYT(kFjOkptFj5lMTngx505faU(OAI6I9cD6ItGXaPyymIzBJH9X4kNoVaW1hvtuxSxOtxCc87FyXy8HXxIoDXjWpm)sDYxcr(xsfU13xcQInDXPVeufxp9rFjfl0JQuAj8gz99LeyZjSPFjOk20fNkkwOhvP0s4nY6lMuXazFjqcjWwIB99L2U0JrIr(PytxCkgwxIB9XOXaJDdfdufB6ItXGsiHbyekgFNI5YVfHJPbIXvmCYrXOEmB2nXEmBhwOhfJ8pTeEJS(IPZoYaPyAGyGD)wzKB9fdAVZCWywumzebw(sqvEM(smwmwXSTX4kNoVaW1hvtuxSxOtxCcmgift6IzBJH9X4kNoVaW1hvtuxSxOtxCc87FyjV(HXxIoDXjWpm)sDYxctiY)sQWT((sqvSPlo9LGQ46Pp6lPyHEuLslH3iRV6tp9lbsaAM7FjwpK9LajKaBjU13xA7spgjg5NInDXPyyDjU1hJgdm2numqvSPlofdkHegGrOy8DkMeclOZv4umnqmp90yweV3eZMDtShZ2Hf6rXi)tlH3iRVy2yCEmx7XSOyYicS89pS2MFy8LOtxCc8dZVuN8LWeI8VKkCRVVeufB6ItFjOkUE6J(sI(TYi36RI2na3o41KEdH)sGeGM5(xkDFjqcjWwIB99L2U0JrIr(PytxCkgwxIB9XOXaJDkMl)weoMgigxXWjhfJ0Ub42bpM0R3q4yq7DMdgZIIjJiWy6lgWm2o4Xa7(TYi36R89pSyS(W4lrNU4e4hMFPo5lHje5Fjv4wFFjOk20fN(sqvC90h9Le9BLrU1xvOiVIPNAh6lbsaAM7FjiRiV(LajKaBjU13xA7spgjg5NInDXPyyDjU1hJgdm2PyC7rXGPNANDWJPVy0yekYJzZoDXa7(TYi36lgHEXSOyYicmg7IbrI(arLV)HLCq2hgFj60fNa)W8l1jFjmHi)lPc367lbvXMU40xcQIRN(OVudLWjDZRagMQlUIC0xcKa0m3)sq2xcKqcSL4wFFPTl9yKyKFk20fNIH1L4wFmAmWy3qXavXMU4umOesyagHIX3PyU8Br4yAGyqKOpqumnqmSGHPyGjxrEm(U6XG27mhmMffts3CcmMef5X47umGeGM5Em6RZNx((hwYj3hgFj60fNa)W8l1jFjmHi)lPc367lbvXMU40xcQIRN(OVe9syctkV2yWtpbvbjUY0xcKa0m3)sYTn)sGesGTe367lTDPhJeJ8tXMU4umSUe36JrJz71BIH3h8yweqJPyGD)wzKB9fdAVZCWyK)VeMWKYJH1Hbp9eumlkMmIa3((9pSKlDFy8LOtxCc8dZVuN8LqK)LuHB99LGQytxC6lbvX1tF0xYThv9Uk63kJCRVVKaBoHn9lbvXMU4ub0q6Itvr)wzKB99LajKaBjU13xsEdedS73kJCRVymumGgsxCcK5yqIDcmZPy8DkgadJ8yGD)wzKB9fdGIJrbCchJVtXayW39yOdev(sqvEM(sag8DVIPNAhkgifJCqgK99pSKt((W4lrNU4e4hMFPo5lHi)lPc367lbvXMU40xcQYZ0xI1(sGesGTe367lbJDkgWmwDRVyAGy0yKYxmmMSd(wOyGjNqi7GhdS73kJCRVYxcQIRN(OVes2vfmJv3677FyjhR)dJVeD6ItGFy(L6KVeI8VKkCRVVeufB6ItFjOkptFjk9ZwscbwGZvqt9gJQlfeofdBSfdL(zljHalpvOlmvr7e51xgzIyyJTyO0pBjjeyXoKaNDDXPA6N1ZZVkib1eumSXwmu6NTKecSGY3I3nyvFKVZeYJHn2IHs)SLKqGf6LWeMuETXGNEckg2ylgk9Zwscbwa46JQnqDPUZPyyJTyO0pBjjeyzJklDegvbW9bgdBSfdL(zljHal2HCCw4ngvbnO2r1fX5FjqcjWwIB99LyS3jFNWXOXKr6ItXyo9IjJiWy8oMvgaigy3Vvg5wFXyOyO0pBjjey5lbvX1tF0xs0Vvg5wF1(Qze99pSKJ1(W4lrNU4e4hMFPo5lHi)lPc367lbvXMU40xcQIRN(OVuF1mIQIS3aaFjb2CcB6xcQInDXPIOFRmYT(Q9vZi6lbsib2sCRVV02R3edVp4XSiGgtXa7(TYi36lg0EN5GX4y7KLCum(U6X4ydoCchJgdAxXeymc1j4nMPyeDZb7nxm9ft77eoghBNSKJI5ApMfftgrGBF)sqvEM(sPdY((hwYXy8HXxIoDXjWpm)sDYxcr(xsfU13xcQInDXPVeuLNPVu6yTVKaBoHn9lrPF2ssiWYtf6ctv0orE9LrM4lbvX1tF0xQVAgrvr2BaGV)HLCYRFy8LOtxCc8dZVuN8LqK)LuHB99LGQytxC6lbv5z6lLoilgifdufB6Itf6LWeMuETXGNEcQcsCLPVKaBoHn9lrPF2ssiWc9syctkV2yWtpb9LGQ46Pp6l1xnJOQi7naW3)WsUT5hgFj60fNa)W8lPc367lH6mVAWpZj8xsGnNWM(LyFmqvSPlove9BLrU1xTVAgrXWqmSpgk9ZwscbwaXKccyyQcLqiIhddXW(yCLtNxammHCf7eUqNU4e4x60h9LqDMxn4N5e(7FyjhJ1hgFjv4wFFPNHXnUApfo9LOtxCc8dZV)Hv6GSpm(s0Plob(H5xsGnNWM(LyFmjycAjHjCV4kY)sQWT((sjmH7fxr(3)(xs0Vvg5wFvr3CWEZH(W4dl5(W4lPc367lL0U13xIoDXjWpm)(hwP7dJVKkCRVV0I3nyfiJz6lrNU4e4hMF)dl57dJVeD6ItGFy(LeyZjSPFPvgaOi63kJCRVso5lPc367lTimIWYAh8V)HfR)dJVKkCRVVeGHPfVBWVeD6ItGFy(9pSyTpm(sQWT((s6jiKJvEvOC(xIoDXjWpm)(hwmgFy8LOtxCc8dZVKaBoHn9lHZhb0y4uXPxsJvEDJItk0PlobgddXSYaafkTDnJCRVso5lPc367l52JQBuCY3)WsE9dJVeD6ItGFy(LuHB99LGZvqt9gJQlfeo9Liaas41tF0xcoxbn1BmQUuq403)WAB(HXxIoDXjWpm)sN(OVKDibo76It10pRNNFvqcQjOVKkCRVVKDibo76It10pRNNFvqcQjOV)HfJ1hgFj60fNa)W8lD6J(saC9r1gOUu350xsfU13xcGRpQ2a1L6oN((hwYbzFy8LOtxCc8dZV0Pp6lTrLLocJQa4(a)sQWT((sBuzPJWOkaUpWV)HLCY9HXxIoDXjWpm)sN(OVKDihNfEJrvqdQDuDrC(xsfU13xYoKJZcVXOkOb1oQUio)7Fyjx6(W4lrNU4e4hMFPtF0xcLVfVBWQ(iFNjK)LuHB99Lq5BX7gSQpY3zc5F)dl5KVpm(sQWT((szevnNEOVeD6ItGFy(9V)LuHBqPQRC6C0hgFyj3hgFj60fNa)W8ljWMtyt)sQWnOuLo6zekg2fJCXWqmRmaqr0Vvg5wFfWEZfddXaHyGQytxCQ42JQExf9BLrU1xmSlgr3CWEZv4gu7Gxx9BvaZy1T(IHn2IbQInDXPIBpQ6Dv0Vvg5wFXWYuXazXaXVKkCRVVe3GAh86QFRV)Hv6(W4lrNU4e4hMFjb2CcB6xcQInDXPIBpQ6Dv0Vvg5wFXWYuXazXWgBXaHyeDZb7nx5ro14cygRU1xmSmgOk20fNkU9OQ3vr)wzKB9fddXW(yCLtNxW5JQnqnP3q4cD6ItGXaXyyJTyCLtNxW5JQnqnP3q4cD6ItGXWqmRmaqbNpQ2a1KEdHl5KyyigOk20fNkU9OQ3vr)wzKB9fd7IrfU1x5ro14IOBoyV5IHn2IbWGV7vm9u7qXWYyGQytxCQ42JQExf9BLrU13xsfU13x6ro14V)HL89HXxIoDXjWpm)scS5e20VKRC68IYP0qowrBFuufiJzQqNU4eymmedeIzLbakI(TYi36Ra2BUyyig2hZkdau2BVICmPYwYjXaXVKkCRVVeiwH3hQUWK67F)7FjKRhOIbR42v367dJpSK7dJVeD6ItGFy(LeyZjSPFjv4guQsh9mcfd7sfdufB6ItL92RihtQSvaU(iKJnzPyyigieZkdau2BVICmPYwYjXWgBXSYaafadtiVXVsojgi(LuHB99La46Jqo2KL((hwP7dJVeD6ItGFy(LeyZjSPFPvgaOayyc5n(vYjFjv4wFFPeMW9IRi)7FyjFFy8LOtxCc8dZVKaBoHn9lTYaaL92RihtQSLCsmmeZkdau2BVICmPYwW0tTdfdlJrfU1xbWW0s58cLgjYovD7rFjv4wFFPeMW9IRi)7FyX6)W4lrNU4e4hMFjb2CcB6xALbak7TxroMuzl5KyyigietcMGwHlalYvammTuopg2ylgadtixXoHlQWnOumSXwmQWT(kjmH7fxrEXUka3GV7XaXVKkCRVVuct4EXvK)9pSyTpm(s0Plob(H5xsfU13xkHjCV4kY)sGesGTe367lbdmtX4DmWjpgjgtWmMeClqXyhYaPy2gD6ftYUIiumnogy3Vvg5wFXKSRicfZMD6IjPriBXPYxsGnNWM(LwzaGckFvzTdoQU4eczh8kMuqMk5KyyigieJOBoyV5k48r1gOM0BiCbtp1oumqkgv4wFfC(OAdut6neUqPrIStv3EumqkgHI8QBpkg2fZkdauq5RkRDWr1fNqi7GxXKcYubtp1oumSXwmSpgx505fC(OAdut6neUqNU4eymqmggIbQInDXPIBpQ6Dv0Vvg5wFXaPyekYRU9OyyxmRmaqbLVQS2bhvxCcHSdEftkitfm9u7qF)dlgJpm(s0Plob(H5xsGnNWM(LwzaGYE7vKJjv2sojggIbrk2o4vVZI9IkCdk9LuHB99Lsyc3lUI8V)HL86hgFj60fNa)W8ljWMtyt)sRmaqjHjCl4k6vYjXWqmcf5v3EumSmMvgaOKWeUfCf9ky6P2H(sQWT((sjmH7fxr(3)WAB(HXxIoDXjWpm)szev3SBCQkuKBh8pSK7ljWMtyt)sSpgadtixXoHlQWnOummed7JbQInDXPcGHP6IRiVM0n3o4XWqmqigiedeIrfU1xbWW0s58cLgjYUDWJHHyGqmQWT(kagMwkNxO0ir2PkMEQDOyyzmqwH1IHn2IH9XGZhb0y4ubWWeYB8RqNU4eymqmg2ylgv4wFLeMW9IRiVqPrISBh8yyigieJkCRVsct4EXvKxO0ir2PkMEQDOyyzmqwH1IHn2IH9XGZhb0y4ubWWeYB8RqNU4eymqmgigddXSYaaLDsD7GxZjLCsmqmg2ylgiedIuSDWRENf7fv4gukggIbcXSYaaLDsD7GxZjLCsmmed7JrfU1xbjASyVqPrISBh8yyJTyyFmRmaqzV9kYXKkBjNeddXW(ywzaGYoPUDWR5KsojggIrfU1xbjASyVqPrISBh8yyig2hZE7vKJjv2kkH4Cu1Uka3GV7XaXyGymq8lLruTbaQWfGFyj3xsfU13xcWWuDXvK)LajKaBjU13xIXLX2bpgFNIb56bQyWyWTRU1hZX0hNPyYikgwWWumWKRihfZMD6IX3jMIrXumx7XSi7Ghts3CcmgGghZ2OtVyACmWUFRmYT(kXW4HOyybdtXatUI8yiZ3jCmGzSDWJrJHfmmTuoNvPht4EXvKhJqrEmB2PlMThPUDWJHXljgdfJkCdkftJJbmJTdEmuAKi7umBmFpgjsX2bpgy0zXE57FyXy9HXxIoDXjWpm)scS5e20V0kdau2BVICmPYwYjXWqmQWnOuLo6zekgwgdufB6ItL92RihtQSvaU(iKJnzPVKkCRVVuct4EXvK)9pSKdY(W4lrNU4e4hMFjb2CcB6xI9XavXMU4ujzVPZsRM0n3o4XWqmqig2hJRC68caUFvFNQkANqf60fNaJHn2IrfUbLQ0rpJqXWUyKlgigddXaHyuHBqPky7fd(zofdlJjDXWgBXOc3Gsv6ONrOyyxQyGQytxCQSRyWQqrEfGRpc5ytwkg2ylgv4guQsh9mcfd7sfdufB6ItL92RihtQSvaU(iKJnzPyG4xsfU13xkzVPZsRcW1hH((hwYj3hgFj60fNa)W8lPc367ljuoVQc36RYnK)L4gYRN(OVKkCdkvDLtNJ((hwYLUpm(s0Plob(H5xsGnNWM(LuHBqPkD0ZiumSlg5(sQWT((sGyfEFO6ctQV)9pSKt((W4lrNU4e4hMFjb2CcB6xcrk2o4vVZI9IkCdk9LuHB99LqIgl2)(hwYX6)W4lrNU4e4hMFjb2CcB6xsfUbLQ0rpJqXWUuXavXMU4urXc9OkLwcVrwFXWqmp90sIWJHDPIbQInDXPIIf6rvkTeEJS(Qp90VKkCRVVKIf6rvkTeEJS(((hwYXAFy8LOtxCc8dZVKkCRVVeaxFeYXMS0xcKqcSL4wFFjgBZ3JHUodFpgxXWjhXCmMhJHIrJbUAxmEhJqrEmSaxFeYXMSumkkgaJZjCm2HCsbJPbIHfmmTuoV8LeyZjSPFjv4guQsh9mcfd7sfdufB6ItLDfdwfkYRaC9rihBYsF)dl5ym(W4lPc367lbyyAPC(xIoDXjWpm)(3)sI(TYi36RMSRi6dJpSK7dJVeD6ItGFy(LeyZjSPFPvgaOi63kJCRVcyV5(sQWT((sCd(UJQmMZGWF05F)dR09HXxIoDXjWpm)szev3SBCQkuKBh8pSK7lbsib2sCRVVK8h52tDkM9Etm8(GhdS73kJCRVy2yCEmCf5X476jlkgVJrkFXWyYo4BHIbMCcHSdEmEhdi5e(zhfZEVjgwWWumWKRihfdAVZCWywumzebw(sDYxcr(xsGnNWM(Le9bMnVyhaHpLxfksOGuHoDXjWVeuLNPV0kdaue9BLrU1xbtp1oumqkMvgaOi63kJCRVcygRU1xmBBmqigr3CWEZve9BLrU1xbtp1oumSmMvgaOi63kJCRVcMEQDOyG4xkJOAdauHla)WsUVKkCRVVeufB6ItFjOkUE6J(suAoDGeyv0Vvg5wFvm9u7qF)dl57dJVeD6ItGFy(LYiQUz34uvOi3o4Fyj3xcKqcSL4wFFPTdeefJVtXaMXQB9ftdeJVtXiLVyymzh8TqXatoHq2bpgy3Vvg5wFX4Dm(ofdDGX0aX47umImgtNhdS73kJCRVymGy8DkgHI8y20zoymI(LWjNIbmJTdEm(UHIb29BLrU1x5l1jFjfe8ljWMtyt)sI(aZMxSdGWNYRcfjuqQqNU4eymmedeIzLbakO8vL1o4O6ItiKDWRysbzQKtIHn2IbQInDXPcLMthibwf9BLrU1xftp1oumSlg5kSwmBBmWfGLNMwmBBmqiMvgaOGYxvw7GJQloHq2bV800QixfYgJ8eZkdauq5RkRDWr1fNqi7GxqUkKngigde)sqvEM(sqvSPlovqYUQGzS6wFFPmIQnaqfUa8dl5(sQWT((sqvSPlo9LGQ46Pp6lrP50bsGvr)wzKB9vX0tTd99pSy9Fy8LOtxCc8dZVKaBoHn9lTYaafr)wzKB9va7n3xsfU13xAPWRnq1XMqw03)WI1(W4lrNU4e4hMFjb2CcB6xsfUbLQ0rpJqXWUyKlggIzLbakI(TYi36Ra2BUVKkCRVVe3GAh86QFRV)HfJXhgFj60fNa)W8lLruDZUXPQqrUDW)WsUVKaBoHn9lX(ye9bMnVyhaHpLxfksOGuHoDXjWyyigXUIHtOyyxQyKlggIzLbakI(TYi36RKtIHHyyFmRmaqbWWeYB8RKtIHHyyFmRmaqzV9kYXKkBjNeddXS3Ef5ysLTIsiohvTRcWn47EmqkMvgaOStQBh8AoPKtIHLXKUVugr1gaOcxa(HLCFjv4wFFjadt1fxr(xcKqcSL4wFFjgBZ37ShJ8(ai8P8yGTIekiXCmmMZipMmIIHfmmfdm5kYrXSzNUy8DIPy203wEmV8j2JrGnhfJEGXSzNUyybdtiVXVymumG9MR89pSKx)W4lrNU4e4hMFPmIQB2novfkYTd(hwY9LajKaBjU13xIX289yK3haHpLhdSvKqbjMJHfmmfdm5kYJjJOyq7DMdgZIIrbbn36t5CMIr0hYXQDeymOogFx9ympgdfZ1EmlkMmIaJjFCcHIrEFae(uEmWwrcfKIXqXORo7X4DmuAjgMIPXX47eMIrXumVgtX476fdDDg(EmSGHPyGjxrokgVJHsZPdmg59bq4t5XaBfjuqkgVJX3PyOdmMgigy3Vvg5wFLVuN8LqK)LeyZjSPFjrFGzZl2bq4t5vHIekivOtxCc8lbv5z6lPc36RayyQU4kYlIDfdNqvaSkCRpLhdKIbcXavXMU4uHsZPdKaRI(TYi36RIPNAhkg5jMvgaOyhaHpLxfksOGubmJv36lgigdRIr0nhS3Cfadt1fxrEbmJv367lLruTbaQWfGFyj3xsfU13xcQInDXPVeufxp9rFjkTes4eyfWWuDXvKJ((hwBZpm(s0Plob(H5xQt(siY)sQWT((sqvSPlo9LYiQ2aav4cWpSK7lbvX1tF0x6icKaRagMQlUIC0xsGnNWM(Le9bMnVyhaHpLxfksOGuHoDXjWVugr1n7gNQcf52b)dl5(sqvEM(scY4XaHyGQytxCQqP50bsGvr)wzKB9vX0tTdfdRIbcXSYaaf7ai8P8QqrcfKkGzS6wFXipXaxawEAAXaXyG43)WIX6dJVeD6ItGFy(LYiQUz34uvOi3o4Fyj3xsGnNWM(Le9bMnVyhaHpLxfksOGuHoDXjWyyigXUIHtOyyxQyKlggIbcXavXMU4uHslHeobwbmmvxCf5OyyxQyGQytxCQCebsGvadt1fxrokg2ylgOk20fNkuAoDGeyv0Vvg5wFvm9u7qXWYuXSYaaf7ai8P8QqrcfKkGzS6wFXWgBXSYaaf7ai8P8QqrcfKkixfYgdlJjDXWgBXSYaaf7ai8P8QqrcfKky6P2HIHLXaxawEAAXWgBXi6Md2BUcA3aC7Gxt6neUGjfKPyyigv4guQsh9mcfd7sfdufB6Itfr)wzKB9vr7gGBh8AsVHWXWqmIgkD65LZGV7vaLIbIXWqmRmaqr0Vvg5wFLCsmmedeIH9XSYaafadtiVXVsojg2ylMvgaOyhaHpLxfksOGubtp1oumSmgiRWAXaXyyig2hZkdau2BVICmPYwYjXWqm7TxroMuzROeIZrv7QaCd(UhdKIzLbak7K62bVMtk5KyyzmP7lLruTbaQWfGFyj3xsfU13xcWWuDXvK)9pSKdY(W4lrNU4e4hMFjv4wFFjHY5vv4wFvUH8Ve3qE90h9LuHBqPQRC6C03)Wso5(W4lrNU4e4hMFPmIQB2novfkYTd(hwY9LeyZjSPFPvgaOi63kJCRVcyV5IHHyGQytxCQ42JQExf9BLrU1xmSmvmqwmmedeIH9XGZhb0y4ub0qclHBNIzQk63tpWcD6ItGXWgBXSYaafqdjSeUDkMPQOFp9al5KyyJTywzaGcOHewc3ofZuv0VNEGvaCJ8sojggIXvoDEbNpQ2a1KEdHl0PlobgddXi6Md2BUYkdaubnKWs42PyMQI(90dSGjfKPyGymmedeIH9XGZhb0y4ubo2qCMQMWeCQqNU4eymSXwmG0kdauGJneNPQjmbNk5KyGymmedeIH9XiAO0PNxosGBEJbJHn2Ir0nhS3Cfqs99vJpQGPNAhkg2ylMvgaOasQVVA8rLCsmqmggIbcXOc36R8iNACXUka3GV7XWqmQWT(kpYPgxSRcWn47Eftp1oumSmvmqvSPlove9BLrU1xvOiVIPNAhkg2ylgv4wFfKOXI9cLgjYUDWJHHyuHB9vqIgl2luAKi7uftp1oumSmgOk20fNkI(TYi36RkuKxX0tTdfdBSfJkCRVcGHPLY5fknsKD7GhddXOc36RayyAPCEHsJezNQy6P2HIHLXavXMU4ur0Vvg5wFvHI8kMEQDOyyJTyuHB9vsyc3lUI8cLgjYUDWJHHyuHB9vsyc3lUI8cLgjYovX0tTdfdlJbQInDXPIOFRmYT(Qcf5vm9u7qXWgBXOc36RaW1hHCSjlvO0ir2TdEmmeJkCRVcaxFeYXMSuHsJezNQy6P2HIHLXavXMU4ur0Vvg5wFvHI8kMEQDOyG4xkJOAdauHla)WsUVKkCRVVKOFRmYT(((hwYLUpm(s0Plob(H5xcKqcSL4wFFjwNVt4yeDZb7nhkgFx9yq7DMdgZIIjJiWy2y(EmWUFRmYT(IbT3zoym9XzkMfftgrGXSX89y0lgv4zLhdS73kJCRVyekYJrpWyU2JzJ57XOXiLVyymzh8TqXatoHq2bpMeClkFjv4wFFjHY5vv4wFvUH8VKaBoHn9lTYaafr)wzKB9vW0tTdfd7IzBgdBSfJOBoyV5kI(TYi36RGPNAhkgwgdR9L4gYRN(OVKOFRmYT(QIU5G9Md99pSKt((W4lrNU4e4hMFjb2CcB6xccXSYaaL92RihtQSLCsmmeJkCdkvPJEgHIHDPIbQInDXPIOFRmYT(QaC9rihBYsXaXyyJTyGqmRmaqbWWeYB8RKtIHHyuHBqPkD0ZiumSlvmqvSPlove9BLrU1xfGRpc5ytwkg5jgC(iGgdNkagMqEJFf60fNaJbIFjv4wFFjaU(iKJnzPV)HLCS(pm(s0Plob(H5xsGnNWM(LwzaGckFvzTdoQU4eczh8kMuqMk5KyyiMvgaOGYxvw7GJQloHq2bVIjfKPcMEQDOyyxmcf5v3E0xsfU13xkHjCV4kY)(hwYXAFy8LOtxCc8dZVKaBoHn9lTYaafadtiVXVso5lPc367lLWeUxCf5F)dl5ym(W4lrNU4e4hMFjb2CcB6xALbakjmHBbxrVsojggIzLbakjmHBbxrVcMEQDOyyxmcf5v3EummedeIzLbakI(TYi36RGPNAhkg2fJqrE1ThfdBSfZkdaue9BLrU1xbS3CXaXyyigv4guQsh9mcfdlJbQInDXPIOFRmYT(QaC9rihBYsFjv4wFFPeMW9IRi)7FyjN86hgFj60fNa)W8ljWMtyt)sRmaqzV9kYXKkBjNeddXSYaafr)wzKB9vYjFjv4wFFPeMW9IRi)7Fyj328dJVeD6ItGFy(LeyZjSPFPembTcxawKRGenwShddXSYaaLDsD7GxZjLCsmmeJkCdkvPJEgHIHLXavXMU4ur0Vvg5wFvaU(iKJnzPyyiMvgaOi63kJCRVso5lPc367lLWeUxCf5F)dl5yS(W4lrNU4e4hMFjv4wFFj0Ub42bVM0Bi8xYoNW4CIxnGVKkCRVcGHP6IRiVi2vmCcLsfU1xbWWuDXvKxEAAvXUIHtOVKaBoHn9lTYaafr)wzKB9vYjXWqmSpgv4wFfadt1fxrErSRy4ekggIrfUbLQ0rpJqXWUuXavXMU4ur0Vvg5wFv0Ub42bVM0BiCmmeJkCRVsYEtNLwfGRpcvaYCEftIDfdNQU9OyyxmazoVIjWSWT((sGesGTe367lX4HSdEms7gGBh8ysVEdHJbmJTdEmWUFRmYT(IX7yWeYBmfdlyykgyYvKhJEGXKE7nDwAXWcC9rXi2vmCcfJqVywuml6iatykN5ywzpMmkRCotX0hNPy6lMTRL)LV)Hv6GSpm(s0Plob(H5xsGnNWM(LwzaGIOFRmYT(k5KyyighRqjE1ThfdlJzLbakI(TYi36RGPNAhkggIbcXaHyuHB9vammvxCf5fXUIHtOyyzmYfddX4kNoVKWeUfCf9k0PlobgddXOc3Gsv6ONrOysfJCXaXyyJTyyFmUYPZljmHBbxrVcD6ItGXWgBXOc3Gsv6ONrOyyxmYfdeJHHywzaGYoPUDWR5KsojgifZE7vKJjv2kkH4Cu1Uka3GV7XWYys3xsfU13xkzVPZsRcW1hH((hwPtUpm(s0Plob(H5xsGnNWM(LwzaGIOFRmYT(kG9MlggIr0nhS3Cfr)wzKB9vW0tTdfdlJrOiV62JIHHyuHBqPkD0ZiumSlvmqvSPlove9BLrU1xfGRpc5ytw6lPc367lbW1hHCSjl99pSsx6(W4lrNU4e4hMFjb2CcB6xALbakI(TYi36Ra2BUyyigr3CWEZve9BLrU1xbtp1oumSmgHI8QBpkggIH9Xi6dmBEbGRpQQcbMCRVcD6ItGFjv4wFFjadtlLZ)(hwPt((W4lrNU4e4hMFjb2CcB6xALbakI(TYi36RGPNAhkg2fJqrE1ThfddXSYaafr)wzKB9vYjXWgBXSYaafr)wzKB9va7nxmmeJOBoyV5kI(TYi36RGPNAhkgwgJqrE1Th9LuHB99LqIgl2)(hwPJ1)HXxIoDXjWpm)scS5e20V0kdaue9BLrU1xbtp1oumSmg4cWYttlggIrfUbLQ0rpJqXWUyK7lPc367lXnO2bVU6367FyLow7dJVeD6ItGFy(LeyZjSPFPvgaOi63kJCRVcMEQDOyyzmWfGLNMwmmeZkdaue9BLrU1xjN8LuHB99LaXk8(q1fMuF)7F)7FjOegz99Hv6GS0jhKjFYbzFPnk(Sdo6lXyVDBdyjVHL8cJgtmWyNIXEjn2JbOXXSLOFRmYT(QU9Sd(wXGP0pBycmgu)Oy0S3p1jWye76bNqLqggXokM0XOXa7(GsyNaJzlrFGzZlq(wX4DmBj6dmBEbYl0PlobUvmqiDPbXsidJyhfdRNrJb29bLWobgZwUYPZlq(wX4DmB5kNoVa5f60fNa3kgiixAqSeYWi2rXWyXOXa7(GsyNaJzlx505fiFRy8oMTCLtNxG8cD6ItGBfdeKlniwczye7OyKdYy0yGDFqjStGXSLRC68cKVvmEhZwUYPZlqEHoDXjWTIbcYLgelHmmIDumYjhJgdS7dkHDcmMTW5JaAmCQa5BfJ3XSfoFeqJHtfiVqNU4e4wXab5sdILqggXokg5y9mAmWUpOe2jWy2YvoDEbY3kgVJzlx505fiVqNU4e4wXaH0LgelHmHmm2B32awYByjVWOXedm2PySxsJ9yaACmBH7KAYUIOTIbtPF2WeymO(rXOzVFQtGXi21doHkHmmIDumSgJgdS7dkHDcmMTCLtNxG8TIX7y2YvoDEbYl0PlobUvmqqU0GyjKHrSJIHXGrJb29bLWobgZw48rangovG8TIX7y2cNpcOXWPcKxOtxCcCRyGq6sdILqMqgg7TBBal5nSKxy0yIbg7um2lPXEmanoMTajanZ9TIbtPF2WeymO(rXOzVFQtGXi21doHkHmmIDumYXOXa7(GsyNaJzlC(iGgdNkq(wX4DmBHZhb0y4ubYl0PlobUvmQhJ8N1XiXab5sdILqggXokg5JrJb29bLWobgZwUYPZlq(wX4DmB5kNoVa5f60fNa3kgiixAqSeYWi2rXiN8XOXa7(GsyNaJrYEWogetNRPfdJpJFmEhdJK1yEnyMNrX0jew9ghdey8HymqqU0GyjKHrSJIro5JrJb29bLWobgZwI(aZMxG8TIX7y2s0hy28cKxOtxCcCRyGGCPbXsidJyhfJCSEgngy3huc7eymB5y7KL8ICfiFRy8oMTCSDYsEXLRa5BfdeKV0GyjKHrSJIrowpJgdS7dkHDcmMTCSDYsEjDfiFRy8oMTCSDYsEXtxbY3kgiiFPbXsidJyhfJCSgJgdS7dkHDcmMTe9bMnVa5BfJ3XSLOpWS5fiVqNU4e4wXab5sdILqggXokM0Logngy3huc7eymBHZhb0y4ubY3kgVJzlC(iGgdNkqEHoDXjWTIbcYLgelHmmIDumPt(y0yGDFqjStGXSfoFeqJHtfiFRy8oMTW5JaAmCQa5f60fNa3kgiixAqSeYWi2rXKowpJgdS7dkHDcmMTCLtNxG8TIX7y2YvoDEbYl0PlobUvmqqU0GyjKHrSJIjDSEgngy3huc7eymBHZhb0y4ubY3kgVJzlC(iGgdNkqEHoDXjWTIbcYLgelHmmIDumPJ1y0yGDFqjStGXSfoFeqJHtfiFRy8oMTW5JaAmCQa5f60fNa3kgiixAqSeYWi2rXKogdgngy3huc7eymBHZhb0y4ubY3kgVJzlC(iGgdNkqEHoDXjWTIbcYLgelHmmIDumPJXIrJb29bLWobgJK9GDmiMoxtlgg)y8oggjRXaAqnK1xmDcHvVXXabwbXyGG8LgelHmmIDumPJXIrJb29bLWobgJK9GDmiMoxtlggFg)y8oggjRX8AWmpJIPtiS6nogiW4dXyGGCPbXsidJyhfJ8bzmAmWUpOe2jWy2cNpcOXWPcKVvmEhZw48rangovG8cD6ItGBfdeKlniwczye7OyKp5y0yGDFqjStGXSfoFeqJHtfiFRy8oMTW5JaAmCQa5f60fNa3kgiixAqSeYWi2rXiFYhJgdS7dkHDcmMTCLtNxG8TIX7y2YvoDEbYl0PlobUvmqqU0GyjKjKHXE72gWsEdl5fgnMyGXofJ9sAShdqJJzRemj63s9TIbtPF2WeymO(rXOzVFQtGXi21doHkHmmIDumPJrJb29bLWobgZwUYPZlq(wX4DmB5kNoVa5f60fNa3kg1Jr(Z6yKyGGCPbXsidJyhfJ8XOXa7(GsyNaJzlx505fiFRy8oMTCLtNxG8cD6ItGBfdeKlniwczye7OyKpgngy3huc7eymB5kNoVa5BfJ3XSLRC68cKxOtxCcCRyupg5pRJrIbcYLgelHmmIDumSEgngy3huc7eymB5kNoVa5BfJ3XSLRC68cKxOtxCcCRyGGCPbXsidJyhfdRNrJb29bLWobgZwUYPZlq(wX4DmB5kNoVa5f60fNa3kg1Jr(Z6yKyGGCPbXsidJyhfdRXOXa7(GsyNaJzlx505fiFRy8oMTCLtNxG8cD6ItGBfdeKlniwczye7Oyyngngy3huc7eymB5kNoVa5BfJ3XSLRC68cKxOtxCcCRyupg5pRJrIbcYLgelHmmIDummgmAmWUpOe2jWy2YvoDEbY3kgVJzlx505fiVqNU4e4wXab5sdILqggXokggdgngy3huc7eymB5kNoVa5BfJ3XSLRC68cKxOtxCcCRyupg5pRJrIbcYLgelHmmIDumYTnz0yGDFqjStGXSLRC68cKVvmEhZwUYPZlqEHoDXjWTIr9yK)SogjgiixAqSeYeYWyVDBdyjVHL8cJgtmWyNIXEjn2JbOXXSLOFRmYT(QIU5G9MdTvmyk9ZgMaJb1pkgn79tDcmgXUEWjujKHrSJIHXGrJb29bLWobgZw48rangovG8TIX7y2cNpcOXWPcKxOtxCcCRyGGCPbXsitidJ92TnGL8gwYlmAmXaJDkg7L0ypgGghZwQWnOu1voDoARyWu6NnmbgdQFumA27N6eymID9GtOsidJyhft6y0yGDFqjStGXSLRC68cKVvmEhZwUYPZlqEHoDXjWTIbcPlniwczye7OyKpgngy3huc7eymB5kNoVa5BfJ3XSLRC68cKxOtxCcCRyGGCPbXsitidJ92TnGL8gwYlmAmXaJDkg7L0ypgGghZwixpqfdwXTRU13wXGP0pBycmgu)Oy0S3p1jWye76bNqLqggXokgwJrJb29bLWobgZwUYPZlq(wX4DmB5kNoVa5f60fNa3kgiixAqSeYWi2rXSnz0yGDFqjStGXSfoFeqJHtfiFRy8oMTW5JaAmCQa5f60fNa3kgiKU0GyjKHrSJIroiJrJb29bLWobgZwUYPZlq(wX4DmB5kNoVa5f60fNa3kgiixAqSeYeYWyVDBdyjVHL8cJgtmWyNIXEjn2JbOXXSLOFRmYT(Qj7kI2kgmL(zdtGXG6hfJM9(PobgJyxp4eQeYWi2rXKogngy3huc7eymBj6dmBEbY3kgVJzlrFGzZlqEHoDXjWTIr9yK)SogjgiixAqSeYWi2rXiFmAmWUpOe2jWy2s0hy28cKVvmEhZwI(aZMxG8cD6ItGBfdeKlniwczye7Oyymy0yGDFqjStGXSLOpWS5fiFRy8oMTe9bMnVa5f60fNa3kgiixAqSeYWi2rXiVYOXa7(GsyNaJrYEWogetNRPfdJFmEhdJK1yanOgY6lMoHWQ34yGaRGymqqU0GyjKHrSJIrELrJb29bLWobgZwI(aZMxG8TIX7y2s0hy28cKxOtxCcCRyupg5pRJrIbcYLgelHmmIDumBtgngy3huc7eyms2d2XGy6CnTyy8JX7yyKSgdOb1qwFX0jew9ghdeyfeJbcYLgelHmmIDumBtgngy3huc7eymBj6dmBEbY3kgVJzlrFGzZlqEHoDXjWTIr9yK)SogjgiixAqSeYWi2rXWyXOXa7(GsyNaJzlrFGzZlq(wX4DmBj6dmBEbYl0PlobUvmqqU0GyjKHrSJIro5y0yGDFqjStGXSLRC68cKVvmEhZwUYPZlqEHoDXjWTIbcYLgelHmmIDumYjhJgdS7dkHDcmMTW5JaAmCQa5BfJ3XSfoFeqJHtfiVqNU4e4wXaH0LgelHmmIDumYjFmAmWUpOe2jWy2cNpcOXWPcKVvmEhZw48rangovG8cD6ItGBfdeKlniwczye7OyshKXOXa7(GsyNaJzlx505fiFRy8oMTCLtNxG8cD6ItGBfdesxAqSeYWi2rXKU0XOXa7(GsyNaJzlrFGzZlq(wX4DmBj6dmBEbYl0PlobUvmQhJ8N1XiXab5sdILqMqg59lPXobgZ2mgv4wFXWnKJkHmFjucj(WIXq((sj4gW40xIfzXyybdtXS9RWPqgwKfJz39eeJYkwb3898Qi6hRq2lZv36tGvaNvi7jyvidlYIXSDjyJht6yoM0bzPtUqMqgwKfJb276bNqmAidlYIXipXW4HOyam47Eftp1oumy13jCm(UEX4kgo5f3Eu17kOrXa04y4kYLhej6dmgDzCZzkMmsHtOsidlYIXipXWiDJOlgHI8yWu6Nnm9OZrXa04yGD)wzKB9fdeScvyogW(2YJzV5GXyEmanogngamH2Jz7NCQXXiuKdXsidlYIXipXi)pDXPyqo2eEmIDsiRDWJPVy0yaOnXa0yzrXyxm(ofZ2LEmsmEhdMaZckMnnwwERGLqgwKfJrEIz7azmNrEmAmPht4EXvKhdDoMPy8D1JbSjumx7X8AqIhZgIZJXo5bU(OyGaYEX4eYjWyupMRJbzWpdWe65XW4spPySxIkCiwczyrwmg5jgy3huc7XOCEmRmaqbYlysfEm05yJqX4DmRmaqbYl5eMJrVyu(RrEm2Hm4Nbyc98yyCPNumWv7IXUyq2dvczczyrwmg5FAKi7eymlcOXumI(TupMfb3oujMTtiOehfZ1N8SR4hqMhJkCRpum9XzQeYOc36dvsWKOFl1HukwPyHEu1oN4Cs4HmSilgZ2LEmsmYpfB6ItXW6sCRpgng5nqmiYJX7y0yU(KNTpeUJbQYZeZX47umWUFRmYT(IrfU1xm6bgJOBoyV5qX47QhJIPye9HCSAhbgJ3X0hNPywumzebgZMD6Ib29BLrU1xmgkMCsmBmopMR9ywumzebgdygBh8y8DkgK9YC1T(kHmSilgJkCRpujbtI(TuhsPyfufB6ItmF6JsbAiDXPQOFRmYT(yUtsHje5HmSymBx6XiXi)uSPlofdRlXT(y0yGXUHIbQInDXPyqjKWamcfZMDY3jCmWUFRmYT(IbT3zoymlkMmIaJbmJTdEmSGHjKRyNWLqgv4wFOscMe9BPoKsXkOk20fNy(0hLcWWeYvSt4QOFRmYT(y2asbvXMU4ubWWeYvSt4QOFRmYT(yjKXmuLNPuYTTS3voDEjHjCl4k6XmuLNPkXruk5rUqgwmMTl9yKyKFk20fNIH1L4wFmAmWy3qXavXMU4umOesyagHIX3PyU8Br4yAGyCfdNCumQhZMDtShZ2R9yKCmPYgdlW1hHCSjlHIPZoYaPyAGyGD)wzKB9fdAVZCWywumzebwczuHB9Hkjys0VL6qkfRGQytxCI5tFuQ92RihtQSvaU(iKJnzjM7KuiYz2asbvXMU4uzV9kYXKkBfGRpc5ytwkfKXmuLNPuPBBDLtNxa46JQjQl2HK8TTS3voDEbGRpQMOUypKHfJz7spgjg5NInDXPyyDjU1hJgdm2numqvSPlofdkHegGrOy8DkMl)weoMgigxXWjhfJ6XSz3e7XS9umymWwrEmSaxFeYXMSekMo7idKIPbIb29BLrU1xmO9oZbJzrXKreymkkgaJZjCjKrfU1hQKGjr)wQdPuScQInDXjMp9rP2vmyvOiVcW1hHCSjlXCNKcroZgqkOk20fNk7kgSkuKxb46Jqo2KLsbzmdv5zkv62wx505faU(OAI6IDijFBl7DLtNxa46JQjQl2dzyXy2U0JrIr(PytxCkgwxIB9XOXaJDdfdufB6ItXGsiHbyekgFNI5YVfHJPbIXvmCYrXOEmB2nXEmBV2JrYXKkBmSaxFeYXMSekgftXKreymGzSDWJb29BLrU1xjKrfU1hQKGjr)wQdPuScQInDXjMp9rPe9BLrU1xfGRpc5ytwI5ojfICMnGuqvSPlove9BLrU1xfGRpc5ytwkfKXmuLNPuY326kNoVaW1hvtuxSdjgJTL9UYPZlaC9r1e1f7HmSymBx6XiXi)uSPlofdRlXT(y0yGXUHIbQInDXPyqjKWamcfJVtXC53IWX0aX4kgo5OyupMn7MypMTdl0JIr(NwcVrwFX0zhzGumnqmWUFRmYT(IbT3zoymlkMmIalHmQWT(qLemj63sDiLIvqvSPloX8PpkLIf6rvkTeEJS(yUtsHiNzdifufB6Itffl0JQuAj8gz9LcYygQYZukglgRT1voDEbGRpQMOUyhsPBBzVRC68caxFunrDXEidlgZ2LEmsmYpfB6ItXW6sCRpgngySBOyGQytxCkgucjmaJqX47umjewqNRWPyAGyE6PXSiEVjMn7MypMTdl0JIr(NwcVrwFXSX48yU2JzrXKreyjKrfU1hQKGjr)wQdPuScQInDXjMp9rPuSqpQsPLWBK1x9PNYmibOzUNI1dzm3jPWeI8qgwmMTl9yKyKFk20fNIH1L4wFmAmWyNI5YVfHJPbIXvmCYrXiTBaUDWJj96neog0EN5GXSOyYicmM(IbmJTdEmWUFRmYT(kHmQWT(qLemj63sDiLIvqvSPloX8PpkLOFRmYT(QODdWTdEnP3qyMbjanZ9uPJ5ojfMqKhYWIXSDPhJeJ8tXMU4umSUe36JrJbg7umU9OyW0tTZo4X0xmAmcf5XSzNUyGD)wzKB9fJqVywumzebgJDXGirFGOsiJkCRpujbtI(TuhsPyfufB6ItmF6Jsj63kJCRVQqrEftp1oeZGeGM5EkiRiVYCNKctiYdzyXy2U0JrIr(PytxCkgwxIB9XOXaJDdfdufB6ItXGsiHbyekgFNI5YVfHJPbIbrI(arX0aXWcgMIbMCf5X47QhdAVZCWywumjDZjWysuKhJVtXasaAM7XOVoFEjKrfU1hQKGjr)wQdPuScQInDXjMp9rPAOeoPBEfWWuDXvKJygKa0m3tbzm3jPWeI8qgwmMTl9yKyKFk20fNIH1L4wFmAmBVEtm8(GhZIaAmfdS73kJCRVyq7DMdgJ8)LWeMuEmSom4PNGIzrXKre423qgv4wFOscMe9BPoKsXkOk20fNy(0hLIEjmHjLxBm4PNGQGexzIzqcqZCpLCBtM7KuycrEidlgJ8gigy3Vvg5wFXyOyanKU4eiZXGe7eyMtX47umagg5Xa7(TYi36lgafhJc4eogFNIbWGV7XqhiQeYOc36dvsWKOFl1HukwbvXMU4eZN(OuU9OQ3vr)wzKB9XmuLNPuag8DVIPNAhcsYbzqgZgqkOk20fNkGgsxCQk63kJCRVqgwmgyStXaMXQB9ftdeJgJu(IHXKDW3cfdm5eczh8yGD)wzKB9vczuHB9Hkjys0VL6qkfRGQytxCI5tFukKSRkygRU1hZDske5mdv5zkfRfYWIXWyVt(oHJrJjJ0fNIXC6ftgrGX4DmRmaqmWUFRmYT(IXqXqPF2ssiWsiJkCRpujbtI(TuhsPyfufB6ItmF6Jsj63kJCRVAF1mIyUtsHiNzOkptPO0pBjjeyboxbn1BmQUuq4eBSrPF2ssiWYtf6ctv0orE9LrMGn2O0pBjjeyXoKaNDDXPA6N1ZZVkib1eeBSrPF2ssiWckFlE3Gv9r(otiNn2O0pBjjeyHEjmHjLxBm4PNGyJnk9Zwscbwa46JQnqDPUZj2yJs)SLKqGLnQS0ryufa3hiBSrPF2ssiWIDihNfEJrvqdQDuDrCEidlgZ2R3edVp4XSiGgtXa7(TYi36lg0EN5GX4y7KLCum(U6X4ydoCchJgdAxXeymc1j4nMPyeDZb7nxm9ft77eoghBNSKJI5ApMfftgrGBFdzuHB9Hkjys0VL6qkfRGQytxCI5tFuQ(QzevfzVbayUtsHiNzOkptPshKXSbKcQInDXPIOFRmYT(Q9vZikKrfU1hQKGjr)wQdPuScQInDXjMp9rP6RMruvK9gaG5ojfICMHQ8mLkDSgZgqkk9ZwscbwEQqxyQI2jYRVmYeHmQWT(qLemj63sDiLIvqvSPloX8PpkvF1mIQIS3aam3jPqKZmuLNPuPdYGeufB6Itf6LWeMuETXGNEcQcsCLjMnGuu6NTKecSqVeMWKYRng80tqHmQWT(qLemj63sDiLIvzevnNEmF6JsH6mVAWpZjmZgqk2dvXMU4ur0Vvg5wF1(QzeXa7P0pBjjeybetkiGHPkucHiodS3voDEbWWeYvSt4qgv4wFOscMe9BPoKsXQNHXnUApfofYOc36dvsWKOFl1HukwLWeUxCf5mBaPyFcMGwsyc3lUI8qMqgwKfJr(NgjYobgdbLWmfJBpkgFNIrfEJJXqXOqvJRlovczuHB9Hsj685egLqCoZgqk2JZhb0y4ub0qclHBNIzQk63tpWqgwmgyStXi63kJCRVQBp7GhJkCRVy4gYJbj2jWmNqXSzNUyGD)wzKB9fZgJZJzrXKreym6bgdYBmHIX3PyWekZ9ySlgOk20fNkU9OQ3vr)wzKB9vczuHB9HGukwjuoVQc36RYnKZ8PpkLOFRmYT(QU9SdEidlgJ8tXMU4um(U6Xqi3EQtOy2St(oHJrA3aC7Ght61BiCmBmopMfftgrGXSiGgtXa7(TYi36lgdfdMuqMkHmQWT(qqkfRGQytxCI5tFuk0Ub42bVM0BiCDranMQI(TYi36J5ojfICMHQ8mLccQWnOuLo6zeILqvSPlove9BLrU1xfTBaUDWRj9gcZgBQWnOuLo6zeILqvSPlove9BLrU1xfGRpc5ytwIn2GQytxCQ42JQExf9BLrU1N8Oc36RG2na3o41KEdHlazoVIjWSWT(yNOBoyV5kODdWTdEnP3q4cygRU1hezaQInDXPIBpQ6Dv0Vvg5wFYJOBoyV5kODdWTdEnP3q4cMEQDi2Pc36RG2na3o41KEdHlazoVIjWSWT(yacIU5G9MRGZhvBGAsVHWfm9u7qYJOBoyV5kODdWTdEnP3q4cMEQDi2XASXg7DLtNxW5JQnqnP3qyigYOc36dbPuScTBaUDWRj9gcZSbKALbakI(TYi36Ra2BoguHB9vammvxCf5fXUIHtiwMsogypewzaGIDae(uEvOiHcsLCcdRmaqzV9kYXKkBbtQWHidqvSPlovq7gGBh8AsVHW1fb0yQk63kJCRVqgv4wFiiLIvyf00ZROefllZgqQvgaOi63kJCRVcyV5yacqvSPlovC7rvVRI(TYi36JLqvSPlove9BLrU1xnbtcf5v3EeKO0ir2PQBpIn2GQytxCQ42JQExf9BLrU1h7eDZb7nN8ihKbXqgv4wFiiLIvGK67RgFeZgqQvgaOi63kJCRVcyV5yyLbak48r1gOM0BiCbS3CmavXMU4uXThv9Uk63kJCRpwcvXMU4ur0Vvg5wF1emjuKxD7rqIsJezNQU9Oqgv4wFiiLIvpdJBmQ2avVXp6CMnGuqvSPlovC7rvVRI(TYi36JLqvSPlove9BLrU1xnbtcf5v3EeKO0ir2PQBpIHvgaOi63kJCRVcyV5czyXyyHghJ8JoFNjmZXKrumAmSGHPyGjxrEmIDfdNIbmJTdEmB)gg3yumnqmWOXp68yekYJX7yuOTbgJqtsSdEmIDfdNqLqgv4wFiiLIvagMQlUICMZiQUz34uvOi3o4PKJzdiLkCRVYZW4gJQnq1B8JoVqPrISBhCgaYCEftIDfdNQU9i5rfU1x5zyCJr1gO6n(rNxO0ir2PkMEQDiwY6zG97TxroMuzROeIZrv7QaCd(UZa7xzaGYE7vKJjv2sojKrfU1hcsPyvgrvZPhZeaaj86PpkfCUcAQ3yuDPGWjMnGuqvSPlovC7rvVRI(TYi36JDIU5G9MtEyTqgv4wFiiLIvzevnNEmF6JsrVeMWKYRng80tqmBaPGQytxCQ42JQExf9BLrU1hltbvXMU4uHEjmHjLxBm4PNGQGexzIbOk20fNkU9OQ3vr)wzKB9XoOk20fNk0lHjmP8AJbp9eufK4ktYdRfYOc36dbPuSkJOQ50J5tFuk4CMs2Rnqvri7zC1T(y2asbvXMU4uXThv9Uk63kJCRp2LcQInDXPsF1mIQIS3aaHmQWT(qqkfRYiQAo9y(0hL6PcDHPkANiV(YitWSbKcQInDXPIBpQ6Dv0Vvg5wFSmfRfYWIXiVbIjJSdEmAmiNWTbgtFYtgrXyo9yogLVrzcftgrXW4WKccyykg5hHqepMo7idKIPbIb29BLrU1xjgwNVt4ngIyoMeS1yZTTpumzKDWJHXHjfeWWumYpcHiEmBmFpgy3Vvg5wFX0hNPymGyK3haHpLhdSvKqbPymum0PlobgJEGXOXKrkCkMn9TLhZIIH3ipMgkHJX3PyaZy1T(IPbIX3Pyam47EjgySBOyuqqumAmONY5Xav5zkgVJX3PyeDZb7nxmnqmmomPGagMIr(rieXJzZoDXa22bpgF3qXiuUiZv36lMfj0mIIX8ymum5dtkh5MigVJrrO8JIX3vpgZJzJX5XSOyYicmMecdqcNZum9fJOBoyV5kHmQWT(qqkfRYiQAo9y(0hLcetkiGHPkucHioZgqkOk20fNkU9OQ3vr)wzKB9XUuqvSPlov6RMruvK9gaGbiSYaaf7ai8P8QqrcfKkixfYMALbak2bq4t5vHIekivEAAvKRczzJn2l6dmBEXoacFkVkuKqbj2ydQInDXPIOFRmYT(Q9vZiIn2GQytxCQ42JQExf9BLrU1h7SZjCsZvNaRag8DVIPNAhIXNXhcIU5G9MdsYbzqeIHmSilgdSOnXi1zEmYB4N5eog6CmtmhdM4gHIPVyq7kMaJXC6fdSzCXyhqJFQB9fJVREmgkMR9yyI8yq5KKg7eyjMy2gucxfekgFNIjbtqToJIHBhfZMD6IbiFc36t5Lqgv4wFiiLIvzevnNEmF6JsH6mVAWpZjmZgqkiavXMU4uXThv9Uk63kJCRp2Ls(GSTfcqvSPlov6RMruvK9gaGDqgezJniWEhBNSKxKRyOcQZ8Qb)mNWm4y7KL8ICLmsxCIbhBNSKxKRi6Md2BUcMEQDi2yJ9o2ozjVKUIHkOoZRg8ZCcZGJTtwYlPRKr6Itm4y7KL8s6kIU5G9MRGPNAhcIqKbiWEk9ZwscbwaXKccyyQcLqiIZgBIU5G9MRaIjfeWWufkHqeVkFSEgRTjRjVwW0tTdXowdIHmSymWaBWHt4yK6mpg5n8ZCchdPyotXSX89yK3haHpLhdSvKqbPyACmB2PlgZJzJIIjbtcf5Lqgv4wFiiLIvc9eeVUYaamF6JsH6mVAWpZT(y2asXErFGzZl2bq4t5vHIekiXGBpILSgBSTYaaf7ai8P8QqrcfKkixfYMALbak2bq4t5vHIekivEAAvKRczdzyXyK3o9qX47QhdyhZ1Eml6iaZJb29BLrU1xmO9oZbJHXCg5XSOyYicmMo7idKIPbIb29BLrU1xmQhdQFumjTDEjKrfU1hcsPyvgrvZPhZN(Ou2He4SRlovt)SEE(vbjOMGy2asrPF2ssiWcCUcAQ3yuDPGWjgGQytxCQ42JQExf9BLrU1h7sbvXMU4uPVAgrvr2BaGqgv4wFiiLIvzevnNEmF6JsbW1hvBG6sDNtmBaPO0pBjjeyboxbn1BmQUuq4edqvSPlovC7rvVRI(TYi36JDPGQytxCQ0xnJOQi7naqiJkCRpeKsXQmIQMtpMp9rP2OYshHrvaCFGmBaPO0pBjjeyboxbn1BmQUuq4edqvSPlovC7rvVRI(TYi36JDPGQytxCQ0xnJOQi7naqiJkCRpeKsXQmIQMtpMp9rPSd54SWBmQcAqTJQlIZz2asrPF2ssiWcCUcAQ3yuDPGWjgGQytxCQ42JQExf9BLrU1h7sbvXMU4uPVAgrvr2BaGqgv4wFiiLIvzevnNEmF6JsHY3I3nyvFKVZeYz2asrPF2ssiWcCUcAQ3yuDPGWjgGQytxCQ42JQExf9BLrU1h7sbvXMU4uPVAgrvr2BaGqgv4wFiiLIvzevnNEiMnGuqvSPlovC7rvVRI(TYi36JDPGQytxCQ0xnJOQi7naqidlgdJhIIHfWnYJbwnungVJXXgC4eog5fSH4mfJ8wycovczuHB9HGukwbGBKxVgQYSbKcNpcOXWPcCSH4mvnHj4edRmaqr0Vvg5wFfWEZXaeGQytxCQ42JQExf9BLrU1h7eDZb7nhBSbvXMU4uXThv9Uk63kJCRpwcvXMU4ur0Vvg5wF1emjuKxD7rqIsJezNQU9iigYWIXiVqEm(ofdJZqclHBNIzkgy3VNEGXSYaaXKtyoM8Xjekgr)wzKB9fJHIb19vczuHB9HGukwj685egLqCoZgqkC(iGgdNkGgsyjC7umtvr)E6bYGOBoyV5kRmaqf0qclHBNIzQk63tpWcMEQDiwQc36RaGBKVAUxekYRU9igwzaGcOHewc3ofZuv0VNEGvfl0JkG9MJb2VYaafqdjSeUDkMPQOFp9al5egGaufB6Itf3Eu17QOFRmYT(GKkCRVcaUr(Q5ErOiV62JyNOBoyV5kRmaqf0qclHBNIzQk63tpWcygRU1hBSbvXMU4uXThv9Uk63kJCRpwYAqmKrfU1hcsPyLIf6rvkTeEJS(y2asHZhb0y4ub0qclHBNIzQk63tpqgeDZb7nxzLbaQGgsyjC7umtvr)E6bwW0tTdXsknsKDQ62JGKkCRVcaUr(Q5ErOiV62JyyLbakGgsyjC7umtvr)E6bwvSqpQa2Bogy)kdauanKWs42PyMQI(90dSKtyacqvSPlovC7rvVRI(TYi36dsuAKi7u1Thbjv4wFfaCJ8vZ9IqrE1ThXor3CWEZvwzaGkOHewc3ofZuv0VNEGfWmwDRp2ydQInDXPIBpQ6Dv0Vvg5wFSK1yG9UYPZl48r1gOM0BimedzuHB9HGukwbGBKVAUZSbKcNpcOXWPcOHewc3ofZuv0VNEGmi6Md2BUYkdaubnKWs42PyMQI(90dSGPNAhILcf5v3EedRmaqb0qclHBNIzQk63tpWkaUrEbS3CmW(vgaOaAiHLWTtXmvf97PhyjNWaeGQytxCQ42JQExf9BLrU1hKekYRU9i2j6Md2BUYkdaubnKWs42PyMQI(90dSaMXQB9XgBqvSPlovC7rvVRI(TYi36JLSgedzuHB9HGukwbGBKxVgQYSbKcNpcOXWPcOHewc3ofZuv0VNEGmi6Md2BUYkdaubnKWs42PyMQI(90dSGjfKjgwzaGcOHewc3ofZuv0VNEGvaCJ8cyV5yG9Rmaqb0qclHBNIzQk63tpWsoHbiavXMU4uXThv9Uk63kJCRp2j6Md2BUYkdaubnKWs42PyMQI(90dSaMXQB9XgBqvSPlovC7rvVRI(TYi36JLSgedzuHB9HGukwjuoVQc36RYnKZ8PpkLOFRmYT(Qj7kIy2asbvXMU4uXThv9Uk63kJCRpwMcYyJnOk20fNkU9OQ3vr)wzKB9XsOk20fNkI(TYi36RMGjHI8QBpIbr3CWEZve9BLrU1xbtp1oelHQytxCQi63kJCRVAcMekYRU9Oqgv4wFiiLIv48r1gOM0BimZgqQvgaOGZhvBGAsVHWfWEZXa7xzaGcGHjK34xjNWaeGQytxCQ42JQExf9BLrU1h7sTYaafC(OAdut6neUaMXQB9XaufB6Itf3Eu17QOFRmYT(yNkCRVcGHP6IRiVaK58kMe7kgovD7rSXgufB6Itf3Eu17QOFRmYT(yhGbF3Ry6P2HGyidlgt61npgffZtpMIHfmmfdm5kYrXOOysAeYwCkgGghdS73kJCRVsms5LJvHhtN9yAGy8DkgaSkCRpLhJOFj9rNhtdeJVtXC53IWX0aXWcgMIbMCf5Oy8D1JzJX5XCQNXkNZumysSRy4umGzSDWJX3PyGD)wzKB9ftYUIOywKqZikMKU52bpg9yY3TdEmjkYJX3vpMngNhZ1EmWX65XOxmuAowJHfmmfdm5kYJbmJTdEmWUFRmYT(kHmQWT(qqkfRGQytxCI5mIQnaqfUamLCmNruDZUXPQqrUDWtjhZN(OuagMQlUI8As3C7GZmuLNPuQWT(kagMQlUI8IyxXWjufaRc36t5qccqvSPlovC7rvVRI(TYi36dsQWT(kODdWTdEnP3q4cqMZRycmlCRVTfQInDXPcA3aC7Gxt6neUUiGgtvr)wzKB9brgFr3CWEZvammvxCf5fWmwDRp5rowk6Md2BUcGHP6IRiV800QIDfdNqqcQInDXPsdLWjDZRagMQlUICeJVOBoyV5kagMQlUI8cygRU1N8aHvgaOi63kJCRVcygRU1hJVOBoyV5kagMQlUI8cygRU1hez8z8LJbOk20fNkU9OQ3vr)wzKB9Xsad(UxX0tTdfYWIXi)uSPlofJVREmI(CCZrXKE7nDwAXWcC9rOyYifofJ3XqhkJPymhfJyxXWjumkMIjPBobgdqJJb29BLrU1xjgw3XzkMmIIj92B6S0IHf46JqX0zhzGumnqmWUFRmYT(IzZoDXaK58ye7kgoHIrOxmlkME5QDeymGzSDWJX3Pyoknpgy3Vvg5wFLqgv4wFiiLIvqvSPloX8PpkvYEtNLwnPBUDWz2asPc3Gsv6ONriwcvXMU4ur0Vvg5wFvaU(iKJnzjMHQ8mLcQInDXPIBpQ6Dv0Vvg5wFqALbakI(TYi36RaMXQB9jpSglvHB9vs2B6S0QaC9rOcqMZRysSRy4u1Thbjr3CWEZvs2B6S0QaC9rOcygRU1N8Oc36RG2na3o41KEdHlazoVIjWSWT(2wOk20fNkODdWTdEnP3q46IaAmvf9BLrU1hdqvSPlovC7rvVRI(TYi36JLag8DVIPNAhIn2W5JaAmCQGYxvw7GJQloHq2bNn2C7rSK1czyXyyS3PlMmYo4XWcC9rihBYsXyxmWUFRmYT(yogKcLIrrX80JPye7kgoHIrrXK0iKT4umanogy3Vvg5wFXSX89o7Xi0Ke7GxczuHB9HGukwbvXMU4eZN(Ouj7nDwA1KU52bNzdiLkCdkvPJEgHyxkOk20fNkI(TYi36RcW1hHCSjlXmuLNPuqvSPlovC7rvVRI(TYi36JLQWT(kj7nDwAvaU(iubiZ5vmj2vmCQ62JKhv4wFf0Ub42bVM0BiCbiZ5vmbMfU132cvXMU4ubTBaUDWRj9gcxxeqJPQOFRmYT(yaQInDXPIBpQ6Dv0Vvg5wFSeWGV7vm9u7qSXgoFeqJHtfu(QYAhCuDXjeYo4SXMBpILSwiJkCRpeKsXkHY5vv4wFvUHCMp9rPWDsnzxreZihBcpLCmBaPwzaGcoFuTbQj9gcxYjmavXMU4uXThv9Uk63kJCRp2bzHmSymBhiJ5mYJX3PyGQytxCkgFx9ye954MJIHfmmfdm5kYJjJu4umEhdDOmMIXCumIDfdNqXOykgLJ6ys6MtGXa04y2g5JIPbIj96neUeYOc36dbPuScQInDXjMZiQ2aav4cWuYXCgr1n7gNQcf52bpLCmF6JsbyyQU4kYRjDZTdoZDske5mdv5zkLOBoyV5k48r1gOM0BiCbtp1oelvHB9vammvxCf5fGmNxXKyxXWPQBpsEuHB9vq7gGBh8AsVHWfGmNxXeyw4wFBleGQytxCQG2na3o41KEdHRlcOXuv0Vvg5wFmi6Md2BUcA3aC7Gxt6neUGPNAhILIU5G9MRGZhvBGAsVHWfm9u7qqKbr3CWEZvW5JQnqnP3q4cMEQDiwcyW39kMEQDiMnGuShQInDXPcGHP6IRiVM0n3o4m4kNoVGZhvBGAsVHWmSYaafC(OAdut6neUa2BUqgwmgg7D6Iz7PyqHIC7GhdlW1hfJKJnzjMJHfmmfdm5kYrXG27mhmMfftgrGX4DmWPJWQtXS9ApgjhtQSOy0dmgVJHsZPdmgyYvKt4y2(vKt4siJkCRpeKsXkadt1fxroZzevBaGkCbyk5yoJO6MDJtvHIC7GNsoMnGuShQInDXPcGHP6IRiVM0n3o4mavXMU4uXThv9Uk63kJCRp2bzmOc3Gsv6ONri2LcQInDXPYUIbRcf5vaU(iKJnzjgypGHjKRyNWfv4guIb2VYaaL92RihtQSLCcdqyLbak7K62bVMtk5eguHB9va46Jqo2KLkuAKi7uftp1oelHScRXgBIDfdNqvaSkCRpLZUuPdIHmSymmUm2o4XWcgMqUIDcZCmSGHPyGjxrokgftXKreymi7zCfZzkgVJbmJTdEmWUFRmYT(kXiVqhHvoNjMJX3jMIrXumzebgJ3XaNocRofZ2R9yKCmPYIIzZoDXiWMJIzJX5XCThZIIzJICcmg9aJzJ57XatUICchZ2VICcZCm(oXumO9oZbJzrXGsWKcgtN9y8oMNANR2fJVtXatUICchZ2VICchZkdauczuHB9HGukwbyyQU4kYzoJOAdauHlatjhZzev3SBCQkuKBh8uYXSbKcWWeYvSt4IkCdkXGyxXWje7sjhdShQInDXPcGHP6IRiVM0n3o4mab2Rc36RayyAPCEHsJez3o4mWEv4wFLeMW9IRiVyxfGBW3DgwzaGYoPUDWR5KsoHn2uHB9vammTuoVqPrISBhCgy)kdau2BVICmPYwYjSXMkCRVsct4EXvKxSRcWn47odRmaqzNu3o41CsjNWa7xzaGYE7vKJjv2sobIHmSymBh02aJrOjj2bpgwWWumWKRipgXUIHtOy2SBCkgXUEhXTdEms7gGBh8ysVEdHdzuHB9HGukwbyyQU4kYzoJO6MDJtvHIC7GNsoMnGuQWT(kODdWTdEnP3q4cLgjYUDWzaiZ5vmj2vmCQ62JyPkCRVcA3aC7Gxt6neU4Mq2kMaZc36JHvgaOS3Ef5ysLTa2BogC7rStoilKrfU1hcsPyLq58QkCRVk3qoZN(OuixpqfdwXTRU1hZgqkOk20fNkU9OQ3vr)wzKB9XoiJHvgaOGZhvBGAsVHWfWEZfYOc36dbPuScjASypKjKrfU1hQOc3Gsvx505OuCdQDWRR(Ty2asPc3Gsv6ONri2jhdRmaqr0Vvg5wFfWEZXaeGQytxCQ42JQExf9BLrU1h7eDZb7nxHBqTdED1VvbmJv36Jn2GQytxCQ42JQExf9BLrU1hltbzqmKrfU1hQOc3Gsvx505iiLIvpYPgZSbKcQInDXPIBpQ6Dv0Vvg5wFSmfKXgBqq0nhS3CLh5uJlGzS6wFSeQInDXPIBpQ6Dv0Vvg5wFmWEx505fC(OAdut6negISXMRC68coFuTbQj9gcZWkdauW5JQnqnP3q4soHbOk20fNkU9OQ3vr)wzKB9Xov4wFLh5uJlIU5G9MJn2am47Eftp1oelHQytxCQ42JQExf9BLrU1xiJkCRpurfUbLQUYPZrqkfRaXk8(q1fMuFNzdiLRC68IYP0qowrBFuufiJzIbiSYaafr)wzKB9va7nhdSFLbak7TxroMuzl5eigYeYOc36dve9BLrU1xv0nhS3COujTB9fYOc36dve9BLrU1xv0nhS3CiiLIvlE3GvGmMPqgv4wFOIOFRmYT(QIU5G9MdbPuSAryeHL1o4mBaPwzaGIOFRmYT(k5Kqgv4wFOIOFRmYT(QIU5G9MdbPuScWW0I3nyiJkCRpur0Vvg5wFvr3CWEZHGukwPNGqow5vHY5HmQWT(qfr)wzKB9vfDZb7nhcsPyLBpQUrXjmBaPW5JaAmCQ40lPXkVUrXjmSYaafkTDnJCRVsojKrfU1hQi63kJCRVQOBoyV5qqkfRYiQAo9yMaaiHxp9rPGZvqt9gJQlfeofYOc36dve9BLrU1xv0nhS3CiiLIvzevnNEmF6JszhsGZUU4un9Z655xfKGAckKrfU1hQi63kJCRVQOBoyV5qqkfRYiQAo9y(0hLcGRpQ2a1L6oNczuHB9HkI(TYi36Rk6Md2BoeKsXQmIQMtpMp9rP2OYshHrvaCFGHmQWT(qfr)wzKB9vfDZb7nhcsPyvgrvZPhZN(Ou2HCCw4ngvbnO2r1fX5HmQWT(qfr)wzKB9vfDZb7nhcsPyvgrvZPhZN(OuO8T4Ddw1h57mH8qgv4wFOIOFRmYT(QIU5G9MdbPuSkJOQ50dfYeYOc36dve9BLrU1xnzxrukUbF3rvgZzq4p6CMnGuRmaqr0Vvg5wFfWEZfYWIXi)rU9uNIzV3edVp4Xa7(TYi36lMngNhdxrEm(UEYIIX7yKYxmmMSd(wOyGjNqi7GhJ3XasoHF2rXS3BIHfmmfdm5kYrXG27mhmMfftgrGLqgv4wFOIOFRmYT(Qj7kIGukwbvXMU4eZzevBaGkCbyk5yoJO6MDJtvHIC7GNsoMp9rPO0C6ajWQOFRmYT(Qy6P2HyUtsHiNzOkptPwzaGIOFRmYT(ky6P2HG0kdaue9BLrU1xbmJv36BBHGOBoyV5kI(TYi36RGPNAhILRmaqr0Vvg5wFfm9u7qqKzdiLOpWS5f7ai8P8QqrcfKczyXy2oqqum(ofdygRU1xmnqm(ofJu(IHXKDW3cfdm5eczh8yGD)wzKB9fJ3X47um0bgtdeJVtXiYymDEmWUFRmYT(IXaIX3PyekYJztN5GXi6xcNCkgWm2o4X47gkgy3Vvg5wFLqgv4wFOIOFRmYT(Qj7kIGukwbvXMU4eZzevBaGkCbyk5yoJO6MDJtvHIC7GNsoMp9rPO0C6ajWQOFRmYT(Qy6P2HyUtsPGGmdv5zkfufB6ItfKSRkygRU1hZgqkrFGzZl2bq4t5vHIekiXaewzaGckFvzTdoQU4eczh8kMuqMk5e2ydQInDXPcLMthibwf9BLrU1xftp1oe7KRWABlCby5PPTTqyLbakO8vL1o4O6ItiKDWlpnTkYvHSYZkdauq5RkRDWr1fNqi7GxqUkKfIqmKrfU1hQi63kJCRVAYUIiiLIvlfETbQo2eYIy2asTYaafr)wzKB9va7nxiJkCRpur0Vvg5wF1KDfrqkfR4gu7Gxx9BXSbKsfUbLQ0rpJqStogwzaGIOFRmYT(kG9MlKHfJHX289o7XiVpacFkpgyRiHcsmhdJ5mYJjJOyybdtXatUICumB2PlgFNykMn9TLhZlFI9yeyZrXOhymB2PlgwWWeYB8lgdfdyV5kHmQWT(qfr)wzKB9vt2vebPuScWWuDXvKZCgr1gaOcxaMsoMZiQUz34uvOi3o4PKJzdif7f9bMnVyhaHpLxfksOGedIDfdNqSlLCmSYaafr)wzKB9vYjmW(vgaOayyc5n(vYjmW(vgaOS3Ef5ysLTKtyyV9kYXKkBfLqCoQAxfGBW3DiTYaaLDsD7GxZjLCcltxidlgdJT57XiVpacFkpgyRiHcsmhdlyykgyYvKhtgrXG27mhmMffJccAU1NY5mfJOpKJv7iWyqDm(U6XyEmgkMR9ywumzebgt(4ecfJ8(ai8P8yGTIekifJHIrxD2JX7yO0smmftJJX3jmfJIPyEnMIX31lg66m89yybdtXatUICumEhdLMthymY7dGWNYJb2ksOGumEhJVtXqhymnqmWUFRmYT(kHmQWT(qfr)wzKB9vt2vebPuScQInDXjMZiQ2aav4cWuYXCgr1n7gNQcf52bpLCmF6JsrPLqcNaRagMQlUICeZDske5mdv5zkLkCRVcGHP6IRiVi2vmCcvbWQWT(uoKGaufB6ItfknNoqcSk63kJCRVkMEQDi5zLbak2bq4t5vHIekivaZy1T(GiJVOBoyV5kagMQlUI8cygRU1hZgqkrFGzZl2bq4t5vHIekifYOc36dve9BLrU1xnzxreKsXkOk20fNyoJOAdauHlatjhZzev3SBCQkuKBh8uYX8Ppk1reibwbmmvxCf5iM7KuiYzgQYZukbzCiavXMU4uHsZPdKaRI(TYi36RIPNAhIXhcRmaqXoacFkVkuKqbPcygRU1N8axawEAAqeImBaPe9bMnVyhaHpLxfksOGuiJkCRpur0Vvg5wF1KDfrqkfRammvxCf5mNruTbaQWfGPKJ5mIQB2novfkYTdEk5y2asj6dmBEXoacFkVkuKqbjge7kgoHyxk5yacqvSPlovO0siHtGvadt1fxroIDPGQytxCQCebsGvadt1fxroIn2GQytxCQqP50bsGvr)wzKB9vX0tTdXYuRmaqXoacFkVkuKqbPcygRU1hBSTYaaf7ai8P8QqrcfKkixfYYY0XgBRmaqXoacFkVkuKqbPcMEQDiwcxawEAASXMOBoyV5kODdWTdEnP3q4cMuqMyqfUbLQ0rpJqSlfufB6Itfr)wzKB9vr7gGBh8AsVHWmiAO0PNxod(UxbucImSYaafr)wzKB9vYjmab2VYaafadtiVXVsoHn2wzaGIDae(uEvOiHcsfm9u7qSeYkSgezG9RmaqzV9kYXKkBjNWWE7vKJjv2kkH4Cu1Uka3GV7qALbak7K62bVMtk5ewMUqgv4wFOIOFRmYT(Qj7kIGukwjuoVQc36RYnKZ8PpkLkCdkvDLtNJczuHB9HkI(TYi36RMSRicsPyLOFRmYT(yoJOAdauHlatjhZzev3SBCQkuKBh8uYXSbKALbakI(TYi36Ra2BogGQytxCQ42JQExf9BLrU1hltbzmab2JZhb0y4ub0qclHBNIzQk63tpq2yBLbakGgsyjC7umtvr)E6bwYjSX2kdauanKWs42PyMQI(90dScGBKxYjm4kNoVGZhvBGAsVHWmi6Md2BUYkdaubnKWs42PyMQI(90dSGjfKjiYaeypoFeqJHtf4ydXzQActWj2ydKwzaGcCSH4mvnHj4ujNargGa7fnu60ZlhjWnVXGSXMOBoyV5kGK67RgFubtp1oeBSTYaafqs99vJpQKtGidqqfU1x5ro14IDvaUbF3zqfU1x5ro14IDvaUbF3Ry6P2HyzkOk20fNkI(TYi36RkuKxX0tTdXgBQWT(kirJf7fknsKD7GZGkCRVcs0yXEHsJezNQy6P2HyjufB6Itfr)wzKB9vfkYRy6P2HyJnv4wFfadtlLZluAKi72bNbv4wFfadtlLZluAKi7uftp1oelHQytxCQi63kJCRVQqrEftp1oeBSPc36RKWeUxCf5fknsKD7GZGkCRVsct4EXvKxO0ir2PkMEQDiwcvXMU4ur0Vvg5wFvHI8kMEQDi2ytfU1xbGRpc5ytwQqPrISBhCguHB9va46Jqo2KLkuAKi7uftp1oelHQytxCQi63kJCRVQqrEftp1oeedzyXyyD(oHJr0nhS3COy8D1JbT3zoymlkMmIaJzJ57Xa7(TYi36lg0EN5GX0hNPywumzebgZgZ3JrVyuHNvEmWUFRmYT(IrOipg9aJ5ApMnMVhJgJu(IHXKDW3cfdm5eczh8ysWTOeYOc36dve9BLrU1xnzxreKsXkHY5vv4wFvUHCMp9rPe9BLrU1xv0nhS3CiMnGuRmaqr0Vvg5wFfm9u7qSBBYgBIU5G9MRi63kJCRVcMEQDiwYAHmQWT(qfr)wzKB9vt2vebPuScGRpc5ytwIzdifewzaGYE7vKJjv2soHbv4guQsh9mcXUuqvSPlove9BLrU1xfGRpc5ytwcISXgewzaGcGHjK34xjNWGkCdkvPJEgHyxkOk20fNkI(TYi36RcW1hHCSjljp48rangovammH8g)GyiJkCRpur0Vvg5wF1KDfrqkfRsyc3lUICMnGuRmaqbLVQS2bhvxCcHSdEftkitLCcdRmaqbLVQS2bhvxCcHSdEftkitfm9u7qStOiV62JczuHB9HkI(TYi36RMSRicsPyvct4EXvKZSbKALbakagMqEJFLCsiJkCRpur0Vvg5wF1KDfrqkfRsyc3lUICMnGuRmaqjHjCl4k6vYjmSYaaLeMWTGROxbtp1oe7ekYRU9igGWkdaue9BLrU1xbtp1oe7ekYRU9i2yBLbakI(TYi36Ra2BoiYGkCdkvPJEgHyjufB6Itfr)wzKB9vb46Jqo2KLczuHB9HkI(TYi36RMSRicsPyvct4EXvKZSbKALbak7TxroMuzl5egwzaGIOFRmYT(k5Kqgv4wFOIOFRmYT(Qj7kIGukwLWeUxCf5mBaPsWe0kCbyrUcs0yXodRmaqzNu3o41CsjNWGkCdkvPJEgHyjufB6Itfr)wzKB9vb46Jqo2KLyyLbakI(TYi36RKtczyXyy8q2bpgPDdWTdEmPxVHWXaMX2bpgy3Vvg5wFX4Dmyc5nMIHfmmfdm5kYJrpWysV9MolTyybU(Oye7kgoHIrOxmlkMfDeGjmLZCmRShtgLvoNPy6JZum9fZ21Y)siJkCRpur0Vvg5wF1KDfrqkfRq7gGBh8AsVHWmBaPwzaGIOFRmYT(k5egyVkCRVcGHP6IRiVi2vmCcXGkCdkvPJEgHyxkOk20fNkI(TYi36RI2na3o41KEdHzqfU1xjzVPZsRcW1hHkazoVIjXUIHtv3Ee7aYCEftGzHB9XSDoHX5eVAaPuHB9vammvxCf5fXUIHtOuQWT(kagMQlUI8YttRk2vmCcfYOc36dve9BLrU1xnzxreKsXQK9MolTkaxFeIzdi1kdaue9BLrU1xjNWGJvOeV62Jy5kdaue9BLrU1xbtp1oedqacQWT(kagMQlUI8IyxXWjelLJbx505LeMWTGROhdQWnOuLo6zekLCqKn2yVRC68sct4wWv0Jn2uHBqPkD0Zie7KdImSYaaLDsD7GxZjLCcK2BVICmPYwrjeNJQ2vb4g8DNLPlKrfU1hQi63kJCRVAYUIiiLIvaC9rihBYsmBaPwzaGIOFRmYT(kG9MJbr3CWEZve9BLrU1xbtp1oelfkYRU9iguHBqPkD0Zie7sbvXMU4ur0Vvg5wFvaU(iKJnzPqgv4wFOIOFRmYT(Qj7kIGukwbyyAPCoZgqQvgaOi63kJCRVcyV5yq0nhS3Cfr)wzKB9vW0tTdXsHI8QBpIb2l6dmBEbGRpQQcbMCRVqgv4wFOIOFRmYT(Qj7kIGukwHenwSZSbKALbakI(TYi36RGPNAhIDcf5v3EedRmaqr0Vvg5wFLCcBSTYaafr)wzKB9va7nhdIU5G9MRi63kJCRVcMEQDiwkuKxD7rHmQWT(qfr)wzKB9vt2vebPuSIBqTdED1VfZgqQvgaOi63kJCRVcMEQDiwcxawEAAmOc3Gsv6ONri2jxiJkCRpur0Vvg5wF1KDfrqkfRaXk8(q1fMuFNzdi1kdaue9BLrU1xbtp1oelHlalpnngwzaGIOFRmYT(k5KqMqgwmMThXtiCmqvSPlofJVREmI(C1oum(ofJk8SYJHqU9uNaJXThfJVREm(ofZrP5Xa7(TYi36lMngNhZIIbtkitLqgv4wFOIOFRmYT(QU9SdEkOk20fNy(0hLs0Vvg5wFvmPGmvD7rmdv5zkLOBoyV5kI(TYi36RGPNAhABP0siHtGvzTdKBh8kMaZc36lKHfJbg7umcf5X42JIPbIX3PyqjeNhJVREmBmopMfftcMekYJXoVJb29BLrU1xjKrfU1hQi63kJCRVQBp7GdPuScQInDXjMp9rPe9BLrU1xnbtcf5v3EeZqvEMsbbv4wFfadtlLZlcf5v3E02YErFGzZlaC9rvviWKB9bjv4wFfKOXI9IqrE1ThbjrFGzZlaC9rvviWKB9bXTfcQWnOuLo6zeILqvSPlove9BLrU1xfGRpc5ytwcIqsfU1xbGRpc5ytwQiuKxD7rBleuHBqPkD0Zie7sbvXMU4ur0Vvg5wFvaU(iKJnzjikpqvSPlove9BLrU1xvOiVIPNAhkKrfU1hQi63kJCRVQBp7GdPuScQInDXjMp9rPe9BLrU1x1ThXmuLNPuqvSPlove9BLrU1xftkitv3EuidlgdJJ4ktXa7(TYi36lgGghJc4eogwWWeYvSt4yYhNqOyGQytxCQayyc5k2jCv0Vvg5wFXyOyqKxczuHB9HkI(TYi36R62Zo4qkfRGQytxCI5tFukr)wzKB9vD7rm3jPEAAmdv5zkfGHjKRyNWfm9u7qmBaPCLtNxammHCf7eMb2dvXMU4ubWWeYvSt4QOFRmYT(czyXyyCexzkgy3Vvg5wFXa04y2gkOPNhJuIILngdigZJzJX5Xi6hftdaeJOBoyV5Ib19vczuHB9HkI(TYi36R62Zo4qkfRGQytxCI5tFukr)wzKB9vD7rm3jPEAAmdv5zkLOBoyV5kyf00ZROeflBbtp1oeZgqkrdLo98ISmHn9yq0nhS3CfScA65vuIILTGPNAhsEKdYyjufB6Itfr)wzKB9vD7rHmSymmoIRmfdS73kJCRVyaACmmos99vJpQeYOc36dve9BLrU1x1TNDWHukwbvXMU4eZN(OuI(TYi36R62JyUts900ygQYZukr3CWEZvaj13xn(OcMEQDiMnGuIgkD65LJe4M3yqgeDZb7nxbKuFF14Jky6P2HKh5GmwcvXMU4ur0Vvg5wFv3EuidlgdJJ4ktXa7(TYi36lgGghJVtXi)FjmHjLhdRddE6jOywzaGymGy8DkMeUYeHJXqXKr2bpgFx9yCSDYsEjKrfU1hQi63kJCRVQBp7GdPuScQInDXjMp9rPe9BLrU1x1ThXCNK6PPXmuLNPuqvSPlovOxctys51gdE6jOkiXvMKhii6Md2BUc9syctkV2yWtpbvaZy1T(Khr3CWEZvOxctys51gdE6jOcMEQDiiUTSx0nhS3Cf6LWeMuETXGNEcQGjfKjMnGuu6NTKecSqVeMWKYRng80tqHmSymmoIRmfdS73kJCRVyaACmYlCf0uVXOyGPccNyoM8XjekgZJztN5GXSOyajUYebgdVp4eogFxVyshKfdIe9bIkHmQWT(qfr)wzKB9vD7zhCiLIvqvSPloX8PpkLOFRmYT(QU9iM7KupnnMHQ8mLs0nhS3Cf4Cf0uVXO6sbHtv5J1ZAPlDBZcMEQDiMnGuu6NTKecSaNRGM6ngvxkiCIbr3CWEZvGZvqt9gJQlfeovLpwpRLU0Tnly6P2HKN0bzSeQInDXPIOFRmYT(QU9OqgwmgghXvMIb29BLrU1xm5ZnEmBJo9IHslXWekgdigZ3cftoPeYOc36dve9BLrU1x1TNDWHukwbvXMU4eZN(OuI(TYi36R62JyUts900ygQYZuQvgaOGZhvBGAsVHWfm9u7qmBaPCLtNxW5JQnqnP3qygwzaGIOFRmYT(kG9MlKHfJHXrCLPyGD)wzKB9fdqJJrVyO0CSgZ2iFumnqmPxVHWXyaX47umBJ8rX0aXKE9gchZMoZbJr0pkMgaigr3CWEZfJ6XWjf5XWAXGirFGOyweqJPyGD)wzKB9fZMoZblHmQWT(qfr)wzKB9vD7zhCiLIvqvSPloX8PpkLOFRmYT(QU9iM7KupnnMHQ8mLs0nhS3CfC(OAdut6neUGPNAhcsRmaqbNpQ2a1KEdHlGzS6wFmBaPCLtNxW5JQnqnP3qygwzaGIOFRmYT(kG9MJbr3CWEZvW5JQnqnP3q4cMEQDiiXASeQInDXPIOFRmYT(QU9OqgwmgghXvMIb29BLrU1xmgqmmodjSeUDkMPyGD)E6bgZMoZbJ5ApMffdMuqMIbOXXyEmmrEjKrfU1hQi63kJCRVQBp7GdPuScQInDXjMp9rPe9BLrU1x1ThXCNK6PPXmuLNPuIU5G9MRSYaavqdjSeUDkMPQOFp9aly6P2Hy2asHZhb0y4ub0qclHBNIzQk63tpqgwzaGcOHewc3ofZuv0VNEGfWEZfYWIXSnudmg5pu6CeJgdJJ4ktXa7(TYi36lgGghJccgdkr3COyAGyKVyACmVgtXOGGOy8D1JzJX5XWvKhdVp4eogFxVyKJ1IbrI(arLyGXoHOyGQ8mHIrX0TLhZrccHuSXzkMoXTNYJXUyuopgHIiujKrfU1hQi63kJCRVQBp7GdPuScQInDXjMp9rPe9BLrU1x1ThXCNK6PPXmuLNPuy1aReu68IccIk2XSbKcRgyLGsNxuqquHsZqoIbSAGvckDErbbrfrNpNDPKpgWQbwjO05ffeevaZy1T(yNCSwidlgZ2qnWyK)qPZrmAmBhFJYekMmIIb29BLrU1xmBmFpgOz(ryDzCZzkgSAGXqqPZrmhtdLWydKIrpMIbK4ktOy4gYjWy0vdLIX7yEQSumOmMIX8yGtokMmIaJzNWujKrfU1hQi63kJCRVQBp7GdPuScQInDXjMp9rPe9BLrU1x1ThXmuLNPuy1aReu68c0m)iSU4uXUTL9y1aReu68c0m)iSU4ujNWSbKcRgyLGsNxGM5hH1fNkuAgYrmavXMU4ur0Vvg5wFvmPGmvD7rSeRgyLGsNxGM5hH1fNk2fYWIXW4HOy8DkMJsZJb29BLrU1xm9fJOBoyV5IXaIX8y20zoymx7XSOyO0siHtGX4DmGexzkgFNIbj2jWmNaJPpkMghJVtXGe7eyMtGX0hfZMoZbJzxtsOlgoHqX476ft6GSyqKOpqumlcOXum(ofdGbF3JHoqujKrfU1hQi63kJCRVQBp7GdPuScQInDXjMp9rPe9BLrU1x1ThXmuLNPuqvSPlove9BLrU1xftkitv3EeZgqkOk20fNkI(TYi36RIjfKPQBpcsIU5G9MRi63kJCRVcygRU132cb5KhiazfgdibzL0TTUYPZlagMqUIDcdXT1voDErw7a52bhISmfufB6Itfr)wzKB9vD7rSXgufB6Itfr)wzKB9vD7rSdWGV7vm9u7qYt6GSqgwmMTdemgFNIrKXy68yC7rX4Dm(ofdsStGzobgdS73kJCRVy8oMKShJ5Xyxm6c18StX42JIb1X47QhJ5XyOyqUX5XOcrgRofJc4eogngU5oNIXThftIIqeQeYOc36dve9BLrU1x1TNDWHukwbvXMU4eZN(OuI(TYi36R62JyUtsPGGmdv5zkLBpkKHfJHfSt5CMyogrFqjShdaUFXOluZZofJBpkg9aJb5nMIX3PyWexDdkfJBpkg7IbQInDXPIBpQ6Dv0Vvg5wFLyy8oUjlfJVtXGjKhtdeJVtXiuUiZv36dXCmB2nXEm7AscDXWjekgamL(z6CotX4DmOeIaJjNeJVtXGSxMRU1hZX47gkMDnjHoumnaG8iVaBgxm6bgZMDJtXiuKBh8siJkCRpur0Vvg5wFv3E2bhsPyfufB6ItmNruTbaQWfGPKJ5mIQB2novfkYTdEk5y(0hLYThv9Uk63kJCRpMHQ8mLccqvSPlove9BLrU1x1ThjpU9iiUTRmaqr0Vvg5wFfWEZfYeYOc36dvWDsnzxrukaU(iKJnzjMnGuQWnOuLo6zeIDPGQytxCQS3Ef5ysLTcW1hHCSjlXaewzaGYE7vKJjv2soHn2wzaGcGHjK34xjNaXqgv4wFOcUtQj7kIGukwLWeUxCf5mBaPwzaGckFvzTdoQU4eczh8kMuqMk5egwzaGckFvzTdoQU4eczh8kMuqMky6P2HyNqrE1ThfYOc36dvWDsnzxreKsXQeMW9IRiNzdi1kdauammH8g)k5Kqgv4wFOcUtQj7kIGukwLWeUxCf5mBaPwzaGYE7vKJjv2sojKHfJHXdrX0hfdlyykgyYvKhdPyotXyxmBJo9IXaIHPohdyFB5XSRqPyiZ3jCmBpsD7GhdJxsmnoMTx7Xi5ysLngMipg9aJHmFNWmAmqqHym7kukMxJPy8D9IX30XOCmPGmXCmqybXy2vOumBhNsd5yfT9r3cfdlKXmfdMuqMIX7yYiI5yACmqqaXyKifBh8yGrNf7XyOyuHBqPsmmU(2YJbSJX3numB2nofZUIbJrOi3o4XWcC9rihBYsOyACmB2PlgP8fdJj7GVfkgyYjeYo4XyOyWKcYujKrfU1hQG7KAYUIiiLIvagMQlUICMZiQ2aav4cWuYXCgr1n7gNQcf52bpLCmBaPypufB6Itfadt1fxrEnPBUDWzyLbakO8vL1o4O6ItiKDWRysbzQa2BoguHBqPkD0ZielHQytxCQSRyWQqrEfGRpc5ytwIb2dyyc5k2jCrfUbLyacSFLbak7K62bVMtk5egy)kdau2BVICmPYwYjmW(embT2aav4cWcGHP6IRiNbiOc36RayyQU4kYlIDfdNqSlv6yJni4kNoVOCknKJv02hfvbYyMyq0nhS3CfqScVpuDHj13lysbzcISXgIuSDWRENf7fv4gucIqmKHfJHXdrXWcgMIbMCf5XqMVt4yaZy7GhJgdlyyAPCoRspMW9IRipgHI8y2StxmBpsD7GhdJxsmgkgv4gukMghdygBh8yO0ir2Py2y(EmsKITdEmWOZI9siJkCRpub3j1KDfrqkfRammvxCf5mNruTbaQWfGPKJ5mIQB2novfkYTdEk5y2asXEOk20fNkagMQlUI8As3C7GZa7bmmHCf7eUOc3Gsmabiabv4wFfadtlLZluAKi72bNbiOc36RayyAPCEHsJezNQy6P2HyjKvyn2yJ948rangovammH8g)GiBSPc36RKWeUxCf5fknsKD7GZaeuHB9vsyc3lUI8cLgjYovX0tTdXsiRWASXg7X5JaAmCQayyc5n(briYWkdau2j1TdEnNuYjqKn2GaIuSDWRENf7fv4guIbiSYaaLDsD7GxZjLCcdSxfU1xbjASyVqPrISBhC2yJ9RmaqzV9kYXKkBjNWa7xzaGYoPUDWR5KsoHbv4wFfKOXI9cLgjYUDWzG97TxroMuzROeIZrv7QaCd(UdricXqgv4wFOcUtQj7kIGukwjuoVQc36RYnKZ8PpkLkCdkvDLtNJczuHB9Hk4oPMSRicsPyvct4EXvKZSbKALbakjmHBbxrVsoHbHI8QBpILRmaqjHjCl4k6vW0tTdXGqrE1ThXYvgaOGZhvBGAsVHWfm9u7qHmQWT(qfCNut2vebPuSkHjCV4kYz2asTYaaL92RihtQSLCcdisX2bV6DwSxuHBqjguHBqPkD0ZielHQytxCQS3Ef5ysLTcW1hHCSjlfYOc36dvWDsnzxreKsXQK9MolTkaxFeIzdif7HQytxCQKS30zPvt6MBhCgwzaGYoPUDWR5KsoHb2VYaaL92RihtQSLCcdqqfUbLQGTxm4N5elthBSPc3Gsv6ONri2LcQInDXPYUIbRcf5vaU(iKJnzj2ytfUbLQ0rpJqSlfufB6ItL92RihtQSvaU(iKJnzjigYOc36dvWDsnzxreKsXkKOXIDMnGuisX2bV6DwSxuHBqPqgv4wFOcUtQj7kIGukwbIv49HQlmP(oZgqkv4guQsh9mcXU0fYOc36dvWDsnzxreKsXkfl0JQuAj8gz9XSbKsfUbLQ0rpJqSlfufB6Itffl0JQuAj8gz9XWtpTKiC2LcQInDXPIIf6rvkTeEJS(Qp90qgwmggBZ3JHUodFpgxXWjhXCmMhJHIrJbUAxmEhJqrEmSaxFeYXMSumkkgaJZjCm2HCsbJPbIHfmmTuoVeYOc36dvWDsnzxreKsXkaU(iKJnzjMnGuQWnOuLo6zeIDPGQytxCQSRyWQqrEfGRpc5ytwkKrfU1hQG7KAYUIiiLIvagMwkNhYeYOc36dvqUEGkgSIBxDRVuaC9rihBYsmBaPuHBqPkD0Zie7sbvXMU4uzV9kYXKkBfGRpc5ytwIbiSYaaL92RihtQSLCcBSTYaafadtiVXVsobIHmQWT(qfKRhOIbR42v36dsPyvct4EXvKZSbKALbakagMqEJFLCsiJkCRpub56bQyWkUD1T(GukwLWeUxCf5mBaPwzaGYE7vKJjv2soHHvgaOS3Ef5ysLTGPNAhILQWT(kagMwkNxO0ir2PQBpkKrfU1hQGC9avmyf3U6wFqkfRsyc3lUICMnGuRmaqzV9kYXKkBjNWaesWe0kCbyrUcGHPLY5SXgGHjKRyNWfv4guIn2uHB9vsyc3lUI8IDvaUbF3HyidlgdmWmfJ3XaN8yKymbZysWTafJDidKIzB0Pxmj7kIqX04yGD)wzKB9ftYUIiumB2PlMKgHSfNkHmQWT(qfKRhOIbR42v36dsPyvct4EXvKZSbKALbakO8vL1o4O6ItiKDWRysbzQKtyacIU5G9MRGZhvBGAsVHWfm9u7qqsfU1xbNpQ2a1KEdHluAKi7u1ThbjHI8QBpIDRmaqbLVQS2bhvxCcHSdEftkitfm9u7qSXg7DLtNxW5JQnqnP3qyiYaufB6Itf3Eu17QOFRmYT(GKqrE1ThXUvgaOGYxvw7GJQloHq2bVIjfKPcMEQDOqgv4wFOcY1duXGvC7QB9bPuSkHjCV4kYz2asTYaaL92RihtQSLCcdisX2bV6DwSxuHBqPqgv4wFOcY1duXGvC7QB9bPuSkHjCV4kYz2asTYaaLeMWTGROxjNWGqrE1ThXYvgaOKWeUfCf9ky6P2HczyXyyCzSDWJX3PyqUEGkgmgC7QB9XCm9XzkMmIIHfmmfdm5kYrXSzNUy8DIPyumfZ1EmlYo4XK0nNaJbOXXSn60lMghdS73kJCRVsmmEikgwWWumWKRipgY8DchdygBh8y0yybdtlLZzv6XeUxCf5XiuKhZMD6Iz7rQBh8yy8sIXqXOc3GsX04yaZy7GhdLgjYofZgZ3JrIuSDWJbgDwSxczuHB9HkixpqfdwXTRU1hKsXkadt1fxroZzevBaGkCbyk5yoJO6MDJtvHIC7GNsoMnGuShWWeYvSt4IkCdkXa7HQytxCQayyQU4kYRjDZTdodqacqqfU1xbWW0s58cLgjYUDWzacQWT(kagMwkNxO0ir2PkMEQDiwczfwJn2ypoFeqJHtfadtiVXpiYgBQWT(kjmH7fxrEHsJez3o4mabv4wFLeMW9IRiVqPrIStvm9u7qSeYkSgBSXEC(iGgdNkagMqEJFqeImSYaaLDsD7GxZjLCcezJniGifBh8Q3zXErfUbLyacRmaqzNu3o41CsjNWa7vHB9vqIgl2luAKi72bNn2y)kdau2BVICmPYwYjmW(vgaOStQBh8AoPKtyqfU1xbjASyVqPrISBhCgy)E7vKJjv2kkH4Cu1Uka3GV7qeIqmKrfU1hQGC9avmyf3U6wFqkfRsyc3lUICMnGuRmaqzV9kYXKkBjNWGkCdkvPJEgHyjufB6ItL92RihtQSvaU(iKJnzPqgv4wFOcY1duXGvC7QB9bPuSkzVPZsRcW1hHy2asXEOk20fNkj7nDwA1KU52bNbiWEx505faC)Q(ovv0oHyJnv4guQsh9mcXo5GidqqfUbLQGTxm4N5elthBSPc3Gsv6ONri2LcQInDXPYUIbRcf5vaU(iKJnzj2ytfUbLQ0rpJqSlfufB6ItL92RihtQSvaU(iKJnzjigYOc36dvqUEGkgSIBxDRpiLIvcLZRQWT(QCd5mF6JsPc3Gsvx505Oqgv4wFOcY1duXGvC7QB9bPuSceRW7dvxys9DMnGuQWnOuLo6zeIDYfYOc36dvqUEGkgSIBxDRpiLIvirJf7mBaPqKITdE17SyVOc3GsHmQWT(qfKRhOIbR42v36dsPyLIf6rvkTeEJS(y2asPc3Gsv6ONri2LcQInDXPIIf6rvkTeEJS(y4PNwseo7sbvXMU4urXc9OkLwcVrwF1NEAidlgdJT57XqxNHVhJRy4KJyogZJXqXOXaxTlgVJrOipgwGRpc5ytwkgffdGX5eog7qoPGX0aXWcgMwkNxczuHB9HkixpqfdwXTRU1hKsXkaU(iKJnzjMnGuQWnOuLo6zeIDPGQytxCQSRyWQqrEfGRpc5ytwkKrfU1hQGC9avmyf3U6wFqkfRammTuo)7F))b]] )


end
