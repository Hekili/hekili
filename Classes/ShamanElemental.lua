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

    spec:RegisterPack( "Elemental", 20201114, [[dGekybqijOhjrrBsk8jjkv1OKiDkjIvjrHxrv0SOkCljkLDrLFHk1WKsCmi0YKO6zqqnnvKCnujzBQi13qLiJdcsNtIswhQKknpPKUheTpiWbrLu1crf9qii0eLOurxevs5JsuQuNecIwPuQzkrPkUjQKk2PkQFcbbTujkvYtLQPIkCvjkvPTcbb2lWFfmyHomLfdPhtyYi6YkBwsFgvnAQQtRQxlHMnOBRs7w0Vrz4QWXrLWYr65qnDsxhHTlf9DveJxIsfoVey9OsuZNQ0(jAaIaoaDsth4C5TuEliIiINYvoc3szHWLd6Abhd0pmrrJFGEA3b6Cn4Ulvdc6hwbqMrc4a0XmcQyGUVQhyUUCZn)R(eOob7Yn(VeqtFwkOwv5g)xb3GokXdveYeGc6KMoW5YBP8wqerepLRCeULYcHbD8XeGZLF6YbD)NKCjaf0jhwa6LPmY1G7UunOm29TRLY2LPmEM1Cx0rLrepLhYy5TuElY2Y2LPmIq03s(H56kBxMYyztg56jjhPmIAIIehYixdJxkMmAOp81cCY2LPmw2KroozwrSmQmz8VhuwZjJCnHp7tEzS7ZefLXJrLresrbLnec2NyzKN4jNd0pOS6dhOxMYixdU7s1GYy33UwkBxMY4zwZDrhvgr8uEiJL3s5TiBlBxMYicrFl5hMRRSDzkJLnzKRNKCKYiQjksCiJCnmEPyYOH(WxlWjBxMYyztg54KzfXYOYKX)EqznNmY1e(Sp5LXUptuugpgvgriffu2qiyFILrEINCozBzBtOplXUd6eSlQPijWl86UEK2DinUm23OgouzPgy1Wb7KrLTnH(Se7oOtWUOM6jsUpy6ZszBz7Yug5ALDmbHoszCnhTazu)7Kr1FYOjugvgFSmAnThAOW5KTltzeHOHvzKtiJrcjWQmETKWGWcKXVkJQ)KrUEU8OVozKdQ9QmY1NIHvQbLXYUgMLwkMm(yz8Go8s1jBBc9zjgjkKXiHey1JVI04YJ(6CwkgwPgmqhMLwkMBPHchPSDzkJiKzztWUOMkJhm9zPm(yz8GU6Ol13GWcKr4NfhPmQmzu9Nmw2nHrjFlLrwvg565YJYuFpKrIeomwgfSlQPY4jpekJljLrSpJQWcCY2MqFwI9ej3hm9zPhFfz9591aDx7tCRNUfVEfmgKKDs64jmk5BzGvdgxEuM67O7AFIBfHBr2w2UmLreYuhLsCOYiRkJcdRyNSTj0NLyprY9jFsgW(ZOY2MqFwI9ej3e4fEDxSSTj0NLyprYD9Plm4UlvdkBBc9zj2tKCJvg9ggC3LQbLTLTnH(Se7jsUfSuSuPMoYqfA3jBBc9zj2tKCJczmYaRgu)fwUBbY2MqFwI9ej38egL8TmWQbJlpkt9LTnH(Se7jsURmbbEKbJlp6RlGo7kBBc9zj2tKCFqq)AbFYhqHgwLTnH(Se7jsUv)fisugrsgQmQyY2MqFwI9ej33Dz0ccSAasiEYajD2flBBc9zj2tKCt)Jd4cFgWhMyY2MqFwI9ej3NWOqYM7ZaDywAPyY2MqFwI9ej30zhFYhQq7oShFfPAu(Po)zq1pCiueGqBXRx1O8tD(ZGQF4qOTwElE9wFEFnq31(e3kc3ISDzkJiKPmkm8KreszSYO8mvgXS7u)p5DY2MqFwI9ej3(ZOAyy8sXKTLTnH(Se7jsUrHmgzOsqlWJVISq1GlvNHfljTum3sdfosVErjQvNHfljTumhXHxVcgdsYojDgwSK0sXC0DTpXiGRAr22e6ZsSNi5gDu8Of)K3JVISq1GlvNHfljTum3sdfosVErjQvNHfljTumhXHSTj0NLyprYD9PdfYyKE8vKfQgCP6mSyjPLI5wAOWr61lkrT6mSyjPLI5io86vWyqs2jPZWILKwkMJUR9jgbCvlY2MqFwI9ej3wkgwPgmimi0JVISq1GlvNHfljTum3sdfosVErjQvNHfljTumhXHxVcgdsYojDgwSK0sXC0DTpXiGRAr22e6ZsSNi5g14dSAqPVOi2JVISq1GlvNHfljTum3sdfosVEleLOwDgwSK0sXCehY2Y2MqFwI9ej3h0)YOKVbdNynNhIceWfuJYpfJerp(kYcrjQv3b9Vmk5BWWjwZ5ioKTnH(Se7jsUBo8XObLP7kBBc9zj2tKCxTfuQL4kb(zPSTSTj0NLyprY9e(Sp5dyFMOOhFfzPxBqSszxeG80T41RGXGKStsh0AAbuckwD0DTpXTIKxq61lkrT6GwtlGjO8ZrCuISTj0NLyprYnLidMqFwgGpw9iT7qAS5XxrAc9BUWYD)Hrq5nkfFmimOgLFk2j8TpdWN3xZp5rq5E9IpgeguJYpf7GwtlGo7IGYlr22e6ZsSNi5MsKbtOpldWhREK2DiXFYdxqnk)up(kYcvdUuDyLrVHb3DPAq3sdfoYgMq)MlSC3F4wrwUSTj0NLyprYnLidMqFwgGpw9iT7qIxa)jpCb1O8t94RivdUuDyLrVHb3DPAq3sdfoYgMq)MlSC3F4wrwUSTSTj0NLyNXgYzu1NliSIZJVIeLOwDt4Z(KpG9zIIoIdzBtOplXoJnprYTW3(m4B0MdRY2MqFwIDgBEIKBSYO3IBhJ6XxrQgCP6WkJElUDmQBPHchPSTj0NLyNXMNi5UcT7cyFMOOhIceWfuJYpfJerp(ks6Q0H9nu4Ayc9BUajtDvODxa7ZefBfHByc9BUWYD)HBfjxjBBc9zj2zS5jsURq7Ua2Njk6XxrwOj0V5cKm1vH2DbSptuu22e6ZsSZyZtKCpHp7t(a2Njk6XxrQgCP6MWN9jFa7ZefDlnu4iBCTbXkLDraYt3ISTj0NLyNXMNi52WILKwkMhFfPAWLQZWILKwkMBPHchzJsl8yQdRm6nm4Ulvd6mH(nxjnkTq1Glv3lwLGwGBPHchPxVfIsuRUxSkbTahXrJcfmgKKDs6EXQe0cCehLiBBc9zj2zS5jsUHpxq8KHRXFTGY0D94RivdUuDWNliEYW14Vwqz6UULgkCKY2MqFwIDgBEIK7zu1pG9zIIE8vKuICvgLFUj8zdhy1apDMgWej5OFY7gxq8hhJSrHOe1QBcF2WbwnWtNPbmrso6N8oIdzBtOplXoJnprY9mQ6hgC3LQb94RiPe5Qmk)CKBhkDxgnGvwo34cI)4yKnkTq1Glv3b9Vgmm4Ulvd(y1T0qHJ0R3sl8yQdRm6nm4Ulvd6mH(nxJcpM6QpDHb3DPAqNj0V5kPezBtOplXoJnprYn0AAbuckw9quGaUGAu(PyKi6XxrIpgeguJYpf7e(2Nb4Z7R5N8TEkVErjQvh0AAbmbLFoIdVElvn4s1DnSoAGvdQ)cdU7sf7wAOWr2OquIA1DnSoAGvdQ)cdU7sf7ioACTbXkLDraYt3sjY2LPmYbTazuzYiVDNmY1mQ6ZfewXjJN8QVmY1XW6OYiRkJQ)KrUgC3LkwgrjQvz8e)LYy9591p5LrewgvJYpf7KXYozzzFvgznhvyhYixhBqSsz3cLTnH(Se7m28ej3ZOQpxqyfNhFfzHQbxQURH1rdSAq9xyWDxQy3sdfosVErjQvhwz0BXTJrDehE9ETbXkLDraYsrSLwkBNQmWhdcdQr5NIDcF7Za85918t(s86fLOwDxdRJgy1G6VWG7UuXoIdVEXhdcdQr5NIDcF7Za85918tEeGWY2LPmY1XkozetqNmwaJqgjzzzFvgHm8Krtg7kJElUDmQmIsuRozBtOplXoJnprYTW3(maFEFn)K3JVIeLOwDyLrVf3og1r31(e3kcxg8cYYaLOwDyLrVf3og1Hvtuu2UmLrectybYOWWQmw2J10KrojOyvgzPmQ(0nzunk)uSm(vz8vz8XYOLY4Ny1svgTKug7kJELrUgC3LQbLXhlJNriKdz0e63CozBtOplXoJnprYn0AAbuckw94RirjQvh0AAbmbLFoIJg4JbHb1O8tXoHV9za(8(A(jFRNQrPfEm1Hvg9ggC3LQbDMq)MRKgKm1vH2DbSptu0PVO4N8Y2LPmw2lEYixdU7s1GYiNqdRYOXBFIvzK4qgvMmIWYOAu(Pyz0WYiKL8YOHLXUYOxzKRb3DPAqz8XYyYuz0e63CozBtOplXoJnprY9G7UunyafAy1JVIun4s1n4UlvdgqHgwDlnu4iBGpgeguJYpf7e(2Nb4Z7R5N8TYvnkTWJPoSYO3WG7UunOZe63CLiBBc9zj2zS5jsUf(2Nb4Z7R5N8Y2MqFwIDgBEIKBO10cOeuS6XL18tEKi6XxrIsuRoO10cyck)CehnemgKKDsgOZeQSTj0NLyNXMNi5UcT7cyFMOOhxwZp5rIOhIceWfuJYpfJerp(ks6Q0H9nu4KTnH(Se7m28ej3vkdRbSptu0JlR5N8iru2w22e6ZsSdVa(tE4cQr5NIScT7cyFMOOhIceWfuJYpfJerp(kYsP7AFIBfjVGSKgLIsuRoO10cyck)CehE9wikrT6qHmgjKaRoIJsKTnH(Se7WlG)KhUGAu(PEIK7b3DPAWak0WQhFfPAWLQBWDxQgmGcnS6wAOWrkBBc9zj2Hxa)jpCb1O8t9ej3yLrVf3og1JVIun4s1Hvg9wC7yu3sdfoYgLETbXkLDB9uNQezBtOplXo8c4p5HlOgLFQNi5EcF2N8bSptu0JVIun4s1nHp7t(a2Njk6wAOWrkBBc9zj2Hxa)jpCb1O8t9ej3qRPfqjOy1JVIeLOwDN8jzGNaRoSAIITIic1RxuIA1bTMwatq5NJ4q22e6ZsSdVa(tE4cQr5N6jsUHpVVMFYhqzq1JVIeLOwDyLrVf3og1rCiBBc9zj2Hxa)jpCb1O8t9ej3ZOQpxqyfNhFfjkrT6MWNnCGvd80zAatKKJ(jVJ4q22e6ZsSdVa(tE4cQr5N6jsUNrvFUGWkop(kYsXhdcdQr5NIDcF7Za85918tEeGyjnkTqsM6Qq7Ua2Njk6ORsh23qHRezBtOplXo8c4p5HlOgLFQNi5Egv9dyFMOOhFfj(yqyqnk)uSt4BFgGpVVMFY3A5nU2GyLYUia5PBPrPOe1Q7Kpjd8ey1HvtuS1YBXR3RniwPSlckRwkr22e6ZsSdVa(tE4cQr5N6jsUHpVVMFYhqzq1JVISuuIA1Hvg9wC7yuhDx7tCRi6qSm4fKLbkrT6WkJElUDmQdRMOOxVOe1QdRm6T42XOoIJgOe1Q7AyD0aRgu)fgC3Lk2rCuISTj0NLyhEb8N8WfuJYp1tKCxPmSgW(mrrp(ks1Glv3lwLGwGBPHchzd1Glv31W6ObwnO(lm4UlvSBPHchzduIA19IvjOf4ioAGsuRURH1rdSAq9xyWDxQyhXHSTj0NLyhEb8N8WfuJYp1tKCdTMwaLGIvp(ksuIA1zyXsslfZrCiBBc9zj2Hxa)jpCb1O8t9ej3qRPfqjOy1JVIuWyqs2jzGotOnkun4s1DnSoAGvdQ)cdU7sf7wAOWrkBBc9zj2Hxa)jpCb1O8t9ej3VyvcAbE8vKQbxQUxSkbTa3sdfoYgfw61geRu2fbCjUQHGXGKStsh0AAbuckwD0DTpXTISLsKTnH(Se7WlG)KhUGAu(PEIKBO10cOeuS6Xxrkymij7KmqNj0gcFJYpmcudUuDt4ZcSAq9xyWDxQy3sdfoszBtOplXo8c4p5HlOgLFQNi5UszynG9zIIE8vKQbxQUxSkbTa3sdfoYgOe1Q7fRsqlWrCiBBc9zj2Hxa)jpCb1O8t9ej3cF7ZGVrBoSkBBc9zj2Hxa)jpCb1O8t9ej3y10xeiFSW3O8ZJVIun4s1HvtFrG8XcFJYp3sdfoszBtOplXo8c4p5HlOgLFQNi5Egv9ddU7s1GE8vKfQgCP6oO)1GHb3DPAWhRULgkCKE9QgCP6oO)1GHb3DPAWhRULgkCKnkTWJPoSYO3WG7UunOZe63CLiBBc9zj2Hxa)jpCb1O8t9ej3WN3xZp5dOmOkBBc9zj2Hxa)jpCb1O8t9ej3vODxa7Zef94YA(jpse9quGaUGAu(PyKi6XxrsxLoSVHcNSTj0NLyhEb8N8WfuJYp1tKCxH2DbSptu0JlR5N8ir0JVI8YAU7s1r(y1sXqWPLTnH(Se7WlG)KhUGAu(PEIK7kLH1a2Njk6XL18tEKikBlBBc9zj2H)KhUGAu(PiRq7Ua2Njk6HOabCb1O8tXir0JVIS0c1xu8tEVEjzQRcT7cyFMOOJUR9jUvK8csVEvdUuDgwSK0sXClnu4iBqYuxfA3fW(mrrhDx7tCRLkymij7K0zyXsslfZr31(e7jkrT6mSyjPLI5ijOM(SSKgcgdsYojDgwSK0sXC0DTpXTEQsAukkrT6GwtlGjO8ZrC41BHOe1QdfYyKqcS6iokr22e6ZsSd)jpCb1O8t9ej3gwSK0sX84RivdUuDgwSK0sXClnu4iBuQ(3HaKNUfVErjQvhkKXiHey1rCusJsfmgKKDs6GwtlGsqXQJUR9jgbTusJslun4s19IvjOf4wAOWr61BHOe1Q7fRsqlWrC0OqbJbjzNKUxSkbTahXrjY2MqFwID4p5HlOgLFQNi5EWDxQgmGcnS6XxrQgCP6gC3LQbdOqdRULgkCKnkvn4s1DnSoAGvdQ)cdU7sf7wAOWr2OuuIA1DnSoAGvdQ)cdU7sf7ioACTbXkLDB90T41BHOe1Q7AyD0aRgu)fgC3Lk2rCuIxVfQgCP6UgwhnWQb1FHb3DPIDlnu4ilr22e6ZsSd)jpCb1O8t9ej3yLrVf3og1JVIun4s1Hvg9wC7yu3sdfoYgLsTNmSMlvNrsIDcgrQTIWE9sTNmSMlvNrsIDFIaUQLsAu61geRu2T1tDQsKTnH(Se7WFYdxqnk)uprY9e(Sp5dyFMOOhFfPAWLQBcF2N8bSptu0T0qHJSHGXGKStsh0AAbuckwD0DTpXTISfzBtOplXo8N8WfuJYp1tKCdTMwaLGIvp(ks1Glv3e(Sp5dyFMOOBPHchzduIA1nHp7t(a2Njk6ioKTnH(Se7WFYdxqnk)uprYn85cINmCn(RfuMURhFfPAWLQd(CbXtgUg)1ckt31T0qHJu22e6ZsSd)jpCb1O8t9ej3WN3xZp5dOmO6XxrIsuRoSYO3IBhJ6ioAGpgeguJYpf7e(2Nb4Z7R5N8TwEJsrjQv31W6ObwnO(lm4UlvSJ4OezBtOplXo8N8WfuJYp1tKCpJQ(CbHvCE8vKOe1QBcF2WbwnWtNPbmrso6N8oIJgLwOAWLQ7AyD0aRgu)fgC3Lk2T0qHJ0RxuIA1DnSoAGvdQ)cdU7sf7iokr22e6ZsSd)jpCb1O8t9ej3ZOQpxqyfNhFfzP4JbHb1O8tXoHV9za(8(A(jpcqSKgLwijtDvODxa7ZefD0vPd7BOWvsJslun4s1DnSoAGvdQ)cdU7sf7wAOWr61lkrT6UgwhnWQb1FHb3DPIDehE9kymij7K0bTMwaLGIvhDx7tmcAPX1geRu2fbilRYlr22e6ZsSd)jpCb1O8t9ej3ZOQFa7Zef94RivdUuDxdRJgy1G6VWG7UuXULgkCKnkfLOwDxdRJgy1G6VWG7UuXoIdVEfmgKKDs6GwtlGsqXQJUR9jgbT04AdIvk7IaKLv5E9IpgeguJYpf7e(2Nb4Z7R5N8TwEduIA1Hvg9wC7yuhXrdbJbjzNKoO10cOeuS6O7AFIBfjVGSeVEV2GyLYUia5PBr22e6ZsSd)jpCb1O8t9ej3WN3xZp5dOmO6XxrwkkrT6WkJElUDmQJUR9jUveDiwg8cYYaLOwDyLrVf3og1Hvtu0RxuIA1Hvg9wC7yuhXrduIA1DnSoAGvdQ)cdU7sf7iokr22e6ZsSd)jpCb1O8t9ej3vkdRbSptu0JVIun4s19IvjOf4wAOWr2qn4s1DnSoAGvdQ)cdU7sf7wAOWr2aLOwDVyvcAboIJgOe1Q7AyD0aRgu)fgC3Lk2rCiBBc9zj2H)KhUGAu(PEIKBO10cOeuS6XxrIsuRodlwsAPyoIdzBtOplXo8N8WfuJYp1tKCdTMwaLGIvp(ksbJbjzNKb6mH2Oq1Glv31W6ObwnO(lm4UlvSBPHchPSTj0NLyh(tE4cQr5N6jsUFXQe0c84RivdUuDVyvcAbULgkCKnkS0RniwPSlc4sCvdbJbjzNKoO10cOeuS6O7AFIBfzlLiBBc9zj2H)KhUGAu(PEIKBO10cOeuS6Xxrkymij7KmqNj0gcFJYpmcudUuDt4ZcSAq9xyWDxQy3sdfoszBtOplXo8N8WfuJYp1tKCxPmSgW(mrrp(ks1Glv3lwLGwGBPHchzduIA19IvjOf4ioAGsuRUxSkbTahDx7tCRi6qSm4fKLbkrT6EXQe0cCy1efLTnH(Se7WFYdxqnk)uprYn0AAbuckw94RifmgKKDsgOZeQSTj0NLyh(tE4cQr5N6jsURq7Ua2Njk6HOabCb1O8tXir0JVIKUkDyFdfozBtOplXo8N8WfuJYp1tKCpJQ(CbHvCE8vK4JbHb1O8tXoHV9za(8(A(jpcqSrHuICvgLFUj8zdhy1apDMgWej5OFY7gxq8hhJ0R3srjQv3e(SHdSAGNotdyIKC0p5DehnqjQv31W6ObwnO(lm4UlvSJ4OezBtOplXo8N8WfuJYp1tKCxPmSgW(mrrp(ks1Glv3lwLGwGBPHchzduIA19IvjOf4ioAukkrT6EXQe0cC0DTpXTYlilJtvgOe1Q7fRsqlWHvtu0RxuIA1Hvg9wC7yuhXHxVfQgCP6UgwhnWQb1FHb3DPIDlnu4ilr22e6ZsSd)jpCb1O8t9ej3cF7ZGVrBoSkBBc9zj2H)KhUGAu(PEIKBSA6lcKpw4Bu(5XxrQgCP6WQPViq(yHVr5NBPHchPSTj0NLyh(tE4cQr5N6jsUNrv)WG7UunOhFfzHQbxQUd6FnyyWDxQg8XQBPHchPxVQbxQUd6FnyyWDxQg8XQBPHchzJsl8yQR(0fgC3LQbDMq)MRezBtOplXo8N8WfuJYp1tKCdFEFn)KpGYGQSTj0NLyh(tE4cQr5N6jsURq7Ua2Njk6XL18tEKi6HOabCb1O8tXir0JVIKUkDyFdfozBtOplXo8N8WfuJYp1tKCxH2DbSptu0JlR5N8ir0JVI8YAU7s1r(y1sXqWPLTnH(Se7WFYdxqnk)uprYDLYWAa7Zef94YA(jpseb9MJIFwcoxElL3cIiIicd6Ny08tEmOJqEpyuDKYixjJMqFwkJWhRyNSnOdFSIbCa64p5HlOgLFkGdWzebCa6lnu4ibCc6MqFwc6vODxa7ZefbDb91rFd0lvglug1xu8tEz0RxzKKPUk0UlG9zIIo6U2NyzSvKYiVGug96vgvdUuDgwSK0sXClnu4iLXgYijtDvODxa7ZefD0DTpXYyRYyPYOGXGKStsNHfljTumhDx7tSm6PmIsuRodlwsAPyoscQPplLXsKXgYOGXGKStsNHfljTumhDx7tSm2QmEkzSezSHmwQmIsuRoO10cyck)CehYOxVYyHYikrT6qHmgjKaRoIdzSeqxuGaUGAu(PyWzebk4C5aoa9LgkCKaobDb91rFd0vdUuDgwSK0sXClnu4iLXgYyPYO(3jJiaPmE6wKrVELruIA1HczmsibwDehYyjYydzSuzuWyqs2jPdAnTakbfRo6U2NyzebYylYyjYydzSuzSqzun4s19IvjOf4wAOWrkJE9kJfkJOe1Q7fRsqlWrCiJnKXcLrbJbjzNKUxSkbTahXHmwcOBc9zjOByXsslfdOGZimGdqFPHchjGtqxqFD03aD1Glv3G7UunyafAy1T0qHJugBiJLkJQbxQURH1rdSAq9xyWDxQy3sdfoszSHmwQmIsuRURH1rdSAq9xyWDxQyhXHm2qgV2GyLYUYyRY4PBrg96vglugrjQv31W6ObwnO(lm4UlvSJ4qglrg96vglugvdUuDxdRJgy1G6VWG7UuXULgkCKYyjGUj0NLG(G7UunyafAyfOGZNcWbOV0qHJeWjOlOVo6BGUAWLQdRm6T42XOULgkCKYydzSuzKApzynxQoJKe7emIuLXwLrewg96vgP2tgwZLQZijXUpLreiJCvlYyjYydzSuz8AdIvk7kJTkJN6uYyjGUj0NLGowz0BXTJrbk4mxb4a0xAOWrc4e0f0xh9nqxn4s1nHp7t(a2Njk6wAOWrkJnKrbJbjzNKoO10cOeuS6O7AFILXwrkJTa6MqFwc6t4Z(KpG9zIIafC(0aoa9LgkCKaobDb91rFd0vdUuDt4Z(KpG9zIIULgkCKYydzeLOwDt4Z(KpG9zIIoIdq3e6ZsqhAnTakbfRafCMlb4a0xAOWrc4e0f0xh9nqxn4s1bFUG4jdxJ)AbLP76wAOWrc6MqFwc6WNliEYW14Vwqz6UafCgHc4a0xAOWrc4e0f0xh9nqhLOwDyLrVf3og1rCiJnKr8XGWGAu(PyNW3(maFEFn)KxgBvglxgBiJLkJOe1Q7AyD0aRgu)fgC3Lk2rCiJLa6MqFwc6WN3xZp5dOmOcuW5YcWbOV0qHJeWjOlOVo6BGokrT6MWNnCGvd80zAatKKJ(jVJ4qgBiJLkJfkJQbxQURH1rdSAq9xyWDxQy3sdfosz0RxzeLOwDxdRJgy1G6VWG7UuXoIdzSeq3e6ZsqFgv95ccR4ak4mITa4a0xAOWrc4e0f0xh9nqVuzeFmimOgLFk2j8TpdWN3xZp5LreiJikJLiJnKXsLXcLrsM6Qq7Ua2Njk6ORsh23qHtglrgBiJLkJfkJQbxQURH1rdSAq9xyWDxQy3sdfosz0RxzeLOwDxdRJgy1G6VWG7UuXoIdz0RxzuWyqs2jPdAnTakbfRo6U2NyzebYylYydz8AdIvk7kJiaPmwwLlJLa6MqFwc6ZOQpxqyfhqbNrerahG(sdfosaNGUG(6OVb6QbxQURH1rdSAq9xyWDxQy3sdfoszSHmwQmIsuRURH1rdSAq9xyWDxQyhXHm61Rmkymij7K0bTMwaLGIvhDx7tSmIazSfzSHmETbXkLDLreGuglRYLrVELr8XGWGAu(PyNW3(maFEFn)KxgBvglxgBiJOe1QdRm6T42XOoIdzSHmkymij7K0bTMwaLGIvhDx7tSm2kszKxqkJLiJE9kJxBqSszxzebiLXt3cOBc9zjOpJQ(bSptueOGZiwoGdqFPHchjGtqxqFD03a9sLruIA1Hvg9wC7yuhDx7tSm2QmIOdrzSmKrEbPmwgYikrT6WkJElUDmQdRMOOm61RmIsuRoSYO3IBhJ6ioKXgYikrT6UgwhnWQb1FHb3DPIDehYyjGUj0NLGo85918t(akdQafCgregWbOV0qHJeWjOlOVo6BGUAWLQ7fRsqlWT0qHJugBiJQbxQURH1rdSAq9xyWDxQy3sdfoszSHmIsuRUxSkbTahXHm2qgrjQv31W6ObwnO(lm4UlvSJ4a0nH(Se0RugwdyFMOiqbNr8uaoa9LgkCKaobDb91rFd0rjQvNHfljTumhXbOBc9zjOdTMwaLGIvGcoJixb4a0xAOWrc4e0f0xh9nqxWyqs2jzGotOYydzSqzun4s1DnSoAGvdQ)cdU7sf7wAOWrc6MqFwc6qRPfqjOyfOGZiEAahG(sdfosaNGUG(6OVb6QbxQUxSkbTa3sdfoszSHmwOmwQmETbXkLDLreiJCjUsgBiJcgdsYojDqRPfqjOy1r31(elJTIugBrglb0nH(Se0FXQe0cak4mICjahG(sdfosaNGUG(6OVb6cgdsYojd0zcvgBiJcFJYpSmIazun4s1nHplWQb1FHb3DPIDlnu4ibDtOplbDO10cOeuScuWzerOaoa9LgkCKaobDb91rFd0vdUuDVyvcAbULgkCKYydzeLOwDVyvcAboIdzSHmIsuRUxSkbTahDx7tSm2QmIOdrzSmKrEbPmwgYikrT6EXQe0cCy1efbDtOplb9kLH1a2NjkcuWzellahG(sdfosaNGUG(6OVb6cgdsYojd0zcf0nH(Se0HwtlGsqXkqbNlVfahG(sdfosaNGUj0NLGEfA3fW(mrrqxqFD03aD6Q0H9nu4aDrbc4cQr5NIbNreOGZLJiGdqFPHchjGtqxqFD03aD8XGWGAu(PyNW3(maFEFn)KxgrGmIOm2qglugPe5Qmk)Ct4ZgoWQbE6mnGjsYr)K3nUG4pogPm61RmwQmIsuRUj8zdhy1apDMgWej5OFY7ioKXgYikrT6UgwhnWQb1FHb3DPIDehYyjGUj0NLG(mQ6ZfewXbuW5YlhWbOV0qHJeWjOlOVo6BGUAWLQ7fRsqlWT0qHJugBiJOe1Q7fRsqlWrCiJnKXsLruIA19IvjOf4O7AFILXwLrEbPmwgY4PKXYqgrjQv3lwLGwGdRMOOm61RmIsuRoSYO3IBhJ6ioKrVELXcLr1Glv31W6ObwnO(lm4UlvSBPHchPmwcOBc9zjOxPmSgW(mrrGcoxocd4a0nH(Se0f(2NbFJ2Cyf0xAOWrc4eOGZLFkahG(sdfosaNGUG(6OVb6QbxQoSA6lcKpw4Bu(5wAOWrc6MqFwc6y10xeiFSW3O8dOGZLZvaoa9LgkCKaobDb91rFd0lugvdUuDh0)AWWG7Uun4Jv3sdfosz0Rxzun4s1Dq)RbddU7s1GpwDlnu4iLXgYyPYyHY4Xux9Plm4Ulvd6mH(nNmwcOBc9zjOpJQ(Hb3DPAqGcox(PbCa6MqFwc6WN3xZp5dOmOc6lnu4ibCcuW5Y5saoa9lR5N8GZic6lnu4cxwZp5bCc6MqFwc6vODxa7ZefbDrbc4cQr5NIbNre0f0xh9nqNUkDyFdfoqFPHchjGtGcoxocfWbOV0qHJeWjOV0qHlCzn)KhWjOlOVo6BG(L1C3LQJ8XQLIjJiqgpnOBc9zjOxH2DbSptue0VSMFYdoJiqbNlVSaCa6xwZp5bNre0xAOWfUSMFYd4e0nH(Se0RugwdyFMOiOV0qHJeWjqbkOtUQravahGZic4a0xAOWrcqbDb91rFd0nU8OVoNLIHvQbd0HzPLI5wAOWrc6MqFwc6OqgJesGvGcoxoGdqFPHchjGtqxqFD03a96Z7Rb6U2NyzSvz80TiJE9kJcgdsYojD8egL8TmWQbJlpkt9D0DTpXYyRYic3cOBc9zjOFW0NLafCgHbCa6MqFwc6N8jza7pJc6lnu4ibCcuW5tb4a0nH(Se0jWl86UyqFPHchjGtGcoZvaoaDtOplb96txyWDxQge0xAOWrc4eOGZNgWbOBc9zjOJvg9ggC3LQbb9LgkCKaobk4mxcWbOBc9zjOlyPyPsnDKHk0Ud0xAOWrc4eOGZiuahGUj0NLGokKXidSAq9xy5Ufa6lnu4ibCcuW5YcWbOBc9zjOZtyuY3YaRgmU8Om1h0xAOWrc4eOGZi2cGdq3e6ZsqVYee4rgmU8OVUa6SlOV0qHJeWjqbNrerahGUj0NLG(bb9Rf8jFafAyf0xAOWrc4eOGZiwoGdq3e6Zsqx9xGirzejzOYOIb6lnu4ibCcuWzeryahGUj0NLG(DxgTGaRgGeINmqsNDXG(sdfosaNafCgXtb4a0nH(Se0P)XbCHpd4dtmqFPHchjGtGcoJixb4a0nH(Se0pHrHKn3Nb6WS0sXa9LgkCKaobk4mINgWbOV0qHJeWjOlOVo6BGUAu(Po)zq1pCiuzebYicTfz0Rxzunk)uN)mO6hoeQm2QmwElYOxVYy9591aDx7tSm2QmIWTa6MqFwc60zhFYhQq7omqbNrKlb4a0nH(Se09Nr1WW4LIb6lnu4ibCcuWzerOaoa9LgkCKaobDb91rFd0lugvdUuDgwSK0sXClnu4iLrVELruIA1zyXsslfZrCiJE9kJcgdsYojDgwSK0sXC0DTpXYicKrUQfq3e6ZsqhfYyKHkbTaGcoJyzb4a0xAOWrc4e0f0xh9nqVqzun4s1zyXsslfZT0qHJug96vgrjQvNHfljTumhXbOBc9zjOJokE0IFYduW5YBbWbOV0qHJeWjOlOVo6BGEHYOAWLQZWILKwkMBPHchPm61RmIsuRodlwsAPyoIdz0RxzuWyqs2jPZWILKwkMJUR9jwgrGmYvTa6MqFwc61NouiJrcuW5YreWbOV0qHJeWjOlOVo6BGEHYOAWLQZWILKwkMBPHchPm61RmIsuRodlwsAPyoIdz0RxzuWyqs2jPZWILKwkMJUR9jwgrGmYvTa6MqFwc6wkgwPgmimieOGZLxoGdqFPHchjGtqxqFD03a9cLr1GlvNHfljTum3sdfosz0RxzSqzeLOwDgwSK0sXCehGUj0NLGoQXhy1GsFrrmqbNlhHbCa6lnu4ibCc6MqFwc6h0)YOKVbdNynhOlOVo6BGEHYikrT6oO)LrjFdgoXAohXbOlkqaxqnk)um4mIafCU8tb4a0nH(Se0Bo8XObLP7c6lnu4ibCcuW5Y5kahGUj0NLGE1wqPwIRe4NLG(sdfosaNafCU8td4a0xAOWrc4e0f0xh9nqVuz8AdIvk7kJiaPmE6wKrVELrbJbjzNKoO10cOeuS6O7AFILXwrkJ8csz0RxzeLOwDqRPfWeu(5ioKXsaDtOplb9j8zFYhW(mrrGcoxoxcWbOV0qHJeWjOlOVo6BGUj0V5cl39hwgrGmwUm2qglvgXhdcdQr5NIDcF7Za85918tEzebYy5YOxVYi(yqyqnk)uSdAnTa6SRmIazSCzSeq3e6ZsqNsKbtOpldWhRGo8XAiT7aDJnGcoxocfWbOV0qHJeWjOlOVo6BGEHYOAWLQdRm6nm4Ulvd6wAOWrkJnKrtOFZfwU7pSm2kszSCq3e6ZsqNsKbtOpldWhRGo8XAiT7aD8N8WfuJYpfOGZLxwaoa9LgkCKaobDb91rFd0vdUuDyLrVHb3DPAq3sdfoszSHmAc9BUWYD)HLXwrkJLd6MqFwc6uImyc9zza(yf0HpwdPDhOJxa)jpCb1O8tbkqb9d6eSlQPaoaNreWbOV0qHJeWjON2DGUXLX(g1WHkl1aRgoyNmkOBc9zjOBCzSVrnCOYsnWQHd2jJcuW5YbCa6MqFwc6hm9zjOV0qHJeWjqbkOBSb4aCgrahG(sdfosaNGUG(6OVb6Oe1QBcF2N8bSptu0rCa6MqFwc6ZOQpxqyfhqbNlhWbOBc9zjOl8Tpd(gT5WkOV0qHJeWjqbNryahG(sdfosaNGUG(6OVb6QbxQoSYO3IBhJ6wAOWrc6MqFwc6yLrVf3ogfOGZNcWbOV0qHJeWjOBc9zjOxH2DbSptue0f0xh9nqNUkDyFdfozSHmAc9BUajtDvODxa7ZefLXwLrewgBiJMq)MlSC3FyzSvKYixb6IceWfuJYpfdoJiqbN5kahG(sdfosaNGUG(6OVb6fkJMq)MlqYuxfA3fW(mrrq3e6ZsqVcT7cyFMOiqbNpnGdqFPHchjGtqxqFD03aD1Glv3e(Sp5dyFMOOBPHchPm2qgV2GyLYUYicqkJNUfq3e6ZsqFcF2N8bSptueOGZCjahG(sdfosaNGUG(6OVb6QbxQodlwsAPyULgkCKYydzSuzSqz8yQdRm6nm4Ulvd6mH(nNmwIm2qglvglugvdUuDVyvcAbULgkCKYOxVYyHYikrT6EXQe0cCehYydzSqzuWyqs2jP7fRsqlWrCiJLa6MqFwc6gwSK0sXak4mcfWbOV0qHJeWjOlOVo6BGUAWLQd(CbXtgUg)1ckt31T0qHJe0nH(Se0Hpxq8KHRXFTGY0Dbk4Czb4a0xAOWrc4e0f0xh9nqNsKRYO8ZnHpB4aRg4PZ0aMijh9tE34cI)4yKYydzSqzeLOwDt4ZgoWQbE6mnGjsYr)K3rCa6MqFwc6ZOQFa7Zefbk4mITa4a0xAOWrc4e0f0xh9nqNsKRYO8ZrUDO0Dz0awz5CJli(JJrkJnKXsLXcLr1Glv3b9Vgmm4Ulvd(y1T0qHJug96vglvglugpM6WkJEddU7s1GotOFZjJnKXcLXJPU6txyWDxQg0zc9BozSezSeq3e6ZsqFgv9ddU7s1GafCgrebCa6lnu4ibCc6MqFwc6qRPfqjOyf0f0xh9nqhFmimOgLFk2j8TpdWN3xZp5LXwLXtjJE9kJOe1QdAnTaMGYphXHm61RmwQmQgCP6UgwhnWQb1FHb3DPIDlnu4iLXgYyHYikrT6UgwhnWQb1FHb3DPIDehYydz8AdIvk7kJiaPmE6wKXsaDrbc4cQr5NIbNreOGZiwoGdqFPHchjGtqxqFD03a9cLr1Glv31W6ObwnO(lm4UlvSBPHchPm61RmIsuRoSYO3IBhJ6ioKrVELXRniwPSRmIaKYyPYiIT0Imw2KXtjJLHmIpgeguJYpf7e(2Nb4Z7R5N8YyjYOxVYikrT6UgwhnWQb1FHb3DPIDehYOxVYi(yqyqnk)uSt4BFgGpVVMFYlJiqgryq3e6ZsqFgv95ccR4ak4mIimGdqFPHchjGtqxqFD03aDuIA1Hvg9wC7yuhDx7tSm2QmIWYyziJ8cszSmKruIA1Hvg9wC7yuhwnrrq3e6Zsqx4BFgGpVVMFYduWzepfGdqFPHchjGtqxqFD03aDuIA1bTMwatq5NJ4qgBiJ4JbHb1O8tXoHV9za(8(A(jVm2QmEkzSHmwQmwOmEm1Hvg9ggC3LQbDMq)MtglrgBiJKm1vH2DbSptu0PVO4N8GUj0NLGo0AAbuckwbk4mICfGdqFPHchjGtqxqFD03aD1Glv3G7UunyafAy1T0qHJugBiJ4JbHb1O8tXoHV9za(8(A(jVm2QmYvYydzSuzSqz8yQdRm6nm4Ulvd6mH(nNmwcOBc9zjOp4UlvdgqHgwbk4mINgWbOBc9zjOl8TpdWN3xZp5b9LgkCKaobk4mICjahG(sdfosaNG(sdfUWL18tEaNGUG(6OVb6Oe1QdAnTaMGYphXHm2qgfmgKKDsgOZekOBc9zjOdTMwaLGIvq)YA(jp4mIafCgrekGdq)YA(jp4mIG(sdfUWL18tEaNGUj0NLGEfA3fW(mrrqxuGaUGAu(PyWzebDb91rFd0PRsh23qHd0xAOWrc4eOGZiwwaoa9lR5N8GZic6lnu4cxwZp5bCc6MqFwc6vkdRbSptue0xAOWrc4eOaf0XlG)KhUGAu(PaoaNreWbOV0qHJeWjOBc9zjOxH2DbSptue0f0xh9nqVuzKUR9jwgBfPmYliLXsKXgYyPYikrT6GwtlGjO8ZrCiJE9kJfkJOe1QdfYyKqcS6ioKXsaDrbc4cQr5NIbNreOGZLd4a0xAOWrc4e0f0xh9nqxn4s1n4UlvdgqHgwDlnu4ibDtOplb9b3DPAWak0WkqbNryahG(sdfosaNGUG(6OVb6QbxQoSYO3IBhJ6wAOWrkJnKXsLXRniwPSRm2QmEQtjJLa6MqFwc6yLrVf3ogfOGZNcWbOV0qHJeWjOlOVo6BGUAWLQBcF2N8bSptu0T0qHJe0nH(Se0NWN9jFa7Zefbk4mxb4a0xAOWrc4e0f0xh9nqhLOwDN8jzGNaRoSAIIYyRYiIiuz0RxzeLOwDqRPfWeu(5ioaDtOplbDO10cOeuScuW5td4a0xAOWrc4e0f0xh9nqhLOwDyLrVf3og1rCa6MqFwc6WN3xZp5dOmOcuWzUeGdqFPHchjGtqxqFD03aDuIA1nHpB4aRg4PZ0aMijh9tEhXbOBc9zjOpJQ(CbHvCafCgHc4a0xAOWrc4e0f0xh9nqVuzeFmimOgLFk2j8TpdWN3xZp5LreiJikJLiJnKXsLXcLrsM6Qq7Ua2Njk6ORsh23qHtglb0nH(Se0NrvFUGWkoGcoxwaoa9LgkCKaobDb91rFd0XhdcdQr5NIDcF7Za85918tEzSvzSCzSHmETbXkLDLreGugpDlYydzSuzeLOwDN8jzGNaRoSAIIYyRYy5TiJE9kJxBqSszxzebYyz1ImwcOBc9zjOpJQ(bSptueOGZi2cGdqFPHchjGtqxqFD03a9sLruIA1Hvg9wC7yuhDx7tSm2QmIOdrzSmKrEbPmwgYikrT6WkJElUDmQdRMOOm61RmIsuRoSYO3IBhJ6ioKXgYikrT6UgwhnWQb1FHb3DPIDehYyjGUj0NLGo85918t(akdQafCgrebCa6lnu4ibCc6c6RJ(gORgCP6EXQe0cClnu4iLXgYOAWLQ7AyD0aRgu)fgC3Lk2T0qHJugBiJOe1Q7fRsqlWrCiJnKruIA1DnSoAGvdQ)cdU7sf7ioaDtOplb9kLH1a2NjkcuWzelhWbOV0qHJeWjOlOVo6BGokrT6mSyjPLI5ioaDtOplbDO10cOeuScuWzeryahG(sdfosaNGUG(6OVb6cgdsYojd0zcvgBiJfkJQbxQURH1rdSAq9xyWDxQy3sdfosq3e6ZsqhAnTakbfRafCgXtb4a0xAOWrc4e0f0xh9nqxn4s19IvjOf4wAOWrkJnKXcLXsLXRniwPSRmIazKlXvYydzuWyqs2jPdAnTakbfRo6U2NyzSvKYylYyjGUj0NLG(lwLGwaqbNrKRaCa6lnu4ibCc6c6RJ(gOlymij7KmqNjuzSHmk8nk)WYicKr1Glv3e(SaRgu)fgC3Lk2T0qHJe0nH(Se0HwtlGsqXkqbNr80aoa9LgkCKaobDb91rFd0vdUuDVyvcAbULgkCKYydzeLOwDVyvcAboIdq3e6ZsqVszynG9zIIafCgrUeGdq3e6Zsqx4BFg8nAZHvqFPHchjGtGcoJicfWbOV0qHJeWjOlOVo6BGUAWLQdRM(Ia5Jf(gLFULgkCKGUj0NLGown9fbYhl8nk)ak4mILfGdqFPHchjGtqxqFD03a9cLr1Glv3b9Vgmm4Ulvd(y1T0qHJug96vgvdUuDh0)AWWG7Uun4Jv3sdfoszSHmwQmwOmEm1Hvg9ggC3LQbDMq)Mtglb0nH(Se0Nrv)WG7UuniqbNlVfahGUj0NLGo85918t(akdQG(sdfosaNafCUCebCa6xwZp5bNre0xAOWfUSMFYd4e0nH(Se0Rq7Ua2Njkc6IceWfuJYpfdoJiOlOVo6BGoDv6W(gkCG(sdfosaNafCU8YbCa6lnu4ibCc6lnu4cxwZp5bCc6c6RJ(gOFzn3DP6iFSAPyYicKXtd6MqFwc6vODxa7Zefb9lR5N8GZicuW5YryahG(L18tEWzeb9LgkCHlR5N8aobDtOplb9kLH1a2Njkc6lnu4ibCcuGcuq3iuFgf07)LaA6ZseIuRQafOaa]] )

end
