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
        traveling_storms = 730, -- 204403
        lightning_lasso = 731, -- 305483
        elemental_attunement = 727, -- 204385
        control_of_lava = 728, -- 204393
        skyfury_totem = 3488, -- 204330
        grounding_totem = 3620, -- 204336
        swelling_waves = 3621, -- 204264
        spectral_recovery = 3062, -- 204261
        purifying_waters = 3491, -- 204247
        counterstrike_totem = 3490, -- 204331
        traveling_storms = 730, -- 204403
        lightning_lasso = 731, -- 305483
        elemental_attunement = 727, -- 204385
        control_of_lava = 728, -- 204393
        skyfury_totem = 3488, -- 204330
        grounding_totem = 3620, -- 204336
        swelling_waves = 3621, -- 204264
        spectral_recovery = 3062, -- 204261
        purifying_waters = 3491, -- 204247
        counterstrike_totem = 3490, -- 204331
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

            -- TODO: add echoes of the great sundering legendary buff
            startsCombat = true,
            texture = 451165,

            handler = function ()
                --removeBuff( "echoes_of_the_great_sundering" )
                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )
            end,
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

    spec:RegisterPack( "Elemental", 20201024, [[dS05HaqiOQ6reu2Kku9jkseJsQIoLuLSkksQELuYSOiULeQAxQ0VKcdJGCmPQwguLNjvPMMuKUMekBtkIVjvHgNeQCoksyDuKsVJIeL5rq19ur7dQkhuQcwOe8qviXfvHYgvHK6JuKIojfPALqLzQcj5MuKOANuWpPifgkfjHLsrsYtP0uPqxLIePTsrs5RuKeTxH)Qudwshg1IHYJHmzLCzWMjXNjPrlvoTIxRcMnr3Mq7w0Vv1WjWXvHulNuphX0P66s02Ls9DPOgpfjPoVeY6vHy(uu7hPJ(HXWUyhcd4jeEc1xi8A6TF)I1JnTjH1lsaewbm6aRcHnzriShtcIq6SmSc4IKpVcJHL8LAee2o3fqmTnAOoExj2f9IniJyPK95tKMv8gKre1iSyLJ0n9mWc7IDimGNq4juFHWRP3(9BAXHxpgwIaafgWRj4f2UzTGmWc7ciOWkmA9ysqesNL0QTJf5KIty0QPbYFmqtR41utOv8ecpHO4O4egTEu64ufiMwkoHrRfpT2dRfSOvmgDOuaTEmcbseqRm2ihVOlfNWO1INwn2mWhi0Q)06ikq)TbA9yOUFsvA129Od0QaqtRMoQOI3udMKqRQLZcUHvG(vgjewHrRhtcIq6SKwTDSiNuCcJwnnq(JbAAfVMAcTINq4jefhfNWO1JshNQaX0sXjmAT4P1EyTGfTIXOdLcO1JriqIaALXg54fDP4egTw80QXMb(aHw9Nwhrb6VnqRhd19tQsR2UhDGwfaAA10rfv8MAWKeAvTCwWLIJIJr(8j5kqdOxeJ9wNnKJANNtQUjDdixuCmYNpjxbAa9IyS36Srjb2JdIMKSiCYhH0XAMSv(03VYwW3mOP4egTAkLa0Q1FT4baeaAAvGgqVig70AzkbcHwjViqR8ArO1MhPKwjc4MtAL8FEP4yKpFsUc0a6fXyV1zdI)AXdaia0MmkNolH0Ve)1IhaqaOVqYysyD8EQ5zTH2q6xETix0xMUW7TzZAEwBOnK(LxlYDs8vmH6ffhJ85tYvGgqVig7ToBasqesNLBmjtCtgLtNLq6xqcIq6SCJjzIFHKXKWIIJr(8j5kqdOxeJ9wNnKCBEJvQjUjJYj(DwcPFbjicPZYnMKj(fsgtclkokoHrRhZunGkDyrRqBqxeT6JiqREhqRmYFnToeALBZJKXKWLIty06rHjoTwq()swsCAvKZswklIwhfA17aAThocOhhOvJAECAThseqCnlPvtva5toraToeAvGgiq6xkog5ZNKtm5)lzjXnzuo5Ja6XHlNiG4AwU1a5torWfsgtclkoHrRMEw8OxeJDAvW7ZN06qOvbAqb0q6dlLfrRYjpalA1FA17aA10SK1RHtA9vO1E4iG(9otO1YucecTIErm2P1MhPKwHCrRKUx7YIUuCmYNpjToBi495ttgLtLrTZ3AqKNKi8MiKzZO)LRV58QwY61W5(v28ra97DxniYtseEVfIIJIty0QPNoO1LcCA9vOvetCYLIJr(8jP1zJMNCTjDaRP4yKpFsAD2OKa7XbrcfhJ85tsRZgkJg2GeeH0zjfhJ85tsRZge)1IBqcIq6SKIJIJr(8jP1zd0NiiDn7WARizrGIJr(8jP1zdm5)R9RS9oydjiwefhJ85tsRZgQLSEnCUFLnFeq)EhfhJ85tsRZgkpQKaRnFeqpoSXawKIJr(8jP1zdbL6rPOjv3ysM4uCmYNpjToB4DWUmX(YCTvEncO4yKpFsAD2qeeFDr7xzllrZAV0alsO4yKpFsAD2qpceiH9KBIagbuCmYNpjToB08RLR2WKBnq(KteqXXiF(K06SHgybtQUvKSiqmzuoDwRc(TdyP3TfGC8vCcz2SZAvWVDal9UTaKlC8eYSzLrTZ3AqKNKi8ElefNWOvtpPvetaA10PvLxR(oTsErW7Mu9sXXiF(K06SrhWAFdecKiGIJIJr(8jP1zdm5)RTsPUitgLt87Ses)YeeKlorWfsgtclZMXkvuUmbb5IteClfy2m6F56BoVmbb5IteC1GipjbFftikog5ZNKwNnWanb0hMu1Kr5e)olH0Vmbb5IteCHKXKWYSzSsfLltqqU4eb3sbuCmYNpjToBOmAat()YKr5e)olH0Vmbb5IteCHKXKWYSzSsfLltqqU4eb3sbMnJ(xU(MZltqqU4ebxniYtsWxXeIIJr(8jP1zdoraX1SCJyP0Kr5e)olH0Vmbb5IteCHKXKWYSzSsfLltqqU4eb3sbMnJ(xU(MZltqqU4ebxniYtsWxXeIIJIJr(8jP1zJ2araO3(7GifhJ85tsRZgc0J4Rxdl3nZTbkog5ZNKwNnuyy7AojkLK5tkog5ZNKwNnqD8K7ow3giUjJYjJ8PnSHeehGGV(uCuCmYNpjToBGXQ7xz76bDGyYOCIFNLq6xMGGCXjcUqYysyz2m(XkvuUmbb5IteClfqXXiF(K06SbG6(jv3KUhDWKr5SNImijU(fX3zteYSz0)Y13CELCBEJvQj(vdI8KeHFQIwMnJvQOCLCBEtk1QWTuqVO4yKpFsAD2qxMBg5ZNB5qCtsweo5hmzuozKpTHnKG4ae8H3X7jraiLBN1QGtUOoEYTCu78Csv8HNzZebGuUDwRco5k528gdyr8HxVO4yKpFsAD2qxMBg5ZNB5qCtsweojtQkHTZAvWP4O4egTAkVu6dT6SwfCALr(8jTkqpVE8IOv5qCkog5ZNKl)WjXFT4baeaAkog5ZNKl)qRZgmbb5IteqXXiF(KC5hAD2qohD5S2ISQiV93brkog5ZNKl)qRZgaR9UJUKpauCmYNpjx(HwNnKCBEJbSOjJYPZsi9ltqqU4ebxizmjSO4yKpFsU8dToBG64j3YrTZZjvP4yKpFsU8dToBqC2h0EneuhRvbkog5ZNKl)qRZgsUnVXk1e3eXV9KQN9nzuoDwcPFzccYfNi4cjJjHffhJ85tYLFO1zdfjlcBs3JoyI43Es1Z(MmkNAqrdKogtchhRur5cOUFs1nP7rhURV5KIJr(8j5Yp06SHI(j(M09OdMi(TNu9SpfhfNWOv7KQsGwnYAvWP1Ea5ZN0QPc986XlIwpQgItXjmA9yjPud06rTLwhcTYiFAd0AzkbcHwl6lP1oUnqR9BkT(AAv81aTsCgDGqRVcTAQCYfTAAwsCAvr)I0Q1FTiTEmjicPZYlT2ZJTubAfXeW0sRLcqV4KQ0Apqq0kwPtRmYN2aTApMPmAD9PPeNw7ffhJ85tYLmPQe2oRvb)urYIWM09OdMGkcjHTZAvWjN9nzuo7j(9bDysvZMxVFvKSiSjDp6WvdI8KeHFQIw9644hRur5sk1QW(v2c(Mb9TuWXXpwPIYfqD)KQBs3JoClfqXXiF(KCjtQkHTZAvWBD2GjiixCIakog5ZNKlzsvjSDwRcERZgGeeH0z5gtYeNIJr(8j5sMuvcBN1QG36SbXFT4baeaAkog5ZNKlzsvjSDwRcERZgY5OlN1wKvf5T)oisXXiF(KCjtQkHTZAvWBD2qoQDEoP6wYeYtXXiF(KCjtQkHTZAvWBD2qYT5nwPM4uCmYNpjxYKQsy7Swf8wNnu0pX3KUhDWKr5eRur5oiqPux0TuWX7PidsIRFrH3eHmBgRur5oiqPux0vdI8KeHRIwM69SFlSsfL7GaLsDrxIZOd9QxuCmYNpjxYKQsy7Swf8wNngeOuQlIIJr(8j5sMuvcBN1QG36SbWAVBt6E0bkog5ZNKlzsvjSDwRcERZgeN9bTxdb1XAvGIJr(8j5sMuvcBN1QG36SHCu78Cs1n2lDkog5ZNKlzsvjSDwRcERZgkswe2KUhDWeXV9KQN9nbvescBN1QGto7BYOCQbfnq6ymjqXXiF(KCjtQkHTZAvWBD2qrYIWM09OdMi(TNu9SVjJYP43geH0VRH4CIa81ekog5ZNKlzsvjSDwRcERZgk6N4Bs3JoyI43Es1Z(HTnOjZNHb8ecpH6leEcf2MzDoPkjSMUOGx7WIwBkTYiF(KwLdXjxkUWYLE3RdRDelLSpFEu0SIhw5qCsymSKjvLW2zTk4HXWq)WyyHKXKWkkewg5ZNHvrYIWM09OdHfPhh0dh2EsR4Nw9bDysvA1SzAD9(vrYIWM09OdxniYtsOvHFsRQOfT2lA940k(PvSsfLlPuRc7xzl4Bg03sb06XPv8tRyLkkxa19tQUjDp6WTuqyrfHKW2zTk4KWq)Wdd4fgdlJ85ZWYeeKlorqyHKXKWkkeEyO3HXWYiF(mSGeeH0z5gtYepSqYysyffcpm00WyyzKpFgwI)AXdaia0HfsgtcROq4HHIfgdlJ85ZWkNJUCwBrwvK3(7GyyHKXKWkkeEyOjHXWYiF(mSYrTZZjv3sMq(WcjJjHvui8WqpggdlJ85ZWk528gRut8WcjJjHvui8WqXfgdlKmMewrHWI0Jd6HdlwPIYDqGsPUOBPaA940ApPvrgKex)I0QWP1MieTA2mTIvQOCheOuQl6QbrEscTkCAvfTOvtDATN0AFATfTIvQOCheOuQl6sCgDGw7fT2RWYiF(mSk6N4Bs3JoeEyWuegdlJ85ZWoiqPuxuyHKXKWkkeEyOVqHXWYiF(mSaR9UnP7rhclKmMewrHWdd97hgdlJ85ZWsC2h0EneuhRvHWcjJjHvui8WqF8cJHLr(8zyLJANNtQUXEPhwizmjSIcHhg637Wyyf)2tQgg6hwizmjSf)2tQgfclJ85ZWQizryt6E0HWIkcjHTZAvWjHH(HfPhh0dhwnOObshJjHWcjJjHvui8Wq)MggdlKmMewrHWcjJjHT43Es1Oqyr6Xb9WHv8BdIq631qCoraTIpATjHLr(8zyvKSiSjDp6qyf)2tQgg6hEyOFXcJHv8BpPAyOFyHKXKWw8BpPAuiSmYNpdRI(j(M09OdHfsgtcROq4Hhw(HWyyOFymSmYNpdlXFT4baea6WcjJjHvui8WaEHXWYiF(mSmbb5IteewizmjSIcHhg6DymSmYNpdRCo6YzTfzvrE7VdIHfsgtcROq4HHMggdlJ85ZWcS27o6s(aewizmjSIcHhgkwymSqYysyffclspoOhoSolH0Vmbb5IteCHKXKWkSmYNpdRKBZBmGfdpm0KWyyzKpFgwuhp5woQDEoPAyHKXKWkkeEyOhdJHLr(8zyjo7dAVgcQJ1QqyHKXKWkkeEyO4cJHfsgtcROqyHKXKWw8BpPAuiSi94GE4W6Ses)YeeKlorWfsgtcRWYiF(mSsUnVXk1epSIF7jvdd9dpmykcJHfsgtcROqyHKXKWw8BpPAuiSi94GE4WQbfnq6ymjqRhNwXkvuUaQ7NuDt6E0H76BodlJ85ZWQizryt6E0HWk(TNunm0p8WqFHcJHv8BpPAyOFyHKXKWw8BpPAuiSmYNpdRI(j(M09OdHfsgtcROq4Hh2fOWLspmgg6hgdlKmMewbwyr6Xb9WHLpcOhhUCIaIRz5wdKp5ebxizmjSclJ85ZWIj)FjljE4Hb8cJHfsgtcROqyr6Xb9WHvzu78Tge5jj0QWP1MieTA2mTI(xU(MZRAjRxdN7xzZhb0V3D1GipjHwfoT2BHclJ85ZWk495ZWdd9omgwg5ZNHT5jxBshW6WcjJjHvui8WqtdJHLr(8zyljWECqKewizmjSIcHhgkwymSmYNpdRYOHnibriDwgwizmjSIcHhgAsymSmYNpdlXFT4gKGiKoldlKmMewrHWdd9yymSmYNpdl6teKUMDyTvKSiewizmjSIcHhgkUWyyzKpFgwm5)R9RS9oydjiwuyHKXKWkkeEyWuegdlJ85ZWQwY61W5(v28ra97DHfsgtcROq4HH(cfgdlJ85ZWQ8OscS28ra94WgdyXWcjJjHvui8Wq)(HXWYiF(mSck1JsrtQUXKmXdlKmMewrHWdd9Xlmgwg5ZNH17GDzI9L5AR8AeewizmjSIcHhg637WyyzKpFgwrq81fTFLTSenR9sdSijSqYysyffcpm0VPHXWYiF(mS6rGajSNCteWiiSqYysyffcpm0VyHXWYiF(mSn)A5Qnm5wdKp5ebHfsgtcROq4HH(njmgwizmjSIcHfPhh0dhwN1QGF7aw6DBbiNwXhTwCcrRMntRoRvb)2bS072cqoTkCAfpHOvZMPvLrTZ3AqKNKqRcNw7TqHLr(8zy1alys1TIKfbs4HH(9yymSmYNpdBhWAFdecKiiSqYysyffcpm0V4cJHfsgtcROqyr6Xb9WHf)0QZsi9ltqqU4ebxizmjSOvZMPvSsfLltqqU4eb3sb0QzZ0k6F56BoVmbb5IteC1GipjHwXhTwmHclJ85ZWIj)FTvk1ffEyOVPimgwizmjSIcHfPhh0dhw8tRolH0Vmbb5IteCHKXKWIwnBMwXkvuUmbb5IteClfewg5ZNHfd0eqFys1Wdd4juymSqYysyffclspoOhoS4NwDwcPFzccYfNi4cjJjHfTA2mTIvQOCzccYfNi4wkGwnBMwr)lxFZ5LjiixCIGRge5jj0k(O1IjuyzKpFgwLrdyY)xHhgWRFymSqYysyffclspoOhoS4NwDwcPFzccYfNi4cjJjHfTA2mTIvQOCzccYfNi4wkGwnBMwr)lxFZ5LjiixCIGRge5jj0k(O1IjuyzKpFgworaX1SCJyPm8WaE4fgdlJ85ZW2gica92FhedlKmMewrHWdd417WyyzKpFgwb6r81RHL7M52qyHKXKWkkeEyaVMggdlJ85ZWQWW21CsukjZNHfsgtcROq4Hb8kwymSqYysyffclspoOhoSmYN2WgsqCacTIpATFyzKpFgwuhp5UJ1TbIhEyaVMegdlKmMewrHWI0Jd6Hdl(PvNLq6xMGGCXjcUqYysyrRMntR4NwXkvuUmbb5IteClfewg5ZNHfJv3VY21d6aj8WaE9yymSqYysyffclspoOhoS9KwfzqsC9lsR47KwBIq0QzZ0k6F56BoVsUnVXk1e)QbrEscTk8tAvfTOvZMPvSsfLRKBZBsPwfULcO1Efwg5ZNHfqD)KQBs3JoeEyaVIlmgwizmjSIcHfPhh0dhwg5tBydjioaHwXhTIhTECATN0kraiLBN1QGtUOoEYTCu78CsvAfF0kE0QzZ0kraiLBN1QGtUsUnVXawKwXhTIhT2RWYiF(mS6YCZiF(ClhIhw5q8DYIqy5hcpmGNPimgwizmjSIcHLr(8zy1L5Mr(85woepSYH47KfHWsMuvcBN1QGhE4HvGgqVig7HXWq)WyyzKpFgw5O255KQBs3aYvyHKXKWkkeEyaVWyyHKXKWkke2KfHWYhH0XAMSv(03VYwW3mOdlJ85ZWYhH0XAMSv(03VYwW3mOdpm07WyyHKXKWkkewKECqpCyDwcPFj(RfpaGaqFHKXKWIwpoT2tAvZZAdTH0V8ArUOVmDAv40AVPvZMPvnpRn0gs)YRf5ojTIpATycrR9kSmYNpdlXFT4baea6WddnnmgwizmjSIcHfPhh0dhwNLq6xqcIq6SCJjzIFHKXKWkSmYNpdlibriDwUXKmXdpmuSWyyHKXKWkkewKECqpCyXpT6Ses)csqesNLBmjt8lKmMewHLr(8zyLCBEJvQjE4HhE4Hhb]] )

end
