-- ShamanElemental.lua
-- 09.2020

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [x] Call of Flame
-- [-] High Voltage
-- [-] Pyroclastic Shock
-- [-] Shake the Foundations

-- Covenants
-- [-] Elysian Dirge
-- [-] Lavish Harvest
-- [-] Tumbling Waves
-- [x] Essential Extraction

-- Endurance
-- [-] Astral Protection
-- [-] Refreshing Waters
-- [x] Vital Accretion

-- Finesse
-- [x] Crippling Hex
-- [x] Spiritual Resonance
-- [x] Thunderous Paws
-- [x] Totemic Surge


if UnitClassBase( "player" ) == "SHAMAN" then
    local spec = Hekili:NewSpecialization( 262, true )

    spec:RegisterResource( Enum.PowerType.Maelstrom )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        earthen_rage = 22356, -- 170374
        echo_of_the_elements = 22357, -- 333919
        static_discharge = 22358, -- 342243

        aftershock = 23108, -- 273221
        echoing_shock = 23460, -- 320125
        elemental_blast = 23190, -- 117014

        spirit_wolf = 23162, -- 260878
        earth_shield = 23163, -- 974
        static_charge = 23164, -- 265046

        master_of_the_elements = 19271, -- 16166
        storm_elemental = 19272, -- 192249
        liquid_magma_totem = 19273, -- 192222

        natures_guardian = 22144, -- 30884
        ancestral_guidance = 22172, -- 108281
        wind_rush_totem = 21966, -- 192077

        surge_of_power = 22145, -- 262303
        primal_elementalist = 19266, -- 117013
        icefury = 23111, -- 210714

        unlimited_power = 21198, -- 260895
        stormkeeper = 22153, -- 191634
        ascendance = 21675, -- 114050
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        control_of_lava = 728, -- 204393
        counterstrike_totem = 3490, -- 204331
        grounding_totem = 3620, -- 204336
        lightning_lasso = 731, -- 305483
        seasoned_winds = 5415, -- 355630
        skyfury_totem = 3488, -- 204330
        spectral_recovery = 3062, -- 204261
        static_field_totem = 727, -- 355580
        swelling_waves = 3621, -- 204264
        traveling_storms = 730, -- 204403
        unleash_shield = 3491, -- 356736
    } )

    -- Auras
    spec:RegisterAuras( {
        ancestral_guidance = {
            id = 108281,
            duration = 10,
            max_stack = 1,
        },

        ascendance = {
            id = 114050,
            duration = 15,
            max_stack = 1,
        },

        astral_shift = {
            id = 108271,
            duration = function () return level > 53 and 12 or 8 end,
            max_stack = 1,
        },

        celestial_guidance = {
            id = 324748,
            duration = 10,
            max_stack = 1,
        },

        earth_shield = {
            id = 974,
            duration = 600,
            type = "Magic",
            max_stack = 9,
        },

        earthbind = {
            id = 3600,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        -- might be the debuff on targets
        earthquake = {
            id = 61882,
            duration = 3600,
            max_stack = 1,
        },

        echoing_shock = {
            id = 320125,
            duration = 8,
            max_stack = 1,
        },

        elemental_blast = {
            duration = 10,
            type = "Magic",
            max_stack = 3,
            generate = function ()
                local eb = buff.elemental_blast

                local count = ( buff.elemental_blast_critical_strike.up and 1 or 0 ) +
                              ( buff.elemental_blast_haste.up and 1 or 0 ) +
                              ( buff.elemental_blast_mastery.up and 1 or 0 )
                local applied = max( buff.elemental_blast_critical_strike.applied,
                                buff.elemental_blast_haste.applied,
                                buff.elemental_blast_mastery.applied )

                eb.name = class.abilities.elemental_blast.name or "Elemental Blast"
                eb.count = count
                eb.applied = applied
                eb.expires = applied + 15
                eb.caster = count > 0 and "player" or "nobody"
            end
        },

        elemental_blast_critical_strike = {
            id = 118522,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        elemental_blast_haste = {
            id = 173183,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        elemental_blast_mastery = {
            id = 173184,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        elemental_fury = {
            id = 60188,
        },

        far_sight = {
            id = 6196,
            duration = 60,
            max_stack = 1,
        },

        flame_shock = {
            id = 188389,
            duration = function () return level > 58 and ( fire_elemental.up or storm_elemental.up ) and 36 or 18 end,
            tick_time = function () return 3 * haste end,
            type = "Magic",
            max_stack = 1,
        },

        fleshcraft = {
            id = 324631,
            duration = 120,
            max_stack = 1,
        },

        frost_shock = {
            id = 196840,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        ghost_wolf = {
            id = 2645,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
        },

        icefury = {
            id = 210714,
            duration = 15,
            max_stack = 4,
        },

        lava_surge = {
            id = 77762,
            duration = 10,
            max_stack = 1,
        },

        lightning_lasso = {
            id = 305484,
            duration = 5,
            max_stack = 1
        },

        lightning_shield = {
            id = 192106,
            duration = 1800,
            type = "Magic",
            max_stack = 1,
        },

        master_of_the_elements = {
            id = 260734,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },

        primordial_wave = {
            id = 327164,
            duration = 15,
            max_stack = 1,
        },

        reincarnation = {
            id = 20608,
        },

        spirit_wolf = {
            id = 260881,
            duration = 3600,
            max_stack = 4,
        },

        spiritwalkers_grace = {
            id = 79206,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },

        static_discharge = {
            id = 342243,
            duration = 3,
            max_stack = 1,
        },

        stormkeeper = {
            id = 191634,
            duration = 15,
            max_stack = 2,
        },

        surge_of_power = {
            id = 285514,
            duration = 15,
            max_stack = 1,
        },

        surge_of_power_debuff = {
            id = 285515,
            duration = 6,
            max_stack = 1,
        },

        thunderstorm = {
            id = 51490,
            duration = 5,
            max_stack = 1,
        },

        unlimited_power = {
            id = 272737,
            duration = 10,
            max_stack = 20, -- good luck reaching this...
        },

        water_walking = {
            id = 546,
            duration = 600,
            max_stack = 1,
        },

        wind_rush = {
            id = 192082,
            duration = 5,
            max_stack = 1,
        },

        wind_gust = {
            id = 263806,
            duration = 30,
            max_stack = 20
        },


        -- Pet aura.
        call_lightning = {
            duration = 15,
            generate = function( t, db )
                if storm_elemental.up then
                    local name, _, count, _, duration, expires = FindUnitBuffByID( "pet", 157348 )

                    if name then
                        t.count = count
                        t.expires = expires
                        t.applied = expires - duration
                        t.caster = "pet"
                        return
                    end
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,
        },


        -- Legendaries
        -- TODO:  Implement like Bloodtalons, but APL doesn't really require it mechanically.
        elemental_equilibrium = {
            id = 347348,
            duration = 10,
            max_stack = 1
        },

        elemental_equilibrium_debuff = {
            id = 347349,
            duration = 30,
            max_stack = 1
        }
    } )


    -- Pets
    spec:RegisterPet( "primal_storm_elemental", 77942, "storm_elemental", function() return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) end )
    spec:RegisterTotem( "greater_storm_elemental", 1020304 ) -- Texture ID

    spec:RegisterPet( "primal_fire_elemental", 61029, "fire_elemental", function() return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) end )
    spec:RegisterTotem( "greater_fire_elemental", 135790 ) -- Texture ID

    spec:RegisterPet( "primal_earth_elemental", 61056, "earth_elemental", 60 )
    spec:RegisterTotem( "greater_earth_elemental", 136024 ) -- Texture ID

    spec:RegisterTotem( "liquid_magma_totem", 971079 )
    spec:RegisterTotem( "tremor_totem", 136108 )
    spec:RegisterTotem( "vesper_totem", 3565451 )
    spec:RegisterTotem( "wind_rush_totem", 538576 )


    spec:RegisterStateTable( "fire_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == "cast_time" then
                t.cast_time = class.abilities.fire_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_fire_elemental or pet.greater_fire_elemental

            if k == "active" or k == "up" then
                return elem.up

            elseif k == "down" then
                return not elem.up

            elseif k == "remains" then
                return max( 0, elem.remains )

            end

            return false
        end
    } ) )

    spec:RegisterStateTable( "storm_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == "cast_time" then
                t.cast_time = class.abilities.storm_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_storm_elemental or pet.greater_storm_elemental

            if k == "active" or k == "up" then
                return elem.up

            elseif k == "down" then
                return not elem.up

            elseif k == "remains" then
                return max( 0, elem.remains )

            end

            return false
        end
    } ) )

    spec:RegisterStateTable( "earth_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == "cast_time" then
                t.cast_time = class.abilities.earth_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_earth_elemental or pet.greater_earth_elemental

            if k == "active" or k == "up" then
                return elem.up

            elseif k == "down" then
                return not elem.up

            elseif k == "remains" then
                return max( 0, elem.remains )

            end

            return false
        end
    } ) )


    spec:RegisterHook( "reset_precast", function ()
        if talent.master_of_the_elements.enabled and action.lava_burst.in_flight and buff.master_of_the_elements.down then
            applyBuff( "master_of_the_elements" )
        end

        rawset( state.pet, "earth_elemental", talent.primal_elementalist.enabled and state.pet.primal_earth_elemental or state.pet.greater_earth_elemental )
        rawset( state.pet, "fire_elemental",  talent.primal_elementalist.enabled and state.pet.primal_fire_elemental  or state.pet.greater_fire_elemental  )
        rawset( state.pet, "storm_elemental", talent.primal_elementalist.enabled and state.pet.primal_storm_elemental or state.pet.greater_storm_elemental )
    end )


    -- Abilities
    spec:RegisterAbilities( {
        ancestral_guidance = {
            id = 108281,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            talent = "ancestral_guidance",
            toggle = "defensives",

            startsCombat = false,
            texture = 538564,

            handler = function ()
                applyBuff( "ancestral_guidance" )
            end,
        },

        ancestral_spirit = {
            id = 2008,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = false,
            texture = 136077,

            handler = function ()
            end,
        },

        ascendance = {
            id = 114050,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            talent = "ascendance",
            toggle = "cooldowns",

            startsCombat = false,
            texture = 135791,

            handler = function ()
                applyBuff( "ascendance" )
                gainCharges( "lava_burst", 2 )
            end,
        },

        astral_recall = {
            id = 556,
            cast = function () return 10 * haste end,
            cooldown = 600,
            gcd = "spell",

            startsCombat = false,
            texture = 136010,

            handler = function ()
            end,
        },

        astral_shift = {
            id = 108271,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 538565,

            handler = function ()
                applyBuff( "astral_shift" )
            end,
        },

        bloodlust = {
            id = 2825,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.22,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136012,

            handler = function ()
                applyBuff( "bloodlust" )
                applyDebuff( "player", "sated" )
                if conduit.spiritual_resonance.enabled then
                    applyBuff( "spiritwalkers_grace", conduit.spiritual_resonance.mod * 0.001 )
                end
            end,
        },

        capacitor_totem = {
            id = 192058,
            cast = 0,
            cooldown = function () return 60 + ( conduit.totemic_surge.mod * 0.001 ) end,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = false,
            texture = 136013,

            handler = function ()
            end,
        },

        --[[ chain_harvest = {
            id = 320674,
            cast = function () return 2.5 * haste end,
            cooldown = 90,
            gcd = "spell",

            toggle = "covenant",

            startsCombat = true,
            texture = 3565725,

            handler = function ()
            end,
        }, ]]

        chain_heal = {
            id = 1064,
            cast = function ()
                if buff.chains_of_devastation_ch.up then return 0 end
                return 2.5 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 136042,

            handler = function ()
                removeBuff( "chains_of_devastation_ch" )
                removeBuff( "echoing_shock" )

                if legendary.chains_of_devastation.enabled then
                    applyBuff( "chains_of_devastation_cl" )
                end
            end,
        },

        chain_lightning = {
            id = 188443,
            cast = function () return ( buff.stormkeeper.up or buff.chains_of_devastation_cl.up ) and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            nobuff = "ascendance",
            bind = "lava_beam",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136015,

            handler = function ()
                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )
                removeBuff( "chains_of_devastation_cl" )

                if legendary.chains_of_devastation.enabled then
                    applyBuff( "chains_of_devastation_ch" )
                end

                -- 4 MS per target, direct.
                -- 3 MS per target, overload.

                gain( ( buff.stormkeeper.up and 7 or 4 ) * min( 5, active_enemies ), "maelstrom" )
                removeStack( "stormkeeper" )

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end
            end,
        },

        cleanse_spirit = {
            id = 51886,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 236288,

            handler = function ()
            end,
        },

        earth_elemental = {
            id = 198103,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136024,

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_earth_elemental" or "greater_earth_elemental", 60 )
                if conduit.vital_accretion.enabled then
                    applyBuff( "vital_accretion" )
                    health.max = health.max * ( 1 + ( conduit.vital_accretion.mod * 0.01 ) )
                end
            end,

            usable = function ()
                return max( cooldown.fire_elemental.true_remains, cooldown.storm_elemental.true_remains ) > 0, "DPS elementals must be on CD first"
            end,

            timeToReady = function ()
                return max( pet.fire_elemental.remains, pet.storm_elemental.remains, pet.primal_fire_elemental.remains, pet.primal_storm_elemental.remains )
            end,

            auras = {
                -- Conduit
                vital_accretion = {
                    id = 337984,
                    duration = 60,
                    max_stack = 1
                }
            }
        },

        earth_shield = {
            id = 974,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            talent = "earth_shield",

            startsCombat = false,
            texture = 136089,

            handler = function ()
                applyBuff( "earth_shield" )
            end,
        },

        earth_shock = {
            id = 8042,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 60,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 136026,

            handler = function ()
                if talent.surge_of_power.enabled then
                    applyBuff( "surge_of_power" )
                end

                if runeforge.echoes_of_great_sundering.enabled then
                    applyBuff( "echoes_of_great_sundering" )
                end

                if runeforge.windspeakers_lava_resurgence.enabled then
                    applyBuff( "lava_surge" )
                    applyBuff( "windspeakers_lava_resurgence" )
                end

                removeBuff( "echoing_shock" )
            end,

            auras = {
                windspeakers_lava_resurgence = {
                    id = 336065,
                    duration = 15,
                    max_stack = 1,
                },
            }
        },

        earthbind_totem = {
            id = 2484,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136102,

            handler = function ()
            end,
        },

        earthquake = {
            id = 61882,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 60,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 451165,

            handler = function ()
                removeBuff( "echoes_of_great_sundering" )
                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )
            end,

            auras = {
                echoes_of_great_sundering = {
                    id = 336217,
                    duration = 25,
                    max_stack = 1
                }
            }
        },

        echoing_shock = {
            id = 320125,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 1603013,

            talent = "echoing_shock",

            handler = function ()
                applyBuff( "echoing_shock" )
            end,
        },

        elemental_blast = {
            id = 117014,
            cast = function () return 2 * haste end,
            cooldown = 12,
            gcd = "spell",

            spend = -30,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 651244,

            handler = function ()
                applyBuff( "elemental_blast" )

                if talent.surge_of_power.enabled then
                    applyBuff( "surge_of_power" )
                end

                if runeforge.echoes_of_great_sundering.enabled then
                    applyBuff( "echoes_of_great_sundering" )
                end

                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )
            end,
        },

        far_sight = {
            id = 6196,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 136034,

            handler = function ()
            end,
        },

        fire_elemental = {
            id = 198067,
            cast = 0,
            charges = 1,
            cooldown = 150,
            recharge = 150,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            toggle = "cooldowns",
            notalent = "storm_elemental",

            startsCombat = false,
            texture = 135790,


            timeToReady = function ()
                return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.storm_elemental.remains, pet.primal_storm_elemental.remains )
            end,            

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental" )
            end,
        },

        flame_shock = {
            id = 188389,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135813,

            cycle = "flame_shock",
            min_ttd = function () return debuff.flame_shock.duration / 3 end,

            handler = function ()
                applyDebuff( "target", "flame_shock" )

                if buff.surge_of_power.up then
                    active_dot.surge_of_power = min( active_enemies, active_dot.flame_shock + 1 )
                    removeBuff( "surge_of_power" )
                end

                removeBuff( "echoing_shock" )
            end,
        },

        frost_shock = {
            id = 196840,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135849,

            handler = function ()
                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )

                applyDebuff( "target", "frost_shock" )

                if buff.icefury.up then
                    gain( 8, "maelstrom" )
                    removeStack( "icefury", 1 )
                end

                if buff.surge_of_power.up then
                    applyDebuff( "target", "surge_of_power_debuff" )
                    removeBuff( "surge_of_power" )
                end
            end,
        },

        ghost_wolf = {
            id = 2645,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136095,

            handler = function ()
                applyBuff( "ghost_wolf" )
                if talent.spirit_wolf.enabled then applyBuff( "spirit_wolf" ) end
                if conduit.thunderous_paws.enabled then applyBuff( "thunderous_paws" ) end
            end,
        },

        healing_stream_totem = {
            id = 5394,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.09,
            spendType = "mana",

            startsCombat = true,
            texture = 135127,

            handler = function ()
            end,
        },

        healing_surge = {
            id = 8004,
            cast = function () return 1.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.24,
            spendType = "mana",

            startsCombat = false,
            texture = 136044,

            handler = function ()
                removeBuff( "echoing_shock" )
            end,
        },

        hex = {
            id = 51514,
            cast = function () return 1.7 * haste end,
            cooldown = function () return level > 55 and 20 or 30 end,
            gcd = "spell",

            startsCombat = false,
            texture = 237579,

            handler = function ()
                applyDebuff( "target", "hex" )
            end,

            auras = {
                -- Conduit
                crippling_hex = {
                    id = 338055,
                    duration = 8,
                    max_stack = 1
                }
            }
        },

        icefury = {
            id = 210714,
            cast = 2,
            cooldown = 30,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135855,

            talent = "icefury",

            handler = function ()
                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )

                applyBuff( "icefury", 15, 4 )
                gain( 25, "maelstrom" )
            end,
        },

        lava_beam = {
            id = 114074,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",

            buff = "ascendance",
            bind = "chain_lightning",

            startsCombat = true,
            texture = 236216,

            handler = function ()
                removeBuff( "echoing_shock" )

                -- 4 MS per target, direct.
                -- 3 MS per target, overload.

                gain( ( buff.stormkeeper.up and 7 or 4 ) * min( 5, active_enemies ), "maelstrom" )
                removeStack( "stormkeeper" )
            end,
        },

        lava_burst = {
            id = 51505,
            cast = function () return buff.lava_surge.up and 0 or ( 2 * haste ) end,
            charges = function () return talent.echo_of_the_elements.enabled and 2 or nil end,
            cooldown = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            recharge = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 237582,

            velocity = 30,

            handler = function ()
                removeBuff( "windspeakers_lava_resurgence" )
                removeBuff( "lava_surge" )
                removeBuff( "echoing_shock" )

                gain( 10, "maelstrom" )

                if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end

                if talent.surge_of_power.enabled then
                    gainChargeTime( "fire_elemental", 6 )
                    removeBuff( "surge_of_power" )
                end

                if buff.primordial_wave.up and state.spec.elemental and legendary.splintered_elements.enabled then
                    applyBuff( "splintered_elements", nil, active_dot.flame_shock )
                end
                removeBuff( "primordial_wave" )
            end,

            impact = function () end,  -- This + velocity makes action.lava_burst.in_flight work in APL logic.
        },

        lightning_bolt = {
            id = 188196,
            cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            essential = true,

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136048,

            handler = function ()
                removeBuff( "echoing_shock" )

                gain( ( buff.stormkeeper.up and 11 or 8 ) + ( buff.surge_of_power.up and 3 or 0 ), "maelstrom" )

                removeBuff( "master_of_the_elements" )
                removeBuff( "surge_of_power" )

                removeStack( "stormkeeper" )

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end
            end,
        },

        lightning_lasso = {
            id = 305483,
            cast = function () return 5 * haste end,
            channeled = true,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1385911,

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "lightning_lasso"
            end,

            start = function ()
                removeBuff( "echoing_shock" )
                applyDebuff( "target", "lightning_lasso" )
            end,

            copy = 305485
        },

        lightning_shield = {
            id = 192106,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136051,

            readyTime = function () return buff.lightning_shield.remains - 120 end,

            handler = function ()
                applyBuff( "lightning_shield" )
            end,
        },

        liquid_magma_totem = {
            id = 192222,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 971079,

            talent = "liquid_magma_totem",

            handler = function ()
                summonTotem( "liquid_magma_totem" )
            end,
        },

        primal_strike = {
            id = 73899,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.09,
            spendType = "mana",

            startsCombat = true,
            texture = 460956,

            handler = function ()
            end,
        },

        purge = {
            id = 370,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136075,

            toggle = "interrupts",
            interrupt = true,

            buff = "dispellable_magic",

            handler = function ()
                removeBuff( "dispellable_magic" )
            end,
        },

        spiritwalkers_grace = {
            id = 79206,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = true,
            texture = 451170,

            handler = function ()
                applyBuff( "spiritwalkers_grace" )
            end,
        },

        static_discharge = {
            id = 342243,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = off,
            texture = 135845,

            talent = "static_discharge",
            buff = "lightning_shield",

            handler = function ()
                applyBuff( "static_discharge" )
            end,
        },

        storm_elemental = {
            id = 192249,
            cast = 0,
            charges = 1,
            cooldown = 150,
            recharge = 150,
            gcd = "spell",

            toggle = "cooldowns",
            talent = "storm_elemental",

            startsCombat = true,
            texture = 2065626,

            timeToReady = function ()
                return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.fire_elemental.remains, pet.primal_fire_elemental.remains )
            end,            

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental" )
            end,
        },

        stormkeeper = {
            id = 191634,
            cast = function () return 1.5 * haste end,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 839977,

            talent = "stormkeeper",

            handler = function ()
                applyBuff( "stormkeeper", 20, 2 )
            end,
        },

        thunderstorm = {
            id = 51490,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 237589,

            handler = function ()
                if target.within10 then applyDebuff( "target", "thunderstorm" ) end
            end,
        },

        tremor_totem = {
            id = 8143,
            cast = 0,
            cooldown = function () return 60 + ( conduit.totemic_surge.mod * 0.001 ) end,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136108,

            handler = function ()
                summonTotem( "tremor_totem" )
            end,
        },

        water_walking = {
            id = 546,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 135863,

            handler = function ()
                applyBuff( "water_walking" )
            end,
        },

        wind_rush_totem = {
            id = 192077,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 538576,

            talent = "wind_rush_totem",

            handler = function ()
                summonTotem( "wind_rush_totem" )
            end,
        },

        wind_shear = {
            id = 57994,
            cast = 0,
            cooldown = 12,
            gcd = "spell",

            startsCombat = true,
            texture = 136018,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        -- Pet Abilities
        meteor = {
            id = 117588,
            known = function () return talent.primal_elementalist.enabled and not talent.storm_elemental.enabled and fire_elemental.up end,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            startsCombat = true,
            texture = 1033911,

            talent = "primal_elementalist",

            usable = function () return fire_elemental.up end,
            handler = function () end,
        },

        eye_of_the_storm = {
            id = 157375,
            known = function () return talent.primal_elementalist.enabled and talent.storm_elemental.enabled and storm_elemental.up end,
            cast = 0,
            cooldown = 40,
            gcd = "off",

            startsCombat = true,
            -- texture = ,

            talent = "primal_elementalist",

            usable = function () return storm_elemental.up end,
            handler = function () end,
        },


        -- Shaman - Kyrian    - 324386 - vesper_totem         (Vesper Totem)
        vesper_totem = {
            id = 324386,
            cast = 0,
            cooldown = 60,
            gcd = "totem",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 3565451,

            toggle = "essences",

            handler = function ()
                summonPet( "vesper_totem", 30 )
            end,
        },

        -- Shaman - Necrolord - 326059 - primordial_wave      (Primordial Wave)
        primordial_wave = {
            id = 326059,
            cast = 0,
            cooldown = 45,
            recharge = 45,
            charges = 1,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 3578231,

            toggle = "essences",

            cycle = "flame_shock",
            velocity = 45,

            impact = function ()
                applyDebuff( "target", "flame_shock" )
                applyBuff( "primordial_wave" )
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            auras = {
                primordial_wave = {
                    id = 327164,
                    duration = 15,
                    max_stack = 1
                },
                splintered_elements = {
                    id = 354648,
                    duration = 10,
                    max_stack = 10,
                },
            }
        },

        -- Shaman - Night Fae - 328923 - fae_transfusion      (Fae Transfusion)
        fae_transfusion = {
            id = 328923,
            cast = function () return haste * 3 * ( 1 + ( conduit.essential_extraction.mod * 0.01 ) ) end,
            channeled = true,
            cooldown = 120,
            gcd = "spell",

            spend = 0.075,
            spendType = "mana",

            startsCombat = true,
            texture = 3636849,

            toggle = "essences",
            nobuff = "fae_transfusion",

            start = function ()
                applyBuff( "fae_transfusion" )
            end,

            tick = function ()
                if legendary.seeds_of_rampant_growth.enabled then
                    if state.spec.enhancement then reduceCooldown( "feral_spirit", 9 )
                    elseif state.spec.elemental then reduceCooldown( talent.storm_elemental.enabled and "storm_elemental" or "fire_elemental", 6 )
                    else reduceCooldown( "healing_tide_totem", 5 ) end
                    addStack( "seeds_of_rampant_growth" )
                end
            end,

            finish = function ()
                if state.spec.enhancement then addStack( "maelstrom_weapon", nil, 3 ) end
            end,

            auras = {
                fae_transfusion = {
                    id = 328933,
                    duration = 20,
                    max_stack = 1
                },
                seeds_of_rampant_growth = {
                    id = 358945,
                    duration = 15,
                    max_stack = 5
                }
            },
        },

        fae_transfusion_heal = {
            id = 328930,
            cast = 0,
            channeled = true,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 3636849,

            buff = "fae_transfusion",

            handler = function ()
                removeBuff( "fae_transfusion" )
            end,
        },

        -- Shaman - Venthyr   - 320674 - chain_harvest        (Chain Harvest)
        chain_harvest = {
            id = 320674,
            cast = 2.5,
            cooldown = 90,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 3565725,

            toggle = "essences",

            handler = function ()
                if legendary.elemental_conduit.enabled then                    
                    applyDebuff( "target", "flame_shock" )
                    active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + min( 5, active_enemies ) )
                end
            end,
        }


    } )


    --[[ spec:RegisterSetting( "funnel_damage", false, {
        name = "Funnel AOE -> Target",
        desc = function ()
            local s = "If checked, the addon's default priority will encourage you to spread |T135813:0|t Flame Shock but will focus damage on your current target, using |T136026:0|t Earth Shock rather than |T451165:0|t Earthquake."

            if not Hekili.DB.profile.specs[ state.spec.id ].cycle then
                s = s .. "\n\n|cFFFF0000Requires 'Recommend Target Swaps' on Targeting tab.|r"
            end

            return s
        end,
        type = "toggle",
        width = 1.5
    } ) ]]


    spec:RegisterStateExpr( "funneling", function ()
        return false
        -- return active_enemies > 1 and settings.cycle and settings.funnel_damage
    end )


    spec:RegisterSetting( "stack_buffer", 1.1, {
        name = "|T135855:0|t Icefury and |T839977:0|t Stormkeeper Padding",
        desc = "The default priority tries to avoid wasting |T839977:0|t Stormkeeper and |T135855:0|t Icefury stacks with a grace period of 1.1 GCD per stack.\n\n" ..
                "Increasing this number will reduce the likelihood of wasted Icefury / Stormkeeper stacks due to other procs taking priority, and leave you with more time to react.",
        type = "range",
        min = 1,
        max = 2,
        step = 0.01,
        width = "full"
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageDots = true,
        damageExpiration = 8,

        potion = "potion_of_spectral_intellect",

        package = "Elemental",
    } )

    --[[ spec:RegisterSetting( "micromanage_pets", true, {
        name = "Micromanage Primal Elemental Pets",
        desc = "If checked, Meteor, Eye of the Storm, etc. will appear in your recommendations.",
        type = "toggle",
        width = 1.5
    } ) ]]

    spec:RegisterPack( "Elemental", 20211207, [[dGKKecqiKkpsqPAta1NaIQrjQ0PevSkbf9krkZsq1TaII2fk)se1Wqs5yivTmrQEgqKPHKQUgscBtqjFtqbJdjv6Cck06qsfMhq4EiX(asoisIuluq8qKurtejrsxejr5JarHojquALiLMjsI4MckLyNif)ejrILkOuQNIOPkICvbLs6RarbJvqPyVu8xIgSqhMQfdPhtPjJWLv2Su(mGrlWPv51IWSv1THy3s(nQgUOCCKKwouph00jDDPA7IQ(oqQXJKO68csZxKSFcBO3KKHKW1zOjDQLo90No1cdS0bP0PE6PEdPgA2mKzUnHdmdz5iZqsL9dzL6VHmZd95oHjjdjK3X2zidundsDKCYaNg0rzwosYWdP)UE8YI9MMm8qSjBir73RGSLb1qs46m0Ko1sNE6tNAHbw6Gu6up9PBiHzZAOj9WkDdzWrqSYGAijg0AiPY(HSs9xejdCeVe0sdp)qqhwePhKcxetNAPtVGwbTuNbEbmi1HGwqMIiiBz54mo21jIWP6vaqguDBcjAV1gweBCSicYAxRJdnCrKu5yKeBzdZe0cYuePstqiIHTmDCSi6fHisLf6erEte1GjIKkhJiIoGFfZqMH5T7NHmSh2frQSFiRu)frYahXlbTH9WUisdp)qqhwePhKcxetNAPtVGwbTH9WUisDg4fWGuhcAd7HDreKPicYwwooJJDDIiCQEfaKbv3MqI2BTHfXghlIGS2164qdxejvogjXw2WmbTH9WUicYuePstqiIHTmDCSi6fHisLf6erEte1GjIKkhJiIoGFftqRG2WUisLrLpBxhHiU8dhQiQhYernyIOBvowepOi6597D0FmbTUvpEbzz4z5iOUszowdK7hYk1)WVgf6u)xPSm8H4VC)qwP(FqLTYr)riOnSlIHTcNisQCmsITSHfXm8SCeuxfXE9dcfrihzIOtqafrqF)lIWmh0Lic58IjO1T6Xlildplhb110OKC7hmWI9Mg(1Oa59h9kcwwhQ9FYH7z6XRuPG8(JEfblp)D9(jH8p)kvqRB1JxqwgEwocQRPrjzOYXij2Ygo8Rrr9FLYGkhJKylBy2kh9hb4CX(rix(vkZjiGmlVxkiaPuPW(rix(vkZjiGSRafvqTCe06w94fKLHNLJG6AAusUD4j3pKvQ)cADRE8cYYWZYrqDnnkjVFiRu)LOVd1WVgf1)vkB)qwP(lrFhQSvo6pcWWS9VuDmWuiZg4xj)diqRRaabijOnSlIHmR3HtePsYhIig4qr0frf753lI6HSWfrnyIOtqWlrm7D7GIyyQbhuexP4qdtrKxIi1jvQIyJJfrqseHZYlcOiQCr0ZZpcrKG3r)bYKkjFiIiVeXS()mbTUvpEbzz4z5iOUMgLKFpVlr7yOg(F1KwckGu4xJcDQ)Ru2(HSs9xI(ouzRC0FeGHz7FP6yGPqMnWVs(hqGwxbacqkvk0ERXGkhJKylBywptqRB1JxqwgEwocQRPrjzBGFL8pGaTUci8RrHo1)vkB)qwP(lrFhQSvo6pcWWS9VuDmWuiZg4xj)diqRRaaffqcmDO9wJbvogjXw2WSEMGw3QhVGSm8SCeuxtJsYzC94LGwbTHDreKT0HX9mve5nr06qfYe06w94fmnkjd6RiKWG5ybTUvpEbtJsYWSdFkO9pXWqja2TlCeE(RaOqVGw3QhVGPrj5mUE8sqRB1JxW0OKCho5PdbkO1T6XlyAusU9oYKWaUnr4xJsU0P(Vsz7hYk1Fj67qLTYr)rKdy60ZM4kaW0LnLbvogrUFiRu)zUvV8dCUWS9VuDmWuiZg4xj)diqRRaabiLkL6)kLH4qDyjVj1Gj3pKvkKTYr)rKkfUxRXXaJbtekkEEIHHY2nCOsIHCWXgv7xw2iYrqRB1JxW0OKCg(q4yIZFjO98lCBO2Fs1XatHuOp8RrHo0ERXYWhchtC(lbTNFSEg4CPlBkdQCmIC)qwP(ZCRE5xQuWS9VuDmWuiZg4xj)diqRRaabibgT3AmqFfHeOdvguDBcqKo1sLcY7p6veSFoHenu5OYDKSFSvo6pICaNlmB)lvhdmfYSb(vY)ac06kaqqfPsP(VsziouhwYBsnyY9dzLczRC0FePsH71ACmWyWeHIINNyyOSDdhQKyihCSr1(LLnIuPG8(JEfb7NtirdvoQChj7hBLJ(JihbTUvpEbtJsYT3rMegWTjc)AuOtpBIRaaNlDztzqLJrK7hYk1FMB1l)sLcMT)LQJbMcz2a)k5FabADfaiajWO9wJb6RiKaDOYGQBtaI0PwoGZfMT)LQJbMcz2a)k5FabADfaiaPuPu)xPmehQdl5nPgm5(HSsHSvo6pIuPW9AnogymyIqrXZtmmu2UHdvsmKdo2OA)YYgrocADRE8cMgLKBhEY9dzL6VGw3QhVGPrjzKPJJf06w94fmnkjJ(CoHS1XHg(1OqN6)kL5q7kcVSJTYr)rKkfAV1yo0UIWl7y9SuPSC(tWbDXCODfHx2XWdXVcckQGAcADRE8cMgLKrhgoCIRac)AuOt9FLYCODfHx2Xw5O)isLcT3AmhAxr4LDSEMGw3QhVGPrj52Hh6Z5eHFnk0P(Vszo0UIWl7yRC0FePsH2BnMdTRi8YowplvklN)eCqxmhAxr4LDm8q8RGGIkOMGw3QhVGPrjzVSdQy)Lw))WVgf6u)xPmhAxr4LDSvo6pIuPq7TgZH2veEzhRNLkLLZFcoOlMdTRi8YogEi(vqqrfutqRB1JxW0OKmQdi5nPIpBcy4xJcDQ)RuMdTRi8Yo2kh9hrQu0H2BnMdTRi8YowptqRB1JxW0OKC(bZgwQCDicADRE8cMgLKB(Kk2lyRdpEf(1Oy55x5LYQdiqLnFGPd3R14yGXGBeqjVjXosMxQeaZbTgWgv7xw2iaNlDQ)RugId1HL8MudMC)qwPq2kh9hrQuO9wJH4qDyjVj1Gj3pKvkK1ZYbmmB)lvhdmfYSb(vY)ac06kaqascADRE8cMgLKB(Kk2lyRdpEf(1Oy55x5LYQdiqLnFGX9Anogym4gbuYBsSJK5LkbWCqRbSr1(LLncW5sN6)kLH4qDyjVj1Gj3pKvkKTYr)rKkfAV1yiouhwYBsnyY9dzLcz9SuPGz7FP6yGPqMnWVs(hqGwxbakkGuoGZ1Y5pbh0fRD4j3pKvQ)m8q8RGGkDQLkLLZFcoOlgu5ye5(HSs9NHhIFfeuPtTCe06w94fmnkjJ7L0T6Xl5Fqn8YrgfNVWHk(Skf6d)AuCRE5NC1qUbbv6GZfMT)LQJbMcz2a)k5FabADfaOspvky2(xQogykK9EExIohbuPNJGw3QhVGPrjzCVKUvpEj)dQHxoYOaVc4NuDmW0WHk(Skf6d)AuOt9FLYGkhJi3pKvQ)Svo6pcWUvV8tUAi3GGGs6cADRE8cMgLKX9s6w94L8pOgE5iJcCs4va)KQJbMgouXNvPqF4xJI6)kLbvogrUFiRu)zRC0FeGDRE5NC1qUbbbL0f0kO1T6XliZ5Jcu5ye5(HSs9xqRB1JxqMZxAusEHojVj1GjHkhJe(1OG2BnM1)x(hqGwxbWWdXVcckk0tnbTUvpEbzoFPrj55ynGQDpXc)Auq7TgB2a(vasya3MG1Ze06w94fK58LgLKTb(vYahNFqvqRB1JxqMZxAusgQCmsITSHd)Auu)xPmOYXij2YgMTYr)riO1T6XliZ5lnkj3Ehzsya3MiCBO2Fs1XatHuOp8RrbVgEWah9h4CZ1T6LFscUYAVJmjmGBtaI0b7w9Yp5QHCdcckGeylN)eCqxSm8HWXeN)sq75hdpe)kiiOpSaB55x5LYQzX8NJjatx2ugu5ye5(HSs9N5w9YVuPCRE5NKGRS27itcd42eGGEWUvV8tUAi3GGIc1dMUSPmOYXiY9dzL6pZT6LFGv)xPmehQdl5nPgm5(HSsHSvo6pICsLkxCVwJJbgdMiuu88eddLTB4qLed5GJnQ2VSSraMUSPmOYXiY9dzL6pZT6LF5KJGw3QhVGmNV0OKC7DKjHbCBIWVgf6CRE5NKGRS27itcd42eGPlBkdQCmIC)qwP(ZCRE5h4Cv)xPmehQdl5nPgm5(HSsHSvo6pIuPW9AnogymyIqrXZtmmu2UHdvsmKdo2OA)YYgrocADRE8cYC(sJsYZgWVcqcd42eHFnkQ)Ru2Sb8RaKWaUnbBLJ(JamIVhQyocOOewudCU4ETghdm2Sb8bL8MeapxLWErm8vaSr1(LLncWO9wJnBaFqjVjbWZvjSxedFfaRNLkfD4ETghdm2Sb8bL8MeapxLWErm8vaSr1(LLnICe06w94fK58LgLKDODfHx2f(1OO(Vszo0UIWl7yRC0FeGZLUSPmOYXiY9dzL6pZT6LF5aox6u)xPSZUwhhkBLJ(Jivk6q7Tg7SR1XHY6zGPZY5pbh0f7SR1XHY6z5iO1T6XliZ5lnkj)hv7hHeXbqCPY1He(1OO(Vsz)r1(rirCaexQCDiSvo6pcbTUvpEbzoFPrjzBGFL8pGaTUci8RrbMT)LQJbMcz2a)k5FabADfaiOEWO9wJH4qDyjVj1Gj3pKvkK1ZaJ47HkMJacQGAcADRE8cYC(sJsYZXAGegWTjc)AuW9AnogySzd4dk5njaEUkH9Iy4RayJQ9llBeGPdT3ASzd4dk5njaEUkH9Iy4Ray9mbTUvpEbzoFPrj53Z7s0ogQHFnkeCL1Ehzsya3MGHhIFfemmB)lvhdmfYSb(vY)ac06kaqq9GZLUSPmOYXiY9dzL6pZT6LF5aox0ERXEpVlHDmWy9mW0H2BngId1HL8MudMC)qwPqwpdS6)kLH4qDyjVj1Gj3pKvkKTYr)rKJGw3QhVGmNV0OK8CSgq1UNyHFnkWS9VuDmWuiZg4xj)diqRRaafL0bthUxRXXaJnBaFqjVjbWZvjSxedFfaBuTFzzJaCUQ)RugId1HL8MudMC)qwPq2kh9hbyeFpuXCeqrHkOgy6q7TgdXH6WsEtQbtUFiRuiRNLJGw3QhVGmNV0OK875DjAhd1WVgfcUYAVJmjmGBtWWdXVccgT3AS3Z7syhdmwpdmAV1yz4dHJjo)LG2ZpwptqRB1JxqMZxAus(98UeTJHA4xJcbxzT3rMegWTjy4H4xbbdZ2)s1XatHmBGFL8pGaTUcaeupyCVwJJbgdMiuu88eddLTB4qLed5GJnQ2VSSragT3AS3Z7syhdmwpdS6)kLH4qDyjVj1Gj3pKvkKTYr)raMo0ERXqCOoSK3KAWK7hYkfY6zGr89qfZraffQGAcADRE8cYC(sJsYVN3LODmud)Aui4kR9oYKWaUnbdpe)ki4CZfMT)LQJbMcz2a)k5FabADfaiOEW4ETghdmgmrOO45jggkB3WHkjgYbhBuTFzzJaS6)kLH4qDyjVj1Gj3pKvkKTYr)rKtQu5Q(VsziouhwYBsnyY9dzLczRC0FeGr89qfZraffQGAGPdT3AmehQdl5nPgm5(HSsHSEg4CPd3R14yGXMnGpOK3Ka45Qe2lIHVcGnQ2VSSrKkfAV1yZgWhuYBsa8Cvc7fXWxbW6z5aMoCVwJJbgdMiuu88eddLTB4qLed5GJnQ2VSSrKtocADRE8cYC(sJsYVN3LODmud)Aui4kR9oYKWaUnbdpe)kiyy2(xQogykKzd8RK)beO1vauOEW4ETghdmgmrOO45jggkB3WHkjgYbhBuTFzzJamAV1yVN3LWogySEgy1)vkdXH6WsEtQbtUFiRuiBLJ(JamDO9wJH4qDyjVj1Gj3pKvkK1ZaJ47HkMJakkub1e06w94fK58LgLKNJ1aQ29el8RrbMT)LQJbMcz2a)k5FabADfaOOKUGw3QhVGmNV0OKSnWVs(hqGwxbe(1OG2Bngu5yKeBzdZWdXVcccqkmbSeHjAV1yqLJrsSLnmdQUnHGw3QhVGmNV0OK875DjAhd1WVgf0ERXEpVlHDmWy9mWWS9VuDmWuiZg4xj)diqRRaab1dox6YMYGkhJi3pKvQ)m3Qx(LdycUYAVJmjmGBtW0ZM4kabTUvpEbzoFPrj59dzL6Ve9DOg(1OO(Vsz7hYk1Fj67qLTYr)ragMT)LQJbMcz2a)k5FabADfaiOcW5sx2ugu5ye5(HSs9N5w9YVCe06w94fK58LgLKFpVlrNJe(1OO(Vszo0UIWl7yRC0FecADRE8cYC(sJsY2a)k5FabADfGGw3QhVGmNV0OK875DjAhd1Wr45VcGc9HFnkO9wJ9EExc7yGX6zGTC(tWbDjXZTQGw3QhVGmNV0OKC7DKjHbCBIWr45VcGc9HBd1(tQogykKc9HFnk41Wdg4O)e06w94fK58LgLKByouLWaUnr4i88xbqHEbTcADRE8cYGtcVc4NuDmWukqLJrK7hYk1FbTUvpEbzWjHxb8tQogyAAusEHojVj1GjHkhJe(1OG2BnM1)x(hqGwxbWWdXVcckk0tnbTUvpEbzWjHxb8tQogyAAusUH5qvcd42eHFnkQ)Ru2zxRJdLTYr)ragT3ASZUwhhkRNbgT3ASZUwhhkdpe)kiiGt1RaGmO62es0ERnCycyjct0ERXo7ADCOmO62eGr7Tgd0xrib6qLbv3Mae0tDf06w94fKbNeEfWpP6yGPPrj59dzL6Ve9DOg(1OO(Vsz7hYk1Fj67qLTYr)riO1T6Xlidoj8kGFs1XattJsYqLJrsSLnC4xJI6)kLbvogjXw2WSvo6pcbTUvpEbzWjHxb8tQogyAAusE2a(vasya3Mi8Rrr9FLYMnGFfGegWTjyRC0FeGTC(tWbDXEpVlr7yOYWdXVccckawcWWS9VuDmWuiZg4xj)diqRRaar6PsH47HkMJakkHf1adZ2)s1XatHmBGFL8pGaTUcauushCU0H71ACmWyZgWhuYBsa8Cvc7fXWxbWgv7xw2isLcT3ASzd4dk5njaEUkH9Iy4Ray9SCsLcMT)LQJbMcz2a)k5FabADfaishmAV1yG(kcjqhQmO62eGIc9uxW5shUxRXXaJnBaFqjVjbWZvjSxedFfaBuTFzzJivk0ERXMnGpOK3Ka45Qe2lIHVcG1ZYbmIVhQyocOOewutqRB1JxqgCs4va)KQJbMMgLKFpVlr7yOg(1OKlAV1yG(kcjqhQmO62eGGEQly6q7Tgd95CIVdvwplNuPq7Tg798Ue2XaJ1Ze06w94fKbNeEfWpP6yGPPrj53Z7s0ogQHFnkQ)Ru2Sb8RaKWaUnbBLJ(JamAV1yZgWVcqcd42eSEgyy2(xQogykKzd8RK)beO1vaGiDbTUvpEbzWjHxb8tQogyAAusEowdOA3tSWVgf1)vkB2a(vasya3MGTYr)ragT3ASzd4xbiHbCBcwpdmmB)lvhdmfYSb(vY)ac06kaqrjDbTUvpEbzWjHxb8tQogyAAus(pGaTUcqIYFn8RrbT3AmOYXij2YgM1Ze06w94fKbNeEfWpP6yGPPrj55ynGQDpXc)Auq7TgB2a(GsEtcGNRsyVig(kawptqRB1JxqgCs4va)KQJbMMgLKNJ1ajmGBte(1OaZ2)s1XatHmBGFL8pGaTUcaePdgX3dvmhbuuclQbox0ERXa9vesGouzq1Tjar6ulvkeFpuXCeqfgPwoPsLlUxRXXaJnBaFqjVjbWZvjSxedFfaBuTFzzJamDO9wJnBaFqjVjbWZvjSxedFfaRNLJGw3QhVGm4KWRa(jvhdmnnkjphRbuT7jw4xJsUWS9VuDmWuiZg4xj)diqRRaaf95aox6i4kR9oYKWaUnbdVgEWah9xocADRE8cYGtcVc4NuDmW00OKSnWVs(hqGwxbe(1O4w9Yp5QHCdck6bNnLbvogrUFiRu)zUvV8dmAV1yOpNt8DOY6zcADRE8cYGtcVc4NuDmW00OK8FabADfGeL)A4xJs2ugu5ye5(HSs9N5w9YpWO9wJH(CoX3HkRNjO1T6Xlidoj8kGFs1XattJsYVN3LODmud)Auq7TgZH2veEzhRNjO1T6Xlidoj8kGFs1XattJsYVN3LODmud)AuSC(tWbDjXZTQGw3QhVGm4KWRa(jvhdmnnkj)EExI2Xqn8RrXY5pbh0Lep3QGTbogyqqP(VszZgWL8MudMC)qwPq2kh9hHGw3QhVGm4KWRa(jvhdmnnkj3WCOkHbCBIWVgf1)vk7SR1XHYw5O)iaJ2Bn2zxRJdL1Ze06w94fKbNeEfWpP6yGPPrjzBGFLmWX5huf06w94fKbNeEfWpP6yGPPrj52pyGf7nn8R0HX9mLc9HFnkqE)rVIGLN)UE)Kq(NFLkO1T6Xlidoj8kGFs1XattJsYq11ZkjoOnWXal8Rrr9FLYGQRNvsCqBGJbgBLJ(JqqRB1JxqgCs4va)KQJbMMgLKNJ1a5(HSs9p8RrHo1)vkldFi(l3pKvQ)huzRC0FePsP(Vszz4dXF5(HSs9)GkBLJ(JaCU0LnLbvogrUFiRu)zUvV8lhbTUvpEbzWjHxb8tQogyAAus2g4xj)diqRRac)AuCRE5NC1qUbbf9GZfMT)LQJbMcz2a)k5FabADfaOOpvky2(xQogykK9EExIohbu0NJGw3QhVGm4KWRa(jvhdmnnkj)hqGwxbir5VkO1T6Xlidoj8kGFs1XattJsYT3rMegWTjchHN)kak0hUnu7pP6yGPqk0h(1OGxdpyGJ(tqRB1JxqgCs4va)KQJbMMgLKBVJmjmGBteocp)vauOp8RrbHNFiRugXbvVSduHLGw3QhVGm4KWRa(jvhdmnnkj3WCOkHbCBIWr45VcGc9cAf06w94fKbVc4NuDmWuk)beO1vasu(RHFnk5I2Bngu5yKeBzdZWdXVccc4u9kaidQUnHeT3AdhMawIWeT3AmOYXij2YgMbv3MihbTUvpEbzWRa(jvhdmnnkj3WCOkHbCBIWVgf1)vk7SR1XHYw5O)iaJ2Bn2zxRJdL1ZaJ2Bn2zxRJdLHhIFfeeWP6vaqguDBcjAV1gombSeHjAV1yNDToouguDBcbTUvpEbzWRa(jvhdmnnkj3Ehzsya3MiCBO2Fs1XatHuOp8Rrjx60ZM4kGuPi4kR9oYKWaUnbdpe)kiiOayjsLs9FLYCODfHx2Xw5O)iatWvw7DKjHbCBcgEi(vqqKRLZFcoOlMdTRi8YogEi(vW0q7TgZH2veEzhJOJD94voGTC(tWbDXCODfHx2XWdXVcccQphW5I2Bn275DjSJbgRNLkfDO9wJH(CoX3HkRNLJGw3QhVGm4va)KQJbMMgLKBVJmjmGBteUnu7pP6yGPqk0h(1OG2Bnwg(q4yIZFjO98J1ZaJxdpyGJ(tqRB1Jxqg8kGFs1XattJsYo0UIWl7c)Auu)xPmhAxr4LDSvo6pcW5QhYafLWIAPsH2Bng6Z5eFhQSEwoGZ1Y5pbh0f798UeTJHkdpe)kiOOwoGZLo1)vk7SR1XHYw5O)isLIo0ERXo7ADCOSEgy6SC(tWbDXo7ADCOSEwocADRE8cYGxb8tQogyAAus(98UeTJHA4xJcAV1yVN3LWogySEg4CX9AnogymqFfbmBEIHHY3Z7s8GDmWk7yJQ9llBePsrhAV1yiouhwYBsnyY9dzLcz9mWQ)RugId1HL8MudMC)qwPq2kh9hrocADRE8cYGxb8tQogyAAusE)qwP(lrFhQHFnkQ)Ru2(HSs9xI(ouzRC0FeGZfX3dvmhbeHbQLJGw3QhVGm4va)KQJbMMgLKHkhJKylB4WVgf1)vkdQCmsITSHzRC0FeGZf7hHC5xPmNGaYS8EPGaKsLc7hHC5xPmNGaYUcuub1YbCUi(EOI5iGG6P(Ce06w94fKbVc4NuDmW00OK8Sb8RaKWaUnr4xJI6)kLnBa)kajmGBtWw5O)iaB58NGd6I9EExI2XqLHhIFfeeuaSecADRE8cYGxb8tQogyAAus(98UeTJHA4xJI6)kLnBa)kajmGBtWw5O)iaJ2Bn2Sb8RaKWaUnbRNjO1T6XlidEfWpP6yGPPrj5)OA)iKioaIlvUoKWVgf1)vk7pQ2pcjIdG4sLRdHTYr)riO1T6XlidEfWpP6yGPPrj55ynGQDpXc)Auq7TgB2a(GsEtcGNRsyVig(kawpdS6)kLH4qDyjVj1Gj3pKvkKTYr)ragT3AmehQdl5nPgm5(HSsHSEMGw3QhVGm4va)KQJbMMgLK)diqRRaKO8xd)Auq7TgdQCmsITSHz9mWO9wJH4qDyjVj1Gj3pKvkK1ZaJ47HkMJaIWIAcADRE8cYGxb8tQogyAAusEowdOA3tSWVgf0ERXMnGpOK3Ka45Qe2lIHVcG1ZaNR6)kLH4qDyjVj1Gj3pKvkKTYr)raox0ERXqCOoSK3KAWK7hYkfY6zPsz58NGd6I9EExI2XqLHhIFfeuudmIVhQyocOOegtpvky2(xQogykKzd8RK)beO1vaGiDWO9wJbvogjXw2WSEgylN)eCqxS3Z7s0ogQm8q8RGGGcGLiNuPOt9FLYqCOoSK3KAWK7hYkfYw5O)isLYY5pbh0fB)qwP(lrFhQm8q8RGGGcCQEfaKbv3MqI2BTHdtalryMEocADRE8cYGxb8tQogyAAusEowdOA3tSWVgfy2(xQogykKzd8RK)beO1vaGIEW0rWvw7DKjHbCBcgEn8Gbo6pW0H71ACmWyZgWhuYBsa8Cvc7fXWxbWgv7xw2iaNlDQ)RugId1HL8MudMC)qwPq2kh9hrQuO9wJH4qDyjVj1Gj3pKvkK1ZsLYY5pbh0f798UeTJHkdpe)kiOOgyeFpuXCeqrjmMEocADRE8cYGxb8tQogyAAus(98UeTJHA4xJILZFcoOljEUvbNlDO9wJH4qDyjVj1Gj3pKvkK1ZaJ2Bn2zxRJdL1ZYrqRB1Jxqg8kGFs1XattJsYVN3LODmud)AuSC(tWbDjXZTkyBGJbgeuQ)Ru2SbCjVj1Gj3pKvkKTYr)raMo0ERXo7ADCOSEMGw3QhVGm4va)KQJbMMgLKFpVlr7yOg(1OO(VszZgWL8MudMC)qwPq2kh9hby6q7TgdXH6WsEtQbtUFiRuiRNbgX3dvmhbuuOcQbMo0ERXMnGpOK3Ka45Qe2lIHVcG1Ze06w94fKbVc4NuDmW00OK8CSgiHbCBIWVgLCX9AnogySzd4dk5njaEUkH9Iy4RayJQ9llBePsbZ2)s1XatHmBGFL8pGaTUcaePNd4Cv)xPmehQdl5nPgm5(HSsHSvo6pcW0H2Bn2Sb8bL8MeapxLWErm8vaSEg4Cr7TgdXH6WsEtQbtUFiRuiRNLkfIVhQyocOOegtpvky2(xQogykKzd8RK)beO1vaGiDWO9wJbvogjXw2WSEgylN)eCqxS3Z7s0ogQm8q8RGGGcGLiNuPOt9FLYqCOoSK3KAWK7hYkfYw5O)isLYY5pbh0fB)qwP(lrFhQm8q8RGGGcCQEfaKbv3MqI2BTHdtalryMEocADRE8cYGxb8tQogyAAusUH5qvcd42eHFnkQ)Ru2zxRJdLTYr)raw9FLYqCOoSK3KAWK7hYkfYw5O)iaJ2Bn2zxRJdL1ZaJ2BngId1HL8MudMC)qwPqwptqRB1Jxqg8kGFs1XattJsYVN3LODmud)Auq7TgZH2veEzhRNjO1T6XlidEfWpP6yGPPrj53Z7s0ogQHFnkwo)j4GUK45wfmDQ)RugId1HL8MudMC)qwPq2kh9hHGw3QhVGm4va)KQJbMMgLKp7ADCOHFnkQ)Ru2zxRJdLTYr)raMUCr89qfZrafirfGTC(tWbDXEpVlr7yOYWdXVccckulhbTUvpEbzWRa(jvhdmnnkj3WCOkHbCBIWVgf1)vk7SR1XHYw5O)iaJ2Bn2zxRJdL1ZaNlAV1yNDToougEi(vqqayjctQpmr7Tg7SR1XHYGQBtKkfAV1yqLJrsSLnmRNLkfDQ)RugId1HL8MudMC)qwPq2kh9hrocADRE8cYGxb8tQogyAAus(98UeTJHQGw3QhVGm4va)KQJbMMgLKBVJmjmGBteUnu7pP6yGPqk0h(1OGxdpyGJ(tqRB1Jxqg8kGFs1XattJsYnmhQsya3Mi8Rrb3R14yGX2pKvQ)Yr1(9hk(6iSr1(LLncW0H2Bn2(HSs9xoQ2V)qXxhrsm0ERX6zGPt9FLY2pKvQ)s03HkBLJ(JamDQ)Ru2Sb8RaKWaUnbBLJ(JqqRB1Jxqg8kGFs1XattJsYTFWal2BA4xPdJ7zkf6d)AuG8(JEfblp)D9(jH8p)kvqRB1Jxqg8kGFs1XattJsY2a)kzGJZpOkO1T6XlidEfWpP6yGPPrj5gMdvjmGBte(1OO(VszNDToou2kh9hby0ERXo7ADCOSEMGw3QhVGm4va)KQJbMMgLKHQRNvsCqBGJbw4xJI6)kLbvxpRK4G2ahdm2kh9hHGw3QhVGm4va)KQJbMMgLKNJ1a5(HSs9p8RrHo1)vkldFi(l3pKvQ)huzRC0FePsrx2uw7WtUFiRu)zUvV8tqRB1Jxqg8kGFs1XattJsY2a)k5FabADfq4xJcmB)lvhdmfYSb(vY)ac06kaqrVGw3QhVGm4va)KQJbMMgLK)diqRRaKO8xf06w94fKbVc4NuDmW00OKC7DKjHbCBIWr45VcGc9HBd1(tQogykKc9HFnk41Wdg4O)e06w94fKbVc4NuDmW00OKC7DKjHbCBIWr45VcGc9HFnki88dzLYioO6LDGkSe06w94fKbVc4NuDmW00OKCdZHQegWTjchHN)kak0lO1T6XlidEfWpP6yGPPrj5gMdvjmGBte(1OO(VszNDToou2kh9hby0ERXo7ADCOSEgy0ERXo7ADCOm8q8RGGaovVcaYGQBtir7T2WHjGLimr7Tg7SR1XHYGQBtyiZpm84LHM0Pw60tTWa1cdgsq746kaOHeKbQ0HTPbKLgqgPoerrmPGjIhsghRIyJJfrqo8kGFs1Xatb5IiEuTF4riIqoYerVRCexhHiAd8cyqMGwQKRMiMo1L6qePo5v(H1riIGCiV)OxrWcBa5IOYfrqoK3F0RiyHnSvo6pcqUi6QisLrLcvIiMl9u55We0kOfKbQ0HTPbKLgqgPoerrmPGjIhsghRIyJJfrqEgEwocQRGCrepQ2p8ierihzIO3voIRJqeTbEbmitqlvYvtetN6qePo5v(H1riIGCiV)OxrWcBa5IOYfrqoK3F0RiyHnSvo6pcqUiMl9u55We0sLC1eX0PoerQtELFyDeIiihY7p6veSWgqUiQCreKd59h9kcwydBLJ(JaKlIUkIuzuPqLiI5spvEombTcAbzGkDyBAazPbKrQdruetkyI4HKXXQi24yreKdNeEfWpP6yGPGCrepQ2p8ierihzIO3voIRJqeTbEbmitqlvYvtetNEQdrK6Kx5hwhHicYH8(JEfblSbKlIkxeb5qE)rVIGf2Ww5O)ia5IORIivgvkujIyU0tLNdtqRGwqwKmowhHisfIOB1JxI4FqfYe0Ai9UgWXgsYdP)UE8I6e7n1q(huHMKmKWRa(jvhdm1KKHg6njzix5O)imHyiT4th(CdzUIiAV1yqLJrsSLnmdpe)kOiccreovVcaYGQBtir7T2WIyykIawcrmmfr0ERXGkhJKylByguDBcrmhdPB1JxgY)ac06kajk)vJAOjDtsgYvo6pctigsl(0Hp3qQ(VszNDToou2kh9hHicwer7Tg7SR1XHY6zIiyreT3ASZUwhhkdpe)kOiccreovVcaYGQBtir7T2WIyykIawcrmmfr0ERXo7ADCOmO62egs3QhVmKnmhQsya3MWOgAajtsgYvo6pctigs3QhVmKT3rMegWTjmKw8PdFUHmxrKorupBIRaeXuPercUYAVJmjmGBtWWdXVckIGGIicyjeXuPer1)vkZH2veEzhBLJ(JqeblIeCL1Ehzsya3MGHhIFfuebHiMRiA58NGd6I5q7kcVSJHhIFfuetter7TgZH2veEzhJOJD94LiMJicweTC(tWbDXCODfHx2XWdXVckIGqePErmhreSiMRiI2Bn275DjSJbgRNjIPsjI0jIO9wJH(CoX3HkRNjI5yiTHA)jvhdmfAOHEJAOH6njzix5O)imHyiDRE8Yq2Ehzsya3MWqAXNo85gs0ERXYWhchtC(lbTNFSEMicweXRHhmWr)ziTHA)jvhdmfAOHEJAOHkmjzix5O)imHyiT4th(CdP6)kL5q7kcVSJTYr)riIGfXCfr9qMickkIyyrnrmvkreT3Am0NZj(ouz9mrmhreSiMRiA58NGd6I9EExI2XqLHhIFfuebLisnrmhreSiMRisNiQ(VszNDToou2kh9hHiMkLisNiI2Bn2zxRJdL1ZerWIiDIOLZFcoOl2zxRJdL1ZeXCmKUvpEziDODfHx2zudnHLjjd5kh9hHjedPfF6WNBir7Tg798Ue2XaJ1ZerWIyUIiUxRXXaJb6RiGzZtmmu(EExIhSJbwzhBuTFzzJqetLsePter7TgdXH6WsEtQbtUFiRuiRNjIGfr1)vkdXH6WsEtQbtUFiRuiBLJ(JqeZXq6w94LH898UeTJHQrn0egmjzix5O)imHyiT4th(CdP6)kLTFiRu)LOVdv2kh9hHicweZver89qfZrerqiIHbQjI5yiDRE8YqUFiRu)LOVdvJAOH6AsYqUYr)rycXqAXNo85gs1)vkdQCmsITSHzRC0FeIiyrmxre7hHC5xPmNGaYS8EPIiierqsetLseX(rix(vkZjiGSRerqjIub1eXCerWIyUIiIVhQyoIiccrK6PErmhdPB1JxgsOYXij2Yg2OgAcJMKmKRC0FeMqmKw8PdFUHu9FLYMnGFfGegWTjyRC0FeIiyr0Y5pbh0f798UeTJHkdpe)kOicckIiGLWq6w94LHC2a(vasya3MWOgAONAMKmKRC0FeMqmKw8PdFUHu9FLYMnGFfGegWTjyRC0FeIiyreT3ASzd4xbiHbCBcwpZq6w94LH898UeTJHQrn0qp9MKmKRC0FeMqmKw8PdFUHu9FLY(JQ9JqI4aiUu56qyRC0Fegs3QhVmK)r1(rirCaexQCDig1qd9PBsYqUYr)rycXqAXNo85gs0ERXMnGpOK3Ka45Qe2lIHVcG1ZerWIO6)kLH4qDyjVj1Gj3pKvkKTYr)riIGfr0ERXqCOoSK3KAWK7hYkfY6zgs3QhVmKZXAav7EIzudn0dsMKmKRC0FeMqmKw8PdFUHeT3AmOYXij2YgM1ZerWIiAV1yiouhwYBsnyY9dzLcz9mreSiI47HkMJiIGqedlQziDRE8Yq(hqGwxbir5VAudn0t9MKmKRC0FeMqmKw8PdFUHeT3ASzd4dk5njaEUkH9Iy4Ray9mreSiMRiQ(VsziouhwYBsnyY9dzLczRC0FeIiyrmxreT3AmehQdl5nPgm5(HSsHSEMiMkLiA58NGd6I9EExI2XqLHhIFfuebLisnreSiI47HkMJiIGIIiggtxetLseHz7FP6yGPqMnWVs(hqGwxbiIGqetxeblIO9wJbvogjXw2WSEMicweTC(tWbDXEpVlr7yOYWdXVckIGGIicyjeXCeXuPer6er1)vkdXH6WsEtQbtUFiRuiBLJ(JqetLseTC(tWbDX2pKvQ)s03Hkdpe)kOicckIiCQEfaKbv3MqI2BTHfXWuebSeIyykIPlI5yiDRE8YqohRbuT7jMrn0qpvysYqUYr)rycXqAXNo85gsy2(xQogykKzd8RK)beO1vaIiOer6frWIiDIibxzT3rMegWTjy41Wdg4O)erWIiDIiUxRXXaJnBaFqjVjbWZvjSxedFfaBuTFzzJqeblI5kI0jIQ)RugId1HL8MudMC)qwPq2kh9hHiMkLiI2BngId1HL8MudMC)qwPqwptetLseTC(tWbDXEpVlr7yOYWdXVckIGsePMicwer89qfZrerqrredJPlI5yiDRE8YqohRbuT7jMrn0qFyzsYqUYr)rycXqAXNo85gslN)eCqxs8CRkIGfXCfr6er0ERXqCOoSK3KAWK7hYkfY6zIiyreT3ASZUwhhkRNjI5yiDRE8Yq(EExI2Xq1OgAOpmysYqUYr)rycXqAXNo85gslN)eCqxs8CRkIGfrBGJbguebLiQ(VszZgWL8MudMC)qwPq2kh9hHicwePter7Tg7SR1XHY6zgs3QhVmKVN3LODmunQHg6PUMKmKRC0FeMqmKw8PdFUHu9FLYMnGl5nPgm5(HSsHSvo6pcreSisNiI2BngId1HL8MudMC)qwPqwpteblIi(EOI5iIiOOiIub1erWIiDIiAV1yZgWhuYBsa8Cvc7fXWxbW6zgs3QhVmKVN3LODmunQHg6dJMKmKRC0FeMqmKw8PdFUHmxre3R14yGXMnGpOK3Ka45Qe2lIHVcGnQ2VSSriIPsjIWS9VuDmWuiZg4xj)diqRRaerqiIPlI5iIGfXCfr1)vkdXH6WsEtQbtUFiRuiBLJ(JqeblI0jIO9wJnBaFqjVjbWZvjSxedFfaRNjIGfXCfr0ERXqCOoSK3KAWK7hYkfY6zIyQuIiIVhQyoIickkIyymDrmvkreMT)LQJbMcz2a)k5FabADfGiccrmDreSiI2Bngu5yKeBzdZ6zIiyr0Y5pbh0f798UeTJHkdpe)kOicckIiGLqeZretLsePtev)xPmehQdl5nPgm5(HSsHSvo6pcrmvkr0Y5pbh0fB)qwP(lrFhQm8q8RGIiiOiIWP6vaqguDBcjAV1gwedtreWsiIHPiMUiMJH0T6Xld5CSgiHbCBcJAOjDQzsYqUYr)rycXqAXNo85gs1)vk7SR1XHYw5O)ierWIO6)kLH4qDyjVj1Gj3pKvkKTYr)riIGfr0ERXo7ADCOSEMicwer7TgdXH6WsEtQbtUFiRuiRNziDRE8Yq2WCOkHbCBcJAOjD6njzix5O)imHyiT4th(CdjAV1yo0UIWl7y9mdPB1JxgY3Z7s0ogQg1qt6PBsYqUYr)rycXqAXNo85gslN)eCqxs8CRkIGfr6er1)vkdXH6WsEtQbtUFiRuiBLJ(JWq6w94LH898UeTJHQrn0KoizsYqUYr)rycXqAXNo85gs1)vk7SR1XHYw5O)ierWIiDIyUIiIVhQyoIickreKOcreSiA58NGd6I9EExI2XqLHhIFfuebbfrKAIyogs3QhVmKNDToouJAOjDQ3KKHCLJ(JWeIH0IpD4ZnKQ)Ru2zxRJdLTYr)riIGfr0ERXo7ADCOSEMicweZver7Tg7SR1XHYWdXVckIGqebSeIyykIuVigMIiAV1yNDToouguDBcrmvkreT3AmOYXij2YgM1ZeXuPer6er1)vkdXH6WsEtQbtUFiRuiBLJ(JqeZXq6w94LHSH5qvcd42eg1qt6uHjjdPB1JxgY3Z7s0ogQgYvo6pctig1qt6HLjjd5kh9hHjedPB1JxgY27itcd42egsl(0Hp3qIxdpyGJ(ZqAd1(tQogyk0qd9g1qt6HbtsgYvo6pctigsl(0Hp3qI71ACmWy7hYk1F5OA)(dfFDe2OA)YYgHicwePter7TgB)qwP(lhv73FO4RJijgAV1y9mreSisNiQ(Vsz7hYk1Fj67qLTYr)riIGfr6er1)vkB2a(vasya3MGTYr)ryiDRE8Yq2WCOkHbCBcJAOjDQRjjd5kh9hHjedPfF6WNBiH8(JEfblp)D9(jH8p)kLTYr)ryiDRE8Yq2(bdSyVPgYR0HX9m1qsVrn0KEy0KKH0T6XldPnWVsg448dQgYvo6pctig1qdirntsgYvo6pctigsl(0Hp3qQ(VszNDToou2kh9hHicwer7Tg7SR1XHY6zgs3QhVmKnmhQsya3MWOgAaj6njzix5O)imHyiT4th(CdP6)kLbvxpRK4G2ahdm2kh9hHH0T6XldjuD9SsIdAdCmWmQHgqkDtsgYvo6pctigsl(0Hp3qsNiQ(Vszz4dXF5(HSs9)GkBLJ(JqetLsePteZMYAhEY9dzL6pZT6LFgs3QhVmKZXAGC)qwP(BudnGeizsYqUYr)rycXqAXNo85gsy2(xQogykKzd8RK)beO1vaIiOer6nKUvpEziTb(vY)ac06kaJAObKOEtsgs3QhVmK)beO1vasu(RgYvo6pctig1qdirfMKmKi88xbyOHEd5kh9NeHN)katigs3QhVmKT3rMegWTjmK2qT)KQJbMcn0qVH0IpD4ZnK41Wdg4O)mKRC0FeMqmQHgqkSmjzix5O)imHyix5O)Ki88xbycXqAXNo85gseE(HSszehu9YoreuIyyziDRE8Yq2Ehzsya3MWqIWZFfGHg6nQHgqkmysYqIWZFfGHg6nKRC0FseE(RamHyiDRE8Yq2WCOkHbCBcd5kh9hHjeJAObKOUMKmKRC0FeMqmKw8PdFUHu9FLYo7ADCOSvo6pcreSiI2Bn2zxRJdL1ZerWIiAV1yNDToougEi(vqreeIiCQEfaKbv3MqI2BTHfXWuebSeIyykIO9wJD2164qzq1TjmKUvpEziByouLWaUnHrnQHKynV)Qjjdn0BsYqUYr)rycXqsmOfFz6XldjiBPdJ7zQiYBIO1HkKziDRE8Yqc6RiKWG5yJAOjDtsgseE(Ram0qVHCLJ(tIWZFfGjedPB1Jxgsy2Hpf0(NyyOea72zix5O)imHyudnGKjjdPB1JxgYmUE8YqUYr)rycXOgAOEtsgs3QhVmKD4KNoeOHCLJ(JWeIrn0qfMKmKRC0FeMqmKw8PdFUHmxrKoru9FLY2pKvQ)s03HkBLJ(JqeZreblI0jI6ztCfGicwePteZMYGkhJi3pKvQ)m3Qx(jIGfXCfry2(xQogykKzd8RK)beO1vaIiierqsetLsev)xPmehQdl5nPgm5(HSsHSvo6pcrmvkre3R14yGXGjcffppXWqz7goujXqo4yJQ9llBeIyogs3QhVmKT3rMegWTjmQHMWYKKHCLJ(JWeIH0T6Xldzg(q4yIZFjO98ZqAXNo85gs6er0ERXYWhchtC(lbTNFSEMicweZvePteZMYGkhJi3pKvQ)m3Qx(jIPsjIWS9VuDmWuiZg4xj)diqRRaerqiIGKicwer7Tgd0xrib6qLbv3MqebHiMo1eXuPeriV)OxrW(5es0qLJk3rY(Xw5O)ieXCerWIyUIimB)lvhdmfYSb(vY)ac06kareeIiviIPsjIQ)RugId1HL8MudMC)qwPq2kh9hHiMkLiI71ACmWyWeHIINNyyOSDdhQKyihCSr1(LLncrmvkreY7p6veSFoHenu5OYDKSFSvo6pcrmhdPnu7pP6yGPqdn0BudnHbtsgYvo6pctigsl(0Hp3qsNiQNnXvaIiyrmxrKormBkdQCmIC)qwP(ZCRE5NiMkLicZ2)s1XatHmBGFL8pGaTUcqebHicsIiyreT3AmqFfHeOdvguDBcreeIy6uteZreblI5kIWS9VuDmWuiZg4xj)diqRRaerqiIGKiMkLiQ(VsziouhwYBsnyY9dzLczRC0FeIyQuIiUxRXXaJbtekkEEIHHY2nCOsIHCWXgv7xw2ieXCmKUvpEziBVJmjmGBtyudnuxtsgs3QhVmKTdp5(HSs93qUYr)rycXOgAcJMKmKUvpEzirMoo2qUYr)rycXOgAONAMKmKRC0FeMqmKw8PdFUHKoru9FLYCODfHx2Xw5O)ieXuPer0ERXCODfHx2X6zIyQuIOLZFcoOlMdTRi8YogEi(vqreuIivqndPB1Jxgs0NZjKToouJAOHE6njzix5O)imHyiT4th(CdjDIO6)kL5q7kcVSJTYr)riIPsjIO9wJ5q7kcVSJ1ZmKUvpEzirhgoCIRamQHg6t3KKHCLJ(JWeIH0IpD4ZnK0jIQ)RuMdTRi8Yo2kh9hHiMkLiI2BnMdTRi8YowptetLseTC(tWbDXCODfHx2XWdXVckIGsePcQziDRE8Yq2o8qFoNWOgAOhKmjzix5O)imHyiT4th(CdjDIO6)kL5q7kcVSJTYr)riIPsjIO9wJ5q7kcVSJ1ZeXuPerlN)eCqxmhAxr4LDm8q8RGIiOerQGAgs3QhVmKEzhuX(lT()g1qd9uVjjd5kh9hHjedPfF6WNBiPtev)xPmhAxr4LDSvo6pcrmvkrKoreT3AmhAxr4LDSEMH0T6XldjQdi5nPIpBcOrn0qpvysYq6w94LHm)GzdlvUoed5kh9hHjeJAOH(WYKKHCLJ(JWeIH0IpD4ZnKwE(vEPS6acuzZNicwePteX9Anogym4gbuYBsSJK5LkbWCqRbSr1(LLncreSiMRisNiQ(VsziouhwYBsnyY9dzLczRC0FeIyQuIiAV1yiouhwYBsnyY9dzLcz9mrmhreSicZ2)s1XatHmBGFL8pGaTUcqebHicsgs3QhVmKnFsf7fS1HhVmQHg6ddMKmKRC0FeMqmKw8PdFUH0YZVYlLvhqGkB(erWIiUxRXXaJb3iGsEtIDKmVujaMdAnGnQ2VSSriIGfXCfr6er1)vkdXH6WsEtQbtUFiRuiBLJ(JqetLser7TgdXH6WsEtQbtUFiRuiRNjIPsjIWS9VuDmWuiZg4xj)diqRRaerqrrebjrmhreSiMRiA58NGd6I1o8K7hYk1FgEi(vqreuIy6utetLseTC(tWbDXGkhJi3pKvQ)m8q8RGIiOeX0PMiMJH0T6XldzZNuXEbBD4XlJAOHEQRjjd5kh9hHjedPfF6WNBiDRE5NC1qUbfrqjIPlIGfXCfry2(xQogykKzd8RK)beO1vaIiOeX0fXuPery2(xQogykK9EExIohrebLiMUiMJHeQ4ZQgAO3q6w94LHe3lPB1JxY)GQH8pOklhzgsNpJAOH(WOjjd5kh9hHjedPfF6WNBiPtev)xPmOYXiY9dzL6pBLJ(JqeblIUvV8tUAi3GIiiOiIPBiHk(SQHg6nKUvpEziX9s6w94L8pOAi)dQYYrMHeEfWpP6yGPg1qt6uZKKHCLJ(JWeIH0IpD4ZnKQ)Rugu5ye5(HSs9NTYr)riIGfr3Qx(jxnKBqreeueX0nKqfFw1qd9gs3QhVmK4EjDRE8s(hunK)bvz5iZqcNeEfWpP6yGPg1OgYm8SCeuxnjzOHEtsgYvo6pctigs3QhVmKZXAGC)qwP(Bijg0IVm94LHKkJkF2UocrC5hourupKjIAWer3QCSiEqr0Z737O)ygsl(0Hp3qsNiQ(Vszz4dXF5(HSs9)GkBLJ(JWOgAs3KKHCLJ(JWeIH0T6Xldz7hmWI9MAijg0IVm94LHmSv4ersLJrsSLnSiMHNLJG6Qi2RFqOic5iteDccOic67FreM5GUeriNxmdPfF6WNBiH8(JEfblRd1(p5W9m94fBLJ(JqetLseH8(JEfblp)D9(jH8p)kLTYr)ryudnGKjjd5kh9hHjedPfF6WNBiv)xPmOYXij2YgMTYr)riIGfXCfrSFeYLFLYCcciZY7LkIGqebjrmvkre7hHC5xPmNGaYUsebLisfuteZXq6w94LHeQCmsITSHnQHgQ3KKH0T6Xldz7WtUFiRu)nKRC0FeMqmQHgQWKKHCLJ(JWeIH0IpD4ZnKQ)Ru2(HSs9xI(ouzRC0FeIiyreMT)LQJbMcz2a)k5FabADfGiccreKmKUvpEzi3pKvQ)s03HQrn0ewMKmKRC0FeMqmKUvpEziFpVlr7yOAi)RM0syibjdPfF6WNBiPtev)xPS9dzL6Ve9DOYw5O)ierWIimB)lvhdmfYSb(vY)ac06kareeIiijIPsjIO9wJbvogjXw2WSEMHKyql(Y0JxgYqM17WjIuj5dredCOi6IOI987fr9qw4IOgmr0ji4LiM9UDqrmm1GdkIRuCOHPiYlrK6KkvrSXXIiijIWz5fbuevUi655hHisW7O)azsLKperKxIyw)FMrn0egmjzix5O)imHyiT4th(CdjDIO6)kLTFiRu)LOVdv2kh9hHicweHz7FP6yGPqMnWVs(hqGwxbiIGIIicsIiyrKoreT3AmOYXij2YgM1ZmKUvpEziTb(vY)ac06kaJAOH6AsYq6w94LHmJRhVmKRC0FeMqmQrnKoFMKm0qVjjdPB1JxgsOYXiY9dzL6VHCLJ(JWeIrn0KUjjd5kh9hHjedPfF6WNBir7TgZ6)l)diqRRay4H4xbfrqrrePNAgs3QhVmKl0j5nPgmju5yeJAObKmjzix5O)imHyiT4th(CdjAV1yZgWVcqcd42eSEMH0T6Xld5CSgq1UNyg1qd1BsYq6w94LH0g4xjdCC(bvd5kh9hHjeJAOHkmjzix5O)imHyiT4th(CdP6)kLbvogjXw2WSvo6pcdPB1JxgsOYXij2Yg2OgAcltsgYvo6pctigs3QhVmKT3rMegWTjmKw8PdFUHeVgEWah9NicweZveZveDRE5NKGRS27itcd42eIiieX0frWIOB1l)KRgYnOicckIiijIGfrlN)eCqxSm8HWXeN)sq75hdpe)kOiccrK(WseblIwE(vEPSAwm)5ycreSisNiMnLbvogrUFiRu)zUvV8tetLseDRE5NKGRS27itcd42eIiier6frWIOB1l)KRgYnOickkIi1lIGfr6eXSPmOYXiY9dzL6pZT6LFIiyru9FLYqCOoSK3KAWK7hYkfYw5O)ieXCeXuPeXCfrCVwJJbgdMiuu88eddLTB4qLed5GJnQ2VSSriIGfr6eXSPmOYXiY9dzL6pZT6LFIyoIyogsBO2Fs1XatHgAO3OgAcdMKmKRC0FeMqmKw8PdFUHKor0T6LFscUYAVJmjmGBtiIGfr6eXSPmOYXiY9dzL6pZT6LFIiyrmxru9FLYqCOoSK3KAWK7hYkfYw5O)ieXuPerCVwJJbgdMiuu88eddLTB4qLed5GJnQ2VSSriI5yiDRE8Yq2Ehzsya3MWOgAOUMKmKRC0FeMqmKw8PdFUHu9FLYMnGFfGegWTjyRC0FeIiyreX3dvmhrebffrmSOMicweZveX9AnogySzd4dk5njaEUkH9Iy4RayJQ9llBeIiyreT3ASzd4dk5njaEUkH9Iy4Ray9mrmvkrKore3R14yGXMnGpOK3Ka45Qe2lIHVcGnQ2VSSriI5yiDRE8YqoBa)kajmGBtyudnHrtsgYvo6pctigsl(0Hp3qQ(Vszo0UIWl7yRC0FeIiyrmxrKormBkdQCmIC)qwP(ZCRE5NiMJicweZvePtev)xPSZUwhhkBLJ(JqetLsePter7Tg7SR1XHY6zIiyrKor0Y5pbh0f7SR1XHY6zIyogs3QhVmKo0UIWl7mQHg6PMjjd5kh9hHjedPfF6WNBiv)xPS)OA)iKioaIlvUoe2kh9hHH0T6Xld5FuTFesehaXLkxhIrn0qp9MKmKRC0FeMqmKw8PdFUHeMT)LQJbMcz2a)k5FabADfGiccrK6frWIiAV1yiouhwYBsnyY9dzLcz9mreSiI47HkMJiIGqePcQziDRE8YqAd8RK)beO1vag1qd9PBsYqUYr)rycXqAXNo85gsCVwJJbgB2a(GsEtcGNRsyVig(ka2OA)YYgHicwePter7TgB2a(GsEtcGNRsyVig(kawpZq6w94LHCowdKWaUnHrn0qpizsYqUYr)rycXqAXNo85gscUYAVJmjmGBtWWdXVckIGfry2(xQogykKzd8RK)beO1vaIiierQxeblI5kI0jIztzqLJrK7hYk1FMB1l)eXCerWIyUIiAV1yVN3LWogySEMicwePter7TgdXH6WsEtQbtUFiRuiRNjIGfr1)vkdXH6WsEtQbtUFiRuiBLJ(JqeZXq6w94LH898UeTJHQrn0qp1BsYqUYr)rycXqAXNo85gsy2(xQogykKzd8RK)beO1vaIiOOiIPlIGfr6erCVwJJbgB2a(GsEtcGNRsyVig(ka2OA)YYgHicweZvev)xPmehQdl5nPgm5(HSsHSvo6pcreSiI47HkMJiIGIIisfuteblI0jIO9wJH4qDyjVj1Gj3pKvkK1ZeXCmKUvpEziNJ1aQ29eZOgAONkmjzix5O)imHyiT4th(CdjbxzT3rMegWTjy4H4xbfrWIiAV1yVN3LWogySEMicwer7TgldFiCmX5Ve0E(X6zgs3QhVmKVN3LODmunQHg6dltsgYvo6pctigsl(0Hp3qsWvw7DKjHbCBcgEi(vqreSicZ2)s1XatHmBGFL8pGaTUcqebHis9Iiyre3R14yGXGjcffppXWqz7goujXqo4yJQ9llBeIiyreT3AS3Z7syhdmwpteblIQ)RugId1HL8MudMC)qwPq2kh9hHicwePter7TgdXH6WsEtQbtUFiRuiRNjIGfreFpuXCereuuerQGAgs3QhVmKVN3LODmunQHg6ddMKmKRC0FeMqmKw8PdFUHKGRS27itcd42em8q8RGIiyrmxrmxreMT)LQJbMcz2a)k5FabADfGiccrK6frWIiUxRXXaJbtekkEEIHHY2nCOsIHCWXgv7xw2ierWIO6)kLH4qDyjVj1Gj3pKvkKTYr)riI5iIPsjI5kIQ)RugId1HL8MudMC)qwPq2kh9hHicwer89qfZrerqrrePcQjIGfr6er0ERXqCOoSK3KAWK7hYkfY6zIiyrmxrKore3R14yGXMnGpOK3Ka45Qe2lIHVcGnQ2VSSriIPsjIO9wJnBaFqjVjbWZvjSxedFfaRNjI5iIGfr6erCVwJJbgdMiuu88eddLTB4qLed5GJnQ2VSSriI5iI5yiDRE8Yq(EExI2Xq1OgAON6AsYqUYr)rycXqAXNo85gscUYAVJmjmGBtWWdXVckIGfry2(xQogykKzd8RK)beO1vaIifrK6frWIiUxRXXaJbtekkEEIHHY2nCOsIHCWXgv7xw2ierWIiAV1yVN3LWogySEMicwev)xPmehQdl5nPgm5(HSsHSvo6pcreSisNiI2BngId1HL8MudMC)qwPqwpteblIi(EOI5iIiOOiIub1mKUvpEziFpVlr7yOAudn0hgnjzix5O)imHyiT4th(CdjmB)lvhdmfYSb(vY)ac06kareuueX0nKUvpEziNJ1aQ29eZOgAsNAMKmKRC0FeMqmKw8PdFUHeT3AmOYXij2YgMHhIFfuebHicsIyykIawcrmmfr0ERXGkhJKylByguDBcdPB1JxgsBGFL8pGaTUcWOgAsNEtsgYvo6pctigsl(0Hp3qI2Bn275DjSJbgRNjIGfry2(xQogykKzd8RK)beO1vaIiierQxeblI5kI0jIztzqLJrK7hYk1FMB1l)eXCerWIibxzT3rMegWTjy6ztCfGH0T6Xld575DjAhdvJAOj90njzix5O)imHyiT4th(CdP6)kLTFiRu)LOVdv2kh9hHicweHz7FP6yGPqMnWVs(hqGwxbiIGqePcreSiMRisNiMnLbvogrUFiRu)zUvV8teZXq6w94LHC)qwP(lrFhQg1qt6GKjjd5kh9hHjedPfF6WNBiv)xPmhAxr4LDSvo6pcdPB1JxgY3Z7s05ig1qt6uVjjdPB1JxgsBGFL8pGaTUcWqUYr)rycXOgAsNkmjzix5O)imHyix5O)Ki88xbycXqAXNo85gs0ERXEpVlHDmWy9mreSiA58NGd6sINBvdPB1JxgY3Z7s0ogQgseE(Ram0qVrn0KEyzsYqIWZFfGHg6nKRC0FseE(RamHyiDRE8Yq2Ehzsya3MWqAd1(tQogyk0qd9gsl(0Hp3qIxdpyGJ(ZqUYr)rycXOgAspmysYqIWZFfGHg6nKRC0FseE(RamHyiDRE8Yq2WCOkHbCBcd5kh9hHjeJAudjCs4va)KQJbMAsYqd9MKmKUvpEziHkhJi3pKvQ)gYvo6pctig1qt6MKmKRC0FeMqmKw8PdFUHeT3AmR)V8pGaTUcGHhIFfuebffrKEQziDRE8YqUqNK3KAWKqLJrmQHgqYKKHCLJ(JWeIH0IpD4ZnKQ)Ru2zxRJdLTYr)riIGfr0ERXo7ADCOSEMicwer7Tg7SR1XHYWdXVckIGqeHt1RaGmO62es0ERnSigMIiGLqedtreT3ASZUwhhkdQUnHicwer7Tgd0xrib6qLbv3MqebHisp11q6w94LHSH5qvcd42eg1qd1BsYqUYr)rycXqAXNo85gs1)vkB)qwP(lrFhQSvo6pcdPB1JxgY9dzL6Ve9DOAudnuHjjd5kh9hHjedPfF6WNBiv)xPmOYXij2YgMTYr)ryiDRE8YqcvogjXw2Wg1qtyzsYqUYr)rycXqAXNo85gs1)vkB2a(vasya3MGTYr)riIGfrlN)eCqxS3Z7s0ogQm8q8RGIiiOiIawcreSicZ2)s1XatHmBGFL8pGaTUcqebHiMUiMkLiI47HkMJiIGIIigwuteblIWS9VuDmWuiZg4xj)diqRRaerqrretxeblI5kI0jI4ETghdm2Sb8bL8MeapxLWErm8vaSr1(LLncrmvkreT3ASzd4dk5njaEUkH9Iy4Ray9mrmhrmvkreMT)LQJbMcz2a)k5FabADfGiccrmDreSiI2BngOVIqc0HkdQUnHickkIi9uxreSiMRisNiI71ACmWyZgWhuYBsa8Cvc7fXWxbWgv7xw2ieXuPer0ERXMnGpOK3Ka45Qe2lIHVcG1ZeXCerWIiIVhQyoIickkIyyrndPB1JxgYzd4xbiHbCBcJAOjmysYqUYr)rycXqAXNo85gYCfr0ERXa9vesGouzq1TjerqiI0tDfrWIiDIiAV1yOpNt8DOY6zIyoIyQuIiAV1yVN3LWogySEMH0T6Xld575DjAhdvJAOH6AsYqUYr)rycXqAXNo85gs1)vkB2a(vasya3MGTYr)riIGfr0ERXMnGFfGegWTjy9mreSicZ2)s1XatHmBGFL8pGaTUcqebHiMUH0T6Xld575DjAhdvJAOjmAsYqUYr)rycXqAXNo85gs1)vkB2a(vasya3MGTYr)riIGfr0ERXMnGFfGegWTjy9mreSicZ2)s1XatHmBGFL8pGaTUcqebffrmDdPB1JxgY5ynGQDpXmQHg6PMjjd5kh9hHjedPfF6WNBir7TgdQCmsITSHz9mdPB1JxgY)ac06kajk)vJAOHE6njzix5O)imHyiT4th(CdjAV1yZgWhuYBsa8Cvc7fXWxbW6zgs3QhVmKZXAav7EIzudn0NUjjd5kh9hHjedPfF6WNBiHz7FP6yGPqMnWVs(hqGwxbiIGqetxeblIi(EOI5iIiOOiIHf1erWIyUIiAV1yG(kcjqhQmO62eIiieX0PMiMkLiI47HkMJiIGsedJuteZretLseZveX9AnogySzd4dk5njaEUkH9Iy4RayJQ9llBeIiyrKoreT3ASzd4dk5njaEUkH9Iy4Ray9mrmhdPB1JxgY5ynqcd42eg1qd9GKjjd5kh9hHjedPfF6WNBiZveHz7FP6yGPqMnWVs(hqGwxbiIGsePxeZreblI5kI0jIeCL1Ehzsya3MGHxdpyGJ(teZXq6w94LHCowdOA3tmJAOHEQ3KKHCLJ(JWeIH0IpD4ZnKUvV8tUAi3GIiOer6frWIy2ugu5ye5(HSs9N5w9YpreSiI2Bng6Z5eFhQSEMH0T6XldPnWVs(hqGwxbyudn0tfMKmKRC0FeMqmKw8PdFUHmBkdQCmIC)qwP(ZCRE5Nicwer7Tgd95CIVdvwpZq6w94LH8pGaTUcqIYF1OgAOpSmjzix5O)imHyiT4th(CdjAV1yo0UIWl7y9mdPB1JxgY3Z7s0ogQg1qd9HbtsgYvo6pctigsl(0Hp3qA58NGd6sINBvdPB1JxgY3Z7s0ogQg1qd9uxtsgYvo6pctigsl(0Hp3qA58NGd6sINBvreSiAdCmWGIiOer1)vkB2aUK3KAWK7hYkfYw5O)imKUvpEziFpVlr7yOAudn0hgnjzix5O)imHyiT4th(CdP6)kLD2164qzRC0FeIiyreT3ASZUwhhkRNziDRE8Yq2WCOkHbCBcJAOjDQzsYq6w94LH0g4xjdCC(bvd5kh9hHjeJAOjD6njzix5O)imHyiT4th(CdjK3F0Riy55VR3pjK)5xPSvo6pcdPB1JxgY2pyGf7n1qELomUNPgs6nQHM0t3KKHCLJ(JWeIH0IpD4ZnKQ)RuguD9SsIdAdCmWyRC0Fegs3QhVmKq11ZkjoOnWXaZOgAshKmjzix5O)imHyiT4th(CdjDIO6)kLLHpe)L7hYk1)dQSvo6pcrmvkru9FLYYWhI)Y9dzL6)bv2kh9hHicweZvePteZMYGkhJi3pKvQ)m3Qx(jI5yiDRE8YqohRbY9dzL6Vrn0Ko1BsYqUYr)rycXqAXNo85gs3Qx(jxnKBqreuIi9IiyrmxreMT)LQJbMcz2a)k5FabADfGickrKErmvkreMT)LQJbMczVN3LOZrerqjI0lI5yiDRE8YqAd8RK)beO1vag1qt6uHjjdPB1JxgY)ac06kajk)vd5kh9hHjeJAOj9WYKKHeHN)kadn0Bix5O)Ki88xbycXq6w94LHS9oYKWaUnHH0gQ9NuDmWuOHg6nKw8PdFUHeVgEWah9NHCLJ(JWeIrn0KEyWKKHCLJ(JWeIHCLJ(tIWZFfGjedPfF6WNBir45hYkLrCq1l7erqjIHLH0T6Xldz7DKjHbCBcdjcp)vagAO3OgAsN6AsYqIWZFfGHg6nKRC0FseE(RamHyiDRE8Yq2WCOkHbCBcd5kh9hHjeJAuJAuJAma]] )

end
