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


    spec:RegisterPack( "Balance", 20220403, [[difR5fqiHOhHOsxIuuSjsPpPuQrPOCkfvRsIKxHaMfPi3siWUO4xKcgMsrhdrzzuQ8mHqtdrQUgPqBdrv8neKACKIQZjreRtIOMhc09Ou1(KO8psrPOdQusluIQEiIKjIOkDrevSreK8rsrPQrskkLoPevSsLcVuIiXmruv3KuuYovkXprqudfbHJskkfwQerQNcstvIuxvIkTvjIK(kcImwePSxj8xjnyIdt1IjvpwWKb1LH2ScFgHgTs1Pvz1KIsLxJiMnj3wO2TOFdmCk54cbTCPEostxvxxjBheFNsz8iOoVqA9seMVISFuxqwrPlGc7pwSf720o72K03mIgYkjKz3MKNcOFulSaQLhiXjIfqtpglGwEx5zalGA5rvahUO0fqPGvhWcO7)BrlznObDx5zaJa6fhmeVFFPBoGgkVR8mGra0lMuAig2S)XknBoofAVUR8mGMNWFbu91P(Yjl0lGc7pwSf720o72K03mIgYkjKrMgTRaQV(Dqxaf6ftQcO7hmmMf6fqHrAOaA5DLNbKfYBVoyEJTA1NIfY0el2TPD2XBWBqQDpjI0sM3icyzRWWimlqbkVzP8OhB4nIawi1UNerywEVjIF9gSeCksz5bSeIguy99Mi(udVreWsjngdGGWSSYediL6DuwG4956kKYYSZGgnXIvJqQ03B6QjISebLXIvJqm03B6QjIZn8gralBfc4GzXQXGt)ljYcHu7)ol3GL73MYYVJSyRbjrwiNG6SOOH3icyrZYjbzHuGecGeKLFhzbQ113tzXzrD)RqwIbnYYqHe(0vilZUblrblw2D4C7NL97z5EwOx8s9EIGfvfLfB3VZs5jK3APzHaSqkuH0)CflBvDeZymFnXY9BdZcLKZAUH3icyrZYjbzjgqFw2ECe3)AJX(L0TzHgW07dqzXTSurz5bSOdOuwghX9NYcivrn8gralLUr)zP0GyKfWGLYR8DwkVY3zP8kFNfNYIZc1cdNRy57ljbFdVreWcHSfMyZYSZGgnXcHu7)UMyHqQ9FxtSa99ECnoNLyhgzjg0ilnsp1H5ZYdyb9wDyZsaeR7FeqFVFdVreWcH6imlLuUeUrywiNylGnSJX8zjSJbsyzaAwif5LLf1jIgEJiGLsAmgabzbUxhSjb1amLLWogiHAkGQo6tlkDbuGfMyxu6ITqwrPlGIPRRq4IYxa1d)bYcO2A)3lGcJ0qFw)bYcOeIgdo9zXowiKA)3zXtywCwG(EtxnrKfqYc0sZIT73zzlhX9NfcLJS4jmlLhS1sZcOzb6794AKfWVJTTJIfqd99yFEb0zSGb1zrrJALExtKWplttSGb1zrrZLvkq5nlttSGb1zrrZLvDWVZY0elyqDwu04z0AIe(zzolAzXQrigYm2A)3zrllrYIvJqm2zS1(Vx8fBXUIsxaftxxHWfLVaQh(dKfqPV3JRXcOH(ESpVa6mwMXsKS0RehGMiA0DLNbScgvxPQ)(LePgmDDfcZY0elrYsaabtpFtEe3)6WrwMMyjswOwOsvFVjIp1qFVhUsXI9SqglttSejlVRW8nP)RgPvDx5zany66keML5SmnXYmwWG6SOOHcuExtKWplttSGb1zrrZLv1k9MLPjwWG6SOO5YQo43zzAIfmOolkA8mAnrc)SmNL5SOLLizHIFvhKlQ5pSTtZR2zfkGQUeRb4cOAS4l2selkDbumDDfcxu(cOE4pqwaL(EtxnrSaAOVh7ZlGoJLEL4a0erJUR8mGvWO6kv93VKi1GPRRqyw0YsaabtpFtEe3)6Wrw0Yc1cvQ67nr8Pg679WvkwSNfYyzolAzjswO4x1b5IA(dB708QDwHcOQlXAaUaQgl(IVakmo8L6lkDXwiRO0fq9WFGSakfO8UQJECbumDDfcxu(IVyl2vu6cOy66keUO8fqd99yFEb0)IrwiilZyXowkflE4pqAS1(VBco9R)fJSqaw8WFG0qFVhxJMGt)6FXilZlGs)(cFXwiRaQh(dKfqdUsv9WFGSQo6xavD0VMEmwafyHj2fFXwIyrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfqPwOsvFVjIp1qFVhUsXszSqglAzzglrYY7kmFd99wbAydMUUcHzzAIL3vy(g6JkL3v4(gVbtxxHWSmNLPjwOwOsvFVjIp1qFVhUsXszSyxbuyKg6Z6pqwafk(uw2kGCybKSercWIT73bRNf4(gplEcZIT73zb67Tc0WS4jml2rawa)o22okwafI310JXcOhT6aS4l2cPxu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwybuQfQu13BI4tn037X1ilLXczfqHrAOpR)azbuO4tzjOqhcYITDmzb6794AKLGNSSFpl2rawEVjIpLfB7xyNLJYsJkeINpldqZYVJSqob1zrrwEal6ilwnoWUryw8eMfB7xyNLXPuyZYdyj40VakeVRPhJfqpAnOqhcw8fBrJfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4Qfwa1QrivIbydzMyaihxJSmnXIvJqQedWgYm0voUgzzAIfRgHujgGnKzOV30vtezzAIfRgHujgGnKzOV3dxPyzAIfRgHujgGnKzgRoAfmQOALilttSy1iet7qWeSO1rJzjIYY0el6RXWe86LbtJX(LuwSNf91yycE9YGbE1(FGKLPjwG4956k0C0QdWcOWin0N1FGSaAjvVpxxHS87(ZsyhdKqz5gSefSyXBKLlzXzHyaMLhWIdbCWS87il07x(FGKfB7yJS4S89LKGpl4hy5OSSOimlxYIo(2qmzj40NwafI310JXcOxwjgGl(ITqEkkDbumDDfcxu(cOE4pqwavhBk2KCjXcOWin0N1FGSaA5srwkp2uSj5sIS4pl)oYcMWSagSqOAmlruwSTJjl7o9rwoklUoacYc5ztnJMyXhp2SqkqcbqcYIT73zP8aV0S4jmlGFhBBhfzX297SqQTQHYjdfqd99yFEb0zSmJLizjaGGPNVjpI7FD4ilttSejlbaqbdSLMaiHaibR)owPwxFp1SSyzAILizPxjoanr0O7kpdyfmQUsv)9ljsny66keML5SOLf91yycE9YGPXy)sklLXczAKfTSOVgdt7qWeSO1rJzjIAAm2VKYcbzH0zrllrYsaabtpFdem)9OnlttSeaqW0Z3abZFpAZIww0xJHj41ldMLflAzrFngM2HGjyrRJgZse1SSyrllZyrFngM2HGjyrRJgZse10ySFjLfcAplKzhlralKolLILEL4a0erd9YXsv3JsFSp3GPRRqywMMyrFngMGxVmyAm2VKYcbzHmYyzAIfYyrdSqTqLQU70hzHGSqMH8WYCwMZIwwG4956k0CzLyaU4l2cHUO0fqX01viCr5lGg67X(8cOZyrFngMGxVmyAm2VKYszSqMgzrllZyjsw6vIdqten0lhlvDpk9X(CdMUUcHzzAIf91yyAhcMGfToAmlrutJX(LuwiilKvsyrll6RXW0oemblAD0ywIOMLflZzzAIfDaLYIwwghX9V2ySFjLfcYIDAKL5SOLfiEFUUcnxwjgGlGcJ0qFw)bYcOecWZIT73zXzHuBvdLtgy539NLJMB)S4SqiwkQ3Sy1GalGMfB7yYYVJSmoI7plhLfxhSEwEalycxa1d)bYcOwG)azXxSfnVO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOb8uSmJLzSmoI7FTXy)sklralKPrwIawcaGcgylnbVEzW0ySFjLL5SObwitZ3KL5Suglb8uSmJLzSmoI7FTXy)sklralKPrwIawcaGcgylnbqcbqcw)DSsTU(EQPXy)sklZzrdSqMMVjlZzrllrYs7hCfHG5BCyyQbj8rFklAzzglrYsaauWaBPj41ldMgD4OSmnXsKSeaafmWwAcGecGeS(7yLAD99utJoCuwMZY0elbaqbdSLMGxVmyAm2VKYszSC5JTfq5pcxhhX9V2ySFjLLPjw6vIdqtenbuH0)CvLAD99udMUUcHzrllbaqbdSLMGxVmyAm2VKYszSeXnzzAILaaOGb2staKqaKG1FhRuRRVNAAm2VKYszSC5JTfq5pcxhhX9V2ySFjLLiGfY2KLPjwIKLaacME(M8iU)1HJfqHrAOpR)azbus5QWs5pszX2o(7yZYIEjrwifiHaibzjb2yX2PuS4kfWglrblwEal0)ukwco9z53rwOEmYIhdw5ZcyWcPajeajibi1w1q5Kbwco9PfqH4Dn9ySaAaKqaKGvyKgndfFXwkjfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaDglV3eX38xmwFqf(qwkJfY0ilttS0(bxriy(ghgMAUKLYyrJBYYCw0YYmwMXcgHRZYcHnySv0gDvf0WPNbKfTSmJLizjaGGPNVbcM)E0MLPjwcaGcgylnySv0gDvf0WPNb00ySFjLfcYczKhcnleGLzSOrwkfl9kXbOjIg6LJLQUhL(yFUbtxxHWSmNL5SOLLizjaakyGT0GXwrB0vvqdNEgqtJoCuwMZY0elyeUolle2qblLc))sI1EPhLfTSmJLizjaGGPNVjpI7FD4ilttSeaafmWwAOGLsH)FjXAV0JwJiPRrnFtYmng7xszHGSqgzKolZzzAILzSeaafmWwA0XMInjxs00OdhLLPjwIKL2dO5BGsXY0elbaem98n5rC)RdhzzolAzzglrYY7kmFZy1rRGrfvReny66keMLPjwcaiy65BGG5VhTzrllbaqbdSLMXQJwbJkQwjAAm2VKYcbzHmYyHaSOrwkfl9kXbOjIg6LJLQUhL(yFUbtxxHWSmnXsKSeaqW0Z3abZFpAZIwwcaGcgylnJvhTcgvuTs00ySFjLfcYI(AmmbVEzWaVA)pqYcbyHm7yPuS0RehGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSebSqMDSmNfTSmJfmcxNLfcBUKg6176kSgHlp)vCfgHCbKfTSeaafmWwAUKg6176kSgHlp)vCfgHCb00ySFjLfcYIgzzolttSmJLzSGr46SSqydD3Hb2q4kO1RGr9bDmMplAzjaakyGT08GogZhHRxspI7FnIAuJr0oYmng7xszzolttSmJLzSaX7Z1vObK1ffRFFjj4ZI9SqglttSaX7Z1vObK1ffRFFjj4ZI9SerwMZIwwMXY3xsc(MNmtJoC0AaauWaBjlttS89LKGV5jZeaafmWwAAm2VKYszSC5JTfq5pcxhhX9V2ySFjLLiGfY2KL5SmnXceVpxxHgqwxuS(9LKGpl2ZIDSOLLzS89LKGV5TZ0OdhTgaafmWwYY0elFFjj4BE7mbaqbdSLMgJ9lPSuglx(yBbu(JW1XrC)Rng7xszjcyHSnzzolttSaX7Z1vObK1ffRFFjj4ZI9SSjlZzzolZlGcJ0qFw)bYcOLlfHz5bSaJkpkl)oYYI6erwadwi1w1q5KbwSTJjll6LezbgS0vilGKLffzXtywSAecMpllQtezX2oMS4jlommliemFwoklUoy9S8awGpSakeVRPhJfqdW1aiHV)azXxSfY2SO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOrYcfSu6xcB(9(uQkfrsW2GPRRqywMMyzCe3)AJX(LuwkJf72CtwMMyrhqPSOLLXrC)Rng7xszHGSyNgzHaSmJfsFtwIaw0xJH537tPQuejbBd99ajSukwSJL5SmnXI(Amm)EFkvLIijyBOVhiHLYyjIAolralZyPxjoanr0qVCSu19O0h7Zny66keMLsXIDSmVakmsd9z9hilGws17Z1villkcZYdybgvEuw8mklFFjj4tzXtywcWuwSTJjl287VKildqZINSqolRDqFolwniuafI310JXcO)EFkvLIijyxT53x8fBHmYkkDbumDDfcxu(cOWin0N1FGSaA5srwiNyROn6kwiKB40ZaYIDBsXaLfDCaAKfNfsTvnuozGLffzb0SqbS87(ZY9Sy7ukwuxISSSyX297S87ilycZcyWcHQXSerlGMEmwafJTI2ORQGgo9mGfqd99yFEb0aaOGb2stWRxgmng7xszHGSy3MSOLLaaOGb2staKqaKG1FhRuRRVNAAm2VKYcbzXUnzrllZybI3NRRqZV3NsvPisc2vB(9SmnXI(Amm)EFkvLIijyBOVhiHLYyjIBYcbyzgl9kXbOjIg6LJLQUhL(yFUbtxxHWSukwIilZzzolAzbI3NRRqZLvIbywMMyrhqPSOLLXrC)Rng7xszHGSercDbup8hilGIXwrB0vvqdNEgWIVylKzxrPlGIPRRq4IYxafgPH(S(dKfqlxkYcuWsPW)sISusV0JYc5HIbkl64a0ilolKARAOCYallkYcOzHcy539NL7zX2PuSOUezzzXIT73z53rwWeMfWGfcvJzjIwan9ySakfSuk8)ljw7LE0cOH(ESpVa6mwcaGcgylnbVEzW0ySFjLfcYc5HfTSejlbaem98nqW83J2SOLLizjaGGPNVjpI7FD4ilttSeaqW0Z3KhX9VoCKfTSeaafmWwAcGecGeS(7yLAD99utJX(LuwiilKhw0YYmwG4956k0eajeajyfgPrZalttSeaafmWwAcE9YGPXy)skleKfYdlZzzAILaacME(giy(7rBw0YYmwIKLEL4a0erd9YXsv3JsFSp3GPRRqyw0YsaauWaBPj41ldMgJ9lPSqqwipSmnXI(AmmTdbtWIwhnMLiQPXy)skleKfY2KfcWYmw0ilLIfmcxNLfcBUK(9k8GMwHpixIvDuPyzolAzrFngM2HGjyrRJgZse1SSyzolttSOdOuw0YY4iU)1gJ9lPSqqwStJSmnXcgHRZYcHnySv0gDvf0WPNbKfTSeaafmWwAWyROn6QkOHtpdOPXy)sklLXIDBYYCw0YceVpxxHMlRedWSOLLizbJW1zzHWMlPHE9UUcRr4YZFfxHrixazzAILaaOGb2sZL0qVExxH1iC55VIRWiKlGMgJ9lPSugl2TjlttSOdOuw0YY4iU)1gJ9lPSqqwSBZcOE4pqwaLcwkf()LeR9spAXxSfYIyrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfq1xJHj41ldMgJ9lPSuglKPrw0YYmwIKLEL4a0erd9YXsv3JsFSp3GPRRqywMMyrFngM2HGjyrRJgZse10ySFjLfcAplKPrJgzHaSmJLiA0ilLIf91yy0vaaSArFZYIL5SqawMXcPB0ilralr0Orwkfl6RXWORaay1I(MLflZzPuSGr46SSqyZL0VxHh00k8b5sSQJkfleGfs3OrwkflZybJW1zzHWMFhRJRPFLEepflAzjaakyGT087yDCn9R0J4Pmng7xszHG2ZIDBYYCw0YI(AmmTdbtWIwhnMLiQzzXYCwMMyrhqPSOLLXrC)Rng7xszHGSyNgzzAIfmcxNLfcBWyROn6QkOHtpdilAzjaakyGT0GXwrB0vvqdNEgqtJX(L0cOWin0N1FGSa6wv28OuwwuKLYrZgKxwSD)olKARAOCYalGMf)z53rwWeMfWGfcvJzjIwafI310JXcOxecxdGe((dKfFXwiJ0lkDbumDDfcxu(cOE4pqwa9sAOxVRRWAeU88xXvyeYfWcOH(ESpVakeVpxxHMlcHRbqcF)bsw0YceVpxxHMlRedWfqtpglGEjn0R31vyncxE(R4kmc5cyXxSfY0yrPlGIPRRq4IYxafgPH(S(dKfqlxkYc0DhgydHzHqU1zrhhGgzHuBvdLtgkGMEmwaLU7WaBiCf06vWO(GogZVaAOVh7ZlGoJLaaOGb2stWRxgmn6WrzrllrYsaabtpFtEe3)6Wrw0YceVpxxHMFVpLQsrKeSR287zrllZyjaakyGT0OJnfBsUKOPrhoklttSejlThqZ3aLIL5SmnXsaabtpFtEe3)6Wrw0YsaauWaBPjasiasW6VJvQ113tnn6WrzrllZybI3NRRqtaKqaKGvyKgndSmnXsaauWaBPj41ldMgD4OSmNL5SOLfyWBORCCnA(lqYLezrllZybg8g6JkL31HYB08xGKljYY0elrYY7kmFd9rLY76q5nAW01vimlttSqTqLQ(EteFQH(EpUgzPmwIilZzrllWG3eda54A08xGKljYIwwMXceVpxxHMJwDaYY0el9kXbOjIgDx5zaRGr1vQ6VFjrQbtxxHWSmnXIt)2vvlGnSzPm7zPKSjlttSaX7Z1vOjasiasWkmsJMbwMMyrFnggDfaaRw03SSyzolAzjswWiCDwwiS5sAOxVRRWAeU88xXvyeYfqwMMybJW1zzHWMlPHE9UUcRr4YZFfxHrixazrllbaqbdSLMlPHE9UUcRr4YZFfxHrixanng7xszPmwI4MSOLLizrFngMGxVmywwSmnXIoGszrllJJ4(xBm2VKYcbzH03SaQh(dKfqP7omWgcxbTEfmQpOJX8l(ITqg5PO0fqX01viCr5lGcJ0qFw)bYcOLE)OSCuwCwA)3XMfu56G2FKfBEuwEalXojilUsXcizzrrwOV)S89LKGpLLhWIoYI6seMLLfl2UFNfsTvnuozGfpHzHuGecGeKfpHzzrrw(DKf7sywOkWZcizjaZYnyrh87S89LKGpLfVrwajllkYc99NLVVKe8Pfqd99yFEbuiEFUUcnGSUOy97ljbFwI0EwiJfTSejlFFjj4BE7mn6WrRbaqbdSLSmnXYmwG4956k0aY6II1VVKe8zXEwiJLPjwG4956k0aY6II1VVKe8zXEwIilZzrllZyrFngMGxVmywwSOLLaacME(giy(7rBw0YYmw0xJHPDiycw06OXSernng7xszHaSmJLiA0ilLILEL4a0erd9YXsv3JsFSp3GPRRqywMZcbTNLVVKe8npzg91yuHxT)hizrll6RXW0oemblAD0ywIOMLflttSOVgdt7qWeSO1rJzjIwPxowQ6Eu6J95MLflZzzAILaaOGb2stWRxgmng7xszHaSyhlLXY3xsc(MNmtaauWaBPbE1(FGKfTSmJLizPxjoanr0y1xmOHpxv9o45fQwlf1BdMUUcHzzAIf91yycE9YGPXy)sklLXc5HL5SOLLzSejlbaem98n5rC)RdhzzAILVVKe8npzMaaOGb2sd8Q9)ajlLXsaauWaBPjasiasW6VJvQ113tnng7xszzAIfiEFUUcnbqcbqcwHrA0mWIww((ssW38KzcaGcgylnWR2)dKSuglbaqbdSLMGxVmyAm2VKYYCw0YsKSeaqW0Z3qs0(8KLPjwcaiy65BYJ4(xhoYIwwG4956k0eajeajyfgPrZalAzjaakyGT0eajeajy93Xk1667PMLflAzjswcaGcgylnbVEzWSSyrllZyzgl6RXWGb1zrXQALEBAm2VKYszSOrwMMyrFnggmOolkwPaL3MgJ9lPSuglAKL5SmNLPjw0xJHHKlHBeUIXwaByhJ5xXeBIxjqZYIL5SmnXY4iU)1gJ9lPSqqwSBtwMMybI3NRRqdiRlkw)(ssWNf7zzZcOuf4Pfq)(ssWNScOE4pqwa97ljbFYk(ITqgHUO0fqX01viCr5lG6H)azb0VVKe8TRaAOVh7ZlGcX7Z1vObK1ffRFFjj4ZsK2ZIDSOLLiz57ljbFZtMPrhoAnaakyGTKLPjwG4956k0aY6II1VVKe8zXEwSJfTSmJf91yycE9YGzzXIwwcaiy65BGG5VhTzrllZyrFngM2HGjyrRJgZse10ySFjLfcWYmwIOrJSukw6vIdqten0lhlvDpk9X(CdMUUcHzzole0Ew((ssW382z0xJrfE1(FGKfTSOVgdt7qWeSO1rJzjIAwwSmnXI(AmmTdbtWIwhnMLiALE5yPQ7rPp2NBwwSmNLPjwcaGcgylnbVEzW0ySFjLfcWIDSuglFFjj4BE7mbaqbdSLg4v7)bsw0YYmwIKLEL4a0erJvFXGg(Cv17GNxOATuuVny66keMLPjw0xJHj41ldMgJ9lPSuglKhwMZIwwMXsKSeaqW0Z3KhX9VoCKLPjw((ssW382zcaGcgylnWR2)dKSuglbaqbdSLMaiHaibR)owPwxFp10ySFjLLPjwG4956k0eajeajyfgPrZalAz57ljbFZBNjaakyGT0aVA)pqYszSeaafmWwAcE9YGPXy)sklZzrllrYsaabtpFdjr7Ztw0YYmwIKf91yycE9YGzzXY0elrYsaabtpFdem)9OnlZzzAILaacME(M8iU)1HJSOLfiEFUUcnbqcbqcwHrA0mWIwwcaGcgylnbqcbqcw)DSsTU(EQzzXIwwIKLaaOGb2stWRxgmllw0YYmwMXI(AmmyqDwuSQwP3MgJ9lPSuglAKLPjw0xJHbdQZIIvkq5TPXy)sklLXIgzzolZzzolttSOVgddjxc3iCfJTa2WogZVIj2eVsGMLflttSmoI7FTXy)skleKf72KLPjwG4956k0aY6II1VVKe8zXEw2SakvbEAb0VVKe8TR4l2czAErPlGIPRRq4IYxafgPH(S(dKfqlxkszXvkwa)o2SaswwuKL7XyklGKLaCbup8hilGUOy9EmMw8fBHSssrPlGIPRRq4IYxafgPH(S(dKfqjN73XMfIawU8bS87il0NfqZIdqw8WFGKf1r)cOE4pqwaTxz1d)bYQ6OFbu63x4l2czfqd99yFEbuiEFUUcnhT6aSaQ6OFn9ySaQdWIVyl2TzrPlGIPRRq4IYxa1d)bYcO9kRE4pqwvh9lGQo6xtpglGs)IV4lGA1yaeR7FrPl2czfLUaQh(dKfqj5s4gHRuRRVNwaftxxHWfLV4l2IDfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaDZcOWin0N1FGSaAP3rwG4956kKLJYcfFwEalBYIT73zjbSqF)zbKSSOilFFjj4t1elKXITDmz53rwgxtFwajYYrzbKSSOOMyXowUbl)oYcfdGeMLJYINWSerwUbl6GFNfVXcOq8UMEmwafK1ffRFFjj4x8fBjIfLUakMUUcHlkFbuGvbuhgUaQh(dKfqH4956kSakexTWcOKvan03J95fq)(ssW38Kz2DADrXQ(AmyrllFFjj4BEYmbaqbdSLg4v7)bsw0YsKS89LKGV5jZCuZdIXkyuJbj9BWIwdGK(9k8hiPfqH4Dn9ySakiRlkw)(ssWV4l2cPxu6cOy66keUO8fqbwfqDy4cOE4pqwafI3NRRWcOqC1clGAxb0qFp2Nxa97ljbFZBNz3P1ffR6RXGfTS89LKGV5TZeaafmWwAGxT)hizrllrYY3xsc(M3oZrnpigRGrngK0VblAnas63RWFGKwafI310JXcOGSUOy97ljb)IVylASO0fqX01viCr5lGcSkG6WWfq9WFGSakeVpxxHfqH4Dn9ySakiRlkw)(ssWVaAOVh7ZlGIr46SSqyZL0qVExxH1iC55VIRWiKlGSmnXcgHRZYcHnySv0gDvf0WPNbKLPjwWiCDwwiSHcwkf()LeR9spAbuyKg6Z6pqwaT07ifz57ljbFklEJSKGNfF9Gy)VGRurzbgFm8imloLfqYYIISqF)z57ljbFQHfwGIplq8(CDfYYdyH0zXPS87yuwCffWsIimlulmCUILDpHvxs0uafIRwybusV4l2c5PO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOrCtwkflZyHmwIaw20qMgzPuSqXVQdYf18h22P5vs3kWY8cOWin0N1FGSaku8PS87ilqFVPRMiYsaqFwgGMfL)yZsWvHLY)dKuwMnanliH9ylfYITDmz5bSqFVFwGxXwxsKfDCaAKfcvJzjIYYWvkklGXyEbuiExtpglGsP1aG(fFXwi0fLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwavJBYsPyzglKXseWYMgY0ilLIfk(vDqUOM)W2onVs6wbwMxafI310JXcO0rnaOFXxSfnVO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcOrCtwialKTjlLILEL4a0ertavi9pxvPwxFp1GPRRq4cOWin0N1FGSaku8PS4pl22VWolEmyLplGblBLsiyHuGecGeKf6oyPGzrhzzrr4sMfsFtwSD)oy9SqkuH0)CflqTU(EklEcZse3KfB3VBkGcX7A6Xyb0aiHaibRo1Q4l2sjPO0fq9WFGSaAmaKKCzDa64cOy66keUO8fFXwiBZIsxaftxxHWfLVaQh(dKfqT1(Vxan03J95fqNXcguNffnQv6Dnrc)SmnXcguNffnxwPaL3SmnXcguNffnxw1b)olttSGb1zrrJNrRjs4NL5fqvxI1aCbuY2S4l(cOoalkDXwiRO0fqX01viCr5lGcSkGsXVaQh(dKfqH4956kSakexTWcO9kXbOjIM)IrBGoRWn6X6xcJTbtxxHWSOLLzSOVgdZFXOnqNv4g9y9lHX20ySFjLfcYcXaSj2jmleGLnnKXY0el6RXW8xmAd0zfUrpw)sySnng7xszHGS4H)aPH(EpUgniHXW6X6FXileGLnnKXIwwMXcguNffnxwvR0BwMMybdQZIIgkq5Dnrc)SmnXcguNffnEgTMiHFwMZYCw0YI(Amm)fJ2aDwHB0J1VegBZYQakmsd9z9hilGskxfwk)rkl22XFhBw(DKfYBJECW)Wo2SOVgdwSDkfldxPybmgSy7(9lz53rwsKWplbN(fqH4Dn9ySakCJEC12Pu1HRuvWyu8fBXUIsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGgjlyqDwu0CzLcuEZIwwOwOsvFVjIp1qFVhxJSugleAwIawExH5BOGLQcg1FhRdqJ03GPRRqywkfl2XcbybdQZIIMlR6GFNfTSejl9kXbOjIgR(Ibn85QQ3bpVq1APOEBW01vimlAzjsw6vIdqtenGe)DAnOqVRqo6bsdMUUcHlGcJ0qFw)bYcOKYvHLYFKYITD83XMfOV30vtez5OSyd0)olbN(xsKfaeSzb6794AKLlzH8xP3Sqob1zrXcOq8UMEmwa9iMGgR03B6QjIfFXwIyrPlGIPRRq4IYxa1d)bYcObqcbqcw)DSsTU(EAbuyKg6Z6pqwaTCPilKcKqaKGSyBhtw8NffsPS87EYIg3KLTsjeS4jmlQlrwwwSy7(Dwi1w1q5KHcOH(ESpVa6mwMXceVpxxHMaiHaibRWinAgyrllrYsaauWaBPj41ldMgD4OSOLLizPxjoanr0y1xmOHpxv9o45fQwlf1BdMUUcHzzAIf91yycE9YGzzXIwwMXsKS0RehGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSmnXsVsCaAIOjGkK(NRQuRRVNAW01vimlttSmoI7FTXy)sklLXcz2rOzzAIfDaLYIwwghX9V2ySFjLfcYsaauWaBPj41ldMgJ9lPSqawiBtwMMyrFngMGxVmyAm2VKYszSqMDSmNL5SOLLzSmJLzS40VDv1cydBwiO9SaX7Z1vOjasiasWQtTyzAIfQfQu13BI4tn037X1ilLXsezzolAzzgl6RXWGb1zrXQALEBAm2VKYszSq2MSmnXI(AmmyqDwuSsbkVnng7xszPmwiBtwMZY0el6RXWe86LbtJX(LuwkJfnYIww0xJHj41ldMgJ9lPSqq7zHm7yzolAzzglrYY7kmFd9rLY7kCFJ3GPRRqywMMyrFngg679WvktJX(LuwiilKz0ilralBA0ilLILEL4a0ertavi9pxvPwxFp1GPRRqywMMyrFngMGxVmyAm2VKYcbzrFngg679WvktJX(LuwialAKfTSOVgdtWRxgmllwMZIwwMXsKS0RehGMiA(lgTb6Sc3OhRFjm2gmDDfcZY0elrYsVsCaAIOjGkK(NRQuRRVNAW01vimlttSOVgdZFXOnqNv4g9y9lHX20ySFjLLYybjmgwpw)lgzzolttS0RehGMiA0DLNbScgvxPQ)(LePgmDDfcZYCw0YYmwIKLEL4a0erJUR8mGvWO6kv93VKi1GPRRqywMMyzgl6RXWO7kpdyfmQUsv)9ljsRP)Rgn03dKWI9SO5SmnXI(Amm6UYZawbJQRu1F)sI0Q3bprd99ajSyplAolZzzolttSOdOuw0YY4iU)1gJ9lPSqqwiBtw0YsKSeaafmWwAcE9YGPrhoklZl(ITq6fLUakMUUcHlkFbup8hilGsx54ASaAiAqH13BI4tl2czfqd99yFEb0zS04Or6URRqwMMyrFnggmOolkwPaL3MgJ9lPSqqwIilAzbdQZIIMlRuGYBw0YsJX(LuwiilKr6SOLL3vy(gkyPQGr93X6a0i9ny66keML5SOLL3BI4B(lgRpOcFilLXczKolraluluPQV3eXNYcbyPXy)sklAzzglyqDwu0Cz1ZOSmnXsJX(LuwiiledWMyNWSmVakmsd9z9hilGwUuKfORCCnYYLSy5jmgFbwajlEg93VKil)U)SOoiiLfYiDkgOS4jmlkKszX297SedAKL3BI4tzXtyw8NLFhzbtywadwCwGcuEZc5euNffzXFwiJ0zHIbklGMffsPS0ySF5LezXPS8awsWZYUd5sIS8awAC0iDNf4vFjrwi)v6nlKtqDwuS4l2IglkDbumDDfcxu(cOE4pqwaLUYX1ybuyKg6Z6pqwaTCPilqx54AKLhWYUdbzXzHOcO7kwEallkYs5OzdYBb0qFp2NxafI3NRRqZfHW1aiHV)ajlAzjaakyGT0Cjn0R31vyncxE(R4kmc5cOPrhoklAzbJW1zzHWMlPHE9UUcRr4YZFfxHrixazrllUvnSJbsk(ITqEkkDbumDDfcxu(cOE4pqwaL(EpCLQakmsd9z9hilGwsbrlwwwSa99E4kfl(ZIRuS8xmszzLkKszzrVKilKF0G3oLfpHz5EwoklUoy9S8awSAqGfqZIcFw(DKfQfgoxXIh(dKSOUezrhvaBSS7jSczH82OhRFjm2SaswSJL3BI4tlGg67X(8cOrYY7kmFd9rLY7kCFJ3GPRRqyw0YYmwIKfk(vDqUOM)W2onVs6wbwMMybdQZIIMlREgLLPjwOwOsvFVjIp1qFVhUsXszSerwMZIwwMXI(Amm037HRuMghns3DDfYIwwMXc1cvQ67nr8Pg679WvkwiilrKLPjwIKLEL4a0erZFXOnqNv4g9y9lHX2GPRRqywMZY0elVRW8nuWsvbJ6VJ1bOr6BW01vimlAzrFnggmOolkwPaL3MgJ9lPSqqwIilAzbdQZIIMlRuGYBw0YI(Amm037HRuMgJ9lPSqqwi0SOLfQfQu13BI4tn037HRuSuM9Sq6SmNfTSmJLizPxjoanr0OIg82P1HcX)sIvIQl2IIgmDDfcZY0el)fJSOzyH01ilLXI(Amm037HRuMgJ9lPSqawSJL5SOLL3BI4B(lgRpOcFilLXIgl(ITqOlkDbumDDfcxu(cOE4pqwaL(EpCLQakmsd9z9hilGsiD)olqFuP8MfYBFJNLffzbKSeGzX2oMS04Or6URRqw0xpl0)ukwS53ZYa0Sq(rdE7uwSAqGfpHzbgKB)SSOil64a0ilKI8snSa9pLILffzrhhGgzHuGecGeKf6LbKLF3FwSDkflwniWINGFhBwG(EpCLQaAOVh7ZlG(UcZ3qFuP8Uc334ny66keMfTSOVgdd99E4kLPXrJ0DxxHSOLLzSejlu8R6GCrn)HTDAEL0TcSmnXcguNffnxw9mklttSqTqLQ(EteFQH(EpCLILYyjISmNfTSmJLizPxjoanr0OIg82P1HcX)sIvIQl2IIgmDDfcZY0el)fJSOzyH01ilLXcPZYCw0YY4iU)1gJ9lPSuglrS4l2IMxu6cOy66keUO8fq9WFGSak99E4kvbuyKg6Z6pqwaLq6(DwiVn6X6xcJnllkYc037HRuS8awibrlwwwS87il6RXGf9OS4kkGLf9sISa99E4kflGKfnYcfdGeMYcOzrHuklng7xEjXcOH(ESpVaAVsCaAIO5Vy0gOZkCJES(LWyBW01vimlAzHAHkv99Mi(ud99E4kflLzplrKfTSmJLizrFngM)IrBGoRWn6X6xcJTzzXIww0xJHH(EpCLY04Or6URRqwMMyzglq8(CDfAGB0JR2oLQoCLQcgdw0YYmw0xJHH(EpCLY0ySFjLfcYsezzAIfQfQu13BI4tn037HRuSugl2XIwwExH5BOpQuExH7B8gmDDfcZIww0xJHH(EpCLY0ySFjLfcYIgzzolZzzEXxSLssrPlGIPRRq4IYxafyvaLIFbup8hilGcX7Z1vybuiUAHfqD63UQAbSHnlLXIMVjlLILzSqglralu8R6GCrn)HTDAE1oRalLILnn2XYCwkflZyHmwIaw0xJH5Vy0gOZkCJES(LWyBOVhiHLsXYMgYyzolralZyrFngg679WvktJX(LuwkflrKfnWc1cvQ6UtFKLsXsKS8UcZ3qFuP8Uc334ny66keML5SebSmJLaaOGb2sd99E4kLPXy)sklLILiYIgyHAHkvD3PpYsPy5DfMVH(Os5DfUVXBW01vimlZzjcyzgl6RXWmwD0kyur1krtJX(LuwkflAKL5SOLLzSOVgdd99E4kLzzXY0elbaqbdSLg679WvktJX(LuwMxafgPH(S(dKfqjLRclL)iLfB74VJnlolqFVPRMiYYIISy7ukwc(IISa99E4kflpGLHRuSagdnXINWSSOilqFVPRMiYYdyHeeTyH82OhRFjm2SqFpqcllldlA(MSCuw(DKLgJW11imlBLsiy5bSeC6Zc03B6QjIea679WvQcOq8UMEmwaL(EpCLQAdKFD4kvfmgfFXwiBZIsxaftxxHWfLVaQh(dKfqPV30vtelGcJ0qFw)bYcOLlfzb67nD1erwSD)olK3g9y9lHXMLhWcjiAXYYILFhzrFngSy7(DW6zrbOxsKfOV3dxPyzz9xmYINWSSOilqFVPRMiYcizH0jalLhS1sZc99ajuww5FkwiDwEVjIpTaAOVh7ZlGcX7Z1vObUrpUA7uQ6WvQkymyrllq8(CDfAOV3dxPQ2a5xhUsvbJblAzjswG4956k0CetqJv67nD1erwMMyzgl6RXWO7kpdyfmQUsv)9ljsRP)Rgn03dKWszSerwMMyrFnggDx5zaRGr1vQ6VFjrA17GNOH(EGewkJLiYYCw0Yc1cvQ67nr8Pg679WvkwiilKolAzbI3NRRqd99E4kv1gi)6WvQkymk(ITqgzfLUakMUUcHlkFbup8hilG6WU1FqWk1M3XfqdrdkS(EteFAXwiRaAOVh7ZlGgjl)fi5sISOLLizXd)bsJd7w)bbRuBEhxH9yNiAUSouhX9NLPjwGbVXHDR)GGvQnVJRWESten03dKWcbzjISOLfyWBCy36piyLAZ74kSh7ertJX(LuwiilrSakmsd9z9hilGwUuKfQnVJzHcy539NLOGfleXNLyNWSSS(lgzrpkll6Lez5EwCklk)rwCklwak90vilGKffsPS87EYsezH(EGeklGMfn7w0NfB7yYsejal03dKqzbjS11yXxSfYSRO0fqX01viCr5lG6H)azb0yaihxJfqdrdkS(EteFAXwiRaAOVh7ZlG24Or6URRqw0YY7nr8n)fJ1huHpKLYyzglZyHmsNfcWYmwOwOsvFVjIp1qFVhxJSukwSJLsXI(AmmyqDwuSQwP3MLflZzzoleGLgJ9lPSmNfnWYmwiJfcWY7kmFZB7YAmaKudMUUcHzzolAzXPF7QQfWg2Suglq8(CDfAOJAaqFwIaw0xJHH(EpCLY0ySFjLLsXc5HfTSmJf3Qg2XajSmnXceVpxxHMJycASsFVPRMiYY0elrYcguNffnxw9mklZzrllZyjaakyGT0e86LbtJoCuw0YcguNffnxw9mklAzzglq8(CDfAcGecGeScJ0OzGLPjwcaGcgylnbqcbqcw)DSsTU(EQPrhoklttSejlbaem98n5rC)RdhzzolttSqTqLQ(EteFQH(EpUgzHGSmJLzSO5SebSmJf91yyWG6SOyvTsVnllwkflrKL5SmNLsXYmwiJfcWY7kmFZB7YAmaKudMUUcHzzolZzrllrYcguNffnuGY7AIe(zrllZyjswcaGcgylnbVEzW0OdhLL5SmnXYmwWG6SOO5YkfO8MLPjw0xJHbdQZIIv1k92SSyrllrYY7kmFdfSuvWO(7yDaAK(gmDDfcZYCw0YYmwOwOsvFVjIp1qFVhxJSqqwiBtwkflZyHmwialVRW8nVTlRXaqsny66keML5SmNL5SOLLzSejlbaem98nKeTppzzAILizrFnggsUeUr4kgBbSHDmMFftSjELanllwMMybdQZIIMlRuGYBwMZIwwIKf91yyAhcMGfToAmlr0k9YXsv3JsFSp3SSkGcJ0qFw)bYcOL04Or6olAwaqoUgz5gSqQTQHYjdSCuwA0HJQjw(DSrw8gzrHukl)UNSOrwEVjIpLLlzH8xP3Sqob1zrrwSD)olqbpHstSOqkLLF3twiBtwa)o22okYYLS4zuwiNG6SOilGMLLflpGfnYY7nr8PSOJdqJS4Sq(R0BwiNG6SOOHfYli3(zPXrJ0DwGx9LezPKYLWncZc5eBbSHDmMplRuHuklxYcuGYBwiNG6SOyXxSfYIyrPlGIPRRq4IYxa1d)bYcOdqhWkyut)xnwafgPH(S(dKfqlxkYcHcSfwajlbywSD)oy9SeClRljwan03J95fqDRAyhdKWY0elq8(CDfAoIjOXk99MUAIyXxSfYi9IsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGoJfiEFUUcnb4AaKW3FGKfTSmJf91yyOV3dxPmllwMMy5DfMVH(Os5DfUVXBW01vimlttSeaqW0Z3KhX9VoCKL5SOLfyWBIbGCCnA(lqYLezrllZyjsw0xJHHcu0)cOzzXIwwIKf91yycE9YGzzXIwwMXsKS8UcZ3mwD0kyur1krdMUUcHzzAIf91yycE9YGbE1(FGKLYyjaakyGT0mwD0kyur1krtJX(LuwialAolZzrllZyjswO4x1b5IA(dB708QDwbwMMybdQZIIMlRQv6nlttSGb1zrrdfO8UMiHFwMZIwwG4956k0879PuvkIKGD1MFplAzzglrYsaabtpFtEe3)6WrwMMybI3NRRqtaKqaKGvyKgndSmnXsaauWaBPjasiasW6VJvQ113tnng7xszHGSqMgzzolAz59Mi(M)IX6dQWhYszSOVgdtWRxgmWR2)dKSukw20qOzzolttSOdOuw0YY4iU)1gJ9lPSqqw0xJHj41ldg4v7)bswialKzhlLILEL4a0erJvFXGg(Cv17GNxOATuuVny66keML5fqH4Dn9ySaAaUgaj89hiRoal(ITqMglkDbumDDfcxu(cOE4pqwaTDiycw06OXSerlGcJ0qFw)bYcOLlfzHq1ywIOSy7(Dwi1w1q5KHcOH(ESpVaQ(AmmbVEzW0ySFjLLYyHmnYY0el6RXWe86Lbd8Q9)ajleGfYSJLsXsVsCaAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZcbzXoYdlAzbI3NRRqtaUgaj89hiRoal(ITqg5PO0fqX01viCr5lG6H)azb0aQq6FUQ6QJygJ5xafgPH(S(dKfqlxkYcP2QgkNmWcizjaZYkviLYINWSOUez5EwwwSy7(DwifiHaiblGg67X(8cOq8(CDfAcW1aiHV)az1bilAzzglrYsaabtpFdem)9OnlttSejl9kXbOjIg6LJLQUhL(yFUbtxxHWSmnXsVsCaAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZY0el6RXWe86Lbd8Q9)ajlLzpl2rEyzolttSOVgdt7qWeSO1rJzjIAwwSOLf91yyAhcMGfToAmlrutJX(LuwiilKPrJgl(ITqgHUO0fqX01viCr5lGg67X(8cOq8(CDfAcW1aiHV)az1bybup8hilGEzW70)dKfFXwitZlkDbumDDfcxu(cOE4pqwafJTa2WUQds4cOWin0N1FGSaA5srwiNylGnSzP8GeMfqYsaMfB3VZc037HRuSSSyXtywOoeKLbOzHqSuuVzXtywi1w1q5KHcOH(ESpVa6mwcaGcgylnbVEzW0ySFjLfcWI(AmmbVEzWaVA)pqYcbyPxjoanr0y1xmOHpxv9o45fQwlf1BdMUUcHzPuSqMDSuglbaqbdSLgm2cyd7QoiHnWR2)dKSqawiBtwMZY0el6RXWe86LbtJX(LuwkJfnV4l2czLKIsxaftxxHWfLVaQh(dKfqPpQuExhkVXcOHObfwFVjIpTylKvan03J95fqBC0iD31vilAz5VyS(Gk8HSuglKPrw0Yc1cvQ67nr8Pg6794AKfcYcPZIwwCRAyhdKWIwwMXI(AmmbVEzW0ySFjLLYyHSnzzAILizrFngMGxVmywwSmVakmsd9z9hilGwsJJgP7SmuEJSaswwwS8awIilV3eXNYIT73bRNfsTvnuozGfD8sIS46G1ZYdybjS11ilEcZscEwaqWo4wwxsS4l2IDBwu6cOy66keUO8fq9WFGSa6y1rRGrfvRelGcJ0qFw)bYcOLlfzHqbihwUblxspyKfpzHCcQZIIS4jmlQlrwUNLLfl2UFNfNfcXsr9MfRgeyXtyw2kSB9heKfO28oUaAOVh7ZlGIb1zrrZLvpJYIwwMXIBvd7yGewMMyjsw6vIdqtenw9fdA4ZvvVdEEHQ1sr92GPRRqywMZIwwMXI(Ammw9fdA4ZvvVdEEHQ1sr92aXvlKfcYIDACtwMMyrFngMGxVmyAm2VKYszSO5SmNfTSmJfyWBCy36piyLAZ74kSh7erZFbsUKilttSejlbaem98njgAGc0WSmnXc1cvQ67nr8PSugl2XYCw0YYmw0xJHPDiycw06OXSernng7xszHGSusyjcyzglKolLILEL4a0erd9YXsv3JsFSp3GPRRqywMZIww0xJHPDiycw06OXSernllwMMyjsw0xJHPDiycw06OXSernllwMZIwwMXsKSeaafmWwAcE9YGzzXY0el6RXW879PuvkIKGTH(EGewiilKPrw0YY4iU)1gJ9lPSqqwSBZnzrllJJ4(xBm2VKYszSq2MBYY0elrYcfSu6xcB(9(uQkfrsW2GPRRqywMZIwwMXcfSu6xcB(9(uQkfrsW2GPRRqywMMyjaakyGT0e86LbtJX(LuwkJLiUjlZzrllV3eX38xmwFqf(qwkJfnYY0el6akLfTSmoI7FTXy)skleKfY2S4l2IDKvu6cOy66keUO8fq9WFGSak99E4kvbuyKg6Z6pqwaTCPilolqFVhUsXcHCI)olwniWYkviLYc037HRuSCuwCvJoCuwwwSaAwIcwS4nYIRdwplpGfaeSdUflBLsikGg67X(8cO6RXWas83PvlSdO1FG0SSyrllZyrFngg679WvktJJgP7UUczzAIfN(TRQwaByZszSus2KL5fFXwSZUIsxaftxxHWfLVaQh(dKfqPV3dxPkGcJ0qFw)bYcOK3vSflBLsiyrhhGgzHuGecGeKfB3VZc037HRuS4jml)oMSa99MUAIyb0qFp2NxanaGGPNVjpI7FD4ilAzjswExH5BOpQuExH7B8gmDDfcZIwwMXceVpxxHMaiHaibRWinAgyzAILaaOGb2stWRxgmllwMMyrFngMGxVmywwSmNfTSeaafmWwAcGecGeS(7yLAD99utJX(LuwiiledWMyNWSukwc4Pyzglo9BxvTa2WMfnWceVpxxHg6Oga0NL5SOLf91yyOV3dxPmng7xszHGSq6fFXwSlIfLUakMUUcHlkFb0qFp2NxanaGGPNVjpI7FD4ilAzzglq8(CDfAcGecGeScJ0OzGLPjwcaGcgylnbVEzWSSyzAIf91yycE9YGzzXYCw0YsaauWaBPjasiasW6VJvQ113tnng7xszHGSOrw0YceVpxxHg679WvQQnq(1HRuvWyWIwwWG6SOO5YQNrzrllrYceVpxxHMJycASsFVPRMiwa1d)bYcO03B6QjIfFXwSJ0lkDbumDDfcxu(cOE4pqwaL(EtxnrSakmsd9z9hilGwUuKfOV30vtezX297S4jleYj(7Sy1GalGMLBWsuWABywaqWo4wSSvkHGfB3VZsuWQzjrc)SeC6ByzRkkGf4vSflBLsiyXFw(DKfmHzbmy53rwkPI5VhTzrFngSCdwG(EpCLIfBGLco3(zz4kflGXGfqZsuWIfVrwajl2XY7nr8Pfqd99yFEbu91yyaj(70AqHExHC0dKMLflttSmJLizH(EpUgnUvnSJbsyrllrYceVpxxHMJycASsFVPRMiYY0elZyrFngMGxVmyAm2VKYcbzrJSOLf91yycE9YGzzXY0elZyzgl6RXWe86LbtJX(LuwiiledWMyNWSukwc4Pyzglo9BxvTa2WMfnWceVpxxHgkTga0NL5SOLf91yycE9YGzzXY0el6RXW0oemblAD0ywIOv6LJLQUhL(yFUPXy)skleKfIbytStywkflb8uSmJfN(TRQwaByZIgybI3NRRqdLwda6ZYCw0YI(AmmTdbtWIwhnMLiALE5yPQ7rPp2NBwwSmNfTSeaqW0Z3abZFpAZYCwMZIwwMXc1cvQ67nr8Pg679WvkwiilrKLPjwG4956k0qFVhUsvTbYVoCLQcgdwMZYCw0YsKSaX7Z1vO5iMGgR03B6QjISOLLzSejl9kXbOjIM)IrBGoRWn6X6xcJTbtxxHWSmnXc1cvQ67nr8Pg679WvkwiilrKL5fFXwStJfLUakMUUcHlkFbup8hilGMOTAmaKfqHrAOpR)azb0YLISOzbajLLlzbkq5nlKtqDwuKfpHzH6qqwiulLIfnlaizzaAwi1w1q5KHcOH(ESpVa6mw0xJHbdQZIIvkq5TPXy)sklLXcsymSES(xmYY0elZyjS7nrKYI9SyhlAzPXWU3eX6FXileKfnYYCwMMyjS7nrKYI9SerwMZIwwCRAyhdKu8fBXoYtrPlGIPRRq4IYxan03J95fqNXI(AmmyqDwuSsbkVnng7xszPmwqcJH1J1)IrwMMyzglHDVjIuwSNf7yrllng29Miw)lgzHGSOrwMZY0elHDVjIuwSNLiYYCw0YIBvd7yGew0YYmw0xJHPDiycw06OXSernng7xszHGSOrw0YI(AmmTdbtWIwhnMLiQzzXIwwIKLEL4a0erd9YXsv3JsFSp3GPRRqywMMyjsw0xJHPDiycw06OXSernllwMxa1d)bYcO7UAuJbGS4l2IDe6IsxaftxxHWfLVaAOVh7ZlGoJf91yyWG6SOyLcuEBAm2VKYszSGegdRhR)fJSOLLzSeaafmWwAcE9YGPXy)sklLXIg3KLPjwcaGcgylnbqcbqcw)DSsTU(EQPXy)sklLXIg3KL5SmnXYmwc7EtePSypl2XIwwAmS7nrS(xmYcbzrJSmNLPjwc7EtePSyplrKL5SOLf3Qg2XajSOLLzSOVgdt7qWeSO1rJzjIAAm2VKYcbzrJSOLf91yyAhcMGfToAmlruZYIfTSejl9kXbOjIg6LJLQUhL(yFUbtxxHWSmnXsKSOVgdt7qWeSO1rJzjIAwwSmVaQh(dKfqhlLQgdazXxSf708IsxaftxxHWfLVakmsd9z9hilGwUuKfcja5WcizHuK3cOE4pqwa1M39b6kyur1kXIVyl2vskkDbumDDfcxu(cOaRcOu8lG6H)azbuiEFUUclGcXvlSak1cvQ67nr8Pg6794AKLYyH0zHaSmuaqZYmwID6JD0kexTqwkflKT5MSObwSBtwMZcbyzOaGMLzSOVgdd99MUAIyfJTa2WogZVsbkVn03dKWIgyH0zzEbuyKg6Z6pqwaLuUkSu(JuwSTJ)o2S8awwuKfOV3JRrwUKfOaL3SyB)c7SCuw8NfnYY7nr8PeGmwgGMfec2rzXUn1mSe70h7OSaAwiDwG(EtxnrKfYj2cyd7ymFwOVhiHwafI310JXcO037X1y9YkfO8U4l2se3SO0fqX01viCr5lG6H)azbuBT)7fqHrAOpR)azbuc5Kf7y59Mi(uwSD)oy9SafSuSagS87ilekqJ0NLOGfl0DWsbZY4ukwSD)olesT)7SaV6ljYs5KHcOH(ESpVaAKSOVgdt7qWeSO1rJzjIAwwSOLLizrFngM2HGjyrRJgZseTsVCSu19O0h7Znllw0YsKS8UcZ3qblvfmQ)owhGgPVbtxxHWSOLfQfQu13BI4tn037X1ileKLiYIww0xJHbdQZIIvkq5TPXy)sklLXcsymSES(xmYIwwghX9V2ySFjLLYyrFngMGxVmyAm2VKYcbyHm7yPuS0RehGMiAS6lg0WNRQEh88cvRLI6TbtxxHWfFXwIizfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaLmw0aluluPQ7o9rwiil2XseWYmw20yhlLILzSqTqLQ(EteFQH(EpUgzjcyHmwMZsPyzglKXcby5DfMVHcwQkyu)DSoansFdMUUcHzPuSqMrJSmNL5Sqaw20qMgzPuSOVgdt7qWeSO1rJzjIAAm2VKwafgPH(S(dKfqjLRclL)iLfB74VJnlpGfcP2)DwGx9LezHq1ywIOfqH4Dn9ySaQT2)96L1rJzjIw8fBjI2vu6cOy66keUO8fq9WFGSaQT2)9cOWin0N1FGSaA5srwiKA)3z5swGcuEZc5euNffzb0SCdwsalqFVhxJSy7ukwg3ZYLpGfsTvnuozGfpJgdASaAOVh7ZlGoJfmOolkAuR07AIe(zzAIfmOolkA8mAnrc)SOLfiEFUUcnhTguOdbzzolAzzglV3eX38xmwFqf(qwkJfsNLPjwWG6SOOrTsVRxwTJLPjw0buklAzzCe3)AJX(LuwiilKTjlZzzAIf91yyWG6SOyLcuEBAm2VKYcbzXd)bsd99ECnAqcJH1J1)Irw0YI(AmmyqDwuSsbkVnllwMMybdQZIIMlRuGYBw0YsKSaX7Z1vOH(EpUgRxwPaL3SmnXI(AmmbVEzW0ySFjLfcYIh(dKg6794A0GegdRhR)fJSOLLizbI3NRRqZrRbf6qqw0YI(AmmbVEzW0ySFjLfcYcsymSES(xmYIww0xJHj41ldMLflttSOVgdt7qWeSO1rJzjIAwwSOLfiEFUUcn2A)3RxwhnMLiklttSejlq8(CDfAoAnOqhcYIww0xJHj41ldMgJ9lPSugliHXW6X6FXyXxSLigXIsxaftxxHWfLVakmsd9z9hilGwUuKfOV3JRrwUblxYc5VsVzHCcQZIIAILlzbkq5nlKtqDwuKfqYcPtawEVjIpLfqZYdyXQbbwGcuEZc5euNfflG6H)azbu6794AS4l2sej9IsxaftxxHWfLVakmsd9z9hilGsOCL637vbup8hilG2RS6H)azvD0VaQ6OFn9ySa6WvQFVxfFXxaD4k1V3RIsxSfYkkDbumDDfcxu(cOE4pqwaL(EtxnrSakmsd9z9hilGc99MUAIildqZsmacgJ5ZYkviLYYIEjrwkpyRLUaAOVh7ZlGgjl9kXbOjIgDx5zaRGr1vQ6VFjrQbJW1zzHWfFXwSRO0fqX01viCr5lG6H)azbu6khxJfqdrdkS(EteFAXwiRaAOVh7ZlGcdEtmaKJRrtJX(LuwkJLgJ9lPSukwSZow0alKP5fqHrAOpR)azbus50NLFhzbg8Sy7(Dw(DKLya9z5VyKLhWIddZYk)tXYVJSe7eMf4v7)bswokl73Byb6khxJS0ySFjLL4L6pl1HWS8awI9pSZsmaKJRrwGxT)hil(ITeXIsxa1d)bYcOXaqoUglGIPRRq4IYx8fFbu6xu6ITqwrPlGIPRRq4IYxa1d)bYcOoSB9heSsT5DCb0q0GcRV3eXNwSfYkGg67X(8cOrYcm4noSB9heSsT5DCf2JDIO5VajxsKfTSejlE4pqACy36piyLAZ74kSh7erZL1H6iU)SOLLzSejlWG34WU1FqWk1M3X1D0vM)cKCjrwMMybg8gh2T(dcwP28oUUJUY0ySFjLLYyrJSmNLPjwGbVXHDR)GGvQnVJRWESten03dKWcbzjISOLfyWBCy36piyLAZ74kSh7ertJX(LuwiilrKfTSadEJd7w)bbRuBEhxH9yNiA(lqYLelGcJ0qFw)bYcOLlfzzRWU1FqqwGAZ7ywSTJjl)o2ilhLLeWIh(dcYc1M3XAIfNYIYFKfNYIfGspDfYcizHAZ7ywSD)ol2XcOzzG2WMf67bsOSaAwajlolrKaSqT5Dmlual)U)S87iljAJfQnVJzX7(GGuw0SBrFw8XJnl)U)SqT5DmliHTUgPfFXwSRO0fqX01viCr5lG6H)azb0aiHaibR)owPwxFpTakmsd9z9hilGwUuKYcPajeajil3GfsTvnuozGLJYYYIfqZsuWIfVrwGrA0mCjrwi1w1q5KbwSD)olKcKqaKGS4jmlrblw8gzrhvaBSq6BQHiU5msHkK(NRybQ113tNZYwPecwUKfNfY2KaSqXalKtqDwu0WYwvualWGC7Nff(SqEB0J1VegBwqcBDnQjwCLnpkLLffz5swi1w1q5KbwSD)oleILI6nlEcZI)S87il037NfWGfNLYd2APzX2LWaBMcOH(ESpVa6mwMXceVpxxHMaiHaibRWinAgyrllrYsaauWaBPj41ldMgD4OSOLLizPxjoanr0y1xmOHpxv9o45fQwlf1BdMUUcHzzAIf91yycE9YGzzXIwwMXsKS0RehGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSmnXsVsCaAIOjGkK(NRQuRRVNAW01vimlttSmoI7FTXy)sklLXcz2rOzzAIfDaLYIwwghX9V2ySFjLfcYsaauWaBPj41ldMgJ9lPSqawiBtwMMyrFngMGxVmyAm2VKYszSqMDSmNL5SOLLzSmJfN(TRQwaByZcbTNfiEFUUcnbqcbqcwDQflAzzgl6RXWGb1zrXQALEBAm2VKYszSq2MSmnXI(AmmyqDwuSsbkVnng7xszPmwiBtwMZY0el6RXWe86LbtJX(LuwkJfnYIww0xJHj41ldMgJ9lPSqq7zHm7yzolAzzglrYsVsCaAIO5Vy0gOZkCJES(LWyBW01vimlttSejl9kXbOjIMaQq6FUQsTU(EQbtxxHWSmnXI(Amm)fJ2aDwHB0J1VegBtJX(LuwkJfKWyy9y9VyKL5SmnXsVsCaAIOr3vEgWkyuDLQ(7xsKAW01vimlZzrllZyjsw6vIdqten6UYZawbJQRu1F)sIudMUUcHzzAILzSOVgdJUR8mGvWO6kv93VKiTM(VA0qFpqcl2ZIMZY0el6RXWO7kpdyfmQUsv)9ljsREh8en03dKWI9SO5SmNL5SmnXIoGszrllJJ4(xBm2VKYcbzHSnzrllrYsaauWaBPj41ldMgD4OSmV4l2selkDbumDDfcxu(cOE4pqwaL(EtxnrSakmsd9z9hilGwUuKfOV30vtez5bSqcIwSSSy53rwiVn6X6xcJnl6RXGLBWY9SydSuWSGe26AKfDCaAKLXLhD)sIS87iljs4NLGtFwanlpGf4vSfl64a0ilKcKqaKGfqd99yFEb0EL4a0erZFXOnqNv4g9y9lHX2GPRRqyw0YYmwIKLzSmJf91yy(lgTb6Sc3OhRFjm2MgJ9lPSuglE4pqAS1(VBqcJH1J1)IrwialBAiJfTSmJfmOolkAUSQd(DwMMybdQZIIMlRuGYBwMMybdQZIIg1k9UMiHFwMZY0el6RXW8xmAd0zfUrpw)sySnng7xszPmw8WFG0qFVhxJgKWyy9y9VyKfcWYMgYyrllZybdQZIIMlRQv6nlttSGb1zrrdfO8UMiHFwMMybdQZIIgpJwtKWplZzzolttSejl6RXW8xmAd0zfUrpw)sySnllwMZY0elZyrFngMGxVmywwSmnXceVpxxHMaiHaibRWinAgyzolAzjaakyGT0eajeajy93Xk1667PMgD4OSOLLaacME(M8iU)1HJSOLLzSOVgddguNffRQv6TPXy)sklLXczBYY0el6RXWGb1zrXkfO820ySFjLLYyHSnzzolZzrllZyjswcaiy65BijAFEYY0elbaqbdSLgm2cyd7QoiHnng7xszPmw0CwMx8fBH0lkDbumDDfcxu(cOE4pqwaL(EtxnrSakmsd9z9hilGsExXwSa99MUAIiLfB3VZs5DLNbKfWGLTQuSu69ljszb0S8awSA0YBKLbOzHuGecGeKfB3VZs5bBT0fqd99yFEb0EL4a0erJUR8mGvWO6kv93VKi1GPRRqyw0YYmwMXI(Amm6UYZawbJQRu1F)sI0A6)Qrd99ajSugl2XY0el6RXWO7kpdyfmQUsv)9ljsREh8en03dKWszSyhlZzrllbaqbdSLMGxVmyAm2VKYszSqOzrllrYsaauWaBPjasiasW6VJvQ113tnllwMMyzglbaem98n5rC)RdhzrllbaqbdSLMaiHaibR)owPwxFp10ySFjLfcYczBYIwwWG6SOO5YQNrzrllo9BxvTa2WMLYyXUnzHaSeXnzPuSeaafmWwAcE9YGPrhoklZzzEXxSfnwu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0zSOVgdt7qWeSO1rJzjIAAm2VKYszSOrwMMyjsw0xJHPDiycw06OXSernllwMZIwwIKf91yyAhcMGfToAmlr0k9YXsv3JsFSp3SSyrllZyrFnggsUeUr4kgBbSHDmMFftSjELanng7xszHGSqmaBIDcZYCw0YYmw0xJHbdQZIIvkq5TPXy)sklLXcXaSj2jmlttSOVgddguNffRQv6TPXy)sklLXcXaSj2jmlttSmJLizrFnggmOolkwvR0BZYILPjwIKf91yyWG6SOyLcuEBwwSmNfTSejlVRW8nuGI(xany66keML5fqHrAOpR)azbusbs47pqYYa0S4kflWGNYYV7plXojiLf6Qrw(DmklEJ52plnoAKUJWSyBhtwkPDiycwuwiunMLikl7oLffsPS87EYIgzHIbklng7xEjrwanl)oYc5eBbSHnlLhKWSOVgdwoklUoy9S8awgUsXcymyb0S4zuwiNG6SOilhLfxhSEwEaliHTUglGcX7A6XybuyWxBmcxxJXy(0IVylKNIsxaftxxHWfLVakWQakf)cOE4pqwafI3NRRWcOqC1clGoJLizrFnggmOolkwPaL3MLflAzjsw0xJHbdQZIIv1k92SSyzolAzjswExH5BOaf9VaAW01vimlAzjsw6vIdqten)fJ2aDwHB0J1VegBdMUUcHlGcJ0qFw)bYcOKcKW3FGKLF3Fwc7yGekl3GLOGflEJSawp9GrwWG6SOilpGfqQIYcm4z53Xgzb0SCetqJS87hLfB3VZcuGI(xalGcX7A6XybuyWxbRNEWyfdQZIIfFXwi0fLUakMUUcHlkFbup8hilGgda54ASaAiAqH13BI4tl2czfqd99yFEb0zSOVgddguNffRuGYBtJX(LuwkJLgJ9lPSmnXI(AmmyqDwuSQwP3MgJ9lPSuglng7xszzAIfiEFUUcnWGVcwp9GXkguNffzzolAzPXrJ0DxxHSOLL3BI4B(lgRpOcFilLXcz2XIwwCRAyhdKWIwwG4956k0ad(AJr46AmgZNwafgPH(S(dKfqjVGNfxPy59Mi(uwSD)(LSqi8egJVal2UFhSEwaqWo4wwxsKa)oYIRdGGSeaj89hiPfFXw08IsxaftxxHWfLVaQh(dKfqPRCCnwan03J95fqNXI(AmmyqDwuSsbkVnng7xszPmwAm2VKYY0el6RXWGb1zrXQALEBAm2VKYszS0ySFjLLPjwG4956k0ad(ky90dgRyqDwuKL5SOLLghns3DDfYIwwEVjIV5VyS(Gk8HSuglKzhlAzXTQHDmqclAzbI3NRRqdm4RngHRRXymFAb0q0GcRV3eXNwSfYk(ITuskkDbumDDfcxu(cOE4pqwaL(Os5DDO8glGg67X(8cOZyrFnggmOolkwPaL3MgJ9lPSuglng7xszzAIf91yyWG6SOyvTsVnng7xszPmwAm2VKYY0elq8(CDfAGbFfSE6bJvmOolkYYCw0YsJJgP7UUczrllV3eX38xmwFqf(qwkJfYipSOLf3Qg2XajSOLfiEFUUcnWGV2yeUUgJX8PfqdrdkS(EteFAXwiR4l2czBwu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0aacME(giy(7rBw0YsKS0RehGMiAOxowQ6Eu6J95gmDDfcZIwwIKLEL4a0ert46GcRGrvDdS6jCfg9F3GPRRqyw0YsaauWaBPrhBk2KCjrtJoCuw0YsaauWaBPPDiycw06OXSernn6WrzrllrYI(AmmbVEzWSSyrllZyXPF7QQfWg2SuglAoHMLPjw0xJHrxbaWQf9nllwMxafgPH(S(dKfqjVGNL(iU)SOJdqJSqOAmlruwUbl3ZInWsbZIRuaBSefSy5bS04Or6olkKszbE1xsKfcvJzjIYYSF)OSasvuw2DllmPSy7(DW6zb6LJLIfnBJsFSpFEbuiExtpglGMG6Eu6J95v0Bv0km4l(ITqgzfLUakMUUcHlkFb0qFp2NxafI3NRRqtcQ7rPp2NxrVvrRWGNfTS0ySFjLfcYIDBwa1d)bYcOXaqoUgl(ITqMDfLUakMUUcHlkFb0qFp2NxafI3NRRqtcQ7rPp2NxrVvrRWGNfTS0ySFjLfcYczLKcOE4pqwaLUYX1yXxSfYIyrPlGIPRRq4IYxa1d)bYcOdqhWkyut)xnwafgPH(S(dKfqlxkYcHcSfwajlbywSD)oy9SeClRljwan03J95fqDRAyhdKu8fBHmsVO0fqX01viCr5lG6H)azbum2cyd7QoiHlGcJ0qFw)bYcOLlfzHCITa2WMLYdsywSD)olEgLffijYcMGfXDwuo9VKilKtqDwuKfpHz57OS8awuxISCplllwSD)oleILI6nlEcZcP2QgkNmuan03J95fqNXsaauWaBPj41ldMgJ9lPSqaw0xJHj41ldg4v7)bswial9kXbOjIgR(Ibn85QQ3bpVq1APOEBW01vimlLIfYSJLYyjaakyGT0GXwaByx1bjSbE1(FGKfcWczBYYCwMMyrFngMGxVmyAm2VKYszSO5fFXwitJfLUakMUUcHlkFbuGvbuk(fq9WFGSakeVpxxHfqH4Qfwa1PF7QQfWg2SuglLKnzjcyzgl2z0ilLIf91yygRoAfmQOALOH(EGewIawSJLsXcguNffnxwvR0BwMxafgPH(S(dKfqHIpLfB7yYYwPecwO7GLcMfDKf4vSfcZYdyjbplaiyhClwMrErlmHPSaswiuRoklGblKJALilEcZYVJSqob1zrX5fqH4Dn9ySaQtTQWRyRIVylKrEkkDbumDDfcxu(cOaRcOu8lG6H)azbuiEFUUclGcXvlSa6mwG4956k0eGRbqcF)bsw0YsKSOVgdtWRxgmllw0YYmwIKfk(vDqUOM)W2onVANvGLPjwWG6SOO5YQALEZY0elyqDwu0qbkVRjs4NL5SOLLzSmJLzSaX7Z1vOXPwv4vSflttSeaqW0Z3KhX9VoCKLPjwMXsaabtpFdjr7Ztw0YsaauWaBPbJTa2WUQdsytJoCuwMZY0el9kXbOjIM)IrBGoRWn6X6xcJTbtxxHWSmNfTSadEdDLJRrtJX(LuwkJfnNfTSadEtmaKJRrtJX(LuwkJLsclAzzglWG3qFuP8UouEJMgJ9lPSuglKTjlttSejlVRW8n0hvkVRdL3ObtxxHWSmNfTSaX7Z1vO537tPQuejb7Qn)Ew0YY7nr8n)fJ1huHpKLYyrFngMGxVmyGxT)hizPuSSPHqZY0el6RXWORaay1I(MLflAzrFnggDfaaRw030ySFjLfcYI(AmmbVEzWaVA)pqYcbyzglKzhlLILEL4a0erJvFXGg(Cv17GNxOATuuVny66keML5SmNLPjwMXcgHRZYcHnySv0gDvf0WPNbKfTSeaafmWwAWyROn6QkOHtpdOPXy)skleKfYipeAwialZyrJSukw6vIdqten0lhlvDpk9X(CdMUUcHzzolZzzolAzzglZyjswcaiy65BYJ4(xhoYY0elZybI3NRRqtaKqaKGvyKgndSmnXsaauWaBPjasiasW6VJvQ113tnng7xszHGSqMgzzolAzzglrYsVsCaAIOr3vEgWkyuDLQ(7xsKAW01vimlttS40VDv1cydBwiilACtw0YsaauWaBPjasiasW6VJvQ113tnn6WrzzolZzzAILXrC)Rng7xszHGSeaafmWwAcGecGeS(7yLAD99utJX(LuwMZY0el6akLfTSmoI7FTXy)skleKf91yycE9YGbE1(FGKfcWcz2XsPyPxjoanr0y1xmOHpxv9o45fQwlf1BdMUUcHzzEbuyKg6Z6pqwaTCPilKARAOCYal2UFNfsbsiasqnus5s4gHzbQ113tzXtywGb52plaiyBRVhzHqSuuVzb0SyBhtwkVcaGvl6ZInWsbZcsyRRrw0XbOrwi1w1q5KbwqcBDnsnSOz5KGSqxnYYdybZhBwCwi)v6nlKtqDwuKfB7yYYIEetwkTDAol2zfyXtywCLIfsrEPSy7ukw0XaigzPrhokluaizbtWI4olWR(sIS87il6RXGfpHzbg8uw2Diil6iMSqxJXfomFvuwAC0iDhHnfqH4Dn9ySaAaUgaj89hiR0V4l2cze6IsxaftxxHWfLVaQh(dKfqBhcMGfToAmlr0cOWin0N1FGSaA5srwiunMLikl2UFNfsTvnuozGLvQqkLfcvJzjIYInWsbZIYPplkqseBw(DpzHuBvdLtg0el)oMSSOil64a0yb0qFp2NxavFngMGxVmyAm2VKYszSqMgzzAIf91yycE9YGbE1(FGKfcYIDeAwial9kXbOjIgR(Ibn85QQ3bpVq1APOEBW01vimlLIfYSJfTSaX7Z1vOjaxdGe((dKv6x8fBHmnVO0fqX01viCr5lGg67X(8cOq8(CDfAcW1aiHV)azL(SOLLzSOVgdtWRxgmWR2)dKSuM9SyhHMfcWsVsCaAIOXQVyqdFUQ6DWZluTwkQ3gmDDfcZsPyHm7yzAILizjaGGPNVbcM)E0ML5SmnXI(AmmTdbtWIwhnMLiQzzXIww0xJHPDiycw06OXSernng7xszHGSusyHaSeaj86EJvJHJIvxDeZymFZFXyfIRwileGLzSejl6RXWORaay1I(MLflAzjswExH5BOV3kqdBW01vimlZlG6H)azb0aQq6FUQ6QJygJ5x8fBHSssrPlGIPRRq4IYxan03J95fqH4956k0eGRbqcF)bYk9lG6H)azb0ldEN(FGS4l2IDBwu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0aaOGb2stWRxgmng7xszPmwiBtwMMyjswG4956k0eajeajyfgPrZalAzjaGGPNVjpI7FD4ybuyKg6Z6pqwaTKQ3NRRqwwueMfqYIRFQ7pKYYV7pl288z5bSOJSqDiimldqZcP2QgkNmWcfWYV7pl)ogLfVX8zXMtFeMfn7w0NfDCaAKLFhJlGcX7A6XybuQdbRdqxdE9YqXxSf7iRO0fqX01viCr5lG6H)azb0XQJwbJkQwjwafgPH(S(dKfqlxkszHqbihwUblxYINSqob1zrrw8eMLVpKYYdyrDjYY9SSSyX297SqiwkQ3AIfsTvnuozqtSqoXwaByZs5bjmlEcZYwHDR)GGSa1M3Xfqd99yFEbumOolkAUS6zuw0YYmwC63UQAbSHnleKLsIDSebSOVgdZy1rRGrfvRen03dKWsPyrJSmnXI(AmmTdbtWIwhnMLiQzzXYCw0YYmw0xJHXQVyqdFUQ6DWZluTwkQ3giUAHSqqwSJ03KLPjw0xJHj41ldMgJ9lPSuglAolZzrllq8(CDfAOoeSoaDn41ldSOLLzSejlbaem98njgAGc0WSmnXcm4noSB9heSsT5DCf2JDIO5VajxsKL5SOLLzSejlbaem98nqW83J2SmnXI(AmmTdbtWIwhnMLiQPXy)skleKLsclralZyH0zPuS0RehGMiAOxowQ6Eu6J95gmDDfcZYCw0YI(AmmTdbtWIwhnMLiQzzXY0elrYI(AmmTdbtWIwhnMLiQzzXYCw0YYmwIKLaacME(gsI2NNSmnXsaauWaBPbJTa2WUQdsytJX(LuwkJf72KL5SOLL3BI4B(lgRpOcFilLXIgzzAIfDaLYIwwghX9V2ySFjLfcYczBw8fBXo7kkDbumDDfcxu(cOE4pqwaL(EpCLQakmsd9z9hilGwUuKfc5e)DwG(EpCLIfRgeOSCdwG(EpCLILJMB)SSSkGg67X(8cO6RXWas83PvlSdO1FG0SSyrll6RXWqFVhUszAC0iD31vyXxSf7IyrPlGIPRRq4IYxa1d)bYcObpdOQQVgJcOH(ESpVaQ(Amm03BfOHnng7xszHGSOrw0YYmw0xJHbdQZIIvkq5TPXy)sklLXIgzzAIf91yyWG6SOyvTsVnng7xszPmw0ilZzrllo9BxvTa2WMLYyPKSzbu91yutpglGsFVvGgUakmsd9z9hilGskpdOIfOV3kqdZYny5Ew2DklkKsz539KfnszPXy)YljQjwIcwS4nYI)Sus2KaSSvkHGfpHz53rwcRUX8zHCcQZIISS7uw0ibOS0ySF5Lel(ITyhPxu6cOy66keUO8fqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0aacME(M8iU)1HJSOLLEL4a0erJvFXGg(Cv17GNxOATuuVny66keMfTSOVgdJvFXGg(Cv17GNxOATuuVnqC1czHaS40VDv1cydBwialrKLYSNLiU5MSOLfiEFUUcnbqcbqcwHrA0mWIwwcaGcgylnbqcbqcw)DSsTU(EQPXy)skleKfN(TRQwaByZIgyjIBYsPyHya2e7eMfTSGb1zrrZLvpJYIwwC63UQAbSHnlLXceVpxxHMaiHaibRo1IfTSeaafmWwAcE9YGPXy)sklLXIglGcJ0qFw)bYcOqXNYITDmzHqSuuVzHUdwkyw0rwSAqiGWSGERIYYdyrhzX1vilpGLffzHuGecGeKfqYsaauWaBjlZihkfZ)CLkkl6yaeJuw(EHSCdwGxXwxsKLTsjeSKaBSy7ukwCLcyJLOGflpGflShy4vrzbZhBwielf1Bw8eMLFhtwwuKfsbsiasW5fqH4Dn9ySaQvdcvRLI6Df9wfT4l2IDASO0fqX01viCr5lG6H)azbu679WvQcOWin0N1FGSaA5srwG(EpCLIfB3VZc0hvkVzH8234zb0S82P5Sq6wbw8eMLeWc03BfOH1el22XKLeWc037HRuSCuwwwSaAwEalwniWcHyPOEZITDmzX1bqqwkjBYYwPeIzGMLFhzb9wfLfcXsr9MfRgeybI3NRRqwoklFVW5SaAwCyl)piiluBEhZYUtzrZjafduwAm2V8sISaAwoklxYYqDe3)cOH(ESpVa6mwExH5BOpQuExH7B8gmDDfcZY0elu8R6GCrn)HTDAEL0TcSmNfTSejlVRW8n03BfOHny66keMfTSOVgdd99E4kLPXrJ0DxxHSOLLizPxjoanr08xmAd0zfUrpw)sySny66keMfTSmJf91yyS6lg0WNRQEh88cvRLI6TbIRwilLzpl2PXnzrllrYI(AmmbVEzWSSyrllZybI3NRRqJtTQWRylwMMyrFnggsUeUr4kgBbSHDmMFftSjELanllwMMybI3NRRqJvdcvRLI6Df9wfLL5SmnXYmwcaiy65Bsm0afOHzrllVRW8n0hvkVRW9nEdMUUcHzrllZybg8gh2T(dcwP28oUc7Xor00ySFjLLYyrZzzAIfp8hinoSB9heSsT5DCf2JDIO5Y6qDe3FwMZYCwMZIwwMXsaauWaBPj41ldMgJ9lPSuglKTjlttSeaafmWwAcGecGeS(7yLAD99utJX(LuwkJfY2KL5fFXwSJ8uu6cOy66keUO8fq9WFGSak99MUAIybuyKg6Z6pqwaL8UITOSSvkHGfDCaAKfsbsiasqww0ljYYVJSqkqcbqcYsaKW3FGKLhWsyhdKWYnyHuGecGeKLJYIh(LRurzX1bRNLhWIoYsWPFb0qFp2NxafI3NRRqJvdcvRLI6Df9wfT4l2IDe6IsxaftxxHWfLVaQh(dKfqt0wngaYcOWin0N1FGSaA5srw0SaGKYITDmzjkyXI3ilUoy9S8an4nYsWTSUKilHDVjIuw8eMLyNeKf6Qrw(DmklEJSCjlEYc5euNffzH(NsXYa0SOzRMLgiuAwfqd99yFEbu3Qg2XajSOLLzSe29MiszXEwSJfTS0yy3BIy9VyKfcYIgzzAILWU3erkl2ZsezzEXxSf708IsxaftxxHWfLVaAOVh7ZlG6w1WogiHfTSmJLWU3erkl2ZIDSOLLgd7EteR)fJSqqw0ilttSe29MiszXEwIilZzrllZyrFnggmOolkwvR0BtJX(LuwkJfKWyy9y9VyKLPjw0xJHbdQZIIvkq5TPXy)sklLXcsymSES(xmYY8cOE4pqwaD3vJAmaKfFXwSRKuu6cOy66keUO8fqd99yFEbu3Qg2XajSOLLzSe29MiszXEwSJfTS0yy3BIy9VyKfcYIgzzAILWU3erkl2ZsezzolAzzgl6RXWGb1zrXQALEBAm2VKYszSGegdRhR)fJSmnXI(AmmyqDwuSsbkVnng7xszPmwqcJH1J1)IrwMxa1d)bYcOJLsvJbGS4l2se3SO0fqX01viCr5lG6H)azbu67nD1eXcOWin0N1FGSaA5srwG(EtxnrKfc5e)DwSAqGYINWSaVITyzRucbl22XKfsTvnuozqtSqoXwaByZs5bjSMy53rwkPI5VhTzrFngSCuwCDW6z5bSmCLIfWyWcOzjkyTnmlb3ILTsjefqd99yFEbumOolkAUS6zuw0YYmw0xJHbK4VtRbf6DfYrpqAwwSmnXI(AmmKCjCJWvm2cyd7ym)kMyt8kbAwwSmnXI(AmmbVEzWSSyrllZyjswcaiy65BijAFEYY0elbaqbdSLgm2cyd7QoiHnng7xszPmw0ilttSOVgdtWRxgmng7xszHGSqmaBIDcZsPyzOaGMLzS40VDv1cydBw0alq8(CDfAO0AaqFwMZYCw0YYmwIKLaacME(giy(7rBwMMyrFngM2HGjyrRJgZse10ySFjLfcYcXaSj2jmlLILaEkwMXYmwC63UQAbSHnleGfsFtwkflVRW8nJvhTcgvuTs0GPRRqywMZIgybI3NRRqdLwda6ZYCwialrKLsXY7kmFtI2QXaqAW01vimlAzjsw6vIdqten0lhlvDpk9X(CdMUUcHzrll6RXW0oemblAD0ywIOMLflttSOVgdt7qWeSO1rJzjIwPxowQ6Eu6J95MLflttSmJf91yyAhcMGfToAmlrutJX(LuwiilE4pqAOV3JRrdsymSES(xmYIwwOwOsv3D6JSqqw20q6SmnXI(AmmTdbtWIwhnMLiQPXy)skleKfp8hin2A)3niHXW6X6FXilttSOVgdJvFXGg(Cv17GNxOATuuVnqC1czPm7zXoY2KfTSmJfN(TRQwaByZszSaX7Z1vOHsRba9zPuSyhlralAKLPjw0xJHPDiycw06OXSernng7xszPmwSJL5SOLf91yyAhcMGfToAmlrutJX(LuwiilKhwMMybI3NRRqZfHW1aiHV)ajlAzjaakyGT0Cjn0R31vyncxE(R4kmc5cOPrhoklAzbJW1zzHWMlPHE9UUcRr4YZFfxHrixazzolAzrFngM2HGjyrRJgZse1SSyzAILizrFngM2HGjyrRJgZse1SSyrllrYsaauWaBPPDiycw06OXSernn6WrzzolttSaX7Z1vOXPwv4vSflttSOdOuw0YY4iU)1gJ9lPSqqwigGnXoHzPuSeWtXYmwC63UQAbSHnlAGfiEFUUcnuAnaOplZzzEXxSLiswrPlGIPRRq4IYxa1d)bYcO03B6QjIfqHrAOpR)azb0s3rz5bSe7KGS87il6i9zbmyb67Tc0WSOhLf67bsUKil3ZYYILiCDbsurz5sw8mklKtqDwuKf91ZcHyPOEZYrZTFwCDW6z5bSOJSy1GqaHlGg67X(8cOVRW8n03BfOHny66keMfTSejl9kXbOjIM)IrBGoRWn6X6xcJTbtxxHWSOLLzSOVgdd99wbAyZYILPjwC63UQAbSHnlLXsjztwMZIww0xJHH(ERanSH(EGewiilrKfTSmJf91yyWG6SOyLcuEBwwSmnXI(AmmyqDwuSQwP3MLflZzrll6RXWy1xmOHpxv9o45fQwlf1BdexTqwiil2rO3KfTSmJLaaOGb2stWRxgmng7xszPmwiBtwMMyjswG4956k0eajeajyfgPrZalAzjaGGPNVjpI7FD4ilZl(ITer7kkDbumDDfcxu(cOaRcOu8lG6H)azbuiEFUUclGcXvlSakguNffnxwvR0BwkflAolAGfp8hin037X1Objmgwpw)lgzHaSejlyqDwu0CzvTsVzPuSmJfYdleGL3vy(gkyPQGr93X6a0i9ny66keMLsXsezzolAGfp8hin2A)3niHXW6X6FXileGLnnKUgzrdSqTqLQU70hzHaSSPrJSukwExH5Bs)xnsR6UYZaAW01viCbuyKg6Z6pqwaLCO)f7pszzhyJL4vyNLTsjeS4nYcr)seMflSzHIbqcByHqovrz5Dsqklol00TO7GNLbOz53rwcRUX8zHE)Y)dKSqbSydSuW52pl6ilEiSA)rwgGMfL3eXML)IXr7XiTakeVRPhJfqDQfHaBOyO4l2seJyrPlGIPRRq4IYxa1d)bYcO03B6QjIfqHrAOpR)azbuY7k2IfOV30vtez5sw8KfYjOolkYItzHcajloLflaLE6kKfNYIcKezXPSefSyX2PuSGjmlllwSD)olA(MeGfB7yYcMp2xsKLFhzjrc)Sqob1zrrnXcmi3(zrHpl3ZIvdcSqiwkQ3AIfyqU9Zcac2267rw8Kfc5e)DwSAqGfpHzXcauSOJdqJSqQTQHYjdS4jmlKtSfWg2SuEqcxan03J95fqJKLEL4a0erZFXOnqNv4g9y9lHX2GPRRqyw0YYmw0xJHXQVyqdFUQ6DWZluTwkQ3giUAHSqqwSJqVjlttSOVgdJvFXGg(Cv17GNxOATuuVnqC1czHGSyNg3KfTS8UcZ3qFuP8Uc334ny66keML5SOLLzSGb1zrrZLvkq5nlAzXPF7QQfWg2SqawG4956k04ulcb2qXalLIf91yyWG6SOyLcuEBAm2VKYcbybg8MXQJwbJkQwjA(lqcT2ySFjlLIf7mAKLYyrZ3KLPjwWG6SOO5YQALEZIwwC63UQAbSHnleGfiEFUUcno1IqGnumWsPyrFnggmOolkwvR0BtJX(LuwialWG3mwD0kyur1krZFbsO1gJ9lzPuSyNrJSuglLKnzzolAzjsw0xJHbK4VtRwyhqR)aPzzXIwwIKL3vy(g67Tc0WgmDDfcZIwwMXsaauWaBPj41ldMgJ9lPSugleAwMMyHcwk9lHn)EFkvLIijyBW01vimlAzrFngMFVpLQsrKeSn03dKWcbzjIrKLiGLzS0RehGMiAOxowQ6Eu6J95gmDDfcZsPyXowMZIwwghX9V2ySFjLLYyHSn3KfTSmoI7FTXy)skleKf72CtwMZIwwMXsKSeaqW0Z3qs0(8KLPjwcaGcgylnySfWg2vDqcBAm2VKYszSyhlZl(ITersVO0fqX01viCr5lG6H)azb0eTvJbGSakmsd9z9hilGwUuKfnlaiPSCjlEgLfYjOolkYINWSqDiilA26QbbiulLIfnlaizzaAwi1w1q5Kbw8eMLskxc3imlKtSfWg2Xy(gw2QIcyzrrw2IMflEcZcHsZIf)z53rwWeMfWGfcvJzjIYINWSadYTFwu4Zc5Trpw)sySzz4kflGXOaAOVh7ZlG6w1WogiHfTSaX7Z1vOH6qW6a01GxVmWIwwMXI(AmmyqDwuSQwP3MgJ9lPSugliHXW6X6FXilttSOVgddguNffRuGYBtJX(LuwkJfKWyy9y9VyKL5fFXwIOglkDbumDDfcxu(cOH(ESpVaQBvd7yGew0YceVpxxHgQdbRdqxdE9YalAzzgl6RXWGb1zrXQALEBAm2VKYszSGegdRhR)fJSmnXI(AmmyqDwuSsbkVnng7xszPmwqcJH1J1)IrwMZIwwMXI(AmmbVEzWSSyzAIf91yyS6lg0WNRQEh88cvRLI6TbIRwile0EwSJSnzzolAzzglrYsaabtpFdem)9OnlttSOVgdt7qWeSO1rJzjIAAm2VKYcbzzglAKLiGf7yPuS0RehGMiAOxowQ6Eu6J95gmDDfcZYCw0YI(AmmTdbtWIwhnMLiQzzXY0elrYI(AmmTdbtWIwhnMLiQzzXYCw0YYmwIKLEL4a0erZFXOnqNv4g9y9lHX2GPRRqywMMybjmgwpw)lgzHGSOVgdZFXOnqNv4g9y9lHX20ySFjLLPjwIKf91yy(lgTb6Sc3OhRFjm2MLflZlG6H)azb0DxnQXaqw8fBjIKNIsxaftxxHWfLVaAOVh7ZlG6w1WogiHfTSaX7Z1vOH6qW6a01GxVmWIwwMXI(AmmyqDwuSQwP3MgJ9lPSugliHXW6X6FXilttSOVgddguNffRuGYBtJX(LuwkJfKWyy9y9VyKL5SOLLzSOVgdtWRxgmllwMMyrFnggR(Ibn85QQ3bpVq1APOEBG4QfYcbTNf7iBtwMZIwwMXsKSeaqW0Z3qs0(8KLPjw0xJHHKlHBeUIXwaByhJ5xXeBIxjqZYIL5SOLLzSejlbaem98nqW83J2SmnXI(AmmTdbtWIwhnMLiQPXy)skleKfnYIww0xJHPDiycw06OXSernllw0YsKS0RehGMiAOxowQ6Eu6J95gmDDfcZY0elrYI(AmmTdbtWIwhnMLiQzzXYCw0YYmwIKLEL4a0erZFXOnqNv4g9y9lHX2GPRRqywMMybjmgwpw)lgzHGSOVgdZFXOnqNv4g9y9lHX20ySFjLLPjwIKf91yy(lgTb6Sc3OhRFjm2MLflZlG6H)azb0XsPQXaqw8fBjIe6IsxaftxxHWfLVakmsd9z9hilGwUuKfcja5Wcizjaxa1d)bYcO28UpqxbJkQwjw8fBjIAErPlGIPRRq4IYxa1d)bYcO037X1ybuyKg6Z6pqwaTCPilqFVhxJS8awSAqGfOaL3Sqob1zrrnXcP2QgkNmWYUtzrHukl)fJS87EYIZcHu7)oliHXW6rwu44zb0Sasvuwi)v6nlKtqDwuKLJYYYYWcH097SuA70CwSZkWcMp2S4SafO8MfYjOolkYYnyHqSuuVzH(NsXYUtzrHukl)UNSyhzBYc99ajuw8eMfsTvnuozGfpHzHuGecGeKLDhcYsmOrw(DpzHmcnLfsrEzPXy)YljAyPCPilUoacYIDACtndl7o9rwGx9LezHq1ywIOS4jml2zNDAgw2D6JSy7(DW6zHq1ywIOfqd99yFEbumOolkAUSQwP3SOLLizrFngM2HGjyrRJgZse1SSyzAIfmOolkAOaL31ej8ZY0elZybdQZIIgpJwtKWplttSOVgdtWRxgmng7xszHGS4H)aPXw7)Ubjmgwpw)lgzrll6RXWe86LbZYIL5SOLLzSejlu8R6GCrn)HTDAE1oRalttS0RehGMiAS6lg0WNRQEh88cvRLI6TbtxxHWSOLf91yyS6lg0WNRQEh88cvRLI6TbIRwileKf7iBtw0YsaauWaBPj41ldMgJ9lPSuglKrOzrllZyjswcaiy65BYJ4(xhoYY0elbaqbdSLMaiHaibR)owPwxFp10ySFjLLYyHmcnlZzrllZyjswApGMVbkflttSeaafmWwA0XMInjxs00ySFjLLYyHmcnlZzzolttSGb1zrrZLvpJYIwwMXI(Amm28UpqxbJkQwjAwwSmnXc1cvQ6UtFKfcYYMgsxJSOLLzSejlbaem98nqW83J2SmnXsKSOVgdt7qWeSO1rJzjIAwwSmNLPjwcaiy65BGG5VhTzrlluluPQ7o9rwiilBAiDwMx8fBjILKIsxaftxxHWfLVakmsd9z9hilGwUuKfcP2)Dwa)o22okYIT9lSZYrz5swGcuEZc5euNff1elKARAOCYalGMLhWIvdcSq(R0BwiNG6SOybup8hilGAR9FV4l2cPVzrPlGIPRRq4IYxafgPH(S(dKfqjuUs979QaQh(dKfq7vw9WFGSQo6xavD0VMEmwaD4k1V3RIV4l(cOqWMEGSyl2TPD2TzeTlIfqT5DEjrAbucPTwsVLYzlA2xYSWsP3rwUylq)SmanlBdSWe7TzPXiCDncZcfeJS4Rhe7pcZsy3tIi1WBq(xISyxjZcPajeSFeMLT7vIdqtenK22S8aw2Uxjoanr0qAgmDDfcVnlZiJWZn8gK)LilrSKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdEdcPTwsVLYzlA2xYSWsP3rwUylq)SmanlBdJdFP(TzPXiCDncZcfeJS4Rhe7pcZsy3tIi1WBq(xISqEkzwifiHG9JWSa9Ijfl0O57eMfndlpGfYF5SaFqo6bswawy7pOzzMgMZYmYi8CdVb5FjYc5PKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLz2r45gEdY)sKfcDjZcPajeSFeMLT7vIdqtenK22S8aw2Uxjoanr0qAgmDDfcVnlZiJWZn8gK)LilAEjZcPajeSFeMfOxmPyHgnFNWSOzy5bSq(lNf4dYrpqYcWcB)bnlZ0WCwMzhHNB4ni)lrw08sMfsbsiy)imlB3RehGMiAiTTz5bSSDVsCaAIOH0my66keEBwMrgHNB4ni)lrwkjLmlKcKqW(ryw2Uxjoanr0qABZYdyz7EL4a0erdPzW01vi82SmlIeEUH3G8VezPKuYSqkqcb7hHzz7VVKe8nKziTTz5bSS93xsc(MNmdPTnlZSJWZn8gK)LilLKsMfsbsiy)imlB)9LKGVXodPTnlpGLT)(ssW382ziTTzzMDeEUH3G8VezHSnlzwifiHG9JWSSDVsCaAIOH02MLhWY29kXbOjIgsZGPRRq4TzzgzeEUH3G8VezHmYkzwifiHG9JWSSDVsCaAIOH02MLhWY29kXbOjIgsZGPRRq4TzzgzeEUH3G8VezHm7kzwifiHG9JWSSDVsCaAIOH02MLhWY29kXbOjIgsZGPRRq4TzzgzeEUH3G8VezHSiwYSqkqcb7hHzz7EL4a0erdPTnlpGLT7vIdqtenKMbtxxHWBZYmYi8CdVb5FjYczASKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdY)sKfYipLmlKcKqW(ryw2Uxjoanr0qABZYdyz7EL4a0erdPzW01vi82SmZocp3WBq(xISqg5PKzHuGec2pcZY2FFjj4BiZqABZYdyz7VVKe8npzgsBBwMr6eEUH3G8VezHmYtjZcPajeSFeMLT)(ssW3yNH02MLhWY2FFjj4BE7mK22SmJmcp3WBq(xISqgHUKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLz2r45gEdY)sKfYi0LmlKcKqW(ryw2(7ljbFdzgsBBwEalB)9LKGV5jZqABZYmYi8CdVb5FjYcze6sMfsbsiy)imlB)9LKGVXodPTnlpGLT)(ssW382ziTTzzgPt45gEdEdcPTwsVLYzlA2xYSWsP3rwUylq)SmanlBB1yaeR7)2S0yeUUgHzHcIrw81dI9hHzjS7jrKA4ni)lrwIyjZcPajeSFeMLT)(ssW3qMH02MLhWY2FFjj4BEYmK22SmlIeEUH3G8VezH0lzwifiHG9JWSS93xsc(g7mK22S8aw2(7ljbFZBNH02MLzrKWZn8gK)LilAEjZcPajeSFeMLT7vIdqtenK22S8aw2Uxjoanr0qAgmDDfcVnl(Zc5qit(SmJmcp3WBWBqiT1s6TuoBrZ(sMfwk9oYYfBb6NLbOzzBhGBZsJr46AeMfkigzXxpi2FeMLWUNerQH3G8VezHSsMfsbsiy)imlB3RehGMiAiTTz5bSSDVsCaAIOH0my66keEBwMrgHNB4ni)lrwSRKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdY)sKf7kzwifiHG9JWSSDVsCaAIOH02MLhWY29kXbOjIgsZGPRRq4TzXFwihczYNLzKr45gEdY)sKLiwYSqkqcb7hHzz73vy(gsBBwEalB)UcZ3qAgmDDfcVnlZiJWZn8gK)LilrSKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzAoHNB4ni)lrwipLmlKcKqW(rywGEXKIfA08DcZIMrZWYdyH8xolXa4LArzbyHT)GMLzAM5SmJmcp3WBq(xISqEkzwifiHG9JWSSDVsCaAIOH02MLhWY29kXbOjIgsZGPRRq4TzzMDeEUH3G8VezHqxYSqkqcb7hHzb6ftkwOrZ3jmlAgndlpGfYF5SedGxQfLfGf2(dAwMPzMZYmYi8CdVb5FjYcHUKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdY)sKfnVKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdY)sKLssjZcPajeSFeMfOxmPyHgnFNWSOzy5bSq(lNf4dYrpqYcWcB)bnlZ0WCwMzhHNB4ni)lrwiZUsMfsbsiy)imlqVysXcnA(oHzrZWYdyH8xolWhKJEGKfGf2(dAwMPH5SmJmcp3WBq(xISqgPxYSqkqcb7hHzz7EL4a0erdPTnlpGLT7vIdqtenKMbtxxHWBZYmYi8CdVb5FjYczASKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdY)sKfYipLmlKcKqW(ryw2Uxjoanr0qABZYdyz7EL4a0erdPzW01vi82SmZocp3WBq(xISqMMxYSqkqcb7hHzz7EL4a0erdPTnlpGLT7vIdqtenKMbtxxHWBZYmYi8CdVb5FjYIDBwYSqkqcb7hHzz7EL4a0erdPTnlpGLT7vIdqtenKMbtxxHWBZYm7i8CdVb5FjYID2vYSqkqcb7hHzb6ftkwOrZ3jmlAgwEalK)Yzb(GC0dKSaSW2FqZYmnmNLzKr45gEdY)sKf7i9sMfsbsiy)imlqVysXcnA(oHzrZWYdyH8xolWhKJEGKfGf2(dAwMPH5SmZocp3WBq(xISyhPxYSqkqcb7hHzz7EL4a0erdPTnlpGLT7vIdqtenKMbtxxHWBZYmYi8CdVb5FjYIDKNsMfsbsiy)imlB3RehGMiAiTTz5bSSDVsCaAIOH0my66keEBwMrgHNB4ni)lrwSJqxYSqkqcb7hHzz7EL4a0erdPTnlpGLT7vIdqtenKMbtxxHWBZYmYi8CdVb5FjYIDLKsMfsbsiy)imlqVysXcnA(oHzrZWYdyH8xolWhKJEGKfGf2(dAwMPH5SmZocp3WBq(xISeXnlzwifiHG9JWSSDVsCaAIOH02MLhWY29kXbOjIgsZGPRRq4TzXFwihczYNLzKr45gEdY)sKLiswjZcPajeSFeMfOxmPyHgnFNWSOzy5bSq(lNf4dYrpqYcWcB)bnlZ0WCwMrgHNB4n4niK2Aj9wkNTOzFjZclLEhz5ITa9ZYa0SS9WvQFVxBZsJr46AeMfkigzXxpi2FeMLWUNerQH3G8VezXUsMfsbsiy)imlqVysXcnA(oHzrZWYdyH8xolWhKJEGKfGf2(dAwMPH5SmJmcp3WBWBqiT1s6TuoBrZ(sMfwk9oYYfBb6NLbOzzB6VnlngHRRrywOGyKfF9Gy)rywc7EsePgEdY)sKf7kzwifiHG9JWSSDVsCaAIOH02MLhWY29kXbOjIgsZGPRRq4TzzgHMWZn8gK)LilrSKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdY)sKfsVKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdY)sKfYtjZcPajeSFeMLT7vIdqtenK22S8aw2Uxjoanr0qAgmDDfcVnl(Zc5qit(SmJmcp3WBq(xISq2MLmlKcKqW(ryw2Uxjoanr0qABZYdyz7EL4a0erdPzW01vi82SmZocp3WBq(xISqgPxYSqkqcb7hHzz7EL4a0erdPTnlpGLT7vIdqtenKMbtxxHWBZYmYi8CdVb5FjYczKNsMfsbsiy)imlB3RehGMiAiTTz5bSSDVsCaAIOH0my66keEBwMPrcp3WBq(xISqgHUKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdY)sKfY08sMfsbsiy)imlB3RehGMiAiTTz5bSSDVsCaAIOH0my66keEBwMrgHNB4ni)lrwSJSsMfsbsiy)imlB3RehGMiAiTTz5bSSDVsCaAIOH0my66keEBwMrgHNB4ni)lrwSJ0lzwifiHG9JWSa9Ijfl0O57eMfndlpGfYF5SaFqo6bswawy7pOzzMgMZYmYi8CdVb5FjYIDKEjZcPajeSFeMLT7vIdqtenK22S8aw2Uxjoanr0qAgmDDfcVnlZiJWZn8gK)Lil2PXsMfsbsiy)imlB3RehGMiAiTTz5bSSDVsCaAIOH0my66keEBwMrgHNB4ni)lrwI4MLmlKcKqW(rywGEXKIfA08DcZIMHLhWc5VCwGpih9ajlalS9h0SmtdZzzwej8CdVb5FjYse3SKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLzKr45gEdY)sKLiswjZcPajeSFeMLT7vIdqtenK22S8aw2Uxjoanr0qAgmDDfcVnlZiJWZn8gK)Lilr0UsMfsbsiy)imlqVysXcnA(oHzrZWYdyH8xolWhKJEGKfGf2(dAwMPH5SmlIeEUH3G8VezjIrSKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLz2r45gEdY)sKLiQXsMfsbsiy)imlB3RehGMiAiTTz5bSSDVsCaAIOH0my66keEBwMzhHNB4ni)lrwIi5PKzHuGec2pcZY29kXbOjIgsBBwEalB3RehGMiAindMUUcH3MLz2r45gEdY)sKLiQ5LmlKcKqW(ryw2Uxjoanr0qABZYdyz7EL4a0erdPzW01vi82SmJmcp3WBWBuoXwG(rywipS4H)ajlQJ(udVrbuRgmofwaLCjxwkVR8mGSqE71bZBqUKllB1QpflKPjwSBt7SJ3G3GCjxwi1UNerAjZBqUKllralBfggHzbkq5nlLh9ydVb5sUSebSqQDpjIWS8Ete)6nyj4uKYYdyjenOW67nr8PgEdYLCzjcyPKgJbqqywwzIbKs9oklq8(CDfszz2zqJMyXQriv67nD1erwIGYyXQrig67nD1eX5gEdYLCzjcyzRqahmlwngC6FjrwiKA)3z5gSC)2uw(DKfBnijYc5euNffn8gKl5YseWIMLtcYcPajeajil)oYcuRRVNYIZI6(xHSedAKLHcj8PRqwMDdwIcwSS7W52pl73ZY9SqV4L69eblQkkl2UFNLYtiV1sZcbyHuOcP)5kw2Q6iMXy(AIL73gMfkjN1CdVb5sUSebSOz5KGSedOplBpoI7FTXy)s62Sqdy69bOS4wwQOS8aw0buklJJ4(tzbKQOgEdYLCzjcyP0n6plLgeJSagSuELVZs5v(olLx57S4uwCwOwy4CflFFjj4B4nixYLLiGfczlmXMLzNbnAIfcP2)DnXcHu7)UMyb6794AColXomYsmOrwAKEQdZNLhWc6T6WMLaiw3)iG(E)gEdYLCzjcyHqDeMLskxc3imlKtSfWg2Xy(Se2XajSmanlKI8YYI6erdVb5sUSebSusJXaiilW96GnjOgGPSe2XajudVbVb5sUSS1mbV)imlL3vEgqw2kHG8zj4jl6ildWkHzXFw2)3IwYAqd6UYZagb0loyiE)(s3CanuEx5zaJaOxmP0qmSz)JvA2CCk0EDx5zanpHFEdEdp8hiPgRgdGyD)TNKlHBeUsTU(EkVb5YsP3rwG4956kKLJYcfFwEalBYIT73zjbSqF)zbKSSOilFFjj4t1elKXITDmz53rwgxtFwajYYrzbKSSOOMyXowUbl)oYcfdGeMLJYINWSerwUbl6GFNfVrEdp8hiPgRgdGyD)jG9AaI3NRRqnLEmApiRlkw)(ssWxtqC1cTFtEdp8hiPgRgdGyD)jG9AaI3NRRqnLEmApiRlkw)(ssWxtal7DyynbXvl0EY00nS)7ljbFdzMDNwxuSQVgdTFFjj4BiZeaafmWwAGxT)hi1g53xsc(gYmh18GyScg1yqs)gSO1aiPFVc)bskVHh(dKuJvJbqSU)eWEnaX7Z1vOMspgThK1ffRFFjj4RjGL9omSMG4QfAVDA6g2)9LKGVXoZUtRlkw1xJH2VVKe8n2zcaGcgylnWR2)dKAJ87ljbFJDMJAEqmwbJAmiPFdw0AaK0VxH)ajL3GCzP07ifz57ljbFklEJSKGNfF9Gy)VGRurzbgFm8imloLfqYYIISqF)z57ljbFQHfwGIplq8(CDfYYdyH0zXPS87yuwCffWsIimlulmCUILDpHvxs0WB4H)aj1y1yaeR7pbSxdq8(CDfQP0Jr7bzDrX63xsc(AcyzVddRjiUAH2t6A6g2Jr46SSqyZL0qVExxH1iC55VIRWiKlGttyeUolle2GXwrB0vvqdNEgWPjmcxNLfcBOGLsH)FjXAV0JYBqUSafFkl)oYc03B6QjISea0NLbOzr5p2SeCvyP8)ajLLzdqZcsyp2sHSyBhtwEal037Nf4vS1LezrhhGgzHq1ywIOSmCLIYcymMZB4H)aj1y1yaeR7pbSxdq8(CDfQP0Jr7P0AaqFnbXvl0(iUzPMrweSPHmnwkk(vDqUOM)W2onVs6wH58gE4pqsnwngaX6(ta71aeVpxxHAk9y0E6Oga0xtqC1cTxJBwQzKfbBAitJLIIFvhKlQ5pSTtZRKUvyoVb5Ycu8PS4pl22VWolEmyLplGblBLsiyHuGecGeKf6oyPGzrhzzrr4sMfsFtwSD)oy9SqkuH0)CflqTU(EklEcZse3KfB3VB4n8WFGKASAmaI19Na2RbiEFUUc1u6XO9bqcbqcwDQLMG4QfAFe3KaKTzP6vIdqtenbuH0)CvLAD99uEdp8hiPgRgdGyD)jG9AigassUSoaDmVHh(dKuJvJbqSU)eWEnyR9FxtQlXAa2EY2ut3W(zyqDwu0OwP31ej8pnHb1zrrZLvkq590eguNffnxw1b)(0eguNffnEgTMiH)58g8gKlleIgdo9zXowiKA)3zXtywCwG(EtxnrKfqYc0sZIT73zzlhX9NfcLJS4jmlLhS1sZcOzb6794AKfWVJTTJI8gE4pqsnalmXMa2RbBT)7A6g2pddQZIIg1k9UMiH)PjmOolkAUSsbkVNMWG6SOO5YQo43NMWG6SOOXZO1ej8pxRvJqmKzS1(VRnsRgHySZyR9FN3Wd)bsQbyHj2eWEnqFVhxJAsDjwdW2RrnDd7NnlYEL4a0erJUR8mGvWO6kv93VKiDAkYaacME(M8iU)1HJttrsTqLQ(EteFQH(EpCLYEYMMI8DfMVj9F1iTQ7kpdObtxxHWZNMMHb1zrrdfO8UMiH)PjmOolkAUSQwP3ttyqDwu0Czvh87ttyqDwu04z0AIe(NpxBKu8R6GCrn)HTDAE1oRaVHh(dKudWctSjG9AG(EtxnrutQlXAa2EnQPBy)SEL4a0erJUR8mGvWO6kv93VKivBaabtpFtEe3)6WrTuluPQV3eXNAOV3dxPSNS5AJKIFvhKlQ5pSTtZR2zf4n4nixYLfYHWyy9imlieSJYYFXil)oYIhEqZYrzXH4NY1vOH3Wd)bsQ9uGY7Qo6X8gE4pqsjG9Ai4kv1d)bYQ6OVMspgThyHj2AI(9fE7jtt3W()IrcoZUs5H)aPXw7)Uj40V(xmsap8hin037X1Oj40V(xmoN3GCzbk(uw2kGCybKSercWIT73bRNf4(gplEcZIT73zb67Tc0WS4jml2rawa)o22okYB4H)ajLa2RbiEFUUc1u6XO9hT6autqC1cTNAHkv99Mi(ud99E4kvzKPDwKVRW8n03BfOHny66keEA6DfMVH(Os5DfUVXBW01vi88PjQfQu13BI4tn037HRuLzhVb5Ycu8PSeuOdbzX2oMSa99ECnYsWtw2VNf7ialV3eXNYIT9lSZYrzPrfcXZNLbOz53rwiNG6SOilpGfDKfRghy3imlEcZIT9lSZY4ukSz5bSeC6ZB4H)ajLa2RbiEFUUc1u6XO9hTguOdb1eexTq7PwOsvFVjIp1qFVhxJLrgVb5YsjvVpxxHS87(ZsyhdKqz5gSefSyXBKLlzXzHyaMLhWIdbCWS87il07x(FGKfB7yJS4S89LKGpl4hy5OSSOimlxYIo(2qmzj40NYB4H)ajLa2RbiEFUUc1u6XO9xwjgG1eexTq7TAesLya2qMjgaYX140KvJqQedWgYm0voUgNMSAesLya2qMH(EtxnrCAYQrivIbydzg679WvQPjRgHujgGnKzgRoAfmQOAL40KvJqmTdbtWIwhnMLi60K(AmmbVEzW0ySFj1E91yycE9YGbE1(FGCAcI3NRRqZrRoa5nixwkxkYs5XMInjxsKf)z53rwWeMfWGfcvJzjIYITDmzz3PpYYrzX1bqqwipBQz0el(4XMfsbsiasqwSD)olLh4LMfpHzb87yB7Oil2UFNfsTvnuozG3Wd)bskbSxd6ytXMKljQPBy)SzrgaqW0Z3KhX9VoCCAkYaaOGb2staKqaKG1FhRuRRVNAwwttr2RehGMiA0DLNbScgvxPQ)(LePZ1QVgdtWRxgmng7xslJmnQvFngM2HGjyrRJgZse10ySFjLGKU2idaiy65BGG5VhTNMcaiy65BGG5VhT1QVgdtWRxgmllT6RXW0oemblAD0ywIOMLL2z6RXW0oemblAD0ywIOMgJ9lPe0EYSlci9s1RehGMiAOxowQ6Eu6J95tt6RXWe86LbtJX(LucsgzttKPzOwOsv3D6JeKmd5z(CTq8(CDfAUSsmaZBqUSqiapl2UFNfNfsTvnuozGLF3FwoAU9ZIZcHyPOEZIvdcSaAwSTJjl)oYY4iU)SCuwCDW6z5bSGjmVHh(dKucyVgSa)bsnDd7NPVgdtWRxgmng7xslJmnQDwK9kXbOjIg6LJLQUhL(yF(0K(AmmTdbtWIwhnMLiQPXy)skbjRKOvFngM2HGjyrRJgZse1SSMpnPdOuTJJ4(xBm2VKsq704CTq8(CDfAUSsmaZBqUSqkxfwk)rkl22XFhBww0ljYcPajeajiljWgl2oLIfxPa2yjkyXYdyH(NsXsWPpl)oYc1Jrw8yWkFwadwifiHaibjaP2QgkNmWsWPpL3Wd)bskbSxdq8(CDfQP0Jr7dGecGeScJ0OzqtqC1cTpGNA2SXrC)Rng7xsJaY0yeeaafmWwAcE9YGPXy)s6CndzA(MZllGNA2SXrC)Rng7xsJaY0yeeaafmWwAcGecGeS(7yLAD99utJX(L05AgY08nNRnY2p4kcbZ34WWuds4J(uTZImaakyGT0e86LbtJoC0PPidaGcgylnbqcbqcw)DSsTU(EQPrho68PPaaOGb2stWRxgmng7xsl7YhBlGYFeUooI7FTXy)s60uVsCaAIOjGkK(NRQuRRVNQnaakyGT0e86LbtJX(L0YI4MttbaqbdSLMaiHaibR)owPwxFp10ySFjTSlFSTak)r464iU)1gJ9lPrazBonfzaabtpFtEe3)6WrEdYLLYLIWS8awGrLhLLFhzzrDIilGblKARAOCYal22XKLf9sISadw6kKfqYYIIS4jmlwncbZNLf1jISyBhtw8KfhgMfecMplhLfxhSEwEalWhYB4H)ajLa2RbiEFUUc1u6XO9b4AaKW3FGutqC1cTF27nr8n)fJ1huHpSmY040u7hCfHG5BCyyQ5YY04MZ1oBggHRZYcHnySv0gDvf0WPNbu7Sidaiy65BGG5VhTNMcaGcgylnySv0gDvf0WPNb00ySFjLGKrEi0eyMglvVsCaAIOHE5yPQ7rPp2NpFU2idaGcgylnySv0gDvf0WPNb00OdhD(0egHRZYcHnuWsPW)VKyTx6r1olYaacME(M8iU)1HJttbaqbdSLgkyPu4)xsS2l9O1is6AuZ3KmtJX(LucsgzK(8PPzbaqbdSLgDSPytYLenn6WrNMIS9aA(gOuttbaem98n5rC)RdhNRDwKVRW8nJvhTcgvuTs0GPRRq4PPaacME(giy(7rBTbaqbdSLMXQJwbJkQwjAAm2VKsqYiJaASu9kXbOjIg6LJLQUhL(yF(0uKbaem98nqW83J2AdaGcgylnJvhTcgvuTs00ySFjLG6RXWe86Lbd8Q9)ajbiZUs1RehGMiAS6lg0WNRQEh88cvRLI6DeqMDZ1odJW1zzHWMlPHE9UUcRr4YZFfxHrixa1gaafmWwAUKg6176kSgHlp)vCfgHCb00ySFjLGAC(00SzyeUolle2q3DyGneUcA9kyuFqhJ5RnaakyGT08GogZhHRxspI7FnIAuJr0oYmng7xsNpnnBgeVpxxHgqwxuS(9LKGV9KnnbX7Z1vObK1ffRFFjj4BFeNRD23xsc(gYmn6WrRbaqbdSLttFFjj4BiZeaafmWwAAm2VKw2Lp2waL)iCDCe3)AJX(L0iGSnNpnbX7Z1vObK1ffRFFjj4BVDAN99LKGVXotJoC0AaauWaB5003xsc(g7mbaqbdSLMgJ9lPLD5JTfq5pcxhhX9V2ySFjnciBZ5ttq8(CDfAazDrX63xsc(2V585Z5nixwkP6956kKLffHz5bSaJkpklEgLLVVKe8PS4jmlbykl22XKfB(9xsKLbOzXtwiNL1oOpNfRge4n8WFGKsa71aeVpxxHAk9y0(FVpLQsrKeSR2871eexTq7JKcwk9lHn)EFkvLIijyBW01vi8004iU)1gJ9lPLz3MBonPdOuTJJ4(xBm2VKsq70ibMr6Bgb6RXW879PuvkIKGTH(EGKsz38Pj91yy(9(uQkfrsW2qFpqszruZJGz9kXbOjIg6LJLQUhL(yFEPSBoVb5Ys5srwiNyROn6kwiKB40ZaYIDBsXaLfDCaAKfNfsTvnuozGLffzb0SqbS87(ZY9Sy7ukwuxISSSyX297S87ilycZcyWcHQXSer5n8WFGKsa71WII17XynLEmApgBfTrxvbnC6za10nSpaakyGT0e86LbtJX(LucA3MAdaGcgylnbqcbqcw)DSsTU(EQPXy)skbTBtTZG4956k0879PuvkIKGD1MF)0K(Amm)EFkvLIijyBOVhiPSiUjbM1RehGMiAOxowQ6Eu6J95LkIZNRfI3NRRqZLvIb4PjDaLQDCe3)AJX(LucgrcnVb5Ys5srwGcwkf(xsKLs6LEuwipumqzrhhGgzXzHuBvdLtgyzrrwanlual)U)SCpl2oLIf1LilllwSD)ol)oYcMWSagSqOAmlruEdp8hiPeWEnSOy9EmwtPhJ2tblLc))sI1EPhvt3W(zbaqbdSLMGxVmyAm2VKsqYJ2idaiy65BGG5VhT1gzaabtpFtEe3)6WXPPaacME(M8iU)1HJAdaGcgylnbqcbqcw)DSsTU(EQPXy)skbjpANbX7Z1vOjasiasWkmsJMHPPaaOGb2stWRxgmng7xsji5z(0uaabtpFdem)9OT2zr2RehGMiAOxowQ6Eu6J95AdaGcgylnbVEzW0ySFjLGKNPj91yyAhcMGfToAmlrutJX(Lucs2MeyMglfgHRZYcHnxs)EfEqtRWhKlXQoQuZ1QVgdt7qWeSO1rJzjIAwwZNM0buQ2XrC)Rng7xsjODACAcJW1zzHWgm2kAJUQcA40ZaQnaakyGT0GXwrB0vvqdNEgqtJX(L0YSBZ5AH4956k0CzLyawBKyeUolle2Cjn0R31vyncxE(R4kmc5c40uaauWaBP5sAOxVRRWAeU88xXvyeYfqtJX(L0YSBZPjDaLQDCe3)AJX(LucA3M8gKllBvzZJszzrrwkhnBqEzX297SqQTQHYjdSaAw8NLFhzbtywadwiunMLikVHh(dKucyVgG4956kutPhJ2FriCnas47pqQjiUAH2RVgdtWRxgmng7xslJmnQDwK9kXbOjIg6LJLQUhL(yF(0K(AmmTdbtWIwhnMLiQPXy)skbTNmnA0ibMfrJglL(Amm6kaawTOVzznNaZiDJgJGiA0yP0xJHrxbaWQf9nlR5LcJW1zzHWMlPFVcpOPv4dYLyvhvkcq6gnwQzyeUolle287yDCn9R0J4P0gaafmWwA(DSoUM(v6r8uMgJ9lPe0E72CUw91yyAhcMGfToAmlruZYA(0KoGs1ooI7FTXy)skbTtJttyeUolle2GXwrB0vvqdNEgqTbaqbdSLgm2kAJUQcA40ZaAAm2VKYB4H)ajLa2RHffR3JXAk9y0(lPHE9UUcRr4YZFfxHrixa10nShI3NRRqZfHW1aiHV)aPwiEFUUcnxwjgG5nixwkxkYc0DhgydHzHqU1zrhhGgzHuBvdLtg4n8WFGKsa71WII17XynLEmApD3Hb2q4kO1RGr9bDmMVMUH9ZcaGcgylnbVEzW0OdhvBKbaem98n5rC)Rdh1cX7Z1vO537tPQuejb7Qn)ETZcaGcgyln6ytXMKljAA0HJonfz7b08nqPMpnfaqW0Z3KhX9VoCuBaauWaBPjasiasW6VJvQ113tnn6Wr1odI3NRRqtaKqaKGvyKgndttbaqbdSLMGxVmyA0HJoFUwyWBORCCnA(lqYLe1odg8g6JkL31HYB08xGKljonf57kmFd9rLY76q5nAW01vi80e1cvQ67nr8Pg6794ASSioxlm4nXaqoUgn)fi5sIANbX7Z1vO5OvhGtt9kXbOjIgDx5zaRGr1vQ6VFjr60Kt)2vvlGnSlZ(sYMttq8(CDfAcGecGeScJ0OzyAsFnggDfaaRw03SSMRnsmcxNLfcBUKg6176kSgHlp)vCfgHCbCAcJW1zzHWMlPHE9UUcRr4YZFfxHrixa1gaafmWwAUKg6176kSgHlp)vCfgHCb00ySFjTSiUP2i1xJHj41ldML10KoGs1ooI7FTXy)skbj9n5nixwk9(rz5OS4S0(VJnlOY1bT)il28OS8awIDsqwCLIfqYYIISqF)z57ljbFklpGfDKf1LimlllwSD)olKARAOCYalEcZcPajeajilEcZYIIS87il2LWSqvGNfqYsaMLBWIo43z57ljbFklEJSaswwuKf67plFFjj4t5n8WFGKsa71WII17XyQMOkWtT)7ljbFY00nShI3NRRqdiRlkw)(ssWps7jtBKFFjj4BSZ0OdhTgaafmWwonndI3NRRqdiRlkw)(ssW3EYMMG4956k0aY6II1VVKe8TpIZ1otFngMGxVmywwAdaiy65BGG5VhT1otFngM2HGjyrRJgZse10ySFjLaZIOrJLQxjoanr0qVCSu19O0h7ZNtq7)(ssW3qMrFngv4v7)bsT6RXW0oemblAD0ywIOML10K(AmmTdbtWIwhnMLiALE5yPQ7rPp2NBwwZNMcaGcgylnbVEzW0ySFjLa2v23xsc(gYmbaqbdSLg4v7)bsTZISxjoanr0y1xmOHpxv9o45fQwlf17Pj91yycE9YGPXy)sAzKN5ANfzaabtpFtEe3)6WXPPVVKe8nKzcaGcgylnWR2)dKLfaafmWwAcGecGeS(7yLAD99utJX(L0PjiEFUUcnbqcbqcwHrA0mO97ljbFdzMaaOGb2sd8Q9)azzbaqbdSLMGxVmyAm2VKoxBKbaem98nKeTppNMcaiy65BYJ4(xhoQfI3NRRqtaKqaKGvyKgndAdaGcgylnbqcbqcw)DSsTU(EQzzPnYaaOGb2stWRxgmllTZMPVgddguNffRQv6TPXy)sAzACAsFnggmOolkwPaL3MgJ9lPLPX5ZNM0xJHHKlHBeUIXwaByhJ5xXeBIxjqZYA(004iU)1gJ9lPe0UnNMG4956k0aY6II1VVKe8TFtEdp8hiPeWEnSOy9EmMQjQc8u7)(ssW3onDd7H4956k0aY6II1VVKe8J0E70g53xsc(gYmn6WrRbaqbdSLttq8(CDfAazDrX63xsc(2BN2z6RXWe86LbZYsBaabtpFdem)9OT2z6RXW0oemblAD0ywIOMgJ9lPeywenASu9kXbOjIg6LJLQUhL(yF(CcA)3xsc(g7m6RXOcVA)pqQvFngM2HGjyrRJgZse1SSMM0xJHPDiycw06OXSerR0lhlvDpk9X(CZYA(0uaauWaBPj41ldMgJ9lPeWUY((ssW3yNjaakyGT0aVA)pqQDwK9kXbOjIgR(Ibn85QQ3bpVq1APOEpnPVgdtWRxgmng7xslJ8mx7Sidaiy65BYJ4(xhoon99LKGVXotaauWaBPbE1(FGSSaaOGb2staKqaKG1FhRuRRVNAAm2VKonbX7Z1vOjasiasWkmsJMbTFFjj4BSZeaafmWwAGxT)hillaakyGT0e86LbtJX(L05AJmaGGPNVHKO95P2zrQVgdtWRxgmlRPPidaiy65BGG5VhTNpnfaqW0Z3KhX9VoCuleVpxxHMaiHaibRWinAg0gaafmWwAcGecGeS(7yLAD99uZYsBKbaqbdSLMGxVmywwANntFnggmOolkwvR0BtJX(L0Y040K(AmmyqDwuSsbkVnng7xsltJZNpFAsFnggsUeUr4kgBbSHDmMFftSjELanlRPPXrC)Rng7xsjODBonbX7Z1vObK1ffRFFjj4B)M8gKllLlfPS4kflGFhBwajllkYY9ymLfqYsaM3Wd)bskbSxdlkwVhJP8gKllKZ97yZcralx(aw(DKf6ZcOzXbilE4pqYI6OpVHh(dKucyVg6vw9WFGSQo6RP0Jr7DaQj63x4TNmnDd7H4956k0C0QdqEdp8hiPeWEn0RS6H)azvD0xtPhJ2tFEdEdYLfs5QWs5pszX2o(7yZYVJSqEB0Jd(h2XMf91yWITtPyz4kflGXGfB3VFjl)oYsIe(zj40N3Wd)bsQXbO9q8(CDfQP0Jr7HB0JR2oLQoCLQcgdnbXvl0(EL4a0erZFXOnqNv4g9y9lHXw7m91yy(lgTb6Sc3OhRFjm2MgJ9lPeKya2e7eMaBAiBAsFngM)IrBGoRWn6X6xcJTPXy)skb9WFG0qFVhxJgKWyy9y9VyKaBAit7mmOolkAUSQwP3ttyqDwu0qbkVRjs4FAcdQZIIgpJwtKW)85A1xJH5Vy0gOZkCJES(LWyBww8gKllKYvHLYFKYITD83XMfOV30vtez5OSyd0)olbN(xsKfaeSzb6794AKLlzH8xP3Sqob1zrrEdp8hiPghGeWEnaX7Z1vOMspgT)iMGgR03B6QjIAcIRwO9rIb1zrrZLvkq5TwQfQu13BI4tn037X1yze6i4DfMVHcwQkyu)DSoansFdMUUcHlLDeadQZIIMlR6GFxBK9kXbOjIgR(Ibn85QQ3bpVq1APOERnYEL4a0erdiXFNwdk07kKJEGK3GCzPCPilKcKqaKGSyBhtw8NffsPS87EYIg3KLTsjeS4jmlQlrwwwSy7(Dwi1w1q5KbEdp8hiPghGeWEneajeajy93Xk1667PA6g2pBgeVpxxHMaiHaibRWinAg0gzaauWaBPj41ldMgD4OAJSxjoanr0y1xmOHpxv9o45fQwlf17Pj91yycE9YGzzPDwK9kXbOjIgR(Ibn85QQ3bpVq1APOEpn1RehGMiAcOcP)5Qk1667PttJJ4(xBm2VKwgz2rONM0buQ2XrC)Rng7xsjyaauWaBPj41ldMgJ9lPeGSnNM0xJHj41ldMgJ9lPLrMDZNRD2Szo9BxvTa2WMG2dX7Z1vOjasiasWQtTMMOwOsvFVjIp1qFVhxJLfX5ANPVgddguNffRQv6TPXy)sAzKT50K(AmmyqDwuSsbkVnng7xslJSnNpnPVgdtWRxgmng7xsltJA1xJHj41ldMgJ9lPe0EYSBU2zr(UcZ3qFuP8Uc334NM0xJHH(EpCLY0ySFjLGKz0yeSPrJLQxjoanr0eqfs)ZvvQ113tNM0xJHj41ldMgJ9lPeuFngg679WvktJX(LucOrT6RXWe86LbZYAU2zr2RehGMiA(lgTb6Sc3OhRFjm2ttr2RehGMiAcOcP)5Qk1667Ptt6RXW8xmAd0zfUrpw)sySnng7xsldjmgwpw)lgNpn1RehGMiA0DLNbScgvxPQ)(LePZ1olYEL4a0erJUR8mGvWO6kv93VKiDAAM(Amm6UYZawbJQRu1F)sI0A6)Qrd99aj2R5tt6RXWO7kpdyfmQUsv)9ljsREh8en03dKyVMpF(0KoGs1ooI7FTXy)skbjBtTrgaafmWwAcE9YGPrho6CEdYLLYLISaDLJRrwUKflpHX4lWcizXZO)(Lez539Nf1bbPSqgPtXaLfpHzrHukl2UFNLyqJS8EteFklEcZI)S87ilycZcyWIZcuGYBwiNG6SOil(ZczKolumqzb0SOqkLLgJ9lVKiloLLhWscEw2DixsKLhWsJJgP7SaV6ljYc5VsVzHCcQZII8gE4pqsnoajG9AGUYX1OMcrdkS(EteFQ9KPPBy)Sghns3DDfonPVgddguNffRuGYBtJX(LucgrTyqDwu0CzLcuERTXy)skbjJ01(UcZ3qblvfmQ)owhGgPVbtxxHWZ1(EteFZFXy9bv4dlJmspcOwOsvFVjIpLang7xs1oddQZIIMlREgDAQXy)skbjgGnXoHNZBqUSuUuKfORCCnYYdyz3HGS4Squb0DflpGLffzPC0Sb5L3Wd)bsQXbibSxd0voUg10nShI3NRRqZfHW1aiHV)aP2aaOGb2sZL0qVExxH1iC55VIRWiKlGMgD4OAXiCDwwiS5sAOxVRRWAeU88xXvyeYfqTUvnSJbs4nixwkPGOflllwG(EpCLIf)zXvkw(lgPSSsfsPSSOxsKfYpAWBNYINWSCplhLfxhSEwEalwniWcOzrHpl)oYc1cdNRyXd)bswuxISOJkGnw29ewHSqEB0J1VegBwajl2XY7nr8P8gE4pqsnoajG9AG(EpCLst3W(iFxH5BOpQuExH7B8gmDDfcRDwKu8R6GCrn)HTDAEL0TcttyqDwu0Cz1ZOttuluPQV3eXNAOV3dxPklIZ1otFngg679WvktJJgP7UUc1oJAHkv99Mi(ud99E4kfbJ40uK9kXbOjIM)IrBGoRWn6X6xcJ98PP3vy(gkyPQGr93X6a0i9ny66kewR(AmmyqDwuSsbkVnng7xsjye1Ib1zrrZLvkq5Tw91yyOV3dxPmng7xsjiHwl1cvQ67nr8Pg679WvQYSN0NRDwK9kXbOjIgv0G3oToui(xsSsuDXwuCA6VyuZOziDnwM(Amm037HRuMgJ9lPeWU5AFVjIV5VyS(Gk8HLPrEdYLfcP73zb6JkL3SqE7B8SSOilGKLaml22XKLghns3DDfYI(6zH(NsXIn)EwgGMfYpAWBNYIvdcS4jmlWGC7NLffzrhhGgzHuKxQHfO)PuSSOil64a0ilKcKqaKGSqVmGS87(ZITtPyXQbbw8e87yZc037HRu8gE4pqsnoajG9AG(EpCLst3W(3vy(g6JkL3v4(gVbtxxHWA1xJHH(EpCLY04Or6URRqTZIKIFvhKlQ5pSTtZRKUvyAcdQZIIMlREgDAIAHkv99Mi(ud99E4kvzrCU2zr2RehGMiAurdE706qH4FjXkr1fBrXPP)IrnJMH01yzK(CTJJ4(xBm2VKwwe5nixwiKUFNfYBJES(LWyZYIISa99E4kflpGfsq0ILLfl)oYI(AmyrpklUIcyzrVKilqFVhUsXcizrJSqXaiHPSaAwuiLYsJX(LxsK3Wd)bsQXbibSxd037HRuA6g23RehGMiA(lgTb6Sc3OhRFjm2APwOsvFVjIp1qFVhUsvM9ru7Si1xJH5Vy0gOZkCJES(LWyBwwA1xJHH(EpCLY04Or6URRWPPzq8(CDfAGB0JR2oLQoCLQcgdTZ0xJHH(EpCLY0ySFjLGrCAIAHkv99Mi(ud99E4kvz2P9DfMVH(Os5DfUVXBW01viSw91yyOV3dxPmng7xsjOgNpFoVb5YcPCvyP8hPSyBh)DSzXzb67nD1erwwuKfBNsXsWxuKfOV3dxPy5bSmCLIfWyOjw8eMLffzb67nD1erwEalKGOflK3g9y9lHXMf67bsyzzzyrZ3KLJYYVJS0yeUUgHzzRucblpGLGtFwG(EtxnrKaqFVhUsXB4H)aj14aKa2RbiEFUUc1u6XO9037HRuvBG8RdxPQGXqtqC1cT3PF7QQfWg2LP5BwQzKfbu8R6GCrn)HTDAE1oRqP20y38snJSiqFngM)IrBGoRWn6X6xcJTH(EGKsTPHS5rWm91yyOV3dxPmng7xslve1muluPQ7o9Xsf57kmFd9rLY7kCFJ3GPRRq45rWSaaOGb2sd99E4kLPXy)sAPIOMHAHkvD3PpwQ3vy(g6JkL3v4(gVbtxxHWZJGz6RXWmwD0kyur1krtJX(L0sPX5ANPVgdd99E4kLzznnfaafmWwAOV3dxPmng7xsNZBqUSuUuKfOV30vtezX297SqEB0J1VegBwEalKGOflllw(DKf91yWIT73bRNffGEjrwG(EpCLILL1FXilEcZYIISa99MUAIilGKfsNaSuEWwlnl03dKqzzL)PyH0z59Mi(uEdp8hiPghGeWEnqFVPRMiQPBypeVpxxHg4g94QTtPQdxPQGXqleVpxxHg679WvQQnq(1HRuvWyOnsiEFUUcnhXe0yL(EtxnrCAAM(Amm6UYZawbJQRu1F)sI0A6)Qrd99ajLfXPj91yy0DLNbScgvxPQ)(LePvVdEIg67bsklIZ1sTqLQ(EteFQH(EpCLIGKUwiEFUUcn037HRuvBG8RdxPQGXG3GCzPCPiluBEhZcfWYV7plrblwiIplXoHzzz9xmYIEuww0ljYY9S4uwu(JS4uwSau6PRqwajlkKsz539KLiYc99ajuwanlA2TOpl22XKLisawOVhiHYcsyRRrEdp8hiPghGeWEn4WU1FqWk1M3XAkenOW67nr8P2tMMUH9r(xGKljQnsp8hinoSB9heSsT5DCf2JDIO5Y6qDe3)PjyWBCy36piyLAZ74kSh7erd99ajemIAHbVXHDR)GGvQnVJRWEStenng7xsjye5nixwkPXrJ0Dw0SaGCCnYYnyHuBvdLtgy5OS0OdhvtS87yJS4nYIcPuw(DpzrJS8EteFklxYc5VsVzHCcQZIISy7(DwGcEcLMyrHukl)UNSq2MSa(DSTDuKLlzXZOSqob1zrrwanlllwEalAKL3BI4tzrhhGgzXzH8xP3Sqob1zrrdlKxqU9ZsJJgP7SaV6ljYsjLlHBeMfYj2cyd7ymFwwPcPuwUKfOaL3Sqob1zrrEdp8hiPghGeWEneda54AutHObfwFVjIp1EY00nSVXrJ0DxxHAFVjIV5VyS(Gk8HLnBgzKobMrTqLQ(EteFQH(EpUglLDLsFnggmOolkwvR0BZYA(Cc0ySFjDUMzgze4DfMV5TDzngasQbtxxHWZ160VDv1cyd7YG4956k0qh1aG(rG(Amm037HRuMgJ9lPLI8ODMBvd7yGKPjiEFUUcnhXe0yL(EtxnrCAksmOolkAUS6z05ANfaafmWwAcE9YGPrhoQwmOolkAUS6zuTZG4956k0eajeajyfgPrZW0uaauWaBPjasiasW6VJvQ113tnn6WrNMImaGGPNVjpI7FD448PjQfQu13BI4tn037X1ibNntZJGz6RXWGb1zrXQALEBwwLkIZNxQzKrG3vy(M32L1yaiPgmDDfcpFU2iXG6SOOHcuExtKWV2zrgaafmWwAcE9YGPrho68PPzyqDwu0CzLcuEpnPVgddguNffRQv6TzzPnY3vy(gkyPQGr93X6a0i9ny66keEU2zuluPQV3eXNAOV3JRrcs2MLAgze4DfMV5TDzngasQbtxxHWZNpx7Sidaiy65BijAFEonfP(AmmKCjCJWvm2cyd7ym)kMyt8kbAwwttyqDwu0CzLcuEpxBK6RXW0oemblAD0ywIOv6LJLQUhL(yFUzzXBqUSuUuKfcfylSaswcWSy7(DW6zj4wwxsK3Wd)bsQXbibSxddqhWkyut)xnQPByVBvd7yGKPjiEFUUcnhXe0yL(EtxnrK3Wd)bsQXbibSxdq8(CDfQP0Jr7dW1aiHV)az1bOMG4QfA)miEFUUcnb4AaKW3FGu7m91yyOV3dxPmlRPP3vy(g6JkL3v4(gVbtxxHWttbaem98n5rC)RdhNRfg8MyaihxJM)cKCjrTZIuFnggkqr)lGMLL2i1xJHj41ldMLL2zr(UcZ3mwD0kyur1krdMUUcHNM0xJHj41ldg4v7)bYYcaGcgylnJvhTcgvuTs00ySFjLaA(CTZIKIFvhKlQ5pSTtZR2zfMMWG6SOO5YQALEpnHb1zrrdfO8UMiH)5AH4956k0879PuvkIKGD1MFV2zrgaqW0Z3KhX9VoCCAcI3NRRqtaKqaKGvyKgndttbaqbdSLMaiHaibR)owPwxFp10ySFjLGKPX5AFVjIV5VyS(Gk8HLPVgdtWRxgmWR2)dKLAtdHE(0KoGs1ooI7FTXy)skb1xJHj41ldg4v7)bscqMDLQxjoanr0y1xmOHpxv9o45fQwlf1758gKllLlfzHq1ywIOSy7(Dwi1w1q5KbEdp8hiPghGeWEn0oemblAD0ywIOA6g2RVgdtWRxgmng7xslJmnonPVgdtWRxgmWR2)dKeGm7kvVsCaAIOXQVyqdFUQ6DWZluTwkQ3e0oYJwiEFUUcnb4AaKW3FGS6aK3GCzPCPilKARAOCYalGKLamlRuHuklEcZI6sKL7zzzXIT73zHuGecGeK3Wd)bsQXbibSxdbuH0)Cv1vhXmgZxt3WEiEFUUcnb4AaKW3FGS6au7Sidaiy65BGG5VhTNMISxjoanr0qVCSu19O0h7ZNM6vIdqtenw9fdA4ZvvVdEEHQ1sr9EAsFngMGxVmyGxT)hilZE7ipZNM0xJHPDiycw06OXSernllT6RXW0oemblAD0ywIOMgJ9lPeKmnA0iVHh(dKuJdqcyVgUm4D6)bsnDd7H4956k0eGRbqcF)bYQdqEdYLLYLISqoXwaByZs5bjmlGKLaml2UFNfOV3dxPyzzXINWSqDiildqZcHyPOEZINWSqQTQHYjd8gE4pqsnoajG9AaJTa2WUQdsynDd7NfaafmWwAcE9YGPXy)skb0xJHj41ldg4v7)bsc0RehGMiAS6lg0WNRQEh88cvRLI6DPiZUYcaGcgylnySfWg2vDqcBGxT)hijazBoFAsFngMGxVmyAm2VKwMMZBqUSusJJgP7SmuEJSaswwwS8awIilV3eXNYIT73bRNfsTvnuozGfD8sIS46G1ZYdybjS11ilEcZscEwaqWo4wwxsK3Wd)bsQXbibSxd0hvkVRdL3OMcrdkS(EteFQ9KPPByFJJgP7UUc1(xmwFqf(WYitJAPwOsvFVjIp1qFVhxJeK016w1Wogir7m91yycE9YGPXy)sAzKT50uK6RXWe86LbZYAoVb5Ys5srwiuaYHLBWYL0dgzXtwiNG6SOilEcZI6sKL7zzzXIT73zXzHqSuuVzXQbbw8eMLTc7w)bbzbQnVJ5n8WFGKACasa71Wy1rRGrfvRe10nShdQZIIMlREgv7m3Qg2Xajttr2RehGMiAS6lg0WNRQEh88cvRLI69CTZ0xJHXQVyqdFUQ6DWZluTwkQ3giUAHe0onU50K(AmmbVEzW0ySFjTmnFU2zWG34WU1FqWk1M3Xvyp2jIM)cKCjXPPidaiy65Bsm0afOHNMOwOsvFVjIpTm7MRDM(AmmTdbtWIwhnMLiQPXy)skbljrWmsVu9kXbOjIg6LJLQUhL(yF(CT6RXW0oemblAD0ywIOML10uK6RXW0oemblAD0ywIOML1CTZImaakyGT0e86LbZYAAsFngMFVpLQsrKeSn03dKqqY0O2XrC)Rng7xsjODBUP2XrC)Rng7xslJSn3CAkskyP0Ve2879PuvkIKGTbtxxHWZ1oJcwk9lHn)EFkvLIijyBW01vi80uaauWaBPj41ldMgJ9lPLfXnNR99Mi(M)IX6dQWhwMgNM0buQ2XrC)Rng7xsjizBYBqUSuUuKfNfOV3dxPyHqoXFNfRgeyzLkKszb679WvkwoklUQrhoklllwanlrblw8gzX1bRNLhWcac2b3ILTsje8gE4pqsnoajG9AG(EpCLst3WE91yyaj(70Qf2b06pqAwwANPVgdd99E4kLPXrJ0DxxHtto9BxvTa2WUSsYMZ5nixwiVRylw2kLqWIooanYcPajeajil2UFNfOV3dxPyXtyw(Dmzb67nD1erEdp8hiPghGeWEnqFVhUsPPByFaabtpFtEe3)6WrTr(UcZ3qFuP8Uc334ny66kew7miEFUUcnbqcbqcwHrA0mmnfaafmWwAcE9YGzznnPVgdtWRxgmlR5AdaGcgylnbqcbqcw)DSsTU(EQPXy)skbjgGnXoHlvap1mN(TRQwaByRzG4956k0qh1aG(Z1QVgdd99E4kLPXy)skbjDEdp8hiPghGeWEnqFVPRMiQPByFaabtpFtEe3)6WrTZG4956k0eajeajyfgPrZW0uaauWaBPj41ldML10K(AmmbVEzWSSMRnaakyGT0eajeajy93Xk1667PMgJ9lPeuJAH4956k0qFVhUsvTbYVoCLQcgdTyqDwu0Cz1ZOAJeI3NRRqZrmbnwPV30vte5nixwkxkYc03B6QjISy7(Dw8Kfc5e)DwSAqGfqZYnyjkyTnmlaiyhClw2kLqWIT73zjky1SKiHFwco9nSSvffWc8k2ILTsjeS4pl)oYcMWSagS87ilLuX83J2SOVgdwUblqFVhUsXInWsbNB)SmCLIfWyWcOzjkyXI3ilGKf7y59Mi(uEdp8hiPghGeWEnqFVPRMiQPByV(AmmGe)DAnOqVRqo6bsZYAAAwK037X1OXTQHDmqI2iH4956k0CetqJv67nD1eXPPz6RXWe86LbtJX(LucQrT6RXWe86LbZYAAA2m91yycE9YGPXy)skbjgGnXoHlvap1mN(TRQwaByRzG4956k0qP1aG(Z1QVgdtWRxgmlRPj91yyAhcMGfToAmlr0k9YXsv3JsFSp30ySFjLGedWMyNWLkGNAMt)2vvlGnS1mq8(CDfAO0Aaq)5A1xJHPDiycw06OXSerR0lhlvDpk9X(CZYAU2aacME(giy(7r75Z1oJAHkv99Mi(ud99E4kfbJ40eeVpxxHg679WvQQnq(1HRuvWymFU2iH4956k0CetqJv67nD1erTZISxjoanr08xmAd0zfUrpw)sySNMOwOsvFVjIp1qFVhUsrWioN3GCzPCPilAwaqsz5swGcuEZc5euNffzXtywOoeKfc1sPyrZcaswgGMfsTvnuozG3Wd)bsQXbibSxdjARgdaPMUH9Z0xJHbdQZIIvkq5TPXy)sAziHXW6X6FX400SWU3erQ92PTXWU3eX6FXib148PPWU3erQ9rCUw3Qg2Xaj8gE4pqsnoajG9Ay3vJAmaKA6g2ptFnggmOolkwPaL3MgJ9lPLHegdRhR)fJttZc7EteP2BN2gd7EteR)fJeuJZNMc7EteP2hX5ADRAyhdKODM(AmmTdbtWIwhnMLiQPXy)skb1Ow91yyAhcMGfToAmlruZYsBK9kXbOjIg6LJLQUhL(yF(0uK6RXW0oemblAD0ywIOML1CEdp8hiPghGeWEnmwkvngasnDd7NPVgddguNffRuGYBtJX(L0YqcJH1J1)IrTZcaGcgylnbVEzW0ySFjTmnU50uaauWaBPjasiasW6VJvQ113tnng7xsltJBoFAAwy3BIi1E702yy3BIy9VyKGAC(0uy3BIi1(ioxRBvd7yGeTZ0xJHPDiycw06OXSernng7xsjOg1QVgdt7qWeSO1rJzjIAwwAJSxjoanr0qVCSu19O0h7ZNMIuFngM2HGjyrRJgZse1SSMZBqUSuUuKfcja5WcizHuKxEdp8hiPghGeWEnyZ7(aDfmQOALiVb5YcPCvyP8hPSyBh)DSz5bSSOilqFVhxJSCjlqbkVzX2(f2z5OS4plAKL3BI4tjazSmanlieSJYIDBQzyj2Pp2rzb0Sq6Sa99MUAIilKtSfWg2Xy(SqFpqcL3Wd)bsQXbibSxdq8(CDfQP0Jr7PV3JRX6Lvkq5TMG4QfAp1cvQ67nr8Pg6794ASmsNadfa0ZID6JD0kexTWsr2MBQzSBZ5eyOaGEM(Amm03B6QjIvm2cyd7ym)kfO82qFpqIMH0NZBqUSqiNSyhlV3eXNYIT73bRNfOGLIfWGLFhzHqbAK(SefSyHUdwkywgNsXIT73zHqQ9FNf4vFjrwkNmWB4H)aj14aKa2RbBT)7A6g2hP(AmmTdbtWIwhnMLiQzzPns91yyAhcMGfToAmlr0k9YXsv3JsFSp3SS0g57kmFdfSuvWO(7yDaAK(gmDDfcRLAHkv99Mi(ud99ECnsWiQvFnggmOolkwPaL3MgJ9lPLHegdRhR)fJAhhX9V2ySFjTm91yycE9YGPXy)skbiZUs1RehGMiAS6lg0WNRQEh88cvRLI6nVb5YcPCvyP8hPSyBh)DSz5bSqi1(VZc8QVKileQgZseL3Wd)bsQXbibSxdq8(CDfQP0Jr7T1(VxVSoAmlrunbXvl0EY0muluPQ7o9rcAxemBtJDLAg1cvQ67nr8Pg6794AmciBEPMrgbExH5BOGLQcg1FhRdqJ03GPRRq4srMrJZNtGnnKPXsPVgdt7qWeSO1rJzjIAAm2VKYBqUSuUuKfcP2)DwUKfOaL3Sqob1zrrwanl3GLeWc037X1il2oLILX9SC5dyHuBvdLtgyXZOXGg5n8WFGKACasa71GT2)DnDd7NHb1zrrJALExtKW)0eguNffnEgTMiHFTq8(CDfAoAnOqhcox7S3BI4B(lgRpOcFyzK(0eguNffnQv6D9YQDtt6akv74iU)1gJ9lPeKSnNpnPVgddguNffRuGYBtJX(Luc6H)aPH(EpUgniHXW6X6FXOw91yyWG6SOyLcuEBwwttyqDwu0CzLcuERnsiEFUUcn037X1y9YkfO8EAsFngMGxVmyAm2VKsqp8hin037X1Objmgwpw)lg1gjeVpxxHMJwdk0HGA1xJHj41ldMgJ9lPeejmgwpw)lg1QVgdtWRxgmlRPj91yyAhcMGfToAmlruZYsleVpxxHgBT)71lRJgZseDAksiEFUUcnhTguOdb1QVgdtWRxgmng7xsldjmgwpw)lg5nixwkxkYc037X1il3GLlzH8xP3Sqob1zrrnXYLSafO8MfYjOolkYcizH0jalV3eXNYcOz5bSy1GalqbkVzHCcQZII8gE4pqsnoajG9AG(EpUg5nixwiuUs979I3Wd)bsQXbibSxd9kRE4pqwvh91u6XO9dxP(9EXBWBqUSa99MUAIildqZsmacgJ5ZYkviLYYIEjrwkpyRLM3Wd)bsQz4k1V3l7PV30vte10nSpYEL4a0erJUR8mGvWO6kv93VKi1Gr46SSqyEdYLfs50NLFhzbg8Sy7(Dw(DKLya9z5VyKLhWIddZYk)tXYVJSe7eMf4v7)bswokl73Byb6khxJS0ySFjLL4L6pl1HWS8awI9pSZsmaKJRrwGxT)hi5n8WFGKAgUs979Ia2Rb6khxJAkenOW67nr8P2tMMUH9WG3eda54A00ySFjTSgJ9lPLYo70mKP58gE4pqsndxP(9Era71qmaKJRrEdEdYLLYLISSvy36piilqT5Dml22XKLFhBKLJYscyXd)bbzHAZ7ynXItzr5pYItzXcqPNUczbKSqT5Dml2UFNf7yb0SmqByZc99ajuwanlGKfNLisawO28oMfkGLF3Fw(DKLeTXc1M3XS4DFqqklA2TOpl(4XMLF3FwO28oMfKWwxJuEdp8hiPg6BVd7w)bbRuBEhRPq0GcRV3eXNApzA6g2hjm4noSB9heSsT5DCf2JDIO5VajxsuBKE4pqACy36piyLAZ74kSh7erZL1H6iU)ANfjm4noSB9heSsT5DCDhDL5VajxsCAcg8gh2T(dcwP28oUUJUY0ySFjTmnoFAcg8gh2T(dcwP28oUc7Xor0qFpqcbJOwyWBCy36piyLAZ74kSh7ertJX(LucgrTWG34WU1FqWk1M3Xvyp2jIM)cKCjrEdYLLYLIuwifiHaibz5gSqQTQHYjdSCuwwwSaAwIcwS4nYcmsJMHljYcP2QgkNmWIT73zHuGecGeKfpHzjkyXI3il6OcyJfsFtneXnNrkuH0)CflqTU(E6Cw2kLqWYLS4Sq2MeGfkgyHCcQZIIgw2QIcybgKB)SOWNfYBJES(LWyZcsyRRrnXIRS5rPSSOilxYcP2QgkNmWIT73zHqSuuVzXtyw8NLFhzH(E)SagS4SuEWwlnl2UegyZWB4H)aj1qFcyVgcGecGeS(7yLAD99unDd7NndI3NRRqtaKqaKGvyKgndAJmaakyGT0e86LbtJoCuTr2RehGMiAS6lg0WNRQEh88cvRLI690K(AmmbVEzWSS0olYEL4a0erJvFXGg(Cv17GNxOATuuVNM6vIdqtenbuH0)CvLAD990PPXrC)Rng7xslJm7i0tt6akv74iU)1gJ9lPemaakyGT0e86LbtJX(Lucq2Mtt6RXWe86LbtJX(L0YiZU5Z1oBMt)2vvlGnSjO9q8(CDfAcGecGeS6ulTZ0xJHbdQZIIv1k920ySFjTmY2CAsFnggmOolkwPaL3MgJ9lPLr2MZNM0xJHj41ldMgJ9lPLPrT6RXWe86LbtJX(LucApz2nx7Si7vIdqten)fJ2aDwHB0J1Veg7PPi7vIdqtenbuH0)CvLAD990Pj91yy(lgTb6Sc3OhRFjm2MgJ9lPLHegdRhR)fJZNM6vIdqten6UYZawbJQRu1F)sI05ANfzVsCaAIOr3vEgWkyuDLQ(7xsKonntFnggDx5zaRGr1vQ6VFjrAn9F1OH(EGe718Pj91yy0DLNbScgvxPQ)(LePvVdEIg67bsSxZNpFAshqPAhhX9V2ySFjLGKTP2idaGcgylnbVEzW0OdhDoVb5Ys5srwG(EtxnrKLhWcjiAXYYILFhzH82OhRFjm2SOVgdwUbl3ZInWsbZcsyRRrw0XbOrwgxE09ljYYVJSKiHFwco9zb0S8awGxXwSOJdqJSqkqcbqcYB4H)aj1qFcyVgOV30vte10nSVxjoanr08xmAd0zfUrpw)syS1olYzZ0xJH5Vy0gOZkCJES(LWyBAm2VKwMh(dKgBT)7gKWyy9y9VyKaBAit7mmOolkAUSQd(9PjmOolkAUSsbkVNMWG6SOOrTsVRjs4F(0K(Amm)fJ2aDwHB0J1VegBtJX(L0Y8WFG0qFVhxJgKWyy9y9VyKaBAit7mmOolkAUSQwP3ttyqDwu0qbkVRjs4FAcdQZIIgpJwtKW)85ttrQVgdZFXOnqNv4g9y9lHX2SSMpnntFngMGxVmywwttq8(CDfAcGecGeScJ0OzyU2aaOGb2staKqaKG1FhRuRRVNAA0HJQnaGGPNVjpI7FD4O2z6RXWGb1zrXQALEBAm2VKwgzBonPVgddguNffRuGYBtJX(L0YiBZ5Z1olYaacME(gsI2NNttbaqbdSLgm2cyd7QoiHnng7xsltZNZBqUSqExXwSa99MUAIiLfB3VZs5DLNbKfWGLTQuSu69ljszb0S8awSA0YBKLbOzHuGecGeKfB3VZs5bBT08gE4pqsn0Na2Rb67nD1ernDd77vIdqten6UYZawbJQRu1F)sIuTZMPVgdJUR8mGvWO6kv93VKiTM(VA0qFpqsz2nnPVgdJUR8mGvWO6kv93VKiT6DWt0qFpqsz2nxBaauWaBPj41ldMgJ9lPLrO1gzaauWaBPjasiasW6VJvQ113tnlRPPzbaem98n5rC)Rdh1gaafmWwAcGecGeS(7yLAD99utJX(Lucs2MAXG6SOO5YQNr160VDv1cyd7YSBtceXnlvaauWaBPj41ldMgD4OZNZBqUSqkqcF)bswgGMfxPybg8uw(D)zj2jbPSqxnYYVJrzXBm3(zPXrJ0DeMfB7yYsjTdbtWIYcHQXSerzz3PSOqkLLF3tw0ilumqzPXy)YljYcOz53rwiNylGnSzP8GeMf91yWYrzX1bRNLhWYWvkwaJblGMfpJYc5euNffz5OS46G1ZYdybjS11iVHh(dKud9jG9AaI3NRRqnLEmApm4RngHRRXymFQMG4QfA)m91yyAhcMGfToAmlrutJX(L0Y040uK6RXW0oemblAD0ywIOML1CTrQVgdt7qWeSO1rJzjIwPxowQ6Eu6J95MLL2z6RXWqYLWncxXylGnSJX8RyInXReOPXy)skbjgGnXoHNRDM(AmmyqDwuSsbkVnng7xslJya2e7eEAsFnggmOolkwvR0BtJX(L0YigGnXoHNMMfP(AmmyqDwuSQwP3ML10uK6RXWGb1zrXkfO82SSMRnY3vy(gkqr)lGgmDDfcpN3GCzHuGe((dKS87(ZsyhdKqz5gSefSyXBKfW6PhmYcguNffz5bSasvuwGbpl)o2ilGMLJycAKLF)OSy7(DwGcu0)ciVHh(dKud9jG9AaI3NRRqnLEmApm4RG1tpySIb1zrrnbXvl0(zrQVgddguNffRuGYBZYsBK6RXWGb1zrXQALEBwwZ1g57kmFdfOO)fqdMUUcH1gzVsCaAIO5Vy0gOZkCJES(LWyZBqUSqEbplUsXY7nr8PSy7(9lzHq4jmgFbwSD)oy9SaGGDWTSUKib(DKfxhabzjas47pqs5n8WFGKAOpbSxdXaqoUg1uiAqH13BI4tTNmnDd7NPVgddguNffRuGYBtJX(L0YAm2VKonPVgddguNffRQv6TPXy)sAzng7xsNMG4956k0ad(ky90dgRyqDwuCU2ghns3DDfQ99Mi(M)IX6dQWhwgz2P1TQHDmqIwiEFUUcnWGV2yeUUgJX8P8gE4pqsn0Na2Rb6khxJAkenOW67nr8P2tMMUH9Z0xJHbdQZIIvkq5TPXy)sAzng7xsNM0xJHbdQZIIv1k920ySFjTSgJ9lPttq8(CDfAGbFfSE6bJvmOolkoxBJJgP7UUc1(EteFZFXy9bv4dlJm706w1WogirleVpxxHgyWxBmcxxJXy(uEdp8hiPg6ta71a9rLY76q5nQPq0GcRV3eXNApzA6g2ptFnggmOolkwPaL3MgJ9lPL1ySFjDAsFnggmOolkwvR0BtJX(L0YAm2VKonbX7Z1vObg8vW6PhmwXG6SO4CTnoAKU76ku77nr8n)fJ1huHpSmYipADRAyhdKOfI3NRRqdm4RngHRRXymFkVb5Yc5f8S0hX9NfDCaAKfcvJzjIYYny5EwSbwkywCLcyJLOGflpGLghns3zrHuklWR(sISqOAmlruwM97hLfqQIYYUBzHjLfB3VdwplqVCSuSOzBu6J95Z5n8WFGKAOpbSxdq8(CDfQP0Jr7tqDpk9X(8k6TkAfg8AcIRwO9baem98nqW83J2AJSxjoanr0qVCSu19O0h7Z1gzVsCaAIOjCDqHvWOQUbw9eUcJ(VRnaakyGT0OJnfBsUKOPrhoQ2aaOGb2st7qWeSO1rJzjIAA0HJQns91yycE9YGzzPDMt)2vvlGnSltZj0tt6RXWORaay1I(ML1CEdp8hiPg6ta71qmaKJRrnDd7H4956k0KG6Eu6J95v0Bv0km412ySFjLG2TjVHh(dKud9jG9AGUYX1OMUH9q8(CDfAsqDpk9X(8k6TkAfg8ABm2VKsqYkj8gKllLlfzHqb2clGKLaml2UFhSEwcUL1Le5n8WFGKAOpbSxddqhWkyut)xnQPByVBvd7yGeEdYLLYLISqoXwaByZs5bjml2UFNfpJYIcKezbtWI4olkN(xsKfYjOolkYINWS8DuwEalQlrwUNLLfl2UFNfcXsr9MfpHzHuBvdLtg4n8WFGKAOpbSxdySfWg2vDqcRPBy)SaaOGb2stWRxgmng7xsjG(AmmbVEzWaVA)pqsGEL4a0erJvFXGg(Cv17GNxOATuuVlfz2vwaauWaBPbJTa2WUQdsyd8Q9)ajbiBZ5tt6RXWe86LbtJX(L0Y0CEdYLfO4tzX2oMSSvkHGf6oyPGzrhzbEfBHWS8awsWZcac2b3ILzKx0ctyklGKfc1QJYcyWc5OwjYINWS87ilKtqDwuCoVHh(dKud9jG9AaI3NRRqnLEmAVtTQWRylnbXvl0EN(TRQwaByxwjzZiyMDgnwk91yygRoAfmQOALOH(EGKiWUsHb1zrrZLv1k9EoVb5Ys5srwi1w1q5KbwSD)olKcKqaKGAOKYLWncZcuRRVNYINWSadYTFwaqW2wFpYcHyPOEZcOzX2oMSuEfaaRw0NfBGLcMfKWwxJSOJdqJSqQTQHYjdSGe26AKAyrZYjbzHUAKLhWcMp2S4Sq(R0BwiNG6SOil22XKLf9iMSuA70CwSZkWINWS4kflKI8szX2PuSOJbqmYsJoCuwOaqYcMGfXDwGx9Lez53rw0xJblEcZcm4PSS7qqw0rmzHUgJlCy(QOS04Or6ocB4n8WFGKAOpbSxdq8(CDfQP0Jr7dW1aiHV)azL(AcIRwO9ZG4956k0eGRbqcF)bsTrQVgdtWRxgmllTZIKIFvhKlQ5pSTtZR2zfMMWG6SOO5YQALEpnHb1zrrdfO8UMiH)5ANnBgeVpxxHgNAvHxXwttbaem98n5rC)RdhNMMfaqW0Z3qs0(8uBaauWaBPbJTa2WUQdsytJoC05tt9kXbOjIM)IrBGoRWn6X6xcJ9CTWG3qx54A00ySFjTmnxlm4nXaqoUgnng7xslRKODgm4n0hvkVRdL3OPXy)sAzKT50uKVRW8n0hvkVRdL3ObtxxHWZ1cX7Z1vO537tPQuejb7Qn)ETV3eX38xmwFqf(WY0xJHj41ldg4v7)bYsTPHqpnPVgdJUcaGvl6BwwA1xJHrxbaWQf9nng7xsjO(AmmbVEzWaVA)pqsGzKzxP6vIdqtenw9fdA4ZvvVdEEHQ1sr9E(8PPzyeUolle2GXwrB0vvqdNEgqTbaqbdSLgm2kAJUQcA40ZaAAm2VKsqYipeAcmtJLQxjoanr0qVCSu19O0h7ZNpFU2zZImaGGPNVjpI7FD4400miEFUUcnbqcbqcwHrA0mmnfaafmWwAcGecGeS(7yLAD99utJX(LucsMgNRDwK9kXbOjIgDx5zaRGr1vQ6VFjr60Kt)2vvlGnSjOg3uBaauWaBPjasiasW6VJvQ113tnn6WrNpFAACe3)AJX(LucgaafmWwAcGecGeS(7yLAD99utJX(L05tt6akv74iU)1gJ9lPeuFngMGxVmyGxT)hijaz2vQEL4a0erJvFXGg(Cv17GNxOATuuVNZBqUSuUuKfcvJzjIYIT73zHuBvdLtgyzLkKszHq1ywIOSydSuWSOC6ZIcKeXMLF3twi1w1q5KbnXYVJjllkYIooanYB4H)aj1qFcyVgAhcMGfToAmlrunDd71xJHj41ldMgJ9lPLrMgNM0xJHj41ldg4v7)bscAhHMa9kXbOjIgR(Ibn85QQ3bpVq1APOExkYStleVpxxHMaCnas47pqwPpVHh(dKud9jG9AiGkK(NRQU6iMXy(A6g2dX7Z1vOjaxdGe((dKv6RDM(AmmbVEzWaVA)pqwM92rOjqVsCaAIOXQVyqdFUQ6DWZluTwkQ3LIm7MMImaGGPNVbcM)E0E(0K(AmmTdbtWIwhnMLiQzzPvFngM2HGjyrRJgZse10ySFjLGLeceaj86EJvJHJIvxDeZymFZFXyfIRwibMfP(Amm6kaawTOVzzPnY3vy(g67Tc0WgmDDfcpN3Wd)bsQH(eWEnCzW70)dKA6g2dX7Z1vOjaxdGe((dKv6ZBqUSus17Z1villkcZcizX1p19hsz539NfBE(S8aw0rwOoeeMLbOzHuBvdLtgyHcy539NLFhJYI3y(SyZPpcZIMDl6ZIooanYYVJX8gE4pqsn0Na2RbiEFUUc1u6XO9uhcwhGUg86LbnbXvl0(aaOGb2stWRxgmng7xslJSnNMIeI3NRRqtaKqaKGvyKgndAdaiy65BYJ4(xhoYBqUSuUuKYcHcqoSCdwUKfpzHCcQZIIS4jmlFFiLLhWI6sKL7zzzXIT73zHqSuuV1elKARAOCYGMyHCITa2WMLYdsyw8eMLTc7w)bbzbQnVJ5n8WFGKAOpbSxdJvhTcgvuTsut3WEmOolkAUS6zuTZC63UQAbSHnblj2fb6RXWmwD0kyur1krd99ajLsJtt6RXW0oemblAD0ywIOML1CTZ0xJHXQVyqdFUQ6DWZluTwkQ3giUAHe0osFZPj91yycE9YGPXy)sAzA(CTq8(CDfAOoeSoaDn41ldANfzaabtpFtIHgOan80em4noSB9heSsT5DCf2JDIO5VajxsCU2zrgaqW0Z3abZFpApnPVgdt7qWeSO1rJzjIAAm2VKsWssemJ0lvVsCaAIOHE5yPQ7rPp2NpxR(AmmTdbtWIwhnMLiQzznnfP(AmmTdbtWIwhnMLiQzznx7Sidaiy65BijAFEonfaafmWwAWylGnSR6Ge20ySFjTm72CU23BI4B(lgRpOcFyzACAshqPAhhX9V2ySFjLGKTjVb5Ys5srwiKt83zb679WvkwSAqGYYnyb679WvkwoAU9ZYYI3Wd)bsQH(eWEnqFVhUsPPByV(AmmGe)DA1c7aA9hinllT6RXWqFVhUszAC0iD31viVb5YcP8mGkwG(ERanml3GL7zz3PSOqkLLF3tw0iLLgJ9lVKOMyjkyXI3il(ZsjztcWYwPecw8eMLFhzjS6gZNfYjOolkYYUtzrJeGYsJX(LxsK3Wd)bsQH(eWEne8mGQQ(Am0u6XO903BfOH10nSxFngg67Tc0WMgJ9lPeuJANPVgddguNffRuGYBtJX(L0Y040K(AmmyqDwuSQwP3MgJ9lPLPX5AD63UQAbSHDzLKn5nixwGIpLfB7yYcHyPOEZcDhSuWSOJSy1GqaHzb9wfLLhWIoYIRRqwEallkYcPajeajilGKLaaOGb2swMroukM)5kvuw0XaigPS89cz5gSaVITUKilBLsiyjb2yX2PuS4kfWglrblwEalwypWWRIYcMp2SqiwkQ3S4jml)oMSSOilKcKqaKGZ5n8WFGKAOpbSxdq8(CDfQP0Jr7TAqOATuuVRO3QOAcIRwO9baem98n5rC)Rdh12RehGMiAS6lg0WNRQEh88cvRLI6Tw91yyS6lg0WNRQEh88cvRLI6TbIRwibC63UQAbSHnbIyz2hXn3uleVpxxHMaiHaibRWinAg0gaafmWwAcGecGeS(7yLAD99utJX(Luc60VDv1cydBnte3SuedWMyNWAXG6SOO5YQNr160VDv1cyd7YG4956k0eajeajy1PwAdaGcgylnbVEzW0ySFjTmnYBqUSuUuKfOV3dxPyX297Sa9rLYBwiV9nEwanlVDAolKUvGfpHzjbSa99wbAynXITDmzjbSa99E4kflhLLLflGMLhWIvdcSqiwkQ3SyBhtwCDaeKLsYMSSvkHygOz53rwqVvrzHqSuuVzXQbbwG4956kKLJYY3lColGMfh2Y)dcYc1M3XSS7uw0CcqXaLLgJ9lVKilGMLJYYLSmuhX9N3Wd)bsQH(eWEnqFVhUsPPBy)S3vy(g6JkL3v4(gVbtxxHWttu8R6GCrn)HTDAEL0TcZ1g57kmFd99wbAydMUUcH1QVgdd99E4kLPXrJ0DxxHAJSxjoanr08xmAd0zfUrpw)syS1otFnggR(Ibn85QQ3bpVq1APOEBG4QfwM92PXn1gP(AmmbVEzWSS0odI3NRRqJtTQWRyRPj91yyi5s4gHRySfWg2Xy(vmXM4vc0SSMMG4956k0y1Gq1APOExrVvrNpnnlaGGPNVjXqduGgw77kmFd9rLY7kCFJ3GPRRqyTZGbVXHDR)GGvQnVJRWEStenng7xsltZNM8WFG04WU1FqWk1M3Xvyp2jIMlRd1rC)NpFU2zbaqbdSLMGxVmyAm2VKwgzBonfaafmWwAcGecGeS(7yLAD99utJX(L0YiBZ58gKllK3vSfLLTsjeSOJdqJSqkqcbqcYYIEjrw(DKfsbsiasqwcGe((dKS8awc7yGewUblKcKqaKGSCuw8WVCLkklUoy9S8aw0rwco95n8WFGKAOpbSxd03B6QjIA6g2dX7Z1vOXQbHQ1sr9UIERIYBqUSuUuKfnlaiPSyBhtwIcwS4nYIRdwplpqdEJSeClRljYsy3BIiLfpHzj2jbzHUAKLFhJYI3ilxYINSqob1zrrwO)PuSmanlA2QzPbcLMfVHh(dKud9jG9AirB1yai10nS3TQHDmqI2zHDVjIu7TtBJHDVjI1)IrcQXPPWU3erQ9rCoVHh(dKud9jG9Ay3vJAmaKA6g27w1Wogir7SWU3erQ92PTXWU3eX6FXib140uy3BIi1(iox7m91yyWG6SOyvTsVnng7xsldjmgwpw)lgNM0xJHbdQZIIvkq5TPXy)sAziHXW6X6FX4CEdp8hiPg6ta71WyPu1yai10nS3TQHDmqI2zHDVjIu7TtBJHDVjI1)IrcQXPPWU3erQ9rCU2z6RXWGb1zrXQALEBAm2VKwgsymSES(xmonPVgddguNffRuGYBtJX(L0YqcJH1J1)IX58gKllLlfzb67nD1erwiKt83zXQbbklEcZc8k2ILTsjeSyBhtwi1w1q5KbnXc5eBbSHnlLhKWAILFhzPKkM)E0Mf91yWYrzX1bRNLhWYWvkwaJblGMLOG12WSeClw2kLqWB4H)aj1qFcyVgOV30vte10nShdQZIIMlREgv7m91yyaj(70AqHExHC0dKML10K(AmmKCjCJWvm2cyd7ym)kMyt8kbAwwtt6RXWe86LbZYs7Sidaiy65BijAFEonfaafmWwAWylGnSR6Ge20ySFjTmnonPVgdtWRxgmng7xsjiXaSj2jCPgkaON50VDv1cydBndeVpxxHgkTga0F(CTZImaGGPNVbcM)E0EAsFngM2HGjyrRJgZse10ySFjLGedWMyNWLkGNA2mN(TRQwaBytasFZs9UcZ3mwD0kyur1krdMUUcHNRzG4956k0qP1aG(Zjqel17kmFtI2QXaqAW01viS2i7vIdqten0lhlvDpk9X(CT6RXW0oemblAD0ywIOML10K(AmmTdbtWIwhnMLiALE5yPQ7rPp2NBwwttZ0xJHPDiycw06OXSernng7xsjOh(dKg6794A0GegdRhR)fJAPwOsv3D6JeCtdPpnPVgdt7qWeSO1rJzjIAAm2VKsqp8hin2A)3niHXW6X6FX40K(Ammw9fdA4ZvvVdEEHQ1sr92aXvlSm7TJSn1oZPF7QQfWg2LbX7Z1vOHsRba9lLDrGgNM0xJHPDiycw06OXSernng7xslZU5A1xJHPDiycw06OXSernng7xsji5zAcI3NRRqZfHW1aiHV)aP2aaOGb2sZL0qVExxH1iC55VIRWiKlGMgD4OAXiCDwwiS5sAOxVRRWAeU88xXvyeYfW5A1xJHPDiycw06OXSernlRPPi1xJHPDiycw06OXSernllTrgaafmWwAAhcMGfToAmlrutJoC05ttq8(CDfACQvfEfBnnPdOuTJJ4(xBm2VKsqIbytSt4sfWtnZPF7QQfWg2AgiEFUUcnuAnaO)858gKllLUJYYdyj2jbz53rw0r6ZcyWc03BfOHzrpkl03dKCjrwUNLLflr46cKOIYYLS4zuwiNG6SOil6RNfcXsr9MLJMB)S46G1ZYdyrhzXQbHacZB4H)aj1qFcyVgOV30vte10nS)DfMVH(ERanSbtxxHWAJSxjoanr08xmAd0zfUrpw)syS1otFngg67Tc0WML10Kt)2vvlGnSlRKS5CT6RXWqFVvGg2qFpqcbJO2z6RXWGb1zrXkfO82SSMM0xJHbdQZIIv1k92SSMRvFnggR(Ibn85QQ3bpVq1APOEBG4Qfsq7i0BQDwaauWaBPj41ldMgJ9lPLr2MttrcX7Z1vOjasiasWkmsJMbTbaem98n5rC)RdhNZBqUSqo0)I9hPSSdSXs8kSZYwPecw8gzHOFjcZIf2SqXaiHnSqiNQOS8ojiLfNfA6w0DWZYa0S87ilHv3y(SqVF5)bswOawSbwk4C7NfDKfpewT)ildqZIYBIyZYFX4O9yKYB4H)aj1qFcyVgG4956kutPhJ27ulcb2qXGMG4QfApguNffnxwvR07sP5Agp8hin037X1Objmgwpw)lgjqKyqDwu0CzvTsVl1mYdbExH5BOGLQcg1FhRdqJ03GPRRq4sfX5Agp8hin2A)3niHXW6X6FXib20q6AuZqTqLQU70hjWMgnwQ3vy(M0)vJ0QUR8mGgmDDfcZBqUSqExXwSa99MUAIilxYINSqob1zrrwCkluaizXPSybO0txHS4uwuGKiloLLOGfl2oLIfmHzzzXIT73zrZ3KaSyBhtwW8X(sIS87iljs4NfYjOolkQjwGb52plk8z5EwSAqGfcXsr9wtSadYTFwaqW2wFpYINSqiN4VZIvdcS4jmlwaGIfDCaAKfsTvnuozGfpHzHCITa2WMLYdsyEdp8hiPg6ta71a99MUAIOMUH9r2RehGMiA(lgTb6Sc3OhRFjm2ANPVgdJvFXGg(Cv17GNxOATuuVnqC1cjODe6nNM0xJHXQVyqdFUQ6DWZluTwkQ3giUAHe0onUP23vy(g6JkL3v4(gVbtxxHWZ1oddQZIIMlRuGYBTo9BxvTa2WMaq8(CDfACQfHaBOyOu6RXWGb1zrXkfO820ySFjLaWG3mwD0kyur1krZFbsO1gJ9llLDgnwMMV50eguNffnxwvR0BTo9BxvTa2WMaq8(CDfACQfHaBOyOu6RXWGb1zrXQALEBAm2VKsayWBgRoAfmQOALO5Vaj0AJX(LLYoJglRKS5CTrQVgddiXFNwTWoGw)bsZYsBKVRW8n03BfOHny66kew7SaaOGb2stWRxgmng7xslJqpnrblL(LWMFVpLQsrKeSny66kewR(Amm)EFkvLIijyBOVhiHGrmIrWSEL4a0erd9YXsv3JsFSpVu2nx74iU)1gJ9lPLr2MBQDCe3)AJX(LucA3MBox7Sidaiy65BijAFEonfaafmWwAWylGnSR6Ge20ySFjTm7MZBqUSuUuKfnlaiPSCjlEgLfYjOolkYINWSqDiilA26QbbiulLIfnlaizzaAwi1w1q5Kbw8eMLskxc3imlKtSfWg2Xy(gw2QIcyzrrw2IMflEcZcHsZIf)z53rwWeMfWGfcvJzjIYINWSadYTFwu4Zc5Trpw)sySzz4kflGXG3Wd)bsQH(eWEnKOTAmaKA6g27w1WogirleVpxxHgQdbRdqxdE9YG2z6RXWGb1zrXQALEBAm2VKwgsymSES(xmonPVgddguNffRuGYBtJX(L0YqcJH1J1)IX58gE4pqsn0Na2RHDxnQXaqQPByVBvd7yGeTq8(CDfAOoeSoaDn41ldANPVgddguNffRQv6TPXy)sAziHXW6X6FX40K(AmmyqDwuSsbkVnng7xsldjmgwpw)lgNRDM(AmmbVEzWSSMM0xJHXQVyqdFUQ6DWZluTwkQ3giUAHe0E7iBZ5ANfzaabtpFdem)9O90K(AmmTdbtWIwhnMLiQPXy)skbNPXiWUs1RehGMiAOxowQ6Eu6J95Z1QVgdt7qWeSO1rJzjIAwwttrQVgdt7qWeSO1rJzjIAwwZ1olYEL4a0erZFXOnqNv4g9y9lHXEAcjmgwpw)lgjO(Amm)fJ2aDwHB0J1VegBtJX(L0PPi1xJH5Vy0gOZkCJES(LWyBwwZ5n8WFGKAOpbSxdJLsvJbGut3WE3Qg2XajAH4956k0qDiyDa6AWRxg0otFnggmOolkwvR0BtJX(L0YqcJH1J1)IXPj91yyWG6SOyLcuEBAm2VKwgsymSES(xmox7m91yycE9YGzznnPVgdJvFXGg(Cv17GNxOATuuVnqC1cjO92r2MZ1olYaacME(gsI2NNtt6RXWqYLWncxXylGnSJX8RyInXReOzznx7Sidaiy65BGG5VhTNM0xJHPDiycw06OXSernng7xsjOg1QVgdt7qWeSO1rJzjIAwwAJSxjoanr0qVCSu19O0h7ZNMIuFngM2HGjyrRJgZse1SSMRDwK9kXbOjIM)IrBGoRWn6X6xcJ90esymSES(xmsq91yy(lgTb6Sc3OhRFjm2MgJ9lPttrQVgdZFXOnqNv4g9y9lHX2SSMZBqUSuUuKfcja5WcizjaZB4H)aj1qFcyVgS5DFGUcgvuTsK3GCzPCPilqFVhxJS8awSAqGfOaL3Sqob1zrrnXcP2QgkNmWYUtzrHukl)fJS87EYIZcHu7)oliHXW6rwu44zb0Sasvuwi)v6nlKtqDwuKLJYYYYWcH097SuA70CwSZkWcMp2S4SafO8MfYjOolkYYnyHqSuuVzH(NsXYUtzrHukl)UNSyhzBYc99ajuw8eMfsTvnuozGfpHzHuGecGeKLDhcYsmOrw(DpzHmcnLfsrEzPXy)YljAyPCPilUoacYIDACtndl7o9rwGx9LezHq1ywIOS4jml2zNDAgw2D6JSy7(DW6zHq1ywIO8gE4pqsn0Na2Rb6794Aut3WEmOolkAUSQwP3AJuFngM2HGjyrRJgZse1SSMMWG6SOOHcuExtKW)00mmOolkA8mAnrc)tt6RXWe86LbtJX(Luc6H)aPXw7)Ubjmgwpw)lg1QVgdtWRxgmlR5ANfjf)QoixuZFyBNMxTZkmn1RehGMiAS6lg0WNRQEh88cvRLI6Tw91yyS6lg0WNRQEh88cvRLI6TbIRwibTJSn1gaafmWwAcE9YGPXy)sAzKrO1olYaacME(M8iU)1HJttbaqbdSLMaiHaibR)owPwxFp10ySFjTmYi0Z1olY2dO5BGsnnfaafmWwA0XMInjxs00ySFjTmYi0ZNpnHb1zrrZLvpJQDM(Amm28UpqxbJkQwjAwwttuluPQ7o9rcUPH01O2zrgaqW0Z3abZFpApnfP(AmmTdbtWIwhnMLiQzznFAkaGGPNVbcM)E0wl1cvQ6UtFKGBAi958gKllLlfzHqQ9FNfWVJTTJISyB)c7SCuwUKfOaL3Sqob1zrrnXcP2QgkNmWcOz5bSy1GalK)k9MfYjOolkYB4H)aj1qFcyVgS1(VZBqUSqOCL637fVHh(dKud9jG9AOxz1d)bYQ6OVMspgTF4k1V3RcOulmuSfY20UIV4lka]] )


end