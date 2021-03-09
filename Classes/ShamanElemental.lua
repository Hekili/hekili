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

    spec:RegisterPack( "Elemental", 20210308, [[dqKKBbqiukpskk2Ke5tsrLmkPiNsIQvrvOEfvjZcLQBjrjSlQ8lQIggIIJHsSmiWZOkOPrvGRbrX2OkKVbrjJtIsDoPOQ1brPY8GO6EiY(qu6GsrfSqevpeIsvtuIsuxukkDsikLvcHMPuuHUPeL0oHi)ukQONkvtfL0vLIk1EH6VcgSqhMYIb6XKAYiCzLnlPpJIrlHtRYRPQmBvDBa7w0Vr1WLshxIILJ0ZbnDIRdPTlf(oe04LOe58uLA(uvTFsgZcMvCNWKHrcbKbbSqgpKmLTdbSGmLncAECx8UD4ERP9zmd3tdy4EZ(dyPypU3AE)CJaZkUd5Ou9W9crAHi780tMtkqbDAoGNWda9n54PMAvXt4bO9e3brVxq2smiUtyYWiHaYGawiJhsMY2HawqMYgbilCh2ongje4ria3locILyqCNyqnU3S)awk2RI9cdWsfILvJQluXYMDvebKbbSOquHiY(clzgezNcXYcvezl1CAlNAYur4e5sgOdkM2xaeTwhvfRCQkISPxfL6n7Qyx4uaFBTJ6uiwwOInhiiuXY6KXPQOLeQyZ69urEvfLIPIDHtburJXU0H7TuE9(H7ntZOIn7pGLI9QyVWaSuHyZ0mQyz1O6cvSSzxfrazqalkevi2mnJkISVWsMbr2PqSzAgvSSqfr2snN2YPMmveorUKb6GIP9farR1rvXkNQIiB6vrPEZUk2fofW3w7OofIntZOILfQyZbccvSSozCQkAjHk2SEpvKxvrPyQyx4uav0ySlDkevi2mQyZwwAAuzeQ4AmQ3QOCatfLIPIMw4uv8GQO1WU3a)5uiAA54j01sNMdaAcPzuPiSFalf7z)QKytSFP4APhG9H9dyPy)bf3sd8hHcXMrfBUHtf7cNc4BRDuvSLonha0even)bHQiKdmv0iiGQicV)vryRHWufHCE6uiAA54j01sNMdaAIxK8ekCkGVT2rz)QKe7xkoOWPa(2Ah1T0a)ruQjQDeH1yP4mccOtZrtb5EOF)u7icRXsXzeeq3LKfzit5kenTC8e6APtZbanXlsEUFalf7dGVbf2VkjX(LIB)awk2haFdkULg4pcfIMwoEcDT0P5aGM4fjpFRHfarPqH9RsInX(LIB)awk2haFdkULg4pcfIMwoEcDT0P5aGM4fjpB5YXtfIkeBgvezlLrPOTIkYRQO2Gc0Pq00YXtOxK8eHxseGfZOkenTC8e6fjpHTh9eeAVVrHbgQPh7a8gxYqIffIMwoEc9IKNTC54PcrtlhpHErYtu4cNmaOcrtlhpHErYZ6rxy)awk2Rq00YXtOxK8eyY4ufIMwoEc9IKNqHtbc7hWsXEfIMwoEc9IKNZ7f41GuSau4ua2Vkjq0A1PT)d)Xui5Lmo6aSlHKLelKrHOPLJNqVi5j4Z5eHkk1B2Vkj2e7xkodQxsyPEULg4pc)(brRvNb1ljSuphARF)Ao)j4imDguVKWs9C0byxcjlYqgfIMwoEc9IKNGJch13LmSFvsSj2VuCguVKWs9ClnWFe(9dIwRodQxsyPEo0wfIMwoEc9IKN1JoWNZjy)QKytSFP4mOEjHL65wAG)i87heTwDguVKWs9COT(9R58NGJW0zq9scl1ZrhGDjKSidzuiAA54j0lsEAPEqHAFqB)Z(vjXMy)sXzq9scl1ZT0a)r43piAT6mOEjHL65qB97xZ5pbhHPZG6LewQNJoa7sizrgYOq00YXtOxK8e0yc8AqON2hK9RsInX(LIZG6LewQNBPb(JWVF2arRvNb1ljSuphARcrfIMwoEc9IKNT0dGtjo7di0Am21ER)feJYmbsIf2Vkj2arRvxl9a4uIZ(acTgZH2Qq00YXtOxK8SXGTJgeUmafIMwoEc9IKNvBbHAjSIcpEY(vjXMy)sXbyqz0aVgKIf2pGLc0T0a)r43piAT6amOmAGxdsXc7hWsb6qBviQq00YXtOxK8KIMbtlhpd)bf2tdyKm(y)QKmTCnwy5aUbjlck1eSD)heJYmb60f2LH)ykK8sgYIa)(HT7)GyuMjq3BnSa4maYIGYviAA54j0lsEsrZGPLJNH)Gc7PbmsWlz(feJYmH9RsInX(LIdkCkqy)awk27wAG)ikzA5ASWYbCdICsiqHOPLJNqVi5jfndMwoEg(dkSNgWibxaEjZVGyuMjSFvsI9lfhu4uGW(bSuS3T0a)ruY0Y1yHLd4ge5KqGcrfIMwoEcDgFKMrLIYGA(g7xLeiAT6MUGFjtawW1(COTkenTC8e6m(8IKN6c7YqHrBmOOq00YXtOZ4ZlsEcfofW3w7OSFvsI9lfhu4uaFBTJ6wAG)iuiAA54j0z85fjpRVbSaSGR9XU2B9VGyuMjqsSW(vjzA5ASabxC13awawW1(qUhwY0Y1yHLd4ge5Kqg)(PO5QCkZCqFEdsN5BuyOEJ6DGyahCUvg0RTDekenTC8e6m(8IKN13awawW1(y)QKyZ0Y1ybcU4QVbSaSGR9Pq00YXtOZ4ZlsEoDb)sMaSGR9X(vjj2VuCtxWVKjal4AFULg4pIsa2EOq5aKLKhrgfIMwoEcDgFErYtdQxsyPESFvsI9lfNb1ljSup3sd8hrPMyRDIdkCkqy)awk27mTCnw5LAInX(LI70RIs92T0a)r43pBGO1Q70RIs92H2wInnN)eCeMUtVkk1BhAB5kenTC8e6m(8IKN)vg0Jiaymawq4Yay)QKe7xkU)kd6reamgaliCzaULg4pcfIMwoEcDgFErYZzuPial4AFSFvsu0CvoLzUPl4dg41adDMeGOjXOxY4wzqV22ruInq0A1nDbFWaVgyOZKaenjg9sghARcrtlhpHoJpVi55mQue2pGLI9SFvsu0CvoLzoITwHoaonafEo3kd612oIsnXMy)sX1spa7d7hWsX(dkULg4pc)(BIT2joOWPaH9dyPyVZ0Y1yLyRDIRE0f2pGLI9otlxJvE5kenTC8e6m(8IKNV1WcGOuOWU2B9VGyuMjqsSW(vjbB3)bXOmtGoDHDz4pMcjVKb5EGF)GO1Q7TgwaIszMdT1V)Me7xkoadkJg41GuSW(bSuGULg4pIsSbIwRoadkJg41GuSW(bSuGo02sa2EOq5aKLKhrMYvi2mQiRuVvrHRImgWuXM1OsrzqnFtfr4jfQyz1GYOQiVQIsXuXM9hWsbQIGO1QkIWILQy9ykKlzurpuffJYmb6uXYY8S5surEJr1wRkwwT9qHYbytHOPLJNqNXNxK8CgvkkdQ5BSFvsSj2VuCagugnWRbPyH9dyPaDlnWFe(9dIwRoOWPa(2Ah1H263pGThkuoazj1elKHmLfEGhdB3)bXOmtGoDHDz4pMcjVKPC)(brRvhGbLrd8Aqkwy)awkqhARF)W29FqmkZeOtxyxg(JPqYlziRhQqSzuXYQ5BQieLov0BoQksWZMlrfFoCQOPIDHtb8T1oQkcIwRofIMwoEcDgFErYtDHDz4pMcjVKH9RsceTwDqHtb8T1oQJoa7siY9qpMrt4XGO1QdkCkGVT2rDqX0(ui2mQyZz(ERIAdkQyZrRHPIKJsHIkYtvukOBQOyuMjqv8QQ4jQ4bvrlvXlHILIkAjHk2fofqfB2Falf7vXdQIi1CYQkAA5AmNcrtlhpHoJpVi55BnSaikfkSFvsGO1Q7TgwaIszMdTTeSD)heJYmb60f2LH)ykK8sgK7bLAIT2joOWPaH9dyPyVZ0Y1yLxIGlU6Balal4AFo50(UKrHyZOIn3WPIn7pGLI9Qi5Vbfv0ySlHIkI2QIcxf9qvumkZeOkAqv85jJkAqvSlCkGk2S)awk2RIhuftUOIMwUgZPq00YXtOZ4ZlsEUFalf7dGVbf2VkjX(LIB)awk2haFdkULg4pIsW29FqmkZeOtxyxg(JPqYlzqoYuQj2AN4GcNce2pGLI9otlxJvUcrtlhpHoJpVi55BnSa4ma2VkjX(LIZG6LewQNBPb(JqHOPLJNqNXNxK8uxyxg(JPqYlzuiAA54j0z85fjpFRHfarPqHDaEJlziXc7xLeiAT6ERHfGOuM5qBlP58NGJWmqNPffIMwoEcDgFErYZ6Balal4AFSdWBCjdjwyx7T(xqmkZeijwy)QKORshSWa)Pq00YXtOZ4ZlsEwPCOeGfCTp2b4nUKHelkeviAA54j0bxaEjZVGyuMjKQVbSaSGR9XU2B9VGyuMjqsSW(vj1eDa2LqKtIrtuEPMarRv3BnSaeLYmhARF)SbIwRoWNZjEuO4qBlxHOPLJNqhCb4Lm)cIrzM4fjp3pGLI9bW3Gc7xLKy)sXTFalf7dGVbf3sd8hHcrtlhpHo4cWlz(feJYmXlsEcfofW3w7OSFvsI9lfhu4uaFBTJ6wAG)ik1eGThkuoaY9apOCfIMwoEcDWfGxY8ligLzIxK8C6c(Lmbybx7J9RssSFP4MUGFjtawW1(ClnWFekenTC8e6GlaVK5xqmkZeVi55BnSaikfkSFvsGO1QdHxseyqHIdkM2hYzPS97heTwDV1WcqukZCOTkenTC8e6GlaVK5xqmkZeVi55FmfsEjtaK)c7xLeiAT6GcNc4BRDuhARcrtlhpHo4cWlz(feJYmXlsEoJkfLb18n2Vkjq0A1nDbFWaVgyOZKaenjg9sghARcrtlhpHo4cWlz(feJYmXlsEoJkfLb18n2VkPMGT7)GyuMjqNUWUm8htHKxYqwwkVutSrWfx9nGfGfCTphDv6Gfg4VYviAA54j0bxaEjZVGyuMjErYZzuPial4AFSFvsW29FqmkZeOtxyxg(JPqYlzqockby7HcLdqwsEezk1eiAT6q4LebguO4GIP9HCeqg)(bS9qHYbiBZtMY97VjkAUkNYm30f8bd8AGHotcq0Ky0lzCRmOxB7ikXgiAT6MUGpyGxdm0zsaIMeJEjJdTTCfIMwoEcDWfGxY8ligLzIxK88pMcjVKjaYFH9RsQjq0A1bfofW3w7Oo6aSlHihorUKb6GIP9farR1r9ygnHhdIwRoOWPa(2Ah1bft7ZVFq0A1bfofW3w7Oo02sGO1QdWGYObEniflSFalfOdTTCfIMwoEcDWfGxY8ligLzIxK8Ss5qjal4AFSFvsI9lf3PxfL6TBPb(JOKy)sXbyqz0aVgKIf2pGLc0T0a)ruceTwDNEvuQ3o02sGO1QdWGYObEniflSFalfOdTvHOPLJNqhCb4Lm)cIrzM4fjpFRHfarPqH9RsceTwDguVKWs9COTkenTC8e6GlaVK5xqmkZeVi55BnSaikfkSFvsAo)j4imd0zAPeBI9lfhGbLrd8Aqkwy)awkq3sd8hHcrtlhpHo4cWlz(feJYmXlsEE6vrPEZ(vjj2VuCNEvuQ3ULg4pIsS1eGThkuoazrwitjnN)eCeMU3AybqukuC0byxcrojYuUcrtlhpHo4cWlz(feJYmXlsE(wdlaIsHc7xLKMZFcocZaDMwkPlmkZGKvSFP4MUGh41GuSW(bSuGULg4pcfIMwoEcDWfGxY8ligLzIxK8Ss5qjal4AFSFvsI9lf3PxfL6TBPb(JOeiAT6o9QOuVDOTkenTC8e6GlaVK5xqmkZeVi5PUWUmuy0gdkkenTC8e6GlaVK5xqmkZeVi5jum50bIdQlmkZy)QKe7xkoOyYPdehuxyuM5wAG)iuiAA54j0bxaEjZVGyuMjErYZzuPiSFalf7z)QKytSFP4APhG9H9dyPy)bf3sd8hHF)I9lfxl9aSpSFalf7pO4wAG)ik1eBTtCqHtbc7hWsXENPLRXkxHOPLJNqhCb4Lm)cIrzM4fjp)JPqYlzcG8xuiAA54j0bxaEjZVGyuMjErYZ6Balal4AFSdWBCjdjwyx7T(xqmkZeijwy)QKORshSWa)Pq00YXtOdUa8sMFbXOmt8IKN13awawW1(yhG34sgsSW(vjbWBmGLIJ4GIL6rwpsHOPLJNqhCb4Lm)cIrzM4fjpRuoucWcU2h7a8gxYqIffIkenTC8e6GxY8ligLzcP6Balal4AFSR9w)ligLzcKelSFvsnXMCAFxY43pbxC13awawW1(C0byxcrojgnHF)I9lfNb1ljSup3sd8hrjcU4QVbSaSGR95OdWUeI8M0C(tWry6mOEjHL65OdWUe6fiAT6mOEjHL65iqPMC8S8sAo)j4imDguVKWs9C0byxcrUhuEPMarRv3BnSaeLYmhARF)SbIwRoWNZjEuO4qBlxHOPLJNqh8sMFbXOmt8IKNguVKWs9y)QKe7xkodQxsyPEULg4pIsnjhWiljpIm(9dIwRoWNZjEuO4qBlVutAo)j4imDV1WcGOuO4OdWUeswYuEPMytSFP4o9QOuVDlnWFe(9ZgiAT6o9QOuVDOTLytZ5pbhHP70RIs92H2wUcrtlhpHo4Lm)cIrzM4fjp3pGLI9bW3Gc7xLKy)sXTFalf7dGVbf3sd8hrPMe7xkoadkJg41GuSW(bSuGULg4pIsnbIwRoadkJg41GuSW(bSuGo02sa2EOq5ai3JiJF)SbIwRoadkJg41GuSW(bSuGo02Y97NnX(LIdWGYObEniflSFalfOBPb(JOCfIMwoEcDWlz(feJYmXlsEcfofW3w7OSFvsI9lfhu4uaFBTJ6wAG)ik1e1oIWASuCgbb0P5OPGCp0VFQDeH1yP4mccO7sYImKP8snby7HcLdGCpWdkxHOPLJNqh8sMFbXOmt8IKNtxWVKjal4AFSFvsI9lf30f8lzcWcU2NBPb(JOKMZFcoct3BnSaikfko6aSlHiNezuiAA54j0bVK5xqmkZeVi55BnSaikfkSFvsI9lf30f8lzcWcU2NBPb(JOeiAT6MUGFjtawW1(COTkenTC8e6GxY8ligLzIxK88VYGEebaJbWccxga7xLKy)sX9xzqpIaGXaybHldWT0a)rOq00YXtOdEjZVGyuMjErYZ)ykK8sMai)f2Vkjq0A1bfofW3w7Oo02sW29FqmkZeOtxyxg(JPqYlzqock1eiAT6amOmAGxdsXc7hWsb6qBlxHOPLJNqh8sMFbXOmt8IKNZOsrzqnFJ9RsceTwDtxWhmWRbg6mjartIrVKXH2wQj2e7xkoadkJg41GuSW(bSuGULg4pc)(brRvhGbLrd8Aqkwy)awkqhAB5kenTC8e6GxY8ligLzIxK8CgvkkdQ5BSFvsW29FqmkZeOtxyxg(JPqYlzillLyJGlU6Balal4AFo6Q0blmWFLyJIMRYPmZnDbFWaVgyOZKaenjg9sg3kd612oIsnXMy)sXbyqz0aVgKIf2pGLc0T0a)r43piAT6amOmAGxdsXc7hWsb6qB97xZ5pbhHP7TgwaeLcfhDa2LqYsMsa2EOq5aKLuZJGYviAA54j0bVK5xqmkZeVi55mQueGfCTp2VkjX(LIdWGYObEniflSFalfOBPb(JOutGO1QdWGYObEniflSFalfOdT1VFnN)eCeMU3AybqukuC0byxcjlzkby7HcLdqwsnpc87h2U)dIrzMaD6c7YWFmfsEjdYrqjq0A1bfofW3w7Oo02sAo)j4imDV1WcGOuO4OdWUeICsmAIY97NnX(LIdWGYObEniflSFalfOBPb(JqHOPLJNqh8sMFbXOmt8IKN)Xui5Lmbq(lSFvsnbIwRoOWPa(2Ah1rhGDje5WjYLmqhumTVaiAToQhZOj8yq0A1bfofW3w7OoOyAF(9dIwRoOWPa(2Ah1H2wceTwDagugnWRbPyH9dyPaDOTLRq00YXtOdEjZVGyuMjErYZkLdLaSGR9X(vjj2VuCNEvuQ3ULg4pIsI9lfhGbLrd8Aqkwy)awkq3sd8hrjq0A1D6vrPE7qBlbIwRoadkJg41GuSW(bSuGo0wfIMwoEcDWlz(feJYmXlsE(wdlaIsHc7xLeiAT6mOEjHL65qBviAA54j0bVK5xqmkZeVi55BnSaikfkSFvsAo)j4imd0zAPeBI9lfhGbLrd8Aqkwy)awkq3sd8hHcrtlhpHo4Lm)cIrzM4fjpp9QOuVz)QKe7xkUtVkk1B3sd8hrj2AcW2dfkhGSilKPKMZFcoct3BnSaikfko6aSlHiNezkxHOPLJNqh8sMFbXOmt8IKNV1WcGOuOW(vjP58NGJWmqNPLs6cJYmizf7xkUPl4bEniflSFalfOBPb(JqHOPLJNqh8sMFbXOmt8IKNvkhkbybx7J9RssSFP4o9QOuVDlnWFeLarRv3PxfL6TdTTeiAT6o9QOuVD0byxcroCICjd0bft7laIwRJ6XmAcpgeTwDNEvuQ3oOyAFkenTC8e6GxY8ligLzIxK88TgwaeLcf2VkjnN)eCeMb6mTOq00YXtOdEjZVGyuMjErYZ6Balal4AFSR9w)ligLzcKelSFvs0vPdwyG)uiAA54j0bVK5xqmkZeVi55mQuuguZ3y)QKGT7)GyuMjqNUWUm8htHKxYqwwkXgfnxLtzMB6c(GbEnWqNjbiAsm6LmUvg0RTDe(9dIwRUPl4dg41adDMeGOjXOxY4qBviAA54j0bVK5xqmkZeVi5zLYHsawW1(y)QKe7xkUtVkk1B3sd8hrjq0A1D6vrPE7qBl1eiAT6o9QOuVD0byxcroJMWJ9apgeTwDNEvuQ3oOyAF(9dIwRoOWPa(2Ah1H263pBI9lfhGbLrd8Aqkwy)awkq3sd8hr5kenTC8e6GxY8ligLzIxK8Ss5qjal4AFSFvsu0CvoLzU9dyPyFyLb9(dKEOaUvg0RTDeLydeTwD7hWsX(Wkd69hi9qbcedeTwDOTLytSFP42pGLI9bW3GIBPb(JOeBI9lf30f8lzcWcU2NBPb(JqHOPLJNqh8sMFbXOmt8IKN6c7YqHrBmOOq00YXtOdEjZVGyuMjErYtOyYPdehuxyuMX(vjj2VuCqXKthioOUWOmZT0a)rOq00YXtOdEjZVGyuMjErYZzuPiSFalf7z)QKytSFP4APhG9H9dyPy)bf3sd8hHF)S1oXvp6c7hWsXENPLRXuiAA54j0bVK5xqmkZeVi55FmfsEjtaK)IcrtlhpHo4Lm)cIrzM4fjpRVbSaSGR9XoaVXLmKyHDT36FbXOmtGKyH9RsIUkDWcd8NcrtlhpHo4Lm)cIrzM4fjpRVbSaSGR9XoaVXLmKyH9RscG3yalfhXbfl1JSEKcrtlhpHo4Lm)cIrzM4fjpRuoucWcU2h7a8gxYqIfCVXOWJNyKqazqazybbiazH7i0O5LmqChzdOLtLrOIiJkAA54Pk(huGofI4UHkfCkU3pa03KJNi7PwvW9)GceZkUdVK5xqmkZemRyKybZkUV0a)rGjh3nTC8e3RVbSaSGR9H7A6jJEgU3KkYMkkN23LmQOF)QibxC13awawW1(C0byxcvrKtsfz0eQOF)QOy)sXzq9scl1ZT0a)rOILurcU4QVbSaSGR95OdWUeQIixfBsf1C(tWry6mOEjHL65OdWUeQIEPIGO1QZG6LewQNJaLAYXtvSCvSKkQ58NGJW0zq9scl1ZrhGDjufrUk6bQy5QyjvSjveeTwDV1WcqukZCOTQOF)QiBQiiAT6aFoN4rHIdTvflh31ER)feJYmbIrIfSGrcbywX9Lg4pcm54UMEYONH7I9lfNb1ljSup3sd8hHkwsfBsfLdyQizjPIEezur)(vrq0A1b(CoXJcfhARkwUkwsfBsf1C(tWry6ERHfarPqXrhGDjufjRksgvSCvSKk2KkYMkk2VuCNEvuQ3ULg4pcv0VFvKnveeTwDNEvuQ3o0wvSKkYMkQ58NGJW0D6vrPE7qBvXYXDtlhpXDdQxsyPEybJKhIzf3xAG)iWKJ7A6jJEgUl2VuC7hWsX(a4BqXT0a)rOILuXMurX(LIdWGYObEniflSFalfOBPb(JqflPInPIGO1QdWGYObEniflSFalfOdTvflPIa2EOq5aQiYvrpImQOF)QiBQiiAT6amOmAGxdsXc7hWsb6qBvXYvr)(vr2urX(LIdWGYObEniflSFalfOBPb(Jqflh3nTC8e33pGLI9bW3GcwWi5bywX9Lg4pcm54UMEYONH7I9lfhu4uaFBTJ6wAG)iuXsQytQi1oIWASuCgbb0P5OPOIixf9qv0VFvKAhrynwkoJGa6UufjRkImKrflxflPInPIa2EOq5aQiYvrpWduXYXDtlhpXDOWPa(2AhflyKqgmR4(sd8hbMCCxtpz0ZWDX(LIB6c(Lmbybx7ZT0a)rOILurnN)eCeMU3AybqukuC0byxcvrKtsfjdUBA54jUpDb)sMaSGR9HfmsEeMvCFPb(JatoURPNm6z4Uy)sXnDb)sMaSGR95wAG)iuXsQiiAT6MUGFjtawW1(COT4UPLJN4(BnSaikfkybJeYcZkUV0a)rGjh310tg9mCxSFP4(RmOhraWyaSGWLb4wAG)iWDtlhpX9)kd6reamgaliCzaybJuzJzf3xAG)iWKJ7A6jJEgUdIwRoOWPa(2Ah1H2QILury7(pigLzc0PlSld)Xui5LmQiYvreOILuXMurq0A1byqz0aVgKIf2pGLc0H2QILJ7MwoEI7)Xui5Lmbq(lybJuZJzf3xAG)iWKJ7A6jJEgUdIwRUPl4dg41adDMeGOjXOxY4qBvXsQytQiBQOy)sXbyqz0aVgKIf2pGLc0T0a)rOI(9RIGO1QdWGYObEniflSFalfOdTvflh3nTC8e3NrLIYGA(gwWiXczWSI7lnWFeyYXDn9Krpd3HT7)GyuMjqNUWUm8htHKxYOIKvfzrflPISPIeCXvFdybybx7ZrxLoyHb(tflPISPIu0CvoLzUPl4dg41adDMeGOjXOxY4wzqV22rOILuXMur2urX(LIdWGYObEniflSFalfOBPb(Jqf97xfbrRvhGbLrd8Aqkwy)awkqhARk63VkQ58NGJW09wdlaIsHIJoa7sOkswvKmQyjveW2dfkhqfjljvS5rGkwoUBA54jUpJkfLb18nSGrIfwWSI7lnWFeyYXDn9Krpd3f7xkoadkJg41GuSW(bSuGULg4pcvSKk2KkcIwRoadkJg41GuSW(bSuGo0wv0VFvuZ5pbhHP7TgwaeLcfhDa2LqvKSQizuXsQiGThkuoGkswsQyZJav0VFve2U)dIrzMaD6c7YWFmfsEjJkICvebQyjveeTwDqHtb8T1oQdTvflPIAo)j4imDV1WcGOuO4OdWUeQIiNKkYOjuXYvr)(vr2urX(LIdWGYObEniflSFalfOBPb(Ja3nTC8e3NrLIaSGR9HfmsSGamR4(sd8hbMCCxtpz0ZW9Murq0A1bfofW3w7Oo6aSlHQiYvr4e5sgOdkM2xaeTwhvf9yvKrtOIESkcIwRoOWPa(2Ah1bft7tf97xfbrRvhu4uaFBTJ6qBvXsQiiAT6amOmAGxdsXc7hWsb6qBvXYXDtlhpX9)ykK8sMai)fSGrIfpeZkUV0a)rGjh310tg9mCxSFP4o9QOuVDlnWFeQyjvuSFP4amOmAGxdsXc7hWsb6wAG)iuXsQiiAT6o9QOuVDOTQyjveeTwDagugnWRbPyH9dyPaDOT4UPLJN4ELYHsawW1(Wcgjw8amR4(sd8hbMCCxtpz0ZWDq0A1zq9scl1ZH2I7MwoEI7V1WcGOuOGfmsSGmywX9Lg4pcm54UMEYONH7Ao)j4imd0zArflPISPII9lfhGbLrd8Aqkwy)awkq3sd8hbUBA54jU)wdlaIsHcwWiXIhHzf3xAG)iWKJ7A6jJEgUl2VuCNEvuQ3ULg4pcvSKkYMk2Kkcy7HcLdOIKvfrwiJkwsf1C(tWry6ERHfarPqXrhGDjufrojvKmQy54UPLJN4(PxfL6nwWiXcYcZkUV0a)rGjh310tg9mCxZ5pbhHzGotlQyjvuxyuMbvrYQII9lf30f8aVgKIf2pGLc0T0a)rG7MwoEI7V1WcGOuOGfmsSu2ywX9Lg4pcm54UMEYONH7I9lf3PxfL6TBPb(JqflPIGO1Q70RIs92H2QILurq0A1D6vrPE7OdWUeQIixfHtKlzGoOyAFbq0ADuv0JvrgnHk6XQiiAT6o9QOuVDqX0(WDtlhpX9kLdLaSGR9HfmsS08ywX9Lg4pcm54UMEYONH7Ao)j4imd0zAb3nTC8e3FRHfarPqblyKqazWSI7lnWFeyYXDtlhpX96Balal4AF4UMEYONH70vPdwyG)WDT36FbXOmtGyKyblyKqalywX9Lg4pcm54UMEYONH7W29FqmkZeOtxyxg(JPqYlzurYQISOILur2urkAUkNYm30f8bd8AGHotcq0Ky0lzCRmOxB7iur)(vrq0A1nDbFWaVgyOZKaenjg9sghAlUBA54jUpJkfLb18nSGrcbiaZkUV0a)rGjh310tg9mCxSFP4o9QOuVDlnWFeQyjveeTwDNEvuQ3o0wvSKk2KkcIwRUtVkk1BhDa2Lqve5QiJMqf9yv0durpwfbrRv3PxfL6TdkM2Nk63VkcIwRoOWPa(2Ah1H2QI(9RISPII9lfhGbLrd8Aqkwy)awkq3sd8hHkwoUBA54jUxPCOeGfCTpSGrcbEiMvCFPb(JatoURPNm6z4ofnxLtzMB)awk2hwzqV)aPhkGBLb9ABhHkwsfztfbrRv3(bSuSpSYGE)bspuGaXarRvhARkwsfztff7xkU9dyPyFa8nO4wAG)iuXsQiBQOy)sXnDb)sMaSGR95wAG)iWDtlhpX9kLdLaSGR9HfmsiWdWSI7MwoEI76c7YqHrBmOG7lnWFeyYXcgjeGmywX9Lg4pcm54UMEYONH7I9lfhum50bIdQlmkZClnWFe4UPLJN4oum50bIdQlmkZWcgje4rywX9Lg4pcm54UMEYONH7SPII9lfxl9aSpSFalf7pO4wAG)iur)(vr2uX2jU6rxy)awk27mTCngUBA54jUpJkfH9dyPypwWiHaKfMvC30YXtC)pMcjVKjaYFb3xAG)iWKJfmsiOSXSI7a8gxYGrIfCFPb(laWBCjdMCC30YXtCV(gWcWcU2hUR9w)ligLzceJel4UMEYONH70vPdwyG)W9Lg4pcm5ybJecAEmR4(sd8hbMCCFPb(laWBCjdMCCxtpz0ZWDaEJbSuCehuSupvKSQOhH7MwoEI713awawW1(WDaEJlzWiXcwWi5HKbZkUdWBCjdgjwW9Lg4VaaVXLmyYXDtlhpX9kLdLaSGR9H7lnWFeyYXcwWDIvn0xWSIrIfmR4(sd8hbMCCNyqn9ALJN4oYwkJsrBfvKxvrTbfOd3nTC8e3r4LebyXmkwWiHamR4oaVXLmyKyb3xAG)ca8gxYGjh3nTC8e3HTh9eeAVVrHbgQPhUV0a)rGjhlyK8qmR4UPLJN4ElxoEI7lnWFeyYXcgjpaZkUBA54jUJcx4KbaX9Lg4pcm5ybJeYGzf3nTC8e3RhDH9dyPypUV0a)rGjhlyK8imR4UPLJN4oWKXP4(sd8hbMCSGrczHzf3nTC8e3HcNce2pGLI94(sd8hbMCSGrQSXSI7lnWFeyYXDn9Krpd3brRvN2(p8htHKxY4OdWUeQIKLKkYczWDtlhpX959c8AqkwakCkawWi18ywX9Lg4pcm54UMEYONH7SPII9lfNb1ljSup3sd8hHk63VkcIwRodQxsyPEo0wv0VFvuZ5pbhHPZG6LewQNJoa7sOkswvezidUBA54jUd(CorOIs9glyKyHmywX9Lg4pcm54UMEYONH7SPII9lfNb1ljSup3sd8hHk63VkcIwRodQxsyPEo0wC30YXtChCu4O(UKblyKyHfmR4(sd8hbMCCxtpz0ZWD2urX(LIZG6LewQNBPb(Jqf97xfbrRvNb1ljSuphARk63VkQ58NGJW0zq9scl1ZrhGDjufjRkImKb3nTC8e3RhDGpNtGfmsSGamR4(sd8hbMCCxtpz0ZWD2urX(LIZG6LewQNBPb(Jqf97xfbrRvNb1ljSuphARk63VkQ58NGJW0zq9scl1ZrhGDjufjRkImKb3nTC8e3TupOqTpOT)Xcgjw8qmR4(sd8hbMCCxtpz0ZWD2urX(LIZG6LewQNBPb(Jqf97xfztfbrRvNb1ljSuphAlUBA54jUdAmbEni0t7dIfmsS4bywX9Lg4pcm54UPLJN4El9a4uIZ(acTgd310tg9mCNnveeTwDT0dGtjo7di0AmhAlUR9w)ligLzceJelybJelidMvC30YXtCVXGTJgeUmaCFPb(JatowWiXIhHzf3xAG)iWKJ7A6jJEgUZMkk2VuCagugnWRbPyH9dyPaDlnWFeQOF)QiiAT6amOmAGxdsXc7hWsb6qBXDtlhpX9QTGqTewrHhpXcgjwqwywX9Lg4pcm54UMEYONH7MwUglSCa3GQizvreOILuXMury7(pigLzc0PlSld)Xui5LmQizvreOI(9RIW29FqmkZeO7TgwaCgGkswvebQy54UPLJN4ofndMwoEg(dk4(FqjKgWWDJpSGrILYgZkUV0a)rGjh310tg9mCNnvuSFP4GcNce2pGLI9ULg4pcvSKkAA5ASWYbCdQIiNKkIaC30YXtCNIMbtlhpd)bfC)pOesdy4o8sMFbXOmtWcgjwAEmR4(sd8hbMCCxtpz0ZWDX(LIdkCkqy)awk27wAG)iuXsQOPLRXclhWnOkICsQicWDtlhpXDkAgmTC8m8huW9)GsinGH7WfGxY8ligLzcwWcU3sNMdaAcMvmsSGzf3xAG)iWKJ7MwoEI7ZOsry)awk2J7edQPxRC8e3B2YstJkJqfxJr9wfLdyQOumv00cNQIhufTg29g4phURPNm6z4oBQOy)sX1spa7d7hWsX(dkULg4pcSGrcbywX9Lg4pcm54UPLJN4ou4uaFBTJI7edQPxRC8e3BUHtf7cNc4BRDuvSLonha0even)bHQiKdmv0iiGQicV)vryRHWufHCE6WDn9Krpd3f7xkoOWPa(2Ah1T0a)rOILuXMurQDeH1yP4mccOtZrtrfrUk6HQOF)Qi1oIWASuCgbb0DPkswveziJkwowWi5HywX9Lg4pcm54UMEYONH7I9lf3(bSuSpa(guClnWFe4UPLJN4((bSuSpa(guWcgjpaZkUV0a)rGjh310tg9mCNnvuSFP42pGLI9bW3GIBPb(Ja3nTC8e3FRHfarPqblyKqgmR4UPLJN4ElxoEI7lnWFeyYXcwWDJpmRyKybZkUV0a)rGjh310tg9mCheTwDtxWVKjal4AFo0wC30YXtCFgvkkdQ5BybJecWSI7MwoEI76c7YqHrBmOG7lnWFeyYXcgjpeZkUV0a)rGjh310tg9mCxSFP4GcNc4BRDu3sd8hbUBA54jUdfofW3w7OybJKhGzf3xAG)iWKJ7MwoEI713awawW1(WDn9Krpd3nTCnwGGlU6Balal4AFQiYvrpuflPIMwUglSCa3GQiYjPIiJk63VksrZv5uM5G(8gKoZ3OWq9g17aXao4CRmOxB7iWDT36FbXOmtGyKyblyKqgmR4(sd8hbMCCxtpz0ZWD2urtlxJfi4IR(gWcWcU2hUBA54jUxFdybybx7dlyK8imR4(sd8hbMCCxtpz0ZWDX(LIB6c(Lmbybx7ZT0a)rOILuraBpuOCavKSKurpIm4UPLJN4(0f8lzcWcU2hwWiHSWSI7lnWFeyYXDn9Krpd3f7xkodQxsyPEULg4pcvSKk2KkYMk2oXbfofiSFalf7DMwUgtflxflPInPISPII9lf3PxfL6TBPb(Jqf97xfztfbrRv3PxfL6TdTvflPISPIAo)j4imDNEvuQ3o0wvSCC30YXtC3G6LewQhwWiv2ywX9Lg4pcm54UMEYONH7I9lf3FLb9icagdGfeUma3sd8hbUBA54jU)xzqpIaGXaybHldalyKAEmR4(sd8hbMCCxtpz0ZWDkAUkNYm30f8bd8AGHotcq0Ky0lzCRmOxB7iuXsQiBQiiAT6MUGpyGxdm0zsaIMeJEjJdTf3nTC8e3NrLIaSGR9HfmsSqgmR4(sd8hbMCCxtpz0ZWDkAUkNYmhXwRqhaNgGcpNBLb9ABhHkwsfBsfztff7xkUw6byFy)awk2FqXT0a)rOI(9RInPISPITtCqHtbc7hWsXENPLRXuXsQiBQy7ex9OlSFalf7DMwUgtflxflh3nTC8e3NrLIW(bSuShlyKyHfmR4(sd8hbMCC30YXtC)TgwaeLcfCxtpz0ZWDy7(pigLzc0PlSld)Xui5LmQiYvrpqf97xfbrRv3BnSaeLYmhARk63Vk2Kkk2VuCagugnWRbPyH9dyPaDlnWFeQyjvKnveeTwDagugnWRbPyH9dyPaDOTQyjveW2dfkhqfjljv0JiJkwoUR9w)ligLzceJelybJeliaZkUV0a)rGjh3nTC8e3NrLIYGA(gUtmOMETYXtCNvQ3QOWvrgdyQyZAuPOmOMVPIi8KcvSSAqzuvKxvrPyQyZ(dyPavrq0AvfryXsvSEmfYLmQOhQIIrzMaDQyzzE2CjQiVXOARvflR2EOq5aSH7A6jJEgUZMkk2VuCagugnWRbPyH9dyPaDlnWFeQOF)QiiAT6GcNc4BRDuhARk63Vkcy7HcLdOIKLKk2KkYcziJkwwOIEGk6XQiSD)heJYmb60f2LH)ykK8sgvSCv0VFveeTwDagugnWRbPyH9dyPaDOTQOF)QiSD)heJYmb60f2LH)ykK8sgvKSQOhIfmsS4HywX9Lg4pcm54UPLJN4UUWUm8htHKxYG7edQPxRC8e3lRMVPIqu6urV5OQibpBUev85WPIMk2fofW3w7OQiiAT6WDn9Krpd3brRvhu4uaFBTJ6OdWUeQIixf9qv0JvrgnHk6XQiiAT6GcNc4BRDuhumTpSGrIfpaZkUV0a)rGjh3nTC8e3FRHfarPqb3jgutVw54jU3CMV3QO2GIk2C0AyQi5OuOOI8ufLc6MkkgLzcufVQkEIkEqv0sv8sOyPOIwsOIDHtbuXM9hWsXEv8GQisnNSQIMwUgZH7A6jJEgUdIwRU3AybikLzo0wvSKkcB3)bXOmtGoDHDz4pMcjVKrfrUk6bQyjvSjvKnvSDIdkCkqy)awk27mTCnMkwUkwsfj4IR(gWcWcU2NtoTVlzWcgjwqgmR4(sd8hbMCC30YXtCF)awk2haFdk4oXGA61khpX9MB4uXM9hWsXEvK83GIkAm2LqrfrBvrHRIEOkkgLzcufnOk(8KrfnOk2fofqfB2Falf7vXdQIjxurtlxJ5WDn9Krpd3f7xkU9dyPyFa8nO4wAG)iuXsQiSD)heJYmb60f2LH)ykK8sgve5QiYOILuXMur2uX2joOWPaH9dyPyVZ0Y1yQy5ybJelEeMvCFPb(JatoURPNm6z4Uy)sXzq9scl1ZT0a)rG7MwoEI7V1WcGZaWcgjwqwywXDtlhpXDDHDz4pMcjVKb3xAG)iWKJfmsSu2ywX9Lg4pcm54(sd8xaG34sgm54UMEYONH7GO1Q7TgwaIszMdTvflPIAo)j4imd0zAb3nTC8e3FRHfarPqb3b4nUKbJelybJelnpMvChG34sgmsSG7lnWFbaEJlzWKJ7MwoEI713awawW1(WDT36FbXOmtGyKyb310tg9mCNUkDWcd8hUV0a)rGjhlyKqazWSI7a8gxYGrIfCFPb(laWBCjdMCC30YXtCVs5qjal4AF4(sd8hbMCSGfChUa8sMFbXOmtWSIrIfmR4(sd8hbMCC30YXtCV(gWcWcU2hURPNm6z4EtQiDa2Lqve5KurgnHkwUkwsfBsfbrRv3BnSaeLYmhARk63VkYMkcIwRoWNZjEuO4qBvXYXDT36FbXOmtGyKyblyKqaMvCFPb(JatoURPNm6z4Uy)sXTFalf7dGVbf3sd8hbUBA54jUVFalf7dGVbfSGrYdXSI7lnWFeyYXDn9Krpd3f7xkoOWPa(2Ah1T0a)rOILuXMuraBpuOCave5QOh4bQy54UPLJN4ou4uaFBTJIfmsEaMvCFPb(JatoURPNm6z4Uy)sXnDb)sMaSGR95wAG)iWDtlhpX9Pl4xYeGfCTpSGrczWSI7lnWFeyYXDn9Krpd3brRvhcVKiWGcfhumTpve5QilLTk63VkcIwRU3AybikLzo0wC30YXtC)TgwaeLcfSGrYJWSI7lnWFeyYXDn9Krpd3brRvhu4uaFBTJ6qBXDtlhpX9)ykK8sMai)fSGrczHzf3xAG)iWKJ7A6jJEgUdIwRUPl4dg41adDMeGOjXOxY4qBXDtlhpX9zuPOmOMVHfmsLnMvCFPb(JatoURPNm6z4EtQiSD)heJYmb60f2LH)ykK8sgvKSQilQy5QyjvSjvKnvKGlU6Balal4AFo6Q0blmWFQy54UPLJN4(mQuuguZ3WcgPMhZkUV0a)rGjh310tg9mCh2U)dIrzMaD6c7YWFmfsEjJkICvebQyjveW2dfkhqfjljv0JiJkwsfBsfbrRvhcVKiWGcfhumTpve5QiciJk63Vkcy7HcLdOIKvfBEYOILRI(9RInPIu0CvoLzUPl4dg41adDMeGOjXOxY4wzqV22rOILur2urq0A1nDbFWaVgyOZKaenjg9sghARkwoUBA54jUpJkfbybx7dlyKyHmywX9Lg4pcm54UMEYONH7nPIGO1QdkCkGVT2rD0byxcvrKRIWjYLmqhumTVaiAToQk6XQiJMqf9yveeTwDqHtb8T1oQdkM2Nk63VkcIwRoOWPa(2Ah1H2QILurq0A1byqz0aVgKIf2pGLc0H2QILJ7MwoEI7)Xui5Lmbq(lybJelSGzf3xAG)iWKJ7A6jJEgUl2VuCNEvuQ3ULg4pcvSKkk2VuCagugnWRbPyH9dyPaDlnWFeQyjveeTwDNEvuQ3o0wvSKkcIwRoadkJg41GuSW(bSuGo0wC30YXtCVs5qjal4AFybJeliaZkUV0a)rGjh310tg9mCheTwDguVKWs9COT4UPLJN4(BnSaikfkybJelEiMvCFPb(JatoURPNm6z4UMZFcocZaDMwuXsQiBQOy)sXbyqz0aVgKIf2pGLc0T0a)rG7MwoEI7V1WcGOuOGfmsS4bywX9Lg4pcm54UMEYONH7I9lf3PxfL6TBPb(JqflPISPInPIa2EOq5aQizvrKfYOILurnN)eCeMU3AybqukuC0byxcvrKtsfjJkwoUBA54jUF6vrPEJfmsSGmywX9Lg4pcm54UMEYONH7Ao)j4imd0zArflPI6cJYmOkswvuSFP4MUGh41GuSW(bSuGULg4pcC30YXtC)TgwaeLcfSGrIfpcZkUV0a)rGjh310tg9mCxSFP4o9QOuVDlnWFeQyjveeTwDNEvuQ3o0wC30YXtCVs5qjal4AFybJelilmR4UPLJN4UUWUmuy0gdk4(sd8hbMCSGrILYgZkUV0a)rGjh310tg9mCxSFP4GIjNoqCqDHrzMBPb(Ja3nTC8e3HIjNoqCqDHrzgwWiXsZJzf3xAG)iWKJ7A6jJEgUZMkk2VuCT0dW(W(bSuS)GIBPb(Jqf97xff7xkUw6byFy)awk2FqXT0a)rOILuXMur2uX2joOWPaH9dyPyVZ0Y1yQy54UPLJN4(mQue2pGLI9ybJecidMvC30YXtC)pMcjVKjaYFb3xAG)iWKJfmsiGfmR4oaVXLmyKyb3xAG)ca8gxYGjh3nTC8e3RVbSaSGR9H7AV1)cIrzMaXiXcURPNm6z4oDv6Gfg4pCFPb(JatowWiHaeGzf3xAG)iWKJ7lnWFbaEJlzWKJ7A6jJEgUdWBmGLIJ4GIL6PIKvf9iC30YXtCV(gWcWcU2hUdWBCjdgjwWcgje4HywXDaEJlzWiXcUV0a)fa4nUKbtoUBA54jUxPCOeGfCTpCFPb(JatowWcwWcwWya]] )

end
