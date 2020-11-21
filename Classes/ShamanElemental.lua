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

    spec:RegisterPack( "Elemental", 20201121, [[dC0ezbqibYJKcPnjs9jvPq1OejDkrIvHkPELaAwOsDlvPuTlQ8lbyysjogQOLjf8mujAAOs4Aie2gcrFtvkzCOsIZPkfToPqeZtkP7HG9Hq6GsHOwiQWdvLsXeLcrQlkfcFukejNuvkyLsPMPQui1nvLsPDQk5NQsHYsvLcjpvQMkc1vvLcr7f4Vu1Gf6WuwmepMKjJOlRSzr9zu1Of0Pv51IOzd62QQDl53OmCvXXLc1Yr65qnDIRdPTlf9DvPA8QsHW5fOwpQK08fH9tQbCcig0jnzGxn0sdTWjNnWPJtISfUKiElqxc(zG(JPsA8d0l7pqVra3FLyqq)XcgYmsaXGoMHsvd0df5b3ijGa4pjefXPy)aW3hfAYXkf1Ysa47Rca0rqpO8gkacOtAYaVAOLgAHtoBGthNezlCjrWfGo(zkWRgiYga9WJKCfab0jhwb6nQo2iG7VsmOo2dTVv62nQo(I1CFKr1Xg4KBDSHwAOfDBD7gvhFBcTIF4gj62nQo(21XgzsYrQJiMkj6Jo2iW4vQPJgYbpjyNUDJQJVDD8nukg9Hrnz6iEICfp2HftL0JGMZJQJzgvhFdQLrPbZTo2fg9NC7zuhO)qz5doqVr1XgbC)vIb1XEO9Ts3Ur1XxSM7JmQo2aNCRJn0sdTOBRB3O64BtOv8d3ir3Ur1X3Uo2itsosDeXujrF0XgbgVsnD0qo4jb70TBuD8TRJVHsXOpmQjthXtKR4XoSyQKEe0CEuDmZO64BqTmknyU1XUWO)KBpJ60T1TnLCSc7EOtX(iMqafp)j7ZDz)rW4Q4qJAyFMvINL9pS3hv32uYXkS7Hof7JysGec4HjhR0T1TBuDSr8gXuOYi1X1C0G1r5(thLWPJMsyuD8W6O10oOHaNt3Ur1X3gdl6ihqgJeIIfD8BfQbHbRJxwhLWPJnYC1rpz6iXu7eDSrUudludQJVrnmRSsnD8W64dD4vIt32uYXkmbeiJrcrXc3xMGXvh9K5SsnSqnONomRSsn3kdbosD7gvhFd1BxX(iMOJpm5yLoEyD8HU8ORKZGWG1r4vjhPokmDucNo2ifQrjpR0rwwhBK5QJYKqU1r0comwhvSpIj647heQJRi1rCiJkWGD62MsowHdKqapm5yf3xMq(4dfpDF7kCRezljsOymij79YXJAuYZkpl7nU6Omj0r33Uc3kx2IUTUDJQJVHsgLI(i6ilRJkdlyNUTPKJv4ajeW7xr6XHZO62MsowHdKqaO45pzFSUTPKJv4ajeq(OZp4(RedQBBk5yfoqcbGfg97hC)vIb1T1TnLCSchiHauSsTsOMmsFgA)PBBk5yfoqcbGazmspl7LW5xTFW62MsowHdKqa8OgL8SYZYEJRoktc1TnLCSchiHaYmfkEKEJRo6jZJm7RBBk5yfoqcb8GsVCWxX7rGgw0TnLCSchiHaKW5rlegAr6ZmQA62MsowHdKqa)9z0G9SShIQospjD2hRBBk5yfoqcbqVNh48x5XpMA62MsowHdKqaVZOqYM7kpDywzLA62MsowHdKqa0zpxX7Zq7pm3xMGyu(jUWzqj0)OeIYvAjrcXO8tCHZGsO)rjT2qljsKp(qXt33Uc3kx2IUDJQJVHshvgE64BqhZmkpt0rm7pj8kENUTPKJv4ajeq4mQ4hgVsnDBDBtjhRWbsiaeiJr6ZO0G5(Yecsm4kXzy1ksRuZTYqGJmrce0C2zy1ksRuZH(KiHIXGKS3lNHvRiTsnhDF7kmrjIw0TnLCSchiHaqgfpAYR45(Yecsm4kXzy1ksRuZTYqGJmrce0C2zy1ksRuZH(OBBk5yfoqcbKp6qGmgj3xMqqIbxjodRwrALAUvgcCKjsGGMZodRwrALAo0NejumgKK9E5mSAfPvQ5O7BxHjkr0IUTPKJv4ajeGvQHfQb9kdc5(Yecsm4kXzy1ksRuZTYqGJmrce0C2zy1ksRuZH(KiHIXGKS3lNHvRiTsnhDF7kmrjIw0TnLCSchiHaqmEpl7f6PsI5(Yecsm4kXzy1ksRuZTYqGJmrIGqqZzNHvRiTsnh6JUTUTPKJv4ajeWd9(mk5zq)7wZXTkyfCEXO8tWe4K7ltiie0C29qVpJsEg0)U1Co0hDBtjhRWbsiGMd)mQxyY(62MsowHdKqazBEHAfoJIpwPBRBBk5yfoqcbqrlVPKJvE4HfUl7pcgBCFzcMsUMZVA)ByI2q6uXpdc9Ir5NGDQq7kp84dL6kEI2qIe4NbHEXO8tWoO108iZ(eTHu0TnLCSchiHaOOL3uYXkp8Wc3L9hb8v8W5fJYpH7ltiiXGRehwy0VFW9xjg0TYqGJmTPKR58R2)gUvcnOBBk5yfoqcbqrlVPKJvE4HfUl7pc45XxXdNxmk)eUVmbXGRehwy0VFW9xjg0TYqGJmTPKR58R2)gUvcnOBRBBk5yf2zSrygvcBmQLCCFzciO5SBQq2v8ECitL0H(OBBk5yf2zSfiHauH2v(qJ2Cyr32uYXkSZylqcbGfg9NC7zuUVmbXGRehwy0FYTNrDRme4i1TnLCSc7m2cKqazO9NhhYuj5wfScoVyu(jycCY9LjqxMoCOHaxAtjxZ5jzIldT)84qMkzRCzAtjxZ5xT)nCReicDBtjhRWoJTajeqgA)5XHmvsUVmHGmLCnNNKjUm0(ZJdzQK62MsowHDgBbsiGPczxX7XHmvsUVmbXGRe3uHSR494qMkPBLHahz6VniwOSprjqKTOBBk5yf2zSfiHamSAfPvQX9LjigCL4mSAfPvQ5wziWrMo1GEM4WcJ(9dU)kXGotjxZLs6udsm4kXDQLrPb7wziWrMirqiO5S7ulJsd2H(KoifJbjzVxUtTmknyh6tk62MsowHDgBbsia41y0J0)n(V5fMSp3xMGyWvIdEng9i9FJ)BEHj77wziWrQBBk5yf2zSfiHaMrLqpoKPsY9LjqrRLzu(5MkKnSNL980zIhJwKJEfVBng9EEgz6GqqZz3uHSH9SSNNot8y0IC0R4DOp62MsowHDgBbsiGzuj0p4(RedY9LjqrRLzu(5i3Ee6(mQhlSAU1y075zKPtniXGRe3d9(g0p4(RedEyXTYqGJmrIud6zIdlm63p4(Red6mLCnx6GEM4YhD(b3FLyqNPKR5sjfDBtjhRWoJTajea0AAEeukw4wfScoVyu(jycCY9LjGFge6fJYpb7uH2vE4Xhk1v8TYfjsGGMZoO108yuk)COpjsKQyWvI7Byzupl7LW5hC)vc2TYqGJmDqiO5S7Byzupl7LW5hC)vc2H(K(BdIfk7tucezlPOB3O6iX0G1rHPJ82F6yJWOsyJrTKthF)KqD8T1WYO6ilRJs40XgbC)vcwhrqZzD89Wv6y(4dLR41rUuhfJYpb70XgPz1BCrhznhvzp64BRniwOSFq62MsowHDgBbsiGzujSXOwYX9LjeKyWvI7Byzupl7LW5hC)vc2TYqGJmrce0C2Hfg9NC7zuh6tIeFBqSqzFIsivoBPL3oxW14NbHEXO8tWovODLhE8HsDfFkjsGGMZUVHLr9SSxcNFW9xjyh6tIe4NbHEXO8tWovODLhE8HsDfpr5sD7gvhFBTKthXO0PJbZq1rsw9gx0ridpD00XUWO)KBpJQJiO5St32uYXkSZylqcbOcTR8WJpuQR45(YeqqZzhwy0FYTNrD09TRWTYLCnVIKRrqZzhwy0FYTNrDyXuj1TBuD8nwbdwhvgw0X3OTMMoYbkfl6iR0rjKUPJIr5NG1XlRJNOJhwhTshVclwj6OvK6yxy0Vo2iG7VsmOoEyD81BmI1rtjxZ50TnLCSc7m2cKqaqRP5rqPyH7ltabnNDqRP5XOu(5qFsJFge6fJYpb7uH2vE4Xhk1v8TYfPtnONjoSWOF)G7VsmOZuY1CPKMKjUm0(ZJdzQKo5ujVIx3Ur1X3iXthBeW9xjguh5aAyrhnE7kSOJOp6OW0rUuhfJYpbRJgwhHSIxhnSo2fg9RJnc4(RedQJhwhlMOJMsUMZPBBk5yf2zSfiHagC)vIb9iqdlCFzcIbxjUb3FLyqpc0WIBLHahzA8ZGqVyu(jyNk0UYdp(qPUIVvIiDQb9mXHfg97hC)vIbDMsUMlfDBtjhRWoJTajeGk0UYdp(qPUIx32uYXkSZylqcbaTMMhbLIfU)SMxXtGtUVmbe0C2bTMMhJs5Nd9jTIXGKS3lpDMs0TnLCSc7m2cKqazO9NhhYuj5(ZAEfpbo5wfScoVyu(jycCY9LjqxMoCOHaNUTPKJvyNXwGecitzyXJdzQKC)znVINaN6262MsowHD45XxXdNxmk)eczO9NhhYuj5wfScoVyu(jycCY9LjKkDF7kCRe4vKPKove0C2bTMMhJs5Nd9jrIGqqZzhcKXiHOyXH(KIUTPKJvyhEE8v8W5fJYpjqcbm4(Red6rGgw4(YeedUsCdU)kXGEeOHf3kdbosDBtjhRWo884R4HZlgLFsGecalm6p52ZOCFzcIbxjoSWO)KBpJ6wziWrMo1VniwOSFRCbxKIUTPKJvyhEE8v8W5fJYpjqcbmvi7kEpoKPsY9LjigCL4MkKDfVhhYujDRme4i1TnLCSc7WZJVIhoVyu(jbsiaO108iOuSW9LjGGMZU3VI0ZJIfhwmvYw5KRKibcAo7GwtZJrP8ZH(OBBk5yf2HNhFfpCEXO8tcKqaWJpuQR49imOW9LjGGMZoSWO)KBpJ6qF0TnLCSc7WZJVIhoVyu(jbsiGzujSXOwYX9LjGGMZUPczd7zzppDM4XOf5OxX7qF0TnLCSc7WZJVIhoVyu(jbsiGzujSXOwYX9LjKk(zqOxmk)eStfAx5HhFOuxXtuotjDQbrYexgA)5XHmvshDz6WHgcCPOBBk5yf2HNhFfpCEXO8tcKqaZOsOhhYuj5(YeWpdc9Ir5NGDQq7kp84dL6k(wBi93gelu2NOeiYwsNkcAo7E)ksppkwCyXujBTHwsK4BdIfk7t03SLu0TnLCSc7WZJVIhoVyu(jbsia4Xhk1v8Eegu4(YesfbnNDyHr)j3Eg1r33Uc3kEICfp2HftL0JGMZJY18ksUgbnNDyHr)j3Eg1HftLmrce0C2Hfg9NC7zuh6tAe0C29nSmQNL9s48dU)kb7qFsr32uYXkSdpp(kE48Ir5NeiHaYugw84qMkj3xMGyWvI7ulJsd2TYqGJmTyWvI7Byzupl7LW5hC)vc2TYqGJmncAo7o1YO0GDOpPrqZz33WYOEw2lHZp4(ReSd9r32uYXkSdpp(kE48Ir5NeiHaGwtZJGsXc3xMacAo7mSAfPvQ5qF0TnLCSc7WZJVIhoVyu(jbsiaO108iOuSW9LjOymij79YtNPK0bjgCL4(gwg1ZYEjC(b3FLGDRme4i1TnLCSc7WZJVIhoVyu(jbsiGtTmknyUVmbXGRe3PwgLgSBLHahz6Gs9BdIfk7t03IisRymij79YbTMMhbLIfhDF7kCReAjfDBtjhRWo884R4HZlgLFsGecaAnnpckflCFzckgdsYEV80zkjTk0O8dtuXGRe3uHmpl7LW5hC)vc2TYqGJu32uYXkSdpp(kE48Ir5NeiHaYugw84qMkj3xMGyWvI7ulJsd2TYqGJmncAo7o1YO0GDOp62MsowHD45XxXdNxmk)KajeGk0UYhA0Mdl62MsowHD45XxXdNxmk)Kajeawm5uEYdRcnk)4(YeedUsCyXKt5jpSk0O8ZTYqGJu32uYXkSdpp(kE48Ir5NeiHaMrLq)G7Vsmi3xMqqIbxjUh69nOFW9xjg8WIBLHahzIeIbxjUh69nOFW9xjg8WIBLHahz6ud6zIdlm63p4(Red6mLCnxk62MsowHD45XxXdNxmk)Kajea84dL6kEpcdk62MsowHD45XxXdNxmk)KajeqgA)5XHmvsU)SMxXtGtUvbRGZlgLFcMaNCFzc0LPdhAiWPBBk5yf2HNhFfpCEXO8tcKqazO9NhhYuj5(ZAEfpbo5(Ye(SM7VsCKhwSsnIsK62MsowHD45XxXdNxmk)KajeqMYWIhhYuj5(ZAEfpbo1T1TnLCSc7WxXdNxmk)eczO9NhhYuj5wfScoVyu(jycCY9LjKAqYPsEfFIeKmXLH2FECitL0r33Uc3kbEfzIeIbxjodRwrALAUvgcCKPjzIldT)84qMkPJUVDfU1uvmgKK9E5mSAfPvQ5O7BxHdebnNDgwTI0k1CKOutowLsAfJbjzVxodRwrALAo6(2v4w5IusNkcAo7GwtZJrP8ZH(KirqiO5SdbYyKquS4qFsr32uYXkSdFfpCEXO8tcKqagwTI0k14(YeedUsCgwTI0k1CRme4itNQC)rucezljsGGMZoeiJrcrXId9jL0PQymij79YbTMMhbLIfhDF7kmrBjL0PgKyWvI7ulJsd2TYqGJmrIGqqZz3PwgLgSd9jDqkgdsYEVCNAzuAWo0Nu0TnLCSc7WxXdNxmk)KajeWG7VsmOhbAyH7ltqm4kXn4(Red6rGgwCRme4itNQyWvI7Byzupl7LW5hC)vc2TYqGJmDQiO5S7Byzupl7LW5hC)vc2H(K(BdIfk73kr2sIebHGMZUVHLr9SSxcNFW9xjyh6tkjseKyWvI7Byzupl7LW5hC)vc2TYqGJmfDBtjhRWo8v8W5fJYpjqcbGfg9NC7zuUVmbXGRehwy0FYTNrDRme4itNk1os)AUsCgjj2PyOL0kxMib1os)AUsCgjj2DfrjIwsjDQFBqSqz)w5cUifDBtjhRWo8v8W5fJYpjqcbmvi7kEpoKPsY9LjigCL4MkKDfVhhYujDRme4itRymij79YbTMMhbLIfhDF7kCReAr32uYXkSdFfpCEXO8tcKqaqRP5rqPyH7ltqm4kXnvi7kEpoKPs6wziWrMgbnNDtfYUI3JdzQKo0hDBtjhRWo8v8W5fJYpjqcbaVgJEK(VX)nVWK95(YeedUsCWRXOhP)B8FZlmzF3kdbosDBtjhRWo8v8W5fJYpjqcbap(qPUI3JWGc3xMacAo7WcJ(tU9mQd9jn(zqOxmk)eStfAx5HhFOuxX3AdPtfbnNDFdlJ6zzVeo)G7VsWo0Nu0TnLCSc7WxXdNxmk)KajeWmQe2yul54(YeqqZz3uHSH9SSNNot8y0IC0R4DOpPtniXGRe33WYOEw2lHZp4(ReSBLHahzIeiO5S7Byzupl7LW5hC)vc2H(KIUTPKJvyh(kE48Ir5NeiHaMrLWgJAjh3xMqQ4NbHEXO8tWovODLhE8HsDfpr5mL0PgejtCzO9NhhYujD0LPdhAiWLs6udsm4kX9nSmQNL9s48dU)kb7wziWrMibcAo7(gwg1ZYEjC(b3FLGDOpjsOymij79YbTMMhbLIfhDF7kmrBj93gelu2NOeEZgsr32uYXkSdFfpCEXO8tcKqaZOsOhhYuj5(YeedUsCFdlJ6zzVeo)G7VsWUvgcCKPtfbnNDFdlJ6zzVeo)G7VsWo0NejumgKK9E5GwtZJGsXIJUVDfMOTK(BdIfk7tucVzdjsGFge6fJYpb7uH2vE4Xhk1v8T2qAe0C2Hfg9NC7zuh6tAfJbjzVxoO108iOuS4O7BxHBLaVImLejcsm4kX9nSmQNL9s48dU)kb7wziWrQBBk5yf2HVIhoVyu(jbsia4Xhk1v8Eegu4(YesfbnNDyHr)j3Eg1r33Uc3kEICfp2HftL0JGMZJY18ksUgbnNDyHr)j3Eg1HftLmrce0C2Hfg9NC7zuh6tAe0C29nSmQNL9s48dU)kb7qFsr32uYXkSdFfpCEXO8tcKqazkdlECitLK7ltqm4kXDQLrPb7wziWrMwm4kX9nSmQNL9s48dU)kb7wziWrMgbnNDNAzuAWo0N0iO5S7Byzupl7LW5hC)vc2H(OBBk5yf2HVIhoVyu(jbsiaO108iOuSW9LjGGMZodRwrALAo0hDBtjhRWo8v8W5fJYpjqcbaTMMhbLIfUVmbfJbjzVxE6mLKoiXGRe33WYOEw2lHZp4(ReSBLHahPUTPKJvyh(kE48Ir5NeiHao1YO0G5(YeedUsCNAzuAWUvgcCKPdk1VniwOSprFlIiTIXGKS3lh0AAEeukwC09TRWTsOLu0TnLCSc7WxXdNxmk)Kajea0AAEeukw4(YeumgKK9E5PZusAvOr5hMOIbxjUPczEw2lHZp4(ReSBLHahPUTPKJvyh(kE48Ir5NeiHaYugw84qMkj3xMGyWvI7ulJsd2TYqGJmncAo7o1YO0GDOpPrqZz3PwgLgSJUVDfUv8e5kESdlMkPhbnNhLR5vKCncAo7o1YO0GDyXuj1TnLCSc7WxXdNxmk)Kajea0AAEeukw4(YeumgKK9E5PZuIUTPKJvyh(kE48Ir5NeiHaYq7ppoKPsYTkyfCEXO8tWe4K7ltGUmD4qdboDBtjhRWo8v8W5fJYpjqcbmJkHng1soUVmb8ZGqVyu(jyNk0UYdp(qPUINOCMoikATmJYp3uHSH9SSNNot8y0IC0R4DRXO3ZZitKive0C2nviBypl75PZepgTih9kEh6tAe0C29nSmQNL9s48dU)kb7qFsr32uYXkSdFfpCEXO8tcKqazkdlECitLK7ltqm4kXDQLrPb7wziWrMgbnNDNAzuAWo0N0PIGMZUtTmknyhDF7kCR8ksUMl4Ae0C2DQLrPb7WIPsMibcAo7WcJ(tU9mQd9jrIGedUsCFdlJ6zzVeo)G7VsWUvgcCKPOBBk5yf2HVIhoVyu(jbsiGmLHfpoKPsY9LjqrRLzu(5gC)vIb9RXOh8qOh63TgJEppJmDqiO5SBW9xjg0VgJEWdHEOFp5qqZzh6t6GedUsCdU)kXGEeOHf3kdboY0bjgCL4MkKDfVhhYujDRme4i1TnLCSc7WxXdNxmk)KajeGk0UYhA0Mdl62MsowHD4R4HZlgLFsGecalMCkp5HvHgLFCFzcIbxjoSyYP8KhwfAu(5wziWrQBBk5yf2HVIhoVyu(jbsiGzuj0p4(RedY9LjeKyWvI7HEFd6hC)vIbpS4wziWrMirqptC5Jo)G7VsmOZuY1C62MsowHD4R4HZlgLFsGecaE8HsDfVhHbfDBtjhRWo8v8W5fJYpjqcbKH2FECitLK7pR5v8e4KBvWk48Ir5NGjWj3xMaDz6WHgcC62MsowHD4R4HZlgLFsGecidT)84qMkj3FwZR4jWj3xMWN1C)vIJ8WIvQruIu32uYXkSdFfpCEXO8tcKqazkdlECitLK7pR5v8e4e0Bok(yf4vdT0qlCYzdT44e0F3O1v8yq)n8FyuzK6irOJMsowPJWdlyNUnOBOsiJc697Jcn5y1Bd1YcOdpSGbed64R4HZlgLFcGyWlobed6Rme4ibCa6Msowb6zO9NhhYujbDf9Krpd0tvhdshLtL8kEDmrcDKKjUm0(ZJdzQKo6(2vyDSvc6iVIuhtKqhfdUsCgwTI0k1CRme4i1X06ijtCzO9NhhYujD09TRW6yR6yQ6OIXGKS3lNHvRiTsnhDF7kSogOoIGMZodRwrALAosuQjhR0Xu0X06OIXGKS3lNHvRiTsnhDF7kSo2QoYf6yk6yADmvDebnNDqRP5XOu(5qF0Xej0XG0re0C2HazmsikwCOp6ykGUkyfCEXO8tWGxCceWRgaed6Rme4ibCa6k6jJEgOlgCL4mSAfPvQ5wziWrQJP1Xu1r5(thjkbDKiBrhtKqhrqZzhcKXiHOyXH(OJPOJP1Xu1rfJbjzVxoO108iOuS4O7BxH1rIQJTOJPOJP1Xu1XG0rXGRe3PwgLgSBLHahPoMiHogKoIGMZUtTmknyh6JoMwhdshvmgKK9E5o1YO0GDOp6ykGUPKJvGUHvRiTsnGaEXLaIb9vgcCKaoaDf9Krpd0fdUsCdU)kXGEeOHf3kdbosDmToMQokgCL4(gwg1ZYEjC(b3FLGDRme4i1X06yQ6icAo7(gwg1ZYEjC(b3FLGDOp6yAD8BdIfk7RJTQJezl6yIe6yq6icAo7(gwg1ZYEjC(b3FLGDOp6yk6yIe6yq6OyWvI7Byzupl7LW5hC)vc2TYqGJuhtb0nLCSc0hC)vIb9iqdlab8Ilaed6Rme4ibCa6k6jJEgOlgCL4WcJ(tU9mQBLHahPoMwhtvhP2r6xZvIZijXofdTeDSvDKl1Xej0rQDK(1CL4mssS7kDKO6ir0IoMIoMwhtvh)2GyHY(6yR6ixWf6ykGUPKJvGowy0FYTNrbc4fraig0xziWrc4a0v0tg9mqxm4kXnvi7kEpoKPs6wziWrQJP1rfJbjzVxoO108iOuS4O7BxH1XwjOJTa6Msowb6tfYUI3JdzQKab8Iibed6Rme4ibCa6k6jJEgOlgCL4MkKDfVhhYujDRme4i1X06icAo7MkKDfVhhYujDOpGUPKJvGo0AAEeukwac41Bbig0xziWrc4a0v0tg9mqxm4kXbVgJEK(VX)nVWK9DRme4ibDtjhRaD41y0J0)n(V5fMSpqaV4kaIb9vgcCKaoaDf9Krpd0rqZzhwy0FYTNrDOp6yADe)mi0lgLFc2PcTR8WJpuQR41Xw1Xg0X06yQ6icAo7(gwg1ZYEjC(b3FLGDOp6ykGUPKJvGo84dL6kEpcdkab86nbed6Rme4ibCa6k6jJEgOJGMZUPczd7zzppDM4XOf5OxX7qF0X06yQ6yq6OyWvI7Byzupl7LW5hC)vc2TYqGJuhtKqhrqZz33WYOEw2lHZp4(ReSd9rhtb0nLCSc0NrLWgJAjhqaV4SfaXG(kdbosahGUIEYONb6PQJ4NbHEXO8tWovODLhE8HsDfVosuDKtDmfDmToMQogKosYexgA)5XHmvshDz6WHgcC6yk6yADmvDmiDum4kX9nSmQNL9s48dU)kb7wziWrQJjsOJiO5S7Byzupl7LW5hC)vc2H(OJjsOJkgdsYEVCqRP5rqPyXr33UcRJevhBrhtRJFBqSqzFDKOe0X3SbDmfq3uYXkqFgvcBmQLCab8Itobed6Rme4ibCa6k6jJEgOlgCL4(gwg1ZYEjC(b3FLGDRme4i1X06yQ6icAo7(gwg1ZYEjC(b3FLGDOp6yIe6OIXGKS3lh0AAEeukwC09TRW6ir1Xw0X0643gelu2xhjkbD8nBqhtKqhXpdc9Ir5NGDQq7kp84dL6kEDSvDSbDmToIGMZoSWO)KBpJ6qF0X06OIXGKS3lh0AAEeukwC09TRW6yRe0rEfPoMIoMiHogKokgCL4(gwg1ZYEjC(b3FLGDRme4ibDtjhRa9zuj0JdzQKab8IZgaed6Rme4ibCa6k6jJEgONQoIGMZoSWO)KBpJ6O7BxH1Xw1r8e5kESdlMkPhbnNhvh5ADKxrQJCToIGMZoSWO)KBpJ6WIPsQJjsOJiO5Sdlm6p52ZOo0hDmToIGMZUVHLr9SSxcNFW9xjyh6JoMcOBk5yfOdp(qPUI3JWGcqaV4Klbed6Rme4ibCa6k6jJEgOlgCL4o1YO0GDRme4i1X06OyWvI7Byzupl7LW5hC)vc2TYqGJuhtRJiO5S7ulJsd2H(OJP1re0C29nSmQNL9s48dU)kb7qFaDtjhRa9mLHfpoKPsceWlo5caXG(kdbosahGUIEYONb6iO5SZWQvKwPMd9b0nLCSc0HwtZJGsXcqaV4Kiaed6Rme4ibCa6k6jJEgORymij79YtNPeDmTogKokgCL4(gwg1ZYEjC(b3FLGDRme4ibDtjhRaDO108iOuSaeWlojsaXG(kdbosahGUIEYONb6IbxjUtTmkny3kdbosDmTogKoMQo(TbXcL91rIQJVfrOJP1rfJbjzVxoO108iOuS4O7BxH1XwjOJTOJPa6Msowb6NAzuAWab8IZ3cqmOVYqGJeWbORONm6zGUIXGKS3lpDMs0X06Ok0O8dRJevhfdUsCtfY8SSxcNFW9xjy3kdbosq3uYXkqhAnnpckflab8ItUcGyqFLHahjGdqxrpz0ZaDXGRe3PwgLgSBLHahPoMwhrqZz3PwgLgSd9rhtRJiO5S7ulJsd2r33UcRJTQJ4jYv8yhwmvspcAopQoY16iVIuh5ADebnNDNAzuAWoSyQKGUPKJvGEMYWIhhYujbc4fNVjGyqFLHahjGdqxrpz0ZaDfJbjzVxE6mLa6Msowb6qRP5rqPybiGxn0cGyqFLHahjGdq3uYXkqpdT)84qMkjORONm6zGoDz6WHgcCGUkyfCEXO8tWGxCceWRg4eqmOVYqGJeWbORONm6zGo(zqOxmk)eStfAx5HhFOuxXRJevh5uhtRJbPJu0AzgLFUPczd7zzppDM4XOf5OxX7wJrVNNrQJjsOJPQJiO5SBQq2WEw2ZtNjEmAro6v8o0hDmToIGMZUVHLr9SSxcNFW9xjyh6JoMcOBk5yfOpJkHng1soGaE1qdaIb9vgcCKaoaDf9Krpd0fdUsCNAzuAWUvgcCK6yADebnNDNAzuAWo0hDmToMQoIGMZUtTmknyhDF7kSo2QoYRi1rUwh5cDKR1re0C2DQLrPb7WIPsQJjsOJiO5Sdlm6p52ZOo0hDmrcDmiDum4kX9nSmQNL9s48dU)kb7wziWrQJPa6Msowb6zkdlECitLeiGxnWLaIb9vgcCKaoaDf9Krpd0PO1Ymk)CdU)kXG(1y0dEi0d97wJrVNNrQJP1XG0re0C2n4(Red6xJrp4Hqp0VNCiO5Sd9rhtRJbPJIbxjUb3FLyqpc0WIBLHahPoMwhdshfdUsCtfYUI3JdzQKUvgcCKGUPKJvGEMYWIhhYujbc4vdCbGyq3uYXkqxfAx5dnAZHfqFLHahjGdGaE1araig0xziWrc4a0v0tg9mqxm4kXHftoLN8WQqJYp3kdbosq3uYXkqhlMCkp5HvHgLFab8QbIeqmOVYqGJeWbORONm6zGEq6OyWvI7HEFd6hC)vIbpS4wziWrQJjsOJbPJptC5Jo)G7VsmOZuY1CGUPKJvG(mQe6hC)vIbbc4vdVfGyq3uYXkqhE8HsDfVhHbfqFLHahjGdGaE1axbqmO)znVIh8ItqFLHaN)ZAEfpGdq3uYXkqpdT)84qMkjORcwbNxmk)em4fNGUIEYONb60LPdhAiWb6Rme4ibCaeWRgEtaXG(kdbosahG(kdbo)N18kEahGUIEYONb6FwZ9xjoYdlwPMosuDKibDtjhRa9m0(ZJdzQKG(N18kEWlobc4fx2cGyq)ZAEfp4fNG(kdbo)N18kEahGUPKJvGEMYWIhhYujb9vgcCKaoacqaDYLnuOaig8ItaXG(kdbosacORONm6zGUXvh9K5SsnSqnONomRSsn3kdbosq3uYXkqhbYyKquSaeWRgaed6Rme4ibCa6k6jJEgONp(qXt33UcRJTQJezl6yIe6OIXGKS3lhpQrjpR8SS34QJYKqhDF7kSo2QoYLTa6Msowb6pm5yfqaV4saXGUPKJvG(7xr6XHZOG(kdbosahab8Ilaed6Msowb6O45pzFmOVYqGJeWbqaVicaXGUPKJvGE(OZp4(Redc6Rme4ibCaeWlIeqmOBk5yfOJfg97hC)vIbb9vgcCKaoac41Bbig0nLCSc0vSsTsOMmsFgA)b6Rme4ibCaeWlUcGyq3uYXkqhbYyKEw2lHZVA)Gb9vgcCKaoac41Bcig0nLCSc05rnk5zLNL9gxDuMec6Rme4ibCaeWloBbqmOBk5yfONzku8i9gxD0tMhz2h0xziWrc4aiGxCYjGyq3uYXkq)bLE5GVI3JanSa6Rme4ibCaeWloBaqmOBk5yfOlHZJwim0I0Nzu1a9vgcCKaoac4fNCjGyq3uYXkq)VpJgSNL9qu1r6jPZ(yqFLHahjGdGaEXjxaig0nLCSc0P3ZdC(R84htnqFLHahjGdGaEXjraig0nLCSc0FNrHKn3vE6WSYk1a9vgcCKaoac4fNejGyqFLHahjGdqxrpz0ZaDXO8tCHZGsO)rj6ir1rUsl6yIe6Oyu(jUWzqj0)OeDSvDSHw0Xej0X8XhkE6(2vyDSvDKlBb0nLCSc0PZEUI3NH2FyGaEX5Bbig0nLCSc0dNrf)W4vQb6Rme4ibCaeWlo5kaIb9vgcCKaoaDf9Krpd0dshfdUsCgwTI0k1CRme4i1Xej0re0C2zy1ksRuZH(OJjsOJkgdsYEVCgwTI0k1C09TRW6ir1rIOfq3uYXkqhbYyK(mknyGaEX5Bcig0xziWrc4a0v0tg9mqpiDum4kXzy1ksRuZTYqGJuhtKqhrqZzNHvRiTsnh6dOBk5yfOJmkE0KxXdeWRgAbqmOVYqGJeWbORONm6zGEq6OyWvIZWQvKwPMBLHahPoMiHoIGMZodRwrALAo0hDmrcDuXyqs27LZWQvKwPMJUVDfwhjQoseTa6Msowb65JoeiJrceWRg4eqmOVYqGJeWbORONm6zGEq6OyWvIZWQvKwPMBLHahPoMiHoIGMZodRwrALAo0hDmrcDuXyqs27LZWQvKwPMJUVDfwhjQoseTa6Msowb6wPgwOg0RmieiGxn0aGyqFLHahjGdqxrpz0Za9G0rXGReNHvRiTsn3kdbosDmrcDmiDebnNDgwTI0k1COpGUPKJvGoIX7zzVqpvsmqaVAGlbed6Rme4ibCa6Msowb6p07ZOKNb9VBnhORONm6zGEq6icAo7EO3Nrjpd6F3Aoh6dORcwbNxmk)em4fNab8QbUaqmOBk5yfO3C4Nr9ct2h0xziWrc4aiGxnqeaIbDtjhRa9SnVqTcNrXhRa9vgcCKaoac4vdejGyqFLHahjGdqxrpz0ZaDtjxZ5xT)nSosuDSbDmToMQoIFge6fJYpb7uH2vE4Xhk1v86ir1Xg0Xej0r8ZGqVyu(jyh0AAEKzFDKO6yd6ykGUPKJvGofT8Msow5HhwaD4HfFz)b6gBab8QH3cqmOVYqGJeWbORONm6zGEq6OyWvIdlm63p4(Red6wziWrQJP1rtjxZ5xT)nSo2kbDSbq3uYXkqNIwEtjhR8WdlGo8WIVS)aD8v8W5fJYpbiGxnWvaed6Rme4ibCa6k6jJEgOlgCL4WcJ(9dU)kXGUvgcCK6yAD0uY1C(v7FdRJTsqhBa0nLCSc0POL3uYXkp8WcOdpS4l7pqhpp(kE48Ir5NaeGa6p0PyFetaedEXjGyqFLHahjGdqVS)aDJRIdnQH9zwjEw2)WEFuq3uYXkq34Q4qJAyFMvINL9pS3hfiGxnaig0nLCSc0FyYXkqFLHahjGdGaeq3ydqm4fNaIb9vgcCKaoaDf9Krpd0rqZz3uHSR494qMkPd9b0nLCSc0NrLWgJAjhqaVAaqmOBk5yfORcTR8HgT5WcOVYqGJeWbqaV4saXG(kdbosahGUIEYONb6IbxjoSWO)KBpJ6wziWrc6Msowb6yHr)j3EgfiGxCbGyqFLHahjGdq3uYXkqpdT)84qMkjORONm6zGoDz6WHgcC6yAD0uY1CEsM4Yq7ppoKPsQJTQJCPoMwhnLCnNF1(3W6yRe0rIa0vbRGZlgLFcg8ItGaEreaIb9vgcCKaoaDf9Krpd0dshnLCnNNKjUm0(ZJdzQKGUPKJvGEgA)5XHmvsGaErKaIb9vgcCKaoaDf9Krpd0fdUsCtfYUI3JdzQKUvgcCK6yAD8BdIfk7RJeLGosKTa6Msowb6tfYUI3JdzQKab86Taed6Rme4ibCa6k6jJEgOlgCL4mSAfPvQ5wziWrQJP1Xu1XG0XNjoSWOF)G7VsmOZuY1C6yk6yADmvDmiDum4kXDQLrPb7wziWrQJjsOJbPJiO5S7ulJsd2H(OJP1XG0rfJbjzVxUtTmknyh6JoMcOBk5yfOBy1ksRudiGxCfaXG(kdbosahGUIEYONb6Ibxjo41y0J0)n(V5fMSVBLHahjOBk5yfOdVgJEK(VX)nVWK9bc41Bcig0xziWrc4a0v0tg9mqNIwlZO8ZnviBypl75PZepgTih9kE3Am698msDmTogKoIGMZUPczd7zzppDM4XOf5OxX7qFaDtjhRa9zuj0JdzQKab8IZwaed6Rme4ibCa6k6jJEgOtrRLzu(5i3Ee6(mQhlSAU1y075zK6yADmvDmiDum4kX9qVVb9dU)kXGhwCRme4i1Xej0Xu1XG0XNjoSWOF)G7VsmOZuY1C6yADmiD8zIlF05hC)vIbDMsUMthtrhtb0nLCSc0NrLq)G7VsmiqaV4KtaXG(kdbosahGUPKJvGo0AAEeukwaDf9Krpd0Xpdc9Ir5NGDQq7kp84dL6kEDSvDKl0Xej0re0C2bTMMhJs5Nd9rhtKqhtvhfdUsCFdlJ6zzVeo)G7VsWUvgcCK6yADmiDebnNDFdlJ6zzVeo)G7VsWo0hDmTo(TbXcL91rIsqhjYw0XuaDvWk48Ir5NGbV4eiGxC2aGyqFLHahjGdqxrpz0Za9G0rXGRe33WYOEw2lHZp4(ReSBLHahPoMiHoIGMZoSWO)KBpJ6qF0Xej0XVniwOSVosuc6yQ6iNT0Io(21rUqh5ADe)mi0lgLFc2PcTR8WJpuQR41Xu0Xej0re0C29nSmQNL9s48dU)kb7qF0Xej0r8ZGqVyu(jyNk0UYdp(qPUIxhjQoYLGUPKJvG(mQe2yul5ac4fNCjGyqFLHahjGdqxrpz0ZaDe0C2Hfg9NC7zuhDF7kSo2QoYL6ixRJ8ksDKR1re0C2Hfg9NC7zuhwmvsq3uYXkqxfAx5HhFOuxXdeWlo5caXG(kdbosahGUIEYONb6iO5SdAnnpgLYph6JoMwhXpdc9Ir5NGDQq7kp84dL6kEDSvDKl0X06yQ6yq64Zehwy0VFW9xjg0zk5AoDmfDmTosYexgA)5XHmvsNCQKxXd6Msowb6qRP5rqPybiGxCseaIb9vgcCKaoaDf9Krpd0fdUsCdU)kXGEeOHf3kdbosDmToIFge6fJYpb7uH2vE4Xhk1v86yR6irOJP1Xu1XG0XNjoSWOF)G7VsmOZuY1C6ykGUPKJvG(G7VsmOhbAybiGxCsKaIbDtjhRaDvODLhE8HsDfpOVYqGJeWbqaV48Taed6Rme4ibCa6Rme48FwZR4bCa6k6jJEgOJGMZoO108yuk)COp6yADuXyqs27LNotjGUPKJvGo0AAEeukwa9pR5v8GxCceWlo5kaIb9pR5v8GxCc6Rme48FwZR4bCa6Msowb6zO9NhhYujbDvWk48Ir5NGbV4e0v0tg9mqNUmD4qdboqFLHahjGdGaEX5Bcig0)SMxXdEXjOVYqGZ)znVIhWbOBk5yfONPmS4XHmvsqFLHahjGdGaeqhpp(kE48Ir5Naig8ItaXG(kdbosahGUPKJvGEgA)5XHmvsqxrpz0Za9u1r6(2vyDSvc6iVIuhtrhtRJPQJiO5SdAnnpgLYph6JoMiHogKoIGMZoeiJrcrXId9rhtb0vbRGZlgLFcg8ItGaE1aGyqFLHahjGdqxrpz0ZaDXGRe3G7VsmOhbAyXTYqGJe0nLCSc0hC)vIb9iqdlab8Ilbed6Rme4ibCa6k6jJEgOlgCL4WcJ(tU9mQBLHahPoMwhtvh)2GyHY(6yR6ixWf6ykGUPKJvGowy0FYTNrbc4fxaig0xziWrc4a0v0tg9mqxm4kXnvi7kEpoKPs6wziWrc6Msowb6tfYUI3JdzQKab8Iiaed6Rme4ibCa6k6jJEgOJGMZU3VI0ZJIfhwmvsDSvDKtUIoMiHoIGMZoO108yuk)COpGUPKJvGo0AAEeukwac4frcig0xziWrc4a0v0tg9mqhbnNDyHr)j3Eg1H(a6Msowb6WJpuQR49imOaeWR3cqmOVYqGJeWbORONm6zGocAo7MkKnSNL980zIhJwKJEfVd9b0nLCSc0NrLWgJAjhqaV4kaIb9vgcCKaoaDf9Krpd0tvhXpdc9Ir5NGDQq7kp84dL6kEDKO6iN6yk6yADmvDmiDKKjUm0(ZJdzQKo6Y0Hdne40XuaDtjhRa9zujSXOwYbeWR3eqmOVYqGJeWbORONm6zGo(zqOxmk)eStfAx5HhFOuxXRJTQJnOJP1XVniwOSVosuc6ir2IoMwhtvhrqZz37xr65rXIdlMkPo2Qo2ql6yIe643gelu2xhjQo(MTOJPa6Msowb6ZOsOhhYujbc4fNTaig0xziWrc4a0v0tg9mqpvDebnNDyHr)j3Eg1r33UcRJTQJ4jYv8yhwmvspcAopQoY16iVIuh5ADebnNDyHr)j3Eg1HftLuhtKqhrqZzhwy0FYTNrDOp6yADebnNDFdlJ6zzVeo)G7VsWo0hDmfq3uYXkqhE8HsDfVhHbfGaEXjNaIb9vgcCKaoaDf9Krpd0fdUsCNAzuAWUvgcCK6yADum4kX9nSmQNL9s48dU)kb7wziWrQJP1re0C2DQLrPb7qF0X06icAo7(gwg1ZYEjC(b3FLGDOpGUPKJvGEMYWIhhYujbc4fNnaig0xziWrc4a0v0tg9mqhbnNDgwTI0k1COpGUPKJvGo0AAEeukwac4fNCjGyqFLHahjGdqxrpz0ZaDfJbjzVxE6mLOJP1XG0rXGRe33WYOEw2lHZp4(ReSBLHahjOBk5yfOdTMMhbLIfGaEXjxaig0xziWrc4a0v0tg9mqxm4kXDQLrPb7wziWrQJP1XG0Xu1XVniwOSVosuD8TicDmToQymij79YbTMMhbLIfhDF7kSo2kbDSfDmfq3uYXkq)ulJsdgiGxCseaIb9vgcCKaoaDf9Krpd0vmgKK9E5PZuIoMwhvHgLFyDKO6OyWvIBQqMNL9s48dU)kb7wziWrc6Msowb6qRP5rqPybiGxCsKaIb9vgcCKaoaDf9Krpd0fdUsCNAzuAWUvgcCK6yADebnNDNAzuAWo0hq3uYXkqptzyXJdzQKab8IZ3cqmOBk5yfORcTR8HgT5WcOVYqGJeWbqaV4KRaig0xziWrc4a0v0tg9mqxm4kXHftoLN8WQqJYp3kdbosq3uYXkqhlMCkp5HvHgLFab8IZ3eqmOVYqGJeWbORONm6zGEq6OyWvI7HEFd6hC)vIbpS4wziWrQJjsOJIbxjUh69nOFW9xjg8WIBLHahPoMwhtvhdshFM4WcJ(9dU)kXGotjxZPJPa6Msowb6ZOsOFW9xjgeiGxn0cGyq3uYXkqhE8HsDfVhHbfqFLHahjGdGaE1aNaIb9pR5v8GxCc6Rme48FwZR4bCa6Msowb6zO9NhhYujbDvWk48Ir5NGbV4e0v0tg9mqNUmD4qdboqFLHahjGdGaE1qdaIb9vgcCKaoa9vgcC(pR5v8aoaDf9Krpd0)SM7VsCKhwSsnDKO6irc6Msowb6zO9NhhYujb9pR5v8GxCceWRg4saXG(N18kEWlob9vgcC(pR5v8aoaDtjhRa9mLHfpoKPsc6Rme4ibCaeGaeGaeaaa]] )

end
