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

    spec:RegisterPack( "Elemental", 20201205, [[duutAbqiQIEKki2Kq5tQGumkLqNsjyvuLuVIQWSqrDlQsc7Iu)cfzyQahdfAzcv9mevmnvqDnHkTnQs03OkHghvj4CiQK1rvsK5PIY9qK9PIQdQcsLfIO8qevQAIiQu5IuLKoPkizLQqZKQKO6MiQuANQi)ufKQEQsnvuWvvbP0Eb9xbdwHdtzXq8ysMmKUS0Mv0NrPrlKtRQxtv1SbUTkTBr)gvdxjDCHkwosphQPtCDe2Us03ru14PkjkNNQuRhrLI5tvz)uziJqgGButk8u8he)bmg)bXvZy8hqoX9WWT49AH7vt53ylCN2TWTxf0BtXaW9Q5nGBOqgGBmNGQkChjYk2RetmX(sebIwXVmH)lbWKNNkQnfMW)vXeCJq8a5qLqe4g1Kcpf)bXFaJXFqC1mg)bKtCzeUXRvbpfVxgpCh9OOnHiWnAXk4(qCdVkO3MIbCJDKDT0D8qCdYDv1lsPUrCz2nI)G4pWD0D8qCdY9rwYwSxj3XdXn8kCJdDOOf1nqmLFIv3WRIXnv1nmKh8I3A3XdXn8kCJdvQ40vo1K6g4kYNSynwmL)acXCwQBm5u34qP6KG6nZUXw40R)21s1W9kLpFqH7dXn8QGEBkgWn2r21s3XdXni3vvViL6gXLz3i(dI)a3r3XdXni3hzjBXELChpe3WRWno0HIwu3aXu(jwDdVkg3uv3WqEWlERDhpe3WRWnouPItx5utQBGRiFYI1yXu(dieZzPUXKtDJdLQtcQ3m7gBHtV(Bxlv7o6oEiUHx1RSQiKI6gDzPE7gYFRBir1nmLWPUXJDdBP9adbuT7OPKNNy9kTk(fXes1OsuOGEBkgG5FsYtXanf9k9VgiuqVnfd8yr30qaf1D8qCJdT46gBHtV(Bxl1nwPvXViM4gejOySBG536ggkk2ni)daUbE1iF6gyop1UJMsEEI1R0Q4xet8GetyHtV(BxlL5FssmqtrJfo96VDTuDtdbu0ylsThn0LnfTHII1korkNro(8rThn0LnfTHII1FEECpyb3rtjppX6vAv8lIjEqIPvU880D0uYZtSELwf)IyIhKyQGEBkgiGamSW8pjjgOPOlO3MIbciadl6MgcOOUJMsEEI1R0Q4xet8GetaBPfqiOyH5FsYtXanfDb92umqabyyr30qaf1D0D8qCJdvkLsjwf3GpDdLHfS2D0uYZtShKyI8FIgWr1OUJMsEEI9Gete4gEPxS7OPKNNypiX08PnuqVnfd4oAk55j2dsmHfo9gkO3MIbChDhnL88e7bjMu8u1uOMu0Wey36oAk55j2dsmHa4C0aFgKOgA2R3UJMsEEI9GetSegf9TmWNbJCtPCjYD0uYZtShKyAYve4IgmYnL(sdi1UUJMsEEI9GetRe0F69NSbeGHf3rtjppXEqIjjQbIeHtKOHjNQQ7OPKNNypiX0Txo17aFgaeQhnGsRDXUJMsEEI9Get0FDf0WNb8QPQ7OPKNNypiXe55ua6Y(zGwmpTuv3rtjppXEqIjAT1pzdtGDlM5FssmkBfDunGefwvY5EHd85tmkBfDunGefwvYzXFGpFZNnsc0ETpXNroh4oEiUXHkDdLHRBCOCJjNYYf3aZVvI(Kv7oAk55j2dsmfvJkHIXnv1D0D0uYZtShKycbW5OHjb1BM)jjpfd0u0gw1e1sv1nneqr95dHyo1gw1e1sv1eR(8P4CakN8P2WQMOwQQM2R9j(84EG7OPKNNypiXesP4s9)jlZ)KKNIbAkAdRAIAPQ6MgcOO(8HqmNAdRAIAPQAIv3rtjppXEqIP5tlcGZrz(NK8umqtrByvtulvv30qaf1NpeI5uByvtulvvtS6ZNIZbOCYNAdRAIAPQAAV2N4ZJ7bUJMsEEI9GetwQkwOgiOmaG5FsYtXanfTHvnrTuvDtdbuuF(qiMtTHvnrTuvnXQpFkohGYjFQnSQjQLQQP9AFIppUh4oAk55j2dsmHySb(mi0x5hZ8pj5PyGMI2WQMOwQQUPHakQpFEIqmNAdRAIAPQAIv3r3rtjppXEqIPv6F5u03abYBllZkVvGgeJYwbtIrM)jjpriMt9k9VCk6BGa5TLvtS6oAk55j2dsmTS41sdcx61D0uYZtShKyAAniulXtc8Zt3r3rtjppXEqIjkrgmL88maESWCA3sY4L5FsYuYVSHM9(fFE8XweVwaiigLTcwRISpdGNnsYpzppEF(WRfacIrzRG1aBPfqQDpp(fChnL88e7bjMOezWuYZZa4XcZPDlj8NSGgeJYwH5FsYtXanfnw40BOGEBkgq30qafnMPKFzdn79l(msX7oAk55j2dsmrjYGPKNNbWJfMt7ws4gWFYcAqmkBfM)jjXanfnw40BOGEBkgq30qafnMPKFzdn79l(msX7o6oAk55jwB8sQgvIIdH5Vm)tsieZPUQi(NSbCex5xtS6oAk55jwB86bjMur2NHiJUSyXD0uYZtS241dsmHfo96VDTuM)jjXanfnw40R)21s1nneqrDhnL88eRnE9GettGDBahXv(zw5Tc0Gyu2kysmY8pjzk5x2akx0tGDBahXv(pJCIzk5x2qZE)IpJuC95JsKDYPSvJ97ncTM)sXH5xQ3b0EFC1noe)6ArDhnL88eRnE9GettGDBahXv(z(NK80uYVSbuUONa72aoIR87oAk55jwB86bjMQkI)jBahXv(z(NKed0u0vfX)KnGJ4k)6MgcOOXUwbyHYVNtYlpWD0uYZtS241dsmzyvtulvL5FssmqtrByvtulvv30qafn2IEUwrJfo9gkO3MIb0Ms(LDHyl6PyGMI(vDsq9w30qaf1NppriMt9R6KG6TMynMNkohGYjFQFvNeuV1eRl4oAk55jwB86bjMaFCiE0W1yVwq4sVm)tsIbAkAWhhIhnCn2RfeU0RUPHakQ7OPKNNyTXRhKyQgvIc4iUYpZ)KeLi7KtzRUQiEXb(mWsRjbmrIw6NS6ghIFDTOX8eHyo1vfXloWNbwAnjGjs0s)KvtS6oAk55jwB86bjMQrLOqb92umaZ)KeLi7KtzRgTDvO9YPbSWZQBCi(11IgBrpfd0u0R0)AGqb92umWJfDtdbuuF(w0Z1kASWP3qb92umG2uYVSX8CTIE(0gkO3MIb0Ms(LDHfChnL88eRnE9GetaBPfqiOyHzL3kqdIrzRGjXiZ)KeETaqqmkBfSwfzFgapBKKFYE2H95dHyo1aBPfWeu2Qjw95BrXanf91WsPb(mirnuqVnfSUPHakAmpriMt91WsPb(mirnuqVnfSMyn21kalu(9CsE5bl4oEiUbduVDdH7gS2TUHx1OsuCim)1ni)lrUb5wdlL6g8PBir1n8QGEBky3aHyoDdYh10nMpBK8jRBqoUHyu2kyTBqUJNhAe3GVSuLT6gKBTcWcLF90D0uYZtS241dsmvJkrXHW8xM)jjpfd0u0xdlLg4ZGe1qb92uW6MgcOO(8HqmNASWPx)TRLQjw957AfGfk)EoPfz8Gd8koSxJxlaeeJYwbRvr2NbWZgj5NSl4ZhcXCQVgwknWNbjQHc6TPG1eR(8HxlaeeJYwbRvr2NbWZgj5NSNtoUJhIBqU18x3atqRB4nNWnq55HgXnaCCDdZn2cNE93UwQBGqmNA3rtjppXAJxpiXKkY(maE2ij)KL5FscHyo1yHtV(Bxlvt71(eFg541SkuVgHyo1yHtV(BxlvJft53D8qCJd9jWB3qzyXn8k3wAUbzeuS4g80nKiARBigLTc2n(PB8IB8y3Ws34tSyP4gwI6gBHtVUHxf0BtXaUXJDJth6zWnmL8lR2D0uYZtS241dsmbSLwaHGIfM)jjeI5udSLwatqzRMyngETaqqmkBfSwfzFgapBKKFYE2HJTONRv0yHtVHc6TPyaTPKFzxigkx0tGDBahXv(1YR8)jR74H4ghAX1n8QGEBkgWnidyyXnmw7tS4geRUHWDdYXneJYwb7gg2na8K1nmSBSfo96gEvqVnfd4gp2nsU4gMs(Lv7oAk55jwB86bjMkO3MIbciadlm)tsIbAk6c6TPyGacWWIUPHakAm8AbGGyu2kyTkY(maE2ij)K9S4gBrpxROXcNEdf0BtXaAtj)YUG7OPKNNyTXRhKycylTasTlZ)KKyGMI2WQMOwQQUPHakQ7OPKNNyTXRhKysfzFgapBKKFY6oAk55jwB86bjMa2slGqqXcZx(YpzjXiZ)KecXCQb2slGjOSvtSgtX5auo5ZaTMsChnL88eRnE9GettGDBahXv(z(Yx(jljgzw5Tc0Gyu2kysmY8pjr7KwCKHaQ7OPKNNyTXRhKyAs5yjGJ4k)mF5l)KLeJUJUJMsEEI14gWFYcAqmkBfstGDBahXv(zw5Tc0Gyu2kysmY8pjTiTx7t8zKyvOleBreI5udSLwatqzRMy1NppriMtncGZrbeyrtSUG7OPKNNynUb8NSGgeJYwXdsmvqVnfdeqagwy(NKed0u0f0BtXabeGHfDtdbuu3rtjppXACd4pzbnigLTIhKyclC61F7APm)tsIbAkASWPx)TRLQBAiGIgBXRvawO87zh(Wl4oAk55jwJBa)jlObXOSv8GetvfX)KnGJ4k)m)tsIbAk6QI4FYgWrCLFDtdbuu3rtjppXACd4pzbnigLTIhKycylTacbflm)tsieZPM8FIgyjWIglMY)zm6f85dHyo1aBPfWeu2QjwDhnL88eRXnG)Kf0Gyu2kEqIjWZgj5NSbeoqy(NKqiMtnw40R)21s1eRUJMsEEI14gWFYcAqmkBfpiXunQefhcZFz(NKqiMtDvr8Id8zGLwtcyIeT0pz1eRUJMsEEI14gWFYcAqmkBfpiXunQefhcZFz(NKweVwaiigLTcwRISpdGNnsYpzpNXfITONOCrpb2TbCex5xt7KwCKHa6cUJMsEEI14gWFYcAqmkBfpiXunQefWrCLFM)jj8AbGGyu2kyTkY(maE2ij)K9S4JDTcWcLFpNKxEqSfriMtn5)enWsGfnwmL)ZI)aF(UwbyHYVNtUoyb3rtjppXACd4pzbnigLTIhKyc8Srs(jBaHdeM)jPfriMtnw40R)21s10ETpXNHRiFYI1yXu(dieZzPEnRc1RriMtnw40R)21s1yXu(95dHyo1yHtV(BxlvtSgdHyo1xdlLg4ZGe1qb92uWAI1fChnL88eRXnG)Kf0Gyu2kEqIPjLJLaoIR8Z8pjjgOPOFvNeuV1nneqrJjgOPOVgwknWNbjQHc6TPG1nneqrJHqmN6x1jb1BnXAmeI5uFnSuAGpdsudf0BtbRjwDhnL88eRXnG)Kf0Gyu2kEqIjGT0cieuSW8pjHqmNAdRAIAPQAIv3rtjppXACd4pzbnigLTIhKycylTacbflm)tskohGYjFgO1usmpfd0u0xdlLg4ZGe1qb92uW6MgcOOUJMsEEI14gWFYcAqmkBfpiX0R6KG6nZ)KKyGMI(vDsq9w30qafnMNlETcWcLFp3lg3ykohGYjFQb2slGqqXIM2R9j(mshSG7OPKNNynUb8NSGgeJYwXdsmbSLwaHGIfM)jjfNdq5Kpd0AkjMkYOSfFUyGMIUQiEGpdsudf0BtbRBAiGI6oAk55jwJBa)jlObXOSv8GettkhlbCex5N5Fssmqtr)QojOERBAiGIgdHyo1VQtcQ3AIv3rtjppXACd4pzbnigLTIhKysfzFgIm6YIf3rtjppXACd4pzbnigLTIhKyclM8Qa6JvrgLTm)tsIbAkASyYRcOpwfzu2QBAiGI6oAk55jwJBa)jlObXOSv8Get1OsuOGEBkgG5FsYtXanf9k9VgiuqVnfd8yr30qaf1NpXanf9k9VgiuqVnfd8yr30qafn2IEUwrJfo9gkO3MIb0Ms(LDb3rtjppXACd4pzbnigLTIhKyc8Srs(jBaHde3rtjppXACd4pzbnigLTIhKyAcSBd4iUYpZx(YpzjXiZkVvGgeJYwbtIrM)jjAN0IJmeqDhnL88eRXnG)Kf0Gyu2kEqIPjWUnGJ4k)mF5l)KLeJm)tsx(YEBkA0hlwQ65EP7OPKNNynUb8NSGgeJYwXdsmnPCSeWrCLFMV8LFYsIr3r3rtjppXA8NSGgeJYwH0ey3gWrCLFMvERanigLTcMeJm)tsl6P8k)FY6Zhkx0tGDBahXv(10ETpXNrIvH6ZNyGMI2WQMOwQQUPHakAmuUONa72aoIR8RP9AFIpBrfNdq5Kp1gw1e1sv10ETpXEGqmNAdRAIAPQAucQjppxiMIZbOCYNAdRAIAPQAAV2N4Zo8cXweHyo1aBPfWeu2Qjw95ZteI5uJa4Cuabw0eRl4oAk55jwJ)Kf0Gyu2kEqIjdRAIAPQm)tsIbAkAdRAIAPQ6MgcOOXwu(BpNKxEGpFieZPgbW5OacSOjwxi2IkohGYjFQb2slGqqXIM2R9j(8dwi2IEkgOPOFvNeuV1nneqr95ZteI5u)QojOERjwJ5PIZbOCYN6x1jb1BnX6cUJMsEEI14pzbnigLTIhKyQGEBkgiGamSW8pjjgOPOlO3MIbciadl6MgcOOXwumqtrFnSuAGpdsudf0BtbRBAiGIgBreI5uFnSuAGpdsudf0BtbRjwJDTcWcLFpZlpWNppriMt91WsPb(mirnuqVnfSMyDbF(8umqtrFnSuAGpdsudf0BtbRBAiGIUG7OPKNNyn(twqdIrzR4bjMWcNE93UwkZ)KKyGMIglC61F7AP6MgcOOXwKApAOlBkAdffRvCIuoJC85JApAOlBkAdffR)884EWcXw8AfGfk)E2Hp8cUJMsEEI14pzbnigLTIhKyQQi(NSbCex5N5Fssmqtrxve)t2aoIR8RBAiGIgtX5auo5tnWwAbeckw00ETpXNr6a3rtjppXA8NSGgeJYwXdsmbSLwaHGIfM)jjXanfDvr8pzd4iUYVUPHakAmeI5uxve)t2aoIR8RjwDhnL88eRXFYcAqmkBfpiXe4JdXJgUg71ccx6L5Fssmqtrd(4q8OHRXETGWLE1nneqrDhnL88eRXFYcAqmkBfpiXe4zJK8t2achim)tsieZPglC61F7APAI1y41cabXOSvWAvK9za8Srs(j7zXhBreI5uFnSuAGpdsudf0BtbRjwxWD0uYZtSg)jlObXOSv8Get1OsuCim)L5FscHyo1vfXloWNbwAnjGjs0s)KvtSgBrpfd0u0xdlLg4ZGe1qb92uW6MgcOO(8HqmN6RHLsd8zqIAOGEBkynX6cUJMsEEI14pzbnigLTIhKyQgvIIdH5Vm)ts41cabXOSvWAvK9za8Srs(j75mgZtuUONa72aoIR8RPDsloYqanMNuIStoLT6QI4fh4ZalTMeWejAPFYQBCi(11IgBrpfd0u0xdlLg4ZGe1qb92uW6MgcOO(8HqmN6RHLsd8zqIAOGEBkynXQpFkohGYjFQb2slGqqXIM2R9j(8dIDTcWcLFpNe5k(fChnL88eRXFYcAqmkBfpiXunQefWrCLFM)jjXanf91WsPb(mirnuqVnfSUPHakASfriMt91WsPb(mirnuqVnfSMy1NpfNdq5Kp1aBPfqiOyrt71(eF(bXUwbyHYVNtICfVpF41cabXOSvWAvK9za8Srs(j7zXhdHyo1yHtV(BxlvtSgtX5auo5tnWwAbeckw00ETpXNrIvHUGpFEkgOPOVgwknWNbjQHc6TPG1nneqrDhnL88eRXFYcAqmkBfpiXe4zJK8t2achim)tslIqmNASWPx)TRLQP9AFIpdxr(KfRXIP8hqiMZs9AwfQxJqmNASWPx)TRLQXIP87ZhcXCQXcNE93UwQMyngcXCQVgwknWNbjQHc6TPG1eRl4oAk55jwJ)Kf0Gyu2kEqIPjLJLaoIR8Z8pjjgOPOFvNeuV1nneqrJjgOPOVgwknWNbjQHc6TPG1nneqrJHqmN6x1jb1BnXAmeI5uFnSuAGpdsudf0BtbRjwDhnL88eRXFYcAqmkBfpiXeWwAbeckwy(NKqiMtTHvnrTuvnXQ7OPKNNyn(twqdIrzR4bjMa2slGqqXcZ)KKIZbOCYNbAnLeZtXanf91WsPb(mirnuqVnfSUPHakQ7OPKNNyn(twqdIrzR4bjMEvNeuVz(NKed0u0VQtcQ36MgcOOX8CXRvawO875EX4gtX5auo5tnWwAbeckw00ETpXNr6GfChnL88eRXFYcAqmkBfpiXeWwAbeckwy(NKuCoaLt(mqRPKyQiJYw85IbAk6QI4b(mirnuqVnfSUPHakQ7OPKNNyn(twqdIrzR4bjMMuowc4iUYpZ)KKyGMI(vDsq9w30qafngcXCQFvNeuV1eRXqiMt9R6KG6TM2R9j(mCf5twSglMYFaHyol1RzvOEncXCQFvNeuV1yXu(DhnL88eRXFYcAqmkBfpiXeWwAbeckwy(NKuCoaLt(mqRPe3rtjppXA8NSGgeJYwXdsmnb2TbCex5NzL3kqdIrzRGjXiZ)KeTtAXrgcOUJMsEEI14pzbnigLTIhKyQgvIIdH5Vm)ts41cabXOSvWAvK9za8Srs(j75mgZtkr2jNYwDvr8Id8zGLwtcyIeT0pz1noe)6Ar95dHyo1vfXloWNbwAnjGjs0s)KvtS6oAk55jwJ)Kf0Gyu2kEqIPjLJLaoIR8Z8pjjgOPOFvNeuV1nneqrJHqmN6x1jb1BnXASfriMt9R6KG6TM2R9j(mwfQxFyVgHyo1VQtcQ3ASyk)(8HqmNASWPx)TRLQjw95ZtXanf91WsPb(mirnuqVnfSUPHak6cUJMsEEI14pzbnigLTIhKyAs5yjGJ4k)m)tsuIStoLT6c6TPyGqJdXdEe6tC1noe)6ArJ5jcXCQlO3MIbcnoep4rOpXnGweI5utSgZtXanfDb92umqabyyr30qafnMNIbAk6QI4FYgWrCLFDtdbuu3rtjppXA8NSGgeJYwXdsmPISpdrgDzXI7OPKNNyn(twqdIrzR4bjMWIjVkG(yvKrzlZ)KKyGMIglM8Qa6JvrgLT6MgcOOUJMsEEI14pzbnigLTIhKyQgvIcf0BtXam)tsEkgOPOxP)1aHc6TPyGhl6MgcOO(855Af98PnuqVnfdOnL8lR7OPKNNyn(twqdIrzR4bjMapBKKFYgq4aXD0uYZtSg)jlObXOSv8GettGDBahXv(z(Yx(jljgzw5Tc0Gyu2kysmY8pjr7KwCKHaQ7OPKNNyn(twqdIrzR4bjMMa72aoIR8Z8LV8twsmY8pjD5l7TPOrFSyPQN7LUJMsEEI14pzbnigLTIhKyAs5yjGJ4k)mF5l)KLeJW9YsXppHNI)G4pGX4pGr4M8gn)Kfd3hQ7kNkf1nIRByk55PBaESG1UJWTrirCkCV)lbWKNNK7P2uGBWJfmKb4g)jlObXOSvGmapXiKb4UPHakkKm42uYZt4EcSBd4iUYpCROVu6BW9IUHNUH8k)FY6g(85gOCrpb2TbCex5xt71(e7gNrYnyvOUHpFUHyGMI2WQMOwQQUPHakQBeZnq5IEcSBd4iUYVM2R9j2noZnw0nuCoaLt(uByvtulvvt71(e7gE4gieZP2WQMOwQQgLGAYZt3yb3iMBO4CakN8P2WQMOwQQM2R9j2noZnoSBSGBeZnw0nqiMtnWwAbmbLTAIv3WNp3Wt3aHyo1iaohfqGfnXQBSaCR8wbAqmkBfm8eJqbEkEidWDtdbuuizWTI(sPVb3IbAkAdRAIAPQ6MgcOOUrm3yr3q(BDJZj5gE5bUHpFUbcXCQraCokGalAIv3yb3iMBSOBO4CakN8PgylTacbflAAV2Ny34C34a3yb3iMBSOB4PBigOPOFvNeuV1nneqrDdF(CdpDdeI5u)QojOERjwDJyUHNUHIZbOCYN6x1jb1BnXQBSaCBk55jCByvtulvfkWtKdKb4UPHakkKm4wrFP03GBXanfDb92umqabyyr30qaf1nI5gl6gIbAk6RHLsd8zqIAOGEBkyDtdbuu3iMBSOBGqmN6RHLsd8zqIAOGEBkynXQBeZnUwbyHYVUXzUHxEGB4ZNB4PBGqmN6RHLsd8zqIAOGEBkynXQBSGB4ZNB4PBigOPOVgwknWNbjQHc6TPG1nneqrDJfGBtjppH7c6TPyGacWWcuGNomKb4UPHakkKm4wrFP03GBXanfnw40R)21s1nneqrDJyUXIUb1E0qx2u0gkkwR4eP4gN5gKJB4ZNBqThn0LnfTHII1F6gN7gX9a3yb3iMBSOBCTcWcLFDJZCJdFy3yb42uYZt4glC61F7APqbEkUqgG7MgcOOqYGBf9LsFdUfd0u0vfX)KnGJ4k)6MgcOOUrm3qX5auo5tnWwAbeckw00ETpXUXzKCJdGBtjppH7QI4FYgWrCLFOap5LqgG7MgcOOqYGBf9LsFdUfd0u0vfX)KnGJ4k)6MgcOOUrm3aHyo1vfX)KnGJ4k)AIv42uYZt4gylTacbflqbEYlczaUBAiGIcjdUv0xk9n4wmqtrd(4q8OHRXETGWLE1nneqrHBtjppHBWhhIhnCn2RfeU0luGN8cqgG7MgcOOqYGBf9LsFdUriMtnw40R)21s1eRUrm3aVwaiigLTcwRISpdGNnsYpzDJZCJ4DJyUXIUbcXCQVgwknWNbjQHc6TPG1eRUXcWTPKNNWn4zJK8t2achiqbEICbzaUBAiGIcjdUv0xk9n4gHyo1vfXloWNbwAnjGjs0s)KvtS6gXCJfDdpDdXanf91WsPb(mirnuqVnfSUPHakQB4ZNBGqmN6RHLsd8zqIAOGEBkynXQBSaCBk55jCxJkrXHW8xOapX4bqgG7MgcOOqYGBf9LsFdUXRfacIrzRG1Qi7Za4zJK8tw34C3Gr3iMB4PBGYf9ey3gWrCLFnTtAXrgcOUrm3Wt3GsKDYPSvxveV4aFgyP1KaMirl9twDJdXVUwu3iMBSOB4PBigOPOVgwknWNbjQHc6TPG1nneqrDdF(CdeI5uFnSuAGpdsudf0BtbRjwDdF(CdfNdq5Kp1aBPfqiOyrt71(e7gN7gh4gXCJRvawO8RBCoj3GCfVBSaCBk55jCxJkrXHW8xOapXiJqgG7MgcOOqYGBf9LsFdUfd0u0xdlLg4ZGe1qb92uW6MgcOOUrm3yr3aHyo1xdlLg4ZGe1qb92uWAIv3WNp3qX5auo5tnWwAbeckw00ETpXUX5UXbUrm34AfGfk)6gNtYnixX7g(85g41cabXOSvWAvK9za8Srs(jRBCMBeVBeZnqiMtnw40R)21s1eRUrm3qX5auo5tnWwAbeckw00ETpXUXzKCdwfQBSGB4ZNB4PBigOPOVgwknWNbjQHc6TPG1nneqrHBtjppH7AujkGJ4k)qbEIX4Hma3nneqrHKb3k6lL(gCVOBGqmNASWPx)TRLQP9AFIDJZCdCf5twSglMYFaHyol1n8A3GvH6gETBGqmNASWPx)TRLQXIP87g(85gieZPglC61F7APAIv3iMBGqmN6RHLsd8zqIAOGEBkynXQBSaCBk55jCdE2ij)KnGWbcuGNyKCGma3nneqrHKb3k6lL(gClgOPOFvNeuV1nneqrDJyUHyGMI(AyP0aFgKOgkO3Mcw30qaf1nI5gieZP(vDsq9wtS6gXCdeI5uFnSuAGpdsudf0BtbRjwHBtjppH7jLJLaoIR8df4jgpmKb4UPHakkKm4wrFP03GBeI5uByvtulvvtSc3MsEEc3aBPfqiOybkWtmgxidWDtdbuuizWTI(sPVb3kohGYjFgO1uIBeZn80ned0u0xdlLg4ZGe1qb92uW6MgcOOWTPKNNWnWwAbeckwGc8eJEjKb4UPHakkKm4wrFP03GBXanf9R6KG6TUPHakQBeZn80nw0nUwbyHYVUX5UHxmUUrm3qX5auo5tnWwAbeckw00ETpXUXzKCJdCJfGBtjppH7x1jb1BOapXOxeYaC30qaffsgCROVu6BWTIZbOCYNbAnL4gXCdvKrzl2no3ned0u0vfXd8zqIAOGEBkyDtdbuu42uYZt4gylTacbflqbEIrVaKb4UPHakkKm4wrFP03GBXanf9R6KG6TUPHakQBeZnqiMt9R6KG6TMy1nI5gieZP(vDsq9wt71(e7gN5g4kYNSynwmL)acXCwQB41UbRc1n8A3aHyo1VQtcQ3ASyk)WTPKNNW9KYXsahXv(Hc8eJKlidWDtdbuuizWTI(sPVb3kohGYjFgO1ucCBk55jCdSLwaHGIfOapf)bqgG7MgcOOqYGBtjppH7jWUnGJ4k)WTI(sPVb30oPfhziGc3kVvGgeJYwbdpXiuGNINridWDtdbuuizWTI(sPVb341cabXOSvWAvK9za8Srs(jRBCUBWOBeZn80nOezNCkB1vfXloWNbwAnjGjs0s)Kv34q8RRf1n85ZnqiMtDvr8Id8zGLwtcyIeT0pz1eRWTPKNNWDnQefhcZFHc8u8XdzaUBAiGIcjdUv0xk9n4wmqtr)QojOERBAiGI6gXCdeI5u)QojOERjwDJyUXIUbcXCQFvNeuV10ETpXUXzUbRc1n8A34WUHx7gieZP(vDsq9wJft53n85ZnqiMtnw40R)21s1eRUHpFUHNUHyGMI(AyP0aFgKOgkO3Mcw30qaf1nwaUnL88eUNuowc4iUYpuGNINCGma3nneqrHKb3k6lL(gCtjYo5u2QlO3MIbcnoep4rOpXv34q8RRf1nI5gE6gieZPUGEBkgi04q8GhH(e3aAriMtnXQBeZn80ned0u0f0BtXabeGHfDtdbuu3iMB4PBigOPORkI)jBahXv(1nneqrHBtjppH7jLJLaoIR8df4P4pmKb42uYZt4wfzFgIm6YIf4UPHakkKmOapfFCHma3nneqrHKb3k6lL(gClgOPOXIjVkG(yvKrzRUPHakkCBk55jCJftEva9XQiJYwOapfVxczaUBAiGIcjdUv0xk9n42t3qmqtrVs)Rbcf0BtXapw0nneqrDdF(CdpDJ1k65tBOGEBkgqBk5xw42uYZt4UgvIcf0BtXaqbEkEViKb42uYZt4g8Srs(jBaHde4UPHakkKmOapfVxaYaCF5l)KfEIr4UPHaA4Yx(jlKm42uYZt4EcSBd4iUYpCR8wbAqmkBfm8eJWTI(sPVb30oPfhziGc3nneqrHKbf4P4jxqgG7MgcOOqYG7MgcOHlF5NSqYGBf9LsFdUV8L92u0OpwSuv34C3WlHBtjppH7jWUnGJ4k)W9LV8tw4jgHc8e5CaKb4(Yx(jl8eJWDtdb0WLV8twizWTPKNNW9KYXsahXv(H7MgcOOqYGcuGB0oncGazaEIridWTPKNNWn5)enGJQrH7MgcOOqYGc8u8qgGBtjppHBcCdV0lgUBAiGIcjdkWtKdKb42uYZt4E(0gkO3MIbG7MgcOOqYGc80HHma3MsEEc3yHtVHc6TPya4UPHakkKmOapfxidWTPKNNWTINQMc1KIgMa7w4UPHakkKmOap5LqgGBtjppHBeaNJg4ZGe1qZE9gUBAiGIcjdkWtEridWTPKNNWnlHrrFld8zWi3ukxIG7MgcOOqYGc8KxaYaCBk55jCp5kcCrdg5MsFPbKAx4UPHakkKmOaprUGma3MsEEc3Re0F69NSbeGHf4UPHakkKmOapX4bqgGBtjppHBjQbIeHtKOHjNQkC30qaffsguGNyKridWTPKNNW9Txo17aFgaeQhnGsRDXWDtdbuuizqbEIX4Hma3MsEEc30FDf0WNb8QPkC30qaffsguGNyKCGma3MsEEc3KNtbOl7NbAX80svH7MgcOOqYGc8eJhgYaC30qaffsgCROVu6BWTyu2k6OAajkSQe34C3WlCGB4ZNBigLTIoQgqIcRkXnoZnI)a3WNp3y(SrsG2R9j2noZniNdGBtjppHBAT1pzdtGDlgkWtmgxidWTPKNNWDunQekg3uv4UPHakkKmOapXOxczaUBAiGIcjdUv0xk9n42t3qmqtrByvtulvv30qaf1n85ZnqiMtTHvnrTuvnXQB4ZNBO4CakN8P2WQMOwQQM2R9j2no3nI7bWTPKNNWncGZrdtcQ3qbEIrViKb4UPHakkKm4wrFP03GBpDdXanfTHvnrTuvDtdbuu3WNp3aHyo1gw1e1sv1eRWTPKNNWnsP4s9)jluGNy0lazaUBAiGIcjdUv0xk9n42t3qmqtrByvtulvv30qaf1n85ZnqiMtTHvnrTuvnXQB4ZNBO4CakN8P2WQMOwQQM2R9j2no3nI7bWTPKNNW98PfbW5OqbEIrYfKb4UPHakkKm4wrFP03GBpDdXanfTHvnrTuvDtdbuu3WNp3aHyo1gw1e1sv1eRUHpFUHIZbOCYNAdRAIAPQAAV2Ny34C3iUha3MsEEc3wQkwOgiOmaakWtXFaKb4UPHakkKm4wrFP03GBpDdXanfTHvnrTuvDtdbuu3WNp3Wt3aHyo1gw1e1sv1eRWTPKNNWnIXg4ZGqFLFmuGNINridWDtdbuuizWTPKNNW9k9VCk6BGa5TLfUv0xk9n42t3aHyo1R0)YPOVbcK3wwnXkCR8wbAqmkBfm8eJqbEk(4Hma3MsEEc3llET0GWLEH7MgcOOqYGc8u8KdKb42uYZt4EAniulXtc8Zt4UPHakkKmOapf)HHma3nneqrHKb3k6lL(gCBk5x2qZE)IDJZDJ4DJyUXIUbETaqqmkBfSwfzFgapBKKFY6gN7gX7g(85g41cabXOSvWAGT0ci1UUX5Ur8UXcWTPKNNWnLidMsEEgapwGBWJLqA3c3gVqbEk(4czaUBAiGIcjdUv0xk9n42t3qmqtrJfo9gkO3MIb0nneqrDJyUHPKFzdn79l2noJKBepCBk55jCtjYGPKNNbWJf4g8yjK2TWn(twqdIrzRaf4P49sidWDtdbuuizWTI(sPVb3IbAkASWP3qb92umGUPHakQBeZnmL8lBOzVFXUXzKCJ4HBtjppHBkrgmL88maESa3GhlH0UfUXnG)Kf0Gyu2kqbkW9kTk(fXeidWtmczaUBAiGIcjdUv0xk9n42t3qmqtrVs)Rbcf0BtXapw0nneqrHBtjppH7AujkuqVnfdaf4P4Hma3nneqrHKb3k6lL(gClgOPOXcNE93UwQUPHakQBeZnw0nO2Jg6YMI2qrXAfNif34m3GCCdF(CdQ9OHUSPOnuuS(t34C3iUh4gla3MsEEc3yHtV(BxlfkWtKdKb42uYZt4ELlppH7MgcOOqYGc80HHma3nneqrHKb3k6lL(gClgOPOlO3MIbciadl6MgcOOWTPKNNWDb92umqabyybkWtXfYaC30qaffsgCROVu6BWTNUHyGMIUGEBkgiGamSOBAiGIc3MsEEc3aBPfqiOybkqbUnEHmapXiKb4UPHakkKm4wrFP03GBeI5uxve)t2aoIR8RjwHBtjppH7AujkoeM)cf4P4Hma3MsEEc3Qi7ZqKrxwSa3nneqrHKbf4jYbYaC30qaffsgCROVu6BWTyGMIglC61F7AP6MgcOOWTPKNNWnw40R)21sHc80HHma3nneqrHKb3MsEEc3tGDBahXv(HBf9LsFdUnL8lBaLl6jWUnGJ4k)UXzUb54gXCdtj)YgA27xSBCgj3iUUHpFUbLi7KtzRg73BeAn)LIdZVuVdO9(4QBCi(11Ic3kVvGgeJYwbdpXiuGNIlKb4UPHakkKm4wrFP03GBpDdtj)Ygq5IEcSBd4iUYpCBk55jCpb2TbCex5hkWtEjKb4UPHakkKm4wrFP03GBXanfDvr8pzd4iUYVUPHakQBeZnUwbyHYVUX5KCdV8a42uYZt4UQi(NSbCex5hkWtEridWDtdbuuizWTI(sPVb3IbAkAdRAIAPQ6MgcOOUrm3yr3Wt3yTIglC6nuqVnfdOnL8lRBSGBeZnw0n80ned0u0VQtcQ36MgcOOUHpFUHNUbcXCQFvNeuV1eRUrm3Wt3qX5auo5t9R6KG6TMy1nwaUnL88eUnSQjQLQcf4jVaKb4UPHakkKm4wrFP03GBXanfn4JdXJgUg71ccx6v30qaffUnL88eUbFCiE0W1yVwq4sVqbEICbzaUBAiGIcjdUv0xk9n4MsKDYPSvxveV4aFgyP1KaMirl9twDJdXVUwu3iMB4PBGqmN6QI4fh4ZalTMeWejAPFYQjwHBtjppH7AujkGJ4k)qbEIXdGma3nneqrHKb3k6lL(gCtjYo5u2QrBxfAVCAal8S6ghIFDTOUrm3yr3Wt3qmqtrVs)Rbcf0BtXapw0nneqrDdF(CJfDdpDJ1kASWP3qb92umG2uYVSUrm3Wt3yTIE(0gkO3MIb0Ms(L1nwWnwaUnL88eURrLOqb92umauGNyKridWDtdbuuizWTPKNNWnWwAbeckwGBf9LsFdUXRfacIrzRG1Qi7Za4zJK8tw34m34WUHpFUbcXCQb2slGjOSvtS6g(85gl6gIbAk6RHLsd8zqIAOGEBkyDtdbuu3iMB4PBGqmN6RHLsd8zqIAOGEBkynXQBeZnUwbyHYVUX5KCdV8a3yb4w5Tc0Gyu2ky4jgHc8eJXdzaUBAiGIcjdUv0xk9n42t3qmqtrFnSuAGpdsudf0BtbRBAiGI6g(85gieZPglC61F7APAIv3WNp34AfGfk)6gNtYnw0ny8GdCdVc34WUHx7g41cabXOSvWAvK9za8Srs(jRBSGB4ZNBGqmN6RHLsd8zqIAOGEBkynXQB4ZNBGxlaeeJYwbRvr2NbWZgj5NSUX5Ub5a3MsEEc31OsuCim)fkWtmsoqgG7MgcOOqYGBf9LsFdUriMtnw40R)21s10ETpXUXzUb54gETBWQqDdV2nqiMtnw40R)21s1yXu(HBtjppHBvK9za8Srs(jluGNy8WqgG7MgcOOqYGBf9LsFdUriMtnWwAbmbLTAIv3iMBGxlaeeJYwbRvr2NbWZgj5NSUXzUXHDJyUXIUHNUXAfnw40BOGEBkgqBk5xw3yb3iMBGYf9ey3gWrCLFT8k)FYc3MsEEc3aBPfqiOybkWtmgxidWDtdbuuizWTI(sPVb3IbAk6c6TPyGacWWIUPHakQBeZnWRfacIrzRG1Qi7Za4zJK8tw34m3iUUrm3yr3Wt3yTIglC6nuqVnfdOnL8lRBSaCBk55jCxqVnfdeqagwGc8eJEjKb4UPHakkKm4wrFP03GBXanfTHvnrTuvDtdbuu42uYZt4gylTasTluGNy0lczaUnL88eUvr2NbWZgj5NSWDtdbuuizqbEIrVaKb4UPHakkKm4UPHaA4Yx(jlKm4wrFP03GBeI5udSLwatqzRMy1nI5gkohGYjFgO1ucCBk55jCdSLwaHGIf4(Yx(jl8eJqbEIrYfKb4(Yx(jl8eJWDtdb0WLV8twizWTPKNNW9ey3gWrCLF4w5Tc0Gyu2ky4jgHBf9LsFdUPDsloYqafUBAiGIcjdkWtXFaKb4(Yx(jl8eJWDtdb0WLV8twizWTPKNNW9KYXsahXv(H7MgcOOqYGcuGBCd4pzbnigLTcKb4jgHma3nneqrHKb3MsEEc3tGDBahXv(HBf9LsFdUx0nO9AFIDJZi5gSku3yb3iMBSOBGqmNAGT0cyckB1eRUHpFUHNUbcXCQraCokGalAIv3yb4w5Tc0Gyu2ky4jgHc8u8qgG7MgcOOqYGBf9LsFdUfd0u0f0BtXabeGHfDtdbuu42uYZt4UGEBkgiGamSaf4jYbYaC30qaffsgCROVu6BWTyGMIglC61F7AP6MgcOOUrm3yr34AfGfk)6gN5gh(WUXcWTPKNNWnw40R)21sHc80HHma3nneqrHKb3k6lL(gClgOPORkI)jBahXv(1nneqrHBtjppH7QI4FYgWrCLFOapfxidWDtdbuuizWTI(sPVb3ieZPM8FIgyjWIglMYVBCMBWOxWn85ZnqiMtnWwAbmbLTAIv42uYZt4gylTacbflqbEYlHma3nneqrHKb3k6lL(gCJqmNASWPx)TRLQjwHBtjppHBWZgj5NSbeoqGc8KxeYaC30qaffsgCROVu6BWncXCQRkIxCGpdS0AsatKOL(jRMyfUnL88eURrLO4qy(luGN8cqgG7MgcOOqYGBf9LsFdUx0nWRfacIrzRG1Qi7Za4zJK8tw34C3Gr3yb3iMBSOB4PBGYf9ey3gWrCLFnTtAXrgcOUXcWTPKNNWDnQefhcZFHc8e5cYaC30qaffsgCROVu6BWnETaqqmkBfSwfzFgapBKKFY6gN5gX7gXCJRvawO8RBCoj3WlpWnI5gl6gieZPM8FIgyjWIglMYVBCMBe)bUHpFUX1kalu(1no3nixh4gla3MsEEc31OsuahXv(Hc8eJhazaUBAiGIcjdUv0xk9n4Er3aHyo1yHtV(Bxlvt71(e7gN5g4kYNSynwmL)acXCwQB41UbRc1n8A3aHyo1yHtV(BxlvJft53n85ZnqiMtnw40R)21s1eRUrm3aHyo1xdlLg4ZGe1qb92uWAIv3yb42uYZt4g8Srs(jBaHdeOapXiJqgG7MgcOOqYGBf9LsFdUfd0u0VQtcQ36MgcOOUrm3qmqtrFnSuAGpdsudf0BtbRBAiGI6gXCdeI5u)QojOERjwDJyUbcXCQVgwknWNbjQHc6TPG1eRWTPKNNW9KYXsahXv(Hc8eJXdzaUBAiGIcjdUv0xk9n4gHyo1gw1e1sv1eRWTPKNNWnWwAbeckwGc8eJKdKb4UPHakkKm4wrFP03GBfNdq5Kpd0AkXnI5gE6gIbAk6RHLsd8zqIAOGEBkyDtdbuu42uYZt4gylTacbflqbEIXddzaUBAiGIcjdUv0xk9n4wmqtr)QojOERBAiGI6gXCdpDJfDJRvawO8RBCUB4fJRBeZnuCoaLt(udSLwaHGIfnTx7tSBCgj34a3yb42uYZt4(vDsq9gkWtmgxidWDtdbuuizWTI(sPVb3kohGYjFgO1uIBeZnurgLTy34C3qmqtrxvepWNbjQHc6TPG1nneqrHBtjppHBGT0cieuSaf4jg9sidWDtdbuuizWTI(sPVb3IbAk6x1jb1BDtdbuu3iMBGqmN6x1jb1BnXkCBk55jCpPCSeWrCLFOapXOxeYaCBk55jCRISpdrgDzXcC30qaffsguGNy0lazaUBAiGIcjdUv0xk9n4wmqtrJftEva9XQiJYwDtdbuu42uYZt4glM8Qa6JvrgLTqbEIrYfKb4UPHakkKm4wrFP03GBpDdXanf9k9VgiuqVnfd8yr30qaf1n85Zned0u0R0)AGqb92umWJfDtdbuu3iMBSOB4PBSwrJfo9gkO3MIb0Ms(L1nwaUnL88eURrLOqb92umauGNI)aidWTPKNNWn4zJK8t2achiWDtdbuuizqbEkEgHma3x(YpzHNyeUBAiGgU8LFYcjdUnL88eUNa72aoIR8d3kVvGgeJYwbdpXiCROVu6BWnTtAXrgcOWDtdbuuizqbEk(4Hma3nneqrHKb3nneqdx(YpzHKb3k6lL(gCF5l7TPOrFSyPQUX5UHxc3MsEEc3tGDBahXv(H7lF5NSWtmcf4P4jhidW9LV8tw4jgH7MgcOHlF5NSqYGBtjppH7jLJLaoIR8d3nneqrHKbfOafOafie]] )

end
