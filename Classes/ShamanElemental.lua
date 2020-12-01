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

    spec:RegisterPack( "Elemental", 20201201, [[du02ybqib0JufL2Kq5tQIIyukHoLsWQei5vcWSqrDlbsLDrQFHImmvrogk0YeQ8muGMMqvDnuaBtGOVjqW4ufvDovrL1jqinpvPCpeSpvP6GcKQ0cripuGqzIceQUOaPCsvrHvQkmtbsvCtbcXovL8tvrr6Pk1urOUQaPQAVG(lvnyfomLfdXJjzYi6YsBwrFgLgTqoTkVwqnBGBRQ2TOFJQHRKoUqvwosphQPtCDiTDLOVJcA8cKQY5fOwVQOOMVGSFQmKriXWnPjf(kUNI7jgJ7jg1mYGXp(XXaWTe8AH7vtf2ylCN2VWDqd0FtXaW9QfmGBKqIHBmhLQkChjYkoiktmXEsekIwX)mHVpkWKJNkQnfMW3xXeCJGEa5zKqe4M0KcFf3tX9eJX9eJAgzW4hFgFo4gVwf8vCbzCWD0rs2eIa3KfRG7N1ncAG(BkgWn2r23s3JN1ncIxv)iL6gmYSBe3tX9K7H7XZ6gbXISKT4GOUhpRBe05gpJuXPRCQj1nWvKlzXASyQWEe05Su3yYPUXZq1jknyMDJTWP)WTRLQH7vkFEGc3pRBe0a93umGBSJSVLUhpRBeeVQ(rk1nyKz3iUNI7j3d3JN1ncIfzjBXbrDpEw3iOZnc6LKSKUbIPcJU6gbnmUPQUHHCGtcw7E8SUrqNB8msfNUYPMu3axrUKfRXIPc7rqNZsDJjN6gpdvNO0Gz2n2cN(d3UwQ29W94zDJGwqFvHkL0n6Ysd2nK7x3qIQBykHtDJd7g2s7agcOA3dtjhpX6vAv8pIjeQrLiFb93umaZ3KqGIbAk6v69nGVG(Bkg4WIUPHakP7HPKJNy9kTk(hXKaiW0kxoE6Eyk54jwVsRI)rmjacmvq)nfd4ragwy(Meed0u0f0FtXaEeGHfDtdbus3dtjhpX6vAv8pIjbqGjGT08iOuSW8njeOyGMIUG(BkgWJamSOBAiGs6E4E8SUXZiLsPORIBWNUHYWcw7Eyk54joacmXWlj94OAu3dtjhpXbqGjuC9N0p29WuYXtCaeyAE06lO)MIbCpmLC8ehabMWcN(9f0FtXaUhUhMsoEIdGatkEQAkutkPFcSFDpmLC8ehabMqaCoPNp9su9n7py3dtjhpXbqGjwuJsEw65tV9mxkxICpmLC8ehabMMCfkUKE7zU0tQhP239WuYXtCaeyAfLEZGVK1JamS4Eyk54joacmjr1JMiC0K0p5uvDpmLC8ehabM(9ZPb75tpavDKEsATp29WuYXtCaeyIERRG6V0JxnvDpmLC8ehabMyiNcix2l90I5PLQ6Eyk54joacmrRTEjRFcSFXmFtcIrzROJQbKi)QsE)5FkuiXOSv0r1asKFvjVf3tHcnp2iXt73Ue)gd(K7XZ6gpJ0nugUUXZWnMCklxCdm)xj6swT7HPKJN4aiWuunQ4lg3uv3d3dtjhpXbqGjeaNt6NO0Gz(MecumqtrByvtslvv30qaLmuie05uByvtslvvJUgkKIZbKCgMAdRAsAPQAA)2L43zGNCpmLC8ehabMqkfxA4lzz(MecumqtrByvtslvv30qaLmuie05uByvtslvvJU6Eyk54joacmnpAraCojZ3KqGIbAkAdRAsAPQ6MgcOKHcHGoNAdRAsAPQA01qHuCoGKZWuByvtslvvt73Ue)od8K7HPKJN4aiWKLQIfQb8kday(MecumqtrByvtslvv30qaLmuie05uByvtslvvJUgkKIZbKCgMAdRAsAPQAA)2L43zGNCpmLC8ehabMqmwpF6f6PcJz(MecumqtrByvtslvv30qaLmuOarqNtTHvnjTuvn6Q7H7HPKJN4aiW0k9(Ck5zapdTLLzvWkq9IrzRGjWiZ3KqGiOZPELEFoL8mGNH2YQrxDpmLC8ehabMww8APEHl97Eyk54joacmnT6fQL4jk(4P7H7HPKJN4aiWefn9MsoE6bhwyoTFjy8Y8njyk5wwFZ(VIFpUylIxla4fJYwbRvr2LEWXgj5LSVhxOq41caEXOSvWAGT08i1(Vh3cUhMsoEIdGatu00Bk54PhCyH50(La(swq9IrzRW8njeOyGMIglC63xq)nfdOBAiGsgZuYTS(M9Ff)gH4CpmLC8ehabMOOP3uYXtp4WcZP9lbC94lzb1lgLTcZ3KGyGMIglC63xq)nfdOBAiGsgZuYTS(M9Ff)gH4CpCpmLC8eRnEjuJkrXd1cxMVjbe05uxve)swpoIRcRrxDpmLC8eRnEdGatQi7sFKrxwS4Eyk54jwB8gabMWcN(d3UwkZ3KGyGMIglC6pC7AP6MgcOKUhMsoEI1gVbqGPjW(1JJ4QWmRcwbQxmkBfmbgz(MemLClRNKl6jW(1JJ4QWVXGXmLClRVz)xXVrGbcfIIMDYPSvJdhmcTw4sX(5vAWEY(pC1nEO36AjDpmLC8eRnEdGattG9RhhXvHz(Mec0uYTSEsUONa7xpoIRc7Eyk54jwB8gabMQkIFjRhhXvHz(Meed0u0vfXVK1JJ4QW6MgcOKX(wbyHY)VtiiFY9WuYXtS24nacmzyvtslvL5BsqmqtrByvtslvv30qaLm2IbUwrJfo97lO)MIb0MsULDHylgOyGMI(uDIsdw30qaLmuOarqNt9P6eLgSgDnwGkohqYzyQpvNO0G1ORl4Eyk54jwB8gabMax8qps)3y)Mx4s)mFtcIbAkAWfp0J0)n2V5fU0VUPHakP7HPKJNyTXBaeyQgvI84iUkmZ3Kafn7KtzRUQiEXE(0ZsRjEmAsw6LS6gp0BDTKXcebDo1vfXl2ZNEwAnXJrtYsVKvJU6Eyk54jwB8gabMQrLiFb93umaZ3Kafn7KtzRMSDvO9ZPESWZQB8qV11sgBXafd0u0R07BaFb93umWHfDtdbuYqHwmW1kASWPFFb93umG2uYTSXcCTIEE06lO)MIb0MsULDHfCpmLC8eRnEdGataBP5rqPyHzvWkq9IrzRGjWiZ3KaETaGxmkBfSwfzx6bhBKKxY(w8dfcbDo1aBP5XOu2QrxdfArXanf93WsPE(0lr1xq)nfSUPHakzSarqNt93WsPE(0lr1xq)nfSgDn23kalu()Dcb5tl4E8SUbX0GDdH7gS2VUrqZOsu8qTW1ny4jrUrqedlL6g8PBir1ncAG(Bky3abDoDdgg10nMhBKCjRBWGUHyu2kyTBeeNNpte3GVSuLT6gbrScWcL)d09WuYXtS24nacmvJkrXd1cxMVjHafd0u0FdlL65tVevFb93uW6MgcOKHcHGoNASWP)WTRLQrxdf6BfGfk))oHfz8PNc6IFqHxla4fJYwbRvr2LEWXgj5LSlekec6CQ)gwk1ZNEjQ(c6VPG1ORHcHxla4fJYwbRvr2LEWXgj5LSVZGUhpRBeeXcx3aJsRBemh1ni55ZeXnaCCDdZn2cN(d3UwQBGGoNA3dtjhpXAJ3aiWKkYU0do2ijVKL5BsabDo1yHt)HBxlvt73Ue)gdguSkYGcbDo1yHt)HBxlvJftf294zDJNPjiy3qzyXnc6XwAUbrOuS4g80nKiARBigLTc2nUPBCIBCy3Ws34sSyP4gws6gBHt)Urqd0FtXaUXHDJxptj2nmLClR29WuYXtS24nacmbSLMhbLIfMVjbe05udSLMhJszRgDngETaGxmkBfSwfzx6bhBKKxY(w8JTyGRv0yHt)(c6VPyaTPKBzxigjx0tG9RhhXvH1YPcFjR7XZ6gb9JRBe0a93umGBqeWWIByS2LyXnqxDdH7gmOBigLTc2nmSBa4jRByy3ylC63ncAG(BkgWnoSBKCXnmLClR29WuYXtS24nacmvq)nfd4ragwy(Meed0u0f0FtXaEeGHfDtdbuYy41caEXOSvWAvKDPhCSrsEj7BmqSfdCTIglC63xq)nfdOnLCl7cUhMsoEI1gVbqGjGT08i1(mFtcIbAkAdRAsAPQ6MgcOKUhMsoEI1gVbqGjvKDPhCSrsEjR7HPKJNyTXBaeycylnpckflm)5lVKLaJmFtciOZPgylnpgLYwn6AmfNdi5mm90AkX9WuYXtS24nacmnb2VECexfM5pF5LSeyKzvWkq9IrzRGjWiZ3KaTtAXrgcOUhMsoEI1gVbqGPjLJfpoIRcZ8NV8swcm6E4Eyk54jwJRhFjlOEXOSvimb2VECexfMzvWkq9IrzRGjWiZ3KWI0(TlXVrGvrUqSfrqNtnWwAEmkLTA01qHcebDo1iaoNeGIfn66cUhMsoEI146XxYcQxmkBLaiWub93umGhbyyH5Bsqmqtrxq)nfd4ragw0nneqjDpmLC8eRX1JVKfuVyu2kbqGjSWP)WTRLY8njigOPOXcN(d3UwQUPHakzSf)wbyHY)Vf)4VG7HPKJNynUE8LSG6fJYwjacmvve)swpoIRcZ8njigOPORkIFjRhhXvH1nneqjDpmLC8eRX1JVKfuVyu2kbqGjGT08iOuSW8njGGoNAgEjPNfflASyQWVX4Zhkec6CQb2sZJrPSvJU6Eyk54jwJRhFjlOEXOSvcGatGJnsYlz9iCGW8njGGoNASWP)WTRLQrxDpmLC8eRX1JVKfuVyu2kbqGPAujkEOw4Y8njGGoN6QI4f75tplTM4XOjzPxYQrxDpmLC8eRX1JVKfuVyu2kbqGPAujkEOw4Y8njSiETaGxmkBfSwfzx6bhBKKxY(oJleBXaj5IEcSF94iUkSM2jT4idb0fCpmLC8eRX1JVKfuVyu2kbqGPAujYJJ4QWmFtc41caEXOSvWAvKDPhCSrsEj7BXf7BfGfk))oHG8PylIGoNAgEjPNfflASyQWVf3tHc9TcWcL)F)5EAb3dtjhpXAC94lzb1lgLTsaeycCSrsEjRhHdeMVjHfrqNtnw40F421s10(TlXVHRixYI1yXuH9iOZzPbfRImOqqNtnw40F421s1yXuHdfcbDo1yHt)HBxlvJUgdbDo1FdlL65tVevFb93uWA01fCpmLC8eRX1JVKfuVyu2kbqGPjLJfpoIRcZ8njigOPOpvNO0G1nneqjJjgOPO)gwk1ZNEjQ(c6VPG1nneqjJHGoN6t1jknyn6Ame05u)nSuQNp9su9f0FtbRrxDpmLC8eRX1JVKfuVyu2kbqGjGT08iOuSW8njGGoNAdRAsAPQA0v3dtjhpXAC94lzb1lgLTsaeycylnpckflmFtckohqYzy6P1usSafd0u0FdlL65tVevFb93uW6MgcOKUhMsoEI146XxYcQxmkBLaiW0P6eLgmZ3KGyGMI(uDIsdw30qaLmwGl(TcWcL)FpiWaXuCoGKZWudSLMhbLIfnTF7s8BeEAb3dtjhpXAC94lzb1lgLTsaeycylnpckflmFtckohqYzy6P1usmvKrzl(DXanfDvrCpF6LO6lO)Mcw30qaL09WuYXtSgxp(swq9IrzReabMMuow84iUkmZ3KGyGMI(uDIsdw30qaLmgc6CQpvNO0G1ORUhMsoEI146XxYcQxmkBLaiWKkYU0hz0LflUhMsoEI146XxYcQxmkBLaiWewm5uEYdRImkBz(Meed0u0yXKt5jpSkYOSv30qaL09WuYXtSgxp(swq9IrzReabMQrLiFb93umaZ3KqGIbAk6v69nGVG(Bkg4WIUPHakzOqIbAk6v69nGVG(Bkg4WIUPHakzSfdCTIglC63xq)nfdOnLCl7cUhMsoEI146XxYcQxmkBLaiWe4yJK8swpchiUhMsoEI146XxYcQxmkBLaiW0ey)6XrCvyM)8LxYsGrMvbRa1lgLTcMaJmFtc0oPfhziG6Eyk54jwJRhFjlOEXOSvcGattG9RhhXvHz(ZxEjlbgz(Me(8L93u0KhwSu13ds3dtjhpXAC94lzb1lgLTsaeyAs5yXJJ4QWm)5lVKLaJUhUhMsoEI14lzb1lgLTcHjW(1JJ4QWmRcwbQxmkBfmbgz(Mewmq5uHVKnuisUONa7xpoIRcRP9BxIFJaRImuiXanfTHvnjTuvDtdbuYyKCrpb2VECexfwt73Ue)2IkohqYzyQnSQjPLQQP9BxIdabDo1gw1K0sv1KOutoEUqmfNdi5mm1gw1K0sv10(TlXVf)fITic6CQb2sZJrPSvJUgkuGiOZPgbW5KauSOrxxW9WuYXtSgFjlOEXOSvcGatgw1K0svz(Meed0u0gw1K0sv1nneqjJTOC)(oHG8PqHqqNtncGZjbOyrJUUqSfvCoGKZWudSLMhbLIfnTF7s87pTqSfdumqtrFQorPbRBAiGsgkuGiOZP(uDIsdwJUglqfNdi5mm1NQtuAWA01fCpmLC8eRXxYcQxmkBLaiWub93umGhbyyH5Bsqmqtrxq)nfd4ragw0nneqjJTOyGMI(ByPupF6LO6lO)Mcw30qaLm2IiOZP(ByPupF6LO6lO)McwJUg7BfGfk))wq(uOqbIGoN6VHLs98PxIQVG(Bkyn66cHcfOyGMI(ByPupF6LO6lO)Mcw30qaLCb3dtjhpXA8LSG6fJYwjacmHfo9hUDTuMVjbXanfnw40F421s1nneqjJTi1osFx2u0gjjwR4OP8gdgke1osFx2u0gjjwF57mWtleBXVvawO8)BXp(l4Eyk54jwJVKfuVyu2kbqGPQI4xY6XrCvyMVjbXanfDvr8lz94iUkSUPHakzmfNdi5mm1aBP5rqPyrt73Ue)gHNCpmLC8eRXxYcQxmkBLaiWeWwAEeukwy(Meed0u0vfXVK1JJ4QW6MgcOKXqqNtDvr8lz94iUkSgD19WuYXtSgFjlOEXOSvcGatGlEOhP)BSFZlCPFMVjbXanfn4Ih6r6)g738cx6x30qaL09WuYXtSgFjlOEXOSvcGatGJnsYlz9iCGW8njGGoNASWP)WTRLQrxJHxla4fJYwbRvr2LEWXgj5LSVfxSfrqNt93WsPE(0lr1xq)nfSgDDb3dtjhpXA8LSG6fJYwjacmvJkrXd1cxMVjbe05uxveVypF6zP1epgnjl9swn6ASfdumqtr)nSuQNp9su9f0FtbRBAiGsgkec6CQ)gwk1ZNEjQ(c6VPG1ORl4Eyk54jwJVKfuVyu2kbqGPAujkEOw4Y8njGxla4fJYwbRvr2LEWXgj5LSVZySaj5IEcSF94iUkSM2jT4idb0ybsrZo5u2QRkIxSNp9S0AIhJMKLEjRUXd9wxlzSfdumqtr)nSuQNp9su9f0FtbRBAiGsgkec6CQ)gwk1ZNEjQ(c6VPG1ORHcP4CajNHPgylnpckflAA)2L43Fk23kalu()DcpxCl4Eyk54jwJVKfuVyu2kbqGPAujYJJ4QWmFtcIbAk6VHLs98PxIQVG(BkyDtdbuYylIGoN6VHLs98PxIQVG(Bkyn6AOqkohqYzyQb2sZJGsXIM2VDj(9NI9TcWcL)FNWZfxOq41caEXOSvWAvKDPhCSrsEj7BXfdbDo1yHt)HBxlvJUgtX5asodtnWwAEeukw00(TlXVrGvrUqOqbkgOPO)gwk1ZNEjQ(c6VPG1nneqjDpmLC8eRXxYcQxmkBLaiWe4yJK8swpchimFtclIGoNASWP)WTRLQP9BxIFdxrUKfRXIPc7rqNZsdkwfzqHGoNASWP)WTRLQXIPchkec6CQXcN(d3UwQgDngc6CQ)gwk1ZNEjQ(c6VPG1ORl4Eyk54jwJVKfuVyu2kbqGPjLJfpoIRcZ8njigOPOpvNO0G1nneqjJjgOPO)gwk1ZNEjQ(c6VPG1nneqjJHGoN6t1jknyn6Ame05u)nSuQNp9su9f0FtbRrxDpmLC8eRXxYcQxmkBLaiWeWwAEeukwy(MeqqNtTHvnjTuvn6Q7HPKJNyn(swq9IrzReabMa2sZJGsXcZ3KGIZbKCgMEAnLelqXanf93WsPE(0lr1xq)nfSUPHakP7HPKJNyn(swq9IrzReabMovNO0Gz(Meed0u0NQtuAW6MgcOKXcCXVvawO8)7bbgiMIZbKCgMAGT08iOuSOP9BxIFJWtl4Eyk54jwJVKfuVyu2kbqGjGT08iOuSW8njO4CajNHPNwtjXurgLT43fd0u0vfX98PxIQVG(BkyDtdbus3dtjhpXA8LSG6fJYwjacmnPCS4XrCvyMVjbXanf9P6eLgSUPHakzme05uFQorPbRrxJHGoN6t1jknynTF7s8B4kYLSynwmvypc6CwAqXQidke05uFQorPbRXIPc7Eyk54jwJVKfuVyu2kbqGjGT08iOuSW8njO4CajNHPNwtjUhMsoEI14lzb1lgLTsaeyAcSF94iUkmZQGvG6fJYwbtGrMVjbAN0IJmeqDpmLC8eRXxYcQxmkBLaiWunQefpulCz(MeWRfa8IrzRG1Qi7sp4yJK8s23zmwGu0StoLT6QI4f75tplTM4XOjzPxYQB8qV11sgkec6CQRkIxSNp9S0AIhJMKLEjRgD19WuYXtSgFjlOEXOSvcGattkhlECexfM5BsqmqtrFQorPbRBAiGsgdbDo1NQtuAWA01ylIGoN6t1jknynTF7s8BSkYGk(bfc6CQpvNO0G1yXuHdfcbDo1yHt)HBxlvJUgkuGIbAk6VHLs98PxIQVG(BkyDtdbuYfCpmLC8eRXxYcQxmkBLaiW0KYXIhhXvHz(MeOOzNCkB1f0FtXa(gp0dCi0d9RB8qV11sglqe05uxq)nfd4B8qpWHqp0VNSiOZPgDnwGIbAk6c6VPyapcWWIUPHakzSafd0u0vfXVK1JJ4QW6MgcOKUhMsoEI14lzb1lgLTsaeysfzx6Jm6YIf3dtjhpXA8LSG6fJYwjacmHftoLN8WQiJYwMVjbXanfnwm5uEYdRImkB1nneqjDpmLC8eRXxYcQxmkBLaiWunQe5lO)MIby(MecumqtrVsVVb8f0FtXahw0nneqjdfkW1k65rRVG(BkgqBk5ww3dtjhpXA8LSG6fJYwjacmbo2ijVK1JWbI7HPKJNyn(swq9IrzReabMMa7xpoIRcZ8NV8swcmYSkyfOEXOSvWeyK5BsG2jT4idbu3dtjhpXA8LSG6fJYwjacmnb2VECexfM5pF5LSeyK5Bs4Zx2FtrtEyXsvFpiDpmLC8eRXxYcQxmkBLaiW0KYXIhhXvHz(ZxEjlbgH7LLIpEcFf3tX9eJmgx8HBgA08swmC)m(RCQus3GbCdtjhpDdWHfS29aUnujItH799rbMC8mig1McCdoSGHed34lzb1lgLTcKy4lgHed3nneqjHeb3MsoEc3tG9RhhXvHHBf9KspdUx0nc0nKtf(sw3iui3GKl6jW(1JJ4QWAA)2Ly34ncUbRI0ncfYned0u0gw1K0sv1nneqjDJyUbjx0tG9RhhXvH10(TlXUXBUXIUHIZbKCgMAdRAsAPQAA)2Ly3ia3abDo1gw1K0sv1KOutoE6gl4gXCdfNdi5mm1gw1K0sv10(TlXUXBUr8DJfCJyUXIUbc6CQb2sZJrPSvJU6gHc5gb6giOZPgbW5KauSOrxDJfGBvWkq9IrzRGHVyekWxXbjgUBAiGscjcUv0tk9m4wmqtrByvtslvv30qaL0nI5gl6gY9RB8ob3iiFYncfYnqqNtncGZjbOyrJU6gl4gXCJfDdfNdi5mm1aBP5rqPyrt73Ue7gV7gp5gl4gXCJfDJaDdXanf9P6eLgSUPHakPBekKBeOBGGoN6t1jknyn6QBeZnc0nuCoGKZWuFQorPbRrxDJfGBtjhpHBdRAsAPQqb(IbHed3nneqjHeb3k6jLEgClgOPOlO)MIb8iadl6MgcOKUrm3yr3qmqtr)nSuQNp9su9f0FtbRBAiGs6gXCJfDde05u)nSuQNp9su9f0FtbRrxDJyUX3kalu(3nEZncYNCJqHCJaDde05u)nSuQNp9su9f0FtbRrxDJfCJqHCJaDdXanf93WsPE(0lr1xq)nfSUPHakPBSaCBk54jCxq)nfd4ragwGc8v8Hed3nneqjHeb3k6jLEgClgOPOXcN(d3UwQUPHakPBeZnw0nO2r67YMI2ijXAfhnf34n3GbDJqHCdQDK(USPOnssS(s34D3GbEYnwWnI5gl6gFRaSq5F34n3i(X3nwaUnLC8eUXcN(d3UwkuGVyaiXWDtdbusirWTIEsPNb3IbAk6QI4xY6XrCvyDtdbus3iMBO4CajNHPgylnpckflAA)2Ly34ncUXtWTPKJNWDvr8lz94iUkmuGVcsiXWDtdbusirWTIEsPNb3IbAk6QI4xY6XrCvyDtdbus3iMBGGoN6QI4xY6XrCvyn6kCBk54jCdSLMhbLIfOaFfeGed3nneqjHeb3k6jLEgClgOPObx8qps)3y)Mx4s)6MgcOKWTPKJNWn4Ih6r6)g738cx6hkWxppKy4UPHakjKi4wrpP0ZGBe05uJfo9hUDTun6QBeZnWRfa8IrzRG1Qi7sp4yJK8sw34n3io3iMBSOBGGoN6VHLs98PxIQVG(Bkyn6QBSaCBk54jCdo2ijVK1JWbcuGVEoiXWDtdbusirWTIEsPNb3iOZPUQiEXE(0ZsRjEmAsw6LSA0v3iMBSOBeOBigOPO)gwk1ZNEjQ(c6VPG1nneqjDJqHCde05u)nSuQNp9su9f0FtbRrxDJfGBtjhpH7AujkEOw4cf4lgFcsmC30qaLeseCRONu6zWnETaGxmkBfSwfzx6bhBKKxY6gV7gm6gXCJaDdsUONa7xpoIRcRPDsloYqa1nI5gb6gu0StoLT6QI4f75tplTM4XOjzPxYQB8qV11s6gXCJfDJaDdXanf93WsPE(0lr1xq)nfSUPHakPBekKBGGoN6VHLs98PxIQVG(Bkyn6QBekKBO4CajNHPgylnpckflAA)2Ly34D34j3iMB8TcWcL)DJ3j4gpxCUXcWTPKJNWDnQefpulCHc8fJmcjgUBAiGscjcUv0tk9m4wmqtr)nSuQNp9su9f0FtbRBAiGs6gXCJfDde05u)nSuQNp9su9f0FtbRrxDJqHCdfNdi5mm1aBP5rqPyrt73Ue7gV7gp5gXCJVvawO8VB8ob345IZncfYnWRfa8IrzRG1Qi7sp4yJK8sw34n3io3iMBGGoNASWP)WTRLQrxDJyUHIZbKCgMAGT08iOuSOP9BxIDJ3i4gSks3yb3iui3iq3qmqtr)nSuQNp9su9f0FtbRBAiGsc3MsoEc31OsKhhXvHHc8fJXbjgUBAiGscjcUv0tk9m4Er3abDo1yHt)HBxlvt73Ue7gV5g4kYLSynwmvypc6CwQBeuUbRI0nck3abDo1yHt)HBxlvJftf2ncfYnqqNtnw40F421s1ORUrm3abDo1FdlL65tVevFb93uWA0v3yb42uYXt4gCSrsEjRhHdeOaFXidcjgUBAiGscjcUv0tk9m4wmqtrFQorPbRBAiGs6gXCdXanf93WsPE(0lr1xq)nfSUPHakPBeZnqqNt9P6eLgSgD1nI5giOZP(ByPupF6LO6lO)McwJUc3MsoEc3tkhlECexfgkWxmgFiXWDtdbusirWTIEsPNb3iOZP2WQMKwQQgDfUnLC8eUb2sZJGsXcuGVyKbGed3nneqjHeb3k6jLEgCR4CajNHPNwtjUrm3iq3qmqtr)nSuQNp9su9f0FtbRBAiGsc3MsoEc3aBP5rqPybkWxmgKqIH7MgcOKqIGBf9KspdUfd0u0NQtuAW6MgcOKUrm3iq3yr34BfGfk)7gV7gbbgWnI5gkohqYzyQb2sZJGsXIM2VDj2nEJGB8KBSaCBk54jCFQorPbdf4lgdcqIH7MgcOKqIGBf9KspdUvCoGKZW0tRPe3iMBOImkBXUX7UHyGMIUQiUNp9su9f0FtbRBAiGsc3MsoEc3aBP5rqPybkWxm(8qIH7MgcOKqIGBf9KspdUfd0u0NQtuAW6MgcOKUrm3abDo1NQtuAWA0v3iMBGGoN6t1jknynTF7sSB8MBGRixYI1yXuH9iOZzPUrq5gSks3iOCde05uFQorPbRXIPcd3MsoEc3tkhlECexfgkWxm(CqIH7MgcOKqIGBf9KspdUvCoGKZW0tRPe42uYXt4gylnpckflqb(kUNGed3nneqjHeb3MsoEc3tG9RhhXvHHBf9KspdUPDsloYqafUvbRa1lgLTcg(IrOaFfhJqIH7MgcOKqIGBf9KspdUXRfa8IrzRG1Qi7sp4yJK8sw34D3Gr3iMBeOBqrZo5u2QRkIxSNp9S0AIhJMKLEjRUXd9wxlPBekKBGGoN6QI4f75tplTM4XOjzPxYQrxHBtjhpH7AujkEOw4cf4R4IdsmC30qaLeseCRONu6zWTyGMI(uDIsdw30qaL0nI5giOZP(uDIsdwJU6gXCJfDde05uFQorPbRP9BxIDJ3CdwfPBeuUr8DJGYnqqNt9P6eLgSglMkSBekKBGGoNASWP)WTRLQrxDJqHCJaDdXanf93WsPE(0lr1xq)nfSUPHakPBSaCBk54jCpPCS4XrCvyOaFfhdcjgUBAiGscjcUv0tk9m4MIMDYPSvxq)nfd4B8qpWHqp0VUXd9wxlPBeZnc0nqqNtDb93umGVXd9ahc9q)EYIGoNA0v3iMBeOBigOPOlO)MIb8iadl6MgcOKUrm3iq3qmqtrxve)swpoIRcRBAiGsc3MsoEc3tkhlECexfgkWxXfFiXWTPKJNWTkYU0hz0LflWDtdbusirqb(kogasmC30qaLeseCRONu6zWTyGMIglMCkp5HvrgLT6MgcOKWTPKJNWnwm5uEYdRImkBHc8vCbjKy4UPHakjKi4wrpP0ZG7aDdXanf9k9(gWxq)nfdCyr30qaL0ncfYnc0nwRONhT(c6VPyaTPKBzHBtjhpH7AujYxq)nfdaf4R4ccqIHBtjhpHBWXgj5LSEeoqG7MgcOKqIGc8vCppKy4(ZxEjl8fJWDtdbu)NV8swirWTPKJNW9ey)6XrCvy4wfScuVyu2ky4lgHBf9KspdUPDsloYqafUBAiGscjckWxX9CqIH7MgcOKqIG7MgcO(pF5LSqIGBf9KspdU)8L93u0KhwSuv34D3iiHBtjhpH7jW(1JJ4QWW9NV8sw4lgHc8fd(eKy4(ZxEjl8fJWDtdbu)NV8swirWTPKJNW9KYXIhhXvHH7MgcOKqIGcuGBYonuGajg(IriXWTPKJNWndVK0JJQrH7MgcOKqIGc8vCqIHBtjhpHBuC9N0pgUBAiGscjckWxmiKy42uYXt4EE06lO)MIbG7MgcOKqIGc8v8Hed3MsoEc3yHt)(c6VPya4UPHakjKiOaFXaqIHBtjhpHBfpvnfQjL0pb2VWDtdbusirqb(kiHed3MsoEc3iaoN0ZNEjQ(M9hmC30qaLeseuGVccqIHBtjhpHBwuJsEw65tV9mxkxIG7MgcOKqIGc81ZdjgUnLC8eUNCfkUKE7zU0tQhP2hUBAiGscjckWxphKy42uYXt4EfLEZGVK1JamSa3nneqjHebf4lgFcsmCBk54jClr1JMiC0K0p5uvH7MgcOKqIGc8fJmcjgUnLC8eU)9ZPb75tpavDKEsATpgUBAiGscjckWxmghKy42uYXt4MERRG6V0JxnvH7MgcOKqIGc8fJmiKy42uYXt4MHCkGCzV0tlMNwQkC30qaLeseuGVym(qIH7MgcOKqIGBf9KspdUfJYwrhvdir(vL4gV7gp)tUrOqUHyu2k6OAajYVQe34n3iUNCJqHCJ5XgjEA)2Ly34n3GbFcUnLC8eUP1wVK1pb2VyOaFXidajgUnLC8eUJQrfFX4MQc3nneqjHebf4lgdsiXWDtdbusirWTIEsPNb3b6gIbAkAdRAsAPQ6MgcOKUrOqUbc6CQnSQjPLQQrxDJqHCdfNdi5mm1gw1K0sv10(TlXUX7Ubd8eCBk54jCJa4Cs)eLgmuGVymiajgUBAiGscjcUv0tk9m4oq3qmqtrByvtslvv30qaL0ncfYnqqNtTHvnjTuvn6kCBk54jCJukU0WxYcf4lgFEiXWDtdbusirWTIEsPNb3b6gIbAkAdRAsAPQ6MgcOKUrOqUbc6CQnSQjPLQQrxDJqHCdfNdi5mm1gw1K0sv10(TlXUX7Ubd8eCBk54jCppAraCojuGVy85Ged3nneqjHeb3k6jLEgChOBigOPOnSQjPLQQBAiGs6gHc5giOZP2WQMKwQQgD1ncfYnuCoGKZWuByvtslvvt73Ue7gV7gmWtWTPKJNWTLQIfQb8kdaGc8vCpbjgUBAiGscjcUv0tk9m4oq3qmqtrByvtslvv30qaL0ncfYnc0nqqNtTHvnjTuvn6kCBk54jCJySE(0l0tfgdf4R4yesmC30qaLeseCBk54jCVsVpNsEgWZqBzHBf9KspdUd0nqqNt9k9(Ck5zapdTLvJUc3QGvG6fJYwbdFXiuGVIloiXWTPKJNW9YIxl1lCPF4UPHakjKiOaFfhdcjgUnLC8eUNw9c1s8efF8eUBAiGscjckWxXfFiXWDtdbusirWTIEsPNb3MsUL13S)Ry34D3io3iMBSOBGxla4fJYwbRvr2LEWXgj5LSUX7UrCUrOqUbETaGxmkBfSgylnpsTVB8UBeNBSaCBk54jCtrtVPKJNEWHf4gCyXN2VWTXluGVIJbGed3nneqjHeb3k6jLEgChOBigOPOXcN(9f0FtXa6MgcOKUrm3WuYTS(M9Ff7gVrWnIdUnLC8eUPOP3uYXtp4WcCdoS4t7x4gFjlOEXOSvGc8vCbjKy4UPHakjKi4wrpP0ZGBXanfnw40VVG(Bkgq30qaL0nI5gMsUL13S)Ry34ncUrCWTPKJNWnfn9MsoE6bhwGBWHfFA)c346XxYcQxmkBfOaf4ELwf)JycKy4lgHed3nneqjHeb3k6jLEgChOBigOPOxP33a(c6VPyGdl6MgcOKWTPKJNWDnQe5lO)MIbGc8vCqIHBtjhpH7vUC8eUBAiGscjckWxmiKy4UPHakjKi4wrpP0ZGBXanfDb93umGhbyyr30qaLeUnLC8eUlO)MIb8iadlqb(k(qIH7MgcOKqIGBf9KspdUd0ned0u0f0FtXaEeGHfDtdbus42uYXt4gylnpckflqbkWTXlKy4lgHed3nneqjHeb3k6jLEgCJGoN6QI4xY6XrCvyn6kCBk54jCxJkrXd1cxOaFfhKy42uYXt4wfzx6Jm6YIf4UPHakjKiOaFXGqIH7MgcOKqIGBf9KspdUfd0u0yHt)HBxlv30qaLeUnLC8eUXcN(d3UwkuGVIpKy4UPHakjKi42uYXt4EcSF94iUkmCRONu6zWTPKBz9KCrpb2VECexf2nEZnyq3iMByk5wwFZ(VIDJ3i4gmGBekKBqrZo5u2QXHdgHwlCPy)8knypz)hU6gp0BDTKWTkyfOEXOSvWWxmcf4lgasmC30qaLeseCRONu6zWDGUHPKBz9KCrpb2VECexfgUnLC8eUNa7xpoIRcdf4RGesmC30qaLeseCRONu6zWTyGMIUQi(LSECexfw30qaL0nI5gFRaSq5F34DcUrq(eCBk54jCxve)swpoIRcdf4RGaKy4UPHakjKi4wrpP0ZGBXanfTHvnjTuvDtdbus3iMBSOBeOBSwrJfo97lO)MIb0MsUL1nwWnI5gl6gb6gIbAk6t1jknyDtdbus3iui3iq3abDo1NQtuAWA0v3iMBeOBO4CajNHP(uDIsdwJU6gla3MsoEc3gw1K0svHc81ZdjgUBAiGscjcUv0tk9m4wmqtrdU4HEK(VX(nVWL(1nneqjHBtjhpHBWfp0J0)n2V5fU0puGVEoiXWDtdbusirWTIEsPNb3u0StoLT6QI4f75tplTM4XOjzPxYQB8qV11s6gXCJaDde05uxveVypF6zP1epgnjl9swn6kCBk54jCxJkrECexfgkWxm(eKy4UPHakjKi4wrpP0ZGBkA2jNYwnz7Qq7Nt9yHNv34HERRL0nI5gl6gb6gIbAk6v69nGVG(Bkg4WIUPHakPBekKBSOBeOBSwrJfo97lO)MIb0MsUL1nI5gb6gRv0ZJwFb93umG2uYTSUXcUXcWTPKJNWDnQe5lO)MIbGc8fJmcjgUBAiGscjcUnLC8eUb2sZJGsXcCRONu6zWnETaGxmkBfSwfzx6bhBKKxY6gV5gX3ncfYnqqNtnWwAEmkLTA0v3iui3yr3qmqtr)nSuQNp9su9f0FtbRBAiGs6gXCJaDde05u)nSuQNp9su9f0FtbRrxDJyUX3kalu(3nENGBeKp5gla3QGvG6fJYwbdFXiuGVymoiXWDtdbusirWTIEsPNb3b6gIbAk6VHLs98PxIQVG(BkyDtdbus3iui3abDo1yHt)HBxlvJU6gHc5gFRaSq5F34DcUXIUbJp9KBe05gX3nck3aVwaWlgLTcwRISl9GJnsYlzDJfCJqHCde05u)nSuQNp9su9f0FtbRrxDJqHCd8AbaVyu2kyTkYU0do2ijVK1nE3nyq42uYXt4UgvIIhQfUqb(IrgesmC30qaLeseCRONu6zWnc6CQXcN(d3UwQM2VDj2nEZnyq3iOCdwfPBeuUbc6CQXcN(d3UwQglMkmCBk54jCRISl9GJnsYlzHc8fJXhsmC30qaLeseCRONu6zWnc6CQb2sZJrPSvJU6gXCd8AbaVyu2kyTkYU0do2ijVK1nEZnIVBeZnw0nc0nwROXcN(9f0FtXaAtj3Y6gl4gXCdsUONa7xpoIRcRLtf(sw42uYXt4gylnpckflqb(IrgasmC30qaLeseCRONu6zWTyGMIUG(BkgWJamSOBAiGs6gXCd8AbaVyu2kyTkYU0do2ijVK1nEZnya3iMBSOBeOBSwrJfo97lO)MIb0MsUL1nwaUnLC8eUlO)MIb8iadlqb(IXGesmC30qaLeseCRONu6zWTyGMI2WQMKwQQUPHakjCBk54jCdSLMhP2hkWxmgeGed3MsoEc3Qi7sp4yJK8sw4UPHakjKiOaFX4ZdjgUBAiGscjcUBAiG6)8LxYcjcUv0tk9m4gbDo1aBP5XOu2QrxDJyUHIZbKCgMEAnLa3MsoEc3aBP5rqPybU)8LxYcFXiuGVy85Ged3F(YlzHVyeUBAiG6)8LxYcjcUnLC8eUNa7xpoIRcd3QGvG6fJYwbdFXiCRONu6zWnTtAXrgcOWDtdbusirqb(kUNGed3F(YlzHVyeUBAiG6)8LxYcjcUnLC8eUNuow84iUkmC30qaLeseuGcCJRhFjlOEXOSvGedFXiKy4UPHakjKi42uYXt4EcSF94iUkmCRONu6zW9IUbTF7sSB8gb3Gvr6gl4gXCJfDde05udSLMhJszRgD1ncfYnc0nqqNtncGZjbOyrJU6gla3QGvG6fJYwbdFXiuGVIdsmC30qaLeseCRONu6zWTyGMIUG(BkgWJamSOBAiGsc3MsoEc3f0FtXaEeGHfOaFXGqIH7MgcOKqIGBf9KspdUfd0u0yHt)HBxlv30qaL0nI5gl6gFRaSq5F34n3i(X3nwaUnLC8eUXcN(d3UwkuGVIpKy4UPHakjKi4wrpP0ZGBXanfDvr8lz94iUkSUPHakjCBk54jCxve)swpoIRcdf4lgasmC30qaLeseCRONu6zWnc6CQz4LKEwuSOXIPc7gV5gm(8UrOqUbc6CQb2sZJrPSvJUc3MsoEc3aBP5rqPybkWxbjKy4UPHakjKi4wrpP0ZGBe05uJfo9hUDTun6kCBk54jCdo2ijVK1JWbcuGVccqIH7MgcOKqIGBf9KspdUrqNtDvr8I98PNLwt8y0KS0lz1ORWTPKJNWDnQefpulCHc81ZdjgUBAiGscjcUv0tk9m4Er3aVwaWlgLTcwRISl9GJnsYlzDJ3DdgDJfCJyUXIUrGUbjx0tG9RhhXvH10oPfhziG6gla3MsoEc31Osu8qTWfkWxphKy4UPHakjKi4wrpP0ZGB8AbaVyu2kyTkYU0do2ijVK1nEZnIZnI5gFRaSq5F34DcUrq(KBeZnw0nqqNtndVK0ZIIfnwmvy34n3iUNCJqHCJVvawO8VB8UB8Cp5gla3MsoEc31OsKhhXvHHc8fJpbjgUBAiGscjcUv0tk9m4Er3abDo1yHt)HBxlvt73Ue7gV5g4kYLSynwmvypc6CwQBeuUbRI0nck3abDo1yHt)HBxlvJftf2ncfYnqqNtnw40F421s1ORUrm3abDo1FdlL65tVevFb93uWA0v3yb42uYXt4gCSrsEjRhHdeOaFXiJqIH7MgcOKqIGBf9KspdUfd0u0NQtuAW6MgcOKUrm3qmqtr)nSuQNp9su9f0FtbRBAiGs6gXCde05uFQorPbRrxDJyUbc6CQ)gwk1ZNEjQ(c6VPG1ORWTPKJNW9KYXIhhXvHHc8fJXbjgUBAiGscjcUv0tk9m4gbDo1gw1K0sv1ORWTPKJNWnWwAEeukwGc8fJmiKy4UPHakjKi4wrpP0ZGBfNdi5mm90AkXnI5gb6gIbAk6VHLs98PxIQVG(BkyDtdbus42uYXt4gylnpckflqb(IX4djgUBAiGscjcUv0tk9m4wmqtrFQorPbRBAiGs6gXCJaDJfDJVvawO8VB8UBeeya3iMBO4CajNHPgylnpckflAA)2Ly34ncUXtUXcWTPKJNW9P6eLgmuGVyKbGed3nneqjHeb3k6jLEgCR4CajNHPNwtjUrm3qfzu2IDJ3DdXanfDvrCpF6LO6lO)Mcw30qaLeUnLC8eUb2sZJGsXcuGVymiHed3nneqjHeb3k6jLEgClgOPOpvNO0G1nneqjDJyUbc6CQpvNO0G1ORWTPKJNW9KYXIhhXvHHc8fJbbiXWTPKJNWTkYU0hz0LflWDtdbusirqb(IXNhsmC30qaLeseCRONu6zWTyGMIglMCkp5HvrgLT6MgcOKWTPKJNWnwm5uEYdRImkBHc8fJphKy4UPHakjKi4wrpP0ZG7aDdXanf9k9(gWxq)nfdCyr30qaL0ncfYned0u0R07BaFb93umWHfDtdbus3iMBSOBeOBSwrJfo97lO)MIb0MsUL1nwaUnLC8eURrLiFb93umauGVI7jiXWTPKJNWn4yJK8swpchiWDtdbusirqb(kogHed3F(YlzHVyeUBAiG6)8LxYcjcUnLC8eUNa7xpoIRcd3QGvG6fJYwbdFXiCRONu6zWnTtAXrgcOWDtdbusirqb(kU4Ged3nneqjHeb3nneq9F(YlzHeb3k6jLEgC)5l7VPOjpSyPQUX7Urqc3MsoEc3tG9RhhXvHH7pF5LSWxmcf4R4yqiXW9NV8sw4lgH7MgcO(pF5LSqIGBtjhpH7jLJfpoIRcd3nneqjHebfOafOafiea]] )

end
