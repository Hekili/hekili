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


    spec:RegisterPack( "Balance", 20220319, [[dm1Q9fqikvEePGUeKkztKsFsPuJsbDkfYQuG8kiWSif6wKIYUO4xqQAykuogKYYOu1ZecnniOUgPiBdsL6BqqACcboNcaRtbO5bHCpHO9Pu0)uau1avau5GkL0cvOYdHKmrsrLlskWgHKsFubqyKqsr5KkuvRuPWlvauMjKkUjPOk7uPe)KuuvdfcIJQaiAPqsrEkGMQcuxvHQSvfaPVcjfglKuTxr8xrnyIdt1IjvpwWKb6YiBwrFgIgTs1Pvz1qsr1RHeZMKBlu7wYVbnCk54cbTCPEoutxvxxjBhGVtPmEiuNxiTEfqZxK2pQtqlzWjab9Ns2I9JzV9Jfr0gag0q4igr7r3ja)OwucqlpGIJKsawEmLaCCUYRaLa0YJQGoyYGtaIHRoqja3)3cpGOh96UYRaPz4loyqE)(s3Cq0pox5vG0mGxmQqFmOz)JvdWppffPUR8kqMhXFcq91P(XVs0tac6pLSf7hZE7hlIOnamOHW2JWJPPeG(63HDcqGxmQsaUFGGuLONaeKWHeGJZvEfiw0C96a5n088oSZcAdanYI9JzV98g8gOA3lKeEa5n0mw2kiibYcqOYBwgh5XgEdnJfuT7fscKL3BK0NVjlbhtywEilHObfLFVrsp2WBOzSGAIIHaiqwwvrbcJ9okla8(CDfHzz4ziJgzXQjaz87nE1ijw0SnzXQjag87nE1iPrgEdnJLTcaEGSy1uWX)vizb1O9FNLBYY9BJz53jwS1WcjlAqqDwyYWBOzSO55OqSGkybaIcXYVtSa0667XS4SOU)velXWMyzQieF6kILH3KLOWfl7oyT9ZY(9SCpl4lEPEVi4cRIYIT73zzCA(BDWSGawqfPi8FUILTQoKvmvVgz5(TbzbJYznYWBOzSO55OqSedXplBppK7FUPy)k82SGdu59bXS4wwQOS8qw0HymlZd5(JzbwQOgEdnJLb3K)SmyymXcCYY4u(olJt57SmoLVZIJzXzbBrHZvS89vOqVH3qZyrZ3IkQzz4ziJgzb1O9FxJSGA0(VRrwa(EpVMgXsSdsSedBILMWN6O6z5HSqERoQzjaJ19xZWV3VH3qZyb1EiMLbyxb2eilAqSf0g1Xu9Se2PakSmHnlOsZXYc7ijtcq1HFCYGtacTOI6KbNSf0sgCcqQCDfbMmUeGE4pyLa0w7)Ecqqch6Z6pyLaeH0uWXpl2ZcQr7)olEbYIZcW3B8QrsSalwaoywSD)olB5qU)SGADIfVazzCWToywGnlaFVNxtSa)DQTDykbyOVN6ZtaoKfkOolmzuRY7Cri(zjnLfkOolmzUkJHkVzjnLfkOolmzUkRd)DwstzHcQZctgVIMlcXplJyrllwnbWGMXw7)olAzXowSAcGXEJT2)9Kpzl2Nm4eGu56kcmzCja9WFWkbi(9EEnLam03t95jahYYqwSJLEv0e2ijJUR8kqz4m7kv(3Vcj2qLRRiqwstzXowcqau51BQd5(NNoXsAkl2Xc2IuQ87ns6Xg8790vkwIKf0yjnLf7y5DfvVP8F1eoR7kVcKHkxxrGSmIL0uwgYcfuNfMmyOY7Cri(zjnLfkOolmzUkRwL3SKMYcfuNfMmxL1H)olPPSqb1zHjJxrZfH4NLrSmIfTSyhly6Z6WAHn)rT9rq2ERqcq1vuoaMautjFYwIyYGtasLRRiWKXLa0d)bReG43B8Qrsjad99uFEcWHS0RIMWgjz0DLxbkdNzxPY)(viXgQCDfbYIwwcqau51BQd5(NNoXIwwWwKsLFVrsp2GFVNUsXsKSGglJyrll2XcM(SoSwyZFuBFeKT3kKauDfLdGja1uYN8jabPPVuFYGt2cAjdobOh(dwjaXqL3zDYJtasLRRiWKXL8jBX(KbNaKkxxrGjJlbyOVN6Zta(xmXcIyzil2ZYGyXd)blJT2)DtWXF(VyIfeWIh(dwg8798AYeC8N)lMyzucq83x4t2cAja9WFWkbyWvQSh(dwz1H)eGQd)5YJPeGqlQOo5t2setgCcqQCDfbMmUeGqReGy6ta6H)GvcqaEFUUIsacWvlkbi2IuQ87ns6Xg8790vkw2Kf0yrlldzXowExr1BWV3kydAOY1veilPPS8UIQ3GFsP8od238nu56kcKLrSKMYc2IuQ87ns6Xg8790vkw2Kf7tacs4qFw)bReGaPhZYwHAalWILiIawSD)oC9Sa238zXlqwSD)olaFVvWgKfVazXEeWc83P22HPeGa8oxEmLa8WzhsjFYwq4KbNaKkxxrGjJlbi0kbiM(eGE4pyLaeG3NRROeGaC1IsaITiLk)EJKESb)EpVMyztwqlbiiHd9z9hSsacKEmlbf5aiwSTtflaFVNxtSe8IL97zXEeWY7ns6XSyB)c7SCywAsra86zzcBw(DIfniOolmXYdzrNyXQPj1nbYIxGSyB)c7SmpLIAwEilbh)jab4DU8ykb4HZbf5aOKpzlAkzWjaPY1veyY4sacTsaIPpbOh(dwjab4956kkbiaxTOeGwnbiJmaAqZedH18AIL0uwSAcqgza0GMbVQ51elPPSy1eGmYaObnd(9gVAKelPPSy1eGmYaObnd(9E6kflPPSy1eGmYaObnZC1rZWzMuRIyjnLfRMayAhavWfopBQgyuwstzrFnNMGNVkyAk2VcZsKSOVMttWZxfmGR2)dwSKMYcaVpxxrMdNDiLaeKWH(S(dwjahG6956kILF3Fwc7uafml3KLOWflEtSCflolidGS8qwCaWdKLFNybF)Y)dwSyBNAIfNLVVcf6zH(alhMLfMaz5kw0P3grflbh)4eGa8oxEmLa8QmYayYNSf0DYGtasLRRiWKXLa0d)bReG6uJPgLRqMaeKWH(S(dwjahpmXY4OgtnkxHKf)z53jwOcKf4KfuBt1aJYITDQyz3XpXYHzX1Haiwq3JHU0il(8PMfublaquiwSD)olJd6dMfVazb(7uB7Wel2UFNfuTv0p(vibyOVN6ZtaoKLHSyhlbiaQ86n1HC)ZtNyjnLf7yjaHkqOTYeGfaiku(3Pm2667XMLflPPSyhl9QOjSrsgDx5vGYWz2vQ8VFfsSHkxxrGSmIfTSOVMttWZxfmnf7xHzztwqttSOLf91CAAhavWfopBQgyuttX(vywqelimlAzXowcqau51Baq1VhTzjnLLaeavE9gau97rBw0YI(AonbpFvWSSyrll6R500oaQGlCE2unWOMLflAzzil6R500oaQGlCE2unWOMMI9RWSGOizbn7zrZybHzzqS0RIMWgjzWxnxQ8Eu8t95gQCDfbYsAkl6R50e88vbttX(vywqelOHglPPSGglONfSfPu5Dh)eliIf0mOBwgXYiw0YcaVpxxrMRYidGjFYwqOjdobivUUIatgxcWqFp1NNaCil6R50e88vbttX(vyw2Kf00elAzzil2XsVkAcBKKbF1CPY7rXp1NBOY1veilPPSOVMtt7aOcUW5zt1aJAAk2VcZcIybTbalAzrFnNM2bqfCHZZMQbg1SSyzelPPSOdXyw0YY8qU)5MI9RWSGiwSxtSmIfTSaW7Z1vK5QmYaycqqch6Z6pyLaeHaFwSD)ololOAROF8Ral)U)SC4A7NfNfeYsH9MfRggyb2SyBNkw(DIL5HC)z5WS46W1ZYdzHkWeGE4pyLa0c(hSs(KTebjdobivUUIatgxcqOvcqm9ja9WFWkbiaVpxxrjab4QfLamqNILHSmKL5HC)Znf7xHzrZybnnXIMXsacvGqBLj45RcMMI9RWSmIf0ZcArWySmILnzjqNILHSmKL5HC)Znf7xHzrZybnnXIMXsacvGqBLjalaquO8VtzS113Jnnf7xHzzelONf0IGXyzelAzXowA)aZeaQEJdcIneIp8JzrlldzXowcqOceARmbpFvW0KdgLL0uwSJLaeQaH2ktawaGOq5FNYyRRVhBAYbJYYiwstzjaHkqOTYe88vbttX(vyw2KLREQTGk)jW88qU)5MI9RWSKMYsVkAcBKKjqkc)NRYyRRVhBOY1veilAzjaHkqOTYe88vbttX(vyw2KLioglPPSeGqfi0wzcWcaefk)7ugBD99yttX(vyw2KLREQTGk)jW88qU)5MI9RWSOzSG2ySKMYIDSeGaOYR3uhY9ppDkbiiHd9z9hSsaIkxfwk)jml22PFNAww4RqYcQGfaikelf0gl2oLIfxPG2yjkCXYdzb)NsXsWXpl)oXc2Jjw8y4QEwGtwqfSaarHqaQ2k6h)kWsWXpobiaVZLhtjadWcaefkds4Ovi5t2YaizWjaPY1veyY4sacTsaIPpbOh(dwjab4956kkbiaxTOeGdz59gj9M)IP8dZGhXYMSGMMyjnLL2pWmbGQ34GGyZvSSjlAAmwgXIwwgYYqwOiCDwweOHITI2KRYWgS8kqSOLLHSyhlbiaQ86naO63J2SKMYsacvGqBLHITI2KRYWgS8kqMMI9RWSGiwqdDJqzbbSmKfnXYGyPxfnHnsYGVAUu59O4N6Znu56kcKLrSmIfTSyhlbiubcTvgk2kAtUkdBWYRazAYbJYYiwstzHIW1zzrGgmCPu0)xHm3l9OSOLLHSyhlbiaQ86n1HC)ZtNyjnLLaeQaH2kdgUuk6)RqM7LE0CerynfbJHMPPy)kmliIf0qdHzzelPPSmKLaeQaH2kJo1yQr5kKMMCWOSKMYIDS0EGmFdvkwstzjabqLxVPoK7FE6elJyrlldzXowExr1BMRoAgoZKAvKHkxxrGSKMYsacGkVEdaQ(9OnlAzjaHkqOTYmxD0mCMj1QittX(vywqelOHgliGfnXYGyPxfnHnsYGVAUu59O4N6Znu56kcKL0uwSJLaeavE9gau97rBw0YsacvGqBLzU6Oz4mtQvrMMI9RWSGiw0xZPj45RcgWv7)blwqalOzpldILEv0e2ijJvFXWg8Cv27GxxiBTuyVnu56kcKfnJf0SNLrSOLLHSqr46SSiqZv4qVExxr5iC51VIZGeGlqSOLLaeQaH2kZv4qVExxr5iC51VIZGeGlqMMI9RWSGiw0elJyjnLLHSmKfkcxNLfbAW7oi0gbMHTEgoZpSJP6zrllbiubcTvMh2Xu9ey(k8HC)ZrutAkI2JMPPy)kmlJyjnLLHSmKfaEFUUImWkVWu(7RqHEwIKf0yjnLfaEFUUImWkVWu(7RqHEwIKLiYYiw0YYqw((kuO38OzAYbJMdqOceARyjnLLVVcf6npAMaeQaH2kttX(vyw2KLREQTGk)jW88qU)5MI9RWSOzSG2ySmIL0uwa4956kYaR8ct5VVcf6zjswSNfTSmKLVVcf6nV9MMCWO5aeQaH2kwstz57RqHEZBVjaHkqOTY0uSFfMLnz5QNAlOYFcmppK7FUPy)kmlAglOnglJyjnLfaEFUUImWkVWu(7RqHEwIKLXyzelJyzucqqch6Z6pyLaC8WeilpKfqs5rz53jwwyhjXcCYcQ2k6h)kWITDQyzHVcjlGWLUIybwSSWelEbYIvtaO6zzHDKel22PIfVyXbbzHaq1ZYHzX1HRNLhYc4rjab4DU8ykbyamhGf49hSs(KTG2yjdobivUUIatgxcqOvcqm9ja9WFWkbiaVpxxrjab4QfLa0owWWLs)kqZV3NsLXeHc1gQCDfbYsAklZd5(NBk2VcZYMSy)yJXsAkl6qmMfTSmpK7FUPy)kmliIf71eliGLHSGWJXIMXI(Aon)EFkvgtekuBWVhqHLbXI9SmIL0uw0xZP537tPYyIqHAd(9akSSjlrmcyrZyzil9QOjSrsg8vZLkVhf)uFUHkxxrGSmiwSNLrjabjCOpR)GvcWbOEFUUIyzHjqwEilGKYJYIxrz57RqHEmlEbYsaeZITDQyXMF)vizzcBw8IfnyzTd7ZzXQHHeGa8oxEmLa837tPYyIqH6Sn)(KpzlOHwYGtasLRRiWKXLaeKWH(S(dwjahpmXIgeBfTjxXIMFdwEfiwSFmmfWSOttytS4SGQTI(XVcSSWelWMfmKLF3FwUNfBNsXI6kILLfl2UFNLFNyHkqwGtwqTnvdmAcWYJPeGuSv0MCvg2GLxbkbyOVN6ZtagGqfi0wzcE(QGPPy)kmliIf7hJfTSeGqfi0wzcWcaefk)7ugBD99yttX(vywqel2pglAzzila8(CDfz(9(uQmMiuOoBZVNL0uw0xZP537tPYyIqHAd(9akSSjlrCmwqaldzPxfnHnsYGVAUu59O4N6Znu56kcKLbXsezzelJyrlla8(CDfzUkJmaYsAkl6qmMfTSmpK7FUPy)kmliILiIqta6H)Gvcqk2kAtUkdBWYRaL8jBbn7tgCcqQCDfbMmUeGGeo0N1FWkb44Hjwacxkf9xHKfutl9OSGUXuaZIonHnXIZcQ2k6h)kWYctSaBwWqw(D)z5EwSDkflQRiwwwSy7(Dw(DIfQazbozb12unWOjalpMsaIHlLI()kK5EPhnbyOVN6ZtaoKLaeQaH2ktWZxfmnf7xHzbrSGUzrll2XsacGkVEdaQ(9OnlAzXowcqau51BQd5(NNoXsAklbiaQ86n1HC)ZtNyrllbiubcTvMaSaarHY)oLXwxFp20uSFfMfeXc6MfTSmKfaEFUUImbybaIcLbjC0kWsAklbiubcTvMGNVkyAk2VcZcIybDZYiwstzjabqLxVbav)E0MfTSmKf7yPxfnHnsYGVAUu59O4N6Znu56kcKfTSeGqfi0wzcE(QGPPy)kmliIf0nlPPSOVMtt7aOcUW5zt1aJAAk2VcZcIybTXybbSmKfnXYGyHIW1zzrGMRWFVcpSXzWdWvuwNukwgXIww0xZPPDaubx48SPAGrnllwgXsAkl6qmMfTSmpK7FUPy)kmliIf71elPPSqr46SSiqdfBfTjxLHny5vGyrllbiubcTvgk2kAtUkdBWYRazAk2VcZYMSy)ySmIfTSaW7Z1vK5QmYailAzXowOiCDwweO5kCOxVRROCeU86xXzqcWfiwstzjaHkqOTYCfo0R31vuocxE9R4mib4cKPPy)kmlBYI9JXsAkl6qmMfTSmpK7FUPy)kmliIf7hlbOh(dwjaXWLsr)FfYCV0JM8jBbTiMm4eGu56kcmzCjaHwjaX0Na0d)bReGa8(CDfLaeGRwucq91CAcE(QGPPy)kmlBYcAAIfTSmKf7yPxfnHnsYGVAUu59O4N6Znu56kcKL0uw0xZPPDaubx48SPAGrnnf7xHzbrrYcAAYOjwqaldzjIgnXYGyrFnNgDfecQw43SSyzeliGLHSGWgnXIMXsenAILbXI(Aon6kieuTWVzzXYiwgelueUollc0Cf(7v4HnodEaUIY6KsXccybHnAILbXYqwOiCDwweO53P88A8NXhYtXIwwcqOceARm)oLNxJ)m(qEkttX(vywquKSy)ySmIfTSOVMtt7aOcUW5zt1aJAwwSmIL0uw0HymlAzzEi3)CtX(vywqel2RjwstzHIW1zzrGgk2kAtUkdBWYRaXIwwcqOceARmuSv0MCvg2GLxbY0uSFfobiiHd9z9hSsaUvLnpkMLfMyz8hGuZXIT73zbvBf9JFfyb2S4pl)oXcvGSaNSGABQgy0eGa8oxEmLa8IqWCawG3FWk5t2cAiCYGtasLRRiWKXLa0d)bReGxHd96DDfLJWLx)kodsaUaLam03t95jab4956kYCriyoalW7pyXIwwa4956kYCvgzamby5XucWRWHE9UUIYr4YRFfNbjaxGs(KTGMMsgCcqQCDfbMmUeGGeo0N1FWkb44HjwaU7GqBeilA(Tol60e2elOAROF8RqcWYJPeG4DheAJaZWwpdN5h2Xu9jad99uFEcWHSeGqfi0wzcE(QGPjhmklAzXowcqau51BQd5(NNoXIwwa4956kY879PuzmrOqD2MFplAzzilbiubcTvgDQXuJYvinn5GrzjnLf7yP9az(gQuSmIL0uwcqau51BQd5(NNoXIwwcqOceARmbybaIcL)DkJTU(ESPjhmklAzzila8(CDfzcWcaefkds4OvGL0uwcqOceARmbpFvW0KdgLLrSmIfTSacFdEvZRjZFbuUcjlAzzilGW3GFsP8opvEtM)cOCfswstzXowExr1BWpPuENNkVjdvUUIazjnLfSfPu53BK0Jn43751elBYsezzelAzbe(MyiSMxtM)cOCfsw0YYqwa4956kYC4SdjwstzPxfnHnsYO7kVcugoZUsL)9RqInu56kcKL0uwC83UkBbTrnlBgjldGXyjnLfaEFUUImbybaIcLbjC0kWsAkl6R50ORGqq1c)MLflJyrll2XcfHRZYIanxHd96DDfLJWLx)kodsaUaXsAklueUollc0Cfo0R31vuocxE9R4mib4celAzjaHkqOTYCfo0R31vuocxE9R4mib4cKPPy)kmlBYsehJfTSyhl6R50e88vbZYIL0uw0HymlAzzEi3)CtX(vywqeli8yja9WFWkbiE3bH2iWmS1ZWz(HDmvFYNSf0q3jdobivUUIatgxcqqch6Z6pyLaCW7hMLdZIZs7)o1Sqkxh2(tSyZJYYdzj2rHyXvkwGfllmXc(9NLVVcf6XS8qw0jwuxrGSSSyX297SGQTI(XVcS4filOcwaGOqS4fillmXYVtSyFbYcwbFwGflbqwUjl6WFNLVVcf6XS4nXcSyzHjwWV)S89vOqpobyOVN6ZtaoKfaEFUUImWkVWu(7RqHEwSlswqJfTSyhlFFfk0BE7nn5GrZbiubcTvSKMYYqwa4956kYaR8ct5VVcf6zjswqJL0uwa4956kYaR8ct5VVcf6zjswIilJyrlldzrFnNMGNVkywwSOLLHSyhlbiaQ86naO63J2SKMYI(AonTdGk4cNNnvdmQPPy)kmliGLHSerJMyzqS0RIMWgjzWxnxQ8Eu8t95gQCDfbYYiwquKS89vOqV5rZOVMZm4Q9)GflAzrFnNM2bqfCHZZMQbg1SSyjnLf91CAAhavWfopBQgy0m(Q5sL3JIFQp3SSyzelPPSeGqfi0wzcE(QGPPy)kmliGf7zztw((kuO38OzcqOceARmGR2)dwSOLf7yrFnNMGNVkywwSOLLHSyhlbiaQ86n1HC)ZtNyjnLf7ybG3NRRitawaGOqzqchTcSmIfTSyhlbiaQ86nOeTpVyjnLLaeavE9M6qU)5PtSOLfaEFUUImbybaIcLbjC0kWIwwcqOceARmbybaIcL)DkJTU(ESzzXIwwSJLaeQaH2ktWZxfmllw0YYqwgYI(AonuqDwykRwL3MMI9RWSSjlOnglPPSOVMtdfuNfMYyOYBttX(vyw2Kf0gJLrSOLf7yPxfnHnsYO7kVcugoZUsL)9RqInu56kcKL0uwgYI(Aon6UYRaLHZSRu5F)kK4C5)Qjd(9akSejlAIL0uw0xZPr3vEfOmCMDLk)7xHeN9o4fzWVhqHLizjcyzelJyjnLf91CAq5kWMaZuSf0g1Xu9zQOg5nqYSSyzelPPSOdXyw0YY8qU)5MI9RWSGiwSFmwstzbG3NRRidSYlmL)(kuONLizzmwgXIwwa4956kYCvgzambiwbFCcWVVcf6rlbOh(dwja)(kuOhTKpzlOHqtgCcqQCDfbMmUeGE4pyLa87RqHE7tag67P(8eGdzbG3NRRidSYlmL)(kuONf7IKf7zrll2XY3xHc9Mhnttoy0CacvGqBflPPSaW7Z1vKbw5fMYFFfk0ZsKSyplAzzil6R50e88vbZYIfTSmKf7yjabqLxVbav)E0ML0uw0xZPPDaubx48SPAGrnnf7xHzbbSmKLiA0eldILEv0e2ijd(Q5sL3JIFQp3qLRRiqwgXcIIKLVVcf6nV9g91CMbxT)hSyrll6R500oaQGlCE2unWOMLflPPSOVMtt7aOcUW5zt1aJMXxnxQ8Eu8t95MLflJyjnLLaeQaH2ktWZxfmnf7xHzbbSyplBYY3xHc9M3EtacvGqBLbC1(FWIfTSyhl6R50e88vbZYIfTSmKf7yjabqLxVPoK7FE6elPPSyhla8(CDfzcWcaefkds4OvGLrSOLf7yjabqLxVbLO95flAzzil2XI(AonbpFvWSSyjnLf7yjabqLxVbav)E0MLrSKMYsacGkVEtDi3)80jw0YcaVpxxrMaSaarHYGeoAfyrllbiubcTvMaSaarHY)oLXwxFp2SSyrll2XsacvGqBLj45RcMLflAzzildzrFnNgkOolmLvRYBttX(vyw2Kf0gJL0uw0xZPHcQZctzmu5TPPy)kmlBYcAJXYiw0YIDS0RIMWgjz0DLxbkdNzxPY)(viXgQCDfbYsAkldzrFnNgDx5vGYWz2vQ8VFfsCU8F1Kb)EafwIKfnXsAkl6R50O7kVcugoZUsL)9RqIZEh8Im43dOWsKSebSmILrSmIL0uw0xZPbLRaBcmtXwqBuht1NPIAK3ajZYIL0uw0HymlAzzEi3)CtX(vywqel2pglPPSaW7Z1vKbw5fMYFFfk0ZsKSmglJyrlla8(CDfzUkJmaMaeRGpob43xHc92N8jBbTiizWjaPY1veyY4sacs4qFw)bReGJhMWS4kflWFNAwGfllmXY9umMfyXsambOh(dwjaxykFpfJt(KTG2aizWjaPY1veyY4sacs4qFw)bReGAW97uZcsilx9qw(DIf8ZcSzXHelE4pyXI6WFcqp8hSsa2Rk7H)GvwD4pbi(7l8jBbTeGH(EQppbiaVpxxrMdNDiLauD4pxEmLa0HuYNSf7hlzWjaPY1veyY4sa6H)GvcWEvzp8hSYQd)javh(ZLhtjaXFYN8jaTAkaJ19pzWjBbTKbNa0d)bReGOCfytGzS113JtasLRRiWKXL8jBX(KbNaKkxxrGjJlbi0kbiM(eGE4pyLaeG3NRROeGaC1Isaowcqqch6Z6pyLaCW7ela8(CDfXYHzbtplpKLXyX297SuqwWV)SalwwyILVVcf6XAKf0yX2ovS87elZRXplWIy5WSalwwysJSypl3KLFNybtbybYYHzXlqwIil3KfD4VZI3ucqaENlpMsacR8ct5VVcf6t(KTeXKbNaKkxxrGjJlbi0kbOdcMa0d)bReGa8(CDfLaeGRwucq0sag67P(8eGFFfk0BE0m7ooVWuwFnNSOLLVVcf6npAMaeQaH2kd4Q9)GflAzXow((kuO38OzoS5HXugoZXWc)nCHZbyH)Ef(dw4eGa8oxEmLaew5fMYFFfk0N8jBbHtgCcqQCDfbMmUeGqReGoiycqp8hSsacW7Z1vucqaUArjaTpbyOVN6Zta(9vOqV5T3S748ctz91CYIww((kuO382BcqOceARmGR2)dwSOLf7y57RqHEZBV5WMhgtz4mhdl83WfohGf(7v4pyHtacW7C5XucqyLxyk)9vOqFYNSfnLm4eGu56kcmzCjaHwjaDqWeGE4pyLaeG3NRROeGa8oxEmLaew5fMYFFfk0Nam03t95jaPiCDwweO5kCOxVRROCeU86xXzqcWfiwstzHIW1zzrGgk2kAtUkdBWYRaXsAklueUollc0GHlLI()kK5EPhnbiiHd9z9hSsao4DctS89vOqpMfVjwk4ZIVEyS)xWvQOSaspfEcKfhZcSyzHjwWV)S89vOqp2WclaPNfaEFUUIy5HSGWS4yw(DkklUcdzPicKfSffoxXYUxGQRqAsacWvlkbicN8jBbDNm4eGu56kcmzCjaHwjaX0Na0d)bReGa8(CDfLaeGRwucWiogldILHSGglAglJzqttSmiwW0N1H1cB(JA7JGmcBfyzucqqch6Z6pyLaei9yw(DIfGV34vJKyjaXpltyZIYFQzj4QWs5)blmldNWMfcXESLIyX2ovS8qwWV3plGRyRRqYIonHnXcQTPAGrzz6kfMf4CokbiaVZLhtjaX4CaI)Kpzli0KbNaKkxxrGjJlbi0kbiM(eGE4pyLaeG3NRROeGaC1IsaQPXyzqSmKf0yrZyzmdAAILbXcM(SoSwyZFuBFeKryRalJsacW7C5Xucq8mhG4p5t2seKm4eGu56kcmzCjaHwjaX0Na0d)bReGa8(CDfLaeGRwucWiogliGf0gJLbXsVkAcBKKjqkc)NRYyRRVhBOY1veycqqch6Z6pyLaei9yw8NfB7xyNfpgUQNf4KLTIriSGkybaIcXcEhUuGSOtSSWe4aYccpgl2UFhUEwqfPi8FUIfGwxFpMfVazjIJXIT73njab4DU8ykbyawaGOqzhBL8jBzaKm4eGE4pyLamgcluUkpHDCcqQCDfbMmUKpzlOnwYGtasLRRiWKXLa0d)bReG2A)3tag67P(8eGdzHcQZctg1Q8oxeIFwstzHcQZctMRYyOYBwstzHcQZctMRY6WFNL0uwOG6SWKXRO5Iq8ZYOeGQROCambiAJL8jFcqhsjdozlOLm4eGu56kcmzCjaHwjaX0Na0d)bReGa8(CDfLaeGRwucWEv0e2ijZFXKnyxzWM8y9RaP2qLRRiqw0YYqw0xZP5VyYgSRmytES(vGuBAk2VcZcIybza0e7iMfeWYyg0yjnLf91CA(lMSb7kd2KhRFfi1MMI9RWSGiw8WFWYGFVNxtgcXuy9u(VyIfeWYyg0yrlldzHcQZctMRYQv5nlPPSqb1zHjdgQ8oxeIFwstzHcQZctgVIMlcXplJyzelAzrFnNM)IjBWUYGn5X6xbsTzzLaeKWH(S(dwjarLRclL)eMfB70Vtnl)oXIMRjpo4FyNAw0xZjl2oLILPRuSaNtwSD)(vS87elfH4NLGJ)eGa8oxEmLaeSjpoB7uQ80vQmCot(KTyFYGtasLRRiWKXLaeALaetFcqp8hSsacW7Z1vucqaUArjaTJfkOolmzUkJHkVzrllylsPYV3iPhBWV3ZRjw2KfeklAglVRO6ny4sLHZ8Vt5jSj8BOY1veildIf7zbbSqb1zHjZvzD4VZIwwSJLEv0e2ijJvFXWg8Cv27GxxiBTuyVnu56kcKfTSyhl9QOjSrsgyr)oohuK3zah(GLHkxxrGjabjCOpR)Gvcqu5QWs5pHzX2o97uZcW3B8QrsSCywSb7FNLGJ)RqYcea1Sa89EEnXYvSGoRYBw0GG6SWucqaENlpMsaEilytz87nE1iPKpzlrmzWjaPY1veyY4sa6H)GvcWaSaarHY)oLXwxFpobiiHd9z9hSsaoEyIfublaquiwSTtfl(ZIIWyw(DVyrtJXYwXiew8cKf1velllwSD)olOAROF8RqcWqFp1NNa0owa71bAkyoaIzrlldzzila8(CDfzcWcaefkds4OvGfTSyhlbiubcTvMGNVkyAYbJYIwwSJLEv0e2ijJvFXWg8Cv27GxxiBTuyVnu56kcKL0uw0xZPj45RcMLflAzzil2XsVkAcBKKXQVyydEUk7DWRlKTwkS3gQCDfbYsAkl9QOjSrsMaPi8FUkJTU(ESHkxxrGSKMYY8qU)5MI9RWSSjlOzpcLL0uw0HymlAzzEi3)CtX(vywqelbiubcTvMGNVkyAk2VcZccybTXyjnLf91CAcE(QGPPy)kmlBYcA2ZYiwgXIwwgYYqwgYIJ)2vzlOnQzbrrYcaVpxxrMaSaarHYo2IL0uwWwKsLFVrsp2GFVNxtSSjlrKLrSOLLHSOVMtdfuNfMYQv5TPPy)kmlBYcAJXsAkl6R50qb1zHPmgQ820uSFfMLnzbTXyzelPPSOVMttWZxfmnf7xHzztw0elAzrFnNMGNVkyAk2VcZcIIKf0SNLrSOLLHSyhlVRO6n4NukVZG9nFdvUUIazjnLf91CAWV3txPmnf7xHzbrSGMrtSOzSmMrtSmiw6vrtyJKmbsr4)CvgBD99ydvUUIazjnLf91CAcE(QGPPy)kmliIf91CAWV3txPmnf7xHzbbSOjw0YI(AonbpFvWSSyzelAzzil2XsVkAcBKK5VyYgSRmytES(vGuBOY1veilPPSyhl9QOjSrsMaPi8FUkJTU(ESHkxxrGSKMYI(Aon)ft2GDLbBYJ1VcKAttX(vyw2KfcXuy9u(VyILrSKMYsVkAcBKKr3vEfOmCMDLk)7xHeBOY1veilJyrlldzXow6vrtyJKm6UYRaLHZSRu5F)kKydvUUIazjnLLHSOVMtJUR8kqz4m7kv(3Vcjox(VAYGFpGclrYseWsAkl6R50O7kVcugoZUsL)9RqIZEh8Im43dOWsKSebSmILrSKMYIoeJzrllZd5(NBk2VcZcIybTXyrll2XsacvGqBLj45RcMMCWOSmk5t2ccNm4eGu56kcmzCja9WFWkbiEvZRPeGHObfLFVrspozlOLam03t95jahYstZMW7UUIyjnLf91CAOG6SWugdvEBAk2VcZcIyjISOLfkOolmzUkJHkVzrllnf7xHzbrSGgcZIwwExr1BWWLkdN5FNYtyt43qLRRiqwgXIwwEVrsV5Vyk)Wm4rSSjlOHWSOzSGTiLk)EJKEmliGLMI9RWSOLLHSqb1zHjZvzVIYsAklnf7xHzbrSGmaAIDeZYOeGGeo0N1FWkb44HjwaUQ51elxXILxGu8fybwS4v0F)kKS87(ZI6aqywqdHXuaZIxGSOimMfB3VZsmSjwEVrspMfVazXFw(DIfQazbozXzbiu5nlAqqDwyIf)zbneMfmfWSaBwuegZstX(vxHKfhZYdzPGpl7oGRqYYdzPPzt4Dwax9vizbDwL3SObb1zHPKpzlAkzWjaPY1veyY4sa6H)Gvcq8QMxtjabjCOpR)GvcWXdtSaCvZRjwEil7oaIfNfKkOURy5HSSWelJ)aKAUeGH(EQppbiaVpxxrMlcbZbybE)blw0YsacvGqBL5kCOxVRROCeU86xXzqcWfittoyuw0YcfHRZYIanxHd96DDfLJWLx)kodsaUaXIwwCRCyNcOK8jBbDNm4eGu56kcmzCja9WFWkbi(9E6kvcqqch6Z6pyLaCagrwSSSyb4790vkw8NfxPy5VycZYQuegZYcFfswqNObVDmlEbYY9SCywCD46z5HSy1WalWMff9S87elylkCUIfp8hSyrDfXIoPG2yz3lqfXIMRjpw)kqQzbwSyplV3iPhNam03t95jaTJL3vu9g8tkL3zW(MVHkxxrGSOLLHSyhly6Z6WAHn)rT9rqgHTcSKMYcfuNfMmxL9kklPPSGTiLk)EJKESb)EpDLILnzjISmIfTSmKf91CAWV3txPmnnBcV76kIfTSmKfSfPu53BK0Jn437PRuSGiwIilPPSyhl9QOjSrsM)IjBWUYGn5X6xbsTHkxxrGSmIL0uwExr1BWWLkdN5FNYtyt43qLRRiqw0YI(AonuqDwykJHkVnnf7xHzbrSerw0YcfuNfMmxLXqL3SOLf91CAWV3txPmnf7xHzbrSGqzrllylsPYV3iPhBWV3txPyzZizbHzzelAzzil2XsVkAcBKKrfn4TJZtfr)viZivxSfMmu56kcKL0uw(lMybDXccRjw2Kf91CAWV3txPmnf7xHzbbSyplJyrllV3iP38xmLFyg8iw2KfnL8jBbHMm4eGu56kcmzCja9WFWkbi(9E6kvcqqch6Z6pyLae14(Dwa(Ks5nlAU(MpllmXcSyjaYITDQyPPzt4DxxrSOVEwW)PuSyZVNLjSzbDIg82XSy1WalEbYciS2(zzHjw0PjSjwqLMdByb4FkfllmXIonHnXcQGfaikel4Rcel)U)Sy7ukwSAyGfVG)o1Sa89E6kvcWqFp1NNa8DfvVb)Ks5DgSV5BOY1veilAzrFnNg8790vkttZMW7UUIyrlldzXowW0N1H1cB(JA7JGmcBfyjnLfkOolmzUk7vuwstzbBrkv(9gj9yd(9E6kflBYccZYiw0YYqwSJLEv0e2ijJkAWBhNNkI(RqMrQUylmzOY1veilPPS8xmXc6IfewtSSjlimlJyrllV3iP38xmLFyg8iw2KLiM8jBjcsgCcqQCDfbMmUeGE4pyLae)EpDLkbiiHd9z9hSsaIAC)olAUM8y9RaPMLfMyb4790vkwEilOqKflllw(DIf91CYIEuwCfgYYcFfswa(EpDLIfyXIMybtbybIzb2SOimMLMI9RUczcWqFp1NNaSxfnHnsY8xmzd2vgSjpw)kqQnu56kcKfTSGTiLk)EJKESb)EpDLILnJKLiYIwwgYIDSOVMtZFXKnyxzWM8y9RaP2SSyrll6R50GFVNUszAA2eE31velPPSmKfaEFUUImGn5XzBNsLNUsLHZjlAzzil6R50GFVNUszAk2VcZcIyjISKMYc2IuQ87ns6Xg8790vkw2Kf7zrllVRO6n4NukVZG9nFdvUUIazrll6R50GFVNUszAk2VcZcIyrtSmILrSmk5t2YaizWjaPY1veyY4sacTsaIPpbOh(dwjab4956kkbiaxTOeGo(BxLTG2OMLnzjcgJLbXYqwqJfnJfm9zDyTWM)O2(iiBVvGLbXYyg7zzeldILHSGglAgl6R508xmzd2vgSjpw)kqQn43dOWYGyzmdASmIfnJLHSOVMtd(9E6kLPPy)kmldILiYc6zbBrkvE3XpXYGyXowExr1BWpPuENb7B(gQCDfbYYiw0mwgYsacvGqBLb)EpDLY0uSFfMLbXsezb9SGTiLkV74NyzqS8UIQ3GFsP8od238nu56kcKLrSOzSmKf91CAMRoAgoZKAvKPPy)kmldIfnXYiw0YYqw0xZPb)EpDLYSSyjnLLaeQaH2kd(9E6kLPPy)kmlJsacs4qFw)bReGOYvHLYFcZITD63PMfNfGV34vJKyzHjwSDkflbFHjwa(EpDLILhYY0vkwGZPgzXlqwwyIfGV34vJKy5HSGcrwSO5AYJ1VcKAwWVhqHLLLHLiymwoml)oXstr46AcKLTIriS8qwco(zb47nE1ijea89E6kvcqaENlpMsaIFVNUsLTbRppDLkdNZKpzlOnwYGtasLRRiWKXLa0d)bReG43B8QrsjabjCOpR)GvcWXdtSa89gVAKel2UFNfnxtES(vGuZYdzbfISyzzXYVtSOVMtwSD)oC9SOG4RqYcW37PRuSSS(lMyXlqwwyIfGV34vJKybwSGWiGLXb36Gzb)EafmlR6pflimlV3iPhNam03t95jab4956kYa2KhNTDkvE6kvgoNSOLfaEFUUIm437PRuzBW6ZtxPYW5KfTSyhla8(CDfzoKfSPm(9gVAKelPPSmKf91CA0DLxbkdNzxPY)(viX5Y)vtg87buyztwIilPPSOVMtJUR8kqz4m7kv(3Vcjo7DWlYGFpGclBYsezzelAzbBrkv(9gj9yd(9E6kfliIfeMfTSaW7Z1vKb)EpDLkBdwFE6kvgoNjFYwqdTKbNaKkxxrGjJlbOh(dwjaDq36paugBZ74eGHObfLFVrspozlOLam03t95jaTJL)cOCfsw0YIDS4H)GLXbDR)aqzSnVJZGESJKmxLNQd5(ZsAklGW34GU1FaOm2M3Xzqp2rsg87buybrSerw0Yci8noOB9hakJT5DCg0JDKKPPy)kmliILiMaeKWH(S(dwjahpmXc2M3XSGHS87(Zsu4IfK0ZsSJywww)ftSOhLLf(kKSCploMfL)eloMfligF6kIfyXIIWyw(DVyjISGFpGcMfyZcQ5l8ZITDQyjIiGf87buWSqi26Ak5t2cA2Nm4eGu56kcmzCja9WFWkbymewZRPeGHObfLFVrspozlOLam03t95jaBA2eE31velAz59gj9M)IP8dZGhXYMSmKLHSGgcZccyzilylsPYV3iPhBWV3ZRjwgel2ZYGyrFnNgkOolmLvRYBZYILrSmIfeWstX(vywgXc6zzilOXccy5DfvV5TDvogclSHkxxrGSmIfTS44VDv2cAJAw2KfaEFUUIm4zoaXplAgl6R50GFVNUszAk2VcZYGybDZIwwgYIBLd7uafwstzbG3NRRiZHSGnLXV34vJKyjnLf7yHcQZctMRYEfLLrSOLLHSeGqfi0wzcE(QGPjhmklAzHcQZctMRYEfLfTSyhlG96anfmhaXSOLLHSaW7Z1vKjalaquOmiHJwbwstzjaHkqOTYeGfaiku(3Pm2667XMMCWOSKMYIDSeGaOYR3uhY9ppDILrSKMYc2IuQ87ns6Xg8798AIfeXYqwgYseWIMXYqw0xZPHcQZctz1Q82SSyzqSerwgXYiwgeldzbnwqalVRO6nVTRYXqyHnu56kcKLrSmIfTSyhluqDwyYGHkVZfH4NfTSmKf7yjaHkqOTYe88vbttoyuwstzbSxhOPG5aiMLrSKMYYqwOG6SWK5QmgQ8ML0uw0xZPHcQZctz1Q82SSyrll2XY7kQEdgUuz4m)7uEcBc)gQCDfbYYiw0YYqwWwKsLFVrsp2GFVNxtSGiwqBmwgeldzbnwqalVRO6nVTRYXqyHnu56kcKLrSmILrSOLLHSyhlbiaQ86nOeTpVyjnLf7yrFnNguUcSjWmfBbTrDmvFMkQrEdKmllwstzHcQZctMRYyOYBwgXIwwSJf91CAAhavWfopBQgy0m(Q5sL3JIFQp3SSsacs4qFw)bReGOMOzt4Dw08GWAEnXYnzbvBf9JFfy5WS0KdgvJS87utS4nXIIWyw(DVyrtS8EJKEmlxXc6SkVzrdcQZctSy7(DwacFuRgzrryml)UxSG2ySa)DQTDyILRyXROSObb1zHjwGnlllwEilAIL3BK0JzrNMWMyXzbDwL3SObb1zHjdlAoyT9ZstZMW7SaU6RqYYaSRaBcKfni2cAJ6yQEwwLIWywUIfGqL3SObb1zHPKpzlOfXKbNaKkxxrGjJlbOh(dwjaNWoqz4mx(VAkbiiHd9z9hSsaoEyIfulClSalwcGSy7(D46zj4wwxHmbyOVN6Zta6w5WofqHL0uwa4956kYCilytz87nE1iPKpzlOHWjdobivUUIatgxcqOvcqm9ja9WFWkbiaVpxxrjab4QfLa0owa71bAkyoaIzrlldzbG3NRRitamhGf49hSyrlldzrFnNg8790vkZYIL0uwExr1BWpPuENb7B(gQCDfbYsAklbiaQ86n1HC)ZtNyzelAzbe(MyiSMxtM)cOCfsw0YYqwSJf91CAWqf(VazwwSOLf7yrFnNMGNVkywwSOLLHSyhlVRO6nZvhndNzsTkYqLRRiqwstzrFnNMGNVkyaxT)hSyztwcqOceARmZvhndNzsTkY0uSFfMfeWseWYiw0YYqwSJfm9zDyTWM)O2(iiBVvGL0uwOG6SWK5QSAvEZsAkluqDwyYGHkVZfH4NLrSOLfaEFUUIm)EFkvgtekuNT53ZIwwgYIDSeGaOYR3uhY9ppDIL0uwa4956kYeGfaikugKWrRalPPSeGqfi0wzcWcaefk)7ugBD99yttX(vywqelOPjwgXIwwEVrsV5Vyk)Wm4rSSjl6R50e88vbd4Q9)GfldILXmiuwgXsAkl6qmMfTSmpK7FUPy)kmliIf91CAcE(QGbC1(FWIfeWcA2ZYGyPxfnHnsYy1xmSbpxL9o41fYwlf2BdvUUIazzucqaENlpMsagaZbybE)bRSdPKpzlOPPKbNaKkxxrGjJlbOh(dwjaBhavWfopBQgy0eGGeo0N1FWkb44HjwqTnvdmkl2UFNfuTv0p(vibyOVN6ZtaQVMttWZxfmnf7xHzztwqttSKMYI(AonbpFvWaUA)pyXccybn7zzqS0RIMWgjzS6lg2GNRYEh86czRLc7THkxxrGSGiwShDZIwwa4956kYeaZbybE)bRSdPKpzlOHUtgCcqQCDfbMmUeGE4pyLamqkc)NRYU6qwXu9jabjCOpR)GvcWXdtSGQTI(XVcSalwcGSSkfHXS4filQRiwUNLLfl2UFNfublaquOeGH(EQppbiaVpxxrMayoalW7pyLDiXIwwgYIDSeGaOYR3aGQFpAZsAkl2XsVkAcBKKbF1CPY7rXp1NBOY1veilPPS0RIMWgjzS6lg2GNRYEh86czRLc7THkxxrGSKMYI(AonbpFvWaUA)pyXYMrYI9OBwgXsAkl6R500oaQGlCE2unWOMLflAzrFnNM2bqfCHZZMQbg10uSFfMfeXcAAYOPKpzlOHqtgCcqQCDfbMmUeGH(EQppbiaVpxxrMayoalW7pyLDiLa0d)bReGxf8U8)GvYNSf0IGKbNaKkxxrGjJlbOh(dwjaPylOnQZ6WcmbiiHd9z9hSsaoEyIfni2cAJAwghSazbwSeazX297Sa89E6kflllw8cKfSdGyzcBwqilf2Bw8cKfuTv0p(vibyOVN6ZtaoKLaeQaH2ktWZxfmnf7xHzbbSOVMttWZxfmGR2)dwSGaw6vrtyJKmw9fdBWZvzVdEDHS1sH92qLRRiqwgelOzplBYsacvGqBLHITG2OoRdlqd4Q9)GfliGf0gJLrSKMYI(AonbpFvW0uSFfMLnzjcyjnLfWEDGMcMdG4KpzlOnasgCcqQCDfbMmUeGE4pyLae)Ks5DEQ8MsagIguu(9gj94KTGwcWqFp1NNaSPzt4DxxrSOLL)IP8dZGhXYMSGMMyrllylsPYV3iPhBWV3ZRjwqelimlAzXTYHDkGclAzzil6R50e88vbttX(vyw2Kf0gJL0uwSJf91CAcE(QGzzXYOeGGeo0N1FWkbiQjA2eENLPYBIfyXYYILhYsez59gj9ywSD)oC9SGQTI(XVcSOtxHKfxhUEwEileITUMyXlqwk4Zcea1b3Y6kKjFYwSFSKbNaKkxxrGjJlbOh(dwjaNRoAgoZKAvucqqch6Z6pyLaC8WelOwOgWYnz5k8bsS4flAqqDwyIfVazrDfXY9SSSyX297S4SGqwkS3Sy1WalEbYYwbDR)aqSa0M3Xjad99uFEcqkOolmzUk7vuw0YYqwCRCyNcOWsAkl2XsVkAcBKKXQVyydEUk7DWRlKTwkS3gQCDfbYYiw0YYqw0xZPXQVyydEUk7DWRlKTwkS3gaUArSGiwSxtJXsAkl6R50e88vbttX(vyw2KLiGLrSOLLHSacFJd6w)bGYyBEhNb9yhjz(lGYvizjnLf7yjabqLxVPOqdvWgKL0uwWwKsLFVrspMLnzXEwgXIwwgYI(AonTdGk4cNNnvdmQPPy)kmliILbalAgldzbHzzqS0RIMWgjzWxnxQ8Eu8t95gQCDfbYYiw0YI(AonTdGk4cNNnvdmQzzXsAkl2XI(AonTdGk4cNNnvdmQzzXYiw0YYqwSJLaeQaH2ktWZxfmllwstzrFnNMFVpLkJjcfQn43dOWcIybnnXIwwMhY9p3uSFfMfeXI9JnglAzzEi3)CtX(vyw2Kf0gBmwstzXowWWLs)kqZV3NsLXeHc1gQCDfbYYiw0YYqwWWLs)kqZV3NsLXeHc1gQCDfbYsAklbiubcTvMGNVkyAk2VcZYMSeXXyzelAz59gj9M)IP8dZGhXYMSOjwstzrhIXSOLL5HC)Znf7xHzbrSG2yjFYwShTKbNaKkxxrGjJlbOh(dwjaXV3txPsacs4qFw)bReGJhMyXzb4790vkw08l63zXQHbwwLIWywa(EpDLILdZIRAYbJYYYIfyZsu4IfVjwCD46z5HSabqDWTyzRyescWqFp1NNauFnNgyr)ooBrDGS(dwMLflAzzil6R50GFVNUszAA2eE31velPPS44VDv2cAJAw2KLbWySmk5t2I92Nm4eGu56kcmzCja9WFWkbi(9E6kvcqqch6Z6pyLauZTITyzRyecl60e2elOcwaGOqSy7(Dwa(EpDLIfVaz53PIfGV34vJKsag67P(8eGbiaQ86n1HC)ZtNyrll2XY7kQEd(jLY7myFZ3qLRRiqw0YYqwa4956kYeGfaikugKWrRalPPSeGqfi0wzcE(QGzzXsAkl6R50e88vbZYILrSOLLaeQaH2ktawaGOq5FNYyRRVhBAk2VcZcIybza0e7iMLbXsGofldzXXF7QSf0g1SGEwa4956kYGN5ae)SmIfTSOVMtd(9E6kLPPy)kmliIfeMfTSyhlG96anfmhaXjFYwSpIjdobivUUIatgxcWqFp1NNamabqLxVPoK7FE6elAzzila8(CDfzcWcaefkds4OvGL0uwcqOceARmbpFvWSSyjnLf91CAcE(QGzzXYiw0YsacvGqBLjalaquO8VtzS113Jnnf7xHzbrSOjw0YcaVpxxrg8790vQSny95PRuz4CYIwwOG6SWK5QSxrzrll2XcaVpxxrMdzbBkJFVXRgjXIwwSJfWEDGMcMdG4eGE4pyLae)EJxnsk5t2I9iCYGtasLRRiWKXLa0d)bReG43B8QrsjabjCOpR)GvcWXdtSa89gVAKel2UFNfVyrZVOFNfRggyb2SCtwIcxBdYcea1b3ILTIriSy7(DwIcxnlfH4NLGJFdlBvHHSaUITyzRyecl(ZYVtSqfilWjl)oXYauQ(9Onl6R5KLBYcW37PRuSydUuG12pltxPyboNSaBwIcxS4nXcSyXEwEVrspobyOVN6ZtaQVMtdSOFhNdkY7mGdFWYSSyjnLLHSyhl43751KXTYHDkGclAzXowa4956kYCilytz87nE1ijwstzzil6R50e88vbttX(vywqelAIfTSOVMttWZxfmllwstzzildzrFnNMGNVkyAk2VcZcIybza0e7iMLbXsGofldzXXF7QSf0g1SGEwa4956kYGX5ae)SmIfTSOVMttWZxfmllwstzrFnNM2bqfCHZZMQbgnJVAUu59O4N6Znnf7xHzbrSGmaAIDeZYGyjqNILHS44VDv2cAJAwqpla8(CDfzW4CaIFwgXIww0xZPPDaubx48SPAGrZ4RMlvEpk(P(CZYILrSOLLaeavE9gau97rBwgXYiw0YYqwWwKsLFVrsp2GFVNUsXcIyjISKMYcaVpxxrg8790vQSny95PRuz4CYYiwgXIwwSJfaEFUUImhYc2ug)EJxnsIfTSmKf7yPxfnHnsY8xmzd2vgSjpw)kqQnu56kcKL0uwWwKsLFVrsp2GFVNUsXcIyjISmk5t2I9AkzWjaPY1veyY4sa6H)GvcWISLJHWkbiiHd9z9hSsaoEyIfnpiSWSCflaHkVzrdcQZctS4filyhaXcQDPuSO5bHfltyZcQ2k6h)kKam03t95jahYI(AonuqDwykJHkVnnf7xHzztwietH1t5)IjwstzzilHDVrsywIKf7zrllnf29gjL)lMybrSOjwgXsAklHDVrsywIKLiYYiw0YIBLd7uaLKpzl2JUtgCcqQCDfbMmUeGH(EQppb4qw0xZPHcQZctzmu5TPPy)kmlBYcHykSEk)xmXsAkldzjS7nscZsKSyplAzPPWU3iP8FXeliIfnXYiwstzjS7nscZsKSerwgXIwwCRCyNcOWIwwgYI(AonTdGk4cNNnvdmQPPy)kmliIfnXIww0xZPPDaubx48SPAGrnllw0YIDS0RIMWgjzWxnxQ8Eu8t95gQCDfbYsAkl2XI(AonTdGk4cNNnvdmQzzXYOeGE4pyLaC3vZCmewjFYwShHMm4eGu56kcmzCjad99uFEcWHSOVMtdfuNfMYyOYBttX(vyw2KfcXuy9u(VyIfTSmKLaeQaH2ktWZxfmnf7xHzztw00ySKMYsacvGqBLjalaquO8VtzS113Jnnf7xHzztw00ySmIL0uwgYsy3BKeMLizXEw0YstHDVrs5)IjwqelAILrSKMYsy3BKeMLizjISmIfTS4w5WofqHfTSmKf91CAAhavWfopBQgyuttX(vywqelAIfTSOVMtt7aOcUW5zt1aJAwwSOLf7yPxfnHnsYGVAUu59O4N6Znu56kcKL0uwSJf91CAAhavWfopBQgyuZYILrja9WFWkb4CPu5yiSs(KTyFeKm4eGu56kcmzCjabjCOpR)GvcWXdtSGAa1awGflOsZLa0d)bReG28UpyNHZmPwfL8jBX(bqYGtasLRRiWKXLaeALaetFcqp8hSsacW7Z1vucqaUArjaXwKsLFVrsp2GFVNxtSSjlimliGLPccBwgYsSJFQJMb4QfXYGybTXgJf0ZI9JXYiwqaltfe2SmKf91CAWV34vJKYuSf0g1Xu9zmu5Tb)EafwqplimlJsacs4qFw)bReGOYvHLYFcZITD63PMLhYYctSa89EEnXYvSaeQ8MfB7xyNLdZI)SOjwEVrspgbOXYe2SqaOokl2pg6ILyh)uhLfyZccZcW3B8QrsSObXwqBuht1Zc(9ak4eGa8oxEmLae)EpVMYxLXqL3jFYwI4yjdobivUUIatgxcqOvcqm9ja9WFWkbiaVpxxrjab4QfLaenwqplylsPY7o(jwqel2ZIMXYqwgZypldILHSGTiLk)EJKESb)EpVMyrZybnwgXYGyzilOXccy5DfvVbdxQmCM)DkpHnHFdvUUIazzqSGMrtSmILrSGawgZGMMyzqSOVMtt7aOcUW5zt1aJAAk2VcNaeKWH(S(dwjarLRclL)eMfB70VtnlpKfuJ2)Dwax9vizb12unWOjab4DU8ykbOT2)98v5zt1aJM8jBjIOLm4eGu56kcmzCja9WFWkbOT2)9eGGeo0N1FWkb44HjwqnA)3z5kwacvEZIgeuNfMyb2SCtwkilaFVNxtSy7ukwM3ZYvpKfuTv0p(vGfVIgdBkbyOVN6ZtaoKfkOolmzuRY7Cri(zjnLfkOolmz8kAUie)SOLfaEFUUImhohuKdGyzelAzzilV3iP38xmLFyg8iw2KfeML0uwOG6SWKrTkVZxLTNL0uw0HymlAzzEi3)CtX(vywqelOnglJyjnLf91CAOG6SWugdvEBAk2VcZcIyXd)bld(9EEnzietH1t5)Ijw0YI(AonuqDwykJHkVnllwstzHcQZctMRYyOYBw0YIDSaW7Z1vKb)EpVMYxLXqL3SKMYI(AonbpFvW0uSFfMfeXIh(dwg8798AYqiMcRNY)ftSOLf7ybG3NRRiZHZbf5aiw0YI(AonbpFvW0uSFfMfeXcHykSEk)xmXIww0xZPj45RcMLflPPSOVMtt7aOcUW5zt1aJAwwSOLfaEFUUIm2A)3ZxLNnvdmklPPSyhla8(CDfzoCoOihaXIww0xZPj45RcMMI9RWSSjleIPW6P8FXuYNSLiAFYGtasLRRiWKXLaeKWH(S(dwjahpmXcW3751el3KLRybDwL3SObb1zHjnYYvSaeQ8MfniOolmXcSybHralV3iPhZcSz5HSy1WalaHkVzrdcQZctja9WFWkbi(9EEnL8jBjIrmzWjaPY1veyY4sacs4qFw)bReGOwxP(9ELa0d)bReG9QYE4pyLvh(taQo8NlpMsaoDL637vYN8jaNUs979kzWjBbTKbNaKkxxrGjJlbOh(dwjaXV34vJKsacs4qFw)bReGaFVXRgjXYe2SedbqXu9SSkfHXSSWxHKLXb36Gtag67P(8eG2XsVkAcBKKr3vEfOmCMDLk)7xHeBOiCDwweyYNSf7tgCcqQCDfbMmUeGE4pyLaeVQ51ucWq0GIYV3iPhNSf0sag67P(8eGGW3edH18AY0uSFfMLnzPPy)kmldIf7TNf0ZcArqcqqch6Z6pyLaevo(z53jwaHpl2UFNLFNyjgIFw(lMy5HS4GGSSQ)uS87elXoIzbC1(FWILdZY(9gwaUQ51elnf7xHzjEP(ZsDeilpKLy)d7SedH18AIfWv7)bRKpzlrmzWja9WFWkbymewZRPeGu56kcmzCjFYNae)jdozlOLm4eGu56kcmzCja9WFWkbOd6w)bGYyBEhNamenOO87ns6XjBbTeGH(EQppbODSacFJd6w)bGYyBEhNb9yhjz(lGYvizrll2XIh(dwgh0T(daLX28ood6XosYCvEQoK7plAzzil2Xci8noOB9hakJT5DCENCL5VakxHKL0uwaHVXbDR)aqzSnVJZ7KRmnf7xHzztw0elJyjnLfq4BCq36paugBZ74mOh7ijd(9akSGiwIilAzbe(gh0T(daLX28ood6XosY0uSFfMfeXsezrllGW34GU1FaOm2M3Xzqp2rsM)cOCfYeGGeo0N1FWkb44Hjw2kOB9haIfG28oMfB7uXYVtnXYHzPGS4H)aqSGT5DSgzXXSO8NyXXSybX4txrSalwW28oMfB3VZI9SaBwMKnQzb)EafmlWMfyXIZseralyBEhZcgYYV7pl)oXsr2ybBZ7yw8UpaeMfuZx4NfF(uZYV7plyBEhZcHyRRjCYNSf7tgCcqQCDfbMmUeGE4pyLamalaquO8VtzS113Jtacs4qFw)bReGJhMWSGkybaIcXYnzbvBf9JFfy5WSSSyb2SefUyXBIfqchTcxHKfuTv0p(vGfB3VZcQGfaikelEbYsu4IfVjw0jf0gli8yOpIJnevKIW)5kwaAD994rSSvmcHLRyXzbTXqalykWIgeuNfMmSSvfgYciS2(zrrplAUM8y9RaPMfcXwxtAKfxzZJIzzHjwUIfuTv0p(vGfB3VZcczPWEZIxGS4pl)oXc(9(zbozXzzCWToywSDfi0MjbyOVN6ZtaAhlG96anfmhaXSOLLHSmKfaEFUUImbybaIcLbjC0kWIwwSJLaeQaH2ktWZxfmn5Grzrll2XsVkAcBKKXQVyydEUk7DWRlKTwkS3gQCDfbYsAkl6R50e88vbZYIfTSmKf7yPxfnHnsYy1xmSbpxL9o41fYwlf2BdvUUIazjnLLEv0e2ijtGue(pxLXwxFp2qLRRiqwstzzEi3)CtX(vyw2Kf0ShHYsAkl6qmMfTSmpK7FUPy)kmliILaeQaH2ktWZxfmnf7xHzbbSG2ySKMYI(AonbpFvW0uSFfMLnzbn7zzelJyrlldzzilo(BxLTG2OMfefjla8(CDfzcWcaefk7ylw0YYqw0xZPHcQZctz1Q820uSFfMLnzbTXyjnLf91CAOG6SWugdvEBAk2VcZYMSG2ySmIL0uw0xZPj45RcMMI9RWSSjlAIfTSOVMttWZxfmnf7xHzbrrYcA2ZYiw0YYqwSJLEv0e2ijZFXKnyxzWM8y9RaP2qLRRiqwstzXow6vrtyJKmbsr4)CvgBD99ydvUUIazjnLf91CA(lMSb7kd2KhRFfi1MMI9RWSSjleIPW6P8FXelJyjnLLEv0e2ijJUR8kqz4m7kv(3Vcj2qLRRiqwgXIwwgYIDS0RIMWgjz0DLxbkdNzxPY)(viXgQCDfbYsAkldzrFnNgDx5vGYWz2vQ8VFfsCU8F1Kb)EafwIKLiGL0uw0xZPr3vEfOmCMDLk)7xHeN9o4fzWVhqHLizjcyzelJyjnLfDigZIwwMhY9p3uSFfMfeXcAJXIwwSJLaeQaH2ktWZxfmn5GrzzuYNSLiMm4eGu56kcmzCja9WFWkbi(9gVAKucqqch6Z6pyLaC8WelaFVXRgjXYdzbfISyzzXYVtSO5AYJ1VcKAw0xZjl3KL7zXgCPazHqS11el60e2elZRo8(viz53jwkcXplbh)SaBwEilGRylw0PjSjwqfSaarHsag67P(8eG9QOjSrsM)IjBWUYGn5X6xbsTHkxxrGSOLLHSyhldzzil6R508xmzd2vgSjpw)kqQnnf7xHzztw8WFWYyR9F3qiMcRNY)ftSGawgZGglAzziluqDwyYCvwh(7SKMYcfuNfMmxLXqL3SKMYcfuNfMmQv5DUie)SmIL0uw0xZP5VyYgSRmytES(vGuBAk2VcZYMS4H)GLb)EpVMmeIPW6P8FXeliGLXmOXIwwgYcfuNfMmxLvRYBwstzHcQZctgmu5DUie)SKMYcfuNfMmEfnxeIFwgXYiwstzXow0xZP5VyYgSRmytES(vGuBwwSmIL0uwgYI(AonbpFvWSSyjnLfaEFUUImbybaIcLbjC0kWYiw0YsacvGqBLjalaquO8VtzS113Jnn5GrzrllbiaQ86n1HC)ZtNyrlldzrFnNgkOolmLvRYBttX(vyw2Kf0gJL0uw0xZPHcQZctzmu5TPPy)kmlBYcAJXYiwgXIwwgYIDSeGaOYR3Gs0(8IL0uwcqOceARmuSf0g1zDybAAk2VcZYMSebSmk5t2ccNm4eGu56kcmzCja9WFWkbi(9gVAKucqqch6Z6pyLauZTITyb47nE1ijml2UFNLX5kVcelWjlBvPyzW7xHeZcSz5HSy1KL3eltyZcQGfaikel2UFNLXb36Gtag67P(8eG9QOjSrsgDx5vGYWz2vQ8VFfsSHkxxrGSOLLHSmKf91CA0DLxbkdNzxPY)(viX5Y)vtg87buyztwSNL0uw0xZPr3vEfOmCMDLk)7xHeN9o4fzWVhqHLnzXEwgXIwwcqOceARmbpFvW0uSFfMLnzbHYIwwSJLaeQaH2ktawaGOq5FNYyRRVhBwwSKMYYqwcqau51BQd5(NNoXIwwcqOceARmbybaIcL)DkJTU(ESPPy)kmliIf0gJfTSqb1zHjZvzVIYIwwC83UkBbTrnlBYI9JXccyjIJXYGyjaHkqOTYe88vbttoyuwgXYOKpzlAkzWjaPY1veyY4sacTsaIPpbOh(dwjab4956kkbiaxTOeGdzrFnNM2bqfCHZZMQbg10uSFfMLnzrtSKMYIDSOVMtt7aOcUW5zt1aJAwwSmIfTSyhl6R500oaQGlCE2unWOz8vZLkVhf)uFUzzXIwwgYI(AonOCfytGzk2cAJ6yQ(mvuJ8gizAk2VcZcIybza0e7iMLrSOLLHSOVMtdfuNfMYyOYBttX(vyw2KfKbqtSJywstzrFnNgkOolmLvRYBttX(vyw2KfKbqtSJywstzzil2XI(AonuqDwykRwL3MLflPPSyhl6R50qb1zHPmgQ82SSyzelAzXowExr1BWqf(VazOY1veilJsacs4qFw)bReGOcwG3FWILjSzXvkwaHpMLF3FwIDuiml4vtS87uuw8MQTFwAA2eENazX2ovSGAYbqfCHzb12unWOSS7ywuegZYV7flAIfmfWS0uSF1vizb2S87elAqSf0g1SmoybYI(Aoz5WS46W1ZYdzz6kflW5KfyZIxrzrdcQZctSCywCD46z5HSqi26AkbiaVZLhtjabHFUPiCDnft1Jt(KTGUtgCcqQCDfbMmUeGqReGy6ta6H)GvcqaEFUUIsacWvlkb4qwSJf91CAOG6SWugdvEBwwSOLf7yrFnNgkOolmLvRYBZYILrSOLf7y5DfvVbdv4)cKHkxxrGSOLf7yPxfnHnsY8xmzd2vgSjpw)kqQnu56kcmbiiHd9z9hSsaIkybE)blw(D)zjStbuWSCtwIcxS4nXcC94dKyHcQZctS8qwGLkklGWNLFNAIfyZYHSGnXYVFywSD)olaHk8FbkbiaVZLhtjabHFgUE8bszkOolmL8jBbHMm4eGu56kcmzCja9WFWkbymewZRPeGHObfLFVrspozlOLam03t95jahYI(AonuqDwykJHkVnnf7xHzztwAk2VcZsAkl6R50qb1zHPSAvEBAk2VcZYMS0uSFfML0uwa4956kYac)mC94dKYuqDwyILrSOLLMMnH3DDfXIwwEVrsV5Vyk)Wm4rSSjlOzplAzXTYHDkGclAzbG3NRRidi8ZnfHRRPyQECcqqch6Z6pyLauZbFwCLIL3BK0JzX297xXccXlqk(cSy7(D46zbcG6GBzDfse87elUoeaXsawG3FWcN8jBjcsgCcqQCDfbMmUeGE4pyLaeVQ51ucWqFp1NNaCil6R50qb1zHPmgQ820uSFfMLnzPPy)kmlPPSOVMtdfuNfMYQv5TPPy)kmlBYstX(vywstzbG3NRRidi8ZW1Jpqktb1zHjwgXIwwAA2eE31velAz59gj9M)IP8dZGhXYMSGM9SOLf3kh2PakSOLfaEFUUImGWp3ueUUMIP6Xjadrdkk)EJKECYwql5t2YaizWjaPY1veyY4sa6H)Gvcq8tkL35PYBkbyOVN6ZtaoKf91CAOG6SWugdvEBAk2VcZYMS0uSFfML0uw0xZPHcQZctz1Q820uSFfMLnzPPy)kmlPPSaW7Z1vKbe(z46XhiLPG6SWelJyrllnnBcV76kIfTS8EJKEZFXu(HzWJyztwqdDZIwwCRCyNcOWIwwa4956kYac)Ctr46AkMQhNamenOO87ns6XjBbTKpzlOnwYGtasLRRiWKXLaeALaetFcqp8hSsacW7Z1vucqaUArjadqau51Baq1VhTzrll2XsVkAcBKKbF1CPY7rXp1NBOY1veilAzXow6vrtyJKmHRdkkdNz1nPSxGzqY)DdvUUIazrllbiubcTvgDQXuJYvinn5GrzrllbiubcTvM2bqfCHZZMQbg10KdgLfTSyhl6R50e88vbZYIfTSmKfh)TRYwqBuZYMSebiuwstzrFnNgDfecQw43SSyzucqqch6Z6pyLauZbFw6d5(ZIonHnXcQTPAGrz5MSCpl2GlfilUsbTXsu4ILhYstZMW7SOimMfWvFfswqTnvdmkld)9dZcSurzz3TSOcZIT73HRNfGxnxkwqnlk(P(8rjab4DU8ykbybZ7rXp1NNjVvrZGWp5t2cAOLm4eGu56kcmzCjad99uFEcqaEFUUImfmVhf)uFEM8wfndcFw0YstX(vywqel2pwcqp8hSsagdH18Ak5t2cA2Nm4eGu56kcmzCjad99uFEcqaEFUUImfmVhf)uFEM8wfndcFw0YstX(vywqelOnasa6H)Gvcq8QMxtjFYwqlIjdobivUUIatgxcqp8hSsaoHDGYWzU8F1ucqqch6Z6pyLaC8WelOw4wybwSeazX297W1ZsWTSUczcWqFp1NNa0TYHDkGsYNSf0q4KbNaKkxxrGjJlbOh(dwjaPylOnQZ6WcmbiiHd9z9hSsaoEyIfni2cAJAwghSazX297S4vuwuWcjlubxi3zr54)kKSObb1zHjw8cKLVJYYdzrDfXY9SSSyX297SGqwkS3S4filOAROF8RqcWqFp1NNaCilbiubcTvMGNVkyAk2VcZccyrFnNMGNVkyaxT)hSybbS0RIMWgjzS6lg2GNRYEh86czRLc7THkxxrGSmiwqZEw2KLaeQaH2kdfBbTrDwhwGgWv7)blwqalOnglJyjnLf91CAcE(QGPPy)kmlBYseWsAklG96anfmhaXjFYwqttjdobivUUIatgxcqOvcqm9ja9WFWkbiaVpxxrjab4QfLa0XF7QSf0g1SSjldGXyrZyzil2B0eldIf91CAMRoAgoZKAvKb)Eafw0mwSNLbXcfuNfMmxLvRYBwgLaeKWH(S(dwjabspMfB7uXYwXiewW7WLcKfDIfWvSfbYYdzPGplqauhClwgQ5ilQaXSalwqTRoklWjlAGAvelEbYYVtSObb1zHPrjab4DU8ykbOJTYGRyRKpzlOHUtgCcqQCDfbMmUeGqReGy6ta6H)GvcqaEFUUIsacWvlkbODSa2Rd0uWCaeZIwwgYcaVpxxrMayoalW7pyXIwwSJf91CAcE(QGzzXIwwgYIDSGPpRdRf28h12hbz7TcSKMYcfuNfMmxLvRYBwstzHcQZctgmu5DUie)SmIfTSmKLHSmKfaEFUUImo2kdUITyjnLLaeavE9M6qU)5PtSKMYYqwcqau51BqjAFEXIwwcqOceARmuSf0g1zDybAAYbJYYiwstzPxfnHnsY8xmzd2vgSjpw)kqQnu56kcKLrSOLfq4BWRAEnzAk2VcZYMSebSOLfq4BIHWAEnzAk2VcZYMSmayrlldzbe(g8tkL35PYBY0uSFfMLnzbTXyjnLf7y5DfvVb)Ks5DEQ8Mmu56kcKLrSOLfaEFUUIm)EFkvgtekuNT53ZIwwEVrsV5Vyk)Wm4rSSjl6R50e88vbd4Q9)GfldILXmiuwstzrFnNgDfecQw43SSyrll6R50ORGqq1c)MMI9RWSGiw0xZPj45RcgWv7)blwqaldzbn7zzqS0RIMWgjzS6lg2GNRYEh86czRLc7THkxxrGSmILrSKMYYqwOiCDwweOHITI2KRYWgS8kqSOLLaeQaH2kdfBfTjxLHny5vGmnf7xHzbrSGg6gHYccyzilAILbXsVkAcBKKbF1CPY7rXp1NBOY1veilJyzelJyrlldzzil2XsacGkVEtDi3)80jwstzzila8(CDfzcWcaefkds4OvGL0uwcqOceARmbybaIcL)DkJTU(ESPPy)kmliIf00elJyrlldzXow6vrtyJKm6UYRaLHZSRu5F)kKydvUUIazjnLfh)TRYwqBuZcIyrtJXIwwcqOceARmbybaIcL)DkJTU(ESPjhmklJyzelPPSmpK7FUPy)kmliILaeQaH2ktawaGOq5FNYyRRVhBAk2VcZYiwstzrhIXSOLL5HC)Znf7xHzbrSOVMttWZxfmGR2)dwSGawqZEwgel9QOjSrsgR(IHn45QS3bVUq2APWEBOY1veilJsacs4qFw)bReGJhMybvBf9JFfyX297SGkybaIcH(byxb2eilaTU(EmlEbYciS2(zbcGAB99eliKLc7nlWMfB7uXY4uqiOAHFwSbxkqwieBDnXIonHnXcQ2k6h)kWcHyRRjSHfnphfIf8QjwEilu9uZIZc6SkVzrdcQZctSyBNkww4dzXYGTpcyXERalEbYIRuSGknhMfBNsXIofGXeln5GrzbdHflubxi3zbC1xHKLFNyrFnNS4filGWhZYUdGyrNOIf8AoVWr1RIYstZMW7eOjbiaVZLhtjadG5aSaV)Gvg)jFYwqdHMm4eGu56kcmzCja9WFWkby7aOcUW5zt1aJMaeKWH(S(dwjahpmXcQTPAGrzX297SGQTI(XVcSSkfHXSGABQgyuwSbxkqwuo(zrblKuZYV7flOAROF8RGgz53PILfMyrNMWMsag67P(8eG6R50e88vbttX(vyw2Kf00elPPSOVMttWZxfmGR2)dwSGiwShHYccyPxfnHnsYy1xmSbpxL9o41fYwlf2BdvUUIazzqSGM9SOLfaEFUUImbWCawG3FWkJ)KpzlOfbjdobivUUIatgxcWqFp1NNaeG3NRRitamhGf49hSY4NfTSmKf91CAcE(QGbC1(FWILnJKf7rOSGaw6vrtyJKmw9fdBWZvzVdEDHS1sH92qLRRiqwgelOzplPPSyhlbiaQ86naO63J2SmIL0uw0xZPPDaubx48SPAGrnllw0YI(AonTdGk4cNNnvdmQPPy)kmliILbaliGLaSax3BSAkCyk7Qdzft1B(lMYaC1IybbSmKf7yrFnNgDfecQw43SSyrll2XY7kQEd(9wbBqdvUUIazzucqp8hSsagifH)ZvzxDiRyQ(KpzlOnasgCcqQCDfbMmUeGH(EQppbiaVpxxrMayoalW7pyLXFcqp8hSsaEvW7Y)dwjFYwSFSKbNaKkxxrGjJlbi0kbiM(eGE4pyLaeG3NRROeGaC1IsagGqfi0wzcE(QGPPy)kmlBYcAJXsAkl2XcaVpxxrMaSaarHYGeoAfyrllbiaQ86n1HC)ZtNyjnLfWEDGMcMdG4eGGeo0N1FWkb4auVpxxrSSWeilWIfx)u3FeMLF3FwS51ZYdzrNyb7aiqwMWMfuTv0p(vGfmKLF3Fw(DkklEt1ZInh)eilOMVWpl60e2el)ofNaeG35YJPeGyhaLNWoh88vHKpzl2JwYGtasLRRiWKXLa0d)bReGZvhndNzsTkkbiiHd9z9hSsaoEycZcQfQbSCtwUIfVyrdcQZctS4filFFeMLhYI6kIL7zzzXIT73zbHSuyV1ilOAROF8RGgzrdITG2OMLXblqw8cKLTc6w)bGybOnVJtag67P(8eGuqDwyYCv2ROSOLLHS44VDv2cAJAwqelda7zrZyrFnNM5QJMHZmPwfzWVhqHLbXIMyjnLf91CAAhavWfopBQgyuZYILrSOLLHSOVMtJvFXWg8Cv27GxxiBTuyVnaC1IybrSypcpglPPSOVMttWZxfmnf7xHzztwIawgXIwwa4956kYGDauEc7CWZxfyrlldzXowcqau51Bkk0qfSbzjnLfq4BCq36paugBZ74mOh7ijZFbuUcjlJyrlldzXowcqau51Baq1VhTzjnLf91CAAhavWfopBQgyuttX(vywqeldaw0mwgYccZYGyPxfnHnsYGVAUu59O4N6Znu56kcKLrSOLf91CAAhavWfopBQgyuZYIL0uwSJf91CAAhavWfopBQgyuZYILrSOLLHSyhlbiaQ86nOeTpVyjnLLaeQaH2kdfBbTrDwhwGMMI9RWSSjl2pglJyrllV3iP38xmLFyg8iw2KfnXsAkl6qmMfTSmpK7FUPy)kmliIf0gl5t2I92Nm4eGu56kcmzCja9WFWkbi(9E6kvcqqch6Z6pyLaC8WelA(f97Sa89E6kflwnmGz5MSa89E6kflhU2(zzzLam03t95ja1xZPbw0VJZwuhiR)GLzzXIww0xZPb)EpDLY00Sj8URROKpzl2hXKbNaKkxxrGjJlbOh(dwjadEfivwFnNjad99uFEcq91CAWV3kydAAk2VcZcIyrtSOLLHSOVMtdfuNfMYyOYBttX(vyw2KfnXsAkl6R50qb1zHPSAvEBAk2VcZYMSOjwgXIwwC83UkBbTrnlBYYaySeG6R5mxEmLae)ERGnycqqch6Z6pyLaevEfiflaFVvWgKLBYY9SS7ywuegZYV7flAcZstX(vxHuJSefUyXBIf)zzamgcyzRyeclEbYYVtSewDt1ZIgeuNfMyz3XSOjeGzPPy)QRqM8jBXEeozWjaPY1veyY4sa6H)GvcWGxbsL1xZzcWqFp1NNa8DfvV5QG3L)hSmu56kcKfTSyhlVRO6nfzlhdHLHkxxrGSOLLb4yzildzjIJnglAglo(BxLTG2OMfeWccpglAgly6Z6WAHn)rT9rq2ERaldIfeEmwgXc6zzilimlONfSfPu5Dh)elJyrZyjaHkqOTYeGfaiku(3Pm2667XMMI9RWSmIfeXYaCSmKLHSeXXgJfnJfh)TRYwqBuZIMXI(Aonw9fdBWZvzVdEDHS1sH92aWvlIfeWccpglAgly6Z6WAHn)rT9rq2ERaldIfeEmwgXc6zzilimlONfSfPu5Dh)elJyrZyjaHkqOTYeGfaiku(3Pm2667XMMI9RWSmIfTSeGqfi0wzcE(QGPPy)kmlBYsehJfTSOVMtJvFXWg8Cv27GxxiBTuyVnaC1IybrSypAJXIww0xZPXQVyydEUk7DWRlKTwkS3gaUArSSjlrCmw0YsacvGqBLjalaquO8VtzS113Jnnf7xHzbrSGWJXIwwMhY9p3uSFfMLnzjaHkqOTYeGfaiku(3Pm2667XMMI9RWSGawq3SOLLHS0RIMWgjzcKIW)5Qm2667XgQCDfbYsAkla8(CDfzcWcaefkds4OvGLrja1xZzU8ykbOvFXWg8Cv27GxxiBTuyVtacs4qFw)bReGOYRaPy53jwqilf2Bw0xZjl3KLFNyXQHbwSbxkWA7Nf1velllwSD)ol)oXsri(z5VyIfublaquiwcWycZcCozjaAyzW7hMLfE5kvuwGLkkl7ULfvywax9viz53jwgh6ys(KTyVMsgCcqQCDfbMmUeGqReGy6ta6H)GvcqaEFUUIsacWvlkbyacGkVEtDi3)80jw0YsVkAcBKKXQVyydEUk7DWRlKTwkS3gQCDfbYIww0xZPXQVyydEUk7DWRlKTwkS3gaUArSGawC83UkBbTrnliGLiYYMrYsehBmw0YcaVpxxrMaSaarHYGeoAfyrllbiubcTvMaSaarHY)oLXwxFp20uSFfMfeXIJ)2vzlOnQzb9SeXXyzqSGmaAIDeZIwwSJfWEDGMcMdGyw0YcfuNfMmxL9kklAzXXF7QSf0g1SSjla8(CDfzcWcaefk7ylw0YsacvGqBLj45RcMMI9RWSSjlAkbiiHd9z9hSsacKEml22PIfeYsH9Mf8oCPazrNyXQHHabYc5TkklpKfDIfxxrS8qwwyIfublaquiwGflbiubcTvSmudWyQ(ZvQOSOtbymHz57fXYnzbCfBDfsw2kgHWsbTXITtPyXvkOnwIcxS8qwSOEsHxfLfQEQzbHSuyVzXlqw(DQyzHjwqfSaarHgLaeG35YJPeGwnmKTwkS3zYBv0Kpzl2JUtgCcqQCDfbMmUeGE4pyLae)EpDLkbiiHd9z9hSsaoEyIfGV3txPyX297Sa8jLYBw0C9nFwGnlV9raliSvGfVazPGSa89wbBqnYITDQyPGSa89E6kflhMLLflWMLhYIvddSGqwkS3SyBNkwCDiaILbWySSvmcziSz53jwiVvrzbHSuyVzXQHbwa4956kILdZY3lAelWMfh0Y)daXc2M3XSS7ywIaeGPaMLMI9RUcjlWMLdZYvSmvhY9pbyOVN6ZtaoKL3vu9g8tkL3zW(MVHkxxrGSKMYcM(SoSwyZFuBFeKryRalJyrll2XY7kQEd(9wbBqdvUUIazrll6R50GFVNUszAA2eE31velAzXow6vrtyJKm)ft2GDLbBYJ1VcKAdvUUIazrlldzrFnNgR(IHn45QS3bVUq2APWEBa4QfXYMrYI9AAmw0YIDSOVMttWZxfmllw0YYqwa4956kY4yRm4k2IL0uw0xZPbLRaBcmtXwqBuht1NPIAK3ajZYIL0uwa4956kYy1Wq2APWENjVvrzzelPPSmKLaeavE9MIcnubBqw0YY7kQEd(jLY7myFZ3qLRRiqw0YYqwaHVXbDR)aqzSnVJZGESJKmnf7xHzztwIawstzXd)blJd6w)bGYyBEhNb9yhjzUkpvhY9NLrSmILrSOLLHSeGqfi0wzcE(QGPPy)kmlBYcAJXsAklbiubcTvMaSaarHY)oLXwxFp20uSFfMLnzbTXyzuYNSf7rOjdobivUUIatgxcqp8hSsaIFVXRgjLaeKWH(S(dwja1CRylmlBfJqyrNMWMybvWcaefILf(kKS87elOcwaGOqSeGf49hSy5HSe2PakSCtwqfSaarHy5WS4HF5kvuwCD46z5HSOtSeC8Nam03t95jab4956kYy1Wq2APWENjVvrt(KTyFeKm4eGu56kcmzCja9WFWkbyr2YXqyLaeKWH(S(dwjahpmXIMhewywSTtflrHlw8MyX1HRNLhIEVjwcUL1vizjS7nscZIxGSe7OqSGxnXYVtrzXBILRyXlw0GG6SWel4)ukwMWMfuZ08qpQvZlbyOVN6Zta6w5WofqHfTSmKLWU3ijmlrYI9SOLLMc7EJKY)ftSGiw0elPPSe29gjHzjswIilJs(KTy)aizWjaPY1veyY4sag67P(8eGUvoStbuyrlldzjS7nscZsKSyplAzPPWU3iP8FXeliIfnXsAklHDVrsywIKLiYYiw0YYqw0xZPHcQZctz1Q820uSFfMLnzHqmfwpL)lMyjnLf91CAOG6SWugdvEBAk2VcZYMSqiMcRNY)ftSmkbOh(dwja3D1mhdHvYNSLiowYGtasLRRiWKXLam03t95jaDRCyNcOWIwwgYsy3BKeMLizXEw0YstHDVrs5)IjwqelAIL0uwc7EJKWSejlrKLrSOLLHSOVMtdfuNfMYQv5TPPy)kmlBYcHykSEk)xmXsAkl6R50qb1zHPmgQ820uSFfMLnzHqmfwpL)lMyzucqp8hSsaoxkvogcRKpzlreTKbNaKkxxrGjJlbOh(dwjaXV34vJKsacs4qFw)bReGJhMyb47nE1ijw08l63zXQHbmlEbYc4k2ILTIriSyBNkwq1wr)4xbnYIgeBbTrnlJdwGAKLFNyzakv)E0Mf91CYYHzX1HRNLhYY0vkwGZjlWMLOW12GSeClw2kgHKam03t95jaPG6SWK5QSxrzrlldzrFnNgyr)oohuK3zah(GLzzXsAkl6R50GYvGnbMPylOnQJP6ZurnYBGKzzXsAkl6R50e88vbZYIfTSmKf7yjabqLxVbLO95flPPSeGqfi0wzOylOnQZ6Wc00uSFfMLnzrtSKMYI(AonbpFvW0uSFfMfeXcYaOj2rmldILPccBwgYIJ)2vzlOnQzb9SaW7Z1vKbJZbi(zzelJyrlldzXowcqau51Baq1VhTzjnLf91CAAhavWfopBQgyuttX(vywqelidGMyhXSmiwc0PyzildzXXF7QSf0g1SGawq4XyzqS8UIQ3mxD0mCMj1QidvUUIazzelONfaEFUUImyCoaXplJybbSerwgelVRO6nfzlhdHLHkxxrGSOLf7yPxfnHnsYGVAUu59O4N6Znu56kcKfTSOVMtt7aOcUW5zt1aJAwwSKMYI(AonTdGk4cNNnvdmAgF1CPY7rXp1NBwwSKMYYqw0xZPPDaubx48SPAGrnnf7xHzbrS4H)GLb)EpVMmeIPW6P8FXelAzbBrkvE3XpXcIyzmdcZsAkl6R500oaQGlCE2unWOMMI9RWSGiw8WFWYyR9F3qiMcRNY)ftSKMYcaVpxxrMlcbZbybE)blw0YsacvGqBL5kCOxVRROCeU86xXzqcWfittoyuw0YcfHRZYIanxHd96DDfLJWLx)kodsaUaXYiw0YI(AonTdGk4cNNnvdmQzzXsAkl2XI(AonTdGk4cNNnvdmQzzXIwwSJLaeQaH2kt7aOcUW5zt1aJAAYbJYYiwstzbG3NRRiJJTYGRylwstzrhIXSOLL5HC)Znf7xHzbrSGmaAIDeZYGyjqNILHS44VDv2cAJAwqpla8(CDfzW4CaIFwgXYOKpzlr0(KbNaKkxxrGjJlbOh(dwjaXV34vJKsacs4qFw)bReGdUJYYdzj2rHy53jw0j8ZcCYcW3BfSbzrpkl43dOCfswUNLLflr46cOOIYYvS4vuw0GG6SWel6RNfeYsH9MLdxB)S46W1ZYdzrNyXQHHabMam03t95jaFxr1BWV3kydAOY1veilAzXow6vrtyJKm)ft2GDLbBYJ1VcKAdvUUIazrlldzrFnNg87Tc2GMLflPPS44VDv2cAJAw2KLbWySmIfTSOVMtd(9wbBqd(9akSGiwIilAzzil6R50qb1zHPmgQ82SSyjnLf91CAOG6SWuwTkVnllwgXIww0xZPXQVyydEUk7DWRlKTwkS3gaUArSGiwShHoglAzzilbiubcTvMGNVkyAk2VcZYMSG2ySKMYIDSaW7Z1vKjalaquOmiHJwbw0YsacGkVEtDi3)80jwgL8jBjIrmzWjaPY1veyY4sacTsaIPpbOh(dwjab4956kkbiaxTOeGuqDwyYCvwTkVzzqSebSGEw8WFWYGFVNxtgcXuy9u(VyIfeWIDSqb1zHjZvz1Q8MLbXYqwq3SGawExr1BWWLkdN5FNYtyt43qLRRiqwgelrKLrSGEw8WFWYyR9F3qiMcRNY)ftSGawgZGWAIf0Zc2IuQ8UJFIfeWYygnXYGy5DfvVP8F1eoR7kVcKHkxxrGjabjCOpR)Gvcqna)xS)eMLDOnwIxHDw2kgHWI3eli9RiqwSOMfmfGfOHfn)sfLL3rHWS4SGl3cVdFwMWMLFNyjS6MQNf89l)pyXcgYIn4sbwB)SOtS4HWQ9NyzcBwuEJKAw(lMMTht4eGa8oxEmLa0XwieQbsHKpzlreHtgCcqQCDfbMmUeGE4pyLae)EJxnskbiiHd9z9hSsaQ5wXwSa89gVAKelxXIxSObb1zHjwCmlyiSyXXSybX4txrS4ywuWcjloMLOWfl2oLIfQazzzXIT73zjcgdbSyBNkwO6P(kKS87elfH4NfniOolmPrwaH12plk6z5EwSAyGfeYsH9wJSacRTFwGaO2wFpXIxSO5x0VZIvddS4filwqOIfDAcBIfuTv0p(vGfVazrdITG2OMLXblWeGH(EQppbODS0RIMWgjz(lMSb7kd2KhRFfi1gQCDfbYIwwgYI(Aonw9fdBWZvzVdEDHS1sH92aWvlIfeXI9i0XyjnLf91CAS6lg2GNRYEh86czRLc7TbGRweliIf710ySOLL3vu9g8tkL3zW(MVHkxxrGSmIfTSmKfkOolmzUkJHkVzrllo(BxLTG2OMfeWcaVpxxrghBHqOgifyzqSOVMtdfuNfMYyOYBttX(vywqalGW3mxD0mCMj1QiZFbuW5MI9RyzqSyVrtSSjlrWySKMYcfuNfMmxLvRYBw0YIJ)2vzlOnQzbbSaW7Z1vKXXwieQbsbwgel6R50qb1zHPSAvEBAk2VcZccybe(M5QJMHZmPwfz(lGco3uSFfldIf7nAILnzzamglJyrll2XI(AonWI(DC2I6az9hSmllw0YIDS8UIQ3GFVvWg0qLRRiqw0YYqwcqOceARmbpFvW0uSFfMLnzbHYsAkly4sPFfO537tPYyIqHAdvUUIazrll6R50879PuzmrOqTb)EafwqelrmISOzSmKLEv0e2ijd(Q5sL3JIFQp3qLRRiqwgel2ZYiw0YY8qU)5MI9RWSSjlOn2ySOLL5HC)Znf7xHzbrSy)yJXsAklG96anfmhaXSmIfTSmKf7yjabqLxVbLO95flPPSeGqfi0wzOylOnQZ6Wc00uSFfMLnzXEwgL8jBjIAkzWjaPY1veyY4sa6H)GvcWISLJHWkbiiHd9z9hSsaoEyIfnpiSWSCflEfLfniOolmXIxGSGDaelOM5QjcqTlLIfnpiSyzcBwq1wr)4xbw8cKLbyxb2eilAqSf0g1Xu9gw2QcdzzHjw2IMhlEbYcQvZJf)z53jwOcKf4KfuBt1aJYIxGSacRTFwu0ZIMRjpw)kqQzz6kflW5mbyOVN6Zta6w5WofqHfTSaW7Z1vKb7aO8e25GNVkWIwwgYI(AonuqDwykRwL3MMI9RWSSjleIPW6P8FXelPPSOVMtdfuNfMYyOYBttX(vyw2KfcXuy9u(VyILrjFYwIi6ozWjaPY1veyY4sag67P(8eGUvoStbuyrlla8(CDfzWoakpHDo45RcSOLLHSOVMtdfuNfMYQv5TPPy)kmlBYcHykSEk)xmXsAkl6R50qb1zHPmgQ820uSFfMLnzHqmfwpL)lMyzelAzzil6R50e88vbZYIL0uw0xZPXQVyydEUk7DWRlKTwkS3gaUArSGOizXE0gJLrSOLLHSyhlbiaQ86naO63J2SKMYI(AonTdGk4cNNnvdmQPPy)kmliILHSOjw0mwSNLbXsVkAcBKKbF1CPY7rXp1NBOY1veilJyrll6R500oaQGlCE2unWOMLflPPSyhl6R500oaQGlCE2unWOMLflJyrlldzXow6vrtyJKm)ft2GDLbBYJ1VcKAdvUUIazjnLfcXuy9u(VyIfeXI(Aon)ft2GDLbBYJ1VcKAttX(vywstzXow0xZP5VyYgSRmytES(vGuBwwSmkbOh(dwja3D1mhdHvYNSLiIqtgCcqQCDfbMmUeGH(EQppbOBLd7uafw0YcaVpxxrgSdGYtyNdE(QalAzzil6R50qb1zHPSAvEBAk2VcZYMSqiMcRNY)ftSKMYI(AonuqDwykJHkVnnf7xHzztwietH1t5)IjwgXIwwgYI(AonbpFvWSSyjnLf91CAS6lg2GNRYEh86czRLc7TbGRwelikswShTXyzelAzzil2XsacGkVEdkr7ZlwstzrFnNguUcSjWmfBbTrDmvFMkQrEdKmllwgXIwwgYIDSeGaOYR3aGQFpAZsAkl6R500oaQGlCE2unWOMMI9RWSGiw0elAzrFnNM2bqfCHZZMQbg1SSyrll2XsVkAcBKKbF1CPY7rXp1NBOY1veilPPSyhl6R500oaQGlCE2unWOMLflJyrlldzXow6vrtyJKm)ft2GDLbBYJ1VcKAdvUUIazjnLfcXuy9u(VyIfeXI(Aon)ft2GDLbBYJ1VcKAttX(vywstzXow0xZP5VyYgSRmytES(vGuBwwSmkbOh(dwjaNlLkhdHvYNSLigbjdobivUUIatgxcqqch6Z6pyLaC8WelOgqnGfyXsambOh(dwjaT5DFWodNzsTkk5t2sehajdobivUUIatgxcqp8hSsaIFVNxtjabjCOpR)GvcWXdtSa89EEnXYdzXQHbwacvEZIgeuNfM0ilOAROF8Ral7oMffHXS8xmXYV7flolOgT)7SqiMcRNyrrZNfyZcSurzbDwL3SObb1zHjwomllldlOg3VZYGTpcyXERalu9uZIZcqOYBw0GG6SWel3KfeYsH9Mf8Fkfl7oMffHXS87EXI9Ongl43dOGzXlqwq1wr)4xbw8cKfublaquiw2DaelXWMy539If0qOywqLMJLMI9RUcPHLXdtS46qael2RPXqxSS74NybC1xHKfuBt1aJYIxGSyV92JUyz3XpXIT73HRNfuBt1aJMam03t95jaPG6SWK5QSAvEZIwwSJf91CAAhavWfopBQgyuZYIL0uwOG6SWKbdvENlcXplPPSmKfkOolmz8kAUie)SKMYI(AonbpFvW0uSFfMfeXIh(dwgBT)7gcXuy9u(VyIfTSOVMttWZxfmllwgXIwwgYIDSGPpRdRf28h12hbz7TcSKMYsVkAcBKKXQVyydEUk7DWRlKTwkS3gQCDfbYIww0xZPXQVyydEUk7DWRlKTwkS3gaUArSGiwShTXyrllbiubcTvMGNVkyAk2VcZYMSGgcLfTSmKf7yjabqLxVPoK7FE6elPPSeGqfi0wzcWcaefk)7ugBD99yttX(vyw2Kf0qOSmIfTSmKf7yP9az(gQuSKMYsacvGqBLrNAm1OCfsttX(vyw2Kf0qOSmILrSKMYcfuNfMmxL9kklAzzil6R50yZ7(GDgoZKAvKzzXsAklylsPY7o(jwqelJzqynXIwwgYIDSeGaOYR3aGQFpAZsAkl2XI(AonTdGk4cNNnvdmQzzXYiwstzjabqLxVbav)E0MfTSGTiLkV74NybrSmMbHzzuYNSfeESKbNaKkxxrGjJlbiiHd9z9hSsaoEyIfuJ2)DwG)o12omXIT9lSZYHz5kwacvEZIgeuNfM0ilOAROF8RalWMLhYIvddSGoRYBw0GG6SWucqp8hSsaAR9Fp5t2ccJwYGtasLRRiWKXLaeKWH(S(dwjarTUs979kbOh(dwja7vL9WFWkRo8NauD4pxEmLaC6k1V3RKp5t(eGaOgFWkzl2pM92pwerdHMa0M31viXjarn2kQPTm(BzaIbKfwg8oXYfBb7NLjSzzBOfvuVnlnfHRRjqwWWyIfF9Wy)jqwc7EHKWgEd05kIf7hqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIyjIdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBWBGASvutBz83YaedilSm4DILl2c2pltyZY2G00xQFBwAkcxxtGSGHXel(6HX(tGSe29cjHn8gOZvelO7bKfublau)eilaVyuXcoA9oIzbDXYdzbDwolGhGdFWIfOf1(dBwgI(rSmenepYWBGoxrSGUhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzzO9iEKH3aDUIybHoGSGkybG6Nazz7Ev0e2ijdQVnlpKLT7vrtyJKmOUHkxxrGBZYq0q8idVb6CfXsemGSGkybG6Nazb4fJkwWrR3rmlOlwEilOZYzb8aC4dwSaTO2FyZYq0pILH2J4rgEd05kILiyazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLHOH4rgEd05kILbWaYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldJiIhz4nqNRiwgadilOcwaO(jqw2(7RqHEdAguFBwEilB)9vOqV5rZG6BZYq7r8idVb6CfXYayazbvWca1pbYY2FFfk0BS3G6BZYdzz7VVcf6nV9guFBwgApIhz4nqNRiwqBSbKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwqdTbKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwqZ(bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwqlIdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSGMMgqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIybn09aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldThXJm8gOZvelOHUhqwqfSaq9tGSS93xHc9g0mO(2S8qw2(7RqHEZJMb13MLH2J4rgEd05kIf0q3dilOcwaO(jqw2(7RqHEJ9guFBwEilB)9vOqV5T3G6BZYq0q8idVb6CfXcAi0bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgApIhz4nqNRiwqdHoGSGkybG6Nazz7VVcf6nOzq9Tz5HSS93xHc9MhndQVnldrdXJm8gOZvelOHqhqwqfSaq9tGSS93xHc9g7nO(2S8qw2(7RqHEZBVb13MLH2J4rgEdEduJTIAAlJ)wgGyazHLbVtSCXwW(zzcBw22QPamw3)TzPPiCDnbYcggtS4Rhg7pbYsy3lKe2WBGoxrSeXbKfublau)eilB)9vOqVbndQVnlpKLT)(kuO38Ozq9Tzzyer8idVb6CfXccpGSGkybG6Nazz7VVcf6n2Bq9Tz5HSS93xHc9M3EdQVnldJiIhz4nqNRiwIGbKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBw8NfnqZhDyziAiEKH3G3a1yROM2Y4VLbigqwyzW7elxSfSFwMWMLTDiTnlnfHRRjqwWWyIfF9Wy)jqwc7EHKWgEd05kIf0gqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIyX(bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwSFazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3Mf)zrd08rhwgIgIhz4nqNRiwI4aYcQGfaQFcKLTFxr1Bq9Tz5HSS97kQEdQBOY1ve42SmenepYWBGoxrSeXbKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwggbiEKH3aDUIybDpGSGkybG6Nazb4fJkwWrR3rmlOl0flpKf0z5SedbxQfMfOf1(dBwgIUgXYq0q8idVb6CfXc6EazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLH2J4rgEd05kIfe6aYcQGfaQFcKfGxmQybhTEhXSGUqxS8qwqNLZsmeCPwywGwu7pSzzi6AeldrdXJm8gOZveli0bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwIGbKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwgadilOcwaO(jqwaEXOIfC06DeZc6ILhYc6SCwapah(GflqlQ9h2Sme9JyzO9iEKH3aDUIybn7hqwqfSaq9tGSa8Irfl4O17iMf0flpKf0z5SaEao8blwGwu7pSzzi6hXYq0q8idVb6CfXcAi8aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrdXJm8gOZvelOPPbKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwqdDpGSGkybG6Nazz7Ev0e2ijdQVnlpKLT7vrtyJKmOUHkxxrGBZYq7r8idVb6CfXcArWaYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrdXJm8gOZvel2p2aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldThXJm8gOZvel2B)aYcQGfaQFcKfGxmQybhTEhXSGUy5HSGolNfWdWHpyXc0IA)Hnldr)iwgIgIhz4nqNRiwShHhqwqfSaq9tGSa8Irfl4O17iMf0flpKf0z5SaEao8blwGwu7pSzzi6hXYq7r8idVb6CfXI9i8aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrdXJm8gOZvel2JUhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIyXEe6aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrdXJm8gOZvel2pagqwqfSaq9tGSa8Irfl4O17iMf0flpKf0z5SaEao8blwGwu7pSzzi6hXYq7r8idVb6CfXsehBazbvWca1pbYcWlgvSGJwVJywqxS8qwqNLZc4b4WhSybArT)WMLHOFeldrdXJm8g8gOgBf10wg)TmaXaYcldENy5ITG9ZYe2SS90vQFVxBZstr46AcKfmmMyXxpm2FcKLWUxijSH3aDUIyX(bKfublau)eilaVyuXcoA9oIzbDXYdzbDwolGhGdFWIfOf1(dBwgI(rSmenepYWBWBGASvutBz83YaedilSm4DILl2c2pltyZY24FBwAkcxxtGSGHXel(6HX(tGSe29cjHn8gOZvel2pGSGkybG6Nazz7Ev0e2ijdQVnlpKLT7vrtyJKmOUHkxxrGBZYqekIhz4nqNRiwI4aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrdXJm8gOZveli8aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrdXJm8gOZvelO7bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBw8NfnqZhDyziAiEKH3aDUIybTXgqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzzO9iEKH3aDUIybneEazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLHOH4rgEd05kIf0q3dilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmutiEKH3aDUIybne6aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrdXJm8gOZvelOfbdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSypAdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSypcpGSGkybG6Nazb4fJkwWrR3rmlOlwEilOZYzb8aC4dwSaTO2FyZYq0pILHimIhz4nqNRiwShHhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIyXEnnGSGkybG6Nazb4fJkwWrR3rmlOlwEilOZYzb8aC4dwSaTO2FyZYq0pILHOH4rgEd05kIf710aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrdXJm8gOZvel2JUhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIyjIOnGSGkybG6Nazb4fJkwWrR3rmlOlwEilOZYzb8aC4dwSaTO2FyZYq0pILHreXJm8gOZvelreTbKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwIO9dilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSeXioGSGkybG6Nazb4fJkwWrR3rmlOlwEilOZYzb8aC4dwSaTO2FyZYq0pILHreXJm8gOZvelreHhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzzO9iEKH3aDUIyjIO7bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgApIhz4nqNRiwIicDazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLH2J4rgEd05kILioagqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3G3y8JTG9tGSGUzXd)blwuh(XgEJeGwnCEkkbOgQHSmox5vGyrZ1RdK3qd1qw088oSZcAdanYI9JzV98g8gAOgYcQ29cjHhqEdnudzrZyzRGGeilaHkVzzCKhB4n0qnKfnJfuT7fscKL3BK0NVjlbhtywEilHObfLFVrsp2WBOHAilAglOMOyiacKLvvuGWyVJYcaVpxxrywgEgYOrwSAcqg)EJxnsIfnBtwSAcGb)EJxnsAKH3qd1qw0mw2ka4bYIvtbh)xHKfuJ2)DwUjl3VnMLFNyXwdlKSObb1zHjdVHgQHSOzSO55OqSGkybaIcXYVtSa0667XS4SOU)velXWMyzQieF6kILH3KLOWfl7oyT9ZY(9SCpl4lEPEVi4cRIYIT73zzCA(BDWSGawqfPi8FUILTQoKvmvVgz5(TbzbJYznYWBOHAilAglAEokelXq8ZY2Zd5(NBk2VcVnl4avEFqmlULLkklpKfDigZY8qU)ywGLkQH3qd1qw0mwgCt(ZYGHXelWjlJt57SmoLVZY4u(oloMfNfSffoxXY3xHc9gEdnudzrZyrZ3IkQzz4ziJgzb1O9FxJSGA0(VRrwa(EpVMgXsSdsSedBILMWN6O6z5HSqERoQzjaJ19xZWV3VH3qd1qw0mwqThIzza2vGnbYIgeBbTrDmvplHDkGcltyZcQ0CSSWosYWBWBOHAilBTk47pbYY4CLxbILTIqqhwcEXIoXYeUkqw8NL9)TWdi6rVUR8kqAg(IdgK3VV0nhe9JZvEfind4fJk0hdA2)y1a8ZtrrQ7kVcK5r8ZBWB4H)Gf2y1uagR7FKOCfytGzS113J5n0qwg8oXcaVpxxrSCywW0ZYdzzmwSD)olfKf87plWILfMy57RqHESgzbnwSTtfl)oXY8A8ZcSiwomlWILfM0il2ZYnz53jwWuawGSCyw8cKLiYYnzrh(7S4nXB4H)Gf2y1uagR7pcIe9a8(CDfPXYJPiHvEHP83xHc9AeGRwuKJXB4H)Gf2y1uagR7pcIe9a8(CDfPXYJPiHvEHP83xHc9AeAfPdcQraUArrIMgVzKFFfk0BqZS748ctz91CQ97RqHEdAMaeQaH2kd4Q9)GLw7((kuO3GM5WMhgtz4mhdl83WfohGf(7v4pyH5n8WFWcBSAkaJ19hbrIEaEFUUI0y5XuKWkVWu(7RqHEncTI0bb1iaxTOiTxJ3mYVVcf6n2B2DCEHPS(Ao1(9vOqVXEtacvGqBLbC1(FWsRDFFfk0BS3CyZdJPmCMJHf(B4cNdWc)9k8hSW8gAildENWelFFfk0JzXBILc(S4Rhg7)fCLkklG0tHNazXXSalwwyIf87plFFfk0JnSWcq6zbG3NRRiwEilimloMLFNIYIRWqwkIazbBrHZvSS7fO6kKgEdp8hSWgRMcWyD)rqKOhG3NRRinwEmfjSYlmL)(kuOxJqRiDqqncWvlksewJ3mskcxNLfbAUch6176kkhHlV(vCgKaCbknLIW1zzrGgk2kAtUkdBWYRaLMsr46SSiqdgUuk6)RqM7LEuEdnKfG0Jz53jwa(EJxnsILae)SmHnlk)PMLGRclL)hSWSmCcBwie7XwkIfB7uXYdzb)E)SaUITUcjl60e2elO2MQbgLLPRuywGZ5iEdp8hSWgRMcWyD)rqKOhG3NRRinwEmfjgNdq8RraUArrgXXg0q00SXmOPPbHPpRdRf28h12hbze2kmI3Wd)blSXQPamw3Feej6b4956ksJLhtrIN5ae)AeGRwuKAASbnennBmdAAAqy6Z6WAHn)rT9rqgHTcJ4n0qwaspMf)zX2(f2zXJHR6zbozzRyeclOcwaGOqSG3Hlfil6ellmboGSGWJXIT73HRNfurkc)NRybO113JzXlqwI4ySy7(DdVHh(dwyJvtbySU)iis0dW7Z1vKglpMImalaquOSJT0iaxTOiJ4yiaTXguVkAcBKKjqkc)NRYyRRVhZB4H)Gf2y1uagR7pcIe9XqyHYv5jSJ5n8WFWcBSAkaJ19hbrIEBT)7AuDfLdGrI2yA8MroKcQZctg1Q8oxeI)0ukOolmzUkJHkVttPG6SWK5QSo83ttPG6SWKXRO5Iq8pI3G3qdzbH0uWXpl2ZcQr7)olEbYIZcW3B8QrsSalwaoywSD)olB5qU)SGADIfVazzCWToywGnlaFVNxtSa)DQTDyI3Wd)blSbArf1iis0BR9FxJ3mYHuqDwyYOwL35Iq8NMsb1zHjZvzmu5DAkfuNfMmxL1H)EAkfuNfMmEfnxeI)rATAcGbnJT2)DT2z1eaJ9gBT)78gE4pyHnqlQOgbrIE8798AsJQROCamsnPXBg5WH21RIMWgjz0DLxbkdNzxPY)(viXPP2fGaOYR3uhY9ppDkn1oSfPu53BK0Jn437PRurIwAQDVRO6nL)RMWzDx5vGmu56kcCuA6qkOolmzWqL35Iq8NMsb1zHjZvz1Q8onLcQZctMRY6WFpnLcQZctgVIMlcX)OrATdtFwhwlS5pQTpcY2Bf4n8WFWcBGwurncIe943B8QrsAuDfLdGrQjnEZih2RIMWgjz0DLxbkdNzxPY)(viXAdqau51BQd5(NNoPfBrkv(9gj9yd(9E6kvKOnsRDy6Z6WAHn)rT9rq2ERaVbVHgQHSObiMcRNazHaqDuw(lMy53jw8WdBwomloa)uUUIm8gE4pyHJedvEN1jpM3Wd)blmcIe9bxPYE4pyLvh(1y5XuKqlQOwJ4VVWhjAA8Mr(xmHOH2pip8hSm2A)3nbh)5)Ije4H)GLb)EpVMmbh)5)IPr8gAilaPhZYwHAalWILiIawSD)oC9Sa238zXlqwSD)olaFVvWgKfVazXEeWc83P22HjEdp8hSWiis0dW7Z1vKglpMI8WzhsAeGRwuKylsPYV3iPhBWV3txP2enTdT7DfvVb)ERGnOHkxxrGPPVRO6n4NukVZG9nFdvUUIahLMITiLk)EJKESb)EpDLAt75n0qwaspMLGICael22PIfGV3ZRjwcEXY(9Sypcy59gj9ywSTFHDwomlnPiaE9SmHnl)oXIgeuNfMy5HSOtSy10K6MazXlqwSTFHDwMNsrnlpKLGJFEdp8hSWiis0dW7Z1vKglpMI8W5GICaKgb4Qffj2IuQ87ns6Xg8798AAt04n0qwgG6956kILF3Fwc7uafml3KLOWflEtSCflolidGS8qwCaWdKLFNybF)Y)dwSyBNAIfNLVVcf6zH(alhMLfMaz5kw0P3grflbh)yEdp8hSWiis0dW7Z1vKglpMI8QmYaOgb4QffPvtaYidGg0mXqynVMstTAcqgza0GMbVQ51uAQvtaYidGg0m43B8QrsPPwnbiJmaAqZGFVNUsLMA1eGmYaObnZC1rZWzMuRIstTAcGPDaubx48SPAGrtt1xZPj45RcMMI9RWrQVMttWZxfmGR2)dwPPa8(CDfzoC2HeVHgYY4Hjwgh1yQr5kKS4pl)oXcvGSaNSGABQgyuwSTtfl7o(jwomlUoeaXc6Em0LgzXNp1SGkybaIcXIT73zzCqFWS4filWFNABhMyX297SGQTI(XVc8gE4pyHrqKOxNAm1OCfsnEZiho0UaeavE9M6qU)5PtPP2fGqfi0wzcWcaefk)7ugBD99yZYkn1UEv0e2ijJUR8kqz4m7kv(3VcjEKw91CAcE(QGPPy)k8MOPjT6R500oaQGlCE2unWOMMI9RWicH1AxacGkVEdaQ(9ODAAacGkVEdaQ(9OTw91CAcE(QGzzPvFnNM2bqfCHZZMQbg1SS0ouFnNM2bqfCHZZMQbg10uSFfgrrIM9AgcpOEv0e2ijd(Q5sL3JIFQppnvFnNMGNVkyAk2VcJi0qlnfn0f2IuQ8UJFcrOzq3JgPfG3NRRiZvzKbqEdnKfec8zX297S4SGQTI(XVcS87(ZYHRTFwCwqilf2BwSAyGfyZITDQy53jwMhY9NLdZIRdxplpKfQa5n8WFWcJGirVf8pyPXBg5q91CAcE(QGPPy)k8MOPjTdTRxfnHnsYGVAUu59O4N6Ztt1xZPPDaubx48SPAGrnnf7xHreAdaT6R500oaQGlCE2unWOML1O0uDigRDEi3)CtX(vyezVMgPfG3NRRiZvzKbqEdnKfu5QWs5pHzX2o97uZYcFfswqfSaarHyPG2yX2PuS4kf0glrHlwEil4)ukwco(z53jwWEmXIhdx1ZcCYcQGfaikecq1wr)4xbwco(X8gE4pyHrqKOhG3NRRinwEmfzawaGOqzqchTcAeGRwuKb6udhopK7FUPy)kSMHMM0SaeQaH2ktWZxfmnf7xHhHUqlcgB0Mb6udhopK7FUPy)kSMHMM0SaeQaH2ktawaGOq5FNYyRRVhBAk2VcpcDHwem2iT21(bMjau9gheeBieF4hRDODbiubcTvMGNVkyAYbJMMAxacvGqBLjalaquO8VtzS113Jnn5GrhLMgGqfi0wzcE(QGPPy)k8Mx9uBbv(tG55HC)Znf7xHtt7vrtyJKmbsr4)CvgBD99yTbiubcTvMGNVkyAk2VcVzehlnnaHkqOTYeGfaiku(3Pm2667XMMI9RWBE1tTfu5pbMNhY9p3uSFfwZqBS0u7cqau51BQd5(NNoXBOHSmEycKLhYciP8OS87ellSJKybozbvBf9JFfyX2ovSSWxHKfq4sxrSalwwyIfVazXQjau9SSWosIfB7uXIxS4GGSqaO6z5WS46W1ZYdzb8iEdp8hSWiis0dW7Z1vKglpMImaMdWc8(dwAeGRwuKdFVrsV5Vyk)Wm4rBIMMstB)aZeaQEJdcInxTPMgBK2HdPiCDwweOHITI2KRYWgS8kqAhAxacGkVEdaQ(9ODAAacvGqBLHITI2KRYWgS8kqMMI9RWicn0ncfbd10G6vrtyJKm4RMlvEpk(P(8rJ0AxacvGqBLHITI2KRYWgS8kqMMCWOJstPiCDwweObdxkf9)viZ9spQ2H2fGaOYR3uhY9ppDknnaHkqOTYGHlLI()kK5EPhnhrewtrWyOzAk2VcJi0qdHhLMomaHkqOTYOtnMAuUcPPjhmAAQDThiZ3qLknnabqLxVPoK7FE60iTdT7DfvVzU6Oz4mtQvrgQCDfbMMgGaOYR3aGQFpARnaHkqOTYmxD0mCMj1QittX(vyeHgAiqtdQxfnHnsYGVAUu59O4N6ZttTlabqLxVbav)E0wBacvGqBLzU6Oz4mtQvrMMI9RWisFnNMGNVkyaxT)hSqaA2pOEv0e2ijJvFXWg8Cv27GxxiBTuyV1m0SFK2HueUollc0Cfo0R31vuocxE9R4mib4cK2aeQaH2kZv4qVExxr5iC51VIZGeGlqMMI9RWistJsthoKIW1zzrGg8UdcTrGzyRNHZ8d7yQETbiubcTvMh2Xu9ey(k8HC)ZrutAkI2JMPPy)k8O00Hdb4956kYaR8ct5VVcf6JeT0uaEFUUImWkVWu(7RqH(iJ4iTd)(kuO3GMPjhmAoaHkqOTkn97RqHEdAMaeQaH2kttX(v4nV6P2cQ8NaZZd5(NBk2VcRzOn2O0uaEFUUImWkVWu(7RqH(iTx7WVVcf6n2BAYbJMdqOceARst)(kuO3yVjaHkqOTY0uSFfEZREQTGk)jW88qU)5MI9RWAgAJnknfG3NRRidSYlmL)(kuOpYXgnAeVHgYYauVpxxrSSWeilpKfqs5rzXROS89vOqpMfVazjaIzX2ovSyZV)kKSmHnlEXIgSS2H95Sy1WaVHh(dwyeej6b4956ksJLhtr(79PuzmrOqD2MFVgb4QffPDy4sPFfO537tPYyIqHAdvUUIattNhY9p3uSFfEt7hBS0uDigRDEi3)CtX(vyezVMqWqeEmntFnNMFVpLkJjcfQn43dOmi7hLMQVMtZV3NsLXeHc1g87bu2mIrGMnSxfnHnsYGVAUu59O4N6ZhK9J4n0qwgpmXIgeBfTjxXIMFdwEfiwSFmmfWSOttytS4SGQTI(XVcSSWelWMfmKLF3FwUNfBNsXI6kILLfl2UFNLFNyHkqwGtwqTnvdmkVHh(dwyeej6xykFpfRXYJPiPyROn5QmSblVcKgVzKbiubcTvMGNVkyAk2VcJi7htBacvGqBLjalaquO8VtzS113Jnnf7xHrK9JPDiaVpxxrMFVpLkJjcfQZ287tt1xZP537tPYyIqHAd(9akBgXXqWWEv0e2ijd(Q5sL3JIFQpFqrC0iTa8(CDfzUkJmaMMQdXyTZd5(NBk2VcJOiIq5n0qwgpmXcq4sPO)kKSGAAPhLf0nMcyw0PjSjwCwq1wr)4xbwwyIfyZcgYYV7pl3ZITtPyrDfXYYIfB3VZYVtSqfilWjlO2MQbgL3Wd)blmcIe9lmLVNI1y5XuKy4sPO)VczUx6r14nJCyacvGqBLj45RcMMI9RWicDR1UaeavE9gau97rBT2fGaOYR3uhY9ppDknnabqLxVPoK7FE6K2aeQaH2ktawaGOq5FNYyRRVhBAk2VcJi0T2Ha8(CDfzcWcaefkds4OvinnaHkqOTYe88vbttX(vyeHUhLMgGaOYR3aGQFpARDOD9QOjSrsg8vZLkVhf)uFU2aeQaH2ktWZxfmnf7xHre6onvFnNM2bqfCHZZMQbg10uSFfgrOngcgQPbrr46SSiqZv4VxHh24m4b4kkRtk1iT6R500oaQGlCE2unWOML1O0uDigRDEi3)CtX(vyezVMstPiCDwweOHITI2KRYWgS8kqAdqOceARmuSv0MCvg2GLxbY0uSFfEt7hBKwaEFUUImxLrga1AhfHRZYIanxHd96DDfLJWLx)kodsaUaLMgGqfi0wzUch6176kkhHlV(vCgKaCbY0uSFfEt7hlnvhIXANhY9p3uSFfgr2pgVHgYYwv28OywwyILXFasnhl2UFNfuTv0p(vGfyZI)S87elubYcCYcQTPAGr5n8WFWcJGirpaVpxxrAS8ykYlcbZbybE)blncWvlks91CAcE(QGPPy)k8MOPjTdTRxfnHnsYGVAUu59O4N6Ztt1xZPPDaubx48SPAGrnnf7xHruKOPjJMqWWiA00G0xZPrxbHGQf(nlRriyicB0KMfrJMgK(Aon6kieuTWVzznAqueUollc0Cf(7v4HnodEaUIY6KsHae2OPbnKIW1zzrGMFNYZRXFgFipL2aeQaH2kZVt5514pJpKNY0uSFfgrrA)yJ0QVMtt7aOcUW5zt1aJAwwJst1HyS25HC)Znf7xHrK9AknLIW1zzrGgk2kAtUkdBWYRaPnaHkqOTYqXwrBYvzydwEfittX(vyEdp8hSWiis0VWu(EkwJLhtrEfo0R31vuocxE9R4mib4cKgVzKa8(CDfzUiemhGf49hS0cW7Z1vK5QmYaiVHgYY4HjwaU7GqBeilA(Tol60e2elOAROF8RaVHh(dwyeej6xykFpfRXYJPiX7oi0gbMHTEgoZpSJP614nJCyacvGqBLj45RcMMCWOATlabqLxVPoK7FE6KwaEFUUIm)EFkvgtekuNT53RDyacvGqBLrNAm1OCfsttoy00u7ApqMVHk1O00aeavE9M6qU)5PtAdqOceARmbybaIcL)DkJTU(ESPjhmQ2Ha8(CDfzcWcaefkds4OvinnaHkqOTYe88vbttoy0rJ0ccFdEvZRjZFbuUcP2HGW3GFsP8opvEtM)cOCfY0u7Exr1BWpPuENNkVjdvUUIattXwKsLFVrsp2GFVNxtBgXrAbHVjgcR51K5VakxHu7qaEFUUImho7qknTxfnHnsYO7kVcugoZUsL)9RqIttD83UkBbTr9MroaglnfG3NRRitawaGOqzqchTcPP6R50ORGqq1c)ML1iT2rr46SSiqZv4qVExxr5iC51VIZGeGlqPPueUollc0Cfo0R31vuocxE9R4mib4cK2aeQaH2kZv4qVExxr5iC51VIZGeGlqMMI9RWBgXX0AN(AonbpFvWSSst1HyS25HC)Znf7xHrecpgVHgYYG3pmlhMfNL2)DQzHuUoS9NyXMhLLhYsSJcXIRuSalwwyIf87plFFfk0Jz5HSOtSOUIazzzXIT73zbvBf9JFfyXlqwqfSaarHyXlqwwyILFNyX(cKfSc(SalwcGSCtw0H)olFFfk0JzXBIfyXYctSGF)z57RqHEmVHh(dwyeej6xykFpfJ1iwbFCKFFfk0JMgVzKdb4956kYaR8ct5VVcf6Tls00A33xHc9g7nn5GrZbiubcTvPPdb4956kYaR8ct5VVcf6JeT0uaEFUUImWkVWu(7RqH(iJ4iTd1xZPj45RcMLL2H2fGaOYR3aGQFpANMQVMtt7aOcUW5zt1aJAAk2VcJGHr0OPb1RIMWgjzWxnxQ8Eu8t95JquKFFfk0BqZOVMZm4Q9)GLw91CAAhavWfopBQgyuZYknvFnNM2bqfCHZZMQbgnJVAUu59O4N6ZnlRrPPbiubcTvMGNVkyAk2VcJa7387RqHEdAMaeQaH2kd4Q9)GLw70xZPj45RcMLL2H2fGaOYR3uhY9ppDkn1oaEFUUImbybaIcLbjC0kmsRDbiaQ86nOeTpVstdqau51BQd5(NNoPfG3NRRitawaGOqzqchTcAdqOceARmbybaIcL)DkJTU(ESzzP1UaeQaH2ktWZxfmllTdhQVMtdfuNfMYQv5TPPy)k8MOnwAQ(AonuqDwykJHkVnnf7xH3eTXgP1UEv0e2ijJUR8kqz4m7kv(3VcjonDO(Aon6UYRaLHZSRu5F)kK4C5)Qjd(9akrQP0u91CA0DLxbkdNzxPY)(viXzVdErg87buImcgnknvFnNguUcSjWmfBbTrDmvFMkQrEdKmlRrPP6qmw78qU)5MI9RWiY(Xstb4956kYaR8ct5VVcf6JCSrAb4956kYCvgzaK3Wd)blmcIe9lmLVNIXAeRGpoYVVcf6TxJ3mYHa8(CDfzGvEHP83xHc92fP9AT77RqHEdAMMCWO5aeQaH2Q0uaEFUUImWkVWu(7RqH(iTx7q91CAcE(QGzzPDODbiaQ86naO63J2PP6R500oaQGlCE2unWOMMI9RWiyyenAAq9QOjSrsg8vZLkVhf)uF(ief53xHc9g7n6R5mdUA)pyPvFnNM2bqfCHZZMQbg1SSst1xZPPDaubx48SPAGrZ4RMlvEpk(P(CZYAuAAacvGqBLj45RcMMI9RWiW(n)(kuO3yVjaHkqOTYaUA)pyP1o91CAcE(QGzzPDODbiaQ86n1HC)ZtNstTdG3NRRitawaGOqzqchTcJ0AxacGkVEdkr7ZlTdTtFnNMGNVkywwPP2fGaOYR3aGQFpApknnabqLxVPoK7FE6KwaEFUUImbybaIcLbjC0kOnaHkqOTYeGfaiku(3Pm2667XMLLw7cqOceARmbpFvWSS0oCO(AonuqDwykRwL3MMI9RWBI2yPP6R50qb1zHPmgQ820uSFfEt0gBKw76vrtyJKm6UYRaLHZSRu5F)kK400H6R50O7kVcugoZUsL)9RqIZL)RMm43dOePMst1xZPr3vEfOmCMDLk)7xHeN9o4fzWVhqjYiy0OrPP6R50GYvGnbMPylOnQJP6ZurnYBGKzzLMQdXyTZd5(NBk2VcJi7hlnfG3NRRidSYlmL)(kuOpYXgPfG3NRRiZvzKbqEdnKLXdtywCLIf4VtnlWILfMy5EkgZcSyjaYB4H)GfgbrI(fMY3tXyEdnKfn4(DQzbjKLREil)oXc(zb2S4qIfp8hSyrD4N3Wd)blmcIe99QYE4pyLvh(1y5XuKoK0i(7l8rIMgVzKa8(CDfzoC2HeVHh(dwyeej67vL9WFWkRo8RXYJPiXpVbVHgYcQCvyP8NWSyBN(DQz53jw0Cn5Xb)d7uZI(AozX2PuSmDLIf4CYIT73VILFNyPie)SeC8ZB4H)Gf24qksaEFUUI0y5XuKGn5XzBNsLNUsLHZPgb4QffzVkAcBKK5VyYgSRmytES(vGuRDO(Aon)ft2GDLbBYJ1VcKAttX(vyeHmaAIDeJGXmOLMQVMtZFXKnyxzWM8y9RaP20uSFfgrE4pyzWV3ZRjdHykSEk)xmHGXmOPDifuNfMmxLvRY70ukOolmzWqL35Iq8NMsb1zHjJxrZfH4F0iT6R508xmzd2vgSjpw)kqQnllEdnKfu5QWs5pHzX2o97uZcW3B8QrsSCywSb7FNLGJ)RqYcea1Sa89EEnXYvSGoRYBw0GG6SWeVHh(dwyJdjeej6b4956ksJLhtrEilytz87nE1ijncWvlks7OG6SWK5QmgQ8wl2IuQ87ns6Xg8798AAteQM9UIQ3GHlvgoZ)oLNWMWVHkxxrGdYEeqb1zHjZvzD4VR1UEv0e2ijJvFXWg8Cv27GxxiBTuyV1AxVkAcBKKbw0VJZbf5DgWHpyXBOHSmEyIfublaquiwSTtfl(ZIIWyw(DVyrtJXYwXiew8cKf1velllwSD)olOAROF8RaVHh(dwyJdjeej6dWcaefk)7ugBD99ynEZiTdSxhOPG5aiw7WHa8(CDfzcWcaefkds4OvqRDbiubcTvMGNVkyAYbJQ1UEv0e2ijJvFXWg8Cv27GxxiBTuyVtt1xZPj45RcMLL2H21RIMWgjzS6lg2GNRYEh86czRLc7DAAVkAcBKKjqkc)NRYyRRVhNMopK7FUPy)k8MOzpcnnvhIXANhY9p3uSFfgrbiubcTvMGNVkyAk2VcJa0glnvFnNMGNVkyAk2VcVjA2pAK2Hdh64VDv2cAJAefjaVpxxrMaSaarHYo2knfBrkv(9gj9yd(9EEnTzehPDO(AonuqDwykRwL3MMI9RWBI2yPP6R50qb1zHPmgQ820uSFfEt0gBuAQ(AonbpFvW0uSFfEtnPvFnNMGNVkyAk2VcJOirZ(rAhA37kQEd(jLY7myFZpnvFnNg8790vkttX(vyeHMrtA2ygnnOEv0e2ijtGue(pxLXwxFponvFnNMGNVkyAk2VcJi91CAWV3txPmnf7xHrGM0QVMttWZxfmlRrAhAxVkAcBKK5VyYgSRmytES(vGuNMAxVkAcBKKjqkc)NRYyRRVhNMQVMtZFXKnyxzWM8y9RaP20uSFfEtcXuy9u(VyAuAAVkAcBKKr3vEfOmCMDLk)7xHeps7q76vrtyJKm6UYRaLHZSRu5F)kK400H6R50O7kVcugoZUsL)9RqIZL)RMm43dOezeKMQVMtJUR8kqz4m7kv(3Vcjo7DWlYGFpGsKrWOrPP6qmw78qU)5MI9RWicTX0AxacvGqBLj45RcMMCWOJ4n0qwgpmXcWvnVMy5kwS8cKIValWIfVI(7xHKLF3FwuhacZcAimMcyw8cKffHXSy7(DwIHnXY7ns6XS4fil(ZYVtSqfilWjlolaHkVzrdcQZctS4plOHWSGPaMfyZIIWywAk2V6kKS4ywEilf8zz3bCfswEilnnBcVZc4QVcjlOZQ8MfniOolmXB4H)Gf24qcbrIE8QMxtAmenOO87ns6XrIMgVzKdBA2eE31vuAQ(AonuqDwykJHkVnnf7xHrue1sb1zHjZvzmu5T2MI9RWicnew77kQEdgUuz4m)7uEcBc)gQCDfbos77ns6n)ft5hMbpAt0qyndBrkv(9gj9ye0uSFfw7qkOolmzUk7v000MI9RWicza0e7iEeVHgYY4HjwaUQ51elpKLDhaXIZcsfu3vS8qwwyILXFasnhVHh(dwyJdjeej6XRAEnPXBgjaVpxxrMlcbZbybE)blTbiubcTvMRWHE9UUIYr4YRFfNbjaxGmn5Gr1sr46SSiqZv4qVExxr5iC51VIZGeGlqADRCyNcOWBOHSmaJilwwwSa89E6kfl(ZIRuS8xmHzzvkcJzzHVcjlOt0G3oMfVaz5EwomlUoC9S8qwSAyGfyZIIEw(DIfSffoxXIh(dwSOUIyrNuqBSS7fOIyrZ1KhRFfi1SalwSNL3BK0J5n8WFWcBCiHGirp(9E6kLgVzK29UIQ3GFsP8od238nu56kcu7q7W0N1H1cB(JA7JGmcBfstPG6SWK5QSxrttXwKsLFVrsp2GFVNUsTzehPDO(Aon437PRuMMMnH3DDfPDi2IuQ87ns6Xg8790vkefX0u76vrtyJKm)ft2GDLbBYJ1VcK6rPPVRO6ny4sLHZ8Vt5jSj8BOY1veOw91CAOG6SWugdvEBAk2VcJOiQLcQZctMRYyOYBT6R50GFVNUszAk2VcJieQwSfPu53BK0Jn437PRuBgjcps7q76vrtyJKmQObVDCEQi6VczgP6ITWuA6FXe6cDHWAAt91CAWV3txPmnf7xHrG9J0(EJKEZFXu(HzWJ2ut8gAilOg3VZcWNukVzrZ138zzHjwGflbqwSTtflnnBcV76kIf91Zc(pLIfB(9SmHnlOt0G3oMfRggyXlqwaH12pllmXIonHnXcQ0Cydla)tPyzHjw0PjSjwqfSaarHybFvGy539NfBNsXIvddS4f83PMfGV3txP4n8WFWcBCiHGirp(9E6kLgVzKVRO6n4NukVZG9nFdvUUIa1QVMtd(9E6kLPPzt4DxxrAhAhM(SoSwyZFuBFeKryRqAkfuNfMmxL9kAAk2IuQ87ns6Xg8790vQnr4rAhAxVkAcBKKrfn4TJZtfr)viZivxSfMst)lMqxOlewtBIWJ0(EJKEZFXu(HzWJ2mI8gAilOg3VZIMRjpw)kqQzzHjwa(EpDLILhYckezXYYILFNyrFnNSOhLfxHHSSWxHKfGV3txPybwSOjwWuawGywGnlkcJzPPy)QRqYB4H)Gf24qcbrIE8790vknEZi7vrtyJKm)ft2GDLbBYJ1VcKATylsPYV3iPhBWV3txP2mYiQDOD6R508xmzd2vgSjpw)kqQnllT6R50GFVNUszAA2eE31vuA6qaEFUUImGn5XzBNsLNUsLHZP2H6R50GFVNUszAk2VcJOiMMITiLk)EJKESb)EpDLAt71(UIQ3GFsP8od238nu56kcuR(Aon437PRuMMI9RWistJgnI3qdzbvUkSu(tywSTt)o1S4Sa89gVAKellmXITtPyj4lmXcW37PRuS8qwMUsXcCo1ilEbYYctSa89gVAKelpKfuiYIfnxtES(vGuZc(9akSSSmSebJXYHz53jwAkcxxtGSSvmcHLhYsWXplaFVXRgjHaGV3txP4n8WFWcBCiHGirpaVpxxrAS8yks8790vQSny95PRuz4CQraUArr64VDv2cAJ6nJGXg0q00mm9zDyTWM)O2(iiBVvyqJzSF0GgIMMPVMtZFXKnyxzWM8y9RaP2GFpGYGgZG2inBO(Aon437PRuMMI9RWdkIOlSfPu5Dh)0GS7DfvVb)Ks5DgSV5BOY1ve4inByacvGqBLb)EpDLY0uSFfEqreDHTiLkV74Ng07kQEd(jLY7myFZ3qLRRiWrA2q91CAMRoAgoZKAvKPPy)k8G00iTd1xZPb)EpDLYSSstdqOceARm437PRuMMI9RWJ4n0qwgpmXcW3B8QrsSy7(Dw0Cn5X6xbsnlpKfuiYILLfl)oXI(AozX297W1ZIcIVcjlaFVNUsXYY6VyIfVazzHjwa(EJxnsIfyXccJawghCRdMf87buWSSQ)uSGWS8EJKEmVHh(dwyJdjeej6XV34vJK04nJeG3NRRidytEC22Pu5PRuz4CQfG3NRRid(9E6kv2gS(80vQmCo1AhaVpxxrMdzbBkJFVXRgjLMouFnNgDx5vGYWz2vQ8VFfsCU8F1Kb)EaLnJyAQ(Aon6UYRaLHZSRu5F)kK4S3bVid(9akBgXrAXwKsLFVrsp2GFVNUsHiewlaVpxxrg8790vQSny95PRuz4CYBOHSmEyIfSnVJzbdz539NLOWfliPNLyhXSSS(lMyrpkll8viz5EwCmlk)jwCmlwqm(0velWIffHXS87EXsezb)EafmlWMfuZx4NfB7uXseral43dOGzHqS11eVHh(dwyJdjeej6Dq36paugBZ7yngIguu(9gj94irtJ3ms7(lGYvi1ANh(dwgh0T(daLX28ood6XosYCvEQoK7FAki8noOB9hakJT5DCg0JDKKb)EafefrTGW34GU1FaOm2M3Xzqp2rsMMI9RWikI8gAilOMOzt4Dw08GWAEnXYnzbvBf9JFfy5WS0KdgvJS87utS4nXIIWyw(DVyrtS8EJKEmlxXc6SkVzrdcQZctSy7(DwacFuRgzrryml)UxSG2ySa)DQTDyILRyXROSObb1zHjwGnlllwEilAIL3BK0JzrNMWMyXzbDwL3SObb1zHjdlAoyT9ZstZMW7SaU6RqYYaSRaBcKfni2cAJ6yQEwwLIWywUIfGqL3SObb1zHjEdp8hSWghsiis0hdH18AsJHObfLFVrspos004nJSPzt4DxxrAFVrsV5Vyk)Wm4rBoCiAimcgITiLk)EJKESb)EpVMgK9dsFnNgkOolmLvRYBZYA0ie0uSFfEe6AiAi4DfvV5TDvogclSHkxxrGJ064VDv2cAJ6nb4956kYGN5ae)AM(Aon437PRuMMI9RWdcDRDOBLd7uaL0uaEFUUImhYc2ug)EJxnskn1okOolmzUk7v0rAhgGqfi0wzcE(QGPjhmQwkOolmzUk7vuT2b2Rd0uWCaeRDiaVpxxrMaSaarHYGeoAfstdqOceARmbybaIcL)DkJTU(ESPjhmAAQDbiaQ86n1HC)ZtNgLMITiLk)EJKESb)EpVMq0WHrGMnuFnNgkOolmLvRYBZYAqrC0Obnene8UIQ382UkhdHf2qLRRiWrJ0AhfuNfMmyOY7Cri(1o0UaeQaH2ktWZxfmn5Grttb71bAkyoaIhLMoKcQZctMRYyOY70u91CAOG6SWuwTkVnllT29UIQ3GHlvgoZ)oLNWMWVHkxxrGJ0oeBrkv(9gj9yd(9EEnHi0gBqdrdbVRO6nVTRYXqyHnu56kcC0OrAhAxacGkVEdkr7ZR0u70xZPbLRaBcmtXwqBuht1NPIAK3ajZYknLcQZctMRYyOY7rATtFnNM2bqfCHZZMQbgnJVAUu59O4N6ZnllEdnKLXdtSGAHBHfyXsaKfB3Vdxplb3Y6kK8gE4pyHnoKqqKOFc7aLHZC5)QjnEZiDRCyNcOKMcW7Z1vK5qwWMY43B8Qrs8gE4pyHnoKqqKOhG3NRRinwEmfzamhGf49hSYoK0iaxTOiTdSxhOPG5aiw7qaEFUUImbWCawG3FWs7q91CAWV3txPmlR003vu9g8tkL3zW(MVHkxxrGPPbiaQ86n1HC)ZtNgPfe(MyiSMxtM)cOCfsTdTtFnNgmuH)lqMLLw70xZPj45RcMLL2H29UIQ3mxD0mCMj1QidvUUIatt1xZPj45RcgWv7)bRndqOceARmZvhndNzsTkY0uSFfgbrWiTdTdtFwhwlS5pQTpcY2BfstPG6SWK5QSAvENMsb1zHjdgQ8oxeI)rAb4956kY879PuzmrOqD2MFV2H2fGaOYR3uhY9ppDknfG3NRRitawaGOqzqchTcPPbiubcTvMaSaarHY)oLXwxFp20uSFfgrOPPrAFVrsV5Vyk)Wm4rBQVMttWZxfmGR2)dwdAmdcDuAQoeJ1opK7FUPy)kmI0xZPj45RcgWv7)bleGM9dQxfnHnsYy1xmSbpxL9o41fYwlf27r8gAilJhMyb12unWOSy7(Dwq1wr)4xbEdp8hSWghsiis03oaQGlCE2unWOA8MrQVMttWZxfmnf7xH3ennLMQVMttWZxfmGR2)dwian7huVkAcBKKXQVyydEUk7DWRlKTwkS3iYE0TwaEFUUImbWCawG3FWk7qI3qdzz8WelOAROF8RalWILailRsrymlEbYI6kIL7zzzXIT73zbvWcaefI3Wd)blSXHecIe9bsr4)Cv2vhYkMQxJ3msaEFUUImbWCawG3FWk7qs7q7cqau51Baq1VhTttTRxfnHnsYGVAUu59O4N6Ztt7vrtyJKmw9fdBWZvzVdEDHS1sH9onvFnNMGNVkyaxT)hS2ms7r3Jst1xZPPDaubx48SPAGrnllT6R500oaQGlCE2unWOMMI9RWicnnz0eVHh(dwyJdjeej6Vk4D5)blnEZib4956kYeaZbybE)bRSdjEdnKLXdtSObXwqBuZY4GfilWILail2UFNfGV3txPyzzXIxGSGDaeltyZcczPWEZIxGSGQTI(XVc8gE4pyHnoKqqKONITG2OoRdlqnEZihgGqfi0wzcE(QGPPy)kmc0xZPj45RcgWv7)ble0RIMWgjzS6lg2GNRYEh86czRLc79GqZ(ndqOceARmuSf0g1zDybAaxT)hSqaAJnknvFnNMGNVkyAk2VcVzeKMc2Rd0uWCaeZBOHSGAIMnH3zzQ8MybwSSSy5HSerwEVrspMfB3VdxplOAROF8Ral60vizX1HRNLhYcHyRRjw8cKLc(SabqDWTSUcjVHh(dwyJdjeej6XpPuENNkVjngIguu(9gj94irtJ3mYMMnH3DDfP9Vyk)Wm4rBIMM0ITiLk)EJKESb)EpVMqecR1TYHDkGI2H6R50e88vbttX(v4nrBS0u70xZPj45RcML1iEdnKLXdtSGAHAal3KLRWhiXIxSObb1zHjw8cKf1vel3ZYYIfB3VZIZcczPWEZIvddS4filBf0T(daXcqBEhZB4H)Gf24qcbrI(5QJMHZmPwfPXBgjfuNfMmxL9kQ2HUvoStbustTRxfnHnsYy1xmSbpxL9o41fYwlf27rAhQVMtJvFXWg8Cv27GxxiBTuyVnaC1IqK9AAS0u91CAcE(QGPPy)k8MrWiTdbHVXbDR)aqzSnVJZGESJKm)fq5kKPP2fGaOYR3uuOHkydMMITiLk)EJKE8M2ps7q91CAAhavWfopBQgyuttX(vyena0SHi8G6vrtyJKm4RMlvEpk(P(8rA1xZPPDaubx48SPAGrnlR0u70xZPPDaubx48SPAGrnlRrAhAxacvGqBLj45RcMLvAQ(Aon)EFkvgtekuBWVhqbrOPjTZd5(NBk2VcJi7hBmTZd5(NBk2VcVjAJnwAQDy4sPFfO537tPYyIqHAdvUUIahPDigUu6xbA(9(uQmMiuO2qLRRiW00aeQaH2ktWZxfmnf7xH3mIJns77ns6n)ft5hMbpAtnLMQdXyTZd5(NBk2VcJi0gJ3qdzz8WelolaFVNUsXIMFr)olwnmWYQuegZcW37PRuSCywCvtoyuwwwSaBwIcxS4nXIRdxplpKfiaQdUflBfJq4n8WFWcBCiHGirp(9E6kLgVzK6R50al63XzlQdK1FWYSS0ouFnNg8790vkttZMW7UUIstD83UkBbTr9MdGXgXBOHSO5wXwSSvmcHfDAcBIfublaquiwSD)olaFVNUsXIxGS87uXcW3B8Qrs8gE4pyHnoKqqKOh)EpDLsJ3mYaeavE9M6qU)5PtAT7DfvVb)Ks5DgSV5BOY1veO2Ha8(CDfzcWcaefkds4OvinnaHkqOTYe88vbZYknvFnNMGNVkywwJ0gGqfi0wzcWcaefk)7ugBD99yttX(vyeHmaAIDepOaDQHo(BxLTG2OgDbW7Z1vKbpZbi(hPvFnNg8790vkttX(vyeHWATdSxhOPG5aiM3Wd)blSXHecIe943B8QrsA8MrgGaOYR3uhY9ppDs7qaEFUUImbybaIcLbjC0kKMgGqfi0wzcE(QGzzLMQVMttWZxfmlRrAdqOceARmbybaIcL)DkJTU(ESPPy)kmI0KwaEFUUIm437PRuzBW6ZtxPYW5ulfuNfMmxL9kQw7a4956kYCilytz87nE1ijT2b2Rd0uWCaeZBOHSmEyIfGV34vJKyX297S4flA(f97Sy1WalWMLBYsu4ABqwGaOo4wSSvmcHfB3VZsu4QzPie)SeC8ByzRkmKfWvSflBfJqyXFw(DIfQazboz53jwgGs1VhTzrFnNSCtwa(EpDLIfBWLcS2(zz6kflW5KfyZsu4IfVjwGfl2ZY7ns6X8gE4pyHnoKqqKOh)EJxnssJ3ms91CAGf974CqrENbC4dwMLvA6q7WV3ZRjJBLd7uafT2bW7Z1vK5qwWMY43B8QrsPPd1xZPj45RcMMI9RWistA1xZPj45RcMLvA6WH6R50e88vbttX(vyeHmaAIDepOaDQHo(BxLTG2OgDbW7Z1vKbJZbi(hPvFnNMGNVkywwPP6R500oaQGlCE2unWOz8vZLkVhf)uFUPPy)kmIqganXoIhuGo1qh)TRYwqBuJUa4956kYGX5ae)J0QVMtt7aOcUW5zt1aJMXxnxQ8Eu8t95ML1iTbiaQ86naO63J2JgPDi2IuQ87ns6Xg8790vkefX0uaEFUUIm437PRuzBW6ZtxPYW5C0iT2bW7Z1vK5qwWMY43B8QrsAhAxVkAcBKK5VyYgSRmytES(vGuNMITiLk)EJKESb)EpDLcrrCeVHgYY4Hjw08GWcZYvSaeQ8MfniOolmXIxGSGDaelO2LsXIMhewSmHnlOAROF8RaVHh(dwyJdjeej6lYwogclnEZihQVMtdfuNfMYyOYBttX(v4njetH1t5)IP00HHDVrs4iTxBtHDVrs5)IjePPrPPHDVrs4iJ4iTUvoStbu4n8WFWcBCiHGir)URM5yiS04nJCO(AonuqDwykJHkVnnf7xH3KqmfwpL)lMsthg29gjHJ0ETnf29gjL)lMqKMgLMg29gjHJmIJ06w5Wofqr7q91CAAhavWfopBQgyuttX(vyePjT6R500oaQGlCE2unWOMLLw76vrtyJKm4RMlvEpk(P(80u70xZPPDaubx48SPAGrnlRr8gE4pyHnoKqqKOFUuQCmewA8MrouFnNgkOolmLXqL3MMI9RWBsiMcRNY)ftAhgGqfi0wzcE(QGPPy)k8MAAS00aeQaH2ktawaGOq5FNYyRRVhBAk2VcVPMgBuA6WWU3ijCK2RTPWU3iP8FXeI00O00WU3ijCKrCKw3kh2PakAhQVMtt7aOcUW5zt1aJAAk2VcJinPvFnNM2bqfCHZZMQbg1SS0AxVkAcBKKbF1CPY7rXp1NNMAN(AonTdGk4cNNnvdmQzznI3qdzz8WelOgqnGfyXcQ0C8gE4pyHnoKqqKO3M39b7mCMj1QiEdnKfu5QWs5pHzX2o97uZYdzzHjwa(EpVMy5kwacvEZIT9lSZYHzXFw0elV3iPhJa0yzcBwiauhLf7hdDXsSJFQJYcSzbHzb47nE1ijw0GylOnQJP6zb)EafmVHh(dwyJdjeej6b4956ksJLhtrIFVNxt5RYyOYBncWvlksSfPu53BK0Jn437510MimcMkiShg74N6OzaUArdcTXgdDz)yJqWubH9q91CAWV34vJKYuSf0g1Xu9zmu5Tb)Eaf0fcpI3qdzbvUkSu(tywSTt)o1S8qwqnA)3zbC1xHKfuBt1aJYB4H)Gf24qcbrIEaEFUUI0y5XuK2A)3ZxLNnvdmQgb4QffjAOlSfPu5Dh)eISxZgoMX(bneBrkv(9gj9yd(9EEnPzOnAqdrdbVRO6ny4sLHZ8Vt5jSj8BOY1ve4GqZOPrJqWyg000G0xZPPDaubx48SPAGrnnf7xH5n0qwgpmXcQr7)olxXcqOYBw0GG6SWelWMLBYsbzb4798AIfBNsXY8EwU6HSGQTI(XVcS4v0yyt8gE4pyHnoKqqKO3w7)UgVzKdPG6SWKrTkVZfH4pnLcQZctgVIMlcXVwaEFUUImhohuKdGgPD47ns6n)ft5hMbpAteonLcQZctg1Q8oFv2(0uDigRDEi3)CtX(vyeH2yJst1xZPHcQZctzmu5TPPy)kmI8WFWYGFVNxtgcXuy9u(VysR(AonuqDwykJHkVnlR0ukOolmzUkJHkV1AhaVpxxrg8798AkFvgdvENMQVMttWZxfmnf7xHrKh(dwg8798AYqiMcRNY)ftATdG3NRRiZHZbf5aiT6R50e88vbttX(vyeriMcRNY)ftA1xZPj45RcMLvAQ(AonTdGk4cNNnvdmQzzPfG3NRRiJT2)98v5zt1aJMMAhaVpxxrMdNdkYbqA1xZPj45RcMMI9RWBsiMcRNY)ft8gAilJhMyb4798AILBYYvSGoRYBw0GG6SWKgz5kwacvEZIgeuNfMybwSGWiGL3BK0Jzb2S8qwSAyGfGqL3SObb1zHjEdp8hSWghsiis0JFVNxt8gAilOwxP(9EXB4H)Gf24qcbrI(Evzp8hSYQd)AS8ykYPRu)EV4n4n0qwa(EJxnsILjSzjgcGIP6zzvkcJzzHVcjlJdU1bZB4H)Gf2mDL637vK43B8QrsA8MrAxVkAcBKKr3vEfOmCMDLk)7xHeBOiCDwweiVHgYcQC8ZYVtSacFwSD)ol)oXsme)S8xmXYdzXbbzzv)Py53jwIDeZc4Q9)GflhML97nSaCvZRjwAk2VcZs8s9NL6iqwEilX(h2zjgcR51elGR2)dw8gE4pyHntxP(9EHGirpEvZRjngIguu(9gj94irtJ3msq4BIHWAEnzAk2VcVztX(v4bzV9Ol0IaEdp8hSWMPRu)EVqqKOpgcR51eVbVHgYY4Hjw2kOB9haIfG28oMfB7uXYVtnXYHzPGS4H)aqSGT5DSgzXXSO8NyXXSybX4txrSalwW28oMfB3VZI9SaBwMKnQzb)EafmlWMfyXIZseralyBEhZcgYYV7pl)oXsr2ybBZ7yw8UpaeMfuZx4NfF(uZYV7plyBEhZcHyRRjmVHh(dwyd(J0bDR)aqzSnVJ1yiAqr53BK0JJennEZiTde(gh0T(daLX28ood6XosY8xaLRqQ1op8hSmoOB9hakJT5DCg0JDKK5Q8uDi3FTdTde(gh0T(daLX28ooVtUY8xaLRqMMccFJd6w)bGYyBEhN3jxzAk2VcVPMgLMccFJd6w)bGYyBEhNb9yhjzWVhqbrruli8noOB9hakJT5DCg0JDKKPPy)kmIIOwq4BCq36paugBZ74mOh7ijZFbuUcjVHgYY4HjmlOcwaGOqSCtwq1wr)4xbwomlllwGnlrHlw8MybKWrRWvizbvBf9JFfyX297SGkybaIcXIxGSefUyXBIfDsbTXccpg6J4ydrfPi8FUIfGwxFpEelBfJqy5kwCwqBmeWcMcSObb1zHjdlBvHHSacRTFwu0ZIMRjpw)kqQzHqS11KgzXv28OywwyILRybvBf9JFfyX297SGqwkS3S4fil(ZYVtSGFVFwGtwCwghCRdMfBxbcTz4n8WFWcBWpcIe9bybaIcL)DkJTU(ESgVzK2b2Rd0uWCaeRD4qaEFUUImbybaIcLbjC0kO1UaeQaH2ktWZxfmn5Gr1AxVkAcBKKXQVyydEUk7DWRlKTwkS3PP6R50e88vbZYs7q76vrtyJKmw9fdBWZvzVdEDHS1sH9onTxfnHnsYeifH)ZvzS113JttNhY9p3uSFfEt0ShHMMQdXyTZd5(NBk2VcJOaeQaH2ktWZxfmnf7xHraAJLMQVMttWZxfmnf7xH3en7hns7WHo(BxLTG2OgrrcW7Z1vKjalaquOSJT0ouFnNgkOolmLvRYBttX(v4nrBS0u91CAOG6SWugdvEBAk2VcVjAJnknvFnNMGNVkyAk2VcVPM0QVMttWZxfmnf7xHruKOz)iTdTRxfnHnsY8xmzd2vgSjpw)kqQttTRxfnHnsYeifH)ZvzS113Jtt1xZP5VyYgSRmytES(vGuBAk2VcVjHykSEk)xmnknTxfnHnsYO7kVcugoZUsL)9RqIhPDOD9QOjSrsgDx5vGYWz2vQ8VFfsCA6q91CA0DLxbkdNzxPY)(viX5Y)vtg87buImcst1xZPr3vEfOmCMDLk)7xHeN9o4fzWVhqjYiy0O0uDigRDEi3)CtX(vyeH2yATlaHkqOTYe88vbttoy0r8gAilJhMyb47nE1ijwEilOqKflllw(DIfnxtES(vGuZI(Aoz5MSCpl2GlfileITUMyrNMWMyzE1H3Vcjl)oXsri(zj44NfyZYdzbCfBXIonHnXcQGfaikeVHh(dwyd(rqKOh)EJxnssJ3mYEv0e2ijZFXKnyxzWM8y9RaPw7q7gouFnNM)IjBWUYGn5X6xbsTPPy)k8ME4pyzS1(VBietH1t5)IjemMbnTdPG6SWK5QSo83ttPG6SWK5QmgQ8onLcQZctg1Q8oxeI)rPP6R508xmzd2vgSjpw)kqQnnf7xH30d)bld(9EEnzietH1t5)IjemMbnTdPG6SWK5QSAvENMsb1zHjdgQ8oxeI)0ukOolmz8kAUie)JgLMAN(Aon)ft2GDLbBYJ1VcKAZYAuA6q91CAcE(QGzzLMcW7Z1vKjalaquOmiHJwHrAdqOceARmbybaIcL)DkJTU(ESPjhmQ2aeavE9M6qU)5PtAhQVMtdfuNfMYQv5TPPy)k8MOnwAQ(AonuqDwykJHkVnnf7xH3eTXgns7q7cqau51BqjAFELMgGqfi0wzOylOnQZ6Wc00uSFfEZiyeVHgYIMBfBXcW3B8QrsywSD)olJZvEfiwGtw2QsXYG3VcjMfyZYdzXQjlVjwMWMfublaquiwSD)olJdU1bZB4H)Gf2GFeej6XV34vJK04nJSxfnHnsYO7kVcugoZUsL)9RqI1oCO(Aon6UYRaLHZSRu5F)kK4C5)Qjd(9akBAFAQ(Aon6UYRaLHZSRu5F)kK4S3bVid(9akBA)iTbiubcTvMGNVkyAk2VcVjcvRDbiubcTvMaSaarHY)oLXwxFp2SSsthgGaOYR3uhY9ppDsBacvGqBLjalaquO8VtzS113Jnnf7xHreAJPLcQZctMRYEfvRJ)2vzlOnQ30(XqqehBqbiubcTvMGNVkyAYbJoAeVHgYcQGf49hSyzcBwCLIfq4Jz539NLyhfcZcE1el)ofLfVPA7NLMMnH3jqwSTtflOMCaubxywqTnvdmkl7oMffHXS87EXIMybtbmlnf7xDfswGnl)oXIgeBbTrnlJdwGSOVMtwomlUoC9S8qwMUsXcCozb2S4vuw0GG6SWelhMfxhUEwEileITUM4n8WFWcBWpcIe9a8(CDfPXYJPibHFUPiCDnft1J1iaxTOihQVMtt7aOcUW5zt1aJAAk2VcVPMstTtFnNM2bqfCHZZMQbg1SSgP1o91CAAhavWfopBQgy0m(Q5sL3JIFQp3SS0ouFnNguUcSjWmfBbTrDmvFMkQrEdKmnf7xHreYaOj2r8iTd1xZPHcQZctzmu5TPPy)k8MidGMyhXPP6R50qb1zHPSAvEBAk2VcVjYaOj2rCA6q70xZPHcQZctz1Q82SSstTtFnNgkOolmLXqL3ML1iT29UIQ3GHk8FbYqLRRiWr8gAilOcwG3FWILF3Fwc7uafml3KLOWflEtSaxp(ajwOG6SWelpKfyPIYci8z53PMyb2SCilytS87hMfB3VZcqOc)xG4n8WFWcBWpcIe9a8(CDfPXYJPibHFgUE8bszkOolmPraUArro0o91CAOG6SWugdvEBwwATtFnNgkOolmLvRYBZYAKw7Exr1BWqf(VazOY1veOw76vrtyJKm)ft2GDLbBYJ1VcKAEdnKfnh8zXvkwEVrspMfB3VFflieVaP4lWIT73HRNfiaQdUL1virWVtS46qaelbybE)blmVHh(dwyd(rqKOpgcR51Kgdrdkk)EJKECKOPXBg5q91CAOG6SWugdvEBAk2VcVztX(v40u91CAOG6SWuwTkVnnf7xH3SPy)kCAkaVpxxrgq4NHRhFGuMcQZctJ020Sj8URRiTV3iP38xmLFyg8OnrZETUvoStbu0cW7Z1vKbe(5MIW11umvpM3Wd)blSb)iis0Jx18AsJHObfLFVrspos004nJCO(AonuqDwykJHkVnnf7xH3SPy)kCAQ(AonuqDwykRwL3MMI9RWB2uSFfonfG3NRRidi8ZW1Jpqktb1zHPrABA2eE31vK23BK0B(lMYpmdE0MOzVw3kh2PakAb4956kYac)Ctr46AkMQhZB4H)Gf2GFeej6XpPuENNkVjngIguu(9gj94irtJ3mYH6R50qb1zHPmgQ820uSFfEZMI9RWPP6R50qb1zHPSAvEBAk2VcVztX(v40uaEFUUImGWpdxp(aPmfuNfMgPTPzt4DxxrAFVrsV5Vyk)Wm4rBIg6wRBLd7uafTa8(CDfzaHFUPiCDnft1J5n0qw0CWNL(qU)SOttytSGABQgyuwUjl3ZIn4sbYIRuqBSefUy5HS00Sj8olkcJzbC1xHKfuBt1aJYYWF)WSalvuw2DllQWSy7(D46zb4vZLIfuZIIFQpFeVHh(dwyd(rqKOhG3NRRinwEmfzbZ7rXp1NNjVvrZGWxJaC1IImabqLxVbav)E0wRD9QOjSrsg8vZLkVhf)uFUw76vrtyJKmHRdkkdNz1nPSxGzqY)DTbiubcTvgDQXuJYvinn5Gr1gGqfi0wzAhavWfopBQgyuttoyuT2PVMttWZxfmllTdD83UkBbTr9MracnnvFnNgDfecQw43SSgXB4H)Gf2GFeej6JHWAEnPXBgjaVpxxrMcM3JIFQpptERIMbHV2MI9RWiY(X4n8WFWcBWpcIe94vnVM04nJeG3NRRitbZ7rXp1NNjVvrZGWxBtX(vyeH2aG3qdzz8WelOw4wybwSeazX297W1ZsWTSUcjVHh(dwyd(rqKOFc7aLHZC5)QjnEZiDRCyNcOWBOHSmEyIfni2cAJAwghSazX297S4vuwuWcjlubxi3zr54)kKSObb1zHjw8cKLVJYYdzrDfXY9SSSyX297SGqwkS3S4filOAROF8RaVHh(dwyd(rqKONITG2OoRdlqnEZihgGqfi0wzcE(QGPPy)kmc0xZPj45RcgWv7)ble0RIMWgjzS6lg2GNRYEh86czRLc79GqZ(ndqOceARmuSf0g1zDybAaxT)hSqaAJnknvFnNMGNVkyAk2VcVzeKMc2Rd0uWCaeZBOHSaKEml22PILTIriSG3Hlfil6elGRylcKLhYsbFwGaOo4wSmuZrwubIzbwSGAxDuwGtw0a1Qiw8cKLFNyrdcQZctJ4n8WFWcBWpcIe9a8(CDfPXYJPiDSvgCfBPraUArr64VDv2cAJ6nhaJPzdT3OPbPVMtZC1rZWzMuRIm43dOOz2pikOolmzUkRwL3J4n0qwgpmXcQ2k6h)kWIT73zbvWcaefc9dWUcSjqwaAD99yw8cKfqyT9Zcea1267jwqilf2BwGnl22PILXPGqq1c)SydUuGSqi26AIfDAcBIfuTv0p(vGfcXwxtydlAEokel4vtS8qwO6PMfNf0zvEZIgeuNfMyX2ovSSWhYILbBFeWI9wbw8cKfxPybvAoml2oLIfDkaJjwAYbJYcgclwOcUqUZc4QVcjl)oXI(AozXlqwaHpMLDhaXIorfl41CEHJQxfLLMMnH3jqdVHh(dwyd(rqKOhG3NRRinwEmfzamhGf49hSY4xJaC1II0oWEDGMcMdGyTdb4956kYeaZbybE)blT2PVMttWZxfmllTdTdtFwhwlS5pQTpcY2BfstPG6SWK5QSAvENMsb1zHjdgQ8oxeI)rAhoCiaVpxxrghBLbxXwPPbiaQ86n1HC)ZtNsthgGaOYR3Gs0(8sBacvGqBLHITG2OoRdlqttoy0rPP9QOjSrsM)IjBWUYGn5X6xbs9iTGW3Gx18AY0uSFfEZiqli8nXqynVMmnf7xH3CaODii8n4NukVZtL3KPPy)k8MOnwAQDVRO6n4NukVZtL3KHkxxrGJ0cW7Z1vK537tPYyIqH6Sn)ETV3iP38xmLFyg8On1xZPj45RcgWv7)bRbnMbHMMQVMtJUccbvl8BwwA1xZPrxbHGQf(nnf7xHrK(AonbpFvWaUA)pyHGHOz)G6vrtyJKmw9fdBWZvzVdEDHS1sH9E0O00HueUollc0qXwrBYvzydwEfiTbiubcTvgk2kAtUkdBWYRazAk2VcJi0q3iuemutdQxfnHnsYGVAUu59O4N6ZhnAK2HdTlabqLxVPoK7FE6uA6qaEFUUImbybaIcLbjC0kKMgGqfi0wzcWcaefk)7ugBD99yttX(vyeHMMgPDOD9QOjSrsgDx5vGYWz2vQ8VFfsCAQJ)2vzlOnQrKMgtBacvGqBLjalaquO8VtzS113Jnn5GrhnknDEi3)CtX(vyefGqfi0wzcWcaefk)7ugBD99yttX(v4rPP6qmw78qU)5MI9RWisFnNMGNVkyaxT)hSqaA2pOEv0e2ijJvFXWg8Cv27GxxiBTuyVhXBOHSmEyIfuBt1aJYIT73zbvBf9JFfyzvkcJzb12unWOSydUuGSOC8ZIcwiPMLF3lwq1wr)4xbnYYVtfllmXIonHnXB4H)Gf2GFeej6BhavWfopBQgyunEZi1xZPj45RcMMI9RWBIMMst1xZPj45RcgWv7)blezpcfb9QOjSrsgR(IHn45QS3bVUq2APWEpi0SxlaVpxxrMayoalW7pyLXpVHh(dwyd(rqKOpqkc)NRYU6qwXu9A8MrcW7Z1vKjaMdWc8(dwz8RDO(AonbpFvWaUA)pyTzK2JqrqVkAcBKKXQVyydEUk7DWRlKTwkS3dcn7ttTlabqLxVbav)E0EuAQ(AonTdGk4cNNnvdmQzzPvFnNM2bqfCHZZMQbg10uSFfgrdaeeGf46EJvtHdtzxDiRyQEZFXugGRwecgAN(Aon6kieuTWVzzP1U3vu9g87Tc2GgQCDfboI3Wd)blSb)iis0FvW7Y)dwA8MrcW7Z1vKjaMdWc8(dwz8ZBOHSma17Z1vellmbYcSyX1p19hHz539NfBE9S8qw0jwWoacKLjSzbvBf9JFfybdz539NLFNIYI3u9SyZXpbYcQ5l8ZIonHnXYVtX8gE4pyHn4hbrIEaEFUUI0y5XuKyhaLNWoh88vbncWvlkYaeQaH2ktWZxfmnf7xH3eTXstTdG3NRRitawaGOqzqchTcAdqau51BQd5(NNoLMc2Rd0uWCaeZBOHSmEycZcQfQbSCtwUIfVyrdcQZctS4filFFeMLhYI6kIL7zzzXIT73zbHSuyV1ilOAROF8RGgzrdITG2OMLXblqw8cKLTc6w)bGybOnVJ5n8WFWcBWpcIe9ZvhndNzsTksJ3mskOolmzUk7vuTdD83UkBbTrnIga2Rz6R50mxD0mCMj1Qid(9akdstPP6R500oaQGlCE2unWOML1iTd1xZPXQVyydEUk7DWRlKTwkS3gaUAriYEeES0u91CAcE(QGPPy)k8MrWiTa8(CDfzWoakpHDo45RcAhAxacGkVEtrHgQGnyAki8noOB9hakJT5DCg0JDKK5VakxHCK2H2fGaOYR3aGQFpANMQVMtt7aOcUW5zt1aJAAk2VcJObGMneHhuVkAcBKKbF1CPY7rXp1NpsR(AonTdGk4cNNnvdmQzzLMAN(AonTdGk4cNNnvdmQzzns7q7cqau51BqjAFELMgGqfi0wzOylOnQZ6Wc00uSFfEt7hBK23BK0B(lMYpmdE0MAknvhIXANhY9p3uSFfgrOngVHgYY4Hjw08l63zb4790vkwSAyaZYnzb4790vkwoCT9ZYYI3Wd)blSb)iis0JFVNUsPXBgP(AonWI(DC2I6az9hSmllT6R50GFVNUszAA2eE31veVHgYcQ8kqkwa(ERGnil3KL7zz3XSOimMLF3lw0eMLMI9RUcPgzjkCXI3el(ZYaymeWYwXiew8cKLFNyjS6MQNfniOolmXYUJzrtiaZstX(vxHK3Wd)blSb)iis0h8kqQS(Ao1y5XuK43BfSb14nJuFnNg87Tc2GMMI9RWistAhQVMtdfuNfMYyOYBttX(v4n1uAQ(AonuqDwykRwL3MMI9RWBQPrAD83UkBbTr9MdGX4n0qwqLxbsXYVtSGqwkS3SOVMtwUjl)oXIvddSydUuG12plQRiwwwSy7(Dw(DILIq8ZYFXelOcwaGOqSeGXeMf4CYsa0WYG3pmll8YvQOSalvuw2DllQWSaU6RqYYVtSmo0XWB4H)Gf2GFeej6dEfivwFnNAS8yksR(IHn45QS3bVUq2APWERXBg57kQEZvbVl)pyzOY1veOw7Exr1BkYwogcldvUUIa1oa3WHrCSX0mh)TRYwqBuJaeEmndtFwhwlS5pQTpcY2Bfgecp2i01qegDHTiLkV74NgPzbiubcTvMaSaarHY)oLXwxFp20uSFfEeIgGB4Wio2yAMJ)2vzlOnQ1m91CAS6lg2GNRYEh86czRLc7TbGRwecq4X0mm9zDyTWM)O2(iiBVvyqi8yJqxdry0f2IuQ8UJFAKMfGqfi0wzcWcaefk)7ugBD99yttX(v4rAdqOceARmbpFvW0uSFfEZioMw91CAS6lg2GNRYEh86czRLc7TbGRweIShTX0QVMtJvFXWg8Cv27GxxiBTuyVnaC1I2mIJPnaHkqOTYeGfaiku(3Pm2667XMMI9RWicHht78qU)5MI9RWBgGqfi0wzcWcaefk)7ugBD99yttX(vyeGU1oSxfnHnsYeifH)ZvzS113Jttb4956kYeGfaikugKWrRWiEdnKfG0JzX2ovSGqwkS3SG3Hlfil6elwnmeiqwiVvrz5HSOtS46kILhYYctSGkybaIcXcSyjaHkqOTILHAagt1FUsfLfDkaJjmlFViwUjlGRyRRqYYwXiewkOnwSDkflUsbTXsu4ILhYIf1tk8QOSq1tnliKLc7nlEbYYVtfllmXcQGfaik0iEdp8hSWg8JGirpaVpxxrAS8yksRggYwlf27m5TkQgb4QffzacGkVEtDi3)80jT9QOjSrsgR(IHn45QS3bVUq2APWERvFnNgR(IHn45QS3bVUq2APWEBa4QfHah)TRYwqBuJGiUzKrCSX0cW7Z1vKjalaquOmiHJwbTbiubcTvMaSaarHY)oLXwxFp20uSFfgro(BxLTG2OgDfXXgeYaOj2rSw7a71bAkyoaI1sb1zHjZvzVIQ1XF7QSf0g1BcW7Z1vKjalaquOSJT0gGqfi0wzcE(QGPPy)k8MAI3qdzz8WelaFVNUsXIT73zb4tkL3SO56B(SaBwE7JawqyRalEbYsbzb47Tc2GAKfB7uXsbzb4790vkwomlllwGnlpKfRggybHSuyVzX2ovS46qaeldGXyzRyeYqyZYVtSqERIYcczPWEZIvddSaW7Z1velhMLVx0iwGnloOL)haIfSnVJzz3XSebiatbmlnf7xDfswGnlhMLRyzQoK7pVHh(dwyd(rqKOh)EpDLsJ3mYHVRO6n4NukVZG9nFdvUUIattX0N1H1cB(JA7JGmcBfgP1U3vu9g87Tc2GgQCDfbQvFnNg8790vkttZMW7UUI0AxVkAcBKK5VyYgSRmytES(vGuRDO(Aonw9fdBWZvzVdEDHS1sH92aWvlAZiTxtJP1o91CAcE(QGzzPDiaVpxxrghBLbxXwPP6R50GYvGnbMPylOnQJP6ZurnYBGKzzLMcW7Z1vKXQHHS1sH9otERIoknDyacGkVEtrHgQGnO23vu9g8tkL3zW(MVHkxxrGAhccFJd6w)bGYyBEhNb9yhjzAk2VcVzeKM6H)GLXbDR)aqzSnVJZGESJKmxLNQd5(pA0iTddqOceARmbpFvW0uSFfEt0glnnaHkqOTYeGfaiku(3Pm2667XMMI9RWBI2yJ4n0qw0CRylmlBfJqyrNMWMybvWcaefILf(kKS87elOcwaGOqSeGf49hSy5HSe2PakSCtwqfSaarHy5WS4HF5kvuwCD46z5HSOtSeC8ZB4H)Gf2GFeej6XV34vJK04nJeG3NRRiJvddzRLc7DM8wfL3qdzz8WelAEqyHzX2ovSefUyXBIfxhUEwEi69Myj4wwxHKLWU3ijmlEbYsSJcXcE1el)ofLfVjwUIfVyrdcQZctSG)tPyzcBwqntZd9OwnpEdp8hSWg8JGirFr2YXqyPXBgPBLd7uafTdd7EJKWrAV2Mc7EJKY)ftistPPHDVrs4iJ4iEdp8hSWg8JGir)URM5yiS04nJ0TYHDkGI2HHDVrs4iTxBtHDVrs5)IjePP00WU3ijCKrCK2H6R50qb1zHPSAvEBAk2VcVjHykSEk)xmLMQVMtdfuNfMYyOYBttX(v4njetH1t5)IPr8gE4pyHn4hbrI(5sPYXqyPXBgPBLd7uafTdd7EJKWrAV2Mc7EJKY)ftistPPHDVrs4iJ4iTd1xZPHcQZctz1Q820uSFfEtcXuy9u(VyknvFnNgkOolmLXqL3MMI9RWBsiMcRNY)ftJ4n0qwgpmXcW3B8QrsSO5x0VZIvddyw8cKfWvSflBfJqyX2ovSGQTI(XVcAKfni2cAJAwghSa1il)oXYauQ(9Onl6R5KLdZIRdxplpKLPRuSaNtwGnlrHRTbzj4wSSvmcH3Wd)blSb)iis0JFVXRgjPXBgjfuNfMmxL9kQ2H6R50al63X5GI8od4WhSmlR0u91CAq5kWMaZuSf0g1Xu9zQOg5nqYSSst1xZPj45RcMLL2H2fGaOYR3Gs0(8knnaHkqOTYqXwqBuN1HfOPPy)k8MAknvFnNMGNVkyAk2VcJiKbqtSJ4bnvqyp0XF7QSf0g1OlaEFUUImyCoaX)OrAhAxacGkVEdaQ(9ODAQ(AonTdGk4cNNnvdmQPPy)kmIqganXoIhuGo1WHo(BxLTG2Ogbi8yd6DfvVzU6Oz4mtQvrgQCDfbocDbW7Z1vKbJZbi(hHGioO3vu9MISLJHWYqLRRiqT21RIMWgjzWxnxQ8Eu8t95A1xZPPDaubx48SPAGrnlR0u91CAAhavWfopBQgy0m(Q5sL3JIFQp3SSsthQVMtt7aOcUW5zt1aJAAk2VcJip8hSm43751KHqmfwpL)lM0ITiLkV74Nq0ygeonvFnNM2bqfCHZZMQbg10uSFfgrE4pyzS1(VBietH1t5)IP0uaEFUUImxecMdWc8(dwAdqOceARmxHd96DDfLJWLx)kodsaUazAYbJQLIW1zzrGMRWHE9UUIYr4YRFfNbjaxGgPvFnNM2bqfCHZZMQbg1SSstTtFnNM2bqfCHZZMQbg1SS0AxacvGqBLPDaubx48SPAGrnn5GrhLMcW7Z1vKXXwzWvSvAQoeJ1opK7FUPy)kmIqganXoIhuGo1qh)TRYwqBuJUa4956kYGX5ae)JgXBOHSm4oklpKLyhfILFNyrNWplWjlaFVvWgKf9OSGFpGYviz5EwwwSeHRlGIkklxXIxrzrdcQZctSOVEwqilf2BwoCT9ZIRdxplpKfDIfRggceiVHh(dwyd(rqKOh)EJxnssJ3mY3vu9g87Tc2GgQCDfbQ1UEv0e2ijZFXKnyxzWM8y9RaPw7q91CAWV3kydAwwPPo(BxLTG2OEZbWyJ0QVMtd(9wbBqd(9akikIAhQVMtdfuNfMYyOYBZYknvFnNgkOolmLvRYBZYAKw91CAS6lg2GNRYEh86czRLc7TbGRweIShHoM2HbiubcTvMGNVkyAk2VcVjAJLMAhaVpxxrMaSaarHYGeoAf0gGaOYR3uhY9ppDAeVHgYIgG)l2FcZYo0glXRWolBfJqyXBIfK(veilwuZcMcWc0WIMFPIYY7OqywCwWLBH3HpltyZYVtSewDt1Zc((L)hSybdzXgCPaRTFw0jw8qy1(tSmHnlkVrsnl)ftZ2JjmVHh(dwyd(rqKOhG3NRRinwEmfPJTqiudKcAeGRwuKuqDwyYCvwTkVhueGU8WFWYGFVNxtgcXuy9u(Vycb2rb1zHjZvz1Q8Eqdr3i4DfvVbdxQmCM)DkpHnHFdvUUIahuehHU8WFWYyR9F3qiMcRNY)ftiymdcRj0f2IuQ8UJFcbJz00GExr1Bk)xnHZ6UYRazOY1veiVHgYIMBfBXcW3B8QrsSCflEXIgeuNfMyXXSGHWIfhZIfeJpDfXIJzrblKS4ywIcxSy7ukwOcKLLfl2UFNLiymeWITDQyHQN6RqYYVtSueIFw0GG6SWKgzbewB)SOONL7zXQHbwqilf2BnYciS2(zbcGAB99elEXIMFr)olwnmWIxGSybHkw0PjSjwq1wr)4xbw8cKfni2cAJAwghSa5n8WFWcBWpcIe943B8QrsA8MrAxVkAcBKK5VyYgSRmytES(vGuRDO(Aonw9fdBWZvzVdEDHS1sH92aWvlcr2JqhlnvFnNgR(IHn45QS3bVUq2APWEBa4QfHi710yAFxr1BWpPuENb7B(gQCDfbos7qkOolmzUkJHkV164VDv2cAJAeaW7Z1vKXXwieQbsHbPVMtdfuNfMYyOYBttX(vyeacFZC1rZWzMuRIm)fqbNBk2VAq2B00MrWyPPuqDwyYCvwTkV164VDv2cAJAeaW7Z1vKXXwieQbsHbPVMtdfuNfMYQv5TPPy)kmcaHVzU6Oz4mtQvrM)cOGZnf7xni7nAAZbWyJ0AN(AonWI(DC2I6az9hSmllT29UIQ3GFVvWg0qLRRiqTddqOceARmbpFvW0uSFfEteAAkgUu6xbA(9(uQmMiuO2qLRRiqT6R50879PuzmrOqTb)EafefXiQzd7vrtyJKm4RMlvEpk(P(8bz)iTZd5(NBk2VcVjAJnM25HC)Znf7xHrK9JnwAkyVoqtbZbq8iTdTlabqLxVbLO95vAAacvGqBLHITG2OoRdlqttX(v4nTFeVHgYY4Hjw08GWcZYvS4vuw0GG6SWelEbYc2bqSGAMRMia1Uukw08GWILjSzbvBf9JFfyXlqwgGDfytGSObXwqBuht1ByzRkmKLfMyzlAES4filOwnpw8NLFNyHkqwGtwqTnvdmklEbYciS2(zrrplAUM8y9RaPMLPRuSaNtEdp8hSWg8JGirFr2YXqyPXBgPBLd7uafTa8(CDfzWoakpHDo45RcAhQVMtdfuNfMYQv5TPPy)k8MeIPW6P8FXuAQ(AonuqDwykJHkVnnf7xH3KqmfwpL)lMgXB4H)Gf2GFeej63D1mhdHLgVzKUvoStbu0cW7Z1vKb7aO8e25GNVkODO(AonuqDwykRwL3MMI9RWBsiMcRNY)ftPP6R50qb1zHPmgQ820uSFfEtcXuy9u(VyAK2H6R50e88vbZYknvFnNgR(IHn45QS3bVUq2APWEBa4QfHOiThTXgPDODbiaQ86naO63J2PP6R500oaQGlCE2unWOMMI9RWiAOM0m7huVkAcBKKbF1CPY7rXp1NpsR(AonTdGk4cNNnvdmQzzLMAN(AonTdGk4cNNnvdmQzzns7q76vrtyJKm)ft2GDLbBYJ1VcK60ucXuy9u(Vycr6R508xmzd2vgSjpw)kqQnnf7xHttTtFnNM)IjBWUYGn5X6xbsTzznI3Wd)blSb)iis0pxkvogclnEZiDRCyNcOOfG3NRRid2bq5jSZbpFvq7q91CAOG6SWuwTkVnnf7xH3KqmfwpL)lMst1xZPHcQZctzmu5TPPy)k8MeIPW6P8FX0iTd1xZPj45RcMLvAQ(Aonw9fdBWZvzVdEDHS1sH92aWvlcrrApAJns7q7cqau51BqjAFELMQVMtdkxb2eyMITG2OoMQptf1iVbsML1iTdTlabqLxVbav)E0onvFnNM2bqfCHZZMQbg10uSFfgrAsR(AonTdGk4cNNnvdmQzzP1UEv0e2ijd(Q5sL3JIFQppn1o91CAAhavWfopBQgyuZYAK2H21RIMWgjz(lMSb7kd2KhRFfi1PPeIPW6P8FXeI0xZP5VyYgSRmytES(vGuBAk2VcNMAN(Aon)ft2GDLbBYJ1VcKAZYAeVHgYY4HjwqnGAalWILaiVHh(dwyd(rqKO3M39b7mCMj1QiEdnKLXdtSa89EEnXYdzXQHbwacvEZIgeuNfM0ilOAROF8Ral7oMffHXS8xmXYV7flolOgT)7SqiMcRNyrrZNfyZcSurzbDwL3SObb1zHjwomllldlOg3VZYGTpcyXERalu9uZIZcqOYBw0GG6SWel3KfeYsH9Mf8Fkfl7oMffHXS87EXI9Ongl43dOGzXlqwq1wr)4xbw8cKfublaquiw2DaelXWMy539If0qOywqLMJLMI9RUcPHLXdtS46qael2RPXqxSS74NybC1xHKfuBt1aJYIxGSyV92JUyz3XpXIT73HRNfuBt1aJYB4H)Gf2GFeej6XV3ZRjnEZiPG6SWK5QSAvER1o91CAAhavWfopBQgyuZYknLcQZctgmu5DUie)PPdPG6SWKXRO5Iq8NMQVMttWZxfmnf7xHrKh(dwgBT)7gcXuy9u(VysR(AonbpFvWSSgPDODy6Z6WAHn)rT9rq2ERqAAVkAcBKKXQVyydEUk7DWRlKTwkS3A1xZPXQVyydEUk7DWRlKTwkS3gaUAriYE0gtBacvGqBLj45RcMMI9RWBIgcv7q7cqau51BQd5(NNoLMgGqfi0wzcWcaefk)7ugBD99yttX(v4nrdHos7q7ApqMVHkvAAacvGqBLrNAm1OCfsttX(v4nrdHoAuAkfuNfMmxL9kQ2H6R50yZ7(GDgoZKAvKzzLMITiLkV74Nq0ygewtAhAxacGkVEdaQ(9ODAQD6R500oaQGlCE2unWOML1O00aeavE9gau97rBTylsPY7o(jenMbHhXBOHSmEyIfuJ2)DwG)o12omXIT9lSZYHz5kwacvEZIgeuNfM0ilOAROF8RalWMLhYIvddSGoRYBw0GG6SWeVHh(dwyd(rqKO3w7)oVHgYcQ1vQFVx8gE4pyHn4hbrI(Evzp8hSYQd)AS8ykYPRu)EVsaITOqYwqBm7t(Kpjb]] )


end