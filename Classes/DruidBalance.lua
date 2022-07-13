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


    spec:RegisterPack( "Balance", 20220713, [[Hekili:S3x2YTnswI(TOyIIMul0KGIY2vyRjSlBF7YtTnL8T75jrbrcAIRjjydaAznHd(TFpl5oYeaKwU6Q7zEOklILezEYZ(wE9WRF)1xnlUm56FjAqu0GNmCu)bpl6jrJU(QY73KC9vBIN(X4pa)X64vW))vXlJxpLU(9lZINHVFr22C8slkl3u89p(X3YpZzfPRM2)dPLl2EB)0ShlE1ZUkD1p84vZ6VOC1Y)95PltEH4f6x(5YRV62TPll)X1xFR3j2WND9vXBlxKLF9v4abF10zZs4hpPyQAgU7MxNVnD2U39UTlVF3nJoD3n4aT7D7E3pSiE9hsk((DV7SD38s4TNT7MRYwgNV7MxLeVQpDD(HG7ugN)HKYjPZ3DZ04IKc4kzWFE)0Ljt47vWVXVNSk7t4BSD96KPjffX5Wh(tX5PX3UeFVUP9t6dZJn5jFAsb8UfBHxF3nNDjFT(QR1JhXx(PmyfG3d(YLPR)WUB(B5XLl2DdoBslFeozwaJWD5z4nFZ0LPBks4x(NJ)iCNFiB9NYW)GEUR2KMNwcVv8UBwMwwUeU2QSC4)pFzYNtVf)DxCSVpB7UBwepB9JkH)nTe)A7Ub2q3USmEDs22ceOExkoxE1V(Y3V7MtGVvcSmltJxcZ8LPFy9QK1LNsZtyru8X0n9mNzRYkGH8rZt)WIYj5jRItxx8i45MMSgazz4KCZg8RGG7BZkGlqpl8VzRxEppuVppjggL3NTcgXmyI)QLXlS))X8YTytYuAQvMNU(JjL87)RBswNKR3AiWRX)EfSJmpnpPhmFJNPGw5jfPltHLhp7sIZHFbdZ0Sv3gxEgUpk(aVn9Z7U5)iD9SCeZ4nR2KDxs(k6nNUiz6hHfvg8I)WRb0McGoZevA3nZqu4(RZMmDwH4fqKTDV7LRxNvcuhWyQW3F5V9tik6AaAHBOzBxd3fHopm0LltlklqY9mcMb)1VqCpGTlaVz21VcimNwMMT(6RUdHEm9yE6g(A)gJeduHkK4yAcYazbPqgm7V69smRFb3VbyyCI4HFvgIQHam5gd8laZo)U0cGbe81ktaYTRVQlSPiigwUfWNMSo5ZWi9LVOVE66jfmrVZvVnd)2MxmE99IbaWd6iiwh2)oEzax4iX1I4RDDjW1kaSPqmXDMTDPbjF76eaFaqdeG(jzZNeVC5KYfa1FrFX4XZUJq8TpbxADz)1ev0CeqjUfGVJVNGbf9vHbA3nVy3ndvpuz8Ye8TJl3cO0tK73Qptp(jnGMeiZp0Ka07l0SNe(va8yVnB92I(LaPu0tNeTzkI0Tobq(V(QXimDunWucbYbO2AWzh)GYonbg3NzFjsqmpgyGQiDuZFcOEli7XC55bjsV6ktroEpN2BakQJbceAWyeW(iP2e(zorDljQN5D7HqV80PL4usnHMIaj(htq6EM6FcRcGG(3Z(r2gy0sk1JJu4h(xl3c)tiW5Le4SJKoqGxI3Fzw(mB8E1nHHcaBZYtNxwbLTMpuKdNPRsqzkVm7nm7NrNWSFY2wImGHbxW8H5jDLyojUy0jwCG(esCqqP0IjXzjiu68hcOeXQdHsEN8GUiXO8I7wKS2K3ijnGeFJZtXaIpw6uujIcus2YKpfJIJi5qKwcc1iesEtiEBZtYjjymKGFFqgXsuQhPpumILyT85jfcbgV3qasfPpmDgWLDvw2AE1G7Rg3OyBGRRfN45omAGZnMVn)EK3qcWdZ416NdlG1GYotMNNS()(E(o3UD(CGeAs66P9f6Tq8dmV(STazykIoHVHC51xGuyVf(xf3fH(Xs9ckyD8i9WIXfz6AswjmFzaEmRBiTHvKwUv85ama8PJv65a8DlNY71BlWDWusbHY7squfCBRWAFBncsWnTlcWS92K8IK8pcmqDwh)FruMxPUlR7bn)sqKgu7S3kaJmE6c4JNWtT4Bj9DUyW3bkDfpVerRuQUkuZml(9c8pfbN8E)WlF8pUEQxrQ1iICAw2Yzz3TU)u(lbIfsMuWQi3F7g1Z1AXiS4aV4hiP7yP0c1Cc(NYf3leAw9QodgoLKxYbZuEVUbUTAE8CuWfiWauY8CsSHEXvKUE(2LtwCFbbdTz66DrbIFgkuMa(Nhl56k2xzHtd7)m6R5W1Eo8)mu0aMid6pKEqwN3zjlJVFYTgyt0JmsQ0adQ1ewk02NeuKz3g3ACvcRzisy4mmOpR(TlHKk20MocRBMyocrJdTqD0ToRusjeljgKCtsliB4GR)BBxwGkOTjpBkRentgsKOZzvTf0IBLg2SEMMWFtg9Vam(P7n)8PjPlj4B3kRZZyW)zM0Jo7q9iKRHpDa9NW(1EoCEiVdm2m9zEC6Sjjizy)4zZac8pJ2(yGIuDMgp7(2Xxr8O9K08bwYxImQbSUnGQHGzEtCwL47QXtNkn8w9vS1Sn83y0a35rDWQgMuiOFqn2M4G1(dXlNUfhisJKeKNokJIi2v8(xNDhIAJYSboU4pirIiYjSIXlZwvYYbJrvAJxbM(wYcCeJZjsAIkY7KRxyMDpibbqUF2EJC3vQAvFuN6jLztMLMO4RqBvoiuOmy42JviDmQCYFFB6MnjG(UR2CpGOSCcOO5A26(oveO5i8qSbw5vT5jDXtilcGHACBz)BALwTFgteB1sPiBlOLyj69Qj5BV9EFRehrZQpI77oz05JF6GHocGo30ov17QfD4qDMhJE0iptQgOVzrVQ2IyPIOTKaVcUvte7x0v25j7XgHlH1E(58RF6jS(awZGn5PRG9vKHsCoydr60jBiHh65Yz8RPauQ9B4RnnFBj(yt(7BHP52vaX1Nsf4WQ5z4NZbtYH0Oyrm8(aZNS8BX1zzMWDAMdU4IWtbFgABD04XJIgAX2xm4Qrgz5bgua25cVckFPJngLZ9Nm6INeDUnYyKG9NdJXlRYe2AdiAGKktVGvs8btWbf3NOuNx7aN6EKrg7nspEwoKbTtKtgEymUTAwUNS8718ekQYSjQ(zt03YzJcG3RQrmcdSinqfcwixZkKOiKKW6ojexnlBlzaxgDPeHzkOjKeQP415xbnjhecaiE8nDu5ceDyjFAgaFwplvQ61Wb7T4j09uaJ0BtxJ445GqZjfjjFmj3MZsvC2ObdALkQS8KZhqBaexg7pdy2n6O7JjKGEgAp79XqTsEknuDBfxrXWg0O6TU7OXRVxHMvi2Qi)RZ7p3fNYHAHCicUB9MTBwKbdhR6S5UJ1cyc(M0EKRFXRAM8BeIp3DZVQKWhnOizAbAC(8mHn8sKncNcNofzk96lL6fHEzeEKnsta8zYTm8DveBBAGuqfffC260w9e1pVjJSQaR2GkmqIF1ouHrHToSrC5rprtfvfqHBSU(JT6g7vSklec0VtQ7CX3(Dvx9KCS6TU91lc7tIonOKMx)L3AeKlQGFyRkEd2hXJqVAuaR1gZxNjs8NrHLwR5(dS1S2uJOY8TtbDskadd(egtGBtWT4Epe(hWszB)2n0gBdUuPfIpchgvOv64zTRvRsE2F5MwQdmdxId6osAgm2qtJb4oOO4CqHRK81OrYaZ)5UXk6iXorWNFY5kFc2QhSty3nfzA33HcSA7gspfxIGqce(T)rP4pqNPH68oUVsvJr9zsm6TUDzw2SLBlkLenc1r6ZEbQ(NTv0PNigTJB2EH2BSWl07KABBcTdPXMAcR7pp8uCKo(YL3fFFHqO3p(F(ABx3ZYbdfWaRau83D1i2n6sse2WefMK(AEDMdSp2Gs6OAgxC64g3ep6iimHfv(7wTMbYGyiOw9BNBJI2jtNdl6UtdkK15a8IIRu49sJa58D)1eq6KagLFwwPmIG9ltNYXmGhx6wwXDq9aIvt9bNaFOAcj7iZPGmALUZbNqaYdARdSe(WXaDoqMrjqe8Db(hpBGJHU(GB(57TNc0B1d2z)LLnAGCQ4gNRg4sDUP6abOuqIr3Obzrm((fOT3K93icn7aAWgXBZqEROLGISpBfLWAuGJvw4dOaLMMrkJvoQ3(mtf3Lm4i7mv(1M(fnqedVi8NflX44GFbuNlm8VCYZyyRkLWt(NcEzQ566JJEHmrloQrpX8W6eQ2gDZUnPmGH492520ES0wd3CHFGjApWvNaZqkNmX9ZziDnO1eNWkhDPFFUznHC1EQfUKvnv9Ot2fnmZoRPP0Z5PUPJX9hiIJQbyAYHi4(R3pHJXN1pxVSrHoIpvTmp7SxFMQrS0rg8hVh(oRRvszDtLAxqcyRNatQjQK0vISWJZwplCKXgOqYNIYmn3NQNTx8(iNDRts0j36emdX(q6)DsBv60vsMpx2cC6bgKaFoXvnYxn1vqE(UrN25HIAnJYOkmk97a9w52BpS6c52IVX8)I(Ze)VO)8X)Z7u6pP8)8oxF45)18NP18)uRnFA85fQwV5f)ZftZ9IV53cMMrels3CCW1g1cP2USoXknob2MRkKQOQ5SIFv6wuol7gHkRb)nP8q(HmkuEzc9FXu4G8aaAAepSOQ0fg(Fc4fyNsYg5TSpZ5fPAPrIllYh3OqLTqLVGX7wuYPWnwlourEujjULBNc8RgYK7MDV2GkwRKO3RzZwksebnCG0yJ1zsZcu7zs7doLuz3kLVYjW(AXOjEJtjHwO1h8otc6ueHzs4FmY00K4CROvAJbgkfXJNnRM1T12PHK3fXf0GJ0oTq7SksUtl6xMTImXEvg6QpK570mHt)G3PO(vIphKw)kjY7kjQMvsiPH2gR91Us8Lo2bxjbggJvwRCoGLxe84srR7xnEwUucMi2cZIxJgphVfGmaCdlGH7Xi(wMmLQsQ4IGgo3F3n7U5kKustDHevNZVfqfGbnEjgKU1j4yPkLSfabXs03yQT8Z9L50ntRJ(bH9UmNdSd6pKvVRsDLC(MP7QeSBUiaiYvJAPAkvGDuuSXSLa(NPImUdrrGVgDRKphVAdUKfCgygi5WBoB7QnKhSKoOuM92yk0JGZ5Z7zIHuGiHeFYkjHBZqGX7neW4dpx9H3)mtveG5HdCuNoyov6f2J4tIQIWm9dFzXVz4ZNIfaE9m2nrywj89CstOk2eJ6NuxOMelxXt13kZqe60exSrL2IYvj6fsqE0eyP4wsrvsGe57ikAVPF7RHoJcJcMnKyvu0SNckS5Tp9ggM7L3LLVEcifoEfMTlMz4IHLvEFqtfRWAczv8Nj8ckR0vQS14RYZtDLwL85KPBlt0LIfnE8KP(sNluH25P65cp12UPn5ClX4414RnnUCkDjw0eNjcCfZKXxa9mT4n4zHBH)qF(j4BobFrqi18dt)NJ8HM1PwpX)eRknai2i3bJrId4Fvu6MZqN4bLTZ(B3P7RakuvUGl)P8jFkTari8Z7W7UHbhCuNlypfNxQcahSck3SeVWTJFIrFe1TLv0Y(WAyPRl2CFQKj3b8yKKVOxPllhoD2aCaGTfj)bTVdzKtS9ioxUzXsOc1PoR48yHMvyU2RnlxNeOT17qgPwiUGFWQjx3WON0OfE16iLb17Xdr252ZWu2UUbrcDlufipipHh52eYRMnq2AEg2czJ82m0kASMzxL005foPJC1y65uMOQpKSMaTyJpuK8adQ4LTg2N9p7c(PoX3QshIoxSY6fXjCGY(nxRxI2LO(HMsW65I33QkIZDD0IODkrS8(Ot4cwxMMGWM)tnws(FfIm25v61gFtpCqdCH65Z6qvWj5qsdC8mByiooTawS5jZbrulyRpAIE55efyNaciTM8NZgy2SiXEIh0FDSCoroyXrGWEvFRkQ0qzzlHR4tZkpPDniutwqVOmTnG8JKvPtzZ2GrJ2h3jYtYLPFcfAo8Co5kzznKuiwod3MouZ0yzRWWo7sIv99fvjpJpeUA5XLSDIgwEvWL1AbBMezW5I4pXtRm1EiA5uoDrh5YEm92ci83OmWa7vjRivUwLXv2GOEyTlEwJugxKX5iCdqVXCebM9xFfBc1zkLsD94mTjxKsjbSYiamfMTsjypHOq0(lQuC0DAXNIqd4zMIXGsB54ntenffeXPEg4DmOhnySQYrfxoUgKx98zKUIGv8ko7n)hjjByfzUsve5iUc9h4YRa77pmUIOOa(P7NgNhlX(OEOtH1(MUqmxMiXnv(wq7euudQBtOAFJC4GuzDMzntFePq2n39AukOElWRv2og1PiPRP5kurZa)Bb8deACy(BvKNvV4VE2yn1WQRZxd31Wkn8KqMNWWMxqEuYVaXLmQYK5ltOChFYhwMUc)0wYezrWFhmoCq0cRurud8Zh7Zjnnqb83eT)ccrcrbPoJbNd7u8aKCMS2OVfr2fvQjNHzKxNu0gmnarHmlJQuzAev5e3Rr3ZDf)(23r5vfMTclxGTyvoOzAlQ4fKH7yBIUOrK3Vvunpaigk8SQMDmYNxYA1oVfphARqZje5M9rfhsIrg7bHBvUovWuu)oisZyz8f8lR1CdRTSbAGeCKbyUo)M0eoGqhvL1tEC7ri2GwSzAaXiYs9TwJSQ)e6ipE9bvBZozDiO2SJJA915JenRbMlK5dhgIxOQrmYdz9KfawGvgxPpUDCIJBHHFQr2N2dnn6TCOPjDGcX9y5EIpKdzuFRzU5Q5SxFiz3u12YnkfUy59q5QCW3P7mYlrJbqtEBXeqSNTDtFgTavVHO9ZXi5qTliYtqY(dKXyEIMNSHF8fxBYDzRlT8EyqNwxuQ68xESNqVcURklSG8Su(JFzMlpRTBywTEHsidTZpr2K6iGdPuyjwBaN7vbTgzFOEa)WgPLP6OE74VV93y6lvSLATX0McWQrLUZBZk6AF1pPC3oEwmSb8jy9DxmgyJ6SPgzeyKc2hPSnXEqMmlEf22fXGLSeLwYRDmvU9)GI1SsjXWpPfNEF4N0tVZO6)OwBXhqBbiJKLyBOquH4tYaXcoGE8FTjROGBCNK1cgEIDKgjeLT()BBrPufnShNjVxYN3GoOWx5nAgoPM9IHRosL(19KDejAJ9jHmcGCca7J(J35ZbJcxK1Z2he9iE2SWMtumRlVd2BXvqf3svr2Mg3KJOOwMLxzeQsy02U1gigpQQ2HkPbH9ZT7R0Xw9J6RyIWfEHycfOhyeq5eA755YDYNAj1R6(Kzr5ECR3E6jPA9fpmLgCH8iNITN)avgyM2Xs9Hg9vwn4Upxfq52VC7zTU8K1WsnwBvEJvDHRGO0G0C6C6WX63Lo36Nv9JVuJ2Ha3lbbO)PKSuQsNX)NvOH2P9ix1WwjfsFvw5Bp1(fryPrpFlLDiOXBI83iP4z2FfJIU2(JbAS8A2CZkoTZFZ6v6Bh8BB7ZWRRR6tHppl8KfY6tkWBZ(fdlOL6EmnEZghlGAjxMRpSQ50IBIBLWfur1MdYs42RtDLlLenfWDlkXQgstF6gQe1l0CJ6X8v9NhRbuA)ez4c6e00)ipM(3qy97zRqu4YXlahAl0GdqcGrycg3GdJ8d5iR1EIIFBnbrX)7FG9EiRK)Xexv2XvdwsOoC98sok9YEG4vBUsScG546WXoWvkMLVxyJL4D9gYz26iaglBi7EdPVSgCfCHKm7mcHpImAegFgFYRPmUtqFiXUzmFlQIb8j3lyxne8VGbR9mEOaPRV37zt50NCMALknSfqg9(em)IZxttVRRReweI8ropU5sISTYWkZ(kkNDnLQyBgRyVTG6AWKhzLDhsUmf9LMg1LncbX63RTSJzQetgYMRyh6PMZyGNETVKDx77aJQ9DpnTXtF(ZVXVs1bzJF1IWneQ6JzYaBv(mZmGq6LrldrsUkufAKHQq6SmuqSFBchntJU9jzjOafGIUjMSrsnr8LA)k1CmfB6xjN3W6lcRW0zjC4k1bDneFMkDTu6jFPWCBaLw4haDUi71mjBnNoApXkT9vx4xGuKI5zpUHKZXuzIWoqWTk116aKmnpJBc5vmrt62y7zDDSWEM0aUw3qG7fM3OrL8e8(9QXcoRAoZBtH65kYnFLeZaF3HOO0Kun1n00M31I2MwqUIxY5TBTQvnUrfNOeKnCjRivi3hnxSjl)FftkrjvKu(U(2uKPxkmFg3dqrc6MpUbtcblbY1Uv0lsK6JBGhjHMkgAO76hfNGPuXzmy3nGcAruThLgvx8VE7QncppxjyHUscj(jLQUMFLdrIafDwJrzOZ(4Egpy(vsfSwRkVkfBaszvBs2g4(yFE6YGM2BGKOkBiY1o3gHu)dckm2wP5A8EUhjg15qDFHEabmbZ)RY9jafOurlkvKmuCoaGhIsMeFY3bUvUzYy3hp9LqFkptthun1NOF9xLQHJqB(dPjnUdlwbYfjQ4d5YwiCMNyYnWkrOL7VcROfQi13sXO2hqdpzAP)8Pu8s18E7lDtrv6gFOWn5NTh4PqtFotsjp1zBDo2m2oZCAK2Y0jU1SDQ0eOTb4VIgpvMESuJq(ayDYDKdy9rqI(20Rt(SSx6TBXVf(ScBN8AUeTFeoHNTZRwb(50f4sQWOZbKNWxBI6a)zSYShZNwfaojLebdC9lWFMMGTw)0X1RTzN9Xdc1QwQghzr8Y5msccfB(iLOTqrEfxNkJslhANKUlv9q()N1(dmal17pUElPkD9FtE4o9dV2mxxZZtZY12TIJ1(NHm1uMeCmoNVmdzs0fJQlUMVFIWsXJfML8yvhH06Pv6IrCkTc3dJNjmi6XCcF1M8crLTW21pKGxNXXcfQWGoqkNmuWOlb0)4EC2(DQfdRtW5wkZyf5eooZvYZd4JprgCkQQKAOUeTwC)QLIhgo3aB)Ugk48wkWDcvwKLF5CozejLNeNeHYy)4WfVoSXo7tS0CnAO(KtTg3instRTh8CQAoSxTGoiNut7D7FDB6)8cks6kck5XowQZwiaYz7ehcFpEFEYirf)kvrXtuABO2bPYdQNKIvvQY1XPSTuNoiKv7)Le5as5icHbc(dzGSpshMFi)v8PNJ0IdStsO5siQeukj2PU2HUR2DpwRfxVF1nSUiwnTstDMXzOiAPFhNCU94XFhaOe1chQOe)vhze8KI8fszJsfYkpVF4WV7OiCfEGvn7DVMlh5ho2j8q6F50cByK8ZuFphusLK89zc5W2IqRDD2GFdO15Iq1Ck40a44R5m1tj)itq9XgD7eFFB)njYvQrUg8Bn5Elyns5I8TgrESMElZC5ttLcV6x1Ca7gYRcgYGj514PiSD(liYJmmhfDK01y55j6ohKAsHMxTPA3SI7VjcG6VXu)ksCUCvHXP60EAM(upJ(nFGsZOZ0jK4SzQ0VKFa02ADmKq9CwKI(lrv4zQzaEoxNUzzkYWN7aOLtPYktM7lYHHWfqOr1CLtdFO91IY62r3ZuBSfbnGzk02KEuzgUNrErs8s7Gre6HSmmrXN9bpzkB4zftvFmmCcD0oD)qIyIuWY9qGg(m0OIjfDr4mUuKeNmEyeZkzEYDQ8JwWDHkIrrIx6M2NLC3u4o1TqdtO6BKZztr9)XpS4r4y1vuhXyRQN)cdNJ7MpxvJda75wcnqDo4yMqac3KOFbrDRD(GhpAq3Q93KEc)tkoCthoabpjtnttlHVm5K1IQtoRS4MHd4EKz)fhhp7jOv4TvaDKpA5ozTGYjU9DWiNDx)R)F7rb)JOhf02guGHVj(tyVhyF8L5r7Xwenb8oKHT)RNlAW)Bj7ZEiUfNM81gYgpfqIfRjCLjumTueofDowiJm5801PfYkBpXmooATs5a54elZRpSAJJ3x7Q3TAeBsObbFUY3Y(zu12)K)ofLP9H92hu86Th6BrFwY07KbRzWE2ucogtfuactY1M81VJ)mb9Ba3qt2abAI1(srlZr6P7AO3yeGqJdGVIsRqkd)vmxcwE9lrhs8EIrHP9BjBi9o4WYyh1FxBEAnZTowemTH9gNco7f7nZS2PUae8KQS2c0CBfyIh2XYrfMPEItELu2q4znr3mmCXzqyf(6cLnMI615InZmQP24iiHG7JZBLF7Al(ctWMUvN4L8SkDN6fQqJwLu26z7QxmvRPftGrvxvPafk)Eks3ET2aU2FRRlaIgJc7kykwH0(e8SYa(bq5MSt27mbiRrPwGdlB21VlG96SUEbzQLDnJWTIfE5tckjQDuyPt6Uke4cpSr(k5K8c21nI7XDoxkCMDZUmuZcQAwXTAYER9V9E6zhsVh0PUTVM3GCTVOonacVxY7DuC)kuzCIWgoa8W5SzIeSr5b2AQbRMvQSEM8CmfFF8sPf6c6HNZUWvX4ormSiOnulPODfGyZ0yQ)Uf0ywpRs0TNjUCxQL1)4qoUSwHz1A4TW3CKms94wQUTnd9fAU7VP6xsQGHzK9UNq0laQo6wdvsOtOZbBgekF59V2a4kyuLv7tcAnwStz8)zdYCXxnK5ao)HdDYI2IucW9bNMMJtjqpQL4rEhGYd6qt2Ly8gk9oQE4LzE3QAry4Vgx1374X5eOgUpXulp7dzlFKU5SZwDBOYo2ice4OtZioWw9vmwWODSbHjgZSLziVaO3twxygsCc4U7M)Ia6Av9uRZuq9jjX5lVFcGgq7ZUoQEA16zX7llWh1kczEYDQ4Jx6PAZp4VWWNvLRv5FWfLj9bdzOZEw2oYCb9ESfuG70iE6hW9FztG1oR0kXSWaru8vcf)RBD9S)gq4nhZ5eoiY8yc1UkqfgODMSFeu1Fc(7h7SoUK)Tn783O3CKHvYSiBGPXRtaAxQxiTgZYqk5AawdVbNg7u5QUA73IsoUyZeCOjqtO6b8aR)rD4dv3Lxplj)uHiPIauO87oxg4RTAAxvsqyFUeU2YOezN8Kdg)RtOYOSW)HfOhgsoVMLPDvMTuDgE4txHPBbpqCcAGBNMStMl6Ntynb3Mw2hpvtsbvruvjkR6Gip1oXYgtBXC2wNa6kGLLKL5JQWr5Pwul9uRJnd11JzQtDtU)zVxDUAXOk8Ql2pvDWIdD1Fv8YeXWmrSaVnDjSEskK2EDx8AHvOitcmrJNzLDXobmuywn9If0jCbhRqPQfWJSYkN7GbetLPj86KIB4bwnFfwLZ3opLYxzoVWQvK0PgSkCeaEGv5NDOJaC8iDdCXll9JTp)MQTw1ONOvf)35TT4)0jdK9MJ8tAs87uYFng87aoW9tMfEDBys8pYkd8GC6C03SAUZIoOL9QxBpPy4QjocpXuglIUO5FE6zVkSwtno23A0Ju1quPt6soct)Qc36qkTGBlOBQO(qWQnKUR8l33W4yAQg88pa9r)s6uzQYNsjzZepzSfVHWM(pUvg9RAbhE0sLNfgPpnoxQKzu40NHCmJcPzLvDQAHH)up1cdTe)CNyEeoqACoDBolTrXONg0XNyose0D)78mbcqXEPYuN2YG(ex47ju(erTgurXdxVS(wg1KkLTLiOikp33PDHujy2puBrKuJ9is7bnnjbP7MIGrYgBTwiSslQIgqfpnYWyX3hiaEtrbGBaWC8DVfpF8iP)5i8gXbvhKues1A03gC(e76OdGsEEY0sCyGbeHawwVAyqHyQyzbeUke72SZci8XqLbwDmMmkcsVn9ykaerGCCQF)kAxcAkVtLWAvouhlRXAzkvPt2u5ku1v3rnEq7sbGvxvKoeBm2ndHpP0RmvaV7jcYXSnXgzWMGy9PN4nsk0zGogohktaD8nqZ93PaNpxnAzqDSPLVC7IQX(PHgzu2yvcI43rFvKXzWbVvTFn1aubP0mjb8PDxNMa68mSfzk5LQCSPTjbAp7i)3gBJAhdrXlWfMzDDE)qPdqrOc6xKpZerI6IgnVmsxl2z3u6nQY1XccSSLzAzOygY3JptR8yiQFwmHIAvlQ0uMQ3JgIpM(PWHJ70vQhXSbJXALqS6XymrFxNSI8V8Zp(T)SppxQ2TBxPdsB6o1nibfcBh)d4xYRgxv1LQATR2GkAoPmNEp0UsqD9VW)ASgTQMYG1HxBtloJ(xGeF1OteWi8(n8)0D(Blbf7QjG(IoJGVwsIF3eyA6G3wtq75Y7x4XHB7QhFFAQtPz)bqxMOTRbb8a4naVTNGktGt4d1YJ31q)ySx45kRsUEeK8rdhxW6cGyToJW3n9Mcqcj2ncKQpXe7uTKhh0)8wc)fdTVeXu9(Tt9hrkD5lIMv3qowwwM15QmlpWuRBGmxrx4OSu6F3TXJQOzsdE2cBe42wDse)v6IQo2jFxGOi3ZzL5OhzyFp9v0dq4KAEFlzS3ldEiRubXa(wQOPZMB6mbSjKtUnnv2hYrObaWN(rudQQ9Kx6KFrAWIWjoo6zjS70KNDD2lCyweOgk5UR)onLTfj0l4wDs(90JfRKqzWv7ioPWBnyFu)EVdnHenz)ppwRg2ZJjdmECtm9oHMMEF9UepGwx31JKInQHviL7345GJB5LFI(4CukxHc)FXer65gil5EdOf9kUsTxGERy1wSsaz)JHAD)bytbNFBOs(IonB6JAbrosHtgs0nVRJ3uSad37CLr9kNQvKcgIW88WG8O78sKtyMofJOyYo5r5DohSvy1oppEvsHtuG)TKCyVI2K33kCWjXR9fENcCksbWQWSs4ipmMjpD8i7zyx8qnCkDOFEk6BrwhqYdpUf(GUUDnR4lKBJP3s03gJD(DiZJDv7DwKQNBaIidZgvvT(mhDpVouXW2A(mTM6U9cRFU2vfnEYZWZedQmDDNxrbntXsm6Io3hcy)WjSlhSvMdJ1uHq8fROasGDjFAWGlZQe9h60XX(N9B6OzWFKT()vdDqdUSQb2YI0bRP(gPuGqO(B5OrYaV1cvCp2qJRa99sVAAq9kZhIaUjfPek7NAHBqQQ9Gr726VaMGFsGEUL4b91Z(v1ok5W4F5Nfp6BX)Ou6wvz7WtgVoZdIUQfBQY0ZGw(3uiD)wBtpUp46X7)CovT(m(66enZDuAkZdGTTDjZBuP4vli7(knJWCo3wHnehvlO4ZLmsQTE5mNlHlDTa(8Au4Ei3)tcDYKNinEn6GOhaSY)W6SA)jgz025KUUAVQefvREB6mZuKOAREBuTNcMP(ZlyDdNju7I5uTOjZ4Utqio67XQ(VKa(HpKmSICwC7EY4WHoeKOXhfNVhJ9iDGJictQNdYAmAhQy9YXbOsEaqO7fIUuHrccl)Hmyjli5WIZuB(e55jfyZ0ZiyIWKJ760Cemb9w)o6lIlp3mwNg9OOi9tOsXAzdVYRxC16qwh2SPINUv3BxFf4RIw0JpxRXsZov52ysif(eI5BtMn8CTJ9Q1ZbpXhFjNtvM2hvVN4W9igSJUmpdr3SgiRAXOY73RI5cUoS3LcwTt7XFQJBKZBdmd5zU7l2jGZBzTUCdnKhotmrVXbzLrdxSABQYGrIDgd4CQYRzYrD7nyUCUBiCM9a1BQGBb2BJblbZE0OObJhmKyUImakU(Q)2l)9F5h)L)pF)UBWsZgzcbchZL(84rzBqbKpANX5dArgsjfVTmdDXYmkyyR)qsr)DV7NOmhn67z(qj50TFKM25)6rmqX8ssYg4wDh(5EQrz0x5OS7DnS0MLmpE7YY9BTDH9S6Q0v)a8w3VUe9)73XZRFAlWBFwkhIkataSynUKI8ZJ75SiV4GxKrgJYto4rXCU80V(Lwu4H7aNup7GhLr1mkLGSTpMu2FOEuKxQKVM1sj0Rh551JQ(6dhCWlctqXWHpmdZdd55WZFygMdNcWAyoCsGO6gMwGOmUnVFnykwlJdNOjQUHPflJANgTyzmUDmDXQwjB1TX7jBxxHbTybzs)7IR2I1ZOhcwzOtREZV(tTxMuCwY(byEy4j8WWs4GhfxWuG9C2hV6DmXVF4vG4PHLq7iv0uS4QSzBxIngddPIF3Fic8)ANuhoZZA0F4ahLN9WQfIR0Udz8(wi2B8dZW8WGo9vi2XI()W1ZXC2e9aVLfD(x)4fvZ4ThltRP1HV3znmpmeVrpW0DJoyCHacdg(1p)g1ozWsZNF0Eji(bdPTX5xXEQ70blwU7tEqKMoSgfXoSr5GPC8JB9vyFw03ardh8Q7HYIOhiE6p08GRB8o0P1dJyyxMDhYQB0dcZZA5zEOdZdaRnRv3HZkXscZHV3znmho5M1W81Qc1U39JexE8LVqgddSw8lkrw50zw0uSxofrvn38umn)(3(3m6WMVoFB6SDVdV272IrKA0Pi9Bueo44v)bwWW3Z)6mSC9NrBOSpSFvs8Q(Q7XpmCxUKSNGXMAACHShby1NP0V1VNGhFbZWMpY6KPjffXyQQkJZm8UDt7N0)uU2Mnps5o7sr9oRUwp9O(YpLbRm8(tLDth5PHcvUSpIIogmk3LNz0QD0dWpt5jlU9KPsywr7mNce3Y0YsmL44WLnFzYN5uKRRQwWxeZz33IurUTvKIN3aXRtY2wSu17vE1VITJ8tGVLUVP)szRZ4uAUIIS)y6MEUZo(Oq4rwj9dGEumfqvYtZWj6MnQk9KYgz6zl4aqQhU3NNGY5EpPxaMOmVAz8c7)FmVSrukAkkD(HAm(vYT)6TlcCB8VYyQ2dZb5zkixEsr6Y0ezxXal3QuCyyx(CgU3A8rEB6N9Ngq7KL)1CkRHEnMpqyzV5GMbmCquESJtnf7apCRqSVeD)LRxNvYQePOrE5V9tiAmqyHPP58STYwl)IYYnfF)JFSiVspd2EN2)dWE62B7NM9yXaCgY77XRM1Fr5QL)7in4lKjIA5NlXpmt3w0x5NRxit6arO4G5MqRo7sbTira0giXLWkrfGyLCOXPmIsSpva7ad3PpheqmHCk9VxlgnXBCkLCmPYJwlotxfvNd(hJ4BYT(zmZyRo)p5fpworpfdV0lYwpbg5jIPYPuKmFXGd4nZ28I4zZedWWttN)cTx9wexqplgXVo6lRcnPSH905i9ntl6d6atnjSvWePmhds4u6V2YZTV2jzK5KmY)KmQUjzuRMKmcI5(nV5WTEkHM(Pt5YGCwszYucjpUWatHrCKVFF0uIRqmmnshIRDo)wI6rKY8U1jKrfsodGuGzlPuf4Re2Doc7ArXE8LVOEOKvBUh4LTCsw(S1irMX9W01Czsjkmys(2BVNGACnZZC31Iw4ITyoNi2uQxmvCsErG7B6s3k5ZXR2GWfbvft8HwDPkfE3waiAOybLBH9Ad0ru3hc4XObh3D4zyh64yFLJD7gX5MJ44ghrfiIAErCGSJxbmblzbfucYRKsA2TbWMG03ZvjMkTpQE0Gi5QiEQwHZy0JeuqMtgo4yTYsvoFf8pSy(g9rSWOZYx5)jOGTFk2DJa5fVy4aeJSRm)f0T1EalZjJSTUcYSuFbzgP0JK6S7MFJ1rH47k0rHp(sSqjrY0REVKr)VWvY9BXm5GEy(qnbXk15UKofeuRno28Qf2d5QPJO3ZqJCNJOFfX)YZ3xM9vky7yAY09i9MO32P(x(YrvZMf4I(pQGFXq4w1xgi9(Yx6wnnISwWeKPnGGEDoYB6a5F5tBSoR)gw9DQU27eALhCYWQ68gojNauhXP9Pm31siljqmjsM)NItxIaknL5lyW0TGU)QRblju4Iz(Li4VtR4tbzvPtlfISHp0Z7gDSvoxHuaucxDIBvgPUJj3Oxkt)p8KwsXEzg33oI1DxtDHTXjJ2j(OkQWGjTysCwIG3IF47Ld709OaLqWx(sDLXbGWfyiJmwGYdspw0IMMMueLSOiY8KTZifJYbEFFI6YCZvLGKkDbjdbsi7IMNKtkrZql(9XZm1erwir8KQdeXtXWqjy(E5qAjP7mE11aYfNouFa7fR4eiMnHJvdvx6u3XTH8yLQkagC5urYtsnEVusx9Y7sqqhUmkQzDSEc8bflcYctS0mhQo56(YxmUOORZAFnjLCLRI7Pwx0Qmw474MAAF5lEYqXxyEnPgIF5l66PLqxjinLbAVsLeE7QPgiymlrsUjk(EeJ7IbFhEoBXn4mLKD5zRr87fymM53Mzpe1asRtgqbVDVCUB4aUaEIgyk2RJhy2Ldh35i3K77lFX9kDStTZobsxWoDRljUF(lggD25gQF4KH2E3uF(qq20WVZivdFE3H9F2zoSoOwqUK1XXGMANXgWolzz89t0qy4wJ6bcG0ifeInRGH(eumwTpjifLvSRBthczDyzSiPVH7bPaGiySFVjd)lAVoWoIP4D)aPqG4Hpl0EdWpfDTrhlVG88OX(HfEprEfDxgfYEn9UkrowZkSXSMIPGPyOtSyCorcPBGfKDb9kyfHffE3UwRPZgo(SaP8BVVB4th07YgFjpuywJqNJYJtNnjbPo6dgIv0p5ZO3e709iVhZlnr(spupKSZ70(YumV23KH7hZMynV)YxQrB(oHgVrdm)wHxT18HpB4aV6ykzVkeor0FcmaYttITE5PrOOhMr4vZY2ER8CKCRQQ3q2)KJReVUOZGH)3mwRS1vP4WUBzyejJ2QGanQBzLUJjqhcaxNT501xog2(72nSL0D66LFQUUbTFCnL7fp5KUJdZDe1AU2HHrHcAgFh)YvudP7Zpz05JF6GHg8HphTbWFkSZ4460D3qcI6B1tRjO3MGIhPoQpM9lONsNudaZe9SLdOpfiozyKX3iyDhC2Wiyb2cVW0P1nXdeCRhXIfXWBbKHz53snfGmYHU6HtCb4jGbMa6JgpEuKAhKSGtoAulfa9S5e4rtx2rVV6CNjJU4jrNRrdIaYElgbx6YKrb4Ig0Jwck5l2oXcn6m0TgbWsT7hjOXe53bmBOQxlBfdREH)Gr6VxuWVx0d33dan9C05FRlttQOpm8tjYnK8gpZceB0TeFtY(fQVeSDZImy4ekNeKbOvHwpbhhbBWJQVuTD35JgmiGsfN098bNXf1w1I6(4OEcTy8CZlh90Z6gKMgEvT(7VrWeC3n)QGliguoURokDOOHICKifeuP7C40PmcPOc3yU1DMbV2cyaqX9Y0YKvmaTc7yu5UacFbkOoTr2l(CAsNQBz1bchCsnGWrvv)17U4ONOb1xXchi0TFh9j8nx8pc4SRmksh6qW5lQAytNaIaR4SOwTbDHX(JTYPb1K75x0ZJyUAu3pKkCp)IMmeyaQnHP8ikmiz5ftWCjyDcyu0YL92xRfQlgcDAwlhGLrfKVoh1cPMgq0AfBk)k(N(dQb1AAmaAa5QZZXizSg1Ig49oNiL7EebMc(mtoNSaVfpKxBWrGs39D91gOgZS8LMNf4)4)5RD8eb3JCd5)JWEe6Vxvn6hCZzFXWX9bHjJ6p(y65mpTn6bcz6p(m)3Rrm)tG394W6d1w1HEbUvO1rl0EFNwGA8hnTyyAHWiuiXGM81edWRxeyzhcfxrX03UZT5dfMG0V(Uby5dkS5J5ENAeG2X1wM))T31)VTvoo()wcgKh8ZoXJ9Z2njajb4UTTyWE3S3IDgC)4M6M406DDId8ZzYvGf9V9tKuuIsIsVxs7mthGflW2P1VVONKif5h(HKz8LP(LCcbmEEoNoaM7xxbfXhl4PCNROAa(pgaZL9N8XSrffmv8ZbWMNrVig6w)BkcPuj2czcYKS4fD5fNnryWB83CQmApv83JlQN(urkKMnP6Gq4mvLVMpXsxamFKjw9aHGbacZyF(73UdRczpTmOGbsLehDQc4dRayf0nsZG0l0a4FJyNcOAUblcqBWMKfGy)nskMeXNHCdbfXT2JGNzlZ(IPbY4HUTCWftLmUi2pPxQNEDH2CruLXtbkaBY5cUVapNRCChjJ6w9JKukdQ5bSB00fxQ4KQ7nlpqmlIcQWHF5RY(spUWB88PlQvbM6GCi5790vFAVodEsfgex2hRQZQbPexLsWGWnipiQK1OQlp3BS441mhLa2lSxL2SQwAFUCHDnvTo(C5IA2V4oQMozmiysb4g6HGFtrb)gjFWIf8lGQsKOCQVpFDKTB(Dr2wJrA)6kBR8g)Tx2wzq8vs2U8tUdz7QbjNRNmROBm33oka6PgGxIcaYE8w2gfYsgNDcOcbNHfAAlWNWBwt33h2c8hy)wo4E7TUrUfmBbVxIG9YN0UWcRczMpqGejRxsIwFh3F7El9WuJyjo4WIw41l3Fn(pbtVmAuIINp34W37R(Qbm7ySzWCrOhWyz66k4jDf8Gm2gFR1pyVgaTA6LvNxPcd252cF9OjJNYa9v6YJjdKS0mbpJQb55PLgBUeu1k)l3y(A2jEzvZf(33Udms1LJbgrWak4bZ8rv5l5eFk4dyJ13NLdm(1XeYtJ1xGlqNCCNLy5HnJIyYwvF0SlViL2QG3TypLrOaAUpQPKnr21XIHnnY5z7CKIwkIrj50VPhT6E9DgEcgO3RF3vHWvhhEHPnNOQNl7bZt0pwDAtneY2bsNvp)IK5KLTpuYL5sQ1DVzD96yKG0gzl0GdeOjtTK1CcYXXymU31LOOBz64fhpjWujLzxT3L6JB0IipWQdwD1ugeq)OCV7sQWUuQYQUtOhchrzqNGwYu)rBZoNcyYfNYWtOEP4wy3LwRB990jzKMebS6NiODi1DpyeSxD36RPZCnkCX3ghXKnR)fqF605uywiLaO6bsbGT6dY8ACjNSnHy4QuieHlA6CmHvAPZSPhl9DSMRz5Wj7yor8XL)cnS2(zFN3NRGHLvzBrY6OGeAJoLFGO9Mvs058zvjQ0DZ4ZR6ujEDLgXoMFCGy(i7tm4qsZcIzty4PX0szp71PUoyhZjflLwGvFZwP73hpDHXH1SSCbKNbhBprp2cD87aBdPuigJ8MsVVMw15d7C4DAePCgqWfZ2YC01BGSqfcIFASEf3Qnnh(FTA1d05z(gciSZe)pGHfeUcBtw3YoO)7pD9YDl596Rt58JNqEyPQMSlLt2gVnPWbPVFfYwnmdCwfvvRHRQXlAfVN2oCHzFvn0UPMbP0kF(dxhqpECpwgso7oXrBsSAG(DD(Sa9WA6BR9ROzLAQEEcK6hjDsgg3F5fZdvEVHwyV62nRWimF1h2S(oZlWmqnJ)dpC(Il1pLQrv6EbjKQ2PkPqtBXoLeqd6ZIytAXsDXNqXCKBfUTEIoPGTQOJprxinEnKoy)eD)H)IlZFwJ0uW2KZxZT5x4HU1B5mkquyNxXnEf218LVL85TUzwPdnPBMyXjqQdNT86ca55)Pthbkkt(T9Ex20zvl4VhyDDbNjMzoBRWCAh(SLBZ8mg1HmUiLF5qIxUIRKPI)wbW85fr1ZAFb94wWers1nUWCR6rIf7eXEvwXCUtFKm2fIhGFznyXVLA1dyjDg6vgy)BfwZ9LIf0vix6w4FMJYjUe6Vi)zF1tBVFFS36bbX6umv)0YiOHtg3ud)y(LB8dbyFE9X6REdNjzY(WINGyEgAhVQ9C64XGdfvgpoCrYXma4szFVsJz9lRpLkpNva2LesB2gla)4duUvPU1bKUNpItGVwBv6(X73dnfS5fpVMqiqITKM4M7h13RuDGhzQiWh6VJgxoR3oAaABZCi)8UgR(fjBdp2ZelKG(FaSpcBRA8uoOw1QqfnUTLsO3ph1xJqlOeGumZVsaAB)hpcYM05QqcNX)2Q)VhwVlX9GW(VRMxchWrM(aRbSD0YE)x)R89byCSySEPZof850zu)n2xNF0gMCkyRCGAPmiZyQl1LorkWb)Fbq4iCqtbGlo172U)ThfEJqDlxK3qPTdgyYgLR2g(weSXl8LzuS(AYGLeF40RseSX3PfI74LrMgbAlGsJp2NAQ2GbtNpsZuwZJByZqfaxE8H6A2DT6dhmDKvZ3(NmBcGrsR3ZVa16EjgkXUpwx98RQg498PGa)bHMmjPVvasAHxwVyeso6KOMTf6jjPz678bdo9yniRE8bGaOdlo1bmZibC4C52ImXG95bT6BU6GoD9Ow11g4dA6Kog0brTIJ2lzBwNrtj(dOUsn4zA9cvNU23U9ViCUGpMJ7z1rsnMVAs9pD8aiS0JnELnYrMxlIeZvSPtYxlLJ9lzgHEgDOZJilBj3UX4k11RWf(q8e7mtqKxEAGavnLz0P1Ao40e5Gt2GFuxMRyQbe9LkoBbWAHQdSAF7gBkprh3rTRUNPSIWyohOvfIUqKSaSLv(YDGDVqF5RNdQZBEvL6g2WC31XDvR8gFELiAjCtz1(nz9apoKjoOQx6QLuslfJhb6bAVa9w7XNCMT7x08QAD(kmoxg463znEr8xQ5zVC394JU4xyq(v47iKHQ2cnB3oTt9NoeXeojzLDrNOXJSd6vIh)Ju3m1JP1HtB8Qmc6xF(TK5cmZPH2aI8Q0gSCRzxZeMD5RBl2DLVFfbKUifGjtGPjeeyDieOzoCiGoNDAxvqklMjGNgFg4JxQ0t64j8zL(G(ipA7nK5VMlD9nRiySdBoHAYCjzlnEL)hwRVn7HqVtIpzuQChRSrr2q5pNSprCK9VTJgg05nlYe9q4yL8on4PIR)8HvxVBluNlISn7YM6oYp(ZoEqH0Jpl)WZZ0NAfJ2CKGsjZHmkos4uYKii8Mcj9vhjkgyfxhzswgP9lNnrhv3mbDZVhDPuNuqNVLpBW)ZyKd2SJAo5W(vqNLVcBiKBTsPeaufqpeNr1AJQfqXpI(0NnHK4O2omc4vc8XX6ErbQ9UAFIQrIYHPc3N6ikg9WeNO9vIOg3lZGSbxBiMv(YzKdJDARodgMZlI6JY38VbFvl6cKMyFdZJVubm3s6YZy9iIkxmq5Wmy7R9Em)0ojfNCDg2B8B8sdLm(3(FxzB(xWuc9I87f99PBhoWXcwDhBn3QMuGssGgCfrjqL9aFUiQpetYbivL1UU(S)SvU)mERtxor(IFrD9GPnRreGu3d7LuWd7yplGmq2P5EWrKCVyHPgIwGCc1f8gzMR)hhTJI71Y(ATIobDKCpbQXbFegHTx0uTBf9FJ)Y5la2JA)Tz1olQIFRUgg7VUV2omMyr2I0tj3vYAjrQzAB28S)i1GjJUQf9TIKSys93(tv8Mzx3x9p96u2Ee2bhlWH1TYWJ64pKv6qurZaL2E0Ghn1kAyRBDnqhi9oiCrWFd(H5bhOea)Rf5(UJPMz4CfdAw5sC28r3Uz72DdSdHRWlEOXAYdBMuB)n3X74ykaUoAtfoUoConf))eEAI3nmiB1fNA9weHr75qCP38wki)4jI2QjjJiUIIexzGmlN67lEH9ad0C(WnRaVmcfZcTyx5qTEcgt5nLrtBrjmS6EgCEe2WyXqYwHIdkVxnhpyY4MHdYae8XtRpS0V1mz00aaUlqX3PJxuxpcRRRLuqieOPpzTtNylVGAlTxs1YZCKUsiD59z63Nqo8LBJwX6nktpBrs3Y1zqOWPK6(0C)9sppZsqtgxQQlsipBK4C2FfSVt5(0qxxyerIseDAQw8TEq6SGkVAthQDyPgiU6E2rBDn6)73RnqYm0uEFyftdp4rz2LzddUtP3wRWOwZ3w1tqmsSFhutCPEXtcmVAzzXTUlgVxXXg4rmqjJpmUH2GjJrR39c4NYfbw63fpEhZjaSvBKRIYDJVE9H)DQm)tb0glmM3CJJHa0faH8Mb)JoZ8JRb)FCeZLf4Fh0bcw)WM1Cj55oi9rGxbhmy3Jj5RRmZxdIycVfX(NdBAoC6PQpr3l(p73cfdKMVqeIBRAjDrWddUgkk7LJTVLUa0CAdT562vp54OJD)gsyzBi(JjyWEk)zEY9tGDoixMj2byzjlDX2lHahvyUr7(l6b7a6evU(YBaJNlkpRpUA5gp(E5UaNDP1FLyFqHRXoy4DaTcGHI5MqkOwechOuPR67fezeY)k)nyjj78jF)SjdsRi51wOcSLJ2PtgHCVts5alSceXdqs5gWriAzh2sklqjWZlCagemb3EmqhY(pZ0CNOf0tMN82Ngl3in6FNwmLtlMUZkMF7t9LUWr4FNRjDNRj7vyDPJlEbYHWWXAgYElmE(awXqqF767x3YzOYQGuK0zdcbGymO1HcJbh93bNBhCWGUtvYlT64P6JEXeFmSC0VoPO97n1UUp7Ikzu6xwsxYGlKHtX1riAc2VMrxwNOvdk20qi)lsKxLko6XILVRtLb)WT5TLpdW1MHWMPb4t1pJcmsdGx9aEUfHhyyetcTdT0gr9(jWG(kEFztVfVH4bMdoStQkxWGr0QF(vLiN6JOypeehkJd0ZMmux)ILQ4mFb4ApjSEymBPLTRdQfoM)Iz6DfQU4tOjfs(hUYLag)nRpxEsO8r0e1qIusPRg9fGkH81S)qwkyvM1gefVOasesMY4I1DezvBtBSkMp1RSuth86PLjAvjmeGiyMpmT9g9i6DuKpB8YmN0AvLqN1ErQe2l5ASe7kMwF8hwSJ)1cSUSubJJpC82Os97aZkdr6Gv8kggy27Xw0029ohEqayWysa)tRB9eSLE5DUKAFrxzFp8QQ(hxL(Cr(V5QoSQHu)HTHkmFkKOAc2e)xD5lQdNtbfsgHYc2wtGJppTrFZL4QBPDj2)S4Ue314ojszoTUQdkbpTXdAFWdskVfRjVqEM(h3pQU4a03iFAVQxFA8w7DWjvPT7RiBpxg1mbCCwNouicW53nGK2jncF0ipS6(GObGAr)87(bMhnfveC)wN(2RGMS4NUY81WnBG40TTqDBv6IY6DWQNXsGnqTE0ihBmodA(tUZyJR)GLQqpONOHw)vnimfMoHTbrwT9YPkqYfq1pExcxlkFQHcE9)rm9SNnFPX30T5PlDw(kYmK4tqUgb7xGjYpa7I4QqsyKL3VZwj)0OYwrcnIdX)aWNrQLjrMDHy3i7dDGZBmANsckAKVE9kJifMsL3dHEhJFOrI9nyClDCqYnFwwaBz7dxbVlTKV7SjhpOHRNRHS8gnz(4MHXUuvNYj4ayT(Ex(Te2j9SOsbFKpz(Nx5xI9T0L)tw(jRxX8R0IG5yUJZAT8fmN8(92ePmj9F4EFXhm)Xp3C6NFh02XSOCbMa8NEDlhaP3dTAVv2uocGBfwj49ZS(W9(SSZ(jcFTFejmX7XM8uR5hxFn0fzbvLotXh)5)8OcRybme21tepq2HyRYKKbjkQeGUXBe0YSaP3n2I7vo3hPuqPJKEpOYQ6ekQubJ)mTsUQ033IvD1YPrGYjOAQda6(ROdVk6FH1QQQrzq)cXl2Ig(IQJW9OZLa4mQMaf9HiEDKbf9aBUaiox0z53hD0nc11Z7Z45RFgA8LLrlDKFhUG15(vsj3geup4mtBKACiYtj749Hf3GqL9FHzjY5nN0ZZcZKLiYs2gH()ZjdpA3hspErYy03XLErhmJN)LtJJZgbJShxVh71QRnMW7(eiviOM4rwpud0uKRNlgF286(KviWC63L2QsWWa((1Bmx0kh0ppTKBr5GrfaB9UjKIEHXk0ImeEJTyB2KctiFaR5sURO5eWBaO1Xv0kMZsDDC1q135c7tQckrK2ePaXNvs)H97wZ9V)8MpEKqokYy1YzgbzdCNjgHun3znhNZkQHlYUFS3zlX88zlHNBhHlnb5qNphj6mCN6f30Yco)6KifplaTBEbjYqplTuH4JjWUKchZsSUhrykfSd63)kmvIXF(JOS0y3ZNCGrlTXKm32hgH8Unbn)UZfd8x4lDSS0)qulXmo3qVnQz4Y4sKIiTem6Jcwnmx(zqSW9fVr0U8RFChPNZP3aFOlg1QwFAOJUWbe2e89uUegzUVsN6DEJ0IIO9gx(zJkoTr5m)zts8AK9rs64iSoDn2GKb3996(PJkCSx1frg0LFROJX5Y302AMxmAAG7L8ZbMM394kA(31J4Xj0cTCsZs9TRUg9SX60vGt7cdxSdLY(PcFwwLEeqgXGa5J6spmmOQpQvhjN(hn7YlMnzYlR2eZBhcYIGztgAHYVy8FuPaqwEBhXOTLEw1gx8TWi2aU5o35MlZvsCpnVhZrGYLCQAXKzXZZnEL1vK9GdnpJkzQdCHgYUHmmhe)fNvmRT7ZQTrf6MhwkOkLva90rQHEcBkeq8Vqcevqz0GYjvVwb5QoR1BfQTxDeDH(DUUXm3fjDhJknx2XlPZYQG7gteMQdIFjBnq5cyvH0W0z(HXzVEr5l0N0swj2hXliu3UOw3MlN9SuHe3r6(hVwe7RT2iFzzXLJsxauvxV)rsZO4uEq5AyTPonG25N5ts1gsgsXEIVh)RmGSVZMxfwr37K4CX2XRyDSTA6HEa8d)43)2FmAultrhF6AKn)oKP3r0tkiTBEMpQI8DimnDkC8AaTIsSExKVmFlm6uikKitcDWK6ZjqAFIUdmhz3FhNGGTFUqy4T5OyA61MUDo2vhPjEjzhy)0nfRK75AF)cvhGCjXhLqlLZIVxGNnb5iyWJF08jdlvuvQtF)JMX3blfQfS64iBL15jTFqHddm5LY9jUSaTQQKjkYKXZ7y2Y(OsPgM9(6(4WPtIcUw8K4WMJZ5oTZtWmoCYJYxjR4pb9un3oW1D0QGR6rtY6f42RGfsQbISwmYf2gK6F7Zi1wjvt)8UG2QffAdmlU2ER0dnOW1HGASMRDDGXIMjJR)NWPMPLonSeVYweYD1)WZwzhAkOpkN9z9Zkm3TbZ9X1aGQWlHzoUMBDoHUuwO0NT3N3CYKYgb9mGkJw2EJ54(7Ouf7JGZz39iK1eKRWG5bFyj15ZEatPaSsTogo3b9BKingGEX9lFW4H5ERzdH(p3U2ysez5eGKOpRZrFoV(AaX2v27CdCck8emRf3UB5DRIzzrsOj)RR29tRyueJbzF4Phws50OdsUHbVQhzH2S6dZQOAKrj3cz6XnckZ)SwBmy4Txzd7b)a1isPgULTCGedteeeRJTCHGhTlKC4gRfaEmnpfq5Gmka93oMBW(ezsMbaGiQ0hUJ0cfBsznaTf5bZo10qVI)uiAQfeC7NaApeC63jiqzLPOtn1vjfpVaVXhj1VsBohM3gVrGhsHN(dGO2A1dpSz8IlpDsA0JEEVYa7p7ZRe0QDG0KTqu5Y6TBwDtNyCCUy9LH0)PvHBMnRC7fpTA3KwrCEjObRxIdcpBsuGd(bJZmJYvLdOluRWD6s6geNR)YpAV03c)h7zur4s6bdNSKpePzPJ3O9E44wES))vWdME493VHJN4wDxpvqaMy(c8dyWIJB(QhHJUs7g53lfwBTRJhJDLed9Yb5)aUaYkeW7URo54ZFL)RCXQ43HL9VlU6yCD8r2QfhJO0MoxspFKxnPmSnRXScgdEZsxE8B)YGlIrOMyrAmxTiuOhZTUapBTw5O3vCMAdy55cxcbcwsyKAGk9CRnZALul0(xyOajoCz75pujI(KwGGycCPhZ1bncmCJHhhIVr4ZlMXS4tVPPXFfo(xgxfh8aABz6zITd52APNStoZD4SDshgLSgehL4(5ziZxRGYCoGbqwNKojtLHTFWhFck(5604IBlGrWURUoUxDy1zflVGZ(rqLSqV0LMtVGGvE2log7fPKmjojQz5IYstAzmqiIggwNC9tksPa(sG3zAPlGOEuPkxWFFV5)93))p]] )


end