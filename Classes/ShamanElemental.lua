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

    spec:RegisterPack( "Elemental", 20201208, [[dm0OwbqiuQEecj2Kq5tuvPsJsOQtPezvuvjVIQOzHs6wuvPQDrQFrvyyqGJHszzkr9mesnniOUgeKTrvf(MqLACiK05eQK1rvfLMheX9qW(GiTqeQhsvfPMivvuCrQQuojvveReIAMuvrLUjvvKSti0pPQIQEQsnvuIRsvLk2lO)kyWkCyklgOhtYKr0LL2SI(mkgTqoTQEnvPzRYTbSBr)gvdxjDCHkwosphQPtCDiTDLW3rigpvvuX5PQQ5tvz)uziBqwGBstkeXLrWYiGTLrarvZwCHWX9YXfCl(Vw4E1uEnMc3Pbu42VDfOPyhCVA(FCJeYcCJ5OuvH7irwX(z9WdMxIqb1koGh4ha9m55PIAtXd8dO8aUbr)t8tsiiCtAsHiUmcwgbSTmciQA2IleoUxoUHB8Avqex2pwgUJEsYMqq4MSyfCtuCd)2vGMIDUXoYaS0HmrXn8Zuvbal1niQS6glJGLrGdzhYef3WpDKLmf7N1HmrXn87Dd)KuXPRCQj1nWvKpzWASykVbq05Su3yYPUHFIQtuQ)S6gBHtb82UwQgUxP85FfUjkUHF7kqtXo3yhzaw6qMO4g(zQQaGL6gevwDJLrWYiWHSdzIIB4NoYsMI9Z6qMO4g(9UHFsQ40vo1K6g4kYNmynwmL3ai6CwQBm5u3Wpr1jk1FwDJTWPaEBxlv7q2HmrXn8B(5ufQus3Olk1F3qEG6gsuDdtjCQB8y3Wwy)zGx1oKnL88eRxPvXbanHqnQef6vGMIDS(tcSl21u0R0hWUqVc0uS7XIUPbEL0HmrXn87GRBSfofWB7APUXkTkoaOjUbAEfJDdmhOUHrsIDdI835g4vJiPBG58u7q2uYZtSELwfha0epj4bw4uaVTRLY6pji21u0yHtb82UwQUPbELmw8u7jdDrtrBKKyTIJMcsiAF(O2tg6IMI2ijX6prkcHGLCiBk55jwVsRIdaAINe8OxbAk2fapdlS(tcIDnfDVc0uSlaEgw0nnWRKoKnL88eRxPvXbanXtcEC2claIsXcR)Ka7IDnfDVc0uSlaEgw0nnWRKoKnL88eRxPvXbanXtcESYLNNoKDituCd)KukLIUkUbF6gkdlyTdztjppXEsWdI8jzahvJ6q2uYZtSNe8aV(0xiIDElfhyOMQScWx8jdb2CiBk55j2tcESYLNNoKnL88e7jbpqXn8sbWoKnL88e7jbpMpTHEfOPyNdztjppXEsWdSWPaHEfOPyNdztjppXEsWdWJZjdtuQ)S(tcSl21u0gw1K0sv1nnWRK(8bIoNAdRAsAPQA0vF(uC(rYjsQnSQjPLQQPfW(eJuecboKnL88e7jbpalfxQ3pzy9NeyxSRPOnSQjPLQQBAGxj95deDo1gw1K0sv1ORoKnL88e7jbpMpTGhNtY6pjWUyxtrByvtslvv30aVs6Zhi6CQnSQjPLQQrx95tX5hjNiP2WQMKwQQMwa7tmsrie4q2uYZtSNe8WsvXc1UGYUJ1FsGDXUMI2WQMKwQQUPbEL0Npq05uByvtslvvJU6ZNIZpsorsTHvnjTuvnTa2NyKIqiWHSPKNNypj4bOXe4ZGqFLxmR)Ka7IDnfTHvnjTuvDtd8kPpFSdIoNAdRAsAPQA0vhYoKnL88e7jbpwPpaNs(2fiITOSQ8xDnigLPcMaBS(tcSdIoN6v6dWPKVDbIylQgD1HSPKNNypj4XIIxlniCPaoKnL88e7jbpMwdc1s8ef)80HSdztjppXEsWdkAgmL88mCpwynnGsW4L1FsWuYVOHMf4lgPlhlE8AVligLPcwRISpd3Zej5NmiDzF(WR9UGyuMky9zlSaynaKU8soKnL88e7jbpOOzWuYZZW9yH10akb8NmxdIrzQW6pjWUyxtrJfofi0Ranf70nnWRKXmL8lAOzb(IrcHLDiBk55j2tcEqrZGPKNNH7XcRPbuc4gWFYCnigLPcR)KGyxtrJfofi0Ranf70nnWRKXmL8lAOzb(IrcHLDi7q2uYZtS24LqnQefhuZBz9NearNtDvr8pzc4iUYRgD1HSPKNNyTXRNe8qfzFgIm6IIfhYMsEEI1gVEsWdSWPaEBxlL1FsqSRPOXcNc4TDTuDtd8kPdztjppXAJxpj4X8mGgWrCLxwv(RUgeJYubtGnw)jbtj)Igi5IEEgqd4iUYlsi6yMs(fn0SaFXiHac5Zhfn7KtzQg71FqAnVLIdZVu)dKf4Xv34G(RRL0HSPKNNyTXRNe8yEgqd4iUYlR)Ka7Ms(fnqYf98mGgWrCLxhYMsEEI1gVEsWJQI4FYeWrCLxw)jbXUMIUQi(NmbCex5v30aVsgdW6HfkhaPe8de4q2uYZtS241tcEyyvtslvL1FsqSRPOnSQjPLQQBAGxjJfp7Rv0yHtbc9kqtXoTPKFrxkw8Sl21u0VQtuQ)6Mg4vsF(yheDo1VQtuQ)A01ySR48JKtKu)QorP(RrxxYHSPKNNyTXRNe84(4G(KbaJbWccxkaR)KGyxtrFFCqFYaGXaybHlfq30aVs6q2uYZtS241tcEuJkrbCex5L1FsGIMDYPmvxveV4aFgyO1Kagnjl9tgDJd6VUwYySdIoN6QI4fh4ZadTMeWOjzPFYOrxDiBk55jwB86jbpQrLOqVc0uSJ1FsGIMDYPmvt2Uk0cWPbSWZQBCq)11sglE2f7Ak6v6dyxOxbAk29yr30aVs6Zx8SVwrJfofi0Ranf70Ms(fng7Rv0ZN2qVc0uStBk5x0LwYHSPKNNyTXRNe84SfwaeLIfwv(RUgeJYubtGnw)jb8AVligLPcwRISpd3Zej5NmibH95deDo1NTWcyukt1OR(8fVyxtrdyyP0aFgKOg6vGMcw30aVsgJDq05udyyP0aFgKOg6vGMcwJUgdW6HfkhaPe8deSKdzIIBWc1F3q4UbJbu3WVzujkoOM36ge5Li3WpLHLsDd(0nKO6g(TRanfSBaIoNUbrIA6gZNjs(KXniA3qmktfS2n8ZWt)UIBWxuQYwDd)uwpSq5aS7q2uYZtS241tcEuJkrXb18ww)jb2f7AkAadlLg4ZGe1qVc0uW6Mg4vsF(arNtnw4uaVTRLQrx95dW6HfkhaPeINneGa)Ee2VWR9UGyuMkyTkY(mCptKKFYSKpFGOZPgWWsPb(mirn0RanfSgD1Np8AVligLPcwRISpd3Zej5NmiLODituCd)uM36gyuADd)5OUbjp97kUXXX1nm3ylCkG321sDdq05u7q2uYZtS241tcEOISpd3Zej5NmS(tcGOZPglCkG321s10cyFIrcr7xmks)ceDo1yHtb82UwQglMYRdzIIB4Npp)DdLHf3WpxBH5geJsXIBWt3qIOTUHyuMky34NUXlUXJDdlDJpXILIByjPBSfofWn8BxbAk25gp2nq0pplUHPKFr1oKnL88eRnE9KGhNTWcGOuSW6pjaIoN6ZwybmkLPA01y41ExqmktfSwfzFgUNjsYpzqcchlE2xROXcNce6vGMIDAtj)IUumsUONNb0aoIR8QLx59tghYef3WVdUUHF7kqtXo3G4ZWIBym2NyXnqxDdH7geTBigLPc2nmSBC8KXnmSBSfofWn8BxbAk25gp2nsU4gMs(fv7q2uYZtS241tcE0Ranf7cGNHfw)jbXUMIUxbAk2fapdl6Mg4vYy41ExqmktfSwfzFgUNjsYpzqccflE2xROXcNce6vGMIDAtj)IUKdztjppXAJxpj4XzlSaynaw)jbXUMI2WQMKwQQUPbEL0HSPKNNyTXRNe8qfzFgUNjsYpzCiBk55jwB86jbpoBHfarPyHva(IpziWgR)Kai6CQpBHfWOuMQrxJP48JKtKmqRPehYMsEEI1gVEsWJ5zanGJ4kVScWx8jdb2yv5V6Aqmktfmb2y9NeODsloYaV6q2uYZtS241tcEmPCSeWrCLxwb4l(KHaBoKDiBk55jwJBa)jZ1GyuMkeMNb0aoIR8YQYF11GyuMkycSX6pjepTa2NyKqGrrUuS4brNt9zlSagLYun6QpFSdIoNAWJZjpuSOrxxYHSPKNNynUb8NmxdIrzQ4jbp6vGMIDbWZWcR)KGyxtr3Ranf7cGNHfDtd8kPdztjppXACd4pzUgeJYuXtcEGfofWB7APS(tcIDnfnw4uaVTRLQBAGxjJfpG1dluoasqyeEjhYMsEEI14gWFYCnigLPINe8OQi(NmbCex5L1FsqSRPORkI)jtahXvE1nnWRKoKnL88eRXnG)K5Aqmktfpj4XzlSaikflS(tcGOZPMiFsgyqXIglMYlsyJO6Zhi6CQpBHfWOuMQrxDiBk55jwJBa)jZ1GyuMkEsWJ7zIK8tMai)ew)jbq05uJfofWB7APA0vhYMsEEI14gWFYCnigLPINe8OgvIIdQ5TS(tcGOZPUQiEXb(mWqRjbmAsw6NmA0vhYMsEEI14gWFYCnigLPINe8OgvIIdQ5TS(tcXJx7DbXOmvWAvK9z4EMij)KbPSTuS4zNKl65zanGJ4kVAAN0IJmWRl5q2uYZtSg3a(tMRbXOmv8KGh1OsuahXvEz9NeWR9UGyuMkyTkY(mCptKKFYGKLJby9WcLdGuc(bcIfpi6CQjYNKbguSOXIP8IKLrGpFawpSq5ainUqWsoKnL88eRXnG)K5Aqmktfpj4X9mrs(jtaKFcR)Kq8GOZPglCkG321s10cyFIrcUI8jdwJft5naIoNL6xmks)ceDo1yHtb82UwQglMYRpFGOZPglCkG321s1ORXarNtnGHLsd8zqIAOxbAkyn66soKnL88eRXnG)K5Aqmktfpj4XKYXsahXvEz9Nee7Ak6x1jk1FDtd8kzmXUMIgWWsPb(mirn0RanfSUPbELmgi6CQFvNOu)1ORXarNtnGHLsd8zqIAOxbAkyn6QdztjppXACd4pzUgeJYuXtcEC2claIsXcR)Kai6CQnSQjPLQQrxDiBk55jwJBa)jZ1GyuMkEsWJZwybqukwy9NeuC(rYjsgO1usm2f7AkAadlLg4ZGe1qVc0uW6Mg4vshYMsEEI14gWFYCnigLPINe84vDIs9N1FsqSRPOFvNOu)1nnWRKXypEaRhwOCaKg3iumfNFKCIK6Zwybqukw00cyFIrcbeSKdztjppXACd4pzUgeJYuXtcEC2claIsXcR)KGIZpsorYaTMsIPImktXivSRPORkIh4ZGe1qVc0uW6Mg4vshYMsEEI14gWFYCnigLPINe8ys5yjGJ4kVS(tcIDnf9R6eL6VUPbELmgi6CQFvNOu)1ORoKnL88eRXnG)K5Aqmktfpj4HkY(mez0ffloKnL88eRXnG)K5Aqmktfpj4bwm5vbYhRImktz9Nee7AkASyYRcKpwfzuMQBAGxjDiBk55jwJBa)jZ1GyuMkEsWJAujk0Ranf7y9NeyxSRPOxPpGDHEfOPy3JfDtd8kPpFIDnf9k9bSl0Ranf7ESOBAGxjJfp7Rv0yHtbc9kqtXoTPKFrxYHSPKNNynUb8NmxdIrzQ4jbpUNjsYpzcG8tCiBk55jwJBa)jZ1GyuMkEsWJ5zanGJ4kVScWx8jdb2yv5V6Aqmktfmb2y9NeODsloYaV6q2uYZtSg3a(tMRbXOmv8KGhZZaAahXvEzfGV4tgcSX6pjaWxuGMIM8XILQIu)WHSPKNNynUb8NmxdIrzQ4jbpMuowc4iUYlRa8fFYqGnhYoKnL88eRXFYCnigLPcH5zanGJ4kVSQ8xDnigLPcMaBS(tcXZU8kVFY4Zhjx0ZZaAahXvE10cyFIrcbgfPpFIDnfTHvnjTuvDtd8kzmsUONNb0aoIR8QPfW(eJK4vC(rYjsQnSQjPLQQPfW(e7ji6CQnSQjPLQQjrPM88CPyko)i5ej1gw1K0sv10cyFIrccVuS4brNt9zlSagLYun6QpFSdIoNAWJZjpuSOrxxYHSPKNNyn(tMRbXOmv8KGhgw1K0svz9Nee7AkAdRAsAPQ6Mg4vYyXlpqrkb)ab(8bIoNAWJZjpuSOrxxkw8ko)i5ej1NTWcGOuSOPfW(eJueSuS4zxSRPOFvNOu)1nnWRK(8Xoi6CQFvNOu)1ORXyxX5hjNiP(vDIs9xJUUKdztjppXA8NmxdIrzQ4jbp6vGMIDbWZWcR)KGyxtr3Ranf7cGNHfDtd8kzS4f7AkAadlLg4ZGe1qVc0uW6Mg4vYyXdIoNAadlLg4ZGe1qVc0uWA01yawpSq5aiXpqGpFSdIoNAadlLg4ZGe1qVc0uWA01L85JDXUMIgWWsPb(mirn0RanfSUPbELCjhYMsEEI14pzUgeJYuXtcEGfofWB7APS(tcIDnfnw4uaVTRLQBAGxjJfp1EYqx0u0gjjwR4OPGeI2NpQ9KHUOPOnssS(tKIqiyPyXdy9WcLdGeegHxYHSPKNNyn(tMRbXOmv8KGhvfX)KjGJ4kVS(tcIDnfDvr8pzc4iUYRUPbELmMIZpsors9zlSaikflAAbSpXiHacCiBk55jwJ)K5Aqmktfpj4XzlSaikflS(tcIDnfDvr8pzc4iUYRUPbELmgi6CQRkI)jtahXvE1ORoKnL88eRXFYCnigLPINe84(4G(KbaJbWccxkaR)KGyxtrFFCqFYaGXaybHlfq30aVs6q2uYZtSg)jZ1GyuMkEsWJ7zIK8tMai)ew)jbq05uJfofWB7APA01y41ExqmktfSwfzFgUNjsYpzqYYXIheDo1agwknWNbjQHEfOPG1ORl5q2uYZtSg)jZ1GyuMkEsWJAujkoOM3Y6pjaIoN6QI4fh4ZadTMeWOjzPFYOrxJfp7IDnfnGHLsd8zqIAOxbAkyDtd8kPpFGOZPgWWsPb(mirn0RanfSgDDjhYMsEEI14pzUgeJYuXtcEuJkrXb18ww)jb8AVligLPcwRISpd3Zej5NmiLTyStYf98mGgWrCLxnTtAXrg41yStrZo5uMQRkIxCGpdm0AsaJMKL(jJUXb9xxlzS4zxSRPObmSuAGpdsud9kqtbRBAGxj95deDo1agwknWNbjQHEfOPG1OR(8P48JKtKuF2claIsXIMwa7tmsrqmaRhwOCaKsiUwEjhYMsEEI14pzUgeJYuXtcEuJkrbCex5L1FsqSRPObmSuAGpdsud9kqtbRBAGxjJfpi6CQbmSuAGpdsud9kqtbRrx95tX5hjNiP(SfwaeLIfnTa2NyKIGyawpSq5aiLqCTSpF41ExqmktfSwfzFgUNjsYpzqYYXarNtnw4uaVTRLQrxJP48JKtKuF2claIsXIMwa7tmsiWOixYNp2f7AkAadlLg4ZGe1qVc0uW6Mg4vshYMsEEI14pzUgeJYuXtcECptKKFYea5NW6pjepi6CQXcNc4TDTunTa2NyKGRiFYG1yXuEdGOZzP(fJI0VarNtnw4uaVTRLQXIP86Zhi6CQXcNc4TDTun6Amq05udyyP0aFgKOg6vGMcwJUUKdztjppXA8NmxdIrzQ4jbpMuowc4iUYlR)KGyxtr)QorP(RBAGxjJj21u0agwknWNbjQHEfOPG1nnWRKXarNt9R6eL6VgDngi6CQbmSuAGpdsud9kqtbRrxDiBk55jwJ)K5Aqmktfpj4XzlSaikflS(tcGOZP2WQMKwQQgD1HSPKNNyn(tMRbXOmv8KGhNTWcGOuSW6pjO48JKtKmqRPKySl21u0agwknWNbjQHEfOPG1nnWRKoKnL88eRXFYCnigLPINe84vDIs9N1FsqSRPOFvNOu)1nnWRKXypEaRhwOCaKg3iumfNFKCIK6Zwybqukw00cyFIrcbeSKdztjppXA8NmxdIrzQ4jbpoBHfarPyH1FsqX5hjNizGwtjXurgLPyKk21u0vfXd8zqIAOxbAkyDtd8kPdztjppXA8NmxdIrzQ4jbpMuowc4iUYlR)KGyxtr)QorP(RBAGxjJbIoN6x1jk1Fn6Amq05u)QorP(RPfW(eJeCf5tgSglMYBaeDol1VyuK(fi6CQFvNOu)1yXuEDiBk55jwJ)K5Aqmktfpj4XzlSaikflS(tcko)i5ejd0AkXHSPKNNyn(tMRbXOmv8KGhZZaAahXvEzv5V6Aqmktfmb2y9NeODsloYaV6q2uYZtSg)jZ1GyuMkEsWJAujkoOM3Y6pjGx7DbXOmvWAvK9z4EMij)KbPSfJDkA2jNYuDvr8Id8zGHwtcy0KS0pz0noO)6Aj95deDo1vfXloWNbgAnjGrtYs)KrJU6q2uYZtSg)jZ1GyuMkEsWJjLJLaoIR8Y6pji21u0VQtuQ)6Mg4vYyGOZP(vDIs9xJUglEq05u)QorP(RPfW(eJegfPFHW(fi6CQFvNOu)1yXuE95deDo1yHtb82UwQgD1Np2f7AkAadlLg4ZGe1qVc0uW6Mg4vYLCiBk55jwJ)K5Aqmktfpj4XKYXsahXvEz9NeOOzNCkt19kqtXUqJd6Fpi9rb0noO)6AjJXoi6CQ7vGMIDHgh0)Eq6Jceili6CQrxJXUyxtr3Ranf7cGNHfDtd8kzm2f7Ak6QI4FYeWrCLxDtd8kPdztjppXA8NmxdIrzQ4jbpur2NHiJUOyXHSPKNNyn(tMRbXOmv8KGhyXKxfiFSkYOmL1FsqSRPOXIjVkq(yvKrzQUPbEL0HSPKNNyn(tMRbXOmv8KGh1OsuOxbAk2X6pjWUyxtrVsFa7c9kqtXUhl6Mg4vsF(yFTIE(0g6vGMIDAtj)I6q2uYZtSg)jZ1GyuMkEsWJ7zIK8tMai)ehYMsEEI14pzUgeJYuXtcEmpdObCex5Lva(IpziWgRk)vxdIrzQGjWgR)KaTtAXrg4vhYMsEEI14pzUgeJYuXtcEmpdObCex5Lva(IpziWgR)KaaFrbAkAYhlwQks9dhYMsEEI14pzUgeJYuXtcEmPCSeWrCLxwb4l(KHaBW9IsXppHiUmcwgbSTmcqi4Mign)Kbd3(jaRCQus3aHCdtjppDJ7Xcw7qgUVhlyilWn(tMRbXOmvGSarKnilWDtd8kjKy42uYZt4EEgqd4iUYlCROVu6BWD8Ub7UH8kVFY4g(85gKCrppdObCex5vtlG9j2nqcb3Grr6g(85gIDnfTHvnjTuvDtd8kPBeZni5IEEgqd4iUYRMwa7tSBGe3iE3qX5hjNiP2WQMKwQQMwa7tSB4PBaIoNAdRAsAPQAsuQjppDJLCJyUHIZpsorsTHvnjTuvnTa2Ny3ajUbc7gl5gXCJ4Ddq05uF2clGrPmvJU6g(85gS7gGOZPg84CYdflA0v3yj4w5V6Aqmktfmer2GceXLHSa3nnWRKqIHBf9LsFdUf7AkAdRAsAPQ6Mg4vs3iMBeVBipqDdKsWn8de4g(85gGOZPg84CYdflA0v3yj3iMBeVBO48JKtKuF2claIsXIMwa7tSBGu3abUXsUrm3iE3GD3qSRPOFvNOu)1nnWRKUHpFUb7Ubi6CQFvNOu)1ORUrm3GD3qX5hjNiP(vDIs9xJU6glb3MsEEc3gw1K0svHcerIgYcC30aVscjgUv0xk9n4wSRPO7vGMIDbWZWIUPbEL0nI5gX7gIDnfnGHLsd8zqIAOxbAkyDtd8kPBeZnI3narNtnGHLsd8zqIAOxbAkyn6QBeZnaSEyHYbCdK4g(bcCdF(Cd2Ddq05udyyP0aFgKOg6vGMcwJU6gl5g(85gS7gIDnfnGHLsd8zqIAOxbAkyDtd8kPBSeCBk55jC3Ranf7cGNHfOareHHSa3nnWRKqIHBf9LsFdUf7AkASWPaEBxlv30aVs6gXCJ4DdQ9KHUOPOnssSwXrtXnqIBq0UHpFUb1EYqx0u0gjjw)PBGu3aHqGBSKBeZnI3naSEyHYbCdK4gimc7glb3MsEEc3yHtb82UwkuGiIqqwG7Mg4vsiXWTI(sPVb3IDnfDvr8pzc4iUYRUPbEL0nI5gko)i5ej1NTWcGOuSOPfW(e7giHGBGa42uYZt4UQi(NmbCex5fkqe9dilWDtd8kjKy4wrFP03GBXUMIUQi(NmbCex5v30aVs6gXCdq05uxve)tMaoIR8QrxHBtjppH7ZwybqukwGceX4gYcC30aVscjgUv0xk9n4wSRPOVpoOpzaWyaSGWLcOBAGxjHBtjppH77Jd6tgamgaliCPaqbIirfYcC30aVscjgUv0xk9n4geDo1yHtb82UwQgD1nI5g41ExqmktfSwfzFgUNjsYpzCdK4gl7gXCJ4Ddq05udyyP0aFgKOg6vGMcwJU6glb3MsEEc33Zej5Nmbq(jqbIyCbzbUBAGxjHed3k6lL(gCdIoN6QI4fh4ZadTMeWOjzPFYOrxDJyUr8Ub7UHyxtrdyyP0aFgKOg6vGMcw30aVs6g(85gGOZPgWWsPb(mirn0RanfSgD1nwcUnL88eURrLO4GAEluGiYgcGSa3nnWRKqIHBf9LsFdUXR9UGyuMkyTkY(mCptKKFY4gi1nyZnI5gS7gKCrppdObCex5vt7KwCKbE1nI5gS7gu0StoLP6QI4fh4ZadTMeWOjzPFYOBCq)11s6gXCJ4Dd2DdXUMIgWWsPb(mirn0RanfSUPbEL0n85ZnarNtnGHLsd8zqIAOxbAkyn6QB4ZNBO48JKtKuF2claIsXIMwa7tSBGu3abUrm3aW6HfkhWnqkb3iUw2nwcUnL88eURrLO4GAEluGiYgBqwG7Mg4vsiXWTI(sPVb3IDnfnGHLsd8zqIAOxbAkyDtd8kPBeZnI3narNtnGHLsd8zqIAOxbAkyn6QB4ZNBO48JKtKuF2claIsXIMwa7tSBGu3abUrm3aW6HfkhWnqkb3iUw2n85ZnWR9UGyuMkyTkY(mCptKKFY4giXnw2nI5gGOZPglCkG321s1ORUrm3qX5hjNiP(SfwaeLIfnTa2Ny3ajeCdgfPBSKB4ZNBWUBi21u0agwknWNbjQHEfOPG1nnWRKWTPKNNWDnQefWrCLxOarKTLHSa3nnWRKqIHBf9LsFdUJ3narNtnw4uaVTRLQPfW(e7giXnWvKpzWASykVbq05Su3WVCdgfPB4xUbi6CQXcNc4TDTunwmLx3WNp3aeDo1yHtb82UwQgD1nI5gGOZPgWWsPb(mirn0RanfSgD1nwcUnL88eUVNjsYpzcG8tGcer2iAilWDtd8kjKy4wrFP03GBXUMI(vDIs9x30aVs6gXCdXUMIgWWsPb(mirn0RanfSUPbEL0nI5gGOZP(vDIs9xJU6gXCdq05udyyP0aFgKOg6vGMcwJUc3MsEEc3tkhlbCex5fkqezdHHSa3nnWRKqIHBf9LsFdUbrNtTHvnjTuvn6kCBk55jCF2claIsXcuGiYgcbzbUBAGxjHed3k6lL(gCR48JKtKmqRPe3iMBWUBi21u0agwknWNbjQHEfOPG1nnWRKWTPKNNW9zlSaikflqbIiB(bKf4UPbELesmCROVu6BWTyxtr)QorP(RBAGxjDJyUb7Ur8UbG1dluoGBGu3iUri3iMBO48JKtKuF2claIsXIMwa7tSBGecUbcCJLGBtjppH7x1jk1FOarKT4gYcC30aVscjgUv0xk9n4wX5hjNizGwtjUrm3qfzuMIDdK6gIDnfDvr8aFgKOg6vGMcw30aVsc3MsEEc3NTWcGOuSafiISruHSa3nnWRKqIHBf9LsFdUf7Ak6x1jk1FDtd8kPBeZnarNt9R6eL6VgD1nI5gGOZP(vDIs9xtlG9j2nqIBGRiFYG1yXuEdGOZzPUHF5gmks3WVCdq05u)QorP(RXIP8c3MsEEc3tkhlbCex5fkqezlUGSa3nnWRKqIHBf9LsFdUvC(rYjsgO1ucCBk55jCF2claIsXcuGiUmcGSa3nnWRKqIHBtjppH75zanGJ4kVWTI(sPVb30oPfhzGxHBL)QRbXOmvWqezdkqexMnilWDtd8kjKy4wrFP03GB8AVligLPcwRISpd3Zej5NmUbsDd2CJyUb7Ubfn7KtzQUQiEXb(mWqRjbmAsw6Nm6gh0FDTKUHpFUbi6CQRkIxCGpdm0AsaJMKL(jJgDfUnL88eURrLO4GAEluGiU8YqwG7Mg4vsiXWTI(sPVb3IDnf9R6eL6VUPbEL0nI5gGOZP(vDIs9xJU6gXCJ4Ddq05u)QorP(RPfW(e7giXnyuKUHF5giSB4xUbi6CQFvNOu)1yXuEDdF(Cdq05uJfofWB7APA0v3WNp3GD3qSRPObmSuAGpdsud9kqtbRBAGxjDJLGBtjppH7jLJLaoIR8cfiIlt0qwG7Mg4vsiXWTI(sPVb3u0StoLP6EfOPyxOXb9VhK(Oa6gh0FDTKUrm3GD3aeDo19kqtXUqJd6Fpi9rbcKfeDo1ORUrm3GD3qSRPO7vGMIDbWZWIUPbEL0nI5gS7gIDnfDvr8pzc4iUYRUPbELeUnL88eUNuowc4iUYluGiUmcdzbUnL88eUvr2NHiJUOybUBAGxjHedfiIlJqqwG7Mg4vsiXWTI(sPVb3IDnfnwm5vbYhRImkt1nnWRKWTPKNNWnwm5vbYhRImktHceXL9dilWDtd8kjKy4wrFP03GB2DdXUMIEL(a2f6vGMIDpw0nnWRKUHpFUb7UXAf98Pn0Ranf70Ms(ffUnL88eURrLOqVc0uSdkqexoUHSa3MsEEc33Zej5Nmbq(jWDtd8kjKyOarCzIkKf4gGV4tgiISb3nnWRba(IpzGed3MsEEc3ZZaAahXvEHBL)QRbXOmvWqezdUv0xk9n4M2jT4id8kC30aVscjgkqexoUGSa3nnWRKqIH7Mg41aaFXNmqIHBf9LsFdUb4lkqtrt(yXsvDdK6g(bCBk55jCppdObCex5fUb4l(KbIiBqbIirJailWnaFXNmqezdUBAGxda8fFYajgUnL88eUNuowc4iUYlC30aVscjgkqbUj70qpbYcer2GSa3MsEEc3e5tYaoQgfUBAGxjHedfiIldzbUb4l(KbIiBWDtd8AaGV4tgiXWTPKNNWnE9PVqe78wkoWqnvH7Mg4vsiXqbIirdzbUnL88eUx5YZt4UPbELesmuGiIWqwGBtjppHBuCdVuamC30aVscjgkqeriilWTPKNNW98Pn0Ranf7G7Mg4vsiXqbIOFazbUnL88eUXcNce6vGMIDWDtd8kjKyOarmUHSa3nnWRKqIHBf9LsFdUz3ne7AkAdRAsAPQ6Mg4vs3WNp3aeDo1gw1K0sv1ORUHpFUHIZpsorsTHvnjTuvnTa2Ny3aPUbcHa42uYZt4g84CYWeL6puGisuHSa3nnWRKqIHBf9LsFdUz3ne7AkAdRAsAPQ6Mg4vs3WNp3aeDo1gw1K0sv1ORWTPKNNWnyP4s9(jduGigxqwG7Mg4vsiXWTI(sPVb3S7gIDnfTHvnjTuvDtd8kPB4ZNBaIoNAdRAsAPQA0v3WNp3qX5hjNiP2WQMKwQQMwa7tSBGu3aHqaCBk55jCpFAbpoNekqezdbqwG7Mg4vsiXWTI(sPVb3S7gIDnfTHvnjTuvDtd8kPB4ZNBaIoNAdRAsAPQA0v3WNp3qX5hjNiP2WQMKwQQMwa7tSBGu3aHqaCBk55jCBPQyHAxqz3bfiISXgKf4UPbELesmCROVu6BWn7UHyxtrByvtslvv30aVs6g(85gS7gGOZP2WQMKwQQgDfUnL88eUbnMaFge6R8IHcer2wgYcC30aVscjgUnL88eUxPpaNs(2fiITOWTI(sPVb3S7gGOZPEL(aCk5BxGi2IQrxHBL)QRbXOmvWqezdkqezJOHSa3MsEEc3lkET0GWLca3nnWRKqIHcer2qyilWTPKNNW90AqOwINO4NNWDtd8kjKyOarKnecYcC30aVscjgUv0xk9n42uYVOHMf4l2nqQBSSBeZnI3nWR9UGyuMkyTkY(mCptKKFY4gi1nw2n85ZnWR9UGyuMky9zlSayna3aPUXYUXsWTPKNNWnfndMsEEgUhlW99yjKgqHBJxOarKn)aYcC30aVscjgUv0xk9n4MD3qSRPOXcNce6vGMID6Mg4vs3iMByk5x0qZc8f7giHGBSmCBk55jCtrZGPKNNH7XcCFpwcPbu4g)jZ1GyuMkqbIiBXnKf4UPbELesmCROVu6BWTyxtrJfofi0Ranf70nnWRKUrm3WuYVOHMf4l2nqcb3yz42uYZt4MIMbtjppd3Jf4(ESesdOWnUb8NmxdIrzQafOa3R0Q4aGMazbIiBqwG7Mg4vsiXWTI(sPVb3S7gIDnf9k9bSl0Ranf7ESOBAGxjHBtjppH7Aujk0Ranf7GceXLHSa3nnWRKqIHBf9LsFdUf7AkASWPaEBxlv30aVs6gXCJ4DdQ9KHUOPOnssSwXrtXnqIBq0UHpFUb1EYqx0u0gjjw)PBGu3aHqGBSeCBk55jCJfofWB7APqbIirdzbUBAGxjHed3k6lL(gCl21u09kqtXUa4zyr30aVsc3MsEEc39kqtXUa4zybkqeryilWDtd8kjKy4wrFP03GB2DdXUMIUxbAk2fapdl6Mg4vs42uYZt4(SfwaeLIfOareHGSa3MsEEc3RC55jC30aVscjgkqbUnEHSarKnilWDtd8kjKy4wrFP03GBq05uxve)tMaoIR8QrxHBtjppH7AujkoOM3cfiIldzbUnL88eUvr2NHiJUOybUBAGxjHedfiIenKf4UPbELesmCROVu6BWTyxtrJfofWB7AP6Mg4vs42uYZt4glCkG321sHceregYcC30aVscjgUnL88eUNNb0aoIR8c3k6lL(gCBk5x0ajx0ZZaAahXvEDdK4geTBeZnmL8lAOzb(IDdKqWnqi3WNp3GIMDYPmvJ96piTM3sXH5xQ)bYc84QBCq)11sc3k)vxdIrzQGHiYguGiIqqwG7Mg4vsiXWTI(sPVb3S7gMs(fnqYf98mGgWrCLx42uYZt4EEgqd4iUYluGi6hqwG7Mg4vsiXWTI(sPVb3IDnfDvr8pzc4iUYRUPbEL0nI5gawpSq5aUbsj4g(bcGBtjppH7QI4FYeWrCLxOarmUHSa3nnWRKqIHBf9LsFdUf7AkAdRAsAPQ6Mg4vs3iMBeVBWUBSwrJfofi0Ranf70Ms(f1nwYnI5gX7gS7gIDnf9R6eL6VUPbEL0n85Zny3narNt9R6eL6VgD1nI5gS7gko)i5ej1VQtuQ)A0v3yj42uYZt42WQMKwQkuGisuHSa3nnWRKqIHBf9LsFdUf7Ak67Jd6tgamgaliCPa6Mg4vs42uYZt4((4G(KbaJbWccxkauGigxqwG7Mg4vsiXWTI(sPVb3u0StoLP6QI4fh4ZadTMeWOjzPFYOBCq)11s6gXCd2Ddq05uxveV4aFgyO1Kagnjl9tgn6kCBk55jCxJkrbCex5fkqezdbqwG7Mg4vsiXWTI(sPVb3u0StoLPAY2vHwaonGfEwDJd6VUws3iMBeVBWUBi21u0R0hWUqVc0uS7XIUPbEL0n85ZnI3ny3nwROXcNce6vGMIDAtj)I6gXCd2DJ1k65tBOxbAk2PnL8lQBSKBSeCBk55jCxJkrHEfOPyhuGiYgBqwG7Mg4vsiXWTPKNNW9zlSaikflWTI(sPVb341ExqmktfSwfzFgUNjsYpzCdK4giSB4ZNBaIoN6ZwybmkLPA0v3WNp3iE3qSRPObmSuAGpdsud9kqtbRBAGxjDJyUb7Ubi6CQbmSuAGpdsud9kqtbRrxDJyUbG1dluoGBGucUHFGa3yj4w5V6Aqmktfmer2Gcer2wgYcC30aVscjgUv0xk9n4MD3qSRPObmSuAGpdsud9kqtbRBAGxjDdF(Cdq05uJfofWB7APA0v3WNp3aW6HfkhWnqkb3iE3GneGa3WV3nqy3WVCd8AVligLPcwRISpd3Zej5NmUXsUHpFUbi6CQbmSuAGpdsud9kqtbRrxDdF(Cd8AVligLPcwRISpd3Zej5NmUbsDdIgUnL88eURrLO4GAEluGiYgrdzbUBAGxjHed3k6lL(gCdIoNASWPaEBxlvtlG9j2nqIBq0UHF5gmks3WVCdq05uJfofWB7APASykVWTPKNNWTkY(mCptKKFYafiISHWqwG7Mg4vsiXWTI(sPVb3GOZP(SfwaJszQgD1nI5g41ExqmktfSwfzFgUNjsYpzCdK4giSBeZnI3ny3nwROXcNce6vGMIDAtj)I6gl5gXCdsUONNb0aoIR8QLx59tg42uYZt4(SfwaeLIfOarKnecYcC30aVscjgUv0xk9n4wSRPO7vGMIDbWZWIUPbEL0nI5g41ExqmktfSwfzFgUNjsYpzCdK4giKBeZnI3ny3nwROXcNce6vGMIDAtj)I6glb3MsEEc39kqtXUa4zybkqezZpGSa3nnWRKqIHBf9LsFdUf7AkAdRAsAPQ6Mg4vs42uYZt4(SfwaSgauGiYwCdzbUnL88eUvr2NH7zIK8tg4UPbELesmuGiYgrfYcC30aVscjgUBAGxda8fFYajgUv0xk9n4geDo1NTWcyukt1ORUrm3qX5hjNizGwtjWTPKNNW9zlSaikflWnaFXNmqezdkqezlUGSa3a8fFYarKn4UPbEnaWx8jdKy42uYZt4EEgqd4iUYlCR8xDnigLPcgIiBWTI(sPVb30oPfhzGxH7Mg4vsiXqbI4YiaYcCdWx8jder2G7Mg41aaFXNmqIHBtjppH7jLJLaoIR8c3nnWRKqIHcuGBCd4pzUgeJYubYcer2GSa3nnWRKqIHBtjppH75zanGJ4kVWTI(sPVb3X7g0cyFIDdKqWnyuKUXsUrm3iE3aeDo1NTWcyukt1ORUHpFUb7Ubi6CQbpoN8qXIgD1nwcUv(RUgeJYubdrKnOarCzilWDtd8kjKy4wrFP03GBXUMIUxbAk2fapdl6Mg4vs42uYZt4UxbAk2fapdlqbIirdzbUBAGxjHed3k6lL(gCl21u0yHtb82UwQUPbEL0nI5gX7gawpSq5aUbsCdegHDJLGBtjppHBSWPaEBxlfkqeryilWDtd8kjKy4wrFP03GBXUMIUQi(NmbCex5v30aVsc3MsEEc3vfX)KjGJ4kVqbIicbzbUBAGxjHed3k6lL(gCdIoNAI8jzGbflASykVUbsCd2iQUHpFUbi6CQpBHfWOuMQrxHBtjppH7ZwybqukwGcer)aYcC30aVscjgUv0xk9n4geDo1yHtb82UwQgDfUnL88eUVNjsYpzcG8tGceX4gYcC30aVscjgUv0xk9n4geDo1vfXloWNbgAnjGrtYs)KrJUc3MsEEc31OsuCqnVfkqejQqwG7Mg4vsiXWTI(sPVb3X7g41ExqmktfSwfzFgUNjsYpzCdK6gS5gl5gXCJ4Dd2DdsUONNb0aoIR8QPDsloYaV6glb3MsEEc31OsuCqnVfkqeJlilWDtd8kjKy4wrFP03GB8AVligLPcwRISpd3Zej5NmUbsCJLDJyUbG1dluoGBGucUHFGa3iMBeVBaIoNAI8jzGbflASykVUbsCJLrGB4ZNBay9WcLd4gi1nIle4glb3MsEEc31OsuahXvEHcer2qaKf4UPbELesmCROVu6BWD8Ubi6CQXcNc4TDTunTa2Ny3ajUbUI8jdwJft5naIoNL6g(LBWOiDd)YnarNtnw4uaVTRLQXIP86g(85gGOZPglCkG321s1ORUrm3aeDo1agwknWNbjQHEfOPG1ORUXsWTPKNNW99mrs(jtaKFcuGiYgBqwG7Mg4vsiXWTI(sPVb3IDnf9R6eL6VUPbEL0nI5gIDnfnGHLsd8zqIAOxbAkyDtd8kPBeZnarNt9R6eL6VgD1nI5gGOZPgWWsPb(mirn0RanfSgDfUnL88eUNuowc4iUYluGiY2YqwG7Mg4vsiXWTI(sPVb3GOZP2WQMKwQQgDfUnL88eUpBHfarPybkqezJOHSa3nnWRKqIHBf9LsFdUvC(rYjsgO1uIBeZny3ne7AkAadlLg4ZGe1qVc0uW6Mg4vs42uYZt4(SfwaeLIfOarKnegYcC30aVscjgUv0xk9n4wSRPOFvNOu)1nnWRKUrm3GD3iE3aW6HfkhWnqQBe3iKBeZnuC(rYjsQpBHfarPyrtlG9j2nqcb3abUXsWTPKNNW9R6eL6puGiYgcbzbUBAGxjHed3k6lL(gCR48JKtKmqRPe3iMBOImktXUbsDdXUMIUQiEGpdsud9kqtbRBAGxjHBtjppH7ZwybqukwGcer28dilWDtd8kjKy4wrFP03GBXUMI(vDIs9x30aVs6gXCdq05u)QorP(RrxHBtjppH7jLJLaoIR8cfiISf3qwGBtjppHBvK9ziYOlkwG7Mg4vsiXqbIiBevilWDtd8kjKy4wrFP03GBXUMIglM8Qa5JvrgLP6Mg4vs42uYZt4glM8Qa5JvrgLPqbIiBXfKf4UPbELesmCROVu6BWn7UHyxtrVsFa7c9kqtXUhl6Mg4vs3WNp3qSRPOxPpGDHEfOPy3JfDtd8kPBeZnI3ny3nwROXcNce6vGMIDAtj)I6glb3MsEEc31OsuOxbAk2bfiIlJailWTPKNNW99mrs(jtaKFcC30aVscjgkqexMnilWnaFXNmqezdUBAGxda8fFYajgUnL88eUNNb0aoIR8c3k)vxdIrzQGHiYgCROVu6BWnTtAXrg4v4UPbELesmuGiU8YqwG7Mg4vsiXWDtd8AaGV4tgiXWTI(sPVb3a8ffOPOjFSyPQUbsDd)aUnL88eUNNb0aoIR8c3a8fFYarKnOarCzIgYcCdWx8jder2G7Mg41aaFXNmqIHBtjppH7jLJLaoIR8c3nnWRKqIHcuGcCBOseNc37ha9m55PFAQnfOafie]] )

end
