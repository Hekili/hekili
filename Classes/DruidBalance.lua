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


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20220408, [[di1a9fqiHOhrkOlrkqBIu6tkLAukKtPqTkjsEfcywKIClsrzxu8levnmLIogIYYOu5zseMgIuUgIkBJuaFdbrJJsvCojIY6KiY8qGUNqyFsu(hPOQOdQuIfkrvperYejfvUiPqTreK6JKIQkJKuuv1jLOIvQu4LsevAMKc5MKIQStLs6NiiPHIGWrjfvfwQervpfKMQePUQevARsev8veKySis1ELWFL0GjomvlMu9ybtguxgAZk6Zi0OvQoTkRMuuv61iIztYTfQDl63adNsooLQ0YL65inDvDDLSDq8DkLXJG68cP1tPQMVc2pQliRO0fqH9hl2QDBANDBsABApg7kXMesYrilG(rTWcOwEGeNiwan9ySaA5DLNbSaQLhvbC4IsxaLcwDalGU)VfTKip51DLNbuZOxCWq8(9LU5aKV8UYZaQzqVysr(yyZ(hR0858uye6UYZaAEc)fq1xN6lNSqVakS)yXwTBt7SBtsBt7Xyxj2KqsonqbuF97GUak0lMufq3pyyml0lGcJ0qb0Y7kpdilAUEDW8gBXQpfl2JMyXUnTZoEdEdsT7jrKws8gAglBbggHzbkq5nlLh9ydVHMXcP29KicZY7nr8R3KLGtrklpGLq0GcRV3eXNA4n0mwk5XyaeeMLvMyaPuVJYceVpxxHuwgDg0OjwSAesL(EtxnrKfnRmwSAeIH(EtxnrCSH3qZyzlqahmlwngC6FjrwiuA)3z5MSC)2uw(DKfBnijYIghuNffn8gAglAEojilKcKqaKGS87ilqTU(EklolQ7FfYsmOrwMkKWNUczz0nzjkyXYUdNB)SSFpl3Zc9IxQ3teSOQOSy7(DwkpH6wknleGfsHkK(NRyzlQJygJ5RjwUFBywOKCwJn8gAglAEojilXa6ZY2ZJ4(xBm2VKUnl0aMEFaklULLkklpGfDaLYY8iU)uwaPkQH3qZyP0n6plLgeJSaMSuELVZs5v(olLx57S4uwCwOwy4CflFFjj4B4n0mwiuTWeBwgDg0OjwiuA)31elekT)7AIfOV3ZRXXSe7WilXGgzPr6PomFwEalO3QdBwcGyD)1m679B4n0mwi0hHzPK7LWncZIghBbSHDmMplHDmqcltqZcP0CSSOor0WBOzSuYJXaiilW96GnjOgGPSe2XajudVbVXwYe8(JWSuEx5zazzlecnILGNSOJSmbReMf)zz)FlAjrEYR7kpdOMrV4GH497lDZbiF5DLNbuZGEXKI8XWM9pwP5Z5PWi0DLNb08e(lGQo6tlkDbuGfMyxu6ITswrPlGIPRRq4IYxa1d)bYcO2A)3lGcJ0qFw)bYcOeIgdo9zXowiuA)3zXtywCwG(EtxnrKfqYc0sZIT73zzRhX9NfcTJS4jmlLhSLsZcOzb6798AKfWVJTTJIfqd99yFEb0rSGb1zrrJALExtKWplddSGb1zrrZLvkq5nlddSGb1zrrZLvDWVZYWalyqDwu04z0AIe(zzmlAzXQrigYm2A)3zrllrYIvJqm2zS1(Vx8fB1UIsxaftxxHWfLVaQh(dKfqPV3ZRXcOH(ESpVa6iwgXsKS0ReNGMiA0DLNbScMvxPQ)(LePgmDDfcZYWalrYsaabtpFtEe3)60rwggyjswOwOsvFVjIp1qFVNUsXseSqglddSejlVRW8nP)RgPvDx5zany66keMLXSmmWYiwWG6SOOHcuExtKWplddSGb1zrrZLv1k9MLHbwWG6SOO5YQo43zzyGfmOolkA8mAnrc)SmMLXSOLLizHIFvhKlQ5pSTZEQ2zfkGQUeRb4cOKR4l2AjkkDbumDDfcxu(cOE4pqwaL(EtxnrSaAOVh7ZlGoILEL4e0erJUR8mGvWS6kv93VKi1GPRRqyw0YsaabtpFtEe3)60rw0Yc1cvQ67nr8Pg6790vkwIGfYyzmlAzjswO4x1b5IA(dB7SNQDwHcOQlXAaUak5k(IVakmo9L6lkDXwjRO0fq9WFGSakfO8UQJECbumDDfcxu(IVyR2vu6cOy66keUO8fqd99yFEb0)IrwiilJyXowkflE4pqAS1(VBco9R)fJSqaw8WFG0qFVNxJMGt)6FXilJlGs)(cFXwjRaQh(dKfqdUsv9WFGSQo6xavD0VMEmwafyHj2fFXwlrrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfqPwOsvFVjIp1qFVNUsXszSqglAzzelrYY7kmFd99wbAydMUUcHzzyGL3vy(g6JkL3v4(MVbtxxHWSmMLHbwOwOsvFVjIp1qFVNUsXszSyxbuyKg6Z6pqwafk(uw2cqJzbKSuccWIT73bRNf4(MplEcZIT73zb67Tc0WS4jml2rawa)o22okwafI310JXcOhT6aS4l2kPvu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwybuQfQu13BI4tn03751ilLXczfqHrAOpR)azbuO4tzjOqhcYITDmzb6798AKLGNSSFpl2rawEVjIpLfB7xyNLJYsJkeINpltqZYVJSOXb1zrrwEal6ilwnoXUryw8eMfB7xyNL5PuyZYdyj40VakeVRPhJfqpAnOqhcw8fBLCfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4Qfwa1QrivIbydzMyaiNxJSmmWIvJqQedWgYm0voVgzzyGfRgHujgGnKzOV30vtezzyGfRgHujgGnKzOV3txPyzyGfRgHujgGnKzMRoAfmROALilddSy1iet7qWeSO1zJP9JYYWal6R50e86LbtJX(LuwIGf91CAcE9YGbE1(FGKLHbwG4956k0C0QdWcOWin0N1FGSaAjhVpxxHS87(ZsyhdKqz5MSefSyXBKLlzXzHyaMLhWIdbCWS87il07x(FGKfB7yJS4S89LKGpl4hy5OSSOimlxYIo(2qmzj40NwafI310JXcOxwjgGl(ITQbkkDbumDDfcxu(cOE4pqwavhBk2KCjXcOWin0N1FGSaA5srwkp2uSj5sIS4pl)oYcMWSaMSqOBmTFuwSTJjl7o9rwoklUoacYIgytnOMyXNp2SqkqcbqcYIT73zP8aV0S4jmlGFhBBhfzX297SqQTq(Yjdfqd99yFEb0rSmILizjaGGPNVjpI7FD6ilddSejlbaqbdSLMaiHaibR)owPwxFp1SSyzyGLizPxjobnr0O7kpdyfmRUsv)9ljsny66keMLXSOLf91CAcE9YGPXy)sklLXczKJfTSOVMtt7qWeSO1zJP9JAAm2VKYcbzH0yrllrYsaabtpFdem)9OnlddSeaqW0Z3abZFpAZIww0xZPj41ldMLflAzrFnNM2HGjyrRZgt7h1SSyrllJyrFnNM2HGjyrRZgt7h10ySFjLfcgblKzhlAglKglLILEL4e0erd9Y5sv3JsFSp3GPRRqywggyrFnNMGxVmyAm2VKYcbzHmYyzyGfYyH8SqTqLQU70hzHGSqMrdWYywgZIwwG4956k0CzLyaU4l2kHSO0fqX01viCr5lGg67X(8cOJyrFnNMGxVmyAm2VKYszSqg5yrllJyjsw6vItqten0lNlvDpk9X(CdMUUcHzzyGf91CAAhcMGfToBmTFutJX(LuwiilKvYyrll6R500oemblAD2yA)OMLflJzzyGfDaLYIwwMhX9V2ySFjLfcYIDKJLXSOLfiEFUUcnxwjgGlGcJ0qFw)bYcOecWZIT73zXzHuBH8Ltgy539NLJMB)S4SqiwkQ3Sy1GalGMfB7yYYVJSmpI7plhLfxhSEwEalycxa1d)bYcOwG)azXxSv7PO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOb8uSmILrSmpI7FTXy)sklAglKrow0mwcaGcgylnbVEzW0ySFjLLXSqEwiZE2KLXSuglb8uSmILrSmpI7FTXy)sklAglKrow0mwcaGcgylnbqcbqcw)DSsTU(EQPXy)sklJzH8SqM9SjlJzrllrYs7hCfHG5BCyyQbj8rFklAzzelrYsaauWaBPj41ldMgD4OSmmWsKSeaafmWwAcGecGeS(7yLAD99utJoCuwgZYWalbaqbdSLMGxVmyAm2VKYszSC5JTfq5pcxNhX9V2ySFjLLHbw6vItqtenbuH0)CvLAD99udMUUcHzrllbaqbdSLMGxVmyAm2VKYszSuInzzyGLaaOGb2staKqaKG1FhRuRRVNAAm2VKYszSC5JTfq5pcxNhX9V2ySFjLfnJfY2KLHbwIKLaacME(M8iU)1PJfqHrAOpR)azbus5QWs5pszX2o(7yZYIEjrwifiHaibzjb2yX2PuS4kfWglrblwEal0)ukwco9z53rwOEmYIhdw5ZcyYcPajeajibi1wiF5Kbwco9PfqH4Dn9ySaAaKqaKGvyKgndfFXwlzfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaDelV3eX38xmwFqf(qwkJfYihlddS0(bxriy(ghgMAUKLYyHCBYYyw0YYiwgXcAVRZYcHnySv0gDvf0WPNbKfTSmILizjaGGPNVbcM)E0MLHbwcaGcgylnySv0gDvf0WPNb00ySFjLfcYczAacjleGLrSqowkfl9kXjOjIg6LZLQUhL(yFUbtxxHWSmMLXSOLLizjaakyGT0GXwrB0vvqdNEgqtJoCuwgZYWalO9Uolle2qblLc))sI1EPhLfTSmILizjaGGPNVjpI7FD6ilddSeaafmWwAOGLsH)FjXAV0JwlbPro7ztYmng7xszHGSqgzKglJzzyGLrSeaafmWwA0XMInjxs00OdhLLHbwIKL2dO5BGsXYWalbaem98n5rC)RthzzmlAzzelrYY7kmFZC1rRGzfvReny66keMLHbwcaiy65BGG5VhTzrllbaqbdSLM5QJwbZkQwjAAm2VKYcbzHmYyHaSqowkfl9kXjOjIg6LZLQUhL(yFUbtxxHWSmmWsKSeaqW0Z3abZFpAZIwwcaGcgylnZvhTcMvuTs00ySFjLfcYI(AonbVEzWaVA)pqYcbyHm7yPuS0ReNGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSOzSqMDSmMfTSmIf0ExNLfcBUKg6176kSAVlp)vCfgHCbKfTSeaafmWwAUKg6176kSAVlp)vCfgHCb00ySFjLfcYc5yzmlddSmILrSG276SSqydD3Hb2q4kO1RGz9bDmMplAzjaakyGT08GogZhHRxspI7FTeKJCLWoYmng7xszzmlddSmILrSaX7Z1vObK1ffRFFjj4ZseSqglddSaX7Z1vObK1ffRFFjj4ZseSucwgZIwwgXY3xsc(MNmtJoC0AaauWaBjlddS89LKGV5jZeaafmWwAAm2VKYszSC5JTfq5pcxNhX9V2ySFjLfnJfY2KLXSmmWceVpxxHgqwxuS(9LKGplrWIDSOLLrS89LKGV5TZ0OdhTgaafmWwYYWalFFjj4BE7mbaqbdSLMgJ9lPSuglx(yBbu(JW15rC)Rng7xszrZyHSnzzmlddSaX7Z1vObK1ffRFFjj4ZseSSjlJzzmlJlGcJ0qFw)bYcOLlfHz5bSaJkpkl)oYYI6erwatwi1wiF5KbwSTJjll6LezbgS0vilGKLffzXtywSAecMpllQtezX2oMS4jlommliemFwoklUoy9S8awGpSakeVRPhJfqdW1aiHV)azXxSvY2SO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOrYcfSu6xcB(9(uQkfrsW2GPRRqywggyzEe3)AJX(LuwkJf72CtwggyrhqPSOLL5rC)Rng7xszHGSyh5yHaSmIfsBtw0mw0xZP537tPQuejbBd99ajSukwSJLXSmmWI(Aon)EFkvLIijyBOVhiHLYyPe2dlAglJyPxjobnr0qVCUu19O0h7Zny66keMLsXIDSmUakmsd9z9hilGwYX7Z1villkcZYdybgvEuw8mklFFjj4tzXtywcWuwSTJjl287VKiltqZINSOXlRDqFolwniuafI310JXcO)EFkvLIijyxT53x8fBLmYkkDbumDDfcxu(cOWin0N1FGSaA5srw04yROn6kwiuB40ZaYIDBsXaLfDCcAKfNfsTfYxozGLffzb0SqbS87(ZY9Sy7ukwuxISSSyX297S87ilycZcyYcHUX0(rlGMEmwafJTI2ORQGgo9mGfqd99yFEb0aaOGb2stWRxgmng7xszHGSy3MSOLLaaOGb2staKqaKG1FhRuRRVNAAm2VKYcbzXUnzrllJybI3NRRqZV3NsvPisc2vB(9SmmWI(Aon)EFkvLIijyBOVhiHLYyPeBYcbyzel9kXjOjIg6LZLQUhL(yFUbtxxHWSukwkblJzzmlAzbI3NRRqZLvIbywggyrhqPSOLL5rC)Rng7xszHGSucczbup8hilGIXwrB0vvqdNEgWIVyRKzxrPlGIPRRq4IYxafgPH(S(dKfqlxkYcuWsPW)sISuYV0JYIgGIbkl64e0ilolKAlKVCYallkYcOzHcy539NL7zX2PuSOUezzzXIT73z53rwWeMfWKfcDJP9Jwan9ySakfSuk8)ljw7LE0cOH(ESpVa6iwcaGcgylnbVEzW0ySFjLfcYIgGfTSejlbaem98nqW83J2SOLLizjaGGPNVjpI7FD6ilddSeaqW0Z3KhX9VoDKfTSeaafmWwAcGecGeS(7yLAD99utJX(LuwiilAaw0YYiwG4956k0eajeajyfgPrZalddSeaafmWwAcE9YGPXy)skleKfnalJzzyGLaacME(giy(7rBw0YYiwIKLEL4e0erd9Y5sv3JsFSp3GPRRqyw0YsaauWaBPj41ldMgJ9lPSqqw0aSmmWI(AonTdbtWIwNnM2pQPXy)skleKfY2KfcWYiwihlLIf0ExNLfcBUK(9k8GMwHpixIvDuPyzmlAzrFnNM2HGjyrRZgt7h1SSyzmlddSOdOuw0YY8iU)1gJ9lPSqqwSJCSmmWcAVRZYcHnySv0gDvf0WPNbKfTSeaafmWwAWyROn6QkOHtpdOPXy)sklLXIDBYYyw0YceVpxxHMlRedWSOLLizbT31zzHWMlPHE9UUcR27YZFfxHrixazzyGLaaOGb2sZL0qVExxHv7D55VIRWiKlGMgJ9lPSugl2TjlddSOdOuw0YY8iU)1gJ9lPSqqwSBZcOE4pqwaLcwkf()LeR9spAXxSvYkrrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfq1xZPj41ldMgJ9lPSuglKrow0YYiwIKLEL4e0erd9Y5sv3JsFSp3GPRRqywggyrFnNM2HGjyrRZgt7h10ySFjLfcgblKrod5yHaSmILsyihlLIf91CA0vaaSArFZYILXSqawgXcPzihlAglLWqowkfl6R50ORaay1I(MLflJzPuSG276SSqyZL0VxHh00k8b5sSQJkfleGfsZqowkflJybT31zzHWMFhRZRPFLEepflAzjaakyGT087yDEn9R0J4Pmng7xszHGrWIDBYYyw0YI(AonTdbtWIwNnM2pQzzXYywggyrhqPSOLL5rC)Rng7xszHGSyh5yzyGf0ExNLfcBWyROn6QkOHtpdilAzjaakyGT0GXwrB0vvqdNEgqtJX(L0cOWin0N1FGSa6wu28OuwwuKLYrZhAowSD)olKAlKVCYalGMf)z53rwWeMfWKfcDJP9JwafI310JXcON9cxdGe((dKfFXwjJ0kkDbumDDfcxu(cOE4pqwa9sAOxVRRWQ9U88xXvyeYfWcOH(ESpVakeVpxxHMZEHRbqcF)bsw0YceVpxxHMlRedWfqtpglGEjn0R31vy1ExE(R4kmc5cyXxSvYixrPlGIPRRq4IYxafgPH(S(dKfqlxkYc0DhgydHzHqT1zrhNGgzHuBH8LtgkGMEmwaLU7WaBiCf06vWS(GogZVaAOVh7ZlGoILaaOGb2stWRxgmn6WrzrllrYsaabtpFtEe3)60rw0YceVpxxHMFVpLQsrKeSR287zrllJyjaakyGT0OJnfBsUKOPrhoklddSejlThqZ3aLILXSmmWsaabtpFtEe3)60rw0YsaauWaBPjasiasW6VJvQ113tnn6WrzrllJybI3NRRqtaKqaKGvyKgndSmmWsaauWaBPj41ldMgD4OSmMLXSOLfyWBORCEnA(lqYLezrllJybg8g6JkL31PYB08xGKljYYWalrYY7kmFd9rLY76u5nAW01vimlddSqTqLQ(EteFQH(EpVgzPmwkblJzrllWG3eda58A08xGKljYIwwgXceVpxxHMJwDaYYWal9kXjOjIgDx5zaRGz1vQ6VFjrQbtxxHWSmmWIt)2vvlGnSzPSiyPKTjlddSaX7Z1vOjasiasWkmsJMbwggyrFnNgDfaaRw03SSyzmlAzjswq7DDwwiS5sAOxVRRWQ9U88xXvyeYfqwggybT31zzHWMlPHE9UUcR27YZFfxHrixazrllbaqbdSLMlPHE9UUcR27YZFfxHrixanng7xszPmwkXMSOLLizrFnNMGxVmywwSmmWIoGszrllZJ4(xBm2VKYcbzH02SaQh(dKfqP7omWgcxbTEfmRpOJX8l(ITsMgOO0fqX01viCr5lGcJ0qFw)bYcOLE)OSCuwCwA)3XMfu56G2FKfBEuwEalXojilUsXcizzrrwOV)S89LKGpLLhWIoYI6seMLLfl2UFNfsTfYxozGfpHzHuGecGeKfpHzzrrw(DKf7sywOkWZcizjaZYnzrh87S89LKGpLfVrwajllkYc99NLVVKe8Pfqd99yFEbuiEFUUcnGSUOy97ljbFwImcwiJfTSejlFFjj4BE7mn6WrRbaqbdSLSmmWYiwG4956k0aY6II1VVKe8zjcwiJLHbwG4956k0aY6II1VVKe8zjcwkblJzrllJyjaGGPNVbcM)E0MfTSOVMttWRxgmllw0YYiw0xZPPDiycw06SX0(rnng7xszHaSmIfsZqowkfl9kXjOjIg6LZLQUhL(yFUbtxxHWSmMfcgblFFjj4BEYm6R5ScVA)pqYIww0xZPPDiycw06SX0(rnllwggyrFnNM2HGjyrRZgt7hTsVCUu19O0h7ZnllwgZYWalbaqbdSLMGxVmyAm2VKYcbyHmYXszS89LKGV5jZeaafmWwAGxT)hizrllJyjsw6vItqtenw9fdA4ZvvVdEEHQ1sr92GPRRqywggyrFnNMGxVmyAm2VKYszSObyzyGLaaOGb2stWRxgmng7xszrZy57ljbFZtMjaakyGT0aVA)pqYcbzHmYXYyw0YYiwIKLaacME(giy(7rBwggyjsw0xZPPDiycw06SX0(rnllw0YsaauWaBPPDiycw06SX0(rnng7xszzmlAzzelrYsaabtpFtEe3)60rwggy57ljbFZtMjaakyGT0aVA)pqYszSeaafmWwAcGecGeS(7yLAD99utJX(LuwggybI3NRRqtaKqaKGvyKgndSOLLVVKe8npzMaaOGb2sd8Q9)ajlLXsaauWaBPj41ldMgJ9lPSmMfTSejlbaem98nKeTppzzyGLaacME(M8iU)1PJSOLfiEFUUcnbqcbqcwHrA0mWIwwcaGcgylnbqcbqcw)DSsTU(EQzzXIwwIKLaaOGb2stWRxgmllw0YYiwgXI(AonyqDwuSQwP3MgJ9lPSuglKJLHbw0xZPbdQZIIvkq5TPXy)sklLXc5yzmlJzzyGf91CAi5s4gHRySfWg2Xy(vmXM4zF0SSyzmlddSOdOuw0YY8iU)1gJ9lPSqqwSBtwggybI3NRRqdiRlkw)(ssWNLiyzZcOuf4Pfq)(ssWNScOE4pqwa97ljbFYk(ITsgHSO0fqX01viCr5lG6H)azb0VVKe8TRaAOVh7ZlGcX7Z1vObK1ffRFFjj4ZsKrWIDSOLLiz57ljbFZtMPrhoAnaakyGTKLHbwG4956k0aY6II1VVKe8zjcwSJfTSmIf91CAcE9YGzzXIwwcaiy65BGG5VhTzrllJyrFnNM2HGjyrRZgt7h10ySFjLfcWYiwind5yPuS0ReNGMiAOxoxQ6Eu6J95gmDDfcZYywiyeS89LKGV5TZOVMZk8Q9)ajlAzrFnNM2HGjyrRZgt7h1SSyzyGf91CAAhcMGfToBmTF0k9Y5sv3JsFSp3SSyzmlddSeaafmWwAcE9YGPXy)skleGfYihlLXY3xsc(M3otaauWaBPbE1(FGKfTSmILizPxjobnr0y1xmOHpxv9o45fQwlf1BdMUUcHzzyGf91CAcE9YGPXy)sklLXIgGLHbwcaGcgylnbVEzW0ySFjLfnJLVVKe8nVDMaaOGb2sd8Q9)ajleKfYihlJzrllJyjswcaiy65BGG5VhTzzyGLizrFnNM2HGjyrRZgt7h1SSyrllbaqbdSLM2HGjyrRZgt7h10ySFjLLXSOLLrSejlbaem98n5rC)RthzzyGLVVKe8nVDMaaOGb2sd8Q9)ajlLXsaauWaBPjasiasW6VJvQ113tnng7xszzyGfiEFUUcnbqcbqcwHrA0mWIww((ssW382zcaGcgylnWR2)dKSuglbaqbdSLMGxVmyAm2VKYYyw0YsKSeaqW0Z3qs0(8KfTSmILizrFnNMGxVmywwSmmWsKSeaqW0Z3abZFpAZYywggyjaGGPNVjpI7FD6ilAzbI3NRRqtaKqaKGvyKgndSOLLaaOGb2staKqaKG1FhRuRRVNAwwSOLLizjaakyGT0e86LbZYIfTSmILrSOVMtdguNffRQv6TPXy)sklLXc5yzyGf91CAWG6SOyLcuEBAm2VKYszSqowgZYywgZYWal6R50qYLWncxXylGnSJX8RyInXZ(OzzXYWal6akLfTSmpI7FTXy)skleKf72KLHbwG4956k0aY6II1VVKe8zjcw2SakvbEAb0VVKe8TR4l2kz2trPlGIPRRq4IYxafgPH(S(dKfqlxkszXvkwa)o2SaswwuKL7XyklGKLaCbup8hilGUOy9EmMw8fBLSswrPlGIPRRq4IYxafgPH(S(dKfq1473XMfIawU8bS87il0NfqZIdqw8WFGKf1r)cOE4pqwaTxz1d)bYQ6OFbu63x4l2kzfqd99yFEbuiEFUUcnhT6aSaQ6OFn9ySaQdWIVyR2TzrPlGIPRRq4IYxa1d)bYcO9kRE4pqwvh9lGQo6xtpglGs)IV4lGA1yaeR7FrPl2kzfLUaQh(dKfqj5s4gHRuRRVNwaftxxHWfLV4l2QDfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaDZcOWin0N1FGSaAP3rwG4956kKLJYcfFwEalBYIT73zjbSqF)zbKSSOilFFjj4t1elKXITDmz53rwMxtFwajYYrzbKSSOOMyXowUjl)oYcfdGeMLJYINWSucwUjl6GFNfVXcOq8UMEmwafK1ffRFFjj4x8fBTefLUakMUUcHlkFbuGvbuhgUaQh(dKfqH4956kSakexTWcOKvan03J95fq)(ssW38Kz2DADrXQ(AozrllFFjj4BEYmbaqbdSLg4v7)bsw0YsKS89LKGV5jZCuZdIXkywJbj9BWIwdGK(9k8hiPfqH4Dn9ySakiRlkw)(ssWV4l2kPvu6cOy66keUO8fqbwfqDy4cOE4pqwafI3NRRWcOqC1clGAxb0qFp2Nxa97ljbFZBNz3P1ffR6R5KfTS89LKGV5TZeaafmWwAGxT)hizrllrYY3xsc(M3oZrnpigRGzngK0VblAnas63RWFGKwafI310JXcOGSUOy97ljb)IVyRKRO0fqX01viCr5lGcSkG6WWfq9WFGSakeVpxxHfqH4Dn9ySakiRlkw)(ssWVaAOVh7ZlGI276SSqyZL0qVExxHv7D55VIRWiKlGSmmWcAVRZYcHnySv0gDvf0WPNbKLHbwq7DDwwiSHcwkf()LeR9spAbuyKg6Z6pqwaT07ifz57ljbFklEJSKGNfF9Gy)VGRurzbgFm8imloLfqYYIISqF)z57ljbFQHfwGIplq8(CDfYYdyH0yXPS87yuwCffWsIimlulmCUILDpHvxs0uafIRwybusR4l2QgOO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOLytwkflJyHmw0mw20qg5yPuSqXVQdYf18h22zpvsZkWY4cOWin0N1FGSaku8PS87ilqFVPRMiYsaqFwMGMfL)yZsWvHLY)dKuwgnbnliH9ylfYITDmz5bSqFVFwGxXwxsKfDCcAKfcDJP9JYY0vkklG5CCbuiExtpglGsP1aG(fFXwjKfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaLCBYsPyzelKXIMXYMgYihlLIfk(vDqUOM)W2o7PsAwbwgxafI310JXcO0znaOFXxSv7PO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOLytwialKTjlLILEL4e0ertavi9pxvPwxFp1GPRRq4cOWin0N1FGSaku8PS4pl22VWolEmyLplGjlBHsiyHuGecGeKf6oyPGzrhzzrr4sIfsBtwSD)oy9SqkuH0)CflqTU(EklEcZsj2KfB3VBkGcX7A6Xyb0aiHaibRo1Q4l2AjRO0fq9WFGSaAmaKKCzDc64cOy66keUO8fFXwjBZIsxaftxxHWfLVaQh(dKfqT1(Vxan03J95fqhXcguNffnQv6Dnrc)SmmWcguNffnxwPaL3SmmWcguNffnxw1b)olddSGb1zrrJNrRjs4NLXfqvxI1aCbuY2S4l(cOoalkDXwjRO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcO9kXjOjIM)IrBGoRWn6X6xcJTbtxxHWSOLLrSOVMtZFXOnqNv4g9y9lHX20ySFjLfcYcXaSj2jmleGLnnKXYWal6R508xmAd0zfUrpw)sySnng7xszHGS4H)aPH(EpVgniHXW6X6FXileGLnnKXIwwgXcguNffnxwvR0BwggybdQZIIgkq5Dnrc)SmmWcguNffnEgTMiHFwgZYyw0YI(Aon)fJ2aDwHB0J1VegBZYQakmsd9z9hilGskxfwk)rkl22XFhBw(DKfnxJECW)Wo2SOVMtwSDkfltxPybmNSy7(9lz53rwsKWplbN(fqH4Dn9ySakCJEC12Pu1PRuvWCw8fB1UIsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGgjlyqDwu0CzLcuEZIwwOwOsvFVjIp1qFVNxJSuglesw0mwExH5BOGLQcM1FhRtqJ03GPRRqywkfl2XcbybdQZIIMlR6GFNfTSejl9kXjOjIgR(Ibn85QQ3bpVq1APOEBW01vimlAzjsw6vItqtenGe)DAnOqVRqo6bsdMUUcHlGcJ0qFw)bYcOKYvHLYFKYITD83XMfOV30vtez5OSyd0)olbN(xsKfaeSzb6798AKLlzrJwP3SOXb1zrXcOq8UMEmwa9iMGgR03B6QjIfFXwlrrPlGIPRRq4IYxa1d)bYcObqcbqcw)DSsTU(EAbuyKg6Z6pqwaTCPilKcKqaKGSyBhtw8NffsPS87EYc52KLTqjeS4jmlQlrwwwSy7(Dwi1wiF5KHcOH(ESpVa6iwgXceVpxxHMaiHaibRWinAgyrllrYsaauWaBPj41ldMgD4OSOLLizPxjobnr0y1xmOHpxv9o45fQwlf1BdMUUcHzzyGf91CAcE9YGzzXIwwgXsKS0ReNGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSmmWsVsCcAIOjGkK(NRQuRRVNAW01vimlddSmpI7FTXy)sklLXcz2rizzyGfDaLYIwwMhX9V2ySFjLfcYsaauWaBPj41ldMgJ9lPSqawiBtwggyrFnNMGxVmyAm2VKYszSqMDSmMLXSOLLrSmILrS40VDv1cydBwiyeSaX7Z1vOjasiasWQtTyzyGfQfQu13BI4tn03751ilLXsjyzmlAzzel6R50Gb1zrXQALEBAm2VKYszSq2MSmmWI(AonyqDwuSsbkVnng7xszPmwiBtwgZYWal6R50e86LbtJX(LuwkJfYXIww0xZPj41ldMgJ9lPSqWiyHm7yzmlAzzelrYY7kmFd9rLY7kCFZ3GPRRqywggyrFnNg6790vktJX(LuwiilKzihlAglBAihlLILEL4e0ertavi9pxvPwxFp1GPRRqywggyrFnNMGxVmyAm2VKYcbzrFnNg6790vktJX(LuwialKJfTSOVMttWRxgmllwgZIwwgXsKS0ReNGMiA(lgTb6Sc3OhRFjm2gmDDfcZYWalrYsVsCcAIOjGkK(NRQuRRVNAW01vimlddSOVMtZFXOnqNv4g9y9lHX20ySFjLLYybjmgwpw)lgzzmlddS0ReNGMiA0DLNbScMvxPQ)(LePgmDDfcZYyw0YYiwIKLEL4e0erJUR8mGvWS6kv93VKi1GPRRqywggyzel6R50O7kpdyfmRUsv)9ljsRP)Rgn03dKWseSypSmmWI(Aon6UYZawbZQRu1F)sI0Q3bprd99ajSebl2dlJzzmlddSOdOuw0YY8iU)1gJ9lPSqqwiBtw0YsKSeaafmWwAcE9YGPrhoklJl(ITsAfLUakMUUcHlkFbup8hilGsx58ASaAiAqH13BI4tl2kzfqd99yFEb0rS04Sr6URRqwggyrFnNgmOolkwPaL3MgJ9lPSqqwkblAzbdQZIIMlRuGYBw0YsJX(LuwiilKrASOLL3vy(gkyPQGz93X6e0i9ny66keMLXSOLL3BI4B(lgRpOcFilLXczKglAgluluPQV3eXNYcbyPXy)sklAzzelyqDwu0Cz1ZOSmmWsJX(LuwiiledWMyNWSmUakmsd9z9hilGwUuKfORCEnYYLSy5jmgFbwajlEg93VKil)U)SOoiiLfYinkgOS4jmlkKszX297SedAKL3BI4tzXtyw8NLFhzbtywatwCwGcuEZIghuNffzXFwiJ0yHIbklGMffsPS0ySF5LezXPS8awsWZYUd5sIS8awAC2iDNf4vFjrw0Ov6nlACqDwuS4l2k5kkDbumDDfcxu(cOE4pqwaLUY51ybuyKg6Z6pqwaTCPilqx58AKLhWYUdbzXzHOcO7kwEallkYs5O5dnxb0qFp2NxafI3NRRqZzVW1aiHV)ajlAzjaakyGT0Cjn0R31vy1ExE(R4kmc5cOPrhoklAzbT31zzHWMlPHE9UUcR27YZFfxHrixazrllUvnSJbsk(ITQbkkDbumDDfcxu(cOE4pqwaL(EpDLQakmsd9z9hilGwYfrlwwwSa99E6kfl(ZIRuS8xmszzLkKszzrVKilAu0G3oLfpHz5EwoklUoy9S8awSAqGfqZIcFw(DKfQfgoxXIh(dKSOUezrhvaBSS7jSczrZ1OhRFjm2SaswSJL3BI4tlGg67X(8cOrYY7kmFd9rLY7kCFZ3GPRRqyw0YYiwIKfk(vDqUOM)W2o7PsAwbwggybdQZIIMlREgLLHbwOwOsvFVjIp1qFVNUsXszSucwgZIwwgXI(Aon037PRuMgNns3DDfYIwwgXc1cvQ67nr8Pg6790vkwiilLGLHbwIKLEL4e0erZFXOnqNv4g9y9lHX2GPRRqywgZYWalVRW8nuWsvbZ6VJ1jOr6BW01vimlAzrFnNgmOolkwPaL3MgJ9lPSqqwkblAzbdQZIIMlRuGYBw0YI(Aon037PRuMgJ9lPSqqwiKSOLfQfQu13BI4tn037PRuSuweSqASmMfTSmILizPxjobnr0OIg82P1PcX)sIvIQl2IIgmDDfcZYWal)fJSObzH0ihlLXI(Aon037PRuMgJ9lPSqawSJLXSOLL3BI4B(lgRpOcFilLXc5k(ITsilkDbumDDfcxu(cOE4pqwaL(EpDLQakmsd9z9hilGsOC)olqFuP8MfnxFZNLffzbKSeGzX2oMS04Sr6URRqw0xpl0)ukwS53ZYe0SOrrdE7uwSAqGfpHzbgKB)SSOil64e0ilKsZrnSa9pLILffzrhNGgzHuGecGeKf6LbKLF3FwSDkflwniWINGFhBwG(EpDLQaAOVh7ZlG(UcZ3qFuP8Uc338ny66keMfTSOVMtd99E6kLPXzJ0DxxHSOLLrSejlu8R6GCrn)HTD2tL0ScSmmWcguNffnxw9mklddSqTqLQ(EteFQH(EpDLILYyPeSmMfTSmILizPxjobnr0OIg82P1PcX)sIvIQl2IIgmDDfcZYWal)fJSObzH0ihlLXcPXYyw0YY8iU)1gJ9lPSuglLO4l2Q9uu6cOy66keUO8fq9WFGSak99E6kvbuyKg6Z6pqwaLq5(Dw0Cn6X6xcJnllkYc037PRuS8awibrlwwwS87il6R5Kf9OS4kkGLf9sISa99E6kflGKfYXcfdGeMYcOzrHuklng7xEjXcOH(ESpVaAVsCcAIO5Vy0gOZkCJES(LWyBW01vimlAzHAHkv99Mi(ud99E6kflLfblLGfTSmILizrFnNM)IrBGoRWn6X6xcJTzzXIww0xZPH(EpDLY04Sr6URRqwggyzelq8(CDfAGB0JR2oLQoDLQcMtw0YYiw0xZPH(EpDLY0ySFjLfcYsjyzyGfQfQu13BI4tn037PRuSugl2XIwwExH5BOpQuExH7B(gmDDfcZIww0xZPH(EpDLY0ySFjLfcYc5yzmlJzzCXxS1swrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfqD63UQAbSHnlLXI9SjlLILrSqglAglu8R6GCrn)HTD2t1oRalLILnn2XYywkflJyHmw0mw0xZP5Vy0gOZkCJES(LWyBOVhiHLsXYMgYyzmlAglJyrFnNg6790vktJX(LuwkflLGfYZc1cvQ6UtFKLsXsKS8UcZ3qFuP8Uc338ny66keMLXSOzSmILaaOGb2sd99E6kLPXy)sklLILsWc5zHAHkvD3PpYsPy5DfMVH(Os5DfUV5BW01vimlJzrZyzel6R50mxD0kywr1krtJX(LuwkflKJLXSOLLrSOVMtd99E6kLzzXYWalbaqbdSLg6790vktJX(LuwgxafgPH(S(dKfqjLRclL)iLfB74VJnlolqFVPRMiYYIISy7ukwc(IISa99E6kflpGLPRuSaMtnXINWSSOilqFVPRMiYYdyHeeTyrZ1OhRFjm2SqFpqcllldl2ZMSCuw(DKLgT311imlBHsiy5bSeC6Zc03B6QjIea6790vQcOq8UMEmwaL(EpDLQAdKFD6kvfmNfFXwjBZIsxaftxxHWfLVaQh(dKfqPV30vtelGcJ0qFw)bYcOLlfzb67nD1erwSD)olAUg9y9lHXMLhWcjiAXYYILFhzrFnNSy7(DW6zrbOxsKfOV3txPyzz9xmYINWSSOilqFVPRMiYcizH0ialLhSLsZc99ajuww5FkwinwEVjIpTaAOVh7ZlGcX7Z1vObUrpUA7uQ60vQkyozrllq8(CDfAOV3txPQ2a5xNUsvbZjlAzjswG4956k0CetqJv67nD1erwggyzel6R50O7kpdyfmRUsv)9ljsRP)Rgn03dKWszSucwggyrFnNgDx5zaRGz1vQ6VFjrA17GNOH(EGewkJLsWYyw0Yc1cvQ67nr8Pg6790vkwiilKglAzbI3NRRqd99E6kv1gi)60vQkyol(ITsgzfLUakMUUcHlkFbup8hilG6WU1FqWk1M3XfqdrdkS(EteFAXwjRaAOVh7ZlGgjl)fi5sISOLLizXd)bsJd7w)bbRuBEhxH9yNiAUSovhX9NLHbwGbVXHDR)GGvQnVJRWESten03dKWcbzPeSOLfyWBCy36piyLAZ74kSh7ertJX(LuwiilLOakmsd9z9hilGwUuKfQnVJzHcy539NLOGfleXNLyNWSSS(lgzrpkll6Lez5EwCklk)rwCklwak90vilGKffsPS87EYsjyH(EGeklGMfnFx0NfB7yYsjial03dKqzbjS11yXxSvYSRO0fqX01viCr5lG6H)azb0yaiNxJfqdrdkS(EteFAXwjRaAOVh7ZlG24Sr6URRqw0YY7nr8n)fJ1huHpKLYyzelJyHmsJfcWYiwOwOsvFVjIp1qFVNxJSukwSJLsXI(AonyqDwuSQwP3MLflJzzmleGLgJ9lPSmMfYZYiwiJfcWY7kmFZB7YAmaKudMUUcHzzmlAzXPF7QQfWg2Suglq8(CDfAOZAaqFw0mw0xZPH(EpDLY0ySFjLLsXIgGfTSmIf3Qg2XajSmmWceVpxxHMJycASsFVPRMiYYWalrYcguNffnxw9mklJzrllJyjaakyGT0e86LbtJoCuw0YcguNffnxw9mklAzzelq8(CDfAcGecGeScJ0OzGLHbwcaGcgylnbqcbqcw)DSsTU(EQPrhoklddSejlbaem98n5rC)RthzzmlddSqTqLQ(EteFQH(EpVgzHGSmILrSypSOzSmIf91CAWG6SOyvTsVnllwkflLGLXSmMLsXYiwiJfcWY7kmFZB7YAmaKudMUUcHzzmlJzrllrYcguNffnuGY7AIe(zrllJyjswcaGcgylnbVEzW0OdhLLXSmmWYiwWG6SOO5YkfO8MLHbw0xZPbdQZIIv1k92SSyrllrYY7kmFdfSuvWS(7yDcAK(gmDDfcZYyw0YYiwOwOsvFVjIp1qFVNxJSqqwiBtwkflJyHmwialVRW8nVTlRXaqsny66keMLXSmMLXSOLLrSejlbaem98nKeTppzzyGLizrFnNgsUeUr4kgBbSHDmMFftSjE2hnllwggybdQZIIMlRuGYBwgZIwwIKf91CAAhcMGfToBmTF0k9Y5sv3JsFSp3SSkGcJ0qFw)bYcOL84Sr6olAEaqoVgz5MSqQTq(YjdSCuwA0HJQjw(DSrw8gzrHukl)UNSqowEVjIpLLlzrJwP3SOXb1zrrwSD)olqbpHwtSOqkLLF3twiBtwa)o22okYYLS4zuw04G6SOilGMLLflpGfYXY7nr8PSOJtqJS4SOrR0Bw04G6SOOHfnhi3(zPXzJ0DwGx9LezPK7LWncZIghBbSHDmMplRuHuklxYcuGYBw04G6SOyXxSvYkrrPlGIPRRq4IYxa1d)bYcOtqhWkywt)xnwafgPH(S(dKfqlxkYcHgSvwajlbywSD)oy9SeClRljwan03J95fqDRAyhdKWYWalq8(CDfAoIjOXk99MUAIyXxSvYiTIsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGoIfiEFUUcnb4AaKW3FGKfTSmIf91CAOV3txPmllwggy5DfMVH(Os5DfUV5BW01vimlddSeaqW0Z3KhX9VoDKLXSOLfyWBIbGCEnA(lqYLezrllJyjsw0xZPHcu0)cOzzXIwwIKf91CAcE9YGzzXIwwgXsKS8UcZ3mxD0kywr1krdMUUcHzzyGf91CAcE9YGbE1(FGKLYyjaakyGT0mxD0kywr1krtJX(Luwial2dlJzrllJyjswO4x1b5IA(dB7SNQDwbwggybdQZIIMlRQv6nlddSGb1zrrdfO8UMiHFwgZIwwG4956k0879PuvkIKGD1MFplAzzelrYsaabtpFtEe3)60rwggybI3NRRqtaKqaKGvyKgndSmmWsaauWaBPjasiasW6VJvQ113tnng7xszHGSqg5yzmlAz59Mi(M)IX6dQWhYszSOVMttWRxgmWR2)dKSukw20qizzmlddSOdOuw0YY8iU)1gJ9lPSqqw0xZPj41ldg4v7)bswialKzhlLILEL4e0erJvFXGg(Cv17GNxOATuuVny66keMLXfqH4Dn9ySaAaUgaj89hiRoal(ITsg5kkDbumDDfcxu(cOE4pqwaTDiycw06SX0(rlGcJ0qFw)bYcOLlfzHq3yA)OSy7(Dwi1wiF5KHcOH(ESpVaQ(AonbVEzW0ySFjLLYyHmYXYWal6R50e86Lbd8Q9)ajleGfYSJLsXsVsCcAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZcbzXonalAzbI3NRRqtaUgaj89hiRoal(ITsMgOO0fqX01viCr5lG6H)azb0aQq6FUQ6QJygJ5xafgPH(S(dKfqlxkYcP2c5lNmWcizjaZYkviLYINWSOUez5EwwwSy7(DwifiHaiblGg67X(8cOq8(CDfAcW1aiHV)az1bilAzzelrYsaabtpFdem)9OnlddSejl9kXjOjIg6LZLQUhL(yFUbtxxHWSmmWsVsCcAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZYWal6R50e86Lbd8Q9)ajlLfbl2PbyzmlddSOVMtt7qWeSO1zJP9JAwwSOLf91CAAhcMGfToBmTFutJX(LuwiilKrod5k(ITsgHSO0fqX01viCr5lGg67X(8cOq8(CDfAcW1aiHV)az1bybup8hilGEzW70)dKfFXwjZEkkDbumDDfcxu(cOE4pqwafJTa2WUQds4cOWin0N1FGSaA5srw04ylGnSzP8GeMfqYsaMfB3VZc037PRuSSSyXtywOoeKLjOzHqSuuVzXtywi1wiF5KHcOH(ESpVa6iwcaGcgylnbVEzW0ySFjLfcWI(AonbVEzWaVA)pqYcbyPxjobnr0y1xmOHpxv9o45fQwlf1BdMUUcHzPuSqMDSuglbaqbdSLgm2cyd7QoiHnWR2)dKSqawiBtwgZYWal6R50e86LbtJX(LuwkJf7P4l2kzLSIsxaftxxHWfLVaQh(dKfqPpQuExNkVXcOHObfwFVjIpTyRKvan03J95fqBC2iD31vilAz5VyS(Gk8HSuglKrow0Yc1cvQ67nr8Pg6798AKfcYcPXIwwCRAyhdKWIwwgXI(AonbVEzW0ySFjLLYyHSnzzyGLizrFnNMGxVmywwSmUakmsd9z9hilGwYJZgP7SmvEJSaswwwS8awkblV3eXNYIT73bRNfsTfYxozGfD8sIS46G1ZYdybjS11ilEcZscEwaqWo4wwxsS4l2QDBwu6cOy66keUO8fq9WFGSa6C1rRGzfvRelGcJ0qFw)bYcOLlfzHqd0ywUjlxspyKfpzrJdQZIIS4jmlQlrwUNLLfl2UFNfNfcXsr9MfRgeyXtyw2cSB9heKfO28oUaAOVh7ZlGIb1zrrZLvpJYIwwgXIBvd7yGewggyjsw6vItqtenw9fdA4ZvvVdEEHQ1sr92GPRRqywgZIwwgXI(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKfcYIDKBtwggyrFnNMGxVmyAm2VKYszSypSmMfTSmIfyWBCy36piyLAZ74kSh7erZFbsUKilddSejlbaem98njgAGc0WSmmWc1cvQ67nr8PSugl2XYyw0YYiw0xZPPDiycw06SX0(rnng7xszHGSuYyrZyzelKglLILEL4e0erd9Y5sv3JsFSp3GPRRqywgZIww0xZPPDiycw06SX0(rnllwggyjsw0xZPPDiycw06SX0(rnllwgZIwwgXsKSeaafmWwAcE9YGzzXYWal6R50879PuvkIKGTH(EGewiilKrow0YY8iU)1gJ9lPSqqwSBZnzrllZJ4(xBm2VKYszSq2MBYYWalrYcfSu6xcB(9(uQkfrsW2GPRRqywgZIwwgXcfSu6xcB(9(uQkfrsW2GPRRqywggyjaakyGT0e86LbtJX(LuwkJLsSjlJzrllV3eX38xmwFqf(qwkJfYXYWal6akLfTSmpI7FTXy)skleKfY2S4l2QDKvu6cOy66keUO8fq9WFGSak99E6kvbuyKg6Z6pqwaTCPilolqFVNUsXcHAI)olwniWYkviLYc037PRuSCuwCvJoCuwwwSaAwIcwS4nYIRdwplpGfaeSdUflBHsikGg67X(8cO6R50as83PvlSdO1FG0SSyrllJyrFnNg6790vktJZgP7UUczzyGfN(TRQwaByZszSuY2KLXfFXwTZUIsxaftxxHWfLVaQh(dKfqPV3txPkGcJ0qFw)bYcOAUvSflBHsiyrhNGgzHuGecGeKfB3VZc037PRuS4jml)oMSa99MUAIyb0qFp2NxanaGGPNVjpI7FD6ilAzjswExH5BOpQuExH7B(gmDDfcZIwwgXceVpxxHMaiHaibRWinAgyzyGLaaOGb2stWRxgmllwggyrFnNMGxVmywwSmMfTSeaafmWwAcGecGeS(7yLAD99utJX(LuwiiledWMyNWSukwc4Pyzelo9BxvTa2WMfYZceVpxxHg6Sga0NLXSOLf91CAOV3txPmng7xszHGSqAfFXwTRefLUakMUUcHlkFb0qFp2NxanaGGPNVjpI7FD6ilAzzelq8(CDfAcGecGeScJ0OzGLHbwcaGcgylnbVEzWSSyzyGf91CAcE9YGzzXYyw0YsaauWaBPjasiasW6VJvQ113tnng7xszHGSqow0YceVpxxHg6790vQQnq(1PRuvWCYIwwWG6SOO5YQNrzrllrYceVpxxHMJycASsFVPRMiwa1d)bYcO03B6QjIfFXwTJ0kkDbumDDfcxu(cOE4pqwaL(EtxnrSakmsd9z9hilGwUuKfOV30vtezX297S4jleQj(7Sy1GalGMLBYsuWABywaqWo4wSSfkHGfB3VZsuWQzjrc)SeC6ByzlkkGf4vSflBHsiyXFw(DKfmHzbmz53rwk5G5VhTzrFnNSCtwG(EpDLIfBGLco3(zz6kflG5KfqZsuWIfVrwajl2XY7nr8Pfqd99yFEbu91CAaj(70AqHExHC0dKMLflddSmILizH(EpVgnUvnSJbsyrllrYceVpxxHMJycASsFVPRMiYYWalJyrFnNMGxVmyAm2VKYcbzHCSOLf91CAcE9YGzzXYWalJyzel6R50e86LbtJX(LuwiiledWMyNWSukwc4Pyzelo9BxvTa2WMfYZceVpxxHgkTga0NLXSOLf91CAcE9YGzzXYWal6R500oemblAD2yA)Ov6LZLQUhL(yFUPXy)skleKfIbytStywkflb8uSmIfN(TRQwaByZc5zbI3NRRqdLwda6ZYyw0YI(AonTdbtWIwNnM2pALE5CPQ7rPp2NBwwSmMfTSeaqW0Z3abZFpAZYywgZIwwgXc1cvQ67nr8Pg6790vkwiilLGLHbwG4956k0qFVNUsvTbYVoDLQcMtwgZYyw0YsKSaX7Z1vO5iMGgR03B6QjISOLLrSejl9kXjOjIM)IrBGoRWn6X6xcJTbtxxHWSmmWc1cvQ67nr8Pg6790vkwiilLGLXfFXwTJCfLUakMUUcHlkFbup8hilGMOTAmaKfqHrAOpR)azb0YLISO5bajLLlzbkq5nlACqDwuKfpHzH6qqwi0lLIfnpaizzcAwi1wiF5KHcOH(ESpVa6iw0xZPbdQZIIvkq5TPXy)sklLXcsymSES(xmYYWalJyjS7nrKYseSyhlAzPXWU3eX6FXileKfYXYywggyjS7nrKYseSucwgZIwwCRAyhdKu8fB1onqrPlGIPRRq4IYxan03J95fqhXI(AonyqDwuSsbkVnng7xszPmwqcJH1J1)IrwggyzelHDVjIuwIGf7yrllng29Miw)lgzHGSqowgZYWalHDVjIuwIGLsWYyw0YIBvd7yGew0YYiw0xZPPDiycw06SX0(rnng7xszHGSqow0YI(AonTdbtWIwNnM2pQzzXIwwIKLEL4e0erd9Y5sv3JsFSp3GPRRqywggyjsw0xZPPDiycw06SX0(rnllwgxa1d)bYcO7UAwJbGS4l2QDeYIsxaftxxHWfLVaAOVh7ZlGoIf91CAWG6SOyLcuEBAm2VKYszSGegdRhR)fJSOLLrSeaafmWwAcE9YGPXy)sklLXc52KLHbwcaGcgylnbqcbqcw)DSsTU(EQPXy)sklLXc52KLXSmmWYiwc7EtePSebl2XIwwAmS7nrS(xmYcbzHCSmMLHbwc7EtePSeblLGLXSOLf3Qg2XajSOLLrSOVMtt7qWeSO1zJP9JAAm2VKYcbzHCSOLf91CAAhcMGfToBmTFuZYIfTSejl9kXjOjIg6LZLQUhL(yFUbtxxHWSmmWsKSOVMtt7qWeSO1zJP9JAwwSmUaQh(dKfqNlLQgdazXxSv7SNIsxaftxxHWfLVakmsd9z9hilGwUuKfcfGgZcizHuAUcOE4pqwa1M39b6kywr1kXIVyR2vYkkDbumDDfcxu(cOaRcOu8lG6H)azbuiEFUUclGcXvlSak1cvQ67nr8Pg6798AKLYyH0yHaSmvaqZYiwID6JD0kexTqwkflKT5MSqEwSBtwgZcbyzQaGMLrSOVMtd99MUAIyfJTa2WogZVsbkVn03dKWc5zH0yzCbuyKg6Z6pqwaLuUkSu(JuwSTJ)o2S8awwuKfOV3ZRrwUKfOaL3SyB)c7SCuw8NfYXY7nr8PeGmwMGMfec2rzXUn1GSe70h7OSaAwinwG(EtxnrKfno2cyd7ymFwOVhiHwafI310JXcO03751y9YkfO8U4l2Aj2SO0fqX01viCr5lG6H)azbuBT)7fqHrAOpR)azbuc1Kf7y59Mi(uwSD)oy9SafSuSaMS87ileAqJ0NLOGfl0DWsbZY8ukwSD)olekT)7SaV6ljYs5KHcOH(ESpVaAKSOVMtt7qWeSO1zJP9JAwwSOLLizrFnNM2HGjyrRZgt7hTsVCUu19O0h7Znllw0YsKS8UcZ3qblvfmR)owNGgPVbtxxHWSOLfQfQu13BI4tn03751ileKLsWIww0xZPbdQZIIvkq5TPXy)sklLXcsymSES(xmYIwwMhX9V2ySFjLLYyrFnNMGxVmyAm2VKYcbyHm7yPuS0ReNGMiAS6lg0WNRQEh88cvRLI6TbtxxHWfFXwlbzfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaLmwipluluPQ7o9rwiil2XIMXYiw20yhlLILrSmIfQfQu13BI4tn03751ilAglKXYywiplJyzeluluPQV3eXNAOV3ZRrw0mwiJLXSqEwSBtwialKXYywgZsPyzelKXcby5DfMVHcwQkyw)DSobnsFdMUUcHzPuSqMHCSmMLXSqaw20qg5yPuSOVMtt7qWeSO1zJP9JAAm2VKwafgPH(S(dKfqjLRclL)iLfB74VJnlpGfcL2)DwGx9LezHq3yA)OfqH4Dn9ySaQT2)96L1zJP9Jw8fBTe2vu6cOy66keUO8fq9WFGSaQT2)9cOWin0N1FGSaA5srwiuA)3z5swGcuEZIghuNffzb0SCtwsalqFVNxJSy7ukwM3ZYLpGfsTfYxozGfpJgdASaAOVh7ZlGoIfmOolkAuR07AIe(zzyGfmOolkA8mAnrc)SOLfiEFUUcnhTguOdbzzmlAzzelV3eX38xmwFqf(qwkJfsJLHbwWG6SOOrTsVRxwTJLHbw0buklAzzEe3)AJX(LuwiilKTjlJzzyGf91CAWG6SOyLcuEBAm2VKYcbzXd)bsd99EEnAqcJH1J1)Irw0YI(AonyqDwuSsbkVnllwggybdQZIIMlRuGYBw0YsKSaX7Z1vOH(EpVgRxwPaL3SmmWI(AonbVEzW0ySFjLfcYIh(dKg6798A0GegdRhR)fJSOLLizbI3NRRqZrRbf6qqw0YI(AonbVEzW0ySFjLfcYcsymSES(xmYIww0xZPj41ldMLflddSOVMtt7qWeSO1zJP9JAwwSOLfiEFUUcn2A)3RxwNnM2pklddSejlq8(CDfAoAnOqhcYIww0xZPj41ldMgJ9lPSugliHXW6X6FXyXxS1suIIsxaftxxHWfLVakmsd9z9hilGwUuKfOV3ZRrwUjlxYIgTsVzrJdQZIIAILlzbkq5nlACqDwuKfqYcPrawEVjIpLfqZYdyXQbbwGcuEZIghuNfflG6H)azbu6798AS4l2AjiTIsxaftxxHWfLVakmsd9z9hilGsODL637vbup8hilG2RS6H)azvD0VaQ6OFn9ySa60vQFVxfFXxaD6k1V3RIsxSvYkkDbumDDfcxu(cOE4pqwaL(EtxnrSakmsd9z9hilGc99MUAIiltqZsmacgJ5ZYkviLYYIEjrwkpylLUaAOVh7ZlGgjl9kXjOjIgDx5zaRGz1vQ6VFjrQbT31zzHWfFXwTRO0fqX01viCr5lG6H)azbu6kNxJfqdrdkS(EteFAXwjRaAOVh7ZlGcdEtmaKZRrtJX(LuwkJLgJ9lPSukwSZowiplKzpfqHrAOpR)azbus50NLFhzbg8Sy7(Dw(DKLya9z5VyKLhWIddZYk)tXYVJSe7eMf4v7)bswokl73Byb6kNxJS0ySFjLL4L6pl1HWS8awI9pSZsmaKZRrwGxT)hil(ITwIIsxa1d)bYcOXaqoVglGIPRRq4IYx8fFbu6xu6ITswrPlGIPRRq4IYxa1d)bYcOoSB9heSsT5DCb0q0GcRV3eXNwSvYkGg67X(8cOrYcm4noSB9heSsT5DCf2JDIO5VajxsKfTSejlE4pqACy36piyLAZ74kSh7erZL1P6iU)SOLLrSejlWG34WU1FqWk1M3X1D0vM)cKCjrwggybg8gh2T(dcwP28oUUJUY0ySFjLLYyHCSmMLHbwGbVXHDR)GGvQnVJRWESten03dKWcbzPeSOLfyWBCy36piyLAZ74kSh7ertJX(LuwiilLGfTSadEJd7w)bbRuBEhxH9yNiA(lqYLelGcJ0qFw)bYcOLlfzzlWU1FqqwGAZ7ywSTJjl)o2ilhLLeWIh(dcYc1M3XAIfNYIYFKfNYIfGspDfYcizHAZ7ywSD)ol2XcOzzI2WMf67bsOSaAwajlolLGaSqT5Dmlual)U)S87iljAJfQnVJzX7(GGuw08DrFw85Jnl)U)SqT5DmliHTUgPfFXwTRO0fqX01viCr5lG6H)azb0aiHaibR)owPwxFpTakmsd9z9hilGwUuKYcPajeajil3KfsTfYxozGLJYYYIfqZsuWIfVrwGrA0mCjrwi1wiF5KbwSD)olKcKqaKGS4jmlrblw8gzrhvaBSqABs(sS5isHkK(NRybQ113thZYwOecwUKfNfY2KaSqXalACqDwu0WYwuualWGC7Nff(SO5A0J1VegBwqcBDnQjwCLnpkLLffz5swi1wiF5KbwSD)oleILI6nlEcZI)S87il037NfWKfNLYd2sPzX2LWaBMcOH(ESpVa6iwgXceVpxxHMaiHaibRWinAgyrllrYsaauWaBPj41ldMgD4OSOLLizPxjobnr0y1xmOHpxv9o45fQwlf1BdMUUcHzzyGf91CAcE9YGzzXIwwgXsKS0ReNGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSmmWsVsCcAIOjGkK(NRQuRRVNAW01vimlddSmpI7FTXy)sklLXcz2rizzyGfDaLYIwwMhX9V2ySFjLfcYsaauWaBPj41ldMgJ9lPSqawiBtwggyrFnNMGxVmyAm2VKYszSqMDSmMLXSOLLrSmIfN(TRQwaByZcbJGfiEFUUcnbqcbqcwDQflAzzel6R50Gb1zrXQALEBAm2VKYszSq2MSmmWI(AonyqDwuSsbkVnng7xszPmwiBtwgZYWal6R50e86LbtJX(LuwkJfYXIww0xZPj41ldMgJ9lPSqWiyHm7yzmlAzzelrYsVsCcAIO5Vy0gOZkCJES(LWyBW01vimlddSejl9kXjOjIMaQq6FUQsTU(EQbtxxHWSmmWI(Aon)fJ2aDwHB0J1VegBtJX(LuwkJfKWyy9y9VyKLXSmmWsVsCcAIOr3vEgWkywDLQ(7xsKAW01vimlJzrllJyjsw6vItqten6UYZawbZQRu1F)sIudMUUcHzzyGLrSOVMtJUR8mGvWS6kv93VKiTM(VA0qFpqclrWI9WYWal6R50O7kpdyfmRUsv)9ljsREh8en03dKWseSypSmMLXSmmWIoGszrllZJ4(xBm2VKYcbzHSnzrllrYsaauWaBPj41ldMgD4OSmU4l2AjkkDbumDDfcxu(cOE4pqwaL(EtxnrSakmsd9z9hilGwUuKfOV30vtez5bSqcIwSSSy53rw0Cn6X6xcJnl6R5KLBYY9SydSuWSGe26AKfDCcAKL5LhD)sIS87iljs4NLGtFwanlpGf4vSfl64e0ilKcKqaKGfqd99yFEb0EL4e0erZFXOnqNv4g9y9lHX2GPRRqyw0YYiwIKLrSmIf91CA(lgTb6Sc3OhRFjm2MgJ9lPSuglE4pqAS1(VBqcJH1J1)IrwialBAiJfTSmIfmOolkAUSQd(DwggybdQZIIMlRuGYBwggybdQZIIg1k9UMiHFwgZYWal6R508xmAd0zfUrpw)sySnng7xszPmw8WFG0qFVNxJgKWyy9y9VyKfcWYMgYyrllJybdQZIIMlRQv6nlddSGb1zrrdfO8UMiHFwggybdQZIIgpJwtKWplJzzmlddSejl6R508xmAd0zfUrpw)sySnllwgZYWalJyrFnNMGxVmywwSmmWceVpxxHMaiHaibRWinAgyzmlAzjaakyGT0eajeajy93Xk1667PMgD4OSOLLaacME(M8iU)1PJSOLLrSOVMtdguNffRQv6TPXy)sklLXczBYYWal6R50Gb1zrXkfO820ySFjLLYyHSnzzmlJzrllJyjswcaiy65BijAFEYYWalbaqbdSLgm2cyd7QoiHnng7xszPmwShwgx8fBL0kkDbumDDfcxu(cOE4pqwaL(EtxnrSakmsd9z9hilGQ5wXwSa99MUAIiLfB3VZs5DLNbKfWKLTOuSu69ljszb0S8awSA0YBKLjOzHuGecGeKfB3VZs5bBP0fqd99yFEb0EL4e0erJUR8mGvWS6kv93VKi1GPRRqyw0YYiwgXI(Aon6UYZawbZQRu1F)sI0A6)Qrd99ajSugl2XYWal6R50O7kpdyfmRUsv)9ljsREh8en03dKWszSyhlJzrllbaqbdSLMGxVmyAm2VKYszSqizrllrYsaauWaBPjasiasW6VJvQ113tnllwggyzelbaem98n5rC)RthzrllbaqbdSLMaiHaibR)owPwxFp10ySFjLfcYczBYIwwWG6SOO5YQNrzrllo9BxvTa2WMLYyXUnzHaSuInzPuSeaafmWwAcE9YGPrhoklJzzCXxSvYvu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0rSOVMtt7qWeSO1zJP9JAAm2VKYszSqowggyjsw0xZPPDiycw06SX0(rnllwgZIwwIKf91CAAhcMGfToBmTF0k9Y5sv3JsFSp3SSyrllJyrFnNgsUeUr4kgBbSHDmMFftSjE2hnng7xszHGSqmaBIDcZYyw0YYiw0xZPbdQZIIvkq5TPXy)sklLXcXaSj2jmlddSOVMtdguNffRQv6TPXy)sklLXcXaSj2jmlddSmILizrFnNgmOolkwvR0BZYILHbwIKf91CAWG6SOyLcuEBwwSmMfTSejlVRW8nuGI(xany66keMLXfqHrAOpR)azbusbs47pqYYe0S4kflWGNYYV7plXojiLf6Qrw(DmklEJ52plnoBKUJWSyBhtwk5Diycwuwi0nM2pkl7oLffsPS87EYc5yHIbklng7xEjrwanl)oYIghBbSHnlLhKWSOVMtwoklUoy9S8awMUsXcyozb0S4zuw04G6SOilhLfxhSEwEaliHTUglGcX7A6XybuyWxB0ExxJXy(0IVyRAGIsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGoILizrFnNgmOolkwPaL3MLflAzjsw0xZPbdQZIIv1k92SSyzmlAzjswExH5BOaf9VaAW01vimlAzjsw6vItqten)fJ2aDwHB0J1VegBdMUUcHlGcJ0qFw)bYcOKcKW3FGKLF3Fwc7yGekl3KLOGflEJSawp9GrwWG6SOilpGfqQIYcm4z53Xgzb0SCetqJS87hLfB3VZcuGI(xalGcX7A6XybuyWxbRNEWyfdQZIIfFXwjKfLUakMUUcHlkFbup8hilGgda58ASaAiAqH13BI4tl2kzfqd99yFEb0rSOVMtdguNffRuGYBtJX(LuwkJLgJ9lPSmmWI(AonyqDwuSQwP3MgJ9lPSuglng7xszzyGfiEFUUcnWGVcwp9GXkguNffzzmlAzPXzJ0DxxHSOLL3BI4B(lgRpOcFilLXcz2XIwwCRAyhdKWIwwG4956k0ad(AJ276AmgZNwafgPH(S(dKfq1CGNfxPy59Mi(uwSD)(LSqi8egJVal2UFhSEwaqWo4wwxsKa)oYIRdGGSeaj89hiPfFXwTNIsxaftxxHWfLVaQh(dKfqPRCEnwan03J95fqhXI(AonyqDwuSsbkVnng7xszPmwAm2VKYYWal6R50Gb1zrXQALEBAm2VKYszS0ySFjLLHbwG4956k0ad(ky90dgRyqDwuKLXSOLLgNns3DDfYIwwEVjIV5VyS(Gk8HSuglKzhlAzXTQHDmqclAzbI3NRRqdm4RnAVRRXymFAb0q0GcRV3eXNwSvYk(ITwYkkDbumDDfcxu(cOE4pqwaL(Os5DDQ8glGg67X(8cOJyrFnNgmOolkwPaL3MgJ9lPSuglng7xszzyGf91CAWG6SOyvTsVnng7xszPmwAm2VKYYWalq8(CDfAGbFfSE6bJvmOolkYYyw0YsJZgP7UUczrllV3eX38xmwFqf(qwkJfY0aSOLf3Qg2XajSOLfiEFUUcnWGV2O9UUgJX8PfqdrdkS(EteFAXwjR4l2kzBwu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0aacME(giy(7rBw0YsKS0ReNGMiAOxoxQ6Eu6J95gmDDfcZIwwIKLEL4e0ert46GcRGzvDtS6jCfg9F3GPRRqyw0YsaauWaBPrhBk2KCjrtJoCuw0YsaauWaBPPDiycw06SX0(rnn6WrzrllrYI(AonbVEzWSSyrllJyXPF7QQfWg2Sugl2dHKLHbw0xZPrxbaWQf9nllwgxafgPH(S(dKfq1CGNL(iU)SOJtqJSqOBmTFuwUjl3ZInWsbZIRuaBSefSy5bS04Sr6olkKszbE1xsKfcDJP9JYYOF)OSasvuw2DllmPSy7(DW6zb6LZLIfn)JsFSpFCbuiExtpglGMG6Eu6J95v0Bv0km4l(ITsgzfLUakMUUcHlkFb0qFp2NxafI3NRRqtcQ7rPp2NxrVvrRWGNfTS0ySFjLfcYIDBwa1d)bYcOXaqoVgl(ITsMDfLUakMUUcHlkFb0qFp2NxafI3NRRqtcQ7rPp2NxrVvrRWGNfTS0ySFjLfcYczLScOE4pqwaLUY51yXxSvYkrrPlGIPRRq4IYxa1d)bYcOtqhWkywt)xnwafgPH(S(dKfqlxkYcHgSvwajlbywSD)oy9SeClRljwan03J95fqDRAyhdKu8fBLmsRO0fqX01viCr5lG6H)azbum2cyd7QoiHlGcJ0qFw)bYcOLlfzrJJTa2WMLYdsywSD)olEgLffijYcMGfXDwuo9VKilACqDwuKfpHz57OS8awuxISCplllwSD)oleILI6nlEcZcP2c5lNmuan03J95fqhXsaauWaBPj41ldMgJ9lPSqaw0xZPj41ldg4v7)bswial9kXjOjIgR(Ibn85QQ3bpVq1APOEBW01vimlLIfYSJLYyjaakyGT0GXwaByx1bjSbE1(FGKfcWczBYYywggyrFnNMGxVmyAm2VKYszSypfFXwjJCfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4Qfwa1PF7QQfWg2SuglLSnzrZyzel2zihlLIf91CAMRoAfmROALOH(EGew0mwSJLsXcguNffnxwvR0BwgxafgPH(S(dKfqHIpLfB7yYYwOecwO7GLcMfDKf4vSfcZYdyjbplaiyhClwgP5qlmHPSaswi0RoklGjlASALilEcZYVJSOXb1zrXXfqH4Dn9ySaQtTQWRyRIVyRKPbkkDbumDDfcxu(cOaRcOu8lG6H)azbuiEFUUclGcXvlSa6iwG4956k0eGRbqcF)bsw0YsKSOVMttWRxgmllw0YYiwIKfk(vDqUOM)W2o7PANvGLHbwWG6SOO5YQALEZYWalyqDwu0qbkVRjs4NLXSOLLrSmILrSaX7Z1vOXPwv4vSflddSeaqW0Z3KhX9VoDKLHbwgXsaabtpFdjr7Ztw0YsaauWaBPbJTa2WUQdsytJoCuwgZYWal9kXjOjIM)IrBGoRWn6X6xcJTbtxxHWSmMfTSadEdDLZRrtJX(LuwkJf7HfTSadEtmaKZRrtJX(LuwkJLsglAzzelWG3qFuP8UovEJMgJ9lPSuglKTjlddSejlVRW8n0hvkVRtL3ObtxxHWSmMfTSaX7Z1vO537tPQuejb7Qn)Ew0YY7nr8n)fJ1huHpKLYyrFnNMGxVmyGxT)hizPuSSPHqYYWal6R50ORaay1I(MLflAzrFnNgDfaaRw030ySFjLfcYI(AonbVEzWaVA)pqYcbyzelKzhlLILEL4e0erJvFXGg(Cv17GNxOATuuVny66keMLXSmMLHbwgXcAVRZYcHnySv0gDvf0WPNbKfTSeaafmWwAWyROn6QkOHtpdOPXy)skleKfY0aeswialJyHCSukw6vItqten0lNlvDpk9X(CdMUUcHzzmlJzzmlAzzelJyjswcaiy65BYJ4(xNoYYWalJybI3NRRqtaKqaKGvyKgndSmmWsaauWaBPjasiasW6VJvQ113tnng7xszHGSqg5yzmlAzzelrYsVsCcAIOr3vEgWkywDLQ(7xsKAW01vimlddS40VDv1cydBwiilKBtw0YsaauWaBPjasiasW6VJvQ113tnn6WrzzmlJzzyGL5rC)Rng7xszHGSeaafmWwAcGecGeS(7yLAD99utJX(LuwgZYWal6akLfTSmpI7FTXy)skleKf91CAcE9YGbE1(FGKfcWcz2XsPyPxjobnr0y1xmOHpxv9o45fQwlf1BdMUUcHzzCbuyKg6Z6pqwaTCPilKAlKVCYal2UFNfsbsiasqYxY9s4gHzbQ113tzXtywGb52plaiyBRVhzHqSuuVzb0SyBhtwkVcaGvl6ZInWsbZcsyRRrw0XjOrwi1wiF5KbwqcBDnsnSO55KGSqxnYYdybZhBwCw0Ov6nlACqDwuKfB7yYYIEetwkTD2dl2zfyXtywCLIfsP5OSy7ukw0XaigzPrhokluaizbtWI4olWR(sIS87il6R5KfpHzbg8uw2Diil6iMSqxZ5fomFvuwAC2iDhHnfqH4Dn9ySaAaUgaj89hiR0V4l2kzeYIsxaftxxHWfLVaQh(dKfqBhcMGfToBmTF0cOWin0N1FGSaA5srwi0nM2pkl2UFNfsTfYxozGLvQqkLfcDJP9JYInWsbZIYPplkqseBw(DpzHuBH8Ltg0el)oMSSOil64e0yb0qFp2NxavFnNMGxVmyAm2VKYszSqg5yzyGf91CAcE9YGbE1(FGKfcYIDeswial9kXjOjIgR(Ibn85QQ3bpVq1APOEBW01vimlLIfYSJfTSaX7Z1vOjaxdGe((dKv6x8fBLm7PO0fqX01viCr5lGg67X(8cOq8(CDfAcW1aiHV)azL(SOLLrSOVMttWRxgmWR2)dKSuweSyhHKfcWsVsCcAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZsPyHm7yzyGLizjaGGPNVbcM)E0MLXSmmWI(AonTdbtWIwNnM2pQzzXIww0xZPPDiycw06SX0(rnng7xszHGSuYyHaSeaj86EJvJHJIvxDeZymFZFXyfIRwileGLrSejl6R50ORaay1I(MLflAzjswExH5BOV3kqdBW01vimlJlG6H)azb0aQq6FUQ6QJygJ5x8fBLSswrPlGIPRRq4IYxan03J95fqH4956k0eGRbqcF)bYk9lG6H)azb0ldEN(FGS4l2QDBwu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0aaOGb2stWRxgmng7xszPmwiBtwggyjswG4956k0eajeajyfgPrZalAzjaGGPNVjpI7FD6ybuyKg6Z6pqwaTKJ3NRRqwwueMfqYIRFQ7pKYYV7pl288z5bSOJSqDiimltqZcP2c5lNmWcfWYV7pl)ogLfVX8zXMtFeMfnFx0NfDCcAKLFhJlGcX7A6XybuQdbRtqxdE9YqXxSv7iRO0fqX01viCr5lG6H)azb05QJwbZkQwjwafgPH(S(dKfqlxkszHqd0ywUjlxYINSOXb1zrrw8eMLVpKYYdyrDjYY9SSSyX297SqiwkQ3AIfsTfYxozqtSOXXwaByZs5bjmlEcZYwGDR)GGSa1M3Xfqd99yFEbumOolkAUS6zuw0YYiwC63UQAbSHnleKLsMDSOzSOVMtZC1rRGzfvRen03dKWsPyHCSmmWI(AonTdbtWIwNnM2pQzzXYyw0YYiw0xZPXQVyqdFUQ6DWZluTwkQ3giUAHSqqwSJ02KLHbw0xZPj41ldMgJ9lPSugl2dlJzrllq8(CDfAOoeSobDn41ldSOLLrSejlbaem98njgAGc0WSmmWcm4noSB9heSsT5DCf2JDIO5VajxsKLXSOLLrSejlbaem98nqW83J2SmmWI(AonTdbtWIwNnM2pQPXy)skleKLsglAglJyH0yPuS0ReNGMiAOxoxQ6Eu6J95gmDDfcZYyw0YI(AonTdbtWIwNnM2pQzzXYWalrYI(AonTdbtWIwNnM2pQzzXYyw0YYiwIKLaacME(gsI2NNSmmWsaauWaBPbJTa2WUQdsytJX(LuwkJf72KLXSOLL3BI4B(lgRpOcFilLXc5yzyGfDaLYIwwMhX9V2ySFjLfcYczBw8fB1o7kkDbumDDfcxu(cOE4pqwaL(EpDLQakmsd9z9hilGwUuKfc1e)DwG(EpDLIfRgeOSCtwG(EpDLILJMB)SSSkGg67X(8cO6R50as83PvlSdO1FG0SSyrll6R50qFVNUszAC2iD31vyXxSv7krrPlGIPRRq4IYxa1d)bYcObpdOQQVMZcOH(ESpVaQ(Aon03BfOHnng7xszHGSqow0YYiw0xZPbdQZIIvkq5TPXy)sklLXc5yzyGf91CAWG6SOyvTsVnng7xszPmwihlJzrllo9BxvTa2WMLYyPKTzbu91CwtpglGsFVvGgUakmsd9z9hilGskpdOIfOV3kqdZYnz5Ew2DklkKsz539KfYrzPXy)YljQjwIcwS4nYI)SuY2KaSSfkHGfpHz53rwcRUX8zrJdQZIISS7uwihbOS0ySF5Lel(ITAhPvu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0aacME(M8iU)1PJSOLLEL4e0erJvFXGg(Cv17GNxOATuuVny66keMfTSOVMtJvFXGg(Cv17GNxOATuuVnqC1czHaS40VDv1cydBwialLGLYIGLsS5MSOLfiEFUUcnbqcbqcwHrA0mWIwwcaGcgylnbqcbqcw)DSsTU(EQPXy)skleKfN(TRQwaByZc5zPeBYsPyHya2e7eMfTSGb1zrrZLvpJYIwwC63UQAbSHnlLXceVpxxHMaiHaibRo1IfTSeaafmWwAcE9YGPXy)sklLXc5kGcJ0qFw)bYcOqXNYITDmzHqSuuVzHUdwkyw0rwSAqiGWSGERIYYdyrhzX1vilpGLffzHuGecGeKfqYsaauWaBjlJ0ykfZ)CLkkl6yaeJuw(EHSCtwGxXwxsKLTqjeSKaBSy7ukwCLcyJLOGflpGflSNy4vrzbZhBwielf1Bw8eMLFhtwwuKfsbsiasWXfqH4Dn9ySaQvdcvRLI6Df9wfT4l2QDKRO0fqX01viCr5lG6H)azbu6790vQcOWin0N1FGSaA5srwG(EpDLIfB3VZc0hvkVzrZ138zb0S82zpSqAwbw8eMLeWc03BfOH1el22XKLeWc037PRuSCuwwwSaAwEalwniWcHyPOEZITDmzX1bqqwkzBYYwOeIrGMLFhzb9wfLfcXsr9MfRgeybI3NRRqwoklFVWXSaAwCyl)piiluBEhZYUtzXEiafduwAm2V8sISaAwoklxYYuDe3)cOH(ESpVa6iwExH5BOpQuExH7B(gmDDfcZYWalu8R6GCrn)HTD2tL0ScSmMfTSejlVRW8n03BfOHny66keMfTSOVMtd99E6kLPXzJ0DxxHSOLLizPxjobnr08xmAd0zfUrpw)sySny66keMfTSmIf91CAS6lg0WNRQEh88cvRLI6TbIRwilLfbl2rUnzrllrYI(AonbVEzWSSyrllJybI3NRRqJtTQWRylwggyrFnNgsUeUr4kgBbSHDmMFftSjE2hnllwggybI3NRRqJvdcvRLI6Df9wfLLXSmmWYiwcaiy65Bsm0afOHzrllVRW8n0hvkVRW9nFdMUUcHzrllJybg8gh2T(dcwP28oUc7Xor00ySFjLLYyXEyzyGfp8hinoSB9heSsT5DCf2JDIO5Y6uDe3FwgZYywgZIwwgXsaauWaBPj41ldMgJ9lPSuglKTjlddSeaafmWwAcGecGeS(7yLAD99utJX(LuwkJfY2KLXfFXwTtduu6cOy66keUO8fq9WFGSak99MUAIybuyKg6Z6pqwavZTITOSSfkHGfDCcAKfsbsiasqww0ljYYVJSqkqcbqcYsaKW3FGKLhWsyhdKWYnzHuGecGeKLJYIh(LRurzX1bRNLhWIoYsWPFb0qFp2NxafI3NRRqJvdcvRLI6Df9wfT4l2QDeYIsxaftxxHWfLVaQh(dKfqt0wngaYcOWin0N1FGSaA5srw08aGKYITDmzjkyXI3ilUoy9S8aY7nYsWTSUKilHDVjIuw8eMLyNeKf6Qrw(DmklEJSCjlEYIghuNffzH(NsXYe0SO5VMh5j0AEfqd99yFEbu3Qg2XajSOLLrSe29MiszjcwSJfTS0yy3BIy9VyKfcYc5yzyGLWU3erklrWsjyzCXxSv7SNIsxaftxxHWfLVaAOVh7ZlG6w1WogiHfTSmILWU3erklrWIDSOLLgd7EteR)fJSqqwihlddSe29MiszjcwkblJzrllJyrFnNgmOolkwvR0BtJX(LuwkJfKWyy9y9VyKLHbw0xZPbdQZIIvkq5TPXy)sklLXcsymSES(xmYY4cOE4pqwaD3vZAmaKfFXwTRKvu6cOy66keUO8fqd99yFEbu3Qg2XajSOLLrSe29MiszjcwSJfTS0yy3BIy9VyKfcYc5yzyGLWU3erklrWsjyzmlAzzel6R50Gb1zrXQALEBAm2VKYszSGegdRhR)fJSmmWI(AonyqDwuSsbkVnng7xszPmwqcJH1J1)Irwgxa1d)bYcOZLsvJbGS4l2Aj2SO0fqX01viCr5lG6H)azbu67nD1eXcOWin0N1FGSaA5srwG(EtxnrKfc1e)DwSAqGYINWSaVITyzlucbl22XKfsTfYxozqtSOXXwaByZs5bjSMy53rwk5G5VhTzrFnNSCuwCDW6z5bSmDLIfWCYcOzjkyTnmlb3ILTqjefqd99yFEbumOolkAUS6zuw0YYiw0xZPbK4VtRbf6DfYrpqAwwSmmWI(AonKCjCJWvm2cyd7ym)kMyt8SpAwwSmmWI(AonbVEzWSSyrllJyjswcaiy65BijAFEYYWalbaqbdSLgm2cyd7QoiHnng7xszPmwihlddSOVMttWRxgmng7xszHGSqmaBIDcZsPyzQaGMLrS40VDv1cydBwiplq8(CDfAO0AaqFwgZYyw0YYiwIKLaacME(giy(7rBwggyrFnNM2HGjyrRZgt7h10ySFjLfcYcXaSj2jmlLILaEkwgXYiwC63UQAbSHnleGfsBtwkflVRW8nZvhTcMvuTs0GPRRqywgZc5zbI3NRRqdLwda6ZYywialLGLsXY7kmFtI2QXaqAW01vimlAzjsw6vItqten0lNlvDpk9X(CdMUUcHzrll6R500oemblAD2yA)OMLflddSOVMtt7qWeSO1zJP9JwPxoxQ6Eu6J95MLflddSmIf91CAAhcMGfToBmTFutJX(LuwiilE4pqAOV3ZRrdsymSES(xmYIwwOwOsv3D6JSqqw20qASmmWI(AonTdbtWIwNnM2pQPXy)skleKfp8hin2A)3niHXW6X6FXilddSOVMtJvFXGg(Cv17GNxOATuuVnqC1czPSiyXoY2KfTSmIfN(TRQwaByZszSaX7Z1vOHsRba9zPuSyhlAglKJLHbw0xZPPDiycw06SX0(rnng7xszPmwSJLXSOLf91CAAhcMGfToBmTFutJX(LuwiilAawggybI3NRRqZzVW1aiHV)ajlAzjaakyGT0Cjn0R31vy1ExE(R4kmc5cOPrhoklAzbT31zzHWMlPHE9UUcR27YZFfxHrixazzmlAzrFnNM2HGjyrRZgt7h1SSyzyGLizrFnNM2HGjyrRZgt7h1SSyrllrYsaauWaBPPDiycw06SX0(rnn6WrzzmlddSaX7Z1vOXPwv4vSflddSOdOuw0YY8iU)1gJ9lPSqqwigGnXoHzPuSeWtXYiwC63UQAbSHnlKNfiEFUUcnuAnaOplJzzCXxS1sqwrPlGIPRRq4IYxa1d)bYcO03B6QjIfqHrAOpR)azb0s3rz5bSe7KGS87il6i9zbmzb67Tc0WSOhLf67bsUKil3ZYYIf7DDbsurz5sw8mklACqDwuKf91ZcHyPOEZYrZTFwCDW6z5bSOJSy1GqaHlGg67X(8cOVRW8n03BfOHny66keMfTSejl9kXjOjIM)IrBGoRWn6X6xcJTbtxxHWSOLLrSOVMtd99wbAyZYILHbwC63UQAbSHnlLXsjBtwgZIww0xZPH(ERanSH(EGewiilLGfTSmIf91CAWG6SOyLcuEBwwSmmWI(AonyqDwuSQwP3MLflJzrll6R50y1xmOHpxv9o45fQwlf1BdexTqwiil2ri3KfTSmILaaOGb2stWRxgmng7xszPmwiBtwggyjswG4956k0eajeajyfgPrZalAzjaGGPNVjpI7FD6ilJl(ITwc7kkDbumDDfcxu(cOaRcOu8lG6H)azbuiEFUUclGcXvlSakguNffnxwvR0Bwkfl2dlKNfp8hin03751Objmgwpw)lgzHaSejlyqDwu0CzvTsVzPuSmIfnaleGL3vy(gkyPQGz93X6e0i9ny66keMLsXsjyzmlKNfp8hin2A)3niHXW6X6FXileGLnnKg5yH8SqTqLQU70hzHaSSPHCSukwExH5Bs)xnsR6UYZaAW01viCbuyKg6Z6pqwavJP)f7pszzhyJL4vyNLTqjeS4nYcr)seMflSzHIbqcByHqnvrz5Dsqklol00TO7GNLjOz53rwcRUX8zHE)Y)dKSqbSydSuW52pl6ilEiSA)rwMGMfL3eXML)IXz7XiTakeVRPhJfqDQfHaBOyO4l2AjkrrPlGIPRRq4IYxa1d)bYcO03B6QjIfqHrAOpR)azbun3k2IfOV30vtez5sw8KfnoOolkYItzHcajloLflaLE6kKfNYIcKezXPSefSyX2PuSGjmlllwSD)ol2ZMeGfB7yYcMp2xsKLFhzjrc)SOXb1zrrnXcmi3(zrHpl3ZIvdcSqiwkQ3AIfyqU9Zcac2267rw8Kfc1e)DwSAqGfpHzXcauSOJtqJSqQTq(YjdS4jmlACSfWg2SuEqcxan03J95fqJKLEL4e0erZFXOnqNv4g9y9lHX2GPRRqyw0YYiw0xZPXQVyqdFUQ6DWZluTwkQ3giUAHSqqwSJqUjlddSOVMtJvFXGg(Cv17GNxOATuuVnqC1czHGSyh52KfTS8UcZ3qFuP8Uc338ny66keMLXSOLLrSGb1zrrZLvkq5nlAzXPF7QQfWg2SqawG4956k04ulcb2qXalLIf91CAWG6SOyLcuEBAm2VKYcbybg8M5QJwbZkQwjA(lqcT2ySFjlLIf7mKJLYyXE2KLHbwWG6SOO5YQALEZIwwC63UQAbSHnleGfiEFUUcno1IqGnumWsPyrFnNgmOolkwvR0BtJX(LuwialWG3mxD0kywr1krZFbsO1gJ9lzPuSyNHCSuglLSnzzmlAzjsw0xZPbK4VtRwyhqR)aPzzXIwwIKL3vy(g67Tc0WgmDDfcZIwwgXsaauWaBPj41ldMgJ9lPSugleswggyHcwk9lHn)EFkvLIijyBW01vimlAzrFnNMFVpLQsrKeSn03dKWcbzPeLGfnJLrS0ReNGMiAOxoxQ6Eu6J95gmDDfcZsPyXowgZIwwMhX9V2ySFjLLYyHSn3KfTSmpI7FTXy)skleKf72CtwgZIwwgXsKSeaqW0Z3qs0(8KLHbwcaGcgylnySfWg2vDqcBAm2VKYszSyhlJl(ITwcsRO0fqX01viCr5lG6H)azb0eTvJbGSakmsd9z9hilGwUuKfnpaiPSCjlEgLfnoOolkYINWSqDiilA(7Qjbi0lLIfnpaizzcAwi1wiF5Kbw8eMLsUxc3imlACSfWg2Xy(gw2IIcyzrrw2QMhlEcZcHwZJf)z53rwWeMfWKfcDJP9JYINWSadYTFwu4ZIMRrpw)sySzz6kflG5SaAOVh7ZlG6w1WogiHfTSaX7Z1vOH6qW6e01GxVmWIwwgXI(AonyqDwuSQwP3MgJ9lPSugliHXW6X6FXilddSOVMtdguNffRuGYBtJX(LuwkJfKWyy9y9VyKLXfFXwlb5kkDbumDDfcxu(cOH(ESpVaQBvd7yGew0YceVpxxHgQdbRtqxdE9YalAzzel6R50Gb1zrXQALEBAm2VKYszSGegdRhR)fJSmmWI(AonyqDwuSsbkVnng7xszPmwqcJH1J1)IrwgZIwwgXI(AonbVEzWSSyzyGf91CAS6lg0WNRQEh88cvRLI6TbIRwilemcwSJSnzzmlAzzelrYsaabtpFdem)9OnlddSOVMtt7qWeSO1zJP9JAAm2VKYcbzzelKJfnJf7yPuS0ReNGMiAOxoxQ6Eu6J95gmDDfcZYyw0YI(AonTdbtWIwNnM2pQzzXYWalrYI(AonTdbtWIwNnM2pQzzXYyw0YYiwIKLEL4e0erZFXOnqNv4g9y9lHX2GPRRqywggybjmgwpw)lgzHGSOVMtZFXOnqNv4g9y9lHX20ySFjLLHbwIKf91CA(lgTb6Sc3OhRFjm2MLflJlG6H)azb0DxnRXaqw8fBTeAGIsxaftxxHWfLVaAOVh7ZlG6w1WogiHfTSaX7Z1vOH6qW6e01GxVmWIwwgXI(AonyqDwuSQwP3MgJ9lPSugliHXW6X6FXilddSOVMtdguNffRuGYBtJX(LuwkJfKWyy9y9VyKLXSOLLrSOVMttWRxgmllwggyrFnNgR(Ibn85QQ3bpVq1APOEBG4QfYcbJGf7iBtwgZIwwgXsKSeaqW0Z3qs0(8KLHbw0xZPHKlHBeUIXwaByhJ5xXeBIN9rZYILXSOLLrSejlbaem98nqW83J2SmmWI(AonTdbtWIwNnM2pQPXy)skleKfYXIww0xZPPDiycw06SX0(rnllw0YsKS0ReNGMiAOxoxQ6Eu6J95gmDDfcZYWalrYI(AonTdbtWIwNnM2pQzzXYyw0YYiwIKLEL4e0erZFXOnqNv4g9y9lHX2GPRRqywggybjmgwpw)lgzHGSOVMtZFXOnqNv4g9y9lHX20ySFjLLHbwIKf91CA(lgTb6Sc3OhRFjm2MLflJlG6H)azb05sPQXaqw8fBTeeYIsxaftxxHWfLVakmsd9z9hilGwUuKfcfGgZcizjaxa1d)bYcO28UpqxbZkQwjw8fBTe2trPlGIPRRq4IYxa1d)bYcO03751ybuyKg6Z6pqwaTCPilqFVNxJS8awSAqGfOaL3SOXb1zrrnXcP2c5lNmWYUtzrHukl)fJS87EYIZcHs7)oliHXW6rwu48zb0Sasvuw0Ov6nlACqDwuKLJYYYYWcHY97SuA7ShwSZkWcMp2S4SafO8MfnoOolkYYnzHqSuuVzH(NsXYUtzrHukl)UNSyhzBYc99ajuw8eMfsTfYxozGfpHzHuGecGeKLDhcYsmOrw(DpzHmcjLfsP5yPXy)YljAyPCPilUoacYIDKBtnil7o9rwGx9LezHq3yA)OS4jml2zNDAqw2D6JSy7(DW6zHq3yA)Ofqd99yFEbumOolkAUSQwP3SOLLizrFnNM2HGjyrRZgt7h1SSyzyGfmOolkAOaL31ej8ZYWalJybdQZIIgpJwtKWplddSOVMttWRxgmng7xszHGS4H)aPXw7)Ubjmgwpw)lgzrll6R50e86LbZYILXSOLLrSejlu8R6GCrn)HTD2t1oRalddS0ReNGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSOLf91CAS6lg0WNRQEh88cvRLI6TbIRwileKf7iBtw0YsaauWaBPj41ldMgJ9lPSuglKrizrllJyjswcaiy65BYJ4(xNoYYWalbaqbdSLMaiHaibR)owPwxFp10ySFjLLYyHmcjlJzrllJyjswApGMVbkflddSeaafmWwA0XMInjxs00ySFjLLYyHmcjlJzzmlddSGb1zrrZLvpJYIwwgXI(Aon28UpqxbZkQwjAwwSmmWc1cvQ6UtFKfcYYMgsJCSOLLrSejlbaem98nqW83J2SmmWsKSOVMtt7qWeSO1zJP9JAwwSmMLHbwcaiy65BGG5VhTzrlluluPQ7o9rwiilBAinwgx8fBTeLSIsxaftxxHWfLVakmsd9z9hilGwUuKfcL2)Dwa)o22okYIT9lSZYrz5swGcuEZIghuNff1elKAlKVCYalGMLhWIvdcSOrR0Bw04G6SOybup8hilGAR9FV4l2kPTzrPlGIPRRq4IYxafgPH(S(dKfqj0Us979QaQh(dKfq7vw9WFGSQo6xavD0VMEmwaD6k1V3RIV4l(cOqWMEGSyR2TPD2TjPTj5kGAZ78sI0cOekBPKFRLZw18RKyHLsVJSCXwG(zzcAw2gyHj2BZsJ276AeMfkigzXxpi2FeMLWUNerQH3qJUezXUsIfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4n0OlrwkrjXcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8g8gekBPKFRLZw18RKyHLsVJSCXwG(zzcAw2ggN(s9BZsJ276AeMfkigzXxpi2FeMLWUNerQH3qJUezrdusSqkqcb7hHzb6ftkwOrZ3jmlAqwEalA0Yzb(GC0dKSaSW2FqZYiYpMLrKr4XgEdn6sKfnqjXcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJSJWJn8gA0LileYsIfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4n0OlrwSNsIfsbsiy)imlqVysXcnA(oHzrdYYdyrJwolWhKJEGKfGf2(dAwgr(XSmYocp2WBOrxISypLelKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmImcp2WBOrxISuYkjwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4Tzzuji8ydVHgDjYsjRKyHuGec2pcZY2FFjj4BiZq6BZYdyz7VVKe8npzgsFBwgzhHhB4n0OlrwkzLelKcKqW(ryw2(7ljbFJDgsFBwEalB)9LKGV5TZq6BZYi7i8ydVHgDjYczBwsSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVHgDjYczKvsSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVHgDjYcz2vsSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVHgDjYczLOKyHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLrKr4XgEdn6sKfYixjXcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8gA0LilKPbkjwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzKDeESH3qJUezHmnqjXcPajeSFeMLT)(ssW3qMH03MLhWY2FFjj4BEYmK(2SmICeESH3qJUezHmnqjXcPajeSFeMLT)(ssW3yNH03MLhWY2FFjj4BE7mK(2SmImcp2WBOrxISqgHSKyHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLr2r4XgEdn6sKfYiKLelKcKqW(ryw2(7ljbFdzgsFBwEalB)9LKGV5jZq6BZYiYi8ydVHgDjYczeYsIfsbsiy)imlB)9LKGVXodPVnlpGLT)(ssW382zi9Tzze5i8ydVbVbHYwk53A5Svn)kjwyP07ilxSfOFwMGMLTTAmaI19FBwA0ExxJWSqbXil(6bX(JWSe29Kisn8gA0LilLOKyHuGec2pcZY2FFjj4BiZq6BZYdyz7VVKe8npzgsFBwgvccp2WBOrxISqALelKcKqW(ryw2(7ljbFJDgsFBwEalB)9LKGV5TZq6BZYOsq4XgEdn6sKf7PKyHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3Mf)zrJju1iwgrgHhB4n4niu2sj)wlNTQ5xjXclLEhz5ITa9ZYe0SSTdWTzPr7DDncZcfeJS4Rhe7pcZsy3tIi1WBOrxISqwjXcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8gA0Lil2vsSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVHgDjYIDLelKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82S4plAmHQgXYiYi8ydVHgDjYsjkjwifiHG9JWSS97kmFdPVnlpGLTFxH5BiDdMUUcH3MLrKr4XgEdn6sKLsusSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYi7HWJn8gA0LilAGsIfsbsiy)imlqVysXcnA(oHzrdQbz5bSOrlNLya8sTOSaSW2FqZYin4ywgrgHhB4n0Olrw0aLelKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmYocp2WBOrxISqiljwifiHG9JWSa9Ijfl0O57eMfnOgKLhWIgTCwIbWl1IYcWcB)bnlJ0GJzzezeESH3qJUezHqwsSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVHgDjYI9usSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVHgDjYsjRKyHuGec2pcZc0lMuSqJMVtyw0GS8aw0OLZc8b5OhizbyHT)GMLrKFmlJSJWJn8gA0LilKzxjXcPajeSFeMfOxmPyHgnFNWSObz5bSOrlNf4dYrpqYcWcB)bnlJi)ywgrgHhB4n0OlrwiJ0kjwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3qJUezHmYvsSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVHgDjYczAGsIfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgzhHhB4n0OlrwiZEkjwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3qJUezXUnljwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzKDeESH3qJUezXo7kjwifiHG9JWSa9Ijfl0O57eMfnilpGfnA5SaFqo6bswawy7pOzze5hZYiYi8ydVHgDjYIDKwjXcPajeSFeMfOxmPyHgnFNWSObz5bSOrlNf4dYrpqYcWcB)bnlJi)ywgzhHhB4n0OlrwSJ0kjwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3qJUezXonqjXcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8gA0Lil2riljwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3qJUezXUswjXcPajeSFeMfOxmPyHgnFNWSObz5bSOrlNf4dYrpqYcWcB)bnlJi)ywgzhHhB4n0OlrwkXMLelKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82S4plAmHQgXYiYi8ydVHgDjYsjiRKyHuGec2pcZc0lMuSqJMVtyw0GS8aw0OLZc8b5OhizbyHT)GMLrKFmlJkbHhB4n4niu2sj)wlNTQ5xjXclLEhz5ITa9ZYe0SS90vQFVxBZsJ276AeMfkigzXxpi2FeMLWUNerQH3qJUezXUsIfsbsiy)imlqVysXcnA(oHzrdYYdyrJwolWhKJEGKfGf2(dAwgr(XSmImcp2WBWBqOSLs(TwoBvZVsIfwk9oYYfBb6NLjOzzB6VnlnAVRRrywOGyKfF9Gy)rywc7EsePgEdn6sKf7kjwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzeHKWJn8gA0LilLOKyHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLrKr4XgEdn6sKfsRKyHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLrKr4XgEdn6sKfnqjXcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnl(ZIgtOQrSmImcp2WBOrxISq2MLelKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmYocp2WBOrxISqgPvsSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVHgDjYczAGsIfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrocp2WBOrxISqgHSKyHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLrKr4XgEdn6sKfYSNsIfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4n0OlrwSJSsIfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4n0OlrwSJ0kjwifiHG9JWSa9Ijfl0O57eMfnilpGfnA5SaFqo6bswawy7pOzze5hZYiYi8ydVHgDjYIDKwjXcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8gA0Lil2rUsIfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4n0OlrwkXMLelKcKqW(rywGEXKIfA08DcZIgKLhWIgTCwGpih9ajlalS9h0SmI8Jzzuji8ydVHgDjYsj2SKyHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLrKr4XgEdn6sKLsqwjXcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8gA0LilLWUsIfsbsiy)imlqVysXcnA(oHzrdYYdyrJwolWhKJEGKfGf2(dAwgr(XSmQeeESH3qJUezPeLOKyHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLr2r4XgEdn6sKLsqUsIfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgzhHhB4n0OlrwkHgOKyHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLr2r4XgEdn6sKLsypLelKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmImcp2WBWBuoXwG(ryw0aS4H)ajlQJ(udVrbuRgmpfwavd1qwkVR8mGSO561bZBOHAilBXQpfl2JMyXUnTZoEdEdnudzHu7EsePLeVHgQHSOzSSfyyeMfOaL3SuE0Jn8gAOgYIMXcP29KicZY7nr8R3KLGtrklpGLq0GcRV3eXNA4n0qnKfnJLsEmgabHzzLjgqk17OSaX7Z1viLLrNbnAIfRgHuPV30vtezrZkJfRgHyOV30vtehB4n0qnKfnJLTabCWSy1yWP)LezHqP9FNLBYY9Btz53rwS1GKilACqDwu0WBOHAilAglAEojilKcKqaKGS87ilqTU(EklolQ7FfYsmOrwMkKWNUczz0nzjkyXYUdNB)SSFpl3Zc9IxQ3teSOQOSy7(DwkpH6wknleGfsHkK(NRyzlQJygJ5RjwUFBywOKCwJn8gAOgYIMXIMNtcYsmG(SS98iU)1gJ9lPBZcnGP3hGYIBzPIYYdyrhqPSmpI7pLfqQIA4n0qnKfnJLs3O)SuAqmYcyYs5v(olLx57SuELVZItzXzHAHHZvS89LKGVH3qd1qw0mwiuTWeBwgDg0OjwiuA)31elekT)7AIfOV3ZRXXSe7WilXGgzPr6PomFwEalO3QdBwcGyD)1m679B4n0qnKfnJfc9rywk5EjCJWSOXXwaByhJ5ZsyhdKWYe0SqknhllQten8gAOgYIMXsjpgdGGSa3Rd2KGAaMYsyhdKqn8g8gAOgYYwYe8(JWSuEx5zazzlecnILGNSOJSmbReMf)zz)FlAjrEYR7kpdOMrV4GH497lDZbiF5DLNbuZGEXKI8XWM9pwP5Z5PWi0DLNb08e(5n4n8WFGKASAmaI19pcsUeUr4k1667P8gAilLEhzbI3NRRqwoklu8z5bSSjl2UFNLeWc99NfqYYIIS89LKGpvtSqgl22XKLFhzzEn9zbKilhLfqYYIIAIf7y5MS87ilumasywoklEcZsjy5MSOd(Dw8g5n8WFGKASAmaI19NarqEiEFUUc1u6XyeGSUOy97ljbFnbXvlmIn5n8WFGKASAmaI19NarqEiEFUUc1u6XyeGSUOy97ljbFnbSIWHH1eexTWiitt3mIVVKe8nKz2DADrXQ(Ao1(9LKGVHmtaauWaBPbE1(FGuBKFFjj4BiZCuZdIXkywJbj9BWIwdGK(9k8hiP8gE4pqsnwngaX6(tGiipeVpxxHAk9ymcqwxuS(9LKGVMawr4WWAcIRwye2PPBgX3xsc(g7m7oTUOyvFnNA)(ssW3yNjaakyGT0aVA)pqQnYVVKe8n2zoQ5bXyfmRXGK(nyrRbqs)Ef(dKuEdnKLsVJuKLVVKe8PS4nYscEw81dI9)cUsfLfy8XWJWS4uwajllkYc99NLVVKe8Pgwybk(SaX7Z1vilpGfsJfNYYVJrzXvualjIWSqTWW5kw29ewDjrdVHh(dKuJvJbqSU)eicYdX7Z1vOMspgJaK1ffRFFjj4RjGveomSMG4QfgbPPPBgbAVRZYcHnxsd96DDfwT3LN)kUcJqUaomG276SSqydgBfTrxvbnC6zahgq7DDwwiSHcwkf()LeR9spkVHgYcu8PS87ilqFVPRMiYsaqFwMGMfL)yZsWvHLY)dKuwgnbnliH9ylfYITDmz5bSqFVFwGxXwxsKfDCcAKfcDJP9JYY0vkklG5CmVHh(dKuJvJbqSU)eicYdX7Z1vOMspgJGsRba91eexTWikXMLAezA2MgYixPO4x1b5IA(dB7SNkPzfgZB4H)aj1y1yaeR7pbIG8q8(CDfQP0JXiOZAaqFnbXvlmcYTzPgrMMTPHmYvkk(vDqUOM)W2o7PsAwHX8gAilqXNYI)SyB)c7S4XGv(SaMSSfkHGfsbsiasqwO7GLcMfDKLffHljwiTnzX297G1ZcPqfs)ZvSa1667PS4jmlLytwSD)UH3Wd)bsQXQXaiw3Fceb5H4956kutPhJreajeajy1PwAcIRwyeLytcq2MLQxjobnr0eqfs)ZvvQ113t5n8WFGKASAmaI19Narq(yaij5Y6e0X8gE4pqsnwngaX6(tGiiVT2)DnPUeRb4iiBtnDZigHb1zrrJALExtKW)WaguNffnxwPaL3ddyqDwu0Czvh87ddyqDwu04z0AIe(hZBWBOHSqiAm40Nf7yHqP9FNfpHzXzb67nD1erwajlqlnl2UFNLTEe3Fwi0oYINWSuEWwknlGMfOV3ZRrwa)o22okYB4H)aj1aSWeBceb5T1(VRPBgXimOolkAuR07AIe(hgWG6SOO5YkfO8EyadQZIIMlR6GFFyadQZIIgpJwtKW)yTwncXqMXw7)U2iTAeIXoJT2)DEdp8hiPgGfMytGiip99EEnQj1Lynahb500nJy0Oi7vItqten6UYZawbZQRu1F)sI0HHidaiy65BYJ4(xNoomej1cvQ67nr8Pg6790vQiiByiY3vy(M0)vJ0QUR8mGgmDDfcpEyyeguNffnuGY7AIe(hgWG6SOO5YQALEpmGb1zrrZLvDWVpmGb1zrrJNrRjs4F8yTrsXVQdYf18h22zpv7Sc8gE4pqsnalmXMarqE67nD1ernPUeRb4iiNMUzeJ6vItqten6UYZawbZQRu1F)sIuTbaem98n5rC)Rth1sTqLQ(EteFQH(EpDLkcYgRnsk(vDqUOM)W2o7PANvG3G3qd1qw0ycJH1JWSGqWokl)fJS87ilE4bnlhLfhIFkxxHgEdp8hiPrqbkVR6OhZB4H)ajLarq(GRuvp8hiRQJ(Ak9ymcGfMyRj63x4JGmnDZi(lgj4i7kLh(dKgBT)7MGt)6FXib8WFG0qFVNxJMGt)6FX4yEdnKfO4tzzlanMfqYsjial2UFhSEwG7B(S4jml2UFNfOV3kqdZINWSyhbyb87yB7OiVHh(dKuceb5H4956kutPhJrC0QdqnbXvlmcQfQu13BI4tn037PRuLrM2rr(UcZ3qFVvGg2GPRRq4HH3vy(g6JkL3v4(MVbtxxHWJhgOwOsvFVjIp1qFVNUsvMD8gAilqXNYsqHoeKfB7yYc03751ilbpzz)EwSJaS8EteFkl22VWolhLLgviepFwMGMLFhzrJdQZIIS8aw0rwSACIDJWS4jml22VWolZtPWMLhWsWPpVHh(dKuceb5H4956kutPhJrC0AqHoeutqC1cJGAHkv99Mi(ud99EEnwgz8gAilLC8(CDfYYV7plHDmqcLLBYsuWIfVrwUKfNfIbywEaloeWbZYVJSqVF5)bswSTJnYIZY3xsc(SGFGLJYYIIWSCjl64BdXKLGtFkVHh(dKuceb5H4956kutPhJrCzLyawtqC1cJWQrivIbydzMyaiNxJddwncPsmaBiZqx58ACyWQrivIbydzg67nD1eXHbRgHujgGnKzOV3txPggSAesLya2qMzU6OvWSIQvIddwncX0oemblAD2yA)Odd6R50e86LbtJX(L0i0xZPj41ldg4v7)bYHbiEFUUcnhT6aK3qdzPCPilLhBk2KCjrw8NLFhzbtywatwi0nM2pkl22XKLDN(ilhLfxhabzrdSPgutS4ZhBwifiHaibzX297SuEGxAw8eMfWVJTTJISy7(Dwi1wiF5KbEdp8hiPeicYRJnfBsUKOMUzeJgfzaabtpFtEe3)60XHHidaGcgylnbqcbqcw)DSsTU(EQzznmezVsCcAIOr3vEgWkywDLQ(7xsKowR(AonbVEzW0ySFjTmYiNw91CAAhcMGfToBmTFutJX(LucsAAJmaGGPNVbcM)E0EyiaGGPNVbcM)E0wR(AonbVEzWSS0QVMtt7qWeSO1zJP9JAwwAhPVMtt7qWeSO1zJP9JAAm2VKsWiiZonJ0kvVsCcAIOHE5CPQ7rPp2NpmOVMttWRxgmng7xsjizKnmqMgKAHkvD3PpsqYmAGXJ1cX7Z1vO5YkXamVHgYcHa8Sy7(DwCwi1wiF5Kbw(D)z5O52ploleILI6nlwniWcOzX2oMS87ilZJ4(ZYrzX1bRNLhWcMW8gE4pqsjqeK3c8hi10nJyK(AonbVEzW0ySFjTmYiN2rr2ReNGMiAOxoxQ6Eu6J95dd6R500oemblAD2yA)OMgJ9lPeKSsMw91CAAhcMGfToBmTFuZYA8WGoGs1opI7FTXy)skbTJCJ1cX7Z1vO5YkXamVHgYcPCvyP8hPSyBh)DSzzrVKilKcKqaKGSKaBSy7ukwCLcyJLOGflpGf6FkflbN(S87ilupgzXJbR8zbmzHuGecGeKaKAlKVCYalbN(uEdp8hiPeicYdX7Z1vOMspgJiasiasWkmsJMbnbXvlmIaEQrJMhX9V2ySFjvZiJCAwaauWaBPj41ldMgJ9lPJ1GKzpBoUSaEQrJMhX9V2ySFjvZiJCAwaauWaBPjasiasW6VJvQ113tnng7xshRbjZE2CS2iB)GRiemFJddtniHp6t1okYaaOGb2stWRxgmn6WrhgImaakyGT0eajeajy93Xk1667PMgD4OJhgcaGcgylnbVEzW0ySFjTSlFSTak)r468iU)1gJ9lPdd9kXjOjIMaQq6FUQsTU(EQ2aaOGb2stWRxgmng7xslReBomeaafmWwAcGecGeS(7yLAD99utJX(L0YU8X2cO8hHRZJ4(xBm2VKQzKT5WqKbaem98n5rC)Rth5n0qwkxkcZYdybgvEuw(DKLf1jISaMSqQTq(YjdSyBhtww0ljYcmyPRqwajllkYINWSy1iemFwwuNiYITDmzXtwCyywqiy(SCuwCDW6z5bSaFiVHh(dKuceb5H4956kutPhJreGRbqcF)bsnbXvlmIrV3eX38xmwFqf(WYiJCddTFWvecMVXHHPMllJCBow7OrO9Uolle2GXwrB0vvqdNEgqTJImaGGPNVbcM)E0EyiaakyGT0GXwrB0vvqdNEgqtJX(LucsMgGqsGrKRu9kXjOjIg6LZLQUhL(yF(4XAJmaakyGT0GXwrB0vvqdNEgqtJoC0XddO9Uolle2qblLc))sI1EPhv7Oidaiy65BYJ4(xNoomeaafmWwAOGLsH)FjXAV0JwlbPro7ztYmng7xsjizKrAJhggfaafmWwA0XMInjxs00OdhDyiY2dO5BGsnmeaqW0Z3KhX9VoDCS2rr(UcZ3mxD0kywr1krdMUUcHhgcaiy65BGG5VhT1gaafmWwAMRoAfmROALOPXy)skbjJmcqUs1ReNGMiAOxoxQ6Eu6J95ddrgaqW0Z3abZFpARnaakyGT0mxD0kywr1krtJX(LucQVMttWRxgmWR2)dKeGm7kvVsCcAIOXQVyqdFUQ6DWZluTwkQ3Agz2nw7i0ExNLfcBUKg6176kSAVlp)vCfgHCbuBaauWaBP5sAOxVRRWQ9U88xXvyeYfqtJX(LucsUXddJgH276SSqydD3Hb2q4kO1RGz9bDmMV2aaOGb2sZd6ymFeUEj9iU)1sqoYvc7iZ0ySFjD8WWOrq8(CDfAazDrX63xsc(rq2WaeVpxxHgqwxuS(9LKGFeLyS2rFFjj4BiZ0OdhTgaafmWwom89LKGVHmtaauWaBPPXy)sAzx(yBbu(JW15rC)Rng7xs1mY2C8WaeVpxxHgqwxuS(9LKGFe2PD03xsc(g7mn6WrRbaqbdSLddFFjj4BSZeaafmWwAAm2VKw2Lp2waL)iCDEe3)AJX(LunJSnhpmaX7Z1vObK1ffRFFjj4hXMJhpM3qdzPKJ3NRRqwwueMLhWcmQ8OS4zuw((ssWNYINWSeGPSyBhtwS53FjrwMGMfpzrJxw7G(CwSAqG3Wd)bskbIG8q8(CDfQP0JXi(9(uQkfrsWUAZVxtqC1cJiskyP0Ve2879PuvkIKGTbtxxHWddZJ4(xBm2VKwMDBU5WGoGs1opI7FTXy)skbTJCeyePTPMPVMtZV3NsvPisc2g67bskLDJhg0xZP537tPQuejbBd99ajLvc7rZg1ReNGMiAOxoxQ6Eu6J95LYUX8gAilLlfzrJJTI2ORyHqTHtpdil2Tjfduw0XjOrwCwi1wiF5KbwwuKfqZcfWYV7pl3ZITtPyrDjYYYIfB3VZYVJSGjmlGjle6gt7hL3Wd)bskbIG8lkwVhJ1u6XyeySv0gDvf0WPNbut3mIaaOGb2stWRxgmng7xsjODBQnaakyGT0eajeajy93Xk1667PMgJ9lPe0Un1ocI3NRRqZV3NsvPisc2vB(9dd6R50879PuvkIKGTH(EGKYkXMeyuVsCcAIOHE5CPQ7rPp2NxQsmESwiEFUUcnxwjgGhg0buQ25rC)Rng7xsjyjiK8gAilLlfzbkyPu4Fjrwk5x6rzrdqXaLfDCcAKfNfsTfYxozGLffzb0SqbS87(ZY9Sy7ukwuxISSSyX297S87ilycZcyYcHUX0(r5n8WFGKsGii)II17XynLEmgbfSuk8)ljw7LEunDZigfaafmWwAcE9YGPXy)skb1aAJmaGGPNVbcM)E0wBKbaem98n5rC)Rthhgcaiy65BYJ4(xNoQnaakyGT0eajeajy93Xk1667PMgJ9lPeudODeeVpxxHMaiHaibRWinAgggcaGcgylnbVEzW0ySFjLGAGXddbaem98nqW83J2AhfzVsCcAIOHE5CPQ7rPp2NRnaakyGT0e86LbtJX(LucQbgg0xZPPDiycw06SX0(rnng7xsjizBsGrKRuO9Uolle2Cj97v4bnTcFqUeR6OsnwR(AonTdbtWIwNnM2pQzznEyqhqPANhX9V2ySFjLG2rUHb0ExNLfcBWyROn6QkOHtpdO2aaOGb2sdgBfTrxvbnC6zanng7xslZUnhRfI3NRRqZLvIbyTrI276SSqyZL0qVExxHv7D55VIRWiKlGddbaqbdSLMlPHE9UUcR27YZFfxHrixanng7xslZUnhg0buQ25rC)Rng7xsjODBYBOHSSfLnpkLLffzPC08HMJfB3VZcP2c5lNmWcOzXFw(DKfmHzbmzHq3yA)O8gE4pqsjqeKhI3NRRqnLEmgXzVW1aiHV)aPMG4QfgH(AonbVEzW0ySFjTmYiN2rr2ReNGMiAOxoxQ6Eu6J95dd6R500oemblAD2yA)OMgJ9lPemcYiNHCeyujmKRu6R50ORaay1I(ML1ycmI0mKtZkHHCLsFnNgDfaaRw03SSgxk0ExNLfcBUK(9k8GMwHpixIvDuPiaPzixPgH276SSqyZVJ1510VspINsBaauWaBP53X68A6xPhXtzAm2VKsWiSBZXA1xZPPDiycw06SX0(rnlRXdd6akv78iU)1gJ9lPe0oYnmG276SSqydgBfTrxvbnC6za1gaafmWwAWyROn6QkOHtpdOPXy)skVHh(dKuceb5xuSEpgRP0JXiUKg6176kSAVlp)vCfgHCbut3mciEFUUcnN9cxdGe((dKAH4956k0CzLyaM3qdzPCPilq3DyGneMfc1wNfDCcAKfsTfYxozG3Wd)bskbIG8lkwVhJ1u6Xye0DhgydHRGwVcM1h0Xy(A6MrmkaakyGT0e86LbtJoCuTrgaqW0Z3KhX9VoDuleVpxxHMFVpLQsrKeSR2871okaakyGT0OJnfBsUKOPrho6WqKThqZ3aLA8WqaabtpFtEe3)60rTbaqbdSLMaiHaibR)owPwxFp10Odhv7iiEFUUcnbqcbqcwHrA0mmmeaafmWwAcE9YGPrho64XAHbVHUY51O5Vajxsu7iyWBOpQuExNkVrZFbsUK4WqKVRW8n0hvkVRtL3ObtxxHWdduluPQV3eXNAOV3ZRXYkXyTWG3eda58A08xGKljQDeeVpxxHMJwDaom0ReNGMiA0DLNbScMvxPQ)(LePddo9BxvTa2WUSikzBomaX7Z1vOjasiasWkmsJMHHb91CA0vaaSArFZYAS2ir7DDwwiS5sAOxVRRWQ9U88xXvyeYfWHb0ExNLfcBUKg6176kSAVlp)vCfgHCbuBaauWaBP5sAOxVRRWQ9U88xXvyeYfqtJX(L0YkXMAJuFnNMGxVmywwdd6akv78iU)1gJ9lPeK02K3qdzP07hLLJYIZs7)o2SGkxh0(JSyZJYYdyj2jbzXvkwajllkYc99NLVVKe8PS8aw0rwuxIWSSSyX297SqQTq(YjdS4jmlKcKqaKGS4jmllkYYVJSyxcZcvbEwajlbywUjl6GFNLVVKe8PS4nYcizzrrwOV)S89LKGpL3Wd)bskbIG8lkwVhJPAIQapnIVVKe8jtt3mciEFUUcnGSUOy97ljb)iJGmTr(9LKGVXotJoC0AaauWaB5WWiiEFUUcnGSUOy97ljb)iiByaI3NRRqdiRlkw)(ssWpIsmw7OaacME(giy(7rBT6R50e86LbZYs7i91CAAhcMGfToBmTFutJX(LucmI0mKRu9kXjOjIg6LZLQUhL(yF(ycgX3xsc(gYm6R5ScVA)pqQvFnNM2HGjyrRZgt7h1SSgg0xZPPDiycw06SX0(rR0lNlvDpk9X(CZYA8WqaauWaBPj41ldMgJ9lPeGmYv23xsc(gYmbaqbdSLg4v7)bsTJISxjobnr0y1xmOHpxv9o45fQwlf17Hb91CAcE9YGPXy)sAzAGHHaaOGb2stWRxgmng7xs1SVVKe8nKzcaGcgylnWR2)dKeKmYnw7Oidaiy65BGG5VhThgIuFnNM2HGjyrRZgt7h1SS0gaafmWwAAhcMGfToBmTFutJX(L0XAhfzaabtpFtEe3)60XHHVVKe8nKzcaGcgylnWR2)dKLfaafmWwAcGecGeS(7yLAD99utJX(L0HbiEFUUcnbqcbqcwHrA0mO97ljbFdzMaaOGb2sd8Q9)azzbaqbdSLMGxVmyAm2VKowBKbaem98nKeTpphgcaiy65BYJ4(xNoQfI3NRRqtaKqaKGvyKgndAdaGcgylnbqcbqcw)DSsTU(EQzzPnYaaOGb2stWRxgmllTJgPVMtdguNffRQv6TPXy)sAzKByqFnNgmOolkwPaL3MgJ9lPLrUXJhg0xZPHKlHBeUIXwaByhJ5xXeBIN9rZYA8WGoGs1opI7FTXy)skbTBZHbiEFUUcnGSUOy97ljb)i2K3Wd)bskbIG8lkwVhJPAIQapnIVVKe8Ttt3mciEFUUcnGSUOy97ljb)iJWoTr(9LKGVHmtJoC0AaauWaB5WaeVpxxHgqwxuS(9LKGFe2PDK(AonbVEzWSS0gaqW0Z3abZFpARDK(AonTdbtWIwNnM2pQPXy)skbgrAgYvQEL4e0erd9Y5sv3JsFSpFmbJ47ljbFJDg91CwHxT)hi1QVMtt7qWeSO1zJP9JAwwdd6R500oemblAD2yA)Ov6LZLQUhL(yFUzznEyiaakyGT0e86LbtJX(Lucqg5k77ljbFJDMaaOGb2sd8Q9)aP2rr2ReNGMiAS6lg0WNRQEh88cvRLI69WG(AonbVEzW0ySFjTmnWWqaauWaBPj41ldMgJ9lPA23xsc(g7mbaqbdSLg4v7)bscsg5gRDuKbaem98nqW83J2ddrQVMtt7qWeSO1zJP9JAwwAdaGcgylnTdbtWIwNnM2pQPXy)s6yTJImaGGPNVjpI7FD64WW3xsc(g7mbaqbdSLg4v7)bYYcaGcgylnbqcbqcw)DSsTU(EQPXy)s6WaeVpxxHMaiHaibRWinAg0(9LKGVXotaauWaBPbE1(FGSSaaOGb2stWRxgmng7xshRnYaacME(gsI2NNAhfP(AonbVEzWSSggImaGGPNVbcM)E0E8WqaabtpFtEe3)60rTq8(CDfAcGecGeScJ0OzqBaauWaBPjasiasW6VJvQ113tnllTrgaafmWwAcE9YGzzPD0i91CAWG6SOyvTsVnng7xslJCdd6R50Gb1zrXkfO820ySFjTmYnE84Hb91CAi5s4gHRySfWg2Xy(vmXM4zF0SSgg0buQ25rC)Rng7xsjODBomaX7Z1vObK1ffRFFjj4hXM8gAilLlfPS4kflGFhBwajllkYY9ymLfqYsaM3Wd)bskbIG8lkwVhJP8gAilA897yZcralx(aw(DKf6ZcOzXbilE4pqYI6OpVHh(dKuceb57vw9WFGSQo6RP0JXiCaQj63x4JGmnDZiG4956k0C0QdqEdp8hiPeicY3RS6H)azvD0xtPhJrqFEdEdnKfs5QWs5pszX2o(7yZYVJSO5A0Jd(h2XMf91CYITtPyz6kflG5KfB3VFjl)oYsIe(zj40N3Wd)bsQXbyeq8(CDfQP0JXiGB0JR2oLQoDLQcMtnbXvlmIEL4e0erZFXOnqNv4g9y9lHXw7i91CA(lgTb6Sc3OhRFjm2MgJ9lPeKya2e7eMaBAiByqFnNM)IrBGoRWn6X6xcJTPXy)skb9WFG0qFVNxJgKWyy9y9VyKaBAit7imOolkAUSQwP3ddyqDwu0qbkVRjs4FyadQZIIgpJwtKW)4XA1xZP5Vy0gOZkCJES(LWyBww8gAilKYvHLYFKYITD83XMfOV30vtez5OSyd0)olbN(xsKfaeSzb6798AKLlzrJwP3SOXb1zrrEdp8hiPghGeicYdX7Z1vOMspgJ4iMGgR03B6QjIAcIRwyerIb1zrrZLvkq5TwQfQu13BI4tn03751yzesn7DfMVHcwQkyw)DSobnsFdMUUcHlLDeadQZIIMlR6GFxBK9kXjOjIgR(Ibn85QQ3bpVq1APOERnYEL4e0erdiXFNwdk07kKJEGK3qdzPCPilKcKqaKGSyBhtw8NffsPS87EYc52KLTqjeS4jmlQlrwwwSy7(Dwi1wiF5KbEdp8hiPghGeicYhajeajy93Xk1667PA6MrmAeeVpxxHMaiHaibRWinAg0gzaauWaBPj41ldMgD4OAJSxjobnr0y1xmOHpxv9o45fQwlf17Hb91CAcE9YGzzPDuK9kXjOjIgR(Ibn85QQ3bpVq1APOEpm0ReNGMiAcOcP)5Qk1667PddZJ4(xBm2VKwgz2rihg0buQ25rC)Rng7xsjyaauWaBPj41ldMgJ9lPeGSnhg0xZPj41ldMgJ9lPLrMDJhRD0Oro9BxvTa2WMGraX7Z1vOjasiasWQtTggOwOsvFVjIp1qFVNxJLvIXAhPVMtdguNffRQv6TPXy)sAzKT5WG(AonyqDwuSsbkVnng7xslJSnhpmOVMttWRxgmng7xslJCA1xZPj41ldMgJ9lPemcYSBS2rr(UcZ3qFuP8Uc338hg0xZPH(EpDLY0ySFjLGKziNMTPHCLQxjobnr0eqfs)ZvvQ113thg0xZPj41ldMgJ9lPeuFnNg6790vktJX(LucqoT6R50e86LbZYAS2rr2ReNGMiA(lgTb6Sc3OhRFjm2ddr2ReNGMiAcOcP)5Qk1667Pdd6R508xmAd0zfUrpw)sySnng7xsldjmgwpw)lghpm0ReNGMiA0DLNbScMvxPQ)(LePJ1okYEL4e0erJUR8mGvWS6kv93VKiDyyK(Aon6UYZawbZQRu1F)sI0A6)Qrd99ajrypdd6R50O7kpdyfmRUsv)9ljsREh8en03dKeH9mE8WGoGs1opI7FTXy)skbjBtTrgaafmWwAcE9YGPrho6yEdnKLYLISaDLZRrwUKflpHX4lWcizXZO)(Lez539Nf1bbPSqgPrXaLfpHzrHukl2UFNLyqJS8EteFklEcZI)S87ilycZcyYIZcuGYBw04G6SOil(ZczKglumqzb0SOqkLLgJ9lVKiloLLhWscEw2DixsKLhWsJZgP7SaV6ljYIgTsVzrJdQZII8gE4pqsnoajqeKNUY51OMcrdkS(EteFAeKPPBgXOgNns3DDfomOVMtdguNffRuGYBtJX(LucwcTyqDwu0CzLcuERTXy)skbjJ00(UcZ3qblvfmR)owNGgPVbtxxHWJ1(EteFZFXy9bv4dlJmstZOwOsvFVjIpLang7xs1ocdQZIIMlREgDyOXy)skbjgGnXoHhZBOHSuUuKfORCEnYYdyz3HGS4Squb0DflpGLffzPC08HMJ3Wd)bsQXbibIG80voVg10nJaI3NRRqZzVW1aiHV)aP2aaOGb2sZL0qVExxHv7D55VIRWiKlGMgD4OAr7DDwwiS5sAOxVRRWQ9U88xXvyeYfqTUvnSJbs4n0qwk5IOflllwG(EpDLIf)zXvkw(lgPSSsfsPSSOxsKfnkAWBNYINWSCplhLfxhSEwEalwniWcOzrHpl)oYc1cdNRyXd)bswuxISOJkGnw29ewHSO5A0J1VegBwajl2XY7nr8P8gE4pqsnoajqeKN(EpDLst3mIiFxH5BOpQuExH7B(gmDDfcRDuKu8R6GCrn)HTD2tL0ScddyqDwu0Cz1ZOdduluPQV3eXNAOV3txPkReJ1osFnNg6790vktJZgP7UUc1oIAHkv99Mi(ud99E6kfblXWqK9kXjOjIM)IrBGoRWn6X6xcJ94HH3vy(gkyPQGz93X6e0i9ny66kewR(AonyqDwuSsbkVnng7xsjyj0Ib1zrrZLvkq5Tw91CAOV3txPmng7xsjiHul1cvQ67nr8Pg6790vQYIG0gRDuK9kXjOjIgv0G3oTovi(xsSsuDXwuCy4VyudQbjnYvM(Aon037PRuMgJ9lPeWUXAFVjIV5VyS(Gk8HLroEdnKfcL73zb6JkL3SO56B(SSOilGKLaml22XKLgNns3DDfYI(6zH(NsXIn)EwMGMfnkAWBNYIvdcS4jmlWGC7NLffzrhNGgzHuAoQHfO)PuSSOil64e0ilKcKqaKGSqVmGS87(ZITtPyXQbbw8e87yZc037PRu8gE4pqsnoajqeKN(EpDLst3mI3vy(g6JkL3v4(MVbtxxHWA1xZPH(EpDLY04Sr6URRqTJIKIFvhKlQ5pSTZEQKMvyyadQZIIMlREgDyGAHkv99Mi(ud99E6kvzLyS2rr2ReNGMiAurdE706uH4FjXkr1fBrXHH)IrnOgK0ixzK2yTZJ4(xBm2VKwwj4n0qwiuUFNfnxJES(LWyZYIISa99E6kflpGfsq0ILLfl)oYI(AozrpklUIcyzrVKilqFVNUsXcizHCSqXaiHPSaAwuiLYsJX(LxsK3Wd)bsQXbibIG8037PRuA6Mr0ReNGMiA(lgTb6Sc3OhRFjm2APwOsvFVjIp1qFVNUsvweLq7Oi1xZP5Vy0gOZkCJES(LWyBwwA1xZPH(EpDLY04Sr6URRWHHrq8(CDfAGB0JR2oLQoDLQcMtTJ0xZPH(EpDLY0ySFjLGLyyGAHkv99Mi(ud99E6kvz2P9DfMVH(Os5DfUV5BW01viSw91CAOV3txPmng7xsji5gpEmVHgYcPCvyP8hPSyBh)DSzXzb67nD1erwwuKfBNsXsWxuKfOV3txPy5bSmDLIfWCQjw8eMLffzb67nD1erwEalKGOflAUg9y9lHXMf67bsyzzzyXE2KLJYYVJS0O9UUgHzzlucblpGLGtFwG(EtxnrKaqFVNUsXB4H)aj14aKarqEiEFUUc1u6Xye037PRuvBG8RtxPQG5utqC1cJWPF7QQfWg2LzpBwQrKPzu8R6GCrn)HTD2t1oRqP20y34snImntFnNM)IrBGoRWn6X6xcJTH(EGKsTPHSXA2i91CAOV3txPmng7xslvj0GuluPQ7o9Xsf57kmFd9rLY7kCFZ3GPRRq4XA2OaaOGb2sd99E6kLPXy)sAPkHgKAHkvD3PpwQ3vy(g6JkL3v4(MVbtxxHWJ1Sr6R50mxD0kywr1krtJX(L0srUXAhPVMtd99E6kLzznmeaafmWwAOV3txPmng7xshZBOHSuUuKfOV30vtezX297SO5A0J1VegBwEalKGOflllw(DKf91CYIT73bRNffGEjrwG(EpDLILL1FXilEcZYIISa99MUAIilGKfsJaSuEWwknl03dKqzzL)PyH0y59Mi(uEdp8hiPghGeicYtFVPRMiQPBgbeVpxxHg4g94QTtPQtxPQG5uleVpxxHg6790vQQnq(1PRuvWCQnsiEFUUcnhXe0yL(EtxnrCyyK(Aon6UYZawbZQRu1F)sI0A6)Qrd99ajLvIHb91CA0DLNbScMvxPQ)(LePvVdEIg67bskReJ1sTqLQ(EteFQH(EpDLIGKMwiEFUUcn037PRuvBG8RtxPQG5K3qdzPCPiluBEhZcfWYV7plrblwiIplXoHzzz9xmYIEuww0ljYY9S4uwu(JS4uwSau6PRqwajlkKsz539KLsWc99ajuwanlA(UOpl22XKLsqawOVhiHYcsyRRrEdp8hiPghGeicY7WU1FqWk1M3XAkenOW67nr8PrqMMUzer(xGKljQnsp8hinoSB9heSsT5DCf2JDIO5Y6uDe3)HbyWBCy36piyLAZ74kSh7erd99ajeSeAHbVXHDR)GGvQnVJRWEStenng7xsjyj4n0qwk5XzJ0Dw08aGCEnYYnzHuBH8Ltgy5OS0OdhvtS87yJS4nYIcPuw(DpzHCS8EteFklxYIgTsVzrJdQZIISy7(DwGcEcTMyrHukl)UNSq2MSa(DSTDuKLlzXZOSOXb1zrrwanlllwEalKJL3BI4tzrhNGgzXzrJwP3SOXb1zrrdlAoqU9ZsJZgP7SaV6ljYsj3lHBeMfno2cyd7ymFwwPcPuwUKfOaL3SOXb1zrrEdp8hiPghGeicYhda58AutHObfwFVjIpncY00nJOXzJ0DxxHAFVjIV5VyS(Gk8HLnAezKgbgrTqLQ(EteFQH(EpVglLDLsFnNgmOolkwvR0BZYA8yc0ySFjDSgCeze4DfMV5TDzngasQbtxxHWJ160VDv1cyd7YG4956k0qN1aG(AM(Aon037PRuMgJ9lPLsdODKBvd7yGKHbiEFUUcnhXe0yL(EtxnrCyismOolkAUS6z0XAhfaafmWwAcE9YGPrhoQwmOolkAUS6zuTJG4956k0eajeajyfgPrZWWqaauWaBPjasiasW6VJvQ113tnn6WrhgImaGGPNVjpI7FD644HbQfQu13BI4tn03751ibhnYE0Sr6R50Gb1zrXQALEBwwLQeJhxQrKrG3vy(M32L1yaiPgmDDfcpES2iXG6SOOHcuExtKWV2rrgaafmWwAcE9YGPrho64HHryqDwu0CzLcuEpmOVMtdguNffRQv6TzzPnY3vy(gkyPQGz93X6e0i9ny66keES2ruluPQV3eXNAOV3ZRrcs2MLAeze4DfMV5TDzngasQbtxxHWJhpw7Oidaiy65BijAFEomeP(AonKCjCJWvm2cyd7ym)kMyt8SpAwwddyqDwu0CzLcuEpwBK6R500oemblAD2yA)Ov6LZLQUhL(yFUzzXBOHSuUuKfcnyRSaswcWSy7(DW6zj4wwxsK3Wd)bsQXbibIG8tqhWkywt)xnQPBgHBvd7yGKHbiEFUUcnhXe0yL(EtxnrK3Wd)bsQXbibIG8q8(CDfQP0JXicW1aiHV)az1bOMG4QfgXiiEFUUcnb4AaKW3FGu7i91CAOV3txPmlRHH3vy(g6JkL3v4(MVbtxxHWddbaem98n5rC)RthhRfg8MyaiNxJM)cKCjrTJIuFnNgkqr)lGMLL2i1xZPj41ldMLL2rr(UcZ3mxD0kywr1krdMUUcHhg0xZPj41ldg4v7)bYYcaGcgylnZvhTcMvuTs00ySFjLa2ZyTJIKIFvhKlQ5pSTZEQ2zfggWG6SOO5YQALEpmGb1zrrdfO8UMiH)XAH4956k0879PuvkIKGD1MFV2rrgaqW0Z3KhX9VoDCyaI3NRRqtaKqaKGvyKgndddbaqbdSLMaiHaibR)owPwxFp10ySFjLGKrUXAFVjIV5VyS(Gk8HLPVMttWRxgmWR2)dKLAtdHC8WGoGs1opI7FTXy)skb1xZPj41ldg4v7)bscqMDLQxjobnr0y1xmOHpxv9o45fQwlf17X8gAilLlfzHq3yA)OSy7(Dwi1wiF5KbEdp8hiPghGeicY3oemblAD2yA)OA6MrOVMttWRxgmng7xslJmYnmOVMttWRxgmWR2)dKeGm7kvVsCcAIOXQVyqdFUQ6DWZluTwkQ3e0onGwiEFUUcnb4AaKW3FGS6aK3qdzPCPilKAlKVCYalGKLamlRuHuklEcZI6sKL7zzzXIT73zHuGecGeK3Wd)bsQXbibIG8buH0)Cv1vhXmgZxt3mciEFUUcnb4AaKW3FGS6au7Oidaiy65BGG5VhThgISxjobnr0qVCUu19O0h7Zhg6vItqtenw9fdA4ZvvVdEEHQ1sr9EyqFnNMGxVmyGxT)hillc70aJhg0xZPPDiycw06SX0(rnllT6R500oemblAD2yA)OMgJ9lPeKmYzihVHh(dKuJdqceb5Vm4D6)bsnDZiG4956k0eGRbqcF)bYQdqEdnKLYLISOXXwaByZs5bjmlGKLaml2UFNfOV3txPyzzXINWSqDiiltqZcHyPOEZINWSqQTq(Yjd8gE4pqsnoajqeKhJTa2WUQdsynDZigfaafmWwAcE9YGPXy)skb0xZPj41ldg4v7)bsc0ReNGMiAS6lg0WNRQEh88cvRLI6DPiZUYcaGcgylnySfWg2vDqcBGxT)hijazBoEyqFnNMGxVmyAm2VKwM9WBOHSuYJZgP7SmvEJSaswwwS8awkblV3eXNYIT73bRNfsTfYxozGfD8sIS46G1ZYdybjS11ilEcZscEwaqWo4wwxsK3Wd)bsQXbibIG80hvkVRtL3OMcrdkS(EteFAeKPPBgrJZgP7UUc1(xmwFqf(WYiJCAPwOsvFVjIp1qFVNxJeK006w1Wogir7i91CAcE9YGPXy)sAzKT5WqK6R50e86LbZYAmVHgYs5srwi0anMLBYYL0dgzXtw04G6SOilEcZI6sKL7zzzXIT73zXzHqSuuVzXQbbw8eMLTa7w)bbzbQnVJ5n8WFGKACasGii)C1rRGzfvRe10nJadQZIIMlREgv7i3Qg2Xajddr2ReNGMiAS6lg0WNRQEh88cvRLI69yTJ0xZPXQVyqdFUQ6DWZluTwkQ3giUAHe0oYT5WG(AonbVEzW0ySFjTm7zS2rWG34WU1FqWk1M3Xvyp2jIM)cKCjXHHidaiy65Bsm0afOHhgOwOsvFVjIpTm7gRDK(AonTdbtWIwNnM2pQPXy)skblzA2isRu9kXjOjIg6LZLQUhL(yF(yT6R500oemblAD2yA)OML1WqK6R500oemblAD2yA)OML1yTJImaakyGT0e86LbZYAyqFnNMFVpLQsrKeSn03dKqqYiN25rC)Rng7xsjODBUP25rC)Rng7xslJSn3CyiskyP0Ve2879PuvkIKGTbtxxHWJ1oIcwk9lHn)EFkvLIijyBW01vi8WqaauWaBPj41ldMgJ9lPLvInhR99Mi(M)IX6dQWhwg5gg0buQ25rC)Rng7xsjizBYBOHSuUuKfNfOV3txPyHqnXFNfRgeyzLkKszb6790vkwoklUQrhoklllwanlrblw8gzX1bRNLhWcac2b3ILTqje8gE4pqsnoajqeKN(EpDLst3mc91CAaj(70Qf2b06pqAwwAhPVMtd99E6kLPXzJ0DxxHddo9BxvTa2WUSs2MJ5n0qw0CRylw2cLqWIoobnYcPajeajil2UFNfOV3txPyXtyw(Dmzb67nD1erEdp8hiPghGeicYtFVNUsPPBgraabtpFtEe3)60rTr(UcZ3qFuP8Uc338ny66kew7iiEFUUcnbqcbqcwHrA0mmmeaafmWwAcE9YGzznmOVMttWRxgmlRXAdaGcgylnbqcbqcw)DSsTU(EQPXy)skbjgGnXoHlvap1iN(TRQwaByRbH4956k0qN1aG(J1QVMtd99E6kLPXy)skbjnEdp8hiPghGeicYtFVPRMiQPBgraabtpFtEe3)60rTJG4956k0eajeajyfgPrZWWqaauWaBPj41ldML1WG(AonbVEzWSSgRnaakyGT0eajeajy93Xk1667PMgJ9lPeKCAH4956k0qFVNUsvTbYVoDLQcMtTyqDwu0Cz1ZOAJeI3NRRqZrmbnwPV30vte5n0qwkxkYc03B6QjISy7(Dw8Kfc1e)DwSAqGfqZYnzjkyTnmlaiyhClw2cLqWIT73zjky1SKiHFwco9nSSfffWc8k2ILTqjeS4pl)oYcMWSaMS87ilLCW83J2SOVMtwUjlqFVNUsXInWsbNB)SmDLIfWCYcOzjkyXI3ilGKf7y59Mi(uEdp8hiPghGeicYtFVPRMiQPBgH(AonGe)DAnOqVRqo6bsZYAyyuK03751OXTQHDmqI2iH4956k0CetqJv67nD1eXHHr6R50e86LbtJX(LucsoT6R50e86LbZYAyy0i91CAcE9YGPXy)skbjgGnXoHlvap1iN(TRQwaByRbH4956k0qP1aG(J1QVMttWRxgmlRHb91CAAhcMGfToBmTF0k9Y5sv3JsFSp30ySFjLGedWMyNWLkGNAKt)2vvlGnS1Gq8(CDfAO0Aaq)XA1xZPPDiycw06SX0(rR0lNlvDpk9X(CZYAS2aacME(giy(7r7XJ1oIAHkv99Mi(ud99E6kfblXWaeVpxxHg6790vQQnq(1PRuvWCoES2iH4956k0CetqJv67nD1erTJISxjobnr08xmAd0zfUrpw)syShgOwOsvFVjIp1qFVNUsrWsmM3qdzPCPilAEaqsz5swGcuEZIghuNffzXtywOoeKfc9sPyrZdaswMGMfsTfYxozG3Wd)bsQXbibIG8jARgdaPMUzeJ0xZPbdQZIIvkq5TPXy)sAziHXW6X6FX4WWOWU3erAe2PTXWU3eX6FXibj34HHWU3erAeLySw3Qg2Xaj8gE4pqsnoajqeKF3vZAmaKA6MrmsFnNgmOolkwPaL3MgJ9lPLHegdRhR)fJddJc7EtePryN2gd7EteR)fJeKCJhgc7EtePruIXADRAyhdKODK(AonTdbtWIwNnM2pQPXy)skbjNw91CAAhcMGfToBmTFuZYsBK9kXjOjIg6LZLQUhL(yF(WqK6R500oemblAD2yA)OML1yEdp8hiPghGeicYpxkvngasnDZigPVMtdguNffRuGYBtJX(L0YqcJH1J1)IrTJcaGcgylnbVEzW0ySFjTmYT5WqaauWaBPjasiasW6VJvQ113tnng7xslJCBoEyyuy3BIinc702yy3BIy9VyKGKB8Wqy3BIinIsmwRBvd7yGeTJ0xZPPDiycw06SX0(rnng7xsji50QVMtt7qWeSO1zJP9JAwwAJSxjobnr0qVCUu19O0h7ZhgIuFnNM2HGjyrRZgt7h1SSgZBOHSuUuKfcfGgZcizHuAoEdp8hiPghGeicYBZ7(aDfmROALiVHgYcPCvyP8hPSyBh)DSz5bSSOilqFVNxJSCjlqbkVzX2(f2z5OS4plKJL3BI4tjazSmbnlieSJYIDBQbzj2Pp2rzb0SqASa99MUAIilACSfWg2Xy(SqFpqcL3Wd)bsQXbibIG8q8(CDfQP0JXiOV3ZRX6Lvkq5TMG4Qfgb1cvQ67nr8Pg6798ASmsJatfa0JID6JD0kexTWsr2MBQbTBZXeyQaGEK(Aon03B6QjIvm2cyd7ym)kfO82qFpqIgK0gZBOHSqOMSyhlV3eXNYIT73bRNfOGLIfWKLFhzHqdAK(SefSyHUdwkywMNsXIT73zHqP9FNf4vFjrwkNmWB4H)aj14aKarqEBT)7A6MreP(AonTdbtWIwNnM2pQzzPns91CAAhcMGfToBmTF0k9Y5sv3JsFSp3SS0g57kmFdfSuvWS(7yDcAK(gmDDfcRLAHkv99Mi(ud99EEnsWsOvFnNgmOolkwPaL3MgJ9lPLHegdRhR)fJANhX9V2ySFjTm91CAcE9YGPXy)skbiZUs1ReNGMiAS6lg0WNRQEh88cvRLI6nVHgYcPCvyP8hPSyBh)DSz5bSqO0(VZc8QVKile6gt7hL3Wd)bsQXbibIG8q8(CDfQP0JXiS1(VxVSoBmTFunbXvlmcY0GuluPQ7o9rcANMnAtJDLA0iQfQu13BI4tn03751OMr2yn4OruluPQV3eXNAOV3ZRrnJSXAq72KaKnECPgrgbExH5BOGLQcM1FhRtqJ03GPRRq4srMHCJhtGnnKrUsPVMtt7qWeSO1zJP9JAAm2VKYBOHSuUuKfcL2)DwUKfOaL3SOXb1zrrwanl3KLeWc03751il2oLIL59SC5dyHuBH8LtgyXZOXGg5n8WFGKACasGiiVT2)DnDZigHb1zrrJALExtKW)WaguNffnEgTMiHFTq8(CDfAoAnOqhcow7O3BI4B(lgRpOcFyzK2WaguNffnQv6D9YQDdd6akv78iU)1gJ9lPeKSnhpmOVMtdguNffRuGYBtJX(Luc6H)aPH(EpVgniHXW6X6FXOw91CAWG6SOyLcuEBwwddyqDwu0CzLcuERnsiEFUUcn03751y9YkfO8EyqFnNMGxVmyAm2VKsqp8hin03751Objmgwpw)lg1gjeVpxxHMJwdk0HGA1xZPj41ldMgJ9lPeejmgwpw)lg1QVMttWRxgmlRHb91CAAhcMGfToBmTFuZYsleVpxxHgBT)71lRZgt7hDyisiEFUUcnhTguOdb1QVMttWRxgmng7xsldjmgwpw)lg5n0qwkxkYc03751il3KLlzrJwP3SOXb1zrrnXYLSafO8MfnoOolkYcizH0ialV3eXNYcOz5bSy1GalqbkVzrJdQZII8gE4pqsnoajqeKN(EpVg5n0qwi0Us979I3Wd)bsQXbibIG89kRE4pqwvh91u6XyetxP(9EXBWBOHSa99MUAIiltqZsmacgJ5ZYkviLYYIEjrwkpylLM3Wd)bsQz6k1V3RiOV30vte10nJiYEL4e0erJUR8mGvWS6kv93VKi1G276SSqyEdnKfs50NLFhzbg8Sy7(Dw(DKLya9z5VyKLhWIddZYk)tXYVJSe7eMf4v7)bswokl73Byb6kNxJS0ySFjLL4L6pl1HWS8awI9pSZsmaKZRrwGxT)hi5n8WFGKAMUs979IarqE6kNxJAkenOW67nr8PrqMMUzeWG3eda58A00ySFjTSgJ9lPLYo70GKzp8gE4pqsntxP(9ErGiiFmaKZRrEdEdnKLYLISSfy36piilqT5Dml22XKLFhBKLJYscyXd)bbzHAZ7ynXItzr5pYItzXcqPNUczbKSqT5Dml2UFNf7yb0SmrByZc99ajuwanlGKfNLsqawO28oMfkGLF3Fw(DKLeTXc1M3XS4DFqqklA(UOpl(8XMLF3FwO28oMfKWwxJuEdp8hiPg6hHd7w)bbRuBEhRPq0GcRV3eXNgbzA6Mrejm4noSB9heSsT5DCf2JDIO5VajxsuBKE4pqACy36piyLAZ74kSh7erZL1P6iU)Ahfjm4noSB9heSsT5DCDhDL5VajxsCyag8gh2T(dcwP28oUUJUY0ySFjTmYnEyag8gh2T(dcwP28oUc7Xor0qFpqcblHwyWBCy36piyLAZ74kSh7ertJX(LucwcTWG34WU1FqWk1M3Xvyp2jIM)cKCjrEdnKLYLIuwifiHaibz5MSqQTq(YjdSCuwwwSaAwIcwS4nYcmsJMHljYcP2c5lNmWIT73zHuGecGeKfpHzjkyXI3il6OcyJfsBtYxInhrkuH0)CflqTU(E6yw2cLqWYLS4Sq2MeGfkgyrJdQZIIgw2IIcybgKB)SOWNfnxJES(LWyZcsyRRrnXIRS5rPSSOilxYcP2c5lNmWIT73zHqSuuVzXtyw8NLFhzH(E)SaMS4SuEWwknl2UegyZWB4H)aj1qFceb5dGecGeS(7yLAD99unDZigncI3NRRqtaKqaKGvyKgndAJmaakyGT0e86LbtJoCuTr2ReNGMiAS6lg0WNRQEh88cvRLI69WG(AonbVEzWSS0okYEL4e0erJvFXGg(Cv17GNxOATuuVhg6vItqtenbuH0)CvLAD990HH5rC)Rng7xslJm7iKdd6akv78iU)1gJ9lPemaakyGT0e86LbtJX(Lucq2Mdd6R50e86LbtJX(L0YiZUXJ1oAKt)2vvlGnSjyeq8(CDfAcGecGeS6ulTJ0xZPbdQZIIv1k920ySFjTmY2CyqFnNgmOolkwPaL3MgJ9lPLr2MJhg0xZPj41ldMgJ9lPLroT6R50e86LbtJX(Lucgbz2nw7Oi7vItqten)fJ2aDwHB0J1Veg7HHi7vItqtenbuH0)CvLAD990Hb91CA(lgTb6Sc3OhRFjm2MgJ9lPLHegdRhR)fJJhg6vItqten6UYZawbZQRu1F)sI0XAhfzVsCcAIOr3vEgWkywDLQ(7xsKommsFnNgDx5zaRGz1vQ6VFjrAn9F1OH(EGKiSNHb91CA0DLNbScMvxPQ)(LePvVdEIg67bsIWEgpEyqhqPANhX9V2ySFjLGKTP2idaGcgylnbVEzW0OdhDmVHgYs5srwG(EtxnrKLhWcjiAXYYILFhzrZ1OhRFjm2SOVMtwUjl3ZInWsbZcsyRRrw0XjOrwMxE09ljYYVJSKiHFwco9zb0S8awGxXwSOJtqJSqkqcbqcYB4H)aj1qFceb5PV30vte10nJOxjobnr08xmAd0zfUrpw)syS1okYrJ0xZP5Vy0gOZkCJES(LWyBAm2VKwMh(dKgBT)7gKWyy9y9VyKaBAit7imOolkAUSQd(9HbmOolkAUSsbkVhgWG6SOOrTsVRjs4F8WG(Aon)fJ2aDwHB0J1VegBtJX(L0Y8WFG0qFVNxJgKWyy9y9VyKaBAit7imOolkAUSQwP3ddyqDwu0qbkVRjs4FyadQZIIgpJwtKW)4XddrQVMtZFXOnqNv4g9y9lHX2SSgpmmsFnNMGxVmywwddq8(CDfAcGecGeScJ0OzyS2aaOGb2staKqaKG1FhRuRRVNAA0HJQnaGGPNVjpI7FD6O2r6R50Gb1zrXQALEBAm2VKwgzBomOVMtdguNffRuGYBtJX(L0YiBZXJ1okYaacME(gsI2NNddbaqbdSLgm2cyd7QoiHnng7xslZEgZBOHSO5wXwSa99MUAIiLfB3VZs5DLNbKfWKLTOuSu69ljszb0S8awSA0YBKLjOzHuGecGeKfB3VZs5bBP08gE4pqsn0NarqE67nD1ernDZi6vItqten6UYZawbZQRu1F)sIuTJgPVMtJUR8mGvWS6kv93VKiTM(VA0qFpqsz2nmOVMtJUR8mGvWS6kv93VKiT6DWt0qFpqsz2nwBaauWaBPj41ldMgJ9lPLri1gzaauWaBPjasiasW6VJvQ113tnlRHHrbaem98n5rC)Rth1gaafmWwAcGecGeS(7yLAD99utJX(Lucs2MAXG6SOO5YQNr160VDv1cyd7YSBtcuInlvaauWaBPj41ldMgD4OJhZBOHSqkqcF)bswMGMfxPybg8uw(D)zj2jbPSqxnYYVJrzXBm3(zPXzJ0DeMfB7yYsjVdbtWIYcHUX0(rzz3PSOqkLLF3twihlumqzPXy)YljYcOz53rw04ylGnSzP8GeMf91CYYrzX1bRNLhWY0vkwaZjlGMfpJYIghuNffz5OS46G1ZYdybjS11iVHh(dKud9jqeKhI3NRRqnLEmgbm4RnAVRRXymFQMG4QfgXi91CAAhcMGfToBmTFutJX(L0Yi3WqK6R500oemblAD2yA)OML1yTrQVMtt7qWeSO1zJP9JwPxoxQ6Eu6J95MLL2r6R50qYLWncxXylGnSJX8RyInXZ(OPXy)skbjgGnXoHhRDK(AonyqDwuSsbkVnng7xslJya2e7eEyqFnNgmOolkwvR0BtJX(L0YigGnXoHhggfP(AonyqDwuSQwP3ML1WqK6R50Gb1zrXkfO82SSgRnY3vy(gkqr)lGgmDDfcpM3qdzHuGe((dKS87(ZsyhdKqz5MSefSyXBKfW6PhmYcguNffz5bSasvuwGbpl)o2ilGMLJycAKLF)OSy7(DwGcu0)ciVHh(dKud9jqeKhI3NRRqnLEmgbm4RG1tpySIb1zrrnbXvlmIrrQVMtdguNffRuGYBZYsBK6R50Gb1zrXQALEBwwJ1g57kmFdfOO)fqdMUUcH1gzVsCcAIO5Vy0gOZkCJES(LWyZBOHSO5aplUsXY7nr8PSy7(9lzHq4jmgFbwSD)oy9SaGGDWTSUKib(DKfxhabzjas47pqs5n8WFGKAOpbIG8XaqoVg1uiAqH13BI4tJGmnDZigPVMtdguNffRuGYBtJX(L0YAm2VKomOVMtdguNffRQv6TPXy)sAzng7xshgG4956k0ad(ky90dgRyqDwuCS2gNns3DDfQ99Mi(M)IX6dQWhwgz2P1TQHDmqIwiEFUUcnWGV2O9UUgJX8P8gE4pqsn0NarqE6kNxJAkenOW67nr8PrqMMUzeJ0xZPbdQZIIvkq5TPXy)sAzng7xshg0xZPbdQZIIv1k920ySFjTSgJ9lPddq8(CDfAGbFfSE6bJvmOolkowBJZgP7UUc1(EteFZFXy9bv4dlJm706w1WogirleVpxxHgyWxB0ExxJXy(uEdp8hiPg6tGiip9rLY76u5nQPq0GcRV3eXNgbzA6MrmsFnNgmOolkwPaL3MgJ9lPL1ySFjDyqFnNgmOolkwvR0BtJX(L0YAm2VKomaX7Z1vObg8vW6PhmwXG6SO4yTnoBKU76ku77nr8n)fJ1huHpSmY0aADRAyhdKOfI3NRRqdm4RnAVRRXymFkVHgYIMd8S0hX9NfDCcAKfcDJP9JYYnz5EwSbwkywCLcyJLOGflpGLgNns3zrHuklWR(sISqOBmTFuwg97hLfqQIYYUBzHjLfB3VdwplqVCUuSO5Fu6J95J5n8WFGKAOpbIG8q8(CDfQP0JXisqDpk9X(8k6TkAfg8AcIRwyebaem98nqW83J2AJSxjobnr0qVCUu19O0h7Z1gzVsCcAIOjCDqHvWSQUjw9eUcJ(VRnaakyGT0OJnfBsUKOPrhoQ2aaOGb2st7qWeSO1zJP9JAA0HJQns91CAcE9YGzzPDKt)2vvlGnSlZEiKdd6R50ORaay1I(ML1yEdp8hiPg6tGiiFmaKZRrnDZiG4956k0KG6Eu6J95v0Bv0km412ySFjLG2TjVHh(dKud9jqeKNUY51OMUzeq8(CDfAsqDpk9X(8k6TkAfg8ABm2VKsqYkz8gAilLlfzHqd2klGKLaml2UFhSEwcUL1Le5n8WFGKAOpbIG8tqhWkywt)xnQPBgHBvd7yGeEdnKLYLISOXXwaByZs5bjml2UFNfpJYIcKezbtWI4olkN(xsKfnoOolkYINWS8DuwEalQlrwUNLLfl2UFNfcXsr9MfpHzHuBH8Ltg4n8WFGKAOpbIG8ySfWg2vDqcRPBgXOaaOGb2stWRxgmng7xsjG(AonbVEzWaVA)pqsGEL4e0erJvFXGg(Cv17GNxOATuuVlfz2vwaauWaBPbJTa2WUQdsyd8Q9)ajbiBZXdd6R50e86LbtJX(L0YShEdnKfO4tzX2oMSSfkHGf6oyPGzrhzbEfBHWS8awsWZcac2b3ILrAo0ctyklGKfc9QJYcyYIgRwjYINWS87ilACqDwuCmVHh(dKud9jqeKhI3NRRqnLEmgHtTQWRylnbXvlmcN(TRQwaByxwjBtnBKDgYvk91CAMRoAfmROALOH(EGenZUsHb1zrrZLv1k9EmVHgYs5srwi1wiF5KbwSD)olKcKqaKGKVK7LWncZcuRRVNYINWSadYTFwaqW2wFpYcHyPOEZcOzX2oMSuEfaaRw0NfBGLcMfKWwxJSOJtqJSqQTq(YjdSGe26AKAyrZZjbzHUAKLhWcMp2S4SOrR0Bw04G6SOil22XKLf9iMSuA7ShwSZkWINWS4kflKsZrzX2PuSOJbqmYsJoCuwOaqYcMGfXDwGx9Lez53rw0xZjlEcZcm4PSS7qqw0rmzHUMZlCy(QOS04Sr6ocB4n8WFGKAOpbIG8q8(CDfQP0JXicW1aiHV)azL(AcIRwyeJG4956k0eGRbqcF)bsTrQVMttWRxgmllTJIKIFvhKlQ5pSTZEQ2zfggWG6SOO5YQALEpmGb1zrrdfO8UMiH)XAhnAeeVpxxHgNAvHxXwddbaem98n5rC)RthhggfaqW0Z3qs0(8uBaauWaBPbJTa2WUQdsytJoC0Xdd9kXjOjIM)IrBGoRWn6X6xcJ9yTWG3qx58A00ySFjTm7rlm4nXaqoVgnng7xslRKPDem4n0hvkVRtL3OPXy)sAzKT5WqKVRW8n0hvkVRtL3ObtxxHWJ1cX7Z1vO537tPQuejb7Qn)ETV3eX38xmwFqf(WY0xZPj41ldg4v7)bYsTPHqomOVMtJUcaGvl6BwwA1xZPrxbaWQf9nng7xsjO(AonbVEzWaVA)pqsGrKzxP6vItqtenw9fdA4ZvvVdEEHQ1sr9E84HHrO9Uolle2GXwrB0vvqdNEgqTbaqbdSLgm2kAJUQcA40ZaAAm2VKsqY0aescmICLQxjobnr0qVCUu19O0h7ZhpES2rJImaGGPNVjpI7FD64WWiiEFUUcnbqcbqcwHrA0mmmeaafmWwAcGecGeS(7yLAD99utJX(Lucsg5gRDuK9kXjOjIgDx5zaRGz1vQ6VFjr6WGt)2vvlGnSji52uBaauWaBPjasiasW6VJvQ113tnn6WrhpEyyEe3)AJX(LucgaafmWwAcGecGeS(7yLAD99utJX(L0Xdd6akv78iU)1gJ9lPeuFnNMGxVmyGxT)hijaz2vQEL4e0erJvFXGg(Cv17GNxOATuuVhZBOHSuUuKfcDJP9JYIT73zHuBH8LtgyzLkKszHq3yA)OSydSuWSOC6ZIcKeXMLF3twi1wiF5KbnXYVJjllkYIoobnYB4H)aj1qFceb5BhcMGfToBmTFunDZi0xZPj41ldMgJ9lPLrg5gg0xZPj41ldg4v7)bscAhHKa9kXjOjIgR(Ibn85QQ3bpVq1APOExkYStleVpxxHMaCnas47pqwPpVHh(dKud9jqeKpGkK(NRQU6iMXy(A6MraX7Z1vOjaxdGe((dKv6RDK(AonbVEzWaVA)pqwwe2rijqVsCcAIOXQVyqdFUQ6DWZluTwkQ3LIm7ggImaGGPNVbcM)E0E8WG(AonTdbtWIwNnM2pQzzPvFnNM2HGjyrRZgt7h10ySFjLGLmceaj86EJvJHJIvxDeZymFZFXyfIRwibgfP(Aon6kaawTOVzzPnY3vy(g67Tc0WgmDDfcpM3Wd)bsQH(eicYFzW70)dKA6MraX7Z1vOjaxdGe((dKv6ZBOHSuYX7Z1villkcZcizX1p19hsz539NfBE(S8aw0rwOoeeMLjOzHuBH8LtgyHcy539NLFhJYI3y(SyZPpcZIMVl6ZIoobnYYVJX8gE4pqsn0NarqEiEFUUc1u6XyeuhcwNGUg86LbnbXvlmIaaOGb2stWRxgmng7xslJSnhgIeI3NRRqtaKqaKGvyKgndAdaiy65BYJ4(xNoYBOHSuUuKYcHgOXSCtwUKfpzrJdQZIIS4jmlFFiLLhWI6sKL7zzzXIT73zHqSuuV1elKAlKVCYGMyrJJTa2WMLYdsyw8eMLTa7w)bbzbQnVJ5n8WFGKAOpbIG8ZvhTcMvuTsut3mcmOolkAUS6zuTJC63UQAbSHnblz2Pz6R50mxD0kywr1krd99ajLICdd6R500oemblAD2yA)OML1yTJ0xZPXQVyqdFUQ6DWZluTwkQ3giUAHe0osBZHb91CAcE9YGPXy)sAz2ZyTq8(CDfAOoeSobDn41ldAhfzaabtpFtIHgOan8Wam4noSB9heSsT5DCf2JDIO5VajxsCS2rrgaqW0Z3abZFpApmOVMtt7qWeSO1zJP9JAAm2VKsWsMMnI0kvVsCcAIOHE5CPQ7rPp2NpwR(AonTdbtWIwNnM2pQzznmeP(AonTdbtWIwNnM2pQzznw7Oidaiy65BijAFEomeaafmWwAWylGnSR6Ge20ySFjTm72CS23BI4B(lgRpOcFyzKByqhqPANhX9V2ySFjLGKTjVHgYs5srwiut83zb6790vkwSAqGYYnzb6790vkwoAU9ZYYI3Wd)bsQH(eicYtFVNUsPPBgH(AonGe)DA1c7aA9hinllT6R50qFVNUszAC2iD31viVHgYcP8mGkwG(ERanml3KL7zz3PSOqkLLF3twihLLgJ9lVKOMyjkyXI3il(ZsjBtcWYwOecw8eMLFhzjS6gZNfnoOolkYYUtzHCeGYsJX(LxsK3Wd)bsQH(eicYh8mGQQ(Ao1u6Xye03BfOH10nJqFnNg67Tc0WMgJ9lPeKCAhPVMtdguNffRuGYBtJX(L0Yi3WG(AonyqDwuSQwP3MgJ9lPLrUXAD63UQAbSHDzLSn5n0qwGIpLfB7yYcHyPOEZcDhSuWSOJSy1GqaHzb9wfLLhWIoYIRRqwEallkYcPajeajilGKLaaOGb2swgPXukM)5kvuw0XaigPS89cz5MSaVITUKilBHsiyjb2yX2PuS4kfWglrblwEalwypXWRIYcMp2SqiwkQ3S4jml)oMSSOilKcKqaKGJ5n8WFGKAOpbIG8q8(CDfQP0JXiSAqOATuuVRO3QOAcIRwyebaem98n5rC)Rth12ReNGMiAS6lg0WNRQEh88cvRLI6Tw91CAS6lg0WNRQEh88cvRLI6TbIRwibC63UQAbSHnbkrzruIn3uleVpxxHMaiHaibRWinAg0gaafmWwAcGecGeS(7yLAD99utJX(Luc60VDv1cydBnyj2SuedWMyNWAXG6SOO5YQNr160VDv1cyd7YG4956k0eajeajy1PwAdaGcgylnbVEzW0ySFjTmYXBOHSuUuKfOV3txPyX297Sa9rLYBw0C9nFwanlVD2dlKMvGfpHzjbSa99wbAynXITDmzjbSa99E6kflhLLLflGMLhWIvdcSqiwkQ3SyBhtwCDaeKLs2MSSfkHyeOz53rwqVvrzHqSuuVzXQbbwG4956kKLJYY3lCmlGMfh2Y)dcYc1M3XSS7uwShcqXaLLgJ9lVKilGMLJYYLSmvhX9N3Wd)bsQH(eicYtFVNUsPPBgXO3vy(g6JkL3v4(MVbtxxHWddu8R6GCrn)HTD2tL0ScJ1g57kmFd99wbAydMUUcH1QVMtd99E6kLPXzJ0DxxHAJSxjobnr08xmAd0zfUrpw)syS1osFnNgR(Ibn85QQ3bpVq1APOEBG4Qfwwe2rUn1gP(AonbVEzWSS0ocI3NRRqJtTQWRyRHb91CAi5s4gHRySfWg2Xy(vmXM4zF0SSggG4956k0y1Gq1APOExrVvrhpmmkaGGPNVjXqduGgw77kmFd9rLY7kCFZ3GPRRqyTJGbVXHDR)GGvQnVJRWEStenng7xslZEgg8WFG04WU1FqWk1M3Xvyp2jIMlRt1rC)hpES2rbaqbdSLMGxVmyAm2VKwgzBomeaafmWwAcGecGeS(7yLAD99utJX(L0YiBZX8gAilAUvSfLLTqjeSOJtqJSqkqcbqcYYIEjrw(DKfsbsiasqwcGe((dKS8awc7yGewUjlKcKqaKGSCuw8WVCLkklUoy9S8aw0rwco95n8WFGKAOpbIG803B6QjIA6MraX7Z1vOXQbHQ1sr9UIERIYBOHSuUuKfnpaiPSyBhtwIcwS4nYIRdwplpG8EJSeClRljYsy3BIiLfpHzj2jbzHUAKLFhJYI3ilxYINSOXb1zrrwO)PuSmbnlA(R5rEcTMhVHh(dKud9jqeKprB1yai10nJWTQHDmqI2rHDVjI0iStBJHDVjI1)IrcsUHHWU3erAeLymVHh(dKud9jqeKF3vZAmaKA6Mr4w1Wogir7OWU3erAe2PTXWU3eX6FXibj3Wqy3BIinIsmw7i91CAWG6SOyvTsVnng7xsldjmgwpw)lghg0xZPbdQZIIvkq5TPXy)sAziHXW6X6FX4yEdp8hiPg6tGii)CPu1yai10nJWTQHDmqI2rHDVjI0iStBJHDVjI1)IrcsUHHWU3erAeLyS2r6R50Gb1zrXQALEBAm2VKwgsymSES(xmomOVMtdguNffRuGYBtJX(L0YqcJH1J1)IXX8gAilLlfzb67nD1erwiut83zXQbbklEcZc8k2ILTqjeSyBhtwi1wiF5KbnXIghBbSHnlLhKWAILFhzPKdM)E0Mf91CYYrzX1bRNLhWY0vkwaZjlGMLOG12WSeClw2cLqWB4H)aj1qFceb5PV30vte10nJadQZIIMlREgv7i91CAaj(70AqHExHC0dKML1WG(AonKCjCJWvm2cyd7ym)kMyt8SpAwwdd6R50e86LbZYs7Oidaiy65BijAFEomeaafmWwAWylGnSR6Ge20ySFjTmYnmOVMttWRxgmng7xsjiXaSj2jCPMkaOh50VDv1cydBnieVpxxHgkTga0F8yTJImaGGPNVbcM)E0EyqFnNM2HGjyrRZgt7h10ySFjLGedWMyNWLkGNA0iN(TRQwaBytasBZs9UcZ3mxD0kywr1krdMUUcHhRbH4956k0qP1aG(Jjqjk17kmFtI2QXaqAW01viS2i7vItqten0lNlvDpk9X(CT6R500oemblAD2yA)OML1WG(AonTdbtWIwNnM2pALE5CPQ7rPp2NBwwddJ0xZPPDiycw06SX0(rnng7xsjOh(dKg6798A0GegdRhR)fJAPwOsv3D6JeCtdPnmOVMtt7qWeSO1zJP9JAAm2VKsqp8hin2A)3niHXW6X6FX4WG(Aonw9fdA4ZvvVdEEHQ1sr92aXvlSSiSJSn1oYPF7QQfWg2LbX7Z1vOHsRba9lLDAg5gg0xZPPDiycw06SX0(rnng7xslZUXA1xZPPDiycw06SX0(rnng7xsjOgyyaI3NRRqZzVW1aiHV)aP2aaOGb2sZL0qVExxHv7D55VIRWiKlGMgD4OAr7DDwwiS5sAOxVRRWQ9U88xXvyeYfWXA1xZPPDiycw06SX0(rnlRHHi1xZPPDiycw06SX0(rnllTrgaafmWwAAhcMGfToBmTFutJoC0Xddq8(CDfACQvfEfBnmOdOuTZJ4(xBm2VKsqIbytSt4sfWtnYPF7QQfWg2AqiEFUUcnuAnaO)4X8gAilLUJYYdyj2jbz53rw0r6ZcyYc03BfOHzrpkl03dKCjrwUNLLfl276cKOIYYLS4zuw04G6SOil6RNfcXsr9MLJMB)S46G1ZYdyrhzXQbHacZB4H)aj1qFceb5PV30vte10nJ4DfMVH(ERanSbtxxHWAJSxjobnr08xmAd0zfUrpw)syS1osFnNg67Tc0WML1WGt)2vvlGnSlRKT5yT6R50qFVvGg2qFpqcblH2r6R50Gb1zrXkfO82SSgg0xZPbdQZIIv1k92SSgRvFnNgR(Ibn85QQ3bpVq1APOEBG4Qfsq7iKBQDuaauWaBPj41ldMgJ9lPLr2MddrcX7Z1vOjasiasWkmsJMbTbaem98n5rC)RthhZBOHSOX0)I9hPSSdSXs8kSZYwOecw8gzHOFjcZIf2SqXaiHnSqOMQOS8ojiLfNfA6w0DWZYe0S87ilHv3y(SqVF5)bswOawSbwk4C7NfDKfpewT)iltqZIYBIyZYFX4S9yKYB4H)aj1qFceb5H4956kutPhJr4ulcb2qXGMG4QfgbguNffnxwvR07szpAqp8hin03751Objmgwpw)lgjqKyqDwu0CzvTsVl1inabExH5BOGLQcM1FhRtqJ03GPRRq4svIXAqp8hin2A)3niHXW6X6FXib20qAKtdsTqLQU70hjWMgYvQ3vy(M0)vJ0QUR8mGgmDDfcZBOHSO5wXwSa99MUAIilxYINSOXb1zrrwCkluaizXPSybO0txHS4uwuGKiloLLOGfl2oLIfmHzzzXIT73zXE2KaSyBhtwW8X(sIS87iljs4NfnoOolkQjwGb52plk8z5EwSAqGfcXsr9wtSadYTFwaqW2wFpYINSqOM4VZIvdcS4jmlwaGIfDCcAKfsTfYxozGfpHzrJJTa2WMLYdsyEdp8hiPg6tGiip99MUAIOMUzer2ReNGMiA(lgTb6Sc3OhRFjm2AhPVMtJvFXGg(Cv17GNxOATuuVnqC1cjODeYnhg0xZPXQVyqdFUQ6DWZluTwkQ3giUAHe0oYTP23vy(g6JkL3v4(MVbtxxHWJ1ocdQZIIMlRuGYBTo9BxvTa2WMaq8(CDfACQfHaBOyOu6R50Gb1zrXkfO820ySFjLaWG3mxD0kywr1krZFbsO1gJ9llLDgYvM9S5WaguNffnxwvR0BTo9BxvTa2WMaq8(CDfACQfHaBOyOu6R50Gb1zrXQALEBAm2VKsayWBMRoAfmROALO5Vaj0AJX(LLYod5kRKT5yTrQVMtdiXFNwTWoGw)bsZYsBKVRW8n03BfOHny66kew7OaaOGb2stWRxgmng7xslJqomqblL(LWMFVpLQsrKeSny66kewR(Aon)EFkvLIijyBOVhiHGLOeA2OEL4e0erd9Y5sv3JsFSpVu2nw78iU)1gJ9lPLr2MBQDEe3)AJX(LucA3MBow7Oidaiy65BijAFEomeaafmWwAWylGnSR6Ge20ySFjTm7gZBOHSuUuKfnpaiPSCjlEgLfnoOolkYINWSqDiilA(7Qjbi0lLIfnpaizzcAwi1wiF5Kbw8eMLsUxc3imlACSfWg2Xy(gw2IIcyzrrw2QMhlEcZcHwZJf)z53rwWeMfWKfcDJP9JYINWSadYTFwu4ZIMRrpw)sySzz6kflG5K3Wd)bsQH(eicYNOTAmaKA6Mr4w1WogirleVpxxHgQdbRtqxdE9YG2r6R50Gb1zrXQALEBAm2VKwgsymSES(xmomOVMtdguNffRuGYBtJX(L0YqcJH1J1)IXX8gE4pqsn0Narq(DxnRXaqQPBgHBvd7yGeTq8(CDfAOoeSobDn41ldAhPVMtdguNffRQv6TPXy)sAziHXW6X6FX4WG(AonyqDwuSsbkVnng7xsldjmgwpw)lghRDK(AonbVEzWSSgg0xZPXQVyqdFUQ6DWZluTwkQ3giUAHemc7iBZXAhfzaabtpFdem)9O9WG(AonTdbtWIwNnM2pQPXy)skbhronZUs1ReNGMiAOxoxQ6Eu6J95J1QVMtt7qWeSO1zJP9JAwwddrQVMtt7qWeSO1zJP9JAwwJ1okYEL4e0erZFXOnqNv4g9y9lHXEyajmgwpw)lgjO(Aon)fJ2aDwHB0J1VegBtJX(L0HHi1xZP5Vy0gOZkCJES(LWyBwwJ5n8WFGKAOpbIG8ZLsvJbGut3mc3Qg2XajAH4956k0qDiyDc6AWRxg0osFnNgmOolkwvR0BtJX(L0YqcJH1J1)IXHb91CAWG6SOyLcuEBAm2VKwgsymSES(xmow7i91CAcE9YGzznmOVMtJvFXGg(Cv17GNxOATuuVnqC1cjye2r2MJ1okYaacME(gsI2NNdd6R50qYLWncxXylGnSJX8RyInXZ(Ozznw7Oidaiy65BGG5VhThg0xZPPDiycw06SX0(rnng7xsji50QVMtt7qWeSO1zJP9JAwwAJSxjobnr0qVCUu19O0h7ZhgIuFnNM2HGjyrRZgt7h1SSgRDuK9kXjOjIM)IrBGoRWn6X6xcJ9WasymSES(xmsq91CA(lgTb6Sc3OhRFjm2MgJ9lPddrQVMtZFXOnqNv4g9y9lHX2SSgZBOHSuUuKfcfGgZcizjaZB4H)aj1qFceb5T5DFGUcMvuTsK3qdzPCPilqFVNxJS8awSAqGfOaL3SOXb1zrrnXcP2c5lNmWYUtzrHukl)fJS87EYIZcHs7)oliHXW6rwu48zb0Sasvuw0Ov6nlACqDwuKLJYYYYWcHY97SuA7ShwSZkWcMp2S4SafO8MfnoOolkYYnzHqSuuVzH(NsXYUtzrHukl)UNSyhzBYc99ajuw8eMfsTfYxozGfpHzHuGecGeKLDhcYsmOrw(DpzHmcjLfsP5yPXy)YljAyPCPilUoacYIDKBtnil7o9rwGx9LezHq3yA)OS4jml2zNDAqw2D6JSy7(DW6zHq3yA)O8gE4pqsn0NarqE6798Aut3mcmOolkAUSQwP3AJuFnNM2HGjyrRZgt7h1SSggWG6SOOHcuExtKW)WWimOolkA8mAnrc)dd6R50e86LbtJX(Luc6H)aPXw7)Ubjmgwpw)lg1QVMttWRxgmlRXAhfjf)QoixuZFyBN9uTZkmm0ReNGMiAS6lg0WNRQEh88cvRLI6Tw91CAS6lg0WNRQEh88cvRLI6TbIRwibTJSn1gaafmWwAcE9YGPXy)sAzKri1okYaacME(M8iU)1PJddbaqbdSLMaiHaibR)owPwxFp10ySFjTmYiKJ1okY2dO5BGsnmeaafmWwA0XMInjxs00ySFjTmYiKJhpmGb1zrrZLvpJQDK(Aon28UpqxbZkQwjAwwdduluPQ7o9rcUPH0iN2rrgaqW0Z3abZFpApmeP(AonTdbtWIwNnM2pQzznEyiaGGPNVbcM)E0wl1cvQ6UtFKGBAiTX8gAilLlfzHqP9FNfWVJTTJISyB)c7SCuwUKfOaL3SOXb1zrrnXcP2c5lNmWcOz5bSy1GalA0k9MfnoOolkYB4H)aj1qFceb5T1(VZBOHSqODL637fVHh(dKud9jqeKVxz1d)bYQ6OVMspgJy6k1V3RcOulmuSvY20UIV4lka]] )


end