-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

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


    spec:RegisterPack( "Balance", 20220820, [[Hekili:S33A3joswc(BXN5uKGXgdcJtN1X2ZjFUtxtvvwB5C7A)KXYGWOnbjAjHD654d)234EVXBfHKat2D19mFOQ0OhHI4g33VIBgCZxU56PHfr38Rb9dc6FEWGEdoR)Bo98BUU4Pvr3C9QWjFn8E2FKeUK9)Fx4IWKj41FArA4u49ZtxNbxAErXQ8F8KtUJEMJZJxoP39XfZxFxV40t4V6XxhV89NSCAV5flx8VplEr0L8xOxX3kU567whVO4VKCZDUNyNEZ1HRlMNMDZ1WaX(QXtNgrpEu(e5mCZTFiBD80n)0BxF)68In3g0)i4)feS5N28tVFEyY9r5)4MF64n3(w2amDZTxNUimBZTVlkCzp860dXUtry29rfJJNT52jH5r5SRKY(ZNMSiAmDVC6n(9OLPpaVX6KKOjr55HzpT52hcZIdVBb8ETJ7f1JnpwLf9W4C27MVM96BU94ROR1tETo0i(2hszlc4ESVCrCY9BU9pYclMV5wy2ex8kyYmNncpMLc38JtweVkpIE5Fj8RS78(0KhsH)aFURxfNfxWERWn3UiUOyb7AltZy))zlI(w8DWVBdJ9tPR3C78WPjVIb8MhxaFTn3Y2txVOimjkDD(c2A7XyyU8Up)2VS52USVveBzwehUGnZxeFFYYOKIJW5jBrK)14vD0NzltHnMxnl((5fJZIwggNK)k2ZnjkHbYsHj5QvWxba33LMZUa(SS)nnzXt0q9LSOq2O8L0LSrmLnXF3IW5M))qA5MVkAco1kYIt(Aub9(FEvusuMARbbVA)71SDKzXzrDyZ3WPsOvwuE8Iy2YJMDrHzSFXgMjPlVlS4yyFK)b(u832C7)zCY0maZ4JlxL(yu2s8nNmpAYxzlQu2l((pWqBYzKA6OsBUDkGf3ljD8KP58xaq2y41jjPfmce2ykr5F7V9ZakAcdAbBOPRty3fGo7hsZfX5f5afFkcZy)1VImqyBxm8MP38ogT5KI40KBU(ra6rKKzXROR9BesmJkuIehItqciZjfszZ(R)IaZ6xH9BgmmmI)WVlfq1aaMyJH9lgMD2JX5mEqSVwreJC7MRBZ2u4edlwZWNgNe9n2i98ZQRhNmoNi6TU6DPW3w)IHjpXhagEqloX6GEpsld2foGFTa6A3uWyC5b2KZN4wZ224GKTojIHpWqd4G(XPZghUyX4I5mQ)8E8XJMDha4BpWUusrVeKkAgaO43IHVdVhNbf(vzd0MBVCZTdKpur4Ii4TdlwZqPhl2VLFMo0tQbnrqMBOjcO3wOzhb8lNXJ9U0K159kyKsbNpoy1eaPljIH8FZ1Jay6WkGPicKfqTXGZwUbLTQdmUnZ(cGGywiJbQK0ro)rG6Dmzp6lphirQvxrmWX7cCVHrrDiJabhmcbShqQnMEMUYBjq90VBha6LfpPaMsYj0eair)ymq3tu)JjTa40)o2psxXgTOc14ie(b)1I1S)Xh48keC2sqhWXlH7VinBQjEV8MSHIb2MMfpROekBfFOalotxhbYuEB6hj2pd7sSFsxxamGzdoN5dXt6A(CIFXGUgCGEaioqOuC(4W0iakD6(akHS6aOKZjptxKqqEXJZJs05nIsdqX3W8KpGWJfpbuIihKKTi6HqqCekhc1sGRgbxYBeYBBwugkbJGe07ZKrSaK6H6dfcyjglFAsbqGrBneavr6(jtzCzxMMMqRgyFv7g5R9CDL4eh3HqdSUXS1zpb8gIy8W0ETEzSfqctzNXZYIs(VEIUZDRNnJrcnoozspUEli)a9RpDnJmmgqNG3qS86Xrkm3c)R87cq)qHEb5KoEOEyHWImobLvYMVeapK0ne3WYJlwZ)Cmma4PdL65W47wmH2RxNd7GXOccfpgbOkW2wUX(wcasGnTZ8WS9UOS8OSVYyGATo()aOmVtExs3dC(fbinG2zFIdgj805SpEen1cVd135S()atPRWzfaALu1vUAMPHFHJ)jj4e379V9K)sYeNIuRqe5K00fttFmP3e6lXelenoNurU36vYNRXIriXboXpas3rcPfY5e7FkM)exOz5RAnyWusCjlmtX9A752Y5XfGGlMadMsMNIInulU84KzRxmE(t5im0KPRZfft8ZaUYeS)5ebxx((kjCAqV3GFnlU2Zy)pnfnytK(9gGpiPZ70OfHpn(onSj8rgkuAGa1kcljA7R9kYSDTBn2kHvpeXpCMnOVP6TlUKkY0MwCRBgRpcbJ8TqT0ToTqqjekigeCtIZrB4yx)3wVihuqBvw6esjAImejrNrQAZPfxlmSjzQIWFvk(Vmy85Bn)8jrXlq4B7sRZJjW)X60Jw7qDqKRbN3h)t2(1woCoiV9m2e9zwy80XrazyVWPtze4FdS9rdfP8mnC6tnJVc)r7iO59SKVcyuZW6wXunKzM3yRvj8Uk80jcdVLFftnB9)ng23EEufSQMjfa67xHTjwyTVpCXK1WaHAKeb80bzuiXUK3Fs6JaQniZMXXf(bkseqozRy4YKvLKCWqqL2WLmtFlibo8XPRGMOK8oX6LnZEIjbHHC)MTg5UTq1QEGo1JlshpnosYxb3QSqOazWSBpsI01Us5c89gf3qleUSqWi9SuaC0PSA0gA3yYeZPmh5h08fTz7Z0OC02icX5cSzFo3Qw1LeLzmdwLfVKPDoqleMXu)nEY4viFp1C5y61KakW62)264vRIygASC1tmy7IXSXiHCRst3Dk9QMaSZEnoHBVfanDZJR8ZOZrrUuYtxZupVaCB44S139KRvILorYpI97oE4PJoV)aluGtl)rz3Cs26cybm(VTM9jwVKrA9qmhqk)a(FoDuB5JxKI(mJXYH9I4CE4OrddgyWA6uoVh99tGngZibMTRSxdKzqWa1aBE)Xdp71bNAUod4dRfZURkZy1aZmOVydKpNARjfNzwntz8Xsv0voLPQhzOgsRWlMfdia2yXKHggTBlNLBjB8o1pHcknBcQE2e89C2Wb4LTkHBXeQsjxsb6RvUicUObsziU8NPPRrlYsXlfXT7aSjeDDl)1PxbSXMXvNH1r30shkMSadbotzaNKPXcDPg0FRL3a(BIrGExCcGGNXKcoopk6RrzM8BlJWg0VFJ05K4tb0thZ59A(zy2rdEU(qedOJM6WoFmqnJZXHQDJy7XhwVwjV2Ehnm5jjowoFRcDyoT)8yymf7e0dhWU1hxVAEkB4iDH13DmwaJH3e3JSD0Dz7E)iNT8MB)SuYrq)8Oj5G12Zs5gLlq2qCky6KNkvuVqOOd42q2JSsOtVlBOfHKRK4aDlE8Q5hNTwRMQ4N6515Ivgy1euH(c8RMHkm0V5E1Ilp81kQOYakyJ12bRL3yVMefIiq)okg9SV)7Q2YFTmJTQ91Z87KHw1i83PdWBmcYzLWpm1TUgdEOrOtfQL2yRZRYMh6ZiXsR0(9(MASPRKtr26jmLsYzA6)a4K)7Iu6E)cn43qFk36J2eDoVsQcIlchcvOrQTzSRvPEBMF56wQ91J)Hf6oqA6nyptczWDMzcZyABfLLaw9Yy(pZo4phW3j8(8Jpv6KVg9GT87)OaDd52vGvt3qQhnA4qjJeValaeV9rM4VJoqd0jEupP2id7ruH4BD3I00PlwNxiOR4AS0J88t1pBJiL7YhTdR3EIMBmXLQnBLzA(2HuiC1Hy(Nh2owcqF7IhdFkNlx8V8)(dMURNev6libgbL4VzR0SDeLeiS(PB05oOyhQpWU4ukOJQyCHPJDSsCOgX8qgOdq9)C2DkLhebUGtTYFigC9oy)MB2BzgBUDfHtndqJPTymz4ijn0ajFilhkzjeXLEFoDJLp3luNQek2PttleX5Rxr8eksa0hcVLr0eKpaFvuDihGhQIaTouFkiIbPXCOP8RnOSQ6bBT9Yog2xmvSduunK8NQl(1dAhGzBhofX7Wn3YoC0Fzoy9lAbmGfr(0LzL2DPaRlWwmEcDTeZbmmwSsBSzW)cDd5eHFg0CEQUQZc(hOLEsxfJ)chiKFsa8Z8fqOrGVaO1dervkFu0SweZHi3tbN8mS98WbxkYDHdQ1ri7xFa10ag2UozTAspBSNjbHzAEzc(aJvoaRk5r(K9p2(ZPj8YR(8DjDpUYTlVmMq2kN0axflNQou55SAMzhx3u6cAQ7KZPbF9dQayQZZW7(Btyox9C9QMY92a)12aWwB1NPCqaBzUc(6tSVtsLwVw1uPYfeh26iwFkIkbDfpX2OeGZahzKgkK4PWK9Y(P6y6hTVsjm64iv(Iogs6Q7J)VIAQoD9RNzsFKfVD0CBipVGs88C7k6g5azhCT85dGVZSYc(ZeRSG)8XkZ5u6pPSYCox3)SYQ)Z0ywzY1Ml15CcvT9y2)mZ)BRybUx4)zRpBaYr0ofaSnNlxO5kPFRu7rgFZL5c1nvJn8zXBHP0RD8Emg8pgtd59PyuXs56Ycz4aASCkON7ecdJsmxXhHXmWmJD1sRxxw(YZerT86LNUQb(YQ)sFbT3nVGYWzOuvWAGOuool2p5iy1KOZ17jQ(LS8isTztMGKhXdbxFHHdjPcv8L7zcD9pcv)2iJOYqWEcF04VXrOulWscANjc8Fa3Kh4pgQBMryMrS)mrb9Lb1HtNwX62y7ut078WCCWbINgOPvjr3X59ksxIP24YuWRya33jPC)JXEN8QxjU8Ly1RKaNRKGkwj(ehAA41lDL4kBL9Us8mmARSgz6VHpcC49nJ7xo6q2uc6i2CtCtadHdxZGmm4gKF)pbXpTiAcwerH5EncU3MB3C71aPKI6ciQoLElgvaec2fqiVsIGXswPvZzeelaNmj3Yp1vIfxpTo4LdYrSukI2V3as)UsLDXPRyY2SdDmLJ8i5QwPgnbR)mmMWqIhW(Nj8esdqryFn8wrFlC5kyjZ5mqmqYyV501lxHUcs4lprYndzyoaoNnRJogsoGeI8jlLJQ1dbgT1qaTp8m5hE7tCtE4Ah03sFAVPCOtypGpXlAa9SZ7T5)MM)BYNZWRNsU8bIX)psPGGSwm0kVqvDmISC5pvpJ8SGRuty(kzw9jwLG78yYJgZwk2vCtP0Xq8o8AABY3)smtRUHg0NeRcIMDuVD1V9P2WGut8X0SKXmPWHlHChrpFr0mTY5dQRzfuYeld)gIxGjTTuNTAFvAEQkePOVfnzDrKQsLWXJMmvxzz(QdnhfxM)P26vnjLurghFaETjHftWlrIMO46tfuskDbOIa4VbnlSRlg8ZpgEZXWlYesnB30)5axOzTQ0L2V2ir8zeBOZEHGwX4FLxyNboDDGY2A7n80(vykuvmNQoOSXpeNdieU5D4C3qJdoOZfBpfMxY6JMzguMEfqbBh)mH(WlRjJalDFcBPRQfBxQKj2bCyLKRa9OQAfk5Wy4am2wO8hWapGroY2d5CzNti(QJLQmJZHjAQO(STBw2EjqzS3UmsnqCb9GLtvTbbVUwt8Q0tk9R2Lh8maUJMTSTbfAkYyZr0ItYVqLG8m5j0i3KyhvVfYgZt)MiRLcK(wrJum7kL0lxALYZLdoMvvuk)qIsMZGn(aEC27xYnB1Sp7E259t111QsfXBBSYQfXX9GY2nxRwI2vG(H6sW6yJ33OcgZED0GA)wGy58rht1ZTiP7yB(NRTKC)kizS1R0Pj(zEq)A4c1XL1HYqpsX2LXXtVFAy50I2qzQoJjIAoz9rD0lxGuGT8iG0yYFkzGz9Ie7WFq3L5XPi5Gbhbe7v(TkPsdMZQiUIlnRCKeZmHAI6DfKPTIj)iAz8eYSn2OH7JB4zD4I4haHMdoLsvrswdkfIKZqDXc5mnu0PimteJqzBrrwrWWdbRwACrBNWHLwfuvFMtMjHgCop8bAALk3dblNYWlAjx2HP3LqtQaQaFI5yvqdLj7I07WM9rQk7tAygG0SqWleW2iR7zpx4QXyD96YayJf1FGPtb0WswIkwUmL6wi8II1ScA1sZCEwQdyhmIyiPry7r3CnzO4XsvVTDSoIkNhJjoS0uhiTNnsJyhrIH3dmkvH0TAWNcr2PzMK9N0MabKIipQwmL(2LM4dzbKylxrJjshxgIlX34VI1EZ)zu0ksDTRLvsoqrG)bS8YHM)drrWlKGF(PjHzHcAmSr6KBSVPQgZfrckqPhuuU6f0t8UiSa4q3QimjHejrCbcKK067E1kRxTf40xcwMUkzCvrhwOK(pU3cOhW34qCXlj1UAH8DmXAQGHERxIme)Qg9A8(EHnxI(nZTy)feQY4zlIW8nF89lIxcFAdj)KIg)aBCOyf6x1PGAKAnYLhHQHc4p49adercqbX2JbL37yupeCMm2OVdq25LRjLUyOV1K0genasHmnflxzCeLjj3haNqEn9(M3r67iITcj9JSlxmOPk7gPfKMtNRJUOwK3Vxun7bedjEwzJRgEJJ6CTr78g8CWTcfNqGB2xLCirgzKFsUt6Gyotr17ainJerrXTgf6BynLnqnKGd1aZv5DO6Wb4AIlvMWHZD8Xg0GntnigbgkP2yKv1NqfGvNU4SENnzAxmBkDUL)OD1)J4TSbInK(d7hKNllSm0rGDevnMNLgvEq29DIdBG9TYr2L6d1n6nCOXjTNAA(qXMIlSdr0TRyUzBGGtxLz2A1wtTlfQK5Dq6k9J5rB0sLsTbqrFBWfGVNTEvpcTa0Vbj(ZaDJXMge6WlrxcsBm7QykRfUc(1g)yAsHHtslvgE6SS49)lhgiOwbpwMhMxMwYWoSi1MP16veVwNqjGJ2PDfTQoe4GAfwavlWPo1qRw(hYhWnSbFMd0ZDDl3AU9(m4kjFPg7ZaDjyvOt3PnzfDJRAZtSBhonKTb8aB99yie)MQCDaWiWmLT5gNyoiJNgUeA(IqmHwqDcfyTdP(T7hKVMLAj6)jny17c)eF6nALmi2GlUhmga9fGaBdKIYLFIwiMtXTK(RvP55u77enxqZHZdviHGW1)Fy7qL0rd60zI7f9TvGb2vv4vIKGVAiUTssfUv(K83k4kHU(ScaTQNcfXHBC5hvUNa7y6QLoipBsytxjZ6Ihz7TWkOK33kjBtHBsbovjZYPmczDpAA4AneJhuw9qP0a)UZ3(vAzQ)r1fCP)MrdFc5khY64v7eC75cXo55gs9kVpPxjVh24TNocQwxH9tQcNphpkz75oESEMPTmuFOwxcwbU7fY4M38LBhJ1LJeDwOYAJYpUYlCjefhK6tBvlow)UWhE)ISR8fR1dfOokid6FeklflpA4)zebSnkhpwo6CcH0xNw8PJmFrawQ153Ij)EQ9Ma)nukEQ5xrRsTn)ymnw(azVzjFt6UL9kCUd8TnDn6nUQNsbNt2NNeEsczDjf4tP)QMj0cDpMeUALLjqnKlZnUQsU6v03GBITNr9QOA9XsYdRLwvuEvAMNXWDZla)UQOpTJiK8fQVNhP)QUZxxpkT3vevKwET9pWHT)1K9cDmviYvX1vMJGvgp)sKaOfnKr14Xi3qo0ATxl53wrSIC)(7yBCYihN0Xvf9D1svLPmrwn565KCu4MDpHLxFLyeN2rvHJTJRuiBMpZelX561N3Svb6mu0w2DM5cIQYLZfsWStltfaKrTSvGWNCAkJ9e0fsSDLb0GQ1aEYTc2vbb)LeyTJ2d5PSeCEptkNEO3uBsT0uARtUpXMFHzj407gxPHU454I8bop2PmJOx0qkZ(om1K1LQyAglFVnhJAg6swrpIKQSsxzJsvjDHxS(TAl7qIkrNHS(k2IEQ(eJ48BCL29kFhOvDWBPPno62FUn(vOoiz8RseUMqvxmt6BQYNEcq4tVmCzWZLxUQqd1ufsLmLCI97IOG2Q1Zprlb5OayqCHCQsOjsvfiGHyt3k58rsFr2kmEAefVsvSL9XNPuVlfFY3Yn3MHsZ9dGkLRDAMKPMthSLyLM(QZ)lGksr8ShvtoiPRmHFhiyxv7kDaIMKLsTI8sMOj8BS5SUkwyVryaxJBlWD8ZBuRIL8E)ovybNrT15StsDHKCZvP)031DqkkfjvDTqnL5DnOxR5LR4vu6jxPAvJQvXjmpG)1GkptjkhYgKMluNL)NHCVuqfjKVRUngA6fCZNH9aqKGQfKRXKGZsaDTBj9I4z45k2JeHtfnn0T9JIv0uk5mM3aapCXx1H)GJf)hwVCf3ZZLIwOTKqKFsHS35x6OKWtX1vBugATnUNXbMFPmERXQYlZKigPSSzjBcCpXLNU0OPDgjjSaocSTZTwi1)GGcJmvAUcVN7qIrvou3vOhaaJ38xQyBcqbiv0Gsfid5NgaWrPKoXN4Dy3ktpNZ7bNbtGpLNQOdkNHx4V(Rc1WbOn9HuKgpc1Kb6Iez8HSzl4p1t05gyKV3I9xUv0CvK6zOyuZdOHJek1DAJYFPkEVTLUjVmDJlu468Z2EEku3NtNuYr9exLJndntnNAPT0DIBfBNsnbAAe(lPXtPPhj1WNpasIEeDaRlcsW3MoDYNH9sFAn8TGNLB7KtZLW9d)51Tz6dZXpNmhws5ADiHSi6AJLh7pJKM9O)0YaWPNUHb1FKi8pUjyJ1pDu1AB2AB8GqLQLQWrMhUygHKaqr)M2VTqrAfxLkJclhAMKURKDs()71(dBawO2FQRO93C7FioINE)h0t21SS40mLDRqjaT9zitfvdcfJZzlsbMeTHO6cR5NgZTu8qUzjNi77zgpTuxmKtPr4Ei8mUbrNqz8vtYlez6cBwMuCEDAhouGcdQaP0DaNrxet)JNGz7pixmKobNAOmJrKtO4mxkppyF8XIGtHq(T5if8ZgkEO5CdON9QPGZNWa3XvzruLPZOSrevEIFEekI9Jfx8QWgBTnXsZ2OHQZo1kCJ0qfT2wWZPS5Wo1cANCsnU3T9fXO7tnOaHRiWKh7qHoB(aihVHFu8DY28Kb8cBwOIIJO0wtjsIvbvhbfRSISRItztPoTqil3rmrYbGYHhcda87ZazxKoe)q6R4sphHfhqdZqXLGxWRywSJnNevJ47jOKsUz7kpAvT6QBLM8KJttr0c3oo5uZXJ(omGsqdCOIu8xvKrSNKNVqsBukrw5499h(DlfHlXdSSzVB1C5a3WXw(hs3lNgydJGFM87zHskLKVntil2wiATTZgCBaTkxekNtbh5bhpHYupP8Juo1hz0Tv89n93epxPgABWVXK7tmRrkMNTwlYJv0cDMjEASI)L)QIJzxFEvqtgmkVgolHnZFbEEKb5OOLKUARcrE9oHQC5BE1KI6ZiU)6iaY)gs9Ra(PZvjgNYZ8PPQZ(m830XknHoJNtItNkt)s6baBRvXqc0ZzEm4VezLKjNbWPDD8QfXadFQPLwmbREorUViggexaGgLZvof8b3xZlQAhDltTXge0aIPqtt6rPz4og55rHlmdgHVhYWWejF29EYuwZZYNQUyyyf6OnQ2(eYejNK7ban4zWrfsk6C)zCjpjoj8WaIvYSOhL5hnN7cwRM8eV0oTplOMgXJYBbgMGLXjLZM8caKEy(JqXQlVkIXg12cY1CoUD(CvooaKNBr0a5HNJEcbWDtI6f4fU2P9pzy)2LBJlD4(NKFeNoOpaEIMONMwCFzsjRfwOCgzXnbhG9i9ooomEMtqJWBlb6aF0InIsELsC7hzJC6J9Sj4mop2Bj030RVTB5m6w)Ru7z47ExzOPTKbn3u8DVBl0vKuYBVHs44F2WQbddRqLnhTYHTXNPhSfB74eW5q63oZo2Ow)pDabYt0n4SRVYqd5OqvmybcRmUcWf8W2OYLdreqNfNeNlAuar6XlsP9lfWiRyMEZUveE0(AB1UvTytCnvOtX(g2EOk3nTC34T0TdTZ2GIxTDxFpABv6Eb1BXj2XKsWYOnVcLisUMuxaTCNXPFhy1QZgWt)92vQGPpsNVPMwnIhcnkrbKuA5cDfEhXLG0l4TGJp(cYOq3oXOvO(nu4FmZUaBBRAmZTwgemnH92vYJUJgZEtp7GQkqeVUmRnpnlyoM4l9ueJZm1r84lLAiCp4XBoK(lceeRyNsf(QCLNEM7uz8keqWTXjXIVDLf5Hoyt15yCsEwMUt(cLOrltkB8STvlMY1oJoWOSlXKGcP)v5P1VsBaB78v1FasJHH3LzYxUWoi4yeH9dgLB0grRiLbz1kPdyyjZ7(DoSxLD3Zrt6mRnfQZ2qlFuqjsTdclTsRwUax2dRLxuwjjHz9PyF4QtLCNEZbmf0SaRAwyRgTRB77wQo2Hu7bTQA7R(niBBwQsda)7L0EhgFXCzMTWTvKbEOCdnsa2W8nlb7xTPfsR0rpuJ5raCP4CvHdrZzB4kFChZhwa06lF5BwHowpnM8VBanMXZkfD7yIl2LAyDwoGI)Rr4CngEd8nljJyldgRpC9qSbMv)BY2pLmOBAzjCxKEHHQdUprMS7i6S3(nI0NH)RnaUegvrvDIdZut)F2GmN9IHmE7gVZ(ourD4h0NNz3YAUqKiFpb9paqkci55(5Gde5nQuZukQacHoWOZv(V)VSfLrPs8VEHBotqykAXb6N6JMLWhxR3Jf(TPSrAU7z4KIdOZj17o1GjYIycOxHeSPXhIwfrDYMeifXWmJGjF7JW0yJmrJLB)gfXwy(QXWqJGgxNma12rGD5FYhCv4rgkcuYzIwE1umVewIvwdFBL)1oot8z4MEjA3m9jeSF8DMawvLK(spSa7yY9YtrA6HrOBkqrztQSBZ4GkTvPRQRVVxI627Mtj7O7nHx8Xakzj3zVwmJS7sSvvsjwU)9Gkr486JddxguRnNJ2S7(H0Y)0uQ41Q2VU04uAuQYn6vn79(6Erq2rSdjWzFuYZsu(AlJkSinvzdPDYk3Yz5)CEz25gf4QrWQorwP)MhQa8ynbC2Fee1QeddwEqcgENG20RdxfFsEG66T52Fbp4l5gScwbMuW7vtLAec43yDoZkNn3(fyvHGAk2vGw5V)d5ICY5o4y3jAZTCeRCmRKf6CisJOcv3nIVeHvl1ZuVlc(y5SBgpjMnNaZTKwq3ZBPwthReEB8b7yLwRsub5DjW7c0t1Ggv8qHkJWh1Wjsm6pGLkfbxrCQYc2gWME9oRSulFfSnhQz7tk1S13RjOdDpBrILDF6Yfe69igZRlUA55E6eLVbNwWAzDCrp4yIkMzmISE0jzMCI(UgEzQKyrDH1HzqbqA4ajzGVDu17fo6ka1d1vJzSvfAV9hKlv5S1bKdnhX9NP92aF)PQGn7tuPUEHweH)v(WHuot5POWDXlylEWZA8oQzyc3PvG6Vq9pm1OOhSYJbUx4WxmhpFHOuyqWvK9ilnsfy2aczy5ycOGGwFokOMImo3OkJ34OcJlYOfwLgBDKgFflt72XIp2wnH3eO6Ruonw5qZJpVklH2Mjmf4MDAtRjzvokAU5OPkGVkrU2CYzJ749yGP3eok)JSGL3PyufSVkf4QpIcBype30XRAEMMciCiMi1Gfy)ZtVeVKnRyQr5V3p4VUP5fGPQsiHScn3U8iJZP2v8kFL9y5IGgVR4l3tZxA4u1N)NMa2HSapt8k9PKIb1XtgzWBWVNch1iFekTqYH)xOzHwvDaZLsjSjm9jihXOqKPcLJbtUw4xoYadTa(CD1paDqvANSoJK2iz0Jd6OU6JecD3E)n5jEMBL(vTAkd6U2W3UyUaHTSyEpnOAP)nXKXlS)iNiJHQmqFTAwey9MjwvwBBv4PnHjw6oBdO7MaGXigQZtkTqiLwK1YKm87OlF5FFgbWhZZz4gmyo8UKzsaQwgaVbCq5X4hIuLa5Pizsf7nGFGOFy0(JYMfnbnmIBZMHFz1S(Gpvm8ThSk472JXfcIpUL90av2UhQkEj7MXogVsWAXtLwlkQIdGY7ibSwwAhHIw)Gitpv5aVyfkpTjanEapUYawTLbgLVXy2JwEqQxzmhE3Hht0PRc1sSwoX65DDg4v4Db14Oeu2YR313258C6iwRzevXMw8Yn1PLBJgAs3D0QcVZ6XVS4d3OUcPCakHuQ7fqxA31QoGElP3wRjbUVsMsEnn30T8nyDgs1CpaYFbQEX3LShk3xFgHxMfirI8IA(Gh11IIngM11YuWohblRjMwAkMb89OtuqhwT6MfJVwsrdkaEIQ3HgING)KhkTnQcigz2Su3bxcBbDymg)8GaTI8)4xo5t)IRyYj3TBwfnJB6wLZmcf8B0)E8l5uJRY6svUK6RrfnRmSvThAwG6(lZ))zEnAwK3vDCL0KSOvRTQiWx1AqkecVBd)pIthB3TuY3ur()WBylU6usUDtGUPdo7yknNlVBHh7UTRoCuQUoL6TTev1R3S(wYEWBao7AkLMaDPJu4d3utBITJ)5kPsUAee8r9NJuE9hrRACgHRB6mJb5sSRfivDEm3QCLy3V3Pne(xrEBlF)MP(dpdqlT3DLRnKdfvlEvUkZWdmv6gi9v0zwkl93LtkUxOlQAzMRULxE6rD3NEK(990lO1erIHR6mhYf77VislgsPckawyVCiDMUZeGZgb0TPXIJhbaAWa4t(kObv5wfoEIujmyH7ehl9S42DQZZUk7f2nlcKdLy31DdWZ0Ie8fSlAs3E6XGvIVe(SzeNySW6VnQFVdbRGkvMTV9Ruo2ZhIgyCsDm96IttNVEBKhqJBhedfInQGviwQiW5ZLDxVOR6W0vixbtST8X8uqWts1(rMw0lPgiXCWBflxdfOm5FmqR77zBkW8BfwjQ4PSvpqli0rkuUtdU5njCv(CirMMjnQx6uT8yMHieppiipQgch6eMjtGWpgXFZfGYIWiWwTZYcxgLBLFt)wugBVc3K32QA3QonCfENCrKVnlqx0dJPIZMu0EgYfpyFWtf6NZbFls6aIE4XUoPuTta9crf42O7TKJCL7aLAPFOQNRyerBkLRa4Tm098gF1OFJ5Z0yQ7MlS(cLRkQ9aXIMjAuzQ2Hrjf00flrOlQS6ZJ9dDjxoyQmheRPCU4lsrbGa7k6qQcwMLj631PJL9pB30rXG)at9)lh6GACzvnSL55AwDTZwHabFTD3HdfbERbQ4EOMgxEAhVo10aBHV7JaUjeP4R84BGBqkR9Gwxa8)GzcExpTcq(d66Oerws7OdJ)1FH)OFc(JcHBvfDPtr860ZlPY1aV00tVw(xxiD)EBtFHJMu0FoNQgFgR6QSHChfMYShSTTnAEJm5LBaz3l0mc95Ctf2GCunGIISq057jxF6ZfNpjoH84ZRsnhO)7j6KoprC8Q1br7bSY)U1Wh)tmYOHZjRUzqz2bkNmvpfjC0bk913AfMX4nYGXIel1vxS6iLOj94UJqik67HY2chh(bpKiSIuv4zNNQuOdzs0OJiyvMQgjtTv7wVfeTdzSEP4aukpaq09CEZZrR0xe)qeSek)vxYtSm8Gc715qYXQfmr2KJAg(uemz6T(d4xewEMnzp(OheeOEczXdj6dFo9IRshYQWM1v80oLO1urw1paK0Io85AfwA2Qm3gDcj)zX93NmB4cLJ9Q0ZbV2fFjRKzS5r171wCpcz2rxKLcOBgd0Drz5rzGZJC9(DkzUGTd7TPGL70o8N6OA58wdZqAMB)IT848wsRl7qd5GZer0RD(6P1hyl3980yKyMXaMmh0yYHnHsyUyhcNP7PwMh7wm7THGLaz8vqq)ZhCkYCfyaKFZ1)XB)9F9V8R)V(Xn3cDYbGjet4yMWNhVkDfiG8vB0o2IZXuQpCDrk4ILPyWWsUhYI)F6NXmhn4hj(qrz4TFLI25)7RiGI(LeKnSB1EW36ihLHVWrzZpvZsBA0SW1lk2U12zMZQRJx(E2B9usb4)3FGMx)8AgV9PXuiQyycmlwdlWi)CshRf5z78ImqBuE9opk6ZLZF5lTa)d3ooPEZopkdRyukyY2(AurVbQrrCPc6AglfFVEGJxpO8RpO)oVi0bfdgSFgM9d55Gt3pdZUJ7gu1W0GD4rn59Ryl2yzS7y7bvnmnyzu50OblJrnJBjuBkPlVlCl5xAZfVbliDcxBKSgSEgUp4bbEB6JF(NBUWKW0OTdWSFiM3p0Y78OydM8SNtoNvTJX)9(xY)5(fkAjotxE2Y0PRxanahnXz)GTK69dFQQLXU1tQDg)EpjJDqfs5EP6pmy4lF8mMFJ2plZDxLTVhY92p7Db7o3i9ztWEElly0lF8cQy82ILPX0A337mgM9d17W9mD3WDgxWJ0GGx(8ByZeclm89vBLK49W8RHkjKVLkpTZYLneeU7IthuHMy72OSZmpDJBTVmjA3brggrSFGr7lbv7h2lb7nYd3J3UoT29TSQ4bVlRUH7FE6b7hX67drdd3lIgmLWS77DgdZUtUzmm7mpjjB))cYLhE5ZerFaQI(8cGvowKBZIHSY7F7FtR)5(bO5dS5NGR9213JncGG(hb)VGayqHB8EsGWps)6yOa7NIBKKxNFxu4YEY7rpm7UurupgIM0KWCrv9B0i5uV1VhbNdktHElss0KO88qi5sfrgM9UTJ7f17iQAK1pBkp(kEfklVwh1O(2hszlo4(teD2nXXQewGRVcJNfBuEmlvRTVPgaQFWaBlPYuCv1jAaOBrbKeBuaUMTi6BusT1ww92ZdP8XBEmpB0YJHdUKWKO015lKTwL39z4CnOl7BPoagEROZyCeoxbr1FnEvh7zhDMQ8kJ00HHwKpHHIKfNct0vRK1MjM)W4ZMtHmunCFjlcKV9fuFai1wE3IW5M))qAzNVkAcoffE9qogFgDuVA7cb3A)RikODGSgEQeYLfLhVios0hlGcKkgggYxphd7TAFKpf)n3jUZgrbBndZZNpazWduOAwOz2TInQxN2tGU)2KK0csvijzYB)TFgqJzeuqIvolDT4mQyErXQ8F8Kt4zc6XST3j9UNTNU(UEXPNWhGJbEENSCAV5flx8VdKHxksD0IVvaFyIEnVN0bxxkstaEWZyZnU2CMfVzEehO1xGlb1okdIvqbZgZHj((uoBhyWg1bQcGjKHjSDcF04VXry6SeloJ(OCtLxpnWFmKUj1B3HCzT88V7LNiMOhbbe6Y0KXSrEmFQCeg7Xl7VdVz6QldNoLpadokE2Lk35npmhFwigDTuxwgmrr)4P1bQBgN3JP7l2hXwYMifzqy9MG)1AAU9sNKb6tYa3tYGQMKbnAssii6730Md1ge5A4hpHkCXPrfrtqK8WCnmfcXr8(9atiUgWWuiDaU2P0BXRGqmx5sIqJjeCgysbMUadU)le2Dka7Aq5z88Z(7mEA3dsWYfrfGWGXzRV7jeQrv5oXDxjAHkpIzuQtJjlXe(rcicUVTnEROVfUCfax4uveXhyTLS41f5qSijgadeZXSbSttGo8k1Gdpg2)W2dog6Pgh6QaQB2iotFehv7ikbry7gIc9C4sgtWcsqbMs7sPK69haOTf9JuDDjtuJYNXqcUk8NQr4mAD1ajKP7G(hQusQ0bOI7HfYqOVcLYCA2s3pbgE8JG(retEXLd6dyKTfzCG6CRGHLzLd1gxbywQUGihs6GsD2C7Vr6OG8D56Oq9sodusGm96Viy0)RuTx)ji3lWhMoDKaSsv2gPsAa5AJIMUCHTpxnT4DlgCKBDa(Ra6xo((I8LscBhHtM2hO2eD2KhF(5dkN)jSl6(mh)YbSBvDHB055NBxoXFmwWiKPjGGoToWzc84E5JBSwR)Aw9TkV2B5BL7DYqQ68rkTKyOo8Jnyr2MfHwqaysOm)hcJxaakfL5Ley6oMU)YRXwsGWf9mcHZFhxXhXKvfpPGlYM9HUODWHgzjfqbGPivx76csEhDUrVvKWEWr2MK9YuQtBeQ60ZQsrJsFSUUOkkXGjoFCyAeN3IB47vdA1(apj9)ZpxvHxWq48mKbAlqXjYjjArrtJkIIwue0DJw)FxLuqzmEFpG9fUzYIgsMGFOHarODrZIYqLOjOf9(WHVCepVHqEsvbIOPOFOeB(E1aCjP6LDvDcdWpM5Uh6l4WeiKmHJudvvStpsNZaHsvvyyWft4P7i2Q8IrD1lEeBDMWYiVI1rYy2hKViqlmHIPCGSHf)8ZAxK3DJnVMGsU0vH9uJlAu4j0DStMSNF2rofEP(1eAi(8ZQkGfrxrinMZyVtM2CBQOQfimlEAPXlxEaJ7S()aCG9rTKmPKDXHNt4x4ym6zKMElcvdsRsFpoVDNCUR5eSH9e1WuStlhWSRgmQ1b2PJ3ZpBFLwMjJzlpj4xR2vL21xC5GGJpvt9dRCQ25M6fdyYMg8dAjh4fTh07nhxv)U(qMMAhtgWonAr4tJvqy2Tg2HjasHuGi2KcgQJI1q5(eNuuuJT2TjiG1HHXIO(g2NukmebT97vPWFH71E2r0fV7gi5dep4n(2By8tbxB0YWlixemYnSW5r7nVFWir2ROBtXZkAsHnI1uigefnDI5JtxbKUgwqMLGlNveug3TBBSMoEWOJ9KKUD(HbN3VZv1(soOWmgHwhKfgpDCeqD0JziwEVOVbErSv7dCEoovh5l(qDaYoNt7RIHmrFvkSFmDSX8(5NRqB(w(gVH91)w(xTv8HpEqFN6ykyVYfoH0FCma0tt8TErRSw0JOb8QPPRVtCG0UwwNAa7F0Xv8xN3lVG)BkPvwszkoOFu6hrsRriWrJAxuQFwYOdzaxRT54KRgX2(B7KLPRSXM28vzUDhL6qo7Dhoy9khyZxqXFS7OQ4PwAQw3a6skA3bbAFdVPl)XdcylW2(DZq1qoVnK)lgC2R72UILjysrLddrF51hhTCl0voK2p)4HNo68(d02eovF497dMwnUPBO91zwza(ULrcYEjC2nC0OHbYp)vN2hSot81Xc8h8A5y2dhVOvB1azENXdp71bNQwfbSHXGi)kBgis8HG(DalcBlLDy6GkWGsF3Aidfr5ArCTow8DyMeu2JKnIzuh)FWa13lW73ly)99yGgl15xBZpeRadnxqcm6qhTtC3GUolYsennbBsaRxnpLnCC9o8YBR8j7bNd3bvx302B8b977rFHUTpT)XufMvUcRpmOdxbfh38QHNFCBVKWSxvPA(h5KWBU9ZYJUJG(ulwu4RqnD0qPfaOs1gVXtrwuheQlzRAtcovZxdGcBLXfrljaAjMjGEBEKRYiGA1eXQWZPOCkVLvfiSF3kaHdlRzRZDXHVwbQVMyTHOB)o4U3Bp7FeWzBoSO6X(GZNv2MLwEyGxYpqnAd6mT9ht9o9QK2fN1XHW7k0K3N2zxCwD643hKfQlSbJWrAw(yi9asIy27aAASLgcuv4bAvVmAglJsiFToObIe1GOvktu8v4t)))S3vBVTXrs6FlcbIGdhjgYHCSKbKiWERTXEVKD3BtW9vfkkkBElLOoourNbc8V9RRQ6xQU7Q7PLSDIdW9LeBZ5LE6URQR6PEQQcg(tYS1A1s1uJYoNB3dbP4EWazLU3Brr5HhHttjVMRMJoxxWfj6EnmPm85(9vYSM8Q4SzOG9FA7tl)yNwE9F9)8nbypq1X2uiEKgdO)NydN)I7a7LtBhRoJz242r41XBFgvQZEg3EQ8V1RarT6EhL2kPsns6syfYzizQTedkyhZV1IOPfrsVpdKrCs18DaI4gqhP8HLQbcyYZFB)1FkSabLwovFBQX91yHQIm7LKsJDBq40bLPDmPT40I9IgFNXykSIpfUQpNcYFcF1aHg92GHj7KBUiWiIPLiA4a0XZOxuyNJRqvVfCrf6Ycj7pBYGJ8XkuCR88j6yXJPNlrzgi(gaktklKVE3ESOC90sV6NhvHyKJdVdZEWoKB4gIiN394FJO(bOfSbRjoBXUHiah(nC(BeqwGudb2oB9)2upXhF)eo6YPC6le6yYl11Q(GUnleTOc2mUzFbJijWZ5klrmsOjtwBVqvann6x1tBxi4vO9nZpRjjYeIylV4vjFPNM5nEX0wziGokfS4oxlLN2tPQjZGyrjQHy7u8TInhXFIC63oipkOITiAFDQ3y2XRAokc5uyVkTzvSY2SOvVMkwgBw0wz8eTNIjtIZANKX)Ebb9MSc6nCYufkONb2Iar3yVl(Yil387ISSeDU(6kll8g)Txwwyq8fswo)tUhz5bdJo3oAwP6BCb(cL4Fjc8KPTDgBqilvS2ba2W2znCqWaxI6HVDdDFVFhe89d7mrg7G2JSDGzj49sSsN)K27xhrilMb2xWPmsuOU75(7oO5wLy4(WbhwJ(wT8Wk8FcMEn49WQv8M2Q)bxXg1JweJvdMl9DMeRkvxbpPRGhKYE)B1Uu60aivcR068YvhSUqxNNRNmEQbkTCxEitA4vIi4zmyyAsojrfkgpNs)YvMNMCINxKyH)9D7bJqTe0xjc6XFnyMpOOwXN4J9J)93R8hZLIageIdzZMeLPapoo70EROWJAQdOb2Gs0SZViHUiGZdthFlOObEiOhCnH3KTcbMmWpu9CKGwkIogP0VjhQ3I(o9pbd07v2DLjwVHa4pT5mr9CjpyEI8XQtBQGq6nKxyzV4YO5KLDpKZd1CQ1TVzz96yOwKgzTsaUbCmPIt5mgZYmO4DW2uKOBz642tN4zQKWSR07s8Xv3g4XvL3QRKYapU7K6DNtf2cUkRk((KembQa(JslzI)4vehrPqsC556bO8LIBHTxALS12tNKqAIfsOFKqsHu39GsWE9DBwrN5Qu4IVntmj2U5xa9PtNtbYGucGQhifa6ITNHuGlnzQIpCOc19p4IMohZ2Jo6mB6XsFhBmLOB4KDmHc(WYFHgw7(KPBu7kyF5vzRbo6eVSbJoLFiRBELt05IzdIuPBNXNpOxL4vdKyfX8t9eZR1prVdjvliQnH(NglTucZlu9pei042DxJzm1ogW1jMvsdkzzGvbkQlb6lBvyfg7f2wsTnBodzu0Czb25QedU)q4hfgLw1wQlHem4uT1iHExGRbyhdLcazGNGYTG0b9(WUaENk1bwJFmFX5jNRBAMP(djTqOor7ovA9)FF96hOZID9UpqQc)dWWcIAHU5PRPf0)XhxTC)sJC6MyY(4yIhwvPjBQnzzJZEAWiGRxJ0udt9M1bfGA4QACQfc35PhUWSV4Pl2PMHX8jF(dR84fpkFKGDZ2tlLMehmu(UUyM3zisNvu5wrtkXp45Pmr(40Zsq1(fxo3)GNT0c7v3UDng)5RE)2n3PEbQbQA8F8XZBxiFcBJOMPwsivSPssbUwJRljG61seX(PIMZIpHI5iZlSB9yn9aDbmhFI2iB8gipW(r6(9)fBk)SbjXGUFKVX0rEHh6oNv)OarMDEz34LzxZN)wYN36MAL23C0zSfhpPoC2YPlaKN)NwDeOOm5Z5120OtRwWDpW6ARjfmtCUCM50E83m1M5zgets4Ex6Ldo2(cUbhl(RfatNqedEw7lOhhGxsAxq9tQQhj6Rtm6vyfZcfWj84QWEaULvVf)oQRmGvFzOTwGTAvyn3v7vq34S5zH7zwNsCX3xxZN9vpT7(dHinW9PzX5yo(jLkqJMmUPc(X0l34hcq78QtLx9gnJtH9rzpbr9mKoEv650ZJbhkIS8CuB0XmaWyjFVCR3ClRpflpNua2M9rB3fka)4dusvjU1bKUNxBYCVoDb1(X7pa9VR5zpVMq3GBROK4M9hL3Rm4iNLMbaNuUtslMvStsG22ehYpVVXQBrs3BID80czM)7b7JWoGMzkhuRQvOIg32rzY7NcAbrOfumawM5wjaTT)3yvXGoxfY0mZVT()9Hn7JCTXVv5k5HZr2GyRnGTNUR7V(RPBzV4yrz9sVn13lOZO(hg)0(bDe1PabBcImL6yktDPgQjsqo4)4b)eZ5sbW5m5C3UdV7e)BekX4SegkUZTat2OC1o)3cJRE(VmLI13qgSe5)PC5HWy8DCnZoCz0W4aPfqUXhhInvB4WPZRLmLv94g1msaSOhFOQY4Qz1XdNwR18D4j1MayK058A1tTUtIHYO7tLvp)QbdDE(KrG)iFtM4K7Ydfq)lRi2eMkVqetZc5SJun9DXWHNFQeCBp(aqp0rzN6QgCumW2PsQfEgb7saAX38GJ611JkrxBGpOPt6zq7fXntKPjBZ6nsqHFavded8NuBl1QR9D7(RmNlmhZzAV0bsnQVAs9pD8aiSuWgV8g5WtOfwg5Y20Xrir4y)CMrifZVeuoYWLYDBvUsTAnUW7JfAVz)c)YJdIPOPm1Nxj5GttGdojdCtwsGLiyUVuXzn4BTIoWk9TRSP8mzmtLU6ctthMXCwqRYezKazbyll)LBbQVvE5RWb1fnVAG4gw)K21sHvT8M58kwKEm9pv93K2d8WW9yHzFPTisXTumCeitsGmSCTGp5eB3VS5vvjyjBQuV1TZACB4xQ6zVC)94Jo7xOx2x4AEJ(Q28nBxpTtTsoeXet2XYB4nbJhEZUlhl)Rf3mvW06OPnovgETwp3wYubv6CFBarkyQd0V2SRzmZUCfSf9UYRxtbbGL7VKjW0ecguai8TjoCWJ5N9AxLxUkMiyTkFgmhVmqoBJNyoR0fWk(rBVLm)vDPBUznbJTFFeusMlknPXR8pPT(wThc9oj8KrUYDSKgfydL7CYsIwQX)2E6Tpx00MiYNWXkPDAWXAx35dRxTFhuGlcSnBrtvpjg)RpDyM8IpjnXtZsPkbJ2Se4siVIukoI4dZKai8McPewpPrgyfxp5zwcP9fZMiJQBIag62JUKRtYRj1AoBW9ZyKd2UN6J4W(vqNLR0AWKB1sPeauzqpeNrL64PzqX)x)vpxuE9esIJ6qWiGxrWhhQ7ffOoyl6jIgjYhMc82QNOyuGjob7Ryr8UiZG0bgCeMo(8zKJdDARkbgMZZI6JW38VbFvT9bstOVHPXxkdMBrnKzSqer1jgOoy6T9vFpQFApNEw2M46nUnEXHbh)B)xR19PlykHErU9IUwQTfh4qbR(JTMDvJlqXj)dUIieOYcWNlG2gHe0aYJzPRRK9ND89NHBD6ZjYx8lQVhmTznG8MYEyVKcEyp7zbKbsonxa)ws9IzMAW6wXr0UWzKzQwvCWoktBr2vKvKjxeN3mqgf9bye2DzZG9RP)m(lx0cmFv)BZQyScW)TA7TRFDFT9ymrBYQZto3vsAjrSzAB3(S)iLGjJUQ2slfjTGj7FRpvz2mBBuQ)5ikSe2SfZW)2D8WJA5(Kw6GvkZaL2o0GRNQfn0fSUgOzHEheUi4Vb)WCVdu8G)vJCF)XutnCUYaAw(AB286B3UB3(H6HWv4fpszn5XntQ0)M94DCm5bxhTPchxhpNMI)B(NM4CddYLD2PwVdryuFoKPMBElfKF8erDzK0GiUGIeB9Fmz(aukEHfGbAkF4MLHxg(Iz(wSlCOwHGXKFtzW0wqEdlUNbNhHnmAmK0LMyV66vZPdNmUz0WeabF60QJZ9BntQN6bWDg6jpDCBvvnwqxZPGGjqtFYsNozS8ckQ0ojvnh5r6kHu93LfIFe5FyQnAzl0OgQLZY9wtbgeQQkXUpn3DV0ZtTe0KWLQQSKjuhjoR9xE77eUpj01zgrePerMITzFRhfpliYj44HApwQbIR2NDWwxL()YETEsM(MY7cRyC4bpjXUmDyWTk92PfgL6t2IEcIrI97GIHl18DIG5vkdrU1EX49Yo2apIbQv8(XnuhmzmA92xG5PCPNL(9Xb5XggAQ1gzlLC34kuF4FNQV)uaTXkI5n3yziaDbqiVnG)rNz(HnG)pwMOAe4)zO1dS5HTBmfSN7GuFbEfMGbBFmrFD5zTRxetmBr0))rnnhp9CXNO9f)V52cfcKMRceIBR6iDrWddUgkk75JTVMUa0CAdT5621pz5OJE)gs2ADi(djyWbk3FEY(tGDoipSj2bOzjlDX6lHahLzUr3HllGDa9IkxP8gq55IWZ6dRxU1HVxQlWAxA1xi2hK5A0dgZoGogWqHCtigulcHduQ0w298Imc5FL7g0KKD(KVF2KHXLI8knub66q70j1i374uoqdRar8aKuUECeIw2HTK86uc888hGEbtWUhd0HC4tgk6t0c6j1tE3tJ5BKQtMsphX7Tfd(dDc(8fj3E6p1E(AK)o1nJkZw0fVAM8WFwUeaQpej()Z4M(Z4Mdc830YQppjAy4OnO5GgqqxOVmGzF7M730zYtN1EjkQ1AgckYq4V9fR9mIOh27o8OH9NWOl0NwqLy9SP)PFfTFtuD)3z0Evj7IYzE7NxQNAGPib7KRcWgfSeoHEWEX9gukkH1(NLodrs9ihvxZDDopmk2nVDMttSDQiSFCaEN9tOad3u61pGNasil6h7fFlAZTruULemSuX7fnflEdrwmfWANniFnhgX9(LwF8uQpcIIHxeTuUIpBYiz9lAsNByEGPgxcRhkdG6mwicv8h1Frn9Ugvx8r04eotgxBtLJ)H27nhDw(aASRpLmPK2J(cqLqUY(VpFh0kZ68IhyqOn8PLzy9(oG2RDX9Mf1N6vAsUd(p1zOSvo0iGyHMoGVfJdf9oYYmoZYSj19gKdNx9fjs9VORrtrSqccA(WcHqOIHAMMuzMinhUnkxltqTYq0xyTzfddX79yxEA3bRRtiuoy0nG)PnDoQ6sV8Exs1VOR0VhZQQ8h3a55I0FZd6XQgs9h2jRWmZGJpkyD9F3M1SwetzKrPgLf0D3alZG6c(MZX63C7s0))S7sSxJ9KiH50Qb9qU4Pno4)9EqC5Tqn5zY22)4(r1hBI(g5t7vf9P9mzBlodCBAY2MKTBM4R)ritvGJja9PV)da2j66VHFCjpSxxJ6Kicvw6WHdX)aWgoQt7qh1IE(ZBFzGb7gSY40B7t)8W3S(H1uc5Dpe4wm6tk1YVfJ6LLbl25ZQSAxvEHEf8UKsDRxp50HnMIcQphHrZKoTzuOz0vXmk1duKV3MDe(nGnnMgWh5tQ)51ULyxNa5FXuwst6jK5vQX)ASPrLQT2bmH4(d60Wlk5rmTmH3R(F)uZ5F6NHUvLgJeqT)F(nDMWpCn0H2wRtyfaSoyLWSF2e(MdUC0s)jcFTuA5Fn2BG6u)4MvqZhfoW0A(viCl(lyE0l12j9cWErKmQXKgNHrJzFGeT05g0QRQvP8yGYFHEYyAXk4PmZ3FPL1Z8KpxqBPKAaGK4gFgyLe3bb)lgR6e1KmSmWyWQ()NvrOTGE5aakLiT7lH(w9W7(cWHXdpS2ElP7OtnPHIl94j6MexykCD5Zkfi0BE6HQSlUSHyRHpXIcjo659LEb2yfz)vsl5weji4qxDGcSact5A39(5wVVYNpZKu4IMZk8W0ejPaVANrGp)CsWGUd(SZMLlaLoUKRxFjCxmFwe86AyK94Mdyp(CJYUp7NaPlc3ouRDRXtLtQE9x4H7BkjPeG50VlUpAGrH66nBvx0AlEbpT00ASbRsaYIDJpdX8dvLgob8g7W27ifLkZj0Ql5UShVbVbGvbxrRyM2rvcWyMoPUDKq(JKk0dsk)86i3UibXOO)NeON)H9Bmnw(0gOEctqlWC48m3NSYUxI7ZvO(6MttzN2O2KBylMn)ZtZMFh3d8x78YXlhh(7nCCYfo08swFDi6)ZcM0Mxar7lS0h5J6cdrmcKFQV4tiv4Td63)kGuK9LUZW00S2X3zGXfDHKGw3GaH8cncJ4(Zva8xmx6yEPPHO(GACULEBuxA1ePLyCo5qCEI3QH6YFneRwxHreT8F1J7jfHw9g4dTTUtS(PqNTHdiS7S7OeimYSFLw9)MnsTzXqmS0Ugu4xdYP7xpjYVuJxyCxtH1PvyN7vnw(O7Wb6Sel7kT48JGkOfDuUV(2Uo18IstdCVKNuW08(hxtZ)2MxooHMPxiQwQVD9k03jTBDEWcWSSrpuY7jm8zPv6Df(Lzp7jcl)cSCyqjQvR5t)1ZwC5SjtEz19xZ2bpwUpBYinaXzJQGyKPtYR4agxT0X6ZWIdfghaWr65whPnC5d3tB2Jzj43stQeziBHJhwMvwBrGdo081u5iDOnGd6nK(5i3VynZzJEFwLowd38WsgvE0cONxlgqdSHkarvbj4sgLrdZN03I95(KM3LP2t1dM1LDUo66rmUacOcGxsVP9V9gJeMQ8IkMXAG8fyPmPjO18dLBLfrjj0730MrwMNUqauTXcTlvoLPPQhUJ0(pUIfrLD64POzzKLYrayyRo8iPzKDkpOC1VUphhM00Z8rPccjdjypX3J)vdKV)SM3)Ar374iPzm0xW6yD1EdDr4V8dF)7(HGrnpfsCPtqY8pGN(bbpjV0c5z(OYgfD)0ijZXREKvjY6Dw(C8TWOtG(jSmDZceRlN1O9jYoWCIE)DycSLn4U6COlo9pJ3oh6Qd3eVOSxRmDtHk5EU233kZKAtsMrjCr(Sm7f4zJxoS594RNpzuUI(rv87VEM5omsHsHanSF6L05jPFqiY4gkXK6tmhzDgWtKHjJN3ZSvschvmsCtN47x9IWjXrnNMYDARNGjC40mkFfVI081Rk7(cC7LXTL4bpHTVKTbX(3(ms9ss10pT3RLurbpbZYOD3Y9qdkSAiOgBm1wnWyr1KXQ)jCQzCP9clbPglcnTBE)Zwno0KrFuk7ZkZkm7TbZ9H5O(a)lXWSzj36ScDXCBOKT3x0C2K8gb9maoJw2ER64(7Ouz6dGZz39iWQFYvyW8G3VK6AypGuEhRKOJHZDq)gjQibOxC)YhuEyEqB2GV)ZDBuMerwobqn6YkA0NZvRaiDxRVZTWjOWtqTwC7(L3Tom29rb)8VVE)pU2aZyiM(Jo)4CkNQpk6gg(QcYsQzvhNurvTsjxlp9TQHsOVrRngU9UR0byX8aLONNeULDMqv6NOciwh7mfzD0UqYHBmx1DyAEoGYbzua6VDiJtDjAdNH6Gik3hUtKc2BuA3J2I8GANACWDXFYhn1mcULjGwGGtzNGaL9KSo1uniQ4U55nEnx)kT5CuAB8QbpK8p9harTtRhEuZ42fNpjoyvpVxPN9NL8kbTAhXnzZhvUKE7Mu30zkhNZw)ti9FsvGLzZY3CSJRglXvSLxcAWYPGV)ztSeW)VOCMPovw4txOuHL0Muiiox)1FqFPVd(dhmOIyk5eg4K5mUiolsCgTxGJBPX()RGhmf493VHJNW2ixHkiatmFb(bmS90MV4r4OVK5G)9srrx66mJX(OgFroi)hWfqJcb8U7RRi(8x5)cxmf(Dyz)7cREdRcpYwS4neKwVPsk3tCQj5HTzdM1QyWBwAZZC9xgCrgeQj2khYgmcf6XMsRVJpyRTeilmtIbS8SHlHablkmsnqLiUtN5NCYlQ)lgOajwIP7Noujm(SoGcAmCPhBQtxey4kdpogFJWNxqjeGE6nnnURWYWZWQmGdq7n7dHIHSDi1wlzgWyn3XKdnYWOK0G4GelpnHC(sfuMlamas6K0zjQCPLbF8zO4NTrzZUT4MQnC1vH9scToRq5fC2paQKw5sRzk9cgci9)nKM6x0mqKZjdj7esNP2iDSPG52ShPSOOoTo46UAcsHcGTeSV16HS2KW3oRpUGbDx1eNFgAGrXvcqyCa(]] )


end