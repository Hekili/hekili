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


    spec:RegisterPack( "Balance", 20220725, [[Hekili:S3x2YTnswI(TOyIIM0sIIeuuYUcBnHDz7P7AQTPKVDFFsuqKGM4Asc2aGwwt4GF73ZsUJmbaPL7U6EMhSLewsK5jp7B5ndV593C9S4YKB(LObrrdUmAC)HxeD5ONFZ1LpSj5MR3ep9JXFa(L1XRG))1XlJxpLU(dlZINHVFr22C8slkl3u89ND2D8ZCAr6QP9)qA5IT31pn7mXRE61PR(HZwnR)IYvl)3NNUm5LIxOF5NlV5672MUS8pV(M78oXgEXnxhVTCrw(nxJde8vtNnlHF8KIPQz4UBFt(20z7(XFC7Yh2DB04tG)dgPD)4UF8hweV(djfF)UF80D3(k41NT72RZwgNV72xNeVQpDD(HG7ugN)HKYjPZ3D704IKc4kzWV(W0Ljt47vWVXVNSk7t4BSD96KPjffX5Wx(tX5PX3TeFVUP9t6dZJn5jFAsb8UfBHxF3TNEfFT(QR1JhXx9PmyjG3d(YLPR)WUB)R5XLl2DloBslFcozwaJW95z4nF70LPBks4x(NJ)iCNFiB9NYWFHEUR3KMNwcVv8UBxMwwUeU2QSC4)NVm5ZP3H)DxCSFiB7UBxepB9tkHFMwIFTD3c7OBxwgVojBBbcvVpfNlV(xF173D7XW3kbwMLPXlHz(Y0pSEvY6YtO5jSik(y6MEMZSvzfWq(K5PFyr5K8KvXPRlEc8CttwdGSmCsUzd(vqW9DzfWfONf(z26LpWd17ZtIHr59zRGrmdM4VEz8c7)pMxUfBsMstTY801FmPKF)FDtY6KC9wdbEn(51WoY808KEW8nEMcALNuKUmfwE8Sljoh(lyyMMT6U4YtX9rXh4DPFE3T)NPRNLJygVD1MS7tYxrV50fjt)iSOYGx8hEdG2uaeAMOs7UDgId3FD2KPZkeVaIST7hF161zLa5bmMke(x9B)eIIUgGw4gA221WDrOZJdH5Y0IYcKEpJGzWV9le7dy7cWBMDZRbkZPLPzRV567rOhtqMNUHV2VXiXavOcjoMMGmqwqkKbZ(RFVeZ6xW9BaggNiE4xNHOAiatUXa)fGzNFFAbWbc(ALja52nx3f2ueedl3c4ttwN8zyK(Yx0xpD9KcMO35Q3LHFBZlgV(bXaa4bDeeRd7FpVmGlCK4Ar81UPeyBfa2uiM4oZ2U0GKVDDcGpaObcq)KS5tIxUCs5cG6VOVy84z3ri(2NGlTUS)AIkAocOe3cW3X3tWGI(QWaT72xU72HQhQmEzc(2XLBbu6jY9B1NPh)KgqtcK5hAsa69fA2tc)kaES3LTEBr)sGuk6ztI2mfr6wNai)3C9yeMoQgykHa5auBn4SJFqzNMaJ7ZSVejiMhdmqvKoQ5pbuVdK9yU88GePxDLPihVxq7naf1tbceAWyeW(iP2e(zowDljQN5D7HqV80PL4usnHMIaj(pMG09m1)ewhab9VN9JSnWOLuQhhPWp83wUf(riW5ve4SJKoqGxI3Fzw(mB8E1nHHcaBZYtNxwbLTMpuKdNPRtqzkVk7Tm7NrhZSFY2wImGHbxW8H5jDTyojUy0XwCG(esCqqP0IjXzjiu68hdOeXQdHsEN8GUiXO8I7xKS2K3ijnGeFJZtXaIpw6uujIcus2YKpfJIJi5qKwcc1iesEtiEBZtYjjymKGFFqgXsuQhPpumILyT85jfcbgV3qasfPpmDgWLDvw2AE1G7Rg3OyBGRRfN45omAGZnMVn)bK3qcWdZ416NdlG1GYotMNNS()(b(o3TD(CGeAs66P9f6Tq8dmV(STazykIoHVHC51xGuyVf(xe3fH(Xs9ckyD8i9WIXfz6AswjmFzaEmRBiTHvKwUv85ama8PJv65a8DlNY71BlWDWusbHY7tqufCBRWAFBncsWnTlcWS9UK8IK8pcmqDwh)FquMxRUlR7bn)sqKgu7S3jaJmE6c4JNWtT47i9DUyW3bkDfpVerRuQUkuZml(9c8pfbN8E)WRo7pVEQxrQ1iICAw2Yzz3VU)u(lbIfsMuWQi3F7g1Z1AXiS4aV4hiP7yP0c1Cc(r5IhecnREvNbdNsYl5GzkVx3a3wnpEbk4ceyakzEoj2qV4ksxpF7YjlEOGGH2mD9UOaXpdfkta)4mjxxX(klCAy)NtFnhU2ZH)ZqrdyImO)q6bzDENLSm(Hj3zGnrpYiPsdmOwtyPqBVmOiZUnU14QewZqKWWzyqFE9BxcjvSPnDew3mXCeIghAH6OBDwPKsiwsmi5MKwq2Wbx)32USavqBtE2uwjAMmKirNZQAlOf3knSz9mnH)Mm6Nam(z7n)8PjPlj4B3kRZtzW)PM0Jo7q9iKRHpBa9RW(1EoCEiVdm2m9zEC6Sjjizy)4zZac8pJ2(yGIuDMgp7H2Xxr8O9K08bwYxHmQbSUnGQHGzEtCwL47QXtNkn8w9vS1Sn83y0a35rDWQgMuiOFqn2M4G1(dXlNUfhisJKeKNokJIi2v8(xNDpIAJYSboU4FqIerKtyfJxMTQKLdgJQ0gVcm9TKf4igNJL0evK3jxVWm7bqccGC)89g5URu1Q(Oo1tkZMmlnrXxH2QCqOqzWWThRq6yu5K)220nBsa9DxT5barz5eqrZ1S19DQiqZr4HydSYRAZt6IljlcGHACBz)BALwTFgteB1sPiBlOLyj69Qj5BV7bFRehrZQpI77oz05JF2GHocGo30ov17QfD4qDMhJE0iptQgOVzrVQ2IyPIOTKaVcUvte7x0v25X7XgHlH1E(58RF6XS(awZGn5PRG9vKHsCoydr60jBiHh65YP8RPauQ9B4RnnFBj(yt(BBHP52vaX1Nsf4WQ5z4NZbtYH0Oyrm8(aZNS87W1zzMWDAMdU4IWtbFgABD04XJIgAX2xm4Qrgz5bgua25cVckFPJngLZ9Nm6IlJo3gzmsW(ZHX4vvzcBTbenqsLPxWkj(Gj4GI7tuQZRDGtDpYiJ9gPhplhYG2jYjdpmg3wnl3tw(9AEcfvz2ev)Sj6B5SrbW7v1igHbwKgOcblKRzfsuessyDNeIRMLTLmGlJUuIWmf0esc1u868RGMKdcbaep(MoQCbIoSKpndGpRNLkv9A4G9w8e6EkGr6DPRrC8CqO5KIKKpMKBZzPkoB0GbTsfvwEY5dOnaIlJ9Nbm7gD09tjKGEgAp79XqTsEgnuDBfxrXWg0O6TU7OXRFqHMvi2Qi)RZ7p3hNYHAHCicUB92TBwKbdhR6S5UJ1cyc(M0EKRFXRAM8BfIp3D7VQKWhnOizAbAC(8mHn8sKncNcNofzk96lL6fHEzeEKnsta8zYTm(DveBBAGuqfffC260w9e1pVjJSQaR2GkmqIF1ouHrHToSrC5rxQPIQcOWnwx)XwDJ9AwLfcb63j1DU4B)UQREsow9w3(6fH9jrNgusZR)YBncYfvWpSvfVb7J4rOxnkG1AJ5RZej(ZOWsR1C)b2AwBQruz(2PGojfGHbFcJjWDj4wCVhd)dyPSTF7gAJTbxP0cXhHdJk0kD8S21Qvjp7VCtl1bMHlXbDhjndgBOPXaChuuCoOWvs(A0izG5)C3yfDKyNi4Zp5CLpbB1d2jS7MImT77qbwTDdPNIlrqibc)2)Ou83rNPH68oUVsvJr9zsm6TUBzw2SLBlkLenc1r6ZEbQ(NTv0PhlgTN2S9cT3yHxQ3j122eAhsJn1ew3FC4P4iD8vlVp(HcHqV)8)1BSDDplhmuadScqXFZvJy3Oljrydtuys6R51zoW(ydkPJQzCXPJBCt8OJGWewu5V70AgidIHGA1VDUnkANmDoSO7onOqwNdWlkUsH3lncKZ39xtaPtcyu(zzLYic2VmDkhZaECPBzf3b1diwn1hCc8HQjKSJmNcYOv6ohCcbipOToWs4dhd05azgLarW3f4F88bog66dU5NV3EkqVvpyN9xw2ObYPIBCUAGl15MQdeGsbjgDJgKfX47xG2Et2FJi0SdObBeVld5TIwckY(SvucRrbowzHpGcuAAgPmw5OE7ZmvCxYGJSZu5xB6VObIy4fH)zXsmoo4xa15cd)lN8mg2Qsj8K)PGxMAUU(4Oxkt0IJA0tmpUoHQTr3SBtkdyiEVDUnThlT1Wnx4hyI2dC1jWmKYjtC)CgsxdAnXXSYrx53NBwtixTNAHlzvtvp6KDrdZStBAk9cEQB6yC)bI4OAaMMCicU)69t4y8z9Z1RAuOJ4tvlZZo71NPAelDKb)XhGVZ6ALuw3uP2fKa26jWKAIkjDLil84S1ZchzSbkK8POmtZ9P6z7fVpYz36KeDYTobZqSpK(FN0wLoDLK5ZLTaNEGbjWNtCvJ8vtDfKNVB0PDEOOwZOmQcJs)oqVvU92dRUqUT4Bm)VO)iX)l6pE8)8oL(dk)pVZ1hF(Fn)zAn)p1AZNgFEHQ1BEX)CX0CV4B(TGPzeXI0nhhCTrTqQTlRtSsJtGT5QcPkQAoR4xLUfLZYUrOYAWFBkpKFiJcLxMq)xmfoipaGMgXdlQkDHH)NaEb2PKSrEl7ZCErQwAK4YI8Xnkuzlu5ly8UfLCkCJ1IdvKhvsIB52Pa)QHm5Uz3RnOI1kj69A2SLIerqdhin2yDM0Sa1EM0(Gtiv2Ts5RCcSVwmAI34esOfA9bVZKGofryMe(lJmnnjo3kAL2yGHsr84zZQzDBTDAi5DrCbn4iTtl0oRIK70I(LzRitSxLHU6dz(ont40p4DkQFL4ZbP1VsI8UsIQzLesAOTXAFTReFPJDWvsGHXyL1kNdy5fbpUu06(vJNLlLGjITWS41OXZXBbida3Wcy4bmIVLjtPQKkUiOHZ93D7UBVgjL0uxir158BbubyqJxIbPBDcowQsjBbqqSe9nMAl)CFzoDZ06OFqyVlZ5a7G(dz17QuxjNVz6Ukb7MlcaIC1OwQMsfyhffBmBjGFmvKXDikc81OBL854vBWLSGZaZajhEZzBxTH8GL0bLYS3gtHEeCoFEptmKcejK4twjjCBgcmEVHagF45Qp8(NzQIampCGJ60bZPsVWEeFsuveMPF4Rk(ndF(uSaWRNXUjcZkHVNtAcvXMyu)K6c1Ky5kEQ(wzgIqNM4InQ0wuUkrVqcYJMalf3skQscKiFhrr7n9BFn0zuyuWSHeRIIM9uqHnV9P3WWCV8(S81taPWXRWSDXmdxmSSY7dAQyfwtiRI)mHxqzLUsLTgFvEEQR0QKpNmDBzIUuSOXJNm1x6CHk0opvpx4P22nTjNBjghVbFTPXLtPlXIM4mrGRyMm(cONPfVbplCl8h6ZpbFZj4lccPMFy6)CKp0So16j(lTQ0aGyJChmgjoG)vrPBodDShu2o7VDNUVcOqv5cU8NYN8P0ceHWpVdV7ggCWrDUG9uCEPkaCWkOCZs8c3o(jg9ru3wwrl7dRHLUUyZ9PsMChWJrs(IELUSC40zdWba2wK8h0(oKroX2J4C5MflHkuN6SIZJfAwH5AV2SCDsG2wVdzKAH4c(bRMCDdJUSrl8Q1rkdQ3JhISZTNHPSDDdIe6wOkqEqEcpYTjKxnBGS18mSfYg5TzOv0ynZUkPPZlDsh5QX0ZPmrvFiznbAXgFOi5bguXlBnSp7F2f8tDSVvLoeDUyL1lIt4aL9BUwVeTRq9dnLG1ZfVVvveN76Ofr7uIy59rNWfSUmnbHn)NzSK8)kezSZR0Rn(ME4Gg4c1ZN1HQGtYHKg44z2WqCCAbSyZtMdIOwWwF0e9YlikWobeqAn5pNnWSzrI9epO)6y5CICWIJaH9Q(wvuPHYYwcxXNMvEs7AqOMSGErzABa5hjRsNYMTbJgTpUtKNKlt)ek0C45CYvYYAiPqSCgUnDOMPXYwHHD2LeR67lQsEgFiC1YJlz7enS8QGlR1c2mjYGZfXFINwzQ9q0YPC6IoYL9y6Tfq4VszGb2RswrQCTkJRSbr9WAx8SgPmUiJZr4gGEJ5icm7V5A2eQtvkL66XzAtUiLscyLraykmBLsWEcrHO9xuP4O70IpfHgWZmfJbL2YXBMiAkkiIt9mW7yqpAWyvLJkUCCniV65ZiDfbR4vC2B(pts2WkYCTQiYrCf6xWLxb23FyCfrrb8tpmnopwI9r9qNcR9nDHyUmrIBQ8TG2jOOgu3Lq1(g5WbPY6mZAM(isHSBU71Ouq9wGxRSDmQtrsxtZvOIMb(3c4hi04W83QipREXF9SXAQHvxNVgURHvA4YqMNWWMxsEuYVaXLmQYK5ltOChFYhwMUc)0wYezrWFhmoCq0cRurud8Zh7Zjnnqb8xfT)ccrcrbPoJbNd7u8aKCMS2OVdr2fvQjNHzKxNu0gmnarHmlJQuzAev5e3Bq3ZDn)(23r5vfMTclxGTyvoOzAlQ4fKH7yBIUOrK3Vvunpcigk8SQMDmYNxYA1oVfphARqZje5M9rfhsIrg7bH7uUovWuu)oisZyz8f8lR1CdRTSbAGeCKbyUo)M0eoGqhvL1tEC7ri2GwSzAaXiYs9TwJSQ)e6ipEZbvBZozDiO2SJJA915JenRbMlK5dhgIxOQrmYdz9KfawGvgxPpUDCIN2cd)uJSpThAA0B5qtt6afI7tL7j(qoKr9TM5MRMZE9HKDtvBl3Ou4IL3dLRYbFNSZiVengan5TftaXE22n9z0cu9gI2phJKd1UGipbj7pqgJ5XAEYg(XxCTj3NTU0Y7HbDADrPQZF5XEc9k4(QSWcYZs5p(LzU8S2UHz16fkHm0o)yztQJaoKsHLyTbCUxf0AK9H6b8dBKwMQJ6TJ)(2FJPVsXwQ1gtBkaRgv6oVnROB8v)KYD74zXWgWNG139XyGnQZMAKrGrkyFKY2e7bzYS4vyBxedwYsuAjV2Xu52)dkwZkLed)KwC69HFsp9oJQ)JATfFaTfGmswITHcrfIpjdel4a6X)2MSIcUXDswly4j2rAKqu26)VTfLsv0WECM8EjFEd6GcFL3Oz4KA2lgU6iv6x3t2rKOn2hhYiaYjaSp6F6oFoyu4ISE2(GOhXZMf2CSIzD59WElUcQ4wQkY204MCef1YS8kJqvcJ22T2aX4rv1oujniSFUDFLo2QFuFfteUWletOa9aJakNqBpVqUt(mlPEv3Nmlk3N26TNEsQwFXdtPbxipYPy75pqLbMPDSuFOrFLvdU7lubuU9l3EwRlpznSuJ1wL3yvx4kikninNoNoCS(DPZT(zv)4l1ODiW9sqa6FcjlLQ0z8)Scn0oTh5Qg2kPq6RZkF3j2Vicln65BPSdbnEtK)gjfpZ(Ryu012FmqJL3WMBwXPD(BwVsF7GFBBFgEtDvFk85zHNSqwFsbEx2VyybTu3JPXB24ybul5YCZHvnNwCtCReUGkQ2Cqwc3EDQRCPKOPaUBrjw1qA6t3qLOEHMBupMVQ)8ynGs7hldxqNGM(h5X0)gcRFpBfIcxoEb4qBHgCasamctW4gCyKFihzT2Lk(T1eef)V)b27HSs(htCvzhxnyjH6W1Zl5O0l7bIxT5kXkaMJRdh7axPyw(EHnwI31BiNzRJaySSHS7nK(YAWvWfsYSZie(iYOry8z8jVMY4ob9He7MX8TOkgWNCVGD1qW)sgS2Z4HcKU(EVNnLtFYzQvQ0Wwaz07tW8loFnn9UPUsyriYh584MljY2kdRm7RPC21uQITzSI92cQRbtEKv2Di5Yu0xAAux2ieeRFV2YEktLyYq2Cf7qp1Cgd8SB8LS7AFhyuTV7PPnE6ZF(n(vQoiB8RweUHqvFmtgyRYNzMbesVmAzisYvHQqJmufsNLHcI97s4OzA0TpjlbfOau0nXKnsQjIVu7xPMJPyt)k58wwFryfMolHdxPoORH4ZuPRLsp5ReMBdO0c)aOZfzVMjzR50r7jwPTV6c)cKIump7XnKCoMkte2bcUvPUwhGKP5zCtiVIjAs3gBpRRJf2ZLgW16gcCVW8gnQKNG3VxnwWzvZzEBkuVqrU5RKyg47oefLMKQPUHM28Uw020cYv8koVDRvTQXnQ4eLGSHlzfPc5(O5Inz5)RysjkPIKY313MIm9sH5Z4Eaksq38XnysiyjqU2TIErIuFCd8ij0uXqdDx)O4emLkoJb7UbuqlIQ9O0O6I)nBxTr455kbl0vsiXpPu118RCiseOOZAmkdD2h3Z4bZVsQG1Av5vPydqkRAtY2a3Z85PldAAVbsIQSHix7CBes9piOWyBLMRX75EKyuNd19f6beWem)Vk3NauGsfTOurYqX5aaEikzs8jFh4w5MjJDF80xc9P8mnDq1uFI(R)IunCeAZFinPX9yXkqUirfFix2cHZ8etUbwjcTC)vyfTqfP(wkg1(aA4jtl9NpLIxQM3BFPBkQs34dfUj)S9ipfA6Zzsk5PoBRZXMX2zMtJ0wMoXTMTtLMaTna)v04PY0JLAeYhaRtUNCaRpcs03MEDYNL9sVBl(TWNvy7KxZLO9JWj8SDE1kWpNUaxsfgDoG8e(Atuh4pJvM9y(0QaWjPKiyGRFb(J0eS16NoUETn7SpEqOw1s14ilIxoNrsqOyZhPeTfkYR46uzuA5q7K0DLQhY))S2FGbyPE)X1BjvPR)RYd3PF4nM56AEEAwU2UvCS2)mKPMYKGJX58LzitIUyuDX18dtewk(uHzjNP6iKwpTsxmItPv4Ey8mHbrNXj8vBYlev2cBx)qcEDghluOcd6aPC8qbJUeq)JhWz73PwmSobNBPmJvKt44mxjppGp(ezWPOQsQH6s0AX9RwkEy4CdS97AOGZ7Oa3juzrw(LZ5KrKuEsCsekJ9Jdx86Wg7SpXsZ1OH6to1ACJ0inT2EWZPQ5WE1c6GCsnT3T)1TP)ZlOiPRiOKh7PsD2cbqoDN4q47S95jJev8RuffprPTHAhKkpOEskwvPkxhNY2sD6GqwT)xsKdiLJiegi4pKbY(iDy(H8xXNEosloWojHMlHOsqPKyN6Ah6UA3dyTwCZ(v3W6Iy10kn1zgNHIOL(DCY52Jh)DaGsulCOIs8xDKrWtkYxiLnkviR88(Hd)UJIWv4bw1S39AUCKF4yNWdP)LtlSHrYpt99CqjvsY3NjKdBlcT21zd(nGwNlcvZPGtcGJVMZupL8Jmb1hB0Tt89T93KixPg5AWV1K7DG1iLlY3Ae5XA6TmZLpnvk8Q)QMdy3qEvWqgmjVgpfHTZFbrEKH5OOJKUglppr35Gutk08Qnv7MvC)nrau)oM6xrIZLRkmovN2tZ0N6z0FZhO0m6mDcjoBMk9l5haTTwhdjupNfPO)sufEMAgGNZ1PBwMIm85oaA5uQSYK5(ICyiCbeAunx50WhAFTOSUD09m1gBrqdyMcTnPhvMH7zKxKeV0oyeHEildtu8zF0tMYgEwXu1hddNqhTt3pKiMifSCpeOHpdnQysrxeoJlfjXjJhgXSsMNCVk)OfCxOIyuK4LUP9zj3nfUxDl0WeQ(g5C2uu)F8dlEeowDf1rm2Q65VWW54U5Zv14aWEULqduNdoMjeGWnj6xqu3ANp4Srd6wT)M0t4FsXHB6Wbi4jzQzAAj8LjNSwuDYzLf3mCa3Jm7V444zpbTcVTcOJ8rl3jRfuoXTVhg5S77FZ)Bpk4Fe9OG22Gcm8nXFa79a7JVmpAp2IOjG3HmS9F9Crd(FlzF2dXT40KV2q24PasSynHRmHIPLIWPOZXczKjNNUoTqwz7jMXXrRvkhihNyzEZHvBC8(Ax9UvJytcni4Zv(w2pJQ2(N83POmTpS3(GIxV9qFl6ZsMENmynd2ZMsWXyQGcqysU2KV(D8NjOFd4gAYgiqtS2xkAzospBxd9gJaeACa8vuAfsz4VM5sWYRFf6qI3tmkmTFlzdP3bhwg7O(7AZtRzU1XIGPnS34uWzVyVzM1o1fGGlRYAlqZTvGjEyhlhvyM6jo5vszdHN1eDZWWfNbHv4Rlu2ykQxNl2mZOMAJJGecUpoVv(TRT4lmbB6wDIxYZQ0DQxOcnAvszRNTREXuTMwmbgvDvLcuO87PiD71Ad4A)TUUaiAmkSRGPyfs7tWZkd4pak3KDYENjaznk1cCyzZU(DbSxN11litTSRzeUvSWlFsqjrTJclDs3vHax4HnYxjNKxWUUrCpUZ5sHZSB2LHAwqvZkUvt2BT)T3tp7q69Go1T918gKR9f1Pbq49sEVJI7xHkJte2WbGhoNntKGnkpWwtny1SsL1ZKNJP47JxkTqxqp8C2fUkg3jIHfbTHAjfTRaeBMgt97TGgZ6zvIU9mXL7sTS(hhYXL1kmRwdVf(MJKrQh3s1TTzOVqZD)nv)ssfmmJS39yIEbq1r3AOscDcDoyZGq5lV)1gaxbJQSAFsqRXIDkJ)pBqMl(QHmhW5pCOtw0wKsaUp400CCkb6rTepY7auEqhAYUeJ3qP3r1dVmZ7wvlcd)14Q(EhpoNa1W9stT8SpKT8r6MZoB1THk7yJiqGJonJ4aB1xXybJ2XgeMymZwMH8cGEpzDHziXjG7UB)tcORv1tTotb1NKeNV8HjaAaTp76O6PvRNfVVSaFuRiK5j3PIpEPNQn)G)cdFEvUwL)DUOmPpyidD2ZY2rMlOpGTGcCNgXt)aU)lBcS2zLwjMfgiIIVsO4FDRRN93acV5yoNWbrMhtO2vbQWaTtL9JGQ(tWF)yN1XL8VTzN)g9MJmSsMfzdmnEtcq7s9cP1ywgsjxdWA4T40yNkx1vB)wuYXfBMGdnbA2FvuXi)KVnDgsYrhg6DC85TBjbhKjzx7xuoVKonOQXOU2PACsXeYhdMv5F7u9vkP08yI0XxfDCkjzZB)C5QR6zjPpxSyOWU)JuYE2YEdu6VbeJ7NOuwmUbKh1PYvnzHgKoV7HKtqM(mdDa3x7rjlZL)IlLZi3MYBDfQKt8foQwCWGEOZYHxn6XKX7oCVO7eaeobp704x34WqfhL6IttDZ(M9TEqmLdenrbLEuQO(6QUzRivEMQnpyFulic0iYt(EuiPwakAElZs)1ssOGE1x(jfrPT)UB)z6iev4ve0vdRlfnQRkDbd6BSTamLE3TVpcymracoWLOPF)WBkKjK1D4HruYUBf7)fukPl1wqQNyPU1wjwI4QDbLoo3LGFSc4MPttH5eQcPYnn9dwN9f(pDvvj7YHvM96SurDxg8UKchcQlKio4QW7YDBK1w9gYk1HIVipwB16JATE5bRMtNqvRVaQ5AWTh9EDEnjvI)zlvo7h(0viVk45Uwq)O2jW9m5w8CAAHRLTPL9XdpRuWIxvZiGfTjsh6JTCLzfPxMYubtbGfNLxkvz9GNwEqPNQaVzOUEmtTlp)kLbDZQxvNh9nuAOUumOQylh6Q)I4LjIHzIuo5U0LW6b9iRObPgVw4StuxuSEwMzvelo5LIW7T0lwqhKsCkPiz0bpYkRu7ggqmJzNWRtcAfkLNAOOXlSQA8DEQy8YCEHvRLpNyWQWXoRdSyYDfq)8iDFcZRLdp1(ycS2sIMEIwvJ5N32AmxHu5S5yi7nuLL3yowTZFCc)Kz)9Onmj(hzbOFqX2m6rR0UDDdIfDqlBj82oS3iIgCIeetjgpAo0n)ttRHVIbKeWQUC2iuDWlkOwDLTIz5BHB5UMwWDF6nvuFiyrTt3v(L7B4dwAQgYzqtrlawsh(Fv(ukjBM4jJT4ne2dZJBLVLv2M4Xzi8SWOkDW5sLeWfN(mKJzui9Ez1y3vye2UtSWqlXp3XMNuqKwQt3MZsBum6PbD8XMJebD3FN)eio47LktDAld6JDHVhtPTk1bQf9OI6L13gJ1EH7h5mvS3vbiUt7ICFLjJmj7QTwfRXTxsRMm98fs3nfbJKRC1AHWkTOQnnvABq(Fv89bcG3wua4gamhFx2YhevlhH3ioO68kKqQwJUqNTsY1F6aL88KPKTocZWSCsQHbfIPILJ2WvHy3M9jnHpUNhNe6QxiwxmAU9wFko3ObGNRmauwvoiL3jsyTQuDILTYdzM7QRPb5kuD4HGA8GU)eawDvbuxSXy3ZD(KsVYub8UNiw6Z2eBKO0cI1NDS3a2JVlQghNW5oUGU52iyGJbYgTmOo20YxUTEqCF0qJmkBSkpe97Q0aojLE4w1LpvdqfKst)V5t7Uonb07OC3zdjK)vQu5ST1AGJx5AJTrTJHO4f46)VUJ3IqzDwrO(gJOSziIe1fnCioPRfhtvkl6vPuFbbw2YmTmumd57XhDIEme1plMqbQVfn0aMQ3JgINr)PiUw70feoXSzLPpRK2c6XymXX7bzf5F6Np7D)SVaKP2TBxfQtB6oLNobfcBh)J4xYRgxv1LQAlsObv0CYmB9EOvdhOsPq)VgRrRI2Vsjd3e5PB2xB0MCK4Rgn8ggH3VH)NiOJD7(nf7QjVXenGhFD(k)UjW00bVDaN2ZL3VWJd32vp((0uNsZ2qJUBe0U(qZJG3a82fCQmboMp7KF6UgA7V9cpxzvY1JGKpA40pPU8uPwNr47MEZ0uHe7gbsX1M)7DQwz9d6FElH)IH2x((RE)2P(JiZHRS3DLVnKNkR()6CvMLhyQ1nqMROlCuwk9V5gmBfntAWJW((g9I)2CG3)v6IQocsO6twPEoRmh9id77PVIwnfx7m11t(8X((9YCuHvQGJjf1BoYMB6mb8SUGCBAQ84UaHgaaF6hrnOQ263PdymPblcN44ONLWUttE21zVWHzrGAOK7U(BOH2wKqVGBrW63tpwSscLOWTJ4KcV1G9r979o0es0ex)11SBAQgS3NsgyCwtm9oMMMEF9UepGw3EpgjfBudRqQeJWJBn3UyYX6tnyPCfklZkMic(FGKX(TGw0R4gcYc0BfR2IfCo7FmuR7paBk48BdvzX0HMwFuliYrkCo3JU5DD8MIfywfnxzuVYPAfPGHimppmip6g8h5eMPtXikMiEZLOYI4iaR255XRskCs2OFljh2ROn5VY67Xx4DkKbZ2UGRjpmMjpewj7zyx8q91qDOFEg6BrwhqYdpU1xNU9qywyXi3gtVLCIV0bOslAKu9CdqeTRs4)PBzP75nH65cTMptRPUBVW6xODvrJhWz8mXGkt3EtQOGMPyjgDrNIDbSF4y2Ld2kZHXAQqi(IvuajWUIp0XWLzvI(dD64y)Z(nD0m4pYw))QHoObxw1aBzrwE1u7jwkqiuBuE0izG3AHkUp1qJRaTxzVAAqTK5hJaUjfP8v2xhT1EWORo(NatWpoqRDu8G(oAyuTOaYHX)YplE03H)sP0TQYUUQmEDMPAu1EAGY0ZGw(3uiD)wBtpUpeU3s(hPPQ1NXPECBj3rPPmpc222LmVrLjXTGS7R0mcZ5CBf2qCuTGIY0(Z77PwFMZfVpPOSi87ZRWnzZ)Ne6KjprA8A0brpcyL)DRbE(hyKrBNtUhDu0PZmtrIQDu0rHRLmr3eR2(AwOUs2jArtMXDNGqC03JvT5pb8dFizyf5IfYn1t5qhcs04t8zDYNMOYwv3wPggTdvSE54aujpai09crZqYOouK)HmyjCkPUsKyz0b)2Lfy(UAemryYXhUbCemb9w)o6lIlp3cJIg9OOi9tOQKhzFv0RxC16qwh2SPINUnrcdvK19rcfTOhFUwJLMDQYTXKqkCAt)TjZgEH2XE165Gl9XxYjJ7BFu9U0H7rmyhDzEgIUznqwL8xL3VxfZfCDyVlfSAN2J)uh3iN3gygYZC3xStaN3YTsd3qd5HZet0BCEjA0xFR2nenyKyNXa2mhmyYrnvuCU4gchR5YxrlqeUfyVngSemxBJIgC5WreZvKbqXnx)xF1V)l)5F5)473Dl2bqqMqGWXCPppEs2gua5t2zCmuxqzjF82Ym0flZOGHT(dyI5)J)eL5OrFpZhkjNU9t00o)FFcdumVKKSbUv3HFUNAug9vok7(XgwAZsMhVDz5(T2UWEwDD6QFaERhwxI()97451pTf4TplLdrfGjawSgxsr(5SEolYlo4fzKXOC5bpkMZLN91V0IcpCh4K65h8OmQMrPeKT9XKY(d1JI8sL81SwkHE9ipVEu1xF4GdEryckgo8XzyECiphE(JZWC4uawdZHtcev3W0ceLXT59RbtXAzC4enr1nmTyzu70OflJXTJPlw1kzRUlEpz76kmOflit6FxC1wSEg9yWkdDA1B)1FQ9YKIZs2paZJdpHhhwch8O4cMcSNZ(4vVJj(7hFfiEwyj0osfnflUkB22Ly)xYqQ4393fb(FTtQdN5zn6pCGJYZFC1cXvA3HmEFle7n(XzyECqN(ke7yr)F465yoBIEK3YIo)RF8IQz82JLP106W37SgMhhI3Ohz6UrhmUqaHbd)6NFJANmyP5ZpzVee)OH0248Ryp1D6Gfl39YhfPPdRrrSdBuoykh)4wFf2Nf9nq0WbV6Q3uK2pmpswKyXE5rsp1Xpwuz(hVdDAD4BzFB4X5F8o0P1HZaXAyg9iV6oCYnlbvh(EN1WC4KBwdZH7VlP0J)mjSaF5lKHcblP)IsuIavXDZtXue8F7FZOjq)gSDvT7hXR9JBXOzfn(euHUOiCiXl)dSuLVN)RtXA9FgTnYoa)1jXR6RUh)WWD565EcgyRPXfYgmGvVqu)w)EcEe7md7CjRtMMuueJ55Qmi1W72nTFs)t4cJ28yp90ReflT6A90J6R(ugS0W7pv2X3KNyxuT2(ek0AWOCFEMr7GtpaC3Mb3uYuzBRUp3GW2YsmF64yTnFzYN58RRRQqYxeZPg4IurIXvKINjoXRtY2wSu14wE9VIhzghdFl9z7XRK9DJtO5kkV)JPB65o74JRNNyLXqasrXuabjpndNOB2OktukvMPNTGJEPE4EFEckK89Ksfyw286LXlS))yEzxSjzknfLEorng)kfZa92fbUn(PmGS9WeyEMcYLNuKUmnr2snWA1kfhg2FrNI7TgFK3L(z)5q0ozTJnNs5O3GjtewZCoOzUTOnUD92xIU)Q1RZkz9PuejV63(jengiNWC8CE2w5XFYIYYnfF)zNjsk1tHT3P9)aSNU9U(PzNjgGtroENTAw)fLRw(VJeHVuMfRLFUe)Wm1ArFLtYEPmJfeXXdMBcvcTRJ0IebqBGexclJvaIvYXvNsNkX(ubSdmCN(S6bXeYPChFTy0eVXjuM1Kkp(h50KvuAp4VmIVjF8eGPvB15)XV8m5e9em2uVmB9eyKNiMkNqHb9LdoG3mBZlJNntmadpjD(l1UeCrCb9Sy4c7OVSkUMYU9tNJ03mTOpOan1mXwbtKYCmcJtPFBlp3(ANKrMtYi)tYO6MKrTAsYiiM738Md3EefMjKoLRHYzjLjtjK84cdmfgXr((9r7qUgXW0iDiU258BjkMrkT9wNqwKi5masbMTKYZGVsy35iSRfvkYx(s42JNX9WC9Czsjkmys(27EGGACb3ZC31Iw4k1yoNf3uEBmvCAtsG7B7s3k5ZXR2GWfbvft8HMSPQJE32ulALzbLyI9Ad0ru0ic4XObpT7WtX27Xt9vl3TBeNBoIJBCevGiQZhXrbpEfWeSKfuqzxVskPzRka7GsFpxIzQCgP6XxLKRI4PAfoJrdwqbzoE4GNQvrQYzaK)HftwPpIvvDw(k)pbfP(tWwJeiV4LdhGyKDLj)G(OxbWYCsNBRRGml1xqMol9iPo7U93yDui(UcDu4ovNfkjsME97Lm6)fUmWFhMgi0dZh8wiwPoXN05VGATXb2xTWEmxnDenUgAK7Ce9xr8F557ltDlfSDmnz6EKEt0BNE8lF5OQPcdCr)hN9VCiCR6RHKEF5lDRMdswlycY0gqqVoh5nxI8V8PnwN1FdR(ovx7DcTYdozyvDElNHuaQJ4ePwM4BjK9diMejZ)tXPlraLMY8Lmy6oq3F11GLekCXm5ue83Pv8jGSQ0PLcr2Wh6fDJEQvcBHuau2ADSBjkPUJj3OxjZDq80auXEzg30pI1DaADvXXzY2X(OkQWGjTysCwIG3IF47vd709Oa1FWx(sD1acGWfyiJmwGYd7vw0IMMMueLSOi64DghHb68tkh499jQf1nxv)sQCnKmeiHSlAEsoPendT43hpxVtePWeXtQoqepfddLG57vdPLKUT6v3HKH4em8dy)chNaXSjCSAO66U6E(OYiwPQcGbxovK5Lux7lL0vV8EQXCIlJIAwhRNaFqXIGSWeRRZHQwy8x(IXffD9y7RjPKRCvCp16Iw1adFh38A7lFXt6n(sZRj1q8lFrxmUe6kbPP0x71Qm4BxnfqbJzjYqorL7JyCxm47WZcsU7OPKSlp)NIFVaJXm54mBaPgqADMek4T7LZDdhctWt0atXED8aZUA44oh5MzGF5lUxPJDEH2jqUg2PBDza(lE5WOtp3q9dN0727M6lgcYMg(Dg5P4l6oS)ZpTUME9tbn1oLnGDwYY4hMOHWWTg1deaPrkieBwbd9P8BSAFsqkkl3x3oweY6WYyrsFd3d7harWy)Etg(B0EDGDetX7(bsHaXdFEO9gGFk6AJowEb5frJ9dl8EQXlAnnkK9AA8vIe0MvyJznftrIXqNyX4CSes3ali7QbwWkcRO8UDTwtNoC8PbYx4EF3WNnO3vn(sEOWSgHohLhNoBscsD0hmeROFYNrFi2P7rEpkYAI8LEOEizN3P9vPysXVjd3pMnXAE)LVuJ28DcnEJgy(TcVAR5dF6WbE1XuYEviCIO)eyaKNMeB9YgLTSduJ4vZY2EN8SoERQK5q2)KJReVUOTIH)BgRv26QuCyRXmmIKrpzqGg1TSsR1eOdbGRZ2C66RgdB)D7g2s6oD9YpTPgp)lgEXLh3DCyUJOwZ1ommkuqZ474xUIAiDF(jJoF8Zgm0Gp85Ona(Z)DghxNR8gsquFREAnb92bv8i1r9XSFb9u64AayMONTCa9PaXXdJm(gblAHthgblWw4fMoTUdGGGB9iwSigElGmml)oQJcKro0vpCIlapbmWeqF04XJIu7GKfCYrJ6hbONnNapA6Yo69vN7mz0fxgDUgnici7TyeCLltgfGlAqpAjOKVy7el0OZq3Aeal1UFKGgtKFhWSHQETSvmS6f(dgP)Erb)ErpEFpa00ZrN)TUmnPkgXWpLi3qYB8mlqSl5s8nj7xOMAW2nlYGHtOCsqgGvpdqeSbpQ(682DNpAWGakvCC3ZhCkxrCvRi8Ng1tOfJNBE1ONDA3G00WRQ1F)TcMG7U9xvhYhrd4wcP0HIgkYrIuqqLUTJtNewKIkCx9w3wh8AlGbaf3ltltwXa0kSJrL7ci8fOG60gzV4ZPjDQULvhiCWX1achvv9xV7IJUudQVMfoqOB)o6t4BVyVGZ))zVR9EBJCK8Fwmw4gQLS10QLKFaiBG92KG5Em7T3odU)vrXwor3Qy5tT84lalYN9Jvv8rrYISPDYKndW(pZKe1pytwVRFvvFL2Nd1rH2qNAF(SyhBQsOcmkyrfDaDg78X340KwYT4SAb1Czm3pLjCloRphbAaRj46JW0GSBF3sabb3Vw5u02T1pxVfYLdHQ(TYrjYiI4R6Oc0AY2rZQ208wKx(nziTUzLARrPx9U9qMmUhSIwj79oKvEWr42uYRz5m0d8cUirFWHnLbp3VVs21iHL)XTpT6tDAgZ)1)RxfejcQb7Mk(hPJi0)BSz0F1DN9QjZhRuMmD88H41Xhvh1kLmJNFQ8V1lL)i19omT9qLAo0vWrHZgTuN9vfqA8TMxmnVqAckGzWX(YPaeJIaP7qB4kOM(DFoSZfLMHu2E3eI8vgSjjCVkJc0Qc9LP(LOHawpphTdG5(1v8rgNESxuniEoWP)jxoBeJcMy8ZHGnpLEr2PpN9nfePuESfsKKjENp66RUSHzWB43CmpAHc(l4Ik0NksG00MQJ8dNPi)1SgnCbWIzMq1dKcgiqyk7ZF3U9ylm7PvEDBqQF6idvaxAfaRGULBgKCxka)Be6uarZTyheAloihHi2FlhIjb4zi1sqGDR7e4z2zqFXepECF3wo6QjCexe6N0l1tV(I2C2OkJAbYe2KfmSVapNLwSJKqCRSkjHEOA6a2nAY8RfCs1(M5ketgrbXWHF9zjFPNM5nUyY8AXatDuQi5780vEBVor8KYSiUUeRQtkbjhwLIIbHDrEuq)UruwEQ3y21RApkkyVaTkrSk2xGUEU(mvSjaD98AJFX90kEsyqqtMWnuaJFBwg)woEWcz8ZevLaw5yFF(6WB3(peEBjeP9BlVTWB8BpVTWI4ReVD(NCp82vdI0RhTRiBm33pcakucWlraazpENXgfYsgRDcOabRHfsslWNWR3q3373b4h4WotY9oODJChy2cEVeS65pP9(DLfYmFaajCuVeLT(EU)UdA4HjMXsCXHD8WBwD4g8Fc2EnrJI159b7W2ysJl1fL8q2Xy1I5kFpGXE81s4jTeEqkBJVt7hStcGudbtlZlxxfBHURzpQz8etG(YD5HGbI3xNGNr1G040scnxmOAL(LRmFn5gpVL7c)772dgPARXaflOhe8GD(GwegFJpo4dV)ELtKUQCWe)6qa5jH6lWfOZpT3(Z8W2rbizRQej78lsyMm4Cl2bzekHMhcMOzn8rwwyytdCEwVhjiLIqusk5BYzRUOVtFnyGCVYURmPRom9ctApxuoxsfZnYQvN0wdPSDa3z1fxfTNSQ7HCUmNtSU9nllxhZeK0kBUu4abyYuZrnhdCCMymEWoIPOBzY45N24zQKWUR07s8XnAEGhy1ENUscd8GFuQ3DoryxZfzv3BOh8xrjIobDKj(JljyUsjm5QlmHNq8srsy7LwlB99KMeCtSew9ZuODiXDpOySx)Xn3q6CvcCX3MjJjB38RG80jZO0SqcbqXdKaaDRl0GRXvMITXpgUcDrr4IMmdlyLosNn9yPVJnMgEoOzhRjIpS6xPL1UpBgx3U2FyEr26izDIxbTrA5hWMnA5yDwmTksKUDhFwvVcXRRKa2XSt9yZhPFIEkjvhikIqFTX0rzHdkv74VZGjfnKwGtFfP09hc3UW8WQowUcQZGt1A0dTqh)oWzykLIXaVPKhkQv9(WwaVtflL1actNWnpgDDgiZeHGXpnuUI90M2d)3xV(bsFMBAccuM4Fawwq6k0tODn6G(p(0nR2VYqRVjgZpoa5H95AYUutX24SjfuK(U1iA1WkWzDqlXgUQwhRvinTE5c7(IsOTBndIHv(ShUXdE8inwcqoB14iTjwnq(Uwm1toSK82A3jAsUMQNhdPSkPZtG4(RVAMVW7T0b7Y72UgZW8Y3VDZhvVa1cvT(p(4zZVwwlvRi39CIjvCmxsPMwh7uIb1BinIt4fn0fFczZrSvyj9yJHbDlvhFI2uA8kOCW(z6(9)fBL)SbHPGEcPVXmJGHh6oNLZidrgkVSeEzOA(YjjFENBQtAFt6MYoC846WDlNSaGF(VzLrGSYKFBVZwnDAXcU7boxNBQeZe62YSN2JpBPiMNAI6qcxKsFCWJxUGRKXS)AgW01fr1ZIUGECZnars0no)AR6rcf7eWEfoXSUtFcp3fShG7y17WVJMtey)Ggg0g4WFfoZD9Xf0viB5w4EMJsXU47VO5ZE5t7U)qO36EjX6cSu)KQiOHnJBRHFm9Xn(HaOpV(u5tVHt5izFywniQNHK6vPNtppgCPiI4XHZJuZabxk57LBmR7y9Py(5KmW2IqA7Uqg4hFGQTkrshG7E2itb81PBX3pE)byIInlR(Akcb8yljXUz)rzALQJCrMki4dL7OX1tl2rdqABcL8Z6BT6oK0tlzhsSqa6)EW(iCMSz2YbXQAbQOXTDub9(5GHIeAbfliftDNeG02)NhbEtsVkuWzMFB9)3dB2h5EG)W7vYlHJmzM(iTbS9mVF)7)90dryCTOSEP3Xm8csh1F14RZpPttoLSvtIAPkitzQlnIpriWb)hVq4WCqtiaxMsVB3H3CI)ncn9CwDdfplzGnBKVAN)BHHgp)xMsW6RidwI8HtUlrym(oUlEhEmAGrG0bi34JdXMQnyWKzJKmLv94g2ouiGlp(qDTXDT6JhmzKwY3HNuebWkPZ55NNyDhhdvy3NklE(SQbopFYWWFKVjtC4B5fjn)lRieHKcojIvBHCrsQ2(wmyWfNkfYQhFaaa6WSBDaYmIcoCQABHxyWU6Gw8nxDuVUEul6Ad8bnPPNfTxwRmz7LSnR3SPe(buxjM8mPbPQvw7B29NzoxyuZzg41bCnQVAs8pPEaywkGWlVro86AHvyUmIooETeu7NZmc5k6qghrA0sUBRYvQBwJh8(XtS3kbHF5Xjcu0uMrxul5GtBGdojt(rDESIjMq0xk7SoawZfDGv6Bxzt55YXDu6QlSKvygZzdAvMSleWlaKS8xUny3ZLp(kCrTO9Skrcw)A31IDvn)MrFflBjMj6Q(Bs7bEyktSHQELTxsXTumCfiNO9mWBTGp5eK7x1EwTmEfgNQcCDuwJNh(LQE2R2Fp(OZ(f6vFfUXjPVOnFZ21B70WTdJyIPiz5JGNG1dF87Ldh)JejMkyBD4KwNidVH9NJKmvIzUW3gqexL6KLRn7AkZSlxFBrtv(U1uG0zLamzcmTHGbwhsbAcLdEW5Sx7Q8kzXej8u5ZGr9sLCrh3y0v6s6dx12RjZFvx6MBxtHX2FYgkXZfvT04v(h1wFROHqVtc1mYfUJD2OaBOC6jljJJg)B7zAdTODEIShcQvs70GdkUo9dRVz)oOpxeyB21T19uF8xE6GmLhFs8HNgPp1cgTzbbLqLdPeCeHPKMGq4nbk6REkumWkUEQKSeC7xpTroQUjs6MJgDfxMK3yZ1OBW9ZyMd2UNMS5a9kiZY1Hny8TAUukauzIEiUJkndwZef)a4tFzdXXrZSymGxrHpou2lYqDW27tensKVmfW(upzXOatCcORyznUiZG0jxBiwv(8DKJdDARormmNLnQpcFZFd(QM3xqAc9nmD8LYeZTOren2pIO2fd0om9iF13J6N2ZH4KDSYERJWlovY4F7)ETEYHbBj0lYrl6gY324ahYy1FU1SNACgkoaAWteHevwq85cG(qiihGsvw66kH(SJtFgs60NtKV4xuFpyIynaaKYEyVIsEyp0SqKbsUnxagrs9IzMAWMFYrqxWzKzQHNCafLzqn761kYa0HJ9eOhh8byf2DvB1(10Fg)LfZb0JQ)TP1wlQcFR2Pn7VTV2EmMyEYM0to3vsAjrSzAB3(S)iLctgDvZlTJKmVP(7)TkdXSD0T(NEvmAp8h)JzWW6oE6rT4hsZDW6OzGqBx0GhnrZAO7BDTW4l9Jq6IG)g8dZ8uO4f(xDK77pNAQLZstqZY3IZMn6UT72TFGEjSeV4HkRjpUTPw)Bw174AYlCDerfUUoEgTf)F6RnX5gguT6mTwVbJWOwpKP1BEhLKFuJOUBsAIiUGGeBBGmjM6lnEHfed0u(WnndUm8zZ8TyxqPwHbJjprzW2wqbdlsZG7JabJogs6ouSx79Q90bnJBhoirGGpDs9X5(T2Mrt8cWDgi(oz8866ryFDnNacgdn9jlPDYy5f0BPDCQACMJWvcHlVRs)(eIHVueAz73Og4zZk6wtFgeACkXUpnZDV0ZtDe0MWLQ6SaYtNjoR9xE0Dc3Nu01zgrejergMQzFRhfVliIR24LApwQbSR2NDaPRs(FzVwpotFt5DPvmo9GNKGktNgCRqVDAMrPj3TONGyMy)dqpXLgKprH5vQklUZEX49YuBGQyGwgVFEd1jtgZwV9fyEkx5zPFF44DSPaG1sJSDuUBD9Rp8VtT5FkH2yJX82BTieGUaiL3MG)r6m)WgW)hlWCnm8VfMabBEy7gtl55Jq5JaVctYGTpMOVU8iF1lJjgse9)FyB7XtUq8jAFX)BosOWaP5AeHizvhjlcEyW1qzzpFU91WfG2tBjIR7w)KfJoA6neWY6u8hcWGdu9Z8K9Na7CqSmtOdqJsw6I1xcfCuM5gDhUQa0b0Bu5kf3akpxeEwFy9QTU47L6cS2Lw)vc9bzUg9IXqb0Xcmui2eIdQffHdKR02998Ymc5FL7g0GKDwZpmTzqChjVwhQaD7ODsZie7DCihOdRab8aeuUEyeIo2bssEdkbEE(lqVKjyPXazih(SbM7eSGEs9K390yoH0O)zzXKVSy6VQy(2x6l9fhH)zTM0FTMCqa1LwS45XhclhTzih0HXZLWktiOVBZ9B6mvOYAVsK0AdcfaXWGw7Zm6P6Vhm3o4Ob9xQKxRLXt9h9Sf(OF7OFtut73zQDDjur5mk9lROlnbxibMIRdIOjy)Aczz9gTAqWMueY)Iy5fHIJCUyn31f8KFyjE7m6aSJziCyAa(u9lidd3a41pG6TO4b6NXeF7qZrikppbguk791TfZEd5dmv4WoVkFddgJw9ZVRezfFeK7bV8qPCGEAZqz5lAOIBWlGP3tcNhkZw6m21b9ch1FrT9Ugfx8j0Kco(dxBlaJ)Q2Nlhiu(aAIQpqkPYvJ(cqHqUE2Vpkf0cZ68YIxqcj8btzyZ6oaSQDXdwf1N6sn00bVE6maTkxmeGmyMonTfh9i6DKfpBMJztrRvLl6S6lseWErxJgyxHW6Z8Hf64FnlwxAOGzYpCizuU5DG6KHaDWAZjgMy27Xr00UdwhEWaWG5Ka(N205ayl9Y79iv)IwQFpMtv5pUk59I0FZv9yvdj(dhdvy9uWJQjyt8FXwVO24CYGqYiKxqpAcS45Pl4BohwDZrLO))zPsSxJvtKWEADvpqcEsRlO9Epio)wOK8m1z6VF)O6ddqFN8PDwrFAgs79GMQ4X9vGTNRcgMawmRtkfcc48BhqC7KeHpO4hwFVx2aqPOF(T)ObhnzfeC)oR82LWqw8tlvFnMHnqy52MPVTYDrzZE40tzjWwOxpQ4JvgNbd)jRo2W(pyUo0d6jQV1Fvd8lHPZn2GW72EPefWXcO4hVTGRzTpvFgVYFetU8zJxA8nDxA4sNeVIges8jOwJa6fyJ89avKPlK4Nz5d71DYpjOSLfqJ4s83b4zKgzsKzxySB4ZHoW5nt0o5auuXF9Q1kwkSKkVhs9oM)qfh7RX8wAXGKD)mpd2QUhwcVlPIV7YMth0A6NR(O8gnz(02HHUuvhJjyVWA9d26BXFs6PJkf8r(K6FET7i2nsx(xm8pj9k28k1rWCSzIZQT8fmN8(d6cPmQ8FmZ(I3R(F)s7fF(TWyhthLlWeG)0R6mjq6DWO2BTUKJGWTcNeg6zJ8WdUQSt)jcFTFabmX7WH8uN6h3CdmfzbrLwtXddyM)bMhaHTJeXJ4di2Qe1yqKCkwm3m0bsfwa35gDV9kL3JufO0tnV71yvT8evIXI)sPoUk313SnD18vrGGcujPbaA)feHxf8VyeQkkqzqzz4fNqdFrTr4cgCjqygfRFIsWHxpfqrbHMZlcNZ7T77J(5ge01fLSE(6xGgFzf0spL3HnxD2FLKXTfJPhOYuNOgBa5PAD8E)EBGVOJVWIezr75fQkmrrIW7yBuW)Fof4r3bF0XZQfJsxxY9CWeo(NVkoUCeSYECZbCuRUrzbV9tGeHGsIhPDq1tsrQrUyOQ5nLuuiWE6FiEsLGzb8DB2QUO12i)80kZekhSPaaR3T(i0ZpvH6adH3yhoLnPSeA0VQUKpMv5e8gauDSKoXSgQlhwnu8DQS(elGILOnwfq8zHQF4W(nMX3FARhpHXhfyRA(cJGmbU36IGlM7Y2ttze1W5jPhlUyjMLUyjCq7W)OXRe6CLirVz7uU3MMNX53M6O4zfp72xqDmuyNLYp8ySqxszJzf22JOqk5rb9p(gmvKXFovuAuS7GtoaOLUqmMRhdJqz3gfm)(lfd8xmx6yEN)HqwIADULEB0SW1ewI4asZJf9jENgQl)siv4UE3iAw(npUNKZzLBGp05J6eBpnKQlCbHZaFhIlHvM9R0kE3qinpBWEd7(Sb9M2GsM)YMiNgnUiX9BeoNUbNpYG3(oz)KQcl4vTjKb94xZ6O8T81DDQ9fLKg4Ej3CGT59pUM2)TJiECdnZeNuDuF36BqhB0(C55ZoZWf9sjVBQWNLwOhfhJWya5s6sbgguvIy1r8T)rtV(QPnnVSwtSHCWRicM2muhj)SP)rebajHTDaG2w5avByV3ctyd4L7mRxUgOsI00gAml(jxzQuldwwCWCZCYA7XEGsZlPoM6aBMH0eK(LG4VATIzJMoRwNuOBFyfdPuAg0lgjM5jCMqaP)cXpugHrdYxt9s9JR6KwVLP1E1tYfktVUYm35rdhJkjx2XlP3UQG9gJyMQ9sFPXAG89VQmvHP18dLZEfH4l0N0Cwjwc7fKPBBsR7svYEAKqIuK2)XByP(ANoXxAqCzr0fePQBo8ijzKPLheU63AQJZND6D(OkTH4HeSN4hW)QjESVvxwfAw3pYdZLXoEbRJ1ntp0dGF8N(H38tbRAEf64QwJKL3bV6ocEsEvDZZ8rLfUd(vPtg1REOkkY6Dw5Y89WQtaNqScj0gLuxjbs0jYoWCIM(oS(a7(CMSWRlrX4QRnMCo0vhUjErfhyzYMcfY9CTVFUOdq2A4JQNL8fX3lWZgVse07XpAwZWC9uL643)OPM7WWfkLR6WeBL05jPFqacdgSlL6tCvguvvXRtKMXZ6z3s)OIrgM((6xD4KMGCRfUjoS90uUtB9emHdNMv5z8g(J3ivZsbUPNjfCvbZiRxGBVmqijMhYA2kNzBqS)TpJkBLen9l79MQwuMnWI4A3DCp0G(whguJnMwxhySOAZ4M)gO1mUZPHD4vJfHMH6VVUvJdnzKhLY(SYScZEBWEFylaOY)smahxYToltxmiukH8Er75n5nc6zeQm6y71k19FKQuSpaoN9XhHIMGCfgmp49RObF2dyffGnQ1XGEh0VrcZyq0lUF1dkpmpOnBW3)5UnktIilNGij6k6C0NZBUbIy7A9DUf0Gcpb1zXD7x9X1HGSikZK)L17)51MOiggK9HxCCoHtJok6ggCwbfH206JtkOAKsi3CE1Xnc6Y)gP2yUW7wQt7H5bkHJsP4w2zYJOFDGGX6yNPpWJ2fsoCJTcaxmnVaIYbzua6VDi0GD1XeVaaawuUpCNiLj2OUAaAlYdkk14mVI)KF0uZW4wgdAbmoLPbb6QmzDQPUkQ3555n(iU8vI4CyAB8gbEi5R9hcIANwo8W2XZV(IM4Sh98ELE2FwYReKQDe3Kn)OYL0B3KYMox54C22ldj)tQb3mDA(PlECZUjUH48sIgSChoWx3eR)g8JkNzgLQjhqxOuF70wZnyCU(Z)K(sFd8hoyIkIPJEycNmhoeXfPJZO9cCClDS))nWdMc8(7B46jCs3vOacWeZxGFadMFA7x9mC0xv3W)EP0AlDDM1yF1Wqroi)7WdqJab8U7Bqo(8p5)k3Rk(gDS))3AxlRGWWab)yepiifnGKl(n4fVhqep452)FS7JSz7KSIhepjK2qA7MUD2zM1FBFhAogpXxzp0BmavthP55JTTj9LT5nlkyU4npmz8RRmAqveQfsKIu1sqHEQ25cAK16LXUluO2ewEw5seqW6kJuIm65zvyTEMfQ)PcfOqHlTL)ioeDEM4hMdx6PQnOjGHVM4XEEgPLhsyw(SNsP2im6xIM4qdqBLOND5oe9O1yTozP7uf70yyuctig0TFmdz(xfL5kHbq4hjLdmg2Fd(4mh(znAC3HTHqW2OpGTQdDplmEHV6dqLCzSZLgTVGJvE6GrSx8rYs4KZYYDUstVlg4cr3wwNO2jLSPapj0C27Cbc1J(MXfuUtTcOYTZNsLL1FLp]] )


end