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


    spec:RegisterPack( "Fire", 20210310, [[de13LeqiIcpcLGlHssztOqFsLOrbcofi0QarLxbkmluu3IOi7sHFHsQHPsQogrPLPsINPskMgrvLRHsITHcQ6BOGkJtLuY5qbLwhkqZdLO7jLAFev5FGOQ0bvjPwiOKhcImruq6IevvTruc9rusQgjiQYjjkQwjkvVuLKWmrbCtvsI2jOu)eLKmuIQYsvjj9uImvqrxffuSvIIYxvjLASGOSxv1Fv0GfDyklwfpMWKb6YiBgWNbvJwL60KwniQQEnrLzJQBRk7wPFlz4sXXrbXYH8COMUW1LQTdsFxkz8QeopkY6brvX8rPSFQ(l7hMFjqlOpSVY1VISx)AK96dzVwxxww5lfm1qFPgtiNbN(sR9OVelQi6l1ymXld8dZVeU6ib9LUJObZGSM1W14UFgI6XAS(6Cl0AfidiynwFcw)LoDLhY89F(sGwqFyFLRFfzV(1i71hYYWXkmCYYW)LSECxOVKK(G0x6wbbP9F(sGew8LyrfrEEvAWjN97iAWmiRznCnU7NHOESgRVo3cTwbYacwJ1NG1o7xLgsC7PSxNzpVY1VISo7o7q62w4eMbD2LjpzyWKNak87yIONPl2tKf3eYZ42wpddbNIrOpAg1eujpbkKNCdhYeMe1c6PDuUgm5zhBWj8WzxM8KbQctRNcdhEIigsxr0J2a7jqH8es170XHwRNqqh0GzpbR9YWZ7Id6PgEcuipnpbqe(2ZRskOc5PWWbeho7YKNY)1oCYtCGur4P4MeYPlCpR1tZtaQLNafsoSN66zCtEE1Yhd4zuEIiWUG8SvHKJxg4WzxM88QbH83XHNMNYhtO6WnC4jTbIjpJBl8eSiSNBfE(kqI7zlIZ9uxzcU9ipHawFEgeoiqpTWZT8eRWxfqf2gEYqLpjp1xJjcioC2LjpHuTqju4PX5EE6aadiBGiteEsBGuc7zuEE6aadiB0By2tB904VchEQlwHVkGkSn8KHkFsEc301tD9eRp84lXvCG)W8ljQ3PJdT2zOpDH)H5h2Y(H5xIw7WjWpS(svZxctXxYeHw7xcQHu7WPVeuJ3PVKOkoy1AhI6D64qRDGONPl2tiNNqWtz9uM8ecEc1qQD40qoDb56cFIiWUi0A9egEE9Xv8eY5jGIiCyOGqdtekuYti6jKZZW40gd50fKRl8bT2HtGEcXVeudnx7rFjr9oDCO1orKbY0m0h9LajSaPnHw7xcYJ4neYtOgsTdN8mUTWtrTHPl2Z4M80er34Es4qFwqGEg6J8mUTWZ4M8CPlcpHu9oDCO16zlLZ98qEIidKPXp(W(kFy(LO1oCc8dRVu18LWu8LmrO1(LGAi1oC6lb14D6lb1qQD40quVthhATtezGmnd9rFjOgAU2J(sI6D64qRDg6J(Xh2xZhMFjATdNa)W6lvnFPNDXxYeHw7xcQHu7WPVeudnx7rFjr9oDCO1od9rFjOgVtFjafr4WqbHgi6z6I)sGewG0MqR9lXqjUXKNqQENoo0A9eOqEAabH8KfveHddfeYZ(Yjm2tOgsTdNgakIWHHccnf170XHwRNk2tmfJVKaPbHu7lfgN2yaOichgki0Gw7Wjqpz0tz4judP2Htdafr4WqbHMI6D64qR9hFyl)(W8lrRD4e4hwFPQ5l9Sl(sMi0A)sqnKAho9LGAO5Ap6ljQ3PJdT2zOp6lb14D6ljQIdwT2bYavBJjUXqYnq0Z0f)LajSaPnHw7xIHsCJjpHu9oDCO16jqH88QAGQTHNsngsopvap1WZwkN7POEKNfaGNIQ4GvR1tCv74ljqAqi1(sIckT2gd5ycP26jJEkQIdwT2bYavBJjUXqYnq0Z0f7Pm5PSx3tw6judP2Htdr9oDCO1od9r)4dBw5dZVeT2HtGFy9LQMV0ZU4lzIqR9lb1qQD40xcQHMR9OVKOENoo0ANH(OVeuJ3PVKOkoy1AhGKf3NcT0arptx8xcKWcK2eATFjgkXnM8es170XHwRNafYtgkzX9Pqln(scKgesTVKOGsRTXyjbQ4fc0tg9uufhSATdqYI7tHwAGONPl2tzYtzVUNS0tOgsTdNgI6D64qRDg6J(Xh2m8Fy(LO1oCc8dRVu18LE2fFjteATFjOgsTdN(sqn0CTh9Le170XHw7m0h9LGA8o9LGAi1oCAqVgMqKXNfcCTvqtqIBm5Pm5je8uufhSATd61WeIm(SqGRTcAa2rwO16Pm5POkoy1Ah0RHjez8zHaxBf0arptxSNq0tiNNYWtrvCWQ1oOxdtiY4ZcbU2kObImqM(sGewG0MqR9lXqjUXKNqQENoo0A9eOqEg3KNY)xdtiY4EYQqGRTcYZthaWtfWZ4M8SHBmripvSNDSUW9mUTWZaPRCum(scKgesTVeXq6AtdboOxdtiY4ZcbU2kOF8Hnd3hMFjATdNa)W6lvnFPNDXxYeHw7xcQHu7WPVeudnx7rFjr9oDCO1od9rFjOgVtFjrvCWQ1oGZnq1IcHNhdeonVg5hRCLRCTgi6z6I)sGewG0MqR9lXqjUXKNqQENoo0A9eOqEYQZnq1IcH9ewgiCIzp7lNWyp1WZwvNd65H8eK4gteON8AHtipJBB98kx3tmjQfep(scKgesTVeXq6AtdboGZnq1IcHNhdeo5jJEkQIdwT2bCUbQwui88yGWP51i)yLRCLR1arptxSNYKNx56EYspHAi1oCAiQ3PJdT2zOp6hFyFT(W8lrRD4e4hwFPQ5l9Sl(sMi0A)sqnKAho9LGAO5Ap6ljQ3PJdT2zOp6lb14D6lD6aaduFPzbmBQweAGONPl(lbsybsBcT2VedL4gtEcP6D64qR1Z(gk3ZRAjFEsx0Oic7Pc4PgxI9S3m(scKgesTVuyCAJbQV0SaMnvlcnO1oCc0tg980bagI6D64qRDawT2F8Hnd7hMFjATdNa)W6lvnFPNDXxYeHw7xcQHu7WPVeudnx7rFjr9oDCO1od9rFjOgVtFjrvCWQ1oq9LMfWSPArObIEMUypHHNNoaWa1xAwaZMQfHgGDKfATFjqclqAtO1(LyOe3yYtivVthhATEcuipT1t6IazEEv7l5zb4P8vTiKNkGNXn55vTVKNfGNYx1IqE2Q6Cqpf1J8Saa8uufhSATEAHNCYWHNSINysuli2ZdbuiYtivVthhATE2Q6CWXxsG0GqQ9LcJtBmq9LMfWSPArObT2HtGEYONNoaWquVthhATdWQ16jJEkQIdwT2bQV0SaMnvlcnq0Z0f7jm8Kv8KLEc1qQD40quVthhATZqF0p(Ww2R)H5xIw7WjWpS(svZx6zx8LmrO1(LGAi1oC6lb1qZ1E0xsuVthhATZqF0xcQX70xsufhSATJthaycQyH2W11qmnf17zl4aSJSqR1ty4POkoy1AhNoaWeuXcTHRRHyAkQ3ZwWbIEMU4VeiHfiTj0A)smuIBm5jKQ3PJdTwppm5zVXZO8u2R7jMe1cI9mkpb0WtD9KUiqMNDSbNWEwaEYqvSqB46AiM8es17zl44ljqAqi1(sIQ4GvRDC6aatqfl0gUUgIPPOEpBbhi6z6I9egEkQIdwT2XPdambvSqB46AiMMI69SfCa2rwO16jl9eQHu7WPHOENoo0ANH(ipLjpL96)4dBzL9dZVeT2HtGFy9LQMV0ZU4lzIqR9lb1qQD40xcQHMR9OVKOENoo0ANH(OVeuJ3PVKOkoy1AhNoaWeuXcTHRRHyAkQ3ZwWbIEMU4VeiHfiTj0A)smuIBm5jKQ3PJdTwpvapzOkwOnCDnetEcP69Sf0ZwvNd65wHNhYtezGm5jqH8udpzIIXxsG0GqQ9Lq9LakeCAaQyH2W11qmnf17zl4Gw7Wjqpz0ZthayaQyH2W11qmnf17zl4aSAT)4dBzVYhMFjATdNa)W6lvnFPNDXxYeHw7xcQHu7WPVeudnx7rFjr9oDCO1od9rFjOgVtFjKPGtckTXWabXdD)sGewG0MqR9lDvnf0t5puAdmd6jdL4gtEcP6D64qR1tGc5Pbc6jUXATyplapVgplKNVcrEAGGypJBl8SLY5EYnC4jVw4eYZ42wpLLv8etIAbXdpH5nHjpHA8oH90q0Ez45sccJnKYzYZQj0NX9uxpno3tHHj84ljqAqi1(sitbNeuAJHbcIh0fkoWEYONitbNeuAJHbcIhIQVHNYRTNxJNm6jYuWjbL2yyGG4byhzHwRNYZtzzLF8HTSxZhMFjATdNa)W6lvnFjmfFjteATFjOgsTdN(sqn0CTh9Le170XHw7m0h9LGA8o9LqMcojO0gdOD(si7WPHUEc58ugEImfCsqPngq78Lq2HtJEZxcKWcK2eATFPRQPGEk)HsBGzqpVAElJjSNDm5jKQ3PJdTwpBPXTNq78Lq2r5AWKNitb9KGsBGz2ZckHqki5PTm5jiXnMWEYvCqGEANck5zuE(m5ipXDe5PgEcNcSNDmb65nHOXxsG0GqQ9LqMcojO0gdOD(si7WPbDHIdSNm6judP2Htdr9oDCO1orKbY0m0h5jl9ezk4KGsBmG25lHSdNg6(JpSLv(9H5xIw7WjWpS(svZxctXxYeHw7xcQHu7WPVeudnx7rFjr9oDCO1od9rFjOgVtFjOgsTdNgI6D64qRDIidKPzOp6lbsybsBcT2VeddM8mUjpx6IWtivVthhATEwRNIQ4GvR1tfWtn8Sv15GEUv45H8KUOHebb6zuEcsCJjpJBYtS4Ma7Cc0ZAjplKNXn5jwCtGDob6zTKNTQoh0ZBRPHwp5eg7zCBRNYYkEIjrTGyppeqHipJBYtaf(D4jTG4HNxniONr5judP2Htd50fKRl8jIa7IqR1ZdjSoM8mUvSN6k4Dqc7zCtEcGQn4LbsGEgifoCcH9eSJ0fUNqQENoo0A90wqpJBl8eQHu7WjpvSNpY2WZO88qE2XeONgqqipHu9oDCO1o(scKgesTVeudP2Htdr9oDCO1orKbY0m0h5jm8uufhSATdr9oDCO1oa7il0A9eY5je8uwpLjpHGNxFCfpHHNqnKAhonKtxqUUWNicSlcTwpHHNxFCfpHCEcOichgki0WeHcL8eIEc58mmoTXqoDb56cFqRD4eONq0tw22tOgsTdNgI6D64qRDg6J8Kn28eQHu7WPHOENoo0ANH(ipLNNak87yIONPl2tzYZRC9F8HTSSYhMFjATdNa)W6lvnFjde8lzIqR9lb1qQD40xcQX70xk0h9LGAO5Ap6ljQ3PJdT2zOp6lbsybsBcT2V0vdc6zCtEk6ieTHNH(ipJYZ4M8elUjWoNa9es170XHwRNr5ztp8udp11t7GlEpipd9rEIlpJBl8udpvSN4q5CpnHOJSG80acc5P5jxJGtEg6J8SXWycp(Xh2YYW)H5xIw7WjWpS(sDmnBDRCAkmCOl8pSL9lbsybsBcT2VelQRX5mXSNIAHsOWtau980o4I3dYZqFKN2c6joke5zCtEIiUfkuYZqFKN66judP2HtJqF0mQPOENoo0AhEYWSCvoYZ4M8er4WZcWZ4M8uyCrNBHwlMzpBDRIBpVTMgA9KtySNaiIH0Pn4m5zuEIBic0ZEJNXn5jwFDUfATm7zCRypVTMgAXEwaaYeRoKyOEAlONTUvo5PWWHUWhFPQ5lHP4lb14D6lbbpHAi1oCAiQ3PJdT2zOpYtzYZqFKNq0tiNNNoaWquVthhATdWQ1(LGAO5Ap6lf6JMrnf170XHw7xQJPzbamHla)Ww2VKjcT2VeudP2Ht)4hFju1mBUnm9H5h2Y(H5xIw7WjWpS(scKgesTVKjcfknPLEkH9uET9eQHu7WPXDftCGitUja3EeoqQCKNm6je880bag3vmXbIm5g9gpzJnppDaGbGIiCuO3O34je)sMi0A)saC7r4aPYr)4d7R8H5xIw7WjWpS(scKgesTV0PdamW9DkNUWXZdNWyDHprKbY0O34jJEE6aadCFNYPlC88Wjmwx4tezGmnq0Z0f7P88uy4yg6J(sMi0A)snmHQd3WXp(W(A(W8lrRD4e4hwFjbsdcP2x60bagakIWrHEJEZxYeHw7xQHjuD4go(Xh2YVpm)s0Ahob(H1xsG0GqQ9LoDaGXDftCGitUrV5lzIqR9l1WeQoCdh)4dBw5dZVeT2HtGFy9L6yA26w50uy4qx4Fyl7xsG0GqQ9LKHNqnKAhonauenpCdhZMQ46c3tg980bag4(oLtx445HtySUWNiYazAawTwpz0ttekuAsl9uc7jl9eQHu7WPXTHaNcdhtaU9iCGu5ipz0tz4jGIiCyOGqdtekuYtg9ecEkdppDaGXnzHUWN9MrVXtg9ugEE6aaJ7kM4arMCJEJNm6Pm8SbrqNfaWeUaCaOiAE4go8KrpHGNMi0AhakIMhUHJH42qWjSNYRTNxXt2yZti4zyCAJHXPlWbYWq(y4jqhX0Gw7Wjqpz0trvCWQ1oarg8AXZdIS4EGidKjpHONSXMNyYq6cFgvxCpmrOqjpHONq8l1X0SaaMWfGFyl7xcKWcK2eATFjggm5zTKNSOIipHf3WHNKH4m5PUEEvl5ZtfWtMQUNG1Ez45TbL8K04MqEc5rwOlCpzyA8SqEc5vHNsbIm58Kjk80wqpjnUjed6jemi65TbL88viYZ42wpJwLNghrgitm7jeoq0ZBdk55vZPlWbYWq(yxI9Kf7iM8ergitEgLNDmXSNfYtiiGONsKH0fUNWS6IBpvSNMiuO0WtgATxgEcwEg3k2Zw3kN882qGEkmCOlCpzrU9iCGu5iSNfYZw306PuF98Qqx4xI9ewCcJ1fUNk2tezGmn(sMi0A)sakIMhUHJF8Hnd)hMFjATdNa)W6l1X0S1TYPPWWHUW)Ww2VKaPbHu7ljdpHAi1oCAaOiAE4goMnvX1fUNm6Pm8eqreomuqOHjcfk5jJEcbpHGNqWtteATdafrhJZh0fKOh6c3tg9ecEAIqRDaOi6yC(GUGe9GMi6z6I9KLEE9bR4jBS5Pm8e1xcOqWPbGIiCuO3Gw7WjqpHONSXMNMi0AhnmHQd3WXGUGe9qx4EYONqWtteATJgMq1HB4yqxqIEqte9mDXEYspV(Gv8Kn28ugEI6lbui40aqreok0BqRD4eONq0ti6jJEE6aaJBYcDHp7nJEJNq0t2yZti4jMmKUWNr1f3dtekuYtg9ecEE6aaJBYcDHp7nJEJNm6Pm80eHw7alkK4EqxqIEOlCpzJnpLHNNoaW4UIjoqKj3O34jJEkdppDaGXnzHUWN9MrVXtg90eHw7alkK4EqxqIEOlCpz0tz45DftCGitUjUH4C8u3jaxHFhEcrpHONq8l1X0SaaMWfGFyl7xcKWcK2eATFjggm5jlQiYtyXnC4jPXnH8eSJ0fUNMNSOIOJX5Sw(ycvhUHdpfgo8S1nTEc5rwOlCpzyA8uXEAIqHsEwipb7iDH7jDbj6b5zlnU9uImKUW9eMvxCp(sMi0A)sakIMhUHJF8Hnd3hMFjATdNa)W6lzIqR9ljmoFAIqRDYvC8L4koMR9OVKjcfkndJtBG)Xh2xRpm)s0Ahob(H1xsG0GqQ9LoDaGrdtOsWn8B0B8KrpfgoMH(ipzPNNoaWOHjuj4g(nq0Z0f7jJEkmCmd9rEYsppDaGbQV0SaMnvlcnq0Z0f)LmrO1(LAycvhUHJF8Hnd7hMFjATdNa)W6ljqAqi1(sNoaW4UIjoqKj3O34jJEIjdPl8zuDX9WeHcL8KrpnrOqPjT0tjSNS0tOgsTdNg3vmXbIm5MaC7r4aPYrFjteATFPgMq1HB44hFyl71)W8lrRD4e4hwFjbsdcP2xsgEc1qQD40O5UOvVy2ufxx4EYONNoaW4MSqx4ZEZO34jJEkdppDaGXDftCGitUrVXtg9ecEAIqHstWkgk8vdYtw65v8Kn280eHcLM0spLWEkV2Ec1qQD4042qGtHHJja3EeoqQCKNSXMNMiuO0Kw6Pe2t512tOgsTdNg3vmXbIm5MaC7r4aPYrEcXVKjcT2VuZDrREXeGBpc)JpSLv2pm)s0Ahob(H1xsG0GqQ9LWKH0f(mQU4EyIqHsFjteATFjSOqI7F8HTSx5dZVeT2HtGFy9LeiniKAFjtekuAsl9uc7P888kFjteATFjqKbVw88GilU)Xh2YEnFy(LO1oCc8dRVKaPbHu7lzIqHstAPNsypLxBpHAi1oCAyiHT0KUOHxyTwpz0ZNT2OreEkV2Ec1qQD40WqcBPjDrdVWATZNT2xYeHw7xYqcBPjDrdVWAT)4dBzLFFy(LO1oCc8dRVKaPbHu7lzIqHstAPNsypLxBpHAi1oCACBiWPWWXeGBpchivo6lzIqR9lbWThHdKkh9LajSaPnHw7x6ARXTN0wD43EggcofyM9udpvSNMNWnD9mkpfgo8Kf52JWbsLJ80WEcOCoH8uxCqgONfGNSOIOJX5JF8HTSSYhMFjteATFjafrhJZ)s0Ahob(H1p(XxcKaSop(W8dBz)W8lrRD4e4hwFjbsdcP2xsgEI6lbui40auXcTHRRHyAkQ3ZwWbT2HtGFjteATFjr13Gq4gIZ)Xh2x5dZVeT2HtGFy9LmrO1(LegNpnrO1o5ko(sGewG0MqR9lbZBYtr9oDCO1od9PlCpnrO16jxXHNyXnb25e2Zw306jKQ3PJdTwpBPCUNhYZoMa90wqpXrHiSNXn5jIWDE4PUEc1qQD40i0hnJAkQ3PJdT2XxIR4yU2J(sI6D64qRDg6tx4)4d7R5dZVeT2HtGFy9LQMVeMIVKjcT2VeudP2HtFjOgVtFji4PjcfknPLEkH9KLEc1qQD40quVthhATt8Tce6cF2uTiKNSXMNMiuO0Kw6Pe2tw6judP2Htdr9oDCO1ob42JWbsLJ8Kn28eQHu7WPrOpAg1uuVthhATEktEAIqRDGVvGqx4ZMQfHgaDoFIiWUi0A9uEEkQIdwT2b(wbcDHpBQweAa2rwO16je9KrpHAi1oCAe6JMrnf170XHwRNYKNIQ4GvRDGVvGqx4ZMQfHgi6z6I9uEEAIqRDGVvGqx4ZMQfHgaDoFIiWUi0A9KrpHGNIQ4GvRDG6lnlGzt1Iqde9mDXEktEkQIdwT2b(wbcDHpBQweAGONPl2t55jR4jBS5Pm8mmoTXa1xAwaZMQfHg0Ahob6je)sqn0CTh9LW3kqOl8zt1IqZdbuiAkQ3PJdT2VeiHfiTj0A)sYmdP2HtEg3w4jHd9zbH9S1nf3eYtPBfi0fUNYx1IqE2s5CppKNDmb65Hake5jKQ3PJdTwpvSNiYazA8JpSLFFy(LO1oCc8dRVKaPbHu7lD6aadr9oDCO1oaRwRNm6PjcT2bGIO5HB4yiUneCc7jlB7PSEYONYWti45Pdam0fGqRXNcdlmqA0B8KrppDaGXDftCGitUbImr4je9KrpHAi1oCAGVvGqx4ZMQfHMhcOq0uuVthhATFjteATFj8Tce6cF2uTi0p(WMv(W8lrRD4e4hwFjbsdcP2x60bagI6D64qRDawTwpz0ti4judP2HtJqF0mQPOENoo0A9KLEc1qQD40quVthhATZgejmCmd9rEcdpPlirpOzOpYt2yZtOgsTdNgH(Ozutr9oDCO16P880eHw7uufhSATEktEk719eIFjteATFjKbQ2gtCJHK7hFyZW)H5xIw7WjWpS(scKgesTV0Pdame170XHw7aSATEYONNoaWa1xAwaZMQfHgGvR1tg9eQHu7WPrOpAg1uuVthhATEYspHAi1oCAiQ3PJdT2zdIegoMH(ipHHN0fKOh0m0h9LmrO1(LajlUpfAPF8Hnd3hMFjATdNa)W6ljqAqi1(sqnKAhonc9rZOMI6D64qR1tw6judP2Htdr9oDCO1oBqKWWXm0h5jm8KUGe9GMH(ipz0ZthayiQ3PJdT2by1A)sMi0A)spfHkeEwaZOqpAJF8H916dZVeT2HtGFy9L6yA26w50uy4qx4Fyl7xYeHw7xcqr08WnC8LajSaPnHw7xIflKNYmAJBMqm7zhtEAEYIkI8ewCdhEkUneCYtWosx4EEvQiuHWEwaEcZc9On8uy4WZO80GwkONcRPrx4EkUneCcp(scKgesTVKjcT2XtrOcHNfWmk0J2yqxqIEOlCpz0tGoNprK42qWPzOpYtzYtteATJNIqfcplGzuOhTXGUGe9GMi6z6I9KLEk)8KrpLHN3vmXbIm5M4gIZXtDNaCf(D4jJEkdppDaGXDftCGitUrV5hFyZW(H5xIw7WjWpS(scKgesTVeudP2HtJqF0mQPOENoo0A9uEEAIqRDkQIdwTwpLjpzLVKjcT2VeCUbQwui88yGWPVebaqIyU2J(sW5gOArHWZJbcN(Xh2YE9pm)s0Ahob(H1xATh9LOxdtiY4ZcbU2kOVKjcT2Ve9AycrgFwiW1wb9LeiniKAFjOgsTdNgH(Ozutr9oDCO16jlB7judP2Htd61WeIm(SqGRTcAcsCJjpz0tOgsTdNgH(Ozutr9oDCO16P88eQHu7WPb9AycrgFwiW1wbnbjUXKNYKNSYp(Wwwz)W8lrRD4e4hwFP1E0xcoNPM7zbmnmwFk3cT2VKjcT2VeCotn3ZcyAyS(uUfATFjbsdcP2xcQHu7WPrOpAg1uuVthhATEkV2Ec1qQD40O2zhttrpkaGF8HTSx5dZVeT2HtGFy9Lw7rFPNjSdIM4BII5RJvXxYeHw7x6zc7GOj(MOy(6yv8LeiniKAFjOgsTdNgH(Ozutr9oDCO16jlB7jR8JpSL9A(W8lrRD4e4hwFP1E0xcergiGIOjucJj(xcKWcK2eATFjzoGNDSUW908eheQuqpRvM6yYtnOhZEA8wgtyp7yYtgkImqafrEkZimM4Ew9aRGKNfGNqQENoo0AhEYQIBc1sXeZE2G0cPHc5d5zhRlCpzOiYabue5PmJWyI7zlnU9es170XHwRN1YzYtfWtz(cqO14EcjdlmqYtf7jT2HtGEAlONMNDSbN8SvTxgEEip5fo8SGsipJBYtWoYcTwplapJBYtaf(Dm8eM3k2tdee7P5j(zCUNqnEN8mkpJBYtrvCWQ16zb4jdfrgiGIipLzegtCpBDtRNGLUW9mUvSNcJl6Cl0A98qcRJjp1Wtf7zFrKXXHk8mkpnmU)ipJBl8udpBPCUNhYZoMa9SHqaKi4m5zTEkQIdwT2XxsG0GqQ9LGAi1oCAe6JMrnf170XHwRNYRTNqnKAhonQD2X0u0JcaWtg9ecEE6aadDbi0A8PWWcdKg4WeY5zBppDaGHUaeAn(uyyHbsJNDXehMqopzJnpLHNIAb7Am0fGqRXNcdlmqAqRD4eONSXMNqnKAhone170XHw7S2zhtEYgBEc1qQD40i0hnJAkQ3PJdTwpLNN6geQP4wqGtaf(Dmr0Z0f7jRMNEcbpnrO1ofvXbRwRNWWtzVUNq0ti(LmrO1(LarKbcOiAcLWyI)JpSLv(9H5xIw7WjWpS(sR9OVeU68PcF1GqFjteATFjC15tf(QbH(scKgesTVee8eQHu7WPrOpAg1uuVthhATEkV2EEnx3tiNNqWtOgsTdNg1o7yAk6rba4P8886EcrpzJnpHGNYWZaPRCumczhkEGRoFQWxniKNm6zG0vokgHSJo2oCYtg9mq6khfJq2HOkoy1Ahi6z6I9Kn28ugEgiDLJIrCLHIh4QZNk8vdc5jJEgiDLJIrCLrhBho5jJEgiDLJIrCLHOkoy1Ahi6z6I9eIEcrpz0ti4Pm8KyiDTPHahGiYabuenHsymX9Kn28uufhSATdqezGakIMqjmM4ZRr(XWETyfgUbIEMUypLNNSINq8hFyllR8H5x60baMR9OVeU68PcF1qR9ljqAqi1(sYWtrTGDng6cqO14tHHfginO1oCc0tg9m0h5jl9Kv8Kn2880bag6cqO14tHHfginWHjKZZ2EE6aadDbi0A8PWWcdKgp7IjomHCFjATdNa)W6lbsybsBcT2VemrkC4eYtPQZ9uMdF1GqEsgIZKNT042tz(cqO14EcjdlmqYZc5zRBA9udpBzypBqKWWX4lzIqR9ljSvq85Pda8JpSLLH)dZVeT2HtGFy9LeiniKAFjOgsTdNgH(Ozutr9oDCO16P8A7judP2HtJANDmnf9Oaa(sMi0A)sDmn1GE4VeiHfiTj0A)sY8GEypJBl8eS8CRWZdTeGgEcP6D64qR1t8D15GEc5VJdppKNDmb6z1dScsEwaEcP6D64qR1tl8expYZMs3y8JpSLLH7dZVeT2HtGFy9LeiniKAFjuFjGcbNgWrkMZ0ufQGtdATdNa9KrppDaGHOENoo0AhGvR1tg9ecEc1qQD40i0hnJAkQ3PJdTwpLNNMi0ANIQ4GvR1t2yZtOgsTdNgH(Ozutr9oDCO16jl9eQHu7WPHOENoo0ANnisy4yg6J8egEsxqIEqZqFKNq8lzIqR9lbGkCm3cQ9LajSaPnHw7xIHbtEYIOchEc7cQ5zuEgifoCc5jRosXCM8uMlubNg)4dBzVwFy(LO1oCc8dRVKaPbHu7lH6lbui40auXcTHRRHyAkQ3ZwWbT2HtGEYONIQ4GvRDC6aatqfl0gUUgIPPOEpBbhi6z6I9KLEAIqRDaGkCCkEmegoMH(ipz0ZthayaQyH2W11qmnf17zl40qcBPby1A9KrpLHNNoaWauXcTHRRHyAkQ3ZwWrVXtg9ecEc1qQD40i0hnJAkQ3PJdTwpLNNIQ4GvRDC6aatqfl0gUUgIPPOEpBbhGDKfATEYgBEc1qQD40i0hnJAkQ3PJdTwpzPNSINq8lzIqR9ljQ(gec3qC(xcKWcK2eATFjwDk8mUjpzOkwOnCDnetEcP69Sf0ZthaWZEdZE2xoHXEkQ3PJdTwpvSN4Q2Xp(Wwwg2pm)s0Ahob(H1xsG0GqQ9Lq9LakeCAaQyH2W11qmnf17zl4Gw7Wjqpz0trvCWQ1ooDaGjOIfAdxxdX0uuVNTGde9mDXEYspPlirpOzOpYty4PjcT2baQWXP4Xqy4yg6J8KrppDaGbOIfAdxxdX0uuVNTGtdjSLgGvR1tg9ugEE6aadqfl0gUUgIPPOEpBbh9gpz0ti4judP2HtJqF0mQPOENoo0A9uEEkQIdwT2XPdambvSqB46AiMMI69SfCa2rwO16jBS5judP2HtJqF0mQPOENoo0A9KLEYkEYONYWZW40gduFPzbmBQweAqRD4eONq8lzIqR9lziHT0KUOHxyT2F8H9vU(hMFjATdNa)W6ljqAqi1(sO(safconavSqB46AiMMI69SfCqRD4eONm6POkoy1AhNoaWeuXcTHRRHyAkQ3ZwWbIEMUypzPNcdhZqFKNm65PdamavSqB46AiMMI69SfCcGkCmaRwRNm6Pm880bagGkwOnCDnettr9E2co6nEYONqWtOgsTdNgH(Ozutr9oDCO16P88uufhSATJthaycQyH2W11qmnf17zl4aSJSqR1t2yZtOgsTdNgH(Ozutr9oDCO16jl9Kv8eIFjteATFjauHJtXJF8H9vK9dZVeT2HtGFy9LmrO1(LegNpnrO1o5ko(scKgesTVeudP2HtJqF0mQPOENoo0A9KLT986EYgBEc1qQD40i0hnJAkQ3PJdTwpzPNqnKAhone170XHw7SbrcdhZqFKNm6POkoy1AhI6D64qRDGONPl2tw6judP2Htdr9oDCO1oBqKWWXm0h9L4koMR9OVKOENoo0ANn3gM(Xh2x5kFy(LO1oCc8dRVKaPbHu7lD6aaduFPzbmBQweAawTwpz0tz45PdamaueHJc9g9gpz0ti4judP2HtJqF0mQPOENoo0A9uET980bagO(sZcy2uTi0aSJSqR1tg9eQHu7WPrOpAg1uuVthhATEkppnrO1oauenpCdhdGoNprK42qWPzOpYt2yZtOgsTdNgH(Ozutr9oDCO16P88eqHFhte9mDXEcXVKjcT2VeQV0SaMnvlc9JpSVY18H5xIw7WjWpS(sDmnBDRCAkmCOl8pSL9lbsybsBcT2VK8vf3td75ZwM8Kfve5jS4goWEAypBkmwpCYtGc5jKQ3PJdT2HNs9tGmr4z1dplapJBYtaKjcTwJ7POEn1sB4zb4zCtEU93HqEwaEYIkI8ewCdhypJBl8SLY5EUw0rgNZKNisCBi4KNGDKUW9mUjpHu9oDCO16zZTHjppKW6yYZMQ46c3tBzkU1fUNngo8mUTWZwkN75wHNWr2gEARN0fbY8Kfve5jS4go8eSJ0fUNqQENoo0AhFPQ5lHP4lb14D6lzIqRDaOiAE4gogIBdbNWtaKjcTwJ7jm8ecEc1qQD40i0hnJAkQ3PJdTwpHHNMi0Ah4Bfi0f(SPArObqNZNicSlcTwpHCEc1qQD40aFRaHUWNnvlcnpeqHOPOENoo0A9eIEYApfvXbRw7aqr08WnCma7il0A9uM8uwpzPNIQ4GvRDaOiAE4gogp7IP42qWjSNWWtOgsTdNgfuc1ufFcOiAE4goWEYApfvXbRw7aqr08WnCma7il0A9uM8ecEE6aadr9oDCO1oa7il0A9K1EkQIdwT2bGIO5HB4ya2rwO16je90twnpL1tg9eQHu7WPrOpAg1uuVthhATEYspbu43Xerptx8xcQHMR9OVeGIO5HB4y2ufxx4FPoMMfaWeUa8dBz)sMi0A)sqnKAho9JpSVI87dZVeT2HtGFy9LQMVeMIVKjcT2VeudP2HtFjOgAU2J(sn3fT6fZMQ46c)lb14D6lb1qQD40i0hnJAkQ3PJdTwpHHNNoaWquVthhATdWoYcTwpLjpzfpzPNMi0Ahn3fT6ftaU9i8aOZ5tejUneCAg6J8egEkQIdwT2rZDrREXeGBpcpa7il0A9uM80eHw7aFRaHUWNnvlcna6C(erGDrO16jKZtOgsTdNg4Bfi0f(SPArO5Hakenf170XHwRNm6judP2HtJqF0mQPOENoo0A9KLEcOWVJjIEMUypzJnpr9LakeCAG77uoDHJNhoHX6cFqRD4eONSXMNH(ipzPNSYxcKWcK2eATFjzMHu7WjpJBl8uuBGko2t57UOvVWtwKBpc7zhBWjpJYtAXDe5Pgypf3gcoH90qKNnvXjqpbkKNqQENoo0AhEYQwotE2XKNY3DrREHNSi3Ee2ZQhyfK8Sa8es170XHwRNTUP1tGoN7P42qWjSNcB98qEwNW0La9eSJ0fUNXn55sxeEcP6D64qRD8LeiniKAFjtekuAsl9uc7jl9eQHu7WPHOENoo0ANaC7r4aPYr)4d7RWkFy(LO1oCc8dRVu18LWu8LmrO1(LGAi1oC6lb1qZ1E0xQ5UOvVy2ufxx4FjOgVtFjOgsTdNgH(Ozutr9oDCO16jl90eHw7O5UOvVycWThHhaDoFIiXTHGtZqFKNYKNMi0Ah4Bfi0f(SPArObqNZNicSlcTwpHCEc1qQD40aFRaHUWNnvlcnpeqHOPOENoo0A9KrpHAi1oCAe6JMrnf170XHwRNS0taf(Dmr0Z0f7jBS5jQVeqHGtdCFNYPlC88Wjmwx4dATdNa9Kn28m0h5jl9Kv(sGewG0MqR9lDTVP1Zowx4EYIC7r4aPYrEQRNqQENoo0Az2tSbL80WE(SLjpf3gcoH90WE2uySE4KNafYtivVthhATE2sJ7QhEkSMgDHp(scKgesTVKjcfknPLEkH9uET9eQHu7WPHOENoo0ANaC7r4aPYr)4d7RWW)H5xIw7WjWpS(scKgesTV0Pdamq9LMfWSPArOrVXtg9eQHu7WPrOpAg1uuVthhATEkppV(xchiveFyl7xYeHw7xsyC(0eHw7KR44lXvCmx7rFju1mBUnm9JpSVcd3hMFjATdNa)W6l1X0S1TYPPWWHUW)Ww2VeiHfiTj0A)sxniK)oo8mUjpHAi1oCYZ42cpf1gOIJ9Kfve5jS4go8SJn4KNr5jT4oI8udSNIBdbNWEAiYtJJlpBQItGEcuipVQ9L8Sa8u(QweA8LQMVeMIVKaPbHu7ljdpHAi1oCAaOiAE4goMnvX1fUNm6zyCAJbQV0SaMnvlcnO1oCc0tg980bagO(sZcy2uTi0aSATFPoMMfaWeUa8dBz)sqnEN(sIQ4GvRDG6lnlGzt1Iqde9mDXEYspnrO1oauenpCdhdGoNprK42qWPzOpYtzYtteATd8Tce6cF2uTi0aOZ5teb2fHwRNqopHGNqnKAhonW3kqOl8zt1IqZdbuiAkQ3PJdTwpz0trvCWQ1oW3kqOl8zt1Iqde9mDXEYspfvXbRw7a1xAwaZMQfHgi6z6I9eIEYONIQ4GvRDG6lnlGzt1Iqde9mDXEYspbu43Xerptx8xYeHw7xcQHu7WPVeudnx7rFjafrZd3WXSPkUUW)Xh2x5A9H5xIw7WjWpS(sDmnBDRCAkmCOl8pSL9ljqAqi1(sYWtOgsTdNgakIMhUHJztvCDH7jJEc1qQD40i0hnJAkQ3PJdTwpLNNx3tg90eHcLM0spLWEkV2Ec1qQD4042qGtHHJja3EeoqQCKNm6Pm8eqreomuqOHjcfk5jJEkdppDaGXDftCGitUrVXtg9ecEE6aaJBYcDHp7nJEJNm6PjcT2ba3EeoqQC0GUGe9GMi6z6I9KLEE9bR4jBS5P42qWj8eazIqR14EkV2EEfpH4xQJPzbamHla)Ww2VeiHfiTj0A)sx7BA9eYZqGcdh6c3twKBpYtPaPYrm7jlQiYtyXnCG9eFxDoONhYZoMa9mkpHtlHSG8eYRcpLcezYH90wqpJYt6IGwqpHf3WbH88Q0WbHgFjteATFjafrZd3WXp(W(kmSFy(LO1oCc8dRVuhtZw3kNMcdh6c)dBz)scKgesTVeGIiCyOGqdtekuYtg9uCBi4e2t512tz9KrpLHNqnKAhonauenpCdhZMQ46c3tg9ecEkdpnrO1oaueDmoFqxqIEOlCpz0tz4PjcT2rdtO6WnCm0DcWv43HNm65PdamUjl0f(S3m6nEYgBEAIqRDaOi6yC(GUGe9qx4EYONYWZthayCxXehiYKB0B8Kn280eHw7OHjuD4gog6ob4k87Wtg980bag3Kf6cF2Bg9gpz0tz45PdamURyIdezYn6nEcXVuhtZcaycxa(HTSFjqclqAtO1(LyODKUW9KfveHddfeIzpzrfrEclUHdSNgI8SJjqpX6t5gIZKNr5jyhPlCpHu9oDCO1o8KvNwczCotm7zCtm5PHip7yc0ZO8eoTeYcYtiVk8ukqKjh2Zw306PaPb2ZwkN75wHNhYZwgoiqpTf0ZwAC7jS4goiKNxLgoieZEg3etEIVRoh0Zd5jUbrgONvp8mkpFMUHPRNXn5jS4goiKNxLgoiKNNoaW4lzIqR9lbOiAE4go(Xh2xZ1)W8lrRD4e4hwFPoMMTUvonfgo0f(h2Y(LmrO1(LauenpCdhFjqclqAtO1(LUAOLc6PWAA0fUNSOIipHf3WHNIBdbNWE26w5KNIBBxIRlCpLUvGqx4EkFvlc9LeiniKAFjteATd8Tce6cF2uTi0GUGe9qx4EYONaDoFIiXTHGtZqFKNS0tteATd8Tce6cF2uTi0iuHCteb2fHwRNm65PdamURyIdezYnaRwRNm6zOpYt55PSx)hFyFnY(H5xIw7WjWpS(sMi0A)scJZNMi0ANCfhFjbsdcP2xcQHu7WPrOpAg1uuVthhATEkppVUNm65Pdamq9LMfWSPArOby1A)sCfhZ1E0xch2cAiWjQcl0A)Xh2xZv(W8lzIqR9lHffsC)LO1oCc8dRF8JVudIe17yXhMFyl7hMFjteATFjdjSLM6geNtI4lrRD4e4hw)4d7R8H5xIw7WjWpS(svZxctXxcKWcK2eATFPRw(yapLzgsTdN8Kv1eATmONW8wXEc1qQD4KN4gsOakH9S1nf3eYtivVthhATEIVRoh0Zd5zhtGEc2r6c3twureomuqOXxcQX70xswpHCEkdpdJtBmAycvcUHFdATdNa)sqn0CTh9LaueHddfeAkQ3PJdT2VKjcT2VeudP2HtFjOgVttIJPVKm5PSFjbsdcP2xcQHu7WPbGIiCyOGqtr9oDCO16jl986)4d7R5dZVeT2HtGFy9LQMVeMIVKjcT2VeudP2HtFjOgAU2J(s3vmXbIm5MaC7r4aPYrFjOgVtFPR4jKZZW40gdaU9OzJfI7bT2HtGEcdpVgpHCEkdpdJtBma42JMnwiUh0Ahob(LajSaPnHw7x6QLpgWtzMHu7WjpzvnHwld6jmVvSNqnKAho5jUHekGsypJBYZT)oeYZcWZWqWPa7PfE26wf3Ec5vHNsbIm58Kf52JWbsLJWEw9aRGKNfGNqQENoo0A9eFxDoONhYZoMahFjbsdcP2xcQHu7WPXDftCGitUja3EeoqQCKNT986)4dB53hMFjATdNa)W6lvnFjmfFjteATFjOgsTdN(sqn0CTh9LUne4uy4ycWThHdKkh9LGA8o9LUINqopdJtBma42JMnwiUh0Ahob6jm88A8eY5Pm8mmoTXaGBpA2yH4EqRD4e4xcKWcK2eATFPRw(yapLzgsTdN8Kv1eATmONW8wXEc1qQD4KN4gsOakH9mUjp3(7qiplapddbNcSNw4zRBvC7jKNHa9esgo8Kf52JWbsLJWEw9aRGKNfGNqQENoo0A9eFxDoONhYZoMa90WEcOCoHgFjbsdcP2xcQHu7WPXTHaNcdhtaU9iCGu5ipB751)Xh2SYhMFjATdNa)W6lvnFjmfFjteATFjOgsTdN(sqn0CTh9Le170XHw7eGBpchivo6lb14D6lDnEc58mmoTXaGBpA2yH4EqRD4eONWWtgEpHCEkdpdJtBma42JMnwiUh0Ahob(LajSaPnHw7x6QLpgWtzMHu7WjpzvnHwld6jmVvSNqnKAho5jUHekGsypJBYZT)oeYZcWZWqWPa7PfE26wf3Ec5vHNsbIm58Kf52JWbsLJWEAiYZoMa9eSJ0fUNqQENoo0AhFjbsdcP2xcQHu7WPHOENoo0ANaC7r4aPYrE22ZR)JpSz4)W8lrRD4e4hwFPQ5lHP4lzIqR9lb1qQD40xcQHMR9OVKHe2st6IgEH1A)sqnEN(smSmSEc58mmoTXaGBpA2yH4EqRD4eONWWZR4jKZtz4zyCAJba3E0SXcX9Gw7WjWVeiHfiTj0A)sxT8XaEkZmKAho5jRQj0AzqpH5TI9eQHu7WjpXnKqbuc7zCtEU93HqEwaEggcofypTWZw3Q42ZRgjSL8u(FrdVWATEw9aRGKNfGNqQENoo0A9eFxDoONhYZoMahFjbsdcP2xcQHu7WPHHe2st6IgEH1A9STNx)hFyZW9H5xIw7WjWpS(svZxcryk(sMi0A)sqnKAho9LGAO5Ap6lziHT0KUOHxyT25Zw7lbsybsBcT2V0vlFmGNYmdP2HtEYQAcTwg0tyERypHAi1oCYtCdjuaLWEg3KNnesqByWjplapF2AEEiE1YZw3Q42ZRgjSL8u(FrdVWATE2s5Cp3k88qE2Xe44lbsawNhFj531)Xh2xRpm)s0Ahob(H1xQA(sictXxYeHw7xcQHu7WPVeudnx7rFj50fKRl8jIa7IqR9lbsybsBcT2V0vlFmGNYmdP2HtEYQAcTwg0ZRTg3EEvOlixx4m7jKQ3PJdT2lXEkQIdwTwpBPCUNhYteb2feONhM808ezly980EvFdM980dpJBYZT)oeYZcWtbsdSN4Wqb2tOeIjpVv43EAabH80eHc1cDH7jKQ3PJdTwpTf0tmVAH9eSATEgvldbI9mUjpPf0ZcWtivVthhATxI9uufhSATdpV23065ZKtx4EcscfR1I9uxpJBYZRw(yaM9es170XHw7Lypr0Z0vx4EkQIdwTwpvSNicSliqppm5zCRypbqMi0A9mkpnHO6B4jqH88QqxqUUWhFjqcW684lD9H87hFyZW(H5xIw7WjWpS(svZxcryk(sMi0A)sqnKAho9LGAO5Ap6ljQ3PJdT2j(wbcDHpBQwe6lbsybsBcT2V0vlFmGNYmdP2HtEYQAcTwg0tyEtEU93HqEwaEggcofypLUvGqx4EkFvlc5j(U6CqppKNDmb6zTEc2r6c3tivVthhATJVeibyDE8LUYp(Ww2R)H5xIw7WjWpS(svZxcryk(sMi0A)sqnKAho9LGAO5Ap6ljQ3PJdT2PWWXerptx8xcKWcK2eATFPRw(yapLzgsTdN8Kv1eATmONW8M8m0h5jIEMU6c3ZA908uy4WZw306jKQ3PJdTwpf265H8SJjqp11tmjQfep(sGeG15Xx66dgUF8HTSY(H5xIw7WjWpS(svZxcryk(sMi0A)sqnKAho9LGAO5Ap6lvqjutv8jGIO5HB4a)LajSaPnHw7x6QLpgWtzMHu7WjpzvnHwld6jmVvSNqnKAho5jUHekGsypJBYZT)oeYZcWtmjQfe7zb4jlQiYtyXnC4zCBHN47QZb98qE2ufNa9SXWHNXn5jibyDE4P9Q(gJVeibyDE8LU(p(Ww2R8H5xIw7WjWpS(svZxcryk(sMi0A)sqnKAho9LGAO5Ap6lrVgMqKXNfcCTvqtqIBm9LajSaPnHw7x6QLpgWtzMHu7WjpzvnHwld6jKx1YtETW98qafI8es170XHwRN47QZb9u()Aycrg3twfcCTvqEEip7yceY3VeibyDE8LK9A9JpSL9A(W8lrRD4e4hwFPQ5lHP4lzIqR9lb1qQD40xcQHMR9OVuOpAg1uuVthhATFjOgVtFjaf(Dmr0Z0f7jm8u2RF9VeiHfiTj0A)sYCapHu9oDCO16PI9euX2HtGm7jwCtGDo5zCtEcOiC4jKQ3PJdTwpbmKNgqqipJBYtaf(D4jTG4XxsG0GqQ9LGAi1oCAaQy7WPPOENoo0A)Xh2Yk)(W8lrRD4e4hwFPQ5lHP4lzIqR9lb1qQD40xcQX70xIv(sqn0CTh9LWYDMGDKfATFjqclqAtO1(LG5n5jyhzHwRNfGNMNs91ZRcDHFj2tyXjmwx4EcP6D64qRD8JpSLLv(W8lrRD4e4hwFPQ5lHP4lzIqR9lb1qQD40xcQX70xIyiDTPHahW5gOArHWZJbcN8Kn28KyiDTPHahptyhenX3efZxhRcpzJnpjgsxBAiWHUybQh2Httgs32O)MGeuvqEYgBEsmKU20qGdCFp8QaN2JIBMWHNSXMNedPRnne4GEnmHiJple4ARG8Kn28KyiDTPHahaC7rZcyESi4KNSXMNedPRnne4OLjhTecpbq1c6jBS5jXq6Atdbo0fhOUikeEcQq1LMhIZ)sqn0CTh9Le170XHw7S2zhtFjqclqAtO1(LU23uCtipnp7y7Wjp1GEE2XeONr55Pda4jKQ3PJdTwpvSNedPRnne44hFylld)hMFjATdNa)W6lvnFjmfFjteATFjOgsTdN(sqn0CTh9LQD2X0u0Jca4lb14D6lDLR)LajSaPnHw7xcYRA5jVw4EEiGcrEcP6D64qR1t8D15GEgiDLJcSNXTfEgifoCc5P5j(2qeONcli4fIjpfvXbRwRN16zf3eYZaPRCuG9CRWZd5zhtGq((LeiniKAFjOgsTdNgI6D64qRDw7SJPF8HTSmCFy(LO1oCc8dRVu18LWu8LmrO1(LGAi1oC6lb14D6lDfw5lb1qZ1E0xQ2zhttrpkaGVKaPbHu7lrmKU20qGJNjSdIM4BII5RJvXp(Ww2R1hMFjATdNa)W6lvnFjmfFjteATFjOgsTdN(sqnEN(sx56EcdpHAi1oCAqVgMqKXNfcCTvqtqIBm9LGAO5Ap6lv7SJPPOhfaWxsG0GqQ9LigsxBAiWb9AycrgFwiW1wb9JpSLLH9dZVeT2HtGFy9Lw7rFjC15tf(QbH(sMi0A)s4QZNk8vdc9LeiniKAFjz4judP2Htdr9oDCO1oRD2XKNm6Pm8KyiDTPHahGiYabuenHsymX9KrpLHNHXPngakIWHHccnO1oCc8hFyFLR)H5xYeHw7x6PiuHM6ZGtFjATdNa)W6hFyFfz)W8lrRD4e4hwFjbsdcP2xsgE2GiOJgMq1HB44lzIqR9l1WeQoCdh)4hFjr9oDCO1ofvXbRwl(dZpSL9dZVKjcT2VutfATFjATdNa)W6hFyFLpm)sMi0A)shEvGtGoIPVeT2HtGFy9JpSVMpm)s0Ahob(H1xsG0GqQ9LoDaGHOENoo0Ah9MVKjcT2V0HqycjNUW)Xh2YVpm)sMi0A)sakIo8Qa)s0Ahob(H1p(WMv(W8lzIqR9lzRGWbY4tHX5FjATdNa)W6hFyZW)H5xIw7WjWpS(scKgesTVeQVeqHGtJGEnfY4ZwgQzqRD4eONm65PdamOlUToo0Ah9MVKjcT2VuOpA2Yqn)4dBgUpm)s0Ahob(H1xYeHw7xco3avlkeEEmq40xIaairmx7rFj4CduTOq45XaHt)4d7R1hMFjATdNa)W6lT2J(s6IfOEyhonziDBJ(Bcsqvb9LmrO1(L0flq9WoCAYq62g93eKGQc6hFyZW(H5xIw7WjWpS(sR9OVea3E0SaMhlco9LmrO1(La42JMfW8yrWPF8HTSx)dZVeT2HtGFy9Lw7rFPwMC0si8eavl4xYeHw7xQLjhTecpbq1c(JpSLv2pm)s0Ahob(H1xATh9L0fhOUikeEcQq1LMhIZ)sMi0A)s6IduxefcpbvO6sZdX5)4dBzVYhMFjATdNa)W6lT2J(s4(E4vboThf3mHJVKjcT2VeUVhEvGt7rXnt44hFyl718H5xYeHw7xQJPPg0d)LO1oCc8dRF8JVKjcfkndJtBG)W8dBz)W8lrRD4e4hwFjbsdcP2xYeHcLM0spLWEkppL1tg980bagI6D64qRDawTwpz0ti4judP2HtJqF0mQPOENoo0A9uEEkQIdwT2bxHQl85PENbyhzHwRNSXMNqnKAhonc9rZOMI6D64qR1tw22ZR7je)sMi0A)sCfQUWNN6D(Xh2x5dZVeT2HtGFy9LeiniKAFjOgsTdNgH(Ozutr9oDCO16jlB7519Kn28ecEkQIdwT2XJcQqdWoYcTwpzPNqnKAhonc9rZOMI6D64qR1tg9ugEggN2yG6lnlGzt1IqdATdNa9eIEYgBEggN2yG6lnlGzt1IqdATdNa9KrppDaGbQV0SaMnvlcn6nEYONqnKAhonc9rZOMI6D64qR1t55PjcT2XJcQqdrvCWQ16jBS5jGc)oMi6z6I9KLEc1qQD40i0hnJAkQ3PJdT2VKjcT2V0JcQq)4d7R5dZVeT2HtGFy9LeiniKAFPW40gdJtxGdKHH8XWtGoIPbT2HtGEYONqWZthayiQ3PJdT2by1A9KrpLHNNoaW4UIjoqKj3O34je)sMi0A)sGidET45brwC)JF8LWHTGgcCIQWcT2pm)Ww2pm)s0Ahob(H1xsG0GqQ9LmrOqPjT0tjSNYRTNqnKAhonURyIdezYnb42JWbsLJ8KrpHGNNoaW4UIjoqKj3O34jBS55PdamaueHJc9g9gpH4xYeHw7xcGBpchivo6hFyFLpm)s0Ahob(H1xsG0GqQ9LoDaGbGIiCuO3O38LmrO1(LAycvhUHJF8H918H5xIw7WjWpS(scKgesTV0PdamURyIdezYn6nEYONNoaW4UIjoqKj3arptxSNS0tteATdafrhJZh0fKOh0m0h9LmrO1(LAycvhUHJF8HT87dZVeT2HtGFy9LeiniKAFPthayCxXehiYKB0B8KrpHGNnic6eUaCi7aqr0X4CpzJnpbueHddfeAyIqHsEYgBEAIqRD0WeQoCdhdDNaCf(D4je)sMi0A)snmHQd3WXp(WMv(W8lrRD4e4hwFjbsdcP2x60bag4(oLtx445HtySUWNiYazA0B8KrpHGNIQ4GvRDG6lnlGzt1Iqde9mDXEcdpnrO1oq9LMfWSPArObDbj6bnd9rEcdpfgoMH(ipLNNNoaWa33PC6chppCcJ1f(ergitde9mDXEYgBEkdpdJtBmq9LMfWSPArObT2HtGEcrpz0tOgsTdNgH(Ozutr9oDCO16jm8uy4yg6J8uEEE6aadCFNYPlC88Wjmwx4tezGmnq0Z0f)LmrO1(LAycvhUHJVeiHfiTj0A)sWeXKNr5jCk8u6QawE2Gkb2tDXki55vTKppBUnmH9SqEcP6D64qR1ZMBdtypBDtRNnfgRhon(Xh2m8Fy(LO1oCc8dRVKaPbHu7lD6aaJ7kM4arMCJEJNm6jMmKUWNr1f3dteku6lzIqR9l1WeQoCdh)4dBgUpm)s0Ahob(H1xsG0GqQ9LoDaGrdtOsWn8B0B8KrpfgoMH(ipzPNNoaWOHjuj4g(nq0Z0f)LmrO1(LAycvhUHJF8H916dZVeT2HtGFy9L6yA26w50uy4qx4Fyl7xsG0GqQ9LKHNakIWHHccnmrOqjpz0tz4judP2HtdafrZd3WXSPkUUW9KrpHGNqWti4PjcT2bGIOJX5d6cs0dDH7jJEcbpnrO1oaueDmoFqxqIEqte9mDXEYspV(Gv8Kn28ugEI6lbui40aqreok0BqRD4eONq0t2yZtteATJgMq1HB4yqxqIEOlCpz0ti4PjcT2rdtO6WnCmOlirpOjIEMUypzPNxFWkEYgBEkdpr9LakeCAaOichf6nO1oCc0ti6je9KrppDaGXnzHUWN9MrVXti6jBS5je8etgsx4ZO6I7Hjcfk5jJEcbppDaGXnzHUWN9MrVXtg9ugEAIqRDGffsCpOlirp0fUNSXMNYWZthayCxXehiYKB0B8KrpLHNNoaW4MSqx4ZEZO34jJEAIqRDGffsCpOlirp0fUNm6Pm88UIjoqKj3e3qCoEQ7eGRWVdpHONq0ti(L6yAwaat4cWpSL9lbsybsBcT2VedTJ0fUNXn5joSf0qGEIQWcTwM9SwotE2XKNSOIipHf3Wb2Zw306zCtm5PHip3k88q6c3ZMQ4eONafYZRAjFEwipHu9oDCO1o8KHbtEYIkI8ewCdhEsACtipb7iDH7P5jlQi6yCoRLpMq1HB4WtHHdpBDtRNqEKf6c3tgMgpvSNMiuOKNfYtWosx4EsxqIEqE2sJBpLidPlCpHz1f3JVKjcT2VeGIO5HB44hFyZW(H5xIw7WjWpS(scKgesTV0PdamURyIdezYn6nEYONMiuO0Kw6Pe2tw6judP2HtJ7kM4arMCtaU9iCGu5OVKjcT2VudtO6WnC8JpSL96Fy(LO1oCc8dRVKaPbHu7ljdpHAi1oCA0Cx0QxmBQIRlCpz0ti4Pm8mmoTXaavVzCttdFt4bT2HtGEYgBEAIqHstAPNsypLNNY6je9KrpHGNMiuO0eSIHcF1G8KLEEfpzJnpnrOqPjT0tjSNYRTNqnKAhonUne4uy4ycWThHdKkh5jBS5PjcfknPLEkH9uET9eQHu7WPXDftCGitUja3EeoqQCKNq8lzIqR9l1Cx0Qxmb42JW)4dBzL9dZVeT2HtGFy9LmrO1(LegNpnrO1o5ko(sCfhZ1E0xYeHcLMHXPnW)4dBzVYhMFjATdNa)W6ljqAqi1(sMiuO0Kw6Pe2t55PSFjteATFjqKbVw88GilU)Xh2YEnFy(LO1oCc8dRVKaPbHu7lHjdPl8zuDX9WeHcL(sMi0A)syrHe3)4dBzLFFy(LO1oCc8dRVKaPbHu7lzIqHstAPNsypLxBpHAi1oCAyiHT0KUOHxyTwpz0ZNT2OreEkV2Ec1qQD40WqcBPjDrdVWATZNT2xYeHw7xYqcBPjDrdVWAT)4dBzzLpm)s0Ahob(H1xsG0GqQ9LmrOqPjT0tjSNYRTNqnKAhonUne4uy4ycWThHdKkh9LmrO1(La42JWbsLJ(sGewG0MqR9lDT142tARo8BpddbNcmZEQHNk2tZt4MUEgLNcdhEYIC7r4aPYrEAypbuoNqEQloid0ZcWtwur0X48Xp(Wwwg(pm)sMi0A)sakIogN)LO1oCc8dRF8JVKOENoo0ANn3gM(W8dBz)W8lrRD4e4hwFjbsdcP2x60bagI6D64qRDawT2VKjcT2VexHFh4jK)oi8hTXp(W(kFy(LO1oCc8dRVuhtZw3kNMcdh6c)dBz)sGewG0MqR9lj)XH(SG88UA5jVw4EcP6D64qR1ZwkN7j3WHNXTTYH9mkpL6RNxf6c)sSNWItySUW9mkpbPGqpDjpVRwEYIkI8ewCdhypX3vNd65H8SJjWXxQA(syk(scKgesTVKOwWUgdDbi0A8PWWcdKg0Ahob(L6yAwaat4cWpSL9lb14D6lD6aadr9oDCO1oq0Z0f7jm880bagI6D64qRDa2rwO16jKZti4POkoy1AhI6D64qRDGONPl2tw65Pdame170XHw7arptxSNq8lzIqR9lb1qQD40xcQHMR9OVeDrqlibof170XHw7erptx8p(W(A(W8lrRD4e4hwFPoMMTUvonfgo0f(h2Y(LajSaPnHw7x6QbbXEg3KNGDKfATEwaEg3KNs91ZRcDHFj2tyXjmwx4EcP6D64qR1ZO8mUjpPf0ZcWZ4M8u0riAdpHu9oDCO16Pc4zCtEkmC4zRQZb9uuVgofKNGDKUW9mUvSNqQENoo0AhFPQ5lzGGFjbsdcP2xsulyxJHUaeAn(uyyHbsdATdNa9KrpHGNNoaWa33PC6chppCcJ1f(ergitJEJNSXMNqnKAhonOlcAbjWPOENoo0ANi6z6I9uEEk7Gv8eY5jCb44zx4jKZti45PdamW9DkNUWXZdNWyDHpE2ftCyc58uM880bag4(oLtx445HtySUWh4WeY5je9eIFPoMMfaWeUa8dBz)sqnEN(sqnKAhonWYDMGDKfATFjteATFjOgsTdN(sqn0CTh9LOlcAbjWPOENoo0ANi6z6I)Xh2YVpm)s0Ahob(H1xsG0GqQ9LoDaGHOENoo0AhGvR9lzIqR9lDm4Zcygivih(hFyZkFy(LO1oCc8dRVKaPbHu7lzIqHstAPNsypLNNY6jJEE6aadr9oDCO1oaRw7xYeHw7xIRq1f(8uVZp(WMH)dZVeT2HtGFy9L6yA26w50uy4qx4Fyl7xsG0GqQ9LKHNIAb7Am0fGqRXNcdlmqAqRD4eONm6P42qWjSNYRTNY6jJEE6aadr9oDCO1o6nEYONYWZthayaOichf6n6nEYONYWZthayCxXehiYKB0B8KrpVRyIdezYnXneNJN6ob4k87Wty45PdamUjl0f(S3m6nEYspVYxQJPzbamHla)Ww2VeiHfiTj0A)sxBnURE4PmFbi0ACpHKHfgiXSNq(74WZoM8Kfve5jS4goWE26MwpJBIjpBv7LHNV(kU9uG0a7PTGE26Mwpzrfr4OqppvSNGvRD8LmrO1(LauenpCdh)4dBgUpm)s0Ahob(H1xQJPzRBLttHHdDH)HTSFjqclqAtO1(LU2AC7PmFbi0ACpHKHfgiXSNSOIipHf3WHNDm5j(U6CqppKNgiOgATgNZKNIAXbY0La9exEg3w4PgEQyp3k88qE2XeON9LtySNY8fGqRX9esgwyGKNk2t7u9WZO8KUOrrKNfYZ4MqKNgI88viYZ42wpPT6WV9Kfve5jS4goWEgLN0fbTGEkZxacTg3tizyHbsEgLNXn5jTGEwaEcP6D64qRD8LQMVeMIVKaPbHu7ljQfSRXqxacTgFkmSWaPbT2HtGFPoMMfaWeUa8dBz)sqnEN(sMi0AhakIMhUHJH42qWj8eazIqR14EcdpHGNqnKAhonOlcAbjWPOENoo0ANi6z6I9uM880bag6cqO14tHHfgina7il0A9eIEYApfvXbRw7aqr08WnCma7il0A)sMi0A)sqnKAho9LGAO5Ap6lrx0qIGaNakIMhUHd8p(W(A9H5xIw7WjWpS(svZxctXxYeHw7xcQHu7WPVeuJ3PVKGuUNqWtOgsTdNg0fbTGe4uuVthhATte9mDXEYApHGNNoaWqxacTgFkmSWaPbyhzHwRNYKNWfGJNDHNq0ti(L6yAwaat4cWpSL9l1X0S1TYPPWWHUW)Ww2VKaPbHu7ljQfSRXqxacTgFkmSWaPbT2HtGFjOgAU2J(slrGe4eqr08WnCG)Xh2mSFy(LO1oCc8dRVuhtZw3kNMcdh6c)dBz)scKgesTVKOwWUgdDbi0A8PWWcdKg0Ahob6jJEkUneCc7P8A7PSEYONqWtOgsTdNg0fnKiiWjGIO5HB4a7P8A7judP2HtJLiqcCcOiAE4goWEYgBEc1qQD40GUiOfKaNI6D64qRDIONPl2tw22ZthayOlaHwJpfgwyG0aSJSqR1t2yZZthayOlaHwJpfgwyG0ahMqopzPNxXt2yZZthayOlaHwJpfgwyG0arptxSNS0t4cWXZUWt2yZtrvCWQ1oW3kqOl8zt1IqdezGm5jJEAIqHstAPNsypLxBpHAi1oCAiQ3PJdT2j(wbcDHpBQweYtg9uuqP12ySk87ycyKNq0tg980bagI6D64qRD0B8KrpHGNYWZthayaOichf6n6nEYgBEE6aadDbi0A8PWWcdKgi6z6I9KLEE9bR4je9KrpLHNNoaW4UIjoqKj3O34jJEExXehiYKBIBiohp1DcWv43HNWWZthayCtwOl8zVz0B8KLEELVuhtZcaycxa(HTSFjteATFjafrZd3WXp(Ww2R)H5xIw7WjWpS(sMi0A)scJZNMi0ANCfhFjUIJ5Ap6lzIqHsZW40g4F8HTSY(H5xIw7WjWpS(sDmnBDRCAkmCOl8pSL9ljqAqi1(sNoaWquVthhATdWQ16jJEc1qQD40i0hnJAkQ3PJdTwpzzBpVUNm6je8ugEI6lbui40auXcTHRRHyAkQ3ZwWbT2HtGEYgBEE6aadqfl0gUUgIPPOEpBbh9gpzJnppDaGbOIfAdxxdX0uuVNTGtauHJrVXtg9mmoTXa1xAwaZMQfHg0Ahob6jJEkQIdwT2XPdambvSqB46AiMMI69SfCGidKjpHONm6je8ugEI6lbui40aosXCMMQqfCAqRD4eONSXMNG0PdamGJumNPPkubNg9gpHONm6je8ugEkkO0ABmwsGkEHa9Kn28uufhSATdqYI7tHwAGONPl2t2yZZthayaswCFk0sJEJNq0tg9ecEAIqRD8OGk0q3jaxHFhEYONMi0AhpkOcn0DcWv43XerptxSNSSTNqnKAhone170XHw7uy4yIONPl2t2yZtteATdSOqI7bDbj6HUW9KrpnrO1oWIcjUh0fKOh0erptxSNS0tOgsTdNgI6D64qRDkmCmr0Z0f7jBS5PjcT2bGIOJX5d6cs0dDH7jJEAIqRDaOi6yC(GUGe9GMi6z6I9KLEc1qQD40quVthhATtHHJjIEMUypzJnpnrO1oAycvhUHJbDbj6HUW9KrpnrO1oAycvhUHJbDbj6bnr0Z0f7jl9eQHu7WPHOENoo0ANcdhte9mDXEYgBEAIqRDaWThHdKkhnOlirp0fUNm6PjcT2ba3EeoqQC0GUGe9GMi6z6I9KLEc1qQD40quVthhATtHHJjIEMUypH4xQJPzbamHla)Ww2VKjcT2VKOENoo0A)Xh2YELpm)s0Ahob(H1xcKWcK2eATFjwvCtipfvXbRwl2Z42cpX3vNd65H8SJjqpBPXTNqQENoo0A9eFxDoON1YzYZd5zhtGE2sJBpT1tteDJ7jKQ3PJdTwpfgo80wqp3k8SLg3EAEk1xpVk0f(LypHfNWyDH7zdQeJVKjcT2VKW48PjcT2jxXXxsG0GqQ9LoDaGHOENoo0Ahi6z6I9uEEET8Kn28uufhSATdr9oDCO1oq0Z0f7jl9Kv(sCfhZ1E0xsuVthhATtrvCWQ1I)Xh2YEnFy(LO1oCc8dRVKaPbHu7lbbppDaGXDftCGitUrVXtg90eHcLM0spLWEkV2Ec1qQD40quVthhATtaU9iCGu5ipHONSXMNqWZthayaOichf6n6nEYONMiuO0Kw6Pe2t512tOgsTdNgI6D64qRDcWThHdKkh5Pm5jQVeqHGtdafr4OqVbT2HtGEcXVKjcT2Vea3EeoqQC0p(Www53hMFjATdNa)W6ljqAqi1(sNoaWa33PC6chppCcJ1f(ergitJEJNm65PdamW9DkNUWXZdNWyDHprKbY0arptxSNYZtHHJzOp6lzIqR9l1WeQoCdh)4dBzzLpm)s0Ahob(H1xsG0GqQ9LoDaGbGIiCuO3O38LmrO1(LAycvhUHJF8HTSm8Fy(LO1oCc8dRVKaPbHu7lD6aaJgMqLGB43O34jJEE6aaJgMqLGB43arptxSNYZtHHJzOpYtg9ecEE6aadr9oDCO1oq0Z0f7P88uy4yg6J8Kn2880bagI6D64qRDawTwpHONm6PjcfknPLEkH9KLEc1qQD40quVthhATtaU9iCGu5OVKjcT2VudtO6WnC8JpSLLH7dZVeT2HtGFy9LeiniKAFPthayCxXehiYKB0B8KrppDaGHOENoo0Ah9MVKjcT2VudtO6WnC8JpSL9A9H5xIw7WjWpS(scKgesTVudIGoHlahYoWIcjU9KrppDaGXnzHUWN9MrVXtg90eHcLM0spLWEYspHAi1oCAiQ3PJdT2ja3EeoqQC0xYeHw7xQHjuD4go(Xh2YYW(H5xIw7WjWpS(sMi0A)s4Bfi0f(SPArOVKUbHq9MyQaFjteATdafrZd3WXqCBi4eUTjcT2bGIO5HB4y8SlMIBdbNWFjqclqAtO1(LyyW6c3tPBfi0fUNYx1IqEc2r6c3tivVthhATEgLNichfI8Kfve5jS4go80wqpLV7Iw9cpzrU9ipf3gcoH9uyRNhYZdTeGkuJZSNNE4zh3noNjpRLZKN165vxY)XxsG0GqQ9LoDaGHOENoo0Ah9gpz0tz4PjcT2bGIO5HB4yiUneCc7jJEAIqHstAPNsypLxBpHAi1oCAiQ3PJdT2j(wbcDHpBQweYtg90eHw7O5UOvVycWThHhaDoFIiXTHGtZqFKNYZtGoNpreyxeAT)4d7RC9pm)s0Ahob(H1xsG0GqQ9LoDaGHOENoo0Ah9gpz0Zazqj(m0h5jl980bagI6D64qRDGONPl2tg9ecEcbpnrO1oauenpCdhdXTHGtypzPNY6jJEggN2y0WeQeCd)g0Ahob6jJEAIqHstAPNsypB7PSEcrpzJnpLHNHXPngnmHkb3WVbT2HtGEYgBEAIqHstAPNsypLNNY6je9KrppDaGXnzHUWN9MrVXty45DftCGitUjUH4C8u3jaxHFhEYspVYxYeHw7xQ5UOvVycWThH)Xh2xr2pm)s0Ahob(H1xsG0GqQ9LoDaGHOENoo0AhGvR1tg9uufhSATdr9oDCO1oq0Z0f7jl9uy4yg6J8KrpnrOqPjT0tjSNYRTNqnKAhone170XHw7eGBpchivo6lzIqR9lbWThHdKkh9JpSVYv(W8lrRD4e4hwFjbsdcP2x60bagI6D64qRDawTwpz0trvCWQ1oe170XHw7arptxSNS0tHHJzOpYtg9ugEkQfSRXaGBpAAcbIcT2bT2HtGFjteATFjafrhJZ)Xh2x5A(W8lrRD4e4hwFjbsdcP2x60bagI6D64qRDGONPl2t55PWWXm0h5jJEE6aadr9oDCO1o6nEYgBEE6aadr9oDCO1oaRwRNm6POkoy1AhI6D64qRDGONPl2tw6PWWXm0h9LmrO1(LWIcjU)Xh2xr(9H5xIw7WjWpS(scKgesTV0Pdame170XHw7arptxSNS0t4cWXZUWtg90eHcLM0spLWEkppL9lzIqR9lXvO6cFEQ35hFyFfw5dZVeT2HtGFy9LeiniKAFPthayiQ3PJdT2bIEMUypzPNWfGJNDHNm65Pdame170XHw7O38LmrO1(Larg8AXZdIS4(h)4hFjOecR1(H9vU(vK96xZ1z4(sTm0QlC8x6AF1xvylZHnRod6PNW8M8uFnfk8eOqEEPOENoo0ANH(0f(LEIigsxreON46rEA9OEwqGEkUTfoHho7mGUKNYYGEcPAHsOGa98YW40gdi7spJYZldJtBmGSbT2HtGx6jeK9cioC2zaDjpVgg0tivlucfeONxggN2yazx6zuEEzyCAJbKnO1oCc8spHGSxaXHZodOl551Ib9es1cLqbb65LHXPngq2LEgLNxggN2yazdATdNaV0tii7fqC4SZa6sEYWYGEcPAHsOGa98YW40gdi7spJYZldJtBmGSbT2HtGx6jeK9cioC2zaDjpLvwg0tivlucfeONxI6lbui40aYU0ZO88suFjGcbNgq2Gw7WjWl9ecYEbeho7mGUKNYk)yqpHuTqjuqGEEzyCAJbKDPNr55LHXPngq2Gw7WjWl9ecYEbeho7o7x7R(QcBzoSz1zqp9eM3KN6RPqHNafYZlrvZS52W0LEIigsxreON46rEA9OEwqGEkUTfoHho7mGUKNScd6jKQfkHcc0ZldJtBmGSl9mkpVmmoTXaYg0AhobEPNqq2lG4WzNb0L8KHNb9es1cLqbb65LO(safconGSl9mkpVe1xcOqWPbKnO1oCc8spHWvUaIdNDN9R9vFvHTmh2S6mONEcZBYt91uOWtGc55LGeG15XLEIigsxreON46rEA9OEwqGEkUTfoHho7mGUKNYYGEcPAHsOGa98suFjGcbNgq2LEgLNxI6lbui40aYg0AhobEPNw4P8NvXaEcbzVaIdNDgqxYZRHb9es1cLqbb65LHXPngq2LEgLNxggN2yazdATdNaV0tii7fqC4SZa6sEk71WGEcPAHsOGa9usFqYtmtByx4jRgRMNr5jd0npFfyN3XEwneYIc5jey1GONqq2lG4WzNb0L8u2RHb9es1cLqbb65LIAb7AmGSl9mkpVuulyxJbKnO1oCc8spHGSxaXHZodOl5PSYpg0tivlucfeONxgiDLJIHSdi7spJYZldKUYrXiKDazx6jeUMlG4WzNb0L8uw5hd6jKQfkHcc0ZldKUYrX4kdi7spJYZldKUYrXiUYaYU0tiCnxaXHZodOl5PSScd6jKQfkHcc0Zlf1c21yazx6zuEEPOwWUgdiBqRD4e4LEcbzVaIdNDgqxYtzz4yqpHuTqjuqGEEjQVeqHGtdi7spJYZlr9LakeCAazdATdNaV0tii7fqC4SZa6sEk71Ib9es1cLqbb65LO(safconGSl9mkpVe1xcOqWPbKnO1oCc8spHGSxaXHZodOl5PSmSmONqQwOekiqpVmmoTXaYU0ZO88YW40gdiBqRD4e4LEcbzVaIdNDgqxYtzzyzqpHuTqjuqGEEjQVeqHGtdi7spJYZlr9LakeCAazdATdNaV0tii7fqC4SZa6sEELRZGEcPAHsOGa98suFjGcbNgq2LEgLNxI6lbui40aYg0AhobEPNqq2lG4WzNb0L88kxdd6jKQfkHcc0tj9bjpXmTHDHNSAEgLNmq38euHQyTwpRgczrH8ecSgIEcHR5cioC2zaDjpVY1WGEcPAHsOGa9usFqYtmtByx4jRgRMNr5jd0npFfyN3XEwneYIc5jey1GONqq2lG4WzNb0L88kYpg0tivlucfeONxI6lbui40aYU0ZO88suFjGcbNgq2Gw7WjWl9ecYEbeho7mGUKNxHvyqpHuTqjuqGEEjQVeqHGtdi7spJYZlr9LakeCAazdATdNaV0tii7fqC4SZa6sEEfgog0tivlucfeONxggN2yazx6zuEEzyCAJbKnO1oCc8spHGSxaXHZUZ(1(QVQWwMdBwDg0tpH5n5P(Aku4jqH88YgejQ3XIl9ermKUIiqpX1J806r9SGa9uCBlCcpC2zaDjpVcd6jKQfkHcc0ZldJtBmGSl9mkpVmmoTXaYg0AhobEPNw4P8NvXaEcbzVaIdNDgqxYZRHb9es1cLqbb65LHXPngq2LEgLNxggN2yazdATdNaV0tii7fqC4SZa6sEEnmONqQwOekiqpVmmoTXaYU0ZO88YW40gdiBqRD4e4LEAHNYFwfd4jeK9cioC2zaDjpLFmONqQwOekiqpVmmoTXaYU0ZO88YW40gdiBqRD4e4LEcbzVaIdNDgqxYt5hd6jKQfkHcc0ZldJtBmGSl9mkpVmmoTXaYg0AhobEPNw4P8NvXaEcbzVaIdNDgqxYtwHb9es1cLqbb65LHXPngq2LEgLNxggN2yazdATdNaV0tii7fqC4SZa6sEYkmONqQwOekiqpVmmoTXaYU0ZO88YW40gdiBqRD4e4LEAHNYFwfd4jeK9cioC2zaDjpz4zqpHuTqjuqGEEzyCAJbKDPNr55LHXPngq2Gw7WjWl9ecYEbeho7mGUKNm8mONqQwOekiqpVmmoTXaYU0ZO88YW40gdiBqRD4e4LEAHNYFwfd4jeK9cioC2zaDjpLLHLb9es1cLqbb65LHXPngq2LEgLNxggN2yazdATdNaV0tl8u(ZQyapHGSxaXHZUZ(1(QVQWwMdBwDg0tpH5n5P(Aku4jqH88sr9oDCO1ofvXbRwl(spredPRic0tC9ipTEupliqpf32cNWdNDgqxYtgEg0tivlucfeONxI6lbui40aYU0ZO88suFjGcbNgq2Gw7WjWl9ecYEbeho7o7x7R(QcBzoSz1zqp9eM3KN6RPqHNafYZlnrOqPzyCAd8LEIigsxreON46rEA9OEwqGEkUTfoHho7mGUKNxHb9es1cLqbb65LHXPngq2LEgLNxggN2yazdATdNaV0tiCLlG4WzNb0L88AyqpHuTqjuqGEEzyCAJbKDPNr55LHXPngq2Gw7WjWl9ecYEbeho7o7x7R(QcBzoSz1zqp9eM3KN6RPqHNafYZlXHTGgcCIQWcT2l9ermKUIiqpX1J806r9SGa9uCBlCcpC2zaDjpzfg0tivlucfeONxggN2yazx6zuEEzyCAJbKnO1oCc8spHGSxaXHZodOl551Ib9es1cLqbb65LO(safconGSl9mkpVe1xcOqWPbKnO1oCc8spHWvUaIdNDgqxYtzVod6jKQfkHcc0ZldJtBmGSl9mkpVmmoTXaYg0AhobEPNqq2lG4Wz3z)AF1xvylZHnRod6PNW8M8uFnfk8eOqEEPOENoo0ANn3gMU0teXq6kIa9expYtRh1Zcc0tXTTWj8WzNb0L88kmONqQwOekiqpVuulyxJbKDPNr55LIAb7AmGSbT2HtGx6PfEk)zvmGNqq2lG4WzNb0L88AyqpHuTqjuqGEEPOwWUgdi7spJYZlf1c21yazdATdNaV0tii7fqC4SZa6sEYWZGEcPAHsOGa98srTGDngq2LEgLNxkQfSRXaYg0AhobEPNqq2lG4WzNb0L8KHJb9es1cLqbb6PK(GKNyM2WUWtwnpJYtgOBEcQqvSwRNvdHSOqEcbwdrpHGSxaXHZodOl5jdhd6jKQfkHcc0Zlf1c21yazx6zuEEPOwWUgdiBqRD4e4LEAHNYFwfd4jeK9cioC2zaDjpVwmONqQwOekiqpL0hK8eZ0g2fEYQ5zuEYaDZtqfQI1A9SAiKffYtiWAi6jeK9cioC2zaDjpVwmONqQwOekiqpVuulyxJbKDPNr55LIAb7AmGSbT2HtGx6PfEk)zvmGNqq2lG4WzNb0L8KHLb9es1cLqbb65LIAb7AmGSl9mkpVuulyxJbKnO1oCc8spHGSxaXHZodOl5PSYYGEcPAHsOGa98YW40gdi7spJYZldJtBmGSbT2HtGx6jeK9cioC2zaDjpLvwg0tivlucfeONxI6lbui40aYU0ZO88suFjGcbNgq2Gw7WjWl9ecx5cioC2zaDjpL9AyqpHuTqjuqGEEjQVeqHGtdi7spJYZlr9LakeCAazdATdNaV0tii7fqC4SZa6sEELRZGEcPAHsOGa98YW40gdi7spJYZldJtBmGSbT2HtGx6jeUYfqC4SZa6sEELRWGEcPAHsOGa98srTGDngq2LEgLNxkQfSRXaYg0AhobEPNw4P8NvXaEcbzVaIdNDNDz(RPqbb651YtteATEYvCGho7FjCdj(WMH)A(snOcq50xIfybpzrfrEEvAWjNDwGf88oIgmdYAwdxJ7(ziQhRX6RZTqRvGmGG1y9jyTZolWcEEvAiXTNYEDM98kx)kY6S7SZcSGNq62w4eMbD2zbwWtzYtggm5jGc)oMi6z6I9ezXnH8mUT1ZWqWPye6JMrnbvYtGc5j3WHmHjrTGEAhLRbtE2XgCcpC2zbwWtzYtgOkmTEkmC4jIyiDfrpAdSNafYtivVthhATEcbDqdM9eS2ldpVloONA4jqH808ear4BpVkPGkKNcdhqC4SZcSGNYKNY)1oCYtCGur4P4MeYPlCpR1tZtaQLNafsoSN66zCtEE1Yhd4zuEIiWUG8SvHKJxg4WzNfybpLjpVAqi)DC4P5P8XeQoCdhEsBGyYZ42cpblc75wHNVcK4E2I4Cp1vMGBpYtiG1NNbHdc0tl8ClpXk8vbuHTHNmu5tYt91yIaIdNDwGf8uM8es1cLqHNgN75PdamGSbImr4jTbsjSNr55PdamGSrVHzpT1tJ)kC4PUyf(QaQW2WtgQ8j5jCtxp11tS(WdNDNDwGf8u(Fbj6bb65Hake5POEhl88qW1fp88QfcQjWEU1kt3g6b05EAIqRf7zTCMgo7Mi0AXJgejQ3Xcy0M1gsyln1nioNeHZolWcEE1Yhd4PmZqQD4KNSQMqRLb9uMd4jMcpJYtZZTwzcYhcvEc14DIzpJBYtivVthhATEAIqR1tBb9uufhSATypJBl80qKNIAXbY0La9mkpRLZKNhYZoMa9S1nTEcP6D64qR1tf7zVXZwkN75wHNhYZoMa9eSJ0fUNXn5jwFDUfATdNDwGf80eHwlE0Gir9owaJ2SgQHu7WjMx7rTbvSD40uuVthhATmxnTreMcNDwWZRw(yapLzgsTdN8Kv1eATmONW8wXEc1qQD4KN4gsOakH9S1nf3eYtivVthhATEIVRoh0Zd5zhtGEc2r6c3twureomuqOHZUjcTw8ObrI6DSagTznudP2HtmV2JAdOichgki0uuVthhATmRaTHAi1oCAaOichgki0uuVthhATS86md14DQTSqozegN2y0WeQeCd)ygQX70K4yQTmjRZol45vlFmGNYmdP2HtEYQAcTwg0tyERypHAi1oCYtCdjuaLWEg3KNB)DiKNfGNHHGtb2tl8S1TkU9eYRcpLcezY5jlYThHdKkhH9S6bwbjplapHu9oDCO16j(U6CqppKNDmboC2nrO1IhnisuVJfWOnRHAi1oCI51Eu77kM4arMCtaU9iCGu5iMRM2ykywbAd1qQD404UIjoqKj3eGBpchivoQ91zgQX7u7Ra5cJtBma42JMnwiUHX1a5KryCAJba3E0SXcXTZol45vlFmGNYmdP2HtEYQAcTwg0tyERypHAi1oCYtCdjuaLWEg3KNB)DiKNfGNHHGtb2tl8S1TkU9eYZqGEcjdhEYIC7r4aPYrypREGvqYZcWtivVthhATEIVRoh0Zd5zhtGEAypbuoNqdNDteAT4rdIe17ybmAZAOgsTdNyETh1(2qGtHHJja3EeoqQCeZvtBmfmRaTHAi1oCACBiWPWWXeGBpchivoQ91zgQX7u7Ra5cJtBma42JMnwiUHX1a5KryCAJba3E0SXcXTZol45vlFmGNYmdP2HtEYQAcTwg0tyERypHAi1oCYtCdjuaLWEg3KNB)DiKNfGNHHGtb2tl8S1TkU9eYRcpLcezY5jlYThHdKkhH90qKNDmb6jyhPlCpHu9oDCO1oC2nrO1IhnisuVJfWOnRHAi1oCI51EuBr9oDCO1ob42JWbsLJyUAAJPGzfOnudP2Htdr9oDCO1ob42JWbsLJAFDMHA8o1(AGCHXPngaC7rZgle3WGHhYjJW40gdaU9OzJfIBNDwWZRw(yapLzgsTdN8Kv1eATmONW8wXEc1qQD4KN4gsOakH9mUjp3(7qiplapddbNcSNw4zRBvC75vJe2sEk)VOHxyTwpREGvqYZcWtivVthhATEIVRoh0Zd5zhtGdNDteAT4rdIe17ybmAZAOgsTdNyETh12qcBPjDrdVWATmxnTXuWSc0gQHu7WPHHe2st6IgEH1ABFDMHA8o1MHLHfYfgN2yaWThnBSqCdJRa5KryCAJba3E0SXcXTZol45vlFmGNYmdP2HtEYQAcTwg0tyERypHAi1oCYtCdjuaLWEg3KNnesqByWjplapF2AEEiE1YZw3Q42ZRgjSL8u(FrdVWATE2s5Cp3k88qE2Xe4Wz3eHwlE0Gir9owaJ2SgQHu7WjMx7rTnKWwAsx0WlSw78zRXmibyDE0w(DDMRM2ictHZol45vlFmGNYmdP2HtEYQAcTwg0ZRTg3EEvOlixx4m7jKQ3PJdT2lXEkQIdwTwpBPCUNhYteb2feONhM808ezly980EvFdM980dpJBYZT)oeYZcWtbsdSN4Wqb2tOeIjpVv43EAabH80eHc1cDH7jKQ3PJdTwpTf0tmVAH9eSATEgvldbI9mUjpPf0ZcWtivVthhATxI9uufhSATdpV23065ZKtx4EcscfR1I9uxpJBYZRw(yaM9es170XHw7Lypr0Z0vx4EkQIdwTwpvSNicSliqppm5zCRypbqMi0A9mkpnHO6B4jqH88QqxqUUWho7Mi0AXJgejQ3Xcy0M1qnKAhoX8ApQTC6cY1f(erGDrO1YmibyDE0(6d5hZvtBeHPWzNf88QLpgWtzMHu7WjpzvnHwld6jmVjp3(7qiplapddbNcSNs3kqOlCpLVQfH8eFxDoONhYZoMa9Swpb7iDH7jKQ3PJdT2HZUjcTw8ObrI6DSagTznudP2HtmV2JAlQ3PJdT2j(wbcDHpBQweIzqcW68O9vyUAAJimfo7SGNxT8XaEkZmKAho5jRQj0AzqpH5n5zOpYte9mD1fUN16P5PWWHNTUP1tivVthhATEkS1Zd5zhtGEQRNysuliE4SBIqRfpAqKOEhlGrBwd1qQD4eZR9O2I6D64qRDkmCmr0Z0fZmibyDE0(6dgoMRM2ictHZol45vlFmGNYmdP2HtEYQAcTwg0tyERypHAi1oCYtCdjuaLWEg3KNB)DiKNfGNysuli2ZcWtwurKNWIB4WZ42cpX3vNd65H8SPkob6zJHdpJBYtqcW68Wt7v9ngo7Mi0AXJgejQ3Xcy0M1qnKAhoX8ApQDbLqnvXNakIMhUHdmZGeG15r7RZC10grykC2zbpVA5Jb8uMzi1oCYtwvtO1YGEc5vT8KxlCppeqHipHu9oDCO16j(U6CqpL)VgMqKX9KvHaxBfKNhYZoMaH81z3eHwlE0Gir9owaJ2SgQHu7WjMx7rTPxdtiY4ZcbU2kOjiXnMygKaSopAl71I5QPnIWu4SZcEkZb8es170XHwRNk2tqfBhobYSNyXnb25KNXn5jGIWHNqQENoo0A9eWqEAabH8mUjpbu43HN0cIho7Mi0AXJgejQ3Xcy0M1qnKAhoX8ApQDOpAg1uuVthhATmd14DQnGc)oMi6z6IHHSx)6mRaTHAi1oCAaQy7WPPOENoo0AD2zbpH5n5jyhzHwRNfGNMNs91ZRcDHFj2tyXjmwx4EcP6D64qRD4SBIqRfpAqKOEhlGrBwd1qQD4eZR9O2y5otWoYcTwMRM2ykygQX7uBwXzNf88AFtXnH808SJTdN8ud65zhtGEgLNNoaGNqQENoo0A9uXEsmKU20qGdNDteAT4rdIe17ybmAZAOgsTdNyETh1wuVthhATZANDmXC10gtbZqnENAtmKU20qGd4CduTOq45XaHtSXgXq6AtdboEMWoiAIVjkMVowfSXgXq6Atdbo0flq9WoCAYq62g93eKGQcIn2igsxBAiWbUVhEvGt7rXnt4Gn2igsxBAiWb9AycrgFwiW1wbXgBedPRnne4aGBpAwaZJfbNyJnIH01MgcC0YKJwcHNaOAbzJnIH01MgcCOloqDrui8euHQlnpeN7SZcEc5vT8KxlCppeqHipHu9oDCO16j(U6CqpdKUYrb2Z42cpdKchoH808eFBic0tHfe8cXKNIQ4GvR1ZA9SIBc5zG0vokWEUv45H8SJjqiFD2nrO1IhnisuVJfWOnRHAi1oCI51Eu7ANDmnf9OaayUAAJPGzOgVtTVY1zwbAd1qQD40quVthhATZANDm5SBIqRfpAqKOEhlGrBwd1qQD4eZR9O21o7yAk6rbaWC10gtbZqnENAFfwHzfOnXq6AtdboEMWoiAIVjkMVowfo7Mi0AXJgejQ3Xcy0M1qnKAhoX8ApQDTZoMMIEuaamxnTXuWmuJ3P2x56WaQHu7WPb9AycrgFwiW1wbnbjUXeZkqBIH01MgcCqVgMqKXNfcCTvqo7Mi0AXJgejQ3Xcy0M1Dmn1GEmV2JAJRoFQWxnieZkqBza1qQD40quVthhATZANDmXOmigsxBAiWbiImqafrtOegtCgLryCAJbGIiCyOGqo7Mi0AXJgejQ3Xcy0M1pfHk0uFgCYz3eHwlE0Gir9owaJ2SUHjuD4goywbAlJgebD0WeQoCdho7o7Sal4P8)cs0dc0tckHyYZqFKNXn5PjIc5PI90GAk3oCA4SBIqRf3wu9nieUH4CMvG2Ya1xcOqWPbOIfAdxxdX0uuVNTGo7SGNW8M8uuVthhATZqF6c3tteATEYvC4jwCtGDoH9S1nTEcP6D64qR1ZwkN75H8SJjqpTf0tCuic7zCtEIiCNhEQRNqnKAhonc9rZOMI6D64qRD4SBIqRfdJ2SwyC(0eHw7KR4G51EuBr9oDCO1od9PlCNDwWtzMHu7WjpJBl8KWH(SGWE26MIBc5P0Tce6c3t5RAripBPCUNhYZoMa98qafI8es170XHwRNk2tezGmnC2nrO1IHrBwd1qQD4eZR9O24Bfi0f(SPArO5Hakenf170XHwlZvtBmfmd14DQnemrOqPjT0tjmlHAi1oCAiQ3PJdT2j(wbcDHpBQweIn2mrOqPjT0tjmlHAi1oCAiQ3PJdT2ja3EeoqQCeBSb1qQD40i0hnJAkQ3PJdTwzYeHw7aFRaHUWNnvlcna6C(erGDrO1kprvCWQ1oW3kqOl8zt1IqdWoYcTwiYiudP2HtJqF0mQPOENoo0ALjrvCWQ1oW3kqOl8zt1Iqde9mDXYZeHw7aFRaHUWNnvlcna6C(erGDrO1YieevXbRw7a1xAwaZMQfHgi6z6ILjrvCWQ1oW3kqOl8zt1Iqde9mDXYJvyJnzegN2yG6lnlGzt1Iqq0z3eHwlggTzn(wbcDHpBQweIzfO9Pdame170XHw7aSATmAIqRDaOiAE4gogIBdbNWSSTSmkdiC6aadDbi0A8PWWcdKg9ggpDaGXDftCGitUbImrargHAi1oCAGVvGqx4ZMQfHMhcOq0uuVthhATo7Mi0AXWOnRrgOABmXngsoMvG2NoaWquVthhATdWQ1YieGAi1oCAe6JMrnf170XHwllHAi1oCAiQ3PJdT2zdIegoMH(iyqxqIEqZqFeBSb1qQD40i0hnJAkQ3PJdTw5jQIdwTwzs2RdrNDteATyy0M1GKf3NcTeZkq7thayiQ3PJdT2by1Az80bagO(sZcy2uTi0aSATmc1qQD40i0hnJAkQ3PJdTwwc1qQD40quVthhATZgejmCmd9rWGUGe9GMH(iNDteATyy0M1pfHkeEwaZOqpAdMvG2qnKAhonc9rZOMI6D64qRLLqnKAhone170XHw7SbrcdhZqFemOlirpOzOpIXthayiQ3PJdT2by1AD2zbpzXc5PmJ24MjeZE2XKNMNSOIipHf3WHNIBdbN8eSJ0fUNxLkcviSNfGNWSqpAdpfgo8mkpnOLc6PWAA0fUNIBdbNWdNDteATyy0M1akIMhUHdM7yA26w50uy4qx4TLLzfOTjcT2XtrOcHNfWmk0J2yqxqIEOlCgb6C(erIBdbNMH(izYeHw74PiuHWZcygf6rBmOlirpOjIEMUywk)yug3vmXbIm5M4gIZXtDNaCf(DWOmoDaGXDftCGitUrVXz3eHwlggTzDhttnOhZeaajI5ApQnCUbQwui88yGWjMvG2qnKAhonc9rZOMI6D64qRvEIQ4GvRvMyfNDteATyy0M1Dmn1GEmV2JAtVgMqKXNfcCTvqmRaTHAi1oCAe6JMrnf170XHwllBd1qQD40GEnmHiJple4ARGMGe3yIrOgsTdNgH(Ozutr9oDCO1kpOgsTdNg0RHjez8zHaxBf0eK4gtYeR4SBIqRfdJ2SUJPPg0J51EuB4CMAUNfW0Wy9PCl0AzwbAd1qQD40i0hnJAkQ3PJdTw51gQHu7WPrTZoMMIEuaao7Mi0AXWOnR7yAQb9yETh1(zc7GOj(MOy(6yvWSc0gQHu7WPrOpAg1uuVthhATSSnR4SZcEkZb8SJ1fUNMN4GqLc6zTYuhtEQb9y2tJ3Yyc7zhtEYqrKbcOiYtzgHXe3ZQhyfK8Sa8es170XHw7WtwvCtOwkMy2ZgKwinuiFip7yDH7jdfrgiGIipLzegtCpBPXTNqQENoo0A9SwotEQaEkZxacTg3tizyHbsEQypP1oCc0tBb908SJn4KNTQ9YWZd5jVWHNfuc5zCtEc2rwO16zb4zCtEcOWVJHNW8wXEAGGypnpXpJZ9eQX7KNr5zCtEkQIdwTwplapzOiYabue5PmJWyI7zRBA9eS0fUNXTI9uyCrNBHwRNhsyDm5PgEQyp7lImoouHNr5PHX9h5zCBHNA4zlLZ98qE2XeONnecGebNjpR1trvCWQ1oC2nrO1IHrBw3X0ud6X8ApQniImqafrtOegtCMvG2qnKAhonc9rZOMI6D64qRvETHAi1oCAu7SJPPOhfaaJq40bag6cqO14tHHfginWHjKR9Pdam0fGqRXNcdlmqA8SlM4WeYXgBYqulyxJHUaeAn(uyyHbsSXgudP2Htdr9oDCO1oRD2XeBSb1qQD40i0hnJAkQ3PJdTw5PBqOMIBbbobu43XerptxmRgRgeevXbRwlmK96qeIo7Sal4jSPwEkvDUNYC4RgeYtAdetm7jI4kH9SwpX3gIa9ud65jKyOEQlqHEwO16zCBHNk2ZTcpzIcpX9MMcfe4WtpVQud3ee2Z4M8Sbrq1QJ9KRl5zRBA9eOVIqR14dNDteATyy0M1Dmn1GEmV2JAJRoFQWxnieZkqBia1qQD40i0hnJAkQ3PJdTw51(AUoKdcqnKAhonQD2X0u0JcaqExhISXgeKrG0vokgYou8axD(uHVAqigdKUYrXq2rhBhoXyG0vokgYoevXbRw7arptxmBSjJaPRCumUYqXdC15tf(QbHymq6khfJRm6y7WjgdKUYrX4kdrvCWQ1oq0Z0fdriYieKbXq6AtdboarKbcOiAcLWyIZgBIQ4GvRDaIideqr0ekHXeFEnYpg2RfRWWnq0Z0flpwbIo7SGNWePWHtipLQo3tzo8vdc5jziotE2sJBpL5laHwJ7jKmSWajplKNTUP1tn8SLH9SbrcdhdNDteATyy0M1cBfeFE6aamV2JAJRoFQWxn0AzwbAldrTGDng6cqO14tHHfgiXyOpILScBSD6aadDbi0A8PWWcdKg4WeY1(0bag6cqO14tHHfginE2ftCyc5C2zbpL5b9WEg3w4jy55wHNhAjan8es170XHwRN47QZb9eYFhhEEip7yc0ZQhyfK8Sa8es170XHwRNw4jUEKNnLUXWz3eHwlggTzDhttnOhMzfOnudP2HtJqF0mQPOENoo0ALxBOgsTdNg1o7yAk6rba4SZcEYWGjpzruHdpHDb18mkpdKchoH8KvhPyotEkZfQGtdNDteATyy0M1aOchZTGAmRaTr9LakeCAahPyottvOcoX4Pdame170XHw7aSATmcbOgsTdNgH(Ozutr9oDCO1kprvCWQ1YgBqnKAhonc9rZOMI6D64qRLLqnKAhone170XHw7SbrcdhZqFemOlirpOzOpcIo7SGNS6u4zCtEYqvSqB46AiM8es17zlONNoaGN9gM9SVCcJ9uuVthhATEQypXvTdNDteATyy0M1IQVbHWneNZSc0g1xcOqWPbOIfAdxxdX0uuVNTGmkQIdwT2XPdambvSqB46AiMMI69SfCGONPlMLMi0AhaOchNIhdHHJzOpIXthayaQyH2W11qmnf17zl40qcBPby1AzugNoaWauXcTHRRHyAkQ3ZwWrVHria1qQD40i0hnJAkQ3PJdTw5jQIdwT2XPdambvSqB46AiMMI69SfCa2rwO1YgBqnKAhonc9rZOMI6D64qRLLSceD2nrO1IHrBwBiHT0KUOHxyTwMvG2O(safconavSqB46AiMMI69SfKrrvCWQ1ooDaGjOIfAdxxdX0uuVNTGde9mDXSKUGe9GMH(iyyIqRDaGkCCkEmegoMH(igpDaGbOIfAdxxdX0uuVNTGtdjSLgGvRLrzC6aadqfl0gUUgIPPOEpBbh9ggHaudP2HtJqF0mQPOENoo0ALNOkoy1AhNoaWeuXcTHRRHyAkQ3ZwWbyhzHwlBSb1qQD40i0hnJAkQ3PJdTwwYkmkJW40gduFPzbmBQwecIo7Mi0AXWOnRbqfoofpywbAJ6lbui40auXcTHRRHyAkQ3ZwqgfvXbRw740baMGkwOnCDnettr9E2coq0Z0fZsHHJzOpIXthayaQyH2W11qmnf17zl4eav4yawTwgLXPdamavSqB46AiMMI69SfC0ByecqnKAhonc9rZOMI6D64qRvEIQ4GvRDC6aatqfl0gUUgIPPOEpBbhGDKfATSXgudP2HtJqF0mQPOENoo0AzjRarNDteATyy0M1cJZNMi0ANCfhmV2JAlQ3PJdT2zZTHjMvG2qnKAhonc9rZOMI6D64qRLLTVoBSb1qQD40i0hnJAkQ3PJdTwwc1qQD40quVthhATZgejmCmd9rmkQIdwT2HOENoo0Ahi6z6IzjudP2Htdr9oDCO1oBqKWWXm0h5SBIqRfdJ2Sg1xAwaZMQfHywbAF6aaduFPzbmBQweAawTwgLXPdamaueHJc9g9ggHaudP2HtJqF0mQPOENoo0ALx7thayG6lnlGzt1IqdWoYcTwgHAi1oCAe6JMrnf170XHwR8mrO1oauenpCdhdGoNprK42qWPzOpIn2GAi1oCAe6JMrnf170XHwR8au43XerptxmeD2zbpLVQ4EAypF2YKNSOIipHf3Wb2td7ztHX6HtEcuipHu9oDCO1o8uQFcKjcpRE4zb4zCtEcGmrO1ACpf1RPwAdplapJBYZT)oeYZcWtwurKNWIB4a7zCBHNTuo3Z1IoY4CM8erIBdbN8eSJ0fUNXn5jKQ3PJdTwpBUnm55HewhtE2ufxx4EAltXTUW9SXWHNXTfE2s5Cp3k8eoY2WtB9KUiqMNSOIipHf3WHNGDKUW9es170XHw7Wz3eHwlggTznudP2Htm3X0SaaMWfGTLL5oMMTUvonfgo0fEBzzETh1gqr08WnCmBQIRlCMHA8o12eHw7aqr08WnCme3gcoHNaiteATghgqaQHu7WPrOpAg1uuVthhATWWeHw7aFRaHUWNnvlcna6C(erGDrO1c5GAi1oCAGVvGqx4ZMQfHMhcOq0uuVthhATqKvtufhSATdafrZd3WXaSJSqRvMKLLIQ4GvRDaOiAE4gogp7IP42qWjmmGAi1oCAuqjutv8jGIO5HB4aZQjQIdwT2bGIO5HB4ya2rwO1ktq40bagI6D64qRDa2rwO1YQjQIdwT2bGIO5HB4ya2rwO1crwnwnzzeQHu7WPrOpAg1uuVthhATSeqHFhte9mDXo7SGNYmdP2HtEg3w4PO2avCSNY3DrREHNSi3Ee2Zo2GtEgLN0I7iYtnWEkUneCc7PHipBQItGEcuipHu9oDCO1o8KvTCM8SJjpLV7Iw9cpzrU9iSNvpWki5zb4jKQ3PJdTwpBDtRNaDo3tXTHGtypf265H8SoHPlb6jyhPlCpJBYZLUi8es170XHw7Wz3eHwlggTznudP2HtmV2JA3Cx0QxmBQIRlCMvG2MiuO0Kw6PeMLqnKAhone170XHw7eGBpchivoIzOgVtTHAi1oCAe6JMrnf170XHwlmoDaGHOENoo0AhGDKfATYeRWsteATJM7Iw9Ija3EeEa058jIe3gcond9rWqufhSATJM7Iw9Ija3EeEa2rwO1ktMi0Ah4Bfi0f(SPArObqNZNicSlcTwihudP2Htd8Tce6cF2uTi08qafIMI6D64qRLrOgsTdNgH(Ozutr9oDCO1Ysaf(Dmr0Z0fZgBO(safconW9DkNUWXZdNWyDHZgBH(iwYko7SGNx7BA9SJ1fUNSi3EeoqQCKN66jKQ3PJdTwM9eBqjpnSNpBzYtXTHGtypnSNnfgRho5jqH8es170XHwRNT04U6HNcRPrx4dNDteATyy0M1qnKAhoX8ApQDZDrREXSPkUUWzwbABIqHstAPNsy51gQHu7WPHOENoo0ANaC7r4aPYrmd14DQnudP2HtJqF0mQPOENoo0AzPjcT2rZDrREXeGBpcpa6C(erIBdbNMH(izYeHw7aFRaHUWNnvlcna6C(erGDrO1c5GAi1oCAGVvGqx4ZMQfHMhcOq0uuVthhATmc1qQD40i0hnJAkQ3PJdTwwcOWVJjIEMUy2yd1xcOqWPbUVt50foEE4egRlC2yl0hXswXz3eHwlggTzTW48PjcT2jxXbZR9O2OQz2CByIzCGur0wwMvG2NoaWa1xAwaZMQfHg9ggHAi1oCAe6JMrnf170XHwR8UUZol45vdc5VJdpJBYtOgsTdN8mUTWtrTbQ4ypzrfrEclUHdp7ydo5zuEslUJip1a7P42qWjSNgI8044YZMQ4eONafYZRAFjplapLVQfHgo7Mi0AXWOnRHAi1oCI5oMMfaWeUaSTSm3X0S1TYPPWWHUWBllZR9O2akIMhUHJztvCDHZC10gtbZqnENAlQIdwT2bQV0SaMnvlcnq0Z0fZsteATdafrZd3WXaOZ5tejUneCAg6JKjteATd8Tce6cF2uTi0aOZ5teb2fHwlKdcqnKAhonW3kqOl8zt1IqZdbuiAkQ3PJdTwgfvXbRw7aFRaHUWNnvlcnq0Z0fZsrvCWQ1oq9LMfWSPArObIEMUyiYOOkoy1AhO(sZcy2uTi0arptxmlbu43XerptxmZkqBza1qQD40aqr08WnCmBQIRlCgdJtBmq9LMfWSPArigpDaGbQV0SaMnvlcnaRwRZol451(MwpH8meOWWHUW9Kf52J8ukqQCeZEYIkI8ewCdhypX3vNd65H8SJjqpJYt40silipH8QWtParMCypTf0ZO8KUiOf0tyXnCqipVknCqOHZUjcTwmmAZAafrZd3WbZDmnlaGjCbyBzzUJPzRBLttHHdDH3wwMvG2YaQHu7WPbGIO5HB4y2ufxx4mc1qQD40i0hnJAkQ3PJdTw5DDgnrOqPjT0tjS8Ad1qQD4042qGtHHJja3EeoqQCeJYaqreomuqOHjcfkXOmoDaGXDftCGitUrVHriC6aaJBYcDHp7nJEdJMi0AhaC7r4aPYrd6cs0dAIONPlMLxFWkSXM42qWj8eazIqR14YR9vGOZol4jdTJ0fUNSOIiCyOGqm7jlQiYtyXnCG90qKNDmb6jwFk3qCM8mkpb7iDH7jKQ3PJdT2HNS60siJZzIzpJBIjpne5zhtGEgLNWPLqwqEc5vHNsbIm5WE26MwpfinWE2s5Cp3k88qE2YWbb6PTGE2sJBpHf3WbH88Q0WbHy2Z4MyYt8D15GEEipXniYa9S6HNr55Z0nmD9mUjpHf3WbH88Q0WbH880bago7Mi0AXWOnRbuenpCdhm3X0SaaMWfGTLL5oMMTUvonfgo0fEBzzwbAdOichgki0WeHcLyuCBi4ewETLLrza1qQD40aqr08WnCmBQIRlCgHGmmrO1oaueDmoFqxqIEOlCgLHjcT2rdtO6WnCm0DcWv43bJNoaW4MSqx4ZEZO3WgBMi0AhakIogNpOlirp0foJY40bag3vmXbIm5g9g2yZeHw7OHjuD4gog6ob4k87GXthayCtwOl8zVz0ByugNoaW4UIjoqKj3O3arNDwWZRgAPGEkSMgDH7jlQiYtyXnC4P42qWjSNTUvo5P422L46c3tPBfi0fUNYx1Iqo7Mi0AXWOnRbuenpCdhm3X0S1TYPPWWHUWBllZkqBteATd8Tce6cF2uTi0GUGe9qx4mc058jIe3gcond9rS0eHw7aFRaHUWNnvlcncvi3erGDrO1Y4PdamURyIdezYnaRwlJH(i5j71D2nrO1IHrBwlmoFAIqRDYvCW8ApQnoSf0qGtufwO1YSc0gQHu7WPrOpAg1uuVthhATY76mE6aaduFPzbmBQweAawTwNDteATyy0M1yrHe3o7o7Mi0AXdtekuAggN2a3MRq1f(8uVdZkqBtekuAsl9uclpzz80bagI6D64qRDawTwgHaudP2HtJqF0mQPOENoo0ALNOkoy1AhCfQUWNN6DgGDKfATSXgudP2HtJqF0mQPOENoo0Azz7RdrNDteAT4HjcfkndJtBGHrBw)OGkeZkqBOgsTdNgH(Ozutr9oDCO1YY2xNn2GGOkoy1AhpkOcna7il0AzjudP2HtJqF0mQPOENoo0AzugHXPngO(sZcy2uTieezJTW40gduFPzbmBQweIXthayG6lnlGzt1IqJEdJqnKAhonc9rZOMI6D64qRvEMi0AhpkOcnevXbRwlBSbOWVJjIEMUywc1qQD40i0hnJAkQ3PJdTwNDteAT4HjcfkndJtBGHrBwdIm41INhezXnZkq7W40gdJtxGdKHH8XWtGoIjgHWPdame170XHw7aSATmkJthayCxXehiYKB0BGOZUZUjcTw8quVthhATtrvCWQ1IB3uHwRZUjcTw8quVthhATtrvCWQ1IHrBwF4vbob6iMC2nrO1IhI6D64qRDkQIdwTwmmAZ6dHWesoDHZSc0(0bagI6D64qRD0BC2nrO1IhI6D64qRDkQIdwTwmmAZAafrhEvGo7Mi0AXdr9oDCO1ofvXbRwlggTzTTcchiJpfgN7SBIqRfpe170XHw7uufhSATyy0M1H(Ozld1WSc0g1xcOqWPrqVMcz8zld1W4PdamOlUToo0Ah9gNDteAT4HOENoo0ANIQ4GvRfdJ2SUJPPg0JzcaGeXCTh1go3avlkeEEmq4KZUjcTw8quVthhATtrvCWQ1IHrBw3X0ud6X8ApQTUybQh2Httgs32O)MGeuvqo7Mi0AXdr9oDCO1ofvXbRwlggTzDhttnOhZR9O2aC7rZcyESi4KZUjcTw8quVthhATtrvCWQ1IHrBw3X0ud6X8ApQDltoAjeEcGQf0z3eHwlEiQ3PJdT2POkoy1AXWOnR7yAQb9yETh1wxCG6IOq4jOcvxAEio3z3eHwlEiQ3PJdT2POkoy1AXWOnR7yAQb9yETh1g33dVkWP9O4MjC4SBIqRfpe170XHw7uufhSATyy0M1Dmn1GEyNDNDteAT4HOENoo0ANn3gMAZv43bEc5Vdc)rBWSc0(0bagI6D64qRDawTwNDwWt5po0NfKN3vlp51c3tivVthhATE2s5Cp5go8mUTvoSNr5PuF98Qqx4xI9ewCcJ1fUNr5jife6Pl55D1YtwurKNWIB4a7j(U6CqppKNDmboC2nrO1IhI6D64qRD2CBycgTznudP2Htm3X0SaaMWfGTLL5oMMTUvonfgo0fEBzzETh1MUiOfKaNI6D64qRDIONPlM5QPnMcMHA8o1(0bagI6D64qRDGONPlggNoaWquVthhATdWoYcTwiheevXbRw7quVthhATde9mDXS80bagI6D64qRDGONPlgImRaTf1c21yOlaHwJpfgwyGKZol45vdcI9mUjpb7il0A9Sa8mUjpL6RNxf6c)sSNWItySUW9es170XHwRNr5zCtEslONfGNXn5POJq0gEcP6D64qR1tfWZ4M8uy4WZwvNd6POEnCkipb7iDH7zCRypHu9oDCO1oC2nrO1IhI6D64qRD2CBycgTznudP2Htm3X0SaaMWfGTLL5oMMTUvonfgo0fEBzzETh1MUiOfKaNI6D64qRDIONPlM5QPTbcYmuJ3P2qnKAhonWYDMGDKfATmRaTf1c21yOlaHwJpfgwyGeJq40bag4(oLtx445HtySUWNiYazA0ByJnOgsTdNg0fbTGe4uuVthhATte9mDXYt2bRa5Glahp7ciheoDaGbUVt50foEE4egRl8XZUyIdtiNmD6aadCFNYPlC88Wjmwx4dCyc5GieD2nrO1IhI6D64qRD2CBycgTz9XGplGzGuHCyMvG2NoaWquVthhATdWQ16SBIqRfpe170XHw7S52WemAZAUcvx4Zt9omRaTnrOqPjT0tjS8KLXthayiQ3PJdT2by1AD2zbpV2ACx9Wtz(cqO14EcjdlmqIzpH83XHNDm5jlQiYtyXnCG9S1nTEg3etE2Q2ldpF9vC7PaPb2tBb9S1nTEYIkIWrHEEQypbRw7Wz3eHwlEiQ3PJdT2zZTHjy0M1akIMhUHdM7yAwaat4cW2YYChtZw3kNMcdh6cVTSmRaTLHOwWUgdDbi0A8PWWcdKyuCBi4ewETLLXthayiQ3PJdT2rVHrzC6aadafr4OqVrVHrzC6aaJ7kM4arMCJEdJ3vmXbIm5M4gIZXtDNaCf(DaJthayCtwOl8zVz0By5vC2zbpV2AC7PmFbi0ACpHKHfgiXSNSOIipHf3WHNDm5j(U6CqppKNgiOgATgNZKNIAXbY0La9exEg3w4PgEQyp3k88qE2XeON9LtySNY8fGqRX9esgwyGKNk2t7u9WZO8KUOrrKNfYZ4MqKNgI88viYZ42wpPT6WV9Kfve5jS4goWEgLN0fbTGEkZxacTg3tizyHbsEgLNXn5jTGEwaEcP6D64qRD4SBIqRfpe170XHw7S52WemAZAOgsTdNyUJPzbamHlaBllZDmnBDRCAkmCOl82YY8ApQnDrdjccCcOiAE4goWmxnTXuWmuJ3P2Mi0AhakIMhUHJH42qWj8eazIqR14WacqnKAhonOlcAbjWPOENoo0ANi6z6ILPthayOlaHwJpfgwyG0aSJSqRfISAIQ4GvRDaOiAE4gogGDKfATmRaTf1c21yOlaHwJpfgwyGKZUjcTw8quVthhATZMBdtWOnRHAi1oCI5oMMfaWeUaSTSm3X0S1TYPPWWHUWBllZR9O2lrGe4eqr08WnCGzUAAJPGzOgVtTfKYHaudP2Htd6IGwqcCkQ3PJdT2jIEMUywniC6aadDbi0A8PWWcdKgGDKfATYeCb44zxariYSc0wulyxJHUaeAn(uyyHbso7Mi0AXdr9oDCO1oBUnmbJ2Sgqr08WnCWChtZcaycxa2wwM7yA26w50uy4qx4TLLzfOTOwWUgdDbi0A8PWWcdKyuCBi4ewETLLria1qQD40GUOHebbobuenpCdhy51gQHu7WPXseibobuenpCdhy2ydQHu7WPbDrqlibof170XHw7erptxmlBF6aadDbi0A8PWWcdKgGDKfATSX2Pdam0fGqRXNcdlmqAGdtihlVcBSD6aadDbi0A8PWWcdKgi6z6IzjCb44zxWgBIQ4GvRDGVvGqx4ZMQfHgiYazIrtekuAsl9uclV2qnKAhone170XHw7eFRaHUWNnvlcXOOGsRTXyv43XeWiiY4Pdame170XHw7O3WieKXPdamaueHJc9g9g2y70bag6cqO14tHHfginq0Z0fZYRpyfiYOmoDaGXDftCGitUrVHX7kM4arMCtCdX54PUtaUc)oGXPdamUjl0f(S3m6nS8ko7Mi0AXdr9oDCO1oBUnmbJ2SwyC(0eHw7KR4G51EuBtekuAggN2a7SBIqRfpe170XHw7S52WemAZAr9oDCO1YChtZcaycxa2wwM7yA26w50uy4qx4TLLzfO9Pdame170XHw7aSATmc1qQD40i0hnJAkQ3PJdTww2(6mcbzG6lbui40auXcTHRRHyAkQ3Zwq2y70bagGkwOnCDnettr9E2co6nSX2PdamavSqB46AiMMI69SfCcGkCm6nmggN2yG6lnlGzt1IqmkQIdwT2XPdambvSqB46AiMMI69SfCGidKjiYieKbQVeqHGtd4ifZzAQcvWj2ydKoDaGbCKI5mnvHk40O3argHGmefuATngljqfVqGSXMOkoy1AhGKf3NcT0arptxmBSD6aadqYI7tHwA0BGiJqWeHw74rbvOHUtaUc)oy0eHw74rbvOHUtaUc)oMi6z6IzzBOgsTdNgI6D64qRDkmCmr0Z0fZgBMi0AhyrHe3d6cs0dDHZOjcT2bwuiX9GUGe9GMi6z6IzjudP2Htdr9oDCO1ofgoMi6z6IzJnteATdafrhJZh0fKOh6cNrteATdafrhJZh0fKOh0erptxmlHAi1oCAiQ3PJdT2PWWXerptxmBSzIqRD0WeQoCdhd6cs0dDHZOjcT2rdtO6WnCmOlirpOjIEMUywc1qQD40quVthhATtHHJjIEMUy2yZeHw7aGBpchivoAqxqIEOlCgnrO1oa42JWbsLJg0fKOh0erptxmlHAi1oCAiQ3PJdT2PWWXerptxmeD2zbpzvXnH8uufhSATypJBl8eFxDoONhYZoMa9SLg3EcP6D64qR1t8D15GEwlNjppKNDmb6zlnU90wpnr0nUNqQENoo0A9uy4WtBb9CRWZwAC7P5PuF98Qqx4xI9ewCcJ1fUNnOsmC2nrO1IhI6D64qRD2CBycgTzTW48PjcT2jxXbZR9O2I6D64qRDkQIdwTwmZkq7thayiQ3PJdT2bIEMUy5DTyJnrvCWQ1oe170XHw7arptxmlzfNDteAT4HOENoo0ANn3gMGrBwdWThHdKkhXSc0gcNoaW4UIjoqKj3O3WOjcfknPLEkHLxBOgsTdNgI6D64qRDcWThHdKkhbr2ydcNoaWaqreok0B0By0eHcLM0spLWYRnudP2Htdr9oDCO1ob42JWbsLJKjuFjGcbNgakIWrHEq0z3eHwlEiQ3PJdT2zZTHjy0M1nmHQd3WbZkq7thayG77uoDHJNhoHX6cFIidKPrVHXthayG77uoDHJNhoHX6cFIidKPbIEMUy5jmCmd9ro7Mi0AXdr9oDCO1oBUnmbJ2SUHjuD4goywbAF6aadafr4OqVrVXz3eHwlEiQ3PJdT2zZTHjy0M1nmHQd3WbZkq7thay0WeQeCd)g9ggpDaGrdtOsWn8BGONPlwEcdhZqFeJq40bagI6D64qRDGONPlwEcdhZqFeBSD6aadr9oDCO1oaRwlez0eHcLM0spLWSeQHu7WPHOENoo0ANaC7r4aPYro7Mi0AXdr9oDCO1oBUnmbJ2SUHjuD4goywbAF6aaJ7kM4arMCJEdJNoaWquVthhATJEJZUjcTw8quVthhATZMBdtWOnRBycvhUHdMvG2nic6eUaCi7alkK4MXthayCtwOl8zVz0By0eHcLM0spLWSeQHu7WPHOENoo0ANaC7r4aPYro7SGNmmyDH7P0Tce6c3t5RAripb7iDH7jKQ3PJdTwpJYteHJcrEYIkI8ewCdhEAlONY3DrREHNSi3EKNIBdbNWEkS1Zd55HwcqfQXz2Ztp8SJ7gNZKN1YzYZA98Ql5)Wz3eHwlEiQ3PJdT2zZTHjy0M14Bfi0f(SPAriMvG2NoaWquVthhATJEdJYWeHw7aqr08WnCme3gcoHz0eHcLM0spLWYRnudP2Htdr9oDCO1oX3kqOl8zt1IqmAIqRD0Cx0Qxmb42JWdGoNprK42qWPzOpsEaDoFIiWUi0Azw3GqOEtmvG2Mi0AhakIMhUHJH42qWjCBteATdafrZd3WX4zxmf3gcoHD2nrO1IhI6D64qRD2CBycgTzDZDrREXeGBpcZSc0(0bagI6D64qRD0BymqguIpd9rS80bagI6D64qRDGONPlMriabteATdafrZd3WXqCBi4eMLYYyyCAJrdtOsWn8JrtekuAsl9uc3wwiYgBYimoTXOHjuj4g(XgBMiuO0Kw6PewEYcrgpDaGXnzHUWN9MrVbg3vmXbIm5M4gIZXtDNaCf(DWYR4SBIqRfpe170XHw7S52WemAZAaU9iCGu5iMvG2NoaWquVthhATdWQ1YOOkoy1AhI6D64qRDGONPlMLcdhZqFeJMiuO0Kw6PewETHAi1oCAiQ3PJdT2ja3EeoqQCKZUjcTw8quVthhATZMBdtWOnRbueDmoNzfO9Pdame170XHw7aSATmkQIdwT2HOENoo0Ahi6z6IzPWWXm0hXOme1c21yaWThnnHarHwRZUjcTw8quVthhATZMBdtWOnRXIcjUzwbAF6aadr9oDCO1oq0Z0flpHHJzOpIXthayiQ3PJdT2rVHn2oDaGHOENoo0AhGvRLrrvCWQ1oe170XHw7arptxmlfgoMH(iNDteAT4HOENoo0ANn3gMGrBwZvO6cFEQ3HzfO9Pdame170XHw7arptxmlHlahp7cgnrOqPjT0tjS8K1z3eHwlEiQ3PJdT2zZTHjy0M1GidET45brwCZSc0(0bagI6D64qRDGONPlMLWfGJNDbJNoaWquVthhATJEJZUZol4jKhXBiKNqnKAho5zCBHNIAdtxSNXn5PjIUX9KWH(SGa9m0h5zCBHNXn55sxeEcP6D64qR1ZwkN75H8ergitdNDteAT4HOENoo0ANH(0fEBOgsTdNyETh1wuVthhATtezGmnd9rmd14DQTOkoy1AhI6D64qRDGONPlgYbbzLjia1qQD40qoDb56cFIiWUi0AHX1hxbYbOichgki0WeHcLGiKlmoTXqoDb56chIo7Mi0AXdr9oDCO1od9PlCy0M1qnKAhoX8ApQTOENoo0ANH(iMHA8o1gQHu7WPHOENoo0ANiYazAg6JC2zbpzOe3yYtivVthhATEcuipnGGqEYIkIWHHcc5zF5eg7judP2Htdafr4WqbHMI6D64qR1tf7jMIHZUjcTw8quVthhATZqF6chgTznudP2HtmV2JAlQ3PJdT2zOpI5QP9ZUGzOgVtTbueHddfeAGONPlMzfODyCAJbGIiCyOGqmkdOgsTdNgakIWHHccnf170XHwRZol4jdL4gtEcP6D64qR1tGc55v1avBdpLAmKCEQaEQHNTuo3tr9iplaapfvXbRwRN4Q2HZUjcTw8quVthhATZqF6chgTznudP2HtmV2JAlQ3PJdT2zOpI5QP9ZUGzOgVtTfvXbRw7azGQTXe3yi5gi6z6IzwbAlkO0ABmKJjKAlJIQ4GvRDGmq12yIBmKCde9mDXYKSxNLqnKAhone170XHw7m0h5SZcEYqjUXKNqQENoo0A9eOqEYqjlUpfAPHZUjcTw8quVthhATZqF6chgTznudP2HtmV2JAlQ3PJdT2zOpI5QP9ZUGzOgVtTfvXbRw7aKS4(uOLgi6z6IzwbAlkO0ABmwsGkEHazuufhSATdqYI7tHwAGONPlwMK96SeQHu7WPHOENoo0ANH(iNDwWtgkXnM8es170XHwRNafYZ4M8u()Aycrg3twfcCTvqEE6aaEQaEg3KNnCJjc5PI9SJ1fUNXTfEgiDLJIHZUjcTw8quVthhATZqF6chgTznudP2HtmV2JAlQ3PJdT2zOpI5QP9ZUGzOgVtTHAi1oCAqVgMqKXNfcCTvqtqIBmjtqqufhSATd61WeIm(SqGRTcAa2rwO1ktIQ4GvRDqVgMqKXNfcCTvqde9mDXqeYjdrvCWQ1oOxdtiY4ZcbU2kObImqMywbAtmKU20qGd61WeIm(SqGRTcYzNf8KHsCJjpHu9oDCO16jqH8KvNBGQffc7jSmq4eZE2xoHXEQHNTQoh0Zd5jiXnMiqp51cNqEg3265vUUNysuliE4SBIqRfpe170XHw7m0NUWHrBwd1qQD4eZR9O2I6D64qRDg6JyUAA)SlygQX7uBrvCWQ1oGZnq1IcHNhdeonVg5hRCLRCTgi6z6IzwbAtmKU20qGd4CduTOq45XaHtmkQIdwT2bCUbQwui88yGWP51i)yLRCLR1arptxSmDLRZsOgsTdNgI6D64qRDg6JC2zbpzOe3yYtivVthhATE23q5EEvl5Zt6Igfrypvap14sSN9MHZUjcTw8quVthhATZqF6chgTznudP2HtmV2JAlQ3PJdT2zOpI5QP9ZUGzOgVtTpDaGbQV0SaMnvlcnq0Z0fZSc0omoTXa1xAwaZMQfHy80bagI6D64qRDawTwNDwWtgkXnM8es170XHwRNafYtB9KUiqMNx1(sEwaEkFvlc5Pc4zCtEEv7l5zb4P8vTiKNTQoh0tr9iplaapfvXbRwRNw4jNmC4jR4jMe1cI98qafI8es170XHwRNTQohC4SBIqRfpe170XHw7m0NUWHrBwd1qQD4eZR9O2I6D64qRDg6JyUAA)SlygQX7uBrvCWQ1oq9LMfWSPArObIEMUyyC6aaduFPzbmBQweAa2rwO1YSc0omoTXa1xAwaZMQfHy80bagI6D64qRDawTwgfvXbRw7a1xAwaZMQfHgi6z6IHbRWsOgsTdNgI6D64qRDg6JC2zbpzOe3yYtivVthhATEEyYZEJNr5PSx3tmjQfe7zuEcOHN66jDrGmp7ydoH9Sa8KHQyH2W11qm5jKQ3ZwWHZUjcTw8quVthhATZqF6chgTznudP2HtmV2JAlQ3PJdT2zOpI5QP9ZUGzOgVtTfvXbRw740baMGkwOnCDnettr9E2coa7il0AHHOkoy1AhNoaWeuXcTHRRHyAkQ3ZwWbIEMUyMvG2IQ4GvRDC6aatqfl0gUUgIPPOEpBbhi6z6IHHOkoy1AhNoaWeuXcTHRRHyAkQ3ZwWbyhzHwllHAi1oCAiQ3PJdT2zOpsMK96o7SGNmuIBm5jKQ3PJdTwpvapzOkwOnCDnetEcP69Sf0ZwvNd65wHNhYtezGm5jqH8udpzIIHZUjcTw8quVthhATZqF6chgTznudP2HtmV2JAlQ3PJdT2zOpI5QP9ZUGzOgVtTfvXbRw740baMGkwOnCDnettr9E2coq0Z0fZSc0g1xcOqWPbOIfAdxxdX0uuVNTGmE6aadqfl0gUUgIPPOEpBbhGvR1zNf88QAkONYFO0gyg0tgkXnM8es170XHwRNafYtde0tCJ1AXEwaEEnEwipFfI80abXEg3w4zlLZ9KB4WtETWjKNXTTEklR4jMe1cIhEcZBctEc14Dc7PHO9YWZLeegBiLZKNvtOpJ7PUEACUNcdt4HZUjcTw8quVthhATZqF6chgTznudP2HtmV2JAlQ3PJdT2zOpI5QP9ZUGzOgVtTrMcojO0gddeep0LzfOnYuWjbL2yyGG4bDHIdmJitbNeuAJHbcIhIQVH8AFnmImfCsqPnggiiEa2rwO1kpzzfNDwWZRQPGEk)HsBGzqpVAElJjSNDm5jKQ3PJdTwpBPXTNq78Lq2r5AWKNitb9KGsBGz2ZckHqki5PTm5jiXnMWEYvCqGEANck5zuE(m5ipXDe5PgEcNcSNDmb65nHOHZUjcTw8quVthhATZqF6chgTznudP2HtmV2JAlQ3PJdT2zOpIzOgVtTrMcojO0gdOD(si7WPHUqozGmfCsqPngq78Lq2HtJEdZkqBKPGtckTXaANVeYoCAqxO4aZiudP2Htdr9oDCO1orKbY0m0hXsKPGtckTXaANVeYoCAORZol4jddM8mUjpx6IWtivVthhATEwRNIQ4GvR1tfWtn8Sv15GEUv45H8KUOHebb6zuEcsCJjpJBYtS4Ma7Cc0ZAjplKNXn5jwCtGDob6zTKNTQoh0ZBRPHwp5eg7zCBRNYYkEIjrTGyppeqHipJBYtaf(D4jTG4HNxniONr5judP2Htd50fKRl8jIa7IqR1ZdjSoM8mUvSN6k4Dqc7zCtEcGQn4LbsGEgifoCcH9eSJ0fUNqQENoo0A90wqpJBl8eQHu7WjpvSNpY2WZO88qE2XeONgqqipHu9oDCO1oC2nrO1IhI6D64qRDg6tx4WOnRHAi1oCI51EuBr9oDCO1od9rmd14DQnudP2Htdr9oDCO1orKbY0m0hXSc0gQHu7WPHOENoo0ANiYazAg6JGHOkoy1AhI6D64qRDa2rwO1c5GGSYeeU(4kWaQHu7WPHC6cY1f(erGDrO1cJRpUcKdqreomuqOHjcfkbrixyCAJHC6cY1foezzBOgsTdNgI6D64qRDg6JyJnOgsTdNgI6D64qRDg6JKhGc)oMi6z6ILPRCDNDwWZRge0Z4M8u0riAdpd9rEgLNXn5jwCtGDob6jKQ3PJdTwpJYZME4PgEQRN2bx8EqEg6J8exEg3w4PgEQypXHY5EAcrhzb5PbeeYtZtUgbN8m0h5zJHXeE4SBIqRfpe170XHw7m0NUWHrBwd1qQD4eZR9O2I6D64qRDg6JyUAABGGmd14DQDOpYzNf8Kf114CMy2trTqju4jaQEEAhCX7b5zOpYtBb9ehfI8mUjpre3cfk5zOpYtD9eQHu7WPrOpAg1uuVthhATdpzywUkh5zCtEIiC4zb4zCtEkmUOZTqRfZSNTUvXTN3wtdTEYjm2taeXq60gCM8mkpXneb6zVXZ4M8eRVo3cTwM9mUvSN3wtdTyplaazIvhsmupTf0Zw3kN8uy4qx4dNDteAT4HOENoo0ANH(0fomAZAOgsTdNyUJPzbamHlaBllZDmnBDRCAkmCOl82YY8ApQDOpAg1uuVthhATmd14DQneGAi1oCAiQ3PJdT2zOpsMc9rqeYD6aadr9oDCO1oaRwRZUZUjcTw8avnZMBdtTb42JWbsLJywbABIqHstAPNsy51gQHu7WPXDftCGitUja3EeoqQCeJq40bag3vmXbIm5g9g2y70bagakIWrHEJEdeD2nrO1IhOQz2CBycgTzDdtO6WnCWSc0(0bag4(oLtx445HtySUWNiYazA0By80bag4(oLtx445HtySUWNiYazAGONPlwEcdhZqFKZUjcTw8avnZMBdtWOnRBycvhUHdMvG2NoaWaqreok0B0BC2nrO1IhOQz2CBycgTzDdtO6WnCWSc0(0bag3vmXbIm5g9gNDwWtggm5zTKNSOIipHf3WHNKH4m5PUEEvl5ZtfWtMQUNG1Ez45TbL8K04MqEc5rwOlCpzyA8SqEc5vHNsbIm58Kjk80wqpjnUjed6jemi65TbL88viYZ42wpJwLNghrgitm7jeoq0ZBdk55vZPlWbYWq(yxI9Kf7iM8ergitEgLNDmXSNfYtiiGONsKH0fUNWS6IBpvSNMiuO0WtgATxgEcwEg3k2Zw3kN882qGEkmCOlCpzrU9iCGu5iSNfYZw306PuF98Qqx4xI9ewCcJ1fUNk2tezGmnC2nrO1IhOQz2CBycgTznGIO5HB4G5oMMfaWeUaSTSm3X0S1TYPPWWHUWBllZkqBza1qQD40aqr08WnCmBQIRlCgpDaGbUVt50foEE4egRl8jImqMgGvRLrtekuAsl9ucZsOgsTdNg3gcCkmCmb42JWbsLJyugakIWHHccnmrOqjgHGmoDaGXnzHUWN9MrVHrzC6aaJ7kM4arMCJEdJYObrqNfaWeUaCaOiAE4goyecMi0AhakIMhUHJH42qWjS8AFf2ydcHXPnggNUahidd5JHNaDetmkQIdwT2biYGxlEEqKf3dezGmbr2ydtgsx4ZO6I7Hjcfkbri6SZcEYWGjpzrfrEclUHdpjnUjKNGDKUW908KfveDmoN1YhtO6WnC4PWWHNTUP1tipYcDH7jdtJNk2ttekuYZc5jyhPlCpPlirpipBPXTNsKH0fUNWS6I7HZUjcTw8avnZMBdtWOnRbuenpCdhm3X0SaaMWfGTLL5oMMTUvonfgo0fEBzzwbAldOgsTdNgakIMhUHJztvCDHZOmaueHddfeAyIqHsmcbiabteATdafrhJZh0fKOh6cNriyIqRDaOi6yC(GUGe9GMi6z6Iz51hScBSjduFjGcbNgakIWrHEqKn2mrO1oAycvhUHJbDbj6HUWzecMi0AhnmHQd3WXGUGe9GMi6z6Iz51hScBSjduFjGcbNgakIWrHEqeImE6aaJBYcDHp7nJEdezJniGjdPl8zuDX9WeHcLyecNoaW4MSqx4ZEZO3WOmmrO1oWIcjUh0fKOh6cNn2KXPdamURyIdezYn6nmkJthayCtwOl8zVz0By0eHw7alkK4EqxqIEOlCgLXDftCGitUjUH4C8u3jaxHFhqeIq0z3eHwlEGQMzZTHjy0M1cJZNMi0ANCfhmV2JABIqHsZW40gyNDteAT4bQAMn3gMGrBw3WeQoCdhmRaTpDaGrdtOsWn8B0Byuy4yg6Jy5PdamAycvcUHFde9mDXmkmCmd9rS80bagO(sZcy2uTi0arptxSZUjcTw8avnZMBdtWOnRBycvhUHdMvG2NoaW4UIjoqKj3O3WiMmKUWNr1f3dtekuIrtekuAsl9ucZsOgsTdNg3vmXbIm5MaC7r4aPYro7Mi0AXdu1mBUnmbJ2SU5UOvVycWThHzwbAldOgsTdNgn3fT6fZMQ46cNXthayCtwOl8zVz0ByugNoaW4UIjoqKj3O3WiemrOqPjyfdf(QbXYRWgBMiuO0Kw6PewETHAi1oCACBiWPWWXeGBpchivoIn2mrOqPjT0tjS8Ad1qQD404UIjoqKj3eGBpchivocIo7Mi0AXdu1mBUnmbJ2SglkK4MzfOnMmKUWNr1f3dtekuYz3eHwlEGQMzZTHjy0M1GidET45brwCZSc02eHcLM0spLWY7ko7Mi0AXdu1mBUnmbJ2S2qcBPjDrdVWATmRaTnrOqPjT0tjS8Ad1qQD40WqcBPjDrdVWATm(S1gnIqETHAi1oCAyiHT0KUOHxyT25ZwZzNf88ARXTN0wD43EggcofyM9udpvSNMNWnD9mkpfgo8Kf52JWbsLJ80WEcOCoH8uxCqgONfGNSOIOJX5dNDteAT4bQAMn3gMGrBwdWThHdKkhXSc02eHcLM0spLWYRnudP2HtJBdbofgoMaC7r4aPYro7Mi0AXdu1mBUnmbJ2Sgqr0X4CNDNDteAT4boSf0qGtufwO12gGBpchivoIzfOTjcfknPLEkHLxBOgsTdNg3vmXbIm5MaC7r4aPYrmcHthayCxXehiYKB0ByJTthayaOichf6n6nq0z3eHwlEGdBbne4evHfATWOnRBycvhUHdMvG2NoaWaqreok0B0BC2nrO1Ih4WwqdborvyHwlmAZ6gMq1HB4GzfO9PdamURyIdezYn6nmE6aaJ7kM4arMCde9mDXS0eHw7aqr0X48bDbj6bnd9ro7Mi0AXdCylOHaNOkSqRfgTzDdtO6WnCWSc0(0bag3vmXbIm5g9ggHqdIGoHlahYoaueDmoNn2aueHddfeAyIqHsSXMjcT2rdtO6WnCm0DcWv43beD2zbpHjIjpJYt4u4P0vbS8SbvcSN6IvqYZRAjFE2CByc7zH8es170XHwRNn3gMWE26MwpBkmwpCA4SBIqRfpWHTGgcCIQWcTwy0M1nmHQd3WbZkq7thayG77uoDHJNhoHX6cFIidKPrVHriiQIdwT2bQV0SaMnvlcnq0Z0fddteATduFPzbmBQweAqxqIEqZqFemegoMH(i5D6aadCFNYPlC88Wjmwx4tezGmnq0Z0fZgBYimoTXa1xAwaZMQfHGiJqnKAhonc9rZOMI6D64qRfgcdhZqFK8oDaGbUVt50foEE4egRl8jImqMgi6z6ID2nrO1Ih4WwqdborvyHwlmAZ6gMq1HB4GzfO9PdamURyIdezYn6nmIjdPl8zuDX9WeHcLC2nrO1Ih4WwqdborvyHwlmAZ6gMq1HB4GzfO9PdamAycvcUHFJEdJcdhZqFelpDaGrdtOsWn8BGONPl2zNf8KH2r6c3Z4M8eh2cAiqprvyHwlZEwlNjp7yYtwurKNWIB4a7zRBA9mUjM80qKNBfEEiDH7ztvCc0tGc55vTKpplKNqQENoo0AhEYWGjpzrfrEclUHdpjnUjKNGDKUW908KfveDmoN1YhtO6WnC4PWWHNTUP1tipYcDH7jdtJNk2ttekuYZc5jyhPlCpPlirpipBPXTNsKH0fUNWS6I7HZUjcTw8ah2cAiWjQcl0AHrBwdOiAE4goyUJPzbamHlaBllZDmnBDRCAkmCOl82YYSc0wgakIWHHccnmrOqjgLbudP2HtdafrZd3WXSPkUUWzecqacMi0AhakIogNpOlirp0foJqWeHw7aqr0X48bDbj6bnr0Z0fZYRpyf2ytgO(safconaueHJc9GiBSzIqRD0WeQoCdhd6cs0dDHZiemrO1oAycvhUHJbDbj6bnr0Z0fZYRpyf2ytgO(safconaueHJc9Giez80bag3Kf6cF2Bg9giYgBqatgsx4ZO6I7HjcfkXieoDaGXnzHUWN9MrVHrzyIqRDGffsCpOlirp0foBSjJthayCxXehiYKB0ByugNoaW4MSqx4ZEZO3WOjcT2bwuiX9GUGe9qx4mkJ7kM4arMCtCdX54PUtaUc)oGieHOZUjcTw8ah2cAiWjQcl0AHrBw3WeQoCdhmRaTpDaGXDftCGitUrVHrtekuAsl9ucZsOgsTdNg3vmXbIm5MaC7r4aPYro7Mi0AXdCylOHaNOkSqRfgTzDZDrREXeGBpcZSc0wgqnKAhonAUlA1lMnvX1foJqqgHXPngaO6nJBAA4BcZgBMiuO0Kw6PewEYcrgHGjcfknbRyOWxniwEf2yZeHcLM0spLWYRnudP2HtJBdbofgoMaC7r4aPYrSXMjcfknPLEkHLxBOgsTdNg3vmXbIm5MaC7r4aPYrq0z3eHwlEGdBbne4evHfATWOnRfgNpnrO1o5koyETh12eHcLMHXPnWo7Mi0AXdCylOHaNOkSqRfgTzniYGxlEEqKf3mRaTnrOqPjT0tjS8K1z3eHwlEGdBbne4evHfATWOnRXIcjUzwbAJjdPl8zuDX9WeHcLC2nrO1Ih4WwqdborvyHwlmAZAdjSLM0fn8cR1YSc02eHcLM0spLWYRnudP2HtddjSLM0fn8cR1Y4ZwB0ic51gQHu7WPHHe2st6IgEH1ANpBnNDwWZRTg3EsB1HF7zyi4uGz2tn8uXEAEc301ZO8uy4WtwKBpchivoYtd7jGY5eYtDXbzGEwaEYIkIogNpC2nrO1Ih4WwqdborvyHwlmAZAaU9iCGu5iMvG2MiuO0Kw6PewETHAi1oCACBiWPWWXeGBpchivoYz3eHwlEGdBbne4evHfATWOnRbueDmo)h)4)b]] )

end
