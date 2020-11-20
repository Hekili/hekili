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


    spec:RegisterSetting( "funnel_damage", false, {
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
    } )


    spec:RegisterStateExpr( "funneling", function ()
        return active_enemies > 1 and settings.cycle and settings.funnel_damage
    end )


    spec:RegisterSetting( "stack_buffer", 1.1, {
        name = "Icefury and Stormkeeper Padding",
        desc = "The default priority tries to avoid wasting Stormkeeper and Icefury stacks with a grace period of 1.1 GCDs per stack.\n\n" ..
                "Increasing this number will reduce the likelihood of wasted Icefury / Stormkeeper stacks due to other procs taking priority, and leave you with more time to react.",
        type = "range",
        min = 1,
        max = 2,
        step = 0.01,
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

    spec:RegisterPack( "Elemental", 20201120, [[dCeSwbqiHWJKIOnjf(eecQrjK6ucjRcvQ6vufnlQc3skc1UOYVqLmmHkhdcwMqvpdvknnPiDniK2gekFdvkmouPOZbHO1HkvkZtkQ7br7tfvhukczHOIEieczIOsLQUOue8ruPsLtIkvYkLsntieOUjec1ovr(jecYsHqG8uPAQOcxfcb0Eb(RGblXHPSyi9ysMmcxwzZs6ZOQrtvDAv9AHYSbDBvA3I(nkdxfooeQwosphQPtCDeTDPKVRIY4HqaoVq06rLkMpvP9tQbia4a0jmzGtXhx8XHacXhNlU4q0MgxtbDjYJb6hMkMXpqpT7a9MaC3LIbb9dlsiZiaCa6ygjvnq3xKdm3nU4I)fFsuNID5c)xsOjplvuRkCH)RIlqhL8Hc3vcqbDctg4u8XfFCiGq8X5IloeTPGo(ykWP4rS4bD)NGyjaf0jgwb6nPU0eG7UumOU09TRL62nPUCI1Ax0r1L4JZdDj(4IpoDBD7Muxqe5Bj)WC30TBsDPjwxAIiigHUGAQyKh6staJxQMUyOp8LiDG(bLvF4a9MuxAcWDxkgux6(21sD7MuxoXATl6O6s8X5HUeFCXhNUTUDtQliI8TKFyUB62nPU0eRlnreeJqxqnvmYdDPjGXlvtxm0h(sKoDBDBtjplXUd6uSlQjijXl8YUEK2DinUd23OgouzPey1Wb7Sr1TnL8Se7oOtXUOM4jsUoyYZsDBD7MuxAcicyksze6YAnAK6I83PlI)0ftjmQU8yDXAzp0qHZPB3K6cIidl6cNqgJasIfD5AjPbHrQlFvxe)PlnrCNrFz6chu7fDPjkvdludQlicAywAPA6YJ1Ld6WlfNUTPKNLyKOqgJasIfp(ksJ7m6lZzPAyHAWaDywAPAULgkCe62nPUWDLnXk2f1eD5Gjpl1LhRlh0vhDP8gegPUa)m2i0fHPlI)0fU7inkXBPUWQ6ste3zuM47HUqMWHX6IIDrnrxo7HqDzjHUG9zubgPt32uYZsSNi56Gjpl94RiRpVVeO7AFIBgXIZRxfJbjyNLoEsJs8wgy1GXDgLj(o6U2N4M5240T1TBsDH7kLrPKhIUWQ6IYWc2PBBk5zj2tKCD2NebS)mQUTPKNLyprYfjEHx2fRBBk5zj2tKCvF6cdU7sXG62MsEwI9ejxyHrVHb3DPyqDBDBtjplXEIKlflvlfQjJiuH2D62MsEwI9ejxOqgJiWQbXFHL7gPUTPKNLyprYfpPrjEldSAW4oJYeFDBtjplXEIKRktrIhrW4oJ(YcOZU62MsEwI9ejxhK0Vg5N8buOHfDBtjplXEIKlXFbYeLrMeHkJQMUTPKNLyprY1DxgnYaRgGKQNiqqNDX62MsEwI9ejx0)4aUWNb8HPMUTPKNLyprY1zmkKO1(mqhMLwQMUTPKNLyprYfD2XN8Hk0Ud7XxrkgLFIZFgu8dhk5CUzCE9kgLFIZFgu8dhkP54JZR36Z7lb6U2N4M5240TBsDH7k1fLHNUWDPlvgLNj6cMDN4)jVt32uYZsSNi5YFgvcdJxQMUTUTPKNLyprYfkKXicvsAKE8vKrigCP4mSAjHLQ5wAOWr41lkzT6mSAjHLQ5ip86vXyqc2zPZWQLewQMJUR9j(CenoDBtjplXEIKl0rXJg7tEp(kYiedUuCgwTKWs1Clnu4i86fLSwDgwTKWs1CKh62MsEwI9ejx1NouiJr4XxrgHyWLIZWQLewQMBPHchHxVOK1QZWQLewQMJ8WRxfJbjyNLodRwsyPAo6U2N4Zr040TnL8Se7jsUSunSqnyqzqOhFfzeIbxkodRwsyPAULgkCeE9IswRodRwsyPAoYdVEvmgKGDw6mSAjHLQ5O7AFIphrJt32uYZsSNi5c14dSAqOVkg2JVImcXGlfNHvljSun3sdfocVEJaLSwDgwTKWs1CKh6262MsEwI9ejxh0)YOeVbdNzTMhQivWfeJYpbJebp(kYiqjRv3b9VmkXBWWzwR5ip0TnL8Se7jsUAn8XObHj7QBBk5zj2tKCvTfeQL4kj(zPUTUTPKNLyprYfLmdMsEwgGpw8iT7qAS5XxrAk5BTWYD)Hpp(grJpgegeJYpb7u(2Nb4Z7l5N8NhVxV4JbHbXO8tWoO1YcOZUNhFu62MsEwI9ejxuYmyk5zza(yXJ0Udj(tE4cIr5N4XxrgHyWLIdlm6nm4Ulfd6wAOWr0WuY3AHL7(d3mY41TnL8Se7jsUOKzWuYZYa8XIhPDhs8c4p5HligLFIhFfPyWLIdlm6nm4Ulfd6wAOWr0WuY3AHL7(d3mY41T1TnL8Se7m2qoJk(ioPfBE8vKOK1QBkF2N8bSptfZrEOBBk5zj2zS5jsUu(2NbFJ2Ayr32uYZsSZyZtKCHfg9gB7yup(ksXGlfhwy0BSTJrDlnu4i0TnL8Se7m28ejxvODxa7ZuX8qfPcUGyu(jyKi4XxrsxLoSVHcxdtjFRfiyIRcT7cyFMkwZCBdtjFRfwU7pCZiruDBtjplXoJnprYvfA3fW(mvmp(kYimL8TwGGjUk0UlG9zQy62MsEwIDgBEIKRP8zFYhW(mvmp(ksXGlf3u(Sp5dyFMkMBPHchrJRniwOS75irS40TnL8Se7m28ejxgwTKWs184RifdUuCgwTKWs1Clnu4iAeDehtCyHrVHb3DPyqNPKV1IQr0rigCP4E1QK0iDlnu4i86ncuYA19QvjPr6ipAeHIXGeSZs3RwLKgPJ8ikDBtjplXoJnprYf8rCYNiCn(RfeMSRhFfPyWLId(io5teUg)1cct21T0qHJq32uYZsSZyZtKCnJk(bSptfZJVIKsMRYO8ZnLpB4aRg4PZKaMmjg9tE3qCY)4yenIaLSwDt5ZgoWQbE6mjGjtIr)K3rEOBBk5zj2zS5jsUMrf)WG7UumOhFfjLmxLr5NJy7qO7YObSWY5gIt(hhJOr0rigCP4oO)1GHb3DPyWhlULgkCeE9gDehtCyHrVHb3DPyqNPKV1AeXXex9Plm4Ulfd6mL8TwurPBBk5zj2zS5jsUGwllGssXIhQivWfeJYpbJebp(ks8XGWGyu(jyNY3(maFEFj)KV5M61lkzT6GwllGjP8ZrE41B0IbxkURHLrdSAq8xyWDxky3sdfoIgrGswRURHLrdSAq8xyWDxkyh5rJRniwOS75irS4Is3Uj1foOrQlctx4T70LMGrfFeN0InD5Sx81feXgwgvxyvDr8NU0eG7UuW6ckzTQlN5VuxQpVV8jVUWT6Iyu(jyNUWDplrew0fwRrv2HUGi2gelu2ncDBtjplXoJnprY1mQ4J4KwS5XxrgHyWLI7Ayz0aRge)fgC3Lc2T0qHJWRxuYA1Hfg9gB7yuh5HxVxBqSqz3ZrgncXfxtCt5E8XGWGyu(jyNY3(maFEFj)KpkVErjRv31WYObwni(lm4UlfSJ8WRx8XGWGyu(jyNY3(maFEFj)K)CUv3Uj1feXwSPlys60LizK6cblrew0fidpDX0LUWO3yBhJQlOK1Qt32uYZsSZyZtKCP8TpdWN3xYp594RirjRvhwy0BSTJrD0DTpXnZTCpVIG7rjRvhwy0BSTJrDyXuX0TBsDbrOegPUOmSOlic2Az6cNKuSOlSuxeF6MUigLFcwx(QU8IU8yDXsD5tSyPOlwsOlDHrV6staU7sXG6YJ1LticXHUyk5BnNUTPKNLyNXMNi5cATSakjflE8vKOK1QdATSaMKYph5rd8XGWGyu(jyNY3(maFEFj)KV5M2i6ioM4WcJEddU7sXGotjFRfvdcM4Qq7Ua2NPI5Kxf7tED7MuxqeiE6staU7sXG6cNqdl6IXBFIfDH8qxeMUWT6Iyu(jyDXW6cKL86IH1LUWOxDPja3DPyqD5X6sYeDXuY3AoDBtjplXoJnprY1G7UumyafAyXJVIum4sXn4UlfdgqHgwClnu4iAGpgegeJYpb7u(2Nb4Z7l5N8nJOnIoIJjoSWO3WG7UumOZuY3ArPBBk5zj2zS5jsUu(2Nb4Z7l5N862MsEwIDgBEIKlO1YcOKuS4XL16tEKi4XxrIswRoO1Ycysk)CKhnumgKGDwgOZuIUTPKNLyNXMNi5QcT7cyFMkMhxwRp5rIGhQivWfeJYpbJebp(ks6Q0H9nu40TnL8Se7m28ejxvkdlbSptfZJlR1N8irq3w32uYZsSdVa(tE4cIr5NGScT7cyFMkMhQivWfeJYpbJebp(kYOP7AFIBgjVIiQgrJswRoO1Ycysk)CKhE9gbkzT6qHmgbKeloYJO0TnL8Se7WlG)KhUGyu(jEIKRb3DPyWak0WIhFfPyWLIBWDxkgmGcnS4wAOWrOBBk5zj2Hxa)jpCbXO8t8ejxyHrVX2og1JVIum4sXHfg9gB7yu3sdfoIgrFTbXcLDBUPnnkDBtjplXo8c4p5HligLFINi5AkF2N8bSptfZJVIum4sXnLp7t(a2NPI5wAOWrOBBk5zj2Hxa)jpCbXO8t8ejxqRLfqjPyXJVIeLSwDN9jrGNeloSyQynJa30RxuYA1bTwwats5NJ8q32uYZsSdVa(tE4cIr5N4jsUGpVVKFYhqzqXJVIeLSwDyHrVX2og1rEOBBk5zj2Hxa)jpCbXO8t8ejxZOIpItAXMhFfjkzT6MYNnCGvd80zsatMeJ(jVJ8q32uYZsSdVa(tE4cIr5N4jsUMrfFeN0Inp(kYOXhdcdIr5NGDkF7Za859L8t(ZriQgrhbbtCvODxa7ZuXC0vPd7BOWfLUTPKNLyhEb8N8WfeJYpXtKCnJk(bSptfZJVIeFmimigLFc2P8TpdWN3xYp5Bo(gxBqSqz3ZrIyX1iAuYA1D2NebEsS4WIPI1C8X5171gelu29CezCrPBBk5zj2Hxa)jpCbXO8t8ejxWN3xYp5dOmO4XxrgnkzT6WcJEJTDmQJUR9jUzeCiW98kcUhLSwDyHrVX2og1HftfZRxuYA1Hfg9gB7yuh5rduYA1DnSmAGvdI)cdU7sb7ipIs32uYZsSdVa(tE4cIr5N4jsUQugwcyFMkMhFfPyWLI7vRssJ0T0qHJOHyWLI7Ayz0aRge)fgC3Lc2T0qHJObkzT6E1QK0iDKhnqjRv31WYObwni(lm4UlfSJ8q32uYZsSdVa(tE4cIr5N4jsUGwllGssXIhFfjkzT6mSAjHLQ5ip0TnL8Se7WlG)KhUGyu(jEIKlO1YcOKuS4XxrQymib7SmqNPKgrigCP4UgwgnWQbXFHb3DPGDlnu4i0TnL8Se7WlG)KhUGyu(jEIKRxTkjnsp(ksXGlf3RwLKgPBPHchrJiI(AdIfk7Eo3arBOymib7S0bTwwaLKIfhDx7tCZiJlkDBtjplXo8c4p5HligLFINi5cATSakjflE8vKkgdsWold0zkPHY3O8dFUyWLIBkFwGvdI)cdU7sb7wAOWrOBBk5zj2Hxa)jpCbXO8t8ejxvkdlbSptfZJVIum4sX9QvjPr6wAOWr0aLSwDVAvsAKoYdDBtjplXo8c4p5HligLFINi5s5BFg8nARHfDBtjplXo8c4p5HligLFINi5clM8QaXJv(gLFE8vKIbxkoSyYRcepw5Bu(5wAOWrOBBk5zj2Hxa)jpCbXO8t8ejxZOIFyWDxkg0JVImcXGlf3b9Vgmm4Ulfd(yXT0qHJWRxXGlf3b9Vgmm4Ulfd(yXT0qHJOr0rCmXHfg9ggC3LIbDMs(wlkDBtjplXo8c4p5HligLFINi5c(8(s(jFaLbfDBtjplXo8c4p5HligLFINi5QcT7cyFMkMhxwRp5rIGhQivWfeJYpbJebp(ks6Q0H9nu40TnL8Se7WlG)KhUGyu(jEIKRk0UlG9zQyECzT(KhjcE8vKxwRDxkoIhlwQ25iMUTPKNLyhEb8N8WfeJYpXtKCvPmSeW(mvmpUSwFYJebDBDBtjplXo8N8WfeJYpbzfA3fW(mvmpurQGligLFcgjcE8vKrhH8QyFY71lbtCvODxa7ZuXC0DTpXnJKxr41RyWLIZWQLewQMBPHchrdcM4Qq7Ua2NPI5O7AFIBoAfJbjyNLodRwsyPAo6U2NyprjRvNHvljSunhbj1KNLr1qXyqc2zPZWQLewQMJUR9jU5MgvJOrjRvh0AzbmjLFoYdVEJaLSwDOqgJasIfh5ru62MsEwID4p5HligLFINi5YWQLewQMhFfPyWLIZWQLewQMBPHchrJOL)UZrIyX51lkzT6qHmgbKeloYJOAeTIXGeSZsh0AzbuskwC0DTpXNhxunIocXGlf3RwLKgPBPHchHxVrGswRUxTkjnsh5rJiumgKGDw6E1QK0iDKhrPBBk5zj2H)KhUGyu(jEIKRb3DPyWak0WIhFfPyWLIBWDxkgmGcnS4wAOWr0iAXGlf31WYObwni(lm4UlfSBPHchrJOrjRv31WYObwni(lm4UlfSJ8OX1gelu2TzeloVEJaLSwDxdlJgy1G4VWG7UuWoYJO86ncXGlf31WYObwni(lm4UlfSBPHchru62MsEwID4p5HligLFINi5clm6n22XOE8vKIbxkoSWO3yBhJ6wAOWr0iAQ9eH1AP4mccStXitPzU1RxQ9eH1AP4mccS7ZZr04IQr0xBqSqz3MBAtJs32uYZsSd)jpCbXO8t8ejxt5Z(KpG9zQyE8vKIbxkUP8zFYhW(mvm3sdfoIgkgdsWolDqRLfqjPyXr31(e3mY40TnL8Se7WFYdxqmk)eprYf0Azbuskw84RifdUuCt5Z(KpG9zQyULgkCenqjRv3u(Sp5dyFMkMJ8q32uYZsSd)jpCbXO8t8ejxWhXjFIW14VwqyYUE8vKIbxko4J4Kpr4A8xlimzx3sdfocDBtjplXo8N8WfeJYpXtKCbFEFj)KpGYGIhFfjkzT6WcJEJTDmQJ8Ob(yqyqmk)eSt5BFgGpVVKFY3C8nIgLSwDxdlJgy1G4VWG7UuWoYJO0TnL8Se7WFYdxqmk)eprY1mQ4J4KwS5XxrIswRUP8zdhy1apDMeWKjXOFY7ipAeDeIbxkURHLrdSAq8xyWDxky3sdfocVErjRv31WYObwni(lm4UlfSJ8ikDBtjplXo8N8WfeJYpXtKCnJk(ioPfBE8vKrJpgegeJYpb7u(2Nb4Z7l5N8NJqunIoccM4Qq7Ua2NPI5ORsh23qHlQgrhHyWLI7Ayz0aRge)fgC3Lc2T0qHJWRxuYA1DnSmAGvdI)cdU7sb7ip86vXyqc2zPdATSakjflo6U2N4ZJRX1gelu29CKiY4Js32uYZsSd)jpCbXO8t8ejxZOIFa7ZuX84RifdUuCxdlJgy1G4VWG7UuWULgkCenIgLSwDxdlJgy1G4VWG7UuWoYdVEvmgKGDw6GwllGssXIJUR9j(84ACTbXcLDphjImEVEXhdcdIr5NGDkF7Za859L8t(MJVbkzT6WcJEJTDmQJ8OHIXGeSZsh0AzbuskwC0DTpXnJKxreLxVxBqSqz3ZrIyXPBBk5zj2H)KhUGyu(jEIKl4Z7l5N8bugu84RiJgLSwDyHrVX2og1r31(e3mcoe4EEfb3JswRoSWO3yBhJ6WIPI51lkzT6WcJEJTDmQJ8ObkzT6UgwgnWQbXFHb3DPGDKhrPBBk5zj2H)KhUGyu(jEIKRkLHLa2NPI5XxrkgCP4E1QK0iDlnu4iAigCP4UgwgnWQbXFHb3DPGDlnu4iAGswRUxTkjnsh5rduYA1DnSmAGvdI)cdU7sb7ip0TnL8Se7WFYdxqmk)eprYf0Azbuskw84RirjRvNHvljSunh5HUTPKNLyh(tE4cIr5N4jsUGwllGssXIhFfPIXGeSZYaDMsAeHyWLI7Ayz0aRge)fgC3Lc2T0qHJq32uYZsSd)jpCbXO8t8ejxVAvsAKE8vKIbxkUxTkjns3sdfoIgre91gelu29CUbI2qXyqc2zPdATSakjflo6U2N4Mrgxu62MsEwID4p5HligLFINi5cATSakjflE8vKkgdsWold0zkPHY3O8dFUyWLIBkFwGvdI)cdU7sb7wAOWrOBBk5zj2H)KhUGyu(jEIKRkLHLa2NPI5XxrkgCP4E1QK0iDlnu4iAGswRUxTkjnsh5rduYA19QvjPr6O7AFIBgbhcCpVIG7rjRv3RwLKgPdlMkMUTPKNLyh(tE4cIr5N4jsUGwllGssXIhFfPIXGeSZYaDMs0TnL8Se7WFYdxqmk)eprYvfA3fW(mvmpurQGligLFcgjcE8vK0vPd7BOWPBBk5zj2H)KhUGyu(jEIKRzuXhXjTyZJVIeFmimigLFc2P8TpdWN3xYp5phHgrqjZvzu(5MYNnCGvd80zsatMeJ(jVBio5FCmcVEJgLSwDt5ZgoWQbE6mjGjtIr)K3rE0aLSwDxdlJgy1G4VWG7UuWoYJO0TnL8Se7WFYdxqmk)eprYvLYWsa7ZuX84RifdUuCVAvsAKULgkCenqjRv3RwLKgPJ8Or0OK1Q7vRssJ0r31(e3mVIG7Bk3JswRUxTkjnshwmvmVErjRvhwy0BSTJrDKhE9gHyWLI7Ayz0aRge)fgC3Lc2T0qHJikDBtjplXo8N8WfeJYpXtKCP8Tpd(gT1WIUTPKNLyh(tE4cIr5N4jsUWIjVkq8yLVr5NhFfPyWLIdlM8QaXJv(gLFULgkCe62MsEwID4p5HligLFINi5Agv8ddU7sXGE8vKrigCP4oO)1GHb3DPyWhlULgkCeE9kgCP4oO)1GHb3DPyWhlULgkCenIoIJjU6txyWDxkg0zk5BTO0TnL8Se7WFYdxqmk)eprYf859L8t(akdk62MsEwID4p5HligLFINi5QcT7cyFMkMhxwRp5rIGhQivWfeJYpbJebp(ks6Q0H9nu40TnL8Se7WFYdxqmk)eprYvfA3fW(mvmpUSwFYJebp(kYlR1UlfhXJflv7Cet32uYZsSd)jpCbXO8t8ejxvkdlbSptfZJlR1N8ira0Bnk(zj4u8XfFCiGacnf0pZO5N8yqN76EWOYi0fevxmL8SuxGpwWoDBqh(ybd4a0XFYdxqmk)eahGtia4a0xAOWra4e0nL8Se0Rq7Ua2NPIb6k6lJ(gOhTUeHUiVk2N86IxV6cbtCvODxa7ZuXC0DTpX6sZi1fEfHU41RUigCP4mSAjHLQ5wAOWrOln0fcM4Qq7Ua2NPI5O7AFI1LM1LO1ffJbjyNLodRwsyPAo6U2NyDXtDbLSwDgwTKWs1CeKutEwQlrPln0ffJbjyNLodRwsyPAo6U2NyDPzDPP6su6sdDjADbLSwDqRLfWKu(5ip0fVE1Li0fuYA1HczmcijwCKh6suGUksfCbXO8tWGtiaeWP4bCa6lnu4iaCc6k6lJ(gOlgCP4mSAjHLQ5wAOWrOln0LO1f5VtxohPUGyXPlE9QlOK1QdfYyeqsS4ip0LO0Lg6s06IIXGeSZsh0AzbuskwC0DTpX6Y56sC6su6sdDjADjcDrm4sX9QvjPr6wAOWrOlE9QlrOlOK1Q7vRssJ0rEOln0Li0ffJbjyNLUxTkjnsh5HUefOBk5zjOBy1sclvdiGtClGdqFPHchbGtqxrFz03aDXGlf3G7UumyafAyXT0qHJqxAOlrRlIbxkURHLrdSAq8xyWDxky3sdfocDPHUeTUGswRURHLrdSAq8xyWDxkyh5HU0qxU2GyHYU6sZ6cIfNU41RUeHUGswRURHLrdSAq8xyWDxkyh5HUeLU41RUeHUigCP4UgwgnWQbXFHb3DPGDlnu4i0LOaDtjplb9b3DPyWak0WcqaNAkGdqFPHchbGtqxrFz03aDXGlfhwy0BSTJrDlnu4i0Lg6s06c1EIWATuCgbb2PyKPOlnRlCRU41RUqTNiSwlfNrqGDFQlNRliAC6su6sdDjAD5AdIfk7QlnRlnTP6suGUPKNLGowy0BSTJrbc4eIc4a0xAOWra4e0v0xg9nqxm4sXnLp7t(a2NPI5wAOWrOln0ffJbjyNLoO1YcOKuS4O7AFI1LMrQlXb6MsEwc6t5Z(KpG9zQyabCcXaCa6lnu4iaCc6k6lJ(gOlgCP4MYN9jFa7ZuXClnu4i0Lg6ckzT6MYN9jFa7ZuXCKhGUPKNLGo0Azbuskwac4e3aWbOV0qHJaWjOROVm6BGUyWLId(io5teUg)1cct21T0qHJa0nL8Se0HpIt(eHRXFTGWKDbc4e3eWbOV0qHJaWjOROVm6BGokzT6WcJEJTDmQJ8qxAOl4JbHbXO8tWoLV9za(8(s(jVU0SUeVU0qxIwxqjRv31WYObwni(lm4UlfSJ8qxIc0nL8Se0HpVVKFYhqzqbiGtisahG(sdfocaNGUI(YOVb6OK1QBkF2WbwnWtNjbmzsm6N8oYdDPHUeTUeHUigCP4UgwgnWQbXFHb3DPGDlnu4i0fVE1fuYA1DnSmAGvdI)cdU7sb7ip0LOaDtjplb9zuXhXjTydiGtiehGdqFPHchbGtqxrFz03a9O1f8XGWGyu(jyNY3(maFEFj)KxxoxxqqxIsxAOlrRlrOlemXvH2DbSptfZrxLoSVHcNUeLU0qxIwxIqxedUuCxdlJgy1G4VWG7UuWULgkCe6IxV6ckzT6UgwgnWQbXFHb3DPGDKh6IxV6IIXGeSZsh0AzbuskwC0DTpX6Y56sC6sdD5AdIfk7QlNJuxqKXRlrb6MsEwc6ZOIpItAXgqaNqabahG(sdfocaNGUI(YOVb6IbxkURHLrdSAq8xyWDxky3sdfocDPHUeTUGswRURHLrdSAq8xyWDxkyh5HU41RUOymib7S0bTwwaLKIfhDx7tSUCUUeNU0qxU2GyHYU6Y5i1fez86IxV6c(yqyqmk)eSt5BFgGpVVKFYRlnRlXRln0fuYA1Hfg9gB7yuh5HU0qxumgKGDw6GwllGssXIJUR9jwxAgPUWRi0LO0fVE1LRniwOSRUCosDbXId0nL8Se0Nrf)a2NPIbeWjeIhWbOV0qHJaWjOROVm6BGE06ckzT6WcJEJTDmQJUR9jwxAwxqWHGUW96cVIqx4EDbLSwDyHrVX2og1Hftftx86vxqjRvhwy0BSTJrDKh6sdDbLSwDxdlJgy1G4VWG7UuWoYdDjkq3uYZsqh(8(s(jFaLbfGaoHa3c4a0xAOWra4e0v0xg9nqxm4sX9QvjPr6wAOWrOln0fXGlf31WYObwni(lm4UlfSBPHchHU0qxqjRv3RwLKgPJ8qxAOlOK1Q7Ayz0aRge)fgC3Lc2rEa6MsEwc6vkdlbSptfdiGti0uahG(sdfocaNGUI(YOVb6OK1QZWQLewQMJ8a0nL8Se0HwllGssXcqaNqarbCa6lnu4iaCc6k6lJ(gORymib7SmqNPeDPHUeHUigCP4UgwgnWQbXFHb3DPGDlnu4iaDtjplbDO1YcOKuSaeWjeqmahG(sdfocaNGUI(YOVb6IbxkUxTkjns3sdfocDPHUeHUeTUCTbXcLD1LZ1fUbIQln0ffJbjyNLoO1YcOKuS4O7AFI1LMrQlXPlrb6MsEwc6VAvsAKabCcbUbGdqFPHchbGtqxrFz03aDfJbjyNLb6mLOln0fLVr5hwxoxxedUuCt5ZcSAq8xyWDxky3sdfocq3uYZsqhATSakjflabCcbUjGdqFPHchbGtqxrFz03aDXGlf3RwLKgPBPHchHU0qxqjRv3RwLKgPJ8qxAOlOK1Q7vRssJ0r31(eRlnRli4qqx4EDHxrOlCVUGswRUxTkjnshwmvmq3uYZsqVszyjG9zQyabCcbejGdqFPHchbGtqxrFz03aDfJbjyNLb6mLa6MsEwc6qRLfqjPybiGtXhhGdqFPHchbGtq3uYZsqVcT7cyFMkgOROVm6BGoDv6W(gkCGUksfCbXO8tWGtiaeWP4raWbOV0qHJaWjOROVm6BGo(yqyqmk)eSt5BFgGpVVKFYRlNRliOln0Li0fkzUkJYp3u(SHdSAGNotcyYKy0p5DdXj)JJrOlE9QlrRlOK1QBkF2WbwnWtNjbmzsm6N8oYdDPHUGswRURHLrdSAq8xyWDxkyh5HUefOBk5zjOpJk(ioPfBabCk(4bCa6lnu4iaCc6k6lJ(gOlgCP4E1QK0iDlnu4i0Lg6ckzT6E1QK0iDKh6sdDjADbLSwDVAvsAKo6U2NyDPzDHxrOlCVU0uDH71fuYA19QvjPr6WIPIPlE9QlOK1Qdlm6n22XOoYdDXRxDjcDrm4sXDnSmAGvdI)cdU7sb7wAOWrOlrb6MsEwc6vkdlbSptfdiGtXZTaoaDtjplbDLV9zW3OTgwa9LgkCeaobc4u8nfWbOV0qHJaWjOROVm6BGUyWLIdlM8QaXJv(gLFULgkCeGUPKNLGowm5vbIhR8nk)ac4u8ikGdqFPHchbGtqxrFz03a9i0fXGlf3b9Vgmm4Ulfd(yXT0qHJqx86vxedUuCh0)AWWG7Uum4Jf3sdfocDPHUeTUeHUCmXvF6cdU7sXGotjFRPlrb6MsEwc6ZOIFyWDxkgeiGtXJyaoaDtjplbD4Z7l5N8bugua9LgkCeaobc4u8CdahG(L16tEWjea9LgkCHlR1N8aobDtjplb9k0UlG9zQyGUksfCbXO8tWGtia6k6lJ(gOtxLoSVHchOV0qHJaWjqaNINBc4a0xAOWra4e0xAOWfUSwFYd4e0v0xg9nq)YAT7sXr8yXs10LZ1fed0nL8Se0Rq7Ua2NPIb6xwRp5bNqaiGtXJibCa6xwRp5bNqa0xAOWfUSwFYd4e0nL8Se0RugwcyFMkgOV0qHJaWjqacOtSQrcfahGtia4a0xAOWraqbDf9LrFd0nUZOVmNLQHfQbd0HzPLQ5wAOWra6MsEwc6OqgJasIfGaofpGdqFPHchbGtqxrFz03a96Z7lb6U2NyDPzDbXItx86vxumgKGDw64jnkXBzGvdg3zuM47O7AFI1LM1fUnoq3uYZsq)Gjplbc4e3c4a0nL8Se0p7tIa2Fgf0xAOWra4eiGtnfWbOBk5zjOtIx4LDXG(sdfocaNabCcrbCa6MsEwc61NUWG7UumiOV0qHJaWjqaNqmahGUPKNLGowy0ByWDxkge0xAOWra4eiGtCdahGUPKNLGUILQLc1KreQq7oqFPHchbGtGaoXnbCa6MsEwc6OqgJiWQbXFHL7gjOV0qHJaWjqaNqKaoaDtjplbDEsJs8wgy1GXDgLj(G(sdfocaNabCcH4aCa6MsEwc6vMIepIGXDg9LfqNDb9LgkCeaobc4ecia4a0nL8Se0piPFnYp5dOqdlG(sdfocaNabCcH4bCa6MsEwc6I)cKjkJmjcvgvnqFPHchbGtGaoHa3c4a0nL8Se0V7YOrgy1aKu9ebc6Slg0xAOWra4eiGti0uahGUPKNLGo9poGl8zaFyQb6lnu4iaCceWjequahGUPKNLG(zmkKO1(mqhMLwQgOV0qHJaWjqaNqaXaCa6lnu4iaCc6k6lJ(gOlgLFIZFgu8dhkrxoxx4MXPlE9QlIr5N48Nbf)WHs0LM1L4Jtx86vxQpVVeO7AFI1LM1fUnoq3uYZsqNo74t(qfA3Hbc4ecCdahGUPKNLGU)mQeggVunqFPHchbGtGaoHa3eWbOV0qHJaWjOROVm6BGEe6IyWLIZWQLewQMBPHchHU41RUGswRodRwsyPAoYdDXRxDrXyqc2zPZWQLewQMJUR9jwxoxxq04aDtjplbDuiJreQK0ibc4ecisahG(sdfocaNGUI(YOVb6rOlIbxkodRwsyPAULgkCe6IxV6ckzT6mSAjHLQ5ipaDtjplbD0rXJg7tEGaofFCaoa9LgkCeaobDf9LrFd0JqxedUuCgwTKWs1Clnu4i0fVE1fuYA1zy1sclvZrEOlE9QlkgdsWolDgwTKWs1C0DTpX6Y56cIghOBk5zjOxF6qHmgbqaNIhbahG(sdfocaNGUI(YOVb6rOlIbxkodRwsyPAULgkCe6IxV6ckzT6mSAjHLQ5ip0fVE1ffJbjyNLodRwsyPAo6U2NyD5CDbrJd0nL8Se0TunSqnyqzqiqaNIpEahG(sdfocaNGUI(YOVb6rOlIbxkodRwsyPAULgkCe6IxV6se6ckzT6mSAjHLQ5ipaDtjplbDuJpWQbH(QyyGaofp3c4a0xAOWra4e0nL8Se0pO)LrjEdgoZAnqxrFz03a9i0fuYA1Dq)lJs8gmCM1AoYdqxfPcUGyu(jyWjeac4u8nfWbOBk5zjO3A4Jrdct2f0xAOWra4eiGtXJOaoaDtjplb9QTGqTexjXplb9LgkCeaobc4u8igGdqFPHchbGtqxrFz03aDtjFRfwU7pSUCUUeVU0qxIwxWhdcdIr5NGDkF7Za859L8tED5CDjEDXRxDbFmimigLFc2bTwwaD2vxoxxIxxIc0nL8Se0PKzWuYZYa8XcOdFSes7oq3ydiGtXZnaCa6lnu4iaCc6k6lJ(gOhHUigCP4WcJEddU7sXGULgkCe6sdDXuY3AHL7(dRlnJuxIh0nL8Se0PKzWuYZYa8XcOdFSes7oqh)jpCbXO8tac4u8CtahG(sdfocaNGUI(YOVb6IbxkoSWO3WG7UumOBPHchHU0qxmL8Twy5U)W6sZi1L4bDtjplbDkzgmL8SmaFSa6WhlH0Ud0XlG)KhUGyu(jabiG(bDk2f1eahGtia4a0xAOWra4e0t7oq34oyFJA4qLLsGvdhSZgf0nL8Se0nUd23OgouzPey1Wb7Srbc4u8aoaDtjplb9dM8Se0xAOWra4eiab0n2aCaoHaGdqFPHchbGtqxrFz03aDuYA1nLp7t(a2NPI5ipaDtjplb9zuXhXjTydiGtXd4a0nL8Se0v(2NbFJ2Ayb0xAOWra4eiGtClGdqFPHchbGtqxrFz03aDXGlfhwy0BSTJrDlnu4iaDtjplbDSWO3yBhJceWPMc4a0xAOWra4e0nL8Se0Rq7Ua2NPIb6k6lJ(gOtxLoSVHcNU0qxmL8TwGGjUk0UlG9zQy6sZ6c3Qln0ftjFRfwU7pSU0msDbrbDvKk4cIr5NGbNqaiGtikGdqFPHchbGtqxrFz03a9i0ftjFRfiyIRcT7cyFMkgOBk5zjOxH2DbSptfdiGtigGdqFPHchbGtqxrFz03aDXGlf3u(Sp5dyFMkMBPHchHU0qxU2GyHYU6Y5i1feloq3uYZsqFkF2N8bSptfdiGtCdahG(sdfocaNGUI(YOVb6IbxkodRwsyPAULgkCe6sdDjADjcD5yIdlm6nm4Ulfd6mL8TMUeLU0qxIwxIqxedUuCVAvsAKULgkCe6IxV6se6ckzT6E1QK0iDKh6sdDjcDrXyqc2zP7vRssJ0rEOlrb6MsEwc6gwTKWs1ac4e3eWbOV0qHJaWjOROVm6BGUyWLId(io5teUg)1cct21T0qHJa0nL8Se0HpIt(eHRXFTGWKDbc4eIeWbOV0qHJaWjOROVm6BGoLmxLr5NBkF2WbwnWtNjbmzsm6N8UH4K)XXi0Lg6se6ckzT6MYNnCGvd80zsatMeJ(jVJ8a0nL8Se0Nrf)a2NPIbeWjeIdWbOV0qHJaWjOROVm6BGoLmxLr5NJy7qO7YObSWY5gIt(hhJqxAOlrRlrOlIbxkUd6FnyyWDxkg8XIBPHchHU41RUeTUeHUCmXHfg9ggC3LIbDMs(wtxAOlrOlhtC1NUWG7UumOZuY3A6su6suGUPKNLG(mQ4hgC3LIbbc4ecia4a0xAOWra4e0nL8Se0HwllGssXcOROVm6BGo(yqyqmk)eSt5BFgGpVVKFYRlnRlnvx86vxqjRvh0AzbmjLFoYdDXRxDjADrm4sXDnSmAGvdI)cdU7sb7wAOWrOln0Li0fuYA1DnSmAGvdI)cdU7sb7ip0Lg6Y1gelu2vxohPUGyXPlrb6QivWfeJYpbdoHaqaNqiEahG(sdfocaNGUI(YOVb6rOlIbxkURHLrdSAq8xyWDxky3sdfocDXRxDbLSwDyHrVX2og1rEOlE9QlxBqSqzxD5CK6s06ccXfNU0eRlnvx4EDbFmimigLFc2P8TpdWN3xYp51LO0fVE1fuYA1DnSmAGvdI)cdU7sb7ip0fVE1f8XGWGyu(jyNY3(maFEFj)Kxxoxx4wq3uYZsqFgv8rCsl2ac4ecClGdqFPHchbGtqxrFz03aDuYA1Hfg9gB7yuhDx7tSU0SUWT6c3Rl8kcDH71fuYA1Hfg9gB7yuhwmvmq3uYZsqx5BFgGpVVKFYdeWjeAkGdqFPHchbGtqxrFz03aDuYA1bTwwats5NJ8qxAOl4JbHbXO8tWoLV9za(8(s(jVU0SU0uDPHUeTUeHUCmXHfg9ggC3LIbDMs(wtxIsxAOlemXvH2DbSptfZjVk2N8GUPKNLGo0Azbuskwac4ecikGdqFPHchbGtqxrFz03aDXGlf3G7UumyafAyXT0qHJqxAOl4JbHbXO8tWoLV9za(8(s(jVU0SUGO6sdDjADjcD5yIdlm6nm4Ulfd6mL8TMUefOBk5zjOp4UlfdgqHgwac4ecigGdq3uYZsqx5BFgGpVVKFYd6lnu4iaCceWje4gaoa9LgkCeaob9LgkCHlR1N8aobDf9LrFd0rjRvh0AzbmjLFoYdDPHUOymib7SmqNPeq3uYZsqhATSakjflG(L16tEWjeac4ecCtahG(L16tEWjea9LgkCHlR1N8aobDtjplb9k0UlG9zQyGUksfCbXO8tWGtia6k6lJ(gOtxLoSVHchOV0qHJaWjqaNqarc4a0VSwFYdoHaOV0qHlCzT(KhWjOBk5zjOxPmSeW(mvmqFPHchbGtGaeqhVa(tE4cIr5Na4aCcbahG(sdfocaNGUPKNLGEfA3fW(mvmqxrFz03a9O1f6U2NyDPzK6cVIqxIsxAOlrRlOK1QdATSaMKYph5HU41RUeHUGswRouiJrajXIJ8qxIc0vrQGligLFcgCcbGaofpGdqFPHchbGtqxrFz03aDXGlf3G7UumyafAyXT0qHJa0nL8Se0hC3LIbdOqdlabCIBbCa6lnu4iaCc6k6lJ(gOlgCP4WcJEJTDmQBPHchHU0qxIwxU2GyHYU6sZ6stBQUefOBk5zjOJfg9gB7yuGao1uahG(sdfocaNGUI(YOVb6IbxkUP8zFYhW(mvm3sdfocq3uYZsqFkF2N8bSptfdiGtikGdqFPHchbGtqxrFz03aDuYA1D2NebEsS4WIPIPlnRliWn1fVE1fuYA1bTwwats5NJ8a0nL8Se0HwllGssXcqaNqmahG(sdfocaNGUI(YOVb6OK1Qdlm6n22XOoYdq3uYZsqh(8(s(jFaLbfGaoXnaCa6lnu4iaCc6k6lJ(gOJswRUP8zdhy1apDMeWKjXOFY7ipaDtjplb9zuXhXjTydiGtCtahG(sdfocaNGUI(YOVb6rRl4JbHbXO8tWoLV9za(8(s(jVUCUUGGUeLU0qxIwxIqxiyIRcT7cyFMkMJUkDyFdfoDjkq3uYZsqFgv8rCsl2ac4eIeWbOV0qHJaWjOROVm6BGo(yqyqmk)eSt5BFgGpVVKFYRlnRlXRln0LRniwOSRUCosDbXItxAOlrRlOK1Q7Spjc8KyXHftftxAwxIpoDXRxD5AdIfk7QlNRliY40LOaDtjplb9zuXpG9zQyabCcH4aCa6lnu4iaCc6k6lJ(gOhTUGswRoSWO3yBhJ6O7AFI1LM1feCiOlCVUWRi0fUxxqjRvhwy0BSTJrDyXuX0fVE1fuYA1Hfg9gB7yuh5HU0qxqjRv31WYObwni(lm4UlfSJ8qxIc0nL8Se0HpVVKFYhqzqbiGtiGaGdqFPHchbGtqxrFz03aDXGlf3RwLKgPBPHchHU0qxedUuCxdlJgy1G4VWG7UuWULgkCe6sdDbLSwDVAvsAKoYdDPHUGswRURHLrdSAq8xyWDxkyh5bOBk5zjOxPmSeW(mvmGaoHq8aoa9LgkCeaobDf9LrFd0rjRvNHvljSunh5bOBk5zjOdTwwaLKIfGaoHa3c4a0xAOWra4e0v0xg9nqxXyqc2zzGotj6sdDjcDrm4sXDnSmAGvdI)cdU7sb7wAOWra6MsEwc6qRLfqjPybiGti0uahG(sdfocaNGUI(YOVb6IbxkUxTkjns3sdfocDPHUeHUeTUCTbXcLD1LZ1fUbIQln0ffJbjyNLoO1YcOKuS4O7AFI1LMrQlXPlrb6MsEwc6VAvsAKabCcbefWbOV0qHJaWjOROVm6BGUIXGeSZYaDMs0Lg6IY3O8dRlNRlIbxkUP8zbwni(lm4UlfSBPHchbOBk5zjOdTwwaLKIfGaoHaIb4a0xAOWra4e0v0xg9nqxm4sX9QvjPr6wAOWrOln0fuYA19QvjPr6ipaDtjplb9kLHLa2NPIbeWje4gaoaDtjplbDLV9zW3OTgwa9LgkCeaobc4ecCtahG(sdfocaNGUI(YOVb6IbxkoSyYRcepw5Bu(5wAOWra6MsEwc6yXKxfiESY3O8diGtiGibCa6lnu4iaCc6k6lJ(gOhHUigCP4oO)1GHb3DPyWhlULgkCe6IxV6IyWLI7G(xdggC3LIbFS4wAOWrOln0LO1Li0LJjoSWO3WG7UumOZuY3A6suGUPKNLG(mQ4hgC3LIbbc4u8Xb4a0nL8Se0HpVVKFYhqzqb0xAOWra4eiGtXJaGdq)YA9jp4ecG(sdfUWL16tEaNGUPKNLGEfA3fW(mvmqxfPcUGyu(jyWjeaDf9LrFd0PRsh23qHd0xAOWra4eiGtXhpGdqFPHchbGtqFPHcx4YA9jpGtqxrFz03a9lR1UlfhXJflvtxoxxqmq3uYZsqVcT7cyFMkgOFzT(KhCcbGaofp3c4a0VSwFYdoHaOV0qHlCzT(KhWjOBk5zjOxPmSeW(mvmqFPHchbGtGaeGa6gP4ZOGE)VKqtEwIiIAvbiabaa]] )

end
