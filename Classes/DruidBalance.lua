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


    spec:RegisterPack( "Balance", 20220405, [[dife6fqiHOhHOkxcrfTjsPpPuQrPqoLc1QKi5viGzrkYTOuf7IIFrk0Wuk6yiklJsLNrPQMgIuUgPGTHOcFdbPghPO6CseX6KiQ5HaDpHW(KO8psrPOdQusluIQEiIKjskkUiIkTreK8rsrPQrskkLoPevSsLcVuIiXmruv3KuuYovkXprqudfbHJskkfwQerQNcstvIuxvIkTvjIK(kcImwePAVs4VsAWehMQftQESGjdQldTzf9zeA0kvNwLvtkkvEnIy2KCBHA3I(nWWPKJtPkTCPEostxvxxjBheFNsz8iOoVqA9seMVc2pQliRO0fqH9hl2IDBANDBsABQbdzAU9ljAqZlG(rTWcOwEGeNiwan9ySaA5DLNbSaQLhvbC4IsxaLcwDalGU)VfTK1Og1DLNb0EOxCWq8(9LU5aAS8UYZaApqVysPXyyZ(hR0S58uye6UYZaAEc)fq1xN6lNSqVakS)yXwSBt7SBtsBtnyitZTFjrdKwbuF97GUak0lMufq3pyyml0lGcJ0qb0Y7kpdilAMEDW8gB1QpflAqtSy3M2zhVbVbP29KislzEd7HLTcdJWSafO8MLYJESH3WEyHu7EseHz59Mi(1BYsWPiLLhWsiAqH13BI4tn8g2dlL0ymaccZYktmGuQ3rzbI3NRRqklJodA0elwncPsFVPRMiYI9uglwncXqFVPRMio2WBypSSviGdMfRgdo9VKilesT)7SCtwUFBkl)oYITgKezHCdQZIIgEd7HfnlNeKfsbsiasqw(DKfOwxFpLfNf19Vczjg0iltfs4txHSm6MSefSyz3HZTFw2VNL7zHEXl17jcwuvuwSD)olLNqERLMfcWcPqfs)ZvSSv1rmJX81el3VnmlusoRXgEd7HfnlNeKLya9zz75rC)Rng7xs3MfAatVpaLf3YsfLLhWIoGszzEe3FklGuf1WBypSu6g9NLsdIrwatwkVY3zP8kFNLYR8DwCklolulmCUILVVKe8n8g2dleYwyInlJodA0elesT)7AIfcP2)DnXc037514ywIDyKLyqJS0i9uhMplpGf0B1HnlbqSU)2d99(n8g2dleQJWSus5s4gHzHCJTa2WogZNLWogiHLjOzHuAgwwuNiA4nShwkPXyaeKf4EDWMeudWuwc7yGeQPaQ6OpTO0fqbwyIDrPl2czfLUakMUUcHlkFbup8hilGAR9FVakmsd9z9hilGsiAm40Nf7yHqQ9FNfpHzXzb67nD1erwajlqlnl2UFNLTCe3FwiuoYINWSuEWwlnlGMfOV3ZRrwa)o22okwan03J95fqhXcguNffnQv6Dnrc)SmmWcguNffnxwPaL3SmmWcguNffnxw1b)olddSGb1zrrJNrRjs4NLXSOLfRgHyiZyR9FNfTSejlwncXyNXw7)EXxSf7kkDbumDDfcxu(cOE4pqwaL(EpVglGg67X(8cOJyzelrYsVsCcAIOr3vEgWkywDLQ(7xsKAW01vimlddSejlbaem98n5rC)RthzzyGLizHAHkv99Mi(ud99E6kflrWczSmmWsKS8UcZ3K(VAKw1DLNb0GPRRqywgZYWalJybdQZIIgkq5Dnrc)SmmWcguNffnxwvR0BwggybdQZIIMlR6GFNLHbwWG6SOOXZO1ej8ZYywgZIwwIKfk(vDqUOM)W2onVANvOaQ6sSgGlGQHIVyl2VO0fqX01viCr5lG6H)azbu67nD1eXcOH(ESpVa6iw6vItqten6UYZawbZQRu1F)sIudMUUcHzrllbaem98n5rC)RthzrlluluPQV3eXNAOV3txPyjcwiJLXSOLLizHIFvhKlQ5pSTtZR2zfkGQUeRb4cOAO4l(cOW40xQVO0fBHSIsxa1d)bYcOuGY7Qo6XfqX01viCr5l(ITyxrPlGIPRRq4IYxan03J95fq)lgzHGSmIf7yPuS4H)aPXw7)Uj40V(xmYcbyXd)bsd99EEnAco9R)fJSmUak97l8fBHScOE4pqwan4kv1d)bYQ6OFbu1r)A6XybuGfMyx8fBX(fLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaLAHkv99Mi(ud99E6kflLXczSOLLrSejlVRW8n03BfOHny66keMLHbwExH5BOpQuExH7B(gmDDfcZYywggyHAHkv99Mi(ud99E6kflLXIDfqHrAOpR)azbuO4tzzRaYLfqYI9jal2UFhSEwG7B(S4jml2UFNfOV3kqdZINWSyhbyb87yB7OybuiExtpglGE0QdWIVylKwrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfqPwOsvFVjIp1qFVNxJSuglKvafgPH(S(dKfqHIpLLGcDiil22XKfOV3ZRrwcEYY(9Syhby59Mi(uwSTFHDwoklnQqiE(Smbnl)oYc5guNffz5bSOJSy14e7gHzXtywSTFHDwMNsHnlpGLGt)cOq8UMEmwa9O1GcDiyXxSfnuu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwybuRgHujgGnKzIbGCEnYYWalwncPsmaBiZqx58AKLHbwSAesLya2qMH(EtxnrKLHbwSAesLya2qMH(EpDLILHbwSAesLya2qMzU6OvWSIQvISmmWIvJqmTdbtWIwNnMLiklddSOVMttWRxgmng7xszjcw0xZPj41ldg4v7)bswggybI3NRRqZrRoalGcJ0qFw)bYcOLu9(CDfYYV7plHDmqcLLBYsuWIfVrwUKfNfIbywEaloeWbZYVJSqVF5)bswSTJnYIZY3xsc(SGFGLJYYIIWSCjl64BdXKLGtFAbuiExtpglGEzLyaU4l2c5OO0fqX01viCr5lG6H)azbuDSPytYLelGcJ0qFw)bYcOLlfzP8ytXMKljYI)S87ilycZcyYcHQXSerzX2oMSS70hz5OS46aiilKJnjNAIfF(yZcPajeajil2UFNLYd8sZINWSa(DSTDuKfB3VZcP2QglNmuan03J95fqhXYiwIKLaacME(M8iU)1PJSmmWsKSeaafmWwAcGecGeS(7yLAD99uZYILHbwIKLEL4e0erJUR8mGvWS6kv93VKi1GPRRqywgZIww0xZPj41ldMgJ9lPSuglKPbw0YI(AonTdbtWIwNnMLiQPXy)skleKfsJfTSejlbaem98nqW83J2SmmWsaabtpFdem)9OnlAzrFnNMGxVmywwSOLf91CAAhcMGfToBmlruZYIfTSmIf91CAAhcMGfToBmlrutJX(LuwiyeSqMDSypSqASukw6vItqten0lNlvDpk9X(CdMUUcHzzyGf91CAcE9YGPXy)skleKfYiJLHbwiJfnYc1cvQ6UtFKfcYczgYblJzzmlAzbI3NRRqZLvIb4IVyle6IsxaftxxHWfLVaAOVh7ZlGoIf91CAcE9YGPXy)sklLXczAGfTSmILizPxjobnr0qVCUu19O0h7Zny66keMLHbw0xZPPDiycw06SXSernng7xszHGSqwjHfTSOVMtt7qWeSO1zJzjIAwwSmMLHbw0buklAzzEe3)AJX(Luwiil2PbwgZIwwG4956k0CzLyaUakmsd9z9hilGsiapl2UFNfNfsTvnwozGLF3FwoAU9ZIZcHyPOEZIvdcSaAwSTJjl)oYY8iU)SCuwCDW6z5bSGjCbup8hilGAb(dKfFXw08IsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGgWtXYiwgXY8iU)1gJ9lPSypSqMgyXEyjaakyGT0e86LbtJX(LuwgZIgzHmnFtwgZszSeWtXYiwgXY8iU)1gJ9lPSypSqMgyXEyjaakyGT0eajeajy93Xk1667PMgJ9lPSmMfnYczA(MSmMfTSejlTFWvecMVXHHPgKWh9PSOLLrSejlbaqbdSLMGxVmyA0HJYYWalrYsaauWaBPjasiasW6VJvQ113tnn6WrzzmlddSeaafmWwAcE9YGPXy)sklLXYLp2waL)iCDEe3)AJX(LuwggyPxjobnr0eqfs)ZvvQ113tny66keMfTSeaafmWwAcE9YGPXy)sklLXI93KLHbwcaGcgylnbqcbqcw)DSsTU(EQPXy)sklLXYLp2waL)iCDEe3)AJX(LuwShwiBtwggyjswcaiy65BYJ4(xNowafgPH(S(dKfqjLRclL)iLfB74VJnll6LezHuGecGeKLeyJfBNsXIRuaBSefSy5bSq)tPyj40NLFhzH6XilEmyLplGjlKcKqaKGeGuBvJLtgyj40NwafI310JXcObqcbqcwHrA0mu8fBPKuu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0rS8EteFZFXy9bv4dzPmwitdSmmWs7hCfHG5BCyyQ5swkJfnSjlJzrllJyzelO9Uolle2GXwrB0vvqdNEgqw0YYiwIKLaacME(giy(7rBwggyjaakyGT0GXwrB0vvqdNEgqtJX(LuwiilKroi0SqawgXIgyPuS0ReNGMiAOxoxQ6Eu6J95gmDDfcZYywgZIwwIKLaaOGb2sdgBfTrxvbnC6zann6WrzzmlddSG276SSqydfSuk8)ljw7LEuw0YYiwIKLaacME(M8iU)1PJSmmWsaauWaBPHcwkf()LeR9spA1(KMg08njZ0ySFjLfcYczKrASmMLHbwgXsaauWaBPrhBk2KCjrtJoCuwggyjswApGMVbkflddSeaqW0Z3KhX9VoDKLXSOLLrSejlVRW8nZvhTcMvuTs0GPRRqywggyjaGGPNVbcM)E0MfTSeaafmWwAMRoAfmROALOPXy)skleKfYiJfcWIgyPuS0ReNGMiAOxoxQ6Eu6J95gmDDfcZYWalrYsaabtpFdem)9OnlAzjaakyGT0mxD0kywr1krtJX(Luwiil6R50e86Lbd8Q9)ajleGfYSJLsXsVsCcAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZI9Wcz2XYyw0YYiwq7DDwwiS5sAOxVRRWQ9U88xXvyeYfqw0YsaauWaBP5sAOxVRRWQ9U88xXvyeYfqtJX(LuwiilAGLXSmmWYiwgXcAVRZYcHn0DhgydHRGwVcM1h0Xy(SOLLaaOGb2sZd6ymFeUEj9iU)v7RbnyF7iZ0ySFjLLXSmmWYiwgXceVpxxHgqwxuS(9LKGplrWczSmmWceVpxxHgqwxuS(9LKGplrWI9zzmlAzzelFFjj4BEYmn6WrRbaqbdSLSmmWY3xsc(MNmtaauWaBPPXy)sklLXYLp2waL)iCDEe3)AJX(LuwShwiBtwgZYWalq8(CDfAazDrX63xsc(Sebl2XIwwgXY3xsc(M3otJoC0AaauWaBjlddS89LKGV5TZeaafmWwAAm2VKYszSC5JTfq5pcxNhX9V2ySFjLf7HfY2KLXSmmWceVpxxHgqwxuS(9LKGplrWYMSmMLXSmUakmsd9z9hilGwUueMLhWcmQ8OS87illQtezbmzHuBvJLtgyX2oMSSOxsKfyWsxHSaswwuKfpHzXQriy(SSOorKfB7yYINS4WWSGqW8z5OS46G1ZYdyb(WcOq8UMEmwanaxdGe((dKfFXwiBZIsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGgjluWsPFjS537tPQuejbBdMUUcHzzyGL5rC)Rng7xszPmwSBZnzzyGfDaLYIwwMhX9V2ySFjLfcYIDAGfcWYiwiTnzXEyrFnNMFVpLQsrKeSn03dKWsPyXowgZYWal6R50879PuvkIKGTH(EGewkJf7R5SypSmILEL4e0erd9Y5sv3JsFSp3GPRRqywkfl2XY4cOWin0N1FGSaAjvVpxxHSSOimlpGfyu5rzXZOS89LKGpLfpHzjatzX2oMSyZV)sISmbnlEYc5US2b95Sy1GqbuiExtpglG(79PuvkIKGD1MFFXxSfYiRO0fqX01viCr5lGcJ0qFw)bYcOLlfzHCJTI2ORyHqUHtpdil2Tjfduw0XjOrwCwi1w1y5KbwwuKfqZcfWYV7pl3ZITtPyrDjYYYIfB3VZYVJSGjmlGjleQgZseTaA6Xybum2kAJUQcA40Zawan03J95fqdaGcgylnbVEzW0ySFjLfcYIDBYIwwcaGcgylnbqcbqcw)DSsTU(EQPXy)skleKf72KfTSmIfiEFUUcn)EFkvLIijyxT53ZYWal6R50879PuvkIKGTH(EGewkJf7VjleGLrS0ReNGMiAOxoxQ6Eu6J95gmDDfcZsPyX(SmMLXSOLfiEFUUcnxwjgGzzyGfDaLYIwwMhX9V2ySFjLfcYI9j0fq9WFGSakgBfTrxvbnC6zal(ITqMDfLUakMUUcHlkFbuyKg6Z6pqwaTCPilqblLc)ljYsj9spklKdkgOSOJtqJS4SqQTQXYjdSSOilGMfkGLF3FwUNfBNsXI6sKLLfl2UFNLFhzbtywatwiunMLiAb00JXcOuWsPW)VKyTx6rlGg67X(8cOJyjaakyGT0e86LbtJX(LuwiilKdw0YsKSeaqW0Z3abZFpAZIwwIKLaacME(M8iU)1PJSmmWsaabtpFtEe3)60rw0YsaauWaBPjasiasW6VJvQ113tnng7xszHGSqoyrllJybI3NRRqtaKqaKGvyKgndSmmWsaauWaBPj41ldMgJ9lPSqqwihSmMLHbwcaiy65BGG5VhTzrllJyjsw6vItqten0lNlvDpk9X(CdMUUcHzrllbaqbdSLMGxVmyAm2VKYcbzHCWYWal6R500oemblAD2ywIOMgJ9lPSqqwiBtwialJyrdSukwq7DDwwiS5s63RWdAAf(GCjw1rLILXSOLf91CAAhcMGfToBmlruZYILXSmmWIoGszrllZJ4(xBm2VKYcbzXonWYWalO9Uolle2GXwrB0vvqdNEgqw0YsaauWaBPbJTI2ORQGgo9mGMgJ9lPSugl2TjlJzrllq8(CDfAUSsmaZIwwIKf0ExNLfcBUKg6176kSAVlp)vCfgHCbKLHbwcaGcgylnxsd96DDfwT3LN)kUcJqUaAAm2VKYszSy3MSmmWIoGszrllZJ4(xBm2VKYcbzXUnlG6H)azbukyPu4)xsS2l9OfFXwiZ(fLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwavFnNMGxVmyAm2VKYszSqMgyrllJyjsw6vItqten0lNlvDpk9X(CdMUUcHzzyGf91CAAhcMGfToBmlrutJX(LuwiyeSqMgmAGfcWYiwSVrdSukw0xZPrxbaWQf9nllwgZcbyzelKMrdSypSyFJgyPuSOVMtJUcaGvl6BwwSmMLsXcAVRZYcHnxs)EfEqtRWhKlXQoQuSqawinJgyPuSmIf0ExNLfcB(DSoVM(v6r8uSOLLaaOGb2sZVJ1510VspINY0ySFjLfcgbl2TjlJzrll6R500oemblAD2ywIOMLflJzzyGfDaLYIwwMhX9V2ySFjLfcYIDAGLHbwq7DDwwiSbJTI2ORQGgo9mGSOLLaaOGb2sdgBfTrxvbnC6zanng7xslGcJ0qFw)bYcOBvzZJszzrrwkhnBOzyX297SqQTQXYjdSaAw8NLFhzbtywatwiunMLiAbuiExtpglGE2lCnas47pqw8fBHmsRO0fqX01viCr5lG6H)azb0lPHE9UUcR27YZFfxHrixalGg67X(8cOq8(CDfAo7fUgaj89hizrllq8(CDfAUSsmaxan9ySa6L0qVExxHv7D55VIRWiKlGfFXwitdfLUakMUUcHlkFbuyKg6Z6pqwaTCPilq3DyGneMfc5wNfDCcAKfsTvnwozOaA6Xybu6UddSHWvqRxbZ6d6ym)cOH(ESpVa6iwcaGcgylnbVEzW0OdhLfTSejlbaem98n5rC)Rthzrllq8(CDfA(9(uQkfrsWUAZVNfTSmILaaOGb2sJo2uSj5sIMgD4OSmmWsKS0EanFdukwgZYWalbaem98n5rC)RthzrllbaqbdSLMaiHaibR)owPwxFp10OdhLfTSmIfiEFUUcnbqcbqcwHrA0mWYWalbaqbdSLMGxVmyA0HJYYywgZIwwGbVHUY51O5VajxsKfTSmIfyWBOpQuExNkVrZFbsUKilddSejlVRW8n0hvkVRtL3ObtxxHWSmmWc1cvQ67nr8Pg6798AKLYyX(SmMfTSadEtmaKZRrZFbsUKilAzzelq8(CDfAoA1bilddS0ReNGMiA0DLNbScMvxPQ)(LePgmDDfcZYWalo9BxvTa2WMLYIGLsYMSmmWceVpxxHMaiHaibRWinAgyzyGf91CA0vaaSArFZYILXSOLLizbT31zzHWMlPHE9UUcR27YZFfxHrixazzyGf0ExNLfcBUKg6176kSAVlp)vCfgHCbKfTSeaafmWwAUKg6176kSAVlp)vCfgHCb00ySFjLLYyX(BYIwwIKf91CAcE9YGzzXYWal6akLfTSmpI7FTXy)skleKfsBZcOE4pqwaLU7WaBiCf06vWS(GogZV4l2czKJIsxaftxxHWfLVakmsd9z9hilGw69JYYrzXzP9FhBwqLRdA)rwS5rz5bSe7KGS4kflGKLffzH((ZY3xsc(uwEal6ilQlrywwwSy7(Dwi1w1y5Kbw8eMfsbsiasqw8eMLffz53rwSlHzHQaplGKLaml3KfDWVZY3xsc(uw8gzbKSSOil03Fw((ssWNwan03J95fqH4956k0aY6II1VVKe8zjYiyHmw0YsKS89LKGV5TZ0OdhTgaafmWwYYWalJybI3NRRqdiRlkw)(ssWNLiyHmwggybI3NRRqdiRlkw)(ssWNLiyX(SmMfTSmIf91CAcE9YGzzXIwwcaiy65BGG5VhTzrllJyrFnNM2HGjyrRZgZse10ySFjLfcWYiwSVrdSukw6vItqten0lNlvDpk9X(CdMUUcHzzmlemcw((ssW38Kz0xZzfE1(FGKfTSOVMtt7qWeSO1zJzjIAwwSmmWI(AonTdbtWIwNnMLiALE5CPQ7rPp2NBwwSmMLHbwcaGcgylnbVEzW0ySFjLfcWIDSuglFFjj4BEYmbaqbdSLg4v7)bsw0YYiwIKLEL4e0erJvFXGg(Cv17GNxOATuuVny66keMLHbw0xZPj41ldMgJ9lPSuglKdwgZIwwgXsKSeaqW0Z3KhX9VoDKLHbw((ssW38KzcaGcgylnWR2)dKSuglbaqbdSLMaiHaibR)owPwxFp10ySFjLLHbwG4956k0eajeajyfgPrZalAz57ljbFZtMjaakyGT0aVA)pqYszSeaafmWwAcE9YGPXy)sklJzrllrYsaabtpFdjr7ZtwggyjaGGPNVjpI7FD6ilAzbI3NRRqtaKqaKGvyKgndSOLLaaOGb2staKqaKG1FhRuRRVNAwwSOLLizjaakyGT0e86LbZYIfTSmILrSOVMtdguNffRQv6TPXy)sklLXIgyzyGf91CAWG6SOyLcuEBAm2VKYszSObwgZYywggyrFnNgsUeUr4kgBbSHDmMFftSjELanllwgZYWalZJ4(xBm2VKYcbzXUnzzyGfiEFUUcnGSUOy97ljbFwIGLnlGsvGNwa97ljbFYkG6H)azb0VVKe8jR4l2cze6IsxaftxxHWfLVaQh(dKfq)(ssW3UcOH(ESpVakeVpxxHgqwxuS(9LKGplrgbl2XIwwIKLVVKe8npzMgD4O1aaOGb2swggybI3NRRqdiRlkw)(ssWNLiyXow0YYiw0xZPj41ldMLflAzjaGGPNVbcM)E0MfTSmIf91CAAhcMGfToBmlrutJX(LuwialJyX(gnWsPyPxjobnr0qVCUu19O0h7Zny66keMLXSqWiy57ljbFZBNrFnNv4v7)bsw0YI(AonTdbtWIwNnMLiQzzXYWal6R500oemblAD2ywIOv6LZLQUhL(yFUzzXYywggyjaakyGT0e86LbtJX(Luwial2XszS89LKGV5TZeaafmWwAGxT)hizrllJyjsw6vItqtenw9fdA4ZvvVdEEHQ1sr92GPRRqywggyrFnNMGxVmyAm2VKYszSqoyzmlAzzelrYsaabtpFtEe3)60rwggy57ljbFZBNjaakyGT0aVA)pqYszSeaafmWwAcGecGeS(7yLAD99utJX(LuwggybI3NRRqtaKqaKGvyKgndSOLLVVKe8nVDMaaOGb2sd8Q9)ajlLXsaauWaBPj41ldMgJ9lPSmMfTSejlbaem98nKeTppzrllJyjsw0xZPj41ldMLflddSejlbaem98nqW83J2SmMLHbwcaiy65BYJ4(xNoYIwwG4956k0eajeajyfgPrZalAzjaakyGT0eajeajy93Xk1667PMLflAzjswcaGcgylnbVEzWSSyrllJyzel6R50Gb1zrXQALEBAm2VKYszSObwggyrFnNgmOolkwPaL3MgJ9lPSuglAGLXSmMLXSmmWI(AonKCjCJWvm2cyd7ym)kMyt8kbAwwSmmWY8iU)1gJ9lPSqqwSBtwggybI3NRRqdiRlkw)(ssWNLiyzZcOuf4Pfq)(ssW3UIVylKP5fLUakMUUcHlkFbuyKg6Z6pqwaTCPiLfxPyb87yZcizzrrwUhJPSaswcWfq9WFGSa6II17XyAXxSfYkjfLUakMUUcHlkFbuyKg6Z6pqwaLCVFhBwicy5YhWYVJSqFwanloazXd)bswuh9lG6H)azb0ELvp8hiRQJ(fqPFFHVylKvan03J95fqH4956k0C0QdWcOQJ(10JXcOoal(ITy3MfLUakMUUcHlkFbup8hilG2RS6H)azvD0VaQ6OFn9ySak9l(IVaQvJbqSU)fLUylKvu6cOE4pqwaLKlHBeUsTU(EAbumDDfcxu(IVyl2vu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0nlGcJ0qFw)bYcOLEhzbI3NRRqwoklu8z5bSSjl2UFNLeWc99NfqYYIIS89LKGpvtSqgl22XKLFhzzEn9zbKilhLfqYYIIAIf7y5MS87ilumasywoklEcZI9z5MSOd(Dw8glGcX7A6XybuqwxuS(9LKGFXxSf7xu6cOy66keUO8fqbwfqDy4cOE4pqwafI3NRRWcOqC1clGswb0qFp2Nxa97ljbFZtMz3P1ffR6R5KfTS89LKGV5jZeaafmWwAGxT)hizrllrYY3xsc(MNmZrnpigRGzngK0VblAnas63RWFGKwafI310JXcOGSUOy97ljb)IVylKwrPlGIPRRq4IYxafyva1HHlG6H)azbuiEFUUclGcXvlSaQDfqd99yFEb0VVKe8nVDMDNwxuSQVMtw0YY3xsc(M3otaauWaBPbE1(FGKfTSejlFFjj4BE7mh18GyScM1yqs)gSO1aiPFVc)bsAbuiExtpglGcY6II1VVKe8l(ITOHIsxaftxxHWfLVakWQaQddxa1d)bYcOq8(CDfwafI310JXcOGSUOy97ljb)cOH(ESpVakAVRZYcHnxsd96DDfwT3LN)kUcJqUaYYWalO9Uolle2GXwrB0vvqdNEgqwggybT31zzHWgkyPu4)xsS2l9OfqHrAOpR)azb0sVJuKLVVKe8PS4nYscEw81dI9)cUsfLfy8XWJWS4uwajllkYc99NLVVKe8Pgwybk(SaX7Z1vilpGfsJfNYYVJrzXvualjIWSqTWW5kw29ewDjrtbuiUAHfqjTIVylKJIsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGA)nzPuSmIfYyXEyztdzAGLsXcf)QoixuZFyBNMxjnRalJlGcJ0qFw)bYcOqXNYYVJSa99MUAIilba9zzcAwu(Jnlbxfwk)pqszz0e0SGe2JTuil22XKLhWc99(zbEfBDjrw0XjOrwiunMLikltxPOSaMZXfqH4Dn9ySakLwda6x8fBHqxu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwybunSjlLILrSqgl2dlBAitdSukwO4x1b5IA(dB708kPzfyzCbuiExtpglGsN1aG(fFXw08IsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGA)nzHaSq2MSukw6vItqtenbuH0)CvLAD99udMUUcHlGcJ0qFw)bYcOqXNYI)SyB)c7S4XGv(SaMSSvkHGfsbsiasqwO7GLcMfDKLffHlzwiTnzX297G1ZcPqfs)ZvSa1667PS4jml2FtwSD)UPakeVRPhJfqdGecGeS6uRIVylLKIsxa1d)bYcOXaqsYL1jOJlGIPRRq4IYx8fBHSnlkDbumDDfcxu(cOE4pqwa1w7)Eb0qFp2NxaDelyqDwu0OwP31ej8ZYWalyqDwu0CzLcuEZYWalyqDwu0Czvh87SmmWcguNffnEgTMiHFwgxavDjwdWfqjBZIV4lG6aSO0fBHSIsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clG2ReNGMiA(lgTb6Sc3OhRFjm2gmDDfcZIwwgXI(Aon)fJ2aDwHB0J1VegBtJX(LuwiiledWMyNWSqaw20qglddSOVMtZFXOnqNv4g9y9lHX20ySFjLfcYIh(dKg6798A0GegdRhR)fJSqaw20qglAzzelyqDwu0CzvTsVzzyGfmOolkAOaL31ej8ZYWalyqDwu04z0AIe(zzmlJzrll6R508xmAd0zfUrpw)sySnlRcOWin0N1FGSakPCvyP8hPSyBh)DSz53rw0mn6Xb)d7yZI(AozX2PuSmDLIfWCYIT73VKLFhzjrc)SeC6xafI310JXcOWn6XvBNsvNUsvbZzXxSf7kkDbumDDfcxu(cOaRcOu8lG6H)azbuiEFUUclGcXvlSaAKSGb1zrrZLvkq5nlAzHAHkv99Mi(ud99EEnYszSqOzXEy5DfMVHcwQkyw)DSobnsFdMUUcHzPuSyhleGfmOolkAUSQd(Dw0YsKS0ReNGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSOLLizPxjobnr0as83P1Gc9Uc5Ohiny66keUakmsd9z9hilGskxfwk)rkl22XFhBwG(EtxnrKLJYInq)7SeC6FjrwaqWMfOV3ZRrwUKfYFLEZc5guNfflGcX7A6Xyb0JycASsFVPRMiw8fBX(fLUakMUUcHlkFbup8hilGgajeajy93Xk1667PfqHrAOpR)azb0YLISqkqcbqcYITDmzXFwuiLYYV7jlAytw2kLqWINWSOUezzzXIT73zHuBvJLtgkGg67X(8cOJyzelq8(CDfAcGecGeScJ0OzGfTSejlbaqbdSLMGxVmyA0HJYIwwIKLEL4e0erJvFXGg(Cv17GNxOATuuVny66keMLHbw0xZPj41ldMLflAzzelrYsVsCcAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZYWal9kXjOjIMaQq6FUQsTU(EQbtxxHWSmmWY8iU)1gJ9lPSuglKzhHMLHbw0buklAzzEe3)AJX(LuwiilbaqbdSLMGxVmyAm2VKYcbyHSnzzyGf91CAcE9YGPXy)sklLXcz2XYywgZIwwgXYiwgXIt)2vvlGnSzHGrWceVpxxHMaiHaibRo1ILHbwOwOsvFVjIp1qFVNxJSugl2NLXSOLLrSOVMtdguNffRQv6TPXy)sklLXczBYYWal6R50Gb1zrXkfO820ySFjLLYyHSnzzmlddSOVMttWRxgmng7xszPmw0alAzrFnNMGxVmyAm2VKYcbJGfYSJLXSOLLrSejlVRW8n0hvkVRW9nFdMUUcHzzyGf91CAOV3txPmng7xszHGSqMrdSypSSPrdSukw6vItqtenbuH0)CvLAD99udMUUcHzzyGf91CAcE9YGPXy)skleKf91CAOV3txPmng7xszHaSObw0YI(AonbVEzWSSyzmlAzzelrYsVsCcAIO5Vy0gOZkCJES(LWyBW01vimlddSejl9kXjOjIMaQq6FUQsTU(EQbtxxHWSmmWI(Aon)fJ2aDwHB0J1VegBtJX(LuwkJfKWyy9y9VyKLXSmmWsVsCcAIOr3vEgWkywDLQ(7xsKAW01vimlJzrllJyjsw6vItqten6UYZawbZQRu1F)sIudMUUcHzzyGLrSOVMtJUR8mGvWS6kv93VKiTM(VA0qFpqclrWIMZYWal6R50O7kpdyfmRUsv)9ljsREh8en03dKWseSO5SmMLXSmmWIoGszrllZJ4(xBm2VKYcbzHSnzrllrYsaauWaBPj41ldMgD4OSmU4l2cPvu6cOy66keUO8fq9WFGSakDLZRXcOHObfwFVjIpTylKvan03J95fqhXsJZgP7UUczzyGf91CAWG6SOyLcuEBAm2VKYcbzX(SOLfmOolkAUSsbkVzrllng7xszHGSqgPXIwwExH5BOGLQcM1FhRtqJ03GPRRqywgZIwwEVjIV5VyS(Gk8HSuglKrASypSqTqLQ(EteFkleGLgJ9lPSOLLrSGb1zrrZLvpJYYWalng7xszHGSqmaBIDcZY4cOWin0N1FGSaA5srwGUY51ilxYILNWy8fybKS4z0F)sIS87(ZI6GGuwiJ0OyGYINWSOqkLfB3VZsmOrwEVjIpLfpHzXFw(DKfmHzbmzXzbkq5nlKBqDwuKf)zHmsJfkgOSaAwuiLYsJX(LxsKfNYYdyjbpl7oKljYYdyPXzJ0DwGx9LezH8xP3SqUb1zrXIVylAOO0fqX01viCr5lG6H)azbu6kNxJfqHrAOpR)azb0YLISaDLZRrwEal7oeKfNfIkGURy5bSSOilLJMn0mfqd99yFEbuiEFUUcnN9cxdGe((dKSOLLaaOGb2sZL0qVExxHv7D55VIRWiKlGMgD4OSOLf0ExNLfcBUKg6176kSAVlp)vCfgHCbKfTS4w1WogiP4l2c5OO0fqX01viCr5lG6H)azbu6790vQcOWin0N1FGSaAjfeTyzzXc037PRuS4plUsXYFXiLLvQqkLLf9sISq(rdE7uw8eML7z5OS46G1ZYdyXQbbwanlk8z53rwOwy4CflE4pqYI6sKfDubSXYUNWkKfntJES(LWyZcizXowEVjIpTaAOVh7ZlGgjlVRW8n0hvkVRW9nFdMUUcHzrllJyjswO4x1b5IA(dB708kPzfyzyGfmOolkAUS6zuwggyHAHkv99Mi(ud99E6kflLXI9zzmlAzzel6R50qFVNUszAC2iD31vilAzzeluluPQV3eXNAOV3txPyHGSyFwggyjsw6vItqten)fJ2aDwHB0J1VegBdMUUcHzzmlddS8UcZ3qblvfmR)owNGgPVbtxxHWSOLf91CAWG6SOyLcuEBAm2VKYcbzX(SOLfmOolkAUSsbkVzrll6R50qFVNUszAm2VKYcbzHqZIwwOwOsvFVjIp1qFVNUsXszrWcPXYyw0YYiwIKLEL4e0erJkAWBNwNke)ljwjQUylkAW01vimlddS8xmYc5KfstdSugl6R50qFVNUszAm2VKYcbyXowgZIwwEVjIV5VyS(Gk8HSuglAO4l2cHUO0fqX01viCr5lG6H)azbu6790vQcOWin0N1FGSakH097Sa9rLYBw0m9nFwwuKfqYsaMfB7yYsJZgP7UUczrF9Sq)tPyXMFpltqZc5hn4TtzXQbbw8eMfyqU9ZYIISOJtqJSqknd1Wc0)ukwwuKfDCcAKfsbsiasqwOxgqw(D)zX2PuSy1GalEc(DSzb6790vQcOH(ESpVa67kmFd9rLY7kCFZ3GPRRqyw0YI(Aon037PRuMgNns3DDfYIwwgXsKSqXVQdYf18h22P5vsZkWYWalyqDwu0Cz1ZOSmmWc1cvQ67nr8Pg6790vkwkJf7ZYyw0YYiwIKLEL4e0erJkAWBNwNke)ljwjQUylkAW01vimlddS8xmYc5KfstdSuglKglJzrllZJ4(xBm2VKYszSy)IVylAErPlGIPRRq4IYxa1d)bYcO037PRufqHrAOpR)azbucP73zrZ0OhRFjm2SSOilqFVNUsXYdyHeeTyzzXYVJSOVMtw0JYIROaww0ljYc037PRuSasw0alumasyklGMffsPS0ySF5LelGg67X(8cO9kXjOjIM)IrBGoRWn6X6xcJTbtxxHWSOLfQfQu13BI4tn037PRuSuweSyFw0YYiwIKf91CA(lgTb6Sc3OhRFjm2MLflAzrFnNg6790vktJZgP7UUczzyGLrSaX7Z1vObUrpUA7uQ60vQkyozrllJyrFnNg6790vktJX(Luwiil2NLHbwOwOsvFVjIp1qFVNUsXszSyhlAz5DfMVH(Os5DfUV5BW01vimlAzrFnNg6790vktJX(LuwiilAGLXSmMLXfFXwkjfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4Qfwa1PF7QQfWg2SuglA(MSukwgXczSypSqXVQdYf18h22P5v7ScSukw20yhlJzPuSmIfYyXEyrFnNM)IrBGoRWn6X6xcJTH(EGewkflBAiJLXSypSmIf91CAOV3txPmng7xszPuSyFw0iluluPQ7o9rwkflrYY7kmFd9rLY7kCFZ3GPRRqywgZI9WYiwcaGcgyln037PRuMgJ9lPSukwSplAKfQfQu1DN(ilLIL3vy(g6JkL3v4(MVbtxxHWSmMf7HLrSOVMtZC1rRGzfvRenng7xszPuSObwgZIwwgXI(Aon037PRuMLflddSeaafmWwAOV3txPmng7xszzCbuyKg6Z6pqwaLuUkSu(JuwSTJ)o2S4Sa99MUAIillkYITtPyj4lkYc037PRuS8awMUsXcyo1elEcZYIISa99MUAIilpGfsq0IfntJES(LWyZc99ajSSSmSO5BYYrz53rwA0ExxJWSSvkHGLhWsWPplqFVPRMisaOV3txPkGcX7A6Xybu6790vQQnq(1PRuvWCw8fBHSnlkDbumDDfcxu(cOE4pqwaL(EtxnrSakmsd9z9hilGwUuKfOV30vtezX297SOzA0J1VegBwEalKGOflllw(DKf91CYIT73bRNffGEjrwG(EpDLILL1FXilEcZYIISa99MUAIilGKfsJaSuEWwlnl03dKqzzL)PyH0y59Mi(0cOH(ESpVakeVpxxHg4g94QTtPQtxPQG5KfTSaX7Z1vOH(EpDLQAdKFD6kvfmNSOLLizbI3NRRqZrmbnwPV30vtezzyGLrSOVMtJUR8mGvWS6kv93VKiTM(VA0qFpqclLXI9zzyGf91CA0DLNbScMvxPQ)(LePvVdEIg67bsyPmwSplJzrlluluPQV3eXNAOV3txPyHGSqASOLfiEFUUcn037PRuvBG8RtxPQG5S4l2czKvu6cOy66keUO8fq9WFGSaQd7w)bbRuBEhxanenOW67nr8PfBHScOH(ESpVaAKS8xGKljYIwwIKfp8hinoSB9heSsT5DCf2JDIO5Y6uDe3Fwggybg8gh2T(dcwP28oUc7Xor0qFpqcleKf7ZIwwGbVXHDR)GGvQnVJRWEStenng7xszHGSy)cOWin0N1FGSaA5srwO28oMfkGLF3FwIcwSqeFwIDcZYY6VyKf9OSSOxsKL7zXPSO8hzXPSybO0txHSaswuiLYYV7jl2Nf67bsOSaAw0SBrFwSTJjl2NaSqFpqcLfKWwxJfFXwiZUIsxaftxxHWfLVaQh(dKfqJbGCEnwanenOW67nr8PfBHScOH(ESpVaAJZgP7UUczrllV3eX38xmwFqf(qwkJLrSmIfYinwialJyHAHkv99Mi(ud99EEnYsPyXowkfl6R50Gb1zrXQALEBwwSmMLXSqawAm2VKYYyw0ilJyHmwialVRW8nVTlRXaqsny66keMLXSOLfN(TRQwaByZszSaX7Z1vOHoRba9zXEyrFnNg6790vktJX(LuwkflKdw0YYiwCRAyhdKWYWalq8(CDfAoIjOXk99MUAIilddSejlyqDwu0Cz1ZOSmMfTSmILaaOGb2stWRxgmn6WrzrllyqDwu0Cz1ZOSOLLrSaX7Z1vOjasiasWkmsJMbwggyjaakyGT0eajeajy93Xk1667PMgD4OSmmWsKSeaqW0Z3KhX9VoDKLXSmmWc1cvQ67nr8Pg6798AKfcYYiwgXIMZI9WYiw0xZPbdQZIIv1k92SSyPuSyFwgZYywkflJyHmwialVRW8nVTlRXaqsny66keMLXSmMfTSejlyqDwu0qbkVRjs4NfTSmILizjaakyGT0e86LbtJoCuwgZYWalJybdQZIIMlRuGYBwggyrFnNgmOolkwvR0BZYIfTSejlVRW8nuWsvbZ6VJ1jOr6BW01vimlJzrllJyHAHkv99Mi(ud99EEnYcbzHSnzPuSmIfYyHaS8UcZ382USgdaj1GPRRqywgZYywgZIwwgXsKSeaqW0Z3qs0(8KLHbwIKf91CAi5s4gHRySfWg2Xy(vmXM4vc0SSyzyGfmOolkAUSsbkVzzmlAzjsw0xZPPDiycw06SXSerR0lNlvDpk9X(CZYQakmsd9z9hilGwsJZgP7SOzba58AKLBYcP2QglNmWYrzPrhoQMy53XgzXBKffsPS87EYIgy59Mi(uwUKfYFLEZc5guNffzX297Saf8eknXIcPuw(DpzHSnzb87yB7OilxYINrzHCdQZIISaAwwwS8aw0alV3eXNYIoobnYIZc5VsVzHCdQZIIgw0mGC7NLgNns3zbE1xsKLskxc3imlKBSfWg2Xy(SSsfsPSCjlqbkVzHCdQZIIfFXwiZ(fLUakMUUcHlkFbup8hilGobDaRGzn9F1ybuyKg6Z6pqwaTCPilekWwybKSeGzX297G1ZsWTSUKyb0qFp2Nxa1TQHDmqclddSaX7Z1vO5iMGgR03B6QjIfFXwiJ0kkDbumDDfcxu(cOaRcOu8lG6H)azbuiEFUUclGcXvlSa6iwG4956k0eGRbqcF)bsw0YYiw0xZPH(EpDLYSSyzyGL3vy(g6JkL3v4(MVbtxxHWSmmWsaabtpFtEe3)60rwgZIwwGbVjgaY51O5VajxsKfTSmILizrFnNgkqr)lGMLflAzjsw0xZPj41ldMLflAzzelrYY7kmFZC1rRGzfvReny66keMLHbw0xZPj41ldg4v7)bswkJLaaOGb2sZC1rRGzfvRenng7xszHaSO5SmMfTSmILizHIFvhKlQ5pSTtZR2zfyzyGfmOolkAUSQwP3SmmWcguNffnuGY7AIe(zzmlAzbI3NRRqZV3NsvPisc2vB(9SOLLrSejlbaem98n5rC)RthzzyGfiEFUUcnbqcbqcwHrA0mWYWalbaqbdSLMaiHaibR)owPwxFp10ySFjLfcYczAGLXSOLL3BI4B(lgRpOcFilLXI(AonbVEzWaVA)pqYsPyztdHMLXSmmWIoGszrllZJ4(xBm2VKYcbzrFnNMGxVmyGxT)hizHaSqMDSukw6vItqtenw9fdA4ZvvVdEEHQ1sr92GPRRqywgxafI310JXcOb4AaKW3FGS6aS4l2czAOO0fqX01viCr5lG6H)azb02HGjyrRZgZseTakmsd9z9hilGwUuKfcvJzjIYIT73zHuBvJLtgkGg67X(8cO6R50e86LbtJX(LuwkJfY0alddSOVMttWRxgmWR2)dKSqawiZowkfl9kXjOjIgR(Ibn85QQ3bpVq1APOEBW01vimleKf7ihSOLfiEFUUcnb4AaKW3FGS6aS4l2czKJIsxaftxxHWfLVaQh(dKfqdOcP)5QQRoIzmMFbuyKg6Z6pqwaTCPilKARASCYalGKLamlRuHuklEcZI6sKL7zzzXIT73zHuGecGeSaAOVh7ZlGcX7Z1vOjaxdGe((dKvhGSOLLrSejlbaem98nqW83J2SmmWsKS0ReNGMiAOxoxQ6Eu6J95gmDDfcZYWal9kXjOjIgR(Ibn85QQ3bpVq1APOEBW01vimlddSOVMttWRxgmWR2)dKSuweSyh5GLXSmmWI(AonTdbtWIwNnMLiQzzXIww0xZPPDiycw06SXSernng7xszHGSqMgmAO4l2cze6IsxaftxxHWfLVaAOVh7ZlGcX7Z1vOjaxdGe((dKvhGfq9WFGSa6LbVt)pqw8fBHmnVO0fqX01viCr5lG6H)azbum2cyd7QoiHlGcJ0qFw)bYcOLlfzHCJTa2WMLYdsywajlbywSD)olqFVNUsXYYIfpHzH6qqwMGMfcXsr9MfpHzHuBvJLtgkGg67X(8cOJyjaakyGT0e86LbtJX(Luwial6R50e86Lbd8Q9)ajleGLEL4e0erJvFXGg(Cv17GNxOATuuVny66keMLsXcz2XszSeaafmWwAWylGnSR6Ge2aVA)pqYcbyHSnzzmlddSOVMttWRxgmng7xszPmw08IVylKvskkDbumDDfcxu(cOE4pqwaL(Os5DDQ8glGgIguy99Mi(0ITqwb0qFp2NxaTXzJ0DxxHSOLL)IX6dQWhYszSqMgyrlluluPQV3eXNAOV3ZRrwiilKglAzXTQHDmqclAzzel6R50e86LbtJX(LuwkJfY2KLHbwIKf91CAcE9YGzzXY4cOWin0N1FGSaAjnoBKUZYu5nYcizzzXYdyX(S8EteFkl2UFhSEwi1w1y5Kbw0XljYIRdwplpGfKWwxJS4jmlj4zbab7GBzDjXIVyl2TzrPlGIPRRq4IYxa1d)bYcOZvhTcMvuTsSakmsd9z9hilGwUuKfcfGCz5MSCj9Grw8KfYnOolkYINWSOUez5EwwwSy7(DwCwielf1BwSAqGfpHzzRWU1FqqwGAZ74cOH(ESpVakguNffnxw9mklAzzelUvnSJbsyzyGLizPxjobnr0y1xmOHpxv9o45fQwlf1BdMUUcHzzmlAzzel6R50y1xmOHpxv9o45fQwlf1BdexTqwiil2PHnzzyGf91CAcE9YGPXy)sklLXIMZYyw0YYiwGbVXHDR)GGvQnVJRWESten)fi5sISmmWsKSeaqW0Z3KyObkqdZYWaluluPQV3eXNYszSyhlJzrllJyrFnNM2HGjyrRZgZse10ySFjLfcYsjHf7HLrSqASukw6vItqten0lNlvDpk9X(CdMUUcHzzmlAzrFnNM2HGjyrRZgZse1SSyzyGLizrFnNM2HGjyrRZgZse1SSyzmlAzzelrYsaauWaBPj41ldMLflddSOVMtZV3NsvPisc2g67bsyHGSqMgyrllZJ4(xBm2VKYcbzXUn3KfTSmpI7FTXy)sklLXczBUjlddSejluWsPFjS537tPQuejbBdMUUcHzzmlAzzeluWsPFjS537tPQuejbBdMUUcHzzyGLaaOGb2stWRxgmng7xszPmwS)MSmMfTS8EteFZFXy9bv4dzPmw0alddSOdOuw0YY8iU)1gJ9lPSqqwiBZIVyl2rwrPlGIPRRq4IYxa1d)bYcO037PRufqHrAOpR)azb0YLIS4Sa99E6kfleYj(7Sy1GalRuHuklqFVNUsXYrzXvn6WrzzzXcOzjkyXI3ilUoy9S8awaqWo4wSSvkHOaAOVh7ZlGQVMtdiXFNwTWoGw)bsZYIfTSmIf91CAOV3txPmnoBKU76kKLHbwC63UQAbSHnlLXsjztwgx8fBXo7kkDbumDDfcxu(cOE4pqwaL(EpDLQakmsd9z9hilGQzwXwSSvkHGfDCcAKfsbsiasqwSD)olqFVNUsXINWS87yYc03B6QjIfqd99yFEb0aacME(M8iU)1PJSOLLiz5DfMVH(Os5DfUV5BW01vimlAzzelq8(CDfAcGecGeScJ0OzGLHbwcaGcgylnbVEzWSSyzyGf91CAcE9YGzzXYyw0YsaauWaBPjasiasW6VJvQ113tnng7xszHGSqmaBIDcZsPyjGNILrS40VDv1cydBw0ilq8(CDfAOZAaqFwgZIww0xZPH(EpDLY0ySFjLfcYcPv8fBXo7xu6cOy66keUO8fqd99yFEb0aacME(M8iU)1PJSOLLrSaX7Z1vOjasiasWkmsJMbwggyjaakyGT0e86LbZYILHbw0xZPj41ldMLflJzrllbaqbdSLMaiHaibR)owPwxFp10ySFjLfcYIgyrllq8(CDfAOV3txPQ2a5xNUsvbZjlAzbdQZIIMlREgLfTSejlq8(CDfAoIjOXk99MUAIybup8hilGsFVPRMiw8fBXosRO0fqX01viCr5lG6H)azbu67nD1eXcOWin0N1FGSaA5srwG(EtxnrKfB3VZINSqiN4VZIvdcSaAwUjlrbRTHzbab7GBXYwPecwSD)olrbRMLej8ZsWPVHLTQOawGxXwSSvkHGf)z53rwWeMfWKLFhzPKkM)E0Mf91CYYnzb6790vkwSbwk4C7NLPRuSaMtwanlrblw8gzbKSyhlV3eXNwan03J95fq1xZPbK4VtRbf6DfYrpqAwwSmmWYiwIKf6798A04w1WogiHfTSejlq8(CDfAoIjOXk99MUAIilddSmIf91CAcE9YGPXy)skleKfnWIww0xZPj41ldMLflddSmILrSOVMttWRxgmng7xszHGSqmaBIDcZsPyjGNILrS40VDv1cydBw0ilq8(CDfAO0AaqFwgZIww0xZPj41ldMLflddSOVMtt7qWeSO1zJzjIwPxoxQ6Eu6J95MgJ9lPSqqwigGnXoHzPuSeWtXYiwC63UQAbSHnlAKfiEFUUcnuAnaOplJzrll6R500oemblAD2ywIOv6LZLQUhL(yFUzzXYyw0YsaabtpFdem)9OnlJzzmlAzzeluluPQV3eXNAOV3txPyHGSyFwggybI3NRRqd99E6kv1gi)60vQkyozzmlJzrllrYceVpxxHMJycASsFVPRMiYIwwgXsKS0ReNGMiA(lgTb6Sc3OhRFjm2gmDDfcZYWaluluPQV3eXNAOV3txPyHGSyFwgx8fBXonuu6cOy66keUO8fq9WFGSaAI2QXaqwafgPH(S(dKfqlxkYIMfaKuwUKfOaL3SqUb1zrrw8eMfQdbzHqTukw0SaGKLjOzHuBvJLtgkGg67X(8cOJyrFnNgmOolkwPaL3MgJ9lPSugliHXW6X6FXilddSmILWU3erklrWIDSOLLgd7EteR)fJSqqw0alJzzyGLWU3erklrWI9zzmlAzXTQHDmqsXxSf7ihfLUakMUUcHlkFb0qFp2NxaDel6R50Gb1zrXkfO820ySFjLLYybjmgwpw)lgzzyGLrSe29MiszjcwSJfTS0yy3BIy9VyKfcYIgyzmlddSe29MiszjcwSplJzrllUvnSJbsyrllJyrFnNM2HGjyrRZgZse10ySFjLfcYIgyrll6R500oemblAD2ywIOMLflAzjsw6vItqten0lNlvDpk9X(CdMUUcHzzyGLizrFnNM2HGjyrRZgZse1SSyzCbup8hilGU7QzngaYIVyl2rOlkDbumDDfcxu(cOH(ESpVa6iw0xZPbdQZIIvkq5TPXy)sklLXcsymSES(xmYIwwgXsaauWaBPj41ldMgJ9lPSuglAytwggyjaakyGT0eajeajy93Xk1667PMgJ9lPSuglAytwgZYWalJyjS7nrKYseSyhlAzPXWU3eX6FXileKfnWYywggyjS7nrKYseSyFwgZIwwCRAyhdKWIwwgXI(AonTdbtWIwNnMLiQPXy)skleKfnWIww0xZPPDiycw06SXSernllw0YsKS0ReNGMiAOxoxQ6Eu6J95gmDDfcZYWalrYI(AonTdbtWIwNnMLiQzzXY4cOE4pqwaDUuQAmaKfFXwStZlkDbumDDfcxu(cOWin0N1FGSaA5srwiKaKllGKfsPzkG6H)azbuBE3hORGzfvRel(ITyxjPO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOuluPQV3eXNAOV3ZRrwkJfsJfcWYubanlJyj2Pp2rRqC1czPuSq2MBYIgzXUnzzmleGLPcaAwgXI(Aon03B6QjIvm2cyd7ym)kfO82qFpqclAKfsJLXfqHrAOpR)azbus5QWs5pszX2o(7yZYdyzrrwG(EpVgz5swGcuEZIT9lSZYrzXFw0alV3eXNsaYyzcAwqiyhLf72KCYsStFSJYcOzH0yb67nD1erwi3ylGnSJX8zH(EGeAbuiExtpglGsFVNxJ1lRuGY7IVyl2FZIsxaftxxHWfLVaQh(dKfqT1(VxafgPH(S(dKfqjKtwSJL3BI4tzX297G1ZcuWsXcyYYVJSqOansFwIcwSq3blfmlZtPyX297Sqi1(VZc8QVKilLtgkGg67X(8cOrYI(AonTdbtWIwNnMLiQzzXIwwIKf91CAAhcMGfToBmlr0k9Y5sv3JsFSp3SSyrllrYY7kmFdfSuvWS(7yDcAK(gmDDfcZIwwOwOsvFVjIp1qFVNxJSqqwSplAzrFnNgmOolkwPaL3MgJ9lPSugliHXW6X6FXilAzzEe3)AJX(LuwkJf91CAcE9YGPXy)skleGfYSJLsXsVsCcAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcx8fBX(Kvu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwybuYyrJSqTqLQU70hzHGSyhl2dlJyztJDSukwgXYiwOwOsvFVjIp1qFVNxJSypSqglJzrJSmILrSqTqLQ(EteFQH(EpVgzXEyHmwgZIgzXUnzHaSqglJzzmlLILrSqgleGL3vy(gkyPQGz93X6e0i9ny66keMLsXczgnWYywgZcbyztdzAGLsXI(AonTdbtWIwNnMLiQPXy)sAbuyKg6Z6pqwaLuUkSu(JuwSTJ)o2S8awiKA)3zbE1xsKfcvJzjIwafI310JXcO2A)3RxwNnMLiAXxSf7BxrPlGIPRRq4IYxa1d)bYcO2A)3lGcJ0qFw)bYcOLlfzHqQ9FNLlzbkq5nlKBqDwuKfqZYnzjbSa99EEnYITtPyzEplx(awi1w1y5Kbw8mAmOXcOH(ESpVa6iwWG6SOOrTsVRjs4NLHbwWG6SOOXZO1ej8ZIwwG4956k0C0AqHoeKLXSOLLrS8EteFZFXy9bv4dzPmwinwggybdQZIIg1k9UEz1owggyrhqPSOLL5rC)Rng7xszHGSq2MSmMLHbw0xZPbdQZIIvkq5TPXy)skleKfp8hin03751Objmgwpw)lgzrll6R50Gb1zrXkfO82SSyzyGfmOolkAUSsbkVzrllrYceVpxxHg6798ASEzLcuEZYWal6R50e86LbtJX(LuwiilE4pqAOV3ZRrdsymSES(xmYIwwIKfiEFUUcnhTguOdbzrll6R50e86LbtJX(LuwiiliHXW6X6FXilAzrFnNMGxVmywwSmmWI(AonTdbtWIwNnMLiQzzXIwwG4956k0yR9FVEzD2ywIOSmmWsKSaX7Z1vO5O1GcDiilAzrFnNMGxVmyAm2VKYszSGegdRhR)fJfFXwSV9lkDbumDDfcxu(cOWin0N1FGSaA5srwG(EpVgz5MSCjlK)k9MfYnOolkQjwUKfOaL3SqUb1zrrwajlKgby59Mi(uwanlpGfRgeybkq5nlKBqDwuSaQh(dKfqPV3ZRXIVyl2N0kkDbumDDfcxu(cOWin0N1FGSakHYvQFVxfq9WFGSaAVYQh(dKv1r)cOQJ(10JXcOtxP(9Ev8fFb0PRu)EVkkDXwiRO0fqX01viCr5lG6H)azbu67nD1eXcOWin0N1FGSak03B6QjISmbnlXaiymMplRuHukll6LezP8GTw6cOH(ESpVaAKS0ReNGMiA0DLNbScMvxPQ)(LePg0ExNLfcx8fBXUIsxaftxxHWfLVaQh(dKfqPRCEnwanenOW67nr8PfBHScOH(ESpVakm4nXaqoVgnng7xszPmwAm2VKYsPyXo7yrJSqMMxafgPH(S(dKfqjLtFw(DKfyWZIT73z53rwIb0NL)IrwEalommlR8pfl)oYsStywGxT)hiz5OSSFVHfORCEnYsJX(LuwIxQ)SuhcZYdyj2)WolXaqoVgzbE1(FGS4l2I9lkDbup8hilGgda58ASakMUUcHlkFXx8fqPFrPl2czfLUakMUUcHlkFbup8hilG6WU1FqWk1M3XfqdrdkS(EteFAXwiRaAOVh7ZlGgjlWG34WU1FqWk1M3Xvyp2jIM)cKCjrw0YsKS4H)aPXHDR)GGvQnVJRWEStenxwNQJ4(ZIwwgXsKSadEJd7w)bbRuBEhx3rxz(lqYLezzyGfyWBCy36piyLAZ746o6ktJX(LuwkJfnWYywggybg8gh2T(dcwP28oUc7Xor0qFpqcleKf7ZIwwGbVXHDR)GGvQnVJRWEStenng7xszHGSyFw0Ycm4noSB9heSsT5DCf2JDIO5VajxsSakmsd9z9hilGwUuKLTc7w)bbzbQnVJzX2oMS87yJSCuwsalE4piiluBEhRjwCklk)rwCklwak90vilGKfQnVJzX297SyhlGMLjAdBwOVhiHYcOzbKS4SyFcWc1M3XSqbS87(ZYVJSKOnwO28oMfV7dcszrZUf9zXNp2S87(Zc1M3XSGe26AKw8fBXUIsxaftxxHWfLVaQh(dKfqdGecGeS(7yLAD990cOWin0N1FGSaA5srklKcKqaKGSCtwi1w1y5Kbwoklllwanlrblw8gzbgPrZWLezHuBvJLtgyX297SqkqcbqcYINWSefSyXBKfDubSXcPTPgT)MJifQq6FUIfOwxFpDmlBLsiy5swCwiBtcWcfdSqUb1zrrdlBvrbSadYTFwu4ZIMPrpw)sySzbjS11OMyXv28OuwwuKLlzHuBvJLtgyX297SqiwkQ3S4jml(ZYVJSqFVFwatwCwkpyRLMfBxcdSzkGg67X(8cOJyzelq8(CDfAcGecGeScJ0OzGfTSejlbaqbdSLMGxVmyA0HJYIwwIKLEL4e0erJvFXGg(Cv17GNxOATuuVny66keMLHbw0xZPj41ldMLflAzzelrYsVsCcAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZYWal9kXjOjIMaQq6FUQsTU(EQbtxxHWSmmWY8iU)1gJ9lPSuglKzhHMLHbw0buklAzzEe3)AJX(LuwiilbaqbdSLMGxVmyAm2VKYcbyHSnzzyGf91CAcE9YGPXy)sklLXcz2XYywgZIwwgXYiwC63UQAbSHnlemcwG4956k0eajeajy1PwSOLLrSOVMtdguNffRQv6TPXy)sklLXczBYYWal6R50Gb1zrXkfO820ySFjLLYyHSnzzmlddSOVMttWRxgmng7xszPmw0alAzrFnNMGxVmyAm2VKYcbJGfYSJLXSOLLrSejl9kXjOjIM)IrBGoRWn6X6xcJTbtxxHWSmmWsKS0ReNGMiAcOcP)5Qk1667PgmDDfcZYWal6R508xmAd0zfUrpw)sySnng7xszPmwqcJH1J1)IrwgZYWal9kXjOjIgDx5zaRGz1vQ6VFjrQbtxxHWSmMfTSmILizPxjobnr0O7kpdyfmRUsv)9ljsny66keMLHbwgXI(Aon6UYZawbZQRu1F)sI0A6)Qrd99ajSeblAolddSOVMtJUR8mGvWS6kv93VKiT6DWt0qFpqclrWIMZYywgZYWal6akLfTSmpI7FTXy)skleKfY2KfTSejlbaqbdSLMGxVmyA0HJYY4IVyl2VO0fqX01viCr5lG6H)azbu67nD1eXcOWin0N1FGSaA5srwG(EtxnrKLhWcjiAXYYILFhzrZ0OhRFjm2SOVMtwUjl3ZInWsbZcsyRRrw0XjOrwMxE09ljYYVJSKiHFwco9zb0S8awGxXwSOJtqJSqkqcbqcwan03J95fq7vItqten)fJ2aDwHB0J1VegBdMUUcHzrllJyjswgXYiw0xZP5Vy0gOZkCJES(LWyBAm2VKYszS4H)aPXw7)Ubjmgwpw)lgzHaSSPHmw0YYiwWG6SOO5YQo43zzyGfmOolkAUSsbkVzzyGfmOolkAuR07AIe(zzmlddSOVMtZFXOnqNv4g9y9lHX20ySFjLLYyXd)bsd99EEnAqcJH1J1)IrwialBAiJfTSmIfmOolkAUSQwP3SmmWcguNffnuGY7AIe(zzyGfmOolkA8mAnrc)SmMLXSmmWsKSOVMtZFXOnqNv4g9y9lHX2SSyzmlddSmIf91CAcE9YGzzXYWalq8(CDfAcGecGeScJ0OzGLXSOLLaaOGb2staKqaKG1FhRuRRVNAA0HJYIwwcaiy65BYJ4(xNoYIwwgXI(AonyqDwuSQwP3MgJ9lPSuglKTjlddSOVMtdguNffRuGYBtJX(LuwkJfY2KLXSmMfTSmILizjaGGPNVHKO95jlddSeaafmWwAWylGnSR6Ge20ySFjLLYyrZzzCXxSfsRO0fqX01viCr5lG6H)azbu67nD1eXcOWin0N1FGSaQMzfBXc03B6QjIuwSD)olL3vEgqwatw2QsXsP3VKiLfqZYdyXQrlVrwMGMfsbsiasqwSD)olLhS1sxan03J95fq7vItqten6UYZawbZQRu1F)sIudMUUcHzrllJyzel6R50O7kpdyfmRUsv)9ljsRP)Rgn03dKWszSyhlddSOVMtJUR8mGvWS6kv93VKiT6DWt0qFpqclLXIDSmMfTSeaafmWwAcE9YGPXy)sklLXcHMfTSejlbaqbdSLMaiHaibR)owPwxFp1SSyzyGLrSeaqW0Z3KhX9VoDKfTSeaafmWwAcGecGeS(7yLAD99utJX(LuwiilKTjlAzbdQZIIMlREgLfTS40VDv1cydBwkJf72KfcWI93KLsXsaauWaBPj41ldMgD4OSmMLXfFXw0qrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfqhXI(AonTdbtWIwNnMLiQPXy)sklLXIgyzyGLizrFnNM2HGjyrRZgZse1SSyzmlAzjsw0xZPPDiycw06SXSerR0lNlvDpk9X(CZYIfTSmIf91CAi5s4gHRySfWg2Xy(vmXM4vc00ySFjLfcYcXaSj2jmlJzrllJyrFnNgmOolkwPaL3MgJ9lPSugledWMyNWSmmWI(AonyqDwuSQwP3MgJ9lPSugledWMyNWSmmWYiwIKf91CAWG6SOyvTsVnllwggyjsw0xZPbdQZIIvkq5TzzXYyw0YsKS8UcZ3qbk6Fb0GPRRqywgxafgPH(S(dKfqjfiHV)ajltqZIRuSadEkl)U)Se7KGuwORgz53XOS4nMB)S04Sr6ocZITDmzPK2HGjyrzHq1ywIOSS7uwuiLYYV7jlAGfkgOS0ySF5Lezb0S87ilKBSfWg2SuEqcZI(Aoz5OS46G1ZYdyz6kflG5KfqZINrzHCdQZIISCuwCDW6z5bSGe26ASakeVRPhJfqHbFTr7DDngJ5tl(ITqokkDbumDDfcxu(cOaRcOu8lG6H)azbuiEFUUclGcXvlSa6iwIKf91CAWG6SOyLcuEBwwSOLLizrFnNgmOolkwvR0BZYILXSOLLiz5DfMVHcu0)cObtxxHWSOLLizPxjobnr08xmAd0zfUrpw)sySny66keUakmsd9z9hilGskqcF)bsw(D)zjSJbsOSCtwIcwS4nYcy90dgzbdQZIIS8awaPkklWGNLFhBKfqZYrmbnYYVFuwSD)olqbk6FbSakeVRPhJfqHbFfSE6bJvmOolkw8fBHqxu6cOy66keUO8fq9WFGSaAmaKZRXcOHObfwFVjIpTylKvan03J95fqhXI(AonyqDwuSsbkVnng7xszPmwAm2VKYYWal6R50Gb1zrXQALEBAm2VKYszS0ySFjLLHbwG4956k0ad(ky90dgRyqDwuKLXSOLLgNns3DDfYIwwEVjIV5VyS(Gk8HSuglKzhlAzXTQHDmqclAzbI3NRRqdm4RnAVRRXymFAbuyKg6Z6pqwavZaEwCLIL3BI4tzX297xYcHWtym(cSy7(DW6zbab7GBzDjrc87ilUoacYsaKW3FGKw8fBrZlkDbumDDfcxu(cOE4pqwaLUY51yb0qFp2NxaDel6R50Gb1zrXkfO820ySFjLLYyPXy)sklddSOVMtdguNffRQv6TPXy)sklLXsJX(LuwggybI3NRRqdm4RG1tpySIb1zrrwgZIwwAC2iD31vilAz59Mi(M)IX6dQWhYszSqMDSOLf3Qg2XajSOLfiEFUUcnWGV2O9UUgJX8PfqdrdkS(EteFAXwiR4l2sjPO0fqX01viCr5lG6H)azbu6JkL31PYBSaAOVh7ZlGoIf91CAWG6SOyLcuEBAm2VKYszS0ySFjLLHbw0xZPbdQZIIv1k920ySFjLLYyPXy)sklddSaX7Z1vObg8vW6PhmwXG6SOilJzrllnoBKU76kKfTS8EteFZFXy9bv4dzPmwiJCWIwwCRAyhdKWIwwG4956k0ad(AJ276AmgZNwanenOW67nr8PfBHSIVylKTzrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfqdaiy65BGG5VhTzrllrYsVsCcAIOHE5CPQ7rPp2NBW01vimlAzjsw6vItqtenHRdkScMv1nXQNWvy0)DdMUUcHzrllbaqbdSLgDSPytYLenn6WrzrllbaqbdSLM2HGjyrRZgZse10OdhLfTSejl6R50e86LbZYIfTSmIfN(TRQwaByZszSO5eAwggyrFnNgDfaaRw03SSyzCbuyKg6Z6pqwavZaEw6J4(ZIoobnYcHQXSerz5MSCpl2alfmlUsbSXsuWILhWsJZgP7SOqkLf4vFjrwiunMLiklJ(9JYcivrzz3TSWKYIT73bRNfOxoxkw0Snk9X(8XfqH4Dn9ySaAcQ7rPp2NxrVvrRWGV4l2czKvu6cOy66keUO8fqd99yFEbuiEFUUcnjOUhL(yFEf9wfTcdEw0YsJX(Luwiil2Tzbup8hilGgda58AS4l2cz2vu6cOy66keUO8fqd99yFEbuiEFUUcnjOUhL(yFEf9wfTcdEw0YsJX(LuwiilKvskG6H)azbu6kNxJfFXwiZ(fLUakMUUcHlkFbup8hilGobDaRGzn9F1ybuyKg6Z6pqwaTCPilekWwybKSeGzX297G1ZsWTSUKyb0qFp2Nxa1TQHDmqsXxSfYiTIsxaftxxHWfLVaQh(dKfqXylGnSR6GeUakmsd9z9hilGwUuKfYn2cydBwkpiHzX297S4zuwuGKilycwe3zr50)sISqUb1zrrw8eMLVJYYdyrDjYY9SSSyX297SqiwkQ3S4jmlKARASCYqb0qFp2NxaDelbaqbdSLMGxVmyAm2VKYcbyrFnNMGxVmyGxT)hizHaS0ReNGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSukwiZowkJLaaOGb2sdgBbSHDvhKWg4v7)bswialKTjlJzzyGf91CAcE9YGPXy)sklLXIMx8fBHmnuu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwybuN(TRQwaByZszSus2Kf7HLrSyNrdSukw0xZPzU6OvWSIQvIg67bsyXEyXowkflyqDwu0CzvTsVzzCbuyKg6Z6pqwafk(uwSTJjlBLsiyHUdwkyw0rwGxXwimlpGLe8SaGGDWTyzKMbTWeMYcizHqT6OSaMSqUQvIS4jml)oYc5guNffhxafI310JXcOo1QcVITk(ITqg5OO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOJybI3NRRqtaUgaj89hizrllrYI(AonbVEzWSSyrllJyjswO4x1b5IA(dB708QDwbwggybdQZIIMlRQv6nlddSGb1zrrdfO8UMiHFwgZIwwgXYiwgXceVpxxHgNAvHxXwSmmWsaabtpFtEe3)60rwggyzelbaem98nKeTppzrllbaqbdSLgm2cyd7QoiHnn6WrzzmlddS0ReNGMiA(lgTb6Sc3OhRFjm2gmDDfcZYyw0Ycm4n0voVgnng7xszPmw0Cw0Ycm4nXaqoVgnng7xszPmwkjSOLLrSadEd9rLY76u5nAAm2VKYszSq2MSmmWsKS8UcZ3qFuP8UovEJgmDDfcZYyw0YceVpxxHMFVpLQsrKeSR287zrllV3eX38xmwFqf(qwkJf91CAcE9YGbE1(FGKLsXYMgcnlddSOVMtJUcaGvl6BwwSOLf91CA0vaaSArFtJX(Luwiil6R50e86Lbd8Q9)ajleGLrSqMDSukw6vItqtenw9fdA4ZvvVdEEHQ1sr92GPRRqywgZYywggyzelO9Uolle2GXwrB0vvqdNEgqw0YsaauWaBPbJTI2ORQGgo9mGMgJ9lPSqqwiJCqOzHaSmIfnWsPyPxjobnr0qVCUu19O0h7Zny66keMLXSmMLXSOLLrSmILizjaGGPNVjpI7FD6ilddSmIfiEFUUcnbqcbqcwHrA0mWYWalbaqbdSLMaiHaibR)owPwxFp10ySFjLfcYczAGLXSOLLrSejl9kXjOjIgDx5zaRGz1vQ6VFjrQbtxxHWSmmWIt)2vvlGnSzHGSOHnzrllbaqbdSLMaiHaibR)owPwxFp10OdhLLXSmMLHbwMhX9V2ySFjLfcYsaauWaBPjasiasW6VJvQ113tnng7xszzmlddSOdOuw0YY8iU)1gJ9lPSqqw0xZPj41ldg4v7)bswialKzhlLILEL4e0erJvFXGg(Cv17GNxOATuuVny66keMLXfqHrAOpR)azb0YLISqQTQXYjdSy7(DwifiHaib1yjLlHBeMfOwxFpLfpHzbgKB)SaGGTT(EKfcXsr9MfqZITDmzP8kaawTOpl2alfmliHTUgzrhNGgzHuBvJLtgybjS11i1WIMLtcYcD1ilpGfmFSzXzH8xP3SqUb1zrrwSTJjll6rmzP02P5SyNvGfpHzXvkwiLMHYITtPyrhdGyKLgD4OSqbGKfmblI7SaV6ljYYVJSOVMtw8eMfyWtzz3HGSOJyYcDnNx4W8vrzPXzJ0De2uafI310JXcOb4AaKW3FGSs)IVylKrOlkDbumDDfcxu(cOE4pqwaTDiycw06SXSerlGcJ0qFw)bYcOLlfzHq1ywIOSy7(Dwi1w1y5KbwwPcPuwiunMLikl2alfmlkN(SOajrSz539KfsTvnwozqtS87yYYIISOJtqJfqd99yFEbu91CAcE9YGPXy)sklLXczAGLHbw0xZPj41ldg4v7)bswiil2rOzHaS0ReNGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSukwiZow0YceVpxxHMaCnas47pqwPFXxSfY08IsxaftxxHWfLVaAOVh7ZlGcX7Z1vOjaxdGe((dKv6ZIwwgXI(AonbVEzWaVA)pqYszrWIDeAwial9kXjOjIgR(Ibn85QQ3bpVq1APOEBW01vimlLIfYSJLHbwIKLaacME(giy(7rBwgZYWal6R500oemblAD2ywIOMLflAzrFnNM2HGjyrRZgZse10ySFjLfcYsjHfcWsaKWR7nwngokwD1rmJX8n)fJviUAHSqawgXsKSOVMtJUcaGvl6BwwSOLLiz5DfMVH(ERanSbtxxHWSmUaQh(dKfqdOcP)5QQRoIzmMFXxSfYkjfLUakMUUcHlkFb0qFp2NxafI3NRRqtaUgaj89hiR0VaQh(dKfqVm4D6)bYIVyl2TzrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfqdaGcgylnbVEzW0ySFjLLYyHSnzzyGLizbI3NRRqtaKqaKGvyKgndSOLLaacME(M8iU)1PJfqHrAOpR)azb0sQEFUUczzrrywajlU(PU)qkl)U)SyZZNLhWIoYc1HGWSmbnlKARASCYalual)U)S87yuw8gZNfBo9ryw0SBrFw0XjOrw(DmUakeVRPhJfqPoeSobDn41ldfFXwSJSIsxaftxxHWfLVaQh(dKfqNRoAfmROALybuyKg6Z6pqwaTCPiLfcfGCz5MSCjlEYc5guNffzXtyw((qklpGf1Lil3ZYYIfB3VZcHyPOERjwi1w1y5KbnXc5gBbSHnlLhKWS4jmlBf2T(dcYcuBEhxan03J95fqXG6SOO5YQNrzrllJyXPF7QQfWg2Sqqwkj2XI9WI(AonZvhTcMvuTs0qFpqclLIfnWYWal6R500oemblAD2ywIOMLflJzrllJyrFnNgR(Ibn85QQ3bpVq1APOEBG4QfYcbzXosBtwggyrFnNMGxVmyAm2VKYszSO5SmMfTSaX7Z1vOH6qW6e01GxVmWIwwgXsKSeaqW0Z3KyObkqdZYWalWG34WU1FqWk1M3Xvyp2jIM)cKCjrwgZIwwgXsKSeaqW0Z3abZFpAZYWal6R500oemblAD2ywIOMgJ9lPSqqwkjSypSmIfsJLsXsVsCcAIOHE5CPQ7rPp2NBW01vimlJzrll6R500oemblAD2ywIOMLflddSejl6R500oemblAD2ywIOMLflJzrllJyjswcaiy65BijAFEYYWalbaqbdSLgm2cyd7QoiHnng7xszPmwSBtwgZIwwEVjIV5VyS(Gk8HSuglAGLHbw0buklAzzEe3)AJX(LuwiilKTzXxSf7SRO0fqX01viCr5lG6H)azbu6790vQcOWin0N1FGSaA5srwiKt83zb6790vkwSAqGYYnzb6790vkwoAU9ZYYQaAOVh7ZlGQVMtdiXFNwTWoGw)bsZYIfTSOVMtd99E6kLPXzJ0DxxHfFXwSZ(fLUakMUUcHlkFbup8hilGg8mGQQ(AolGg67X(8cO6R50qFVvGg20ySFjLfcYIgyrllJyrFnNgmOolkwPaL3MgJ9lPSuglAGLHbw0xZPbdQZIIv1k920ySFjLLYyrdSmMfTS40VDv1cydBwkJLsYMfq1xZzn9ySak99wbA4cOWin0N1FGSakP8mGkwG(ERanml3KL7zz3PSOqkLLF3tw0aLLgJ9lVKOMyjkyXI3il(ZsjztcWYwPecw8eMLFhzjS6gZNfYnOolkYYUtzrdeGYsJX(LxsS4l2IDKwrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfqdaiy65BYJ4(xNoYIww6vItqtenw9fdA4ZvvVdEEHQ1sr92GPRRqyw0YI(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKfcWIt)2vvlGnSzHaSyFwklcwS)MBYIwwG4956k0eajeajyfgPrZalAzjaakyGT0eajeajy93Xk1667PMgJ9lPSqqwC63UQAbSHnlAKf7VjlLIfIbytStyw0YcguNffnxw9mklAzXPF7QQfWg2Suglq8(CDfAcGecGeS6ulw0YsaauWaBPj41ldMgJ9lPSuglAOakmsd9z9hilGcfFkl22XKfcXsr9Mf6oyPGzrhzXQbHacZc6TkklpGfDKfxxHS8awwuKfsbsiasqwajlbaqbdSLSmICPum)ZvQOSOJbqmsz57fYYnzbEfBDjrw2kLqWscSXITtPyXvkGnwIcwS8awSWEIHxfLfmFSzHqSuuVzXtyw(DmzzrrwifiHaibhxafI310JXcOwniuTwkQ3v0Bv0IVyl2PHIsxaftxxHWfLVaQh(dKfqPV3txPkGcJ0qFw)bYcOLlfzb6790vkwSD)olqFuP8MfntFZNfqZYBNMZcPzfyXtywsalqFVvGgwtSyBhtwsalqFVNUsXYrzzzXcOz5bSy1GaleILI6nl22XKfxhabzPKSjlBLsigbAw(DKf0Bvuwielf1BwSAqGfiEFUUcz5OS89chZcOzXHT8)GGSqT5Dml7oLfnNaumqzPXy)YljYcOz5OSCjlt1rC)lGg67X(8cOJy5DfMVH(Os5DfUV5BW01vimlddSqXVQdYf18h22P5vsZkWYyw0YsKS8UcZ3qFVvGg2GPRRqyw0YI(Aon037PRuMgNns3DDfYIwwIKLEL4e0erZFXOnqNv4g9y9lHX2GPRRqyw0YYiw0xZPXQVyqdFUQ6DWZluTwkQ3giUAHSuweSyNg2KfTSejl6R50e86LbZYIfTSmIfiEFUUcno1QcVITyzyGf91CAi5s4gHRySfWg2Xy(vmXM4vc0SSyzyGfiEFUUcnwniuTwkQ3v0BvuwgZYWalJyjaGGPNVjXqduGgMfTS8UcZ3qFuP8Uc338ny66keMfTSmIfyWBCy36piyLAZ74kSh7ertJX(LuwkJfnNLHbw8WFG04WU1FqWk1M3Xvyp2jIMlRt1rC)zzmlJzzmlAzzelbaqbdSLMGxVmyAm2VKYszSq2MSmmWsaauWaBPjasiasW6VJvQ113tnng7xszPmwiBtwgx8fBXoYrrPlGIPRRq4IYxa1d)bYcO03B6QjIfqHrAOpR)azbunZk2IYYwPecw0XjOrwifiHaibzzrVKil)oYcPajeajilbqcF)bswEalHDmqcl3KfsbsiasqwoklE4xUsfLfxhSEwEal6ilbN(fqd99yFEbuiEFUUcnwniuTwkQ3v0Bv0IVyl2rOlkDbumDDfcxu(cOE4pqwanrB1yailGcJ0qFw)bYcOLlfzrZcaskl22XKLOGflEJS46G1ZYd0O3ilb3Y6sISe29MiszXtywIDsqwORgz53XOS4nYYLS4jlKBqDwuKf6FkfltqZIMTAwAKqPzvan03J95fqDRAyhdKWIwwgXsy3BIiLLiyXow0YsJHDVjI1)IrwiilAGLHbwc7EtePSebl2NLXfFXwStZlkDbumDDfcxu(cOH(ESpVaQBvd7yGew0YYiwc7EtePSebl2XIwwAmS7nrS(xmYcbzrdSmmWsy3BIiLLiyX(SmMfTSmIf91CAWG6SOyvTsVnng7xszPmwqcJH1J1)IrwggyrFnNgmOolkwPaL3MgJ9lPSugliHXW6X6FXilJlG6H)azb0DxnRXaqw8fBXUssrPlGIPRRq4IYxan03J95fqDRAyhdKWIwwgXsy3BIiLLiyXow0YsJHDVjI1)IrwiilAGLHbwc7EtePSebl2NLXSOLLrSOVMtdguNffRQv6TPXy)sklLXcsymSES(xmYYWal6R50Gb1zrXkfO820ySFjLLYybjmgwpw)lgzzCbup8hilGoxkvngaYIVyl2FZIsxaftxxHWfLVaQh(dKfqPV30vtelGcJ0qFw)bYcOLlfzb67nD1erwiKt83zXQbbklEcZc8k2ILTsjeSyBhtwi1w1y5KbnXc5gBbSHnlLhKWAILFhzPKkM)E0Mf91CYYrzX1bRNLhWY0vkwaZjlGMLOG12WSeClw2kLquan03J95fqXG6SOO5YQNrzrllJyrFnNgqI)oTguO3vih9aPzzXYWal6R50qYLWncxXylGnSJX8RyInXReOzzXYWal6R50e86LbZYIfTSmILizjaGGPNVHKO95jlddSeaafmWwAWylGnSR6Ge20ySFjLLYyrdSmmWI(AonbVEzW0ySFjLfcYcXaSj2jmlLILPcaAwgXIt)2vvlGnSzrJSaX7Z1vOHsRba9zzmlJzrllJyjswcaiy65BGG5VhTzzyGf91CAAhcMGfToBmlrutJX(LuwiiledWMyNWSukwc4PyzelJyXPF7QQfWg2SqawiTnzPuS8UcZ3mxD0kywr1krdMUUcHzzmlAKfiEFUUcnuAnaOplJzHaSyFwkflVRW8njARgdaPbtxxHWSOLLizPxjobnr0qVCUu19O0h7Zny66keMfTSOVMtt7qWeSO1zJzjIAwwSmmWI(AonTdbtWIwNnMLiALE5CPQ7rPp2NBwwSmmWYiw0xZPPDiycw06SXSernng7xszHGS4H)aPH(EpVgniHXW6X6FXilAzHAHkvD3PpYcbzztdPXYWal6R500oemblAD2ywIOMgJ9lPSqqw8WFG0yR9F3GegdRhR)fJSmmWI(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKLYIGf7iBtw0YYiwC63UQAbSHnlLXceVpxxHgkTga0NLsXIDSypSObwggyrFnNM2HGjyrRZgZse10ySFjLLYyXowgZIww0xZPPDiycw06SXSernng7xszHGSqoyzyGfiEFUUcnN9cxdGe((dKSOLLaaOGb2sZL0qVExxHv7D55VIRWiKlGMgD4OSOLf0ExNLfcBUKg6176kSAVlp)vCfgHCbKLXSOLf91CAAhcMGfToBmlruZYILHbwIKf91CAAhcMGfToBmlruZYIfTSejlbaqbdSLM2HGjyrRZgZse10OdhLLXSmmWceVpxxHgNAvHxXwSmmWIoGszrllZJ4(xBm2VKYcbzHya2e7eMLsXsapflJyXPF7QQfWg2SOrwG4956k0qP1aG(SmMLXfFXwSpzfLUakMUUcHlkFbup8hilGsFVPRMiwafgPH(S(dKfqlDhLLhWsStcYYVJSOJ0NfWKfOV3kqdZIEuwOVhi5sISCplllwS31firfLLlzXZOSqUb1zrrw0xpleILI6nlhn3(zX1bRNLhWIoYIvdcbeUaAOVh7ZlG(UcZ3qFVvGg2GPRRqyw0YsKS0ReNGMiA(lgTb6Sc3OhRFjm2gmDDfcZIwwgXI(Aon03BfOHnllwggyXPF7QQfWg2SuglLKnzzmlAzrFnNg67Tc0Wg67bsyHGSyFw0YYiw0xZPbdQZIIvkq5TzzXYWal6R50Gb1zrXQALEBwwSmMfTSOVMtJvFXGg(Cv17GNxOATuuVnqC1czHGSyhHEtw0YYiwcaGcgylnbVEzW0ySFjLLYyHSnzzyGLizbI3NRRqtaKqaKGvyKgndSOLLaacME(M8iU)1PJSmU4l2I9TRO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOyqDwu0CzvTsVzPuSO5SOrw8WFG0qFVNxJgKWyy9y9VyKfcWsKSGb1zrrZLv1k9MLsXYiwihSqawExH5BOGLQcM1FhRtqJ03GPRRqywkfl2NLXSOrw8WFG0yR9F3GegdRhR)fJSqaw20qAAGfnYc1cvQ6UtFKfcWYMgnWsPy5DfMVj9F1iTQ7kpdObtxxHWfqHrAOpR)azbuYL(xS)iLLDGnwIxHDw2kLqWI3ile9lrywSWMfkgajSHfc5ufLL3jbPS4Sqt3IUdEwMGMLFhzjS6gZNf69l)pqYcfWInWsbNB)SOJS4HWQ9hzzcAwuEteBw(lgNThJ0cOq8UMEmwa1PwecSHIHIVyl23(fLUakMUUcHlkFbup8hilGsFVPRMiwafgPH(S(dKfq1mRylwG(EtxnrKLlzXtwi3G6SOiloLfkaKS4uwSau6PRqwCklkqsKfNYsuWIfBNsXcMWSSSyX297SO5BsawSTJjly(yFjrw(DKLej8Zc5guNff1elWGC7Nff(SCplwniWcHyPOERjwGb52plaiyBRVhzXtwiKt83zXQbbw8eMflaqXIoobnYcP2QglNmWINWSqUXwaByZs5bjCb0qFp2Nxansw6vItqten)fJ2aDwHB0J1VegBdMUUcHzrllJyrFnNgR(Ibn85QQ3bpVq1APOEBG4QfYcbzXoc9MSmmWI(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKfcYIDAytw0YY7kmFd9rLY7kCFZ3GPRRqywgZIwwgXcguNffnxwPaL3SOLfN(TRQwaByZcbybI3NRRqJtTieydfdSukw0xZPbdQZIIvkq5TPXy)skleGfyWBMRoAfmROALO5Vaj0AJX(LSukwSZObwkJfnFtwggybdQZIIMlRQv6nlAzXPF7QQfWg2SqawG4956k04ulcb2qXalLIf91CAWG6SOyvTsVnng7xszHaSadEZC1rRGzfvRen)fiHwBm2VKLsXIDgnWszSus2KLXSOLLizrFnNgqI)oTAHDaT(dKMLflAzjswExH5BOV3kqdBW01vimlAzzelbaqbdSLMGxVmyAm2VKYszSqOzzyGfkyP0Ve2879PuvkIKGTbtxxHWSOLf91CA(9(uQkfrsW2qFpqcleKf7BFwShwgXsVsCcAIOHE5CPQ7rPp2NBW01vimlLIf7yzmlAzzEe3)AJX(LuwkJfY2Ctw0YY8iU)1gJ9lPSqqwSBZnzzmlAzzelrYsaabtpFdjr7ZtwggyjaakyGT0GXwaByx1bjSPXy)sklLXIDSmU4l2I9jTIsxaftxxHWfLVaQh(dKfqt0wngaYcOWin0N1FGSaA5srw0SaGKYYLS4zuwi3G6SOilEcZc1HGSOzRRMeGqTukw0SaGKLjOzHuBvJLtgyXtywkPCjCJWSqUXwaByhJ5ByzRkkGLffzzlAwS4jmleknlw8NLFhzbtywatwiunMLiklEcZcmi3(zrHplAMg9y9lHXMLPRuSaMZcOH(ESpVaQBvd7yGew0YceVpxxHgQdbRtqxdE9YalAzzel6R50Gb1zrXQALEBAm2VKYszSGegdRhR)fJSmmWI(AonyqDwuSsbkVnng7xszPmwqcJH1J1)Irwgx8fBX(AOO0fqX01viCr5lGg67X(8cOUvnSJbsyrllq8(CDfAOoeSobDn41ldSOLLrSOVMtdguNffRQv6TPXy)sklLXcsymSES(xmYYWal6R50Gb1zrXkfO820ySFjLLYybjmgwpw)lgzzmlAzzel6R50e86LbZYILHbw0xZPXQVyqdFUQ6DWZluTwkQ3giUAHSqWiyXoY2KLXSOLLrSejlbaem98nqW83J2SmmWI(AonTdbtWIwNnMLiQPXy)skleKLrSObwShwSJLsXsVsCcAIOHE5CPQ7rPp2NBW01vimlJzrll6R500oemblAD2ywIOMLflddSejl6R500oemblAD2ywIOMLflJzrllJyjsw6vItqten)fJ2aDwHB0J1VegBdMUUcHzzyGfKWyy9y9VyKfcYI(Aon)fJ2aDwHB0J1VegBtJX(Luwggyjsw0xZP5Vy0gOZkCJES(LWyBwwSmUaQh(dKfq3D1SgdazXxSf7tokkDbumDDfcxu(cOH(ESpVaQBvd7yGew0YceVpxxHgQdbRtqxdE9YalAzzel6R50Gb1zrXQALEBAm2VKYszSGegdRhR)fJSmmWI(AonyqDwuSsbkVnng7xszPmwqcJH1J1)IrwgZIwwgXI(AonbVEzWSSyzyGf91CAS6lg0WNRQEh88cvRLI6TbIRwilemcwSJSnzzmlAzzelrYsaabtpFdjr7ZtwggyrFnNgsUeUr4kgBbSHDmMFftSjELanllwgZIwwgXsKSeaqW0Z3abZFpAZYWal6R500oemblAD2ywIOMgJ9lPSqqw0alAzrFnNM2HGjyrRZgZse1SSyrllrYsVsCcAIOHE5CPQ7rPp2NBW01vimlddSejl6R500oemblAD2ywIOMLflJzrllJyjsw6vItqten)fJ2aDwHB0J1VegBdMUUcHzzyGfKWyy9y9VyKfcYI(Aon)fJ2aDwHB0J1VegBtJX(Luwggyjsw0xZP5Vy0gOZkCJES(LWyBwwSmUaQh(dKfqNlLQgdazXxSf7tOlkDbumDDfcxu(cOWin0N1FGSaA5srwiKaKllGKLaCbup8hilGAZ7(aDfmROALyXxSf7R5fLUakMUUcHlkFbup8hilGsFVNxJfqHrAOpR)azb0YLISa99EEnYYdyXQbbwGcuEZc5guNff1elKARASCYal7oLffsPS8xmYYV7jlolesT)7SGegdRhzrHZNfqZcivrzH8xP3SqUb1zrrwokllldles3VZsPTtZzXoRaly(yZIZcuGYBwi3G6SOil3KfcXsr9Mf6Fkfl7oLffsPS87EYIDKTjl03dKqzXtywi1w1y5Kbw8eMfsbsiasqw2DiilXGgz539KfYi0uwiLMHLgJ9lVKOHLYLIS46aiil2PHnjNSS70hzbE1xsKfcvJzjIYINWSyND2rozz3PpYIT73bRNfcvJzjIwan03J95fqXG6SOO5YQALEZIwwIKf91CAAhcMGfToBmlruZYILHbwWG6SOOHcuExtKWplddSmIfmOolkA8mAnrc)SmmWI(AonbVEzW0ySFjLfcYIh(dKgBT)7gKWyy9y9VyKfTSOVMttWRxgmllwgZIwwgXsKSqXVQdYf18h22P5v7ScSmmWsVsCcAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZIww0xZPXQVyqdFUQ6DWZluTwkQ3giUAHSqqwSJSnzrllbaqbdSLMGxVmyAm2VKYszSqgHMfTSmILizjaGGPNVjpI7FD6ilddSeaafmWwAcGecGeS(7yLAD99utJX(LuwkJfYi0SmMfTSmILizP9aA(gOuSmmWsaauWaBPrhBk2KCjrtJX(LuwkJfYi0SmMLXSmmWcguNffnxw9mklAzzel6R50yZ7(aDfmROALOzzXYWaluluPQ7o9rwiilBAinnWIwwgXsKSeaqW0Z3abZFpAZYWalrYI(AonTdbtWIwNnMLiQzzXYywggyjaGGPNVbcM)E0MfTSqTqLQU70hzHGSSPH0yzCXxSf7xskkDbumDDfcxu(cOWin0N1FGSaA5srwiKA)3zb87yB7Oil22VWolhLLlzbkq5nlKBqDwuutSqQTQXYjdSaAwEalwniWc5VsVzHCdQZIIfq9WFGSaQT2)9IVylK2MfLUakMUUcHlkFbuyKg6Z6pqwaLq5k1V3RcOE4pqwaTxz1d)bYQ6OFbu1r)A6Xyb0PRu)EVk(IV4lGcbB6bYITy3M2z3MK2M2VaQnVZljslGsiT1s6TuoBrZ(sMfwk9oYYfBb6NLjOzzBGfMyVnlnAVRRrywOGyKfF9Gy)rywc7EsePgEdY)sKf7kzwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3G8VezX(LmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmImcp2WBWBqiT1s6TuoBrZ(sMfwk9oYYfBb6NLjOzzByC6l1VnlnAVRRrywOGyKfF9Gy)rywc7EsePgEdY)sKfYrjZcPajeSFeMfOxmPyHgnFNWSqoz5bSq(lNf4dYrpqYcWcB)bnlJ04ywgrgHhB4ni)lrwihLmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmYocp2WBq(xISqOlzwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3G8VezrZlzwifiHG9JWSa9Ijfl0O57eMfYjlpGfYF5SaFqo6bswawy7pOzzKghZYi7i8ydVb5FjYIMxYSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVb5FjYsjPKzHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLr2NWJn8gK)LilLKsMfsbsiy)imlB)9LKGVHmdPVnlpGLT)(ssW38Kzi9TzzKDeESH3G8VezPKuYSqkqcb7hHzz7VVKe8n2zi9Tz5bSS93xsc(M3odPVnlJSJWJn8gK)LilKTzjZcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8gK)LilKrwjZcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8gK)LilKzxjZcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8gK)LilKz)sMfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4ni)lrwitdLmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmImcp2WBq(xISqg5OKzHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLr2r4XgEdY)sKfYihLmlKcKqW(ryw2(7ljbFdzgsFBwEalB)9LKGV5jZq6BZYisJWJn8gK)LilKrokzwifiHG9JWSS93xsc(g7mK(2S8aw2(7ljbFZBNH03MLrKr4XgEdY)sKfYi0LmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmYocp2WBq(xISqgHUKzHuGec2pcZY2FFjj4BiZq6BZYdyz7VVKe8npzgsFBwgrgHhB4ni)lrwiJqxYSqkqcb7hHzz7VVKe8n2zi9Tz5bSS93xsc(M3odPVnlJincp2WBWBqiT1s6TuoBrZ(sMfwk9oYYfBb6NLjOzzBRgdGyD)3MLgT311imluqmYIVEqS)imlHDpjIudVb5FjYI9lzwifiHG9JWSS93xsc(gYmK(2S8aw2(7ljbFZtMH03MLr2NWJn8gK)LilKwjZcPajeSFeMLT)(ssW3yNH03MLhWY2FFjj4BE7mK(2SmY(eESH3G8VezrZlzwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzXFwixczYNLrKr4XgEdEdcPTwsVLYzlA2xYSWsP3rwUylq)SmbnlB7aCBwA0ExxJWSqbXil(6bX(JWSe29Kisn8gK)LilKvYSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVb5FjYIDLmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmImcp2WBq(xISyxjZcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnl(Zc5sit(SmImcp2WBq(xISy)sMfsbsiy)imlB)UcZ3q6BZYdyz73vy(gs3GPRRq4TzzezeESH3G8VezX(LmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmsZj8ydVb5FjYc5OKzHuGec2pcZc0lMuSqJMVtywiNKtwEalK)YzjgaVulklalS9h0SmICoMLrKr4XgEdY)sKfYrjZcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJSJWJn8gK)Lile6sMfsbsiy)imlqVysXcnA(oHzHCsoz5bSq(lNLya8sTOSaSW2FqZYiY5ywgrgHhB4ni)lrwi0LmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmImcp2WBq(xISO5LmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmImcp2WBq(xISuskzwifiHG9JWSa9Ijfl0O57eMfYjlpGfYF5SaFqo6bswawy7pOzzKghZYi7i8ydVb5FjYcz2vYSqkqcb7hHzb6ftkwOrZ3jmlKtwEalK)Yzb(GC0dKSaSW2FqZYinoMLrKr4XgEdY)sKfYiTsMfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4ni)lrwitdLmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmImcp2WBq(xISqg5OKzHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLr2r4XgEdY)sKfY08sMfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4ni)lrwSBZsMfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgzhHhB4ni)lrwSZUsMfsbsiy)imlqVysXcnA(oHzHCYYdyH8xolWhKJEGKfGf2(dAwgPXXSmImcp2WBq(xISyhPvYSqkqcb7hHzb6ftkwOrZ3jmlKtwEalK)Yzb(GC0dKSaSW2FqZYinoMLr2r4XgEdY)sKf7iTsMfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4ni)lrwSJCuYSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVb5FjYIDe6sMfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrgHhB4ni)lrwSRKuYSqkqcb7hHzb6ftkwOrZ3jmlKtwEalK)Yzb(GC0dKSaSW2FqZYinoMLr2r4XgEdY)sKf7VzjZcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnl(Zc5sit(SmImcp2WBq(xISyFYkzwifiHG9JWSa9Ijfl0O57eMfYjlpGfYF5SaFqo6bswawy7pOzzKghZYi7t4XgEdEdcPTwsVLYzlA2xYSWsP3rwUylq)SmbnlBpDL63712S0O9UUgHzHcIrw81dI9hHzjS7jrKA4ni)lrwSRKzHuGec2pcZc0lMuSqJMVtywiNS8awi)LZc8b5OhizbyHT)GMLrACmlJiJWJn8g8gesBTKElLZw0SVKzHLsVJSCXwG(zzcAw2M(BZsJ276AeMfkigzXxpi2FeMLWUNerQH3G8VezXUsMfsbsiy)imlB3ReNGMiAi9Tz5bSSDVsCcAIOH0ny66keEBwgrOj8ydVb5FjYI9lzwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3G8VezH0kzwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3G8VezHCuYSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZI)SqUeYKplJiJWJn8gK)LilKTzjZcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJSJWJn8gK)LilKrALmlKcKqW(ryw2Uxjobnr0q6BZYdyz7EL4e0erdPBW01vi82SmImcp2WBq(xISqg5OKzHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLrAGWJn8gK)LilKrOlzwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3G8VezHmnVKzHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLrKr4XgEdY)sKf7iRKzHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLrKr4XgEdY)sKf7iTsMfsbsiy)imlqVysXcnA(oHzHCYYdyH8xolWhKJEGKfGf2(dAwgPXXSmImcp2WBq(xISyhPvYSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVb5FjYIDAOKzHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLrKr4XgEdY)sKf7VzjZcPajeSFeMfOxmPyHgnFNWSqoz5bSq(lNf4dYrpqYcWcB)bnlJ04ywgzFcp2WBq(xISy)nlzwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzezeESH3G8VezX(KvYSqkqcb7hHzz7EL4e0erdPVnlpGLT7vItqtenKUbtxxHWBZYiYi8ydVb5FjYI9TRKzHuGec2pcZc0lMuSqJMVtywiNS8awi)LZc8b5OhizbyHT)GMLrACmlJSpHhB4ni)lrwSV9lzwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzKDeESH3G8VezX(AOKzHuGec2pcZY29kXjOjIgsFBwEalB3ReNGMiAiDdMUUcH3MLr2r4XgEdY)sKf7tokzwifiHG9JWSSDVsCcAIOH03MLhWY29kXjOjIgs3GPRRq4TzzKDeESH3G8VezX(AEjZcPajeSFeMLT7vItqtenK(2S8aw2Uxjobnr0q6gmDDfcVnlJiJWJn8g8gLtSfOFeMfYblE4pqYI6Op1WBuaLAHHITq2M2va1QbZtHfqjpYJLY7kpdilAMEDW8gKh5XYwT6tXIg0el2TPD2XBWBqEKhlKA3tIiTK5nipYJf7HLTcdJWSafO8MLYJESH3G8ipwShwi1UNerywEVjIF9MSeCksz5bSeIguy99Mi(udVb5rESypSusJXaiimlRmXasPEhLfiEFUUcPSm6mOrtSy1iKk99MUAIil2tzSy1ied99MUAI4ydVb5rESypSSviGdMfRgdo9VKilesT)7SCtwUFBkl)oYITgKezHCdQZIIgEdYJ8yXEyrZYjbzHuGecGeKLFhzbQ113tzXzrD)RqwIbnYYuHe(0vilJUjlrblw2D4C7NL97z5EwOx8s9EIGfvfLfB3VZs5jK3APzHaSqkuH0)CflBvDeZymFnXY9BdZcLKZASH3G8ipwShw0SCsqwIb0NLTNhX9V2ySFjDBwObm9(auwCllvuwEal6akLL5rC)PSasvudVb5rESypSu6g9NLsdIrwatwkVY3zP8kFNLYR8DwCklolulmCUILVVKe8n8gKh5XI9WcHSfMyZYOZGgnXcHu7)UMyHqQ9FxtSa99EEnoMLyhgzjg0ilnsp1H5ZYdyb9wDyZsaeR7V9qFVFdVb5rESypSqOocZsjLlHBeMfYn2cyd7ymFwc7yGewMGMfsPzyzrDIOH3G8ipwShwkPXyaeKf4EDWMeudWuwc7yGeQH3G3G8ipw2AMG3FeMLY7kpdilBLqq(Se8KfDKLjyLWS4pl7)BrlznQrDx5zaTh6fhmeVFFPBoGglVR8mG2d0lMuAmg2S)XknBopfgHUR8mGMNWpVbVHh(dKuJvJbqSU)rqYLWncxPwxFpL3G8yP07ilq8(CDfYYrzHIplpGLnzX297SKawOV)SaswwuKLVVKe8PAIfYyX2oMS87ilZRPplGez5OSaswwuutSyhl3KLFhzHIbqcZYrzXtywSpl3KfDWVZI3iVHh(dKuJvJbqSU)eicncX7Z1vOMspgJaK1ffRFFjj4RjiUAHrSjVHh(dKuJvJbqSU)eicncX7Z1vOMspgJaK1ffRFFjj4RjGveomSMG4QfgbzA6Mr89LKGVHmZUtRlkw1xZP2VVKe8nKzcaGcgylnWR2)dKAJ87ljbFdzMJAEqmwbZAmiPFdw0AaK0VxH)ajL3Wd)bsQXQXaiw3FceHgH4956kutPhJraY6II1VVKe81eWkchgwtqC1cJWonDZi((ssW3yNz3P1ffR6R5u73xsc(g7mbaqbdSLg4v7)bsTr(9LKGVXoZrnpigRGzngK0VblAnas63RWFGKYBqESu6DKIS89LKGpLfVrwsWZIVEqS)xWvQOSaJpgEeMfNYcizzrrwOV)S89LKGp1WclqXNfiEFUUcz5bSqAS4uw(DmklUIcyjreMfQfgoxXYUNWQljA4n8WFGKASAmaI19NarOriEFUUc1u6XyeGSUOy97ljbFnbSIWHH1eexTWiinnDZiq7DDwwiS5sAOxVRRWQ9U88xXvyeYfWHb0ExNLfcBWyROn6QkOHtpd4WaAVRZYcHnuWsPW)VKyTx6r5nipwGIpLLFhzb67nD1erwca6ZYe0SO8hBwcUkSu(FGKYYOjOzbjShBPqwSTJjlpGf679Zc8k26sISOJtqJSqOAmlruwMUsrzbmNJ5n8WFGKASAmaI19NarOriEFUUc1u6XyeuAnaOVMG4QfgH93SuJiZE20qMgkff)QoixuZFyBNMxjnRWyEdp8hiPgRgdGyD)jqeAeI3NRRqnLEmgbDwda6RjiUAHrOHnl1iYSNnnKPHsrXVQdYf18h22P5vsZkmM3G8ybk(uw8NfB7xyNfpgSYNfWKLTsjeSqkqcbqcYcDhSuWSOJSSOiCjZcPTjl2UFhSEwifQq6FUIfOwxFpLfpHzX(BYIT73n8gE4pqsnwngaX6(tGi0ieVpxxHAk9ymIaiHaibRo1stqC1cJW(BsaY2Su9kXjOjIMaQq6FUQsTU(EkVHh(dKuJvJbqSU)eicngdajjxwNGoM3Wd)bsQXQXaiw3FceHgT1(VRj1LynahbzBQPBgXimOolkAuR07AIe(hgWG6SOO5YkfO8EyadQZIIMlR6GFFyadQZIIgpJwtKW)yEdEdYJfcrJbN(SyhlesT)7S4jmlolqFVPRMiYcizbAPzX297SSLJ4(ZcHYrw8eMLYd2APzb0Sa99EEnYc43X22rrEdp8hiPgGfMytGi0OT2)DnDZigHb1zrrJALExtKW)WaguNffnxwPaL3ddyqDwu0Czvh87ddyqDwu04z0AIe(hR1QrigYm2A)31gPvJqm2zS1(VZB4H)aj1aSWeBceHgPV3ZRrnPUeRb4i0GMUzeJgfzVsCcAIOr3vEgWkywDLQ(7xsKomezaabtpFtEe3)60XHHiPwOsvFVjIp1qFVNUsfbzddr(UcZ3K(VAKw1DLNb0GPRRq4XddJWG6SOOHcuExtKW)WaguNffnxwvR07HbmOolkAUSQd(9HbmOolkA8mAnrc)JhRnsk(vDqUOM)W2onVANvG3Wd)bsQbyHj2eicnsFVPRMiQj1LynahHg00nJyuVsCcAIOr3vEgWkywDLQ(7xsKQnaGGPNVjpI7FD6OwQfQu13BI4tn037PRurq2yTrsXVQdYf18h22P5v7Sc8g8gKh5Xc5symSEeMfec2rz5VyKLFhzXdpOz5OS4q8t56k0WB4H)ajnckq5Dvh9yEdp8hiPeicngCLQ6H)azvD0xtPhJraSWeBnr)(cFeKPPBgXFXibhzxP8WFG0yR9F3eC6x)lgjGh(dKg6798A0eC6x)lghZBqESafFklBfqUSaswSpbyX297G1ZcCFZNfpHzX297Sa99wbAyw8eMf7ialGFhBBhf5n8WFGKsGi0ieVpxxHAk9ymIJwDaQjiUAHrqTqLQ(EteFQH(EpDLQmY0okY3vy(g67Tc0WgmDDfcpm8UcZ3qFuP8Uc338ny66keE8Wa1cvQ67nr8Pg6790vQYSJ3G8ybk(uwck0HGSyBhtwG(EpVgzj4jl73ZIDeGL3BI4tzX2(f2z5OS0OcH45ZYe0S87ilKBqDwuKLhWIoYIvJtSBeMfpHzX2(f2zzEkf2S8awco95n8WFGKsGi0ieVpxxHAk9ymIJwdk0HGAcIRwyeuluPQV3eXNAOV3ZRXYiJ3G8yPKQ3NRRqw(D)zjSJbsOSCtwIcwS4nYYLS4SqmaZYdyXHaoyw(DKf69l)pqYITDSrwCw((ssWNf8dSCuwwueMLlzrhFBiMSeC6t5n8WFGKsGi0ieVpxxHAk9ymIlRedWAcIRwyewncPsmaBiZeda58ACyWQrivIbydzg6kNxJddwncPsmaBiZqFVPRMiomy1iKkXaSHmd99E6k1WGvJqQedWgYmZvhTcMvuTsCyWQriM2HGjyrRZgZseDyqFnNMGxVmyAm2VKgH(AonbVEzWaVA)pqomaX7Z1vO5OvhG8gKhlLlfzP8ytXMKljYI)S87ilycZcyYcHQXSerzX2oMSS70hz5OS46aiilKJnjNAIfF(yZcPajeajil2UFNLYd8sZINWSa(DSTDuKfB3VZcP2QglNmWB4H)ajLarOrDSPytYLe10nJy0Oidaiy65BYJ4(xNoomezaauWaBPjasiasW6VJvQ113tnlRHHi7vItqten6UYZawbZQRu1F)sI0XA1xZPj41ldMgJ9lPLrMg0QVMtt7qWeSO1zJzjIAAm2VKsqstBKbaem98nqW83J2ddbaem98nqW83J2A1xZPj41ldMLLw91CAAhcMGfToBmlruZYs7i91CAAhcMGfToBmlrutJX(Lucgbz2zpKwP6vItqten0lNlvDpk9X(8Hb91CAcE9YGPXy)skbjJSHbYiNuluPQ7o9rcsMHCmESwiEFUUcnxwjgG5nipwieGNfB3VZIZcP2QglNmWYV7plhn3(zXzHqSuuVzXQbbwanl22XKLFhzzEe3FwoklUoy9S8awWeM3Wd)bskbIqJwG)aPMUzeJ0xZPj41ldMgJ9lPLrMg0okYEL4e0erd9Y5sv3JsFSpFyqFnNM2HGjyrRZgZse10ySFjLGKvs0QVMtt7qWeSO1zJzjIAwwJhg0buQ25rC)Rng7xsjODAySwiEFUUcnxwjgG5nipwiLRclL)iLfB74VJnll6LezHuGecGeKLeyJfBNsXIRuaBSefSy5bSq)tPyj40NLFhzH6XilEmyLplGjlKcKqaKGeGuBvJLtgyj40NYB4H)ajLarOriEFUUc1u6XyebqcbqcwHrA0mOjiUAHreWtnA08iU)1gJ9lP2dzAWEcaGcgylnbVEzW0ySFjDm5KmnFZXLfWtnA08iU)1gJ9lP2dzAWEcaGcgylnbqcbqcw)DSsTU(EQPXy)s6yYjzA(MJ1gz7hCfHG5BCyyQbj8rFQ2rrgaafmWwAcE9YGPrho6WqKbaqbdSLMaiHaibR)owPwxFp10OdhD8WqaauWaBPj41ldMgJ9lPLD5JTfq5pcxNhX9V2ySFjDyOxjobnr0eqfs)ZvvQ113t1gaafmWwAcE9YGPXy)sAz2FZHHaaOGb2staKqaKG1FhRuRRVNAAm2VKw2Lp2waL)iCDEe3)AJX(Lu7HSnhgImaGGPNVjpI7FD6iVb5Xs5srywEalWOYJYYVJSSOorKfWKfsTvnwozGfB7yYYIEjrwGblDfYcizzrrw8eMfRgHG5ZYI6erwSTJjlEYIddZccbZNLJYIRdwplpGf4d5n8WFGKsGi0ieVpxxHAk9ymIaCnas47pqQjiUAHrm69Mi(M)IX6dQWhwgzAyyO9dUIqW8nomm1CzzAyZXAhncT31zzHWgm2kAJUQcA40ZaQDuKbaem98nqW83J2ddbaqbdSLgm2kAJUQcA40ZaAAm2VKsqYiheAcmsdLQxjobnr0qVCUu19O0h7ZhpwBKbaqbdSLgm2kAJUQcA40ZaAA0HJoEyaT31zzHWgkyPu4)xsS2l9OAhfzaabtpFtEe3)60XHHaaOGb2sdfSuk8)ljw7LE0Q9jnnO5BsMPXy)skbjJmsB8WWOaaOGb2sJo2uSj5sIMgD4Oddr2EanFduQHHaacME(M8iU)1PJJ1okY3vy(M5QJwbZkQwjAW01vi8WqaabtpFdem)9OT2aaOGb2sZC1rRGzfvRenng7xsjizKranuQEL4e0erd9Y5sv3JsFSpFyiYaacME(giy(7rBTbaqbdSLM5QJwbZkQwjAAm2VKsq91CAcE9YGbE1(FGKaKzxP6vItqtenw9fdA4ZvvVdEEHQ1sr92EiZUXAhH276SSqyZL0qVExxHv7D55VIRWiKlGAdaGcgylnxsd96DDfwT3LN)kUcJqUaAAm2VKsqnmEyy0i0ExNLfcBO7omWgcxbTEfmRpOJX81gaafmWwAEqhJ5JW1lPhX9VAFnOb7BhzMgJ9lPJhggncI3NRRqdiRlkw)(ssWpcYggG4956k0aY6II1VVKe8JW(J1o67ljbFdzMgD4O1aaOGb2YHHVVKe8nKzcaGcgylnng7xsl7YhBlGYFeUopI7FTXy)sQ9q2MJhgG4956k0aY6II1VVKe8JWoTJ((ssW3yNPrhoAnaakyGTCy47ljbFJDMaaOGb2stJX(L0YU8X2cO8hHRZJ4(xBm2VKApKT54HbiEFUUcnGSUOy97ljb)i2C84X8gKhlLu9(CDfYYIIWS8awGrLhLfpJYY3xsc(uw8eMLamLfB7yYIn)(ljYYe0S4jlK7YAh0NZIvdc8gE4pqsjqeAeI3NRRqnLEmgXV3NsvPisc2vB(9AcIRwyersblL(LWMFVpLQsrKeSny66keEyyEe3)AJX(L0YSBZnhg0buQ25rC)Rng7xsjODAGaJiTnTh91CA(9(uQkfrsW2qFpqsPSB8WG(Aon)EFkvLIijyBOVhiPm7R52ZOEL4e0erd9Y5sv3JsFSpVu2nM3G8yPCPilKBSv0gDfleYnC6zazXUnPyGYIoobnYIZcP2QglNmWYIISaAwOaw(D)z5EwSDkflQlrwwwSy7(Dw(DKfmHzbmzHq1ywIO8gE4pqsjqeACrX69ySMspgJaJTI2ORQGgo9mGA6MreaafmWwAcE9YGPXy)skbTBtTbaqbdSLMaiHaibR)owPwxFp10ySFjLG2TP2rq8(CDfA(9(uQkfrsWUAZVFyqFnNMFVpLQsrKeSn03dKuM93KaJ6vItqten0lNlvDpk9X(8sz)XJ1cX7Z1vO5YkXa8WGoGs1opI7FTXy)skbTpHM3G8yPCPilqblLc)ljYsj9spklKdkgOSOJtqJS4SqQTQXYjdSSOilGMfkGLF3FwUNfBNsXI6sKLLfl2UFNLFhzbtywatwiunMLikVHh(dKuceHgxuSEpgRP0JXiOGLsH)FjXAV0JQPBgXOaaOGb2stWRxgmng7xsji5qBKbaem98nqW83J2AJmaGGPNVjpI7FD64WqaabtpFtEe3)60rTbaqbdSLMaiHaibR)owPwxFp10ySFjLGKdTJG4956k0eajeajyfgPrZWWqaauWaBPj41ldMgJ9lPeKCmEyiaGGPNVbcM)E0w7Oi7vItqten0lNlvDpk9X(CTbaqbdSLMGxVmyAm2VKsqYXWG(AonTdbtWIwNnMLiQPXy)skbjBtcmsdLcT31zzHWMlPFVcpOPv4dYLyvhvQXA1xZPPDiycw06SXSernlRXdd6akv78iU)1gJ9lPe0onmmG276SSqydgBfTrxvbnC6za1gaafmWwAWyROn6QkOHtpdOPXy)sAz2T5yTq8(CDfAUSsmaRns0ExNLfcBUKg6176kSAVlp)vCfgHCbCyiaakyGT0Cjn0R31vy1ExE(R4kmc5cOPXy)sAz2T5WGoGs1opI7FTXy)skbTBtEdYJLTQS5rPSSOilLJMn0mSy7(Dwi1w1y5Kbwanl(ZYVJSGjmlGjleQgZseL3Wd)bskbIqJq8(CDfQP0JXio7fUgaj89hi1eexTWi0xZPj41ldMgJ9lPLrMg0okYEL4e0erd9Y5sv3JsFSpFyqFnNM2HGjyrRZgZse10ySFjLGrqMgmAGaJSVrdLsFnNgDfaaRw03SSgtGrKMrd2J9nAOu6R50ORaay1I(ML14sH276SSqyZL0VxHh00k8b5sSQJkfbinJgk1i0ExNLfcB(DSoVM(v6r8uAdaGcgyln)owNxt)k9iEktJX(LucgHDBowR(AonTdbtWIwNnMLiQzznEyqhqPANhX9V2ySFjLG2PHHb0ExNLfcBWyROn6QkOHtpdO2aaOGb2sdgBfTrxvbnC6zanng7xs5n8WFGKsGi04II17XynLEmgXL0qVExxHv7D55VIRWiKlGA6MraX7Z1vO5Sx4AaKW3FGuleVpxxHMlRedW8gKhlLlfzb6UddSHWSqi36SOJtqJSqQTQXYjd8gE4pqsjqeACrX69ySMspgJGU7WaBiCf06vWS(GogZxt3mIrbaqbdSLMGxVmyA0HJQnYaacME(M8iU)1PJAH4956k0879PuvkIKGD1MFV2rbaqbdSLgDSPytYLenn6WrhgIS9aA(gOuJhgcaiy65BYJ4(xNoQnaakyGT0eajeajy93Xk1667PMgD4OAhbX7Z1vOjasiasWkmsJMHHHaaOGb2stWRxgmn6Wrhpwlm4n0voVgn)fi5sIAhbdEd9rLY76u5nA(lqYLehgI8DfMVH(Os5DDQ8gny66keEyGAHkv99Mi(ud99EEnwM9hRfg8MyaiNxJM)cKCjrTJG4956k0C0QdWHHEL4e0erJUR8mGvWS6kv93VKiDyWPF7QQfWg2LfrjzZHbiEFUUcnbqcbqcwHrA0mmmOVMtJUcaGvl6BwwJ1gjAVRZYcHnxsd96DDfwT3LN)kUcJqUaomG276SSqyZL0qVExxHv7D55VIRWiKlGAdaGcgylnxsd96DDfwT3LN)kUcJqUaAAm2VKwM93uBK6R50e86LbZYAyqhqPANhX9V2ySFjLGK2M8gKhlLE)OSCuwCwA)3XMfu56G2FKfBEuwEalXojilUsXcizzrrwOV)S89LKGpLLhWIoYI6seMLLfl2UFNfsTvnwozGfpHzHuGecGeKfpHzzrrw(DKf7sywOkWZcizjaZYnzrh87S89LKGpLfVrwajllkYc99NLVVKe8P8gE4pqsjqeACrX69ymvtuf4Pr89LKGpzA6MraX7Z1vObK1ffRFFjj4hzeKPnYVVKe8n2zA0HJwdaGcgylhggbX7Z1vObK1ffRFFjj4hbzddq8(CDfAazDrX63xsc(ry)XAhPVMttWRxgmllTbaem98nqW83J2AhPVMtt7qWeSO1zJzjIAAm2VKsGr23OHs1ReNGMiAOxoxQ6Eu6J95JjyeFFjj4BiZOVMZk8Q9)aPw91CAAhcMGfToBmlruZYAyqFnNM2HGjyrRZgZseTsVCUu19O0h7ZnlRXddbaqbdSLMGxVmyAm2VKsa7k77ljbFdzMaaOGb2sd8Q9)aP2rr2ReNGMiAS6lg0WNRQEh88cvRLI69WG(AonbVEzW0ySFjTmYXyTJImaGGPNVjpI7FD64WW3xsc(gYmbaqbdSLg4v7)bYYcaGcgylnbqcbqcw)DSsTU(EQPXy)s6WaeVpxxHMaiHaibRWinAg0(9LKGVHmtaauWaBPbE1(FGSSaaOGb2stWRxgmng7xshRnYaacME(gsI2NNddbaem98n5rC)Rth1cX7Z1vOjasiasWkmsJMbTbaqbdSLMaiHaibR)owPwxFp1SS0gzaauWaBPj41ldMLL2rJ0xZPbdQZIIv1k920ySFjTmnmmOVMtdguNffRuGYBtJX(L0Y0W4Xdd6R50qYLWncxXylGnSJX8RyInXReOzznEyyEe3)AJX(LucA3Mddq8(CDfAazDrX63xsc(rSjVHh(dKuceHgxuSEpgt1evbEAeFFjj4BNMUzeq8(CDfAazDrX63xsc(rgHDAJ87ljbFdzMgD4O1aaOGb2YHbiEFUUcnGSUOy97ljb)iSt7i91CAcE9YGzzPnaGGPNVbcM)E0w7i91CAAhcMGfToBmlrutJX(LucmY(gnuQEL4e0erd9Y5sv3JsFSpFmbJ47ljbFJDg91CwHxT)hi1QVMtt7qWeSO1zJzjIAwwdd6R500oemblAD2ywIOv6LZLQUhL(yFUzznEyiaakyGT0e86LbtJX(LucyxzFFjj4BSZeaafmWwAGxT)hi1okYEL4e0erJvFXGg(Cv17GNxOATuuVhg0xZPj41ldMgJ9lPLrogRDuKbaem98n5rC)Rthhg((ssW3yNjaakyGT0aVA)pqwwaauWaBPjasiasW6VJvQ113tnng7xshgG4956k0eajeajyfgPrZG2VVKe8n2zcaGcgylnWR2)dKLfaafmWwAcE9YGPXy)s6yTrgaqW0Z3qs0(8u7Oi1xZPj41ldML1WqKbaem98nqW83J2Jhgcaiy65BYJ4(xNoQfI3NRRqtaKqaKGvyKgndAdaGcgylnbqcbqcw)DSsTU(EQzzPnYaaOGb2stWRxgmllTJgPVMtdguNffRQv6TPXy)sAzAyyqFnNgmOolkwPaL3MgJ9lPLPHXJhpmOVMtdjxc3iCfJTa2WogZVIj2eVsGML1WW8iU)1gJ9lPe0UnhgG4956k0aY6II1VVKe8JytEdYJLYLIuwCLIfWVJnlGKLffz5EmMYcizjaZB4H)ajLarOXffR3JXuEdYJfY9(DSzHiGLlFal)oYc9zb0S4aKfp8hizrD0N3Wd)bskbIqJ9kRE4pqwvh91u6Xyeoa1e97l8rqMMUzeq8(CDfAoA1biVHh(dKuceHg7vw9WFGSQo6RP0JXiOpVbVb5XcPCvyP8hPSyBh)DSz53rw0mn6Xb)d7yZI(AozX2PuSmDLIfWCYIT73VKLFhzjrc)SeC6ZB4H)aj14amciEFUUc1u6XyeWn6XvBNsvNUsvbZPMG4QfgrVsCcAIO5Vy0gOZkCJES(LWyRDK(Aon)fJ2aDwHB0J1VegBtJX(LucsmaBIDctGnnKnmOVMtZFXOnqNv4g9y9lHX20ySFjLGE4pqAOV3ZRrdsymSES(xmsGnnKPDeguNffnxwvR07HbmOolkAOaL31ej8pmGb1zrrJNrRjs4F8yT6R508xmAd0zfUrpw)sySnllEdYJfs5QWs5pszX2o(7yZc03B6QjISCuwSb6FNLGt)ljYcac2Sa99EEnYYLSq(R0Bwi3G6SOiVHh(dKuJdqceHgH4956kutPhJrCetqJv67nD1ernbXvlmIiXG6SOO5YkfO8wl1cvQ67nr8Pg6798ASmcT98UcZ3qblvfmR)owNGgPVbtxxHWLYocGb1zrrZLvDWVRnYEL4e0erJvFXGg(Cv17GNxOATuuV1gzVsCcAIObK4VtRbf6DfYrpqYBqESuUuKfsbsiasqwSTJjl(ZIcPuw(DpzrdBYYwPecw8eMf1LilllwSD)olKARASCYaVHh(dKuJdqceHgdGecGeS(7yLAD99unDZigncI3NRRqtaKqaKGvyKgndAJmaakyGT0e86LbtJoCuTr2ReNGMiAS6lg0WNRQEh88cvRLI69WG(AonbVEzWSS0okYEL4e0erJvFXGg(Cv17GNxOATuuVhg6vItqtenbuH0)CvLAD990HH5rC)Rng7xslJm7i0dd6akv78iU)1gJ9lPemaakyGT0e86LbtJX(Lucq2Mdd6R50e86LbtJX(L0YiZUXJ1oA0iN(TRQwaBytWiG4956k0eajeajy1PwdduluPQV3eXNAOV3ZRXYS)yTJ0xZPbdQZIIv1k920ySFjTmY2CyqFnNgmOolkwPaL3MgJ9lPLr2MJhg0xZPj41ldMgJ9lPLPbT6R50e86LbtJX(Lucgbz2nw7OiFxH5BOpQuExH7B(dd6R50qFVNUszAm2VKsqYmAWE20OHs1ReNGMiAcOcP)5Qk1667Pdd6R50e86LbtJX(LucQVMtd99E6kLPXy)skb0Gw91CAcE9YGzznw7Oi7vItqten)fJ2aDwHB0J1Veg7HHi7vItqtenbuH0)CvLAD990Hb91CA(lgTb6Sc3OhRFjm2MgJ9lPLHegdRhR)fJJhg6vItqten6UYZawbZQRu1F)sI0XAhfzVsCcAIOr3vEgWkywDLQ(7xsKommsFnNgDx5zaRGz1vQ6VFjrAn9F1OH(EGKi08Hb91CA0DLNbScMvxPQ)(LePvVdEIg67bsIqZhpEyqhqPANhX9V2ySFjLGKTP2idaGcgylnbVEzW0OdhDmVb5Xs5srwGUY51ilxYILNWy8fybKS4z0F)sIS87(ZI6GGuwiJ0OyGYINWSOqkLfB3VZsmOrwEVjIpLfpHzXFw(DKfmHzbmzXzbkq5nlKBqDwuKf)zHmsJfkgOSaAwuiLYsJX(LxsKfNYYdyjbpl7oKljYYdyPXzJ0DwGx9LezH8xP3SqUb1zrrEdp8hiPghGeicnsx58AutHObfwFVjIpncY00nJyuJZgP7UUchg0xZPbdQZIIvkq5TPXy)skbTVwmOolkAUSsbkV12ySFjLGKrAAFxH5BOGLQcM1FhRtqJ03GPRRq4XAFVjIV5VyS(Gk8HLrgPzpuluPQV3eXNsGgJ9lPAhHb1zrrZLvpJom0ySFjLGedWMyNWJ5nipwkxkYc0voVgz5bSS7qqwCwiQa6UILhWYIISuoA2qZWB4H)aj14aKarOr6kNxJA6MraX7Z1vO5Sx4AaKW3FGuBaauWaBP5sAOxVRRWQ9U88xXvyeYfqtJoCuTO9Uolle2Cjn0R31vy1ExE(R4kmc5cOw3Qg2Xaj8gKhlLuq0ILLflqFVNUsXI)S4kfl)fJuwwPcPuww0ljYc5hn4TtzXtywUNLJYIRdwplpGfRgeyb0SOWNLFhzHAHHZvS4H)ajlQlrw0rfWgl7EcRqw0mn6X6xcJnlGKf7y59Mi(uEdp8hiPghGeicnsFVNUsPPBgrKVRW8n0hvkVRW9nFdMUUcH1oksk(vDqUOM)W2onVsAwHHbmOolkAUS6z0HbQfQu13BI4tn037PRuLz)XAhPVMtd99E6kLPXzJ0DxxHAhrTqLQ(EteFQH(EpDLIG2FyiYEL4e0erZFXOnqNv4g9y9lHXE8WW7kmFdfSuvWS(7yDcAK(gmDDfcRvFnNgmOolkwPaL3MgJ9lPe0(AXG6SOO5YkfO8wR(Aon037PRuMgJ9lPeKqRLAHkv99Mi(ud99E6kvzrqAJ1okYEL4e0erJkAWBNwNke)ljwjQUylkom8xmsojNKMgktFnNg6790vktJX(Lucy3yTV3eX38xmwFqf(WY0aVb5XcH097Sa9rLYBw0m9nFwwuKfqYsaMfB7yYsJZgP7UUczrF9Sq)tPyXMFpltqZc5hn4TtzXQbbw8eMfyqU9ZYIISOJtqJSqknd1Wc0)ukwwuKfDCcAKfsbsiasqwOxgqw(D)zX2PuSy1GalEc(DSzb6790vkEdp8hiPghGeicnsFVNUsPPBgX7kmFd9rLY7kCFZ3GPRRqyT6R50qFVNUszAC2iD31vO2rrsXVQdYf18h22P5vsZkmmGb1zrrZLvpJomqTqLQ(EteFQH(EpDLQm7pw7Oi7vItqtenQObVDADQq8VKyLO6ITO4WWFXi5KCsAAOmsBS25rC)Rng7xslZ(8gKhles3VZIMPrpw)sySzzrrwG(EpDLILhWcjiAXYYILFhzrFnNSOhLfxrbSSOxsKfOV3txPybKSObwOyaKWuwanlkKszPXy)YljYB4H)aj14aKarOr6790vknDZi6vItqten)fJ2aDwHB0J1VegBTuluPQV3eXNAOV3txPklc7RDuK6R508xmAd0zfUrpw)sySnllT6R50qFVNUszAC2iD31v4WWiiEFUUcnWn6XvBNsvNUsvbZP2r6R50qFVNUszAm2VKsq7pmqTqLQ(EteFQH(EpDLQm70(UcZ3qFuP8Uc338ny66kewR(Aon037PRuMgJ9lPeudJhpM3G8yHuUkSu(JuwSTJ)o2S4Sa99MUAIillkYITtPyj4lkYc037PRuS8awMUsXcyo1elEcZYIISa99MUAIilpGfsq0IfntJES(LWyZc99ajSSSmSO5BYYrz53rwA0ExxJWSSvkHGLhWsWPplqFVPRMisaOV3txP4n8WFGKACasGi0ieVpxxHAk9ymc6790vQQnq(1PRuvWCQjiUAHr40VDv1cyd7Y08nl1iYShk(vDqUOM)W2onVANvOuBASBCPgrM9OVMtZFXOnqNv4g9y9lHX2qFpqsP20q2y7zK(Aon037PRuMgJ9lPLY(KtQfQu1DN(yPI8DfMVH(Os5DfUV5BW01vi8y7zuaauWaBPH(EpDLY0ySFjTu2NCsTqLQU70hl17kmFd9rLY7kCFZ3GPRRq4X2Zi91CAMRoAfmROALOPXy)sAP0WyTJ0xZPH(EpDLYSSggcaGcgyln037PRuMgJ9lPJ5nipwkxkYc03B6QjISy7(Dw0mn6X6xcJnlpGfsq0ILLfl)oYI(AozX297G1ZIcqVKilqFVNUsXYY6VyKfpHzzrrwG(EtxnrKfqYcPrawkpyRLMf67bsOSSY)uSqAS8EteFkVHh(dKuJdqceHgPV30vte10nJaI3NRRqdCJEC12Pu1PRuvWCQfI3NRRqd99E6kv1gi)60vQkyo1gjeVpxxHMJycASsFVPRMiommsFnNgDx5zaRGz1vQ6VFjrAn9F1OH(EGKYS)WG(Aon6UYZawbZQRu1F)sI0Q3bprd99ajLz)XAPwOsvFVjIp1qFVNUsrqstleVpxxHg6790vQQnq(1PRuvWCYBqESuUuKfQnVJzHcy539NLOGfleXNLyNWSSS(lgzrpkll6Lez5EwCklk)rwCklwak90vilGKffsPS87EYI9zH(EGeklGMfn7w0NfB7yYI9jal03dKqzbjS11iVHh(dKuJdqceHgDy36piyLAZ7ynfIguy99Mi(0iitt3mIi)lqYLe1gPh(dKgh2T(dcwP28oUc7Xor0CzDQoI7)Wam4noSB9heSsT5DCf2JDIOH(EGecAFTWG34WU1FqWk1M3Xvyp2jIMgJ9lPe0(8gKhlL04Sr6olAwaqoVgz5MSqQTQXYjdSCuwA0HJQjw(DSrw8gzrHukl)UNSObwEVjIpLLlzH8xP3SqUb1zrrwSD)olqbpHstSOqkLLF3twiBtwa)o22okYYLS4zuwi3G6SOilGMLLflpGfnWY7nr8PSOJtqJS4Sq(R0Bwi3G6SOOHfndi3(zPXzJ0DwGx9LezPKYLWncZc5gBbSHDmMplRuHuklxYcuGYBwi3G6SOiVHh(dKuJdqceHgJbGCEnQPq0GcRV3eXNgbzA6Mr04Sr6URRqTV3eX38xmwFqf(WYgnImsJaJOwOsvFVjIp1qFVNxJLYUsPVMtdguNffRQv6TzznEmbAm2VKoMCoImc8UcZ382USgdaj1GPRRq4XAD63UQAbSHDzq8(CDfAOZAaqF7rFnNg6790vktJX(L0sro0oYTQHDmqYWaeVpxxHMJycASsFVPRMiomejguNffnxw9m6yTJcaGcgylnbVEzW0OdhvlguNffnxw9mQ2rq8(CDfAcGecGeScJ0OzyyiaakyGT0eajeajy93Xk1667PMgD4OddrgaqW0Z3KhX9VoDC8Wa1cvQ67nr8Pg6798AKGJgP52Zi91CAWG6SOyvTsVnlRsz)XJl1iYiW7kmFZB7YAmaKudMUUcHhpwBKyqDwu0qbkVRjs4x7OidaGcgylnbVEzW0OdhD8WWimOolkAUSsbkVhg0xZPbdQZIIv1k92SS0g57kmFdfSuvWS(7yDcAK(gmDDfcpw7iQfQu13BI4tn03751ibjBZsnImc8UcZ382USgdaj1GPRRq4XJhRDuKbaem98nKeTpphgIuFnNgsUeUr4kgBbSHDmMFftSjELanlRHbmOolkAUSsbkVhRns91CAAhcMGfToBmlr0k9Y5sv3JsFSp3SS4nipwkxkYcHcSfwajlbywSD)oy9SeClRljYB4H)aj14aKarOXjOdyfmRP)Rg10nJWTQHDmqYWaeVpxxHMJycASsFVPRMiYB4H)aj14aKarOriEFUUc1u6Xyeb4AaKW3FGS6autqC1cJyeeVpxxHMaCnas47pqQDK(Aon037PRuML1WW7kmFd9rLY7kCFZ3GPRRq4HHaacME(M8iU)1PJJ1cdEtmaKZRrZFbsUKO2rrQVMtdfOO)fqZYsBK6R50e86LbZYs7OiFxH5BMRoAfmROALObtxxHWdd6R50e86Lbd8Q9)azzbaqbdSLM5QJwbZkQwjAAm2VKsanFS2rrsXVQdYf18h22P5v7ScddyqDwu0CzvTsVhgWG6SOOHcuExtKW)yTq8(CDfA(9(uQkfrsWUAZVx7Oidaiy65BYJ4(xNoomaX7Z1vOjasiasWkmsJMHHHaaOGb2staKqaKG1FhRuRRVNAAm2VKsqY0WyTV3eX38xmwFqf(WY0xZPj41ldg4v7)bYsTPHqpEyqhqPANhX9V2ySFjLG6R50e86Lbd8Q9)ajbiZUs1ReNGMiAS6lg0WNRQEh88cvRLI69yEdYJLYLISqOAmlruwSD)olKARASCYaVHh(dKuJdqceHgBhcMGfToBmlrunDZi0xZPj41ldMgJ9lPLrMggg0xZPj41ldg4v7)bscqMDLQxjobnr0y1xmOHpxv9o45fQwlf1BcAh5qleVpxxHMaCnas47pqwDaYBqESuUuKfsTvnwozGfqYsaMLvQqkLfpHzrDjYY9SSSyX297SqkqcbqcYB4H)aj14aKarOXaQq6FUQ6QJygJ5RPBgbeVpxxHMaCnas47pqwDaQDuKbaem98nqW83J2ddr2ReNGMiAOxoxQ6Eu6J95dd9kXjOjIgR(Ibn85QQ3bpVq1APOEpmOVMttWRxgmWR2)dKLfHDKJXdd6R500oemblAD2ywIOMLLw91CAAhcMGfToBmlrutJX(LucsMgmAG3Wd)bsQXbibIqJxg8o9)aPMUzeq8(CDfAcW1aiHV)az1biVb5Xs5srwi3ylGnSzP8GeMfqYsaMfB3VZc037PRuSSSyXtywOoeKLjOzHqSuuVzXtywi1w1y5KbEdp8hiPghGeicnIXwaByx1bjSMUzeJcaGcgylnbVEzW0ySFjLa6R50e86Lbd8Q9)ajb6vItqtenw9fdA4ZvvVdEEHQ1sr9UuKzxzbaqbdSLgm2cyd7QoiHnWR2)dKeGSnhpmOVMttWRxgmng7xsltZ5nipwkPXzJ0DwMkVrwajlllwEal2NL3BI4tzX297G1ZcP2QglNmWIoEjrwCDW6z5bSGe26AKfpHzjbplaiyhClRljYB4H)aj14aKarOr6JkL31PYButHObfwFVjIpncY00nJOXzJ0DxxHA)lgRpOcFyzKPbTuluPQV3eXNAOV3ZRrcsAADRAyhdKODK(AonbVEzW0ySFjTmY2Cyis91CAcE9YGzznM3G8yPCPileka5YYnz5s6bJS4jlKBqDwuKfpHzrDjYY9SSSyX297S4SqiwkQ3Sy1GalEcZYwHDR)GGSa1M3X8gE4pqsnoajqeACU6OvWSIQvIA6MrGb1zrrZLvpJQDKBvd7yGKHHi7vItqtenw9fdA4ZvvVdEEHQ1sr9ES2r6R50y1xmOHpxv9o45fQwlf1BdexTqcANg2CyqFnNMGxVmyAm2VKwMMpw7iyWBCy36piyLAZ74kSh7erZFbsUK4WqKbaem98njgAGc0WdduluPQV3eXNwMDJ1osFnNM2HGjyrRZgZse10ySFjLGLe7zePvQEL4e0erd9Y5sv3JsFSpFSw91CAAhcMGfToBmlruZYAyis91CAAhcMGfToBmlruZYAS2rrgaafmWwAcE9YGzznmOVMtZV3NsvPisc2g67bsiizAq78iU)1gJ9lPe0Un3u78iU)1gJ9lPLr2MBomejfSu6xcB(9(uQkfrsW2GPRRq4XAhrblL(LWMFVpLQsrKeSny66keEyiaakyGT0e86LbtJX(L0YS)MJ1(EteFZFXy9bv4dltddd6akv78iU)1gJ9lPeKSn5nipwkxkYIZc037PRuSqiN4VZIvdcSSsfsPSa99E6kflhLfx1OdhLLLflGMLOGflEJS46G1ZYdybab7GBXYwPecEdp8hiPghGeicnsFVNUsPPBgH(AonGe)DA1c7aA9hinllTJ0xZPH(EpDLY04Sr6URRWHbN(TRQwaByxwjzZX8gKhlAMvSflBLsiyrhNGgzHuGecGeKfB3VZc037PRuS4jml)oMSa99MUAIiVHh(dKuJdqceHgPV3txP00nJiaGGPNVjpI7FD6O2iFxH5BOpQuExH7B(gmDDfcRDeeVpxxHMaiHaibRWinAgggcaGcgylnbVEzWSSgg0xZPj41ldML1yTbaqbdSLMaiHaibR)owPwxFp10ySFjLGedWMyNWLkGNAKt)2vvlGnSjNq8(CDfAOZAaq)XA1xZPH(EpDLY0ySFjLGKgVHh(dKuJdqceHgPV30vte10nJiaGGPNVjpI7FD6O2rq8(CDfAcGecGeScJ0OzyyiaakyGT0e86LbZYAyqFnNMGxVmywwJ1gaafmWwAcGecGeS(7yLAD99utJX(LucQbTq8(CDfAOV3txPQ2a5xNUsvbZPwmOolkAUS6zuTrcX7Z1vO5iMGgR03B6QjI8gKhlLlfzb67nD1erwSD)olEYcHCI)olwniWcOz5MSefS2gMfaeSdUflBLsiyX297SefSAwsKWplbN(gw2QIcybEfBXYwPecw8NLFhzbtywatw(DKLsQy(7rBw0xZjl3KfOV3txPyXgyPGZTFwMUsXcyozb0SefSyXBKfqYIDS8EteFkVHh(dKuJdqceHgPV30vte10nJqFnNgqI)oTguO3vih9aPzznmmks6798A04w1WogirBKq8(CDfAoIjOXk99MUAI4WWi91CAcE9YGPXy)skb1Gw91CAcE9YGzznmmAK(AonbVEzW0ySFjLGedWMyNWLkGNAKt)2vvlGnSjNq8(CDfAO0Aaq)XA1xZPj41ldML1WG(AonTdbtWIwNnMLiALE5CPQ7rPp2NBAm2VKsqIbytSt4sfWtnYPF7QQfWg2KtiEFUUcnuAnaO)yT6R500oemblAD2ywIOv6LZLQUhL(yFUzznwBaabtpFdem)9O94XAhrTqLQ(EteFQH(EpDLIG2FyaI3NRRqd99E6kv1gi)60vQkyohpwBKq8(CDfAoIjOXk99MUAIO2rr2ReNGMiA(lgTb6Sc3OhRFjm2dduluPQV3eXNAOV3txPiO9hZBqESuUuKfnlaiPSCjlqbkVzHCdQZIIS4jmluhcYcHAPuSOzbajltqZcP2QglNmWB4H)aj14aKarOXeTvJbGut3mIr6R50Gb1zrXkfO820ySFjTmKWyy9y9VyCyyuy3BIinc702yy3BIy9VyKGAy8Wqy3BIinc7pwRBvd7yGeEdp8hiPghGeicnU7QzngasnDZigPVMtdguNffRuGYBtJX(L0YqcJH1J1)IXHHrHDVjI0iStBJHDVjI1)IrcQHXddHDVjI0iS)yTUvnSJbs0osFnNM2HGjyrRZgZse10ySFjLGAqR(AonTdbtWIwNnMLiQzzPnYEL4e0erd9Y5sv3JsFSpFyis91CAAhcMGfToBmlruZYAmVHh(dKuJdqceHgNlLQgdaPMUzeJ0xZPbdQZIIvkq5TPXy)sAziHXW6X6FXO2rbaqbdSLMGxVmyAm2VKwMg2CyiaakyGT0eajeajy93Xk1667PMgJ9lPLPHnhpmmkS7nrKgHDABmS7nrS(xmsqnmEyiS7nrKgH9hR1TQHDmqI2r6R500oemblAD2ywIOMgJ9lPeudA1xZPPDiycw06SXSernllTr2ReNGMiAOxoxQ6Eu6J95ddrQVMtt7qWeSO1zJzjIAwwJ5nipwkxkYcHeGCzbKSqkndVHh(dKuJdqceHgT5DFGUcMvuTsK3G8yHuUkSu(JuwSTJ)o2S8awwuKfOV3ZRrwUKfOaL3SyB)c7SCuw8NfnWY7nr8PeGmwMGMfec2rzXUnjNSe70h7OSaAwinwG(EtxnrKfYn2cyd7ymFwOVhiHYB4H)aj14aKarOriEFUUc1u6Xye03751y9YkfO8wtqC1cJGAHkv99Mi(ud99EEnwgPrGPca6rXo9XoAfIRwyPiBZnjN2T5ycmvaqpsFnNg67nD1eXkgBbSHDmMFLcuEBOVhiHCsAJ5nipwiKtwSJL3BI4tzX297G1ZcuWsXcyYYVJSqOansFwIcwSq3blfmlZtPyX297Sqi1(VZc8QVKilLtg4n8WFGKACasGi0OT2)DnDZiIuFnNM2HGjyrRZgZse1SS0gP(AonTdbtWIwNnMLiALE5CPQ7rPp2NBwwAJ8DfMVHcwQkyw)DSobnsFdMUUcH1sTqLQ(EteFQH(EpVgjO91QVMtdguNffRuGYBtJX(L0YqcJH1J1)IrTZJ4(xBm2VKwM(AonbVEzW0ySFjLaKzxP6vItqtenw9fdA4ZvvVdEEHQ1sr9M3G8yHuUkSu(JuwSTJ)o2S8awiKA)3zbE1xsKfcvJzjIYB4H)aj14aKarOriEFUUc1u6Xye2A)3RxwNnMLiQMG4QfgbzKtQfQu1DN(ibTZEgTPXUsnAe1cvQ67nr8Pg6798A0EiBm5C0iQfQu13BI4tn03751O9q2yYPDBsaYgpUuJiJaVRW8nuWsvbZ6VJ1jOr6BW01viCPiZOHXJjWMgY0qP0xZPPDiycw06SXSernng7xs5nipwkxkYcHu7)olxYcuGYBwi3G6SOilGMLBYscyb6798AKfBNsXY8EwU8bSqQTQXYjdS4z0yqJ8gE4pqsnoajqeA0w7)UMUzeJWG6SOOrTsVRjs4FyadQZIIgpJwtKWVwiEFUUcnhTguOdbhRD07nr8n)fJ1huHpSmsByadQZIIg1k9UEz1UHbDaLQDEe3)AJX(Lucs2MJhg0xZPbdQZIIvkq5TPXy)skb9WFG0qFVNxJgKWyy9y9VyuR(AonyqDwuSsbkVnlRHbmOolkAUSsbkV1gjeVpxxHg6798ASEzLcuEpmOVMttWRxgmng7xsjOh(dKg6798A0GegdRhR)fJAJeI3NRRqZrRbf6qqT6R50e86LbtJX(LucIegdRhR)fJA1xZPj41ldML1WG(AonTdbtWIwNnMLiQzzPfI3NRRqJT2)96L1zJzjIomejeVpxxHMJwdk0HGA1xZPj41ldMgJ9lPLHegdRhR)fJ8gKhlLlfzb6798AKLBYYLSq(R0Bwi3G6SOOMy5swGcuEZc5guNffzbKSqAeGL3BI4tzb0S8awSAqGfOaL3SqUb1zrrEdp8hiPghGeicnsFVNxJ8gKhlekxP(9EXB4H)aj14aKarOXELvp8hiRQJ(Ak9ymIPRu)EV4n4nipwG(EtxnrKLjOzjgabJX8zzLkKszzrVKilLhS1sZB4H)aj1mDL637ve03B6QjIA6MrezVsCcAIOr3vEgWkywDLQ(7xsKAq7DDwwimVb5XcPC6ZYVJSadEwSD)ol)oYsmG(S8xmYYdyXHHzzL)Py53rwIDcZc8Q9)ajlhLL97nSaDLZRrwAm2VKYs8s9NL6qywEalX(h2zjgaY51ilWR2)dK8gE4pqsntxP(9ErGi0iDLZRrnfIguy99Mi(0iitt3mcyWBIbGCEnAAm2VKwwJX(L0szNDKtY0CEdp8hiPMPRu)EViqeAmgaY51iVbVb5Xs5srw2kSB9heKfO28oMfB7yYYVJnYYrzjbS4H)GGSqT5DSMyXPSO8hzXPSybO0txHSaswO28oMfB3VZIDSaAwMOnSzH(EGeklGMfqYIZI9jaluBEhZcfWYV7pl)oYsI2yHAZ7yw8UpiiLfn7w0NfF(yZYV7pluBEhZcsyRRrkVHh(dKud9JWHDR)GGvQnVJ1uiAqH13BI4tJGmnDZiIeg8gh2T(dcwP28oUc7Xor08xGKljQnsp8hinoSB9heSsT5DCf2JDIO5Y6uDe3FTJIeg8gh2T(dcwP28oUUJUY8xGKljomadEJd7w)bbRuBEhx3rxzAm2VKwMggpmadEJd7w)bbRuBEhxH9yNiAOVhiHG2xlm4noSB9heSsT5DCf2JDIOPXy)skbTVwyWBCy36piyLAZ74kSh7erZFbsUKiVb5Xs5srklKcKqaKGSCtwi1w1y5Kbwoklllwanlrblw8gzbgPrZWLezHuBvJLtgyX297SqkqcbqcYINWSefSyXBKfDubSXcPTPgT)MJifQq6FUIfOwxFpDmlBLsiy5swCwiBtcWcfdSqUb1zrrdlBvrbSadYTFwu4ZIMPrpw)sySzbjS11OMyXv28OuwwuKLlzHuBvJLtgyX297SqiwkQ3S4jml(ZYVJSqFVFwatwCwkpyRLMfBxcdSz4n8WFGKAOpbIqJbqcbqcw)DSsTU(EQMUzeJgbX7Z1vOjasiasWkmsJMbTrgaafmWwAcE9YGPrhoQ2i7vItqtenw9fdA4ZvvVdEEHQ1sr9EyqFnNMGxVmywwAhfzVsCcAIOXQVyqdFUQ6DWZluTwkQ3dd9kXjOjIMaQq6FUQsTU(E6WW8iU)1gJ9lPLrMDe6HbDaLQDEe3)AJX(LucgaafmWwAcE9YGPXy)skbiBZHb91CAcE9YGPXy)sAzKz34XAhnYPF7QQfWg2emciEFUUcnbqcbqcwDQL2r6R50Gb1zrXQALEBAm2VKwgzBomOVMtdguNffRuGYBtJX(L0YiBZXdd6R50e86LbtJX(L0Y0Gw91CAcE9YGPXy)skbJGm7gRDuK9kXjOjIM)IrBGoRWn6X6xcJ9WqK9kXjOjIMaQq6FUQsTU(E6WG(Aon)fJ2aDwHB0J1VegBtJX(L0YqcJH1J1)IXXdd9kXjOjIgDx5zaRGz1vQ6VFjr6yTJISxjobnr0O7kpdyfmRUsv)9ljshggPVMtJUR8mGvWS6kv93VKiTM(VA0qFpqseA(WG(Aon6UYZawbZQRu1F)sI0Q3bprd99ajrO5JhpmOdOuTZJ4(xBm2VKsqY2uBKbaqbdSLMGxVmyA0HJoM3G8yPCPilqFVPRMiYYdyHeeTyzzXYVJSOzA0J1VegBw0xZjl3KL7zXgyPGzbjS11il64e0ilZlp6(Lez53rwsKWplbN(SaAwEalWRylw0XjOrwifiHaib5n8WFGKAOpbIqJ03B6QjIA6Mr0ReNGMiA(lgTb6Sc3OhRFjm2Ahf5Or6R508xmAd0zfUrpw)sySnng7xslZd)bsJT2)DdsymSES(xmsGnnKPDeguNffnxw1b)(WaguNffnxwPaL3ddyqDwu0OwP31ej8pEyqFnNM)IrBGoRWn6X6xcJTPXy)sAzE4pqAOV3ZRrdsymSES(xmsGnnKPDeguNffnxwvR07HbmOolkAOaL31ej8pmGb1zrrJNrRjs4F84HHi1xZP5Vy0gOZkCJES(LWyBwwJhggPVMttWRxgmlRHbiEFUUcnbqcbqcwHrA0mmwBaauWaBPjasiasW6VJvQ113tnn6Wr1gaqW0Z3KhX9VoDu7i91CAWG6SOyvTsVnng7xslJSnhg0xZPbdQZIIvkq5TPXy)sAzKT54XAhfzaabtpFdjr7ZZHHaaOGb2sdgBbSHDvhKWMgJ9lPLP5J5nipw0mRylwG(EtxnrKYIT73zP8UYZaYcyYYwvkwk9(LePSaAwEalwnA5nYYe0SqkqcbqcYIT73zP8GTwAEdp8hiPg6tGi0i99MUAIOMUze9kXjOjIgDx5zaRGz1vQ6VFjrQ2rJ0xZPr3vEgWkywDLQ(7xsKwt)xnAOVhiPm7gg0xZPr3vEgWkywDLQ(7xsKw9o4jAOVhiPm7gRnaakyGT0e86LbtJX(L0Yi0AJmaakyGT0eajeajy93Xk1667PML1WWOaacME(M8iU)1PJAdaGcgylnbqcbqcw)DSsTU(EQPXy)skbjBtTyqDwu0Cz1ZOAD63UQAbSHDz2TjbS)MLkaakyGT0e86LbtJoC0XJ5nipwifiHV)ajltqZIRuSadEkl)U)Se7KGuwORgz53XOS4nMB)S04Sr6ocZITDmzPK2HGjyrzHq1ywIOSS7uwuiLYYV7jlAGfkgOS0ySF5Lezb0S87ilKBSfWg2SuEqcZI(Aoz5OS46G1ZYdyz6kflG5KfqZINrzHCdQZIISCuwCDW6z5bSGe26AK3Wd)bsQH(eicncX7Z1vOMspgJag81gT311ymMpvtqC1cJyK(AonTdbtWIwNnMLiQPXy)sAzAyyis91CAAhcMGfToBmlruZYAS2i1xZPPDiycw06SXSerR0lNlvDpk9X(CZYs7i91CAi5s4gHRySfWg2Xy(vmXM4vc00ySFjLGedWMyNWJ1osFnNgmOolkwPaL3MgJ9lPLrmaBIDcpmOVMtdguNffRQv6TPXy)sAzedWMyNWddJIuFnNgmOolkwvR0BZYAyis91CAWG6SOyLcuEBwwJ1g57kmFdfOO)fqdMUUcHhZBqESqkqcF)bsw(D)zjSJbsOSCtwIcwS4nYcy90dgzbdQZIIS8awaPkklWGNLFhBKfqZYrmbnYYVFuwSD)olqbk6FbK3Wd)bsQH(eicncX7Z1vOMspgJag8vW6PhmwXG6SOOMG4QfgXOi1xZPbdQZIIvkq5TzzPns91CAWG6SOyvTsVnlRXAJ8DfMVHcu0)cObtxxHWAJSxjobnr08xmAd0zfUrpw)syS5nipw0mGNfxPy59Mi(uwSD)(LSqi8egJVal2UFhSEwaqWo4wwxsKa)oYIRdGGSeaj89hiP8gE4pqsn0NarOXyaiNxJAkenOW67nr8PrqMMUzeJ0xZPbdQZIIvkq5TPXy)sAzng7xshg0xZPbdQZIIv1k920ySFjTSgJ9lPddq8(CDfAGbFfSE6bJvmOolkowBJZgP7UUc1(EteFZFXy9bv4dlJm706w1WogirleVpxxHgyWxB0ExxJXy(uEdp8hiPg6tGi0iDLZRrnfIguy99Mi(0iitt3mIr6R50Gb1zrXkfO820ySFjTSgJ9lPdd6R50Gb1zrXQALEBAm2VKwwJX(L0HbiEFUUcnWGVcwp9GXkguNffhRTXzJ0DxxHAFVjIV5VyS(Gk8HLrMDADRAyhdKOfI3NRRqdm4RnAVRRXymFkVHh(dKud9jqeAK(Os5DDQ8g1uiAqH13BI4tJGmnDZigPVMtdguNffRuGYBtJX(L0YAm2VKomOVMtdguNffRQv6TPXy)sAzng7xshgG4956k0ad(ky90dgRyqDwuCS2gNns3DDfQ99Mi(M)IX6dQWhwgzKdTUvnSJbs0cX7Z1vObg81gT311ymMpL3G8yrZaEw6J4(ZIoobnYcHQXSerz5MSCpl2alfmlUsbSXsuWILhWsJZgP7SOqkLf4vFjrwiunMLiklJ(9JYcivrzz3TSWKYIT73bRNfOxoxkw0Snk9X(8X8gE4pqsn0NarOriEFUUc1u6XyejOUhL(yFEf9wfTcdEnbXvlmIaacME(giy(7rBTr2ReNGMiAOxoxQ6Eu6J95AJSxjobnr0eUoOWkywv3eREcxHr)31gaafmWwA0XMInjxs00OdhvBaauWaBPPDiycw06SXSernn6Wr1gP(AonbVEzWSS0oYPF7QQfWg2LP5e6Hb91CA0vaaSArFZYAmVHh(dKud9jqeAmgaY51OMUzeq8(CDfAsqDpk9X(8k6TkAfg8ABm2VKsq72K3Wd)bsQH(eicnsx58Aut3mciEFUUcnjOUhL(yFEf9wfTcdETng7xsjizLeEdYJLYLISqOaBHfqYsaMfB3Vdwplb3Y6sI8gE4pqsn0NarOXjOdyfmRP)Rg10nJWTQHDmqcVb5Xs5srwi3ylGnSzP8GeMfB3VZINrzrbsISGjyrCNfLt)ljYc5guNffzXtyw(oklpGf1Lil3ZYYIfB3VZcHyPOEZINWSqQTQXYjd8gE4pqsn0NarOrm2cyd7QoiH10nJyuaauWaBPj41ldMgJ9lPeqFnNMGxVmyGxT)hijqVsCcAIOXQVyqdFUQ6DWZluTwkQ3LIm7klaakyGT0GXwaByx1bjSbE1(FGKaKT54Hb91CAcE9YGPXy)sAzAoVb5Xcu8PSyBhtw2kLqWcDhSuWSOJSaVITqywEalj4zbab7GBXYindAHjmLfqYcHA1rzbmzHCvRezXtyw(DKfYnOolkoM3Wd)bsQH(eicncX7Z1vOMspgJWPwv4vSLMG4QfgHt)2vvlGnSlRKSP9mYoJgkL(AonZvhTcMvuTs0qFpqI9yxPWG6SOO5YQALEpM3G8yPCPilKARASCYal2UFNfsbsiasqnws5s4gHzbQ113tzXtywGb52plaiyBRVhzHqSuuVzb0SyBhtwkVcaGvl6ZInWsbZcsyRRrw0XjOrwi1w1y5KbwqcBDnsnSOz5KGSqxnYYdybZhBwCwi)v6nlKBqDwuKfB7yYYIEetwkTDAol2zfyXtywCLIfsPzOSy7ukw0XaigzPrhokluaizbtWI4olWR(sIS87il6R5KfpHzbg8uw2Diil6iMSqxZ5fomFvuwAC2iDhHn8gE4pqsn0NarOriEFUUc1u6Xyeb4AaKW3FGSsFnbXvlmIrq8(CDfAcW1aiHV)aP2i1xZPj41ldMLL2rrsXVQdYf18h22P5v7ScddyqDwu0CzvTsVhgWG6SOOHcuExtKW)yTJgncI3NRRqJtTQWRyRHHaacME(M8iU)1PJddJcaiy65BijAFEQnaakyGT0GXwaByx1bjSPrho64HHEL4e0erZFXOnqNv4g9y9lHXESwyWBORCEnAAm2VKwMMRfg8MyaiNxJMgJ9lPLvs0ocg8g6JkL31PYB00ySFjTmY2CyiY3vy(g6JkL31PYB0GPRRq4XAH4956k0879PuvkIKGD1MFV23BI4B(lgRpOcFyz6R50e86Lbd8Q9)azP20qOhg0xZPrxbaWQf9nllT6R50ORaay1I(MgJ9lPeuFnNMGxVmyGxT)hijWiYSRu9kXjOjIgR(Ibn85QQ3bpVq1APOEpE8WWi0ExNLfcBWyROn6QkOHtpdO2aaOGb2sdgBfTrxvbnC6zanng7xsjizKdcnbgPHs1ReNGMiAOxoxQ6Eu6J95Jhpw7OrrgaqW0Z3KhX9VoDCyyeeVpxxHMaiHaibRWinAgggcaGcgylnbqcbqcw)DSsTU(EQPXy)skbjtdJ1okYEL4e0erJUR8mGvWS6kv93VKiDyWPF7QQfWg2eudBQnaakyGT0eajeajy93Xk1667PMgD4OJhpmmpI7FTXy)skbdaGcgylnbqcbqcw)DSsTU(EQPXy)s64HbDaLQDEe3)AJX(LucQVMttWRxgmWR2)dKeGm7kvVsCcAIOXQVyqdFUQ6DWZluTwkQ3J5nipwkxkYcHQXSerzX297SqQTQXYjdSSsfsPSqOAmlruwSbwkywuo9zrbsIyZYV7jlKARASCYGMy53XKLffzrhNGg5n8WFGKAOpbIqJTdbtWIwNnMLiQMUze6R50e86LbtJX(L0Yitddd6R50e86Lbd8Q9)ajbTJqtGEL4e0erJvFXGg(Cv17GNxOATuuVlfz2PfI3NRRqtaUgaj89hiR0N3Wd)bsQH(eicngqfs)ZvvxDeZymFnDZiG4956k0eGRbqcF)bYk91osFnNMGxVmyGxT)hillc7i0eOxjobnr0y1xmOHpxv9o45fQwlf17srMDddrgaqW0Z3abZFpApEyqFnNM2HGjyrRZgZse1SS0QVMtt7qWeSO1zJzjIAAm2VKsWscbcGeEDVXQXWrXQRoIzmMV5VyScXvlKaJIuFnNgDfaaRw03SS0g57kmFd99wbAydMUUcHhZB4H)aj1qFceHgVm4D6)bsnDZiG4956k0eGRbqcF)bYk95nipwkP6956kKLffHzbKS46N6(dPS87(ZInpFwEal6iluhccZYe0SqQTQXYjdSqbS87(ZYVJrzXBmFwS50hHzrZUf9zrhNGgz53XyEdp8hiPg6tGi0ieVpxxHAk9ymcQdbRtqxdE9YGMG4QfgraauWaBPj41ldMgJ9lPLr2MddrcX7Z1vOjasiasWkmsJMbTbaem98n5rC)Rth5nipwkxkszHqbixwUjlxYINSqUb1zrrw8eMLVpKYYdyrDjYY9SSSyX297SqiwkQ3AIfsTvnwozqtSqUXwaByZs5bjmlEcZYwHDR)GGSa1M3X8gE4pqsn0NarOX5QJwbZkQwjQPBgbguNffnxw9mQ2ro9BxvTa2WMGLe7Sh91CAMRoAfmROALOH(EGKsPHHb91CAAhcMGfToBmlruZYAS2r6R50y1xmOHpxv9o45fQwlf1BdexTqcAhPT5WG(AonbVEzW0ySFjTmnFSwiEFUUcnuhcwNGUg86LbTJImaGGPNVjXqduGgEyag8gh2T(dcwP28oUc7Xor08xGKljow7Oidaiy65BGG5VhThg0xZPPDiycw06SXSernng7xsjyjXEgrALQxjobnr0qVCUu19O0h7ZhRvFnNM2HGjyrRZgZse1SSggIuFnNM2HGjyrRZgZse1SSgRDuKbaem98nKeTpphgcaGcgylnySfWg2vDqcBAm2VKwMDBow77nr8n)fJ1huHpSmnmmOdOuTZJ4(xBm2VKsqY2K3G8yPCPileYj(7Sa99E6kflwniqz5MSa99E6kflhn3(zzzXB4H)aj1qFceHgPV3txP00nJqFnNgqI)oTAHDaT(dKMLLw91CAOV3txPmnoBKU76kK3G8yHuEgqflqFVvGgMLBYY9SS7uwuiLYYV7jlAGYsJX(LxsutSefSyXBKf)zPKSjbyzRucblEcZYVJSewDJ5Zc5guNffzz3PSObcqzPXy)YljYB4H)aj1qFceHgdEgqvvFnNAk9ymc67Tc0WA6MrOVMtd99wbAytJX(LucQbTJ0xZPbdQZIIvkq5TPXy)sAzAyyqFnNgmOolkwvR0BtJX(L0Y0WyTo9BxvTa2WUSsYM8gKhlqXNYITDmzHqSuuVzHUdwkyw0rwSAqiGWSGERIYYdyrhzX1vilpGLffzHuGecGeKfqYsaauWaBjlJixkfZ)CLkkl6yaeJuw(EHSCtwGxXwxsKLTsjeSKaBSy7ukwCLcyJLOGflpGflSNy4vrzbZhBwielf1Bw8eMLFhtwwuKfsbsiasWX8gE4pqsn0NarOriEFUUc1u6XyewniuTwkQ3v0BvunbXvlmIaacME(M8iU)1PJA7vItqtenw9fdA4ZvvVdEEHQ1sr9wR(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKao9BxvTa2WMa2VSiS)MBQfI3NRRqtaKqaKGvyKgndAdaGcgylnbqcbqcw)DSsTU(EQPXy)skbD63UQAbSHn50(BwkIbytStyTyqDwu0Cz1ZOAD63UQAbSHDzq8(CDfAcGecGeS6ulTbaqbdSLMGxVmyAm2VKwMg4nipwkxkYc037PRuSy7(DwG(Os5nlAM(MplGML3onNfsZkWINWSKawG(ERanSMyX2oMSKawG(EpDLILJYYYIfqZYdyXQbbwielf1BwSTJjlUoacYsjztw2kLqmc0S87ilO3QOSqiwkQ3Sy1Galq8(CDfYYrz57foMfqZIdB5)bbzHAZ7yw2DklAobOyGYsJX(LxsKfqZYrz5swMQJ4(ZB4H)aj1qFceHgPV3txP00nJy07kmFd9rLY7kCFZ3GPRRq4Hbk(vDqUOM)W2onVsAwHXAJ8DfMVH(ERanSbtxxHWA1xZPH(EpDLY04Sr6URRqTr2ReNGMiA(lgTb6Sc3OhRFjm2AhPVMtJvFXGg(Cv17GNxOATuuVnqC1cllc70WMAJuFnNMGxVmywwAhbX7Z1vOXPwv4vS1WG(AonKCjCJWvm2cyd7ym)kMyt8kbAwwddq8(CDfASAqOATuuVRO3QOJhggfaqW0Z3KyObkqdR9DfMVH(Os5DfUV5BW01viS2rWG34WU1FqWk1M3Xvyp2jIMgJ9lPLP5ddE4pqACy36piyLAZ74kSh7erZL1P6iU)Jhpw7OaaOGb2stWRxgmng7xslJSnhgcaGcgylnbqcbqcw)DSsTU(EQPXy)sAzKT5yEdYJfnZk2IYYwPecw0XjOrwifiHaibzzrVKil)oYcPajeajilbqcF)bswEalHDmqcl3KfsbsiasqwoklE4xUsfLfxhSEwEal6ilbN(8gE4pqsn0NarOr67nD1ernDZiG4956k0y1Gq1APOExrVvr5nipwkxkYIMfaKuwSTJjlrblw8gzX1bRNLhOrVrwcUL1LezjS7nrKYINWSe7KGSqxnYYVJrzXBKLlzXtwi3G6SOil0)ukwMGMfnB1S0iHsZI3Wd)bsQH(eicnMOTAmaKA6Mr4w1Wogir7OWU3erAe2PTXWU3eX6FXib1WWqy3BIinc7pM3Wd)bsQH(eicnU7QzngasnDZiCRAyhdKODuy3BIinc702yy3BIy9VyKGAyyiS7nrKgH9hRDK(AonyqDwuSQwP3MgJ9lPLHegdRhR)fJdd6R50Gb1zrXkfO820ySFjTmKWyy9y9VyCmVHh(dKud9jqeACUuQAmaKA6Mr4w1Wogir7OWU3erAe2PTXWU3eX6FXib1WWqy3BIinc7pw7i91CAWG6SOyvTsVnng7xsldjmgwpw)lghg0xZPbdQZIIvkq5TPXy)sAziHXW6X6FX4yEdYJLYLISa99MUAIileYj(7Sy1GaLfpHzbEfBXYwPecwSTJjlKARASCYGMyHCJTa2WMLYdsynXYVJSusfZFpAZI(Aoz5OS46G1ZYdyz6kflG5KfqZsuWABywcUflBLsi4n8WFGKAOpbIqJ03B6QjIA6MrGb1zrrZLvpJQDK(AonGe)DAnOqVRqo6bsZYAyqFnNgsUeUr4kgBbSHDmMFftSjELanlRHb91CAcE9YGzzPDuKbaem98nKeTpphgcaGcgylnySfWg2vDqcBAm2VKwMggg0xZPj41ldMgJ9lPeKya2e7eUutfa0JC63UQAbSHn5eI3NRRqdLwda6pES2rrgaqW0Z3abZFpApmOVMtt7qWeSO1zJzjIAAm2VKsqIbytSt4sfWtnAKt)2vvlGnSjaPTzPExH5BMRoAfmROALObtxxHWJjNq8(CDfAO0Aaq)XeW(L6DfMVjrB1yainy66kewBK9kXjOjIg6LZLQUhL(yFUw91CAAhcMGfToBmlruZYAyqFnNM2HGjyrRZgZseTsVCUu19O0h7ZnlRHHr6R500oemblAD2ywIOMgJ9lPe0d)bsd99EEnAqcJH1J1)IrTuluPQ7o9rcUPH0gg0xZPPDiycw06SXSernng7xsjOh(dKgBT)7gKWyy9y9VyCyqFnNgR(Ibn85QQ3bpVq1APOEBG4Qfwwe2r2MAh50VDv1cyd7YG4956k0qP1aG(LYo7rddd6R500oemblAD2ywIOMgJ9lPLz3yT6R500oemblAD2ywIOMgJ9lPeKCmmaX7Z1vO5Sx4AaKW3FGuBaauWaBP5sAOxVRRWQ9U88xXvyeYfqtJoCuTO9Uolle2Cjn0R31vy1ExE(R4kmc5c4yT6R500oemblAD2ywIOML1WqK6R500oemblAD2ywIOMLL2idaGcgylnTdbtWIwNnMLiQPrho64HbiEFUUcno1QcVITgg0buQ25rC)Rng7xsjiXaSj2jCPc4Pg50VDv1cydBYjeVpxxHgkTga0F8yEdYJLs3rz5bSe7KGS87il6i9zbmzb67Tc0WSOhLf67bsUKil3ZYYIf7DDbsurz5sw8mklKBqDwuKf91ZcHyPOEZYrZTFwCDW6z5bSOJSy1GqaH5n8WFGKAOpbIqJ03B6QjIA6Mr8UcZ3qFVvGg2GPRRqyTr2ReNGMiA(lgTb6Sc3OhRFjm2AhPVMtd99wbAyZYAyWPF7QQfWg2Lvs2CSw91CAOV3kqdBOVhiHG2x7i91CAWG6SOyLcuEBwwdd6R50Gb1zrXQALEBwwJ1QVMtJvFXGg(Cv17GNxOATuuVnqC1cjODe6n1okaakyGT0e86LbtJX(L0YiBZHHiH4956k0eajeajyfgPrZG2aacME(M8iU)1PJJ5nipwix6FX(Juw2b2yjEf2zzRucblEJSq0VeHzXcBwOyaKWgwiKtvuwENeKYIZcnDl6o4zzcAw(DKLWQBmFwO3V8)ajlual2alfCU9ZIoYIhcR2FKLjOzr5nrSz5VyC2Ems5n8WFGKAOpbIqJq8(CDfQP0JXiCQfHaBOyqtqC1cJadQZIIMlRQv6DP0CYPh(dKg6798A0GegdRhR)fJeismOolkAUSQwP3LAe5GaVRW8nuWsvbZ6VJ1jOr6BW01viCPS)yYPh(dKgBT)7gKWyy9y9VyKaBAinnqoPwOsv3D6JeytJgk17kmFt6)QrAv3vEgqdMUUcH5nipw0mRylwG(EtxnrKLlzXtwi3G6SOiloLfkaKS4uwSau6PRqwCklkqsKfNYsuWIfBNsXcMWSSSyX297SO5BsawSTJjly(yFjrw(DKLej8Zc5guNff1elWGC7Nff(SCplwniWcHyPOERjwGb52plaiyBRVhzXtwiKt83zXQbbw8eMflaqXIoobnYcP2QglNmWINWSqUXwaByZs5bjmVHh(dKud9jqeAK(Etxnrut3mIi7vItqten)fJ2aDwHB0J1VegBTJ0xZPXQVyqdFUQ6DWZluTwkQ3giUAHe0oc9Mdd6R50y1xmOHpxv9o45fQwlf1BdexTqcANg2u77kmFd9rLY7kCFZ3GPRRq4XAhHb1zrrZLvkq5TwN(TRQwaBytaiEFUUcno1IqGnumuk91CAWG6SOyLcuEBAm2VKsayWBMRoAfmROALO5Vaj0AJX(LLYoJgktZ3CyadQZIIMlRQv6TwN(TRQwaBytaiEFUUcno1IqGnumuk91CAWG6SOyvTsVnng7xsjam4nZvhTcMvuTs08xGeATXy)YszNrdLvs2CS2i1xZPbK4VtRwyhqR)aPzzPnY3vy(g67Tc0WgmDDfcRDuaauWaBPj41ldMgJ9lPLrOhgOGLs)syZV3NsvPisc2gmDDfcRvFnNMFVpLQsrKeSn03dKqq7BF7zuVsCcAIOHE5CPQ7rPp2Nxk7gRDEe3)AJX(L0YiBZn1opI7FTXy)skbTBZnhRDuKbaem98nKeTpphgcaGcgylnySfWg2vDqcBAm2VKwMDJ5nipwkxkYIMfaKuwUKfpJYc5guNffzXtywOoeKfnBD1KaeQLsXIMfaKSmbnlKARASCYalEcZsjLlHBeMfYn2cyd7ymFdlBvrbSSOilBrZIfpHzHqPzXI)S87ilycZcyYcHQXSerzXtywGb52plk8zrZ0OhRFjm2SmDLIfWCYB4H)aj1qFceHgt0wngasnDZiCRAyhdKOfI3NRRqd1HG1jORbVEzq7i91CAWG6SOyvTsVnng7xsldjmgwpw)lghg0xZPbdQZIIvkq5TPXy)sAziHXW6X6FX4yEdp8hiPg6tGi04URM1yai10nJWTQHDmqIwiEFUUcnuhcwNGUg86LbTJ0xZPbdQZIIv1k920ySFjTmKWyy9y9VyCyqFnNgmOolkwPaL3MgJ9lPLHegdRhR)fJJ1osFnNMGxVmywwdd6R50y1xmOHpxv9o45fQwlf1BdexTqcgHDKT5yTJImaGGPNVbcM)E0EyqFnNM2HGjyrRZgZse10ySFjLGJ0G9yxP6vItqten0lNlvDpk9X(8XA1xZPPDiycw06SXSernlRHHi1xZPPDiycw06SXSernlRXAhfzVsCcAIO5Vy0gOZkCJES(LWypmGegdRhR)fJeuFnNM)IrBGoRWn6X6xcJTPXy)s6WqK6R508xmAd0zfUrpw)sySnlRX8gE4pqsn0NarOX5sPQXaqQPBgHBvd7yGeTq8(CDfAOoeSobDn41ldAhPVMtdguNffRQv6TPXy)sAziHXW6X6FX4WG(AonyqDwuSsbkVnng7xsldjmgwpw)lghRDK(AonbVEzWSSgg0xZPXQVyqdFUQ6DWZluTwkQ3giUAHemc7iBZXAhfzaabtpFdjr7ZZHb91CAi5s4gHRySfWg2Xy(vmXM4vc0SSgRDuKbaem98nqW83J2dd6R500oemblAD2ywIOMgJ9lPeudA1xZPPDiycw06SXSernllTr2ReNGMiAOxoxQ6Eu6J95ddrQVMtt7qWeSO1zJzjIAwwJ1okYEL4e0erZFXOnqNv4g9y9lHXEyajmgwpw)lgjO(Aon)fJ2aDwHB0J1VegBtJX(L0HHi1xZP5Vy0gOZkCJES(LWyBwwJ5nipwkxkYcHeGCzbKSeG5n8WFGKAOpbIqJ28UpqxbZkQwjYBqESuUuKfOV3ZRrwEalwniWcuGYBwi3G6SOOMyHuBvJLtgyz3PSOqkLL)Irw(DpzXzHqQ9FNfKWyy9ilkC(SaAwaPkklK)k9MfYnOolkYYrzzzzyHq6(DwkTDAol2zfybZhBwCwGcuEZc5guNffz5MSqiwkQ3Sq)tPyz3PSOqkLLF3twSJSnzH(EGeklEcZcP2QglNmWINWSqkqcbqcYYUdbzjg0il)UNSqgHMYcP0mS0ySF5LenSuUuKfxhabzXonSj5KLDN(ilWR(sISqOAmlruw8eMf7SZoYjl7o9rwSD)oy9SqOAmlruEdp8hiPg6tGi0i99EEnQPBgbguNffnxwvR0BTrQVMtt7qWeSO1zJzjIAwwddyqDwu0qbkVRjs4FyyeguNffnEgTMiH)Hb91CAcE9YGPXy)skb9WFG0yR9F3GegdRhR)fJA1xZPj41ldML1yTJIKIFvhKlQ5pSTtZR2zfgg6vItqtenw9fdA4ZvvVdEEHQ1sr9wR(Aonw9fdA4ZvvVdEEHQ1sr92aXvlKG2r2MAdaGcgylnbVEzW0ySFjTmYi0AhfzaabtpFtEe3)60XHHaaOGb2staKqaKG1FhRuRRVNAAm2VKwgze6XAhfz7b08nqPggcaGcgyln6ytXMKljAAm2VKwgze6XJhgWG6SOO5YQNr1osFnNgBE3hORGzfvRenlRHbQfQu1DN(ib30qAAq7Oidaiy65BGG5VhThgIuFnNM2HGjyrRZgZse1SSgpmeaqW0Z3abZFpARLAHkvD3PpsWnnK2yEdYJLYLISqi1(VZc43X22rrwSTFHDwoklxYcuGYBwi3G6SOOMyHuBvJLtgyb0S8awSAqGfYFLEZc5guNff5n8WFGKAOpbIqJ2A)35nipwiuUs979I3Wd)bsQH(eicn2RS6H)azvD0xtPhJrmDL637vXx8ffa]] )


end