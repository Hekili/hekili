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

        stellar_drift = 22389, -- 202354
        twin_moons = 21712, -- 279620
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
            s:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
                if not state.covenant.necrolord then return end

                local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

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
            if set_bonus.tier28_2pc > 0 then applyDebuff( "target", "fury_of_elune_ap" ) end
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

            spend = function () return ( buff.oneths_perception.up and 0 or 50 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) * ( set_bonus.tier28_4pc > 0 and 0.8 or 1 ) end,
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

            spend = function () return ( buff.oneths_clear_vision.up and 0 or 30 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) * ( set_bonus.tier28_4pc > 0 and 0.8 or 1 ) end,
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


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20220323, [[dmvqbgqiHWJif0LqOQ2eP0Nuk1OKOoLczvsK8keWSif1TifPDrXVquAykfDmevlJsLNrPktdbQRrk02qOkFdHkghLQY5KikRtIiZdb5Ecr7tHY)KiQQgOerv5GkL0cvOYdrOmrsr0fjfyJiuPpIaPYirGu1jvOkRuPWlLiQYmru0njfb7uPe)KueAOiqCujIkAPiqkpfKMQePUQcv1wLiQ0xrGKXIOWELWFL0GjomvlMu9ybtguxgAZk6ZiYOvQoTkRwIOcVgHmBsUTqTBr)gy4uYXPuvTCPEostxvxxjBheFNsz8iOoVqA9seMVc2pQliVO0fqH9hl2IDBANDBAp7SNXo7zpI3MeNcOFulSaQLhiYjHfqtpglGoox5zalGA5rvahUO0fqPGvhWcO7)BrljYswDx5za1u6fhmKUFFPBoazhNR8mGAk0lMyKng2S)XQs(NNcJu3vEgqZt4VaQ(6u)4Lf6fqH9hl2IDBANDBAp7SNXo7zpnAVcO(63bDbuOxmXkGUFWWywOxafgPHcOJZvEgqw0K96G5n0e8oSZID2tZSy3M2zhVbVbX29KesljEdnLLTcdJWSafO8MLXHESH3qtzHy7EscHz59Me(1BYsWPiLLhWsiAqH13Bs4tn8gAkle0WyaeeMLvMyaPuVJYceVpxxHuwkFg0OzwSAesL(EtxnjKfnDmwSAeIH(EtxnjCKH3qtzzRqahmlwngC6FjjwiOA)3z5MSC)2uw(DKfBnijXIgeuNffn8gAklAcoriledKqaeHS87ilqTU(EklolQ7FfYsmOrwMkKWNUczP8nzjkyXYUdNB)SSFpl3Zc9IxQ3teSOQOSy7(DwgNM4wlnleGfIHkK(NRyzRQJugJ5RzwUFBywOeDwJm8gAklAcorilXa6ZY2ZJ0(xBm2VKUnl0aMEFaklULLkklpGfDaLYY8iT)uwaPkQH3qtzP0n6plLgeJSaMSmoLVZY4u(olJt57S4uwCwOwy4CflFFjr4B4n0uw0eTWeBwkFg0OzwiOA)31mleuT)7AMfOV3ZRXrSe7WilXGgzPr6PomFwEalO3QdBwcGyD)1u679B4n0uwiUhHzPK3LWncZIgeBbSHDmMplHDmqeltqZcX0KSSOoj0uavD0Nwu6cOalmXUO0fBH8IsxaftxxHWfJRaAOVh7ZlGwMfmOolkAuR07AIe(zzyGfmOolkAUSsbkVzzyGfmOolkAUSQd(DwggybdQZIIgpJwtKWplJyrllwncXqUXw7)olAzjcwSAeIXoJT2)9cOE4pqwa1w7)EbuyKg6Z6pqwaLG0yWPpl2Xcbv7)olEcZIZc03B6QjHSaswGwAwSD)olB5iT)SqCDKfpHzzCGTwAwanlqFVNxJSa(DSTDuS4l2IDfLUakMUUcHlgxb0qFp2NxaTmlLzjcw6vItqtcn6UYZawbZQRu1F)ssudMUUcHzzyGLiyjaGGPNVjps7FD6ilddSebluluPQV3KWNAOV3txPyjswiNLHbwIGL3vy(M0)vJ0QUR8mGgmDDfcZYiwggyPmlyqDwu0qbkVRjs4NLHbwWG6SOO5YQALEZYWalyqDwu0Czvh87SmmWcguNffnEgTMiHFwgXYiw0YseSqXVQdYf18h22zFv7Scfq9WFGSak99EEnwavDjwdWfq1yXxSf7vu6cOy66keUyCfqd99yFEb0YS0ReNGMeA0DLNbScMvxPQ)(LKOgmDDfcZIwwcaiy65BYJ0(xNoYIwwOwOsvFVjHp1qFVNUsXsKSqolJyrllrWcf)QoixuZFyBN9vTZkua1d)bYcO03B6QjHfqvxI1aCbunw8fFbuyC6l1xu6ITqErPlG6H)azbukq5Dvh94cOy66keUyCfFXwSRO0fqX01viCX4kGg67X(8cO)fJSqiwkZIDSukw8WFG0yR9F3eC6x)lgzHaS4H)aPH(EpVgnbN(1)IrwgvaL(9f(ITqEbup8hilGgCLQ6H)azvD0VaQ6OFn9ySakWctSl(ITyVIsxaftxxHWfJRakWQakf)cOE4pqwafI3NRRWcOqC1clGsTqLQ(EtcFQH(EpDLILXyHCw0YszwIGL3vy(g67Tc0WgmDDfcZYWalVRW8n0hvkVRW9nFdMUUcHzzelddSqTqLQ(EtcFQH(EpDLILXyXUcOq8UMEmwa9OvhGfqHrAOpR)azbuO4tzzRanGfqYI9ial2UFhSEwG7B(S4jml2UFNfOV3kqdZINWSyhbyb87yB7OyXxSfcUO0fqX01viCX4kGcSkGsXVaQh(dKfqH4956kSakexTWcOuluPQV3KWNAOV3ZRrwgJfYlGcX7A6Xyb0Jwdk0HGfqHrAOpR)azbuO4tzjOqhcYITDmzb6798AKLGNSSFpl2rawEVjHpLfB7xyNLJYsJkeINpltqZYVJSObb1zrrwEal6ilwnoXUryw8eMfB7xyNL5PuyZYdyj40V4l2IglkDbumDDfcxmUcOaRcOu8lG6H)azbuiEFUUclGcXvlSaQvJqQKcWgYnXaqoVgzzyGfRgHujfGnKBORCEnYYWalwncPskaBi3qFVPRMeYYWalwncPskaBi3qFVNUsXYWalwncPskaBi3mxD0kywr1krwggyXQriM2HGjyrRZgZseLLHbw0xZPj41ldMgJ9lPSejl6R50e86Lbd8Q9)ajlddSaX7Z1vO5OvhGfqH4Dn9ySa6Lvsb4cOWin0N1FGSaAjxVpxxHS87(Zsyhderz5MSefSyXBKLlzXzHuaMLhWIdbCWS87il07x(FGKfB7yJS4S89LeHpl4hy5OSSOimlxYIo(2qmzj40Nw8fBH4vu6cOy66keUyCfqd99yFEb0YSuMLiyjaGGPNVjps7FD6ilddSeblbaqbdSLMaiHaicR)owPwxFp1SSyzyGLiyPxjobnj0O7kpdyfmRUsv)9ljrny66keMLrSOLf91CAcE9YGPXy)sklJXc5AKfTSOVMtt7qWeSO1zJzjIAAm2VKYcHyHGzrllrWsaabtpFdem)9OnlddSeaqW0Z3abZFpAZIww0xZPj41ldMLflAzrFnNM2HGjyrRZgZse1SSyrllLzrFnNM2HGjyrRZgZse10ySFjLfcfjlKBhlAklemlLILEL4e0Kqd9Y5sv3JsFSp3GPRRqywggyrFnNMGxVmyAm2VKYcHyHCYzzyGfYzHSSqTqLQU70hzHqSqUH4XYiwgXIwwG4956k0CzLuaUaQh(dKfq1XMInrxsQakmsd9z9hilGo(uKLXHnfBIUKel(ZYVJSGjmlGjle3gZseLfB7yYYUtFKLJYIRdGGSq82K4Rzw85JnledKqaeHSy7(DwghWlnlEcZc43X22rrwSD)oleBRKD8YqXxSfItrPlGIPRRq4IXva1d)bYcOwG)azb0qFp2NxaTml6R50e86LbtJX(LuwgJfY1ilAzPmlrWsVsCcAsOHE5CPQ7rPp2NBW01vimlddSOVMtt7qWeSO1zJzjIAAm2VKYcHyH8sglAzrFnNM2HGjyrRZgZse1SSyzelddSOdOuw0YY8iT)1gJ9lPSqiwStJSmIfTSaX7Z1vO5YkPaCbuyKg6Z6pqwaLGaEwSD)ololeBRKD8Yal)U)SC0C7NfNfcYsr9MfRgeyb0SyBhtw(DKL5rA)z5OS46G1ZYdybt4IVyl2xrPlGIPRRq4IXvafyvaLIFbup8hilGcX7Z1vybuiUAHfqd4PyPmlLzzEK2)AJX(Luw0uwixJSOPSeaafmWwAcE9YGPXy)sklJyHSSqU9TjlJyzmwc4PyPmlLzzEK2)AJX(Luw0uwixJSOPSeaafmWwAcGecGiS(7yLAD99utJX(LuwgXczzHC7BtwgXIwwIGL2p4kcbZ34WWuds4J(uw0YszwIGLaaOGb2stWRxgmn6WrzzyGLiyjaakyGT0eajeary93Xk1667PMgD4OSmILHbwcaGcgylnbVEzW0ySFjLLXy5YhBlGYFeUops7FTXy)sklddS0ReNGMeAcOcP)5Qk1667PgmDDfcZIwwcaGcgylnbVEzW0ySFjLLXyXEBYYWalbaqbdSLMaiHaicR)owPwxFp10ySFjLLXy5YhBlGYFeUops7FTXy)sklAklKVjlddSeblbaem98n5rA)RthlGcX7A6Xyb0aiHaicRWinAgkGcJ0qFw)bYcOeZvHLYFKYITD83XMLf9ssSqmqcbqeYscSXITtPyXvkGnwIcwS8awO)PuSeC6ZYVJSq9yKfpgSYNfWKfIbsiaIqcqSTs2XldSeC6tl(ITuYkkDbumDDfcxmUcOaRcOu8lG6H)azbuiEFUUclGcXvlSaAzwEVjHV5VyS(Gk8HSmglKRrwggyP9dUIqW8nomm1CjlJXIg3KLrSOLLYSuMf0(xNLfcBWyROn6QkOHtpdilAzPmlrWsaabtpFdem)9OnlddSeaafmWwAWyROn6QkOHtpdOPXy)skleIfYjEehwialLzrJSukw6vItqtcn0lNlvDpk9X(CdMUUcHzzelJyrllrWsaauWaBPbJTI2ORQGgo9mGMgD4OSmILHbwq7FDwwiSHcwkf()LKQ9spklAzPmlrWsaabtpFtEK2)60rwggyjaakyGT0qblLc))ss1EPhTApcwJ23MKBAm2VKYcHyHCYjywgXYWalLzjaakyGT0OJnfBIUKKPrhoklddSeblThqZ3aLILHbwcaiy65BYJ0(xNoYYiw0YszwIGL3vy(M5QJwbZkQwjAW01vimlddSeaqW0Z3abZFpAZIwwcaGcgylnZvhTcMvuTs00ySFjLfcXc5KZcbyrJSukw6vItqtcn0lNlvDpk9X(CdMUUcHzzyGLiyjaGGPNVbcM)E0MfTSeaafmWwAMRoAfmROALOPXy)skleIf91CAcE9YGbE1(FGKfcWc52XsPyPxjobnj0y1xmOHpxv9o45fQwlf1BdMUUcHzrtzHC7yzelAzPmlO9Volle2Cjn0R31vy1(xE(R4kmc5cilAzjaakyGT0Cjn0R31vy1(xE(R4kmc5cOPXy)skleIfnYYiwggyPmlLzbT)1zzHWg6UddSHWvqRxbZ6d6ymFw0YsaauWaBP5bDmMpcxVKEK2)Q90OgTNDKBAm2VKYYiwggyPmlLzbI3NRRqdiRlkw)(sIWNLizHCwggybI3NRRqdiRlkw)(sIWNLizXESmIfTSuMLVVKi8np5MgD4O1aaOGb2swggy57ljcFZtUjaakyGT00ySFjLLXy5YhBlGYFeUops7FTXy)sklAklKVjlJyzyGfiEFUUcnGSUOy97ljcFwIKf7yrllLz57ljcFZBNPrhoAnaakyGTKLHbw((sIW382zcaGcgylnng7xszzmwU8X2cO8hHRZJ0(xBm2VKYIMYc5BYYiwggybI3NRRqdiRlkw)(sIWNLizztwgXYiwgvafI310JXcOb4AaKW3FGSakmsd9z9hilGo(ueMLhWcmQ8OS87illQtczbmzHyBLSJxgyX2oMSSOxsIfyWsxHSaswwuKfpHzXQriy(SSOojKfB7yYINS4WWSGqW8z5OS46G1ZYdyb(WIVylKVzrPlGIPRRq4IXvafyvaLIFbup8hilGcX7Z1vybuiUAHfqJGfkyP0Ve2879PuvkIeHTbtxxHWSmmWY8iT)1gJ9lPSmgl2T5MSmmWIoGszrllZJ0(xBm2VKYcHyXonYcbyPmle8MSOPSOVMtZV3NsvPise2g67bIyPuSyhlJyzyGf91CA(9(uQkfrIW2qFpqelJXI9Spw0uwkZsVsCcAsOHE5CPQ7rPp2NBW01vimlLIf7yzubuiExtpglG(79PuvkIeHD1MFFbuyKg6Z6pqwaTKR3NRRqwwueMLhWcmQ8OS4zuw((sIWNYINWSeGPSyBhtwS53FjjwMGMfpzrdww7G(CwSAqO4l2c5Kxu6cOy66keUyCfqtpglGIXwrB0vvqdNEgWcOWin0N1FGSa64trw0GyROn6kw0eB40ZaYIDBsXaLfDCcAKfNfITvYoEzGLffzb0SqbS87(ZY9Sy7ukwuxISSSyX297S87ilycZcyYcXTXSerlGg67X(8cObaqbdSLMGxVmyAm2VKYcHyXUnzrllbaqbdSLMaiHaicR)owPwxFp10ySFjLfcXIDBYIwwkZceVpxxHMFVpLQsrKiSR287zzyGf91CA(9(uQkfrIW2qFpqelJXI92KfcWszw6vItqtcn0lNlvDpk9X(CdMUUcHzPuSypwgXYiw0YceVpxxHMlRKcWSmmWIoGszrllZJ0(xBm2VKYcHyXEeNcOE4pqwafJTI2ORQGgo9mGfFXwi3UIsxaftxxHWfJRaA6XybukyPu4)xsQ2l9OfqHrAOpR)azb0XNISafSuk8VKele0w6rzH4rXaLfDCcAKfNfITvYoEzGLffzb0SqbS87(ZY9Sy7ukwuxISSSyX297S87ilycZcyYcXTXSerlGg67X(8cOLzjaakyGT0e86LbtJX(Luwielepw0YseSeaqW0Z3abZFpAZIwwIGLaacME(M8iT)1PJSmmWsaabtpFtEK2)60rw0YsaauWaBPjasiaIW6VJvQ113tnng7xszHqSq8yrllLzbI3NRRqtaKqaeHvyKgndSmmWsaauWaBPj41ldMgJ9lPSqiwiESmILHbwcaiy65BGG5VhTzrllLzjcw6vItqtcn0lNlvDpk9X(CdMUUcHzrllbaqbdSLMGxVmyAm2VKYcHyH4XYWal6R500oemblAD2ywIOMgJ9lPSqiwiFtwialLzrJSukwq7FDwwiS5s63RWdAAf(GCjw1rLILrSOLf91CAAhcMGfToBmlruZYILrSmmWIoGszrllZJ0(xBm2VKYcHyXonYYWalO9Volle2GXwrB0vvqdNEgqw0YsaauWaBPbJTI2ORQGgo9mGMgJ9lPSmgl2TjlJyrllq8(CDfAUSskaZIwwIGf0(xNLfcBUKg6176kSA)lp)vCfgHCbKLHbwcaGcgylnxsd96DDfwT)LN)kUcJqUaAAm2VKYYySy3MSmmWIoGszrllZJ0(xBm2VKYcHyXUnlG6H)azbukyPu4)xsQ2l9OfFXwi3EfLUakMUUcHlgxbuGvbuk(fq9WFGSakeVpxxHfqH4QfwavFnNMGxVmyAm2VKYYySqUgzrllLzjcw6vItqtcn0lNlvDpk9X(CdMUUcHzzyGf91CAAhcMGfToBmlrutJX(LuwiuKSqUgnAKfcWszwSNrJSukw0xZPrxbaWQf9nllwgXcbyPmleSrJSOPSypJgzPuSOVMtJUcaGvl6BwwSmILsXcA)RZYcHnxs)EfEqtRWhKlXQoQuSqawiyJgzPuSuMf0(xNLfcB(DSoVM(v6r6uSOLLaaOGb2sZVJ1510VspsNY0ySFjLfcfjl2TjlJyrll6R500oemblAD2ywIOMLflJyzyGfDaLYIwwMhP9V2ySFjLfcXIDAKLHbwq7FDwwiSbJTI2ORQGgo9mGSOLLaaOGb2sdgBfTrxvbnC6zanng7xslGcX7A6Xyb0Z(HRbqcF)bYcOWin0N1FGSa6wv28OuwwuKLXRKtnjl2UFNfITvYoEzGfqZI)S87ilycZcyYcXTXSerl(ITqobxu6cOy66keUyCfqtpglGEjn0R31vy1(xE(R4kmc5cybup8hilGEjn0R31vy1(xE(R4kmc5cyb0qFp2NxafI3NRRqZz)W1aiHV)ajlAzbI3NRRqZLvsb4IVylKRXIsxaftxxHWfJRaA6Xybu6UddSHWvqRxbZ6d6ym)cOWin0N1FGSa64trwGU7WaBimlAITol64e0ileBRKD8Yqb0qFp2NxaTmlbaqbdSLMGxVmyA0HJYIwwIGLaacME(M8iT)1PJSOLfiEFUUcn)EFkvLIiryxT53ZIwwkZsaauWaBPrhBk2eDjjtJoCuwggyjcwApGMVbkflJyzyGLaacME(M8iT)1PJSOLLaaOGb2staKqaeH1FhRuRRVNAA0HJYIwwkZceVpxxHMaiHaicRWinAgyzyGLaaOGb2stWRxgmn6WrzzelJyrllWG3qx58A08xGOljXIwwkZcm4n0hvkVRtL3O5VarxsILHbwIGL3vy(g6JkL31PYB0GPRRqywggyHAHkv99Me(ud99EEnYYySypwgXIwwGbVjgaY51O5VarxsIfTSuMfiEFUUcnhT6aKLHbw6vItqtcn6UYZawbZQRu1F)ssudMUUcHzzyGfN(TRQwaByZYyrYsjBtwggybI3NRRqtaKqaeHvyKgndSmmWI(Aon6kaawTOVzzXYiw0YseSG2)6SSqyZL0qVExxHv7F55VIRWiKlGSmmWcA)RZYcHnxsd96DDfwT)LN)kUcJqUaYIwwcaGcgylnxsd96DDfwT)LN)kUcJqUaAAm2VKYYySyVnzrllrWI(AonbVEzWSSyzyGfDaLYIwwMhP9V2ySFjLfcXcbVzbup8hilGs3DyGneUcA9kywFqhJ5x8fBHCIxrPlGIPRRq4IXvan03J95fqH4956k0aY6II1VVKi8zjIizHCw0YseS89LeHV5TZ0OdhTgaafmWwYYWalLzbI3NRRqdiRlkw)(sIWNLizHCwggybI3NRRqdiRlkw)(sIWNLizXESmIfTSuMf91CAcE9YGzzXIwwcaiy65BGG5VhTzrllLzrFnNM2HGjyrRZgZse10ySFjLfcWszwSNrJSukw6vItqtcn0lNlvDpk9X(CdMUUcHzzeleksw((sIW38KB0xZzfE1(FGKfTSOVMtt7qWeSO1zJzjIAwwSmmWI(AonTdbtWIwNnMLiALE5CPQ7rPp2NBwwSmILHbwcaGcgylnbVEzW0ySFjLfcWIDSmglFFjr4BEYnbaqbdSLg4v7)bsw0YszwIGLEL4e0KqJvFXGg(Cv17GNxOATuuVny66keMLHbw0xZPj41ldMgJ9lPSmglepwgXIwwkZseSeaqW0Z3KhP9VoDKLHbw((sIW38KBcaGcgylnWR2)dKSmglbaqbdSLMaiHaicR)owPwxFp10ySFjLLHbwG4956k0eajearyfgPrZalAz57ljcFZtUjaakyGT0aVA)pqYYySeaafmWwAcE9YGPXy)sklJyrllrWsaabtpFdrr7ZtwggyjaGGPNVjps7FD6ilAzbI3NRRqtaKqaeHvyKgndSOLLaaOGb2staKqaeH1FhRuRRVNAwwSOLLiyjaakyGT0e86LbZYIfTSuMLYSOVMtdguNffRQv6TPXy)sklJXIgzzyGf91CAWG6SOyLcuEBAm2VKYYySOrwgXYiwggyrFnNgIUeUr4kgBbSHDmMFftSjDLanllwgXYWalZJ0(xBm2VKYcHyXUnzzyGfiEFUUcnGSUOy97ljcFwIKLnlGcJ0qFw)bYcOLE)OSCuwCwA)3XMfu56G2FKfBEuwEalXorilUsXcizzrrwOV)S89LeHpLLhWIoYI6seMLLfl2UFNfITvYoEzGfpHzHyGecGiKfpHzzrrw(DKf7sywOkWZcizjaZYnzrh87S89LeHpLfVrwajllkYc99NLVVKi8PfqPkWtlG(9LeHp5fq9WFGSa63xse(Kx8fBHCItrPlGIPRRq4IXvaLQapTa63xse(2va1d)bYcOFFjr4Bxb0qFp2NxafI3NRRqdiRlkw)(sIWNLiIKf7yrllrWY3xse(MNCtJoC0AaauWaBjlddSaX7Z1vObK1ffRFFjr4ZsKSyhlAzPml6R50e86LbZYIfTSeaqW0Z3abZFpAZIwwkZI(AonTdbtWIwNnMLiQPXy)skleGLYSypJgzPuS0ReNGMeAOxoxQ6Eu6J95gmDDfcZYiwiuKS89LeHV5TZOVMZk8Q9)ajlAzrFnNM2HGjyrRZgZse1SSyzyGf91CAAhcMGfToBmlr0k9Y5sv3JsFSp3SSyzelddSeaafmWwAcE9YGPXy)skleGf7yzmw((sIW382zcaGcgylnWR2)dKSOLLYSebl9kXjOjHgR(Ibn85QQ3bpVq1APOEBW01vimlddSOVMttWRxgmng7xszzmwiESmIfTSuMLiyjaGGPNVjps7FD6ilddS89LeHV5TZeaafmWwAGxT)hizzmwcaGcgylnbqcbqew)DSsTU(EQPXy)sklddSaX7Z1vOjasiaIWkmsJMbw0YY3xse(M3otaauWaBPbE1(FGKLXyjaakyGT0e86LbtJX(LuwgXIwwIGLaacME(gII2NNSOLLYSebl6R50e86LbZYILHbwIGLaacME(giy(7rBwgXYWalbaem98n5rA)Rthzrllq8(CDfAcGecGiScJ0OzGfTSeaafmWwAcGecGiS(7yLAD99uZYIfTSeblbaqbdSLMGxVmywwSOLLYSuMf91CAWG6SOyvTsVnng7xszzmw0ilddSOVMtdguNffRuGYBtJX(LuwgJfnYYiwgXYiwggyrFnNgIUeUr4kgBbSHDmMFftSjDLanllwggyzEK2)AJX(Luwiel2TjlddSaX7Z1vObK1ffRFFjr4ZsKSSzXxSfYTVIsxaftxxHWfJRakmsd9z9hilGo(uKYIRuSa(DSzbKSSOil3JXuwajlb4cOE4pqwaDrX69ymT4l2c5LSIsxaftxxHWfJRakmsd9z9hilGQb3VJnlKaSC5dy53rwOplGMfhGS4H)ajlQJ(fq9WFGSaAVYQh(dKv1r)cO0VVWxSfYlGg67X(8cOq8(CDfAoA1bybu1r)A6XybuhGfFXwSBZIsxaftxxHWfJRaQh(dKfq7vw9WFGSQo6xavD0VMEmwaL(fFXxa1QXaiw3)IsxSfYlkDbup8hilGs0LWncxPwxFpTakMUUcHlgxXxSf7kkDbumDDfcxmUcOaRcOu8lG6H)azbuiEFUUclGcXvlSa6MfqH4Dn9ySakiRlkw)(sIWVakmsd9z9hilGw6DKfiEFUUcz5OSqXNLhWYMSy7(Dwsal03FwajllkYY3xse(unZc5SyBhtw(DKL510NfqISCuwajllkQzwSJLBYYVJSqXaiHz5OS4jml2JLBYIo43zXBS4l2I9kkDbumDDfcxmUcOaRcOomCbup8hilGcX7Z1vybuiUAHfqjVakeVRPhJfqbzDrX63xse(fqd99yFEb0VVKi8np5MDNwxuSQVMtw0YY3xse(MNCtaauWaBPbE1(FGKfTSeblFFjr4BEYnh18GyScM1yqs)gSO1aiPFVc)bsAXxSfcUO0fqX01viCX4kGcSkG6WWfq9WFGSakeVpxxHfqH4Qfwa1UcOq8UMEmwafK1ffRFFjr4xan03J95fq)(sIW382z2DADrXQ(AozrllFFjr4BE7mbaqbdSLg4v7)bsw0YseS89LeHV5TZCuZdIXkywJbj9BWIwdGK(9k8hiPfFXw0yrPlGIPRRq4IXvafyva1HHlG6H)azbuiEFUUclGcX7A6XybuqwxuS(9LeHFbuiUAHfqj4cOWin0N1FGSaAP3rkYY3xse(uw8gzjbpl(6bX(FbxPIYcm(y4rywCklGKLffzH((ZY3xse(udlSafFwG4956kKLhWcbZItz53XOS4kkGLerywOwy4Cfl7EcRUKKPaAOVh7ZlGI2)6SSqyZL0qVExxHv7F55VIRWiKlGSmmWcA)RZYcHnySv0gDvf0WPNbKLHbwq7FDwwiSHcwkf()LKQ9spAXxSfIxrPlGIPRRq4IXvafyvaLIFbup8hilGcX7Z1vybuiUAHfqT3MSukwkZc5SOPSSPHCnYsPyHIFvhKlQ5pSTZ(QeSvGLrfqH4Dn9ySakLwda6xafgPH(S(dKfqHIpLLFhzb67nD1Kqwca6ZYe0SO8hBwcUkSu(FGKYs5jOzbjShBPqwSTJjlpGf679Zc8k26ssSOJtqJSqCBmlruwMUsrzbmNJk(ITqCkkDbumDDfcxmUcOaRcOu8lG6H)azbuiEFUUclGcXvlSaQg3KLsXszwiNfnLLnnKRrwkflu8R6GCrn)HTD2xLGTcSmQakeVRPhJfqPZAaq)IVyl2xrPlGIPRRq4IXvafyvaLIFbup8hilGcX7Z1vybuiUAHfqT3MSqawiFtwkfl9kXjOjHMaQq6FUQsTU(EQbtxxHWfqH4Dn9ySaAaKqaeHvNAvafgPH(S(dKfqHIpLf)zX2(f2zXJbR8zbmzzRuccledKqaeHSq3blfml6illkcxsSqWBYIT73bRNfIHkK(NRybQ113tzXtywS3MSy7(DtXxSLswrPlG6H)azb0yaij6Y6e0XfqX01viCX4k(ITq(MfLUakMUUcHlgxb0qFp2NxaTmlyqDwu0OwP31ej8ZYWalyqDwu0CzLcuEZYWalyqDwu0Czvh87SmmWcguNffnEgTMiHFwgva1d)bYcO2A)3lGQUeRb4cOKVzXx8fqDawu6ITqErPlGIPRRq4IXvafyvaLIFbup8hilGcX7Z1vybuiUAHfq7vItqtcn)fJ2aDwHB0J1VegBdMUUcHzrllLzrFnNM)IrBGoRWn6X6xcJTPXy)skleIfsbytStywialBAiNLHbw0xZP5Vy0gOZkCJES(LWyBAm2VKYcHyXd)bsd99EEnAqcJH1J1)IrwialBAiNfTSuMfmOolkAUSQwP3SmmWcguNffnuGY7AIe(zzyGfmOolkA8mAnrc)SmILrSOLf91CA(lgTb6Sc3OhRFjm2MLvbuiExtpglGc3OhxTDkvD6kvfmNfqHrAOpR)azbuI5QWs5pszX2o(7yZYVJSOjB0Jd(h2XMf91CYITtPyz6kflG5KfB3VFjl)oYsIe(zj40V4l2IDfLUakMUUcHlgxbuGvbuk(fq9WFGSakeVpxxHfqH4QfwancwWG6SOO5YkfO8MfTSqTqLQ(EtcFQH(EpVgzzmwioSOPS8UcZ3qblvfmR)owNGgPVbtxxHWSukwSJfcWcguNffnxw1b)olAzjcw6vItqtcnw9fdA4ZvvVdEEHQ1sr92GPRRqyw0YseS0ReNGMeAaj(70AqHExHC0dKgmDDfcxafI310JXcOhPe0yL(EtxnjSakmsd9z9hilGsmxfwk)rkl22XFhBwG(EtxnjKLJYInq)7SeC6FjjwaqWMfOV3ZRrwUKfYCLEZIgeuNffl(ITyVIsxaftxxHWfJRaAOVh7ZlGgblW96GnjOgGPSOLLYSuMfiEFUUcnbqcbqewHrA0mWIwwIGLaaOGb2stWRxgmn6WrzrllrWsVsCcAsOXQVyqdFUQ6DWZluTwkQ3gmDDfcZYWal6R50e86LbZYIfTSuMLiyPxjobnj0y1xmOHpxv9o45fQwlf1BdMUUcHzzyGLEL4e0Kqtavi9pxvPwxFp1GPRRqywggyzEK2)AJX(LuwgJfYTJ4WYWal6akLfTSmps7FTXy)skleILaaOGb2stWRxgmng7xszHaSq(MSmmWI(AonbVEzW0ySFjLLXyHC7yzelJyrllLzPmlLzXPF7QQfWg2SqOizbI3NRRqtaKqaeHvNAXYWaluluPQV3KWNAOV3ZRrwgJf7XYiw0Yszw0xZPbdQZIIv1k920ySFjLLXyH8nzzyGf91CAWG6SOyLcuEBAm2VKYYySq(MSmILHbw0xZPj41ldMgJ9lPSmglAKfTSOVMttWRxgmng7xszHqrYc52XYiw0YszwIGL3vy(g6JkL3v4(MVbtxxHWSmmWI(Aon037PRuMgJ9lPSqiwi3Orw0uw20Orwkfl9kXjOjHMaQq6FUQsTU(EQbtxxHWSmmWI(AonbVEzW0ySFjLfcXI(Aon037PRuMgJ9lPSqaw0ilAzrFnNMGxVmywwSmIfTSuMLiyPxjobnj08xmAd0zfUrpw)sySny66keMLHbwIGLEL4e0Kqtavi9pxvPwxFp1GPRRqywggyrFnNM)IrBGoRWn6X6xcJTPXy)sklJXcsymSES(xmYYiwggyPxjobnj0O7kpdyfmRUsv)9ljrny66keMLrSOLLYSebl9kXjOjHgDx5zaRGz1vQ6VFjjQbtxxHWSmmWszw0xZPr3vEgWkywDLQ(7xsIwt)xnAOVhiILizX(yzyGf91CA0DLNbScMvxPQ)(LKOvVdEIg67bIyjswSpwgXYiwggyrhqPSOLL5rA)Rng7xszHqSq(MSOLLiyjaakyGT0e86LbtJoCuwgva1d)bYcObqcbqew)DSsTU(EAbuyKg6Z6pqwaD8PiledKqaeHSyBhtw8NffsPS87EYIg3KLTsjiS4jmlQlrwwwSy7(Dwi2wj74LHIVyleCrPlGIPRRq4IXva1d)bYcO0voVglGgIguy99Me(0ITqEbuyKg6Z6pqwaD8Pilqx58AKLlzXYtym(cSasw8m6VFjjw(D)zrDqqklKtWumqzXtywuiLYIT73zjg0ilV3KWNYINWS4pl)oYcMWSaMS4SafO8MfniOolkYI)SqobZcfduwanlkKszPXy)YljXItz5bSKGNLDhYLKy5bS04Sr6olWR(ssSqMR0Bw0GG6SOyb0qFp2NxaTmlnoBKU76kKLHbw0xZPbdQZIIvkq5TPXy)skleIf7XIwwWG6SOO5YkfO8MfTS0ySFjLfcXc5emlAz5DfMVHcwQkyw)DSobnsFdMUUcHzzelAz59Me(M)IX6dQWhYYySqobZIMYc1cvQ67nj8PSqawAm2VKYIwwkZcguNffnxw9mklddS0ySFjLfcXcPaSj2jmlJk(ITOXIsxaftxxHWfJRaAOVh7ZlGcX7Z1vO5SF4AaKW3FGKfTSeaafmWwAUKg6176kSA)lp)vCfgHCb00OdhLfTSG2)6SSqyZL0qVExxHv7F55VIRWiKlGSOLf3Qg2Xarfq9WFGSakDLZRXcOWin0N1FGSa64trwGUY51ilpGLDhcYIZcjfq3vS8awwuKLXRKtnzXxSfIxrPlGIPRRq4IXvan03J95fqJGL3vy(g6JkL3v4(MVbtxxHWSOLLYSeblu8R6GCrn)HTD2xLGTcSmmWcguNffnxw9mklddSqTqLQ(EtcFQH(EpDLILXyXESmIfTSuMf91CAOV3txPmnoBKU76kKfTSuMfQfQu13Bs4tn037PRuSqiwShlddSebl9kXjOjHM)IrBGoRWn6X6xcJTbtxxHWSmILHbwExH5BOGLQcM1FhRtqJ03GPRRqyw0YI(AonyqDwuSsbkVnng7xszHqSypw0YcguNffnxwPaL3SOLf91CAOV3txPmng7xszHqSqCyrlluluPQV3KWNAOV3txPyzSizHGzzelAzPmlrWsVsCcAsOrfn4TtRtfI)LKQKuxSffny66keMLHbw(lgzH4ZcbRrwgJf91CAOV3txPmng7xszHaSyhlJyrllV3KW38xmwFqf(qwgJfnwa1d)bYcO037PRufqHrAOpR)azb0sEiAXYYIfOV3txPyXFwCLIL)IrklRuHukll6LKyHmJg82PS4jml3ZYrzX1bRNLhWIvdcSaAwu4ZYVJSqTWW5kw8WFGKf1Lil6OcyJLDpHvilAYg9y9lHXMfqYIDS8EtcFAXxSfItrPlGIPRRq4IXvan03J95fqFxH5BOpQuExH7B(gmDDfcZIww0xZPH(EpDLY04Sr6URRqw0YszwIGfk(vDqUOM)W2o7RsWwbwggybdQZIIMlREgLLHbwOwOsvFVjHp1qFVNUsXYySqWSmIfTSuMLiyPxjobnj0OIg82P1PcX)ssvsQl2IIgmDDfcZYWal)fJSq8zHG1ilJXcbZYiw0YY7nj8n)fJ1huHpKLXyXEfq9WFGSak99E6kvbuyKg6Z6pqwaLG6(DwG(Os5nlAY(MpllkYcizjaZITDmzPXzJ0DxxHSOVEwO)PuSyZVNLjOzHmJg82PSy1GalEcZcmi3(zzrrw0XjOrwiMMKAyb6FkfllkYIoobnYcXajearil0ldil)U)Sy7ukwSAqGfpb)o2Sa99E6kvXxSf7RO0fqX01viCX4kGg67X(8cO9kXjOjHM)IrBGoRWn6X6xcJTbtxxHWSOLfQfQu13Bs4tn037PRuSmwKSypw0YszwIGf91CA(lgTb6Sc3OhRFjm2MLflAzrFnNg6790vktJZgP7UUczzyGLYSaX7Z1vObUrpUA7uQ60vQkyozrllLzrFnNg6790vktJX(Luwiel2JLHbwOwOsvFVjHp1qFVNUsXYySyhlAz5DfMVH(Os5DfUV5BW01vimlAzrFnNg6790vktJX(LuwielAKLrSmILrfq9WFGSak99E6kvbuyKg6Z6pqwaLG6(Dw0Kn6X6xcJnllkYc037PRuS8awicrlwwwS87il6R5Kf9OS4kkGLf9ssSa99E6kflGKfnYcfdGeMYcOzrHuklng7xEjPIVylLSIsxaftxxHWfJRakWQakf)cOE4pqwafI3NRRWcOqC1clG60VDv1cydBwgJf7BtwkflLzHCw0uwO4x1b5IA(dB7SVQDwbwkflBASJLrSukwkZc5SOPSOVMtZFXOnqNv4g9y9lHX2qFpqelLILnnKZYiw0uwkZI(Aon037PRuMgJ9lPSukwShlKLfQfQu1DN(ilLILiy5DfMVH(Os5DfUV5BW01vimlJyrtzPmlbaqbdSLg6790vktJX(Luwkfl2JfYYc1cvQ6UtFKLsXY7kmFd9rLY7kCFZ3GPRRqywgXIMYszw0xZPzU6OvWSIQvIMgJ9lPSukw0ilJyrllLzrFnNg6790vkZYILHbwcaGcgyln037PRuMgJ9lPSmQakeVRPhJfqPV3txPQ2a5xNUsvbZzbuyKg6Z6pqwaLyUkSu(JuwSTJ)o2S4Sa99MUAsillkYITtPyj4lkYc037PRuS8awMUsXcyo1mlEcZYIISa99MUAsilpGfIq0IfnzJES(LWyZc99arSSSmSyFBYYrz53rwA0(xxJWSSvkbHLhWsWPplqFVPRMesaOV3txPk(ITq(MfLUakMUUcHlgxb0qFp2NxafI3NRRqdCJEC12Pu1PRuvWCYIwwG4956k0qFVNUsvTbYVoDLQcMtw0YseSaX7Z1vO5iLGgR03B6QjHSmmWszw0xZPr3vEgWkywDLQ(7xsIwt)xnAOVhiILXyXESmmWI(Aon6UYZawbZQRu1F)ss0Q3bprd99arSmgl2JLrSOLfQfQu13Bs4tn037PRuSqiwiyw0YceVpxxHg6790vQQnq(1PRuvWCwa1d)bYcO03B6QjHfqHrAOpR)azb0XNISa99MUAsil2UFNfnzJES(LWyZYdyHieTyzzXYVJSOVMtwSD)oy9SOa0ljXc037PRuSSS(lgzXtywwuKfOV30vtczbKSqWeGLXb2APzH(EGiklR8pflemlV3KWNw8fBHCYlkDbumDDfcxmUcOE4pqwa1HDR)GGvQnVJlGgIguy99Me(0ITqEbuyKg6Z6pqwaD8PiluBEhZcfWYV7plrblwiHplXoHzzz9xmYIEuww0ljXY9S4uwu(JS4uwSau6PRqwajlkKsz539Kf7Xc99aruwanlLCSOpl22XKf7rawOVhiIYcsyRRXcOH(ESpVaAeS8xGOljXIwwIGfp8hinoSB9heSsT5DCf2JDsO5Y6uDK2Fwggybg8gh2T(dcwP28oUc7Xoj0qFpqeleIf7XIwwGbVXHDR)GGvQnVJRWEStcnng7xszHqSyVIVylKBxrPlGIPRRq4IXva1d)bYcOXaqoVglGgIguy99Me(0ITqEbuyKg6Z6pqwaLGgoBKUZIMaaKZRrwUjleBRKD8YalhLLgD4OAMLFhBKfVrwuiLYYV7jlAKL3Bs4tz5swiZv6nlAqqDwuKfB3VZcuWtC1mlkKsz539KfY3KfWVJTTJISCjlEgLfniOolkYcOzzzXYdyrJS8EtcFkl64e0ilolK5k9MfniOolkAyrtcYTFwAC2iDNf4vFjjwk5DjCJWSObXwaByhJ5ZYkviLYYLSafO8MfniOolkwan03J95fqBC2iD31vilAz59Me(M)IX6dQWhYYySuMLYSqobZcbyPmluluPQV3KWNAOV3ZRrwkfl2XsPyrFnNgmOolkwvR0BZYILrSmIfcWsJX(LuwgXczzPmlKZcby5DfMV5TDzngasQbtxxHWSmIfTS40VDv1cydBwgJfiEFUUcn0znaOplAkl6R50qFVNUszAm2VKYsPyH4XIwwkZIBvd7yGiwggybI3NRRqZrkbnwPV30vtczzyGLiybdQZIIMlREgLLrSOLLYSeaafmWwAcE9YGPrhoklAzbdQZIIMlREgLfTSeblW96GnjOgGPSOLLYSaX7Z1vOjasiaIWkmsJMbwggyjaakyGT0eajeary93Xk1667PMgD4OSmmWseSeaqW0Z3KhP9VoDKLrSmmWc1cvQ67nj8Pg6798AKfcXszwkZI9XIMYszw0xZPbdQZIIv1k92SSyPuSypwgXYiwkflLzHCwialVRW8nVTlRXaqsny66keMLrSmIfTSeblyqDwu0qbkVRjs4NfTSuMLiyjaakyGT0e86LbtJoCuwggybUxhSjb1amLLrSmmWszwWG6SOO5YkfO8MLHbw0xZPbdQZIIv1k92SSyrllrWY7kmFdfSuvWS(7yDcAK(gmDDfcZYiw0YszwOwOsvFVjHp1qFVNxJSqiwiFtwkflLzHCwialVRW8nVTlRXaqsny66keMLrSmILrSOLLYSeblbaem98nefTppzzyGLiyrFnNgIUeUr4kgBbSHDmMFftSjDLanllwggybdQZIIMlRuGYBwgXIwwIGf91CAAhcMGfToBmlr0k9Y5sv3JsFSp3SSk(ITqU9kkDbumDDfcxmUcOH(ESpVaQBvd7yGiwggybI3NRRqZrkbnwPV30vtclG6H)azb0jOdyfmRP)RglGcJ0qFw)bYcOJpfzH4c2clGKLaml2UFhSEwcUL1LKk(ITqobxu6cOy66keUyCfqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0iybUxhSjb1amLfTSuMfiEFUUcnb4AaKW3FGKfTSuMf91CAOV3txPmllwggy5DfMVH(Os5DfUV5BW01vimlddSeaqW0Z3KhP9VoDKLrSOLfyWBIbGCEnA(lq0LKyrllLzjcw0xZPHcu0)cOzzXIwwIGf91CAcE9YGzzXIwwkZseS8UcZ3mxD0kywr1krdMUUcHzzyGf91CAcE9YGbE1(FGKLXyjaakyGT0mxD0kywr1krtJX(Luwial2hlJyrllLzjcwO4x1b5IA(dB7SVQDwbwggybdQZIIMlRQv6nlddSGb1zrrdfO8UMiHFwgXIwwG4956k0879PuvkIeHD1MFplAzPmlrWsaabtpFtEK2)60rwggybI3NRRqtaKqaeHvyKgndSmmWsaauWaBPjasiaIW6VJvQ113tnng7xszHqSqUgzzelAz59Me(M)IX6dQWhYYySOVMttWRxgmWR2)dKSukw20qCyzelddSOdOuw0YY8iT)1gJ9lPSqiw0xZPj41ldg4v7)bswialKBhlLILEL4e0KqJvFXGg(Cv17GNxOATuuVny66keMLrfqH4Dn9ySaAaUgaj89hiRoal(ITqUglkDbumDDfcxmUcOH(ESpVaQ(AonbVEzW0ySFjLLXyHCnYYWal6R50e86Lbd8Q9)ajleGfYTJLsXsVsCcAsOXQVyqdFUQ6DWZluTwkQ3gmDDfcZcHyXoIhlAzbI3NRRqtaUgaj89hiRoalG6H)azb02HGjyrRZgZseTakmsd9z9hilGo(uKfIBJzjIYIT73zHyBLSJxgk(ITqoXRO0fqX01viCX4kGg67X(8cOq8(CDfAcW1aiHV)az1bilAzPmlrWsaabtpFdem)9OnlddSebl9kXjOjHg6LZLQUhL(yFUbtxxHWSmmWsVsCcAsOXQVyqdFUQ6DWZluTwkQ3gmDDfcZYWal6R50e86Lbd8Q9)ajlJfjl2r8yzelddSOVMtt7qWeSO1zJzjIAwwSOLf91CAAhcMGfToBmlrutJX(LuwielKRrJglG6H)azb0aQq6FUQ6QJugJ5xafgPH(S(dKfqhFkYcX2kzhVmWcizjaZYkviLYINWSOUez5EwwwSy7(DwigiHaicl(ITqoXPO0fqX01viCX4kGg67X(8cOq8(CDfAcW1aiHV)az1bybup8hilGEzW70)dKfFXwi3(kkDbumDDfcxmUcOH(ESpVaAzwcaGcgylnbVEzW0ySFjLfcWI(AonbVEzWaVA)pqYcbyPxjobnj0y1xmOHpxv9o45fQwlf1BdMUUcHzPuSqUDSmglbaqbdSLgm2cyd7QoiHnWR2)dKSqawiFtwgXYWal6R50e86LbtJX(LuwgJf7JLHbwG71bBsqnatlG6H)azbum2cyd7QoiHlGcJ0qFw)bYcOJpfzrdITa2WMLXbsywajlbywSD)olqFVNUsXYYIfpHzH6qqwMGMfcYsr9MfpHzHyBLSJxgk(ITqEjRO0fqX01viCX4kG6H)azbu6JkL31PYBSaAiAqH13Bs4tl2c5fqHrAOpR)azbucA4Sr6oltL3ilGKLLflpGf7XY7nj8PSy7(DW6zHyBLSJxgyrhVKelUoy9S8awqcBDnYINWSKGNfaeSdUL1LKkGg67X(8cOnoBKU76kKfTS8xmwFqf(qwgJfY1ilAzHAHkv99Me(ud99EEnYcHyHGzrllUvnSJbIyrllLzrFnNMGxVmyAm2VKYYySq(MSmmWseSOVMttWRxgmllwgv8fBXUnlkDbumDDfcxmUcOH(ESpVakguNffnxw9mklAzPmlUvnSJbIyzyGLiyPxjobnj0y1xmOHpxv9o45fQwlf1BdMUUcHzzelAzPml6R50y1xmOHpxv9o45fQwlf1BdexTqwiel2PXnzzyGf91CAcE9YGPXy)sklJXI9XYiw0YszwGbVXHDR)GGvQnVJRWEStcn)fi6ssSmmWseSeaqW0Z3KyObkqdZYWaluluPQV3KWNYYySyhlJyrllLzrFnNM2HGjyrRZgZse10ySFjLfcXsjJfnLLYSqWSukw6vItqtcn0lNlvDpk9X(CdMUUcHzzelAzrFnNM2HGjyrRZgZse1SSyzyGLiyrFnNM2HGjyrRZgZse1SSyzelAzPmlrWsaauWaBPj41ldMLflddSOVMtZV3NsvPise2g67bIyHqSqUgzrllZJ0(xBm2VKYcHyXUn3KfTSmps7FTXy)sklJXc5BUjlddSebluWsPFjS537tPQuejcBdMUUcHzzelAzPmluWsPFjS537tPQuejcBdMUUcHzzyGLaaOGb2stWRxgmng7xszzmwS3MSmIfTS8EtcFZFXy9bv4dzzmw0ilddSOdOuw0YY8iT)1gJ9lPSqiwiFZcOE4pqwaDU6OvWSIQvIfqHrAOpR)azb0XNISqCbAal3KLlPhmYINSObb1zrrw8eMf1Lil3ZYYIfB3VZIZcbzPOEZIvdcS4jmlBf2T(dcYcuBEhx8fBXoYlkDbumDDfcxmUcOH(ESpVaQ(AonGe)DA1c7aA9hinllw0Yszw0xZPH(EpDLY04Sr6URRqwggyXPF7QQfWg2SmglLSnzzubup8hilGsFVNUsvafgPH(S(dKfqhFkYIZc037PRuSOjM4VZIvdcSSsfsPSa99E6kflhLfx1OdhLLLflGMLOGflEJS46G1ZYdybab7GBXYwPeKIVyl2zxrPlGIPRRq4IXvan03J95fqdaiy65BYJ0(xNoYIwwIGL3vy(g6JkL3v4(MVbtxxHWSOLLYSaX7Z1vOjasiaIWkmsJMbwggyjaakyGT0e86LbZYILHbw0xZPj41ldMLflJyrllbaqbdSLMaiHaicR)owPwxFp10ySFjLfcXcPaSj2jmlLILaEkwkZIt)2vvlGnSzHSSaX7Z1vOHoRba9zzelAzrFnNg6790vktJX(LuwielemlAzjcwG71bBsqnatlG6H)azbu6790vQcOWin0N1FGSaQMCfBXYwPeew0XjOrwigiHaiczX297Sa99E6kflEcZYVJjlqFVPRMew8fBXo7vu6cOy66keUyCfqd99yFEb0aacME(M8iT)1PJSOLLYSaX7Z1vOjasiaIWkmsJMbwggyjaakyGT0e86LbZYILHbw0xZPj41ldMLflJyrllbaqbdSLMaiHaicR)owPwxFp10ySFjLfcXIgzrllq8(CDfAOV3txPQ2a5xNUsvbZjlAzbdQZIIMlREgLfTSeblq8(CDfAosjOXk99MUAsilAzjcwG71bBsqnatlG6H)azbu67nD1KWIVyl2rWfLUakMUUcHlgxb0qFp2NxavFnNgqI)oTguO3vih9aPzzXYWalLzjcwOV3ZRrJBvd7yGiw0YseSaX7Z1vO5iLGgR03B6QjHSmmWszw0xZPj41ldMgJ9lPSqiw0ilAzrFnNMGxVmywwSmmWszwkZI(AonbVEzW0ySFjLfcXcPaSj2jmlLILaEkwkZIt)2vvlGnSzHSSaX7Z1vOHsRba9zzelAzrFnNMGxVmywwSmmWI(AonTdbtWIwNnMLiALE5CPQ7rPp2NBAm2VKYcHyHua2e7eMLsXsapflLzXPF7QQfWg2SqwwG4956k0qP1aG(SmIfTSOVMtt7qWeSO1zJzjIwPxoxQ6Eu6J95MLflJyrllbaem98nqW83J2SmILrSOLLYSqTqLQ(EtcFQH(EpDLIfcXI9yzyGfiEFUUcn037PRuvBG8RtxPQG5KLrSmIfTSeblq8(CDfAosjOXk99MUAsilAzPmlrWsVsCcAsO5Vy0gOZkCJES(LWyBW01vimlddSqTqLQ(EtcFQH(EpDLIfcXI9yzubup8hilGsFVPRMewafgPH(S(dKfqhFkYc03B6QjHSy7(Dw8KfnXe)DwSAqGfqZYnzjkyTnmlaiyhClw2kLGWIT73zjky1SKiHFwco9nSSvffWc8k2ILTsjiS4pl)oYcMWSaMS87ilLCX83J2SOVMtwUjlqFVNUsXInWsbNB)SmDLIfWCYcOzjkyXI3ilGKf7y59Me(0IVyl2PXIsxaftxxHWfJRaAOVh7ZlGwMf91CAWG6SOyLcuEBAm2VKYYySGegdRhR)fJSmmWszwc7EtcPSejl2XIwwAmS7njS(xmYcHyrJSmILHbwc7EtcPSejl2JLrSOLf3Qg2Xarfq9WFGSaAI2QXaqwafgPH(S(dKfqhFkYIMaaKuwUKfOaL3SObb1zrrw8eMfQdbzH4Uukw0eaGKLjOzHyBLSJxgk(ITyhXRO0fqX01viCX4kGg67X(8cOLzrFnNgmOolkwPaL3MgJ9lPSmgliHXW6X6FXilddSuMLWU3KqklrYIDSOLLgd7EtcR)fJSqiw0ilJyzyGLWU3KqklrYI9yzelAzXTQHDmqelAzPml6R500oemblAD2ywIOMgJ9lPSqiw0ilAzrFnNM2HGjyrRZgZse1SSyrllrWsVsCcAsOHE5CPQ7rPp2NBW01vimlddSebl6R500oemblAD2ywIOMLflJkG6H)azb0DxnRXaqw8fBXoItrPlGIPRRq4IXvan03J95fqlZI(AonyqDwuSsbkVnng7xszzmwqcJH1J1)Irw0YszwcaGcgylnbVEzW0ySFjLLXyrJBYYWalbaqbdSLMaiHaicR)owPwxFp10ySFjLLXyrJBYYiwggyPmlHDVjHuwIKf7yrllng29Mew)lgzHqSOrwgXYWalHDVjHuwIKf7XYiw0YIBvd7yGiw0Yszw0xZPPDiycw06SXSernng7xszHqSOrw0YI(AonTdbtWIwNnMLiQzzXIwwIGLEL4e0Kqd9Y5sv3JsFSp3GPRRqywggyjcw0xZPPDiycw06SXSernllwgva1d)bYcOZLsvJbGS4l2ID2xrPlGIPRRq4IXvafgPH(S(dKfqhFkYcbfqdybKSqmnzbup8hilGAZ7(aDfmROALyXxSf7kzfLUakMUUcHlgxbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaLAHkv99Me(ud99EEnYYySqWSqawMkaOzPmlXo9XoAfIRwilLIfY3Ctwill2TjlJyHaSmvaqZszw0xZPH(EtxnjSIXwaByhJ5xPaL3g67bIyHSSqWSmQakeVRPhJfqPV3ZRX6Lvkq5DbuyKg6Z6pqwaLyUkSu(JuwSTJ)o2S8awwuKfOV3ZRrwUKfOaL3SyB)c7SCuw8NfnYY7nj8PeGCwMGMfec2rzXUnj(Se70h7OSaAwiywG(EtxnjKfni2cyd7ymFwOVhiIw8fBXEBwu6cOy66keUyCfqd99yFEb0iyrFnNM2HGjyrRZgZse1SSyrllrWI(AonTdbtWIwNnMLiALE5CPQ7rPp2NBwwSOLLiy5DfMVHcwQkyw)DSobnsFdMUUcHzrlluluPQV3KWNAOV3ZRrwiel2JfTSOVMtdguNffRuGYBtJX(LuwgJfKWyy9y9VyKfTSmps7FTXy)sklJXI(AonbVEzW0ySFjLfcWc52XsPyPxjobnj0y1xmOHpxv9o45fQwlf1BdMUUcHlG6H)azbuBT)7fqHrAOpR)azbunXKf7y59Me(uwSD)oy9SafSuSaMS87ilexqJ0NLOGfl0DWsbZY8ukwSD)oleuT)7SaV6ljXY4LHIVyl2J8IsxaftxxHWfJRakWQakf)cOE4pqwafI3NRRWcOqC1clGsolKLfQfQu1DN(ileIf7yrtzPmlBASJLsXszwOwOsvFVjHp1qFVNxJSOPSqolJyPuSuMfYzHaS8UcZ3qblvfmR)owNGgPVbtxxHWSukwi3OrwgXYiwialBAixJSukw0xZPPDiycw06SXSernng7xslGcX7A6XybuBT)71lRZgZseTakmsd9z9hilGsmxfwk)rkl22XFhBwEaleuT)7SaV6ljXcXTXSerl(ITyp7kkDbumDDfcxmUcOH(ESpVaAzwWG6SOOrTsVRjs4NLHbwWG6SOOXZO1ej8ZIwwG4956k0C0AqHoeKLrSOLLYS8EtcFZFXy9bv4dzzmwiywggybdQZIIg1k9UEz1owggyrhqPSOLL5rA)Rng7xszHqSq(MSmILHbw0xZPbdQZIIvkq5TPXy)skleIfp8hin03751Objmgwpw)lgzrll6R50Gb1zrXkfO82SSyzyGfmOolkAUSsbkVzrllrWceVpxxHg6798ASEzLcuEZYWal6R50e86LbtJX(LuwielE4pqAOV3ZRrdsymSES(xmYIwwIGfiEFUUcnhTguOdbzrll6R50e86LbtJX(LuwieliHXW6X6FXilAzrFnNMGxVmywwSmmWI(AonTdbtWIwNnMLiQzzXIwwG4956k0yR9FVEzD2ywIOSmmWseSaX7Z1vO5O1GcDiilAzrFnNMGxVmyAm2VKYYySGegdRhR)fJfq9WFGSaQT2)9cOWin0N1FGSa64trwiOA)3z5swGcuEZIgeuNffzb0SCtwsalqFVNxJSy7ukwM3ZYLpGfITvYoEzGfpJgdAS4l2I9SxrPlGIPRRq4IXvafgPH(S(dKfqhFkYc03751il3KLlzHmxP3SObb1zrrnZYLSafO8MfniOolkYcizHGjalV3KWNYcOz5bSy1GalqbkVzrdcQZIIfq9WFGSak99EEnw8fBXEeCrPlGIPRRq4IXva1d)bYcO9kRE4pqwvh9lGcJ0qFw)bYcOexxP(9EvavD0VMEmwaD6k1V3RIV4lGoDL637vrPl2c5fLUakMUUcHlgxb0qFp2Nxancw6vItqtcn6UYZawbZQRu1F)ssudA)RZYcHlG6H)azbu67nD1KWcOWin0N1FGSak03B6QjHSmbnlXaiymMplRuHukll6LKyzCGTw6IVyl2vu6cOy66keUyCfq9WFGSakDLZRXcOHObfwFVjHpTylKxafgPH(S(dKfqjMtFw(DKfyWZIT73z53rwIb0NL)IrwEalommlR8pfl)oYsStywGxT)hiz5OSSFVHfORCEnYsJX(LuwIxQ)SuhcZYdyj2)WolXaqoVgzbE1(FGSaAOVh7ZlGcdEtmaKZRrtJX(LuwgJLgJ9lPSukwSZowillKBFfFXwSxrPlG6H)azb0yaiNxJfqX01viCX4k(IVak9lkDXwiVO0fqX01viCX4kG6H)azbuh2T(dcwP28oUaAiAqH13Bs4tl2c5fqHrAOpR)azb0XNISSvy36piilqT5Dml22XKLFhBKLJYscyXd)bbzHAZ7ynZItzr5pYItzXcqPNUczbKSqT5Dml2UFNf7yb0SmrByZc99aruwanlGKfNf7rawO28oMfkGLF3Fw(DKLeTXc1M3XS4DFqqklLCSOpl(8XMLF3FwO28oMfKWwxJ0cOH(ESpVaAeSadEJd7w)bbRuBEhxH9yNeA(lq0LKyrllrWIh(dKgh2T(dcwP28oUc7Xoj0CzDQos7plAzPmlrWcm4noSB9heSsT5DCDhDL5VarxsILHbwGbVXHDR)GGvQnVJR7ORmng7xszzmw0ilJyzyGfyWBCy36piyLAZ74kSh7Kqd99arSqiwShlAzbg8gh2T(dcwP28oUc7Xoj00ySFjLfcXI9yrllWG34WU1FqWk1M3Xvyp2jHM)ceDjPIVyl2vu6cOy66keUyCfqd99yFEb0iybUxhSjb1amLfTSuMLYSaX7Z1vOjasiaIWkmsJMbw0YseSeaafmWwAcE9YGPrhoklAzjcw6vItqtcnw9fdA4ZvvVdEEHQ1sr92GPRRqywggyrFnNMGxVmywwSOLLYSebl9kXjOjHgR(Ibn85QQ3bpVq1APOEBW01vimlddS0ReNGMeAcOcP)5Qk1667PgmDDfcZYWalZJ0(xBm2VKYYySqUDehwggyrhqPSOLL5rA)Rng7xszHqSeaafmWwAcE9YGPXy)skleGfY3KLHbw0xZPj41ldMgJ9lPSmglKBhlJyzelAzPmlLzXPF7QQfWg2SqOizbI3NRRqtaKqaeHvNAXIwwkZI(AonyqDwuSQwP3MgJ9lPSmglKVjlddSOVMtdguNffRuGYBtJX(LuwgJfY3KLrSmmWI(AonbVEzW0ySFjLLXyrJSOLf91CAcE9YGPXy)sklekswi3owgXIwwkZseS0ReNGMeA(lgTb6Sc3OhRFjm2gmDDfcZYWalrWsVsCcAsOjGkK(NRQuRRVNAW01vimlddSOVMtZFXOnqNv4g9y9lHX20ySFjLLXybjmgwpw)lgzzelddS0ReNGMeA0DLNbScMvxPQ)(LKOgmDDfcZYiw0YszwIGLEL4e0KqJUR8mGvWS6kv93VKe1GPRRqywggyPml6R50O7kpdyfmRUsv)9ljrRP)Rgn03deXsKSyFSmmWI(Aon6UYZawbZQRu1F)ss0Q3bprd99arSejl2hlJyzelddSOdOuw0YY8iT)1gJ9lPSqiwiFtw0YseSeaafmWwAcE9YGPrhoklJkG6H)azb0aiHaicR)owPwxFpTakmsd9z9hilGo(uKYcXajearil3KfITvYoEzGLJYYYIfqZsuWIfVrwGrA0mCjjwi2wj74LbwSD)oledKqaeHS4jmlrblw8gzrhvaBSqWBsw7TzzIHkK(NRybQ113thXYwPeewUKfNfY3KaSqXalAqqDwu0WYwvualWGC7Nff(SOjB0J1VegBwqcBDnQzwCLnpkLLffz5swi2wj74LbwSD)oleKLI6nlEcZI)S87il037NfWKfNLXb2APzX2LWaBMIVyl2RO0fqX01viCX4kGg67X(8cO9kXjOjHM)IrBGoRWn6X6xcJTbtxxHWSOLLYSeblLzPml6R508xmAd0zfUrpw)sySnng7xszzmw8WFG0yR9F3GegdRhR)fJSqaw20qolAzPmlyqDwu0Czvh87SmmWcguNffnxwPaL3SmmWcguNffnQv6Dnrc)SmILHbw0xZP5Vy0gOZkCJES(LWyBAm2VKYYyS4H)aPH(EpVgniHXW6X6FXileGLnnKZIwwkZcguNffnxwvR0BwggybdQZIIgkq5Dnrc)SmmWcguNffnEgTMiHFwgXYiwggyjcw0xZP5Vy0gOZkCJES(LWyBwwSmILHbwkZI(AonbVEzWSSyzyGfiEFUUcnbqcbqewHrA0mWYiw0YsaauWaBPjasiaIW6VJvQ113tnn6Wrzrllbaem98n5rA)RthzrllLzrFnNgmOolkwvR0BtJX(LuwgJfY3KLHbw0xZPbdQZIIvkq5TPXy)sklJXc5BYYiwgXIwwkZseSeaqW0Z3qu0(8KLHbwcaGcgylnySfWg2vDqcBAm2VKYYySyFSmQaQh(dKfqPV30vtclGcJ0qFw)bYcOJpfzb67nD1KqwEaleHOflllw(DKfnzJES(LWyZI(Aoz5MSCpl2alfmliHTUgzrhNGgzzE5r3VKel)oYsIe(zj40NfqZYdybEfBXIoobnYcXajearyXxSfcUO0fqX01viCX4kGg67X(8cO9kXjOjHgDx5zaRGz1vQ6VFjjQbtxxHWSOLLYSuMf91CA0DLNbScMvxPQ)(LKO10)vJg67bIyzmwSJLHbw0xZPr3vEgWkywDLQ(7xsIw9o4jAOVhiILXyXowgXIwwcaGcgylnbVEzW0ySFjLLXyH4WIwwIGLaaOGb2staKqaeH1FhRuRRVNAwwSmmWszwcaiy65BYJ0(xNoYIwwcaGcgylnbqcbqew)DSsTU(EQPXy)skleIfY3KfTSGb1zrrZLvpJYIwwC63UQAbSHnlJXIDBYcbyXEBYsPyjaakyGT0e86LbtJoCuwgXYOcOE4pqwaL(EtxnjSakmsd9z9hilGQjxXwSa99MUAsiLfB3VZY4CLNbKfWKLTQuSu69ljrzb0S8awSA0YBKLjOzHyGecGiKfB3VZY4aBT0fFXw0yrPlGIPRRq4IXvafyvaLIFbup8hilGcX7Z1vybuiUAHfqlZI(AonTdbtWIwNnMLiQPXy)sklJXIgzzyGLiyrFnNM2HGjyrRZgZse1SSyzelAzjcw0xZPPDiycw06SXSerR0lNlvDpk9X(CZYIfTSuMf91CAi6s4gHRySfWg2Xy(vmXM0vc00ySFjLfcXcPaSj2jmlJyrllLzrFnNgmOolkwPaL3MgJ9lPSmglKcWMyNWSmmWI(AonyqDwuSQwP3MgJ9lPSmglKcWMyNWSmmWszwIGf91CAWG6SOyvTsVnllwggyjcw0xZPbdQZIIvkq5TzzXYiw0YseS8UcZ3qbk6Fb0GPRRqywgvafI310JXcOWGV2O9VUgJX8PfqHrAOpR)azbuIbs47pqYYe0S4kflWGNYYV7plXoriLf6Qrw(DmklEJ52plnoBKUJWSyBhtwiO5qWeSOSqCBmlruw2DklkKsz539KfnYcfduwAm2V8ssSaAw(DKfni2cydBwghiHzrFnNSCuwCDW6z5bSmDLIfWCYcOzXZOSObb1zrrwoklUoy9S8awqcBDnw8fBH4vu6cOy66keUyCfqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0YSebl6R50Gb1zrXkfO82SSyrllrWI(AonyqDwuSQwP3MLflJyrllrWY7kmFdfOO)fqdMUUcHzrllrWsVsCcAsO5Vy0gOZkCJES(LWyBW01viCbuiExtpglGcd(ky90dgRyqDwuSakmsd9z9hilGsmqcF)bsw(D)zjSJbIOSCtwIcwS4nYcy90dgzbdQZIIS8awaPkklWGNLFhBKfqZYrkbnYYVFuwSD)olqbk6FbS4l2cXPO0fqX01viCX4kG6H)azb0yaiNxJfqdrdkS(EtcFAXwiVakmsd9z9hilGQjbplUsXY7nj8PSy7(9lzHG4jmgFbwSD)oy9SaGGDWTSUKeb(DKfxhabzjas47pqslGg67X(8cOLzrFnNgmOolkwPaL3MgJ9lPSmglng7xszzyGf91CAWG6SOyvTsVnng7xszzmwAm2VKYYWalq8(CDfAGbFfSE6bJvmOolkYYiw0YsJZgP7UUczrllV3KW38xmwFqf(qwgJfYTJfTS4w1WogiIfTSaX7Z1vObg81gT)11ymMpT4l2I9vu6cOy66keUyCfqd99yFEb0YSOVMtdguNffRuGYBtJX(LuwgJLgJ9lPSmmWI(AonyqDwuSQwP3MgJ9lPSmglng7xszzyGfiEFUUcnWGVcwp9GXkguNffzzelAzPXzJ0DxxHSOLL3Bs4B(lgRpOcFilJXc52XIwwCRAyhdeXIwwG4956k0ad(AJ2)6AmgZNwa1d)bYcO0voVglGgIguy99Me(0ITqEXxSLswrPlGIPRRq4IXvan03J95fqlZI(AonyqDwuSsbkVnng7xszzmwAm2VKYYWal6R50Gb1zrXQALEBAm2VKYYyS0ySFjLLHbwG4956k0ad(ky90dgRyqDwuKLrSOLLgNns3DDfYIwwEVjHV5VyS(Gk8HSmglKt8yrllUvnSJbIyrllq8(CDfAGbFTr7FDngJ5tlG6H)azbu6JkL31PYBSaAiAqH13Bs4tl2c5fFXwiFZIsxaftxxHWfJRakWQakf)cOE4pqwafI3NRRWcOqC1clGgaqW0Z3abZFpAZIwwIGLEL4e0Kqd9Y5sv3JsFSp3GPRRqyw0YseS0ReNGMeAcxhuyfmRQBIvpHRWO)7gmDDfcZIwwcaGcgyln6ytXMOljzA0HJYIwwcaGcgylnTdbtWIwNnMLiQPrhoklAzjcw0xZPj41ldMLflAzPmlo9BxvTa2WMLXyX(ioSmmWI(Aon6kaawTOVzzXYOcOq8UMEmwanb19O0h7ZRO3QOvyWxafgPH(S(dKfq1KGNL(iT)SOJtqJSqCBmlruwUjl3ZInWsbZIRuaBSefSy5bS04Sr6olkKszbE1xsIfIBJzjIYs5F)OSasvuw2DllmPSy7(DW6zb6LZLIfc6JsFSpFuXxSfYjVO0fqX01viCX4kGg67X(8cOq8(CDfAsqDpk9X(8k6TkAfg8SOLLgJ9lPSqiwSBZcOE4pqwangaY51yXxSfYTRO0fqX01viCX4kGg67X(8cOq8(CDfAsqDpk9X(8k6TkAfg8SOLLgJ9lPSqiwiVKva1d)bYcO0voVgl(ITqU9kkDbumDDfcxmUcOH(ESpVaQBvd7yGOcOE4pqwaDc6awbZA6)QXcOWin0N1FGSa64trwiUGTWcizjaZIT73bRNLGBzDjPIVylKtWfLUakMUUcHlgxb0qFp2NxaTmlbaqbdSLMGxVmyAm2VKYcbyrFnNMGxVmyGxT)hizHaS0ReNGMeAS6lg0WNRQEh88cvRLI6TbtxxHWSukwi3owgJLaaOGb2sdgBbSHDvhKWg4v7)bswialKVjlJyzyGf91CAcE9YGPXy)sklJXI9XYWalW96GnjOgGPfq9WFGSakgBbSHDvhKWfqHrAOpR)azb0XNISObXwaByZY4ajml2UFNfpJYIcKKybtWI0olkN(xsIfniOolkYINWS8DuwEalQlrwUNLLfl2UFNfcYsr9MfpHzHyBLSJxgk(ITqUglkDbumDDfcxmUcOaRcOu8lG6H)azbuiEFUUclGcXvlSaQt)2vvlGnSzzmwkzBYIMYszwSZOrwkfl6R50mxD0kywr1krd99arSOPSyhlLIfmOolkAUSQwP3SmQakeVRPhJfqDQvfEfBvafgPH(S(dKfqHIpLfB7yYYwPeewO7GLcMfDKf4vSfcZYdyjbplaiyhClwkRjrlmHPSaswiURoklGjlAGALilEcZYVJSObb1zrXrfFXwiN4vu6cOy66keUyCfqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0iybUxhSjb1amLfTSuMfiEFUUcnb4AaKW3FGKfTSebl6R50e86LbZYIfTSuMLiyHIFvhKlQ5pSTZ(Q2zfyzyGfmOolkAUSQwP3SmmWcguNffnuGY7AIe(zzelAzPmlLzPmlq8(CDfACQvfEfBXYWalbaem98n5rA)RthzzyGLYSeaqW0Z3qu0(8KfTSeaafmWwAWylGnSR6Ge20OdhLLrSmmWsVsCcAsO5Vy0gOZkCJES(LWyBW01vimlJyrllWG3qx58A00ySFjLLXyX(yrllWG3eda58A00ySFjLLXyPKXIwwkZcm4n0hvkVRtL3OPXy)sklJXc5BYYWalrWY7kmFd9rLY76u5nAW01vimlJyrllq8(CDfA(9(uQkfrIWUAZVNfTS8EtcFZFXy9bv4dzzmw0xZPj41ldg4v7)bswkflBAioSmmWI(Aon6kaawTOVzzXIww0xZPrxbaWQf9nng7xszHqSOVMttWRxgmWR2)dKSqawkZc52XsPyPxjobnj0y1xmOHpxv9o45fQwlf1BdMUUcHzzelJyzyGLYSG2)6SSqydgBfTrxvbnC6zazrllbaqbdSLgm2kAJUQcA40ZaAAm2VKYcHyHCIhXHfcWszw0ilLILEL4e0Kqd9Y5sv3JsFSp3GPRRqywgXYiwgXIwwkZszwIGLaacME(M8iT)1PJSmmWszwG4956k0eajearyfgPrZalddSeaafmWwAcGecGiS(7yLAD99utJX(LuwielKRrwgXIwwkZseS0ReNGMeA0DLNbScMvxPQ)(LKOgmDDfcZYWalo9BxvTa2WMfcXIg3KfTSeaafmWwAcGecGiS(7yLAD99utJoCuwgXYiwggyzEK2)AJX(LuwielbaqbdSLMaiHaicR)owPwxFp10ySFjLLrSmmWIoGszrllZJ0(xBm2VKYcHyrFnNMGxVmyGxT)hizHaSqUDSukw6vItqtcnw9fdA4ZvvVdEEHQ1sr92GPRRqywgvafI310JXcOb4AaKW3FGSs)cOWin0N1FGSa64trwi2wj74LbwSD)oledKqaeHKTK3LWncZcuRRVNYINWSadYTFwaqW2wFpYcbzPOEZcOzX2oMSmofaaRw0NfBGLcMfKWwxJSOJtqJSqSTs2XldSGe26AKAyrtWjczHUAKLhWcMp2S4SqMR0Bw0GG6SOil22XKLf9iLSuA7SpwSZkWINWS4kflettszX2PuSOJbqmYsJoCuwOaqYcMGfPDwGx9LKy53rw0xZjlEcZcm4PSS7qqw0rmzHUMZlCy(QOS04Sr6ocBk(ITqoXPO0fqX01viCX4kGg67X(8cO6R50e86LbtJX(LuwgJfY1ilddSOVMttWRxgmWR2)dKSqiwSJ4WcbyPxjobnj0y1xmOHpxv9o45fQwlf1BdMUUcHzPuSqUDSOLfiEFUUcnb4AaKW3FGSs)cOE4pqwaTDiycw06SXSerlGcJ0qFw)bYcOJpfzH42ywIOSy7(Dwi2wj74LbwwPcPuwiUnMLikl2alfmlkN(SOajjSz539KfITvYoEzqZS87yYYIISOJtqJfFXwi3(kkDbumDDfcxmUcOH(ESpVakeVpxxHMaCnas47pqwPplAzPml6R50e86Lbd8Q9)ajlJfjl2rCyHaS0ReNGMeAS6lg0WNRQEh88cvRLI6TbtxxHWSukwi3owggyjcwcaiy65BGG5VhTzzelddSOVMtt7qWeSO1zJzjIAwwSOLf91CAAhcMGfToBmlrutJX(LuwielLmwialbqcVU3y1y4Oy1vhPmgZ38xmwH4QfYcbyPmlrWI(Aon6kaawTOVzzXIwwIGL3vy(g67Tc0WgmDDfcZYOcOE4pqwanGkK(NRQU6iLXy(fFXwiVKvu6cOy66keUyCfqd99yFEbuiEFUUcnb4AaKW3FGSs)cOE4pqwa9YG3P)hil(ITy3MfLUakMUUcHlgxbuGvbuk(fq9WFGSakeVpxxHfqH4QfwanaakyGT0e86LbtJX(LuwgJfY3KLHbwIGfiEFUUcnbqcbqewHrA0mWIwwcaiy65BYJ0(xNoYYWalW96GnjOgGPfqH4Dn9ySak1HG1jORbVEzOakmsd9z9hilGwY17Z1villkcZcizX1p19hsz539NfBE(S8aw0rwOoeeMLjOzHyBLSJxgyHcy539NLFhJYI3y(SyZPpcZsjhl6ZIoobnYYVJXfFXwSJ8IsxaftxxHWfJRaAOVh7ZlGIb1zrrZLvpJYIwwkZIt)2vvlGnSzHqSuYSJfnLf91CAMRoAfmROALOH(EGiwkflAKLHbw0xZPPDiycw06SXSernllwgXIwwkZI(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKfcXIDe8MSmmWI(AonbVEzW0ySFjLLXyX(yzelAzbI3NRRqd1HG1jORbVEzGfTSuMLiyjaGGPNVjXqduGgMLHbwGbVXHDR)GGvQnVJRWEStcn)fi6ssSmIfTSuMLiyjaGGPNVbcM)E0MLHbw0xZPPDiycw06SXSernng7xszHqSuYyrtzPmlemlLILEL4e0Kqd9Y5sv3JsFSp3GPRRqywgXIww0xZPPDiycw06SXSernllwggyjcw0xZPPDiycw06SXSernllwgXIwwkZseSeaqW0Z3qu0(8KLHbwcaGcgylnySfWg2vDqcBAm2VKYYySy3MSmIfTS8EtcFZFXy9bv4dzzmw0ilddSOdOuw0YY8iT)1gJ9lPSqiwiFZcOE4pqwaDU6OvWSIQvIfqHrAOpR)azb0XNIuwiUanGLBYYLS4jlAqqDwuKfpHz57dPS8awuxISCplllwSD)oleKLI6TMzHyBLSJxg0mlAqSfWg2SmoqcZINWSSvy36piilqT5DCXxSf7SRO0fqX01viCX4kGg67X(8cO6R50as83PvlSdO1FG0SSyrll6R50qFVNUszAC2iD31vybup8hilGsFVNUsvafgPH(S(dKfqhFkYIMyI)olqFVNUsXIvdcuwUjlqFVNUsXYrZTFwwwfFXwSZEfLUaQ(AoRPhJfqPV3kqdxan03J95fq1xZPH(ERanSPXy)skleIfnYIwwkZI(AonyqDwuSsbkVnng7xszzmw0ilddSOVMtdguNffRQv6TPXy)sklJXIgzzelAzXPF7QQfWg2SmglLSnlGIPRRq4IXvafgPH(S(dKfqjMNbuXc03BfOHz5MSCpl7oLffsPS87EYIgPS0ySF5LK0mlrblw8gzXFwkzBsaw2kLGWINWS87ilHv3y(SObb1zrrw2DklAKauwAm2V8ssfq9WFGSaAWZaQQ6R5S4l2IDeCrPlGQVMZA6XybuR(Ibn85QQ3bpVq1APOExan03J95fqFxH5BUm4D6)bsdMUUcHzrllrWY7kmFtI2QXaqAW01vimlAzPKpwkZszwS3MBYIMYIt)2vvlGnSzHaSqWBYIMYcf)QoixuZFyBN9vTZkWsPyHG3KLrSqwwkZcbZczzHAHkvD3PpYYiw0uwcaGcgylnbqcbqew)DSsTU(EQPXy)sklJyHqSuYhlLzPml2BZnzrtzXPF7QQfWg2SOPSOVMtJvFXGg(Cv17GNxOATuuVnqC1czHaSqWBYIMYcf)QoixuZFyBN9vTZkWsPyHG3KLrSqwwkZcbZczzHAHkvD3PpYYiw0uwcaGcgylnbqcbqew)DSsTU(EQPXy)sklJyrllbaqbdSLMGxVmyAm2VKYYySyVnzrll6R50y1xmOHpxv9o45fQwlf1BdexTqwiel2r(MSOLf91CAS6lg0WNRQEh88cvRLI6TbIRwilJXI92KfTSeaafmWwAcGecGiS(7yLAD99utJX(Luwiele8MSOLL5rA)Rng7xszzmwcaGcgylnbqcbqew)DSsTU(EQPXy)skleGfIhlAzPml9kXjOjHMaQq6FUQsTU(EQbtxxHWSmmWceVpxxHMaiHaicRWinAgyzubumDDfcxmUcOWin0N1FGSakX8mGkw(DKfcYsr9Mf91CYYnz53rwSAqGfBGLco3(zrDjYYYIfB3VZYVJSKiHFw(lgzHyGecGiKLaigPSaMtwcWgwk9(rzzrxUsfLfqQIYYUBzHjLf4vFjjw(DKLXrMMcOE4pqwan4zavv91Cw8fBXonwu6cOy66keUyCfqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0aacME(M8iT)1PJSOLLEL4e0KqJvFXGg(Cv17GNxOATuuVny66keMfTSOVMtJvFXGg(Cv17GNxOATuuVnqC1czHaS40VDv1cydBwial2JLXIKf7T5MSOLfiEFUUcnbqcbqewHrA0mWIwwcaGcgylnbqcbqew)DSsTU(EQPXy)skleIfN(TRQwaByZczzXEBYsPyHua2e7eMfTSeblW96GnjOgGPSOLfmOolkAUS6zuw0YIt)2vvlGnSzzmwG4956k0eajeary1PwSOLLaaOGb2stWRxgmng7xszzmw0ybuiExtpglGA1Gq1APOExrVvrlGcJ0qFw)bYcOqXNYITDmzHGSuuVzHUdwkyw0rwSAqiGWSGERIYYdyrhzX1vilpGLffzHyGecGiKfqYsaauWaBjlL1akfZ)CLkkl6yaeJuw(EHSCtwGxXwxsILTsjiSKaBSy7ukwCLcyJLOGflpGflSNy4vrzbZhBwiilf1Bw8eMLFhtwwuKfIbsiaIWrfFXwSJ4vu6cOy66keUyCfqd99yFEb0YS8UcZ3qFuP8Uc338ny66keMLHbwO4x1b5IA(dB7SVkbBfyzelAzjcwExH5BOV3kqdBW01vimlAzrFnNg6790vktJZgP7UUczrllrWsVsCcAsO5Vy0gOZkCJES(LWyBW01vimlAzPml6R50y1xmOHpxv9o45fQwlf1BdexTqwglswStJBYIwwIGf91CAcE9YGzzXIwwkZceVpxxHgNAvHxXwSmmWI(AoneDjCJWvm2cyd7ym)kMyt6kbAwwSmmWceVpxxHgRgeQwlf17k6TkklJyzyGLYSeaqW0Z3KyObkqdZIwwExH5BOpQuExH7B(gmDDfcZIwwkZcm4noSB9heSsT5DCf2JDsOPXy)sklJXI9XYWalE4pqACy36piyLAZ74kSh7KqZL1P6iT)SmILrSmIfTSuMLaaOGb2stWRxgmng7xszzmwiFtwggyjaakyGT0eajeary93Xk1667PMgJ9lPSmglKVjlJkG6H)azbu6790vQcOWin0N1FGSa64trwG(EpDLIfB3VZc0hvkVzrt238zb0S82zFSqWwbw8eMLeWc03BfOH1ml22XKLeWc037PRuSCuwwwSaAwEalwniWcbzPOEZITDmzX1bqqwkzBYYwPeKYGMLFhzb9wfLfcYsr9MfRgeybI3NRRqwoklFVWrSaAwCyl)piiluBEhZYUtzX(iafduwAm2V8ssSaAwoklxYYuDK2)IVyl2rCkkDbumDDfcxmUcOH(ESpVakeVpxxHgRgeQwlf17k6TkAbup8hilGsFVPRMewafgPH(S(dKfq1KRylklBLsqyrhNGgzHyGecGiKLf9ssS87iledKqaeHSeaj89hiz5bSe2XarSCtwigiHaicz5OS4HF5kvuwCDW6z5bSOJSeC6x8fBXo7RO0fqX01viCX4kGg67X(8cOUvnSJbIyrllLzjS7njKYsKSyhlAzPXWU3KW6FXileIfnYYWalHDVjHuwIKf7XYOcOE4pqwanrB1yailGcJ0qFw)bYcOJpfzrtaaskl22XKLOGflEJS46G1ZYdiR3ilb3Y6ssSe29MeszXtywIDIqwORgz53XOS4nYYLS4jlAqqDwuKf6FkfltqZcb9AcKL4Qju8fBXUswrPlGIPRRq4IXvan03J95fqDRAyhdeXIwwkZsy3BsiLLizXow0YsJHDVjH1)IrwielAKLHbwc7EtcPSejl2JLrSOLLYSOVMtdguNffRQv6TPXy)sklJXcsymSES(xmYYWal6R50Gb1zrXkfO820ySFjLLXybjmgwpw)lgzzubup8hilGU7QzngaYIVyl2BZIsxaftxxHWfJRaAOVh7ZlG6w1WogiIfTSuMLWU3KqklrYIDSOLLgd7EtcR)fJSqiw0ilddSe29MeszjswShlJyrllLzrFnNgmOolkwvR0BtJX(LuwgJfKWyy9y9VyKLHbw0xZPbdQZIIvkq5TPXy)sklJXcsymSES(xmYYOcOE4pqwaDUuQAmaKfFXwSh5fLUakMUUcHlgxb0qFp2NxafdQZIIMlREgLfTSuMf91CAaj(70AqHExHC0dKMLflddSOVMtdrxc3iCfJTa2WogZVIj2KUsGMLflddSOVMttWRxgmllw0YszwIGLaacME(gII2NNSmmWsaauWaBPbJTa2WUQdsytJX(LuwgJfnYYWal6R50e86LbtJX(LuwielKcWMyNWSukwMkaOzPmlo9BxvTa2WMfYYceVpxxHgkTga0NLrSmIfTSuMLiyjaGGPNVbcM)E0MLHbw0xZPPDiycw06SXSernng7xszHqSqkaBIDcZsPyjGNILYSuMfN(TRQwaByZcbyHG3KLsXY7kmFZC1rRGzfvReny66keMLrSqwwG4956k0qP1aG(SmIfcWI9yPuS8UcZ3KOTAmaKgmDDfcZIwwIGLEL4e0Kqd9Y5sv3JsFSp3GPRRqyw0YI(AonTdbtWIwNnMLiQzzXYWal6R500oemblAD2ywIOv6LZLQUhL(yFUzzXYWalLzrFnNM2HGjyrRZgZse10ySFjLfcXIh(dKg6798A0GegdRhR)fJSOLfQfQu1DN(ileILnnemlddSOVMtt7qWeSO1zJzjIAAm2VKYcHyXd)bsJT2)DdsymSES(xmYYWalq8(CDfAo7hUgaj89hizrllbaqbdSLMlPHE9UUcR2)YZFfxHrixann6WrzrllO9Volle2Cjn0R31vy1(xE(R4kmc5cilJyrll6R500oemblAD2ywIOMLflddSebl6R500oemblAD2ywIOMLflAzjcwcaGcgylnTdbtWIwNnMLiQPrhoklJyzyGfiEFUUcno1QcVITyzyGfDaLYIwwMhP9V2ySFjLfcXcPaSj2jmlLILaEkwkZIt)2vvlGnSzHSSaX7Z1vOHsRba9zzelJkG6H)azbu67nD1KWcOWin0N1FGSa64trwG(EtxnjKfnXe)DwSAqGYINWSaVITyzRuccl22XKfITvYoEzqZSObXwaByZY4ajSMz53rwk5I5VhTzrFnNSCuwCDW6z5bSmDLIfWCYcOzjkyTnmlb3ILTsjifFXwSNDfLUakMUUcHlgxb0qFp2Nxa9DfMVH(ERanSbtxxHWSOLLiyPxjobnj08xmAd0zfUrpw)sySny66keMfTSuMf91CAOV3kqdBwwSmmWIt)2vvlGnSzzmwkzBYYiw0YI(Aon03BfOHn03deXcHyXESOLLYSOVMtdguNffRuGYBZYILHbw0xZPbdQZIIv1k92SSyzelAzrFnNgR(Ibn85QQ3bpVq1APOEBG4QfYcHyXoIZMSOLLYSeaafmWwAcE9YGPXy)sklJXc5BYYWalrWceVpxxHMaiHaicRWinAgyrllbaem98n5rA)Rthzzubup8hilGsFVPRMewafgPH(S(dKfqlDhLLhWsSteYYVJSOJ0NfWKfOV3kqdZIEuwOVhi6ssSCplllwS)1fisfLLlzXZOSObb1zrrw0xpleKLI6nlhn3(zX1bRNLhWIoYIvdcbeU4l2I9SxrPlGIPRRq4IXvafyvaLIFbup8hilGcX7Z1vybuiUAHfqXG6SOO5YQALEZsPyX(yHSS4H)aPH(EpVgniHXW6X6FXileGLiybdQZIIMlRQv6nlLILYSq8yHaS8UcZ3qblvfmR)owNGgPVbtxxHWSukwShlJyHSS4H)aPXw7)Ubjmgwpw)lgzHaSSPHG1ilKLfQfQu1DN(ileGLnnAKLsXY7kmFt6)QrAv3vEgqdMUUcHlGcX7A6XybuNArqWgkgkGcJ0qFw)bYcOAa9Vy)rkl7aBSeVc7SSvkbHfVrwi5xIWSyHnlumasydlAIPkklVteszXzHMUfDh8Smbnl)oYsy1nMpl07x(FGKfkGfBGLco3(zrhzXdHv7pYYe0SO8Me2S8xmoBpgPfFXwShbxu6cOy66keUyCfqd99yFEb0iyPxjobnj08xmAd0zfUrpw)sySny66keMfTSuMf91CAS6lg0WNRQEh88cvRLI6TbIRwileIf7ioBYYWal6R50y1xmOHpxv9o45fQwlf1BdexTqwiel2PXnzrllVRW8n0hvkVRW9nFdMUUcHzzelAzPmlyqDwu0CzLcuEZIwwC63UQAbSHnleGfiEFUUcno1IGGnumWsPyrFnNgmOolkwPaL3MgJ9lPSqawGbVzU6OvWSIQvIM)cerRng7xYsPyXoJgzzmwSVnzzyGfmOolkAUSQwP3SOLfN(TRQwaByZcbybI3NRRqJtTiiydfdSukw0xZPbdQZIIv1k920ySFjLfcWcm4nZvhTcMvuTs08xGiATXy)swkfl2z0ilJXsjBtwgXIwwIGf91CAaj(70Qf2b06pqAwwSOLLiy5DfMVH(ERanSbtxxHWSOLLYSeaafmWwAcE9YGPXy)sklJXcXHLHbwOGLs)syZV3NsvPise2gmDDfcZIww0xZP537tPQuejcBd99arSqiwSN9yrtzPml9kXjOjHg6LZLQUhL(yFUbtxxHWSukwSJLrSOLL5rA)Rng7xszzmwiFZnzrllZJ0(xBm2VKYcHyXUn3KLHbwG71bBsqnatzzelAzPmlrWsaabtpFdrr7ZtwggyjaakyGT0GXwaByx1bjSPXy)sklJXIDSmQaQh(dKfqPV30vtclGcJ0qFw)bYcOAYvSflqFVPRMeYYLS4jlAqqDwuKfNYcfaswCklwak90viloLffijXItzjkyXITtPybtywwwSy7(DwSVnjal22XKfmFSVKel)oYsIe(zrdcQZIIAMfyqU9ZIcFwUNfRgeyHGSuuV1mlWGC7NfaeST13JS4jlAIj(7Sy1GalEcZIfaOyrhNGgzHyBLSJxgyXtyw0GylGnSzzCGeU4l2I90yrPlGIPRRq4IXvan03J95fqDRAyhdeXIwwG4956k0qDiyDc6AWRxgyrllLzrFnNgmOolkwvR0BtJX(LuwgJfKWyy9y9VyKLHbw0xZPbdQZIIvkq5TPXy)sklJXcsymSES(xmYYOcOE4pqwanrB1yailGcJ0qFw)bYcOJpfzrtaasklxYINrzrdcQZIIS4jmluhcYcb9UAsaI7sPyrtaaswMGMfITvYoEzGfpHzPK3LWncZIgeBbSHDmMVHLTQOawwuKLTOjWINWSqC1eyXFw(DKfmHzbmzH42ywIOS4jmlWGC7Nff(SOjB0J1VegBwMUsXcyol(ITypIxrPlGIPRRq4IXvan03J95fqDRAyhdeXIwwG4956k0qDiyDc6AWRxgyrllLzrFnNgmOolkwvR0BtJX(LuwgJfKWyy9y9VyKLHbw0xZPbdQZIIvkq5TPXy)sklJXcsymSES(xmYYiw0Yszw0xZPj41ldMLflddSOVMtJvFXGg(Cv17GNxOATuuVnqC1czHqrYIDKVjlJyrllLzjcwcaiy65BGG5VhTzzyGf91CAAhcMGfToBmlrutJX(LuwielLzrJSOPSyhlLILEL4e0Kqd9Y5sv3JsFSp3GPRRqywgXIww0xZPPDiycw06SXSernllwggyjcw0xZPPDiycw06SXSernllwgXIwwkZseS0ReNGMeA(lgTb6Sc3OhRFjm2gmDDfcZYWaliHXW6X6FXileIf91CA(lgTb6Sc3OhRFjm2MgJ9lPSmmWseSOVMtZFXOnqNv4g9y9lHX2SSyzubup8hilGU7QzngaYIVyl2J4uu6cOy66keUyCfqd99yFEbu3Qg2XarSOLfiEFUUcnuhcwNGUg86Lbw0Yszw0xZPbdQZIIv1k920ySFjLLXybjmgwpw)lgzzyGf91CAWG6SOyLcuEBAm2VKYYySGegdRhR)fJSmIfTSuMf91CAcE9YGzzXYWal6R50y1xmOHpxv9o45fQwlf1BdexTqwiuKSyh5BYYiw0YszwIGLaacME(gII2NNSmmWI(AoneDjCJWvm2cyd7ym)kMyt6kbAwwSmIfTSuMLiyjaGGPNVbcM)E0MLHbw0xZPPDiycw06SXSernng7xszHqSOrw0YI(AonTdbtWIwNnMLiQzzXIwwIGLEL4e0Kqd9Y5sv3JsFSp3GPRRqywggyjcw0xZPPDiycw06SXSernllwgXIwwkZseS0ReNGMeA(lgTb6Sc3OhRFjm2gmDDfcZYWaliHXW6X6FXileIf91CA(lgTb6Sc3OhRFjm2MgJ9lPSmmWseSOVMtZFXOnqNv4g9y9lHX2SSyzubup8hilGoxkvngaYIVyl2Z(kkDbumDDfcxmUcOWin0N1FGSa64trwiOaAalGKLaCbup8hilGAZ7(aDfmROALyXxSf7vYkkDbumDDfcxmUcOH(ESpVakguNffnxwvR0Bw0YseSOVMtt7qWeSO1zJzjIAwwSmmWcguNffnuGY7AIe(zzyGLYSGb1zrrJNrRjs4NLHbw0xZPj41ldMgJ9lPSqiw8WFG0yR9F3GegdRhR)fJSOLf91CAcE9YGzzXYiw0YszwIGfk(vDqUOM)W2o7RANvGLHbw6vItqtcnw9fdA4ZvvVdEEHQ1sr92GPRRqyw0YI(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKfcXIDKVjlAzjaakyGT0e86LbtJX(LuwgJfYjoSOLLYSeblbaem98n5rA)RthzzyGLaaOGb2staKqaeH1FhRuRRVNAAm2VKYYySqoXHLrSOLLYSeblThqZ3aLILHbwcaGcgyln6ytXMOljzAm2VKYYySqoXHLrSmILHbwWG6SOO5YQNrzrllLzrFnNgBE3hORGzfvRenllwggyHAHkvD3PpYcHyztdbRrw0YszwIGLaacME(giy(7rBwggyjcw0xZPPDiycw06SXSernllwgXYWalbaem98nqW83J2SOLfQfQu1DN(ileILnnemlJkG6H)azbu6798ASakmsd9z9hilGo(uKfOV3ZRrwEalwniWcuGYBw0GG6SOOMzHyBLSJxgyz3PSOqkLL)Irw(DpzXzHGQ9FNfKWyy9ilkC(SaAwaPkklK5k9MfniOolkYYrzzzzyHG6(DwkTD2hl2zfybZhBwCwGcuEZIgeuNffz5MSqqwkQ3Sq)tPyz3PSOqkLLF3twSJ8nzH(EGiklEcZcX2kzhVmWINWSqmqcbqeYYUdbzjg0il)UNSqoXHYcX0KS0ySF5LKmSm(uKfxhabzXonUjXNLDN(ilWR(ssSqCBmlruw8eMf7SZoIpl7o9rwSD)oy9SqCBmlr0IVyle8MfLUakMUUcHlgxbuyKg6Z6pqwaD8PileuT)7Sa(DSTDuKfB7xyNLJYYLSafO8MfniOolkQzwi2wj74LbwanlpGfRgeyHmxP3SObb1zrXcOE4pqwa1w7)EXxSfcM8IsxaftxxHWfJRaQh(dKfq7vw9WFGSQo6xafgPH(S(dKfqjUUs979QaQ6OFn9ySa60vQFVxfFXx8fqHGn9azXwSBt7SBt7rEjRaQnVZljrlGsqTvcABz82cbDLelSu6DKLl2c0pltqZY2almXEBwA0(xxJWSqbXil(6bX(JWSe29Kesn8gK5Lil2vsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZszYj8idVbzEjYI9kjwigiHG9JWSSDVsCcAsOHm2MLhWY29kXjOjHgYWGPRRq4TzPm5eEKH3G3GGARe02Y4Tfc6kjwyP07ilxSfOFwMGMLTHXPVu)2S0O9VUgHzHcIrw81dI9hHzjS7jjKA4niZlrwiELeledKqW(rywGEXeJfA08DcZcXNLhWczUCwGpih9ajlalS9h0SuMSJyPm5eEKH3GmVezH4vsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZsz7i8idVbzEjYcXPKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLYKt4rgEdY8sKf7RKyHyGec2pcZc0lMySqJMVtywi(S8awiZLZc8b5OhizbyHT)GMLYKDelLTJWJm8gK5Lil2xjXcXajeSFeMLT7vItqtcnKX2S8aw2Uxjobnj0qggmDDfcVnlLjNWJm8gK5LilLSsIfIbsiy)imlB3ReNGMeAiJTz5bSSDVsCcAsOHmmy66keEBwkBpcpYWBqMxISuYkjwigiHG9JWSS93xse(gYnKX2S8aw2(7ljcFZtUHm2MLY2r4rgEdY8sKLswjXcXajeSFeMLT)(sIW3yNHm2MLhWY2FFjr4BE7mKX2Su2ocpYWBqMxISq(MLeledKqW(ryw2Uxjobnj0qgBZYdyz7EL4e0KqdzyW01vi82SuMCcpYWBqMxISqo5LeledKqW(ryw2Uxjobnj0qgBZYdyz7EL4e0KqdzyW01vi82SuMCcpYWBqMxISqUDLeledKqW(ryw2Uxjobnj0qgBZYdyz7EL4e0KqdzyW01vi82SuMCcpYWBqMxISqU9kjwigiHG9JWSSDVsCcAsOHm2MLhWY29kXjOjHgYWGPRRq4TzPm5eEKH3GmVezHCnwsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZszYj8idVbzEjYc5eVsIfIbsiy)imlB3ReNGMeAiJTz5bSSDVsCcAsOHmmy66keEBwkBhHhz4niZlrwiN4vsSqmqcb7hHzz7VVKi8nKBiJTz5bSS93xse(MNCdzSnlLjycpYWBqMxISqoXRKyHyGec2pcZY2FFjr4BSZqgBZYdyz7VVKi8nVDgYyBwktoHhz4niZlrwiN4usSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZsz7i8idVbzEjYc5eNsIfIbsiy)imlB)9LeHVHCdzSnlpGLT)(sIW38KBiJTzPm5eEKH3GmVezHCItjXcXajeSFeMLT)(sIW3yNHm2MLhWY2FFjr4BE7mKX2SuMGj8idVbVbb1wjOTLXBle0vsSWsP3rwUylq)SmbnlBB1yaeR7)2S0O9VUgHzHcIrw81dI9hHzjS7jjKA4niZlrwSxjXcXajeSFeMLT)(sIW3qUHm2MLhWY2FFjr4BEYnKX2Su2EeEKH3GmVezHGljwigiHG9JWSS93xse(g7mKX2S8aw2(7ljcFZBNHm2MLY2JWJm8gK5Lil2xjXcXajeSFeMLT7vItqtcnKX2S8aw2Uxjobnj0qggmDDfcVnl(ZIgOjsMSuMCcpYWBWBqqTvcABz82cbDLelSu6DKLl2c0pltqZY2oa3MLgT)11imluqmYIVEqS)imlHDpjHudVbzEjYc5LeledKqW(ryw2Uxjobnj0qgBZYdyz7EL4e0KqdzyW01vi82SuMCcpYWBqMxISyxjXcXajeSFeMLT7vItqtcnKX2S8aw2Uxjobnj0qggmDDfcVnlLjNWJm8gK5Lil2vsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZI)SObAIKjlLjNWJm8gK5Lil2RKyHyGec2pcZY2VRW8nKX2S8aw2(DfMVHmmy66keEBwktoHhz4niZlrwSxjXcXajeSFeMLT7vItqtcnKX2S8aw2Uxjobnj0qggmDDfcVnlLTpcpYWBqMxISq8kjwigiHG9JWSa9Ijgl0O57eMfIpXNLhWczUCwIbWl1IYcWcB)bnlLj(JyPm5eEKH3GmVezH4vsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZsz7i8idVbzEjYcXPKyHyGec2pcZc0lMySqJMVtywi(eFwEalK5YzjgaVulklalS9h0SuM4pILYKt4rgEdY8sKfItjXcXajeSFeMLT7vItqtcnKX2S8aw2Uxjobnj0qggmDDfcVnlLjNWJm8gK5Lil2xjXcXajeSFeMLT7vItqtcnKX2S8aw2Uxjobnj0qggmDDfcVnlLjNWJm8gK5LilLSsIfIbsiy)imlqVyIXcnA(oHzH4ZYdyHmxolWhKJEGKfGf2(dAwkt2rSu2ocpYWBqMxISqUDLeledKqW(rywGEXeJfA08DcZcXNLhWczUCwGpih9ajlalS9h0SuMSJyPm5eEKH3GmVezHCcUKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLYKt4rgEdY8sKfY1yjXcXajeSFeMLT7vItqtcnKX2S8aw2Uxjobnj0qggmDDfcVnlLjNWJm8gK5LilKt8kjwigiHG9JWSSDVsCcAsOHm2MLhWY29kXjOjHgYWGPRRq4TzPSDeEKH3GmVezHC7RKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLYKt4rgEdY8sKf72SKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLY2r4rgEdY8sKf7SRKyHyGec2pcZc0lMySqJMVtywi(S8awiZLZc8b5OhizbyHT)GMLYKDelLjNWJm8gK5Lil2rWLeledKqW(rywGEXeJfA08DcZcXNLhWczUCwGpih9ajlalS9h0SuMSJyPSDeEKH3GmVezXocUKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLYKt4rgEdY8sKf7iELeledKqW(ryw2Uxjobnj0qgBZYdyz7EL4e0KqdzyW01vi82SuMCcpYWBqMxISyhXPKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLYKt4rgEdY8sKf7kzLeledKqW(rywGEXeJfA08DcZcXNLhWczUCwGpih9ajlalS9h0SuMSJyPSDeEKH3GmVezXEBwsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZI)SObAIKjlLjNWJm8gK5Lil2J8sIfIbsiy)imlqVyIXcnA(oHzH4ZYdyHmxolWhKJEGKfGf2(dAwkt2rSuMCcpYWBWBqqTvcABz82cbDLelSu6DKLl2c0pltqZY2txP(9ETnlnA)RRrywOGyKfF9Gy)rywc7EscPgEdY8sKf7kjwigiHG9JWSa9Ijgl0O57eMfIplpGfYC5SaFqo6bswawy7pOzPmzhXszYj8idVbVbb1wjOTLXBle0vsSWsP3rwUylq)SmbnlBt)TzPr7FDncZcfeJS4Rhe7pcZsy3tsi1WBqMxISyxjXcXajeSFeMLT7vItqtcnKX2S8aw2Uxjobnj0qggmDDfcVnlLjoeEKH3GmVezXELeledKqW(ryw2Uxjobnj0qgBZYdyz7EL4e0KqdzyW01vi82SuMCcpYWBqMxISqWLeledKqW(ryw2Uxjobnj0qgBZYdyz7EL4e0KqdzyW01vi82SuMCcpYWBqMxISq8kjwigiHG9JWSSDVsCcAsOHm2MLhWY29kXjOjHgYWGPRRq4TzXFw0anrYKLYKt4rgEdY8sKfY3SKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLY2r4rgEdY8sKfYj4sIfIbsiy)imlB3ReNGMeAiJTz5bSSDVsCcAsOHmmy66keEBwktoHhz4niZlrwiN4vsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZszns4rgEdY8sKfYjoLeledKqW(ryw2Uxjobnj0qgBZYdyz7EL4e0KqdzyW01vi82SuMCcpYWBqMxISqU9vsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZszYj8idVbzEjYIDKxsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZszYj8idVbzEjYIDeCjXcXajeSFeMfOxmXyHgnFNWSq8z5bSqMlNf4dYrpqYcWcB)bnlLj7iwktWeEKH3GmVezXocUKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLYKt4rgEdY8sKf70yjXcXajeSFeMfOxmXyHgnFNWSq8z5bSqMlNf4dYrpqYcWcB)bnlLj7iwktoHhz4niZlrwStJLeledKqW(ryw2Uxjobnj0qgBZYdyz7EL4e0KqdzyW01vi82SuMCcpYWBqMxISyhXRKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLYKt4rgEdY8sKf7rEjXcXajeSFeMfOxmXyHgnFNWSq8z5bSqMlNf4dYrpqYcWcB)bnlLj7iwkBpcpYWBqMxISypYljwigiHG9JWSSDVsCcAsOHm2MLhWY29kXjOjHgYWGPRRq4TzPm5eEKH3GmVezXE2vsSqmqcb7hHzz7EL4e0KqdzSnlpGLT7vItqtcnKHbtxxHWBZszYj8idVbzEjYI9SxjXcXajeSFeMfOxmXyHgnFNWSq8z5bSqMlNf4dYrpqYcWcB)bnlLj7iwkBpcpYWBqMxISypcUKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLY2r4rgEdY8sKf7r8kjwigiHG9JWSSDVsCcAsOHm2MLhWY29kXjOjHgYWGPRRq4TzPSDeEKH3GmVezXEeNsIfIbsiy)imlB3ReNGMeAiJTz5bSSDVsCcAsOHmmy66keEBwkBhHhz4niZlrwSxjRKyHyGec2pcZY29kXjOjHgYyBwEalB3ReNGMeAiddMUUcH3MLYKt4rgEdEJXl2c0pcZcXJfp8hizrD0NA4nkGA1G5PWcOAOgYY4CLNbKfnzVoyEdnudzrtW7Wol2zpnZIDBAND8g8gAOgYcX29KesljEdnudzrtzzRWWimlqbkVzzCOhB4n0qnKfnLfIT7jjeML3Bs4xVjlbNIuwEalHObfwFVjHp1WBOHAilAkle0WyaeeMLvMyaPuVJYceVpxxHuwkFg0OzwSAesL(EtxnjKfnDmwSAeIH(EtxnjCKH3qd1qw0uw2keWbZIvJbN(xsIfcQ2)DwUjl3VnLLFhzXwdssSObb1zrrdVHgQHSOPSOj4eHSqmqcbqeYYVJSa1667PS4SOU)vilXGgzzQqcF6kKLY3KLOGfl7oCU9ZY(9SCpl0lEPEprWIQIYIT73zzCAIBT0SqawigQq6FUILTQoszmMVMz5(THzHs0znYWBOHAilAklAcorilXa6ZY2ZJ0(xBm2VKUnl0aMEFaklULLkklpGfDaLYY8iT)uwaPkQH3qd1qw0uwkDJ(ZsPbXilGjlJt57SmoLVZY4u(oloLfNfQfgoxXY3xse(gEdnudzrtzrt0ctSzP8zqJMzHGQ9FxZSqq1(VRzwG(EpVghXsSdJSedAKLgPN6W8z5bSGERoSzjaI19xtPV3VH3qd1qw0uwiUhHzPK3LWncZIgeBbSHDmMplHDmqeltqZcX0KSSOoj0WBWBOHAilBntW7pcZY4CLNbKLTsqitwcEYIoYYeSsyw8NL9)TOLezjRUR8mGAk9Idgs3VV0nhGSJZvEgqnf6ftmYgdB2)yvj)ZtHrQ7kpdO5j8ZBWB4H)aj1y1yaeR7FKeDjCJWvQ113t5n0qwk9oYceVpxxHSCuwO4ZYdyztwSD)oljGf67plGKLffz57ljcFQMzHCwSTJjl)oYY8A6ZcirwoklGKLff1ml2XYnz53rwOyaKWSCuw8eMf7XYnzrh87S4nYB4H)aj1y1yaeR7pbIKSq8(CDfQ50JXibzDrX63xse(AgIRwyKBYB4H)aj1y1yaeR7pbIKSq8(CDfQ50JXibzDrX63xse(AgyfPddRziUAHrsUMVzKFFjr4Bi3S706IIv91CQ97ljcFd5MaaOGb2sd8Q9)aP2i((sIW3qU5OMheJvWSgds63GfTgaj97v4pqs5n8WFGKASAmaI19NarswiEFUUc1C6XyKGSUOy97ljcFndSI0HH1mexTWiTtZ3mYVVKi8n2z2DADrXQ(Ao1(9LeHVXotaauWaBPbE1(FGuBeFFjr4BSZCuZdIXkywJbj9BWIwdGK(9k8hiP8gAilLEhPilFFjr4tzXBKLe8S4Rhe7)fCLkklW4JHhHzXPSaswwuKf67plFFjr4tnSWcu8zbI3NRRqwEalemloLLFhJYIROawseHzHAHHZvSS7jS6ssgEdp8hiPgRgdGyD)jqKKfI3NRRqnNEmgjiRlkw)(sIWxZaRiDyyndXvlmscwZ3ms0(xNLfcBUKg6176kSA)lp)vCfgHCbCyaT)1zzHWgm2kAJUQcA40ZaomG2)6SSqydfSuk8)ljv7LEuEdnKfO4tz53rwG(EtxnjKLaG(Smbnlk)XMLGRclL)hiPSuEcAwqc7XwkKfB7yYYdyH(E)SaVITUKel64e0ile3gZseLLPRuuwaZ5iEdp8hiPgRgdGyD)jqKKfI3NRRqnNEmgjLwda6RziUAHrAVnlvzY10nnKRXsrXVQdYf18h22zFvc2kmI3Wd)bsQXQXaiw3FcejzH4956kuZPhJrsN1aG(AgIRwyKACZsvMCnDtd5ASuu8R6GCrn)HTD2xLGTcJ4n0qwGIpLf)zX2(f2zXJbR8zbmzzRuccledKqaeHSq3blfml6illkcxsSqWBYIT73bRNfIHkK(NRybQ113tzXtywS3MSy7(DdVHh(dKuJvJbqSU)eisYcX7Z1vOMtpgJmasiaIWQtT0mexTWiT3MeG8nlvVsCcAsOjGkK(NRQuRRVNYB4H)aj1y1yaeR7pbIKSXaqs0L1jOJ5n8WFGKASAmaI19NarswBT)7AwDjwdWrs(MA(MrwgdQZIIg1k9UMiH)HbmOolkAUSsbkVhgWG6SOO5YQo43hgWG6SOOXZO1ej8pI3G3qdzHG0yWPpl2Xcbv7)olEcZIZc03B6QjHSaswGwAwSD)olB5iT)SqCDKfpHzzCGTwAwanlqFVNxJSa(DSTDuK3Wd)bsQbyHj2eisYAR9FxZ3mYYyqDwu0OwP31ej8pmGb1zrrZLvkq59WaguNffnxw1b)(WaguNffnEgTMiH)rATAeIHCJT2)DTry1ieJDgBT)78gE4pqsnalmXMarsw6798AuZQlXAaosnQ5Bgz5Yr0ReNGMeA0DLNbScMvxPQ)(LKOddreaqW0Z3KhP9VoDCyicQfQu13Bs4tn037PRurs(WqeVRW8nP)RgPvDx5zany66keE0WqzmOolkAOaL31ej8pmGb1zrrZLv1k9EyadQZIIMlR6GFFyadQZIIgpJwtKW)OrAJGIFvhKlQ5pSTZ(Q2zf4n8WFGKAawyInbIKS03B6QjHAwDjwdWrQrnFZil3ReNGMeA0DLNbScMvxPQ)(LKOAdaiy65BYJ0(xNoQLAHkv99Me(ud99E6kvKKpsBeu8R6GCrn)HTD2x1oRaVbVHgQHSObegdRhHzbHGDuw(lgz53rw8WdAwokloe)uUUcn8gE4pqsJKcuEx1rpM3Wd)bskbIKSbxPQE4pqwvh91C6XyKalmXwZ0VVWhj5A(Mr(xmsOY2vkp8hin2A)3nbN(1)Irc4H)aPH(EpVgnbN(1)IXr8gAilqXNYYwbAalGKf7rawSD)oy9Sa338zXtywSD)olqFVvGgMfpHzXocWc43X22rrEdp8hiPeisYcX7Z1vOMtpgJ8OvhGAgIRwyKuluPQV3KWNAOV3txPgJCTLJ4DfMVH(ERanSbtxxHWddVRW8n0hvkVRW9nFdMUUcHhnmqTqLQ(EtcFQH(EpDLAm74n0qwGIpLLGcDiil22XKfOV3ZRrwcEYY(9Syhby59Me(uwSTFHDwoklnQqiE(Smbnl)oYIgeuNffz5bSOJSy14e7gHzXtywSTFHDwMNsHnlpGLGtFEdp8hiPeisYcX7Z1vOMtpgJ8O1GcDiOMH4Qfgj1cvQ67nj8Pg6798ACmY5n0qwk56956kKLF3Fwc7yGikl3KLOGflEJSCjlolKcWS8awCiGdMLFhzHE)Y)dKSyBhBKfNLVVKi8zb)alhLLffHz5sw0X3gIjlbN(uEdp8hiPeisYcX7Z1vOMtpgJ8YkPaSMH4QfgPvJqQKcWgYnXaqoVghgSAesLua2qUHUY514WGvJqQKcWgYn03B6QjHddwncPskaBi3qFVNUsnmy1iKkPaSHCZC1rRGzfvRehgSAeIPDiycw06SXSerhg0xZPj41ldMgJ9lPrQVMttWRxgmWR2)dKddq8(CDfAoA1biVHgYY4trwgh2uSj6ssS4pl)oYcMWSaMSqCBmlruwSTJjl7o9rwoklUoacYcXBtIVMzXNp2SqmqcbqeYIT73zzCaV0S4jmlGFhBBhfzX297SqSTs2Xld8gE4pqsjqKKvhBk2eDjjnFZilxoIaacME(M8iT)1PJddreaafmWwAcGecGiS(7yLAD99uZYAyiIEL4e0KqJUR8mGvWS6kv93VKeDKw91CAcE9YGPXy)s6yKRrT6R500oemblAD2ywIOMgJ9lPeIG1graabtpFdem)9O9WqaabtpFdem)9OTw91CAcE9YGzzPvFnNM2HGjyrRZgZse1SS0wwFnNM2HGjyrRZgZse10ySFjLqrsUDAkbxQEL4e0Kqd9Y5sv3JsFSpFyqFnNMGxVmyAm2VKsiYjFyGCIp1cvQ6UtFKqKBiEJgPfI3NRRqZLvsbyEdnKfcc4zX297S4SqSTs2XldS87(ZYrZTFwCwiilf1BwSAqGfqZITDmz53rwMhP9NLJYIRdwplpGfmH5n8WFGKsGijRf4pqQ5Bgzz91CAcE9YGPXy)s6yKRrTLJOxjobnj0qVCUu19O0h7Zhg0xZPPDiycw06SXSernng7xsje5LmT6R500oemblAD2ywIOML1OHbDaLQDEK2)AJX(LuczNghPfI3NRRqZLvsbyEdnKfI5QWs5pszX2o(7yZYIEjjwigiHaiczjb2yX2PuS4kfWglrblwEal0)ukwco9z53rwOEmYIhdw5ZcyYcXajearibi2wj74Lbwco9P8gE4pqsjqKKfI3NRRqnNEmgzaKqaeHvyKgndAgIRwyKb8uLlpps7FTXy)sQMsUg10aaOGb2stWRxgmng7xshr8j3(2C0yb8uLlpps7FTXy)sQMsUg10aaOGb2staKqaeH1FhRuRRVNAAm2VKoI4tU9T5iTr0(bxriy(ghgMAqcF0NQTCebaqbdSLMGxVmyA0HJomeraauWaBPjasiaIW6VJvQ113tnn6WrhnmeaafmWwAcE9YGPXy)s6yx(yBbu(JW15rA)Rng7xshg6vItqtcnbuH0)CvLAD99uTbaqbdSLMGxVmyAm2VKoM92CyiaakyGT0eajeary93Xk1667PMgJ9lPJD5JTfq5pcxNhP9V2ySFjvtjFZHHicaiy65BYJ0(xNoYBOHSm(ueMLhWcmQ8OS87illQtczbmzHyBLSJxgyX2oMSSOxsIfyWsxHSaswwuKfpHzXQriy(SSOojKfB7yYINS4WWSGqW8z5OS46G1ZYdyb(qEdp8hiPeisYcX7Z1vOMtpgJmaxdGe((dKAgIRwyKLFVjHV5VyS(Gk8HJrUghgA)GRiemFJddtnxoMg3CK2YLr7FDwwiSbJTI2ORQGgo9mGAlhraabtpFdem)9O9WqaauWaBPbJTI2ORQGgo9mGMgJ9lPeICIhXHaL1yP6vItqtcn0lNlvDpk9X(8rJ0graauWaBPbJTI2ORQGgo9mGMgD4OJggq7FDwwiSHcwkf()LKQ9spQ2YreaqW0Z3KhP9VoDCyiaakyGT0qblLc))ss1EPhTApcwJ23MKBAm2VKsiYjNGhnmuoaakyGT0OJnfBIUKKPrho6WqeThqZ3aLAyiaGGPNVjps7FD64iTLJ4DfMVzU6OvWSIQvIgmDDfcpmeaqW0Z3abZFpARnaakyGT0mxD0kywr1krtJX(Lucro5eqJLQxjobnj0qVCUu19O0h7ZhgIiaGGPNVbcM)E0wBaauWaBPzU6OvWSIQvIMgJ9lPesFnNMGxVmyGxT)hija52vQEL4e0KqJvFXGg(Cv17GNxOATuuV1uYTBK2YO9Volle2Cjn0R31vy1(xE(R4kmc5cO2aaOGb2sZL0qVExxHv7F55VIRWiKlGMgJ9lPesJJggkxgT)1zzHWg6UddSHWvqRxbZ6d6ymFTbaqbdSLMh0Xy(iC9s6rA)R2tJA0E2rUPXy)s6OHHYLH4956k0aY6II1VVKi8JK8HbiEFUUcnGSUOy97ljc)iT3iTL)(sIW3qUPrhoAnaakyGTCy47ljcFd5MaaOGb2stJX(L0XU8X2cO8hHRZJ0(xBm2VKQPKV5OHbiEFUUcnGSUOy97ljc)iTtB5VVKi8n2zA0HJwdaGcgylhg((sIW3yNjaakyGT00ySFjDSlFSTak)r468iT)1gJ9lPAk5BoAyaI3NRRqdiRlkw)(sIWpYnhnAeVHgYsjxVpxxHSSOimlpGfyu5rzXZOS89LeHpLfpHzjatzX2oMSyZV)ssSmbnlEYIgSS2b95Sy1GaVHh(dKucejzH4956kuZPhJr(79PuvkIeHD1MFVMH4QfgzeuWsPFjS537tPQuejcBdMUUcHhgMhP9V2ySFjDm72CZHbDaLQDEK2)AJX(LuczNgjqzcEtnvFnNMFVpLQsrKiSn03devk7gnmOVMtZV3NsvPise2g67bIgZE2NMwUxjobnj0qVCUu19O0h7ZlLDJ4n0qwgFkYIgeBfTrxXIMydNEgqwSBtkgOSOJtqJS4SqSTs2XldSSOilGMfkGLF3FwUNfBNsXI6sKLLfl2UFNLFhzbtywatwiUnMLikVHh(dKucejzxuSEpgR50JXiXyROn6QkOHtpdOMVzKbaqbdSLMGxVmyAm2VKsi72uBaauWaBPjasiaIW6VJvQ113tnng7xsjKDBQTmeVpxxHMFVpLQsrKiSR287hg0xZP537tPQuejcBd99arJzVnjq5EL4e0Kqd9Y5sv3JsFSpVu2B0iTq8(CDfAUSskapmOdOuTZJ0(xBm2VKsi7rC4n0qwgFkYcuWsPW)ssSqqBPhLfIhfduw0XjOrwCwi2wj74LbwwuKfqZcfWYV7pl3ZITtPyrDjYYYIfB3VZYVJSGjmlGjle3gZseL3Wd)bskbIKSlkwVhJ1C6XyKuWsPW)VKuTx6r18nJSCaauWaBPj41ldMgJ9lPeI4PnIaacME(giy(7rBTreaqW0Z3KhP9VoDCyiaGGPNVjps7FD6O2aaOGb2staKqaeH1FhRuRRVNAAm2VKsiIN2Yq8(CDfAcGecGiScJ0OzyyiaakyGT0e86LbtJX(Lucr8gnmeaqW0Z3abZFpARTCe9kXjOjHg6LZLQUhL(yFU2aaOGb2stWRxgmng7xsjeXByqFnNM2HGjyrRZgZse10ySFjLqKVjbkRXsH2)6SSqyZL0VxHh00k8b5sSQJk1iT6R500oemblAD2ywIOML1OHbDaLQDEK2)AJX(LuczNghgq7FDwwiSbJTI2ORQGgo9mGAdaGcgylnySv0gDvf0WPNb00ySFjDm72CKwiEFUUcnxwjfG1gbA)RZYcHnxsd96DDfwT)LN)kUcJqUaomeaafmWwAUKg6176kSA)lp)vCfgHCb00ySFjDm72CyqhqPANhP9V2ySFjLq2TjVHgYYwv28OuwwuKLXRKtnjl2UFNfITvYoEzGfqZI)S87ilycZcyYcXTXSer5n8WFGKsGijleVpxxHAo9ymYZ(HRbqcF)bsndXvlms91CAcE9YGPXy)s6yKRrTLJOxjobnj0qVCUu19O0h7Zhg0xZPPDiycw06SXSernng7xsjuKKRrJgjqz7z0yP0xZPrxbaWQf9nlRreOmbB0OMApJglL(Aon6kaawTOVzznQuO9Volle2Cj97v4bnTcFqUeR6Osrac2OXsvgT)1zzHWMFhRZRPFLEKoL2aaOGb2sZVJ1510VspsNY0ySFjLqrA3MJ0QVMtt7qWeSO1zJzjIAwwJgg0buQ25rA)Rng7xsjKDACyaT)1zzHWgm2kAJUQcA40ZaQnaakyGT0GXwrB0vvqdNEgqtJX(LuEdp8hiPeisYUOy9EmwZPhJrEjn0R31vy1(xE(R4kmc5cOMVzKq8(CDfAo7hUgaj89hi1cX7Z1vO5YkPamVHgYY4trwGU7WaBimlAITol64e0ileBRKD8YaVHh(dKucejzxuSEpgR50JXiP7omWgcxbTEfmRpOJX818nJSCaauWaBPj41ldMgD4OAJiaGGPNVjps7FD6OwiEFUUcn)EFkvLIiryxT53RTCaauWaBPrhBk2eDjjtJoC0HHiApGMVbk1OHHaacME(M8iT)1PJAdaGcgylnbqcbqew)DSsTU(EQPrhoQ2Yq8(CDfAcGecGiScJ0OzyyiaakyGT0e86LbtJoC0rJ0cdEdDLZRrZFbIUKK2YWG3qFuP8UovEJM)ceDjPHHiExH5BOpQuExNkVrdMUUcHhgOwOsvFVjHp1qFVNxJJzVrAHbVjgaY51O5VarxssBziEFUUcnhT6aCyOxjobnj0O7kpdyfmRUsv)9ljrhgC63UQAbSH9yrwY2CyaI3NRRqtaKqaeHvyKgnddd6R50ORaay1I(ML1iTrG2)6SSqyZL0qVExxHv7F55VIRWiKlGddO9Volle2Cjn0R31vy1(xE(R4kmc5cO2aaOGb2sZL0qVExxHv7F55VIRWiKlGMgJ9lPJzVn1gH(AonbVEzWSSgg0buQ25rA)Rng7xsjebVjVHgYsP3pklhLfNL2)DSzbvUoO9hzXMhLLhWsSteYIRuSaswwuKf67plFFjr4tz5bSOJSOUeHzzzXIT73zHyBLSJxgyXtywigiHaiczXtywwuKLFhzXUeMfQc8SaswcWSCtw0b)olFFjr4tzXBKfqYYIISqF)z57ljcFkVHh(dKucejzxuSEpgt1mvbEAKFFjr4tUMVzKq8(CDfAazDrX63xse(rej5AJ47ljcFJDMgD4O1aaOGb2YHHYq8(CDfAazDrX63xse(rs(WaeVpxxHgqwxuS(9LeHFK2BK2Y6R50e86LbZYsBaabtpFdem)9OT2Y6R500oemblAD2ywIOMgJ9lPeOS9mASu9kXjOjHg6LZLQUhL(yF(icf53xse(gYn6R5ScVA)pqQvFnNM2HGjyrRZgZse1SSgg0xZPPDiycw06SXSerR0lNlvDpk9X(CZYA0WqaauWaBPj41ldMgJ9lPeWUX((sIW3qUjaakyGT0aVA)pqQTCe9kXjOjHgR(Ibn85QQ3bpVq1APOEpmOVMttWRxgmng7xshJ4nsB5icaiy65BYJ0(xNoom89LeHVHCtaauWaBPbE1(FGCSaaOGb2staKqaeH1FhRuRRVNAAm2VKomaX7Z1vOjasiaIWkmsJMbTFFjr4Bi3eaafmWwAGxT)hihlaakyGT0e86LbtJX(L0rAJiaGGPNVHOO955WqaabtpFtEK2)60rTq8(CDfAcGecGiScJ0OzqBaauWaBPjasiaIW6VJvQ113tnllTreaafmWwAcE9YGzzPTCz91CAWG6SOyvTsVnng7xshtJdd6R50Gb1zrXkfO820ySFjDmnoA0WG(AoneDjCJWvm2cyd7ym)kMyt6kbAwwJggMhP9V2ySFjLq2T5WaeVpxxHgqwxuS(9LeHFKBYB4H)ajLars2ffR3JXuntvGNg53xse(2P5BgjeVpxxHgqwxuS(9LeHFerAN2i((sIW3qUPrhoAnaakyGTCyaI3NRRqdiRlkw)(sIWps70wwFnNMGxVmywwAdaiy65BGG5VhT1wwFnNM2HGjyrRZgZse10ySFjLaLTNrJLQxjobnj0qVCUu19O0h7ZhrOi)(sIW3yNrFnNv4v7)bsT6R500oemblAD2ywIOML1WG(AonTdbtWIwNnMLiALE5CPQ7rPp2NBwwJggcaGcgylnbVEzW0ySFjLa2n23xse(g7mbaqbdSLg4v7)bsTLJOxjobnj0y1xmOHpxv9o45fQwlf17Hb91CAcE9YGPXy)s6yeVrAlhraabtpFtEK2)60XHHVVKi8n2zcaGcgylnWR2)dKJfaafmWwAcGecGiS(7yLAD99utJX(L0HbiEFUUcnbqcbqewHrA0mO97ljcFJDMaaOGb2sd8Q9)a5ybaqbdSLMGxVmyAm2VKosBebaem98nefTpp1woc91CAcE9YGzznmeraabtpFdem)9O9OHHaacME(M8iT)1PJAH4956k0eajearyfgPrZG2aaOGb2staKqaeH1FhRuRRVNAwwAJiaakyGT0e86LbZYsB5Y6R50Gb1zrXQALEBAm2VKoMghg0xZPbdQZIIvkq5TPXy)s6yAC0Ordd6R50q0LWncxXylGnSJX8RyInPReOzznmmps7FTXy)skHSBZHbiEFUUcnGSUOy97ljc)i3K3qdzz8PiLfxPyb87yZcizzrrwUhJPSaswcW8gE4pqsjqKKDrX69ymL3qdzrdUFhBwiby5YhWYVJSqFwanloazXd)bswuh95n8WFGKsGijBVYQh(dKv1rFnNEmgPdqnt)(cFKKR5BgjeVpxxHMJwDaYB4H)ajLars2ELvp8hiRQJ(Ao9yms6ZBWBOHSqmxfwk)rkl22XFhBw(DKfnzJECW)Wo2SOVMtwSDkfltxPybmNSy7(9lz53rwsKWplbN(8gE4pqsnoaJeI3NRRqnNEmgjCJEC12Pu1PRuvWCQziUAHr2ReNGMeA(lgTb6Sc3OhRFjm2AlRVMtZFXOnqNv4g9y9lHX20ySFjLqKcWMyNWeytd5dd6R508xmAd0zfUrpw)sySnng7xsjKh(dKg6798A0GegdRhR)fJeytd5AlJb1zrrZLv1k9EyadQZIIgkq5Dnrc)ddyqDwu04z0AIe(hnsR(Aon)fJ2aDwHB0J1VegBZYI3qdzHyUkSu(JuwSTJ)o2Sa99MUAsilhLfBG(3zj40)ssSaGGnlqFVNxJSCjlK5k9MfniOolkYB4H)aj14aKarswiEFUUc1C6XyKhPe0yL(EtxnjuZqC1cJmcmOolkAUSsbkV1sTqLQ(EtcFQH(EpVghJ4OPVRW8nuWsvbZ6VJ1jOr6BW01viCPSJayqDwu0Czvh87AJOxjobnj0y1xmOHpxv9o45fQwlf1BTr0ReNGMeAaj(70AqHExHC0dK8gAilJpfzHyGecGiKfB7yYI)SOqkLLF3tw04MSSvkbHfpHzrDjYYYIfB3VZcX2kzhVmWB4H)aj14aKars2aiHaicR)owPwxFpvZ3mYiG71bBsqnat1wUmeVpxxHMaiHaicRWinAg0graauWaBPj41ldMgD4OAJOxjobnj0y1xmOHpxv9o45fQwlf17Hb91CAcE9YGzzPTCe9kXjOjHgR(Ibn85QQ3bpVq1APOEpm0ReNGMeAcOcP)5Qk1667PddZJ0(xBm2VKog52rCgg0buQ25rA)Rng7xsjuaauWaBPj41ldMgJ9lPeG8nhg0xZPj41ldMgJ9lPJrUDJgPTC5Yo9BxvTa2WMqrcX7Z1vOjasiaIWQtTggOwOsvFVjHp1qFVNxJJzVrAlRVMtdguNffRQv6TPXy)s6yKV5WG(AonyqDwuSsbkVnng7xshJ8nhnmOVMttWRxgmng7xshtJA1xZPj41ldMgJ9lPeksYTBK2Yr8UcZ3qFuP8Uc338hg0xZPH(EpDLY0ySFjLqKB0OMUPrJLQxjobnj0eqfs)ZvvQ113thg0xZPj41ldMgJ9lPesFnNg6790vktJX(LucOrT6R50e86LbZYAK2Yr0ReNGMeA(lgTb6Sc3OhRFjm2ddr0ReNGMeAcOcP)5Qk1667Pdd6R508xmAd0zfUrpw)sySnng7xshdjmgwpw)lghnm0ReNGMeA0DLNbScMvxPQ)(LKOJ0woIEL4e0KqJUR8mGvWS6kv93VKeDyOS(Aon6UYZawbZQRu1F)ss0A6)Qrd99arrAFdd6R50O7kpdyfmRUsv)9ljrREh8en03defP9nA0WGoGs1ops7FTXy)skHiFtTreaafmWwAcE9YGPrho6iEdnKLXNISaDLZRrwUKflpHX4lWcizXZO)(LKy539Nf1bbPSqobtXaLfpHzrHukl2UFNLyqJS8EtcFklEcZI)S87ilycZcyYIZcuGYBw0GG6SOil(Zc5emlumqzb0SOqkLLgJ9lVKeloLLhWscEw2DixsILhWsJZgP7SaV6ljXczUsVzrdcQZII8gE4pqsnoajqKKLUY51OMdrdkS(EtcFAKKR5Bgz5gNns3DDfomOVMtdguNffRuGYBtJX(LuczpTyqDwu0CzLcuERTXy)skHiNG1(UcZ3qblvfmR)owNGgPVbtxxHWJ0(EtcFZFXy9bv4dhJCcwtPwOsvFVjHpLang7xs1wgdQZIIMlREgDyOXy)skHifGnXoHhXBOHSm(uKfORCEnYYdyz3HGS4Sqsb0DflpGLffzz8k5utYB4H)aj14aKarsw6kNxJA(MrcX7Z1vO5SF4AaKW3FGuBaauWaBP5sAOxVRRWQ9V88xXvyeYfqtJoCuTO9Volle2Cjn0R31vy1(xE(R4kmc5cOw3Qg2Xar8gAilL8q0ILLflqFVNUsXI)S4kfl)fJuwwPcPuww0ljXczgn4TtzXtywUNLJYIRdwplpGfRgeyb0SOWNLFhzHAHHZvS4H)ajlQlrw0rfWgl7EcRqw0Kn6X6xcJnlGKf7y59Me(uEdp8hiPghGeisYsFVNUsP5BgzeVRW8n0hvkVRW9nFdMUUcH1wock(vDqUOM)W2o7RsWwHHbmOolkAUS6z0HbQfQu13Bs4tn037PRuJzVrAlRVMtd99E6kLPXzJ0DxxHAltTqLQ(EtcFQH(EpDLIq2ByiIEL4e0KqZFXOnqNv4g9y9lHXE0WW7kmFdfSuvWS(7yDcAK(gmDDfcRvFnNgmOolkwPaL3MgJ9lPeYEAXG6SOO5YkfO8wR(Aon037PRuMgJ9lPeI4OLAHkv99Me(ud99E6k1yrsWJ0woIEL4e0KqJkAWBNwNke)ljvjPUylkom8xms8j(eSghtFnNg6790vktJX(Lucy3iTV3KW38xmwFqf(WX0iVHgYcb197Sa9rLYBw0K9nFwwuKfqYsaMfB7yYsJZgP7UUczrF9Sq)tPyXMFpltqZczgn4TtzXQbbw8eMfyqU9ZYIISOJtqJSqmnj1Wc0)ukwwuKfDCcAKfIbsiaIqwOxgqw(D)zX2PuSy1GalEc(DSzb6790vkEdp8hiPghGeisYsFVNUsP5Bg57kmFd9rLY7kCFZ3GPRRqyT6R50qFVNUszAC2iD31vO2YrqXVQdYf18h22zFvc2kmmGb1zrrZLvpJomqTqLQ(EtcFQH(EpDLAmcEK2Yr0ReNGMeAurdE706uH4FjPkj1fBrXHH)IrIpXNG14ye8iTV3KW38xmwFqf(WXShVHgYcb197SOjB0J1VegBwwuKfOV3txPy5bSqeIwSSSy53rw0xZjl6rzXvuall6LKyb6790vkwajlAKfkgajmLfqZIcPuwAm2V8ss8gE4pqsnoajqKKL(EpDLsZ3mYEL4e0KqZFXOnqNv4g9y9lHXwl1cvQ67nj8Pg6790vQXI0EAlhH(Aon)fJ2aDwHB0J1VegBZYsR(Aon037PRuMgNns3DDfomugI3NRRqdCJEC12Pu1PRuvWCQTS(Aon037PRuMgJ9lPeYEdduluPQV3KWNAOV3txPgZoTVRW8n0hvkVRW9nFdMUUcH1QVMtd99E6kLPXy)skH04OrJ4n0qwiMRclL)iLfB74VJnlolqFVPRMeYYIISy7ukwc(IISa99E6kflpGLPRuSaMtnZINWSSOilqFVPRMeYYdyHieTyrt2OhRFjm2SqFpqellldl23MSCuw(DKLgT)11imlBLsqy5bSeC6Zc03B6QjHea6790vkEdp8hiPghGeisYcX7Z1vOMtpgJK(EpDLQAdKFD6kvfmNAgIRwyKo9BxvTa2WEm7BZsvMCnLIFvhKlQ5pSTZ(Q2zfk1Mg7gvQYKRP6R508xmAd0zfUrpw)sySn03devQnnKpstlRVMtd99E6kLPXy)sAPShXNAHkvD3PpwQiExH5BOpQuExH7B(gmDDfcpstlhaafmWwAOV3txPmng7xslL9i(uluPQ7o9Xs9UcZ3qFuP8Uc338ny66keEKMwwFnNM5QJwbZkQwjAAm2VKwknosBz91CAOV3txPmlRHHaaOGb2sd99E6kLPXy)s6iEdnKLXNISa99MUAsil2UFNfnzJES(LWyZYdyHieTyzzXYVJSOVMtwSD)oy9SOa0ljXc037PRuSSS(lgzXtywwuKfOV30vtczbKSqWeGLXb2APzH(EGiklR8pflemlV3KWNYB4H)aj14aKarsw67nD1KqnFZiH4956k0a3OhxTDkvD6kvfmNAH4956k0qFVNUsvTbYVoDLQcMtTraX7Z1vO5iLGgR03B6QjHddL1xZPr3vEgWkywDLQ(7xsIwt)xnAOVhiAm7nmOVMtJUR8mGvWS6kv93VKeT6DWt0qFpq0y2BKwQfQu13Bs4tn037PRueIG1cX7Z1vOH(EpDLQAdKFD6kvfmN8gAilJpfzHAZ7ywOaw(D)zjkyXcj8zj2jmllR)Irw0JYYIEjjwUNfNYIYFKfNYIfGspDfYcizrHukl)UNSypwOVhiIYcOzPKJf9zX2oMSypcWc99aruwqcBDnYB4H)aj14aKarswh2T(dcwP28owZHObfwFVjHpnsY18nJmI)ceDjjTr4H)aPXHDR)GGvQnVJRWEStcnxwNQJ0(pmadEJd7w)bbRuBEhxH9yNeAOVhiIq2tlm4noSB9heSsT5DCf2JDsOPXy)skHShVHgYcbnC2iDNfnbaiNxJSCtwi2wj74Lbwokln6Wr1ml)o2ilEJSOqkLLF3tw0ilV3KWNYYLSqMR0Bw0GG6SOil2UFNfOGN4QzwuiLYYV7jlKVjlGFhBBhfz5sw8mklAqqDwuKfqZYYILhWIgz59Me(uw0XjOrwCwiZv6nlAqqDwu0WIMeKB)S04Sr6olWR(ssSuY7s4gHzrdITa2WogZNLvQqkLLlzbkq5nlAqqDwuK3Wd)bsQXbibIKSXaqoVg1CiAqH13Bs4tJKCnFZiBC2iD31vO23Bs4B(lgRpOcF4yLltobtGYuluPQV3KWNAOV3ZRXszxP0xZPbdQZIIv1k92SSgnIang7xshr8ltobExH5BEBxwJbGKAW01vi8iTo9BxvTa2WEmiEFUUcn0znaOVMQVMtd99E6kLPXy)sAPiEAl7w1WogiAyaI3NRRqZrkbnwPV30vtchgIadQZIIMlREgDK2YbaqbdSLMGxVmyA0HJQfdQZIIMlREgvBeW96GnjOgGPAldX7Z1vOjasiaIWkmsJMHHHaaOGb2staKqaeH1FhRuRRVNAA0HJomeraabtpFtEK2)60XrdduluPQV3KWNAOV3ZRrcvUS9PPL1xZPbdQZIIv1k92SSkL9gnQuLjNaVRW8nVTlRXaqsny66keE0iTrGb1zrrdfO8UMiHFTLJiaakyGT0e86LbtJoC0Hb4EDWMeudW0rddLXG6SOO5YkfO8EyqFnNgmOolkwvR0BZYsBeVRW8nuWsvbZ6VJ1jOr6BW01vi8iTLPwOsvFVjHp1qFVNxJeI8nlvzYjW7kmFZB7YAmaKudMUUcHhnAK2YreaqW0Z3qu0(8Cyic91CAi6s4gHRySfWg2Xy(vmXM0vc0SSggWG6SOO5YkfO8EK2i0xZPPDiycw06SXSerR0lNlvDpk9X(CZYI3qdzz8PilexWwybKSeGzX297G1ZsWTSUKeVHh(dKuJdqcejzNGoGvWSM(VAuZ3ms3Qg2Xarddq8(CDfAosjOXk99MUAsiVHh(dKuJdqcejzH4956kuZPhJrgGRbqcF)bYQdqndXvlmYiG71bBsqnat1wgI3NRRqtaUgaj89hi1wwFnNg6790vkZYAy4DfMVH(Os5DfUV5BW01vi8WqaabtpFtEK2)60XrAHbVjgaY51O5VarxssB5i0xZPHcu0)cOzzPnc91CAcE9YGzzPTCeVRW8nZvhTcMvuTs0GPRRq4Hb91CAcE9YGbE1(FGCSaaOGb2sZC1rRGzfvRenng7xsjG9nsB5iO4x1b5IA(dB7SVQDwHHbmOolkAUSQwP3ddyqDwu0qbkVRjs4FKwiEFUUcn)EFkvLIiryxT53RTCebaem98n5rA)RthhgG4956k0eajearyfgPrZWWqaauWaBPjasiaIW6VJvQ113tnng7xsje5ACK23Bs4B(lgRpOcF4y6R50e86Lbd8Q9)azP20qCgnmOdOuTZJ0(xBm2VKsi91CAcE9YGbE1(FGKaKBxP6vItqtcnw9fdA4ZvvVdEEHQ1sr9EeVHgYY4trwiUnMLikl2UFNfITvYoEzG3Wd)bsQXbibIKSTdbtWIwNnMLiQMVzK6R50e86LbtJX(L0XixJdd6R50e86Lbd8Q9)ajbi3Us1ReNGMeAS6lg0WNRQEh88cvRLI6nHSJ4PfI3NRRqtaUgaj89hiRoa5n0qwgFkYcX2kzhVmWcizjaZYkviLYINWSOUez5EwwwSy7(DwigiHaic5n8WFGKACasGijBavi9pxvD1rkJX818nJeI3NRRqtaUgaj89hiRoa1woIaacME(giy(7r7HHi6vItqtcn0lNlvDpk9X(8HHEL4e0KqJvFXGg(Cv17GNxOATuuVhg0xZPj41ldg4v7)bYXI0oI3OHb91CAAhcMGfToBmlruZYsR(AonTdbtWIwNnMLiQPXy)skHixJgnYB4H)aj14aKars2ldEN(FGuZ3msiEFUUcnb4AaKW3FGS6aK3qdzz8PilAqSfWg2SmoqcZcizjaZIT73zb6790vkwwwS4jmluhcYYe0SqqwkQ3S4jmleBRKD8YaVHh(dKuJdqcejzXylGnSR6GewZ3mYYbaqbdSLMGxVmyAm2VKsa91CAcE9YGbE1(FGKa9kXjOjHgR(Ibn85QQ3bpVq1APOExkYTBSaaOGb2sdgBbSHDvhKWg4v7)bscq(MJgg0xZPj41ldMgJ9lPJzFddW96GnjOgGP8gAile0WzJ0DwMkVrwajlllwEal2JL3Bs4tzX297G1ZcX2kzhVmWIoEjjwCDW6z5bSGe26AKfpHzjbplaiyhClRljXB4H)aj14aKarsw6JkL31PYBuZHObfwFVjHpnsY18nJSXzJ0DxxHA)lgRpOcF4yKRrTuluPQV3KWNAOV3ZRrcrWADRAyhdePTS(AonbVEzW0ySFjDmY3Cyic91CAcE9YGzznI3qdzz8PilexGgWYnz5s6bJS4jlAqqDwuKfpHzrDjYY9SSSyX297S4SqqwkQ3Sy1GalEcZYwHDR)GGSa1M3X8gE4pqsnoajqKKDU6OvWSIQvIA(MrIb1zrrZLvpJQTSBvd7yGOHHi6vItqtcnw9fdA4ZvvVdEEHQ1sr9EK2Y6R50y1xmOHpxv9o45fQwlf1BdexTqczNg3CyqFnNMGxVmyAm2VKoM9nsBzyWBCy36piyLAZ74kSh7KqZFbIUK0Wqebaem98njgAGc0WdduluPQV3KWNoMDJ0wwFnNM2HGjyrRZgZse10ySFjLqLmnTmbxQEL4e0Kqd9Y5sv3JsFSpFKw91CAAhcMGfToBmlruZYAyic91CAAhcMGfToBmlruZYAK2YreaafmWwAcE9YGzznmOVMtZV3NsvPise2g67bIie5Au78iT)1gJ9lPeYUn3u78iT)1gJ9lPJr(MBomebfSu6xcB(9(uQkfrIW2GPRRq4rAltblL(LWMFVpLQsrKiSny66keEyiaakyGT0e86LbtJX(L0XS3MJ0(EtcFZFXy9bv4dhtJdd6akv78iT)1gJ9lPeI8n5n0qwgFkYIZc037PRuSOjM4VZIvdcSSsfsPSa99E6kflhLfx1OdhLLLflGMLOGflEJS46G1ZYdybab7GBXYwPeeEdp8hiPghGeisYsFVNUsP5BgP(AonGe)DA1c7aA9hinllTL1xZPH(EpDLY04Sr6URRWHbN(TRQwaBypwjBZr8gAilAYvSflBLsqyrhNGgzHyGecGiKfB3VZc037PRuS4jml)oMSa99MUAsiVHh(dKuJdqcejzPV3txP08nJmaGGPNVjps7FD6O2iExH5BOpQuExH7B(gmDDfcRTmeVpxxHMaiHaicRWinAgggcaGcgylnbVEzWSSgg0xZPj41ldML1iTbaqbdSLMaiHaicR)owPwxFp10ySFjLqKcWMyNWLkGNQSt)2vvlGnSj(q8(CDfAOZAaq)rA1xZPH(EpDLY0ySFjLqeS2iG71bBsqnat5n8WFGKACasGijl99MUAsOMVzKbaem98n5rA)Rth1wgI3NRRqtaKqaeHvyKgndddbaqbdSLMGxVmywwdd6R50e86LbZYAK2aaOGb2staKqaeH1FhRuRRVNAAm2VKsinQfI3NRRqd99E6kv1gi)60vQkyo1Ib1zrrZLvpJQnciEFUUcnhPe0yL(EtxnjuBeW96GnjOgGP8gAilJpfzb67nD1KqwSD)olEYIMyI)olwniWcOz5MSefS2gMfaeSdUflBLsqyX297SefSAwsKWplbN(gw2QIcybEfBXYwPeew8NLFhzbtywatw(DKLsUy(7rBw0xZjl3KfOV3txPyXgyPGZTFwMUsXcyozb0SefSyXBKfqYIDS8EtcFkVHh(dKuJdqcejzPV30vtc18nJuFnNgqI)oTguO3vih9aPzznmuoc6798A04w1WogisBeq8(CDfAosjOXk99MUAs4Wqz91CAcE9YGPXy)skH0Ow91CAcE9YGzznmuUS(AonbVEzW0ySFjLqKcWMyNWLkGNQSt)2vvlGnSj(q8(CDfAO0Aaq)rA1xZPj41ldML1WG(AonTdbtWIwNnMLiALE5CPQ7rPp2NBAm2VKsisbytSt4sfWtv2PF7QQfWg2eFiEFUUcnuAnaO)iT6R500oemblAD2ywIOv6LZLQUhL(yFUzznsBaabtpFdem)9O9OrAltTqLQ(EtcFQH(EpDLIq2ByaI3NRRqd99E6kv1gi)60vQkyohnsBeq8(CDfAosjOXk99MUAsO2Yr0ReNGMeA(lgTb6Sc3OhRFjm2dduluPQV3KWNAOV3txPiK9gXBOHSm(uKfnbaiPSCjlqbkVzrdcQZIIS4jmluhcYcXDPuSOjaajltqZcX2kzhVmWB4H)aj14aKars2eTvJbGuZ3mYY6R50Gb1zrXkfO820ySFjDmKWyy9y9VyCyOCy3Bsins702yy3Bsy9VyKqAC0Wqy3Bsins7nsRBvd7yGiEdp8hiPghGeisYU7QzngasnFZilRVMtdguNffRuGYBtJX(L0XqcJH1J1)IXHHYHDVjH0iTtBJHDVjH1)IrcPXrddHDVjH0iT3iTUvnSJbI0wwFnNM2HGjyrRZgZse10ySFjLqAuR(AonTdbtWIwNnMLiQzzPnIEL4e0Kqd9Y5sv3JsFSpFyic91CAAhcMGfToBmlruZYAeVHh(dKuJdqcejzNlLQgdaPMVzKL1xZPbdQZIIvkq5TPXy)s6yiHXW6X6FXO2YbaqbdSLMGxVmyAm2VKoMg3CyiaakyGT0eajeary93Xk1667PMgJ9lPJPXnhnmuoS7njKgPDABmS7njS(xmsinoAyiS7njKgP9gP1TQHDmqK2Y6R500oemblAD2ywIOMgJ9lPesJA1xZPPDiycw06SXSernllTr0ReNGMeAOxoxQ6Eu6J95ddrOVMtt7qWeSO1zJzjIAwwJ4n0qwgFkYcbfqdybKSqmnjVHh(dKuJdqcejzT5DFGUcMvuTsK3qdzHyUkSu(JuwSTJ)o2S8awwuKfOV3ZRrwUKfOaL3SyB)c7SCuw8NfnYY7nj8PeGCwMGMfec2rzXUnj(Se70h7OSaAwiywG(EtxnjKfni2cyd7ymFwOVhiIYB4H)aj14aKarswiEFUUc1C6XyK03751y9YkfO8wZqC1cJKAHkv99Me(ud99EEnogbtGPca6YXo9XoAfIRwyPiFZnj(2T5icmvaqxwFnNg67nD1KWkgBbSHDmMFLcuEBOVhiI4tWJ4n0qw0etwSJL3Bs4tzX297G1ZcuWsXcyYYVJSqCbnsFwIcwSq3blfmlZtPyX297Sqq1(VZc8QVKelJxg4n8WFGKACasGijRT2)DnFZiJqFnNM2HGjyrRZgZse1SS0gH(AonTdbtWIwNnMLiALE5CPQ7rPp2NBwwAJ4DfMVHcwQkyw)DSobnsFdMUUcH1sTqLQ(EtcFQH(EpVgjK90QVMtdguNffRuGYBtJX(L0XqcJH1J1)IrTZJ0(xBm2VKoM(AonbVEzW0ySFjLaKBxP6vItqtcnw9fdA4ZvvVdEEHQ1sr9M3qdzHyUkSu(JuwSTJ)o2S8awiOA)3zbE1xsIfIBJzjIYB4H)aj14aKarswiEFUUc1C6XyK2A)3RxwNnMLiQMH4Qfgj5eFQfQu1DN(iHSttlVPXUsvMAHkv99Me(ud99EEnQPKpQuLjNaVRW8nuWsvbZ6VJ1jOr6BW01viCPi3OXrJiWMgY1yP0xZPPDiycw06SXSernng7xs5n0qwgFkYcbv7)olxYcuGYBw0GG6SOilGMLBYscyb6798AKfBNsXY8EwU8bSqSTs2XldS4z0yqJ8gE4pqsnoajqKK1w7)UMVzKLXG6SOOrTsVRjs4FyadQZIIgpJwtKWVwiEFUUcnhTguOdbhPT87nj8n)fJ1huHpCmcEyadQZIIg1k9UEz1UHbDaLQDEK2)AJX(Lucr(MJgg0xZPbdQZIIvkq5TPXy)skH8WFG0qFVNxJgKWyy9y9VyuR(AonyqDwuSsbkVnlRHbmOolkAUSsbkV1gbeVpxxHg6798ASEzLcuEpmOVMttWRxgmng7xsjKh(dKg6798A0GegdRhR)fJAJaI3NRRqZrRbf6qqT6R50e86LbtJX(LucHegdRhR)fJA1xZPj41ldML1WG(AonTdbtWIwNnMLiQzzPfI3NRRqJT2)96L1zJzjIomebeVpxxHMJwdk0HGA1xZPj41ldMgJ9lPJHegdRhR)fJ8gAilJpfzb6798AKLBYYLSqMR0Bw0GG6SOOMz5swGcuEZIgeuNffzbKSqWeGL3Bs4tzb0S8awSAqGfOaL3SObb1zrrEdp8hiPghGeisYsFVNxJ8gAilexxP(9EXB4H)aj14aKars2ELvp8hiRQJ(Ao9ymYPRu)EV4n4n0qwG(EtxnjKLjOzjgabJX8zzLkKszzrVKelJdS1sZB4H)aj1mDL637vK03B6QjHA(MrgrVsCcAsOr3vEgWkywDLQ(7xsIAq7FDwwimVHgYcXC6ZYVJSadEwSD)ol)oYsmG(S8xmYYdyXHHzzL)Py53rwIDcZc8Q9)ajlhLL97nSaDLZRrwAm2VKYs8s9NL6qywEalX(h2zjgaY51ilWR2)dK8gE4pqsntxP(9ErGijlDLZRrnhIguy99Me(0ijxZ3msyWBIbGCEnAAm2VKowJX(L0szNDeFYTpEdp8hiPMPRu)EViqKKngaY51iVbVHgYY4trw2kSB9heKfO28oMfB7yYYVJnYYrzjbS4H)GGSqT5DSMzXPSO8hzXPSybO0txHSaswO28oMfB3VZIDSaAwMOnSzH(EGiklGMfqYIZI9ialuBEhZcfWYV7pl)oYsI2yHAZ7yw8UpiiLLsow0NfF(yZYV7pluBEhZcsyRRrkVHh(dKud9J0HDR)GGvQnVJ1CiAqH13Bs4tJKCnFZiJag8gh2T(dcwP28oUc7Xoj08xGOljPncp8hinoSB9heSsT5DCf2JDsO5Y6uDK2FTLJag8gh2T(dcwP28oUUJUY8xGOljnmadEJd7w)bbRuBEhx3rxzAm2VKoMghnmadEJd7w)bbRuBEhxH9yNeAOVhiIq2tlm4noSB9heSsT5DCf2JDsOPXy)skHSNwyWBCy36piyLAZ74kSh7KqZFbIUKeVHgYY4trkledKqaeHSCtwi2wj74Lbwoklllwanlrblw8gzbgPrZWLKyHyBLSJxgyX297SqmqcbqeYINWSefSyXBKfDubSXcbVjzT3MLjgQq6FUIfOwxFpDelBLsqy5swCwiFtcWcfdSObb1zrrdlBvrbSadYTFwu4ZIMSrpw)sySzbjS11OMzXv28OuwwuKLlzHyBLSJxgyX297SqqwkQ3S4jml(ZYVJSqFVFwatwCwghyRLMfBxcdSz4n8WFGKAOpbIKSbqcbqew)DSsTU(EQMVzKra3Rd2KGAaMQTCziEFUUcnbqcbqewHrA0mOnIaaOGb2stWRxgmn6Wr1grVsCcAsOXQVyqdFUQ6DWZluTwkQ3dd6R50e86LbZYsB5i6vItqtcnw9fdA4ZvvVdEEHQ1sr9EyOxjobnj0eqfs)ZvvQ113thgMhP9V2ySFjDmYTJ4mmOdOuTZJ0(xBm2VKsOaaOGb2stWRxgmng7xsja5BomOVMttWRxgmng7xshJC7gnsB5Yo9BxvTa2WMqrcX7Z1vOjasiaIWQtT0wwFnNgmOolkwvR0BtJX(L0XiFZHb91CAWG6SOyLcuEBAm2VKog5BoAyqFnNMGxVmyAm2VKoMg1QVMttWRxgmng7xsjuKKB3iTLJOxjobnj08xmAd0zfUrpw)syShgIOxjobnj0eqfs)ZvvQ113thg0xZP5Vy0gOZkCJES(LWyBAm2VKogsymSES(xmoAyOxjobnj0O7kpdyfmRUsv)9ljrhPTCe9kXjOjHgDx5zaRGz1vQ6VFjj6Wqz91CA0DLNbScMvxPQ)(LKO10)vJg67bII0(gg0xZPr3vEgWkywDLQ(7xsIw9o4jAOVhiks7B0OHbDaLQDEK2)AJX(Lucr(MAJiaakyGT0e86LbtJoC0r8gAilJpfzb67nD1KqwEaleHOflllw(DKfnzJES(LWyZI(Aoz5MSCpl2alfmliHTUgzrhNGgzzE5r3VKel)oYsIe(zj40NfqZYdybEfBXIoobnYcXajeariVHh(dKud9jqKKL(EtxnjuZ3mYEL4e0KqZFXOnqNv4g9y9lHXwB5ikxwFnNM)IrBGoRWn6X6xcJTPXy)s6yE4pqAS1(VBqcJH1J1)IrcSPHCTLXG6SOO5YQo43hgWG6SOO5YkfO8EyadQZIIg1k9UMiH)rdd6R508xmAd0zfUrpw)sySnng7xshZd)bsd99EEnAqcJH1J1)IrcSPHCTLXG6SOO5YQALEpmGb1zrrdfO8UMiH)HbmOolkA8mAnrc)JgnmeH(Aon)fJ2aDwHB0J1VegBZYA0Wqz91CAcE9YGzznmaX7Z1vOjasiaIWkmsJMHrAdaGcgylnbqcbqew)DSsTU(EQPrhoQ2aacME(M8iT)1PJAlRVMtdguNffRQv6TPXy)s6yKV5WG(AonyqDwuSsbkVnng7xshJ8nhnsB5icaiy65BikAFEomeaafmWwAWylGnSR6Ge20ySFjDm7BeVHgYIMCfBXc03B6QjHuwSD)olJZvEgqwatw2QsXsP3VKeLfqZYdyXQrlVrwMGMfIbsiaIqwSD)olJdS1sZB4H)aj1qFcejzPV30vtc18nJSxjobnj0O7kpdyfmRUsv)9ljr1wUS(Aon6UYZawbZQRu1F)ss0A6)Qrd99arJz3WG(Aon6UYZawbZQRu1F)ss0Q3bprd99arJz3iTbaqbdSLMGxVmyAm2VKogXrBebaqbdSLMaiHaicR)owPwxFp1SSggkhaqW0Z3KhP9VoDuBaauWaBPjasiaIW6VJvQ113tnng7xsje5BQfdQZIIMlREgvRt)2vvlGnShZUnjG92SubaqbdSLMGxVmyA0HJoAeVHgYcXaj89hizzcAwCLIfyWtz539NLyNiKYcD1il)ogLfVXC7NLgNns3rywSTJjle0CiycwuwiUnMLikl7oLffsPS87EYIgzHIbklng7xEjjwanl)oYIgeBbSHnlJdKWSOVMtwoklUoy9S8awMUsXcyozb0S4zuw0GG6SOilhLfxhSEwEaliHTUg5n8WFGKAOpbIKSq8(CDfQ50JXiHbFTr7FDngJ5t1mexTWilRVMtt7qWeSO1zJzjIAAm2VKoMghgIqFnNM2HGjyrRZgZse1SSgPnc91CAAhcMGfToBmlr0k9Y5sv3JsFSp3SS0wwFnNgIUeUr4kgBbSHDmMFftSjDLanng7xsjePaSj2j8iTL1xZPbdQZIIvkq5TPXy)s6yKcWMyNWdd6R50Gb1zrXQALEBAm2VKogPaSj2j8Wq5i0xZPbdQZIIv1k92SSggIqFnNgmOolkwPaL3ML1iTr8UcZ3qbk6Fb0GPRRq4r8gAiledKW3FGKLF3Fwc7yGikl3KLOGflEJSawp9GrwWG6SOilpGfqQIYcm4z53Xgzb0SCKsqJS87hLfB3VZcuGI(xa5n8WFGKAOpbIKSq8(CDfQ50JXiHbFfSE6bJvmOolkQziUAHrwoc91CAWG6SOyLcuEBwwAJqFnNgmOolkwvR0BZYAK2iExH5BOaf9VaAW01viS2i6vItqtcn)fJ2aDwHB0J1VegBEdnKfnj4zXvkwEVjHpLfB3VFjleepHX4lWIT73bRNfaeSdUL1LKiWVJS46aiilbqcF)bskVHh(dKud9jqKKngaY51OMdrdkS(EtcFAKKR5Bgzz91CAWG6SOyLcuEBAm2VKowJX(L0Hb91CAWG6SOyvTsVnng7xshRXy)s6WaeVpxxHgyWxbRNEWyfdQZIIJ024Sr6URRqTV3KW38xmwFqf(WXi3oTUvnSJbI0cX7Z1vObg81gT)11ymMpL3Wd)bsQH(eisYsx58AuZHObfwFVjHpnsY18nJSS(AonyqDwuSsbkVnng7xshRXy)s6WG(AonyqDwuSQwP3MgJ9lPJ1ySFjDyaI3NRRqdm4RG1tpySIb1zrXrABC2iD31vO23Bs4B(lgRpOcF4yKBNw3Qg2XarAH4956k0ad(AJ2)6AmgZNYB4H)aj1qFcejzPpQuExNkVrnhIguy99Me(0ijxZ3mYY6R50Gb1zrXkfO820ySFjDSgJ9lPdd6R50Gb1zrXQALEBAm2VKowJX(L0HbiEFUUcnWGVcwp9GXkguNffhPTXzJ0DxxHAFVjHV5VyS(Gk8HJroXtRBvd7yGiTq8(CDfAGbFTr7FDngJ5t5n0qw0KGNL(iT)SOJtqJSqCBmlruwUjl3ZInWsbZIRuaBSefSy5bS04Sr6olkKszbE1xsIfIBJzjIYs5F)OSasvuw2DllmPSy7(DW6zb6LZLIfc6JsFSpFeVHh(dKud9jqKKfI3NRRqnNEmgzcQ7rPp2NxrVvrRWGxZqC1cJmaGGPNVbcM)E0wBe9kXjOjHg6LZLQUhL(yFU2i6vItqtcnHRdkScMv1nXQNWvy0)DTbaqbdSLgDSPyt0LKmn6Wr1gaafmWwAAhcMGfToBmlrutJoCuTrOVMttWRxgmllTLD63UQAbSH9y2hXzyqFnNgDfaaRw03SSgXB4H)aj1qFcejzJbGCEnQ5BgjeVpxxHMeu3JsFSpVIERIwHbV2gJ9lPeYUn5n8WFGKAOpbIKS0voVg18nJeI3NRRqtcQ7rPp2NxrVvrRWGxBJX(LucrEjJ3qdzz8PilexWwybKSeGzX297G1ZsWTSUKeVHh(dKud9jqKKDc6awbZA6)QrnFZiDRAyhdeXBOHSm(uKfni2cydBwghiHzX297S4zuwuGKelycwK2zr50)ssSObb1zrrw8eMLVJYYdyrDjYY9SSSyX297SqqwkQ3S4jmleBRKD8YaVHh(dKud9jqKKfJTa2WUQdsynFZilhaafmWwAcE9YGPXy)skb0xZPj41ldg4v7)bsc0ReNGMeAS6lg0WNRQEh88cvRLI6DPi3UXcaGcgylnySfWg2vDqcBGxT)hija5BoAyqFnNMGxVmyAm2VKoM9nma3Rd2KGAaMYBOHSafFkl22XKLTsjiSq3blfml6ilWRyleMLhWscEwaqWo4wSuwtIwyctzbKSqCxDuwatw0a1krw8eMLFhzrdcQZIIJ4n8WFGKAOpbIKSq8(CDfQ50JXiDQvfEfBPziUAHr60VDv1cyd7XkzBQPLTZOXsPVMtZC1rRGzfvRen03dePP2vkmOolkAUSQwP3J4n0qwgFkYcX2kzhVmWIT73zHyGecGiKSL8UeUrywGAD99uw8eMfyqU9Zcac2267rwiilf1Bwanl22XKLXPaay1I(SydSuWSGe26AKfDCcAKfITvYoEzGfKWwxJudlAcoril0vJS8awW8XMfNfYCLEZIgeuNffzX2oMSSOhPKLsBN9XIDwbw8eMfxPyHyAskl2oLIfDmaIrwA0HJYcfaswWeSiTZc8QVKel)oYI(AozXtywGbpLLDhcYIoIjl01CEHdZxfLLgNns3rydVHh(dKud9jqKKfI3NRRqnNEmgzaUgaj89hiR0xZqC1cJmc4EDWMeudWuTLH4956k0eGRbqcF)bsTrOVMttWRxgmllTLJGIFvhKlQ5pSTZ(Q2zfggWG6SOO5YQALEpmGb1zrrdfO8UMiH)rAlxUmeVpxxHgNAvHxXwddbaem98n5rA)RthhgkhaqW0Z3qu0(8uBaauWaBPbJTa2WUQdsytJoC0rdd9kXjOjHM)IrBGoRWn6X6xcJ9iTWG3qx58A00ySFjDm7tlm4nXaqoVgnng7xshRKPTmm4n0hvkVRtL3OPXy)s6yKV5WqeVRW8n0hvkVRtL3ObtxxHWJ0cX7Z1vO537tPQuejc7Qn)ETV3KW38xmwFqf(WX0xZPj41ldg4v7)bYsTPH4mmOVMtJUcaGvl6BwwA1xZPrxbaWQf9nng7xsjK(AonbVEzWaVA)pqsGYKBxP6vItqtcnw9fdA4ZvvVdEEHQ1sr9E0OHHYO9Volle2GXwrB0vvqdNEgqTbaqbdSLgm2kAJUQcA40ZaAAm2VKsiYjEehcuwJLQxjobnj0qVCUu19O0h7ZhnAK2YLJiaGGPNVjps7FD64WqziEFUUcnbqcbqewHrA0mmmeaafmWwAcGecGiS(7yLAD99utJX(LucrUghPTCe9kXjOjHgDx5zaRGz1vQ6VFjj6WGt)2vvlGnSjKg3uBaauWaBPjasiaIW6VJvQ113tnn6WrhnAyyEK2)AJX(LucfaafmWwAcGecGiS(7yLAD99utJX(L0rdd6akv78iT)1gJ9lPesFnNMGxVmyGxT)hija52vQEL4e0KqJvFXGg(Cv17GNxOATuuVhXBOHSm(uKfIBJzjIYIT73zHyBLSJxgyzLkKszH42ywIOSydSuWSOC6ZIcKKWMLF3twi2wj74LbnZYVJjllkYIoobnYB4H)aj1qFcejzBhcMGfToBmlrunFZi1xZPj41ldMgJ9lPJrUghg0xZPj41ldg4v7)bsczhXHa9kXjOjHgR(Ibn85QQ3bpVq1APOExkYTtleVpxxHMaCnas47pqwPpVHh(dKud9jqKKnGkK(NRQU6iLXy(A(MrcX7Z1vOjaxdGe((dKv6RTS(AonbVEzWaVA)pqowK2rCiqVsCcAsOXQVyqdFUQ6DWZluTwkQ3LIC7ggIiaGGPNVbcM)E0E0WG(AonTdbtWIwNnMLiQzzPvFnNM2HGjyrRZgZse10ySFjLqLmceaj86EJvJHJIvxDKYymFZFXyfIRwibkhH(Aon6kaawTOVzzPnI3vy(g67Tc0WgmDDfcpI3Wd)bsQH(eisYEzW70)dKA(MrcX7Z1vOjaxdGe((dKv6ZBOHSuY17Z1villkcZcizX1p19hsz539NfBE(S8aw0rwOoeeMLjOzHyBLSJxgyHcy539NLFhJYI3y(SyZPpcZsjhl6ZIoobnYYVJX8gE4pqsn0NarswiEFUUc1C6XyKuhcwNGUg86LbndXvlmYaaOGb2stWRxgmng7xshJ8nhgIaI3NRRqtaKqaeHvyKgndAdaiy65BYJ0(xNooma3Rd2KGAaMYBOHSm(uKYcXfObSCtwUKfpzrdcQZIIS4jmlFFiLLhWI6sKL7zzzXIT73zHGSuuV1mleBRKD8YGMzrdITa2WMLXbsyw8eMLTc7w)bbzbQnVJ5n8WFGKAOpbIKSZvhTcMvuTsuZ3msmOolkAUS6zuTLD63UQAbSHnHkz2PP6R50mxD0kywr1krd99arLsJdd6R500oemblAD2ywIOML1iTL1xZPXQVyqdFUQ6DWZluTwkQ3giUAHeYocEZHb91CAcE9YGPXy)s6y23iTq8(CDfAOoeSobDn41ldAlhraabtpFtIHgOan8Wam4noSB9heSsT5DCf2JDsO5VarxsAK2YreaqW0Z3abZFpApmOVMtt7qWeSO1zJzjIAAm2VKsOsMMwMGlvVsCcAsOHE5CPQ7rPp2NpsR(AonTdbtWIwNnMLiQzznmeH(AonTdbtWIwNnMLiQzznsB5icaiy65BikAFEomeaafmWwAWylGnSR6Ge20ySFjDm72CK23Bs4B(lgRpOcF4yACyqhqPANhP9V2ySFjLqKVjVHgYY4trw0et83zb6790vkwSAqGYYnzb6790vkwoAU9ZYYI3Wd)bsQH(eisYsFVNUsP5BgP(AonGe)DA1c7aA9hinllT6R50qFVNUszAC2iD31viVHgYcX8mGkwG(ERanml3KL7zz3PSOqkLLF3tw0iLLgJ9lVKKMzjkyXI3il(ZsjBtcWYwPeew8eMLFhzjS6gZNfniOolkYYUtzrJeGYsJX(LxsI3Wd)bsQH(eisYg8mGQQ(Ao1C6XyK03BfOH18nJuFnNg67Tc0WMgJ9lPesJAlRVMtdguNffRuGYBtJX(L0X04WG(AonyqDwuSQwP3MgJ9lPJPXrAD63UQAbSH9yLSn5n0qwiMNbuXYVJSqqwkQ3SOVMtwUjl)oYIvdcSydSuW52plQlrwwwSy7(Dw(DKLej8ZYFXiledKqaeHSeaXiLfWCYsa2WsP3pkll6YvQOSasvuw2DllmPSaV6ljXYVJSmoY0WB4H)aj1qFcejzdEgqvvFnNAo9ymsR(Ibn85QQ3bpVq1APOER5Bg57kmFZLbVt)pqAW01viS2iExH5Bs0wngasdMUUcH1wYx5Y2BZn1uN(TRQwaBytacEtnLIFvhKlQ5pSTZ(Q2zfkfbV5iIFzcM4tTqLQU70hhPPbaqbdSLMaiHaicR)owPwxFp10ySFjDeHk5RCz7T5MAQt)2vvlGnS1u91CAS6lg0WNRQEh88cvRLI6TbIRwibi4n1uk(vDqUOM)W2o7RANvOue8MJi(LjyIp1cvQ6UtFCKMgaafmWwAcGecGiS(7yLAD99utJX(L0rAdaGcgylnbVEzW0ySFjDm7TPw91CAS6lg0WNRQEh88cvRLI6TbIRwiHSJ8n1QVMtJvFXGg(Cv17GNxOATuuVnqC1chZEBQnaakyGT0eajeary93Xk1667PMgJ9lPeIG3u78iT)1gJ9lPJfaafmWwAcGecGiS(7yLAD99utJX(Lucq80wUxjobnj0eqfs)ZvvQ113thgG4956k0eajearyfgPrZWiEdnKfO4tzX2oMSqqwkQ3Sq3blfml6ilwnieqywqVvrz5bSOJS46kKLhWYIISqmqcbqeYcizjaakyGTKLYAaLI5FUsfLfDmaIrklFVqwUjlWRyRljXYwPeewsGnwSDkflUsbSXsuWILhWIf2tm8QOSG5JnleKLI6nlEcZYVJjllkYcXajear4iEdp8hiPg6tGijleVpxxHAo9ymsRgeQwlf17k6TkQMH4QfgzaabtpFtEK2)60rT9kXjOjHgR(Ibn85QQ3bpVq1APOERvFnNgR(Ibn85QQ3bpVq1APOEBG4QfsaN(TRQwaByta7nwK2BZn1cX7Z1vOjasiaIWkmsJMbTbaqbdSLMaiHaicR)owPwxFp10ySFjLqo9BxvTa2WM4BVnlfPaSj2jS2iG71bBsqnat1Ib1zrrZLvpJQ1PF7QQfWg2JbX7Z1vOjasiaIWQtT0gaafmWwAcE9YGPXy)s6yAK3qdzz8PilqFVNUsXIT73zb6JkL3SOj7B(SaAwE7SpwiyRalEcZscyb67Tc0WAMfB7yYscyb6790vkwoklllwanlpGfRgeyHGSuuVzX2oMS46aiilLSnzzRucszqZYVJSGERIYcbzPOEZIvdcSaX7Z1vilhLLVx4iwanloSL)heKfQnVJzz3PSyFeGIbklng7xEjjwanlhLLlzzQos7pVHh(dKud9jqKKL(EpDLsZ3mYYVRW8n0hvkVRW9nFdMUUcHhgO4x1b5IA(dB7SVkbBfgPnI3vy(g67Tc0WgmDDfcRvFnNg6790vktJZgP7UUc1grVsCcAsO5Vy0gOZkCJES(LWyRTS(Aonw9fdA4ZvvVdEEHQ1sr92aXvlCSiTtJBQnc91CAcE9YGzzPTmeVpxxHgNAvHxXwdd6R50q0LWncxXylGnSJX8RyInPReOzznmaX7Z1vOXQbHQ1sr9UIERIoAyOCaabtpFtIHgOanS23vy(g6JkL3v4(MVbtxxHWAlddEJd7w)bbRuBEhxH9yNeAAm2VKoM9nm4H)aPXHDR)GGvQnVJRWEStcnxwNQJ0(pA0iTLdaGcgylnbVEzW0ySFjDmY3CyiaakyGT0eajeary93Xk1667PMgJ9lPJr(MJ4n0qw0KRylklBLsqyrhNGgzHyGecGiKLf9ssS87iledKqaeHSeaj89hiz5bSe2XarSCtwigiHaicz5OS4HF5kvuwCDW6z5bSOJSeC6ZB4H)aj1qFcejzPV30vtc18nJeI3NRRqJvdcvRLI6Df9wfL3qdzz8PilAcaqszX2oMSefSyXBKfxhSEwEaz9gzj4wwxsILWU3KqklEcZsSteYcD1il)ogLfVrwUKfpzrdcQZIISq)tPyzcAwiOxtGSexnbEdp8hiPg6tGijBI2QXaqQ5BgPBvd7yGiTLd7EtcPrAN2gd7EtcR)fJesJddHDVjH0iT3iEdp8hiPg6tGij7URM1yai18nJ0TQHDmqK2YHDVjH0iTtBJHDVjH1)IrcPXHHWU3KqAK2BK2Y6R50Gb1zrXQALEBAm2VKogsymSES(xmomOVMtdguNffRuGYBtJX(L0XqcJH1J1)IXr8gE4pqsn0Nars25sPQXaqQ5BgPBvd7yGiTLd7EtcPrAN2gd7EtcR)fJesJddHDVjH0iT3iTL1xZPbdQZIIv1k920ySFjDmKWyy9y9VyCyqFnNgmOolkwPaL3MgJ9lPJHegdRhR)fJJ4n0qwgFkYc03B6QjHSOjM4VZIvdcuw8eMf4vSflBLsqyX2oMSqSTs2XldAMfni2cydBwghiH1ml)oYsjxm)9Onl6R5KLJYIRdwplpGLPRuSaMtwanlrbRTHzj4wSSvkbH3Wd)bsQH(eisYsFVPRMeQ5BgjguNffnxw9mQ2Y6R50as83P1Gc9Uc5OhinlRHb91CAi6s4gHRySfWg2Xy(vmXM0vc0SSgg0xZPj41ldMLL2YreaqW0Z3qu0(8CyiaakyGT0GXwaByx1bjSPXy)s6yACyqFnNMGxVmyAm2VKsisbytSt4snvaqx2PF7QQfWg2eFiEFUUcnuAnaO)OrAlhraabtpFdem)9O9WG(AonTdbtWIwNnMLiQPXy)skHifGnXoHlvapv5Yo9BxvTa2WMae8ML6DfMVzU6OvWSIQvIgmDDfcpI4dX7Z1vOHsRba9hra7vQ3vy(MeTvJbG0GPRRqyTr0ReNGMeAOxoxQ6Eu6J95A1xZPPDiycw06SXSernlRHb91CAAhcMGfToBmlr0k9Y5sv3JsFSp3SSggkRVMtt7qWeSO1zJzjIAAm2VKsip8hin03751Objmgwpw)lg1sTqLQU70hj0MgcEyqFnNM2HGjyrRZgZse10ySFjLqE4pqAS1(VBqcJH1J1)IXHbiEFUUcnN9dxdGe((dKAdaGcgylnxsd96DDfwT)LN)kUcJqUaAA0HJQfT)1zzHWMlPHE9UUcR2)YZFfxHrixahPvFnNM2HGjyrRZgZse1SSggIqFnNM2HGjyrRZgZse1SS0graauWaBPPDiycw06SXSernn6WrhnmaX7Z1vOXPwv4vS1WGoGs1ops7FTXy)skHifGnXoHlvapvzN(TRQwaByt8H4956k0qP1aG(JgXBOHSu6oklpGLyNiKLFhzrhPplGjlqFVvGgMf9OSqFpq0LKy5EwwwSy)RlqKkklxYINrzrdcQZIISOVEwiilf1BwoAU9ZIRdwplpGfDKfRgecimVHh(dKud9jqKKL(EtxnjuZ3mY3vy(g67Tc0WgmDDfcRnIEL4e0KqZFXOnqNv4g9y9lHXwBz91CAOV3kqdBwwddo9BxvTa2WESs2MJ0QVMtd99wbAyd99areYEAlRVMtdguNffRuGYBZYAyqFnNgmOolkwvR0BZYAKw91CAS6lg0WNRQEh88cvRLI6TbIRwiHSJ4SP2YbaqbdSLMGxVmyAm2VKog5BomebeVpxxHMaiHaicRWinAg0gaqW0Z3KhP9VoDCeVHgYIgq)l2FKYYoWglXRWolBLsqyXBKfs(LimlwyZcfdGe2WIMyQIYY7eHuwCwOPBr3bpltqZYVJSewDJ5Zc9(L)hizHcyXgyPGZTFw0rw8qy1(JSmbnlkVjHnl)fJZ2JrkVHh(dKud9jqKKfI3NRRqnNEmgPtTiiydfdAgIRwyKyqDwu0CzvTsVlL9r89WFG0qFVNxJgKWyy9y9VyKarGb1zrrZLv1k9UuLjEe4DfMVHcwQkyw)DSobnsFdMUUcHlL9gr89WFG0yR9F3GegdRhR)fJeytdbRrIp1cvQ6UtFKaBA0yPExH5Bs)xnsR6UYZaAW01vimVHgYIMCfBXc03B6QjHSCjlEYIgeuNffzXPSqbGKfNYIfGspDfYItzrbssS4uwIcwSy7ukwWeMLLfl2UFNf7BtcWITDmzbZh7ljXYVJSKiHFw0GG6SOOMzbgKB)SOWNL7zXQbbwiilf1BnZcmi3(zbabBB99ilEYIMyI)olwniWINWSybakw0XjOrwi2wj74Lbw8eMfni2cydBwghiH5n8WFGKAOpbIKS03B6QjHA(MrgrVsCcAsO5Vy0gOZkCJES(LWyRTS(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKq2rC2CyqFnNgR(Ibn85QQ3bpVq1APOEBG4Qfsi704MAFxH5BOpQuExH7B(gmDDfcpsBzmOolkAUSsbkV160VDv1cydBcaX7Z1vOXPweeSHIHsPVMtdguNffRuGYBtJX(LucadEZC1rRGzfvRen)fiIwBm2VSu2z04y23MddyqDwu0CzvTsV160VDv1cydBcaX7Z1vOXPweeSHIHsPVMtdguNffRQv6TPXy)skbGbVzU6OvWSIQvIM)cerRng7xwk7mACSs2MJ0gH(AonGe)DA1c7aA9hinllTr8UcZ3qFVvGg2GPRRqyTLdaGcgylnbVEzW0ySFjDmIZWafSu6xcB(9(uQkfrIW2GPRRqyT6R50879PuvkIeHTH(EGiczp7PPL7vItqtcn0lNlvDpk9X(8sz3iTZJ0(xBm2VKog5BUP25rA)Rng7xsjKDBU5WaCVoytcQby6iTLJiaGGPNVHOO955WqaauWaBPbJTa2WUQdsytJX(L0XSBeVHgYY4trw0eaGKYYLS4zuw0GG6SOilEcZc1HGSqqVRMeG4Uukw0eaGKLjOzHyBLSJxgyXtywk5DjCJWSObXwaByhJ5ByzRkkGLffzzlAcS4jmlexnbw8NLFhzbtywatwiUnMLiklEcZcmi3(zrHplAYg9y9lHXMLPRuSaMtEdp8hiPg6tGijBI2QXaqQ5BgPBvd7yGiTq8(CDfAOoeSobDn41ldAlRVMtdguNffRQv6TPXy)s6yiHXW6X6FX4WG(AonyqDwuSsbkVnng7xshdjmgwpw)lghXB4H)aj1qFcejz3D1SgdaPMVzKUvnSJbI0cX7Z1vOH6qW6e01GxVmOTS(AonyqDwuSQwP3MgJ9lPJHegdRhR)fJdd6R50Gb1zrXkfO820ySFjDmKWyy9y9VyCK2Y6R50e86LbZYAyqFnNgR(Ibn85QQ3bpVq1APOEBG4QfsOiTJ8nhPTCebaem98nqW83J2dd6R500oemblAD2ywIOMgJ9lPeQSg1u7kvVsCcAsOHE5CPQ7rPp2NpsR(AonTdbtWIwNnMLiQzznmeH(AonTdbtWIwNnMLiQzznsB5i6vItqtcn)fJ2aDwHB0J1Veg7HbKWyy9y9VyKq6R508xmAd0zfUrpw)sySnng7xshgIqFnNM)IrBGoRWn6X6xcJTzznI3Wd)bsQH(eisYoxkvngasnFZiDRAyhdePfI3NRRqd1HG1jORbVEzqBz91CAWG6SOyvTsVnng7xshdjmgwpw)lghg0xZPbdQZIIvkq5TPXy)s6yiHXW6X6FX4iTL1xZPj41ldML1WG(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKqrAh5BosB5icaiy65BikAFEomOVMtdrxc3iCfJTa2WogZVIj2KUsGML1iTLJiaGGPNVbcM)E0EyqFnNM2HGjyrRZgZse10ySFjLqAuR(AonTdbtWIwNnMLiQzzPnIEL4e0Kqd9Y5sv3JsFSpFyic91CAAhcMGfToBmlruZYAK2Yr0ReNGMeA(lgTb6Sc3OhRFjm2ddiHXW6X6FXiH0xZP5Vy0gOZkCJES(LWyBAm2VKomeH(Aon)fJ2aDwHB0J1VegBZYAeVHgYY4trwiOaAalGKLamVHh(dKud9jqKK1M39b6kywr1krEdnKLXNISa99EEnYYdyXQbbwGcuEZIgeuNff1mleBRKD8Yal7oLffsPS8xmYYV7jloleuT)7SGegdRhzrHZNfqZcivrzHmxP3SObb1zrrwokllldleu3VZsPTZ(yXoRaly(yZIZcuGYBw0GG6SOil3KfcYsr9Mf6Fkfl7oLffsPS87EYIDKVjl03derzXtywi2wj74Lbw8eMfIbsiaIqw2DiilXGgz539KfYjouwiMMKLgJ9lVKKHLXNIS46aiil2PXnj(SS70hzbE1xsIfIBJzjIYINWSyND2r8zz3PpYIT73bRNfIBJzjIYB4H)aj1qFcejzPV3ZRrnFZiXG6SOO5YQALERnc91CAAhcMGfToBmlruZYAyadQZIIgkq5Dnrc)ddLXG6SOOXZO1ej8pmOVMttWRxgmng7xsjKh(dKgBT)7gKWyy9y9VyuR(AonbVEzWSSgPTCeu8R6GCrn)HTD2x1oRWWqVsCcAsOXQVyqdFUQ6DWZluTwkQ3A1xZPXQVyqdFUQ6DWZluTwkQ3giUAHeYoY3uBaauWaBPj41ldMgJ9lPJroXrB5icaiy65BYJ0(xNoomeaafmWwAcGecGiS(7yLAD99utJX(L0XiN4msB5iApGMVbk1WqaauWaBPrhBk2eDjjtJX(L0XiN4mA0WaguNffnxw9mQ2Y6R50yZ7(aDfmROALOzznmqTqLQU70hj0MgcwJAlhraabtpFdem)9O9Wqe6R500oemblAD2ywIOML1OHHaacME(giy(7rBTuluPQ7o9rcTPHGhXBOHSm(uKfcQ2)Dwa)o22okYIT9lSZYrz5swGcuEZIgeuNff1mleBRKD8YalGMLhWIvdcSqMR0Bw0GG6SOiVHh(dKud9jqKK1w7)oVHgYcX1vQFVx8gE4pqsn0Nars2ELvp8hiRQJ(Ao9ymYPRu)EVkGsTWqXwiFt7k(IVOaa]] )


end