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
            duration = 12,
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
            duration = 15,
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
        firestorm = {
            id = 333100,
            duration = 5,
            max_stack = 1
        },

        sun_kings_blessing = {
            id = 333314,
            duration = 30,
            max_stack = 16
        },

        sun_kings_blessing_ready = {
            id = 333315,
            duration = 15,
            max_stack = 1
        }
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
            readyTime = function () if debuff.casting.up then return state.timeToInterrupt end end,

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
            

            impact = function ()
                if hot_streak( firestarter.active or stat.crit + buff.fireball.stack * 10 >= 100 ) then
                    removeBuff( "fireball" )
                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    addStack( "fireball", nil, 1 )
                    if conduit.flame_accretion.enabled then addStack( "flame_accretion" ) end
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
                        if buff.sun_kings_blessing.stack == 16 then
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
                if hot_streak( true ) and talent.kindling.enabled then
                    setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
                end

                applyDebuff( "target", "ignire" )
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
                    if buff.sun_kings_blessing_ready.up then applyBuff( "combustion", 4 ) end
                else
                    if buff.hot_streak.up then
                        if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                        else removeBuff( "hot_streak" ) end
                        if legendary.sun_kings_blessing.enabled then
                            addStack( "sun_kings_blessing", nil, 1 )
                            if buff.sun_kings_blessing.stack == 16 then
                                removeBuff( "sun_kings_blessing" )
                                applyBuff( "sun_kings_blessing_ready" )
                            end
                        end
                    end
                end
            end,

            velocity = 35,

            impact = function ()
                if hot_streak( firestarter.active or buff.firestorm.up ) then
                    if talent.kindling.enabled then
                        setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
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


    spec:RegisterPack( "Fire", 20201011, [[d807JcqivkEKuvQlrHs1MOGpjvfmkjItjrzvsvjVsQQMffYTiHQDHQFPsvdde1XKqTmvQ4zQuPPjvf11OqX2KQI8nkuHXrHk6CuOsTokusZde5EKO9PsPdscbTqvcpKeknrkujUifQK2ije9rPQq1ijHqNKek0kLqEjfkLMjjuKBsHsStjQ(jjuudvQkKLsHsHNsrtvLORscf8vsiWyLQcL9kL)sQbd1HjwSipgLjdQlJSzr9zqA0sLtlSAkuk61KGztPBRIDR0VvmCs64KqA5Q65atNQRlPTlbFxQY4LiDEqy9uOQ5RsA)qUvC7YMjS4uR87a57a5IHCXfZlUpb570NnoAMoeQuZuvykiqPM5khQzQiJNAMQce2rGBx2mbt9zuZSZDvGX693dn8UAIZMZ9G4uTIhZYEj73dId7(MzQgwxX42sntyXPw53bY3bYfd5IlMxSXymgtF24UzkvVB(MPzCuSnZUagM2wQzctawZSVryfz8ecBSiqjur9nc35UkWy9(7HgExnXzZ5EqCQwXJzzVK97bXHDpQO(gHvmZ8jrpcxCXgHW3bY3bYOIqf13iSITtwOeWyfvuFJWkocRyaqiCoG256NosSae(fVJEe27KfHD5Hso3JdP9rdhecNNhHTcWvCaXMfgHLuydhceUceOeG3mTbWbTlBMWuwQwVDzR8IBx2mPvswcUDrZK9HtFinZBq4VUuEEOehoaSq1gR8qOzZ5ilmNu0AOQsWntH5XSnt2uxNEGkzTnVv(DAx2mPvswcUDrZCuBMaYBMcZJzBMfKpKKLAMfeBLAMUyP1554jGlVtpNwjzjyeUVq4C8eWL3PN)0rIfGW9JWLGWSzSWtVLZMtQc8yw(thjwac3xiCjiCXiSIJWfKpKKL4kelSnwO6NGRmpMfH7le2flToxHyHTXcLtRKSemcxgcxgc3xi8nimBgl80B5S5KQapML)Kadbc3xiCQMZC2CsvGhZYHNEBZSG86vouZ0JdP9rZMtQc8y2M3k)UTlBM0kjlb3UOzY(WPpKMzQMZC2CsvGhZYHNElcBaHt1CM)1L0twRo9ONdp9we2acZMXcp9woBoPkWJz5pDKybi8TimKrydiCjimBgl80B5FDj9K1Qtp65pDKybi8TimKr4Rxr4BqyxS068VUKEYA1Ph9CALKLGr4YAMcZJzBMGUi7XcvRo9OV5TY7ZTlBM0kjlb3UOzY(WPpKMzjiCQMZC2CsvGhZYHNElcBaHt1CM)1L0twRo9ONdp9we2acxccZMXcp9woBoPkWJz5pDKybimKqyQuIvDs7XHq4Rxry2mw4P3YzZjvbEml)PJelaHVfHzZyHNEl)f4qwxduLxboC9fpMfHldHldHVEfHlbHt1CM)1L0twRo9ONxvrydimBgl80B5S5KQapML)0rIfGW3IW3fYiCzntH5XSnZxGdzDnqvEfAERCJPDzZKwjzj42fnt2ho9H0mt1CMZMtQc8ywo80BrydiCQMZ8VUKEYA1Ph9C4P3IWgqy2mw4P3YzZjvbEml)PJelaHHectLsSQtApouZuyEmBZeMeVln)snVvEFQDzZKwjzj42fnt2ho9H0mt1CMZMtQc8ywo80BrydimmLQ5m)f4qwxduLxbDHQDPxsHnCi4WtVTzkmpMTzEI)Nxhhbk18w5ghTlBM0kjlb3UOzUYHAMIXd6Kxa68SUEYA1Ph9ntH5XSntX4bDYlaDEwxpzT60J(Mj7dN(qAMfKpKKL4ECiTpA2CsvGhZIWqsjcBmiC)iCXgdc3xiCb5djzjEEwxdp1KL0ZQRacHnGWfKpKKL4ECiTpA2CsvGhZIW3IWqU5TYnoBx2mPvswcUDrZK9HtFinZsq4cYhsYsCpoK2hnBoPkWJzryiHWfdze(6veohq7C9thjwacdjeUG8HKSe3JdP9rZMtQc8yweUSMPW8y2Mj0Q8WHS6jRfJN(X7AERCJ72LntH5XSnt2SmA9xCcwNTYHAM0kjlb3UO5TYlgYTlBMcZJzBMpjQXcvNTYHantALKLGBx08w5fxC7YMPW8y2MzEyvabRfJN(WjDIKtZKwjzj42fnVvEX3PDzZuyEmBZuT(rgIyHQtwb4ntALKLGBx08w5fF32LntH5XSnZpuvTKownqvyuZKwjzj42fnVvEX952LntH5XSntVJ01nn1fwNNNrntALKLGBx08w5fBmTlBM0kjlb3UOzY(WPpKM5xxkppuIdhawOAJvEi0S5CKfMtkAnuvjye2acZMXcp9wEQMZA4aWcvBSYdHMnNJSW8NeyiqydiCQMZC4aWcvBSYdHMnNJSWA5zYsC4P3IWgqy2mw4P3YzZjvbEml)PJelaHVfHVlKrydi8niCQMZC4aWcvBSYdHMnNJSW8QAZuyEmBZKn11PhOswBZBLxCFQDzZKwjzj42fnt2ho9H0m)6s55HsC4aWcvBSYdHMnNJSWCsrRHQkbJWgqy2mw4P3Yt1CwdhawOAJvEi0S5CKfM)KadbcBaHt1CMdhawOAJvEi0S5CKfwlptwIdp9we2acZMXcp9woBoPkWJz5pDKybi8Ti8DHmcBaHVbHt1CMdhawOAJvEi0S5CKfMxvBMcZJzBMYZKL0uPQ2beZ28w5fBC0USzsRKSeC7IMj7dN(qAMFDP88qjoCayHQnw5HqZMZrwyoPO1qvLGrydimBgl80B5PAoRHdaluTXkpeA2CoYcZFsGHaHnGWPAoZHdaluTXkpeA2CoYcRZ)aCo80BrydimBgl80B5S5KQapML)0rIfGW3IW3fYiSbe(geovZzoCayHQnw5HqZMZrwyEvTzkmpMTzM)b4PX6nVvEXgNTlBM0kjlb3UOzY(WPpKMzQMZ8VUKEYA1Ph9C4P3IWgq4sq4cYhsYsCpoK2hnBoPkWJzr4Br4unN5FDj9K1Qtp65W1x8ywe2acxq(qswI7XH0(OzZjvbEmlcFlclmpMLNJN0jRaCEUAT6NyDYdL0ECie(6veUG8HKSe3JdP9rZMtQc8ywe(weohq7C9thjwacxwZuyEmBZ8RlPNSwD6rFZBLxSXD7YMjTsYsWTlAMcZJzBMmXA1cZJz12a4nt2ho9H0mVbHliFijlXHdGKSKMnNuf4XSiSbeUG8HKSe3JdP9rZMtQc8ywegskryi3mTbW1RCOMjBoPkWJz1QDcGAER87a52LntALKLGBx0mh1MjG8MPW8y2Mzb5djzPMzbXwPM5niCb5djzjoCaKKL0S5KQapMfHnGWfKpKKL4ECiTpA2CsvGhZIWqcHfMhZYZXt6KvaopxTw9tSo5HsApoecR4iCb5djzjoOlYESq1Qtp61pbxzEmlc3xiCjimBgl80B5GUi7XcvRo9ON)0rIfGWqcHliFijlX94qAF0S5KQapMfHldHnGWfKpKKL4ECiTpA2CsvGhZIWqcHZb0ox)0rIfGWxVIWFDP88qjoOUAfIfkqNSeaeluoPO1qvLGrydiSW8ywEoEsNScW5So5HsaD(fMhZkwegsiSW8ywEoEsNScW5hPunRtEOeaHvCegYCJbHnGWLGWSzSWtVLd6IShluT60JE(thjwacFlcxSXGWxVIW3GWSPaTY68nG256SqiCznZcYRx5qnZC8KozfGRvNXgl0M3k)of3USzsRKSeC7IMPW8y2MjtSwTW8ywTnaEZK9HtFinZunN5FDj9K1Qtp65vve2acxccxq(qswI7XH0(OzZjvbEmlcFlcdzeUSMPnaUELd1m)rvR2jaQ5TYVZDAx2mPvswcUDrZCuBMaYBMcZJzBMfKpKKLAMfeBLAM3GWfKpKKL4WbqswsZMtQc8ywe2acxq(qswI7XH0(OzZjvbEmlcdjewyEmlxTBOnkvNTYHa8C1A1pX6KhkP94qiSbeUG8HKSe3JdP9rZMtQc8ywegsiCoG256NosSae(6ve(RlLNhkXb1vRqSqb6KLaGyHYjfTgQQeCZSG86vouZuTBOnkvRoJnwOnVv(DUB7YMjTsYsWTlAMvaP71fwsZeGhl0w5f3mzF40hsZ8geUG8HKSephpPtwb4A1zSXcfHnGWLGWfKpKKL4ECiTpA2CsvGhZIW3IWqgHldHnGWLGWcZJcKMw6eeaHVvjcxq(qswI3jpSMjaxNTYHa(hkqiSbeUee2JdHWkocNQ5mNnNuf4XSCRaCnvQA8ecFlcxq(qswIdtwbcD2khc4FOaHWLHWLHWgq4Bq4C8eWL3PNlmpkqiSbe(geovZzE34AG)KOa)jH5nZkG0toRHYGBLxCZuyEmBZmhpPtwb4nVv(D6ZTlBM0kjlb3UOzwbKUxxyjntaESqBLxCZK9HtFinZC8eWL3PNlmpkqiSbeM1jpucGW3QeHlgHnGW3GWfKpKKL454jDYkaxRoJnwOiSbeUee(gewyEmlphpLeRLtLsSQhlue2acFdclmpMLRcXpjRaCES6SnG25iSbeovZzEhjESq1vv(tcZr4RxryH5XS8C8usSwovkXQESqrydi8niCQMZ8UX1a)jrb(tcZr4RxryH5XSCvi(jzfGZJvNTb0ohHnGWPAoZ7iXJfQUQYFsyocBaHVbHt1CM3nUg4pjkWFsyocxwZSci9KZAOm4w5f3mfMhZ2mZXt6KvaEZBLFhJPDzZKwjzj42fntH5XSntMyTAH5XSABa8Mj7dN(qAMLGWfKpKKL4ECiTpA2CsvGhZIW3IWqgHldHnGWPAoZ)6s6jRvNE0ZHNEBZ0gaxVYHAMaxwy5H1)4IhZ28M3m)rvR2jaQDzR8IBx2mPvswcUDrZK9HtFinZsqyH5rbstlDccGW3QeHliFijlX7gxd8Nef0zRCiG)HcecBaHlbH94qiSIJWPAoZzZjvbEml3kaxtLQgpHW3IWfKpKKL4WKvGqNTYHa(hkqiCziCziSbeovZzE34AG)KOa)jH5ntH5XSnZSvoeW)qbQ5TYVt7YMjTsYsWTlAMSpC6dPzMQ5mhuxTcXcfOtwcaIfQ(jbgcEvfHnGWPAoZb1vRqSqb6KLaGyHQFsGHG)0rIfGW3IWmb4ApouZuyEmBZufIFswb4nVv(DBx2mPvswcUDrZK9HtFinZunN554jGp)H)KW8MPW8y2MPke)KScWBER8(C7YMjTsYsWTlAMSpC6dPzMQ5mVBCnWFsuG)KW8MPW8y2MPke)KScWBERCJPDzZKwjzj42fnZkG096clPzcWJfAR8IBMSpC6dPzMQ5mhuxTcXcfOtwcaIfQ(jbgco80Brydi8niCjiSW8OaPPLobbq4BvIWfKpKKL4DYdRzcW1zRCiG)HcecBaHlbH94qiSIJWPAoZzZjvbEml3kaxtLQgpHW3IWfKpKKL4WKvGqNTYHa(hkqiCziCziSbe(geohpbC5D65cZJcecBaHlbHVbHt1CM3rIhluDvL)KWCe2acFdcNQ5mVBCnWFsuG)KWCe2acFdcR(ub9KZAOmyEoEsNScWrydiCjiSW8ywEoEsNScW5So5Hsae(wLi8Dq4Rxr4sqyxS06CXsLc8xagVa056dbNwjzjye2acZMXcp9wo8lqNfOtpjEh)jbgceUme(6veUee2flTohqYhluTpvwhNwjzjye2ac7YdLCEhjwVJRYCegskr47czeUmeUmeUSMzfq6jN1qzWTYlUzkmpMTzMJN0jRa8M3kVp1USzsRKSeC7IMzfq6EDHL0mb4XcTvEXnt2ho9H0mVbHZXtaxENEUW8OaHWgq4sq4sq4sqyH5XS8C8usSwovkXQESqr4RxryH5XSCvi(jzfGZPsjw1JfkcxgcBaHt1CM3rIhluDvL)KWCeUme(6veUee2flTohqYhluTpvwhNwjzjye2ac7YdLCEhjwVJRYCegskr47cze2acxccNQ5mVJepwO6Qk)jH5iSbe(gewyEmlhWMN1XPsjw1JfkcF9kcFdcNQ5mVBCnWFsuG)KWCe2acFdcNQ5mVJepwO6Qk)jH5iSbewyEmlhWMN1XPsjw1JfkcBaHVbH7gxd8Nef0avYAb6y1zBaTZr4Yq4Yq4YAMvaPNCwdLb3kV4MPW8y2MzoEsNScWBERCJJ2LntALKLGBx0mfMhZ2mzI1QfMhZQTbWBM2a46vouZuyEuG0UyP1bnVvUXz7YMjTsYsWTlAMSpC6dPzMQ5mxfIFywbC4pjmhHnGWmb4ApoecdjeovZzUke)WSc4WF6iXcqydimtaU2JdHWqcHt1CM)1L0twRo9ON)0rIfGWgq4sq4unN5Qq8dZkGd)jH5iSseovZzUke)WSc4WpsPAGlmfq4Rxr4unN5Qq8dZkGd)PJelaHHecZeGR94qiC)iSW8ywEoEkjwlNkLyvN0ECie(6veovZzUyPsb(laJxa6C9HGxvr4Rxr4Bq4VUuEEOehuxTcXcfOtwcaIfkNu0AOQsWiCzntH5XSntvi(jzfG38w5g3TlBM0kjlb3UOzY(WPpKMP6tf0qzW8I5a28Soe2acNQ5mVJepwO6Qk)jH5iSbe2flTohqYhluTpvwhNwjzjye2ac7YdLCEhjwVJRYCegskr47cze2acFdcxcclmpkqAAPtqae(wLiCb5djzjE34AG)KOGoBLdb8puGqydiCjiShhcHvCeovZzoBoPkWJz5wb4AQu14je(weUG8HKSehMSce6SvoeW)qbcHldHlRzkmpMTzQcXpjRa8M3kVyi3USzsRKSeC7IMj7dN(qAM3GWfKpKKL4QDdTrPA1zSXcfHnGWPAoZ7iXJfQUQYFsyocBaHVbHt1CM3nUg4pjkWFsyocBaHlbHfMhfin848a6goHWqcHVdcF9kclmpkqAAPtqae(wLiCb5djzjEN8WAMaCD2khc4FOaHWxVIWcZJcKMw6eeaHVvjcxq(qswI3nUg4pjkOZw5qa)dfieUSMPW8y2MPA3qBuQoBLdbAER8IlUDzZKwjzj42fnt2ho9H0mD5HsoVJeR3XvzocdjLi8DHmcBaHDXsRZbK8Xcv7tL1XPvswcUzkmpMTzcyZZ6AER8IVt7YMjTsYsWTlAMSpC6dPzkmpkqAAPtqae(we(ontH5XSnt4xGolqNEs8UM3kV472USzsRKSeC7IMj7dN(qAMLGWcZJcKMw6eeaHVvjcxq(qswI3jpSMjaxNTYHa(hkqiSbeUee2JdHWkocNQ5mNnNuf4XSCRaCnvQA8ecFlcxq(qswIdtwbcD2khc4FOaHWLHWL1mfMhZ2mZw5qa)dfOM3kV4(C7YMPW8y2MzoEkjwBZKwjzj42fnV5nt2CsvGhZQv7ea1USvEXTlBM0kjlb3UOzY(WPpKMzQMZC2CsvGhZYHNEBZuyEmBZ0gq7CG2yZkm0dTEZBLFN2LntALKLGBx0mh1MjG8MPW8y2Mzb5djzPMzbXwPMzQMZC2CsvGhZYF6iXcq4(r4unN5S5KQapMLdxFXJzr4(cHlbHzZyHNElNnNuf4XS8NosSaegsiCQMZC2CsvGhZYF6iXcq4YAMfKxVYHAMuPoTWeSMnNuf4XS6NosSGM3k)UTlBM0kjlb3UOzoQntbgUzkmpMTzwq(qswQzwqSvQz2NAMfKxVYHAMuPoTWeSMnNuf4XS6NosSGMj7dN(qAMPAoZb1vRqSqb6KLaGyHQFsGHGxvr4Rxr4cYhsYsCQuNwycwZMtQc8yw9thjwacFlcxm3yq4(cHHYG5hPueUVq4sq4unN5G6QviwOaDYsaqSq5hPunWfMciSIJWPAoZb1vRqSqb6KLaGyHYbUWuaHlR5TY7ZTlBM0kjlb3UOzY(WPpKMzQMZC2CsvGhZYHNEBZuyEmBZmjq1tw7FWua08w5gt7YMjTsYsWTlAMSpC6dPzkmpkqAAPtqae(weUye2acNQ5mNnNuf4XSC4P32mfMhZ2mTrHyHQtZj18w59P2LntALKLGBx0mzF40hsZmvZzoBoPkWJz5WtVfHnGWPAoZ)6s6jRvNE0ZHNEBZuyEmBZ8e)ppqpzTp)HwV5TYnoAx2mPvswcUDrZCLd1m7GqLEV7jbw37dG37fvqZuyEmBZSdcv69UNeyDVpaEVxubnt2ho9H0mt1CMZMtQc8ywEvfHnGWcZJz554jDYkaNZ6KhkbqyLimKrydiSW8ywEoEsNScW5pX6KhkP94qi8Timugm)iL28w5gNTlBMcZJzBMj7mW6jR9ostlDGOzsRKSeC7IM3k34UDzZuyEmBZ8qN5HqpzTTYcyn8tYb0mPvswcUDrZBLxmKBx2mfMhZ2m7nVfUafR(jWSYYOMjTsYsWTlAER8IlUDzZKwjzj42fnZkG096clPzcWJfAR8IBMSpC6dPzkgp9Ht8Kvao96JaC650kjlbJWgqywN8qjacFRseUye2acxccxcclmpMLNJN0jRaCoRtEOeqNFH5XSIfH7hHlbHt1CMZMtQc8yw(thjwacR4iCQMZ8Kvao96JaC65W1x8yweUme2yhHzZyHNElphpPtwb4C46lEmlcR4iCjiCQMZC2CsvGhZYF6iXcq4YqyJDeUeeovZzEYkaNE9rao9C46lEmlcR4imK5gdcxgcxgcFRsegYi81Ri8niSy80hoXtwb40RpcWPNtRKSemcF9kcFdc7ILwNNTYH0ZYPvswcgHVEfHt1CMZMtQc8yw(thjwacdjLiCQMZ8Kvao96JaC65W1x8ywe(6veovZzEYkaNE9rao98NosSaegsimK5gdcF9kctkAnuvjyEheQ07DpjW6EFa8EVOcqydimBgl80B5DqOsV39KaR79bW79IkqFxid5I7Z3H)0rIfGWqcHngeUme2acNQ5mNnNuf4XS8QkcBaHlbHVbHfMhZYbS5zDCQuIv9yHIWgq4BqyH5XSCvi(jzfGZJvNTb0ohHnGWPAoZ7iXJfQUQYRQi81RiSW8ywoGnpRJtLsSQhlue2acNQ5mVBCnWFsuGdp9we2acxccNQ5mVJepwO6QkhE6Ti81RiSy80hoXtwb40RpcWPNtRKSemcxgcF9kclgp9Ht8Kvao96JaC650kjlbJWgqyxS068SvoKEwoTsYsWiSbewyEmlxfIFswb48y1zBaTZrydiCQMZ8os8yHQRQC4P3IWgq4unN5DJRb(tIcC4P3IWL1mRasp5SgkdUvEXntH5XSnZC8KozfG38w5fFN2LntALKLGBx0mRas3RlSKMjapwOTYlUzY(WPpKM5niSy80hoXtwb40RpcWPNtRKSemcBaHlbHfMhfinT0jiacdjLiSW8OaPHhNhq3Wje(6ve(geMnJfE6TC1UH2OuD2khcWFsGHaHldHnGWSzHRHZJnt)kwntambM40kjlbJWgqywN8qjacFRseUye2acxccxcclmpMLNJN0jRaCoRtEOeqNFH5XSIfH7hHlbHliFijlXPsDAHjynBoPkWJz1pDKybiSIJWPAoZJnt)kwntambM4W1x8yweUme2yhHzZyHNElphpPtwb4C46lEmlcR4iCb5djzjovQtlmbRzZjvbEmR(PJelaHn2r4sq4unN5XMPFfRMjaMatC46lEmlcR4imK5gdcxgcxgcFRsegYi81RiCb5djzjovQtlmbRzZjvbEmR(PJelaHHKseovZzESz6xXQzcGjWehU(IhZIWxVIWPAoZJnt)kwntambM4pDKybimKqyiZngeUme2acNQ5mNnNuf4XS8QkcBaHVbHt1CMNJNa(8h(tcZrydi8niCQMZ8UX1a)jrb(tcZrydiC34AG)KOGgOswlqhRoBdODoc3pcNQ5mVJepwO6Qk)jH5imKq470mRasp5SgkdUvEXntH5XSnZC8KozfG38w5fF32LntALKLGBx0mRas3RlSKMjapwOTYlUzY(WPpKM5niSy80hoXtwb40RpcWPNtRKSemcBaHlbHfMhfinT0jiacdjLiSW8OaPHhNhq3Wje(6ve(geMnJfE6TC1UH2OuD2khcWFsGHaHldHnGW3GWSzHRHZJnt)kwntambM40kjlbJWgqywN8qjacFRseUye2acNQ5mNnNuf4XS8QkcBaHVbHt1CMNJNa(8h(tcZrydi8niCQMZ8UX1a)jrb(tcZrydiC34AG)KOGgOswlqhRoBdODoc3pcNQ5mVJepwO6Qk)jH5imKq470mRasp5SgkdUvEXntH5XSnZC8KozfG38w5f3NBx2mPvswcUDrZK9HtFinZVUuEEOehoaSq1gR8qOzZ5ilmNu0AOQsWiSbeovZzoCayHQnw5HqZMZrwyo80BrydiCQMZC4aWcvBSYdHMnNJSWA5zYsC4P3IWgqy2mw4P3Yt1CwdhawOAJvEi0S5CKfM)KadrZuyEmBZKn11PhOswBZBLxSX0USzsRKSeC7IMj7dN(qAMFDP88qjoCayHQnw5HqZMZrwyoPO1qvLGrydiCQMZC4aWcvBSYdHMnNJSWC4P3IWgq4unN5WbGfQ2yLhcnBohzH1YZKL4WtVfHnGWSzSWtVLNQ5SgoaSq1gR8qOzZ5ilm)jbgIMPW8y2MP8mzjnvQQDaXSnVvEX9P2LntALKLGBx0mzF40hsZ8RlLNhkXHdaluTXkpeA2CoYcZjfTgQQemcBaHt1CMdhawOAJvEi0S5CKfMdp9we2acNQ5mhoaSq1gR8qOzZ5ilSo)dW5WtVTzkmpMTzM)b4PX6nVvEXghTlBM0kjlb3UOzkmpMTzYeRvlmpMvBdG3mTbW1RCOMPW8OaPDXsRdAER8InoBx2mPvswcUDrZSciDVUWsAMa8yH2kV4Mj7dN(qAMPAoZzZjvbEmlhE6TiSbeUee(RlLNhkXHdaluTXkpeA2CoYcZjfTgQQemcReHt1CMdhawOAJvEi0S5CKfMxvr4YqydiCjiSW8yw(HCAEES6SnG25iSbewyEml)qonppwD2gq7C9thjwacdjLimK5gdcF9kclmpMLdyZZ64uPeR6XcfHnGWcZJz5a28SoovkXQoPF6iXcqyiHWqMBmi81RiSW8ywEoEkjwlNkLyvpwOiSbewyEmlphpLeRLtLsSQt6NosSaegsimK5gdcF9kclmpMLRcXpjRaCovkXQESqrydiSW8ywUke)KScW5uPeR6K(PJelaHHecdzUXGWL1mRasp5SgkdUvEXntH5XSnt2CsvGhZ28w5fBC3USzsRKSeC7IMj7dN(qAMPAoZzZjvbEml3kaxtLQgpHWqsjclmpMLZMtQc8ywUvaUUci4MPW8y2MP64XSnVv(DGC7YMjTsYsWTlAMSpC6dPzMQ5mNnNuf4XSCRaCnvQA8ecdjLiSW8ywoBoPkWJz5wb46kGGBMcZJzBMj7mW6C9HO5TYVtXTlBM0kjlb3UOzY(WPpKMzQMZC2CsvGhZYTcW1uPQXtimKuIWcZJz5S5KQapMLBfGRRacUzkmpMTzMOhqVcXcT5TYVZDAx2mPvswcUDrZK9HtFinZunN5S5KQapMLBfGRPsvJNqyiPeHfMhZYzZjvbEml3kaxxbeCZuyEmBZmhpLSZa38w535UTlBM0kjlb3UOzY(WPpKMzQMZC2CsvGhZYTcW1uPQXtimKuIWcZJz5S5KQapMLBfGRRacUzkmpMTzklJa(lwntS2M3k)o952LntALKLGBx0mzF40hsZmvZzoBoPkWJz5wb4AQu14jegskryH5XSC2CsvGhZYTcW1vab3mfMhZ2mRashoDanVv(DmM2LntALKLGBx0mzF40hsZmvZzE34AG)KOa)jH5iSbewyEuG00sNGai8Tkr4cYhsYsC2CsvGhZQZw5qa)dfOMPW8y2Mz2khc4FOa18w53Pp1USzsRKSeC7IMj7dN(qAMPAoZb1vRqSqb6KLaGyHQFsGHGxvrydiCQMZCqD1keluGozjaiwO6Neyi4pDKybi8TimtaU2Jd1mfMhZ2mvH4NKvaEZBLFhJJ2LntALKLGBx0mzF40hsZmvZzEoEc4ZF4pjmVzkmpMTzQcXpjRa8M3k)ogNTlBM0kjlb3UOzY(WPpKMzQMZCvi(HzfWH)KWCe2acNQ5mxfIFywbC4pDKybi8TimtaU2JdHWgq4sq4unN5S5KQapML)0rIfGW3IWmb4ApoecF9kcNQ5mNnNuf4XSC4P3IWL1mfMhZ2mvH4NKvaEZBLFhJ72LntALKLGBx0mzF40hsZmvZzE34AG)KOa)jH5iSbeovZzoBoPkWJz5v1MPW8y2MPke)KScWBER87c52LntALKLGBx0mzF40hsZu9PcAOmyEXCaBEwhcBaHt1CM3rIhluDvL)KW8MPW8y2MPke)KScWBER87wC7YMjTsYsWTlAMSpC6dPzMQ5mNnNuf4XS8QAZuyEmBZuTBOnkvNTYHanVv(DVt7YMjTsYsWTlAMSpC6dPzMQ5mNnNuf4XSC4P3IWgqy2mw4P3YzZjvbEml)PJelaHHecZeGR94qiSbe(geMnlCnCE2khslm2tEmlNwjzj4MPW8y2MzoEkjwBZBLF372USzsRKSeC7IMj7dN(qAMPAoZzZjvbEml)PJelaHVfHzcW1ECie2acNQ5mNnNuf4XS8QkcF9kcNQ5mNnNuf4XSC4P3IWgqy2mw4P3YzZjvbEml)PJelaHHecZeGR94qntH5XSntaBEwxZBLF3(C7YMjTsYsWTlAMSpC6dPzMQ5mNnNuf4XS8NosSaegsimugm)iLIWgqyH5rbstlDccGW3IWf3mfMhZ2mTrHyHQtZj18w531yAx2mPvswcUDrZK9HtFinZunN5S5KQapML)0rIfGWqcHHYG5hPue2acNQ5mNnNuf4XS8QAZuyEmBZe(fOZc0PNeVR5TYVBFQDzZKwjzj42fnt2ho9H0mD5HsoVJeR3XvzocdjLi8DHmcBaHDXsRZbK8Xcv7tL1XPvswcUzkmpMTzcyZZ6AEZBMcZJcK2flToODzR8IBx2mPvswcUDrZK9HtFintH5rbstlDccGW3IWfJWgq4unN5S5KQapMLdp9we2acxccxq(qswI7XH0(OzZjvbEmlcFlcZMXcp9wUnkeluDAojoC9fpMfHVEfHliFijlX94qAF0S5KQapMfHHKsegYiCzntH5XSntBuiwO60CsnVv(DAx2mPvswcUDrZK9HtFinZBq4cYhsYsC4aijlPzZjvbEmlcBaHliFijlX94qAF0S5KQapMfHHKsegYi81RiCjimBgl80B5hYP55W1x8ywegsiCb5djzjUhhs7JMnNuf4XSiSbe(ge2flTo)RlPNSwD6rpNwjzjyeUme(6ve2flTo)RlPNSwD6rpNwjzjye2acNQ5m)RlPNSwD6rpVQIWgq4cYhsYsCpoK2hnBoPkWJzr4BryH5XS8d508C2mw4P3IWxVIW5aANRF6iXcqyiHWfKpKKL4ECiTpA2CsvGhZ2mfMhZ2mpKtZ38w53TDzZKwjzj42fnt2ho9H0mDXsRZflvkWFby8cqNRpeCALKLGrydiCjiCQMZC2CsvGhZYHNElcBaHVbHt1CM3nUg4pjkWFsyocxwZuyEmBZe(fOZc0PNeVR5nVzcCzHLhw)JlEmB7Yw5f3USzsRKSeC7IMj7dN(qAMLGWcZJcKMw6eeaHVvjcxq(qswI3nUg4pjkOZw5qa)dfie2acxcc7XHqyfhHt1CMZMtQc8ywUvaUMkvnEcHVfHliFijlXHjRaHoBLdb8puGq4Yq4YqydiCQMZ8UX1a)jrb(tcZBMcZJzBMzRCiG)HcuZBLFN2LntALKLGBx0mzF40hsZmvZzEoEc4ZF4pjmVzkmpMTzQcXpjRa8M3k)UTlBM0kjlb3UOzY(WPpKMzQMZ8UX1a)jrb(tcZrydiCQMZ8UX1a)jrb(thjwacdjewyEmlphpLeRLtLsSQtApouZuyEmBZufIFswb4nVvEFUDzZKwjzj42fnt2ho9H0mt1CM3nUg4pjkWFsyocBaHlbHvFQGgkdMxmphpLeRfHVEfHZXtaxENEUW8OaHWxVIWcZJz5Qq8tYkaNhRoBdODocxwZuyEmBZufIFswb4nVvUX0USzsRKSeC7IMj7dN(qAMPAoZb1vRqSqb6KLaGyHQFsGHGxvrydiCjimBgl80B5FDj9K1Qtp65pDKybiC)iSW8yw(xxspzT60JEovkXQoP94qiC)imtaU2JdHW3IWPAoZb1vRqSqb6KLaGyHQFsGHG)0rIfGWxVIW3GWUyP15FDj9K1Qtp650kjlbJWLHWgq4cYhsYsCpoK2hnBoPkWJzr4(ryMaCThhcHVfHt1CMdQRwHyHc0jlbaXcv)Kadb)PJelOzkmpMTzQcXpjRa8M3kVp1USzsRKSeC7IMj7dN(qAMPAoZ7gxd8Nef4pjmhHnGWU8qjN3rI174QmhHHKse(UqgHnGWUyP15as(yHQ9PY640kjlb3mfMhZ2mvH4NKvaEZBLBC0USzsRKSeC7IMj7dN(qAMPAoZvH4hMvah(tcZrydimtaU2JdHWqcHt1CMRcXpmRao8NosSae2acxccNQ5mxfIFywbC4pjmhHvIWPAoZvH4hMvah(rkvdCHPacF9kcNQ5mxfIFywbC4pDKybimKqyMaCThhcH7hHfMhZYZXtjXA5uPeR6K2JdHWxVIWPAoZflvkWFby8cqNRpe8QkcF9kcFdc)1LYZdL4G6QviwOaDYsaqSq5KIwdvvcgHlRzkmpMTzQcXpjRa8M3k34SDzZKwjzj42fnZkG096clPzcWJfAR8IBMSpC6dPzEdcNJNaU8o9CH5rbcHnGW3GWfKpKKL454jDYkaxRoJnwOiSbeUeeUeeUeewyEmlphpLeRLtLsSQhlue(6vewyEmlxfIFswb4CQuIv9yHIWLHWgq4unN5DK4Xcvxv5pjmhHldHVEfHlbHDXsRZbK8Xcv7tL1XPvswcgHnGWU8qjN3rI174QmhHHKse(UqgHnGWLGWPAoZ7iXJfQUQYFsyocBaHVbHfMhZYbS5zDCQuIv9yHIWxVIW3GWPAoZ7gxd8Nef4pjmhHnGW3GWPAoZ7iXJfQUQYFsyocBaHfMhZYbS5zDCQuIv9yHIWgq4Bq4UX1a)jrbnqLSwGowD2gq7CeUmeUmeUSMzfq6jN1qzWTYlUzkmpMTzMJN0jRa8M3k34UDzZKwjzj42fnt2ho9H0mvFQGgkdMxmhWMN1HWgq4unN5DK4Xcvxv5pjmhHnGWUyP15as(yHQ9PY640kjlbJWgqyxEOKZ7iX6DCvMJWqsjcFxiJWgq4Bq4sqyH5rbstlDccGW3QeHliFijlX7gxd8Nef0zRCiG)HcecBaHlbH94qiSIJWPAoZzZjvbEml3kaxtLQgpHW3IWfKpKKL4WKvGqNTYHa(hkqiCziCzntH5XSntvi(jzfG38w5fd52LntALKLGBx0mzF40hsZ8geUG8HKSexTBOnkvRoJnwOiSbeUee(ge2flTop)Zr7DKwaDeGtRKSemcF9kclmpkqAAPtqae(weUyeUme2acxcclmpkqAAPtqae(weUye2aclmpkqA4X5b0nCcHHecFhe(6vewyEuG00sNGai8Tkr4cYhsYs8o5H1mb46SvoeW)qbcHVEfHfMhfinT0jiacFRseUG8HKSeVBCnWFsuqNTYHa(hkqiCzntH5XSnt1UH2OuD2khc08w5fxC7YMjTsYsWTlAMcZJzBMmXA1cZJz12a4ntBaC9khQzkmpkqAxS06GM3kV470USzsRKSeC7IMj7dN(qAMcZJcKMw6eeaHVfHlUzkmpMTzc)c0zb60tI318w5fF32LntALKLGBx0mzF40hsZ0Lhk58osSEhxL5imKuIW3fYiSbe2flTohqYhluTpvwhNwjzj4MPW8y2MjGnpRR5TYlUp3USzsRKSeC7IMj7dN(qAMcZJcKMw6eeaHVvjcxq(qswI3jpSMjaxNTYHa(hkqiSbeUee2JdHWkocNQ5mNnNuf4XSCRaCnvQA8ecFlcxq(qswIdtwbcD2khc4FOaHWL1mfMhZ2mZw5qa)dfOM3kVyJPDzZuyEmBZmhpLeRTzsRKSeC7IM3kV4(u7YMPW8y2MjGnpRRzsRKSeC7IM38MP6tS5KeVDzR8IBx2mfMhZ2mLNjlPJ1jRLyEZKwjzj42fnVv(DAx2mPvswcUDrZCuBMaYBMcZJzBMfKpKKLAMfeBLAM3bH7le2flTopBLdPvfN1XPvswcgH7hHVlc3xi8niSlwADE2khsRkoRJtRKSeCZSG86vouZSBCnWFsuqNTYHa(hkqnt2ho9H0mliFijlX7gxd8Nef0zRCiG)HcecReHHCZBLF32LntALKLGBx0mh1MjG8MPW8y2Mzb5djzPMzbXwPM5Dq4(cHDXsRZZw5qAvXzDCALKLGr4(r47IW9fcFdc7ILwNNTYH0QIZ640kjlb3mliVELd1m7KhwZeGRZw5qa)dfOMj7dN(qAMfKpKKL4DYdRzcW1zRCiG)HcecReHHCZBL3NBx2mPvswcUDrZCuBMaYBMcZJzBMfKpKKLAMfeBLAM3fH7le2flTopBLdPvfN1XPvswcgH7hH7tiCFHW3GWUyP15zRCiTQ4SooTsYsWnZcYRx5qnt2CsvGhZQZw5qa)dfOMj7dN(qAMfKpKKL4S5KQapMvNTYHa(hkqiSsegYnVvUX0USzsRKSeC7IM5O2mFcqEZuyEmBZSG8HKSuZSG86vouZeMSce6SvoeW)qbQzctzPA9MjKBER8(u7YMjTsYsWTlAMJAZ8ja5ntH5XSnZcYhsYsnZcYRx5qntfIf2glu9tWvMhZ2mHPSuTEZeY8708w5ghTlBM0kjlb3UOzoQnta5ntH5XSnZcYhsYsnZcITsntH5XSCqxK9yHQvNE0ZzcW1ECie2yhHfMhZYbDr2JfQwD6rp3dMcApoec3xi8DBMfKxVYHAMGUi7XcvRo9Ox)eCL5XSnt2ho9H0mztbAL15BaTZ1zHAERCJZ2LntALKLGBx0mh1MjG8MPW8y2Mzb5djzPMzbXwPMjPO1qvLG5hzJmb8rpz9rGxcaq4RxrysrRHQkbZHAf4q85b6KadLq4RxrysrRHQkbZHAf4q85b6dblwBmlcF9kctkAnuvjyEaDdpMvFeOeqNRacHVEfHjfTgQQem3nEzjGojVca1yjacF9kctkAnuvjyUy81N8UbObXcLG1Q26rGsi81RimPO1qvLG5YYcADTc746jR7fa45GWxVIWKIwdvvcMd6gMcPWPhOZYcfHVEfHjfTgQQemFP6lwnaIvubKM2ozz0JWxVIWKIwdvvcMNelLJN0PxwwxZSG86vouZKnNuf4XS6z1va18w5g3TlBM0kjlb3UOzoQnta5ntH5XSnZcYhsYsnZcITsntsrRHQkbZfJh0jVa05zD9K1Qtp6rydiCb5djzjoBoPkWJz1ZQRaQzwqE9khQzMN11Wtnzj9S6kGAER8IHC7YMjTsYsWTlAMJAZeqEZuyEmBZSG8HKSuZSGyRuZSyJZMzb51RCOMzEwxpzT60JET6tS5KexZ6KDjBZK9HtFinZcYhsYs88SUgEQjlPNvxbecBaHVbHDXsRZZXtaxENEoTsYsWiSbeUG8HKSeppRRNSwD6rVw9j2CsIRzDYUKfHvIWqU5TYlU42LntALKLGBx08w5fFN2LntALKLGBx0mx5qntX4bDYlaDEwxpzT60J(MPW8y2MPy8Go5fGopRRNSwD6rFZBLx8DBx2mfMhZ2mpX)ZRJJaLAM0kjlb3UO5TYlUp3USzkmpMTzQoEmBZKwjzj42fnVvEXgt7YMPW8y2MPke)KScWBM0kjlb3UO5nV5nZc0dIzBLFhiFhixmKlU4Mzp53yHcAMkcueASr5kglVpUXkcJWx2riCCuN3r488iCFaMYs169be(jfTgpbJWG5qiSu95iobJWSozHsaoQiftXsi8DGSXkcRyNTa9obJW9b2uGwzDEFmoTsYsW9be2heUpWMc0kRZ7J1hq4skU0Y4OIqfPiqrOXgLRyS8(4gRimcFzhHWXrDEhHZZJW9b1NyZjjEFaHFsrRXtWimyoeclvFoItWimRtwOeGJksXuSecBCySIWk2zlqVtWiCFGnfOvwN3hJtRKSeCFaH9bH7dSPaTY68(y9beUKIlTmoQiurkgpQZ7emc3NqyH5XSiSnaoGJkQzcujwR8(0DBMQ)Kdl1m7BewrgpHWglcucvuFJWDURcmwV)EOH3vtC2CUheNQv8yw2lz)EqCy3JkQVryfZmFs0JWfxSri8DG8DGmQiur9ncRy7Kfkbmwrf13iSIJWkgaecNdODU(PJelaHFX7OhH9ozryxEOKZ94qAF0WbHW55ryRaCfhqSzHryjf2WHaHRabkb4OI6BewXryfdQWItiSDGgme(jJvewXuLfWiSXLNKdGJkQVryfhHvmndGweMjahHFsrRXthADacNNhHvSZjvbEmlcxsWjUrim8S9bhH7glmchocNNhHfeo)eOdHnwiNMhHzcWlJJkQVryfhHnUeajzjewweMw)HaH9oXr4Et1cJWpbQwhHJfHfeUtEyMaCeUpcIFswb4iCSkou5qCur9ncR4iSX1vswcHb(hmhHzDetHyHIWZIWccNPEiCEEfaiCSiS3riSIW(iftiSpi8tWvgHW9Mxb7iWCurOI6Be24APeR6emcNO88ecZMtsCeorqJfWryfHmgP6aeENvX7K)KRwewyEmlaHN1cbhvKW8ywax9j2CsI3VY7LNjlPJ1jRLyoQO(gHVSlaiCb5djzjegOsSiheaH9ocH36jrpcpze2Lhk5aewCeUxxW6qyfXXryt)jrbewrALdb8puGai8uDqati8Kryf7CsvGhZIWGUPAHr4eHWvabZrfjmpMfWvFInNK49R8(cYhsYsgTYHu2nUg4pjkOZw5qa)dfiJgvLaYnkYkliFijlX7gxd8Nef0zRCiG)HcKsiBubXwjL3PVCXsRZZw5qAvXzDCALKLG7)U91nUyP15zRCiTQ4SooTsYsWOI6Be(YUaGWfKpKKLqyGkXICqae27ieERNe9i8KryxEOKdqyXr4EDbRdHveLhgHvScWryfPvoeW)qbcGWt1bbmHWtgHvSZjvbEmlcd6MQfgHtecxbemclaeohwl9CurcZJzbC1NyZjjE)kVVG8HKSKrRCiLDYdRzcW1zRCiG)HcKrJQsa5gfzLfKpKKL4DYdRzcW1zRCiG)HcKsiBubXwjL3PVCXsRZZw5qAvXzDCALKLG7)U91nUyP15zRCiTQ4SooTsYsWOI6Be(YUaGWfKpKKLqyGkXICqae27ieERNe9i8KryxEOKdqyXr4EDbRdHvehhHn9NefqyfPvoeW)qbcGWYtiCfqWimC9JfkcRyNtQc8ywoQiH5XSaU6tS5KeVFL3xq(qswYOvoKs2CsvGhZQZw5qa)dfiJgvLaYnkYkliFijlXzZjvbEmRoBLdb8puGuczJki2kP8U9LlwADE2khsRkoRJtRKSeC)9P(6gxS068SvoKwvCwhNwjzjyur9ncFzxaq4cYhsYsiCaq4kGGryFqyGkXImeiS3riSCM66i8Krypoechlcdi2SWae27ehHpvGJWQcaGWs2PhHvSZjvbEmlctLQgpbq4eLNNqyfPvoeW)qbcGW9cRfHtecxbemcVZFeRfcoQiH5XSaU6tS5KeVFL3xq(qswYOvoKsyYkqOZw5qa)dfiJGPSuTUsiB0OQ8ja5OI6Bewrq4DiSX2yHTXc1iewXoNuf4XS9bacZMXcp9weUxyTiCIq4NGRmcgHtqGWcc)YcphewotDDJq4u1ryVJq4TEs0JWtgHzF4aeg4Y7aeUa9qGWDb0oewYo9iSW8OG4XcfHvSZjvbEmlcllmcdStpacdp9we2NEYddqyVJqyAHr4jJWk25KQapMTpaqy2mw4P3YryfbD0IWhrHyHIWWelaXSaeowe27iewryFKIjJqyf7CsvGhZ2hai8thj2yHIWSzSWtVfHdac)eCLrWiCcce27cacNFH5XSiSpiSWytDDeoppcBSnwyBSq5OIeMhZc4QpXMts8(vEFb5djzjJw5qkviwyBSq1pbxzEmRrWuwQwxjK53XOrv5taYrfjmpMfWvFInNK49R8(cYhsYsgTYHuc6IShluT60JE9tWvMhZA0OQeqUrfeBLukmpMLd6IShluT60JEotaU2JdzSlmpMLd6IShluT60JEUhmf0ECO(6UgfzLSPaTY68nG256SqCALKLGrfjmpMfWvFInNK49R8(cYhsYsgTYHuYMtQc8yw9S6kGmAuvci3OcITskjfTgQQem)iBKjGp6jRpc8saW1RKIwdvvcMd1kWH4Zd0jbgkD9kPO1qvLG5qTcCi(8a9HGfRnM96vsrRHQkbZdOB4XS6JaLa6CfqxVskAnuvjyUB8YsaDsEfaQXsGRxjfTgQQemxm(6tE3a0GyHsWAvB9iqPRxjfTgQQemxwwqRRvyhxpzDVaapNRxjfTgQQemh0nmfsHtpqNLf61RKIwdvvcMVu9fRgaXkQastBNSm6VELu0AOQsW8KyPC8Ko9YY6qfjmpMfWvFInNK49R8(cYhsYsgTYHuMN11Wtnzj9S6kGmAuvci3OcITskjfTgQQemxmEqN8cqNN11twRo9O3qb5djzjoBoPkWJz1ZQRacvuFJWx2faeUG8HKSecdto9Nyjac3RJwewrOXd6Kx6daewroRJWtgH7JME0JWbaHRacgHtuEEcH9ocHvRwlchzeoLfEEwxpzT60JET6tS5KexZ6KDjlchaeEhhHbQelYbbZrfjmpMfWvFInNK49R8(cYhsYsgTYHuMN11twRo9OxR(eBojX1SozxYA0OQeqUrfeBLuwSXPrrwzb5djzjEEwxdp1KL0ZQRaYWnUyP1554jGlVtpNwjzjydfKpKKL45zD9K1Qtp61QpXMtsCnRt2LSkHmQiH5XSaU6tS5KeVFL3dwrf0nUg4IdqfjmpMfWvFInNK49R8(kG0HthJw5qkfJh0jVa05zD9K1Qtp6rfjmpMfWvFInNK49R8(t8)864iqjurcZJzbC1NyZjjE)kVxD8ywurcZJzbC1NyZjjE)kVxfIFswb4OIqf13iSX1sjw1jyeMkqpeiShhcH9ocHfMppchaewkiHvswIJksyEmlqjBQRtpqLSwJISYB(6s55HsC4aWcvBSYdHMnNJSWCsrRHQkbJksyEmlOFL3xq(qswYOvoKspoK2hnBoPkWJznAuvci3OcITskDXsRZZXtaxENEoTsYsW9voEc4Y70ZF6iXc6Ve2mw4P3YzZjvbEml)PJelOVkPyfVG8HKSexHyHTXcv)eCL5XS9LlwADUcXcBJfkNwjzj4YkRVUHnJfE6TC2CsvGhZYFsGHOVs1CMZMtQc8ywo80BrfjmpMf0VY7bDr2JfQwD6rVrrwzQMZC2CsvGhZYHNERHunN5FDj9K1Qtp65WtV1aBgl80B5S5KQapML)0rIfClKnucBgl80B5FDj9K1Qtp65pDKyb3c5RxVXflTo)RlPNSwD6rpNwjzj4YqfjmpMf0VY7FboK11av5vWOiRSKunN5S5KQapMLdp9wdPAoZ)6s6jRvNE0ZHNERHsyZyHNElNnNuf4XS8NosSairLsSQtApo01RSzSWtVLZMtQc8yw(thjwWTSzSWtVL)cCiRRbQYRahU(IhZwwzxVwsQMZ8VUKEYA1Ph98QQb2mw4P3YzZjvbEml)PJel427c5YqfjmpMf0VY7HjX7sZVKrrwzQMZC2CsvGhZYHNERHunN5FDj9K1Qtp65WtV1aBgl80B5S5KQapML)0rIfajQuIvDs7XHqfjmpMf0VY7pX)ZRJJaLmkYkt1CMZMtQc8ywo80BnatPAoZFboK11av5vqxOAx6Luydhco80BrfjmpMf0VY7RashoDmALdPumEqN8cqNN11twRo9O3OiRSG8HKSe3JdP9rZMtQc8ywiP0y6VyJPVkiFijlXZZ6A4PMSKEwDfqgkiFijlX94qAF0S5KQapM9wiJksyEmlOFL3dTkpCiREYAX4PF8oJISYskiFijlX94qAF0S5KQapMfsfd5RxZb0ox)0rIfaPcYhsYsCpoK2hnBoPkWJzldvKW8ywq)kVNnlJw)fNG1zRCiurcZJzb9R8(Ne1yHQZw5qaurcZJzb9R8(8WQacwlgp9Ht6ejhurcZJzb9R8E16hziIfQozfGJksyEmlOFL3)HQQL0XQbQcJqfjmpMf0VY79osx30uxyDEEgHkQVr4(4KJWEhHWWbGfQ2yLhcnBohzHr4unNr4QQriCDTeaGWS5KQapMfHdacdMz5OIeMhZc6x59SPUo9avYAnkYk)6s55HsC4aWcvBSYdHMnNJSWCsrRHQkbBGnJfE6T8unN1WbGfQ2yLhcnBohzH5pjWqyivZzoCayHQnw5HqZMZrwyT8mzjo80BnWMXcp9woBoPkWJz5pDKyb3ExiB4MunN5WbGfQ2yLhcnBohzH5vvurcZJzb9R8E5zYsAQuv7aIznkYk)6s55HsC4aWcvBSYdHMnNJSWCsrRHQkbBGnJfE6T8unN1WbGfQ2yLhcnBohzH5pjWqyivZzoCayHQnw5HqZMZrwyT8mzjo80BnWMXcp9woBoPkWJz5pDKyb3ExiB4MunN5WbGfQ2yLhcnBohzH5vvurcZJzb9R8(8papnw3OiR8RlLNhkXHdaluTXkpeA2CoYcZjfTgQQeSb2mw4P3Yt1CwdhawOAJvEi0S5CKfM)KadHHunN5WbGfQ2yLhcnBohzH15FaohE6TgyZyHNElNnNuf4XS8NosSGBVlKnCtQMZC4aWcvBSYdHMnNJSW8QkQiH5XSG(vE)xxspzT60JEJISYunN5FDj9K1Qtp65WtV1qjfKpKKL4ECiTpA2CsvGhZEBQMZ8VUKEYA1Ph9C46lEmRHcYhsYsCpoK2hnBoPkWJzVvyEmlphpPtwb48C1A1pX6KhkP94qxVwq(qswI7XH0(OzZjvbEm7T5aANRF6iXckdvKW8ywq)kVNjwRwyEmR2ga3OvoKs2CsvGhZQv7eazuKvEtb5djzjoCaKKL0S5KQapM1qb5djzjUhhs7JMnNuf4XSqsjKrf13i8LkMnUOy2yfHVSJq4IngeEj5ryVJqyAHr4jJWExaqy2SWHhZIWbaHLfHLpf(lpeimBw4WJzr488imRJykelueoYiSzxK9yHIW9rtp6r4EH1IWjcHRQimyMLJWkYyHrybHpZtiSWy1xCcH7jqGW(GWkStpe27ehHn7IShlueUpA6rpc3lSwew9NKKSqGWjcHRacgHtuEEcH9ocHnn2EbcR(dJJksyEmlOFL3xq(qswYOvoKYC8KozfGRvNXgluJki2kP8McYhsYsC4aijlPzZjvbEmRHcYhsYsCpoK2hnBoPkWJzHKW8ywEoEsNScW55Q1QFI1jpus7XHu8cYhsYsCqxK9yHQvNE0RFcUY8y2(Qe2mw4P3YbDr2JfQwD6rp)PJelasfKpKKL4ECiTpA2CsvGhZwMHcYhsYsCpoK2hnBoPkWJzHuoG256NosSGRx)6s55HsCqD1keluGozjaiwOCsrRHQkbBqyEmlphpPtwb4CwN8qjGo)cZJzflKeMhZYZXt6Kvao)iLQzDYdLakoK5gJHsyZyHNElh0fzpwOA1Ph98NosSGBl2yUE9g2uGwzD(gq7CDwioTsYsWLHksyEmlOFL3ZeRvlmpMvBdGB0khs5pQA1obqgfzLPAoZ)6s6jRvNE0ZRQgkPG8HKSe3JdP9rZMtQc8y2BHCzOIeMhZc6x59fKpKKLmALdPuTBOnkvRoJnwOgvqSvs5nfKpKKL4WbqswsZMtQc8ywdfKpKKL4ECiTpA2CsvGhZcjH5XSC1UH2OuD2khcWZvRv)eRtEOK2JdzOG8HKSe3JdP9rZMtQc8ywiLdODU(PJel461VUuEEOehuxTcXcfOtwcaIfkNu0AOQsWOI6BewrqhTiSIO8Wmb4XcfHvKw5qiSP)HcKriSImEcHVWkahGWGUPAHr4eHWvabJW(GWqPLEXjewrCCe20FsuaGWYcJW(GWuPoTWi8fwb40JWglcWPNJksyEmlOFL3NJN0jRaCJQasp5SgkdwzXgvbKUxxyjntaESqvwSrrw5nfKpKKL454jDYkaxRoJnwOgkPG8HKSe3JdP9rZMtQc8y2BHCzgkryEuG00sNGa3QSG8HKSeVtEyntaUoBLdb8puGmuIhhsXt1CMZMtQc8ywUvaUMkvnE62cYhsYsCyYkqOZw5qa)dfOYkZWn54jGlVtpxyEuGmCtQMZ8UX1a)jrb(tcZrf13iSXL6hluewrgpbC5D6ncHvKXti8fwb4aewEcHRacgHbXjSYBHaH9bHHRFSqryf7CsvGhZYr4(40sVyTqyec7DeeiS8ecxbemc7dcdLw6fNqyfXXryt)jrbac3RJweM9Hdq4EH1IW74iCIq4EcWjyewwyeUx4Di8fwb40JWglcWP3ie27iiqyq3uTWiCIqyG6tcmcpvhH9bHpsSUelc7DecFHvao9iSXIaC6r4unN5OIeMhZc6x5954jDYka3OkG0toRHYGvwSrvaP71fwsZeGhluLfBuKvMJNaU8o9CH5rbYaRtEOe4wLfB4McYhsYs8C8KozfGRvNXgludLCJW8ywEoEkjwlNkLyvpwOgUryEmlxfIFswb48y1zBaTZnKQ5mVJepwO6Qk)jH5xVkmpMLNJNsI1YPsjw1JfQHBs1CM3nUg4pjkWFsy(1RcZJz5Qq8tYkaNhRoBdODUHunN5DK4Xcvxv5pjm3WnPAoZ7gxd8Nef4pjmVmurcZJzb9R8EMyTAH5XSABaCJw5qkbUSWYdR)XfpM1OiRSKcYhsYsCpoK2hnBoPkWJzVfYLzivZz(xxspzT60JEo80BrfHksyEmlGlmpkqAxS06aL2OqSq1P5KmkYkfMhfinT0jiWTfBivZzoBoPkWJz5WtV1qjfKpKKL4ECiTpA2CsvGhZElBgl80B52OqSq1P5K4W1x8y2RxliFijlX94qAF0S5KQapMfskHCzOIeMhZc4cZJcK2flToOFL3FiNM3OiR8McYhsYsC4aijlPzZjvbEmRHcYhsYsCpoK2hnBoPkWJzHKsiF9AjSzSWtVLFiNMNdxFXJzHub5djzjUhhs7JMnNuf4XSgUXflTo)RlPNSwD6rpNwjzj4YUE1flTo)RlPNSwD6rpNwjzjydPAoZ)6s6jRvNE0ZRQgkiFijlX94qAF0S5KQapM9wH5XS8d508C2mw4P3E9AoG256NosSaivq(qswI7XH0(OzZjvbEmlQiH5XSaUW8OaPDXsRd6x59WVaDwGo9K4DgfzLUyP15ILkf4VamEbOZ1hcoTsYsWgkjvZzoBoPkWJz5WtV1WnPAoZ7gxd8Nef4pjmVmurOIeMhZc4S5KQapMvR2jasPnG25aTXMvyOhADJISYunN5S5KQapMLdp9wur9ncBCf4XrCcH7MEiSDwOiSIDoPkWJzr4EH1IWwb4iS3jRcae2he2SUiSX2yH2hai8fwcaIfkc7dcdto9NyjeUB6HWkY4je(cRaCacd6MQfgHtecxbemhvKW8ywaNnNuf4XSA1obq9R8(cYhsYsgTYHusL60ctWA2CsvGhZQF6iXcmAuvci3OcITskt1CMZMtQc8yw(thjwq)PAoZzZjvbEmlhU(IhZ2xLWMXcp9woBoPkWJz5pDKybqkvZzoBoPkWJz5pDKybLHksyEmlGZMtQc8ywTANaO(vEFb5djzjJw5qkPsDAHjynBoPkWJz1pDKybgnQkfyyJki2kPSpzuKvMQ5mhuxTcXcfOtwcaIfQ(jbgcEv961cYhsYsCQuNwycwZMtQc8yw9thjwWTfZnM(ckdMFKs7Rss1CMdQRwHyHc0jlbaXcLFKs1axykO4PAoZb1vRqSqb6KLaGyHYbUWuOmurcZJzbC2CsvGhZQv7ea1VY7tcu9K1(hmfagfzLPAoZzZjvbEmlhE6TOIeMhZc4S5KQapMvR2jaQFL3BJcXcvNMtYOiRuyEuG00sNGa3wSHunN5S5KQapMLdp9wurcZJzbC2CsvGhZQv7ea1VY7pX)Zd0tw7ZFO1nkYkt1CMZMtQc8ywo80BnKQ5m)RlPNSwD6rphE6TOIeMhZc4S5KQapMvR2jaQFL3xbKoC6y0khszheQ07DpjW6EFa8EVOcmkYkt1CMZMtQc8ywEv1GW8ywEoEsNScW5So5HsaLq2GW8ywEoEsNScW5pX6KhkP94q3cLbZpsPOIeMhZc4S5KQapMvR2jaQFL3NSZaRNS27inT0bcurcZJzbC2CsvGhZQv7ea1VY7p0zEi0twBRSawd)KCaOIeMhZc4S5KQapMvR2jaQFL33BElCbkw9tGzLLrOI6Be24s9JfkcRyNtQc8ywJqyfz8ecFHvaoaHLNq4kGGryFqyO0sV4ecRioocB6pjkaqyzHr4tSXjmEcH9ocHLZuxhHNmc7XHqyGkToctLsSQhlueE8o6ryGkzTaocRiNhHbUSWYdJWkY4jJqyfz8ecFHvaoaHLNq4zTqGWvabJW96OfHvejXJfkcRyqfHdaclmpkqi88iCVoArybHnzZZ6qyMaCeoaiCSiS6pqFcaqyzHryfrs8yHIWkguryzHryfXXryt)jrbewEcH3XryH5rbIJWkccVdHVWkaNEe2yrao9iSSWiSI0khcHvmVgHWkY4je(cRaCacZKfHfy4WJzfRfceoriCfqWiCVUWsiSI44iSP)KOacllmcRisIhluewXGkclpHW74iSW8OaHWYcJWcc3hbXpjRaCeoaiCSiS3riSepcllmclwWGW96clHWmb4XcfHnzZZ6qyQaTiCKryfrs8yHIWkgur4aGWI9jbgcewyEuG4i8LDecBf3PhHfRD6bqyV3GWkIJJWM(tIciCFee)KScWbiSpiCIqyMaCeoweguzmcaIzryj70JWEhHWMS5zDCewrimC4XSI1cbc3l8oe(cRaC6ryJfb40JWYcJWksRCiewX8AecRiJNq4lScWbimOBQwyeEhhHtecxbemcxxlbai8fwb40JWglcWPhHdaclPP6iSpimvQA8ecppc7D0tiS8ecFMNqyVtweM2PcTdHvKXti8fwb4ae2heMk1PfgHVWkaNEe2yrao9iSpiS3rimTWi8Kryf7CsvGhZYrfjmpMfWzZjvbEmRwTtau)kVphpPtwb4gvbKEYznugSYInQciDVUWsAMa8yHQSyJISsX4PpCINScWPxFeGtpNwjzjydSo5HsGBvwSHskryEmlphpPtwb4CwN8qjGo)cZJzfB)LKQ5mNnNuf4XS8NosSafpvZzEYkaNE9rao9C46lEmBzg7SzSWtVLNJN0jRaCoC9fpMvXljvZzoBoPkWJz5pDKybLzSxsQMZ8Kvao96JaC65W1x8ywfhYCJPSYUvjKVE9gX4PpCINScWPxFeGtpNwjzj4RxVXflTopBLdPNLtRKSe81RPAoZzZjvbEml)PJelaskt1CMNScWPxFeGtphU(IhZE9AQMZ8Kvao96JaC65pDKybqcYCJ56vsrRHQkbZ7GqLEV7jbw37dG37fvGb2mw4P3Y7GqLEV7jbw37dG37fvG(UqgYf3NVd)PJelasgtzgs1CMZMtQc8ywEv1qj3impMLdyZZ64uPeR6Xc1WncZJz5Qq8tYkaNhRoBdODUHunN5DK4Xcvxv5v1RxfMhZYbS5zDCQuIv9yHAivZzE34AG)KOahE6TgkjvZzEhjESq1vvo80BVEvmE6dN4jRaC61hb40ZPvswcUSRxfJN(WjEYkaNE9rao9CALKLGn4ILwNNTYH0ZYPvswc2GW8ywUke)KScW5XQZ2aANBivZzEhjESq1vvo80BnKQ5mVBCnWFsuGdp92Yqf13iSIGW7qyfJBM(vSiSIvambMmcHvKXti8fwb4aeg0nvlmcVJJWjcHRacgHRRLaaewX4MPFflcRyfatGjeoaiSKMQJW(GWuPQXti88iS3rpHWYti8zEcH9ozryANk0oewrgpHWxyfGdqyFqyQuNwye(cRaC6ryJfb40JW(GWEhHW0cJWtgHvSZjvbEmlhvKW8ywaNnNuf4XSA1obq9R8(C8KozfGBufq6jN1qzWkl2OkG096clPzcWJfQYInkYkVrmE6dN4jRaC61hb40ZPvswc2qjcZJcKMw6eeaskfMhfin848a6goD96nSzSWtVLR2n0gLQZw5qa(tcmeLzGnlCnCESz6xXQzcGjWeNwjzjydSo5HsGBvwSHskryEmlphpPtwb4CwN8qjGo)cZJzfB)Luq(qswItL60ctWA2CsvGhZQF6iXcu8unN5XMPFfRMjaMatC46lEmBzg7SzSWtVLNJN0jRaCoC9fpMvXliFijlXPsDAHjynBoPkWJz1pDKybg7LKQ5mp2m9Ry1mbWeyIdxFXJzvCiZnMYk7wLq(61cYhsYsCQuNwycwZMtQc8yw9thjwaKuMQ5mp2m9Ry1mbWeyIdxFXJzVEnvZzESz6xXQzcGjWe)PJelasqMBmLzivZzoBoPkWJz5vvd3KQ5mphpb85p8NeMB4MunN5DJRb(tIc8NeMBOBCnWFsuqdujRfOJvNTb0oV)unN5DK4Xcvxv5pjmhs3bvKW8ywaNnNuf4XSA1obq9R8(C8KozfGBufq6jN1qzWkl2OkG096clPzcWJfQYInkYkVrmE6dN4jRaC61hb40ZPvswc2qjcZJcKMw6eeaskfMhfin848a6goD96nSzSWtVLR2n0gLQZw5qa(tcmeLz4g2SW1W5XMPFfRMjaMatCALKLGnW6KhkbUvzXgs1CMZMtQc8ywEv1WnPAoZZXtaF(d)jH5gUjvZzE34AG)KOa)jH5g6gxd8Nef0avYAb6y1zBaTZ7pvZzEhjESq1vv(tcZH0DqfjmpMfWzZjvbEmRwTtau)kVNn11PhOswRrrw5xxkppuIdhawOAJvEi0S5CKfMtkAnuvjydPAoZHdaluTXkpeA2CoYcZHNERHunN5WbGfQ2yLhcnBohzH1YZKL4WtV1aBgl80B5PAoRHdaluTXkpeA2CoYcZFsGHavKW8ywaNnNuf4XSA1obq9R8E5zYsAQuv7aIznkYk)6s55HsC4aWcvBSYdHMnNJSWCsrRHQkbBivZzoCayHQnw5HqZMZrwyo80BnKQ5mhoaSq1gR8qOzZ5ilSwEMSehE6TgyZyHNElpvZznCayHQnw5HqZMZrwy(tcmeOIeMhZc4S5KQapMvR2jaQFL3N)b4PX6gfzLFDP88qjoCayHQnw5HqZMZrwyoPO1qvLGnKQ5mhoaSq1gR8qOzZ5ilmhE6Tgs1CMdhawOAJvEi0S5CKfwN)b4C4P3IksyEmlGZMtQc8ywTANaO(vEptSwTW8ywTnaUrRCiLcZJcK2flToavKW8ywaNnNuf4XSA1obq9R8E2CsvGhZAufq6jN1qzWkl2OkG096clPzcWJfQYInkYkt1CMZMtQc8ywo80BnuYxxkppuIdhawOAJvEi0S5CKfMtkAnuvjyLPAoZHdaluTXkpeA2CoYcZRQLzOeH5XS8d5088y1zBaTZnimpMLFiNMNhRoBdODU(PJelaskHm3yUEvyEmlhWMN1XPsjw1JfQbH5XSCaBEwhNkLyvN0pDKybqcYCJ56vH5XS8C8usSwovkXQESqnimpMLNJNsI1YPsjw1j9thjwaKGm3yUEvyEmlxfIFswb4CQuIv9yHAqyEmlxfIFswb4CQuIvDs)0rIfajiZnMYqfjmpMfWzZjvbEmRwTtau)kVxD8ywJISYunN5S5KQapMLBfGRPsvJNGKsH5XSC2CsvGhZYTcW1vabJksyEmlGZMtQc8ywTANaO(vEFYodSoxFimkYkt1CMZMtQc8ywUvaUMkvnEcskfMhZYzZjvbEml3kaxxbemQiH5XSaoBoPkWJz1QDcG6x59j6b0RqSqnkYkt1CMZMtQc8ywUvaUMkvnEcskfMhZYzZjvbEml3kaxxbemQiH5XSaoBoPkWJz1QDcG6x5954PKDgyJISYunN5S5KQapMLBfGRPsvJNGKsH5XSC2CsvGhZYTcW1vabJksyEmlGZMtQc8ywTANaO(vEVSmc4Vy1mXAnkYkt1CMZMtQc8ywUvaUMkvnEcskfMhZYzZjvbEml3kaxxbemQiH5XSaoBoPkWJz1QDcG6x59vaPdNoaJISYunN5S5KQapMLBfGRPsvJNGKsH5XSC2CsvGhZYTcW1vabJksyEmlGZMtQc8ywTANaO(vEF2khc4FOazuKvMQ5mVBCnWFsuG)KWCdcZJcKMw6ee4wLfKpKKL4S5KQapMvNTYHa(hkqOIeMhZc4S5KQapMvR2jaQFL3RcXpjRaCJISYunN5G6QviwOaDYsaqSq1pjWqWRQgs1CMdQRwHyHc0jlbaXcv)Kadb)PJel4wMaCThhcvKW8ywaNnNuf4XSA1obq9R8Evi(jzfGBuKvMQ5mphpb85p8NeMJksyEmlGZMtQc8ywTANaO(vEVke)KScWnkYkt1CMRcXpmRao8NeMBivZzUke)WSc4WF6iXcULjax7XHmusQMZC2CsvGhZYF6iXcULjax7XHUEnvZzoBoPkWJz5WtVTmurcZJzbC2CsvGhZQv7ea1VY7vH4NKvaUrrwzQMZ8UX1a)jrb(tcZnKQ5mNnNuf4XS8QkQiH5XSaoBoPkWJz1QDcG6x59Qq8tYka3OiRu9PcAOmyEXCaBEwNHunN5DK4Xcvxv5pjmhvKW8ywaNnNuf4XSA1obq9R8E1UH2OuD2khcyuKvMQ5mNnNuf4XS8QkQiH5XSaoBoPkWJz1QDcG6x5954PKyTgfzLPAoZzZjvbEmlhE6TgyZyHNElNnNuf4XS8NosSaiXeGR94qgUHnlCnCE2khslm2tEmlNwjzjyurcZJzbC2CsvGhZQv7ea1VY7bS5zDgfzLPAoZzZjvbEml)PJel4wMaCThhYqQMZC2CsvGhZYRQxVMQ5mNnNuf4XSC4P3AGnJfE6TC2CsvGhZYF6iXcGetaU2JdHksyEmlGZMtQc8ywTANaO(vEVnkeluDAojJISYunN5S5KQapML)0rIfajOmy(rk1GW8OaPPLobbUTyurcZJzbC2CsvGhZQv7ea1VY7HFb6SaD6jX7mkYkt1CMZMtQc8yw(thjwaKGYG5hPudPAoZzZjvbEmlVQIksyEmlGZMtQc8ywTANaO(vEpGnpRZOiR0Lhk58osSEhxL5qs5DHSbxS06CajFSq1(uzDCALKLGrfHksyEmlG)JQwTtaKYSvoeW)qbYOiRSeH5rbstlDccCRYcYhsYs8UX1a)jrbD2khc4FOazOepoKINQ5mNnNuf4XSCRaCnvQA80TfKpKKL4WKvGqNTYHa(hkqLvMHunN5DJRb(tIc8NeMJksyEmlG)JQwTtau)kVxfIFswb4gfzLPAoZb1vRqSqb6KLaGyHQFsGHGxvnKQ5mhuxTcXcfOtwcaIfQ(jbgc(thjwWTmb4ApoeQiH5XSa(pQA1obq9R8Evi(jzfGBuKvMQ5mphpb85p8NeMJksyEmlG)JQwTtau)kVxfIFswb4gfzLPAoZ7gxd8Nef4pjmhvKW8ywa)hvTANaO(vEFoEsNScWnQci9KZAOmyLfBufq6EDHL0mb4XcvzXgfzLPAoZb1vRqSqb6KLaGyHQFsGHGdp9wd3uIW8OaPPLobbUvzb5djzjEN8WAMaCD2khc4FOazOepoKINQ5mNnNuf4XSCRaCnvQA80TfKpKKL4WKvGqNTYHa(hkqLvMHBYXtaxENEUW8OazOKBs1CM3rIhluDvL)KWCd3KQ5mVBCnWFsuG)KWCd3O(ub9KZAOmyEoEsNScWnuIW8ywEoEsNScW5So5HsGBvENRxlXflToxSuPa)fGXlaDU(qWPvswc2aBgl80B5WVaDwGo9K4D8Neyik761sCXsRZbK8Xcv7tL1XPvswc2GlpuY5DKy9oUkZHKY7c5YkRmurcZJzb8Fu1QDcG6x5954jDYka3OkG0toRHYGvwSrvaP71fwsZeGhluLfBuKvEtoEc4Y70ZfMhfidLusjcZJz554PKyTCQuIv9yHE9QW8ywUke)KScW5uPeR6XcTmdPAoZ7iXJfQUQYFsyEzxVwIlwADoGKpwOAFQSooTsYsWgC5HsoVJeR3XvzoKuExiBOKunN5DK4Xcvxv5pjm3WncZJz5a28SoovkXQESqVE9MunN5DJRb(tIc8NeMB4MunN5DK4Xcvxv5pjm3GW8ywoGnpRJtLsSQhlud30nUg4pjkObQK1c0XQZ2aANxwzLHksyEmlG)JQwTtau)kVNjwRwyEmR2ga3OvoKsH5rbs7ILwhGksyEmlG)JQwTtau)kVxfIFswb4gfzLPAoZvH4hMvah(tcZnWeGR94qqkvZzUke)WSc4WF6iXcmWeGR94qqkvZz(xxspzT60JE(thjwGHss1CMRcXpmRao8NeMRmvZzUke)WSc4WpsPAGlmfUEnvZzUke)WSc4WF6iXcGetaU2Jd1VW8ywEoEkjwlNkLyvN0ECORxt1CMlwQuG)cW4fGoxFi4v1RxV5RlLNhkXb1vRqSqb6KLaGyHYjfTgQQeCzOIeMhZc4)OQv7ea1VY7vH4NKvaUrrwP6tf0qzW8I5a28SodPAoZ7iXJfQUQYFsyUbxS06CajFSq1(uzDCALKLGn4YdLCEhjwVJRYCiP8Uq2WnLimpkqAAPtqGBvwq(qswI3nUg4pjkOZw5qa)dfidL4XHu8unN5S5KQapMLBfGRPsvJNUTG8HKSehMSce6SvoeW)qbQSYqfjmpMfW)rvR2jaQFL3R2n0gLQZw5qaJISYBkiFijlXv7gAJs1QZyJfQHunN5DK4Xcvxv5pjm3WnPAoZ7gxd8Nef4pjm3qjcZJcKgECEaDdNG0DUEvyEuG00sNGa3QSG8HKSeVtEyntaUoBLdb8puGUEvyEuG00sNGa3QSG8HKSeVBCnWFsuqNTYHa(hkqLHksyEmlG)JQwTtau)kVhWMN1zuKv6YdLCEhjwVJRYCiP8Uq2GlwADoGKpwOAFQSooTsYsWOIeMhZc4)OQv7ea1VY7HFb6SaD6jX7mkYkfMhfinT0jiWT3bvKW8ywa)hvTANaO(vEF2khc4FOazuKvwIW8OaPPLobbUvzb5djzjEN8WAMaCD2khc4FOazOepoKINQ5mNnNuf4XSCRaCnvQA80TfKpKKL4WKvGqNTYHa(hkqLvgQiH5XSa(pQA1obq9R8(C8usSwurOIeMhZc4axwy5H1)4IhZQmBLdb8puGmkYklryEuG00sNGa3QSG8HKSeVBCnWFsuqNTYHa(hkqgkXJdP4PAoZzZjvbEml3kaxtLQgpDBb5djzjomzfi0zRCiG)HcuzLzivZzE34AG)KOa)jH5OIeMhZc4axwy5H1)4IhZ2VY7vH4NKvaUrrwzQMZ8C8eWN)WFsyoQiH5XSaoWLfwEy9pU4XS9R8Evi(jzfGBuKvMQ5mVBCnWFsuG)KWCdPAoZ7gxd8Nef4pDKybqsyEmlphpLeRLtLsSQtApoeQiH5XSaoWLfwEy9pU4XS9R8Evi(jzfGBuKvMQ5mVBCnWFsuG)KWCdLO(ubnugmVyEoEkjw71R54jGlVtpxyEuGUEvyEmlxfIFswb48y1zBaTZldvuFJWx(qGW(GWqjhHnn2EbcR(ddGWXccycHn2y6Jqy1obqaeEEewXoNuf4XSiSANaiac3RJwewDaGizjoQiH5XSaoWLfwEy9pU4XS9R8Evi(jzfGBuKvMQ5mhuxTcXcfOtwcaIfQ(jbgcEv1qjSzSWtVL)1L0twRo9ON)0rIf0VW8yw(xxspzT60JEovkXQoP94q9ZeGR94q3MQ5mhuxTcXcfOtwcaIfQ(jbgc(thjwW1R34ILwN)1L0twRo9ONtRKSeCzgkiFijlX94qAF0S5KQapMTFMaCThh62unN5G6QviwOaDYsaqSq1pjWqWF6iXcqfjmpMfWbUSWYdR)XfpMTFL3RcXpjRaCJISYunN5DJRb(tIc8NeMBWLhk58osSEhxL5qs5DHSbxS06CajFSq1(uzDCALKLGrfjmpMfWbUSWYdR)XfpMTFL3RcXpjRaCJISYunN5Qq8dZkGd)jH5gycW1ECiiLQ5mxfIFywbC4pDKybgkjvZzUke)WSc4WFsyUYunN5Qq8dZkGd)iLQbUWu461unN5Qq8dZkGd)PJelasmb4Apou)cZJz554PKyTCQuIvDs7XHUEnvZzUyPsb(laJxa6C9HGxvVE9MVUuEEOehuxTcXcfOtwcaIfkNu0AOQsWLHksyEmlGdCzHLhw)JlEmB)kVphpPtwb4gvbKEYznugSYInQciDVUWsAMa8yHQSyJISYBYXtaxENEUW8Oaz4McYhsYs8C8KozfGRvNXgludLusjcZJz554PKyTCQuIv9yHE9QW8ywUke)KScW5uPeR6XcTmdPAoZ7iXJfQUQYFsyEzxVwIlwADoGKpwOAFQSooTsYsWgC5HsoVJeR3XvzoKuExiBOKunN5DK4Xcvxv5pjm3WncZJz5a28SoovkXQESqVE9MunN5DJRb(tIc8NeMB4MunN5DK4Xcvxv5pjm3GW8ywoGnpRJtLsSQhlud30nUg4pjkObQK1c0XQZ2aANxwzLHksyEmlGdCzHLhw)JlEmB)kVxfIFswb4gfzLQpvqdLbZlMdyZZ6mKQ5mVJepwO6Qk)jH5gCXsRZbK8Xcv7tL1XPvswc2GlpuY5DKy9oUkZHKY7czd3uIW8OaPPLobbUvzb5djzjE34AG)KOGoBLdb8puGmuIhhsXt1CMZMtQc8ywUvaUMkvnE62cYhsYsCyYkqOZw5qa)dfOYkdvKW8ywah4YclpS(hx8y2(vEVA3qBuQoBLdbmkYkVPG8HKSexTBOnkvRoJnwOgk5gxS0688phT3rAb0raoTsYsWxVkmpkqAAPtqGBlUmdLimpkqAAPtqGBl2GW8OaPHhNhq3WjiDNRxfMhfinT0jiWTkliFijlX7KhwZeGRZw5qa)dfORxfMhfinT0jiWTkliFijlX7gxd8Nef0zRCiG)HcuzOIeMhZc4axwy5H1)4IhZ2VY7zI1QfMhZQTbWnALdPuyEuG0UyP1bOIeMhZc4axwy5H1)4IhZ2VY7HFb6SaD6jX7mkYkfMhfinT0jiWTfJksyEmlGdCzHLhw)JlEmB)kVhWMN1zuKv6YdLCEhjwVJRYCiP8Uq2GlwADoGKpwOAFQSooTsYsWOI6Bewrq4DimTtfAhc7YdLCGriC4iCaqybHHkXIW(GWmb4iSI0khc4FOaHWcaHZH1spchlWjbgHNmcRiJNsI1YrfjmpMfWbUSWYdR)XfpMTFL3NTYHa(hkqgfzLcZJcKMw6ee4wLfKpKKL4DYdRzcW1zRCiG)HcKHs84qkEQMZC2CsvGhZYTcW1uPQXt3wq(qswIdtwbcD2khc4FOavgQiH5XSaoWLfwEy9pU4XS9R8(C8usSwurcZJzbCGllS8W6FCXJz7x59a28SUM38wd]] )

end
