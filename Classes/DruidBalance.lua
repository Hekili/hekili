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


    spec:RegisterPack( "Balance", 20220501, [[di1qcgqiHOhHOsxIuuSjsPpPuQrjrDkfLvjrYRqaZIuKBrkWUO4xiQAykfDmeQLrPQNjryAKc6Aik2gPO03qqQXrPsoNerSojIAEiq3tiSpfv9psrvrhuPKwOIkEiIstKuu5IKc1grqYhjfvLgjPOQYjvujRuPWlLisAMKc5MiiQDQuIFskQYqrq4OKIQclvIi1tbPPkrQRQOsTvjIeFfbrglIk2Re(RKgmXHPAXKQhlyYG6YqBwHpJiJwP60QSAsrvvVgHmBsUTqTBr)gy4uYXPuPwUuphPPRQRRKTdIVtPmEeuNxiTEkvmFfz)OUG4Isxaf2FSyl2VP92Vjz2KyJ9eVzjSxdlG(rTWcOwEGiNewan9ySa6CCLNbSaQLhvbC4IsxaLcwDalGU)VfTKjp51DLNbudOxCWq6(9LU5aKFoUYZaQbqVyYs(yyZ(hR0854uye6UYZaAEc)fq1xN6NRSqVakS)yXwSFt7TFtYSjXg7jEZsqCjPaQV(Dqxaf6ft2cO7hmmMf6fqHrAOa6CCLNbKfnxVoyEJTA1NIf7TlnXI9BAV98g8gKD3tsiTK5n0aw2kmmcZcuGYBwMd6XgEdnGfYU7jjeML3Bs4xVblbNIuwEalHObfwFVjHp1WBObSusJXaiimlRmXasPEhLfiEFUUcPSu(mOrtSy1iKk99MUAsilAW8Sy1ied99MUAs4mdVHgWYwHaoywSAm40)ssSqi1(VZYny5(TPS87il2AqsIfnoOolkA4n0awiKDIqwiliHaicz53rwGAD99uwCwu3)kKLyqJSmuiHpDfYs5BWsuWILDho3(zz)EwUNf6fVuVNiyrvrzX297SmhnVTwAwialKfvi9pxXYwvhPmgZxtSC)2WSqj6SMz4n0awiKDIqwIb0NLThhP9V2ySFjDBwObm9(auwCllvuwEal6akLLXrA)PSasvudVHgWsPB0FwknigzbmyzokFNL5O8DwMJY3zXPS4SqTWW5kw((sIW3WBObSO5zHj2Su(mOrtSqi1(VRjwiKA)31elqFVhxJZyj2HrwIbnYsJ0tDy(S8awqVvh2SeaX6(Rb0373WBObSqOocZsj1lHBeMfno2cyd7ymFwc7yGiwgGMfYQ5yzrDsOH3qdyPKgJbqqwG71bBsqnatzjSJbIOgEdEJTMj49hHzzoUYZaYYwjeAelbpzrhzzawjml(ZY()w0sM8Kx3vEgqnGEXbdP73x6Mdq(54kpdOga9Ijl5JHn7FSsZNJtHrO7kpdO5j8xavD0Nwu6cOalmXUO0fBH4IsxaftxxHWfZPaQh(dKfqT1(VxafgPH(S(dKfqjengC6ZI9Sqi1(VZINWS4Sa99MUAsilGKfOLMfB3VZYwos7plekhzXtywMdyRLMfqZc037X1ilGFhBBhflGg67X(8cOLzbdQZIIg1k9UMiHFwMMybdQZIIMlRuGYBwMMybdQZIIMlR6GFNLPjwWG6SOOXZO1ej8ZYmw0YIvJqmeBS1(VZIwwIKfRgHyS3yR9FV4l2I9fLUakMUUcHlMtbup8hilGsFVhxJfqd99yFEb0YSuMLizPxjoanj0O7kpdyfmQUsv)9ljrny66keMLPjwIKLaacME(M8iT)1HJSmnXsKSqTqLQ(EtcFQH(EpCLILiyHywMMyjswExH5Bs)xnsR6UYZaAW01vimlZyzAILYSGb1zrrdfO8UMiHFwMMybdQZIIMlRQv6nlttSGb1zrrZLvDWVZY0elyqDwu04z0AIe(zzglZyrllrYcf)QoixuZFyBVDvT3kuavDjwdWfqjtXxSLsuu6cOy66keUyofq9WFGSak99MUAsyb0qFp2NxaTml9kXbOjHgDx5zaRGr1vQ6VFjjQbtxxHWSOLLaacME(M8iT)1HJSOLfQfQu13Bs4tn037HRuSebleZYmw0YsKSqXVQdYf18h22Bxv7TcfqvxI1aCbuYu8fFbuyC4l1xu6ITqCrPlG6H)azbukq5Dvh94cOy66keUyofFXwSVO0fqX01viCXCkGg67X(8cO)fJSqqwkZI9Sukw8WFG0yR9F3eC6x)lgzHaS4H)aPH(EpUgnbN(1)IrwMvaL(9f(ITqCbup8hilGgCLQ6H)azvD0VaQ6OFn9ySakWctSl(ITuIIsxaftxxHWfZPakWQakf)cOE4pqwafI3NRRWcOqC1clGsTqLQ(EtcFQH(EpCLIL5zHyw0YszwIKL3vy(g67Tc0WgmDDfcZY0elVRW8n0hvkVRW9nEdMUUcHzzglttSqTqLQ(EtcFQH(EpCLIL5zX(cOWin0N1FGSaku8PSSvGgZcizPeeGfB3VdwplW9nEw8eMfB3VZc03BfOHzXtywSNaSa(DSTDuSakeVRPhJfqpA1byXxSfnSO0fqX01viCXCkGcSkGsXVaQh(dKfqH4956kSakexTWcOuluPQV3KWNAOV3JRrwMNfIlGcJ0qFw)bYcOqXNYsqHoeKfB7yYc037X1ilbpzz)EwSNaS8EtcFkl22VWolhLLgviepFwgGMLFhzrJdQZIIS8aw0rwSACGDJWS4jml22VWolJtPWMLhWsWPFbuiExtpglGE0AqHoeS4l2czkkDbumDDfcxmNcOaRcOu8lG6H)azbuiEFUUclGcXvlSaQvJqQKcWgInXaqoUgzzAIfRgHujfGneBORCCnYY0elwncPskaBi2qFVPRMeYY0elwncPskaBi2qFVhUsXY0elwncPskaBi2mwD0kyur1krwMMyXQriM2HGjyrRJgt7eLLPjw0xJHj41ldMgJ9lPSebl6RXWe86Lbd8Q9)ajlttSaX7Z1vO5OvhGfqHrAOpR)azb0skEFUUcz539NLWogiIYYnyjkyXI3ilxYIZcPamlpGfhc4Gz53rwO3V8)ajl22XgzXz57ljcFwWpWYrzzrrywUKfD8THyYsWPpTakeVRPhJfqVSskax8fBrZwu6cOy66keUyofq9WFGSaQo2uSj6ssfqHrAOpR)azb05MISmhSPyt0LKyXFw(DKfmHzbmyHq1yANOSyBhtw2D6JSCuwCDaeKfn7MAgnXIpESzHSGecGiKfB3VZYCaEPzXtywa)o22okYIT73zHSBL8ZvgkGg67X(8cOLzPmlrYsaabtpFtEK2)6WrwMMyjswcaGcgylnbqcbqew)DSsTU(EQzzXY0elrYsVsCaAsOr3vEgWkyuDLQ(7xsIAW01vimlZyrll6RXWe86LbtJX(LuwMNfIjdlAzjswcaiy65BGG5VhTzzAILaacME(giy(7rBw0YI(AmmbVEzWSSyrll6RXW0oemblAD0yANOMLflAzPml6RXW0oemblAD0yANOMgJ9lPSqWiyHy7zrdyrdzPuS0RehGMeAOxowQ6Eu6J95gmDDfcZY0el6RXWe86LbtJX(LuwiiletmlttSqmlKNfQfQu1DN(ileKLYSqSPKWIgWY7kmFd9rLY76q5nAW01vimlLILnneZIgWcCVoydmQ8OvDSPyt0LKyPuSSPPeSmJLzSmJfTSaX7Z1vO5YkPaCXxSfcDrPlGIPRRq4I5uan03J95fqlZI(AmmbVEzW0ySFjLL5zHyYWIwwkZsKS0RehGMeAOxowQ6Eu6J95gmDDfcZY0el6RXW0oemblAD0yANOMgJ9lPSqqwiUKWIww0xJHPDiycw06OX0ornllwMXY0el6akLfTSmos7FTXy)skleKf7jdlZyrllq8(CDfAUSskaxafgPH(S(dKfqjeGNfB3VZIZcz3k5NRmWYV7plhn3(zXzHqSuuVzXQbbwanl22XKLFhzzCK2FwoklUoy9S8awWeUaQh(dKfqTa)bYIVyl2vrPlGIPRRq4I5uafyvaLIFbup8hilGcX7Z1vybuiUAHfqd4PyPmlLzzCK2)AJX(Luw0awiMmSObSeaafmWwAcE9YGPXy)sklZyH8SqSDTjlZyzEwc4PyPmlLzzCK2)AJX(Luw0awiMmSObSeaafmWwAcGecGiS(7yLAD99utJX(LuwMXc5zHy7AtwMXIwwIKL2p4kcbZ34WWuds4J(uw0YszwIKLaaOGb2stWRxgmn6WrzzAILizjaakyGT0eajeary93Xk1667PMgD4OSmJLPjwcaGcgylnbVEzW0ySFjLL5z5YhBlGYFeUoos7FTXy)sklttS0RehGMeAcOcP)5Qk1667PgmDDfcZIwwcaGcgylnbVEzW0ySFjLL5zPeBYY0elbaqbdSLMaiHaicR)owPwxFp10ySFjLL5z5YhBlGYFeUoos7FTXy)sklAaleVjlttSejlbaem98n5rA)RdhlGcJ0qFw)bYcOK1vHLYFKYITD83XMLf9ssSqwqcbqeYscSXITtPyXvkGnwIcwS8awO)PuSeC6ZYVJSq9yKfpgSYNfWGfYcsiaIqcq2Ts(5kdSeC6tlGcX7A6Xyb0aiHaicRWinAgk(ITuskkDbumDDfcxmNcOaRcOu8lG6H)azbuiEFUUclGcXvlSaAzwEVjHV5VyS(Gk8HSmpletgwMMyP9dUIqW8nomm1CjlZZcz2KLzSOLLYSuMf0UxNLfcBWyROn6QkOHtpdilAzPmlrYsaabtpFdem)9OnlttSeaafmWwAWyROn6QkOHtpdOPXy)skleKfI1SeAwialLzHmSukw6vIdqtcn0lhlvDpk9X(CdMUUcHzzglZyrllrYsaauWaBPbJTI2ORQGgo9mGMgD4OSmJLPjwq7EDwwiSHcwkf()LKQ9spklAzPmlrYsaabtpFtEK2)6WrwMMyjaakyGT0qblLc))ss1EPhTwcnKm21MeBAm2VKYcbzHyI1qwMXY0elLzjaakyGT0OJnfBIUKKPrhoklttSejlThqZ3aLILPjwcaiy65BYJ0(xhoYYmw0YszwIKL3vy(MXQJwbJkQwjAW01vimlttSeaqW0Z3abZFpAZIwwcaGcgylnJvhTcgvuTs00ySFjLfcYcXeZcbyHmSukw6vIdqtcn0lhlvDpk9X(CdMUUcHzzAILizjaGGPNVbcM)E0MfTSeaafmWwAgRoAfmQOALOPXy)skleKf91yycE9YGbE1(FGKfcWcX2ZsPyPxjoanj0y1xmOHpxv9o45fQwlf1BdMUUcHzrdyHy7zzglAzPmlODVolle2Cjn0R31vy1UxE(R4kmc5cilAzjaakyGT0Cjn0R31vy1UxE(R4kmc5cOPXy)skleKfYWYmwMMyPmlLzbT71zzHWg6UddSHWvqRxbJ6d6ymFw0YsaauWaBP5bDmMpcxVKEK2)AjidzkH9eBAm2VKYYmwMMyPmlLzbI3NRRqdiRlkw)(sIWNLiyHywMMybI3NRRqdiRlkw)(sIWNLiyPeSmJfTSuMLVVKi8npXMgD4O1aaOGb2swMMy57ljcFZtSjaakyGT00ySFjLL5z5YhBlGYFeUoos7FTXy)sklAaleVjlZyzAIfiEFUUcnGSUOy97ljcFwIGf7zrllLz57ljcFZBVPrhoAnaakyGTKLPjw((sIW382BcaGcgylnng7xszzEwU8X2cO8hHRJJ0(xBm2VKYIgWcXBYYmwMMybI3NRRqdiRlkw)(sIWNLiyztwMXYmwMvafgPH(S(dKfqNBkcZYdybgvEuw(DKLf1jHSagSq2Ts(5kdSyBhtww0ljXcmyPRqwajllkYINWSy1iemFwwuNeYITDmzXtwCyywqiy(SCuwCDW6z5bSaFybuiExtpglGgGRbqcF)bYIVyleVzrPlGIPRRq4I5uafyvaLIFbup8hilGcX7Z1vybuiUAHfqJKfkyP0Ve2879PuvkIeHTbtxxHWSmnXY4iT)1gJ9lPSmpl2V5MSmnXIoGszrllJJ0(xBm2VKYcbzXEYWcbyPmlA4MSObSOVgdZV3NsvPise2g67bIyPuSyplZyzAIf91yy(9(uQkfrIW2qFpqelZZsjSlw0awkZsVsCaAsOHE5yPQ7rPp2NBW01vimlLIf7zzwbuyKg6Z6pqwaTKI3NRRqwwueMLhWcmQ8OS4zuw((sIWNYINWSeGPSyBhtwS53FjjwgGMfpzrJxw7G(CwSAqOakeVRPhJfq)9(uQkfrIWUAZVV4l2cXexu6cOy66keUyofqHrAOpR)azb05MISOXXwrB0vSO51WPNbKf73KIbkl64a0ilolKDRKFUYallkYcOzHcy539NL7zX2PuSOUezzzXIT73z53rwWeMfWGfcvJPDIwan9ySakgBfTrxvbnC6zalGg67X(8cObaqbdSLMGxVmyAm2VKYcbzX(nzrllbaqbdSLMaiHaicR)owPwxFp10ySFjLfcYI9BYIwwkZceVpxxHMFVpLQsrKiSR287zzAIf91yy(9(uQkfrIW2qFpqelZZsj2KfcWszw6vIdqtcn0lhlvDpk9X(CdMUUcHzPuSucwMXYmw0YceVpxxHMlRKcWSmnXIoGszrllJJ0(xBm2VKYcbzPee6cOE4pqwafJTI2ORQGgo9mGfFXwi2(IsxaftxxHWfZPakmsd9z9hilGo3uKfOGLsH)LKyPKEPhLfnlfduw0XbOrwCwi7wj)CLbwwuKfqZcfWYV7pl3ZITtPyrDjYYYIfB3VZYVJSGjmlGbleQgt7eTaA6XybukyPu4)xsQ2l9Ofqd99yFEb0YSeaafmWwAcE9YGPXy)skleKfnllAzjswcaiy65BGG5VhTzrllrYsaabtpFtEK2)6WrwMMyjaGGPNVjps7FD4ilAzjaakyGT0eajeary93Xk1667PMgJ9lPSqqw0SSOLLYSaX7Z1vOjasiaIWkmsJMbwMMyjaakyGT0e86LbtJX(LuwiilAwwMXY0elbaem98nqW83J2SOLLYSejl9kXbOjHg6LJLQUhL(yFUbtxxHWSOLLaaOGb2stWRxgmng7xszHGSOzzzAIf91yyAhcMGfToAmTtutJX(LuwiileVjleGLYSqgwkflODVolle2Cj97v4bnTcFqUeR6OsXYmw0YI(AmmTdbtWIwhnM2jQzzXYmwMMyrhqPSOLLXrA)Rng7xszHGSypzyzAIf0UxNLfcBWyROn6QkOHtpdilAzjaakyGT0GXwrB0vvqdNEgqtJX(LuwMNf73KLzSOLfiEFUUcnxwjfGzrllrYcA3RZYcHnxsd96DDfwT7LN)kUcJqUaYY0elbaqbdSLMlPHE9UUcR29YZFfxHrixanng7xszzEwSFtwMMyrhqPSOLLXrA)Rng7xszHGSy)Mfq9WFGSakfSuk8)ljv7LE0IVylexIIsxaftxxHWfZPakWQakf)cOE4pqwafI3NRRWcOqC1clGQVgdtWRxgmng7xszzEwiMmSOLLYSejl9kXbOjHg6LJLQUhL(yFUbtxxHWSmnXI(AmmTdbtWIwhnM2jQPXy)sklemcwiMmgYWcbyPmlLWqgwkfl6RXWORaay1I(MLflZyHaSuMfn0qgw0awkHHmSukw0xJHrxbaWQf9nllwMXsPybT71zzHWMlPFVcpOPv4dYLyvhvkwialAOHmSukwkZcA3RZYcHn)owhxt)k9iDkw0YsaauWaBP53X64A6xPhPtzAm2VKYcbJGf73KLzSOLf91yyAhcMGfToAmTtuZYILzSmnXIoGszrllJJ0(xBm2VKYcbzXEYWY0elODVolle2GXwrB0vvqdNEgqw0YsaauWaBPbJTI2ORQGgo9mGMgJ9lPfqHrAOpR)azb0TQS5rPSSOilZLMp0CSy7(Dwi7wj)CLbwanl(ZYVJSGjmlGbleQgt7eTakeVRPhJfqp7gUgaj89hil(ITqSgwu6cOy66keUyofq9WFGSa6L0qVExxHv7E55VIRWiKlGfqd99yFEbuiEFUUcnNDdxdGe((dKSOLfiEFUUcnxwjfGlGMEmwa9sAOxVRRWQDV88xXvyeYfWIVyletMIsxaftxxHWfZPakmsd9z9hilGo3uKfO7omWgcZIMxRZIooanYcz3k5NRmuan9ySakD3Hb2q4kO1RGr9bDmMFb0qFp2NxaTmlbaqbdSLMGxVmyA0HJYIwwIKLaacME(M8iT)1HJSOLfiEFUUcn)EFkvLIiryxT53ZIwwkZsaauWaBPrhBk2eDjjtJoCuwMMyjswApGMVbkflZyzAILaacME(M8iT)1HJSOLLaaOGb2staKqaeH1FhRuRRVNAA0HJYIwwkZceVpxxHMaiHaicRWinAgyzAILaaOGb2stWRxgmn6WrzzglZyrllWG3qx54A08xGOljXIwwkZcm4n0hvkVRdL3O5VarxsILPjwIKL3vy(g6JkL31HYB0GPRRqywMMyHAHkv99Me(ud99ECnYY8SucwMXIwwGbVjgaYX1O5VarxsIfTSuMfiEFUUcnhT6aKLPjw6vIdqtcn6UYZawbJQRu1F)ssudMUUcHzzAIfN(TRQwaByZY8rWsjztwMMybI3NRRqtaKqaeHvyKgndSmnXI(Amm6kaawTOVzzXYmw0YsKSG296SSqyZL0qVExxHv7E55VIRWiKlGSmnXcA3RZYcHnxsd96DDfwT7LN)kUcJqUaYIwwcaGcgylnxsd96DDfwT7LN)kUcJqUaAAm2VKYY8SuInzrllrYI(AmmbVEzWSSyzAIfDaLYIwwghP9V2ySFjLfcYIgUzbup8hilGs3DyGneUcA9kyuFqhJ5x8fBHynBrPlGIPRRq4I5uafgPH(S(dKfql9(rz5OS4S0(VJnlOY1bT)il28OS8awIDIqwCLIfqYYIISqF)z57ljcFklpGfDKf1LimlllwSD)olKDRKFUYalEcZczbjearilEcZYIIS87il2NWSqvGNfqYsaMLBWIo43z57ljcFklEJSaswwuKf67plFFjr4tlGg67X(8cOq8(CDfAazDrX63xse(SezeSqmlAzjsw((sIW382BA0HJwdaGcgylzzAILYSaX7Z1vObK1ffRFFjr4ZseSqmlttSaX7Z1vObK1ffRFFjr4ZseSucwMXIwwkZsaabtpFdem)9OnlAzrFngMGxVmywwSOLLYSOVgdt7qWeSO1rJPDIAAm2VKYcbyPmlAOHmSukw6vIdqtcn0lhlvDpk9X(CdMUUcHzzglemcw((sIW38eB0xJrfE1(FGKfTSOVgdt7qWeSO1rJPDIAwwSmnXI(AmmTdbtWIwhnM2jALE5yPQ7rPp2NBwwSmJLPjwcaGcgylnbVEzW0ySFjLfcWcXKHL5z57ljcFZtSjaakyGT0aVA)pqYIwwkZsKS0RehGMeAS6lg0WNRQEh88cvRLI6TbtxxHWSmnXI(AmmbVEzW0ySFjLL5zrZYY0elbaqbdSLMGxVmyAm2VKYIgWY3xse(MNytaauWaBPbE1(FGKfcYcXKHLzSOLLYSejlbaem98nqW83J2SmnXsKSOVgdt7qWeSO1rJPDIAwwSOLLaaOGb2st7qWeSO1rJPDIAAm2VKYYmw0YszwIKLaacME(M8iT)1HJSmnXY3xse(MNytaauWaBPbE1(FGKL5zjaakyGT0eajeary93Xk1667PMgJ9lPSmnXceVpxxHMaiHaicRWinAgyrllFFjr4BEInbaqbdSLg4v7)bswMNLaaOGb2stWRxgmng7xszzglAzjswcaiy65BikAFEYY0elbaem98n5rA)Rdhzrllq8(CDfAcGecGiScJ0OzGfTSeaafmWwAcGecGiS(7yLAD99uZYIfTSejlbaqbdSLMGxVmywwSOLLYSuMf91yyWG6SOyvTsVnng7xszzEwidlttSOVgddguNffRuGYBtJX(LuwMNfYWYmwMXY0el6RXWq0LWncxXylGnSJX8RyInPZoOzzXYmwMMyrhqPSOLLXrA)Rng7xszHGSy)MSmnXceVpxxHgqwxuS(9LeHplrWYMfqPkWtlG(9LeHpXfq9WFGSa63xse(ex8fBHycDrPlGIPRRq4I5ua1d)bYcOFFjr4BFb0qFp2NxafI3NRRqdiRlkw)(sIWNLiJGf7zrllrYY3xse(MNytJoC0AaauWaBjlttSaX7Z1vObK1ffRFFjr4ZseSyplAzPml6RXWe86LbZYIfTSeaqW0Z3abZFpAZIwwkZI(AmmTdbtWIwhnM2jQPXy)skleGLYSOHgYWsPyPxjoanj0qVCSu19O0h7Zny66keMLzSqWiy57ljcFZBVrFngv4v7)bsw0YI(AmmTdbtWIwhnM2jQzzXY0el6RXW0oemblAD0yANOv6LJLQUhL(yFUzzXYmwMMyjaakyGT0e86LbtJX(LuwialetgwMNLVVKi8nV9MaaOGb2sd8Q9)ajlAzPmlrYsVsCaAsOXQVyqdFUQ6DWZluTwkQ3gmDDfcZY0el6RXWe86LbtJX(LuwMNfnllttSeaafmWwAcE9YGPXy)sklAalFFjr4BE7nbaqbdSLg4v7)bswiiletgwMXIwwkZsKSeaqW0Z3abZFpAZY0elrYI(AmmTdbtWIwhnM2jQzzXIwwcaGcgylnTdbtWIwhnM2jQPXy)sklZyrllLzjswcaiy65BYJ0(xhoYY0elFFjr4BE7nbaqbdSLg4v7)bswMNLaaOGb2staKqaeH1FhRuRRVNAAm2VKYY0elq8(CDfAcGecGiScJ0OzGfTS89LeHV5T3eaafmWwAGxT)hizzEwcaGcgylnbVEzW0ySFjLLzSOLLizjaGGPNVHOO95jlAzPmlrYI(AmmbVEzWSSyzAILizjaGGPNVbcM)E0MLzSmnXsaabtpFtEK2)6Wrw0YceVpxxHMaiHaicRWinAgyrllbaqbdSLMaiHaicR)owPwxFp1SSyrllrYsaauWaBPj41ldMLflAzPmlLzrFnggmOolkwvR0BtJX(LuwMNfYWY0el6RXWGb1zrXkfO820ySFjLL5zHmSmJLzSmJLPjw0xJHHOlHBeUIXwaByhJ5xXeBsNDqZYILPjw0buklAzzCK2)AJX(Luwiil2VjlttSaX7Z1vObK1ffRFFjr4ZseSSzbuQc80cOFFjr4BFXxSfITRIsxaftxxHWfZPakmsd9z9hilGo3uKYIRuSa(DSzbKSSOil3JXuwajlb4cOE4pqwaDrX69ymT4l2cXLKIsxaftxxHWfZPakmsd9z9hilGQX3VJnlKaSC5dy53rwOplGMfhGS4H)ajlQJ(fq9WFGSaAVYQh(dKv1r)cO0VVWxSfIlGg67X(8cOq8(CDfAoA1bybu1r)A6XybuhGfFXwSFZIsxaftxxHWfZPaQh(dKfq7vw9WFGSQo6xavD0VMEmwaL(fFXxa1QXaiw3)IsxSfIlkDbup8hilGs0LWncxPwxFpTakMUUcHlMtXxSf7lkDbumDDfcxmNcOaRcOu8lG6H)azbuiEFUUclGcXvlSa6MfqHrAOpR)azb0sVJSaX7Z1vilhLfk(S8aw2KfB3VZscyH((Zcizzrrw((sIWNQjwiMfB7yYYVJSmUM(SasKLJYcizzrrnXI9SCdw(DKfkgajmlhLfpHzPeSCdw0b)olEJfqH4Dn9ySakiRlkw)(sIWV4l2sjkkDbumDDfcxmNcOaRcOomCbup8hilGcX7Z1vybuiUAHfqjUaAOVh7ZlG(9LeHV5j2S706IIv91yWIww((sIW38eBcaGcgylnWR2)dKSOLLiz57ljcFZtS5OMheJvWOgds63GfTgaj97v4pqslGcX7A6XybuqwxuS(9LeHFXxSfnSO0fqX01viCXCkGcSkG6WWfq9WFGSakeVpxxHfqH4Qfwa1(cOH(ESpVa63xse(M3EZUtRlkw1xJblAz57ljcFZBVjaakyGT0aVA)pqYIwwIKLVVKi8nV9MJAEqmwbJAmiPFdw0AaK0VxH)ajTakeVRPhJfqbzDrX63xse(fFXwitrPlGIPRRq4I5uafyva1HHlG6H)azbuiEFUUclGcX7A6XybuqwxuS(9LeHFb0qFp2NxafT71zzHWMlPHE9UUcR29YZFfxHrixazzAIf0UxNLfcBWyROn6QkOHtpdilttSG296SSqydfSuk8)ljv7LE0cOWin0N1FGSaAP3rkYY3xse(uw8gzjbpl(6bX(FbxPIYcm(y4rywCklGKLffzH((ZY3xse(udlSafFwG4956kKLhWIgYItz53XOS4kkGLerywOwy4Cfl7EcRUKKPakexTWcOAyXxSfnBrPlGIPRRq4I5uafyvaLIFbup8hilGcX7Z1vybuiUAHfqlXMSukwkZcXSObSSPHyYWsPyHIFvhKlQ5pST3UQAOvGLzfqHrAOpR)azbuO4tz53rwG(EtxnjKLaG(Smanlk)XMLGRclL)hiPSuEaAwqc7XwkKfB7yYYdyH(E)SaVITUKel64a0ileQgt7eLLHRuuwaJXScOq8UMEmwaLsRba9l(ITqOlkDbumDDfcxmNcOaRcOu8lG6H)azbuiEFUUclGcXvlSakz2KLsXszwiMfnGLnnetgwkflu8R6GCrn)HT92vvdTcSmRakeVRPhJfqPJAaq)IVyl2vrPlGIPRRq4I5uafyvaLIFbup8hilGcX7Z1vybuiUAHfqlXMSqawiEtwkfl9kXbOjHMaQq6FUQsTU(EQbtxxHWfqHrAOpR)azbuO4tzXFwSTFHDw8yWkFwadw2kLqWczbjearil0DWsbZIoYYIIWLmlA4MSy7(DW6zHSOcP)5kwGAD99uw8eMLsSjl2UF3uafI310JXcObqcbqewDQvXxSLssrPlG6H)azb0yaij6Y6a0XfqX01viCXCk(ITq8MfLUakMUUcHlMtbup8hilGAR9FVaAOVh7ZlGwMfmOolkAuR07AIe(zzAIfmOolkAUSsbkVzzAIfmOolkAUSQd(DwMMybdQZIIgpJwtKWplZkGQUeRb4cOeVzXx8fqDawu6ITqCrPlGIPRRq4I5uafyvaLIFbup8hilGcX7Z1vybuiUAHfq7vIdqtcn)fJ2aDwHB0J1VegBdMUUcHzrllLzrFngM)IrBGoRWn6X6xcJTPXy)skleKfsbytStywialBAiMLPjw0xJH5Vy0gOZkCJES(LWyBAm2VKYcbzXd)bsd99ECnAqcJH1J1)IrwialBAiMfTSuMfmOolkAUSQwP3SmnXcguNffnuGY7AIe(zzAIfmOolkA8mAnrc)SmJLzSOLf91yy(lgTb6Sc3OhRFjm2MLvbuyKg6Z6pqwaLSUkSu(JuwSTJ)o2S87ilAUg94G)HDSzrFngSy7ukwgUsXcymyX297xYYVJSKiHFwco9lGcX7A6Xybu4g94QTtPQdxPQGXO4l2I9fLUakMUUcHlMtbuGvbuk(fq9WFGSakeVpxxHfqH4QfwanswWG6SOO5YkfO8MfTSqTqLQ(EtcFQH(EpUgzzEwi0SObS8UcZ3qblvfmQ)owhGgPVbtxxHWSukwSNfcWcguNffnxw1b)olAzjsw6vIdqtcnw9fdA4ZvvVdEEHQ1sr92GPRRqyw0YsKS0RehGMeAaj(70AqHExHC0dKgmDDfcxafgPH(S(dKfqjRRclL)iLfB74VJnlqFVPRMeYYrzXgO)Dwco9VKelaiyZc037X1ilxYIgTsVzrJdQZIIfqH4Dn9ySa6rkbnwPV30vtcl(ITuIIsxaftxxHWfZPaQh(dKfqdGecGiS(7yLAD990cOWin0N1FGSa6CtrwiliHaiczX2oMS4plkKsz539KfYSjlBLsiyXtywuxISSSyX297Sq2Ts(5kdfqd99yFEb0YSuMfiEFUUcnbqcbqewHrA0mWIwwIKLaaOGb2stWRxgmn6WrzrllrYsVsCaAsOXQVyqdFUQ6DWZluTwkQ3gmDDfcZY0el6RXWe86LbZYIfTSuMLizPxjoanj0y1xmOHpxv9o45fQwlf1BdMUUcHzzAILEL4a0Kqtavi9pxvPwxFp1GPRRqywMMyzCK2)AJX(LuwMNfITNqZY0el6akLfTSmos7FTXy)skleKLaaOGb2stWRxgmng7xszHaSq8MSmnXI(AmmbVEzW0ySFjLL5zHy7zzglZyrllLzPmlLzXPF7QQfWg2SqWiybI3NRRqtaKqaeHvNAXY0eluluPQV3KWNAOV3JRrwMNLsWYmw0Yszw0xJHbdQZIIv1k920ySFjLL5zH4nzzAIf91yyWG6SOyLcuEBAm2VKYY8Sq8MSmJLPjw0xJHj41ldMgJ9lPSmplKHfTSOVgdtWRxgmng7xszHGrWcX2ZYmw0YszwIKL3vy(g6JkL3v4(gVbtxxHWSmnXI(Amm037HRuMgJ9lPSqqwi2qgw0aw20qgwkfl9kXbOjHMaQq6FUQsTU(EQbtxxHWSmnXI(AmmbVEzW0ySFjLfcYI(Amm037HRuMgJ9lPSqawidlAzrFngMGxVmywwSmJfTSuMLizPxjoanj08xmAd0zfUrpw)sySny66keMLPjwIKLEL4a0Kqtavi9pxvPwxFp1GPRRqywMMyrFngM)IrBGoRWn6X6xcJTPXy)sklZZcsymSES(xmYYmwMMyPxjoanj0O7kpdyfmQUsv)9ljrny66keMLzSOLLYSejl9kXbOjHgDx5zaRGr1vQ6VFjjQbtxxHWSmnXszw0xJHr3vEgWkyuDLQ(7xsIwt)xnAOVhiILiyXUyzAIf91yy0DLNbScgvxPQ)(LKOvVdEIg67bIyjcwSlwMXYmwMMyrhqPSOLLXrA)Rng7xszHGSq8MSOLLizjaakyGT0e86LbtJoCuwMv8fBrdlkDbumDDfcxmNcOE4pqwaLUYX1yb0q0GcRV3KWNwSfIlGg67X(8cOLzPXrJ0DxxHSmnXI(AmmyqDwuSsbkVnng7xszHGSucw0YcguNffnxwPaL3SOLLgJ9lPSqqwiwdzrllVRW8nuWsvbJ6VJ1bOr6BW01vimlZyrllV3KW38xmwFqf(qwMNfI1qw0awOwOsvFVjHpLfcWsJX(Luw0YszwWG6SOO5YQNrzzAILgJ9lPSqqwifGnXoHzzwbuyKg6Z6pqwaDUPilqx54AKLlzXYtym(cSasw8m6VFjjw(D)zrDqqkleRHumqzXtywuiLYIT73zjg0ilV3KWNYINWS4pl)oYcMWSagS4SafO8MfnoOolkYI)SqSgYcfduwanlkKszPXy)YljXItz5bSKGNLDhYLKy5bS04Or6olWR(ssSOrR0Bw04G6SOyXxSfYuu6cOy66keUyofqHrAOpR)azbucj)EwCwOXUsXsmigZNfF8yZcHQX0orzX2oMS46G1ZYdyzrrw8KLlPVNFbukgkGUPHyYWIgWIh(dKM2HGjyrRJgt7e18xmwPxgWcOE4pqwa1MFFb0qFp2NxanaGGPNVbcM)E0MfTSy1iedXM2HGjyrRJgt7eLfTS4H)aPPDiycw06OX0orn)fJv6LbKfcYYMgIjdlAzPmlrYc99ECnACRAyhdeXY0elVRW8n0hvkVRW9nEdMUUcHzrllbaqbdSLg679WvktJoCuwMMyrFngg679WvktJJgP7UUczzwXxSfnBrPlGIPRRq4I5ua1d)bYcO0voUglGcJ0qFw)bYcOZnfzb6khxJS8aw2DiilolKuaDxXYdyzrrwMlnFO5kGg67X(8cOq8(CDfAo7gUgaj89hizrllbaqbdSLMlPHE9UUcR29YZFfxHrixann6WrzrllODVolle2Cjn0R31vy1UxE(R4kmc5cilAzXTQHDmquXxSfcDrPlGIPRRq4I5ua1d)bYcO037HRufqHrAOpR)azb0sQiAXYYIfOV3dxPyXFwCLIL)IrklRuHukll6LKyrJIg82PS4jml3ZYrzX1bRNLhWIvdcSaAwu4ZYVJSqTWW5kw8WFGKf1Lil6OcyJLDpHvilAUg9y9lHXMfqYI9S8EtcFAb0qFp2NxanswExH5BOpQuExH7B8gmDDfcZIwwkZsKSqXVQdYf18h22Bxvn0kWY0elyqDwu0Cz1ZOSmnXc1cvQ67nj8Pg679WvkwMNLsWYmw0Yszw0xJHH(EpCLY04Or6URRqw0YszwOwOsvFVjHp1qFVhUsXcbzPeSmnXsKS0RehGMeA(lgTb6Sc3OhRFjm2gmDDfcZYmwMMy5DfMVHcwQkyu)DSoansFdMUUcHzrll6RXWGb1zrXkfO820ySFjLfcYsjyrllyqDwu0CzLcuEZIww0xJHH(EpCLY0ySFjLfcYcHMfTSqTqLQ(EtcFQH(EpCLIL5JGfnKLzSOLLYSejl9kXbOjHgv0G3oToui(xsQssDXwu0GPRRqywMMy5VyKfndlAizyzEw0xJHH(EpCLY0ySFjLfcWI9SmJfTS8EtcFZFXy9bv4dzzEwitXxSf7QO0fqX01viCXCkG6H)azbu679WvQcOWin0N1FGSakH097Sa9rLYBw0C9nEwwuKfqYsaMfB7yYsJJgP7UUczrF9Sq)tPyXMFpldqZIgfn4TtzXQbbw8eMfyqU9ZYIISOJdqJSqwnh1Wc0)ukwwuKfDCaAKfYcsiaIqwOxgqw(D)zX2PuSy1GalEc(DSzb679WvQcOH(ESpVa67kmFd9rLY7kCFJ3GPRRqyw0YI(Amm037HRuMghns3DDfYIwwkZsKSqXVQdYf18h22Bxvn0kWY0elyqDwu0Cz1ZOSmnXc1cvQ67nj8Pg679WvkwMNLsWYmw0YszwIKLEL4a0KqJkAWBNwhke)ljvjPUylkAW01vimlttS8xmYIMHfnKmSmplAilZyrllJJ0(xBm2VKYY8SuIIVylLKIsxaftxxHWfZPaQh(dKfqPV3dxPkGcJ0qFw)bYcOes3VZIMRrpw)sySzzrrwG(EpCLILhWcriAXYYILFhzrFngSOhLfxrbSSOxsIfOV3dxPybKSqgwOyaKWuwanlkKszPXy)Yljvan03J95fq7vIdqtcn)fJ2aDwHB0J1VegBdMUUcHzrlluluPQV3KWNAOV3dxPyz(iyPeSOLLYSejl6RXW8xmAd0zfUrpw)sySnllw0YI(Amm037HRuMghns3DDfYY0elLzbI3NRRqdCJEC12Pu1HRuvWyWIwwkZI(Amm037HRuMgJ9lPSqqwkblttSqTqLQ(EtcFQH(EpCLIL5zXEw0YY7kmFd9rLY7kCFJ3GPRRqyw0YI(Amm037HRuMgJ9lPSqqwidlZyzglZk(ITq8MfLUakMUUcHlMtbuGvbuk(fq9WFGSakeVpxxHfqH4Qfwa1PF7QQfWg2Smpl21MSukwkZcXSObSqXVQdYf18h22Bxv7TcSukw20yplZyPuSuMfIzrdyrFngM)IrBGoRWn6X6xcJTH(EGiwkflBAiMLzSObSuMf91yyOV3dxPmng7xszPuSucwipluluPQ7o9rwkflrYY7kmFd9rLY7kCFJ3GPRRqywMXIgWszwcaGcgyln037HRuMgJ9lPSukwkblKNfQfQu1DN(ilLIL3vy(g6JkL3v4(gVbtxxHWSmJfnGLYSOVgdZy1rRGrfvRenng7xszPuSqgwMXIwwkZI(Amm037HRuMLflttSeaafmWwAOV3dxPmng7xszzwbuyKg6Z6pqwaLSUkSu(JuwSTJ)o2S4Sa99MUAsillkYITtPyj4lkYc037HRuS8awgUsXcym0elEcZYIISa99MUAsilpGfIq0IfnxJES(LWyZc99arSSSmSyxBYYrz53rwA0UxxJWSSvkHGLhWsWPplqFVPRMesaOV3dxPkGcX7A6Xybu679WvQQnq(1HRuvWyu8fBHyIlkDbumDDfcxmNcOE4pqwaL(EtxnjSakmsd9z9hilGo3uKfOV30vtczX297SO5A0J1VegBwEaleHOflllw(DKf91yWIT73bRNffGEjjwG(EpCLILL1FXilEcZYIISa99MUAsilGKfnKaSmhWwlnl03derzzL)Pyrdz59Me(0cOH(ESpVakeVpxxHg4g94QTtPQdxPQGXGfTSaX7Z1vOH(EpCLQAdKFD4kvfmgSOLLizbI3NRRqZrkbnwPV30vtczzAILYSOVgdJUR8mGvWO6kv93VKeTM(VA0qFpqelZZsjyzAIf91yy0DLNbScgvxPQ)(LKOvVdEIg67bIyzEwkblZyrlluluPQV3KWNAOV3dxPyHGSOHSOLfiEFUUcn037HRuvBG8RdxPQGXO4l2cX2xu6cOy66keUyofq9WFGSaQd7w)bbRuBEhxanenOW67nj8PfBH4cOH(ESpVaAKS8xGOljXIwwIKfp8hinoSB9heSsT5DCf2JDsO5Y6qDK2FwMMybg8gh2T(dcwP28oUc7Xoj0qFpqeleKLsWIwwGbVXHDR)GGvQnVJRWEStcnng7xszHGSuIcOWin0N1FGSa6CtrwO28oMfkGLF3FwIcwSqcFwIDcZYY6VyKf9OSSOxsIL7zXPSO8hzXPSybO0txHSaswuiLYYV7jlLGf67bIOSaAw08FrFwSTJjlLGaSqFpqeLfKWwxJfFXwiUefLUakMUUcHlMtbup8hilGgda54ASaAiAqH13Bs4tl2cXfqd99yFEb0ghns3DDfYIwwEVjHV5VyS(Gk8HSmplLzPmleRHSqawkZc1cvQ67nj8Pg6794AKLsXI9Sukw0xJHbdQZIIv1k92SSyzglZyHaS0ySFjLLzSqEwkZcXSqawExH5BEBxwJbGKAW01vimlZyrllo9BxvTa2WML5zbI3NRRqdDuda6ZIgWI(Amm037HRuMgJ9lPSukw0SSOLLYS4w1WogiILPjwG4956k0CKsqJv67nD1KqwMMyjswWG6SOO5YQNrzzglAzPmlbaqbdSLMGxVmyA0HJYIwwWG6SOO5YQNrzrllLzbI3NRRqtaKqaeHvyKgndSmnXsaauWaBPjasiaIW6VJvQ113tnn6WrzzAILizjaGGPNVjps7FD4ilZyzAIfQfQu13Bs4tn037X1ileKLYSuMf7IfnGLYSOVgddguNffRQv6TzzXsPyPeSmJLzSukwkZcXSqawExH5BEBxwJbGKAW01vimlZyzglAzjswWG6SOOHcuExtKWplAzPmlrYsaauWaBPj41ldMgD4OSmJLPjwkZcguNffnxwPaL3SmnXI(AmmyqDwuSQwP3MLflAzjswExH5BOGLQcg1FhRdqJ03GPRRqywMXIwwkZc1cvQ67nj8Pg6794AKfcYcXBYsPyPmleZcby5DfMV5TDzngasQbtxxHWSmJLzSmJfTSuMLizjaGGPNVHOO95jlttSejl6RXWq0LWncxXylGnSJX8RyInPZoOzzXY0elyqDwu0CzLcuEZYmw0YsKSOVgdt7qWeSO1rJPDIwPxowQ6Eu6J95MLvbuyKg6Z6pqwaTKghns3zHqgaYX1il3GfYUvYpxzGLJYsJoCunXYVJnYI3ilkKsz539KfYWY7nj8PSCjlA0k9MfnoOolkYIT73zbk4juAIffsPS87EYcXBYc43X22rrwUKfpJYIghuNffzb0SSSy5bSqgwEVjHpLfDCaAKfNfnALEZIghuNffnSO5a52plnoAKUZc8QVKelLuVeUryw04ylGnSJX8zzLkKsz5swGcuEZIghuNffl(ITqSgwu6cOy66keUyofq9WFGSa6a0bScg10)vJfqHrAOpR)azb05MISqOaBHfqYsaMfB3Vdwplb3Y6ssfqd99yFEbu3Qg2XarSmnXceVpxxHMJucASsFVPRMew8fBHyYuu6cOy66keUyofqbwfqP4xa1d)bYcOq8(CDfwafIRwyb0YSaX7Z1vOjaxdGe((dKSOLLYSOVgdd99E4kLzzXY0elVRW8n0hvkVRW9nEdMUUcHzzAILaacME(M8iT)1HJSmJfTSadEtmaKJRrZFbIUKelAzPmlrYI(AmmuGI(xanllw0YsKSOVgdtWRxgmllw0YszwIKL3vy(MXQJwbJkQwjAW01vimlttSOVgdtWRxgmWR2)dKSmplbaqbdSLMXQJwbJkQwjAAm2VKYcbyXUyzglAzPmlrYcf)QoixuZFyBVDvT3kWY0elyqDwu0CzvTsVzzAIfmOolkAOaL31ej8ZYmw0YceVpxxHMFVpLQsrKiSR287zrllLzjswcaiy65BYJ0(xhoYY0elq8(CDfAcGecGiScJ0OzGLPjwcaGcgylnbqcbqew)DSsTU(EQPXy)skleKfIjdlZyrllV3KW38xmwFqf(qwMNf91yycE9YGbE1(FGKLsXYMgcnlZyzAIfDaLYIwwghP9V2ySFjLfcYI(AmmbVEzWaVA)pqYcbyHy7zPuS0RehGMeAS6lg0WNRQEh88cvRLI6TbtxxHWSmRakeVRPhJfqdW1aiHV)az1byXxSfI1SfLUakMUUcHlMtbup8hilG2oemblAD0yANOfqHrAOpR)azb05MISqOAmTtuwSD)olKDRKFUYqb0qFp2NxavFngMGxVmyAm2VKYY8SqmzyzAIf91yycE9YGbE1(FGKfcWcX2ZsPyPxjoanj0y1xmOHpxv9o45fQwlf1BdMUUcHzHGSyVMLfTSaX7Z1vOjaxdGe((dKvhGfFXwiMqxu6cOy66keUyofq9WFGSaAavi9pxvD1rkJX8lGcJ0qFw)bYcOZnfzHSBL8ZvgybKSeGzzLkKszXtywuxISCplllwSD)olKfKqaeHfqd99yFEbuiEFUUcnb4AaKW3FGS6aKfTSuMLizjaGGPNVbcM)E0MLPjwIKLEL4a0Kqd9YXsv3JsFSp3GPRRqywMMyPxjoanj0y1xmOHpxv9o45fQwlf1BdMUUcHzzAIf91yycE9YGbE1(FGKL5JGf71SSmJLPjw0xJHPDiycw06OX0ornllw0YI(AmmTdbtWIwhnM2jQPXy)skleKfIjJHmfFXwi2UkkDbumDDfcxmNcOH(ESpVakeVpxxHMaCnas47pqwDawa1d)bYcOxg8o9)azXxSfIljfLUakMUUcHlMtbup8hilGIXwaByx1bjCbuyKg6Z6pqwaDUPilACSfWg2SmhqcZcizjaZIT73zb679WvkwwwS4jmluhcYYa0SqiwkQ3S4jmlKDRKFUYqb0qFp2NxaTmlbaqbdSLMGxVmyAm2VKYcbyrFngMGxVmyGxT)hizHaS0RehGMeAS6lg0WNRQEh88cvRLI6TbtxxHWSukwi2EwMNLaaOGb2sdgBbSHDvhKWg4v7)bswialeVjlZyzAIf91yycE9YGPXy)sklZZIDv8fBX(nlkDbumDDfcxmNcOE4pqwaL(Os5DDO8glGgIguy99Me(0ITqCb0qFp2NxaTXrJ0DxxHSOLL)IX6dQWhYY8SqmzyrlluluPQV3KWNAOV3JRrwiilAilAzXTQHDmqelAzPml6RXWe86LbtJX(LuwMNfI3KLPjwIKf91yycE9YGzzXYScOWin0N1FGSaAjnoAKUZYq5nYcizzzXYdyPeS8EtcFkl2UFhSEwi7wj)CLbw0XljXIRdwplpGfKWwxJS4jmlj4zbab7GBzDjPIVyl2tCrPlGIPRRq4I5ua1d)bYcOJvhTcgvuTsSakmsd9z9hilGo3uKfcfqJz5gSCj9Grw8KfnoOolkYINWSOUez5EwwwSy7(DwCwielf1BwSAqGfpHzzRWU1FqqwGAZ74cOH(ESpVakguNffnxw9mklAzPmlUvnSJbIyzAILizPxjoanj0y1xmOHpxv9o45fQwlf1BdMUUcHzzglAzPml6RXWy1xmOHpxv9o45fQwlf1BdexTqwiil2tMnzzAIf91yycE9YGPXy)sklZZIDXYmw0YszwGbVXHDR)GGvQnVJRWEStcn)fi6ssSmnXsKSeaqW0Z3KyObkqdZY0eluluPQV3KWNYY8SyplZyrllLzrFngM2HGjyrRJgt7e10ySFjLfcYsjHfnGLYSOHSukw6vIdqtcn0lhlvDpk9X(CdMUUcHzzglAzrFngM2HGjyrRJgt7e1SSyzAILizrFngM2HGjyrRJgt7e1SSyzglAzPmlrYsaauWaBPj41ldMLflttSOVgdZV3NsvPise2g67bIyHGSqmzyrllJJ0(xBm2VKYcbzX(n3KfTSmos7FTXy)sklZZcXBUjlttSejluWsPFjS537tPQuejcBdMUUcHzzglAzPmluWsPFjS537tPQuejcBdMUUcHzzAILaaOGb2stWRxgmng7xszzEwkXMSmJfTS8EtcFZFXy9bv4dzzEwidlttSOdOuw0YY4iT)1gJ9lPSqqwiEZIVyl2BFrPlGIPRRq4I5ua1d)bYcO037HRufqHrAOpR)azb05MIS4Sa99E4kflAEj(7Sy1GalRuHuklqFVhUsXYrzXvn6WrzzzXcOzjkyXI3ilUoy9S8awaqWo4wSSvkHOaAOVh7ZlGQVgddiXFNwTWoGw)bsZYIfTSuMf91yyOV3dxPmnoAKU76kKLPjwC63UQAbSHnlZZsjztwMv8fBX(suu6cOy66keUyofq9WFGSak99E4kvbuyKg6Z6pqwavZTITyzRucbl64a0ilKfKqaeHSy7(DwG(EpCLIfpHz53XKfOV30vtclGg67X(8cObaem98n5rA)RdhzrllrYY7kmFd9rLY7kCFJ3GPRRqyw0YszwG4956k0eajearyfgPrZalttSeaafmWwAcE9YGzzXY0el6RXWe86LbZYILzSOLLaaOGb2staKqaeH1FhRuRRVNAAm2VKYcbzHua2e7eMLsXsapflLzXPF7QQfWg2SqEwG4956k0qh1aG(SmJfTSOVgdd99E4kLPXy)skleKfnS4l2I9AyrPlGIPRRq4I5uan03J95fqdaiy65BYJ0(xhoYIwwkZceVpxxHMaiHaicRWinAgyzAILaaOGb2stWRxgmllwMMyrFngMGxVmywwSmJfTSeaafmWwAcGecGiS(7yLAD99utJX(LuwiilKHfTSaX7Z1vOH(EpCLQAdKFD4kvfmgSOLfmOolkAUS6zuw0YsKSaX7Z1vO5iLGgR03B6QjHfq9WFGSak99MUAsyXxSf7jtrPlGIPRRq4I5ua1d)bYcO03B6QjHfqHrAOpR)azb05MISa99MUAsil2UFNfpzrZlXFNfRgeyb0SCdwIcwBdZcac2b3ILTsjeSy7(DwIcwnljs4NLGtFdlBvrbSaVITyzRucbl(ZYVJSGjmlGbl)oYsjfm)9Onl6RXGLBWc037HRuSydSuW52pldxPybmgSaAwIcwS4nYcizXEwEVjHpTaAOVh7ZlGQVgddiXFNwdk07kKJEG0SSyzAILYSejl037X1OXTQHDmqelAzjswG4956k0CKsqJv67nD1KqwMMyPml6RXWe86LbtJX(LuwiilKHfTSOVgdtWRxgmllwMMyPmlLzrFngMGxVmyAm2VKYcbzHua2e7eMLsXsapflLzXPF7QQfWg2SqEwG4956k0qP1aG(SmJfTSOVgdtWRxgmllwMMyrFngM2HGjyrRJgt7eTsVCSu19O0h7Znng7xszHGSqkaBIDcZsPyjGNILYS40VDv1cydBwiplq8(CDfAO0AaqFwMXIww0xJHPDiycw06OX0orR0lhlvDpk9X(CZYILzSOLLaacME(giy(7rBwMXYmw0YszwOwOsvFVjHp1qFVhUsXcbzPeSmnXceVpxxHg679WvQQnq(1HRuvWyWYmwMXIwwIKfiEFUUcnhPe0yL(EtxnjKfTSuMLizPxjoanj08xmAd0zfUrpw)sySny66keMLPjwOwOsvFVjHp1qFVhUsXcbzPeSmR4l2I9A2IsxaftxxHWfZPaQh(dKfqt0wngaYcOWin0N1FGSa6CtrwiKbGKYYLSafO8MfnoOolkYINWSqDiileQLsXcHmaKSmanlKDRKFUYqb0qFp2NxaTml6RXWGb1zrXkfO820ySFjLL5zbjmgwpw)lgzzAILYSe29MeszjcwSNfTS0yy3Bsy9VyKfcYczyzglttSe29MeszjcwkblZyrllUvnSJbIk(ITypHUO0fqX01viCXCkGg67X(8cOLzrFnggmOolkwPaL3MgJ9lPSmpliHXW6X6FXilttSuMLWU3KqklrWI9SOLLgd7EtcR)fJSqqwidlZyzAILWU3KqklrWsjyzglAzXTQHDmqelAzPml6RXW0oemblAD0yANOMgJ9lPSqqwidlAzrFngM2HGjyrRJgt7e1SSyrllrYsVsCaAsOHE5yPQ7rPp2NBW01vimlttSejl6RXW0oemblAD0yANOMLflZkG6H)azb0DxnQXaqw8fBXE7QO0fqX01viCXCkGg67X(8cOLzrFnggmOolkwPaL3MgJ9lPSmpliHXW6X6FXilAzPmlbaqbdSLMGxVmyAm2VKYY8SqMnzzAILaaOGb2staKqaeH1FhRuRRVNAAm2VKYY8SqMnzzglttSuMLWU3KqklrWI9SOLLgd7EtcR)fJSqqwidlZyzAILWU3KqklrWsjyzglAzXTQHDmqelAzPml6RXW0oemblAD0yANOMgJ9lPSqqwidlAzrFngM2HGjyrRJgt7e1SSyrllrYsVsCaAsOHE5yPQ7rPp2NBW01vimlttSejl6RXW0oemblAD0yANOMLflZkG6H)azb0XsPQXaqw8fBX(ssrPlGIPRRq4I5uafgPH(S(dKfqNBkYcHeqJzbKSqwnxbup8hilGAZ7(aDfmQOALyXxSLsSzrPlGIPRRq4I5uafyvaLIFbup8hilGcX7Z1vybuiUAHfqPwOsvFVjHp1qFVhxJSmplAileGLHcaAwkZsStFSJwH4QfYsPyH4n3KfYZI9BYYmwialdfa0SuMf91yyOV30vtcRySfWg2Xy(vkq5TH(EGiwiplAilZkGcJ0qFw)bYcOK1vHLYFKYITD83XMLhWYIISa99ECnYYLSafO8MfB7xyNLJYI)SqgwEVjHpLaeZYa0SGqWokl2VPMHLyN(yhLfqZIgYc03B6QjHSOXXwaByhJ5Zc99ar0cOq8UMEmwaL(EpUgRxwPaL3fFXwkbXfLUakMUUcHlMtbup8hilGAR9FVakmsd9z9hilGQ5LSyplV3KWNYIT73bRNfOGLIfWGLFhzHqbAK(SefSyHUdwkywgNsXIT73zHqQ9FNf4vFjjwMRmuan03J95fqJKf91yyAhcMGfToAmTtuZYIfTSejl6RXW0oemblAD0yANOv6LJLQUhL(yFUzzXIwwIKL3vy(gkyPQGr93X6a0i9ny66keMfTSqTqLQ(EtcFQH(EpUgzHGSucw0YI(AmmyqDwuSsbkVnng7xszzEwqcJH1J1)Irw0YY4iT)1gJ9lPSmpl6RXWe86LbtJX(LuwialeBplLILEL4a0KqJvFXGg(Cv17GNxOATuuVny66keU4l2sjSVO0fqX01viCXCkGcSkGsXVaQh(dKfqH4956kSakexTWcOeZc5zHAHkvD3PpYcbzXEw0awkZYMg7zPuSuMLYSqTqLQ(EtcFQH(EpUgzrdyHywMXc5zPmlLzHAHkv99Me(ud99ECnYIgWcXSmJfYZI9BYcbyHywMXYmwkflLzHywialVRW8nuWsvbJ6VJ1bOr6BW01vimlLIfInKHLzSmJfcWYMgIjdlLIf91yyAhcMGfToAmTtutJX(L0cOWin0N1FGSakzDvyP8hPSyBh)DSz5bSqi1(VZc8QVKeleQgt7eTakeVRPhJfqT1(VxVSoAmTt0IVylLOefLUakMUUcHlMtbup8hilGAR9FVakmsd9z9hilGo3uKfcP2)DwUKfOaL3SOXb1zrrwanl3GLeWc037X1il2oLILX9SC5dyHSBL8ZvgyXZOXGglGg67X(8cOLzbdQZIIg1k9UMiHFwMMybdQZIIgpJwtKWplAzbI3NRRqZrRbf6qqwMXIwwkZY7nj8n)fJ1huHpKL5zrdzzAIfmOolkAuR076Lv7zzAIfDaLYIwwghP9V2ySFjLfcYcXBYYmwMMyrFnggmOolkwPaL3MgJ9lPSqqw8WFG0qFVhxJgKWyy9y9VyKfTSOVgddguNffRuGYBZYILPjwWG6SOO5YkfO8MfTSejlq8(CDfAOV3JRX6Lvkq5nlttSOVgdtWRxgmng7xszHGS4H)aPH(EpUgniHXW6X6FXilAzjswG4956k0C0AqHoeKfTSOVgdtWRxgmng7xszHGSGegdRhR)fJSOLf91yycE9YGzzXY0el6RXW0oemblAD0yANOMLflAzbI3NRRqJT2)96L1rJPDIYY0elrYceVpxxHMJwdk0HGSOLf91yycE9YGPXy)sklZZcsymSES(xmw8fBPeAyrPlGIPRRq4I5uafgPH(S(dKfqNBkYc037X1il3GLlzrJwP3SOXb1zrrnXYLSafO8MfnoOolkYcizrdjalV3KWNYcOz5bSy1GalqbkVzrJdQZIIfq9WFGSak99ECnw8fBPeKPO0fqX01viCXCkGcJ0qFw)bYcOekxP(9Eva1d)bYcO9kRE4pqwvh9lGQo6xtpglGoCL637vXx8fqhUs979QO0fBH4IsxaftxxHWfZPaQh(dKfqPV30vtclGcJ0qFw)bYcOqFVPRMeYYa0SedGGXy(SSsfsPSSOxsIL5a2APlGg67X(8cOrYsVsCaAsOr3vEgWkyuDLQ(7xsIAq7EDwwiCXxSf7lkDbumDDfcxmNcOE4pqwaLUYX1yb0q0GcRV3KWNwSfIlGg67X(8cOWG3eda54A00ySFjLL5zPXy)sklLIf7TNfYZcX2vbuyKg6Z6pqwaLSo9z53rwGbpl2UFNLFhzjgqFw(lgz5bS4WWSSY)uS87ilXoHzbE1(FGKLJYY(9gwGUYX1ilng7xszjEP(ZsDimlpGLy)d7Seda54AKf4v7)bYIVylLOO0fq9WFGSaAmaKJRXcOy66keUyofFXxaL(fLUylexu6cOy66keUyofq9WFGSaQd7w)bbRuBEhxanenOW67nj8PfBH4cOH(ESpVaAKSadEJd7w)bbRuBEhxH9yNeA(lq0LKyrllrYIh(dKgh2T(dcwP28oUc7Xoj0CzDOos7plAzPmlrYcm4noSB9heSsT5DCDhDL5VarxsILPjwGbVXHDR)GGvQnVJR7ORmng7xszzEwidlZyzAIfyWBCy36piyLAZ74kSh7Kqd99arSqqwkblAzbg8gh2T(dcwP28oUc7Xoj00ySFjLfcYsjyrllWG34WU1FqWk1M3Xvyp2jHM)ceDjPcOWin0N1FGSa6Ctrw2kSB9heKfO28oMfB7yYYVJnYYrzjbS4H)GGSqT5DSMyXPSO8hzXPSybO0txHSaswO28oMfB3VZI9SaAwgOnSzH(EGiklGMfqYIZsjialuBEhZcfWYV7pl)oYsI2yHAZ7yw8UpiiLfn)x0NfF8yZYV7pluBEhZcsyRRrAXxSf7lkDbumDDfcxmNcOE4pqwanasiaIW6VJvQ113tlGcJ0qFw)bYcOZnfPSqwqcbqeYYnyHSBL8Zvgy5OSSSyb0SefSyXBKfyKgndxsIfYUvYpxzGfB3VZczbjearilEcZsuWIfVrw0rfWglA4MKVeBwMSOcP)5kwGAD990zSSvkHGLlzXzH4njalumWIghuNffnSSvffWcmi3(zrHplAUg9y9lHXMfKWwxJAIfxzZJszzrrwUKfYUvYpxzGfB3VZcHyPOEZINWS4pl)oYc99(zbmyXzzoGTwAwSDjmWMPaAOVh7ZlGwMLYSaX7Z1vOjasiaIWkmsJMbw0YsKSeaafmWwAcE9YGPrhoklAzjsw6vIdqtcnw9fdA4ZvvVdEEHQ1sr92GPRRqywMMyrFngMGxVmywwSOLLYSejl9kXbOjHgR(Ibn85QQ3bpVq1APOEBW01vimlttS0RehGMeAcOcP)5Qk1667PgmDDfcZY0elJJ0(xBm2VKYY8SqS9eAwMMyrhqPSOLLXrA)Rng7xszHGSeaafmWwAcE9YGPXy)skleGfI3KLPjw0xJHj41ldMgJ9lPSmpleBplZyzglAzPmlLzXPF7QQfWg2SqWiybI3NRRqtaKqaeHvNAXIwwkZI(AmmyqDwuSQwP3MgJ9lPSmpleVjlttSOVgddguNffRuGYBtJX(LuwMNfI3KLzSmnXI(AmmbVEzW0ySFjLL5zHmSOLf91yycE9YGPXy)sklemcwi2EwMXIwwkZsKS0RehGMeA(lgTb6Sc3OhRFjm2gmDDfcZY0elrYsVsCaAsOjGkK(NRQuRRVNAW01vimlttSOVgdZFXOnqNv4g9y9lHX20ySFjLL5zbjmgwpw)lgzzglttS0RehGMeA0DLNbScgvxPQ)(LKOgmDDfcZYmw0YszwIKLEL4a0KqJUR8mGvWO6kv93VKe1GPRRqywMMyPml6RXWO7kpdyfmQUsv)9ljrRP)Rgn03deXseSyxSmnXI(Amm6UYZawbJQRu1F)ss0Q3bprd99arSebl2flZyzglttSOdOuw0YY4iT)1gJ9lPSqqwiEtw0YsKSeaafmWwAcE9YGPrhoklZk(ITuIIsxaftxxHWfZPaQh(dKfqPV30vtclGcJ0qFw)bYcOZnfzb67nD1KqwEaleHOflllw(DKfnxJES(LWyZI(Amy5gSCpl2alfmliHTUgzrhhGgzzC5r3VKel)oYsIe(zj40NfqZYdybEfBXIooanYczbjearyb0qFp2NxaTxjoanj08xmAd0zfUrpw)sySny66keMfTSuMLizPmlLzrFngM)IrBGoRWn6X6xcJTPXy)sklZZIh(dKgBT)7gKWyy9y9VyKfcWYMgIzrllLzbdQZIIMlR6GFNLPjwWG6SOO5YkfO8MLPjwWG6SOOrTsVRjs4NLzSmnXI(Amm)fJ2aDwHB0J1VegBtJX(LuwMNfp8hin037X1Objmgwpw)lgzHaSSPHyw0YszwWG6SOO5YQALEZY0elyqDwu0qbkVRjs4NLPjwWG6SOOXZO1ej8ZYmwMXY0elrYI(Amm)fJ2aDwHB0J1VegBZYILzSmnXszw0xJHj41ldMLflttSaX7Z1vOjasiaIWkmsJMbwMXIwwcaGcgylnbqcbqew)DSsTU(EQPrhoklAzjaGGPNVjps7FD4ilAzPml6RXWGb1zrXQALEBAm2VKYY8Sq8MSmnXI(AmmyqDwuSsbkVnng7xszzEwiEtwMXYmw0YszwIKLaacME(gII2NNSmnXsaauWaBPbJTa2WUQdsytJX(LuwMNf7ILzfFXw0WIsxaftxxHWfZPaQh(dKfqPV30vtclGcJ0qFw)bYcOAUvSflqFVPRMeszX297Smhx5zazbmyzRkflLE)ssuwanlpGfRgT8gzzaAwiliHaiczX297SmhWwlDb0qFp2NxaTxjoanj0O7kpdyfmQUsv)9ljrny66keMfTSuMLYSOVgdJUR8mGvWO6kv93VKeTM(VA0qFpqelZZI9SmnXI(Amm6UYZawbJQRu1F)ss0Q3bprd99arSmpl2ZYmw0YsaauWaBPj41ldMgJ9lPSmpleAw0YsKSeaafmWwAcGecGiS(7yLAD99uZYILPjwkZsaabtpFtEK2)6Wrw0YsaauWaBPjasiaIW6VJvQ113tnng7xszHGSq8MSOLfmOolkAUS6zuw0YIt)2vvlGnSzzEwSFtwialLytwkflbaqbdSLMGxVmyA0HJYYmwMv8fBHmfLUakMUUcHlMtbuGvbuk(fq9WFGSakeVpxxHfqH4QfwaTml6RXW0oemblAD0yANOMgJ9lPSmplKHLPjwIKf91yyAhcMGfToAmTtuZYILzSOLLizrFngM2HGjyrRJgt7eTsVCSu19O0h7Znllw0Yszw0xJHHOlHBeUIXwaByhJ5xXeBsNDqtJX(LuwiilKcWMyNWSmJfTSuMf91yyWG6SOyLcuEBAm2VKYY8SqkaBIDcZY0el6RXWGb1zrXQALEBAm2VKYY8SqkaBIDcZY0elLzjsw0xJHbdQZIIv1k92SSyzAILizrFnggmOolkwPaL3MLflZyrllrYY7kmFdfOO)fqdMUUcHzzwbuyKg6Z6pqwaLSGe((dKSmanlUsXcm4PS87(ZsSteszHUAKLFhJYI3yU9ZsJJgP7iml22XKLsAhcMGfLfcvJPDIYYUtzrHukl)UNSqgwOyGYsJX(LxsIfqZYVJSOXXwaByZYCajml6RXGLJYIRdwplpGLHRuSagdwanlEgLfnoOolkYYrzX1bRNLhWcsyRRXcOq8UMEmwafg81gT711ymMpT4l2IMTO0fqX01viCXCkGcSkGsXVaQh(dKfqH4956kSakexTWcOLzjsw0xJHbdQZIIvkq5TzzXIwwIKf91yyWG6SOyvTsVnllwMXIwwIKL3vy(gkqr)lGgmDDfcZIwwIKLEL4a0KqZFXOnqNv4g9y9lHX2GPRRq4cOWin0N1FGSakzbj89hiz539NLWogiIYYnyjkyXI3ilG1tpyKfmOolkYYdybKQOSadEw(DSrwanlhPe0il)(rzX297SafOO)fWcOq8UMEmwafg8vW6PhmwXG6SOyXxSfcDrPlGIPRRq4I5ua1d)bYcOXaqoUglGgIguy99Me(0ITqCb0qFp2NxaTml6RXWGb1zrXkfO820ySFjLL5zPXy)sklttSOVgddguNffRQv6TPXy)sklZZsJX(LuwMMybI3NRRqdm4RG1tpySIb1zrrwMXIwwAC0iD31vilAz59Me(M)IX6dQWhYY8SqS9SOLf3Qg2XarSOLfiEFUUcnWGV2ODVUgJX8PfqHrAOpR)azbunh4zXvkwEVjHpLfB3VFjlecpHX4lWIT73bRNfaeSdUL1LKiWVJS46aiilbqcF)bsAXxSf7QO0fqX01viCXCkG6H)azbu6khxJfqd99yFEb0YSOVgddguNffRuGYBtJX(LuwMNLgJ9lPSmnXI(AmmyqDwuSQwP3MgJ9lPSmplng7xszzAIfiEFUUcnWGVcwp9GXkguNffzzglAzPXrJ0DxxHSOLL3Bs4B(lgRpOcFilZZcX2ZIwwCRAyhdeXIwwG4956k0ad(AJ296AmgZNwanenOW67nj8PfBH4IVylLKIsxaftxxHWfZPaQh(dKfqPpQuExhkVXcOH(ESpVaAzw0xJHbdQZIIvkq5TPXy)sklZZsJX(LuwMMyrFnggmOolkwvR0BtJX(LuwMNLgJ9lPSmnXceVpxxHgyWxbRNEWyfdQZIISmJfTS04Or6URRqw0YY7nj8n)fJ1huHpKL5zHynllAzXTQHDmqelAzbI3NRRqdm4RnA3RRXymFAb0q0GcRV3KWNwSfIl(ITq8MfLUakMUUcHlMtbuGvbuk(fq9WFGSakeVpxxHfqH4QfwanaGGPNVbcM)E0MfTSejl9kXbOjHg6LJLQUhL(yFUbtxxHWSOLLizPxjoanj0eUoOWkyuv3aREcxHr)3ny66keMfTSeaafmWwA0XMInrxsY0OdhLfTSeaafmWwAAhcMGfToAmTtutJoCuw0YsKSOVgdtWRxgmllw0YszwC63UQAbSHnlZZIDrOzzAIf91yy0vaaSArFZYILzfqHrAOpR)azbunh4zPps7pl64a0ileQgt7eLLBWY9SydSuWS4kfWglrblwEalnoAKUZIcPuwGx9LKyHq1yANOSu(3pklGufLLD3Yctkl2UFhSEwGE5yPyrZVO0h7ZNvafI310JXcOjOUhL(yFEf9wfTcd(IVyletCrPlGIPRRq4I5uan03J95fqH4956k0KG6Eu6J95v0Bv0km4zrllng7xszHGSy)Mfq9WFGSaAmaKJRXIVyleBFrPlGIPRRq4I5uan03J95fqH4956k0KG6Eu6J95v0Bv0km4zrllng7xszHGSqCjPaQh(dKfqPRCCnw8fBH4suu6cOy66keUyofq9WFGSa6a0bScg10)vJfqHrAOpR)azb05MISqOaBHfqYsaMfB3Vdwplb3Y6ssfqd99yFEbu3Qg2XarfFXwiwdlkDbumDDfcxmNcOE4pqwafJTa2WUQds4cOWin0N1FGSa6Ctrw04ylGnSzzoGeMfB3VZINrzrbssSGjyrANfLt)ljXIghuNffzXtyw(oklpGf1Lil3ZYYIfB3VZcHyPOEZINWSq2Ts(5kdfqd99yFEb0YSeaafmWwAcE9YGPXy)skleGf91yycE9YGbE1(FGKfcWsVsCaAsOXQVyqdFUQ6DWZluTwkQ3gmDDfcZsPyHy7zzEwcaGcgylnySfWg2vDqcBGxT)hizHaSq8MSmJLPjw0xJHj41ldMgJ9lPSmpl2vXxSfIjtrPlGIPRRq4I5uafyvaLIFbup8hilGcX7Z1vybuiUAHfqD63UQAbSHnlZZsjztw0awkZI9gYWsPyrFngMXQJwbJkQwjAOVhiIfnGf7zPuSGb1zrrZLv1k9MLzfqHrAOpR)azbuO4tzX2oMSSvkHGf6oyPGzrhzbEfBHWS8awsWZcac2b3ILYAo0ctyklGKfc1QJYcyWIgRwjYINWS87ilACqDwuCwbuiExtpglG6uRk8k2Q4l2cXA2IsxaftxxHWfZPakWQakf)cOE4pqwafI3NRRWcOqC1clGwMfiEFUUcnb4AaKW3FGKfTSejl6RXWe86LbZYIfTSuMLizHIFvhKlQ5pST3UQ2BfyzAIfmOolkAUSQwP3SmnXcguNffnuGY7AIe(zzglAzPmlLzPmlq8(CDfACQvfEfBXY0elbaem98n5rA)RdhzzAILYSeaqW0Z3qu0(8KfTSeaafmWwAWylGnSR6Ge20OdhLLzSmnXsVsCaAsO5Vy0gOZkCJES(LWyBW01vimlZyrllWG3qx54A00ySFjLL5zXUyrllWG3eda54A00ySFjLL5zPKWIwwkZcm4n0hvkVRdL3OPXy)sklZZcXBYY0elrYY7kmFd9rLY76q5nAW01vimlZyrllq8(CDfA(9(uQkfrIWUAZVNfTS8EtcFZFXy9bv4dzzEw0xJHj41ldg4v7)bswkflBAi0SmnXI(Amm6kaawTOVzzXIww0xJHrxbaWQf9nng7xszHGSOVgdtWRxgmWR2)dKSqawkZcX2ZsPyPxjoanj0y1xmOHpxv9o45fQwlf1BdMUUcHzzglZyzAILYSG296SSqydgBfTrxvbnC6zazrllbaqbdSLgm2kAJUQcA40ZaAAm2VKYcbzHynlHMfcWszwidlLILEL4a0Kqd9YXsv3JsFSp3GPRRqywMXYmwMXIwwkZszwIKLaacME(M8iT)1HJSmnXszwG4956k0eajearyfgPrZalttSeaafmWwAcGecGiS(7yLAD99utJX(LuwiiletgwMXIwwkZsKS0RehGMeA0DLNbScgvxPQ)(LKOgmDDfcZY0elo9BxvTa2WMfcYcz2KfTSeaafmWwAcGecGiS(7yLAD99utJoCuwMXYmwMMyzCK2)AJX(LuwiilbaqbdSLMaiHaicR)owPwxFp10ySFjLLzSmnXIoGszrllJJ0(xBm2VKYcbzrFngMGxVmyGxT)hizHaSqS9Sukw6vIdqtcnw9fdA4ZvvVdEEHQ1sr92GPRRqywMvafgPH(S(dKfqNBkYcz3k5NRmWIT73zHSGecGiK8LuVeUrywGAD99uw8eMfyqU9Zcac2267rwielf1Bwanl22XKL5Oaay1I(SydSuWSGe26AKfDCaAKfYUvYpxzGfKWwxJudleYoril0vJS8awW8XMfNfnALEZIghuNffzX2oMSSOhPKLsBVDXI9wbw8eMfxPyHSAokl2oLIfDmaIrwA0HJYcfaswWeSiTZc8QVKel)oYI(AmyXtywGbpLLDhcYIoIjl01yCHdZxfLLghns3rytbuiExtpglGgGRbqcF)bYk9l(ITqmHUO0fqX01viCXCkG6H)azb02HGjyrRJgt7eTakmsd9z9hilGo3uKfcvJPDIYIT73zHSBL8ZvgyzLkKszHq1yANOSydSuWSOC6ZIcKKWMLF3twi7wj)CLbnXYVJjllkYIooanwan03J95fq1xJHj41ldMgJ9lPSmpletgwMMyrFngMGxVmyGxT)hizHGSypHMfcWsVsCaAsOXQVyqdFUQ6DWZluTwkQ3gmDDfcZsPyHy7zrllq8(CDfAcW1aiHV)azL(fFXwi2UkkDbumDDfcxmNcOH(ESpVakeVpxxHMaCnas47pqwPplAzPml6RXWe86Lbd8Q9)ajlZhbl2tOzHaS0RehGMeAS6lg0WNRQEh88cvRLI6TbtxxHWSukwi2EwMMyjswcaiy65BGG5VhTzzglttSOVgdt7qWeSO1rJPDIAwwSOLf91yyAhcMGfToAmTtutJX(LuwiilLewialbqcVU3y1y4Oy1vhPmgZ38xmwH4QfYcbyPmlrYI(Amm6kaawTOVzzXIwwIKL3vy(g67Tc0WgmDDfcZYScOE4pqwanGkK(NRQU6iLXy(fFXwiUKuu6cOy66keUyofqd99yFEbuiEFUUcnb4AaKW3FGSs)cOE4pqwa9YG3P)hil(ITy)MfLUakMUUcHlMtbuGvbuk(fq9WFGSakeVpxxHfqH4QfwanaakyGT0e86LbtJX(LuwMNfI3KLPjwIKfiEFUUcnbqcbqewHrA0mWIwwcaiy65BYJ0(xhowafgPH(S(dKfqlP4956kKLffHzbKS46N6(dPS87(ZInpFwEal6iluhccZYa0Sq2Ts(5kdSqbS87(ZYVJrzXBmFwS50hHzrZ)f9zrhhGgz53X4cOq8UMEmwaL6qW6a01GxVmu8fBXEIlkDbumDDfcxmNcOE4pqwaDS6OvWOIQvIfqHrAOpR)azb05MIuwiuanMLBWYLS4jlACqDwuKfpHz57dPS8awuxISCplllwSD)oleILI6TMyHSBL8Zvg0elACSfWg2SmhqcZINWSSvy36piilqT5DCb0qFp2NxafdQZIIMlREgLfTSuMfN(TRQwaByZcbzPKyplAal6RXWmwD0kyur1krd99arSukwidlttSOVgdt7qWeSO1rJPDIAwwSmJfTSuMf91yyS6lg0WNRQEh88cvRLI6TbIRwileKf71WnzzAIf91yycE9YGPXy)sklZZIDXYmw0YceVpxxHgQdbRdqxdE9YalAzPmlrYsaabtpFtIHgOanmlttSadEJd7w)bbRuBEhxH9yNeA(lq0LKyzglAzPmlrYsaabtpFdem)9OnlttSOVgdt7qWeSO1rJPDIAAm2VKYcbzPKWIgWszw0qwkfl9kXbOjHg6LJLQUhL(yFUbtxxHWSmJfTSOVgdt7qWeSO1rJPDIAwwSmnXsKSOVgdt7qWeSO1rJPDIAwwSmJfTSuMLizjaGGPNVHOO95jlttSeaafmWwAWylGnSR6Ge20ySFjLL5zX(nzzglAz59Me(M)IX6dQWhYY8SqgwMMyrhqPSOLLXrA)Rng7xszHGSq8MfFXwS3(IsxaftxxHWfZPakmsd9z9hilGsi53ZIZcn2vkwIbXy(S4JhBwiunM2jkl3GLOGflEJS46G1ZYdyj40NfNfQfMWyxaLIHcOBAiMmSObS4H)aPPDiycw06OX0orn)fJv6LbSaQh(dKfqT53xan03J95fqdaiy65BGG5VhTzrllwncXqSPDiycw06OX0orzrllE4pqAAhcMGfToAmTtuZFXyLEzazHGSSPHyYWIwwG4956k04uRk8k2Q4l2I9LOO0fqX01viCXCkG6H)azbu679WvQcOWin0N1FGSa6Ctrw08s83zb679WvkwSAqGYYnyb679WvkwoAU9ZYYQaAOVh7ZlGQVgddiXFNwTWoGw)bsZYIfTSOVgdd99E4kLPXrJ0DxxHfFXwSxdlkDbumDDfcxmNcOE4pqwan4zavv91yuan03J95fq1xJHH(ERanSPXy)skleKfYWIwwkZI(AmmyqDwuSsbkVnng7xszzEwidlttSOVgddguNffRQv6TPXy)sklZZczyzglAzXPF7QQfWg2SmplLKnlGQVgJA6Xybu67Tc0WfqHrAOpR)azbuY6zavSa99wbAywUbl3ZYUtzrHukl)UNSqgklng7xEjjnXsuWIfVrw8NLsYMeGLTsjeS4jml)oYsy1nMplACqDwuKLDNYcziaLLgJ9lVKuXxSf7jtrPlGIPRRq4I5uafyvaLIFbup8hilGcX7Z1vybuiUAHfqdaiy65BYJ0(xhoYIww6vIdqtcnw9fdA4ZvvVdEEHQ1sr92GPRRqyw0YI(Ammw9fdA4ZvvVdEEHQ1sr92aXvlKfcWIt)2vvlGnSzHaSucwMpcwkXMBYIwwG4956k0eajearyfgPrZalAzjaakyGT0eajeary93Xk1667PMgJ9lPSqqwC63UQAbSHnlKNLsSjlLIfsbytStyw0YcguNffnxw9mklAzXPF7QQfWg2Smplq8(CDfAcGecGiS6ulw0YsaauWaBPj41ldMgJ9lPSmplKPakmsd9z9hilGcfFkl22XKfcXsr9Mf6oyPGzrhzXQbHacZc6TkklpGfDKfxxHS8awwuKfYcsiaIqwajlbaqbdSLSuwJPum)ZvQOSOJbqmsz57fYYnybEfBDjjw2kLqWscSXITtPyXvkGnwIcwS8awSWEGHxfLfmFSzHqSuuVzXtyw(DmzzrrwiliHaicNvafI310JXcOwniuTwkQ3v0Bv0IVyl2RzlkDbumDDfcxmNcOE4pqwaL(EpCLQakmsd9z9hilGo3uKfOV3dxPyX297Sa9rLYBw0C9nEwanlV92flAOvGfpHzjbSa99wbAynXITDmzjbSa99E4kflhLLLflGMLhWIvdcSqiwkQ3SyBhtwCDaeKLsYMSSvkHOmOz53rwqVvrzHqSuuVzXQbbwG4956kKLJYY3lCglGMfh2Y)dcYc1M3XSS7uwSlcqXaLLgJ9lVKelGMLJYYLSmuhP9VaAOVh7ZlGwML3vy(g6JkL3v4(gVbtxxHWSmnXcf)QoixuZFyBVDv1qRalZyrllrYY7kmFd99wbAydMUUcHzrll6RXWqFVhUszAC0iD31vilAzjsw6vIdqtcn)fJ2aDwHB0J1VegBdMUUcHzrllLzrFnggR(Ibn85QQ3bpVq1APOEBG4QfYY8rWI9Kztw0YsKSOVgdtWRxgmllw0YszwG4956k04uRk8k2ILPjw0xJHHOlHBeUIXwaByhJ5xXeBsNDqZYILPjwG4956k0y1Gq1APOExrVvrzzglttSuMLaacME(MednqbAyw0YY7kmFd9rLY7kCFJ3GPRRqyw0YszwGbVXHDR)GGvQnVJRWEStcnng7xszzEwSlwMMyXd)bsJd7w)bbRuBEhxH9yNeAUSouhP9NLzSmJLzSOLLYSeaafmWwAcE9YGPXy)sklZZcXBYY0elbaqbdSLMaiHaicR)owPwxFp10ySFjLL5zH4nzzwXxSf7j0fLUakMUUcHlMtbup8hilGsFVPRMewafgPH(S(dKfq1CRylklBLsiyrhhGgzHSGecGiKLf9ssS87ilKfKqaeHSeaj89hiz5bSe2XarSCdwiliHaicz5OS4HF5kvuwCDW6z5bSOJSeC6xan03J95fqH4956k0y1Gq1APOExrVvrl(ITyVDvu6cOy66keUyofq9WFGSaAI2QXaqwafgPH(S(dKfqNBkYcHmaKuwSTJjlrblw8gzX1bRNLhqEVrwcUL1LKyjS7njKYINWSe7eHSqxnYYVJrzXBKLlzXtw04G6SOil0)ukwgGMfn)iKjpHIqUaAOVh7ZlG6w1WogiIfTSuMLWU3KqklrWI9SOLLgd7EtcR)fJSqqwidlttSe29MeszjcwkblZk(ITyFjPO0fqX01viCXCkGg67X(8cOUvnSJbIyrllLzjS7njKYseSyplAzPXWU3KW6FXileKfYWY0elHDVjHuwIGLsWYmw0Yszw0xJHbdQZIIv1k920ySFjLL5zbjmgwpw)lgzzAIf91yyWG6SOyLcuEBAm2VKYY8SGegdRhR)fJSmRaQh(dKfq3D1OgdazXxSLsSzrPlGIPRRq4I5uan03J95fqDRAyhdeXIwwkZsy3BsiLLiyXEw0YsJHDVjH1)IrwiilKHLPjwc7EtcPSeblLGLzSOLLYSOVgddguNffRQv6TPXy)sklZZcsymSES(xmYY0el6RXWGb1zrXkfO820ySFjLL5zbjmgwpw)lgzzwbup8hilGowkvngaYIVylLG4IsxaftxxHWfZPaQh(dKfqPV30vtclGcJ0qFw)bYcOZnfzb67nD1Kqw08s83zXQbbklEcZc8k2ILTsjeSyBhtwi7wj)CLbnXIghBbSHnlZbKWAILFhzPKcM)E0Mf91yWYrzX1bRNLhWYWvkwaJblGMLOG12WSeClw2kLquan03J95fqXG6SOO5YQNrzrllLzrFnggqI)oTguO3vih9aPzzXY0el6RXWq0LWncxXylGnSJX8RyInPZoOzzXY0el6RXWe86LbZYIfTSuMLizjaGGPNVHOO95jlttSeaafmWwAWylGnSR6Ge20ySFjLL5zHmSmnXI(AmmbVEzW0ySFjLfcYcPaSj2jmlLILHcaAwkZIt)2vvlGnSzH8SaX7Z1vOHsRba9zzglZyrllLzjswcaiy65BGG5VhTzzAIf91yyAhcMGfToAmTtutJX(LuwiilKcWMyNWSukwc4PyPmlLzXPF7QQfWg2Sqaw0WnzPuS8UcZ3mwD0kyur1krdMUUcHzzglKNfiEFUUcnuAnaOplZyHaSucwkflVRW8njARgdaPbtxxHWSOLLizPxjoanj0qVCSu19O0h7Zny66keMfTSOVgdt7qWeSO1rJPDIAwwSmnXI(AmmTdbtWIwhnM2jALE5yPQ7rPp2NBwwSmnXszw0xJHPDiycw06OX0ornng7xszHGS4H)aPH(EpUgniHXW6X6FXilAzHAHkvD3PpYcbzztJgYY0el6RXW0oemblAD0yANOMgJ9lPSqqw8WFG0yR9F3GegdRhR)fJSmnXI(Ammw9fdA4ZvvVdEEHQ1sr92aXvlKL5JGf7jEtw0YszwC63UQAbSHnlZZceVpxxHgkTga0NLsXI9SObSqgwMMyrFngM2HGjyrRJgt7e10ySFjLL5zXEwMXIww0xJHPDiycw06OX0ornng7xszHGSOzzzAIfiEFUUcnNDdxdGe((dKSOLLaaOGb2sZL0qVExxHv7E55VIRWiKlGMgD4OSOLf0UxNLfcBUKg6176kSA3lp)vCfgHCbKLzSOLf91yyAhcMGfToAmTtuZYILPjwIKf91yyAhcMGfToAmTtuZYIfTSejlbaqbdSLM2HGjyrRJgt7e10OdhLLzSmnXceVpxxHgNAvHxXwSmnXIoGszrllJJ0(xBm2VKYcbzHua2e7eMLsXsapflLzXPF7QQfWg2SqEwG4956k0qP1aG(SmJLzfFXwkH9fLUakMUUcHlMtbup8hilGsFVPRMewafgPH(S(dKfqlDhLLhWsSteYYVJSOJ0NfWGfOV3kqdZIEuwOVhi6ssSCplllwS71fisfLLlzXZOSOXb1zrrw0xpleILI6nlhn3(zX1bRNLhWIoYIvdcbeUaAOVh7ZlG(UcZ3qFVvGg2GPRRqyw0YsKS0RehGMeA(lgTb6Sc3OhRFjm2gmDDfcZIwwkZI(Amm03BfOHnllwMMyXPF7QQfWg2SmplLKnzzglAzrFngg67Tc0Wg67bIyHGSucw0Yszw0xJHbdQZIIvkq5TzzXY0el6RXWGb1zrXQALEBwwSmJfTSOVgdJvFXGg(Cv17GNxOATuuVnqC1czHGSypHEtw0YszwcaGcgylnbVEzW0ySFjLL5zH4nzzAILizbI3NRRqtaKqaeHvyKgndSOLLaacME(M8iT)1HJSmR4l2sjkrrPlGIPRRq4I5uafyvaLIFbup8hilGcX7Z1vybuiUAHfqXG6SOO5YQALEZsPyXUyH8S4H)aPH(EpUgniHXW6X6FXileGLizbdQZIIMlRQv6nlLILYSOzzHaS8UcZ3qblvfmQ)owhGgPVbtxxHWSukwkblZyH8S4H)aPXw7)Ubjmgwpw)lgzHaSSPrdjdlKNfQfQu1DN(ileGLnnKHLsXY7kmFt6)QrAv3vEgqdMUUcHlGcJ0qFw)bYcOAm9Vy)rkl7aBSeVc7SSvkHGfVrwi5xIWSyHnlumasydlAEPkklVteszXzHMUfDh8Smanl)oYsy1nMpl07x(FGKfkGfBGLco3(zrhzXdHv7pYYa0SO8Me2S8xmoApgPfqH4Dn9ySaQtTieydfdfFXwkHgwu6cOy66keUyofq9WFGSak99MUAsybuyKg6Z6pqwavZTITyb67nD1KqwUKfpzrJdQZIIS4uwOaqYItzXcqPNUczXPSOajjwCklrblwSDkflycZYYIfB3VZIDTjbyX2oMSG5J9LKy53rwsKWplACqDwuutSadYTFwu4ZY9Sy1GaleILI6TMybgKB)SaGGTT(EKfpzrZlXFNfRgeyXtywSaafl64a0ilKDRKFUYalEcZIghBbSHnlZbKWfqd99yFEb0izPxjoanj08xmAd0zfUrpw)sySny66keMfTSuMf91yyS6lg0WNRQEh88cvRLI6TbIRwileKf7j0BYY0el6RXWy1xmOHpxv9o45fQwlf1BdexTqwiil2tMnzrllVRW8n0hvkVRW9nEdMUUcHzzglAzPmlyqDwu0CzLcuEZIwwC63UQAbSHnleGfiEFUUcno1IqGnumWsPyrFnggmOolkwPaL3MgJ9lPSqawGbVzS6OvWOIQvIM)cerRng7xYsPyXEdzyzEwSRnzzAIfmOolkAUSQwP3SOLfN(TRQwaByZcbybI3NRRqJtTieydfdSukw0xJHbdQZIIv1k920ySFjLfcWcm4nJvhTcgvuTs08xGiATXy)swkfl2BidlZZsjztwMXIwwIKf91yyaj(70Qf2b06pqAwwSOLLiz5DfMVH(ERanSbtxxHWSOLLYSeaafmWwAcE9YGPXy)sklZZcHMLPjwOGLs)syZV3NsvPise2gmDDfcZIww0xJH537tPQuejcBd99arSqqwkrjyrdyPml9kXbOjHg6LJLQUhL(yFUbtxxHWSukwSNLzSOLLXrA)Rng7xszzEwiEZnzrllJJ0(xBm2VKYcbzX(n3KLzSOLLYSejlbaem98nefTppzzAILaaOGb2sdgBbSHDvhKWMgJ9lPSmpl2ZYSIVylLGmfLUakMUUcHlMtbup8hilGMOTAmaKfqHrAOpR)azb05MISqidajLLlzXZOSOXb1zrrw8eMfQdbzrZpxniaHAPuSqidajldqZcz3k5NRmWINWSus9s4gHzrJJTa2WogZ3WYwvuallkYYwiKzXtywiueYS4pl)oYcMWSagSqOAmTtuw8eMfyqU9ZIcFw0Cn6X6xcJnldxPybmgfqd99yFEbu3Qg2XarSOLfiEFUUcnuhcwhGUg86Lbw0Yszw0xJHbdQZIIv1k920ySFjLL5zbjmgwpw)lgzzAIf91yyWG6SOyLcuEBAm2VKYY8SGegdRhR)fJSmR4l2sj0SfLUakMUUcHlMtb0qFp2Nxa1TQHDmqelAzbI3NRRqd1HG1bORbVEzGfTSuMf91yyWG6SOyvTsVnng7xszzEwqcJH1J1)IrwMMyrFnggmOolkwPaL3MgJ9lPSmpliHXW6X6FXilZyrllLzrFngMGxVmywwSmnXI(Ammw9fdA4ZvvVdEEHQ1sr92aXvlKfcgbl2t8MSmJfTSuMLizjaGGPNVbcM)E0MLPjw0xJHPDiycw06OX0ornng7xszHGSuMfYWIgWI9Sukw6vIdqtcn0lhlvDpk9X(CdMUUcHzzglAzrFngM2HGjyrRJgt7e1SSyzAILizrFngM2HGjyrRJgt7e1SSyzglAzPmlrYsVsCaAsO5Vy0gOZkCJES(LWyBW01vimlttSGegdRhR)fJSqqw0xJH5Vy0gOZkCJES(LWyBAm2VKYY0elrYI(Amm)fJ2aDwHB0J1VegBZYILzfq9WFGSa6URg1yail(ITuccDrPlGIPRRq4I5uan03J95fqDRAyhdeXIwwG4956k0qDiyDa6AWRxgyrllLzrFnggmOolkwvR0BtJX(LuwMNfKWyy9y9VyKLPjw0xJHbdQZIIvkq5TPXy)sklZZcsymSES(xmYYmw0Yszw0xJHj41ldMLflttSOVgdJvFXGg(Cv17GNxOATuuVnqC1czHGrWI9eVjlZyrllLzjswcaiy65BikAFEYY0el6RXWq0LWncxXylGnSJX8RyInPZoOzzXYmw0YszwIKLaacME(giy(7rBwMMyrFngM2HGjyrRJgt7e10ySFjLfcYczyrll6RXW0oemblAD0yANOMLflAzjsw6vIdqtcn0lhlvDpk9X(CdMUUcHzzAILizrFngM2HGjyrRJgt7e1SSyzglAzPmlrYsVsCaAsO5Vy0gOZkCJES(LWyBW01vimlttSGegdRhR)fJSqqw0xJH5Vy0gOZkCJES(LWyBAm2VKYY0elrYI(Amm)fJ2aDwHB0J1VegBZYILzfq9WFGSa6yPu1yail(ITuc7QO0fqX01viCXCkGcJ0qFw)bYcOZnfzHqcOXSaswcWfq9WFGSaQnV7d0vWOIQvIfFXwkrjPO0fqX01viCXCkG6H)azbu6794ASakmsd9z9hilGo3uKfOV3JRrwEalwniWcuGYBw04G6SOOMyHSBL8Zvgyz3PSOqkLL)Irw(DpzXzHqQ9FNfKWyy9ilkC8SaAwaPkklA0k9MfnoOolkYYrzzzzyHq6(DwkT92fl2BfybZhBwCwGcuEZIghuNffz5gSqiwkQ3Sq)tPyz3PSOqkLLF3twSN4nzH(EGiklEcZcz3k5NRmWINWSqwqcbqeYYUdbzjg0il)UNSqmHMYcz1CS0ySF5LKmSm3uKfxhabzXEYSPMHLDN(ilWR(ssSqOAmTtuw8eMf7T3Endl7o9rwSD)oy9SqOAmTt0cOH(ESpVakguNffnxwvR0Bw0YsKSOVgdt7qWeSO1rJPDIAwwSmnXcguNffnuGY7AIe(zzAILYSGb1zrrJNrRjs4NLPjw0xJHj41ldMgJ9lPSqqw8WFG0yR9F3GegdRhR)fJSOLf91yycE9YGzzXYmw0YszwIKfk(vDqUOM)W2E7QAVvGLPjw6vIdqtcnw9fdA4ZvvVdEEHQ1sr92GPRRqyw0YI(Ammw9fdA4ZvvVdEEHQ1sr92aXvlKfcYI9eVjlAzjaakyGT0e86LbtJX(LuwMNfIj0SOLLYSejlbaem98n5rA)RdhzzAILaaOGb2staKqaeH1FhRuRRVNAAm2VKYY8SqmHMLzSOLLYSejlThqZ3aLILPjwcaGcgyln6ytXMOljzAm2VKYY8SqmHMLzSmJLPjwWG6SOO5YQNrzrllLzrFnggBE3hORGrfvRenllwMMyHAHkvD3PpYcbzztJgsgw0YszwIKLaacME(giy(7rBwMMyjsw0xJHPDiycw06OX0ornllwMXY0elbaem98nqW83J2SOLfQfQu1DN(ileKLnnAilZk(ITOHBwu6cOy66keUyofqHrAOpR)azb05MISqi1(VZc43X22rrwSTFHDwoklxYcuGYBw04G6SOOMyHSBL8Zvgyb0S8awSAqGfnALEZIghuNfflG6H)azbuBT)7fFXw0qIlkDbumDDfcxmNcOWin0N1FGSakHYvQFVxfq9WFGSaAVYQh(dKv1r)cOQJ(10JXcOdxP(9Ev8fFXxafc20dKfBX(nT3(n1WnTRcO28oVKeTakH0wlP3YCTfnFlzwyP07ilxSfOFwgGMLTbwyI92S0ODVUgHzHcIrw81dI9hHzjS7jjKA4n0OlrwSVKzHSGec2pcZY29kXbOjHgYzBwEalB3RehGMeAihdMUUcH3MLYet4zgEdn6sKLsuYSqwqcb7hHzz7EL4a0Kqd5SnlpGLT7vIdqtcnKJbtxxHWBZszIj8mdVbVbH0wlP3YCTfnFlzwyP07ilxSfOFwgGMLTHXHVu)2S0ODVUgHzHcIrw81dI9hHzjS7jjKA4n0Olrw0SLmlKfKqW(rywGEXKLfA08DcZIMHLhWIgTCwGpih9ajlalS9h0SuM8ZyPmXeEMH3qJUezrZwYSqwqcb7hHzz7EL4a0Kqd5SnlpGLT7vIdqtcnKJbtxxHWBZsz7j8mdVHgDjYcHUKzHSGec2pcZY29kXbOjHgYzBwEalB3RehGMeAihdMUUcH3MLYet4zgEdn6sKf7QKzHSGec2pcZc0lMSSqJMVtyw0mS8aw0OLZc8b5OhizbyHT)GMLYKFglLTNWZm8gA0Lil2vjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnlLjMWZm8gA0LilLKsMfYcsiy)imlB3RehGMeAiNTz5bSSDVsCaAsOHCmy66keEBwkxccpZWBOrxISuskzwiliHG9JWSS93xse(gInKZ2S8aw2(7ljcFZtSHC2MLY2t4zgEdn6sKLssjZczbjeSFeMLT)(sIW3yVHC2MLhWY2FFjr4BE7nKZ2Su2EcpZWBOrxISq8MLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBOrxISqmXLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBOrxISqS9LmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBOrxISqCjkzwiliHG9JWSSDVsCaAsOHC2MLhWY29kXbOjHgYXGPRRq4TzPmXeEMH3qJUezHyYuYSqwqcb7hHzz7EL4a0Kqd5SnlpGLT7vIdqtcnKJbtxxHWBZszIj8mdVHgDjYcXA2sMfYcsiy)imlB3RehGMeAiNTz5bSSDVsCaAsOHCmy66keEBwkBpHNz4n0OlrwiwZwYSqwqcb7hHzz7VVKi8neBiNTz5bSS93xse(MNyd5SnlLjdHNz4n0OlrwiwZwYSqwqcb7hHzz7VVKi8n2BiNTz5bSS93xse(M3Ed5SnlLjMWZm8gA0LiletOlzwiliHG9JWSSDVsCaAsOHC2MLhWY29kXbOjHgYXGPRRq4TzPS9eEMH3qJUezHycDjZczbjeSFeMLT)(sIW3qSHC2MLhWY2FFjr4BEInKZ2SuMycpZWBOrxISqmHUKzHSGec2pcZY2FFjr4BS3qoBZYdyz7VVKi8nV9gYzBwktgcpZWBWBqiT1s6TmxBrZ3sMfwk9oYYfBb6NLbOzzBRgdGyD)3MLgT711imluqmYIVEqS)imlHDpjHudVHgDjYsjkzwiliHG9JWSS93xse(gInKZ2S8aw2(7ljcFZtSHC2MLYLGWZm8gA0LilAyjZczbjeSFeMLT)(sIW3yVHC2MLhWY2FFjr4BE7nKZ2SuUeeEMH3qJUezXUkzwiliHG9JWSSDVsCaAsOHC2MLhWY29kXbOjHgYXGPRRq4TzXFw0ynpnILYet4zgEdEdcPTwsVL5AlA(wYSWsP3rwUylq)SmanlB7aCBwA0UxxJWSqbXil(6bX(JWSe29Kesn8gA0LilexYSqwqcb7hHzz7EL4a0Kqd5SnlpGLT7vIdqtcnKJbtxxHWBZszIj8mdVHgDjYI9LmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBOrxISyFjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnl(ZIgR5PrSuMycpZWBOrxISuIsMfYcsiy)imlB)UcZ3qoBZYdyz73vy(gYXGPRRq4TzPmXeEMH3qJUezPeLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82Su2Ui8mdVHgDjYcHUKzHSGec2pcZc0lMSSqJMVtyw0mAgwEalA0YzjgaVulklalS9h0SuwZmJLYet4zgEdn6sKfcDjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnlLTNWZm8gA0Lil2vjZczbjeSFeMfOxmzzHgnFNWSOz0mS8aw0OLZsmaEPwuwawy7pOzPSMzglLjMWZm8gA0Lil2vjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnlLjMWZm8gA0LilLKsMfYcsiy)imlB3RehGMeAiNTz5bSSDVsCaAsOHCmy66keEBwktmHNz4n0OlrwiEZsMfYcsiy)imlqVyYYcnA(oHzrZWYdyrJwolWhKJEGKfGf2(dAwkt(zSu2EcpZWBOrxISqCjkzwiliHG9JWSa9Ijll0O57eMfndlpGfnA5SaFqo6bswawy7pOzPm5NXszIj8mdVHgDjYcXKPKzHSGec2pcZY29kXbOjHgYzBwEalB3RehGMeAihdMUUcH3MLYet4zgEdn6sKfI1SLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBOrxISqmHUKzHSGec2pcZY29kXbOjHgYzBwEalB3RehGMeAihdMUUcH3MLY2t4zgEdn6sKfIljLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBOrxISypXLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82Su2EcpZWBOrxISyFjkzwiliHG9JWSa9Ijll0O57eMfndlpGfnA5SaFqo6bswawy7pOzPm5NXszIj8mdVHgDjYI9KPKzHSGec2pcZc0lMSSqJMVtyw0mS8aw0OLZc8b5OhizbyHT)GMLYKFglLTNWZm8gA0Lil2tMsMfYcsiy)imlB3RehGMeAiNTz5bSSDVsCaAsOHCmy66keEBwktmHNz4n0OlrwSNqxYSqwqcb7hHzz7EL4a0Kqd5SnlpGLT7vIdqtcnKJbtxxHWBZszIj8mdVHgDjYI92vjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnlLjMWZm8gA0LilLyZsMfYcsiy)imlqVyYYcnA(oHzrZWYdyrJwolWhKJEGKfGf2(dAwkt(zSu2EcpZWBOrxISucIlzwiliHG9JWSSDVsCaAsOHC2MLhWY29kXbOjHgYXGPRRq4TzXFw0ynpnILYet4zgEdn6sKLsyFjZczbjeSFeMfOxmzzHgnFNWSOzy5bSOrlNf4dYrpqYcWcB)bnlLj)mwkxccpZWBWBqiT1s6TmxBrZ3sMfwk9oYYfBb6NLbOzz7HRu)EV2MLgT711imluqmYIVEqS)imlHDpjHudVHgDjYI9LmlKfKqW(rywGEXKLfA08DcZIMHLhWIgTCwGpih9ajlalS9h0SuM8ZyPmXeEMH3G3GqARL0BzU2IMVLmlSu6DKLl2c0pldqZY20FBwA0UxxJWSqbXil(6bX(JWSe29Kesn8gA0Lil2xYSqwqcb7hHzz7EL4a0Kqd5SnlpGLT7vIdqtcnKJbtxxHWBZszcnHNz4n0OlrwkrjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnlLjMWZm8gA0LilAyjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnlLjMWZm8gA0LilA2sMfYcsiy)imlB3RehGMeAiNTz5bSSDVsCaAsOHCmy66keEBw8NfnwZtJyPmXeEMH3qJUezH4nlzwiliHG9JWSSDVsCaAsOHC2MLhWY29kXbOjHgYXGPRRq4TzPS9eEMH3qJUezHynSKzHSGec2pcZY29kXbOjHgYzBwEalB3RehGMeAihdMUUcH3MLYet4zgEdn6sKfI1SLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMmeEMH3qJUezHycDjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnlLjMWZm8gA0LileBxLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBOrxISypXLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBOrxISypzkzwiliHG9JWSa9Ijll0O57eMfndlpGfnA5SaFqo6bswawy7pOzPm5NXszIj8mdVHgDjYI9KPKzHSGec2pcZY29kXbOjHgYzBwEalB3RehGMeAihdMUUcH3MLYet4zgEdn6sKf71SLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBOrxISucIlzwiliHG9JWSa9Ijll0O57eMfndlpGfnA5SaFqo6bswawy7pOzPm5NXs5sq4zgEdn6sKLsqCjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnlLjMWZm8gA0LilLW(sMfYcsiy)imlB3RehGMeAiNTz5bSSDVsCaAsOHCmy66keEBwktmHNz4n0OlrwkrjkzwiliHG9JWSa9Ijll0O57eMfndlpGfnA5SaFqo6bswawy7pOzPm5NXs5sq4zgEdn6sKLsOHLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82Su2EcpZWBOrxISucnBjZczbjeSFeMLT7vIdqtcnKZ2S8aw2Uxjoanj0qogmDDfcVnlLTNWZm8gA0LilLGqxYSqwqcb7hHzz7EL4a0Kqd5SnlpGLT7vIdqtcnKJbtxxHWBZsz7j8mdVHgDjYsjkjLmlKfKqW(ryw2Uxjoanj0qoBZYdyz7EL4a0Kqd5yW01vi82SuMycpZWBWBmxXwG(ryw0SS4H)ajlQJ(udVrbuRgmofwaLCjxwMJR8mGSO561bZBqUKllB1Qpfl2BxAIf730E75n4nixYLfYU7jjKwY8gKl5YIgWYwHHrywGcuEZYCqp2WBqUKllAalKD3tsimlV3KWVEdwcofPS8awcrdkS(EtcFQH3GCjxw0awkPXyaeeMLvMyaPuVJYceVpxxHuwkFg0OjwSAesL(EtxnjKfnyEwSAeIH(EtxnjCMH3GCjxw0aw2keWbZIvJbN(xsIfcP2)DwUbl3VnLLFhzXwdssSOXb1zrrdVb5sUSObSqi7eHSqwqcbqeYYVJSa1667PS4SOU)vilXGgzzOqcF6kKLY3GLOGfl7oCU9ZY(9SCpl0lEPEprWIQIYIT73zzoAEBT0SqawilQq6FUILTQoszmMVMy5(THzHs0znZWBqUKllAaleYorilXa6ZY2JJ0(xBm2VKUnl0aMEFaklULLkklpGfDaLYY4iT)uwaPkQH3GCjxw0awkDJ(ZsPbXilGblZr57SmhLVZYCu(oloLfNfQfgoxXY3xse(gEdYLCzrdyrZZctSzP8zqJMyHqQ9FxtSqi1(VRjwG(EpUgNXsSdJSedAKLgPN6W8z5bSGERoSzjaI19xdOV3VH3GCjxw0awiuhHzPK6LWncZIghBbSHDmMplHDmqeldqZcz1CSSOoj0WBqUKllAalL0ymacYcCVoytcQbyklHDmqe1WBWBqUKllBntW7pcZYCCLNbKLTsi0iwcEYIoYYaSsyw8NL9)TOLm5jVUR8mGAa9Idgs3VV0nhG8ZXvEgqna6ftwYhdB2)yLMphNcJq3vEgqZt4N3G3Wd)bsQXQXaiw3)ii6s4gHRuRRVNYBqUSu6DKfiEFUUcz5OSqXNLhWYMSy7(Dwsal03FwajllkYY3xse(unXcXSyBhtw(DKLX10NfqISCuwajllkQjwSNLBWYVJSqXaiHz5OS4jmlLGLBWIo43zXBK3Wd)bsQXQXaiw3Fceb5H4956kutPhJraY6II1VVKi81eexTWi2K3Wd)bsQXQXaiw3Fceb5H4956kutPhJraY6II1VVKi81eWkchgwtqC1cJGynDJi((sIW3qSz3P1ffR6RXq73xse(gInbaqbdSLg4v7)bsTr(9LeHVHyZrnpigRGrngK0VblAnas63RWFGKYB4H)aj1y1yaeR7pbIG8q8(CDfQP0JXiazDrX63xse(AcyfHddRjiUAHryVMUreFFjr4BS3S706IIv91yO97ljcFJ9MaaOGb2sd8Q9)aP2i)(sIW3yV5OMheJvWOgds63GfTgaj97v4pqs5nixwk9osrw((sIWNYI3ilj4zXxpi2)l4kvuwGXhdpcZItzbKSSOil03Fw((sIWNAyHfO4ZceVpxxHS8aw0qwCkl)ogLfxrbSKicZc1cdNRyz3ty1LKm8gE4pqsnwngaX6(tGiipeVpxxHAk9ymcqwxuS(9LeHVMawr4WWAcIRwyeAOMUreODVolle2Cjn0R31vy1UxE(R4kmc5c40eA3RZYcHnySv0gDvf0WPNbCAcT71zzHWgkyPu4)xsQ2l9O8gKllqXNYYVJSa99MUAsilba9zzaAwu(Jnlbxfwk)pqszP8a0SGe2JTuil22XKLhWc99(zbEfBDjjw0XbOrwiunM2jkldxPOSagJz8gE4pqsnwngaX6(tGiipeVpxxHAk9ymckTga0xtqC1cJOeBwQYeRbBAiMmLIIFvhKlQ5pST3UQAOvygVHh(dKuJvJbqSU)eicYdX7Z1vOMspgJGoQba91eexTWiiZMLQmXAWMgIjtPO4x1b5IA(dB7TRQgAfMXBqUSafFkl(ZIT9lSZIhdw5ZcyWYwPecwiliHaiczHUdwkyw0rwwueUKzrd3KfB3VdwplKfvi9pxXcuRRVNYINWSuInzX297gEdp8hiPgRgdGyD)jqeKhI3NRRqnLEmgraKqaeHvNAPjiUAHruInjaXBwQEL4a0Kqtavi9pxvPwxFpL3Wd)bsQXQXaiw3Fceb5JbGKOlRdqhZB4H)aj1y1yaeR7pbIG82A)31K6sSgGJG4n10nIOmguNffnQv6Dnrc)ttyqDwu0CzLcuEpnHb1zrrZLvDWVpnHb1zrrJNrRjs4FgVbVb5YcHOXGtFwSNfcP2)Dw8eMfNfOV30vtczbKSaT0Sy7(Dw2YrA)zHq5ilEcZYCaBT0SaAwG(EpUgzb87yB7OiVHh(dKudWctSjqeK3w7)UMUreLXG6SOOrTsVRjs4FAcdQZIIMlRuGY7PjmOolkAUSQd(9PjmOolkA8mAnrc)Z0A1iedXgBT)7AJ0Qrig7n2A)35n8WFGKAawyInbIG8037X1OMuxI1aCeKrt3iIYLJSxjoanj0O7kpdyfmQUsv)9ljrNMImaGGPNVjps7FD440uKuluPQV3KWNAOV3dxPIG4PPiFxH5Bs)xnsR6UYZaAW01vi8SPPYyqDwu0qbkVRjs4FAcdQZIIMlRQv690eguNffnxw1b)(0eguNffnEgTMiH)zZ0gjf)QoixuZFyBVDvT3kWB4H)aj1aSWeBceb5PV30vtc1K6sSgGJGmA6gruUxjoanj0O7kpdyfmQUsv)9ljr1gaqW0Z3KhP9VoCul1cvQ67nj8Pg679WvQiiEM2iP4x1b5IA(dB7TRQ9wbEdEdYLCzrJjmgwpcZccb7OS8xmYYVJS4Hh0SCuwCi(PCDfA4n8WFGKgbfO8UQJEmVHh(dKuceb5dUsv9WFGSQo6RP0JXiawyITMOFFHpcI10nI4VyKGLTVuE4pqAS1(VBco9R)fJeWd)bsd99ECnAco9R)fJZ4nixwGIpLLTc0ywajlLGaSy7(DW6zbUVXZINWSy7(DwG(ERanmlEcZI9eGfWVJTTJI8gE4pqsjqeKhI3NRRqnLEmgXrRoa1eexTWiOwOsvFVjHp1qFVhUsnpXAlh57kmFd99wbAydMUUcHNMExH5BOpQuExH7B8gmDDfcpBAIAHkv99Me(ud99E4k182ZBqUSafFklbf6qqwSTJjlqFVhxJSe8KL97zXEcWY7nj8PSyB)c7SCuwAuHq88zzaAw(DKfnoOolkYYdyrhzXQXb2ncZINWSyB)c7SmoLcBwEalbN(8gE4pqsjqeKhI3NRRqnLEmgXrRbf6qqnbXvlmcQfQu13Bs4tn037X148eZBqUSusX7Z1vil)U)Se2XaruwUblrblw8gz5swCwifGz5bS4qahml)oYc9(L)hizX2o2ilolFFjr4Zc(bwokllkcZYLSOJVnetwco9P8gE4pqsjqeKhI3NRRqnLEmgXLvsbynbXvlmcRgHujfGneBIbGCCnonz1iKkPaSHydDLJRXPjRgHujfGneBOV30vtcNMSAesLua2qSH(EpCLAAYQrivsbydXMXQJwbJkQwjonz1iet7qWeSO1rJPDIonPVgdtWRxgmng7xsJqFngMGxVmyGxT)hiNMG4956k0C0QdqEdYLL5MISmhSPyt0LKyXFw(DKfmHzbmyHq1yANOSyBhtw2D6JSCuwCDaeKfn7MAgnXIpESzHSGecGiKfB3VZYCaEPzXtywa)o22okYIT73zHSBL8Zvg4n8WFGKsGiiVo2uSj6ssA6gruUCKbaem98n5rA)RdhNMImaakyGT0eajeary93Xk1667PML10uK9kXbOjHgDx5zaRGr1vQ6VFjj6mT6RXWe86LbtJX(L05jMmAJmaGGPNVbcM)E0EAkaGGPNVbcM)E0wR(AmmbVEzWSS0QVgdt7qWeSO1rJPDIAwwAlRVgdt7qWeSO1rJPDIAAm2VKsWii2EnqdlvVsCaAsOHE5yPQ7rPp2NpnPVgdtWRxgmng7xsjiXepnrSMHAHkvD3PpsWYeBkjAW7kmFd9rLY76q5nAW01viCP20qSga3Rd2aJkpAvhBk2eDjPsTPPeZMntleVpxxHMlRKcW8gKllecWZIT73zXzHSBL8Zvgy539NLJMB)S4SqiwkQ3Sy1GalGMfB7yYYVJSmos7plhLfxhSEwEalycZB4H)ajLarqElWFGut3iIY6RXWe86LbtJX(L05jMmAlhzVsCaAsOHE5yPQ7rPp2NpnPVgdt7qWeSO1rJPDIAAm2VKsqIljA1xJHPDiycw06OX0ornlRztt6akv74iT)1gJ9lPe0EYmtleVpxxHMlRKcW8gKllK1vHLYFKYITD83XMLf9ssSqwqcbqeYscSXITtPyXvkGnwIcwS8awO)PuSeC6ZYVJSq9yKfpgSYNfWGfYcsiaIqcq2Ts(5kdSeC6t5n8WFGKsGiipeVpxxHAk9ymIaiHaicRWinAg0eexTWic4PkxECK2)AJX(LunGyYObbaqbdSLMGxVmyAm2VKotZqSDT5S5d4PkxECK2)AJX(LunGyYObbaqbdSLMaiHaicR)owPwxFp10ySFjDMMHy7AZzAJS9dUIqW8nomm1Ge(OpvB5idaGcgylnbVEzW0OdhDAkYaaOGb2staKqaeH1FhRuRRVNAA0HJoBAkaakyGT0e86LbtJX(L05V8X2cO8hHRJJ0(xBm2VKon1RehGMeAcOcP)5Qk1667PAdaGcgylnbVEzW0ySFjD(sS50uaauWaBPjasiaIW6VJvQ113tnng7xsN)YhBlGYFeUoos7FTXy)sQgq8MttrgaqW0Z3KhP9VoCK3GCzzUPimlpGfyu5rz53rwwuNeYcyWcz3k5NRmWITDmzzrVKelWGLUczbKSSOilEcZIvJqW8zzrDsil22XKfpzXHHzbHG5ZYrzX1bRNLhWc8H8gE4pqsjqeKhI3NRRqnLEmgraUgaj89hi1eexTWik)EtcFZFXy9bv4dNNyYmn1(bxriy(ghgMAUCEYS5mTLlJ296SSqydgBfTrxvbnC6za1woYaacME(giy(7r7PPaaOGb2sdgBfTrxvbnC6zanng7xsjiXAwcnbktMs1RehGMeAOxowQ6Eu6J95ZMPnYaaOGb2sdgBfTrxvbnC6zann6WrNnnH296SSqydfSuk8)ljv7LEuTLJmaGGPNVjps7FD440uaauWaBPHcwkf()LKQ9spATeAizSRnj20ySFjLGetSgoBAQCaauWaBPrhBk2eDjjtJoC0PPiBpGMVbk10uaabtpFtEK2)6WXzAlh57kmFZy1rRGrfvReny66keEAkaGGPNVbcM)E0wBaauWaBPzS6OvWOIQvIMgJ9lPeKyIjazkvVsCaAsOHE5yPQ7rPp2NpnfzaabtpFdem)9OT2aaOGb2sZy1rRGrfvRenng7xsjO(AmmbVEzWaVA)pqsaITVu9kXbOjHgR(Ibn85QQ3bpVq1APOERbeB)mTLr7EDwwiS5sAOxVRRWQDV88xXvyeYfqTbaqbdSLMlPHE9UUcR29YZFfxHrixanng7xsjizMnnvUmA3RZYcHn0DhgydHRGwVcg1h0Xy(AdaGcgylnpOJX8r46L0J0(xlbzitjSNytJX(L0zttLldX7Z1vObK1ffRFFjr4hbXttq8(CDfAazDrX63xse(ruIzAl)9LeHVHytJoC0AaauWaB5003xse(gInbaqbdSLMgJ9lPZF5JTfq5pcxhhP9V2ySFjvdiEZzttq8(CDfAazDrX63xse(ryV2YFFjr4BS30OdhTgaafmWwon99LeHVXEtaauWaBPPXy)s68x(yBbu(JW1XrA)Rng7xs1aI3C20eeVpxxHgqwxuS(9LeHFeBoB2mEdYLLskEFUUczzrrywEalWOYJYINrz57ljcFklEcZsaMYITDmzXMF)LKyzaAw8KfnEzTd6ZzXQbbEdp8hiPeicYdX7Z1vOMspgJ437tPQuejc7Qn)EnbXvlmIiPGLs)syZV3NsvPise2gmDDfcpnnos7FTXy)s682V5Mtt6akv74iT)1gJ9lPe0EYqGYA4MAG(Amm)EFkvLIiryBOVhiQu2pBAsFngMFVpLQsrKiSn03denFjSlnOCVsCaAsOHE5yPQ7rPp2Nxk7NXBqUSm3uKfno2kAJUIfnVgo9mGSy)MumqzrhhGgzXzHSBL8Zvgyzrrwanlual)U)SCpl2oLIf1LilllwSD)ol)oYcMWSagSqOAmTtuEdp8hiPeicYVOy9EmwtPhJrGXwrB0vvqdNEgqnDJicaGcgylnbVEzW0ySFjLG2VP2aaOGb2staKqaeH1FhRuRRVNAAm2VKsq73uBziEFUUcn)EFkvLIiryxT53pnPVgdZV3NsvPise2g67bIMVeBsGY9kXbOjHg6LJLQUhL(yFEPkXSzAH4956k0CzLuaEAshqPAhhP9V2ySFjLGLGqZBqUSm3uKfOGLsH)LKyPKEPhLfnlfduw0XbOrwCwi7wj)CLbwwuKfqZcfWYV7pl3ZITtPyrDjYYYIfB3VZYVJSGjmlGbleQgt7eL3Wd)bskbIG8lkwVhJ1u6XyeuWsPW)VKuTx6r10nIOCaauWaBPj41ldMgJ9lPeuZQnYaacME(giy(7rBTrgaqW0Z3KhP9VoCCAkaGGPNVjps7FD4O2aaOGb2staKqaeH1FhRuRRVNAAm2VKsqnR2Yq8(CDfAcGecGiScJ0OzyAkaakyGT0e86LbtJX(LucQzNnnfaqW0Z3abZFpARTCK9kXbOjHg6LJLQUhL(yFU2aaOGb2stWRxgmng7xsjOMDAsFngM2HGjyrRJgt7e10ySFjLGeVjbktMsH296SSqyZL0VxHh00k8b5sSQJk1mT6RXW0oemblAD0yANOML1SPjDaLQDCK2)AJX(LucApzMMq7EDwwiSbJTI2ORQGgo9mGAdaGcgylnySv0gDvf0WPNb00ySFjDE73CMwiEFUUcnxwjfG1gjA3RZYcHnxsd96DDfwT7LN)kUcJqUaonfaafmWwAUKg6176kSA3lp)vCfgHCb00ySFjDE73CAshqPAhhP9V2ySFjLG2VjVb5YYwv28OuwwuKL5sZhAowSD)olKDRKFUYalGMf)z53rwWeMfWGfcvJPDIYB4H)ajLarqEiEFUUc1u6XyeNDdxdGe((dKAcIRwye6RXWe86LbtJX(L05jMmAlhzVsCaAsOHE5yPQ7rPp2NpnPVgdt7qWeSO1rJPDIAAm2VKsWiiMmgYqGYLWqMsPVgdJUcaGvl6BwwZiqzn0qgnOegYuk91yy0vaaSArFZYAwPq7EDwwiS5s63RWdAAf(GCjw1rLIaAOHmLQmA3RZYcHn)owhxt)k9iDkTbaqbdSLMFhRJRPFLEKoLPXy)skbJW(nNPvFngM2HGjyrRJgt7e1SSMnnPdOuTJJ0(xBm2VKsq7jZ0eA3RZYcHnySv0gDvf0WPNbuBaauWaBPbJTI2ORQGgo9mGMgJ9lP8gE4pqsjqeKFrX69ySMspgJ4sAOxVRRWQDV88xXvyeYfqnDJiG4956k0C2nCnas47pqQfI3NRRqZLvsbyEdYLL5MISaD3Hb2qyw08ADw0XbOrwi7wj)CLbEdp8hiPeicYVOy9EmwtPhJrq3DyGneUcA9kyuFqhJ5RPBer5aaOGb2stWRxgmn6Wr1gzaabtpFtEK2)6WrTq8(CDfA(9(uQkfrIWUAZVxB5aaOGb2sJo2uSj6ssMgD4Ottr2EanFduQzttbaem98n5rA)Rdh1gaafmWwAcGecGiS(7yLAD99utJoCuTLH4956k0eajearyfgPrZW0uaauWaBPj41ldMgD4OZMPfg8g6khxJM)ceDjjTLHbVH(Os5DDO8gn)fi6ssttr(UcZ3qFuP8UouEJgmDDfcpnrTqLQ(EtcFQH(EpUgNVeZ0cdEtmaKJRrZFbIUKK2Yq8(CDfAoA1b40uVsCaAsOr3vEgWkyuDLQ(7xsIon50VDv1cyd75JOKS50eeVpxxHMaiHaicRWinAgMM0xJHrxbaWQf9nlRzAJeT71zzHWMlPHE9UUcR29YZFfxHrixaNMq7EDwwiS5sAOxVRRWQDV88xXvyeYfqTbaqbdSLMlPHE9UUcR29YZFfxHrixanng7xsNVeBQns91yycE9YGzznnPdOuTJJ0(xBm2VKsqnCtEdYLLsVFuwoklolT)7yZcQCDq7pYInpklpGLyNiKfxPybKSSOil03Fw((sIWNYYdyrhzrDjcZYYIfB3VZcz3k5NRmWINWSqwqcbqeYINWSSOil)oYI9jmluf4zbKSeGz5gSOd(Dw((sIWNYI3ilGKLffzH((ZY3xse(uEdp8hiPeicYVOy9EmMQjQc80i((sIWNynDJiG4956k0aY6II1VVKi8JmcI1g53xse(g7nn6WrRbaqbdSLttLH4956k0aY6II1VVKi8JG4PjiEFUUcnGSUOy97ljc)ikXmTLdaiy65BGG5VhT1QVgdtWRxgmllTL1xJHPDiycw06OX0ornng7xsjqzn0qMs1RehGMeAOxowQ6Eu6J95ZiyeFFjr4Bi2OVgJk8Q9)aPw91yyAhcMGfToAmTtuZYAAsFngM2HGjyrRJgt7eTsVCSu19O0h7ZnlRzttbaqbdSLMGxVmyAm2VKsaIjZ8FFjr4Bi2eaafmWwAGxT)hi1woYEL4a0KqJvFXGg(Cv17GNxOATuuVNM0xJHj41ldMgJ9lPZRzNMcaGcgylnbVEzW0ySFjvd((sIW3qSjaakyGT0aVA)pqsqIjZmTLJmaGGPNVbcM)E0EAks91yyAhcMGfToAmTtuZYsBaauWaBPPDiycw06OX0ornng7xsNPTCKbaem98n5rA)RdhNM((sIW3qSjaakyGT0aVA)pqoFaauWaBPjasiaIW6VJvQ113tnng7xsNMG4956k0eajearyfgPrZG2VVKi8neBcaGcgylnWR2)dKZhaafmWwAcE9YGPXy)s6mTrgaqW0Z3qu0(8CAkaGGPNVjps7FD4OwiEFUUcnbqcbqewHrA0mOnaakyGT0eajeary93Xk1667PMLL2idaGcgylnbVEzWSS0wUS(AmmyqDwuSQwP3MgJ9lPZtMPj91yyWG6SOyLcuEBAm2VKopzMnBAsFnggIUeUr4kgBbSHDmMFftSjD2bnlRztt6akv74iT)1gJ9lPe0(nNMG4956k0aY6II1VVKi8JytEdp8hiPeicYVOy9EmMQjQc80i((sIW3EnDJiG4956k0aY6II1VVKi8Jmc71g53xse(gInn6WrRbaqbdSLttq8(CDfAazDrX63xse(ryV2Y6RXWe86LbZYsBaabtpFdem)9OT2Y6RXW0oemblAD0yANOMgJ9lPeOSgAitP6vIdqtcn0lhlvDpk9X(8zemIVVKi8n2B0xJrfE1(FGuR(AmmTdbtWIwhnM2jQzznnPVgdt7qWeSO1rJPDIwPxowQ6Eu6J95ML1SPPaaOGb2stWRxgmng7xsjaXKz(VVKi8n2BcaGcgylnWR2)dKAlhzVsCaAsOXQVyqdFUQ6DWZluTwkQ3tt6RXWe86LbtJX(L051SttbaqbdSLMGxVmyAm2VKQbFFjr4BS3eaafmWwAGxT)hijiXKzM2YrgaqW0Z3abZFpApnfP(AmmTdbtWIwhnM2jQzzPnaakyGT00oemblAD0yANOMgJ9lPZ0woYaacME(M8iT)1HJttFFjr4BS3eaafmWwAGxT)hiNpaakyGT0eajeary93Xk1667PMgJ9lPttq8(CDfAcGecGiScJ0Ozq73xse(g7nbaqbdSLg4v7)bY5daGcgylnbVEzW0ySFjDM2idaiy65BikAFEQTCK6RXWe86LbZYAAkYaacME(giy(7r7zttbaem98n5rA)Rdh1cX7Z1vOjasiaIWkmsJMbTbaqbdSLMaiHaicR)owPwxFp1SS0gzaauWaBPj41ldMLL2YL1xJHbdQZIIv1k920ySFjDEYmnPVgddguNffRuGYBtJX(L05jZSzZMM0xJHHOlHBeUIXwaByhJ5xXeBsNDqZYAAshqPAhhP9V2ySFjLG2V50eeVpxxHgqwxuS(9LeHFeBYBqUSm3uKYIRuSa(DSzbKSSOil3JXuwajlbyEdp8hiPeicYVOy9EmMYBqUSOX3VJnlKaSC5dy53rwOplGMfhGS4H)ajlQJ(8gE4pqsjqeKVxz1d)bYQ6OVMspgJWbOMOFFHpcI10nIaI3NRRqZrRoa5n8WFGKsGiiFVYQh(dKv1rFnLEmgb95n4nixwiRRclL)iLfB74VJnl)oYIMRrpo4FyhBw0xJbl2oLILHRuSagdwSD)(LS87iljs4NLGtFEdp8hiPghGraX7Z1vOMspgJaUrpUA7uQ6WvQkym0eexTWi6vIdqtcn)fJ2aDwHB0J1VegBTL1xJH5Vy0gOZkCJES(LWyBAm2VKsqsbytStycSPH4Pj91yy(lgTb6Sc3OhRFjm2MgJ9lPe0d)bsd99ECnAqcJH1J1)IrcSPHyTLXG6SOO5YQALEpnHb1zrrdfO8UMiH)PjmOolkA8mAnrc)ZMPvFngM)IrBGoRWn6X6xcJTzzXBqUSqwxfwk)rkl22XFhBwG(EtxnjKLJYInq)7SeC6FjjwaqWMfOV3JRrwUKfnALEZIghuNff5n8WFGKACasGiipeVpxxHAk9ymIJucASsFVPRMeQjiUAHrejguNffnxwPaL3APwOsvFVjHp1qFVhxJZtO1G3vy(gkyPQGr93X6a0i9ny66keUu2tamOolkAUSQd(DTr2RehGMeAS6lg0WNRQEh88cvRLI6T2i7vIdqtcnGe)DAnOqVRqo6bsEdYLL5MISqwqcbqeYITDmzXFwuiLYYV7jlKztw2kLqWINWSOUezzzXIT73zHSBL8Zvg4n8WFGKACasGiiFaKqaeH1FhRuRRVNQPBer5Yq8(CDfAcGecGiScJ0OzqBKbaqbdSLMGxVmyA0HJQnYEL4a0KqJvFXGg(Cv17GNxOATuuVNM0xJHj41ldMLL2Yr2RehGMeAS6lg0WNRQEh88cvRLI690uVsCaAsOjGkK(NRQuRRVNonnos7FTXy)s68eBpHEAshqPAhhP9V2ySFjLGbaqbdSLMGxVmyAm2VKsaI3CAsFngMGxVmyAm2VKopX2pBM2YLl70VDv1cydBcgbeVpxxHMaiHaicRo1AAIAHkv99Me(ud99ECnoFjMPTS(AmmyqDwuSQwP3MgJ9lPZt8Mtt6RXWGb1zrXkfO820ySFjDEI3C20K(AmmbVEzW0ySFjDEYOvFngMGxVmyAm2VKsWii2(zAlh57kmFd9rLY7kCFJFAsFngg679WvktJX(LucsSHmAWMgYuQEL4a0Kqtavi9pxvPwxFpDAsFngMGxVmyAm2VKsq91yyOV3dxPmng7xsjaz0QVgdtWRxgmlRzAlhzVsCaAsO5Vy0gOZkCJES(LWypnfzVsCaAsOjGkK(NRQuRRVNonPVgdZFXOnqNv4g9y9lHX20ySFjDEKWyy9y9VyC20uVsCaAsOr3vEgWkyuDLQ(7xsIotB5i7vIdqtcn6UYZawbJQRu1F)ss0PPY6RXWO7kpdyfmQUsv)9ljrRP)Rgn03defHDnnPVgdJUR8mGvWO6kv93VKeT6DWt0qFpque21Sztt6akv74iT)1gJ9lPeK4n1gzaauWaBPj41ldMgD4OZ4nixwMBkYc0voUgz5swS8egJValGKfpJ(7xsILF3FwuheKYcXAifduw8eMffsPSy7(DwIbnYY7nj8PS4jml(ZYVJSGjmlGblolqbkVzrJdQZIIS4pleRHSqXaLfqZIcPuwAm2V8ssS4uwEalj4zz3HCjjwEalnoAKUZc8QVKelA0k9MfnoOolkYB4H)aj14aKarqE6khxJAkenOW67nj8PrqSMUreLBC0iD31v40K(AmmyqDwuSsbkVnng7xsjyj0Ib1zrrZLvkq5T2gJ9lPeKynu77kmFdfSuvWO(7yDaAK(gmDDfcpt77nj8n)fJ1huHpCEI1qnGAHkv99Me(uc0ySFjvBzmOolkAUS6z0PPgJ9lPeKua2e7eEgVb5YcHKFplol0yxPyjgeJ5ZIpESzHq1yANOSyBhtwCDW6z5bSSOilEYYL03ZN3Wd)bsQXbibIG82871efdrSPHyYObE4pqAAhcMGfToAmTtuZFXyLEza10nIiaGGPNVbcM)E0wRvJqmeBAhcMGfToAmTtuTE4pqAAhcMGfToAmTtuZFXyLEzaj4MgIjJ2YrsFVhxJg3Qg2XarttVRW8n0hvkVRW9nEdMUUcH1gaafmWwAOV3dxPmn6WrNM0xJHH(EpCLY04Or6URRWz8gKllZnfzb6khxJS8aw2DiilolKuaDxXYdyzrrwMlnFO54n8WFGKACasGiipDLJRrnDJiG4956k0C2nCnas47pqQnaakyGT0Cjn0R31vy1UxE(R4kmc5cOPrhoQw0UxNLfcBUKg6176kSA3lp)vCfgHCbuRBvd7yGiEdYLLsQiAXYYIfOV3dxPyXFwCLIL)IrklRuHukll6LKyrJIg82PS4jml3ZYrzX1bRNLhWIvdcSaAwu4ZYVJSqTWW5kw8WFGKf1Lil6OcyJLDpHvilAUg9y9lHXMfqYI9S8EtcFkVHh(dKuJdqceb5PV3dxP00nIiY3vy(g6JkL3v4(gVbtxxHWAlhjf)QoixuZFyBVDv1qRW0eguNffnxw9m60e1cvQ67nj8Pg679WvQ5lXmTL1xJHH(EpCLY04Or6URRqTLPwOsvFVjHp1qFVhUsrWsmnfzVsCaAsO5Vy0gOZkCJES(LWypBA6DfMVHcwQkyu)DSoansFdMUUcH1QVgddguNffRuGYBtJX(LucwcTyqDwu0CzLcuERvFngg679WvktJX(LucsO1sTqLQ(EtcFQH(EpCLA(i0WzAlhzVsCaAsOrfn4TtRdfI)LKQKuxSffNM(lg1mAgnKmZRVgdd99E4kLPXy)skbSFM23Bs4B(lgRpOcF48KH3GCzHq6(DwG(Os5nlAU(gpllkYcizjaZITDmzPXrJ0DxxHSOVEwO)PuSyZVNLbOzrJIg82PSy1GalEcZcmi3(zzrrw0XbOrwiRMJAyb6FkfllkYIooanYczbjearil0ldil)U)Sy7ukwSAqGfpb)o2Sa99E4kfVHh(dKuJdqceb5PV3dxP00nI4DfMVH(Os5DfUVXBW01viSw91yyOV3dxPmnoAKU76kuB5iP4x1b5IA(dB7TRQgAfMMWG6SOO5YQNrNMOwOsvFVjHp1qFVhUsnFjMPTCK9kXbOjHgv0G3oToui(xsQssDXwuCA6VyuZOz0qYmVgot74iT)1gJ9lPZxcEdYLfcP73zrZ1OhRFjm2SSOilqFVhUsXYdyHieTyzzXYVJSOVgdw0JYIROaww0ljXc037HRuSaswidlumasyklGMffsPS0ySF5LK4n8WFGKACasGiip99E4kLMUre9kXbOjHM)IrBGoRWn6X6xcJTwQfQu13Bs4tn037HRuZhrj0wos91yy(lgTb6Sc3OhRFjm2MLLw91yyOV3dxPmnoAKU76kCAQmeVpxxHg4g94QTtPQdxPQGXqBz91yyOV3dxPmng7xsjyjMMOwOsvFVjHp1qFVhUsnV9AFxH5BOpQuExH7B8gmDDfcRvFngg679WvktJX(LucsMzZMXBqUSqwxfwk)rkl22XFhBwCwG(EtxnjKLffzX2PuSe8ffzb679WvkwEaldxPybmgAIfpHzzrrwG(EtxnjKLhWcriAXIMRrpw)sySzH(EGiwwwgwSRnz5OS87ilnA3RRryw2kLqWYdyj40NfOV30vtcja037HRu8gE4pqsnoajqeKhI3NRRqnLEmgb99E4kv1gi)6WvQkym0eexTWiC63UQAbSH9821MLQmXAaf)QoixuZFyBVDvT3kuQnn2pRuLjwd0xJH5Vy0gOZkCJES(LWyBOVhiQuBAiEMguwFngg679WvktJX(L0svcnd1cvQ6UtFSur(UcZ3qFuP8Uc334ny66keEMguoaakyGT0qFVhUszAm2VKwQsOzOwOsv3D6JL6DfMVH(Os5DfUVXBW01vi8mnOS(AmmJvhTcgvuTs00ySFjTuKzM2Y6RXWqFVhUszwwttbaqbdSLg679WvktJX(L0z8gKllZnfzb67nD1KqwSD)olAUg9y9lHXMLhWcriAXYYILFhzrFngSy7(DW6zrbOxsIfOV3dxPyzz9xmYINWSSOilqFVPRMeYcizrdjalZbS1sZc99aruww5Fkw0qwEVjHpL3Wd)bsQXbibIG803B6QjHA6graX7Z1vObUrpUA7uQ6WvQkym0cX7Z1vOH(EpCLQAdKFD4kvfmgAJeI3NRRqZrkbnwPV30vtcNMkRVgdJUR8mGvWO6kv93VKeTM(VA0qFpq08LyAsFnggDx5zaRGr1vQ6VFjjA17GNOH(EGO5lXmTuluPQV3KWNAOV3dxPiOgQfI3NRRqd99E4kv1gi)6WvQkym4nixwMBkYc1M3XSqbS87(ZsuWIfs4ZsStywww)fJSOhLLf9ssSCploLfL)iloLflaLE6kKfqYIcPuw(DpzPeSqFpqeLfqZIM)l6ZITDmzPeeGf67bIOSGe26AK3Wd)bsQXbibIG8oSB9heSsT5DSMcrdkS(EtcFAeeRPBerK)fi6ssAJ0d)bsJd7w)bbRuBEhxH9yNeAUSouhP9FAcg8gh2T(dcwP28oUc7Xoj0qFpqeblHwyWBCy36piyLAZ74kSh7KqtJX(LucwcEdYLLsAC0iDNfczaihxJSCdwi7wj)CLbwokln6Wr1el)o2ilEJSOqkLLF3twidlV3KWNYYLSOrR0Bw04G6SOil2UFNfOGNqPjwuiLYYV7jleVjlGFhBBhfz5sw8mklACqDwuKfqZYYILhWczy59Me(uw0XbOrwCw0Ov6nlACqDwu0WIMdKB)S04Or6olWR(ssSus9s4gHzrJJTa2WogZNLvQqkLLlzbkq5nlACqDwuK3Wd)bsQXbibIG8XaqoUg1uiAqH13Bs4tJGynDJiAC0iD31vO23Bs4B(lgRpOcF48LltSgsGYuluPQV3KWNAOV3JRXszFP0xJHbdQZIIv1k92SSMnJang7xsNPzktmbExH5BEBxwJbGKAW01vi8mTo9BxvTa2WEEiEFUUcn0rnaOVgOVgdd99E4kLPXy)sAP0SAl7w1WogiAAcI3NRRqZrkbnwPV30vtcNMIedQZIIMlREgDM2YbaqbdSLMGxVmyA0HJQfdQZIIMlREgvBziEFUUcnbqcbqewHrA0mmnfaafmWwAcGecGiS(7yLAD99utJoC0PPidaiy65BYJ0(xhooBAIAHkv99Me(ud99ECnsWYLTlnOS(AmmyqDwuSQwP3MLvPkXSzLQmXe4DfMV5TDzngasQbtxxHWZMPnsmOolkAOaL31ej8RTCKbaqbdSLMGxVmyA0HJoBAQmguNffnxwPaL3tt6RXWGb1zrXQALEBwwAJ8DfMVHcwQkyu)DSoansFdMUUcHNPTm1cvQ67nj8Pg6794AKGeVzPktmbExH5BEBxwJbGKAW01vi8SzZ0woYaacME(gII2NNttrQVgddrxc3iCfJTa2WogZVIj2Ko7GML10eguNffnxwPaL3Z0gP(AmmTdbtWIwhnM2jALE5yPQ7rPp2NBww8gKllZnfzHqb2clGKLaml2UFhSEwcUL1LK4n8WFGKACasGii)a0bScg10)vJA6gr4w1WogiAAcI3NRRqZrkbnwPV30vtc5n8WFGKACasGiipeVpxxHAk9ymIaCnas47pqwDaQjiUAHrugI3NRRqtaUgaj89hi1wwFngg679WvkZYAA6DfMVH(Os5DfUVXBW01vi80uaabtpFtEK2)6WXzAHbVjgaYX1O5VarxssB5i1xJHHcu0)cOzzPns91yycE9YGzzPTCKVRW8nJvhTcgvuTs0GPRRq4Pj91yycE9YGbE1(FGC(aaOGb2sZy1rRGrfvRenng7xsjGDntB5iP4x1b5IA(dB7TRQ9wHPjmOolkAUSQwP3ttyqDwu0qbkVRjs4FMwiEFUUcn)EFkvLIiryxT53RTCKbaem98n5rA)RdhNMG4956k0eajearyfgPrZW0uaauWaBPjasiaIW6VJvQ113tnng7xsjiXKzM23Bs4B(lgRpOcF486RXWe86Lbd8Q9)azP20qONnnPdOuTJJ0(xBm2VKsq91yycE9YGbE1(FGKaeBFP6vIdqtcnw9fdA4ZvvVdEEHQ1sr9EgVb5YYCtrwiunM2jkl2UFNfYUvYpxzG3Wd)bsQXbibIG8TdbtWIwhnM2jQMUre6RXWe86LbtJX(L05jMmtt6RXWe86Lbd8Q9)ajbi2(s1RehGMeAS6lg0WNRQEh88cvRLI6nbTxZQfI3NRRqtaUgaj89hiRoa5nixwMBkYcz3k5NRmWcizjaZYkviLYINWSOUez5EwwwSy7(DwiliHaic5n8WFGKACasGiiFavi9pxvD1rkJX810nIaI3NRRqtaUgaj89hiRoa1woYaacME(giy(7r7PPi7vIdqtcn0lhlvDpk9X(8PPEL4a0KqJvFXGg(Cv17GNxOATuuVNM0xJHj41ldg4v7)bY5JWEn7SPj91yyAhcMGfToAmTtuZYsR(AmmTdbtWIwhnM2jQPXy)skbjMmgYWB4H)aj14aKarq(ldEN(FGut3iciEFUUcnb4AaKW3FGS6aK3GCzzUPilACSfWg2SmhqcZcizjaZIT73zb679WvkwwwS4jmluhcYYa0SqiwkQ3S4jmlKDRKFUYaVHh(dKuJdqceb5XylGnSR6Gewt3iIYbaqbdSLMGxVmyAm2VKsa91yycE9YGbE1(FGKa9kXbOjHgR(Ibn85QQ3bpVq1APOExkITF(aaOGb2sdgBbSHDvhKWg4v7)bscq8MZMM0xJHj41ldMgJ9lPZBx8gKllL04Or6oldL3ilGKLLflpGLsWY7nj8PSy7(DW6zHSBL8ZvgyrhVKelUoy9S8awqcBDnYINWSKGNfaeSdUL1LK4n8WFGKACasGiip9rLY76q5nQPq0GcRV3KWNgbXA6gr04Or6URRqT)fJ1huHpCEIjJwQfQu13Bs4tn037X1ib1qTUvnSJbI0wwFngMGxVmyAm2VKopXBonfP(AmmbVEzWSSMXBqUSm3uKfcfqJz5gSCj9Grw8KfnoOolkYINWSOUez5EwwwSy7(DwCwielf1BwSAqGfpHzzRWU1FqqwGAZ7yEdp8hiPghGeicYpwD0kyur1krnDJiWG6SOO5YQNr1w2TQHDmq00uK9kXbOjHgR(Ibn85QQ3bpVq1APOEptBz91yyS6lg0WNRQEh88cvRLI6TbIRwibTNmBonPVgdtWRxgmng7xsN3UMPTmm4noSB9heSsT5DCf2JDsO5VarxsAAkYaacME(MednqbA4PjQfQu13Bs4tN3(zAlRVgdt7qWeSO1rJPDIAAm2VKsWsIguwdlvVsCaAsOHE5yPQ7rPp2NptR(AmmTdbtWIwhnM2jQzznnfP(AmmTdbtWIwhnM2jQzzntB5idaGcgylnbVEzWSSMM0xJH537tPQuejcBd99areKyYODCK2)AJX(LucA)MBQDCK2)AJX(L05jEZnNMIKcwk9lHn)EFkvLIiryBW01vi8mTLPGLs)syZV3NsvPise2gmDDfcpnfaafmWwAcE9YGPXy)s68LyZzAFVjHV5VyS(Gk8HZtMPjDaLQDCK2)AJX(Lucs8M8gKllZnfzXzb679Wvkw08s83zXQbbwwPcPuwG(EpCLILJYIRA0HJYYYIfqZsuWIfVrwCDW6z5bSaGGDWTyzRucbVHh(dKuJdqceb5PV3dxP00nIqFnggqI)oTAHDaT(dKMLL2Y6RXWqFVhUszAC0iD31v40Kt)2vvlGnSNVKS5mEdYLfn3k2ILTsjeSOJdqJSqwqcbqeYIT73zb679Wvkw8eMLFhtwG(EtxnjK3Wd)bsQXbibIG8037HRuA6greaqW0Z3KhP9VoCuBKVRW8n0hvkVRW9nEdMUUcH1wgI3NRRqtaKqaeHvyKgndttbaqbdSLMGxVmywwtt6RXWe86LbZYAM2aaOGb2staKqaeH1FhRuRRVNAAm2VKsqsbytSt4sfWtv2PF7QQfWg2AgiEFUUcn0rnaO)mT6RXWqFVhUszAm2VKsqnK3Wd)bsQXbibIG803B6QjHA6greaqW0Z3KhP9VoCuBziEFUUcnbqcbqewHrA0mmnfaafmWwAcE9YGzznnPVgdtWRxgmlRzAdaGcgylnbqcbqew)DSsTU(EQPXy)skbjJwiEFUUcn037HRuvBG8RdxPQGXqlguNffnxw9mQ2iH4956k0CKsqJv67nD1KqEdYLL5MISa99MUAsil2UFNfpzrZlXFNfRgeyb0SCdwIcwBdZcac2b3ILTsjeSy7(DwIcwnljs4NLGtFdlBvrbSaVITyzRucbl(ZYVJSGjmlGbl)oYsjfm)9Onl6RXGLBWc037HRuSydSuW52pldxPybmgSaAwIcwS4nYcizXEwEVjHpL3Wd)bsQXbibIG803B6QjHA6grOVgddiXFNwdk07kKJEG0SSMMkhj99ECnACRAyhdePnsiEFUUcnhPe0yL(EtxnjCAQS(AmmbVEzW0ySFjLGKrR(AmmbVEzWSSMMkxwFngMGxVmyAm2VKsqsbytSt4sfWtv2PF7QQfWg2AgiEFUUcnuAnaO)mT6RXWe86LbZYAAsFngM2HGjyrRJgt7eTsVCSu19O0h7Znng7xsjiPaSj2jCPc4Pk70VDv1cydBndeVpxxHgkTga0FMw91yyAhcMGfToAmTt0k9YXsv3JsFSp3SSMPnaGGPNVbcM)E0E2mTLPwOsvFVjHp1qFVhUsrWsmnbX7Z1vOH(EpCLQAdKFD4kvfmgZMPnsiEFUUcnhPe0yL(EtxnjuB5i7vIdqtcn)fJ2aDwHB0J1Veg7PjQfQu13Bs4tn037HRueSeZ4nixwMBkYcHmaKuwUKfOaL3SOXb1zrrw8eMfQdbzHqTukwiKbGKLbOzHSBL8Zvg4n8WFGKACasGiiFI2QXaqQPBerz91yyWG6SOyLcuEBAm2VKopsymSES(xmonvoS7njKgH9ABmS7njS(xmsqYmBAkS7njKgrjMP1TQHDmqeVHh(dKuJdqceb53D1OgdaPMUreL1xJHbdQZIIvkq5TPXy)s68iHXW6X6FX40u5WU3KqAe2RTXWU3KW6FXibjZSPPWU3KqAeLyMw3Qg2XarAlRVgdt7qWeSO1rJPDIAAm2VKsqYOvFngM2HGjyrRJgt7e1SS0gzVsCaAsOHE5yPQ7rPp2NpnfP(AmmTdbtWIwhnM2jQzznJ3Wd)bsQXbibIG8JLsvJbGut3iIY6RXWGb1zrXkfO820ySFjDEKWyy9y9VyuB5aaOGb2stWRxgmng7xsNNmBonfaafmWwAcGecGiS(7yLAD99utJX(L05jZMZMMkh29MesJWETng29Mew)lgjizMnnf29MesJOeZ06w1WogisBz91yyAhcMGfToAmTtutJX(LucsgT6RXW0oemblAD0yANOMLL2i7vIdqtcn0lhlvDpk9X(8PPi1xJHPDiycw06OX0ornlRz8gKllZnfzHqcOXSaswiRMJ3Wd)bsQXbibIG828UpqxbJkQwjYBqUSqwxfwk)rkl22XFhBwEallkYc037X1ilxYcuGYBwSTFHDwokl(Zczy59Me(ucqmldqZccb7OSy)MAgwID6JDuwanlAilqFVPRMeYIghBbSHDmMpl03der5n8WFGKACasGiipeVpxxHAk9ymc6794ASEzLcuERjiUAHrqTqLQ(EtcFQH(EpUgNxdjWqbaD5yN(yhTcXvlSueV5MAg73CgbgkaOlRVgdd99MUAsyfJTa2WogZVsbkVn03dePz0Wz8gKllAEjl2ZY7nj8PSy7(DW6zbkyPybmy53rwiuGgPplrblwO7GLcMLXPuSy7(DwiKA)3zbE1xsIL5kd8gE4pqsnoajqeK3w7)UMUrerQVgdt7qWeSO1rJPDIAwwAJuFngM2HGjyrRJgt7eTsVCSu19O0h7ZnllTr(UcZ3qblvfmQ)owhGgPVbtxxHWAPwOsvFVjHp1qFVhxJeSeA1xJHbdQZIIvkq5TPXy)s68iHXW6X6FXO2XrA)Rng7xsNxFngMGxVmyAm2VKsaITVu9kXbOjHgR(Ibn85QQ3bpVq1APOEZBqUSqwxfwk)rkl22XFhBwEalesT)7SaV6ljXcHQX0or5n8WFGKACasGiipeVpxxHAk9ymcBT)71lRJgt7evtqC1cJGynd1cvQ6UtFKG2RbL30yFPkxMAHkv99Me(ud99ECnQbeptZuUm1cvQ67nj8Pg6794AudiEMMX(njaXZMvQYetG3vy(gkyPQGr93X6a0i9ny66keUueBiZSzeytdXKPu6RXW0oemblAD0yANOMgJ9lP8gKllZnfzHqQ9FNLlzbkq5nlACqDwuKfqZYnyjbSa99ECnYITtPyzCplx(awi7wj)CLbw8mAmOrEdp8hiPghGeicYBR9Fxt3iIYyqDwu0OwP31ej8pnHb1zrrJNrRjs4xleVpxxHMJwdk0HGZ0w(9Me(M)IX6dQWhoVgonHb1zrrJALExVSA)0KoGs1oos7FTXy)skbjEZztt6RXWGb1zrXkfO820ySFjLGE4pqAOV3JRrdsymSES(xmQvFnggmOolkwPaL3ML10eguNffnxwPaL3AJeI3NRRqd99ECnwVSsbkVNM0xJHj41ldMgJ9lPe0d)bsd99ECnAqcJH1J1)IrTrcX7Z1vO5O1GcDiOw91yycE9YGPXy)skbrcJH1J1)IrT6RXWe86LbZYAAsFngM2HGjyrRJgt7e1SS0cX7Z1vOXw7)E9Y6OX0orNMIeI3NRRqZrRbf6qqT6RXWe86LbtJX(L05rcJH1J1)IrEdYLL5MISa99ECnYYny5sw0Ov6nlACqDwuutSCjlqbkVzrJdQZIISasw0qcWY7nj8PSaAwEalwniWcuGYBw04G6SOiVHh(dKuJdqceb5PV3JRrEdYLfcLRu)EV4n8WFGKACasGiiFVYQh(dKv1rFnLEmgXWvQFVx8g8gKllqFVPRMeYYa0SedGGXy(SSsfsPSSOxsIL5a2AP5n8WFGKAgUs979kc67nD1KqnDJiISxjoanj0O7kpdyfmQUsv)9ljrnODVolleM3GCzHSo9z53rwGbpl2UFNLFhzjgqFw(lgz5bS4WWSSY)uS87ilXoHzbE1(FGKLJYY(9gwGUYX1ilng7xszjEP(ZsDimlpGLy)d7Seda54AKf4v7)bsEdp8hiPMHRu)EViqeKNUYX1OMcrdkS(EtcFAeeRPBebm4nXaqoUgnng7xsNVXy)sAPS3EndX2fVHh(dKuZWvQFVxeicYhda54AK3G3GCzzUPilBf2T(dcYcuBEhZITDmz53Xgz5OSKaw8WFqqwO28owtS4uwu(JS4uwSau6PRqwajluBEhZIT73zXEwanld0g2SqFpqeLfqZcizXzPeeGfQnVJzHcy539NLFhzjrBSqT5DmlE3heKYIM)l6ZIpESz539NfQnVJzbjS11iL3Wd)bsQH(r4WU1FqWk1M3XAkenOW67nj8PrqSMUrercdEJd7w)bbRuBEhxH9yNeA(lq0LK0gPh(dKgh2T(dcwP28oUc7Xoj0CzDOos7V2YrcdEJd7w)bbRuBEhx3rxz(lq0LKMMGbVXHDR)GGvQnVJR7ORmng7xsNNmZMMGbVXHDR)GGvQnVJRWEStcn03derWsOfg8gh2T(dcwP28oUc7Xoj00ySFjLGLqlm4noSB9heSsT5DCf2JDsO5VarxsI3GCzzUPiLfYcsiaIqwUblKDRKFUYalhLLLflGMLOGflEJSaJ0Oz4ssSq2Ts(5kdSy7(DwiliHaiczXtywIcwS4nYIoQa2yrd3K8LyZYKfvi9pxXcuRRVNoJLTsjeSCjloleVjbyHIbw04G6SOOHLTQOawGb52plk8zrZ1OhRFjm2SGe26AutS4kBEukllkYYLSq2Ts(5kdSy7(Dwielf1Bw8eMf)z53rwOV3plGblolZbS1sZITlHb2m8gE4pqsn0Narq(aiHaicR)owPwxFpvt3iIYLH4956k0eajearyfgPrZG2idaGcgylnbVEzW0OdhvBK9kXbOjHgR(Ibn85QQ3bpVq1APOEpnPVgdtWRxgmllTLJSxjoanj0y1xmOHpxv9o45fQwlf17PPEL4a0Kqtavi9pxvPwxFpDAACK2)AJX(L05j2Ec90KoGs1oos7FTXy)skbdaGcgylnbVEzW0ySFjLaeV50K(AmmbVEzW0ySFjDEITF2mTLl70VDv1cydBcgbeVpxxHMaiHaicRo1sBz91yyWG6SOyvTsVnng7xsNN4nNM0xJHbdQZIIvkq5TPXy)s68eV5SPj91yycE9YGPXy)s68KrR(AmmbVEzW0ySFjLGrqS9Z0woYEL4a0KqZFXOnqNv4g9y9lHXEAkYEL4a0Kqtavi9pxvPwxFpDAsFngM)IrBGoRWn6X6xcJTPXy)s68iHXW6X6FX4SPPEL4a0KqJUR8mGvWO6kv93VKeDM2Yr2RehGMeA0DLNbScgvxPQ)(LKOttL1xJHr3vEgWkyuDLQ(7xsIwt)xnAOVhikc7AAsFnggDx5zaRGr1vQ6VFjjA17GNOH(EGOiSRzZMM0buQ2XrA)Rng7xsjiXBQnYaaOGb2stWRxgmn6WrNXBqUSm3uKfOV30vtcz5bSqeIwSSSy53rw0Cn6X6xcJnl6RXGLBWY9SydSuWSGe26AKfDCaAKLXLhD)ssS87iljs4NLGtFwanlpGf4vSfl64a0ilKfKqaeH8gE4pqsn0NarqE67nD1KqnDJi6vIdqtcn)fJ2aDwHB0J1VegBTLJSCz91yy(lgTb6Sc3OhRFjm2MgJ9lPZ7H)aPXw7)Ubjmgwpw)lgjWMgI1wgdQZIIMlR6GFFAcdQZIIMlRuGY7PjmOolkAuR07AIe(NnnPVgdZFXOnqNv4g9y9lHX20ySFjDEp8hin037X1Objmgwpw)lgjWMgI1wgdQZIIMlRQv690eguNffnuGY7AIe(NMWG6SOOXZO1ej8pB20uK6RXW8xmAd0zfUrpw)sySnlRzttL1xJHj41ldML10eeVpxxHMaiHaicRWinAgMPnaakyGT0eajeary93Xk1667PMgD4OAdaiy65BYJ0(xhoQTS(AmmyqDwuSQwP3MgJ9lPZt8Mtt6RXWGb1zrXkfO820ySFjDEI3C2mTLJmaGGPNVHOO9550uaauWaBPbJTa2WUQdsytJX(L05TRz8gKllAUvSflqFVPRMeszX297Smhx5zazbmyzRkflLE)ssuwanlpGfRgT8gzzaAwiliHaiczX297SmhWwlnVHh(dKud9jqeKN(Etxnjut3iIEL4a0KqJUR8mGvWO6kv93VKevB5Y6RXWO7kpdyfmQUsv)9ljrRP)Rgn03denV9tt6RXWO7kpdyfmQUsv)9ljrREh8en03denV9Z0gaafmWwAcE9YGPXy)s68eATrgaafmWwAcGecGiS(7yLAD99uZYAAQCaabtpFtEK2)6WrTbaqbdSLMaiHaicR)owPwxFp10ySFjLGeVPwmOolkAUS6zuTo9BxvTa2WEE73KaLyZsfaafmWwAcE9YGPrho6Sz8gKllKfKW3FGKLbOzXvkwGbpLLF3FwIDIqkl0vJS87yuw8gZTFwAC0iDhHzX2oMSus7qWeSOSqOAmTtuw2DklkKsz539KfYWcfduwAm2V8ssSaAw(DKfno2cydBwMdiHzrFngSCuwCDW6z5bSmCLIfWyWcOzXZOSOXb1zrrwoklUoy9S8awqcBDnYB4H)aj1qFceb5H4956kutPhJrad(AJ296AmgZNQjiUAHruwFngM2HGjyrRJgt7e10ySFjDEYmnfP(AmmTdbtWIwhnM2jQzzntBK6RXW0oemblAD0yANOv6LJLQUhL(yFUzzPTS(AmmeDjCJWvm2cyd7ym)kMyt6SdAAm2VKsqsbytSt4zAlRVgddguNffRuGYBtJX(L05jfGnXoHNM0xJHbdQZIIv1k920ySFjDEsbytSt4PPYrQVgddguNffRQv6TzznnfP(AmmyqDwuSsbkVnlRzAJ8DfMVHcu0)cObtxxHWZ4nixwiliHV)ajl)U)Se2XaruwUblrblw8gzbSE6bJSGb1zrrwEalGufLfyWZYVJnYcOz5iLGgz53pkl2UFNfOaf9VaYB4H)aj1qFceb5H4956kutPhJrad(ky90dgRyqDwuutqC1cJOCK6RXWGb1zrXkfO82SS0gP(AmmyqDwuSQwP3ML1mTr(UcZ3qbk6Fb0GPRRqyTr2RehGMeA(lgTb6Sc3OhRFjm28gKllAoWZIRuS8EtcFkl2UF)swieEcJXxGfB3VdwplaiyhClRljrGFhzX1bqqwcGe((dKuEdp8hiPg6tGiiFmaKJRrnfIguy99Me(0iiwt3iIY6RXWGb1zrXkfO820ySFjD(gJ9lPtt6RXWGb1zrXQALEBAm2VKoFJX(L0PjiEFUUcnWGVcwp9GXkguNffNPTXrJ0DxxHAFVjHV5VyS(Gk8HZtS9ADRAyhdePfI3NRRqdm4RnA3RRXymFkVHh(dKud9jqeKNUYX1OMcrdkS(EtcFAeeRPBerz91yyWG6SOyLcuEBAm2VKoFJX(L0Pj91yyWG6SOyvTsVnng7xsNVXy)s60eeVpxxHgyWxbRNEWyfdQZIIZ024Or6URRqTV3KW38xmwFqf(W5j2ETUvnSJbI0cX7Z1vObg81gT711ymMpL3Wd)bsQH(eicYtFuP8UouEJAkenOW67nj8PrqSMUreL1xJHbdQZIIvkq5TPXy)s68ng7xsNM0xJHbdQZIIv1k920ySFjD(gJ9lPttq8(CDfAGbFfSE6bJvmOolkotBJJgP7UUc1(EtcFZFXy9bv4dNNynRw3Qg2XarAH4956k0ad(AJ296AmgZNYBqUSO5apl9rA)zrhhGgzHq1yANOSCdwUNfBGLcMfxPa2yjkyXYdyPXrJ0DwuiLYc8QVKeleQgt7eLLY)(rzbKQOSS7wwyszX297G1Zc0lhlflA(fL(yF(mEdp8hiPg6tGiipeVpxxHAk9ymIeu3JsFSpVIERIwHbVMG4QfgraabtpFdem)9OT2i7vIdqtcn0lhlvDpk9X(CTr2RehGMeAcxhuyfmQQBGvpHRWO)7AdaGcgyln6ytXMOljzA0HJQnaakyGT00oemblAD0yANOMgD4OAJuFngMGxVmywwAl70VDv1cyd75Tlc90K(Amm6kaawTOVzznJ3Wd)bsQH(eicYhda54Aut3iciEFUUcnjOUhL(yFEf9wfTcdETng7xsjO9BYB4H)aj1qFceb5PRCCnQPBebeVpxxHMeu3JsFSpVIERIwHbV2gJ9lPeK4scVb5YYCtrwiuGTWcizjaZIT73bRNLGBzDjjEdp8hiPg6tGii)a0bScg10)vJA6gr4w1WogiI3GCzzUPilACSfWg2SmhqcZIT73zXZOSOajjwWeSiTZIYP)LKyrJdQZIIS4jmlFhLLhWI6sKL7zzzXIT73zHqSuuVzXtywi7wj)CLbEdp8hiPg6tGiipgBbSHDvhKWA6gruoaakyGT0e86LbtJX(LucOVgdtWRxgmWR2)dKeOxjoanj0y1xmOHpxv9o45fQwlf17srS9ZhaafmWwAWylGnSR6Ge2aVA)pqsaI3C20K(AmmbVEzW0ySFjDE7I3GCzbk(uwSTJjlBLsiyHUdwkyw0rwGxXwimlpGLe8SaGGDWTyPSMdTWeMYcizHqT6OSagSOXQvIS4jml)oYIghuNffNXB4H)aj1qFceb5H4956kutPhJr4uRk8k2stqC1cJWPF7QQfWg2Zxs2udkBVHmLsFngMXQJwbJkQwjAOVhisdSVuyqDwu0CzvTsVNXBqUSm3uKfYUvYpxzGfB3VZczbjeari5lPEjCJWSa1667PS4jmlWGC7NfaeST13JSqiwkQ3SaAwSTJjlZrbaWQf9zXgyPGzbjS11il64a0ilKDRKFUYaliHTUgPgwiKDIqwORgz5bSG5JnlolA0k9MfnoOolkYITDmzzrpsjlL2E7If7TcS4jmlUsXcz1CuwSDkfl6yaeJS0OdhLfkaKSGjyrANf4vFjjw(DKf91yWINWSadEkl7oeKfDetwORX4chMVkklnoAKUJWgEdp8hiPg6tGiipeVpxxHAk9ymIaCnas47pqwPVMG4QfgrziEFUUcnb4AaKW3FGuBK6RXWe86LbZYsB5iP4x1b5IA(dB7TRQ9wHPjmOolkAUSQwP3ttyqDwu0qbkVRjs4FM2YLldX7Z1vOXPwv4vS10uaabtpFtEK2)6WXPPYbaem98nefTpp1gaafmWwAWylGnSR6Ge20OdhD20uVsCaAsO5Vy0gOZkCJES(LWyptlm4n0voUgnng7xsN3U0cdEtmaKJRrtJX(L05ljAlddEd9rLY76q5nAAm2VKopXBonf57kmFd9rLY76q5nAW01vi8mTq8(CDfA(9(uQkfrIWUAZVx77nj8n)fJ1huHpCE91yycE9YGbE1(FGSuBAi0tt6RXWORaay1I(MLLw91yy0vaaSArFtJX(LucQVgdtWRxgmWR2)dKeOmX2xQEL4a0KqJvFXGg(Cv17GNxOATuuVNnBAQmA3RZYcHnySv0gDvf0WPNbuBaauWaBPbJTI2ORQGgo9mGMgJ9lPeKynlHMaLjtP6vIdqtcn0lhlvDpk9X(8zZMPTC5idaiy65BYJ0(xhoonvgI3NRRqtaKqaeHvyKgndttbaqbdSLMaiHaicR)owPwxFp10ySFjLGetMzAlhzVsCaAsOr3vEgWkyuDLQ(7xsIon50VDv1cydBcsMn1gaafmWwAcGecGiS(7yLAD99utJoC0zZMMghP9V2ySFjLGbaqbdSLMaiHaicR)owPwxFp10ySFjD20KoGs1oos7FTXy)skb1xJHj41ldg4v7)bscqS9LQxjoanj0y1xmOHpxv9o45fQwlf17z8gKllZnfzHq1yANOSy7(Dwi7wj)CLbwwPcPuwiunM2jkl2alfmlkN(SOajjSz539KfYUvYpxzqtS87yYYIISOJdqJ8gE4pqsn0Narq(2HGjyrRJgt7evt3ic91yycE9YGPXy)s68etMPj91yycE9YGbE1(FGKG2tOjqVsCaAsOXQVyqdFUQ6DWZluTwkQ3LIy71cX7Z1vOjaxdGe((dKv6ZB4H)aj1qFceb5dOcP)5QQRoszmMVMUreq8(CDfAcW1aiHV)azL(AlRVgdtWRxgmWR2)dKZhH9eAc0RehGMeAS6lg0WNRQEh88cvRLI6DPi2(PPidaiy65BGG5VhTNnnPVgdt7qWeSO1rJPDIAwwA1xJHPDiycw06OX0ornng7xsjyjHabqcVU3y1y4Oy1vhPmgZ38xmwH4QfsGYrQVgdJUcaGvl6BwwAJ8DfMVH(ERanSbtxxHWZ4n8WFGKAOpbIG8xg8o9)aPMUreq8(CDfAcW1aiHV)azL(8gKllLu8(CDfYYIIWSaswC9tD)Huw(D)zXMNplpGfDKfQdbHzzaAwi7wj)CLbwOaw(D)z53XOS4nMpl2C6JWSO5)I(SOJdqJS87ymVHh(dKud9jqeKhI3NRRqnLEmgb1HG1bORbVEzqtqC1cJiaakyGT0e86LbtJX(L05jEZPPiH4956k0eajearyfgPrZG2aacME(M8iT)1HJ8gKllZnfPSqOaAml3GLlzXtw04G6SOilEcZY3hsz5bSOUez5EwwwSy7(Dwielf1BnXcz3k5NRmOjw04ylGnSzzoGeMfpHzzRWU1FqqwGAZ7yEdp8hiPg6tGii)y1rRGrfvRe10nIadQZIIMlREgvBzN(TRQwaBytWsI9AG(AmmJvhTcgvuTs0qFpquPiZ0K(AmmTdbtWIwhnM2jQzzntBz91yyS6lg0WNRQEh88cvRLI6TbIRwibTxd3CAsFngMGxVmyAm2VKoVDntleVpxxHgQdbRdqxdE9YG2YrgaqW0Z3KyObkqdpnbdEJd7w)bbRuBEhxH9yNeA(lq0LKMPTCKbaem98nqW83J2tt6RXW0oemblAD0yANOMgJ9lPeSKObL1Ws1RehGMeAOxowQ6Eu6J95Z0QVgdt7qWeSO1rJPDIAwwttrQVgdt7qWeSO1rJPDIAwwZ0woYaacME(gII2NNttbaqbdSLgm2cyd7QoiHnng7xsN3(nNP99Me(M)IX6dQWhopzMM0buQ2XrA)Rng7xsjiXBYBqUSqi53ZIZcn2vkwIbXy(S4JhBwiunM2jkl3GLOGflEJS46G1ZYdyj40NfNfQfMWyZB4H)aj1qFceb5T53RjkgIytdXKrd8WFG00oemblAD0yANOM)IXk9YaQPBeraabtpFdem)9OTwRgHyi20oemblAD0yANOA9WFG00oemblAD0yANOM)IXk9YasWnnetgTq8(CDfACQvfEfBXBqUSm3uKfnVe)DwG(EpCLIfRgeOSCdwG(EpCLILJMB)SSS4n8WFGKAOpbIG8037HRuA6grOVgddiXFNwTWoGw)bsZYsR(Amm037HRuMghns3DDfYBqUSqwpdOIfOV3kqdZYny5Ew2DklkKsz539KfYqzPXy)YljPjwIcwS4nYI)Sus2KaSSvkHGfpHz53rwcRUX8zrJdQZIISS7uwidbOS0ySF5LK4n8WFGKAOpbIG8bpdOQQVgdnLEmgb99wbAynDJi0xJHH(ERanSPXy)skbjJ2Y6RXWGb1zrXkfO820ySFjDEYmnPVgddguNffRQv6TPXy)s68KzMwN(TRQwaBypFjztEdYLfO4tzX2oMSqiwkQ3Sq3blfml6ilwnieqywqVvrz5bSOJS46kKLhWYIISqwqcbqeYcizjaakyGTKLYAmLI5FUsfLfDmaIrklFVqwUblWRyRljXYwPecwsGnwSDkflUsbSXsuWILhWIf2dm8QOSG5JnleILI6nlEcZYVJjllkYczbjear4mEdp8hiPg6tGiipeVpxxHAk9ymcRgeQwlf17k6TkQMG4QfgraabtpFtEK2)6WrT9kXbOjHgR(Ibn85QQ3bpVq1APOERvFnggR(Ibn85QQ3bpVq1APOEBG4QfsaN(TRQwaBytGsmFeLyZn1cX7Z1vOjasiaIWkmsJMbTbaqbdSLMaiHaicR)owPwxFp10ySFjLGo9BxvTa2WwZuInlfPaSj2jSwmOolkAUS6zuTo9BxvTa2WEEiEFUUcnbqcbqewDQL2aaOGb2stWRxgmng7xsNNm8gKllZnfzb679WvkwSD)olqFuP8MfnxFJNfqZYBVDXIgAfyXtywsalqFVvGgwtSyBhtwsalqFVhUsXYrzzzXcOz5bSy1GaleILI6nl22XKfxhabzPKSjlBLsikdAw(DKf0Bvuwielf1BwSAqGfiEFUUcz5OS89cNXcOzXHT8)GGSqT5Dml7oLf7IaumqzPXy)YljXcOz5OSCjld1rA)5n8WFGKAOpbIG8037HRuA6gru(DfMVH(Os5DfUVXBW01vi80ef)QoixuZFyBVDv1qRWmTr(UcZ3qFVvGg2GPRRqyT6RXWqFVhUszAC0iD31vO2i7vIdqtcn)fJ2aDwHB0J1VegBTL1xJHXQVyqdFUQ6DWZluTwkQ3giUAHZhH9KztTrQVgdtWRxgmllTLH4956k04uRk8k2AAsFnggIUeUr4kgBbSHDmMFftSjD2bnlRPjiEFUUcnwniuTwkQ3v0Bv0zttLdaiy65Bsm0afOH1(UcZ3qFuP8Uc334ny66kewBzyWBCy36piyLAZ74kSh7KqtJX(L05TRPjp8hinoSB9heSsT5DCf2JDsO5Y6qDK2)zZMPTCaauWaBPj41ldMgJ9lPZt8MttbaqbdSLMaiHaicR)owPwxFp10ySFjDEI3CgVb5YIMBfBrzzRucbl64a0ilKfKqaeHSSOxsILFhzHSGecGiKLaiHV)ajlpGLWogiILBWczbjearilhLfp8lxPIYIRdwplpGfDKLGtFEdp8hiPg6tGiip99MUAsOMUreq8(CDfASAqOATuuVRO3QO8gKllZnfzHqgaskl22XKLOGflEJS46G1ZYdiV3ilb3Y6ssSe29MeszXtywIDIqwORgz53XOS4nYYLS4jlACqDwuKf6FkfldqZIMFeYKNqriZB4H)aj1qFceb5t0wngasnDJiCRAyhdePTCy3Bsinc712yy3Bsy9VyKGKzAkS7njKgrjMXB4H)aj1qFceb53D1OgdaPMUreUvnSJbI0woS7njKgH9ABmS7njS(xmsqYmnf29MesJOeZ0wwFnggmOolkwvR0BtJX(L05rcJH1J1)IXPj91yyWG6SOyLcuEBAm2VKopsymSES(xmoJ3Wd)bsQH(eicYpwkvngasnDJiCRAyhdePTCy3Bsinc712yy3Bsy9VyKGKzAkS7njKgrjMPTS(AmmyqDwuSQwP3MgJ9lPZJegdRhR)fJtt6RXWGb1zrXkfO820ySFjDEKWyy9y9VyCgVb5YYCtrwG(EtxnjKfnVe)DwSAqGYINWSaVITyzRucbl22XKfYUvYpxzqtSOXXwaByZYCajSMy53rwkPG5VhTzrFngSCuwCDW6z5bSmCLIfWyWcOzjkyTnmlb3ILTsje8gE4pqsn0NarqE67nD1KqnDJiWG6SOO5YQNr1wwFnggqI)oTguO3vih9aPzznnPVgddrxc3iCfJTa2WogZVIj2Ko7GML10K(AmmbVEzWSS0woYaacME(gII2NNttbaqbdSLgm2cyd7QoiHnng7xsNNmtt6RXWe86LbtJX(LucskaBIDcxQHca6Yo9BxvTa2WwZaX7Z1vOHsRba9NntB5idaiy65BGG5VhTNM0xJHPDiycw06OX0ornng7xsjiPaSj2jCPc4Pkx2PF7QQfWg2eqd3SuVRW8nJvhTcgvuTs0GPRRq4zAgiEFUUcnuAnaO)mcuIs9UcZ3KOTAmaKgmDDfcRnYEL4a0Kqd9YXsv3JsFSpxR(AmmTdbtWIwhnM2jQzznnPVgdt7qWeSO1rJPDIwPxowQ6Eu6J95ML10uz91yyAhcMGfToAmTtutJX(Luc6H)aPH(EpUgniHXW6X6FXOwQfQu1DN(ib30OHtt6RXW0oemblAD0yANOMgJ9lPe0d)bsJT2)DdsymSES(xmonPVgdJvFXGg(Cv17GNxOATuuVnqC1cNpc7jEtTLD63UQAbSH98q8(CDfAO0Aaq)szVgqMPj91yyAhcMGfToAmTtutJX(L05TFMw91yyAhcMGfToAmTtutJX(LucQzNMG4956k0C2nCnas47pqQnaakyGT0Cjn0R31vy1UxE(R4kmc5cOPrhoQw0UxNLfcBUKg6176kSA3lp)vCfgHCbCMw91yyAhcMGfToAmTtuZYAAks91yyAhcMGfToAmTtuZYsBKbaqbdSLM2HGjyrRJgt7e10OdhD20eeVpxxHgNAvHxXwtt6akv74iT)1gJ9lPeKua2e7eUub8uLD63UQAbSHTMbI3NRRqdLwda6pBgVb5YsP7OS8awIDIqw(DKfDK(SagSa99wbAyw0JYc99arxsIL7zzzXIDVUarQOSCjlEgLfnoOolkYI(6zHqSuuVz5O52plUoy9S8aw0rwSAqiGW8gE4pqsn0NarqE67nD1KqnDJiExH5BOV3kqdBW01viS2i7vIdqtcn)fJ2aDwHB0J1VegBTL1xJHH(ERanSzznn50VDv1cyd75ljBotR(Amm03BfOHn03derWsOTS(AmmyqDwuSsbkVnlRPj91yyWG6SOyvTsVnlRzA1xJHXQVyqdFUQ6DWZluTwkQ3giUAHe0Ec9MAlhaafmWwAcE9YGPXy)s68eV50uKq8(CDfAcGecGiScJ0OzqBaabtpFtEK2)6WXz8gKllAm9Vy)rkl7aBSeVc7SSvkHGfVrwi5xIWSyHnlumasydlAEPkklVteszXzHMUfDh8Smanl)oYsy1nMpl07x(FGKfkGfBGLco3(zrhzXdHv7pYYa0SO8Me2S8xmoApgP8gE4pqsn0NarqEiEFUUc1u6Xyeo1IqGnumOjiUAHrGb1zrrZLv1k9Uu2LMXd)bsd99ECnAqcJH1J1)IrcejguNffnxwvR07svwZsG3vy(gkyPQGr93X6a0i9ny66keUuLyMMXd)bsJT2)DdsymSES(xmsGnnAiz0muluPQ7o9rcSPHmL6DfMVj9F1iTQ7kpdObtxxHW8gKllAUvSflqFVPRMeYYLS4jlACqDwuKfNYcfaswCklwak90viloLffijXItzjkyXITtPybtywwwSy7(DwSRnjal22XKfmFSVKel)oYsIe(zrJdQZIIAIfyqU9ZIcFwUNfRgeyHqSuuV1elWGC7NfaeST13JS4jlAEj(7Sy1GalEcZIfaOyrhhGgzHSBL8ZvgyXtyw04ylGnSzzoGeM3Wd)bsQH(eicYtFVPRMeQPBerK9kXbOjHM)IrBGoRWn6X6xcJT2Y6RXWy1xmOHpxv9o45fQwlf1BdexTqcApHEZPj91yyS6lg0WNRQEh88cvRLI6TbIRwibTNmBQ9DfMVH(Os5DfUVXBW01vi8mTLXG6SOO5YkfO8wRt)2vvlGnSjaeVpxxHgNAriWgkgkL(AmmyqDwuSsbkVnng7xsjam4nJvhTcgvuTs08xGiATXy)YszVHmZBxBonHb1zrrZLv1k9wRt)2vvlGnSjaeVpxxHgNAriWgkgkL(AmmyqDwuSQwP3MgJ9lPeag8MXQJwbJkQwjA(lqeT2ySFzPS3qM5ljBotBK6RXWas83PvlSdO1FG0SS0g57kmFd99wbAydMUUcH1woaakyGT0e86LbtJX(L05j0ttuWsPFjS537tPQuejcBdMUUcH1QVgdZV3NsvPise2g67bIiyjkHguUxjoanj0qVCSu19O0h7ZlL9Z0oos7FTXy)s68eV5MAhhP9V2ySFjLG2V5MZ0woYaacME(gII2NNttbaqbdSLgm2cyd7QoiHnng7xsN3(z8gKllZnfzHqgasklxYINrzrJdQZIIS4jmluhcYIMFUAqac1sPyHqgaswgGMfYUvYpxzGfpHzPK6LWncZIghBbSHDmMVHLTQOawwuKLTqiZINWSqOiKzXFw(DKfmHzbmyHq1yANOS4jmlWGC7Nff(SO5A0J1VegBwgUsXcym4n8WFGKAOpbIG8jARgdaPMUreUvnSJbI0cX7Z1vOH6qW6a01GxVmOTS(AmmyqDwuSQwP3MgJ9lPZJegdRhR)fJtt6RXWGb1zrXkfO820ySFjDEKWyy9y9VyCgVHh(dKud9jqeKF3vJAmaKA6gr4w1WogisleVpxxHgQdbRdqxdE9YG2Y6RXWGb1zrXQALEBAm2VKopsymSES(xmonPVgddguNffRuGYBtJX(L05rcJH1J1)IXzAlRVgdtWRxgmlRPj91yyS6lg0WNRQEh88cvRLI6TbIRwibJWEI3CM2YrgaqW0Z3abZFpApnPVgdt7qWeSO1rJPDIAAm2VKsWYKrdSVu9kXbOjHg6LJLQUhL(yF(mT6RXW0oemblAD0yANOML10uK6RXW0oemblAD0yANOML1mTLJSxjoanj08xmAd0zfUrpw)sySNMqcJH1J1)IrcQVgdZFXOnqNv4g9y9lHX20ySFjDAks91yy(lgTb6Sc3OhRFjm2ML1mEdp8hiPg6tGii)yPu1yai10nIWTQHDmqKwiEFUUcnuhcwhGUg86LbTL1xJHbdQZIIv1k920ySFjDEKWyy9y9VyCAsFnggmOolkwPaL3MgJ9lPZJegdRhR)fJZ0wwFngMGxVmywwtt6RXWy1xmOHpxv9o45fQwlf1BdexTqcgH9eV5mTLJmaGGPNVHOO9550K(AmmeDjCJWvm2cyd7ym)kMyt6SdAwwZ0woYaacME(giy(7r7Pj91yyAhcMGfToAmTtutJX(LucsgT6RXW0oemblAD0yANOMLL2i7vIdqtcn0lhlvDpk9X(8PPi1xJHPDiycw06OX0ornlRzAlhzVsCaAsO5Vy0gOZkCJES(LWypnHegdRhR)fJeuFngM)IrBGoRWn6X6xcJTPXy)s60uK6RXW8xmAd0zfUrpw)sySnlRz8gKllZnfzHqcOXSaswcW8gE4pqsn0NarqEBE3hORGrfvRe5nixwMBkYc037X1ilpGfRgeybkq5nlACqDwuutSq2Ts(5kdSS7uwuiLYYFXil)UNS4Sqi1(VZcsymSEKffoEwanlGufLfnALEZIghuNffz5OSSSmSqiD)olL2E7If7TcSG5JnlolqbkVzrJdQZIISCdwielf1BwO)PuSS7uwuiLYYV7jl2t8MSqFpqeLfpHzHSBL8ZvgyXtywiliHaiczz3HGSedAKLF3twiMqtzHSAowAm2V8ssgwMBkYIRdGGSypz2uZWYUtFKf4vFjjwiunM2jklEcZI92BVMHLDN(il2UFhSEwiunM2jkVHh(dKud9jqeKN(EpUg10nIadQZIIMlRQv6T2i1xJHPDiycw06OX0ornlRPjmOolkAOaL31ej8pnvgdQZIIgpJwtKW)0K(AmmbVEzW0ySFjLGE4pqAS1(VBqcJH1J1)IrT6RXWe86LbZYAM2YrsXVQdYf18h22Bxv7Tctt9kXbOjHgR(Ibn85QQ3bpVq1APOERvFnggR(Ibn85QQ3bpVq1APOEBG4Qfsq7jEtTbaqbdSLMGxVmyAm2VKopXeATLJmaGGPNVjps7FD440uaauWaBPjasiaIW6VJvQ113tnng7xsNNyc9mTLJS9aA(gOuttbaqbdSLgDSPyt0LKmng7xsNNyc9SzttyqDwu0Cz1ZOAlRVgdJnV7d0vWOIQvIML10e1cvQ6UtFKGBA0qYOTCKbaem98nqW83J2ttrQVgdt7qWeSO1rJPDIAwwZMMcaiy65BGG5VhT1sTqLQU70hj4MgnCgVb5YYCtrwiKA)3zb87yB7Oil22VWolhLLlzbkq5nlACqDwuutSq2Ts(5kdSaAwEalwniWIgTsVzrJdQZII8gE4pqsn0NarqEBT)78gKllekxP(9EXB4H)aj1qFceb57vw9WFGSQo6RP0JXigUs979Qak1cdfBH4nTV4l(Ica]] )


end