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

    spec:RegisterPack( "Elemental", 20201120.1, [[dG0(ybqiQsEKQuXMKcFsvQcJsIYPKOAvse8kQIMfvHBHkP0UOYVqLAysrogcAzsKEgcW0qLW1qaTnuj5BOsKXPkv6CQsvToujvnpPOUhcTpeOdIkPYcrf9qvPkAIsekCrjc5JOsk4KQsvALsPMPeHIUjQKI2PQKFkrOYsLiu1tLQPIkCvjcL6ROsk0Eb9xbdwOdtzXq8yctgrxwzZs6ZOQrtvDAvETeA2a3wvTBr)gLHRkoUerlhPNd10jDDiTDPKVRkLXlrOKZtvQ1JkrnFjy)enKqihWoPPd(Q0MkTjcjS0MCn9UeabsaLc7Q3pd2FmrrJFWEA)b7LiW(lvda7pM3aMrc5a2XmuQyWUVQpyUEU5M)uFueNG95gFFuGPhlfuRQCJVVGByhb9a67nHiWoPPd(Q0MkTjcjS0MCn9UeabsaWo(zc4Rs5QsHD)JKCjeb2jhwa7VJmwIa7VunGm29TVLY2VJm(I1AFKrLXsBYdzS0MkTjzBz73rgFp9TKFyUEz73rg5ALrUosYrkJiMOi6JmwIW4LIjJgYbo1BhS)qz1dmy)DKXsey)LQbKXUV9Tu2(DKXxSw7JmQmwAtEiJL2uPnjBlB)oY47PVL8dZ1lB)oYixRmY1rsoszeXefrFKXsegVumz0qoWPE7KTLTnHESe7EOtW(iMsefVWP77rA)r04YyFJA4qLLAGvdpS3gv22e6XsS7Hob7JyQNe5(HPhlLTLTFhzSevI1eO6iLX1AuVLr9(tgv)jJMqzuz8WYO1YoGHaMt2(DKX3tdRYiNagJeGIvz8BjQbaElJxvgv)jJCDC5rpDYihu7uzKRlfdRudiJL4hMLwkMmEyz8Ho8s1jBBc9yjMicGXibOy1JRs04YJE6CwkgwPgiqhMLwkMBPHagPS97iJV3KRvW(iMkJpm9yPmEyz8HU6Ol1ZaaVLrWLfhPmQmzu9NmY1aQrjplLrwvg564YJYuFpKr0emmwgfSpIPY4BhaiJljLrSpJQaVDY2MqpwI9Ki3pm9yPhxLy9491aDF7sCZCvtfkiymaj7T0XJAuYZYaRgmU8Om13r33Ue3mb0KSTS97iJV3uhLI(OYiRkJcdRyNSTj0JLypjY9BxsgW(ZOY2MqpwI9Ki3O4foDFSSTj0JLypjYD9OlmW(lvdiBBc9yj2tICJvg9hgy)LQbKTLTnHESe7jrUfSuSuPMoYqfy)jBBc9yj2tICJaymYaRgu)fwUV3Y2MqpwI9Ki38OgL8SmWQbJlpkt9LTnHESe7jrURmbkEKbJlp6PlGm7lBBc9yj2tIC)GsVQ3xYhqagwLTnHESe7jrUv)fqtegAsgQmQyY2MqpwI9Ki3)9zuVdSAaGkoYajD2hlBBc9yj2tICtVNhWcxgWpMyY2MqpwI9Ki3VXOaYw7YaDywAPyY2MqpwI9Ki30zpxYhQa7pShxLOAu(Po)za1p8iuc(UnvOGAu(Po)za1p8i0MlTPcfQhVVgO7BxIBMaAs2(DKX3BkJcdpz89kJvgLNPYiM9N6FjVt22e6XsSNe52FgvddJxkMSTSTj0JLypjYncGXidvuQ3ECvIEPgyP6mSyjPLI5wAiGrwOacAT6mSyjPLI5qFkuqWyas2BPZWILKwkMJUVDjMGeytY2MqpwI9Ki3iJIhT4L8ECvIEPgyP6mSyjPLI5wAiGrwOacAT6mSyjPLI5qFKTnHESe7jrURhDiagJ0JRs0l1alvNHfljTum3sdbmYcfqqRvNHfljTumh6tHccgdqYElDgwSK0sXC09TlXeKaBs22e6XsSNe52sXWk1abHbaECvIEPgyP6mSyjPLI5wAiGrwOacAT6mSyjPLI5qFkuqWyas2BPZWILKwkMJUVDjMGeytY2MqpwI9Ki3igFGvdk9efXECvIEPgyP6mSyjPLI5wAiGrwOGxiO1QZWILKwkMd9r2w22e6XsSNe5(HEFgL8mq4nR18q4TaSGAu(PyIe6Xvj6fcAT6EO3NrjpdeEZAnh6JSTj0JLypjYDRHFgnOmDFzBtOhlXEsK7QTGsTexrXhlLTLTnHESe7jrUPOzWe6XYa4WQhP9hrJnpUkrtOxRfwU)nmblTrz4Nbab1O8tXoHVDzaC8(AEjpblTqb8ZaGGAu(PyhWAzbKzFcwA5Y2MqpwI9Ki3u0myc9yzaCy1J0(Ji(sEWcQr5N6Xvj6LAGLQdRm6pmW(lvd4wAiGr2We61AHL7Fd3mXsLTnHESe7jrUPOzWe6XYa4WQhP9hr8c4l5blOgLFQhxLOAGLQdRm6pmW(lvd4wAiGr2We61AHL7Fd3mXsLTLTnHESe7m2ioJQ(Le1kopUkre0A1nHp7s(a2Njk6qFKTnHESe7m28Ki3cF7YGVrBnSkBBc9yj2zS5jrUXkJ(lU9mQhxLOAGLQdRm6V42ZOULgcyKY2MqpwIDgBEsK7kW(lG9zIIEi8wawqnk)umrc94QePRsh23qaRHj0R1cKm1vb2FbSptuSzcOHj0R1cl3)gUzIeOSTj0JLyNXMNe5UcS)cyFMOOhxLOxMqVwlqYuxfy)fW(mrrzBtOhlXoJnpjY9e(Sl5dyFMOOhxLOAGLQBcF2L8bSptu0T0qaJSX3gaRu2NGe5QMKTnHESe7m28Ki3gwSK0sX84QevdSuDgwSK0sXClneWiBuMxptDyLr)Hb2FPAaNj0R1kVrzEPgyP6oXQOuVDlneWiluWle0A1DIvrPE7qFA4LGXaKS3s3jwfL6Td9PCzBtOhlXoJnpjYn4kj6rg(g)3ckt33JRsunWs1bUsIEKHVX)TGY09DlneWiLTnHESe7m28Ki3ZOQFa7Zef94QePO5Qmk)Ct4ZgoWQbE6mnGrtYrVK3TsIEppJSHxiO1QBcF2WbwnWtNPbmAso6L8o0hzBtOhlXoJnpjY9mQ6hgy)LQb84QePO5Qmk)CKBpkDFgnGvwo3kj698mYgL5LAGLQ7HEFdegy)LQboS6wAiGrwOqzE9m1Hvg9hgy)LQbCMqVwRHxptD1JUWa7VunGZe61ALxUSTj0JLyNXMNe5gyTSackfREi8wawqnk)umrc94QeXpdacQr5NIDcF7Ya44918s(M5IcfqqRvhWAzbmkLFo0NcfktnWs19nSoAGvdQ)cdS)sf7wAiGr2Wle0A19nSoAGvdQ)cdS)sf7qFA8TbWkL9jirUQPYLTFhzKdQ3YOYKrE7pzSezu1VKOwXjJVDQVmY10W6OYiRkJQ)KXsey)LkwgrqRvz8n)LYy9491l5LrcqgvJYpf7KXsmy57HkJSwJkShzKRPnawPSVxY2MqpwIDgBEsK7zu1VKOwX5Xvj6LAGLQ7ByD0aRgu)fgy)Lk2T0qaJSqbe0A1Hvg9xC7zuh6tHcFBaSszFcsSmcBQjUwUOeWpdacQr5NIDcF7Ya44918s(YluabTwDFdRJgy1G6VWa7VuXo0NcfWpdacQr5NIDcF7Ya44918sEcsaY2VJmY10kozeJsNm6ndvgjz57HkJagEYOjJDLr)f3EgvgrqRvNSTj0JLyNXMNe5w4BxgahVVMxY7XvjIGwRoSYO)IBpJ6O7BxIBMakbEbzjGGwRoSYO)IBpJ6WQjkkB)oYyjUe4TmkmSkJLyATmzKtukwLrwkJQpDtgvJYpflJxvgpvgpSmAPmEjwTuLrljLXUYOFzSeb2FPAaz8WY4RsCCiJMqVwZjBBc9yj2zS5jrUbwllGGsXQhxLicAT6awllGrP8ZH(0a)maiOgLFk2j8TldGJ3xZl5BMlAuMxptDyLr)Hb2FPAaNj0R1kVbjtDvG9xa7ZefD6jkEjVS97iJLyJNmwIa7VunGmYjWWQmA82LyvgrFKrLjJeGmQgLFkwgnSmcyjVmAyzSRm6xglrG9xQgqgpSmMmvgnHETMt22e6XsSZyZtICpW(lvdeqagw94QevdSuDdS)s1abeGHv3sdbmYg4Nbab1O8tXoHVDzaC8(AEjFZeyJY86zQdRm6pmW(lvd4mHETw5Y2MqpwIDgBEsKBHVDzaC8(AEjVSTj0JLyNXMNe5gyTSackfRE8zTUKNiHECvIiO1QdyTSagLYph6tdbJbizVLb6mHkBBc9yj2zS5jrURa7Va2Njk6XN16sEIe6HWBbyb1O8tXej0JRsKUkDyFdbmzBtOhlXoJnpjYDLYWAa7Zef94ZADjprcLTLTnHESe7WlGVKhSGAu(PeRa7Va2Njk6HWBbyb1O8tXej0JRsSm6(2L4MjYlilVrziO1QdyTSagLYph6tHcEHGwRoeaJrcqXQd9PCzBtOhlXo8c4l5blOgLFQNe5EG9xQgiGamS6XvjQgyP6gy)LQbciadRULgcyKY2MqpwID4fWxYdwqnk)upjYnwz0FXTNr94QevdSuDyLr)f3Eg1T0qaJSrzFBaSsz)M5cUOCzBtOhlXo8c4l5blOgLFQNe5EcF2L8bSptu0JRsunWs1nHp7s(a2Njk6wAiGrkBBc9yj2HxaFjpyb1O8t9Ki3aRLfqqPy1JRsebTwDVDjzGhfRoSAIInt47wOacAT6awllGrP8ZH(iBBc9yj2HxaFjpyb1O8t9Ki3GJ3xZl5dimG6XvjIGwRoSYO)IBpJ6qFKTnHESe7WlGVKhSGAu(PEsK7zu1VKOwX5XvjIGwRUj8zdhy1apDMgWOj5OxY7qFKTnHESe7WlGVKhSGAu(PEsK7zu1VKOwX5Xvjwg(zaqqnk)uSt4BxgahVVMxYtqclVrzErYuxfy)fW(mrrhDv6W(gcyLlBBc9yj2HxaFjpyb1O8t9Ki3ZOQFa7Zef94QeXpdacQr5NIDcF7Ya44918s(MlTX3gaRu2NGe5QMAugcAT6E7sYapkwDy1efBU0Mku4BdGvk7tW3VPYLTnHESe7WlGVKhSGAu(PEsKBWX7R5L8begq94QeldbTwDyLr)f3Eg1r33Ue3mHoclbEbzjGGwRoSYO)IBpJ6WQjkwOacAT6WkJ(lU9mQd9PbcAT6(gwhnWQb1FHb2FPIDOpLlBBc9yj2HxaFjpyb1O8t9Ki3vkdRbSptu0JRsunWs1DIvrPE7wAiGr2qnWs19nSoAGvdQ)cdS)sf7wAiGr2abTwDNyvuQ3o0NgiO1Q7ByD0aRgu)fgy)Lk2H(iBBc9yj2HxaFjpyb1O8t9Ki3aRLfqqPy1JRsebTwDgwSK0sXCOpY2MqpwID4fWxYdwqnk)upjYnWAzbeukw94QefmgGK9wgOZeAdVudSuDFdRJgy1G6VWa7VuXULgcyKY2MqpwID4fWxYdwqnk)upjY9jwfL6ThxLOAGLQ7eRIs92T0qaJSHxL9TbWkL9jixIaBiymaj7T0bSwwabLIvhDF7sCZeBQCzBtOhlXo8c4l5blOgLFQNe5gyTSackfRECvIcgdqYEld0zcTHW3O8dtq1alv3e(SaRgu)fgy)Lk2T0qaJu22e6XsSdVa(sEWcQr5N6jrURugwdyFMOOhxLOAGLQ7eRIs92T0qaJSbcAT6oXQOuVDOpY2MqpwID4fWxYdwqnk)upjYTW3Um4B0wdRY2MqpwID4fWxYdwqnk)upjYnwn9ebYdl8nk)84QevdSuDy10teipSW3O8ZT0qaJu22e6XsSdVa(sEWcQr5N6jrUNrv)Wa7VunGhxLOxQbwQUh69nqyG9xQg4WQBPHagzHcQbwQUh69nqyG9xQg4WQBPHagzJY86zQdRm6pmW(lvd4mHETw5Y2MqpwID4fWxYdwqnk)upjYn44918s(acdOY2MqpwID4fWxYdwqnk)upjYDfy)fW(mrrp(SwxYtKqpeElalOgLFkMiHECvI0vPd7BiGjBBc9yj2HxaFjpyb1O8t9Ki3vG9xa7Zef94ZADjprc94Qe)Sw7VuDKhwTumcYvY2MqpwID4fWxYdwqnk)upjYDLYWAa7Zef94ZADjprcLTLTnHESe7WxYdwqnk)uIvG9xa7Zef9q4TaSGAu(PyIe6XvjwMx6jkEjFHcKm1vb2FbSptu0r33Ue3mrEbzHcQbwQodlwsAPyULgcyKnizQRcS)cyFMOOJUVDjU5YemgGK9w6mSyjPLI5O7BxI9ebTwDgwSK0sXCKOutpwwEdbJbizVLodlwsAPyo6(2L4M5IYBugcAT6awllGrP8ZH(uOGxiO1QdbWyKauS6qFkx22e6XsSdFjpyb1O8t9Ki3gwSK0sX84QevdSuDgwSK0sXClneWiBuME)rqICvtfkGGwRoeaJrcqXQd9P8gLjymaj7T0bSwwabLIvhDF7smbBQ8gL5LAGLQ7eRIs92T0qaJSqbVqqRv3jwfL6Td9PHxcgdqYElDNyvuQ3o0NYLTnHESe7WxYdwqnk)upjY9a7Vunqabyy1JRsunWs1nW(lvdeqagwDlneWiBuMAGLQ7ByD0aRgu)fgy)Lk2T0qaJSrziO1Q7ByD0aRgu)fgy)Lk2H(04BdGvk73mx1uHcEHGwRUVH1rdSAq9xyG9xQyh6t5fk4LAGLQ7ByD0aRgu)fgy)Lk2T0qaJSCzBtOhlXo8L8GfuJYp1tICJvg9xC7zupUkr1alvhwz0FXTNrDlneWiBug1oYWATuDgjj2jyOP2mbuOa1oYWATuDgjj2DjbjWMkVrzFBaSsz)M5cUOCzBtOhlXo8L8GfuJYp1tICpHp7s(a2Njk6XvjQgyP6MWNDjFa7ZefDlneWiBiymaj7T0bSwwabLIvhDF7sCZeBs22e6XsSdFjpyb1O8t9Ki3aRLfqqPy1JRsunWs1nHp7s(a2Njk6wAiGr2abTwDt4ZUKpG9zIIo0hzBtOhlXo8L8GfuJYp1tICdUsIEKHVX)TGY0994QevdSuDGRKOhz4B8FlOmDF3sdbmszBtOhlXo8L8GfuJYp1tICdoEFnVKpGWaQhxLicAT6WkJ(lU9mQd9Pb(zaqqnk)uSt4BxgahVVMxY3CPnkdbTwDFdRJgy1G6VWa7VuXo0NYLTnHESe7WxYdwqnk)upjY9mQ6xsuR484QerqRv3e(SHdSAGNotdy0KC0l5DOpnkZl1alv33W6ObwnO(lmW(lvSBPHagzHciO1Q7ByD0aRgu)fgy)Lk2H(uUSTj0JLyh(sEWcQr5N6jrUNrv)sIAfNhxLyz4Nbab1O8tXoHVDzaC8(AEjpbjS8gL5fjtDvG9xa7ZefD0vPd7BiGvEJY8snWs19nSoAGvdQ)cdS)sf7wAiGrwOacAT6(gwhnWQb1FHb2FPIDOpfkiymaj7T0bSwwabLIvhDF7smbBQX3gaRu2NGeF)slx22e6XsSdFjpyb1O8t9Ki3ZOQFa7Zef94QevdSuDFdRJgy1G6VWa7VuXULgcyKnkdbTwDFdRJgy1G6VWa7VuXo0NcfemgGK9w6awllGGsXQJUVDjMGn14BdGvk7tqIVFPfkGFgaeuJYpf7e(2LbWX7R5L8nxAde0A1Hvg9xC7zuh6tdbJbizVLoG1YciOuS6O7BxIBMiVGS8cf8snWs19nSoAGvdQ)cdS)sf7wAiGrkBBc9yj2HVKhSGAu(PEsKBWX7R5L8begq94QeldbTwDyLr)f3Eg1r33Ue3mHoclbEbzjGGwRoSYO)IBpJ6WQjkwOacAT6WkJ(lU9mQd9PbcAT6(gwhnWQb1FHb2FPIDOpLlBBc9yj2HVKhSGAu(PEsK7kLH1a2Njk6XvjQgyP6oXQOuVDlneWiBOgyP6(gwhnWQb1FHb2FPIDlneWiBGGwRUtSkk1Bh6tde0A19nSoAGvdQ)cdS)sf7qFKTnHESe7WxYdwqnk)upjYnWAzbeukw94QerqRvNHfljTumh6JSTj0JLyh(sEWcQr5N6jrUbwllGGsXQhxLOGXaKS3YaDMqB4LAGLQ7ByD0aRgu)fgy)Lk2T0qaJu22e6XsSdFjpyb1O8t9Ki3NyvuQ3ECvIQbwQUtSkk1B3sdbmYgEv23gaRu2NGCjcSHGXaKS3shWAzbeukwD09TlXntSPYLTnHESe7WxYdwqnk)upjYnWAzbeukw94QefmgGK9wgOZeAdHVr5hMGQbwQUj8zbwnO(lmW(lvSBPHagPSTj0JLyh(sEWcQr5N6jrURugwdyFMOOhxLOAGLQ7eRIs92T0qaJSbcAT6oXQOuVDOpnqqRv3jwfL6TJUVDjUzcDewc8cYsabTwDNyvuQ3oSAIIY2MqpwID4l5blOgLFQNe5gyTSackfRECvIcgdqYEld0zcv22e6XsSdFjpyb1O8t9Ki3vG9xa7Zef9q4TaSGAu(PyIe6XvjsxLoSVHaMSTj0JLyh(sEWcQr5N6jrUNrv)sIAfNhxLi(zaqqnk)uSt4BxgahVVMxYtqcB4ffnxLr5NBcF2WbwnWtNPbmAso6L8Uvs075zKfkugcAT6MWNnCGvd80zAaJMKJEjVd9PbcAT6(gwhnWQb1FHb2FPIDOpLlBBc9yj2HVKhSGAu(PEsK7kLH1a2Njk6XvjQgyP6oXQOuVDlneWiBGGwRUtSkk1Bh6tJYqqRv3jwfL6TJUVDjUzEbzjWfLacAT6oXQOuVDy1efluabTwDyLr)f3Eg1H(uOGxQbwQUVH1rdSAq9xyG9xQy3sdbmYYLTnHESe7WxYdwqnk)upjYDLYWAa7Zef94QePO5Qmk)CdS)s1aHvs0dCi0d97wjrVNNr2Wle0A1nW(lvdewjrpWHqp0FGCiO1Qd9PHxQbwQUb2FPAGacWWQBPHagzdVudSuDt4ZUKpG9zIIULgcyKY2MqpwID4l5blOgLFQNe5w4Bxg8nARHvzBtOhlXo8L8GfuJYp1tICJvtprG8WcFJYppUkr1alvhwn9ebYdl8nk)ClneWiLTnHESe7WxYdwqnk)upjY9mQ6hgy)LQb84Qe9snWs19qVVbcdS)s1ahwDlneWiluWRNPU6rxyG9xQgWzc9AnzBtOhlXo8L8GfuJYp1tICdoEFnVKpGWaQSTj0JLyh(sEWcQr5N6jrURa7Va2Njk6XN16sEIe6HWBbyb1O8tXej0JRsKUkDyFdbmzBtOhlXo8L8GfuJYp1tICxb2FbSptu0JpR1L8ej0JRs8ZAT)s1rEy1sXiixjBBc9yj2HVKhSGAu(PEsK7kLH1a2Njk6XN16sEIec7TgfFSe(Q0MkTjcjS0MG93mAEjpg25AKRRe)R37lUg46LrzKd)jJ3)HrvzSYOY47b(sEWcQr5N(EiJ0vs0JoszeZ(tgnuL9nDKYOW3s(HDY2C4pzSYaa2BxYlJgk1WY4BJozefpsz8szu9NmAc9yPmcoSkJiOQm(2OtgtMkJvgAskJxkJQ)KrJKKLYiPPgIHhxVSTmY1kJdS)s1aHvs0dCi0d9hihcATkBlB)E)pmQoszKaLrtOhlLrWHvSt2g2bhwXqoGD8L8GfuJYpfYb8fHqoG9LgcyKqoHDtOhlH9kW(lG9zIIWUGE6ONb7LjJEjJ6jkEjVmwOGmsYuxfy)fW(mrrhDF7sSm2mrzKxqkJfkiJQbwQodlwsAPyULgcyKYydzKKPUkW(lG9zIIo6(2LyzSzzSmzuWyas2BPZWILKwkMJUVDjwg9ugrqRvNHfljTumhjk10JLYy5YydzuWyas2BPZWILKwkMJUVDjwgBwg5czSCzSHmwMmIGwRoG1Ycyuk)COpYyHcYOxYicAT6qamgjafRo0hzSCyx4TaSGAu(Py4lcHk8vPqoG9LgcyKqoHDb90rpd2vdSuDgwSK0sXClneWiLXgYyzYOE)jJeKOmYvnjJfkiJiO1QdbWyKauS6qFKXYLXgYyzYOGXaKS3shWAzbeukwD09TlXYibLXMKXYLXgYyzYOxYOAGLQ7eRIs92T0qaJugluqg9sgrqRv3jwfL6Td9rgBiJEjJcgdqYElDNyvuQ3o0hzSCy3e6Xsy3WILKwkguHViaihW(sdbmsiNWUGE6ONb7QbwQUb2FPAGacWWQBPHagPm2qgltgvdSuDFdRJgy1G6VWa7VuXULgcyKYydzSmzebTwDFdRJgy1G6VWa7VuXo0hzSHm(TbWkL9LXMLrUQjzSqbz0lzebTwDFdRJgy1G6VWa7VuXo0hzSCzSqbz0lzunWs19nSoAGvdQ)cdS)sf7wAiGrkJLd7Mqpwc7dS)s1abeGHvOcFXfqoG9LgcyKqoHDb90rpd2vdSuDyLr)f3Eg1T0qaJugBiJLjJu7idR1s1zKKyNGHMQm2SmsaYyHcYi1oYWATuDgjj2DPmsqzKaBsglxgBiJLjJFBaSszFzSzzKl4czSCy3e6XsyhRm6V42ZOqf(IaHCa7lneWiHCc7c6PJEgSRgyP6MWNDjFa7ZefDlneWiLXgYOGXaKS3shWAzbeukwD09TlXYyZeLXMGDtOhlH9j8zxYhW(mrrOcFXvqoG9LgcyKqoHDb90rpd2vdSuDt4ZUKpG9zIIULgcyKYydzebTwDt4ZUKpG9zIIo0hy3e6XsyhyTSackfRqf(Ilb5a2xAiGrc5e2f0th9myxnWs1bUsIEKHVX)TGY09DlneWiHDtOhlHDWvs0Jm8n(VfuMUpuHVExihW(sdbmsiNWUGE6ONb7iO1QdRm6V42ZOo0hzSHmIFgaeuJYpf7e(2LbWX7R5L8YyZYyPYydzSmzebTwDFdRJgy1G6VWa7VuXo0hzSCy3e6XsyhC8(AEjFaHbuOcF9(qoG9LgcyKqoHDb90rpd2rqRv3e(SHdSAGNotdy0KC0l5DOpYydzSmz0lzunWs19nSoAGvdQ)cdS)sf7wAiGrkJfkiJiO1Q7ByD0aRgu)fgy)Lk2H(iJLd7Mqpwc7ZOQFjrTIdQWxe2eKdyFPHagjKtyxqpD0ZG9YKr8ZaGGAu(PyNW3UmaoEFnVKxgjOmsOmwUm2qgltg9sgjzQRcS)cyFMOOJUkDyFdbmzSCzSHmwMm6LmQgyP6(gwhnWQb1FHb2FPIDlneWiLXcfKre0A19nSoAGvdQ)cdS)sf7qFKXcfKrbJbizVLoG1YciOuS6O7BxILrckJnjJnKXVnawPSVmsqIY47xQmwoSBc9yjSpJQ(Le1koOcFriHqoG9LgcyKqoHDb90rpd2vdSuDFdRJgy1G6VWa7VuXULgcyKYydzSmzebTwDFdRJgy1G6VWa7VuXo0hzSqbzuWyas2BPdyTSackfRo6(2LyzKGYytYydz8BdGvk7lJeKOm((LkJfkiJ4Nbab1O8tXoHVDzaC8(AEjVm2SmwQm2qgrqRvhwz0FXTNrDOpYydzuWyas2BPdyTSackfRo6(2LyzSzIYiVGuglxgluqg9sgvdSuDFdRJgy1G6VWa7VuXULgcyKWUj0JLW(mQ6hW(mrrOcFryPqoG9LgcyKqoHDb90rpd2ltgrqRvhwz0FXTNrD09TlXYyZYiHocLXsqg5fKYyjiJiO1QdRm6V42ZOoSAIIYyHcYicAT6WkJ(lU9mQd9rgBiJiO1Q7ByD0aRgu)fgy)Lk2H(iJLd7Mqpwc7GJ3xZl5dimGcv4lcjaihW(sdbmsiNWUGE6ONb7QbwQUtSkk1B3sdbmszSHmQgyP6(gwhnWQb1FHb2FPIDlneWiLXgYicAT6oXQOuVDOpYydzebTwDFdRJgy1G6VWa7VuXo0hy3e6XsyVszynG9zIIqf(IqUaYbSV0qaJeYjSlONo6zWocAT6mSyjPLI5qFGDtOhlHDG1YciOuScv4lcjqihW(sdbmsiNWUGE6ONb7cgdqYEld0zcvgBiJEjJQbwQUVH1rdSAq9xyG9xQy3sdbmsy3e6XsyhyTSackfRqf(IqUcYbSV0qaJeYjSlONo6zWUAGLQ7eRIs92T0qaJugBiJEjJLjJFBaSszFzKGYixIaLXgYOGXaKS3shWAzbeukwD09TlXYyZeLXMKXYHDtOhlH9tSkk1BOcFrixcYbSV0qaJeYjSlONo6zWUGXaKS3YaDMqLXgYOW3O8dlJeugvdSuDt4ZcSAq9xyG9xQy3sdbmsy3e6XsyhyTSackfRqf(IW3fYbSV0qaJeYjSlONo6zWUAGLQ7eRIs92T0qaJugBiJiO1Q7eRIs92H(iJnKre0A1DIvrPE7O7BxILXMLrcDekJLGmYliLXsqgrqRv3jwfL6TdRMOiSBc9yjSxPmSgW(mrrOcFr47d5a2xAiGrc5e2f0th9myxWyas2BzGotOWUj0JLWoWAzbeukwHk8vPnb5a2xAiGrc5e2nHESe2Ra7Va2Njkc7c6PJEgStxLoSVHagSl8wawqnk)um8fHqf(QucHCa7lneWiHCc7c6PJEgSJFgaeuJYpf7e(2LbWX7R5L8YibLrcLXgYOxYifnxLr5NBcF2WbwnWtNPbmAso6L8Uvs075zKYyHcYyzYicAT6MWNnCGvd80zAaJMKJEjVd9rgBiJiO1Q7ByD0aRgu)fgy)Lk2H(iJLd7Mqpwc7ZOQFjrTIdQWxLwkKdyFPHagjKtyxqpD0ZGD1alv3jwfL6TBPHagPm2qgrqRv3jwfL6Td9rgBiJLjJiO1Q7eRIs92r33UelJnlJ8cszSeKrUqglbzebTwDNyvuQ3oSAIIYyHcYicAT6WkJ(lU9mQd9rgluqg9sgvdSuDFdRJgy1G6VWa7VuXULgcyKYy5WUj0JLWELYWAa7ZefHk8vPeaKdyFPHagjKtyxqpD0ZGDkAUkJYp3a7VunqyLe9ahc9q)Uvs075zKYydz0lzebTwDdS)s1aHvs0dCi0d9hihcAT6qFKXgYOxYOAGLQBG9xQgiGamS6wAiGrkJnKrVKr1alv3e(Sl5dyFMOOBPHagjSBc9yjSxPmSgW(mrrOcFvkxa5a2nHESe2f(2LbFJ2Ayf2xAiGrc5eQWxLsGqoG9LgcyKqoHDb90rpd2vdSuDy10teipSW3O8ZT0qaJe2nHESe2XQPNiqEyHVr5huHVkLRGCa7lneWiHCc7c6PJEgS7LmQgyP6EO33aHb2FPAGdRULgcyKYyHcYOxY4Zux9OlmW(lvd4mHETgSBc9yjSpJQ(Hb2FPAaOcFvkxcYbSBc9yjSdoEFnVKpGWakSV0qaJeYjuHVk9DHCa7FwRl5HVie2xAiGf(SwxYd5e2nHESe2Ra7Va2Njkc7cVfGfuJYpfdFriSlONo6zWoDv6W(gcyW(sdbmsiNqf(Q03hYbSV0qaJeYjSV0qal8zTUKhYjSlONo6zW(N1A)LQJ8WQLIjJeug5ky3e6XsyVcS)cyFMOiS)zTUKh(IqOcFranb5a2)SwxYdFriSV0qal8zTUKhYjSBc9yjSxPmSgW(mrryFPHagjKtOcvyNCvdfOqoGVieYbSV0qaJeIa7c6PJEgSBC5rpDolfdRudeOdZslfZT0qaJe2nHESe2ramgjafRqf(QuihW(sdbmsiNWUGE6ONb71J3xd09TlXYyZYix1KmwOGmkymaj7T0XJAuYZYaRgmU8Om13r33UelJnlJeqtWUj0JLW(dtpwcv4lcaYbSBc9yjS)2LKbS)mkSV0qaJeYjuHV4cihWUj0JLWokEHt3hd7lneWiHCcv4lceYbSBc9yjSxp6cdS)s1aW(sdbmsiNqf(IRGCa7Mqpwc7yLr)Hb2FPAayFPHagjKtOcFXLGCa7Mqpwc7cwkwQuthzOcS)G9LgcyKqoHk817c5a2nHESe2ramgzGvdQ)cl33ByFPHagjKtOcF9(qoGDtOhlHDEuJsEwgy1GXLhLP(W(sdbmsiNqf(IWMGCa7Mqpwc7vMafpYGXLh90fqM9H9LgcyKqoHk8fHec5a2nHESe2FqPx17l5diadRW(sdbmsiNqf(IWsHCa7Mqpwc7Q)cOjcdnjdvgvmyFPHagjKtOcFriba5a2nHESe2)7ZOEhy1aavCKbs6Spg2xAiGrc5eQWxeYfqoGDtOhlHD698aw4Ya(Xed2xAiGrc5eQWxesGqoGDtOhlH93yuazRDzGomlTumyFPHagjKtOcFrixb5a2xAiGrc5e2f0th9myxnk)uN)mG6hEeQmsqz8DBsgluqgvJYp15pdO(HhHkJnlJL2KmwOGmwpEFnq33UelJnlJeqtWUj0JLWoD2ZL8HkW(ddv4lc5sqoGDtOhlHD)zunmmEPyW(sdbmsiNqf(IW3fYbSV0qaJeYjSlONo6zWUxYOAGLQZWILKwkMBPHagPmwOGmIGwRodlwsAPyo0hzSqbzuWyas2BPZWILKwkMJUVDjwgjOmsGnb7Mqpwc7iagJmurPEdv4lcFFihW(sdbmsiNWUGE6ONb7EjJQbwQodlwsAPyULgcyKYyHcYicAT6mSyjPLI5qFGDtOhlHDKrXJw8sEOcFvAtqoG9LgcyKqoHDb90rpd29sgvdSuDgwSK0sXClneWiLXcfKre0A1zyXsslfZH(iJfkiJcgdqYElDgwSK0sXC09TlXYibLrcSjy3e6XsyVE0HaymsOcFvkHqoG9LgcyKqoHDb90rpd29sgvdSuDgwSK0sXClneWiLXcfKre0A1zyXsslfZH(iJfkiJcgdqYElDgwSK0sXC09TlXYibLrcSjy3e6Xsy3sXWk1abHbaqf(Q0sHCa7lneWiHCc7c6PJEgS7LmQgyP6mSyjPLI5wAiGrkJfkiJEjJiO1QZWILKwkMd9b2nHESe2rm(aRgu6jkIHk8vPeaKdyFPHagjKty3e6Xsy)HEFgL8mq4nR1GDb90rpd29sgrqRv3d9(mk5zGWBwR5qFGDH3cWcQr5NIHVieQWxLYfqoGDtOhlH9wd)mAqz6(W(sdbmsiNqf(QuceYbSBc9yjSxTfuQL4kk(yjSV0qaJeYjuHVkLRGCa7lneWiHCc7c6PJEgSBc9ATWY9VHLrckJLkJnKXYKr8ZaGGAu(PyNW3UmaoEFnVKxgjOmwQmwOGmIFgaeuJYpf7awllGm7lJeuglvglh2nHESe2POzWe6XYa4WkSdoSgs7py3ydQWxLYLGCa7lneWiHCc7c6PJEgS7LmQgyP6WkJ(ddS)s1aULgcyKYydz0e61AHL7FdlJntuglf2nHESe2POzWe6XYa4WkSdoSgs7pyhFjpyb1O8tHk8vPVlKdyFPHagjKtyxqpD0ZGD1alvhwz0FyG9xQgWT0qaJugBiJMqVwlSC)ByzSzIYyPWUj0JLWofndMqpwgahwHDWH1qA)b74fWxYdwqnk)uOcvy)Hob7JykKd4lcHCa7lneWiHCc7P9hSBCzSVrnCOYsnWQHh2BJc7Mqpwc7gxg7BudhQSudSA4H92Oqf(QuihWUj0JLW(dtpwc7lneWiHCcvOc7gBqoGVieYbSV0qaJeYjSlONo6zWocAT6MWNDjFa7ZefDOpWUj0JLW(mQ6xsuR4Gk8vPqoGDtOhlHDHVDzW3OTgwH9LgcyKqoHk8fba5a2xAiGrc5e2f0th9myxnWs1Hvg9xC7zu3sdbmsy3e6XsyhRm6V42ZOqf(IlGCa7lneWiHCc7Mqpwc7vG9xa7ZefHDb90rpd2PRsh23qatgBiJMqVwlqYuxfy)fW(mrrzSzzKaKXgYOj0R1cl3)gwgBMOmsGWUWBbyb1O8tXWxecv4lceYbSV0qaJeYjSlONo6zWUxYOj0R1cKm1vb2FbSptue2nHESe2Ra7Va2Njkcv4lUcYbSV0qaJeYjSlONo6zWUAGLQBcF2L8bSptu0T0qaJugBiJFBaSszFzKGeLrUQjy3e6XsyFcF2L8bSptueQWxCjihW(sdbmsiNWUGE6ONb7QbwQodlwsAPyULgcyKYydzSmz0lz8zQdRm6pmW(lvd4mHETMmwUm2qgltg9sgvdSuDNyvuQ3ULgcyKYyHcYOxYicAT6oXQOuVDOpYydz0lzuWyas2BP7eRIs92H(iJLd7Mqpwc7gwSK0sXGk817c5a2xAiGrc5e2f0th9myxnWs1bUsIEKHVX)TGY09DlneWiHDtOhlHDWvs0Jm8n(VfuMUpuHVEFihW(sdbmsiNWUGE6ONb7u0CvgLFUj8zdhy1apDMgWOj5OxY7wjrVNNrkJnKrVKre0A1nHpB4aRg4PZ0agnjh9sEh6dSBc9yjSpJQ(bSptueQWxe2eKdyFPHagjKtyxqpD0ZGDkAUkJYph52Js3NrdyLLZTsIEppJugBiJLjJEjJQbwQUh69nqyG9xQg4WQBPHagPmwOGmwMm6Lm(m1Hvg9hgy)LQbCMqVwtgBiJEjJptD1JUWa7VunGZe61AYy5Yy5WUj0JLW(mQ6hgy)LQbGk8fHec5a2xAiGrc5e2nHESe2bwllGGsXkSlONo6zWo(zaqqnk)uSt4BxgahVVMxYlJnlJCHmwOGmIGwRoG1Ycyuk)COpYyHcYyzYOAGLQ7ByD0aRgu)fgy)Lk2T0qaJugBiJEjJiO1Q7ByD0aRgu)fgy)Lk2H(iJnKXVnawPSVmsqIYix1KmwoSl8wawqnk)um8fHqf(IWsHCa7lneWiHCc7c6PJEgS7LmQgyP6(gwhnWQb1FHb2FPIDlneWiLXcfKre0A1Hvg9xC7zuh6JmwOGm(TbWkL9LrcsugltgjSPMKrUwzKlKXsqgXpdacQr5NIDcF7Ya44918sEzSCzSqbzebTwDFdRJgy1G6VWa7VuXo0hzSqbze)maiOgLFk2j8TldGJ3xZl5LrckJeaSBc9yjSpJQ(Le1koOcFriba5a2xAiGrc5e2f0th9myhbTwDyLr)f3Eg1r33UelJnlJeGmwcYiVGuglbzebTwDyLr)f3Eg1Hvtue2nHESe2f(2LbWX7R5L8qf(IqUaYbSV0qaJeYjSlONo6zWocAT6awllGrP8ZH(iJnKr8ZaGGAu(PyNW3UmaoEFnVKxgBwg5czSHmwMm6Lm(m1Hvg9hgy)LQbCMqVwtglxgBiJKm1vb2FbSptu0PNO4L8WUj0JLWoWAzbeukwHk8fHeiKdyFPHagjKtyxqpD0ZGD1alv3a7Vunqabyy1T0qaJugBiJ4Nbab1O8tXoHVDzaC8(AEjVm2SmsGYydzSmz0lz8zQdRm6pmW(lvd4mHETMmwoSBc9yjSpW(lvdeqagwHk8fHCfKdy3e6Xsyx4BxgahVVMxYd7lneWiHCcv4lc5sqoG9LgcyKqoH9LgcyHpR1L8qoHDb90rpd2rqRvhWAzbmkLFo0hzSHmkymaj7TmqNjuy3e6XsyhyTSackfRW(N16sE4lcHk8fHVlKdy)ZADjp8fHW(sdbSWN16sEiNWUj0JLWEfy)fW(mrryx4TaSGAu(Py4lcHDb90rpd2PRsh23qad2xAiGrc5eQWxe((qoG9pR1L8Wxec7lneWcFwRl5HCc7Mqpwc7vkdRbSptue2xAiGrc5eQqf2XlGVKhSGAu(PqoGVieYbSV0qaJeYjSBc9yjSxb2FbSptue2f0th9myVmzKUVDjwgBMOmYliLXYLXgYyzYicAT6awllGrP8ZH(iJfkiJEjJiO1QdbWyKauS6qFKXYHDH3cWcQr5NIHVieQWxLc5a2xAiGrc5e2f0th9myxnWs1nW(lvdeqagwDlneWiHDtOhlH9b2FPAGacWWkuHViaihW(sdbmsiNWUGE6ONb7QbwQoSYO)IBpJ6wAiGrkJnKXYKXVnawPSVm2SmYfCHmwoSBc9yjSJvg9xC7zuOcFXfqoG9LgcyKqoHDb90rpd2vdSuDt4ZUKpG9zIIULgcyKWUj0JLW(e(Sl5dyFMOiuHViqihW(sdbmsiNWUGE6ONb7iO1Q7Tljd8Oy1HvtuugBwgj8DLXcfKre0A1bSwwaJs5Nd9b2nHESe2bwllGGsXkuHV4kihW(sdbmsiNWUGE6ONb7iO1QdRm6V42ZOo0hy3e6XsyhC8(AEjFaHbuOcFXLGCa7lneWiHCc7c6PJEgSJGwRUj8zdhy1apDMgWOj5OxY7qFGDtOhlH9zu1VKOwXbv4R3fYbSV0qaJeYjSlONo6zWEzYi(zaqqnk)uSt4BxgahVVMxYlJeugjuglxgBiJLjJEjJKm1vb2FbSptu0rxLoSVHaMmwoSBc9yjSpJQ(Le1koOcF9(qoG9LgcyKqoHDb90rpd2XpdacQr5NIDcF7Ya44918sEzSzzSuzSHm(TbWkL9Lrcsug5QMKXgYyzYicAT6E7sYapkwDy1efLXMLXsBsgluqg)2ayLY(YibLX3VjzSCy3e6XsyFgv9dyFMOiuHViSjihW(sdbmsiNWUGE6ONb7LjJiO1QdRm6V42ZOo6(2LyzSzzKqhHYyjiJ8cszSeKre0A1Hvg9xC7zuhwnrrzSqbzebTwDyLr)f3Eg1H(iJnKre0A19nSoAGvdQ)cdS)sf7qFKXYHDtOhlHDWX7R5L8begqHk8fHec5a2xAiGrc5e2f0th9myxnWs1DIvrPE7wAiGrkJnKr1alv33W6ObwnO(lmW(lvSBPHagPm2qgrqRv3jwfL6Td9rgBiJiO1Q7ByD0aRgu)fgy)Lk2H(a7Mqpwc7vkdRbSptueQWxewkKdyFPHagjKtyxqpD0ZGDe0A1zyXsslfZH(a7Mqpwc7aRLfqqPyfQWxesaqoG9LgcyKqoHDb90rpd2fmgGK9wgOZeQm2qg9sgvdSuDFdRJgy1G6VWa7VuXULgcyKWUj0JLWoWAzbeukwHk8fHCbKdyFPHagjKtyxqpD0ZGD1alv3jwfL6TBPHagPm2qg9sgltg)2ayLY(YibLrUebkJnKrbJbizVLoG1YciOuS6O7BxILXMjkJnjJLd7Mqpwc7NyvuQ3qf(IqceYbSV0qaJeYjSlONo6zWUGXaKS3YaDMqLXgYOW3O8dlJeugvdSuDt4ZcSAq9xyG9xQy3sdbmsy3e6XsyhyTSackfRqf(IqUcYbSV0qaJeYjSlONo6zWUAGLQ7eRIs92T0qaJugBiJiO1Q7eRIs92H(a7Mqpwc7vkdRbSptueQWxeYLGCa7Mqpwc7cF7YGVrBnSc7lneWiHCcv4lcFxihW(sdbmsiNWUGE6ONb7QbwQoSA6jcKhw4Bu(5wAiGrc7Mqpwc7y10teipSW3O8dQWxe((qoG9LgcyKqoHDb90rpd29sgvdSuDp07BGWa7VunWHv3sdbmszSqbzunWs19qVVbcdS)s1ahwDlneWiLXgYyzYOxY4Zuhwz0FyG9xQgWzc9AnzSCy3e6XsyFgv9ddS)s1aqf(Q0MGCa7Mqpwc7GJ3xZl5dimGc7lneWiHCcv4RsjeYbS)zTUKh(IqyFPHaw4ZADjpKty3e6XsyVcS)cyFMOiSl8wawqnk)um8fHWUGE6ONb70vPd7BiGb7lneWiHCcv4RslfYbSV0qaJeYjSV0qal8zTUKhYjSlONo6zW(N1A)LQJ8WQLIjJeug5ky3e6XsyVcS)cyFMOiS)zTUKh(IqOcFvkba5a2)SwxYdFriSV0qal8zTUKhYjSBc9yjSxPmSgW(mrryFPHagjKtOcvOc7gQ6ZOWE)(Oatpw(EsTQcvOcH]] )

end
