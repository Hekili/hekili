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

    spec:RegisterPack( "Elemental", 20210403, [[dq0JDbqiuQEKuuztsKpjrj1OKO6usrwfvH6vuLmluk3sIsyxu5xufnmGkhdHAzaHNbezAarDnPOSnQc5BufKXrvqDoQc06OkGAEiKUhc2hcXbLIQ0crjEOeLituIsIlkrPojvbyLaLzkrjPBkfv1obs)ukQINkvtfL0vPkGSxq)vWGf6WuwmuEmjtgrxwzZs6ZOy0s40Q8AQkZwv3gWUf9BunCP0XLOy5i9CitN46q12LcFhOQXlrjQZtvQ5tv1(j1qIHSc7KMmiOGaCGGyWbYGdKCetCZab4AgSlE3oyV1u(mMb7PbmyVS)bSuSh2BnVFUrczf2rCCQAWEHiTipWE6jZjf4yofhWt0bG)MC8urTQ4j6auEc7y43lEajed2jnzqqbb4abXGdKbhi5iM4MbcWbsWoQDkiOGWJabSxCKKlHyWo5qkyVS)bSuSxh7fgGLAWAEBP3RJGeB6iiahiiwdMgSYsfwYmKhynyLf6OhqQ40wo1KPJOjYLmihsmLVagEToQow5uD0dqTko1B20XUWPa(2Ah1PbRSqhBEjj1XM)KXP6OLK6yz790rEvhLIPJDHtb0rJXU0b7TuE9(b7nxZPJL9pGLI96yVWaSudwZ1C6yZBl9EDeKythbb4abXAW0G1CnNowwQWsMH8aRbR5AoDSSqh9asfN2YPMmDenrUKb5qIP8fWWR1r1XkNQJEaQvXPEZMo2fofW3w7OonynxZPJLf6yZljPo28NmovhTKuhlBVNoYR6OumDSlCkGoAm2LonyAWAoDSSllpfUmsDCng1BDuoGPJsX0rtjCQoEiD0Ay3By)CAWmLC8e5APtXbWmHWmQue2pGLI9SDvcSl2VuCT0dW(W(bSuS)qIBPH9JudwZPJEGqth7cNc4BRDuDSLofhaZeDep)Hq6iIdmD0ijr6i4V)1ruRb(uhrCE60Gzk54jY1sNIdGzIxe8ejCkGVT2rz7Qee7xkoKWPa(2Ah1T0W(rwQCQDKH1yP4mssKtXXtHOGKF)u7idRXsXzKKi3LePzGRjnyMsoEICT0P4ayM4fbp3pGLI9bS3qcBxLGy)sXTFalf7dyVHe3sd7hPgmtjhprUw6uCamt8IGNV1Wcy4uKW2F5ckscnJTRsGDX(LIB)awk2hWEdjULg2psnyMsoEICT0P4ayM4fbpRVbSaQGR8X2vjqxLouHH9tdMPKJNixlDkoaMjErWZwUC8udMgSMth9aszukEROJ8QoQmKGCAWmLC8e5fbpb)LKbuXmQgmtjhprErWtu7rpb827BuuGHAQXgaVXLmeiwdMPKJNiVi4zlxoEQbZuYXtKxe8ehTWjdaPbZuYXtKxe8SE0f2pGLI9AWmLC8e5fbpbMmovdMPKJNiVi4js4uGW(bSuSxdMPKJNiVi458EbEniflGeofGTRsadVwDk7)WFmfsEjJJoa7seriqm40Gzk54jYlcEI9CozOIt9MTRsGDX(LIZqQLKwQMBPH9J0VFm8A1zi1sslvZH363VIZFso4tNHuljTunhDa2LiI0mWPbZuYXtKxe8eBu0O(UKHTRsGDX(LIZqQLKwQMBPH9J0VFm8A1zi1sslvZH3QbZuYXtKxe8SE0H9CojBxLa7I9lfNHuljTun3sd7hPF)y41QZqQLKwQMdV1VFfN)KCWNodPwsAPAo6aSlrePzGtdMPKJNiVi4PLQHeQ9bL9pBxLa7I9lfNHuljTun3sd7hPF)y41QZqQLKwQMdV1VFfN)KCWNodPwsAPAo6aSlrePzGtdMPKJNiVi4jMXe41GqpLpeBxLa7I9lfNHuljTun3sd7hPF)SJHxRodPwsAPAo8wnyAWmLC8e5fbpBPhaNsE2haV1ySP8w9ligLzcIaXSDvcSJHxRUw6bWPKN9bWBnMdVvdMPKJNiVi4zJHAhniCzaAWmLC8e5fbpR2cc1sufhD8KTRsGDX(LIdWqYObEniflSFalfKBPH9J0VFm8A1byiz0aVgKIf2pGLcYH3QbtdMPKJNiVi4jfpdMsoEg(djSLgWiy8X2vjyk5ASWYbCdrequQCu7(pigLzcYPkSld)Xui5Lmebe(9JA3)bXOmtqU3AybSzaebenPbZuYXtKxe8KINbtjhpd)He2sdyeqxY8ligLzcBiHEkHaXSDvcSl2VuCiHtbc7hWsXE3sd7hzjtjxJfwoGBiIsaeAWmLC8e5fbpP4zWuYXZWFiHT0agb0cOlz(feJYmHnKqpLqGy2UkbX(LIdjCkqy)awk27wAy)ilzk5ASWYbCdrucGqdMgmtjhproJpcZOsrzWnFJTRsadVwDtvWVKjGk4kFo8wnyMsoEICgFErWtvHDzOWOngs0Gzk54jYz85fbprcNc4BRDu2UkbX(LIdjCkGVT2rDlnSFKAWmLC8e5m(8IGN13awavWv(yt5T6xqmkZeebIz7QemLCnwGKlU6BalGk4kFefKkzk5ASWYbCdrucnZVFkEUkNYmhYN3y0z(gffQ3OEhihWHMBLb)ABhPgmtjhproJpVi4z9nGfqfCLp2Ukb2nLCnwGKlU6BalGk4kFAWmLC8e5m(8IGNtvWVKjGk4kFSDvcI9lf3uf8lzcOcUYNBPH9JSeGThjuoari4rGtdMPKJNiNXNxe80qQLKwQgBxLGy)sXzi1sslvZT0W(rwQC2BN4qcNce2pGLI9otjxJ1uPYzxSFP4o1Q4uVDlnSFK(9ZogET6o1Q4uVD4TLyxX5pjh8P7uRIt92H32KgmtjhproJpVi45FLb)idagdGfeUma2UkbX(LI7VYGFKbaJbWccxgGBPH9JudMPKJNiNXNxe8CgvkcOcUYhBxLafpxLtzMBQc(qbEnWqNjbeEso6LmUvg8RTDKLyhdVwDtvWhkWRbg6mjGWtYrVKXH3QbZuYXtKZ4ZlcEoJkfH9dyPypBxLafpxLtzMJCRvOdGtdiHNZTYGFTTJSu5Sl2VuCT0dW(W(bSuS)qIBPH9J0V)YzVDIdjCkqy)awk27mLCnwj2BN4QhDH9dyPyVZuY1yn1KgmtjhproJpVi45BnSagofjSP8w9ligLzcIaXSDvcO29FqmkZeKtvyxg(JPqYlziki73pgET6ERHfq4uM5WB97VCX(LIdWqYObEniflSFalfKBPH9JSe7y41QdWqYObEniflSFalfKdVTeGThjuoari4rGRjnynNoYk1BDu46iJbmDSSnQuugCZ30rWFsHo28nKmQoYR6OumDSS)bSuq6igETQJGVyPowpMc5sgDeK0rXOmtqoDSScplRfDK3yuL1QJnFBpsOCa21Gzk54jYz85fbpNrLIYGB(gBxLa7I9lfhGHKrd8Aqkwy)awki3sd7hPF)y41QdjCkGVT2rD4T(9dy7rcLdqecLtm4axzbi7XO29FqmkZeKtvyxg(JPqYlzAYVFm8A1byiz0aVgKIf2pGLcYH363pQD)heJYmb5uf2LH)ykK8sgIasAWAoDS5B(MoIWPth9MJRJK8SSw0XNJMoA6yx4uaFBTJQJy41QtdMPKJNiNXNxe8uvyxg(JPqYlzy7QeWWRvhs4uaFBTJ6OdWUeruqYJzuKEmgET6qcNc4BRDuhsmLpnynNo28KV36OYqIoww1Ay6il4uKOJ8uhLc6MokgLzcshVQoEIoEiD0sD8sKyPOJwsQJDHtb0XY(hWsXED8q6iOnpSQJMsUgZPbZuYXtKZ4ZlcE(wdlGHtrcBxLagET6ERHfq4uM5WBlHA3)bXOmtqovHDz4pMcjVKHOGCPYzVDIdjCkqy)awk27mLCnwtLi5IR(gWcOcUYNtoLVlz0G1C6Ohi00XY(hWsXEDKL3qIoAm2LirhXB1rHRJGKokgLzcshnKo(8KrhnKo2fofqhl7Falf71XdPJjx0rtjxJ50Gzk54jYz85fbp3pGLI9bS3qcBxLGy)sXTFalf7dyVHe3sd7hzju7(pigLzcYPkSld)Xui5LmeTzLkN92joKWPaH9dyPyVZuY1ynPbZuYXtKZ4ZlcE(wdlGndGTRsqSFP4mKAjPLQ5wAy)i1Gzk54jYz85fbpvf2LH)ykK8sgnyMsoEICgFErWZ3AybmCksydG34sgceZ2vjGHxRU3AybeoLzo82sko)j5Gpd0zkrdMPKJNiNXNxe8S(gWcOcUYhBa8gxYqGy2uER(feJYmbrGy2Ukb6Q0HkmSFAWmLC8e5m(8IGNvkhjbubx5JnaEJlziqSgmnyMsoEICOfqxY8ligLzcH6BalGk4kFSP8w9ligLzcIaXSDvcLthGDjIOeyuKnvQCm8A19wdlGWPmZH363p7y41Qd75CYhhjo82M0Gzk54jYHwaDjZVGyuMjErWZ9dyPyFa7nKW2vji2VuC7hWsX(a2BiXT0W(rQbZuYXtKdTa6sMFbXOmt8IGNiHtb8T1okBxLGy)sXHeofW3w7OULg2pYsLdy7rcLdquqgKBsdMPKJNihAb0Lm)cIrzM4fbpNQGFjtavWv(y7Qee7xkUPk4xYeqfCLp3sd7hPgmtjhpro0cOlz(feJYmXlcE(wdlGHtrcBxLagET6a)LKbgCK4qIP8ruI9W(9JHxRU3AybeoLzo8wnyMsoEICOfqxY8ligLzIxe88pMcjVKjGXFHTRsadVwDiHtb8T1oQdVvdMPKJNihAb0Lm)cIrzM4fbpNrLIYGB(gBxLagET6MQGpuGxdm0zsaHNKJEjJdVvdMPKJNihAb0Lm)cIrzM4fbpNrLIYGB(gBxLq5O29FqmkZeKtvyxg(JPqYlzicXnvQC2j5IR(gWcOcUYNJUkDOcd7xtAWmLC8e5qlGUK5xqmkZeVi45mQueqfCLp2Ukbu7(pigLzcYPkSld)Xui5LmefeLaS9iHYbicbpcCLkhdVwDG)sYadosCiXu(ikiaNF)a2EKq5aeXdcUM87VCkEUkNYm3uf8Hc8AGHotci8KC0lzCRm4xB7ilXogET6MQGpuGxdm0zsaHNKJEjJdVTjnyMsoEICOfqxY8ligLzIxe88pMcjVKjGXFHTRsOCm8A1HeofW3w7Oo6aSlrefnrUKb5qIP8fWWR1r9ygfPhJHxRoKWPa(2Ah1Het5ZVFm8A1HeofW3w7Oo82sy41QdWqYObEniflSFalfKdVTjnyMsoEICOfqxY8ligLzIxe8Ss5ijGk4kFSDvcI9lf3PwfN6TBPH9JSKy)sXbyiz0aVgKIf2pGLcYT0W(rwcdVwDNAvCQ3o82sy41QdWqYObEniflSFalfKdVvdMPKJNihAb0Lm)cIrzM4fbpFRHfWWPiHTRsadVwDgsTK0s1C4TAWmLC8e5qlGUK5xqmkZeVi45BnSagofjSDvcko)j5Gpd0zkPe7I9lfhGHKrd8Aqkwy)awki3sd7hPgmtjhpro0cOlz(feJYmXlcEEQvXPEZ2vji2VuCNAvCQ3ULg2pYsSxoGThjuoar8qnRKIZFso4t3BnSagofjo6aSlreLa4AsdMPKJNihAb0Lm)cIrzM4fbpFRHfWWPiHTRsqX5pjh8zGotjLufgLziIi2VuCtvWd8Aqkwy)awki3sd7hPgmtjhpro0cOlz(feJYmXlcEwPCKeqfCLp2UkbX(LI7uRIt92T0W(rwcdVwDNAvCQ3o8wnyMsoEICOfqxY8ligLzIxe8uvyxgkmAJHenyMsoEICOfqxY8ligLzIxe8ejMCQa5HufgLzSDvcI9lfhsm5ubYdPkmkZClnSFKAWmLC8e5qlGUK5xqmkZeVi45mQue2pGLI9SDvcSl2VuCT0dW(W(bSuS)qIBPH9J0VFX(LIRLEa2h2pGLI9hsClnSFKLkN92joKWPaH9dyPyVZuY1ynPbZuYXtKdTa6sMFbXOmt8IGNQc7YWFmfsEjdBxLaQD)heJYmb5uf2LH)ykK8sgcGqdMPKJNihAb0Lm)cIrzM4fbp)JPqYlzcy8x0Gzk54jYHwaDjZVGyuMjErWZ6BalGk4kFSbWBCjdbIzt5T6xqmkZeebIz7QeORshQWW(PbZuYXtKdTa6sMFbXOmt8IGN13awavWv(ydG34sgceZ2vjaWBmGLIJ8qILQrepsdMPKJNihAb0Lm)cIrzM4fbpRuoscOcUYhBa8gxYqGynyAWmLC8e5qxY8ligLzcH6BalGk4kFSP8w9ligLzcIaXSDvcLZUCkFxY43pjxC13awavWv(C0byxIikbgfPF)I9lfNHuljTun3sd7hzjsU4QVbSaQGR85OdWUer0YvC(tYbF6mKAjPLQ5OdWUe5fgET6mKAjPLQ5iXPMC8SPsko)j5GpDgsTK0s1C0byxIiki3uPYXWRv3BnSacNYmhERF)SJHxRoSNZjFCK4WBBsdMPKJNih6sMFbXOmt8IGNgsTK0s1y7Qee7xkodPwsAPAULg2pYsLlhWicbpcC(9JHxRoSNZjFCK4WBBQu5ko)j5GpDV1Wcy4uK4OdWUereW1uPYzxSFP4o1Q4uVDlnSFK(9ZogET6o1Q4uVD4TLyxX5pjh8P7uRIt92H32Kgmtjhpro0Lm)cIrzM4fbp3pGLI9bS3qcBxLGy)sXTFalf7dyVHe3sd7hzPYf7xkoadjJg41GuSW(bSuqULg2pYsLJHxRoadjJg41GuSW(bSuqo82sa2EKq5ae1JaNF)SJHxRoadjJg41GuSW(bSuqo82M87NDX(LIdWqYObEniflSFalfKBPH9JSjnyMsoEICOlz(feJYmXlcEIeofW3w7OSDvcI9lfhs4uaFBTJ6wAy)ilvo1oYWASuCgjjYP44PquqYVFQDKH1yP4mssK7sI0mW1uPYbS9iHYbikidYnPbZuYXtKdDjZVGyuMjErWZPk4xYeqfCLp2UkbX(LIBQc(Lmbubx5ZT0W(rwsX5pjh8P7TgwadNIehDa2LiIsaCAWmLC8e5qxY8ligLzIxe88TgwadNIe2UkbX(LIBQc(Lmbubx5ZT0W(rwcdVwDtvWVKjGk4kFo8wnyMsoEICOlz(feJYmXlcE(xzWpYaGXaybHldGTRsqSFP4(Rm4hzaWyaSGWLb4wAy)i1Gzk54jYHUK5xqmkZeVi45FmfsEjtaJ)cBxLagET6qcNc4BRDuhEBju7(pigLzcYPkSld)Xui5LmefeLkhdVwDagsgnWRbPyH9dyPGC4TnPbZuYXtKdDjZVGyuMjErWZzuPOm4MVX2vjGHxRUPk4df41adDMeq4j5OxY4WBlvo7I9lfhGHKrd8Aqkwy)awki3sd7hPF)y41QdWqYObEniflSFalfKdVTjnyMsoEICOlz(feJYmXlcEoJkfLb38n2Ukbu7(pigLzcYPkSld)Xui5LmeH4sStYfx9nGfqfCLphDv6qfg2VsStXZv5uM5MQGpuGxdm0zsaHNKJEjJBLb)ABhzPYzxSFP4amKmAGxdsXc7hWsb5wAy)i97hdVwDagsgnWRbPyH9dyPGC4T(9R48NKd(09wdlGHtrIJoa7seraxjaBpsOCaIqWdcIM0Gzk54jYHUK5xqmkZeVi45mQueqfCLp2UkbX(LIdWqYObEniflSFalfKBPH9JSu5y41QdWqYObEniflSFalfKdV1VFfN)KCWNU3AybmCksC0byxIic4kby7rcLdqecEqq43pQD)heJYmb5uf2LH)ykK8sgIcIsy41QdjCkGVT2rD4TLuC(tYbF6ERHfWWPiXrhGDjIOeyuKn53p7I9lfhGHKrd8Aqkwy)awki3sd7hPgmtjhpro0Lm)cIrzM4fbp)JPqYlzcy8xy7QekhdVwDiHtb8T1oQJoa7serrtKlzqoKykFbm8ADupMrr6Xy41QdjCkGVT2rDiXu(87hdVwDiHtb8T1oQdVTegET6amKmAGxdsXc7hWsb5WBBsdMPKJNih6sMFbXOmt8IGNvkhjbubx5JTRsqSFP4o1Q4uVDlnSFKLe7xkoadjJg41GuSW(bSuqULg2pYsy41Q7uRIt92H3wcdVwDagsgnWRbPyH9dyPGC4TAWmLC8e5qxY8ligLzIxe88TgwadNIe2Ukbm8A1zi1sslvZH3QbZuYXtKdDjZVGyuMjErWZ3AybmCksy7QeuC(tYbFgOZusj2f7xkoadjJg41GuSW(bSuqULg2psnyMsoEICOlz(feJYmXlcEEQvXPEZ2vji2VuCNAvCQ3ULg2pYsSxoGThjuoar8qnRKIZFso4t3BnSagofjo6aSlreLa4AsdMPKJNih6sMFbXOmt8IGNV1Wcy4uKW2vjO48NKd(mqNPKsQcJYmere7xkUPk4bEniflSFalfKBPH9JudMPKJNih6sMFbXOmt8IGNvkhjbubx5JTRsqSFP4o1Q4uVDlnSFKLWWRv3PwfN6TdVTegET6o1Q4uVD0byxIikAICjdYHet5lGHxRJ6XmkspgdVwDNAvCQ3oKykFAWmLC8e5qxY8ligLzIxe88TgwadNIe2UkbfN)KCWNb6mLObZuYXtKdDjZVGyuMjErWZ6BalGk4kFSP8w9ligLzcIaXSDvc0vPdvyy)0Gzk54jYHUK5xqmkZeVi45mQuugCZ3y7QeqT7)GyuMjiNQWUm8htHKxYqeIlXofpxLtzMBQc(qbEnWqNjbeEso6LmUvg8RTDK(9JHxRUPk4df41adDMeq4j5OxY4WB1Gzk54jYHUK5xqmkZeVi4zLYrsavWv(y7Qee7xkUtTko1B3sd7hzjm8A1DQvXPE7WBlvogET6o1Q4uVD0byxIikJI0JbzpgdVwDNAvCQ3oKykF(9JHxRoKWPa(2Ah1H363p7I9lfhGHKrd8Aqkwy)awki3sd7hztAWmLC8e5qxY8ligLzIxe8Ss5ijGk4kFSDvcu8CvoLzU9dyPyFyLb)(dJE4aUvg8RTDKLyhdVwD7hWsX(Wkd(9hg9WbcKddVwD4TLyxSFP42pGLI9bS3qIBPH9JSe7I9lf3uf8lzcOcUYNBPH9JudMPKJNih6sMFbXOmt8IGNQc7YqHrBmKObZuYXtKdDjZVGyuMjErWtKyYPcKhsvyuMX2vji2VuCiXKtfipKQWOmZT0W(rQbZuYXtKdDjZVGyuMjErWZzuPiSFalf7z7QeyxSFP4APhG9H9dyPy)He3sd7hPF)S3oXvp6c7hWsXENPKRX0Gzk54jYHUK5xqmkZeVi4PQWUm8htHKxYW2vjGA3)bXOmtqovHDz4pMcjVKHai0Gzk54jYHUK5xqmkZeVi45FmfsEjtaJ)Igmtjhpro0Lm)cIrzM4fbpRVbSaQGR8XgaVXLmeiMnL3QFbXOmtqeiMTRsGUkDOcd7Ngmtjhpro0Lm)cIrzM4fbpRVbSaQGR8XgaVXLmeiMTRsaG3yalfh5HelvJiEKgmtjhpro0Lm)cIrzM4fbpRuoscOcUYhBa8gxYqGyyVXOOJNqqbb4abXGdKaNhg2bVrZlzqWUhaqlNkJuhBMoAk54Po(hsqonyW(Fibbzf2rxY8ligLzcKviOedzf2xAy)iHSa7MsoEc713awavWv(GDf9Krpd2lxhzxhLt57sgD0VFDKKlU6BalGk4kFo6aSlr6irjOJmksD0VFDuSFP4mKAjPLQ5wAy)i1Xs6ijxC13awavWv(C0byxI0rIQJLRJko)j5GpDgsTK0s1C0byxI0rV0rm8A1zi1sslvZrItn54Po2KowshvC(tYbF6mKAjPLQ5OdWUePJevhbzDSjDSKowUoIHxRU3AybeoLzo8wD0VFDKDDedVwDypNt(4iXH3QJnb7kVv)cIrzMGGGsmuGGcciRW(sd7hjKfyxrpz0ZGDX(LIZqQLKwQMBPH9JuhlPJLRJYbmDKie0rpcC6OF)6igET6WEoN8XrIdVvhBshlPJLRJko)j5GpDV1Wcy4uK4OdWUePJerhbNo2Kowshlxhzxhf7xkUtTko1B3sd7hPo63VoYUoIHxRUtTko1BhERowshzxhvC(tYbF6o1Q4uVD4T6ytWUPKJNWUHuljTunOabfKGSc7lnSFKqwGDf9Krpd2f7xkU9dyPyFa7nK4wAy)i1Xs6y56Oy)sXbyiz0aVgKIf2pGLcYT0W(rQJL0XY1rm8A1byiz0aVgKIf2pGLcYH3QJL0raBpsOCaDKO6OhboD0VFDKDDedVwDagsgnWRbPyH9dyPGC4T6yt6OF)6i76Oy)sXbyiz0aVgKIf2pGLcYT0W(rQJnb7MsoEc77hWsX(a2BibkqqbziRW(sd7hjKfyxrpz0ZGDX(LIdjCkGVT2rDlnSFK6yjDSCDKAhzynwkoJKe5uC8u0rIQJGKo63VosTJmSglfNrsICxQJerhBg40XM0Xs6y56iGThjuoGosuDeKbzDSjy3uYXtyhjCkGVT2rHce0Mbzf2xAy)iHSa7k6jJEgSl2VuCtvWVKjGk4kFULg2psDSKoQ48NKd(09wdlGHtrIJoa7sKosuc6i4GDtjhpH9Pk4xYeqfCLpOab1JGSc7lnSFKqwGDf9Krpd2f7xkUPk4xYeqfCLp3sd7hPowshXWRv3uf8lzcOcUYNdVf2nLC8e2FRHfWWPibkqq9qqwH9Lg2psilWUIEYONb7I9lf3FLb)idagdGfeUma3sd7hjSBk54jS)xzWpYaGXaybHldakqq9WqwH9Lg2psilWUIEYONb7y41QdjCkGVT2rD4T6yjDe1U)dIrzMGCQc7YWFmfsEjJosuDee6yjDSCDedVwDagsgnWRbPyH9dyPGC4T6ytWUPKJNW(FmfsEjtaJ)cuGG6bHSc7lnSFKqwGDf9Krpd2XWRv3uf8Hc8AGHotci8KC0lzC4T6yjDSCDKDDuSFP4amKmAGxdsXc7hWsb5wAy)i1r)(1rm8A1byiz0aVgKIf2pGLcYH3QJnb7MsoEc7ZOsrzWnFdkqqjgCqwH9Lg2psilWUIEYONb7O29FqmkZeKtvyxg(JPqYlz0rIOJeRJL0r21rsU4QVbSaQGR85ORshQWW(PJL0r21rkEUkNYm3uf8Hc8AGHotci8KC0lzCRm4xB7i1Xs6y56i76Oy)sXbyiz0aVgKIf2pGLcYT0W(rQJ(9RJy41QdWqYObEniflSFalfKdVvh97xhvC(tYbF6ERHfWWPiXrhGDjshjIocoDSKocy7rcLdOJeHGo6bbHo2eSBk54jSpJkfLb38nOabLyIHSc7lnSFKqwGDf9Krpd2f7xkoadjJg41GuSW(bSuqULg2psDSKowUoIHxRoadjJg41GuSW(bSuqo8wD0VFDuX5pjh8P7TgwadNIehDa2LiDKi6i40Xs6iGThjuoGosec6Ohee6OF)6iQD)heJYmb5uf2LH)ykK8sgDKO6ii0Xs6igET6qcNc4BRDuhERowshvC(tYbF6ERHfWWPiXrhGDjshjkbDKrrQJnPJ(9RJSRJI9lfhGHKrd8Aqkwy)awki3sd7hjSBk54jSpJkfbubx5dkqqjgeqwH9Lg2psilWUIEYONb7LRJy41QdjCkGVT2rD0byxI0rIQJOjYLmihsmLVagEToQo6X6iJIuh9yDedVwDiHtb8T1oQdjMYNo63VoIHxRoKWPa(2Ah1H3QJL0rm8A1byiz0aVgKIf2pGLcYH3QJnb7MsoEc7)Xui5Lmbm(lqbckXGeKvyFPH9JeYcSRONm6zWUy)sXDQvXPE7wAy)i1Xs6Oy)sXbyiz0aVgKIf2pGLcYT0W(rQJL0rm8A1DQvXPE7WB1Xs6igET6amKmAGxdsXc7hWsb5WBHDtjhpH9kLJKaQGR8bfiOedYqwH9Lg2psilWUIEYONb7y41QZqQLKwQMdVf2nLC8e2FRHfWWPibkqqjUzqwH9Lg2psilWUIEYONb7ko)j5Gpd0zkrhlPJSRJI9lfhGHKrd8Aqkwy)awki3sd7hjSBk54jS)wdlGHtrcuGGsShbzf2xAy)iHSa7k6jJEgSl2VuCNAvCQ3ULg2psDSKoYUowUocy7rcLdOJerh9qnthlPJko)j5GpDV1Wcy4uK4OdWUePJeLGocoDSjy3uYXty)uRIt9gkqqj2dbzf2xAy)iHSa7k6jJEgSR48NKd(mqNPeDSKoQkmkZq6ir0rX(LIBQcEGxdsXc7hWsb5wAy)iHDtjhpH93AybmCksGceuI9WqwH9Lg2psilWUIEYONb7I9lf3PwfN6TBPH9JuhlPJy41Q7uRIt92H3QJL0rm8A1DQvXPE7OdWUePJevhrtKlzqoKykFbm8ADuD0J1rgfPo6X6igET6o1Q4uVDiXu(GDtjhpH9kLJKaQGR8bfiOe7bHSc7lnSFKqwGDf9Krpd2vC(tYbFgOZucSBk54jS)wdlGHtrcuGGccWbzf2xAy)iHSa7MsoEc713awavWv(GDf9Krpd2PRshQWW(b7kVv)cIrzMGGGsmuGGccIHSc7lnSFKqwGDf9Krpd2rT7)GyuMjiNQWUm8htHKxYOJerhjwhlPJSRJu8CvoLzUPk4df41adDMeq4j5OxY4wzWV22rQJ(9RJy41QBQc(qbEnWqNjbeEso6Lmo8wy3uYXtyFgvkkdU5BqbckiabKvyFPH9JeYcSRONm6zWUy)sXDQvXPE7wAy)i1Xs6igET6o1Q4uVD4T6yjDSCDedVwDNAvCQ3o6aSlr6ir1rgfPo6X6iiRJESoIHxRUtTko1BhsmLpD0VFDedVwDiHtb8T1oQdVvh97xhzxhf7xkoadjJg41GuSW(bSuqULg2psDSjy3uYXtyVs5ijGk4kFqbckiajiRW(sd7hjKfyxrpz0ZGDkEUkNYm3(bSuSpSYGF)HrpCa3kd(12osDSKoYUoIHxRU9dyPyFyLb)(dJE4abYHHxRo8wDSKoYUok2VuC7hWsX(a2BiXT0W(rQJL0r21rX(LIBQc(Lmbubx5ZT0W(rc7MsoEc7vkhjbubx5dkqqbbidzf2nLC8e2vf2LHcJ2yib2xAy)iHSafiOGOzqwH9Lg2psilWUIEYONb7I9lfhsm5ubYdPkmkZClnSFKWUPKJNWosm5ubYdPkmkZGceuq4rqwH9Lg2psilWUIEYONb7SRJI9lfxl9aSpSFalf7pK4wAy)i1r)(1r21X2jU6rxy)awk27mLCngSBk54jSpJkfH9dyPypuGGccpeKvyFPH9JeYcSRONm6zWoQD)heJYmb5uf2LH)ykK8sgDKGoccy3uYXtyxvyxg(JPqYlzGceuq4HHSc7MsoEc7)Xui5Lmbm(lW(sd7hjKfOabfeEqiRWoaVXLmqqjg2xAy)ca8gxYazb2nLC8e2RVbSaQGR8b7kVv)cIrzMGGGsmSRONm6zWoDv6qfg2pyFPH9JeYcuGGcsGdYkSV0W(rczb2xAy)ca8gxYazb2v0tg9myhG3yalfh5HelvthjIo6rWUPKJNWE9nGfqfCLpyhG34sgiOedfiOGeXqwHDaEJlzGGsmSV0W(fa4nUKbYcSBk54jSxPCKeqfCLpyFPH9JeYcuGcStUQH)cKviOedzf2xAy)iHSa7KdPOxRC8e29aszukEROJ8QoQmKGCWUPKJNWo4VKmGkMrHceuqazf2b4nUKbckXW(sd7xaG34sgilWUPKJNWoQ9ONaE79nkkWqn1G9Lg2psilqbckibzf2nLC8e2B5YXtyFPH9JeYcuGGcYqwHDtjhpHDC0cNmaeSV0W(rczbkqqBgKvy3uYXtyVE0f2pGLI9W(sd7hjKfOab1JGSc7MsoEc7atgNc7lnSFKqwGceupeKvy3uYXtyhjCkqy)awk2d7lnSFKqwGceupmKvyFPH9JeYcSRONm6zWogET6u2)H)ykK8sghDa2LiDKie0rIbhSBk54jSpVxGxdsXciHtbGceupiKvyFPH9JeYcSRONm6zWo76Oy)sXzi1sslvZT0W(rQJ(9RJy41QZqQLKwQMdVvh97xhvC(tYbF6mKAjPLQ5OdWUePJerhBg4GDtjhpHDSNZjdvCQ3qbckXGdYkSV0W(rczb2v0tg9myNDDuSFP4mKAjPLQ5wAy)i1r)(1rm8A1zi1sslvZH3c7MsoEc7yJIg13LmqbckXedzf2xAy)iHSa7k6jJEgSZUok2VuCgsTK0s1ClnSFK6OF)6igET6mKAjPLQ5WB1r)(1rfN)KCWNodPwsAPAo6aSlr6ir0XMboy3uYXtyVE0H9CojuGGsmiGSc7lnSFKqwGDf9Krpd2zxhf7xkodPwsAPAULg2psD0VFDedVwDgsTK0s1C4T6OF)6OIZFso4tNHuljTunhDa2LiDKi6yZahSBk54jSBPAiHAFqz)dfiOedsqwH9Lg2psilWUIEYONb7SRJI9lfNHuljTun3sd7hPo63VoYUoIHxRodPwsAPAo8wy3uYXtyhZyc8AqONYhckqqjgKHSc7lnSFKqwGDtjhpH9w6bWPKN9bWBngSRONm6zWo76igET6APhaNsE2haV1yo8wyx5T6xqmkZeeeuIHceuIBgKvy3uYXtyVXqTJgeUmayFPH9JeYcuGGsShbzf2xAy)iHSa7k6jJEgSZUok2VuCagsgnWRbPyH9dyPGClnSFK6OF)6igET6amKmAGxdsXc7hWsb5WBHDtjhpH9QTGqTevXrhpHceuI9qqwH9Lg2psilWUIEYONb7MsUglSCa3q6ir0rqOJL0XY1ru7(pigLzcYPkSld)Xui5Lm6ir0rqOJ(9RJO29FqmkZeK7TgwaBgGoseDee6ytWUPKJNWofpdMsoEg(djW(FijKgWGDJpOabLypmKvyFPH9JeYcSRONm6zWo76Oy)sXHeofiSFalf7DlnSFK6yjD0uY1yHLd4gshjkbDeeWosONsGGsmSBk54jStXZGPKJNH)qcS)hscPbmyhDjZVGyuMjqbckXEqiRW(sd7hjKfyxrpz0ZGDX(LIdjCkqy)awk27wAy)i1Xs6OPKRXclhWnKosuc6iiGDKqpLabLyy3uYXtyNINbtjhpd)Hey)pKesdyWoAb0Lm)cIrzMafOa7T0P4ayMazfckXqwH9Lg2psilWUPKJNW(mQue2pGLI9Wo5qk61khpH9YUS8u4Yi1X1yuV1r5aMokfthnLWP64H0rRHDVH9Zb7k6jJEgSZUok2VuCT0dW(W(bSuS)qIBPH9JekqqbbKvyFPH9JeYcSBk54jSJeofW3w7OWo5qk61khpHDpqOPJDHtb8T1oQo2sNIdGzIoIN)qiDeXbMoAKKiDe83)6iQ1aFQJiopDWUIEYONb7I9lfhs4uaFBTJ6wAy)i1Xs6y56i1oYWASuCgjjYP44POJevhbjD0VFDKAhzynwkoJKe5UuhjIo2mWPJnbfiOGeKvyFPH9JeYcSRONm6zWUy)sXTFalf7dyVHe3sd7hjSBk54jSVFalf7dyVHeOabfKHSc7lnSFKqwGDtjhpH93AybmCksGDf9Krpd2zxhf7xkU9dyPyFa7nK4wAy)iH9)YfuKWEZGce0Mbzf2xAy)iHSa7k6jJEgStxLouHH9d2nLC8e2RVbSaQGR8bfiOEeKvy3uYXtyVLlhpH9Lg2psilqbkWUXhKviOedzf2xAy)iHSa7k6jJEgSJHxRUPk4xYeqfCLphElSBk54jSpJkfLb38nOabfeqwHDtjhpHDvHDzOWOngsG9Lg2psilqbckibzf2xAy)iHSa7k6jJEgSl2VuCiHtb8T1oQBPH9Je2nLC8e2rcNc4BRDuOabfKHSc7lnSFKqwGDtjhpH96BalGk4kFWUIEYONb7MsUglqYfx9nGfqfCLpDKO6iiPJL0rtjxJfwoGBiDKOe0XMPJ(9RJu8CvoLzoKpVXOZ8nkkuVr9oqoGdn3kd(12osyx5T6xqmkZeeeuIHce0Mbzf2xAy)iHSa7k6jJEgSZUoAk5ASajxC13awavWv(GDtjhpH96BalGk4kFqbcQhbzf2xAy)iHSa7k6jJEgSl2VuCtvWVKjGk4kFULg2psDSKocy7rcLdOJeHGo6rGd2nLC8e2NQGFjtavWv(GceupeKvyFPH9JeYcSRONm6zWUy)sXzi1sslvZT0W(rQJL0XY1r21X2joKWPaH9dyPyVZuY1y6yt6yjDSCDKDDuSFP4o1Q4uVDlnSFK6OF)6i76igET6o1Q4uVD4T6yjDKDDuX5pjh8P7uRIt92H3QJnb7MsoEc7gsTK0s1GceupmKvyFPH9JeYcSRONm6zWUy)sX9xzWpYaGXaybHldWT0W(rc7MsoEc7)vg8Jmaymawq4YaGceupiKvyFPH9JeYcSRONm6zWofpxLtzMBQc(qbEnWqNjbeEso6LmUvg8RTDK6yjDKDDedVwDtvWhkWRbg6mjGWtYrVKXH3c7MsoEc7ZOsravWv(GceuIbhKvyFPH9JeYcSRONm6zWofpxLtzMJCRvOdGtdiHNZTYGFTTJuhlPJLRJSRJI9lfxl9aSpSFalf7pK4wAy)i1r)(1XY1r21X2joKWPaH9dyPyVZuY1y6yjDKDDSDIRE0f2pGLI9otjxJPJnPJnb7MsoEc7ZOsry)awk2dfiOetmKvyFPH9JeYcSBk54jS)wdlGHtrcSRONm6zWoQD)heJYmb5uf2LH)ykK8sgDKO6iiRJ(9RJy41Q7TgwaHtzMdVvh97xhlxhf7xkoadjJg41GuSW(bSuqULg2psDSKoYUoIHxRoadjJg41GuSW(bSuqo8wDSKocy7rcLdOJeHGo6rGthBc2vER(feJYmbbbLyOabLyqazf2xAy)iHSa7MsoEc7ZOsrzWnFd2jhsrVw54jSZk1BDu46iJbmDSSnQuugCZ30rWFsHo28nKmQoYR6OumDSS)bSuq6igETQJGVyPowpMc5sgDeK0rXOmtqoDSScplRfDK3yuL1QJnFBpsOCa2HDf9Krpd2zxhf7xkoadjJg41GuSW(bSuqULg2psD0VFDedVwDiHtb8T1oQdVvh97xhbS9iHYb0rIqqhlxhjgCGthll0rqwh9yDe1U)dIrzMGCQc7YWFmfsEjJo2Ko63VoIHxRoadjJg41GuSW(bSuqo8wD0VFDe1U)dIrzMGCQc7YWFmfsEjJoseDeKGceuIbjiRW(sd7hjKfy3uYXtyxvyxg(JPqYlzGDYHu0RvoEc7nFZ30reoD6O3CCDKKNL1Io(C00rth7cNc4BRDuDedVwDWUIEYONb7y41QdjCkGVT2rD0byxI0rIQJGKo6X6iJIuh9yDedVwDiHtb8T1oQdjMYhuGGsmidzf2xAy)iHSa7MsoEc7V1Wcy4uKa7KdPOxRC8e2BEY3BDuzirhlRAnmDKfCks0rEQJsbDthfJYmbPJxvhprhpKoAPoEjsSu0rlj1XUWPa6yz)dyPyVoEiDe0Mhw1rtjxJ5GDf9Krpd2XWRv3BnSacNYmhERowshrT7)GyuMjiNQWUm8htHKxYOJevhbzDSKowUoYUo2oXHeofiSFalf7DMsUgthBshlPJKCXvFdybubx5ZjNY3LmqbckXndYkSV0W(rczb2nLC8e23pGLI9bS3qcStoKIETYXty3deA6yz)dyPyVoYYBirhng7sKOJ4T6OW1rqshfJYmbPJgshFEYOJgsh7cNcOJL9pGLI964H0XKl6OPKRXCWUIEYONb7I9lf3(bSuSpG9gsClnSFK6yjDe1U)dIrzMGCQc7YWFmfsEjJosuDSz6yjDSCDKDDSDIdjCkqy)awk27mLCnMo2euGGsShbzf2xAy)iHSa7k6jJEgSl2VuCgsTK0s1ClnSFKWUPKJNW(BnSa2maOabLypeKvy3uYXtyxvyxg(JPqYlzG9Lg2psilqbckXEyiRW(sd7hjKfyFPH9laWBCjdKfyxrpz0ZGDm8A19wdlGWPmZH3QJL0rfN)KCWNb6mLa7MsoEc7V1Wcy4uKa7a8gxYabLyOabLypiKvyhG34sgiOed7lnSFbaEJlzGSa7MsoEc713awavWv(GDL3QFbXOmtqqqjg2v0tg9myNUkDOcd7hSV0W(rczbkqqbb4GSc7a8gxYabLyyFPH9laWBCjdKfy3uYXtyVs5ijGk4kFW(sd7hjKfOafyhTa6sMFbXOmtGScbLyiRW(sd7hjKfy3uYXtyV(gWcOcUYhSRONm6zWE56iDa2LiDKOe0rgfPo2KowshlxhXWRv3BnSacNYmhERo63VoYUoIHxRoSNZjFCK4WB1XMGDL3QFbXOmtqqqjgkqqbbKvyFPH9JeYcSRONm6zWUy)sXTFalf7dyVHe3sd7hjSBk54jSVFalf7dyVHeOabfKGSc7lnSFKqwGDf9Krpd2f7xkoKWPa(2Ah1T0W(rQJL0XY1raBpsOCaDKO6iidY6ytWUPKJNWos4uaFBTJcfiOGmKvyFPH9JeYcSRONm6zWUy)sXnvb)sMaQGR85wAy)iHDtjhpH9Pk4xYeqfCLpOabTzqwH9Lg2psilWUIEYONb7y41Qd8xsgyWrIdjMYNosuDKypSo63VoIHxRU3AybeoLzo8wy3uYXty)TgwadNIeOab1JGSc7lnSFKqwGDf9Krpd2XWRvhs4uaFBTJ6WBHDtjhpH9)ykK8sMag)fOab1dbzf2xAy)iHSa7k6jJEgSJHxRUPk4df41adDMeq4j5OxY4WBHDtjhpH9zuPOm4MVbfiOEyiRW(sd7hjKfyxrpz0ZG9Y1ru7(pigLzcYPkSld)Xui5Lm6ir0rI1XM0Xs6y56i76ijxC13awavWv(C0vPdvyy)0XMGDtjhpH9zuPOm4MVbfiOEqiRW(sd7hjKfyxrpz0ZGDu7(pigLzcYPkSld)Xui5Lm6ir1rqOJL0raBpsOCaDKie0rpcC6yjDSCDedVwDG)sYadosCiXu(0rIQJGaC6OF)6iGThjuoGoseD0dcoDSjD0VFDSCDKINRYPmZnvbFOaVgyOZKacpjh9sg3kd(12osDSKoYUoIHxRUPk4df41adDMeq4j5OxY4WB1XMGDtjhpH9zuPiGk4kFqbckXGdYkSV0W(rczb2v0tg9myVCDedVwDiHtb8T1oQJoa7sKosuDenrUKb5qIP8fWWR1r1rpwhzuK6OhRJy41QdjCkGVT2rDiXu(0r)(1rm8A1HeofW3w7Oo8wDSKoIHxRoadjJg41GuSW(bSuqo8wDSjy3uYXty)pMcjVKjGXFbkqqjMyiRW(sd7hjKfyxrpz0ZGDX(LI7uRIt92T0W(rQJL0rX(LIdWqYObEniflSFalfKBPH9JuhlPJy41Q7uRIt92H3QJL0rm8A1byiz0aVgKIf2pGLcYH3c7MsoEc7vkhjbubx5dkqqjgeqwH9Lg2psilWUIEYONb7y41QZqQLKwQMdVf2nLC8e2FRHfWWPibkqqjgKGSc7lnSFKqwGDf9Krpd2vC(tYbFgOZuIowshzxhf7xkoadjJg41GuSW(bSuqULg2psy3uYXty)TgwadNIeOabLyqgYkSV0W(rczb2v0tg9myxSFP4o1Q4uVDlnSFK6yjDKDDSCDeW2JekhqhjIo6HAMowshvC(tYbF6ERHfWWPiXrhGDjshjkbDeC6ytWUPKJNW(PwfN6nuGGsCZGSc7lnSFKqwGDf9Krpd2vC(tYbFgOZuIowshvfgLziDKi6Oy)sXnvbpWRbPyH9dyPGClnSFKWUPKJNW(BnSagofjqbckXEeKvyFPH9JeYcSRONm6zWUy)sXDQvXPE7wAy)i1Xs6igET6o1Q4uVD4TWUPKJNWELYrsavWv(GceuI9qqwHDtjhpHDvHDzOWOngsG9Lg2psilqbckXEyiRW(sd7hjKfyxrpz0ZGDX(LIdjMCQa5HufgLzULg2psy3uYXtyhjMCQa5HufgLzqbckXEqiRW(sd7hjKfyxrpz0ZGD21rX(LIRLEa2h2pGLI9hsClnSFK6OF)6Oy)sX1spa7d7hWsX(djULg2psDSKowUoYUo2oXHeofiSFalf7DMsUgthBc2nLC8e2NrLIW(bSuShkqqbb4GSc7lnSFKqwGDf9Krpd2rT7)GyuMjiNQWUm8htHKxYOJe0rqa7MsoEc7Qc7YWFmfsEjduGGccIHSc7MsoEc7)Xui5Lmbm(lW(sd7hjKfOabfeGaYkSdWBCjdeuIH9Lg2VaaVXLmqwGDtjhpH96BalGk4kFWUYB1VGyuMjiiOed7k6jJEgStxLouHH9d2xAy)iHSafiOGaKGSc7lnSFKqwG9Lg2VaaVXLmqwGDf9Krpd2b4ngWsXrEiXs10rIOJEeSBk54jSxFdybubx5d2b4nUKbckXqbckiaziRWoaVXLmqqjg2xAy)ca8gxYazb2nLC8e2RuoscOcUYhSV0W(rczbkqbkWUHlfCkS3pa83KJNLLOwvGcuGqa]] )


end
