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

    spec:RegisterPack( "Elemental", 20201123, [[dC0wzbqiQsEKqH2Kq1NKsIQrjfCkPqRcvL6vufnluvDluvq7Ik)IQWWKsCmuLwMqPNHqyAieDnPKABOQKVHQImouvOZjLKwNqbX8uL4EiyFiKoOqb1crv8quvatuOGuxuOaFuOGKtkLewPuQzkLePUjQkq7uvQFkLeLLkLejpvQMkc1vLsIO9c8xbdwKdtzXq8ysMmIUSYMf1NrLrlKtRYRPQA2GUTQA3s(nkdxvCCHIwosphQPtCDiTDPOVRkPXlLeHZtvQ1JQIA(uv2pPgWlGyqN0KbEhBlX2cV8glr44T1TUvBP1GU49Za9ht534gOx2FGEmaU)kXGG(J5nKzKaIbDmdLQgOhjYdogIhEWDsekItX(EGVpk0KJvkQLfpW3x5bOJGEqPvuaeqN0KbEhBlX2cV8glr44T1TUvBHibD8ZuG3XYxXc6rhj5kacOtoSc0JrDkga3FLyqDQhzFR0TJrD6nR5(iJQtXse8RtX2sSTOBRBhJ6eFGiR4gogIUDmQt8H6ummj5i1jet5h9rNIby8k10jd5GN4Tt3og1j(qDQvukg9Hrnz6eEICfh2Hft5pGGMZJQtzgvNAfQLrPEZVo1fg97F7zuhO)qz5doqpg1PyaC)vIb1PEK9Ts3og1P3SM7JmQoflrWVofBlX2IUTUDmQt8bISIB4yi62XOoXhQtXWKKJuNqmLF0hDkgGXRutNmKdEI3oD7yuN4d1PwrPy0hg1KPt4jYvCyhwmL)acAopQoLzuDQvOwgL6n)6uxy0V)TNrD6262MsowHDp0PyFetiGIx4K95VS)iy8zCKrnCiZkjWYHh2RJQBBk5yf29qNI9rmXtcE8WKJv6262XOofdALykuzK60AoQ36KC)Pts00jtjmQoDyDYAAh0qGZPBhJ6eFadl6epqgJeIIfD6BfQbHERtxwNKOPtXW85rpz6eXu7eDkgUudludQtTsnmRSsnD6W60dD4vIt32uYXkmbeiJrcrXc)xMGXNh9K5SsnSqnyGomRSsn3kdbosD7yuNAffFOI9rmrNEyYXkD6W60dD5rxjNbHERtWR8psDsy6KenDkgkuJsEwPtSSofdZNhLjr8RtOfCySoPyFet0PxpiuNwrQt4igvGE70TnLCSc7jbpEyYXk(VmH8Xfjb6(2v4x4Rw85tXyqs2RLJd1OKNvbwoy85rzsKJUVDf(fIOfDBD7yuNAfLmkf9r0jwwNugwWoDBtjhRWEsWJxVImGJMr1TnLCSc7jbpqXlCY(yDBtjhRWEsWJ8rxyW9xjgu32uYXkSNe8alm6pm4(RedQBRBBk5yf2tcEOyLALqnzKHm0(t32uYXkSNe8abYyKbwoirlSAFV1TnLCSc7jbp4qnk5zvGLdgFEuMePBBk5yf2tcEKzku8idgFE0twaz2x32uYXkSNe84bLEzVVIlGanSOBBk5yf2tcEirlGwim0ImKzu10TnLCSc7jbp(7ZOEhy5aevDKbs6Spw32uYXkSNe8GEppWfUkGFm10TnLCSc7jbpELrHKn3vb6WSYk10TnLCSc7jbpOZEUIlKH2Fy(VmbXOCtCrZGsu4rjeLp2IpFIr5M4IMbLOWJsEj2w85lFCrsGUVDf(fIOfD7yuNAfLoPm80PwHoLzuoMOty2Fs0vCoDBtjhRWEsWJOzujmmELA6262MsowH9KGhiqgJmKrPEZ)Lj4LyWvIZWQvKwPMBLHahPpFiO5SZWQvKwPMd9XNpfJbjzVwodRwrALAo6(2vyI26w0TnLCSc7jbpqgfpQ)R44)Ye8sm4kXzy1ksRuZTYqGJ0Npe0C2zy1ksRuZH(OBBk5yf2tcEKp6qGmgj)xMGxIbxjodRwrALAUvgcCK(8HGMZodRwrALAo0hF(umgKK9A5mSAfPvQ5O7BxHjARBr32uYXkSNe8Wk1Wc1GbLbH8FzcEjgCL4mSAfPvQ5wziWr6ZhcAo7mSAfPvQ5qF85tXyqs2RLZWQvKwPMJUVDfMOTUfDBtjhRWEsWdeJlWYbHEk)y(VmbVedUsCgwTI0k1CRme4i95Zle0C2zy1ksRuZH(OBRBBk5yf2tcE8qVpJsEgm8Q1C8R8wbxqmk3embE5)Ye8cbnNDp07ZOKNbdVAnNd9r32uYXkSNe8O5WpJgeMSVUTPKJvypj4r2wqOwHZO4Jv6262MsowH9KGhu0kyk5yvaEyH)Y(JGXg)xMGPKR5cR2)gMOXgVb8ZGWGyuUjyNkYUkapUiPUIJOX6Zh(zqyqmk3eSdAnTaYSprJTrDBtjhRWEsWdkAfmLCSkapSWFz)raFfhCbXOCt4)Ye8sm4kXHfg9hgC)vIbDRme4iJBk5AUWQ9VHFHqS62MsowH9KGhu0kyk5yvaEyH)Y(JaEb8vCWfeJYnH)ltqm4kXHfg9hgC)vIbDRme4iJBk5AUWQ9VHFHqS6262MsowHDgBeMrLOyIA(h)xMacAo7MkIDfxahXu(DOp62MsowHDgBEsWdvKDviYOnhw0TnLCSc7m28KGhyHr)(3EgL)ltqm4kXHfg97F7zu3kdbosDBtjhRWoJnpj4rgA)fWrmLF(vERGligLBcMaV8FzcMsUMlqYexgA)fWrmL)xiI4MsUMlSA)B4xi0AF(OO1Ymk3Cy)EJqN5FuCiFJ6DGC)dp3Ij698msDBtjhRWoJnpj4rgA)fWrmLF(VmbVmLCnxGKjUm0(lGJyk)62MsowHDgBEsWJPIyxXfWrmLF(VmbXGRe3urSR4c4iMYVBLHahz8VniwOSprjWxTOBBk5yf2zS5jbpmSAfPvQX)LjigCL4mSAfPvQ5wziWrgVbVEM4WcJ(ddU)kXGotjxZ1y8g8sm4kXDQLrPE7wziWr6ZNxiO5S7ulJs92H(e3lfJbjzVwUtTmk1Bh6tJ62MsowHDgBEsWd4ft0Jm8nUVfeMSp)xMGyWvIdEXe9idFJ7BbHj77wziWrQBBk5yf2zS5jbpMrLOaoIP8Z)LjqrRLzuU5MkInCGLdC0zsaJwKJEfNBXe9EEgzCVqqZz3urSHdSCGJotcy0IC0R4COp62MsowHDgBEsWJzujkm4(RedY)LjqrRLzuU5i3Ee6(mAalSAUft075zKXBWlXGRe3d9(gmm4(RedEyXTYqGJ0NVg86zIdlm6pm4(Red6mLCnxCVEM4YhDHb3FLyqNPKR5ASrDBtjhRWoJnpj4b0AAbeukw4x5TcUGyuUjyc8Y)LjGFgegeJYnb7ur2vb4Xfj1vCVqK(8HGMZoO10cyuk3COp(81GyWvI7Byz0alhKOfgC)vc2TYqGJmUxiO5S7Byz0alhKOfgC)vc2H(e)BdIfk7tuc8vlnQBhJ6eXuV1jHPtC2F6umWOsumrn)tNE9KiDIpOHLr1jwwNKOPtXa4(ReSoHGMZ60RrR0P8XfjxXPteHojgLBc2PtXqZQw5IoXAoQYE0j(G2GyHY(EPBBk5yf2zS5jbpMrLOyIA(h)xMGxIbxjUVHLrdSCqIwyW9xjy3kdbosF(qqZzhwy0V)TNrDOp(89TbXcL9jkHg4TLw4djs(g)mimigLBc2PISRcWJlsQR4A0Npe0C29nSmAGLds0cdU)kb7qF85d)mimigLBc2PISRcWJlsQR4ikrOBhJ6eFqZ)0jmkD6K3muDIKvTYfDcYWtNmDQlm63)2ZO6ecAo70TnLCSc7m28KGhQi7Qa84IK6ko(Vmbe0C2Hfg97F7zuhDF7k8lebFZPi5Be0C2Hfg97F7zuhwmLFD7yuNALvqV1jLHfDQvARPPt8GsXIoXkDsIOB6KyuUjyD6Y60j60H1jR0PRWIvIozfPo1fg9RtXa4(RedQthwNE3kJyDYuY1CoDBtjhRWoJnpj4b0AAbeukw4)YeqqZzh0AAbmkLBo0N44NbHbXOCtWovKDvaECrsDf3lez8g86zIdlm6pm4(Red6mLCnxJXjzIldT)c4iMYVtoL)R40TJrDQvs80PyaC)vIb1jEGgw0jJZUcl6e6JojmDIi0jXOCtW6KH1jiR40jdRtDHr)6umaU)kXG60H1PIj6KPKR5C62MsowHDgBEsWJb3FLyWac0Wc)xMGyWvIBW9xjgmGanS4wziWrgh)mimigLBc2PISRcWJlsQR4EP1XBWRNjoSWO)WG7VsmOZuY1CnQBBk5yf2zS5jbpur2vb4Xfj1vC62MsowHDgBEsWdO10ciOuSW)N18koc8Y)LjGGMZoO10cyuk3COpXvmgKK9AfOZuIUTPKJvyNXMNe8idT)c4iMYp)FwZR4iWl)kVvWfeJYnbtGx(Vmb6Y0HJme40TnLCSc7m28KGhzkdlbCet5N)pR5vCe4v3w32uYXkSdVa(ko4cIr5MqidT)c4iMYp)kVvWfeJYnbtGx(VmHgO7BxHFHaNISX4nGGMZoO10cyuk3COp(85fcAo7qGmgjeflo0Ng1TnLCSc7WlGVIdUGyuUjEsWJb3FLyWac0Wc)xMGyWvIBW9xjgmGanS4wziWrQBBk5yf2HxaFfhCbXOCt8KGhyHr)(3EgL)ltqm4kXHfg97F7zu3kdboY4n8TbXcL9FHijYg1TnLCSc7WlGVIdUGyuUjEsWJPIyxXfWrmLF(VmbXGRe3urSR4c4iMYVBLHahPUTPKJvyhEb8vCWfeJYnXtcEaTMwabLIf(Vmbe0C296vKbouS4WIP8)cV8rF(qqZzh0AAbmkLBo0hDBtjhRWo8c4R4GligLBINe8aECrsDfxaHbf(Vmbe0C2Hfg97F7zuh6JUTPKJvyhEb8vCWfeJYnXtcEmJkrXe18p(Vmbe0C2nveB4alh4OZKagTih9koh6JUTPKJvyhEb8vCWfeJYnXtcEmJkrXe18p(VmHgWpdcdIr5MGDQi7Qa84IK6koIYBJXBWlsM4Yq7VaoIP87OlthoYqGRrDBtjhRWo8c4R4GligLBINe8ygvIc4iMYp)xMa(zqyqmk3eStfzxfGhxKuxX9sSX)2GyHY(eLaF1s8gqqZz3Rxrg4qXIdlMY)lX2IpFFBqSqzFI2QT0OUTPKJvyhEb8vCWfeJYnXtcEapUiPUIlGWGc)xMqdiO5Sdlm63)2ZOo6(2v4xWtKR4WoSyk)be0CEu(MtrY3iO5Sdlm63)2ZOoSyk)(8HGMZoSWOF)BpJ6qFIJGMZUVHLrdSCqIwyW9xjyh6tJ62MsowHD4fWxXbxqmk3epj4rMYWsahXu(5)YeedUsCNAzuQ3UvgcCKXfdUsCFdlJgy5GeTWG7VsWUvgcCKXrqZz3PwgL6Td9jocAo7(gwgnWYbjAHb3FLGDOp62MsowHD4fWxXbxqmk3epj4b0AAbeukw4)YeqqZzNHvRiTsnh6JUTPKJvyhEb8vCWfeJYnXtcEaTMwabLIf(VmbfJbjzVwb6mLe3lXGRe33WYObwoirlm4(ReSBLHahPUTPKJvyhEb8vCWfeJYnXtcECQLrPEZ)LjigCL4o1YOuVDRme4iJ7vdFBqSqzFIYNADCfJbjzVwoO10ciOuS4O7BxHFHqlnQBBk5yf2HxaFfhCbXOCt8KGhqRPfqqPyH)ltqXyqs2RvGotjXvrgLByIkgCL4MkIfy5GeTWG7VsWUvgcCK62MsowHD4fWxXbxqmk3epj4rMYWsahXu(5)YeedUsCNAzuQ3UvgcCKXrqZz3PwgL6Td9r32uYXkSdVa(ko4cIr5M4jbpur2vHiJ2Cyr32uYXkSdVa(ko4cIr5M4jbpWIjNkqEyvKr5g)xMGyWvIdlMCQa5HvrgLBUvgcCK62MsowHD4fWxXbxqmk3epj4XmQefgC)vIb5)Ye8sm4kX9qVVbddU)kXGhwCRme4i95tm4kX9qVVbddU)kXGhwCRme4iJ3GxptCyHr)Hb3FLyqNPKR5Au32uYXkSdVa(ko4cIr5M4jbpGhxKuxXfqyqr32uYXkSdVa(ko4cIr5M4jbpYq7VaoIP8Z)N18koc8YVYBfCbXOCtWe4L)ltGUmD4idboDBtjhRWo8c4R4GligLBINe8idT)c4iMYp)FwZR4iWl)xMWN1C)vIJ8WIvQru(s32uYXkSdVa(ko4cIr5M4jbpYugwc4iMYp)FwZR4iWRUTUTPKJvyh(ko4cIr5MqidT)c4iMYp)kVvWfeJYnbtGx(VmHg8soL)R485JKjUm0(lGJyk)o6(2v4xiWPi95tm4kXzy1ksRuZTYqGJmojtCzO9xahXu(D09TRWV0GIXGKSxlNHvRiTsnhDF7kSNiO5SZWQvKwPMJeLAYXQgJRymij71Yzy1ksRuZr33Uc)cr2y8gqqZzh0AAbmkLBo0hF(8cbnNDiqgJeIIfh6tJ62MsowHD4R4GligLBINe8WWQvKwPg)xMGyWvIZWQvKwPMBLHahz8gK7pIsGVAXNpe0C2HazmsikwCOpngVbfJbjzVwoO10ciOuS4O7BxHjAlngVbVedUsCNAzuQ3UvgcCK(85fcAo7o1YOuVDOpX9sXyqs2RL7ulJs92H(0OUTPKJvyh(ko4cIr5M4jbpgC)vIbdiqdl8FzcIbxjUb3FLyWac0WIBLHahz8gedUsCFdlJgy5GeTWG7VsWUvgcCKXBabnNDFdlJgy5GeTWG7VsWo0N4FBqSqz)x4Rw85Zle0C29nSmAGLds0cdU)kb7qFA0NpVedUsCFdlJgy5GeTWG7VsWUvgcCKnQBBk5yf2HVIdUGyuUjEsWdSWOF)BpJY)LjigCL4WcJ(9V9mQBLHahz8gO2rgwZvIZijXofdTKxicF(O2rgwZvIZijXURiARBPX4n8TbXcL9FHijYg1TnLCSc7WxXbxqmk3epj4XurSR4c4iMYp)xMGyWvIBQi2vCbCet53TYqGJmUIXGKSxlh0AAbeukwC09TRWVqOfDBtjhRWo8vCWfeJYnXtcEaTMwabLIf(VmbXGRe3urSR4c4iMYVBLHahzCe0C2nve7kUaoIP87qF0TnLCSc7WxXbxqmk3epj4b8Ij6rg(g33cct2N)ltqm4kXbVyIEKHVX9TGWK9DRme4i1TnLCSc7WxXbxqmk3epj4b84IK6kUacdk8FzciO5Sdlm63)2ZOo0N44NbHbXOCtWovKDvaECrsDf3lXgVbe0C29nSmAGLds0cdU)kb7qFAu32uYXkSdFfhCbXOCt8KGhZOsumrn)J)ltabnNDtfXgoWYbo6mjGrlYrVIZH(eVbVedUsCFdlJgy5GeTWG7VsWUvgcCK(8HGMZUVHLrdSCqIwyW9xjyh6tJ62MsowHD4R4GligLBINe8ygvIIjQ5F8Fzc4NbHbXOCtWovKDvaECrsDfhr5nUxKmXLH2FbCet53rxMoCKHaxCVOO1Ymk3CtfXgoWYbo6mjGrlYrVIZTyIEppJmEdEjgCL4(gwgnWYbjAHb3FLGDRme4i95dbnNDFdlJgy5GeTWG7VsWo0hF(umgKK9A5GwtlGGsXIJUVDfMOTe)BdIfk7tucTASnQBBk5yf2HVIdUGyuUjEsWJzujkGJyk)8FzcIbxjUVHLrdSCqIwyW9xjy3kdboY4nGGMZUVHLrdSCqIwyW9xjyh6JpFkgdsYETCqRPfqqPyXr33Uct0wI)TbXcL9jkHwnwF(WpdcdIr5MGDQi7Qa84IK6kUxInocAo7WcJ(9V9mQd9jUIXGKSxlh0AAbeukwC09TRWVqGtr2OpFEjgCL4(gwgnWYbjAHb3FLGDRme4i1TnLCSc7WxXbxqmk3epj4b84IK6kUacdk8FzcnGGMZoSWOF)BpJ6O7BxHFbprUId7WIP8hqqZ5r5BofjFJGMZoSWOF)BpJ6WIP87ZhcAo7WcJ(9V9mQd9jocAo7(gwgnWYbjAHb3FLGDOpnQBBk5yf2HVIdUGyuUjEsWJmLHLaoIP8Z)LjigCL4o1YOuVDRme4iJlgCL4(gwgnWYbjAHb3FLGDRme4iJJGMZUtTmk1Bh6tCe0C29nSmAGLds0cdU)kb7qF0TnLCSc7WxXbxqmk3epj4b0AAbeukw4)YeqqZzNHvRiTsnh6JUTPKJvyh(ko4cIr5M4jbpGwtlGGsXc)xMGIXGKSxRaDMsI7LyWvI7Byz0alhKOfgC)vc2TYqGJu32uYXkSdFfhCbXOCt8KGhNAzuQ38FzcIbxjUtTmk1B3kdboY4E1W3gelu2NO8PwhxXyqs2RLdAnTackflo6(2v4xi0sJ62MsowHD4R4GligLBINe8aAnTackfl8FzckgdsYETc0zkjUkYOCdtuXGRe3urSalhKOfgC)vc2TYqGJu32uYXkSdFfhCbXOCt8KGhzkdlbCet5N)ltqm4kXDQLrPE7wziWrghbnNDNAzuQ3o0N4iO5S7ulJs92r33Uc)cEICfh2Hft5pGGMZJY3Cks(gbnNDNAzuQ3oSyk)62MsowHD4R4GligLBINe8aAnTackfl8FzckgdsYETc0zkr32uYXkSdFfhCbXOCt8KGhzO9xahXu(5x5TcUGyuUjyc8Y)LjqxMoCKHaNUTPKJvyh(ko4cIr5M4jbpMrLOyIA(h)xMa(zqyqmk3eStfzxfGhxKuxXruEJ7ffTwMr5MBQi2WbwoWrNjbmAro6vCUft075zK(8HGMZUPIydhy5ahDMeWOf5OxX5qF0TnLCSc7WxXbxqmk3epj4rMYWsahXu(5)YeedUsCNAzuQ3UvgcCKXrqZz3PwgL6Td9jEdiO5S7ulJs92r33Uc)cNIKVjs(gbnNDNAzuQ3oSyk)(8HGMZoSWOF)BpJ6qF85ZlXGRe33WYObwoirlm4(ReSBLHahzJ62MsowHD4R4GligLBINe8itzyjGJyk)8Fzcu0AzgLBUb3FLyWWIj6bpe6H(DlMO3ZZiJ7fcAo7gC)vIbdlMOh8qOh6pqoe0C2H(e3lXGRe3G7VsmyabAyXTYqGJmUxIbxjUPIyxXfWrmLF3kdbosDBtjhRWo8vCWfeJYnXtcEOISRcrgT5WIUTPKJvyh(ko4cIr5M4jbpWIjNkqEyvKr5g)xMGyWvIdlMCQa5HvrgLBUvgcCK62MsowHD4R4GligLBINe8ygvIcdU)kXG8FzcEjgCL4EO33GHb3FLyWdlUvgcCK(851Zex(Olm4(Red6mLCnNUTPKJvyh(ko4cIr5M4jbpGhxKuxXfqyqr32uYXkSdFfhCbXOCt8KGhzO9xahXu(5)ZAEfhbE5x5TcUGyuUjyc8Y)LjqxMoCKHaNUTPKJvyh(ko4cIr5M4jbpYq7VaoIP8Z)N18koc8Y)Lj8zn3FL4ipSyLAeLV0TnLCSc7WxXbxqmk3epj4rMYWsahXu(5)ZAEfhbEb9MJIpwbEhBlX2cV8glVG(RgTUIdd6TI)dJkJuNATozk5yLobpSGD62Go8WcgqmOJVIdUGyuUjaIbV5fqmOVYqGJeWdOBk5yfONH2FbCet5h0v0tg9mqVbDYlDsoL)R40jF(0jsM4Yq7VaoIP87O7BxH1PxiOtCksDYNpDsm4kXzy1ksRuZTYqGJuNIRtKmXLH2FbCet53r33UcRtVOtnOtkgdsYETCgwTI0k1C09TRW6KN6ecAo7mSAfPvQ5irPMCSsNAuNIRtkgdsYETCgwTI0k1C09TRW60l6erQtnQtX1Pg0je0C2bTMwaJs5Md9rN85tN8sNqqZzhcKXiHOyXH(Otnc6kVvWfeJYnbdEZlqaVJfqmOVYqGJeWdORONm6zGUyWvIZWQvKwPMBLHahPofxNAqNK7pDIOe0j(QfDYNpDcbnNDiqgJeIIfh6Jo1OofxNAqNumgKK9A5GwtlGGsXIJUVDfwNiQo1Io1OofxNAqN8sNedUsCNAzuQ3UvgcCK6KpF6Kx6ecAo7o1YOuVDOp6uCDYlDsXyqs2RL7ulJs92H(Otnc6Msowb6gwTI0k1ac4nraig0xziWrc4b0v0tg9mqxm4kXn4(RedgqGgwCRme4i1P46ud6KyWvI7Byz0alhKOfgC)vc2TYqGJuNIRtnOtiO5S7Byz0alhKOfgC)vc2H(OtX1PVniwOSVo9IoXxTOt(8PtEPtiO5S7Byz0alhKOfgC)vc2H(OtnQt(8PtEPtIbxjUVHLrdSCqIwyW9xjy3kdbosDQrq3uYXkqFW9xjgmGanSaeWBIeqmOVYqGJeWdORONm6zGUyWvIdlm63)2ZOUvgcCK6uCDQbDIAhzynxjoJKe7um0s0Px0jIqN85tNO2rgwZvIZijXUR0jIQtTUfDQrDkUo1Go9TbXcL91Px0jIKi1PgbDtjhRaDSWOF)BpJceW7wdig0xziWrc4b0v0tg9mqxm4kXnve7kUaoIP87wziWrQtX1jfJbjzVwoO10ciOuS4O7BxH1PxiOtTa6Msowb6tfXUIlGJyk)ab8MVaed6Rme4ib8a6k6jJEgOlgCL4MkIDfxahXu(DRme4i1P46ecAo7MkIDfxahXu(DOpGUPKJvGo0AAbeukwac4nFcqmOVYqGJeWdORONm6zGUyWvIdEXe9idFJ7BbHj77wziWrc6Msowb6WlMOhz4BCFlimzFGaEZhbed6Rme4ib8a6k6jJEgOJGMZoSWOF)BpJ6qF0P46e(zqyqmk3eStfzxfGhxKuxXPtVOtXQtX1Pg0je0C29nSmAGLds0cdU)kb7qF0PgbDtjhRaD4Xfj1vCbeguac4DRcig0xziWrc4b0v0tg9mqhbnNDtfXgoWYbo6mjGrlYrVIZH(OtX1Pg0jV0jXGRe33WYObwoirlm4(ReSBLHahPo5ZNoHGMZUVHLrdSCqIwyW9xjyh6Jo1iOBk5yfOpJkrXe18pGaEZBlaIb9vgcCKaEaDf9Krpd0XpdcdIr5MGDQi7Qa84IK6koDIO6eV6uCDYlDIKjUm0(lGJyk)o6Y0HJme40P46Kx6efTwMr5MBQi2WbwoWrNjbmAro6vCUft075zK6uCDQbDYlDsm4kX9nSmAGLds0cdU)kb7wziWrQt(8PtiO5S7Byz0alhKOfgC)vc2H(Ot(8PtkgdsYETCqRPfqqPyXr33UcRtevNArNIRtFBqSqzFDIOe0PwnwDQrq3uYXkqFgvIIjQ5Fab8MxEbed6Rme4ib8a6k6jJEgOlgCL4(gwgnWYbjAHb3FLGDRme4i1P46ud6ecAo7(gwgnWYbjAHb3FLGDOp6KpF6KIXGKSxlh0AAbeukwC09TRW6er1Pw0P4603gelu2xNikbDQvJvN85tNWpdcdIr5MGDQi7Qa84IK6koD6fDkwDkUoHGMZoSWOF)BpJ6qF0P46KIXGKSxlh0AAbeukwC09TRW60le0jofPo1Oo5ZNo5LojgCL4(gwgnWYbjAHb3FLGDRme4ibDtjhRa9zujkGJyk)ab8M3ybed6Rme4ib8a6k6jJEgO3GoHGMZoSWOF)BpJ6O7BxH1Px0j8e5koSdlMYFabnNhvN4BDItrQt8ToHGMZoSWOF)BpJ6WIP8Rt(8PtiO5Sdlm63)2ZOo0hDkUoHGMZUVHLrdSCqIwyW9xjyh6Jo1iOBk5yfOdpUiPUIlGWGcqaV5Liaed6Rme4ib8a6k6jJEgOlgCL4o1YOuVDRme4i1P46KyWvI7Byz0alhKOfgC)vc2TYqGJuNIRtiO5S7ulJs92H(OtX1je0C29nSmAGLds0cdU)kb7qFaDtjhRa9mLHLaoIP8deWBEjsaXG(kdbosapGUIEYONb6iO5SZWQvKwPMd9b0nLCSc0HwtlGGsXcqaV5T1aIb9vgcCKaEaDf9Krpd0vmgKK9AfOZuIofxN8sNedUsCFdlJgy5GeTWG7VsWUvgcCKGUPKJvGo0AAbeukwac4nV8fGyqFLHahjGhqxrpz0ZaDXGRe3PwgL6TBLHahPofxN8sNAqN(2GyHY(6er1j(uR1P46KIXGKSxlh0AAbeukwC09TRW60le0Pw0PgbDtjhRa9tTmk1BGaEZlFcqmOVYqGJeWdORONm6zGUIXGKSxRaDMs0P46KkYOCdRtevNedUsCtfXcSCqIwyW9xjy3kdbosq3uYXkqhAnTackflab8Mx(iGyqFLHahjGhqxrpz0ZaDXGRe3PwgL6TBLHahPofxNqqZz3PwgL6Td9rNIRtiO5S7ulJs92r33UcRtVOt4jYvCyhwmL)acAopQoX36eNIuN4BDcbnNDNAzuQ3oSyk)GUPKJvGEMYWsahXu(bc4nVTkGyqFLHahjGhqxrpz0ZaDfJbjzVwb6mLa6Msowb6qRPfqqPybiG3X2cGyqFLHahjGhq3uYXkqpdT)c4iMYpORONm6zGoDz6WrgcCGUYBfCbXOCtWG38ceW7y5fqmOVYqGJeWdORONm6zGo(zqyqmk3eStfzxfGhxKuxXPtevN4vNIRtEPtu0AzgLBUPIydhy5ahDMeWOf5OxX5wmrVNNrQt(8PtiO5SBQi2WbwoWrNjbmAro6vCo0hq3uYXkqFgvIIjQ5Fab8o2ybed6Rme4ib8a6k6jJEgOlgCL4o1YOuVDRme4i1P46ecAo7o1YOuVDOp6uCDQbDcbnNDNAzuQ3o6(2vyD6fDItrQt8TorK6eFRtiO5S7ulJs92Hft5xN85tNqqZzhwy0V)TNrDOp6KpF6Kx6KyWvI7Byz0alhKOfgC)vc2TYqGJuNAe0nLCSc0Zugwc4iMYpqaVJLiaed6Rme4ib8a6k6jJEgOtrRLzuU5gC)vIbdlMOh8qOh63TyIEppJuNIRtEPtiO5SBW9xjgmSyIEWdHEO)a5qqZzh6JofxN8sNedUsCdU)kXGbeOHf3kdbosDkUo5LojgCL4MkIDfxahXu(DRme4ibDtjhRa9mLHLaoIP8deW7yjsaXGUPKJvGUkYUkez0MdlG(kdbosapab8o2wdig0xziWrc4b0v0tg9mqxm4kXHftovG8WQiJYn3kdbosq3uYXkqhlMCQa5HvrgLBab8ow(cqmOVYqGJeWdORONm6zGUx6KyWvI7HEFdggC)vIbpS4wziWrQt(8PtEPtptC5JUWG7VsmOZuY1CGUPKJvG(mQefgC)vIbbc4DS8jaXGUPKJvGo84IK6kUacdkG(kdbosapab8ow(iGyq)ZAEfh4nVG(kdbUWN18koapGUPKJvGEgA)fWrmLFqx5TcUGyuUjyWBEbDf9Krpd0PlthoYqGd0xziWrc4biG3X2QaIb9vgcCKaEa9vgcCHpR5vCaEaDf9Krpd0)SM7VsCKhwSsnDIO6eFb6Msowb6zO9xahXu(b9pR5vCG38ceWBIOfaXG(N18koWBEb9vgcCHpR5vCaEaDtjhRa9mLHLaoIP8d6Rme4ib8aeGa6KlBOqbqm4nVaIb9vgcCKaeqxrpz0ZaDJpp6jZzLAyHAWaDywzLAUvgcCKGUPKJvGocKXiHOybiG3Xcig0xziWrc4b0v0tg9mqpFCrsGUVDfwNErN4Rw0jF(0jfJbjzVwoouJsEwfy5GXNhLjro6(2vyD6fDIiAb0nLCSc0FyYXkGaEteaIbDtjhRa9xVImGJMrb9vgcCKaEac4nrcig0nLCSc0rXlCY(yqFLHahjGhGaE3AaXGUPKJvGE(Olm4(Redc6Rme4ib8aeWB(cqmOBk5yfOJfg9hgC)vIbb9vgcCKaEac4nFcqmOBk5yfORyLALqnzKHm0(d0xziWrc4biG38raXGUPKJvGocKXidSCqIwy1(Ed6Rme4ib8aeW7wfqmOBk5yfOZHAuYZQalhm(8Omjc0xziWrc4biG382cGyq3uYXkqpZuO4rgm(8ONSaYSpOVYqGJeWdqaV5LxaXGUPKJvG(dk9YEFfxabAyb0xziWrc4biG38glGyq3uYXkqxIwaTqyOfziZOQb6Rme4ib8aeWBEjcaXGUPKJvG(FFg17alhGOQJmqsN9XG(kdbosapab8MxIeqmOBk5yfOtVNh4cxfWpMAG(kdbosapab8M3wdig0nLCSc0FLrHKn3vb6WSYk1a9vgcCKaEac4nV8fGyqFLHahjGhqxrpz0ZaDXOCtCrZGsu4rj6er1j(yl6KpF6KyuUjUOzqjk8OeD6fDk2w0jF(0P8Xfjb6(2vyD6fDIiAb0nLCSc0PZEUIlKH2FyGaEZlFcqmOBk5yfOhnJkHHXRud0xziWrc4biG38Yhbed6Rme4ib8a6k6jJEgO7LojgCL4mSAfPvQ5wziWrQt(8PtiO5SZWQvKwPMd9rN85tNumgKK9A5mSAfPvQ5O7BxH1jIQtTUfq3uYXkqhbYyKHmk1BGaEZBRcig0xziWrc4b0v0tg9mq3lDsm4kXzy1ksRuZTYqGJuN85tNqqZzNHvRiTsnh6dOBk5yfOJmkEu)xXbeW7yBbqmOVYqGJeWdORONm6zGUx6KyWvIZWQvKwPMBLHahPo5ZNoHGMZodRwrALAo0hDYNpDsXyqs2RLZWQvKwPMJUVDfwNiQo16waDtjhRa98rhcKXibc4DS8cig0xziWrc4b0v0tg9mq3lDsm4kXzy1ksRuZTYqGJuN85tNqqZzNHvRiTsnh6Jo5ZNoPymij71Yzy1ksRuZr33UcRtevNADlGUPKJvGUvQHfQbdkdcbc4DSXcig0xziWrc4b0v0tg9mq3lDsm4kXzy1ksRuZTYqGJuN85tN8sNqqZzNHvRiTsnh6dOBk5yfOJyCbwoi0t5hdeW7yjcaXG(kdbosapGUPKJvG(d9(mk5zWWRwZb6k6jJEgO7LoHGMZUh69zuYZGHxTMZH(a6kVvWfeJYnbdEZlqaVJLibed6Msowb6nh(z0GWK9b9vgcCKaEac4DSTgqmOBk5yfONTfeQv4mk(yfOVYqGJeWdqaVJLVaed6Rme4ib8a6k6jJEgOBk5AUWQ9VH1jIQtXQtX1Pg0j8ZGWGyuUjyNkYUkapUiPUItNiQofRo5ZNoHFgegeJYnb7GwtlGm7RtevNIvNAe0nLCSc0POvWuYXQa8WcOdpSek7pq3ydiG3XYNaed6Rme4ib8a6k6jJEgO7LojgCL4WcJ(ddU)kXGUvgcCK6uCDYuY1CHv7FdRtVqqNIf0nLCSc0POvWuYXQa8WcOdpSek7pqhFfhCbXOCtac4DS8raXG(kdbosapGUIEYONb6IbxjoSWO)WG7VsmOBLHahPofxNmLCnxy1(3W60le0PybDtjhRaDkAfmLCSkapSa6WdlHY(d0XlGVIdUGyuUjabiG(dDk2hXeaXG38cig0xziWrc4b0l7pq34Z4iJA4qMvsGLdpSxhf0nLCSc0n(moYOgoKzLey5Wd71rbc4DSaIbDtjhRa9hMCSc0xziWrc4biab0n2aedEZlGyqFLHahjGhqxrpz0ZaDe0C2nve7kUaoIP87qFaDtjhRa9zujkMOM)beW7ybed6Msowb6Qi7QqKrBoSa6Rme4ib8aeWBIaqmOVYqGJeWdORONm6zGUyWvIdlm63)2ZOUvgcCKGUPKJvGowy0V)TNrbc4nrcig0xziWrc4b0nLCSc0Zq7VaoIP8d6k6jJEgOBk5AUajtCzO9xahXu(1Px0jIqNIRtMsUMlSA)ByD6fc6uR1jF(0jkATmJYnh2V3i0z(hfhY3OEhi3)WZTyIEppJe0vERGligLBcg8MxGaE3AaXG(kdbosapGUIEYONb6EPtMsUMlqYexgA)fWrmLFq3uYXkqpdT)c4iMYpqaV5laXG(kdbosapGUIEYONb6IbxjUPIyxXfWrmLF3kdbosDkUo9TbXcL91jIsqN4RwaDtjhRa9PIyxXfWrmLFGaEZNaed6Rme4ib8a6k6jJEgOlgCL4mSAfPvQ5wziWrQtX1Pg0jV0PNjoSWO)WG7VsmOZuY1C6uJ6uCDQbDYlDsm4kXDQLrPE7wziWrQt(8PtEPtiO5S7ulJs92H(OtX1jV0jfJbjzVwUtTmk1Bh6Jo1iOBk5yfOBy1ksRudiG38raXG(kdbosapGUIEYONb6Ibxjo4ft0Jm8nUVfeMSVBLHahjOBk5yfOdVyIEKHVX9TGWK9bc4DRcig0xziWrc4b0v0tg9mqNIwlZOCZnveB4alh4OZKagTih9ko3Ij698msDkUo5LoHGMZUPIydhy5ahDMeWOf5OxX5qFaDtjhRa9zujkGJyk)ab8M3waed6Rme4ib8a6k6jJEgOtrRLzuU5i3Ee6(mAalSAUft075zK6uCDQbDYlDsm4kX9qVVbddU)kXGhwCRme4i1jF(0Pg0jV0PNjoSWO)WG7VsmOZuY1C6uCDYlD6zIlF0fgC)vIbDMsUMtNAuNAe0nLCSc0NrLOWG7VsmiqaV5LxaXG(kdbosapGUPKJvGo0AAbeukwaDf9Krpd0XpdcdIr5MGDQi7Qa84IK6koD6fDIi1jF(0je0C2bTMwaJs5Md9rN85tNAqNedUsCFdlJgy5GeTWG7VsWUvgcCK6uCDYlDcbnNDFdlJgy5GeTWG7VsWo0hDkUo9TbXcL91jIsqN4Rw0PgbDL3k4cIr5MGbV5fiG38glGyqFLHahjGhqxrpz0ZaDV0jXGRe33WYObwoirlm4(ReSBLHahPo5ZNoHGMZoSWOF)BpJ6qF0jF(0PVniwOSVoruc6ud6eVT0IoXhQtePoX36e(zqyqmk3eStfzxfGhxKuxXPtnQt(8PtiO5S7Byz0alhKOfgC)vc2H(Ot(8Pt4NbHbXOCtWovKDvaECrsDfNoruDIiaDtjhRa9zujkMOM)beWBEjcaXG(kdbosapGUIEYONb6iO5Sdlm63)2ZOo6(2vyD6fDIi0j(wN4uK6eFRtiO5Sdlm63)2ZOoSyk)GUPKJvGUkYUkapUiPUIdiG38sKaIb9vgcCKaEaDf9Krpd0rqZzh0AAbmkLBo0hDkUoHFgegeJYnb7ur2vb4Xfj1vC60l6erQtX1Pg0jV0PNjoSWO)WG7VsmOZuY1C6uJ6uCDIKjUm0(lGJyk)o5u(VId0nLCSc0HwtlGGsXcqaV5T1aIb9vgcCKaEaDf9Krpd0fdUsCdU)kXGbeOHf3kdbosDkUoHFgegeJYnb7ur2vb4Xfj1vC60l6uR1P46ud6Kx60Zehwy0FyW9xjg0zk5AoDQrq3uYXkqFW9xjgmGanSaeWBE5laXGUPKJvGUkYUkapUiPUId0xziWrc4biG38YNaed6Rme4ib8a6Rme4cFwZR4a8a6k6jJEgOJGMZoO10cyuk3COp6uCDsXyqs2RvGotjGUPKJvGo0AAbeukwa9pR5vCG38ceWBE5JaIb9pR5vCG38c6Rme4cFwZR4a8a6Msowb6zO9xahXu(bDL3k4cIr5MGbV5f0v0tg9mqNUmD4idboqFLHahjGhGaEZBRcig0)SMxXbEZlOVYqGl8znVIdWdOBk5yfONPmSeWrmLFqFLHahjGhGaeqhVa(ko4cIr5Maig8MxaXG(kdbosapGUPKJvGEgA)fWrmLFqxrpz0Za9g0j6(2vyD6fc6eNIuNAuNIRtnOtiO5SdAnTagLYnh6Jo5ZNo5LoHGMZoeiJrcrXId9rNAe0vERGligLBcg8MxGaEhlGyqFLHahjGhqxrpz0ZaDXGRe3G7VsmyabAyXTYqGJe0nLCSc0hC)vIbdiqdlab8Miaed6Rme4ib8a6k6jJEgOlgCL4WcJ(9V9mQBLHahPofxNAqN(2GyHY(60l6ersK6uJGUPKJvGowy0V)TNrbc4nrcig0xziWrc4b0v0tg9mqxm4kXnve7kUaoIP87wziWrc6Msowb6tfXUIlGJyk)ab8U1aIb9vgcCKaEaDf9Krpd0rqZz3Rxrg4qXIdlMYVo9IoXlFuN85tNqqZzh0AAbmkLBo0hq3uYXkqhAnTackflab8MVaed6Rme4ib8a6k6jJEgOJGMZoSWOF)BpJ6qFaDtjhRaD4Xfj1vCbeguac4nFcqmOVYqGJeWdORONm6zGocAo7MkInCGLdC0zsaJwKJEfNd9b0nLCSc0NrLOyIA(hqaV5JaIb9vgcCKaEaDf9Krpd0BqNWpdcdIr5MGDQi7Qa84IK6koDIO6eV6uJ6uCDQbDYlDIKjUm0(lGJyk)o6Y0HJme40PgbDtjhRa9zujkMOM)beW7wfqmOVYqGJeWdORONm6zGo(zqyqmk3eStfzxfGhxKuxXPtVOtXQtX1PVniwOSVoruc6eF1IofxNAqNqqZz3Rxrg4qXIdlMYVo9IofBl6KpF603gelu2xNiQo1QTOtnc6Msowb6ZOsuahXu(bc4nVTaig0xziWrc4b0v0tg9mqVbDcbnNDyHr)(3Eg1r33UcRtVOt4jYvCyhwmL)acAopQoX36eNIuN4BDcbnNDyHr)(3Eg1Hft5xN85tNqqZzhwy0V)TNrDOp6uCDcbnNDFdlJgy5GeTWG7VsWo0hDQrq3uYXkqhECrsDfxaHbfGaEZlVaIb9vgcCKaEaDf9Krpd0fdUsCNAzuQ3UvgcCK6uCDsm4kX9nSmAGLds0cdU)kb7wziWrQtX1je0C2DQLrPE7qF0P46ecAo7(gwgnWYbjAHb3FLGDOpGUPKJvGEMYWsahXu(bc4nVXcig0xziWrc4b0v0tg9mqhbnNDgwTI0k1COpGUPKJvGo0AAbeukwac4nVebGyqFLHahjGhqxrpz0ZaDfJbjzVwb6mLOtX1jV0jXGRe33WYObwoirlm4(ReSBLHahjOBk5yfOdTMwabLIfGaEZlrcig0xziWrc4b0v0tg9mqxm4kXDQLrPE7wziWrQtX1jV0Pg0PVniwOSVoruDIp1ADkUoPymij71YbTMwabLIfhDF7kSo9cbDQfDQrq3uYXkq)ulJs9giG382AaXG(kdbosapGUIEYONb6kgdsYETc0zkrNIRtQiJYnSoruDsm4kXnvelWYbjAHb3FLGDRme4ibDtjhRaDO10ciOuSaeWBE5laXG(kdbosapGUIEYONb6IbxjUtTmk1B3kdbosDkUoHGMZUtTmk1Bh6dOBk5yfONPmSeWrmLFGaEZlFcqmOBk5yfORISRcrgT5WcOVYqGJeWdqaV5Lpcig0xziWrc4b0v0tg9mqxm4kXHftovG8WQiJYn3kdbosq3uYXkqhlMCQa5HvrgLBab8M3wfqmOVYqGJeWdORONm6zGUx6KyWvI7HEFdggC)vIbpS4wziWrQt(8PtIbxjUh69nyyW9xjg8WIBLHahPofxNAqN8sNEM4WcJ(ddU)kXGotjxZPtnc6Msowb6ZOsuyW9xjgeiG3X2cGyq3uYXkqhECrsDfxaHbfqFLHahjGhGaEhlVaIb9pR5vCG38c6Rme4cFwZR4a8a6Msowb6zO9xahXu(bDL3k4cIr5MGbV5f0v0tg9mqNUmD4idboqFLHahjGhGaEhBSaIb9vgcCKaEa9vgcCHpR5vCaEaDf9Krpd0)SM7VsCKhwSsnDIO6eFb6Msowb6zO9xahXu(b9pR5vCG38ceW7yjcaXG(N18koWBEb9vgcCHpR5vCaEaDtjhRa9mLHLaoIP8d6Rme4ib8aeGaeq3qLigf073hfAYXk(aullabiaa]] )

end
