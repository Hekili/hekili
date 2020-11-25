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

        bloodlust = {
            id = 2825,
            duration = 40,
            type = "Magic",
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
            id = 77756,
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

        sated = {
            id = 57724,
            duration = 600,
            max_stack = 1,
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
                    duration = 15,
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

        potion = "potion_of_unbridled_fury",

        package = "Elemental",
    } )

    --[[ spec:RegisterSetting( "micromanage_pets", true, {
        name = "Micromanage Primal Elemental Pets",
        desc = "If checked, Meteor, Eye of the Storm, etc. will appear in your recommendations.",
        type = "toggle",
        width = 1.5
    } ) ]]

    spec:RegisterPack( "Elemental", 20201124, [[dCu2zbqiQsEKqjTjHQpPkfQgLuOtjfSkuvQxrv0Sqv1Tqiu7Ik)IQWWKsCmuLwMqXZqiAAQsPRHQs2gQk8necghQkY5uLIwNqjI5jL09qW(qiDqHsulevXdrietuOePUOqj8rHsKCsvPGvkLAMQsHu3eHqANQs(PQuOSuvPqYtLQPIqDvvPq0Eb(RGblXHPSyiEmjtgrxwzZs6ZOYOfYPv51uvnBq3wvTBr)gLHRkoUqPwosphQPtCDiTDPOVRkvJxvkeopvPwpQkQ5tvz)KAaVaIbDstg4vmTetl8YBmV1fdr2cra0fVFgO)yk)g3a90(d0JfW9xkge0FmVHmJeqmOJzOu1a9irEWXs8WdUtIqrCk23d89rHMCSurTQ4b((kpaDe0dkVHeGa6KMmWRyAjMw4L3yERlgISf(igqh)mf4vm8rmGE0rsUeGa6KdRa9yvxIfW9xkgux6r23sD7yvxEXAUpYO6smVLFDjMwIPfDBD7yvxiIezj3WXs0TJvDHiwxILjjhPUGyk)Op6sSaJxQMUyih8eVD62XQUqeRlVHuXOpmQjtxWtKl5WoSyk)be0ADuDPYO6YBqTkk1B(1LUWOF)BpJ6a9hkREWb6XQUelG7VumOU0JSVL62XQU8I1CFKr1LyEl)6smTetl6262XQUqejYsUHJLOBhR6crSUeltsosDbXu(rF0LybgVunDXqo4jE70TJvDHiwxEdPIrFyutMUGNixYHDyXu(diO16O6sLr1L3GAvuQ38RlDHr)(3Eg1PBRBBk5yj29qNI9rmHakEHt2N)0(JGXNXrg1WHklLaRgEyVpQUTPKJLy3dDk2hXepj4XdtowQBRBhR6sS4nIPqLrQlR5OERlY9NUirtxmLWO6YH1fRPDqdboNUDSQlermSOl8azmsikw0LVLOge6TUCvDrIMUelZNh9KPletTt0Ly5unSqnOU8g1WS0s10LdRlp0HxkoDBtjhlXeqGmgjefl8FvcgFE0tMZs1Wc1Gb6WS0s1Clne4i1TJvD5nKeXk2hXeD5Hjhl1LdRlp0vhDPCge6TUaV0)i1fHPls00LyPqnk5zPUWQ6sSmFEuMeXVUGMWHX6II9rmrxE)GqDzjPUGJyub6Tt32uYXsSNe84Hjhl5)QeQhxKeO7BxIBLpAXNpfJbjzVNoouJsEwgy1GXNhLjro6(2L4wjYw0T1TJvD5nKYOu0hrxyvDrzyb70TnLCSe7jbpE)sYaoAgv32uYXsSNe8afVWj7J1TnLCSe7jbpQhDHb3FPyqDBtjhlXEsWdSWO)WG7VumOUTUTPKJLypj4HILQLc1KrgQq7pDBtjhlXEsWdeiJrgy1GeTWY99w32uYXsSNe8Gd1OKNLbwny85rzsKUTPKJLypj4rLPqXJmy85rpzbKzFDBtjhlXEsWJhu6v9(sUac0WIUTPKJLypj4HeTaAIWqtYqLrvt32uYXsSNe84VpJ6DGvdqu1rgiPZ(yDBtjhlXEsWd698ax4Ya(Xut32uYXsSNe84Dgfs2CxgOdZslvt32uYXsSNe8Go75sUqfA)H5)QeeJYnXfndkrHhLqu(ul(8jgLBIlAguIcpkP1yAXNV6Xfjb6(2L4wjYw0TJvD5nK6IYWtxEd6sLr5yIUGz)jrxY50TnLCSe7jbpIMrLWW4LQPBRBBk5yj2tcEGazmYqfL6n)xLGxIbxkodRwsAPAULgcCK(8HGwRodRwsAPAo0hF(umgKK9E6mSAjPLQ5O7BxIjkF1IUTPKJLypj4bYO4r9Fjh)xLGxIbxkodRwsAPAULgcCK(8HGwRodRwsAPAo0hDBtjhlXEsWJ6rhcKXi5)Qe8sm4sXzy1sslvZT0qGJ0Npe0A1zy1sslvZH(4ZNIXGKS3tNHvljTunhDF7smr5Rw0TnLCSe7jbpSunSqnyqzqi)xLGxIbxkodRwsAPAULgcCK(8HGwRodRwsAPAo0hF(umgKK9E6mSAjPLQ5O7BxIjkF1IUTPKJLypj4bIXfy1GqpLFm)xLGxIbxkodRwsAPAULgcCK(85fcAT6mSAjPLQ5qF0T1TnLCSe7jbpEO3NrjpdgE3Ao(vERGligLBcMaV8FvcEHGwRUh69zuYZGH3TMZH(OBBk5yj2tcE0C4Nrdct2x32uYXsSNe8OAliulXvu8XsDBDBtjhlXEsWdkAgmLCSmapSWFA)rWyJ)RsWuY1CHL7Fdt0yI3i(zqyqmk3eStfzxgGhxKKxYr0y85d)mimigLBc2bTMwaz2NOX0GUTPKJLypj4bfndMsowgGhw4pT)iGVKdUGyuUj8FvcEjgCP4WcJ(ddU)sXGULgcCKXnLCnxy5(3WTsigDBtjhlXEsWdkAgmLCSmapSWFA)raVa(so4cIr5MW)vjigCP4WcJ(ddU)sXGULgcCKXnLCnxy5(3WTsigDBDBtjhlXoJncZOsuSrn)J)RsabTwDtfXUKlGJyk)o0hDBtjhlXoJnpj4HkYUmez0Mdl62MsowIDgBEsWdSWOF)BpJY)vjigCP4WcJ(9V9mQBPHahPUTPKJLyNXMNe8OcT)c4iMYp)kVvWfeJYnbtGx(VkbtjxZfizIRcT)c4iMYFRezCtjxZfwU)nCRe4lF(OO5Qmk3Cy)EJqN5FuCOEJ6DGC)dp3In698msDBtjhlXoJnpj4rfA)fWrmLF(VkbVmLCnxGKjUk0(lGJyk)62MsowIDgBEsWJPIyxYfWrmLF(VkbXGlf3urSl5c4iMYVBPHahz8VniwOSprjWhTOBBk5yj2zS5jbpmSAjPLQX)vjigCP4mSAjPLQ5wAiWrgVrVEM4WcJ(ddU)sXGotjxZ1q8g9sm4sXDQvrPE7wAiWr6ZNxiO1Q7uRIs92H(e3lfJbjzVNUtTkk1Bh6td62MsowIDgBEsWd4fB0Jm8nUVfeMSp)xLGyWLIdEXg9idFJ7BbHj77wAiWrQBBk5yj2zS5jbpMrLOaoIP8Z)vjqrZvzuU5MkInCGvdC0zsaJMKJEjNBXg9EEgzCVqqRv3urSHdSAGJotcy0KC0l5COp62MsowIDgBEsWJzujkm4(lfdY)vjqrZvzuU5i3Ee6(mAalSCUfB075zKXB0lXGlf3d9(gmm4(lfdEyXT0qGJ0NVg96zIdlm6pm4(lfd6mLCnxCVEM4QhDHb3FPyqNPKR5AObDBtjhlXoJnpj4b0AAbeukw4x5TcUGyuUjyc8Y)vjGFgegeJYnb7ur2Lb4Xfj5LCT(wF(qqRvh0AAbmkLBo0hF(Aum4sX9nSmAGvds0cdU)sb7wAiWrg3le0A19nSmAGvds0cdU)sb7qFI)TbXcL9jkb(OLg0TJvDHyQ36IW0fo7pDjwyujk2OM)PlVFsKUqe1WYO6cRQls00LybC)LcwxqqRvD59OL6s94IKl50fIuxeJYnb70LyPz5BCrxynhvzp6cruBqSqzFV0TnLCSe7m28KGhZOsuSrn)J)RsWlXGlf33WYObwnirlm4(lfSBPHahPpFiO1Qdlm63)2ZOo0hF((2GyHY(eLqJ82sleXVLVXpdcdIr5MGDQi7Ya84IK8sUg85dbTwDFdlJgy1GeTWG7VuWo0hF(WpdcdIr5MGDQi7Ya84IK8soIsK62XQUqe18pDbJsNU4ndvxiz5BCrxGm80ftx6cJ(9V9mQUGGwRoDBtjhlXoJnpj4HkYUmapUijVKJ)RsabTwDyHr)(3Eg1r33Ue3krY3Cks(gbTwDyHr)(3Eg1Hft5x3ow1L3yj0BDrzyrxEJ2AA6cpOuSOlSuxKi6MUigLBcwxUQUCIUCyDXsD5sSyPOlwsQlDHr)6sSaU)sXG6YH1LxVXiwxmLCnNt32uYXsSZyZtcEaTMwabLIf(Vkbe0A1bTMwaJs5Md9jo(zqyqmk3eStfzxgGhxKKxY16BJ3OxptCyHr)Hb3FPyqNPKR5AiojtCvO9xahXu(DYP8FjNUDSQlVrINUelG7VumOUWd0WIUyC2LyrxqF0fHPlePUigLBcwxmSUazjNUyyDPlm6xxIfW9xkguxoSUKmrxmLCnNt32uYXsSZyZtcEm4(lfdgqGgw4)QeedUuCdU)sXGbeOHf3sdboY44NbHbXOCtWovKDzaECrsEjxR8v8g96zIdlm6pm4(lfd6mLCnxd62MsowIDgBEsWdO10ciZ(8FvcIbxkodRwsAPAULgcCK62MsowIDgBEsWdvKDzaECrsEjNUTPKJLyNXMNe8aAnTackfl8)znVKJaV8FvciO1QdAnTagLYnh6tCfJbjzVNb6mLOBBk5yj2zS5jbpQq7VaoIP8Z)N18soc8YVYBfCbXOCtWe4L)RsGUkD4idboDBtjhlXoJnpj4rLYWsahXu(5)ZAEjhbE1T1TnLCSe7WlGVKdUGyuUjeQq7VaoIP8ZVYBfCbXOCtWe4L)RsOr6(2L4wjWPiBiEJiO1QdAnTagLYnh6JpFEHGwRoeiJrcrXId9PbDBtjhlXo8c4l5GligLBINe8yW9xkgmGanSW)vjigCP4gC)LIbdiqdlULgcCK62MsowID4fWxYbxqmk3epj4bwy0V)TNr5)QeedUuCyHr)(3Eg1T0qGJmEJFBqSqz)wF7BBq32uYXsSdVa(so4cIr5M4jbpMkIDjxahXu(5)QeedUuCtfXUKlGJyk)ULgcCK62MsowID4fWxYbxqmk3epj4b0AAbeukw4)QeqqRv37xsg4qXIdlMYFR8YN85dbTwDqRPfWOuU5qF0TnLCSe7WlGVKdUGyuUjEsWd4Xfj5LCbegu4)QeqqRvhwy0V)TNrDOp62MsowID4fWxYbxqmk3epj4XmQefBuZ)4)QeqqRv3urSHdSAGJotcy0KC0l5COp62MsowID4fWxYbxqmk3epj4XmQefBuZ)4)QeAe)mimigLBc2PISldWJlsYl5ikVneVrVizIRcT)c4iMYVJUkD4idbUg0TnLCSe7WlGVKdUGyuUjEsWJzujkGJyk)8Fvc4NbHbXOCtWovKDzaECrsEjxRXe)BdIfk7tuc8rlXBebTwDVFjzGdfloSyk)Tgtl(89TbXcL9j6B2sd62MsowID4fWxYbxqmk3epj4b84IK8sUacdk8FvcnIGwRoSWOF)BpJ6O7BxIBfprUKd7WIP8hqqR1r5BofjFJGwRoSWOF)BpJ6WIP87ZhcAT6WcJ(9V9mQd9jocAT6(gwgnWQbjAHb3FPGDOpnOBBk5yj2HxaFjhCbXOCt8KGhvkdlbCet5N)Rsqm4sXDQvrPE7wAiWrgxm4sX9nSmAGvds0cdU)sb7wAiWrghbTwDNAvuQ3o0N4iO1Q7Byz0aRgKOfgC)Lc2H(OBBk5yj2HxaFjhCbXOCt8KGhqRPfqqPyH)RsabTwDgwTK0s1COp62MsowID4fWxYbxqmk3epj4b0AAbeukw4)QeumgKK9EgOZusCVedUuCFdlJgy1GeTWG7VuWULgcCK62MsowID4fWxYbxqmk3epj4XPwfL6n)xLGyWLI7uRIs92T0qGJmUxn(TbXcL9jkrGVIRymij790bTMwabLIfhDF7sCReAPbDBtjhlXo8c4l5GligLBINe8aAnTackfl8FvckgdsYEpd0zkjUkYOCdtuXGlf3urSaRgKOfgC)Lc2T0qGJu32uYXsSdVa(so4cIr5M4jbpQugwc4iMYp)xLGyWLI7uRIs92T0qGJmocAT6o1QOuVDOp62MsowID4fWxYbxqmk3epj4HkYUmez0Mdl62MsowID4fWxYbxqmk3epj4bwm5ubYdRImk34)QeedUuCyXKtfipSkYOCZT0qGJu32uYXsSdVa(so4cIr5M4jbpMrLOWG7Vumi)xLGxIbxkUh69nyyW9xkg8WIBPHahPpFIbxkUh69nyyW9xkg8WIBPHahz8g96zIdlm6pm4(lfd6mLCnxd62MsowID4fWxYbxqmk3epj4b84IK8sUacdk62MsowID4fWxYbxqmk3epj4rfA)fWrmLF()SMxYrGx(vERGligLBcMaV8Fvc0vPdhziWPBBk5yj2HxaFjhCbXOCt8KGhvO9xahXu(5)ZAEjhbE5)Qe(SM7VuCKhwSunIYh62MsowID4fWxYbxqmk3epj4rLYWsahXu(5)ZAEjhbE1T1TnLCSe7WxYbxqmk3ecvO9xahXu(5x5TcUGyuUjyc8Y)vj0OxYP8FjNpFKmXvH2FbCet53r33Ue3kbofPpFIbxkodRwsAPAULgcCKXjzIRcT)c4iMYVJUVDjU1gvmgKK9E6mSAjPLQ5O7BxI9ebTwDgwTK0s1CKOutow2qCfJbjzVNodRwsAPAo6(2L4wFBdXBebTwDqRPfWOuU5qF85Zle0A1HazmsikwCOpnOBBk5yj2HVKdUGyuUjEsWddRwsAPA8FvcIbxkodRwsAPAULgcCKXBuU)ikb(OfF(qqRvhcKXiHOyXH(0q8gvmgKK9E6GwtlGGsXIJUVDjMOT0q8g9sm4sXDQvrPE7wAiWr6ZNxiO1Q7uRIs92H(e3lfJbjzVNUtTkk1Bh6td62MsowID4l5GligLBINe8yW9xkgmGanSW)vjigCP4gC)LIbdiqdlULgcCKXBum4sX9nSmAGvds0cdU)sb7wAiWrgVre0A19nSmAGvds0cdU)sb7qFI)TbXcL9BLpAXNpVqqRv33WYObwnirlm4(lfSd9PbF(8sm4sX9nSmAGvds0cdU)sb7wAiWr2GUTPKJLyh(so4cIr5M4jbpWcJ(9V9mk)xLGyWLIdlm63)2ZOULgcCKXBKAhzynxkoJKe7um0uALi95JAhzynxkoJKe7UKO8vlneVXVniwOSFRV9TnOBBk5yj2HVKdUGyuUjEsWJPIyxYfWrmLF(VkbXGlf3urSl5c4iMYVBPHahzCfJbjzVNoO10ciOuS4O7BxIBLql62MsowID4l5GligLBINe8aAnTackfl8FvcIbxkUPIyxYfWrmLF3sdboY4iO1QBQi2LCbCet53H(OBBk5yj2HVKdUGyuUjEsWd4fB0Jm8nUVfeMSp)xLGyWLIdEXg9idFJ7BbHj77wAiWrQBBk5yj2HVKdUGyuUjEsWd4Xfj5LCbegu4)QeqqRvhwy0V)TNrDOpXXpdcdIr5MGDQi7Ya84IK8sUwJjEJiO1Q7Byz0aRgKOfgC)Lc2H(0GUTPKJLyh(so4cIr5M4jbpMrLOyJA(h)xLacAT6MkInCGvdC0zsaJMKJEjNd9jEJEjgCP4(gwgnWQbjAHb3FPGDlne4i95dbTwDFdlJgy1GeTWG7VuWo0Ng0TnLCSe7WxYbxqmk3epj4XmQefBuZ)4)QeWpdcdIr5MGDQi7Ya84IK8soIYBCVizIRcT)c4iMYVJUkD4idbU4ErrZvzuU5MkInCGvdC0zsaJMKJEjNBXg9EEgz8g9sm4sX9nSmAGvds0cdU)sb7wAiWr6ZhcAT6(gwgnWQbjAHb3FPGDOp(8Pymij790bTMwabLIfhDF7smrBj(3gelu2NOeEZyAq32uYXsSdFjhCbXOCt8KGhZOsuahXu(5)QeedUuCFdlJgy1GeTWG7VuWULgcCKXBebTwDFdlJgy1GeTWG7VuWo0hF(umgKK9E6GwtlGGsXIJUVDjMOTe)BdIfk7tucVzm(8HFgegeJYnb7ur2Lb4Xfj5LCTgtCe0A1Hfg97F7zuh6tCfJbjzVNoO10ciOuS4O7BxIBLaNISbF(8sm4sX9nSmAGvds0cdU)sb7wAiWrQBBk5yj2HVKdUGyuUjEsWd4Xfj5LCbegu4)QeAebTwDyHr)(3Eg1r33Ue3kEICjh2Hft5pGGwRJY3Cks(gbTwDyHr)(3Eg1Hft53Npe0A1Hfg97F7zuh6tCe0A19nSmAGvds0cdU)sb7qFAq32uYXsSdFjhCbXOCt8KGhvkdlbCet5N)Rsqm4sXDQvrPE7wAiWrgxm4sX9nSmAGvds0cdU)sb7wAiWrghbTwDNAvuQ3o0N4iO1Q7Byz0aRgKOfgC)Lc2H(OBBk5yj2HVKdUGyuUjEsWdO10ciOuSW)vjGGwRodRwsAPAo0hDBtjhlXo8LCWfeJYnXtcEaTMwabLIf(VkbfJbjzVNb6mLe3lXGlf33WYObwnirlm4(lfSBPHahPUTPKJLyh(so4cIr5M4jbpo1QOuV5)QeedUuCNAvuQ3ULgcCKX9QXVniwOSprjc8vCfJbjzVNoO10ciOuS4O7BxIBLqlnOBBk5yj2HVKdUGyuUjEsWdO10ciOuSW)vjOymij79mqNPK4QiJYnmrfdUuCtfXcSAqIwyW9xky3sdbosDBtjhlXo8LCWfeJYnXtcEuPmSeWrmLF(VkbXGlf3PwfL6TBPHahzCe0A1DQvrPE7qFIJGwRUtTkk1BhDF7sCR4jYLCyhwmL)acATokFZPi5Be0A1DQvrPE7WIP8RBBk5yj2HVKdUGyuUjEsWdO10ciOuSW)vjOymij79mqNPeDBtjhlXo8LCWfeJYnXtcEuH2FbCet5NFL3k4cIr5MGjWl)xLaDv6WrgcC62MsowID4l5GligLBINe8ygvIInQ5F8Fvc4NbHbXOCtWovKDzaECrsEjhr5nUxu0CvgLBUPIydhy1ahDMeWOj5OxY5wSrVNNr6ZhcAT6MkInCGvdC0zsaJMKJEjNd9r32uYXsSdFjhCbXOCt8KGhvkdlbCet5N)Rsqm4sXDQvrPE7wAiWrghbTwDNAvuQ3o0N4nIGwRUtTkk1BhDF7sCRCks((T8ncAT6o1QOuVDyXu(95dbTwDyHr)(3Eg1H(4ZNxIbxkUVHLrdSAqIwyW9xky3sdboYg0TnLCSe7WxYbxqmk3epj4rLYWsahXu(5)QeOO5Qmk3CdU)sXGHfB0dEi0d97wSrVNNrg3le0A1n4(lfdgwSrp4Hqp0FGCiO1Qd9jUxIbxkUb3FPyWac0WIBPHahzCVedUuCtfXUKlGJyk)ULgcCK62MsowID4l5GligLBINe8qfzxgImAZHfDBtjhlXo8LCWfeJYnXtcEGftovG8WQiJYn(VkbXGlfhwm5ubYdRImk3Clne4i1TnLCSe7WxYbxqmk3epj4XmQefgC)LIb5)Qe8sm4sX9qVVbddU)sXGhwClne4i95ZRNjU6rxyW9xkg0zk5AoDBtjhlXo8LCWfeJYnXtcEapUijVKlGWGIUTPKJLyh(so4cIr5M4jbpQq7VaoIP8Z)N18soc8YVYBfCbXOCtWe4L)RsGUkD4idboDBtjhlXo8LCWfeJYnXtcEuH2FbCet5N)pR5LCe4L)Rs4ZAU)sXrEyXs1ikFOBBk5yj2HVKdUGyuUjEsWJkLHLaoIP8Z)N18soc8c6nhfFSe8kMwIPfE5ngIe0F3O5LCyq)n8FyuzK6cFPlMsowQlWdlyNUnOdpSGbed64l5GligLBcGyWlEbed6lne4ib8a6Msowc6vO9xahXu(bDf9Krpd0Bux8sxKt5)soDXNpDHKjUk0(lGJyk)o6(2LyDPvc6cNIux85txedUuCgwTK0s1Clne4i1L46cjtCvO9xahXu(D09TlX6sR6sJ6IIXGKS3tNHvljTunhDF7sSU4PUGGwRodRwsAPAosuQjhl1Lg0L46IIXGKS3tNHvljTunhDF7sSU0QU8wDPbDjUU0OUGGwRoO10cyuk3COp6IpF6Ix6ccAT6qGmgjeflo0hDPbqx5TcUGyuUjyWlEbc4vmaIb9LgcCKaEaDf9Krpd0fdUuCgwTK0s1Clne4i1L46sJ6IC)PleLGUWhTOl(8PliO1QdbYyKquS4qF0Lg0L46sJ6IIXGKS3th0AAbeukwC09TlX6cr1Lw0Lg0L46sJ6Ix6IyWLI7uRIs92T0qGJux85tx8sxqqRv3PwfL6Td9rxIRlEPlkgdsYEpDNAvuQ3o0hDPbq3uYXsq3WQLKwQgqaVisaXG(sdbosapGUIEYONb6IbxkUb3FPyWac0WIBPHahPUexxAuxedUuCFdlJgy1GeTWG7VuWULgcCK6sCDPrDbbTwDFdlJgy1GeTWG7VuWo0hDjUU8TbXcL91Lw1f(OfDXNpDXlDbbTwDFdlJgy1GeTWG7VuWo0hDPbDXNpDXlDrm4sX9nSmAGvds0cdU)sb7wAiWrQlna6Msowc6dU)sXGbeOHfGaE9waXG(sdbosapGUIEYONb6IbxkoSWOF)BpJ6wAiWrQlX1Lg1fQDKH1CP4mssStXqtrxAvxisDXNpDHAhzynxkoJKe7UuxiQUWxTOlnOlX1Lg1LVniwOSVU0QU823Qlna6Msowc6yHr)(3EgfiGx8fGyqFPHahjGhqxrpz0ZaDXGlf3urSl5c4iMYVBPHahPUexxumgKK9E6GwtlGGsXIJUVDjwxALGU0cOBk5yjOpve7sUaoIP8deWl(aqmOV0qGJeWdORONm6zGUyWLIBQi2LCbCet53T0qGJuxIRliO1QBQi2LCbCet53H(a6Msowc6qRPfqqPybiGxebaXG(sdbosapGUIEYONb6Ibxko4fB0Jm8nUVfeMSVBPHahjOBk5yjOdVyJEKHVX9TGWK9bc4fFcqmOV0qGJeWdORONm6zGocAT6WcJ(9V9mQd9rxIRl4NbHbXOCtWovKDzaECrsEjNU0QUeJUexxAuxqqRv33WYObwnirlm4(lfSd9rxAa0nLCSe0HhxKKxYfqyqbiGxVjGyqFPHahjGhqxrpz0ZaDe0A1nveB4aRg4OZKagnjh9soh6JUexxAux8sxedUuCFdlJgy1GeTWG7VuWULgcCK6IpF6ccAT6(gwgnWQbjAHb3FPGDOp6sdGUPKJLG(mQefBuZ)ac4fVTaig0xAiWrc4b0v0tg9mqh)mimigLBc2PISldWJlsYl50fIQl8QlX1fV0fsM4Qq7VaoIP87ORshoYqGtxIRlEPlu0CvgLBUPIydhy1ahDMeWOj5OxY5wSrVNNrQlX1Lg1fV0fXGlf33WYObwnirlm4(lfSBPHahPU4ZNUGGwRUVHLrdSAqIwyW9xkyh6JU4ZNUOymij790bTMwabLIfhDF7sSUquDPfDjUU8TbXcL91fIsqxEZy0LgaDtjhlb9zujk2OM)beWlE5fqmOV0qGJeWdORONm6zGUyWLI7Byz0aRgKOfgC)Lc2T0qGJuxIRlnQliO1Q7Byz0aRgKOfgC)Lc2H(Ol(8PlkgdsYEpDqRPfqqPyXr33UeRlevxArxIRlFBqSqzFDHOe0L3mgDXNpDb)mimigLBc2PISldWJlsYl50Lw1Ly0L46ccAT6WcJ(9V9mQd9rxIRlkgdsYEpDqRPfqqPyXr33UeRlTsqx4uK6sd6IpF6Ix6IyWLI7Byz0aRgKOfgC)Lc2T0qGJe0nLCSe0NrLOaoIP8deWlEJbqmOV0qGJeWdORONm6zGEJ6ccAT6WcJ(9V9mQJUVDjwxAvxWtKl5WoSyk)be0ADuDHV1fofPUW36ccAT6WcJ(9V9mQdlMYVU4ZNUGGwRoSWOF)BpJ6qF0L46ccAT6(gwgnWQbjAHb3FPGDOp6sdGUPKJLGo84IK8sUacdkab8IxIeqmOV0qGJeWdORONm6zGUyWLI7uRIs92T0qGJuxIRlIbxkUVHLrdSAqIwyW9xky3sdbosDjUUGGwRUtTkk1Bh6JUexxqqRv33WYObwnirlm4(lfSd9b0nLCSe0Rugwc4iMYpqaV49TaIb9LgcCKaEaDf9Krpd0rqRvNHvljTunh6dOBk5yjOdTMwabLIfGaEXlFbig0xAiWrc4b0v0tg9mqxXyqs27zGotj6sCDXlDrm4sX9nSmAGvds0cdU)sb7wAiWrc6Msowc6qRPfqqPybiGx8YhaIb9LgcCKaEaDf9Krpd0fdUuCNAvuQ3ULgcCK6sCDXlDPrD5BdIfk7Rlevxic8LUexxumgKK9E6GwtlGGsXIJUVDjwxALGU0IU0aOBk5yjOFQvrPEdeWlEjcaIb9LgcCKaEaDf9Krpd0vmgKK9EgOZuIUexxurgLByDHO6IyWLIBQiwGvds0cdU)sb7wAiWrc6Msowc6qRPfqqPybiGx8YNaed6lne4ib8a6k6jJEgOlgCP4o1QOuVDlne4i1L46ccAT6o1QOuVDOp6sCDbbTwDNAvuQ3o6(2LyDPvDbprUKd7WIP8hqqR1r1f(wx4uK6cFRliO1Q7uRIs92Hft5h0nLCSe0Rugwc4iMYpqaV49nbed6lne4ib8a6k6jJEgORymij79mqNPeq3uYXsqhAnTackflab8kMwaed6lne4ib8a6Msowc6vO9xahXu(bDf9Krpd0PRshoYqGd0vERGligLBcg8IxGaEfdVaIb9LgcCKaEaDf9Krpd0XpdcdIr5MGDQi7Ya84IK8soDHO6cV6sCDXlDHIMRYOCZnveB4aRg4OZKagnjh9so3In698msDXNpDbbTwDtfXgoWQbo6mjGrtYrVKZH(a6Msowc6ZOsuSrn)diGxXedGyqFPHahjGhqxrpz0ZaDXGlf3PwfL6TBPHahPUexxqqRv3PwfL6Td9rxIRlnQliO1Q7uRIs92r33UeRlTQlCksDHV1L3Ql8TUGGwRUtTkk1BhwmLFDXNpDbbTwDyHr)(3Eg1H(Ol(8PlEPlIbxkUVHLrdSAqIwyW9xky3sdbosDPbq3uYXsqVszyjGJyk)ab8kgIeqmOV0qGJeWdORONm6zGofnxLr5MBW9xkgmSyJEWdHEOF3In698msDjUU4LUGGwRUb3FPyWWIn6bpe6H(dKdbTwDOp6sCDXlDrm4sXn4(lfdgqGgwClne4i1L46Ix6IyWLIBQi2LCbCet53T0qGJe0nLCSe0Rugwc4iMYpqaVI5TaIbDtjhlbDvKDziYOnhwa9LgcCKaEac4vm8fGyqFPHahjGhqxrpz0ZaDXGlfhwm5ubYdRImk3Clne4ibDtjhlbDSyYPcKhwfzuUbeWRy4daXG(sdbosapGUIEYONb6EPlIbxkUh69nyyW9xkg8WIBPHahPU4ZNU4LU8mXvp6cdU)sXGotjxZb6Msowc6ZOsuyW9xkgeiGxXqeaed6Msowc6WJlsYl5cimOa6lne4ib8aeWRy4taIb9pR5LCGx8c6lne4cFwZl5a8a6Msowc6vO9xahXu(bDL3k4cIr5MGbV4f0v0tg9mqNUkD4idboqFPHahjGhGaEfZBcig0xAiWrc4b0xAiWf(SMxYb4b0v0tg9mq)ZAU)sXrEyXs10fIQl8bOBk5yjOxH2FbCet5h0)SMxYbEXlqaViYwaed6FwZl5aV4f0xAiWf(SMxYb4b0nLCSe0Rugwc4iMYpOV0qGJeWdqacOtUQHcfaXGx8cig0xAiWrcqaDf9Krpd0n(8ONmNLQHfQbd0HzPLQ5wAiWrc6Msowc6iqgJeIIfGaEfdGyqFPHahjGhqxrpz0Za96Xfjb6(2LyDPvDHpArx85txumgKK9E64qnk5zzGvdgFEuMe5O7BxI1Lw1fISfq3uYXsq)Hjhlbc4frcig0nLCSe0F)sYaoAgf0xAiWrc4biGxVfqmOBk5yjOJIx4K9XG(sdbosapab8IVaed6Msowc61JUWG7VumiOV0qGJeWdqaV4daXGUPKJLGowy0FyW9xkge0xAiWrc4biGxebaXGUPKJLGUILQLc1KrgQq7pqFPHahjGhGaEXNaed6Msowc6iqgJmWQbjAHL77nOV0qGJeWdqaVEtaXGUPKJLGohQrjpldSAW4ZJYKiqFPHahjGhGaEXBlaIbDtjhlb9ktHIhzW4ZJEYciZ(G(sdbosapab8IxEbed6Msowc6pO0R69LCbeOHfqFPHahjGhGaEXBmaIbDtjhlbDjAb0eHHMKHkJQgOV0qGJeWdqaV4Libed6Msowc6)9zuVdSAaIQoYajD2hd6lne4ib8aeWlEFlGyq3uYXsqNEppWfUmGFm1a9LgcCKaEac4fV8fGyq3uYXsq)Dgfs2CxgOdZslvd0xAiWrc4biGx8YhaIb9LgcCKaEaDf9Krpd0fJYnXfndkrHhLOlevx4tTOl(8PlIr5M4IMbLOWJs0Lw1LyArx85txQhxKeO7BxI1Lw1fISfq3uYXsqNo75sUqfA)Hbc4fVebaXGUPKJLGE0mQeggVunqFPHahjGhGaEXlFcqmOV0qGJeWdORONm6zGUx6IyWLIZWQLKwQMBPHahPU4ZNUGGwRodRwsAPAo0hDXNpDrXyqs27PZWQLKwQMJUVDjwxiQUWxTa6Msowc6iqgJmurPEdeWlEFtaXG(sdbosapGUIEYONb6EPlIbxkodRwsAPAULgcCK6IpF6ccAT6mSAjPLQ5qFaDtjhlbDKrXJ6)soGaEftlaIb9LgcCKaEaDf9Krpd09sxedUuCgwTK0s1Clne4i1fF(0fe0A1zy1sslvZH(Ol(8PlkgdsYEpDgwTK0s1C09TlX6cr1f(Qfq3uYXsqVE0HazmsGaEfdVaIb9LgcCKaEaDf9Krpd09sxedUuCgwTK0s1Clne4i1fF(0fe0A1zy1sslvZH(Ol(8PlkgdsYEpDgwTK0s1C09TlX6cr1f(Qfq3uYXsq3s1Wc1GbLbHab8kMyaed6lne4ib8a6k6jJEgO7LUigCP4mSAjPLQ5wAiWrQl(8PlEPliO1QZWQLKwQMd9b0nLCSe0rmUaRge6P8Jbc4vmejGyqFPHahjGhq3uYXsq)HEFgL8my4DR5aDf9Krpd09sxqqRv3d9(mk5zWW7wZ5qFaDL3k4cIr5MGbV4fiGxX8waXGUPKJLGEZHFgnimzFqFPHahjGhGaEfdFbig0nLCSe0R2cc1sCffFSe0xAiWrc4biGxXWhaIb9LgcCKaEaDf9Krpd0nLCnxy5(3W6cr1Ly0L46sJ6c(zqyqmk3eStfzxgGhxKKxYPlevxIrx85txWpdcdIr5MGDqRPfqM91fIQlXOlna6Msowc6u0myk5yzaEyb0HhwcP9hOBSbeWRyicaIb9LgcCKaEaDf9Krpd09sxedUuCyHr)Hb3FPyq3sdbosDjUUyk5AUWY9VH1LwjOlXa6Msowc6u0myk5yzaEyb0HhwcP9hOJVKdUGyuUjab8kg(eGyqFPHahjGhqxrpz0ZaDXGlfhwy0FyW9xkg0T0qGJuxIRlMsUMlSC)ByDPvc6smGUPKJLGofndMsowgGhwaD4HLqA)b64fWxYbxqmk3eGaeq)Hof7JycGyWlEbed6lne4ib8a6P9hOB8zCKrnCOYsjWQHh27Jc6Msowc6gFghzudhQSucSA4H9(Oab8kgaXGUPKJLG(dtowc6lne4ib8aeGa6gBaIbV4fqmOV0qGJeWdORONm6zGocAT6MkIDjxahXu(DOpGUPKJLG(mQefBuZ)ac4vmaIbDtjhlbDvKDziYOnhwa9LgcCKaEac4frcig0xAiWrc4b0v0tg9mqxm4sXHfg97F7zu3sdbosq3uYXsqhlm63)2ZOab86TaIb9LgcCKaEaDtjhlb9k0(lGJyk)GUIEYONb6MsUMlqYexfA)fWrmLFDPvDHi1L46IPKR5cl3)gwxALGUWx6IpF6cfnxLr5Md73Be6m)JId1BuVdK7F45wSrVNNrc6kVvWfeJYnbdEXlqaV4laXG(sdbosapGUIEYONb6EPlMsUMlqYexfA)fWrmLFq3uYXsqVcT)c4iMYpqaV4daXG(sdbosapGUIEYONb6IbxkUPIyxYfWrmLF3sdbosDjUU8TbXcL91fIsqx4JwaDtjhlb9PIyxYfWrmLFGaEreaed6lne4ib8a6k6jJEgOlgCP4mSAjPLQ5wAiWrQlX1Lg1fV0LNjoSWO)WG7VumOZuY1C6sd6sCDPrDXlDrm4sXDQvrPE7wAiWrQl(8PlEPliO1Q7uRIs92H(OlX1fV0ffJbjzVNUtTkk1Bh6JU0aOBk5yjOBy1sslvdiGx8jaXG(sdbosapGUIEYONb6Ibxko4fB0Jm8nUVfeMSVBPHahjOBk5yjOdVyJEKHVX9TGWK9bc41Bcig0xAiWrc4b0v0tg9mqNIMRYOCZnveB4aRg4OZKagnjh9so3In698msDjUU4LUGGwRUPIydhy1ahDMeWOj5OxY5qFaDtjhlb9zujkGJyk)ab8I3waed6lne4ib8a6k6jJEgOtrZvzuU5i3Ee6(mAalSCUfB075zK6sCDPrDXlDrm4sX9qVVbddU)sXGhwClne4i1fF(0Lg1fV0LNjoSWO)WG7VumOZuY1C6sCDXlD5zIRE0fgC)LIbDMsUMtxAqxAa0nLCSe0NrLOWG7VumiqaV4LxaXG(sdbosapGUPKJLGo0AAbeukwaDf9Krpd0XpdcdIr5MGDQi7Ya84IK8soDPvD5T6IpF6ccAT6GwtlGrPCZH(Ol(8PlnQlIbxkUVHLrdSAqIwyW9xky3sdbosDjUU4LUGGwRUVHLrdSAqIwyW9xkyh6JUexx(2GyHY(6crjOl8rl6sdGUYBfCbXOCtWGx8ceWlEJbqmOV0qGJeWdORONm6zGUx6IyWLI7Byz0aRgKOfgC)Lc2T0qGJux85txqqRvhwy0V)TNrDOp6IpF6Y3gelu2xxikbDPrDH3wArxiI1L3Ql8TUGFgegeJYnb7ur2Lb4Xfj5LC6sd6IpF6ccAT6(gwgnWQbjAHb3FPGDOp6IpF6c(zqyqmk3eStfzxgGhxKKxYPlevxisq3uYXsqFgvIInQ5Fab8IxIeqmOV0qGJeWdORONm6zGocAT6WcJ(9V9mQJUVDjwxAvxisDHV1fofPUW36ccAT6WcJ(9V9mQdlMYpOBk5yjORISldWJlsYl5ac4fVVfqmOV0qGJeWdORONm6zGocAT6GwtlGrPCZH(OlX1f8ZGWGyuUjyNkYUmapUijVKtxAvxERUexxAux8sxEM4WcJ(ddU)sXGotjxZPlnOlX1fsM4Qq7VaoIP87Kt5)soq3uYXsqhAnTackflab8Ix(cqmOV0qGJeWdORONm6zGUyWLIBW9xkgmGanS4wAiWrQlX1f8ZGWGyuUjyNkYUmapUijVKtxAvx4lDjUU0OU4LU8mXHfg9hgC)LIbDMsUMtxAa0nLCSe0hC)LIbdiqdlab8Ix(aqmOV0qGJeWdORONm6zGUyWLIZWQLKwQMBPHahjOBk5yjOdTMwaz2hiGx8seaed6Msowc6Qi7Ya84IK8soqFPHahjGhGaEXlFcqmOV0qGJeWdOV0qGl8znVKdWdORONm6zGocAT6GwtlGrPCZH(OlX1ffJbjzVNb6mLa6Msowc6qRPfqqPyb0)SMxYbEXlqaV49nbed6FwZl5aV4f0xAiWf(SMxYb4b0nLCSe0Rq7VaoIP8d6kVvWfeJYnbdEXlORONm6zGoDv6WrgcCG(sdbosapab8kMwaed6FwZl5aV4f0xAiWf(SMxYb4b0nLCSe0Rugwc4iMYpOV0qGJeWdqacOJxaFjhCbXOCtaedEXlGyqFPHahjGhq3uYXsqVcT)c4iMYpORONm6zGEJ6cDF7sSU0kbDHtrQlnOlX1Lg1fe0A1bTMwaJs5Md9rx85tx8sxqqRvhcKXiHOyXH(Olna6kVvWfeJYnbdEXlqaVIbqmOV0qGJeWdORONm6zGUyWLIBW9xkgmGanS4wAiWrc6Msowc6dU)sXGbeOHfGaErKaIb9LgcCKaEaDf9Krpd0fdUuCyHr)(3Eg1T0qGJuxIRlnQlFBqSqzFDPvD5TVvxAa0nLCSe0XcJ(9V9mkqaVElGyqFPHahjGhqxrpz0ZaDXGlf3urSl5c4iMYVBPHahjOBk5yjOpve7sUaoIP8deWl(cqmOV0qGJeWdORONm6zGocAT6E)sYahkwCyXu(1Lw1fE5t6IpF6ccAT6GwtlGrPCZH(a6Msowc6qRPfqqPybiGx8bGyqFPHahjGhqxrpz0ZaDe0A1Hfg97F7zuh6dOBk5yjOdpUijVKlGWGcqaVicaIb9LgcCKaEaDf9Krpd0rqRv3urSHdSAGJotcy0KC0l5COpGUPKJLG(mQefBuZ)ac4fFcqmOV0qGJeWdORONm6zGEJ6c(zqyqmk3eStfzxgGhxKKxYPlevx4vxAqxIRlnQlEPlKmXvH2FbCet53rxLoCKHaNU0aOBk5yjOpJkrXg18pGaE9MaIb9LgcCKaEaDf9Krpd0XpdcdIr5MGDQi7Ya84IK8soDPvDjgDjUU8TbXcL91fIsqx4Jw0L46sJ6ccAT6E)sYahkwCyXu(1Lw1LyArx85tx(2GyHY(6cr1L3SfDPbq3uYXsqFgvIc4iMYpqaV4TfaXG(sdbosapGUIEYONb6nQliO1Qdlm63)2ZOo6(2LyDPvDbprUKd7WIP8hqqR1r1f(wx4uK6cFRliO1Qdlm63)2ZOoSyk)6IpF6ccAT6WcJ(9V9mQd9rxIRliO1Q7Byz0aRgKOfgC)Lc2H(Olna6Msowc6WJlsYl5cimOaeWlE5fqmOV0qGJeWdORONm6zGUyWLI7uRIs92T0qGJuxIRlIbxkUVHLrdSAqIwyW9xky3sdbosDjUUGGwRUtTkk1Bh6JUexxqqRv33WYObwnirlm4(lfSd9b0nLCSe0Rugwc4iMYpqaV4ngaXG(sdbosapGUIEYONb6iO1QZWQLKwQMd9b0nLCSe0HwtlGGsXcqaV4Libed6lne4ib8a6k6jJEgORymij79mqNPeDjUU4LUigCP4(gwgnWQbjAHb3FPGDlne4ibDtjhlbDO10ciOuSaeWlEFlGyqFPHahjGhqxrpz0ZaDXGlf3PwfL6TBPHahPUexx8sxAux(2GyHY(6cr1fIaFPlX1ffJbjzVNoO10ciOuS4O7BxI1LwjOlTOlna6Msowc6NAvuQ3ab8Ix(cqmOV0qGJeWdORONm6zGUIXGKS3ZaDMs0L46IkYOCdRlevxedUuCtfXcSAqIwyW9xky3sdbosq3uYXsqhAnTackflab8Ix(aqmOV0qGJeWdORONm6zGUyWLI7uRIs92T0qGJuxIRliO1Q7uRIs92H(a6Msowc6vkdlbCet5hiGx8seaed6Msowc6Qi7YqKrBoSa6lne4ib8aeWlE5taIb9LgcCKaEaDf9Krpd0fdUuCyXKtfipSkYOCZT0qGJe0nLCSe0XIjNkqEyvKr5gqaV49nbed6lne4ib8a6k6jJEgO7LUigCP4EO33GHb3FPyWdlULgcCK6IpF6IyWLI7HEFdggC)LIbpS4wAiWrQlX1Lg1fV0LNjoSWO)WG7VumOZuY1C6sdGUPKJLG(mQefgC)LIbbc4vmTaig0nLCSe0HhxKKxYfqyqb0xAiWrc4biGxXWlGyq)ZAEjh4fVG(sdbUWN18soapGUPKJLGEfA)fWrmLFqx5TcUGyuUjyWlEbDf9Krpd0PRshoYqGd0xAiWrc4biGxXedGyqFPHahjGhqFPHax4ZAEjhGhqxrpz0Za9pR5(lfh5HflvtxiQUWhGUPKJLGEfA)fWrmLFq)ZAEjh4fVab8kgIeqmO)znVKd8IxqFPHax4ZAEjhGhq3uYXsqVszyjGJyk)G(sdbosapabiab0nujIrb9(9rHMCSKic1Qcqacaa]] )

end
