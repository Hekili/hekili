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

            usable = function () return storm_elemental.up end,
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

    spec:RegisterPack( "Elemental", 20210413, [[dquFFbqiQcpsIsTjjYNKOKAusroLuuRcLQ6vuvmluk3sIsyxu5xufnmiLogKQLjr1ZacnnifUgkvSnuQY3qPsnouQKZbe06Guu18asUhKSpGuhesr0crjEOeLituIsIlce4KqkkReOAMsus6Mqks7eO8tifHNkvtfL0vHuuzVq9xbdwOdtzXq8ysnzeDzLnlPpJIrlHtRYRPQA2Q62a2TOFJQHlLoUeflhPNdA6exhHTlf(oq04LOe15PQ08PkTFsgJoMvCN0KHbRC0wo6OfnqheDLJoiYUaXYXDX32H7TM2VXmCpnGH7GGFalf7X9wZ3NBKywXDiNGQhUxislenVNEYCsbbItZb8eEaeVjhp1uRkEcpaTN4ocX9cAwIrWDstggSYrB5OJw0aDq0vo6Gi7QC2d3HTtJbRC2RCCV4ijxIrWDYb14oi4hWsXEvSxyawQahnzl9Eve9YztflhTLJUcCf4LLkSKzq08kWllur0SuZPTCQjtfHtKlzGoOyA)beIADuvSYPQiAMEvcQVSPIDHtb8V1oQtbEzHkIMKKufrtNmovfTKufbb(ovKxvrPyQyx4uav0ySlD4ElLxVF4Ezx2Qii4hWsXEvSxyawQaVSlBvenzl9Eve9YztflhTLJUcCf4LDzRILLkSKzq08kWl7Ywfllur0SuZPTCQjtfHtKlzGoOyA)beIADuvSYPQiAMEvcQVSPIDHtb8V1oQtbEzx2QyzHkIMKKufrtNmovfTKufbb(ovKxvrPyQyx4uav0ySlDkWvGx2QiiOS80eYivX1yuFvr5aMkkftfnTWPQ4bvrRHDVH8ZPa30YXtORLonhaXeuZOsry)awk2Z2vr5Hy)sX1spa7d7hWsX(dkULgYpsf4LTkIMdovSlCkG)T2rvXw60CaeturI8heQIqoWurJKeQIG8(xfHTgitveY5PtbUPLJNqxlDAoaIj(GYtOWPa(3AhLTRIsSFP4GcNc4FRDu3sd5hzPMO2rgwJLIZijHonNifqbIE9sTJmSglfNrscDxcA2bTnRa30YXtORLonhaXeFq55(bSuSpG8guy7QOe7xkU9dyPyFa5nO4wAi)ivGBA54j01sNMdGyIpO88TgwaHGcf2(lxqtIIDy7QO8qSFP42pGLI9bK3GIBPH8JubUPLJNqxlDAoaIj(GYZ6Balal4A)SDvu0vPdwyi)uGBA54j01sNMdGyIpO8SLlhpvGRaVSvr0SugLs0kQiVQIAdkqNcCtlhpH(GYtqEjzawmJQa30YXtOpO8e2E0taP9(hfgyOMESbWBCjdk0vGBA54j0huE2YLJNkWnTC8e6dkpjGlCYaGkWnTC8e6dkpRhDH9dyPyVcCtlhpH(GYtGjJtvGBA54j0huEcfofiSFalf7vGBA54j0huEoFxGxdsXcqHtby7QOqiQvN2(p8htHKxY4OdWUecAuOJwf4MwoEc9bLNipNtgQeuFz7QO8qSFP4mOEjPL65wAi)i96fHOwDguVK0s9CeTE9Q58NKdY0zq9ssl1ZrhGDje0SdAvGBA54j0huEImkCu)xYW2vr5Hy)sXzq9ssl1ZT0q(r61lcrT6mOEjPL65iAvGBA54j0huEwp6qEoNKTRIYdX(LIZG6LKwQNBPH8J0RxeIA1zq9ssl1Zr061RMZFsoitNb1ljTuphDa2LqqZoOvbUPLJNqFq5PL6bfQ9bT9pBxfLhI9lfNb1ljTup3sd5hPxVie1QZG6LKwQNJO1RxnN)KCqModQxsAPEo6aSlHGMDqRcCtlhpH(GYteJjWRbHEA)q2Ukkpe7xkodQxsAPEULgYpsVE9aHOwDguVK0s9CeTkWvGBA54j0huE2spaoL8SpasRXyt7R(xqmkZeik0z7QO8aHOwDT0dGtjp7dG0AmhrRcCtlhpH(GYZgd2oAq4YauGBA54j0huEwTfeQLWkb84jBxfLhI9lfhGbLrd8Aqkwy)awkq3sd5hPxVie1QdWGYObEniflSFalfOJOvbUcCtlhpH(GYtkrgmTC8m8huylnGHY4JTRIY0Y1yHLd4ge0LxQjy7(pigLzc0PlSld)Xui5LmGUCVEHT7)GyuMjq3BnSaYmaqxEZkWnTC8e6dkpPezW0YXZWFqHT0agk4Lm)cIrzMWguONwqHoBxfLhI9lfhu4uGW(bSuS3T0q(rwY0Y1yHLd4geuOkxbUPLJNqFq5jLidMwoEg(dkSLgWqbxaEjZVGyuMjSbf6PfuOZ2vrj2VuCqHtbc7hWsXE3sd5hzjtlxJfwoGBqqHQCf4kWnTC8e6m(qnJkfLHW8p2UkkeIA1nDb)sMaSGR97iAvGBA54j0z85dkp1f2LHcJ2yqrbUPLJNqNXNpO8ekCkG)T2rz7QOe7xkoOWPa(3Ah1T0q(rQa30YXtOZ4ZhuEwFdybybx7NnTV6FbXOmtGOqNTRIY0Y1ybsU4QVbSaSGR9dkqSKPLRXclhWniOqXoE9sjYv5uM5G(9fHoZ)OWq9g13a5ao4CRmexB7ivGBA54j0z85dkpRVbSaSGR9Z2vr5HPLRXcKCXvFdybybx7xbUPLJNqNXNpO8C6c(Lmbybx7NTRIsSFP4MUGFjtawW1(DlnKFKLaS9qHYbank2dTkWnTC8e6m(8bLNguVK0s9y7QOe7xkodQxsAPEULgYpYsn5r7ehu4uGW(bSuS3zA5ASMl1KhI9lf3PxLG6RBPH8J0RxpqiQv3PxLG6RJOTKhAo)j5GmDNEvcQVoI2MvGBA54j0z85dkp)RmehzaWyaSGWLbW2vrj2VuC)vgIJmaymawq4YaClnKFKkWnTC8e6m(8bLNZOsrawW1(z7QOOe5QCkZCtxWhmWRbg6mjajsYrVKXTYqCTTJSKhie1QB6c(GbEnWqNjbirso6LmoIwf4MwoEcDgF(GYZzuPiSFalf7z7QOOe5QCkZCKBTcDaCAak8CUvgIRTDKLAYdX(LIRLEa2h2pGLI9huClnKFKE92KhTtCqHtbc7hWsXENPLRXk5r7ex9OlSFalf7DMwUgR5MvGBA54j0z85dkpFRHfqiOqHnTV6FbXOmtGOqNTRIc2U)dIrzMaD6c7YWFmfsEjdOqdVEriQv3BnSaKGYmhrRxVnj2VuCagugnWRbPyH9dyPaDlnKFKL8aHOwDagugnWRbPyH9dyPaDeTLaS9qHYbank2dTnRaVSvrwP(QIcxfzmGPIGaJkfLHW8pveKNuOIOPgugvf5vvukMkcc(bSuGQicrTQIGSyPkwpMc5sgveevrXOmtGovSScplRfvK3yuT1QIOP2EOq5aEOa30YXtOZ4ZhuEoJkfLHW8p2Ukkpe7xkoadkJg41GuSW(bSuGULgYpsVEriQvhu4ua)BTJ6iA96fW2dfkha0OAcD0I2Yc0G9HT7)GyuMjqNUWUm8htHKxY0SxVie1QdWGYObEniflSFalfOJO1Rxy7(pigLzc0PlSld)Xui5LmGgevGx2QiAQ5FQiKGov0xoHksYZYArfFoCQOPIDHtb8V1oQkIquRof4MwoEcDgF(GYtDHDz4pMcjVKHTRIcHOwDqHtb8V1oQJoa7siOar2NrtY(ie1QdkCkG)T2rDqX0(vGx2QiAI89vf1guuXYQwdtfzHGcfvKNQOuq3urXOmtGQ4vvXtuXdQIwQIxcflfv0ssvSlCkGkcc(bSuSxfpOkcgAcwvrtlxJ5uGBA54j0z85dkpFRHfqiOqHTRIcHOwDV1WcqckZCeTLGT7)GyuMjqNUWUm8htHKxYak0OutE0oXbfofiSFalf7DMwUgR5sKCXvFdybybx73jN2)LmkWlBvenhCQii4hWsXEvKL3GIkAm2LqrfjAvrHRIGOkkgLzcufnOk(8KrfnOk2fofqfbb)awk2RIhuftUOIMwUgZPa30YXtOZ4ZhuEUFalf7diVbf2UkkX(LIB)awk2hqEdkULgYpYsW29FqmkZeOtxyxg(JPqYlzaf7uQjpAN4GcNce2pGLI9otlxJ1ScCtlhpHoJpFq55BnSaYma2UkkX(LIZG6LKwQNBPH8JubUPLJNqNXNpO8uxyxg(JPqYlzuGBA54j0z85dkpFRHfqiOqHnaEJlzqHoBxffcrT6ERHfGeuM5iAlP58NKdYmqNPff4MwoEcDgF(GYZ6Balal4A)SbWBCjdk0zt7R(xqmkZeik0z7QOORshSWq(Pa30YXtOZ4ZhuEwPCOeGfCTF2a4nUKbf6kWvGBA54j0bxaEjZVGyuMjOQVbSaSGR9ZM2x9VGyuMjquOZ2vr1eDa2LqqHIrt2CPMqiQv3BnSaKGYmhrRxVEGquRoKNZjFcO4iABwbUPLJNqhCb4Lm)cIrzM4dkp3pGLI9bK3GcBxfLy)sXTFalf7diVbf3sd5hPcCtlhpHo4cWlz(feJYmXhuEcfofW)w7OSDvuI9lfhu4ua)BTJ6wAi)il1eGThkuoaOqd0Ozf4MwoEcDWfGxY8ligLzIpO8C6c(Lmbybx7NTRIsSFP4MUGFjtawW1(DlnKFKkWnTC8e6GlaVK5xqmkZeFq55BnSacbfkSDvuie1QdKxsgyiGIdkM2pOqND51lcrT6ERHfGeuM5iAvGBA54j0bxaEjZVGyuMj(GYZ)ykK8sMac)f2UkkeIA1bfofW)w7OoIwf4MwoEcDWfGxY8ligLzIpO8CgvkkdH5FSDvuie1QB6c(GbEnWqNjbirso6LmoIwf4MwoEcDWfGxY8ligLzIpO8CgvkkdH5FSDvunbB3)bXOmtGoDHDz4pMcjVKb0O3CPM8GKlU6Balal4A)o6Q0blmKFnRa30YXtOdUa8sMFbXOmt8bLNZOsrawW1(z7QOGT7)GyuMjqNUWUm8htHKxYaQYlby7HcLdaAuShAl1ecrT6a5LKbgcO4GIP9dQYrRxVa2EOq5aGgeI2M96TjkrUkNYm30f8bd8AGHotcqIKC0lzCRmexB7il5bcrT6MUGpyGxdm0zsasKKJEjJJOTzf4MwoEcDWfGxY8ligLzIpO88pMcjVKjGWFHTRIQjeIA1bfofW)w7Oo6aSlHGcorUKb6GIP9hqiQ1rzFgnj7JquRoOWPa(3Ah1bft73RxeIA1bfofW)w7OoI2sie1QdWGYObEniflSFalfOJOTzf4MwoEcDWfGxY8ligLzIpO8Ss5qjal4A)SDvuI9lf3PxLG6RBPH8JSKy)sXbyqz0aVgKIf2pGLc0T0q(rwcHOwDNEvcQVoI2sie1QdWGYObEniflSFalfOJOvbUPLJNqhCb4Lm)cIrzM4dkpFRHfqiOqHTRIcHOwDguVK0s9CeTkWnTC8e6GlaVK5xqmkZeFq55BnSacbfkSDvuAo)j5Gmd0zAPKhI9lfhGbLrd8Aqkwy)awkq3sd5hPcCtlhpHo4cWlz(feJYmXhuEE6vjO(Y2vrj2VuCNEvcQVULgYpYsE0eGThkuoaOz3StjnN)KCqMU3AybeckuC0byxcbfk02ScCtlhpHo4cWlz(feJYmXhuE(wdlGqqHcBxfLMZFsoiZaDMwkPlmkZGGwSFP4MUGh41GuSW(bSuGULgYpsf4MwoEcDWfGxY8ligLzIpO8Ss5qjal4A)SDvuI9lf3PxLG6RBPH8JSecrT6o9QeuFDeTkWnTC8e6GlaVK5xqmkZeFq5PUWUmuy0gdkkWnTC8e6GlaVK5xqmkZeFq5jum50bYdQlmkZy7QOe7xkoOyYPdKhuxyuM5wAi)ivGBA54j0bxaEjZVGyuMj(GYZzuPiSFalf7z7QO8qSFP4APhG9H9dyPy)bf3sd5hPxVI9lfxl9aSpSFalf7pO4wAi)il1KhTtCqHtbc7hWsXENPLRXAwbUPLJNqhCb4Lm)cIrzM4dkp1f2LH)ykK8sg2Ukky7(pigLzc0PlSld)Xui5LmOkxbUPLJNqhCb4Lm)cIrzM4dkp)JPqYlzci8xuGBA54j0bxaEjZVGyuMj(GYZ6Balal4A)SbWBCjdk0zt7R(xqmkZeik0z7QOORshSWq(Pa30YXtOdUa8sMFbXOmt8bLN13awawW1(zdG34sguOZ2vrbWBmGLIJ8GIL6bA2tbUPLJNqhCb4Lm)cIrzM4dkpRuoucWcU2pBa8gxYGcDf4kWnTC8e6GxY8ligLzcQ6Balal4A)SP9v)ligLzcef6SDvun5HCA)xY41ljxC13awawW1(D0byxcbfkgnPxVI9lfNb1ljTup3sd5hzjsU4QVbSaSGR97OdWUecQM0C(tYbz6mOEjPL65OdWUe6dcrT6mOEjPL65ijOMC8S5sAo)j5GmDguVK0s9C0byxcbfA0CPMqiQv3BnSaKGYmhrRxVEGquRoKNZjFcO4iABwbUPLJNqh8sMFbXOmt8bLNguVK0s9y7QOe7xkodQxsAPEULgYpYsnjhWank2dTE9IquRoKNZjFcO4iABUutAo)j5GmDV1WcieuO4OdWUecA02CPM8qSFP4o9QeuFDlnKFKE96bcrT6o9QeuFDeTL8qZ5pjhKP70Rsq91r02ScCtlhpHo4Lm)cIrzM4dkp3pGLI9bK3GcBxfLy)sXTFalf7diVbf3sd5hzPMe7xkoadkJg41GuSW(bSuGULgYpYsnHquRoadkJg41GuSW(bSuGoI2sa2EOq5aGI9qRxVEGquRoadkJg41GuSW(bSuGoI2M961dX(LIdWGYObEniflSFalfOBPH8JSzf4MwoEcDWlz(feJYmXhuEcfofW)w7OSDvuI9lfhu4ua)BTJ6wAi)il1e1oYWASuCgjj0P5ePakq0RxQDKH1yP4mssO7sqZoOT5snby7HcLdak0anAwbUPLJNqh8sMFbXOmt8bLNtxWVKjal4A)SDvuI9lf30f8lzcWcU2VBPH8JSKMZFsoit3BnSacbfko6aSlHGcfAvGBA54j0bVK5xqmkZeFq55BnSacbfkSDvuI9lf30f8lzcWcU2VBPH8JSecrT6MUGFjtawW1(DeTkWnTC8e6GxY8ligLzIpO88VYqCKbaJbWccxgaBxfLy)sX9xzioYaGXaybHldWT0q(rQa30YXtOdEjZVGyuMj(GYZ)ykK8sMac)f2UkkeIA1bfofW)w7OoI2sW29FqmkZeOtxyxg(JPqYlzav5LAcHOwDagugnWRbPyH9dyPaDeTnRa30YXtOdEjZVGyuMj(GYZzuPOmeM)X2vrHquRUPl4dg41adDMeGej5OxY4iAl1Ky)sXbyqz0aVgKIf2pGLc0T0q(rwQjeIA1byqz0aVgKIf2pGLc0r061RMZFsoit3BnSacbfko6aSlHGgTLaS9qHYbankqy5E9cB3)bXOmtGoDHDz4pMcjVKbuLxcHOwDqHtb8V1oQJOTKMZFsoit3BnSacbfko6aSlHGcfJMSzVE9qSFP4amOmAGxdsXc7hWsb6wAi)i96vZ5pjhKPB)awk2hqEdko6aSlHGcf6o0zFgnj7xEZkWnTC8e6GxY8ligLzIpO8CgvkkdH5FSDvuW29FqmkZeOtxyxg(JPqYlzan6L8GKlU6Balal4A)o6Q0blmKFL8GsKRYPmZnDbFWaVgyOZKaKijh9sg3kdX12oYsn5Hy)sXbyqz0aVgKIf2pGLc0T0q(r61lcrT6amOmAGxdsXc7hWsb6iA96vZ5pjhKP7TgwaHGcfhDa2LqqJ2sa2EOq5aGgfiS8MvGBA54j0bVK5xqmkZeFq55mQueGfCTF2UkkX(LIdWGYObEniflSFalfOBPH8JSutie1QdWGYObEniflSFalfOJO1RxnN)KCqMU3AybeckuC0byxcbnAlby7HcLdaAuGWY96f2U)dIrzMaD6c7YWFmfsEjdOkVecrT6GcNc4FRDuhrBjnN)KCqMU3AybeckuC0byxcbfkgnzZE96Hy)sXbyqz0aVgKIf2pGLc0T0q(rQa30YXtOdEjZVGyuMj(GYZ)ykK8sMac)f2UkQMqiQvhu4ua)BTJ6OdWUeck4e5sgOdkM2FaHOwhL9z0KSpcrT6GcNc4FRDuhumTFVEriQvhu4ua)BTJ6iAlHquRoadkJg41GuSW(bSuGoI2MvGBA54j0bVK5xqmkZeFq5zLYHsawW1(z7QOe7xkUtVkb1x3sd5hzjX(LIdWGYObEniflSFalfOBPH8JSecrT6o9QeuFDeTLqiQvhGbLrd8Aqkwy)awkqhrRcCtlhpHo4Lm)cIrzM4dkpFRHfqiOqHTRIcHOwDguVK0s9CeTkWnTC8e6GxY8ligLzIpO88TgwaHGcf2UkknN)KCqMb6mTuYdX(LIdWGYObEniflSFalfOBPH8JubUPLJNqh8sMFbXOmt8bLNNEvcQVSDvuI9lf3PxLG6RBPH8JSKhnby7HcLdaA2n7usZ5pjhKP7TgwaHGcfhDa2LqqHcTnRa30YXtOdEjZVGyuMj(GYZ3Aybeckuy7QO0C(tYbzgOZ0sjDHrzge0I9lf30f8aVgKIf2pGLc0T0q(rQa30YXtOdEjZVGyuMj(GYZkLdLaSGR9Z2vrj2VuCNEvcQVULgYpYsie1Q70Rsq91r0wcHOwDNEvcQVo6aSlHGcorUKb6GIP9hqiQ1rzFgnj7JquRUtVkb1xhumTFf4MwoEcDWlz(feJYmXhuE(wdlGqqHcBxfLMZFsoiZaDMwuGBA54j0bVK5xqmkZeFq5z9nGfGfCTF20(Q)feJYmbIcD2Ukk6Q0blmKFkWnTC8e6GxY8ligLzIpO8CgvkkdH5FSDvuW29FqmkZeOtxyxg(JPqYlzan6L8GsKRYPmZnDbFWaVgyOZKaKijh9sg3kdX12osVEriQv30f8bd8AGHotcqIKC0lzCeTkWnTC8e6GxY8ligLzIpO8Ss5qjal4A)SDvuI9lf3PxLG6RBPH8JSecrT6o9QeuFDeTLAcHOwDNEvcQVo6aSlHGIrtY(Ob7JquRUtVkb1xhumTFVEriQvhu4ua)BTJ6iA961dX(LIdWGYObEniflSFalfOBPH8JSzf4MwoEcDWlz(feJYmXhuEwPCOeGfCTF2UkkkrUkNYm3(bSuSpSYqC)Hqpca3kdX12oYsEGquRU9dyPyFyLH4(dHEeabYHquRoI2sEi2VuC7hWsX(aYBqXT0q(rwYdX(LIB6c(Lmbybx73T0q(rQa30YXtOdEjZVGyuMj(GYtDHDzOWOnguuGBA54j0bVK5xqmkZeFq5jum50bYdQlmkZy7QOe7xkoOyYPdKhuxyuM5wAi)ivGBA54j0bVK5xqmkZeFq55mQue2pGLI9SDvuEi2VuCT0dW(W(bSuS)GIBPH8J0RxpAN4QhDH9dyPyVZ0Y1ykWnTC8e6GxY8ligLzIpO8uxyxg(JPqYlzy7QOGT7)GyuMjqNUWUm8htHKxYGQCf4MwoEcDWlz(feJYmXhuE(htHKxYeq4VOa30YXtOdEjZVGyuMj(GYZ6Balal4A)SbWBCjdk0zt7R(xqmkZeik0z7QOORshSWq(Pa30YXtOdEjZVGyuMj(GYZ6Balal4A)SbWBCjdk0z7QOa4ngWsXrEqXs9an7Pa30YXtOdEjZVGyuMj(GYZkLdLaSGR9ZgaVXLmOqh3Bmk84jgSYrB5OJw0aTGiUdsJMxYaXD0mGwovgPkYoQOPLJNQ4Fqb6uGJ7)bfiMvChEjZVGyuMjywXGHoMvCFPH8JeZcUBA54jUxFdybybx7h310tg9mCVjv0dvuoT)lzurVEvrsU4QVbSaSGR97OdWUeQIGcLkYOjvrVEvrX(LIZG6LKwQNBPH8JuflPIKCXvFdybybx73rhGDjufbLk2KkQ58NKdY0zq9ssl1ZrhGDjuf9rfriQvNb1ljTuphjb1KJNQyZQyjvuZ5pjhKPZG6LKwQNJoa7sOkckvenuXMvXsQytQicrT6ERHfGeuM5iAvrVEvrpureIA1H8Co5tafhrRk2mUR9v)ligLzcedg6ybdw5ywX9LgYpsml4UMEYONH7I9lfNb1ljTup3sd5hPkwsfBsfLdyQiOrPIShAvrVEvreIA1H8Co5tafhrRk2SkwsfBsf1C(tYbz6ERHfqiOqXrhGDjufbTkIwvSzvSKk2Kk6Hkk2VuCNEvcQVULgYpsv0Rxv0dveHOwDNEvcQVoIwvSKk6HkQ58NKdY0D6vjO(6iAvXMXDtlhpXDdQxsAPEybdgiIzf3xAi)iXSG7A6jJEgUl2VuC7hWsX(aYBqXT0q(rQILuXMurX(LIdWGYObEniflSFalfOBPH8JuflPInPIie1QdWGYObEniflSFalfOJOvflPIa2EOq5aQiOur2dTQOxVQOhQicrT6amOmAGxdsXc7hWsb6iAvXMvrVEvrpurX(LIdWGYObEniflSFalfOBPH8JufBg3nTC8e33pGLI9bK3GcwWGHgywX9LgYpsml4UMEYONH7I9lfhu4ua)BTJ6wAi)ivXsQytQi1oYWASuCgjj0P5ePOIGsfbrv0RxvKAhzynwkoJKe6UufbTkYoOvfBwflPInPIa2EOq5aQiOur0anuXMXDtlhpXDOWPa(3AhflyWyhmR4(sd5hjMfCxtpz0ZWDX(LIB6c(Lmbybx73T0q(rQILurnN)KCqMU3AybeckuC0byxcvrqHsfrlUBA54jUpDb)sMaSGR9JfmyShMvCFPH8JeZcURPNm6z4Uy)sXnDb)sMaSGR97wAi)ivXsQicrT6MUGFjtawW1(DeT4UPLJN4(BnSacbfkybdg7gZkUV0q(rIzb310tg9mCxSFP4(RmehzaWyaSGWLb4wAi)iXDtlhpX9)kdXrgamgaliCzaybdg7cZkUV0q(rIzb310tg9mChHOwDqHtb8V1oQJOvflPIW29FqmkZeOtxyxg(JPqYlzurqPILRILuXMureIA1byqz0aVgKIf2pGLc0r0QInJ7MwoEI7)Xui5Lmbe(lybdgieZkUV0q(rIzb310tg9mChHOwDtxWhmWRbg6mjajsYrVKXr0QILuXMurX(LIdWGYObEniflSFalfOBPH8JuflPInPIie1QdWGYObEniflSFalfOJOvf96vf1C(tYbz6ERHfqiOqXrhGDjufbTkIwvSKkcy7HcLdOIGgLkcclxf96vfHT7)GyuMjqNUWUm8htHKxYOIGsflxflPIie1QdkCkG)T2rDeTQyjvuZ5pjhKP7TgwaHGcfhDa2LqveuOurgnPk2Sk61Rk6Hkk2VuCagugnWRbPyH9dyPaDlnKFKQOxVQOMZFsoit3(bSuSpG8guC0byxcvrqHsfr3HUkY(QiJMufzFvSCvSzC30YXtCFgvkkdH5Fybdg6OfZkUV0q(rIzb310tg9mCh2U)dIrzMaD6c7YWFmfsEjJkcAveDvSKk6HksYfx9nGfGfCTFhDv6GfgYpvSKk6HksjYv5uM5MUGpyGxdm0zsasKKJEjJBLH4ABhPkwsfBsf9qff7xkoadkJg41GuSW(bSuGULgYpsv0RxveHOwDagugnWRbPyH9dyPaDeTQOxVQOMZFsoit3BnSacbfko6aSlHQiOvr0QILuraBpuOCave0Ourqy5QyZ4UPLJN4(mQuugcZ)Wcgm0rhZkUV0q(rIzb310tg9mCxSFP4amOmAGxdsXc7hWsb6wAi)ivXsQytQicrT6amOmAGxdsXc7hWsb6iAvrVEvrnN)KCqMU3AybeckuC0byxcvrqRIOvflPIa2EOq5aQiOrPIGWYvrVEvry7(pigLzc0PlSld)Xui5LmQiOuXYvXsQicrT6GcNc4FRDuhrRkwsf1C(tYbz6ERHfqiOqXrhGDjufbfkvKrtQInRIE9QIEOII9lfhGbLrd8Aqkwy)awkq3sd5hjUBA54jUpJkfbybx7hlyWqVCmR4(sd5hjMfCxtpz0ZW9MureIA1bfofW)w7Oo6aSlHQiOur4e5sgOdkM2FaHOwhvfzFvKrtQISVkIquRoOWPa(3Ah1bft7xf96vfriQvhu4ua)BTJ6iAvXsQicrT6amOmAGxdsXc7hWsb6iAvXMXDtlhpX9)ykK8sMac)fSGbdDqeZkUV0q(rIzb310tg9mCxSFP4o9QeuFDlnKFKQyjvuSFP4amOmAGxdsXc7hWsb6wAi)ivXsQicrT6o9QeuFDeTQyjveHOwDagugnWRbPyH9dyPaDeT4UPLJN4ELYHsawW1(Xcgm0rdmR4(sd5hjMfCxtpz0ZWDeIA1zq9ssl1Zr0I7MwoEI7V1WcieuOGfmyOZoywX9LgYpsml4UMEYONH7Ao)j5Gmd0zArflPIEOII9lfhGbLrd8Aqkwy)awkq3sd5hjUBA54jU)wdlGqqHcwWGHo7Hzf3xAi)iXSG7A6jJEgUl2VuCNEvcQVULgYpsvSKk6Hk2Kkcy7HcLdOIGwfz3SJkwsf1C(tYbz6ERHfqiOqXrhGDjufbfkveTQyZ4UPLJN4(PxLG6lwWGHo7gZkUV0q(rIzb310tg9mCxZ5pjhKzGotlQyjvuxyuMbvrqRII9lf30f8aVgKIf2pGLc0T0q(rI7MwoEI7V1WcieuOGfmyOZUWSI7lnKFKywWDn9Krpd3f7xkUtVkb1x3sd5hPkwsfriQv3PxLG6RJOvflPIie1Q70Rsq91rhGDjufbLkcNixYaDqX0(die16OQi7RImAsvK9vreIA1D6vjO(6GIP9J7MwoEI7vkhkbybx7hlyWqheIzf3xAi)iXSG7A6jJEgUR58NKdYmqNPfC30YXtC)TgwaHGcfSGbRC0Izf3xAi)iXSG7MwoEI713awawW1(XDn9Krpd3PRshSWq(H7AF1)cIrzMaXGHowWGvo6ywX9LgYpsml4UMEYONH7W29FqmkZeOtxyxg(JPqYlzurqRIORILurpurkrUkNYm30f8bd8AGHotcqIKC0lzCRmexB7ivrVEvreIA1nDbFWaVgyOZKaKijh9sghrlUBA54jUpJkfLHW8pSGbR8YXSI7lnKFKywWDn9Krpd3f7xkUtVkb1x3sd5hPkwsfriQv3PxLG6RJOvflPInPIie1Q70Rsq91rhGDjufbLkYOjvr2xfrdvK9vreIA1D6vjO(6GIP9RIE9QIie1QdkCkG)T2rDeTQOxVQOhQOy)sXbyqz0aVgKIf2pGLc0T0q(rQInJ7MwoEI7vkhkbybx7hlyWkheXSI7lnKFKywWDn9Krpd3Pe5QCkZC7hWsX(WkdX9hc9iaCRmexB7ivXsQOhQicrT62pGLI9HvgI7pe6raeihcrT6iAvXsQOhQOy)sXTFalf7diVbf3sd5hPkwsf9qff7xkUPl4xYeGfCTF3sd5hjUBA54jUxPCOeGfCTFSGbRC0aZkUBA54jURlSldfgTXGcUV0q(rIzblyWkNDWSI7lnKFKywWDn9Krpd3f7xkoOyYPdKhuxyuM5wAi)iXDtlhpXDOyYPdKhuxyuMHfmyLZEywX9LgYpsml4UMEYONH7EOII9lfxl9aSpSFalf7pO4wAi)ivrVEvrpuX2jU6rxy)awk27mTCngUBA54jUpJkfH9dyPypwWGvo7gZkUV0q(rIzb310tg9mCh2U)dIrzMaD6c7YWFmfsEjJkIsflh3nTC8e31f2LH)ykK8sgSGbRC2fMvC30YXtC)pMcjVKjGWFb3xAi)iXSGfmyLdcXSI7a8gxYGbdDCFPH8laWBCjdMfC30YXtCV(gWcWcU2pUR9v)ligLzcedg64UMEYONH70vPdwyi)W9LgYpsmlybdgiIwmR4(sd5hjMfCFPH8laWBCjdMfCxtpz0ZWDaEJbSuCKhuSupve0Qi7H7MwoEI713awawW1(XDaEJlzWGHowWGbIOJzf3b4nUKbdg64(sd5xaG34sgml4UPLJN4ELYHsawW1(X9LgYpsmlybl4o5QgXlywXGHoMvCFPH8JeZcUtoOMETYXtChnlLrPeTIkYRQO2Gc0H7MwoEI7G8sYaSygflyWkhZkUdWBCjdgm0X9LgYVaaVXLmywWDtlhpXDy7rpbK27FuyGHA6H7lnKFKywWcgmqeZkUBA54jU3YLJN4(sd5hjMfSGbdnWSI7MwoEI7eWfozaqCFPH8JeZcwWGXoywXDtlhpX96rxy)awk2J7lnKFKywWcgm2dZkUBA54jUdmzCkUV0q(rIzblyWy3ywXDtlhpXDOWPaH9dyPypUV0q(rIzblyWyxywX9LgYpsml4UMEYONH7ie1QtB)h(JPqYlzC0byxcvrqJsfrhT4UPLJN4(8DbEniflafofalyWaHywX9LgYpsml4UMEYONH7EOII9lfNb1ljTup3sd5hPk61RkIquRodQxsAPEoIwv0RxvuZ5pjhKPZG6LKwQNJoa7sOkcAvKDqlUBA54jUJ8CozOsq9flyWqhTywX9LgYpsml4UMEYONH7EOII9lfNb1ljTup3sd5hPk61RkIquRodQxsAPEoIwC30YXtChzu4O(VKblyWqhDmR4(sd5hjMfCxtpz0ZWDpurX(LIZG6LKwQNBPH8Juf96vfriQvNb1ljTuphrRk61RkQ58NKdY0zq9ssl1ZrhGDjufbTkYoOf3nTC8e3RhDipNtIfmyOxoMvCFPH8JeZcURPNm6z4UhQOy)sXzq9ssl1ZT0q(rQIE9QIie1QZG6LKwQNJOvf96vf1C(tYbz6mOEjPL65OdWUeQIGwfzh0I7MwoEI7wQhuO2h02)ybdg6GiMvCFPH8JeZcURPNm6z4UhQOy)sXzq9ssl1ZT0q(rQIE9QIEOIie1QZG6LKwQNJOf3nTC8e3rmMaVge6P9dXcgm0rdmR4(sd5hjMfC30YXtCVLEaCk5zFaKwJH7A6jJEgU7HkIquRUw6bWPKN9bqAnMJOf31(Q)feJYmbIbdDSGbdD2bZkUBA54jU3yW2rdcxgaUV0q(rIzblyWqN9WSI7lnKFKywWDn9Krpd39qff7xkoadkJg41GuSW(bSuGULgYpsv0RxveHOwDagugnWRbPyH9dyPaDeT4UPLJN4E1wqOwcReWJNybdg6SBmR4(sd5hjMfCxtpz0ZWDtlxJfwoGBqve0Qy5QyjvSjve2U)dIrzMaD6c7YWFmfsEjJkcAvSCv0Rxve2U)dIrzMaDV1WciZaurqRILRInJ7MwoEI7uImyA54z4pOG7)bLqAad3n(Wcgm0zxywX9LgYpsml4UMEYONH7EOII9lfhu4uGW(bSuS3T0q(rQILurtlxJfwoGBqveuOuXYXDOqpTGbdDC30YXtCNsKbtlhpd)bfC)pOesdy4o8sMFbXOmtWcgm0bHywX9LgYpsml4UMEYONH7I9lfhu4uGW(bSuS3T0q(rQILurtlxJfwoGBqveuOuXYXDOqpTGbdDC30YXtCNsKbtlhpd)bfC)pOesdy4oCb4Lm)cIrzMGfSG7T0P5aiMGzfdg6ywX9LgYpsml4UPLJN4(mQue2pGLI94o5GA61khpXDqqz5PjKrQIRXO(QIYbmvukMkAAHtvXdQIwd7Ed5Nd310tg9mC3dvuSFP4APhG9H9dyPy)bf3sd5hjwWGvoMvCFPH8JeZcUBA54jUdfofW)w7O4o5GA61khpXD0CWPIDHtb8V1oQk2sNMdGyIksK)GqveYbMkAKKqveK3)QiS1azQIqopD4UMEYONH7I9lfhu4ua)BTJ6wAi)ivXsQytQi1oYWASuCgjj0P5ePOIGsfbrv0RxvKAhzynwkoJKe6UufbTkYoOvfBglyWarmR4(sd5hjMfCxtpz0ZWDX(LIB)awk2hqEdkULgYpsC30YXtCF)awk2hqEdkybdgAGzf3xAi)iXSG7MwoEI7V1WcieuOG7A6jJEgU7Hkk2VuC7hWsX(aYBqXT0q(rI7)LlOjXD2blyWyhmR4(sd5hjMfCxtpz0ZWD6Q0blmKF4UPLJN4E9nGfGfCTFSGbJ9WSI7MwoEI7TC54jUV0q(rIzblyb3n(WSIbdDmR4(sd5hjMfCxtpz0ZWDeIA1nDb)sMaSGR97iAXDtlhpX9zuPOmeM)HfmyLJzf3nTC8e31f2LHcJ2yqb3xAi)iXSGfmyGiMvCFPH8JeZcURPNm6z4Uy)sXbfofW)w7OULgYpsC30YXtChkCkG)T2rXcgm0aZkUV0q(rIzb3nTC8e3RVbSaSGR9J7A6jJEgUBA5ASajxC13awawW1(vrqPIGOkwsfnTCnwy5aUbvrqHsfzhv0RxvKsKRYPmZb97lcDM)rHH6nQVbYbCW5wziU22rI7AF1)cIrzMaXGHowWGXoywX9LgYpsml4UMEYONH7EOIMwUglqYfx9nGfGfCTFC30YXtCV(gWcWcU2pwWGXEywX9LgYpsml4UMEYONH7I9lf30f8lzcWcU2VBPH8JuflPIa2EOq5aQiOrPIShAXDtlhpX9Pl4xYeGfCTFSGbJDJzf3xAi)iXSG7A6jJEgUl2VuCguVK0s9ClnKFKQyjvSjv0dvSDIdkCkqy)awk27mTCnMk2SkwsfBsf9qff7xkUtVkb1x3sd5hPk61Rk6HkIquRUtVkb1xhrRkwsf9qf1C(tYbz6o9QeuFDeTQyZ4UPLJN4Ub1ljTupSGbJDHzf3xAi)iXSG7A6jJEgUl2VuC)vgIJmaymawq4YaClnKFK4UPLJN4(FLH4idagdGfeUmaSGbdeIzf3xAi)iXSG7A6jJEgUtjYv5uM5MUGpyGxdm0zsasKKJEjJBLH4ABhPkwsf9qfriQv30f8bd8AGHotcqIKC0lzCeT4UPLJN4(mQueGfCTFSGbdD0Izf3xAi)iXSG7A6jJEgUtjYv5uM5i3Af6a40au45CRmexB7ivXsQytQOhQOy)sX1spa7d7hWsX(dkULgYpsv0RxvSjv0dvSDIdkCkqy)awk27mTCnMkwsf9qfBN4QhDH9dyPyVZ0Y1yQyZQyZ4UPLJN4(mQue2pGLI9ybdg6OJzf3xAi)iXSG7MwoEI7V1WcieuOG7A6jJEgUdB3)bXOmtGoDHDz4pMcjVKrfbLkIgQOxVQicrT6ERHfGeuM5iAvrVEvXMurX(LIdWGYObEniflSFalfOBPH8JuflPIEOIie1QdWGYObEniflSFalfOJOvflPIa2EOq5aQiOrPIShAvXMXDTV6FbXOmtGyWqhlyWqVCmR4(sd5hjMfC30YXtCFgvkkdH5F4o5GA61khpXDwP(QIcxfzmGPIGaJkfLHW8pveKNuOIOPgugvf5vvukMkcc(bSuGQicrTQIGSyPkwpMc5sgveevrXOmtGovSScplRfvK3yuT1QIOP2EOq5aEG7A6jJEgU7Hkk2VuCagugnWRbPyH9dyPaDlnKFKQOxVQicrT6GcNc4FRDuhrRk61Rkcy7HcLdOIGgLk2KkIoArRkwwOIOHkY(QiSD)heJYmb60f2LH)ykK8sgvSzv0RxveHOwDagugnWRbPyH9dyPaDeTQOxVQiSD)heJYmb60f2LH)ykK8sgve0QiiIfmyOdIywX9LgYpsml4UPLJN4UUWUm8htHKxYG7KdQPxRC8e3rtn)tfHe0PI(YjursEwwlQ4ZHtfnvSlCkG)T2rvreIA1H7A6jJEgUJquRoOWPa(3Ah1rhGDjufbLkcIQi7RImAsvK9vreIA1bfofW)w7OoOyA)ybdg6ObMvCFPH8JeZcUBA54jU)wdlGqqHcUtoOMETYXtChnr((QIAdkQyzvRHPISqqHIkYtvukOBQOyuMjqv8QQ4jQ4bvrlvXlHILIkAjPk2fofqfbb)awk2RIhufbdnbRQOPLRXC4UMEYONH7ie1Q7TgwasqzMJOvflPIW29FqmkZeOtxyxg(JPqYlzurqPIOHkwsfBsf9qfBN4GcNce2pGLI9otlxJPInRILursU4QVbSaSGR97Kt7)sgSGbdD2bZkUV0q(rIzb3nTC8e33pGLI9bK3GcUtoOMETYXtChnhCQii4hWsXEvKL3GIkAm2LqrfjAvrHRIGOkkgLzcufnOk(8KrfnOk2fofqfbb)awk2RIhuftUOIMwUgZH7A6jJEgUl2VuC7hWsX(aYBqXT0q(rQILury7(pigLzc0PlSld)Xui5LmQiOur2rflPInPIEOITtCqHtbc7hWsXENPLRXuXMXcgm0zpmR4(sd5hjMfCxtpz0ZWDX(LIZG6LKwQNBPH8Je3nTC8e3FRHfqMbGfmyOZUXSI7MwoEI76c7YWFmfsEjdUV0q(rIzblyWqNDHzf3xAi)iXSG7lnKFbaEJlzWSG7A6jJEgUJquRU3AybibLzoIwvSKkQ58NKdYmqNPfC30YXtC)TgwaHGcfChG34sgmyOJfmyOdcXSI7a8gxYGbdDCFPH8laWBCjdMfC30YXtCV(gWcWcU2pUR9v)ligLzcedg64UMEYONH70vPdwyi)W9LgYpsmlybdw5OfZkUdWBCjdgm0X9LgYVaaVXLmywWDtlhpX9kLdLaSGR9J7lnKFKywWcwWD4cWlz(feJYmbZkgm0XSI7lnKFKywWDtlhpX96Balal4A)4UMEYONH7nPI0byxcvrqHsfz0KQyZQyjvSjveHOwDV1WcqckZCeTQOxVQOhQicrT6qEoN8jGIJOvfBg31(Q)feJYmbIbdDSGbRCmR4(sd5hjMfCxtpz0ZWDX(LIB)awk2hqEdkULgYpsC30YXtCF)awk2hqEdkybdgiIzf3xAi)iXSG7A6jJEgUl2VuCqHtb8V1oQBPH8JuflPInPIa2EOq5aQiOur0anuXMXDtlhpXDOWPa(3AhflyWqdmR4(sd5hjMfCxtpz0ZWDX(LIB6c(Lmbybx73T0q(rI7MwoEI7txWVKjal4A)ybdg7Gzf3xAi)iXSG7A6jJEgUJquRoqEjzGHakoOyA)QiOur0zxQOxVQicrT6ERHfGeuM5iAXDtlhpX93AybeckuWcgm2dZkUV0q(rIzb310tg9mChHOwDqHtb8V1oQJOf3nTC8e3)JPqYlzci8xWcgm2nMvCFPH8JeZcURPNm6z4ocrT6MUGpyGxdm0zsasKKJEjJJOf3nTC8e3NrLIYqy(hwWGXUWSI7lnKFKywWDn9Krpd3BsfHT7)GyuMjqNUWUm8htHKxYOIGwfrxfBwflPInPIEOIKCXvFdybybx73rxLoyHH8tfBg3nTC8e3NrLIYqy(hwWGbcXSI7lnKFKywWDn9Krpd3HT7)GyuMjqNUWUm8htHKxYOIGsflxflPIa2EOq5aQiOrPIShAvXsQytQicrT6a5LKbgcO4GIP9RIGsflhTQOxVQiGThkuoGkcAveeIwvSzv0RxvSjvKsKRYPmZnDbFWaVgyOZKaKijh9sg3kdX12osvSKk6HkIquRUPl4dg41adDMeGej5OxY4iAvXMXDtlhpX9zuPial4A)ybdg6OfZkUV0q(rIzb310tg9mCVjveHOwDqHtb8V1oQJoa7sOkckveorUKb6GIP9hqiQ1rvr2xfz0KQi7RIie1QdkCkG)T2rDqX0(vrVEvreIA1bfofW)w7OoIwvSKkIquRoadkJg41GuSW(bSuGoIwvSzC30YXtC)pMcjVKjGWFblyWqhDmR4(sd5hjMfCxtpz0ZWDX(LI70Rsq91T0q(rQILurX(LIdWGYObEniflSFalfOBPH8JuflPIie1Q70Rsq91r0QILureIA1byqz0aVgKIf2pGLc0r0I7MwoEI7vkhkbybx7hlyWqVCmR4(sd5hjMfCxtpz0ZWDeIA1zq9ssl1Zr0I7MwoEI7V1WcieuOGfmyOdIywX9LgYpsml4UMEYONH7Ao)j5Gmd0zArflPIEOII9lfhGbLrd8Aqkwy)awkq3sd5hjUBA54jU)wdlGqqHcwWGHoAGzf3xAi)iXSG7A6jJEgUl2VuCNEvcQVULgYpsvSKk6Hk2Kkcy7HcLdOIGwfz3SJkwsf1C(tYbz6ERHfqiOqXrhGDjufbfkveTQyZ4UPLJN4(PxLG6lwWGHo7Gzf3xAi)iXSG7A6jJEgUR58NKdYmqNPfvSKkQlmkZGQiOvrX(LIB6cEGxdsXc7hWsb6wAi)iXDtlhpX93AybeckuWcgm0zpmR4(sd5hjMfCxtpz0ZWDX(LI70Rsq91T0q(rQILureIA1D6vjO(6iAXDtlhpX9kLdLaSGR9JfmyOZUXSI7MwoEI76c7YqHrBmOG7lnKFKywWcgm0zxywX9LgYpsml4UMEYONH7I9lfhum50bYdQlmkZClnKFK4UPLJN4oum50bYdQlmkZWcgm0bHywX9LgYpsml4UMEYONH7EOII9lfxl9aSpSFalf7pO4wAi)ivrVEvrX(LIRLEa2h2pGLI9huClnKFKQyjvSjv0dvSDIdkCkqy)awk27mTCnMk2mUBA54jUpJkfH9dyPypwWGvoAXSI7lnKFKywWDn9Krpd3HT7)GyuMjqNUWUm8htHKxYOIOuXYXDtlhpXDDHDz4pMcjVKblyWkhDmR4UPLJN4(FmfsEjtaH)cUV0q(rIzblyWkVCmR4oaVXLmyWqh3xAi)ca8gxYGzb3nTC8e3RVbSaSGR9J7AF1)cIrzMaXGHoURPNm6z4oDv6GfgYpCFPH8JeZcwWGvoiIzf3xAi)iXSG7lnKFbaEJlzWSG7A6jJEgUdWBmGLIJ8GIL6PIGwfzpC30YXtCV(gWcWcU2pUdWBCjdgm0XcgSYrdmR4oaVXLmyWqh3xAi)ca8gxYGzb3nTC8e3RuoucWcU2pUV0q(rIzblybl4UrifCkU3paI3KJNLLOwvWcwWya]] )


end
