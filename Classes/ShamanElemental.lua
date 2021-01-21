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
        elemental_attunement = 727, -- 204385
        grounding_totem = 3620, -- 204336
        lightning_lasso = 731, -- 305483
        purifying_waters = 3491, -- 204247
        skyfury_totem = 3488, -- 204330
        spectral_recovery = 3062, -- 204261
        swelling_waves = 3621, -- 204264
        traveling_storms = 730, -- 204403
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
    spec:RegisterPet( "primal_storm_elemental", 77942, "storm_elemental", 30 )
    spec:RegisterTotem( "greater_storm_elemental", 1020304 ) -- Texture ID

    spec:RegisterPet( "primal_fire_elemental", 61029, "fire_elemental", 30 )
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
            cast = function () return 2.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 136042,

            handler = function ()
                removeBuff( "echoing_shock" )
            end,
        },

        chain_lightning = {
            id = 188443,
            cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
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

                removeBuff( "echoing_shock" )
            end,
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

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental", 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) )
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
                removeBuff( "lava_surge" )
                removeBuff( "echoing_shock" )

                gain( 10, "maelstrom" )

                if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end

                if talent.surge_of_power.enabled then
                    gainChargeTime( "fire_elemental", 6 )
                    removeBuff( "surge_of_power" )
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

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental", 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) )
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

            usable = function () return storm_elemental.up and buff.call_lightning.remains >= 8 end,
            handler = function () end,
        },


        -- Shaman - Kyrian    - 324386 - vesper_totem         (Vesper Totem)
        vesper_totem = {
            id = 324386,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

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

            handler = function ()
                applyDebuff( "target", "flame_shock" )
                applyBuff( "primordial_wave" )
            end,

            auras = {
                primordial_wave = {
                    id = 327164,
                    duration = 15,
                    max_stack = 1
                }
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

            finish = function ()
                if state.spec.enhancement then addStack( "maelstrom_weapon", nil, 1 ) end
            end,

            auras = {
                fae_transfusion = {
                    id = 328933,
                    duration = 20,
                    max_stack = 1
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

    spec:RegisterPack( "Elemental", 20201227, [[dmu(xbqiuspsjsTjHYNuIKyucvoLqvRsqrVsanluQULsKu7Iu)saggi4yOeltjQNHOutdKIRbsPTjOW3uIOXPebNdrjwNseI5bcDpezFGuTqevpujcPjIOKQlQejojIsYkbjZujcf3erjLDcI(PseQEQsnvukxvjss7fYFPQbRWHPSyGEmjtgHllTzf9zumAHCAv9Abz2QCBa7w0Vr1WvshxqPLJ0ZHA6exhuBxj8DefJxjcLoVGQ5lq7NkJybXgAtysrqUmewgcSS8YlPMfiWc0aHLeTLWxlAVAQqgtr70akAVuUc0uSdTxTWpUrGydTXCyQQODKiR4LibeaZlrWGAfhia8daFM88urTPea(bubG2GW)jKvjceTjmPiixgcldbwwE5LuZceybAqB8AviixomwgTJEcIMiq0MOyfAV0UXs5kqtXo3yhzaw6GAPDdY6vvaWsDJLxs2DJLHWYqWbLdQL2nwIgzjtXlrCqT0UXsTBqwLkoDLtnPUbUI8jdwJftfYdcpNL6gto1niRuDctdND3ylCkqO21s1O9kLp)RO9s7glLRanf7CJDKbyPdQL2niRxvbal1nwEjz3nwgcldbhuoOwA3yjAKLmfVeXb1s7gl1UbzvQ40vo1K6g4kYNmynwmvipi8CwQBm5u3GSs1jmnC2DJTWPaHAxlv7GYb1s7glLLyRcwkHB0fLgUBipqDdjQUHPeo1nESBylS)mWRAhuMsEEI1R0Q4aGMqQgvI89kqtXo2)jjwf7Ak6v6dyNVxbAk29yr30aVs4GAPDJLQ46gBHtbc1UwQBSsRIdaAIBaNxXy3aZbQByeey3Gm)DUbE1it6gyop1oOmL88eRxPvXbanjqsbGfofiu7APS)tsIDnfnw4uGqTRLQBAGxjIfh1EcFx0u0gbbwR4WParYoyqQ9e(UOPOnccS(tOdTqiEhuMsEEI1R0Q4aGMeiPa6vGMIDEWZWc7)KKyxtr3Ranf78GNHfDtd8kHdktjppX6vAvCaqtcKuaNTW8GWuSW(pjXQyxtr3Ranf78GNHfDtd8kHdktjppX6vAvCaqtcKuaRC55PdkhulTBqwLsPu4vXn4t3qzybRDqzk55joqsbqMpj84OAuhuMsEEIdKua41N(czSluPypd1uLDa(IpziXIdktjppXbskGvU880bLPKNN4ajfamU(xka2bLPKNN4ajfW8P13Ranf7Cqzk55joqsbGfofW3Ranf7Cqzk55joqsbaECoHFctdN9FsIvXUMI2WQMewQQUPbELiyqq45uByvtclvvdVgmOIZpcozsTHvnjSuvnTa2NyOdTqWbLPKNN4ajfayP4sd9jd7)KeRIDnfTHvnjSuvDtd8krWGGWZP2WQMewQQgE1bLPKNN4ajfW8Pf84Cc2)jjwf7AkAdRAsyPQ6Mg4vIGbbHNtTHvnjSuvn8AWGko)i4Kj1gw1KWsv10cyFIHo0cbhuMsEEIdKuawQkwO25v2DS)tsSk21u0gw1KWsv1nnWRebdccpNAdRAsyPQA41GbvC(rWjtQnSQjHLQQPfW(edDOfcoOmL88ehiPaangpF6f6RcHz)NKyvSRPOnSQjHLQQBAGxjcgKvq45uByvtclvvdV6GYbLPKNN4ajfWk9b4uI3opzSfLDv4QREXOmvWKyH9FsIvq45uVsFaoL4TZtgBr1WRoOmL88ehiPawu8APEHlfWbLPKNN4ajfW0QxOwINW4NNS)tsSk21u0agwk1ZNEjQ(EfOPG1nnWRebdccpNAadlL65tVevFVc0uWA4vhuoOmL88ehiPaOWP3uYZt)9yH90akjJx2)jjtj)I6BwGVyOVCS4WR9oVyuMkyTkY(0FptKKFYa9LdgeV278IrzQG1NTW8G1aG(YX7GYuYZtCGKcGcNEtjpp93Jf2tdOKWFYC1lgLPc7)KeRIDnfnw4uaFVc0uSt30aVseZuYVO(Mf4lgIKw2bLPKNN4ajfafo9MsEE6VhlSNgqjHRh)jZvVyuMkS)tsIDnfnw4uaFVc0uSt30aVseZuYVO(Mf4lgIKw2bLdktjppXAJxs1OsuyHTqL9FsceEo1vfX)KXJJ4QqA4vhuMsEEI1gVbskavK9PpYOlkwCqzk55jwB8giPaWcNceQDTu2)jjXUMIglCkqO21s1nnWReoOmL88eRnEdKuaZZaQhhXvHyxfU6Qxmktfmjwy)NKmL8lQNGl65za1JJ4QqqKSJzk5xuFZc8fdrsqBWGu4StoLPACOWbP1cvk2p)sd3tuGhxDdl8VUwchuMsEEI1gVbskG5za1JJ4QqS)tsSAk5xupbx0ZZaQhhXvHCqzk55jwB8giPaQkI)jJhhXvHy)NKe7Ak6QI4FY4XrCviDtd8krmaRhwOCaOtkmGGdktjppXAJ3ajfGHvnjSuv2)jjXUMI2WQMewQQUPbELiwCSUwrJfofW3Ranf70Ms(fn(yXXQyxtr)QoHPHRBAGxjcgKvq45u)QoHPHRHxJXQIZpcozs9R6eMgUgEnEhuMsEEI1gVbskG7dl8t4bmgaZlCPaS)tsIDnf99Hf(j8agdG5fUuaDtd8kHdktjppXAJ3ajfqnQe5XrCvi2)jjkC2jNYuDvr8I98PNHwt8y4KO0pz0nSW)6AjIXki8CQRkIxSNp9m0AIhdNeL(jJgE1bLPKNNyTXBGKcOgvI89kqtXo2)jjkC2jNYunr7QqlaN6XcpRUHf(xxlrS4yvSRPOxPpGD(EfOPy3JfDtd8krWGXX6Afnw4uaFVc0uStBk5x0ySUwrpFA99kqtXoTPKFrJpEhuMsEEI1gVbskGZwyEqykwyxfU6Qxmktfmjwy)NKWR9oVyuMkyTkY(0FptKKFYarOjyqq45uF2cZJHPmvdVgmyCIDnfnGHLs98PxIQVxbAkyDtd8krmwbHNtnGHLs98PxIQVxbAkyn8AmaRhwOCaOtkmGq8oOwA3GnA4UHWDdgdOUXsXOsuyHTq1niZlrUbzndlL6g8PBir1nwkxbAky3aeEoDdYe10nMptK8jJBq2UHyuMkyTBqwNNlve3GVOuLT6gK1SEyHYby1bLPKNNyTXBGKcOgvIclSfQS)tsSk21u0agwk1ZNEjQ(EfOPG1nnWRebdccpNASWPaHAxlvdVgmiG1dluoa0jfhlqacl1qtyIx7DEXOmvWAvK9P)EMij)Kj(GbbHNtnGHLs98PxIQVxbAkyn8AWG41ENxmktfSwfzF6VNjsYpzGoz7GAPDdYAwO6gyyADJW5WUbbpxQiUXXX1nm3ylCkqO21sDdq45u7GYuYZtS24nqsbOISp93Zej5NmS)tsGWZPglCkqO21s10cyFIHizhMmkIWeeEo1yHtbc1UwQglMkKdQL2nwINx4UHYWIBSeJTWCdYHPyXn4PBir0w3qmktfSB8t34f34XUHLUXNyXsXnSKWn2cNc4glLRanf7CJh7gqUeNn3WuYVOAhuMsEEI1gVbskGZwyEqykwy)NKaHNt9zlmpgMYun8Am8AVZlgLPcwRISp93Zej5NmqeAIfhRRv0yHtb89kqtXoTPKFrJpgbx0ZZaQhhXvH0YRc9jJdQL2nwQIRBSuUc0uSZni)mS4ggJ9jwCd4v3q4Ubz7gIrzQGDdd7ghpzCdd7gBHtbCJLYvGMIDUXJDJKlUHPKFr1oOmL88eRnEdKua9kqtXop4zyH9FssSRPO7vGMIDEWZWIUPbELigET35fJYubRvr2N(7zIK8tgicTXIJ11kASWPa(EfOPyN2uYVOX7GYuYZtS24nqsbC2cZdwdG9FssSRPOnSQjHLQQBAGxjCqzk55jwB8giPaur2N(7zIK8tghuMsEEI1gVbskGZwyEqykwyhGV4tgsSW(pjbcpN6ZwyEmmLPA41yko)i4Kj90AkXbLPKNNyTXBGKcyEgq94iUke7a8fFYqIf2vHRU6fJYubtIf2)jjAN0IJmWRoOmL88eRnEdKuatkhlECexfIDa(IpziXIdkhuMsEEI146XFYC1lgLPcP5za1JJ4QqSRcxD1lgLPcMelS)tsXrlG9jgIKyueXhloq45uF2cZJHPmvdVgmiRGWZPg84CIdglA414Dqzk55jwJRh)jZvVyuMkbskGEfOPyNh8mSW(pjj21u09kqtXop4zyr30aVs4GYuYZtSgxp(tMREXOmvcKuayHtbc1Uwk7)KKyxtrJfofiu7AP6Mg4vIyXby9WcLdarObAI3bLPKNNynUE8Nmx9IrzQeiPaQkI)jJhhXvHy)NKe7Ak6QI4FY4XrCviDtd8kHdktjppXAC94pzU6fJYujqsbC2cZdctXc7)Kei8CQjZNeEgySOXIPcbrwwcbdccpN6ZwyEmmLPA4vhuMsEEI146XFYC1lgLPsGKc4EMij)KXdYpH9FsceEo1yHtbc1UwQgE1bLPKNNynUE8Nmx9IrzQeiPaQrLOWcBHk7)Kei8CQRkIxSNp9m0AIhdNeL(jJgE1bLPKNNynUE8Nmx9IrzQeiPaQrLOWcBHk7)KuC41ENxmktfSwfzF6VNjsYpzGolXhlowj4IEEgq94iUkKM2jT4id8A8oOmL88eRX1J)K5QxmktLajfqnQe5XrCvi2)jj8AVZlgLPcwRISp93Zej5NmqC5yawpSq5aqNuyaHyXbcpNAY8jHNbglASyQqqCziemiG1dluoa0jlqi(GbJJcNDYPmvxveVypF6zO1epgojk9tgDdl8VUwIySccpN6QI4f75tpdTM4XWjrPFYOHxJ3bLPKNNynUE8Nmx9IrzQeiPaUNjsYpz8G8ty)NKIdeEo1yHtbc1UwQMwa7tmeXvKpzWASyQqEq45S0WKrreMGWZPglCkqO21s1yXuHcgeeEo1yHtbc1UwQgEngi8CQbmSuQNp9su99kqtbRHxJ3bLPKNNynUE8Nmx9IrzQeiPaMuow84iUke7)KKyxtr)QoHPHRBAGxjIj21u0agwk1ZNEjQ(EfOPG1nnWReXaHNt9R6eMgUgEngi8CQbmSuQNp9su99kqtbRHxDqzk55jwJRh)jZvVyuMkbskGZwyEqykwy)NKaHNtTHvnjSuvn8QdktjppXAC94pzU6fJYujqsbC2cZdctXc7)KKIZpcozspTMsIXQyxtrdyyPupF6LO67vGMcw30aVs4GYuYZtSgxp(tMREXOmvcKuaVQtyA4S)tsIDnf9R6eMgUUPbELigRXby9WcLda9LeAJP48JGtMuF2cZdctXIMwa7tmejbH4Dqzk55jwJRh)jZvVyuMkbskGZwyEqykwy)NKuC(rWjt6P1usmvKrzkg6IDnfDvrCpF6LO67vGMcw30aVs4GYuYZtSgxp(tMREXOmvcKuatkhlECexfI9FssSRPOFvNW0W1nnWReXaHNt9R6eMgUgE1bLPKNNynUE8Nmx9IrzQeiPaur2N(iJUOyXbLPKNNynUE8Nmx9IrzQeiPaWIjVYt8yvKrzk7)KKyxtrJftELN4XQiJYuDtd8kHdktjppXAC94pzU6fJYujqsbuJkr(EfOPyh7)KeRIDnf9k9bSZ3Ranf7ESOBAGxjcguSRPOxPpGD(EfOPy3JfDtd8krS4yDTIglCkGVxbAk2PnL8lA8oOmL88eRX1J)K5QxmktLajfW9mrs(jJhKFIdktjppXAC94pzU6fJYujqsbmpdOECexfIDa(IpziXc7QWvx9IrzQGjXc7)KeTtAXrg4vhuMsEEI146XFYC1lgLPsGKcyEgq94iUke7a8fFYqIf2)jja(Ic0u0epwSuvOhgoOmL88eRX1J)K5QxmktLajfWKYXIhhXvHyhGV4tgsS4GYbLPKNNyn(tMREXOmvinpdOECexfIDv4QREXOmvWKyH9FskowLxf6tMGbj4IEEgq94iUkKMwa7tmejXOicguSRPOnSQjHLQQBAGxjIrWf98mG6XrCvinTa2NyigNIZpcozsTHvnjSuvnTa2N4abHNtTHvnjSuvnbm1KNNXhtX5hbNmP2WQMewQQMwa7tmeHM4Jfhi8CQpBH5XWuMQHxdgKvq45udECoXbJfn8A8oOmL88eRXFYC1lgLPsGKcWWQMewQk7)KKyxtrByvtclvv30aVselo5bk0jfgqiyqq45udECoXbJfn8A8XItX5hbNmP(SfMheMIfnTa2NyOdH4JfhRIDnf9R6eMgUUPbELiyqwbHNt9R6eMgUgEngRko)i4Kj1VQtyA4A414Dqzk55jwJ)K5QxmktLajfqVc0uSZdEgwy)NKe7Ak6EfOPyNh8mSOBAGxjIfNyxtrdyyPupF6LO67vGMcw30aVseloq45udyyPupF6LO67vGMcwdVgdW6HfkhaIHbecgKvq45udyyPupF6LO67vGMcwdVgFWGSk21u0agwk1ZNEjQ(EfOPG1nnWReX7GYuYZtSg)jZvVyuMkbskaSWPaHAxlL9FssSRPOXcNceQDTuDtd8krS4O2t47IMI2iiWAfhofis2bdsTNW3fnfTrqG1FcDOfcXhloaRhwOCaicnqt8oOmL88eRXFYC1lgLPsGKcOQi(NmECexfI9FssSRPORkI)jJhhXvH0nnWReXuC(rWjtQpBH5bHPyrtlG9jgIKGGdktjppXA8Nmx9IrzQeiPaoBH5bHPyH9FssSRPORkI)jJhhXvH0nnWReXaHNtDvr8pz84iUkKgE1bLPKNNyn(tMREXOmvcKua3hw4NWdymaMx4sby)NKe7Ak67dl8t4bmgaZlCPa6Mg4vchuMsEEI14pzU6fJYujqsbCptKKFY4b5NW(pjbcpNASWPaHAxlvdVgdV278IrzQG1Qi7t)9mrs(jdexowCGWZPgWWsPE(0lr13RanfSgEnEhuMsEEI14pzU6fJYujqsbuJkrHf2cv2)jjq45uxveVypF6zO1epgojk9tgn8AS4yvSRPObmSuQNp9su99kqtbRBAGxjcgeeEo1agwk1ZNEjQ(EfOPG1WRX7GYuYZtSg)jZvVyuMkbskGAujkSWwOY(pjHx7DEXOmvWAvK9P)EMij)Kb6SeJvcUONNbupoIRcPPDsloYaVgJvkC2jNYuDvr8I98PNHwt8y4KO0pz0nSW)6AjIfhRIDnfnGHLs98PxIQVxbAkyDtd8krWGGWZPgWWsPE(0lr13RanfSgEnyqfNFeCYK6ZwyEqykw00cyFIHoeIby9WcLdaDsKLLJ3bLPKNNyn(tMREXOmvcKua1OsKhhXvHy)NKe7AkAadlL65tVevFVc0uW6Mg4vIyXbcpNAadlL65tVevFVc0uWA41GbvC(rWjtQpBH5bHPyrtlG9jg6qigG1dluoa0jrwwoyq8AVZlgLPcwRISp93Zej5NmqC5yGWZPglCkqO21s1WRXuC(rWjtQpBH5bHPyrtlG9jgIKyueXhmiRIDnfnGHLs98PxIQVxbAkyDtd8kHdktjppXA8Nmx9IrzQeiPaUNjsYpz8G8ty)NKIdeEo1yHtbc1UwQMwa7tmeXvKpzWASyQqEq45S0WKrreMGWZPglCkqO21s1yXuHcgeeEo1yHtbc1UwQgEngi8CQbmSuQNp9su99kqtbRHxJ3bLPKNNyn(tMREXOmvcKuatkhlECexfI9FssSRPOFvNW0W1nnWReXe7AkAadlL65tVevFVc0uW6Mg4vIyGWZP(vDctdxdVgdeEo1agwk1ZNEjQ(EfOPG1WRoOmL88eRXFYC1lgLPsGKc4SfMheMIf2)jjq45uByvtclvvdV6GYuYZtSg)jZvVyuMkbskGZwyEqykwy)NKuC(rWjt6P1usmwf7AkAadlL65tVevFVc0uW6Mg4vchuMsEEI14pzU6fJYujqsb8QoHPHZ(pjj21u0VQtyA46Mg4vIySghG1dluoa0xsOnMIZpcozs9zlmpimflAAbSpXqKeeI3bLPKNNyn(tMREXOmvcKuaNTW8GWuSW(pjP48JGtM0tRPKyQiJYum0f7Ak6QI4E(0lr13RanfSUPbELWbLPKNNyn(tMREXOmvcKuatkhlECexfI9FssSRPOFvNW0W1nnWReXaHNt9R6eMgUgEngi8CQFvNW0W10cyFIHiUI8jdwJftfYdcpNLgMmkIWeeEo1VQtyA4ASyQqoOmL88eRXFYC1lgLPsGKc4SfMheMIf2)jjfNFeCYKEAnL4GYuYZtSg)jZvVyuMkbskG5za1JJ4QqSRcxD1lgLPcMelS)ts0oPfhzGxDqzk55jwJ)K5QxmktLajfqnQefwyluz)NKWR9oVyuMkyTkY(0FptKKFYaDwIXkfo7KtzQUQiEXE(0ZqRjEmCsu6Nm6gw4FDTebdccpN6QI4f75tpdTM4XWjrPFYOHxDqzk55jwJ)K5QxmktLajfWKYXIhhXvHy)NKe7Ak6x1jmnCDtd8krmq45u)QoHPHRHxJfhi8CQFvNW0W10cyFIHiJIimHMWeeEo1VQtyA4ASyQqbdccpNASWPaHAxlvdVgmiRIDnfnGHLs98PxIQVxbAkyDtd8kr8oOmL88eRXFYC1lgLPsGKcys5yXJJ4QqS)tsu4StoLP6EfOPyNVHf(VhK(Wa6gw4FDTeXyfeEo19kqtXoFdl8Fpi9Hb8efeEo1WRXyvSRPO7vGMIDEWZWIUPbELigRIDnfDvr8pz84iUkKUPbELWbLPKNNyn(tMREXOmvcKuaQi7tFKrxuS4GYuYZtSg)jZvVyuMkbskaSyYR8epwfzuMY(pjj21u0yXKx5jESkYOmv30aVs4GYuYZtSg)jZvVyuMkbskGAujY3Ranf7y)NKyvSRPOxPpGD(EfOPy3JfDtd8krWGSUwrpFA99kqtXoTPKFrDqzk55jwJ)K5QxmktLajfW9mrs(jJhKFIdktjppXA8Nmx9IrzQeiPaMNbupoIRcXoaFXNmKyHDv4QREXOmvWKyH9FsI2jT4id8QdktjppXA8Nmx9IrzQeiPaMNbupoIRcXoaFXNmKyH9FscGVOanfnXJflvf6HHdktjppXA8Nmx9IrzQeiPaMuow84iUke7a8fFYqIf0ErP4NNiixgcldbwwgclb0Mmgn)KbJ2KvaRCQuc3aADdtjppDJ7Xcw7GcTVhlyeBOn(tMREXOmvqSHGKfeBODtd8kbIC02uYZt0EEgq94iUkeAROVu6BODCUbRUH8QqFY4gbd6geCrppdOECexfstlG9j2nGij3Grr4gbd6gIDnfTHvnjSuvDtd8kHBeZni4IEEgq94iUkKMwa7tSBar3io3qX5hbNmP2WQMewQQMwa7tSBeOBacpNAdRAsyPQAcyQjppDJ4DJyUHIZpcozsTHvnjSuvnTa2Ny3aIUb04gX7gXCJ4Cdq45uF2cZJHPmvdV6gbd6gS6gGWZPg84CIdglA4v3iE0wfU6QxmktfmcswqccYLrSH2nnWReiYrBf9LsFdTf7AkAdRAsyPQ6Mg4vc3iMBeNBipqDdOtYncdi4gbd6gGWZPg84CIdglA4v3iE3iMBeNBO48JGtMuF2cZdctXIMwa7tSBaD3acUr8Urm3io3Gv3qSRPOFvNW0W1nnWReUrWGUbRUbi8CQFvNW0W1WRUrm3Gv3qX5hbNmP(vDctdxdV6gXJ2MsEEI2gw1KWsvrccsYgXgA30aVsGihTv0xk9n0wSRPO7vGMIDEWZWIUPbELWnI5gX5gIDnfnGHLs98PxIQVxbAkyDtd8kHBeZnIZnaHNtnGHLs98PxIQVxbAkyn8QBeZnaSEyHYbCdi6gHbeCJGbDdwDdq45udyyPupF6LO67vGMcwdV6gX7gbd6gS6gIDnfnGHLs98PxIQVxbAkyDtd8kHBepABk55jA3Ranf78GNHfKGGeAqSH2nnWReiYrBf9LsFdTf7AkASWPaHAxlv30aVs4gXCJ4CdQ9e(UOPOnccSwXHtXnGOBq2UrWGUb1EcFx0u0gbbw)PBaD3aAHGBeVBeZnIZnaSEyHYbCdi6gqd04gXJ2MsEEI2yHtbc1UwksqqcTi2q7Mg4vce5OTI(sPVH2IDnfDvr8pz84iUkKUPbELWnI5gko)i4Kj1NTW8GWuSOPfW(e7gqKKBab02uYZt0UQi(NmECexfcjiiddeBODtd8kbIC0wrFP03qBXUMIUQi(NmECexfs30aVs4gXCdq45uxve)tgpoIRcPHxrBtjppr7ZwyEqykwqccYLeXgA30aVsGihTv0xk9n0wSRPOVpSWpHhWyamVWLcOBAGxjqBtjppr77dl8t4bmgaZlCPaibb5saXgA30aVsGihTv0xk9n0geEo1yHtbc1UwQgE1nI5g41ENxmktfSwfzF6VNjsYpzCdi6gl7gXCJ4Cdq45udyyPupF6LO67vGMcwdV6gXJ2MsEEI23Zej5NmEq(jibbjzbXgA30aVsGihTv0xk9n0geEo1vfXl2ZNEgAnXJHtIs)KrdV6gXCJ4CdwDdXUMIgWWsPE(0lr13RanfSUPbELWncg0naHNtnGHLs98PxIQVxbAkyn8QBepABk55jAxJkrHf2cvKGGKfiGydTBAGxjqKJ2k6lL(gAJx7DEXOmvWAvK9P)EMij)KXnGUBWIBeZny1ni4IEEgq94iUkKM2jT4id8QBeZny1nOWzNCkt1vfXl2ZNEgAnXJHtIs)Kr3Wc)RRLWnI5gX5gS6gIDnfnGHLs98PxIQVxbAkyDtd8kHBemOBacpNAadlL65tVevFVc0uWA4v3iyq3qX5hbNmP(SfMheMIfnTa2Ny3a6UbeCJyUbG1dluoGBaDsUbzzz3iE02uYZt0UgvIclSfQibbjlSGydTBAGxjqKJ2k6lL(gAl21u0agwk1ZNEjQ(EfOPG1nnWReUrm3io3aeEo1agwk1ZNEjQ(EfOPG1WRUrWGUHIZpcozs9zlmpimflAAbSpXUb0Ddi4gXCdaRhwOCa3a6KCdYYYUrWGUbET35fJYubRvr2N(7zIK8tg3aIUXYUrm3aeEo1yHtbc1UwQgE1nI5gko)i4Kj1NTW8GWuSOPfW(e7gqKKBWOiCJ4DJGbDdwDdXUMIgWWsPE(0lr13RanfSUPbELaTnL88eTRrLipoIRcHeeKSSmIn0UPbELaroAROVu6BODCUbi8CQXcNceQDTunTa2Ny3aIUbUI8jdwJftfYdcpNL6gHPBWOiCJW0naHNtnw4uGqTRLQXIPc5gbd6gGWZPglCkqO21s1WRUrm3aeEo1agwk1ZNEjQ(EfOPG1WRUr8OTPKNNO99mrs(jJhKFcsqqYczJydTBAGxjqKJ2k6lL(gAl21u0VQtyA46Mg4vc3iMBi21u0agwk1ZNEjQ(EfOPG1nnWReUrm3aeEo1VQtyA4A4v3iMBacpNAadlL65tVevFVc0uWA4v02uYZt0Es5yXJJ4QqibbjlqdIn0UPbELaroAROVu6BOni8CQnSQjHLQQHxrBtjppr7ZwyEqykwqccswGweBODtd8kbIC0wrFP03qBfNFeCYKEAnL4gXCdwDdXUMIgWWsPE(0lr13RanfSUPbELaTnL88eTpBH5bHPybjiizjmqSH2nnWReiYrBf9LsFdTf7Ak6x1jmnCDtd8kHBeZny1nIZnaSEyHYbCdO7glj06gXCdfNFeCYK6ZwyEqykw00cyFIDdisYnGGBepABk55jA)QoHPHJeeKSSKi2q7Mg4vce5OTI(sPVH2ko)i4Kj90AkXnI5gQiJYuSBaD3qSRPORkI75tVevFVc0uW6Mg4vc02uYZt0(SfMheMIfKGGKLLaIn0UPbELaroAROVu6BOTyxtr)QoHPHRBAGxjCJyUbi8CQFvNW0W1WRUrm3aeEo1VQtyA4AAbSpXUbeDdCf5tgSglMkKheEol1nct3Grr4gHPBacpN6x1jmnCnwmvi02uYZt0Es5yXJJ4QqibbjlKfeBODtd8kbIC0wrFP03qBfNFeCYKEAnLG2MsEEI2NTW8GWuSGeeKldbeBODtd8kbIC02uYZt0EEgq94iUkeAROVu6BOnTtAXrg4v0wfU6QxmktfmcswqccYLzbXgA30aVsGihTv0xk9n0gV278IrzQG1Qi7t)9mrs(jJBaD3Gf3iMBWQBqHZo5uMQRkIxSNp9m0AIhdNeL(jJUHf(xxlHBemOBacpN6QI4f75tpdTM4XWjrPFYOHxrBtjppr7AujkSWwOIeeKlVmIn0UPbELaroAROVu6BOTyxtr)QoHPHRBAGxjCJyUbi8CQFvNW0W1WRUrm3io3aeEo1VQtyA4AAbSpXUbeDdgfHBeMUb04gHPBacpN6x1jmnCnwmvi3iyq3aeEo1yHtbc1UwQgE1ncg0ny1ne7AkAadlL65tVevFVc0uW6Mg4vc3iE02uYZt0Es5yXJJ4Qqibb5YKnIn0UPbELaroAROVu6BOnfo7KtzQUxbAk25ByH)7bPpmGUHf(xxlHBeZny1naHNtDVc0uSZ3Wc)3dsFyaprbHNtn8QBeZny1ne7Ak6EfOPyNh8mSOBAGxjCJyUbRUHyxtrxve)tgpoIRcPBAGxjqBtjppr7jLJfpoIRcHeeKldni2qBtjpprBvK9PpYOlkwq7Mg4vce5ibb5YqlIn0UPbELaroAROVu6BOTyxtrJftELN4XQiJYuDtd8kbABk55jAJftELN4XQiJYuKGGC5WaXgA30aVsGihTv0xk9n0Mv3qSRPOxPpGD(EfOPy3JfDtd8kHBemOBWQBSwrpFA99kqtXoTPKFrrBtjppr7AujY3Ranf7qccYLxseBOTPKNNO99mrs(jJhKFcA30aVsGihjiixEjGydTb4l(KbbjlODtd8QhGV4tge5OTPKNNO98mG6XrCvi0wfU6QxmktfmcswqBf9LsFdTPDsloYaVI2nnWReiYrccYLjli2q7Mg4vce5ODtd8QhGV4tge5OTI(sPVH2a8ffOPOjESyPQUb0DJWaTnL88eTNNbupoIRcH2a8fFYGGKfKGGKSHaIn0gGV4tgeKSG2nnWREa(IpzqKJ2MsEEI2tkhlECexfcTBAGxjqKJeKG2eDAWNGydbjli2qBtjpprBY8jHhhvJI2nnWReiYrccYLrSH2a8fFYGGKf0UPbE1dWx8jdIC02uYZt0gV(0xiJDHkf7zOMQODtd8kbICKGGKSrSH2MsEEI2RC55jA30aVsGihjiiHgeBOTPKNNOnmU(xkagTBAGxjqKJeeKqlIn02uYZt0E(067vGMIDODtd8kbICKGGmmqSH2MsEEI2yHtb89kqtXo0UPbELarosqqUKi2q7Mg4vce5OTI(sPVH2S6gIDnfTHvnjSuvDtd8kHBemOBacpNAdRAsyPQA4v3iyq3qX5hbNmP2WQMewQQMwa7tSBaD3aAHaABk55jAdECoHFctdhjiixci2q7Mg4vce5OTI(sPVH2S6gIDnfTHvnjSuvDtd8kHBemOBacpNAdRAsyPQA4v02uYZt0gSuCPH(Kbjiijli2q7Mg4vce5OTI(sPVH2S6gIDnfTHvnjSuvDtd8kHBemOBacpNAdRAsyPQA4v3iyq3qX5hbNmP2WQMewQQMwa7tSBaD3aAHaABk55jApFAbpoNajiizbci2q7Mg4vce5OTI(sPVH2S6gIDnfTHvnjSuvDtd8kHBemOBacpNAdRAsyPQA4v3iyq3qX5hbNmP2WQMewQQMwa7tSBaD3aAHaABk55jABPQyHANxz3HeeKSWcIn0UPbELaroAROVu6BOnRUHyxtrByvtclvv30aVs4gbd6gS6gGWZP2WQMewQQgEfTnL88eTbngpF6f6RcHrccswwgXgA30aVsGihTnL88eTxPpaNs825jJTOOTI(sPVH2S6gGWZPEL(aCkXBNNm2IQHxrBv4QREXOmvWiizbjiizHSrSH2MsEEI2lkETuVWLcG2nnWReiYrccswGgeBODtd8kbIC0wrFP03qBwDdXUMIgWWsPE(0lr13RanfSUPbELWncg0naHNtnGHLs98PxIQVxbAkyn8kABk55jApT6fQL4jm(5jsqqYc0IydTBAGxjqKJ2k6lL(gABk5xuFZc8f7gq3nw2nI5gX5g41ENxmktfSwfzF6VNjsYpzCdO7gl7gbd6g41ENxmktfS(SfMhSgGBaD3yz3iE02uYZt0McNEtjpp93Jf0(ES4tdOOTXlsqqYsyGydTBAGxjqKJ2k6lL(gAZQBi21u0yHtb89kqtXoDtd8kHBeZnmL8lQVzb(IDdisYnwgTnL88eTPWP3uYZt)9ybTVhl(0akAJ)K5QxmktfKGGKLLeXgA30aVsGihTv0xk9n0wSRPOXcNc47vGMID6Mg4vc3iMByk5xuFZc8f7gqKKBSmABk55jAtHtVPKNN(7XcAFpw8Pbu0gxp(tMREXOmvqcsq7vAvCaqtqSHGKfeBODtd8kbIC0wrFP03qBwDdXUMIEL(a257vGMIDpw0nnWReOTPKNNODnQe57vGMIDibb5Yi2q7Mg4vce5OTI(sPVH2IDnfnw4uGqTRLQBAGxjCJyUrCUb1EcFx0u0gbbwR4WP4gq0niB3iyq3GApHVlAkAJGaR)0nGUBaTqWnIhTnL88eTXcNceQDTuKGGKSrSH2nnWReiYrBf9LsFdTf7Ak6EfOPyNh8mSOBAGxjqBtjppr7EfOPyNh8mSGeeKqdIn0UPbELaroAROVu6BOnRUHyxtr3Ranf78GNHfDtd8kbABk55jAF2cZdctXcsqqcTi2qBtjppr7vU88eTBAGxjqKJeKG2gVi2qqYcIn0UPbELaroAROVu6BOni8CQRkI)jJhhXvH0WROTPKNNODnQefwylurccYLrSH2MsEEI2Qi7tFKrxuSG2nnWReiYrccsYgXgA30aVsGihTv0xk9n0wSRPOXcNceQDTuDtd8kbABk55jAJfofiu7APibbj0GydTBAGxjqKJ2MsEEI2ZZaQhhXvHqBf9LsFdTnL8lQNGl65za1JJ4QqUbeDdY2nI5gMs(f13SaFXUbej5gqRBemOBqHZo5uMQXHchKwluPy)8lnCprbEC1nSW)6AjqBv4QREXOmvWiizbjiiHweBODtd8kbIC0wrFP03qBwDdtj)I6j4IEEgq94iUkeABk55jAppdOECexfcjiiddeBODtd8kbIC0wrFP03qBXUMIUQi(NmECexfs30aVs4gXCdaRhwOCa3a6KCJWacOTPKNNODvr8pz84iUkesqqUKi2q7Mg4vce5OTI(sPVH2IDnfTHvnjSuvDtd8kHBeZnIZny1nwROXcNc47vGMIDAtj)I6gX7gXCJ4CdwDdXUMI(vDctdx30aVs4gbd6gS6gGWZP(vDctdxdV6gXCdwDdfNFeCYK6x1jmnCn8QBepABk55jAByvtclvfjiixci2q7Mg4vce5OTI(sPVH2IDnf99Hf(j8agdG5fUuaDtd8kbABk55jAFFyHFcpGXayEHlfajiijli2q7Mg4vce5OTI(sPVH2u4StoLP6QI4f75tpdTM4XWjrPFYOByH)11s4gXCdwDdq45uxveVypF6zO1epgojk9tgn8kABk55jAxJkrECexfcjiizbci2q7Mg4vce5OTI(sPVH2u4StoLPAI2vHwao1JfEwDdl8VUwc3iMBeNBWQBi21u0R0hWoFVc0uS7XIUPbELWncg0nIZny1nwROXcNc47vGMIDAtj)I6gXCdwDJ1k65tRVxbAk2PnL8lQBeVBepABk55jAxJkr(EfOPyhsqqYcli2q7Mg4vce5OTPKNNO9zlmpimflOTI(sPVH241ENxmktfSwfzF6VNjsYpzCdi6gqJBemOBacpN6ZwyEmmLPA4v3iyq3io3qSRPObmSuQNp9su99kqtbRBAGxjCJyUbRUbi8CQbmSuQNp9su99kqtbRHxDJyUbG1dluoGBaDsUryab3iE0wfU6QxmktfmcswqccswwgXgA30aVsGihTv0xk9n0Mv3qSRPObmSuQNp9su99kqtbRBAGxjCJGbDdq45uJfofiu7APA4v3iyq3aW6HfkhWnGoj3io3Gfiab3yP2nGg3imDd8AVZlgLPcwRISp93Zej5NmUr8UrWGUbi8CQbmSuQNp9su99kqtbRHxDJGbDd8AVZlgLPcwRISp93Zej5NmUb0DdYgTnL88eTRrLOWcBHksqqYczJydTBAGxjqKJ2k6lL(gAdcpNASWPaHAxlvtlG9j2nGOBq2Ury6gmkc3imDdq45uJfofiu7APASyQqOTPKNNOTkY(0FptKKFYGeeKSani2q7Mg4vce5OTI(sPVH2GWZP(SfMhdtzQgE1nI5g41ENxmktfSwfzF6VNjsYpzCdi6gqJBeZnIZny1nwROXcNc47vGMIDAtj)I6gX7gXCdcUONNbupoIRcPLxf6tg02uYZt0(SfMheMIfKGGKfOfXgA30aVsGihTv0xk9n0wSRPO7vGMIDEWZWIUPbELWnI5g41ENxmktfSwfzF6VNjsYpzCdi6gqRBeZnIZny1nwROXcNc47vGMIDAtj)I6gXJ2MsEEI29kqtXop4zybjiizjmqSH2nnWReiYrBf9LsFdTf7AkAdRAsyPQ6Mg4vc02uYZt0(SfMhSgasqqYYsIydTnL88eTvr2N(7zIK8tg0UPbELarosqqYYsaXgA30aVsGihTBAGx9a8fFYGihTv0xk9n0geEo1NTW8yykt1WRUrm3qX5hbNmPNwtjOTPKNNO9zlmpimflOnaFXNmiizbjiizHSGydTb4l(KbbjlODtd8QhGV4tge5OTPKNNO98mG6XrCvi0wfU6QxmktfmcswqBf9LsFdTPDsloYaVI2nnWReiYrccYLHaIn0gGV4tgeKSG2nnWREa(IpzqKJ2MsEEI2tkhlECexfcTBAGxjqKJeKG246XFYC1lgLPcIneKSGydTBAGxjqKJ2MsEEI2ZZaQhhXvHqBf9LsFdTJZnOfW(e7gqKKBWOiCJ4DJyUrCUbi8CQpBH5XWuMQHxDJGbDdwDdq45udECoXbJfn8QBepARcxD1lgLPcgbjlibb5Yi2q7Mg4vce5OTI(sPVH2IDnfDVc0uSZdEgw0nnWReOTPKNNODVc0uSZdEgwqccsYgXgA30aVsGihTv0xk9n0wSRPOXcNceQDTuDtd8kHBeZnIZnaSEyHYbCdi6gqd04gXJ2MsEEI2yHtbc1Uwksqqcni2q7Mg4vce5OTI(sPVH2IDnfDvr8pz84iUkKUPbELaTnL88eTRkI)jJhhXvHqccsOfXgA30aVsGihTv0xk9n0geEo1K5tcpdmw0yXuHCdi6gSSeCJGbDdq45uF2cZJHPmvdVI2MsEEI2NTW8GWuSGeeKHbIn0UPbELaroAROVu6BOni8CQXcNceQDTun8kABk55jAFptKKFY4b5NGeeKljIn0UPbELaroAROVu6BOni8CQRkIxSNp9m0AIhdNeL(jJgEfTnL88eTRrLOWcBHksqqUeqSH2nnWReiYrBf9LsFdTJZnWR9oVyuMkyTkY(0FptKKFY4gq3nyXnI3nI5gX5gS6geCrppdOECexfst7KwCKbE1nIhTnL88eTRrLOWcBHksqqswqSH2nnWReiYrBf9LsFdTXR9oVyuMkyTkY(0FptKKFY4gq0nw2nI5gawpSq5aUb0j5gHbeCJyUrCUbi8CQjZNeEgySOXIPc5gq0nwgcUrWGUbG1dluoGBaD3GSab3iE3iyq3io3GcNDYPmvxveVypF6zO1epgojk9tgDdl8VUwc3iMBWQBacpN6QI4f75tpdTM4XWjrPFYOHxDJ4rBtjppr7AujYJJ4QqibbjlqaXgA30aVsGihTv0xk9n0oo3aeEo1yHtbc1UwQMwa7tSBar3axr(KbRXIPc5bHNZsDJW0nyueUry6gGWZPglCkqO21s1yXuHCJGbDdq45uJfofiu7APA4v3iMBacpNAadlL65tVevFVc0uWA4v3iE02uYZt0(EMij)KXdYpbjiizHfeBODtd8kbIC0wrFP03qBXUMI(vDctdx30aVs4gXCdXUMIgWWsPE(0lr13RanfSUPbELWnI5gGWZP(vDctdxdV6gXCdq45udyyPupF6LO67vGMcwdVI2MsEEI2tkhlECexfcjiizzzeBODtd8kbIC0wrFP03qBq45uByvtclvvdVI2MsEEI2NTW8GWuSGeeKSq2i2q7Mg4vce5OTI(sPVH2ko)i4Kj90AkXnI5gS6gIDnfnGHLs98PxIQVxbAkyDtd8kbABk55jAF2cZdctXcsqqYc0GydTBAGxjqKJ2k6lL(gAl21u0VQtyA46Mg4vc3iMBWQBeNBay9WcLd4gq3nwsO1nI5gko)i4Kj1NTW8GWuSOPfW(e7gqKKBab3iE02uYZt0(vDctdhjiizbArSH2nnWReiYrBf9LsFdTvC(rWjt6P1uIBeZnurgLPy3a6UHyxtrxve3ZNEjQ(EfOPG1nnWReOTPKNNO9zlmpimflibbjlHbIn0UPbELaroAROVu6BOTyxtr)QoHPHRBAGxjCJyUbi8CQFvNW0W1WROTPKNNO9KYXIhhXvHqccswwseBOTPKNNOTkY(0hz0fflODtd8kbICKGGKLLaIn0UPbELaroAROVu6BOTyxtrJftELN4XQiJYuDtd8kbABk55jAJftELN4XQiJYuKGGKfYcIn0UPbELaroAROVu6BOnRUHyxtrVsFa789kqtXUhl6Mg4vc3iyq3qSRPOxPpGD(EfOPy3JfDtd8kHBeZnIZny1nwROXcNc47vGMIDAtj)I6gXJ2MsEEI21OsKVxbAk2HeeKldbeBOTPKNNO99mrs(jJhKFcA30aVsGihjiixMfeBOnaFXNmiizbTBAGx9a8fFYGihTnL88eTNNbupoIRcH2QWvx9IrzQGrqYcAROVu6BOnTtAXrg4v0UPbELarosqqU8Yi2q7Mg4vce5ODtd8QhGV4tge5OTI(sPVH2a8ffOPOjESyPQUb0DJWaTnL88eTNNbupoIRcH2a8fFYGGKfKGGCzYgXgAdWx8jdcswq7Mg4vpaFXNmiYrBtjppr7jLJfpoIRcH2nnWReiYrcsqcABWseNI27ha(m555suQnfKGeec]] )

end
