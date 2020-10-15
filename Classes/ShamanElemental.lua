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

    spec:RegisterPack( "Elemental", 20201015, [[dKKQFaqicfpIqLnPGOpbIKmkrPQtPGWRKqZsuYTarIDHs)scggk0XKOwgkQNrOQPrOKRHI02ar8nqKACIsLZHIiRtuk6DekLmpfuDpLQ9bI6GIsPfkkEOOu4IOiSrcLs9rcLQoPckTsqAMOiQCtcLc7Ku8tcLkdffrXsjuk6PKmvsPRIIO0xbrsTxQ(RIgSsomYIb1JHmzjDzvBwu9zs1OvkNwQxJcMnQUnb7w43adNqoUckwUiphQPt56k02vGVdcnEuevDEqW6vqA(sK9t0EzxRRQKDxdZmYmJLzSmtzlxMrXZS4DLbbr3vIiedK(Dvqc3vmb)cpmI7kree4aQ6ADfgmMq3vBMjcNnluqVTTryweqOaUfg5K1GaLOCRaUfqfCf8yZTHnCyxvj7UgMzKzglZyzMYwUmJINXYUcl6ixdZqcZUARR1hoSRQhJCL4KlMGFHhgXLl1gjqHeQ4KlXoKbGFsUkZ0SKlMzKzgLqLqfNCLn2Oq)4SPeQ4Klif5kBR1xLlycXWOi5IjW4hOlxeCZBdcSUsucK387kXjxmb)cpmIlxQnsGcjuXjxIDida)KCvMPzjxmZiZmkHkHko5kBSrH(XztjuXjxqkYv2wRVkxWeIHrrYftGXpqxUi4M3geyLqLqjK1GaZkkDeqaMSI7f4T(MfDOpXB95vjuczniWSIshbeGjR4EHr8NTDHScs470qXBuIWZCqytq(ueaIpjHko5Ijl(YLYajbg(f9KCjkDeqaMm5Am4hJLlmq4YfvRy5cInNlxyreed5cdabRekHSgeywrPJacWKvCVa2ajbg(f9uwD(Ur8hgl2ajbg(f9e7dcM)6qM9jQRZp4HXs1kMfbgdB4IVuPe115h8WyPAfZ2bKzkJdHekHSgeywrPJacWKvCVW5x4Hr8jmNWwwD(Ur8hg75x4Hr8jmNWg7dcM)QekHSgeywrPJacWKvCVaNgqt4Xe2YQZ3fJr8hg75x4Hr8jmNWg7dcM)QeQeQ4KlMGj)rJ2RY1h8eeKlRfUCzBxUiKbsYvJLlAa1CcMFwjuXjxzdcBYvgoau5JytUeOyK4CiixDUCzBxUY2H(uBxU0MO2KRSnqhBjIlxInpgeuGUC1y5su64hgRekHSge4Dyoau5JylRoFNg6tTDwkqhBjIpthdckqN9bbZFvcvCY1WgqkiGamzYLiG1GqUASCjk98NEynX5qqU4DWWRYLbKlB7YLy)iLQnfYfixUY2H(eW2YsUgd(Xy5cbeGjtUGyZ5Y1JQCH3ajJdbwjuczniWf3licyniYQZ3ZB9nBMUa1bE4qcJLkHaaEfaXGvFKs1MIjiFsd9jGTXMUa1bE4INrjujuXjxdBypLgfzYfixUqe2WSsOeYAqGlUxaIDuN4TtjjuczniWf3lmI)STlGLqjK1GaxCVqEN(88l8WiUekHSge4I7fWgijmp)cpmIlHkHsiRbbU4EbeiqpSezVoZ5KWLqjK1GaxCVamhaQtq(02(8XfGGekHSge4I7f0hPuTPycYN0qFcyBsOeYAqGlUxihGgXVoPH(uBFcFsqcLqwdcCX9cIgtDoe6qFcZjSjHsiRbbU4EbB7ZXagmg1zoiHUekHSge4I7feUaibHjiFYhrDDwtNeWsOeYAqGlUxi1IeX)SJjweHUekHSge4I7fGiiXRdEhZ0XGGc0LqjK1GaxCVq6KOo0N5Cs44S68DJs63y3oXTTPiKb5SJXsLmkPFJD7e32MIq2WzMXsLYB9nBMUa1bE4INrjuXjxdBixicF5AyLRCqshyYfgiCBRdDwjuczniWf3lSDkzZJXpqxcvcLqwdcCX9cWCaOoZhtqiRoFxmgXFySeg9Osb6Spiy(RLkbpMNZsy0JkfOZokQujeaWRaigSeg9Osb6SPlqDGHmtzucLqwdcCX9cWpHFIHo0ZQZ3fJr8hglHrpQuGo7dcM)APsWJ55Seg9Osb6SJIKqjK1GaxCVqENomhaQz157IXi(dJLWOhvkqN9bbZFTuj4X8CwcJEuPaD2rrLkHaaEfaXGLWOhvkqNnDbQdmKzkJsOeYAqGlUxGc0XwI4teX5z157IXi(dJLWOhvkqN9bbZFTuj4X8CwcJEuPaD2rrLkHaaEfaXGLWOhvkqNnDbQdmKzkJsOsOeYAqGlUxyWXIEAAa7csOeYAqGlUxquQfaPAt8jePbxcLqwdcCX9c50NwIcC(iUbHekHSge4I7fqBuhZnkn4ylRoFNqwp4ZhxOpgYLLqLqjK1GaxCVamPpb5tl1igWz157IXi(dJLWOhvkqN9bbZFTujXapMNZsy0JkfOZokscLqwdcCX9chTb6qFI3aigYQZ3fOZXwcia5DiHrjuczniWf3lKgJjHSgetEJTScs47e4z157eY6bF(4c9XqM5Hm7XIoNpnkPFdZI2OoM8wFZIo0HmZLkHfDoFAus)gMLtdOj8jbiZ8qiHsiRbbU4EH0ymjK1GyYBSLvqcFh3Ho)tJs63KqLqfNCj2yKBTCzus)MCriRbHCjk1GuBqqU4n2KqjK1GaZsGVJnqsGHFrpjHsiRbbMLaV4EbcJEuPaDjuczniWSe4f3lW7HzSRtbsxGMgWUGekHSgeywc8I7foLSTHzKy4sOeYAqGzjWlUxGtdOj8jHS68DJ4pmwcJEuPaD2hem)vjuczniWSe4f3lG2OoM8wFZIo0LqjK1GaZsGxCVa2iRrZAJrBus)sOeYAqGzjWlUxGtdOj8ycBzjag0H(E5S68DJ4pmwcJEuPaD2hem)vjuczniWSe4f3lKZjHpXBaedzjag0H(E5SmkPFB257PNNoEJG5xcLqwdcmlbEX9c5ja2M4naIHSead6qFVSeQeQ4Klvh68lxAPK(n5kBrwdc5IjtQbP2GGCXKRXMeQ4KlMiWJPlxITvYvJLlcz9GlxJb)ySCbbWOCTrdUCvwSKlqsUeaPlxyJqmGLlqUCbPUJQCj2pIn5kpbeKlLbscYftWVWdJ4SYv2Zev9lxic)SPCnkcbe6qxUYwmsUGhn5Iqwp4YLIjeBjxvqaPYKRHqcLqwdcmlUdD(NgL0VTNZjHpXBaedzzus)2SZ3ZEXynIHo0lvQcm2Coj8jEdGyGnDbQd8W31r1Hyifd8yEolEmP)jiFkcaXNyhfjHsiRbbMf3Ho)tJs63kUxGWOhvkqxcLqwdcmlUdD(NgL0VvCVW5x4Hr8jmNWMekHSgeywCh68pnkPFR4EbSbscm8l6jjuczniWS4o05FAus)wX9c8Eyg76uG0fOPbSliHsiRbbMf3Ho)tJs63kUxG36Bw0H(KtymqcLqwdcmlUdD(NgL0VvCVaNgqt4Xe2KqjK1GaZI7qN)Prj9Bf3lKNayBI3aigYQZ3HhZZzB0ZhtqGDuKekHSgeywCh68pnkPFR4EHg98XeeKqjK1GaZI7qN)Prj9Bf3lCkzBt8gaXGekHSgeywCh68pnkPFR4EbSrwJM1gJ2OK(LqjK1GaZI7qN)Prj9Bf3lWB9nl6qFcd4MekHSgeywCh68pnkPFR4EHCoj8jEdGyilbWGo03lNLrj9BZoFp980XBem)sOeYAqGzXDOZ)0OK(TI7fY5KWN4naIHSead6qFVCwD(UayWfEyS1gBuGoKHejuczniWS4o05FAus)wX9c5ja2M4naIHSead6qFVSRg8eUbHRHzgzMXYmww8UcIuk6qh7QHvqeizVkxILCriRbHCXBSHzLqDfnABGKRuTWiNSgezJeLBUI3yd7ADfUdD(NgL0V5ADnLDTU6bbZF1Z4kuQTNAYvzVCjg5YAedDOlxLkjxvGXMZjHpXBaedSPlqDGLRHVlx6OQCneY1qkxIrUGhZZzXJj9pb5trai(e7OixriRbHRY5KWN4naIb3Cnm7ADfHSgeUIWOhvkq3vpiy(REg3CnI316kczniC15x4Hr8jmNWMREqW8x9mU5AelxRRiK1GWvydKey4x0tU6bbZF1Z4MRHPUwxriRbHR49Wm21PaPlqtdyxWvpiy(REg3CnqIR1veYAq4kERVzrh6toHXax9GG5V6zCZ1aPDTUIqwdcxXPb0eEmHnx9GG5V6zCZ1KDUwx9GG5V6zCfk12tn5k4X8C2g98Xeeyhf5kczniCvEcGTjEdGyWnxdtY16kczniCvJE(yccU6bbZF1Z4MRPmJUwxriRbHRoLSTjEdGyWvpiy(REg3CnLl7ADfHSgeUcBK1OzTXOnkPFx9GG5V6zCZ1uMzxRRiK1GWv8wFZIo0NWaU5Qhem)vpJBUMYI316Qhem)vpJREqW8pfad6q3Z4kczniCvoNe(eVbqm4kuQTNAYvPNNoEJG53vcGbDO7Ak7MRPSy5AD1dcM)QNXvpiy(NcGbDO7zCfk12tn5kbWGl8WyRn2OaD5cYYfK4kczniCvoNe(eVbqm4kbWGo0DnLDZ1uMPUwxjag0HURPSREqW8pfad6q3Z4kczniCvEcGTjEdGyWvpiy(REg3CZve4UwxtzxRRiK1GWvydKey4x0tU6bbZF1Z4MRHzxRRiK1GWveg9Osb6U6bbZF1Z4MRr8UwxriRbHR49Wm21PaPlqtdyxWvpiy(REg3CnILR1veYAq4QtjBBygjgUREqW8x9mU5AyQR1vpiy(REgxHsT9utUYi(dJLWOhvkqN9bbZF1veYAq4konGMWNeCZ1ajUwxriRbHRqBuhtERVzrh6U6bbZF1Z4MRbs7ADfHSgeUcBK1OzTXOnkPFx9GG5V6zCZ1KDUwx9GG5V6zC1dcM)Payqh6EgxHsT9utUYi(dJLWOhvkqN9bbZF1veYAq4konGMWJjS5kbWGo0DnLDZ1WKCTU6bbZF1Z4Qhem)tbWGo09mUIqwdcxLZjHpXBaedUcLA7PMCv65PJ3iy(DLayqh6UMYU5AkZOR1vcGbDO7Ak7Qhem)tbWGo09mUIqwdcxLNayBI3aigC1dcM)QNXn3Cv950i3CTUMYUwx9GG5V6WUcLA7PMCfn0NA7SuGo2seFMogeuGo7dcM)QRiK1GWvWCaOYhXMBUgMDTU6bbZF1Z4kuQTNAYv5T(MntxG6alxdxUGegLRsLKleaWRaigS6JuQ2umb5tAOpbSn20fOoWY1WLlXZORiK1GWvIawdc3CnI316kczniCfe7OoXBNsU6bbZF1Z4MRrSCTUIqwdcxnI)STlGD1dcM)QNXnxdtDTUIqwdcxL3Ppp)cpmI7Qhem)vpJBUgiX16kczniCf2ajH55x4HrCx9GG5V6zCZ1aPDTUIqwdcxHab6HLi71zoNeUREqW8x9mU5AYoxRRiK1GWvWCaOob5tB7ZhxacU6bbZF1Z4MRHj5ADfHSgeUsFKs1MIjiFsd9jGT5Qhem)vpJBUMYm6ADfHSgeUkhGgXVoPH(uBFcFsWvpiy(REg3CnLl7ADfHSgeUs0yQZHqh6tyoHnx9GG5V6zCZ1uMzxRRiK1GWv22NJbmymQZCqcDx9GG5V6zCZ1uw8UwxriRbHReUaibHjiFYhrDDwtNeWU6bbZF1Z4MRPSy5ADfHSgeUk1IeX)SJjweHUREqW8x9mU5AkZuxRRiK1GWvqeK41bVJz6yqqb6U6bbZF1Z4MRPmK4AD1dcM)QNXvOuBp1KRmkPFJD7e32MIqMCbz5k7yuUkvsUmkPFJD7e32MIqMCnC5IzgLRsLKR8wFZMPlqDGLRHlxINrxriRbHRsNe1H(mNtch7MRPmK216kczniC12PKnpg)aDx9GG5V6zCZ1uo7CTU6bbZF1Z4kuQTNAYvIrUmI)Wyjm6rLc0zFqW8xLRsLKl4X8CwcJEuPaD2rrYvPsYfca4vaedwcJEuPaD20fOoWYfKLlMYORiK1GWvWCaOoZhtqWnxtzMKR1vpiy(REgxHsT9utUsmYLr8hglHrpQuGo7dcM)QCvQKCbpMNZsy0JkfOZokYveYAq4k4NWpXqh6U5AyMrxRREqW8x9mUcLA7PMCLyKlJ4pmwcJEuPaD2hem)v5Quj5cEmpNLWOhvkqNDuKCvQKCHaaEfaXGLWOhvkqNnDbQdSCbz5IPm6kczniCvENomhaQU5AyUSR1vpiy(REgxHsT9utUsmYLr8hglHrpQuGo7dcM)QCvQKCbpMNZsy0JkfOZoksUkvsUqaaVcGyWsy0JkfOZMUa1bwUGSCXugDfHSgeUIc0XwI4teX5U5AyMzxRRiK1GWvdow0ttdyxWvpiy(REg3CnmlExRRiK1GWvIsTaivBIpHin4U6bbZF1Z4MRHzXY16kczniCvo9PLOaNpIBq4Qhem)vpJBUgMzQR1vpiy(REgxHsT9utUIqwp4ZhxOpwUGSCv2veYAq4k0g1XCJsdo2CZ1WmK4AD1dcM)QNXvOuBp1KReJCze)HXsy0JkfOZ(GG5VkxLkjxIrUGhZZzjm6rLc0zhf5kczniCfmPpb5tl1igWU5Aygs7AD1dcM)QNXvOuBp1KReOZXwciixqExUGegDfHSgeU6Onqh6t8gaXGBUgMZoxRREqW8x9mUcLA7PMCfHSEWNpUqFSCbz5Iz5AiLRSxUWIoNpnkPFdZI2OoM8wFZIo0LlilxmlxLkjxyrNZNgL0VHz50aAcFsqUGSCXSCneUIqwdcxLgJjHSgetEJnxXBSnds4UIa3nxdZmjxRREqW8x9mUIqwdcxLgJjHSgetEJnxXBSnds4Uc3Ho)tJs63CZnxjkDeqaMmxRRPSR1veYAq4kERVzrh6t8wFE1vpiy(REg3Cnm7AD1dcM)QNXvbjCxrdfVrjcpZbHnb5trai(KRiK1GWv0qXBuIWZCqytq(ueaIp5MRr8Uwx9GG5V6zCfk12tn5kJ4pmwSbscm8l6j2hem)v5AiLRSxUsuxNFWdJLQvmlcmgMCnC5s8YvPsYvI668dEySuTIz7qUGSCXugLRHWveYAq4kSbscm8l6j3CnILR1vpiy(REgxHsT9utUYi(dJ98l8Wi(eMtyJ9bbZF1veYAq4QZVWdJ4tyoHn3Cnm116Qhem)vpJRqP2EQjxjg5Yi(dJ98l8Wi(eMtyJ9bbZF1veYAq4konGMWJjS5MBU5MBUda]] )

end
