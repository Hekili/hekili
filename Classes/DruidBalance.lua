-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

-- Conduits
-- [-] fury_of_the_skies
-- [x] precise_alignment
-- [-] stellar_inspiration
-- [-] umbral_intensity

-- Covenants
-- [x] deep_allegiance
-- [-] endless_thirst
-- [-] evolved_swarm
-- [-] conflux_of_elements

-- Endurance
-- [x] tough_as_bark
-- [x] ursine_vigor
-- [-] innate_resolve

-- Finesse
-- [x] born_anew
-- [-] front_of_the_pack
-- [x] born_of_the_wilds
-- [x] tireless_pursuit


if UnitClassBase( "player" ) == "DRUID" then
    local spec = Hekili:NewSpecialization( 102, true )

    spec:RegisterResource( Enum.PowerType.LunarPower, {
        fury_of_elune = {
            aura = "fury_of_elune_ap",
            debuff = true,

            last = function ()
                local app = state.debuff.fury_of_elune_ap.applied
                local t = state.query_time

                return app + floor( ( t - app ) * 2 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        },

        celestial_infusion = {
            aura = "celestial_infusion",

            last = function ()
                local app = state.buff.celestial_infusion.applied
                local t = state.query_time

                return app + floor( ( t - app ) * 2 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        },

        natures_balance = {
            talent = "natures_balance",

            last = function ()
                local app = state.combat
                local t = state.query_time

                return app + floor( ( t - app ) / 2 ) * 2
            end,

            interval = 2,
            value = 1,
        }
    } )


    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Rage )


    -- Talents
    spec:RegisterTalents( {
        natures_balance = 22385, -- 202430
        warrior_of_elune = 22386, -- 202425
        force_of_nature = 22387, -- 205636

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        feral_affinity = 22155, -- 202157
        guardian_affinity = 22157, -- 197491
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        heart_of_the_wild = 18577, -- 319454

        soul_of_the_forest = 18580, -- 114107
        starlord = 21706, -- 202345
        incarnation = 21702, -- 102560

        twin_moons = 22389, -- 279620
        stellar_drift = 21712, -- 202354
        stellar_flare = 22165, -- 202347

        solstice = 21648, -- 343647
        fury_of_elune = 21193, -- 202770
        new_moon = 21655, -- 274281
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( {
        celestial_guardian = 180, -- 233754
        crescent_burn = 182, -- 200567
        deep_roots = 834, -- 233755
        dying_stars = 822, -- 232546
        faerie_swarm = 836, -- 209749
        high_winds = 5383, -- 200931
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        owlkin_adept = 5407, -- 354541
        protector_of_the_grove = 3728, -- 209730
        star_burst = 3058, -- 356517
        thorns = 3731, -- 305497
    } )


    spec:RegisterPower( "lively_spirit", 279642, {
        id = 279648,
        duration = 20,
        max_stack = 1,
    } )


    local mod_circle_hot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.85 * x ) or x
    end, state )

    local mod_circle_dot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.75 * x ) or x
    end, state )


    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        barkskin = {
            id = 22812,
            duration = 12,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        celestial_alignment = {
            id = 194223,
            duration = function () return 20 + ( conduit.precise_alignment.mod * 0.001 ) end,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        eclipse_lunar = {
            id = 48518,
            duration = 15,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        eclipse_solar = {
            id = 48517,
            duration = 15,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        elunes_wrath = {
            id = 64823,
            duration = 10,
            max_stack = 1
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        feline_swiftness = {
            id = 131768,
        },
        flight_form = {
            id = 276029,
        },
        force_of_nature = {
            id = 205644,
            duration = 15,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        fury_of_elune_ap = {
            id = 202770,
            duration = 8,
            tick_time = 0.5,
            max_stack = 1,

            generate = function ( t )
                local applied = action.fury_of_elune.lastCast

                if applied and now - applied < 8 then
                    t.count = 1
                    t.expires = applied + 8
                    t.applied = applied
                    t.caster = "player"
                    return
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,

            copy = "fury_of_elune"
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        heart_of_the_wild = {
            id = 108291,
            duration = 45,
            max_stack = 1,
            copy = { 108292, 108293, 108294 }
        },
        incarnation = {
            id = 102560,
            duration = function () return 30 + ( conduit.precise_alignment.mod * 0.001 ) end,
            max_stack = 1,
            copy = "incarnation_chosen_of_elune"
        },
        ironfur = {
            id = 192081,
            duration = 7,
            max_stack = 1,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = function () return mod_circle_dot( 22 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 24858,
            duration = 3600,
            max_stack = 1,
        },
        owlkin_frenzy = {
            id = 157228,
            duration = 10,
            max_stack = function () return pvptalent.owlkin_adept.enabled and 2 or 1 end,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = function () return mod_circle_hot( 12 ) end,
            type = "Magic",
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
            max_stack = 1,
        },
        solar_beam = {
            id = 81261,
            duration = 3600,
            max_stack = 1,
        },
        solstice = {
            id = 343648,
            duration = 6,
            max_stack = 1,
        },
        stag_form = {
            id = 210053,
            duration = 3600,
            max_stack = 1,
            generate = function ()
                local form = GetShapeshiftForm()
                local stag = form and form > 0 and select( 4, GetShapeshiftFormInfo( form ) )

                local sf = buff.stag_form

                if stag == 210053 then
                    sf.count = 1
                    sf.applied = now
                    sf.expires = now + 3600
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end,
        },
        starfall = {
            id = 191034,
            duration = 8,
            max_stack = 1,
        },
        starlord = {
            id = 279709,
            duration = 20,
            max_stack = 3,
        },
        stellar_flare = {
            id = 202347,
            duration = function () return mod_circle_dot( 24 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = function () return mod_circle_dot( 18 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thrash_bear = {
            id = 192090,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function () return mod_circle_dot( 3 ) * haste end,
            max_stack = 3,
        },
        tiger_dash = {
            id = 252216,
            duration = 5,
            max_stack = 1,
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        treant_form = {
            id = 114282,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        warrior_of_elune = {
            id = 202425,
            duration = 3600,
            type = "Magic",
            max_stack = 3,
        },
        wild_charge = {
            id = 102401,
            duration = 0.5,
            max_stack = 1,
        },
        yseras_gift = {
            id = 145108,
        },


        -- Alias for Celestial Alignment vs. Incarnation
        ca_inc = {},
        --[[
            alias = { "incarnation", "celestial_alignment" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            -- duration = function () return talent.incarnation.enabled and 30 or 20 end,
        }, ]]

        any_form = {
            alias = { "bear_form", "cat_form", "moonkin_form" },
            duration = 3600,
            aliasMode = "first",
            aliasType = "buff",
        },


        -- PvP Talents
        celestial_guardian = {
            id = 234081,
            duration = 3600,
            max_stack = 1,
        },

        cyclone = {
            id = 33786,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        high_winds = {
            id = 200931,
            duration = 4,
            max_stack = 1,
        },

        moon_and_stars = {
            id = 234084,
            duration = 10,
            max_stack = 1,
        },

        moonkin_aura = {
            id = 209746,
            duration = 18,
            type = "Magic",
            max_stack = 3,
        },

        thorns = {
            id = 305497,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        arcanic_pulsar = {
            id = 287790,
            duration = 3600,
            max_stack = 9,
        },

        dawning_sun = {
            id = 276153,
            duration = 8,
            max_stack = 1,
        },

        sunblaze = {
            id = 274399,
            duration = 20,
            max_stack = 1
        },


        -- Legendaries
        balance_of_all_things_arcane = {
            id = 339946,
            duration = 8,
            max_stack = 8
        },

        balance_of_all_things_nature = {
            id = 339943,
            duration = 8,
            max_stack = 8,
        },

        celestial_infusion = {
            id = 367907,
            duration = 8,
            max_stack = 1
        },

        oath_of_the_elder_druid = {
            id = 338643,
            duration = 60,
            max_stack = 1
        },

        oneths_perception = {
            id = 339800,
            duration = 30,
            max_stack = 1,
        },

        oneths_clear_vision = {
            id = 339797,
            duration = 30,
            max_stack = 1,
        },

        primordial_arcanic_pulsar = {
            id = 338825,
            duration = 3600,
            max_stack = 10,
        },

        timeworn_dreambinder = {
            id = 340049,
            duration = 6,
            max_stack = 2,
        },
    } )


    -- Adaptive Swarm Stuff
    do
        local applications = {
            SPELL_AURA_APPLIED = true,
            SPELL_AURA_REFRESH = true,
            SPELL_AURA_APPLIED_DOSE = true
        }

        local casts = { SPELL_CAST_SUCCESS = true }

        local removals = {
            SPELL_AURA_REMOVED = true,
            SPELL_AURA_BROKEN = true,
            SPELL_AURA_BROKEN_SPELL = true,
            SPELL_AURA_REMOVED_DOSE = true,
            SPELL_DISPEL = true
        }

        local deaths = {
            UNIT_DIED       = true,
            UNIT_DESTROYED  = true,
            UNIT_DISSIPATES = true,
            PARTY_KILL      = true,
            SPELL_INSTAKILL = true,
        }

        local spellIDs = {
            [325733] = true,
            [325748] = true,
            [325727] = true
        }

        local flights = {}
        local pending = {}
        local swarms = {}

        -- Flow:  Cast -> In Flight -> Application -> Ticks -> Removal -> In Flight -> Application -> Ticks -> Removal -> ...
        -- If the swarm target dies, it will jump again.
        local insert, remove = table.insert, table.remove

        function Hekili:EmbedAdaptiveSwarm( s )
            s:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
                if not state.covenant.necrolord then return end

                if sourceGUID == state.GUID and spellIDs[ spellID ] then
                    -- On cast, we need to show we have a cast-in-flight.
                    if casts[ subtype ] then
                        local dot

                        if bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 then
                            dot = "adaptive_swarm_damage"
                        else
                            dot = "adaptive_swarm_heal"
                        end

                        insert( flights, { destGUID, 3, GetTime() + 5, dot } )

                    -- On application, we need to store the GUID of the unit so we can get the stacks and expiration time.
                    elseif applications[ subtype ] and #flights > 0 then
                        local n, flight

                        for i, v in ipairs( flights ) do
                            if v[1] == destGUID then
                                n = i
                                flight = v
                                break
                            end
                            if not flight and v[1] == "unknown" then
                                n = i
                                flight = v
                            end
                        end

                        if flight then
                            local swarm = swarms[ destGUID ]
                            local now = GetTime()

                            if swarm and swarm.expiration > now then
                                swarm.stacks = swarm.stacks + flight[2]
                                swarm.dot = bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 and "adaptive_swarm_damage" or "adaptive_swarm_heal"
                                swarm.expiration = now + class.auras[ swarm.dot ].duration
                            else
                                swarms[ destGUID ] = {}
                                swarms[ destGUID ].stacks = flight[2]
                                swarms[ destGUID ].dot = bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 and "adaptive_swarm_damage" or "adaptive_swarm_heal"
                                swarms[ destGUID ].expiration = now + class.auras[ swarms[ destGUID ].dot ].duration
                            end
                            remove( flights, n )
                        else
                            swarms[ destGUID ] = {}
                            swarms[ destGUID ].stacks = 3 -- We'll assume it's fresh.
                            swarms[ destGUID ].dot = bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 and "adaptive_swarm_damage" or "adaptive_swarm_heal"
                            swarms[ destGUID ].expiration = GetTime() + class.auras[ swarms[ destGUID ].dot ].duration
                        end

                    elseif removals[ subtype ] then
                        -- If we have a swarm for this, remove it.
                        local swarm = swarms[ destGUID ]

                        if swarm then
                            swarms[ destGUID ] = nil

                            if swarm.stacks > 1 then
                                local dot

                                if bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 then
                                    dot = "adaptive_swarm_heal"
                                else
                                    dot = "adaptive_swarm_damage"
                                end

                                insert( flights, { "unknown", swarm.stacks - 1, GetTime() + 5, dot } )

                            end
                        end
                    end

                elseif swarms[ destGUID ] and deaths[ subtype ] then
                    -- If we have a swarm for this, remove it.
                    local swarm = swarms[ destGUID ]

                    if swarm then
                        swarms[ destGUID ] = nil

                        if swarm.stacks > 1 then
                            if bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 then
                                dot = "adaptive_swarm_heal"
                            else
                                dot = "adaptive_swarm_damage"
                            end

                            insert( flights, { "unknown", swarm.stacks - 1, GetTime() + 5, dot } )

                        end
                    end
                end
            end )

            --[[ s:RegisterEvent( "UNIT_AURA", function( _, unit )
                if not state.covenant.necrolord then return end

                local guid = UnitGUID( unit )

                if pending[ guid ] then
                    if UnitIsFriend( unit, "player" ) then
                        local name, _, count, _, _, expirationTime = FindUnitBuffByID( unit, 325748, "PLAYER" )

                        print( "Buff", name, count, guid, pending[ guid ] )

                        if name then
                            swarms[ guid ] = {
                                stacks = count,
                                expiration = expirationTime,
                            }
                            pending[ guid ] = nil
                            return
                        end
                    else
                        local name, _, count, _, _, expirationTime = FindUnitDebuffByID( unit, 325733, "PLAYER" )

                        print( "Debuff", name, count, guid, pending[ guid ] )

                        if name then
                            swarms[ guid ] = {
                                stacks = count,
                                expiration = expirationTime,
                            }
                            pending[ guid ] = nil
                            return
                        end
                    end

                    pending[ guid ] = pending[ guid ] + 1

                    if pending[ guid ] > 2 then
                        pending[ guid ] = nil
                    end
                end
            end ) ]]

            function s.GetActiveSwarms()
                return swarms
            end

            function s.GetPendingSwarms()
                return pending
            end

            function s.GetInFlightSwarms()
                return flights
            end

            local flySwarm, landSwarm

            landSwarm = setfenv( function( aura )
                if aura.key == "adaptive_swarm_heal_in_flight" then
                    applyBuff( "adaptive_swarm_heal", 12, min( 5, buff.adaptive_swarm_heal.stack + aura.count ) )
                    buff.adaptive_swarm_heal.expires = query_time + 12
                    state:QueueAuraEvent( "adaptive_swarm", flySwarm, buff.adaptive_swarm_heal.expires, "AURA_EXPIRATION", buff.adaptive_swarm_heal )
                else
                    applyDebuff( "target", "adaptive_swarm_damage", 12, min( 5, debuff.adaptive_swarm_damage.stack + aura.count ) )
                    debuff.adaptive_swarm_damage.expires = query_time + 12
                    state:QueueAuraEvent( "adaptive_swarm", flySwarm, debuff.adaptive_swarm_damage.expires, "AURA_EXPIRATION", debuff.adaptive_swarm_damage )
                end
            end, state )

            flySwarm = setfenv( function( aura )
                if aura.key == "adaptive_swarm_heal" then
                    applyBuff( "adaptive_swarm_heal_in_flight", 5, aura.count - 1 )
                    state:QueueAuraEvent( "adaptive_swarm", landSwarm, query_time + 5, "AURA_EXPIRATION", buff.adaptive_swarm_heal_in_flight )
                else
                    applyBuff( "adaptive_swarm_damage_in_flight", 5, aura.count - 1 )
                    state:QueueAuraEvent( "adaptive_swarm", landSwarm, query_time + 5, "AURA_EXPIRATION", buff.adaptive_swarm_damage_in_flight )
                end
            end, state )

            s.SwarmOnReset = setfenv( function()
                for k, v in pairs( swarms ) do
                    if v.expiration + 0.1 <= now then swarms[ k ] = nil end
                end

                for i = #flights, 1, -1 do
                    if flights[i][3] + 0.1 <= now then remove( flights, i ) end
                end

                local target = UnitGUID( "target" )
                local tSwarm = swarms[ target ]

                if not UnitIsFriend( "target", "player" ) and tSwarm and tSwarm.expiration > now then
                    applyDebuff( "target", "adaptive_swarm_damage", tSwarm.expiration - now, tSwarm.stacks )
                    debuff.adaptive_swarm_damage.expires = tSwarm.expiration

                    if tSwarm.stacks > 1 then
                        state:QueueAuraEvent( "adaptive_swarm", flySwarm, tSwarm.expiration, "AURA_EXPIRATION", debuff.adaptive_swarm_damage )
                    end
                end

                if buff.adaptive_swarm_heal.up and buff.adaptive_swarm_heal.stack > 1 then
                    state:QueueAuraEvent( "adaptive_swarm", flySwarm, buff.adaptive_swarm_heal.expires, "AURA_EXPIRATION", buff.adaptive_swarm_heal )
                else
                    for k, v in pairs( swarms ) do
                        if k ~= target and v.dot == "adaptive_swarm_heal" then
                            applyBuff( "adaptive_swarm_heal", v.expiration - now, v.stacks )
                            buff.adaptive_swarm_heal.expires = v.expiration

                            if v.stacks > 1 then
                                state:QueueAuraEvent( "adaptive_swarm", flySwarm, buff.adaptive_swarm_heal.expires, "AURA_EXPIRATION", buff.adaptive_swarm_heal )
                            end
                        end
                    end
                end

                local flight

                for i, v in ipairs( flights ) do
                    if not flight or v[3] > now and v[3] > flight then flight = v end
                end

                if flight then
                    local dot = flight[4] .. "_in_flight"
                    applyBuff( dot, flight[3] - now, flight[2] )
                    state:QueueAuraEvent( dot, landSwarm, flight[3], "AURA_EXPIRATION", buff[ dot ] )
                end

                Hekili:Debug( "Swarm Info:\n   Damage - %.2f remains, %d stacks.\n   Dmg In Flight - %.2f remains, %d stacks.\n   Heal - %.2f remains, %d stacks.\n   Heal In Flight - %.2f remains, %d stacks.\n   Count Dmg: %d, Count Heal: %d.", dot.adaptive_swarm_damage.remains, dot.adaptive_swarm_damage.stack, buff.adaptive_swarm_damage_in_flight.remains, buff.adaptive_swarm_damage_in_flight.stack, buff.adaptive_swarm_heal.remains, buff.adaptive_swarm_heal.stack, buff.adaptive_swarm_heal_in_flight.remains, buff.adaptive_swarm_heal_in_flight.stack, active_dot.adaptive_swarm_damage, active_dot.adaptive_swarm_heal )
            end, state )

            function Hekili:DumpSwarmInfo()
                local line = "Flights:"
                for k, v in pairs( flights ) do
                    line = line .. " " .. k .. ":" .. table.concat( v, ":" )
                end
                print( line )

                line = "Pending:"
                for k, v in pairs( pending ) do
                    line = line .. " " .. k .. ":" .. v
                end
                print( line )

                line = "Swarms:"
                for k, v in pairs( swarms ) do
                    line = line .. " " .. k .. ":" .. v.stacks .. ":" .. v.expiration
                end
                print( line )
            end

            -- Druid - Necrolord - 325727 - adaptive_swarm       (Adaptive Swarm)
            spec:RegisterAbility( "adaptive_swarm", {
                id = 325727,
                cast = 0,
                cooldown = 25,
                gcd = "spell",

                spend = 0.05,
                spendType = "mana",

                startsCombat = true,
                texture = 3578197,

                -- For Feral, we want to put Adaptive Swarm on the highest health enemy.
                indicator = function ()
                    if state.spec.feral and active_enemies > 1 and target.time_to_die < longest_ttd then return "cycle" end
                end,

                handler = function ()
                    applyDebuff( "target", "adaptive_swarm_dot", nil, 3 )
                    if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
                end,

                copy = { "adaptive_swarm_damage", "adaptive_swarm_heal", 325733, 325748 },

                auras = {
                    adaptive_swarm_dot = {
                        id = 325733,
                        duration = function () return mod_circle_dot( 12 ) end,
                        tick_time = function () return mod_circle_dot( 2 ) * haste end,
                        max_stack = 5,
                        --[[ meta = {
                            stack = function( t ) return t.down and dot.adaptive_swarm_hot.up and max( 0, dot.adaptive_swarm_hot.count - 1 ) or t.count end,
                        }, ]]
                        copy = "adaptive_swarm_damage"
                    },
                    adaptive_swarm_hot = {
                        id = 325748,
                        duration = function () return mod_circle_hot( 12 ) end,
                        tick_time = function () return mod_circle_hot( 2 ) * haste end,
                        max_stack = 5,
                        --[[ meta = {
                            stack = function( t ) return t.down and dot.adaptive_swarm_dot.up and max( 0, dot.adaptive_swarm_dot.count - 1 ) or t.count end,
                        }, ]]
                        dot = "buff",
                        copy = "adaptive_swarm_heal"
                    },
                    adaptive_swarm_damage_in_flight = {
                        duration = 5,
                        max_stack = 5
                    },
                    adaptive_swarm_heal_in_flight = {
                        duration = 5,
                        max_stack = 5,
                    },
                    adaptive_swarm = {
                        alias = { "adaptive_swarm_damage", "adaptive_swarm_heal" },
                        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
                        aliasType = "any",
                    },
                    adaptive_swarm_in_flight = {
                        alias = { "adaptive_swarm_damage", "adaptive_swarm_heal" },
                        aliasMode = "shortest", -- use duration info from the first buff that's up, as they should all be equal.
                        aliasType = "any",
                    },
                }
            } )
        end
    end


    Hekili:EmbedAdaptiveSwarm( spec )

    spec:RegisterStateFunction( "break_stealth", function ()
        removeBuff( "shadowmeld" )
        if buff.prowl.up then
            setCooldown( "prowl", 6 )
            removeBuff( "prowl" )
        end
    end )



    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        removeBuff( "celestial_guardian" )

        if legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent.restoration_affinity.enabled then
            applyBuff( "heart_of_the_wild" )
            applyDebuff( "player", "oath_of_the_elder_druid_icd" )
        end
    end )


    local affinities = {
        bear_form = "guardian_affinity",
        cat_form = "feral_affinity",
        moonkin_form = "balance_affinity",
    }

    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )

        if affinities[ form ] and legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent[ affinities[ form ] ].enabled then
            applyBuff( "heart_of_the_wild" )
            applyDebuff( "player", "oath_of_the_elder_druid_icd" )
        end

        if form == "bear_form" and pvptalent.celestial_guardian.enabled then
            applyBuff( "celestial_guardian" )
        end
    end )


    spec:RegisterStateExpr( "lunar_eclipse", function ()
        return 0
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return 0
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end
    end )

    --[[ This is intended to cause an AP reset on entering an encounter, but it's not working.
        spec:RegisterHook( "start_combat", function( action )
        if boss and astral_power.current > 50 then
            spend( astral_power.current - 50, "astral_power" )
        end
    end ) ]]

    spec:RegisterHook( "pregain", function( amt, resource, overcap, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt > 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
        end
    end )

    spec:RegisterHook( "prespend", function( amt, resource, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt < 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
        end
    end )


    local check_for_ap_overcap = setfenv( function( ability )
        local a = ability or this_action
        if not a then return true end

        a = action[ a ]
        if not a then return true end

        local cost = 0
        if a.spendType == "astral_power" then cost = a.cost end

        return astral_power.current - cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 2 ) or 0 ) < astral_power.max
    end, state )

    spec:RegisterStateExpr( "ap_check", function() return check_for_ap_overcap() end )

    -- Simplify lookups for AP abilities consistent with SimC.
    local ap_checks = {
        "force_of_nature", "full_moon", "half_moon", "incarnation", "moonfire", "new_moon", "starfall", "starfire", "starsurge", "sunfire", "wrath"
    }

    for i, lookup in ipairs( ap_checks ) do
        spec:RegisterStateExpr( lookup, function ()
            return action[ lookup ]
        end )
    end


    spec:RegisterStateExpr( "active_moon", function ()
        return "new_moon"
    end )

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID
    end

    state.IsActiveSpell = IsActiveSpell

    local ExpireCelestialAlignment = setfenv( function()
        eclipse.state = "ANY_NEXT"
        eclipse.reset_stacks()
        if buff.eclipse_lunar.down then removeBuff( "starsurge_empowerment_lunar" ) end
        if buff.eclipse_solar.down then removeBuff( "starsurge_empowerment_solar" ) end
        if Hekili.ActiveDebug then Hekili:Debug( "Expire CA_Inc: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    local ExpireEclipseLunar = setfenv( function()
        eclipse.state = "SOLAR_NEXT"
        eclipse.reset_stacks()
        eclipse.wrath_counter = 0
        removeBuff( "starsurge_empowerment_lunar" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire Lunar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    local ExpireEclipseSolar = setfenv( function()
        eclipse.state = "LUNAR_NEXT"
        eclipse.reset_stacks()
        eclipse.starfire_counter = 0
        removeBuff( "starsurge_empowerment_solar" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire Solar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    spec:RegisterStateTable( "eclipse", setmetatable( {
        -- ANY_NEXT, IN_SOLAR, IN_LUNAR, IN_BOTH, SOLAR_NEXT, LUNAR_NEXT
        state = "ANY_NEXT",
        wrath_counter = 2,
        starfire_counter = 2,

        reset = setfenv( function()
            eclipse.starfire_counter = GetSpellCount( 197628 ) or 0
            eclipse.wrath_counter    = GetSpellCount(   5176 ) or 0

            if buff.eclipse_solar.up and buff.eclipse_lunar.up then
                eclipse.state = "IN_BOTH"
                -- eclipse.reset_stacks()
            elseif buff.eclipse_solar.up then
                eclipse.state = "IN_SOLAR"
                -- eclipse.reset_stacks()
            elseif buff.eclipse_lunar.up then
                eclipse.state = "IN_LUNAR"
                -- eclipse.reset_stacks()
            elseif eclipse.starfire_counter > 0 and eclipse.wrath_counter > 0 then
                eclipse.state = "ANY_NEXT"
            elseif eclipse.starfire_counter == 0 and eclipse.wrath_counter > 0 then
                eclipse.state = "LUNAR_NEXT"
            elseif eclipse.starfire_counter > 0 and eclipse.wrath_counter == 0 then
                eclipse.state = "SOLAR_NEXT"
            elseif eclipse.starfire_count == 0 and eclipse.wrath_counter == 0 and buff.eclipse_lunar.down and buff.eclipse_solar.down then
                eclipse.state = "ANY_NEXT"
                eclipse.reset_stacks()
            end

            if buff.ca_inc.up then
                state:QueueAuraExpiration( "ca_inc", ExpireCelestialAlignment, buff.ca_inc.expires )
            elseif buff.eclipse_solar.up then
                state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
            elseif buff.eclipse_lunar.up then
                state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
            end

            buff.eclipse_solar.empowerTime = 0
            buff.eclipse_lunar.empowerTime = 0

            if buff.eclipse_solar.up and action.starsurge.lastCast > buff.eclipse_solar.applied then buff.eclipse_solar.empowerTime = action.starsurge.lastCast end
            if buff.eclipse_lunar.up and action.starsurge.lastCast > buff.eclipse_lunar.applied then buff.eclipse_lunar.empowerTime = action.starsurge.lastCast end
        end, state ),

        reset_stacks = setfenv( function()
            eclipse.wrath_counter = 2
            eclipse.starfire_counter = 2
        end, state ),

        trigger_both = setfenv( function( duration )
            eclipse.state = "IN_BOTH"
            eclipse.reset_stacks()

            if legendary.balance_of_all_things.enabled then
                applyBuff( "balance_of_all_things_arcane", nil, 8, 8 )
                applyBuff( "balance_of_all_things_nature", nil, 8, 8 )
            end

            if talent.solstice.enabled then applyBuff( "solstice" ) end

            removeBuff( "starsurge_empowerment_lunar" )
            removeBuff( "starsurge_empowerment_solar" )

            applyBuff( "eclipse_lunar", ( duration or class.auras.eclipse_lunar.duration ) + buff.eclipse_lunar.remains )
            if set_bonus.tier28_2pc > 0 then applyBuff( "celestial_infusion" ) end
            applyBuff( "eclipse_solar", ( duration or class.auras.eclipse_solar.duration ) + buff.eclipse_solar.remains )

            state:QueueAuraExpiration( "ca_inc", ExpireCelestialAlignment, buff.ca_inc.expires )
            state:RemoveAuraExpiration( "eclipse_solar" )
            state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
            state:RemoveAuraExpiration( "eclipse_lunar" )
            state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
        end, state ),

        advance = setfenv( function()
            if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Pre): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end

            if not ( eclipse.state == "IN_SOLAR" or eclipse.state == "IN_LUNAR" or eclipse.state == "IN_BOTH" ) then
                if eclipse.starfire_counter == 0 and ( eclipse.state == "SOLAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                    applyBuff( "eclipse_solar", class.auras.eclipse_solar.duration + buff.eclipse_solar.remains )
                    state:RemoveAuraExpiration( "eclipse_solar" )
                    state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
                    if talent.solstice.enabled then applyBuff( "solstice" ) end
                    if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                    eclipse.state = "IN_SOLAR"
                    eclipse.starfire_counter = 0
                    eclipse.wrath_counter = 2
                    if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                    return
                end

                if eclipse.wrath_counter == 0 and ( eclipse.state == "LUNAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                    applyBuff( "eclipse_lunar", class.auras.eclipse_lunar.duration + buff.eclipse_lunar.remains )
                    if set_bonus.tier28_2pc > 0 then applyDebuff( "target", "fury_of_elune_ap" ) end
                    state:RemoveAuraExpiration( "eclipse_lunar" )
                    state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
                    if talent.solstice.enabled then applyBuff( "solstice" ) end
                    if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                    eclipse.state = "IN_LUNAR"
                    eclipse.wrath_counter = 0
                    eclipse.starfire_counter = 2
                    if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                    return
                end
            end

            if eclipse.state == "IN_SOLAR" then eclipse.state = "LUNAR_NEXT" end
            if eclipse.state == "IN_LUNAR" then eclipse.state = "SOLAR_NEXT" end
            if eclipse.state == "IN_BOTH" then eclipse.state = "ANY_NEXT" end

            if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end

        end, state )
    }, {
        __index = function( t, k )
            -- any_next
            if k == "any_next" then
                return eclipse.state == "ANY_NEXT"
            -- in_any
            elseif k == "in_any" then
                return eclipse.state == "IN_SOLAR" or eclipse.state == "IN_LUNAR" or eclipse.state == "IN_BOTH"
            -- in_solar
            elseif k == "in_solar" then
                return eclipse.state == "IN_SOLAR"
            -- in_lunar
            elseif k == "in_lunar" then
                return eclipse.state == "IN_LUNAR"
            -- in_both
            elseif k == "in_both" then
                return eclipse.state == "IN_BOTH"
            -- solar_next
            elseif k == "solar_next" then
                return eclipse.state == "SOLAR_NEXT"
            -- solar_in
            elseif k == "solar_in" then
                return eclipse.starfire_counter
            -- solar_in_2
            elseif k == "solar_in_2" then
                return eclipse.starfire_counter == 2
            -- solar_in_1
            elseif k == "solar_in_1" then
                return eclipse.starfire_counter == 1
            -- lunar_next
            elseif k == "lunar_next" then
                return eclipse.state == "LUNAR_NEXT"
            -- lunar_in
            elseif k == "lunar_in" then
                return eclipse.wrath_counter
            -- lunar_in_2
            elseif k == "lunar_in_2" then
                return eclipse.wrath_counter == 2
            -- lunar_in_1
            elseif k == "lunar_in_1" then
                return eclipse.wrath_counter == 1
            end
        end
    } ) )

    spec:RegisterStateTable( "druid", setmetatable( {},{
        __index = function( t, k )
            if k == "catweave_bear" then return false
            elseif k == "owlweave_bear" then return false
            elseif k == "primal_wrath" then return debuff.rip
            elseif k == "lunar_inspiration" then return debuff.moonfire_cat
            elseif k == "no_cds" then return not toggle.cooldowns
            elseif k == "delay_berserking" then return settings.delay_berserking
            elseif rawget( debuff, k ) ~= nil then return debuff[ k ] end
            return false
        end
    } ) )

    local LycarasHandler = setfenv( function ()
        if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
        elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
        elseif buff.bear_form.up then state:RunHandler( "barkskin" )
        elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
        else state:RunHandler( "wild_growth" ) end
    end, state )

    local SinfulHysteriaHandler = setfenv( function ()
        applyBuff( "ravenous_frenzy_sinful_hysteria" )
    end, state )

    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
            rawset( buff, "ca_inc", buff.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
            rawset( buff, "ca_inc", buff.celestial_alignment )
        end

        if buff.warrior_of_elune.up then
            setCooldown( "warrior_of_elune", 3600 )
        end

        eclipse.reset()

        if buff.lycaras_fleeting_glimpse.up then
            state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
        end

        if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
            state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
        end
    end )


    spec:RegisterHook( "step", function()
        if Hekili.ActiveDebug then Hekili:Debug( "Eclipse State: %s, Wrath: %d, Starfire: %d; Lunar: %.2f, Solar: %.2f\n", eclipse.state or "NOT SET", eclipse.wrath_counter, eclipse.starfire_counter, buff.eclipse_lunar.remains, buff.eclipse_solar.remains ) end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if legendary.primordial_arcanic_pulsar.enabled and resource == "astral_power" and amt > 0 then
            local v1 = ( buff.primordial_arcanic_pulsar.v1 or 0 ) + amt

            if v1 >= 300 then
                applyBuff( talent.incarnation.enabled and "incarnation" or "celestial_alignment", 9 )
                v1 = v1 - 300
            end

            if v1 > 0 then
                applyBuff( "primordial_arcanic_pulsar", nil, max( 1, floor( amt / 30 ) ) )
                buff.primordial_arcanic_pulsar.v1 = v1
            else
                removeBuff( "primordial_arcanic_pulsar" )
            end
        end
    end )


    -- Tier 28
    spec:RegisterGear( "tier28", 188853, 188851, 188849, 188848, 188847 )
    spec:RegisterSetBonuses( "tier28_2pc", 364423, "tier28_4pc", 363497 )
    -- 2-Set - Celestial Pillar - Entering Lunar Eclipse creates a Fury of Elune at 25% effectiveness that follows your current target for 8 sec.
    -- 4-Set - Umbral Infusion - While in an Eclipse, the cost of Starsurge and Starfall is reduced by 20%.

    -- Legion Sets (for now).
    spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( "solar_solstice", {
            id = 252767,
            duration = 6,
            max_stack = 1,
         } )

    spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

    spec:RegisterGear( "impeccable_fel_essence", 137039 )
    spec:RegisterGear( "oneths_intuition", 137092 )
        spec:RegisterAuras( {
            oneths_intuition = {
                id = 209406,
                duration = 3600,
                max_stacks = 1,
            },
            oneths_overconfidence = {
                id = 209407,
                duration = 3600,
                max_stacks = 1,
            },
        } )

    spec:RegisterGear( "radiant_moonlight", 151800 )
    spec:RegisterGear( "the_emerald_dreamcatcher", 137062 )
        spec:RegisterAura( "the_emerald_dreamcatcher", {
            id = 224706,
            duration = 5,
            max_stack = 2,
        } )


    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = function () return 60 * ( 1 + ( conduit.tough_as_bark.mod * 0.01 ) ) end,
            gcd = "off",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 136097,

            handler = function ()
                applyBuff( "barkskin" )
            end,
        },


        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -25,
            spendType = "rage",

            startsCombat = false,
            texture = 132276,

            noform = "bear_form",

            handler = function ()
                shift( "bear_form" )
                if conduit.ursine_vigor.enabled then applyBuff( "ursine_vigor" ) end
            end,

            auras = {
                -- Conduit
                ursine_vigor = {
                    id = 340541,
                    duration = 4,
                    max_stack = 1
                }
            }
        },


        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132115,

            noform = "cat_form",

            handler = function ()
                shift( "cat_form" )
            end,

            auras = {
                -- Conduit
                tireless_pursuit = {
                    id = 340546,
                    duration = function () return conduit.tireless_pursuit.enabled and conduit.tireless_pursuit.mod or 3 end,
                    max_stack = 1,
                }
            }
        },


        celestial_alignment = {
            id = 194223,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136060,

            notalent = "incarnation",

            handler = function ()
                applyBuff( "celestial_alignment" )
                stat.haste = stat.haste + 0.1

                eclipse.trigger_both( 20 )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },


        cyclone = {
            id = 33786,
            cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136022,

            handler = function ()
                applyDebuff( "target", "cyclone" )
            end,
        },


        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",

            handler = function ()
                if not buff.cat_form.up then
                    shift( "cat_form" )
                end
                applyBuff( "dash" )
            end,
        },


        entangling_roots = {
            id = 339,
            cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 136100,

            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },


        faerie_swarm = {
            id = 209749,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            pvptalent = "faerie_swarm",

            startsCombat = true,
            texture = 538516,

            handler = function ()
                applyDebuff( "target", "faerie_swarm" )
            end,
        },


        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                --[[ if target.health.pct < 25 and debuff.rip.up then
                    applyDebuff( "target", "rip", min( debuff.rip.duration * 1.3, debuff.rip.remains + debuff.rip.duration ) )
                end ]]
                spend( combo_points.current, "combo_points" )
            end,
        },


        --[[ flap = {
            id = 164862,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132925,

            handler = function ()
            end,
        }, ]]


        force_of_nature = {
            id = 205636,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132129,

            talent = "force_of_nature",

            ap_check = function() return check_for_ap_overcap( "force_of_nature" ) end,

            handler = function ()
                summonPet( "treants", 10 )
            end,
        },


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = function () return ( talent.guardian_affinity.enabled and buff.heart_of_the_wild.up ) and 2 or nil end,
            cooldown = 36,
            recharge = 36,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            form = "bear_form",
            talent = "guardian_affinity",

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( 0.08 * health.max, "health" )
            end,
        },


        full_moon = {
            id = 274283,
            known = 274281,
            cast = 3,
            charges = 3,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            spend = -40,
            spendType = "astral_power",

            texture = 1392542,
            startsCombat = true,

            talent = "new_moon",
            bind = "half_moon",

            ap_check = function() return check_for_ap_overcap( "full_moon" ) end,

            usable = function () return active_moon == "full_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "half_moon", 1 )

                -- Radiant Moonlight, NYI.
                active_moon = "new_moon"
            end,
        },


        fury_of_elune = {
            id = 202770,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 132123,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "fury_of_elune_ap" )
            end,
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 132270,

            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        half_moon = {
            id = 274282,
            known = 274281,
            cast = 2,
            charges = 3,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            texture = 1392543,
            startsCombat = true,

            talent = "new_moon",
            bind = "new_moon",

            ap_check = function() return check_for_ap_overcap( "half_moon" ) end,

            usable = function () return active_moon == "half_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "full_moon"
            end,
        },


        heart_of_the_wild = {
            id = 319454,
            cast = 0,
            cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            toggle = "cooldowns",
            talent = "heart_of_the_wild",

            startsCombat = true,
            texture = 135879,

            handler = function ()
                applyBuff( "heart_of_the_wild" )

                if talent.feral_affinity.enabled then
                    shift( "cat_form" )
                elseif talent.guardian_affinity.enabled then
                    shift( "bear_form" )
                elseif talent.restoration_affinity.enabled then
                    unshift()
                end
            end,
        },


        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            startsCombat = false,
            texture = 136090,

            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },


        incarnation = {
            id = 102560,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "off",

            spend = -40,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,

            talent = "incarnation",

            handler = function ()
                shift( "moonkin_form" )

                applyBuff( "incarnation" )
                stat.crit = stat.crit + 0.10
                stat.haste = stat.haste + 0.10

                eclipse.trigger_both( 20 )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = { "incarnation_chosen_of_elune", "Incarnation" },
        },


        innervate = {
            id = 29166,
            cast = 0,
            cooldown = 180,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136048,

            usable = function () return group end,
            handler = function ()
                active_dot.innervate = 1
            end,

            auras = {
                innervate = {
                    id = 29166,
                    duration = 10,
                    max_stack = 1
                }
            }
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            spend = 45,
            spendType = "rage",

            startsCombat = true,
            texture = 1378702,

            handler = function ()
                applyBuff( "ironfur" )
            end,
        },


        maim = {
            id = 22570,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            talent = "feral_affinity",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132134,

            usable = function () return combo_points.current > 0, "requires combo points" end,
            handler = function ()
                applyDebuff( "target", "maim" )
                spend( combo_points.current, "combo_points" )
            end,
        },


        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = -10,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            form = "bear_form",

            handler = function ()
            end,
        },


        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = function () return 30 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",

            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, active_enemies )
            end,
        },


        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = function () return 50 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            startsCombat = true,
            texture = 132114,

            talent = "mighty_bash",

            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },


        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -2,
            spendType = "astral_power",

            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            ap_check = function() return check_for_ap_overcap( "moonfire" ) end,

            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )

                if talent.twin_moons.enabled and active_enemies > 1 then
                    active_dot.moonfire = min( active_enemies, active_dot.moonfire + 1 )
                end
            end,
        },


        moonkin_form = {
            id = 24858,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            essential = true,

            handler = function ()
                shift( "moonkin_form" )
            end,
        },


        new_moon = {
            id = 274281,
            cast = 1,
            charges = 3,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            spend = -10,
            spendType = "astral_power",

            texture = 1392545,
            startsCombat = true,

            talent = "new_moon",
            bind = "full_moon",

            ap_check = function() return check_for_ap_overcap( "new_moon" ) end,

            usable = function () return active_moon == "new_moon" end,
            handler = function ()
                spendCharges( "half_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "half_moon"
            end,
        },


        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = false,
            texture = 514640,

            usable = function () return time == 0 end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
                removeBuff( "shadowmeld" )
            end,
        },


        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 132122,

            talent = "feral_affinity",
            form = "cat_form",

            handler = function ()
                applyDebuff( "target", "rake" )
            end,
        },


        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.17,
            spendType = "mana",

            startsCombat = false,
            texture = 136085,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "regrowth" )
            end,
        },


        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.11,
            spendType = "mana",

            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "rejuvenation" )
            end,
        },


        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 135952,

            handler = function ()
            end,
        },


        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = true,
            texture = 136059,

            talent = "renewal",

            handler = function ()
                gain( 0.3 * health.max, "health" )
            end,
        },


        --[[ revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 132132,

            handler = function ()
            end,
        }, ]]


        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132152,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                spend( combo_points.current, "combo_points" )
                applyDebuff( "target", "rip" )
            end,
        },


        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            form = "cat_form",

            handler = function ()
                gain( 1, "combo_points" )
            end,
        },


        solar_beam = {
            id = 78675,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            spend = 0.17,
            spendType = "mana",

            toggle = "interrupts",

            startsCombat = true,
            texture = 252188,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                interrupt()
            end,
        },


        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 132163,

            usable = function () return buff.dispellable_enrage.up end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeBuff( "dispellable_enrage" )
            end,
        },


        stag_form = {
            id = 210053,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 1394966,

            noform = "travel_form",
            handler = function ()
                shift( "stag_form" )
            end,
        },


        stampeding_roar = {
            id = 106898,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 464343,

            handler = function ()
                if buff.bear_form.down and buff.cat_form.down then
                    shift( "bear_form" )
                end
                applyBuff( "stampeding_roar" )
            end,
        },


        starfall = {
            id = 191034,
            cast = 0,
            cooldown = function () return talent.stellar_drift.enabled and 12 or 0 end,
            gcd = "spell",

            spend = function () return ( buff.oneths_perception.up and 0 or 50 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) * ( set_bonus.tier28_4pc > 0 and ( buff.eclipse_solar.up or buff.eclipse_lunar.up ) and 0.85 or 1 ) end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236168,

            ap_check = function() return check_for_ap_overcap( "starfall" ) end,

            handler = function ()
                if talent.starlord.enabled then
                    if buff.starlord.stack < 3 then stat.haste = stat.haste + 0.04 end
                    addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                end

                applyBuff( "starfall" )
                if level > 53 then
                    if debuff.moonfire.up then debuff.moonfire.expires = debuff.moonfire.expires + 4 end
                    if debuff.sunfire.up then debuff.sunfire.expires = debuff.sunfire.expires + 4 end
                end

                removeBuff( "oneths_perception" )

                if legendary.timeworn_dreambinder.enabled then
                    addStack( "timeworn_dreambinder", nil, 1 )
                end
            end,
        },


        starfire = {
            id = function () return state.spec.balance and 194153 or 197628 end,
            known = function () return state.spec.balance and IsPlayerSpell( 194153 ) or IsPlayerSpell( 197628 ) end,
            cast = function ()
                if buff.warrior_of_elune.up or buff.elunes_wrath.up or buff.owlkin_frenzy.up then return 0 end
                return haste * ( buff.eclipse_lunar and ( level > 46 and 0.8 or 0.92 ) or 1 ) * 2.25
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.warrior_of_elune.up and 1.4 or 1 ) * -8 end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135753,

            ap_check = function() return check_for_ap_overcap( "starfire" ) end,

            talent = function () return ( not state.spec.balance and "balance_affinity" or nil ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if eclipse.state == "ANY_NEXT" or eclipse.state == "SOLAR_NEXT" then
                    eclipse.starfire_counter = eclipse.starfire_counter - 1
                    eclipse.advance()
                end

                if level > 53 then
                    if debuff.moonfire.up then debuff.moonfire.expires = debuff.moonfire.expires + 4 end
                    if debuff.sunfire.up then debuff.sunfire.expires = debuff.sunfire.expires + 4 end
                end

                if buff.elunes_wrath.up then
                    removeBuff( "elunes_wrath" )
                elseif buff.warrior_of_elune.up then
                    removeStack( "warrior_of_elune" )
                    if buff.warrior_of_elune.down then
                        setCooldown( "warrior_of_elune", 45 )
                    end
                elseif buff.owlkin_frenzy.up then
                    removeStack( "owlkin_frenzy" )
                end

                if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
            end,

            copy = { 194153, 197628 }
        },


        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.oneths_clear_vision.up and 0 or 30 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) * ( set_bonus.tier28_4pc > 0 and ( buff.eclipse_solar.up or buff.eclipse_lunar.up ) and 0.85 or 1 ) end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135730,

            ap_check = function() return check_for_ap_overcap( "starsurge" ) end,

            handler = function ()
                if talent.starlord.enabled then
                    if buff.starlord.stack < 3 then stat.haste = stat.haste + 0.04 end
                    addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                end

                removeBuff( "oneths_clear_vision" )
                removeBuff( "sunblaze" )

                if buff.eclipse_solar.up then buff.eclipse_solar.empowerTime = query_time; applyBuff( "starsurge_empowerment_solar" ) end
                if buff.eclipse_lunar.up then buff.eclipse_lunar.empowerTime = query_time; applyBuff( "starsurge_empowerment_lunar" ) end

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

                if azerite.arcanic_pulsar.enabled then
                    addStack( "arcanic_pulsar" )
                    if buff.arcanic_pulsar.stack == 9 then
                        removeBuff( "arcanic_pulsar" )
                        applyBuff( "ca_inc", 6 )
                        eclipse.trigger_both( 6 )
                    end
                end

                if legendary.timeworn_dreambinder.enabled then
                    addStack( "timeworn_dreambinder", nil, 1 )
                end
            end,

            auras = {
                starsurge_empowerment_lunar = {
                    duration = 3600,
                    max_stack = 30,
                    generate = function( t )
                        local last = action.starsurge.lastCast

                        t.name = "Starsurge Empowerment (Lunar)"

                        if eclipse.in_any then
                            t.applied = last
                            t.duration = buff.eclipse_lunar.expires - last
                            t.expires = t.applied + t.duration
                            t.count = 1
                            t.caster = "player"
                            return
                        end

                        t.applied = 0
                        t.duration = 0
                        t.expires = 0
                        t.count = 0
                        t.caster = "nobody"
                    end,
                    copy = "starsurge_lunar"
                },

                starsurge_empowerment_solar = {
                    duration = 3600,
                    max_stack = 30,
                    generate = function( t )
                        local last = action.starsurge.lastCast

                        t.name = "Starsurge Empowerment (Solar)"

                        if eclipse.in_any then
                            t.applied = last
                            t.duration = buff.eclipse_solar.expires - last
                            t.expires = t.applied + t.duration
                            t.count = 1
                            t.caster = "player"
                            return
                        end

                        t.applied = 0
                        t.duration = 0
                        t.expires = 0
                        t.count = 0
                        t.caster = "nobody"
                    end,
                    copy = "starsurge_solar"
                }
            }
        },


        stellar_flare = {
            id = 202347,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",

            startsCombat = true,
            texture = 1052602,
            cycle = "stellar_flare",

            talent = "stellar_flare",

            ap_check = function() return check_for_ap_overcap( "stellar_flare" ) end,

            handler = function ()
                applyDebuff( "target", "stellar_flare" )
            end,
        },


        sunfire = {
            id = 93402,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -2,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",

            ap_check = function()
                return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,

            readyTime = function()
                return mana[ "time_to_" .. ( 0.12 * mana.max ) ]
            end,

            handler = function ()
                spend( 0.12 * mana.max, "mana" ) -- I want to see AP in mouseovers.
                applyDebuff( "target", "sunfire" )
                active_dot.sunfire = active_enemies
            end,
        },


        swiftmend = {
            id = 18562,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 134914,

            talent = "restoration_affinity",

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                gain( health.max * 0.1, "health" )
            end,
        },

        --[[ May want to revisit this and split out swipe_cat from swipe_bear.
        swipe_bear = {
            id = 213764,
            cast = 0,
            cooldown = function () return haste * ( buff.cat_form.up and 0 or 6 ) end,
            gcd = "spell",

            spend = function () return buff.cat_form.up and 40 or nil end,
            spendType = function () return buff.cat_form.up and "energy" or nil end,

            startsCombat = true,
            texture = 134296,

            talent = "feral_affinity",

            usable = function () return buff.cat_form.up or buff.bear_form.up end,
            handler = function ()
                if buff.cat_form.up then
                    gain( 1, "combo_points" )
                end
            end,

            copy = { "swipe", 106785, 213771 },
            bind = { "swipe", "swipe_bear", "swipe_cat" }
        }, ]]


        thrash_bear = {
            id = 106832,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -5,
            spendType = "rage",

            cycle = "thrash_bear",
            startsCombat = true,
            texture = 451161,

            talent = "guardian_affinity",
            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "thrash_bear", nil, debuff.thrash.stack + 1 )
            end,

            copy = { "thrash", 106832 },
            bind = { "thrash", "thrash_bear", "thrash_cat" }
        },


        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",

            handler = function ()
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
            end,
        },


        thorns = {
            id = 305497,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = function ()
                if essence.conflict_and_strife.enabled then return end
                return "thorns"
            end,

            spend = 0.12,
            spendType = "mana",

            startsCombat = false,
            texture = 136104,

            handler = function ()
                applyBuff( "thorns" )
            end,
        },


        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132144,

            noform = "travel_form",
            handler = function ()
                shift( "travel_form" )
            end,
        },


        treant_form = {
            id = 114282,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132145,

            handler = function ()
                shift( "treant_form" )
            end,
        },


        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 236170,

            talent = "typhoon",

            handler = function ()
                applyDebuff( "target", "typhoon" )
                if target.distance < 15 then setDistance( target.distance + 5 ) end
            end,
        },


        ursols_vortex = {
            id = 102793,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = "restoration_affinity",

            startsCombat = true,
            texture = 571588,

            handler = function ()
            end,
        },

        warrior_of_elune = {
            id = 202425,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 135900,

            talent = "warrior_of_elune",

            usable = function () return buff.warrior_of_elune.down end,
            handler = function ()
                applyBuff( "warrior_of_elune", nil, 3 )
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]


        wild_charge = {
            id = function () return buff.moonkin_form.up and 102383 or 102401 end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            -- texture = 538771,

            talent = "wild_charge",

            handler = function ()
                if buff.moonkin_form.up then setDistance( target.distance + 10 ) end
            end,

            copy = { 102401, 102383 }
        },


        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 236153,

            talent = "wild_growth",

            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },


        wrath = {
            id = 190984,
            known = function () return state.spec.balance and IsPlayerSpell( 190984 ) or IsPlayerSpell( 5176 ) end,
            cast = function () return haste * ( buff.eclipse_solar.up and ( level > 46 and 0.8 or 0.92 ) or 1 ) * 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( talent.soul_of_the_forest.enabled and buff.eclipse_solar.up ) and -9 or -6 end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 535045,

            ap_check = function () return check_for_ap_overcap( "solar_wrath" ) end,

            velocity = 20,

            impact = function ()
                if not state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                    eclipse.wrath_counter = eclipse.wrath_counter - 1
                    eclipse.advance()
                end
            end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                    eclipse.wrath_counter = eclipse.wrath_counter - 1
                    eclipse.advance()
                end

                removeBuff( "dawning_sun" )
                if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
            end,

            copy = { "solar_wrath", 5176 }
        },
    } )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageDots = true,
        damageExpiration = 6,

        enhancedRecheck = true,

        potion = "spectral_intellect",

        package = "Balance",
    } )


    spec:RegisterSetting( "starlord_cancel", false, {
        name = "Cancel |T462651:0|t Starlord",
        desc = "If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\n" ..
            "You will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat.",
        icon = 462651,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "delay_berserking", false, {
        name = "Delay |T135727:0|t Berserking",
        desc = "If checked, the default priority will attempt to adjust the timing of |T135727:0|t Berserking to be consistent with simmed Power Infusion usage.",
        type = "toggle",
        width = "full",
    } )


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20220911, [[Hekili:S33AZjoswI(BXXgnfySXGW4YvhL9g1ZD7E7xB76o99tglarHUfiXijSlVHd(TFZZ5KVvMscm1m9mZgXmDz0JuzEYZ7x5TdU9t3EZSWIOB)LG(bb9F1Gb9gmyWLJgD7nfpUo62Bwho9lHFM9hjHRy)33gUmmzkE9hxMgodE)80nzWLwuuSo)7p7Sj0ZCAE8QP9(CCXInt6fNEg)vp9M4vV7SvZ6TOy1Y)95XlJUI)c9k(AXT3mzt8YIFi52jUNydU9MWnflsZU9gyGyF14zZIOhpkFQCgU9U3NTjE22F8MO1frRMeLT9Ubdoz7DWWT9h3(JVBryYNJY)(T)4PBV7nSXy227UjDzi75EBu4QE41PhIDNIWSphvmoE(27MgMhLZUsk7pFC6YOX09YP343JwLEp8gBssIMgLNhM9427UpmloCYs49Ah3lQhBESol6(X5S3nFd713E3PxtxRN8ADOr8n3NYwhW9yF5I4KpV9U)ilSyX27GztCXlGjZc2i8qwkCZpmDz868i6L)5WVWUZ7stUpf(d85UzDCwCb7Tc3E3Y4IILSRTknJ9FNVm6RXtGF3gg7ht3S9UfHZsErb7FJlGV227yBRBwweMeLUjFjBT9qmmxE7V(MpT9UUSVveBzwehUKnZxg)5KvrjfNGZt2Ii)lXR7OpZwLMZgYxmp(ZlkgNfTkmoj)fSNBAucdKLctY1RHVcaUNKMZUa(SS)nnz5J0q9PSOq2O8P0vSrmLnXF7YWfM)3qA5MVoAko1kYIt(sub9()66Oea)qS1GGxT)9g2oY84SOoS5B4mj0klkpEzmB5rZUOWm2VydZ00vtclof2h5FGpg)1T39FfNmldWm(WQ1PpeLTcFZPlIM(f2IkL9IV79m0MCg1MoQ027MbiY9sshpDwo)faKTT)4Bsssly0iSXuI1)MF7Nau0eg0c2qt3KWUlaDomuNlJZlYbI(ueMX(RFb5HW2Uy4nZU9TmYZPfXPj3EZda0JOkZIxtx73iKygvOejoeNGeqMtkKYM938jbM1Va73myyye)HFBkGQbamXgd7xmm7ShIZzSHyFTIig52T30MTPWjgwUHHpnoj6RSr6PNuxpozCor0BD1jPW3w)IHjpYhagEqloX6GEpqld2foIFTa6A3wW4D5b2KZN4wZ224GKTjjIHpWqd4G(XPZhhUC54IfmQ)8E8XJMDhb4B3ZUusrVeKkAoaO43IHVdVhNbf(vzd027UIXmu(qfHlJG3oSyddLESy)w(z6qpPg0ebzUHMiGExHMDeWVCgp2jPjBY7vWiLcUCCW6Pasxsed5)2BgbW0HvatreilGAJbNTCdkBvhyCxM9fabX8qgdujPJC(Ja1jmzp6lphirQvxrmWX714EdJI6ygbcoyecypGuBm9mDL3sG6PF3oa0llEAbmLKtOPaqI(XyGUNO(htkcWP)DSFKUMnArfQXri8d(RLBy)JpW51i4SLGoGJxc3FzA2mt8E5nzdfdSnllEErju2k(qbwCMUjcKP8M0pqSFg2Ly)KUPayaZgCoZhIN0n85e)IbDn4aDpqCGqP48XHPrau68dbucz1bqjNtEMUiHG8IhweLOZBeLgGIVH5jFaHhlEkOeroijBz09HG4iuoeQLaxncUK3iK328OmucgbjO3NjJyji1d1hkeWsmw(0KcGaJ2ziaQI0NNoJXLDvAAcTAG9vTBKVXZ1vItCChcnW6gZ3K9iWBiIXdt716LXwajmLDgpplk5)5r6ot2mFoJeACCY0EC9wq(b6xF2ggzymGobVHy51JJuyUf(x43fG(Hc9cYjD8q9WcHfzCckRKnFjaEiPBiUHLhxSH)5yyaWthk1ZHX3TykTxVjh2bJrfekEicqvGTTCJ9TeaKaBAx4HzltF68OSVWyGATo()aOmVvExs3dC(fbinG2zFKdgj80fSpEen1cNG67Cr)VJP0v48caTsQ6kxnZ0WpXX)KeCI79U3C2pKm1Pi1keronnD5S0hs6nL(smXcrJZjvK7TzT85ASyesCGt8dG0DKqAHCoX(NIfpYfAw(QwdgmLexYcZuCV2EUTCE8AqWftGbtjZZrXgQfxECY8nlhV4XCegAY015I61GHv09z)ZzcUU89vs40GEVc)AwCTNZ(pAkAWMi97naFqsN3zrldFC8enSj8rgkuAGa1kcljA7l9kYSDTBn2kHvpeXpCMnOVQ6TlUKkY0MwCRBgRpcbJ8TqT0ToTqqjekigeCtIZrB4yx)32SmhuqBDw6usjAImejrNtQAZPf3imSjzMIWFDk(Vmy8L7m)8PrXlr4B7sRZtjW)P60Jw7qDqKRbx2h)t2(1ooCoiV9m2e9zwy8SXrazyVWzZye4FfS9rdfP8mnC2JnJVc)r7iO59SKVgyuZW6wZunKzM3yRvj8Uk80PcdVLFftnB9)ng23EEufSQMjfa67xHTjwyTVlC50nWaHAKeb80bzuiXUK3Fs6daQniZMXXf(bkseqozRy4YKvLKCWqqL2WvmtFlibo8XPRGMOK8oX6LnZEKjbHHC)QDg5UTq1QEGo1JlshplosYxb3QSqOazWSBpsI01Us5c89gf3qleUSqWi9SuaC0PSA0gA3yYeZPmh5h08fTz7Z0OC0UicX5cSzFo3Qw1LeLzmdwNfVIPDoqleMXu)nE641iFp1C5u61KakW62)6M41RJygASA9Jmy7YXSXiHCRst3Dk9QMaSlEjoHBVdanDZJR8ZOZrrUuYt3WupVaCB44SntE01kXsNi5hX(Dhp88rx2FGfkW5L)OSBonBtbSag)x3W(eBwXiTUpMdiLFa)pNoQT8XlsrFMXy5WErCopC0OHbdmynDoN3J((jWgJzKaZ2v2RbYmiyGAGnV)4Hx8YGZnxNb8H1Iz31LzSAGzg0xSbYNtT1KIZmRMPm(yPk6kNYu1JmudPv4fZIbeaBSyYqdJ2TLZYDKnEN6NqbLMnbvpBc(woB4a8YwLWTycvPKlPa91kxebx0aPmex(ZS0nOfzP4LI42Da2eIUUL)60Ra2yZ4QZW6OBAPdftwGHaNzmGtYSyHUud6VZYBa)nXiqNeNai4zmPGJZJI(suMj)2YiSb973iDoj(ua90PCEVMFgMD0GNRpgXa6OPoSZhduZ4sCOA3i2E8H1RvYBS3rdtEuIJLZ3QqhMt7ppegtXob9WbSB9HnRxKYgosxy9DhJfWy4nX9iBhDx2U3pWzlV9UFvk5iOFE00CWA75PCJYfiBiofmDYtLkQxiu0bCBi7rwl0P3Ln0IOYvsCGUfpE18JZwRvtv8t986CXkdSAcQqFb(vZqfg63CVAXLh(sfvuzafSXA7G1YBS3qIcreOFhfJEX3(DvB5VwMXw1(6f(DYqRAe(70b4ngb5Is4hM6wxJbp0i0Pc1sBS15vzZd9zKyPvA)EFtn20vYPiBZuMsj5mn9VhCY)KiLU3ptd(n0NYT(OnrNZRLQG4IWHqfAKABg7AvQ3M5xUULAF94FyHUdKMEd2Z0qgCNzMWCM2wrzjGvVmM)ZTd(Zr8DcVp)4ZLo5Rrpyl)(pkq3qU9fy10nK6rJgouYiXlWcaX7EKj(BOd0aDIh1tQnYWEevi(wtwMMoB5M8cbDfxJLEKNFQ(zBePCx(ODC92t0CJjUsTzRmtZ3oKcHRoeZ)8W2Xsa6Bw(q4J5C5I)W)97nDxpjQ0xqcmckXF1wPz7ikjqy9t3OZDqXouFGDXPuqhvX4cth7yL4qnIfHmqhG6)RztukpicCbNAL)qm46ey)MB2BzgBUDfHtndqJPTymz4ijn0ajFilhkzjeXLEFoDJLp3luNQek2PZsleX5Rxr8uksa0hcVLr0eKpaFvuDihGhQIaTouFkiIbPXCOP8RnOSQ6bBT7Yog2xmvSduunK8NRl(1dAhGzBhofX7Wn3YoC0FAby9lAbmGfr(0LzL2KuG1fylgpHUwH5agglwPn2m4FHUHCIWpdAoptx1zb)d0spPRIXFHdeYpja(z(si0iWxa06bIOkLpkAwlI5qK7PGtEg2EE4ORe5UWr16iKdRpGAAadBxNSwnPNn2ZKGWmnVmTimFm(ruobRkzs(K)p2(tQjaRkdF6sQGCTBpFzgnEBLuAGlJLtxhQ(CHglYQ4oFufGdDkFV7snHfB1R(RBkpydSqBZ4ATtFMYHYRL5k4lpY(ojvAdAvtLkxqCyRJi2zrAWZnnkh2m2EhPT7lEkmFTSFkD)G9fkHphhPY3ZXqst954)NOMQtw)6zg0hzrBhn2gYZkOepl3UsUroa(ppSIc(tiROG)LMvKZv)HNvu9FM)xwrFlzfzRAyaYCYoA62wgLlucKuvuQigJf2QCHMBQXg(S4TWSJ1o0jgd(hIPH8ZPyaMs5QfcjlaA3zkOY4ucnHYXvXhHrpAM8RAziRlJi5j1NwkYYZ8ZaFjiFPVG27Mxqjlmu1hy5eukDHfBPCuRAYz46DQt)skXhP2SjT5ZJ4rZQVqh8KuH2YY9mHAZNGAYAKCrziypHpA834euacOuoTZebMIZTEa(JH6AShMzegntuqFjJC4SzvSUn2oT0LfgCG(PbQ7uskACEVI0vywcUkfCWeWcDAk3vtS3jV6vIl3Yv9kjW5kjOIvItULTSTH55UsCL4VExjEggTvwJSI2WCBhoYY4(Ld0InLGoIn3AXeWMYWnmiddUbPk)JqOilIMI1JtyUx7j7T9UT3DdqkPOUaIQZP3IrfarZCje9OKiySKfT0cgbXsWFnYT8ZDLJU1tRdomG8PjLTL97nGu1QufmC(AMun7OWsPBosUQv1otXs5cdVkedF2)mLNBxakc7RH3k6RHRwdlzoNbIbsg7nNTz1A0Rkc3IjYtyizTbW585D0XqYbKqKpzP09SEiWODgcO9HNl)W7EoqYJ85G(wQ26n79Cc7b8jE(3RNOBVj)30Cfs(cgE9mY7jq4Y)EkA(YYAqRs9uLeiYYL)u9mszbU6mH5RLjiNyvcEgJjpAmBPyx8kLYSHACYztChvnvC20V9faMwv9mOpjPgK27OA4QhJqHdajo4dPzjJzc2dxbz2HE2COPDOZhuxznOGgwf(vevdtPAPMG1(Q08uvMqrFnA6MIivDeHJhnzQUUV8vLyok9l)tTnRBscJI8IEp8AtdlMIxIK2rrDNk3Ju6cq(6ZFdAwyx1k4NFm8MJHxKH9nF)uP6ixOzTQ0HZV0in5z0ViUpesjglX8c78JPRdu2w7U5K2VcthTIfuT7Kn((4CaHWn7iN7gAcfa14y7PW8sw9YmBQY0Rpjy74Ni0hErhze2NpNWw6QkL2LwEIDahMC5kmmQAkHsDlgoaJtiksdm8dKnGCsrMH2zSHVQmPkBcDyVNkMm76MLTT)klh3NrQbsGOhSCIKni4L1A1yLoiPF1oYGNFUs3mq)pgwugBoI2XsE9PeKNjIIg5MezN6T42yE63KBTeu03kAujpIPGvxzLqYLdDLvnok)qIcAZGn(aEuW7xYjA1Sp7E259t111QsfpABSYQfXXDl1UnxRwI21GkN6sW6yJ33OY5YED0GkZwGy58rhtvBTiL4yB(xQTKC)kizS1R0PjUUzq)A4c1XLbNsnXOiVY44P3TlS8dsBOisNZerTGmOPo6LxJuGT8iG0yYFozZA9Ie7WFq3fHX5i5Gbhbe7v(TkPsdMrPiUIlnRCKIXmHAIQrfKPTMj)iAv8uYsq2OH7JB55e4Y47bHMdoNsKqswdkfIKZq9yc5mnu0hhmttIqztlrwVUWdbRwACrZXWHLwfunzMtwEH2WUi8EAALk3dbJXYWlAjx2H18LqtQaQaFIfynkdfX6Y0jyR4ivLBinm)mAwaYfcyBKddypx46Xyv36YMAJf1FGj7a0orwHkwUkL6Lh8sw1S(w1scCEoKdyhmIyWAh2E0T3q2EEQu1BBhUJOY5XyA9kn1bskzJK81rOx4DOIs1VCRg8PqKDAMjz)jTjqaPiYJQftPVDPj(qwEh2Yv0yI0XLT9s8n(RyT38FffTMux7gzDEdue4FalVCO18que808)NECAywOGgdBZn5g7BQALCzKGcu6ugL3Jb9eNeHLNg6PgHjjKijIlqGKKwF3Rwz9QTaNUNWY0vjJRk6)bL0)X9wa9a(ghIlEjP2vlKVJjwtfm0B9CKH4x1OxI33lS5k0vCUf7VKqvgpFzeMn4J)8Y4vWN2qYpPOX3XghkeG(vDkOgPwJC5KPAOa(dEhQarKauqS5vqzLogifbNjJn6jaYoVykPK5cDxNK2GObqkKzPyXeJJOmf2Ep4xZBO338os3rrSviPFKD5Ibnvz3iTG08JDD0f1I8(TIQ5aGyiXZkBC1WBDufQnAN3GNdUvO4ecCZ(IKdjYiJ8tYePpN5mfvVdG0mseyg3AuOVH1u2a1qcoudmxL3HQdhGRjUuzcho3XhBqd2m1GyeyOKAJrwvFIrcD5740RP17Sjt7IztPlTCXTRUteVHkqSH0Fy)G8CzzFHocSJOMU8S0OI3XURqCCdSVvoYUuFOUrVHdnoP9uXXhl2uCHDiYzKkMB2gi40vzMn(SnuZmHkODhKUs)yEYwTeDuBau03gCb47zBw3Jqla9BqI)mq3ySL(Go8s0dF0gZUkMYAraHFTXpKMuy4KuV(MpVq2DUCyGGAf8qzEyEzAjJKXYuBMwBwt8ADcLaoAN3v0i5qGdQvybKl)N7udTA5FiFa3Wg8zospZYTCR5U7ZGRL8LASpd0LGvHoDN3Kv0TUQCoXUD4Sq2gW9S13dHqiHQY1baJaZeQMBCI5GmEw4kO1icHzAj1NsG1oKy2UFq(AwQLO)N0GvVl8t8P3QvqFy7N4ZGXaOVaeyBGuuU8t0cXCkuO0FTonpNAUMO5cAoCEOcjeeU()BtEHqhnOpKjUx0xxdgyxvzrjsr9QH42kjv4w5tYFRGRe66Zka0QEkuehV1LFu5EcSJPRw6G8SjHnDLmRlEGT3cRGsEFRKSnfUjflwLmlNYiKvLOPHR1qmEuz1dLsd87oF7xPLP(hvxoK(Bvm8jKResRJxTtWTNxl2jV0qQx59j96S94gV90rq16kSFsv4854rjBp3XJ1ZmTLH6d16sWkWDFTmu8nF52XyD5iRbfQSwBw3zzbcFHlHO4GuFcPAXX63f(W7NL9mVyToCa1V)yq)tqzPyXld)hJiGTv54XYrNtiK(M0IpEI5lcWsT(Ywm53tT3e4VHsXtn)kA1rT5hJPXY7j7nl5Bs3nuxHZDGVTPRrV1v1ok4CY(8KWtsiRlPaFm9x0mHwO7X0W1RTmbQHCzU1vnSvVI(gCtS9mQxfvRpwsEyT0QIIFsZ8mgUBEb43vf9PDeHKVq9DKi9x1DE86rP9UIOI0YRT)boS9VMSxOJPcrUk9TYCeSYe6NJeaTOHmQgpg5gYHwR9sj)2kIvK73FpBYsgPnLoUQOROwQMjfy9wC9CsokCZUNWYRVsmIt7OQWX2ZvkKG0xyIL4C96ZB2QaDgkAA6oZCbrnZY5cjy2PLPcaYOw2kq4tonLXEc6cj2UIbAqTyap5ob7QGG)kcS2r7H8uUcoVNjLtp0BQnPszkT1j3NyZVWSeC6DRRmBx8CCr(aNh7uMr0PyiLzFlMTZ6svmnJLV3MJrndDjROdos19ORSrPQKUWlw)oTLDmrLOZqwFfBrpvFIrC5TUYKFLVd0QD3D00gh9Ip3g)kuhKm(vjcxtOQlMj9nv5tpbi8PxgUm4PhmxvOHAQcPYptoX(KikOTADKt0sqokagexiNQeAIuvnhyi20TsoFG0xKTcJNfrXRufBzF8zk1zrXN8nCZTzO0C)aOYIBNMjzQ50r7iwPPV68)cOIuep7r1Kds6kt43bc21CUshGOPzPuJcVKjAc)gBoRRIf2RegW14M2Bh)8gfkg6XoJs5WJRcwsc5C2NNETKCZv1e131DqkkfjvDn4mL5DnOtO5LR41ugpxPAvJQvXjmpG)LGkpXhkhYgKMluNL)Vc5EPGksiFxDBm00l5Mpd7bGibvdcxJjbNLa6A3s6fXZWZ1ShjcNk2fGM)OPuYzmVcaE4IVQJMbhl(3Vz1AUNNlfTqBjHi)KczNTV0b9GNk1R2Om0AxCpJdm)sz8wJvLxMjrmszzRm2e4EMlpDPrt7mssynHeyBNBTqQ)obfgzQ0CfEp3HeJQCOURqpaagV5VuXUeGcqQObLkqgY7v)WbDKoXN4Dy3ktpNZ7bNqsGpLNPOdkNHx4V(lc1WbOn9HuKgpaL5b6Iez8HSzl4p1t05gyKV3I9xUv0CvK6zOyuZdOHJek1DAJYFPkEVDLUjVmDJlu468Z2bEku3NtNuY2wSov7yZqZuZPwAlDN4wX2PutGMgH)sA8uA6rsn85dGKOhqhW6IGe8TPtN8zyV0h3aFl4z52o50CjC)WFEDBM(WC8ZPlGLuUw)pilIU2y5HYJQgS1FAza40t3WG6pWc(73eSX6NoQATnBTlEqOs1sv4ilcxoNqsaOOFt73vOiTIRsLrHLdnts31Y(8()AT)WgGLQ9N66daBV7pehatV796j7AwwCAMYUvOeG29mKPIQbHIX58LPatI2quDH18JJ5wkEm3SKZKDLmJNwQlgYP0iCpeEg3GOZOm(Qj5fImDHnltkoVoTJUjqHbvGu6oGZOlIP)XJWS97KlgsNGZnuMXiYjuCMlLNhSp(yrWPqi)UCG)9RgkEO5CdOJ6QPGZhXa3Xvzru4QZPSrevEIFAbkI9Jfx8QWgBTlXsZ2OHQZo1kCJ0qfT2oWZPS5Wo1cAVCsnU3T7fXO7Z0NaHRiWKh7yHoB(aiNULFq5D2U8Kb8ALwOIIJO0wtjsIvbvhbfRSiVRItztPoTqil3VkrYbGYHhcda87ZazxKoe)q6R4sphHfhqp4qXLGxWRywSJ97evBY7rOKsUD3kpAvT6QBLM8CDttr0c3oo5CZXJ(omGsqdCOIu8xvKrSNKNVqsBukrw5499h(DlfHlXdSSzV70C5i3WXw(hs3lNgydJGFM87zHskLKVltil2wiATTZgCBaTkxekNtbN4bhpHYupP8Juo1hz0Tv89n93epxPgABWVXK7JmRrkwKTrlYJv0vEMlEASI)L)QIdbxFEvqtgmkVgoPFnZFbEEKb5OOLKUARcrE9oHQC5BE1KI6ZiU)6iaY)gs9Ra(zNvjgNYtKPzQtMm830H(mHoJNIHZMjt)s6baBRvXqc0Zzrm4VezLKjNbWzrD86LXadFQLIwmfREorUViggexaGgLZvof8b3xZlQAhDhtTXge0aIPqtt6rPz4og5frHlndgHVhYWWejF2dEYuwZZYNQUyyyf6OTQojfYejNK7ban4zWrfsk6C)zCjpjoj8WaIvY8OhK5hnN7cwRM8eV0oTplOMgXdYBbgMGLXjLZM8caKEy(JqXQlVkIXg12cY1CoUD(CvooaKNBr0a5rBJEcbWDtI6f4fU259pBy)2L7mmD4(NKFaKoOpaEIMQNMwCFzsjRfwOCgzXnbhG9i9(bomEMtqJWBlb6aF0ITIsELsC7hyJC6d9Sj4moT0Bj030RVTB5m6w)Zu7z4BExzOPTKbn3u8nVBl0vKuY7UHs44FXWQbddRqLnhTYHDXNPhTdB74eW5q63oZo2Ow)VDabYt0n4KLVYqd5OqvmybcRmUcWf8W2OYLdreqNhNeNlAuar6XlsP9lfWiRyME7(veE0(AB1UvTytCnvOZy(g2EOk3nTC34T0TdTZUGIxTDxFlABv6Eb1BXj2XKsWYOnVcLisUMuxaTCNXPFdy1QZgWtZY1vQGPpsxUTMwnIhcnkrbKuA5cDfElXLG0l4nGJp(eYOq3oXO1O(nu4FmZUaBBRAmZTwgemnH921YdwJgZEtp7GQkqeVSmRnpDEyoM4Z9m(IZm1r84lLAiCp4X73K(lceeRyVsf(QCLNEM7uz8keqWDXjXIVDLf5Hoyt15yCsEwMUt(cLOrltkB8STvlMY1oJoWOSlXKGcP)v5P1VsBaB78v1FasJHH3LzYxUWoi4q(G9dgLB0wr3nLbz1kPdyyjZ7(DoSxLD3lqt6mRnfQZ2qlFuqjsTdclTsRwUax2dRLxuwjjHz9PyF0NtLCNEZbmf0SaRAwyRgTRB3BaRo2Hu7bTQA7R(niBBwQsda)7L0EhgFXCzMTWTvKbEOCdnsa2W8nlbBbUPfsR0rpuJ5raCP4CvHdrZzB4kFChZhwa06lF5BwHowpnM8VBanMXZkfD7yIl2LAyDwoGI)Rr4CngEd8nljJyxigRpC9qSbMv)BY2pLmOBAzjCxKEHHQdUprMS7i6S3(nI0NH)ZnaUegvrvDIdZut)F0Gmx8SHmLAvfYq))nOI6WpOppZUJ1CHir(Ee6FaGueqYZNxaoqK3OsntPOcie6aJox5)()0wugLkX)6fU5mbHPOfhOFMmAwcFCTEpv43MYgP5UnKtkoGoNuVHxdMilIjGEfsWMgVpADe1jBsGuedZmcM8TpatJTYenwU9BueBH5RhddncACDyduBhb2L)jV3vHhzOiqjNjA5vtX8syjwzn8Tv(xy5wl)gUPxI2ntFcb7hFNyFvvjPp3JYVoMCV8uKMEye6Mcuu2Kk72mogrBv6Q6677LOU9(5uYo6Et4zFiDswYDXlfZi7UeBvLuIL7FpQseoV(4WWLb1AZ5OT7VFiT8pnLkETQ9RlnoLgLQCJEvZEVVUxeK9e7qcCoeL8SeLV2YOclstv2qANSYTCw(pxwMDUrbUAeSQZKv6V55uapwtaN9harTkXWGLhKGH3kOn96WvXNKhOUEBV7NXJLsUbRGvGjf8E1uPgHa(n2KZSYz7DFcwviOMIDfOv(7EFUiNCMaNKprBVJJyLJzLSqNdrAevO6Ur8LiSAPEM6Ki4JLZUz80y2Ccm3sAbDpVLAnDsv4TXhSNvATkrfK3LaVlrpvdAuXdfQmcFudNiXO)awQueCfXPklyBaB6L7TYsT8vW2COMTpPuZwFVMGo09Sfjw2)PlxqOZscqcI23kK(v40cwlBIl6bN8uXmJrK1JojZKt031WltLelQlSomdkasdhijd8TJQEVWrxbOEOUAmJTQq7D)SHPkNToGCO5iU)mT3g47pvfSzFIk11l0Ii8VWhoKYzgpffMeVKT4bpRX7OMHjCNwbQ)c1)WmJIEWkpg4EHdFXC8ilIsHbbxr2JSYivGzdiKHLJjGccA95OGAkY4CJQmERJkmUiJwyvAS1jA8vSmTBpl(yB1eEvGQVs50yLJnpo(QSeABMWuGB25nTMKv5OO5MJMQa(Qe5AZjNTUJ3JbMEt4O83ZcwEVIrvWHQuGR(upSH9qCthVQ5zAkGWHyIudwG9po9s8s2SIPgL)E)G)6MMxaMQkHeYk0C7YJmoNAxXR9v2JLlcA8UIVCpnFPHtvF(FAkyhYs8y2R0NskguhpzKbVb)EkCuJ8rO0cjh(FHMfAv1bmxkLWMW0NGCeJcrMkuogm5AHF5edm0c4Z1v)a0bvPD6MmsAJKrpoOJ6Qpsi0D393KN4zUt6x1QPmO7AdF7I5ce2YI590GQL(3etgFT9h5mzmuLb6RvZIaR3mXQYABRcpTjmXs3zBaD3uamgXqDEuPfcP0ISwMKHFhD5l)7Zia(qEod3GbZH3Lmtcq1Ya4nGdkpzarKQeipfjtQyVb8de9dJ2Fu28OPOHrCB2m8lRM1h8PIHV9GvbF3EmUqq8XDSNgOY29qvXlz3m2X4vcwlEU0ArrvCauENiG1Ys7iu06hez6Pkh4fRq5PnbOXd4XvgWQTmWO8ngZE0Y9s9kJ5W7o8yIoBDOwI1YjwVSRZaVcVlOghLGYwE9U(2oNNdCXAnJOk20IxUPoTCx0qt6UJwv4Dwp(LfF4g1viLdqjKsDVa6s7Uw1b0Bj92AnjW91YuYRP5MULVbRZqQM7bq(lq1l((K9q5(6Zi8YSajsKxuZh8OUwuSXWSUwMc25iyzdX0stXmGVhDIc6WQv3Sy81skAqbWtu9o0q8m8N8qPTvvaXiZMv6o4sylOdJX4NheOvK)N)8zF8NDfto5UDZQOzCt3QCMrOGFJ(pGFjNACvwxQYLuFnQOzLHTQ9qZcu3Fz()pYRrZI8UQJRKMKfTATvfb(QwdsHq4DB4)jC6y7ULs(2kY)hEdBXvNsYTBc0nDWzhtP5C5Dl8y)TD1HJs11PuVTLOQE9M13soaEdWzxtP0eOlDkfF82AAtSD8pxjvYvJGGpQ)CKYR)iAvJZiCDtNzmixIDTaPQZJ5wLRe7(9oVHW)kYBB573m1F4zaAP9URDTHCSOAXRYvzgEGPs3aPVIUWszP)MCsX9mDrvlZC1T8YtpQ7(0J0VVNEgTMismCvN5qUyF)jrAXqkvqbWc7LdPZ1DMaC2iGUnnwC8iaqdgaF6xanOk3QWXtKkHblCN4yPNf3UtDE2vzVW(zrGCOe7UUBaEMwKGVGDrt62tpgSs8LWNnJ4eJfw)Dr979iyfuPYS7TFLYXE(y0aJZQJPxxCA681BJ8aAC7GyOqSrfScXsfboFUS76fDvhMUc5kyITLpMNccEsQ2pW0IEf1ajwaERy1gOaLj)JbAD)z2Mcm)wJvIkEkB1d0ccDKcL70GBEtcxNVasKP5sJ6LovlpMzicXZdcYJQHWHoHz6ui8Jr83CjOSimcSv78SWvr5w530VfLX2RWn5DTQ2TQtdxH3jxe5BZc0f9WyQ4SjfTNHCXd2h8uH(5sW3IKoGOhESRtkv7eqVqubUn6El5ex5oqPw6hQ65Agr02s5kaEldDpV1xn63y(mnM6U5cRFTYvf1EGyrZenQmv7WOKcA6ILi0fvw95X(HUKlhmvMdI1uox8fPOaqGDnDivblZYe9770XY(NDB6OyWFKP()LdDqnUSQg2Y8CnRU2zRqGGV2U7WHIaV1avCpwtJlpTJxNAAGTW3dra3eIu8vE8nWniL1EqRla(FYmbVRNwbi)bDDuIilPD0HX)YpZF0pc)rHWTQIU0PiED65Lu5AGxA6Pxl)RlKUFRTPVWrtk6pNtvJpJvDv2qUJctzoa222gnVrM8YnGS7zAgH(CUPcBqoQgqrrwi689KRp95IZNeNqE85vPMd0)AIoPZtehVADq0baR8Vzn8X)eJmA4CYQBguMDGYPZ0trchDGsF9TwHzmEJmySiXsD1fRorjAspU7ieII(EOSTWXHFWdjcRivfE25Pkf6qMen6icwLPQrYuB1U1Bbr7qgRxkoaLYdaeDpN38C0k9fXpeblHYF1v8eldpOWEzoKCSAbtKn5OMHpfbtMERFh(fHLNzt2Jp6bbbQNqw8qI(WNtV4Q0HSkSzDfpTtjAnvKv9dajTOdFUwHLMTkZTrNqYFwC)TjZgETYXEv65Gx6IVKvYm28O69slUhHm7OlYsb0nJbAsuwEug48ixVFNsMly7WEBky5oTd)PoQwoV1WmKM52VylpoVL06Yo0qo4mre9ANVEA9b2YDppngjMzmGjZbnMCytOeMl2HWz2bQL5XUfZEBiyjqgFfe0)YG(iZvGbq(T38hV53)LF4x(p((T3bDYbGjet4yMWNhViDniG8fB1o2IZXuQpCtrk4ILzyWWs(mKf))4pHzoAW3t8HIYWB)cfTZ)3xqaf9ljiBy3Q9GV2rokdFMJY2FSML2SO5HBwwSBRTlmNv3eV6DS36XKcW)VFhnV(PnmE7ZIPquXWeywSgwGr(5SowlYl27fzG2O8Y9Eu0Nlx(8xAb(hU9Cs9Q9EugwXOuWKT9LOIEduJI4sf01mwk(E9ahVEq5xFq)9ErOdkgm4WmmhgYZbNFygM9h3nOQHPb7WN3K3VITyJLX(JThu1W0GLrLtJgSmiWaYFCEkKCFOAFHBYanpFaBQeujqaI7OoyWuYV3GihqOCH45siFLVjX4PNndE4zHfHtcZJ(EgNzWODz95upJAOSysxnjChzvBlaPbWsDEg243nauo8qW(dC01h(1FQ5YXctJ2naZHHpYHHnYEpk2Gjp75KFHv7y8FF4v64s)YJTKKQlkDv6SnlHEVJMK0VZwjHddlYQfVVZtQ9g)(ajEFqfcyFUQUmy4ZF8mMFJomlZ9xBXVfICpm7Db7p3i9ztWbElly0ZF8cQy82HLPX0A)37mgMdd17WdmD3W9gxWJ0GGN)8ByZeclS5(f7KK4dW8RHkjKVJkpT3YLneeU)IthuHMy73OS3mpDJBDOSgB)brJ0hMddm6qjO6WWEj4GrE4E823P1(VLvfp49z1n8WZtp4Wiw)qiAy4br0GPeM9FVZyy2FYnJHzV5jjz7)dixE4LVW0WCGvoE(Rnf6xCbyP2npgYnW)T)nTU477HwGW2FeU2nrRlIwnbIn1GbNajBsqa8jG79os8W3t)6uOs)NHBRK7VFBu4QEY7rpm7Uu1CpgcR10WCr7fWOJ2PERFpcoqwMbn5KKOPr55HqwUkcrn7DBh3lQ3juzrRFizE618sLwEToQr9n3NYwFW9NkAXCIZ3jSsBFbgyn2O8qwQw)NtnauJPb2KsL5ARQL4aW6IciB6OiTnFz0xPSRRTSmYxesjg4IyEAXLhdNGkHjrPBYxk7XlV9xHdyHUSVL6KG4nIw0Xj4CfeC)L41DSND0H7YlmYxigss(ugctwCkmrxVwwKOyImJpBof7s1W9PSiqA3NqTdGCS5Tldxy(FdPLnGyHtrHpqKJXVIrmqTDHGBT)veo2oq6lptc5YIYJxghjAOgqLAfddd55NtH9wTpYhJ)Q7miAROYXMJjC07bNxbvmNfAMDpHJA6Q9eO7VjjjTGumssP8MF7Na0yg5fKHNCVCbqRfffRZ)(ZoJNsQNY2EN27ZS90nt6fNEgFaof4aE2Qz9wuSA5)oqjELihwl(Ab8HjQ38Es3DDLiFf4rXJn3462zwfP5rCGwFbUeueRmiwbfvDmzQ47t5SDGbBvNSlaMqgM54j8rJ)gNG5vtS4WcKsswEH9a)Xq6MutMhsQ2YZ)UxDMyIEcezQRstgZg5X8PYjyqqVQ)E8MPRVkC2m(am4K45xPCU3IWC8zHGf2sDzzunfoES1rQBgN3JPjm2qZwXMifzq8fNI)1gAU9CNKb6tYa3tYGQMKbnAssii6730Md5AwU((XtPkOCwur0uejpmxdtHqCeVFpWGIBammfshGRDo9w8szetAVKi00cbNbMuGzlXSm4zc7ohGDnOorE6j)TOpT7bz65YOcqyW4SntEeHAu52tC3vIwO60yoLd3ywBmLF2eIG77AJ3k6RHRwdWfovfr8b2EjRIErYmlYMcWCXCmTe70eOdVKr4WJH9pU9GtHM7XXUQK7MnIZ1hXr1oIsqe23JOyGhUIXeSGeuG5wVukPEJkacEW3tfyMmJrkFyhj4QWFQgHZO1EfKqMUd6FSsLPsNKlUhwivL(cut1PzRC)eaUzmt7ioWJjsNjWzgd7Acw6dPKShNVkgI)tGEQetuZvd6diZTfznH6S3GHGALh4gxb4ZQUGipy6GcS2E3VrQ3GSS5Q3q9dpdSzGc)MpjKr8lu9J)ri)rWhMoHNaeAvgtPs8b5AJYia5c7qUAAX74n4i36i8xb0VC89f58Le2ocNmTpsT)7Srv(0thvohAyx095M(vdy3Q6IpPZtp1UCYlzSGrittabDADKZKqY9Yh3yTw)1S6BvET3Y3k37KH0s6duQvXqD4h9XImMlcnfbWKq1fUpmEjaOue1xrGPjmZgKxJTKa5s6z1cx0aUIpHjMlEAbxAp7d962bhBKPxafaMMxD5xwwBtY7OZi7nIKoeo25KCMMrDleKGq0ireLthLcCDDrvuI3uC(4W0ioBj3W3Rh0Q9rEkCHNEQQIhHHW5zid0wGItvusQKIMg1HfngjO7wTEyVkXMYySnVh7TDZLf(KmjfrBiIqtQMhLH6Ftql69HdqASwNs3snmRQar0u0puInFVEaUKu9JVQoLe4hvEFg6T5WeiKS(J0GvvWwpqNvcHsTCyyWft5PSPmw3tIkEaB)NWYiVI1rYy2hKViqJtHccDGSPl)0tAxK3HMnVMGsU0vH9uJlAu8m0DStiUNEYrErEL(1ekx(0tQQ4frxrinM3BVvM6FBROYlimlEQ1Xl5FaJ7I(FhCOdsTvnPsbIdaOWpXXy0ZQo92CQgKwLcICE7o5CxZPWd7jQHPyNwoGzxpyuRJStPWNEY(kTmtO0wEssXwTRk1XF9vdco9CnnxSYlCNBQVEat20GVtlbhFD7b9E1Pv1ZUpMPK3PKTVZIwg(4yfeMDRHDycGuifiInPGH64KnuUpXjff1jSDRocyDyyNjQVH9P9cdrqB)EDk8x4ETNDeDX7Ubs(aXdELV9gg)uWRiTmCGYRdg5gw484jN3tBKi7v0XS4z2nPWgXAkeJgJM608XPRasxdliZYiMZkckf92TnwtNoy0PEs04oF3Gl7356AFjhuygJqRJYcJNnocOo6XSHlVx0xb3r2Q9roplQQJ8fFOoazNZP91Xq20Vof2pMn2yE)0tvyiqlFJ3W(6Fl)R2k(WNoOVtDmfSx5cNq6poga6Kk(wVODCl6Z1aE1S0ntehQUBK1AhW(h95f)159Jm4)pJ0klPmfh0tn9JiP1mh4OrTlk1toz0HmGR12CCY1JyB)TDYY0vgLtB(QSpVJsDiN9FehSELdS5lO4p2Duv8ulnvRBaDjfT7GaTVH3u()0bbSfyB)EOOAiN3dvGxp4Ix2TDfltWKIkhgI(YR7rA5wORCiTF(XdpF0L9hOTjCU(W739nTACJdr7RZn9MrcYEjC2nC0OHbYp)1N3hSot81XMua4WZXShoEzR2QbY8oJhEXldoxTkcydJbr(12mqK4db97awe2wk7W03wGbL(U1qgkIYRK4ADS47WmjOSZmBeZOo()GbQVxG3VxWH77XanwQZVXMFiwfjAEVey0H(ON4UbDoxKLiAAc2Od2SErkB446D4L3w5tNeohUJQU2VT34d633J(cDBFE)tPQKRCvIFCqhUckoU51dV802EjHzVQs18pWjH3E3Vkp(rc6tTjsHBg10rdLwaGkvRihpjCrDqOo9TQvp4unFnaQPBWkXmb0BZJCvgbuRMiwfEofLt5TSQaH97wbiCyznBDUlo8Lkq9neRneD73bpfF3f)9aoBZHfvp2hC(IY2S0Ydd8s(bQrBqxOT)yQ3PxL0E9fDCi8Ucn59PD2RVOoD87dYc1f2GbhjnlFmKNbjrm7Dann2rdbQkYcTQxgnJLHa57)p7D12BBCKK(3IqGgWHJed5qslzajcS3ABS3lzV92eCFvHIIYM3sjQJdv0zGa)B)6QQ(LQ7U6EAjBNedSFjX2CEPNU7Q6QEQNQk7MVQJk4ir2mA2ZenVf5H)4mBTwTun1OSZ529q8nUhmqwP79wuuEWr40uYR5QzOZ1fCrIUxdtkdEUFFLmRjVkoDkky)N2(0Yp2PLx)x)VEta2duT4nfIhPXa6)n2W5V4oWE5K5JuNXmD08H41XBbi1QZEgn)u5FRxbIg19omTvsLAK0LWkKZqYuBjQkyhZV1IOPfrsVpdKrCs18DaI4gqhPOdDeC691FkSihLwovoItKuASBdcNoOmTJjTfNAVx067mgtHv8PW195uq(t4RReAwDvds2n6CrGretlr0WbOJNsVOWUFxHQEl4Ik0Lfs2F64QJ8XkuCR8SX6W4JPymX2gi(gaktklKVE3ESWI90sVAaivLBKdHVdZEWoKB4gIix7aW)gXAeqlylwxF2ID0rao8B4u)iGNbPgcSD26)TjEIp((jC0Lt4mFi0XKxQRv9bDBwiArfSzCZ(IaoOGpllposOntwJVq1mTwuOMgytMVqW1qhk)8tCsIpHicZlEvTmIohLcLBNNIYZIP0CK5dyrjAvyl8(gLMJcqr(WBhKhfuezenxo1Bm74vnhfbeQDRNyT2zXC9AJyH1zXCJBL9uDBsCW54moRli12MvQTLtQQqP2myq8BKGz7VFcMcC76BlbtHpGVqcM5FY)tbtrbtYEYoZb)K5b2dFbdh7SNwlyvjrvW3UHUV3VdI49HDMWrDq7g0oWwGvumZXK9M9K27xasiZubkpW5Pru8L75(7oOj0Kym2WbhwC)wT8Wk8FcMFnGSWkY8M(X)bxvk1JlcJudMl99GdlNvxbpPRGhKYi7B1(X5KrLQ9v6ni5kGwxOlq0nJhnXGFvUlpK(k8sye8mQgKMzrs8pIrUO0VCLnHjN45vxw4FF3EWYplH6vcGEKgdM5dQgw8j(yNNF)9kNGCu63alBifYK4PeyM)zN2BPiEyBta3RQkr3l)IeA)ao36CKCGcb3HGM31yE35kenWaN)0Zrc6OioqKs7MC8vl670)mgqRxz3vMaSgIA(K2Ze1ZL8SZXYh8nPfo5BWaEfP9IlJMtw29qo3cZPv3(MLvRJX3qAKnxcLlGyh1CEEXOZLb6Sd2UPeDltgn)0XEM0im7k9UeFCnZdSMQ2B1vszGhHzs9UZPcBbxLvnFFsc63uaPnPLmXF8kIyMuCaU8C9au(sXTW2lTw(W3jJtinXIdZpsWxqQ7EqjyV(UnROZCvkCX3MjqaB38lG(0jZOOhqkbq1dKcaDv6ZWeVLMmlXhdsHcgiCrtMHzNrhDMn9yPVJnMA7nCYoMaaFy5VqdRDFY0gRDv6V8QS1O1CIx2BrNYpG1gWYj6CX0Qiv62z8zv9QeVUsIkcZo1tmVr)e9oKuTGO2e6FAS0sjmVqforGfHB3DnMHt7yOfNywjnsGLHqeOOUe8MSLVvySxy)m12L6mmartGeyNRsm4(dHFuyOrvBPUesiGt1wJe62aUgGTAukQFboWj37sR69HDb8ovQdSg)y(IZZiw30mt9hYuGqDI2DQ06))(61pqNf7A6FGuf(hGHfeQaDxxxZfN)JpUAjwCKq50nXmSXr)nSCut2uBYkgN90GraxVg5ggMQmRdQC1Wv16uleUZtpCHzFXtxStndIjX9Shw5rgDu(ibLITNwknjwnq(UUyQ3zisNvu7wrtkXx98uMiFC6zj43(IlN5FWZwAH9QB3Ugd67vVF7M7uVa1avn(p(4zZxiFcBROMP5KqQy3OKIwSgmvsa1RxkIfvlnrbFcfZr6oy36X6wc6kFo(eTHt4nqEB9J097)l2u0zdYCaDJmFJPv(cp0DoR(rbIm78YUXlZUMp)TKpV1n1kTV5OtzloEsD4SLtxaip)pS6iqrzYNZRTP9MwTG7EG115MuMmX5YzMt7XFZuBMNwPJxBc37sVCWbuxWn4yXFTay6SqO6zTVGECZR1Cds0fu)mz6rIZ4enAfwXSqbCcpygShGBz1BXVJANdyzBg6hgypAfwZDvof0noBYn4EMnPex89118zF1t7U)qisdCFAwCoMtEs5FZWXJARHFm9Yn(HaC9U(u5vVHt58gFy2tqupdPJxLEo98yWHIi1khop6ygae2KVxU1BUL1NILNtkaBt5NT7cfGF8bktMe36as3ZAmPlxNUsC)49hGg)1SSNxtOBWTvusCZ(JY7vQoYzPzaWjL7K0IPf7KeOTnXH8Z6BS6wK0n1yh5Oq6W)EW(iS1PzMYb1QAfQOXTDuM3(PGExeAbfdGLPUvcqB7)ZJGSjDUkKExMFB9)3dB2h5AJFp2vYdNJSrowBaBpTL3F9xt3RFXXIY6LE7gWxqNr93n(P9d6WytrF1e5wkFTuM6sDItKvAW)Xd(jMZLcGZzs0TDhE3j(3iuBYzzPtClFbMSr5QD(Vfgb58FzkfRVHmyjY)t5Y5GX474ITD4YOjm)slGCJpoeBQ2GbtM1izkR6XnSDOayrp(qDTXvZ6JhmPrR57WtQnbWiPZ51QNADNedLb2NkRE(vvdCE(KrG)iFtM4mQYdfq)lRik8LkzmeZTb5usun9DXGbNFQeCBp(aWjZHzN6QRokgy7uzscpnCDzDS4BU6OED9Ow01g4dAY4Eg0EHsZeMkY2SEcfuCAtxxjgrpP(DQvx7729xzoxyoMZ0xQdKAuF1K6F64bqyPGnE5nYHNfjS0GLTPJJqIWX(5mJqkIFj45JHaJ72QCLA1ACH3hl0Et5e(LhhDsrtzAoVwYbN2ahCsg4MSmVkruAFPIZAW3Ml6aR03UYMYZKXmv6Qlm3yygZzbTktKrcKfGTS8xUfO(5YlFfoOUO9vvIBy9ZuwlVr1YBMZRyr6X04v1FtApWdd3JfM9L2I(e3sXWrGC0)ZqT0c(KtSD)Y2xvNGAQPY3v3oRrZd)svp7L7VhF0z)c9s5bxxF0x1MVz76PDQh0HiMysjvENYjy8W7sE5OwFJ4MPcMwhoP1PYWRN852sMkOsN7BdiY7rDG(1MDnLz2LRaRO3vE9AkiaSeULmbMMqWGcaHVnXHdE0TSx7Q8sqWebRv5ZG54Lk5u8DS5SsxaR4hT9wY8x1LU5M1em2(nGqjzUOCtgVY)K26B1Ei07KWtg5k3XsquGnuUZjljAPg)B7PPaDr78er(eowjTtdoQY6oFy9Q97GQkrGTzlAR7jB0F9PdYKm6j5MDA6hvly0MLKvcjZJsXreFyghaH3eipS6j3TaR46j5UsiTVy6yzuDteWq3E0LCDsED3wZzdUFgJCW29udih2Vc6SC1ZcMCRwkLaGkd6H4mQuRsndk()6V65IYRhtsCuRfgb8kc(4qDVOa1bBLgr0ir(WuG1w9efJcmXjyFflI3fzgKoWGdXCGNpJCCOtB1jWWCwwuFe(M)n4RAEFG0e6ByA8LYG5wuNCgR(puXzbQBLEBF13J6N2ZPNLT7VEJBJxCyWX)2)9ADd(cMsOxKBVORxCBXbouWQ)yRzx14cuCY)GRicbQSa85cOTribnGKhw66kz)zhF)z4wN(CI8f)I67btBw9TwTw2d7LuWd7zplGmqYP5c43sQxmZudwBooI2foJmt1JJd2rz6NYUkBIm5I48Mbiw8hGry3LTv7xt)z8xUaOwQ53MwZyfG)B12uy)6(A7XyI5jljo5CxjPLeXMPTD7Z(JucMm6QMxA9)y(46)4pvz2mB7WQ)5ikSe2LgZW)2D8WJA5(Kw6Gv)WaL2o0GBMOfn0vjUwOlJEheUi4Vb)WmVdu8G)vJCF)XutnCUYaAw(ck2SMB3UB3(b6HWv4fpuzn5XTJR1)M94DCm5bxhTPchxhpJMI)p9pnX5ggKa5StTEhIWO(CitnY8wki)4jI6A3ObrCbfj2IUysI(xkEHfGbAkF4MMHxg(Iz(wSlCOwHGXKFtzW0wqY6kUNbNhHnmAmK0LsyVIPv7PdgpQD4GeabF6K6JZ9BTJBM4bWDg6jpz0866gSaSMtbbtGM(KLoDYy5fueODsQAoYJ0vcP6Vl1)(iY)WuB0YwDpnulNLWRMQ6huktIDFAM7EPNNAjOnHlv1zjtOosCw7V823jCFsORZmIisjImfBZ(wpkEwqKtWXd1ESudexTp7GTUk9)L9A9Km9nL3fwX4WdEsIDz6WGBv6Ttlmk1GTf9eeJe73bvGwQ15ebZRugICR9IX7LDSbEeduB39JBOoyYy06TVaZt5spl97JdYJmm0uRnYw)2UXvD8W)ovp(PaAJLHYBUXYqa6cGqEB7aI4zMFyd4)JLjQgb(FgAvaBEy7gtvY5oi1xGxHjyWUgPy4xxEw76fXeZwe9)FyB7Xtox8jAFX)BUTqHaP5k7F42Qosxe8WGRHIYE(y7RPlanN2sBUUD9two6O3VHKTwhI)qcgCGY9NNS)eyNdYdBIDaAwYsxS(siWrzMB0D4YcyhqVOYvkVbuEUi8S(W6LBD47L6cS2Lw)fI9bzUg9GXSdOJbmui3eIb1Iq4aLkT16oViJq(x5UbnjzNn(7NoEqCPdVwdvGU4VozCdY9ooLd0WkqepajLRhhHOLDyljV4Gapp)bOxWeS7XaDih(KHI(eTGEs9K390i(gPMKP0Zr8Err130j4ZxKC7P)u75Rr(700oSmBrx8QPYd)P5saO(qK4FMXn9NXnhe4VPLvFEs0WWrBqZbnGGUqFzaZ(2n3VPZKNoR9suuR1meuKHWF7lw7zerpS3DWrd6pHrxOpTGQR5zt)t)Yi)MOITVZO96s2fLZ82pVup1atrc2jxhGnkyjCc9G9I7nOuucR9plDgIK6roQUM76CEyuSBE7mNMy7Sqy)Za8o7NqbgUP0RFapbKqw0p2l(w0MBJOCFayqPI3lAlw8gISykG1oRkFH(fX9(Lwu6uQpcIIHxeTuUIpD8qz9lAsNByEGPWscRhkdG6mwicLzh1Frn9Ugvx8r04eotgxBtLJ)U27nhDw(aASRpLmPK2J(cqLqUATVpFh0kZ68IhyqOn8PLzyr2oG2RDX9sf1N6vAsUd(p1zOSvo0iGyHMoGVfJdf9oYYmoZYSj19QYHZR(IeP(x01OPiwibbnFyHqiuZqnttQmtKMd3gLRpfOwzi6lS2SIHH49ESRmT7G11jekhm6gW)0MohvDPxEVlP6x0v63Jzvv(JRsEUi93Cvpw1qQ)WopfMzgC8rbRR)B2SM1IykJmknOSGULcyzguxW3Cow)MBxI()NDxI9ASNejmNwx1d5IN06G)37bXL3c1KNjBB)29JQp2e9hKpTxv0N2ZKTT4mWTPjBBs2UzIV(hHmvboMa0N((payNOR)g(XL8WEDHHtIiuzPdhoe)gGnCu7THoQf98N3UXad2nyLXP32N(5bVz9dRPeY7EiWTy0NuQLFlg1lldwSZN1z1UQ8c9k4DjL6wVE8PdAnvItFocJMjDA7WqZORJzuQhOiFVn7i8ByAAmnGpYNu)ZRDlXU2VX)IPwGM0tiZRuJ)1itJfvBTdycX9h0PHxuYJy6tbVx9)(P2Z)0pdTikngjGA))8B6mHF4AOTOTwNWkayDWkHz)Sj8nhC5OL(te(AP0Y)ASH80P(XnRGMfkCGP18Rq4w8xW8OxQTZ3fG9IizuJjnodJgZ(ajAPZnOLCzOkLhdu(l0tgtlw2mLz((lTwAMN85cAlLudaKe34ZaRo0wf8VySQtutYGYaJbl1(Fwv(1cAGcaOuI0UVe6B1dV7lahgp8WM3BDuhDQjnuCPhpr3K4ctHRlFwPaHEZtpuLDXLTeBn8jwuiXrpVV0lWgRi7VsAj3Iibbh6QduGfqykx7U3p369v(8zMKcx0EwHhMMijf4v7mc85Ntcg0DWND2SCbO0XLq7v5LMfbVUbgzpU5a2yn3OS7Z(jq6IWTdnA3A8u5KQb7fE4(Msskbyo97IBEfyuOUEZw1fT2IxWtlnTYAWQeGSy34Zqm)qvPHtaVXoSNksrPYCcT6sUl7XBWBayvWv0kMPhqLamMjJBMpui)rsf6bjLFEDqBxKGyu0)tc0Z)W(nMgbFAdupHjOfyoCEM7twz3lX95kuFD7PPStB48KBylMn)ZsZMFh3d8x78YXlhh(7nCCYve08swFDi6)ZcM02xar7lS0h5J6cdrmcKFQp2tiv4Td63)kGuK9LUZW00S2X3zGXfDHKGw3v(G8cncJ4(Zva8xmx6iEPPHO(GACULEBuRr1ePLyCo5qCEI3QH6YFneRwxHreT8F1J7jfHw9g4dDEtNy9tHoBdhqyL91rjqyKz)kT6)nBKMNfdXWk7AqDFniNUF94i)snEHXDnfwNwHTlx1y5JUdhOZsSSR0IZpcQGw0r5(6B76uZlknnW9sEsbtZ7FCnn)BB244eAMgqOAP(21RqFN0U15blaZYg9qjVNWWNLwP3v4xM9SNiS8lWYHQsuR2WN(BMU4YPJh)YQ6VMTdESCF64HAaIZgvbXitNKxXbmUAPJ1NHfhkmoaGJ0ZSosB4YhUN2ShZsWVLMujYq2chpSmRS2IahCO5RPYr6aBah0Bi9ZrUFXAMZg9(SADSgU5HLmQ8OfqpVrmGgyxmaIQcsWLmkJgKpPVf7l9jnVltTNQhmRl7CD01JyCbeqfaVKEt7F7ngjmv7fvmJ1a5lWszstqR5hk3klIssO3VPnJSmpDHaOAJfAxQCkttvpChP9FCflIk70XtrZYilLJaWWwD4rsZi7uEq5QFDFoomPPN5JsfesgsWEIVh)RgiF)znV)1IU3XrsZyOVG1X6Q9g6IWF5h((39dbJAEkK4sNGK5Fap9dcEsEPfYZ8rLnk6(PrsMJx9iRsK17S854pcJob6NWY0nlqSUCwJ2Ni7aZj693HjWw2G7QZHU40)mE7CORoCt8IYETY0nfQK75AF)CzMuBsYmkHlYNLzVapB8YHnVhFZSXdZv0pQJF)ntn3HrkukeOHnXUKopj9dcrg3qjMuFI5iRtfprggpAwpZwjjCuXiXnzSVF1lcNeh2EAk3PTEcMWHtZO8v8ksZxVQS7lWTxg3wIh8e2(s2ge7F7Zi1ljvt)0EV(aff8emlJ2Dl3dnOWQHGASXuB1aJfvtgR(hWPMXL2lSeKASi00J39pB14qtg9rPSpRmRWS3gm3hMJ6v(xIHzZsU1zf6I52qjBVVO9SX5nc6zaCgTS9w1X93rPY0haNZU7rGv)KRWG5bVFj1QUEaP8owjrhbN7G(nsurcqV4(LpO8W8G2SbF)N72OmjISCcGA0Lv0OpNRwbq6UwFNBHtqHNGAT429lVBDyS7Jc(5FB9(FCTbMXqm9hE(X5uo1Cu0nm4vfKLutRpoPIQgLsU5803QbkH(gT2y427UshGfZduIEEs4w2zcvPFIkGyDSZuK1r7cjhUXCv3HP55akhKrbO)2Hmo1LOnCgQdIOCF4orkyVrPDpAlYdQDQXb3f)jF0uZi4wMaAbcoLDccu2tY6utDvuXDZZB8gU(vAZ5W0241aEi5F6paIANwp8W2rZxC(44Gv98ELE2FwYRe0QDe3KnFu5s6TBsDtNPCCoB9pH0)jvbwMonFhPoUASexXwEjOblNc((NnXsa))IYzMMuzHpDHsfwsBsHG4C9x)b9L(o4pCWGkIPKtyGtMZ4I4SiXz0EboULg7)VcEWuG3F)goEQIi6DrkiatmFb(bmy(PTFXJWrFjZb)7LIIU01zgJ9rn(ICq(BWfqJcb8U7RjP98x5)cxmf(Dyz)7cREdRcpYwS4neKwVPsk3tCQj5HTzdM1QyWBwAZZC9xgCrgeQj2khYgmcf6rMsRVJpyRTeilmtIbS8SHlHablkmsTqLiUtN5NCYlQ)lgOajwIP7Noujm(SoGcAmCPhzQtxey4kdpogFJWNxqjeGE6TTTURWYWZWQmGdq7n7dHIHSDi1wlzgWyn3XKdnYWOK0G4GelpnHC(sfuMlamas6K0zjQCPLbF8zO4NT7uZUT4oznC11H9scToRq5fC2paQK5YLwZu6feiGuWdKlj))pizNq6m1gPJnfm3M9iLff1P1bx3vtqkuaSLG9TwpK1Me(2z9XvcqyCao]] )


end