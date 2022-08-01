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


    spec:RegisterPack( "Balance", 20220801, [[Hekili:S3xAZTnssI(BrXgnnPoOibfTS7WwB4Z3m92xVwENz)KOGibnXZKeCbaTS2Wb)T)YJ6gvbasRUNENDJyM2IavvOQkZkVZSUz4nF4MRNfxMCZphnikAWZgmS)WlhpyC0nxx(WMKBUEt80pf)r4pwhVc(VVoEz86P0ZFyzw8mS)fzBZXhTOSCtX3F(53XT5SI0vt7)X0YfBVRFA25IUE21PREZ5RM1Fr5QL)RZtxM8srh6x(LYBU(UTPll)RRV5optSlgoC0nxhVTCrw(nxJde8vtNnlHBEsXu1mC3TVnFB6SD)WR2(XTfL7UD4P7UfhQD)WUF4nlIx)XKIVF3pC2UBFf0)z7U96SLX57U91jXR6tpNBe8MY48pMuojD(UBNgxKuapjd(ZhMUmzc)UcUh)wYQSpJ9y761jttkkIZFy3TFoopn(ULy)6M2pPpmp2KN85jfqFl2cDF3TNDf)S(QN1JhXx95mynGVd(YLPR)4UB)75XLl2DloBslFcozwaJW95z4lF30LPBks4o)tXFcEZBYw)5m8pO2D9M080sOxX7UDzAz5s4zRYYH)78LjFj9o83DXX(HST7UDr8S1pb27wKwIFTD3cG0TllJxNKTTyjS2UpfNlV(xE1h2D7jW3kbwMLPXlHz(Y0pUEvY6YtP5jSik(u6MEMZSvziC5jZt)4IYj5jRItxx8eODttwdBzz4KCZg8RGB33LvapGAl8VzRx(apuFipjggLpKTcgXmyI)6LXlS)VX8YTytYuAQvMNU(tjLC))LnjRtY1GgA714FVgGiZtZt6bZ34zQDR8KI0LPWYJNDjX5WVGHzA2Q7IlpdHJIpW7t)YUB)3sxplhXmE3Qnz3NKVI650fjt)eSOYGo(M3cOnfWjntuPD3odrI7VoBY0zfIoGiBaA961zLW5dymvy8V6x)refDnSBHa0STRH3I7opoNmxMwuwGh4ZO9m4V(zI(baUa8Mz386BUEkGCLaO73CDxytrGmUClapNSo5lWm5RFv)801tk4dDop9UmeRY8HXRFqmaaCOJ4WYW(3ZNfGhCK4zr8ZaIetltZwFZ1IFI0gYt3Wp7x5Jta9a1XPyARIb3IdLzW(41FqIJ)ZiMhanJten(1zispc6KOiWVGZy53NwKCtjq3QU9MU0uoF76ea6daDXg9KS5tIxUCs5c4SErFrV59IJqSRpdpADz)10zM54Kr8ka7g7NGCeI)nhgOD3(sGYNQrLXltWEhxUfqGNiHUQptpULgWoca5h2rG19f21tcTkakQ3LTEBr)s4Gt0ZMeTzQgQvi2srKU1jaY)nxpg3thv3EAR3n74FNStt7I7XKNWHCM9LiA48yGaQ6OJQl028DaVhZLxTirLPifVxqqlap(yaTKgm(aqFebFc3MtuVsUTA(2E4eopDAjoLutOP4(g)Jj45E(0)ewiaX5FpWJSnWOLuQhhjZp8VwUf(Nq7Wxr7WDKNmeyQ47xMLpZ(KG6LWqbBBZYtNxwbjUMpuenVelM0IjXzjouiUob5Y8QS3XKbgDctgiBBjssg(CcIamTHRfZsXdJoXHsWfpg7sebgCxYzYdsHe)z)ZF(vWSCrYAtYuelcINoovfFfSzPtrjlkq2Blt(CmYJIyorIoiKTqWooHi4opjNyRXBgC)bghlrwHKqsaEgUdmEV3birK(40zav(vzzR5jocxnErX2apxte3ZBy0aNxmFB(di5IeGQMr36NdBGRbHDMmppz9)1d8BUB785WrOjPRN2xi3crIW85Z2chdtrKhShYLxFj2MbiCnofCGF)nr7XT(yPKcfSuFKKzX4YoDnXZc6oVBhZslsqRI0YTIjaa(XwhRK8bOnxoLb0BlqWxkjYq59jiEccZkqG2tBMbwnmKMMLTCw29R7pLfafOcNmPGf)S)2nQ21AQ2m1xV794XIXsIZQ5e8pLlEqWIQ6tDgmCkjFKdux(UUbETAE8cKpbqmgeG7cIKSEXvKUE(2Ltw8qbThAtqZ7IciTpuW6g(NZLu0waGhfH)H9Fo91COioh(pgS1HjYG(dPgYYtolzz8da7M8IK8prAvqnzKKfnVvRrAfOOYdR6o6G2(VJKhETXWI4Ue6ycsGafp)9IZrmnjXIbXeJVJe49Pd(oqQ745LijeLUlc9mYI)GGwJI(Q8DV5vN)xxpfrBV0bTvoR3KjyTzIg3a6KRyAndfdJBad6ZRhftW5Iv1PJqBNjMJq04GahBjCZkLBmXY9gjTK0csNo45)62LfOiCBYZMYIYYqfcInNf4vaA2kv0z9mCp(z7n98PjPlP9ZUvwxNXB3NzsZWbI0Joam8zdO)eGp75W5HeuGXMPHKhNoBscsQOF8SzarOVG6(yGsuDMgp7H2r7t00Es6sbwYxHKLbSSnGOHGAEtCwLyF14LtLkER(k2c7g(BmAG78OU9QgMu4w)GA0wXKVN87a4TpahCTXFFt8YPBXpbjwscEyh5vr0uuefwNDpIKJCZb(f4piwJiAkSxGpM1YJ5hgJc7gVcukUKPejgNtKNou89E(EJC3vkfvFuM6jLztMLMOOJqGkhekKJl86XkKogvo5)CB6MnjG8UR28aGOSCciw5Aw7(ovy66WGtaaR0vBAqp9ssJayOg3wwuM6Tv7NXeXwTukY2ccewIwVAs(27EW3kXr8b1hXTVtgDXy0uG2mjVWuZvvF1CPCoDMhJw0iptkgOVzrVQ6IyjIOnLFVcxOMi2D0L)(j7bGW9G1E(58lF6jSmlwZGn5PRa4ksqjohuxiD6KneZc9C5mUBQnkf8g(AtZ3wInBY)5wyAUDfCi)ZPcCy18mC7CWKCoAuSig6pq8jl)oCDwMjmNM5GlEi0k4ZqG1rJhpkAOfzFXGRgzKKhOqbONl0fK)shBmkN3pz0tVm6cBKXib5phcJxvLiSfaiAG8uMEbR4WdQGdIPprj8U2Ko11KrgWgPfplhYBTtKtgEymETAwUNK8718ekQYSjQ(zt0VNZg1gEplMsZGjZ6zPmDExzBfQzrsplyRqMSvWprWhHLHsWSAw2wsnUm6rjcPxrvljuwr35UGALdmhaes(LoIEbSuqUtdhS3SNqlwbesVlDnIJNdSgNuKK8PKCBklvXzJgmOvIKY8tUyabaiQm2FgqTB0q3htib9mKw2BZqPsEgnuDBfvrXWAchTg3j3hNwgub7TUW141pOqcleamY67muchmc0swgbHzVB7MfzWWXcstWix7IZZQkSm9P(07enA3T)II1F0GIKPfOo6ZZeQYlX2iKkCMuKPeWVukweA(rOjBK6c4tvmtfIckOOGYwN2kNOU9MeYQcvAdQWaj(v7qfgfwd2gXLhDP(uuvGfcyDThldyDftXhC9AUneQZVrIb90)yaQDRrbayn)0W2nPtdcP51e6Tgb5PvWpSvjOb9J4rOxncG1AL3Rtfj(ZOWsRv9(b2swBkruz(2PGmjfGIbFg9jWDjiOS3JH9aSe22VEdTr3GRusH47GdJk0kz8SGA1kKN9xUPL6at3L4CEdpA66lcXrZPXWUoiM4CqCRK81OkYaX95jgJw4MyDk6ibOky7NCHYWMTQHDcB)Pitfdp0DZ2cX6r7F7Vxk(d04zOmVJ7Re1yuF(ig1R7wMLnB52Is5HgH4i9zRavFBB150teJ2XnRVq7vw4LAaLw3MqymAKLMqQ(ZdnflVC8FgwY6xT8(4hkeC9(R)FFRTjDzgHHmKmH566DjPJvcHXRrPRRn6Z(AQHMRcFekPPJRFteeI8R2Qxrfenffb8oTacctC3eRDs15WSU70GazDoaRO4YfEVKiqoF3FjbKgjGr5NLvk9iy)Y0PSdi4XLELLVrunqSAQ3bkyJQXLSJmNcsVv6ohCCbipOT25xyJJHZ5WXmkaIGVlq)45dCu013(MF6E7jd9w1Wo7pRQrdKtfxFX1avQlmfhiWrl8WOR3G8CQ216ah9szSiCuJgR4X1onT1jLDBIFPbhW2zzXEmdjdlbHFGjAJuvhpLq8VN4(5myafuG7ty5hUYVzPSMqUcy0cRwQMQEeB5PnmZoRPP0l4PUPTJ9BR(JQzZ08quq4R3pHJ(z1pxVQr6YIpvT0x6SxFMQo1ZHn1NEa(oRRLzsDtLAxqI9wp(UtFOsEUse6ACiUzHJm2afs2kk4TCBvpBdD9joaqNKOJ)Zjyqu9X0)RK2kxMlXEFw10rCIpSanIizirKJn7hTKLX3LHcpIgZseETROiYLImgLPkbECLMwctg3pObiMzAbcPGAKPYuUNJ(fnqKGBr4plwIoMg)cOsLy0SWXlOH52O4O0)uaO0d9h(hXdmIxn1tqA(UEN2Uxrv6vuRzlevHTGFlQ3k7G7HWEi7y87m1(O)mrTp6pFu79oL(tk1EVZ1hFQ9n)zAn1E1AZNiGE3vRxFJ)7flI9IlXJclcKePBmo4QeAHKzaZYqrqgOsUQqsbxtif)i0ROyw21dvwd(7s5H8JzKR8YeShWa1Gu0hvnIhwKttHH9NGJ(2HKSrCl7tzDrOwAe4Y4VXjOR7zc(fm6lfiRLuGPYj5rLG4wc9eOtnej3nBETbMgqXgswHnFIgOZ87lseUnCGKl96mj)uf0uYy9ustfRG)kNaiRfJMOhNsCVq22mmlbngIq(c8pgzYth4KhkeXJNnRM19W6w3gbaVMf8I4cQv4HOwiuAfw4Pf9lZwrkFVkdncisfEAMWCGqFkcfg31VsI2ZvsunRKqSfT1rTDReFHJDWvsO5VynErvCrtulHeDRr5(I3cZnyMJjxWdO)wltMszWuCrqz(6V72D3EnImRXVr06l4Eb4HOlBxIokBDcowQ08AbGsUeTBL5wDRSJHLbp8y9tR37ZxeUwaS5Z6ODqyRlZXP7G(dzP5QKQjxSz6oBNDxGq4cxAcCkaqNtnsQPPuo3rUUgdGc4FMkc1oe3aMa0Rs(s8Qn4oTGKat5ih65STR2qg1sAusz88IrvpcfNpVNVGWT5DGXFl7aZ5DGdkYufoyE4ahPNdgtLwbmIqmI4InE3)ruzrEryg7HVQ4xn0uQybGdnJvUcdhHVNJLcvgNyKwL683KO3kAvFvylkxLOvib(rtGLIBkfvjasM(7Fs7PNyI8XtLyudhWSvrwZEsOWMbFAagg7L3NLVEcWfoEfgTlMr4IHIuEBOPCuyoHSk(leEbf58kj0ASR88uNPvjFjz62YeDQyrJhpzQpz6cL6DEYNUWtTTBmXwP3mbdJGj45vGlX82e4TerK3I9DAC5u6rm)joGe4eQjJFaA4Arp4jPmfG2F5FoYhwxNATe)LwzdbCQImhm6joGyvrPBmdDIhm4o7VAMUDbeBQCbNzw5t(CAbIq4H2r6hxdZQjgPlyZGcds5Ouxa8gNZQKdhuik3mtVqyXpYOwI03YNizUj2tDkq5r5ilxoTxBCU6NRvZ6qgPwq6MBy1aDBy0LnQCvT2Wyq9gBqePS9m0ISRRdDqlYuzNh4RWJCBC)uZ6MAnpdRCQrmugAfnwt4PsiZ8sNqdUQ)1Cszt1hsMFEwKuhkCK)Gkg4Qb4S)zxWp1j(wvA3L5Ivwp7gHTl2V5A9CxUcfmZKBspx8(wLbDURJw45rjIL3MoHtNCzi7ba)NzSK83f6yStx61gJGpCqduHme1WJjE85TDDsMXrHlWZcGuKSZO1Pq5sjX1ijUCd(oDAN5QDOY5KSlPHPJzbdHmAHhp)lZOvKW9g4lMSkDkRBeW2N282jciWLPFg5mm8cokc5zhnV5zgxNkuj3BSSwqyhffXQcFIk9EXgHPubpUKMc0WYGboT(kyLciT6we)zEALHTzoWNDbQNqo9qhMpojSp3AwPUMil9cIqxNaYeyHJCbR5CZsb0t0WCVPUZfevhlcVerc13QIuCuOdthj9jmzpFQE3QOmPDEvxYfUv64cTlEZekVI9GRwdMjcMxqPvoM6XlZUJkPkz6W3XNcWkP)PiXgWSU5Aw)UZusm7A9BcCuKwnkP)7uyQGf0LvKGNRY40)qKZO2jyQr8Zlc)E8Sfq3zDPDGp7XVlIImsLuaVtlMZeKNxIksUkDcKB8mUs9SgnH(gSSurIJlVmJtuEvexVMBKRSEI7vdCh9)u4(1u4fQiPI)jo3GqJdtiOc)16zh3ZEVUgAcD(widfwiMlP3hCV5LKfT8ZGE5dtJZJbKSLju8Jp5JltxHFAlE0SibFhmoS)0clKtude(gBqqq0FNJG)BjjByUGxRwciBd6pWHRaRbwmBdrIW8J8IqWiIQNufwhp1jH8YejBkLT80oeaz)ExcLTNKb(KAMYaCMvzKIVNplczy31Mq)Beh93RdhpcWFf6uvTDg1ia(VlQRj0gdUdtL8eoTeeoVNPVATNChclfPElhmHK1evGEgetiaZYOKqNgrv8n(w0AVxZ93(nklLX0wzjGyRpih0mTcY0cYtI8QH8TLSrdhzhzaVQZgmnHmjKXwjbGh70eISPfzPgWWISKlQ1y96pH2PLTedY6Ojbs1emWd9FsriHoVZwv6oLf9f0o09br(glD8KFPt9AIZMn2KtWvcAK4ypAF18jrDZGjOA24WidfQuHJmeypzEUfytNtOj3I)XXTqNA1i7t8HMg9wo00Koq(gFSeDXhER0x21m3SnWV41tUpBD5Ez7s7A62wUGHW1gap4JcSS5ZpDNr8lzmaAKwluBbuD7M(mItAHaJohfgNkrsKoKYAIKXyEIjfRkjoOh1dcrCq1a)BwuBoYmoKDm)4(RQ)vkIoTwvFt(C1iG3fTzfztdYNju)3DGE3xLOuqQqkVVSmZLk02nmZwVyiijQlorwFaPLnjnujMGixyjzsLSjuUEINfdFIpdaN7Jr)30gthqnDNrgdsfdJpIYsrAFkN0i1vbDvspQc2tG8FTjROGlcOK0wgMbzKETGeD))r1uvwgaS6OjFxYx2Wg7WsndJiH)iLYt2lYjZIxHv)s0NvlrjwyelmI693qbcLsE8WT0Ij5n(svmtVM1kJ18Bs7C8tQAtwQrkGZLqnqhTtjukk7oX)JLDL2PnotvZ0lXvVoR89NA3r0eygL)Ou22qg9eHpeYCM9xXirtT)yarR3YYJvX(n(lCPsz7XVTT5JSeYYrE5s)QBW2chT2YjH07J2Gzx2C8oF24wyL2E22NPhXBJzkFIIPw59aogcPRyz0kYaOjaXoywZB3lVuvgTARGFduCpQQMckUMHD1IBx6ylbz9jqt48WrmHcusuciFjbEEHes(mlPdQcNmZr7JBn4PNK6Hp3JQecpKrHv8287g7aZ0owIz1ODeRb39fQ4lO9l3EwRlpriVuPJwf1Gvx4QDuAqAoyEVXxsIQpT3sCEnXwytKfwGfQWhpT3N9ZgkCkzipnEZgPG(7FHL06uIRHwdkOAZ(VkCveQUSctU9dWeqX5Pjg4DUEHs1HMRhrMD1F05gqO9tKEIPtqZBe5X8gne9c9SLMlCwhgGYJfc1bqzZW1aJBW2x(35iT1UurhPg)t5V)hyjwkyPPzIiqwRKQP6JJMtelx7oUouKdCIIHE8tTbYvMU6GS1MsJ3Z9sB474JT2KnFUFyF4wUHNFlszcSL71EsnNdFjVD1ZOrbYnaVVZgHUVH5A1(yoww(996XtzIvlOSkfNZWdN4zsdVCYhRUXxY10cqGEccBeX5RP9HB8fg6wUhSUaUii67EbJoMr3njmkyII08M5CWO5GI4z6vQ54eOm)WIz(AkeQnzYzRQPaSuqUCJSNQSSDYPBL6WrLWUxRDSrsn3EvBOMlIlxH2eJm0MqhDIcSP7syFdBuSqjLbftuYxXy8jjzFxNMcEQII(nyGu6k2GbAzqm4L7Ji4aBjOmJ1JB8LGa6PQF5UTf(5O9en02izH7ajbdtTDCdbCKjx8WAg7Mf8AMVjtZZ4sAEfz(LMs2EwxhrQNl1iO1ff5EHP(zKyqbFFVAujWkf28w0PEHcHZxg2mW3BiCknsvtvBnT(cTOSSfKm4vCaaxR8mJBuILHgjsVLuH(fi)DSLoGENolH9NUoYrcX)OsTgMA5Re4Ka9oYmx4bVW33be8sezLBaQij08YqYyx9YD8VsfL7XINqZ(XGw2XMKK)fCoixiswN6xtU1CPqXtC2HKS11SDdYJcIHKPHPfF44YmqMU1Ota6SpwfWZ5JkbbxRL0wf1lWbEvXA2ggCUpdSyCY3RlOUOri2B3UAJWC7v8FOl7vcpSuD9iWAOIGIW65gau8pOT5X2sDxJP)9W4QoVb4Z464gt44xY8aQvOplxQcfkfST7BXSU9oMWt8C6pQnfDQM(TV4OfvXr9bnBYukpYtHM(CMyvEsK26SDvSD820iAMPD6QbCQ4n3w3WxrgKktVEhQZGqgywu0rY1IRzd8wlZKiTSpWRYntVH(41Dg64LzAspvd1s6x)n5opc64pKMA09yAar2Hx5hsx2hvdVLOAVMoimKWb6TD8eloXmDbo6fgfRG8e(ztux6qJv6cz2ALR9QgAHRtUNmZPpGc6eLcFEtWs3N3Vf3tW2k0dYq1NW2f4F87bTwm5X1l0BN9Xuf1kDSgQSiE5CgSG7IHvTFF3f5vCDsUkvGPDC6UsvQ8)FwWhyawQHpnL0(7U9VlVXQEZBnd62880SCTG9ykaT)ritnzGc77U5lZWJLDrhoJR5hMiuy9yH2rNRQRLwTwjShry2YngmEMqVSZ5GARsCHaZIjs3A0MqcrfmW25jLG0JXTGfsdx7a1tgkO7KaSeEaxkFNALYKPVWI)ILhtz)Jt78HTTqDifD2hx14QCq9H7AnMvzKgLFpo6xv5yVsGDqgB(g3mj1cE)lwShnmsfw9Lnyd)EAxqWyvM(TZ5axKyXlUwiLUbxWNz0(NeJ(V6MIKweHcESJLcQgcsC2oX1p457tlJej2SuUmpEFSHuKKY8QEYtSQmYUokLMNojieE00RL(dE20zVxxOphvBIlkvWjuMlRZBwtnMu3GEgscx63wkxypE83bwDrTWglkwr1DwcAPi2yukjv5SLN(h2fVosIxHAzvvq3R5Yr(3h7eEi9VCAHsusIAQVNdULIR6(mHCODvpPfM)kJA6tsvPEdyzwrZyrKH0u8Utf7gDTs7bmdTi0AxJn4xTfDygvnCHonWCAnhlAk6HzIJySQoUHUJLHvsftoxf(vUXZTw5ynRFpOat5I8TwLqN5Yhsz8V6x1EpcFulsvrr(o1SkGgCNjo54DSSDenjImom49irUc5sLwMuFVrFbuntFLSr)MV9R5dc0L34SzQWeKBaAwaThOqbswKI6AQsflfImEPCNUzzks2MRMFLtPuaugCAYHXCN1kSemptO(BmIRIe3oAeUaUBunw507peCTO0he9Bj0gDmu8oDLkIoruWh6WVa2gAGX43TiCKnkcwsgCeXNlMNCVkuEfhvO8UueGJUHxzjxIdUx9kukBkLm5yJuKoACJfnHDiwHd(Dl8pdtSTTboPY(kEg5fjXlT97tOgzP8LI)1JEaz2qBftvFhgT4(xN9x741rq)VLTGdPSf02AwGHo1)jSCeSpgE8O9aertaVdzyfM65Ig8)Mf)7Dw8xy4Jh3aXUQp4y6cebq1L2LzCUim7OUdIeo8IbNpAq3QvJPEcB(kUpMhoa5xKm1m(Qf2hMJYAkbhTYcbMXaY0Y8Uqahp7jOvOFO4cHI7uUtMp)CIhCpmYz33xX22lDZ2EmqHV1vJf1iwUGBfFD03YYGu1IiL)6nLPoE92NJE1RtZVhLNjtR9fm9a7zFc1rHOGm2ysbTjUU74pYk)DGkTj5Paf2BFHAL5i9SDhI)C8KjpwNXWPVq)PsHVw0HOK0tXZtxNwilZgjMo5rR8e7LhhFlJh0c704wtNUJ1zS2qPMdgN9IsTz87uNn6VSkv6avnxbY7HDbGuHVGhxvxj6neg3su3edh3)TarIdyafMuHKy7R5TsMW6Rq94)aTBAQgDYgIbb7pk7OmqQd5bfI61zInZa7Pw)iibF7JvJLF7AtQatyMU8M4LCsv6eQouHMsvspwTTREXunxnm3mQAEm1wHYUNIWTxlvLvDYldLxHYCtCH7kWXB05mab4jN1c9PqQUhwn9HFaOtj7KLOuyx3idRWpjRf7VjGl6OEEbP5QDQIXfJhERHOorOGifkNajvqLdASrKg54oz70fZ9gENZGVYdPkM6bcPHbDQd81maYvpT6KyXfwclomC1MKiT0viWjd(i3cwOcdaHqGIbrrEI3UYwtLY2SsL9iidbsX8a(O0cDQ8XljCR11F1vnQsd2f5Tu90LsBztFDGsm(RQYgLY7hgHD7jesdaVrtLOIs7I9ZzVQ)UfhHTARssgpqfjsqltBWHSBFT8IR1WBDaUSU6aY)mUGBHPklRRcz8Ft2tE6HTN0qeXxEqLqIqxGQTiKaCB400CCkbcXTeVz)Gt0Gm)KEug9qj0t17OnZ3wvkcd7E5QUrhpg5bLi)strmTVlXmj2UotT4MKeNV8HjaqWhPRC2sLUvrAhPZbcCOE3enyRYlhZD02dHWmNj3YKKxa07swxy6dyA3F3T)fXmKV2lBrfxW7QsGMQfeY8ckvrhV0tw(FWFHHpV6X6spPZU(dunoSM)yK1LHv0PB9gC0eD7FgsBhzme(awMiqur8K2hreuzf51os2kXqfbXK9fL8bYRNdihx9gR7CahezEBOANfOcTdptMN9vT)H1z94IntqvHD9XglmcjBlzvmZQBo2EPtQmtiiyQ92e44kvtFwJX6hftna1G3HtTDQa1wTHYhE3FrurVIKVnDgEKJUv37447a3ucoirYJEmto2UY)NAIi3ELgnPQM1UkDBCF6eYglMzdF7eLwobnVDnDSvthNuC281pxU6QEfC6Zetgka4)M4SNnl(aPsCaPf8t9rMCVb4V1PYtnjjhKGw3dj4MmTziAaYV1BGxMRXtVuoJCRFY1L)v9SrnpQwCWGwO0YGFnA(NX7oCVB44ykoGr704x34oKfhL68FwDZ(GDpicYbHDemHWReagwj6RL3noxvtxSVmjeoNaPiFpYpxZqc1OLjO)A5HGGgqv(jfU6U)UB)j6Qfuyle0adRlffMRkL8g6BSTa0EE3TFiciTq0tzNDG66(M3widPM7WBHPKD3kGGfuyHl5(kfmSuxoNelrC1YvV27sWpwb8Y0PPWCcLzuzCgYVj1KT5HKKO(SRhfs8YdwCNoHYUER7iRdl561baJ6Tm4Djz5Bu2grWmOCjfxAJwBvPgPDT9nbXlkLh59VRrPl)HVTjyRe8sKlO5t7e4DMNUFonTW1Y20Y(4vdwkO)Rk57zoqIOG(ellywHjJjRpqdayXzDUx5oupP4FzTzsFZinP2zLFLejVzPQQZlcg82RlcnQYDXkqVbGagHQt4pGdE9FtmUeY4mrC7Cx6syPI2HvuUqJxlmXjkjkoGZSsKeNG7ryZwQJf0TufhxpscDqt4uwDVZvCxgvppsxxP8kr(X2xQG1MXZulAvkKFrBtHCfuZbiyWPouIJ3yC9SZV)c)Szb6OnNc)hz(LFq(4m6p0m3UWk1T35jTTlZ5Jk1QB6Pge)D0eU1z0TkgB)JRuWBBhFdFDW(1nMcNEuPNB8LNVMwZ7XRKWxrppAZkSLCiCXGP)o9wzor23W4Pob1B1SLMejqKaK6mreJp4c30tmTGRzZ8uLSbe(Dnsfh8GFLjTIDMjU7yl6vHnY84wzEzLEdEm8r4iR(nOkfl5vitYsA(XQEGRWW5BNAHnvIFKtmVJqiPoNUnN5EOoMrd64tmhjd260CHU2hPD393Mpb89(EjYuN2Y)4e3T6tOi5KQj2IkKr986BJovVW9JCUYF)k)c3PDrlqLjJmgfRnffnfabpri2eyl0wJzVK6nzA5lS)tX9yQZA5qyXwuPKMkgci7VkMCWbL3vuaytaab7lR7dICMJadeRvDVmsOHRrRMZ6j5AcDG2X8KPK2ocfXSm7OHi9IPcxqCQnjJBU44f4oCSrbFRJ0MSZT1ow7J8rKohJvrPOFdagWuDuJBvnzunavqUmTcKpzR600MEhLr3AieSVsfONTn6YDSnuBe9VDN3fDOL1KfJ0M37LvafGeOneUqzdbzQ5G7HNkpSQYxNyz1BrgWO6eLrEerDNYGI4G2uhoT1vfjgciNDLU5Zkvtsfhy7jccJzBInsybb)HNDI3i9a7lk3gddOtKTOu45HMvBIfQIqvpfrYXqlw1dnSwojsf7hwkiCvrKBbHDTLPEzi)fsauD)qg2UbUzQDlt(BcZZjZV17aTOGeWGBpsoEo9tHhXm(iew2kt7Dj1J0Jy3Ilkdsd0)YpD(7)jAxiSE8pI7cEf(QQyvvRmcniTMtGTR3STQZavY98)5ynALR(1KL3(TkGP89EREoTNTIFUvhUQQESPPPmAMLWgDs93UAyZJGY)ERGovMaNWxPYhVRHQNBVWZvwex9iijGeokoQlCpQ12d(EP3a2uiIqJBsX1g27DQMG6d6Frl3)fdTVW8x1)2jVLi6FRa7UYha5yzs0xNLXSm4sTw9XCf9uhPZ(d5(47B0IuDehHQpMF65SYCeCnSPM(gktvTiaSDJKFJ6XKKPQrLvI5k73ouNkKoXTmlvSRMWHvuPNmlfFvk0dAY31PRYHPnIAOKaA)LQqBTHOo4MYL(TNIfvLqHEB7oNsEWAW(i6)EB1)wHX8bzC0WcBX(5JQOhzZnnOdEzNqBsPY77eCfdNhN(juu0Q3Dg0vyMucEHbVCeyvOjpHM4AVUMntt1ad5ysdSZBIi9j0EP3U3LOz16Q6XijBUAiDtzcfEtY5w8sorFpml5dsbswXeHp69fd2aDMFnj)6ex)28oqg4vCfazbALIvBX0wNTKgkZ8hb0jCsVHsmB6s)QpsEGmGchJ9OXBxhVPybgnrZv6IPm)wrkO3bt4gDVJUeRrgFz6u0nJjIEUeLGehbylyEomZ5c2t4OD7WoV36tzTN)5l0MROXRUlEMyGiPlwivKzYKtbdb1bpwarKpHn7GT8vO3EkeCuyE3io0v8LLfUmRIxFOthhr83VPJMq7r2IKx1K7ny2QgipkI3OMQ)VscZHQtXJgjD9vlK68ydHGcu)I9Y8NQ5XpgU8QvK2DYglF(RQqgVh2f2bYO9zY7NAsTD2gOujyu7lRNHMRNLIGmbQB2(PRPkM5RlY8W0AqN6lIzQunjjHx2aBn7QeHm0RSKEHO2eUaR6pk3d4u2)Wu7Tf2rPkBwJY64FjE58tcuBhfn03LqLkNQjBv)Z)KOPVh)JsPb5KLEtPJanJZPQjHTsSqcoe2I3)zcoy9zCsB4wY6qQ61JGU4Dj1XubqClOj9nQ2J5CUTCIj2nw7IYW0ZB)uRpZ5I3wkYgc)28kS5A)FsOtMmmOXRrdA9iGv(hwD78pXiJ2gN01u7vPCRkKOtnR4I(kKOHnyTxz6QBd0uqq3YRGHiR6kSGc87XSK1OCtNQi4MWUWr1)Vpot)fABFvRg1x67OGtSy3EpTDPdcBmO6wzEgYc0AGSsUSk9VxfX3DTPTlsJcs7XKJJB8WEdN)4zUBh7eW(MUEAm1F(qPl(EHkDENQfyXm0riKnoasIv1oqbQi2iPBk5ewZnAOzxrcY5WxL264Horfa1U17p0RBQGpGDVuLqzHq1kef5mJuns(dPt74OKELiwhPlE0llWqW2W5KWKJVFmypIcQG(D0xexEUjNhn6rrr6wOsTmDf(8cxxd5HYeVnACdOAuXERweenan2(01E72Gihv7hX5sOsyx(3yLpe6bOXa6ChmwBJIgCz0yI4kULwCZ1)9x9B)8F9N))897UfR4eiyfyoMlnVXtY2GmiFYoJ7w6cku4J3wMHwtzg5mS1FeJ((F4hPG5l67ziBso96NOjK9F8eEtX8rsAyWR6o8l9uJYOVXrz3p0WsBwY84Tll3V12tTNvxNU6nqVEyDjAV6VJNx)4w40YSu2LAaMaOoFCj5PQZ75SiF6bViJmgLlp4rXCU8SV9Lwu4H7aNup)GhLr1mkLa1IpLu2FOEuKpQKFM1sju3J809OQDF4GdEryUvmC4JZW84C8C4fpodZHFcWAyo8Jar1nmTarzCB6FnykwlJd)qtuDdtlwg1onAXYyC7i6IzTs2Q7I3tYUUmdAXcY88VlUAlwpJEmiLHgh6D)Yp2EEsXzj73gZJdnHhhsch8O4UnfaMZgaxdXe)(XxaINfM3Qdxrt2IRYMTDjwALm4k(DUm8FCOtvpR69EsDW43psSQhwdZYVvXqgo6BF8SMFJFCwM)5IV3JdSl6WPgzoBIEKbzrJ)2hVOAgV9yzAnToCyN1W84C6D0J85UrhmUqaUbrF7ZVrTJjSu)5NSxCIFeMFTuiHI9u4PdMVC3lFuyNoSgjXoSr5GjE6h36BqbnlQOpolUVbwd1Qls7hMhjvsEKyn8ytkVUX7qNwhoiByn0mpKv3OhfAW1s69qhMhb26wRUd)4MfJQdh2znmh(XnRH5BvsSD)WFLywGD(PshtHPzDrjYrGUz9MIvCWikndNNIHl4)Y)Irbi(TyfRA3pGp7vB)ivgcgEkgyorr4WJp)nmhMVN)1zyUypJaPS1WFDs8Q(Q3XngElN75tq)gmnUqMa4w1drDV(Te8(YzgwRqwNmnPOigJctPhRH(2nTFs)t5SK28(E9SRezoT6z90J6R(CgS2W3pvwZ0K3Ysu24(eYZfWOCFEMrbvtpaC9LbbqzQybvxzBW95Ysm8GyxzmFzYx4WfQRkTWxeZHe4IurC(uKI3OoXRtY2wSuvQuE9VGfw)tGVL(ga4vYIWXP0Cf59)P0n9CND8L9ZtSITkabPykGSKNMHt0nBuPfkfh2uBlyNdPhUpKNGmm)ajGbgAlVEz8c7)BmVSrKkAkknJIAm(fYbcAWfTDB8Vs)D1ddV2zQDU8KI0LPjYIObMqzP4WWgp6me2A8rEF6x8h4o7KPi2CkoFElgbpygg6GM5wM24AYBFj6(RwVoRKLTsDk5v)6pIOXR3rX258STYljHfLLBk((ZpxeHQNbG3P9)iat3Ex)0SZfdWzi1VZxnR)IYvl)xXtHVugsRLFPe)W8j3I(klM9sz4li8Wkm3eIhAN2FfjInTbsCjmRdHDSs2j7ummjGtfaey4o9vCeIjKtr28AXOj6XPuy2KkVsd5WJveR74FmIFjFLkGHtB15)jV8C5e9u0rvVmB9eyKNiMkNsoO(LdoGEMT5LXZMjgGHNMo)LA7dUiUGAl6i3o6hR84SS0)05i9ltl6dcttfaSvWePmh997u6V2YZTV1jzK5KmY)KmQUjzuRMKmcIj8MboC5quOYq6uovjNLuMmLqYJlmWuyehz)7J6KCnIHPr6qCTl4Ejsbrkw5wNqANiPmaCbMTKCJ734E3f4ExlsZLV(1WL0oJ3Hrf7YKsKzWK8T39aTRXjyptDxZAHtZK5C0BtUfFQ4ALK2UVTl9QKVeVAdUViovXh(q13u5nVBLOf14SGIgWETz3rKXlI9JrdoU7WZWA9XX(Y892nIZnhXXnoIQTiQwhXUepEfqeSKzuqrvVIlPzPjaRzsFpNFCkxYx9sUrsvr0QwHZyuTfu7mNmCWXAXLQCFk5FyXix6tyoONLVYFli32Fkw6Aa(fVC4aeJSRmSu0xxmawMtGVB9eKyP(bYanQhX1z3T)klJcr3viJcxB6SqjXJPx)bjH(FMtA(3JbOd1y(65bXk1XvIoyguRn2l)Qf2J5QPJOk2qJCNJOFfX)YZ3xgzmQ92X0KP7rAGO3QZ4x)6rvdsj4H(Vh)F5q4v1Nqj9(6x7wn6WSwW0otB2c615iVr5L)LpbyDw)nS67uDT3j0kp4KHf15DCadbOoIlEAzCfLq6sGysep)phNUe3O0NmFjVnDhi7V6zWsczUygalc670k(uGxv60sblB4d9IUrhBfkD4jako6oXnFLuVXKA0RKbsiEjkQiVmJRrdX6AOSoNT4af6eFNkQqGjTysCwIG2I)93Rg2P7rbYuJV(16YwgaHlWqgzSaLxYSmRf9zAsqusJIOt2zClnOdwPCG23NPIs3CvElPcLlsrGesVO5j5Kq08Uf3F8UQoreptenP62I4Py4Djy(E1qAjPlKE1DtyiUNZ(iwFWXjqmRchlgQoFRUNVpmIvIQayWLtfb2gvN(sjz1lVNkfN4YOOM1X6jWhuSiinmXKsDOQSd)1VA8qrLk2(zYtYvEkctTEOv2cXVXnId)6x9e4PV08zsje)6x1zsmHUs70uSS9AvSvURMSwGXSebnNivwrmUNo47WBmoUwNP4SlV8HI)GaJXms5ml5Ng706y8uqB3lL7gUfOGw0arXED8SND1WXDoYnMn)6xDFsh7i2TtGOaTt36ch8x8YHrNDHH4hoX6TxG6lgc8Mg(Dgrq6l6oS)ZpRUcv9XGKANXkWolzz8dt07WWRg1dyaPrkieBwad9DeCScojokktgv3cmds6WszrsEd3l1harWaEVjd)lcwhaIyYE3)MuOT4HppeSbONIM2OJLvqEr0y)7fEVE4fvGgfYEnf6kr8VYcSXKMIjVYyitSyCorUt3aji78xwqkcth(UDTwtNnC8zbIK7EF3WNnO3vn2jpNWSgHohLhNoBscE6OpOiwr)KVG2tSt3J8ExO10XxQr9WJDEN2xLIXC8MmeEmBI18(RFTgP57eA8gnW8BfE1wZh(SHd8kJPK8QG5eD(tGbqwAsa6LLgBznNgXRMLT9o5ve9wvEQHK)jdxj6UOkqH))zSuzRREIdlJNHrKmkOec0OULvkdOW5qyZ1bmNU(QXa4VB3WAs3PRx6PnvS4FXWNE5jDhhM6ik1CTddJcfun(o(5ROgs32pz0fJF2GHg0HVa1bWFMjW446SyWGdI6B1tljO3Y)IhUoQpMDh0tPtQzdZe9SLdOpbiozyKX3iy6KC2Wiyb2cRW0P1LVeC7wpIflIHEbhdZYVJkVazKbD1dN4bqlGbM20hnE8OifeK0GtoAuXjaTS5eOPPl7OHRoVzYONEz0fA0Gi4yVfHGRCjYO24Ig0Jwck(l2gXcv6m0Rgb7LAZps7gtKFhqTHQwTSveS6f(dgP)Erb)ErpEFpyRPNJm)BDjAs5YJHDkrQHK14zsGyj8LOBs6Vq5O92nlYGHtiCsqcGvV3oeKbpQ(mI3fYhnyqaHkoP7fdoJtpUQ5o)Xr9esX45Lxn6zN1n4zAORA53FNGi4UB)f1fZr0aUc(jnOOHGCelfCRsxOXPl7ksqfUQlRZsDV6cySHIWY0YKv8gAfYXOWDby(cNG4ZS))zVR0DBKJK0plcdubwKs0flsQdajbmR72W7HNDwBJ9VSPKO6M7qjQLfL12ad6N9nJiYJiZmYSsP(WEaM)y3DZ6iRmJ74lIOhDVW15yDIpYYTf2mkZw40yZFfpfNEQBR(xiLdi52pdXe(DN87X(COok0g6u7ZNe7ytvcvGrblQOdOtyNp(gNM0sUloPwqnxgZ9tzc3fN0NJanG1eC9ryAq2URBbGMGhwPCkAZM6xQ3c5YHqv)w5Oezer8vDqbAnz7OzvBAElYl)MmKw3SuT1O0RE3oitgpawrRK9EhYkp4aCBk51Syg6bEbxKOp4WMYGx63xj7AKWY)mFQ2)V(F9MGirq9d1uX)iDeH(FJnJ(lU7Sxoz(yLYKPJNpeVo(C7OwPKz88JL)TEP8hPU3HPThQuZHUeokC2OL6SVQasJV18IP5fstqbmdo2xofGyueiDhAdxb10x)PWgXsAgsz7DtiYxzWMKW9QmkqRk0xM6xJgcy98s0oaM7xxXhZB6r0r1G4z3M(NC5SrmkyIXphc28u6fzNyC23uqKs5XwirsM49iQRU88gMbVHFZX8Ofk4VGlQqFQibstBQoWpCMI8xZA0WfaRSzcvpqkyGaHPSp)6T7Wwx2Zl96fEutSrgQaU0kawbDl3mi5Iah)Be6uarZTyB7zdo4gHi2FlhIjb4zi1sqGDR7i4z2zqFXepECF3wo4YjCexe6N0R1tV(I2C2OkJAbYe2KlyyFbEolSyhjH4wzvscna20bSB0K5xj4KQ9nZviMmIcIHd)Qts(spoZB8IjZRfdm1bPIKVZtx5T96eXtkZI4QsSQoPeKCyvkkge2f5bbn)grz5PEJzxVQ9OOG9c0QeXQytc6Q56ZuXoc0vZRn(f3tF5jHbbnzc3qbm(Tzz8B54blKXptuvcyLJ995ldVD7Vl82sis7RlVTWB8BpVTWI4leVD(NCp82vdI0RhTRiBm3FCeauOeGxJaaYE8oJnkKLmw7eqbcwdlKKwGpH3UMUV3VfWpW(TMK7Tx7g5wWSf8Eji2ZFs787ClKz(aas4OEjkB99C)D71WdtmJL4IdBZG3SC)n4)eS9AIgfRvud2HT2KgxQ)w5HSJXQfZL(EaJn8RfWtAb8Gu2gFN2pyNeaPUdMwMxUwm2f6w(9OMXtmb6l3LhcgiEh3cEgvdsJtlj0CXGQv6xUY81KB88oik8VVDhyKQTgduSGEqWd25d6at8n(4Gp8(huor6QYbt8RdbKNeQVaxGo94EBwZdBhfGKTQsKSZViHbkHZTyhKrOeAUpyMN1WhQzHHnnW5z9EKGukcrjPKVjNT6I(o91GbY9k7UYKU6W0lmP9ur5Cjvm3iRwDsBnKY2bCNvV4YO9KLDpMZL5CI1TVzz56yMGKwzZLchiatMAoQ5yGJZeJX92bYfDltgp)4gptLe2DLExIpUrZd8aR270vsyGh8Js9UZjc7kUiR6Ed9G)kkr0jOJmXFCbbZvkHjxEMj8eIxkscBV0AzRVN0KGBILWQFHcTdjU7rfJ9Q7xFdPZvjWfFBMmMSz9VbYtNmJsZcjeafpqca0DgodUgxAk2g)y4k0K6GlAYmSGv6iD20JL(owB6FZGMDSMi(WYFJwwB)KzaD76UC5fzRJK1rEf0gPLFaBsYLJ15IPvrI0T74ZQ6viEDLeWoMDShB(i9t0tjP6arre6Rnw6Oe2xOM1hGjZnBVgl6RTSOTNyxjDKullywGG6scnMTb3cR9chzR2jTMbpnA44auUk2Gh2h(rH5qwrsDjuJehRTgj07c8mahgRu6rd8euE6Uw17d7c4DQehyn(X8fNhFXUTzM4pm2VHYeTuQ05))(Qvps6IDdUoGRc)dWYcs1IEEURr20)XhVz5ULg(01X4vYbMqSXyt2uBkuiN90GraxVcrAhw9qRc6H2Wv16eles5PxUWUVO2f7wZGyiXp7XB8G2pYFKaG2wTLsBIvdKVRlM6PdrsxrT7enjhF1ltyIS60ttuTaxD5mFfpBOd2f3TzfMD8fVFZ67vVa1cvT(p8WzZVswdBROKP5etQ4evKsRUoUVedQ344eNDkAyx(mYMJ4cXs6X6i(6EWo(eTPJ5nqPS9l097)l2QwAncXc98CFTzsfdp0ToR(rgImuEzj8Yq185ts(Yo3uN0(MJoLD44X1H7wozba)8FZkJazLjFoV2wjGAXcU7boxNBQI0e6LZSN2J)MPiMNAIysc37sFCWJ1VGBWXS)AgW010r1lIUGECZnGOs0fu)6c7jcb(eOKfoXSHc4iEExypa3XQ3HFhnnqWwfmmovW5mkCM76hnOBC2sfX9mhLIDX3xxZN9IN3(W(Win4LaUZWYuuQAMg2mUTg(X0h34hcGC(6JLp9goLJc)Hz1GOEgsQxLEo98yWLIiAnhopsndeySKVxU1BUJ1NJ5NtYaBlGQnBdzGF6rQUWejDaU7zJmfFyNU7p)0d7Hr52SS6RPOBWTvuIDZ(JY0kvh4S0miWjL7K0vtl2jjqABcL8Z6BT6oK0dMxhkYWIl49G9r4WWZSLdIv1curJB7OIr(tbZNg0ckwawM6ojaPT)pyF9G0RcflN53w9)946DrU24pMML8W5atw1pqBaBpt25)(Fp94IgxlkRx6DGsFbPJ6Nn(P9t6u8tjk2KKzQ63uM6sZRpe(EW)Xl8tmNlfcoNPSb3U)hoY)gH(BoRMNIh(mWMnYxT1)TWqsO)ltjy9nKblr(Fk3HlmgFh3oYdpgnqGq6aKB8X(yt1gmyYSrsMYQECdBhkeSONESU24Qz9HdMmsl5B)ZkIayL058A1tSUJJHkk9JLfpFs1aNNpzy4pW3Kjo0Z8IcO)LveAwsbfgXkfrUapvBFxmyWzhlfUTNEeaV6WSBDaQsIcSDQ6YHxuZUA4w8nxDqVUEul6Ad8bnPPNfTxg3mzQMSnR3mbf(buxjM4pPjyRvw7pS9VWCUWOMZmITd4AuF1K4Fs9aWSuaHxEJC41KdROIzeD8iKiO2pNzeYvJImgO0i9C7gLRu3Scp49JfAVvXc)YJtIPOPmJoRwYbN2ahCsM4M684CtmzUVw2zDW3Ml6aR03UYMYtLJzQ0vxy52WmMZg0QmzgjGxaiz5VCBG6NlF8v4I6I2tQejy9R7ylUB18Bg9vSm9yMvQ6VjTh4HP7XgM9L2(Gf3sXWvGmibYan3c(KtqUFz7j1YyTyCQQh2rznEE4xQ6zVC3d4Jo7xOxTH4MSF(I28nBxVTttdpmIjMc8LpDwcwp8HSyUAqyKiXubBRdN06ez4nshDKKPsQ0z(2aIycvNOFTzxtzMD565mAQYRxrjbGv(YKjW0gcMuai9Tjuo4bf1ETRYRCltKSwLpdg1lvYfmDJrxPlHvCvBVLm)vDPRVDffgB)rHOepxuLEJx5FwB9TIgc9ojuZix4o2vMcSHYPNSKSLA8VTNzy1fTZtK5tqTsANgCWi2PFy1n72c9OJaBZUQTUNA7)8JhKP0(tIT90OuQwWOnlaUeQ6jLGJi8W0eecVjqbR1trUbwX1tvWLGB)QPnYr1nrcdD0Ol5YK8MGPgDdUFgZCWMD0iLhOxbzwUUdcJVvZLsbGkt0dXDuPjTBMO4ha97ZBioU34gu8rHpou2lYqT323wensKVmfWTvpzXOatCcORyz8UiZG0jgCi2rb47ihg60wDIyyolBuFe(M)g8vnVVG0e6By64lLjMBrtRxSxkrT6gOvE6r(QVh1pTJdpl7CO9whHxCAWX)2)9k98Od2sOxKJw0nyYTXboKXQ)CRzp14muCW)GNicjQSG4ZfaBJqaAaLzT01vc9zhN(mK0PpNiF1VO(EWeXAa4nL9WEjL8WEOzHidKCBUa8TK6fZm1GnWLJGDHZiZutB5akkZKD21NyKbxeh3mq)z4dWkS7Y2QDRO)m(lxmhq(Q(3MwZqfG)B1o2C)6(A7XyI5jBWq5CxjPLeXMPTzZl(Jukmz0vnV0UPY8M6)4VvziMTZG2VpcclHdv0m4VDlp9OwSpP5oyDJnqOTlAWJMOzn09CVwyYwEpKUi4Vb)WmpfkEH)vh5((ZPMA5SWe0S8TNTzJUBZ2T7gOxclWlEOYAYdBBQ1)Mv9oUM8cxhruHRRdNrBX)N(AtCUHbvAptR1pGryuRhY02qVJsYpQru3jmnrexqqITfwMSEaknEHfed0u(WnndUm8zZ8TyxqPwHbJjprzW2wqXolsZG7JabJogs6URSxRjR94bnJBhoirGGpEs9H5(T2Mrt8cWDg4jpz8866rypPnNacgdn9jlPDYy5f0xSDCQAmYJWvcH6VRkf)iI)WueAz7vQgOLZkyytpseA6lXUpnZDV0ZtDe0MWLQ6SGjuNjoR9xE0Dc3Nu01zgrejergITzFRheVliIj44LApwQbSR2NDaPRs(FzVwpotFt5DPvmo9GhLGktNgCRqVTAMrPH6SONGyMy)tq)8LgirrH5vQcrUZEX49YuBGQyG2DVFEd1jtgZwV9fyEkx6zPFFyqESbHMAPr2UH3TUEni(3PruaLqBSPEE7TwecqxaKYBtW)iDMFyn4)JfjQgg(3btpH1pUzTPDcDpu6lWRWKmy7Jj6RlpQD9YyIHer))h22E4KZeFI2x8)MJekmqAUMOisw1rYIGhgCnuw2ZNBFnCbO90wI46UvpBXOJMEdbBTof)Hamypv7ppB)jWoheh2e6a0OKLUy9LqbhLzUr3(llaDa9gvUsXnGYZfHN1hwTCJl(EPUaRDP1FHqFqMRrVymuaDSadfInH4GArr4a5kTDoqVmJq(x5UbnizN18DtBge3n1R1Hkq3kDN0mcXEhhYb6WkqapabLRhgHOJDGKK3CvGNN)c0lzcwAmqgY(pzGOpblONvp5TppMtin6Fwsp5lPN(RONV9LTtFXr4FwNm9xNm7fqDPflEE8HWYrBgYEDy8CjSYec67w)W6ot11SYR8oT2GqbqmmO1(mJEQ(7bZTdoyq)L55vAz8uVDpBrB63k9xhnWbCMAxxcvuoJs)8kyutWfsGP46GiAc2VMqwwVrRgeSjfH8plwErO4iNlwZDDgp5hwI3oJoa7ischeiGpv)kYWWnaE1JOElkEG(zmX3o0CeIYZcHbLYEFvBXS3q(atfoStRY3SJXOv)Y7OswXhb5EWlpukhON2muw(IgQ4g8cy6BMW5HYSLoJDDqF8r9xuBVRqXfFenPGJ)Wv2cW4N1(C5aHYhqtu9bsjvQD0xakeYnVb8rPGwywNxw8csiHpykdB04bGvTlEOWO(uxOHMo41tNbOv5IHaKbZ0PPT4OhrVJS4zZCmBk4UQCrNvFrIa2l6A0a7kewFMpSqh)RzX6sdfmt(HdjJYnRguNmeOdwzoXWeZ(aoEP2U36WdgagmNeW)06ohaBPxEVhP6x0c97XCQk)XvjVxK(BUQhRAiXF4i0cRNcEunbBI)R2AD1gNtgesgH8c6XQGfppDbFZ5WQBoQe9)plvI9ASAIe2tRR6bsWtADbT37bX53cLKNPgz)h3pQ(Wa0Fq(0oPOpndP9oqtv8OklW2ZLbdcblM1jLcbbC(DdiUDsIWhu8dREWlBaOu0p9UF0GJMSccEyRvE7cyar(XfQVgZGsiSCBZ0Zz5UOSEhC6PSeyd0Nkv8XkJZGbxLvhByVtmx3fc9e136VQb(LW0PgBq4DkWuIc4ybu8J3wS4Sw)QpJx5pIjN)IXln(MUlnCPtIxrdcj(iuRra9cSr(EGkY0bv8ZS8(D6UqOeu2YcOrCj(pa4zKg3tKzxySB4ZqpW5nt0o5auuXF9MvkwkSKkFas9oM)qfh7BX8wAXGKD)mpd2YUhxaVlPIV78MJh0A6fT(O8gnz(42HHUuvhJjyVWA9D26BXFkaQJkf8r(S6FEL7i2noA(xm8pj9k28k1rWCSzA5QT8fmN8H96cPmQ8FmZTJ3R(F)A7zF6DWitthLlWeGV)nDMeiDnmMaxPl5iiCRWjHHE2ipCVRk70FIWxl1yfUghqvDQFC9nWeWfevAnfpmGz(hyEae2oohpGpCBRsuJbXW()ZbF(dyrSZqfjvwcCxJ0D1Su(Es1VspvmVxlL1Yrvjgj)ZL61SChNZ2UzZxdccQFLKLa1kGGcGQG)fJizrXrdkl)W4SP4ZQbkxWiBbo4fR(IsqXxpLFrbb2Zl(OZ7DUdGEjheY2lkz9eDtIhmfEU0tLDyttN9xjXBBWW5bAl15OXglEQmhFWVTg4l14ZS(qUO90c1cMO(q4nAokU)VKA7OBVpW4zLHrPRl5wLycF(ZxahNpcwzpTEpoHyxRmE3(jq8)Oq4rAFt9yZtnPid1kVUK6bb2t)tXdyfmbGxVEJ6Iwzd6ZZlndwDWCcaNE36dop)SeQJjeEJD4WbLsqOr1Q6sUpREj4naa6ybDIzTrxoIAOS3uj8jw6clhBSIF4tcf(W(D0EqwdhpIXhfyMA(AIGS(T3sIGlJ682Jtz)0W5jPhlUojMLUojCO6W)OXR65CvhrVj6uULSMNX5Rtju8IcLD7ROegkSPs5hzmwulPeXSe74ru0K8OG(9V3sfz5MtfLga7oKKdyzPleE56PhjuXTrXXV)QWa)fZLoM30FiqLOwNBO3gncFnrKiow08WqFK3PH6YphYcURLtIwKFZt7i5Cw5g4dD(OoXotdP6cxq4O73b2syLz)kTI3nesZZgN3WMMBql1nOA5pVjYFrJ3rCxgHZPBWX6m4OVt2pPQWIBvBUyqN91Sok3kFBxNAFrjPbUxYdhyBE3tRO9F7KTh3qZmOmvh13T6g0NgT7wEURZmCrVuY7Hk8zPf6rHWim8pU8TuGHbvLiwDeF7F00RUCAtZRRJkBih8QFGPnd1bXpBMFet(FseBhGLTLo80g22TWC1ao4oZ6GRbLKinTHgZcDYLMI0YaJfhc3mNS22RhO08CQrVoWMuinbPF1h(BwRywRPZQ15d62hxYajLMb9SrIjDchLfqMVqOdLry0G8LtVuR4QoP1Bz6Qx9KxHY0RRmZDE0m9OsYFB8s6THkyVXiMPAVmxASgiFRRktbyAn)q5PwrG9cDOmNvILWEbj52MV6UuvRNgeKifP9F8gwwV2QZ5Lg)wwWCbbP6M9prsgzA5bHR(Du74uzNENpQiBiEib7j(o8VAcf770vuHM19EEeUm2XlyDSUp6HEa8J)039d)uWQMxCoUc1izLDWlSJGNKxb38cFuzr6GFb6Kr9QhGIISENvPm)ry1jariwneAdqQRAaj6ezhyostFhwAGDFktc41vNyCH1gtoh6Qd3eVO6cSmztHc5EP23pxgJ6MY3JkLL81V3RWZgVQd07XpAwZWCTtL643)OPM7WWfkLM6WCAL05jPFqa9cgylL6tCzgavvXlrKMXZ6z3s)OIbfM((6xD4KMG0QfUjoS94uUtB9emHdNMv5j8E9ZxV(x8RWTxg(JetbznBLZSni2)2xqrTsIM(1DEddmkPgy9BT9oUhAqlRddQXAtxRdmwuTzCZFd0Ag300WM7QXIqT3Kb6wno0KrEuk7ZkZkm7Tb79Hv)FL)LyWmUKBDwMUy8Nuc59fTN2K3iOxqOYOJT3Qu3FpvKyFaCo7(NG6LGCfgmp49lP512JyXeG9O1XGEh0VrcUyq0lEy5Jkpm3RnBW3)5U1ktIilNGij6Q3C0NZBUbIy7k9DUb0Gcpb1zXD7wE)Qq8veLuY)6QD)Yktuedti1WZomNWPrheDddoPG6pBA9HjfunsjKBoVW4gbdNaJuBmn4Dl05SW8aLGqPuCl7mPq0VeqWyDS10(6r7cjhUXUaGlMMNbr5Gmka93oevWUsyIJ9FGfL7d3rsjHnQHgG2I8OIsnoPR4p5hn1mmULXGwaJtzAqGgktwNAQRIABEEEJpIlFLiohM2gVrGhs(A)HGO2PLdpSD88RoRjotRVSxPN9NL8kbPAhWnzZpQCj92nPSPtvooNTZYqY)K6TntNMFOOh3NBI7foVMObl3Cd81nXATb)OYzMrP6Vb0fk1YoTLBdgNR)YpPV0Fa(d7nrfX0mpmHtMJeI46ZXz0EboULo2)Ff8GPaV)(gUEchqFfkGamX8v4hWG5h3(fpdh9vWn8VxkX0sxNzn2x5luKdYfDa()3CxlRGWWab)yepii9qaPx8BPGiEWZ1)FS7ZSDswFafu6PcPgAt310zNz2)RfqlHaF1VR)t(9R8BSnv8dw23H(IXv8VS7AlgGGPZK78XAAYyzBUZ6bMlEZfxb)6DgnidHAH)OilTeuOhSMwqLNw3CIDHA0MWYZlxIacwtzKkKhppRAQnsQq9edkqH9wANksmh6XzIAybCPhmhqtadFzJh75zKU9qUYY)6LsPocN5LO)nub0w54zZEhYE1QVmN8T7y6CQpmkPBigKSFUBVUvfL5mHbq6hjnM4jSFg8XJC4N3F0dx2kUa7J(a2Lo0Cwy8c)0hGk5uFtlnlVqGsD6GrSxIrYs4uWTYdgstRbgecrxxwNSUGLKuGNeAoBnTaH6rVYZcMESCm9m]] )


end