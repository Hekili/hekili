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


    spec:RegisterPack( "Balance", 20220814, [[Hekili:S33A3joswc(BXN5uKGXgdcJTZ6K2ZjFUtxtvvwB5C7A)KXYGWOnbjAjHD654d)234EVXBfHKat2D19mFOQ0OhHI4g33VIBgCZxU56PHfr38Rb9dc6FXGt7n41NEAWOBUU4Pvr3C9QWjFn8E2FKeUK9)Fx4IWKj41FArA4u49ZtxNbxAErXQ8F8KtUJEMJZJxoP39XfZxFxV40t4V6XxhV89NSCAV5flx8VplEr0L8xOxX3kU567whVO4VKCZDUNydV56W1fZtZU5AyGyF14PtJOhpkFICgU52pKToE6MF6TRVFDEXMBhC6rBUfgRn)0MF69ZdtUpk)h38thV523YgGPBU960fHzBU9DrHl7HxNEi2DkcZUpQyC8Sn3ojmpkNDLu2F(0KfrJP7LtVXVhTm9b4nwNKenjkppm7Pn3(qywC4DlG3RDCVOES5XQSOhgNZE381SxFZThFfDTEYR1HgX3(qkBra3J9LlItUFZT)rwyX8n3cZM4IxbtM5Sr4XSu4MFCYI4v5r0l)lHFLDN3NM8qk8h4ZD9Q4S4c2BfU52fXfflyxBzAg7)pBr03IVd(DBySFkD9MBNhon5vmG384c4RT5w2E66ffHjrPRZxWwBpgdZL3953(Ln32L9TIylZI4WfSz(I47twgLuCeopzlI8VgVQJ(mBzkSX8QzX3pVyCw0YW4K8xXEUjrjmqwkmjxTc(ka4(U0C2fWNL9VPjlEIgQVKffYgLVKUKnIPSj(7weo38)hsl38vrtWPwrwCYxJkO3)ZRIsIYuBni4v7FVMTJmlolQdB(govcTYIYJxeZwE0SlkmJ9l2WmjD5DHfhd7J8pWNI)2MB)pJtMMbygFC5Q0hJYwIV5K5rt(kBrLYEX3)bgAtoJuthvAZTtbS4EjPJNmnN)c59U56fX5f5aXxko9z)1VI0YmihBlC6nVJrMmPion5MRFewie1rw8k6A)gHpXiiK4tHjtrO01kSY0e2p)Iyt(xbqpB5egXF43Lc76WCxaJy)IHKL9yCoJDa7RveXW8V562m4dhVCXA2w74KOVXgPNFwD94KX5e9N1vVlf(26xmm5j(aW2sAXPBg07rAzWUWb8Rfqx7McgpepWMC(e3A22ghKS1jrSTg2ocNb140zJdxSyCXCgHyEp(4rZUdGT(hyxkPOxcIqpdau8BXq9G3JZRa)QSbAZTxY4ljFOIWfrWBhwSMHDnwWvu(z6qpPg0ebzUHMiGEBHMDeWVCg7U7stwN3RGHvhCX4GvtaKUKigE4nxpcGPdRaMIiqwa1gdoB5gu2QoW42m7lacIzHmEzssh58hbQ3XedOV8CGePwDfXaZN3G7nmkQdzei4GriG9asTX0Z0vElbQN(D7aqVS4jfWusoHMaaj6hJb6EI6FmjqMt)7y)iDfB0IkuJJqoe8xlwZ(hFGZRqWzlbDahVeU)I0SPM49YBYgkgyBAw8SIsOSv8HcS4mDDeWE)TPFKy)mSlX(jDDbWlKn4CMpepPR5Zj(fd6AWb6bG4aHsX5JdtJaO0P7dOeYQdGsoN8m1ccbw3popkrN34KWeUKuyEYhq4XINaYZZbHklIEieKmGIeqb2Cj6CHGriVTzrzOWecsqVpttQfGaiu1KqalXy5ttkacmARHaO2k3pzkJl7Y00eA1a7RA3iFTNRReN44oeAG1nMTo7jG3qeJhM2R1lJTasy6DmEwwuY)1t0DUB9SzmsOXXjt6XvHa5hOF9PRzKHXa6e8gILxposH5w4FLFxa6hkerNtQBHQefclY4euwjB(sa8qsnnCdlpUyn)ZXWaGNouQYbJVBXeAVEDoSdcd0DrfpgbOkW2wUX(wcasGnTZ8WS9UOS8OSVYyGATo()aOmVtEx2KOGp)IaKgqrPpXbJeE6C2hpIMAH3HQECw)FGP)t4ScaTsQfjxJV0WVWX)KeCI79(3EYFjzItrQviICsA6IPPpM0Bc9LyIfIgNtAR2B9k5Z1yXiK4aN4haP7iH0c5CI9pfZFIl0S8vTgmykjUKfMP4ET9CB584nGGlMadM(ENIInulU84KzRxmE(t5im0KPRZfft8ZaUYeS)5ebxx((kjCAqVxJFnlU2Zy)pnfnytK(9gGpiP(50OfHpn(onSj8rgkuAGa1kcljA75Efz2U2TgBLWQhI4hoZg0xx92fxsfzLrlUHgJ1hHGr(wOw6wNwiOecfedcUjX5O5uSR)BRxKdkOTklDcPenrgIKOZivT50IRf2yKmvr4Vkf)xgm(ITMF(KO4fi8TDP15Xe4)yD6rRDOoiY1Gl6J)jB)AlhohK3EgBI(mlmE64iGmSx40Pmc8Vb2(OHIuEMgo9PMXxH)ODe08EwYxbmQzyDRyQgwenDS1QeExfE6eHnWYVIPMT()gd7BppQcwvZKca99RW2elS23hUyYAyGqnsIaE6GmkKyxY7pj9ra1gKzZ44c)afjciNSvmCzYQssoyiOsB4Y01GcnGah(40vqtusENy9YMzpXKGWqUF9wJC3wOAvpqN6XfPJNghj5RGBvwiuGmy2Thjr6AxPCb(EJIBOfcxwi4kRSuaC0PSA0gA3yYeZPmh5h08fTz7Z0OC02icX5cSzFo3Qw1LeLzmdwLfVKPDoqleMXu)nEY4viFp1C5y61KakW62)264vRIygASC1tmy7IXSXiHCQxt3Dk9QMaSZohNWT3cGMU5Xv(z05Oixk5PRzQNxaEWBC267EY1kXsNi5hX(Dhp80rx0FGfkWPL)OSBojBDbSag)3wZ(eRxYiTEiMdiLFa)pNoQT8Xlsr3xXy5WErCopC0OHbdmynDkN3J((jWgJzKaZ2v2RbYmiyGAGnV)4HNDEWPMRZa(WAXS7QYmwnWmd6l2a5ZP2AsXzMvZugFSufDLtzQ6rgQH0kCOyXacGnwmzOHr72Yz5wYgVt9tOGsZMGQNnbFpNnCaEzRs4wmHQuYLuGU9KlIGlAGugIl)zA6A0ISu8srC7oaBcrVOYFD6vaBSzC1zyD0nT0HIjlWqGZugWjzASqxQb93A5nG)MyeO3fNai4zmPGJZJI(AuMj)2YiSb973iDoj(ua90XCEVMFgMD0GtKpeXa6OPoSZhduZ4cCOA3i2E8H1RvYRT3rdtEsIJLZ3QqFxt7ppggtHXa9WbSB9X1RMNYgosxy9DhJfWy4nX9iBhDx2U3pYzlV52plLCe0ppAsoyT9SuUr5cKneNcMo5Psf1lek6aUnK9iRe607YgAr0Xkjoq3IhVA(XzR1QPk(PEEDUyLbwnbvOVa)QzOcd9BUxT4YdpxrfvgqbBS2oyT8g71KOqeb63rXON99Fx1w(RLzSvTVEMFNm0QgH)oDaEJrqoRe(HPU11yWdncDQqT0gBDEv28qFgjwAL2V33uJnDLCkYwpHPusott)haN8FxKs37xOb)g6t5wF0MOZ5vsvqCr4qOcnsTnJDTk1BZ8lx3sTVE8pSq3bstVb7zsidUZmtygtBROSeWQxgZ)z2b)5a(oH3NF8PsN81OhSLF)hfOBi3UcSA6gs9OrdhkzK4fybG4TpYe)D0bAGoXJ6j1gzypIkeFR7wKMoDX68cbDfxJLEKNFQ(zBePCx(ODy92t0CJjUuTzRmtZ3oKcHRoeZ)8W2Xsa6Bx8y4t5C5I)L)3FW0D9KOsFbjWiOe)nBLMTJOKaH1pDJo3bf7q9b2fNsbDufJlmDSJvId1iMhYaDaQ)NZUtP8GiWfCQv(dXGR3b73CZElZyZTRiCQzaAmTfJjdhjPHgi5dz5qjlHiU07ZPBS85EH6uLqXoDAAHioF9kINqrcG(q4TmIMG8b4RIQd5a8qveO1H6tbrminMdnLFTbLvvpyRTx2XW(IPIDGIQHK)uDXVEq7amB7WPyGz)L5GTUO9Uaod5bxMnz3LcmQalV4zs1sm5RWiVkTOMbTl0nBteSzqp5P6kkl4wG21jDmm(lCGqUhbWpZxabcb(cGooq8tPSprZ2qmJHCpfCYHW2pdhCPitfoOw3ESF94ttdpy76KSQjRSX(HeeDP5tj4dmw5URQK(4ts)y7pNMOkVAV3L004k3o4YyczRksdCmSCQ6qbNZQzMDCDtP3qtDN8jn4IFqfatDoeE3FBcR4QNRx1uE1g4V2M71AR(mLd5xlZvWxFI9DsQ0w1QMkvUG4Wwhr2trujOR4PXgLUBg4iJ0qHepfMAx2pvhtVM9vktnhhPsuZXqkwDF8)vut1GRF9mtyC8bgKm(C8RQLWxYRa88TdVR1df0ygLbLyu62B1nYhZoy15ZnbFN5)f8Nj(Fb)5J)NZP0Fs5)5CUU)5)v)NPX8)KRnxA85eQA7uT)zMP5wX387btZaKfPDscyBWxUqBxsNyPgNm2MlZfQOQ4ScFv8wys)AhriJb)JX0qEFkg3SuU(VqoqGMtNc6gpHqWOu3v8ry8cmZPxTe)1LTX8CvulZF5j0AGV8(V0xq7DZlOCGgQReSGfkLf0ITto(vnPcD9(QQFjRvIu71Kzl5r8G01xySrsQWSa5EMW(GJqv2nYzQmeSNWhn(BCek0cS(G2zIapmWntc(JH6MMeMzeDqtmqF5yD40PvSUn2o1K8opmhhCG2PbANvsYDCEVI0LyYpUmf8BgW8Dsk3dAS3jV6vIlVnw9kjW5kjOIvIpPHMgR9sxjUYNzVRepdJ2kRrohWWlco8pNX9lh)iBkbDeBUzXjGXZHRzqggCdQaGNGiSwenPat87CVgo3BZTBU9AGusrDbevNsVfJkacs7ciOyjrWyjllQ5mcIfGBOKB5N6k1JRNwh8dc5Qwkjs73BaPExPcZ40vmrB2bxMYIEKCvRyKMGflgg1yi1ey)ZeEkRbOiSVgEROVfUCfSK5CgigizS3C66LRqNfj82Ni9NHCqhaNZM1rhdjhqcr(KLYI16HaJ2AiG2hEM8dV9P2jpGUd6BPoT3Ks0jShWN4LvGE(7928FtZNp5Zz41tj3ebzbWpsjPGSAn0QfqvrhISC5pvpJmXGRtty(kzE)jwLGd)yYJgZwk21KtPe2q8o8QEBY3)IqtRYIyZguSkiA2rf5v)2NAddsEXhtZsgZKchUeYUe9mkrZYkNpOUIvqrvSm8BiEbMw3sv2Q9vP5PQuLI(w0K1frQAzchpAYuDTN5Rs1Cu(z(NARx1KKwfzC8b41MewmbVejAII8pvYjP0fGAgG)g0SWUYzWp)y4nhdViti1SDt)NdCHM1QsNEFUrQ6Zi2q3bdH1IX)kVWohD66aLT12B3P9RWuOQyov)qzJFiohqiCZ7W5UHghCqNl2EkmVKfZmZkOm9AKc2o(zc9Hx4tgHE6(e2sxv40UujtSd4WijxHcsvxlu6JXWbySTq5pG9DaJCKThY5YoRr8vPlvzfNdl0uXfAB3SSDsGYwVDzKAG4c6blNmBdcoVwl8Q0rk9R2Jh8CeUJMPSTbfAkYyZr0GtYTqLG8m5j0i3KOlvVbYgZt)wiRLKK(wrJum7kLwmxALu0LdFMvDwk)qIIQZGn(aEK47xYlB1Sp7E259t111QsftCBSYQfXXDGY2nxRwI2vG(H6sW6yJ33OskZED0GQdxGy58rhtv8TiT8yB(xOTKC)kizS1R0Pj(MEq)A4c1XL1HYGtsr)LXXtV5xy50I2qHSoJjIAoz9rD0lVbPaB5raPXK)uYaZ6fj2H)GUleKtrYbdoci2R8BvsLgmRwrCfxAw5inNzc1evelitBft(r0Y4jKzBSrd3h3WZlXfXpacnhCkLmJKSgukejNHA5eYzk1QgkLQgHYEyISMHHhcwT04I2oHdlTkO6cnNmtcn4CE4d00kvUhcwoLHx0sUSdtVlHMubub(eZX6KgkK2fP3HDMJuv(P0WCePzbPxiGTrw3ZEUWvJXk)1LbWglQ)at4cO7ISevSCzk1Ap4LnRzn2QLi688yhWoyeXqALW2JU5AYqXJLQEB7xDevopgtTyPPoqIrBKOXocedVlzuQgQB1GpfIStZmj7pPnbcifrEuTyk9TlnXhYsmXwUIgtKoUmexIVXFfR9M)ZOOvK6AxlR1CGIa)dy5LdDQhIIGxQb)8ttcZcf0yyxVj3yFtvVMlIeuGspOOC1lON4DryjYHUvryscjsI4ceijP139QvwVAlWPVeSmDvY4QIEWqj9FCVfqpGVXH4IxsQD1c57yI1ubd9wVezi(vn6C8(EHnxI(nZTy)feQY4zlIWmsF89lIxcFAdj)KIg)aBCOqf6x1PGAKAnYLhHQHc4p4DjdercqbXgObLz8yupeCMm2OVdq25f0jLqzOV1K0genasHmnflOzCeLPr3haNqEn9(M3r67iITcj9JSlxmOPk7gPfKMtNRJUOwK3Vxun7bedjEwzJRgEJJkHTr78g8CWTcfNqGB2xLCirgzKFsUt6Gyotr17ainJerrXTgf6BynLnqnKGd1aZv5DO6Wb4AIlvMWHZD8Xg0GntnigbgkP2yKv1NqfFvNU4SENnzAxmBkDHL)OD1HK4n1bInK(d7hKNll9m0rGDe1vMNLgvar2DMIdBG9TYr2L6d1n6nCOXjTNQE(qXMIlSdrWTRyUzBGGtxLz281wtnufQO6Dq6k9J5rB0s)sTbqrFBWfGVNTEvpcTa0Vbj(ZaDJX2ke6WlrFesBm7QykRfUc(1g)yAsHHtslvOE6SS4DimhgiOwbpwMhMxMwYWoSi1MP16veVwNqjGJ2PDfnZoe4GAfwa1tWPo1qRw(hYhWnSbFMd0ZUDl3AU9(m4kjFPg7ZaDjyvOt3PnzfDJRQ3tSBhonKTb8aB99yie)MQCDaWiWmPU5gNyoiJNgUe6uIqmHwq9kfyTdjhU7hKVMLAj6)jny17c)eF6nAfvi2cmUhmga9fGaBdKIYLFIwiMtXTK(RvP55uV2enxqZHZdviHGW1)FyVlL0rd6fAI7f9TvGb2vvAwI0KVAiUTssfUv(K83k4kHU(ScaTQNcfXHBC5hvUNa7y6QLoipBsytxjZ6Ihz7TWkOK33kjBtHBsbovjZYPmczLrAA4AneJhuw9qP0a)UZ3(vAzQ)r1LKP)2vdFc5kfY64v7eC75nIDYlmK6vEFsVwFpSXBpDeuTUc7NufoFoEuY2ZD8y9mtBzO(qTUeScC33iJBEZxUDmwxosoAHkRnk94kVWLquCqQpRvT4y97cF49lY(2xSwxwG65GmO)rOSuSaQH)NreW2OC8y5OZjesFDAXNoY8fbyPwVHlM87P2Bc83qP4PMFfTA528JX0y5dK9ML8nP7(RRW5oW3201O34QIlfCozFEs4jjK1LuGpL(RAMql09ys4QvwMa1qUm34Qo6QxrFdUj2Eg1RIQ1hljpSwAvrbyPzEgd3nVa87QI(0oIqYxO(UIK(R6oDD9O0ExrurA512)ah2(xt2l0XuHixLFxzocwj88lrcGw0qgvJhJCd5qR1oxYVTIyf5(93Xg9KrooPJRk6mRLQBtzISAY1Zj5OWn7EclV(kXioTJQchBhxPqYmFMjwIZ1RpVzRc0zOOhQ7mZfe1TlNlKGzNwMkaiJAzRaHp50ug7jOlKy7cdObfRb8KBfSRcc(ljWAhThYtvj48EMuo9qVPwQ4AAaKrTpXMFHzj407gxPHU454I8bop2PmJOB1qkZ(om1K1LQyAglFVnhJAg6swrxKKQgtxzJsvjDHxS(TAl7qIkrNHS(k2IEQ(eJ4IBCL29kFhOv)WBPPno6hGUn(vOoiz8RseUMqvxmt6BQYNEcq4tVmCzWZLxUQqd1ufsLmLCI97IOG2Q1vqrlb5OayqCHCQsOjsvfiGHyt3k58rsFr2kmEAefVsvSL9XNPu3nfFY3Yn3MHsZ9dGkLRDAMKPMthSLyLM(QZ)lGksr8ShvtoiPRmHFhiyx37kDaIMKLsnR8sMOj8BS5SUkwyVwyaxJBCWD8ZBuRGL8E)ovybNrP15Sxt9gj5MRk)PVR7GuuksQ6AYAkZ7Aq3yZlxXRO0tUs1QgvRItyEa)RbvEQtuoKninxOol)pd5EPGksiFxDBm00l4Mpd7bGibvtkxJjbNLa6A3s6fXZWZvShjcNkAAOB7hfROPuYzmVgaE4IVQJhchl(pSE5kUNNlfTqBjHi)Kcz31V0HnHNARR2Om0ABCpJdm)sz8wJvLxMjrmszz7u2e4EIlpDPrt7mssybCeyBNBTqQ)bbfgzQ0CfEp3HeJQCOURqpaagV5VuX2eGcqQObLkqgYpVaGZ9iDIpX7WUvMEoN3doWKaFkpvrhuodVWF9xfQHdqB6dPinEeQjd0fjY4dzZwWFQNOZnWiFVf7VCRO5Qi1ZqXOMhqdhjuQ70gL)sv8EBlDtEz6gxOW15NT98uOUpNoPKJYjUkhBgAMAo1sBP7e3k2oLAc00i8xsJNstpsQHpFaKe9i6awxeKGVnD6Kpd7L(0A4Bbpl32jNMlH7h(ZRBZ0hMJFozoSKY1Aqczr01glpyGgjn7r)PLbGtpDddQ)qt4FCtWgRF6OQ12S124bHkvlvHJmpCXmcjbGI(nTFBHI0kUkvgfwo0mjDxj718)3R9h2aSqT)uxr7V52)qCiq9(pONSRzzXPzk7wHsaA7ZqMkQgekgNZwKcmjAdr1fwZpnMBP4HCZsor2z0mEAPUyiNsJW9q4zCdIoHY4RMKxiY0f2SmP4860o(OafgubsP7aoJUiM(hpbZ2FqUyiDco1qzgJiNqXzUuEEW(4JfbNcH8BZHo4Nnu8qZ5gqx9vtbNpHbUJRYIOktNrzJiQ8e)elue7hlU4vHn2ABILMTrdvNDQv4gPHkATTGNtzZHDQf0o5KACVB7lIr3NRqbcxrGjp2HcD28bqoEd)W67KT5jd4f2SqffhrPTMsKeRcQockwzfzxfNYMsDAHqwUNzIKdaLdpega43NbYUiDi(H0xXLEocloGgMHIlbVGxXSyhBojQM33tqjLCZ2vE0QA1v3kn5zlNMIOfUDCYPMJh9DyaLGg4qfP4VQiJypjpFHK2OuISYX77p87wkcxIhyzZE3Q5YbUHJT8pKUxonWggb)m53ZcLukjFBMqwSTq0ABNn42aAvUiuoNcoYdoEcLPEs5hPCQpYOBR47B6VjEUsn02GFJj3NywJumpBTwKhROf6mt80yf)l)vfheV(8QGMmyuEnCW)AM)c88idYrrljD1wfI86Dcv5Y38Qjf1NrC)1raK)nK6xb8ZVRsmoLNkutvNoA4VPZaAcDgpjfNovM(L0da2wRIHeONZ8yWFjYkjtodGJM64vlIbg(uJoTycw9CICFrmmiUaankNRCk4dUVMxu1o6wMAJniObetHMM0JsZWDmYZJcxygmcFpKHHjs(S79KPSMNLpvDXWWk0rBuT9jKjsoj3daAWZGJkKu05(Z4sEsCs4HbeRKzrpkZpAo3fSwn5jEPDAFwqnnIhL3cmmblJtkNn5fai9W8hHIvxEveJnQTfKR5CC785QCCaip3IObYJxh9ecG7Me1lWlCTt7FYW(Tl3gx6W9pj)qqDqFa8enrpnT4(YKswlSq5mYIBcoa7r69KCy8mNGgH3wc0b(OfBeL8kL42pYg50h7ztWzC4P3sOVPxFB3Yz0T(xP2ZW39UYqtBjdAUP47E3wORiPK3EdLWX)SHvdggwHkBoALdBJptpyl22XjGZH0VDMDSrT(F6acKNOBWPBFLHgYrHQyWcewzCfGl4HTrLlhIiGolojox0OaI0JxKs7xkGrwXm9MDRi8O912QDRAXM4AQqNZ9nS9qvUBA5UXBPBhANTbfVA7U(E02Q09cQ3ItSJjLGLrBEfkrKCnPUaA5oJt)oWQvNnGNEcURubtFKUytnTAepeAuIciP0Yf6k8oIlbPxWBbhF8fKrHUDIrRq9BOW)yMDb22w1yMBTmiyAc7TRKhUhnM9ME2bvvGioVmRnp9kyoM4l9CgJZm1r84lLAiCp4XBoK(lceeRyNsf(QCLNEM7uz8keqWTXjXIVDLf5Hoyt15yCsEwMUt(cLOrltkB8STvlMY1oJoWOSlXKGcP)v5P1VsBaB78v1FasJHH3LzYxUWoi4OhH9dgLB0grRiLbz1kPdyyjZ7(DoSxLD3Zrt6mRnfQZ2qlFuqjsTdclTsRwUax2dRLxuwjjHz9PyF8RtLCNEZbmf0SaRAwyRgTRB77wQo2Hu7bTQA7R(niBBwQsda)7L0EhgFXCzMTWTvKbEOCdnsa2W8nlb7xTPfsR0rpuJ5raCP4CvHdrZzB4kFChZhwa06lF5BwHowpnM8VBanMXZkfD7yIl2LAyDwoGI)Rr4CngEd8nljJyldgRpC9qSbMv)BY2pLmOBAzjCxKEHHQdUprMS7i6S3(nI0NH)RnaUegvrvDIdZut)F2GmN9IHmE7gVZ(ourD4h0NNz3YAUqKiFpb9paqkci55(5Gde5nQuZukQacHoWOZv(V)VSfLrPs8VEHBotqykAXb6NlKMLWhxR3Jf(TPSrAU7z4KIdOZj17o1GjYIycOxHeSPXhIwfrDYMeifXWmJGjF7JW0yJmrJLB)gfXwy(QXWqJGgxNma12rGD5FYhCv4rgkcuYzIwE1umVewIvwdFBL)1ont8z4MEjA3m9jeSF8DQbwvLK(spob7yY9YtrA6HrOBkqrztQSBZ4OmTvPRQRVVxI627Mtj7O7nHx8bfkzj3zNlMr2Dj2QkPel3)EqLiCE9XHHldQ1MZrB2D)qA5FAkv8Av7xxACknkv5g9QM9EFDVii7i2He4Spk5zjkFTLrfwKMQSH0ozLB5S8FUOm7CJcC1iyvNiR0FZdvaESMao7pcIAvIHblpibdVtqB61HRIpjpqD92C7VGhwMCdwbRatk49QPsncb8BSoNzLZMB)cSQqqnf7kqR83)HCro5ChCS7eT5woIvoMvYcDoePruHQ7gXxIWQL6zQ3fbFSC2nJNeZMtG5wslO75TuRPJvcVn(GDSsRvjQG8Ue4Db6PAqJkEOqLr4JA4ejg9hWsLIGRiovzbBdytNVZkl1YxbBZHA2(KsnB99Ac6q3ZwKyz3NUCbHEpHX86IRwEUNor5RXPfSwwhx0doMOIzgJiRhDsMjNOVRHxMkjwuxyDyguaKgoqsg4Bhv9EHJUcq9qD1ygBvH2B)b5svoBDa5qZrC)zAVnW3FQkyZ(evQRxOfr4FLpCiLZuEkkCx8c2Ih8SgVJAgMWDAfO(lu)dtnk6bR8yG7fo8fZXZxikfgeCfzpYsJubMnGqgwoMakiO1NJcQPiJZnQY4noQW4ImAHvPXwhPXxXY0UDS4JTvt41bQ(kLtJvo080ZRYsOTzctbUzN20AswLJIMBoAQc4RsKRnNC24oEpgy6nHJY)ily5Dkgvb7RsbU6JOWg2dXnD8QMNPPachIjsnyb2)80lXlzZkMAu(79d(RBAEbyQQesiRqZTlpY4CQDfVYxzpwUiOX7k(Y908Lgov95)PjGDilWZeVsFkPyqD8Krg8g87PWrnYhHslKC4)fAwOvvhWCPucBctFcYrmkezQq5yWKRf(LJmWqlGpxx9dqhuL2jRZiPnsg94GoQR(iHq3T3FtEIN5wPFvRMYGURn8TlMlqyllM3tdQw6Ftmz8n2FKtKXqvgOVwnlcSEZeRkRTTk80MWelDNTb0DtaWyed15jLwiKslYAzsg(D0LV8VpJa4J55mCdgmhExYmjavldG3aoO8y8drQsG8uKmPI9gWpq0pmA)rzZIMGggXTzZWVSAwFWNkg(2dwf8D7X4cbXh3YEAGkB3dvfVKDZyhJxjyT4PsRffvXbq5DKawllTJqrRFqKPNQCGxScLN2eGgpGhxzaR2YaJY3ym7rlpi1RmMdV7WJj60vHAjwlNy9IUod8k8UGACuckB5176B7CEoDeR1mIQytlE5M60YTrdnP7oAvH3z94xw8HBuxHuoaLqk19cOlT7AvhqVL0BR1Ka3xjtjVMMB6w(gSodPAUha5VavV47s2dL7RpJWlZcKirErnFWJ6ArXgdZ6AzkyNJGL1etlnfZa(E0jkOdRwDZIXxlPObfapr17qdXtWFYdL2gvbeJmBwQ7GlHTGomgJFEqGwr(F8lN8PFXvm5K72nRIMXnDRYzgHc(n6Fp(LCQXvzDPkxs91OIMvg2Q2dnlqD)L5))mVgnlY7QoUsAsw0Q1wve4RAnifcH3TH)hXPJT7wk5BQi)F4nSfxDkj3Ujq30bNDmLMZL3TWJD32vhokvxNs92wIQ61BwFlzp4naNDnLstGU0rk8HBQPnX2X)CLujxncc(O(ZrkV(JOvnoJW1nDMXGCj21cKQopMBvUsS7370gc)RiVTLVFZu)HNbOL27UY1gYHIQfVkxLz4bMkDdK(k6mlLL(7Yjf3l0fvTmZv3Ylp9OU7tps)(E6f0AIiXWvDMd5I99xePfdPubfalSxoKot3zcWzJa620yXXJaanya8jFf0GQCRchprQegSWDIJLEwC7o15zxL9c7MfbYHsS76Ub4zArc(c2fnPBp9yWkXxcF2mItmwy93g1V3HGvqLkZ23(vkh75drdmoPoMEDXPPZxVnYdOXTdIHcXgvWkelve485YURx0vDy6kKRGj2w(yEki4jPA)itl6LudKyo4TILRHcuM8pgO199Snfy(TcRev8u2QhOfe6ifk3Pb38MeUkFoKitZKg1lDQwEmZqeINheKhvdHdDcZKjq4hJ4V5cqzryeyR2zzHlJYTYVPFlkJTxHBYBBvTBvNgUcVtUiY3MfOl6HXuXztkApd5IhSp4Pc9ZfGVfjDarp8yxNuQ2jGEHOcCB09wYrUYDGsT0pu1ZvmIOnLYva8wg6EEJVA0VX8zAm1DZfw)gLRkQ9aXIMjAuzQ2Hrjf00flrOlQS6ZJ9dDjxoyQmheRPCU4lsrbGa7k6qQcwMLj631PJL9pB30rXG)at9)lh6GACzvnSL55AwDTZwHabFTD3HdfbERbQ4EOMgxEAhVo10aBHV7JaUjeP4R84BGBqkR9Gwxa8)GzcExpTcq(d66Oerws7OdJ)1FH)OFc(JcHBvfDPtr860ZlPY1aV00tVw(xxiD)EBtFHJMu0FoNQgFgR6QSHChfMYShSTTnAEJm5LBaz3l0mc95Ctf2GCunGIISq057jxF6ZfNpjoH84ZRsnhO)7j6KoprC8Q1br7bSY)U1Wh)tmYOHZjRUzqz2bkNmvpfjC0bk913AfMX4nYGXIel1vxS6iLOj94UJqik67HY2chh(bpKiSIuv4zNNQuOdzs0OJiyvMQgjtTv7wVfeTdzSEP4aukpaq09CEZZrR0xe)qeSek)vxYtSm8Gc78Ci5y1cMiBYrndFkcMm9w)b8lclpZMShF0dccupHS4He9HpNEXvPdzvyZ6kEANs0AQiR6hasArh(CTclnBvMBJoHK)S4(7tMn8gLJ9Q0ZbN7IVKvYm28O6DUf3JqMD0fzPa6MXaDxuwEug48ixVFNsMly7WEBky5oTd)PoQwoV1WmKM52VylpoVL06Yo0qo4mre9ANVEA9b2YDppngjMzmGjZbnMCytOeMl2HWz6EQL5XUfZEBiyjqgFfe0)I(dqMRadG8BU(pE7V)R)LF9)1pU5wOtoamHychZe(84vPRabKVAJ2XwCoMs9HRlsbxSmfdgwY9qw8)t)mM5Ob)iXhkkdV9Ru0o)FFfbu0VKGSHDR2d(wh5Om8fokB(PAwAtJMfUErX2T2oZCwDD8Y3ZERNska))(d086NxZ4TpnMcrfdtGzXAybg5Nt6yTipBNxKbAJY578OOpxU4LV0c8pC74K6178OmSIrPGjB7Rrf9gOgfXLkORzSu896boE9GYV(G(78IqhumyW(zy2pKNdoD)mm7oUBqvdtd2Hh1K3VITyJLXUJThu1W0GLrLtJgSmg1mULqTPKU8UWTKFPnx8gSG0jCTrYAW6z4(Ghe4TPp(5FU5ctctJ2oaZ(HyE)qlVZJInyYZEo5Cw1og)37Fj)x4xOOL4mD5zltNUEb0aC0eN9d2sQ3p8PQwg7wpP2z879Km2bviL7LQ)WGHV8XZy(nA)Sm3Dv2(Ei3B)S3fS7CJ0Nnb75TSGrV8XlOIXBlwMgtRDFVZyy2puVd3Z0Dd3zCbpsdcE5ZVHntiSWW3xTvsI3dZVgQKq(wQ80olx2qq4UloDqfAITBJYoZ80nU1(YKODhezyeX(bgTVeuTFyVeS3ipCpE760A33YQIh8US6gU)5PhSFeRVpenmCViAWucZUV3zmm7o5MXWSZ8KKS9)lixE4Lpte9bOk6Zlaw5yrUnlgYkV)T)nT(N7hGMpWMFcU2BxFp2iagC6rqoEeeadkCJ3tce(r6xhdfy)uCJK8687Icx2tEp6Hz3LkI6Xq0KMeMlQQFJgjN6T(9i4Cqzk0BrsIMeLNhcjxQiYWS3TDCVOEhrvJS(zt5XxXRqz516Og13(qkBXb3FIOZUjowLWcC9vy8SyJYJzPAT9n1aq9dgyBjvMIRQordaDlkGKyJcW1SfrFJsQT2YQ3EEiLpEZJ5zJwEmCWLeMeLUoFHS1Q8UpdNRbDzFl1bWWBfDgJJW5kiQ(RXR6yp7OZuLxzKMom0I8jmuKS4uyIUALS2mX8hgF2CkKHQH7lzrG8TVG6daP2Y7weo38)hsl78vrtWPOWRhYX4ZOJ6vBxi4w7FfrbTdK1WtLqUSO84fXrI(ybuGuXWWq(65yyVv7J8P4V5oXD2ikyRzyE(8bidEGcvZcnZUvSr960Ec093MKKwqQcjjtE7V9ZaAmJGcsSYzPRfNrfZlkwL)JNCcptqpMT9oP39S90131lo9e(aCmWZ7KLt7nVy5I)DGm8srQJw8Tc4dt0R59Ko46srAcWdEgBUX1MZS4nZJ4aT(cCjO2rzqScky2yomX3NYz7ad2OoqvamHmmHTt4Jg)noctNLyXz0hLBQ86Pb(JH0nPE7oKlRLN)DV8eXe9iiGqxMMmMnYJ5tLJWypEz)D4ntxDz40P8byWrXZUu5oV5H54ZcXORL6YYGjk6hpToqDZ48EmDFX(i2s2ePidcR3e8VwtZTx6KmqFsg4Esgu1KmOrtscbrF)M2CO2Gixd)4juHlonQiAcIKhMRHPqioI3VhycX1agMcPdW1oLElEfeI5kxseAmHGZatkW0fyW9FHWUtbyxdkpJNF2FNXt7EqcwUiQaegmoB9DpHqnQk3jU7krlu5rmJsDAmzjMWpsarW9TTXBf9TWLRa4cNQIi(aRTKfVUihIfjXayGyoMnGDAc0HxPgC4XW(h2EWXqp14qxfqDZgXz6J4OAhrjicB3quONdxYycwqckWuAxkLuV)aaTTOFKQRlzIAu(mgsWvH)uncNrRRgiHmDh0)qLssLoavCpSqgc9vOuMtZw6(jWWJFe0pIyYlUCqFaJSTiJduNBfmSmRCO24kaZs1fe5qshuQZMB)nshfKVlxhfQxYzGscKPx)fbJ(FLQ96pb5Eb(W0PJeGvQY2ivsdixBu00LlS95QPfVBXGJCRdWFfq)YX3xKVusy7iCY0(a1MOZM84ZpFq58pHDr3N54xoGDRQlCJop)C7Yj(JXcgHmnbe0P1botGh3lFCJ1A9xZQVv51ElFRCVtgsvNpsPLed1HFSblY2Si0ccatcL5)qy8caqPOmVKat3X09xEn2sceUONriC(74k(iMSQ4jfCr2Sp0BAhCOrwsbuayks11UUGK3rNB0BfjShCKTjzVmL60gHQo9SQu0O0hRRlQIsmyIZhhMgX5T4g(E1GwTpWts))8Zvv4fmeopdzG2cuCICsIwu00OIOOffbD3O1)3vjfugJ33dyFHBMSOHKj4hAiqeAx0SOmujAcArVpC4lhXZBiKNuvGiAk6hkXMVxnaxsQEzxvNWa8JzU7H(combcjt4i1qvf70J05mqOuvfggCXeE6oITkVyux9IhXwNjSmYRyDKmM9b5lc0ctOykhiByXp)S2f5D3yZRjOKlDvyp14IgfEcDh7Kj75NDKtHxQFnHgIp)SQcyr0vesJ5m27KPn3MkQAbcZINwA8YLhW4oR)pahyFuljtkzxC45e(fogJEgPP3Iq1G0Q03JZB3jN7AobByprnmf70Ybm7QbJADGD6498Z2xPLzYy2Ytc(1QDvPD9BUCqWXNQP(Hvov7Ct9ndyYMg8dAjh4BApO3RpUQ(D9Hmn1oMmGDA0IWNgRGWSBnSdtaKcParSjfmuhfRHY9joPOOgBTBtqaRddJfr9nSpPuyicA73RsH)c3R9SJOlE3nqYhiEWR9T3W4NcU2OLHxqEtWi3WcNhT38(bJezVIUnfpROjf2iwtHyqu00jMpoDfq6AybzwcUCwrqzC3UTXA64bJo2ts625hgCr)oxv7l5GcZyeADqwy80Xra1rpMHy59I(g4fXwTpW554uDKV4d1bi7CoTVkgYe9vPW(X0XgZ7NFUcT5B5B8g2x)B5F1wXh(4b9DQJPG9kx4es)XXaqpnX36fTYArpIgWRMMU(oXbs7AzDQbS)rhxXFDEV8c(VPKwzjLP4G(rPFejTgHahnQDrP(zjJoKbCT2MJtUAeB7VTtwMUYgBAZxL52DuQd5S3D4G1RCGnFbf)XUJQINAPPADdOlPODheO9n8MU8hpiGTaB73ndvd582q(FZGZoVB7kwMGjfvome9LxFC0YTqx5qA)8JhE6Ol6pqBt4u9H3VpyA14MUH2xNzLb47wgji7LWz3WrJggi)8xDAFW6mXxhlWFWRLJzpC8IwTvdK5Dgp8SZdovTkcydJbr(v2mqK4db97awe2wk7W0bvGbL(U1qgkIY1I4ADS47WmjOShjBeZOo()GbQVxG3VxW(77XanwQZV2MFiwbgAUGey0HoAN4UbDDwKLiAAc2KawVAEkB446D4L3w5t2dohUdQUUPT34d633J(cDBFA)JPkmRCfwFyqhUckoU5vdV442EjHzVQs18pYjH3C7NLhDhb9PwSOWxHA6OHslaqLQnEJNISOoiuxYw1MeCQMVgaf2kJlIwsa0smta928ixLra1QjIvHNtr5uElRkqy)UvachwwZwN7IdpxbQVMyTHOB)o4U3Bp7FeWzBoSO6X(GZNv2MLwEyGxYpqnAd6mT9ht9o9QK2BoRJdH3vOjVpTZEZz1PJFFqwOUWgmchPz5JH0dijIzVdOPXwAiqvHhOv9YOzSmkH816GgisudIwPmrXxX90VFfOwtczGgMEoZYGGuKakiZ49odjLBFacMWN5)p7D12BBCKK(3IqGi4WrKHCihlzajcS3ABS3lz392eCFvHsIYM3sjQJdv0zGa)B)6QQ(LQ7U6EAjBN4aCFjX2CEPNU7Q6QEQNQkPR5YfOZ1fCrIUxdtkdFUFFLmRjVkoFoky)N2(0Qp2PLx)x)pFta2duDSnfIhPXa6)j2W5V4oWEXS2jQZyMpPDeED82NrL6SNjTJL)TEfiQv37O0wjvQrsxaRqodjtTLyqb7y(TwenTis69zGmItQMVdqe3a6iLpSsnqatE(B7V6tHfiO0YP6BtnUVcluvKzVKuASBdcNoOmTJjTfNwSN347mgtHv8PWv95uq(t4Rgi0O3gmmzNCZfbgrmTerdhGoEo9Ic7CCfQ6TGlQqxwiz)5thCKpwHIBLxmvhlEm9CjkZaX3aqzszH8v72JfLRNw5v)8OkeJCC4Dy2d2HCd3qe58Uh)Be1paTGnynXzl2neb4WVHZFJaYcKAiiSZU7e4z2zO2WmpXjF)go6IzC6me6OYl1vR(GYnlKTOc3mUDFoJyjWZ5slXmsOztw7VqvbnnAy1ZAxk4LO9nZp7jjsfIynV8vjFPJZ8gpFwRmKqhLcMCNRMYt7Pu9KzqSSe1sSDk(w1MJiqrGayhKhfubxeT3o1Bm74vnhfHKkSxL2SkwPBw2QxtflRnlBRmEM2tXLjXzVtZ4VFbc(nzf8B4KTkuWpdSgbIYXEF8Lr2U53fzBj6E91v2w4n(BVSTWG4lKSD(NCpY2dggDUE0Ss134kakudWlrbaz6BNXgfYsgRDcOcbRHfsAlWNWB3q3373bbN)WotKZoO9yBhy2cEVeR15pP9(1zeYIAGDgCkLefk8EU)UdAUxjgoqCWH1WVRxD4A8FcMEn4bXQL8M2U)bxXi1J2etudMl8D2eRAvxcpPlHhKYFGB1UC60aivIR068YvNSoxxhORNozMbQTCxEitB4vQi4zmyyAsqjrvkgpOs)YvMVMCINxezH)9D7bJuTe4xjc6XVnyMpOOxXN4J9Z)93R8xZLcbgeKdz7MeLQapsoDCVvC4rn1b0eBqjA25xKqxgW5bQJpgu0cpe0JUMYBcxHaxg4NQEosqlfrxJu63KdfCrFN(NGb69k7UYel4qa(N1CQOEUKhmpv(y1znvqi)gYl8SNFr0CYQUhY5bBo1623SSEDmumsJSwja5aoOuXPKgJ5zgu(oyBAs0TmBs74PEMkjm7k9UeFC1TbEGv5T6kPmWJBpPE35uHTKRYQIVpjbtHkGFP0sM4pEjXHukKfxCMEakFP4wy7LwjB99SPjKMyHm6hjKwi1DpOeSxF3MRPZCvkCX3MjMfB38lG(0zlOaDqkbq1dKcaDX4ZqAWvMmzXhUuH6ciCrZwGzdshDMn9yPVJnMs4nCYoMWbFy1VqdRDFY0TQDf0V8QS1alDIx2IrNYpK1TVYj6C(8brQ0TZ4lg0Rs8QbsSMyXypX8A9t07qs1cIAtO)PXslLW8cvFebcpUD3vygvTJbSDIzL0GwwgywGI6sGgZwLwHXEHTTuBZOZqwfnxxGDUkXG7pe(rHrXvTL6cibegRTgj07cCna7OOuakd8euUfLoO3h25W7uPoWA8J5lop5DDtZm1FiPgc1jA3PsR))7Rx)aDwSR3(bsv4Fagwqun0nxDnTH(p(41R2VYiNUjMmqoM6HvDAYMAtw44SNgmc4Q1in2WuZzDqbQgUQgNAHWDE6Hlm7lE6IDQzymFZx8W1E8MhLpsW(z7PLstIdgkFxNp37mePZkQCROjL4h88uMiFC6PjOI)Ylw4FWZwAH9YB3UgJp9LVF7M7uVa1avn(p(4fTlLpHTruZuljKk20jPaBRX9Leq9AzIy)wrZPXNqXCKzg2TESMIGUaNJprBKpEdKNy)iD)()InLG2GKCq3VY3y6yVWdDNZQFuGiZoVSB8YSR5ZFl5ZBDtTs7Bo6C2IJNuhoB50faYZ)tRocuuM858kBA2Pvl4UhyDT1KIMjoxoZCAp(BMAZ8CdIjjCVl9YbhRFb3GJf)1cGPtyIbpR9f0JdWljTlO(jD1Je92jg)kSIzHc4eECxypa3YQ3IFh11gWQZm02lWwXkSM7QnlOBC28WW9mRtjU47RR5Z(YN2D)HqKg4(0S8mmhaLsvOrtN0ub)y6LB8dbOLE1y5vVrZ5uCFu2tqupdPJxLEo98yWHIilqh1gDmdamwY3l36n3Y6tXYZjfGTzN02DHcWp(aL0vIBDaP7f1Mm7RtxWTF8(dq)9Ar2ZRj0n42kkjUz)r59kdoYzPzaWjL7K0Y5f7KeOTnXH8l6BS6wK09UyhpUqM7)EW(iSdPzMYb1QAfQOXTDuM((PGwueAbfdGL5UvcqB7)nw1mOZvHmrZ8BR)FFyZ(ixB8BLUsE4CKni3Ady7P77(R)A6w6lowuwV0Bt)9C6mQ)HXpTFqhXDkqXMGmtPwMYuxQHBIeOd(pEWpXCUuaCoto5T7W7oX)gHsqolHII7SlWKnkxTZ)TW4YN)ltPy9nKblr(Fkx(imgFhxtTdxgnmsqAbKB8XHyt1goC2IAjtzvpUrnJeal6XhQQmUAwD8Wz1AnFhEsTjagjDoVw9uR7KyOm(ESS65xnyOZZNmc8h5BYeN8xEOa6FzfX2Wu5nIyAyiN9KQPVZho8SXsWT94da9rhLDQRAWrXaBNkPx4zmSlbPfFZdoQxxpQeDTb(GMnTNbTxe3mrQMSnR3ibf(bunqmWFsT1uRU23T7VYCUWCmNP9thi1O(Qj1)0XdGWsbB8YBKdpHxyzSlBthhHeHJ9ZzgHum)sqjjdxl3Tv5k11RXfEFSq7n7y4xECqmfnLP(SkjhCAcCWjzGBYssSebZ9LkoRbFRv0bwPVDLnLNkJzQ0vxyA8WmMZcAvMiJeilaBz5VClq9TYlFfoOoV5vde3W6NuVwkUQL3mNxXI0JP)QQ)M0EGhgUhlm7RSfzkULIHJazscKHfSf8jNy7(fnVQkblAtLAUUDwtAd)svp7v7VhF0z)c9YodxZD0x1MVz76PDQvZHiMyYEwEdXjy8WBgE5YcGAXntfmToAwJtLHxR3ZTLmvqLoZ3gqKIM6a9Rn7AoZSlxbDrVR8Q1uqay5gmzcmnHGbfacFBIdh8ygAV2v5LlJjcwRYNbZXldKZg5PMZkDbSIF02BjZFvx6MBwtWy73NbLK5IsJA8k)tARVv7HqVtcpzKRChl5rb2q5oNSKOLA8VTNE)Z5nTjI8jCSsANgCS61D(W6R3Vdkagb2MTSPQNeN)1JhMjV5tsJ80SuQsWOnlbUeY7iLIJi(WmnacVzqkJ1tAMbwX1tEOLqAF58PYO6MiGHU9OR46K8AITMZgC)mg5GT7P(moSFf0z5k9gm5wTukbavg0dXzuPoIAgu8)1F1ZfLxpLK4Ooimc4ve8XH6ErbQd2IIIOrI8HPaVT6jkgfyItW(kweVlYmiDGbhHPRpFg54qN2QsGH5ISO(i8n)BWxvBFG0e6ByA8LYG5wudBgluruDKbQtMEBF13J6N2ZPNLTjVEJBJxCyWX)2)1ADF8cMsOxKBVORLBBXbouWQ)yRzx14cuCY)GRicbQSa85cOTribnG8Cw66kz)zhF)z4wN(CI8f)I67btBwdiVPSh2ROGh2ZEwazGKtZfWVLuVyMPgSUzCeTlCgzMQvghSJY02KDfHfzYfX5ndKXrFagHDx0my)A6pJ)Y5TaZx1)28kgRa8FR2E)6x3xBpgt0MS69KZDLKwseBM22Tp7psjyYORQT0svslyY(36tvMnZ2gP6FoIclHnJXm8VDhp8OwUpPLoyL6mqPTdn46zArdDbTRbAMO3bHlc(BWpSW7afp4F1i33Fm1udNlnGMLV2NTO(2T72TFOEiCjEXJuwtECZ0k9VzpEhhtEW1rBQWX1XlOP4)M)Pjo3WGCDNDQ17qeg1NdzQjN3sb5hpruxMjniIlOiXwFitMpaLIxybyGMYhU5z4LHVyMVf7chQviym53ugmTfKxXI7zW5rydJgdjDPl2RUF1mE40jnJgMai4XZQoo3V1mTEMha3zON8SjTvv1ybFnNccMan9jlD6KXYlOOt7Ku1CKhPRes1Fxwk(rK)HP2OLTqKAOwol3CnfGqOQRe7(0c39spp1sqtcxQQYsMqDK4S2F5TVt4(KqxNzerKsezk2M9TEu8SGiNGJhQ9yPgiUAF2bBDv6)l716jz6BkVlSIXHh8Ke7Y0Hb3Q0BNwyuQpAl6jigj2VdkwUuZ5jcMxPme5w7fJ3l7yd8igOwY7h3qDWKXO1BFbMNYfEw63hhKNyyOPwBKTuZDJRq(H)DQ()tb0gRyM3CJLHa0faH82a(hDM5h2a()yzIQrG)NHwtWMh2UXuqFUds9f4vycgS9Xe91LN1UErmXSfr))h10C8SZeFI2x8)MBluiqAUkuiUTQJ0fbpm4AOOSNp2(A6cqZPn0MRBx)KLJo69BizR1H4pKGbhOC)5j7pb25G8WMyhGMLS0fRVecCuM5gDhUOa2b0lQCLYBaLNlcpRpSE1wh(EPUaRDPvFHyFqMRrpym7a6yadfYnHyqTieoqPsBz5ZlYiK)vUBqts2ft)(5thgxQYR0qfORtTZMwJCVJt5anSceXdqs56XriAzh2sYRJjWZZFa6fmb7EmqhYHpzOOprlONup5DpnHVrQozk9CeV3xm4p0j4ZxKC7P)u75Rr(7u3mQmBrx(Q5Yd)55saO(qK4)pJB6pJBoiWFtlR(8KOHHJ2GMdAabDH(YaM9TBUFtNjpDw7LOOwRziOidH)2xS2ZiIEyV7WJg2FcJUuFAbvc2ZM(N(v8(nr9faNr7vLSlkN5TFEPEQbMIeStUkaBuWs4e6b7f3BqPOew7Fw6mej1JCuDn31z8WOy382zonX2jJW(1b4D2pHcmCtPx)aEciHSOFSx8TOn3gr5wwWWsfVx2uS4nezXuaRD6G81Kye37xA9ZtP(iikgEr0s5k(8PJK1VOjDUH5bMAGjSEOmaQZyHiurGu)f107AuDXhrJt4mzCTnvo(hAV3C0z5dOXU(uYKsAp6lavc5Ala(8DqRmRZlEGbH2WNwMH1d8aAV2f37wuFQxQj5o4)uNHYw5qJaIfA6a(wmou07ilZ4mlZMu3BqoCE1xKi1)IUgnfXcjiO5dlecHkgQzAsLzI0C42OCTub1kdrFH1MvmmeV3JDbQDhSUoHq5Gr3a(N205OQl9Y7Djv)IUu)EmRQYFCdKNls)npOhRAi1FyNUcZmdo(OG11)DBwZArmLrgLAuwq39dSmdQl4BohRFZTlr))ZUlXEn2tIeMtRg0d5IN14G)37bXL3c1KNjBB)J7hvFSj6BKpTxv0N2ZKTT4mWTPjBBs2UzIV(hHmvboMa0N((payNOR)g(XL8WEDnStIiuzPdhoe)daB4OoXdDul65pV9MbgSBWkJtVTp9ZdFZ6hwtjK39qGBXOpPul)wmQxwgSyNpRYQDv5f6LW7sk1TE90XdBmfnuFocJMjnUzuOz0vXmk1duKV3MDe(nOnnMgWh5tQ)51ULyxNc5FXu2st6jK5vQX)AIPrMQT2bmH4(d60Wlk5rmTuH3R(F)uZzF6NHUzLgJeqT)F(nDMWpCf0b3wRtyfaSoyLWSF2e(MdUC0s)jcFTuA5Ff27G6u)4MRHMtkCGP18Rq4w8xW8OxQTt7fG9IizuJjnodJgZ(ajAPZnOvxvRs5XaL)c9KX0Iv4tzMV)sl7N5jFUG2sj1aajXn(mWkzUdc(xmw1jQjzyzGXGDfGpRIuBb96baukrA3xc9T6H39fGdJhEyT9wY3rNAsdfx6Xt0njUWu46YNvkqO380dvzxErdXwdFIffsC0Z6l9cSXkY(RKwYTisqWHU6afybeMY1U79ZTEFLpFMjPW5nNw4HPjssbE1oJaF(5KGbDh8zNnlxakDCjxV(s4Uy(Si411Wi7XnhWEa6gLDF2pbsxeUDOw7wJNkNu9cWWd33ussjaZPFxCF2aJc1vB2QUO1w8cEALP1zdwLaKf7gFgI5hQknCc4n2HT)rkkvMtOvxYDzpEdEdaRcUKwXmTRQeGXmBAD7iH8hjvOhKu(51XUDrcIrr)pjqp)d73yA88Pnq9eMGwG5W5zUpzLDVe3NRq91nJtzN2O2KBylMn)lsZMFh3d8x78YXlhh(7nCCYfo08swFDi6)ZcM0Mxar7lS0h5J6cdrmcKFQV5tiv4Td63)kGuK9LUZW00S2X3zGXfDHKGw3abH8cncJ4(Zva8xmx6eEPPHO(GACULEBuxC1ePLyCo5qCEI3QH6YFneRwxHreT8)6h3tkcT6nWhABDNy9tHoBdhqy3B3rjqyKz)kT6)nBKAZIHyyPDnOWVgKt3VEAKFPgVW4UMcRtxJD2x1y5JUdhOZsSSR0IZpcQGw0r5(6B76uZlknnW9sEsbtZ7FCnn)BBU54eAMELOAP(21xJ(oPDRZdwaMLn6HsEpHHplTsVlXVm7zpry5xGLddkrTAnF6VE(YlMpD6lRU)A2o4XY95thPbioBufeJmDsEfhW4QvowFgwCOW4aaosVW6iTHlF4EAZEmlb)wzsLidzlC8WYSYAlcCWHMVMkhPdTbCqVH0ph5(fRzoB07ZQ0XA4MhwXOYJwa9SAXaAGnCbiQkibxYOmAy(K(wSp4N08Um1EQEWSUSZ1rxpIXfqava8s6nT)T3yKWuLxuXmwdKValLjnbTMFOCRSikjHE)M2mYY80fcGQnwODPYPmnv9WDK2)XRzruzNoEkAwgzPCeag21hEK0mYoLhuU6x3NJdtA6z(OubHKHeSN47X)QbY3FwZ7FTO7DCK0mg6lyDSUAVHUi8x(HV)D)qWOMNcjU0jiz(hWt)GGNKxAH8mFuzJIUFAKK54vpYQez9olFo(wy0jq)ewMUzbI1LZA0(ezhyorV)omb2YgCxDo0fN(NXBNdD1HBIxu2RvMUPqLCpx77BLzsTjjZOeUiFwM9c8SXlh28E81lMokxr)Ok(9xp3ChgPqPqGg2V9s68K0piezCdLys9jMJSod4jYW0jl6z2kjHJkgjUzt99REz4K4OMXPCN26jychonJYxXRinF9QYUVa3EzCBjEWty7lzBqS)TpJuVKun9t79AzvuWtWSmA3TCp0GcRgcQXgtTvdmwunzC9)eo1mU0EHLGuJfHM2rV)zRghAYOpkL9zLzfM92G5(WCuFG)Lyy2SKBDwHUyUnuY27ZBoDAEJGEgaNrlBVvDC)DuQm9bW5S7Eey1p5kmyEW7xrDvShqkVJvs0jW5oOFJevKa0lUF1dkpmpOnBW3)5UnktIilNaOgDzfn6Z51xdq6UwFNBHtqHNGAT429RUBDyS7Jc(5FF9(FCTbMXqm9hD2X5uovFu0nm8vfKLuZRooPIQALsUwE6BvdLqFJwBmC7DxQdWI5bkrppjCl7mHQ0prfqSo2zkY6ODHKd3yUQ7W08maLdYOa0F7qgN6s0god1bruUpCNifS3O0UhTf5b1o14G7I)KpAQzeCltaTabNYobbk7jzDQPAquXDZZB8AU(vAZ5O024vdEi5F6paIANwp8OMjTlpBACWQEEVsp7pl5vcA1oIBYMpQCj92nPUPtvooNT(Nq6)KQalZNNV5zhxnwIRylVe0GLtbF)ZMyjG)Fr5mtDQSWNUqPclPnPqqCU(R)G(sFh8hoyqfXuYjmWjZzCrCwK4mAVah3sJ9)xbpykW7VFdhpHTrUcvqaMy(c8dyy74MV4r4OVK5G)9srrx66mJX(OgFroi)hWfqJcb8U7Rlj(8x5)cxmf(Dyz)7cREdxhEKTyXBiiTEtLuUN4utYdBZgmRvXG3SYMN56Vm4ImiutSvoKnyek0tmLwFhFWwBjqwyMedy5zdxcbcwuyKAGkrCNoZp5Kxu)xmqbsSet3pDOsy8PDaf0y4spXuNUiWWvgECm(gHpVGsia90BAACxHLHNHvzahG2B2hcfdz7qQTwYmGXAUJjhAKHrjPbXbjwEAc58LkOmNdyaK0jPttu5sld(4trXpBJ0MDBXnDB4QRc7LeADwHYl4SFaujTYLwZu6feiGuWdKljtIt6AQ9)3GS8jHFSPG52ShPSOOoTo46UAcsHcGTeSV16HS2KW3oRpUGbDx1eNFgAGrXvcqyCa(d]] )


end