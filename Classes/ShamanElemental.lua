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

    spec:RegisterPack( "Elemental", 20201020, [[dO0rHaqicIhrqAtqu1NiOkmkckDkcQ8kjvZIQIBjPe7cQ(LeAyqPoMsQLbL8mjIMgbfxtIW2Gi6BqKQXrvP6CquzDuvs9oQkbnpjL6EqyFquoOKsAHuv9qQkjxeIKnsqv0hPQe6KuvkRekMjbvj3KGQIDss(jvLidLGQQwkbvLEkPMkj1vjOQYwPQe1xPQeyVc)vPgSuomQfdPhRQjlvxgSzQYNjXOvItR41kjZMOBtODl63QmCcCCisz5u55iMoLRljBxI67sKgpbvPoVKI1dry(sW(r6yDOo0D2GqfwyJf2RXglSXxJCyHCLe5cTvJai0c4FfRaHozri0iLeeH0yzOfW1ipUhQdn5QCpe6fZeq81flQm2sfk(FIfjJyLKT5Y3XEwrYi(fdnA1inFld0q3zdcvyHnwyVgBSWgFnYHfYvsFp0ebWhQWcjXk0ltVdzGg6oq(qluAdPKGiKglPn9clYjfJqPnFP3ouWrByHTp0gwyJf2umumcL28vlCQaeFnfJqPTAH2Q1Eh60gk)RQeqBifHa5d0gJoYXQbNIrO0wTqBQlf4veAZoABef4UYaTHu)YnPcTPxUFfTjaC0MV91ul(YWKeAtPA6aEOf4oVrcHwO0gsjbrinwsB6fwKtkgHsB(sVDOGJ2WcBFOnSWglSPyOyekT5Rw4ubi(AkgHsB1cTvR9o0Pnu(xvjG2qkcbYhOngDKJvdofJqPTAH2uxkWRi0MD02ikWDLbAdP(LBsfAtVC)kAta4OnF7RPw8LHjj0Ms10bCkgkg(T5scUah8NikB1ruuoklwoPYMSmGStXWVnxsWf4G)erzRoIIveypgi6tYIacgjilSJjBVlT95TfCLcokgHsBc)iaTPTZjUcabGJ2e4G)erzJ2Qsjqi0g5ebAJ7DcTv6iL0graxAsBK7sCkg(T5scUah8NikB1ruKyNtCfacaNpJhcJLqA4e7CIRaqa4WHKrLqh5fwhp9nugsdN7Dc(FvPv7swOGJN(gkdPHZ9obFsKvcSfokg(T5scUah8NikB1rueKGiKgl3OsMy(mEimwcPHdsqesJLBujtmCizuj0Py43Mlj4cCWFIOSvhrrjxM3OvoI5Z4HqiglH0WbjicPXYnQKjgoKmQe6umumcL2qkH3WxzqN2GYGRgAZgrG2SfG243ohTneAJlZJKrLaofJqPnFftmAZV8UUSIy0MiNvSuwdTnE0MTa0wTIeGBmG2u74XOTAnFGyowsBcFbYLC(aTneAtGdiqA4um8BZLeeOY76YkI5Z4HGrcWngGZ5deZXYTdixY5d4qYOsOtXiuAZ3YA5pru2OnbNnxsBdH2e4apWbPnSuwdTjNCf0Pn7OnBbOnFXk21hoPTZJ2QvKaCNT4dTvLsGqOT)erzJ2kDKsAdYoTrwoNjRbNIHFBUKuhrrbNnx6Z4HWBuwSTde5jj1gjXUqH)oz)knXvQyxF4CFEBgja3zl4oqKNKu7sInfdfJqPnFlnW5Qey025rBptmcofd)2CjPoIILozFtwa2rXWVnxsQJOyfb2JbIekg(T5ssDef9ghSbjicPXskg(T5ssDefj25e3GeeH0yjfdfd)2CjPoII)LpKMJnOV9KSiqXWVnxsQJOiQ8U((822cSHeeRHIHFBUKuhrrLk21ho3N3MrcWD2cfd)2CjPoIIE3xrG(MrcWngSrbwKIHFBUKuhrrbvUXRMjv2OsMyum8BZLK6ikAlWUkrVQSV9o3dum8BZLK6ikkcINRM95TLv)03DhWIekg(T5ssDefDJabsyp5MiGFGIHFBUKuhrXspNSxgMC7aYLC(afd)2CjPoIIoGfmPY2tYIaXNXdHXofWWxawAlBbVHmFh7cfm2Pag(cWsBzl4TAJf2fk4nkl22bI8KKAxsSPyekT5BjT9mbOnFJ28oNYz0g5ebBzsfCkg(T5ssDefxa2zBGqG8bkgkg(T5ssDefrL313EvUA8z8qieJLqA4m5HSZ5d4qYOsOxOaALNhotEi7C(aELGcf(7K9R0eNjpKDoFa3bI8KeKvcSPy43Mlj1ruefCeWTAsfFgpecXyjKgotEi7C(aoKmQe6fkGw55HZKhYoNpGxjGIHFBUKuhrrVXbOY76(mEieIXsinCM8q258bCizuj0luaTYZdNjpKDoFaVsqHc)DY(vAIZKhYoNpG7arEscYkb2um8BZLK6ikY5deZXY9ZsPpJhcHySesdNjpKDoFahsgvc9cfqR88WzYdzNZhWReuOWFNSFLM4m5HSZ5d4oqKNKGSsGnfdfd)2CjPoIILbIaWTTZarkg(T5ssDeff4gXZ1hwUlLldum8BZLK6ik6XW2CCs8QiZLum8BZLK6ik(l8K7f2vgiMpJhc(TPmSHeehGGS1umum8BZLK6ikIYk7ZBBU5xr8z8qieJLqA4m5HSZ5d4qYOsOxOGqqR88WzYdzNZhWReqXWVnxsQJOi8l3KkBYY9R8z8qiSImijM7ergcKe7cf(7K9R0exYL5nALJy4oqKNKuBekFVqb0kppCjxM3KkNcGxjq4Oy43Mlj1ru0vLB(T5YTCiMpjlci4d8z8qWVnLHnKG4aeKHfYlSebGuUn2Pagb)x4j3YrzXYjvqgwfkqeas52yNcyeCjxM3OalImSeokg(T5ssDefDv5MFBUClhI5tYIacYKksyBStbmkgkgHsBcFQK2qBg7uaJ243MlPnbU5CJvdTjhIrXWVnxsW5dqqSZjUcabGJIHFBUKGZhuhrrM8q258bkg(T5scoFqDefLdsRA6BrwrK32zGifd)2CjbNpOoIIa7SfKwfVcOy43Mlj48b1ruuYL5nkWI(mEimwcPHZKhYoNpGdjJkHofd)2CjbNpOoII)cp5woklwoPcfd)2CjbNpOoIIeJT539H8lStbOy43Mlj48b1ruuYL5nALJy(iELNubXAFgpeglH0WzYdzNZhWHKrLqNIHFBUKGZhuhrrpjlcBYY9R8r8kpPcI1(mEiCGNdilmQeqE0kppC4xUjv2KL7xH3Vstkg(T5scoFqDef9ChX2KL7x5J4vEsfeRPyOyekTPNurc0MA2PagTvRVnxsBc)DZ5gRgAt41qmkgHsBivsQCaTj8utBdH243MYaTvLsGqOTAUkABHld02AHH2ohTjEoG2ig)Ri025rB(cMStB(IveJ28CNiTPTZjsBiLeeH0yjoTjSivxbOTNjGVM2Qe8N4Kk0wTsEAdTYOn(TPmqBAKYxiT1Vu4HrBchfd)2CjbNmPIe2g7uadHNKfHnz5(v(818syBStbmcI1(mEiewHyZVAsLcf6NH7jzrytwUFfUde5jj1gHY3foKxiOvEE4KkNcSpVTGRuWHxja5fcALNho8l3KkBYY9RWReqXWVnxsWjtQiHTXofWQJOitEi7C(afd)2CjbNmPIe2g7uaRoIIGeeH0y5gvYeJIHFBUKGtMurcBJDkGvhrrIDoXvaiaCum8BZLeCYKksyBStbS6ikkhKw103ISIiVTZarkg(T5scozsfjSn2PawDefLJYILtQSLmHCum8BZLeCYKksyBStbS6ikk5Y8gTYrmkg(T5scozsfjSn2PawDef9ChX2KL7x5Z4HaTYZdFEWRYvdELakg(T5scozsfjSn2PawDefNh8QC1qXWVnxsWjtQiHTXofWQJOiWoBztwUFffd)2CjbNmPIe2g7uaRoIIeJT539H8lStbOy43Mlj4KjvKW2yNcy1ruuoklwoPYg9Kgfd)2CjbNmPIe2g7uaRoIIEswe2KL7x5J4vEsfeR95R5LW2yNcyeeR9z8q4aphqwyujqXWVnxsWjtQiHTXofWQJOONKfHnz5(v(iELNubXAFgpeIxzqesdVpeJZhqgssXWVnxsWjtQiHTXofWQJOON7i2MSC)kFeVYtQGyDOldoYCzOclSXc71yVg5cDPSlNuHeAFtuW5mOtBcdTXVnxsBYHyeCkMqZv2Y5cTEeRKSnx6RCSNfA5qmsOo0KjvKW2yNcyH6q16qDOHKrLqp8hA(T5Yq7jzrytwUFvOF3yGB4qlS0MqOnB(vtQqBfkqB9ZW9KSiSjl3Vc3bI8KeAR2iOnLVtBchTH80MqOn0kppCsLtb2N3wWvk4WReqBipTjeAdTYZdh(LBsLnz5(v4vcc9xZlHTXofWiHQ1HfQWkuhA(T5YqZKhYoNpeAizuj0d)HfQkzOo08BZLHgKGiKgl3OsMyHgsgvc9WFyHkHjuhA(T5YqtSZjUcabGl0qYOsOh(dluvIqDO53MldTCqAvtFlYkI82odednKmQe6H)WcvizOo08BZLHwoklwoPYwYeYfAizuj0d)HfQq6H6qZVnxgAjxM3OvoIfAizuj0d)HfQ89qDOHKrLqp8h63ng4go0OvEE4ZdEvUAWReeA(T5Yq75oITjl3VkSqfYfQdn)2CzONh8QC1eAizuj0d)HfQwJDOo08BZLHgyNTSjl3Vk0qYOsOh(dluTEDOo08BZLHMySn)UpKFHDkqOHKrLqp8hwOAnwH6qZVnxgA5OSy5KkB0tAHgsgvc9WFyHQ1LmuhAXR8KkHQ1HgsgvcBXR8KkH)qZVnxgApjlcBYY9Rc9xZlHTXofWiHQ1H(DJbUHdTd8CazHrLqOHKrLqp8hwOATWeQdnKmQe6H)qdjJkHT4vEsLWFOF3yGB4qlELbrin8(qmoFG2qgTHKHMFBUm0Eswe2KL7xfAXR8KkHQ1HfQwxIqDOfVYtQeQwhAizujSfVYtQe(dn)2CzO9ChX2KL7xfAizuj0d)HfwO5dc1HQ1H6qZVnxgAIDoXvaiaCHgsgvc9WFyHkSc1HMFBUm0m5HSZ5dHgsgvc9WFyHQsgQdn)2CzOLdsRA6BrwrK32zGyOHKrLqp8hwOsyc1HMFBUm0a7SfKwfVccnKmQe6H)WcvLiuhAizuj0d)H(DJbUHdTXsinCM8q258bCizuj0dn)2CzOLCzEJcSyyHkKmuhA(T5Yq)l8KB5OSy5KkHgsgvc9WFyHkKEOo08BZLHMySn)UpKFHDkqOHKrLqp8hwOY3d1Hgsgvc9WFOHKrLWw8kpPs4p0VBmWnCOnwcPHZKhYoNpGdjJkHEO53MldTKlZB0khXcT4vEsLq16WcvixOo0qYOsOh(dnKmQe2Ix5jvc)H(DJbUHdTd8CazHrLaTH80gALNho8l3KkBYY9RW7xPzO53MldTNKfHnz5(vHw8kpPsOADyHQ1yhQdT4vEsLq16qdjJkHT4vEsLWFO53MldTN7i2MSC)QqdjJkHE4pSWcDh84kPfQdvRd1Hgsgvc9an0VBmWnCOzKaCJb4C(aXCSC7aYLC(aoKmQe6HMFBUm0OY76YkIfwOcRqDOHKrLqp8h63ng4go0EJYITDGipjH2QnTHKytBfkqB)DY(vAIRuXU(W5(82msaUZwWDGipjH2QnTvsSdn)2CzOfC2CzyHQsgQdn)2CzOlDY(MSaSl0qYOsOh(dlujmH6qZVnxg6kcShdejHgsgvc9WFyHQseQdn)2CzO9ghSbjicPXYqdjJkHE4pSqfsgQdn)2CzOj25e3GeeH0yzOHKrLqp8hwOcPhQdn)2CzO)lFinhBqF7jzri0qYOsOh(dlu57H6qZVnxgAu5D995TTfydjiwtOHKrLqp8hwOc5c1HMFBUm0kvSRpCUpVnJeG7SLqdjJkHE4pSq1ASd1HMFBUm0E3xrG(MrcWngSrbwm0qYOsOh(dluTEDOo08BZLHwqLB8QzsLnQKjwOHKrLqp8hwOAnwH6qZVnxgABb2vj6vL9T35Ei0qYOsOh(dluTUKH6qZVnxgArq8C1SpVTS6N(U7awKeAizuj0d)HfQwlmH6qZVnxgA3iqGe2tUjc4hcnKmQe6H)WcvRlrOo08BZLHU0Zj7LHj3oGCjNpeAizuj0d)HfQwJKH6qdjJkHE4p0VBmWnCOn2Pag(cWsBzl4nAdz0MVJnTvOaTzStbm8fGL2YwWB0wTPnSWM2kuG28gLfB7arEscTvBARKyhA(T5Yq7awWKkBpjlcKWcvRr6H6qZVnxg6fGD2gieiFi0qYOsOh(dluT23d1Hgsgvc9WFOF3yGB4qleAZyjKgotEi7C(aoKmQe60wHc0gALNhotEi7C(aELaARqbA7Vt2VstCM8q258bChiYtsOnKrBLa7qZVnxgAu5D9TxLRMWcvRrUqDOHKrLqp8h63ng4go0cH2mwcPHZKhYoNpGdjJkHoTvOaTHw55HZKhYoNpGxji08BZLHgfCeWTAsLWcvyHDOo0qYOsOh(d97gdCdhAHqBglH0WzYdzNZhWHKrLqN2kuG2qR88WzYdzNZhWReqBfkqB)DY(vAIZKhYoNpG7arEscTHmAReyhA(T5Yq7noavExpSqfwRd1Hgsgvc9WFOF3yGB4qleAZyjKgotEi7C(aoKmQe60wHc0gALNhotEi7C(aELaARqbA7Vt2VstCM8q258bChiYtsOnKrBLa7qZVnxgAoFGyowUFwkdluHfwH6qZVnxg6Yara422zGyOHKrLqp8hwOcRsgQdn)2CzOf4gXZ1hwUlLldHgsgvc9WFyHkSeMqDO53MldThdBZXjXRImxgAizuj0d)HfQWQeH6qdjJkHE4p0VBmWnCO53MYWgsqCacTHmABDO53Mld9VWtUxyxzGyHfQWcjd1Hgsgvc9WFOF3yGB4qleAZyjKgotEi7C(aoKmQe60wHc0MqOn0kppCM8q258b8kbHMFBUm0OSY(82MB(vKWcvyH0d1Hgsgvc9WFOF3yGB4qlS0MidsI5orAdziOnKeBARqbA7Vt2VstCjxM3OvoIH7arEscTvBe0MY3PTcfOn0kppCjxM3KkNcGxjG2eUqZVnxgA4xUjv2KL7xfwOclFpuhAizuj0d)H(DJbUHdn)2ug2qcIdqOnKrByrBipTjS0graiLBJDkGrW)fEYTCuwSCsfAdz0gw0wHc0graiLBJDkGrWLCzEJcSiTHmAdlAt4cn)2CzODv5MFBUClhIfA5qSDYIqO5dcluHfYfQdnKmQe6H)qZVnxgAxvU53Ml3YHyHwoeBNSieAYKksyBStbSWcl0cCWFIOSfQdvRd1HMFBUm0YrzXYjv2KLbK9qdjJkHE4pSqfwH6qdjJkHE4p0jlcHMrcYc7yY27sBFEBbxPGl08BZLHMrcYc7yY27sBFEBbxPGlSqvjd1Hgsgvc9WFOF3yGB4qBSesdNyNtCfacahoKmQe60gYtBclT54PVHYqA4CVtW)RknAR20wjPTcfOnhp9nugsdN7Dc(K0gYOTsGnTjCHMFBUm0e7CIRaqa4clujmH6qdjJkHE4p0VBmWnCOnwcPHdsqesJLBujtmCizuj0dn)2CzObjicPXYnQKjwyHQseQdnKmQe6H)q)UXa3WHwi0MXsinCqcIqASCJkzIHdjJkHEO53MldTKlZB0khXclSWclSia]] )

end
